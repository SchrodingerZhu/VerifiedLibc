import LibcMath.Kernels.Fabsf.Plans
import LibcMath.Kernels.Fabsf.Statement
import LibcMath.Kernels.Fabsf.Proof.GenericSse2
import LibcMath.Kernels.Fabsf.Proof.Sse42
import LibcMath.Kernels.Fabsf.Proof.Avx2Fma
import LibcMath.Kernels.Fabsf.Proof.AArch64
import LibcMath.Kernels.Fabsf.Examples

/-!
# `fabsf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.fabsfGenericSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.fabsfSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.fabsfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.fabsfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
