import LibcMath.Kernels.Tanhf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `tanhf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Tanhf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Tanhf.Generated

/-- Correct rounding of `tanhf` (`sse2`) in all four C modes. -/
def TanhfSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.tanh cModes Sse2.kernel.eval

/-- Correct rounding of `tanhf` (`sse42`) in all four C modes. -/
def TanhfSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.tanh cModes Sse42.kernel.eval

/-- Correct rounding of `tanhf` (`avx2_fma`) in all four C modes. -/
def TanhfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.tanh cModes Avx2Fma.kernel.eval

/-- Correct rounding of `tanhf` (`aarch64`) in all four C modes. -/
def TanhfAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.tanh cModes AArch64.kernel.eval

end LibcMath.Kernels.Tanhf
