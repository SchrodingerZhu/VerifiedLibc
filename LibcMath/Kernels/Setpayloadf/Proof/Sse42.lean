import LibcMath.Kernels.Setpayloadf.Statement

/-!
# `setpayloadf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Setpayloadf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Setpayloadf.Generated

/-- **Open.** Prove `setpayloadf` (`sse42`) executes without C++ undefined behavior. -/
theorem setpayloadfSse42_defined : SetpayloadfSse42Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Setpayloadf.Proof.Sse42.setpayloadfSse42_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms setpayloadfSse42_defined

end LibcMath.Kernels.Setpayloadf.Proof.Sse42
