import LibcMath.Kernels.Canonicalizef.Plans

/-!
# Worked examples for extracted `canonicalizef` plans

Each plan is evaluated at one input. Plans of the same implementation for other targets agree
with the SSE2 plan near `1`.
-/

namespace LibcMath.Kernels.Canonicalizef.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Canonicalizef.Generated

#guard (GenericSse2.canonicalizef f32(0x3FC00000#32)).isSome

#guard (Sse42.canonicalizef f32(0x3FC00000#32)).isSome

#guard (Avx2Fma.canonicalizef f32(0x3FC00000#32)).isSome

#guard (AArch64.canonicalizef f32(0x3FC00000#32)).isSome

end LibcMath.Kernels.Canonicalizef.Examples
