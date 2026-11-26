import LibcMath.Kernels.Rsqrtf.Plans
import LibcMath.Kernels.Rsqrtf.Statement
import LibcMath.Kernels.Rsqrtf.Proof.Sse2
import LibcMath.Kernels.Rsqrtf.Proof.Sse42
import LibcMath.Kernels.Rsqrtf.Proof.Avx2Fma
import LibcMath.Kernels.Rsqrtf.Proof.AArch64
import LibcMath.Kernels.Rsqrtf.Examples

/-!
# `rsqrtf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `sse2` (open): `Proof.Sse2.rsqrtfSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.rsqrtfSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.rsqrtfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.rsqrtfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
