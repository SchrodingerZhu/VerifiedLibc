import LibcMath.Kernels.Getpayloadf.Generated.GenericSse2
import LibcMath.Kernels.Getpayloadf.Generated.Sse42
import LibcMath.Kernels.Getpayloadf.Generated.Avx2Fma
import LibcMath.Kernels.Getpayloadf.Generated.AArch64

/-!
# Extracted `getpayloadf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Getpayloadf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Getpayloadf.Generated

end LibcMath.Kernels.Getpayloadf
