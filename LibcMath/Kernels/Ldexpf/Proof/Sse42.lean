import LibcMath.Kernels.Ldexpf.Statement

/-!
# `ldexpf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Ldexpf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Ldexpf.Generated

/-- **Open.** Prove `ldexpf` (`sse42`) executes without C++ undefined behavior. -/
theorem ldexpfSse42_defined : LdexpfSse42Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Ldexpf.Proof.Sse42.ldexpfSse42_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms ldexpfSse42_defined

end LibcMath.Kernels.Ldexpf.Proof.Sse42
