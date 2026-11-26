import LibcMath.Kernels.Tanpif.Statement

/-!
# `tanpif` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Tanpif.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Tanpif.Generated

/-- **Open.** Prove `tanpif` (`aarch64`) is correctly rounded in all four C modes. -/
theorem tanpifAArch64_correctlyRounded : TanpifAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Tanpif.Proof.AArch64.tanpifAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms tanpifAArch64_correctlyRounded

end LibcMath.Kernels.Tanpif.Proof.AArch64
