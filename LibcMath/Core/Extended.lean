import LibcMath.Core.Ops

/-!
# Extended-precision, fixed-point, and exceptional-value types of LLVM libc

Models the non-primitive numeric carriers used across LLVM libc's math implementations:

* `Frac64` (`src/__support/frac64.h`): 64-bit unsigned fixed-point fractional word whose product
  is `UInt<64>::quick_mul_hi`, used by integer-only evaluation plans (`expf_integer_eval.h`).
* `NumberPair` / `DoubleDouble` / `FloatFloat` (`src/__support/FPUtil/double_double.h`):
  unevaluated sums `hi + lo` with Dekker's `FastTwoSum`, Knuth's `TwoSum`, Veltkamp splitting,
  FMA/Dekker `exact_mult`, `quick_mult`, and Karp–Markstein `div`.
* `TripleDouble` (`src/__support/FPUtil/triple_double.h`): three-component expansion.
* `DyadicFloat` (`src/__support/FPUtil/dyadic_float.h`): wide-mantissa dyadic float for
  accurate passes (`exp`, `log`, `sin`, `cos`, etc.).
* `ExceptValues` (`src/__support/FPUtil/except_value_utils.h`): rounding-mode-indexed table of
  hard-to-round inputs.
-/

namespace LibcMath.Core

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

/-! ## `Frac64` (`src/__support/frac64.h`) -/

/-- 64-bit unsigned fractional number (`LSB = 2^-64`), matching `LIBC_NAMESPACE::Frac64`. -/
structure Frac64 where
  val : BitVec 64
  deriving DecidableEq, Repr, Inhabited

namespace Frac64

@[inline, simp, grind] def ofBits (v : BitVec 64) : Frac64 := ⟨v⟩
@[inline, simp, grind] def toBits (x : Frac64) : BitVec 64 := x.val
@[inline, simp, grind] def add (a b : Frac64) : Frac64 := ⟨a.val + b.val⟩
@[inline, simp, grind] def sub (a b : Frac64) : Frac64 := ⟨a.val - b.val⟩
@[inline, simp, grind] def bnot (a : Frac64) : Frac64 := ⟨~~~a.val⟩
@[inline, simp, grind] def shl (a : Frac64) (s : Nat) : Frac64 := ⟨a.val <<< s⟩
@[inline, simp, grind] def shr (a : Frac64) (s : Nat) : Frac64 := ⟨a.val >>> s⟩

/-- Upper 64 bits of the 64×64→128 unsigned product (`LIBC_TYPES_HAS_INT128`). -/
@[inline] def mulHi128 (a b : Frac64) : Frac64 :=
  ⟨((a.val.zeroExtend 128 * b.val.zeroExtend 128) >>> 64).truncate 64⟩

/-- Three-halfword approximate high product (`!LIBC_TYPES_HAS_INT128`, `big_int.h:263-275`). -/
@[inline] def mulHiSplit32 (a b : Frac64) : Frac64 :=
  let mask : BitVec 64 := 0x00000000FFFFFFFF#64
  let aLo := a.val &&& mask
  let aHi := a.val >>> 32
  let bLo := b.val &&& mask
  let bHi := b.val >>> 32
  let t1 := aHi * bLo
  let t2 := aLo * bHi + (t1 &&& mask)
  ⟨aHi * bHi + (t1 >>> 32) + (t2 >>> 32)⟩

/-- `Frac64::operator*`: selects exact 128-bit `mulHi128` vs 32-bit split `mulHiSplit32`
according to `cfg.hasInt128`. -/
@[inline] def mul (cfg : MathConfig := {}) (a b : Frac64) : Frac64 :=
  if cfg.hasInt128 then mulHi128 a b else mulHiSplit32 a b

instance : Add Frac64 := ⟨add⟩
instance : Sub Frac64 := ⟨sub⟩
instance : HMul Frac64 Frac64 Frac64 := ⟨mulHi128⟩
instance : Complement Frac64 := ⟨bnot⟩
instance : HShiftLeft Frac64 Nat Frac64 := ⟨shl⟩
instance : HShiftRight Frac64 Nat Frac64 := ⟨shr⟩

@[simp, grind =] theorem add_val (a b : Frac64) : (a + b).val = a.val + b.val := rfl
@[simp, grind =] theorem sub_val (a b : Frac64) : (a - b).val = a.val - b.val := rfl

end Frac64

/-! ## `NumberPair` / `DoubleDouble` / `FloatFloat` (`src/__support/FPUtil/double_double.h`) -/

/-- Two-component floating-point expansion `lo + hi`, matching `LIBC_NAMESPACE::NumberPair<T>`.
Field order matches C++ `{lo, hi}`. -/
structure NumberPair (α : Type) where
  lo : α
  hi : α
  deriving DecidableEq, Repr, Inhabited

