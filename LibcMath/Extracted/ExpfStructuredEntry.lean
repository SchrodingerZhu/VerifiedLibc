import LibcMath.Extracted.ExpfStructuredCheck

/-!
# The way to the main computation of `expf`

Two facts about the blocks of the extracted `expf` that precede block 15, with the argument kept
symbolic as in `ExpfPaths/Exec.lean`:

* `exec_reaches_block15`: on the two main ranges, except at `0xC236BD8C`, the integer comparisons
  of blocks 0, 2, 3, 5 and 10 send the argument to block 15 with register 0 unchanged. Block 2
  branches there directly unless the pattern is at least `0xC2B20000`.
* `runUnary_special`: the result at `0xC236BD8C` (blocks 0, 1 and 21).
-/

namespace LibcMath.Extracted

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open IR

variable {mode : IEEERoundingMode}

/-- The binary32 value with bit pattern `b`. -/
local notation "f32(" b ")" => (Model.ofBits b : Model FloatFormat.binary32)

private theorem size_blocks : expf.blocks.size = 22 := rfl

private theorem block0 : expf.blocks[0]? = some
    ⟨[], [(1, .bitcast (.reg 0)), (2, .icmp .eq (.reg 1) (.const 32 0xC236BD8C))],
      .condBr (.reg 2) 1 2⟩ := rfl

private theorem block1 : expf.blocks[1]? = some
    ⟨[], [(3, .fneg .binary32 (.reg 0)),
      (4, .fmuladd .binary32 (.reg 3) (.const 32 0x10000000) (.const 32 0x1E88452C))],
      .br 21⟩ := rfl

private theorem block2 : expf.blocks[2]? = some
    ⟨[], [(5, .fabs .binary32 (.reg 0)), (6, .bitcast (.reg 5)),
      (7, .intBin .add (.reg 6) (.const 32 0xBD4E0000) { nsw := true }),
      (8, .icmp .ult (.reg 7) (.const 32 0xEFCE0001))], .condBr (.reg 8) 3 15⟩ := rfl

private theorem block3 : expf.blocks[3]? = some
    ⟨[], [(9, .intBin .and (.reg 1) (.const 32 0x7F000000)),
      (10, .icmp .ult (.reg 9) (.const 32 0x33000000) { samesign := true })],
      .condBr (.reg 10) 4 5⟩ := rfl

private theorem block5 : expf.blocks[5]? = some
    ⟨[], [(12, .icmp .ugt (.reg 1) (.const 32 0xC2CFF1B4))], .condBr (.reg 12) 6 10⟩ := rfl

private theorem block10 : expf.blocks[10]? = some
    ⟨[], [(18, .icmp .sgt (.reg 1) (.const 32 0x42B1FFFF))], .condBr (.reg 18) 11 15⟩ := rfl

private theorem block21 : expf.blocks[21]? = some
    ⟨[(63, [(1, .reg 4), (4, .reg 11), (20, .reg 62), (6, .const 32 0x0), (7, .reg 0),
      (9, .const 32 0x0), (14, .reg 25), (8, .const 32 0x1), (12, .const 32 0x7F7FFFFF)])], [],
      .ret (.reg 63)⟩ := rfl

private theorem and_abs_mask (n : ℕ) : n &&& 0x7FFFFFFF = n % 2 ^ 31 :=
  Nat.and_two_pow_sub_one_eq_mod n 31

private theorem and_exponent_mask (n : ℕ) : n &&& 0x7F000000 = n / 2 ^ 24 % 2 ^ 7 * 2 ^ 24 :=
  and_shiftLeft_mask n 7 24

