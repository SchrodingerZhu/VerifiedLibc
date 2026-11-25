import LibcMath.Libc.Ops

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

namespace LibcMath.Libc

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
    let hi := fadd mode a b
    let t := fsub mode hi a
    let lo := fsub mode b t
    { lo, hi }
  else
    let hi := fadd mode a b
    let t1 := fsub mode hi a
    let t2 := fsub mode hi t1
    let t3 := fsub mode b t1
    let t4 := fsub mode a t2
    { lo := fadd mode t3 t4, hi }

/-- `fputil::exact_sub<FAST2SUM>(a, b)`. -/
def exactSub (mode : IEEERoundingMode) (a b : Model fmt) (fast2sum : Bool := true) :
    NumberPair (Model fmt) :=
  if fast2sum then
    let hi := fsub mode a b
    let t := fsub mode a hi
    let lo := fsub mode t b
    { lo, hi }
  else
    let hi := fsub mode a b
    let t1 := fsub mode hi a
    let t2 := fsub mode hi t1
    let t3 := fsub mode a t2
    let t4 := fadd mode b t1
    { lo := fsub mode t3 t4, hi }

/-- `fputil::add(a, b)` for two `NumberPair`s. -/
def add (mode : IEEERoundingMode) (a b : NumberPair (Model fmt))
    (fast2sum : Bool := true) : NumberPair (Model fmt) :=
  let r := exactAdd mode a.hi b.hi fast2sum
  let lo := fadd mode a.lo b.lo
  let rLo := fadd mode r.lo lo
  exactAdd mode r.hi rLo fast2sum

/-- `fputil::add(a, b)` for `NumberPair` + scalar. -/
def addScalar (mode : IEEERoundingMode) (a : NumberPair (Model fmt)) (b : Model fmt)
    (fast2sum : Bool := true) : NumberPair (Model fmt) :=
  let r := exactAdd mode a.hi b fast2sum
  let rLo := fadd mode r.lo a.lo
  exactAdd mode r.hi rLo fast2sum

/-- `fputil::add(a, b)` for scalar + `NumberPair`. -/
def scalarAdd (mode : IEEERoundingMode) (a : Model fmt) (b : NumberPair (Model fmt))
    (fast2sum : Bool := true) : NumberPair (Model fmt) :=
  let r := exactAdd mode a b.hi fast2sum
  let rLo := fadd mode r.lo b.lo
  exactAdd mode r.hi rLo fast2sum

/-- `fputil::sub(a, b)` for two `NumberPair`s. -/
def sub (mode : IEEERoundingMode) (a b : NumberPair (Model fmt))
    (fast2sum : Bool := true) : NumberPair (Model fmt) :=
  let r := exactSub mode a.hi b.hi fast2sum
  let lo := fsub mode a.lo b.lo
  let rLo := fadd mode r.lo lo
  exactAdd mode r.hi rLo fast2sum

/-- `fputil::sub(a, b)` for `NumberPair` minus scalar (`double_double.h:130-134`). -/
def subScalar (mode : IEEERoundingMode) (a : NumberPair (Model fmt)) (b : Model fmt)
    (fast2sum : Bool := true) : NumberPair (Model fmt) :=
  let r := exactSub mode a.hi b fast2sum
  let rLo := fadd mode r.lo a.lo
  exactAdd mode r.hi rLo fast2sum

/-- `fputil::sub(a, b)` for scalar minus `NumberPair` (`double_double.h:138-142`). -/
def scalarSub (mode : IEEERoundingMode) (a : Model fmt) (b : NumberPair (Model fmt))
    (fast2sum : Bool := true) : NumberPair (Model fmt) :=
  let r := exactSub mode a b.hi fast2sum
  let rLo := fsub mode r.lo b.lo
  exactAdd mode r.hi rLo fast2sum

/-- Default Veltkamp split exponent (`12` for `binary32`, `27` for `binary64`). -/
@[inline] def defaultSplit (fmt : FloatFormat) : Nat :=
  (fmt.fracWidth + 2) / 2

