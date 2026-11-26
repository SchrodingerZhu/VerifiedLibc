import LibcMath.Kernels.FminimumNumf.Statement

/-!
# `fminimum_numf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.FminimumNumf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FminimumNumf.Generated

/-- **Open.** Prove `fminimum_numf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem fminimum_numfAArch64_correctlyRounded : FminimumNumfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.FminimumNumf.Proof.AArch64.fminimum_numfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fminimum_numfAArch64_correctlyRounded

end LibcMath.Kernels.FminimumNumf.Proof.AArch64
