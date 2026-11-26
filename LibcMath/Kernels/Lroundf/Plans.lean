import LibcMath.Kernels.Lroundf.Generated.GenericSse2
import LibcMath.Kernels.Lroundf.Generated.Sse42
import LibcMath.Kernels.Lroundf.Generated.Avx2Fma
import LibcMath.Kernels.Lroundf.Generated.AArch64

/-!
# Extracted `lroundf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Lroundf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Lroundf.Generated

end LibcMath.Kernels.Lroundf
