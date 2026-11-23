import LibcMath.IR.Syntax
import LibcMath.Spec
import FloatLib.Floats.Formats.BinaryInterchange.Arithmetic.Runtime
import FloatLib.Floats.Formats.BinaryInterchange.Conversion.Cast.Runtime
import FloatLib.Floats.Formats.BinaryInterchange.Operations.Compare.Runtime
import FloatLib.Floats.Formats.BinaryInterchange.DType.Cast

/-!
# Meaning of extracted code

Execution of a `Func` under a rounding direction, as a relation between arguments and results.

* A floating-point instruction is the corresponding IEEE 754 operation of FloatLib in the
  rounding direction in effect. LLVM itself only defines these instructions under the default
  floating-point environment; libc relies on the processor rounding them dynamically, and this
  file states that behavior.
* The result of an arithmetic instruction or conversion is any bit pattern with the same value as
  FloatLib's result (`SameValue`), so nothing can be concluded about the sign or payload of a NaN
  it produces. `fneg` and `fabs` only change the sign bit, and their results are exact.
* `llvm.fmuladd` is a multiplication followed by an addition, and `quickGetRound` returns the
  `FE_*` constants of x86-64. Both describe x86-64 without FMA instructions.
* Core operations are given their intended behavior. Reporting through `errno` and the status
  flags has no effect on the values computed.
* An instruction that LLVM leaves undefined, or whose result would be poison, has no result:
  an out-of-range `fptosi` or table index, a shift by the width or more, and an instruction with
  a flag (`Flags`) whose condition fails. The conditions are those of the LLVM Language Reference.
  There are therefore no poison or undefined values: an execution that returns a result has
  produced none. This also covers the `inbounds`, `nuw` and `nusw` flags of the address of a
  table access and `noundef` on the arguments of a call.
* Not represented, and rejected by `ir2lean` instead: fast-math flags, and metadata and
  attributes of an instruction under which its result is poison (`range`, `nofpclass`, …).
  Attributes of the function itself and of its parameters are not examined.
-/

namespace LibcMath.IR

open FloatLib.Floats.Formats.BinaryInterchange
open FloatLib.Floats.ExecFloat (ConversionOutcome)
open Model (IEEERoundingMode)

/-- A runtime value: a bit vector of some width. -/
structure Val where
  width : ℕ
  bits : BitVec width

namespace Val

def ofNat (width n : ℕ) : Val := ⟨width, BitVec.ofNat width n⟩

def ofBool (b : Bool) : Val := ⟨1, BitVec.ofBool b⟩

def ofModel {fmt : FloatFormat} (x : Model fmt) : Val := ⟨fmt.bitWidth, x.toBits⟩

/-- The value read as a bit pattern of format `fmt`, if it has the width of that format. -/
def toModel? (fmt : FloatFormat) (v : Val) : Option (Model fmt) :=
  if h : v.width = fmt.bitWidth then some (.ofBits (v.bits.cast h)) else none

/-- `v` is a bit pattern of format `fmt` with the same value as `x`. -/
def Encodes {fmt : FloatFormat} (v : Val) (x : Model fmt) : Prop :=
  ∃ y, v.toModel? fmt = some y ∧ SameValue y x

end Val

abbrev Env := Reg → Option Val

def Env.ofArgs (args : List Val) : Env := fun r => args[r]?

def Env.set (env : Env) (r : Reg) (v : Val) : Env :=
  fun r' => if r' = r then some v else env r'

def Operand.eval (env : Env) : Operand → Option Val
  | .reg r => env r
  | .const width bits => some (.ofNat width bits)

/-- The result of `add`, `sub`, `mul` or `shl` on `w`-bit operands does not overflow in the ways
`nuw` and `nsw` forbid: when `nuw` is set, the mathematical result `unsigned` on the operands read
as unsigned integers is an unsigned `w`-bit integer, and when `nsw` is set, the mathematical
result `signed` on the operands read as signed integers is a signed `w`-bit integer. -/
def Flags.noWrap (flags : Flags) (w : ℕ) (unsigned signed : ℤ) : Bool :=
  (!flags.nuw || (0 ≤ unsigned && unsigned < 2 ^ w)) &&
    (!flags.nsw || (-2 ^ (w - 1) ≤ signed && signed < 2 ^ (w - 1)))

