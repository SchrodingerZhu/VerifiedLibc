import LibcMath.Kernels.Issignalingf.Plans
import LibcMath.Kernels.Issignalingf.Statement
import LibcMath.Kernels.Issignalingf.Proof.GenericSse2
import LibcMath.Kernels.Issignalingf.Proof.Sse42
import LibcMath.Kernels.Issignalingf.Proof.Avx2Fma
import LibcMath.Kernels.Issignalingf.Proof.AArch64
import LibcMath.Kernels.Issignalingf.Examples

/-!
# `issignalingf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.issignalingfGenericSse2_correct`.
* `sse42` (open): `Proof.Sse42.issignalingfSse42_correct`.
* `avx2_fma` (open): `Proof.Avx2Fma.issignalingfAvx2Fma_correct`.
* `aarch64` (open): `Proof.AArch64.issignalingfAArch64_correct`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
