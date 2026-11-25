import FloatLib.Floats.Formats.BinaryInterchange.Arithmetic.Runtime
import FloatLib.Floats.Formats.BinaryInterchange.Conversion.Cast.Runtime
import FloatLib.Floats.Formats.BinaryInterchange.DType.Cast
import FloatLib.Floats.Formats.BinaryInterchange.Operations.Compare.Runtime
import FloatLib.Floats.Formats.BinaryInterchange.Operations.MagnitudeExtrema.Runtime
import FloatLib.Floats.Formats.BinaryInterchange.Operations.Payload.Runtime
import FloatLib.Floats.Formats.BinaryInterchange.Operations.Runtime
import FloatLib.Floats.Formats.BinaryInterchange.Operations.TotalOrder.Runtime
import LibcMath.Libc.Config

/-!
# Core LLVM libc math operations

This module defines the Lean semantics of LLVM libc's core floating-point building blocks
(`fputil::FPBits`, `fputil::multiply_add`, `fputil::sub_multiply`, `fputil::nearest_integer`,
`fputil::quick_get_round`, `fputil::set_overflow`, `fputil::set_underflow`, and IEEE 754
arithmetic/conversions/comparisons).

Every IEEE 754 operation delegates directly to FloatLib (`Model.*` and `ExecDType.*`) rather than
reimplementing floating-point arithmetic. Operations whose C++ semantics depend on `LIBC_MATH_*`
or `LIBC_TARGET_CPU_HAS_*` (`multiplyAdd`, `multiplySub`, `subMultiply`, `nearestInt`,
`setOverflow`, `setUnderflow`) take `MathConfig` explicitly so the extracted Lean model matches
the exact configuration compiled by Clang.
-/

namespace LibcMath.Libc

open FloatLib.Floats.Formats.BinaryInterchange
open FloatLib.Floats.ExecFloat (ConversionOutcome)
open Model (IEEERoundingMode)

/-! ## Signs (`LIBC_NAMESPACE::Sign`) -/

/-- Sign bit representation matching `LIBC_NAMESPACE::Sign` (`src/__support/sign.h`). -/
inductive Sign where
  | pos
  | neg
  deriving DecidableEq, Repr, Inhabited

namespace Sign

@[inline, simp, grind] def isNeg : Sign → Bool
  | .pos => false
  | .neg => true

@[inline, simp, grind] def isPos : Sign → Bool
  | .pos => true
  | .neg => false

@[inline, simp, grind] def negate : Sign → Sign
  | .pos => .neg
  | .neg => .pos

@[inline, simp, grind] def ofBool (isNeg : Bool) : Sign :=
  if isNeg then .neg else .pos

@[inline, simp, grind] def mul : Sign → Sign → Sign
  | .pos, s => s
  | .neg, s => s.negate

end Sign

/-- Returns the storage bit width of an IEEE format as a reducible numeral. -/
@[reducible] def storageWidth : FloatFormat → Nat
  | .binary16 => 16
  | .binary32 => 32
  | .binary64 => 64
  | .binary128 => 128
  | fmt => fmt.bitWidth

/-- Resolves standard IEEE `FloatFormat` bit widths to concrete numerals (`16`, `32`, `64`, `128`)
at reducible transparency so `BitVec` operators (`&&&`, `+`, `Libc.bitCast`) synthesize directly
without explicit width casts. -/
class FmtBitWidth (fmt : FloatFormat) (w : outParam Nat) where
  eq : fmt.bitWidth = w

instance : FmtBitWidth .binary16 16 := ⟨rfl⟩
instance : FmtBitWidth .binary32 32 := ⟨rfl⟩
instance : FmtBitWidth .binary64 64 := ⟨rfl⟩
instance : FmtBitWidth .binary128 128 := ⟨rfl⟩
instance (priority := low) {fmt : FloatFormat} : FmtBitWidth fmt fmt.bitWidth := ⟨rfl⟩

/-! ## `fputil::FPBits<T>`

`FPBits fmt` is a transparent alias for FloatLib's `Model fmt`, avoiding any wrapper overhead
while exposing LLVM libc's `FPBits` method surface with `@[simp, grind]` bridges to `Model`. -/

abbrev FPBits (fmt : FloatFormat) := Model fmt

namespace FPBits

variable {fmt : FloatFormat}

@[inline, simp, grind] def ofVal (x : Model fmt) : FPBits fmt := x
@[inline, simp, grind] def ofBits {w : Nat} [h : FmtBitWidth fmt w] (b : BitVec w) : FPBits fmt :=
  Model.ofBits (BitVec.cast h.eq.symm b)
@[inline, simp, grind] def getVal (x : FPBits fmt) : Model fmt := x
@[inline, simp, grind] def uintval {w : Nat} [h : FmtBitWidth fmt w] (x : FPBits fmt) : BitVec w :=
  BitVec.cast h.eq x.toBits

@[inline, simp, grind] def isNeg (x : FPBits fmt) : Bool := x.signBit
@[inline, simp, grind] def isPos (x : FPBits fmt) : Bool := !x.signBit
@[inline, simp, grind] def sign (x : FPBits fmt) : Sign := Sign.ofBool x.signBit