/-- The instruction has a result on `a` and `b`: a shift amount is less than the width, and the
conditions of the flags that are set hold. A left shift by `b` multiplies by `2 ^ b`, so the bits
it shifts out are zero (`nuw`), or agree with the sign of the result (`nsw`), exactly when that
product does not overflow. -/
def IntBinOp.defined {w : ℕ} (flags : Flags) (a b : BitVec w) : IntBinOp → Bool
  | .add => flags.noWrap w (a.toNat + b.toNat) (a.toInt + b.toInt)
  | .sub => flags.noWrap w (a.toNat - b.toNat) (a.toInt - b.toInt)
  | .mul => flags.noWrap w (a.toNat * b.toNat) (a.toInt * b.toInt)
  | .and | .xor => true
  | .or => !flags.disjoint || a &&& b == 0
  | .shl => b.toNat < w && flags.noWrap w (a.toNat * 2 ^ b.toNat) (a.toInt * 2 ^ b.toNat)
  | .lshr | .ashr => b.toNat < w && (!flags.exact || a.toNat % 2 ^ b.toNat == 0)

/-- The result of the instruction where `IntBinOp.defined` holds. -/
def IntBinOp.eval {w : ℕ} (a b : BitVec w) : IntBinOp → BitVec w
  | .add => a + b
  | .sub => a - b
  | .mul => a * b
  | .and => a &&& b
  | .or => a ||| b
  | .xor => a ^^^ b
  | .shl => a <<< b
  | .lshr => a >>> b
  | .ashr => a.sshiftRight' b

/-- An `icmp` has a result on `a` and `b`: with `samesign`, their sign bits agree. -/
def Flags.icmpDefined {w : ℕ} (flags : Flags) (a b : BitVec w) : Bool :=
  !flags.samesign || a.msb == b.msb

/-- A `zext` has a result on `a`: with `nneg`, its sign bit is clear. -/
def Flags.zextDefined {w : ℕ} (flags : Flags) (a : BitVec w) : Bool :=
  !flags.nneg || !a.msb

/-- A `trunc` to `width` bits has a result on `a`: the truncated value is `a` as an unsigned
integer with `nuw`, and as a signed integer with `nsw`. -/
def Flags.truncDefined {w : ℕ} (flags : Flags) (width : ℕ) (a : BitVec w) : Bool :=
  (!flags.nuw || (a.setWidth width).toNat == a.toNat) &&
    (!flags.nsw || (a.setWidth width).toInt == a.toInt)

def ICmp.eval {w : ℕ} (a b : BitVec w) : ICmp → Bool
  | .eq => a == b
  | .ne => a != b
  | .ult => a.ult b
  | .ule => a.ule b
  | .ugt => b.ult a
  | .uge => b.ule a
  | .slt => a.slt b
  | .sle => a.sle b
  | .sgt => b.slt a
  | .sge => b.sle a

/-- The outcome of a comparison, given the IEEE ordering of its operands, which is `none` when
one of them is NaN. -/
def FCmp.eval : FCmp → Option Ordering → Bool
  | .oeq, o => o == some .eq
  | .ogt, o => o == some .gt
  | .oge, o => o == some .gt || o == some .eq
  | .olt, o => o == some .lt
  | .ole, o => o == some .lt || o == some .eq
  | .one, o => o == some .lt || o == some .gt
  | .ord, o => o.isSome
  | .ueq, o => o == none || o == some .eq
  | .ugt, o => o == none || o == some .gt
  | .uge, o => o != some .lt
  | .ult, o => o == none || o == some .lt
  | .ule, o => o != some .gt
  | .une, o => o != some .eq
  | .uno, o => o.isNone

