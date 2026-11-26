import LibcMath.Kernels.FminimumNumf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `fminimum_numf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.FminimumNumf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FminimumNumf.Generated

/-- Correct rounding of `fminimum_numf` (`generic_sse2`) in all four C modes. -/
def FminimumNumfGenericSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fminimumNum cModes GenericSse2.kernel.eval

/-- Correct rounding of `fminimum_numf` (`sse42`) in all four C modes. -/
def FminimumNumfSse42CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fminimumNum cModes Sse42.kernel.eval

/-- Correct rounding of `fminimum_numf` (`avx2_fma`) in all four C modes. -/
def FminimumNumfAvx2FmaCorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fminimumNum cModes Avx2Fma.kernel.eval

/-- Correct rounding of `fminimum_numf` (`aarch64`) in all four C modes. -/
def FminimumNumfAArch64CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fminimumNum cModes AArch64.kernel.eval

end LibcMath.Kernels.FminimumNumf
