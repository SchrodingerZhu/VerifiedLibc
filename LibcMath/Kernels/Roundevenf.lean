import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Roundevenf.Generated.GenericSse2
import LibcMath.Kernels.Roundevenf.Generated.BuiltinSse42

/-!
# Extracted `roundevenf` microarch plans

Collects 2 extracted LLVM libc `roundevenf` plans and states plan-qualified obligations.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Roundevenf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Roundevenf.Generated

/-- Lists all 2 extracted `roundevenf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ GenericSse2.kernel
  , BuiltinSse42.kernel ]

/-- Correct rounding of `roundevenf` (`generic_sse2`) in all four C modes. -/
def RoundevenfGenericSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.roundeven cModes GenericSse2.kernel.eval

/-- **Open.** Prove `roundevenf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem roundevenfGenericSse2_correctlyRounded : RoundevenfGenericSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `roundevenf` (`builtin_sse42`) in all four C modes. -/
def RoundevenfBuiltinSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.roundeven cModes BuiltinSse42.kernel.eval

/-- **Open.** Prove `roundevenf` (`builtin_sse42`) is correctly rounded in all four C modes. -/
theorem roundevenfBuiltinSse42_correctlyRounded : RoundevenfBuiltinSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Roundevenf.roundevenfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms roundevenfGenericSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Roundevenf.roundevenfBuiltinSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms roundevenfBuiltinSse42_correctlyRounded

end LibcMath.Kernels.Roundevenf
