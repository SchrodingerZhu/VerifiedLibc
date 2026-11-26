import LibcMath.Kernels.Truncf.Plans
import LibcMath.Kernels.Truncf.Statement
import LibcMath.Kernels.Truncf.Proof.GenericSse2
import LibcMath.Kernels.Truncf.Proof.BuiltinSse42
import LibcMath.Kernels.Truncf.Proof.Avx2Fma
import LibcMath.Kernels.Truncf.Proof.AArch64
import LibcMath.Kernels.Truncf.Examples

/-!
# `truncf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.truncfGenericSse2_correctlyRounded`.
* `builtin_sse42` (open): `Proof.BuiltinSse42.truncfBuiltinSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.truncfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.truncfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
