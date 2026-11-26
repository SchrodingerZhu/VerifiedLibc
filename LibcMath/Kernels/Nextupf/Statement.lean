import LibcMath.Kernels.Nextupf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `nextupf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Nextupf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Nextupf.Generated

/-- Correct rounding of `nextupf` (`generic_sse2`) in all four C modes. -/
def NextupfGenericSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.nextup cModes GenericSse2.kernel.eval

/-- Correct rounding of `nextupf` (`sse42`) in all four C modes. -/
def NextupfSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.nextup cModes Sse42.kernel.eval

/-- Correct rounding of `nextupf` (`avx2_fma`) in all four C modes. -/
def NextupfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.nextup cModes Avx2Fma.kernel.eval

/-- Correct rounding of `nextupf` (`aarch64`) in all four C modes. -/
def NextupfAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.nextup cModes AArch64.kernel.eval

end LibcMath.Kernels.Nextupf
