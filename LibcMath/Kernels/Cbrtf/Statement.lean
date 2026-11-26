import LibcMath.Kernels.Cbrtf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `cbrtf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Cbrtf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Cbrtf.Generated

/-- Correct rounding of `cbrtf` (`sse2`) in all four C modes. -/
def CbrtfSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.cbrt cModes Sse2.kernel.eval

/-- Correct rounding of `cbrtf` (`sse42`) in all four C modes. -/
def CbrtfSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.cbrt cModes Sse42.kernel.eval

/-- Correct rounding of `cbrtf` (`avx2_fma`) in all four C modes. -/
def CbrtfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.cbrt cModes Avx2Fma.kernel.eval

/-- Correct rounding of `cbrtf` (`aarch64`) in all four C modes. -/
def CbrtfAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.cbrt cModes AArch64.kernel.eval

end LibcMath.Kernels.Cbrtf
