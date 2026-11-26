import LibcMath.Kernels.Asinhf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `asinhf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Asinhf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Asinhf.Generated

/-- Correct rounding of `asinhf` (`sse2`) in all four C modes. -/
def AsinhfSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.asinh cModes Sse2.kernel.eval

/-- Correct rounding of `asinhf` (`sse42`) in all four C modes. -/
def AsinhfSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.asinh cModes Sse42.kernel.eval

/-- Correct rounding of `asinhf` (`avx2_fma`) in all four C modes. -/
def AsinhfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.asinh cModes Avx2Fma.kernel.eval

/-- Correct rounding of `asinhf` (`aarch64`) in all four C modes. -/
def AsinhfAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.asinh cModes AArch64.kernel.eval

end LibcMath.Kernels.Asinhf
