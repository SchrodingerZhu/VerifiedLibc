import LibcMath.Kernels.Asinf.Statement

/-!
# `asinf` (`sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Asinf.Proof.Sse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Asinf.Generated

/-- **Open.** Prove `asinf` (`sse2`) is correctly rounded in all four C modes. -/
theorem asinfSse2_correctlyRounded : AsinfSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Asinf.Proof.Sse2.asinfSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms asinfSse2_correctlyRounded

end LibcMath.Kernels.Asinf.Proof.Sse2
