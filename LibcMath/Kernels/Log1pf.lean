import LibcMath.Kernels.Log1pf.Plans
import LibcMath.Kernels.Log1pf.Statement
import LibcMath.Kernels.Log1pf.Proof.DoubleEvalSse2
import LibcMath.Kernels.Log1pf.Proof.DoubleEvalSse42
import LibcMath.Kernels.Log1pf.Proof.DoubleEvalAvx2Fma
import LibcMath.Kernels.Log1pf.Proof.DoubleEvalAArch64
import LibcMath.Kernels.Log1pf.Examples

/-!
# `log1pf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `double_eval_sse2` (open): `Proof.DoubleEvalSse2.log1pfDoubleEvalSse2_correctlyRounded`.
* `double_eval_sse42` (open): `Proof.DoubleEvalSse42.log1pfDoubleEvalSse42_correctlyRounded`.
* `double_eval_avx2_fma` (open): `Proof.DoubleEvalAvx2Fma.log1pfDoubleEvalAvx2Fma_correctlyRounded`.
* `double_eval_aarch64` (open): `Proof.DoubleEvalAArch64.log1pfDoubleEvalAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