@[inline, simp, grind] def isZero (x : FPBits fmt) : Bool := Model.isZero x
@[inline, simp, grind] def isInf (x : FPBits fmt) : Bool := Model.isInfinite x
@[inline, simp, grind] def isNaN (x : FPBits fmt) : Bool := Model.isNaN x
@[inline, simp, grind] def isQuietNaN (x : FPBits fmt) : Bool := Model.isQNaN x
@[inline, simp, grind] def isSignalingNaN (x : FPBits fmt) : Bool := Model.isSignaling x
@[inline, simp, grind] def isFinite (x : FPBits fmt) : Bool := Model.isFinite x
@[inline, simp, grind] def isNormal (x : FPBits fmt) : Bool := Model.isNormal x
@[inline, simp, grind] def isInfOrNaN (x : FPBits fmt) : Bool := !Model.isFinite x
@[inline, simp, grind] def isSubnormal (x : FPBits fmt) : Bool := Model.isSubnormal x
@[inline, simp, grind] def isSubnormalOrZero (x : FPBits fmt) : Bool :=
  Model.isZero x || Model.isSubnormal x

@[inline, simp, grind] def abs (x : FPBits fmt) : FPBits fmt := Model.abs x
@[inline, simp, grind] def neg (x : FPBits fmt) : FPBits fmt := Model.neg x
@[inline, simp, grind] def copySign (x y : FPBits fmt) : FPBits fmt := Model.copySign x y

/-- Biased exponent field as `BitVec 16`, matching `FPBits<T>::get_biased_exponent()` (`uint16_t`).
-/
@[inline, simp, grind] def biasedExp (x : FPBits fmt) : BitVec 16 :=
  BitVec.ofNat 16 x.expField

/-- Fraction / mantissa bits as `BitVec w`, matching `FPBits<T>::get_mantissa()`. -/
@[inline, simp, grind] def mantissa {w : Nat} [FmtBitWidth fmt w] (x : FPBits fmt) : BitVec w :=
  BitVec.ofNat w x.fracField

/-- Explicit significand bits (with implicit bit set for normal values), matching
`FPBits<T>::get_explicit_mantissa()`. -/
@[inline, simp, grind] def explicitMantissa {w : Nat} [FmtBitWidth fmt w]
    (x : FPBits fmt) : BitVec w :=
  if x.expField == 0 then
    BitVec.ofNat w x.fracField
  else
    BitVec.ofNat w ((1 <<< fmt.fracWidth) ||| x.fracField)

/-- Explicit unbiased exponent (`int`), matching `FPBits<T>::get_explicit_exponent()`. -/
@[inline] def explicitExponent (x : FPBits fmt) : BitVec 32 :=
  let e : Int :=
    if Model.isZero x then 0
    else if x.expField == 0 then 1 - Int.ofNat fmt.exponentBias
    else Int.ofNat x.expField - Int.ofNat fmt.exponentBias
  BitVec.ofInt 32 e

@[inline, simp, grind] def zero (fmt : FloatFormat) (sign : Sign := .pos) : FPBits fmt :=
  Model.zero fmt sign.isNeg

@[inline, simp, grind] def inf (fmt : FloatFormat) (sign : Sign := .pos) : FPBits fmt :=
  if sign.isNeg then Model.negInf fmt else Model.posInf fmt

@[inline, simp, grind] def one (fmt : FloatFormat) (sign : Sign := .pos) : FPBits fmt :=
  if sign.isNeg then Model.negOne fmt else Model.posOne fmt

@[inline, simp, grind] def maxNormal (fmt : FloatFormat) (sign : Sign := .pos) : FPBits fmt :=
  Model.maxFinite fmt sign.isNeg

@[inline, simp, grind] def minNormal (fmt : FloatFormat) (sign : Sign := .pos) : FPBits fmt :=
  Model.ofFields fmt sign.isNeg 1 0

@[inline, simp, grind] def minSubnormal (fmt : FloatFormat) (sign : Sign := .pos) : FPBits fmt :=
  Model.ofFields fmt sign.isNeg 0 1

@[inline, simp, grind] def maxSubnormal (fmt : FloatFormat) (sign : Sign := .pos) : FPBits fmt :=
  Model.ofFields fmt sign.isNeg 0 fmt.fracMaskNat

@[inline, simp, grind] def quietNaN (fmt : FloatFormat) (sign : Sign := .pos)
    (payload : BitVec (storageWidth fmt) := 0) : FPBits fmt :=
  let q :=
    if payload.toNat == 0 then Model.canonicalNaN fmt
    else Model.ofFields fmt false (2 * fmt.exponentBias + 1)
      ((1 <<< (fmt.fracWidth - 1)) ||| (payload.toNat &&& fmt.fracMaskNat))
  if sign.isNeg then Model.neg q else q

/-- Builds a signaling NaN with the given sign and optional payload (`FPBits::signaling_nan`). -/
@[inline, simp, grind] def signalingNaN (fmt : FloatFormat) (sign : Sign := .pos)
    (payload : BitVec (storageWidth fmt) := 0) : FPBits fmt :=
  let frac :=
    if payload.toNat == 0 then 1 <<< (fmt.fracWidth - 2)
    else payload.toNat &&& fmt.fracMaskNat
  Model.ofFields fmt sign.isNeg (2 * fmt.exponentBias + 1) frac

