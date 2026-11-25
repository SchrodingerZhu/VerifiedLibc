import LibcMath.Kernels.Expf.MainPath.PointwiseExceptions
import LibcMath.Kernels.Expf.MainPath.ProductError
import LibcMath.Analysis.ChebTmd
import LibcMath.Kernels.Expf.MainPath.Tmd.ExpApprox

/-!
# Soundness bridge for packed Chebyshev SLZ TMD certificate chunks

Connects `Tmd.ExpApprox` (rigorous pure-`Nat` exponential + Chebyshev-economized polynomial
enclosure), `Tmd.ChebCert` (pure-`Nat` always-odd Chebyshev-L1 verifier), `PointwiseExceptions`,
and `ProductError` (`correctAt_of_awayFromGrid_pos` / `neg`) into a single chunk-level verifier:

* `checkD2Chunk` (`d = 2, m = 2`, 320-bit records: 8-bit `eOff`, 24-bit `rCode`, 288-bit `packedQ`),
* `checkD3Chunk` (`d = 3, m = 3`, 1168-bit records: 8-bit `eOff`, 16-bit `rCode`,
  1144-bit `packedQ`).

Every chunk proves
`HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEval.expf mode) lo hi`
across all four C rounding modes using only `decide +kernel` and the three standard Lean axioms.
-/

namespace LibcMath.Kernels.Expf.MainPath.Tmd.Verify

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc.DSL

variable {mode : IEEERoundingMode}

/-! ### Bit-packing radices -/

def B8 : Nat := 256
def B16 : Nat := 65536
def B24 : Nat := 16777216
def B288 : Nat := 1 <<< 288
def B1144 : Nat := 1 <<< 1144

/-! ### Pure-`Nat` chunk verifiers -/

/-- Verify `k` packed `d = 2, m = 2` records (320 bits each, LSB first) starting at bit pattern
`cur`, returning `some nextCur` on success. -/
def checkD2Blob (exc : List Nat) : Nat → Nat → Nat → Option Nat
  | 0, cur, _ => some cur
  | k + 1, cur, blob =>
    let eOff := Nat.mod blob B8
    let r1 := Nat.div blob B8
    let rCode := Nat.mod r1 B24
    let r2 := Nat.div r1 B24
    let pq := Nat.mod r2 B288
    let rest := Nat.div r2 B288
    if Nat.beq rCode 0 then
      if exc.contains cur then checkD2Blob exc k (cur + 1) rest else none
    else if Nat.ble eOff 254 then
      let R := rCode - 1
      let bc := cur + R
      match Tmd.polyApproxD2Biased bc R eOff with
      | none => none
      | some (M, c0, c1, c2) =>
        if Analysis.ChebTmd.checkPackedD2M2 R M c0 c1 c2 pq then
          checkD2Blob exc k (bc + (R + 1)) rest
        else
          none
    else
      none

/-- Verify a list of `(count, blob)` sub-blocks covering `[lo, hi)` for `d = 2, m = 2`. -/
def checkD2Blobs (exc : List Nat) (cur : Nat) : List (Nat × Nat) → Option Nat
  | [] => some cur
  | (k, blob) :: rest =>
    match checkD2Blob exc k cur blob with
    | none => none
    | some next => checkD2Blobs exc next rest

def checkD2Chunk (exc : List Nat) (lo hi : Nat) (blobs : List (Nat × Nat)) : Bool :=
  match checkD2Blobs exc lo blobs with
  | some endCur => Nat.beq endCur hi
  | none => false