def FBinOp.eval {fmt : FloatFormat} (mode : IEEERoundingMode) (x y : Model fmt) :
    FBinOp → Model fmt
  | .fadd => Model.add x y mode
  | .fsub => Model.sub x y mode
  | .fmul => Model.mul x y mode

/-- The value of `fegetround()` on x86-64, for the rounding directions C can select. -/
def roundingConstant : IEEERoundingMode → Option ℕ
  | .nearest => some 0
  | .down => some 0x400
  | .up => some 0x800
  | .towardZero => some 0xc00
  | .nearestAway | .away => none

/-- `r` is a possible result of the core operation under rounding direction `mode`. -/
def CoreOp.Eval (mode : IEEERoundingMode) : CoreOp → Val → Prop
  | .quickGetRound, r => ∃ c, roundingConstant mode = some c ∧ r = .ofNat 32 c
  | .isRoundUp, r => r = .ofBool (mode = .up)
  | .isRoundDown, r => r = .ofBool (mode = .down)
  | .isRoundToNearest, r => r = .ofBool (mode = .nearest)
  | .isRoundToZero, r => r = .ofBool (mode = .towardZero)
  | .setErrno, r => r.width = 0
  | .raiseExcept, r => r.width = 32

/-- `r` is a possible result of the instruction. -/
def Instr.Eval (mode : IEEERoundingMode) (f : Func) (env : Env) : Instr → Val → Prop
  | .intBin op a b flags, r =>
    ∃ w x y, a.eval env = some ⟨w, x⟩ ∧ b.eval env = some ⟨w, y⟩ ∧
      op.defined flags x y = true ∧ r = ⟨w, op.eval x y⟩
  | .icmp pred a b flags, r =>
    ∃ w x y, a.eval env = some ⟨w, x⟩ ∧ b.eval env = some ⟨w, y⟩ ∧
      flags.icmpDefined x y = true ∧ r = .ofBool (pred.eval x y)
  | .zext width a flags, r =>
    ∃ v, a.eval env = some v ∧ flags.zextDefined v.bits = true ∧
      r = ⟨width, v.bits.setWidth width⟩
  | .sext width a, r => ∃ v, a.eval env = some v ∧ r = ⟨width, v.bits.signExtend width⟩
  | .trunc width a flags, r =>
    ∃ v, a.eval env = some v ∧ flags.truncDefined width v.bits = true ∧
      r = ⟨width, v.bits.setWidth width⟩
  | .select cond a b, r =>
    ∃ c, cond.eval env = some (.ofBool c) ∧ (if c then a.eval env else b.eval env) = some r
  | .fBin fmt op a b, r =>
    ∃ x y, (a.eval env).bind (·.toModel? fmt) = some x ∧
      (b.eval env).bind (·.toModel? fmt) = some y ∧ r.Encodes (op.eval mode x y)
  | .fneg fmt a, r => ∃ x, (a.eval env).bind (·.toModel? fmt) = some x ∧ r = .ofModel x.neg
  | .fabs fmt a, r => ∃ x, (a.eval env).bind (·.toModel? fmt) = some x ∧ r = .ofModel x.abs
  | .fmuladd fmt a b c, r =>
    ∃ x y z, (a.eval env).bind (·.toModel? fmt) = some x ∧
      (b.eval env).bind (·.toModel? fmt) = some y ∧
      (c.eval env).bind (·.toModel? fmt) = some z ∧
      r.Encodes (Model.add (Model.mul x y mode) z mode)
  | .fcmp fmt pred a b, r =>
    ∃ x y, (a.eval env).bind (·.toModel? fmt) = some x ∧
      (b.eval env).bind (·.toModel? fmt) = some y ∧ r = .ofBool (pred.eval (Model.compare x y))
  | .fpConvert src dst a, r =>
    ∃ x, (a.eval env).bind (·.toModel? src) = some x ∧ r.Encodes (Model.cast src dst x mode)
  | .fptosi src width a, r =>
    ∃ x n status, (a.eval env).bind (·.toModel? src) = some x ∧
      ExecDType.convertToInteger (width := width) x .towardZero = .success n status ∧
      r = ⟨width, n.bits⟩
  | .bitcast a, r => a.eval env = some r
  | .load table index, r =>
    ∃ t i e, f.tables[table]? = some t ∧ index.eval env = some i ∧
      t.elems[i.bits.toNat]? = some e ∧ r = .ofNat t.width e
  | .call op _, r => op.Eval mode r

