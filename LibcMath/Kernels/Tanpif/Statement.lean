import LibcMath.Kernels.Tanpif.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `tanpif` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Tanpif

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Tanpif.Generated

/-- Correct rounding of `tanpif` (`sse2`) in all four C modes. -/
def TanpifSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.tanpi cModes Sse2.kernel.eval

/-- Correct rounding of `tanpif` (`sse42`) in all four C modes. -/
def TanpifSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.tanpi cModes Sse42.kernel.eval

/-- Correct rounding of `tanpif` (`avx2_fma`) in all four C modes. -/
def TanpifAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.tanpi cModes Avx2Fma.kernel.eval

/-- Correct rounding of `tanpif` (`aarch64`) in all four C modes. -/
def TanpifAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.tanpi cModes AArch64.kernel.eval

end LibcMath.Kernels.Tanpif
