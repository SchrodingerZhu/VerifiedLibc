import LibcMath.Kernels.Atanhf.Statement

/-!
# `atanhf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Atanhf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Atanhf.Generated

/-- **Open.** Prove `atanhf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem atanhfAArch64_correctlyRounded : AtanhfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Atanhf.Proof.AArch64.atanhfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms atanhfAArch64_correctlyRounded

end LibcMath.Kernels.Atanhf.Proof.AArch64
