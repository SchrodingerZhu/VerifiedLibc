import LibcMath.Kernels.Acosf.Statement

/-!
# `acosf` (`sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Acosf.Proof.Sse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Acosf.Generated

/-- **Open.** Prove `acosf` (`sse2`) is correctly rounded in all four C modes. -/
theorem acosfSse2_correctlyRounded : AcosfSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Acosf.Proof.Sse2.acosfSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms acosfSse2_correctlyRounded

end LibcMath.Kernels.Acosf.Proof.Sse2
