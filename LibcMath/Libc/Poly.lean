import LibcMath.Libc.Extended

/-!
# Polynomial evaluation primitives (`src/__support/FPUtil/polyeval.h`)

Mirrors LLVM libc's polynomial evaluation schemes generically across every scalar and
extended-precision type (`Model fmt`, `Frac64`, `DoubleDouble`, `FloatFloat`, `DyadicFloat`):

* `polyeval` / `polyevalList`: Horner's scheme `a₀ + x * (a₁ + ... + x * aₙ)`.
* `altpolyeval` / `altpolyevalList`: alternating Horner's scheme using `subMultiply`.
* `estrin` / `estrinSlice`: right-heavy minimum-depth Estrin binary tree matching
  `fputil::estrin_polyeval<OFFSET>` in `polyeval.h:209-393`.

`polyevalList` recurses structurally on `List α`, so concrete polynomials unfold directly in Lean's
kernel and under `simp` / `grind` without array-bounds overhead.
-/

namespace LibcMath.Libc

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

/-- Types that support `fputil::polyeval`, `altpolyeval`, and `estrin_polyeval`. -/
class PolyElem (α : Type) where
  /-- `multiply_add(x, y, z) = x * y + z`. -/
  madd : MathConfig → IEEERoundingMode → α → α → α → α
  /-- `sub_multiply(x, y, z) = x - y * z`. -/
  subMul : MathConfig → IEEERoundingMode → α → α → α → α
  /-- Squaring / multiplication `x * y` (used by Estrin to form dyadic powers `x^(2^k)`). -/
  pmul : MathConfig → IEEERoundingMode → α → α → α
  /-- Fallback value for an empty coefficient list (never reached for valid libc calls). -/
  zero : α

instance {fmt : FloatFormat} : PolyElem (Model fmt) where
  madd cfg mode x y z := multiplyAdd cfg mode x y z
  subMul cfg mode x y z := subMultiply cfg mode x y z
  pmul _ mode x y := fmul mode x y
  zero := Model.posZero fmt

instance : PolyElem Frac64 where
  madd cfg _ x y z := Frac64.add (Frac64.mul cfg x y) z
  subMul cfg _ x y z := Frac64.sub x (Frac64.mul cfg y z)
  pmul cfg _ x y := Frac64.mul cfg x y
  zero := ⟨0⟩

instance {fmt : FloatFormat} : PolyElem (NumberPair (Model fmt)) where
  madd cfg mode x y z := NumberPair.add mode z (NumberPair.quickMult cfg mode x y)
  subMul cfg mode x y z := NumberPair.sub mode x (NumberPair.quickMult cfg mode y z)
  pmul cfg mode x y := NumberPair.quickMult cfg mode x y
  zero := { lo := Model.posZero fmt, hi := Model.posZero fmt }

instance {bits : Nat} : PolyElem (DyadicFloat bits) where
  madd _ _ x y z := DyadicFloat.quickAdd (DyadicFloat.quickMul x y) z
  subMul _ _ x y z :=
    let prod := DyadicFloat.quickMul y z
    DyadicFloat.quickAdd x { prod with sign := prod.sign.negate }
  pmul _ _ x y := DyadicFloat.quickMul x y
  zero := {}

/-! ## Horner's scheme (`fputil::polyeval` / `fputil::altpolyeval`) -/

/-- Horner evaluation on a coefficient list `[a₀, a₁, …, aₙ]`:
`a₀ + x * (a₁ + … + x * aₙ)`. Matches `fputil::polyeval(x, a0, a1, ..., an)`. -/
def polyevalList {α : Type} [PolyElem α] (cfg : MathConfig) (mode : IEEERoundingMode)
    (x : α) : List α → α
  | [] => PolyElem.zero
  | [a0] => a0
  | a0 :: rest => PolyElem.madd cfg mode x (polyevalList cfg mode x rest) a0

/-- Alternating Horner evaluation on `[a₀, a₁, …, aₙ]`:
`sub_multiply(a₀, x, sub_multiply(a₁, x, …))`. Matches `fputil::altpolyeval`. -/
def altpolyevalList {α : Type} [PolyElem α] (cfg : MathConfig) (mode : IEEERoundingMode)
    (x : α) : List α → α
  | [] => PolyElem.zero
  | [a0] => a0
  | a0 :: rest => PolyElem.subMul cfg mode a0 x (altpolyevalList cfg mode x rest)

/-- Array-backed Horner evaluation starting at `offset` (matches `fputil::polyeval<OFFSET>(x, a)`).
-/
@[inline] def polyeval {α : Type} [PolyElem α] (cfg : MathConfig) (mode : IEEERoundingMode)
    (x : α) (coeffs : Array α) (offset : Nat := 0) : α :=
  polyevalList cfg mode x (coeffs.toList.drop offset)

/-- Array-backed alternating Horner evaluation starting at `offset`. -/
@[inline] def altpolyeval {α : Type} [PolyElem α] (cfg : MathConfig) (mode : IEEERoundingMode)
    (x : α) (coeffs : Array α) (offset : Nat := 0) : α :=
  altpolyevalList cfg mode x (coeffs.toList.drop offset)

