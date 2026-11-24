import FloatLib.Floats.Formats.BinaryInterchange.Algebraic.Rounding.DirectedEnclosureProof
import FloatLib.Floats.Formats.BinaryInterchange.Analysis.MixedError.Attribute
import LibcMath.Libc.Ops

/-!
# Reusable binary64 Horner and relative-error propagation lemmas

Function-independent error bounds for binary64 polynomial evaluation and final product assembly
across all four IEEE 754 rounding directions (`cModes`):

* `unitRoundoffIn_binary64_le`, `underflowErrorIn_binary64_le`, `minNormalAt_binary64_le`,
  `four_le_posMaxFinite_binary64`, `pow_150_le_posMaxFinite_binary64` — format constants.
* `hornerStep_binary64` — one non-FMA binary64 Horner step `add (mul xd acc mode) c mode` for
  arbitrary argument bound `bx` and intermediate range ceiling `bmax`.
* `mul_rel_bounds`, `round_rel_bounds`, `fmul_one_left_of_pos_binary64` — relative-error
  propagation across products and floating-point roundings.
-/

namespace LibcMath.Analysis.Horner

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc

/-- Every rounding mode in binary64 has unit roundoff at most `2⁻⁵²` (worst-case directed ULP). -/
theorem unitRoundoffIn_binary64_le (mode : IEEERoundingMode) :
    Model.unitRoundoffIn .binary64 mode ≤ (1 / 2 ^ 52 : ℝ) := by
  rw [Model.unitRoundoffIn, Model.unitRoundoffAt_eq]
  have hhalf : (mode.halfUlps : ℝ) ≤ 2 := by
    cases mode <;> norm_num [Model.IEEERoundingMode.halfUlps]
  have hfrac : (FloatFormat.binary64.fracWidth : ℤ) = 52 := by decide
  rw [hfrac]
  have hpos : (0 : ℝ) ≤ (2 : ℝ) ^ (-(52 + 1 : ℤ)) := by positivity
  calc (mode.halfUlps : ℝ) * (2 : ℝ) ^ (-(52 + 1 : ℤ))
      ≤ 2 * (2 : ℝ) ^ (-(52 + 1 : ℤ)) := mul_le_mul_of_nonneg_right hhalf hpos
    _ = (1 / 2 ^ 52 : ℝ) := by norm_num

/-- Every rounding mode has underflow error at most twice the nearest-mode underflow bound. -/
theorem underflowErrorIn_le_two_mul (fmt : FloatFormat) (mode : IEEERoundingMode) :
    Model.underflowErrorIn fmt mode ≤ 2 * Model.underflowErrorAt fmt := by
  rw [Model.underflowErrorIn]
  have hhalf : (mode.halfUlps : ℝ) ≤ 2 := by
    cases mode <;> norm_num [Model.IEEERoundingMode.halfUlps]
  exact mul_le_mul_of_nonneg_right hhalf (Model.underflowErrorAt_pos fmt).le

/-- Binary64 directed underflow error is far smaller than `2⁻⁷⁰`. -/
theorem underflowErrorIn_binary64_le (mode : IEEERoundingMode) :
    Model.underflowErrorIn .binary64 mode ≤ (1 / 2 ^ 70 : ℝ) := by
  have huf : Model.underflowErrorAt .binary64 ≤ (2 : ℝ) ^ (-71 : ℤ) :=
    Model.underflowErrorAt_le_zpow .binary64 (by
      simp [FloatFormat.minSubnormalExponent, FloatFormat.minNormalExponent, FloatFormat.binary64])
  calc Model.underflowErrorIn .binary64 mode
      ≤ 2 * Model.underflowErrorAt .binary64 := underflowErrorIn_le_two_mul .binary64 mode
    _ ≤ 2 * (2 : ℝ) ^ (-71 : ℤ) := mul_le_mul_of_nonneg_left huf (by norm_num)
    _ = (1 / 2 ^ 70 : ℝ) := by norm_num

/-- `minNormalAt .binary64 = 2⁻¹⁰²² ≤ 2^e` for any `e ≥ -1022`. -/
theorem minNormalAt_binary64_le (e : ℤ) (he : -1022 ≤ e) :
    Model.minNormalAt .binary64 ≤ (2 : ℝ) ^ e := by
  change FloatLib.Floats.Formats.Flocq.bpow FloatLib.Numerics.binaryRadix
    (FloatFormat.minNormalExponent .binary64) ≤ (2 : ℝ) ^ e
  simp only [FloatLib.Floats.Formats.Flocq.bpow, FloatLib.Numerics.binaryRadix,
    FloatLib.Numerics.Radix.toReal]
  have hexp : FloatFormat.minNormalExponent .binary64 = -1022 := by decide
  rw [hexp, Nat.cast_ofNat]
  exact zpow_le_zpow_right₀ (by norm_num) he

