import LibcMath.Kernels.FmaximumMagf.Plans
import LibcMath.Kernels.FmaximumMagf.Statement
import LibcMath.Kernels.FmaximumMagf.Proof.GenericSse2
import LibcMath.Kernels.FmaximumMagf.Proof.Sse42
import LibcMath.Kernels.FmaximumMagf.Proof.Avx2Fma
import LibcMath.Kernels.FmaximumMagf.Proof.AArch64
import LibcMath.Kernels.FmaximumMagf.Examples

/-!
# `fmaximum_magf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.fmaximum_magfGenericSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.fmaximum_magfSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.fmaximum_magfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.fmaximum_magfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
