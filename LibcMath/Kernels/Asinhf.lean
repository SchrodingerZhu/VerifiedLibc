import LibcMath.Kernels.Asinhf.Plans
import LibcMath.Kernels.Asinhf.Statement
import LibcMath.Kernels.Asinhf.Proof.Sse2
import LibcMath.Kernels.Asinhf.Proof.Sse42
import LibcMath.Kernels.Asinhf.Proof.Avx2Fma
import LibcMath.Kernels.Asinhf.Proof.AArch64
import LibcMath.Kernels.Asinhf.Examples

/-!
# `asinhf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `sse2` (open): `Proof.Sse2.asinhfSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.asinhfSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.asinhfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.asinhfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
