import LibcMath.Kernels.Fminf.Statement

/-!
# `fminf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fminf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fminf.Generated

/-- **Open.** Prove `fminf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem fminfAArch64_correctlyRounded : FminfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fminf.Proof.AArch64.fminfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fminfAArch64_correctlyRounded

end LibcMath.Kernels.Fminf.Proof.AArch64
