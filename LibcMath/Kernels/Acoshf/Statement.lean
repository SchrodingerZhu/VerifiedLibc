import LibcMath.Kernels.Acoshf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `acoshf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Acoshf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Acoshf.Generated

/-- Correct rounding of `acoshf` (`sse2`) in all four C modes. -/
def AcoshfSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.acosh cModes Sse2.kernel.eval

/-- Correct rounding of `acoshf` (`sse42`) in all four C modes. -/
def AcoshfSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.acosh cModes Sse42.kernel.eval

/-- Correct rounding of `acoshf` (`avx2_fma`) in all four C modes. -/
def AcoshfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.acosh cModes Avx2Fma.kernel.eval

/-- Correct rounding of `acoshf` (`aarch64`) in all four C modes. -/
def AcoshfAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.acosh cModes AArch64.kernel.eval

end LibcMath.Kernels.Acoshf
