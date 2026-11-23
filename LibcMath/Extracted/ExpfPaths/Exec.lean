import LibcMath.Extracted.Expf
import LibcMath.Spec
import LibcMath.IR.InterpLemmas

/-!
# The short paths of `expf`

The interpreter's result on `expf` for the arguments that never reach the polynomial evaluation,
with the argument kept symbolic. Each theorem assumes a condition on the bit pattern of the
argument that decides every branch on one path through the function. The argument is
`Model.ofBits b` for a variable `b : BitVec 32`, and the conditions are on `b.toNat`:

* `exec_of_small`: `|x| ≤ 2⁻²⁶` (patterns up to `0x32800000` after clearing the sign), blocks
  0, 2, 3, 4, 21. The result is `x + 1`.
* `exec_of_large_neg`: finite `x` from `0xC2CFF1B5`, blocks 0, 2, 3, 5, 6, 7, 8, (9,) 21. The
  result is the least positive value when rounding up, and `+0` otherwise.
* `exec_of_negInf`: blocks 0, 2, 3, 5, 6, 21. The result is `+0`.
* `exec_of_neg_nan`: blocks 0, 2, 3, 5, 6, 7, 21. The result is `x`.
* `exec_of_large_pos`: finite `x` from `0x42B20000`, blocks 0, 2, 3, 5, 10, 11, 12, (13, 14,) 21.
  The result is the largest finite value when rounding down or toward zero, and `x + ∞` otherwise.
* `exec_of_posInf_or_pos_nan`: blocks 0, 2, 3, 5, 10, 11, 14, 21. The result is `x + ∞`.

All other arguments are sent to block 15, except `0xC236BD8C`, which has a block of its own.
-/

namespace LibcMath.Extracted.ExpfPaths

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open IR

/-! ## The blocks on the short paths -/

private theorem size_blocks : expf.blocks.size = 22 := rfl

private theorem block0 : expf.blocks[0]? = some
    ⟨[], [(1, .bitcast (.reg 0)), (2, .icmp .eq (.reg 1) (.const 32 0xC236BD8C))],
      .condBr (.reg 2) 1 2⟩ := rfl

private theorem block2 : expf.blocks[2]? = some
    ⟨[], [(5, .fabs .binary32 (.reg 0)), (6, .bitcast (.reg 5)),
      (7, .intBin .add (.reg 6) (.const 32 0xBD4E0000) { nsw := true }),
      (8, .icmp .ult (.reg 7) (.const 32 0xEFCE0001))], .condBr (.reg 8) 3 15⟩ := rfl

private theorem block3 : expf.blocks[3]? = some
    ⟨[], [(9, .intBin .and (.reg 1) (.const 32 0x7F000000)),
      (10, .icmp .ult (.reg 9) (.const 32 0x33000000) { samesign := true })],
      .condBr (.reg 10) 4 5⟩ := rfl

private theorem block4 : expf.blocks[4]? = some
    ⟨[], [(11, .fBin .binary32 .fadd (.reg 0) (.const 32 0x3F800000))], .br 21⟩ := rfl

private theorem block5 : expf.blocks[5]? = some
    ⟨[], [(12, .icmp .ugt (.reg 1) (.const 32 0xC2CFF1B4))], .condBr (.reg 12) 6 10⟩ := rfl

private theorem block6 : expf.blocks[6]? = some
    ⟨[], [(13, .icmp .eq (.reg 6) (.const 32 0x7F800000))], .condBr (.reg 13) 21 7⟩ := rfl

private theorem block7 : expf.blocks[7]? = some
    ⟨[], [(14, .icmp .ugt (.reg 6) (.const 32 0x7F800000) { samesign := true })],
      .condBr (.reg 14) 21 8⟩ := rfl

private theorem block8 : expf.blocks[8]? = some
    ⟨[], [(15, .call .isRoundUp [])], .condBr (.reg 15) 21 9⟩ := rfl

private theorem block9 : expf.blocks[9]? = some
    ⟨[], [(16, .call .setErrno [.const 32 0x22]), (17, .call .raiseExcept [.const 32 0x10])],
      .br 21⟩ := rfl

private theorem block10 : expf.blocks[10]? = some
    ⟨[], [(18, .icmp .sgt (.reg 1) (.const 32 0x42B1FFFF))], .condBr (.reg 18) 11 15⟩ := rfl

