import LibcMath.Kernels.Totalorderf.Generated.GenericSse2
import LibcMath.Kernels.Totalorderf.Generated.Sse42
import LibcMath.Kernels.Totalorderf.Generated.Avx2Fma
import LibcMath.Kernels.Totalorderf.Generated.AArch64

/-!
# Extracted `totalorderf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Totalorderf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Totalorderf.Generated

end LibcMath.Kernels.Totalorderf
