import LibcMath.Kernels.Lgammaf.Plans
import LibcMath.Framework.Spec
import LibcMath.Framework.SpecialSpecs

/-!
# Correctness statements for extracted `lgammaf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Lgammaf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Lgammaf.Generated

/-- Correct rounding of `lgammaf` (`sse2`) in all four C modes. -/
def LgammafSse2CorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.lgamma .binary32) cModes Sse2.kernel.eval

/-- Correct rounding of `lgammaf` (`sse42`) in all four C modes. -/
def LgammafSse42CorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.lgamma .binary32) cModes Sse42.kernel.eval

/-- Correct rounding of `lgammaf` (`avx2_fma`) in all four C modes. -/
def LgammafAvx2FmaCorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.lgamma .binary32) cModes Avx2Fma.kernel.eval

/-- Correct rounding of `lgammaf` (`aarch64`) in all four C modes. -/
def LgammafAArch64CorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.lgamma .binary32) cModes AArch64.kernel.eval

end LibcMath.Kernels.Lgammaf
