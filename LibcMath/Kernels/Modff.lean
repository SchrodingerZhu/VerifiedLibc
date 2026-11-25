import LibcMath.Framework.Spec
import LibcMath.Kernels.Modff.Generated.GenericSse2

/-!
# Extracted `modff` generic SSE2 plan

Collects the extracted LLVM libc `modff` (`generic_sse2`) plan and states its obligation.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Modff

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Modff.Generated

/-- Definedness (no C++ undefined behavior) of `modff` (`generic_sse2`). -/
def ModffGenericSse2Defined : Prop :=
  ∀ m ∈ cModes, ∀ x : Model .binary32, (GenericSse2.modff m x).isSome

/-- **Open.** Prove `modff` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem modffGenericSse2_defined : ModffGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Modff.modffGenericSse2_defined' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms modffGenericSse2_defined

end LibcMath.Kernels.Modff
