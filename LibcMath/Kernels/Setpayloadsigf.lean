import LibcMath.Framework.Spec
import LibcMath.Kernels.Setpayloadsigf.Generated.GenericSse2

/-!
# Extracted `setpayloadsigf` generic SSE2 plan

Collects the extracted LLVM libc `setpayloadsigf` (`generic_sse2`) plan and states its obligation.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Setpayloadsigf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Setpayloadsigf.Generated

/-- Definedness (no C++ undefined behavior) of `setpayloadsigf` (`generic_sse2`). -/
def SetpayloadsigfGenericSse2Defined : Prop :=
  ∀ m ∈ cModes, ∀ x : Model .binary32, (GenericSse2.setpayloadsigf m x).isSome

/-- **Open.** Prove `setpayloadsigf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem setpayloadsigfGenericSse2_defined : SetpayloadsigfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Setpayloadsigf.setpayloadsigfGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms setpayloadsigfGenericSse2_defined

end LibcMath.Kernels.Setpayloadsigf
