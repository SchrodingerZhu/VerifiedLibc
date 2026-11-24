import LibcMath.Libc.Ops
import LibcMath.Analysis.RoundingRanges
import FloatLib.Floats.Formats.BinaryInterchange.Conversion.Cast.Proof
import FloatLib.Floats.Formats.BinaryInterchange.DirectedSemantics.Positive
import FloatLib.Floats.Formats.BinaryInterchange.DirectedSemantics.Rounded
import FloatLib.Floats.Formats.BinaryInterchange.Dyadic.RoundingKernel.Proof

/-!
# Rounding transfer from binary64 approximations to binary32

This module connects the final narrowing cast of `Expf.Generated.DoubleEval.expf` to the real-valued
specification `Model.roundReal .binary32`:

* `fpCast_binary32_eq_roundReal`: for a positive finite binary64 value `v` bounded by
  `posMaxFinite .binary32`, `Libc.fpCast .binary32 mode v` equals
  `Model.roundReal .binary32 mode v.toReal` in every C rounding mode.
* `roundReal_eq_of_awayFromGrid`: if a positive real `y` lies in a binary32 output binade with
  half-ULP grid spacing `u` (`GridFor y u`), stays strictly farther than `ε * y` from every
  multiple of `u` (`AwayFromGrid u ε y`), and `|v - y| ≤ ε * y`, then `v` and `y` round to the
  exact same binary32 float in every C rounding mode.
* `roundReal_near_underflow_of_err`: the companion transfer on the near-underflow interval
  `(2⁻¹⁵⁰, 2⁻¹⁴⁹)`, where every point in a sufficiently tight subinterval rounds identically.
-/

namespace LibcMath.Analysis.RoundingTransfer

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

variable {mode : IEEERoundingMode}

/-! ## Narrowing cast to binary32 -/

private theorem signBit_packRoundedSubnormal (sign : Bool) (zeroResult : Model .binary32)
    (hzero : Model.signBit zeroResult = sign) (fraction : Nat) :
    Model.signBit (Model.packRoundedSubnormal .binary32 sign zeroResult fraction) = sign := by
  unfold Model.packRoundedSubnormal
  split_ifs <;> simp [hzero]

private theorem signBit_packRoundedNormal (sign : Bool) (overflow : Model .binary32)
    (hover : Model.signBit overflow = sign) (totalExponent : Int) (roundedMantissa : Nat) :
    Model.signBit (Model.packRoundedNormal .binary32 sign overflow totalExponent roundedMantissa) =
      sign := by
  unfold Model.packRoundedNormal
  dsimp only
  split_ifs <;> simp [hover]

private theorem signBit_nativeOverflow_binary32 (sign : Bool) :
    Model.signBit (Model.nativeOverflow .binary32 sign) = sign := by
  cases sign <;> decide

private theorem signBit_roundDyadicMagnitudeDown (sign : Bool) (mantissa : Nat) (exponent : Int) :
    Model.signBit (Model.roundDyadicMagnitudeDown .binary32 sign mantissa exponent) = sign := by
  unfold Model.roundDyadicMagnitudeDown
  dsimp only
  cases sign <;> split_ifs <;> simp

private theorem signBit_roundDyadicMagnitudeUp (sign : Bool) (mantissa : Nat) (exponent : Int) :
    Model.signBit (Model.roundDyadicMagnitudeUp .binary32 sign mantissa exponent) = sign := by
  unfold Model.roundDyadicMagnitudeUp
  dsimp only
  split_ifs
  · exact signBit_nativeOverflow_binary32 sign
  · simp
  · exact signBit_packRoundedSubnormal sign _ (by simp) _
  · exact signBit_packRoundedNormal sign _ (signBit_nativeOverflow_binary32 sign) _ _
  · exact signBit_packRoundedNormal sign _ (signBit_nativeOverflow_binary32 sign) _ _