private theorem block11 : expf.blocks[11]? = some
    ⟨[], [(19, .icmp .ult (.reg 1) (.const 32 0x7F800000) { samesign := true })],
      .condBr (.reg 19) 12 14⟩ := rfl

private theorem block12 : expf.blocks[12]? = some
    ⟨[], [(20, .call .quickGetRound []), (21, .intBin .and (.reg 20) (.const 32 0xFFFFF7FF)),
      (22, .icmp .eq (.reg 21) (.const 32 0x400))], .condBr (.reg 22) 21 13⟩ := rfl

private theorem block13 : expf.blocks[13]? = some
    ⟨[], [(23, .call .setErrno [.const 32 0x22]), (24, .call .raiseExcept [.const 32 0x8])],
      .br 14⟩ := rfl

private theorem block14 : expf.blocks[14]? = some
    ⟨[], [(25, .fBin .binary32 .fadd (.reg 0) (.const 32 0x7F800000))], .br 21⟩ := rfl

private theorem block21 : expf.blocks[21]? = some
    ⟨[(63, [(1, .reg 4), (4, .reg 11), (20, .reg 62), (6, .const 32 0x0), (7, .reg 0),
      (9, .const 32 0x0), (14, .reg 25), (8, .const 32 0x1), (12, .const 32 0x7F7FFFFF)])], [],
      .ret (.reg 63)⟩ := rfl

/-- Evaluate `expf.exec` along the short paths, given the facts that decide the branches. -/
local macro "exec_expf" "[" lemmas:Lean.Parser.Tactic.simpLemma,* "]" : tactic =>
  `(tactic| exec_blocks [size_blocks, Func.execFrom_of_block block0, Func.execFrom_of_block block2,
    Func.execFrom_of_block block3, Func.execFrom_of_block block4, Func.execFrom_of_block block5,
    Func.execFrom_of_block block6, Func.execFrom_of_block block7, Func.execFrom_of_block block8,
    Func.execFrom_of_block block9, Func.execFrom_of_block block10,
    Func.execFrom_of_block block11, Func.execFrom_of_block block12,
    Func.execFrom_of_block block13, Func.execFrom_of_block block14,
    Func.execFrom_of_block block21, $lemmas,*])

/-! ## The paths -/

variable {mode : IEEERoundingMode} (b : BitVec 32)

/-- The binary32 value with bit pattern `b`. -/
local notation "f32(" b ")" => (Model.ofBits b : Model FloatFormat.binary32)

private theorem and_abs_mask (n : ℕ) : n &&& 0x7FFFFFFF = n % 2 ^ 31 :=
  Nat.and_two_pow_sub_one_eq_mod n 31

private theorem and_exponent_mask (n : ℕ) : n &&& 0x7F000000 = n / 2 ^ 24 % 2 ^ 7 * 2 ^ 24 :=
  and_shiftLeft_mask n 7 24

/-- Prove the value of an integer comparison or a flag condition on the pattern `b` from
hypotheses about `b.toNat`. -/
local macro "bv_fact" b:ident : tactic =>
  `(tactic| (
    have := BitVec.isLt $b
    simp only [ICmp.eval_eq, ICmp.eval_ult, ICmp.eval_ugt, ICmp.eval_sgt,
      IntBinOp.defined_add_nsw, Flags.icmpDefined_samesign, toInt_eq_toNat_sub, BitVec.toNat_and,
      BitVec.toNat_ofNat, and_abs_mask, and_exponent_mask, decide_eq_true_eq,
      decide_eq_false_iff_not, Nat.reducePow, Nat.reduceMod]
    omega))

