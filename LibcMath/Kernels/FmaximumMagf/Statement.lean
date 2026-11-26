import LibcMath.Kernels.FmaximumMagf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `fmaximum_magf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.FmaximumMagf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FmaximumMagf.Generated

/-- Correct rounding of `fmaximum_magf` (`generic_sse2`) in all four C modes. -/
def FmaximumMagfGenericSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fmaximumMag cModes GenericSse2.kernel.eval

/-- Correct rounding of `fmaximum_magf` (`sse42`) in all four C modes. -/
def FmaximumMagfSse42CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fmaximumMag cModes Sse42.kernel.eval

/-- Correct rounding of `fmaximum_magf` (`avx2_fma`) in all four C modes. -/
def FmaximumMagfAvx2FmaCorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fmaximumMag cModes Avx2Fma.kernel.eval

/-- Correct rounding of `fmaximum_magf` (`aarch64`) in all four C modes. -/
def FmaximumMagfAArch64CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fmaximumMag cModes AArch64.kernel.eval

end LibcMath.Kernels.FmaximumMagf
