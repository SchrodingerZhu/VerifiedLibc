import LibcMath.Kernels.Erff.Plans
import LibcMath.Framework.Spec
import LibcMath.Framework.SpecialSpecs

/-!
# Correctness statements for extracted `erff` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Erff

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Erff.Generated

/-- Correct rounding of `erff` (`sse2`) in all four C modes. -/
def ErffSse2CorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.erf .binary32) cModes Sse2.kernel.eval

/-- Correct rounding of `erff` (`sse42`) in all four C modes. -/
def ErffSse42CorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.erf .binary32) cModes Sse42.kernel.eval

/-- Correct rounding of `erff` (`avx2_fma`) in all four C modes. -/
def ErffAvx2FmaCorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.erf .binary32) cModes Avx2Fma.kernel.eval

/-- Correct rounding of `erff` (`aarch64`) in all four C modes. -/
def ErffAArch64CorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.erf .binary32) cModes AArch64.kernel.eval

end LibcMath.Kernels.Erff
