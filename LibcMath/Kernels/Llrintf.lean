import LibcMath.Kernels.Llrintf.Plans
import LibcMath.Kernels.Llrintf.Statement
import LibcMath.Kernels.Llrintf.Proof.GenericSse2
import LibcMath.Kernels.Llrintf.Proof.Sse42
import LibcMath.Kernels.Llrintf.Proof.Avx2Fma
import LibcMath.Kernels.Llrintf.Proof.AArch64
import LibcMath.Kernels.Llrintf.Examples

/-!
# `llrintf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.llrintfGenericSse2_defined`.
* `sse42` (open): `Proof.Sse42.llrintfSse42_defined`.
* `avx2_fma` (open): `Proof.Avx2Fma.llrintfAvx2Fma_defined`.
* `aarch64` (open): `Proof.AArch64.llrintfAArch64_defined`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
