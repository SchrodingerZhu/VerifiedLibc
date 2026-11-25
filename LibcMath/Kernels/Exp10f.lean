import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Exp10f.Generated.DoubleEvalSse2
import LibcMath.Kernels.Exp10f.Generated.DoubleEvalSse42
import LibcMath.Kernels.Exp10f.Generated.DoubleEvalAvx2Fma
import LibcMath.Kernels.Exp10f.Generated.FloatEval
import LibcMath.Kernels.Exp10f.Generated.IntegerEval
import LibcMath.Kernels.Exp10f.Generated.DoubleEvalAArch64

/-!
# Extracted `exp10f` evaluation and microarch plans

Collects six extracted LLVM libc `exp10f` plans and states plan-qualified correctness obligations.
Every statement names its evaluation and microarch plan explicitly.
-/

namespace LibcMath.Kernels.Exp10f

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Exp10f.Generated

/-- Lists all six extracted `exp10f` evaluation and microarch plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ DoubleEvalSse2.kernel
  , DoubleEvalSse42.kernel
  , DoubleEvalAvx2Fma.kernel
  , FloatEval.kernel
  , IntegerEval.kernel
  , DoubleEvalAArch64.kernel ]

/-- Correct rounding of `exp10f` (`double_eval_sse2`) across all four C rounding modes. -/
def Exp10fDoubleEvalSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.exp10 cModes DoubleEvalSse2.kernel.eval

/-- Correct rounding of `exp10f` (`double_eval_sse42`) across all four C rounding modes. -/
def Exp10fDoubleEvalSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.exp10 cModes DoubleEvalSse42.kernel.eval

/-- Correct rounding of `exp10f` (`double_eval_avx2_fma`) across all four C rounding modes. -/
def Exp10fDoubleEvalAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.exp10 cModes DoubleEvalAvx2Fma.kernel.eval

/-- Correct rounding of `exp10f` (`double_eval_aarch64`) across all four C rounding modes. -/
def Exp10fDoubleEvalAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.exp10 cModes DoubleEvalAArch64.kernel.eval

/-- Correct rounding of `exp10f` (`integer_eval`) in round-to-nearest-even mode. -/
def Exp10fIntegerEvalCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.exp10 {.nearest} IntegerEval.kernel.eval

/-- Definedness (no C++ undefined behavior) of fast `exp10f` (`float_eval`, RN-only). -/
def Exp10fFloatEvalDefined : Prop :=
  ∀ x : Model .binary32, (FloatEval.kernel.eval .nearest x).isSome

/-- **Open.** Prove `exp10f` (`double_eval_sse2`) is correctly rounded across all four C modes. -/
theorem exp10fDoubleEvalSse2_correctlyRounded : Exp10fDoubleEvalSse2CorrectlyRounded := by
  sorry

/-- **Open.** Prove `exp10f` (`double_eval_sse42`) is correctly rounded across all four modes. -/
theorem exp10fDoubleEvalSse42_correctlyRounded : Exp10fDoubleEvalSse42CorrectlyRounded := by
  sorry

/-- **Open.** Prove `exp10f` (`double_eval_avx2_fma`) is correctly rounded across all modes. -/
theorem exp10fDoubleEvalAvx2Fma_correctlyRounded : Exp10fDoubleEvalAvx2FmaCorrectlyRounded := by
  sorry

/-- **Open.** Prove `exp10f` (`double_eval_aarch64`) is correctly rounded across all modes. -/
theorem exp10fDoubleEvalAArch64_correctlyRounded : Exp10fDoubleEvalAArch64CorrectlyRounded := by
  sorry

/-- **Open.** Prove `exp10f` (`integer_eval`) is correctly rounded in round-to-nearest-even. -/
theorem exp10fIntegerEval_correctlyRounded : Exp10fIntegerEvalCorrectlyRounded := by
  sorry

/-- **Open.** Prove fast `exp10f` (`float_eval`) executes without C++ undefined behavior. -/
theorem exp10fFloatEval_defined : Exp10fFloatEvalDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Exp10f.exp10fDoubleEvalSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp10fDoubleEvalSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Exp10f.exp10fDoubleEvalSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp10fDoubleEvalSse42_correctlyRounded

/--
info: 'LibcMath.Kernels.Exp10f.exp10fDoubleEvalAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp10fDoubleEvalAvx2Fma_correctlyRounded

/--
info: 'LibcMath.Kernels.Exp10f.exp10fDoubleEvalAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp10fDoubleEvalAArch64_correctlyRounded

/--
info: 'LibcMath.Kernels.Exp10f.exp10fIntegerEval_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp10fIntegerEval_correctlyRounded

/--
info: 'LibcMath.Kernels.Exp10f.exp10fFloatEval_defined' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms exp10fFloatEval_defined

#guard (Diag.firstDiffBits DoubleEvalAArch64.kernel.eval DoubleEvalAvx2Fma.kernel.eval
    .nearest 0x3F800000 32).isNone

end LibcMath.Kernels.Exp10f
