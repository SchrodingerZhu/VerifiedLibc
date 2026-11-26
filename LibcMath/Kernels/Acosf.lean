import LibcMath.Kernels.Acosf.Plans
import LibcMath.Kernels.Acosf.Statement
import LibcMath.Kernels.Acosf.Proof.Sse2
import LibcMath.Kernels.Acosf.Proof.Sse42
import LibcMath.Kernels.Acosf.Proof.Avx2Fma
import LibcMath.Kernels.Acosf.Proof.AArch64
import LibcMath.Kernels.Acosf.Examples

/-!
# `acosf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `sse2` (open): `Proof.Sse2.acosfSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.acosfSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.acosfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.acosfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
