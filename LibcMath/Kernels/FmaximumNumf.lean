import LibcMath.Kernels.FmaximumNumf.Plans
import LibcMath.Kernels.FmaximumNumf.Statement
import LibcMath.Kernels.FmaximumNumf.Proof.GenericSse2
import LibcMath.Kernels.FmaximumNumf.Proof.Sse42
import LibcMath.Kernels.FmaximumNumf.Proof.Avx2Fma
import LibcMath.Kernels.FmaximumNumf.Proof.AArch64
import LibcMath.Kernels.FmaximumNumf.Examples

/-!
# `fmaximum_numf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.fmaximum_numfGenericSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.fmaximum_numfSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.fmaximum_numfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.fmaximum_numfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
