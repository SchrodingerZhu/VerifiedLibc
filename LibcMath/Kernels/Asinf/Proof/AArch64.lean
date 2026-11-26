import LibcMath.Kernels.Asinf.Statement

/-!
# `asinf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Asinf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Asinf.Generated

/-- **Open.** Prove `asinf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem asinfAArch64_correctlyRounded : AsinfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Asinf.Proof.AArch64.asinfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms asinfAArch64_correctlyRounded

end LibcMath.Kernels.Asinf.Proof.AArch64
