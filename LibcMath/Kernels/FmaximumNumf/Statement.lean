import LibcMath.Kernels.FmaximumNumf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `fmaximum_numf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.FmaximumNumf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FmaximumNumf.Generated

/-- Correct rounding of `fmaximum_numf` (`generic_sse2`) in all four C modes. -/
def FmaximumNumfGenericSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fmaximumNum cModes GenericSse2.kernel.eval

/-- Correct rounding of `fmaximum_numf` (`sse42`) in all four C modes. -/
def FmaximumNumfSse42CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fmaximumNum cModes Sse42.kernel.eval

/-- Correct rounding of `fmaximum_numf` (`avx2_fma`) in all four C modes. -/
def FmaximumNumfAvx2FmaCorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fmaximumNum cModes Avx2Fma.kernel.eval

/-- Correct rounding of `fmaximum_numf` (`aarch64`) in all four C modes. -/
def FmaximumNumfAArch64CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fmaximumNum cModes AArch64.kernel.eval

end LibcMath.Kernels.FmaximumNumf
