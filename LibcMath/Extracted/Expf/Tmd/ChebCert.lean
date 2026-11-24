import Mathlib.Analysis.SpecialFunctions.Trigonometric.Inverse
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring

/-!
# Chebyshev-L1 Coppersmith Certificate Verifiers for TMD

Pure-`Nat` certificate checkers and soundness proofs for excluding integer lattice points
`(i, y) ∈ ℤ²` near a polynomial approximation `y ≈ P(i)` on `|i| ≤ R`.

For a bivariate integer polynomial `Q(X, Y)` that is odd everywhere on `ℤ²` (`Q(i, y) ≡ 1 (mod 2)`),
any `(i, y) ∈ ℤ²` satisfies `1 ≤ |Q(i, y)|`. If `|Q(R * t, P(R * t) + E)| < 1` for all `|t| ≤ 1`
and `|E| ≤ M / 2 ^ 64`, then no integer `y` can lie within `M / 2 ^ 64` of `P(i)` for any
integer `i` with `|i| ≤ R`.

We implement two pure-`Nat` checkers designed for fast Lean 4 kernel reduction (`decide +kernel`):

* `checkPackedD2M2`: degree `d = 2` in `P`, degree `m = 2` in `Y` (9 coefficients, 32 bits/slot,
  288 bits total, Chebyshev scale 8), proved sound in `awayFromInt_of_checkPackedD2M2`.
* `checkPackedD3M3`: degree `d = 3` in `P`, degree `m = 3` in `Y` (22 coefficients, 52 bits/slot,
  1144 bits total, Chebyshev scale 256), proved sound in `awayFromInt_of_checkPackedD3M3`.
-/

namespace LibcMath.Extracted.Expf.Tmd.ChebCert

/-- Fixed-point scale `2 ^ 64`. -/
def S64 : Nat := 18446744073709551616

/-- Squared fixed-point scale `2 ^ 128`. -/
def S128 : Nat := 340282366920938463463374607431768211456

/-- Slot radix `2 ^ 32` for `checkPackedD2M2`. -/
def B32 : Nat := 4294967296

/-- Slot radix `2 ^ 52` for `checkPackedD3M3`. -/
def B52 : Nat := 4503599627370496

/-- Pure-`Nat` absolute difference `|a - b|`. -/
@[inline] def natAbsDiff (a b : Nat) : Nat :=
  if Nat.ble a b then Nat.sub b a else Nat.sub a b

/-- Zigzag decoding of a signed integer into a `(pos, neg)` pair of `Nat`s representing
`(pos : ℤ) - (neg : ℤ)`. -/
def unpackSigned (z : Nat) : Nat × Nat :=
  if Nat.beq (Nat.mod z 2) 0 then (Nat.div z 2, 0) else (0, Nat.div (Nat.add z 1) 2)

/-! ### Executable pure-`Nat` checkers -/

