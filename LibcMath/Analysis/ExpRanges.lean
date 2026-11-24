import LibcMath.Framework.Specs
import LibcMath.Analysis.Binary32Bits
import LibcMath.Analysis.RoundingRanges
import Mathlib.Analysis.Complex.ExponentialBounds

/-!
# Ranges of binary32 arguments on which correctly rounded `exp` has a closed form

On most binary32 arguments the correctly rounded value of `exp` in the rounding directions of C
does not depend on the argument beyond its sign. This file proves the value of
`(Spec.exp .binary32).eval mode x` for `mode ∈ cModes` on the following blocks of consecutive bit
patterns `x.toNatBits`, and under the corresponding conditions on the real value of `x`.

* NaNs, `0x7F800001`–`0x7FFFFFFF` and `0xFF800001`–`0xFFFFFFFF`: a NaN (`eval_of_nan_bits`).
* `±0`, `0x00000000` and `0x80000000`: `1` (`eval_of_zero_bits`).
* `+∞`, `0x7F800000`: `+∞` (`eval_of_posInf_bits`). `-∞`, `0xFF800000`: `+0`
  (`eval_of_negInf_bits`).
* `0 < x < 2⁻²⁴`, `0x00000001`–`0x337FFFFF`: `1 + 2⁻²³` when rounding up, and `1` otherwise
  (`eval_of_tiny_pos_bits`, `eval_of_tiny_pos`). When not rounding to nearest the same holds for
  `0 < x < 2⁻²³`, `0x00000001`–`0x33FFFFFF` (`eval_of_tiny_pos_bits_of_ne_nearest`).
* `-2⁻²⁵ ≤ x < 0`, `0x80000001`–`0xB3000000`: `1 - 2⁻²⁴` when rounding toward zero or down, and
  `1` otherwise (`eval_of_tiny_neg_bits`, `eval_of_tiny_neg`). When not rounding to nearest the
  same holds for `-2⁻²⁴ ≤ x < 0`, `0x80000001`–`0xB3800000`
  (`eval_of_tiny_neg_bits_of_ne_nearest`).
* `2¹²⁸ ≤ exp x`, `0x42B17218`–`0x7F7FFFFF`: the largest finite value when rounding toward zero
  or down, and `+∞` otherwise (`eval_of_overflow_bits`, `eval_of_two_pow_le_exp`).
* `exp x ≤ 2⁻¹⁵⁰`, `0xC2CFF1B5`–`0xFF7FFFFF`: the least positive value `2⁻¹⁴⁹` when rounding up,
  and `+0` otherwise (`eval_of_underflow_bits`, `eval_of_exp_le_two_pow`).
* `2⁻¹⁵⁰ < exp x < 2⁻¹⁴⁹`, `0xC2CE8ED0`–`0xC2CFF1B4`: `+0` when rounding toward zero or down,
  and `2⁻¹⁴⁹` otherwise (`eval_of_near_underflow_bits`, `eval_of_near_underflow`).

The blocks cannot be extended, although this file does not prove it: `exp (2⁻²⁴)` exceeds the
midpoint `1 + 2⁻²⁴` and `exp (2⁻²³)` exceeds `1 + 2⁻²³`, the patterns after `0xB3000000` and
`0xB3800000` denote arguments whose exponential is below `1 - 2⁻²⁵` and `1 - 2⁻²⁴`, the
exponential of `0x42B17217` is below the largest finite value, and the exponential of
`0xC2CE8ECF` is above `2⁻¹⁴⁹`.

`closedForm?` collects the blocks into one function of the bit pattern, and
`eval_eq_of_closedForm?` states that it returns the correctly rounded result.

`blocks mode` lists the same blocks as data, each with the name of its theorem
(`closedForm?_isSome_iff` ties the two together). From it, `blockOf? mode bits` answers which
theorem covers a bit pattern, `covered mode` counts the patterns that have a closed form, and
`uncovered mode` lists the ranges that are left for another method. Evaluate them with `#eval`;
`LibcMath/Analysis/ExpRangesExamples.lean` checks the counts.

The results are equalities of bit patterns, which give `SameValue` in either order.

The closed forms are found by evaluation: a real between two rationals that round alike rounds
like them (`roundReal_eq_of_mem_Icc_rat`), and the rounding of a rational is computed by
FloatLib's `AlgebraicRounding.roundRat`, which the kernel evaluates.
-/

namespace LibcMath.ExpRanges

open FloatLib.Floats.Formats.BinaryInterchange Model
open Model.AlgebraicRounding (roundRat roundLocated)

variable {mode : IEEERoundingMode} {x : Model FloatFormat.binary32}

/-- `exp` is positive, so rounding it toward zero and rounding it down prescribe the same
results, in every format. -/
theorem _root_.LibcMath.Spec.exp_eval_towardZero (fmt : FloatFormat) (x : Model fmt) :
    (Spec.exp fmt).eval .towardZero x = (Spec.exp fmt).eval .down x := by
  simp only [Spec.eval, Spec.exp, Option.getD_none,
    roundReal_towardZero_of_pos fmt (Real.exp_pos _)]

/-! ## Exceptional arguments -/

/-- `exp` of a NaN is the canonical NaN. -/
theorem eval_of_isNaN (hx : x.isNaN = true) :
    (Spec.exp .binary32).eval mode x = canonicalNaN .binary32 := by
  simp [Spec.eval, hx]

/-- `exp` of a NaN, as blocks of bit patterns. -/
theorem eval_of_nan_bits
    (hbits : (0x7F800001 ≤ x.toNatBits ∧ x.toNatBits ≤ 0x7FFFFFFF) ∨
      (0xFF800001 ≤ x.toNatBits ∧ x.toNatBits ≤ 0xFFFFFFFF)) :
    (Spec.exp .binary32).eval mode x = canonicalNaN .binary32 :=
  eval_of_isNaN (Binary32.isNaN_iff.mpr (by omega))

