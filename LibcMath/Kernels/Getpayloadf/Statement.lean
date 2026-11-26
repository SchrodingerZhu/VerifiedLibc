import LibcMath.Kernels.Getpayloadf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `getpayloadf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Getpayloadf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Getpayloadf.Generated

/-- Correct rounding of `getpayloadf` (`generic_sse2`) in all four C modes. -/
def GetpayloadfGenericSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.getpayload cModes GenericSse2.kernel.eval

/-- Correct rounding of `getpayloadf` (`sse42`) in all four C modes. -/
def GetpayloadfSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.getpayload cModes Sse42.kernel.eval

/-- Correct rounding of `getpayloadf` (`avx2_fma`) in all four C modes. -/
def GetpayloadfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.getpayload cModes Avx2Fma.kernel.eval

/-- Correct rounding of `getpayloadf` (`aarch64`) in all four C modes. -/
def GetpayloadfAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.getpayload cModes AArch64.kernel.eval

end LibcMath.Kernels.Getpayloadf
