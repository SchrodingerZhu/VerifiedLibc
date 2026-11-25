import LibcMath.Kernels.Expf.Proof.StaticRounding.ShortPaths.Ranges
import LibcMath.Kernels.Expf.Statement

/-!
# `math::static_rounding::expf`: short paths proved, main path not

**Not complete.** The short paths are proved (87.69 % of the bit patterns). Nothing is proved
about the two ranges that reach the polynomial. They are the open lemma
`expfStaticRounding_mainRangesChecked`, and `expfStaticRounding_correctlyRounded` uses it.
-/

namespace LibcMath.Kernels.Expf.Proof.StaticRounding

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

variable {mode : IEEERoundingMode}

/-- Under `mode`, the pure-integer kernel `Generated.StaticRounding.kernel` is correct on both main
polynomial ranges (`528 573 389` inputs). -/
def ExpfStaticRoundingMainRangesChecked (mode : IEEERoundingMode) : Prop :=
  HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.StaticRounding.kernel mode)
    0x33000000 0x42B17218 ∧
  HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.StaticRounding.kernel mode)
    0xB3000000 0xC2CFF1B5

/-- `Generated.StaticRounding.kernel` is correctly rounded in all four C rounding directions,
provided it is on its two polynomial ranges. -/
theorem expfStaticRoundingCorrectlyRounded_of_mainRanges
    (h : ∀ mode ∈ cModes, ExpfStaticRoundingMainRangesChecked mode) :
    ExpfStaticRoundingCorrectlyRounded := by
  refine correctlyRounded_of_holdsOnBits fun mode hmode => ?_
  obtain ⟨low, middle, high⟩ := ShortPaths.holdsOnBits_short_paths_staticRounding hmode
  obtain ⟨positive, negative⟩ := h mode hmode
  exact (((low.append positive).append middle).append negative).append high

/-- **Open.** Prove that `Generated.StaticRounding.kernel` is correct on both main polynomial
ranges in each C rounding direction. A proof bounds the error of the `Frac64` polynomial and
clears the rounding boundaries with TMD certificates. -/
theorem expfStaticRounding_mainRangesChecked (hmode : mode ∈ cModes) :
    ExpfStaticRoundingMainRangesChecked mode := by
  sorry

/-- `math::static_rounding::expf` is correctly rounded in the four rounding directions of C. -/
theorem expfStaticRounding_correctlyRounded : ExpfStaticRoundingCorrectlyRounded :=
  expfStaticRoundingCorrectlyRounded_of_mainRanges fun _ => expfStaticRounding_mainRangesChecked

/--
info: 'LibcMath.Kernels.Expf.Proof.StaticRounding.expfStaticRoundingCorrectlyRounded_of_mainRanges' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms expfStaticRoundingCorrectlyRounded_of_mainRanges

/--
info: 'LibcMath.Kernels.Expf.Proof.StaticRounding.expfStaticRounding_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms expfStaticRounding_correctlyRounded

end LibcMath.Kernels.Expf.Proof.StaticRounding
