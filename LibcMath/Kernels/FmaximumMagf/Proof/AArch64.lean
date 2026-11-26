import LibcMath.Kernels.FmaximumMagf.Statement

/-!
# `fmaximum_magf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.FmaximumMagf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FmaximumMagf.Generated

/-- **Open.** Prove `fmaximum_magf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem fmaximum_magfAArch64_correctlyRounded : FmaximumMagfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.FmaximumMagf.Proof.AArch64.fmaximum_magfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmaximum_magfAArch64_correctlyRounded

end LibcMath.Kernels.FmaximumMagf.Proof.AArch64
