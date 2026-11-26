import LibcMath.Kernels.Atanf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `atanf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Atanf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Atanf.Generated

/-- Correct rounding of `atanf` (`double_eval_sse2`) in all four C modes. -/
def AtanfDoubleEvalSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.atan cModes DoubleEvalSse2.kernel.eval

/-- Correct rounding of `atanf` (`double_eval_sse42`) in all four C modes. -/
def AtanfDoubleEvalSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.atan cModes DoubleEvalSse42.kernel.eval

/-- Correct rounding of `atanf` (`double_eval_avx2_fma`) in all four C modes. -/
def AtanfDoubleEvalAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.atan cModes DoubleEvalAvx2Fma.kernel.eval

/-- Correct rounding of `atanf` (`double_eval_aarch64`) in all four C modes. -/
def AtanfDoubleEvalAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.atan cModes DoubleEvalAArch64.kernel.eval

/-- Definedness (no C++ undefined behavior) of `atanf` (`float_eval`). -/
def AtanfFloatEvalDefined : Prop :=
  ∀ x : Model .binary32, (FloatEval.kernel.eval .nearest x).isSome

end LibcMath.Kernels.Atanf
