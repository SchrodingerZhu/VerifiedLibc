import LibcMath.Kernels.Logbf.Plans

/-!
# Worked examples for extracted `logbf` plans

Each plan is evaluated at one input. Plans of the same implementation for other targets agree
with the SSE2 plan near `1`.
-/

namespace LibcMath.Kernels.Logbf.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Logbf.Generated

#guard (GenericSse2.logbf f32(0x3FC00000#32)).isSome

#guard (Sse42.logbf f32(0x3FC00000#32)).isSome

#guard (Avx2Fma.logbf f32(0x3FC00000#32)).isSome

#guard (AArch64.logbf f32(0x3FC00000#32)).isSome

end LibcMath.Kernels.Logbf.Examples
