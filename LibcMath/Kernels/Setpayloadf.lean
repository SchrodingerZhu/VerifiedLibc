import LibcMath.Kernels.Setpayloadf.Plans
import LibcMath.Kernels.Setpayloadf.Statement
import LibcMath.Kernels.Setpayloadf.Proof.GenericSse2
import LibcMath.Kernels.Setpayloadf.Proof.Sse42
import LibcMath.Kernels.Setpayloadf.Proof.Avx2Fma
import LibcMath.Kernels.Setpayloadf.Proof.AArch64
import LibcMath.Kernels.Setpayloadf.Examples

/-!
# `setpayloadf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.setpayloadfGenericSse2_defined`.
* `sse42` (open): `Proof.Sse42.setpayloadfSse42_defined`.
* `avx2_fma` (open): `Proof.Avx2Fma.setpayloadfAvx2Fma_defined`.
* `aarch64` (open): `Proof.AArch64.setpayloadfAArch64_defined`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
