import LibcMath.Kernels.Isnanf.Plans
import LibcMath.Framework.Spec

/-!
# Correctness statements for extracted `isnanf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Isnanf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Isnanf.Generated

/-- Exact agreement of `isnanf` (`generic_sse2`) with IEEE NaN classification. -/
def IsnanfGenericSse2Correct : Prop :=
  FnCorrectlyRounded Eq (fun _ (x : Model .binary32) => if x.isNaN then 1#32 else 0#32) cModes
    (fun _ x => GenericSse2.isnanf x)

/-- Exact agreement of `isnanf` (`sse42`) with IEEE NaN classification. -/
def IsnanfSse42Correct : Prop :=
  FnCorrectlyRounded Eq (fun _ (x : Model .binary32) => if x.isNaN then 1#32 else 0#32) cModes
    (fun _ x => Sse42.isnanf x)

/-- Exact agreement of `isnanf` (`avx2_fma`) with IEEE NaN classification. -/
def IsnanfAvx2FmaCorrect : Prop :=
  FnCorrectlyRounded Eq (fun _ (x : Model .binary32) => if x.isNaN then 1#32 else 0#32) cModes
    (fun _ x => Avx2Fma.isnanf x)

/-- Exact agreement of `isnanf` (`aarch64`) with IEEE NaN classification. -/
def IsnanfAArch64Correct : Prop :=
  FnCorrectlyRounded Eq (fun _ (x : Model .binary32) => if x.isNaN then 1#32 else 0#32) cModes
    (fun _ x => AArch64.isnanf x)

end LibcMath.Kernels.Isnanf
