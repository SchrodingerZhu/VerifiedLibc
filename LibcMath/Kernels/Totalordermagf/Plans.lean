import LibcMath.Kernels.Totalordermagf.Generated.GenericSse2
import LibcMath.Kernels.Totalordermagf.Generated.Sse42
import LibcMath.Kernels.Totalordermagf.Generated.Avx2Fma
import LibcMath.Kernels.Totalordermagf.Generated.AArch64

/-!
# Extracted `totalordermagf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Totalordermagf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Totalordermagf.Generated

end LibcMath.Kernels.Totalordermagf
