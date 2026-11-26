import LibcMath.Kernels.Logbf.Generated.GenericSse2
import LibcMath.Kernels.Logbf.Generated.Sse42
import LibcMath.Kernels.Logbf.Generated.Avx2Fma
import LibcMath.Kernels.Logbf.Generated.AArch64

/-!
# Extracted `logbf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Logbf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Logbf.Generated

end LibcMath.Kernels.Logbf
