import LibcMath.Kernels.Acosf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `acosf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Acosf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Acosf.Generated

/-- Correct rounding of `acosf` (`sse2`) in all four C modes. -/
def AcosfSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.acos cModes Sse2.kernel.eval

/-- Correct rounding of `acosf` (`sse42`) in all four C modes. -/
def AcosfSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.acos cModes Sse42.kernel.eval

/-- Correct rounding of `acosf` (`avx2_fma`) in all four C modes. -/
def AcosfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.acos cModes Avx2Fma.kernel.eval

/-- Correct rounding of `acosf` (`aarch64`) in all four C modes. -/
def AcosfAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.acos cModes AArch64.kernel.eval

end LibcMath.Kernels.Acosf
