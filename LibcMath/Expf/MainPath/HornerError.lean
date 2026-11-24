import LibcMath.Analysis.Horner
import LibcMath.Expf.Generated.DoubleEval
import LibcMath.Expf.MainPath.Polynomial

/-!
# Binary64 rounding and approximation error of the `expf` Horner polynomial

On its main path, `Generated.DoubleEval.expf` evaluates a degree-4 polynomial in `xd`
(`|xd| ≤ 1 / 256`) by Horner's scheme in binary64 without FMA:
`horner[Generated.DoubleEval.config, mode] xd [c₀, c₁, c₂, c₃, c₄]`.

This file instantiates `LibcMath.Analysis.Horner.hornerStep_binary64` for those eight operations
across all four C rounding directions (`cModes`), combines the rounding bound with
`Poly.abs_poly_sub_exp_le`, and derives tight enclosure bounds on the tiny-argument
subranges `[2⁻²⁶, 2⁻²⁴ - 2⁻⁴⁸]` and `[-2⁻²⁵ + 2⁻⁴⁹, -2⁻²⁶]`.
-/

namespace LibcMath.Expf.MainPath.HornerError

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc.DSL

variable {mode : IEEERoundingMode}

/-- The exact Horner polynomial expression appearing in `Generated.DoubleEval.expf`. -/
def hornerExpLo (mode : IEEERoundingMode) (xd : Model .binary64) : Model .binary64 :=
  horner[Generated.DoubleEval.config, mode] xd
    [f64(0x3FF0000000000000#64), f64(0x3FEFFFFFFFFFF777#64),
     f64(0x3FE000000000071C#64), f64(0x3FC555566668E5E7#64),
     f64(0x3FA55555555EF243#64)]

/-! ### Polynomial constants and unfolding -/

private theorem toRat?_c0 : Model.toRat? f64(0x3FF0000000000000#64) = some 1 := by
  decide +kernel

private theorem toRat?_c1 :
    Model.toRat? f64(0x3FEFFFFFFFFFF777#64) = some Poly.c₁ := by
  decide +kernel

private theorem toRat?_c2 :
    Model.toRat? f64(0x3FE000000000071C#64) = some Poly.c₂ := by
  decide +kernel

private theorem toRat?_c3 :
    Model.toRat? f64(0x3FC555566668E5E7#64) = some Poly.c₃ := by
  decide +kernel

private theorem toRat?_c4 :
    Model.toRat? f64(0x3FA55555555EF243#64) = some Poly.c₄ := by
  decide +kernel

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
  have hnoFma : Generated.DoubleEval.config.hasFma .binary64 = false := rfl
  simp only [hornerExpLo, Libc.polyevalList_cons_cons, Libc.polyevalList_singleton]
  change Libc.multiplyAdd _ _ _ (Libc.multiplyAdd _ _ _ (Libc.multiplyAdd _ _ _
    (Libc.multiplyAdd _ _ _ _ _) _) _) _ = _
  simp only [Libc.multiplyAdd_of_noFma hnoFma]

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
    |res.toReal - (c0 + xd.toReal * acc0)| ≤ es :=
  Analysis.Horner.hornerStep_binary64 mode (bx := 1 / 256) (bmax := 4) (by norm_num)
    Analysis.Horner.four_le_posMaxFinite_binary64 hxd_fin hxd hacc_fin hacc_abs hacc_err
    hc_fin hc_eq hc_abs (by linarith) (by linarith) hs_range hbs_le (by linarith)

/-! ### Main Horner rounding and approximation bounds -/

/-- For `|xd| ≤ 1 / 256` and every C rounding mode, `hornerExpLo mode xd` is finite and within
`2.5 · 10⁻¹⁶` of the exact polynomial `Poly.poly xd.toReal`. -/
theorem hornerExpLo_finite_and_poly_error (hmode : mode ∈ cModes) {xd : Model .binary64}
    (hfin : xd.isFinite = true) (hxd : |xd.toReal| ≤ 1 / 256) :
    (hornerExpLo mode xd).isFinite = true ∧
    |(hornerExpLo mode xd).toReal - Poly.poly xd.toReal| ≤ (25 / 10 ^ 17 : ℝ) := by
  have _ := hmode
  rw [hornerExpLo_eq, Poly.poly]
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
    rw [hc4_val]; norm_num [Poly.c₄]
  have hs4_err : |f64(0x3FA55555555EF243#64).toReal - (Poly.c₄ : ℝ)| ≤ 0 := by
    rw [hc4_val, sub_self, abs_zero]
  obtain ⟨hs3_fin, hs3_abs, hs3_err⟩ := hornerStep mode
    (acc0 := (Poly.c₄ : ℝ)) (c0 := (Poly.c₃ : ℝ))
    (bacc := 5 / 100) (eacc := 0) (bc := 17 / 100)
    (bp := 1 / 5000) (bs := 18 / 100) (es := 4 / 10 ^ 17)
    hfin hxd hc4_fin hs4_abs hs4_err hc3_fin hc3_val (by norm_num [Poly.c₃])
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  obtain ⟨hs2_fin, hs2_abs, hs2_err⟩ := hornerStep mode
    (acc0 := (Poly.c₃ : ℝ) + xd.toReal * (Poly.c₄ : ℝ)) (c0 := (Poly.c₂ : ℝ))
    (bacc := 18 / 100) (eacc := 4 / 10 ^ 17) (bc := 501 / 1000)
    (bp := 1 / 1000) (bs := 51 / 100) (es := 12 / 10 ^ 17)
    hfin hxd hs3_fin hs3_abs hs3_err hc2_fin hc2_val (by norm_num [Poly.c₂])
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  obtain ⟨hs1_fin, hs1_abs, hs1_err⟩ := hornerStep mode
    (acc0 := (Poly.c₂ : ℝ) + xd.toReal * ((Poly.c₃ : ℝ) + xd.toReal * (Poly.c₄ : ℝ)))
    (c0 := (Poly.c₁ : ℝ))
    (bacc := 51 / 100) (eacc := 12 / 10 ^ 17) (bc := 1)
    (bp := 2 / 1000) (bs := 101 / 100) (es := 23 / 10 ^ 17)
    hfin hxd hs2_fin hs2_abs hs2_err hc1_fin hc1_val (by norm_num [Poly.c₁])
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  obtain ⟨hs0_fin, _, hs0_err⟩ := hornerStep mode
    (acc0 := (Poly.c₁ : ℝ) + xd.toReal * ((Poly.c₂ : ℝ) +
      xd.toReal * ((Poly.c₃ : ℝ) + xd.toReal * (Poly.c₄ : ℝ))))
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
  have happrox := Poly.abs_poly_sub_exp_le (abs_le.mp hxd)
  have htot : |(hornerExpLo mode xd).toReal - Real.exp xd.toReal| ≤ (125 / 10 ^ 17 : ℝ) := by
    have htri : |(hornerExpLo mode xd).toReal - Real.exp xd.toReal| ≤
        |(hornerExpLo mode xd).toReal - Poly.poly xd.toReal| +
        |Poly.poly xd.toReal - Real.exp xd.toReal| := by
      have h := abs_add_le ((hornerExpLo mode xd).toReal - Poly.poly xd.toReal)
        (Poly.poly xd.toReal - Real.exp xd.toReal)
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
  have hc1_lo : (1 / 2 : ℝ) ≤ (Poly.c₁ : ℝ) := by norm_num [Poly.c₁]
  have hc1_hi : (Poly.c₁ : ℝ) ≤ 1 := by norm_num [Poly.c₁]
  have hc2_lo : (0 : ℝ) ≤ (Poly.c₂ : ℝ) := by norm_num [Poly.c₂]
  have hc2_hi : (Poly.c₂ : ℝ) ≤ 51 / 100 := by norm_num [Poly.c₂]
  have hc3_lo : (0 : ℝ) ≤ (Poly.c₃ : ℝ) := by norm_num [Poly.c₃]
  have hc3_hi : (Poly.c₃ : ℝ) ≤ 17 / 100 := by norm_num [Poly.c₃]
  have hc4_lo : (0 : ℝ) ≤ (Poly.c₄ : ℝ) := by norm_num [Poly.c₄]
  have hc4_hi : (Poly.c₄ : ℝ) ≤ 5 / 100 := by norm_num [Poly.c₄]
  have hpoly_lo : (1 + 1 / 2 ^ 27 : ℝ) ≤ Poly.poly r := by
    rw [Poly.poly]
    have htail : 0 ≤ r * ((Poly.c₂ : ℝ) + r * ((Poly.c₃ : ℝ) + r * (Poly.c₄ : ℝ))) :=
      by positivity
    nlinarith
  have hpoly_hi : Poly.poly r ≤ (1 + 1 / 2 ^ 24 - 48 / 100 * (1 / 2 ^ 48) : ℝ) := by
    have hr_le : r ≤ (1 / 2 ^ 24 : ℝ) := by linarith
    have hq3 : (Poly.c₃ : ℝ) + r * (Poly.c₄ : ℝ) ≤ 18 / 100 := by nlinarith
    have hq2 : (Poly.c₂ : ℝ) + r * ((Poly.c₃ : ℝ) + r * (Poly.c₄ : ℝ)) ≤ 52 / 100 :=
      by nlinarith
    have hr2 : r ^ 2 ≤ (1 / 2 ^ 48 : ℝ) := by nlinarith
    have hexpand : Poly.poly r =
        1 + (Poly.c₁ : ℝ) * r +
          r ^ 2 * ((Poly.c₂ : ℝ) + r * ((Poly.c₃ : ℝ) + r * (Poly.c₄ : ℝ))) := by
      rw [Poly.poly]; ring
    rw [hexpand]
    have hterm2 : r ^ 2 * ((Poly.c₂ : ℝ) +
        r * ((Poly.c₃ : ℝ) + r * (Poly.c₄ : ℝ))) ≤ (1 / 2 ^ 48 : ℝ) * (52 / 100) :=
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
  have hc1_lo : (9 / 10 : ℝ) ≤ (Poly.c₁ : ℝ) := by norm_num [Poly.c₁]
  have hc1_hi : (Poly.c₁ : ℝ) ≤ 1 := by norm_num [Poly.c₁]
  have hc2_lo : (49 / 100 : ℝ) ≤ (Poly.c₂ : ℝ) := by norm_num [Poly.c₂]
  have hc2_hi : (Poly.c₂ : ℝ) ≤ 51 / 100 := by norm_num [Poly.c₂]
  have hc3_lo : (0 : ℝ) ≤ (Poly.c₃ : ℝ) := by norm_num [Poly.c₃]
  have hc3_hi : (Poly.c₃ : ℝ) ≤ 17 / 100 := by norm_num [Poly.c₃]
  have hc4_lo : (0 : ℝ) ≤ (Poly.c₄ : ℝ) := by norm_num [Poly.c₄]
  have hc4_hi : (Poly.c₄ : ℝ) ≤ 5 / 100 := by norm_num [Poly.c₄]
  have hexpand : Poly.poly r =
      1 + (Poly.c₁ : ℝ) * r +
        r ^ 2 * ((Poly.c₂ : ℝ) + r * ((Poly.c₃ : ℝ) + r * (Poly.c₄ : ℝ))) := by
    rw [Poly.poly]; ring
  have hq3_lo : (-1 / 100 : ℝ) ≤ (Poly.c₃ : ℝ) + r * (Poly.c₄ : ℝ) := by nlinarith
  have hq3_hi : (Poly.c₃ : ℝ) + r * (Poly.c₄ : ℝ) ≤ 18 / 100 := by nlinarith
  have hq2_nonneg : (0 : ℝ) ≤
      (Poly.c₂ : ℝ) + r * ((Poly.c₃ : ℝ) + r * (Poly.c₄ : ℝ)) := by nlinarith
  have hq2_hi : (Poly.c₂ : ℝ) + r * ((Poly.c₃ : ℝ) + r * (Poly.c₄ : ℝ)) ≤ 1 := by
    nlinarith
  have hpoly_lo : (1 - 1 / 2 ^ 25 + 1 / 2 ^ 49 : ℝ) ≤ Poly.poly r := by
    rw [hexpand]
    have hterm2 : 0 ≤ r ^ 2 * ((Poly.c₂ : ℝ) +
        r * ((Poly.c₃ : ℝ) + r * (Poly.c₄ : ℝ))) := mul_nonneg (sq_nonneg r) hq2_nonneg
    nlinarith
  have hpoly_hi : Poly.poly r ≤ (1 - 9 / 10 * (1 / 2 ^ 26) + 1 / 2 ^ 50 : ℝ) := by
    rw [hexpand]
    have hr2 : r ^ 2 ≤ (1 / 2 ^ 50 : ℝ) := by nlinarith
    have hterm2 : r ^ 2 * ((Poly.c₂ : ℝ) +
        r * ((Poly.c₃ : ℝ) + r * (Poly.c₄ : ℝ))) ≤ (1 / 2 ^ 50 : ℝ) := by nlinarith
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
info: 'LibcMath.Expf.MainPath.HornerError.hornerExpLo_finite_and_poly_error' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms hornerExpLo_finite_and_poly_error

/--
info: 'LibcMath.Expf.MainPath.HornerError.hornerExpLo_finite_and_error' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms hornerExpLo_finite_and_error

/--
info: 'LibcMath.Expf.MainPath.HornerError.hornerExpLo_tiny_pos' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms hornerExpLo_tiny_pos

/--
info: 'LibcMath.Expf.MainPath.HornerError.hornerExpLo_tiny_neg' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms hornerExpLo_tiny_neg

end LibcMath.Expf.MainPath.HornerError
