import LibcMath.Kernels.Ufromfpxf.Plans
import LibcMath.Kernels.Ufromfpxf.Statement
import LibcMath.Kernels.Ufromfpxf.Proof.GenericSse2
import LibcMath.Kernels.Ufromfpxf.Proof.Sse42
import LibcMath.Kernels.Ufromfpxf.Proof.Avx2Fma
import LibcMath.Kernels.Ufromfpxf.Proof.AArch64
import LibcMath.Kernels.Ufromfpxf.Examples

/-!
# `ufromfpxf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.ufromfpxfGenericSse2_defined`.
* `sse42` (open): `Proof.Sse42.ufromfpxfSse42_defined`.
* `avx2_fma` (open): `Proof.Avx2Fma.ufromfpxfAvx2Fma_defined`.
* `aarch64` (open): `Proof.AArch64.ufromfpxfAArch64_defined`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