/-- Veltkamp's splitting (`fputil::split`). -/
def split (mode : IEEERoundingMode) (a : Model fmt)
    (splitBits : Nat := defaultSplit fmt) : NumberPair (Model fmt) :=
  let cn : Model fmt := Model.ofFields fmt false (fmt.exponentBias + splitBits) 0
  let c := fadd mode cn (Model.posOne fmt)
  let t1 := fmul mode c a
  let t2 := fsub mode a t1
  let hi := fadd mode t1 t2
  let lo := fsub mode a hi
  { lo, hi }

/-- Non-FMA 3-argument `fputil::exact_mult<T, SPLIT_B>(as, a, b)` where `as = split(a)`
(`double_double.h:164-176`). -/
def exactMultPresplit (mode : IEEERoundingMode) (as : NumberPair (Model fmt))
    (a b : Model fmt) (splitBits : Nat := defaultSplit fmt) : NumberPair (Model fmt) :=
  let bs := split mode b splitBits
  let hi := fmul mode a b
  let t1 := fsub mode (fmul mode as.hi bs.hi) hi
  let t2 := fadd mode (fmul mode as.hi bs.lo) t1
  let t3 := fadd mode (fmul mode as.lo bs.hi) t2
  let lo := fadd mode (fmul mode as.lo bs.lo) t3
  { lo, hi }

/-- `fputil::exact_mult<T, SPLIT_B>(a, b)`: FMA TwoProd when `cfg.hasFma fmt` is `true`,
else Dekker's product splitting `a` by `defaultSplit fmt` and `b` by `splitBits`
(`double_double.h:205-224`). -/
def exactMult (cfg : MathConfig) (mode : IEEERoundingMode) (a b : Model fmt)
    (splitBits : Nat := defaultSplit fmt) : NumberPair (Model fmt) :=
  if cfg.hasFma fmt then
    let hi := fmul mode a b
    let lo := multiplySub cfg mode a b hi
    { lo, hi }
  else
    let as := split mode a (defaultSplit fmt)
    exactMultPresplit mode as a b splitBits

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

/-- `fputil::div(a, b)` (Karp–Markstein division, `double_double.h:285-304`).
Dispatches on coarse `LIBC_TARGET_CPU_HAS_FMA` (`cfg.hasAnyFma`). -/
def div (cfg : MathConfig) (mode : IEEERoundingMode)
    (a b : NumberPair (Model fmt)) : NumberPair (Model fmt) :=
  let q := fdiv mode (Model.posOne fmt) b.hi
  let hi := fmul mode a.hi q
  let (eHi, eLo) :=
    if cfg.hasAnyFma then
      (subMultiply cfg mode a.hi b.hi hi, subMultiply cfg mode a.lo b.lo hi)
    else
      let pHi := exactMult cfg mode b.hi (Model.neg hi)
      let pLo := exactMult cfg mode b.lo (Model.neg hi)
      (fadd mode (fadd mode a.hi pHi.hi) pHi.lo,
       fadd mode (fadd mode a.lo pLo.hi) pLo.lo)
  { lo := fmul mode q (fadd mode eHi eLo), hi }

end NumberPair

/-! ## `TripleDouble` (`src/__support/FPUtil/triple_double.h`) -/

/-- Three-component floating-point expansion `lo + mid + hi`. -/
structure TripleDouble where
  lo : Model .binary64
  mid : Model .binary64
  hi : Model .binary64
  deriving DecidableEq, Inhabited

/-! ## Multi-limb `BigInt` helpers (`src/__support/big_int.h`) -/

namespace BigInt

/-- Extracts the `idx`-th 64-bit little-endian limb from a bit vector. -/
@[inline] def limb64 {bits : Nat} (x : BitVec bits) (idx : Nat) : Nat :=
  (x.toNat >>> (64 * idx)) &&& ((1 <<< 64) - 1)

/-- Faithful model of `UInt<Bits>::quick_mul_hi` (`src/__support/big_int.h:244-291, 670-700`).

For 64-bit words (`bits = 64`):
* uses exact 128-bit upper half when `cfg.hasInt128` is `true`,
* uses 3-halfword 32-bit split (`Frac64.mulHiSplit32`) when `cfg.hasInt128` is `false`.

