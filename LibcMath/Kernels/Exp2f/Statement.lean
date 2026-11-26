import LibcMath.Kernels.Exp2f.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `exp2f` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Exp2f

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Exp2f.Generated

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

/-- Definedness (no C++ undefined behavior) of fast `exp2f` (`float_eval`, RN-only). -/
def Exp2fFloatEvalDefined : Prop :=
  ∀ x : Model .binary32, (FloatEval.kernel.eval .nearest x).isSome

/-- Correct rounding of `exp2f` (`integer_eval`) in round-to-nearest-even mode. -/
def Exp2fIntegerEvalCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.exp2 {.nearest} IntegerEval.kernel.eval

/-- Correct rounding of `exp2f` (`static_rounding`, integer only) across all four C rounding
modes. -/
def Exp2fStaticRoundingCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.exp2 cModes StaticRounding.kernel.eval

end LibcMath.Kernels.Exp2f
