import LibcMath.Kernels.Ilogbf.Statement

/-!
# `ilogbf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Ilogbf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Ilogbf.Generated

/-- **Open.** Prove `ilogbf` (`sse42`) executes without C++ undefined behavior. -/
theorem ilogbfSse42_defined : IlogbfSse42Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Ilogbf.Proof.Sse42.ilogbfSse42_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms ilogbfSse42_defined

end LibcMath.Kernels.Ilogbf.Proof.Sse42
