import LibcMath.Kernels.Ceilf.Statement

/-!
# `ceilf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Ceilf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Ceilf.Generated

/-- **Open.** Prove `ceilf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem ceilfAArch64_correctlyRounded : CeilfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Ceilf.Proof.AArch64.ceilfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms ceilfAArch64_correctlyRounded

end LibcMath.Kernels.Ceilf.Proof.AArch64
