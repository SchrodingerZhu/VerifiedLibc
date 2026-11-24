import LibcMath.Spec
import Mathlib.Data.List.Chain

/-!
# Properties of all bit patterns in a range

`HoldsOnBits P lo hi` says that `P` holds for the bit patterns `lo, lo + 1, …, hi - 1` of a
format. Such statements for adjacent ranges combine into one for their union
(`HoldsOnBits.append`), and one for the range `[0, 2 ^ fmt.bitWidth)` gives `P` for every value of
the format (`HoldsOnBits.forall`).

Two ranges are adjacent when the upper end of one is syntactically the lower end of the other, so
combining them takes no computation. A proof for a whole format is therefore best assembled as a
balanced tree of `HoldsOnBits.append`, whose leaves may live in different files. For a flat list
of boundaries `b₀, b₁, …, bₙ` there is `HoldsOnBits.of_isChain`; the list does not have to be
sorted, because a range whose ends are out of order is empty and the ranges still chain.

`HoldsOnBits` is unfolded by `grind`, which then settles the arithmetic of the ends: side goals
such as `HoldsOnBits P a c` from statements on `[a, b)` and `[b, c)` are closed by `grind` alone.

## Boolean checks and their diagnostics

`checkBits test first count` evaluates a Boolean test on a block of consecutive bit patterns; it
is the common form of the block checks of `LibcMath.Check.Range`. When such a check is
`false`, `firstFailingBits test first count` evaluates to the first bit pattern that fails
(`firstFailingBits_eq_none_iff`, `firstFailingBits_eq_some`), so a failed block is located with
`#eval` instead of by bisection.
-/

namespace LibcMath

open FloatLib.Floats.Formats.BinaryInterchange

variable {fmt : FloatFormat} {P Q : Model fmt → Prop} {lo mid hi : ℕ}

/-- `P` holds for every bit pattern `n` with `lo ≤ n < hi`. -/
@[grind]
def HoldsOnBits (P : Model fmt → Prop) (lo hi : ℕ) : Prop :=
  ∀ n, lo ≤ n → n < hi → P (.ofNatBits n)

namespace HoldsOnBits

theorem of_forall (h : ∀ x, P x) : HoldsOnBits P lo hi :=
  fun _ _ _ => h _

/-- A range whose ends coincide or are out of order is empty. -/
theorem of_le (h : hi ≤ lo) : HoldsOnBits P lo hi := by
  grind

protected theorem refl (P : Model fmt → Prop) (lo : ℕ) : HoldsOnBits P lo lo :=
  of_le le_rfl

/-- Statements for adjacent ranges combine. -/
theorem append (h₁ : HoldsOnBits P lo mid) (h₂ : HoldsOnBits P mid hi) : HoldsOnBits P lo hi := by
  grind

/-- Adjacent ranges chain in `calc` and in `List.IsChain.pairwise`. -/
instance : Trans (HoldsOnBits P) (HoldsOnBits P) (HoldsOnBits P) :=
  ⟨append⟩

theorem subrange {lo' hi' : ℕ} (h : HoldsOnBits P lo hi) (hlo : lo ≤ lo') (hhi : hi' ≤ hi) :
    HoldsOnBits P lo' hi' := by
  grind

theorem imp (h : HoldsOnBits P lo hi) (hPQ : ∀ x, P x → Q x) : HoldsOnBits Q lo hi :=
  fun n hlo hhi => hPQ _ (h n hlo hhi)

/-- The form in which a block of `count` consecutive bit patterns is enumerated. -/
theorem iff_forall_lt {count : ℕ} :
    HoldsOnBits P lo (lo + count) ↔ ∀ i < count, P (.ofNatBits (lo + i)) := by
  refine ⟨fun h i hi => h _ (Nat.le_add_right ..) (Nat.add_lt_add_left hi _), fun h n hlo hhi => ?_⟩
  obtain ⟨i, rfl⟩ := Nat.exists_eq_add_of_le hlo
  exact h i (Nat.lt_of_add_lt_add_left hhi)

theorem singleton (h : P (.ofNatBits lo)) : HoldsOnBits P lo (lo + 1) := by
  intro n _ _
  grind

/-- If `P` holds between each two consecutive entries of a list of boundaries, it holds between
the first and the last. -/
theorem of_isChain {l : List ℕ} (h : l.IsChain (HoldsOnBits P)) (hlo : lo ∈ l.head?)
    (hhi : hi ∈ l.getLast?) : HoldsOnBits P lo hi := by
  induction l generalizing lo with
  | nil => simp at hlo
  | cons a l ih =>
    obtain rfl : a = lo := by simpa using hlo
    cases l with
    | nil =>
      obtain rfl : a = hi := by simpa using hhi
      exact .refl P a
    | cons b l =>
      rw [List.isChain_cons_cons] at h
      exact h.1.append (ih h.2 rfl (by simpa [List.getLast?_cons_cons] using hhi))

/-- Every value of a format is a bit pattern below `2 ^ fmt.bitWidth`. -/
protected theorem «forall» (h : HoldsOnBits P 0 (2 ^ fmt.bitWidth)) (x : Model fmt) : P x := by
  simpa using h x.toNatBits (Nat.zero_le _) x.toNatBits_lt_two_pow

theorem forall_iff : HoldsOnBits P 0 (2 ^ fmt.bitWidth) ↔ ∀ x, P x :=
  ⟨HoldsOnBits.forall, of_forall⟩

end HoldsOnBits

/-! ### Boolean checks of a block -/

variable {test : Model fmt → Bool} {first count : ℕ}

/-- `test` accepts each of the `count` bit patterns starting at `first`. -/
def checkBits (test : Model fmt → Bool) (first count : ℕ) : Bool :=
  (List.range count).all fun i => test (.ofNatBits (first + i))

/-- The first of the `count` bit patterns starting at `first` that `test` rejects. This is the
diagnostic for a failed `checkBits`: evaluate it with `#eval` to find the input to look at. -/
def firstFailingBits (test : Model fmt → Bool) (first count : ℕ) : Option ℕ :=
  ((List.range count).find? fun i => !test (.ofNatBits (first + i))).map (first + ·)

@[grind =]
theorem checkBits_eq_true_iff :
    checkBits test first count = true ↔ ∀ i < count, test (.ofNatBits (first + i)) = true := by
  simp [checkBits]

theorem holdsOnBits_of_checkBits (h : checkBits test first count = true) :
    HoldsOnBits (test · = true) first (first + count) :=
  HoldsOnBits.iff_forall_lt.2 (checkBits_eq_true_iff.1 h)

/-- A block is checked by checking an initial part and the rest. -/
theorem checkBits_add (test : Model fmt → Bool) (first m n : ℕ) :
    checkBits test first (m + n) = (checkBits test first m && checkBits test (first + m) n) := by
  simp [checkBits, List.range_add, List.all_map, Function.comp_def, Nat.add_assoc]

/-- A check succeeds exactly when there is no failing bit pattern to report. -/
theorem firstFailingBits_eq_none_iff :
    firstFailingBits test first count = none ↔ checkBits test first count = true := by
  simp [firstFailingBits, checkBits]

/-- What `firstFailingBits` reports is a bit pattern of the block that `test` rejects. -/
theorem firstFailingBits_eq_some {n : ℕ} (h : firstFailingBits test first count = some n) :
    first ≤ n ∧ n < first + count ∧ test (.ofNatBits n) = false := by
  obtain ⟨i, hi, rfl⟩ := Option.map_eq_some_iff.1 h
  have := List.find?_some hi
  have := List.mem_range.1 (List.mem_of_find?_eq_some hi)
  grind

end LibcMath
