import LibcMath.Libc
import LibcMath.Analysis.Binary32Bits
import FloatLib.Floats.Formats.BinaryInterchange.Analysis.MixedPrecision
import FloatLib.Floats.Formats.BinaryInterchange.Analysis.StandardModel
import FloatLib.Floats.Formats.BinaryInterchange.DirectedSemantics.Exact
import FloatLib.Floats.Formats.BinaryInterchange.DirectedSemantics.Positive
import FloatLib.Floats.Formats.BinaryInterchange.DirectedSemantics.Rounded
import FloatLib.Floats.Formats.BinaryInterchange.DType.Semantics
import FloatLib.Floats.Formats.BinaryInterchange.KernelPath.Cast
import FloatLib.Floats.Formats.BinaryInterchange.Operations.Compare.Finite
import FloatLib.Floats.Formats.Flocq.Theory.Analysis.SterbenzFLT
import FloatLib.Floats.Formats.Flocq.Theory.Rounding.Properties

/-!
# Reusable binary32 exact range-reduction lemmas

Function-independent building blocks for Cody–Waite / power-of-two range reductions in binary32
across all four IEEE 754 rounding directions (`cModes`):

* `flt_iff_toReal_lt_binary32`, `fgt_iff_toReal_gt_binary32` — finite comparison equivalences.
* `roundAt_intCast_binary32` — exactness of integers `|n| ≤ 2²⁴` in binary32.
* `fmul_pow2_exact_binary32` — exact scaling of a binary32 float by `2^p` (`p ≥ 0`).
* `genericNearestInt_binary32_spec` — exact integer specification of `Libc.genericNearestInt false`
  across all four IEEE rounding modes whenever `|y| ≤ 2²²` and `|y| ∉ (1/2 - 2⁻²⁴, 1/2)`.
* `submul_invPow2_exact_binary32` — Sterbenz exactness of `submul(x, k, 2⁻ᵖ) = x - k · 2⁻ᵖ`.
* `fpCast_binary32_to_binary64_exact` — exact widening from binary32 to binary64 in all modes.
* `fptosi_int_binary32_eq` — UB-free `Libc.fptosi? 32` for exact integers in `[-2³¹, 2³¹ - 1]`.
-/

namespace LibcMath.Analysis.RangeReduction

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Libc.DSL

private abbrev limit32 : Model .binary32 :=
  Model.ofFields .binary32 false (FloatFormat.binary32.exponentBias +
    FloatFormat.binary32.fracWidth + 1) 0

private abbrev magic32 : Model .binary32 :=
  Model.ofFields .binary32 false (FloatFormat.binary32.exponentBias +
    FloatFormat.binary32.fracWidth) 0

private abbrev half32 : Model .binary32 :=
  Model.ofFields .binary32 false (FloatFormat.binary32.exponentBias - 1) 0

private theorem isFinite_limit32 : limit32.isFinite = true := by decide +kernel
private theorem toReal_limit32 : limit32.toReal = 16777216 := by
  simpa using Model.Algebraic.toReal_of_toRat?_eq_some (value := limit32)
    (q := 16777216) (by decide +kernel)

private theorem isFinite_magic32 : magic32.isFinite = true := by decide +kernel
private theorem toReal_magic32 : magic32.toReal = 8388608 := by
  simpa using Model.Algebraic.toReal_of_toRat?_eq_some (value := magic32)
    (q := 8388608) (by decide +kernel)

private theorem isFinite_half32 : half32.isFinite = true := by decide +kernel
private theorem toReal_half32 : half32.toReal = 1 / 2 := by
  simpa using Model.Algebraic.toReal_of_toRat?_eq_some (value := half32)
    (q := 1 / 2) (by decide +kernel)

private theorem isFinite_0x3F000001 :
    (Model.ofNatBits 0x3F000001 : Model .binary32).isFinite = true := by decide +kernel
private theorem toReal_0x3F000001 :
    (Model.ofNatBits 0x3F000001 : Model .binary32).toReal = 1 / 2 + (2 : ℝ) ^ (-24 : ℤ) := by
  have h := Model.Algebraic.toReal_of_toRat?_eq_some
    (value := (Model.ofNatBits 0x3F000001 : Model .binary32))
    (q := 8388609 / 16777216) (by decide +kernel)
  rw [h]; norm_num

private theorem isFinite_0xBF000001 :
    (Model.ofNatBits 0xBF000001 : Model .binary32).isFinite = true := by decide +kernel
private theorem toReal_0xBF000001 :
    (Model.ofNatBits 0xBF000001 : Model .binary32).toReal = -(1 / 2) - (2 : ℝ) ^ (-24 : ℤ) := by
  have h := Model.Algebraic.toReal_of_toRat?_eq_some
    (value := (Model.ofNatBits 0xBF000001 : Model .binary32))
    (q := -(8388609 / 16777216)) (by decide +kernel)
  rw [h]; norm_num

theorem posMaxFinite_binary32_ge_2p24 :
    (16777216 : ℝ) ≤ (Model.posMaxFinite .binary32).toReal := by
  have h := Model.abs_toReal_le_posMaxFinite_of_isFinite limit32 isFinite_limit32
  rw [toReal_limit32] at h
  norm_num at h
  exact h

theorem flt_iff_toReal_lt_binary32 {x y : Model .binary32}
    (hx : x.isFinite = true) (hy : y.isFinite = true) :
    Libc.flt x y = true ↔ x.toReal < y.toReal := by
  simp only [Libc.flt, beq_iff_eq]
  exact Model.compare_eq_some_lt_iff_toReal_lt_of_isFinite x y hx hy

theorem fgt_iff_toReal_gt_binary32 {x y : Model .binary32}
    (hx : x.isFinite = true) (hy : y.isFinite = true) :
    Libc.fgt x y = true ↔ y.toReal < x.toReal := by
  simp only [Libc.fgt, beq_iff_eq]
  exact Model.compare_eq_some_gt_iff_toReal_gt_of_isFinite x y hx hy

