import LibcMath.Kernels.Cbrtf.Generated.Sse2
import LibcMath.Kernels.Cbrtf.Generated.Sse42
import LibcMath.Kernels.Cbrtf.Generated.Avx2Fma
import LibcMath.Kernels.Cbrtf.Generated.AArch64

/-!
# Extracted `cbrtf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `Sse2`: `sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Cbrtf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Cbrtf.Generated

/-- All 4 extracted `cbrtf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ Sse2.kernel
  , Sse42.kernel
  , Avx2Fma.kernel
  , AArch64.kernel ]

end LibcMath.Kernels.Cbrtf
