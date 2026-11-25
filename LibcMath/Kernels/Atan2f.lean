import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Atan2f.Generated.DoubleEvalSse2
import LibcMath.Kernels.Atan2f.Generated.DoubleEvalAvx2Fma
import LibcMath.Kernels.Atan2f.Generated.FloatEval

/-!
# Extracted `atan2f` evaluation and microarch plans

Collects 3 extracted LLVM libc `atan2f` plans and states plan-qualified obligations.
Every statement names its evaluation and microarch plan explicitly.
-/

namespace LibcMath.Kernels.Atan2f

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Atan2f.Generated

/-- Lists all 3 extracted `atan2f` plans. -/
def allPlans : List (BinaryKernel .binary32) :=
  [ DoubleEvalSse2.kernel
  , DoubleEvalAvx2Fma.kernel
  , FloatEval.kernel ]

/-- Correct rounding of `atan2f` (`double_eval_sse2`) in all four C modes. -/
def Atan2fDoubleEvalSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.atan2 cModes DoubleEvalSse2.kernel.eval

/-- **Open.** Prove `atan2f` (`double_eval_sse2`) is correctly rounded in all four C modes. -/
theorem atan2fDoubleEvalSse2_correctlyRounded : Atan2fDoubleEvalSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `atan2f` (`double_eval_avx2_fma`) in all four C modes. -/
def Atan2fDoubleEvalAvx2FmaCorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.atan2 cModes DoubleEvalAvx2Fma.kernel.eval

/-- **Open.** Prove `atan2f` (`double_eval_avx2_fma`) is correctly rounded in all four C modes. -/
theorem atan2fDoubleEvalAvx2Fma_correctlyRounded : Atan2fDoubleEvalAvx2FmaCorrectlyRounded := by
  sorry

/-- Definedness (no C++ undefined behavior) of `atan2f` (`float_eval`). -/
def Atan2fFloatEvalDefined : Prop :=
  ∀ x y : Model .binary32, (FloatEval.kernel.eval .nearest x y).isSome

/-- **Open.** Prove `atan2f` (`float_eval`) executes without C++ undefined behavior. -/
theorem atan2fFloatEval_defined : Atan2fFloatEvalDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Atan2f.atan2fDoubleEvalSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms atan2fDoubleEvalSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Atan2f.atan2fDoubleEvalAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms atan2fDoubleEvalAvx2Fma_correctlyRounded

/--
info: 'LibcMath.Kernels.Atan2f.atan2fFloatEval_defined' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms atan2fFloatEval_defined

end LibcMath.Kernels.Atan2f
