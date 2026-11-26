import LibcMath.Kernels.Acospif.Plans
import LibcMath.Kernels.Acospif.Statement
import LibcMath.Kernels.Acospif.Proof.Sse2
import LibcMath.Kernels.Acospif.Proof.Sse42
import LibcMath.Kernels.Acospif.Proof.Avx2Fma
import LibcMath.Kernels.Acospif.Proof.AArch64
import LibcMath.Kernels.Acospif.Examples

/-!
# `acospif`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `sse2` (open): `Proof.Sse2.acospifSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.acospifSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.acospifAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.acospifAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