/-- Verify `k` packed `d = 3, m = 3` records (1168 bits each, LSB first) starting at bit pattern
`cur`, returning `some nextCur` on success. -/
def checkD3Blob (exc : List Nat) : Nat → Nat → Nat → Option Nat
  | 0, cur, _ => some cur
  | k + 1, cur, blob =>
    let eOff := Nat.mod blob B8
    let r1 := Nat.div blob B8
    let rCode := Nat.mod r1 B16
    let r2 := Nat.div r1 B16
    let pq := Nat.mod r2 B1144
    let rest := Nat.div r2 B1144
    if Nat.beq rCode 0 then
      if exc.contains cur then checkD3Blob exc k (cur + 1) rest else none
    else if Nat.ble eOff 254 then
      let R := rCode - 1
      let bc := cur + R
      match Tmd.polyApproxD3Biased bc R eOff with
      | none => none
      | some (M, c0, c1, c2, c3) =>
        if Analysis.ChebTmd.checkPackedD3M3 R M c0 c1 c2 c3 pq then
          checkD3Blob exc k (bc + (R + 1)) rest
        else
          none
    else
      none

/-- Verify a list of `(count, blob)` sub-blocks covering `[lo, hi)` for `d = 3, m = 3`. -/
def checkD3Blobs (exc : List Nat) (cur : Nat) : List (Nat × Nat) → Option Nat
  | [] => some cur
  | (k, blob) :: rest =>
    match checkD3Blob exc k cur blob with
    | none => none
    | some next => checkD3Blobs exc next rest

def checkD3Chunk (exc : List Nat) (lo hi : Nat) (blobs : List (Nat × Nat)) : Bool :=
  match checkD3Blobs exc lo blobs with
  | some endCur => Nat.beq endCur hi
  | none => false

/-! ### Bridging `Tmd.inOutputBinade` and `Tmd.polyApproxD*Biased` to `RoundingTransfer` -/

private theorem gridFor_of_inOutputBinade {E : Int} {y : ℝ} (h : Tmd.inOutputBinade E y) :
    Analysis.RoundingTransfer.GridFor y ((2 : ℝ) ^ Tmd.uExp E) := by
  rcases h with ⟨hElo, hEhi, hlo, hhi⟩
  by_cases hsub : E = -127
  · subst hsub
    right
    have h1 : Tmd.binadeLoExp (-127) = -150 := by decide
    have h2 : Tmd.uExp (-127) = -150 := by decide
    rw [h1] at hlo
    rw [h2]
    exact ⟨hlo, by simpa using hhi, rfl⟩
  · left
    have hge : (-126 : ℤ) ≤ E := by omega
    have hbeq : (E == -127) = false := beq_false_of_ne hsub
    have h1 : Tmd.binadeLoExp E = E := by simp [Tmd.binadeLoExp, hbeq]
    have h2 : Tmd.uExp E = E - 24 := by simp [Tmd.uExp, hbeq]
    rw [h1] at hlo
    rw [h2]
    exact ⟨E, hge, hEhi, hlo, hhi, rfl⟩

private theorem intToEOff?_sub_127_fin :
    ∀ e : Fin 255, Tmd.intToEOff? ((e.val : ℤ) - 127) = some e.val := by
  decide +kernel

private theorem intToEOff?_sub_127 {eOff : Nat} (he : eOff ≤ 254) :
    Tmd.intToEOff? ((eOff : ℤ) - 127) = some eOff :=
  intToEOff?_sub_127_fin ⟨eOff, by omega⟩

private theorem awayFromGrid_of_poly_and_cert {y u p mS : ℝ} (hu_pos : 0 < u) {I : ℤ}
    (happrox : |y / u - ((I : ℝ) + p)| + (2 / 10 ^ 15 : ℝ) * (y / u) ≤ mS)
    (hcert : ∀ k : ℤ, mS < |((k - I : ℤ) : ℝ) - p|) :
    Analysis.RoundingTransfer.AwayFromGrid u (2 / 10 ^ 15) y := by
  intro k
  have hk := hcert k
  have hsub_eq : (k : ℝ) - ((I : ℝ) + p) = ((k - I : ℤ) : ℝ) - p := by push_cast; ring
  have htri : |((k - I : ℤ) : ℝ) - p| ≤ |y / u - (k : ℝ)| + |y / u - ((I : ℝ) + p)| := by
    rw [← hsub_eq]
    have heq : (k : ℝ) - ((I : ℝ) + p) = ((k : ℝ) - y / u) + (y / u - ((I : ℝ) + p)) := by ring
    rw [heq]
    exact (abs_add_le _ _).trans (by rw [abs_sub_comm (k : ℝ) (y / u)])
  have hdiv_lt : (2 / 10 ^ 15 : ℝ) * (y / u) < |y / u - (k : ℝ)| := by linarith
  have hmul := mul_lt_mul_of_pos_right hdiv_lt hu_pos
  have hlhs : (2 / 10 ^ 15 : ℝ) * (y / u) * u = (2 / 10 ^ 15 : ℝ) * y := by field_simp
  have hrhs : |y / u - (k : ℝ)| * u = |y - (k : ℝ) * u| := by
    calc |y / u - (k : ℝ)| * u
        = |y / u - (k : ℝ)| * |u| := by rw [abs_of_pos hu_pos]
      _ = |(y / u - (k : ℝ)) * u| := (abs_mul _ _).symm
      _ = |y - (k : ℝ) * u| := by congr 1; field_simp
  rwa [hlhs, hrhs] at hmul

