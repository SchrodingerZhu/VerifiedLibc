import LibcMath.Framework.Spec
import LibcMath.Kernels.Fromfpxf.Generated.GenericSse2

/-!
# Extracted `fromfpxf` generic SSE2 plan

Collects the extracted LLVM libc `fromfpxf` (`generic_sse2`) plan and states its obligation.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Fromfpxf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Fromfpxf.Generated

/-- Definedness (no C++ undefined behavior) of `fromfpxf` (`generic_sse2`). -/
def FromfpxfGenericSse2Defined : Prop :=
  ∀ (x : Model .binary32) (r w : BitVec 32), (GenericSse2.fromfpxf x r w).isSome

/-- **Open.** Prove `fromfpxf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem fromfpxfGenericSse2_defined : FromfpxfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Fromfpxf.fromfpxfGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fromfpxfGenericSse2_defined

end LibcMath.Kernels.Fromfpxf
