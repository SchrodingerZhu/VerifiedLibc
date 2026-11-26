import LibcMath.Kernels.Getpayloadf.Plans
import LibcMath.Kernels.Getpayloadf.Statement
import LibcMath.Kernels.Getpayloadf.Proof.GenericSse2
import LibcMath.Kernels.Getpayloadf.Proof.Sse42
import LibcMath.Kernels.Getpayloadf.Proof.Avx2Fma
import LibcMath.Kernels.Getpayloadf.Proof.AArch64
import LibcMath.Kernels.Getpayloadf.Examples

/-!
# `getpayloadf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.getpayloadfGenericSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.getpayloadfSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.getpayloadfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.getpayloadfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
