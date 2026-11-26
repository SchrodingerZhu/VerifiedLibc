import LibcMath.Kernels.Expm1f.Statement

/-!
# `expm1f` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Expm1f.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Expm1f.Generated

/-- **Open.** Prove `expm1f` (`aarch64`) is correctly rounded across all four C rounding modes. -/
theorem expm1fAArch64_correctlyRounded : Expm1fAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Expm1f.Proof.AArch64.expm1fAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms expm1fAArch64_correctlyRounded

end LibcMath.Kernels.Expm1f.Proof.AArch64
