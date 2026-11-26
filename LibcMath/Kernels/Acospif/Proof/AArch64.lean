import LibcMath.Kernels.Acospif.Statement

/-!
# `acospif` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Acospif.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Acospif.Generated

/-- **Open.** Prove `acospif` (`aarch64`) is correctly rounded in all four C modes. -/
theorem acospifAArch64_correctlyRounded : AcospifAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Acospif.Proof.AArch64.acospifAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms acospifAArch64_correctlyRounded

end LibcMath.Kernels.Acospif.Proof.AArch64
