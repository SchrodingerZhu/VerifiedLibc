import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Cosf.Generated.DoubleEvalSse2
import LibcMath.Kernels.Cosf.Generated.DoubleEvalSse42
import LibcMath.Kernels.Cosf.Generated.DoubleEvalAvx2Fma
import LibcMath.Kernels.Cosf.Generated.FloatEval

/-!
# Extracted `cosf` evaluation and microarch plans

Collects 4 extracted LLVM libc `cosf` plans and states plan-qualified obligations.
Every statement names its evaluation and microarch plan explicitly.
-/

namespace LibcMath.Kernels.Cosf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Cosf.Generated

/-- Lists all 4 extracted `cosf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ DoubleEvalSse2.kernel
  , DoubleEvalSse42.kernel
  , DoubleEvalAvx2Fma.kernel
  , FloatEval.kernel ]

/-- Correct rounding of `cosf` (`double_eval_sse2`) in all four C modes. -/
def CosfDoubleEvalSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.cos cModes DoubleEvalSse2.kernel.eval

/-- **Open.** Prove `cosf` (`double_eval_sse2`) is correctly rounded in all four C modes. -/
theorem cosfDoubleEvalSse2_correctlyRounded : CosfDoubleEvalSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `cosf` (`double_eval_sse42`) in all four C modes. -/
def CosfDoubleEvalSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.cos cModes DoubleEvalSse42.kernel.eval

/-- **Open.** Prove `cosf` (`double_eval_sse42`) is correctly rounded in all four C modes. -/
theorem cosfDoubleEvalSse42_correctlyRounded : CosfDoubleEvalSse42CorrectlyRounded := by
  sorry

/-- Correct rounding of `cosf` (`double_eval_avx2_fma`) in all four C modes. -/
def CosfDoubleEvalAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.cos cModes DoubleEvalAvx2Fma.kernel.eval

/-- **Open.** Prove `cosf` (`double_eval_avx2_fma`) is correctly rounded in all four C modes. -/
theorem cosfDoubleEvalAvx2Fma_correctlyRounded : CosfDoubleEvalAvx2FmaCorrectlyRounded := by
  sorry

/-- Definedness (no C++ undefined behavior) of `cosf` (`float_eval`). -/
def CosfFloatEvalDefined : Prop :=
  ∀ x : Model .binary32, (FloatEval.kernel.eval .nearest x).isSome

/-- **Open.** Prove `cosf` (`float_eval`) executes without C++ undefined behavior. -/
theorem cosfFloatEval_defined : CosfFloatEvalDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Cosf.cosfDoubleEvalSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms cosfDoubleEvalSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Cosf.cosfDoubleEvalSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms cosfDoubleEvalSse42_correctlyRounded

/--
info: 'LibcMath.Kernels.Cosf.cosfDoubleEvalAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms cosfDoubleEvalAvx2Fma_correctlyRounded

/--
info: 'LibcMath.Kernels.Cosf.cosfFloatEval_defined' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms cosfFloatEval_defined

end LibcMath.Kernels.Cosf