private theorem signBit_roundDyadic_of_negative_eq_false (hmode : mode ∈ cModes)
    {d : FloatLib.Numerics.Dyadic} (hd : d.negative = false) :
    Model.signBit (Model.Internal.Directed.roundDyadic .binary32 mode d) = false := by
  rcases hmode with rfl | rfl | rfl | rfl
  · change Model.signBit (Model.roundDyadic .binary32 d) = false
    rw [← Model.roundDyadicGeneral_eq_roundDyadic]
    unfold Model.roundDyadicGeneral
    dsimp only
    split_ifs
    · simp [hd]
    · rw [hd]; exact signBit_nativeOverflow_binary32 false
    · rw [hd]; exact signBit_packRoundedSubnormal false _ (by simp) _
    · rw [hd]
      exact signBit_packRoundedNormal false _ (signBit_nativeOverflow_binary32 false) _ _
    · rw [hd]
      exact signBit_packRoundedNormal false _ (signBit_nativeOverflow_binary32 false) _ _
  · unfold Model.Internal.Directed.roundDyadic Model.roundDyadicTowardZero
    split_ifs
    · simp [hd]
    · rw [hd]; exact signBit_roundDyadicMagnitudeDown false _ _
  · unfold Model.Internal.Directed.roundDyadic Model.roundDyadicUp
    split_ifs
    · simp [hd]
    · simp [hd] at *
    · exact signBit_roundDyadicMagnitudeUp false _ _
  · unfold Model.Internal.Directed.roundDyadic Model.roundDyadicDown
    split_ifs
    · simp [hd]
    · simp [hd] at *
    · exact signBit_roundDyadicMagnitudeDown false _ _

private theorem cast_binary64_binary32_of_finite (mode : IEEERoundingMode) (v : Model .binary64)
    {d : FloatLib.Numerics.Dyadic} (hd : Model.toDyadic? v = some d) :
    Model.cast .binary64 .binary32 v mode =
      Model.Internal.Directed.roundDyadic .binary32 mode d := by
  have hnan := Model.isNaN_eq_false_of_toDyadic?_some hd
  have hinf := Model.isInfinite_eq_false_of_toDyadic?_some hd
  have hne : FloatFormat.binary64 ≠ FloatFormat.binary32 := by decide
  have hexp : FloatFormat.binary64.expWidth ≠ FloatFormat.binary32.expWidth := by decide
  rw [← Model.Internal.Directed.cast_eq]
  cases mode <;>
    simp [Model.Internal.Directed.cast, Model.Internal.Nearest.cast, hnan, hinf, hne, hexp,
      Model.finiteDyadic, hd, Model.Internal.Directed.roundDyadic]

/-- Narrowing a positive in-range finite binary64 value to binary32 agrees with `Model.roundReal`
in all four C rounding modes. -/
theorem fpCast_binary32_eq_roundReal (hmode : mode ∈ cModes) {v : Model .binary64}
    (hfin : v.isFinite = true) (hpos : 0 < v.toReal)
    (hmax : v.toReal ≤ (Model.posMaxFinite .binary32).toReal) :
    Libc.fpCast .binary32 mode v = Model.roundReal .binary32 mode v.toReal := by
  obtain ⟨d, hd⟩ := Model.exists_toDyadic?_of_isFinite hfin
  have hdreal : d.toReal = v.toReal := by
    rw [Model.toReal_eq, hd]
  have hdneg : d.negative = false := by
    cases h : d.negative
    · rfl
    · exfalso
      have hle := Model.Dyadic.toReal_nonpos_of_negative_eq_true h
      linarith
  have hcast : Libc.fpCast .binary32 mode v =
      Model.Internal.Directed.roundDyadic .binary32 mode d :=
    cast_binary64_binary32_of_finite mode v hd
  have hbound : |d.toReal| ≤ (Model.posMaxFinite .binary32).toReal := by
    rw [hdreal, abs_of_pos hpos]
    exact hmax
  obtain ⟨hfinCast, hvalCast⟩ :=
    Model.Internal.Directed.roundDyadic_finite_roundAt .binary32 rfl mode d hbound
  have hrt := Model.roundReal_roundsTo (fmt := .binary32) mode (ne_of_gt hpos)
  have hroundNonneg : 0 ≤ Model.roundAt .binary32 v.toReal mode := by
    simpa only [Model.roundAt_zero] using Model.roundAt_mono .binary32 hpos.le mode
  have hroundLe : Model.roundAt .binary32 v.toReal mode ≤
      (Model.posMaxFinite .binary32).toReal := by
    have hmono := Model.roundAt_mono .binary32 hmax mode
    rwa [Model.roundAt_of_genericFormat .binary32
      (Model.toReal_genericFormat_of_isFinite _ (Model.isFinite_posMaxFinite .binary32)) mode] at
      hmono
  have hroundBound : |Model.roundAt .binary32 v.toReal mode| ≤
      (Model.posMaxFinite .binary32).toReal := by
    rw [abs_of_nonneg hroundNonneg]
    exact hroundLe
  obtain ⟨hfinRR, hvalRR⟩ := hrt.finite hroundBound
  rw [hcast]
  refine Model.eq_of_toReal_eq hfinCast hfinRR (by rw [hvalCast, hdreal, hvalRR]) ?_
  intro _
  rw [signBit_roundDyadic_of_negative_eq_false hmode hdneg, hrt.signBit_of_isIEEE rfl,
    decide_eq_false (not_lt.mpr hpos.le)]

