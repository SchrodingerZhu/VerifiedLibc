import LibcMath.Kernels.Roundevenf.Statement

/-!
# `roundevenf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Roundevenf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Roundevenf.Generated

/-- **Open.** Prove `roundevenf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem roundevenfAArch64_correctlyRounded : RoundevenfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Roundevenf.Proof.AArch64.roundevenfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms roundevenfAArch64_correctlyRounded

end LibcMath.Kernels.Roundevenf.Proof.AArch64
