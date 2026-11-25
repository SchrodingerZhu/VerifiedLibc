import LibcMath.Framework.Spec
import LibcMath.Kernels.Nextafterf.Generated.GenericSse2

/-!
# Extracted `nextafterf` generic SSE2 plan

Collects the extracted LLVM libc `nextafterf` (`generic_sse2`) plan and states its obligation.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Nextafterf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Nextafterf.Generated

/-- Definedness (no C++ undefined behavior) of `nextafterf` (`generic_sse2`). -/
def NextafterfGenericSse2Defined : Prop :=
  ∀ x y : Model .binary32, (GenericSse2.nextafterf x y).isSome

/-- **Open.** Prove `nextafterf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem nextafterfGenericSse2_defined : NextafterfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Nextafterf.nextafterfGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms nextafterfGenericSse2_defined

end LibcMath.Kernels.Nextafterf
