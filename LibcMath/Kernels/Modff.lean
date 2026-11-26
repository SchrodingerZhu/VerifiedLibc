import LibcMath.Kernels.Modff.Plans
import LibcMath.Kernels.Modff.Statement
import LibcMath.Kernels.Modff.Proof.GenericSse2
import LibcMath.Kernels.Modff.Proof.Sse42
import LibcMath.Kernels.Modff.Proof.Avx2Fma
import LibcMath.Kernels.Modff.Proof.AArch64
import LibcMath.Kernels.Modff.Examples

/-!
# `modff`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.modffGenericSse2_defined`.
* `sse42` (open): `Proof.Sse42.modffSse42_defined`.
* `avx2_fma` (open): `Proof.Avx2Fma.modffAvx2Fma_defined`.
* `aarch64` (open): `Proof.AArch64.modffAArch64_defined`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
