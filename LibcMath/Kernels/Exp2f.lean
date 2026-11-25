import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Exp2f.Generated.DoubleEvalSse2
import LibcMath.Kernels.Exp2f.Generated.DoubleEvalSse42
import LibcMath.Kernels.Exp2f.Generated.DoubleEvalAvx2Fma
import LibcMath.Kernels.Exp2f.Generated.FloatEval
import LibcMath.Kernels.Exp2f.Generated.IntegerEval
import LibcMath.Kernels.Exp2f.Generated.DoubleEvalAArch64

/-!
# Extracted `exp2f` evaluation and microarch plans

Collects six extracted LLVM libc `exp2f` plans and states plan-qualified correctness obligations.
Every statement names its evaluation and microarch plan explicitly.
-/

namespace LibcMath.Kernels.Exp2f

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Exp2f.Generated

/-- Lists all six extracted `exp2f` evaluation and microarch plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ DoubleEvalSse2.kernel
  , DoubleEvalSse42.kernel
  , DoubleEvalAvx2Fma.kernel
  , FloatEval.kernel
  , IntegerEval.kernel
  , DoubleEvalAArch64.kernel ]

/-- Correct rounding of `exp2f` (`double_eval_sse2`) across all four C rounding modes. -/
def Exp2fDoubleEvalSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.exp2 cModes DoubleEvalSse2.kernel.eval

/-- Correct rounding of `exp2f` (`double_eval_sse42`) across all four C rounding modes. -/
def Exp2fDoubleEvalSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.exp2 cModes DoubleEvalSse42.kernel.eval

/-- Correct rounding of `exp2f` (`double_eval_avx2_fma`) across all four C rounding modes. -/
def Exp2fDoubleEvalAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.exp2 cModes DoubleEvalAvx2Fma.kernel.eval

/-- Correct rounding of `exp2f` (`double_eval_aarch64`) across all four C rounding modes. -/
def Exp2fDoubleEvalAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.exp2 cModes DoubleEvalAArch64.kernel.eval

/-- Correct rounding of `exp2f` (`integer_eval`) in round-to-nearest-even mode. -/
def Exp2fIntegerEvalCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.exp2 {.nearest} IntegerEval.kernel.eval

/-- Definedness (no C++ undefined behavior) of fast `exp2f` (`float_eval`, RN-only). -/
def Exp2fFloatEvalDefined : Prop :=
  ∀ x : Model .binary32, (FloatEval.kernel.eval .nearest x).isSome

/-- **Open.** Prove `exp2f` (`double_eval_sse2`) is correctly rounded across all four C modes. -/
theorem exp2fDoubleEvalSse2_correctlyRounded : Exp2fDoubleEvalSse2CorrectlyRounded := by
  sorry

/-- **Open.** Prove `exp2f` (`double_eval_sse42`) is correctly rounded across all four C modes. -/
theorem exp2fDoubleEvalSse42_correctlyRounded : Exp2fDoubleEvalSse42CorrectlyRounded := by
  sorry

/-- **Open.** Prove `exp2f` (`double_eval_avx2_fma`) is correctly rounded across all four modes. -/
theorem exp2fDoubleEvalAvx2Fma_correctlyRounded : Exp2fDoubleEvalAvx2FmaCorrectlyRounded := by
  sorry

/-- **Open.** Prove `exp2f` (`double_eval_aarch64`) is correctly rounded across all four modes. -/
theorem exp2fDoubleEvalAArch64_correctlyRounded : Exp2fDoubleEvalAArch64CorrectlyRounded := by
  sorry

/-- **Open.** Prove `exp2f` (`integer_eval`) is correctly rounded in round-to-nearest-even. -/
theorem exp2fIntegerEval_correctlyRounded : Exp2fIntegerEvalCorrectlyRounded := by
  sorry

/-- **Open.** Prove fast `exp2f` (`float_eval`) executes without C++ undefined behavior. -/
theorem exp2fFloatEval_defined : Exp2fFloatEvalDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Exp2f.exp2fDoubleEvalSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp2fDoubleEvalSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Exp2f.exp2fDoubleEvalSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp2fDoubleEvalSse42_correctlyRounded

/--
info: 'LibcMath.Kernels.Exp2f.exp2fDoubleEvalAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp2fDoubleEvalAvx2Fma_correctlyRounded

/--
info: 'LibcMath.Kernels.Exp2f.exp2fDoubleEvalAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp2fDoubleEvalAArch64_correctlyRounded

/--
info: 'LibcMath.Kernels.Exp2f.exp2fIntegerEval_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp2fIntegerEval_correctlyRounded

/--
info: 'LibcMath.Kernels.Exp2f.exp2fFloatEval_defined' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms exp2fFloatEval_defined

#guard (Diag.firstDiffBits DoubleEvalAArch64.kernel.eval DoubleEvalAvx2Fma.kernel.eval
    .nearest 0x3F800000 32).isNone

end LibcMath.Kernels.Exp2f
