import LibcMath.Kernels.Nextafterf.Plans
import LibcMath.Kernels.Nextafterf.Statement
import LibcMath.Kernels.Nextafterf.Proof.GenericSse2
import LibcMath.Kernels.Nextafterf.Proof.Sse42
import LibcMath.Kernels.Nextafterf.Proof.Avx2Fma
import LibcMath.Kernels.Nextafterf.Proof.AArch64
import LibcMath.Kernels.Nextafterf.Examples

/-!
# `nextafterf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.nextafterfGenericSse2_defined`.
* `sse42` (open): `Proof.Sse42.nextafterfSse42_defined`.
* `avx2_fma` (open): `Proof.Avx2Fma.nextafterfAvx2Fma_defined`.
* `aarch64` (open): `Proof.AArch64.nextafterfAArch64_defined`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
