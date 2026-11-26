import LibcMath.Kernels.Log1pf.Statement

/-!
# `log1pf` (`double_eval_avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Log1pf.Proof.DoubleEvalAvx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Log1pf.Generated

/-- **Open.** Prove `log1pf` (`double_eval_avx2_fma`) is correctly rounded in all four C modes. -/
theorem log1pfDoubleEvalAvx2Fma_correctlyRounded : Log1pfDoubleEvalAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Log1pf.Proof.DoubleEvalAvx2Fma.log1pfDoubleEvalAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms log1pfDoubleEvalAvx2Fma_correctlyRounded

end LibcMath.Kernels.Log1pf.Proof.DoubleEvalAvx2Fma