abbrev DoubleDouble := NumberPair (Model .binary64)
abbrev FloatFloat := NumberPair (Model .binary32)

namespace NumberPair

variable {fmt : FloatFormat}

/-- `fputil::exact_add<FAST2SUM>(a, b)`: Dekker's FastTwoSum (`fast2sum = true`) or
Knuth's TwoSum (`fast2sum = false`). -/
def exactAdd (mode : IEEERoundingMode) (a b : Model fmt) (fast2sum : Bool := true) :
    NumberPair (Model fmt) :=
  if fast2sum then
    let hi := Model.add a b mode
    let t := Model.sub hi a mode
    let lo := Model.sub b t mode
    { lo, hi }
  else
    let hi := Model.add a b mode
    let t1 := Model.sub hi a mode
    let t2 := Model.sub hi t1 mode
    let t3 := Model.sub b t1 mode
    let t4 := Model.sub a t2 mode
    { lo := Model.add t3 t4 mode, hi }

/-- `fputil::exact_sub<FAST2SUM>(a, b)`. -/
def exactSub (mode : IEEERoundingMode) (a b : Model fmt) (fast2sum : Bool := true) :
    NumberPair (Model fmt) :=
  if fast2sum then
    let hi := Model.sub a b mode
    let t := Model.sub a hi mode
    let lo := Model.sub t b mode
    { lo, hi }
  else
    let hi := Model.sub a b mode
    let t1 := Model.sub hi a mode
    let t2 := Model.sub hi t1 mode
    let t3 := Model.sub a t2 mode
    let t4 := Model.add b t1 mode
    { lo := Model.sub t3 t4 mode, hi }

/-- `fputil::add(a, b)` for two `NumberPair`s. -/
def add (mode : IEEERoundingMode) (a b : NumberPair (Model fmt))
    (fast2sum : Bool := true) : NumberPair (Model fmt) :=
  let r := exactAdd mode a.hi b.hi fast2sum
  let lo := Model.add a.lo b.lo mode
  let rLo := Model.add r.lo lo mode
  exactAdd mode r.hi rLo fast2sum

/-- `fputil::add(a, b)` for `NumberPair` + scalar. -/
def addScalar (mode : IEEERoundingMode) (a : NumberPair (Model fmt)) (b : Model fmt)
    (fast2sum : Bool := true) : NumberPair (Model fmt) :=
  let r := exactAdd mode a.hi b fast2sum
  let rLo := Model.add r.lo a.lo mode
  exactAdd mode r.hi rLo fast2sum

/-- `fputil::add(a, b)` for scalar + `NumberPair`. -/
def scalarAdd (mode : IEEERoundingMode) (a : Model fmt) (b : NumberPair (Model fmt))
    (fast2sum : Bool := true) : NumberPair (Model fmt) :=
  let r := exactAdd mode a b.hi fast2sum
  let rLo := Model.add r.lo b.lo mode
  exactAdd mode r.hi rLo fast2sum

/-- `fputil::sub(a, b)` for two `NumberPair`s. -/
def sub (mode : IEEERoundingMode) (a b : NumberPair (Model fmt))
    (fast2sum : Bool := true) : NumberPair (Model fmt) :=
  let r := exactSub mode a.hi b.hi fast2sum
  let lo := Model.sub a.lo b.lo mode
  let rLo := Model.add r.lo lo mode
  exactAdd mode r.hi rLo fast2sum

/-- Default Veltkamp split exponent (`12` for `binary32`, `27` for `binary64`). -/
@[inline] def defaultSplit (fmt : FloatFormat) : Nat :=
  (fmt.fracWidth + 2) / 2

/-- Veltkamp's splitting (`fputil::split`). -/
def split (mode : IEEERoundingMode) (a : Model fmt)
    (splitBits : Nat := defaultSplit fmt) : NumberPair (Model fmt) :=
  let cn : Model fmt := Model.ofFields fmt false (fmt.exponentBias + splitBits) 0
  let c := Model.add cn (Model.posOne fmt) mode
  let t1 := Model.mul c a mode
  let t2 := Model.sub a t1 mode
  let hi := Model.add t1 t2 mode
  let lo := Model.sub a hi mode
  { lo, hi }

