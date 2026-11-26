import LibcMath.Kernels.Sqrtf.Generated.X86Sse2
import LibcMath.Kernels.Sqrtf.Generated.Sse42
import LibcMath.Kernels.Sqrtf.Generated.Avx2Fma
import LibcMath.Kernels.Sqrtf.Generated.AArch64
import LibcMath.Kernels.Sqrtf.Generated.GenericSoftFloat

/-!
# Extracted `sqrtf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `X86Sse2`: `x86_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
* `GenericSoftFloat`: `generic_softfloat`.
-/

namespace LibcMath.Kernels.Sqrtf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Sqrtf.Generated

/-- All 5 extracted `sqrtf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ X86Sse2.kernel
  , Sse42.kernel
  , Avx2Fma.kernel
  , AArch64.kernel
  , GenericSoftFloat.kernel ]

end LibcMath.Kernels.Sqrtf
