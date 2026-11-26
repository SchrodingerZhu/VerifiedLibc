import LibcMath.Kernels.Fmaxf.Statement

/-!
# `fmaxf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fmaxf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fmaxf.Generated

/-- **Open.** Prove `fmaxf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem fmaxfAArch64_correctlyRounded : FmaxfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fmaxf.Proof.AArch64.fmaxfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmaxfAArch64_correctlyRounded

end LibcMath.Kernels.Fmaxf.Proof.AArch64
