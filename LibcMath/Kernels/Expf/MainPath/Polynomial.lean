import LibcMath.Framework.Spec
import FloatLib.Tactic.Interval
import Mathlib.Analysis.Complex.ExponentialBounds

/-!
# The polynomial of `expf` approximates the exponential

On the inputs that take neither a short path nor the special case, the extracted
`Generated.DoubleEval.expf` computes `exp x` as a product of two table entries and a polynomial of
degree 4 in a remainder `r` with `|r| ≤ 1 / 256` (the `horner` call of
`LibcMath/Kernels/Expf/DoubleEval.lean`). This file bounds the distance between
that polynomial, as a function of a real variable, and the exponential:

* `Poly.poly r` is the polynomial with the constants of the code as rational numbers, and
  `Poly.toReal_c₁` … `Poly.toReal_c₄` state that these are the values of the four
  binary64 constants of the code;
* `Poly.abs_poly_sub_exp_le`: `|poly r - exp r| ≤ 10⁻¹⁵` for `|r| ≤ 1 / 256`.

Sollya reports `9.50 · 10⁻¹⁶` for the supremum, so the bound has little slack.

## How the bound is proved

A direct interval evaluation of `poly r - exp r` cannot work: the enclosures of the two terms are
each as wide as the interval of `r`, and their difference does not see that they move together.
The proof goes through the Taylor polynomial `T` of degree 7 instead.

* `|T r - exp r|` is at most `2 · 10⁻²⁴` by Mathlib's `Real.exp_bound`.
* `poly r - T r` is a polynomial with explicit rational coefficients, and FloatLib's `interval`
  bounds it by subdivision, checked by the kernel (`abs_poly_sub_taylor_le`).

This is about the polynomial as a real function. It says nothing yet about the binary64
operations that evaluate it, nor about the tables; the journal tree `prob-48KJ` lists what is
left.
-/

namespace LibcMath.Kernels.Expf.MainPath.Poly

open FloatLib.Floats.Formats.BinaryInterchange Model

/-- `0x3FEFFFFFFFFFF777`, the coefficient of `r`. -/
def c₁ : ℚ := 9007199254738807 / 9007199254740992
/-- `0x3FE000000000071C`, the coefficient of `r ^ 2`. -/
def c₂ : ℚ := 1125899906843079 / 2251799813685248
/-- `0x3FC555566668E5E7`, the coefficient of `r ^ 3`. -/
def c₃ : ℚ := 6004804084622823 / 36028797018963968
/-- `0x3FA55555555EF243`, the coefficient of `r ^ 4`. -/
def c₄ : ℚ := 6004799503790659 / 144115188075855872

theorem toReal_c₁ : (ofNatBits 0x3FEFFFFFFFFFF777 : Model FloatFormat.binary64).toReal = c₁ :=
  Algebraic.toReal_of_toRat?_eq_some (by decide +kernel)

theorem toReal_c₂ : (ofNatBits 0x3FE000000000071C : Model FloatFormat.binary64).toReal = c₂ :=
  Algebraic.toReal_of_toRat?_eq_some (by decide +kernel)

theorem toReal_c₃ : (ofNatBits 0x3FC555566668E5E7 : Model FloatFormat.binary64).toReal = c₃ :=
  Algebraic.toReal_of_toRat?_eq_some (by decide +kernel)

theorem toReal_c₄ : (ofNatBits 0x3FA55555555EF243 : Model FloatFormat.binary64).toReal = c₄ :=
  Algebraic.toReal_of_toRat?_eq_some (by decide +kernel)

/-- The polynomial of `expf`, in the order in which the code evaluates it. -/
noncomputable def poly (r : ℝ) : ℝ :=
  1 + r * (c₁ + r * (c₂ + r * (c₃ + r * c₄)))

/-- The Taylor polynomial of the exponential of degree 7. -/
noncomputable def taylor (r : ℝ) : ℝ :=
  ∑ m ∈ Finset.range 8, r ^ m / (m.factorial : ℝ)

/-- The polynomial of `expf` minus the Taylor polynomial, with its coefficients written out. -/
theorem poly_sub_taylor (r : ℝ) :
    poly r - taylor r =
      (-2185 / 9007199254740992) * r + (455 / 2251799813685248) * r ^ 2 +
        (13744386485 / 108086391056891904) * r ^ 3 + (1889993 / 432345564227567616) * r ^ 4 -
        (1 / 120) * r ^ 5 - (1 / 720) * r ^ 6 - (1 / 5040) * r ^ 7 := by
  simp only [poly, taylor, c₁, c₂, c₃, c₄, Finset.sum_range_succ, Finset.sum_range_zero,
    Nat.factorial]
  push_cast
  ring

/-- The polynomial of `expf` is within `9.6 · 10⁻¹⁶` of the Taylor polynomial of degree 7. -/
theorem abs_poly_sub_taylor_le {r : ℝ} (hr : r ∈ Set.Icc (-(1 / 256 : ℝ)) (1 / 256)) :
    |poly r - taylor r| ≤ 96 / 10 ^ 17 := by
  rw [poly_sub_taylor]
  revert r
  interval

/-- The Taylor polynomial of degree 7 is within `2 · 10⁻²⁴` of the exponential. -/
theorem abs_exp_sub_taylor_le {r : ℝ} (hr : r ∈ Set.Icc (-(1 / 256 : ℝ)) (1 / 256)) :
    |Real.exp r - taylor r| ≤ 2 / 10 ^ 24 := by
  have habs : |r| ≤ 1 / 256 := abs_le.mpr hr
  have hbound := Real.exp_bound (x := r) (habs.trans (by norm_num)) (n := 8) (by norm_num)
  have hpow : |r| ^ 8 ≤ (1 / 256 : ℝ) ^ 8 := pow_le_pow_left₀ (abs_nonneg r) habs 8
  refine hbound.trans ?_
  calc |r| ^ 8 * ((Nat.succ 8 : ℕ) / ((Nat.factorial 8 : ℕ) * (8 : ℕ)) : ℝ)
      ≤ (1 / 256 : ℝ) ^ 8 * ((Nat.succ 8 : ℕ) / ((Nat.factorial 8 : ℕ) * (8 : ℕ)) : ℝ) := by
        gcongr
    _ ≤ 2 / 10 ^ 24 := by norm_num [Nat.factorial]

/-- The polynomial of `expf` is within `10⁻¹⁵` of the exponential for `|r| ≤ 1 / 256`. -/
theorem abs_poly_sub_exp_le {r : ℝ} (hr : r ∈ Set.Icc (-(1 / 256 : ℝ)) (1 / 256)) :
    |poly r - Real.exp r| ≤ 1 / 10 ^ 15 := by
  have h₁ := abs_poly_sub_taylor_le hr
  have h₂ := abs_exp_sub_taylor_le hr
  have htriangle : |poly r - Real.exp r| ≤ |poly r - taylor r| + |Real.exp r - taylor r| := by
    rw [show poly r - Real.exp r = (poly r - taylor r) - (Real.exp r - taylor r) by ring]
    exact abs_sub _ _
  refine htriangle.trans ((add_le_add h₁ h₂).trans ?_)
  norm_num

/--
info: 'LibcMath.Kernels.Expf.MainPath.Poly.abs_poly_sub_exp_le' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms abs_poly_sub_exp_le

end LibcMath.Kernels.Expf.MainPath.Poly
