import LibcMath.Kernels.Atanhf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `atanhf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Atanhf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Atanhf.Generated

/-- Correct rounding of `atanhf` (`sse2`) in all four C modes. -/
def AtanhfSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.atanh cModes Sse2.kernel.eval

/-- Correct rounding of `atanhf` (`sse42`) in all four C modes. -/
def AtanhfSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.atanh cModes Sse42.kernel.eval

/-- Correct rounding of `atanhf` (`avx2_fma`) in all four C modes. -/
def AtanhfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.atanh cModes Avx2Fma.kernel.eval

/-- Correct rounding of `atanhf` (`aarch64`) in all four C modes. -/
def AtanhfAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.atanh cModes AArch64.kernel.eval

end LibcMath.Kernels.Atanhf
