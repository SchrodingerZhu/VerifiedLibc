import LibcMath.Kernels.Fdimf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `fdimf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Fdimf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fdimf.Generated

/-- Correct rounding of `fdimf` (`generic_sse2`) in all four C modes. -/
def FdimfGenericSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fdim cModes GenericSse2.kernel.eval

/-- Correct rounding of `fdimf` (`sse42`) in all four C modes. -/
def FdimfSse42CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fdim cModes Sse42.kernel.eval

/-- Correct rounding of `fdimf` (`avx2_fma`) in all four C modes. -/
def FdimfAvx2FmaCorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fdim cModes Avx2Fma.kernel.eval

/-- Correct rounding of `fdimf` (`aarch64`) in all four C modes. -/
def FdimfAArch64CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fdim cModes AArch64.kernel.eval

end LibcMath.Kernels.Fdimf
