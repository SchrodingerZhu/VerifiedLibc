import LibcMath.Kernels.Fmaf.Plans
import LibcMath.Kernels.Fmaf.Statement
import LibcMath.Kernels.Fmaf.Proof.GenericSse2
import LibcMath.Kernels.Fmaf.Proof.Sse42
import LibcMath.Kernels.Fmaf.Proof.Avx2Fma
import LibcMath.Kernels.Fmaf.Proof.AArch64
import LibcMath.Kernels.Fmaf.Examples

/-!
# `fmaf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.fmafGenericSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.fmafSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.fmafAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.fmafAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
