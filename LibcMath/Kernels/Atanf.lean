import LibcMath.Kernels.Atanf.Plans
import LibcMath.Kernels.Atanf.Statement
import LibcMath.Kernels.Atanf.Proof.DoubleEvalSse2
import LibcMath.Kernels.Atanf.Proof.DoubleEvalSse42
import LibcMath.Kernels.Atanf.Proof.DoubleEvalAvx2Fma
import LibcMath.Kernels.Atanf.Proof.DoubleEvalAArch64
import LibcMath.Kernels.Atanf.Proof.FloatEval
import LibcMath.Kernels.Atanf.Examples

/-!
# `atanf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `double_eval_sse2` (open): `Proof.DoubleEvalSse2.atanfDoubleEvalSse2_correctlyRounded`.
* `double_eval_sse42` (open): `Proof.DoubleEvalSse42.atanfDoubleEvalSse42_correctlyRounded`.
* `double_eval_avx2_fma` (open): `Proof.DoubleEvalAvx2Fma.atanfDoubleEvalAvx2Fma_correctlyRounded`.
* `double_eval_aarch64` (open): `Proof.DoubleEvalAArch64.atanfDoubleEvalAArch64_correctlyRounded`.
* `float_eval` (open): `Proof.FloatEval.atanfFloatEval_defined`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
