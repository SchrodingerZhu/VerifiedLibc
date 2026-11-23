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
-/

namespace LibcMath

open FloatLib.Floats.Formats.BinaryInterchange

variable {fmt : FloatFormat} {P Q : Model fmt → Prop} {lo mid hi : ℕ}

/-- `P` holds for every bit pattern `n` with `lo ≤ n < hi`. -/
def HoldsOnBits (P : Model fmt → Prop) (lo hi : ℕ) : Prop :=
  ∀ n, lo ≤ n → n < hi → P (.ofNatBits n)

namespace HoldsOnBits

theorem of_forall (h : ∀ x, P x) : HoldsOnBits P lo hi :=
  fun _ _ _ => h _

/-- A range whose ends coincide or are out of order is empty. -/
theorem of_le (h : hi ≤ lo) : HoldsOnBits P lo hi :=
  fun _ hlo hhi => absurd (hlo.trans_lt hhi) h.not_gt

protected theorem refl (P : Model fmt → Prop) (lo : ℕ) : HoldsOnBits P lo lo :=
  of_le le_rfl

/-- Statements for adjacent ranges combine. -/
theorem append (h₁ : HoldsOnBits P lo mid) (h₂ : HoldsOnBits P mid hi) : HoldsOnBits P lo hi :=
  fun n hlo hhi => (lt_or_ge n mid).elim (h₁ n hlo) (h₂ n · hhi)

theorem subrange {lo' hi' : ℕ} (h : HoldsOnBits P lo hi) (hlo : lo ≤ lo') (hhi : hi' ≤ hi) :
    HoldsOnBits P lo' hi' :=
  fun n hn hn' => h n (hlo.trans hn) (hn'.trans_le hhi)

theorem imp (h : HoldsOnBits P lo hi) (hPQ : ∀ x, P x → Q x) : HoldsOnBits Q lo hi :=
  fun n hlo hhi => hPQ _ (h n hlo hhi)

/-- The form in which a block of `count` consecutive bit patterns is enumerated. -/
theorem iff_forall_lt {count : ℕ} :
    HoldsOnBits P lo (lo + count) ↔ ∀ i < count, P (.ofNatBits (lo + i)) := by
  refine ⟨fun h i hi => h _ (Nat.le_add_right ..) (Nat.add_lt_add_left hi _), fun h n hlo hhi => ?_⟩
  obtain ⟨i, rfl⟩ := Nat.exists_eq_add_of_le hlo
  exact h i (Nat.lt_of_add_lt_add_left hhi)

theorem singleton (h : P (.ofNatBits lo)) : HoldsOnBits P lo (lo + 1) :=
  iff_forall_lt.2 fun i hi => by obtain rfl : i = 0 := by omega
                                 exact h

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

end LibcMath
