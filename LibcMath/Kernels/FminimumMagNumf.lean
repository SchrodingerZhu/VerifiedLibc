import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.FminimumMagNumf.Generated.GenericSse2

/-!
# Extracted `fminimum_mag_numf` microarch plans

Collects 1 extracted LLVM libc `fminimum_mag_numf` plans and states plan-qualified obligations.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.FminimumMagNumf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FminimumMagNumf.Generated

/-- Lists all 1 extracted `fminimum_mag_numf` plans. -/
def allPlans : List (BinaryKernel .binary32) :=
  [ GenericSse2.kernel ]

/-- Correct rounding of `fminimum_mag_numf` (`generic_sse2`) in all four C modes. -/
def FminimumMagNumfGenericSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fminimumMagNum cModes GenericSse2.kernel.eval

/-- **Open.** Prove `fminimum_mag_numf` (`generic_sse2`) is correctly rounded in all four C modes.
-/
theorem fminimum_mag_numfGenericSse2_correctlyRounded :
    FminimumMagNumfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.FminimumMagNumf.fminimum_mag_numfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fminimum_mag_numfGenericSse2_correctlyRounded

end LibcMath.Kernels.FminimumMagNumf