/-- `exp (±0) = 1`. -/
theorem eval_of_zero_bits (hbits : x.toNatBits = 0 ∨ x.toNatBits = 0x80000000) :
    (Spec.exp .binary32).eval mode x = posOne .binary32 := by
  obtain ⟨hnan, hinf, hzero⟩ : x.isNaN = false ∧ x.isInfinite = false ∧ x.isZero = true := by
    grind [Binary32.isNaN_iff, Binary32.isInfinite_iff, Binary32.isZero_iff]
  simp [Spec.eval, Spec.exp, hnan, hinf, hzero]

/-- `exp (+∞) = +∞`. -/
theorem eval_of_posInf_bits (hbits : x.toNatBits = 0x7F800000) :
    (Spec.exp .binary32).eval mode x = posInf .binary32 := by
  obtain ⟨hnan, hinf, hsign⟩ : x.isNaN = false ∧ x.isInfinite = true ∧ x.signBit = false := by
    grind [Binary32.isNaN_iff, Binary32.isInfinite_iff, Binary32.signBit_eq_false_iff]
  simp [Spec.eval, Spec.exp, hnan, hinf, hsign]

/-- `exp (-∞) = +0`. -/
theorem eval_of_negInf_bits (hbits : x.toNatBits = 0xFF800000) :
    (Spec.exp .binary32).eval mode x = posZero .binary32 := by
  obtain ⟨hnan, hinf, hsign⟩ : x.isNaN = false ∧ x.isInfinite = true ∧ x.signBit = true := by
    grind [Binary32.isNaN_iff, Binary32.isInfinite_iff, Binary32.signBit_eq_true_iff]
  simp [Spec.eval, Spec.exp, hnan, hinf, hsign]

/-! ## Finite nonzero arguments -/

/-- At a finite nonzero argument the result is the rounding of the real exponential. -/
theorem eval_eq_roundReal (hnan : x.isNaN = false) (hinf : x.isInfinite = false)
    (hzero : x.isZero = false) :
    (Spec.exp .binary32).eval mode x = roundReal .binary32 mode (Real.exp x.toReal) := by
  simp [Spec.eval, Spec.exp, hnan, hinf, hzero]

/-- A finite value that does not denote zero is not a NaN, an infinity or a zero. -/
private theorem classify_of_toReal_ne_zero (hfinite : x.isFinite = true) (hx : x.toReal ≠ 0) :
    x.isNaN = false ∧ x.isInfinite = false ∧ x.isZero = false := by
  have hbits := Binary32.isFinite_iff.mp hfinite
  refine ⟨isNaN_eq_false_of_isFinite_eq_true x hfinite, ?_, ?_⟩ <;> apply Bool.eq_false_iff.mpr
  · rw [ne_eq, Binary32.isInfinite_iff]
    omega
  · exact fun hzero => hx (toReal_eq_zero_of_isZero x hzero)

/-- The real value of a bit pattern, from its exact rational value. -/
private theorem toReal_ofNatBits_eq {bits : ℕ} {q : ℚ}
    (h : toRat? (ofNatBits bits : Model FloatFormat.binary32) = some q) :
    (ofNatBits bits : Model FloatFormat.binary32).toReal = q :=
  Algebraic.toReal_of_toRat?_eq_some h

/-! ### Bounds on the exponential -/

private theorem exp_nat_mul_log_two (n : ℕ) : Real.exp (n * Real.log 2) = 2 ^ n := by
  rw [Real.exp_nat_mul, Real.exp_log (by norm_num)]

/-- `exp t = 2⁻ⁿ exp (t + n log 2)`. -/
private theorem exp_eq_mul (t : ℝ) (n : ℕ) :
    Real.exp t = 1 / 2 ^ n * Real.exp (t + n * Real.log 2) := by
  rw [← exp_nat_mul_log_two n, one_div, ← Real.exp_neg, ← Real.exp_add]
  congr 1
  ring

/-- `exp t ≤ 1 / (1 + c)` for `t ≤ -c ≤ 0`. -/
private theorem exp_le_one_div_of_le_neg {t c : ℝ} (hc : 0 ≤ c) (ht : t ≤ -c) :
    Real.exp t ≤ 1 / (1 + c) := by
  have h := Real.add_one_le_exp (-t)
  rw [Real.exp_neg] at h
  have hpos := Real.exp_pos t
  rw [le_div_iff₀ (by linarith)]
  calc Real.exp t * (1 + c) ≤ Real.exp t * (Real.exp t)⁻¹ := by gcongr; linarith
    _ = 1 := mul_inv_cancel₀ hpos.ne'

/-- Up to the largest binary32 value below `2⁻²⁴`, the exponential is at most the midpoint of
`1` and its successor. -/
private theorem exp_le_midpoint_above_one {t : ℝ} (ht : t ≤ 1 / 2 ^ 24 - 1 / 2 ^ 48) :
    Real.exp t ≤ 1 + 1 / 2 ^ 24 := by
  refine (Real.exp_le_exp.mpr ht).trans ?_
  have h := Real.abs_exp_sub_one_sub_id_le (x := 1 / 2 ^ 24 - 1 / 2 ^ 48)
    (by rw [abs_of_nonneg (by norm_num)]; norm_num)
  have hupper := (abs_le.mp h).2
  have hsquare : ((1 : ℝ) / 2 ^ 24 - 1 / 2 ^ 48) + (1 / 2 ^ 24 - 1 / 2 ^ 48) ^ 2 ≤ 1 / 2 ^ 24 := by
    norm_num
  linarith

/-- Up to the largest binary32 value below `2⁻²³`, the exponential is below the successor of
`1`. -/
private theorem exp_le_succ_one {t : ℝ} (ht : t ≤ 1 / 2 ^ 23 - 1 / 2 ^ 47) :
    Real.exp t ≤ 1 + 1 / 2 ^ 23 - 1 / 2 ^ 72 := by
  refine (Real.exp_le_exp.mpr ht).trans ?_
  have h := Real.exp_bound (x := 1 / 2 ^ 23 - 1 / 2 ^ 47)
    (by rw [abs_of_nonneg (by norm_num)]; norm_num) (n := 3) (by norm_num)
  rw [abs_of_nonneg (a := (1 : ℝ) / 2 ^ 23 - 1 / 2 ^ 47) (by norm_num)] at h
  have hupper := (abs_le.mp h).2
  norm_num [Finset.sum_range_succ, Nat.factorial] at hupper
  linarith

