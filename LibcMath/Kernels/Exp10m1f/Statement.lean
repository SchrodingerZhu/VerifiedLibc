import LibcMath.Kernels.Exp10m1f.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `exp10m1f` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Exp10m1f

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Exp10m1f.Generated

/-- Correct rounding of `exp10m1f` (`sse2`) across all four C rounding modes. -/
def Exp10m1fSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.exp10m1 cModes Sse2.kernel.eval

/-- Correct rounding of `exp10m1f` (`sse42`) across all four C rounding modes. -/
def Exp10m1fSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.exp10m1 cModes Sse42.kernel.eval

/-- Correct rounding of `exp10m1f` (`avx2_fma`) across all four C rounding modes. -/
def Exp10m1fAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.exp10m1 cModes Avx2Fma.kernel.eval

/-- Correct rounding of `exp10m1f` (`aarch64`) across all four C rounding modes. -/
def Exp10m1fAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.exp10m1 cModes AArch64.kernel.eval

end LibcMath.Kernels.Exp10m1f
