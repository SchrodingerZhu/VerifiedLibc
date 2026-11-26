import LibcMath.Kernels.Cosf.Plans
import LibcMath.Kernels.Cosf.Statement
import LibcMath.Kernels.Cosf.Proof.DoubleEvalSse2
import LibcMath.Kernels.Cosf.Proof.DoubleEvalSse42
import LibcMath.Kernels.Cosf.Proof.DoubleEvalAvx2Fma
import LibcMath.Kernels.Cosf.Proof.DoubleEvalAArch64
import LibcMath.Kernels.Cosf.Proof.FloatEval
import LibcMath.Kernels.Cosf.Examples

/-!
# `cosf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `double_eval_sse2` (open): `Proof.DoubleEvalSse2.cosfDoubleEvalSse2_correctlyRounded`.
* `double_eval_sse42` (open): `Proof.DoubleEvalSse42.cosfDoubleEvalSse42_correctlyRounded`.
* `double_eval_avx2_fma` (open): `Proof.DoubleEvalAvx2Fma.cosfDoubleEvalAvx2Fma_correctlyRounded`.
* `double_eval_aarch64` (open): `Proof.DoubleEvalAArch64.cosfDoubleEvalAArch64_correctlyRounded`.
* `float_eval` (open): `Proof.FloatEval.cosfFloatEval_defined`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
