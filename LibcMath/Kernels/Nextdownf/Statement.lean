import LibcMath.Kernels.Nextdownf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `nextdownf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Nextdownf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Nextdownf.Generated

/-- Correct rounding of `nextdownf` (`generic_sse2`) in all four C modes. -/
def NextdownfGenericSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.nextdown cModes GenericSse2.kernel.eval

/-- Correct rounding of `nextdownf` (`sse42`) in all four C modes. -/
def NextdownfSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.nextdown cModes Sse42.kernel.eval

/-- Correct rounding of `nextdownf` (`avx2_fma`) in all four C modes. -/
def NextdownfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.nextdown cModes Avx2Fma.kernel.eval

/-- Correct rounding of `nextdownf` (`aarch64`) in all four C modes. -/
def NextdownfAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.nextdown cModes AArch64.kernel.eval

end LibcMath.Kernels.Nextdownf
