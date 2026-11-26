import LibcMath.Kernels.FminimumMagf.Plans
import LibcMath.Kernels.FminimumMagf.Statement
import LibcMath.Kernels.FminimumMagf.Proof.GenericSse2
import LibcMath.Kernels.FminimumMagf.Proof.Sse42
import LibcMath.Kernels.FminimumMagf.Proof.Avx2Fma
import LibcMath.Kernels.FminimumMagf.Proof.AArch64
import LibcMath.Kernels.FminimumMagf.Examples

/-!
# `fminimum_magf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.fminimum_magfGenericSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.fminimum_magfSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.fminimum_magfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.fminimum_magfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
