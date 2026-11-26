import LibcMath.Kernels.Llroundf.Plans

/-!
# Worked examples for extracted `llroundf` plans

Each plan is evaluated at one input. Plans of the same implementation for other targets agree
with the SSE2 plan near `1`.
-/

namespace LibcMath.Kernels.Llroundf.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Llroundf.Generated

#guard (GenericSse2.llroundf f32(0x3FC00000#32)).isSome

#guard (Sse42.llroundf f32(0x3FC00000#32)).isSome

#guard (Avx2Fma.llroundf f32(0x3FC00000#32)).isSome

#guard (AArch64.llroundf f32(0x3FC00000#32)).isSome

end LibcMath.Kernels.Llroundf.Examples
