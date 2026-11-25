import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Floorf.Generated.GenericSse2
import LibcMath.Kernels.Floorf.Generated.BuiltinSse42

/-!
# Extracted `floorf` microarch plans

Collects 2 extracted LLVM libc `floorf` plans and states plan-qualified obligations.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Floorf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Floorf.Generated

/-- Lists all 2 extracted `floorf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ GenericSse2.kernel
  , BuiltinSse42.kernel ]

/-- Correct rounding of `floorf` (`generic_sse2`) in all four C modes. -/
def FloorfGenericSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.floor cModes GenericSse2.kernel.eval

/-- **Open.** Prove `floorf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem floorfGenericSse2_correctlyRounded : FloorfGenericSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `floorf` (`builtin_sse42`) in all four C modes. -/
def FloorfBuiltinSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.floor cModes BuiltinSse42.kernel.eval

/-- **Open.** Prove `floorf` (`builtin_sse42`) is correctly rounded in all four C modes. -/
theorem floorfBuiltinSse42_correctlyRounded : FloorfBuiltinSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Floorf.floorfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms floorfGenericSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Floorf.floorfBuiltinSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms floorfBuiltinSse42_correctlyRounded

end LibcMath.Kernels.Floorf
