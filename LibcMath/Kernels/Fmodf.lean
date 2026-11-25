import LibcMath.Framework.Spec
import LibcMath.Kernels.Fmodf.Generated.GenericSse2

/-!
# Extracted `fmodf` generic SSE2 plan

Collects the extracted LLVM libc `fmodf` (`generic_sse2`) plan and states its obligation.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Fmodf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Fmodf.Generated

/-- Definedness (no C++ undefined behavior) of `fmodf` (`generic_sse2`). -/
def FmodfGenericSse2Defined : Prop :=
  ∀ x y : Model .binary32, (GenericSse2.fmodf x y).isSome

/-- **Open.** Prove `fmodf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem fmodfGenericSse2_defined : FmodfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Fmodf.fmodfGenericSse2_defined' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms fmodfGenericSse2_defined

end LibcMath.Kernels.Fmodf
