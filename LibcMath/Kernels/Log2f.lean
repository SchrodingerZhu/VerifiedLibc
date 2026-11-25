import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Log2f.Generated.DoubleEvalSse2
import LibcMath.Kernels.Log2f.Generated.DoubleEvalAvx2Fma

/-!
# Extracted `log2f` evaluation and microarch plans

Collects 2 extracted LLVM libc `log2f` plans and states plan-qualified obligations.
Every statement names its evaluation and microarch plan explicitly.
-/

namespace LibcMath.Kernels.Log2f

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Log2f.Generated

/-- Lists all 2 extracted `log2f` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ DoubleEvalSse2.kernel
  , DoubleEvalAvx2Fma.kernel ]

/-- Correct rounding of `log2f` (`double_eval_sse2`) in all four C modes. -/
def Log2fDoubleEvalSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.log2 cModes DoubleEvalSse2.kernel.eval

/-- **Open.** Prove `log2f` (`double_eval_sse2`) is correctly rounded in all four C modes. -/
theorem log2fDoubleEvalSse2_correctlyRounded : Log2fDoubleEvalSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `log2f` (`double_eval_avx2_fma`) in all four C modes. -/
def Log2fDoubleEvalAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.log2 cModes DoubleEvalAvx2Fma.kernel.eval

/-- **Open.** Prove `log2f` (`double_eval_avx2_fma`) is correctly rounded in all four C modes. -/
theorem log2fDoubleEvalAvx2Fma_correctlyRounded : Log2fDoubleEvalAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Log2f.log2fDoubleEvalSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms log2fDoubleEvalSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Log2f.log2fDoubleEvalAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms log2fDoubleEvalAvx2Fma_correctlyRounded

end LibcMath.Kernels.Log2f
