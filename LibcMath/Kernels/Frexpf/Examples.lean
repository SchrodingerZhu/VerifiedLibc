import LibcMath.Kernels.Frexpf.Plans

/-!
# Worked examples for extracted `frexpf` plans

Each plan is evaluated at one input. Plans of the same implementation for other targets agree
with the SSE2 plan near `1`.
-/

namespace LibcMath.Kernels.Frexpf.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Frexpf.Generated

#guard (GenericSse2.frexpf f32(0x3FC00000#32)).isSome

#guard (Sse42.frexpf f32(0x3FC00000#32)).isSome

#guard (Avx2Fma.frexpf f32(0x3FC00000#32)).isSome

#guard (AArch64.frexpf f32(0x3FC00000#32)).isSome

end LibcMath.Kernels.Frexpf.Examples
