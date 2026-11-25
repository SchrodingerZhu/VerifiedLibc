import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Sqrtf.Generated.X86Sse2
import LibcMath.Kernels.Sqrtf.Generated.GenericSoftFloat

/-!
# Extracted `sqrtf` evaluation and microarch plans

Collects 2 extracted LLVM libc `sqrtf` plans and states plan-qualified obligations.
Every statement names its evaluation and microarch plan explicitly.
-/

namespace LibcMath.Kernels.Sqrtf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Sqrtf.Generated

/-- Lists all 2 extracted `sqrtf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ X86Sse2.kernel
  , GenericSoftFloat.kernel ]

/-- Correct rounding of `sqrtf` (`x86_sse2`) in all four C modes. -/
def SqrtfX86Sse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.sqrt cModes X86Sse2.kernel.eval

/-- **Open.** Prove `sqrtf` (`x86_sse2`) is correctly rounded in all four C modes. -/
theorem sqrtfX86Sse2_correctlyRounded : SqrtfX86Sse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `sqrtf` (`generic_softfloat`) in all four C modes. -/
def SqrtfGenericSoftFloatCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.sqrt cModes GenericSoftFloat.kernel.eval

/-- **Open.** Prove `sqrtf` (`generic_softfloat`) is correctly rounded in all four C modes. -/
theorem sqrtfGenericSoftFloat_correctlyRounded : SqrtfGenericSoftFloatCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Sqrtf.sqrtfX86Sse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sqrtfX86Sse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Sqrtf.sqrtfGenericSoftFloat_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sqrtfGenericSoftFloat_correctlyRounded

end LibcMath.Kernels.Sqrtf
