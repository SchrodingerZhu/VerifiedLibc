import LibcMath.Kernels.Fmaxf.Plans
import LibcMath.Kernels.Fmaxf.Statement
import LibcMath.Kernels.Fmaxf.Proof.GenericSse2
import LibcMath.Kernels.Fmaxf.Proof.Sse42
import LibcMath.Kernels.Fmaxf.Proof.Avx2Fma
import LibcMath.Kernels.Fmaxf.Proof.AArch64
import LibcMath.Kernels.Fmaxf.Examples

/-!
# `fmaxf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.fmaxfGenericSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.fmaxfSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.fmaxfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.fmaxfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
