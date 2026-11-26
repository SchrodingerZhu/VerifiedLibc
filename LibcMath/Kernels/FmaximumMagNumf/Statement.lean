import LibcMath.Kernels.FmaximumMagNumf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `fmaximum_mag_numf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.FmaximumMagNumf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FmaximumMagNumf.Generated

/-- Correct rounding of `fmaximum_mag_numf` (`generic_sse2`) in all four C modes. -/
def FmaximumMagNumfGenericSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fmaximumMagNum cModes GenericSse2.kernel.eval

/-- Correct rounding of `fmaximum_mag_numf` (`sse42`) in all four C modes. -/
def FmaximumMagNumfSse42CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fmaximumMagNum cModes Sse42.kernel.eval

/-- Correct rounding of `fmaximum_mag_numf` (`avx2_fma`) in all four C modes. -/
def FmaximumMagNumfAvx2FmaCorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fmaximumMagNum cModes Avx2Fma.kernel.eval

/-- Correct rounding of `fmaximum_mag_numf` (`aarch64`) in all four C modes. -/
def FmaximumMagNumfAArch64CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fmaximumMagNum cModes AArch64.kernel.eval

end LibcMath.Kernels.FmaximumMagNumf
