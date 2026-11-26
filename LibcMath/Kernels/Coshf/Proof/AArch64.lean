import LibcMath.Kernels.Coshf.Statement

/-!
# `coshf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Coshf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Coshf.Generated

/-- **Open.** Prove `coshf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem coshfAArch64_correctlyRounded : CoshfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Coshf.Proof.AArch64.coshfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms coshfAArch64_correctlyRounded

end LibcMath.Kernels.Coshf.Proof.AArch64
