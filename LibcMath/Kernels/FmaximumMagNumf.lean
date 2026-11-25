import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.FmaximumMagNumf.Generated.GenericSse2

/-!
# Extracted `fmaximum_mag_numf` microarch plans

Collects 1 extracted LLVM libc `fmaximum_mag_numf` plans and states plan-qualified obligations.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.FmaximumMagNumf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FmaximumMagNumf.Generated

/-- Lists all 1 extracted `fmaximum_mag_numf` plans. -/
def allPlans : List (BinaryKernel .binary32) :=
  [ GenericSse2.kernel ]

/-- Correct rounding of `fmaximum_mag_numf` (`generic_sse2`) in all four C modes. -/
def FmaximumMagNumfGenericSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fmaximumMagNum cModes GenericSse2.kernel.eval

/-- **Open.** Prove `fmaximum_mag_numf` (`generic_sse2`) is correctly rounded in all four C modes.
-/
theorem fmaximum_mag_numfGenericSse2_correctlyRounded :
    FmaximumMagNumfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.FmaximumMagNumf.fmaximum_mag_numfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmaximum_mag_numfGenericSse2_correctlyRounded

end LibcMath.Kernels.FmaximumMagNumf