/-- Block 2 sends the argument to block 3 when its pattern without the sign is at most
`0x32800000` or at least `0x42B20000`. -/
private theorem block2_facts
    (hb : b.toNat % 2 ^ 31 ≤ 0x32800000 ∨ 0x42B20000 ≤ b.toNat % 2 ^ 31) :
    ICmp.eval b 0xC236BD8C#32 .eq = false ∧
      IntBinOp.add.defined { nsw := true } (b &&& 0x7FFFFFFF#32) 0xBD4E0000#32 = true ∧
      ICmp.eval ((b &&& 0x7FFFFFFF#32) + 0xBD4E0000#32) 0xEFCE0001#32 .ult = true ∧
      Flags.icmpDefined { samesign := true } (b &&& 0x7F000000#32) 0x33000000#32 = true := by
  refine ⟨by bv_fact b, by bv_fact b, ?_, by bv_fact b⟩
  -- The sum wraps around exactly in the second case; `omega` alone is slow here.
  rw [ICmp.eval_ult, decide_eq_true_eq, BitVec.toNat_add, BitVec.toNat_and]
  simp only [BitVec.toNat_ofNat, and_abs_mask, Nat.reducePow, Nat.reduceMod] at hb ⊢
  have hlt : b.toNat % 2147483648 < 2147483648 := Nat.mod_lt _ (by norm_num)
  rcases hb with hb | hb
  · rw [Nat.mod_eq_of_lt (by omega)]
    omega
  · rw [Nat.mod_eq_sub_mod (by omega), Nat.mod_eq_of_lt (by omega)]
    omega

/-- For `|x| ≤ 2⁻²⁶`, zeros included, the code returns `x + 1`. -/
theorem exec_of_small (hb : b.toNat % 2 ^ 31 ≤ 0x32800000) :
    expf.exec mode [.ofModel f32(b)] =
      some (.ofFloat (Model.add f32(b) f32(0x3F800000#32) mode)) := by
  obtain ⟨h2, h7, h8, h10d⟩ := block2_facts b (.inl hb)
  have h10 : ICmp.eval (b &&& 0x7F000000#32) 0x33000000#32 .ult = true := by bv_fact b
  exec_expf [h2, h7, h8, h10d, h10]
  rfl

/-- The facts that send a pattern from `0xC2CFF1B5` to block 7. -/
private theorem block7_facts (hb : 0xC2CFF1B5 ≤ b.toNat) :
    ICmp.eval (b &&& 0x7F000000#32) 0x33000000#32 .ult = false ∧
      ICmp.eval b 0xC2CFF1B4#32 .ugt = true ∧
      Flags.icmpDefined { samesign := true } (b &&& 0x7FFFFFFF#32) 0x7F800000#32 = true := by
  refine ⟨?_, ?_, ?_⟩ <;> bv_fact b

/-- At `-∞` the code returns `+0`. -/
theorem exec_of_negInf :
    expf.exec mode [.ofModel (Model.negInf .binary32)] =
      some (.exact (.ofModel (Model.posZero .binary32))) := by
  have hb : (0xFF800000#32).toNat = 0xFF800000 := rfl
  obtain ⟨h2, h7, h8, h10d⟩ := block2_facts 0xFF800000#32 (.inr (by omega))
  obtain ⟨h10, h12, -⟩ := block7_facts 0xFF800000#32 (by omega)
  have h13 : ICmp.eval (0xFF800000#32 &&& 0x7FFFFFFF#32) 0x7F800000#32 .eq = true := rfl
  change expf.exec mode [.ofModel f32(0xFF800000#32)] = some (.exact (.ofModel f32(0x0#32)))
  exec_expf [h2, h7, h8, h10d, h10, h12, h13]

/-- A NaN with the sign bit set is returned unchanged. -/
theorem exec_of_neg_nan (hb : 0xFF800001 ≤ b.toNat) :
    expf.exec mode [.ofModel f32(b)] = some (.exact (.ofModel f32(b))) := by
  obtain ⟨h2, h7, h8, h10d⟩ := block2_facts b (.inr (by have := b.isLt; omega))
  obtain ⟨h10, h12, h14d⟩ := block7_facts b (by omega)
  have h13 : ICmp.eval (b &&& 0x7FFFFFFF#32) 0x7F800000#32 .eq = false := by bv_fact b
  have h14 : ICmp.eval (b &&& 0x7FFFFFFF#32) 0x7F800000#32 .ugt = true := by bv_fact b
  exec_expf [h2, h7, h8, h10d, h10, h12, h13, h14d, h14]

/-- From `0xC2CFF1B5` to the least finite value the code returns the least positive value when
rounding up, and `+0` otherwise. -/
theorem exec_of_large_neg (hmode : mode ∈ cModes) (hlo : 0xC2CFF1B5 ≤ b.toNat)
    (hhi : b.toNat ≤ 0xFF7FFFFF) :
    expf.exec mode [.ofModel f32(b)] =
      some (.exact (.ofModel
        (if mode = .up then Model.posMinSubnormal .binary32 else Model.posZero .binary32))) := by
  obtain ⟨h2, h7, h8, h10d⟩ := block2_facts b (.inr (by omega))
  obtain ⟨h10, h12, h14d⟩ := block7_facts b hlo
  have h13 : ICmp.eval (b &&& 0x7FFFFFFF#32) 0x7F800000#32 .eq = false := by bv_fact b
  have h14 : ICmp.eval (b &&& 0x7FFFFFFF#32) 0x7F800000#32 .ugt = false := by bv_fact b
  rcases hmode with rfl | rfl | rfl | rfl <;>
    exec_expf [h2, h7, h8, h10d, h10, h12, h13, h14d, h14] <;> rfl

/-- The facts that send a positive pattern from `0x42B20000` to block 11. -/
private theorem block11_facts (hlo : 0x42B20000 ≤ b.toNat) (hhi : b.toNat ≤ 0x7FFFFFFF) :
    ICmp.eval (b &&& 0x7F000000#32) 0x33000000#32 .ult = false ∧
      ICmp.eval b 0xC2CFF1B4#32 .ugt = false ∧ ICmp.eval b 0x42B1FFFF#32 .sgt = true ∧
      Flags.icmpDefined { samesign := true } b 0x7F800000#32 = true := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> bv_fact b

/-- From `0x42B20000` to the largest finite value the code returns the largest finite value when
rounding toward zero or down, and `x + ∞` otherwise. -/
theorem exec_of_large_pos (hmode : mode ∈ cModes) (hlo : 0x42B20000 ≤ b.toNat)
    (hhi : b.toNat ≤ 0x7F7FFFFF) :
    expf.exec mode [.ofModel f32(b)] =
      some (if mode = .towardZero ∨ mode = .down then
        .exact (.ofModel (Model.posMaxFinite .binary32))
      else .ofFloat (Model.add f32(b) (Model.posInf .binary32) mode)) := by
  obtain ⟨h2, h7, h8, h10d⟩ := block2_facts b (.inr (by omega))
  obtain ⟨h10, h12, h18, h19d⟩ := block11_facts b hlo (by omega)
  have h19 : ICmp.eval b 0x7F800000#32 .ult = true := by bv_fact b
  rcases hmode with rfl | rfl | rfl | rfl
  · have h22 : ICmp.eval (0x0#32 &&& 0xFFFFF7FF#32) 0x400#32 .eq = false := rfl
    exec_expf [h2, h7, h8, h10d, h10, h12, h18, h19d, h19, h22]
    rfl
  · have h22 : ICmp.eval (0xC00#32 &&& 0xFFFFF7FF#32) 0x400#32 .eq = true := rfl
    exec_expf [h2, h7, h8, h10d, h10, h12, h18, h19d, h19, h22]
    rfl
  · have h22 : ICmp.eval (0x800#32 &&& 0xFFFFF7FF#32) 0x400#32 .eq = false := rfl
    exec_expf [h2, h7, h8, h10d, h10, h12, h18, h19d, h19, h22]
    rfl
  · have h22 : ICmp.eval (0x400#32 &&& 0xFFFFF7FF#32) 0x400#32 .eq = true := rfl
    exec_expf [h2, h7, h8, h10d, h10, h12, h18, h19d, h19, h22]
    rfl

/-- At `+∞` and at a NaN with the sign bit clear the code returns `x + ∞`. -/
theorem exec_of_posInf_or_pos_nan (hlo : 0x7F800000 ≤ b.toNat) (hhi : b.toNat ≤ 0x7FFFFFFF) :
    expf.exec mode [.ofModel f32(b)] =
      some (.ofFloat (Model.add f32(b) (Model.posInf .binary32) mode)) := by
  obtain ⟨h2, h7, h8, h10d⟩ := block2_facts b (.inr (by omega))
  obtain ⟨h10, h12, h18, h19d⟩ := block11_facts b (by omega) hhi
  have h19 : ICmp.eval b 0x7F800000#32 .ult = false := by bv_fact b
  exec_expf [h2, h7, h8, h10d, h10, h12, h18, h19d, h19]
  rfl

end LibcMath.Extracted.ExpfPaths
