import LibcMath.Framework.Spec
import LibcMath.Kernels.Lroundf.Generated.GenericSse2

/-!
# Extracted `lroundf` generic SSE2 plan

Collects the extracted LLVM libc `lroundf` (`generic_sse2`) plan and states its obligation.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Lroundf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Lroundf.Generated

/-- Definedness (no C++ undefined behavior) of `lroundf` (`generic_sse2`). -/
def LroundfGenericSse2Defined : Prop :=
  ∀ x : Model .binary32, (GenericSse2.lroundf x).isSome

/-- **Open.** Prove `lroundf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem lroundfGenericSse2_defined : LroundfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Lroundf.lroundfGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms lroundfGenericSse2_defined

end LibcMath.Kernels.Lroundf
