import LibcMath.Kernels.Atanhf.Statement

/-!
# `atanhf` (`sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Atanhf.Proof.Sse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Atanhf.Generated

/-- **Open.** Prove `atanhf` (`sse2`) is correctly rounded in all four C modes. -/
theorem atanhfSse2_correctlyRounded : AtanhfSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Atanhf.Proof.Sse2.atanhfSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms atanhfSse2_correctlyRounded

end LibcMath.Kernels.Atanhf.Proof.Sse2
