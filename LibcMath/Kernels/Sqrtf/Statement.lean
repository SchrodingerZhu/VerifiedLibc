import LibcMath.Kernels.Sqrtf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `sqrtf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Sqrtf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Sqrtf.Generated

/-- Correct rounding of `sqrtf` (`x86_sse2`) in all four C modes. -/
def SqrtfX86Sse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.sqrt cModes X86Sse2.kernel.eval

/-- Correct rounding of `sqrtf` (`sse42`) in all four C modes. -/
def SqrtfSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.sqrt cModes Sse42.kernel.eval

/-- Correct rounding of `sqrtf` (`avx2_fma`) in all four C modes. -/
def SqrtfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.sqrt cModes Avx2Fma.kernel.eval

/-- Correct rounding of `sqrtf` (`aarch64`) in all four C modes. -/
def SqrtfAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.sqrt cModes AArch64.kernel.eval

/-- Correct rounding of `sqrtf` (`generic_softfloat`) in all four C modes. -/
def SqrtfGenericSoftFloatCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.sqrt cModes GenericSoftFloat.kernel.eval

end LibcMath.Kernels.Sqrtf
