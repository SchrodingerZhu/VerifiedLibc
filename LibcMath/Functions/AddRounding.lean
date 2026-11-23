import LibcMath.Functions.Binary32Bits
import LibcMath.Functions.RoundingRanges
import FloatLib.Floats.Formats.BinaryInterchange.DirectedSemantics.Rounded

/-!
# Addition as a rounding of the exact sum

`Model.add x y mode` is `Model.roundReal` of the real sum when the operands are finite, the sum
is within the finite range and the result is not a zero (`add_eq_roundReal`). With
`roundReal_eq_of_mem_Icc_rat` this evaluates an addition whose exact sum is only known to lie
between two rationals, which is how `x + 1` is evaluated for all binary32 `x` of small magnitude
at once (`add_one_of_tiny_pos_bits`, `add_one_of_tiny_neg_bits`).
-/

namespace LibcMath

open FloatLib.Floats.Formats.BinaryInterchange Model
open Model.AlgebraicRounding (roundRat)

section
variable {fmt : FloatFormat} {x y : Model fmt}

/-- The sum of finite values is the rounding of their real sum, when the real sum is nonzero and
within the finite range and does not round to zero. -/
theorem add_eq_roundReal (hfmt : fmt.isIEEE = true) (mode : IEEERoundingMode)
    (hx : x.isFinite = true) (hy : y.isFinite = true)
    (hbound : |x.toReal + y.toReal| ≤ (posMaxFinite fmt).toReal)
    (hsum : x.toReal + y.toReal ≠ 0)
    (hround : (roundReal fmt mode (x.toReal + y.toReal)).toReal ≠ 0) :
    Model.add x y mode = roundReal fmt mode (x.toReal + y.toReal) := by
  obtain ⟨hfinite, hvalue⟩ := add_finite_roundAt hfmt hx hy hbound (mode := mode)
  obtain ⟨hfinite', hvalue'⟩ := (roundReal_roundsTo (fmt := fmt) mode hsum).finite
    (by rw [← hvalue]; exact abs_toReal_le_posMaxFinite_of_isFinite _ hfinite)
  exact eq_of_toReal_eq hfinite hfinite' (hvalue.trans hvalue'.symm)
    fun hzero => absurd (hvalue'.trans (hvalue.symm.trans hzero)) hround

end

variable {mode : IEEERoundingMode} {x : Model FloatFormat.binary32}

private theorem toReal_eq {y : Model FloatFormat.binary32} {q : ℚ} (h : toRat? y = some q) :
    y.toReal = q :=
  Algebraic.toReal_of_toRat?_eq_some h

/-- `x + 1` for finite `x` whose sum with `1` lies between two positive rationals at most `2`
that round alike. -/
private theorem add_one_eq (hfinite : x.isFinite = true) {lo hi : ℚ}
    {result : Model FloatFormat.binary32} (hpos : 0 < lo) (hlo : (lo : ℝ) ≤ x.toReal + 1)
    (hhi : x.toReal + 1 ≤ (hi : ℝ)) (hhi' : hi ≤ 2)
    (hroundLo : roundRat .binary32 mode lo = result)
    (hroundHi : roundRat .binary32 mode hi = result) (hresult : result.toReal ≠ 0) :
    Model.add x (posOne .binary32) mode = result := by
  have hone : (posOne FloatFormat.binary32).toReal = ((1 : ℚ) : ℝ) :=
    toReal_eq (by decide +kernel)
  have hmax : (posMaxFinite FloatFormat.binary32).toReal =
      ((340282346638528859811704183484516925440 : ℚ) : ℝ) := toReal_eq (by decide +kernel)
  push_cast at hone hmax
  have hlo' : (0 : ℝ) < lo := by exact_mod_cast hpos
  have hhi'' : (hi : ℝ) ≤ 2 := by exact_mod_cast hhi'
  have hround := roundReal_eq_of_mem_Icc_rat (fmt := .binary32) rfl mode hpos hlo hhi hroundLo
    hroundHi
  rw [← hone] at hround
  rw [add_eq_roundReal rfl mode hfinite (by decide +kernel)
    (by rw [hone, hmax, abs_of_pos (by linarith)]; linarith) (by rw [hone]; linarith)
    (by rw [hround]; exact hresult), hround]

/-- For `0 < x ≤ 2⁻²⁶` the sum `x + 1` is `1 + 2⁻²³` when rounding up, and `1` otherwise. -/
theorem add_one_of_tiny_pos_bits (hmode : mode ∈ cModes)
    (hbits : 0x00000001 ≤ x.toNatBits ∧ x.toNatBits ≤ 0x32800000) :
    Model.add x (posOne .binary32) mode =
      if mode = .up then ofNatBits 0x3F800001 else posOne .binary32 := by
  have hlo := (Binary32.toReal_ofNatBits_le_iff_of_nonneg (by norm_num) (by omega)).mpr hbits.1
  have hhi := (Binary32.toReal_le_ofNatBits_iff_of_nonneg (by norm_num) (by omega)).mpr hbits.2
  rw [toReal_eq (y := ofNatBits 0x00000001) (q := 1 / 2 ^ 149) (by decide +kernel)] at hlo
  rw [toReal_eq (y := ofNatBits 0x32800000) (q := 1 / 2 ^ 26) (by decide +kernel)] at hhi
  have hfinite : x.isFinite = true := Binary32.isFinite_iff.mpr (.inl (by omega))
  have hsucc : (ofNatBits 0x3F800001 : Model FloatFormat.binary32).toReal =
      ((1 + 1 / 2 ^ 23 : ℚ) : ℝ) := toReal_eq (by decide +kernel)
  have hone : (posOne FloatFormat.binary32).toReal = ((1 : ℚ) : ℝ) :=
    toReal_eq (by decide +kernel)
  rcases hmode with rfl | rfl | rfl | rfl <;>
    refine add_one_eq (lo := 1 + 1 / 2 ^ 149) (hi := 1 + 1 / 2 ^ 26) hfinite
      (by norm_num) (by push_cast at hlo ⊢; linarith) (by push_cast at hhi ⊢; linarith)
      (by norm_num) (by decide +kernel) (by decide +kernel) ?_ <;>
    simp only [reduceCtorEq, ↓reduceIte, hsucc, hone] <;> norm_num

/-- For `-2⁻²⁶ ≤ x < 0` the sum `x + 1` is `1 - 2⁻²⁴` when rounding toward zero or down, and `1`
otherwise. -/
theorem add_one_of_tiny_neg_bits (hmode : mode ∈ cModes)
    (hbits : 0x80000001 ≤ x.toNatBits ∧ x.toNatBits ≤ 0xB2800000) :
    Model.add x (posOne .binary32) mode =
      if mode = .towardZero ∨ mode = .down then ofNatBits 0x3F7FFFFF else posOne .binary32 := by
  have hhi := (Binary32.toReal_le_ofNatBits_iff_of_nonpos (by norm_num) (by omega)).mpr hbits.1
  have hlo := (Binary32.toReal_ofNatBits_le_iff_of_nonpos (by norm_num) (by omega)).mpr hbits.2
  rw [toReal_eq (y := ofNatBits 0x80000001) (q := -(1 / 2 ^ 149)) (by decide +kernel)] at hhi
  rw [toReal_eq (y := ofNatBits 0xB2800000) (q := -(1 / 2 ^ 26)) (by decide +kernel)] at hlo
  have hfinite : x.isFinite = true := Binary32.isFinite_iff.mpr (.inr (by omega))
  have hpred : (ofNatBits 0x3F7FFFFF : Model FloatFormat.binary32).toReal =
      ((1 - 1 / 2 ^ 24 : ℚ) : ℝ) := toReal_eq (by decide +kernel)
  have hone : (posOne FloatFormat.binary32).toReal = ((1 : ℚ) : ℝ) :=
    toReal_eq (by decide +kernel)
  rcases hmode with rfl | rfl | rfl | rfl <;>
    refine add_one_eq (lo := 1 - 1 / 2 ^ 26) (hi := 1 - 1 / 2 ^ 149) hfinite
      (by norm_num) (by push_cast at hlo ⊢; linarith) (by push_cast at hhi ⊢; linarith)
      (by norm_num) (by decide +kernel) (by decide +kernel) ?_ <;>
    simp only [reduceCtorEq, or_self, or_true, true_or, ↓reduceIte, hpred, hone] <;> norm_num

/-- `±0 + 1 = 1`. -/
theorem add_one_of_zero_bits (hmode : mode ∈ cModes)
    (hbits : x.toNatBits = 0 ∨ x.toNatBits = 0x80000000) :
    Model.add x (posOne .binary32) mode = posOne .binary32 := by
  rw [← ofNatBits_toNatBits x]
  rcases hbits with h | h <;> rw [h] <;> rcases hmode with rfl | rfl | rfl | rfl <;>
    decide +kernel

end LibcMath
