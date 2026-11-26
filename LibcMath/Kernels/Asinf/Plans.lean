import LibcMath.Kernels.Asinf.Generated.Sse2
import LibcMath.Kernels.Asinf.Generated.Sse42
import LibcMath.Kernels.Asinf.Generated.Avx2Fma
import LibcMath.Kernels.Asinf.Generated.AArch64

/-!
# Extracted `asinf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `Sse2`: `sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Asinf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Asinf.Generated

/-- All 4 extracted `asinf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ Sse2.kernel
  , Sse42.kernel
  , Avx2Fma.kernel
  , AArch64.kernel ]

end LibcMath.Kernels.Asinf
