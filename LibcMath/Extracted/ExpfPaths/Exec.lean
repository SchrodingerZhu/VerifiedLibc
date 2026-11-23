import LibcMath.Extracted.Expf
import LibcMath.Spec
import LibcMath.IR.InterpLemmas

/-!
# The short paths of `expf`

The interpreter's result on `expf` for the arguments that never reach the polynomial evaluation,
with the argument kept symbolic. Each theorem assumes a condition on the bit pattern of the
argument that decides every branch on one path through the function:

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

/-- Prove the value of an integer comparison or a flag condition from bit-vector hypotheses. -/
local macro "bv_fact" : tactic =>
  `(tactic| (simp only [ICmp.eval, IntBinOp.defined_add_nsw, Flags.icmpDefined_samesign]; bv_decide))

/-- Block 2 sends the argument to block 3 when its pattern without the sign is at most
`0x32800000` or at least `0x42B20000`. -/
private theorem block2_facts
    (hb : b &&& 0x7FFFFFFF#32 ≤ 0x32800000#32 ∨ 0x42B20000#32 ≤ b &&& 0x7FFFFFFF#32) :
    ICmp.eval b 0xC236BD8C#32 .eq = false ∧
      IntBinOp.add.defined { nsw := true } (b &&& 0x7FFFFFFF#32) 0xBD4E0000#32 = true ∧
      ICmp.eval ((b &&& 0x7FFFFFFF#32) + 0xBD4E0000#32) 0xEFCE0001#32 .ult = true ∧
      Flags.icmpDefined { samesign := true } (b &&& 0x7F000000#32) 0x33000000#32 = true := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> bv_fact

theorem exec_of_small (hb : b &&& 0x7FFFFFFF#32 ≤ 0x32800000#32) :
    expf.exec mode [.ofModel f32(b)] =
      some (.ofFloat (Model.add f32(b) f32(0x3F800000#32) mode)) := by
  obtain ⟨h2, h7, h8, h10d⟩ := block2_facts b (.inl hb)
  have h10 : ICmp.eval (b &&& 0x7F000000#32) 0x33000000#32 .ult = true := by bv_fact
  exec_expf [h2, h7, h8, h10d, h10]
  rfl

private theorem exec_of_eq_negInf (hb : b = 0xFF800000#32) :
    expf.exec mode [.ofModel f32(b)] = some (.exact (.ofModel f32(0#32))) := by
  obtain ⟨h2, h7, h8, h10d⟩ := block2_facts b (.inr (by bv_decide))
  have h10 : ICmp.eval (b &&& 0x7F000000#32) 0x33000000#32 .ult = false := by bv_fact
  have h12 : ICmp.eval b 0xC2CFF1B4#32 .ugt = true := by bv_fact
  have h13 : ICmp.eval (b &&& 0x7FFFFFFF#32) 0x7F800000#32 .eq = true := by bv_fact
  exec_expf [h2, h7, h8, h10d, h10, h12, h13]

theorem exec_of_negInf :
    expf.exec mode [.ofModel (Model.negInf .binary32)] =
      some (.exact (.ofModel (Model.posZero .binary32))) :=
  exec_of_eq_negInf 0xFF800000#32 rfl

theorem exec_of_neg_nan (hb : 0xFF800001#32 ≤ b) :
    expf.exec mode [.ofModel f32(b)] =
      some (.exact (.ofModel f32(b))) := by
  obtain ⟨h2, h7, h8, h10d⟩ := block2_facts b (.inr (by bv_decide))
  have h10 : ICmp.eval (b &&& 0x7F000000#32) 0x33000000#32 .ult = false := by bv_fact
  have h12 : ICmp.eval b 0xC2CFF1B4#32 .ugt = true := by bv_fact
  have h13 : ICmp.eval (b &&& 0x7FFFFFFF#32) 0x7F800000#32 .eq = false := by bv_fact
  have h14d : Flags.icmpDefined { samesign := true } (b &&& 0x7FFFFFFF#32) 0x7F800000#32 = true := by
    bv_fact
  have h14 : ICmp.eval (b &&& 0x7FFFFFFF#32) 0x7F800000#32 .ugt = true := by bv_fact
  exec_expf [h2, h7, h8, h10d, h10, h12, h13, h14d, h14]

theorem exec_of_large_neg (hmode : mode ∈ cModes) (hlo : 0xC2CFF1B5#32 ≤ b)
    (hhi : b ≤ 0xFF7FFFFF#32) :
    expf.exec mode [.ofModel f32(b)] =
      some (.exact (.ofModel
        (if mode = .up then Model.posMinSubnormal .binary32 else Model.posZero .binary32))) := by
  obtain ⟨h2, h7, h8, h10d⟩ := block2_facts b (.inr (by bv_decide))
  have h10 : ICmp.eval (b &&& 0x7F000000#32) 0x33000000#32 .ult = false := by bv_fact
  have h12 : ICmp.eval b 0xC2CFF1B4#32 .ugt = true := by bv_fact
  have h13 : ICmp.eval (b &&& 0x7FFFFFFF#32) 0x7F800000#32 .eq = false := by bv_fact
  have h14d : Flags.icmpDefined { samesign := true } (b &&& 0x7FFFFFFF#32) 0x7F800000#32 = true := by
    bv_fact
  have h14 : ICmp.eval (b &&& 0x7FFFFFFF#32) 0x7F800000#32 .ugt = false := by bv_fact
  rcases hmode with rfl | rfl | rfl | rfl <;>
    exec_expf [h2, h7, h8, h10d, h10, h12, h13, h14d, h14] <;> rfl

/-- The facts that send a positive pattern from `0x42B20000` to block 11. -/
private theorem block11_facts (hlo : 0x42B20000#32 ≤ b) (hhi : b ≤ 0x7FFFFFFF#32) :
    ICmp.eval (b &&& 0x7F000000#32) 0x33000000#32 .ult = false ∧
      ICmp.eval b 0xC2CFF1B4#32 .ugt = false ∧ ICmp.eval b 0x42B1FFFF#32 .sgt = true ∧
      Flags.icmpDefined { samesign := true } b 0x7F800000#32 = true := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> bv_fact

theorem exec_of_large_pos (hmode : mode ∈ cModes) (hlo : 0x42B20000#32 ≤ b)
    (hhi : b ≤ 0x7F7FFFFF#32) :
    expf.exec mode [.ofModel f32(b)] =
      some (if mode = .towardZero ∨ mode = .down then
        .exact (.ofModel (Model.posMaxFinite .binary32))
      else .ofFloat (Model.add f32(b) (Model.posInf .binary32) mode)) := by
  obtain ⟨h2, h7, h8, h10d⟩ := block2_facts b (.inr (by bv_decide))
  obtain ⟨h10, h12, h18, h19d⟩ := block11_facts b hlo (by bv_decide)
  have h19 : ICmp.eval b 0x7F800000#32 .ult = true := by bv_fact
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

theorem exec_of_posInf_or_pos_nan (hlo : 0x7F800000#32 ≤ b) (hhi : b ≤ 0x7FFFFFFF#32) :
    expf.exec mode [.ofModel f32(b)] =
      some (.ofFloat (Model.add f32(b) (Model.posInf .binary32) mode)) := by
  obtain ⟨h2, h7, h8, h10d⟩ := block2_facts b (.inr (by bv_decide))
  obtain ⟨h10, h12, h18, h19d⟩ := block11_facts b (by bv_decide) hhi
  have h19 : ICmp.eval b 0x7F800000#32 .ult = false := by bv_fact
  exec_expf [h2, h7, h8, h10d, h10, h12, h18, h19d, h19]
  rfl

end LibcMath.Extracted.ExpfPaths
