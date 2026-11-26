import LibcMath.Kernels.Isnanf.Plans
import LibcMath.Kernels.Isnanf.Statement
import LibcMath.Kernels.Isnanf.Proof.GenericSse2
import LibcMath.Kernels.Isnanf.Proof.Sse42
import LibcMath.Kernels.Isnanf.Proof.Avx2Fma
import LibcMath.Kernels.Isnanf.Proof.AArch64
import LibcMath.Kernels.Isnanf.Examples

/-!
# `isnanf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.isnanfGenericSse2_correct`.
* `sse42` (open): `Proof.Sse42.isnanfSse42_correct`.
* `avx2_fma` (open): `Proof.Avx2Fma.isnanfAvx2Fma_correct`.
* `aarch64` (open): `Proof.AArch64.isnanfAArch64_correct`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
