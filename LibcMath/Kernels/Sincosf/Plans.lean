import LibcMath.Kernels.Sincosf.Generated.Sse2
import LibcMath.Kernels.Sincosf.Generated.Sse42
import LibcMath.Kernels.Sincosf.Generated.Avx2Fma
import LibcMath.Kernels.Sincosf.Generated.AArch64

/-!
# Extracted `sincosf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `Sse2`: `sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Sincosf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Sincosf.Generated

end LibcMath.Kernels.Sincosf
