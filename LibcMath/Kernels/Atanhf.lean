import LibcMath.Kernels.Atanhf.Plans
import LibcMath.Kernels.Atanhf.Statement
import LibcMath.Kernels.Atanhf.Proof.Sse2
import LibcMath.Kernels.Atanhf.Proof.Sse42
import LibcMath.Kernels.Atanhf.Proof.Avx2Fma
import LibcMath.Kernels.Atanhf.Proof.AArch64
import LibcMath.Kernels.Atanhf.Examples

/-!
# `atanhf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `sse2` (open): `Proof.Sse2.atanhfSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.atanhfSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.atanhfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.atanhfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
