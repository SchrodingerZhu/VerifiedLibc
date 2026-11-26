import LibcMath.Kernels.Acoshf.Plans
import LibcMath.Kernels.Acoshf.Statement
import LibcMath.Kernels.Acoshf.Proof.Sse2
import LibcMath.Kernels.Acoshf.Proof.Sse42
import LibcMath.Kernels.Acoshf.Proof.Avx2Fma
import LibcMath.Kernels.Acoshf.Proof.AArch64
import LibcMath.Kernels.Acoshf.Examples

/-!
# `acoshf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `sse2` (open): `Proof.Sse2.acoshfSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.acoshfSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.acoshfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.acoshfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
