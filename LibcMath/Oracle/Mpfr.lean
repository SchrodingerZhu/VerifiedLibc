import LibcMath.Check.Oracle
import LibcMath.Functions
import LibcMath.SpecLemmas
import LibcMathMpfr.Basic

/-!
# An oracle for the binary32 exponential that trusts MPFR

`mpfrExpOracle` accepts a result when it has the value that MPFR computes for the correctly
rounded exponential. MPFR runs as compiled C code (`c/mpfr_oracle.c`), so a check against this
oracle is fast, and it can only be evaluated by compiled code: by the `checkrange` executable, or
inside Lean by `native_decide`.

## What is trusted

Lean cannot see what the C function computes. The axiom `mpfrExpf_sameValue` states it: the
function returns the result that `Spec.exp` prescribes, in each of the four rounding directions of
C. Every theorem that uses this oracle depends on that axiom, and `#print axioms` shows it by
name. The axiom stands for:

* MPFR's `mpfr_exp`, `mpfr_subnormalize` and conversions being correct;
* the shim `c/mpfr_oracle.c` using them as the MPFR manual prescribes for emulating binary32;
* the C compiler, and the hardware it runs on.

A proof by `native_decide` also depends on the Lean compiler, as with any oracle.

The oracle `expOracle` of `LibcMath/Oracle/Exp.lean` needs none of this, and is the one to use
where a result must rest on Lean alone. `LibcMath/Oracle/MpfrExamples.lean` compares the two.
-/

namespace LibcMath

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

namespace MpfrOracle

/-- The code of a rounding direction of C in `c/mpfr_oracle.c`. -/
def modeCode : IEEERoundingMode → Option UInt8
  | .nearest => some 0
  | .towardZero => some 1
  | .up => some 2
  | .down => some 3
  | _ => none

/-- The correctly rounded binary32 exponential as MPFR computes it. -/
def expf (code : UInt8) (x : Model .binary32) : Model .binary32 :=
  .ofNatBits (LibcMathMpfr.expfBits code (UInt32.ofNat x.toNatBits)).toNat

/-- **Trusted.** MPFR, through `c/mpfr_oracle.c`, returns the correctly rounded binary32
exponential in each rounding direction of C. See the module docstring for what this covers. -/
axiom mpfrExpf_sameValue {mode : IEEERoundingMode} {code : UInt8} (h : modeCode mode = some code)
    (x : Model .binary32) : SameValue (expf code x) ((Spec.exp .binary32).eval mode x)

/-- Whether `result` has the value MPFR computes. `false` for a direction that C does not have. -/
def check (mode : IEEERoundingMode) (input result : Model .binary32) : Bool :=
  match modeCode mode with
  | some code => decide (SameValue result (expf code input))
  | none => false

end MpfrOracle

/-- An oracle for the binary32 exponential that trusts MPFR (`MpfrOracle.mpfrExpf_sameValue`). -/
def mpfrExpOracle : Oracle (Spec.exp .binary32) where
  check := MpfrOracle.check
  sound mode input result h := by
    unfold MpfrOracle.check at h
    split at h
    · rename_i code hcode
      exact (of_decide_eq_true h).trans (MpfrOracle.mpfrExpf_sameValue hcode input)
    · exact absurd h (by simp)

end LibcMath
