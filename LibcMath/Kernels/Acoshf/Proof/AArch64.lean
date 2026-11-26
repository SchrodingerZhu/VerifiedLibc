import LibcMath.Kernels.Acoshf.Statement

/-!
# `acoshf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Acoshf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Acoshf.Generated

/-- **Open.** Prove `acoshf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem acoshfAArch64_correctlyRounded : AcoshfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Acoshf.Proof.AArch64.acoshfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms acoshfAArch64_correctlyRounded

end LibcMath.Kernels.Acoshf.Proof.AArch64
