import LibcMath.Kernels.Asinhf.Statement

/-!
# `asinhf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Asinhf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Asinhf.Generated

/-- **Open.** Prove `asinhf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem asinhfAArch64_correctlyRounded : AsinhfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Asinhf.Proof.AArch64.asinhfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms asinhfAArch64_correctlyRounded

end LibcMath.Kernels.Asinhf.Proof.AArch64
