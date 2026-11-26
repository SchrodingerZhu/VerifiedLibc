import LibcMath.Kernels.Rintf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `rintf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Rintf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Rintf.Generated

/-- Correct rounding of `rintf` (`generic_sse2`) in all four C modes. -/
def RintfGenericSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.rint cModes GenericSse2.kernel.eval

/-- Correct rounding of `rintf` (`builtin_sse42`) in all four C modes. -/
def RintfBuiltinSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.rint cModes BuiltinSse42.kernel.eval

/-- Correct rounding of `rintf` (`avx2_fma`) in all four C modes. -/
def RintfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.rint cModes Avx2Fma.kernel.eval

/-- Correct rounding of `rintf` (`aarch64`) in all four C modes. -/
def RintfAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.rint cModes AArch64.kernel.eval

end LibcMath.Kernels.Rintf
