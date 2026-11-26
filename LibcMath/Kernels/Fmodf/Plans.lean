import LibcMath.Kernels.Fmodf.Generated.GenericSse2
import LibcMath.Kernels.Fmodf.Generated.Sse42
import LibcMath.Kernels.Fmodf.Generated.Avx2Fma
import LibcMath.Kernels.Fmodf.Generated.AArch64

/-!
# Extracted `fmodf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Fmodf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fmodf.Generated

end LibcMath.Kernels.Fmodf
