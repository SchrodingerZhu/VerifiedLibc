import LibcMath.Kernels.Setpayloadf.Generated.GenericSse2
import LibcMath.Kernels.Setpayloadf.Generated.Sse42
import LibcMath.Kernels.Setpayloadf.Generated.Avx2Fma
import LibcMath.Kernels.Setpayloadf.Generated.AArch64

/-!
# Extracted `setpayloadf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Setpayloadf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Setpayloadf.Generated

end LibcMath.Kernels.Setpayloadf
