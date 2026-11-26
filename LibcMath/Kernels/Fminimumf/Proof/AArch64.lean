import LibcMath.Kernels.Fminimumf.Statement

/-!
# `fminimumf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fminimumf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fminimumf.Generated

/-- **Open.** Prove `fminimumf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem fminimumfAArch64_correctlyRounded : FminimumfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fminimumf.Proof.AArch64.fminimumfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fminimumfAArch64_correctlyRounded

end LibcMath.Kernels.Fminimumf.Proof.AArch64
