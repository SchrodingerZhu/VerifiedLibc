import LibcMath.Kernels.Log2f.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `log2f` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Log2f

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Log2f.Generated

/-- Correct rounding of `log2f` (`double_eval_sse2`) in all four C modes. -/
def Log2fDoubleEvalSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.log2 cModes DoubleEvalSse2.kernel.eval

/-- Correct rounding of `log2f` (`double_eval_sse42`) in all four C modes. -/
def Log2fDoubleEvalSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.log2 cModes DoubleEvalSse42.kernel.eval

/-- Correct rounding of `log2f` (`double_eval_avx2_fma`) in all four C modes. -/
def Log2fDoubleEvalAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.log2 cModes DoubleEvalAvx2Fma.kernel.eval

/-- Correct rounding of `log2f` (`double_eval_aarch64`) in all four C modes. -/
def Log2fDoubleEvalAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.log2 cModes DoubleEvalAArch64.kernel.eval

end LibcMath.Kernels.Log2f
