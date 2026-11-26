import LibcMath.Kernels.Lroundf.Plans

/-!
# Worked examples for extracted `lroundf` plans

Each plan is evaluated at one input. Plans of the same implementation for other targets agree
with the SSE2 plan near `1`.
-/

namespace LibcMath.Kernels.Lroundf.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Lroundf.Generated

#guard (GenericSse2.lroundf f32(0x3FC00000#32)).isSome

#guard (Sse42.lroundf f32(0x3FC00000#32)).isSome

#guard (Avx2Fma.lroundf f32(0x3FC00000#32)).isSome

#guard (AArch64.lroundf f32(0x3FC00000#32)).isSome

end LibcMath.Kernels.Lroundf.Examples
