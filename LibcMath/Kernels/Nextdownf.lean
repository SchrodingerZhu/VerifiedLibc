import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Nextdownf.Generated.GenericSse2

/-!
# Extracted `nextdownf` generic SSE2 plan

Collects the extracted LLVM libc `nextdownf` (`generic_sse2`) plan and states its obligation.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Nextdownf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Nextdownf.Generated

/-- Correct rounding of `nextdownf` (`generic_sse2`) in all four C modes. -/
def NextdownfGenericSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.nextdown cModes GenericSse2.kernel.eval

/-- **Open.** Prove `nextdownf` (`generic_sse2`) matches `FloatLibSpec.nextdown` in all C modes.
-/
theorem nextdownfGenericSse2_correctlyRounded : NextdownfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Nextdownf.nextdownfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms nextdownfGenericSse2_correctlyRounded

end LibcMath.Kernels.Nextdownf
