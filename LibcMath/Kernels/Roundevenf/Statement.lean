import LibcMath.Kernels.Roundevenf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `roundevenf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Roundevenf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Roundevenf.Generated

/-- Correct rounding of `roundevenf` (`generic_sse2`) in all four C modes. -/
def RoundevenfGenericSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.roundeven cModes GenericSse2.kernel.eval

/-- Correct rounding of `roundevenf` (`builtin_sse42`) in all four C modes. -/
def RoundevenfBuiltinSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.roundeven cModes BuiltinSse42.kernel.eval

/-- Correct rounding of `roundevenf` (`avx2_fma`) in all four C modes. -/
def RoundevenfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.roundeven cModes Avx2Fma.kernel.eval

/-- Correct rounding of `roundevenf` (`aarch64`) in all four C modes. -/
def RoundevenfAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.roundeven cModes AArch64.kernel.eval

end LibcMath.Kernels.Roundevenf
