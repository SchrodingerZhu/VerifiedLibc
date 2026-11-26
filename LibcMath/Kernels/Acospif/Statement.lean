import LibcMath.Kernels.Acospif.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `acospif` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Acospif

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Acospif.Generated

/-- Correct rounding of `acospif` (`sse2`) in all four C modes. -/
def AcospifSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.acospi cModes Sse2.kernel.eval

/-- Correct rounding of `acospif` (`sse42`) in all four C modes. -/
def AcospifSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.acospi cModes Sse42.kernel.eval

/-- Correct rounding of `acospif` (`avx2_fma`) in all four C modes. -/
def AcospifAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.acospi cModes Avx2Fma.kernel.eval

/-- Correct rounding of `acospif` (`aarch64`) in all four C modes. -/
def AcospifAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.acospi cModes AArch64.kernel.eval

end LibcMath.Kernels.Acospif