/-- Helper: extract `AwayFromGrid` on a single `d = 2, m = 2` certified interval. -/
private theorem grid_and_away_of_D2 {bc R eOff M c0 c1 c2 pq : Nat}
    (heOff : eOff ≤ 254)
    (hpoly : Tmd.polyApproxD2Biased bc R eOff = some (M, c0, c1, c2))
    (hcert : Analysis.ChebTmd.checkPackedD2M2 R M c0 c1 c2 pq = true) :
    R ≤ bc ∧ bc + R < 0x100000000 ∧
    ∀ n : Nat, bc - R ≤ n → n ≤ bc + R →
      let y := Real.exp (Model.ofNatBits n : Model .binary32).toReal
      let u := (2 : ℝ) ^ Tmd.uExp ((eOff : ℤ) - 127)
      Analysis.RoundingTransfer.GridFor y u ∧
      Analysis.RoundingTransfer.AwayFromGrid u (2 / 10 ^ 15) y := by
  have hpolyE : Tmd.polyApproxD2 bc R ((eOff : ℤ) - 127) = some (M, c0, c1, c2) := by
    simp only [Tmd.polyApproxD2, intToEOff?_sub_127 heOff, hpoly]
  obtain ⟨hRle, hbcHi, _, _, _, hforall⟩ := Tmd.polyApproxD2_sound hpolyE
  refine ⟨hRle, hbcHi, fun n hnlo hnhi => ?_⟩
  obtain ⟨hbin, i, hi, I, happrox⟩ := hforall n hnlo hnhi
  rw [← Analysis.ChebTmd.S64_eq] at happrox
  refine ⟨gridFor_of_inOutputBinade hbin,
    awayFromGrid_of_poly_and_cert (by positivity) happrox fun k =>
      Analysis.ChebTmd.awayFromInt_of_checkPackedD2M2_S64 hcert i (k - I) hi⟩

/-- Helper: extract `AwayFromGrid` on a single `d = 3, m = 3` certified interval. -/
private theorem grid_and_away_of_D3 {bc R eOff M c0 c1 c2 c3 pq : Nat}
    (heOff : eOff ≤ 254)
    (hpoly : Tmd.polyApproxD3Biased bc R eOff = some (M, c0, c1, c2, c3))
    (hcert : Analysis.ChebTmd.checkPackedD3M3 R M c0 c1 c2 c3 pq = true) :
    R ≤ bc ∧ bc + R < 0x100000000 ∧
    ∀ n : Nat, bc - R ≤ n → n ≤ bc + R →
      let y := Real.exp (Model.ofNatBits n : Model .binary32).toReal
      let u := (2 : ℝ) ^ Tmd.uExp ((eOff : ℤ) - 127)
      Analysis.RoundingTransfer.GridFor y u ∧
      Analysis.RoundingTransfer.AwayFromGrid u (2 / 10 ^ 15) y := by
  have hpolyE : Tmd.polyApproxD3 bc R ((eOff : ℤ) - 127) = some (M, c0, c1, c2, c3) := by
    simp only [Tmd.polyApproxD3, intToEOff?_sub_127 heOff, hpoly]
  obtain ⟨hRle, hbcHi, _, _, _, _, hforall⟩ := Tmd.polyApproxD3_sound hpolyE
  refine ⟨hRle, hbcHi, fun n hnlo hnhi => ?_⟩
  obtain ⟨hbin, i, hi, I, happrox⟩ := hforall n hnlo hnhi
  rw [← Analysis.ChebTmd.S64_eq] at happrox
  refine ⟨gridFor_of_inOutputBinade hbin,
    awayFromGrid_of_poly_and_cert (by positivity) happrox fun k =>
      Analysis.ChebTmd.awayFromInt_of_checkPackedD3M3_S64 hcert i (k - I) hi⟩

