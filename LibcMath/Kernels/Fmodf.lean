import LibcMath.Kernels.Fmodf.Plans
import LibcMath.Kernels.Fmodf.Statement
import LibcMath.Kernels.Fmodf.Proof.GenericSse2
import LibcMath.Kernels.Fmodf.Proof.Sse42
import LibcMath.Kernels.Fmodf.Proof.Avx2Fma
import LibcMath.Kernels.Fmodf.Proof.AArch64
import LibcMath.Kernels.Fmodf.Examples

/-!
# `fmodf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.fmodfGenericSse2_defined`.
* `sse42` (open): `Proof.Sse42.fmodfSse42_defined`.
* `avx2_fma` (open): `Proof.Avx2Fma.fmodfAvx2Fma_defined`.
* `aarch64` (open): `Proof.AArch64.fmodfAArch64_defined`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
