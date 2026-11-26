import LibcMath.Kernels.Atanf.Statement

/-!
# `atanf` (`double_eval_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Atanf.Proof.DoubleEvalSse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Atanf.Generated

/-- **Open.** Prove `atanf` (`double_eval_sse2`) is correctly rounded in all four C modes. -/
theorem atanfDoubleEvalSse2_correctlyRounded : AtanfDoubleEvalSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Atanf.Proof.DoubleEvalSse2.atanfDoubleEvalSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms atanfDoubleEvalSse2_correctlyRounded

end LibcMath.Kernels.Atanf.Proof.DoubleEvalSse2
