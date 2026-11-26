import LibcMath.Kernels.Nextdownf.Plans
import LibcMath.Kernels.Nextdownf.Statement
import LibcMath.Kernels.Nextdownf.Proof.GenericSse2
import LibcMath.Kernels.Nextdownf.Proof.Sse42
import LibcMath.Kernels.Nextdownf.Proof.Avx2Fma
import LibcMath.Kernels.Nextdownf.Proof.AArch64
import LibcMath.Kernels.Nextdownf.Examples

/-!
# `nextdownf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.nextdownfGenericSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.nextdownfSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.nextdownfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.nextdownfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
