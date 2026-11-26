import LibcMath.Kernels.Llroundf.Plans
import LibcMath.Kernels.Llroundf.Statement
import LibcMath.Kernels.Llroundf.Proof.GenericSse2
import LibcMath.Kernels.Llroundf.Proof.Sse42
import LibcMath.Kernels.Llroundf.Proof.Avx2Fma
import LibcMath.Kernels.Llroundf.Proof.AArch64
import LibcMath.Kernels.Llroundf.Examples

/-!
# `llroundf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.llroundfGenericSse2_defined`.
* `sse42` (open): `Proof.Sse42.llroundfSse42_defined`.
* `avx2_fma` (open): `Proof.Avx2Fma.llroundfAvx2Fma_defined`.
* `aarch64` (open): `Proof.AArch64.llroundfAArch64_defined`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
