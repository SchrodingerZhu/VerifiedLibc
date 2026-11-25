import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Fminimumf.Generated.GenericSse2

/-!
# Extracted `fminimumf` microarch plans

Collects 1 extracted LLVM libc `fminimumf` plans and states plan-qualified obligations.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Fminimumf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fminimumf.Generated

/-- Lists all 1 extracted `fminimumf` plans. -/
def allPlans : List (BinaryKernel .binary32) :=
  [ GenericSse2.kernel ]

/-- Correct rounding of `fminimumf` (`generic_sse2`) in all four C modes. -/
def FminimumfGenericSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fminimum cModes GenericSse2.kernel.eval

/-- **Open.** Prove `fminimumf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem fminimumfGenericSse2_correctlyRounded : FminimumfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fminimumf.fminimumfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fminimumfGenericSse2_correctlyRounded

end LibcMath.Kernels.Fminimumf
