import LibcMath.Kernels.Totalordermagf.Plans
import LibcMath.Kernels.Totalordermagf.Statement
import LibcMath.Kernels.Totalordermagf.Proof.GenericSse2
import LibcMath.Kernels.Totalordermagf.Proof.Sse42
import LibcMath.Kernels.Totalordermagf.Proof.Avx2Fma
import LibcMath.Kernels.Totalordermagf.Proof.AArch64
import LibcMath.Kernels.Totalordermagf.Examples

/-!
# `totalordermagf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.totalordermagfGenericSse2_correct`.
* `sse42` (open): `Proof.Sse42.totalordermagfSse42_correct`.
* `avx2_fma` (open): `Proof.Avx2Fma.totalordermagfAvx2Fma_correct`.
* `aarch64` (open): `Proof.AArch64.totalordermagfAArch64_correct`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
