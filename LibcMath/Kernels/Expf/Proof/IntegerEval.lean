import LibcMath.Kernels.Expf.Proof.IntegerEval.ShortPaths.Ranges
import LibcMath.Kernels.Expf.Proof.StaticRounding
import LibcMath.Kernels.Expf.Statement

/-!
# `math::integer_eval::expf`: short paths proved, main path not

**Not complete.** In round to nearest this plan computes what `static_rounding` computes
(`ShortPaths.integerEval_eq_staticRounding_nearest`), so its short paths are proved, and it is
correctly rounded if `static_rounding` is (`expfIntegerEvalCorrectlyRounded_of_staticRounding`).
`expfIntegerEval_correctlyRounded` therefore depends on the open lemma
`StaticRounding.expfStaticRounding_mainRangesChecked`.
-/

namespace LibcMath.Kernels.Expf.Proof.IntegerEval

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

variable {mode : IEEERoundingMode}

/-- `Generated.IntegerEval.kernel` is correctly rounded in `.nearest` mode, provided it is on its
two polynomial ranges (`528 573 389` inputs). -/
theorem expfIntegerEvalCorrectlyRounded_of_mainRanges
    (hpos : HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.IntegerEval.kernel .nearest)
      0x33000000 0x42B17218)
    (hneg : HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.IntegerEval.kernel .nearest)
      0xB3000000 0xC2CFF1B5) :
    ExpfIntegerEvalCorrectlyRounded := by
  refine correctlyRounded_of_holdsOnBits fun mode hmode => ?_
  rcases hmode with rfl
  obtain ⟨low, middle, high⟩ := ShortPaths.holdsOnBits_short_paths_integerEval
  exact (((low.append hpos).append middle).append hneg).append high

/-- `ExpfStaticRoundingCorrectlyRounded` immediately implies `ExpfIntegerEvalCorrectlyRounded`. -/
theorem expfIntegerEvalCorrectlyRounded_of_staticRounding
    (h : ExpfStaticRoundingCorrectlyRounded) :
    ExpfIntegerEvalCorrectlyRounded := by
  intro mode hmode x
  rcases hmode with rfl
  obtain ⟨y, hy, hsame⟩ := h .nearest (by simp [cModes]) x
  exact ⟨y, by rw [ShortPaths.integerEval_eq_staticRounding_nearest]; exact hy, hsame⟩

/-- `math::integer_eval::expf` is correctly rounded in round to nearest. -/
theorem expfIntegerEval_correctlyRounded : ExpfIntegerEvalCorrectlyRounded :=
  expfIntegerEvalCorrectlyRounded_of_staticRounding
    StaticRounding.expfStaticRounding_correctlyRounded

/--
info: 'LibcMath.Kernels.Expf.Proof.IntegerEval.expfIntegerEvalCorrectlyRounded_of_mainRanges' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms expfIntegerEvalCorrectlyRounded_of_mainRanges

/--
info: 'LibcMath.Kernels.Expf.Proof.IntegerEval.expfIntegerEvalCorrectlyRounded_of_staticRounding' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms expfIntegerEvalCorrectlyRounded_of_staticRounding

/--
info: 'LibcMath.Kernels.Expf.Proof.IntegerEval.expfIntegerEval_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms expfIntegerEval_correctlyRounded

end LibcMath.Kernels.Expf.Proof.IntegerEval
