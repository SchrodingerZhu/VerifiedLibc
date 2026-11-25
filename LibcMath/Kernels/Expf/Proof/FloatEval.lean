import LibcMath.Kernels.Expf.Statement

/-!
# `math::float_eval::expf`: open

**Not complete.** This plan is the fast single-precision plan. It is not correctly rounded, so
the statement is that it reaches no operation that C++ leaves undefined.
-/

namespace LibcMath.Kernels.Expf.Proof.FloatEval

/-- **Open.** Prove that `math::float_eval::expf` reaches no operation that C++ leaves undefined
in round to nearest. -/
theorem expfFloatEval_defined : ExpfFloatEvalDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Expf.Proof.FloatEval.expfFloatEval_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms expfFloatEval_defined

end LibcMath.Kernels.Expf.Proof.FloatEval
