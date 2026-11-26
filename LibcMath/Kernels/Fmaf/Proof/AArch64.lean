import LibcMath.Kernels.Fmaf.Statement

/-!
# `fmaf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fmaf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fmaf.Generated

/-- **Open.** Prove `fmaf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem fmafAArch64_correctlyRounded : FmafAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fmaf.Proof.AArch64.fmafAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmafAArch64_correctlyRounded

end LibcMath.Kernels.Fmaf.Proof.AArch64