/-- Every integer `n` with `|n| ≤ 2²⁴` is exactly representable in binary32. -/
theorem roundAt_intCast_binary32 (mode : IEEERoundingMode) {n : ℤ}
    (hn : -16777216 ≤ n) (hn' : n ≤ 16777216) :
    Model.roundAt .binary32 (n : ℝ) mode = (n : ℝ) := by
  apply Model.roundAt_intCast_of_abs_le .binary32 _ mode
  have h1 : |(n : ℝ)| ≤ 16777216 := abs_le.mpr ⟨by exact_mod_cast hn, by exact_mod_cast hn'⟩
  have h2 : (16777216 : ℝ) ≤ 2 ^ (FloatFormat.binary32.fracWidth + 1) := by
    norm_num [FloatFormat.binary32]
  linarith

/-- Scaling a finite binary32 float `x` by an exact power of two `c = 2^p` (`p ≥ 0`) has zero
rounding error in every rounding mode whenever `|x * 2^p| ≤ posMaxFinite .binary32`. -/
theorem fmul_pow2_exact_binary32 (mode : IEEERoundingMode) (x c : Model .binary32) (p : ℕ)
    (hx_fin : x.isFinite = true) (hc_fin : c.isFinite = true) (hc_val : c.toReal = (2 : ℝ) ^ p)
    (hbound : |x.toReal * (2 : ℝ) ^ p| ≤ (Model.posMaxFinite .binary32).toReal) :
    (Libc.fmul mode x c).isFinite = true ∧
      (Libc.fmul mode x c).toReal = (2 : ℝ) ^ p * x.toReal := by
  have hb : |x.toReal * c.toReal| ≤ (Model.posMaxFinite .binary32).toReal := by
    rwa [hc_val]
  obtain ⟨hfin, hround⟩ := Model.mul_finite_roundAt (mode := mode) (by decide) hx_fin hc_fin hb
  refine ⟨hfin, ?_⟩
  rw [Libc.fmul, hround, hc_val]
  have hgen : FloatLib.Floats.Formats.Flocq.GenericRepresentable FloatLib.Numerics.binaryRadix
      (Model.fexpOf .binary32) (x.toReal * FloatLib.Floats.Formats.Flocq.bpow
        FloatLib.Numerics.binaryRadix (p : ℤ)) :=
    Model.genericFormat_mul_bpow .binary32 (Model.toReal_genericFormat_of_isFinite x hx_fin)
      (p : ℤ) (Or.inl (Int.natCast_nonneg p))
  have hbpow : FloatLib.Floats.Formats.Flocq.bpow FloatLib.Numerics.binaryRadix (p : ℤ) =
      (2 : ℝ) ^ p := by
    rw [FloatLib.Floats.Formats.Flocq.bpow_binaryRadix, zpow_natCast]
  rw [hbpow] at hgen
  rw [Model.roundAt_of_genericFormat .binary32 hgen mode]
  ring

/-- Any real `t` with `2²³ ≤ |t| < 2²⁴` lies in the unit-spacing binade of binary32, so
`roundAt .binary32 t mode` is an integer chosen from `{⌊t⌋, ⌈t⌉}`. -/
theorem roundAt_eq_floor_or_ceil_of_binade_binary32 (mode : IEEERoundingMode) {t : ℝ}
    (hlo : 8388608 ≤ |t|) (hhi : |t| < 16777216) :
    ∃ m : ℤ, Model.roundAt .binary32 t mode = (m : ℝ) ∧ (m = ⌊t⌋ ∨ m = ⌈t⌉) := by
  open FloatLib.Floats.Formats.Flocq in
  have hmag : magnitude FloatLib.Numerics.binaryRadix t = 24 := by
    apply magnitude_eq_of_bpow_bounds FloatLib.Numerics.binaryRadix t 24
    · rw [bpow_binaryRadix]; norm_num; exact hlo
    · rw [bpow_binaryRadix]; norm_num; exact hhi
  have hcexp : cexp FloatLib.Numerics.binaryRadix (Model.fexpOf .binary32) t = 0 := by
    simp [cexp, Model.fexpOf, fltExp, hmag, FloatFormat.binary32,
      FloatFormat.minSubnormalExponent, FloatFormat.minNormalExponent]
  have hscaled : scaledMantissa FloatLib.Numerics.binaryRadix (Model.fexpOf .binary32) t = t := by
    simp [scaledMantissa, hcexp, bpow_binaryRadix]
  have hround : Model.roundAt .binary32 t mode = (roundingFunction mode t : ℝ) := by
    rw [Model.roundAt_eq_round, FloatLib.Floats.Formats.Flocq.round, hcexp, hscaled]
    simp [FloatLib.Floats.Formats.Flocq.toReal, bpow_binaryRadix]
  refine ⟨roundingFunction mode t, hround, ?_⟩
  simpa [floorRound, ceilRound] using valid_round_eq_floor_or_ceil (roundingFunction mode) t

/-- When `y` is finite with `|y| ≥ 1/2` and `r0 ∈ {⌊y⌋, ⌈y⌉}` with `|r0| ≤ 2²⁴`, `y - r0` is exact
in binary32 (by Sterbenz's lemma when `r0 ≠ 0`, and trivially when `r0 = 0`). -/
theorem genericRepresentable_sub_floor_or_ceil_binary32 (y : Model .binary32)
    (hy_fin : y.isFinite = true) (hy_ge : 1 / 2 ≤ |y.toReal|) {r0 : ℤ}
    (hr0_lo : -16777216 ≤ r0) (hr0_hi : r0 ≤ 16777216) (hr0 : r0 = ⌊y.toReal⌋ ∨ r0 = ⌈y.toReal⌉) :
    FloatLib.Floats.Formats.Flocq.GenericRepresentable FloatLib.Numerics.binaryRadix
      (Model.fexpOf .binary32) (y.toReal - (r0 : ℝ)) := by
  open FloatLib.Floats.Formats.Flocq in
  have hy_gen := Model.toReal_genericFormat_of_isFinite y hy_fin
  by_cases hr0_zero : r0 = 0
  · subst hr0_zero; simpa using hy_gen
  have hr0_gen : GenericRepresentable FloatLib.Numerics.binaryRadix (Model.fexpOf .binary32)
      (r0 : ℝ) := by
    rw [← roundAt_intCast_binary32 .nearest hr0_lo hr0_hi]
    exact Model.genericFormat_roundAt .binary32 (r0 : ℝ) .nearest
  have hprec : (0 : ℤ) < (FloatFormat.binary32.fracWidth : ℤ) + 1 := by decide
  have hpos_case : ∀ (a : ℝ) (m : ℤ), 1 / 2 ≤ a → m ≠ 0 → (m = ⌊a⌋ ∨ m = ⌈a⌉) →
      GenericRepresentable FloatLib.Numerics.binaryRadix (Model.fexpOf .binary32) a →
      GenericRepresentable FloatLib.Numerics.binaryRadix (Model.fexpOf .binary32) (m : ℝ) →
      GenericRepresentable FloatLib.Numerics.binaryRadix (Model.fexpOf .binary32) (a - m) := by
    intro a m ha hm0 hm ha_gen hm_gen
    have hm_ge1 : (1 : ℤ) ≤ m := by
      rcases hm with rfl | rfl
      · have h0 : (0 : ℤ) ≤ ⌊a⌋ := Int.floor_nonneg.mpr (by linarith)
        omega
      · exact Int.le_ceil_iff.mpr (by norm_num; linarith)
    have hm_ge1_r : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm_ge1
    have ha_le : a ≤ 2 * (m : ℝ) := by
      rcases hm with rfl | rfl
      · linarith [Int.lt_floor_add_one a]
      · linarith [Int.le_ceil a]
    have hm_le : (m : ℝ) ≤ 2 * a := by
      rcases hm with rfl | rfl
      · linarith [Int.floor_le a]
      · by_cases ha1 : a ≤ 1
        · have hceil1 : ⌈a⌉ ≤ 1 := Int.ceil_le.mpr (by norm_cast)
          have hceil1_r : (⌈a⌉ : ℝ) ≤ 1 := by exact_mod_cast hceil1
          linarith
        · linarith [Int.ceil_lt_add_one a]
    exact genericRepresentable_flt_sterbenz FloatFormat.binary32.minSubnormalExponent
      ((FloatFormat.binary32.fracWidth : ℤ) + 1) hprec ha_le hm_le ha_gen hm_gen
  rcases le_or_gt 0 y.toReal with hy_nn | hy_neg
  · rw [abs_of_nonneg hy_nn] at hy_ge
    exact hpos_case y.toReal r0 hy_ge hr0_zero hr0 hy_gen hr0_gen
  · rw [abs_of_neg hy_neg] at hy_ge
    have hmir : -r0 = ⌊-y.toReal⌋ ∨ -r0 = ⌈-y.toReal⌉ := by
      rw [Int.floor_neg, Int.ceil_neg]
      rcases hr0 with rfl | rfl
      · exact Or.inr rfl
      · exact Or.inl rfl
    have hneg_sub := hpos_case (-y.toReal) (-r0) hy_ge (by omega) hmir
      (genericRepresentable_neg y.toReal hy_gen)
      (by simpa using genericRepresentable_neg (r0 : ℝ) hr0_gen)
    have hres := genericRepresentable_neg (-y.toReal - (-r0 : ℤ)) hneg_sub
    have heq : -(-y.toReal - ((-r0 : ℤ) : ℝ)) = y.toReal - (r0 : ℝ) := by push_cast; ring
    rwa [heq] at hres

/-- Exact integer specification of `Libc.genericNearestInt false mode y` in binary32 across all
four IEEE rounding modes, for any `lo ≤ y ≤ hi` with `-4194304 ≤ lo ≤ 0 ≤ hi ≤ 4194304` and
`|y| ∉ (1/2 - 2⁻²⁴, 1/2)`. -/
theorem genericNearestInt_binary32_spec (mode : IEEERoundingMode) (y : Model .binary32)
    {lo hi : ℤ} (hlo_ge : -4194304 ≤ lo) (hlo_le0 : lo ≤ 0) (hhi_ge0 : 0 ≤ hi)
    (hhi_le : hi ≤ 4194304)
    (hy_fin : y.isFinite = true) (hy_lo : (lo : ℝ) ≤ y.toReal) (hy_hi : y.toReal ≤ (hi : ℝ))
    (hgap : 1 / 2 ≤ |y.toReal| ∨ |y.toReal| ≤ 1 / 2 - (2 : ℝ) ^ (-24 : ℤ)) :
    ∃ k : ℤ, lo ≤ k ∧ k ≤ hi ∧
      (Libc.genericNearestInt false mode y).isFinite = true ∧
      (Libc.genericNearestInt false mode y).toReal = (k : ℝ) ∧
      |y.toReal - (k : ℝ)| ≤ 1 / 2 ∧
      (|y.toReal| ≤ 1 / 2 - (2 : ℝ) ^ (-24 : ℤ) → k = 0) := by
  have hlo_r : (-4194304 : ℝ) ≤ (lo : ℝ) := by exact_mod_cast hlo_ge
  have hhi_r : (hi : ℝ) ≤ 4194304 := by exact_mod_cast hhi_le
  have hneg_limit_fin : (Model.neg limit32).isFinite = true := by
    simpa using isFinite_limit32
  have hneg_limit_real : (Model.neg limit32).toReal = -16777216 := by
    rw [Model.toReal_neg limit32 isFinite_limit32, toReal_limit32]
  have hflt_lim : Libc.flt y limit32 = true :=
    (flt_iff_toReal_lt_binary32 hy_fin isFinite_limit32).mpr (by rw [toReal_limit32]; linarith)
  have hfgt_nlim : Libc.fgt y (Model.neg limit32) = true :=
    (fgt_iff_toReal_gt_binary32 hy_fin hneg_limit_fin).mpr (by rw [hneg_limit_real]; linarith)
  set r : Model .binary32 :=
    if Libc.flt y (Model.posZero .binary32) then
      Model.add (Model.sub y magic32 mode) magic32 mode
    else
      Model.sub (Model.add y magic32 mode) magic32 mode with hr_def
  have hr_spec : ∃ r0 : ℤ, r.isFinite = true ∧ r.toReal = (r0 : ℝ) ∧
      (r0 = ⌊y.toReal⌋ ∨ r0 = ⌈y.toReal⌉) ∧ lo ≤ r0 ∧ r0 ≤ hi := by
    have hz_fin : (Model.posZero .binary32).isFinite = true := by decide +kernel
    have hz_real : (Model.posZero .binary32).toReal = 0 := by simp
    by_cases hneg : Libc.flt y (Model.posZero .binary32) = true
    · have hy_lt0 : y.toReal < 0 := by
        have := (flt_iff_toReal_lt_binary32 hy_fin hz_fin).mp hneg; rwa [hz_real] at this
      have hs_bound : |y.toReal - magic32.toReal| ≤ (Model.posMaxFinite .binary32).toReal := by
        rw [toReal_magic32, abs_of_neg (by linarith)]
        linarith [posMaxFinite_binary32_ge_2p24]
      obtain ⟨hs_fin, hs_round⟩ := Model.sub_finite_roundAt (mode := mode) (by decide) hy_fin
        isFinite_magic32 hs_bound
      have hs_abs_lo : 8388608 ≤ |y.toReal - magic32.toReal| := by
        rw [toReal_magic32, abs_of_neg (by linarith)]; linarith
      have hs_abs_hi : |y.toReal - magic32.toReal| < 16777216 := by
        rw [toReal_magic32, abs_of_neg (by linarith)]; linarith
      obtain ⟨m, hm_eq, hm_fc⟩ :=
        roundAt_eq_floor_or_ceil_of_binade_binary32 mode hs_abs_lo hs_abs_hi
      set r0 : ℤ := m + 8388608
      have hr0_fc : r0 = ⌊y.toReal⌋ ∨ r0 = ⌈y.toReal⌉ := by
        rw [toReal_magic32] at hm_fc
        have hfl : ⌊y.toReal - 8388608⌋ = ⌊y.toReal⌋ - 8388608 := by simp
        have hce : ⌈y.toReal - 8388608⌉ = ⌈y.toReal⌉ - 8388608 := by simp
        rcases hm_fc with h | h
        · left; omega
        · right; omega
      have hr0_lo : lo ≤ r0 := by
        rcases hr0_fc with h | h <;> rw [h]
        · exact Int.le_floor.mpr hy_lo
        · exact (Int.le_floor.mpr hy_lo).trans (Int.floor_le_ceil y.toReal)
      have hr0_hi : r0 ≤ hi := by
        rcases hr0_fc with h | h <;> rw [h]
        · exact (Int.floor_le_ceil y.toReal).trans (Int.ceil_le.mpr hy_hi)
        · exact Int.ceil_le.mpr hy_hi
      have hadd_real : (Model.sub y magic32 mode).toReal + magic32.toReal = (r0 : ℝ) := by
        rw [hs_round, hm_eq, toReal_magic32]; push_cast [r0]; ring
      have hadd_bound : |(Model.sub y magic32 mode).toReal + magic32.toReal| ≤
          (Model.posMaxFinite .binary32).toReal := by
        rw [hadd_real]
        have hr0_abs : |(r0 : ℝ)| ≤ 4194304 := abs_le.mpr ⟨by
          have : (-4194304 : ℤ) ≤ r0 := by omega
          exact_mod_cast this, by
          have : r0 ≤ 4194304 := by omega
          exact_mod_cast this⟩
        linarith [posMaxFinite_binary32_ge_2p24]
      obtain ⟨hfin, hround⟩ := Model.add_finite_roundAt (mode := mode) (by decide) hs_fin
        isFinite_magic32 hadd_bound
      have hexact := roundAt_intCast_binary32 mode (n := r0) (by omega) (by omega)
      have hr_eq : r = Model.add (Model.sub y magic32 mode) magic32 mode := by
        simp only [hr_def, hneg, ↓reduceIte]
      refine ⟨r0, ?_, ?_, hr0_fc, hr0_lo, hr0_hi⟩
      · rw [hr_eq]; exact hfin
      · rw [hr_eq, hround, hadd_real, hexact]
    · have hy_ge0 : 0 ≤ y.toReal := by
        by_contra hlt; push Not at hlt
        exact hneg ((flt_iff_toReal_lt_binary32 hy_fin hz_fin).mpr (by rwa [hz_real]))
      have hs_bound : |y.toReal + magic32.toReal| ≤ (Model.posMaxFinite .binary32).toReal := by
        rw [toReal_magic32, abs_of_nonneg (by linarith)]
        linarith [posMaxFinite_binary32_ge_2p24]
      obtain ⟨hs_fin, hs_round⟩ := Model.add_finite_roundAt (mode := mode) (by decide) hy_fin
        isFinite_magic32 hs_bound
      have hs_abs_lo : 8388608 ≤ |y.toReal + magic32.toReal| := by
        rw [toReal_magic32, abs_of_nonneg (by linarith)]; linarith
      have hs_abs_hi : |y.toReal + magic32.toReal| < 16777216 := by
        rw [toReal_magic32, abs_of_nonneg (by linarith)]; linarith
      obtain ⟨m, hm_eq, hm_fc⟩ :=
        roundAt_eq_floor_or_ceil_of_binade_binary32 mode hs_abs_lo hs_abs_hi
      set r0 : ℤ := m - 8388608
      have hr0_fc : r0 = ⌊y.toReal⌋ ∨ r0 = ⌈y.toReal⌉ := by
        rw [toReal_magic32] at hm_fc
        have hfl : ⌊y.toReal + 8388608⌋ = ⌊y.toReal⌋ + 8388608 := by simp
        have hce : ⌈y.toReal + 8388608⌉ = ⌈y.toReal⌉ + 8388608 := by simp
        rcases hm_fc with h | h
        · left; omega
        · right; omega
      have hr0_lo : lo ≤ r0 := by
        rcases hr0_fc with h | h <;> rw [h]
        · exact Int.le_floor.mpr hy_lo
        · exact (Int.le_floor.mpr hy_lo).trans (Int.floor_le_ceil y.toReal)
      have hr0_hi : r0 ≤ hi := by
        rcases hr0_fc with h | h <;> rw [h]
        · exact (Int.floor_le_ceil y.toReal).trans (Int.ceil_le.mpr hy_hi)
        · exact Int.ceil_le.mpr hy_hi
      have hsub_real : (Model.add y magic32 mode).toReal - magic32.toReal = (r0 : ℝ) := by
        rw [hs_round, hm_eq, toReal_magic32]; push_cast [r0]; ring
      have hsub_bound : |(Model.add y magic32 mode).toReal - magic32.toReal| ≤
          (Model.posMaxFinite .binary32).toReal := by
        rw [hsub_real]
        have hr0_abs : |(r0 : ℝ)| ≤ 4194304 := abs_le.mpr ⟨by
          have : (-4194304 : ℤ) ≤ r0 := by omega
          exact_mod_cast this, by
          have : r0 ≤ 4194304 := by omega
          exact_mod_cast this⟩
        linarith [posMaxFinite_binary32_ge_2p24]
      obtain ⟨hfin, hround⟩ := Model.sub_finite_roundAt (mode := mode) (by decide) hs_fin
        isFinite_magic32 hsub_bound
      have hexact := roundAt_intCast_binary32 mode (n := r0) (by omega) (by omega)
      have hneg_f : Libc.flt y (Model.posZero .binary32) = false := Bool.eq_false_iff.mpr hneg
      have hr_eq : r = Model.sub (Model.add y magic32 mode) magic32 mode := by
        simp only [hr_def, hneg_f, Bool.false_eq_true, ↓reduceIte]
      refine ⟨r0, ?_, ?_, hr0_fc, hr0_lo, hr0_hi⟩
      · rw [hr_eq]; exact hfin
      · rw [hr_eq, hround, hsub_real, hexact]
  obtain ⟨r0, hr_fin, hr_real, hr0_fc, hr0_lo, hr0_hi⟩ := hr_spec
  have hy_sub_r0_lt1 : |y.toReal - (r0 : ℝ)| < 1 := by
    rw [abs_lt]
    rcases hr0_fc with rfl | rfl
    · exact ⟨by linarith [Int.floor_le y.toReal], by linarith [Int.lt_floor_add_one y.toReal]⟩
    · exact ⟨by linarith [Int.ceil_lt_add_one y.toReal], by linarith [Int.le_ceil y.toReal]⟩
  set diff : Model .binary32 := Model.sub y r mode with hdiff_def
  have hdiff_bound : |y.toReal - r.toReal| ≤ (Model.posMaxFinite .binary32).toReal := by
    rw [hr_real]; linarith [posMaxFinite_binary32_ge_2p24]
  obtain ⟨hdiff_fin, hdiff_round⟩ := Model.sub_finite_roundAt (mode := mode) (by decide) hy_fin
    hr_fin hdiff_bound
  have hone_fin : (Model.posOne .binary32).isFinite = true := Model.isFinite_posOne .binary32
  have hone_real : (Model.posOne .binary32).toReal = 1 := Model.toReal_posOne .binary32
  have hnhalf_fin : (Model.neg half32).isFinite = true := by simpa using isFinite_half32
  have hnhalf_real : (Model.neg half32).toReal = -(1 / 2) := by
    rw [Model.toReal_neg half32 isFinite_half32, toReal_half32]
  have hni_eq : Libc.genericNearestInt false mode y =
      if Libc.fgt diff half32 then Model.add r (Model.posOne .binary32) mode
      else if Libc.flt diff (Model.neg half32) then Model.sub r (Model.posOne .binary32) mode
      else r := by
    simp only [Libc.genericNearestInt, hflt_lim, hfgt_nlim, Bool.and_self, ↓reduceIte]
    rfl
  have hr_add1 : (Model.add r (Model.posOne .binary32) mode).isFinite = true ∧
      (Model.add r (Model.posOne .binary32) mode).toReal = ((r0 + 1 : ℤ) : ℝ) := by
    have hb : |r.toReal + (Model.posOne .binary32).toReal| ≤
        (Model.posMaxFinite .binary32).toReal := by
      rw [hr_real, hone_real]
      have h1 : |(r0 : ℝ) + 1| ≤ 4194305 := abs_le.mpr ⟨by
        have : (-4194304 : ℤ) ≤ r0 := by omega
        linarith [show (-4194304 : ℝ) ≤ r0 by exact_mod_cast this], by
        have : r0 ≤ 4194304 := by omega
        linarith [show (r0 : ℝ) ≤ 4194304 by exact_mod_cast this]⟩
      linarith [posMaxFinite_binary32_ge_2p24]
    obtain ⟨hf, hr'⟩ := Model.add_finite_roundAt (mode := mode) (by decide) hr_fin hone_fin hb
    refine ⟨hf, ?_⟩
    rw [hr', hr_real, hone_real, show (r0 : ℝ) + 1 = ((r0 + 1 : ℤ) : ℝ) by push_cast; ring]
    exact roundAt_intCast_binary32 mode (by omega) (by omega)
  have hr_sub1 : (Model.sub r (Model.posOne .binary32) mode).isFinite = true ∧
      (Model.sub r (Model.posOne .binary32) mode).toReal = ((r0 - 1 : ℤ) : ℝ) := by
    have hb : |r.toReal - (Model.posOne .binary32).toReal| ≤
        (Model.posMaxFinite .binary32).toReal := by
      rw [hr_real, hone_real]
      have h1 : |(r0 : ℝ) - 1| ≤ 4194305 := abs_le.mpr ⟨by
        have : (-4194304 : ℤ) ≤ r0 := by omega
        linarith [show (-4194304 : ℝ) ≤ r0 by exact_mod_cast this], by
        have : r0 ≤ 4194304 := by omega
        linarith [show (r0 : ℝ) ≤ 4194304 by exact_mod_cast this]⟩
      linarith [posMaxFinite_binary32_ge_2p24]
    obtain ⟨hf, hr'⟩ := Model.sub_finite_roundAt (mode := mode) (by decide) hr_fin hone_fin hb
    refine ⟨hf, ?_⟩
    rw [hr', hr_real, hone_real, show (r0 : ℝ) - 1 = ((r0 - 1 : ℤ) : ℝ) by push_cast; ring]
    exact roundAt_intCast_binary32 mode (by omega) (by omega)
  rcases hgap with hy_ge | hy_tiny
  · have hdiff_exact : diff.toReal = y.toReal - (r0 : ℝ) := by
      rw [hdiff_def, hdiff_round, hr_real]
      exact Model.roundAt_of_genericFormat .binary32
        (genericRepresentable_sub_floor_or_ceil_binary32 y hy_fin hy_ge
          (by omega) (by omega) hr0_fc) mode
    have hnot_tiny : ¬(|y.toReal| ≤ 1 / 2 - (2 : ℝ) ^ (-24 : ℤ)) := by
      have : (0 : ℝ) < (2 : ℝ) ^ (-24 : ℤ) := by positivity
      linarith
    by_cases hgt : Libc.fgt diff half32 = true
    · have hgt_r : 1 / 2 < y.toReal - (r0 : ℝ) := by
        have := (fgt_iff_toReal_gt_binary32 hdiff_fin isFinite_half32).mp hgt
        rwa [toReal_half32, hdiff_exact] at this
      have hk_lo : lo ≤ r0 + 1 := by omega
      have hk_hi : r0 + 1 ≤ hi := by
        have : ((r0 + 1 : ℤ) : ℝ) < ((hi + 1 : ℤ) : ℝ) := by push_cast; linarith
        have : r0 + 1 < hi + 1 := by exact_mod_cast this
        omega
      have hni' : Libc.genericNearestInt false mode y =
          Model.add r (Model.posOne .binary32) mode := by
        simp only [hni_eq, hgt, ↓reduceIte]
      refine ⟨r0 + 1, hk_lo, hk_hi, ?_, ?_, ?_, fun ht => absurd ht hnot_tiny⟩
      · rw [hni']; exact hr_add1.1
      · rw [hni']; exact hr_add1.2
      · rw [abs_le]; push_cast
        have := (abs_lt.mp hy_sub_r0_lt1).2
        constructor <;> linarith
    · have hgt_f : Libc.fgt diff half32 = false := Bool.eq_false_iff.mpr hgt
      by_cases hlt : Libc.flt diff (Model.neg half32) = true
      · have hlt_r : y.toReal - (r0 : ℝ) < -(1 / 2) := by
          have := (flt_iff_toReal_lt_binary32 hdiff_fin hnhalf_fin).mp hlt
          rwa [hnhalf_real, hdiff_exact] at this
        have hk_lo : lo ≤ r0 - 1 := by
          have : ((lo - 1 : ℤ) : ℝ) < ((r0 - 1 : ℤ) : ℝ) := by push_cast; linarith
          have : lo - 1 < r0 - 1 := by exact_mod_cast this
          omega
        have hk_hi : r0 - 1 ≤ hi := by omega
        have hni' : Libc.genericNearestInt false mode y =
            Model.sub r (Model.posOne .binary32) mode := by
          simp only [hni_eq, hgt_f, Bool.false_eq_true, ↓reduceIte, hlt]
        refine ⟨r0 - 1, hk_lo, hk_hi, ?_, ?_, ?_, fun ht => absurd ht hnot_tiny⟩
        · rw [hni']; exact hr_sub1.1
        · rw [hni']; exact hr_sub1.2
        · rw [abs_le]; push_cast
          have := (abs_lt.mp hy_sub_r0_lt1).1
          constructor <;> linarith
      · have hlt_f : Libc.flt diff (Model.neg half32) = false := Bool.eq_false_iff.mpr hlt
        have hle_half : y.toReal - (r0 : ℝ) ≤ 1 / 2 := by
          by_contra hc; push Not at hc
          exact hgt ((fgt_iff_toReal_gt_binary32 hdiff_fin isFinite_half32).mpr
            (by rw [toReal_half32, hdiff_exact]; exact hc))
        have hge_nhalf : -(1 / 2) ≤ y.toReal - (r0 : ℝ) := by
          by_contra hc; push Not at hc
          exact hlt ((flt_iff_toReal_lt_binary32 hdiff_fin hnhalf_fin).mpr
            (by rw [hnhalf_real, hdiff_exact]; exact hc))
        have hni' : Libc.genericNearestInt false mode y = r := by
          simp only [hni_eq, hgt_f, hlt_f, Bool.false_eq_true, ↓reduceIte]
        refine ⟨r0, hr0_lo, hr0_hi, ?_, ?_, abs_le.mpr ⟨hge_nhalf, hle_half⟩,
          fun ht => absurd ht hnot_tiny⟩
        · rw [hni']; exact hr_fin
        · rw [hni']; exact hr_real
  · have hy_lt_half : |y.toReal| < 1 / 2 := by
      have : (0 : ℝ) < (2 : ℝ) ^ (-24 : ℤ) := by positivity
      linarith
    have hy_bounds := abs_le.mp hy_tiny
    have hr0_cases : r0 = -1 ∨ r0 = 0 ∨ r0 = 1 := by
      rcases hr0_fc with rfl | rfl
      · have h1 : (-1 : ℤ) ≤ ⌊y.toReal⌋ :=
          Int.le_floor.mpr (by norm_num; linarith [abs_lt.mp hy_lt_half])
        have h2 : ⌊y.toReal⌋ ≤ 0 := by
          have := Int.floor_le y.toReal
          have : (⌊y.toReal⌋ : ℝ) < 1 := by linarith [(abs_lt.mp hy_lt_half).2]
          have : ⌊y.toReal⌋ < 1 := by exact_mod_cast this
          omega
        omega
      · have h1 : (0 : ℤ) ≤ ⌈y.toReal⌉ := by
          have := Int.le_ceil y.toReal
          have : (-1 : ℝ) < (⌈y.toReal⌉ : ℝ) := by linarith [(abs_lt.mp hy_lt_half).1]
          have : -1 < ⌈y.toReal⌉ := by exact_mod_cast this
          omega
        have h2 : ⌈y.toReal⌉ ≤ 1 :=
          Int.ceil_le.mpr (by norm_num; linarith [abs_lt.mp hy_lt_half])
        omega
    have hkf_zero : (Libc.genericNearestInt false mode y).isFinite = true ∧
        (Libc.genericNearestInt false mode y).toReal = (0 : ℝ) := by
      rcases hr0_cases with rfl | rfl | rfl
      · have hdiff_ge : 1 / 2 + (2 : ℝ) ^ (-24 : ℤ) ≤ diff.toReal := by
          rw [hdiff_def, hdiff_round, hr_real]
          have hmono := Model.roundAt_mono .binary32
            (x := (Model.ofNatBits 0x3F000001 : Model .binary32).toReal)
            (y := y.toReal - ((-1 : ℤ) : ℝ))
            (by rw [toReal_0x3F000001]; push_cast; linarith) mode
          rw [Model.roundAt_of_genericFormat .binary32
            (Model.toReal_genericFormat_of_isFinite _ isFinite_0x3F000001) mode,
            toReal_0x3F000001] at hmono
          exact hmono
        have hgt : Libc.fgt diff half32 = true :=
          (fgt_iff_toReal_gt_binary32 hdiff_fin isFinite_half32).mpr (by
            rw [toReal_half32]
            have : (0 : ℝ) < (2 : ℝ) ^ (-24 : ℤ) := by positivity
            linarith)
        have hni' : Libc.genericNearestInt false mode y =
            Model.add r (Model.posOne .binary32) mode := by
          simp only [hni_eq, hgt, ↓reduceIte]
        rw [hni']
        exact ⟨hr_add1.1, by rw [hr_add1.2]; norm_num⟩
      · have hdiff_eq : diff.toReal = y.toReal := by
          rw [hdiff_def, hdiff_round, hr_real]
          simpa using Model.roundAt_of_genericFormat .binary32
            (Model.toReal_genericFormat_of_isFinite y hy_fin) mode
        have hgt_f : Libc.fgt diff half32 = false := Bool.eq_false_iff.mpr fun h => by
          have := (fgt_iff_toReal_gt_binary32 hdiff_fin isFinite_half32).mp h
          rw [toReal_half32, hdiff_eq] at this
          linarith [(abs_lt.mp hy_lt_half).2]
        have hlt_f : Libc.flt diff (Model.neg half32) = false := Bool.eq_false_iff.mpr fun h => by
          have := (flt_iff_toReal_lt_binary32 hdiff_fin hnhalf_fin).mp h
          rw [hnhalf_real, hdiff_eq] at this
          linarith [(abs_lt.mp hy_lt_half).1]
        have hni' : Libc.genericNearestInt false mode y = r := by
          simp only [hni_eq, hgt_f, hlt_f, Bool.false_eq_true, ↓reduceIte]
        rw [hni']
        exact ⟨hr_fin, by simpa using hr_real⟩
      · have hdiff_le : diff.toReal ≤ -(1 / 2) - (2 : ℝ) ^ (-24 : ℤ) := by
          rw [hdiff_def, hdiff_round, hr_real]
          have hmono := Model.roundAt_mono .binary32
            (x := y.toReal - ((1 : ℤ) : ℝ))
            (y := (Model.ofNatBits 0xBF000001 : Model .binary32).toReal)
            (by rw [toReal_0xBF000001]; push_cast; linarith) mode
          rw [Model.roundAt_of_genericFormat .binary32
            (Model.toReal_genericFormat_of_isFinite _ isFinite_0xBF000001) mode,
            toReal_0xBF000001] at hmono
          exact hmono
        have hpos24 : (0 : ℝ) < (2 : ℝ) ^ (-24 : ℤ) := by positivity
        have hgt_f : Libc.fgt diff half32 = false := Bool.eq_false_iff.mpr fun h => by
          have := (fgt_iff_toReal_gt_binary32 hdiff_fin isFinite_half32).mp h
          rw [toReal_half32] at this; linarith
        have hlt : Libc.flt diff (Model.neg half32) = true :=
          (flt_iff_toReal_lt_binary32 hdiff_fin hnhalf_fin).mpr (by rw [hnhalf_real]; linarith)
        have hni' : Libc.genericNearestInt false mode y =
            Model.sub r (Model.posOne .binary32) mode := by
          simp only [hni_eq, hgt_f, Bool.false_eq_true, ↓reduceIte, hlt]
        rw [hni']
        exact ⟨hr_sub1.1, by rw [hr_sub1.2]; norm_num⟩
    exact ⟨0, hlo_le0, hhi_ge0, hkf_zero.1, by simpa using hkf_zero.2,
      by simpa using hy_lt_half.le, fun _ => rfl⟩

/-- Exact non-FMA power-of-two `submul` reduction: when `c = 2⁻ᵖ` (`p ≤ 126`), `kf = k` is an
integer with `|k| ≤ 2²³`, and `|2^p · x - k| ≤ 1/2`, then `submul(x, kf, 2⁻ᵖ) = x - k · 2⁻ᵖ` is
exact in binary32 across all four rounding modes (by Sterbenz's lemma). -/
theorem submul_invPow2_exact_binary32 (cfg : Libc.MathConfig) (mode : IEEERoundingMode)
    (hcfg_fma : cfg.hasFma .binary32 = false) (hcfg_rn : cfg.assumeRoundNearestOnly = false)
    (x kf c : Model .binary32) (p : ℕ) (hp : p ≤ 126) {k : ℤ}
    (hx_fin : x.isFinite = true) (hkf_fin : kf.isFinite = true) (hkf_real : kf.toReal = (k : ℝ))
    (hc_fin : c.isFinite = true) (hc_val : c.toReal = (2 : ℝ) ^ (-(p : ℤ)))
    (hk_abs : |(k : ℝ)| ≤ 8388608)
    (hnear : |(2 : ℝ) ^ p * x.toReal - (k : ℝ)| ≤ 1 / 2) :
    let rem := submul[cfg, mode](x, kf, c)
    rem.isFinite = true ∧
      rem.toReal = x.toReal - (k : ℝ) * (2 : ℝ) ^ (-(p : ℤ)) ∧
      |rem.toReal| ≤ (2 : ℝ) ^ (-(p : ℤ) - 1) := by
  open FloatLib.Floats.Formats.Flocq in
  have hsubmul_eq : submul[cfg, mode](x, kf, c) =
      Model.add x (Model.mul (Model.neg kf) c mode) mode :=
    Libc.subMultiply_of_noFma_directed hcfg_fma hcfg_rn mode x kf c
  have hnkf_fin : (Model.neg kf).isFinite = true := by simpa using hkf_fin
  have hnkf_real : (Model.neg kf).toReal = -(k : ℝ) := by
    rw [Model.toReal_neg kf hkf_fin, hkf_real]
  have h2p_pos : (0 : ℝ) < (2 : ℝ) ^ p := by positivity
  have h2mp_pos : (0 : ℝ) < (2 : ℝ) ^ (-(p : ℤ)) := by positivity
  have h2mp_le1 : (2 : ℝ) ^ (-(p : ℤ)) ≤ 1 := by
    calc (2 : ℝ) ^ (-(p : ℤ)) ≤ (2 : ℝ) ^ (0 : ℤ) := zpow_le_zpow_right₀ (by norm_num) (by omega)
      _ = 1 := by norm_num
  have hp_bound : |(Model.neg kf).toReal * c.toReal| ≤ (Model.posMaxFinite .binary32).toReal := by
    rw [hnkf_real, hc_val, abs_mul, abs_neg, abs_of_pos h2mp_pos]
    have hmul : |(k : ℝ)| * (2 : ℝ) ^ (-(p : ℤ)) ≤ 8388608 * 1 :=
      mul_le_mul hk_abs h2mp_le1 h2mp_pos.le (by norm_num)
    linarith [posMaxFinite_binary32_ge_2p24]
  obtain ⟨hp_fin, hp_round⟩ := Model.mul_finite_roundAt (mode := mode) (by decide) hnkf_fin
    hc_fin hp_bound
  have hbpow_mp : bpow FloatLib.Numerics.binaryRadix (-(p : ℤ)) = (2 : ℝ) ^ (-(p : ℤ)) := by
    rw [bpow_binaryRadix]
  have hp_gen : GenericRepresentable FloatLib.Numerics.binaryRadix (Model.fexpOf .binary32)
      ((Model.neg kf).toReal * bpow FloatLib.Numerics.binaryRadix (-(p : ℤ))) := by
    apply Model.genericFormat_mul_bpow .binary32
      (Model.toReal_genericFormat_of_isFinite (Model.neg kf) hnkf_fin) (-(p : ℤ))
    by_cases hk0 : k = 0
    · right; left; rw [hnkf_real, hk0]; simp
    · right; right
      have hk1 : (1 : ℝ) ≤ |(k : ℝ)| := by
        have : (1 : ℤ) ≤ |k| := Int.one_le_abs hk0
        exact_mod_cast this
      rw [Model.minNormalAt, bpow_binaryRadix, hnkf_real, hbpow_mp, abs_mul, abs_neg,
        abs_of_pos h2mp_pos]
      have hmin : (2 : ℝ) ^ FloatFormat.binary32.minNormalExponent ≤ (2 : ℝ) ^ (-(p : ℤ)) := by
        have : FloatFormat.binary32.minNormalExponent = -126 := rfl
        rw [this]
        exact zpow_le_zpow_right₀ (by norm_num) (by omega)
      calc (2 : ℝ) ^ FloatFormat.binary32.minNormalExponent
          ≤ (2 : ℝ) ^ (-(p : ℤ)) := hmin
        _ = 1 * (2 : ℝ) ^ (-(p : ℤ)) := (one_mul _).symm
        _ ≤ |(k : ℝ)| * (2 : ℝ) ^ (-(p : ℤ)) := mul_le_mul_of_nonneg_right hk1 h2mp_pos.le
  have hp_real : (Model.mul (Model.neg kf) c mode).toReal = -(k : ℝ) * (2 : ℝ) ^ (-(p : ℤ)) := by
    rw [hp_round, hc_val, ← hbpow_mp,
      Model.roundAt_of_genericFormat .binary32 hp_gen mode, hnkf_real, hbpow_mp]
  have h2p_inv : (2 : ℝ) ^ p * (2 : ℝ) ^ (-(p : ℤ)) = 1 := by
    rw [← zpow_natCast, ← zpow_add₀ (by norm_num)]; simp
  have hrem_eq : x.toReal - (k : ℝ) * (2 : ℝ) ^ (-(p : ℤ)) =
      ((2 : ℝ) ^ p * x.toReal - (k : ℝ)) * (2 : ℝ) ^ (-(p : ℤ)) := by
    calc x.toReal - (k : ℝ) * (2 : ℝ) ^ (-(p : ℤ))
        = x.toReal * ((2 : ℝ) ^ p * (2 : ℝ) ^ (-(p : ℤ))) - (k : ℝ) * (2 : ℝ) ^ (-(p : ℤ)) := by
            rw [h2p_inv, mul_one]
      _ = ((2 : ℝ) ^ p * x.toReal - (k : ℝ)) * (2 : ℝ) ^ (-(p : ℤ)) := by ring
  have hrem_abs : |x.toReal - (k : ℝ) * (2 : ℝ) ^ (-(p : ℤ))| ≤ (2 : ℝ) ^ (-(p : ℤ) - 1) := by
    rw [hrem_eq, abs_mul, abs_of_pos h2mp_pos]
    calc |(2 : ℝ) ^ p * x.toReal - (k : ℝ)| * (2 : ℝ) ^ (-(p : ℤ))
        ≤ (1 / 2) * (2 : ℝ) ^ (-(p : ℤ)) := mul_le_mul_of_nonneg_right hnear h2mp_pos.le
      _ = (2 : ℝ) ^ (-(p : ℤ) - 1) := by
          have hhalf : (1 / 2 : ℝ) = (2 : ℝ) ^ (-1 : ℤ) := by norm_num
          rw [hhalf, ← zpow_add₀ (by norm_num)]; congr 1; omega
  have hrem_le_one : (2 : ℝ) ^ (-(p : ℤ) - 1) ≤ 1 := by
    calc (2 : ℝ) ^ (-(p : ℤ) - 1) ≤ (2 : ℝ) ^ (0 : ℤ) :=
          zpow_le_zpow_right₀ (by norm_num) (by omega)
      _ = 1 := by norm_num
  have hadd_bound : |x.toReal + (Model.mul (Model.neg kf) c mode).toReal| ≤
      (Model.posMaxFinite .binary32).toReal := by
    rw [hp_real, show x.toReal + -(k : ℝ) * (2 : ℝ) ^ (-(p : ℤ)) =
        x.toReal - (k : ℝ) * (2 : ℝ) ^ (-(p : ℤ)) by ring]
    linarith [posMaxFinite_binary32_ge_2p24]
  obtain ⟨hrem_fin, hrem_round⟩ := Model.add_finite_roundAt (mode := mode) (by decide) hx_fin
    hp_fin hadd_bound
  have hx_gen := Model.toReal_genericFormat_of_isFinite x hx_fin
  have hp_gen' : GenericRepresentable FloatLib.Numerics.binaryRadix (Model.fexpOf .binary32)
      (-(k : ℝ) * (2 : ℝ) ^ (-(p : ℤ))) := by
    rw [← hp_real]; exact Model.toReal_genericFormat_of_isFinite _ hp_fin
  have hk_gen : GenericRepresentable FloatLib.Numerics.binaryRadix (Model.fexpOf .binary32)
      ((k : ℝ) * (2 : ℝ) ^ (-(p : ℤ))) := by
    have := genericRepresentable_neg (-(k : ℝ) * (2 : ℝ) ^ (-(p : ℤ))) hp_gen'
    simpa [neg_mul] using this
  have hprec : (0 : ℤ) < (FloatFormat.binary32.fracWidth : ℤ) + 1 := by decide
  have hrem_gen : GenericRepresentable FloatLib.Numerics.binaryRadix (Model.fexpOf .binary32)
      (x.toReal - (k : ℝ) * (2 : ℝ) ^ (-(p : ℤ))) := by
    have hnb := abs_le.mp hnear
    have hlo_x : ((k : ℝ) - 1 / 2) * (2 : ℝ) ^ (-(p : ℤ)) ≤ x.toReal := by
      have h1 := mul_le_mul_of_nonneg_right (by linarith : (k : ℝ) - 1 / 2 ≤ (2 : ℝ) ^ p * x.toReal)
        h2mp_pos.le
      have h2 : (2 : ℝ) ^ p * x.toReal * (2 : ℝ) ^ (-(p : ℤ)) = x.toReal := by
        calc (2 : ℝ) ^ p * x.toReal * (2 : ℝ) ^ (-(p : ℤ))
            = x.toReal * ((2 : ℝ) ^ p * (2 : ℝ) ^ (-(p : ℤ))) := by ring
          _ = x.toReal := by rw [h2p_inv, mul_one]
      linarith
    have hhi_x : x.toReal ≤ ((k : ℝ) + 1 / 2) * (2 : ℝ) ^ (-(p : ℤ)) := by
      have h1 := mul_le_mul_of_nonneg_right (by linarith : (2 : ℝ) ^ p * x.toReal ≤ (k : ℝ) + 1 / 2)
        h2mp_pos.le
      have h2 : (2 : ℝ) ^ p * x.toReal * (2 : ℝ) ^ (-(p : ℤ)) = x.toReal := by
        calc (2 : ℝ) ^ p * x.toReal * (2 : ℝ) ^ (-(p : ℤ))
            = x.toReal * ((2 : ℝ) ^ p * (2 : ℝ) ^ (-(p : ℤ))) := by ring
          _ = x.toReal := by rw [h2p_inv, mul_one]
      linarith
    rcases lt_trichotomy k 0 with hk_neg | rfl | hk_pos
    · have hk1 : (k : ℝ) ≤ -1 := by exact_mod_cast Int.le_sub_one_of_lt hk_neg
      have h1 : -x.toReal ≤ 2 * (-(k : ℝ) * (2 : ℝ) ^ (-(p : ℤ))) := by
        have hstep := mul_le_mul_of_nonneg_right (by linarith : -(k : ℝ) + 1 / 2 ≤ 2 * -(k : ℝ))
          h2mp_pos.le
        have : -((k : ℝ) - 1 / 2) * (2 : ℝ) ^ (-(p : ℤ)) =
            (-(k : ℝ) + 1 / 2) * (2 : ℝ) ^ (-(p : ℤ)) := by ring
        linarith [show -x.toReal ≤ -((k : ℝ) - 1 / 2) * (2 : ℝ) ^ (-(p : ℤ)) by linarith]
      have h2 : -(k : ℝ) * (2 : ℝ) ^ (-(p : ℤ)) ≤ 2 * (-x.toReal) := by
        have hstep := mul_le_mul_of_nonneg_right (by linarith : -(k : ℝ) ≤ 2 * (-(k : ℝ) - 1 / 2))
          h2mp_pos.le
        have : 2 * (-((k : ℝ) + 1 / 2) * (2 : ℝ) ^ (-(p : ℤ))) =
            2 * (-(k : ℝ) - 1 / 2) * (2 : ℝ) ^ (-(p : ℤ)) := by ring
        linarith [show -((k : ℝ) + 1 / 2) * (2 : ℝ) ^ (-(p : ℤ)) ≤ -x.toReal by linarith]
      have hnx_gen : GenericRepresentable FloatLib.Numerics.binaryRadix (Model.fexpOf .binary32)
          (-x.toReal) := genericRepresentable_neg x.toReal hx_gen
      have hst : GenericRepresentable FloatLib.Numerics.binaryRadix (Model.fexpOf .binary32)
          (-x.toReal - -(k : ℝ) * (2 : ℝ) ^ (-(p : ℤ))) :=
        genericRepresentable_flt_sterbenz FloatFormat.binary32.minSubnormalExponent
          ((FloatFormat.binary32.fracWidth : ℤ) + 1) hprec h1 h2 hnx_gen hp_gen'
      have hneg := genericRepresentable_neg (-x.toReal - -(k : ℝ) * (2 : ℝ) ^ (-(p : ℤ))) hst
      have heq : -(-x.toReal - -(k : ℝ) * (2 : ℝ) ^ (-(p : ℤ))) =
          x.toReal - (k : ℝ) * (2 : ℝ) ^ (-(p : ℤ)) := by ring
      rwa [heq] at hneg
    · simpa using hx_gen
    · have hk1 : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk_pos
      have h1 : x.toReal ≤ 2 * ((k : ℝ) * (2 : ℝ) ^ (-(p : ℤ))) := by
        have hstep := mul_le_mul_of_nonneg_right (by linarith : (k : ℝ) + 1 / 2 ≤ 2 * (k : ℝ))
          h2mp_pos.le
        linarith [show 2 * (k : ℝ) * (2 : ℝ) ^ (-(p : ℤ)) =
          2 * ((k : ℝ) * (2 : ℝ) ^ (-(p : ℤ))) by ring]
      have h2 : (k : ℝ) * (2 : ℝ) ^ (-(p : ℤ)) ≤ 2 * x.toReal := by
        have hstep := mul_le_mul_of_nonneg_right (by linarith : (k : ℝ) ≤ 2 * ((k : ℝ) - 1 / 2))
          h2mp_pos.le
        linarith [show 2 * ((k : ℝ) - 1 / 2) * (2 : ℝ) ^ (-(p : ℤ)) =
          2 * (((k : ℝ) - 1 / 2) * (2 : ℝ) ^ (-(p : ℤ))) by ring]
      exact genericRepresentable_flt_sterbenz FloatFormat.binary32.minSubnormalExponent
        ((FloatFormat.binary32.fracWidth : ℤ) + 1) hprec h1 h2 hx_gen hk_gen
  dsimp only
  rw [hsubmul_eq]
  refine ⟨hrem_fin, ?_, ?_⟩
  · rw [hrem_round, hp_real, show x.toReal + -(k : ℝ) * (2 : ℝ) ^ (-(p : ℤ)) =
        x.toReal - (k : ℝ) * (2 : ℝ) ^ (-(p : ℤ)) by ring]
    exact Model.roundAt_of_genericFormat .binary32 hrem_gen mode
  · rw [hrem_round, hp_real, show x.toReal + -(k : ℝ) * (2 : ℝ) ^ (-(p : ℤ)) =
        x.toReal - (k : ℝ) * (2 : ℝ) ^ (-(p : ℤ)) by ring,
      Model.roundAt_of_genericFormat .binary32 hrem_gen mode]
    exact hrem_abs

/-- Widening any finite binary32 float `x` with `|x| ≤ posMaxFinite .binary64` to binary64 is
exact in every IEEE rounding mode. -/
theorem fpCast_binary32_to_binary64_exact (mode : IEEERoundingMode) (x : Model .binary32)
    (hx_fin : x.isFinite = true)
    (hx_bound : |x.toReal| ≤ (Model.posMaxFinite .binary64).toReal) :
    (Libc.fpCast .binary64 mode x).isFinite = true ∧
      (Libc.fpCast .binary64 mode x).toReal = x.toReal := by
  obtain ⟨d, hd⟩ := Model.exists_toDyadic?_of_isFinite hx_fin
  have hreal : x.toReal = d.toReal := by rw [Model.toReal_eq, hd]
  have hcast : Libc.fpCast .binary64 mode x =
      Model.Internal.Directed.roundDyadic .binary64 mode d := by
    rw [Libc.fpCast]
    exact KernelPath.cast_of_finite mode x d hd (by decide)
  have hsig : d.significand < 2 ^ (FloatFormat.binary64.fracWidth + 1) := by
    have h32 := Model.toDyadic?_significand_lt x hd
    exact lt_trans h32 (by decide)
  have hexp : FloatFormat.binary64.minSubnormalExponent ≤ d.exponent := by
    have h32 := Model.minSubnormalExponent_le_toDyadic? x hd
    have hle : FloatFormat.binary64.minSubnormalExponent ≤
        FloatFormat.binary32.minSubnormalExponent := by decide
    omega
  have hbound : |d.toReal| ≤ (Model.posMaxFinite .binary64).toReal := by rwa [← hreal]
  rw [hcast, hreal]
  exact Model.Internal.Directed.roundDyadic_of_representable .binary64 (by decide) mode d
    hsig hexp hbound

/-- Converting any finite binary32 integer `k` in `[-2³¹, 2³¹ - 1]` via `Libc.fptosi? 32` is
defined and returns `some (BitVec.ofInt 32 k)`. -/
theorem fptosi_int_binary32_eq (kf : Model .binary32) {k : ℤ}
    (hkf_fin : kf.isFinite = true) (hkf_real : kf.toReal = (k : ℝ))
    (hk_lo : -2147483648 ≤ k) (hk_hi : k ≤ 2147483647) :
    Libc.fptosi? 32 kf = some (BitVec.ofInt 32 k) := by
  obtain ⟨d, hd⟩ := Model.exists_toDyadic?_of_isFinite hkf_fin
  have hexact : Model.exactValue kf = .finite d := Model.exactValue_eq_finite_iff.mpr hd
  have hd_real : d.toReal = (k : ℝ) := by rw [← hkf_real, Model.toReal_eq, hd]
  have htz : (if 0 ≤ d.toReal then ⌊d.toReal⌋ else ⌈d.toReal⌉) = k := by
    rw [hd_real, Int.floor_intCast, Int.ceil_intCast, ite_self]
  have hrange : FloatLib.Numerics.Representations.FixedInt.InRange 32
      (if 0 ≤ d.toReal then ⌊d.toReal⌋ else ⌈d.toReal⌉) := by
    rw [htz]
    change (BitVec.intMin 32).toInt ≤ k ∧ k ≤ (BitVec.intMax 32).toInt
    have hmin : (BitVec.intMin 32).toInt = -2147483648 := by decide
    have hmax : (BitVec.intMax 32).toInt = 2147483647 := by decide
    omega
  have hconvExact := ExecDType.convertToIntegerExact_towardZero_of_exactValue_eq_finite_of_inRange
    (width := 32) kf d hexact hrange
  have hconv := ExecDType.convertToInteger_of_convertToIntegerExact_eq_success hconvExact
  rw [htz] at hconv
  simp only [Libc.fptosi?, hconv, FloatLib.Numerics.Representations.FixedInt.ofInt]

/-! ### Axiom checks -/

/--
info: 'LibcMath.Analysis.RangeReduction.genericNearestInt_binary32_spec' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms genericNearestInt_binary32_spec

/--
info: 'LibcMath.Analysis.RangeReduction.submul_invPow2_exact_binary32' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms submul_invPow2_exact_binary32

/--
info: 'LibcMath.Analysis.RangeReduction.fpCast_binary32_to_binary64_exact' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fpCast_binary32_to_binary64_exact

/--
info: 'LibcMath.Analysis.RangeReduction.fptosi_int_binary32_eq' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms fptosi_int_binary32_eq

end LibcMath.Analysis.RangeReduction
