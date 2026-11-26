import LibcMath.Kernels.Roundevenf.Statement

/-!
# `roundevenf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Roundevenf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Roundevenf.Generated

/-- **Open.** Prove `roundevenf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem roundevenfGenericSse2_correctlyRounded : RoundevenfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Roundevenf.Proof.GenericSse2.roundevenfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms roundevenfGenericSse2_correctlyRounded

end LibcMath.Kernels.Roundevenf.Proof.GenericSse2
