import LibcMath.Framework.Spec
import LibcMath.Kernels.Ufromfpf.Generated.GenericSse2

/-!
# Extracted `ufromfpf` generic SSE2 plan

Collects the extracted LLVM libc `ufromfpf` (`generic_sse2`) plan and states its obligation.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Ufromfpf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Ufromfpf.Generated

/-- Definedness (no C++ undefined behavior) of `ufromfpf` (`generic_sse2`). -/
def UfromfpfGenericSse2Defined : Prop :=
  ∀ m ∈ cModes, ∀ (x : Model .binary32) (r w : BitVec 32), (GenericSse2.ufromfpf m x r w).isSome

/-- **Open.** Prove `ufromfpf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem ufromfpfGenericSse2_defined : UfromfpfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Ufromfpf.ufromfpfGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms ufromfpfGenericSse2_defined

end LibcMath.Kernels.Ufromfpf
