import LibcMath.Kernels.Frexpf.Statement

/-!
# `frexpf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Frexpf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Frexpf.Generated

/-- **Open.** Prove `frexpf` (`sse42`) executes without C++ undefined behavior. -/
theorem frexpfSse42_defined : FrexpfSse42Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Frexpf.Proof.Sse42.frexpfSse42_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms frexpfSse42_defined

end LibcMath.Kernels.Frexpf.Proof.Sse42
