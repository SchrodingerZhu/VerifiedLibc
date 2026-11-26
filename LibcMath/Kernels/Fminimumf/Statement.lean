import LibcMath.Kernels.Fminimumf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `fminimumf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Fminimumf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fminimumf.Generated

/-- Correct rounding of `fminimumf` (`generic_sse2`) in all four C modes. -/
def FminimumfGenericSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fminimum cModes GenericSse2.kernel.eval

/-- Correct rounding of `fminimumf` (`sse42`) in all four C modes. -/
def FminimumfSse42CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fminimum cModes Sse42.kernel.eval

/-- Correct rounding of `fminimumf` (`avx2_fma`) in all four C modes. -/
def FminimumfAvx2FmaCorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fminimum cModes Avx2Fma.kernel.eval

/-- Correct rounding of `fminimumf` (`aarch64`) in all four C modes. -/
def FminimumfAArch64CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fminimum cModes AArch64.kernel.eval

end LibcMath.Kernels.Fminimumf