/-- From `-2⁻²⁴` on, the exponential is above the predecessor of `1`. -/
private theorem pred_one_le_exp {t : ℝ} (ht : -(1 / 2 ^ 24) ≤ t) :
    1 - 1 / 2 ^ 24 + 1 / 2 ^ 50 ≤ Real.exp t := by
  refine le_trans ?_ (Real.exp_le_exp.mpr ht)
  have h := Real.exp_bound (x := -(1 / 2 ^ 24))
    (by rw [abs_neg, abs_of_nonneg (by norm_num)]; norm_num) (n := 3) (by norm_num)
  rw [abs_neg, abs_of_nonneg (a := (1 : ℝ) / 2 ^ 24) (by norm_num)] at h
  have hlower := (abs_le.mp h).1
  norm_num [Finset.sum_range_succ, Nat.factorial] at hlower
  linarith

/-- From the binary32 value `0x42B17218` on, the exponential is at least `2¹²⁸`. -/
private theorem two_pow_le_exp {t : ℝ} (ht : 1453635 / 2 ^ 14 ≤ t) : 2 ^ 128 ≤ Real.exp t := by
  rw [← exp_nat_mul_log_two 128]
  apply Real.exp_le_exp.mpr
  have hlog := Real.log_two_lt_d9
  norm_num at hlog ht ⊢
  linarith

/-- Up to the binary32 value `0xC2CFF1B5`, the argument is below `-150 log 2`, so its
exponential is below `2⁻¹⁵⁰`. -/
private theorem add_mul_log_two_neg {t : ℝ} (ht : t ≤ -(13627829 / 2 ^ 17)) :
    t + (150 : ℕ) * Real.log 2 < 0 := by
  have hlog := Real.log_two_lt_d9
  norm_num at hlog ht ⊢
  linarith

/-- From the binary32 value `0xC2CFF1B4` on, the exponential is above `2⁻¹⁵⁰`. -/
private theorem two_pow_mul_le_exp {t : ℝ} (ht : -(3406957 / 2 ^ 15) ≤ t) :
    1 / 2 ^ 150 * (1 + 1 / 2 ^ 21) ≤ Real.exp t := by
  rw [exp_eq_mul t 150]
  have hlog := Real.log_two_gt_d9
  have hexp := Real.add_one_le_exp (t + (150 : ℕ) * Real.log 2)
  refine mul_le_mul_of_nonneg_left ?_ (by positivity)
  norm_num at hlog ht hexp ⊢
  linarith

/-- Up to the binary32 value `0xC2CE8ED0`, the exponential is below `2⁻¹⁴⁹`. -/
private theorem exp_le_two_pow_mul {t : ℝ} (ht : t ≤ -(846061 / 2 ^ 13)) :
    Real.exp t ≤ 1 / 2 ^ 149 * (1 / (1 + 1 / 2 ^ 21)) := by
  rw [exp_eq_mul t 149]
  have hlog := Real.log_two_lt_d9
  refine mul_le_mul_of_nonneg_left (exp_le_one_div_of_le_neg (by positivity) ?_) (by positivity)
  norm_num at hlog ht ⊢
  linarith

/-! ### Rounding of the ranges of the exponential -/

private theorem roundReal_above_one (hmode : mode ∈ cModes) {y : ℝ} (hlo : 1 + 1 / 2 ^ 149 ≤ y)
    (hhi : y ≤ 1 + 1 / 2 ^ 24) :
    roundReal .binary32 mode y = if mode = .up then ofNatBits 0x3F800001 else posOne .binary32 := by
  rcases hmode with rfl | rfl | rfl | rfl <;>
    exact roundReal_eq_of_mem_Icc_rat rfl _ (lo := 1 + 1 / 2 ^ 149) (hi := 1 + 1 / 2 ^ 24)
      (by norm_num) (by push_cast; exact hlo) (by push_cast; exact hhi) (by decide +kernel)
      (by decide +kernel)

private theorem roundReal_above_one_of_ne_nearest (hmode : mode ∈ cModes)
    (hdirected : mode ≠ .nearest) {y : ℝ} (hlo : 1 + 1 / 2 ^ 149 ≤ y)
    (hhi : y ≤ 1 + 1 / 2 ^ 23 - 1 / 2 ^ 72) :
    roundReal .binary32 mode y = if mode = .up then ofNatBits 0x3F800001 else posOne .binary32 := by
  rcases hmode with rfl | rfl | rfl | rfl
  · exact absurd rfl hdirected
  all_goals
    exact roundReal_eq_of_mem_Icc_rat rfl _ (lo := 1 + 1 / 2 ^ 149)
      (hi := 1 + 1 / 2 ^ 23 - 1 / 2 ^ 72) (by norm_num) (by push_cast; exact hlo)
      (by push_cast; exact hhi) (by decide +kernel) (by decide +kernel)

private theorem roundReal_below_one (hmode : mode ∈ cModes) {y : ℝ} (hlo : 1 - 1 / 2 ^ 25 ≤ y)
    (hhi : y ≤ 1 / (1 + 1 / 2 ^ 149)) :
    roundReal .binary32 mode y =
      if mode = .towardZero ∨ mode = .down then ofNatBits 0x3F7FFFFF else posOne .binary32 := by
  rcases hmode with rfl | rfl | rfl | rfl <;>
    exact roundReal_eq_of_mem_Icc_rat rfl _ (lo := 1 - 1 / 2 ^ 25) (hi := 1 / (1 + 1 / 2 ^ 149))
      (by norm_num) (by push_cast; exact hlo) (by push_cast; exact hhi) (by decide +kernel)
      (by decide +kernel)

private theorem roundReal_below_one_of_ne_nearest (hmode : mode ∈ cModes)
    (hdirected : mode ≠ .nearest) {y : ℝ} (hlo : 1 - 1 / 2 ^ 24 + 1 / 2 ^ 50 ≤ y)
    (hhi : y ≤ 1 / (1 + 1 / 2 ^ 149)) :
    roundReal .binary32 mode y =
      if mode = .towardZero ∨ mode = .down then ofNatBits 0x3F7FFFFF else posOne .binary32 := by
  rcases hmode with rfl | rfl | rfl | rfl
  · exact absurd rfl hdirected
  all_goals
    exact roundReal_eq_of_mem_Icc_rat rfl _ (lo := 1 - 1 / 2 ^ 24 + 1 / 2 ^ 50)
      (hi := 1 / (1 + 1 / 2 ^ 149)) (by norm_num) (by push_cast; exact hlo)
      (by push_cast; exact hhi) (by decide +kernel) (by decide +kernel)

