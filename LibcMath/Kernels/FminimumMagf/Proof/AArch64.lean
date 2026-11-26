import LibcMath.Kernels.FminimumMagf.Statement

/-!
# `fminimum_magf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.FminimumMagf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FminimumMagf.Generated

/-- **Open.** Prove `fminimum_magf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem fminimum_magfAArch64_correctlyRounded : FminimumMagfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.FminimumMagf.Proof.AArch64.fminimum_magfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fminimum_magfAArch64_correctlyRounded

end LibcMath.Kernels.FminimumMagf.Proof.AArch64
