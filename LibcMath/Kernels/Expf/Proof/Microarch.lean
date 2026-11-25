import LibcMath.Kernels.Expf.Statement

/-!
# Open correctness theorems for `expf` SSE4.2 and AArch64 microarch plans

Records the explicit open obligations for the SSE4.2 (`-msse4.2 -mno-fma`) and AArch64
(`--target=aarch64-none-elf`) extractions of `math::double_eval::expf`.
-/

namespace LibcMath.Kernels.Expf.Proof.Microarch

/-- **Open.** Prove that `math::double_eval::expf` compiled with `-msse4.2 -mno-fma` is correctly
rounded across all four IEEE rounding modes. -/
theorem expfDoubleEvalSse42_correctlyRounded : ExpfDoubleEvalSse42CorrectlyRounded := by
  sorry

/-- **Open.** Prove that `math::double_eval::expf` compiled for AArch64 is correctly rounded across
all four IEEE rounding modes. -/
theorem expfDoubleEvalAArch64_correctlyRounded : ExpfDoubleEvalAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Expf.Proof.Microarch.expfDoubleEvalSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms expfDoubleEvalSse42_correctlyRounded

/--
info: 'LibcMath.Kernels.Expf.Proof.Microarch.expfDoubleEvalAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms expfDoubleEvalAArch64_correctlyRounded

end LibcMath.Kernels.Expf.Proof.Microarch
