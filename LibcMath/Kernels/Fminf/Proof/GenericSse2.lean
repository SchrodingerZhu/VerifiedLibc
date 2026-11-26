import LibcMath.Kernels.Fminf.Statement

/-!
# `fminf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fminf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fminf.Generated

/-- **Open.** Prove `fminf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem fminfGenericSse2_correctlyRounded : FminfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fminf.Proof.GenericSse2.fminfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fminfGenericSse2_correctlyRounded

end LibcMath.Kernels.Fminf.Proof.GenericSse2
