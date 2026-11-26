import LibcMath.Kernels.Log10f.Statement

/-!
# `log10f` (`double_eval_avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Log10f.Proof.DoubleEvalAvx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Log10f.Generated

/-- **Open.** Prove `log10f` (`double_eval_avx2_fma`) is correctly rounded in all four C modes. -/
theorem log10fDoubleEvalAvx2Fma_correctlyRounded : Log10fDoubleEvalAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Log10f.Proof.DoubleEvalAvx2Fma.log10fDoubleEvalAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms log10fDoubleEvalAvx2Fma_correctlyRounded

end LibcMath.Kernels.Log10f.Proof.DoubleEvalAvx2Fma
