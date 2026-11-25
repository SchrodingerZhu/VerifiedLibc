import LibcMath.Framework.Spec
import LibcMath.Kernels.Iscanonicalf.Generated.GenericSse2

/-!
# Extracted `iscanonicalf` generic SSE2 plan

Collects the extracted LLVM libc `iscanonicalf` (`generic_sse2`) plan and states its obligation.
Every statement names its microarch plan explicitly.
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

/-- **Open.** Prove `iscanonicalf` (`generic_sse2`) matches IEEE canonical encoding predicate. -/
theorem iscanonicalfGenericSse2_correct : IscanonicalfGenericSse2Correct := by
  sorry

/--
info: 'LibcMath.Kernels.Iscanonicalf.iscanonicalfGenericSse2_correct' depends on axioms: [sorryAx]
-/
#guard_msgs in
#print axioms iscanonicalfGenericSse2_correct

end LibcMath.Kernels.Iscanonicalf
