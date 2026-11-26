import LibcMath.Kernels.Rsqrtf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `rsqrtf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Rsqrtf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Rsqrtf.Generated

/-- Correct rounding of `rsqrtf` (`sse2`) in all four C modes. -/
def RsqrtfSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.rsqrt cModes Sse2.kernel.eval

/-- Correct rounding of `rsqrtf` (`sse42`) in all four C modes. -/
def RsqrtfSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.rsqrt cModes Sse42.kernel.eval

/-- Correct rounding of `rsqrtf` (`avx2_fma`) in all four C modes. -/
def RsqrtfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.rsqrt cModes Avx2Fma.kernel.eval

/-- Correct rounding of `rsqrtf` (`aarch64`) in all four C modes. -/
def RsqrtfAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.rsqrt cModes AArch64.kernel.eval

end LibcMath.Kernels.Rsqrtf
