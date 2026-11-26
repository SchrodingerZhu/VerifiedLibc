import LibcMath.Kernels.Cospif.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `cospif` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Cospif

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Cospif.Generated

/-- Correct rounding of `cospif` (`sse2`) in all four C modes. -/
def CospifSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.cospi cModes Sse2.kernel.eval

/-- Correct rounding of `cospif` (`sse42`) in all four C modes. -/
def CospifSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.cospi cModes Sse42.kernel.eval

/-- Correct rounding of `cospif` (`avx2_fma`) in all four C modes. -/
def CospifAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.cospi cModes Avx2Fma.kernel.eval

/-- Correct rounding of `cospif` (`aarch64`) in all four C modes. -/
def CospifAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.cospi cModes AArch64.kernel.eval

end LibcMath.Kernels.Cospif
