import LibcMath.Kernels.Sinpif.Plans
import LibcMath.Kernels.Sinpif.Statement
import LibcMath.Kernels.Sinpif.Proof.Sse2
import LibcMath.Kernels.Sinpif.Proof.Sse42
import LibcMath.Kernels.Sinpif.Proof.Avx2Fma
import LibcMath.Kernels.Sinpif.Proof.AArch64
import LibcMath.Kernels.Sinpif.Examples

/-!
# `sinpif`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `sse2` (open): `Proof.Sse2.sinpifSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.sinpifSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.sinpifAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.sinpifAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
