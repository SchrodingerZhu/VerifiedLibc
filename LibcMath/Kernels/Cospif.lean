import LibcMath.Kernels.Cospif.Plans
import LibcMath.Kernels.Cospif.Statement
import LibcMath.Kernels.Cospif.Proof.Sse2
import LibcMath.Kernels.Cospif.Proof.Sse42
import LibcMath.Kernels.Cospif.Proof.Avx2Fma
import LibcMath.Kernels.Cospif.Proof.AArch64
import LibcMath.Kernels.Cospif.Examples

/-!
# `cospif`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `sse2` (open): `Proof.Sse2.cospifSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.cospifSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.cospifAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.cospifAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
