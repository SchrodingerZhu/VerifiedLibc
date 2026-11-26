import LibcMath.Kernels.Fmaf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `fmaf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Fmaf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fmaf.Generated

/-- Correct rounding of `fmaf` (`generic_sse2`) in all four C modes. -/
def FmafGenericSse2CorrectlyRounded : Prop :=
  TernaryFnCorrectlyRounded FloatLibSpec.fma cModes GenericSse2.kernel.eval

/-- Correct rounding of `fmaf` (`sse42`) in all four C modes. -/
def FmafSse42CorrectlyRounded : Prop :=
  TernaryFnCorrectlyRounded FloatLibSpec.fma cModes Sse42.kernel.eval

/-- Correct rounding of `fmaf` (`avx2_fma`) in all four C modes. -/
def FmafAvx2FmaCorrectlyRounded : Prop :=
  TernaryFnCorrectlyRounded FloatLibSpec.fma cModes Avx2Fma.kernel.eval

/-- Correct rounding of `fmaf` (`aarch64`) in all four C modes. -/
def FmafAArch64CorrectlyRounded : Prop :=
  TernaryFnCorrectlyRounded FloatLibSpec.fma cModes AArch64.kernel.eval

end LibcMath.Kernels.Fmaf
