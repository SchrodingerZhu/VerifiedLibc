import LibcMath.Kernels.Roundf.Plans
import LibcMath.Kernels.Roundf.Statement
import LibcMath.Kernels.Roundf.Proof.GenericSse2
import LibcMath.Kernels.Roundf.Proof.Sse42
import LibcMath.Kernels.Roundf.Proof.Avx2Fma
import LibcMath.Kernels.Roundf.Proof.AArch64
import LibcMath.Kernels.Roundf.Examples

/-!
# `roundf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.roundfGenericSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.roundfSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.roundfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.roundfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
