import LibcMath.Kernels.Fromfpxf.Plans
import LibcMath.Kernels.Fromfpxf.Statement
import LibcMath.Kernels.Fromfpxf.Proof.GenericSse2
import LibcMath.Kernels.Fromfpxf.Proof.Sse42
import LibcMath.Kernels.Fromfpxf.Proof.Avx2Fma
import LibcMath.Kernels.Fromfpxf.Proof.AArch64
import LibcMath.Kernels.Fromfpxf.Examples

/-!
# `fromfpxf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.fromfpxfGenericSse2_defined`.
* `sse42` (open): `Proof.Sse42.fromfpxfSse42_defined`.
* `avx2_fma` (open): `Proof.Avx2Fma.fromfpxfAvx2Fma_defined`.
* `aarch64` (open): `Proof.AArch64.fromfpxfAArch64_defined`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