/-! ### Generic range soundness for `checkD2Blob`, `checkD3Blob`, and chunks -/

private def CoveredOrExc (exc : List Nat) (n : Nat) : Prop :=
  n ∈ exc ∨
    ∃ u : ℝ,
      Analysis.RoundingTransfer.GridFor (Real.exp (Model.ofNatBits n : Model .binary32).toReal) u ∧
      Analysis.RoundingTransfer.AwayFromGrid u (2 / 10 ^ 15)
        (Real.exp (Model.ofNatBits n : Model .binary32).toReal)

private theorem checkD2Blob_sound {exc : List Nat} :
    ∀ {k cur blob endCur : Nat},
      checkD2Blob exc k cur blob = some endCur →
      cur ≤ endCur ∧ ∀ n, cur ≤ n → n < endCur → CoveredOrExc exc n
  | 0, cur, _, endCur, h => by
    simp only [checkD2Blob, Option.some.injEq] at h
    subst h
    exact ⟨le_rfl, fun _ h1 h2 => by omega⟩
  | k + 1, cur, blob, endCur, h => by
    unfold checkD2Blob at h
    dsimp only at h
    set eOff := Nat.mod blob B8
    set r1 := Nat.div blob B8
    set rCode := Nat.mod r1 B24
    set r2 := Nat.div r1 B24
    set pq := Nat.mod r2 B288
    set rest := Nat.div r2 B288
    by_cases hr0 : Nat.beq rCode 0 = true
    · simp only [hr0, ↓reduceIte] at h
      split at h
      · rename_i hexc
        obtain ⟨hle, hrest⟩ := checkD2Blob_sound h
        refine ⟨by omega, fun n hnlo hnhi => ?_⟩
        by_cases hcur : n = cur
        · subst hcur
          exact .inl (List.contains_iff_mem.mp hexc)
        · exact hrest n (by omega) hnhi
      · cases h
    · have hr0f : Nat.beq rCode 0 = false := Bool.eq_false_iff.mpr hr0
      simp only [hr0f, Bool.false_eq_true, ↓reduceIte] at h
      by_cases he : Nat.ble eOff 254 = true
      · simp only [he, ↓reduceIte] at h
        have heOff : eOff ≤ 254 := Nat.ble_eq.mp he
        set R := rCode - 1
        set bc := cur + R
        cases hpoly : Tmd.polyApproxD2Biased bc R eOff with
        | none => simp [hpoly] at h
        | some res =>
          rcases res with ⟨M, c0, c1, c2⟩
          simp only [hpoly] at h
          split at h
          · rename_i hcert
            obtain ⟨_, _, hcov⟩ := grid_and_away_of_D2 heOff hpoly hcert
            obtain ⟨hle, hrest⟩ := checkD2Blob_sound h
            refine ⟨by omega, fun n hnlo hnhi => ?_⟩
            by_cases hmid : n < bc + (R + 1)
            · exact .inr ⟨_, hcov n (by omega) (by omega)⟩
            · exact hrest n (by omega) hnhi
          · cases h
      · have hef : Nat.ble eOff 254 = false := Bool.eq_false_iff.mpr he
        simp only [hef, Bool.false_eq_true, ↓reduceIte] at h
        cases h

