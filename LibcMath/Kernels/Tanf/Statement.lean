import LibcMath.Kernels.Tanf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `tanf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Tanf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Tanf.Generated

/-- Correct rounding of `tanf` (`double_eval_sse2`) in all four C modes. -/
def TanfDoubleEvalSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.tan cModes DoubleEvalSse2.kernel.eval

/-- Correct rounding of `tanf` (`double_eval_sse42`) in all four C modes. -/
def TanfDoubleEvalSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.tan cModes DoubleEvalSse42.kernel.eval

/-- Correct rounding of `tanf` (`double_eval_avx2_fma`) in all four C modes. -/
def TanfDoubleEvalAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.tan cModes DoubleEvalAvx2Fma.kernel.eval

/-- Correct rounding of `tanf` (`double_eval_aarch64`) in all four C modes. -/
def TanfDoubleEvalAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.tan cModes DoubleEvalAArch64.kernel.eval

/-- Definedness (no C++ undefined behavior) of `tanf` (`float_eval`). -/
def TanfFloatEvalDefined : Prop :=
  ∀ x : Model .binary32, (FloatEval.kernel.eval .nearest x).isSome

end LibcMath.Kernels.Tanf
