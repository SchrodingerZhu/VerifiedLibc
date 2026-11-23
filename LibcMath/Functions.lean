import LibcMath.Spec
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic

/-!
# Specifications of individual functions

Special cases follow ISO C23 Annex F.10.
-/

namespace LibcMath.Spec

open FloatLib.Floats.Formats.BinaryInterchange Model

/-- `exp`: `exp(±0) = 1`, `exp(+∞) = +∞`, `exp(-∞) = +0`. -/
noncomputable def exp (fmt : FloatFormat) : Spec fmt where
  real := Real.exp
  atZero _ := posOne fmt
  atInf negative := if negative then posZero fmt else posInf fmt
  exact _ := none

open Classical in
/-- `log`: `log(±0) = -∞`, `log(1) = +0`, `log(+∞) = +∞`, and NaN for negative arguments. -/
noncomputable def log (fmt : FloatFormat) : Spec fmt where
  real := Real.log
  atZero _ := negInf fmt
  atInf negative := if negative then canonicalNaN fmt else posInf fmt
  exact x := if x < 0 then some (canonicalNaN fmt) else if x = 1 then some (posZero fmt) else none

/-- `sin`: `sin(±0) = ±0`, and NaN at infinities. -/
noncomputable def sin (fmt : FloatFormat) : Spec fmt where
  real := Real.sin
  atZero negative := zero fmt negative
  atInf _ := canonicalNaN fmt
  exact _ := none

end LibcMath.Spec
