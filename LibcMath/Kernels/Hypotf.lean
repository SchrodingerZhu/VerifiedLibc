import LibcMath.Kernels.Hypotf.Plans
import LibcMath.Kernels.Hypotf.Statement
import LibcMath.Kernels.Hypotf.Proof.GenericSse2
import LibcMath.Kernels.Hypotf.Proof.Sse42
import LibcMath.Kernels.Hypotf.Proof.Avx2Fma
import LibcMath.Kernels.Hypotf.Proof.AArch64
import LibcMath.Kernels.Hypotf.Examples

/-!
# `hypotf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.hypotfGenericSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.hypotfSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.hypotfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.hypotfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
