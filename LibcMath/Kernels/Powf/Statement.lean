import LibcMath.Kernels.Powf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `powf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Powf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Powf.Generated

/-- Correct rounding of `powf` (`double_eval_sse2`) in all four C modes. -/
def PowfDoubleEvalSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.pow cModes DoubleEvalSse2.kernel.eval

/-- Correct rounding of `powf` (`double_eval_sse42`) in all four C modes. -/
def PowfDoubleEvalSse42CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.pow cModes DoubleEvalSse42.kernel.eval

/-- Correct rounding of `powf` (`double_eval_avx2_fma`) in all four C modes. -/
def PowfDoubleEvalAvx2FmaCorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.pow cModes DoubleEvalAvx2Fma.kernel.eval

/-- Correct rounding of `powf` (`double_eval_aarch64`) in all four C modes. -/
def PowfDoubleEvalAArch64CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.pow cModes DoubleEvalAArch64.kernel.eval

/-- Definedness (no C++ undefined behavior) of `powf` (`float_eval`). -/
def PowfFloatEvalDefined : Prop :=
  ∀ x y : Model .binary32, (FloatEval.kernel.eval .nearest x y).isSome

end LibcMath.Kernels.Powf
