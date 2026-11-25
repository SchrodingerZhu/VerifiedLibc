import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Powf.Generated.DoubleEvalSse2
import LibcMath.Kernels.Powf.Generated.DoubleEvalSse42
import LibcMath.Kernels.Powf.Generated.DoubleEvalAvx2Fma
import LibcMath.Kernels.Powf.Generated.FloatEval

/-!
# Extracted `powf` evaluation and microarch plans

Collects 4 extracted LLVM libc `powf` plans and states plan-qualified obligations.
Every statement names its evaluation and microarch plan explicitly.
-/

namespace LibcMath.Kernels.Powf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Powf.Generated

/-- Lists all 4 extracted `powf` plans. -/
def allPlans : List (BinaryKernel .binary32) :=
  [ DoubleEvalSse2.kernel
  , DoubleEvalSse42.kernel
  , DoubleEvalAvx2Fma.kernel
  , FloatEval.kernel ]

/-- Correct rounding of `powf` (`double_eval_sse2`) in all four C modes. -/
def PowfDoubleEvalSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.pow cModes DoubleEvalSse2.kernel.eval

/-- **Open.** Prove `powf` (`double_eval_sse2`) is correctly rounded in all four C modes. -/
theorem powfDoubleEvalSse2_correctlyRounded : PowfDoubleEvalSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `powf` (`double_eval_sse42`) in all four C modes. -/
def PowfDoubleEvalSse42CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.pow cModes DoubleEvalSse42.kernel.eval

/-- **Open.** Prove `powf` (`double_eval_sse42`) is correctly rounded in all four C modes. -/
theorem powfDoubleEvalSse42_correctlyRounded : PowfDoubleEvalSse42CorrectlyRounded := by
  sorry

/-- Correct rounding of `powf` (`double_eval_avx2_fma`) in all four C modes. -/
def PowfDoubleEvalAvx2FmaCorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.pow cModes DoubleEvalAvx2Fma.kernel.eval

/-- **Open.** Prove `powf` (`double_eval_avx2_fma`) is correctly rounded in all four C modes. -/
theorem powfDoubleEvalAvx2Fma_correctlyRounded : PowfDoubleEvalAvx2FmaCorrectlyRounded := by
  sorry

/-- Definedness (no C++ undefined behavior) of `powf` (`float_eval`). -/
def PowfFloatEvalDefined : Prop :=
  ∀ x y : Model .binary32, (FloatEval.kernel.eval .nearest x y).isSome

/-- **Open.** Prove `powf` (`float_eval`) executes without C++ undefined behavior. -/
theorem powfFloatEval_defined : PowfFloatEvalDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Powf.powfDoubleEvalSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms powfDoubleEvalSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Powf.powfDoubleEvalSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms powfDoubleEvalSse42_correctlyRounded

/--
info: 'LibcMath.Kernels.Powf.powfDoubleEvalAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms powfDoubleEvalAvx2Fma_correctlyRounded

/--
info: 'LibcMath.Kernels.Powf.powfFloatEval_defined' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms powfFloatEval_defined

end LibcMath.Kernels.Powf
