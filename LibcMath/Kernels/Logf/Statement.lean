import LibcMath.Kernels.Logf.Plans
import LibcMath.Framework.Spec
import LibcMath.Framework.Specs

/-!
# Correctness statements for extracted `logf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Logf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Logf.Generated

/-- Correct rounding of `logf` (`double_eval_sse2`) in all four C modes. -/
def LogfDoubleEvalSse2CorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.log .binary32) cModes DoubleEvalSse2.kernel.eval

/-- Correct rounding of `logf` (`double_eval_sse42`) in all four C modes. -/
def LogfDoubleEvalSse42CorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.log .binary32) cModes DoubleEvalSse42.kernel.eval

/-- Correct rounding of `logf` (`double_eval_avx2_fma`) in all four C modes. -/
def LogfDoubleEvalAvx2FmaCorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.log .binary32) cModes DoubleEvalAvx2Fma.kernel.eval

/-- Correct rounding of `logf` (`double_eval_aarch64`) in all four C modes. -/
def LogfDoubleEvalAArch64CorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.log .binary32) cModes DoubleEvalAArch64.kernel.eval

end LibcMath.Kernels.Logf
