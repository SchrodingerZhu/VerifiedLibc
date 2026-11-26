import LibcMath.Kernels.FmaximumMagNumf.Plans
import LibcMath.Kernels.FmaximumMagNumf.Statement
import LibcMath.Kernels.FmaximumMagNumf.Proof.GenericSse2
import LibcMath.Kernels.FmaximumMagNumf.Proof.Sse42
import LibcMath.Kernels.FmaximumMagNumf.Proof.Avx2Fma
import LibcMath.Kernels.FmaximumMagNumf.Proof.AArch64
import LibcMath.Kernels.FmaximumMagNumf.Examples

/-!
# `fmaximum_mag_numf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.fmaximum_mag_numfGenericSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.fmaximum_mag_numfSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.fmaximum_mag_numfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.fmaximum_mag_numfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
