import LibcMath.Kernels.Exp10f.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `exp10f` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Exp10f

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Exp10f.Generated

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

/-- Definedness (no C++ undefined behavior) of fast `exp10f` (`float_eval`, RN-only). -/
def Exp10fFloatEvalDefined : Prop :=
  ∀ x : Model .binary32, (FloatEval.kernel.eval .nearest x).isSome

/-- Correct rounding of `exp10f` (`integer_eval`) in round-to-nearest-even mode. -/
def Exp10fIntegerEvalCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.exp10 {.nearest} IntegerEval.kernel.eval

/-- Correct rounding of `exp10f` (`static_rounding`, integer only) across all four C rounding
modes. -/
def Exp10fStaticRoundingCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.exp10 cModes StaticRounding.kernel.eval

end LibcMath.Kernels.Exp10f
