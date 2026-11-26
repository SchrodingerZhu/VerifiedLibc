import LibcMath.Kernels.Fmaximumf.Statement

/-!
# `fmaximumf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fmaximumf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fmaximumf.Generated

/-- **Open.** Prove `fmaximumf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem fmaximumfAArch64_correctlyRounded : FmaximumfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fmaximumf.Proof.AArch64.fmaximumfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmaximumfAArch64_correctlyRounded

end LibcMath.Kernels.Fmaximumf.Proof.AArch64
