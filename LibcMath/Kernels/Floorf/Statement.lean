import LibcMath.Kernels.Floorf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `floorf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Floorf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Floorf.Generated

/-- Correct rounding of `floorf` (`generic_sse2`) in all four C modes. -/
def FloorfGenericSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.floor cModes GenericSse2.kernel.eval

/-- Correct rounding of `floorf` (`builtin_sse42`) in all four C modes. -/
def FloorfBuiltinSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.floor cModes BuiltinSse42.kernel.eval

/-- Correct rounding of `floorf` (`avx2_fma`) in all four C modes. -/
def FloorfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.floor cModes Avx2Fma.kernel.eval

/-- Correct rounding of `floorf` (`aarch64`) in all four C modes. -/
def FloorfAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.floor cModes AArch64.kernel.eval

end LibcMath.Kernels.Floorf
