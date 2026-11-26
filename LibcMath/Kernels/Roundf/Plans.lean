import LibcMath.Kernels.Roundf.Generated.GenericSse2
import LibcMath.Kernels.Roundf.Generated.Sse42
import LibcMath.Kernels.Roundf.Generated.Avx2Fma
import LibcMath.Kernels.Roundf.Generated.AArch64

/-!
# Extracted `roundf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Roundf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Roundf.Generated

/-- All 4 extracted `roundf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ GenericSse2.kernel
  , Sse42.kernel
  , Avx2Fma.kernel
  , AArch64.kernel ]

end LibcMath.Kernels.Roundf
