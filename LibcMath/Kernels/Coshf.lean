import LibcMath.Kernels.Coshf.Plans
import LibcMath.Kernels.Coshf.Statement
import LibcMath.Kernels.Coshf.Proof.Sse2
import LibcMath.Kernels.Coshf.Proof.Sse42
import LibcMath.Kernels.Coshf.Proof.Avx2Fma
import LibcMath.Kernels.Coshf.Proof.AArch64
import LibcMath.Kernels.Coshf.Examples

/-!
# `coshf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `sse2` (open): `Proof.Sse2.coshfSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.coshfSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.coshfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.coshfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
