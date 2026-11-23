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
* `IntBinOp.defined_add_nsw` and `Flags.icmpDefined_samesign` state the flag conditions as
  bit-vector facts that `bv_decide` proves.
* `Func.runUnary_of_exec_exact` and `Func.runUnary_of_exec_ofFloat` read off the result of
  `Func.runUnary`.

The tactic `exec_blocks [h₁, h₂, …]` rewrites with all of these. The `hᵢ` are the block lemmas
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
    split <;> bv_decide
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

/-- `add nsw` has a result exactly when the signed addition does not overflow. -/
theorem IntBinOp.defined_add_nsw {w : ℕ} (a b : BitVec w) :
    IntBinOp.add.defined { nsw := true } a b = !a.saddOverflow b := by
  simp only [defined, Flags.noWrap, Bool.not_false, Bool.true_or, Bool.not_true, Bool.false_or,
    Bool.true_and, BitVec.saddOverflow]
  rw [Bool.eq_iff_iff]
  simp only [Bool.and_eq_true, decide_eq_true_eq, Bool.not_eq_true', Bool.or_eq_false_iff,
    decide_eq_false_iff_not, ge_iff_le, not_le, not_lt]
  constructor
  · rintro ⟨h₁, h₂⟩
    exact ⟨by exact_mod_cast h₂, by exact_mod_cast h₁⟩
  · rintro ⟨h₁, h₂⟩
    exact ⟨by exact_mod_cast h₂, by exact_mod_cast h₁⟩

/-- `and` always has a result. -/
theorem IntBinOp.defined_and {w : ℕ} (flags : Flags) (a b : BitVec w) :
    IntBinOp.and.defined flags a b = true :=
  rfl

/-- `icmp samesign` has a result exactly when the sign bits of its operands agree. -/
theorem Flags.icmpDefined_samesign {w : ℕ} (a b : BitVec w) :
    Flags.icmpDefined { samesign := true } a b = (a.msb == b.msb) :=
  rfl

/-- An `icmp` without flags always has a result. -/
@[simp]
theorem Flags.icmpDefined_default {w : ℕ} (a b : BitVec w) :
    Flags.icmpDefined { } a b = true :=
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
            f.execFrom mode fuel cur (if c then ifTrue else ifFalse) s₂) := by
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

/-- Evaluate `Func.exec` block by block. The arguments are the block lemmas of the function
(`Func.execFrom_of_block hblock`), the number of its blocks, and the facts that decide its branch
and flag conditions. Evaluation stops at the first condition they do not decide. -/
macro "exec_blocks" "[" lemmas:Lean.Parser.Tactic.simpLemma,* "]" : tactic =>
  `(tactic| simp only [Func.exec, enterPhis, execBody, Instr.exec, CoreOp.exec, roundingConstant,
    IntBinOp.eval, Bool.not_false, Operand.exec, Operand.execExact, Operand.execBool, Operand.execFloat, Store.get_set,
    Store.get_ofArgs, Val.ofModel_binary32, Val.toModel?_binary32, Val.toBits_ofBits_binary32,
    Val.toBits_abs_binary32, Val.ofNat, Val.toBool?_ofBool,
    Flags.icmpDefined_default, IntBinOp.defined_and, Option.bind_some, Option.bind_eq_bind, Option.pure_def,
    Option.map_some, List.getElem?_cons_zero, List.lookup, BitVec.cast_eq, ↓reduceDIte, ↓reduceIte,
    Nat.reduceEqDiff, Nat.reduceBEq, reduceCtorEq, decide_true, decide_false, Bool.false_eq_true,
    or_self, or_true, true_or,
    $lemmas,*])

end LibcMath.IR
