import LibcMath.Kernels.Roundevenf.Plans
import LibcMath.Kernels.Roundevenf.Statement
import LibcMath.Kernels.Roundevenf.Proof.GenericSse2
import LibcMath.Kernels.Roundevenf.Proof.BuiltinSse42
import LibcMath.Kernels.Roundevenf.Proof.Avx2Fma
import LibcMath.Kernels.Roundevenf.Proof.AArch64
import LibcMath.Kernels.Roundevenf.Examples

/-!
# `roundevenf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.roundevenfGenericSse2_correctlyRounded`.
* `builtin_sse42` (open): `Proof.BuiltinSse42.roundevenfBuiltinSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.roundevenfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.roundevenfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
