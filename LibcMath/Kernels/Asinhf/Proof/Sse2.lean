import LibcMath.Kernels.Asinhf.Statement

/-!
# `asinhf` (`sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Asinhf.Proof.Sse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Asinhf.Generated

/-- **Open.** Prove `asinhf` (`sse2`) is correctly rounded in all four C modes. -/
theorem asinhfSse2_correctlyRounded : AsinhfSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Asinhf.Proof.Sse2.asinhfSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms asinhfSse2_correctlyRounded

end LibcMath.Kernels.Asinhf.Proof.Sse2
