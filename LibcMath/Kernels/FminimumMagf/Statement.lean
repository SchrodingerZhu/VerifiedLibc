import LibcMath.Kernels.FminimumMagf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `fminimum_magf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.FminimumMagf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FminimumMagf.Generated

/-- Correct rounding of `fminimum_magf` (`generic_sse2`) in all four C modes. -/
def FminimumMagfGenericSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fminimumMag cModes GenericSse2.kernel.eval

/-- Correct rounding of `fminimum_magf` (`sse42`) in all four C modes. -/
def FminimumMagfSse42CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fminimumMag cModes Sse42.kernel.eval

/-- Correct rounding of `fminimum_magf` (`avx2_fma`) in all four C modes. -/
def FminimumMagfAvx2FmaCorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fminimumMag cModes Avx2Fma.kernel.eval

/-- Correct rounding of `fminimum_magf` (`aarch64`) in all four C modes. -/
def FminimumMagfAArch64CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fminimumMag cModes AArch64.kernel.eval

end LibcMath.Kernels.FminimumMagf
