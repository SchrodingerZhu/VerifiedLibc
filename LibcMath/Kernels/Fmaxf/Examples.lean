import LibcMath.Kernels.Fmaxf.Plans

/-!
# Worked examples for extracted `fmaxf` plans

Each plan is evaluated at one input. Plans of the same implementation for other targets agree
with the SSE2 plan near `1`.
-/

namespace LibcMath.Kernels.Fmaxf.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Fmaxf.Generated

#guard (GenericSse2.kernel.eval .nearest f32(0x3FC00000#32) f32(0x3FC00000#32)).isSome

#guard (Sse42.kernel.eval .nearest f32(0x3FC00000#32) f32(0x3FC00000#32)).isSome

#guard (Avx2Fma.kernel.eval .nearest f32(0x3FC00000#32) f32(0x3FC00000#32)).isSome

#guard (AArch64.kernel.eval .nearest f32(0x3FC00000#32) f32(0x3FC00000#32)).isSome

#guard (List.range 32).all fun i =>
  let x : Model .binary32 := .ofNatBits (0x3F800000 + i)
  Diag.sameResultBool (GenericSse2.kernel.eval .nearest x f32(0x3FC00000#32))
    (Sse42.kernel.eval .nearest x f32(0x3FC00000#32))

#guard (List.range 32).all fun i =>
  let x : Model .binary32 := .ofNatBits (0x3F800000 + i)
  Diag.sameResultBool (GenericSse2.kernel.eval .nearest x f32(0x3FC00000#32))
    (Avx2Fma.kernel.eval .nearest x f32(0x3FC00000#32))

#guard (List.range 32).all fun i =>
  let x : Model .binary32 := .ofNatBits (0x3F800000 + i)
  Diag.sameResultBool (GenericSse2.kernel.eval .nearest x f32(0x3FC00000#32))
    (AArch64.kernel.eval .nearest x f32(0x3FC00000#32))

end LibcMath.Kernels.Fmaxf.Examples
