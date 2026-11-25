import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Totalorderf.Generated.GenericSse2

/-!
# Extracted `totalorderf` generic SSE2 plan

Collects the extracted LLVM libc `totalorderf` (`generic_sse2`) plan and states its obligation.
Every statement names its microarch plan explicitly.
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

/-- **Open.** Prove `totalorderf` (`generic_sse2`) matches `FloatLibSpec.totalorder`. -/
theorem totalorderfGenericSse2_correct : TotalorderfGenericSse2Correct := by
  sorry

/--
info: 'LibcMath.Kernels.Totalorderf.totalorderfGenericSse2_correct' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms totalorderfGenericSse2_correct

end LibcMath.Kernels.Totalorderf
