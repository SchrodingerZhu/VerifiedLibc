import Mathlib.Data.Int.Log
import Mathlib.Algebra.Order.Archimedean.Real.Basic
import Mathlib.Tactic

/-!
# Correct rounding

The statement that a math function is correctly rounded, for IEEE 754 binary interchange formats.

* `Format` describes a format, `Value` is what a bit pattern denotes, and `Format.decode` maps bit
  patterns to values. All NaNs denote the same value.
* `Format.round` rounds a real number in one of the four rounding directions of C, including
  gradual underflow and overflow.
* `Spec` is the mathematical description of a unary function: a real function together with the
  results the C standard fixes at zeros, infinities and other exceptional arguments.
* `CorrectlyRounded` says that an implementation, as a function on bit patterns that may depend on
  the rounding direction, returns the value `Spec.eval` prescribes on every input.

Floating-point exception flags and `errno` are not part of the statement.
-/

namespace LibcMath

/-- An IEEE 754 binary interchange format: the width of the exponent field and the precision,
which counts the implicit leading bit of the significand. -/
structure Format where
  expBits : ℕ
  prec : ℕ
  deriving DecidableEq

namespace Format

def binary16 : Format := ⟨5, 11⟩
def binary32 : Format := ⟨8, 24⟩
def binary64 : Format := ⟨11, 53⟩
def binary128 : Format := ⟨15, 113⟩

variable (F : Format)

/-- Width of the encoding: sign, exponent field, and `prec - 1` fraction bits. -/
def width : ℕ := F.expBits + F.prec

/-- Largest exponent of a finite number, which is also the exponent bias. -/
def emax : ℤ := 2 ^ (F.expBits - 1) - 1

/-- Smallest exponent of a normal number. -/
def emin : ℤ := 1 - F.emax

/-- The largest finite number. -/
noncomputable def maxFinite : ℝ := (2 ^ F.prec - 1) * 2 ^ (F.emax - (F.prec - 1))

end Format

/-- What a floating-point datum denotes. A single `nan` stands for every NaN, so equality of
values ignores NaN signs and payloads and does not distinguish quiet from signaling NaNs. -/
inductive Value where
  | nan
  | inf (neg : Bool)
  | zero (neg : Bool)
  /-- A nonzero finite number. -/
  | num (x : ℝ)

/-- The rounding directions selectable through `fesetround`. -/
inductive Mode where
  | nearestEven
  | towardZero
  | upward
  | downward
  deriving DecidableEq

open Classical in
/-- Round a real number to an integer in the given direction. -/
noncomputable def Mode.roundInt : Mode → ℝ → ℤ
  | .nearestEven, q =>
    if q - ⌊q⌋ < 1 / 2 ∨ (q - ⌊q⌋ = 1 / 2 ∧ Even ⌊q⌋) then ⌊q⌋ else ⌊q⌋ + 1
  | .towardZero, q => if 0 ≤ q then ⌊q⌋ else ⌈q⌉
  | .upward, q => ⌈q⌉
  | .downward, q => ⌊q⌋

namespace Format

variable (F : Format)

/-- `v` is a datum of the format: any special value, or a nonzero number `m * 2 ^ (e - (prec - 1))`
with a significand of at most `prec` bits and `emin ≤ e ≤ emax`. Subnormal numbers are those with
`e = emin` and a short significand. -/
def Represents : Value → Prop
  | .num x => x ≠ 0 ∧ ∃ m e : ℤ, |m| < 2 ^ F.prec ∧ F.emin ≤ e ∧ e ≤ F.emax ∧
      x = m * (2 : ℝ) ^ (e - (F.prec - 1))
  | _ => True

/-- Exponent of the unit in the last place at `x`: numbers in the binade `[2 ^ e, 2 ^ (e + 1))`
are spaced `2 ^ (e - (prec - 1))` apart, and below `2 ^ emin` the spacing stays that of the
smallest normal binade. -/
noncomputable def ulpExp (x : ℝ) : ℤ :=
  max (Int.log 2 |x|) F.emin - (F.prec - 1)

/-- Rounding with the exponent bounded below but not above. -/
noncomputable def roundUnbounded (m : Mode) (x : ℝ) : ℝ :=
  m.roundInt (x / 2 ^ F.ulpExp x) * 2 ^ F.ulpExp x

open Classical in
/-- Round a nonzero real number to the format, as IEEE 754 prescribes: round as if the exponent
range were unbounded above, then replace a result beyond the largest finite number by an infinity
or by the largest finite number, depending on the direction. A result that rounds to zero keeps
the sign of `x`. At `x = 0` this returns `+0`; a `Spec` states the sign of exact zeros itself. -/
noncomputable def round (m : Mode) (x : ℝ) : Value :=
  let r := F.roundUnbounded m x
  if F.maxFinite < |r| then
    match m with
    | .nearestEven => .inf (x < 0)
    | .towardZero => .num (if x < 0 then -F.maxFinite else F.maxFinite)
    | .upward => if x < 0 then .num (-F.maxFinite) else .inf false
    | .downward => if x < 0 then .inf true else .num F.maxFinite
  else if r = 0 then .zero (x < 0)
  else .num r

/-- The value denoted by a bit pattern. From the most significant bit down, the fields are the
sign, the biased exponent, and the fraction. -/
noncomputable def decode (b : BitVec F.width) : Value :=
  let frac := b.toNat % 2 ^ (F.prec - 1)
  let e := b.toNat / 2 ^ (F.prec - 1) % 2 ^ F.expBits
  let sign : ℝ := if b.msb then -1 else 1
  if e = 2 ^ F.expBits - 1 then
    if frac = 0 then .inf b.msb else .nan
  else if e = 0 then
    if frac = 0 then .zero b.msb else .num (sign * frac * 2 ^ (F.emin - (F.prec - 1)))
  else .num (sign * (2 ^ (F.prec - 1) + frac) * 2 ^ (e - F.emax - (F.prec - 1)))

end Format

/-- The mathematical description of a unary function. A NaN argument always gives NaN. -/
structure Spec where
  /-- The real function being approximated. -/
  real : ℝ → ℝ
  /-- The result at `+0` and `-0`. -/
  atZero : (neg : Bool) → Value
  /-- The result at `+∞` and `-∞`. -/
  atInf : (neg : Bool) → Value
  /-- Results at nonzero finite arguments that are not obtained by rounding `real`: arguments
  outside the domain, poles, and arguments where `real` is exactly zero. -/
  exact : ℝ → Option Value

/-- The value a correctly rounded implementation returns. -/
noncomputable def Spec.eval (S : Spec) (F : Format) (m : Mode) : Value → Value
  | .nan => .nan
  | .zero neg => S.atZero neg
  | .inf neg => S.atInf neg
  | .num x => (S.exact x).getD (F.round m (S.real x))

/-- `impl` is a correctly rounded implementation of `S` in format `F` under every rounding
direction in `modes`. The implementation receives the rounding direction in effect, which for
code running on a floating-point unit is the dynamic rounding mode. -/
def CorrectlyRounded (F : Format) (S : Spec) (modes : Set Mode)
    (impl : Mode → BitVec F.width → BitVec F.width) : Prop :=
  ∀ m ∈ modes, ∀ b, F.decode (impl m b) = S.eval F m (F.decode b)

end LibcMath
