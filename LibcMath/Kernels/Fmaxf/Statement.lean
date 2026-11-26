import LibcMath.Kernels.Fmaxf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `fmaxf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Fmaxf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fmaxf.Generated

/-- Correct rounding of `fmaxf` (`generic_sse2`) in all four C modes. -/
def FmaxfGenericSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fmax cModes GenericSse2.kernel.eval

/-- Correct rounding of `fmaxf` (`sse42`) in all four C modes. -/
def FmaxfSse42CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fmax cModes Sse42.kernel.eval

/-- Correct rounding of `fmaxf` (`avx2_fma`) in all four C modes. -/
def FmaxfAvx2FmaCorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fmax cModes Avx2Fma.kernel.eval

/-- Correct rounding of `fmaxf` (`aarch64`) in all four C modes. -/
def FmaxfAArch64CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fmax cModes AArch64.kernel.eval

end LibcMath.Kernels.Fmaxf
