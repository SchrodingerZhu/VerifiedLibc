import LibcMath.Kernels.Logbf.Plans
import LibcMath.Kernels.Logbf.Statement
import LibcMath.Kernels.Logbf.Proof.GenericSse2
import LibcMath.Kernels.Logbf.Proof.Sse42
import LibcMath.Kernels.Logbf.Proof.Avx2Fma
import LibcMath.Kernels.Logbf.Proof.AArch64
import LibcMath.Kernels.Logbf.Examples

/-!
# `logbf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.logbfGenericSse2_defined`.
* `sse42` (open): `Proof.Sse42.logbfSse42_defined`.
* `avx2_fma` (open): `Proof.Avx2Fma.logbfAvx2Fma_defined`.
* `aarch64` (open): `Proof.AArch64.logbfAArch64_defined`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
