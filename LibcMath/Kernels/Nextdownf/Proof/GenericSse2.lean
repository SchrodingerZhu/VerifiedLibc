import LibcMath.Kernels.Nextdownf.Statement

/-!
# `nextdownf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Nextdownf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Nextdownf.Generated

/-- **Open.** Prove `nextdownf` (`generic_sse2`) matches `FloatLibSpec.nextdown` in all C modes.
-/
theorem nextdownfGenericSse2_correctlyRounded : NextdownfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Nextdownf.Proof.GenericSse2.nextdownfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms nextdownfGenericSse2_correctlyRounded

end LibcMath.Kernels.Nextdownf.Proof.GenericSse2
