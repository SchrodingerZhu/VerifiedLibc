import LibcMath.Testing.Block
import LibcMath.Testing.Target
import LibcMath.Testing.Oracle.Mpfr

/-!
# Tests of the oracle that trusts MPFR

Two tests, run by compiled code with `native_decide` when this file is built:

* on a few blocks, the result that MPFR computes is accepted by `expOracle`, whose soundness is a
  theorem. A disagreement between `c/mpfr_oracle.c` and the specification on these inputs would
  make the build fail;
* on one block, `Expf.Generated.DoubleEval.expf` has a result that the MPFR oracle accepts.

These are tests of the tools. They are not part of the proof that `expf` is correctly rounded.
-/

namespace LibcMath.Testing.MpfrExamples

open LibcMath
open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

/-- The result of MPFR is accepted by the proved oracle on `count` inputs from `first`. -/
def mpfrAccepted (mode : IEEERoundingMode) (code : UInt8) (first count : ℕ) : Bool :=
  checkBits (fmt := .binary32)
    (fun input => oracle.check mode input (MpfrOracle.expf code input)) first count

example : mpfrAccepted .nearest 0 0x3f800000 512 = true := by native_decide
example : mpfrAccepted .towardZero 1 0x3f800000 512 = true := by native_decide
example : mpfrAccepted .up 2 0xc2ce8ed0 512 = true := by native_decide
example : mpfrAccepted .down 3 0x42b17000 512 = true := by native_decide

example :
    checkBlock mpfrExpOracle.check Expf.Generated.DoubleEval.expf .nearest 0x3f800000 512 = true :=
  by native_decide

example :
    checkBlock mpfrExpOracle.check Expf.Generated.DoubleEval.expf .up 0x3f800000 512 = true :=
  by native_decide

end LibcMath.Testing.MpfrExamples