/-! ## Unified binary32 half-ULP grid and rounding transfer -/

/-- The half-ULP grid spacing `u` covering every binary32 float and midpoint in the binade
containing `y`: `u = 2^(E - 24)` for normal `y ∈ [2^E, 2^(E+1)]` (`-126 ≤ E ≤ 127`),
and `u = 2^-150` for subnormal `y ∈ [2^-150, 2^-126]`. -/
def GridFor (y u : ℝ) : Prop :=
  (∃ E : ℤ, -126 ≤ E ∧ E ≤ 127 ∧ (2 : ℝ) ^ E ≤ y ∧ y ≤ (2 : ℝ) ^ (E + 1) ∧
    u = (2 : ℝ) ^ (E - 24)) ∨
  ((2 : ℝ) ^ (-150 : ℤ) ≤ y ∧ y ≤ (2 : ℝ) ^ (-126 : ℤ) ∧ u = (2 : ℝ) ^ (-150 : ℤ))

/-- `y` stays strictly farther than `ε * y` from every integer multiple of `u`. -/
def AwayFromGrid (u ε y : ℝ) : Prop :=
  ∀ k : ℤ, ε * y < |y - (k : ℝ) * u|

private theorem roundReal_eq_of_pos_of_roundAt_eq {fmt : FloatFormat} (hfmt : fmt.isIEEE = true)
    (mode : IEEERoundingMode) {v y : ℝ} (hvpos : 0 < v) (hypos : 0 < y)
    (hround : Model.roundAt fmt v mode = Model.roundAt fmt y mode) :
    Model.roundReal fmt mode v = Model.roundReal fmt mode y := by
  have hv := Model.roundReal_roundsTo (fmt := fmt) mode (ne_of_gt hvpos)
  have hy := Model.roundReal_roundsTo (fmt := fmt) mode (ne_of_gt hypos)
  have hsv : decide (v < 0) = false := decide_eq_false (not_lt.mpr hvpos.le)
  have hsy : decide (y < 0) = false := decide_eq_false (not_lt.mpr hypos.le)
  by_cases hrange : |Model.roundAt fmt y mode| ≤ (Model.posMaxFinite fmt).toReal
  · obtain ⟨hfv, hvv⟩ := hv.finite (hround ▸ hrange)
    obtain ⟨hfy, hvy⟩ := hy.finite hrange
    exact Model.eq_of_toReal_eq hfv hfy (by rw [hvv, hvy, hround])
      (fun _ => by rw [hv.signBit_of_isIEEE hfmt, hy.signBit_of_isIEEE hfmt, hsv, hsy])
  · have hov := not_le.mp hrange
    rw [hv.overflow (hround ▸ hov), hy.overflow hov, hsv, hsy]

