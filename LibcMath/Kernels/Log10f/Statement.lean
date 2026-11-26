import LibcMath.Kernels.Log10f.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `log10f` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Log10f

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Log10f.Generated

/-- Correct rounding of `log10f` (`double_eval_sse2`) in all four C modes. -/
def Log10fDoubleEvalSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.log10 cModes DoubleEvalSse2.kernel.eval

/-- Correct rounding of `log10f` (`double_eval_sse42`) in all four C modes. -/
def Log10fDoubleEvalSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.log10 cModes DoubleEvalSse42.kernel.eval

/-- Correct rounding of `log10f` (`double_eval_avx2_fma`) in all four C modes. -/
def Log10fDoubleEvalAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.log10 cModes DoubleEvalAvx2Fma.kernel.eval

/-- Correct rounding of `log10f` (`double_eval_aarch64`) in all four C modes. -/
def Log10fDoubleEvalAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.log10 cModes DoubleEvalAArch64.kernel.eval

end LibcMath.Kernels.Log10f
