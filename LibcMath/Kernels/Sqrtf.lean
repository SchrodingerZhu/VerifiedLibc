import LibcMath.Kernels.Sqrtf.Plans
import LibcMath.Kernels.Sqrtf.Statement
import LibcMath.Kernels.Sqrtf.Proof.X86Sse2
import LibcMath.Kernels.Sqrtf.Proof.Sse42
import LibcMath.Kernels.Sqrtf.Proof.Avx2Fma
import LibcMath.Kernels.Sqrtf.Proof.AArch64
import LibcMath.Kernels.Sqrtf.Proof.GenericSoftFloat
import LibcMath.Kernels.Sqrtf.Examples

/-!
# `sqrtf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `x86_sse2` (open): `Proof.X86Sse2.sqrtfX86Sse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.sqrtfSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.sqrtfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.sqrtfAArch64_correctlyRounded`.
* `generic_softfloat` (open): `Proof.GenericSoftFloat.sqrtfGenericSoftFloat_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
