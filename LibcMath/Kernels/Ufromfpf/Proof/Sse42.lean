import LibcMath.Kernels.Ufromfpf.Statement

/-!
# `ufromfpf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Ufromfpf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Ufromfpf.Generated

/-- **Open.** Prove `ufromfpf` (`sse42`) executes without C++ undefined behavior. -/
theorem ufromfpfSse42_defined : UfromfpfSse42Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Ufromfpf.Proof.Sse42.ufromfpfSse42_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms ufromfpfSse42_defined

end LibcMath.Kernels.Ufromfpf.Proof.Sse42
