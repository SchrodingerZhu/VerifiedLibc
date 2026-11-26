import LibcMath.Kernels.FminimumNumf.Plans
import LibcMath.Kernels.FminimumNumf.Statement
import LibcMath.Kernels.FminimumNumf.Proof.GenericSse2
import LibcMath.Kernels.FminimumNumf.Proof.Sse42
import LibcMath.Kernels.FminimumNumf.Proof.Avx2Fma
import LibcMath.Kernels.FminimumNumf.Proof.AArch64
import LibcMath.Kernels.FminimumNumf.Examples

/-!
# `fminimum_numf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.fminimum_numfGenericSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.fminimum_numfSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.fminimum_numfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.fminimum_numfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
