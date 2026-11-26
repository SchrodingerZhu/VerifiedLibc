import LibcMath.Kernels.Tanf.Plans
import LibcMath.Kernels.Tanf.Statement
import LibcMath.Kernels.Tanf.Proof.DoubleEvalSse2
import LibcMath.Kernels.Tanf.Proof.DoubleEvalSse42
import LibcMath.Kernels.Tanf.Proof.DoubleEvalAvx2Fma
import LibcMath.Kernels.Tanf.Proof.DoubleEvalAArch64
import LibcMath.Kernels.Tanf.Proof.FloatEval
import LibcMath.Kernels.Tanf.Examples

/-!
# `tanf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `double_eval_sse2` (open): `Proof.DoubleEvalSse2.tanfDoubleEvalSse2_correctlyRounded`.
* `double_eval_sse42` (open): `Proof.DoubleEvalSse42.tanfDoubleEvalSse42_correctlyRounded`.
* `double_eval_avx2_fma` (open): `Proof.DoubleEvalAvx2Fma.tanfDoubleEvalAvx2Fma_correctlyRounded`.
* `double_eval_aarch64` (open): `Proof.DoubleEvalAArch64.tanfDoubleEvalAArch64_correctlyRounded`.
* `float_eval` (open): `Proof.FloatEval.tanfFloatEval_defined`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