private theorem cexp_binary32_of_normal {E : ℤ} (hElo : -126 ≤ E) {z : ℝ}
    (hlo : (2 : ℝ) ^ E ≤ z) (hhi : z < (2 : ℝ) ^ (E + 1)) :
    FloatLib.Floats.Formats.Flocq.cexp FloatLib.Numerics.binaryRadix
      (Model.fexpOf .binary32) z = E - 23 := by
  have hzpos : 0 < z := lt_of_lt_of_le (zpow_pos (by norm_num) E) hlo
  have hmag : FloatLib.Floats.Formats.Flocq.magnitude FloatLib.Numerics.binaryRadix z = E + 1 := by
    apply FloatLib.Floats.Formats.Flocq.magnitude_eq_of_bpow_bounds
    · rw [abs_of_pos hzpos, FloatLib.Floats.Formats.Flocq.bpow_binaryRadix]
      simpa using hlo
    · rw [abs_of_pos hzpos, FloatLib.Floats.Formats.Flocq.bpow_binaryRadix]
      exact hhi
  change FloatLib.Floats.Formats.Flocq.fltExp
    FloatFormat.binary32.minSubnormalExponent (FloatFormat.binary32.fracWidth + 1)
    (FloatLib.Floats.Formats.Flocq.magnitude FloatLib.Numerics.binaryRadix z) = E - 23
  rw [hmag]
  have hmin : FloatFormat.binary32.minSubnormalExponent = (-149 : ℤ) := rfl
  have hfrac : (FloatFormat.binary32.fracWidth : ℤ) = 23 := rfl
  rw [FloatLib.Floats.Formats.Flocq.fltExp, hmin, hfrac]
  omega

private theorem cexp_binary32_of_subnormal {e : ℤ} (he : e ≤ -126) {z : ℝ}
    (hzpos : 0 < z) (hhi : z < (2 : ℝ) ^ e) :
    FloatLib.Floats.Formats.Flocq.cexp FloatLib.Numerics.binaryRadix
      (Model.fexpOf .binary32) z = -149 := by
  have hmag : FloatLib.Floats.Formats.Flocq.magnitude FloatLib.Numerics.binaryRadix z ≤ e := by
    apply FloatLib.Floats.Formats.Flocq.magnitude_le_of_abs_lt_bpow _ _ _ hzpos.ne'
    rw [abs_of_pos hzpos, FloatLib.Floats.Formats.Flocq.bpow_binaryRadix]
    exact hhi
  change FloatLib.Floats.Formats.Flocq.fltExp
    FloatFormat.binary32.minSubnormalExponent (FloatFormat.binary32.fracWidth + 1)
    (FloatLib.Floats.Formats.Flocq.magnitude FloatLib.Numerics.binaryRadix z) = -149
  have hmin : FloatFormat.binary32.minSubnormalExponent = (-149 : ℤ) := rfl
  have hfrac : (FloatFormat.binary32.fracWidth : ℤ) = 23 := rfl
  rw [FloatLib.Floats.Formats.Flocq.fltExp, hmin, hfrac]
  omega

