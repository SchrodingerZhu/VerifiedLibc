import LibcMath.Kernels.Totalorderf.Plans
import LibcMath.Kernels.Totalorderf.Statement
import LibcMath.Kernels.Totalorderf.Proof.GenericSse2
import LibcMath.Kernels.Totalorderf.Proof.Sse42
import LibcMath.Kernels.Totalorderf.Proof.Avx2Fma
import LibcMath.Kernels.Totalorderf.Proof.AArch64
import LibcMath.Kernels.Totalorderf.Examples

/-!
# `totalorderf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.totalorderfGenericSse2_correct`.
* `sse42` (open): `Proof.Sse42.totalorderfSse42_correct`.
* `avx2_fma` (open): `Proof.Avx2Fma.totalorderfAvx2Fma_correct`.
* `aarch64` (open): `Proof.AArch64.totalorderfAArch64_correct`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
