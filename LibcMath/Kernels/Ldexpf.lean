import LibcMath.Framework.Spec
import LibcMath.Kernels.Ldexpf.Generated.GenericSse2

/-!
# Extracted `ldexpf` generic SSE2 plan

Collects the extracted LLVM libc `ldexpf` (`generic_sse2`) plan and states its obligation.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Ldexpf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Ldexpf.Generated

/-- Definedness (no C++ undefined behavior) of `ldexpf` (`generic_sse2`). -/
def LdexpfGenericSse2Defined : Prop :=
  ∀ m ∈ cModes, ∀ (x : Model .binary32) (e : BitVec 32), (GenericSse2.ldexpf m x e).isSome

/-- **Open.** Prove `ldexpf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem ldexpfGenericSse2_defined : LdexpfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Ldexpf.ldexpfGenericSse2_defined' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms ldexpfGenericSse2_defined

end LibcMath.Kernels.Ldexpf
