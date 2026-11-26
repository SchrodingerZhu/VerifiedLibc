import LibcMath.Kernels.Lroundf.Plans
import LibcMath.Kernels.Lroundf.Statement
import LibcMath.Kernels.Lroundf.Proof.GenericSse2
import LibcMath.Kernels.Lroundf.Proof.Sse42
import LibcMath.Kernels.Lroundf.Proof.Avx2Fma
import LibcMath.Kernels.Lroundf.Proof.AArch64
import LibcMath.Kernels.Lroundf.Examples

/-!
# `lroundf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.lroundfGenericSse2_defined`.
* `sse42` (open): `Proof.Sse42.lroundfSse42_defined`.
* `avx2_fma` (open): `Proof.Avx2Fma.lroundfAvx2Fma_defined`.
* `aarch64` (open): `Proof.AArch64.lroundfAArch64_defined`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
