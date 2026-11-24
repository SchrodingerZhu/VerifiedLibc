import FloatLib.Floats.Formats.BinaryInterchange.Arithmetic.Runtime
import FloatLib.Floats.Formats.BinaryInterchange.Conversion.Cast.Runtime
import FloatLib.Floats.Formats.BinaryInterchange.DType.Cast
import FloatLib.Floats.Formats.BinaryInterchange.Operations.Compare.Runtime
import FloatLib.Floats.Formats.BinaryInterchange.Operations.Runtime
import LibcMath.Core.Config

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

namespace LibcMath.Core

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

/-- Resolves standard IEEE `FloatFormat` bit widths to concrete numerals (`16`, `32`, `64`, `128`)
at reducible transparency so `BitVec` operators (`&&&`, `+`, `Core.bitCast`) synthesize directly
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
@[inline, simp, grind] def isInfOrNaN (x : FPBits fmt) : Bool := !Model.isFinite x
@[inline, simp, grind] def isSubnormal (x : FPBits fmt) : Bool := Model.isSubnormal x

@[inline, simp, grind] def abs (x : FPBits fmt) : FPBits fmt := Model.abs x
@[inline, simp, grind] def neg (x : FPBits fmt) : FPBits fmt := Model.neg x

/-- Biased exponent field as `BitVec 16`, matching `FPBits<T>::get_biased_exponent()` (`uint16_t`).
-/
@[inline, simp, grind] def biasedExp (x : FPBits fmt) : BitVec 16 :=
  BitVec.ofNat 16 x.expField

/-- Fraction / mantissa bits as `BitVec w`, matching `FPBits<T>::get_mantissa()`. -/
@[inline, simp, grind] def mantissa {w : Nat} [FmtBitWidth fmt w] (x : FPBits fmt) : BitVec w :=
  BitVec.ofNat w x.fracField

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

@[inline, simp, grind] def quietNaN (fmt : FloatFormat) (sign : Sign := .pos) : FPBits fmt :=
  let q := Model.canonicalNaN fmt
  if sign.isNeg then Model.neg q else q

@[inline] def setSign (x : FPBits fmt) (s : Sign) : FPBits fmt :=
  Model.ofFields fmt s.isNeg x.expField x.fracField

@[inline] def setBiasedExp (x : FPBits fmt) (e : BitVec fmt.bitWidth) : FPBits fmt :=
  Model.ofFields fmt x.signBit e.toNat x.fracField

@[inline] def setMantissa (x : FPBits fmt) (m : BitVec fmt.bitWidth) : FPBits fmt :=
  Model.ofFields fmt x.signBit x.expField m.toNat

@[inline] def createValue (fmt : FloatFormat) (s : Sign) (biasedExp : Nat) (mant : Nat) :
    FPBits fmt :=
  Model.ofFields fmt s.isNeg biasedExp mant

end FPBits

/-! ## IEEE 754 arithmetic, comparisons, and conversions -/

section Arithmetic

variable {fmt : FloatFormat}

@[inline, simp, grind] def fadd (mode : IEEERoundingMode) (x y : Model fmt) : Model fmt :=
  Model.add x y mode

@[inline, simp, grind] def fsub (mode : IEEERoundingMode) (x y : Model fmt) : Model fmt :=
  Model.sub x y mode

@[inline, simp, grind] def fmul (mode : IEEERoundingMode) (x y : Model fmt) : Model fmt :=
  Model.mul x y mode

@[inline, simp, grind] def fdiv (mode : IEEERoundingMode) (x y : Model fmt) : Model fmt :=
  Model.div x y mode

