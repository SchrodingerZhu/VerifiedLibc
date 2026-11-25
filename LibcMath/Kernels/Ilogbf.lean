import LibcMath.Framework.Spec
import LibcMath.Kernels.Ilogbf.Generated.GenericSse2

/-!
# Extracted `ilogbf` generic SSE2 plan

Collects the extracted LLVM libc `ilogbf` (`generic_sse2`) plan and states its obligation.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Ilogbf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Ilogbf.Generated

/-- Definedness (no C++ undefined behavior) of `ilogbf` (`generic_sse2`). -/
def IlogbfGenericSse2Defined : Prop :=
  ∀ x : Model .binary32, (GenericSse2.ilogbf x).isSome

/-- **Open.** Prove `ilogbf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem ilogbfGenericSse2_defined : IlogbfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Ilogbf.ilogbfGenericSse2_defined' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms ilogbfGenericSse2_defined

end LibcMath.Kernels.Ilogbf