private theorem checkD2Blobs_sound {exc : List Nat} :
    ∀ {blobs : List (Nat × Nat)} {cur endCur : Nat},
      checkD2Blobs exc cur blobs = some endCur →
      cur ≤ endCur ∧ ∀ n, cur ≤ n → n < endCur → CoveredOrExc exc n
  | [], cur, endCur, h => by
    simp only [checkD2Blobs, Option.some.injEq] at h
    subst h
    exact ⟨le_rfl, fun _ h1 h2 => by omega⟩
  | (k, blob) :: rest, cur, endCur, h => by
    simp only [checkD2Blobs] at h
    cases hb : checkD2Blob exc k cur blob with
    | none => simp [hb] at h
    | some mid =>
      simp only [hb] at h
      obtain ⟨h1, hcov1⟩ := checkD2Blob_sound hb
      obtain ⟨h2, hcov2⟩ := checkD2Blobs_sound h
      refine ⟨le_trans h1 h2, fun n hnlo hnhi => ?_⟩
      by_cases hlt : n < mid
      · exact hcov1 n hnlo hlt
      · exact hcov2 n (by omega) hnhi

private theorem checkD3Blob_sound {exc : List Nat} :
    ∀ {k cur blob endCur : Nat},
      checkD3Blob exc k cur blob = some endCur →
      cur ≤ endCur ∧ ∀ n, cur ≤ n → n < endCur → CoveredOrExc exc n
  | 0, cur, _, endCur, h => by
    simp only [checkD3Blob, Option.some.injEq] at h
    subst h
    exact ⟨le_rfl, fun _ h1 h2 => by omega⟩
  | k + 1, cur, blob, endCur, h => by
    unfold checkD3Blob at h
    dsimp only at h
    set eOff := Nat.mod blob B8
    set r1 := Nat.div blob B8
    set rCode := Nat.mod r1 B16
    set r2 := Nat.div r1 B16
    set pq := Nat.mod r2 B1144
    set rest := Nat.div r2 B1144
    by_cases hr0 : Nat.beq rCode 0 = true
    · simp only [hr0, ↓reduceIte] at h
      split at h
      · rename_i hexc
        obtain ⟨hle, hrest⟩ := checkD3Blob_sound h
        refine ⟨by omega, fun n hnlo hnhi => ?_⟩
        by_cases hcur : n = cur
        · subst hcur
          exact .inl (List.contains_iff_mem.mp hexc)
        · exact hrest n (by omega) hnhi
      · cases h
    · have hr0f : Nat.beq rCode 0 = false := Bool.eq_false_iff.mpr hr0
      simp only [hr0f, Bool.false_eq_true, ↓reduceIte] at h
      by_cases he : Nat.ble eOff 254 = true
      · simp only [he, ↓reduceIte] at h
        have heOff : eOff ≤ 254 := Nat.ble_eq.mp he
        set R := rCode - 1
        set bc := cur + R
        cases hpoly : Tmd.polyApproxD3Biased bc R eOff with
        | none => simp [hpoly] at h
        | some res =>
          rcases res with ⟨M, c0, c1, c2, c3⟩
          simp only [hpoly] at h
          split at h
          · rename_i hcert
            obtain ⟨_, _, hcov⟩ := grid_and_away_of_D3 heOff hpoly hcert
            obtain ⟨hle, hrest⟩ := checkD3Blob_sound h
            refine ⟨by omega, fun n hnlo hnhi => ?_⟩
            by_cases hmid : n < bc + (R + 1)
            · exact .inr ⟨_, hcov n (by omega) (by omega)⟩
            · exact hrest n (by omega) hnhi
          · cases h
      · have hef : Nat.ble eOff 254 = false := Bool.eq_false_iff.mpr he
        simp only [hef, Bool.false_eq_true, ↓reduceIte] at h
        cases h

