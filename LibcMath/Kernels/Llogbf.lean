import LibcMath.Kernels.Llogbf.Plans
import LibcMath.Kernels.Llogbf.Statement
import LibcMath.Kernels.Llogbf.Proof.GenericSse2
import LibcMath.Kernels.Llogbf.Proof.Sse42
import LibcMath.Kernels.Llogbf.Proof.Avx2Fma
import LibcMath.Kernels.Llogbf.Proof.AArch64
import LibcMath.Kernels.Llogbf.Examples

/-!
# `llogbf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.llogbfGenericSse2_defined`.
* `sse42` (open): `Proof.Sse42.llogbfSse42_defined`.
* `avx2_fma` (open): `Proof.Avx2Fma.llogbfAvx2Fma_defined`.
* `aarch64` (open): `Proof.AArch64.llogbfAArch64_defined`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
