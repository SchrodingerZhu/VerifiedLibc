import LibcMath.Kernels.Log10f.Statement

/-!
# `log10f` (`double_eval_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Log10f.Proof.DoubleEvalSse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Log10f.Generated

/-- **Open.** Prove `log10f` (`double_eval_sse2`) is correctly rounded in all four C modes. -/
theorem log10fDoubleEvalSse2_correctlyRounded : Log10fDoubleEvalSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Log10f.Proof.DoubleEvalSse2.log10fDoubleEvalSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms log10fDoubleEvalSse2_correctlyRounded

end LibcMath.Kernels.Log10f.Proof.DoubleEvalSse2