private theorem checkD3Blobs_sound {exc : List Nat} :
    ∀ {blobs : List (Nat × Nat)} {cur endCur : Nat},
      checkD3Blobs exc cur blobs = some endCur →
      cur ≤ endCur ∧ ∀ n, cur ≤ n → n < endCur → CoveredOrExc exc n
  | [], cur, endCur, h => by
    simp only [checkD3Blobs, Option.some.injEq] at h
    subst h
    exact ⟨le_rfl, fun _ h1 h2 => by omega⟩
  | (k, blob) :: rest, cur, endCur, h => by
    simp only [checkD3Blobs] at h
    cases hb : checkD3Blob exc k cur blob with
    | none => simp [hb] at h
    | some mid =>
      simp only [hb] at h
      obtain ⟨h1, hcov1⟩ := checkD3Blob_sound hb
      obtain ⟨h2, hcov2⟩ := checkD3Blobs_sound h
      refine ⟨le_trans h1 h2, fun n hnlo hnhi => ?_⟩
      by_cases hlt : n < mid
      · exact hcov1 n hnlo hlt
      · exact hcov2 n (by omega) hnhi

/-! ### Top-level chunk soundness theorems (positive and negative, `d = 2` and `d = 3`) -/

private theorem holdsOnBits_pos_of_coveredOrExc (hmode : mode ∈ cModes) {lo hi : Nat}
    (hlo : 0x33800000 ≤ lo) (hhi : hi ≤ 0x42B17218)
    (hcov : ∀ n, lo ≤ n → n < hi → CoveredOrExc PointwiseExceptions.posExceptions n) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEval.expf mode) lo hi := by
  intro n hnlo hnhi
  rcases hcov n hnlo hnhi with hexc | ⟨u, hgrid, haway⟩
  · exact PointwiseExceptions.correctAt_of_mem_posExceptions hmode hexc
  · by_cases hsp : n = 0x3B7FFFFF
    · subst hsp
      exact PointwiseExceptions.correctAt_of_mem_posExceptions hmode (by decide)
    · have hmod : (BitVec.ofNat 32 n).toNat = n := by
        rw [BitVec.toNat_ofNat]; omega
      have hof : (Model.ofNatBits n : Model .binary32) = f32(BitVec.ofNat 32 n) := rfl
      rw [hof] at hgrid haway ⊢
      exact ProductError.correctAt_of_awayFromGrid_pos hmode (BitVec.ofNat 32 n)
        (by omega) (by omega) (by omega) hgrid haway

private theorem holdsOnBits_neg_of_coveredOrExc (hmode : mode ∈ cModes) {lo hi : Nat}
    (hlo : 0xB3000001 ≤ lo) (hhi : hi ≤ 0xC2CE8ED0)
    (hcov : ∀ n, lo ≤ n → n < hi → CoveredOrExc PointwiseExceptions.negExceptions n) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEval.expf mode) lo hi := by
  intro n hnlo hnhi
  rcases hcov n hnlo hnhi with hexc | ⟨u, hgrid, haway⟩
  · exact PointwiseExceptions.correctAt_of_mem_negExceptions hmode hexc
  · by_cases hsp1 : n = 0xC236BD8C
    · subst hsp1
      exact PointwiseExceptions.correctAt_of_mem_negExceptions hmode (by decide)
    · by_cases hsp2 : n = 0xBB7FFFFF
      · subst hsp2
        exact PointwiseExceptions.correctAt_of_mem_negExceptions hmode (by decide)
      · have hmod : (BitVec.ofNat 32 n).toNat = n := by
          rw [BitVec.toNat_ofNat]; omega
        have hof : (Model.ofNatBits n : Model .binary32) = f32(BitVec.ofNat 32 n) := rfl
        rw [hof] at hgrid haway ⊢
        exact ProductError.correctAt_of_awayFromGrid_neg hmode (BitVec.ofNat 32 n)
          (by omega) (by omega) (by omega) (by omega) hgrid haway

