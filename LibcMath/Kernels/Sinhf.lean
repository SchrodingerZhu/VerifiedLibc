import LibcMath.Kernels.Sinhf.Plans
import LibcMath.Kernels.Sinhf.Statement
import LibcMath.Kernels.Sinhf.Proof.Sse2
import LibcMath.Kernels.Sinhf.Proof.Sse42
import LibcMath.Kernels.Sinhf.Proof.Avx2Fma
import LibcMath.Kernels.Sinhf.Proof.AArch64
import LibcMath.Kernels.Sinhf.Examples

/-!
# `sinhf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `sse2` (open): `Proof.Sse2.sinhfSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.sinhfSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.sinhfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.sinhfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