private theorem roundAt_eq_of_open_halfUlp_cell (mode : IEEERoundingMode) {c k : ℤ} {v y : ℝ}
    (hcexpV : FloatLib.Floats.Formats.Flocq.cexp FloatLib.Numerics.binaryRadix
      (Model.fexpOf .binary32) v = c)
    (hcexpY : FloatLib.Floats.Formats.Flocq.cexp FloatLib.Numerics.binaryRadix
      (Model.fexpOf .binary32) y = c)
    (hvlo : (k : ℝ) * (2 : ℝ) ^ (c - 1) < v)
    (hvhi : v < ((k + 1 : ℤ) : ℝ) * (2 : ℝ) ^ (c - 1))
    (hylo : (k : ℝ) * (2 : ℝ) ^ (c - 1) < y)
    (hyhi : y < ((k + 1 : ℤ) : ℝ) * (2 : ℝ) ^ (c - 1)) :
    Model.roundAt .binary32 v mode = Model.roundAt .binary32 y mode := by
  have hscale : ∀ z : ℝ,
      FloatLib.Floats.Formats.Flocq.cexp FloatLib.Numerics.binaryRadix
        (Model.fexpOf .binary32) z = c →
      (k : ℝ) * (2 : ℝ) ^ (c - 1) < z →
      z < ((k + 1 : ℤ) : ℝ) * (2 : ℝ) ^ (c - 1) →
      (k : ℝ) / 2 < FloatLib.Floats.Formats.Flocq.scaledMantissa FloatLib.Numerics.binaryRadix
        (Model.fexpOf .binary32) z ∧
      FloatLib.Floats.Formats.Flocq.scaledMantissa FloatLib.Numerics.binaryRadix
        (Model.fexpOf .binary32) z < ((k + 1 : ℤ) : ℝ) / 2 := by
    intro z hcz hzlo hzhi
    rw [FloatLib.Floats.Formats.Flocq.scaledMantissa, hcz,
      FloatLib.Floats.Formats.Flocq.bpow_binaryRadix]
    have hpow : (2 : ℝ) ^ (c - 1) * (2 : ℝ) ^ (-c) = (2 : ℝ)⁻¹ := by
      rw [← zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0), show c - 1 + -c = (-1 : ℤ) by omega]
      norm_num
    have hpos : (0 : ℝ) < (2 : ℝ) ^ (-c) := zpow_pos (by norm_num) (-c)
    constructor
    · calc (k : ℝ) / 2 = (k : ℝ) * (2 : ℝ) ^ (c - 1) * (2 : ℝ) ^ (-c) := by
            rw [mul_assoc, hpow, div_eq_mul_inv]
        _ < z * (2 : ℝ) ^ (-c) := mul_lt_mul_of_pos_right hzlo hpos
    · calc z * (2 : ℝ) ^ (-c)
          < ((k + 1 : ℤ) : ℝ) * (2 : ℝ) ^ (c - 1) * (2 : ℝ) ^ (-c) :=
            mul_lt_mul_of_pos_right hzhi hpos
        _ = ((k + 1 : ℤ) : ℝ) / 2 := by
            rw [mul_assoc, hpow, div_eq_mul_inv]
  obtain ⟨hv1, hv2⟩ := hscale v hcexpV hvlo hvhi
  obtain ⟨hy1, hy2⟩ := hscale y hcexpY hylo hyhi
  rcases Int.even_or_odd k with ⟨m, rfl⟩ | ⟨m, rfl⟩
  · have hloc : ∀ s : ℝ, ((m + m : ℤ) : ℝ) / 2 < s → s < ((m + m + 1 : ℤ) : ℝ) / 2 →
        FloatLib.Floats.Formats.Flocq.InbetweenInt m s (.inexact .lt) := by
      intro s hs1 hs2
      push_cast at hs1 hs2
      refine .inexact .lt ⟨by linarith, by push_cast; linarith⟩ ?_
      rw [cmp_eq_lt_iff]
      push_cast
      linarith
    exact Model.roundAt_eq_of_scaledBracket .binary32 mode (hcexpV.trans hcexpY.symm)
      (hloc _ hv1 hv2) (hloc _ hy1 hy2)
  · have hloc : ∀ s : ℝ, ((2 * m + 1 : ℤ) : ℝ) / 2 < s → s < ((2 * m + 1 + 1 : ℤ) : ℝ) / 2 →
        FloatLib.Floats.Formats.Flocq.InbetweenInt m s (.inexact .gt) := by
      intro s hs1 hs2
      push_cast at hs1 hs2
      refine .inexact .gt ⟨by linarith, by push_cast; linarith⟩ ?_
      rw [cmp_eq_gt_iff]
      push_cast
      linarith
    exact Model.roundAt_eq_of_scaledBracket .binary32 mode (hcexpV.trans hcexpY.symm)
      (hloc _ hv1 hv2) (hloc _ hy1 hy2)

