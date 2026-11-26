import LibcMath.Kernels.Ceilf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `ceilf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Ceilf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Ceilf.Generated

/-- Correct rounding of `ceilf` (`generic_sse2`) in all four C modes. -/
def CeilfGenericSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.ceil cModes GenericSse2.kernel.eval

/-- Correct rounding of `ceilf` (`builtin_sse42`) in all four C modes. -/
def CeilfBuiltinSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.ceil cModes BuiltinSse42.kernel.eval

/-- Correct rounding of `ceilf` (`avx2_fma`) in all four C modes. -/
def CeilfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.ceil cModes Avx2Fma.kernel.eval

/-- Correct rounding of `ceilf` (`aarch64`) in all four C modes. -/
def CeilfAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.ceil cModes AArch64.kernel.eval

end LibcMath.Kernels.Ceilf
