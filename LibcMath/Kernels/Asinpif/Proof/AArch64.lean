import LibcMath.Kernels.Asinpif.Statement

/-!
# `asinpif` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Asinpif.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Asinpif.Generated

/-- **Open.** Prove `asinpif` (`aarch64`) is correctly rounded in all four C modes. -/
theorem asinpifAArch64_correctlyRounded : AsinpifAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Asinpif.Proof.AArch64.asinpifAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms asinpifAArch64_correctlyRounded

end LibcMath.Kernels.Asinpif.Proof.AArch64
