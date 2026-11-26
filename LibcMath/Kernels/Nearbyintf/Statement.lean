import LibcMath.Kernels.Nearbyintf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `nearbyintf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Nearbyintf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Nearbyintf.Generated

/-- Correct rounding of `nearbyintf` (`generic_sse2`) in all four C modes. -/
def NearbyintfGenericSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.rint cModes GenericSse2.kernel.eval

/-- Correct rounding of `nearbyintf` (`builtin_sse42`) in all four C modes. -/
def NearbyintfBuiltinSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.rint cModes BuiltinSse42.kernel.eval

/-- Correct rounding of `nearbyintf` (`avx2_fma`) in all four C modes. -/
def NearbyintfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.rint cModes Avx2Fma.kernel.eval

/-- Correct rounding of `nearbyintf` (`aarch64`) in all four C modes. -/
def NearbyintfAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.rint cModes AArch64.kernel.eval

end LibcMath.Kernels.Nearbyintf