@[simp, grind =] theorem polyevalList_singleton {α : Type} [PolyElem α]
    (cfg : MathConfig) (mode : IEEERoundingMode) (x a0 : α) :
    polyevalList cfg mode x [a0] = a0 := rfl

@[simp, grind =] theorem polyevalList_cons_cons {α : Type} [PolyElem α]
    (cfg : MathConfig) (mode : IEEERoundingMode) (x a0 a1 : α) (rest : List α) :
    polyevalList cfg mode x (a0 :: a1 :: rest) =
      PolyElem.madd cfg mode x (polyevalList cfg mode x (a1 :: rest)) a0 := rfl

@[simp, grind =] theorem altpolyevalList_singleton {α : Type} [PolyElem α]
    (cfg : MathConfig) (mode : IEEERoundingMode) (x a0 : α) :
    altpolyevalList cfg mode x [a0] = a0 := rfl

@[simp, grind =] theorem altpolyevalList_cons_cons {α : Type} [PolyElem α]
    (cfg : MathConfig) (mode : IEEERoundingMode) (x a0 a1 : α) (rest : List α) :
    altpolyevalList cfg mode x (a0 :: a1 :: rest) =
      PolyElem.subMul cfg mode a0 x (altpolyevalList cfg mode x (a1 :: rest)) := rfl

/-! ## Right-heavy Estrin's scheme (`fputil::estrin_polyeval`, `polyeval.h:209-393`) -/

/-- Exact mirror of `fputil::internal::estrin_split_log2`:
for `len ≥ 2`, let `2^h < len ≤ 2^(h+1)` and return the smallest `k` with `2^k ≥ len - 2^h`. -/
def estrinSplitLog2 (len : Nat) : Nat :=
  if len ≤ 2 then 0
  else
    let h := Nat.log2 (len - 1)
    let rem := len - (1 <<< h)
    if rem ≤ 1 then 0 else Nat.log2 (rem - 1) + 1

/-- Exact mirror of `fputil::internal::estrin_max_power_log2`:
smallest `k` with `3 * 2^k ≥ len`. -/
def estrinMaxPowerLog2 (len : Nat) : Nat :=
  let rec go (k fuel : Nat) : Nat :=
    match fuel with
    | 0 => k
    | fuel + 1 => if (3 <<< k) < len then go (k + 1) fuel else k
  go 0 len

/-- Precompute dyadic powers `#[x^(2^0), x^(2^1), …, x^(2^maxK)]` by repeated squaring. -/
def estrinPowers {α : Type} [PolyElem α] (cfg : MathConfig) (mode : IEEERoundingMode)
    (x : α) (maxK : Nat) : Array α :=
  let rec go (rem : Nat) (cur : α) (acc : Array α) : Array α :=
    match rem with
    | 0 => acc
    | rem + 1 =>
      let next := PolyElem.pmul cfg mode cur cur
      go rem next (acc.push next)
  go maxK x #[x]

/-- Recursive right-heavy Estrin tree matching `fputil::internal::estrin_eval_tree`. -/
def estrinEvalTree {α : Type} [PolyElem α] [Inhabited α] (cfg : MathConfig)
    (mode : IEEERoundingMode) (pows : Array α) (coeffs : Array α)
    (offset len : Nat) : α :=
  if len == 0 then PolyElem.zero
  else if len == 1 then coeffs[offset]!
  else if len == 2 then PolyElem.madd cfg mode pows[0]! coeffs[offset + 1]! coeffs[offset]!
  else
    let k := estrinSplitLog2 len
    let low := 1 <<< k
    if _h : low < len ∧ 0 < low then
      if low == 1 then
        let hi := estrinEvalTree cfg mode pows coeffs (offset + 1) (len - 1)
        PolyElem.madd cfg mode pows[0]! hi coeffs[offset]!
      else
        let lo := estrinEvalTree cfg mode pows coeffs offset low
        let hi := estrinEvalTree cfg mode pows coeffs (offset + low) (len - low)
        PolyElem.madd cfg mode pows[k]! hi lo
    else
      coeffs[offset]!
termination_by len
decreasing_by
  all_goals first | exact _h.1 | exact Nat.sub_lt (Nat.lt_trans _h.2 _h.1) _h.2 | omega

/-- `fputil::estrin_polyeval<OFFSET>(x, coeffs)`. -/
def estrin {α : Type} [PolyElem α] [Inhabited α] (cfg : MathConfig) (mode : IEEERoundingMode)
    (x : α) (coeffs : Array α) (offset : Nat := 0) : α :=
  let len := coeffs.size - offset
  if len == 0 then PolyElem.zero
  else if len == 1 then coeffs[offset]!
  else
    let maxK := estrinMaxPowerLog2 len
    let pows := estrinPowers cfg mode x maxK
    estrinEvalTree cfg mode pows coeffs offset len

/-- List-based Estrin evaluation (convenient for inline coefficient lists). -/
@[inline] def estrinList {α : Type} [PolyElem α] [Inhabited α] (cfg : MathConfig)
    (mode : IEEERoundingMode) (x : α) (coeffs : List α) : α :=
  estrin cfg mode x coeffs.toArray 0

end LibcMath.Libc
