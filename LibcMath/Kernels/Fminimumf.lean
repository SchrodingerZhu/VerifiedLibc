import LibcMath.Kernels.Fminimumf.Plans
import LibcMath.Kernels.Fminimumf.Statement
import LibcMath.Kernels.Fminimumf.Proof.GenericSse2
import LibcMath.Kernels.Fminimumf.Proof.Sse42
import LibcMath.Kernels.Fminimumf.Proof.Avx2Fma
import LibcMath.Kernels.Fminimumf.Proof.AArch64
import LibcMath.Kernels.Fminimumf.Examples

/-!
# `fminimumf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.fminimumfGenericSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.fminimumfSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.fminimumfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.fminimumfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
