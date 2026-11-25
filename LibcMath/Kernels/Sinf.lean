import LibcMath.Framework.Spec
import LibcMath.Framework.Specs
import LibcMath.Kernels.Sinf.Generated.DoubleEvalSse2
import LibcMath.Kernels.Sinf.Generated.DoubleEvalSse42
import LibcMath.Kernels.Sinf.Generated.DoubleEvalAvx2Fma
import LibcMath.Kernels.Sinf.Generated.FloatEval

/-!
# Extracted `sinf` evaluation and microarch plans

Collects 4 extracted LLVM libc `sinf` plans and states plan-qualified obligations.
Every statement names its evaluation and microarch plan explicitly.
-/

namespace LibcMath.Kernels.Sinf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Sinf.Generated

/-- Lists all 4 extracted `sinf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ DoubleEvalSse2.kernel
  , DoubleEvalSse42.kernel
  , DoubleEvalAvx2Fma.kernel
  , FloatEval.kernel ]

/-- Correct rounding of `sinf` (`double_eval_sse2`) in all four C modes. -/
def SinfDoubleEvalSse2CorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.sin .binary32) cModes DoubleEvalSse2.kernel.eval

/-- **Open.** Prove `sinf` (`double_eval_sse2`) is correctly rounded in all four C modes. -/
theorem sinfDoubleEvalSse2_correctlyRounded : SinfDoubleEvalSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `sinf` (`double_eval_sse42`) in all four C modes. -/
def SinfDoubleEvalSse42CorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.sin .binary32) cModes DoubleEvalSse42.kernel.eval

/-- **Open.** Prove `sinf` (`double_eval_sse42`) is correctly rounded in all four C modes. -/
theorem sinfDoubleEvalSse42_correctlyRounded : SinfDoubleEvalSse42CorrectlyRounded := by
  sorry

/-- Correct rounding of `sinf` (`double_eval_avx2_fma`) in all four C modes. -/
def SinfDoubleEvalAvx2FmaCorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.sin .binary32) cModes DoubleEvalAvx2Fma.kernel.eval

/-- **Open.** Prove `sinf` (`double_eval_avx2_fma`) is correctly rounded in all four C modes. -/
theorem sinfDoubleEvalAvx2Fma_correctlyRounded : SinfDoubleEvalAvx2FmaCorrectlyRounded := by
  sorry

/-- Definedness (no C++ undefined behavior) of `sinf` (`float_eval`). -/
def SinfFloatEvalDefined : Prop :=
  ∀ x : Model .binary32, (FloatEval.kernel.eval .nearest x).isSome

/-- **Open.** Prove `sinf` (`float_eval`) executes without C++ undefined behavior. -/
theorem sinfFloatEval_defined : SinfFloatEvalDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Sinf.sinfDoubleEvalSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sinfDoubleEvalSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Sinf.sinfDoubleEvalSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sinfDoubleEvalSse42_correctlyRounded

/--
info: 'LibcMath.Kernels.Sinf.sinfDoubleEvalAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sinfDoubleEvalAvx2Fma_correctlyRounded

/--
info: 'LibcMath.Kernels.Sinf.sinfFloatEval_defined' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms sinfFloatEval_defined

end LibcMath.Kernels.Sinf
