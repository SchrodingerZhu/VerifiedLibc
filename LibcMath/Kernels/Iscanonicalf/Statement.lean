import LibcMath.Kernels.Iscanonicalf.Plans
import LibcMath.Framework.Spec

/-!
# Correctness statements for extracted `iscanonicalf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Iscanonicalf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Iscanonicalf.Generated

/-- Exact agreement of `iscanonicalf` (`generic_sse2`) with IEEE canonical encoding predicate. -/
def IscanonicalfGenericSse2Correct : Prop :=
  FnCorrectlyRounded Eq (fun _ (_ : Model .binary32) => 1#32) cModes
    (fun _ x => GenericSse2.iscanonicalf x)

/-- Exact agreement of `iscanonicalf` (`sse42`) with IEEE canonical encoding predicate. -/
def IscanonicalfSse42Correct : Prop :=
  FnCorrectlyRounded Eq (fun _ (_ : Model .binary32) => 1#32) cModes
    (fun _ x => Sse42.iscanonicalf x)

/-- Exact agreement of `iscanonicalf` (`avx2_fma`) with IEEE canonical encoding predicate. -/
def IscanonicalfAvx2FmaCorrect : Prop :=
  FnCorrectlyRounded Eq (fun _ (_ : Model .binary32) => 1#32) cModes
    (fun _ x => Avx2Fma.iscanonicalf x)

/-- Exact agreement of `iscanonicalf` (`aarch64`) with IEEE canonical encoding predicate. -/
def IscanonicalfAArch64Correct : Prop :=
  FnCorrectlyRounded Eq (fun _ (_ : Model .binary32) => 1#32) cModes
    (fun _ x => AArch64.iscanonicalf x)

end LibcMath.Kernels.Iscanonicalf
