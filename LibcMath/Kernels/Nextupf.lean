import LibcMath.Kernels.Nextupf.Plans
import LibcMath.Kernels.Nextupf.Statement
import LibcMath.Kernels.Nextupf.Proof.GenericSse2
import LibcMath.Kernels.Nextupf.Proof.Sse42
import LibcMath.Kernels.Nextupf.Proof.Avx2Fma
import LibcMath.Kernels.Nextupf.Proof.AArch64
import LibcMath.Kernels.Nextupf.Examples

/-!
# `nextupf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.nextupfGenericSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.nextupfSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.nextupfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.nextupfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
