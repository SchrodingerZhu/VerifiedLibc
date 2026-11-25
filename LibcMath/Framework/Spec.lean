import FloatLib.Floats.Formats.BinaryInterchange.Algebraic.Rounding.DirectedProof

/-!
# Correct rounding

The statement that a math function is correctly rounded.

Formats, their encodings and rounding come from FloatLib: `FloatFormat` describes a format,
`Model fmt` is a bit pattern of that format, and `Model.roundReal fmt mode x` is the rounding of
the real number `x` in direction `mode`, with gradual underflow and the overflow results of
IEEE 754. This file adds what is specific to math functions:

* `Spec` is the mathematical description of a unary function: a real function together with the
  results the C standard fixes at zeros, infinities and other exceptional arguments.
* `SameValue` compares two results while identifying all NaNs.
* `CorrectlyRounded` says that an implementation, which may depend on the rounding direction,
  has a result on every input, and that it is the one `Spec.eval` prescribes.

The definitions are meant for IEEE formats (`fmt.isIEEE`). Floating-point exception flags and
`errno` are not part of the statement.
-/

namespace LibcMath

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

variable {fmt : FloatFormat}

/-- The rounding directions selectable through `fesetround`. -/
def cModes : Set IEEERoundingMode := {.nearest, .towardZero, .up, .down}

/-- Two bit patterns denote the same value: they are equal, or both are NaNs. NaN signs and
payloads, and the distinction between quiet and signaling NaNs, are ignored. -/
def SameValue (a b : Model fmt) : Prop :=
  a = b ∨ (a.isNaN = true ∧ b.isNaN = true)

/-- The mathematical description of a unary function in format `fmt`. A NaN argument always gives
NaN. -/
structure Spec (fmt : FloatFormat) where
  /-- The real function being approximated. -/
  real : ℝ → ℝ
  /-- The result at `+0` and `-0`. -/
  atZero : (negative : Bool) → Model fmt
  /-- The result at `+∞` and `-∞`. -/
  atInf : (negative : Bool) → Model fmt
  /-- Results at nonzero finite arguments that are not obtained by rounding `real`: arguments
  outside the domain, poles, and arguments where `real` is exactly zero. -/
  exact : ℝ → Option (Model fmt)

/-- The result a correctly rounded implementation returns, up to `SameValue`. -/
noncomputable def Spec.eval (S : Spec fmt) (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  if x.isNaN then Model.canonicalNaN fmt
  else if x.isInfinite then S.atInf x.signBit
  else if x.isZero then S.atZero x.signBit
  else (S.exact x.toReal).getD (Model.roundReal fmt mode (S.real x.toReal))

/-- `impl` is a correctly rounded implementation of `S` under every rounding direction in `modes`:
on every input it has a result, and the result is the one `S` prescribes.

The implementation receives the rounding direction in effect, which for code running on a
floating-point unit is the dynamic rounding mode. It returns `none` when it reaches an operation
that its language leaves undefined, so a correctly rounded implementation never does. -/
def CorrectlyRounded (S : Spec fmt) (modes : Set IEEERoundingMode)
    (impl : IEEERoundingMode → Model fmt → Option (Model fmt)) : Prop :=
  ∀ mode ∈ modes, ∀ x, ∃ y, impl mode x = some y ∧ SameValue y (S.eval mode x)

/-- Checks that two floating-point pairs match componentwise up to `SameValue`. -/
@[grind]
def SamePairValue (a b : Model fmt × Model fmt) : Prop :=
  SameValue a.1 b.1 ∧ SameValue a.2 b.2

/-- Checks that `impl` succeeds on every input and mode and satisfies `rel` against `spec`. -/
def FnCorrectlyRounded {α β : Type} (rel : β → β → Prop)
    (spec : IEEERoundingMode → α → β) (modes : Set IEEERoundingMode)
    (impl : IEEERoundingMode → α → Option β) : Prop :=
  ∀ mode ∈ modes, ∀ x, ∃ y, impl mode x = some y ∧ rel y (spec mode x)

/-- Checks that a unary floating-point kernel matches `spec` up to `SameValue`. -/
def UnaryFnCorrectlyRounded (spec : IEEERoundingMode → Model fmt → Model fmt)
    (modes : Set IEEERoundingMode)
    (impl : IEEERoundingMode → Model fmt → Option (Model fmt)) : Prop :=
  FnCorrectlyRounded (SameValue (fmt := fmt)) spec modes impl

/-- Checks that a binary floating-point kernel matches `spec` up to `SameValue`. -/
def BinaryFnCorrectlyRounded (spec : IEEERoundingMode → Model fmt → Model fmt → Model fmt)
    (modes : Set IEEERoundingMode)
    (impl : IEEERoundingMode → Model fmt → Model fmt → Option (Model fmt)) : Prop :=
  FnCorrectlyRounded (SameValue (fmt := fmt))
    (fun mode (p : Model fmt × Model fmt) => spec mode p.1 p.2) modes
    (fun mode p => impl mode p.1 p.2)

/-- Checks that a ternary floating-point kernel matches `spec` up to `SameValue`. -/
def TernaryFnCorrectlyRounded
    (spec : IEEERoundingMode → Model fmt → Model fmt → Model fmt → Model fmt)
    (modes : Set IEEERoundingMode)
    (impl : IEEERoundingMode → Model fmt → Model fmt → Model fmt → Option (Model fmt)) : Prop :=
  FnCorrectlyRounded (SameValue (fmt := fmt))
    (fun mode (p : Model fmt × Model fmt × Model fmt) => spec mode p.1 p.2.1 p.2.2) modes
    (fun mode p => impl mode p.1 p.2.1 p.2.2)

end LibcMath