private theorem roundReal_eq_of_subnormal_grid (mode : IEEERoundingMode)
    {v y u ε : ℝ} {e1 e2 : ℤ} (he1 : e1 = -150) (he2 : e2 = -126)
    (hvpos : 0 < v) (hpos : 0 < y) (hεy : 0 ≤ ε * y)
    (hsubHi : y ≤ (2 : ℝ) ^ e2) (hu : u = (2 : ℝ) ^ e1)
    (haway : AwayFromGrid u ε y)
    (hcell : 0 < u →
      let k : ℤ := ⌊y / u⌋
      (k : ℝ) * u < v ∧ v < ((k + 1 : ℤ) : ℝ) * u ∧
      (k : ℝ) * u < y ∧ y < ((k + 1 : ℤ) : ℝ) * u) :
    Model.roundReal .binary32 mode v = Model.roundReal .binary32 mode y := by
  subst hu
  have hupos : (0 : ℝ) < (2 : ℝ) ^ e1 := zpow_pos (by norm_num) e1
  obtain ⟨hvlo, hvhi, hylo, hyhi⟩ := hcell hupos
  set k : ℤ := ⌊y / (2 : ℝ) ^ e1⌋
  have hhighEq : ((2 ^ 24 : ℤ) : ℝ) * (2 : ℝ) ^ e1 = (2 : ℝ) ^ e2 := by
    have h24 : ((2 ^ 24 : ℤ) : ℝ) = (2 : ℝ) ^ (24 : ℤ) := by norm_num
    rw [h24, ← zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0)]
    congr 1
    omega
  have hyStrict : y < (2 : ℝ) ^ e2 := by
    rcases lt_or_eq_of_le hsubHi with hlt | heq
    · exact hlt
    · exfalso
      have h := haway (2 ^ 24)
      rw [hhighEq, heq, sub_self, abs_zero] at h
      rw [heq] at hεy
      linarith
  have hkhi : k + 1 ≤ 2 ^ 24 := by
    have hlt : k < 2 ^ 24 := by
      apply Int.floor_lt.mpr
      rw [div_lt_iff₀ hupos, hhighEq]
      exact hyStrict
    omega
  have hkhiR : ((k + 1 : ℤ) : ℝ) * (2 : ℝ) ^ e1 ≤ (2 : ℝ) ^ e2 := by
    rw [← hhighEq]
    exact mul_le_mul_of_nonneg_right (by exact_mod_cast hkhi) hupos.le
  have hcexpV : FloatLib.Floats.Formats.Flocq.cexp FloatLib.Numerics.binaryRadix
      (Model.fexpOf .binary32) v = e1 + 1 := by
    rw [cexp_binary32_of_subnormal (he2 ▸ le_rfl) hvpos (hvhi.trans_le hkhiR)]
    omega
  have hcexpY : FloatLib.Floats.Formats.Flocq.cexp FloatLib.Numerics.binaryRadix
      (Model.fexpOf .binary32) y = e1 + 1 := by
    rw [cexp_binary32_of_subnormal (he2 ▸ le_rfl) hpos (hyhi.trans_le hkhiR)]
    omega
  have hcEq : (2 : ℝ) ^ (e1 + 1 - 1) = (2 : ℝ) ^ e1 := by
    congr 1
    omega
  have hround := roundAt_eq_of_open_halfUlp_cell mode (c := e1 + 1) (k := k) hcexpV hcexpY
    (hcEq.symm ▸ hvlo) (hcEq.symm ▸ hvhi) (hcEq.symm ▸ hylo) (hcEq.symm ▸ hyhi)
  exact roundReal_eq_of_pos_of_roundAt_eq rfl mode hvpos hpos hround

