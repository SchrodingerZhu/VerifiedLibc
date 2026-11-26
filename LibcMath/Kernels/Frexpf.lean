import LibcMath.Kernels.Frexpf.Plans
import LibcMath.Kernels.Frexpf.Statement
import LibcMath.Kernels.Frexpf.Proof.GenericSse2
import LibcMath.Kernels.Frexpf.Proof.Sse42
import LibcMath.Kernels.Frexpf.Proof.Avx2Fma
import LibcMath.Kernels.Frexpf.Proof.AArch64
import LibcMath.Kernels.Frexpf.Examples

/-!
# `frexpf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.frexpfGenericSse2_defined`.
* `sse42` (open): `Proof.Sse42.frexpfSse42_defined`.
* `avx2_fma` (open): `Proof.Avx2Fma.frexpfAvx2Fma_defined`.
* `aarch64` (open): `Proof.AArch64.frexpfAArch64_defined`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
