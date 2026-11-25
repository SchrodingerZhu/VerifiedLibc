import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Totalordermagf.Generated.GenericSse2

/-!
# Extracted `totalordermagf` generic SSE2 plan

Collects the extracted LLVM libc `totalordermagf` (`generic_sse2`) plan and states its obligation.
Every statement names its microarch plan explicitly.
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

/-- **Open.** Prove `totalordermagf` (`generic_sse2`) matches `FloatLibSpec.totalordermag`. -/
theorem totalordermagfGenericSse2_correct : TotalordermagfGenericSse2Correct := by
  sorry

/--
info: 'LibcMath.Kernels.Totalordermagf.totalordermagfGenericSse2_correct' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms totalordermagfGenericSse2_correct

end LibcMath.Kernels.Totalordermagf
