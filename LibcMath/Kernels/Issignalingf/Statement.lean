import LibcMath.Kernels.Issignalingf.Plans
import LibcMath.Framework.Spec

/-!
# Correctness statements for extracted `issignalingf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Issignalingf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Issignalingf.Generated

/-- Exact agreement of `issignalingf` (`generic_sse2`) with IEEE sNaN test. -/
def IssignalingfGenericSse2Correct : Prop :=
  FnCorrectlyRounded Eq (fun _ (x : Model .binary32) => if x.isSignaling then 1#32 else 0#32) cModes
    (fun _ x => GenericSse2.issignalingf x)

/-- Exact agreement of `issignalingf` (`sse42`) with IEEE sNaN test. -/
def IssignalingfSse42Correct : Prop :=
  FnCorrectlyRounded Eq (fun _ (x : Model .binary32) => if x.isSignaling then 1#32 else 0#32) cModes
    (fun _ x => Sse42.issignalingf x)

/-- Exact agreement of `issignalingf` (`avx2_fma`) with IEEE sNaN test. -/
def IssignalingfAvx2FmaCorrect : Prop :=
  FnCorrectlyRounded Eq (fun _ (x : Model .binary32) => if x.isSignaling then 1#32 else 0#32) cModes
    (fun _ x => Avx2Fma.issignalingf x)

/-- Exact agreement of `issignalingf` (`aarch64`) with IEEE sNaN test. -/
def IssignalingfAArch64Correct : Prop :=
  FnCorrectlyRounded Eq (fun _ (x : Model .binary32) => if x.isSignaling then 1#32 else 0#32) cModes
    (fun _ x => AArch64.issignalingf x)

end LibcMath.Kernels.Issignalingf
