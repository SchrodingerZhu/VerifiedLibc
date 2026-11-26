import LibcMath.Kernels.Fminf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `fminf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Fminf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fminf.Generated

/-- Correct rounding of `fminf` (`generic_sse2`) in all four C modes. -/
def FminfGenericSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fmin cModes GenericSse2.kernel.eval

/-- Correct rounding of `fminf` (`sse42`) in all four C modes. -/
def FminfSse42CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fmin cModes Sse42.kernel.eval

/-- Correct rounding of `fminf` (`avx2_fma`) in all four C modes. -/
def FminfAvx2FmaCorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fmin cModes Avx2Fma.kernel.eval

/-- Correct rounding of `fminf` (`aarch64`) in all four C modes. -/
def FminfAArch64CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fmin cModes AArch64.kernel.eval

end LibcMath.Kernels.Fminf
