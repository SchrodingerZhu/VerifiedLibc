import LibcMath.Kernels.Sinhf.Statement

/-!
# `sinhf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Sinhf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Sinhf.Generated

/-- **Open.** Prove `sinhf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem sinhfAArch64_correctlyRounded : SinhfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Sinhf.Proof.AArch64.sinhfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sinhfAArch64_correctlyRounded

end LibcMath.Kernels.Sinhf.Proof.AArch64
