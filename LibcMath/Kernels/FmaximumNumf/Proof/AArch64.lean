import LibcMath.Kernels.FmaximumNumf.Statement

/-!
# `fmaximum_numf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.FmaximumNumf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FmaximumNumf.Generated

/-- **Open.** Prove `fmaximum_numf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem fmaximum_numfAArch64_correctlyRounded : FmaximumNumfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.FmaximumNumf.Proof.AArch64.fmaximum_numfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmaximum_numfAArch64_correctlyRounded

end LibcMath.Kernels.FmaximumNumf.Proof.AArch64