private theorem roundReal_near_underflow (hmode : mode ∈ cModes) {y : ℝ}
    (hlo : 1 / 2 ^ 150 * (1 + 1 / 2 ^ 21) ≤ y) (hhi : y ≤ 1 / 2 ^ 149 * (1 / (1 + 1 / 2 ^ 21))) :
    roundReal .binary32 mode y =
      if mode = .towardZero ∨ mode = .down then posZero .binary32
      else posMinSubnormal .binary32 := by
  rcases hmode with rfl | rfl | rfl | rfl <;>
    exact roundReal_eq_of_mem_Icc_rat rfl _ (lo := 1 / 2 ^ 150 * (1 + 1 / 2 ^ 21))
      (hi := 1 / 2 ^ 149 * (1 / (1 + 1 / 2 ^ 21))) (by norm_num) (by push_cast; exact hlo)
      (by push_cast; exact hhi) (by decide +kernel) (by decide +kernel)

/-! ## Tiny arguments -/

/-- For `0 < x < 2⁻²⁴` the exponential lies between `1` and the midpoint of `1` and its
successor `1 + 2⁻²³`: the result is the successor when rounding up, and `1` otherwise.
These are the 864 026 623 bit patterns `0x00000001`–`0x337FFFFF`. -/
theorem eval_of_tiny_pos_bits (hmode : mode ∈ cModes)
    (hbits : 0x00000001 ≤ x.toNatBits ∧ x.toNatBits ≤ 0x337FFFFF) :
    (Spec.exp .binary32).eval mode x =
      if mode = .up then ofNatBits 0x3F800001 else posOne .binary32 := by
  obtain ⟨hnan, hinf, hzero⟩ :=
    Binary32.classify_of_toNatBits_mem (.inl ⟨by norm_num, by norm_num⟩) hbits
  have hlo := (Binary32.toReal_ofNatBits_le_iff_of_nonneg (by norm_num) (by omega)).mpr hbits.1
  have hhi := (Binary32.toReal_le_ofNatBits_iff_of_nonneg (by norm_num) (by omega)).mpr hbits.2
  rw [toReal_ofNatBits_eq (q := 1 / 2 ^ 149) (by decide +kernel)] at hlo
  rw [toReal_ofNatBits_eq (q := 1 / 2 ^ 24 - 1 / 2 ^ 48) (by decide +kernel)] at hhi
  push_cast at hlo hhi
  rw [eval_eq_roundReal hnan hinf hzero]
  exact roundReal_above_one hmode (by linarith [Real.add_one_le_exp x.toReal])
    (exp_le_midpoint_above_one hhi)

/-- When not rounding to nearest, the result for `0 < x < 2⁻²³` is the successor `1 + 2⁻²³` of
`1` when rounding up, and `1` otherwise. These are the 872 415 231 bit patterns
`0x00000001`–`0x33FFFFFF`. -/
theorem eval_of_tiny_pos_bits_of_ne_nearest (hmode : mode ∈ cModes) (hdirected : mode ≠ .nearest)
    (hbits : 0x00000001 ≤ x.toNatBits ∧ x.toNatBits ≤ 0x33FFFFFF) :
    (Spec.exp .binary32).eval mode x =
      if mode = .up then ofNatBits 0x3F800001 else posOne .binary32 := by
  obtain ⟨hnan, hinf, hzero⟩ :=
    Binary32.classify_of_toNatBits_mem (.inl ⟨by norm_num, by norm_num⟩) hbits
  have hlo := (Binary32.toReal_ofNatBits_le_iff_of_nonneg (by norm_num) (by omega)).mpr hbits.1
  have hhi := (Binary32.toReal_le_ofNatBits_iff_of_nonneg (by norm_num) (by omega)).mpr hbits.2
  rw [toReal_ofNatBits_eq (q := 1 / 2 ^ 149) (by decide +kernel)] at hlo
  rw [toReal_ofNatBits_eq (q := 1 / 2 ^ 23 - 1 / 2 ^ 47) (by decide +kernel)] at hhi
  push_cast at hlo hhi
  rw [eval_eq_roundReal hnan hinf hzero]
  exact roundReal_above_one_of_ne_nearest hmode hdirected
    (by linarith [Real.add_one_le_exp x.toReal]) (exp_le_succ_one hhi)

/-- For `-2⁻²⁵ ≤ x < 0` the exponential lies between the midpoint of `1` and its predecessor
`1 - 2⁻²⁴`, and `1`: the result is the predecessor when rounding toward zero or down, and `1`
otherwise. These are the 855 638 016 bit patterns `0x80000001`–`0xB3000000`. -/
theorem eval_of_tiny_neg_bits (hmode : mode ∈ cModes)
    (hbits : 0x80000001 ≤ x.toNatBits ∧ x.toNatBits ≤ 0xB3000000) :
    (Spec.exp .binary32).eval mode x =
      if mode = .towardZero ∨ mode = .down then ofNatBits 0x3F7FFFFF else posOne .binary32 := by
  obtain ⟨hnan, hinf, hzero⟩ :=
    Binary32.classify_of_toNatBits_mem (.inr ⟨by norm_num, by norm_num⟩) hbits
  have hhi := (Binary32.toReal_le_ofNatBits_iff_of_nonpos (by norm_num) (by omega)).mpr hbits.1
  have hlo := (Binary32.toReal_ofNatBits_le_iff_of_nonpos (by norm_num) (by omega)).mpr hbits.2
  rw [toReal_ofNatBits_eq (q := -(1 / 2 ^ 149)) (by decide +kernel)] at hhi
  rw [toReal_ofNatBits_eq (q := -(1 / 2 ^ 25)) (by decide +kernel)] at hlo
  push_cast at hlo hhi
  rw [eval_eq_roundReal hnan hinf hzero]
  exact roundReal_below_one hmode (by linarith [Real.add_one_le_exp x.toReal])
    (exp_le_one_div_of_le_neg (by positivity) hhi)

