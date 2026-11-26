import LibcMath.Kernels.Expf.Statement

/-!
# `math::double_eval::expf` compiled with `-msse4.2 -mno-fma`: open

**Not complete.** Nothing is proved about this plan yet.
-/

namespace LibcMath.Kernels.Expf.Proof.DoubleEvalSse42

/-- **Open.** Prove that `math::double_eval::expf` compiled with `-msse4.2 -mno-fma` is correctly
rounded across the four rounding modes of C. -/
theorem expfDoubleEvalSse42_correctlyRounded : ExpfDoubleEvalSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Expf.Proof.DoubleEvalSse42.expfDoubleEvalSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms expfDoubleEvalSse42_correctlyRounded

end LibcMath.Kernels.Expf.Proof.DoubleEvalSse42
