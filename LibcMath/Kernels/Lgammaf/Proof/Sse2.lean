import LibcMath.Kernels.Lgammaf.Statement

/-!
# `lgammaf` (`sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Lgammaf.Proof.Sse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Lgammaf.Generated

/-- **Open.** Prove `lgammaf` (`sse2`) is correctly rounded in all four C modes. -/
theorem lgammafSse2_correctlyRounded : LgammafSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Lgammaf.Proof.Sse2.lgammafSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms lgammafSse2_correctlyRounded

end LibcMath.Kernels.Lgammaf.Proof.Sse2