/-- When not rounding to nearest, the result for `-2⁻²⁴ ≤ x < 0` is the predecessor `1 - 2⁻²⁴`
of `1` when rounding toward zero or down, and `1` when rounding up. These are the 864 026 624
bit patterns `0x80000001`–`0xB3800000`. -/
theorem eval_of_tiny_neg_bits_of_ne_nearest (hmode : mode ∈ cModes) (hdirected : mode ≠ .nearest)
    (hbits : 0x80000001 ≤ x.toNatBits ∧ x.toNatBits ≤ 0xB3800000) :
    (Spec.exp .binary32).eval mode x =
      if mode = .towardZero ∨ mode = .down then ofNatBits 0x3F7FFFFF else posOne .binary32 := by
  obtain ⟨hnan, hinf, hzero⟩ :=
    Binary32.classify_of_toNatBits_mem (.inr ⟨by norm_num, by norm_num⟩) hbits
  have hhi := (Binary32.toReal_le_ofNatBits_iff_of_nonpos (by norm_num) (by omega)).mpr hbits.1
  have hlo := (Binary32.toReal_ofNatBits_le_iff_of_nonpos (by norm_num) (by omega)).mpr hbits.2
  rw [toReal_ofNatBits_eq (q := -(1 / 2 ^ 149)) (by decide +kernel)] at hhi
  rw [toReal_ofNatBits_eq (q := -(1 / 2 ^ 24)) (by decide +kernel)] at hlo
  push_cast at hlo hhi
  rw [eval_eq_roundReal hnan hinf hzero]
  exact roundReal_below_one_of_ne_nearest hmode hdirected (pred_one_le_exp hlo)
    (exp_le_one_div_of_le_neg (by positivity) hhi)

/-- The result for `0 < x < 2⁻²⁴`: see `eval_of_tiny_pos_bits`. -/
theorem eval_of_tiny_pos (hmode : mode ∈ cModes) (hfinite : x.isFinite = true)
    (hpos : 0 < x.toReal) (hlt : x.toReal < 1 / 2 ^ 24) :
    (Spec.exp .binary32).eval mode x =
      if mode = .up then ofNatBits 0x3F800001 else posOne .binary32 := by
  obtain ⟨hpositive, hrange⟩ := (Binary32.toReal_pos_iff hfinite).mp hpos
  refine eval_of_tiny_pos_bits hmode ⟨hpositive, ?_⟩
  by_contra hge
  have hle := (Binary32.toReal_ofNatBits_le_iff_of_nonneg (bits := 0x33800000) (by norm_num)
    hrange).mpr (by omega)
  rw [toReal_ofNatBits_eq (q := 1 / 2 ^ 24) (by decide +kernel)] at hle
  push_cast at hle
  linarith

/-- The result for `0 < x < 2⁻²³` when not rounding to nearest: see
`eval_of_tiny_pos_bits_of_ne_nearest`. -/
theorem eval_of_tiny_pos_of_ne_nearest (hmode : mode ∈ cModes) (hdirected : mode ≠ .nearest)
    (hfinite : x.isFinite = true) (hpos : 0 < x.toReal) (hlt : x.toReal < 1 / 2 ^ 23) :
    (Spec.exp .binary32).eval mode x =
      if mode = .up then ofNatBits 0x3F800001 else posOne .binary32 := by
  obtain ⟨hpositive, hrange⟩ := (Binary32.toReal_pos_iff hfinite).mp hpos
  refine eval_of_tiny_pos_bits_of_ne_nearest hmode hdirected ⟨hpositive, ?_⟩
  by_contra hge
  have hle := (Binary32.toReal_ofNatBits_le_iff_of_nonneg (bits := 0x34000000) (by norm_num)
    hrange).mpr (by omega)
  rw [toReal_ofNatBits_eq (q := 1 / 2 ^ 23) (by decide +kernel)] at hle
  push_cast at hle
  linarith

/-- The result for `-2⁻²⁵ ≤ x < 0`: see `eval_of_tiny_neg_bits`. -/
theorem eval_of_tiny_neg (hmode : mode ∈ cModes) (hfinite : x.isFinite = true)
    (hneg : x.toReal < 0) (hle : -(1 / 2 ^ 25) ≤ x.toReal) :
    (Spec.exp .binary32).eval mode x =
      if mode = .towardZero ∨ mode = .down then ofNatBits 0x3F7FFFFF else posOne .binary32 := by
  obtain ⟨hnegative, hrange⟩ := (Binary32.toReal_neg_iff hfinite).mp hneg
  refine eval_of_tiny_neg_bits hmode ⟨hnegative, ?_⟩
  refine (Binary32.toReal_ofNatBits_le_iff_of_nonpos (by norm_num) ⟨hnegative.le, hrange⟩).mp ?_
  rw [toReal_ofNatBits_eq (q := -(1 / 2 ^ 25)) (by decide +kernel)]
  push_cast
  exact hle

/-- The result for `-2⁻²⁴ ≤ x < 0` when not rounding to nearest: see
`eval_of_tiny_neg_bits_of_ne_nearest`. -/
theorem eval_of_tiny_neg_of_ne_nearest (hmode : mode ∈ cModes) (hdirected : mode ≠ .nearest)
    (hfinite : x.isFinite = true) (hneg : x.toReal < 0) (hle : -(1 / 2 ^ 24) ≤ x.toReal) :
    (Spec.exp .binary32).eval mode x =
      if mode = .towardZero ∨ mode = .down then ofNatBits 0x3F7FFFFF else posOne .binary32 := by
  obtain ⟨hnegative, hrange⟩ := (Binary32.toReal_neg_iff hfinite).mp hneg
  refine eval_of_tiny_neg_bits_of_ne_nearest hmode hdirected ⟨hnegative, ?_⟩
  refine (Binary32.toReal_ofNatBits_le_iff_of_nonpos (by norm_num) ⟨hnegative.le, hrange⟩).mp ?_
  rw [toReal_ofNatBits_eq (q := -(1 / 2 ^ 24)) (by decide +kernel)]
  push_cast
  exact hle

