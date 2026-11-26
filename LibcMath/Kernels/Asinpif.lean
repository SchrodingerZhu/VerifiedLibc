import LibcMath.Kernels.Asinpif.Plans
import LibcMath.Kernels.Asinpif.Statement
import LibcMath.Kernels.Asinpif.Proof.Sse2
import LibcMath.Kernels.Asinpif.Proof.Sse42
import LibcMath.Kernels.Asinpif.Proof.Avx2Fma
import LibcMath.Kernels.Asinpif.Proof.AArch64
import LibcMath.Kernels.Asinpif.Examples

/-!
# `asinpif`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `sse2` (open): `Proof.Sse2.asinpifSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.asinpifSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.asinpifAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.asinpifAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
