import LibcMath.Kernels.Exp2f.Plans
import LibcMath.Kernels.Exp2f.Statement
import LibcMath.Kernels.Exp2f.Proof.DoubleEvalSse2
import LibcMath.Kernels.Exp2f.Proof.DoubleEvalSse42
import LibcMath.Kernels.Exp2f.Proof.DoubleEvalAvx2Fma
import LibcMath.Kernels.Exp2f.Proof.DoubleEvalAArch64
import LibcMath.Kernels.Exp2f.Proof.FloatEval
import LibcMath.Kernels.Exp2f.Proof.IntegerEval
import LibcMath.Kernels.Exp2f.Proof.StaticRounding
import LibcMath.Kernels.Exp2f.Examples

/-!
# `exp2f`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `double_eval_sse2` (open): `Proof.DoubleEvalSse2.exp2fDoubleEvalSse2_correctlyRounded`.
* `double_eval_sse42` (open): `Proof.DoubleEvalSse42.exp2fDoubleEvalSse42_correctlyRounded`.
* `double_eval_avx2_fma` (open): `Proof.DoubleEvalAvx2Fma.exp2fDoubleEvalAvx2Fma_correctlyRounded`.
* `double_eval_aarch64` (open): `Proof.DoubleEvalAArch64.exp2fDoubleEvalAArch64_correctlyRounded`.
* `float_eval` (open): `Proof.FloatEval.exp2fFloatEval_defined`.
* `integer_eval` (open): `Proof.IntegerEval.exp2fIntegerEval_correctlyRounded`.
* `static_rounding` (open): `Proof.StaticRounding.exp2fStaticRounding_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
