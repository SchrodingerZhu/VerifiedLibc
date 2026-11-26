import LibcMath.Kernels.Issignalingf.Generated.GenericSse2
import LibcMath.Kernels.Issignalingf.Generated.Sse42
import LibcMath.Kernels.Issignalingf.Generated.Avx2Fma
import LibcMath.Kernels.Issignalingf.Generated.AArch64

/-!
# Extracted `issignalingf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Issignalingf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Issignalingf.Generated

end LibcMath.Kernels.Issignalingf
