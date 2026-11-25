import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Truncf.Generated.GenericSse2
import LibcMath.Kernels.Truncf.Generated.BuiltinSse42

/-!
# Extracted `truncf` microarch plans

Collects 2 extracted LLVM libc `truncf` plans and states plan-qualified obligations.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Truncf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Truncf.Generated

/-- Lists all 2 extracted `truncf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ GenericSse2.kernel
  , BuiltinSse42.kernel ]

/-- Correct rounding of `truncf` (`generic_sse2`) in all four C modes. -/
def TruncfGenericSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.trunc cModes GenericSse2.kernel.eval

/-- **Open.** Prove `truncf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem truncfGenericSse2_correctlyRounded : TruncfGenericSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `truncf` (`builtin_sse42`) in all four C modes. -/
def TruncfBuiltinSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.trunc cModes BuiltinSse42.kernel.eval

/-- **Open.** Prove `truncf` (`builtin_sse42`) is correctly rounded in all four C modes. -/
theorem truncfBuiltinSse42_correctlyRounded : TruncfBuiltinSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Truncf.truncfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms truncfGenericSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Truncf.truncfBuiltinSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms truncfBuiltinSse42_correctlyRounded

end LibcMath.Kernels.Truncf
