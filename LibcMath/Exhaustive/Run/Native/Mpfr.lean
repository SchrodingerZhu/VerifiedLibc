import LibcMath.Exhaustive.Run.Block
import LibcMath.Exhaustive.Run.Target
import LibcMath.Oracle.Mpfr

/-!
# Blocks checked against MPFR by compiled code

A block certificate with the oracle that trusts MPFR, and a comparison of that oracle with the
one proved in Lean. Both are proved by `native_decide`, which runs the C code of
`c/mpfr_oracle.c`.

`checkRange mpfrExpOracle impl mode first count = true` is the form in which a range that is
checked against MPFR enters `HoldsOnBits` (`holdsOnBits_of_checkRange`). Such a theorem depends on
`MpfrOracle.mpfrExpf_sameValue` and on the Lean compiler. The last check of this file shows both:
the first by name, and the second as the axiom that `native_decide` adds for the block.
-/

namespace LibcMath.Exhaustive.Run.Native.Mpfr

open LibcMath
open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

/-- `Expf.DoubleEval.expf` agrees with MPFR on the 4096 inputs from `1`, rounding to nearest. -/
theorem block_nearest_0x3f800000_4096 :
    checkRange mpfrExpOracle run .nearest 0x3f800000 4096 = true :=
  checkRange_of_checkBlock (by native_decide)

/-- The same block rounding upward. -/
theorem block_up_0x3f800000_4096 :
    checkRange mpfrExpOracle run .up 0x3f800000 4096 = true :=
  checkRange_of_checkBlock (by native_decide)

theorem checked_nearest_0x3f800000_0x3f801000 : CheckedOn .nearest 0x3f800000 0x3f801000 :=
  holdsOnBits_of_checkRange block_nearest_0x3f800000_4096

/-! ### MPFR against the oracle proved in Lean

On a block, the result MPFR computes is accepted by `expOracle`, whose soundness is a theorem. A
disagreement between the shim and the specification on these inputs would make this fail. -/

/-- The result of MPFR is accepted by the proved oracle on `count` inputs from `first`. -/
def mpfrAccepted (mode : IEEERoundingMode) (code : UInt8) (first count : ℕ) : Bool :=
  checkBits (fmt := .binary32)
    (fun input => oracle.check mode input (MpfrOracle.expf code input)) first count

example : mpfrAccepted .nearest 0 0x3f800000 512 = true := by native_decide
example : mpfrAccepted .towardZero 1 0x3f800000 512 = true := by native_decide
example : mpfrAccepted .up 2 0xc2ce8ed0 512 = true := by native_decide
example : mpfrAccepted .down 3 0x42b17000 512 = true := by native_decide

/--
info: 'LibcMath.Exhaustive.Run.Native.Mpfr.checked_nearest_0x3f800000_0x3f801000' depends on axioms: [propext,
 Classical.choice,
 Quot.sound,
 MpfrOracle.mpfrExpf_sameValue,
 block_nearest_0x3f800000_4096._native.native_decide.ax_1_1]
-/
#guard_msgs in
#print axioms checked_nearest_0x3f800000_0x3f801000

end LibcMath.Exhaustive.Run.Native.Mpfr
