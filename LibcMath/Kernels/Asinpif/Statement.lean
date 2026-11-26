import LibcMath.Kernels.Asinpif.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `asinpif` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Asinpif

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Asinpif.Generated

/-- Correct rounding of `asinpif` (`sse2`) in all four C modes. -/
def AsinpifSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.asinpi cModes Sse2.kernel.eval

/-- Correct rounding of `asinpif` (`sse42`) in all four C modes. -/
def AsinpifSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.asinpi cModes Sse42.kernel.eval

/-- Correct rounding of `asinpif` (`avx2_fma`) in all four C modes. -/
def AsinpifAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.asinpi cModes Avx2Fma.kernel.eval

/-- Correct rounding of `asinpif` (`aarch64`) in all four C modes. -/
def AsinpifAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.asinpi cModes AArch64.kernel.eval

end LibcMath.Kernels.Asinpif
