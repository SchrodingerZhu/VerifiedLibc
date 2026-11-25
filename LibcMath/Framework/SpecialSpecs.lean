import LibcMath.Framework.Spec
import Mathlib.Analysis.SpecialFunctions.Gamma.Basic
import Mathlib.MeasureTheory.Integral.IntervalIntegral.Basic

/-!
# Specifications for special functions outside FloatLib

Defines ISO C23 Annex F.10 specifications for `erf` and `lgamma` on top of Mathlib.
Keep this module separate from `LibcMath.Framework.Specs` so elementary kernels do not
import Mathlib measure theory or Gamma.
-/

namespace LibcMath.Spec

open FloatLib.Floats.Formats.BinaryInterchange Model

/-- The Gauss error function `(2 / √π) ∫_0^x exp(-t^2) dt`. -/
noncomputable def realErf (x : ℝ) : ℝ :=
  (2 / Real.sqrt Real.pi) * ∫ t in (0 : ℝ)..x, Real.exp (-(t ^ 2))

/-- ISO C23 Annex F.10 specification for `erf`: `erf(±0) = ±0` and `erf(±∞) = ±1`. -/
noncomputable def erf (fmt : FloatFormat) : Spec fmt where
  real := realErf
  atZero negative := zero fmt negative
  atInf negative := if negative then negOne fmt else posOne fmt
  exact _ := none

open Classical in
/-- ISO C23 Annex F.10 specification for `lgamma`: `log |Γ(x)|`, `+∞` at nonpositive integers
and `±∞`, and `+0` at `1` and `2`. -/
noncomputable def lgamma (fmt : FloatFormat) : Spec fmt where
  real x := Real.log |Real.Gamma x|
  atZero _ := posInf fmt
  atInf _ := posInf fmt
  exact x :=
    if x = 1 ∨ x = 2 then some (posZero fmt)
    else if ∃ n : ℕ, x = -(n : ℝ) then some (posInf fmt)
    else none

end LibcMath.Spec
