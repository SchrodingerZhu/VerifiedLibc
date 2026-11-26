import LibcMath.Kernels.Sqrtf.Statement

/-!
# `sqrtf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Sqrtf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Sqrtf.Generated

/-- **Open.** Prove `sqrtf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem sqrtfAArch64_correctlyRounded : SqrtfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Sqrtf.Proof.AArch64.sqrtfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sqrtfAArch64_correctlyRounded

end LibcMath.Kernels.Sqrtf.Proof.AArch64
