import LibcMath.Correctness
import LibcMath.Extracted.Expf.DoubleEval
import LibcMath.Functions.ExpRanges
import LibcMath.Oracle.Exp

/-!
# Pointwise verification of exceptional inputs for `Expf.DoubleEval.expf`

This file verifies `CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode (Model.ofNatBits bits)`
across all four C rounding modes (`mode ∈ cModes`) for every exceptional binary32 input that is
excluded from the main SLZ / polynomial error analysis:

* `posExceptions` (51 sorted inputs in `[0x33800000, 0x42B17218)`): every positive input in
  `[0x33800000, 0x42B17218)` with `min(rel_dir, rel_rne) ≤ 2.5e-15` (including `0x33800000` and the
  tiny-positive DIR cancellation point `0x33FFFFFF` at `2⁻⁷⁰·⁵⁸⁵`), together with the RTP
  inexact-reduction edge point `0x3B7FFFFF`.
* `negExceptions` (51 sorted inputs in `[0xB3000001, 0xC2CE8ED0)`): every negative input in
  `[0xB3000001, 0xC2CE8ED0)` with `min(rel_dir, rel_rne) ≤ 2.5e-15` (including `0xB3800000` and the
  hard-coded special-branch point `0xC236BD8C`), together with the RTN inexact-reduction edge point
  `0xBB7FFFFF`.
* `0xB3000000` (standalone theorem `correctAt_0xB3000000`): boundary of the tiny-negative closed
  form.

Each input is checked in Lean's kernel (`decide +kernel`) against a single 80-bit
`ExpOracle.reducedEnclosure?` enclosure (with precomputed `ln 2` grid bounds verified once by
`decide +kernel`) and `ExpOracle.roundScaledGrid?`, depending only on the standard Lean axioms
`[propext, Classical.choice, Quot.sound]`.
-/

namespace LibcMath.Extracted.Expf.PointwiseExceptions

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Core.DSL

/-- Sorted positive exceptional inputs in `[0x33800000, 0x42B17218)` (51 points):
all inputs in `[0x33800000, 0x42B17218)` with `min(rel_dir, rel_rne) ≤ 2.5e-15` (including
`0x33800000` and `0x33FFFFFF`), plus the RTP inexact-reduction point `0x3B7FFFFF`. -/
def posExceptions : List ℕ :=
  [ 0x33800000, 0x33FFFFFF, 0x343FFFFF, 0x347FFFFE, 0x34DFFFFD,
    0x34FFFFFC, 0x356FFFF9, 0x357FFFF8, 0x35BFFFF7, 0x35F7FFF1,
    0x35FFFFF0, 0x363FFFEE, 0x367BFFE1, 0x367FFFE0, 0x369FFFE7,
    0x36BFFFDC, 0x36DFFFCF, 0x36FDFFC1, 0x36FFFFC0, 0x371FFFCE,
    0x373FFFB8, 0x375FFF9E, 0x377EFF81, 0x377FFF80, 0x378FFFAF,
    0x379FFF9C, 0x37FEFF02, 0x38007F7F, 0x383A3EF1, 0x38E69CC1,
    0x39A7D91F, 0x39C6BE5B, 0x39E5BB1D, 0x3AB13D4F, 0x3B730A7D,
    0x3B7FFFFF, 0x3D0D2596, 0x3D1A274E, 0x3D6DAB65, 0x3FE67199,
    0x3FFE02EE, 0x4001B249, 0x4025C4E1, 0x40315B33, 0x4071A3D1,
    0x40DD70CB, 0x4195BC36, 0x41B7EE9A, 0x41CBF87B, 0x4288942B,
    0x42A28A1B ]

/-- Sorted negative exceptional inputs in `[0xB3000001, 0xC2CE8ED0)` (51 points):
all inputs in `[0xB3000001, 0xC2CE8ED0)` with `min(rel_dir, rel_rne) ≤ 2.5e-15` (including
`0xB3800000` and `0xC236BD8C`), plus the RTN inexact-reduction point `0xBB7FFFFF`. -/
def negExceptions : List ℕ :=
  [ 0xB3800000, 0xB4400001, 0xB4800001, 0xB4E00003, 0xB5000002,
    0xB5700007, 0xB5800004, 0xB5C00009, 0xB5F8000F, 0xB6000008,
    0xB6400012, 0xB67C001F, 0xB6800010, 0xB6A00019, 0xB6C00024,
    0xB6E00031, 0xB6FE003F, 0xB7000020, 0xB7200032, 0xB7400048,
    0xB7600062, 0xB7800040, 0xB7900051, 0xB7A00064, 0xB7C9C09F,
    0xB7F4C0EA, 0xB9C5E18F, 0xB9F24654, 0xB9F8470C, 0xBA03CC7B,
    0xBA7242A6, 0xBAB1E4E4, 0xBAE0E25C, 0xBB32CF64, 0xBB7FFFFF,
    0xBBA3EC4A, 0xBBB70EE8, 0xBBC3941F, 0xBBF0EDF1, 0xBC2A461A,
    0xBCA55088, 0xBCB8F40F, 0xBEA82076, 0xBECBB365, 0xBED67F95,
    0xBFBFA14B, 0xBFCD4607, 0xC0781533, 0xC13D6631, 0xC16912CD,
    0xC236BD8C ]

