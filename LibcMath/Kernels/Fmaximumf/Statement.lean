import LibcMath.Kernels.Fmaximumf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `fmaximumf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Fmaximumf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fmaximumf.Generated

/-- Correct rounding of `fmaximumf` (`generic_sse2`) in all four C modes. -/
def FmaximumfGenericSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fmaximum cModes GenericSse2.kernel.eval

/-- Correct rounding of `fmaximumf` (`sse42`) in all four C modes. -/
def FmaximumfSse42CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fmaximum cModes Sse42.kernel.eval

/-- Correct rounding of `fmaximumf` (`avx2_fma`) in all four C modes. -/
def FmaximumfAvx2FmaCorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fmaximum cModes Avx2Fma.kernel.eval

/-- Correct rounding of `fmaximumf` (`aarch64`) in all four C modes. -/
def FmaximumfAArch64CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fmaximum cModes AArch64.kernel.eval

end LibcMath.Kernels.Fmaximumf
