import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Fminf.Generated.GenericSse2

/-!
# Extracted `fminf` microarch plans

Collects 1 extracted LLVM libc `fminf` plans and states plan-qualified obligations.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Fminf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fminf.Generated

/-- Lists all 1 extracted `fminf` plans. -/
def allPlans : List (BinaryKernel .binary32) :=
  [ GenericSse2.kernel ]

/-- Correct rounding of `fminf` (`generic_sse2`) in all four C modes. -/
def FminfGenericSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fmin cModes GenericSse2.kernel.eval

/-- **Open.** Prove `fminf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem fminfGenericSse2_correctlyRounded : FminfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fminf.fminfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fminfGenericSse2_correctlyRounded

end LibcMath.Kernels.Fminf
