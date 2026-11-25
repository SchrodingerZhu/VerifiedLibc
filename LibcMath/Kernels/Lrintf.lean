import LibcMath.Framework.Spec
import LibcMath.Kernels.Lrintf.Generated.GenericSse2

/-!
# Extracted `lrintf` generic SSE2 plan

Collects the extracted LLVM libc `lrintf` (`generic_sse2`) plan and states its obligation.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Lrintf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Lrintf.Generated

/-- Definedness (no C++ undefined behavior) of `lrintf` (`generic_sse2`). -/
def LrintfGenericSse2Defined : Prop :=
  ∀ m ∈ cModes, ∀ x : Model .binary32, (GenericSse2.lrintf m x).isSome

/-- **Open.** Prove `lrintf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem lrintfGenericSse2_defined : LrintfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Lrintf.lrintfGenericSse2_defined' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms lrintfGenericSse2_defined

end LibcMath.Kernels.Lrintf
