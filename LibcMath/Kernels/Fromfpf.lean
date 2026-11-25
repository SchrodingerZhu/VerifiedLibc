import LibcMath.Framework.Spec
import LibcMath.Kernels.Fromfpf.Generated.GenericSse2

/-!
# Extracted `fromfpf` generic SSE2 plan

Collects the extracted LLVM libc `fromfpf` (`generic_sse2`) plan and states its obligation.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Fromfpf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Fromfpf.Generated

/-- Definedness (no C++ undefined behavior) of `fromfpf` (`generic_sse2`). -/
def FromfpfGenericSse2Defined : Prop :=
  ∀ (x : Model .binary32) (r w : BitVec 32), (GenericSse2.fromfpf x r w).isSome

/-- **Open.** Prove `fromfpf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem fromfpfGenericSse2_defined : FromfpfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Fromfpf.fromfpfGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fromfpfGenericSse2_defined

end LibcMath.Kernels.Fromfpf
