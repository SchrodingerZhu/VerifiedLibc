import FloatLib.Floats.Formats.BinaryInterchange.Algebraic.Directed.Runtime
import FloatLib.Floats.Formats.BinaryInterchange.Transcendentals.Directed.Runtime
import FloatLib.Floats.Formats.BinaryInterchange.Transcendentals.Recommended.Runtime
import LibcMath.Libc.Ops

/-!
# FloatLib-backed evaluators and reference specifications

Wraps FloatLib's IEEE 754-2019 §5 and §9.2 evaluators under a uniform
`(mode : IEEERoundingMode) → ... → Model fmt` signature. Kernel statements and differential
tests reuse these definitions directly without duplicating IEEE special-case logic.
-/

namespace LibcMath.FloatLibSpec

open FloatLib.Floats.Formats.BinaryInterchange
open FloatLib.Floats.Formats.BinaryInterchange.Model
open Model (IEEERoundingMode)

variable {fmt : FloatFormat}

/-! ### Exponential and logarithmic evaluators -/

/-- Evaluates IEEE 754-2019 `exp` via FloatLib. -/
def exp (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  (Transcendentals.Directed.exp x mode).value

/-- Evaluates IEEE 754-2019 `expm1` via FloatLib. -/
def expm1 (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  (Transcendentals.Directed.expm1 x mode).value

/-- Evaluates IEEE 754-2019 `exp2` via FloatLib. -/
def exp2 (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  (Transcendentals.CorrectlyRounded.Function.apply .exp2 x mode).value

/-- Evaluates IEEE 754-2019 `exp2m1` via FloatLib. -/
def exp2m1 (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  (Transcendentals.CorrectlyRounded.Function.apply .exp2m1 x mode).value

/-- Evaluates IEEE 754-2019 `exp10` via FloatLib. -/
def exp10 (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  (Transcendentals.CorrectlyRounded.Function.apply .exp10 x mode).value

/-- Evaluates IEEE 754-2019 `exp10m1` via FloatLib. -/
def exp10m1 (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  (Transcendentals.CorrectlyRounded.Function.apply .exp10m1 x mode).value

/-- Evaluates IEEE 754-2019 `log` via FloatLib. -/
def log (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  (Transcendentals.Directed.log x mode).value

/-- Evaluates IEEE 754-2019 `log1p` (`logp1`) via FloatLib. -/
def log1p (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  (Transcendentals.Directed.logp1 x mode).value

/-- Evaluates IEEE 754-2019 `log2` via FloatLib. -/
def log2 (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  (Transcendentals.CorrectlyRounded.Function.apply .log2 x mode).value

/-- Evaluates IEEE 754-2019 `log10` via FloatLib. -/
def log10 (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  (Transcendentals.CorrectlyRounded.Function.apply .log10 x mode).value

/-! ### Trigonometric and inverse-trigonometric evaluators -/

/-- Evaluates IEEE 754-2019 `sin` via FloatLib. -/
def sin (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  (Transcendentals.CorrectlyRounded.Function.apply .sin x mode).value

/-- Evaluates IEEE 754-2019 `cos` via FloatLib. -/
def cos (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  (Transcendentals.CorrectlyRounded.Function.apply .cos x mode).value

/-- Evaluates IEEE 754-2019 `tan` via FloatLib. -/
def tan (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  (Transcendentals.CorrectlyRounded.Function.apply .tan x mode).value

/-- Evaluates IEEE 754-2019 `(sin x, cos x)` via FloatLib. -/
def sincos (mode : IEEERoundingMode) (x : Model fmt) : Model fmt × Model fmt :=
  (sin mode x, cos mode x)

/-- Evaluates IEEE 754-2019 `sinPi` via FloatLib. -/
def sinpi (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  (Transcendentals.CorrectlyRounded.Function.apply .sinPi x mode).value

/-- Evaluates IEEE 754-2019 `cosPi` via FloatLib. -/
def cospi (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  (Transcendentals.CorrectlyRounded.Function.apply .cosPi x mode).value

/-- Evaluates IEEE 754-2019 `tanPi` via FloatLib. -/
def tanpi (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  (Transcendentals.CorrectlyRounded.Function.apply .tanPi x mode).value

/-- Evaluates IEEE 754-2019 `asin` via FloatLib. -/
def asin (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  (Transcendentals.CorrectlyRounded.Function.apply .asin x mode).value

/-- Evaluates IEEE 754-2019 `acos` via FloatLib. -/
def acos (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  (Transcendentals.CorrectlyRounded.Function.apply .acos x mode).value

/-- Evaluates IEEE 754-2019 `atan` via FloatLib. -/
def atan (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  (Transcendentals.CorrectlyRounded.Function.apply .atan x mode).value

/-- Evaluates IEEE 754-2019 `asinPi` via FloatLib. -/
def asinpi (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  (Transcendentals.CorrectlyRounded.Function.apply .asinPi x mode).value

/-- Evaluates IEEE 754-2019 `acosPi` via FloatLib. -/
def acospi (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  (Transcendentals.CorrectlyRounded.Function.apply .acosPi x mode).value

/-- Evaluates IEEE 754-2019 `atan2` via FloatLib. -/
def atan2 (mode : IEEERoundingMode) (y x : Model fmt) : Model fmt :=
  (Transcendentals.CorrectlyRounded.atan2 y x mode).value

/-! ### Hyperbolic and inverse-hyperbolic evaluators -/

/-- Evaluates IEEE 754-2019 `sinh` via FloatLib. -/
def sinh (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  (Transcendentals.CorrectlyRounded.Function.apply .sinh x mode).value

/-- Evaluates IEEE 754-2019 `cosh` via FloatLib. -/
def cosh (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  (Transcendentals.CorrectlyRounded.Function.apply .cosh x mode).value

/-- Evaluates IEEE 754-2019 `tanh` via FloatLib. -/
def tanh (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  (Transcendentals.CorrectlyRounded.Function.apply .tanh x mode).value

/-- Evaluates IEEE 754-2019 `asinh` via FloatLib. -/
def asinh (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  (Transcendentals.CorrectlyRounded.Function.apply .asinh x mode).value

/-- Evaluates IEEE 754-2019 `acosh` via FloatLib. -/
def acosh (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  (Transcendentals.CorrectlyRounded.Function.apply .acosh x mode).value

/-- Evaluates IEEE 754-2019 `atanh` via FloatLib. -/
def atanh (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  (Transcendentals.CorrectlyRounded.Function.apply .atanh x mode).value

/-! ### Algebraic, power, rounding, extrema, and IEEE manipulation evaluators -/

/-- Evaluates IEEE 754-2019 `sqrt` via FloatLib. -/
def sqrt (mode : IEEERoundingMode) (x : Model fmt) : Model fmt := Model.sqrt x mode

/-- Evaluates IEEE 754-2019 `rSqrt` via FloatLib. -/
def rsqrt (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  (Algebraic.Directed.rSqrt x mode).value

/-- Evaluates IEEE 754-2019 `cbrt` via FloatLib. -/
def cbrt (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  (Algebraic.Directed.cbrt x mode).value

/-- Evaluates IEEE 754-2019 `hypot` via FloatLib. -/
def hypot (mode : IEEERoundingMode) (x y : Model fmt) : Model fmt :=
  (Algebraic.Directed.hypot x y mode).value

/-- Evaluates IEEE 754-2019 `pow` via FloatLib. -/
def pow (mode : IEEERoundingMode) (x y : Model fmt) : Model fmt :=
  (Transcendentals.CorrectlyRounded.pow x y mode).value

/-- Evaluates IEEE 754-2019 `fma` via FloatLib. -/
def fma (mode : IEEERoundingMode) (x y z : Model fmt) : Model fmt := Model.fma x y z mode

/-- Evaluates IEEE 754 `abs` via FloatLib. -/
def fabs (_mode : IEEERoundingMode) (x : Model fmt) : Model fmt := Model.abs x

/-- Evaluates IEEE 754 `copySign` via FloatLib. -/
def copysign (_mode : IEEERoundingMode) (x y : Model fmt) : Model fmt := Model.copySign x y

/-- Evaluates C23 `fdim` via FloatLib subtraction and comparison. -/
def fdim (mode : IEEERoundingMode) (x y : Model fmt) : Model fmt :=
  if Model.isNaN x then x
  else if Model.isNaN y then y
  else if Libc.fgt x y then Model.sub x y mode
  else Model.posZero fmt

/-- Evaluates IEEE 754 `floor` via FloatLib. -/
def floor (_mode : IEEERoundingMode) (x : Model fmt) : Model fmt := Libc.floor x

/-- Evaluates IEEE 754 `ceil` via FloatLib. -/
def ceil (_mode : IEEERoundingMode) (x : Model fmt) : Model fmt := Libc.ceil x

/-- Evaluates IEEE 754 `trunc` via FloatLib. -/
def trunc (_mode : IEEERoundingMode) (x : Model fmt) : Model fmt := Libc.trunc x

/-- Evaluates IEEE 754 `roundToIntegralTiesToAway` (`round`) via FloatLib. -/
def round (_mode : IEEERoundingMode) (x : Model fmt) : Model fmt := Libc.round x

/-- Evaluates IEEE 754 `roundToIntegralTiesToEven` (`roundeven`) via FloatLib. -/
def roundeven (_mode : IEEERoundingMode) (x : Model fmt) : Model fmt := Libc.roundEven x

/-- Evaluates IEEE 754 `roundToIntegralExact` (`rint` / `nearbyint`) via FloatLib. -/
def rint (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  Model.roundToIntegral x (mode := mode)

/-- Evaluates IEEE 754 `nextUp` via FloatLib. -/
def nextup (_mode : IEEERoundingMode) (x : Model fmt) : Model fmt := Model.nextUp x

/-- Evaluates IEEE 754 `nextDown` via FloatLib. -/
def nextdown (_mode : IEEERoundingMode) (x : Model fmt) : Model fmt := Model.nextDown x

/-- Evaluates C23 `fmax` (`maxNum`) via FloatLib. -/
def fmax (_mode : IEEERoundingMode) (x y : Model fmt) : Model fmt := Libc.fmax x y

/-- Evaluates C23 `fmin` (`minNum`) via FloatLib. -/
def fmin (_mode : IEEERoundingMode) (x y : Model fmt) : Model fmt := Libc.fmin x y

/-- Evaluates IEEE 754-2019 `maximum` via FloatLib. -/
def fmaximum (_mode : IEEERoundingMode) (x y : Model fmt) : Model fmt := Model.maximum x y

/-- Evaluates IEEE 754-2019 `minimum` via FloatLib. -/
def fminimum (_mode : IEEERoundingMode) (x y : Model fmt) : Model fmt := Model.minimum x y

/-- Evaluates IEEE 754-2019 `maximumNumber` via FloatLib. -/
def fmaximumNum (_mode : IEEERoundingMode) (x y : Model fmt) : Model fmt :=
  Model.maximumNumber x y

/-- Evaluates IEEE 754-2019 `minimumNumber` via FloatLib. -/
def fminimumNum (_mode : IEEERoundingMode) (x y : Model fmt) : Model fmt :=
  Model.minimumNumber x y

/-- Evaluates IEEE 754-2019 `maximumMagnitude` via FloatLib. -/
def fmaximumMag (_mode : IEEERoundingMode) (x y : Model fmt) : Model fmt :=
  Model.maximumMagnitude x y

/-- Evaluates IEEE 754-2019 `minimumMagnitude` via FloatLib. -/
def fminimumMag (_mode : IEEERoundingMode) (x y : Model fmt) : Model fmt :=
  Model.minimumMagnitude x y

/-- Evaluates IEEE 754-2019 `maximumMagnitudeNumber` via FloatLib. -/
def fmaximumMagNum (_mode : IEEERoundingMode) (x y : Model fmt) : Model fmt :=
  Model.maximumMagnitudeNumber x y

/-- Evaluates IEEE 754-2019 `minimumMagnitudeNumber` via FloatLib. -/
def fminimumMagNum (_mode : IEEERoundingMode) (x y : Model fmt) : Model fmt :=
  Model.minimumMagnitudeNumber x y

/-- Evaluates IEEE 754 `getPayload` via FloatLib. -/
def getpayload (_mode : IEEERoundingMode) (x : Model fmt) : Model fmt := Model.getPayload x

/-- Evaluates IEEE 754 `totalOrder` via FloatLib. -/
def totalorder (_mode : IEEERoundingMode) (x y : Model fmt) : Bool := Model.totalOrder x y

/-- Evaluates IEEE 754 `totalOrderMag` via FloatLib. -/
def totalordermag (_mode : IEEERoundingMode) (x y : Model fmt) : Bool := Model.totalOrderMag x y

/-- Evaluates IEEE 754 `remainder` via FloatLib. -/
def remainder (_mode : IEEERoundingMode) (x y : Model fmt) : Model fmt := Libc.remainder x y

end LibcMath.FloatLibSpec
