import LibcMath.Kernels.Sinf.Plans
import LibcMath.Framework.Spec
import LibcMath.Framework.Specs

/-!
# Correctness statements for extracted `sinf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Sinf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Sinf.Generated

/-- Correct rounding of `sinf` (`double_eval_sse2`) in all four C modes. -/
def SinfDoubleEvalSse2CorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.sin .binary32) cModes DoubleEvalSse2.kernel.eval

/-- Correct rounding of `sinf` (`double_eval_sse42`) in all four C modes. -/
def SinfDoubleEvalSse42CorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.sin .binary32) cModes DoubleEvalSse42.kernel.eval

/-- Correct rounding of `sinf` (`double_eval_avx2_fma`) in all four C modes. -/
def SinfDoubleEvalAvx2FmaCorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.sin .binary32) cModes DoubleEvalAvx2Fma.kernel.eval

/-- Correct rounding of `sinf` (`double_eval_aarch64`) in all four C modes. -/
def SinfDoubleEvalAArch64CorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.sin .binary32) cModes DoubleEvalAArch64.kernel.eval

/-- Definedness (no C++ undefined behavior) of `sinf` (`float_eval`). -/
def SinfFloatEvalDefined : Prop :=
  ∀ x : Model .binary32, (FloatEval.kernel.eval .nearest x).isSome

end LibcMath.Kernels.Sinf
