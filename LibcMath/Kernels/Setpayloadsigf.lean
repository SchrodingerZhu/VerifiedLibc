import LibcMath.Kernels.Setpayloadsigf.Plans
import LibcMath.Kernels.Setpayloadsigf.Statement
import LibcMath.Kernels.Setpayloadsigf.Proof.GenericSse2
import LibcMath.Kernels.Setpayloadsigf.Proof.Sse42
import LibcMath.Kernels.Setpayloadsigf.Proof.Avx2Fma
import LibcMath.Kernels.Setpayloadsigf.Proof.AArch64
import LibcMath.Kernels.Setpayloadsigf.Examples

/-!
# `setpayloadsigf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.setpayloadsigfGenericSse2_defined`.
* `sse42` (open): `Proof.Sse42.setpayloadsigfSse42_defined`.
* `avx2_fma` (open): `Proof.Avx2Fma.setpayloadsigfAvx2Fma_defined`.
* `aarch64` (open): `Proof.AArch64.setpayloadsigfAArch64_defined`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
