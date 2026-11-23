import LibcMath.IR.Interp

/-!
# Running the interpreter on a symbolic input

`Func.exec` can be evaluated on an input that is not a literal, as long as the hypotheses about
the input decide every branch on the way. This file collects what such an evaluation needs:

* `Func.execFrom_of_block` executes one block whose index is known. Unlike the defining equation
  of `Func.execFrom` it does not apply while the index of the block still depends on an undecided
  branch condition, so rewriting with it stops at the first branch the hypotheses do not decide.
* `Store.get_ofArgs` reads a parameter; `Store.get_set` (in `Interp.lean`) reads a register.
* `Val.ofModel_binary32` and `Val.toModel?_binary32` move between a binary32 value and its 32-bit
  pattern, and `Val.toBits_abs_binary32` is the pattern of `fabs`, so that integer instructions on
  the pattern of a floating-point register reduce. The input is best written `Model.ofBits b` for
  a variable `b : BitVec 32`.
* `ICmp.eval_ult` and its companions, `IntBinOp.defined_add_nsw` and
  `Flags.icmpDefined_samesign` state comparisons and flag conditions in terms of `BitVec.toNat`,
  where `omega` proves them.
* `Func.runUnary_of_exec_exact` and `Func.runUnary_of_exec_ofFloat` read off the result of
  `Func.runUnary`.
* `nonNaN`, `Operand.execFloat_eq` and `AbsVal.toModel?_ofFloat` read a floating-point register
  that holds the result of an arithmetic instruction, `fptosi?` and `Instr.exec_fptosi` state
  `fptosi`, and `execBody_cons` executes one instruction of a block.

The tactic `exec_blocks [h₁, h₂, …]` evaluates `Func.exec` with the lemmas on stores and values
above. The `hᵢ` are the block lemmas
`Func.execFrom_of_block hblock` of the function at hand, the values of its branch conditions
(`ICmp.eval a b pred = c`), and the flag conditions of its instructions.
-/

namespace LibcMath.IR

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

namespace Val

@[simp]
theorem toModel?_ofModel {fmt : FloatFormat} (x : Model fmt) :
    (ofModel x).toModel? fmt = some x := by
  cases x
  simp only [toModel?, ofModel, Model.ofBits, Model.toBits, ↓reduceDIte]
  rfl

/-- A binary32 value as a runtime value of width 32. -/
theorem ofModel_binary32 (x : Model .binary32) : ofModel x = ⟨32, x.toBits⟩ :=
  rfl

theorem toModel?_binary32 (bits : BitVec 32) :
    toModel? .binary32 ⟨32, bits⟩ = some (.ofBits bits) :=
  rfl

theorem toBits_ofBits_binary32 (bits : BitVec 32) :
    (Model.ofBits bits : Model .binary32).toBits = bits :=
  rfl