@[inline, simp, grind] def fsqrt (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  Model.sqrt x mode

@[inline, simp, grind] def fma (mode : IEEERoundingMode) (x y z : Model fmt) : Model fmt :=
  Model.fma x y z mode

@[inline, simp, grind] def fneg (x : Model fmt) : Model fmt := Model.neg x
@[inline, simp, grind] def fabs (x : Model fmt) : Model fmt := Model.abs x
@[inline, simp, grind] def copysign (x y : Model fmt) : Model fmt := Model.copySign x y

/-- IEEE floating-point format conversion (`static_cast<Dst>(x)` / `fputil::cast<Dst>(x)`). -/
@[inline, simp, grind] def fpCast {src : FloatFormat} (dst : FloatFormat)
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

/-- Signed float-to-integer truncation (`static_cast<intN_t>(x)`).
Returns `0` on out-of-range / NaN / infinity (total completion for well-defined math paths). -/
@[inline] def fptosi (width : Nat) (x : Model fmt) : BitVec width :=
  match ExecDType.convertToInteger (width := width) x .towardZero with
  | .success n _ => n.bits
  | .failure _ => 0

/-- Unsigned float-to-integer truncation (`static_cast<uintN_t>(x)`). -/
@[inline] def fptoui (width : Nat) (x : Model fmt) : BitVec width :=
  match ExecDType.convertToInteger (width := width + 1) x .towardZero with
  | .success n _ => if n.bits.msb then 0 else n.bits.setWidth width
  | .failure _ => 0

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

@[inline] def multiplyAdd (cfg : MathConfig) (mode : IEEERoundingMode)
    (x y z : Model fmt) : Model fmt :=
  if cfg.hasFma fmt then Model.fma x y z mode
  else Model.add (Model.mul x y mode) z mode

@[inline] def multiplySub (cfg : MathConfig) (mode : IEEERoundingMode)
    (x y z : Model fmt) : Model fmt :=
  if cfg.hasFma fmt then Model.fma x y (Model.neg z) mode
  else Model.sub (Model.mul x y mode) z mode

@[inline] def subMultiply (cfg : MathConfig) (mode : IEEERoundingMode)
    (x y z : Model fmt) : Model fmt :=
  if cfg.hasFma fmt then
    Model.fma (Model.neg y) z x mode
  else if cfg.assumeRoundNearestOnly then
    Model.sub x (Model.mul y z mode) mode
  else
    Model.add x (Model.mul (Model.neg y) z mode) mode

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

/-- Generic software `fputil::generic::nearest_integer` for any IEEE format:
shifts by `2^fracWidth` and back in the dynamic rounding mode, then corrects by `±1` if
`|x - r| > 0.5` when `!assumeRoundNearestOnly`. -/
@[inline] def genericNearestInt {fmt : FloatFormat} (assumeRN : Bool)
    (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  let limit : Model fmt := Model.ofFields fmt false (fmt.exponentBias + fmt.fracWidth + 1) 0
  let magic : Model fmt := Model.ofFields fmt false (fmt.exponentBias + fmt.fracWidth) 0
  if flt x limit && fgt x (Model.neg limit) then
    let r :=
      if flt x (Model.posZero fmt) then
        Model.add (Model.sub x magic mode) magic mode
      else
        Model.sub (Model.add x magic mode) magic mode
    if assumeRN then
      r
    else
      let half : Model fmt := Model.ofFields fmt false (fmt.exponentBias - 1) 0
      let one : Model fmt := Model.posOne fmt
      let diff := Model.sub x r mode
      if fgt diff half then Model.add r one mode
      else if flt diff (Model.neg half) then Model.sub r one mode
      else r
  else
    x

/-- `fputil::nearest_integer`: hardware round-to-nearest-even (`roundss`/`frintn`) when
`cfg.hasNearestInt`, otherwise `genericNearestInt`. -/
@[inline] def nearestInt {fmt : FloatFormat} (cfg : MathConfig)
    (mode : IEEERoundingMode) (x : Model fmt) : Model fmt :=
  if cfg.hasNearestInt then
    Model.roundToIntegral x (mode := .nearest)
  else
    genericNearestInt cfg.assumeRoundNearestOnly mode x

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

/-- `fputil::set_overflow<T>(sign)`: returns `±inf` or `±max_normal` according to `mode` and `cfg`.
-/
@[inline] def setOverflow {fmt : FloatFormat} (cfg : MathConfig)
    (mode : IEEERoundingMode) (sign : Sign := .pos) : Model fmt :=
  if cfg.assumeRoundNearestOnly then
    FPBits.inf fmt sign
  else
    match mode with
    | .towardZero => FPBits.maxNormal fmt sign
    | .down => if sign.isPos then FPBits.maxNormal fmt sign else FPBits.inf fmt sign
    | .up => if sign.isNeg then FPBits.maxNormal fmt sign else FPBits.inf fmt sign
    | _ => FPBits.inf fmt sign

/-- `fputil::set_underflow<T>(sign)`: returns `±0.0` or `±min_subnormal` according to `mode` and
`cfg`. -/
@[inline] def setUnderflow {fmt : FloatFormat} (cfg : MathConfig)
    (mode : IEEERoundingMode) (sign : Sign := .pos) : Model fmt :=
  if cfg.assumeRoundNearestOnly then
    FPBits.zero fmt sign
  else
    match mode with
    | .up => if sign.isPos then FPBits.minSubnormal fmt sign else FPBits.zero fmt sign
    | .down => if sign.isNeg then FPBits.minSubnormal fmt sign else FPBits.zero fmt sign
    | _ => FPBits.zero fmt sign

/-- `fputil::round_result_slightly_down(value_rn)`. -/
@[inline] def roundResultSlightlyDown {fmt : FloatFormat} (cfg : MathConfig)
    (mode : IEEERoundingMode) (valueRn : Model fmt) : Model fmt :=
  if cfg.assumeRoundNearestOnly then valueRn
  else Model.sub valueRn (FPBits.minNormal fmt) mode

/-- `fputil::round_result_slightly_up(value_rn)`. -/
@[inline] def roundResultSlightlyUp {fmt : FloatFormat} (cfg : MathConfig)
    (mode : IEEERoundingMode) (valueRn : Model fmt) : Model fmt :=
  if cfg.assumeRoundNearestOnly then valueRn
  else Model.add valueRn (FPBits.minNormal fmt) mode

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

end LibcMath.Core