/-! ## Overflow -/

/-- When the exponential is at least `2¹²⁸` the result is the largest finite value when rounding
toward zero or down, and `+∞` otherwise. -/
theorem eval_of_two_pow_le_exp (hmode : mode ∈ cModes) (hfinite : x.isFinite = true)
    (hexp : 2 ^ 128 ≤ Real.exp x.toReal) :
    (Spec.exp .binary32).eval mode x =
      if mode = .towardZero ∨ mode = .down then posMaxFinite .binary32 else posInf .binary32 := by
  have hne : x.toReal ≠ 0 := by
    intro hzero
    rw [hzero, Real.exp_zero] at hexp
    norm_num at hexp
  obtain ⟨hnan, hinf, hzero⟩ := classify_of_toReal_ne_zero hfinite hne
  have hexponent : FloatFormat.binary32.maxNormalExponent + 1 = (128 : ℕ) := by decide
  rw [eval_eq_roundReal hnan hinf hzero,
    roundReal_of_two_zpow_le mode (by rw [hexponent, zpow_natCast]; exact hexp)]
  rcases hmode with rfl | rfl | rfl | rfl <;> decide +kernel

/-- The exponential of the binary32 values from `0x42B17218`, about `88.7228394`, is at least
`2¹²⁸`: see `eval_of_two_pow_le_exp`. These are the 1 020 169 704 bit patterns
`0x42B17218`–`0x7F7FFFFF`. -/
theorem eval_of_overflow_bits (hmode : mode ∈ cModes)
    (hbits : 0x42B17218 ≤ x.toNatBits ∧ x.toNatBits ≤ 0x7F7FFFFF) :
    (Spec.exp .binary32).eval mode x =
      if mode = .towardZero ∨ mode = .down then posMaxFinite .binary32 else posInf .binary32 := by
  have hlo := (Binary32.toReal_ofNatBits_le_iff_of_nonneg (by norm_num) hbits.2).mpr hbits.1
  rw [toReal_ofNatBits_eq (q := 1453635 / 2 ^ 14) (by decide +kernel)] at hlo
  push_cast at hlo
  exact eval_of_two_pow_le_exp hmode (Binary32.isFinite_iff.mpr (.inl hbits.2))
    (two_pow_le_exp hlo)

/-! ## Underflow

The conditions on the exponential are stated with `≤`. A strict inequality between a real and a
closed term such as `1 / 2 ^ 150` is expensive to elaborate against, because unification unfolds
the order of the reals and with it the power, one multiplication at a time. -/

/-- The exponential of the binary32 values from `0xC2CFF1B5`, about `-103.972084`, down to the
least finite value is below `2⁻¹⁵⁰`, half the least positive value `2⁻¹⁴⁹`: the result is
`2⁻¹⁴⁹` when rounding up, and `+0` otherwise. These are the 1 018 170 955 bit patterns
`0xC2CFF1B5`–`0xFF7FFFFF`. -/
theorem eval_of_underflow_bits (hmode : mode ∈ cModes)
    (hbits : 0xC2CFF1B5 ≤ x.toNatBits ∧ x.toNatBits ≤ 0xFF7FFFFF) :
    (Spec.exp .binary32).eval mode x =
      if mode = .up then posMinSubnormal .binary32 else posZero .binary32 := by
  obtain ⟨hnan, hinf, hzero⟩ :=
    Binary32.classify_of_toNatBits_mem (.inr ⟨by norm_num, by norm_num⟩) hbits
  have hhi := (Binary32.toReal_le_ofNatBits_iff_of_nonpos (by norm_num) (by omega)).mpr hbits.1
  rw [toReal_ofNatBits_eq (q := -(13627829 / 2 ^ 17)) (by decide +kernel)] at hhi
  push_cast at hhi
  have hexponent : FloatFormat.binary32.minSubnormalExponent - 1 = -150 := rfl
  rw [eval_eq_roundReal hnan hinf hzero,
    roundReal_of_le_two_zpow_mul mode (Real.exp_pos _)
      (Real.exp_lt_one_iff.mpr (add_mul_log_two_neg hhi))
      (by rw [hexponent, zpow_neg, zpow_ofNat, ← one_div]; exact (exp_eq_mul _ 150).le)]
  rcases hmode with rfl | rfl | rfl | rfl <;> decide +kernel

/-- When the exponential is at most `2⁻¹⁵⁰`, half the least positive value `2⁻¹⁴⁹`, the result is
`2⁻¹⁴⁹` when rounding up, and `+0` otherwise: see `eval_of_underflow_bits`. -/
theorem eval_of_exp_le_two_pow (hmode : mode ∈ cModes) (hfinite : x.isFinite = true)
    (hexp : Real.exp x.toReal ≤ 1 / 2 ^ 150) :
    (Spec.exp .binary32).eval mode x =
      if mode = .up then posMinSubnormal .binary32 else posZero .binary32 := by
  have hneg : x.toReal < 0 := by
    by_contra hnonneg
    have hone := Real.one_le_exp (not_lt.mp hnonneg)
    norm_num at hexp
    linarith
  obtain ⟨hnegative, hrange⟩ := (Binary32.toReal_neg_iff hfinite).mp hneg
  refine eval_of_underflow_bits hmode ⟨?_, hrange⟩
  by_contra hlt
  have hle := (Binary32.toReal_ofNatBits_le_iff_of_nonpos (bits := 0xC2CFF1B4) (by norm_num)
    ⟨hnegative.le, hrange⟩).mpr (by omega)
  rw [toReal_ofNatBits_eq (q := -(3406957 / 2 ^ 15)) (by decide +kernel)] at hle
  push_cast at hle
  have hlower := two_pow_mul_le_exp hle
  norm_num at hexp hlower
  linarith