/-- Pure-`Nat` Chebyshev-L1 certificate checker for `d = 2, m = 2` on unpacked `(pos, neg)`
coefficient pairs. -/
def checkCoeffsD2M2 (R M c0 c1 c2
    p00 n00 p01 n01 p02 n02 p03 n03 p04 n04
    p10 n10 p11 n11 p12 n12 p20 n20 : Nat) : Bool :=
  -- 1. Parity checks ensuring Q(i, y) ≡ 1 (mod 2) for all (i, y) ∈ ℤ².
  let ok0 := Nat.beq (Nat.mod (Nat.add p00 n00) 2) 1
  let ok1 := Nat.beq (Nat.mod
    (Nat.add (Nat.add p01 n01)
      (Nat.add (Nat.add p02 n02)
        (Nat.add (Nat.add p03 n03) (Nat.add p04 n04)))) 2) 0
  let ok2 := Nat.beq (Nat.mod (Nat.add (Nat.add p10 n10) (Nat.add p20 n20)) 2) 0
  let ok3 := Nat.beq (Nat.mod (Nat.add (Nat.add p11 n11) (Nat.add p12 n12)) 2) 0
  if !(ok0 && ok1 && ok2 && ok3) then false else
  -- 2. Scale P(R * t) coefficients and approximate P(R * t)^2 (scaled by 2^64).
  let R2 := Nat.mul R R
  let R3 := Nat.mul R2 R
  let R4 := Nat.mul R2 R2
  let u0 := c0
  let u1 := Nat.mul c1 R
  let u2 := Nat.mul c2 R2
  let q0 := Nat.div (Nat.mul u0 u0) S64
  let q1 := Nat.div (Nat.mul 2 (Nat.mul u0 u1)) S64
  let q2 := Nat.div (Nat.add (Nat.mul u1 u1) (Nat.mul 2 (Nat.mul u0 u2))) S64
  let q3 := Nat.div (Nat.mul 2 (Nat.mul u1 u2)) S64
  let q4 := Nat.div (Nat.mul u2 u2) S64
  let p11' := Nat.mul p11 R
  let n11' := Nat.mul n11 R
  let p12' := Nat.mul p12 R2
  let n12' := Nat.mul n12 R2
  -- 3. r = 0 monomial coefficients (scaled by 2^64).
  let ap0 := Nat.add (Nat.mul p00 S64) (Nat.add (Nat.mul p10 u0) (Nat.mul p20 q0))
  let an0 := Nat.add (Nat.mul n00 S64) (Nat.add (Nat.mul n10 u0) (Nat.mul n20 q0))
  let ap1 := Nat.add (Nat.mul (Nat.mul p01 R) S64)
    (Nat.add (Nat.mul p10 u1) (Nat.add (Nat.mul p11' u0) (Nat.mul p20 q1)))
  let an1 := Nat.add (Nat.mul (Nat.mul n01 R) S64)
    (Nat.add (Nat.mul n10 u1) (Nat.add (Nat.mul n11' u0) (Nat.mul n20 q1)))
  let ap2 := Nat.add (Nat.mul (Nat.mul p02 R2) S64)
    (Nat.add (Nat.mul p10 u2)
      (Nat.add (Nat.mul p11' u1) (Nat.add (Nat.mul p12' u0) (Nat.mul p20 q2))))
  let an2 := Nat.add (Nat.mul (Nat.mul n02 R2) S64)
    (Nat.add (Nat.mul n10 u2)
      (Nat.add (Nat.mul n11' u1) (Nat.add (Nat.mul n12' u0) (Nat.mul n20 q2))))
  let ap3 := Nat.add (Nat.mul (Nat.mul p03 R3) S64)
    (Nat.add (Nat.mul p11' u2) (Nat.add (Nat.mul p12' u1) (Nat.mul p20 q3)))
  let an3 := Nat.add (Nat.mul (Nat.mul n03 R3) S64)
    (Nat.add (Nat.mul n11' u2) (Nat.add (Nat.mul n12' u1) (Nat.mul n20 q3)))
  let ap4 := Nat.add (Nat.mul (Nat.mul p04 R4) S64)
    (Nat.add (Nat.mul p12' u2) (Nat.mul p20 q4))
  let an4 := Nat.add (Nat.mul (Nat.mul n04 R4) S64)
    (Nat.add (Nat.mul n12' u2) (Nat.mul n20 q4))
  -- 4. r = 0 Chebyshev basis (scaled by 8 * 2^64).
  let t0 := natAbsDiff
    (Nat.add (Nat.mul 8 ap0) (Nat.add (Nat.mul 4 ap2) (Nat.mul 3 ap4)))
    (Nat.add (Nat.mul 8 an0) (Nat.add (Nat.mul 4 an2) (Nat.mul 3 an4)))
  let t1 := natAbsDiff
    (Nat.add (Nat.mul 8 ap1) (Nat.mul 6 ap3))
    (Nat.add (Nat.mul 8 an1) (Nat.mul 6 an3))
  let t2 := natAbsDiff
    (Nat.add (Nat.mul 4 ap2) (Nat.mul 4 ap4))
    (Nat.add (Nat.mul 4 an2) (Nat.mul 4 an4))
  let t3 := natAbsDiff (Nat.mul 2 ap3) (Nat.mul 2 an3)
  let t4 := natAbsDiff ap4 an4
  -- 5. r = 1 Chebyshev basis (scaled by 8 * 2^64).
  let dp0 := Nat.div
    (Nat.mul (Nat.add (Nat.mul p10 S64) (Nat.mul 2 (Nat.mul p20 u0))) M) S64
  let dn0 := Nat.div
    (Nat.mul (Nat.add (Nat.mul n10 S64) (Nat.mul 2 (Nat.mul n20 u0))) M) S64
  let dp1 := Nat.div
    (Nat.mul (Nat.add (Nat.mul p11' S64) (Nat.mul 2 (Nat.mul p20 u1))) M) S64
  let dn1 := Nat.div
    (Nat.mul (Nat.add (Nat.mul n11' S64) (Nat.mul 2 (Nat.mul n20 u1))) M) S64
  let dp2 := Nat.div
    (Nat.mul (Nat.add (Nat.mul p12' S64) (Nat.mul 2 (Nat.mul p20 u2))) M) S64
  let dn2 := Nat.div
    (Nat.mul (Nat.add (Nat.mul n12' S64) (Nat.mul 2 (Nat.mul n20 u2))) M) S64
  let w0 := natAbsDiff
    (Nat.add (Nat.mul 8 dp0) (Nat.mul 4 dp2))
    (Nat.add (Nat.mul 8 dn0) (Nat.mul 4 dn2))
  let w1 := natAbsDiff (Nat.mul 8 dp1) (Nat.mul 8 dn1)
  let w2 := natAbsDiff (Nat.mul 4 dp2) (Nat.mul 4 dn2)
  -- 6. r = 2 upper bound (rounded up).
  let q20Norm := Nat.add p20 n20
  let v0 := Nat.add 1 (Nat.div (Nat.mul 8 (Nat.mul q20Norm (Nat.mul M M))) S64)
  -- 7. Rigorous truncation slack and strict L1 bound check (< 8 * 2^64).
  let slack := Nat.add (Nat.mul 40 q20Norm) 24
  let l1 := Nat.add slack
    (Nat.add t0 (Nat.add t1 (Nat.add t2 (Nat.add t3 (Nat.add t4
      (Nat.add w0 (Nat.add w1 (Nat.add w2 v0))))))))
  Nat.blt l1 (Nat.mul 8 S64)

/-- Packed pure-`Nat` Chebyshev-L1 certificate checker for `d = 2, m = 2`
(9 coefficients, 32 bits per slot, LSB first: `q00..q04, q10..q12, q20`). -/
def checkPackedD2M2 (R M c0 c1 c2 packedQ : Nat) : Bool :=
  let u00 := unpackSigned (Nat.mod packedQ B32); let q0 := Nat.div packedQ B32
  let u01 := unpackSigned (Nat.mod q0 B32); let q1 := Nat.div q0 B32
  let u02 := unpackSigned (Nat.mod q1 B32); let q2 := Nat.div q1 B32
  let u03 := unpackSigned (Nat.mod q2 B32); let q3 := Nat.div q2 B32
  let u04 := unpackSigned (Nat.mod q3 B32); let q4 := Nat.div q3 B32
  let u10 := unpackSigned (Nat.mod q4 B32); let q5 := Nat.div q4 B32
  let u11 := unpackSigned (Nat.mod q5 B32); let q6 := Nat.div q5 B32
  let u12 := unpackSigned (Nat.mod q6 B32); let q7 := Nat.div q6 B32
  let u20 := unpackSigned (Nat.mod q7 B32)
  checkCoeffsD2M2 R M c0 c1 c2
    u00.1 u00.2 u01.1 u01.2 u02.1 u02.2 u03.1 u03.2 u04.1 u04.2
    u10.1 u10.2 u11.1 u11.2 u12.1 u12.2 u20.1 u20.2

/-- Pure-`Nat` Chebyshev-L1 certificate checker for `d = 3, m = 3` on unpacked `(pos, neg)`
coefficient pairs. -/
def checkCoeffsD3M3 (R M c0 c1 c2 c3
    p00 n00 p01 n01 p02 n02 p03 n03 p04 n04
    p05 n05 p06 n06 p07 n07 p08 n08 p09 n09
    p10 n10 p11 n11 p12 n12 p13 n13 p14 n14 p15 n15 p16 n16
    p20 n20 p21 n21 p22 n22 p23 n23
    p30 n30 : Nat) : Bool :=
  -- 1. Parity checks ensuring Q(i, y) ≡ 1 (mod 2) for all (i, y) ∈ ℤ².
  let ok0 := Nat.beq (Nat.mod (Nat.add p00 n00) 2) 1
  let ok1 := Nat.beq (Nat.mod
    (Nat.add (Nat.add p01 n01)
      (Nat.add (Nat.add p02 n02)
        (Nat.add (Nat.add p03 n03)
          (Nat.add (Nat.add p04 n04)
            (Nat.add (Nat.add p05 n05)
              (Nat.add (Nat.add p06 n06)
                (Nat.add (Nat.add p07 n07)
                  (Nat.add (Nat.add p08 n08) (Nat.add p09 n09))))))))) 2) 0
  let ok2 := Nat.beq (Nat.mod
    (Nat.add (Nat.add p10 n10) (Nat.add (Nat.add p20 n20) (Nat.add p30 n30))) 2) 0
  let ok3 := Nat.beq (Nat.mod
    (Nat.add (Nat.add p11 n11)
      (Nat.add (Nat.add p12 n12)
        (Nat.add (Nat.add p13 n13)
          (Nat.add (Nat.add p14 n14)
            (Nat.add (Nat.add p15 n15)
              (Nat.add (Nat.add p16 n16)
                (Nat.add (Nat.add p21 n21)
                  (Nat.add (Nat.add p22 n22) (Nat.add p23 n23))))))))) 2) 0
  if !(ok0 && ok1 && ok2 && ok3) then false else
  -- 2. Powers of R and P(R * t), P^2, P^3 (scaled by 2^64).
  let R2 := Nat.mul R R
  let R3 := Nat.mul R2 R
  let R4 := Nat.mul R2 R2
  let R5 := Nat.mul R4 R
  let R6 := Nat.mul R3 R3
  let R7 := Nat.mul R6 R
  let R8 := Nat.mul R4 R4
  let R9 := Nat.mul R8 R
  let u0 := c0
  let u1 := Nat.mul c1 R
  let u2 := Nat.mul c2 R2
  let u3 := Nat.mul c3 R3
  let q0 := Nat.div (Nat.mul u0 u0) S64
  let q1 := Nat.div (Nat.mul 2 (Nat.mul u0 u1)) S64
  let q2 := Nat.div (Nat.add (Nat.mul u1 u1) (Nat.mul 2 (Nat.mul u0 u2))) S64
  let q3 := Nat.div (Nat.mul 2 (Nat.add (Nat.mul u0 u3) (Nat.mul u1 u2))) S64
  let q4 := Nat.div (Nat.add (Nat.mul u2 u2) (Nat.mul 2 (Nat.mul u1 u3))) S64
  let q5 := Nat.div (Nat.mul 2 (Nat.mul u2 u3)) S64
  let q6 := Nat.div (Nat.mul u3 u3) S64
  let s0 := Nat.div (Nat.mul q0 u0) S64
  let s1 := Nat.div (Nat.add (Nat.mul q0 u1) (Nat.mul q1 u0)) S64
  let s2 := Nat.div (Nat.add (Nat.mul q0 u2) (Nat.add (Nat.mul q1 u1) (Nat.mul q2 u0))) S64
  let s3 := Nat.div (Nat.add (Nat.mul q0 u3)
    (Nat.add (Nat.mul q1 u2) (Nat.add (Nat.mul q2 u1) (Nat.mul q3 u0)))) S64
  let s4 := Nat.div (Nat.add (Nat.mul q1 u3)
    (Nat.add (Nat.mul q2 u2) (Nat.add (Nat.mul q3 u1) (Nat.mul q4 u0)))) S64
  let s5 := Nat.div (Nat.add (Nat.mul q2 u3)
    (Nat.add (Nat.mul q3 u2) (Nat.add (Nat.mul q4 u1) (Nat.mul q5 u0)))) S64
  let s6 := Nat.div (Nat.add (Nat.mul q3 u3)
    (Nat.add (Nat.mul q4 u2) (Nat.add (Nat.mul q5 u1) (Nat.mul q6 u0)))) S64
  let s7 := Nat.div (Nat.add (Nat.mul q4 u3) (Nat.add (Nat.mul q5 u2) (Nat.mul q6 u1))) S64
  let s8 := Nat.div (Nat.add (Nat.mul q5 u3) (Nat.mul q6 u2)) S64
  let s9 := Nat.div (Nat.mul q6 u3) S64
  -- 3. Pre-scale Q(R * t, Y) coefficients by powers of R.
  let p01' := Nat.mul p01 R; let n01' := Nat.mul n01 R
  let p02' := Nat.mul p02 R2; let n02' := Nat.mul n02 R2
  let p03' := Nat.mul p03 R3; let n03' := Nat.mul n03 R3
  let p04' := Nat.mul p04 R4; let n04' := Nat.mul n04 R4
  let p05' := Nat.mul p05 R5; let n05' := Nat.mul n05 R5
  let p06' := Nat.mul p06 R6; let n06' := Nat.mul n06 R6
  let p07' := Nat.mul p07 R7; let n07' := Nat.mul n07 R7
  let p08' := Nat.mul p08 R8; let n08' := Nat.mul n08 R8
  let p09' := Nat.mul p09 R9; let n09' := Nat.mul n09 R9
  let p11' := Nat.mul p11 R; let n11' := Nat.mul n11 R
  let p12' := Nat.mul p12 R2; let n12' := Nat.mul n12 R2
  let p13' := Nat.mul p13 R3; let n13' := Nat.mul n13 R3
  let p14' := Nat.mul p14 R4; let n14' := Nat.mul n14 R4
  let p15' := Nat.mul p15 R5; let n15' := Nat.mul n15 R5
  let p16' := Nat.mul p16 R6; let n16' := Nat.mul n16 R6
  let p21' := Nat.mul p21 R; let n21' := Nat.mul n21 R
  let p22' := Nat.mul p22 R2; let n22' := Nat.mul n22 R2
  let p23' := Nat.mul p23 R3; let n23' := Nat.mul n23 R3
  -- 4. r = 0 monomial coefficients (deg 9, scaled by 2^64).
  let ap0 := Nat.add (Nat.mul p00 S64)
    (Nat.add (Nat.mul p10 u0) (Nat.add (Nat.mul p20 q0) (Nat.mul p30 s0)))
  let an0 := Nat.add (Nat.mul n00 S64)
    (Nat.add (Nat.mul n10 u0) (Nat.add (Nat.mul n20 q0) (Nat.mul n30 s0)))
  let ap1 := Nat.add (Nat.mul p01' S64)
    (Nat.add (Nat.add (Nat.mul p10 u1) (Nat.mul p11' u0))
      (Nat.add (Nat.add (Nat.mul p20 q1) (Nat.mul p21' q0)) (Nat.mul p30 s1)))
  let an1 := Nat.add (Nat.mul n01' S64)
    (Nat.add (Nat.add (Nat.mul n10 u1) (Nat.mul n11' u0))
      (Nat.add (Nat.add (Nat.mul n20 q1) (Nat.mul n21' q0)) (Nat.mul n30 s1)))
  let ap2 := Nat.add (Nat.mul p02' S64)
    (Nat.add (Nat.add (Nat.mul p10 u2) (Nat.add (Nat.mul p11' u1) (Nat.mul p12' u0)))
      (Nat.add (Nat.add (Nat.mul p20 q2) (Nat.add (Nat.mul p21' q1) (Nat.mul p22' q0)))
        (Nat.mul p30 s2)))
  let an2 := Nat.add (Nat.mul n02' S64)
    (Nat.add (Nat.add (Nat.mul n10 u2) (Nat.add (Nat.mul n11' u1) (Nat.mul n12' u0)))
      (Nat.add (Nat.add (Nat.mul n20 q2) (Nat.add (Nat.mul n21' q1) (Nat.mul n22' q0)))
        (Nat.mul n30 s2)))
  let ap3 := Nat.add (Nat.mul p03' S64)
    (Nat.add (Nat.add (Nat.mul p10 u3)
        (Nat.add (Nat.mul p11' u2) (Nat.add (Nat.mul p12' u1) (Nat.mul p13' u0))))
      (Nat.add (Nat.add (Nat.mul p20 q3)
          (Nat.add (Nat.mul p21' q2) (Nat.add (Nat.mul p22' q1) (Nat.mul p23' q0))))
        (Nat.mul p30 s3)))
  let an3 := Nat.add (Nat.mul n03' S64)
    (Nat.add (Nat.add (Nat.mul n10 u3)
        (Nat.add (Nat.mul n11' u2) (Nat.add (Nat.mul n12' u1) (Nat.mul n13' u0))))
      (Nat.add (Nat.add (Nat.mul n20 q3)
          (Nat.add (Nat.mul n21' q2) (Nat.add (Nat.mul n22' q1) (Nat.mul n23' q0))))
        (Nat.mul n30 s3)))
  let ap4 := Nat.add (Nat.mul p04' S64)
    (Nat.add (Nat.add (Nat.mul p11' u3)
        (Nat.add (Nat.mul p12' u2) (Nat.add (Nat.mul p13' u1) (Nat.mul p14' u0))))
      (Nat.add (Nat.add (Nat.mul p20 q4)
          (Nat.add (Nat.mul p21' q3) (Nat.add (Nat.mul p22' q2) (Nat.mul p23' q1))))
        (Nat.mul p30 s4)))
  let an4 := Nat.add (Nat.mul n04' S64)
    (Nat.add (Nat.add (Nat.mul n11' u3)
        (Nat.add (Nat.mul n12' u2) (Nat.add (Nat.mul n13' u1) (Nat.mul n14' u0))))
      (Nat.add (Nat.add (Nat.mul n20 q4)
          (Nat.add (Nat.mul n21' q3) (Nat.add (Nat.mul n22' q2) (Nat.mul n23' q1))))
        (Nat.mul n30 s4)))
  let ap5 := Nat.add (Nat.mul p05' S64)
    (Nat.add (Nat.add (Nat.mul p12' u3)
        (Nat.add (Nat.mul p13' u2) (Nat.add (Nat.mul p14' u1) (Nat.mul p15' u0))))
      (Nat.add (Nat.add (Nat.mul p20 q5)
          (Nat.add (Nat.mul p21' q4) (Nat.add (Nat.mul p22' q3) (Nat.mul p23' q2))))
        (Nat.mul p30 s5)))
  let an5 := Nat.add (Nat.mul n05' S64)
    (Nat.add (Nat.add (Nat.mul n12' u3)
        (Nat.add (Nat.mul n13' u2) (Nat.add (Nat.mul n14' u1) (Nat.mul n15' u0))))
      (Nat.add (Nat.add (Nat.mul n20 q5)
          (Nat.add (Nat.mul n21' q4) (Nat.add (Nat.mul n22' q3) (Nat.mul n23' q2))))
        (Nat.mul n30 s5)))
  let ap6 := Nat.add (Nat.mul p06' S64)
    (Nat.add (Nat.add (Nat.mul p13' u3)
        (Nat.add (Nat.mul p14' u2) (Nat.add (Nat.mul p15' u1) (Nat.mul p16' u0))))
      (Nat.add (Nat.add (Nat.mul p20 q6)
          (Nat.add (Nat.mul p21' q5) (Nat.add (Nat.mul p22' q4) (Nat.mul p23' q3))))
        (Nat.mul p30 s6)))
  let an6 := Nat.add (Nat.mul n06' S64)
    (Nat.add (Nat.add (Nat.mul n13' u3)
        (Nat.add (Nat.mul n14' u2) (Nat.add (Nat.mul n15' u1) (Nat.mul n16' u0))))
      (Nat.add (Nat.add (Nat.mul n20 q6)
          (Nat.add (Nat.mul n21' q5) (Nat.add (Nat.mul n22' q4) (Nat.mul n23' q3))))
        (Nat.mul n30 s6)))
  let ap7 := Nat.add (Nat.mul p07' S64)
    (Nat.add (Nat.add (Nat.mul p14' u3) (Nat.add (Nat.mul p15' u2) (Nat.mul p16' u1)))
      (Nat.add (Nat.add (Nat.mul p21' q6) (Nat.add (Nat.mul p22' q5) (Nat.mul p23' q4)))
        (Nat.mul p30 s7)))
  let an7 := Nat.add (Nat.mul n07' S64)
    (Nat.add (Nat.add (Nat.mul n14' u3) (Nat.add (Nat.mul n15' u2) (Nat.mul n16' u1)))
      (Nat.add (Nat.add (Nat.mul n21' q6) (Nat.add (Nat.mul n22' q5) (Nat.mul n23' q4)))
        (Nat.mul n30 s7)))
  let ap8 := Nat.add (Nat.mul p08' S64)
    (Nat.add (Nat.add (Nat.mul p15' u3) (Nat.mul p16' u2))
      (Nat.add (Nat.add (Nat.mul p22' q6) (Nat.mul p23' q5)) (Nat.mul p30 s8)))
  let an8 := Nat.add (Nat.mul n08' S64)
    (Nat.add (Nat.add (Nat.mul n15' u3) (Nat.mul n16' u2))
      (Nat.add (Nat.add (Nat.mul n22' q6) (Nat.mul n23' q5)) (Nat.mul n30 s8)))
  let ap9 := Nat.add (Nat.mul p09' S64)
    (Nat.add (Nat.mul p16' u3) (Nat.add (Nat.mul p23' q6) (Nat.mul p30 s9)))
  let an9 := Nat.add (Nat.mul n09' S64)
    (Nat.add (Nat.mul n16' u3) (Nat.add (Nat.mul n23' q6) (Nat.mul n30 s9)))
  -- 5. r = 0 Chebyshev basis (scaled by 256 * 2^64).
  let t0 := natAbsDiff
    (Nat.add (Nat.mul 256 ap0) (Nat.add (Nat.mul 128 ap2)
      (Nat.add (Nat.mul 96 ap4) (Nat.add (Nat.mul 80 ap6) (Nat.mul 70 ap8)))))
    (Nat.add (Nat.mul 256 an0) (Nat.add (Nat.mul 128 an2)
      (Nat.add (Nat.mul 96 an4) (Nat.add (Nat.mul 80 an6) (Nat.mul 70 an8)))))
  let t1 := natAbsDiff
    (Nat.add (Nat.mul 256 ap1) (Nat.add (Nat.mul 192 ap3)
      (Nat.add (Nat.mul 160 ap5) (Nat.add (Nat.mul 140 ap7) (Nat.mul 126 ap9)))))
    (Nat.add (Nat.mul 256 an1) (Nat.add (Nat.mul 192 an3)
      (Nat.add (Nat.mul 160 an5) (Nat.add (Nat.mul 140 an7) (Nat.mul 126 an9)))))
  let t2 := natAbsDiff
    (Nat.add (Nat.mul 128 ap2) (Nat.add (Nat.mul 128 ap4)
      (Nat.add (Nat.mul 120 ap6) (Nat.mul 112 ap8))))
    (Nat.add (Nat.mul 128 an2) (Nat.add (Nat.mul 128 an4)
      (Nat.add (Nat.mul 120 an6) (Nat.mul 112 an8))))
  let t3 := natAbsDiff
    (Nat.add (Nat.mul 64 ap3) (Nat.add (Nat.mul 80 ap5)
      (Nat.add (Nat.mul 84 ap7) (Nat.mul 84 ap9))))
    (Nat.add (Nat.mul 64 an3) (Nat.add (Nat.mul 80 an5)
      (Nat.add (Nat.mul 84 an7) (Nat.mul 84 an9))))
  let t4 := natAbsDiff
    (Nat.add (Nat.mul 32 ap4) (Nat.add (Nat.mul 48 ap6) (Nat.mul 56 ap8)))
    (Nat.add (Nat.mul 32 an4) (Nat.add (Nat.mul 48 an6) (Nat.mul 56 an8)))
  let t5 := natAbsDiff
    (Nat.add (Nat.mul 16 ap5) (Nat.add (Nat.mul 28 ap7) (Nat.mul 36 ap9)))
    (Nat.add (Nat.mul 16 an5) (Nat.add (Nat.mul 28 an7) (Nat.mul 36 an9)))
  let t6 := natAbsDiff
    (Nat.add (Nat.mul 8 ap6) (Nat.mul 16 ap8))
    (Nat.add (Nat.mul 8 an6) (Nat.mul 16 an8))
  let t7 := natAbsDiff
    (Nat.add (Nat.mul 4 ap7) (Nat.mul 9 ap9))
    (Nat.add (Nat.mul 4 an7) (Nat.mul 9 an9))
  let t8 := natAbsDiff (Nat.mul 2 ap8) (Nat.mul 2 an8)
  let t9 := natAbsDiff ap9 an9
  -- 6. r = 1 monomial coefficients and Chebyshev basis (deg 6, scaled by 256 * 2^64).
  let bp0 := Nat.add (Nat.mul p10 S64)
    (Nat.add (Nat.mul 2 (Nat.mul p20 u0)) (Nat.mul 3 (Nat.mul p30 q0)))
  let bn0 := Nat.add (Nat.mul n10 S64)
    (Nat.add (Nat.mul 2 (Nat.mul n20 u0)) (Nat.mul 3 (Nat.mul n30 q0)))
  let bp1 := Nat.add (Nat.mul p11' S64)
    (Nat.add (Nat.mul 2 (Nat.add (Nat.mul p20 u1) (Nat.mul p21' u0)))
      (Nat.mul 3 (Nat.mul p30 q1)))
  let bn1 := Nat.add (Nat.mul n11' S64)
    (Nat.add (Nat.mul 2 (Nat.add (Nat.mul n20 u1) (Nat.mul n21' u0)))
      (Nat.mul 3 (Nat.mul n30 q1)))
  let bp2 := Nat.add (Nat.mul p12' S64)
    (Nat.add (Nat.mul 2 (Nat.add (Nat.mul p20 u2) (Nat.add (Nat.mul p21' u1) (Nat.mul p22' u0))))
      (Nat.mul 3 (Nat.mul p30 q2)))
  let bn2 := Nat.add (Nat.mul n12' S64)
    (Nat.add (Nat.mul 2 (Nat.add (Nat.mul n20 u2) (Nat.add (Nat.mul n21' u1) (Nat.mul n22' u0))))
      (Nat.mul 3 (Nat.mul n30 q2)))
  let bp3 := Nat.add (Nat.mul p13' S64)
    (Nat.add (Nat.mul 2 (Nat.add (Nat.mul p20 u3)
        (Nat.add (Nat.mul p21' u2) (Nat.add (Nat.mul p22' u1) (Nat.mul p23' u0)))))
      (Nat.mul 3 (Nat.mul p30 q3)))
  let bn3 := Nat.add (Nat.mul n13' S64)
    (Nat.add (Nat.mul 2 (Nat.add (Nat.mul n20 u3)
        (Nat.add (Nat.mul n21' u2) (Nat.add (Nat.mul n22' u1) (Nat.mul n23' u0)))))
      (Nat.mul 3 (Nat.mul n30 q3)))
  let bp4 := Nat.add (Nat.mul p14' S64)
    (Nat.add (Nat.mul 2 (Nat.add (Nat.mul p21' u3)
        (Nat.add (Nat.mul p22' u2) (Nat.mul p23' u1))))
      (Nat.mul 3 (Nat.mul p30 q4)))
  let bn4 := Nat.add (Nat.mul n14' S64)
    (Nat.add (Nat.mul 2 (Nat.add (Nat.mul n21' u3)
        (Nat.add (Nat.mul n22' u2) (Nat.mul n23' u1))))
      (Nat.mul 3 (Nat.mul n30 q4)))
  let bp5 := Nat.add (Nat.mul p15' S64)
    (Nat.add (Nat.mul 2 (Nat.add (Nat.mul p22' u3) (Nat.mul p23' u2)))
      (Nat.mul 3 (Nat.mul p30 q5)))
  let bn5 := Nat.add (Nat.mul n15' S64)
    (Nat.add (Nat.mul 2 (Nat.add (Nat.mul n22' u3) (Nat.mul n23' u2)))
      (Nat.mul 3 (Nat.mul n30 q5)))
  let bp6 := Nat.add (Nat.mul p16' S64)
    (Nat.add (Nat.mul 2 (Nat.mul p23' u3)) (Nat.mul 3 (Nat.mul p30 q6)))
  let bn6 := Nat.add (Nat.mul n16' S64)
    (Nat.add (Nat.mul 2 (Nat.mul n23' u3)) (Nat.mul 3 (Nat.mul n30 q6)))
  let dp0 := Nat.div (Nat.mul bp0 M) S64; let dn0 := Nat.div (Nat.mul bn0 M) S64
  let dp1 := Nat.div (Nat.mul bp1 M) S64; let dn1 := Nat.div (Nat.mul bn1 M) S64
  let dp2 := Nat.div (Nat.mul bp2 M) S64; let dn2 := Nat.div (Nat.mul bn2 M) S64
  let dp3 := Nat.div (Nat.mul bp3 M) S64; let dn3 := Nat.div (Nat.mul bn3 M) S64
  let dp4 := Nat.div (Nat.mul bp4 M) S64; let dn4 := Nat.div (Nat.mul bn4 M) S64
  let dp5 := Nat.div (Nat.mul bp5 M) S64; let dn5 := Nat.div (Nat.mul bn5 M) S64
  let dp6 := Nat.div (Nat.mul bp6 M) S64; let dn6 := Nat.div (Nat.mul bn6 M) S64
  let w0 := natAbsDiff
    (Nat.add (Nat.mul 256 dp0) (Nat.add (Nat.mul 128 dp2)
      (Nat.add (Nat.mul 96 dp4) (Nat.mul 80 dp6))))
    (Nat.add (Nat.mul 256 dn0) (Nat.add (Nat.mul 128 dn2)
      (Nat.add (Nat.mul 96 dn4) (Nat.mul 80 dn6))))
  let w1 := natAbsDiff
    (Nat.add (Nat.mul 256 dp1) (Nat.add (Nat.mul 192 dp3) (Nat.mul 160 dp5)))
    (Nat.add (Nat.mul 256 dn1) (Nat.add (Nat.mul 192 dn3) (Nat.mul 160 dn5)))
  let w2 := natAbsDiff
    (Nat.add (Nat.mul 128 dp2) (Nat.add (Nat.mul 128 dp4) (Nat.mul 120 dp6)))
    (Nat.add (Nat.mul 128 dn2) (Nat.add (Nat.mul 128 dn4) (Nat.mul 120 dn6)))
  let w3 := natAbsDiff
    (Nat.add (Nat.mul 64 dp3) (Nat.mul 80 dp5))
    (Nat.add (Nat.mul 64 dn3) (Nat.mul 80 dn5))
  let w4 := natAbsDiff
    (Nat.add (Nat.mul 32 dp4) (Nat.mul 48 dp6))
    (Nat.add (Nat.mul 32 dn4) (Nat.mul 48 dn6))
  let w5 := natAbsDiff (Nat.mul 16 dp5) (Nat.mul 16 dn5)
  let w6 := natAbsDiff (Nat.mul 8 dp6) (Nat.mul 8 dn6)
  -- 7. r = 2 Chebyshev basis (deg 3, scaled by 256 * 2^64).
  let M2 := Nat.mul M M
  let ep0 := Nat.add (Nat.mul p20 S64) (Nat.mul 3 (Nat.mul p30 u0))
  let en0 := Nat.add (Nat.mul n20 S64) (Nat.mul 3 (Nat.mul n30 u0))
  let ep1 := Nat.add (Nat.mul p21' S64) (Nat.mul 3 (Nat.mul p30 u1))
  let en1 := Nat.add (Nat.mul n21' S64) (Nat.mul 3 (Nat.mul n30 u1))
  let ep2 := Nat.add (Nat.mul p22' S64) (Nat.mul 3 (Nat.mul p30 u2))
  let en2 := Nat.add (Nat.mul n22' S64) (Nat.mul 3 (Nat.mul n30 u2))
  let ep3 := Nat.add (Nat.mul p23' S64) (Nat.mul 3 (Nat.mul p30 u3))
  let en3 := Nat.add (Nat.mul n23' S64) (Nat.mul 3 (Nat.mul n30 u3))
  let fp0 := Nat.div (Nat.mul ep0 M2) S128; let fn0 := Nat.div (Nat.mul en0 M2) S128
  let fp1 := Nat.div (Nat.mul ep1 M2) S128; let fn1 := Nat.div (Nat.mul en1 M2) S128
  let fp2 := Nat.div (Nat.mul ep2 M2) S128; let fn2 := Nat.div (Nat.mul en2 M2) S128
  let fp3 := Nat.div (Nat.mul ep3 M2) S128; let fn3 := Nat.div (Nat.mul en3 M2) S128
  let v0 := natAbsDiff
    (Nat.add (Nat.mul 256 fp0) (Nat.mul 128 fp2))
    (Nat.add (Nat.mul 256 fn0) (Nat.mul 128 fn2))
  let v1 := natAbsDiff
    (Nat.add (Nat.mul 256 fp1) (Nat.mul 192 fp3))
    (Nat.add (Nat.mul 256 fn1) (Nat.mul 192 fn3))
  let v2 := natAbsDiff (Nat.mul 128 fp2) (Nat.mul 128 fn2)
  let v3 := natAbsDiff (Nat.mul 64 fp3) (Nat.mul 64 fn3)
  -- 8. r = 3 upper bound (rounded up).
  let q3Norm := Nat.add p30 n30
  let M3 := Nat.mul M2 M
  let z0 := Nat.add 1 (Nat.div (Nat.mul 256 (Nat.mul q3Norm M3)) S128)
  -- 9. Rigorous truncation slack and strict L1 bound check (< 256 * 2^64).
  let q2Norm := Nat.add (Nat.add p20 n20)
    (Nat.add (Nat.add p21' n21') (Nat.add (Nat.add p22' n22') (Nat.add p23' n23')))
  let uTot := Nat.add u0 (Nat.add u1 (Nat.add u2 u3))
  let sErr := Nat.add 11 (Nat.div (Nat.mul 7 uTot) S64)
  let slack := Nat.add 2817
    (Nat.add (Nat.mul 1792 q2Norm)
      (Nat.add (Nat.mul 256 (Nat.mul q3Norm sErr))
        (Nat.div (Nat.mul 5376 (Nat.mul q3Norm M)) S64)))
  let l1 := Nat.add slack
    (Nat.add t0 (Nat.add t1 (Nat.add t2 (Nat.add t3 (Nat.add t4
      (Nat.add t5 (Nat.add t6 (Nat.add t7 (Nat.add t8 (Nat.add t9
        (Nat.add w0 (Nat.add w1 (Nat.add w2 (Nat.add w3 (Nat.add w4
          (Nat.add w5 (Nat.add w6 (Nat.add v0 (Nat.add v1 (Nat.add v2
            (Nat.add v3 z0)))))))))))))))))))))
  Nat.blt l1 (Nat.mul 256 S64)

/-- Packed pure-`Nat` Chebyshev-L1 certificate checker for `d = 3, m = 3`
(22 coefficients, 52 bits per slot, LSB first: `q00..q09, q10..q16, q20..q23, q30`). -/
def checkPackedD3M3 (R M c0 c1 c2 c3 packedQ : Nat) : Bool :=
  let u00 := unpackSigned (Nat.mod packedQ B52); let q0 := Nat.div packedQ B52
  let u01 := unpackSigned (Nat.mod q0 B52); let q1 := Nat.div q0 B52
  let u02 := unpackSigned (Nat.mod q1 B52); let q2 := Nat.div q1 B52
  let u03 := unpackSigned (Nat.mod q2 B52); let q3 := Nat.div q2 B52
  let u04 := unpackSigned (Nat.mod q3 B52); let q4 := Nat.div q3 B52
  let u05 := unpackSigned (Nat.mod q4 B52); let q5 := Nat.div q4 B52
  let u06 := unpackSigned (Nat.mod q5 B52); let q6 := Nat.div q5 B52
  let u07 := unpackSigned (Nat.mod q6 B52); let q7 := Nat.div q6 B52
  let u08 := unpackSigned (Nat.mod q7 B52); let q8 := Nat.div q7 B52
  let u09 := unpackSigned (Nat.mod q8 B52); let q9 := Nat.div q8 B52
  let u10 := unpackSigned (Nat.mod q9 B52); let q10 := Nat.div q9 B52
  let u11 := unpackSigned (Nat.mod q10 B52); let q11 := Nat.div q10 B52
  let u12 := unpackSigned (Nat.mod q11 B52); let q12 := Nat.div q11 B52
  let u13 := unpackSigned (Nat.mod q12 B52); let q13 := Nat.div q12 B52
  let u14 := unpackSigned (Nat.mod q13 B52); let q14 := Nat.div q13 B52
  let u15 := unpackSigned (Nat.mod q14 B52); let q15 := Nat.div q14 B52
  let u16 := unpackSigned (Nat.mod q15 B52); let q16 := Nat.div q15 B52
  let u20 := unpackSigned (Nat.mod q16 B52); let q17 := Nat.div q16 B52
  let u21 := unpackSigned (Nat.mod q17 B52); let q18 := Nat.div q17 B52
  let u22 := unpackSigned (Nat.mod q18 B52); let q19 := Nat.div q18 B52
  let u23 := unpackSigned (Nat.mod q19 B52); let q20 := Nat.div q19 B52
  let u30 := unpackSigned (Nat.mod q20 B52)
  checkCoeffsD3M3 R M c0 c1 c2 c3
    u00.1 u00.2 u01.1 u01.2 u02.1 u02.2 u03.1 u03.2 u04.1 u04.2
    u05.1 u05.2 u06.1 u06.2 u07.1 u07.2 u08.1 u08.2 u09.1 u09.2
    u10.1 u10.2 u11.1 u11.2 u12.1 u12.2 u13.1 u13.2 u14.1 u14.2 u15.1 u15.2 u16.1 u16.2
    u20.1 u20.2 u21.1 u21.2 u22.1 u22.2 u23.1 u23.2
    u30.1 u30.2

/-! ### Arithmetic and Chebyshev helpers -/

private lemma nat_add_eq (a b : Nat) : Nat.add a b = a + b := rfl
private lemma nat_sub_eq (a b : Nat) : Nat.sub a b = a - b := rfl
private lemma nat_mul_eq (a b : Nat) : Nat.mul a b = a * b := rfl
private lemma nat_div_eq (a b : Nat) : Nat.div a b = a / b := rfl
private lemma nat_mod_eq (a b : Nat) : Nat.mod a b = a % b := rfl

private lemma nat_lt_of_blt {a b : Nat} (h : Nat.blt a b = true) : a < b :=
  Nat.lt_of_succ_le (Nat.le_of_ble_eq_true h)

private lemma abs_le_one_of_Ico {x : ℝ} (h : 0 ≤ x ∧ x < 1) : |x| ≤ 1 :=
  abs_le.mpr ⟨by linarith only [h.1], by linarith only [h.2]⟩

private lemma bool_if_not_and4 {a b c d e : Bool}
    (h : (if !(a && b && c && d) then false else e) = true) :
    a = true ∧ b = true ∧ c = true ∧ d = true ∧ e = true := by
  cases a <;> cases b <;> cases c <;> cases d <;> simp_all

theorem S64_eq : (S64 : ℝ) = (2 ^ 64 : ℝ) := by norm_num [S64]

private lemma S64_nat_pos : 0 < S64 := by decide

private lemma S128_nat_pos : 0 < S128 := by decide

private lemma S64_pos : (0 : ℝ) < (S64 : ℝ) := by norm_num [S64]

private lemma S128_pos : (0 : ℝ) < (S128 : ℝ) := by norm_num [S128]

private lemma S128_eq_sq : (S128 : ℝ) = (S64 : ℝ) ^ 2 := by norm_num [S64, S128]

private lemma natAbsDiff_cast (a b : Nat) :
    ((natAbsDiff a b : Nat) : ℝ) = |(a : ℝ) - (b : ℝ)| := by
  unfold natAbsDiff
  by_cases h : Nat.ble a b = true
  · simp only [h, ↓reduceIte, nat_sub_eq]
    have hab : a ≤ b := Nat.le_of_ble_eq_true h
    rw [Nat.cast_sub hab, abs_of_nonpos (sub_nonpos.mpr (Nat.cast_le.mpr hab)), neg_sub]
  · simp only [h, Bool.false_eq_true, ↓reduceIte, nat_sub_eq]
    have hba : b ≤ a := Nat.le_of_lt (Nat.lt_of_not_ge (fun hle => h (Nat.ble_eq_true_of_le hle)))
    rw [Nat.cast_sub hba, abs_of_nonneg (sub_nonneg.mpr (Nat.cast_le.mpr hba))]

private lemma natDiv_le_div (a d : Nat) (hd : 0 < d) :
    ((Nat.div a d : Nat) : ℝ) ≤ (a : ℝ) / (d : ℝ) := by
  rw [nat_div_eq]
  have hd' : (0 : ℝ) < (d : ℝ) := Nat.cast_pos.mpr hd
  rw [le_div_iff₀ hd']
  have h : (a / d) * d ≤ a := Nat.div_mul_le_self a d
  exact_mod_cast h

private lemma div_lt_natDiv_add_one (a d : Nat) (hd : 0 < d) :
    (a : ℝ) / (d : ℝ) < ((Nat.div a d : Nat) : ℝ) + 1 := by
  rw [nat_div_eq]
  have hd' : (0 : ℝ) < (d : ℝ) := Nat.cast_pos.mpr hd
  rw [div_lt_iff₀ hd']
  have hmod : a % d < d := Nat.mod_lt a hd
  have hdiv : a = d * (a / d) + a % d := (Nat.div_add_mod a d).symm
  have hlt : a < (a / d + 1) * d := by nlinarith
  exact_mod_cast hlt

private lemma div_sub_natDiv_bounds (a d : Nat) (hd : 0 < d) :
    0 ≤ (a : ℝ) / (d : ℝ) - ((Nat.div a d : Nat) : ℝ) ∧
    (a : ℝ) / (d : ℝ) - ((Nat.div a d : Nat) : ℝ) < 1 := by
  have h1 := natDiv_le_div a d hd
  have h2 := div_lt_natDiv_add_one a d hd
  exact ⟨by linarith, by linarith⟩

private lemma abs_div_sub_natDiv_sub_le (a b d : Nat) (hd : 0 < d) :
    |((a : ℝ) / (d : ℝ) - (b : ℝ) / (d : ℝ)) -
      (((Nat.div a d : Nat) : ℝ) - ((Nat.div b d : Nat) : ℝ))| ≤ 1 := by
  have ha := div_sub_natDiv_bounds a d hd
  have hb := div_sub_natDiv_bounds b d hd
  exact abs_le.mpr ⟨by linarith, by linarith⟩

private lemma abs_sub_cast_le_add_cast (p n : Nat) :
    |(p : ℝ) - (n : ℝ)| ≤ (p : ℝ) + (n : ℝ) :=
  abs_le.mpr ⟨by linarith [Nat.cast_nonneg (α := ℝ) p, Nat.cast_nonneg (α := ℝ) n],
    by linarith [Nat.cast_nonneg (α := ℝ) p, Nat.cast_nonneg (α := ℝ) n]⟩

private lemma exists_unit_param (R : Nat) (i : ℤ) (hi : |i| ≤ R) :
    ∃ t : ℝ, |t| ≤ 1 ∧ (i : ℝ) = (R : ℝ) * t := by
  by_cases hR : R = 0
  · refine ⟨0, by norm_num, ?_⟩
    subst hR
    have hi0 : i = 0 := abs_nonpos_iff.mp (by simpa using hi)
    simp [hi0]
  · have hRpos : (0 : ℝ) < (R : ℝ) := Nat.cast_pos.mpr (Nat.pos_of_ne_zero hR)
    refine ⟨(i : ℝ) / (R : ℝ), ?_, ?_⟩
    · rw [abs_div, abs_of_pos hRpos, div_le_one hRpos]
      simpa [Int.cast_abs] using (Int.cast_le (R := ℝ)).mpr hi
    · field_simp

/-- Chebyshev polynomial of the first kind `T_n(t)`. -/
private def chebT : Nat → ℝ → ℝ
  | 0, _ => 1
  | 1, t => t
  | n + 2, t => 2 * t * chebT (n + 1) t - chebT n t

private lemma chebT_cos (n : Nat) (θ : ℝ) : chebT n (Real.cos θ) = Real.cos (n * θ) := by
  match n with
  | 0 => simp [chebT]
  | 1 => simp [chebT]
  | n + 2 =>
    simp only [chebT, chebT_cos (n + 1) θ, chebT_cos n θ]
    have hadd := Real.cos_add (((n + 1 : Nat) : ℝ) * θ) θ
    have hsub := Real.cos_sub (((n + 1 : Nat) : ℝ) * θ) θ
    have heq1 : ((n + 1 : Nat) : ℝ) * θ + θ = ((n + 2 : Nat) : ℝ) * θ := by push_cast; ring
    have heq2 : ((n + 1 : Nat) : ℝ) * θ - θ = (n : ℝ) * θ := by push_cast; ring
    rw [heq1] at hadd
    rw [heq2] at hsub
    linarith

private lemma abs_chebT_le_one (n : Nat) {t : ℝ} (ht : |t| ≤ 1) : |chebT n t| ≤ 1 := by
  have h1 : -1 ≤ t ∧ t ≤ 1 := abs_le.mp ht
  rw [← Real.cos_arccos h1.1 h1.2, chebT_cos]
  exact Real.abs_cos_le_one _

private lemma abs_mul_chebT_le (c : ℝ) (k : Nat) {t : ℝ} (ht : |t| ≤ 1) :
    |c * chebT k t| ≤ |c| := by
  rw [abs_mul]
  calc |c| * |chebT k t| ≤ |c| * 1 :=
        mul_le_mul_of_nonneg_left (abs_chebT_le_one k ht) (abs_nonneg c)
    _ = |c| := mul_one _

private lemma abs_pow_le_one {t : ℝ} (ht : |t| ≤ 1) (k : Nat) : |t ^ k| ≤ 1 := by
  rw [abs_pow]
  exact pow_le_one₀ (abs_nonneg t) ht

private lemma abs_mul_pow_le (c : ℝ) {t : ℝ} (ht : |t| ≤ 1) (k : Nat) :
    |c * t ^ k| ≤ |c| := by
  rw [abs_mul]
  calc |c| * |t ^ k| ≤ |c| * 1 :=
        mul_le_mul_of_nonneg_left (abs_pow_le_one ht k) (abs_nonneg c)
    _ = |c| := mul_one _

private lemma abs_poly7_le_seven {d0 d1 d2 d3 d4 d5 d6 t : ℝ} (ht : |t| ≤ 1)
    (h0 : |d0| ≤ 1) (h1 : |d1| ≤ 1) (h2 : |d2| ≤ 1) (h3 : |d3| ≤ 1)
    (h4 : |d4| ≤ 1) (h5 : |d5| ≤ 1) (h6 : |d6| ≤ 1) :
    |d0 + d1 * t + d2 * t ^ 2 + d3 * t ^ 3 + d4 * t ^ 4 + d5 * t ^ 5 + d6 * t ^ 6| ≤ 7 := by
  have a1 := abs_add_le (d0 + d1 * t + d2 * t ^ 2 + d3 * t ^ 3 + d4 * t ^ 4 + d5 * t ^ 5)
    (d6 * t ^ 6)
  have a2 := abs_add_le (d0 + d1 * t + d2 * t ^ 2 + d3 * t ^ 3 + d4 * t ^ 4) (d5 * t ^ 5)
  have a3 := abs_add_le (d0 + d1 * t + d2 * t ^ 2 + d3 * t ^ 3) (d4 * t ^ 4)
  have a4 := abs_add_le (d0 + d1 * t + d2 * t ^ 2) (d3 * t ^ 3)
  have a5 := abs_add_le (d0 + d1 * t) (d2 * t ^ 2)
  have a6 := abs_add_le d0 (d1 * t)
  have b1 : |d1 * t| ≤ 1 := by
    have := abs_mul_pow_le d1 ht 1; rw [pow_one] at this; exact this.trans h1
  have b2 : |d2 * t ^ 2| ≤ 1 := (abs_mul_pow_le d2 ht 2).trans h2
  have b3 : |d3 * t ^ 3| ≤ 1 := (abs_mul_pow_le d3 ht 3).trans h3
  have b4 : |d4 * t ^ 4| ≤ 1 := (abs_mul_pow_le d4 ht 4).trans h4
  have b5 : |d5 * t ^ 5| ≤ 1 := (abs_mul_pow_le d5 ht 5).trans h5
  have b6 : |d6 * t ^ 6| ≤ 1 := (abs_mul_pow_le d6 ht 6).trans h6
  linarith only [a1, a2, a3, a4, a5, a6, h0, b1, b2, b3, b4, b5, b6]

private lemma cheb8_deg4 (a0 a1 a2 a3 a4 t : ℝ) :
    8 * (a0 + a1 * t + a2 * t ^ 2 + a3 * t ^ 3 + a4 * t ^ 4) =
      (8 * a0 + 4 * a2 + 3 * a4) * chebT 0 t +
      (8 * a1 + 6 * a3) * chebT 1 t +
      (4 * a2 + 4 * a4) * chebT 2 t +
      (2 * a3) * chebT 3 t +
      a4 * chebT 4 t := by
  simp only [chebT]; ring

private lemma cheb8_deg2 (d0 d1 d2 t : ℝ) :
    8 * (d0 + d1 * t + d2 * t ^ 2) =
      (8 * d0 + 4 * d2) * chebT 0 t +
      (8 * d1) * chebT 1 t +
      (4 * d2) * chebT 2 t := by
  simp only [chebT]; ring

private lemma cheb256_deg9 (a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 t : ℝ) :
    256 * (a0 + a1 * t + a2 * t ^ 2 + a3 * t ^ 3 + a4 * t ^ 4 +
           a5 * t ^ 5 + a6 * t ^ 6 + a7 * t ^ 7 + a8 * t ^ 8 + a9 * t ^ 9) =
      (256 * a0 + 128 * a2 + 96 * a4 + 80 * a6 + 70 * a8) * chebT 0 t +
      (256 * a1 + 192 * a3 + 160 * a5 + 140 * a7 + 126 * a9) * chebT 1 t +
      (128 * a2 + 128 * a4 + 120 * a6 + 112 * a8) * chebT 2 t +
      (64 * a3 + 80 * a5 + 84 * a7 + 84 * a9) * chebT 3 t +
      (32 * a4 + 48 * a6 + 56 * a8) * chebT 4 t +
      (16 * a5 + 28 * a7 + 36 * a9) * chebT 5 t +
      (8 * a6 + 16 * a8) * chebT 6 t +
      (4 * a7 + 9 * a9) * chebT 7 t +
      (2 * a8) * chebT 8 t +
      a9 * chebT 9 t := by
  simp only [chebT]; ring

private lemma cheb256_deg6 (d0 d1 d2 d3 d4 d5 d6 t : ℝ) :
    256 * (d0 + d1 * t + d2 * t ^ 2 + d3 * t ^ 3 + d4 * t ^ 4 +
           d5 * t ^ 5 + d6 * t ^ 6) =
      (256 * d0 + 128 * d2 + 96 * d4 + 80 * d6) * chebT 0 t +
      (256 * d1 + 192 * d3 + 160 * d5) * chebT 1 t +
      (128 * d2 + 128 * d4 + 120 * d6) * chebT 2 t +
      (64 * d3 + 80 * d5) * chebT 3 t +
      (32 * d4 + 48 * d6) * chebT 4 t +
      (16 * d5) * chebT 5 t +
      (8 * d6) * chebT 6 t := by
  simp only [chebT]; ring

private lemma cheb256_deg3 (f0 f1 f2 f3 t : ℝ) :
    256 * (f0 + f1 * t + f2 * t ^ 2 + f3 * t ^ 3) =
      (256 * f0 + 128 * f2) * chebT 0 t +
      (256 * f1 + 192 * f3) * chebT 1 t +
      (128 * f2) * chebT 2 t +
      (64 * f3) * chebT 3 t := by
  simp only [chebT]; ring

private lemma abs_cheb8_deg4_le (ap0 an0 ap1 an1 ap2 an2 ap3 an3 ap4 an4 : Nat)
    {t : ℝ} (ht : |t| ≤ 1) :
    |8 * (((ap0 : ℝ) - an0) + ((ap1 : ℝ) - an1) * t + ((ap2 : ℝ) - an2) * t ^ 2 +
      ((ap3 : ℝ) - an3) * t ^ 3 + ((ap4 : ℝ) - an4) * t ^ 4)| ≤
    ((natAbsDiff (Nat.add (Nat.mul 8 ap0) (Nat.add (Nat.mul 4 ap2) (Nat.mul 3 ap4)))
                 (Nat.add (Nat.mul 8 an0) (Nat.add (Nat.mul 4 an2) (Nat.mul 3 an4))) : Nat) : ℝ) +
    ((natAbsDiff (Nat.add (Nat.mul 8 ap1) (Nat.mul 6 ap3))
                 (Nat.add (Nat.mul 8 an1) (Nat.mul 6 an3)) : Nat) : ℝ) +
    ((natAbsDiff (Nat.add (Nat.mul 4 ap2) (Nat.mul 4 ap4))
                 (Nat.add (Nat.mul 4 an2) (Nat.mul 4 an4)) : Nat) : ℝ) +
    ((natAbsDiff (Nat.mul 2 ap3) (Nat.mul 2 an3) : Nat) : ℝ) +
    ((natAbsDiff ap4 an4 : Nat) : ℝ) := by
  rw [cheb8_deg4]
  have htri : ∀ x0 x1 x2 x3 x4 : ℝ,
      |x0 + x1 + x2 + x3 + x4| ≤ |x0| + |x1| + |x2| + |x3| + |x4| := by
    intro x0 x1 x2 x3 x4
    have a1 := abs_add_le (x0 + x1 + x2 + x3) x4
    have a2 := abs_add_le (x0 + x1 + x2) x3
    have a3 := abs_add_le (x0 + x1) x2
    have a4 := abs_add_le x0 x1
    linarith
  refine (htri _ _ _ _ _).trans ?_
  have h0 := abs_mul_chebT_le
    (8 * ((ap0 : ℝ) - an0) + 4 * ((ap2 : ℝ) - an2) + 3 * ((ap4 : ℝ) - an4)) 0 ht
  have h1 := abs_mul_chebT_le (8 * ((ap1 : ℝ) - an1) + 6 * ((ap3 : ℝ) - an3)) 1 ht
  have h2 := abs_mul_chebT_le (4 * ((ap2 : ℝ) - an2) + 4 * ((ap4 : ℝ) - an4)) 2 ht
  have h3 := abs_mul_chebT_le (2 * ((ap3 : ℝ) - an3)) 3 ht
  have h4 := abs_mul_chebT_le ((ap4 : ℝ) - an4) 4 ht
  simp only [natAbsDiff_cast, nat_add_eq, nat_mul_eq, Nat.cast_add, Nat.cast_mul, Nat.cast_ofNat]
  have e0 : 8 * ((ap0 : ℝ) - an0) + 4 * ((ap2 : ℝ) - an2) + 3 * ((ap4 : ℝ) - an4) =
      (8 * (ap0 : ℝ) + (4 * (ap2 : ℝ) + 3 * (ap4 : ℝ))) -
      (8 * (an0 : ℝ) + (4 * (an2 : ℝ) + 3 * (an4 : ℝ))) := by ring
  have e1 : 8 * ((ap1 : ℝ) - an1) + 6 * ((ap3 : ℝ) - an3) =
      (8 * (ap1 : ℝ) + 6 * (ap3 : ℝ)) - (8 * (an1 : ℝ) + 6 * (an3 : ℝ)) := by ring
  have e2 : 4 * ((ap2 : ℝ) - an2) + 4 * ((ap4 : ℝ) - an4) =
      (4 * (ap2 : ℝ) + 4 * (ap4 : ℝ)) - (4 * (an2 : ℝ) + 4 * (an4 : ℝ)) := by ring
  have e3 : 2 * ((ap3 : ℝ) - an3) = 2 * (ap3 : ℝ) - 2 * (an3 : ℝ) := by ring
  rw [e0] at h0 ⊢; rw [e1] at h1 ⊢; rw [e2] at h2 ⊢; rw [e3] at h3 ⊢
  linarith

private lemma abs_cheb8_deg2_le (dp0 dn0 dp1 dn1 dp2 dn2 : Nat)
    {t : ℝ} (ht : |t| ≤ 1) :
    |8 * (((dp0 : ℝ) - dn0) + ((dp1 : ℝ) - dn1) * t + ((dp2 : ℝ) - dn2) * t ^ 2)| ≤
    ((natAbsDiff (Nat.add (Nat.mul 8 dp0) (Nat.mul 4 dp2))
                 (Nat.add (Nat.mul 8 dn0) (Nat.mul 4 dn2)) : Nat) : ℝ) +
    ((natAbsDiff (Nat.mul 8 dp1) (Nat.mul 8 dn1) : Nat) : ℝ) +
    ((natAbsDiff (Nat.mul 4 dp2) (Nat.mul 4 dn2) : Nat) : ℝ) := by
  rw [cheb8_deg2]
  have htri : ∀ x0 x1 x2 : ℝ, |x0 + x1 + x2| ≤ |x0| + |x1| + |x2| := by
    intro x0 x1 x2
    have a1 := abs_add_le (x0 + x1) x2
    have a2 := abs_add_le x0 x1
    linarith
  refine (htri _ _ _).trans ?_
  have h0 := abs_mul_chebT_le (8 * ((dp0 : ℝ) - dn0) + 4 * ((dp2 : ℝ) - dn2)) 0 ht
  have h1 := abs_mul_chebT_le (8 * ((dp1 : ℝ) - dn1)) 1 ht
  have h2 := abs_mul_chebT_le (4 * ((dp2 : ℝ) - dn2)) 2 ht
  simp only [natAbsDiff_cast, nat_add_eq, nat_mul_eq, Nat.cast_add, Nat.cast_mul, Nat.cast_ofNat]
  have e0 : 8 * ((dp0 : ℝ) - dn0) + 4 * ((dp2 : ℝ) - dn2) =
      (8 * (dp0 : ℝ) + 4 * (dp2 : ℝ)) - (8 * (dn0 : ℝ) + 4 * (dn2 : ℝ)) := by ring
  have e1 : 8 * ((dp1 : ℝ) - dn1) = 8 * (dp1 : ℝ) - 8 * (dn1 : ℝ) := by ring
  have e2 : 4 * ((dp2 : ℝ) - dn2) = 4 * (dp2 : ℝ) - 4 * (dn2 : ℝ) := by ring
  rw [e0] at h0 ⊢; rw [e1] at h1 ⊢; rw [e2] at h2 ⊢
  linarith

private lemma abs_cheb256_deg9_le
    (ap0 an0 ap1 an1 ap2 an2 ap3 an3 ap4 an4
     ap5 an5 ap6 an6 ap7 an7 ap8 an8 ap9 an9 : Nat)
    {t : ℝ} (ht : |t| ≤ 1) :
    |256 * (((ap0 : ℝ) - an0) + ((ap1 : ℝ) - an1) * t + ((ap2 : ℝ) - an2) * t ^ 2 +
      ((ap3 : ℝ) - an3) * t ^ 3 + ((ap4 : ℝ) - an4) * t ^ 4 +
      ((ap5 : ℝ) - an5) * t ^ 5 + ((ap6 : ℝ) - an6) * t ^ 6 +
      ((ap7 : ℝ) - an7) * t ^ 7 + ((ap8 : ℝ) - an8) * t ^ 8 +
      ((ap9 : ℝ) - an9) * t ^ 9)| ≤
    ((natAbsDiff
      (Nat.add (Nat.mul 256 ap0) (Nat.add (Nat.mul 128 ap2)
        (Nat.add (Nat.mul 96 ap4) (Nat.add (Nat.mul 80 ap6) (Nat.mul 70 ap8)))))
      (Nat.add (Nat.mul 256 an0) (Nat.add (Nat.mul 128 an2)
        (Nat.add (Nat.mul 96 an4) (Nat.add (Nat.mul 80 an6) (Nat.mul 70 an8))))) : Nat) : ℝ) +
    ((natAbsDiff
      (Nat.add (Nat.mul 256 ap1) (Nat.add (Nat.mul 192 ap3)
        (Nat.add (Nat.mul 160 ap5) (Nat.add (Nat.mul 140 ap7) (Nat.mul 126 ap9)))))
      (Nat.add (Nat.mul 256 an1) (Nat.add (Nat.mul 192 an3)
        (Nat.add (Nat.mul 160 an5) (Nat.add (Nat.mul 140 an7) (Nat.mul 126 an9))))) : Nat) : ℝ) +
    ((natAbsDiff
      (Nat.add (Nat.mul 128 ap2) (Nat.add (Nat.mul 128 ap4)
        (Nat.add (Nat.mul 120 ap6) (Nat.mul 112 ap8))))
      (Nat.add (Nat.mul 128 an2) (Nat.add (Nat.mul 128 an4)
        (Nat.add (Nat.mul 120 an6) (Nat.mul 112 an8)))) : Nat) : ℝ) +
    ((natAbsDiff
      (Nat.add (Nat.mul 64 ap3) (Nat.add (Nat.mul 80 ap5)
        (Nat.add (Nat.mul 84 ap7) (Nat.mul 84 ap9))))
      (Nat.add (Nat.mul 64 an3) (Nat.add (Nat.mul 80 an5)
        (Nat.add (Nat.mul 84 an7) (Nat.mul 84 an9)))) : Nat) : ℝ) +
    ((natAbsDiff
      (Nat.add (Nat.mul 32 ap4) (Nat.add (Nat.mul 48 ap6) (Nat.mul 56 ap8)))
      (Nat.add (Nat.mul 32 an4) (Nat.add (Nat.mul 48 an6) (Nat.mul 56 an8))) : Nat) : ℝ) +
    ((natAbsDiff
      (Nat.add (Nat.mul 16 ap5) (Nat.add (Nat.mul 28 ap7) (Nat.mul 36 ap9)))
      (Nat.add (Nat.mul 16 an5) (Nat.add (Nat.mul 28 an7) (Nat.mul 36 an9))) : Nat) : ℝ) +
    ((natAbsDiff
      (Nat.add (Nat.mul 8 ap6) (Nat.mul 16 ap8))
      (Nat.add (Nat.mul 8 an6) (Nat.mul 16 an8)) : Nat) : ℝ) +
    ((natAbsDiff
      (Nat.add (Nat.mul 4 ap7) (Nat.mul 9 ap9))
      (Nat.add (Nat.mul 4 an7) (Nat.mul 9 an9)) : Nat) : ℝ) +
    ((natAbsDiff (Nat.mul 2 ap8) (Nat.mul 2 an8) : Nat) : ℝ) +
    ((natAbsDiff ap9 an9 : Nat) : ℝ) := by
  rw [cheb256_deg9]
  have htri : ∀ x0 x1 x2 x3 x4 x5 x6 x7 x8 x9 : ℝ,
      |x0 + x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9| ≤
      |x0| + |x1| + |x2| + |x3| + |x4| + |x5| + |x6| + |x7| + |x8| + |x9| := by
    intro x0 x1 x2 x3 x4 x5 x6 x7 x8 x9
    have h1 := abs_add_le (x0 + x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8) x9
    have h2 := abs_add_le (x0 + x1 + x2 + x3 + x4 + x5 + x6 + x7) x8
    have h3 := abs_add_le (x0 + x1 + x2 + x3 + x4 + x5 + x6) x7
    have h4 := abs_add_le (x0 + x1 + x2 + x3 + x4 + x5) x6
    have h5 := abs_add_le (x0 + x1 + x2 + x3 + x4) x5
    have h6 := abs_add_le (x0 + x1 + x2 + x3) x4
    have h7 := abs_add_le (x0 + x1 + x2) x3
    have h8 := abs_add_le (x0 + x1) x2
    have h9 := abs_add_le x0 x1
    linarith
  refine (htri _ _ _ _ _ _ _ _ _ _).trans ?_
  have h0 := abs_mul_chebT_le (256 * ((ap0 : ℝ) - an0) + 128 * ((ap2 : ℝ) - an2) +
    96 * ((ap4 : ℝ) - an4) + 80 * ((ap6 : ℝ) - an6) + 70 * ((ap8 : ℝ) - an8)) 0 ht
  have h1 := abs_mul_chebT_le (256 * ((ap1 : ℝ) - an1) + 192 * ((ap3 : ℝ) - an3) +
    160 * ((ap5 : ℝ) - an5) + 140 * ((ap7 : ℝ) - an7) + 126 * ((ap9 : ℝ) - an9)) 1 ht
  have h2 := abs_mul_chebT_le (128 * ((ap2 : ℝ) - an2) + 128 * ((ap4 : ℝ) - an4) +
    120 * ((ap6 : ℝ) - an6) + 112 * ((ap8 : ℝ) - an8)) 2 ht
  have h3 := abs_mul_chebT_le (64 * ((ap3 : ℝ) - an3) + 80 * ((ap5 : ℝ) - an5) +
    84 * ((ap7 : ℝ) - an7) + 84 * ((ap9 : ℝ) - an9)) 3 ht
  have h4 := abs_mul_chebT_le (32 * ((ap4 : ℝ) - an4) + 48 * ((ap6 : ℝ) - an6) +
    56 * ((ap8 : ℝ) - an8)) 4 ht
  have h5 := abs_mul_chebT_le (16 * ((ap5 : ℝ) - an5) + 28 * ((ap7 : ℝ) - an7) +
    36 * ((ap9 : ℝ) - an9)) 5 ht
  have h6 := abs_mul_chebT_le (8 * ((ap6 : ℝ) - an6) + 16 * ((ap8 : ℝ) - an8)) 6 ht
  have h7 := abs_mul_chebT_le (4 * ((ap7 : ℝ) - an7) + 9 * ((ap9 : ℝ) - an9)) 7 ht
  have h8 := abs_mul_chebT_le (2 * ((ap8 : ℝ) - an8)) 8 ht
  have h9 := abs_mul_chebT_le ((ap9 : ℝ) - an9) 9 ht
  simp only [natAbsDiff_cast, nat_add_eq, nat_mul_eq, Nat.cast_add, Nat.cast_mul, Nat.cast_ofNat]
  have e0 : 256 * ((ap0 : ℝ) - an0) + 128 * ((ap2 : ℝ) - an2) + 96 * ((ap4 : ℝ) - an4) +
      80 * ((ap6 : ℝ) - an6) + 70 * ((ap8 : ℝ) - an8) =
      (256 * (ap0 : ℝ) + (128 * (ap2 : ℝ) + (96 * (ap4 : ℝ) +
        (80 * (ap6 : ℝ) + 70 * (ap8 : ℝ))))) -
      (256 * (an0 : ℝ) + (128 * (an2 : ℝ) + (96 * (an4 : ℝ) +
        (80 * (an6 : ℝ) + 70 * (an8 : ℝ))))) := by ring
  have e1 : 256 * ((ap1 : ℝ) - an1) + 192 * ((ap3 : ℝ) - an3) + 160 * ((ap5 : ℝ) - an5) +
      140 * ((ap7 : ℝ) - an7) + 126 * ((ap9 : ℝ) - an9) =
      (256 * (ap1 : ℝ) + (192 * (ap3 : ℝ) + (160 * (ap5 : ℝ) +
        (140 * (ap7 : ℝ) + 126 * (ap9 : ℝ))))) -
      (256 * (an1 : ℝ) + (192 * (an3 : ℝ) + (160 * (an5 : ℝ) +
        (140 * (an7 : ℝ) + 126 * (an9 : ℝ))))) := by ring
  have e2 : 128 * ((ap2 : ℝ) - an2) + 128 * ((ap4 : ℝ) - an4) + 120 * ((ap6 : ℝ) - an6) +
      112 * ((ap8 : ℝ) - an8) =
      (128 * (ap2 : ℝ) + (128 * (ap4 : ℝ) + (120 * (ap6 : ℝ) + 112 * (ap8 : ℝ)))) -
      (128 * (an2 : ℝ) + (128 * (an4 : ℝ) + (120 * (an6 : ℝ) + 112 * (an8 : ℝ)))) := by ring
  have e3 : 64 * ((ap3 : ℝ) - an3) + 80 * ((ap5 : ℝ) - an5) + 84 * ((ap7 : ℝ) - an7) +
      84 * ((ap9 : ℝ) - an9) =
      (64 * (ap3 : ℝ) + (80 * (ap5 : ℝ) + (84 * (ap7 : ℝ) + 84 * (ap9 : ℝ)))) -
      (64 * (an3 : ℝ) + (80 * (an5 : ℝ) + (84 * (an7 : ℝ) + 84 * (an9 : ℝ)))) := by ring
  have e4 : 32 * ((ap4 : ℝ) - an4) + 48 * ((ap6 : ℝ) - an6) + 56 * ((ap8 : ℝ) - an8) =
      (32 * (ap4 : ℝ) + (48 * (ap6 : ℝ) + 56 * (ap8 : ℝ))) -
      (32 * (an4 : ℝ) + (48 * (an6 : ℝ) + 56 * (an8 : ℝ))) := by ring
  have e5 : 16 * ((ap5 : ℝ) - an5) + 28 * ((ap7 : ℝ) - an7) + 36 * ((ap9 : ℝ) - an9) =
      (16 * (ap5 : ℝ) + (28 * (ap7 : ℝ) + 36 * (ap9 : ℝ))) -
      (16 * (an5 : ℝ) + (28 * (an7 : ℝ) + 36 * (an9 : ℝ))) := by ring
  have e6 : 8 * ((ap6 : ℝ) - an6) + 16 * ((ap8 : ℝ) - an8) =
      (8 * (ap6 : ℝ) + 16 * (ap8 : ℝ)) - (8 * (an6 : ℝ) + 16 * (an8 : ℝ)) := by ring
  have e7 : 4 * ((ap7 : ℝ) - an7) + 9 * ((ap9 : ℝ) - an9) =
      (4 * (ap7 : ℝ) + 9 * (ap9 : ℝ)) - (4 * (an7 : ℝ) + 9 * (an9 : ℝ)) := by ring
  have e8 : 2 * ((ap8 : ℝ) - an8) = 2 * (ap8 : ℝ) - 2 * (an8 : ℝ) := by ring
  rw [e0] at h0 ⊢; rw [e1] at h1 ⊢; rw [e2] at h2 ⊢; rw [e3] at h3 ⊢; rw [e4] at h4 ⊢
  rw [e5] at h5 ⊢; rw [e6] at h6 ⊢; rw [e7] at h7 ⊢; rw [e8] at h8 ⊢
  linarith

private lemma abs_cheb256_deg6_le
    (dp0 dn0 dp1 dn1 dp2 dn2 dp3 dn3 dp4 dn4 dp5 dn5 dp6 dn6 : Nat)
    {t : ℝ} (ht : |t| ≤ 1) :
    |256 * (((dp0 : ℝ) - dn0) + ((dp1 : ℝ) - dn1) * t + ((dp2 : ℝ) - dn2) * t ^ 2 +
      ((dp3 : ℝ) - dn3) * t ^ 3 + ((dp4 : ℝ) - dn4) * t ^ 4 +
      ((dp5 : ℝ) - dn5) * t ^ 5 + ((dp6 : ℝ) - dn6) * t ^ 6)| ≤
    ((natAbsDiff
      (Nat.add (Nat.mul 256 dp0) (Nat.add (Nat.mul 128 dp2)
        (Nat.add (Nat.mul 96 dp4) (Nat.mul 80 dp6))))
      (Nat.add (Nat.mul 256 dn0) (Nat.add (Nat.mul 128 dn2)
        (Nat.add (Nat.mul 96 dn4) (Nat.mul 80 dn6)))) : Nat) : ℝ) +
    ((natAbsDiff
      (Nat.add (Nat.mul 256 dp1) (Nat.add (Nat.mul 192 dp3) (Nat.mul 160 dp5)))
      (Nat.add (Nat.mul 256 dn1) (Nat.add (Nat.mul 192 dn3) (Nat.mul 160 dn5))) : Nat) : ℝ) +
    ((natAbsDiff
      (Nat.add (Nat.mul 128 dp2) (Nat.add (Nat.mul 128 dp4) (Nat.mul 120 dp6)))
      (Nat.add (Nat.mul 128 dn2) (Nat.add (Nat.mul 128 dn4) (Nat.mul 120 dn6))) : Nat) : ℝ) +
    ((natAbsDiff
      (Nat.add (Nat.mul 64 dp3) (Nat.mul 80 dp5))
      (Nat.add (Nat.mul 64 dn3) (Nat.mul 80 dn5)) : Nat) : ℝ) +
    ((natAbsDiff
      (Nat.add (Nat.mul 32 dp4) (Nat.mul 48 dp6))
      (Nat.add (Nat.mul 32 dn4) (Nat.mul 48 dn6)) : Nat) : ℝ) +
    ((natAbsDiff (Nat.mul 16 dp5) (Nat.mul 16 dn5) : Nat) : ℝ) +
    ((natAbsDiff (Nat.mul 8 dp6) (Nat.mul 8 dn6) : Nat) : ℝ) := by
  rw [cheb256_deg6]
  have htri : ∀ x0 x1 x2 x3 x4 x5 x6 : ℝ,
      |x0 + x1 + x2 + x3 + x4 + x5 + x6| ≤ |x0| + |x1| + |x2| + |x3| + |x4| + |x5| + |x6| := by
    intro x0 x1 x2 x3 x4 x5 x6
    have h1 := abs_add_le (x0 + x1 + x2 + x3 + x4 + x5) x6
    have h2 := abs_add_le (x0 + x1 + x2 + x3 + x4) x5
    have h3 := abs_add_le (x0 + x1 + x2 + x3) x4
    have h4 := abs_add_le (x0 + x1 + x2) x3
    have h5 := abs_add_le (x0 + x1) x2
    have h6 := abs_add_le x0 x1
    linarith
  refine (htri _ _ _ _ _ _ _).trans ?_
  have h0 := abs_mul_chebT_le (256 * ((dp0 : ℝ) - dn0) + 128 * ((dp2 : ℝ) - dn2) +
    96 * ((dp4 : ℝ) - dn4) + 80 * ((dp6 : ℝ) - dn6)) 0 ht
  have h1 := abs_mul_chebT_le (256 * ((dp1 : ℝ) - dn1) + 192 * ((dp3 : ℝ) - dn3) +
    160 * ((dp5 : ℝ) - dn5)) 1 ht
  have h2 := abs_mul_chebT_le (128 * ((dp2 : ℝ) - dn2) + 128 * ((dp4 : ℝ) - dn4) +
    120 * ((dp6 : ℝ) - dn6)) 2 ht
  have h3 := abs_mul_chebT_le (64 * ((dp3 : ℝ) - dn3) + 80 * ((dp5 : ℝ) - dn5)) 3 ht
  have h4 := abs_mul_chebT_le (32 * ((dp4 : ℝ) - dn4) + 48 * ((dp6 : ℝ) - dn6)) 4 ht
  have h5 := abs_mul_chebT_le (16 * ((dp5 : ℝ) - dn5)) 5 ht
  have h6 := abs_mul_chebT_le (8 * ((dp6 : ℝ) - dn6)) 6 ht
  simp only [natAbsDiff_cast, nat_add_eq, nat_mul_eq, Nat.cast_add, Nat.cast_mul, Nat.cast_ofNat]
  have e0 : 256 * ((dp0 : ℝ) - dn0) + 128 * ((dp2 : ℝ) - dn2) + 96 * ((dp4 : ℝ) - dn4) +
      80 * ((dp6 : ℝ) - dn6) =
      (256 * (dp0 : ℝ) + (128 * (dp2 : ℝ) + (96 * (dp4 : ℝ) + 80 * (dp6 : ℝ)))) -
      (256 * (dn0 : ℝ) + (128 * (dn2 : ℝ) + (96 * (dn4 : ℝ) + 80 * (dn6 : ℝ)))) := by ring
  have e1 : 256 * ((dp1 : ℝ) - dn1) + 192 * ((dp3 : ℝ) - dn3) + 160 * ((dp5 : ℝ) - dn5) =
      (256 * (dp1 : ℝ) + (192 * (dp3 : ℝ) + 160 * (dp5 : ℝ))) -
      (256 * (dn1 : ℝ) + (192 * (dn3 : ℝ) + 160 * (dn5 : ℝ))) := by ring
  have e2 : 128 * ((dp2 : ℝ) - dn2) + 128 * ((dp4 : ℝ) - dn4) + 120 * ((dp6 : ℝ) - dn6) =
      (128 * (dp2 : ℝ) + (128 * (dp4 : ℝ) + 120 * (dp6 : ℝ))) -
      (128 * (dn2 : ℝ) + (128 * (dn4 : ℝ) + 120 * (dn6 : ℝ))) := by ring
  have e3 : 64 * ((dp3 : ℝ) - dn3) + 80 * ((dp5 : ℝ) - dn5) =
      (64 * (dp3 : ℝ) + 80 * (dp5 : ℝ)) - (64 * (dn3 : ℝ) + 80 * (dn5 : ℝ)) := by ring
  have e4 : 32 * ((dp4 : ℝ) - dn4) + 48 * ((dp6 : ℝ) - dn6) =
      (32 * (dp4 : ℝ) + 48 * (dp6 : ℝ)) - (32 * (dn4 : ℝ) + 48 * (dn6 : ℝ)) := by ring
  have e5 : 16 * ((dp5 : ℝ) - dn5) = 16 * (dp5 : ℝ) - 16 * (dn5 : ℝ) := by ring
  have e6 : 8 * ((dp6 : ℝ) - dn6) = 8 * (dp6 : ℝ) - 8 * (dn6 : ℝ) := by ring
  rw [e0] at h0 ⊢; rw [e1] at h1 ⊢; rw [e2] at h2 ⊢; rw [e3] at h3 ⊢
  rw [e4] at h4 ⊢; rw [e5] at h5 ⊢; rw [e6] at h6 ⊢
  linarith

private lemma abs_cheb256_deg3_le (fp0 fn0 fp1 fn1 fp2 fn2 fp3 fn3 : Nat)
    {t : ℝ} (ht : |t| ≤ 1) :
    |256 * (((fp0 : ℝ) - fn0) + ((fp1 : ℝ) - fn1) * t +
      ((fp2 : ℝ) - fn2) * t ^ 2 + ((fp3 : ℝ) - fn3) * t ^ 3)| ≤
    ((natAbsDiff (Nat.add (Nat.mul 256 fp0) (Nat.mul 128 fp2))
                 (Nat.add (Nat.mul 256 fn0) (Nat.mul 128 fn2)) : Nat) : ℝ) +
    ((natAbsDiff (Nat.add (Nat.mul 256 fp1) (Nat.mul 192 fp3))
                 (Nat.add (Nat.mul 256 fn1) (Nat.mul 192 fn3)) : Nat) : ℝ) +
    ((natAbsDiff (Nat.mul 128 fp2) (Nat.mul 128 fn2) : Nat) : ℝ) +
    ((natAbsDiff (Nat.mul 64 fp3) (Nat.mul 64 fn3) : Nat) : ℝ) := by
  rw [cheb256_deg3]
  have htri : ∀ x0 x1 x2 x3 : ℝ, |x0 + x1 + x2 + x3| ≤ |x0| + |x1| + |x2| + |x3| := by
    intro x0 x1 x2 x3
    have h1 := abs_add_le (x0 + x1 + x2) x3
    have h2 := abs_add_le (x0 + x1) x2
    have h3 := abs_add_le x0 x1
    linarith
  refine (htri _ _ _ _).trans ?_
  have h0 := abs_mul_chebT_le (256 * ((fp0 : ℝ) - fn0) + 128 * ((fp2 : ℝ) - fn2)) 0 ht
  have h1 := abs_mul_chebT_le (256 * ((fp1 : ℝ) - fn1) + 192 * ((fp3 : ℝ) - fn3)) 1 ht
  have h2 := abs_mul_chebT_le (128 * ((fp2 : ℝ) - fn2)) 2 ht
  have h3 := abs_mul_chebT_le (64 * ((fp3 : ℝ) - fn3)) 3 ht
  simp only [natAbsDiff_cast, nat_add_eq, nat_mul_eq, Nat.cast_add, Nat.cast_mul, Nat.cast_ofNat]
  have e0 : 256 * ((fp0 : ℝ) - fn0) + 128 * ((fp2 : ℝ) - fn2) =
      (256 * (fp0 : ℝ) + 128 * (fp2 : ℝ)) - (256 * (fn0 : ℝ) + 128 * (fn2 : ℝ)) := by ring
  have e1 : 256 * ((fp1 : ℝ) - fn1) + 192 * ((fp3 : ℝ) - fn3) =
      (256 * (fp1 : ℝ) + 192 * (fp3 : ℝ)) - (256 * (fn1 : ℝ) + 192 * (fn3 : ℝ)) := by ring
  have e2 : 128 * ((fp2 : ℝ) - fn2) = 128 * (fp2 : ℝ) - 128 * (fn2 : ℝ) := by ring
  have e3 : 64 * ((fp3 : ℝ) - fn3) = 64 * (fp3 : ℝ) - 64 * (fn3 : ℝ) := by ring
  rw [e0] at h0 ⊢; rw [e1] at h1 ⊢; rw [e2] at h2 ⊢; rw [e3] at h3 ⊢
  linarith

/-! ### Parity helpers -/

private lemma int_pow_succ_emod_two (x : ℤ) : ∀ k : Nat, x ^ (k + 1) % 2 = x % 2
  | 0 => by simp
  | k + 1 => by
    rw [pow_succ, Int.mul_emod, int_pow_succ_emod_two x k]
    have h : x % 2 = 0 ∨ x % 2 = 1 := by omega
    rcases h with h | h <;> simp [h]

private lemma two_dvd_pow_sub (x : ℤ) (k : Nat) : (2 : ℤ) ∣ x ^ (k + 1) - x := by
  rw [Int.dvd_iff_emod_eq_zero, Int.sub_emod, int_pow_succ_emod_two, sub_self, Int.zero_emod]

private lemma one_le_abs_cast_of_emod_two_eq_one {z : ℤ} (hz : z % 2 = 1) :
    (1 : ℝ) ≤ |(z : ℝ)| := by
  have hne : z ≠ 0 := by omega
  have h1 : (1 : ℤ) ≤ |z| := by
    rcases le_total 0 z with h | h
    · rw [abs_of_nonneg h]; omega
    · rw [abs_of_nonpos h]; omega
  simpa [Int.cast_abs] using (Int.cast_le (R := ℝ)).mpr h1

private lemma mod_two_eq_one_of_sub {p n : Nat} (h : Nat.beq (Nat.mod (Nat.add p n) 2) 1 = true) :
    ((p : ℤ) - (n : ℤ)) % 2 = 1 := by
  have h' : (p + n) % 2 = 1 := Nat.eq_of_beq_eq_true h
  omega

private lemma two_dvd_int_of_nat_mod_two_eq_zero {s : Nat}
    (h : Nat.beq (Nat.mod s 2) 0 = true) : (2 : ℤ) ∣ (s : ℤ) := by
  have h' : s % 2 = 0 := Nat.eq_of_beq_eq_true h
  omega

private lemma parity_d2m2 {p00 n00 p01 n01 p02 n02 p03 n03 p04 n04
    p10 n10 p11 n11 p12 n12 p20 n20 : Nat}
    (h0 : Nat.beq (Nat.mod (Nat.add p00 n00) 2) 1 = true)
    (h1 : Nat.beq (Nat.mod
      (Nat.add (Nat.add p01 n01)
        (Nat.add (Nat.add p02 n02)
          (Nat.add (Nat.add p03 n03) (Nat.add p04 n04)))) 2) 0 = true)
    (h2 : Nat.beq (Nat.mod (Nat.add (Nat.add p10 n10) (Nat.add p20 n20)) 2) 0 = true)
    (h3 : Nat.beq (Nat.mod (Nat.add (Nat.add p11 n11) (Nat.add p12 n12)) 2) 0 = true)
    (i y : ℤ) :
    ((((p00 : ℤ) - n00) + ((p01 : ℤ) - n01) * i + ((p02 : ℤ) - n02) * i ^ 2 +
      ((p03 : ℤ) - n03) * i ^ 3 + ((p04 : ℤ) - n04) * i ^ 4) +
     (((p10 : ℤ) - n10) + ((p11 : ℤ) - n11) * i + ((p12 : ℤ) - n12) * i ^ 2) * y +
     ((p20 : ℤ) - n20) * y ^ 2) % 2 = 1 := by
  set q00 : ℤ := (p00 : ℤ) - n00
  set q01 : ℤ := (p01 : ℤ) - n01
  set q02 : ℤ := (p02 : ℤ) - n02
  set q03 : ℤ := (p03 : ℤ) - n03
  set q04 : ℤ := (p04 : ℤ) - n04
  set q10 : ℤ := (p10 : ℤ) - n10
  set q11 : ℤ := (p11 : ℤ) - n11
  set q12 : ℤ := (p12 : ℤ) - n12
  set q20 : ℤ := (p20 : ℤ) - n20
  have hq00 : q00 % 2 = 1 := mod_two_eq_one_of_sub h0
  have h1' : (2 : ℤ) ∣ q01 + q02 + q03 + q04 := by
    have hs := two_dvd_int_of_nat_mod_two_eq_zero h1
    have hd : (2 : ℤ) ∣ q01 + q02 + q03 + q04 -
        ((Nat.add (Nat.add p01 n01) (Nat.add (Nat.add p02 n02)
          (Nat.add (Nat.add p03 n03) (Nat.add p04 n04))) : Nat) : ℤ) :=
      ⟨-((n01 : ℤ) + n02 + n03 + n04), by
        simp only [q01, q02, q03, q04, nat_add_eq]; push_cast; ring⟩
    simpa using dvd_add hd hs
  have h2' : (2 : ℤ) ∣ q10 + q20 := by
    have hs := two_dvd_int_of_nat_mod_two_eq_zero h2
    have hd : (2 : ℤ) ∣ q10 + q20 -
        ((Nat.add (Nat.add p10 n10) (Nat.add p20 n20) : Nat) : ℤ) :=
      ⟨-((n10 : ℤ) + n20), by simp only [q10, q20, nat_add_eq]; push_cast; ring⟩
    simpa using dvd_add hd hs
  have h3' : (2 : ℤ) ∣ q11 + q12 := by
    have hs := two_dvd_int_of_nat_mod_two_eq_zero h3
    have hd : (2 : ℤ) ∣ q11 + q12 -
        ((Nat.add (Nat.add p11 n11) (Nat.add p12 n12) : Nat) : ℤ) :=
      ⟨-((n11 : ℤ) + n12), by simp only [q11, q12, nat_add_eq]; push_cast; ring⟩
    simpa using dvd_add hd hs
  have hi2 := two_dvd_pow_sub i 1
  have hi3 := two_dvd_pow_sub i 2
  have hi4 := two_dvd_pow_sub i 3
  have hy2 := two_dvd_pow_sub y 1
  have hdecomp :
      ((q00 + q01 * i + q02 * i ^ 2 + q03 * i ^ 3 + q04 * i ^ 4) +
       (q10 + q11 * i + q12 * i ^ 2) * y + q20 * y ^ 2) - q00 =
      (q01 + q02 + q03 + q04) * i + (q10 + q20) * y + (q11 + q12) * (i * y) +
      q02 * (i ^ 2 - i) + q03 * (i ^ 3 - i) + q04 * (i ^ 4 - i) +
      q12 * (i ^ 2 - i) * y + q20 * (y ^ 2 - y) := by ring
  have hdvd : (2 : ℤ) ∣
      ((q00 + q01 * i + q02 * i ^ 2 + q03 * i ^ 3 + q04 * i ^ 4) +
       (q10 + q11 * i + q12 * i ^ 2) * y + q20 * y ^ 2) - q00 := by
    rw [hdecomp]
    exact dvd_add (dvd_add (dvd_add (dvd_add (dvd_add (dvd_add (dvd_add
      (dvd_mul_of_dvd_left h1' i)
      (dvd_mul_of_dvd_left h2' y))
      (dvd_mul_of_dvd_left h3' (i * y)))
      (dvd_mul_of_dvd_right hi2 q02))
      (dvd_mul_of_dvd_right hi3 q03))
      (dvd_mul_of_dvd_right hi4 q04))
      (dvd_mul_of_dvd_left (dvd_mul_of_dvd_right hi2 q12) y))
      (dvd_mul_of_dvd_right hy2 q20)
  rcases hdvd with ⟨k, hk⟩
  omega

private lemma parity_d3m3
    {p00 n00 p01 n01 p02 n02 p03 n03 p04 n04
     p05 n05 p06 n06 p07 n07 p08 n08 p09 n09
     p10 n10 p11 n11 p12 n12 p13 n13 p14 n14 p15 n15 p16 n16
     p20 n20 p21 n21 p22 n22 p23 n23 p30 n30 : Nat}
    (h0 : Nat.beq (Nat.mod (Nat.add p00 n00) 2) 1 = true)
    (h1 : Nat.beq (Nat.mod
      (Nat.add (Nat.add p01 n01)
        (Nat.add (Nat.add p02 n02)
          (Nat.add (Nat.add p03 n03)
            (Nat.add (Nat.add p04 n04)
              (Nat.add (Nat.add p05 n05)
                (Nat.add (Nat.add p06 n06)
                  (Nat.add (Nat.add p07 n07)
                    (Nat.add (Nat.add p08 n08) (Nat.add p09 n09))))))))) 2) 0 = true)
    (h2 : Nat.beq (Nat.mod
      (Nat.add (Nat.add p10 n10) (Nat.add (Nat.add p20 n20) (Nat.add p30 n30))) 2) 0 = true)
    (h3 : Nat.beq (Nat.mod
      (Nat.add (Nat.add p11 n11)
        (Nat.add (Nat.add p12 n12)
          (Nat.add (Nat.add p13 n13)
            (Nat.add (Nat.add p14 n14)
              (Nat.add (Nat.add p15 n15)
                (Nat.add (Nat.add p16 n16)
                  (Nat.add (Nat.add p21 n21)
                    (Nat.add (Nat.add p22 n22) (Nat.add p23 n23))))))))) 2) 0 = true)
    (i y : ℤ) :
    ((((p00 : ℤ) - n00) + ((p01 : ℤ) - n01) * i + ((p02 : ℤ) - n02) * i ^ 2 +
      ((p03 : ℤ) - n03) * i ^ 3 + ((p04 : ℤ) - n04) * i ^ 4 +
      ((p05 : ℤ) - n05) * i ^ 5 + ((p06 : ℤ) - n06) * i ^ 6 +
      ((p07 : ℤ) - n07) * i ^ 7 + ((p08 : ℤ) - n08) * i ^ 8 +
      ((p09 : ℤ) - n09) * i ^ 9) +
     (((p10 : ℤ) - n10) + ((p11 : ℤ) - n11) * i + ((p12 : ℤ) - n12) * i ^ 2 +
      ((p13 : ℤ) - n13) * i ^ 3 + ((p14 : ℤ) - n14) * i ^ 4 +
      ((p15 : ℤ) - n15) * i ^ 5 + ((p16 : ℤ) - n16) * i ^ 6) * y +
     (((p20 : ℤ) - n20) + ((p21 : ℤ) - n21) * i + ((p22 : ℤ) - n22) * i ^ 2 +
      ((p23 : ℤ) - n23) * i ^ 3) * y ^ 2 +
     ((p30 : ℤ) - n30) * y ^ 3) % 2 = 1 := by
  set q00 : ℤ := (p00 : ℤ) - n00
  set q01 : ℤ := (p01 : ℤ) - n01
  set q02 : ℤ := (p02 : ℤ) - n02
  set q03 : ℤ := (p03 : ℤ) - n03
  set q04 : ℤ := (p04 : ℤ) - n04
  set q05 : ℤ := (p05 : ℤ) - n05
  set q06 : ℤ := (p06 : ℤ) - n06
  set q07 : ℤ := (p07 : ℤ) - n07
  set q08 : ℤ := (p08 : ℤ) - n08
  set q09 : ℤ := (p09 : ℤ) - n09
  set q10 : ℤ := (p10 : ℤ) - n10
  set q11 : ℤ := (p11 : ℤ) - n11
  set q12 : ℤ := (p12 : ℤ) - n12
  set q13 : ℤ := (p13 : ℤ) - n13
  set q14 : ℤ := (p14 : ℤ) - n14
  set q15 : ℤ := (p15 : ℤ) - n15
  set q16 : ℤ := (p16 : ℤ) - n16
  set q20 : ℤ := (p20 : ℤ) - n20
  set q21 : ℤ := (p21 : ℤ) - n21
  set q22 : ℤ := (p22 : ℤ) - n22
  set q23 : ℤ := (p23 : ℤ) - n23
  set q30 : ℤ := (p30 : ℤ) - n30
  have hq00 : q00 % 2 = 1 := mod_two_eq_one_of_sub h0
  have h1' : (2 : ℤ) ∣ q01 + q02 + q03 + q04 + q05 + q06 + q07 + q08 + q09 := by
    have hs := two_dvd_int_of_nat_mod_two_eq_zero h1
    have hd : (2 : ℤ) ∣ (q01 + q02 + q03 + q04 + q05 + q06 + q07 + q08 + q09) -
        ((Nat.add (Nat.add p01 n01) (Nat.add (Nat.add p02 n02) (Nat.add (Nat.add p03 n03)
          (Nat.add (Nat.add p04 n04) (Nat.add (Nat.add p05 n05) (Nat.add (Nat.add p06 n06)
            (Nat.add (Nat.add p07 n07) (Nat.add (Nat.add p08 n08)
              (Nat.add p09 n09)))))))) : Nat) : ℤ) :=
      ⟨-((n01 : ℤ) + n02 + n03 + n04 + n05 + n06 + n07 + n08 + n09), by
        simp only [q01, q02, q03, q04, q05, q06, q07, q08, q09, nat_add_eq]; push_cast; ring⟩
    simpa using dvd_add hd hs
  have h2' : (2 : ℤ) ∣ q10 + q20 + q30 := by
    have hs := two_dvd_int_of_nat_mod_two_eq_zero h2
    have hd : (2 : ℤ) ∣ (q10 + q20 + q30) -
        ((Nat.add (Nat.add p10 n10) (Nat.add (Nat.add p20 n20) (Nat.add p30 n30)) : Nat) : ℤ) :=
      ⟨-((n10 : ℤ) + n20 + n30), by simp only [q10, q20, q30, nat_add_eq]; push_cast; ring⟩
    simpa using dvd_add hd hs
  have h3' : (2 : ℤ) ∣ q11 + q12 + q13 + q14 + q15 + q16 + q21 + q22 + q23 := by
    have hs := two_dvd_int_of_nat_mod_two_eq_zero h3
    have hd : (2 : ℤ) ∣ (q11 + q12 + q13 + q14 + q15 + q16 + q21 + q22 + q23) -
        ((Nat.add (Nat.add p11 n11) (Nat.add (Nat.add p12 n12) (Nat.add (Nat.add p13 n13)
          (Nat.add (Nat.add p14 n14) (Nat.add (Nat.add p15 n15) (Nat.add (Nat.add p16 n16)
            (Nat.add (Nat.add p21 n21) (Nat.add (Nat.add p22 n22)
              (Nat.add p23 n23)))))))) : Nat) : ℤ) :=
      ⟨-((n11 : ℤ) + n12 + n13 + n14 + n15 + n16 + n21 + n22 + n23), by
        simp only [q11, q12, q13, q14, q15, q16, q21, q22, q23, nat_add_eq]; push_cast; ring⟩
    simpa using dvd_add hd hs
  have hi2 := two_dvd_pow_sub i 1
  have hi3 := two_dvd_pow_sub i 2
  have hi4 := two_dvd_pow_sub i 3
  have hi5 := two_dvd_pow_sub i 4
  have hi6 := two_dvd_pow_sub i 5
  have hi7 := two_dvd_pow_sub i 6
  have hi8 := two_dvd_pow_sub i 7
  have hi9 := two_dvd_pow_sub i 8
  have hy2 := two_dvd_pow_sub y 1
  have hy3 := two_dvd_pow_sub y 2
  have hdecomp :
      ((q00 + q01 * i + q02 * i ^ 2 + q03 * i ^ 3 + q04 * i ^ 4 +
        q05 * i ^ 5 + q06 * i ^ 6 + q07 * i ^ 7 + q08 * i ^ 8 + q09 * i ^ 9) +
       (q10 + q11 * i + q12 * i ^ 2 + q13 * i ^ 3 + q14 * i ^ 4 +
        q15 * i ^ 5 + q16 * i ^ 6) * y +
       (q20 + q21 * i + q22 * i ^ 2 + q23 * i ^ 3) * y ^ 2 +
       q30 * y ^ 3) - q00 =
      ((q01 + q02 + q03 + q04 + q05 + q06 + q07 + q08 + q09) * i +
       (q10 + q20 + q30) * y +
       (q11 + q12 + q13 + q14 + q15 + q16 + q21 + q22 + q23) * (i * y)) +
      (q02 * (i ^ 2 - i) + q03 * (i ^ 3 - i) + q04 * (i ^ 4 - i) + q05 * (i ^ 5 - i) +
       q06 * (i ^ 6 - i) + q07 * (i ^ 7 - i) + q08 * (i ^ 8 - i) + q09 * (i ^ 9 - i)) +
      (q12 * (i ^ 2 - i) + q13 * (i ^ 3 - i) + q14 * (i ^ 4 - i) +
       q15 * (i ^ 5 - i) + q16 * (i ^ 6 - i)) * y +
      (q20 * (y ^ 2 - y) + q21 * i * (y ^ 2 - y) +
       q22 * (i ^ 2 * (y ^ 2 - y) + (i ^ 2 - i) * y) +
       q23 * (i ^ 3 * (y ^ 2 - y) + (i ^ 3 - i) * y) +
       q30 * (y ^ 3 - y)) := by ring
  have hd_lin : (2 : ℤ) ∣
      (q01 + q02 + q03 + q04 + q05 + q06 + q07 + q08 + q09) * i +
      (q10 + q20 + q30) * y +
      (q11 + q12 + q13 + q14 + q15 + q16 + q21 + q22 + q23) * (i * y) :=
    dvd_add (dvd_add (dvd_mul_of_dvd_left h1' i) (dvd_mul_of_dvd_left h2' y))
      (dvd_mul_of_dvd_left h3' (i * y))
  have hd_q0 : (2 : ℤ) ∣
      q02 * (i ^ 2 - i) + q03 * (i ^ 3 - i) + q04 * (i ^ 4 - i) + q05 * (i ^ 5 - i) +
      q06 * (i ^ 6 - i) + q07 * (i ^ 7 - i) + q08 * (i ^ 8 - i) + q09 * (i ^ 9 - i) :=
    dvd_add (dvd_add (dvd_add (dvd_add (dvd_add (dvd_add (dvd_add
      (dvd_mul_of_dvd_right hi2 q02) (dvd_mul_of_dvd_right hi3 q03))
      (dvd_mul_of_dvd_right hi4 q04)) (dvd_mul_of_dvd_right hi5 q05))
      (dvd_mul_of_dvd_right hi6 q06)) (dvd_mul_of_dvd_right hi7 q07))
      (dvd_mul_of_dvd_right hi8 q08)) (dvd_mul_of_dvd_right hi9 q09)
  have hd_q1 : (2 : ℤ) ∣
      (q12 * (i ^ 2 - i) + q13 * (i ^ 3 - i) + q14 * (i ^ 4 - i) +
       q15 * (i ^ 5 - i) + q16 * (i ^ 6 - i)) * y :=
    dvd_mul_of_dvd_left (dvd_add (dvd_add (dvd_add (dvd_add
      (dvd_mul_of_dvd_right hi2 q12) (dvd_mul_of_dvd_right hi3 q13))
      (dvd_mul_of_dvd_right hi4 q14)) (dvd_mul_of_dvd_right hi5 q15))
      (dvd_mul_of_dvd_right hi6 q16)) y
  have hd_q23 : (2 : ℤ) ∣
      q20 * (y ^ 2 - y) + q21 * i * (y ^ 2 - y) +
      q22 * (i ^ 2 * (y ^ 2 - y) + (i ^ 2 - i) * y) +
      q23 * (i ^ 3 * (y ^ 2 - y) + (i ^ 3 - i) * y) +
      q30 * (y ^ 3 - y) :=
    dvd_add (dvd_add (dvd_add (dvd_add
      (dvd_mul_of_dvd_right hy2 q20)
      (dvd_mul_of_dvd_right hy2 (q21 * i)))
      (dvd_mul_of_dvd_right (dvd_add (dvd_mul_of_dvd_right hy2 (i ^ 2))
        (dvd_mul_of_dvd_left hi2 y)) q22))
      (dvd_mul_of_dvd_right (dvd_add (dvd_mul_of_dvd_right hy2 (i ^ 3))
        (dvd_mul_of_dvd_left hi3 y)) q23))
      (dvd_mul_of_dvd_right hy3 q30)
  have hdvd : (2 : ℤ) ∣
      ((q00 + q01 * i + q02 * i ^ 2 + q03 * i ^ 3 + q04 * i ^ 4 +
        q05 * i ^ 5 + q06 * i ^ 6 + q07 * i ^ 7 + q08 * i ^ 8 + q09 * i ^ 9) +
       (q10 + q11 * i + q12 * i ^ 2 + q13 * i ^ 3 + q14 * i ^ 4 +
        q15 * i ^ 5 + q16 * i ^ 6) * y +
       (q20 + q21 * i + q22 * i ^ 2 + q23 * i ^ 3) * y ^ 2 +
       q30 * y ^ 3) - q00 := by
    rw [hdecomp]
    exact dvd_add (dvd_add (dvd_add hd_lin hd_q0) hd_q1) hd_q23
  rcases hdvd with ⟨k, hk⟩
  omega

/-! ### Soundness of `checkPackedD2M2` -/

private theorem awayFromInt_of_checkCoeffsD2M2 {R M c0 c1 c2
    p00 n00 p01 n01 p02 n02 p03 n03 p04 n04
    p10 n10 p11 n11 p12 n12 p20 n20 : Nat}
    (h : checkCoeffsD2M2 R M c0 c1 c2
      p00 n00 p01 n01 p02 n02 p03 n03 p04 n04
      p10 n10 p11 n11 p12 n12 p20 n20 = true)
    (i y : ℤ) (hi : |i| ≤ R) :
    (M : ℝ) / (S64 : ℝ) <
      |(y : ℝ) - ((c0 : ℝ) + (c1 : ℝ) * i + (c2 : ℝ) * i ^ 2) / (S64 : ℝ)| := by
  by_contra hle
  push Not at hle
  -- Extract parity and L1 inequality from the Boolean check without zeta-expansion.
  unfold checkCoeffsD2M2 at h
  extract_lets ok0 ok1 ok2 ok3 R2 R3 R4 u0 u1 u2 q0 q1 q2 q3 q4 p11' n11' p12' n12'
    ap0 an0 ap1 an1 ap2 an2 ap3 an3 ap4 an4 t0 t1 t2 t3 t4
    dp0 dn0 dp1 dn1 dp2 dn2 w0 w1 w2 q20Norm v0 slack l1 at h
  have ⟨hok0, hok1, hok2, hok3, hl1⟩ := bool_if_not_and4 h
  have hl1_nat : l1 < Nat.mul 8 S64 := nat_lt_of_blt hl1
  -- Lower bound 1 ≤ |Q(i, y)| from odd parity.
  set QZ : ℤ :=
    (((p00 : ℤ) - n00) + ((p01 : ℤ) - n01) * i + ((p02 : ℤ) - n02) * i ^ 2 +
      ((p03 : ℤ) - n03) * i ^ 3 + ((p04 : ℤ) - n04) * i ^ 4) +
    (((p10 : ℤ) - n10) + ((p11 : ℤ) - n11) * i + ((p12 : ℤ) - n12) * i ^ 2) * y +
    ((p20 : ℤ) - n20) * y ^ 2
  have hQ_ge_one : (1 : ℝ) ≤ |(QZ : ℝ)| :=
    one_le_abs_cast_of_emod_two_eq_one (parity_d2m2 hok0 hok1 hok2 hok3 i y)
  -- Express i = R * t with |t| ≤ 1 and y = P + E with |E| ≤ M / S64.
  rcases exists_unit_param R i hi with ⟨t, ht, hit⟩
  set S : ℝ := (S64 : ℝ)
  have hSpos : 0 < S := S64_pos
  set P : ℝ := ((c0 : ℝ) + (c1 : ℝ) * (i : ℝ) + (c2 : ℝ) * (i : ℝ) ^ 2) / S
  set E : ℝ := (y : ℝ) - P
  have hE : |E| ≤ (M : ℝ) / S := hle
  have hy_eq : (y : ℝ) = P + E := by simp [E]
  -- Expand Q(R * t, P + E) = A0 + A1 * E + q20 * E^2.
  set Q0 : ℝ := ((p00 : ℝ) - n00) + ((p01 : ℝ) - n01) * (R : ℝ) * t +
    ((p02 : ℝ) - n02) * ((R : ℝ) * t) ^ 2 +
    ((p03 : ℝ) - n03) * ((R : ℝ) * t) ^ 3 +
    ((p04 : ℝ) - n04) * ((R : ℝ) * t) ^ 4
  set Q1 : ℝ := ((p10 : ℝ) - n10) + ((p11 : ℝ) - n11) * (R : ℝ) * t +
    ((p12 : ℝ) - n12) * ((R : ℝ) * t) ^ 2
  set Q2 : ℝ := (p20 : ℝ) - n20
  have hQ_cast : (QZ : ℝ) = Q0 + Q1 * (P + E) + Q2 * (P + E) ^ 2 := by
    simp only [QZ, Q0, Q1, Q2]
    push_cast
    rw [hit, hy_eq]
    ring
  set A0 : ℝ := Q0 + Q1 * P + Q2 * P ^ 2
  set A1 : ℝ := Q1 + 2 * Q2 * P
  have hQ_taylor : 8 * S * (QZ : ℝ) = 8 * S * A0 + 8 * S * A1 * E + 8 * S * Q2 * E ^ 2 := by
    rw [hQ_cast]; simp only [A0, A1]; ring
  -- Express P and S * P^2 in terms of u0, u1, u2 and floor errors δ0..δ4.
  have hP_t : S * P = (u0 : ℝ) + (u1 : ℝ) * t + (u2 : ℝ) * t ^ 2 := by
    simp only [P, u0, u1, u2, R2, nat_mul_eq]
    rw [mul_div_cancel₀ _ (ne_of_gt hSpos), hit]
    push_cast; ring
  set δ0 : ℝ := ((Nat.mul u0 u0 : Nat) : ℝ) / S - (q0 : ℝ)
  set δ1 : ℝ := ((Nat.mul 2 (Nat.mul u0 u1) : Nat) : ℝ) / S - (q1 : ℝ)
  set δ2 : ℝ := ((Nat.add (Nat.mul u1 u1) (Nat.mul 2 (Nat.mul u0 u2)) : Nat) : ℝ) / S - (q2 : ℝ)
  set δ3 : ℝ := ((Nat.mul 2 (Nat.mul u1 u2) : Nat) : ℝ) / S - (q3 : ℝ)
  set δ4 : ℝ := ((Nat.mul u2 u2 : Nat) : ℝ) / S - (q4 : ℝ)
  have hδ0 := div_sub_natDiv_bounds (Nat.mul u0 u0) S64 S64_nat_pos
  have hδ1 := div_sub_natDiv_bounds (Nat.mul 2 (Nat.mul u0 u1)) S64 S64_nat_pos
  have hδ2 := div_sub_natDiv_bounds
    (Nat.add (Nat.mul u1 u1) (Nat.mul 2 (Nat.mul u0 u2))) S64 S64_nat_pos
  have hδ3 := div_sub_natDiv_bounds (Nat.mul 2 (Nat.mul u1 u2)) S64 S64_nat_pos
  have hδ4 := div_sub_natDiv_bounds (Nat.mul u2 u2) S64 S64_nat_pos
  have hSP2 : S * P ^ 2 = ((q0 : ℝ) + δ0) + ((q1 : ℝ) + δ1) * t + ((q2 : ℝ) + δ2) * t ^ 2 +
      ((q3 : ℝ) + δ3) * t ^ 3 + ((q4 : ℝ) + δ4) * t ^ 4 := by
    have h1 : S * P ^ 2 = (S * P) ^ 2 / S := by field_simp [ne_of_gt hSpos]
    rw [h1, hP_t]
    simp only [δ0, δ1, δ2, δ3, δ4, nat_add_eq, nat_mul_eq]
    push_cast
    field_simp [ne_of_gt hSpos]
    ring
  -- Bound r = 0 term.
  have hA0_eq : 8 * S * A0 =
      8 * (((ap0 : ℝ) - an0) + ((ap1 : ℝ) - an1) * t + ((ap2 : ℝ) - an2) * t ^ 2 +
           ((ap3 : ℝ) - an3) * t ^ 3 + ((ap4 : ℝ) - an4) * t ^ 4) +
      8 * Q2 * (δ0 + δ1 * t + δ2 * t ^ 2 + δ3 * t ^ 3 + δ4 * t ^ 4) := by
    have hSA0 : S * A0 = S * Q0 + Q1 * (S * P) + Q2 * (S * P ^ 2) := by
      simp only [A0]; ring
    rw [mul_assoc, hSA0, hP_t, hSP2]
    simp only [Q0, Q1, Q2, ap0, an0, ap1, an1, ap2, an2, ap3, an3, ap4, an4,
      p11', n11', p12', n12', R2, R3, R4, nat_add_eq, nat_mul_eq]
    push_cast; ring
  have hδ_sum : |δ0 + δ1 * t + δ2 * t ^ 2 + δ3 * t ^ 3 + δ4 * t ^ 4| ≤ 5 := by
    have htri : |δ0 + δ1 * t + δ2 * t ^ 2 + δ3 * t ^ 3 + δ4 * t ^ 4| ≤
        |δ0| + |δ1 * t| + |δ2 * t ^ 2| + |δ3 * t ^ 3| + |δ4 * t ^ 4| := by
      have a1 := abs_add_le (δ0 + δ1 * t + δ2 * t ^ 2 + δ3 * t ^ 3) (δ4 * t ^ 4)
      have a2 := abs_add_le (δ0 + δ1 * t + δ2 * t ^ 2) (δ3 * t ^ 3)
      have a3 := abs_add_le (δ0 + δ1 * t) (δ2 * t ^ 2)
      have a4 := abs_add_le δ0 (δ1 * t)
      linarith
    have b0 : |δ0| ≤ 1 := abs_le.mpr ⟨by linarith [hδ0.1], by linarith [hδ0.2]⟩
    have b1 : |δ1 * t| ≤ 1 := by
      have := abs_mul_pow_le δ1 ht 1
      simp only [pow_one] at this
      exact this.trans (abs_le.mpr ⟨by linarith [hδ1.1], by linarith [hδ1.2]⟩)
    have b2 : |δ2 * t ^ 2| ≤ 1 :=
      (abs_mul_pow_le δ2 ht 2).trans (abs_le.mpr ⟨by linarith [hδ2.1], by linarith [hδ2.2]⟩)
    have b3 : |δ3 * t ^ 3| ≤ 1 :=
      (abs_mul_pow_le δ3 ht 3).trans (abs_le.mpr ⟨by linarith [hδ3.1], by linarith [hδ3.2]⟩)
    have b4 : |δ4 * t ^ 4| ≤ 1 :=
      (abs_mul_pow_le δ4 ht 4).trans (abs_le.mpr ⟨by linarith [hδ4.1], by linarith [hδ4.2]⟩)
    linarith
  have hQ2_abs : |Q2| ≤ (q20Norm : ℝ) := by
    simpa only [Q2, q20Norm, nat_add_eq, Nat.cast_add] using abs_sub_cast_le_add_cast p20 n20
  have hA0_err : |8 * Q2 * (δ0 + δ1 * t + δ2 * t ^ 2 + δ3 * t ^ 3 + δ4 * t ^ 4)| ≤
      40 * (q20Norm : ℝ) := by
    rw [abs_mul, abs_mul, abs_of_pos (by norm_num : (0 : ℝ) < 8)]
    have h1 : |Q2| * |δ0 + δ1 * t + δ2 * t ^ 2 + δ3 * t ^ 3 + δ4 * t ^ 4| ≤
        (q20Norm : ℝ) * 5 :=
      mul_le_mul hQ2_abs hδ_sum (abs_nonneg _) (Nat.cast_nonneg _)
    linarith
  have hA0_bound : |8 * S * A0| ≤ (t0 : ℝ) + t1 + t2 + t3 + t4 + 40 * (q20Norm : ℝ) := by
    rw [hA0_eq]
    exact (abs_add_le _ _).trans
      (add_le_add (abs_cheb8_deg4_le ap0 an0 ap1 an1 ap2 an2 ap3 an3 ap4 an4 ht) hA0_err)
  -- Bound r = 1 term.
  set bp0 := Nat.add (Nat.mul p10 S64) (Nat.mul 2 (Nat.mul p20 u0))
  set bn0 := Nat.add (Nat.mul n10 S64) (Nat.mul 2 (Nat.mul n20 u0))
  set bp1 := Nat.add (Nat.mul p11' S64) (Nat.mul 2 (Nat.mul p20 u1))
  set bn1 := Nat.add (Nat.mul n11' S64) (Nat.mul 2 (Nat.mul n20 u1))
  set bp2 := Nat.add (Nat.mul p12' S64) (Nat.mul 2 (Nat.mul p20 u2))
  set bn2 := Nat.add (Nat.mul n12' S64) (Nat.mul 2 (Nat.mul n20 u2))
  set ε0 : ℝ := (((Nat.mul bp0 M : Nat) : ℝ) / S - ((Nat.mul bn0 M : Nat) : ℝ) / S) -
    ((dp0 : ℝ) - dn0)
  set ε1 : ℝ := (((Nat.mul bp1 M : Nat) : ℝ) / S - ((Nat.mul bn1 M : Nat) : ℝ) / S) -
    ((dp1 : ℝ) - dn1)
  set ε2 : ℝ := (((Nat.mul bp2 M : Nat) : ℝ) / S - ((Nat.mul bn2 M : Nat) : ℝ) / S) -
    ((dp2 : ℝ) - dn2)
  have hε0 : |ε0| ≤ 1 := abs_div_sub_natDiv_sub_le (Nat.mul bp0 M) (Nat.mul bn0 M) S64 S64_nat_pos
  have hε1 : |ε1| ≤ 1 := abs_div_sub_natDiv_sub_le (Nat.mul bp1 M) (Nat.mul bn1 M) S64 S64_nat_pos
  have hε2 : |ε2| ≤ 1 := abs_div_sub_natDiv_sub_le (Nat.mul bp2 M) (Nat.mul bn2 M) S64 S64_nat_pos
  have hMA1 : 8 * (M : ℝ) * A1 =
      8 * (((dp0 : ℝ) - dn0) + ((dp1 : ℝ) - dn1) * t + ((dp2 : ℝ) - dn2) * t ^ 2) +
      8 * (ε0 + ε1 * t + ε2 * t ^ 2) := by
    have hSA1 : S * A1 = ((bp0 : ℝ) - bn0) + ((bp1 : ℝ) - bn1) * t +
        ((bp2 : ℝ) - bn2) * t ^ 2 := by
      have h1 : S * A1 = S * Q1 + 2 * Q2 * (S * P) := by simp only [A1]; ring
      rw [h1, hP_t]
      simp only [Q1, Q2, bp0, bn0, bp1, bn1, bp2, bn2, p11', n11', p12', n12', R2,
        nat_add_eq, nat_mul_eq]
      push_cast; ring
    have hMA1' : (M : ℝ) * A1 = (S * A1) * (M : ℝ) / S := by field_simp [ne_of_gt hSpos]
    rw [mul_assoc, hMA1', hSA1]
    simp only [ε0, ε1, ε2, nat_mul_eq]
    push_cast
    field_simp [ne_of_gt hSpos]
    ring
  have hε_sum : |8 * (ε0 + ε1 * t + ε2 * t ^ 2)| ≤ 24 := by
    rw [abs_mul, abs_of_pos (by norm_num : (0 : ℝ) < 8)]
    have htri : |ε0 + ε1 * t + ε2 * t ^ 2| ≤ |ε0| + |ε1 * t| + |ε2 * t ^ 2| := by
      have a1 := abs_add_le (ε0 + ε1 * t) (ε2 * t ^ 2)
      have a2 := abs_add_le ε0 (ε1 * t)
      linarith
    have b1 : |ε1 * t| ≤ 1 := by
      have := abs_mul_pow_le ε1 ht 1; simp only [pow_one] at this; exact this.trans hε1
    have b2 : |ε2 * t ^ 2| ≤ 1 := (abs_mul_pow_le ε2 ht 2).trans hε2
    linarith
  have hMA1_bound : |8 * (M : ℝ) * A1| ≤ (w0 : ℝ) + w1 + w2 + 24 := by
    rw [hMA1]
    exact (abs_add_le _ _).trans
      (add_le_add (abs_cheb8_deg2_le dp0 dn0 dp1 dn1 dp2 dn2 ht) hε_sum)
  have hA1E_bound : |8 * S * A1 * E| ≤ |8 * (M : ℝ) * A1| := by
    rw [abs_mul, abs_mul, abs_mul, abs_of_pos (by norm_num : (0 : ℝ) < 8), abs_of_pos hSpos]
    have h1 : 8 * S * |A1| * |E| ≤ 8 * S * |A1| * ((M : ℝ) / S) :=
      mul_le_mul_of_nonneg_left hE (by positivity)
    have h2 : 8 * S * |A1| * ((M : ℝ) / S) = 8 * (M : ℝ) * |A1| := by
      field_simp [ne_of_gt hSpos]
    rw [h2] at h1
    simpa [abs_mul, abs_of_pos (by norm_num : (0 : ℝ) < 8),
      abs_of_nonneg (Nat.cast_nonneg (α := ℝ) M)] using h1
  -- Bound r = 2 term.
  have hA2_bound : |8 * S * Q2 * E ^ 2| ≤ (v0 : ℝ) := by
    rw [abs_mul, abs_mul, abs_mul, abs_pow,
      abs_of_pos (by norm_num : (0 : ℝ) < 8), abs_of_pos hSpos]
    have hE2 : |E| ^ 2 ≤ ((M : ℝ) / S) ^ 2 := pow_le_pow_left₀ (abs_nonneg E) hE 2
    have h1 : 8 * S * |Q2| * |E| ^ 2 ≤ 8 * S * (q20Norm : ℝ) * ((M : ℝ) / S) ^ 2 := by
      have h1a : 8 * S * |Q2| ≤ 8 * S * (q20Norm : ℝ) :=
        mul_le_mul_of_nonneg_left hQ2_abs (by positivity)
      exact mul_le_mul h1a hE2 (sq_nonneg _) (by positivity)
    have h2 : 8 * S * (q20Norm : ℝ) * ((M : ℝ) / S) ^ 2 =
        ((Nat.mul 8 (Nat.mul q20Norm (Nat.mul M M)) : Nat) : ℝ) / S := by
      simp only [nat_mul_eq]; push_cast; field_simp [ne_of_gt hSpos]
    have h3 := div_lt_natDiv_add_one
      (Nat.mul 8 (Nat.mul q20Norm (Nat.mul M M))) S64 S64_nat_pos
    have h4 : ((Nat.div (Nat.mul 8 (Nat.mul q20Norm (Nat.mul M M))) S64 : Nat) : ℝ) + 1 =
        (v0 : ℝ) := by simp only [v0, nat_add_eq]; push_cast; ring
    linarith
  -- Combine r = 0, 1, 2 bounds and compare with 8 * S.
  have hl1_real : 40 * (q20Norm : ℝ) + 24 +
      ((t0 : ℝ) + t1 + t2 + t3 + t4 + w0 + w1 + w2 + v0) < 8 * S := by
    have hcast : (l1 : ℝ) < ((Nat.mul 8 S64 : Nat) : ℝ) := (Nat.cast_lt (α := ℝ)).mpr hl1_nat
    have hl1_eq : (l1 : ℝ) = 40 * (q20Norm : ℝ) + 24 +
        ((t0 : ℝ) + t1 + t2 + t3 + t4 + w0 + w1 + w2 + v0) := by
      simp only [l1, slack, nat_add_eq, nat_mul_eq, Nat.cast_add, Nat.cast_mul, Nat.cast_ofNat]
      ring
    have hrhs_eq : ((Nat.mul 8 S64 : Nat) : ℝ) = 8 * S := by
      simp only [S, nat_mul_eq, Nat.cast_mul, Nat.cast_ofNat]
    linarith
  have hQ_tri : |8 * S * (QZ : ℝ)| ≤
      |8 * S * A0| + |8 * S * A1 * E| + |8 * S * Q2 * E ^ 2| := by
    rw [hQ_taylor]
    have a1 := abs_add_le (8 * S * A0 + 8 * S * A1 * E) (8 * S * Q2 * E ^ 2)
    have a2 := abs_add_le (8 * S * A0) (8 * S * A1 * E)
    linarith
  have hQ_lt : |8 * S * (QZ : ℝ)| < 8 * S := by
    linarith only [hl1_real, hQ_tri, hA0_bound, hA1E_bound, hMA1_bound, hA2_bound]
  have hQ_eq : |8 * S * (QZ : ℝ)| = 8 * S * |(QZ : ℝ)| := by
    rw [abs_mul, abs_of_pos (by positivity : (0 : ℝ) < 8 * S)]
  rw [hQ_eq] at hQ_lt
  have hQ_ge : 8 * S * (1 : ℝ) ≤ 8 * S * |(QZ : ℝ)| :=
    mul_le_mul_of_nonneg_left hQ_ge_one (by positivity)
  linarith only [hQ_lt, hQ_ge]

/-- Soundness of `checkPackedD2M2` with `(S64 : ℝ)` as denominator (avoids Lean's `npowRec`
recursion-depth blowup when unifying `(2 ^ 64 : ℝ)` under `<`). -/
theorem awayFromInt_of_checkPackedD2M2_S64 {R M c0 c1 c2 packedQ : Nat}
    (h : checkPackedD2M2 R M c0 c1 c2 packedQ = true)
    (i y : ℤ) (hi : |i| ≤ R) :
    (M : ℝ) / (S64 : ℝ) <
      |(y : ℝ) - ((c0 : ℝ) + (c1 : ℝ) * i + (c2 : ℝ) * i ^ 2) / (S64 : ℝ)| := by
  unfold checkPackedD2M2 at h
  extract_lets u00 q0 u01 q1 u02 q2 u03 q3 u04 q4 u10 q5 u11 q6 u12 q7 u20 at h
  exact @awayFromInt_of_checkCoeffsD2M2 R M c0 c1 c2
    u00.1 u00.2 u01.1 u01.2 u02.1 u02.2 u03.1 u03.2 u04.1 u04.2
    u10.1 u10.2 u11.1 u11.2 u12.1 u12.2 u20.1 u20.2 h i y hi

/-- Soundness of `checkPackedD2M2`: if the certificate verifies, then every integer `y`
stays strictly farther than `M / 2 ^ 64` from the degree-2 polynomial approximation at every
integer `i` with `|i| ≤ R`. -/
theorem awayFromInt_of_checkPackedD2M2 {R M c0 c1 c2 packedQ : Nat}
    (h : checkPackedD2M2 R M c0 c1 c2 packedQ = true)
    (i y : ℤ) (hi : |i| ≤ R) :
    (M : ℝ) / (2 ^ 64 : ℝ) <
      |(y : ℝ) - ((c0 : ℝ) + (c1 : ℝ) * i + (c2 : ℝ) * i ^ 2) / (2 ^ 64 : ℝ)| := by
  rw [← S64_eq]
  exact awayFromInt_of_checkPackedD2M2_S64 h i y hi

/-! ### Soundness of `checkPackedD3M3` -/

/-- Helper bounding the `P^3` truncation error polynomial on `|t| ≤ 1`. -/
private lemma abs_p3_err_le (u0 u1 u2 u3 q0 q1 q2 q3 q4 q5 q6 : Nat)
    {δ0 δ1 δ2 δ3 δ4 δ5 δ6 : ℝ}
    (hδ0 : 0 ≤ δ0 ∧ δ0 < 1) (hδ1 : 0 ≤ δ1 ∧ δ1 < 1) (hδ2 : 0 ≤ δ2 ∧ δ2 < 1)
    (hδ3 : 0 ≤ δ3 ∧ δ3 < 1) (hδ4 : 0 ≤ δ4 ∧ δ4 < 1) (hδ5 : 0 ≤ δ5 ∧ δ5 < 1)
    (hδ6 : 0 ≤ δ6 ∧ δ6 < 1)
    {t : ℝ} (ht : |t| ≤ 1) :
    let S : ℝ := (S64 : ℝ)
    let s0 := Nat.div (Nat.mul q0 u0) S64
    let s1 := Nat.div (Nat.add (Nat.mul q0 u1) (Nat.mul q1 u0)) S64
    let s2 := Nat.div (Nat.add (Nat.mul q0 u2) (Nat.add (Nat.mul q1 u1) (Nat.mul q2 u0))) S64
    let s3 := Nat.div (Nat.add (Nat.mul q0 u3)
      (Nat.add (Nat.mul q1 u2) (Nat.add (Nat.mul q2 u1) (Nat.mul q3 u0)))) S64
    let s4 := Nat.div (Nat.add (Nat.mul q1 u3)
      (Nat.add (Nat.mul q2 u2) (Nat.add (Nat.mul q3 u1) (Nat.mul q4 u0)))) S64
    let s5 := Nat.div (Nat.add (Nat.mul q2 u3)
      (Nat.add (Nat.mul q3 u2) (Nat.add (Nat.mul q4 u1) (Nat.mul q5 u0)))) S64
    let s6 := Nat.div (Nat.add (Nat.mul q3 u3)
      (Nat.add (Nat.mul q4 u2) (Nat.add (Nat.mul q5 u1) (Nat.mul q6 u0)))) S64
    let s7 := Nat.div (Nat.add (Nat.mul q4 u3) (Nat.add (Nat.mul q5 u2) (Nat.mul q6 u1))) S64
    let s8 := Nat.div (Nat.add (Nat.mul q5 u3) (Nat.mul q6 u2)) S64
    let s9 := Nat.div (Nat.mul q6 u3) S64
    |(((q0 : ℝ) + δ0) + ((q1 : ℝ) + δ1) * t + ((q2 : ℝ) + δ2) * t ^ 2 +
      ((q3 : ℝ) + δ3) * t ^ 3 + ((q4 : ℝ) + δ4) * t ^ 4 +
      ((q5 : ℝ) + δ5) * t ^ 5 + ((q6 : ℝ) + δ6) * t ^ 6) *
     ((u0 : ℝ) + (u1 : ℝ) * t + (u2 : ℝ) * t ^ 2 + (u3 : ℝ) * t ^ 3) / S -
     ((s0 : ℝ) + (s1 : ℝ) * t + (s2 : ℝ) * t ^ 2 + (s3 : ℝ) * t ^ 3 + (s4 : ℝ) * t ^ 4 +
      (s5 : ℝ) * t ^ 5 + (s6 : ℝ) * t ^ 6 + (s7 : ℝ) * t ^ 7 +
      (s8 : ℝ) * t ^ 8 + (s9 : ℝ) * t ^ 9)| ≤
    ((Nat.add 11 (Nat.div (Nat.mul 7
      (Nat.add u0 (Nat.add u1 (Nat.add u2 u3)))) S64) : Nat) : ℝ) := by
  intro S s0 s1 s2 s3 s4 s5 s6 s7 s8 s9
  have hSpos : 0 < S := S64_pos
  set m0 := Nat.mul q0 u0
  set m1 := Nat.add (Nat.mul q0 u1) (Nat.mul q1 u0)
  set m2 := Nat.add (Nat.mul q0 u2) (Nat.add (Nat.mul q1 u1) (Nat.mul q2 u0))
  set m3 := Nat.add (Nat.mul q0 u3)
    (Nat.add (Nat.mul q1 u2) (Nat.add (Nat.mul q2 u1) (Nat.mul q3 u0)))
  set m4 := Nat.add (Nat.mul q1 u3)
    (Nat.add (Nat.mul q2 u2) (Nat.add (Nat.mul q3 u1) (Nat.mul q4 u0)))
  set m5 := Nat.add (Nat.mul q2 u3)
    (Nat.add (Nat.mul q3 u2) (Nat.add (Nat.mul q4 u1) (Nat.mul q5 u0)))
  set m6 := Nat.add (Nat.mul q3 u3)
    (Nat.add (Nat.mul q4 u2) (Nat.add (Nat.mul q5 u1) (Nat.mul q6 u0)))
  set m7 := Nat.add (Nat.mul q4 u3) (Nat.add (Nat.mul q5 u2) (Nat.mul q6 u1))
  set m8 := Nat.add (Nat.mul q5 u3) (Nat.mul q6 u2)
  set m9 := Nat.mul q6 u3
  set γ0 : ℝ := (m0 : ℝ) / S - (s0 : ℝ)
  set γ1 : ℝ := (m1 : ℝ) / S - (s1 : ℝ)
  set γ2 : ℝ := (m2 : ℝ) / S - (s2 : ℝ)
  set γ3 : ℝ := (m3 : ℝ) / S - (s3 : ℝ)
  set γ4 : ℝ := (m4 : ℝ) / S - (s4 : ℝ)
  set γ5 : ℝ := (m5 : ℝ) / S - (s5 : ℝ)
  set γ6 : ℝ := (m6 : ℝ) / S - (s6 : ℝ)
  set γ7 : ℝ := (m7 : ℝ) / S - (s7 : ℝ)
  set γ8 : ℝ := (m8 : ℝ) / S - (s8 : ℝ)
  set γ9 : ℝ := (m9 : ℝ) / S - (s9 : ℝ)
  have hγ0 := div_sub_natDiv_bounds m0 S64 S64_nat_pos
  have hγ1 := div_sub_natDiv_bounds m1 S64 S64_nat_pos
  have hγ2 := div_sub_natDiv_bounds m2 S64 S64_nat_pos
  have hγ3 := div_sub_natDiv_bounds m3 S64 S64_nat_pos
  have hγ4 := div_sub_natDiv_bounds m4 S64 S64_nat_pos
  have hγ5 := div_sub_natDiv_bounds m5 S64 S64_nat_pos
  have hγ6 := div_sub_natDiv_bounds m6 S64 S64_nat_pos
  have hγ7 := div_sub_natDiv_bounds m7 S64 S64_nat_pos
  have hγ8 := div_sub_natDiv_bounds m8 S64 S64_nat_pos
  have hγ9 := div_sub_natDiv_bounds m9 S64 S64_nat_pos
  set δPoly : ℝ := δ0 + δ1 * t + δ2 * t ^ 2 + δ3 * t ^ 3 + δ4 * t ^ 4 +
    δ5 * t ^ 5 + δ6 * t ^ 6
  set uPoly : ℝ := (u0 : ℝ) + (u1 : ℝ) * t + (u2 : ℝ) * t ^ 2 + (u3 : ℝ) * t ^ 3
  set γPoly : ℝ := γ0 + γ1 * t + γ2 * t ^ 2 + γ3 * t ^ 3 + γ4 * t ^ 4 +
    γ5 * t ^ 5 + γ6 * t ^ 6 + γ7 * t ^ 7 + γ8 * t ^ 8 + γ9 * t ^ 9
  have hsplit :
      (((q0 : ℝ) + δ0) + ((q1 : ℝ) + δ1) * t + ((q2 : ℝ) + δ2) * t ^ 2 +
       ((q3 : ℝ) + δ3) * t ^ 3 + ((q4 : ℝ) + δ4) * t ^ 4 +
       ((q5 : ℝ) + δ5) * t ^ 5 + ((q6 : ℝ) + δ6) * t ^ 6) * uPoly / S -
      ((s0 : ℝ) + (s1 : ℝ) * t + (s2 : ℝ) * t ^ 2 + (s3 : ℝ) * t ^ 3 + (s4 : ℝ) * t ^ 4 +
       (s5 : ℝ) * t ^ 5 + (s6 : ℝ) * t ^ 6 + (s7 : ℝ) * t ^ 7 +
       (s8 : ℝ) * t ^ 8 + (s9 : ℝ) * t ^ 9) =
      γPoly + δPoly * uPoly / S := by
    simp only [γPoly, δPoly, uPoly, γ0, γ1, γ2, γ3, γ4, γ5, γ6, γ7, γ8, γ9,
      m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, nat_add_eq, nat_mul_eq]
    push_cast
    field_simp [ne_of_gt hSpos]
    ring
  rw [hsplit]
  have hγ_le : |γPoly| ≤ 10 := by
    have htri : |γPoly| ≤ |γ0| + |γ1 * t| + |γ2 * t ^ 2| + |γ3 * t ^ 3| + |γ4 * t ^ 4| +
        |γ5 * t ^ 5| + |γ6 * t ^ 6| + |γ7 * t ^ 7| + |γ8 * t ^ 8| + |γ9 * t ^ 9| := by
      simp only [γPoly]
      have a1 := abs_add_le (γ0 + γ1 * t + γ2 * t ^ 2 + γ3 * t ^ 3 + γ4 * t ^ 4 +
        γ5 * t ^ 5 + γ6 * t ^ 6 + γ7 * t ^ 7 + γ8 * t ^ 8) (γ9 * t ^ 9)
      have a2 := abs_add_le (γ0 + γ1 * t + γ2 * t ^ 2 + γ3 * t ^ 3 + γ4 * t ^ 4 +
        γ5 * t ^ 5 + γ6 * t ^ 6 + γ7 * t ^ 7) (γ8 * t ^ 8)
      have a3 := abs_add_le (γ0 + γ1 * t + γ2 * t ^ 2 + γ3 * t ^ 3 + γ4 * t ^ 4 +
        γ5 * t ^ 5 + γ6 * t ^ 6) (γ7 * t ^ 7)
      have a4 := abs_add_le (γ0 + γ1 * t + γ2 * t ^ 2 + γ3 * t ^ 3 + γ4 * t ^ 4 +
        γ5 * t ^ 5) (γ6 * t ^ 6)
      have a5 := abs_add_le (γ0 + γ1 * t + γ2 * t ^ 2 + γ3 * t ^ 3 + γ4 * t ^ 4) (γ5 * t ^ 5)
      have a6 := abs_add_le (γ0 + γ1 * t + γ2 * t ^ 2 + γ3 * t ^ 3) (γ4 * t ^ 4)
      have a7 := abs_add_le (γ0 + γ1 * t + γ2 * t ^ 2) (γ3 * t ^ 3)
      have a8 := abs_add_le (γ0 + γ1 * t) (γ2 * t ^ 2)
      have a9 := abs_add_le γ0 (γ1 * t)
      linarith
    have b0 : |γ0| ≤ 1 := abs_le.mpr ⟨by linarith [hγ0.1], by linarith [hγ0.2]⟩
    have b1 : |γ1 * t| ≤ 1 := by
      have := abs_mul_pow_le γ1 ht 1; simp only [pow_one] at this
      exact this.trans (abs_le.mpr ⟨by linarith [hγ1.1], by linarith [hγ1.2]⟩)
    have b2 : |γ2 * t ^ 2| ≤ 1 :=
      (abs_mul_pow_le γ2 ht 2).trans (abs_le.mpr ⟨by linarith [hγ2.1], by linarith [hγ2.2]⟩)
    have b3 : |γ3 * t ^ 3| ≤ 1 :=
      (abs_mul_pow_le γ3 ht 3).trans (abs_le.mpr ⟨by linarith [hγ3.1], by linarith [hγ3.2]⟩)
    have b4 : |γ4 * t ^ 4| ≤ 1 :=
      (abs_mul_pow_le γ4 ht 4).trans (abs_le.mpr ⟨by linarith [hγ4.1], by linarith [hγ4.2]⟩)
    have b5 : |γ5 * t ^ 5| ≤ 1 :=
      (abs_mul_pow_le γ5 ht 5).trans (abs_le.mpr ⟨by linarith [hγ5.1], by linarith [hγ5.2]⟩)
    have b6 : |γ6 * t ^ 6| ≤ 1 :=
      (abs_mul_pow_le γ6 ht 6).trans (abs_le.mpr ⟨by linarith [hγ6.1], by linarith [hγ6.2]⟩)
    have b7 : |γ7 * t ^ 7| ≤ 1 :=
      (abs_mul_pow_le γ7 ht 7).trans (abs_le.mpr ⟨by linarith [hγ7.1], by linarith [hγ7.2]⟩)
    have b8 : |γ8 * t ^ 8| ≤ 1 :=
      (abs_mul_pow_le γ8 ht 8).trans (abs_le.mpr ⟨by linarith [hγ8.1], by linarith [hγ8.2]⟩)
    have b9 : |γ9 * t ^ 9| ≤ 1 :=
      (abs_mul_pow_le γ9 ht 9).trans (abs_le.mpr ⟨by linarith [hγ9.1], by linarith [hγ9.2]⟩)
    linarith only [htri, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9]
  have hδ_le : |δPoly| ≤ 7 := by
    have htri : |δPoly| ≤ |δ0| + |δ1 * t| + |δ2 * t ^ 2| + |δ3 * t ^ 3| +
        |δ4 * t ^ 4| + |δ5 * t ^ 5| + |δ6 * t ^ 6| := by
      simp only [δPoly]
      have a1 := abs_add_le (δ0 + δ1 * t + δ2 * t ^ 2 + δ3 * t ^ 3 + δ4 * t ^ 4 +
        δ5 * t ^ 5) (δ6 * t ^ 6)
      have a2 := abs_add_le (δ0 + δ1 * t + δ2 * t ^ 2 + δ3 * t ^ 3 + δ4 * t ^ 4) (δ5 * t ^ 5)
      have a3 := abs_add_le (δ0 + δ1 * t + δ2 * t ^ 2 + δ3 * t ^ 3) (δ4 * t ^ 4)
      have a4 := abs_add_le (δ0 + δ1 * t + δ2 * t ^ 2) (δ3 * t ^ 3)
      have a5 := abs_add_le (δ0 + δ1 * t) (δ2 * t ^ 2)
      have a6 := abs_add_le δ0 (δ1 * t)
      linarith
    have b0 : |δ0| ≤ 1 := abs_le.mpr ⟨by linarith [hδ0.1], by linarith [hδ0.2]⟩
    have b1 : |δ1 * t| ≤ 1 := by
      have := abs_mul_pow_le δ1 ht 1; simp only [pow_one] at this
      exact this.trans (abs_le.mpr ⟨by linarith [hδ1.1], by linarith [hδ1.2]⟩)
    have b2 : |δ2 * t ^ 2| ≤ 1 :=
      (abs_mul_pow_le δ2 ht 2).trans (abs_le.mpr ⟨by linarith [hδ2.1], by linarith [hδ2.2]⟩)
    have b3 : |δ3 * t ^ 3| ≤ 1 :=
      (abs_mul_pow_le δ3 ht 3).trans (abs_le.mpr ⟨by linarith [hδ3.1], by linarith [hδ3.2]⟩)
    have b4 : |δ4 * t ^ 4| ≤ 1 :=
      (abs_mul_pow_le δ4 ht 4).trans (abs_le.mpr ⟨by linarith [hδ4.1], by linarith [hδ4.2]⟩)
    have b5 : |δ5 * t ^ 5| ≤ 1 :=
      (abs_mul_pow_le δ5 ht 5).trans (abs_le.mpr ⟨by linarith [hδ5.1], by linarith [hδ5.2]⟩)
    have b6 : |δ6 * t ^ 6| ≤ 1 :=
      (abs_mul_pow_le δ6 ht 6).trans (abs_le.mpr ⟨by linarith [hδ6.1], by linarith [hδ6.2]⟩)
    linarith only [htri, b0, b1, b2, b3, b4, b5, b6]
  have hu_le : |uPoly| ≤ ((Nat.add u0 (Nat.add u1 (Nat.add u2 u3)) : Nat) : ℝ) := by
    have htri : |uPoly| ≤ |(u0 : ℝ)| + |(u1 : ℝ) * t| + |(u2 : ℝ) * t ^ 2| +
        |(u3 : ℝ) * t ^ 3| := by
      simp only [uPoly]
      have a1 := abs_add_le ((u0 : ℝ) + (u1 : ℝ) * t + (u2 : ℝ) * t ^ 2) ((u3 : ℝ) * t ^ 3)
      have a2 := abs_add_le ((u0 : ℝ) + (u1 : ℝ) * t) ((u2 : ℝ) * t ^ 2)
      have a3 := abs_add_le (u0 : ℝ) ((u1 : ℝ) * t)
      linarith
    have b0 : |(u0 : ℝ)| = (u0 : ℝ) := abs_of_nonneg (Nat.cast_nonneg (α := ℝ) u0)
    have b1 : |(u1 : ℝ) * t| ≤ (u1 : ℝ) := by
      have := abs_mul_pow_le (u1 : ℝ) ht 1
      rw [pow_one, abs_of_nonneg (Nat.cast_nonneg (α := ℝ) u1)] at this
      exact this
    have b2 : |(u2 : ℝ) * t ^ 2| ≤ (u2 : ℝ) := by
      have := abs_mul_pow_le (u2 : ℝ) ht 2
      rw [abs_of_nonneg (Nat.cast_nonneg (α := ℝ) u2)] at this
      exact this
    have b3 : |(u3 : ℝ) * t ^ 3| ≤ (u3 : ℝ) := by
      have := abs_mul_pow_le (u3 : ℝ) ht 3
      rw [abs_of_nonneg (Nat.cast_nonneg (α := ℝ) u3)] at this
      exact this
    simp only [nat_add_eq, Nat.cast_add]
    linarith only [htri, b0, b1, b2, b3]
  set uTot := Nat.add u0 (Nat.add u1 (Nat.add u2 u3))
  have hprod : |δPoly * uPoly / S| ≤ ((Nat.mul 7 uTot : Nat) : ℝ) / S := by
    rw [abs_div, abs_mul, abs_of_pos hSpos]
    have hmul : |δPoly| * |uPoly| ≤ 7 * (uTot : ℝ) :=
      mul_le_mul hδ_le hu_le (abs_nonneg _) (by norm_num)
    have hdiv := div_le_div_of_nonneg_right hmul (le_of_lt hSpos)
    simpa only [nat_mul_eq, Nat.cast_mul, Nat.cast_ofNat] using hdiv
  have hdiv_lt : ((Nat.mul 7 uTot : Nat) : ℝ) / S <
      ((Nat.div (Nat.mul 7 uTot) S64 : Nat) : ℝ) + 1 :=
    div_lt_natDiv_add_one (Nat.mul 7 uTot) S64 S64_nat_pos
  have htri_main := abs_add_le γPoly (δPoly * uPoly / S)
  have hrhs : ((Nat.add 11 (Nat.div (Nat.mul 7 uTot) S64) : Nat) : ℝ) =
      11 + ((Nat.div (Nat.mul 7 uTot) S64 : Nat) : ℝ) := by
    simp only [nat_add_eq, Nat.cast_add, Nat.cast_ofNat]
  rw [hrhs]
  linarith only [htri_main, hγ_le, hprod, hdiv_lt]

/-- Helper bounding the `r = 1` term of `checkCoeffsD3M3`. -/
private lemma d3m3_r1_bound (M bp0 bn0 bp1 bn1 bp2 bn2 bp3 bn3 bp4 bn4 bp5 bn5 bp6 bn6 q3Norm : Nat)
    {A1 Q3 δPoly E t : ℝ} (ht : |t| ≤ 1) (hE : |E| ≤ (M : ℝ) / (S64 : ℝ))
    (hQ3 : |Q3| ≤ (q3Norm : ℝ)) (hδ : |δPoly| ≤ 7)
    (hSA1 : (S64 : ℝ) * A1 =
      (((bp0 : ℝ) - bn0) + ((bp1 : ℝ) - bn1) * t + ((bp2 : ℝ) - bn2) * t ^ 2 +
       ((bp3 : ℝ) - bn3) * t ^ 3 + ((bp4 : ℝ) - bn4) * t ^ 4 +
       ((bp5 : ℝ) - bn5) * t ^ 5 + ((bp6 : ℝ) - bn6) * t ^ 6) + 3 * Q3 * δPoly) :
    let dp0 := Nat.div (Nat.mul bp0 M) S64; let dn0 := Nat.div (Nat.mul bn0 M) S64
    let dp1 := Nat.div (Nat.mul bp1 M) S64; let dn1 := Nat.div (Nat.mul bn1 M) S64
    let dp2 := Nat.div (Nat.mul bp2 M) S64; let dn2 := Nat.div (Nat.mul bn2 M) S64
    let dp3 := Nat.div (Nat.mul bp3 M) S64; let dn3 := Nat.div (Nat.mul bn3 M) S64
    let dp4 := Nat.div (Nat.mul bp4 M) S64; let dn4 := Nat.div (Nat.mul bn4 M) S64
    let dp5 := Nat.div (Nat.mul bp5 M) S64; let dn5 := Nat.div (Nat.mul bn5 M) S64
    let dp6 := Nat.div (Nat.mul bp6 M) S64; let dn6 := Nat.div (Nat.mul bn6 M) S64
    |256 * (S64 : ℝ) * A1 * E| ≤
      ((natAbsDiff
        (Nat.add (Nat.mul 256 dp0) (Nat.add (Nat.mul 128 dp2)
          (Nat.add (Nat.mul 96 dp4) (Nat.mul 80 dp6))))
        (Nat.add (Nat.mul 256 dn0) (Nat.add (Nat.mul 128 dn2)
          (Nat.add (Nat.mul 96 dn4) (Nat.mul 80 dn6)))) : Nat) : ℝ) +
      ((natAbsDiff
        (Nat.add (Nat.mul 256 dp1) (Nat.add (Nat.mul 192 dp3) (Nat.mul 160 dp5)))
        (Nat.add (Nat.mul 256 dn1) (Nat.add (Nat.mul 192 dn3) (Nat.mul 160 dn5))) : Nat) : ℝ) +
      ((natAbsDiff
        (Nat.add (Nat.mul 128 dp2) (Nat.add (Nat.mul 128 dp4) (Nat.mul 120 dp6)))
        (Nat.add (Nat.mul 128 dn2) (Nat.add (Nat.mul 128 dn4) (Nat.mul 120 dn6))) : Nat) : ℝ) +
      ((natAbsDiff
        (Nat.add (Nat.mul 64 dp3) (Nat.mul 80 dp5))
        (Nat.add (Nat.mul 64 dn3) (Nat.mul 80 dn5)) : Nat) : ℝ) +
      ((natAbsDiff
        (Nat.add (Nat.mul 32 dp4) (Nat.mul 48 dp6))
        (Nat.add (Nat.mul 32 dn4) (Nat.mul 48 dn6)) : Nat) : ℝ) +
      ((natAbsDiff (Nat.mul 16 dp5) (Nat.mul 16 dn5) : Nat) : ℝ) +
      ((natAbsDiff (Nat.mul 8 dp6) (Nat.mul 8 dn6) : Nat) : ℝ) +
      1793 + ((Nat.div (Nat.mul 5376 (Nat.mul q3Norm M)) S64 : Nat) : ℝ) := by
  intro dp0 dn0 dp1 dn1 dp2 dn2 dp3 dn3 dp4 dn4 dp5 dn5 dp6 dn6
  set S : ℝ := (S64 : ℝ)
  have hSpos : 0 < S := S64_pos
  set ε0 : ℝ := (((Nat.mul bp0 M : Nat) : ℝ) / S - ((Nat.mul bn0 M : Nat) : ℝ) / S) -
    ((dp0 : ℝ) - dn0)
  set ε1 : ℝ := (((Nat.mul bp1 M : Nat) : ℝ) / S - ((Nat.mul bn1 M : Nat) : ℝ) / S) -
    ((dp1 : ℝ) - dn1)
  set ε2 : ℝ := (((Nat.mul bp2 M : Nat) : ℝ) / S - ((Nat.mul bn2 M : Nat) : ℝ) / S) -
    ((dp2 : ℝ) - dn2)
  set ε3 : ℝ := (((Nat.mul bp3 M : Nat) : ℝ) / S - ((Nat.mul bn3 M : Nat) : ℝ) / S) -
    ((dp3 : ℝ) - dn3)
  set ε4 : ℝ := (((Nat.mul bp4 M : Nat) : ℝ) / S - ((Nat.mul bn4 M : Nat) : ℝ) / S) -
    ((dp4 : ℝ) - dn4)
  set ε5 : ℝ := (((Nat.mul bp5 M : Nat) : ℝ) / S - ((Nat.mul bn5 M : Nat) : ℝ) / S) -
    ((dp5 : ℝ) - dn5)
  set ε6 : ℝ := (((Nat.mul bp6 M : Nat) : ℝ) / S - ((Nat.mul bn6 M : Nat) : ℝ) / S) -
    ((dp6 : ℝ) - dn6)
  have hε0 := abs_div_sub_natDiv_sub_le (Nat.mul bp0 M) (Nat.mul bn0 M) S64 S64_nat_pos
  have hε1 := abs_div_sub_natDiv_sub_le (Nat.mul bp1 M) (Nat.mul bn1 M) S64 S64_nat_pos
  have hε2 := abs_div_sub_natDiv_sub_le (Nat.mul bp2 M) (Nat.mul bn2 M) S64 S64_nat_pos
  have hε3 := abs_div_sub_natDiv_sub_le (Nat.mul bp3 M) (Nat.mul bn3 M) S64 S64_nat_pos
  have hε4 := abs_div_sub_natDiv_sub_le (Nat.mul bp4 M) (Nat.mul bn4 M) S64 S64_nat_pos
  have hε5 := abs_div_sub_natDiv_sub_le (Nat.mul bp5 M) (Nat.mul bn5 M) S64 S64_nat_pos
  have hε6 := abs_div_sub_natDiv_sub_le (Nat.mul bp6 M) (Nat.mul bn6 M) S64 S64_nat_pos
  set εPoly : ℝ := ε0 + ε1 * t + ε2 * t ^ 2 + ε3 * t ^ 3 + ε4 * t ^ 4 +
    ε5 * t ^ 5 + ε6 * t ^ 6
  have hMA1_eq : 256 * (M : ℝ) * A1 =
      256 * (((dp0 : ℝ) - dn0) + ((dp1 : ℝ) - dn1) * t + ((dp2 : ℝ) - dn2) * t ^ 2 +
             ((dp3 : ℝ) - dn3) * t ^ 3 + ((dp4 : ℝ) - dn4) * t ^ 4 +
             ((dp5 : ℝ) - dn5) * t ^ 5 + ((dp6 : ℝ) - dn6) * t ^ 6) +
      (256 * εPoly + 256 * (3 * Q3 * (M : ℝ) / S) * δPoly) := by
    have hMA1' : (M : ℝ) * A1 = (S * A1) * (M : ℝ) / S := by field_simp [ne_of_gt hSpos]
    rw [mul_assoc, hMA1', hSA1]
    simp only [εPoly, ε0, ε1, ε2, ε3, ε4, ε5, ε6, nat_mul_eq]
    push_cast
    field_simp [ne_of_gt hSpos]
    ring
  have hεPoly_le : |εPoly| ≤ 7 := abs_poly7_le_seven ht hε0 hε1 hε2 hε3 hε4 hε5 hε6
  have hA1_err : |256 * εPoly + 256 * (3 * Q3 * (M : ℝ) / S) * δPoly| ≤
      1793 + ((Nat.div (Nat.mul 5376 (Nat.mul q3Norm M)) S64 : Nat) : ℝ) := by
    refine (abs_add_le _ _).trans ?_
    have h1 : |256 * εPoly| ≤ 1792 := by
      rw [abs_mul, abs_of_pos (by norm_num : (0 : ℝ) < 256)]; linarith only [hεPoly_le]
    have h2 : |256 * (3 * Q3 * (M : ℝ) / S) * δPoly| ≤
        ((Nat.mul 5376 (Nat.mul q3Norm M) : Nat) : ℝ) / S := by
      rw [abs_mul, abs_mul, abs_div, abs_mul, abs_mul,
        abs_of_pos (by norm_num : (0 : ℝ) < 256), abs_of_pos (by norm_num : (0 : ℝ) < 3),
        abs_of_nonneg (Nat.cast_nonneg (α := ℝ) M), abs_of_pos hSpos]
      have ha : 3 * |Q3| * (M : ℝ) / S ≤ 3 * (q3Norm : ℝ) * (M : ℝ) / S := by
        refine div_le_div_of_nonneg_right ?_ (le_of_lt hSpos)
        exact mul_le_mul_of_nonneg_right
          (mul_le_mul_of_nonneg_left hQ3 (by norm_num)) (Nat.cast_nonneg (α := ℝ) M)
      have hb : 256 * (3 * |Q3| * (M : ℝ) / S) * |δPoly| ≤
          256 * (3 * (q3Norm : ℝ) * (M : ℝ) / S) * 7 :=
        mul_le_mul (mul_le_mul_of_nonneg_left ha (by norm_num)) hδ
          (abs_nonneg _) (by positivity)
      have hc : 256 * (3 * (q3Norm : ℝ) * (M : ℝ) / S) * 7 =
          ((Nat.mul 5376 (Nat.mul q3Norm M) : Nat) : ℝ) / S := by
        simp only [nat_mul_eq]; push_cast; ring
      linarith only [hb, hc]
    have hdiv := div_lt_natDiv_add_one (Nat.mul 5376 (Nat.mul q3Norm M)) S64 S64_nat_pos
    linarith only [h1, h2, hdiv]
  have hMA1_bound := (abs_add_le _ _).trans
    (add_le_add (abs_cheb256_deg6_le dp0 dn0 dp1 dn1 dp2 dn2 dp3 dn3 dp4 dn4 dp5 dn5 dp6 dn6 ht)
      hA1_err)
  rw [← hMA1_eq] at hMA1_bound
  have hA1E_bound : |256 * S * A1 * E| ≤ |256 * (M : ℝ) * A1| := by
    rw [abs_mul, abs_mul, abs_mul, abs_of_pos (by norm_num : (0 : ℝ) < 256), abs_of_pos hSpos]
    have h1 : 256 * S * |A1| * |E| ≤ 256 * S * |A1| * ((M : ℝ) / S) :=
      mul_le_mul_of_nonneg_left hE (by positivity)
    have h2 : 256 * S * |A1| * ((M : ℝ) / S) = 256 * (M : ℝ) * |A1| := by
      field_simp [ne_of_gt hSpos]
    rw [h2] at h1
    simpa [abs_mul, abs_of_pos (by norm_num : (0 : ℝ) < 256),
      abs_of_nonneg (Nat.cast_nonneg (α := ℝ) M)] using h1
  linarith only [hA1E_bound, hMA1_bound]

/-- Helper bounding the `r = 2` term of `checkCoeffsD3M3`. -/
private lemma d3m3_r2_bound (M ep0 en0 ep1 en1 ep2 en2 ep3 en3 : Nat)
    {A2 E t : ℝ} (ht : |t| ≤ 1) (hE : |E| ≤ (M : ℝ) / (S64 : ℝ))
    (hSA2 : (S64 : ℝ) * A2 = ((ep0 : ℝ) - en0) + ((ep1 : ℝ) - en1) * t +
      ((ep2 : ℝ) - en2) * t ^ 2 + ((ep3 : ℝ) - en3) * t ^ 3) :
    let M2 := Nat.mul M M
    let fp0 := Nat.div (Nat.mul ep0 M2) S128; let fn0 := Nat.div (Nat.mul en0 M2) S128
    let fp1 := Nat.div (Nat.mul ep1 M2) S128; let fn1 := Nat.div (Nat.mul en1 M2) S128
    let fp2 := Nat.div (Nat.mul ep2 M2) S128; let fn2 := Nat.div (Nat.mul en2 M2) S128
    let fp3 := Nat.div (Nat.mul ep3 M2) S128; let fn3 := Nat.div (Nat.mul en3 M2) S128
    |256 * (S64 : ℝ) * A2 * E ^ 2| ≤
      ((natAbsDiff (Nat.add (Nat.mul 256 fp0) (Nat.mul 128 fp2))
                   (Nat.add (Nat.mul 256 fn0) (Nat.mul 128 fn2)) : Nat) : ℝ) +
      ((natAbsDiff (Nat.add (Nat.mul 256 fp1) (Nat.mul 192 fp3))
                   (Nat.add (Nat.mul 256 fn1) (Nat.mul 192 fn3)) : Nat) : ℝ) +
      ((natAbsDiff (Nat.mul 128 fp2) (Nat.mul 128 fn2) : Nat) : ℝ) +
      ((natAbsDiff (Nat.mul 64 fp3) (Nat.mul 64 fn3) : Nat) : ℝ) + 1024 := by
  intro M2 fp0 fn0 fp1 fn1 fp2 fn2 fp3 fn3
  set S : ℝ := (S64 : ℝ)
  have hSpos : 0 < S := S64_pos
  set ζ0 : ℝ := (((Nat.mul ep0 M2 : Nat) : ℝ) / (S128 : ℝ) -
    ((Nat.mul en0 M2 : Nat) : ℝ) / (S128 : ℝ)) - ((fp0 : ℝ) - fn0)
  set ζ1 : ℝ := (((Nat.mul ep1 M2 : Nat) : ℝ) / (S128 : ℝ) -
    ((Nat.mul en1 M2 : Nat) : ℝ) / (S128 : ℝ)) - ((fp1 : ℝ) - fn1)
  set ζ2 : ℝ := (((Nat.mul ep2 M2 : Nat) : ℝ) / (S128 : ℝ) -
    ((Nat.mul en2 M2 : Nat) : ℝ) / (S128 : ℝ)) - ((fp2 : ℝ) - fn2)
  set ζ3 : ℝ := (((Nat.mul ep3 M2 : Nat) : ℝ) / (S128 : ℝ) -
    ((Nat.mul en3 M2 : Nat) : ℝ) / (S128 : ℝ)) - ((fp3 : ℝ) - fn3)
  have hζ0 := abs_div_sub_natDiv_sub_le (Nat.mul ep0 M2) (Nat.mul en0 M2) S128 S128_nat_pos
  have hζ1 := abs_div_sub_natDiv_sub_le (Nat.mul ep1 M2) (Nat.mul en1 M2) S128 S128_nat_pos
  have hζ2 := abs_div_sub_natDiv_sub_le (Nat.mul ep2 M2) (Nat.mul en2 M2) S128 S128_nat_pos
  have hζ3 := abs_div_sub_natDiv_sub_le (Nat.mul ep3 M2) (Nat.mul en3 M2) S128 S128_nat_pos
  have hM2A2_eq : 256 * ((M : ℝ) ^ 2 / S) * A2 =
      256 * (((fp0 : ℝ) - fn0) + ((fp1 : ℝ) - fn1) * t +
             ((fp2 : ℝ) - fn2) * t ^ 2 + ((fp3 : ℝ) - fn3) * t ^ 3) +
      256 * (ζ0 + ζ1 * t + ζ2 * t ^ 2 + ζ3 * t ^ 3) := by
    have hM2A2' : ((M : ℝ) ^ 2 / S) * A2 = (S * A2) * (M : ℝ) ^ 2 / (S128 : ℝ) := by
      have hS128 : (S128 : ℝ) = S ^ 2 := S128_eq_sq
      rw [hS128]; field_simp [ne_of_gt hSpos]
    rw [mul_assoc, hM2A2', hSA2]
    simp only [ζ0, ζ1, ζ2, ζ3, M2, nat_mul_eq]
    push_cast
    field_simp [ne_of_gt S128_pos]
    ring
  have hζ_sum : |256 * (ζ0 + ζ1 * t + ζ2 * t ^ 2 + ζ3 * t ^ 3)| ≤ 1024 := by
    rw [abs_mul, abs_of_pos (by norm_num : (0 : ℝ) < 256)]
    have a1 := abs_add_le (ζ0 + ζ1 * t + ζ2 * t ^ 2) (ζ3 * t ^ 3)
    have a2 := abs_add_le (ζ0 + ζ1 * t) (ζ2 * t ^ 2)
    have a3 := abs_add_le ζ0 (ζ1 * t)
    have b1 : |ζ1 * t| ≤ 1 := by
      have := abs_mul_pow_le ζ1 ht 1; rw [pow_one] at this; exact this.trans hζ1
    have b2 : |ζ2 * t ^ 2| ≤ 1 := (abs_mul_pow_le ζ2 ht 2).trans hζ2
    have b3 : |ζ3 * t ^ 3| ≤ 1 := (abs_mul_pow_le ζ3 ht 3).trans hζ3
    linarith only [a1, a2, a3, hζ0, b1, b2, b3]
  have hM2A2_bound := (abs_add_le _ _).trans
    (add_le_add (abs_cheb256_deg3_le fp0 fn0 fp1 fn1 fp2 fn2 fp3 fn3 ht) hζ_sum)
  rw [← hM2A2_eq] at hM2A2_bound
  have hA2E2_bound : |256 * S * A2 * E ^ 2| ≤ |256 * ((M : ℝ) ^ 2 / S) * A2| := by
    rw [abs_mul, abs_mul, abs_mul, abs_pow,
      abs_of_pos (by norm_num : (0 : ℝ) < 256), abs_of_pos hSpos]
    have hE2 : |E| ^ 2 ≤ ((M : ℝ) / S) ^ 2 := pow_le_pow_left₀ (abs_nonneg E) hE 2
    have h1 : 256 * S * |A2| * |E| ^ 2 ≤ 256 * S * |A2| * ((M : ℝ) / S) ^ 2 :=
      mul_le_mul_of_nonneg_left hE2 (by positivity)
    have h2 : 256 * S * |A2| * ((M : ℝ) / S) ^ 2 = 256 * ((M : ℝ) ^ 2 / S) * |A2| := by
      field_simp [ne_of_gt hSpos]
    rw [h2] at h1
    simpa [abs_mul, abs_of_pos (by norm_num : (0 : ℝ) < 256),
      abs_of_nonneg (by positivity : (0 : ℝ) ≤ (M : ℝ) ^ 2 / S)] using h1
  linarith only [hA2E2_bound, hM2A2_bound]

private theorem awayFromInt_of_checkCoeffsD3M3 {R M c0 c1 c2 c3
    p00 n00 p01 n01 p02 n02 p03 n03 p04 n04
    p05 n05 p06 n06 p07 n07 p08 n08 p09 n09
    p10 n10 p11 n11 p12 n12 p13 n13 p14 n14 p15 n15 p16 n16
    p20 n20 p21 n21 p22 n22 p23 n23 p30 n30 : Nat}
    (h : checkCoeffsD3M3 R M c0 c1 c2 c3
      p00 n00 p01 n01 p02 n02 p03 n03 p04 n04
      p05 n05 p06 n06 p07 n07 p08 n08 p09 n09
      p10 n10 p11 n11 p12 n12 p13 n13 p14 n14 p15 n15 p16 n16
      p20 n20 p21 n21 p22 n22 p23 n23 p30 n30 = true)
    (i y : ℤ) (hi : |i| ≤ R) :
    (M : ℝ) / (S64 : ℝ) <
      |(y : ℝ) - ((c0 : ℝ) + (c1 : ℝ) * i + (c2 : ℝ) * i ^ 2 + (c3 : ℝ) * i ^ 3) /
        (S64 : ℝ)| := by
  by_contra hle
  push Not at hle
  -- Extract parity and L1 inequality without zeta-expansion.
  unfold checkCoeffsD3M3 at h
  extract_lets ok0 ok1 ok2 ok3 R2 R3 R4 R5 R6 R7 R8 R9 u0 u1 u2 u3
    q0 q1 q2 q3 q4 q5 q6 s0 s1 s2 s3 s4 s5 s6 s7 s8 s9
    p01' n01' p02' n02' p03' n03' p04' n04' p05' n05'
    p06' n06' p07' n07' p08' n08' p09' n09'
    p11' n11' p12' n12' p13' n13' p14' n14' p15' n15' p16' n16'
    p21' n21' p22' n22' p23' n23'
    ap0 an0 ap1 an1 ap2 an2 ap3 an3 ap4 an4
    ap5 an5 ap6 an6 ap7 an7 ap8 an8 ap9 an9
    t0 t1 t2 t3 t4 t5 t6 t7 t8 t9
    bp0 bn0 bp1 bn1 bp2 bn2 bp3 bn3 bp4 bn4 bp5 bn5 bp6 bn6
    dp0 dn0 dp1 dn1 dp2 dn2 dp3 dn3 dp4 dn4 dp5 dn5 dp6 dn6
    w0 w1 w2 w3 w4 w5 w6
    M2 ep0 en0 ep1 en1 ep2 en2 ep3 en3 fp0 fn0 fp1 fn1 fp2 fn2 fp3 fn3
    v0 v1 v2 v3 q3Norm M3 z0 q2Norm uTot sErr slack l1 at h
  have ⟨hok0, hok1, hok2, hok3, hl1⟩ := bool_if_not_and4 h
  have hl1_nat : l1 < Nat.mul 256 S64 := nat_lt_of_blt hl1
  -- Lower bound 1 ≤ |Q(i, y)| from odd parity.
  set QZ : ℤ :=
    (((p00 : ℤ) - n00) + ((p01 : ℤ) - n01) * i + ((p02 : ℤ) - n02) * i ^ 2 +
      ((p03 : ℤ) - n03) * i ^ 3 + ((p04 : ℤ) - n04) * i ^ 4 +
      ((p05 : ℤ) - n05) * i ^ 5 + ((p06 : ℤ) - n06) * i ^ 6 +
      ((p07 : ℤ) - n07) * i ^ 7 + ((p08 : ℤ) - n08) * i ^ 8 +
      ((p09 : ℤ) - n09) * i ^ 9) +
    (((p10 : ℤ) - n10) + ((p11 : ℤ) - n11) * i + ((p12 : ℤ) - n12) * i ^ 2 +
      ((p13 : ℤ) - n13) * i ^ 3 + ((p14 : ℤ) - n14) * i ^ 4 +
      ((p15 : ℤ) - n15) * i ^ 5 + ((p16 : ℤ) - n16) * i ^ 6) * y +
    (((p20 : ℤ) - n20) + ((p21 : ℤ) - n21) * i + ((p22 : ℤ) - n22) * i ^ 2 +
      ((p23 : ℤ) - n23) * i ^ 3) * y ^ 2 +
    ((p30 : ℤ) - n30) * y ^ 3
  have hQ_ge_one : (1 : ℝ) ≤ |(QZ : ℝ)| :=
    one_le_abs_cast_of_emod_two_eq_one (parity_d3m3 hok0 hok1 hok2 hok3 i y)
  -- Express i = R * t with |t| ≤ 1 and y = P + E with |E| ≤ M / S64.
  rcases exists_unit_param R i hi with ⟨t, ht, hit⟩
  set S : ℝ := (S64 : ℝ)
  have hSpos : 0 < S := S64_pos
  have hS128_eq : (S128 : ℝ) = S ^ 2 := S128_eq_sq
  set P : ℝ := ((c0 : ℝ) + (c1 : ℝ) * (i : ℝ) + (c2 : ℝ) * (i : ℝ) ^ 2 +
    (c3 : ℝ) * (i : ℝ) ^ 3) / S
  set E : ℝ := (y : ℝ) - P
  have hE : |E| ≤ (M : ℝ) / S := hle
  have hy_eq : (y : ℝ) = P + E := by simp [E]
  -- Expand Q(R * t, P + E) = A0 + A1 * E + A2 * E^2 + Q3 * E^3.
  set Q0 : ℝ := ((p00 : ℝ) - n00) + ((p01' : ℝ) - n01') * t + ((p02' : ℝ) - n02') * t ^ 2 +
    ((p03' : ℝ) - n03') * t ^ 3 + ((p04' : ℝ) - n04') * t ^ 4 +
    ((p05' : ℝ) - n05') * t ^ 5 + ((p06' : ℝ) - n06') * t ^ 6 +
    ((p07' : ℝ) - n07') * t ^ 7 + ((p08' : ℝ) - n08') * t ^ 8 +
    ((p09' : ℝ) - n09') * t ^ 9
  set Q1 : ℝ := ((p10 : ℝ) - n10) + ((p11' : ℝ) - n11') * t + ((p12' : ℝ) - n12') * t ^ 2 +
    ((p13' : ℝ) - n13') * t ^ 3 + ((p14' : ℝ) - n14') * t ^ 4 +
    ((p15' : ℝ) - n15') * t ^ 5 + ((p16' : ℝ) - n16') * t ^ 6
  set Q2 : ℝ := ((p20 : ℝ) - n20) + ((p21' : ℝ) - n21') * t +
    ((p22' : ℝ) - n22') * t ^ 2 + ((p23' : ℝ) - n23') * t ^ 3
  set Q3 : ℝ := (p30 : ℝ) - n30
  have hQ_cast : (QZ : ℝ) = Q0 + Q1 * (P + E) + Q2 * (P + E) ^ 2 + Q3 * (P + E) ^ 3 := by
    simp only [QZ, Q0, Q1, Q2, Q3,
      p01', n01', p02', n02', p03', n03', p04', n04', p05', n05',
      p06', n06', p07', n07', p08', n08', p09', n09',
      p11', n11', p12', n12', p13', n13', p14', n14', p15', n15', p16', n16',
      p21', n21', p22', n22', p23', n23',
      R2, R3, R4, R5, R6, R7, R8, R9, nat_mul_eq]
    push_cast
    rw [hit, hy_eq]
    ring
  set A0 : ℝ := Q0 + Q1 * P + Q2 * P ^ 2 + Q3 * P ^ 3
  set A1 : ℝ := Q1 + 2 * Q2 * P + 3 * Q3 * P ^ 2
  set A2 : ℝ := Q2 + 3 * Q3 * P
  have hQ_taylor : 256 * S * (QZ : ℝ) =
      256 * S * A0 + 256 * S * A1 * E + 256 * S * A2 * E ^ 2 + 256 * S * Q3 * E ^ 3 := by
    rw [hQ_cast]; simp only [A0, A1, A2]; ring
  -- Express P, S * P^2, S * P^3 in terms of u0..u3, q0..q6, s0..s9.
  have hP_t : S * P = (u0 : ℝ) + (u1 : ℝ) * t + (u2 : ℝ) * t ^ 2 + (u3 : ℝ) * t ^ 3 := by
    simp only [P, u0, u1, u2, u3, R2, R3, nat_mul_eq]
    rw [mul_div_cancel₀ _ (ne_of_gt hSpos), hit]
    push_cast; ring
  set δ0 : ℝ := ((Nat.mul u0 u0 : Nat) : ℝ) / S - (q0 : ℝ)
  set δ1 : ℝ := ((Nat.mul 2 (Nat.mul u0 u1) : Nat) : ℝ) / S - (q1 : ℝ)
  set δ2 : ℝ := ((Nat.add (Nat.mul u1 u1) (Nat.mul 2 (Nat.mul u0 u2)) : Nat) : ℝ) / S - (q2 : ℝ)
  set δ3 : ℝ := ((Nat.mul 2 (Nat.add (Nat.mul u0 u3) (Nat.mul u1 u2)) : Nat) : ℝ) / S - (q3 : ℝ)
  set δ4 : ℝ := ((Nat.add (Nat.mul u2 u2) (Nat.mul 2 (Nat.mul u1 u3)) : Nat) : ℝ) / S - (q4 : ℝ)
  set δ5 : ℝ := ((Nat.mul 2 (Nat.mul u2 u3) : Nat) : ℝ) / S - (q5 : ℝ)
  set δ6 : ℝ := ((Nat.mul u3 u3 : Nat) : ℝ) / S - (q6 : ℝ)
  have hδ0 := div_sub_natDiv_bounds (Nat.mul u0 u0) S64 S64_nat_pos
  have hδ1 := div_sub_natDiv_bounds (Nat.mul 2 (Nat.mul u0 u1)) S64 S64_nat_pos
  have hδ2 := div_sub_natDiv_bounds
    (Nat.add (Nat.mul u1 u1) (Nat.mul 2 (Nat.mul u0 u2))) S64 S64_nat_pos
  have hδ3 := div_sub_natDiv_bounds
    (Nat.mul 2 (Nat.add (Nat.mul u0 u3) (Nat.mul u1 u2))) S64 S64_nat_pos
  have hδ4 := div_sub_natDiv_bounds
    (Nat.add (Nat.mul u2 u2) (Nat.mul 2 (Nat.mul u1 u3))) S64 S64_nat_pos
  have hδ5 := div_sub_natDiv_bounds (Nat.mul 2 (Nat.mul u2 u3)) S64 S64_nat_pos
  have hδ6 := div_sub_natDiv_bounds (Nat.mul u3 u3) S64 S64_nat_pos
  set qPoly : ℝ := (q0 : ℝ) + (q1 : ℝ) * t + (q2 : ℝ) * t ^ 2 + (q3 : ℝ) * t ^ 3 +
    (q4 : ℝ) * t ^ 4 + (q5 : ℝ) * t ^ 5 + (q6 : ℝ) * t ^ 6
  set δPoly : ℝ := δ0 + δ1 * t + δ2 * t ^ 2 + δ3 * t ^ 3 + δ4 * t ^ 4 +
    δ5 * t ^ 5 + δ6 * t ^ 6
  have hSP2 : S * P ^ 2 = qPoly + δPoly := by
    have h1 : S * P ^ 2 = (S * P) ^ 2 / S := by field_simp [ne_of_gt hSpos]
    rw [h1, hP_t]
    simp only [qPoly, δPoly, δ0, δ1, δ2, δ3, δ4, δ5, δ6, nat_add_eq, nat_mul_eq]
    push_cast
    field_simp [ne_of_gt hSpos]
    ring
  set sPoly : ℝ := (s0 : ℝ) + (s1 : ℝ) * t + (s2 : ℝ) * t ^ 2 + (s3 : ℝ) * t ^ 3 +
    (s4 : ℝ) * t ^ 4 + (s5 : ℝ) * t ^ 5 + (s6 : ℝ) * t ^ 6 + (s7 : ℝ) * t ^ 7 +
    (s8 : ℝ) * t ^ 8 + (s9 : ℝ) * t ^ 9
  set p3Err : ℝ := S * P ^ 3 - sPoly
  have hp3Err_bound : |p3Err| ≤ (sErr : ℝ) := by
    have hp3_eq : S * P ^ 3 = (qPoly + δPoly) * (S * P) / S := by
      rw [← hSP2]; field_simp [ne_of_gt hSpos]
    have hrew : p3Err =
        (((q0 : ℝ) + δ0) + ((q1 : ℝ) + δ1) * t + ((q2 : ℝ) + δ2) * t ^ 2 +
         ((q3 : ℝ) + δ3) * t ^ 3 + ((q4 : ℝ) + δ4) * t ^ 4 +
         ((q5 : ℝ) + δ5) * t ^ 5 + ((q6 : ℝ) + δ6) * t ^ 6) *
        ((u0 : ℝ) + (u1 : ℝ) * t + (u2 : ℝ) * t ^ 2 + (u3 : ℝ) * t ^ 3) / S - sPoly := by
      rw [show p3Err = S * P ^ 3 - sPoly from rfl, hp3_eq, hP_t]
      simp only [qPoly, δPoly]; ring
    rw [hrew]
    exact abs_p3_err_le u0 u1 u2 u3 q0 q1 q2 q3 q4 q5 q6 hδ0 hδ1 hδ2 hδ3 hδ4 hδ5 hδ6 ht
  have hδPoly_le : |δPoly| ≤ 7 :=
    abs_poly7_le_seven ht (abs_le_one_of_Ico hδ0) (abs_le_one_of_Ico hδ1)
      (abs_le_one_of_Ico hδ2) (abs_le_one_of_Ico hδ3) (abs_le_one_of_Ico hδ4)
      (abs_le_one_of_Ico hδ5) (abs_le_one_of_Ico hδ6)
  have hQ2_abs : |Q2| ≤ (q2Norm : ℝ) := by
    have htri : |Q2| ≤ |(p20 : ℝ) - n20| + |((p21' : ℝ) - n21') * t| +
        |((p22' : ℝ) - n22') * t ^ 2| + |((p23' : ℝ) - n23') * t ^ 3| := by
      simp only [Q2]
      have a1 := abs_add_le (((p20 : ℝ) - n20) + ((p21' : ℝ) - n21') * t +
        ((p22' : ℝ) - n22') * t ^ 2) (((p23' : ℝ) - n23') * t ^ 3)
      have a2 := abs_add_le (((p20 : ℝ) - n20) + ((p21' : ℝ) - n21') * t)
        (((p22' : ℝ) - n22') * t ^ 2)
      have a3 := abs_add_le ((p20 : ℝ) - n20) (((p21' : ℝ) - n21') * t)
      linarith only [a1, a2, a3]
    have b0 := abs_sub_cast_le_add_cast p20 n20
    have b1 : |((p21' : ℝ) - n21') * t| ≤ (p21' : ℝ) + n21' := by
      have := abs_mul_pow_le ((p21' : ℝ) - n21') ht 1
      simp only [pow_one] at this
      exact this.trans (abs_sub_cast_le_add_cast p21' n21')
    have b2 := (abs_mul_pow_le ((p22' : ℝ) - n22') ht 2).trans (abs_sub_cast_le_add_cast p22' n22')
    have b3 := (abs_mul_pow_le ((p23' : ℝ) - n23') ht 3).trans (abs_sub_cast_le_add_cast p23' n23')
    have hq2_eq : (q2Norm : ℝ) = ((p20 : ℝ) + n20) + ((p21' : ℝ) + n21') +
        ((p22' : ℝ) + n22') + ((p23' : ℝ) + n23') := by
      simp only [q2Norm, nat_add_eq, Nat.cast_add]; ring
    rw [hq2_eq]
    linarith only [htri, b0, b1, b2, b3]
  have hQ3_abs : |Q3| ≤ (q3Norm : ℝ) := by
    simpa only [Q3, q3Norm, nat_add_eq, Nat.cast_add] using abs_sub_cast_le_add_cast p30 n30
  -- Bound r = 0 term.
  have hA0_eq : 256 * S * A0 =
      256 * (((ap0 : ℝ) - an0) + ((ap1 : ℝ) - an1) * t + ((ap2 : ℝ) - an2) * t ^ 2 +
             ((ap3 : ℝ) - an3) * t ^ 3 + ((ap4 : ℝ) - an4) * t ^ 4 +
             ((ap5 : ℝ) - an5) * t ^ 5 + ((ap6 : ℝ) - an6) * t ^ 6 +
             ((ap7 : ℝ) - an7) * t ^ 7 + ((ap8 : ℝ) - an8) * t ^ 8 +
             ((ap9 : ℝ) - an9) * t ^ 9) +
      (256 * Q2 * δPoly + 256 * Q3 * p3Err) := by
    have hSA0 : S * A0 = S * Q0 + Q1 * (S * P) + Q2 * (qPoly + δPoly) + Q3 * (sPoly + p3Err) := by
      have h1 : S * P ^ 3 = sPoly + p3Err := by simp [p3Err]
      calc S * A0 = S * Q0 + Q1 * (S * P) + Q2 * (S * P ^ 2) + Q3 * (S * P ^ 3) := by
            simp only [A0]; ring
        _ = S * Q0 + Q1 * (S * P) + Q2 * (qPoly + δPoly) + Q3 * (sPoly + p3Err) := by
            rw [hSP2, h1]
    have hmain : S * Q0 + Q1 * (S * P) + Q2 * qPoly + Q3 * sPoly =
        ((ap0 : ℝ) - an0) + ((ap1 : ℝ) - an1) * t + ((ap2 : ℝ) - an2) * t ^ 2 +
        ((ap3 : ℝ) - an3) * t ^ 3 + ((ap4 : ℝ) - an4) * t ^ 4 +
        ((ap5 : ℝ) - an5) * t ^ 5 + ((ap6 : ℝ) - an6) * t ^ 6 +
        ((ap7 : ℝ) - an7) * t ^ 7 + ((ap8 : ℝ) - an8) * t ^ 8 +
        ((ap9 : ℝ) - an9) * t ^ 9 := by
      rw [hP_t]
      simp only [Q0, Q1, Q2, Q3, qPoly, sPoly,
        ap0, an0, ap1, an1, ap2, an2, ap3, an3, ap4, an4,
        ap5, an5, ap6, an6, ap7, an7, ap8, an8, ap9, an9, nat_add_eq, nat_mul_eq]
      push_cast; ring
    calc 256 * S * A0 = 256 * (S * A0) := by ring
      _ = 256 * (S * Q0 + Q1 * (S * P) + Q2 * qPoly + Q3 * sPoly) +
          (256 * Q2 * δPoly + 256 * Q3 * p3Err) := by rw [hSA0]; ring
      _ = _ := by rw [hmain]
  have hA0_err : |256 * Q2 * δPoly + 256 * Q3 * p3Err| ≤
      1792 * (q2Norm : ℝ) + 256 * ((q3Norm : ℝ) * (sErr : ℝ)) := by
    refine (abs_add_le _ _).trans (add_le_add ?_ ?_)
    · rw [abs_mul, abs_mul, abs_of_pos (by norm_num : (0 : ℝ) < 256)]
      have h1 : |Q2| * |δPoly| ≤ (q2Norm : ℝ) * 7 :=
        mul_le_mul hQ2_abs hδPoly_le (abs_nonneg _) (Nat.cast_nonneg _)
      linarith only [h1]
    · rw [abs_mul, abs_mul, abs_of_pos (by norm_num : (0 : ℝ) < 256)]
      have h1 : |Q3| * |p3Err| ≤ (q3Norm : ℝ) * (sErr : ℝ) :=
        mul_le_mul hQ3_abs hp3Err_bound (abs_nonneg _) (Nat.cast_nonneg _)
      linarith only [h1]
  have hA0_bound : |256 * S * A0| ≤
      (t0 : ℝ) + t1 + t2 + t3 + t4 + t5 + t6 + t7 + t8 + t9 +
      1792 * (q2Norm : ℝ) + 256 * ((q3Norm : ℝ) * (sErr : ℝ)) := by
    rw [hA0_eq]
    have h := (abs_add_le _ _).trans
      (add_le_add (abs_cheb256_deg9_le ap0 an0 ap1 an1 ap2 an2 ap3 an3 ap4 an4
        ap5 an5 ap6 an6 ap7 an7 ap8 an8 ap9 an9 ht) hA0_err)
    linarith only [h]
  -- Bound r = 1 term.
  set r1Div := Nat.div (Nat.mul 5376 (Nat.mul q3Norm M)) S64
  have hSA1 : S * A1 =
      (((bp0 : ℝ) - bn0) + ((bp1 : ℝ) - bn1) * t + ((bp2 : ℝ) - bn2) * t ^ 2 +
       ((bp3 : ℝ) - bn3) * t ^ 3 + ((bp4 : ℝ) - bn4) * t ^ 4 +
       ((bp5 : ℝ) - bn5) * t ^ 5 + ((bp6 : ℝ) - bn6) * t ^ 6) + 3 * Q3 * δPoly := by
    have h1 : S * A1 = S * Q1 + 2 * Q2 * (S * P) + 3 * Q3 * (S * P ^ 2) := by
      simp only [A1]; ring
    rw [h1, hP_t, hSP2]
    simp only [Q1, Q2, Q3, qPoly,
      bp0, bn0, bp1, bn1, bp2, bn2, bp3, bn3, bp4, bn4, bp5, bn5, bp6, bn6,
      nat_add_eq, nat_mul_eq]
    push_cast; ring
  have hA1E_bound : |256 * S * A1 * E| ≤
      (w0 : ℝ) + w1 + w2 + w3 + w4 + w5 + w6 + 1793 + (r1Div : ℝ) :=
    d3m3_r1_bound M bp0 bn0 bp1 bn1 bp2 bn2 bp3 bn3 bp4 bn4 bp5 bn5 bp6 bn6 q3Norm
      ht hE hQ3_abs hδPoly_le hSA1
  -- Bound r = 2 term.
  have hSA2 : S * A2 = ((ep0 : ℝ) - en0) + ((ep1 : ℝ) - en1) * t +
      ((ep2 : ℝ) - en2) * t ^ 2 + ((ep3 : ℝ) - en3) * t ^ 3 := by
    have h1 : S * A2 = S * Q2 + 3 * Q3 * (S * P) := by simp only [A2]; ring
    rw [h1, hP_t]
    simp only [Q2, Q3, ep0, en0, ep1, en1, ep2, en2, ep3, en3, nat_add_eq, nat_mul_eq]
    push_cast; ring
  have hA2E2_bound : |256 * S * A2 * E ^ 2| ≤ (v0 : ℝ) + v1 + v2 + v3 + 1024 :=
    d3m3_r2_bound M ep0 en0 ep1 en1 ep2 en2 ep3 en3 ht hE hSA2
  -- Bound r = 3 term.
  have hA3_bound : |256 * S * Q3 * E ^ 3| ≤ (z0 : ℝ) := by
    rw [abs_mul, abs_mul, abs_mul, abs_pow,
      abs_of_pos (by norm_num : (0 : ℝ) < 256), abs_of_pos hSpos]
    have hE3 : |E| ^ 3 ≤ ((M : ℝ) / S) ^ 3 := pow_le_pow_left₀ (abs_nonneg E) hE 3
    have h1 : 256 * S * |Q3| * |E| ^ 3 ≤ 256 * S * (q3Norm : ℝ) * ((M : ℝ) / S) ^ 3 := by
      have h1a : 256 * S * |Q3| ≤ 256 * S * (q3Norm : ℝ) :=
        mul_le_mul_of_nonneg_left hQ3_abs (by positivity)
      exact mul_le_mul h1a hE3 (by positivity) (by positivity)
    have h2 : 256 * S * (q3Norm : ℝ) * ((M : ℝ) / S) ^ 3 =
        ((Nat.mul 256 (Nat.mul q3Norm M3) : Nat) : ℝ) / (S128 : ℝ) := by
      rw [hS128_eq]; simp only [M3, M2, nat_mul_eq]; push_cast; field_simp [ne_of_gt hSpos]
    have h3 := div_lt_natDiv_add_one (Nat.mul 256 (Nat.mul q3Norm M3)) S128 S128_nat_pos
    have h4 : ((Nat.div (Nat.mul 256 (Nat.mul q3Norm M3)) S128 : Nat) : ℝ) + 1 = (z0 : ℝ) := by
      simp only [z0, nat_add_eq]; push_cast; ring
    linarith only [h1, h2, h3, h4]
  -- Combine r = 0, 1, 2, 3 bounds and compare with 256 * S.
  have hl1_real : 2817 + 1792 * (q2Norm : ℝ) + 256 * ((q3Norm : ℝ) * (sErr : ℝ)) + (r1Div : ℝ) +
      ((t0 : ℝ) + t1 + t2 + t3 + t4 + t5 + t6 + t7 + t8 + t9 +
       w0 + w1 + w2 + w3 + w4 + w5 + w6 + v0 + v1 + v2 + v3 + z0) < 256 * S := by
    have hcast : (l1 : ℝ) < ((Nat.mul 256 S64 : Nat) : ℝ) := (Nat.cast_lt (α := ℝ)).mpr hl1_nat
    have hl1_eq : (l1 : ℝ) = 2817 + 1792 * (q2Norm : ℝ) + 256 * ((q3Norm : ℝ) * (sErr : ℝ)) +
        (r1Div : ℝ) + ((t0 : ℝ) + t1 + t2 + t3 + t4 + t5 + t6 + t7 + t8 + t9 +
         w0 + w1 + w2 + w3 + w4 + w5 + w6 + v0 + v1 + v2 + v3 + z0) := by
      simp only [l1, slack, r1Div, nat_add_eq, nat_mul_eq, Nat.cast_add, Nat.cast_mul,
        Nat.cast_ofNat]
      ring
    have hrhs_eq : ((Nat.mul 256 S64 : Nat) : ℝ) = 256 * S := by
      simp only [S, nat_mul_eq, Nat.cast_mul, Nat.cast_ofNat]
    linarith only [hcast, hl1_eq, hrhs_eq]
  have hQ_tri : |256 * S * (QZ : ℝ)| ≤
      |256 * S * A0| + |256 * S * A1 * E| + |256 * S * A2 * E ^ 2| + |256 * S * Q3 * E ^ 3| := by
    rw [hQ_taylor]
    have a1 := abs_add_le (256 * S * A0 + 256 * S * A1 * E + 256 * S * A2 * E ^ 2)
      (256 * S * Q3 * E ^ 3)
    have a2 := abs_add_le (256 * S * A0 + 256 * S * A1 * E) (256 * S * A2 * E ^ 2)
    have a3 := abs_add_le (256 * S * A0) (256 * S * A1 * E)
    linarith only [a1, a2, a3]
  have hQ_lt : |256 * S * (QZ : ℝ)| < 256 * S := by
    linarith only [hl1_real, hQ_tri, hA0_bound, hA1E_bound, hA2E2_bound, hA3_bound]
  have hQ_eq : |256 * S * (QZ : ℝ)| = 256 * S * |(QZ : ℝ)| := by
    rw [abs_mul, abs_of_pos (by positivity : (0 : ℝ) < 256 * S)]
  rw [hQ_eq] at hQ_lt
  have hQ_ge : 256 * S * (1 : ℝ) ≤ 256 * S * |(QZ : ℝ)| :=
    mul_le_mul_of_nonneg_left hQ_ge_one (by positivity)
  linarith only [hQ_lt, hQ_ge]

/-- Soundness of `checkPackedD3M3` with `(S64 : ℝ)` as denominator (avoids Lean's `npowRec`
recursion-depth blowup when unifying `(2 ^ 64 : ℝ)` under `<`). -/
theorem awayFromInt_of_checkPackedD3M3_S64 {R M c0 c1 c2 c3 packedQ : Nat}
    (h : checkPackedD3M3 R M c0 c1 c2 c3 packedQ = true)
    (i y : ℤ) (hi : |i| ≤ R) :
    (M : ℝ) / (S64 : ℝ) <
      |(y : ℝ) - ((c0 : ℝ) + (c1 : ℝ) * i + (c2 : ℝ) * i ^ 2 + (c3 : ℝ) * i ^ 3) /
        (S64 : ℝ)| := by
  unfold checkPackedD3M3 at h
  extract_lets u00 q0 u01 q1 u02 q2 u03 q3 u04 q4 u05 q5 u06 q6 u07 q7 u08 q8 u09 q9
    u10 q10 u11 q11 u12 q12 u13 q13 u14 q14 u15 q15 u16 q16
    u20 q17 u21 q18 u22 q19 u23 q20 u30 at h
  exact @awayFromInt_of_checkCoeffsD3M3 R M c0 c1 c2 c3
    u00.1 u00.2 u01.1 u01.2 u02.1 u02.2 u03.1 u03.2 u04.1 u04.2
    u05.1 u05.2 u06.1 u06.2 u07.1 u07.2 u08.1 u08.2 u09.1 u09.2
    u10.1 u10.2 u11.1 u11.2 u12.1 u12.2 u13.1 u13.2 u14.1 u14.2 u15.1 u15.2 u16.1 u16.2
    u20.1 u20.2 u21.1 u21.2 u22.1 u22.2 u23.1 u23.2 u30.1 u30.2 h i y hi

/-- Soundness of `checkPackedD3M3`: if the certificate verifies, then every integer `y`
stays strictly farther than `M / 2 ^ 64` from the degree-3 polynomial approximation at every
integer `i` with `|i| ≤ R`. -/
theorem awayFromInt_of_checkPackedD3M3 {R M c0 c1 c2 c3 packedQ : Nat}
    (h : checkPackedD3M3 R M c0 c1 c2 c3 packedQ = true)
    (i y : ℤ) (hi : |i| ≤ R) :
    (M : ℝ) / (2 ^ 64 : ℝ) <
      |(y : ℝ) - ((c0 : ℝ) + (c1 : ℝ) * i + (c2 : ℝ) * i ^ 2 + (c3 : ℝ) * i ^ 3) /
        (2 ^ 64 : ℝ)| := by
  rw [← S64_eq]
  exact awayFromInt_of_checkPackedD3M3_S64 h i y hi

/-! ### Axiom checks -/

/--
info: 'LibcMath.Extracted.Expf.Tmd.ChebCert.awayFromInt_of_checkPackedD2M2' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms awayFromInt_of_checkPackedD2M2

/--
info: 'LibcMath.Extracted.Expf.Tmd.ChebCert.awayFromInt_of_checkPackedD3M3' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms awayFromInt_of_checkPackedD3M3

end LibcMath.Extracted.Expf.Tmd.ChebCert
