import LibcMath.Kernels.Expf.Statement

/-!
# `math::float_eval_cr_rn::expf`: open

**Not complete.** Nothing is proved about this plan.
-/

namespace LibcMath.Kernels.Expf.Proof.FloatEvalCrRn

/-- **Open.** Prove that `math::float_eval_cr_rn::expf` is correctly rounded in round to
nearest. -/
theorem expfFloatEvalCrRn_correctlyRounded : ExpfFloatEvalCrRnCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Expf.Proof.FloatEvalCrRn.expfFloatEvalCrRn_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms expfFloatEvalCrRn_correctlyRounded

end LibcMath.Kernels.Expf.Proof.FloatEvalCrRn
