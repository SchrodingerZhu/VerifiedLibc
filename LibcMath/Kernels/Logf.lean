import LibcMath.Framework.Spec
import LibcMath.Framework.Specs
import LibcMath.Kernels.Logf.Generated.DoubleEvalSse2
import LibcMath.Kernels.Logf.Generated.DoubleEvalAvx2Fma

/-!
# Extracted `logf` evaluation and microarch plans

Collects 2 extracted LLVM libc `logf` plans and states plan-qualified obligations.
Every statement names its evaluation and microarch plan explicitly.
-/

namespace LibcMath.Kernels.Logf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Logf.Generated

/-- Lists all 2 extracted `logf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ DoubleEvalSse2.kernel
  , DoubleEvalAvx2Fma.kernel ]

/-- Correct rounding of `logf` (`double_eval_sse2`) in all four C modes. -/
def LogfDoubleEvalSse2CorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.log .binary32) cModes DoubleEvalSse2.kernel.eval

/-- **Open.** Prove `logf` (`double_eval_sse2`) is correctly rounded in all four C modes. -/
theorem logfDoubleEvalSse2_correctlyRounded : LogfDoubleEvalSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `logf` (`double_eval_avx2_fma`) in all four C modes. -/
def LogfDoubleEvalAvx2FmaCorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.log .binary32) cModes DoubleEvalAvx2Fma.kernel.eval

/-- **Open.** Prove `logf` (`double_eval_avx2_fma`) is correctly rounded in all four C modes. -/
theorem logfDoubleEvalAvx2Fma_correctlyRounded : LogfDoubleEvalAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Logf.logfDoubleEvalSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms logfDoubleEvalSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Logf.logfDoubleEvalAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms logfDoubleEvalAvx2Fma_correctlyRounded

end LibcMath.Kernels.Logf
