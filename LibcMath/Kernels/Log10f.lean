import LibcMath.Kernels.Log10f.Plans
import LibcMath.Kernels.Log10f.Statement
import LibcMath.Kernels.Log10f.Proof.DoubleEvalSse2
import LibcMath.Kernels.Log10f.Proof.DoubleEvalSse42
import LibcMath.Kernels.Log10f.Proof.DoubleEvalAvx2Fma
import LibcMath.Kernels.Log10f.Proof.DoubleEvalAArch64
import LibcMath.Kernels.Log10f.Examples

/-!
# `log10f`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `double_eval_sse2` (open): `Proof.DoubleEvalSse2.log10fDoubleEvalSse2_correctlyRounded`.
* `double_eval_sse42` (open): `Proof.DoubleEvalSse42.log10fDoubleEvalSse42_correctlyRounded`.
* `double_eval_avx2_fma` (open): `Proof.DoubleEvalAvx2Fma.log10fDoubleEvalAvx2Fma_correctlyRounded`.
* `double_eval_aarch64` (open): `Proof.DoubleEvalAArch64.log10fDoubleEvalAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
