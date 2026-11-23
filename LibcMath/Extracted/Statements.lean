import LibcMath.Extracted.Expf
import LibcMath.Functions
import LibcMath.IR.Semantics

/-!
# Statements about extracted functions
-/

namespace LibcMath.Extracted

/-- The claim LLVM libc makes for `expf`: correct rounding under all four rounding directions.
Not yet proved. -/
def ExpfCorrectlyRounded : Prop :=
  expf.CorrectlyRounded (Spec.exp .binary32) cModes

end LibcMath.Extracted
