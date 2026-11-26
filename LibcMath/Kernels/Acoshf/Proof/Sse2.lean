import LibcMath.Kernels.Acoshf.Statement

/-!
# `acoshf` (`sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Acoshf.Proof.Sse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Acoshf.Generated

/-- **Open.** Prove `acoshf` (`sse2`) is correctly rounded in all four C modes. -/
theorem acoshfSse2_correctlyRounded : AcoshfSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Acoshf.Proof.Sse2.acoshfSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms acoshfSse2_correctlyRounded

end LibcMath.Kernels.Acoshf.Proof.Sse2
