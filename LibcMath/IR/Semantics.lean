import LibcMath.IR.Syntax
import LibcMath.Arith

/-!
# Meaning of extracted code

Execution of a `Func` under a rounding direction, as a relation between arguments and results.

* A floating-point instruction is the IEEE 754 operation in the rounding direction in effect.
  LLVM itself only defines these instructions under the default floating-point environment; libc
  relies on the processor rounding them dynamically, and this file states that behavior.
* The result of a floating-point instruction is any bit pattern that encodes the right value, so
  nothing can be concluded about the sign or payload of a NaN it produces.
* `llvm.fmuladd` is a multiplication followed by an addition, and `quickGetRound` returns the
  `FE_*` constants of x86-64. Both describe x86-64 without FMA instructions.
* Core operations are given their intended behavior. Reporting through `errno` and the status
  flags has no effect on the values computed.
* Flags under which LLVM instructions yield poison (`nsw`, `nuw`, `samesign`, `inbounds`, …) are
  not represented, and shifts by the width or more are defined. Operations that are undefined for
  other reasons, such as an out-of-range `fptosi` or table index, have no result.
-/

namespace LibcMath.IR

/-- A runtime value: a bit vector of some width. -/
structure Val where
  width : ℕ
  bits : BitVec width

namespace Val

def ofNat (width n : ℕ) : Val := ⟨width, BitVec.ofNat width n⟩

def ofBool (b : Bool) : Val := ⟨1, BitVec.ofBool b⟩

/-- `v` is an encoding of `x` in format `F`. -/
def Encodes (F : Format) (v : Val) (x : Value) : Prop :=
  ∃ h : v.width = F.width, F.decode (v.bits.cast h) = x

end Val

abbrev Env := Reg → Option Val

def Env.ofArgs (args : List Val) : Env := fun r => args[r]?

def Env.set (env : Env) (r : Reg) (v : Val) : Env :=
  fun r' => if r' = r then some v else env r'

def Operand.eval (env : Env) : Operand → Option Val
  | .reg r => env r
  | .const width bits => some (.ofNat width bits)

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

/-- The comparison holds between two values, compared as extended reals when neither is NaN. -/
def FCmp.Holds (pred : FCmp) (a b : Value) : Prop :=
  match a.toEReal?, b.toEReal? with
  | some x, some y =>
    match pred with
    | .oeq | .ueq => x = y
    | .ogt | .ugt => y < x
    | .oge | .uge => y ≤ x
    | .olt | .ult => x < y
    | .ole | .ule => x ≤ y
    | .one | .une => x ≠ y
    | .ord => True
    | .uno => False
  | _, _ =>
    match pred with
    | .oeq | .ogt | .oge | .olt | .ole | .one | .ord => False
    | .ueq | .ugt | .uge | .ult | .ule | .une | .uno => True

noncomputable def FBinOp.eval (F : Format) (m : Mode) (a b : Value) : FBinOp → Value
  | .fadd => F.add m a b
  | .fsub => F.sub m a b
  | .fmul => F.mul m a b

/-- The value of `fegetround()` on x86-64. -/
def roundingConstant : Mode → ℕ
  | .nearestEven => 0
  | .downward => 0x400
  | .upward => 0x800
  | .towardZero => 0xc00

/-- `r` is a possible result of the core operation under rounding direction `m`. -/
def CoreOp.Eval (m : Mode) : CoreOp → Val → Prop
  | .quickGetRound, r => r = .ofNat 32 (roundingConstant m)
  | .isRoundUp, r => r = .ofBool (m = .upward)
  | .isRoundDown, r => r = .ofBool (m = .downward)
  | .isRoundToNearest, r => r = .ofBool (m = .nearestEven)
  | .isRoundToZero, r => r = .ofBool (m = .towardZero)
  | .setErrno, r => r.width = 0
  | .raiseExcept, r => r.width = 32