/-- `fputil::exact_mult(a, b)`: FMA TwoProd when `cfg.hasFma fmt`, else Dekker's product. -/
def exactMult (cfg : MathConfig) (mode : IEEERoundingMode) (a b : Model fmt)
    (splitBits : Nat := defaultSplit fmt) : NumberPair (Model fmt) :=
  if cfg.hasFma fmt then
    let hi := Model.mul a b mode
    let lo := multiplySub cfg mode a b hi
    { lo, hi }
  else
    let as := split mode a splitBits
    let bs := split mode b splitBits
    let hi := Model.mul a b mode
    let t1 := Model.sub (Model.mul as.hi bs.hi mode) hi mode
    let t2 := Model.add (Model.mul as.hi bs.lo mode) t1 mode
    let t3 := Model.add (Model.mul as.lo bs.hi mode) t2 mode
    let lo := Model.add (Model.mul as.lo bs.lo mode) t3 mode
    { lo, hi }

/-- `fputil::quick_mult(a, b)` for scalar `a` and `NumberPair` `b`. -/
def quickMultScalar (cfg : MathConfig) (mode : IEEERoundingMode)
    (a : Model fmt) (b : NumberPair (Model fmt)) : NumberPair (Model fmt) :=
  let r := exactMult cfg mode a b.hi
  { lo := multiplyAdd cfg mode a b.lo r.lo, hi := r.hi }

/-- `fputil::quick_mult(a, b)` for two `NumberPair`s. -/
def quickMult (cfg : MathConfig) (mode : IEEERoundingMode)
    (a b : NumberPair (Model fmt)) (splitBits : Nat := defaultSplit fmt) :
    NumberPair (Model fmt) :=
  let r := exactMult cfg mode a.hi b.hi splitBits
  let t1 := multiplyAdd cfg mode a.hi b.lo r.lo
  let t2 := multiplyAdd cfg mode a.lo b.hi t1
  { lo := t2, hi := r.hi }

/-- `fputil::div(a, b)` (Karp–Markstein division, `double_double.h:285-304`). -/
def div (cfg : MathConfig) (mode : IEEERoundingMode)
    (a b : NumberPair (Model fmt)) : NumberPair (Model fmt) :=
  let q := Model.div (Model.posOne fmt) b.hi mode
  let hi := Model.mul a.hi q mode
  let (eHi, eLo) :=
    if cfg.hasFma fmt then
      (subMultiply cfg mode a.hi b.hi hi, subMultiply cfg mode a.lo b.lo hi)
    else
      let pHi := exactMult cfg mode b.hi (Model.neg hi)
      let pLo := exactMult cfg mode b.lo (Model.neg hi)
      (Model.add (Model.add a.hi pHi.hi mode) pHi.lo mode,
       Model.add (Model.add a.lo pLo.hi mode) pLo.lo mode)
  { lo := Model.mul q (Model.add eHi eLo mode) mode, hi }

end NumberPair

/-! ## `TripleDouble` (`src/__support/FPUtil/triple_double.h`) -/

/-- Three-component floating-point expansion `lo + mid + hi`. -/
structure TripleDouble where
  lo : Model .binary64
  mid : Model .binary64
  hi : Model .binary64
  deriving DecidableEq, Inhabited

/-! ## `DyadicFloat` (`src/__support/FPUtil/dyadic_float.h`) -/

/-- Fixed-precision dyadic float `(-1)^sign * mantissa * 2^exponent` matching
`fputil::DyadicFloat<Bits>`. -/
structure DyadicFloat (bits : Nat) where
  sign : Sign := .pos
  exponent : Int := 0
  mantissa : BitVec bits := 0
  deriving DecidableEq, Repr, Inhabited

namespace DyadicFloat

/-- Normalize so the MSB of `mantissa` is 1 (if nonzero), decrementing `exponent`. -/
def normalize {bits : Nat} (x : DyadicFloat bits) : DyadicFloat bits :=
  if x.mantissa == 0 then
    { x with exponent := 0 }
  else
    let lz := x.mantissa.clz.toNat
    { x with
      exponent := x.exponent - Int.ofNat lz
      mantissa := x.mantissa <<< lz }

/-- Convert a finite binary interchange float into a normalized `DyadicFloat bits`. -/
def ofFloat {fmt : FloatFormat} (bits : Nat) (x : Model fmt) : DyadicFloat bits :=
  let sign := Sign.ofBool x.signBit
  if x.isZero then
    { sign, exponent := 0, mantissa := 0 }
  else if x.expField == 0 then
    let exp : Int := 1 - Int.ofNat fmt.exponentBias - Int.ofNat fmt.fracWidth
    normalize { sign, exponent := exp, mantissa := BitVec.ofNat bits x.fracField }
  else
    let exp : Int := Int.ofNat x.expField - Int.ofNat fmt.exponentBias - Int.ofNat fmt.fracWidth
    let mant := (1 <<< fmt.fracWidth) ||| x.fracField
    normalize { sign, exponent := exp, mantissa := BitVec.ofNat bits mant }

