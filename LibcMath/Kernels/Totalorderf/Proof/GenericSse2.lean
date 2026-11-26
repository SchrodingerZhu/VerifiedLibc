import LibcMath.Kernels.Totalorderf.Statement

/-!
# `totalorderf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Totalorderf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Totalorderf.Generated

/-- **Open.** Prove `totalorderf` (`generic_sse2`) matches `FloatLibSpec.totalorder`. -/
theorem totalorderfGenericSse2_correct : TotalorderfGenericSse2Correct := by
  sorry

/--
info: 'LibcMath.Kernels.Totalorderf.Proof.GenericSse2.totalorderfGenericSse2_correct' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms totalorderfGenericSse2_correct

end LibcMath.Kernels.Totalorderf.Proof.GenericSse2
