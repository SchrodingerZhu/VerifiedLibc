import LibcMath.Kernels.Expm1f.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `expm1f` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Expm1f

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Expm1f.Generated

/-- Correct rounding of `expm1f` (`sse2`) across all four C rounding modes. -/
def Expm1fSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.expm1 cModes Sse2.kernel.eval

/-- Correct rounding of `expm1f` (`sse42`) across all four C rounding modes. -/
def Expm1fSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.expm1 cModes Sse42.kernel.eval

/-- Correct rounding of `expm1f` (`avx2_fma`) across all four C rounding modes. -/
def Expm1fAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.expm1 cModes Avx2Fma.kernel.eval

/-- Correct rounding of `expm1f` (`aarch64`) across all four C rounding modes. -/
def Expm1fAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.expm1 cModes AArch64.kernel.eval

end LibcMath.Kernels.Expm1f
