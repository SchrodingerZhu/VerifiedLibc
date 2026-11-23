import LibcMath.Spec

/-!
# IEEE 754 operations on values

The operations a floating-point unit performs, as functions of the rounding direction in effect.
They are the meaning given to the floating-point instructions of extracted code.
-/

namespace LibcMath

namespace Value

def neg : Value → Value
  | nan => nan
  | inf s => inf !s
  | zero s => zero !s
  | num x => num (-x)

def abs : Value → Value
  | nan => nan
  | inf _ => inf false
  | zero _ => zero false
  | num x => num |x|

/-- The real number a finite value stands for; `0` for the others. -/
def toReal : Value → ℝ
  | num x => x
  | _ => 0

open Classical in
/-- The sign bit of a value other than NaN. -/
noncomputable def isNeg : Value → Bool
  | nan => false
  | inf s => s
  | zero s => s
  | num x => x < 0

/-- Position in the extended real line, or `none` for NaN. Both zeros are equal there. -/
noncomputable def toEReal? : Value → Option EReal
  | nan => none
  | inf s => some (if s then ⊥ else ⊤)
  | zero _ => some 0
  | num x => some x

open Classical in
/-- Truncation toward zero of a finite value. -/
noncomputable def truncInt? : Value → Option ℤ
  | zero _ => some 0
  | num x => some (if 0 ≤ x then ⌊x⌋ else ⌈x⌉)
  | _ => none

end Value

namespace Format

variable (F : Format)

open Classical in
/-- Round the exact result `r` of an operation, where `zeroNeg` is the sign of the result if `r`
is exactly zero. -/
noncomputable def roundExact (m : Mode) (r : ℝ) (zeroNeg : Bool) : Value :=
  if r = 0 then .zero zeroNeg else F.round m r

open Classical in
/-- Addition. An exact zero sum of two zeros of the same sign has that sign; any other exact zero
sum is `+0`, except `-0` when rounding downward. -/
noncomputable def add (m : Mode) : Value → Value → Value
  | .nan, _ | _, .nan => .nan
  | .inf s, .inf t => if s = t then .inf s else .nan
  | .inf s, _ | _, .inf s => .inf s
  | .zero s, .zero t => .zero (if s = t then s else m = .downward)
  | a, b => F.roundExact m (a.toReal + b.toReal) (m = .downward)

noncomputable def sub (m : Mode) (a b : Value) : Value :=
  F.add m a b.neg

/-- Multiplication. The sign of a zero or infinite result is the exclusive or of the signs. -/
noncomputable def mul (m : Mode) : Value → Value → Value
  | .nan, _ | _, .nan => .nan
  | .inf _, .zero _ | .zero _, .inf _ => .nan
  | .inf s, b => .inf (s != b.isNeg)
  | a, .inf s => .inf (a.isNeg != s)
  | a, b => F.roundExact m (a.toReal * b.toReal) (a.isNeg != b.isNeg)

/-- Conversion of a value of another format to `F`. Widening conversions are exact. -/
noncomputable def convert (m : Mode) : Value → Value
  | .num x => F.round m x
  | v => v

end Format

end LibcMath
