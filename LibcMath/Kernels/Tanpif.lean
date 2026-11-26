import LibcMath.Kernels.Tanpif.Plans
import LibcMath.Kernels.Tanpif.Statement
import LibcMath.Kernels.Tanpif.Proof.Sse2
import LibcMath.Kernels.Tanpif.Proof.Sse42
import LibcMath.Kernels.Tanpif.Proof.Avx2Fma
import LibcMath.Kernels.Tanpif.Proof.AArch64
import LibcMath.Kernels.Tanpif.Examples

/-!
# `tanpif`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `sse2` (open): `Proof.Sse2.tanpifSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.tanpifSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.tanpifAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.tanpifAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
