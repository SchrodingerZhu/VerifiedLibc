import LibcMath.Framework.Spec
import LibcMath.Kernels.Scalblnf.Generated.GenericSse2

/-!
# Extracted `scalblnf` generic SSE2 plan

Collects the extracted LLVM libc `scalblnf` (`generic_sse2`) plan and states its obligation.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Scalblnf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Scalblnf.Generated

/-- Definedness (no C++ undefined behavior) of `scalblnf` (`generic_sse2`). -/
def ScalblnfGenericSse2Defined : Prop :=
  ∀ m ∈ cModes, ∀ (x : Model .binary32) (n : BitVec 64), (GenericSse2.scalblnf m x n).isSome

/-- **Open.** Prove `scalblnf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem scalblnfGenericSse2_defined : ScalblnfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Scalblnf.scalblnfGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms scalblnfGenericSse2_defined

end LibcMath.Kernels.Scalblnf
