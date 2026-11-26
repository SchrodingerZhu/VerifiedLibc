import LibcMath.Kernels.FminimumMagNumf.Plans
import LibcMath.Kernels.FminimumMagNumf.Statement
import LibcMath.Kernels.FminimumMagNumf.Proof.GenericSse2
import LibcMath.Kernels.FminimumMagNumf.Proof.Sse42
import LibcMath.Kernels.FminimumMagNumf.Proof.Avx2Fma
import LibcMath.Kernels.FminimumMagNumf.Proof.AArch64
import LibcMath.Kernels.FminimumMagNumf.Examples

/-!
# `fminimum_mag_numf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.fminimum_mag_numfGenericSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.fminimum_mag_numfSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.fminimum_mag_numfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.fminimum_mag_numfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
