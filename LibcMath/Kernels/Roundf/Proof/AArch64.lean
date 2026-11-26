import LibcMath.Kernels.Roundf.Statement

/-!
# `roundf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Roundf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Roundf.Generated

/-- **Open.** Prove `roundf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem roundfAArch64_correctlyRounded : RoundfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Roundf.Proof.AArch64.roundfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms roundfAArch64_correctlyRounded

end LibcMath.Kernels.Roundf.Proof.AArch64
