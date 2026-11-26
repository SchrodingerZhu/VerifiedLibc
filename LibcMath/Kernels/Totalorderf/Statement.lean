import LibcMath.Kernels.Totalorderf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `totalorderf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Totalorderf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Totalorderf.Generated

/-- Exact IEEE 754 agreement of `totalorderf` (`generic_sse2`) in all four C modes. -/
def TotalorderfGenericSse2Correct : Prop :=
  FnCorrectlyRounded Eq (fun m (p : Model .binary32 × Model .binary32) =>
    if FloatLibSpec.totalorder m p.1 p.2 then 1#32 else 0#32) cModes
    (fun _ p => GenericSse2.totalorderf p.1 p.2)

/-- Exact IEEE 754 agreement of `totalorderf` (`sse42`) in all four C modes. -/
def TotalorderfSse42Correct : Prop :=
  FnCorrectlyRounded Eq (fun m (p : Model .binary32 × Model .binary32) =>
    if FloatLibSpec.totalorder m p.1 p.2 then 1#32 else 0#32) cModes
    (fun _ p => Sse42.totalorderf p.1 p.2)

/-- Exact IEEE 754 agreement of `totalorderf` (`avx2_fma`) in all four C modes. -/
def TotalorderfAvx2FmaCorrect : Prop :=
  FnCorrectlyRounded Eq (fun m (p : Model .binary32 × Model .binary32) =>
    if FloatLibSpec.totalorder m p.1 p.2 then 1#32 else 0#32) cModes
    (fun _ p => Avx2Fma.totalorderf p.1 p.2)

/-- Exact IEEE 754 agreement of `totalorderf` (`aarch64`) in all four C modes. -/
def TotalorderfAArch64Correct : Prop :=
  FnCorrectlyRounded Eq (fun m (p : Model .binary32 × Model .binary32) =>
    if FloatLibSpec.totalorder m p.1 p.2 then 1#32 else 0#32) cModes
    (fun _ p => AArch64.totalorderf p.1 p.2)

end LibcMath.Kernels.Totalorderf
