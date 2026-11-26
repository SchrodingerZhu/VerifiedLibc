import LibcMath.Kernels.Totalordermagf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `totalordermagf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Totalordermagf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Totalordermagf.Generated

/-- Exact IEEE 754 agreement of `totalordermagf` (`generic_sse2`) in all four C modes. -/
def TotalordermagfGenericSse2Correct : Prop :=
  FnCorrectlyRounded Eq (fun m (p : Model .binary32 × Model .binary32) =>
    if FloatLibSpec.totalordermag m p.1 p.2 then 1#32 else 0#32) cModes
    (fun _ p => GenericSse2.totalordermagf p.1 p.2)

/-- Exact IEEE 754 agreement of `totalordermagf` (`sse42`) in all four C modes. -/
def TotalordermagfSse42Correct : Prop :=
  FnCorrectlyRounded Eq (fun m (p : Model .binary32 × Model .binary32) =>
    if FloatLibSpec.totalordermag m p.1 p.2 then 1#32 else 0#32) cModes
    (fun _ p => Sse42.totalordermagf p.1 p.2)

/-- Exact IEEE 754 agreement of `totalordermagf` (`avx2_fma`) in all four C modes. -/
def TotalordermagfAvx2FmaCorrect : Prop :=
  FnCorrectlyRounded Eq (fun m (p : Model .binary32 × Model .binary32) =>
    if FloatLibSpec.totalordermag m p.1 p.2 then 1#32 else 0#32) cModes
    (fun _ p => Avx2Fma.totalordermagf p.1 p.2)

/-- Exact IEEE 754 agreement of `totalordermagf` (`aarch64`) in all four C modes. -/
def TotalordermagfAArch64Correct : Prop :=
  FnCorrectlyRounded Eq (fun m (p : Model .binary32 × Model .binary32) =>
    if FloatLibSpec.totalordermag m p.1 p.2 then 1#32 else 0#32) cModes
    (fun _ p => AArch64.totalordermagf p.1 p.2)

end LibcMath.Kernels.Totalordermagf
