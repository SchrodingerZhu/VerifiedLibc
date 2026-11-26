import LibcMath.Kernels.Modff.Statement

/-!
# `modff` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Modff.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Modff.Generated

/-- **Open.** Prove `modff` (`sse42`) executes without C++ undefined behavior. -/
theorem modffSse42_defined : ModffSse42Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Modff.Proof.Sse42.modffSse42_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms modffSse42_defined

end LibcMath.Kernels.Modff.Proof.Sse42
