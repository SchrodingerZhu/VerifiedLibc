import LibcMath.Kernels.Cbrtf.Statement

/-!
# `cbrtf` (`sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Cbrtf.Proof.Sse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Cbrtf.Generated

/-- **Open.** Prove `cbrtf` (`sse2`) is correctly rounded in all four C modes. -/
theorem cbrtfSse2_correctlyRounded : CbrtfSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Cbrtf.Proof.Sse2.cbrtfSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms cbrtfSse2_correctlyRounded

end LibcMath.Kernels.Cbrtf.Proof.Sse2