/-! ### High-precision oracle checker -/

/-- 80-bit reduction parameters for `ExpOracle.reducedEnclosure?` with precomputed `scale = 2 ^ 80`
and `logTwo = ln2Grid 96`. Proving `scale_eq` and `logTwo_eq` once avoids recomputing `ln2Grid` for
each exceptional input during kernel reduction. -/
private def fastReduction : ExpOracle.Reduction where
  precision := 80
  guard := 16
  degree := 22
  scale := 1208925819614629174706176
  logTwo := ⟨54916777467707473351141471128, 54916777467707473351141471129⟩
  degree_pos := by decide
  scale_eq := by decide +kernel
  logTwo_eq := by decide +kernel

/-- Verify `Expf.DoubleEval.expf mode x` matches an expected binary32 result bit-for-bit. -/
private def checkModeResult (mode : IEEERoundingMode) (x expected : Model .binary32) : Bool :=
  match Expf.DoubleEval.expf mode x with
  | some y => ExpOracle.sameBits y expected
  | none => false

private theorem correctAt_of_checkModeResult {mode : IEEERoundingMode}
    {x expected : Model .binary32} (hcheck : checkModeResult mode x expected = true)
    (heval : (Spec.exp .binary32).eval mode x = expected) :
    CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode x := by
  unfold checkModeResult at hcheck
  split at hcheck
  · rename_i y hy
    exact .of_eq_some hy (.inl ((ExpOracle.eq_of_sameBits hcheck).trans heval.symm))
  · simp at hcheck

/-- Check `Expf.DoubleEval.expf` at `bits` across all four C rounding modes from a single 80-bit
`ExpOracle.reducedEnclosure?` enclosure of `exp x`. Since `exp x > 0`, `.towardZero` shares the
prescribed result of `.down`. -/
private def checkPointAllModes (bits : ℕ) : Bool :=
  let x : Model .binary32 := Model.ofNatBits bits
  match Model.toRat? x with
  | some q =>
      if q == 0 then false
      else
        match ExpOracle.reducedEnclosure? fastReduction q with
        | some (mult, I) =>
            match ExpOracle.roundScaledGrid? .binary32 .nearest fastReduction.precision mult I,
                ExpOracle.roundScaledGrid? .binary32 .down fastReduction.precision mult I,
                ExpOracle.roundScaledGrid? .binary32 .up fastReduction.precision mult I with
            | some rN, some rD, some rU =>
                checkModeResult .nearest x rN && checkModeResult .down x rD &&
                  checkModeResult .up x rU && checkModeResult .towardZero x rD
            | _, _, _ => false
        | none => false
  | none => false

