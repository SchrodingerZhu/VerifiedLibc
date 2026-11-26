import LibcMath.Kernels.Fmaximumf.Plans
import LibcMath.Kernels.Fmaximumf.Statement
import LibcMath.Kernels.Fmaximumf.Proof.GenericSse2
import LibcMath.Kernels.Fmaximumf.Proof.Sse42
import LibcMath.Kernels.Fmaximumf.Proof.Avx2Fma
import LibcMath.Kernels.Fmaximumf.Proof.AArch64
import LibcMath.Kernels.Fmaximumf.Examples

/-!
# `fmaximumf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.fmaximumfGenericSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.fmaximumfSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.fmaximumfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.fmaximumfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