/-- `4 ≤ posMaxFinite .binary64`. -/
theorem four_le_posMaxFinite_binary64 :
    (4 : ℝ) ≤ (Model.posMaxFinite .binary64).toReal := by
  have hrat : Model.toRat? (Model.ofBits (fmt := .binary64) 0x4010000000000000#64) = some 4 := by
    decide +kernel
  have hfin := Model.Algebraic.isFinite_of_toRat?_eq_some hrat
  have hval := Model.Algebraic.toReal_of_toRat?_eq_some hrat
  have hle := Model.abs_toReal_le_posMaxFinite_of_isFinite _ hfin
  rw [hval] at hle
  simpa using hle

/-- `2¹⁵⁰ ≤ posMaxFinite .binary64`. -/
theorem pow_150_le_posMaxFinite_binary64 :
    (2 : ℝ) ^ (150 : ℤ) ≤ (Model.posMaxFinite .binary64).toReal := by
  have hrat :
      Model.toRat? (Model.ofBits (fmt := .binary64) 0x4950000000000000#64) = some (2 ^ 150) := by
    decide +kernel
  have hfin := Model.Algebraic.isFinite_of_toRat?_eq_some hrat
  have hval := Model.Algebraic.toReal_of_toRat?_eq_some hrat
  have hle := Model.abs_toReal_le_posMaxFinite_of_isFinite _ hfin
  rw [hval] at hle
  have hpos : (0 : ℝ) ≤ ((2 ^ 150 : ℚ) : ℝ) := by positivity
  rw [abs_of_nonneg hpos] at hle
  simpa using hle

/-- One non-FMA binary64 Horner step `add (mul xd acc mode) c mode` propagates magnitude and
absolute error bounds across all IEEE rounding modes whenever `|xd| ≤ bx` and intermediate
magnitudes stay within `bmax ≤ posMaxFinite .binary64`. -/
theorem hornerStep_binary64 (mode : IEEERoundingMode) {xd acc c : Model .binary64}
    {bx bmax acc0 c0 bacc eacc bc bp bs es : ℝ}
    (hbx : 0 ≤ bx) (hbmax : bmax ≤ (Model.posMaxFinite .binary64).toReal)
    (hxd_fin : xd.isFinite = true) (hxd : |xd.toReal| ≤ bx)
    (hacc_fin : acc.isFinite = true) (hacc_abs : |acc.toReal| ≤ bacc)
    (hacc_err : |acc.toReal - acc0| ≤ eacc)
    (hc_fin : c.isFinite = true) (hc_eq : c.toReal = c0) (hc_abs : |c0| ≤ bc)
    (hbp_le : (1 + 1 / (2 : ℝ) ^ 52) * (bx * bacc) + 1 / (2 : ℝ) ^ 70 ≤ bp)
    (hbp_range : bx * bacc ≤ bmax)
    (hs_range : bp + bc ≤ bmax)
    (hbs_le : (1 + 1 / (2 : ℝ) ^ 52) * (bp + bc) ≤ bs)
    (hes_le : bx * eacc + (1 / (2 : ℝ) ^ 52) * (bx * bacc) + 1 / (2 : ℝ) ^ 70 +
      (1 / (2 : ℝ) ^ 52) * (bp + bc) ≤ es) :
    let res := Model.add (Model.mul xd acc mode) c mode
    res.isFinite = true ∧
    |res.toReal| ≤ bs ∧
    |res.toReal - (c0 + xd.toReal * acc0)| ≤ es := by
  have hu : Model.unitRoundoffIn .binary64 mode ≤ 1 / (2 : ℝ) ^ 52 :=
    unitRoundoffIn_binary64_le mode
  have hη : Model.underflowErrorIn .binary64 mode ≤ 1 / (2 : ℝ) ^ 70 :=
    underflowErrorIn_binary64_le mode
  have hprod_abs : |xd.toReal * acc.toReal| ≤ bx * bacc := by
    rw [abs_mul]
    exact mul_le_mul hxd hacc_abs (abs_nonneg _) hbx
  have hprod_range : |xd.toReal * acc.toReal| ≤ (Model.posMaxFinite .binary64).toReal :=
    hprod_abs.trans (hbp_range.trans hbmax)
  set p := Model.mul xd acc mode
  have hp_fin : p.isFinite = true :=
    (Model.mul_finite_roundAt (fmt := .binary64) (mode := mode) rfl hxd_fin hacc_fin hprod_range).1
  have hp_round : |p.toReal - xd.toReal * acc.toReal| ≤
      (1 / (2 : ℝ) ^ 52) * (bx * bacc) + 1 / (2 : ℝ) ^ 70 := by
    have h := Model.abs_toReal_mul_sub_le_mode (fmt := .binary64) (mode := mode)
      rfl hxd_fin hacc_fin hprod_range
    have hmul : Model.unitRoundoffIn .binary64 mode * |xd.toReal * acc.toReal| ≤
        (1 / (2 : ℝ) ^ 52) * (bx * bacc) :=
      mul_le_mul hu hprod_abs (abs_nonneg _) (by positivity)
    linarith
  have hp_abs : |p.toReal| ≤ bp := by
    have htri : |p.toReal| ≤ |p.toReal - xd.toReal * acc.toReal| + |xd.toReal * acc.toReal| := by
      have h := abs_add_le (p.toReal - xd.toReal * acc.toReal) (xd.toReal * acc.toReal)
      simpa [sub_add_cancel] using h
    linarith
  have hp_err : |p.toReal - xd.toReal * acc0| ≤
      bx * eacc + (1 / (2 : ℝ) ^ 52) * (bx * bacc) + 1 / (2 : ℝ) ^ 70 := by
    have htri : |p.toReal - xd.toReal * acc0| ≤
        |p.toReal - xd.toReal * acc.toReal| + |xd.toReal| * |acc.toReal - acc0| := by
      have h := abs_add_le (p.toReal - xd.toReal * acc.toReal) (xd.toReal * (acc.toReal - acc0))
      rw [show p.toReal - xd.toReal * acc.toReal + xd.toReal * (acc.toReal - acc0) =
          p.toReal - xd.toReal * acc0 by ring, abs_mul] at h
      exact h
    have hprop : |xd.toReal| * |acc.toReal - acc0| ≤ bx * eacc :=
      mul_le_mul hxd hacc_err (abs_nonneg _) hbx
    linarith
  have hsum_abs : |p.toReal + c.toReal| ≤ bp + bc := by
    rw [hc_eq]
    have htri := abs_add_le p.toReal c0
    linarith
  have hsum_range : |p.toReal + c.toReal| ≤ (Model.posMaxFinite .binary64).toReal :=
    hsum_abs.trans (hs_range.trans hbmax)
  set res := Model.add p c mode
  have hres_fin : res.isFinite = true :=
    (Model.add_finite_roundAt (fmt := .binary64) (mode := mode) rfl hp_fin hc_fin hsum_range).1
  have hres_round : |res.toReal - (p.toReal + c.toReal)| ≤ (1 / (2 : ℝ) ^ 52) * (bp + bc) := by
    have h := Model.abs_toReal_add_sub_le_mode (fmt := .binary64) (mode := mode)
      rfl hp_fin hc_fin hsum_range
    exact h.trans (mul_le_mul hu hsum_abs (abs_nonneg _) (by positivity))
  have hres_abs : |res.toReal| ≤ bs := by
    have htri : |res.toReal| ≤ |res.toReal - (p.toReal + c.toReal)| + |p.toReal + c.toReal| := by
      have h := abs_add_le (res.toReal - (p.toReal + c.toReal)) (p.toReal + c.toReal)
      simpa [sub_add_cancel] using h
    linarith
  have hres_err : |res.toReal - (c0 + xd.toReal * acc0)| ≤ es := by
    have htri : |res.toReal - (c0 + xd.toReal * acc0)| ≤
        |res.toReal - (p.toReal + c.toReal)| + |p.toReal - xd.toReal * acc0| := by
      have h := abs_add_le (res.toReal - (p.toReal + c.toReal)) (p.toReal - xd.toReal * acc0)
      rw [show res.toReal - (p.toReal + c.toReal) + (p.toReal - xd.toReal * acc0) =
          res.toReal - (c0 + xd.toReal * acc0) by rw [hc_eq]; ring] at h
      exact h
    linarith
  exact ⟨hres_fin, hres_abs, hres_err⟩

/-- Propagate relative error enclosures across a product of two nonnegative approximations. -/
theorem mul_rel_bounds {a b e1 e2 d1 d2 : ℝ}
    (ha_lo : (1 - d1) * e1 ≤ a) (ha_hi : a ≤ (1 + d1) * e1)
    (hb_lo : (1 - d2) * e2 ≤ b) (hb_hi : b ≤ (1 + d2) * e2)
    (he1 : 0 ≤ e1) (he2 : 0 ≤ e2) (hd1 : 0 ≤ d1) (hd2' : d2 ≤ 1)
    (ha0 : 0 ≤ a) (hb0 : 0 ≤ b) :
    ((1 - d1) * (1 - d2)) * (e1 * e2) ≤ a * b ∧
    a * b ≤ ((1 + d1) * (1 + d2)) * (e1 * e2) := by
  constructor
  · calc ((1 - d1) * (1 - d2)) * (e1 * e2)
        = ((1 - d1) * e1) * ((1 - d2) * e2) := by ring
      _ ≤ a * b := mul_le_mul ha_lo hb_lo (mul_nonneg (by linarith) he2) ha0
  · calc a * b
        ≤ ((1 + d1) * e1) * ((1 + d2) * e2) :=
          mul_le_mul ha_hi hb_hi hb0 (mul_nonneg (by linarith) he1)
      _ = ((1 + d1) * (1 + d2)) * (e1 * e2) := by ring

/-- Propagate a relative rounding error `|v - p| ≤ u * p` onto an existing enclosure of `p`. -/
theorem round_rel_bounds {v p e u c_lo c_hi : ℝ}
    (hp_lo : c_lo * e ≤ p) (hp_hi : p ≤ c_hi * e)
    (herr : |v - p| ≤ u * p) (hu0 : 0 ≤ u) (hu : u ≤ 1) :
    ((1 - u) * c_lo) * e ≤ v ∧ v ≤ ((1 + u) * c_hi) * e := by
  have h1 := (abs_le.mp herr).1
  have h2 := (abs_le.mp herr).2
  have hv_lo : (1 - u) * p ≤ v := by linarith
  have hv_hi : v ≤ (1 + u) * p := by linarith
  constructor
  · calc ((1 - u) * c_lo) * e
        = (1 - u) * (c_lo * e) := by ring
      _ ≤ (1 - u) * p := mul_le_mul_of_nonneg_left hp_lo (by linarith)
      _ ≤ v := hv_lo
  · calc v
        ≤ (1 + u) * p := hv_hi
      _ ≤ (1 + u) * (c_hi * e) := mul_le_mul_of_nonneg_left hp_hi (by linarith)
      _ = ((1 + u) * c_hi) * e := by ring

/-- Multiplying a positive finite binary64 value by `1.0` on the left is exact in every rounding
mode. -/
theorem fmul_one_left_of_pos_binary64 (mode : IEEERoundingMode) {x : Model .binary64}
    (hfin : x.isFinite = true) (hpos : 0 < x.toReal) :
    Libc.fmul mode (Model.posOne .binary64) x = x := by
  have h1 : Model.toRat? (Model.posOne .binary64) = some 1 := by decide +kernel
  have h1fin := Model.Algebraic.isFinite_of_toRat?_eq_some h1
  have h1val : (Model.posOne .binary64).toReal = 1 := by
    rw [Model.Algebraic.toReal_of_toRat?_eq_some h1]; norm_num
  have hbound : |(Model.posOne .binary64).toReal * x.toReal| ≤
      (Model.posMaxFinite .binary64).toReal := by
    rw [h1val, one_mul]
    exact Model.abs_toReal_le_posMaxFinite_of_isFinite x hfin
  have ⟨hmfin, hmval⟩ := Model.mul_finite_roundAt (mode := mode) rfl h1fin hfin hbound
  rw [h1val, one_mul, Model.roundAt_of_genericFormat .binary64
    (Model.toReal_genericFormat_of_isFinite x hfin) mode] at hmval
  exact Model.eq_of_toReal_eq hmfin hfin hmval (fun h0 => by
    change (Model.mul (Model.posOne .binary64) x mode).toReal = 0 at h0
    linarith)

/-! ### Axiom checks -/

/--
info: 'LibcMath.Analysis.Horner.hornerStep_binary64' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms hornerStep_binary64

/--
info: 'LibcMath.Analysis.Horner.fmul_one_left_of_pos_binary64' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms fmul_one_left_of_pos_binary64

end LibcMath.Analysis.Horner
