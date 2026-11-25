import LibcMath.Framework.Spec
import LibcMath.Kernels.Issignalingf.Generated.GenericSse2

/-!
# Extracted `issignalingf` generic SSE2 plan

Collects the extracted LLVM libc `issignalingf` (`generic_sse2`) plan and states its obligation.
Every statement names its microarch plan explicitly.
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

/-- **Open.** Prove `issignalingf` (`generic_sse2`) matches IEEE sNaN test. -/
theorem issignalingfGenericSse2_correct : IssignalingfGenericSse2Correct := by
  sorry

/--
info: 'LibcMath.Kernels.Issignalingf.issignalingfGenericSse2_correct' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms issignalingfGenericSse2_correct

end LibcMath.Kernels.Issignalingf
