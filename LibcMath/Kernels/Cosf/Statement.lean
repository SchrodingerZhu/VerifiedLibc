import LibcMath.Kernels.Cosf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `cosf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Cosf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Cosf.Generated

/-- Correct rounding of `cosf` (`double_eval_sse2`) in all four C modes. -/
def CosfDoubleEvalSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.cos cModes DoubleEvalSse2.kernel.eval

/-- Correct rounding of `cosf` (`double_eval_sse42`) in all four C modes. -/
def CosfDoubleEvalSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.cos cModes DoubleEvalSse42.kernel.eval

/-- Correct rounding of `cosf` (`double_eval_avx2_fma`) in all four C modes. -/
def CosfDoubleEvalAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.cos cModes DoubleEvalAvx2Fma.kernel.eval

/-- Correct rounding of `cosf` (`double_eval_aarch64`) in all four C modes. -/
def CosfDoubleEvalAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.cos cModes DoubleEvalAArch64.kernel.eval

/-- Definedness (no C++ undefined behavior) of `cosf` (`float_eval`). -/
def CosfFloatEvalDefined : Prop :=
  ∀ x : Model .binary32, (FloatEval.kernel.eval .nearest x).isSome

end LibcMath.Kernels.Cosf