private theorem correctAt_of_checkPointAllModes {bits : ℕ}
    (h : checkPointAllModes bits = true) {mode : IEEERoundingMode} (hmode : mode ∈ cModes) :
    CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode (Model.ofNatBits bits) := by
  set x : Model .binary32 := Model.ofNatBits bits
  unfold checkPointAllModes at h
  dsimp only at h
  split at h
  · rename_i q hq
    split at h
    · simp at h
    · rename_i hne
      have hqne : q ≠ 0 := by simpa using hne
      have hfinite := Model.Algebraic.isFinite_of_toRat?_eq_some hq
      have hreal := Model.Algebraic.toReal_of_toRat?_eq_some hq
      have hnan := Model.isNaN_eq_false_of_isFinite_eq_true x hfinite
      have hinf := Model.isInfinite_eq_false_of_isFinite_eq_true x hfinite
      have hzero : x.isZero = false := by
        rw [← Bool.not_eq_true, Model.isZero_eq_true_iff_toReal_eq_zero x hfinite, hreal]
        exact_mod_cast hqne
      have heval (m : IEEERoundingMode) :
          (Spec.exp .binary32).eval m x = Model.roundReal .binary32 m (Real.exp q) := by
        rw [ExpRanges.eval_eq_roundReal hnan hinf hzero, hreal]
      split at h
      · rename_i mult I hred
        have hmem := ExpOracle.contains_reducedEnclosure? hred
        split at h
        · rename_i rN rD rU hrN hrD hrU
          simp only [Bool.and_eq_true] at h
          obtain ⟨⟨⟨hcN, hcD⟩, hcU⟩, hcZ⟩ := h
          have hN := ExpOracle.roundReal_eq_of_roundScaledGrid? rfl hmem.1 hmem.2 hrN
          have hD := ExpOracle.roundReal_eq_of_roundScaledGrid? rfl hmem.1 hmem.2 hrD
          have hU := ExpOracle.roundReal_eq_of_roundScaledGrid? rfl hmem.1 hmem.2 hrU
          rcases hmode with rfl | rfl | rfl | rfl
          · exact correctAt_of_checkModeResult hcN ((heval .nearest).trans hN)
          · exact correctAt_of_checkModeResult hcZ
              ((Spec.exp_eval_towardZero .binary32 x).trans ((heval .down).trans hD))
          · exact correctAt_of_checkModeResult hcU ((heval .up).trans hU)
          · exact correctAt_of_checkModeResult hcD ((heval .down).trans hD)
        · simp at h
      · simp at h
  · simp at h

/-! ### Parallel kernel verification in slices -/

private theorem list_all_of_slices {p : ℕ → Bool} {l : List ℕ}
    (h0 : (l.take 6).all p = true)
    (h1 : ((l.drop 6).take 6).all p = true)
    (h2 : ((l.drop 12).take 6).all p = true)
    (h3 : ((l.drop 18).take 6).all p = true)
    (h4 : ((l.drop 24).take 6).all p = true)
    (h5 : ((l.drop 30).take 6).all p = true)
    (h6 : ((l.drop 36).take 6).all p = true)
    (h7 : ((l.drop 42).take 6).all p = true)
    (h8 : (l.drop 48).all p = true) :
    l.all p = true := by
  have step (k : ℕ) : l.drop k = (l.drop k).take 6 ++ l.drop (k + 6) := by
    rw [← List.drop_drop, List.take_append_drop]
  have hsplit : l = l.take 6 ++ (l.drop 6).take 6 ++ (l.drop 12).take 6 ++
      (l.drop 18).take 6 ++ (l.drop 24).take 6 ++ (l.drop 30).take 6 ++
      (l.drop 36).take 6 ++ (l.drop 42).take 6 ++ l.drop 48 := by
    conv_lhs => rw [← List.take_append_drop 6 l, step 6, step 12, step 18, step 24, step 30,
      step 36, step 42]
    simp [List.append_assoc]
  rw [hsplit]
  simp [List.all_append, h0, h1, h2, h3, h4, h5, h6, h7, h8]

private theorem pos_slice0 : (posExceptions.take 6).all checkPointAllModes = true := by
  decide +kernel
private theorem pos_slice1 : ((posExceptions.drop 6).take 6).all checkPointAllModes = true := by
  decide +kernel
private theorem pos_slice2 : ((posExceptions.drop 12).take 6).all checkPointAllModes = true := by
  decide +kernel
private theorem pos_slice3 : ((posExceptions.drop 18).take 6).all checkPointAllModes = true := by
  decide +kernel
private theorem pos_slice4 : ((posExceptions.drop 24).take 6).all checkPointAllModes = true := by
  decide +kernel
private theorem pos_slice5 : ((posExceptions.drop 30).take 6).all checkPointAllModes = true := by
  decide +kernel
private theorem pos_slice6 : ((posExceptions.drop 36).take 6).all checkPointAllModes = true := by
  decide +kernel
private theorem pos_slice7 : ((posExceptions.drop 42).take 6).all checkPointAllModes = true := by
  decide +kernel
private theorem pos_slice8 : (posExceptions.drop 48).all checkPointAllModes = true := by
  decide +kernel

private theorem neg_slice0 : (negExceptions.take 6).all checkPointAllModes = true := by
  decide +kernel
private theorem neg_slice1 : ((negExceptions.drop 6).take 6).all checkPointAllModes = true := by
  decide +kernel
private theorem neg_slice2 : ((negExceptions.drop 12).take 6).all checkPointAllModes = true := by
  decide +kernel
private theorem neg_slice3 : ((negExceptions.drop 18).take 6).all checkPointAllModes = true := by
  decide +kernel
private theorem neg_slice4 : ((negExceptions.drop 24).take 6).all checkPointAllModes = true := by
  decide +kernel
private theorem neg_slice5 : ((negExceptions.drop 30).take 6).all checkPointAllModes = true := by
  decide +kernel
