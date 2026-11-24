import FloatLib.Floats.Formats.BinaryInterchange.Analysis.MixedError.Attribute
import LibcMath.Extracted.Expf.DoubleEval
import LibcMath.Extracted.Expf.Polynomial

/-!
# Binary64 rounding and approximation error of the `expf` Horner polynomial

On its main path, `Expf.DoubleEval.expf` evaluates a degree-4 polynomial in `xd` (`|xd| ≤ 1 / 256`)
by Horner's scheme in binary64 without FMA:
`horner[Expf.DoubleEval.config, mode] xd [c₀, c₁, c₂, c₃, c₄]`.

This file bounds the binary64 rounding error of those eight operations across all four C rounding
directions (`cModes`), combines it with `Expf.Poly.abs_poly_sub_exp_le` to bound the total error
against `Real.exp xd.toReal`, and derives tight enclosure bounds on the tiny-argument subranges
`[2⁻²⁶, 2⁻²⁴ - 2⁻⁴⁸]` and `[-2⁻²⁵ + 2⁻⁴⁹, -2⁻²⁶]`.
-/

namespace LibcMath.Extracted.Expf.HornerError

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Core.DSL

variable {mode : IEEERoundingMode}

/-- The exact Horner polynomial expression appearing in `Expf.DoubleEval.expf`. -/
def hornerExpLo (mode : IEEERoundingMode) (xd : Model .binary64) : Model .binary64 :=
  horner[Expf.DoubleEval.config, mode] xd
    [f64(0x3FF0000000000000#64), f64(0x3FEFFFFFFFFFF777#64),
     f64(0x3FE000000000071C#64), f64(0x3FC555566668E5E7#64),
     f64(0x3FA55555555EF243#64)]

/-! ### Binary64 format bounds and polynomial constants -/

private theorem unitRoundoffIn_binary64_le (mode : IEEERoundingMode) :
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

private theorem underflowErrorIn_le_two_mul (fmt : FloatFormat) (mode : IEEERoundingMode) :
    Model.underflowErrorIn fmt mode ≤ 2 * Model.underflowErrorAt fmt := by
  rw [Model.underflowErrorIn]
  have hhalf : (mode.halfUlps : ℝ) ≤ 2 := by
    cases mode <;> norm_num [Model.IEEERoundingMode.halfUlps]
  exact mul_le_mul_of_nonneg_right hhalf (Model.underflowErrorAt_pos fmt).le

private theorem underflowErrorIn_binary64_le (mode : IEEERoundingMode) :
    Model.underflowErrorIn .binary64 mode ≤ (1 / 2 ^ 70 : ℝ) := by
  have huf : Model.underflowErrorAt .binary64 ≤ (2 : ℝ) ^ (-71 : ℤ) :=
    Model.underflowErrorAt_le_zpow .binary64 (by
      simp [FloatFormat.minSubnormalExponent, FloatFormat.minNormalExponent, FloatFormat.binary64])
  calc Model.underflowErrorIn .binary64 mode
      ≤ 2 * Model.underflowErrorAt .binary64 := underflowErrorIn_le_two_mul .binary64 mode
    _ ≤ 2 * (2 : ℝ) ^ (-71 : ℤ) := mul_le_mul_of_nonneg_left huf (by norm_num)
    _ = (1 / 2 ^ 70 : ℝ) := by norm_num

private theorem four_le_posMaxFinite_binary64 :
    (4 : ℝ) ≤ (Model.posMaxFinite .binary64).toReal := by
  have hrat : Model.toRat? f64(0x4010000000000000#64) = some 4 := by decide +kernel
  have hfin := Model.Algebraic.isFinite_of_toRat?_eq_some hrat
  have hval := Model.Algebraic.toReal_of_toRat?_eq_some hrat
  have hle := Model.abs_toReal_le_posMaxFinite_of_isFinite f64(0x4010000000000000#64) hfin
  rw [hval] at hle
  simpa using hle

private theorem toRat?_c0 : Model.toRat? f64(0x3FF0000000000000#64) = some 1 := by
  decide +kernel

private theorem toRat?_c1 : Model.toRat? f64(0x3FEFFFFFFFFFF777#64) = some Expf.Poly.c₁ := by
  decide +kernel

private theorem toRat?_c2 : Model.toRat? f64(0x3FE000000000071C#64) = some Expf.Poly.c₂ := by
  decide +kernel

private theorem toRat?_c3 : Model.toRat? f64(0x3FC555566668E5E7#64) = some Expf.Poly.c₃ := by
  decide +kernel

private theorem toRat?_c4 : Model.toRat? f64(0x3FA55555555EF243#64) = some Expf.Poly.c₄ := by
  decide +kernel

/-! ### Unfolding and per-step Horner rounding error -/

private theorem hornerExpLo_eq (mode : IEEERoundingMode) (xd : Model .binary64) :
    hornerExpLo mode xd =
      Model.add (Model.mul xd
        (Model.add (Model.mul xd
          (Model.add (Model.mul xd
            (Model.add (Model.mul xd f64(0x3FA55555555EF243#64) mode)
              f64(0x3FC555566668E5E7#64) mode) mode)
            f64(0x3FE000000000071C#64) mode) mode)
          f64(0x3FEFFFFFFFFFF777#64) mode) mode)
        f64(0x3FF0000000000000#64) mode := by
  have hnoFma : Expf.DoubleEval.config.hasFma .binary64 = false := rfl
  simp only [hornerExpLo, Core.polyevalList_cons_cons, Core.polyevalList_singleton]
  change Core.multiplyAdd _ _ _ (Core.multiplyAdd _ _ _ (Core.multiplyAdd _ _ _
    (Core.multiplyAdd _ _ _ _ _) _) _) _ = _
  simp only [Core.multiplyAdd_of_noFma hnoFma]

/-- One non-FMA binary64 Horner step `add (mul xd acc mode) c mode` propagates magnitude and
absolute error bounds whenever intermediate magnitudes stay within `4`. -/
private theorem hornerStep (mode : IEEERoundingMode) {xd acc c : Model .binary64}
    {acc0 c0 bacc eacc bc bp bs es : ℝ}
    (hxd_fin : xd.isFinite = true) (hxd : |xd.toReal| ≤ 1 / 256)
    (hacc_fin : acc.isFinite = true) (hacc_abs : |acc.toReal| ≤ bacc)
    (hacc_err : |acc.toReal - acc0| ≤ eacc)
    (hc_fin : c.isFinite = true) (hc_eq : c.toReal = c0) (hc_abs : |c0| ≤ bc)
    (hbp_le : (1 + 1 / (2 : ℝ) ^ 52) * (bacc / 256) + 1 / (2 : ℝ) ^ 70 ≤ bp)
    (hbp_range : bacc / 256 ≤ 4)
    (hs_range : bp + bc ≤ 4)
    (hbs_le : (1 + 1 / (2 : ℝ) ^ 52) * (bp + bc) ≤ bs)
    (hes_le : eacc / 256 + (1 / (2 : ℝ) ^ 52) * (bacc / 256) + 1 / (2 : ℝ) ^ 70 +
      (1 / (2 : ℝ) ^ 52) * (bp + bc) ≤ es) :
    let res := Model.add (Model.mul xd acc mode) c mode
    res.isFinite = true ∧
    |res.toReal| ≤ bs ∧
    |res.toReal - (c0 + xd.toReal * acc0)| ≤ es := by
  have hu : Model.unitRoundoffIn .binary64 mode ≤ 1 / (2 : ℝ) ^ 52 :=
    unitRoundoffIn_binary64_le mode
  have hη : Model.underflowErrorIn .binary64 mode ≤ 1 / (2 : ℝ) ^ 70 :=
    underflowErrorIn_binary64_le mode
  have hprod_abs : |xd.toReal * acc.toReal| ≤ bacc / 256 := by
    rw [abs_mul]
    calc |xd.toReal| * |acc.toReal|
        ≤ (1 / 256) * bacc := mul_le_mul hxd hacc_abs (abs_nonneg _) (by norm_num)
      _ = bacc / 256 := by ring
  have hprod_range : |xd.toReal * acc.toReal| ≤ (Model.posMaxFinite .binary64).toReal :=
    hprod_abs.trans (hbp_range.trans four_le_posMaxFinite_binary64)
  set p := Model.mul xd acc mode
  have hp_fin : p.isFinite = true :=
    (Model.mul_finite_roundAt (fmt := .binary64) (mode := mode) rfl hxd_fin hacc_fin hprod_range).1
  have hp_round : |p.toReal - xd.toReal * acc.toReal| ≤
      (1 / (2 : ℝ) ^ 52) * (bacc / 256) + 1 / (2 : ℝ) ^ 70 := by
    have h := Model.abs_toReal_mul_sub_le_mode (fmt := .binary64) (mode := mode)
      rfl hxd_fin hacc_fin hprod_range
    have hmul : Model.unitRoundoffIn .binary64 mode * |xd.toReal * acc.toReal| ≤
        (1 / (2 : ℝ) ^ 52) * (bacc / 256) :=
      mul_le_mul hu hprod_abs (abs_nonneg _) (by positivity)
    linarith
  have hp_abs : |p.toReal| ≤ bp := by
    have htri : |p.toReal| ≤ |p.toReal - xd.toReal * acc.toReal| + |xd.toReal * acc.toReal| := by
      have h := abs_add_le (p.toReal - xd.toReal * acc.toReal) (xd.toReal * acc.toReal)
      simpa [sub_add_cancel] using h
    linarith
  have hp_err : |p.toReal - xd.toReal * acc0| ≤
      eacc / 256 + (1 / (2 : ℝ) ^ 52) * (bacc / 256) + 1 / (2 : ℝ) ^ 70 := by
    have htri : |p.toReal - xd.toReal * acc0| ≤
        |p.toReal - xd.toReal * acc.toReal| + |xd.toReal| * |acc.toReal - acc0| := by
      have h := abs_add_le (p.toReal - xd.toReal * acc.toReal) (xd.toReal * (acc.toReal - acc0))
      rw [show p.toReal - xd.toReal * acc.toReal + xd.toReal * (acc.toReal - acc0) =
          p.toReal - xd.toReal * acc0 by ring, abs_mul] at h
      exact h
    have hprop : |xd.toReal| * |acc.toReal - acc0| ≤ eacc / 256 := by
      calc |xd.toReal| * |acc.toReal - acc0|
          ≤ (1 / 256) * eacc := mul_le_mul hxd hacc_err (abs_nonneg _) (by norm_num)
        _ = eacc / 256 := by ring
    linarith
  have hsum_abs : |p.toReal + c.toReal| ≤ bp + bc := by
    rw [hc_eq]
    have htri := abs_add_le p.toReal c0
    linarith
  have hsum_range : |p.toReal + c.toReal| ≤ (Model.posMaxFinite .binary64).toReal :=
    hsum_abs.trans (hs_range.trans four_le_posMaxFinite_binary64)
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

/-! ### Main Horner rounding and approximation bounds -/

/-- For `|xd| ≤ 1 / 256` and every C rounding mode, `hornerExpLo mode xd` is finite and within
`2.5 · 10⁻¹⁶` of the exact polynomial `Expf.Poly.poly xd.toReal`. -/
theorem hornerExpLo_finite_and_poly_error (hmode : mode ∈ cModes) {xd : Model .binary64}
    (hfin : xd.isFinite = true) (hxd : |xd.toReal| ≤ 1 / 256) :
    (hornerExpLo mode xd).isFinite = true ∧
    |(hornerExpLo mode xd).toReal - Expf.Poly.poly xd.toReal| ≤ (25 / 10 ^ 17 : ℝ) := by
  have _ := hmode
  rw [hornerExpLo_eq, Expf.Poly.poly]
  have hc4_fin := Model.Algebraic.isFinite_of_toRat?_eq_some toRat?_c4
  have hc4_val := Model.Algebraic.toReal_of_toRat?_eq_some toRat?_c4
  have hc3_fin := Model.Algebraic.isFinite_of_toRat?_eq_some toRat?_c3
  have hc3_val := Model.Algebraic.toReal_of_toRat?_eq_some toRat?_c3
  have hc2_fin := Model.Algebraic.isFinite_of_toRat?_eq_some toRat?_c2
  have hc2_val := Model.Algebraic.toReal_of_toRat?_eq_some toRat?_c2
  have hc1_fin := Model.Algebraic.isFinite_of_toRat?_eq_some toRat?_c1
  have hc1_val := Model.Algebraic.toReal_of_toRat?_eq_some toRat?_c1
  have hc0_fin := Model.Algebraic.isFinite_of_toRat?_eq_some toRat?_c0
  have hc0_val : f64(0x3FF0000000000000#64).toReal = (1 : ℝ) := by
    simpa using Model.Algebraic.toReal_of_toRat?_eq_some toRat?_c0
  have hs4_abs : |f64(0x3FA55555555EF243#64).toReal| ≤ (5 / 100 : ℝ) := by
    rw [hc4_val]; norm_num [Expf.Poly.c₄]
  have hs4_err : |f64(0x3FA55555555EF243#64).toReal - (Expf.Poly.c₄ : ℝ)| ≤ 0 := by
    rw [hc4_val, sub_self, abs_zero]
  obtain ⟨hs3_fin, hs3_abs, hs3_err⟩ := hornerStep mode
    (acc0 := (Expf.Poly.c₄ : ℝ)) (c0 := (Expf.Poly.c₃ : ℝ))
    (bacc := 5 / 100) (eacc := 0) (bc := 17 / 100)
    (bp := 1 / 5000) (bs := 18 / 100) (es := 4 / 10 ^ 17)
    hfin hxd hc4_fin hs4_abs hs4_err hc3_fin hc3_val (by norm_num [Expf.Poly.c₃])
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  obtain ⟨hs2_fin, hs2_abs, hs2_err⟩ := hornerStep mode
    (acc0 := (Expf.Poly.c₃ : ℝ) + xd.toReal * (Expf.Poly.c₄ : ℝ)) (c0 := (Expf.Poly.c₂ : ℝ))
    (bacc := 18 / 100) (eacc := 4 / 10 ^ 17) (bc := 501 / 1000)
    (bp := 1 / 1000) (bs := 51 / 100) (es := 12 / 10 ^ 17)
    hfin hxd hs3_fin hs3_abs hs3_err hc2_fin hc2_val (by norm_num [Expf.Poly.c₂])
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  obtain ⟨hs1_fin, hs1_abs, hs1_err⟩ := hornerStep mode
    (acc0 := (Expf.Poly.c₂ : ℝ) + xd.toReal * ((Expf.Poly.c₃ : ℝ) + xd.toReal * (Expf.Poly.c₄ : ℝ)))
    (c0 := (Expf.Poly.c₁ : ℝ))
    (bacc := 51 / 100) (eacc := 12 / 10 ^ 17) (bc := 1)
    (bp := 2 / 1000) (bs := 101 / 100) (es := 23 / 10 ^ 17)
    hfin hxd hs2_fin hs2_abs hs2_err hc1_fin hc1_val (by norm_num [Expf.Poly.c₁])
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  obtain ⟨hs0_fin, _, hs0_err⟩ := hornerStep mode
    (acc0 := (Expf.Poly.c₁ : ℝ) + xd.toReal * ((Expf.Poly.c₂ : ℝ) +
      xd.toReal * ((Expf.Poly.c₃ : ℝ) + xd.toReal * (Expf.Poly.c₄ : ℝ))))
    (c0 := (1 : ℝ))
    (bacc := 101 / 100) (eacc := 23 / 10 ^ 17) (bc := 1)
    (bp := 4 / 1000) (bs := 2) (es := 25 / 10 ^ 17)
    hfin hxd hs1_fin hs1_abs hs1_err hc0_fin hc0_val (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  exact ⟨hs0_fin, hs0_err⟩

/-- For `|xd| ≤ 1 / 256` and every C rounding mode, `hornerExpLo mode xd` is finite and has
relative error at most `1.26 · 10⁻¹⁵` against `Real.exp xd.toReal`. -/
theorem hornerExpLo_finite_and_error (hmode : mode ∈ cModes) {xd : Model .binary64}
    (hfin : xd.isFinite = true) (hxd : |xd.toReal| ≤ 1 / 256) :
    (hornerExpLo mode xd).isFinite = true ∧
    |(hornerExpLo mode xd).toReal - Real.exp xd.toReal| ≤
      (126 / 10 ^ 17 : ℝ) * Real.exp xd.toReal := by
  obtain ⟨hres_fin, hpoly⟩ := hornerExpLo_finite_and_poly_error hmode hfin hxd
  have happrox := Expf.Poly.abs_poly_sub_exp_le (abs_le.mp hxd)
  have htot : |(hornerExpLo mode xd).toReal - Real.exp xd.toReal| ≤ (125 / 10 ^ 17 : ℝ) := by
    have htri : |(hornerExpLo mode xd).toReal - Real.exp xd.toReal| ≤
        |(hornerExpLo mode xd).toReal - Expf.Poly.poly xd.toReal| +
        |Expf.Poly.poly xd.toReal - Real.exp xd.toReal| := by
      have h := abs_add_le ((hornerExpLo mode xd).toReal - Expf.Poly.poly xd.toReal)
        (Expf.Poly.poly xd.toReal - Real.exp xd.toReal)
      simpa [sub_add_sub_cancel] using h
    linarith
  have hexp_lb : (255 / 256 : ℝ) ≤ Real.exp xd.toReal := by
    have h1 : (-(1 / 256 : ℝ)) ≤ xd.toReal := (abs_le.mp hxd).1
    have h2 : (-(1 / 256 : ℝ)) + 1 ≤ Real.exp (-(1 / 256 : ℝ)) := Real.add_one_le_exp _
    have h3 : Real.exp (-(1 / 256 : ℝ)) ≤ Real.exp xd.toReal := Real.exp_le_exp.mpr h1
    linarith
  refine ⟨hres_fin, htot.trans ?_⟩
  nlinarith

/-! ### Tiny-argument exact enclosure bounds -/

/-- On `[2⁻²⁶, 2⁻²⁴ - 2⁻⁴⁸]`, `hornerExpLo mode xd` is finite and lies in
`[1 + 2⁻¹⁴⁹, 1 + 2⁻²⁴]`. -/
theorem hornerExpLo_tiny_pos (hmode : mode ∈ cModes) {xd : Model .binary64}
    (hfin : xd.isFinite = true)
    (hlo : (1 / 2 ^ 26 : ℝ) ≤ xd.toReal)
    (hhi : xd.toReal ≤ (1 / 2 ^ 24 - 1 / 2 ^ 48 : ℝ)) :
    (hornerExpLo mode xd).isFinite = true ∧
    (1 + 1 / 2 ^ 149 : ℝ) ≤ (hornerExpLo mode xd).toReal ∧
    (hornerExpLo mode xd).toReal ≤ (1 + 1 / 2 ^ 24 : ℝ) := by
  set r := xd.toReal
  have hr_pos : 0 ≤ r := by linarith
  have hxd : |r| ≤ 1 / 256 := abs_le.mpr ⟨by linarith, by linarith⟩
  obtain ⟨hres_fin, herr⟩ := hornerExpLo_finite_and_poly_error hmode hfin hxd
  have ⟨herr_lo, herr_hi⟩ := abs_le.mp herr
  have hc1_lo : (1 / 2 : ℝ) ≤ (Expf.Poly.c₁ : ℝ) := by norm_num [Expf.Poly.c₁]
  have hc1_hi : (Expf.Poly.c₁ : ℝ) ≤ 1 := by norm_num [Expf.Poly.c₁]
  have hc2_lo : (0 : ℝ) ≤ (Expf.Poly.c₂ : ℝ) := by norm_num [Expf.Poly.c₂]
  have hc2_hi : (Expf.Poly.c₂ : ℝ) ≤ 51 / 100 := by norm_num [Expf.Poly.c₂]
  have hc3_lo : (0 : ℝ) ≤ (Expf.Poly.c₃ : ℝ) := by norm_num [Expf.Poly.c₃]
  have hc3_hi : (Expf.Poly.c₃ : ℝ) ≤ 17 / 100 := by norm_num [Expf.Poly.c₃]
  have hc4_lo : (0 : ℝ) ≤ (Expf.Poly.c₄ : ℝ) := by norm_num [Expf.Poly.c₄]
  have hc4_hi : (Expf.Poly.c₄ : ℝ) ≤ 5 / 100 := by norm_num [Expf.Poly.c₄]
  have hpoly_lo : (1 + 1 / 2 ^ 27 : ℝ) ≤ Expf.Poly.poly r := by
    rw [Expf.Poly.poly]
    have htail : 0 ≤ r * ((Expf.Poly.c₂ : ℝ) + r * ((Expf.Poly.c₃ : ℝ) + r * (Expf.Poly.c₄ : ℝ))) :=
      by positivity
    nlinarith
  have hpoly_hi : Expf.Poly.poly r ≤ (1 + 1 / 2 ^ 24 - 48 / 100 * (1 / 2 ^ 48) : ℝ) := by
    have hr_le : r ≤ (1 / 2 ^ 24 : ℝ) := by linarith
    have hq3 : (Expf.Poly.c₃ : ℝ) + r * (Expf.Poly.c₄ : ℝ) ≤ 18 / 100 := by nlinarith
    have hq2 : (Expf.Poly.c₂ : ℝ) + r * ((Expf.Poly.c₃ : ℝ) + r * (Expf.Poly.c₄ : ℝ)) ≤ 52 / 100 :=
      by nlinarith
    have hr2 : r ^ 2 ≤ (1 / 2 ^ 48 : ℝ) := by nlinarith
    have hexpand : Expf.Poly.poly r =
        1 + (Expf.Poly.c₁ : ℝ) * r +
          r ^ 2 * ((Expf.Poly.c₂ : ℝ) + r * ((Expf.Poly.c₃ : ℝ) + r * (Expf.Poly.c₄ : ℝ))) := by
      rw [Expf.Poly.poly]; ring
    rw [hexpand]
    have hterm2 : r ^ 2 * ((Expf.Poly.c₂ : ℝ) +
        r * ((Expf.Poly.c₃ : ℝ) + r * (Expf.Poly.c₄ : ℝ))) ≤ (1 / 2 ^ 48 : ℝ) * (52 / 100) :=
      mul_le_mul hr2 hq2 (by positivity) (by norm_num)
    nlinarith
  have hpow149 : (1 / 2 ^ 149 : ℝ) ≤ 1 / 2 ^ 30 :=
    one_div_le_one_div_of_le (by norm_num) (pow_le_pow_right₀ (by norm_num) (by decide))
  refine ⟨hres_fin, ?_, ?_⟩
  · linarith
  · linarith

/-- On `[-2⁻²⁵ + 2⁻⁴⁹, -2⁻²⁶]`, `hornerExpLo mode xd` is finite and lies in
`[1 - 2⁻²⁵, 1 / (1 + 2⁻¹⁴⁹)]`. -/
theorem hornerExpLo_tiny_neg (hmode : mode ∈ cModes) {xd : Model .binary64}
    (hfin : xd.isFinite = true)
    (hlo : (-(1 / 2 ^ 25) + 1 / 2 ^ 49 : ℝ) ≤ xd.toReal)
    (hhi : xd.toReal ≤ -(1 / 2 ^ 26 : ℝ)) :
    (hornerExpLo mode xd).isFinite = true ∧
    (1 - 1 / 2 ^ 25 : ℝ) ≤ (hornerExpLo mode xd).toReal ∧
    (hornerExpLo mode xd).toReal ≤ (1 / (1 + 1 / 2 ^ 149) : ℝ) := by
  set r := xd.toReal
  have hr_neg : r ≤ 0 := by linarith
  have hxd : |r| ≤ 1 / 256 := abs_le.mpr ⟨by linarith, by linarith⟩
  obtain ⟨hres_fin, herr⟩ := hornerExpLo_finite_and_poly_error hmode hfin hxd
  have ⟨herr_lo, herr_hi⟩ := abs_le.mp herr
  have hc1_lo : (9 / 10 : ℝ) ≤ (Expf.Poly.c₁ : ℝ) := by norm_num [Expf.Poly.c₁]
  have hc1_hi : (Expf.Poly.c₁ : ℝ) ≤ 1 := by norm_num [Expf.Poly.c₁]
  have hc2_lo : (49 / 100 : ℝ) ≤ (Expf.Poly.c₂ : ℝ) := by norm_num [Expf.Poly.c₂]
  have hc2_hi : (Expf.Poly.c₂ : ℝ) ≤ 51 / 100 := by norm_num [Expf.Poly.c₂]
  have hc3_lo : (0 : ℝ) ≤ (Expf.Poly.c₃ : ℝ) := by norm_num [Expf.Poly.c₃]
  have hc3_hi : (Expf.Poly.c₃ : ℝ) ≤ 17 / 100 := by norm_num [Expf.Poly.c₃]
  have hc4_lo : (0 : ℝ) ≤ (Expf.Poly.c₄ : ℝ) := by norm_num [Expf.Poly.c₄]
  have hc4_hi : (Expf.Poly.c₄ : ℝ) ≤ 5 / 100 := by norm_num [Expf.Poly.c₄]
  have hexpand : Expf.Poly.poly r =
      1 + (Expf.Poly.c₁ : ℝ) * r +
        r ^ 2 * ((Expf.Poly.c₂ : ℝ) + r * ((Expf.Poly.c₃ : ℝ) + r * (Expf.Poly.c₄ : ℝ))) := by
    rw [Expf.Poly.poly]; ring
  have hq3_lo : (-1 / 100 : ℝ) ≤ (Expf.Poly.c₃ : ℝ) + r * (Expf.Poly.c₄ : ℝ) := by nlinarith
  have hq3_hi : (Expf.Poly.c₃ : ℝ) + r * (Expf.Poly.c₄ : ℝ) ≤ 18 / 100 := by nlinarith
  have hq2_nonneg : (0 : ℝ) ≤
      (Expf.Poly.c₂ : ℝ) + r * ((Expf.Poly.c₃ : ℝ) + r * (Expf.Poly.c₄ : ℝ)) := by nlinarith
  have hq2_hi : (Expf.Poly.c₂ : ℝ) + r * ((Expf.Poly.c₃ : ℝ) + r * (Expf.Poly.c₄ : ℝ)) ≤ 1 := by
    nlinarith
  have hpoly_lo : (1 - 1 / 2 ^ 25 + 1 / 2 ^ 49 : ℝ) ≤ Expf.Poly.poly r := by
    rw [hexpand]
    have hterm2 : 0 ≤ r ^ 2 * ((Expf.Poly.c₂ : ℝ) +
        r * ((Expf.Poly.c₃ : ℝ) + r * (Expf.Poly.c₄ : ℝ))) := mul_nonneg (sq_nonneg r) hq2_nonneg
    nlinarith
  have hpoly_hi : Expf.Poly.poly r ≤ (1 - 9 / 10 * (1 / 2 ^ 26) + 1 / 2 ^ 50 : ℝ) := by
    rw [hexpand]
    have hr2 : r ^ 2 ≤ (1 / 2 ^ 50 : ℝ) := by nlinarith
    have hterm2 : r ^ 2 * ((Expf.Poly.c₂ : ℝ) +
        r * ((Expf.Poly.c₃ : ℝ) + r * (Expf.Poly.c₄ : ℝ))) ≤ (1 / 2 ^ 50 : ℝ) := by nlinarith
    nlinarith
  have hpow149 : (1 / 2 ^ 149 : ℝ) ≤ 1 / 2 ^ 30 :=
    one_div_le_one_div_of_le (by norm_num) (pow_le_pow_right₀ (by norm_num) (by decide))
  have hinv_lb : (1 - 1 / 2 ^ 30 : ℝ) ≤ (1 / (1 + 1 / 2 ^ 149) : ℝ) := by
    rw [le_div_iff₀ (by positivity)]
    nlinarith
  refine ⟨hres_fin, ?_, ?_⟩
  · linarith
  · linarith

/-! ### Axiom checks -/

/--
info: 'LibcMath.Extracted.Expf.HornerError.hornerExpLo_finite_and_poly_error' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms hornerExpLo_finite_and_poly_error

/--
info: 'LibcMath.Extracted.Expf.HornerError.hornerExpLo_finite_and_error' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms hornerExpLo_finite_and_error

/--
info: 'LibcMath.Extracted.Expf.HornerError.hornerExpLo_tiny_pos' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms hornerExpLo_tiny_pos

/--
info: 'LibcMath.Extracted.Expf.HornerError.hornerExpLo_tiny_neg' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms hornerExpLo_tiny_neg

end LibcMath.Extracted.Expf.HornerError
