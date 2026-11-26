import LibcMath.Kernels.Sinpif.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `sinpif` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Sinpif

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Sinpif.Generated

/-- Correct rounding of `sinpif` (`sse2`) in all four C modes. -/
def SinpifSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.sinpi cModes Sse2.kernel.eval

/-- Correct rounding of `sinpif` (`sse42`) in all four C modes. -/
def SinpifSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.sinpi cModes Sse42.kernel.eval

/-- Correct rounding of `sinpif` (`avx2_fma`) in all four C modes. -/
def SinpifAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.sinpi cModes Avx2Fma.kernel.eval

/-- Correct rounding of `sinpif` (`aarch64`) in all four C modes. -/
def SinpifAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.sinpi cModes AArch64.kernel.eval

end LibcMath.Kernels.Sinpif
