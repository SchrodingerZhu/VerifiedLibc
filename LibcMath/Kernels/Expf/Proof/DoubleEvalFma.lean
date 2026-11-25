import LibcMath.Kernels.Expf.Proof.DoubleEvalFma.ShortPaths.Ranges
import LibcMath.Kernels.Expf.Statement

/-!
# `math::double_eval::expf` with FMA: short paths proved, main path not

**Not complete.** The short paths are proved (87.30 % of the bit patterns). Nothing is proved
about the two ranges that reach the tables and the polynomial. They are the open lemma
`expfDoubleEvalFma_mainRangesChecked`, and `expfDoubleEvalFma_correctlyRounded` uses it.
-/

namespace LibcMath.Kernels.Expf.Proof.DoubleEvalFma

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

variable {mode : IEEERoundingMode}

/-- Under `mode`, `Generated.DoubleEvalFma.expf` is correct on both main polynomial ranges. -/
def ExpfDoubleEvalFmaMainRangesChecked (mode : IEEERoundingMode) : Prop :=
  HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEvalFma.expf mode)
    0x32800001 0x42B17218 ∧
  HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEvalFma.expf mode)
    0xB2800001 0xC2CFF1B5

/-- `Generated.DoubleEvalFma.expf` is correctly rounded in all four C rounding directions, provided
it is on its two polynomial ranges. -/
theorem expfDoubleEvalFmaCorrectlyRounded_of_mainRanges
    (h : ∀ mode ∈ cModes, ExpfDoubleEvalFmaMainRangesChecked mode) :
    ExpfDoubleEvalFmaCorrectlyRounded := by
  refine correctlyRounded_of_holdsOnBits fun mode hmode => ?_
  obtain ⟨low, middle, high⟩ := ShortPaths.holdsOnBits_short_paths_doubleEvalFma hmode
  obtain ⟨positive, negative⟩ := h mode hmode
  exact (((low.append positive).append middle).append negative).append high

/-- **Open.** Prove that `Generated.DoubleEvalFma.expf` is correct on both main polynomial ranges
in each C rounding direction. A proof follows `Proof.DoubleEval.MainPath` with the FMA error
bounds. -/
theorem expfDoubleEvalFma_mainRangesChecked (hmode : mode ∈ cModes) :
    ExpfDoubleEvalFmaMainRangesChecked mode := by
  sorry

/-- `math::double_eval::expf` compiled with `-mavx2 -mfma` is correctly rounded in the four
rounding directions of C. -/
theorem expfDoubleEvalFma_correctlyRounded : ExpfDoubleEvalFmaCorrectlyRounded :=
  expfDoubleEvalFmaCorrectlyRounded_of_mainRanges fun _ => expfDoubleEvalFma_mainRangesChecked

/--
info: 'LibcMath.Kernels.Expf.Proof.DoubleEvalFma.expfDoubleEvalFmaCorrectlyRounded_of_mainRanges' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms expfDoubleEvalFmaCorrectlyRounded_of_mainRanges

/--
info: 'LibcMath.Kernels.Expf.Proof.DoubleEvalFma.expfDoubleEvalFma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms expfDoubleEvalFma_correctlyRounded

end LibcMath.Kernels.Expf.Proof.DoubleEvalFma
