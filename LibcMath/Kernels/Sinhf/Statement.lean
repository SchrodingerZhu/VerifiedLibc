import LibcMath.Kernels.Sinhf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `sinhf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Sinhf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Sinhf.Generated

/-- Correct rounding of `sinhf` (`sse2`) in all four C modes. -/
def SinhfSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.sinh cModes Sse2.kernel.eval

/-- Correct rounding of `sinhf` (`sse42`) in all four C modes. -/
def SinhfSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.sinh cModes Sse42.kernel.eval

/-- Correct rounding of `sinhf` (`avx2_fma`) in all four C modes. -/
def SinhfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.sinh cModes Avx2Fma.kernel.eval

/-- Correct rounding of `sinhf` (`aarch64`) in all four C modes. -/
def SinhfAArch64CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.sinh cModes AArch64.kernel.eval

end LibcMath.Kernels.Sinhf
