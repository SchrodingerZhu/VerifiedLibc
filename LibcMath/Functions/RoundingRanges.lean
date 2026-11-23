import LibcMath.Spec
import FloatLib.Floats.Formats.BinaryInterchange.Algebraic.Rounding.DirectedEnclosureProof

/-!
# Ranges of reals with a constant rounding

`Model.roundReal fmt mode` is constant on three kinds of ranges, which is what lets a whole range
of arguments of a function be treated at once:

* between two rationals of the same sign that round alike (`roundReal_eq_of_mem_Icc_rat`), where
  the common value is computed by the executable `AlgebraicRounding.roundRat`;
* from the first power of two beyond the finite range upwards (`roundReal_of_two_zpow_le`);
* strictly between zero and half the least subnormal (`roundReal_of_lt_two_zpow`,
  `roundReal_of_le_two_zpow_mul`).
-/

namespace LibcMath

open FloatLib.Floats.Formats.BinaryInterchange FloatLib.Floats.Formats
open Model (IEEERoundingMode roundReal)
open Model.AlgebraicRounding

variable {fmt : FloatFormat}

/-- A real enclosed by two positive rationals that both round to `result` rounds to `result`. -/
theorem roundReal_eq_of_mem_Icc_rat (hfmt : fmt.isIEEE = true) (mode : IEEERoundingMode)
    {lo hi : ℚ} {y : ℝ} {result : Model fmt} (hpos : 0 < lo) (hlo : (lo : ℝ) ≤ y)
    (hhi : y ≤ (hi : ℝ)) (hroundLo : roundRat fmt mode lo = result)
    (hroundHi : roundRat fmt mode hi = result) : roundReal fmt mode y = result := by
  rw [roundRat_eq_roundReal] at hroundLo hroundHi
  rw [Model.roundReal_eq_of_mem_Icc hfmt mode hlo hhi (Or.inl (by exact_mod_cast hpos))
    (hroundLo.trans hroundHi.symm), hroundLo]

/-- A positive real is rounded by `roundMagnitude` on its own comparisons. -/
private theorem roundReal_of_pos (mode : IEEERoundingMode) {y : ℝ} (hy : 0 < y) :
    roundReal fmt mode y =
      roundMagnitude fmt mode false (fun boundary : ℚ => cmp y (boundary : ℝ)) := by
  have hcmp : cmp y ((0 : ℚ) : ℝ) = .gt := (cmp_eq_gt_iff _ _).mpr (by simpa using hy)
  simp only [roundReal, roundSigned, hcmp]

/-- A real at least `2 ^ (emax + 1)` rounds to the overflow result of the direction: the infinity
when the direction rounds a positive value up, and the largest finite value otherwise. -/
theorem roundReal_of_two_zpow_le (mode : IEEERoundingMode) {y : ℝ}
    (hy : (2 : ℝ) ^ (fmt.maxNormalExponent + 1) ≤ y) :
    roundReal fmt mode y =
      Model.directedOverflow fmt false (mode.overflowRoundsMagnitudeUp false) := by
  rw [roundReal_of_pos mode (lt_of_lt_of_le (by positivity) hy),
    roundMagnitude_eq fmt mode false (fun _ => rfl), ite_eq_left]
  rw [cast_powerOfTwo, Flocq.bpow_binaryRadix, upperExponent, ne_eq, cmp_eq_lt_iff]
  exact not_lt.mpr hy

/-- A positive real below half the least subnormal rounds like every other such real: to the
least subnormal when the direction rounds a positive value up, and to `+0` otherwise. -/
theorem roundReal_of_lt_two_zpow (mode : IEEERoundingMode) {y : ℝ} (hpos : 0 < y)
    (hy : y < (2 : ℝ) ^ (fmt.minSubnormalExponent - 1)) :
    roundReal fmt mode y = roundLocated fmt mode false 0 fmt.minSubnormalExponent false true := by
  have hupper : y < (2 : ℝ) ^ (fmt.maxNormalExponent + 1) :=
    hy.trans (zpow_lt_zpow_right₀ (by norm_num) (lowerExponent_lt_upperExponent fmt))
  rw [roundReal_of_pos mode hpos, roundMagnitude_eq fmt mode false (fun _ => rfl), ite_eq_right,
    ite_eq_left]
  · rwa [cast_powerOfTwo, Flocq.bpow_binaryRadix, lowerExponent, cmp_eq_lt_iff]
  · rwa [cast_powerOfTwo, Flocq.bpow_binaryRadix, upperExponent, ne_eq, cmp_eq_lt_iff, not_not]

/-- `roundReal_of_lt_two_zpow` for a real bounded by a proper fraction of half the least
subnormal. -/
theorem roundReal_of_le_two_zpow_mul (mode : IEEERoundingMode) {y r : ℝ} (hpos : 0 < y)
    (hr : r < 1) (hy : y ≤ (2 : ℝ) ^ (fmt.minSubnormalExponent - 1) * r) :
    roundReal fmt mode y = roundLocated fmt mode false 0 fmt.minSubnormalExponent false true :=
  roundReal_of_lt_two_zpow mode hpos (hy.trans_lt (mul_lt_of_lt_one_right (by positivity) hr))

end LibcMath
