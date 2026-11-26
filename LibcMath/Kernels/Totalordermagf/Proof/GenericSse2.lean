import LibcMath.Kernels.Totalordermagf.Statement

/-!
# `totalordermagf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Totalordermagf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Totalordermagf.Generated

/-- **Open.** Prove `totalordermagf` (`generic_sse2`) matches `FloatLibSpec.totalordermag`. -/
theorem totalordermagfGenericSse2_correct : TotalordermagfGenericSse2Correct := by
  sorry

/--
info: 'LibcMath.Kernels.Totalordermagf.Proof.GenericSse2.totalordermagfGenericSse2_correct' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms totalordermagfGenericSse2_correct

end LibcMath.Kernels.Totalordermagf.Proof.GenericSse2
