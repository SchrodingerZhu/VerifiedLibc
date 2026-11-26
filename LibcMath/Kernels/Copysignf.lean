import LibcMath.Kernels.Copysignf.Plans
import LibcMath.Kernels.Copysignf.Statement
import LibcMath.Kernels.Copysignf.Proof.GenericSse2
import LibcMath.Kernels.Copysignf.Proof.Sse42
import LibcMath.Kernels.Copysignf.Proof.Avx2Fma
import LibcMath.Kernels.Copysignf.Proof.AArch64
import LibcMath.Kernels.Copysignf.Examples

/-!
# `copysignf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.copysignfGenericSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.copysignfSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.copysignfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.copysignfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
