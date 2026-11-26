import LibcMath.Kernels.Ldexpf.Plans
import LibcMath.Kernels.Ldexpf.Statement
import LibcMath.Kernels.Ldexpf.Proof.GenericSse2
import LibcMath.Kernels.Ldexpf.Proof.Sse42
import LibcMath.Kernels.Ldexpf.Proof.Avx2Fma
import LibcMath.Kernels.Ldexpf.Proof.AArch64
import LibcMath.Kernels.Ldexpf.Examples

/-!
# `ldexpf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.ldexpfGenericSse2_defined`.
* `sse42` (open): `Proof.Sse42.ldexpfSse42_defined`.
* `avx2_fma` (open): `Proof.Avx2Fma.ldexpfAvx2Fma_defined`.
* `aarch64` (open): `Proof.AArch64.ldexpfAArch64_defined`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
