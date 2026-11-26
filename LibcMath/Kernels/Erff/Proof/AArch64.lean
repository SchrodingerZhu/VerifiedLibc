import LibcMath.Kernels.Erff.Statement

/-!
# `erff` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Erff.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Erff.Generated

/-- **Open.** Prove `erff` (`aarch64`) is correctly rounded in all four C modes. -/
theorem erffAArch64_correctlyRounded : ErffAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Erff.Proof.AArch64.erffAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms erffAArch64_correctlyRounded

end LibcMath.Kernels.Erff.Proof.AArch64
