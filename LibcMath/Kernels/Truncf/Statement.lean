import LibcMath.Kernels.Truncf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `truncf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Truncf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Truncf.Generated

/-- Correct rounding of `truncf` (`generic_sse2`) in all four C modes. -/
def TruncfGenericSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.trunc cModes GenericSse2.kernel.eval

/-- Correct rounding of `truncf` (`builtin_sse42`) in all four C modes. -/
def TruncfBuiltinSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.trunc cModes BuiltinSse42.kernel.eval

/-- Correct rounding of `truncf` (`avx2_fma`) in all four C modes. -/
def TruncfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.trunc cModes Avx2Fma.kernel.eval

/-- Correct rounding of `truncf` (`aarch64`) in all four C modes. -/
def TruncfAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.trunc cModes AArch64.kernel.eval

end LibcMath.Kernels.Truncf
