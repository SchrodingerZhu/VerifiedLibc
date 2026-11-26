import LibcMath.Kernels.Atan2f.Statement

/-!
# `atan2f` (`double_eval_avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Atan2f.Proof.DoubleEvalAvx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Atan2f.Generated

/-- **Open.** Prove `atan2f` (`double_eval_avx2_fma`) is correctly rounded in all four C modes. -/
theorem atan2fDoubleEvalAvx2Fma_correctlyRounded : Atan2fDoubleEvalAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Atan2f.Proof.DoubleEvalAvx2Fma.atan2fDoubleEvalAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms atan2fDoubleEvalAvx2Fma_correctlyRounded

end LibcMath.Kernels.Atan2f.Proof.DoubleEvalAvx2Fma
