import LibcMath.Framework.Spec
import LibcMath.Kernels.Setpayloadf.Generated.GenericSse2

/-!
# Extracted `setpayloadf` generic SSE2 plan

Collects the extracted LLVM libc `setpayloadf` (`generic_sse2`) plan and states its obligation.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Setpayloadf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Setpayloadf.Generated

/-- Definedness (no C++ undefined behavior) of `setpayloadf` (`generic_sse2`). -/
def SetpayloadfGenericSse2Defined : Prop :=
  ∀ m ∈ cModes, ∀ x : Model .binary32, (GenericSse2.setpayloadf m x).isSome

/-- **Open.** Prove `setpayloadf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem setpayloadfGenericSse2_defined : SetpayloadfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Setpayloadf.setpayloadfGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms setpayloadfGenericSse2_defined

end LibcMath.Kernels.Setpayloadf
