import LibcMath.Kernels.Coshf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `coshf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Coshf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Coshf.Generated

/-- Correct rounding of `coshf` (`sse2`) in all four C modes. -/
def CoshfSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.cosh cModes Sse2.kernel.eval

/-- Correct rounding of `coshf` (`sse42`) in all four C modes. -/
def CoshfSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.cosh cModes Sse42.kernel.eval

/-- Correct rounding of `coshf` (`avx2_fma`) in all four C modes. -/
def CoshfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.cosh cModes Avx2Fma.kernel.eval

/-- Correct rounding of `coshf` (`aarch64`) in all four C modes. -/
def CoshfAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.cosh cModes AArch64.kernel.eval

end LibcMath.Kernels.Coshf
