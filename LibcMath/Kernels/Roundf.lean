import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Roundf.Generated.GenericSse2
import LibcMath.Kernels.Roundf.Generated.AArch64

/-!
# Extracted `roundf` microarch plans

Collects 2 extracted LLVM libc `roundf` plans and states plan-qualified obligations.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Roundf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Roundf.Generated

/-- Lists all 2 extracted `roundf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ GenericSse2.kernel
  , AArch64.kernel ]

/-- Correct rounding of `roundf` (`generic_sse2`) in all four C modes. -/
def RoundfGenericSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.round cModes GenericSse2.kernel.eval

/-- **Open.** Prove `roundf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem roundfGenericSse2_correctlyRounded : RoundfGenericSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `roundf` (`aarch64`) in all four C modes. -/
def RoundfAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.round cModes AArch64.kernel.eval

/-- **Open.** Prove `roundf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem roundfAArch64_correctlyRounded : RoundfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Roundf.roundfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms roundfGenericSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Roundf.roundfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms roundfAArch64_correctlyRounded

end LibcMath.Kernels.Roundf
