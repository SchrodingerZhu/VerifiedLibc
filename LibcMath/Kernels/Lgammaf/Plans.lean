import LibcMath.Kernels.Lgammaf.Generated.Sse2
import LibcMath.Kernels.Lgammaf.Generated.Sse42
import LibcMath.Kernels.Lgammaf.Generated.Avx2Fma
import LibcMath.Kernels.Lgammaf.Generated.AArch64

/-!
# Extracted `lgammaf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `Sse2`: `sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Lgammaf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Lgammaf.Generated

/-- All 4 extracted `lgammaf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ Sse2.kernel
  , Sse42.kernel
  , Avx2Fma.kernel
  , AArch64.kernel ]

end LibcMath.Kernels.Lgammaf
