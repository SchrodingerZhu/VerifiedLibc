import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Tanf.Generated.DoubleEvalSse2
import LibcMath.Kernels.Tanf.Generated.DoubleEvalSse42
import LibcMath.Kernels.Tanf.Generated.DoubleEvalAvx2Fma
import LibcMath.Kernels.Tanf.Generated.FloatEval

/-!
# Extracted `tanf` evaluation and microarch plans

Collects 4 extracted LLVM libc `tanf` plans and states plan-qualified obligations.
Every statement names its evaluation and microarch plan explicitly.
-/

namespace LibcMath.Kernels.Tanf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Tanf.Generated

/-- Lists all 4 extracted `tanf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ DoubleEvalSse2.kernel
  , DoubleEvalSse42.kernel
  , DoubleEvalAvx2Fma.kernel
  , FloatEval.kernel ]

/-- Correct rounding of `tanf` (`double_eval_sse2`) in all four C modes. -/
def TanfDoubleEvalSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.tan cModes DoubleEvalSse2.kernel.eval

/-- **Open.** Prove `tanf` (`double_eval_sse2`) is correctly rounded in all four C modes. -/
theorem tanfDoubleEvalSse2_correctlyRounded : TanfDoubleEvalSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `tanf` (`double_eval_sse42`) in all four C modes. -/
def TanfDoubleEvalSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.tan cModes DoubleEvalSse42.kernel.eval

/-- **Open.** Prove `tanf` (`double_eval_sse42`) is correctly rounded in all four C modes. -/
theorem tanfDoubleEvalSse42_correctlyRounded : TanfDoubleEvalSse42CorrectlyRounded := by
  sorry

/-- Correct rounding of `tanf` (`double_eval_avx2_fma`) in all four C modes. -/
def TanfDoubleEvalAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.tan cModes DoubleEvalAvx2Fma.kernel.eval

/-- **Open.** Prove `tanf` (`double_eval_avx2_fma`) is correctly rounded in all four C modes. -/
theorem tanfDoubleEvalAvx2Fma_correctlyRounded : TanfDoubleEvalAvx2FmaCorrectlyRounded := by
  sorry

/-- Definedness (no C++ undefined behavior) of `tanf` (`float_eval`). -/
def TanfFloatEvalDefined : Prop :=
  ∀ x : Model .binary32, (FloatEval.kernel.eval .nearest x).isSome

/-- **Open.** Prove `tanf` (`float_eval`) executes without C++ undefined behavior. -/
theorem tanfFloatEval_defined : TanfFloatEvalDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Tanf.tanfDoubleEvalSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms tanfDoubleEvalSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Tanf.tanfDoubleEvalSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms tanfDoubleEvalSse42_correctlyRounded

/--
info: 'LibcMath.Kernels.Tanf.tanfDoubleEvalAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms tanfDoubleEvalAvx2Fma_correctlyRounded

/--
info: 'LibcMath.Kernels.Tanf.tanfFloatEval_defined' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms tanfFloatEval_defined

end LibcMath.Kernels.Tanf
