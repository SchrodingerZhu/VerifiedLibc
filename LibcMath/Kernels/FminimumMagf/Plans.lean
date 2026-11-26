import LibcMath.Kernels.FminimumMagf.Generated.GenericSse2
import LibcMath.Kernels.FminimumMagf.Generated.Sse42
import LibcMath.Kernels.FminimumMagf.Generated.Avx2Fma
import LibcMath.Kernels.FminimumMagf.Generated.AArch64

/-!
# Extracted `fminimum_magf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.FminimumMagf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FminimumMagf.Generated

/-- All 4 extracted `fminimum_magf` plans. -/
def allPlans : List (BinaryKernel .binary32) :=
  [ GenericSse2.kernel
  , Sse42.kernel
  , Avx2Fma.kernel
  , AArch64.kernel ]

end LibcMath.Kernels.FminimumMagf
