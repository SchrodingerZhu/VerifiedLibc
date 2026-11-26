import LibcMath.Kernels.Fdimf.Plans
import LibcMath.Kernels.Fdimf.Statement
import LibcMath.Kernels.Fdimf.Proof.GenericSse2
import LibcMath.Kernels.Fdimf.Proof.Sse42
import LibcMath.Kernels.Fdimf.Proof.Avx2Fma
import LibcMath.Kernels.Fdimf.Proof.AArch64
import LibcMath.Kernels.Fdimf.Examples

/-!
# `fdimf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.fdimfGenericSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.fdimfSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.fdimfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.fdimfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
