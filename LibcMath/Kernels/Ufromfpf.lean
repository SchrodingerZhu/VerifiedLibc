import LibcMath.Kernels.Ufromfpf.Plans
import LibcMath.Kernels.Ufromfpf.Statement
import LibcMath.Kernels.Ufromfpf.Proof.GenericSse2
import LibcMath.Kernels.Ufromfpf.Proof.Sse42
import LibcMath.Kernels.Ufromfpf.Proof.Avx2Fma
import LibcMath.Kernels.Ufromfpf.Proof.AArch64
import LibcMath.Kernels.Ufromfpf.Examples

/-!
# `ufromfpf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.ufromfpfGenericSse2_defined`.
* `sse42` (open): `Proof.Sse42.ufromfpfSse42_defined`.
* `avx2_fma` (open): `Proof.Avx2Fma.ufromfpfAvx2Fma_defined`.
* `aarch64` (open): `Proof.AArch64.ufromfpfAArch64_defined`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
