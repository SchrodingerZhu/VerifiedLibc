import LibcMath.Kernels.Acosf.Statement

/-!
# `acosf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Acosf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Acosf.Generated

/-- **Open.** Prove `acosf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem acosfAArch64_correctlyRounded : AcosfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Acosf.Proof.AArch64.acosfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms acosfAArch64_correctlyRounded

end LibcMath.Kernels.Acosf.Proof.AArch64
