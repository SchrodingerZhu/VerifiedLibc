import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Log1pf.Generated.DoubleEvalSse2
import LibcMath.Kernels.Log1pf.Generated.DoubleEvalAvx2Fma

/-!
# Extracted `log1pf` evaluation and microarch plans

Collects 2 extracted LLVM libc `log1pf` plans and states plan-qualified obligations.
Every statement names its evaluation and microarch plan explicitly.
-/

namespace LibcMath.Kernels.Log1pf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Log1pf.Generated

/-- Lists all 2 extracted `log1pf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ DoubleEvalSse2.kernel
  , DoubleEvalAvx2Fma.kernel ]

/-- Correct rounding of `log1pf` (`double_eval_sse2`) in all four C modes. -/
def Log1pfDoubleEvalSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.log1p cModes DoubleEvalSse2.kernel.eval

/-- **Open.** Prove `log1pf` (`double_eval_sse2`) is correctly rounded in all four C modes. -/
theorem log1pfDoubleEvalSse2_correctlyRounded : Log1pfDoubleEvalSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `log1pf` (`double_eval_avx2_fma`) in all four C modes. -/
def Log1pfDoubleEvalAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.log1p cModes DoubleEvalAvx2Fma.kernel.eval

/-- **Open.** Prove `log1pf` (`double_eval_avx2_fma`) is correctly rounded in all four C modes. -/
theorem log1pfDoubleEvalAvx2Fma_correctlyRounded : Log1pfDoubleEvalAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Log1pf.log1pfDoubleEvalSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms log1pfDoubleEvalSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Log1pf.log1pfDoubleEvalAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms log1pfDoubleEvalAvx2Fma_correctlyRounded

end LibcMath.Kernels.Log1pf
