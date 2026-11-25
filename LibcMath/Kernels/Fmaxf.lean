import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Fmaxf.Generated.GenericSse2

/-!
# Extracted `fmaxf` microarch plans

Collects 1 extracted LLVM libc `fmaxf` plans and states plan-qualified obligations.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Fmaxf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fmaxf.Generated

/-- Lists all 1 extracted `fmaxf` plans. -/
def allPlans : List (BinaryKernel .binary32) :=
  [ GenericSse2.kernel ]

/-- Correct rounding of `fmaxf` (`generic_sse2`) in all four C modes. -/
def FmaxfGenericSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fmax cModes GenericSse2.kernel.eval

/-- **Open.** Prove `fmaxf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem fmaxfGenericSse2_correctlyRounded : FmaxfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fmaxf.fmaxfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmaxfGenericSse2_correctlyRounded

end LibcMath.Kernels.Fmaxf
