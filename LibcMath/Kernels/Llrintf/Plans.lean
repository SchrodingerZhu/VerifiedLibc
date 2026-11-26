import LibcMath.Kernels.Llrintf.Generated.GenericSse2
import LibcMath.Kernels.Llrintf.Generated.Sse42
import LibcMath.Kernels.Llrintf.Generated.Avx2Fma
import LibcMath.Kernels.Llrintf.Generated.AArch64

/-!
# Extracted `llrintf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Llrintf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Llrintf.Generated

end LibcMath.Kernels.Llrintf