/-- Execute the instructions of a block in order. -/
inductive ExecBody (mode : IEEERoundingMode) (f : Func) : Env → List (Reg × Instr) → Env → Prop
  | nil (env : Env) : ExecBody mode f env [] env
  | cons {env env' : Env} {r : Reg} {i : Instr} {v : Val} {rest : List (Reg × Instr)} :
    i.Eval mode f env v → ExecBody mode f (env.set r v) rest env' →
    ExecBody mode f env ((r, i) :: rest) env'

/-- Assign the phi nodes of a block entered from block `pred`. All of them read the environment
`old` in effect at the end of `pred`. -/
inductive EnterPhis (pred : ℕ) (old : Env) : Env → List (Reg × List (ℕ × Operand)) → Env → Prop
  | nil (env : Env) : EnterPhis pred old env [] env
  | cons {env env' : Env} {r : Reg} {incoming : List (ℕ × Operand)} {a : Operand} {v : Val}
      {rest : List (Reg × List (ℕ × Operand))} :
    incoming.lookup pred = some a → a.eval old = some v →
    EnterPhis pred old (env.set r v) rest env' →
    EnterPhis pred old env ((r, incoming) :: rest) env'

/-- Starting at block `cur`, entered from block `pred` with environment `env`, the function can
return `result`. -/
inductive Run (mode : IEEERoundingMode) (f : Func) : (pred cur : ℕ) → Env → Val → Prop
  | ret {pred cur : ℕ} {env env₁ env₂ : Env} {b : Block} {a : Operand} {result : Val} :
    f.blocks[cur]? = some b → EnterPhis pred env env b.phis env₁ →
    ExecBody mode f env₁ b.body env₂ → b.term = .ret a → a.eval env₂ = some result →
    Run mode f pred cur env result
  | br {pred cur target : ℕ} {env env₁ env₂ : Env} {b : Block} {result : Val} :
    f.blocks[cur]? = some b → EnterPhis pred env env b.phis env₁ →
    ExecBody mode f env₁ b.body env₂ → b.term = .br target →
    Run mode f cur target env₂ result → Run mode f pred cur env result
  | condBr {pred cur ifTrue ifFalse : ℕ} {env env₁ env₂ : Env} {b : Block} {cond : Operand}
      {c : Bool} {result : Val} :
    f.blocks[cur]? = some b → EnterPhis pred env env b.phis env₁ →
    ExecBody mode f env₁ b.body env₂ → b.term = .condBr cond ifTrue ifFalse →
    cond.eval env₂ = some (.ofBool c) →
    Run mode f cur (if c then ifTrue else ifFalse) env₂ result → Run mode f pred cur env result

/-- Called on `args` under rounding direction `mode`, the function can return `result`. -/
def Func.Returns (mode : IEEERoundingMode) (f : Func) (args : List Val) (result : Val) : Prop :=
  Run mode f 0 0 (Env.ofArgs args) result

/-- The extracted unary function `f` is a correctly rounded implementation of `S`: on every input
it has a result, and every result it can have is the prescribed one. -/
def Func.CorrectlyRounded {fmt : FloatFormat} (S : Spec fmt) (modes : Set IEEERoundingMode)
    (f : Func) : Prop :=
  ∀ mode ∈ modes, ∀ x : Model fmt,
    (∃ r, f.Returns mode [.ofModel x] r) ∧
    ∀ r, f.Returns mode [.ofModel x] r → r.Encodes (S.eval mode x)

end LibcMath.IR