theorem holdsOnBits_of_checkD2Chunk_pos (hmode : mode ∈ cModes) {lo hi : Nat}
    {blobs : List (Nat × Nat)}
    (hlo : 0x33800000 ≤ lo) (hhi : hi ≤ 0x42B17218)
    (hok : checkD2Chunk PointwiseExceptions.posExceptions lo hi blobs = true) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEval.expf mode) lo hi := by
  unfold checkD2Chunk at hok
  cases h : checkD2Blobs PointwiseExceptions.posExceptions lo blobs with
  | none => simp [h] at hok
  | some endCur =>
    simp only [h] at hok
    have heq : endCur = hi := Nat.eq_of_beq_eq_true hok
    subst heq
    exact holdsOnBits_pos_of_coveredOrExc hmode hlo hhi (checkD2Blobs_sound h).2

theorem holdsOnBits_of_checkD2Chunk_neg (hmode : mode ∈ cModes) {lo hi : Nat}
    {blobs : List (Nat × Nat)}
    (hlo : 0xB3000001 ≤ lo) (hhi : hi ≤ 0xC2CE8ED0)
    (hok : checkD2Chunk PointwiseExceptions.negExceptions lo hi blobs = true) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEval.expf mode) lo hi := by
  unfold checkD2Chunk at hok
  cases h : checkD2Blobs PointwiseExceptions.negExceptions lo blobs with
  | none => simp [h] at hok
  | some endCur =>
    simp only [h] at hok
    have heq : endCur = hi := Nat.eq_of_beq_eq_true hok
    subst heq
    exact holdsOnBits_neg_of_coveredOrExc hmode hlo hhi (checkD2Blobs_sound h).2

theorem holdsOnBits_of_checkD3Chunk_pos (hmode : mode ∈ cModes) {lo hi : Nat}
    {blobs : List (Nat × Nat)}
    (hlo : 0x33800000 ≤ lo) (hhi : hi ≤ 0x42B17218)
    (hok : checkD3Chunk PointwiseExceptions.posExceptions lo hi blobs = true) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEval.expf mode) lo hi := by
  unfold checkD3Chunk at hok
  cases h : checkD3Blobs PointwiseExceptions.posExceptions lo blobs with
  | none => simp [h] at hok
  | some endCur =>
    simp only [h] at hok
    have heq : endCur = hi := Nat.eq_of_beq_eq_true hok
    subst heq
    exact holdsOnBits_pos_of_coveredOrExc hmode hlo hhi (checkD3Blobs_sound h).2

theorem holdsOnBits_of_checkD3Chunk_neg (hmode : mode ∈ cModes) {lo hi : Nat}
    {blobs : List (Nat × Nat)}
    (hlo : 0xB3000001 ≤ lo) (hhi : hi ≤ 0xC2CE8ED0)
    (hok : checkD3Chunk PointwiseExceptions.negExceptions lo hi blobs = true) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEval.expf mode) lo hi := by
  unfold checkD3Chunk at hok
  cases h : checkD3Blobs PointwiseExceptions.negExceptions lo blobs with
  | none => simp [h] at hok
  | some endCur =>
    simp only [h] at hok
    have heq : endCur = hi := Nat.eq_of_beq_eq_true hok
    subst heq
    exact holdsOnBits_neg_of_coveredOrExc hmode hlo hhi (checkD3Blobs_sound h).2

/-! ### Axiom guards -/

/--
info: 'LibcMath.Kernels.Expf.MainPath.Tmd.Verify.holdsOnBits_of_checkD2Chunk_pos' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms holdsOnBits_of_checkD2Chunk_pos

/--
info: 'LibcMath.Kernels.Expf.MainPath.Tmd.Verify.holdsOnBits_of_checkD2Chunk_neg' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms holdsOnBits_of_checkD2Chunk_neg

/--
info: 'LibcMath.Kernels.Expf.MainPath.Tmd.Verify.holdsOnBits_of_checkD3Chunk_pos' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms holdsOnBits_of_checkD3Chunk_pos

/--
info: 'LibcMath.Kernels.Expf.MainPath.Tmd.Verify.holdsOnBits_of_checkD3Chunk_neg' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms holdsOnBits_of_checkD3Chunk_neg

end LibcMath.Kernels.Expf.MainPath.Tmd.Verify