/-- If `y` lies in a binary32 output binade with half-ULP grid `u`, stays strictly farther than
`ε * y` from `ℤ · u`, and `|v - y| ≤ ε * y`, then `v` and `y` round to the exact same binary32
float in every C rounding mode. -/
theorem roundReal_eq_of_awayFromGrid (hmode : mode ∈ cModes)
    {v y u ε : ℝ} (hpos : 0 < y) (hε : 0 ≤ ε) (hεlt : ε < 1 / 2)
    (hverr : |v - y| ≤ ε * y)
    (hgrid : GridFor y u) (haway : AwayFromGrid u ε y) :
    Model.roundReal .binary32 mode v = Model.roundReal .binary32 mode y := by
  have _ := hmode
  have hvbounds : y - ε * y ≤ v ∧ v ≤ y + ε * y := by
    have h := abs_le.mp hverr
    exact ⟨by linarith, by linarith⟩
  have hvpos : 0 < v := by nlinarith
  have hεy : 0 ≤ ε * y := mul_nonneg hε hpos.le
  have hcell : 0 < u →
      let k : ℤ := ⌊y / u⌋
      (k : ℝ) * u < v ∧ v < ((k + 1 : ℤ) : ℝ) * u ∧
      (k : ℝ) * u < y ∧ y < ((k + 1 : ℤ) : ℝ) * u := by
    intro hupos
    dsimp only
    set k : ℤ := ⌊y / u⌋
    have hkle : (k : ℝ) * u ≤ y := (le_div_iff₀ hupos).mp (Int.floor_le (y / u))
    have hklt : y < ((k + 1 : ℤ) : ℝ) * u := by
      push_cast
      exact (div_lt_iff₀ hupos).mp (Int.lt_floor_add_one (y / u))
    have hloA : ε * y < y - (k : ℝ) * u := by
      have h := haway k
      rwa [abs_of_nonneg (sub_nonneg.mpr hkle)] at h
    have hhiA : ε * y < ((k + 1 : ℤ) : ℝ) * u - y := by
      have h := haway (k + 1)
      rw [abs_of_neg (sub_neg.mpr hklt), neg_sub] at h
      exact h
    exact ⟨by linarith, by linarith, by linarith, by linarith⟩
  rcases hgrid with ⟨E, hElo, _, hEyle, hyEle, rfl⟩ | ⟨_, hsubHi, hu⟩
  · have hupos : (0 : ℝ) < (2 : ℝ) ^ (E - 24) := zpow_pos (by norm_num) (E - 24)
    obtain ⟨hvlo, hvhi, hylo, hyhi⟩ := hcell hupos
    set k : ℤ := ⌊y / (2 : ℝ) ^ (E - 24)⌋
    have hlowEq : ((2 ^ 24 : ℤ) : ℝ) * (2 : ℝ) ^ (E - 24) = (2 : ℝ) ^ E := by
      have h24 : ((2 ^ 24 : ℤ) : ℝ) = (2 : ℝ) ^ (24 : ℤ) := by norm_num
      rw [h24, ← zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0)]
      congr 1
      omega
    have hhighEq : ((2 ^ 25 : ℤ) : ℝ) * (2 : ℝ) ^ (E - 24) = (2 : ℝ) ^ (E + 1) := by
      have h25 : ((2 ^ 25 : ℤ) : ℝ) = (2 : ℝ) ^ (25 : ℤ) := by norm_num
      rw [h25, ← zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0)]
      congr 1
      omega
    have hklo : (2 ^ 24 : ℤ) ≤ k := by
      apply Int.le_floor.mpr
      rw [le_div_iff₀ hupos, hlowEq]
      exact hEyle
    have hyStrict : y < (2 : ℝ) ^ (E + 1) := by
      rcases lt_or_eq_of_le hyEle with hlt | heq
      · exact hlt
      · exfalso
        have h := haway (2 ^ 25)
        rw [hhighEq, heq, sub_self, abs_zero] at h
        rw [heq] at hεy
        linarith
    have hkhi : k + 1 ≤ 2 ^ 25 := by
      have hlt : k < 2 ^ 25 := by
        apply Int.floor_lt.mpr
        rw [div_lt_iff₀ hupos, hhighEq]
        exact hyStrict
      omega
    have hkloR : (2 : ℝ) ^ E ≤ (k : ℝ) * (2 : ℝ) ^ (E - 24) := by
      rw [← hlowEq]
      exact mul_le_mul_of_nonneg_right (by exact_mod_cast hklo) hupos.le
    have hkhiR : ((k + 1 : ℤ) : ℝ) * (2 : ℝ) ^ (E - 24) ≤ (2 : ℝ) ^ (E + 1) := by
      rw [← hhighEq]
      exact mul_le_mul_of_nonneg_right (by exact_mod_cast hkhi) hupos.le
    have hcexpV := cexp_binary32_of_normal hElo (hkloR.trans hvlo.le) (hvhi.trans_le hkhiR)
    have hcexpY := cexp_binary32_of_normal hElo (hkloR.trans hylo.le) (hyhi.trans_le hkhiR)
    have hsubEq : (2 : ℝ) ^ (E - 23 - 1) = (2 : ℝ) ^ (E - 24) := by congr 1; omega
    have hround := roundAt_eq_of_open_halfUlp_cell mode (c := E - 23) (k := k) hcexpV hcexpY
      (hsubEq.symm ▸ hvlo) (hsubEq.symm ▸ hvhi) (hsubEq.symm ▸ hylo) (hsubEq.symm ▸ hyhi)
    exact roundReal_eq_of_pos_of_roundAt_eq rfl mode hvpos hpos hround
  · exact roundReal_eq_of_subnormal_grid mode rfl rfl hvpos hpos hεy hsubHi hu haway hcell

