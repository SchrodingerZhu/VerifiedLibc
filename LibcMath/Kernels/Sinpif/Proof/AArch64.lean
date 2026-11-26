import LibcMath.Kernels.Sinpif.Statement

/-!
# `sinpif` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Sinpif.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Sinpif.Generated

/-- **Open.** Prove `sinpif` (`aarch64`) is correctly rounded in all four C modes. -/
theorem sinpifAArch64_correctlyRounded : SinpifAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Sinpif.Proof.AArch64.sinpifAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sinpifAArch64_correctlyRounded

end LibcMath.Kernels.Sinpif.Proof.AArch64
