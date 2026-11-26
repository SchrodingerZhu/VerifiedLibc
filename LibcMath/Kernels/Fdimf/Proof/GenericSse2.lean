import LibcMath.Kernels.Fdimf.Statement

/-!
# `fdimf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fdimf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fdimf.Generated

/-- **Open.** Prove `fdimf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem fdimfGenericSse2_correctlyRounded : FdimfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fdimf.Proof.GenericSse2.fdimfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fdimfGenericSse2_correctlyRounded

end LibcMath.Kernels.Fdimf.Proof.GenericSse2
