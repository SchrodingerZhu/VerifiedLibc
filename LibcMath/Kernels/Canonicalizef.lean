import LibcMath.Kernels.Canonicalizef.Plans
import LibcMath.Kernels.Canonicalizef.Statement
import LibcMath.Kernels.Canonicalizef.Proof.GenericSse2
import LibcMath.Kernels.Canonicalizef.Proof.Sse42
import LibcMath.Kernels.Canonicalizef.Proof.Avx2Fma
import LibcMath.Kernels.Canonicalizef.Proof.AArch64
import LibcMath.Kernels.Canonicalizef.Examples

/-!
# `canonicalizef`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.canonicalizefGenericSse2_defined`.
* `sse42` (open): `Proof.Sse42.canonicalizefSse42_defined`.
* `avx2_fma` (open): `Proof.Avx2Fma.canonicalizefAvx2Fma_defined`.
* `aarch64` (open): `Proof.AArch64.canonicalizefAArch64_defined`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
