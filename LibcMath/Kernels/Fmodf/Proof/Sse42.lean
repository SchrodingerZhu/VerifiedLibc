import LibcMath.Kernels.Fmodf.Statement

/-!
# `fmodf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fmodf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Fmodf.Generated

/-- **Open.** Prove `fmodf` (`sse42`) executes without C++ undefined behavior. -/
theorem fmodfSse42_defined : FmodfSse42Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Fmodf.Proof.Sse42.fmodfSse42_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmodfSse42_defined

end LibcMath.Kernels.Fmodf.Proof.Sse42
