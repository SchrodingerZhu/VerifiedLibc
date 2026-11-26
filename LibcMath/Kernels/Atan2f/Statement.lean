import LibcMath.Kernels.Atan2f.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `atan2f` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Atan2f

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Atan2f.Generated

/-- Correct rounding of `atan2f` (`double_eval_sse2`) in all four C modes. -/
def Atan2fDoubleEvalSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.atan2 cModes DoubleEvalSse2.kernel.eval

/-- Correct rounding of `atan2f` (`double_eval_sse42`) in all four C modes. -/
def Atan2fDoubleEvalSse42CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.atan2 cModes DoubleEvalSse42.kernel.eval

/-- Correct rounding of `atan2f` (`double_eval_avx2_fma`) in all four C modes. -/
def Atan2fDoubleEvalAvx2FmaCorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.atan2 cModes DoubleEvalAvx2Fma.kernel.eval

/-- Correct rounding of `atan2f` (`double_eval_aarch64`) in all four C modes. -/
def Atan2fDoubleEvalAArch64CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.atan2 cModes DoubleEvalAArch64.kernel.eval

/-- Definedness (no C++ undefined behavior) of `atan2f` (`float_eval`). -/
def Atan2fFloatEvalDefined : Prop :=
  ∀ x y : Model .binary32, (FloatEval.kernel.eval .nearest x y).isSome

end LibcMath.Kernels.Atan2f
