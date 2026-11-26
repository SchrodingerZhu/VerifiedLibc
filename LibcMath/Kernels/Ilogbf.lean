import LibcMath.Kernels.Ilogbf.Plans
import LibcMath.Kernels.Ilogbf.Statement
import LibcMath.Kernels.Ilogbf.Proof.GenericSse2
import LibcMath.Kernels.Ilogbf.Proof.Sse42
import LibcMath.Kernels.Ilogbf.Proof.Avx2Fma
import LibcMath.Kernels.Ilogbf.Proof.AArch64
import LibcMath.Kernels.Ilogbf.Examples

/-!
# `ilogbf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.ilogbfGenericSse2_defined`.
* `sse42` (open): `Proof.Sse42.ilogbfSse42_defined`.
* `avx2_fma` (open): `Proof.Avx2Fma.ilogbfAvx2Fma_defined`.
* `aarch64` (open): `Proof.AArch64.ilogbfAArch64_defined`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