private theorem neg_slice6 : ((negExceptions.drop 36).take 6).all checkPointAllModes = true := by
  decide +kernel
private theorem neg_slice7 : ((negExceptions.drop 42).take 6).all checkPointAllModes = true := by
  decide +kernel
private theorem neg_slice8 : (negExceptions.drop 48).all checkPointAllModes = true := by
  decide +kernel

private theorem posExceptions_checked : posExceptions.all checkPointAllModes = true :=
  list_all_of_slices pos_slice0 pos_slice1 pos_slice2 pos_slice3 pos_slice4
    pos_slice5 pos_slice6 pos_slice7 pos_slice8

private theorem negExceptions_checked : negExceptions.all checkPointAllModes = true :=
  list_all_of_slices neg_slice0 neg_slice1 neg_slice2 neg_slice3 neg_slice4
    neg_slice5 neg_slice6 neg_slice7 neg_slice8

private theorem point_0xB3000000_checked : checkPointAllModes 0xB3000000 = true := by
  decide +kernel

/-! ### Exported correctness theorems -/

/-- `Expf.DoubleEval.expf` is correctly rounded in all four C rounding modes at every bit pattern
in `posExceptions`. -/
theorem correctAt_of_mem_posExceptions {mode : IEEERoundingMode} (hmode : mode ∈ cModes)
    {bits : ℕ} (hmem : bits ∈ posExceptions) :
    CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode (Model.ofNatBits bits) :=
  correctAt_of_checkPointAllModes (List.all_eq_true.mp posExceptions_checked bits hmem) hmode

/-- `Expf.DoubleEval.expf` is correctly rounded in all four C rounding modes at every bit pattern
in `negExceptions`. -/
theorem correctAt_of_mem_negExceptions {mode : IEEERoundingMode} (hmode : mode ∈ cModes)
    {bits : ℕ} (hmem : bits ∈ negExceptions) :
    CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode (Model.ofNatBits bits) :=
  correctAt_of_checkPointAllModes (List.all_eq_true.mp negExceptions_checked bits hmem) hmode

/-- `Expf.DoubleEval.expf` is correctly rounded in all four C rounding modes at `0xB3000000`
(`-2⁻²⁵`, the boundary of the tiny-negative closed form). -/
theorem correctAt_0xB3000000 {mode : IEEERoundingMode} (hmode : mode ∈ cModes) :
    CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode (Model.ofNatBits 0xB3000000) :=
  correctAt_of_checkPointAllModes point_0xB3000000_checked hmode

/-- `posExceptions` is strictly increasing (sorted and duplicate-free). -/
theorem posExceptions_pairwise_lt : posExceptions.Pairwise (· < ·) := by
  decide +kernel

/-- `negExceptions` is strictly increasing (sorted and duplicate-free). -/
theorem negExceptions_pairwise_lt : negExceptions.Pairwise (· < ·) := by
  decide +kernel

/-- Every entry of `posExceptions` lies in `[0x33800000, 0x42B17218)`. -/
theorem mem_posExceptions_bounds {bits : ℕ} (hmem : bits ∈ posExceptions) :
    0x33800000 ≤ bits ∧ bits < 0x42B17218 := by
  have hall : posExceptions.all (fun b => decide (0x33800000 ≤ b ∧ b < 0x42B17218)) = true := by
    decide +kernel
  exact of_decide_eq_true (List.all_eq_true.mp hall bits hmem)

/-- Every entry of `negExceptions` lies in `[0xB3000001, 0xC2CE8ED0)`. -/
theorem mem_negExceptions_bounds {bits : ℕ} (hmem : bits ∈ negExceptions) :
    0xB3000001 ≤ bits ∧ bits < 0xC2CE8ED0 := by
  have hall : negExceptions.all (fun b => decide (0xB3000001 ≤ b ∧ b < 0xC2CE8ED0)) = true := by
    decide +kernel
  exact of_decide_eq_true (List.all_eq_true.mp hall bits hmem)

/-! ### Axiom checks -/

/--
info: 'LibcMath.Extracted.Expf.PointwiseExceptions.correctAt_of_mem_posExceptions' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms correctAt_of_mem_posExceptions

/--
info: 'LibcMath.Extracted.Expf.PointwiseExceptions.correctAt_of_mem_negExceptions' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms correctAt_of_mem_negExceptions

/--
info: 'LibcMath.Extracted.Expf.PointwiseExceptions.correctAt_0xB3000000' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms correctAt_0xB3000000

end LibcMath.Extracted.Expf.PointwiseExceptions