@[inline] def setSign (x : FPBits fmt) (s : Sign) : FPBits fmt :=
  Model.ofFields fmt s.isNeg x.expField x.fracField

@[inline] def setBiasedExp {w : Nat} (x : FPBits fmt) (e : BitVec w) : FPBits fmt :=
  Model.ofFields fmt x.signBit e.toNat x.fracField

@[inline] def setMantissa {w : Nat} (x : FPBits fmt) (m : BitVec w) : FPBits fmt :=
  Model.ofFields fmt x.signBit x.expField m.toNat

@[inline] def setUintval {w : Nat} [h : FmtBitWidth fmt w] (_ : FPBits fmt) (b : BitVec w) :
    FPBits fmt :=
  ofBits b

@[inline] def createValue (fmt : FloatFormat) (s : Sign) (biasedExp : Nat) (mant : Nat) :
    FPBits fmt :=
  Model.ofFields fmt s.isNeg biasedExp mant

end FPBits

/-! ## IEEE 754 arithmetic, comparisons, and conversions -/

section Arithmetic

variable {fmt : FloatFormat}

@[noinline, simp, grind] def fadd (mode : IEEERoundingMode) (x y : Model fmt) : Model fmt :=
  Model.add x y mode

@[noinline, simp, grind] def fsub (mode : IEEERoundingMode) (x y : Model fmt) : Model fmt :=
  Model.sub x y mode

@[noinline, simp, grind] def fmul (mode : IEEERoundingMode) (x y : Model fmt) : Model fmt :=
  Model.mul x y mode

@[noinline, simp, grind] def fdiv (mode : IEEERoundingMode) (x y : Model fmt) : Model fmt :=
  Model.div x y mode