For `N ≥ 2` 64-bit limbs (`bits = 64 * N`): sums only partial products `lhs[j] * rhs[k]` with
`j + k ≥ N - 1` and shifts right by `bits`, omitting all lower partial products `j + k < N - 1`.
This produces error in `[0, N - 1]` ULPs relative to `(a * b) >>> bits`. -/
def quickMulHi (cfg : MathConfig := {}) {bits : Nat} (a b : BitVec bits) : BitVec bits :=
  if h64 : bits = 64 then
    let a64 : BitVec 64 := BitVec.cast h64 a
    let b64 : BitVec 64 := BitVec.cast h64 b
    BitVec.cast h64.symm (Frac64.mul cfg ⟨a64⟩ ⟨b64⟩).val
  else if bits > 64 && bits % 64 == 0 then
    let n := bits / 64
    let sum : Nat :=
      (List.range n).foldl (init := 0) fun acc j =>
        let lj := limb64 a j
        (List.range n).foldl (init := acc) fun acc2 k =>
          if j + k ≥ n - 1 then
            acc2 + ((lj * limb64 b k) <<< (64 * (j + k)))
          else
            acc2
    BitVec.ofNat bits (sum >>> bits)
  else
    ((a.zeroExtend (2 * bits) * b.zeroExtend (2 * bits)) >>> bits).truncate bits

/-- `BigInt::is_zero`. -/
@[inline, simp, grind] def isZero {bits : Nat} (a : BitVec bits) : Bool := a == 0

/-- `BigInt::get_bit`. -/
@[inline, simp, grind] def getBit {bits : Nat} (a : BitVec bits) (i : Nat) : Bool :=
  a.getLsbD i

