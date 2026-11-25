import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.FminimumNumf.Generated.GenericSse2

/-!
# Extracted `fminimum_numf` microarch plans

Collects 1 extracted LLVM libc `fminimum_numf` plans and states plan-qualified obligations.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.FminimumNumf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FminimumNumf.Generated

/-- Lists all 1 extracted `fminimum_numf` plans. -/
def allPlans : List (BinaryKernel .binary32) :=
  [ GenericSse2.kernel ]

/-- Correct rounding of `fminimum_numf` (`generic_sse2`) in all four C modes. -/
def FminimumNumfGenericSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fminimumNum cModes GenericSse2.kernel.eval

/-- **Open.** Prove `fminimum_numf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem fminimum_numfGenericSse2_correctlyRounded : FminimumNumfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.FminimumNumf.fminimum_numfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fminimum_numfGenericSse2_correctlyRounded

end LibcMath.Kernels.FminimumNumf
