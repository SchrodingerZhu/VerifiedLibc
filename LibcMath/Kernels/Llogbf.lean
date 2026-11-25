import LibcMath.Framework.Spec
import LibcMath.Kernels.Llogbf.Generated.GenericSse2

/-!
# Extracted `llogbf` generic SSE2 plan

Collects the extracted LLVM libc `llogbf` (`generic_sse2`) plan and states its obligation.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Llogbf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Llogbf.Generated

/-- Definedness (no C++ undefined behavior) of `llogbf` (`generic_sse2`). -/
def LlogbfGenericSse2Defined : Prop :=
  ∀ x : Model .binary32, (GenericSse2.llogbf x).isSome

/-- **Open.** Prove `llogbf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem llogbfGenericSse2_defined : LlogbfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Llogbf.llogbfGenericSse2_defined' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms llogbfGenericSse2_defined

end LibcMath.Kernels.Llogbf
