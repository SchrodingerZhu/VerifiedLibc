import LibcMath.Framework.Spec
import LibcMath.Kernels.Logbf.Generated.GenericSse2

/-!
# Extracted `logbf` generic SSE2 plan

Collects the extracted LLVM libc `logbf` (`generic_sse2`) plan and states its obligation.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Logbf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Logbf.Generated

/-- Definedness (no C++ undefined behavior) of `logbf` (`generic_sse2`). -/
def LogbfGenericSse2Defined : Prop :=
  ∀ x : Model .binary32, (GenericSse2.logbf x).isSome

/-- **Open.** Prove `logbf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem logbfGenericSse2_defined : LogbfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Logbf.logbfGenericSse2_defined' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms logbfGenericSse2_defined

end LibcMath.Kernels.Logbf
