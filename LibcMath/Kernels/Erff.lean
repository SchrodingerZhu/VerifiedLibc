import LibcMath.Kernels.Erff.Plans
import LibcMath.Kernels.Erff.Statement
import LibcMath.Kernels.Erff.Proof.Sse2
import LibcMath.Kernels.Erff.Proof.Sse42
import LibcMath.Kernels.Erff.Proof.Avx2Fma
import LibcMath.Kernels.Erff.Proof.AArch64
import LibcMath.Kernels.Erff.Examples

/-!
# `erff`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `sse2` (open): `Proof.Sse2.erffSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.erffSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.erffAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.erffAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
