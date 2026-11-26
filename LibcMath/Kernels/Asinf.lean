import LibcMath.Kernels.Asinf.Plans
import LibcMath.Kernels.Asinf.Statement
import LibcMath.Kernels.Asinf.Proof.Sse2
import LibcMath.Kernels.Asinf.Proof.Sse42
import LibcMath.Kernels.Asinf.Proof.Avx2Fma
import LibcMath.Kernels.Asinf.Proof.AArch64
import LibcMath.Kernels.Asinf.Examples

/-!
# `asinf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `sse2` (open): `Proof.Sse2.asinfSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.asinfSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.asinfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.asinfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
