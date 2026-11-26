import LibcMath.Kernels.Cbrtf.Plans
import LibcMath.Kernels.Cbrtf.Statement
import LibcMath.Kernels.Cbrtf.Proof.Sse2
import LibcMath.Kernels.Cbrtf.Proof.Sse42
import LibcMath.Kernels.Cbrtf.Proof.Avx2Fma
import LibcMath.Kernels.Cbrtf.Proof.AArch64
import LibcMath.Kernels.Cbrtf.Examples

/-!
# `cbrtf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `sse2` (open): `Proof.Sse2.cbrtfSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.cbrtfSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.cbrtfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.cbrtfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
