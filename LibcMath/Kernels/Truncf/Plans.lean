import LibcMath.Kernels.Truncf.Generated.GenericSse2
import LibcMath.Kernels.Truncf.Generated.BuiltinSse42
import LibcMath.Kernels.Truncf.Generated.Avx2Fma
import LibcMath.Kernels.Truncf.Generated.AArch64

/-!
# Extracted `truncf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `BuiltinSse42`: `builtin_sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Truncf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Truncf.Generated

/-- All 4 extracted `truncf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ GenericSse2.kernel
  , BuiltinSse42.kernel
  , Avx2Fma.kernel
  , AArch64.kernel ]

end LibcMath.Kernels.Truncf
