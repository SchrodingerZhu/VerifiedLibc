import LibcMath.Kernels.Tanhf.Statement

/-!
# `tanhf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Tanhf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Tanhf.Generated

/-- **Open.** Prove `tanhf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem tanhfAArch64_correctlyRounded : TanhfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Tanhf.Proof.AArch64.tanhfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms tanhfAArch64_correctlyRounded

end LibcMath.Kernels.Tanhf.Proof.AArch64
