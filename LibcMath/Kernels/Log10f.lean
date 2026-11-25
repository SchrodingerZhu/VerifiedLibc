import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Log10f.Generated.DoubleEvalSse2
import LibcMath.Kernels.Log10f.Generated.DoubleEvalAvx2Fma

/-!
# Extracted `log10f` evaluation and microarch plans

Collects 2 extracted LLVM libc `log10f` plans and states plan-qualified obligations.
Every statement names its evaluation and microarch plan explicitly.
-/

namespace LibcMath.Kernels.Log10f

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Log10f.Generated

/-- Lists all 2 extracted `log10f` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ DoubleEvalSse2.kernel
  , DoubleEvalAvx2Fma.kernel ]

/-- Correct rounding of `log10f` (`double_eval_sse2`) in all four C modes. -/
def Log10fDoubleEvalSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.log10 cModes DoubleEvalSse2.kernel.eval

/-- **Open.** Prove `log10f` (`double_eval_sse2`) is correctly rounded in all four C modes. -/
theorem log10fDoubleEvalSse2_correctlyRounded : Log10fDoubleEvalSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `log10f` (`double_eval_avx2_fma`) in all four C modes. -/
def Log10fDoubleEvalAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.log10 cModes DoubleEvalAvx2Fma.kernel.eval

/-- **Open.** Prove `log10f` (`double_eval_avx2_fma`) is correctly rounded in all four C modes. -/
theorem log10fDoubleEvalAvx2Fma_correctlyRounded : Log10fDoubleEvalAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Log10f.log10fDoubleEvalSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms log10fDoubleEvalSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Log10f.log10fDoubleEvalAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms log10fDoubleEvalAvx2Fma_correctlyRounded

end LibcMath.Kernels.Log10f
