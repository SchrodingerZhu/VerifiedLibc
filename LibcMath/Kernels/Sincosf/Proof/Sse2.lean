import LibcMath.Kernels.Sincosf.Statement

/-!
# `sincosf` (`sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Sincosf.Proof.Sse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Kernels.Sincosf.Generated

/-- **Open.** Prove `sincosf` (`sse2`) is correctly rounded in all four C modes. -/
theorem sincosfSse2_correctlyRounded : SincosfSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Sincosf.Proof.Sse2.sincosfSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sincosfSse2_correctlyRounded

end LibcMath.Kernels.Sincosf.Proof.Sse2
