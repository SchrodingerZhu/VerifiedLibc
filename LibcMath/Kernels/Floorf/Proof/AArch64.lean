import LibcMath.Kernels.Floorf.Statement

/-!
# `floorf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Floorf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Floorf.Generated

/-- **Open.** Prove `floorf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem floorfAArch64_correctlyRounded : FloorfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Floorf.Proof.AArch64.floorfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms floorfAArch64_correctlyRounded

end LibcMath.Kernels.Floorf.Proof.AArch64
