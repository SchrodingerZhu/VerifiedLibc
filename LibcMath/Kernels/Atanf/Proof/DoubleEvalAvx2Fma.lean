import LibcMath.Kernels.Atanf.Statement

/-!
# `atanf` (`double_eval_avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Atanf.Proof.DoubleEvalAvx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Atanf.Generated

/-- **Open.** Prove `atanf` (`double_eval_avx2_fma`) is correctly rounded in all four C modes. -/
theorem atanfDoubleEvalAvx2Fma_correctlyRounded : AtanfDoubleEvalAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Atanf.Proof.DoubleEvalAvx2Fma.atanfDoubleEvalAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms atanfDoubleEvalAvx2Fma_correctlyRounded

end LibcMath.Kernels.Atanf.Proof.DoubleEvalAvx2Fma
