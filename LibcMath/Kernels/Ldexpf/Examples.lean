import LibcMath.Kernels.Ldexpf.Plans

/-!
# Worked examples for extracted `ldexpf` plans

Each plan is evaluated at one input. Plans of the same implementation for other targets agree
with the SSE2 plan near `1`.
-/

namespace LibcMath.Kernels.Ldexpf.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Ldexpf.Generated

#guard (GenericSse2.ldexpf .nearest f32(0x3FC00000#32) 3#32).isSome

#guard (Sse42.ldexpf .nearest f32(0x3FC00000#32) 3#32).isSome

#guard (Avx2Fma.ldexpf .nearest f32(0x3FC00000#32) 3#32).isSome

#guard (AArch64.ldexpf .nearest f32(0x3FC00000#32) 3#32).isSome

end LibcMath.Kernels.Ldexpf.Examples
