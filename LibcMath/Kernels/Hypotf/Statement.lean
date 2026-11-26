import LibcMath.Kernels.Hypotf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `hypotf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Hypotf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Hypotf.Generated

/-- Correct rounding of `hypotf` (`generic_sse2`) in all four C modes. -/
def HypotfGenericSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.hypot cModes GenericSse2.kernel.eval

/-- Correct rounding of `hypotf` (`sse42`) in all four C modes. -/
def HypotfSse42CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.hypot cModes Sse42.kernel.eval

/-- Correct rounding of `hypotf` (`avx2_fma`) in all four C modes. -/
def HypotfAvx2FmaCorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.hypot cModes Avx2Fma.kernel.eval

/-- Correct rounding of `hypotf` (`aarch64`) in all four C modes. -/
def HypotfAArch64CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.hypot cModes AArch64.kernel.eval

end LibcMath.Kernels.Hypotf
