import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Copysignf.Generated.GenericSse2

/-!
# Extracted `copysignf` microarch plans

Collects 1 extracted LLVM libc `copysignf` plans and states plan-qualified obligations.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Copysignf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Copysignf.Generated

/-- Lists all 1 extracted `copysignf` plans. -/
def allPlans : List (BinaryKernel .binary32) :=
  [ GenericSse2.kernel ]

/-- Correct rounding of `copysignf` (`generic_sse2`) in all four C modes. -/
def CopysignfGenericSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.copysign cModes GenericSse2.kernel.eval

/-- **Open.** Prove `copysignf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem copysignfGenericSse2_correctlyRounded : CopysignfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Copysignf.copysignfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms copysignfGenericSse2_correctlyRounded

end LibcMath.Kernels.Copysignf
