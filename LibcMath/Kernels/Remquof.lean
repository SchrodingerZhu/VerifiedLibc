import LibcMath.Framework.Spec
import LibcMath.Kernels.Remquof.Generated.GenericSse2

/-!
# Extracted `remquof` generic SSE2 plan

Collects the extracted LLVM libc `remquof` (`generic_sse2`) plan and states its obligation.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Remquof

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Remquof.Generated

/-- Definedness (no C++ undefined behavior) of `remquof` (`generic_sse2`). -/
def RemquofGenericSse2Defined : Prop :=
  ∀ m ∈ cModes, ∀ x y : Model .binary32, (GenericSse2.remquof m x y).isSome

/-- **Open.** Prove `remquof` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem remquofGenericSse2_defined : RemquofGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Remquof.remquofGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms remquofGenericSse2_defined

end LibcMath.Kernels.Remquof