/-- The exponential of the binary32 values from `0xC2CE8ED0`, about `-103.278931`, to
`0xC2CFF1B4`, about `-103.972076`, lies strictly between `2⁻¹⁵⁰` and the least positive value
`2⁻¹⁴⁹`: the result is `+0` when rounding toward zero or down, and `2⁻¹⁴⁹` otherwise. These are
the 90 853 bit patterns `0xC2CE8ED0`–`0xC2CFF1B4`. -/
theorem eval_of_near_underflow_bits (hmode : mode ∈ cModes)
    (hbits : 0xC2CE8ED0 ≤ x.toNatBits ∧ x.toNatBits ≤ 0xC2CFF1B4) :
    (Spec.exp .binary32).eval mode x =
      if mode = .towardZero ∨ mode = .down then posZero .binary32
      else posMinSubnormal .binary32 := by
  obtain ⟨hnan, hinf, hzero⟩ :=
    Binary32.classify_of_toNatBits_mem (.inr ⟨by norm_num, by norm_num⟩) hbits
  have hhi := (Binary32.toReal_le_ofNatBits_iff_of_nonpos (by norm_num) (by omega)).mpr hbits.1
  have hlo := (Binary32.toReal_ofNatBits_le_iff_of_nonpos (by norm_num) (by omega)).mpr hbits.2
  rw [toReal_ofNatBits_eq (q := -(846061 / 2 ^ 13)) (by decide +kernel)] at hhi
  rw [toReal_ofNatBits_eq (q := -(3406957 / 2 ^ 15)) (by decide +kernel)] at hlo
  push_cast at hlo hhi
  rw [eval_eq_roundReal hnan hinf hzero]
  exact roundReal_near_underflow hmode (two_pow_mul_le_exp hlo) (exp_le_two_pow_mul hhi)

/-- The result for `-3406957 / 2¹⁵ ≤ x ≤ -846061 / 2¹³`: see `eval_of_near_underflow_bits`. -/
theorem eval_of_near_underflow (hmode : mode ∈ cModes) (hfinite : x.isFinite = true)
    (hlo : -(3406957 / 2 ^ 15) ≤ x.toReal) (hhi : x.toReal ≤ -(846061 / 2 ^ 13)) :
    (Spec.exp .binary32).eval mode x =
      if mode = .towardZero ∨ mode = .down then posZero .binary32
      else posMinSubnormal .binary32 := by
  have hneg : x.toReal < 0 := by linarith
  obtain ⟨hnegative, hrange⟩ := (Binary32.toReal_neg_iff hfinite).mp hneg
  have hsign : 0x80000000 ≤ x.toNatBits ∧ x.toNatBits ≤ 0xFF7FFFFF := ⟨hnegative.le, hrange⟩
  refine eval_of_near_underflow_bits hmode ⟨?_, ?_⟩
  · refine (Binary32.toReal_le_ofNatBits_iff_of_nonpos (by norm_num) hsign).mp ?_
    rw [toReal_ofNatBits_eq (q := -(846061 / 2 ^ 13)) (by decide +kernel)]
    push_cast
    exact hhi
  · refine (Binary32.toReal_ofNatBits_le_iff_of_nonpos (by norm_num) hsign).mp ?_
    rw [toReal_ofNatBits_eq (q := -(3406957 / 2 ^ 15)) (by decide +kernel)]
    push_cast
    exact hlo

/-! ## All ranges together -/

/-- The correctly rounded `exp` of the binary32 value with bit pattern `bits`, when the pattern
lies in one of the blocks of this file. -/
def closedForm? (mode : IEEERoundingMode) (bits : ℕ) : Option (Model FloatFormat.binary32) :=
  if bits = 0x00000000 ∨ bits = 0x80000000 then some (posOne .binary32)
  else if 0x00000001 ≤ bits ∧ bits ≤ (if mode = .nearest then 0x337FFFFF else 0x33FFFFFF) then
    some (if mode = .up then ofNatBits 0x3F800001 else posOne .binary32)
  else if 0x42B17218 ≤ bits ∧ bits ≤ 0x7F7FFFFF then
    some (if mode = .towardZero ∨ mode = .down then posMaxFinite .binary32 else posInf .binary32)
  else if bits = 0x7F800000 then some (posInf .binary32)
  else if (0x7F800001 ≤ bits ∧ bits ≤ 0x7FFFFFFF) ∨ (0xFF800001 ≤ bits ∧ bits ≤ 0xFFFFFFFF) then
    some (canonicalNaN .binary32)
  else if 0x80000001 ≤ bits ∧ bits ≤ (if mode = .nearest then 0xB3000000 else 0xB3800000) then
    some (if mode = .towardZero ∨ mode = .down then ofNatBits 0x3F7FFFFF else posOne .binary32)
  else if 0xC2CE8ED0 ≤ bits ∧ bits ≤ 0xC2CFF1B4 then
    some (if mode = .towardZero ∨ mode = .down then posZero .binary32
      else posMinSubnormal .binary32)
  else if 0xC2CFF1B5 ≤ bits ∧ bits ≤ 0xFF7FFFFF then
    some (if mode = .up then posMinSubnormal .binary32 else posZero .binary32)
  else if bits = 0xFF800000 then some (posZero .binary32)
  else none

