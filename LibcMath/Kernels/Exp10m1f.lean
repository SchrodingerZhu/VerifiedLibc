import LibcMath.Kernels.Exp10m1f.Plans
import LibcMath.Kernels.Exp10m1f.Statement
import LibcMath.Kernels.Exp10m1f.Proof.Sse2
import LibcMath.Kernels.Exp10m1f.Proof.Sse42
import LibcMath.Kernels.Exp10m1f.Proof.Avx2Fma
import LibcMath.Kernels.Exp10m1f.Proof.AArch64
import LibcMath.Kernels.Exp10m1f.Examples

/-!
# `exp10m1f`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `sse2` (open): `Proof.Sse2.exp10m1fSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.exp10m1fSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.exp10m1fAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.exp10m1fAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
