import LibcMath.Kernels.FmaximumMagf.Generated.GenericSse2
import LibcMath.Kernels.FmaximumMagf.Generated.Sse42
import LibcMath.Kernels.FmaximumMagf.Generated.Avx2Fma
import LibcMath.Kernels.FmaximumMagf.Generated.AArch64

/-!
# Extracted `fmaximum_magf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.FmaximumMagf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FmaximumMagf.Generated

/-- All 4 extracted `fmaximum_magf` plans. -/
def allPlans : List (BinaryKernel .binary32) :=
  [ GenericSse2.kernel
  , Sse42.kernel
  , Avx2Fma.kernel
  , AArch64.kernel ]

end LibcMath.Kernels.FmaximumMagf
