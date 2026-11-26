import LibcMath.Kernels.Logf.Statement

/-!
# `logf` (`double_eval_avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Logf.Proof.DoubleEvalAvx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Logf.Generated

/-- **Open.** Prove `logf` (`double_eval_avx2_fma`) is correctly rounded in all four C modes. -/
theorem logfDoubleEvalAvx2Fma_correctlyRounded : LogfDoubleEvalAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Logf.Proof.DoubleEvalAvx2Fma.logfDoubleEvalAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms logfDoubleEvalAvx2Fma_correctlyRounded

end LibcMath.Kernels.Logf.Proof.DoubleEvalAvx2Fma
