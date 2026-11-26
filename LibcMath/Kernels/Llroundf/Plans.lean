import LibcMath.Kernels.Llroundf.Generated.GenericSse2
import LibcMath.Kernels.Llroundf.Generated.Sse42
import LibcMath.Kernels.Llroundf.Generated.Avx2Fma
import LibcMath.Kernels.Llroundf.Generated.AArch64

/-!
# Extracted `llroundf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Llroundf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Llroundf.Generated

end LibcMath.Kernels.Llroundf
