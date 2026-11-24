import LibcMath.Analysis.ExpRanges

/-!
# The closed forms of `exp` as data

Checks, kept in the build, of what `LibcMath/Analysis/ExpRanges.lean` covers: how many binary32
bit patterns have a closed form in each rounding direction, which ranges are left, and which
theorem covers a given pattern.
-/

namespace LibcMath.ExpRanges.Examples

open FloatLib.Floats.Formats.BinaryInterchange Model

/-! ### How much is covered

3 774 873 369 of the `2 ^ 32` patterns when rounding to nearest, and 3 791 650 585 in each of
the other directions. -/

#guard covered .nearest = 3774873369
#guard covered .towardZero = 3791650585
#guard covered .up = 3791650585
#guard covered .down = 3791650585

/-! ### What is left

Two ranges in each direction: 520 093 927 patterns to nearest, 503 316 711 otherwise. -/

#guard uncovered .nearest = [(0x33800000, 0x42B17217), (0xB3000001, 0xC2CE8ECF)]
#guard uncovered .up = [(0x34000000, 0x42B17217), (0xB3800001, 0xC2CE8ECF)]
#guard uncovered .towardZero = uncovered .up ∧ uncovered .down = uncovered .up
#guard ((uncovered .nearest).map fun r => r.2 - r.1 + 1).sum = 520093927
#guard ((uncovered .up).map fun r => r.2 - r.1 + 1).sum = 503316711
#guard covered .nearest + 520093927 = 2 ^ 32

/-! ### Which theorem covers a bit pattern -/

/-- info: some (1, 864026623, "eval_of_tiny_pos_bits") -/
#guard_msgs in
#eval blockOf? .nearest 0x33000000

/-- `0x33800000` is `2⁻²⁴`: covered when rounding up, not when rounding to nearest. -/
example : blockOf? .nearest 0x33800000 = none ∧
    blockOf? .up 0x33800000 = some (1, 0x33FFFFFF, "eval_of_tiny_pos_bits_of_ne_nearest") := by
  decide

/-- `exp` of the least positive binary32 value, rounded up, is the successor of `1`. -/
example : (Spec.exp .binary32).eval .up (ofNatBits 1) = ofNatBits 0x3F800001 :=
  eval_eq_of_closedForm? (x := ofNatBits 1) (by simp [cModes]) (by decide +kernel)

/-! ### Axioms -/

/--
info: 'LibcMath.ExpRanges.eval_eq_of_closedForm?' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms eval_eq_of_closedForm?

end LibcMath.ExpRanges.Examples
