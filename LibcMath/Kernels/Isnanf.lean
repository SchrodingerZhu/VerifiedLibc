import LibcMath.Framework.Spec
import LibcMath.Kernels.Isnanf.Generated.GenericSse2

/-!
# Extracted `isnanf` generic SSE2 plan

Collects the extracted LLVM libc `isnanf` (`generic_sse2`) plan and states its obligation.
Every statement names its microarch plan explicitly.
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

/-- **Open.** Prove `isnanf` (`generic_sse2`) matches IEEE NaN classification. -/
theorem isnanfGenericSse2_correct : IsnanfGenericSse2Correct := by
  sorry

/--
info: 'LibcMath.Kernels.Isnanf.isnanfGenericSse2_correct' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms isnanfGenericSse2_correct

end LibcMath.Kernels.Isnanf
