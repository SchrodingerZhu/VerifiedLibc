import LibcMath.Kernels.Asinf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `asinf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Asinf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Asinf.Generated

/-- Correct rounding of `asinf` (`sse2`) in all four C modes. -/
def AsinfSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.asin cModes Sse2.kernel.eval

/-- Correct rounding of `asinf` (`sse42`) in all four C modes. -/
def AsinfSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.asin cModes Sse42.kernel.eval

/-- Correct rounding of `asinf` (`avx2_fma`) in all four C modes. -/
def AsinfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.asin cModes Avx2Fma.kernel.eval

/-- Correct rounding of `asinf` (`aarch64`) in all four C modes. -/
def AsinfAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.asin cModes AArch64.kernel.eval

end LibcMath.Kernels.Asinf
