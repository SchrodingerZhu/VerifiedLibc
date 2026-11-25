import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Atanf.Generated.DoubleEvalSse2
import LibcMath.Kernels.Atanf.Generated.DoubleEvalAvx2Fma
import LibcMath.Kernels.Atanf.Generated.FloatEval

/-!
# Extracted `atanf` evaluation and microarch plans

Collects 3 extracted LLVM libc `atanf` plans and states plan-qualified obligations.
Every statement names its evaluation and microarch plan explicitly.
-/

namespace LibcMath.Kernels.Atanf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Atanf.Generated

/-- Lists all 3 extracted `atanf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ DoubleEvalSse2.kernel
  , DoubleEvalAvx2Fma.kernel
  , FloatEval.kernel ]

/-- Correct rounding of `atanf` (`double_eval_sse2`) in all four C modes. -/
def AtanfDoubleEvalSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.atan cModes DoubleEvalSse2.kernel.eval

/-- **Open.** Prove `atanf` (`double_eval_sse2`) is correctly rounded in all four C modes. -/
theorem atanfDoubleEvalSse2_correctlyRounded : AtanfDoubleEvalSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `atanf` (`double_eval_avx2_fma`) in all four C modes. -/
def AtanfDoubleEvalAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.atan cModes DoubleEvalAvx2Fma.kernel.eval

/-- **Open.** Prove `atanf` (`double_eval_avx2_fma`) is correctly rounded in all four C modes. -/
theorem atanfDoubleEvalAvx2Fma_correctlyRounded : AtanfDoubleEvalAvx2FmaCorrectlyRounded := by
  sorry

/-- Definedness (no C++ undefined behavior) of `atanf` (`float_eval`). -/
def AtanfFloatEvalDefined : Prop :=
  ∀ x : Model .binary32, (FloatEval.kernel.eval .nearest x).isSome

/-- **Open.** Prove `atanf` (`float_eval`) executes without C++ undefined behavior. -/
theorem atanfFloatEval_defined : AtanfFloatEvalDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Atanf.atanfDoubleEvalSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms atanfDoubleEvalSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Atanf.atanfDoubleEvalAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms atanfDoubleEvalAvx2Fma_correctlyRounded

/--
info: 'LibcMath.Kernels.Atanf.atanfFloatEval_defined' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms atanfFloatEval_defined

end LibcMath.Kernels.Atanf
