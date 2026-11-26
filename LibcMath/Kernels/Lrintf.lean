import LibcMath.Kernels.Lrintf.Plans
import LibcMath.Kernels.Lrintf.Statement
import LibcMath.Kernels.Lrintf.Proof.GenericSse2
import LibcMath.Kernels.Lrintf.Proof.Sse42
import LibcMath.Kernels.Lrintf.Proof.Avx2Fma
import LibcMath.Kernels.Lrintf.Proof.AArch64
import LibcMath.Kernels.Lrintf.Examples

/-!
# `lrintf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.lrintfGenericSse2_defined`.
* `sse42` (open): `Proof.Sse42.lrintfSse42_defined`.
* `avx2_fma` (open): `Proof.Avx2Fma.lrintfAvx2Fma_defined`.
* `aarch64` (open): `Proof.AArch64.lrintfAArch64_defined`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
