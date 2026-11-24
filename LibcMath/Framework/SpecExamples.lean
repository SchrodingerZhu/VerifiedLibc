import LibcMath.Framework.Specs

/-!
# Checks of the specifications on special arguments
-/

namespace LibcMath

open FloatLib.Floats.Formats.BinaryInterchange Model

example (mode : IEEERoundingMode) :
    (Spec.exp .binary32).eval mode (negInf .binary32) = posZero .binary32 := by
  have h₁ : (negInf FloatFormat.binary32).isNaN = false := by decide
  have h₂ : (negInf FloatFormat.binary32).isInfinite = true := by decide
  have h₃ : (negInf FloatFormat.binary32).signBit = true := by decide
  simp [Spec.eval, Spec.exp, h₁, h₂, h₃]

example (mode : IEEERoundingMode) :
    (Spec.log .binary64).eval mode (negZero .binary64) = negInf .binary64 := by
  have h₁ : (negZero FloatFormat.binary64).isNaN = false := by decide
  have h₂ : (negZero FloatFormat.binary64).isInfinite = false := by decide
  have h₃ : (negZero FloatFormat.binary64).isZero = true := by decide
  simp [Spec.eval, Spec.log, h₁, h₂, h₃]

end LibcMath
