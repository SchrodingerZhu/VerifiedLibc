import LibcMath.Kernels.Remainderf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `remainderf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Remainderf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Remainderf.Generated

/-- Correct rounding of `remainderf` (`generic_sse2`) in all four C modes. -/
def RemainderfGenericSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.remainder cModes GenericSse2.kernel.eval

/-- Correct rounding of `remainderf` (`sse42`) in all four C modes. -/
def RemainderfSse42CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.remainder cModes Sse42.kernel.eval

/-- Correct rounding of `remainderf` (`avx2_fma`) in all four C modes. -/
def RemainderfAvx2FmaCorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.remainder cModes Avx2Fma.kernel.eval

/-- Correct rounding of `remainderf` (`aarch64`) in all four C modes. -/
def RemainderfAArch64CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.remainder cModes AArch64.kernel.eval

end LibcMath.Kernels.Remainderf
