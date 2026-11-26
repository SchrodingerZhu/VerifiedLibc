import LibcMath.Kernels.Copysignf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `copysignf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Copysignf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Copysignf.Generated

/-- Correct rounding of `copysignf` (`generic_sse2`) in all four C modes. -/
def CopysignfGenericSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.copysign cModes GenericSse2.kernel.eval

/-- Correct rounding of `copysignf` (`sse42`) in all four C modes. -/
def CopysignfSse42CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.copysign cModes Sse42.kernel.eval

/-- Correct rounding of `copysignf` (`avx2_fma`) in all four C modes. -/
def CopysignfAvx2FmaCorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.copysign cModes Avx2Fma.kernel.eval

/-- Correct rounding of `copysignf` (`aarch64`) in all four C modes. -/
def CopysignfAArch64CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.copysign cModes AArch64.kernel.eval

end LibcMath.Kernels.Copysignf
