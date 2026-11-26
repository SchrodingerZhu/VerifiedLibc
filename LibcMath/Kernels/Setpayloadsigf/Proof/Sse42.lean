import LibcMath.Kernels.Setpayloadsigf.Statement

/-!
# `setpayloadsigf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Setpayloadsigf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Setpayloadsigf.Generated

/-- **Open.** Prove `setpayloadsigf` (`sse42`) executes without C++ undefined behavior. -/
theorem setpayloadsigfSse42_defined : SetpayloadsigfSse42Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Setpayloadsigf.Proof.Sse42.setpayloadsigfSse42_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms setpayloadsigfSse42_defined

end LibcMath.Kernels.Setpayloadsigf.Proof.Sse42
