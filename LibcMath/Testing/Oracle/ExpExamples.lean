import LibcMath.Testing.Oracle.Exp

/-!
# Checks of the exponential oracle

In binary32: the correctly rounded values of `exp 1 = 2.71828182…`, which lies between
`0x402DF854` and `0x402DF855` and closer to the former, of an overflowing, an underflowing and a
subnormal exponential, and the special arguments. In binary64: `exp 1`, which lies between
`0x4005BF0A8B145769` and the next number and closer to the former.
-/

namespace LibcMath

open FloatLib.Floats.Formats.BinaryInterchange Model

private abbrev check (mode : IEEERoundingMode) (input result : Nat) : Bool :=
  (expOracle .binary32).check mode (.ofNatBits input) (.ofNatBits result)

/-! `exp 1` -/

example : check .nearest 0x3F800000 0x402DF854 = true := by decide +kernel
example : check .towardZero 0x3F800000 0x402DF854 = true := by decide +kernel
example : check .down 0x3F800000 0x402DF854 = true := by decide +kernel
example : check .up 0x3F800000 0x402DF855 = true := by decide +kernel

example : check .nearest 0x3F800000 0x402DF855 = false := by decide +kernel
example : check .nearest 0x3F800000 0x402DF853 = false := by decide +kernel
example : check .up 0x3F800000 0x402DF854 = false := by decide +kernel
example : check .down 0x3F800000 0x402DF855 = false := by decide +kernel

/-! Arguments next to zero: `exp (2 ^ -149)` and `exp (-2 ^ -149)` -/

example : check .nearest 0x00000001 0x3F800000 = true := by decide +kernel
example : check .up 0x00000001 0x3F800001 = true := by decide +kernel
example : check .up 0x00000001 0x3F800000 = false := by decide +kernel
example : check .down 0x80000001 0x3F7FFFFF = true := by decide +kernel
example : check .towardZero 0x80000001 0x3F7FFFFF = true := by decide +kernel
example : check .up 0x80000001 0x3F800000 = true := by decide +kernel

/-! Overflow at `exp 89` and at the largest finite argument -/

example : check .nearest 0x42B20000 0x7F800000 = true := by decide +kernel
example : check .up 0x42B20000 0x7F800000 = true := by decide +kernel
example : check .down 0x42B20000 0x7F7FFFFF = true := by decide +kernel
example : check .towardZero 0x42B20000 0x7F7FFFFF = true := by decide +kernel
example : check .towardZero 0x7F7FFFFF 0x7F7FFFFF = true := by decide +kernel
example : check .towardZero 0x7F7FFFFF 0x7F800000 = false := by decide +kernel

/-! A subnormal result, `exp (-100) = 26.5… * 2 ^ -149`, and underflow at `exp (-104)` -/

example : check .nearest 0xC2C80000 0x0000001B = true := by decide +kernel
example : check .down 0xC2C80000 0x0000001A = true := by decide +kernel
example : check .nearest 0xC2D00000 0x00000000 = true := by decide +kernel
example : check .up 0xC2D00000 0x00000001 = true := by decide +kernel
example : check .up 0xFF7FFFFF 0x00000001 = true := by decide +kernel
example : check .down 0xFF7FFFFF 0x00000000 = true := by decide +kernel
example : check .nearest 0xFF7FFFFF 0x80000000 = false := by decide +kernel

/-! Zeros, infinities and NaNs -/

example : check .nearest 0x00000000 0x3F800000 = true := by decide +kernel
example : check .down 0x80000000 0x3F800000 = true := by decide +kernel
example : check .nearest 0x7F800000 0x7F800000 = true := by decide +kernel
example : check .up 0xFF800000 0x00000000 = true := by decide +kernel
example : check .up 0xFF800000 0x80000000 = false := by decide +kernel
example : check .nearest 0x7FC00000 0xFFC12345 = true := by decide +kernel
example : check .nearest 0x7FA00000 0x7F800000 = false := by decide +kernel

/-! `exp 1` in binary64 -/

private abbrev check64 (mode : IEEERoundingMode) (input result : Nat) : Bool :=
  (expOracle .binary64).check mode (.ofNatBits input) (.ofNatBits result)

example : check64 .nearest 0x3FF0000000000000 0x4005BF0A8B145769 = true := by decide +kernel
example : check64 .up 0x3FF0000000000000 0x4005BF0A8B14576A = true := by decide +kernel
example : check64 .nearest 0x3FF0000000000000 0x4005BF0A8B14576A = false := by decide +kernel

end LibcMath
