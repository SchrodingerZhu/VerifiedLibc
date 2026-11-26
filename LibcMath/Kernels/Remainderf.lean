import LibcMath.Kernels.Remainderf.Plans
import LibcMath.Kernels.Remainderf.Statement
import LibcMath.Kernels.Remainderf.Proof.GenericSse2
import LibcMath.Kernels.Remainderf.Proof.Sse42
import LibcMath.Kernels.Remainderf.Proof.Avx2Fma
import LibcMath.Kernels.Remainderf.Proof.AArch64
import LibcMath.Kernels.Remainderf.Examples

/-!
# `remainderf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.remainderfGenericSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.remainderfSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.remainderfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.remainderfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