/-- Prove the value of an integer comparison or a flag condition on the pattern `b` from
hypotheses about `b.toNat`. -/
local macro "bv_fact" b:ident : tactic =>
  `(tactic| (
    have := BitVec.isLt $b
    simp only [InExpfMainRanges, ICmp.eval_eq, ICmp.eval_ult, ICmp.eval_ugt, ICmp.eval_sgt,
      IntBinOp.defined_add_nsw, Flags.icmpDefined_samesign, toInt_eq_toNat_sub, BitVec.toNat_and,
      BitVec.toNat_ofNat, and_abs_mask, and_exponent_mask, decide_eq_true_eq,
      decide_eq_false_iff_not, Nat.reducePow, Nat.reduceMod] at *
    omega))

/-- On the main ranges, except at `0xC236BD8C`, execution reaches block 15 with the argument in
register 0 and enough fuel for the rest of the function. -/
theorem exec_reaches_block15 (b : BitVec 32) (hb : InExpfMainRanges b.toNat)
    (hs : b.toNat ≠ 0xC236BD8C) :
    ∃ fuel pred s, expf.exec mode [.ofModel f32(b)] = expf.execFrom mode (fuel + 6) pred 15 s ∧
      s.get 0 = some (.exact (.ofModel f32(b))) := by
  have hlt := b.isLt
  have h2 : ICmp.eval b 0xC236BD8C#32 .eq = false := by bv_fact b
  have h7 : IntBinOp.add.defined { nsw := true } (b &&& 0x7FFFFFFF#32) 0xBD4E0000#32 = true := by
    bv_fact b
  by_cases hdirect : b.toNat % 2 ^ 31 < 0x42B20000
  · -- Block 2 branches to block 15.
    have h8 : ICmp.eval ((b &&& 0x7FFFFFFF#32) + 0xBD4E0000#32) 0xEFCE0001#32 .ult = false := by
      rw [ICmp.eval_ult, decide_eq_false_iff_not, BitVec.toNat_add, BitVec.toNat_and]
      simp only [InExpfMainRanges, BitVec.toNat_ofNat, and_abs_mask, Nat.reducePow,
        Nat.reduceMod] at hb hdirect ⊢
      rw [Nat.mod_eq_of_lt (by omega)]
      omega
    exec_blocks [size_blocks, Func.execFrom_of_block block0, Func.execFrom_of_block block2, h2,
      h7, h8]
    exact ⟨14, 2, _, rfl, by simp only [Store.get_set, Store.get_ofArgs, Nat.reduceEqDiff,
      ↓reduceIte, List.getElem?_cons_zero, Option.map_some]⟩
  · -- Block 2 branches to block 3, and blocks 3, 5 and 10 lead to block 15.
    have h8 : ICmp.eval ((b &&& 0x7FFFFFFF#32) + 0xBD4E0000#32) 0xEFCE0001#32 .ult = true := by
      rw [ICmp.eval_ult, decide_eq_true_eq, BitVec.toNat_add, BitVec.toNat_and]
      simp only [InExpfMainRanges, BitVec.toNat_ofNat, and_abs_mask, Nat.reducePow,
        Nat.reduceMod] at hb hdirect ⊢
      have hmod : b.toNat % 2147483648 < 2147483648 := Nat.mod_lt _ (by norm_num)
      rw [Nat.mod_eq_sub_mod (by omega), Nat.mod_eq_of_lt (by omega)]
      omega
    have hrange : 0xC2B20000 ≤ b.toNat ∧ b.toNat < 0xC2CFF1B5 := by
      simp only [InExpfMainRanges] at hb
      omega
    have h10d : Flags.icmpDefined { samesign := true } (b &&& 0x7F000000#32) 0x33000000#32 =
        true := by bv_fact b
    have h10 : ICmp.eval (b &&& 0x7F000000#32) 0x33000000#32 .ult = false := by bv_fact b
    have h12 : ICmp.eval b 0xC2CFF1B4#32 .ugt = false := by bv_fact b
    have h18 : ICmp.eval b 0x42B1FFFF#32 .sgt = false := by bv_fact b
    exec_blocks [size_blocks, Func.execFrom_of_block block0, Func.execFrom_of_block block2,
      Func.execFrom_of_block block3, Func.execFrom_of_block block5,
      Func.execFrom_of_block block10, h2, h7, h8, h10d, h10, h12, h18]
    exact ⟨11, 10, _, rfl, by simp only [Store.get_set, Store.get_ofArgs, Nat.reduceEqDiff,
      ↓reduceIte, List.getElem?_cons_zero, Option.map_some]⟩

/-- The result at `0xC236BD8C` is `fmuladd(-x, 0x1p-95f, c)` (block 1). -/
theorem runUnary_special :
    expf.runUnary mode f32(0xC236BD8C#32) = some (expfSpecial mode) := by
  refine Func.runUnary_of_exec_ofFloat ?_
  have h2 : ICmp.eval 0xC236BD8C#32 0xC236BD8C#32 .eq = true := rfl
  have h3 : Val.toModel? .binary32 ⟨32, f32(0xC236BD8C#32).neg.toBits⟩ =
      some f32(0xC236BD8C#32).neg := Val.toModel?_ofModel _
  exec_blocks [size_blocks, Func.execFrom_of_block block0, Func.execFrom_of_block block1,
    Func.execFrom_of_block block21, h2, h3]
  rfl

end LibcMath.Extracted
