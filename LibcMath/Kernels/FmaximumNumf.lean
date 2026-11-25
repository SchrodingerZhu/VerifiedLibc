import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.FmaximumNumf.Generated.GenericSse2

/-!
# Extracted `fmaximum_numf` microarch plans

Collects 1 extracted LLVM libc `fmaximum_numf` plans and states plan-qualified obligations.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.FmaximumNumf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FmaximumNumf.Generated

/-- Lists all 1 extracted `fmaximum_numf` plans. -/
def allPlans : List (BinaryKernel .binary32) :=
  [ GenericSse2.kernel ]

/-- Correct rounding of `fmaximum_numf` (`generic_sse2`) in all four C modes. -/
def FmaximumNumfGenericSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fmaximumNum cModes GenericSse2.kernel.eval

/-- **Open.** Prove `fmaximum_numf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem fmaximum_numfGenericSse2_correctlyRounded : FmaximumNumfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.FmaximumNumf.fmaximum_numfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmaximum_numfGenericSse2_correctlyRounded

end LibcMath.Kernels.FmaximumNumf
