import LibcMath.Kernels.FminimumMagNumf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `fminimum_mag_numf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.FminimumMagNumf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FminimumMagNumf.Generated

/-- Correct rounding of `fminimum_mag_numf` (`generic_sse2`) in all four C modes. -/
def FminimumMagNumfGenericSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fminimumMagNum cModes GenericSse2.kernel.eval

/-- Correct rounding of `fminimum_mag_numf` (`sse42`) in all four C modes. -/
def FminimumMagNumfSse42CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fminimumMagNum cModes Sse42.kernel.eval

/-- Correct rounding of `fminimum_mag_numf` (`avx2_fma`) in all four C modes. -/
def FminimumMagNumfAvx2FmaCorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fminimumMagNum cModes Avx2Fma.kernel.eval

/-- Correct rounding of `fminimum_mag_numf` (`aarch64`) in all four C modes. -/
def FminimumMagNumfAArch64CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fminimumMagNum cModes AArch64.kernel.eval

end LibcMath.Kernels.FminimumMagNumf