/-- `DyadicFloat::quick_add` (normalized addition of two `DyadicFloat bits`). -/
def quickAdd {bits : Nat} (a b : DyadicFloat bits) : DyadicFloat bits :=
  if a.mantissa == 0 then b
  else if b.mantissa == 0 then a
  else
    let (hi, lo) := if a.exponent ≥ b.exponent then (a, b) else (b, a)
    let expDiff := (hi.exponent - lo.exponent).toNat
    if expDiff ≥ bits then hi
    else if hi.sign == lo.sign then
      let sum : BitVec (bits + 1) :=
        hi.mantissa.zeroExtend (bits + 1) + (lo.mantissa >>> expDiff).zeroExtend (bits + 1)
      if sum.msb then
        { sign := hi.sign, exponent := hi.exponent + 1, mantissa := (sum >>> 1).truncate bits }
      else
        { sign := hi.sign, exponent := hi.exponent, mantissa := sum.truncate bits }
    else
      let loShifted := lo.mantissa >>> expDiff
      if hi.mantissa ≥ loShifted then
        normalize { sign := hi.sign, exponent := hi.exponent, mantissa := hi.mantissa - loShifted }
      else
        normalize { sign := lo.sign, exponent := hi.exponent, mantissa := loShifted - hi.mantissa }

/-- `DyadicFloat::quick_mul`: multiplies mantissas using the upper `bits` of the `2*bits` product.
-/
def quickMul {bits : Nat} (a b : DyadicFloat bits) : DyadicFloat bits :=
  let prod : BitVec (2 * bits) :=
    a.mantissa.zeroExtend (2 * bits) * b.mantissa.zeroExtend (2 * bits)
  normalize {
    sign := a.sign.mul b.sign
    exponent := a.exponent + b.exponent + Int.ofNat bits
    mantissa := (prod >>> bits).truncate bits
  }

/-- Convert a `DyadicFloat` to an IEEE `Model fmt` using FloatLib's exact dyadic rounder. -/
def asFloat {bits : Nat} (fmt : FloatFormat) (mode : IEEERoundingMode) (x : DyadicFloat bits) :
    Model fmt :=
  let exact : FloatLib.Numerics.Dyadic :=
    { negative := x.sign.isNeg
      significand := x.mantissa.toNat
      exponent := x.exponent }
  if x.mantissa == 0 then
    Model.zero fmt x.sign.isNeg
  else
    Model.Internal.Directed.roundDyadic fmt mode exact

end DyadicFloat

/-! ## `ExceptValues` (`src/__support/FPUtil/except_value_utils.h`) -/

/-- One row of `fputil::ExceptValues<T, N>::Mapping`. -/
structure ExceptMapping (fmt : FloatFormat) where
  input : BitVec fmt.bitWidth
  rndTowardZero : BitVec fmt.bitWidth
  rndUpwardOffset : BitVec fmt.bitWidth
  rndDownwardOffset : BitVec fmt.bitWidth
  rndToNearestOffset : BitVec fmt.bitWidth
  deriving DecidableEq, Repr, Inhabited

/-- Table of hard-to-round exceptional inputs (`fputil::ExceptValues<T, N>`). -/
abbrev ExceptValues (fmt : FloatFormat) := Array (ExceptMapping fmt)

namespace ExceptValues

/-- `ExceptValues::lookup(x_bits)`. -/
def lookup {fmt : FloatFormat} (cfg : MathConfig) (mode : IEEERoundingMode)
    (table : ExceptValues fmt) (xBits : BitVec fmt.bitWidth) : Option (Model fmt) :=
  (table.find? fun m => m.input == xBits).map fun m =>
    let offset :=
      if cfg.assumeRoundNearestOnly then m.rndToNearestOffset
      else match mode with
        | .up => m.rndUpwardOffset
        | .down => m.rndDownwardOffset
        | .nearest => m.rndToNearestOffset
        | _ => 0
    Model.ofBits (m.rndTowardZero + offset)

/-- `ExceptValues::lookup_odd(x_abs, sign)`. -/
def lookupOdd {fmt : FloatFormat} (cfg : MathConfig) (mode : IEEERoundingMode)
    (table : ExceptValues fmt) (xAbs : BitVec fmt.bitWidth) (isNeg : Bool) : Option (Model fmt) :=
  (table.find? fun m => m.input == xAbs).map fun m =>
    let offset :=
      if cfg.assumeRoundNearestOnly then m.rndToNearestOffset
      else match mode with
        | .up => if isNeg then m.rndDownwardOffset else m.rndUpwardOffset
        | .down => if isNeg then m.rndUpwardOffset else m.rndDownwardOffset
        | .nearest => m.rndToNearestOffset
        | _ => 0
    let res := Model.ofBits (m.rndTowardZero + offset)
    if isNeg then Model.neg res else res

end ExceptValues

end LibcMath.Core
