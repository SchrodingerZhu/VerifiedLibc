import LibcMath.Kernels.Log1pf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `log1pf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Log1pf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Log1pf.Generated

/-- Correct rounding of `log1pf` (`double_eval_sse2`) in all four C modes. -/
def Log1pfDoubleEvalSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.log1p cModes DoubleEvalSse2.kernel.eval

/-- Correct rounding of `log1pf` (`double_eval_sse42`) in all four C modes. -/
def Log1pfDoubleEvalSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.log1p cModes DoubleEvalSse42.kernel.eval

/-- Correct rounding of `log1pf` (`double_eval_avx2_fma`) in all four C modes. -/
def Log1pfDoubleEvalAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.log1p cModes DoubleEvalAvx2Fma.kernel.eval

/-- Correct rounding of `log1pf` (`double_eval_aarch64`) in all four C modes. -/
def Log1pfDoubleEvalAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.log1p cModes DoubleEvalAArch64.kernel.eval

end LibcMath.Kernels.Log1pf
