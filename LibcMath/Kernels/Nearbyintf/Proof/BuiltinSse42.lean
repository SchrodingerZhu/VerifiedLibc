import LibcMath.Kernels.Nearbyintf.Statement

/-!
# `nearbyintf` (`builtin_sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Nearbyintf.Proof.BuiltinSse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Nearbyintf.Generated

/-- **Open.** Prove `nearbyintf` (`builtin_sse42`) is correctly rounded in all four C modes. -/
theorem nearbyintfBuiltinSse42_correctlyRounded : NearbyintfBuiltinSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Nearbyintf.Proof.BuiltinSse42.nearbyintfBuiltinSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms nearbyintfBuiltinSse42_correctlyRounded

end LibcMath.Kernels.Nearbyintf.Proof.BuiltinSse42
