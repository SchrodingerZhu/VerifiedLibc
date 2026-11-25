import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Ceilf.Generated.GenericSse2
import LibcMath.Kernels.Ceilf.Generated.BuiltinSse42

/-!
# Extracted `ceilf` microarch plans

Collects 2 extracted LLVM libc `ceilf` plans and states plan-qualified obligations.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Ceilf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Ceilf.Generated

/-- Lists all 2 extracted `ceilf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ GenericSse2.kernel
  , BuiltinSse42.kernel ]

/-- Correct rounding of `ceilf` (`generic_sse2`) in all four C modes. -/
def CeilfGenericSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.ceil cModes GenericSse2.kernel.eval

/-- **Open.** Prove `ceilf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem ceilfGenericSse2_correctlyRounded : CeilfGenericSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `ceilf` (`builtin_sse42`) in all four C modes. -/
def CeilfBuiltinSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.ceil cModes BuiltinSse42.kernel.eval

/-- **Open.** Prove `ceilf` (`builtin_sse42`) is correctly rounded in all four C modes. -/
theorem ceilfBuiltinSse42_correctlyRounded : CeilfBuiltinSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Ceilf.ceilfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms ceilfGenericSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Ceilf.ceilfBuiltinSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms ceilfBuiltinSse42_correctlyRounded

end LibcMath.Kernels.Ceilf