/-- A result of `closedForm?` is the correctly rounded result. -/
theorem eval_eq_of_closedForm? (hmode : mode ∈ cModes) {result : Model FloatFormat.binary32}
    (h : closedForm? mode x.toNatBits = some result) :
    (Spec.exp .binary32).eval mode x = result := by
  unfold closedForm? at h
  by_cases hzero : x.toNatBits = 0x00000000 ∨ x.toNatBits = 0x80000000
  · rw [ite_eq_left hzero] at h
    exact (eval_of_zero_bits hzero).trans (Option.some.inj h)
  rw [ite_eq_right hzero] at h
  by_cases htinyPos : 0x00000001 ≤ x.toNatBits ∧
      x.toNatBits ≤ (if mode = .nearest then 0x337FFFFF else 0x33FFFFFF)
  · rw [ite_eq_left htinyPos] at h
    rw [← Option.some.inj h]
    by_cases hnearest : mode = .nearest
    · rw [ite_eq_left hnearest] at htinyPos
      exact eval_of_tiny_pos_bits hmode htinyPos
    · rw [ite_eq_right hnearest] at htinyPos
      exact eval_of_tiny_pos_bits_of_ne_nearest hmode hnearest htinyPos
  rw [ite_eq_right htinyPos] at h
  by_cases hoverflow : 0x42B17218 ≤ x.toNatBits ∧ x.toNatBits ≤ 0x7F7FFFFF
  · rw [ite_eq_left hoverflow] at h
    exact (eval_of_overflow_bits hmode hoverflow).trans (Option.some.inj h)
  rw [ite_eq_right hoverflow] at h
  by_cases hposInf : x.toNatBits = 0x7F800000
  · rw [ite_eq_left hposInf] at h
    exact (eval_of_posInf_bits hposInf).trans (Option.some.inj h)
  rw [ite_eq_right hposInf] at h
  by_cases hnan : (0x7F800001 ≤ x.toNatBits ∧ x.toNatBits ≤ 0x7FFFFFFF) ∨
      (0xFF800001 ≤ x.toNatBits ∧ x.toNatBits ≤ 0xFFFFFFFF)
  · rw [ite_eq_left hnan] at h
    exact (eval_of_nan_bits hnan).trans (Option.some.inj h)
  rw [ite_eq_right hnan] at h
  by_cases htinyNeg : 0x80000001 ≤ x.toNatBits ∧
      x.toNatBits ≤ (if mode = .nearest then 0xB3000000 else 0xB3800000)
  · rw [ite_eq_left htinyNeg] at h
    rw [← Option.some.inj h]
    by_cases hnearest : mode = .nearest
    · rw [ite_eq_left hnearest] at htinyNeg
      exact eval_of_tiny_neg_bits hmode htinyNeg
    · rw [ite_eq_right hnearest] at htinyNeg
      exact eval_of_tiny_neg_bits_of_ne_nearest hmode hnearest htinyNeg
  rw [ite_eq_right htinyNeg] at h
  by_cases hnear : 0xC2CE8ED0 ≤ x.toNatBits ∧ x.toNatBits ≤ 0xC2CFF1B4
  · rw [ite_eq_left hnear] at h
    exact (eval_of_near_underflow_bits hmode hnear).trans (Option.some.inj h)
  rw [ite_eq_right hnear] at h
  by_cases hunderflow : 0xC2CFF1B5 ≤ x.toNatBits ∧ x.toNatBits ≤ 0xFF7FFFFF
  · rw [ite_eq_left hunderflow] at h
    exact (eval_of_underflow_bits hmode hunderflow).trans (Option.some.inj h)
  rw [ite_eq_right hunderflow] at h
  by_cases hnegInf : x.toNatBits = 0xFF800000
  · rw [ite_eq_left hnegInf] at h
    exact (eval_of_negInf_bits hnegInf).trans (Option.some.inj h)
  rw [ite_eq_right hnegInf] at h
  exact absurd h (by simp)

/-! ## The blocks as data -/

/-- The blocks of `closedForm?` in increasing order: the first and the last bit pattern of each,
and the theorem of this file that gives the result on it. -/
def blocks (mode : IEEERoundingMode) : List (ℕ × ℕ × String) :=
  [(0x00000000, 0x00000000, "eval_of_zero_bits"),
   if mode = .nearest then (0x00000001, 0x337FFFFF, "eval_of_tiny_pos_bits")
   else (0x00000001, 0x33FFFFFF, "eval_of_tiny_pos_bits_of_ne_nearest"),
   (0x42B17218, 0x7F7FFFFF, "eval_of_overflow_bits"),
   (0x7F800000, 0x7F800000, "eval_of_posInf_bits"),
   (0x7F800001, 0x7FFFFFFF, "eval_of_nan_bits"),
   (0x80000000, 0x80000000, "eval_of_zero_bits"),
   if mode = .nearest then (0x80000001, 0xB3000000, "eval_of_tiny_neg_bits")
   else (0x80000001, 0xB3800000, "eval_of_tiny_neg_bits_of_ne_nearest"),
   (0xC2CE8ED0, 0xC2CFF1B4, "eval_of_near_underflow_bits"),
   (0xC2CFF1B5, 0xFF7FFFFF, "eval_of_underflow_bits"),
   (0xFF800000, 0xFF800000, "eval_of_negInf_bits"),
   (0xFF800001, 0xFFFFFFFF, "eval_of_nan_bits")]

/-- The block that contains the bit pattern `bits`, if any: which theorem to use for it. -/
def blockOf? (mode : IEEERoundingMode) (bits : ℕ) : Option (ℕ × ℕ × String) :=
  (blocks mode).find? fun block => block.1 ≤ bits ∧ bits ≤ block.2.1

/-- `closedForm?` answers exactly on the bit patterns of `blocks`. -/
theorem closedForm?_isSome_iff (mode : IEEERoundingMode) (bits : ℕ) :
    (closedForm? mode bits).isSome ↔ (blockOf? mode bits).isSome := by
  have hblocks : (blockOf? mode bits).isSome ↔
      bits ≤ (if mode = .nearest then 0x337FFFFF else 0x33FFFFFF) ∨
        (0x42B17218 ≤ bits ∧ bits ≤ (if mode = .nearest then 0xB3000000 else 0xB3800000)) ∨
        (0xC2CE8ED0 ≤ bits ∧ bits ≤ 0xFFFFFFFF) := by
    by_cases hn : mode = .nearest <;>
      simp [blockOf?, blocks, hn, List.find?_isSome] <;> omega
  rw [hblocks]
  unfold closedForm?
  by_cases hn : mode = .nearest <;> simp only [hn, ↓reduceIte] <;>
    split_ifs <;> simp <;> omega

/-- The number of bit patterns with a closed form. -/
def covered (mode : IEEERoundingMode) : ℕ :=
  ((blocks mode).map fun block => block.2.1 - block.1 + 1).sum

/-- The ranges of bit patterns below `2 ^ 32` that lie in no block, as first and last pattern:
what is left for another method. -/
def uncovered (mode : IEEERoundingMode) : List (ℕ × ℕ) :=
  let rec go (next : ℕ) : List (ℕ × ℕ × String) → List (ℕ × ℕ)
    | [] => if next < 2 ^ 32 then [(next, 2 ^ 32 - 1)] else []
    | (lo, hi, _) :: rest => (if next < lo then [(next, lo - 1)] else []) ++ go (hi + 1) rest
  go 0 (blocks mode)

end LibcMath.ExpRanges
