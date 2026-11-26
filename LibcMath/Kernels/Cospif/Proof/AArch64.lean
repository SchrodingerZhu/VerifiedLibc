import LibcMath.Kernels.Cospif.Statement

/-!
# `cospif` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Cospif.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Cospif.Generated

/-- **Open.** Prove `cospif` (`aarch64`) is correctly rounded in all four C modes. -/
theorem cospifAArch64_correctlyRounded : CospifAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Cospif.Proof.AArch64.cospifAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms cospifAArch64_correctlyRounded

end LibcMath.Kernels.Cospif.Proof.AArch64
