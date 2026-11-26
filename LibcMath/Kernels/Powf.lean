import LibcMath.Kernels.Powf.Plans
import LibcMath.Kernels.Powf.Statement
import LibcMath.Kernels.Powf.Proof.DoubleEvalSse2
import LibcMath.Kernels.Powf.Proof.DoubleEvalSse42
import LibcMath.Kernels.Powf.Proof.DoubleEvalAvx2Fma
import LibcMath.Kernels.Powf.Proof.DoubleEvalAArch64
import LibcMath.Kernels.Powf.Proof.FloatEval
import LibcMath.Kernels.Powf.Examples

/-!
# `powf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `double_eval_sse2` (open): `Proof.DoubleEvalSse2.powfDoubleEvalSse2_correctlyRounded`.
* `double_eval_sse42` (open): `Proof.DoubleEvalSse42.powfDoubleEvalSse42_correctlyRounded`.
* `double_eval_avx2_fma` (open): `Proof.DoubleEvalAvx2Fma.powfDoubleEvalAvx2Fma_correctlyRounded`.
* `double_eval_aarch64` (open): `Proof.DoubleEvalAArch64.powfDoubleEvalAArch64_correctlyRounded`.
* `float_eval` (open): `Proof.FloatEval.powfFloatEval_defined`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
