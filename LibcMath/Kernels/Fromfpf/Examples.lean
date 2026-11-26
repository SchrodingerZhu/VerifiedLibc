import LibcMath.Kernels.Fromfpf.Plans

/-!
# Worked examples for extracted `fromfpf` plans

Each plan is evaluated at one input. Plans of the same implementation for other targets agree
with the SSE2 plan near `1`.
-/

namespace LibcMath.Kernels.Fromfpf.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Fromfpf.Generated

#guard (GenericSse2.fromfpf f32(0x3FC00000#32) 3#32 3#32).isSome

#guard (Sse42.fromfpf f32(0x3FC00000#32) 3#32 3#32).isSome

#guard (Avx2Fma.fromfpf f32(0x3FC00000#32) 3#32 3#32).isSome

#guard (AArch64.fromfpf f32(0x3FC00000#32) 3#32 3#32).isSome

end LibcMath.Kernels.Fromfpf.Examples
