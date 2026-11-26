import LibcMath.Kernels.Fromfpf.Plans
import LibcMath.Kernels.Fromfpf.Statement
import LibcMath.Kernels.Fromfpf.Proof.GenericSse2
import LibcMath.Kernels.Fromfpf.Proof.Sse42
import LibcMath.Kernels.Fromfpf.Proof.Avx2Fma
import LibcMath.Kernels.Fromfpf.Proof.AArch64
import LibcMath.Kernels.Fromfpf.Examples

/-!
# `fromfpf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.fromfpfGenericSse2_defined`.
* `sse42` (open): `Proof.Sse42.fromfpfSse42_defined`.
* `avx2_fma` (open): `Proof.Avx2Fma.fromfpfAvx2Fma_defined`.
* `aarch64` (open): `Proof.AArch64.fromfpfAArch64_defined`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