/-- `fabs` clears the sign bit. -/
theorem toBits_abs_binary32 (bits : BitVec 32) :
    (Model.ofBits bits : Model .binary32).abs.toBits = bits &&& 0x7FFFFFFF#32 := by
  have hsigned : FloatFormat.binary32.supportsSignedZero = true := rfl
  have hmask : FloatFormat.signMask .binary32 = 0x80000000#32 := rfl
  have hzero : Model.signBit (Model.posZero .binary32) = false := rfl
  have hbits (b : BitVec 32) :
      (if (b.msb == false) = true then b else b ^^^ 0x80000000#32) = b &&& 0x7FFFFFFF#32 := by
    have hlt := b.isLt
    apply BitVec.eq_of_toNat_eq
    rw [BitVec.toNat_and, show (0x7FFFFFFF#32).toNat = 2 ^ 31 - 1 from rfl,
      Nat.and_two_pow_sub_one_eq_mod]
    split <;> rename_i hmsb <;>
      simp only [BitVec.msb_eq_decide, beq_iff_eq, decide_eq_false_iff_not, not_le] at hmsb
    · omega
    · rw [BitVec.toNat_xor, show (0x80000000#32).toNat = 2 ^ 31 from rfl]
      apply Nat.eq_of_testBit_eq
      intro i
      rw [Nat.testBit_xor, Nat.testBit_two_pow, Nat.testBit_mod_two_pow]
      rcases Nat.lt_trichotomy i 31 with hi | rfl | hi
      · simp [hi, Nat.ne_of_gt hi]
      · have htop : b.toNat.testBit 31 = true := by
          rw [Nat.testBit_eq_decide_div_mod_eq, decide_eq_true_eq]
          omega
        simp [htop]
      · have htop : b.toNat.testBit i = false :=
          Nat.testBit_lt_two_pow (hlt.trans_le (Nat.pow_le_pow_right (by norm_num) hi))
        simp [htop, Nat.ne_of_lt hi, Nat.not_lt_of_gt hi]
  simp only [Model.abs, Model.copySign, hsigned, Bool.not_true, Bool.false_and, Bool.false_eq_true,
    ↓reduceIte, hzero, Model.signBit_eq_msb, Model.toggleSign, hmask, Model.toBits, Model.ofBits]
  rw [← hbits bits]
  split <;> rename_i h
  · exact (ite_eq_left h).symm
  · exact (ite_eq_right h).symm

end Val

theorem Store.get_ofArgs (args : List Val) (r : Reg) :
    (Store.ofArgs args).get r = args[r]?.map .exact := by
  cases h : args[r]? <;> simp [Store.get, Store.ofArgs, h]

/-! ## Integer conditions as statements about natural numbers

The value of a comparison and the condition of a flag, in terms of `BitVec.toNat` and
`BitVec.toInt`. Integer constants are written as numerals, because the kernel evaluates a power
of an integer one multiplication at a time. Together with `toInt_eq_toNat_sub`,
`BitVec.toNat_and` and the two lemmas on masks below, they turn a branch condition on a 32-bit
register into linear arithmetic with division by constants, which `omega` decides.

Two things to avoid with Lean 4.36: `simp only [BitVec.toNat_add]` does not terminate on a sum
with a literal operand, so that lemma is applied with `rw`; and `omega` is slow on the remainder
of a sum of large constants, where it helps to say first whether the sum wraps around. -/

theorem ICmp.eval_eq {w : ℕ} (a b : BitVec w) :
    ICmp.eq.eval a b = decide (a.toNat = b.toNat) := by
  rw [Bool.eq_iff_iff]
  simp [ICmp.eval, BitVec.toNat_inj]

theorem ICmp.eval_ult {w : ℕ} (a b : BitVec w) :
    ICmp.ult.eval a b = decide (a.toNat < b.toNat) :=
  rfl

theorem ICmp.eval_ugt {w : ℕ} (a b : BitVec w) :
    ICmp.ugt.eval a b = decide (b.toNat < a.toNat) :=
  rfl

theorem ICmp.eval_sgt {w : ℕ} (a b : BitVec w) :
    ICmp.sgt.eval a b = decide (b.toInt < a.toInt) :=
  rfl

/-- `add nsw` has a result exactly when the signed sum is a signed integer of the width. -/
theorem IntBinOp.defined_add_nsw (a b : BitVec 32) :
    IntBinOp.add.defined { nsw := true } a b =
      decide (-0x80000000 ≤ a.toInt + b.toInt ∧ a.toInt + b.toInt < 0x80000000) := by
  simp [defined, Flags.noWrap]

/-- `icmp samesign` has a result exactly when the sign bits of its operands agree. -/
theorem Flags.icmpDefined_samesign (a b : BitVec 32) :
    Flags.icmpDefined { samesign := true } a b =
      decide (2 ^ 31 ≤ a.toNat ↔ 2 ^ 31 ≤ b.toNat) := by
  simp [Flags.icmpDefined, BitVec.msb_eq_decide]

/-- The signed value of a 32-bit vector. -/
theorem toInt_eq_toNat_sub (a : BitVec 32) :
    a.toInt = (a.toNat : ℤ) - 0x100000000 * (a.toNat / 2 ^ 31 : ℕ) := by
  have hlt := a.isLt
  rw [BitVec.toInt_eq_toNat_cond]
  split <;> omega

/-- Masking with `k` set bits starting at bit `s` selects those bits. -/
theorem and_shiftLeft_mask (n k s : ℕ) :
    n &&& (2 ^ k - 1) <<< s = n / 2 ^ s % 2 ^ k * 2 ^ s := by
  apply Nat.eq_of_testBit_eq
  intro i
  rw [← Nat.shiftRight_eq_div_pow, ← Nat.shiftLeft_eq, Nat.testBit_and, Nat.testBit_shiftLeft,
    Nat.testBit_shiftLeft, Nat.testBit_mod_two_pow, Nat.testBit_shiftRight,
    Nat.testBit_two_pow_sub_one]
  by_cases hi : s ≤ i
  · simp [hi, Nat.add_sub_cancel' hi, Bool.and_comm]
  · simp [hi]

/-- `and` always has a result. -/
theorem IntBinOp.defined_and {w : ℕ} (flags : Flags) (a b : BitVec w) :
    IntBinOp.and.defined flags a b = true :=
  rfl

/-- An `icmp` without flags always has a result. -/
@[simp]
theorem Flags.icmpDefined_default {w : ℕ} (a b : BitVec w) :
    Flags.icmpDefined { } a b = true :=
  rfl

/-- An instruction without fast-math flags accepts every value. -/
@[simp]
theorem FastMathFlags.admits_default {fmt : FloatFormat} (x : Model fmt) :
    FastMathFlags.admits { } x = true :=
  rfl

/-- Execution of the block `cur`, when it is known which block that is. -/
theorem Func.execFrom_of_block {mode : IEEERoundingMode} {f : Func} {cur : ℕ} {b : Block}
    (hb : f.blocks[cur]? = some b) (fuel pred : ℕ) (s : Store) :
    f.execFrom mode (fuel + 1) pred cur s =
      ((enterPhis pred s s b.phis).bind fun s₁ => (execBody mode f s₁ b.body).bind fun s₂ =>
        match b.term with
        | .ret a => a.exec s₂
        | .br target => f.execFrom mode fuel cur target s₂
        | .condBr cond ifTrue ifFalse =>
          (cond.execBool s₂).bind fun c =>
            f.execFrom mode fuel cur (if c then ifTrue else ifFalse) s₂
        | .unreachable => none) := by
  simp only [Func.execFrom, hb, Option.bind_eq_bind, Option.bind_some]
  rfl

/-- The interpreter's result at `x` when execution ends with a register known exactly. -/
theorem Func.runUnary_of_exec_exact {fmt : FloatFormat} {f : Func} {mode : IEEERoundingMode}
    {x y : Model fmt} (h : f.exec mode [.ofModel x] = some (.exact (.ofModel y))) :
    f.runUnary mode x = some y := by
  simp only [runUnary, runFloat, h, Val.toModel?_ofModel]

/-- The interpreter's result at `x` when execution ends with the result of an arithmetic
instruction for which FloatLib computes `y`. -/
theorem Func.runUnary_of_exec_ofFloat {fmt : FloatFormat} {f : Func} {mode : IEEERoundingMode}
    {x y : Model fmt} (h : f.exec mode [.ofModel x] = some (.ofFloat y)) :
    f.runUnary mode x = some y := by
  unfold AbsVal.ofFloat at h
  split at h <;> simp only [runUnary, runFloat, h, Val.toModel?_ofModel, ↓reduceDIte]

/-! ## Floating-point registers

An arithmetic instruction stores `AbsVal.ofFloat z`, and the next instruction that needs the value
of that register continues only if `z` is not a NaN. `nonNaN` states that condition, and
`Operand.execFloat_eq` with `AbsVal.toModel?_ofFloat` reads a floating-point operand in terms of
it. A structured form of a function mirrors an arithmetic result that is used later by
`nonNaN z >>= …`; `nonNaN_bind_congr` then treats both sides at once. -/

/-- `z`, unless it is a NaN. The interpreter gives up when a NaN produced by arithmetic is the
operand of an instruction that needs its value. -/
def nonNaN {fmt : FloatFormat} (z : Model fmt) : Option (Model fmt) :=
  if z.isNaN then none else some z

theorem nonNaN_of_isNaN_eq_false {fmt : FloatFormat} {z : Model fmt} (h : z.isNaN = false) :
    nonNaN z = some z := by
  simp [nonNaN, h]

theorem nonNaN_of_isNaN {fmt : FloatFormat} {z : Model fmt} (h : z.isNaN = true) :
    nonNaN z = none := by
  simp [nonNaN, h]

/-- Two computations that continue from the same arithmetic result agree if they agree when it
is not a NaN. The second continuation is given as a variable `r`, so that a tactic applied to the
goal `f z = r` works on the first one only. -/
theorem nonNaN_bind_congr {fmt : FloatFormat} {β : Type} {z : Model fmt}
    {f g : Model fmt → Option β} (h : z.isNaN = false → ∀ r, g z = r → f z = r) :
    (nonNaN z).bind f = (nonNaN z).bind g := by
  cases hz : z.isNaN
  · rw [nonNaN_of_isNaN_eq_false hz, Option.bind_some, Option.bind_some, h hz _ rfl]
  · rw [nonNaN_of_isNaN hz, Option.bind_none, Option.bind_none]

/-- Two computations that continue from the same optional value agree if their continuations
do; the second continuation is a variable as in `nonNaN_bind_congr`. -/
theorem bind_congr_of_forall {α β : Type} {o : Option α} {f g : α → Option β}
    (h : ∀ a r, g a = r → f a = r) : o.bind f = o.bind g :=
  congrArg o.bind (funext fun a => h a _ rfl)

/-- The floating-point value of a register, if it is known exactly. -/
def AbsVal.toModel? (fmt : FloatFormat) : AbsVal → Option (Model fmt)
  | .exact v => v.toModel? fmt
  | _ => none

theorem AbsVal.toModel?_exact (fmt : FloatFormat) (v : Val) :
    (AbsVal.exact v).toModel? fmt = v.toModel? fmt :=
  rfl

theorem AbsVal.toModel?_ofFloat {fmt : FloatFormat} (z : Model fmt) :
    (AbsVal.ofFloat z).toModel? fmt = nonNaN z := by
  unfold AbsVal.ofFloat nonNaN
  split
  · rfl
  · exact Val.toModel?_ofModel z

theorem Operand.execFloat_eq (fmt : FloatFormat) (s : Store) (a : Operand) :
    a.execFloat fmt s = (a.exec s).bind (AbsVal.toModel? fmt) := by
  unfold Operand.execFloat Operand.execExact
  rcases a.exec s with _ | v
  · rfl
  · cases v <;> rfl

theorem Val.toModel?_binary64 (bits : BitVec 64) :
    Val.toModel? .binary64 ⟨64, bits⟩ = some (.ofBits bits) :=
  rfl

/-- The outcome of an ordered comparison in terms of the IEEE ordering. -/
theorem FCmp.eval_olt (o : Option Ordering) : FCmp.olt.eval o = (o == some .lt) :=
  rfl

theorem FCmp.eval_ogt (o : Option Ordering) : FCmp.ogt.eval o = (o == some .gt) :=
  rfl

/-- `fptosi`: the integer part of `x` as a signed integer of the given width, if it is one. -/
def fptosi? {fmt : FloatFormat} (width : ℕ) (x : Model fmt) : Option (BitVec width) :=
  match ExecDType.convertToInteger (width := width) x .towardZero with
  | .success n _ => some n.bits
  | .failure _ => none

theorem Instr.exec_fptosi (mode : IEEERoundingMode) (f : Func) (s : Store) (src : FloatFormat)
    (width : ℕ) (a : Operand) :
    Instr.exec mode f s (.fptosi src width a) =
      (a.execFloat src s).bind fun x => (fptosi? width x).bind fun n =>
        some (.exact ⟨width, n⟩) := by
  simp only [Instr.exec, fptosi?, Option.bind_eq_bind]
  congr 1
  funext x
  split <;> simp_all

/-- `add` without flags always has a result. -/
theorem IntBinOp.defined_add {w : ℕ} (a b : BitVec w) : IntBinOp.add.defined { } a b = true := by
  simp [defined, Flags.noWrap]

/-- A shift without flags has a result when the amount is less than the width. -/
theorem IntBinOp.defined_ashr {w : ℕ} (a b : BitVec w) (h : b.toNat < w) :
    IntBinOp.ashr.defined { } a b = true := by
  simp [defined, h]

/-- `zext nneg` has a result on an operand whose sign bit is clear. -/
theorem Flags.zextDefined_nneg {w : ℕ} (a : BitVec w) (h : a.msb = false) :
    Flags.zextDefined { nneg := true } a = true := by
  simp [Flags.zextDefined, h]

/-! ## One instruction at a time

Simplifying `execBody` on a whole block unfolds every instruction under the binders of those
before it, and takes time exponential in the length of the block when their results are not
known to exist. `execBody_cons` exposes one instruction instead. -/

theorem execBody_cons (mode : IEEERoundingMode) (f : Func) (s : Store) (r : Reg) (i : Instr)
    (rest : List (Reg × Instr)) :
    execBody mode f s ((r, i) :: rest) =
      (i.exec mode f s).bind fun a => execBody mode f (s.set r a) rest :=
  rfl

/-- `Option.bind_eq_bind` as a rewrite rule with a proof term. The core lemma holds by `rfl`, so
`simp` applies it without recording a step, and the kernel is then left to compare the monadic
and the plain form of a whole block by unfolding both. -/
theorem bind_eq_optionBind {α β : Type} (o : Option α) (f : α → Option β) :
    o >>= f = o.bind f := by
  cases o <;> rfl

theorem execBody_nil (mode : IEEERoundingMode) (f : Func) (s : Store) :
    execBody mode f s [] = some s :=
  rfl

/-- The floating-point value the interpreter reports for a returned register. -/
def AbsVal.result? (fmt : FloatFormat) : AbsVal → Option (Model fmt)
  | .exact v => v.toModel? fmt
  | .nan fmt' x _ => if h : fmt' = fmt then some (h ▸ x) else none
  | .any _ => none

theorem AbsVal.result?_ofFloat {fmt : FloatFormat} (z : Model fmt) :
    (AbsVal.ofFloat z).result? fmt = some z := by
  unfold AbsVal.ofFloat
  split
  · simp only [result?, ↓reduceDIte]
  · exact Val.toModel?_ofModel z

theorem Func.runUnary_eq_bind {fmt : FloatFormat} (f : Func) (mode : IEEERoundingMode)
    (x : Model fmt) :
    f.runUnary mode x = (f.exec mode [.ofModel x]).bind (AbsVal.result? fmt) := by
  unfold runUnary runFloat
  rcases f.exec mode [.ofModel x] with _ | v
  · rfl
  · cases v <;> rfl

/-- Evaluate `Func.exec` block by block. The arguments are the block lemmas of the function
(`Func.execFrom_of_block hblock`), the number of its blocks, and the facts that decide its branch
and flag conditions. Evaluation stops at the first condition they do not decide. -/
macro "exec_blocks" "[" lemmas:Lean.Parser.Tactic.simpLemma,* "]" : tactic =>
  `(tactic| simp only [Func.exec, enterPhis, execBody, Instr.exec, CoreOp.exec, roundingConstant,
    IntBinOp.eval, Operand.exec, Operand.execExact, Operand.execBool, Operand.execFloat,
    Store.get_set, Store.get_ofArgs, Val.ofModel_binary32, Val.toModel?_binary32,
    Val.toBits_ofBits_binary32, Val.toBits_abs_binary32, Val.ofNat, Val.toBool?_ofBool,
    Flags.icmpDefined_default, IntBinOp.defined_and, FastMathFlags.admits_default,
    Option.bind_some, Option.bind_eq_bind, Option.pure_def, Option.map_some,
    List.getElem?_cons_zero, List.lookup, BitVec.cast_eq, ↓reduceDIte, ↓reduceIte,
    Nat.reduceEqDiff, Nat.reduceBEq, reduceCtorEq, decide_true, decide_false, Bool.false_eq_true,
    Bool.not_false, Bool.and_self, or_self, or_true, true_or, $lemmas,*])

end LibcMath.IR