@[noinline, simp, grind] def fsqrt (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  Model.sqrt x mode

@[noinline, simp, grind] def fma (mode : IEEERoundingMode) (x y z : Model fmt) : Model fmt :=
  Model.fma x y z mode

@[inline, simp, grind] def fneg (x : Model fmt) : Model fmt := Model.neg x
@[inline, simp, grind] def fabs (x : Model fmt) : Model fmt := Model.abs x
@[inline, simp, grind] def copysign (x y : Model fmt) : Model fmt := Model.copySign x y

/-- IEEE floating-point format conversion (`static_cast<Dst>(x)` / `fputil::cast<Dst>(x)`). -/
@[noinline, simp, grind] def fpCast {src : FloatFormat} (dst : FloatFormat)
    (mode : IEEERoundingMode) (x : Model src) : Model dst :=
  Model.cast src dst x mode

/-- Bitwise reinterpretation between raw `BitVec` and `Model` (`cpp::bit_cast`). -/
class BitCast (α : Type) (β : Type) where
  bitCast : α → β

export BitCast (bitCast)

instance {fmt : FloatFormat} {w : Nat} [h : FmtBitWidth fmt w] :
    BitCast (BitVec w) (Model fmt) where
  bitCast b := Model.ofBits (BitVec.cast h.eq.symm b)

instance {fmt : FloatFormat} {w : Nat} [h : FmtBitWidth fmt w] :
    BitCast (Model fmt) (BitVec w) where
  bitCast x := BitVec.cast h.eq x.toBits

instance {w : Nat} : BitCast (BitVec w) (BitVec w) where
  bitCast := id

@[simp, grind =] theorem bitCast_bits_to_model {fmt : FloatFormat} {w : Nat}
    [h : FmtBitWidth fmt w] (b : BitVec w) :
    (bitCast b : Model fmt) = Model.ofBits (BitVec.cast h.eq.symm b) := rfl

@[simp, grind =] theorem bitCast_model_to_bits {fmt : FloatFormat} {w : Nat}
    [h : FmtBitWidth fmt w] (x : Model fmt) :
    (bitCast x : BitVec w) = BitVec.cast h.eq x.toBits := rfl

/-! ### Operations that C++ leaves undefined

An extracted function returns `Option`, and `none` stands for an execution that reaches an
operation to which C++ gives no meaning. The operations below are the places where that can
happen; `ast2lean` emits them, and reads of a table as `table[i]?`. Everything else in this file
is total.

Tracked: a conversion from floating point to an integer that is out of range, an index out of
bounds, a shift by the width or more, overflow of signed `+`, `-`, `*` and unary `-`, and a
division or remainder by zero or of the least signed value by `-1`. Not tracked: a left shift of a
signed value that overflows, which is undefined before C++20, and anything inside the definitions
of `LibcMath/Libc/Extended.lean`, which model library types as total. -/

/-- Signed float-to-integer truncation (`static_cast<intN_t>(x)`). `none` when the truncated
value is out of range, or `x` is a NaN or an infinity. -/
@[inline] def fptosi? (width : Nat) (x : Model fmt) : Option (BitVec width) :=
  match ExecDType.convertToInteger (width := width) x .towardZero with
  | .success n _ => some n.bits
  | .failure _ => none

/-- Unsigned float-to-integer truncation (`static_cast<uintN_t>(x)`). `none` when the truncated
value is negative or too large, or `x` is a NaN or an infinity. -/
@[inline] def fptoui? (width : Nat) (x : Model fmt) : Option (BitVec width) :=
  match ExecDType.convertToInteger (width := width + 1) x .towardZero with
  | .success n _ => if n.bits.msb then none else some (n.bits.setWidth width)
  | .failure _ => none

/-- The amount of a shift of a value of `width` bits: `none` from `width` on. -/
@[inline] def shiftAmount? (width amount : Nat) : Option Nat :=
  if amount < width then some amount else none

/-- Signed addition: `none` on overflow. -/
@[inline] def sadd? {w : Nat} (a b : BitVec w) : Option (BitVec w) :=
  if BitVec.saddOverflow a b then none else some (a + b)

/-- Signed subtraction: `none` on overflow. -/
@[inline] def ssub? {w : Nat} (a b : BitVec w) : Option (BitVec w) :=
  if BitVec.ssubOverflow a b then none else some (a - b)

/-- Signed multiplication: `none` on overflow. -/
@[inline] def smul? {w : Nat} (a b : BitVec w) : Option (BitVec w) :=
  if BitVec.smulOverflow a b then none else some (a * b)

/-- Signed negation: `none` for the least value, whose negation is not representable. -/
@[inline] def sneg? {w : Nat} (a : BitVec w) : Option (BitVec w) :=
  if BitVec.negOverflow a then none else some (-a)

/-- Signed division: `none` for a zero divisor and for the least value divided by `-1`. -/
@[inline] def sdiv? {w : Nat} (a b : BitVec w) : Option (BitVec w) :=
  if b == 0 || BitVec.sdivOverflow a b then none else some (BitVec.sdiv a b)

/-- Signed remainder: `none` where `sdiv?` is. -/
@[inline] def srem? {w : Nat} (a b : BitVec w) : Option (BitVec w) :=
  if b == 0 || BitVec.sdivOverflow a b then none else some (BitVec.srem a b)

/-- Unsigned division: `none` for a zero divisor. -/
@[inline] def udiv? {w : Nat} (a b : BitVec w) : Option (BitVec w) :=
  if b == 0 then none else some (a / b)

/-- Unsigned remainder: `none` for a zero divisor. -/
@[inline] def urem? {w : Nat} (a b : BitVec w) : Option (BitVec w) :=
  if b == 0 then none else some (a % b)

/-- Signed integer-to-float conversion (`static_cast<Float>(n)`). -/
@[inline] def sitofp (dst : FloatFormat) (mode : IEEERoundingMode) {w : Nat} (n : BitVec w) :
    Model dst :=
  ExecDType.convertFromInt dst ⟨n⟩ mode

/-- Unsigned integer-to-float conversion (`static_cast<Float>(n)`). -/
@[inline] def uitofp (dst : FloatFormat) (mode : IEEERoundingMode) {w : Nat} (n : BitVec w) :
    Model dst :=
  ExecDType.convertFromInt dst ⟨n.setWidth (w + 1)⟩ mode

/-! ### IEEE quiet comparisons (`==`, `!=`, `<`, `<=`, `>`, `>=`) -/

@[inline, simp, grind] def feq (x y : Model fmt) : Bool := Model.compare x y == some .eq
@[inline, simp, grind] def fne (x y : Model fmt) : Bool := Model.compare x y != some .eq
@[inline, simp, grind] def flt (x y : Model fmt) : Bool := Model.compare x y == some .lt
@[inline, simp, grind] def fle (x y : Model fmt) : Bool :=
  let o := Model.compare x y; o == some .lt || o == some .eq
@[inline, simp, grind] def fgt (x y : Model fmt) : Bool := Model.compare x y == some .gt
@[inline, simp, grind] def fge (x y : Model fmt) : Bool :=
  let o := Model.compare x y; o == some .gt || o == some .eq

end Arithmetic

/-! ## Config-aware FMA / multiply-add operations (`src/__support/FPUtil/multiply_add.h`)

These match the exact preprocessor and `if constexpr` dispatch in `multiply_add.h`:

* `multiplyAdd`: `fma(x, y, z)` when `cfg.hasFma fmt`, else `(x * y) + z`.
* `multiplySub`: `fma(x, y, -z)` when `cfg.hasFma fmt`, else `(x * y) - z`.
* `subMultiply` (`x - y * z`):
  - `fma(-y, z, x)` when `cfg.hasFma fmt`,
  - `x + ((-y) * z)` when `!cfg.hasFma fmt` and `!cfg.assumeRoundNearestOnly`
    (so `(-y) * z` rounds in the same direction as the outer sum in `FE_UPWARD`/`FE_DOWNWARD`),
  - `x - (y * z)` when `!cfg.hasFma fmt` and `cfg.assumeRoundNearestOnly`. -/

section MultiplyAdd

variable {fmt : FloatFormat}

def multiplyAdd (cfg : MathConfig) (mode : IEEERoundingMode)
    (x y z : Model fmt) : Model fmt :=
  if cfg.hasFma fmt then fma mode x y z
  else fadd mode (fmul mode x y) z

def multiplySub (cfg : MathConfig) (mode : IEEERoundingMode)
    (x y z : Model fmt) : Model fmt :=
  if cfg.hasFma fmt then fma mode x y (Model.neg z)
  else fsub mode (fmul mode x y) z

def subMultiply (cfg : MathConfig) (mode : IEEERoundingMode)
    (x y z : Model fmt) : Model fmt :=
  if cfg.hasFma fmt then
    fma mode (Model.neg y) z x
  else if cfg.assumeRoundNearestOnly then
    fsub mode x (fmul mode y z)
  else
    fadd mode x (fmul mode (Model.neg y) z)

@[simp, grind =] theorem multiplyAdd_of_noFma {cfg : MathConfig} (h : cfg.hasFma fmt = false)
    (mode : IEEERoundingMode) (x y z : Model fmt) :
    multiplyAdd cfg mode x y z = Model.add (Model.mul x y mode) z mode := by
  simp [multiplyAdd, h]

@[simp, grind =] theorem multiplyAdd_of_fma {cfg : MathConfig} (h : cfg.hasFma fmt = true)
    (mode : IEEERoundingMode) (x y z : Model fmt) :
    multiplyAdd cfg mode x y z = Model.fma x y z mode := by
  simp [multiplyAdd, h]

@[simp, grind =] theorem subMultiply_of_noFma_directed {cfg : MathConfig}
    (hf : cfg.hasFma fmt = false) (hrn : cfg.assumeRoundNearestOnly = false)
    (mode : IEEERoundingMode) (x y z : Model fmt) :
    subMultiply cfg mode x y z = Model.add x (Model.mul (Model.neg y) z mode) mode := by
  simp [subMultiply, hf, hrn]

@[simp, grind =] theorem subMultiply_of_fma {cfg : MathConfig} (hf : cfg.hasFma fmt = true)
    (mode : IEEERoundingMode) (x y z : Model fmt) :
    subMultiply cfg mode x y z = Model.fma (Model.neg y) z x mode := by
  simp [subMultiply, hf]

end MultiplyAdd

/-! ## Config-aware `fputil::nearest_integer` (`src/__support/FPUtil/nearest_integer.h`) -/

/-- Generic software `fputil::generic::nearest_integer` for any IEEE format.
Shifts `x` by `2^fracWidth` and back in `mode`, then adds or subtracts `1` if `|x - r| > 0.5`
when `assumeRN` is `false`. -/
def genericNearestInt {fmt : FloatFormat} (assumeRN : Bool)
    (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  let limit : Model fmt := Model.ofFields fmt false (fmt.exponentBias + fmt.fracWidth + 1) 0
  let magic : Model fmt := Model.ofFields fmt false (fmt.exponentBias + fmt.fracWidth) 0
  if flt x limit && fgt x (Model.neg limit) then
    let r :=
      if flt x (Model.posZero fmt) then
        fadd mode (fsub mode x magic) magic
      else
        fsub mode (fadd mode x magic) magic
    if assumeRN then
      r
    else
      let half : Model fmt := Model.ofFields fmt false (fmt.exponentBias - 1) 0
      let one : Model fmt := Model.posOne fmt
      let diff := fsub mode x r
      if fgt diff half then fadd mode r one
      else if flt diff (Model.neg half) then fsub mode r one
      else r
  else
    x

/-- `fputil::nearest_integer`: dispatches by `cfg.nearestIntKind fmt` to match
`src/__support/FPUtil/nearest_integer.h`:
* `.hwTiesToEven` (x86-64 SSE4.2 `roundss`/`roundsd`, AArch64 `frintn`, ARMv8 `roundeven`):
  ties-to-even integral rounding independent of `mode`.
* `.gpuDynamicRint` (NVPTX / AMDGPU / SPIR-V `__builtin_rintf`/`rint`):
  dynamic-mode integral rounding.
* `.genericMagic` (x86-64 SSE2/SSSE3, RISC-V, soft-float): `genericNearestInt`. -/
def nearestInt {fmt : FloatFormat} (cfg : MathConfig)
    (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  match cfg.nearestIntKind fmt with
  | .hwTiesToEven => Model.roundToIntegral x (mode := .nearest)
  | .gpuDynamicRint => Model.roundToIntegral x (mode := mode)
  | .genericMagic => genericNearestInt cfg.assumeRoundNearestOnly mode x

/-! ## Rounding-mode queries (`src/__support/FPUtil/rounding_mode.h`) -/

/-- x86-64 / glibc `FE_*` integer constants matching `hdr/fenv_macros.h`. -/
@[inline, simp, grind] def feTonearest : BitVec 32 := 0x000#32
@[inline, simp, grind] def feDownward : BitVec 32 := 0x400#32
@[inline, simp, grind] def feUpward : BitVec 32 := 0x800#32
@[inline, simp, grind] def feTowardzero : BitVec 32 := 0xC00#32

@[inline, simp, grind] def quickGetRound (mode : IEEERoundingMode) : BitVec 32 :=
  match mode with
  | .nearest => feTonearest
  | .down => feDownward
  | .up => feUpward
  | .towardZero => feTowardzero
  | .nearestAway | .away => feTonearest

@[inline, simp, grind] def isRoundUp (mode : IEEERoundingMode) : Bool := mode == .up
@[inline, simp, grind] def isRoundDown (mode : IEEERoundingMode) : Bool := mode == .down
@[inline, simp, grind] def isRoundToNearest (mode : IEEERoundingMode) : Bool := mode == .nearest
@[inline, simp, grind] def isRoundToZero (mode : IEEERoundingMode) : Bool := mode == .towardZero

/-! ## Exceptional-result helpers (`src/__support/FPUtil/except_value_utils.h`) -/

/-- `fputil::set_overflow<T>(sign)`: returns `±inf` or `±max_normal` for `mode` and `cfg`. -/
def setOverflow {fmt : FloatFormat} (cfg : MathConfig)
    (mode : IEEERoundingMode) (sign : Sign := .pos) : Model fmt :=
  if cfg.assumeRoundNearestOnly then
    FPBits.inf fmt sign
  else
    match mode with
    | .towardZero => FPBits.maxNormal fmt sign
    | .down => if sign.isPos then FPBits.maxNormal fmt sign else FPBits.inf fmt sign
    | .up => if sign.isNeg then FPBits.maxNormal fmt sign else FPBits.inf fmt sign
    | _ => FPBits.inf fmt sign

/-- `fputil::set_underflow<T>(sign)`: returns `±0.0` or `±min_subnormal` for `mode` and `cfg`. -/
def setUnderflow {fmt : FloatFormat} (cfg : MathConfig)
    (mode : IEEERoundingMode) (sign : Sign := .pos) : Model fmt :=
  if cfg.assumeRoundNearestOnly then
    FPBits.zero fmt sign
  else
    match mode with
    | .up => if sign.isPos then FPBits.minSubnormal fmt sign else FPBits.zero fmt sign
    | .down => if sign.isNeg then FPBits.minSubnormal fmt sign else FPBits.zero fmt sign
    | _ => FPBits.zero fmt sign

/-- `fputil::round_result_slightly_down(value_rn)`. -/
def roundResultSlightlyDown {fmt : FloatFormat} (cfg : MathConfig)
    (mode : IEEERoundingMode) (valueRn : Model fmt) : Model fmt :=
  if cfg.assumeRoundNearestOnly then valueRn
  else fsub mode valueRn (FPBits.minNormal fmt)

/-- `fputil::round_result_slightly_up(value_rn)`. -/
def roundResultSlightlyUp {fmt : FloatFormat} (cfg : MathConfig)
    (mode : IEEERoundingMode) (valueRn : Model fmt) : Model fmt :=
  if cfg.assumeRoundNearestOnly then valueRn
  else fadd mode valueRn (FPBits.minNormal fmt)

/-! ## Integral rounding and classification (backed by FloatLib) -/

section IntegralAndIEEE

variable {fmt : FloatFormat}

/-- C23 `FP_INT_*` constants from `hdr/math_macros.h`. -/
@[inline, simp, grind] def fpIntUpward : BitVec 32 := 0#32
@[inline, simp, grind] def fpIntDownward : BitVec 32 := 1#32
@[inline, simp, grind] def fpIntTowardzero : BitVec 32 := 2#32
@[inline, simp, grind] def fpIntTonearestFromZero : BitVec 32 := 3#32
@[inline, simp, grind] def fpIntTonearest : BitVec 32 := 4#32

/-- Maps a C23 `FP_INT_*` code to `IEEERoundingMode`. -/
@[simp, grind] def decodeFpIntMode (rnd : BitVec 32) : IEEERoundingMode :=
  if rnd == fpIntUpward then .up
  else if rnd == fpIntDownward then .down
  else if rnd == fpIntTowardzero then .towardZero
  else if rnd == fpIntTonearestFromZero then .nearestAway
  else .nearest

/-- `fputil::floor`: rounds toward negative infinity via FloatLib. -/
def floor (x : Model fmt) : Model fmt :=
  Model.roundToIntegral x (mode := .down)

/-- `fputil::ceil`: rounds toward positive infinity via FloatLib. -/
def ceil (x : Model fmt) : Model fmt :=
  Model.roundToIntegral x (mode := .up)

/-- `fputil::trunc`: rounds toward zero via FloatLib. -/
def trunc (x : Model fmt) : Model fmt :=
  Model.roundToIntegral x (mode := .towardZero)

/-- `fputil::round`: rounds to nearest integer, ties away from zero, via FloatLib. -/
def round (x : Model fmt) : Model fmt :=
  Model.roundToIntegral x (mode := .nearestAway)

/-- `fputil::roundeven`: rounds to nearest integer, ties to even, via FloatLib. -/
def roundEven (x : Model fmt) : Model fmt :=
  Model.roundToIntegral x (mode := .nearest)

/-- `fputil::round_using_specific_rounding_mode(x, rnd)` via FloatLib. -/
def roundToIntMode (x : Model fmt) (rnd : BitVec 32) : Model fmt :=
  Model.roundToIntegral x (mode := decodeFpIntMode rnd)

/-- `fputil::round_using_current_rounding_mode(x)` via FloatLib.
Uses `.nearest` when `cfg.assumeRoundNearestOnly` is `true`. -/
def roundToInt (cfg : MathConfig) (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  Model.roundToIntegral x (mode := if cfg.assumeRoundNearestOnly then .nearest else mode)

/-- `fputil::is_integer`: tests if finite `x` is an integer via FloatLib `Model.dyadicIsIntegral`.
Returns `true` for infinity and NaN to match `src/__support/FPUtil/is_integer.h`. -/
def isInteger (x : Model fmt) : Bool :=
  match Model.exactValue x with
  | .finite d => Model.dyadicIsIntegral d
  | .infinity _ | .nan _ _ _ => true

/-- `fputil::is_odd_integer`: tests if finite `x` is an odd integer via FloatLib. -/
def isOddInteger (x : Model fmt) : Bool :=
  match Model.exactValue x with
  | .finite d =>
      Model.dyadicIsIntegral d && (Model.roundDyadicToInt .towardZero d % 2 != 0)
  | .infinity _ | .nan _ _ _ => false

/-- Converts `x` to a signed `width`-bit integer under `mode` via FloatLib.
Returns `none` if `x` is NaN, infinite, or out of range. -/
def roundToSignedInt? (width : Nat) (mode : IEEERoundingMode) (x : Model fmt) :
    Option (BitVec width) :=
  match ExecDType.convertToInteger (width := width) x mode with
  | .success n _ => some n.bits
  | .failure _ => none

/-- `fputil::ldexp` / `scale_exp2`: multiplies `x` by `2^exp` via FloatLib `Model.scale`. -/
def ldexp {w : Nat} (cfg : MathConfig) (mode : IEEERoundingMode)
    (x : Model fmt) (exp : BitVec w) : Model fmt :=
  if exp == 0 || Model.isZero x || !Model.isFinite x then
    x
  else
    let e := exp.toInt
    let limit : Int := Int.ofNat (fmt.expAllOnesNat + fmt.fracWidth + 1)
    if e > limit then
      setOverflow cfg mode (FPBits.sign x)
    else if e < -limit then
      setUnderflow cfg mode (FPBits.sign x)
    else
      Model.scale x e (mode := mode)

/-- `fputil::logb`: returns the binary exponent of `x` as a float via FloatLib `Model.logB`. -/
def logb (x : Model fmt) : Model fmt :=
  Model.logB x

/-- `fputil::intlogb`: returns the binary exponent of `x` as a signed `w`-bit integer via FloatLib
`Model.logBInt`. Uses `cfg.fpLogbNanMin` (`INT_MIN` on glibc Linux, `INT_MAX` otherwise). -/
def intlogb (cfg : MathConfig) (w : Nat) (x : Model fmt) : BitVec w :=
  if Model.isZero x then
    BitVec.intMin w
  else if Model.isNaN x then
    if cfg.fpLogbNanMin then BitVec.intMin w else BitVec.intMax w
  else if Model.isInfinite x then
    BitVec.intMax w
  else
    BitVec.ofInt w (Model.logBInt x).value

/-- IEEE 754 `remainder` via FloatLib `Model.remainder`. -/
def remainder (x y : Model fmt) : Model fmt :=
  Model.remainder x y

/-- IEEE 754 `nextUp` via FloatLib `Model.nextUp`. -/
def nextUp (x : Model fmt) : Model fmt :=
  Model.nextUp x

/-- IEEE 754 `nextDown` via FloatLib `Model.nextDown`. -/
def nextDown (x : Model fmt) : Model fmt :=
  Model.nextDown x

/-- `fputil::nextafter(from, to)` via FloatLib `Model.nextUp` / `Model.nextDown`. -/
def nextAfter {dst : FloatFormat} (x : Model fmt) (y : Model dst) : Model fmt :=
  if Model.isNaN x then x
  else if Model.isNaN y then fpCast fmt .nearest y
  else
    let xWid := fpCast dst .nearest x
    match Model.compare xWid y with
    | some .eq => fpCast fmt .nearest y
    | some .lt => Model.nextUp x
    | some .gt => Model.nextDown x
    | none => Model.canonicalNaN fmt

/-! ### IEEE 754-2019 extrema, NaN payload, and total order (backed by FloatLib) -/

/-- `fputil::fmax` via FloatLib `Model.maximumNumber`. -/
def fmax (x y : Model fmt) : Model fmt := Model.maximumNumber x y

/-- `fputil::fmin` via FloatLib `Model.minimumNumber`. -/
def fmin (x y : Model fmt) : Model fmt := Model.minimumNumber x y

/-- `fputil::fmaximum` via FloatLib `Model.maximum`. -/
def fmaximum (x y : Model fmt) : Model fmt := Model.maximum x y

/-- `fputil::fminimum` via FloatLib `Model.minimum`. -/
def fminimum (x y : Model fmt) : Model fmt := Model.minimum x y

/-- `fputil::fmaximum_num` via FloatLib `Model.maximumNumber`. -/
def fmaximumNum (x y : Model fmt) : Model fmt := Model.maximumNumber x y

/-- `fputil::fminimum_num` via FloatLib `Model.minimumNumber`. -/
def fminimumNum (x y : Model fmt) : Model fmt := Model.minimumNumber x y

/-- `fputil::fmaximum_mag` via FloatLib `Model.maximumMagnitude`. -/
def fmaximumMag (x y : Model fmt) : Model fmt := Model.maximumMagnitude x y

/-- `fputil::fminimum_mag` via FloatLib `Model.minimumMagnitude`. -/
def fminimumMag (x y : Model fmt) : Model fmt := Model.minimumMagnitude x y

/-- `fputil::fmaximum_mag_num` via FloatLib `Model.maximumMagnitudeNumber`. -/
def fmaximumMagNum (x y : Model fmt) : Model fmt := Model.maximumMagnitudeNumber x y

/-- `fputil::fminimum_mag_num` via FloatLib `Model.minimumMagnitudeNumber`. -/
def fminimumMagNum (x y : Model fmt) : Model fmt := Model.minimumMagnitudeNumber x y

/-- `fputil::getpayload` via FloatLib `Model.getPayload`. -/
def getPayload (x : Model fmt) : Model fmt := Model.getPayload x

/-- `fputil::setpayload` via FloatLib `Model.setPayload`. -/
def setPayload (x : Model fmt) : Model fmt := Model.setPayload x

/-- `fputil::setpayloadsig` via FloatLib `Model.setPayloadSignaling`. -/
def setPayloadSignaling (x : Model fmt) : Model fmt := Model.setPayloadSignaling x

/-- `fputil::totalorder` via FloatLib `Model.totalOrder`. -/
def totalOrder (x y : Model fmt) : Bool := Model.totalOrder x y

/-- `fputil::totalordermag` via FloatLib `Model.totalOrderMag`. -/
def totalOrderMag (x y : Model fmt) : Bool := Model.totalOrderMag x y

/-! ### Floating-point bitwise operations (`src/__support/FPUtil/fp_bitwise.h`) -/

/-- `fputil::fp_and`: bitwise AND of IEEE encodings. -/
@[simp, grind] def fpAnd (a b : Model fmt) : Model fmt :=
  Model.ofBits (a.toBits &&& b.toBits)

/-- `fputil::fp_or`: bitwise OR of IEEE encodings. -/
@[simp, grind] def fpOr (a b : Model fmt) : Model fmt :=
  Model.ofBits (a.toBits ||| b.toBits)

/-- `fputil::fp_xor`: bitwise XOR of IEEE encodings. -/
@[simp, grind] def fpXor (a b : Model fmt) : Model fmt :=
  Model.ofBits (a.toBits ^^^ b.toBits)

/-- `fputil::fp_andnot`: bitwise `(~a) & b` of IEEE encodings. -/
@[simp, grind] def fpAndNot (a b : Model fmt) : Model fmt :=
  Model.ofBits ((~~~a.toBits) &&& b.toBits)

end IntegralAndIEEE

/-! ## C++20 bit utilities (`src/__support/CPP/bit.h` and Clang 23 builtins) -/

/-- `cpp::countl_zero` / `__builtin_clzg` as `BitVec 32`. -/
@[inline, simp, grind] def countlZero {w : Nat} (x : BitVec w) : BitVec 32 :=
  BitVec.ofNat 32 x.clz.toNat

/-- `cpp::countr_zero` / `__builtin_ctzg` as `BitVec 32`. -/
@[inline, simp, grind] def countrZero {w : Nat} (x : BitVec w) : BitVec 32 :=
  BitVec.ofNat 32 x.ctz.toNat

/-- `cpp::popcount` / `__builtin_popcountg` as `BitVec 32`. -/
@[inline, simp, grind] def popcount {w : Nat} (x : BitVec w) : BitVec 32 :=
  BitVec.ofNat 32 x.cpop.toNat

/-- `cpp::has_single_bit`: tests whether `x` is a power of two. -/
@[inline, simp, grind] def hasSingleBit {w : Nat} (x : BitVec w) : Bool :=
  x != 0 && (x &&& (x - 1)) == 0

/-- `cpp::bit_width`: number of bits needed to represent `x`. -/
@[inline, simp, grind] def bitWidth {w : Nat} (x : BitVec w) : BitVec 32 :=
  BitVec.ofNat 32 (w - x.clz.toNat)

/-- Exact equivalence of the hardware-FPU multiplication trick in `set_overflow<float>` with
`setOverflow` for all four C rounding modes. -/
theorem setOverflow_binary32_pos_eq {mode : IEEERoundingMode} (hmode : mode ∈ cModes) :
    Model.mul (Model.ofBits 0x70000000#32 : Model .binary32)
      (Model.ofBits 0x70000000#32 : Model .binary32) mode =
      if mode = .towardZero ∨ mode = .down then
        Model.posMaxFinite .binary32
      else
        Model.posInf .binary32 := by
  rcases hmode with rfl | rfl | rfl | rfl <;> decide +kernel

/-- Exact equivalence of the hardware-FPU multiplication trick in `set_underflow<float>` with
`setUnderflow` for all four C rounding modes. -/
theorem setUnderflow_binary32_pos_eq {mode : IEEERoundingMode} (hmode : mode ∈ cModes) :
    Model.mul (Model.ofBits 0x10000000#32 : Model .binary32)
      (Model.ofBits 0x10000000#32 : Model .binary32) mode =
      if mode = .up then
        Model.ofNatBits 0x00000001
      else
        Model.posZero .binary32 := by
  rcases hmode with rfl | rfl | rfl | rfl <;> decide +kernel

end LibcMath.Libc
