import LibcMath.Kernels.Iscanonicalf.Plans
import LibcMath.Kernels.Iscanonicalf.Statement
import LibcMath.Kernels.Iscanonicalf.Proof.GenericSse2
import LibcMath.Kernels.Iscanonicalf.Proof.Sse42
import LibcMath.Kernels.Iscanonicalf.Proof.Avx2Fma
import LibcMath.Kernels.Iscanonicalf.Proof.AArch64
import LibcMath.Kernels.Iscanonicalf.Examples

/-!
# `iscanonicalf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.iscanonicalfGenericSse2_correct`.
* `sse42` (open): `Proof.Sse42.iscanonicalfSse42_correct`.
* `avx2_fma` (open): `Proof.Avx2Fma.iscanonicalfAvx2Fma_correct`.
* `aarch64` (open): `Proof.AArch64.iscanonicalfAArch64_correct`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
