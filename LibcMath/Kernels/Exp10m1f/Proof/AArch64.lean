import LibcMath.Kernels.Exp10m1f.Statement

/-!
# `exp10m1f` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Exp10m1f.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Exp10m1f.Generated

/-- **Open.** Prove `exp10m1f` (`aarch64`) is correctly rounded across all four C rounding modes. -/
theorem exp10m1fAArch64_correctlyRounded : Exp10m1fAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Exp10m1f.Proof.AArch64.exp10m1fAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp10m1fAArch64_correctlyRounded

end LibcMath.Kernels.Exp10m1f.Proof.AArch64
