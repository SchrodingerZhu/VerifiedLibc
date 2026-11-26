import LibcMath.Kernels.Floorf.Plans
import LibcMath.Kernels.Floorf.Statement
import LibcMath.Kernels.Floorf.Proof.GenericSse2
import LibcMath.Kernels.Floorf.Proof.BuiltinSse42
import LibcMath.Kernels.Floorf.Proof.Avx2Fma
import LibcMath.Kernels.Floorf.Proof.AArch64
import LibcMath.Kernels.Floorf.Examples

/-!
# `floorf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.floorfGenericSse2_correctlyRounded`.
* `builtin_sse42` (open): `Proof.BuiltinSse42.floorfBuiltinSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.floorfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.floorfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
