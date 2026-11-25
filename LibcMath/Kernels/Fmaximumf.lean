import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Fmaximumf.Generated.GenericSse2

/-!
# Extracted `fmaximumf` microarch plans

Collects 1 extracted LLVM libc `fmaximumf` plans and states plan-qualified obligations.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Fmaximumf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fmaximumf.Generated

/-- Lists all 1 extracted `fmaximumf` plans. -/
def allPlans : List (BinaryKernel .binary32) :=
  [ GenericSse2.kernel ]

/-- Correct rounding of `fmaximumf` (`generic_sse2`) in all four C modes. -/
def FmaximumfGenericSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fmaximum cModes GenericSse2.kernel.eval

/-- **Open.** Prove `fmaximumf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem fmaximumfGenericSse2_correctlyRounded : FmaximumfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fmaximumf.fmaximumfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmaximumfGenericSse2_correctlyRounded

end LibcMath.Kernels.Fmaximumf
