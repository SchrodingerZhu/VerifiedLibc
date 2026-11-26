import LibcMath.Kernels.Fromfpf.Statement

/-!
# `fromfpf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fromfpf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Fromfpf.Generated

/-- **Open.** Prove `fromfpf` (`sse42`) executes without C++ undefined behavior. -/
theorem fromfpfSse42_defined : FromfpfSse42Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Fromfpf.Proof.Sse42.fromfpfSse42_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fromfpfSse42_defined

end LibcMath.Kernels.Fromfpf.Proof.Sse42
