import LibcMath.Kernels.Fmodf.Plans

/-!
# Worked examples for extracted `fmodf` plans

Each plan is evaluated at one input. Plans of the same implementation for other targets agree
with the SSE2 plan near `1`.
-/

namespace LibcMath.Kernels.Fmodf.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Fmodf.Generated

#guard (GenericSse2.fmodf f32(0x3FC00000#32) f32(0x3FC00000#32)).isSome

#guard (Sse42.fmodf f32(0x3FC00000#32) f32(0x3FC00000#32)).isSome

#guard (Avx2Fma.fmodf f32(0x3FC00000#32) f32(0x3FC00000#32)).isSome

#guard (AArch64.fmodf f32(0x3FC00000#32) f32(0x3FC00000#32)).isSome

end LibcMath.Kernels.Fmodf.Examples
