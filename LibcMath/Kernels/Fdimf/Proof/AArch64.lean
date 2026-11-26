import LibcMath.Kernels.Fdimf.Statement

/-!
# `fdimf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fdimf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fdimf.Generated

/-- **Open.** Prove `fdimf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem fdimfAArch64_correctlyRounded : FdimfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fdimf.Proof.AArch64.fdimfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fdimfAArch64_correctlyRounded

end LibcMath.Kernels.Fdimf.Proof.AArch64