/-- `BigInt::set_bit`. -/
@[inline, simp, grind] def setBit {bits : Nat} (a : BitVec bits) (i : Nat) : BitVec bits :=
  a ||| (1#bits <<< i)

/-- `BigInt::add_overflow`: returns `(a + b, carryOut)`. -/
@[inline] def addOverflow {bits : Nat} (a b : BitVec bits) : BitVec bits × Bool :=
  (a + b, BitVec.uaddOverflow a b)

/-- Constructs a `BitVec bits` from an array of 64-bit little-endian limbs (`UInt<N>{w0, w1, ...}`).
-/
def ofLimbs64 (bits : Nat) (limbs : List (BitVec 64)) : BitVec bits :=
  let n := (limbs.zipIdx).foldl (init := 0) fun acc (w, idx) =>
    acc ||| (w.toNat <<< (64 * idx))
  BitVec.ofNat bits n

end BigInt

/-! ## `DyadicFloat` (`src/__support/FPUtil/dyadic_float.h`) -/

/-- Fixed-precision dyadic float `(-1)^sign * mantissa * 2^exponent` matching
`fputil::DyadicFloat<Bits>`. -/
structure DyadicFloat (bits : Nat) where
  sign : Sign := .pos
  exponent : Int := 0
  mantissa : BitVec bits := 0
  deriving DecidableEq, Repr, Inhabited

namespace DyadicFloat

/-- Default zero `DyadicFloat()` (`sign = pos`, `exponent = 0`, `mantissa = 0`). -/
@[inline, simp, grind] def zero (bits : Nat) : DyadicFloat bits := {}

/-- Shifts mantissa left and decrements exponent (`DyadicFloat::shift_left`). -/
def shiftLeft {bits : Nat} (x : DyadicFloat bits) (s : Nat) : DyadicFloat bits :=
  { x with
    exponent := x.exponent - Int.ofNat s
    mantissa := if s < bits then x.mantissa <<< s else 0 }

/-- Shifts mantissa right and increments exponent (`DyadicFloat::shift_right`). -/
def shiftRight {bits : Nat} (x : DyadicFloat bits) (s : Nat) : DyadicFloat bits :=
  { x with
    exponent := x.exponent + Int.ofNat s
    mantissa := if s < bits then x.mantissa >>> s else 0 }

/-- Normalizes so the MSB of `mantissa` is 1 when nonzero, preserving `exponent` on zero
(`dyadic_float.h:131-138`). -/
def normalize {bits : Nat} (x : DyadicFloat bits) : DyadicFloat bits :=
  if x.mantissa == 0 then
    x
  else
    let lz := x.mantissa.clz.toNat
    { x with
      exponent := x.exponent - Int.ofNat lz
      mantissa := x.mantissa <<< lz }

/-- Three-argument normalizing constructor `DyadicFloat(Sign, int, MantissaType)`
(`dyadic_float.h:124-127`). -/
def mkNorm (bits : Nat) (s : Sign) (e : BitVec 32) (m : BitVec bits) : DyadicFloat bits :=
  normalize { sign := s, exponent := e.toInt, mantissa := m }

/-- Negates the sign of a `DyadicFloat` (`operator-`). -/
@[inline, simp, grind] def neg {bits : Nat} (x : DyadicFloat bits) : DyadicFloat bits :=
  { x with sign := x.sign.negate }

instance {bits : Nat} : Neg (DyadicFloat bits) := ⟨neg⟩

/-- Unbiased exponent `exponent + (bits - 1)` for a normalized `DyadicFloat`
(`dyadic_float.h:161-163`). -/
@[inline, simp, grind] def getUnbiasedExponent {bits : Nat} (x : DyadicFloat bits) : BitVec 32 :=
  BitVec.ofInt 32 (x.exponent + Int.ofNat (bits - 1))

/-- Scales exponent by `pow2` (`fputil::mul_pow_2`, `dyadic_float.h:792-797`). -/
@[inline] def mulPow2 {bits : Nat} (x : DyadicFloat bits) (pow2 : BitVec 32) : DyadicFloat bits :=
  { x with exponent := x.exponent + pow2.toInt }

/-- Converts a finite binary interchange float into a normalized `DyadicFloat bits`. -/
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

/-- `DyadicFloat::quick_add` (`dyadic_float.h:581-623`). -/
def quickAdd {bits : Nat} (a b : DyadicFloat bits) : DyadicFloat bits :=
  if a.mantissa == 0 then b
  else if b.mantissa == 0 then a
  else
    let (a, b) :=
      if a.exponent > b.exponent then
        (a, b.shiftRight (a.exponent - b.exponent).toNat)
      else if b.exponent > a.exponent then
        (a.shiftRight (b.exponent - a.exponent).toNat, b)
      else
        (a, b)
    if a.sign == b.sign then
      let sum : BitVec (bits + 1) :=
        a.mantissa.zeroExtend (bits + 1) + b.mantissa.zeroExtend (bits + 1)
      if sum.msb then
        { sign := a.sign, exponent := a.exponent + 1, mantissa := (sum >>> 1).truncate bits }
      else
        { sign := a.sign, exponent := a.exponent, mantissa := sum.truncate bits }
    else
      if a.mantissa ≥ b.mantissa then
        normalize { sign := a.sign, exponent := a.exponent, mantissa := a.mantissa - b.mantissa }
      else
        normalize { sign := b.sign, exponent := b.exponent, mantissa := b.mantissa - a.mantissa }

/-- `DyadicFloat::quick_sub` (`dyadic_float.h:626-629`). -/
def quickSub {bits : Nat} (a b : DyadicFloat bits) : DyadicFloat bits :=
  quickAdd a (neg b)

/-- Faithful `DyadicFloat::quick_mul` (`dyadic_float.h:642-660`).
Uses `BigInt.quickMulHi` and shifts left by at most one bit rather than full `clz`. -/
def quickMul (cfg : MathConfig := {}) {bits : Nat} (a b : DyadicFloat bits) : DyadicFloat bits :=
  let sign := a.sign.mul b.sign
  let exp := a.exponent + b.exponent + Int.ofNat bits
  if a.mantissa == 0 || b.mantissa == 0 then
    { sign, exponent := exp, mantissa := 0 }
  else
    let m := BigInt.quickMulHi cfg a.mantissa b.mantissa
    let r : DyadicFloat bits := { sign, exponent := exp, mantissa := m }
    if m.msb then r else r.shiftLeft 1

/-- Rounds a wide mantissa right by `rshift` bits in `mode` (`DyadicFloat::round`,
`dyadic_float.h:168-184`). -/
def round {mBits : Nat} (bits : Nat) (cfg : MathConfig) (mode : IEEERoundingMode)
    (s : Sign) (exp : Int) (m : BitVec mBits) (rshift : Nat) : DyadicFloat bits :=
  let shifted := (m >>> rshift).truncate bits
  let roundUp :=
    if rshift == 0 then false
    else
      let roundBit := m.getLsbD (rshift - 1)
      let stickyMask : BitVec mBits := (1#mBits <<< (rshift - 1)) - 1#mBits
      let sticky := (m &&& stickyMask) != 0
      let effMode := if cfg.assumeRoundNearestOnly then .nearest else mode
      match effMode with
      | .nearest => roundBit && (shifted.getLsbD 0 || sticky)
      | .up => s.isPos && (roundBit || sticky)
      | .down => s.isNeg && (roundBit || sticky)
      | _ => false
  if roundUp then
    let inc := shifted + 1#bits
    if inc == 0 then
      normalize { sign := s, exponent := exp + 1, mantissa := 1#bits <<< (bits - 1) }
    else
      normalize { sign := s, exponent := exp, mantissa := inc }
  else
    normalize { sign := s, exponent := exp, mantissa := shifted }

/-- `fputil::rounded_mul` (`dyadic_float.h:665-678`). -/
def roundedMul (cfg : MathConfig) (mode : IEEERoundingMode) {bits : Nat}
    (a b : DyadicFloat bits) : DyadicFloat bits :=
  let sign := a.sign.mul b.sign
  let exp := a.exponent + b.exponent + Int.ofNat bits
  let prod : BitVec (2 * bits) :=
    a.mantissa.zeroExtend (2 * bits) * b.mantissa.zeroExtend (2 * bits)
  let (prod, exp) :=
    if prod.msb then (prod, exp) else (prod <<< 1, exp - 1)
  round bits cfg mode sign exp prod bits

/-- `fputil::approx_reciprocal` (`dyadic_float.h:684-713`): Newton–Raphson via `quickMul`. -/
def approxReciprocal (cfg : MathConfig := {}) {bits : Nat} (a : DyadicFloat bits) :
    DyadicFloat bits :=
  let top32 := (a.mantissa >>> (bits - 32)).toNat
  let initMant : Nat := if top32 == 0 then 0 else 0xFFFFFFFFFFFFFFFF / top32
  let x0 : DyadicFloat bits :=
    normalize {
      sign := .pos
      exponent := -32 - a.exponent - Int.ofNat bits
      mantissa := BitVec.ofNat bits initMant
    }
  let two : DyadicFloat bits := normalize { sign := .pos, exponent := 1, mantissa := 1#bits }
  let rec loop (fuel okBits : Nat) (x : DyadicFloat bits) : DyadicFloat bits :=
    match fuel with
    | 0 => x
    | fuel' + 1 =>
        if okBits ≥ bits then x
        else
          let x' := quickMul cfg x (quickSub two (quickMul cfg a x))
          loop fuel' (2 * okBits - 1) x'
  loop 16 31 x0

/-- `fputil::pow_n` (`dyadic_float.h:776-789`): repeated squaring with `quickMul`. -/
def powN (cfg : MathConfig := {}) {bits : Nat} (a : DyadicFloat bits) (power : BitVec 32) :
    DyadicFloat bits :=
  let one : DyadicFloat bits := normalize { sign := .pos, exponent := 0, mantissa := 1#bits }
  let rec loop (fuel : Nat) (p : Nat) (res cur : DyadicFloat bits) : DyadicFloat bits :=
    match fuel with
    | 0 => res
    | fuel' + 1 =>
        if p == 0 then res
        else
          let res' := if p % 2 == 1 then quickMul cfg res cur else res
          loop fuel' (p >>> 1) res' (quickMul cfg cur cur)
  loop 32 power.toNat one a

/-- `DyadicFloat::generic_as<T>` (`dyadic_float.h:191-333`): rounds via FloatLib's exact dyadic
rounder in `.nearest` when `cfg.assumeRoundNearestOnly` is `true`, otherwise in `mode`. -/
def genericAs {bits : Nat} (cfg : MathConfig) (fmt : FloatFormat) (mode : IEEERoundingMode)
    (x : DyadicFloat bits) : Model fmt :=
  if x.mantissa == 0 then
    Model.zero fmt x.sign.isNeg
  else
    let exact : FloatLib.Numerics.Dyadic :=
      { negative := x.sign.isNeg
        significand := x.mantissa.toNat
        exponent := x.exponent }
    let effMode := if cfg.assumeRoundNearestOnly then .nearest else mode
    Model.Internal.Directed.roundDyadic fmt effMode exact

/-- `DyadicFloat::fast_as<T>` (`dyadic_float.h:339-469`): hardware-FPU rounding path for
`binary32` and `binary64`. Uses dynamic `mode` on finite results via `multiplyAdd`, and
dispatches overflow by `cfg.noExcept`, `cfg.assumeRoundNearestOnly`, and `cfg.hasHwFpu fmt`. -/
def fastAs {bits : Nat} (cfg : MathConfig) (fmt : FloatFormat) (mode : IEEERoundingMode)
    (x : DyadicFloat bits) : Model fmt :=
  if x.mantissa == 0 then
    Model.zero fmt x.sign.isNeg
  else
    let prec : Nat := fmt.fracWidth + 1
    let expHi0 : Int := x.exponent + Int.ofNat ((bits - 1) + fmt.exponentBias)
    if expHi0 > Int.ofNat (2 * fmt.exponentBias) then
      if cfg.noExcept && cfg.assumeRoundNearestOnly then
        FPBits.inf fmt x.sign
      else if cfg.hasHwFpu fmt then
        setOverflow { cfg with assumeRoundNearestOnly := false } mode x.sign
      else
        setOverflow cfg mode x.sign
    else
      let (denorm, shift, expHi) :=
        if expHi0 ≤ 0 then
          (true, (bits - prec) + (1 - expHi0).toNat, Int.ofNat fmt.exponentBias)
        else
          (false, bits - prec, expHi0)
      let expLo : Int := expHi - Int.ofNat prec - 1
      let mHi : BitVec bits := if shift ≥ bits then 0#bits else x.mantissa >>> shift
      let dHi : Model fmt :=
        Model.ofFields fmt x.sign.isNeg expHi.toNat (mHi.toNat &&& fmt.fracMaskNat)
      let roundBit : Bool :=
        if shift == 0 || shift - 1 ≥ bits then false else x.mantissa.getLsbD (shift - 1)
      let stickyMask : BitVec bits :=
        if shift ≤ 1 then 0#bits
        else if shift - 1 ≥ bits then ~~~0#bits
        else (1#bits <<< (shift - 1)) - 1#bits
      let stickyBit : Bool := (x.mantissa &&& stickyMask) != 0
      let rsNat : Nat := (if roundBit then 2 else 0) + (if stickyBit then 1 else 0)
      let rsF : Model fmt := sitofp fmt mode (BitVec.ofNat 32 rsNat)
      if expLo ≤ 0 then
        let scaleUpExp : Nat := (1 - expLo).toNat
        let scaleUp : Model fmt := Model.ofFields fmt false (fmt.exponentBias + scaleUpExp) 0
        let scaleDown : Model fmt := Model.ofFields fmt false (fmt.exponentBias - scaleUpExp) 0
        let dLo : Model fmt :=
          Model.ofFields fmt x.sign.isNeg (expLo + Int.ofNat scaleUpExp).toNat 0
        fmul mode (multiplyAdd cfg mode dLo rsF (fmul mode dHi scaleUp)) scaleDown
      else
        let dLo : Model fmt := Model.ofFields fmt x.sign.isNeg expLo.toNat 0
        let r : Model fmt := multiplyAdd cfg mode dLo rsF dHi
        if denorm then
          let clearExp : BitVec fmt.bitWidth :=
            BitVec.ofNat fmt.bitWidth (expHi.toNat <<< fmt.fracWidth)
          Model.ofBits (r.toBits - clearExp)
        else
          r

/-- `DyadicFloat::as<T>` (`dyadic_float.h:477-490`): selects `fastAs` for `binary32`/`binary64`
and `genericAs` for `binary16`/`binary128`. -/
def asFloat {bits : Nat} (cfg : MathConfig) (fmt : FloatFormat) (mode : IEEERoundingMode)
    (x : DyadicFloat bits) : Model fmt :=
  if fmt == .binary32 || fmt == .binary64 then
    fastAs cfg fmt mode x
  else
    genericAs cfg fmt mode x

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

end LibcMath.Libc
