import LibcMath.Spec
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic

/-!
# Specifications of individual functions

Special cases follow ISO C23 Annex F.10.
-/

namespace LibcMath.Spec

/-- `exp`: `exp(±0) = 1`, `exp(+∞) = +∞`, `exp(-∞) = +0`. -/
noncomputable def exp : Spec where
  real := Real.exp
  atZero _ := .num 1
  atInf neg := if neg then .zero false else .inf false
  exact _ := none

open Classical in
/-- `log`: `log(±0) = -∞`, `log(1) = +0`, `log(+∞) = +∞`, and NaN for negative arguments. -/
noncomputable def log : Spec where
  real := Real.log
  atZero _ := .inf true
  atInf neg := if neg then .nan else .inf false
  exact x := if x < 0 then some .nan else if x = 1 then some (.zero false) else none

/-- `sin`: `sin(±0) = ±0`, and NaN at infinities. -/
noncomputable def sin : Spec where
  real := Real.sin
  atZero neg := .zero neg
  atInf _ := .nan
  exact _ := none

end LibcMath.Spec
