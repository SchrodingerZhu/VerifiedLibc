import LibcMath.Kernels.Fabsf.Statement

/-!
# `fabsf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fabsf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fabsf.Generated

/-- **Open.** Prove `fabsf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem fabsfAArch64_correctlyRounded : FabsfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fabsf.Proof.AArch64.fabsfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fabsfAArch64_correctlyRounded

end LibcMath.Kernels.Fabsf.Proof.AArch64
