import LibcMath.Kernels.Sinf.Plans
import LibcMath.Kernels.Sinf.Statement
import LibcMath.Kernels.Sinf.Proof.DoubleEvalSse2
import LibcMath.Kernels.Sinf.Proof.DoubleEvalSse42
import LibcMath.Kernels.Sinf.Proof.DoubleEvalAvx2Fma
import LibcMath.Kernels.Sinf.Proof.DoubleEvalAArch64
import LibcMath.Kernels.Sinf.Proof.FloatEval
import LibcMath.Kernels.Sinf.Examples

/-!
# `sinf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `double_eval_sse2` (open): `Proof.DoubleEvalSse2.sinfDoubleEvalSse2_correctlyRounded`.
* `double_eval_sse42` (open): `Proof.DoubleEvalSse42.sinfDoubleEvalSse42_correctlyRounded`.
* `double_eval_avx2_fma` (open): `Proof.DoubleEvalAvx2Fma.sinfDoubleEvalAvx2Fma_correctlyRounded`.
* `double_eval_aarch64` (open): `Proof.DoubleEvalAArch64.sinfDoubleEvalAArch64_correctlyRounded`.
* `float_eval` (open): `Proof.FloatEval.sinfFloatEval_defined`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
