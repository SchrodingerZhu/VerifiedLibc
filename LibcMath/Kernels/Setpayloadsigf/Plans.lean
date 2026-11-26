import LibcMath.Kernels.Setpayloadsigf.Generated.GenericSse2
import LibcMath.Kernels.Setpayloadsigf.Generated.Sse42
import LibcMath.Kernels.Setpayloadsigf.Generated.Avx2Fma
import LibcMath.Kernels.Setpayloadsigf.Generated.AArch64

/-!
# Extracted `setpayloadsigf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Setpayloadsigf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Setpayloadsigf.Generated

end LibcMath.Kernels.Setpayloadsigf
