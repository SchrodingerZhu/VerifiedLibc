import LibcMath.Kernels.Coshf.Statement

/-!
# `coshf` (`sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Coshf.Proof.Sse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Coshf.Generated

/-- **Open.** Prove `coshf` (`sse2`) is correctly rounded in all four C modes. -/
theorem coshfSse2_correctlyRounded : CoshfSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Coshf.Proof.Sse2.coshfSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms coshfSse2_correctlyRounded

end LibcMath.Kernels.Coshf.Proof.Sse2
