import LibcMath.Kernels.Rintf.Plans
import LibcMath.Kernels.Rintf.Statement
import LibcMath.Kernels.Rintf.Proof.GenericSse2
import LibcMath.Kernels.Rintf.Proof.BuiltinSse42
import LibcMath.Kernels.Rintf.Proof.Avx2Fma
import LibcMath.Kernels.Rintf.Proof.AArch64
import LibcMath.Kernels.Rintf.Examples

/-!
# `rintf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.rintfGenericSse2_correctlyRounded`.
* `builtin_sse42` (open): `Proof.BuiltinSse42.rintfBuiltinSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.rintfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.rintfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
