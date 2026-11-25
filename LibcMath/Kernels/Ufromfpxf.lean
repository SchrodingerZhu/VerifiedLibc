import LibcMath.Framework.Spec
import LibcMath.Kernels.Ufromfpxf.Generated.GenericSse2

/-!
# Extracted `ufromfpxf` generic SSE2 plan

Collects the extracted LLVM libc `ufromfpxf` (`generic_sse2`) plan and states its obligation.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Ufromfpxf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Ufromfpxf.Generated

/-- Definedness (no C++ undefined behavior) of `ufromfpxf` (`generic_sse2`). -/
def UfromfpxfGenericSse2Defined : Prop :=
  ∀ m ∈ cModes, ∀ (x : Model .binary32) (r w : BitVec 32), (GenericSse2.ufromfpxf m x r w).isSome

/-- **Open.** Prove `ufromfpxf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem ufromfpxfGenericSse2_defined : UfromfpxfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Ufromfpxf.ufromfpxfGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms ufromfpxfGenericSse2_defined

end LibcMath.Kernels.Ufromfpxf