open Classical in
/-- `r` is a possible result of the instruction. -/
def Instr.Eval (m : Mode) (f : Func) (env : Env) : Instr → Val → Prop
  | .intBin op a b, r =>
    ∃ w x y, a.eval env = some ⟨w, x⟩ ∧ b.eval env = some ⟨w, y⟩ ∧ r = ⟨w, op.eval x y⟩
  | .icmp pred a b, r =>
    ∃ w x y, a.eval env = some ⟨w, x⟩ ∧ b.eval env = some ⟨w, y⟩ ∧ r = .ofBool (pred.eval x y)
  | .zext width a, r => ∃ v, a.eval env = some v ∧ r = ⟨width, v.bits.setWidth width⟩
  | .sext width a, r => ∃ v, a.eval env = some v ∧ r = ⟨width, v.bits.signExtend width⟩
  | .trunc width a, r => ∃ v, a.eval env = some v ∧ r = ⟨width, v.bits.setWidth width⟩
  | .select cond a b, r =>
    ∃ c, cond.eval env = some (.ofBool c) ∧ (if c then a.eval env else b.eval env) = some r
  | .fBin F op a b, r =>
    ∃ va vb x y, a.eval env = some va ∧ b.eval env = some vb ∧ va.Encodes F x ∧ vb.Encodes F y ∧
      r.Encodes F (op.eval F m x y)
  | .fneg F a, r => ∃ v x, a.eval env = some v ∧ v.Encodes F x ∧ r.Encodes F x.neg
  | .fabs F a, r => ∃ v x, a.eval env = some v ∧ v.Encodes F x ∧ r.Encodes F x.abs
  | .fmuladd F a b c, r =>
    ∃ va vb vc x y z, a.eval env = some va ∧ b.eval env = some vb ∧ c.eval env = some vc ∧
      va.Encodes F x ∧ vb.Encodes F y ∧ vc.Encodes F z ∧ r.Encodes F (F.add m (F.mul m x y) z)
  | .fcmp F pred a b, r =>
    ∃ va vb x y, a.eval env = some va ∧ b.eval env = some vb ∧ va.Encodes F x ∧ vb.Encodes F y ∧
      r = .ofBool (pred.Holds x y)
  | .fpConvert src dst a, r =>
    ∃ v x, a.eval env = some v ∧ v.Encodes src x ∧ r.Encodes dst (dst.convert m x)
  | .fptosi src width a, r =>
    ∃ v x n, a.eval env = some v ∧ v.Encodes src x ∧ x.truncInt? = some n ∧
      -2 ^ (width - 1) ≤ n ∧ n < 2 ^ (width - 1) ∧ r = ⟨width, BitVec.ofInt width n⟩
  | .bitcast a, r => a.eval env = some r
  | .load table index, r =>
    ∃ t i e, f.tables[table]? = some t ∧ index.eval env = some i ∧
      t.elems[i.bits.toNat]? = some e ∧ r = .ofNat t.width e
  | .call op _, r => op.Eval m r

/-- Execute the instructions of a block in order. -/
inductive ExecBody (m : Mode) (f : Func) : Env → List (Reg × Instr) → Env → Prop
  | nil (env : Env) : ExecBody m f env [] env
  | cons {env env' : Env} {r : Reg} {i : Instr} {v : Val} {rest : List (Reg × Instr)} :
    i.Eval m f env v → ExecBody m f (env.set r v) rest env' →
    ExecBody m f env ((r, i) :: rest) env'

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
inductive Run (m : Mode) (f : Func) : (pred cur : ℕ) → Env → Val → Prop
  | ret {pred cur : ℕ} {env env₁ env₂ : Env} {b : Block} {a : Operand} {result : Val} :
    f.blocks[cur]? = some b → EnterPhis pred env env b.phis env₁ →
    ExecBody m f env₁ b.body env₂ → b.term = .ret a → a.eval env₂ = some result →
    Run m f pred cur env result
  | br {pred cur target : ℕ} {env env₁ env₂ : Env} {b : Block} {result : Val} :
    f.blocks[cur]? = some b → EnterPhis pred env env b.phis env₁ →
    ExecBody m f env₁ b.body env₂ → b.term = .br target →
    Run m f cur target env₂ result → Run m f pred cur env result
  | condBr {pred cur ifTrue ifFalse : ℕ} {env env₁ env₂ : Env} {b : Block} {cond : Operand}
      {c : Bool} {result : Val} :
    f.blocks[cur]? = some b → EnterPhis pred env env b.phis env₁ →
    ExecBody m f env₁ b.body env₂ → b.term = .condBr cond ifTrue ifFalse →
    cond.eval env₂ = some (.ofBool c) →
    Run m f cur (if c then ifTrue else ifFalse) env₂ result → Run m f pred cur env result

/-- Called on `args` under rounding direction `m`, the function can return `result`. -/
def Func.Returns (m : Mode) (f : Func) (args : List Val) (result : Val) : Prop :=
  Run m f 0 0 (Env.ofArgs args) result

/-- The extracted unary function `f` is a correctly rounded implementation of `S`: on every input
it has a result, and every result it can have encodes the prescribed value. -/
def Func.CorrectlyRounded (F : Format) (S : Spec) (modes : Set Mode) (f : Func) : Prop :=
  ∀ m ∈ modes, ∀ b : BitVec F.width,
    (∃ r, f.Returns m [⟨F.width, b⟩] r) ∧
    ∀ r, f.Returns m [⟨F.width, b⟩] r → r.Encodes F (S.eval F m (F.decode b))

end LibcMath.IR