/-! ## Near-underflow transfer -/

/-- On the near-underflow interval `(2⁻¹⁵⁰, 2⁻¹⁴⁹)`, any relative error of at most `2 · 10⁻¹⁵`
preserves binary32 rounding in all four C rounding modes. -/
theorem roundReal_near_underflow_of_err (hmode : mode ∈ cModes) {v y : ℝ}
    (hlo : 1 / 2 ^ 150 * (1 + 1 / 2 ^ 21) ≤ y)
    (hhi : y ≤ 1 / 2 ^ 149 * (1 / (1 + 1 / 2 ^ 21)))
    (hverr : |v - y| ≤ (2 / 10 ^ 15 : ℝ) * y) :
    Model.roundReal .binary32 mode v = Model.roundReal .binary32 mode y := by
  have hvbounds := abs_le.mp hverr
  have hloV : ((1 / 2 ^ 150 * (1 + 1 / 2 ^ 22) : ℚ) : ℝ) ≤ v := by push_cast; linarith
  have hhiV : v ≤ ((1 / 2 ^ 149 * (1 / (1 + 1 / 2 ^ 22)) : ℚ) : ℝ) := by push_cast; linarith
  have hloY : ((1 / 2 ^ 150 * (1 + 1 / 2 ^ 22) : ℚ) : ℝ) ≤ y := by push_cast; linarith
  have hhiY : y ≤ ((1 / 2 ^ 149 * (1 / (1 + 1 / 2 ^ 22)) : ℚ) : ℝ) := by push_cast; linarith
  have hconst : ∀ z : ℝ, ((1 / 2 ^ 150 * (1 + 1 / 2 ^ 22) : ℚ) : ℝ) ≤ z →
      z ≤ ((1 / 2 ^ 149 * (1 / (1 + 1 / 2 ^ 22)) : ℚ) : ℝ) →
      Model.roundReal .binary32 mode z =
        if mode = .towardZero ∨ mode = .down then Model.posZero .binary32
        else Model.posMinSubnormal .binary32 := by
    intro z hloZ hhiZ
    rcases hmode with rfl | rfl | rfl | rfl <;>
      exact roundReal_eq_of_mem_Icc_rat rfl _ (lo := 1 / 2 ^ 150 * (1 + 1 / 2 ^ 22))
        (hi := 1 / 2 ^ 149 * (1 / (1 + 1 / 2 ^ 22))) (by norm_num) hloZ hhiZ
        (by decide +kernel) (by decide +kernel)
  exact (hconst v hloV hhiV).trans (hconst y hloY hhiY).symm

/-! ### Axioms -/

/--
info: 'LibcMath.Analysis.RoundingTransfer.fpCast_binary32_eq_roundReal' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fpCast_binary32_eq_roundReal

/--
info: 'LibcMath.Analysis.RoundingTransfer.roundReal_eq_of_awayFromGrid' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms roundReal_eq_of_awayFromGrid

/--
info: 'LibcMath.Analysis.RoundingTransfer.roundReal_near_underflow_of_err' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms roundReal_near_underflow_of_err

end LibcMath.Analysis.RoundingTransfer
