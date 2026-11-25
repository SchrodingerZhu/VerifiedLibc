import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Nextupf.Generated.GenericSse2

/-!
# Extracted `nextupf` generic SSE2 plan

Collects the extracted LLVM libc `nextupf` (`generic_sse2`) plan and states its obligation.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Nextupf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Nextupf.Generated

/-- Correct rounding of `nextupf` (`generic_sse2`) in all four C modes. -/
def NextupfGenericSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.nextup cModes GenericSse2.kernel.eval

/-- **Open.** Prove `nextupf` (`generic_sse2`) matches `FloatLibSpec.nextup` in all four C modes. -/
theorem nextupfGenericSse2_correctlyRounded : NextupfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Nextupf.nextupfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms nextupfGenericSse2_correctlyRounded

end LibcMath.Kernels.Nextupf
