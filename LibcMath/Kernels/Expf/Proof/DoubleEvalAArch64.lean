import LibcMath.Kernels.Expf.Statement

/-!
# `math::double_eval::expf` compiled for AArch64: open

**Not complete.** Nothing is proved about this plan yet.
-/

namespace LibcMath.Kernels.Expf.Proof.DoubleEvalAArch64

/-- **Open.** Prove that `math::double_eval::expf` compiled for AArch64 is correctly rounded across
the four rounding modes of C. -/
theorem expfDoubleEvalAArch64_correctlyRounded : ExpfDoubleEvalAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Expf.Proof.DoubleEvalAArch64.expfDoubleEvalAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms expfDoubleEvalAArch64_correctlyRounded

end LibcMath.Kernels.Expf.Proof.DoubleEvalAArch64
