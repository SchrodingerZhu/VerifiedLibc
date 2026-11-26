import LibcMath.Kernels.Fminf.Plans
import LibcMath.Kernels.Fminf.Statement
import LibcMath.Kernels.Fminf.Proof.GenericSse2
import LibcMath.Kernels.Fminf.Proof.Sse42
import LibcMath.Kernels.Fminf.Proof.Avx2Fma
import LibcMath.Kernels.Fminf.Proof.AArch64
import LibcMath.Kernels.Fminf.Examples

/-!
# `fminf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.fminfGenericSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.fminfSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.fminfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.fminfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
