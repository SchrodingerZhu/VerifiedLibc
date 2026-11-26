import LibcMath.Kernels.Roundf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `roundf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Roundf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Roundf.Generated

/-- Correct rounding of `roundf` (`generic_sse2`) in all four C modes. -/
def RoundfGenericSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.round cModes GenericSse2.kernel.eval

/-- Correct rounding of `roundf` (`sse42`) in all four C modes. -/
def RoundfSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.round cModes Sse42.kernel.eval

/-- Correct rounding of `roundf` (`avx2_fma`) in all four C modes. -/
def RoundfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.round cModes Avx2Fma.kernel.eval

/-- Correct rounding of `roundf` (`aarch64`) in all four C modes. -/
def RoundfAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.round cModes AArch64.kernel.eval

end LibcMath.Kernels.Roundf
