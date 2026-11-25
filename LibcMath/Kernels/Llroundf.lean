import LibcMath.Framework.Spec
import LibcMath.Kernels.Llroundf.Generated.GenericSse2

/-!
# Extracted `llroundf` generic SSE2 plan

Collects the extracted LLVM libc `llroundf` (`generic_sse2`) plan and states its obligation.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Llroundf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Llroundf.Generated

/-- Definedness (no C++ undefined behavior) of `llroundf` (`generic_sse2`). -/
def LlroundfGenericSse2Defined : Prop :=
  ∀ x : Model .binary32, (GenericSse2.llroundf x).isSome

/-- **Open.** Prove `llroundf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem llroundfGenericSse2_defined : LlroundfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Llroundf.llroundfGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms llroundfGenericSse2_defined

end LibcMath.Kernels.Llroundf
