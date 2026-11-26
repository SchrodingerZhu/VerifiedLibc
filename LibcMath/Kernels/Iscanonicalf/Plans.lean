import LibcMath.Kernels.Iscanonicalf.Generated.GenericSse2
import LibcMath.Kernels.Iscanonicalf.Generated.Sse42
import LibcMath.Kernels.Iscanonicalf.Generated.Avx2Fma
import LibcMath.Kernels.Iscanonicalf.Generated.AArch64

/-!
# Extracted `iscanonicalf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Iscanonicalf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Iscanonicalf.Generated

end LibcMath.Kernels.Iscanonicalf
