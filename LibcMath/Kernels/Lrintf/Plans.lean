import LibcMath.Kernels.Lrintf.Generated.GenericSse2
import LibcMath.Kernels.Lrintf.Generated.Sse42
import LibcMath.Kernels.Lrintf.Generated.Avx2Fma
import LibcMath.Kernels.Lrintf.Generated.AArch64

/-!
# Extracted `lrintf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Lrintf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Lrintf.Generated

end LibcMath.Kernels.Lrintf
