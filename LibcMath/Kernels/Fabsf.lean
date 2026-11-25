import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Fabsf.Generated.GenericSse2

/-!
# Extracted `fabsf` microarch plans

Collects 1 extracted LLVM libc `fabsf` plans and states plan-qualified obligations.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Fabsf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fabsf.Generated

/-- Lists all 1 extracted `fabsf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ GenericSse2.kernel ]

/-- Correct rounding of `fabsf` (`generic_sse2`) in all four C modes. -/
def FabsfGenericSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.fabs cModes GenericSse2.kernel.eval

/-- **Open.** Prove `fabsf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem fabsfGenericSse2_correctlyRounded : FabsfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fabsf.fabsfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fabsfGenericSse2_correctlyRounded

end LibcMath.Kernels.Fabsf
