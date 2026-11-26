import LibcMath.Kernels.Fabsf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `fabsf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Fabsf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fabsf.Generated

/-- Correct rounding of `fabsf` (`generic_sse2`) in all four C modes. -/
def FabsfGenericSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.fabs cModes GenericSse2.kernel.eval

/-- Correct rounding of `fabsf` (`sse42`) in all four C modes. -/
def FabsfSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.fabs cModes Sse42.kernel.eval

/-- Correct rounding of `fabsf` (`avx2_fma`) in all four C modes. -/
def FabsfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.fabs cModes Avx2Fma.kernel.eval

/-- Correct rounding of `fabsf` (`aarch64`) in all four C modes. -/
def FabsfAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.fabs cModes AArch64.kernel.eval

end LibcMath.Kernels.Fabsf
