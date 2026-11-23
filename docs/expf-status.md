# Status of the proof that `expf` is correctly rounded

This note records what is proved about LLVM libc's binary32 `expf`, what the proof rests on, and
what is left. It describes the state of the branch `swarm/integration` on 2026-11-23.

## The statement

`LibcMath.Extracted.ExpfCorrectlyRounded` (`LibcMath/Extracted/Statements.lean`) says that for
every binary32 bit pattern `x` and each of the four rounding directions of C:

1. some execution of the extracted function returns;
2. every execution that returns gives `round(exp(x))` in that direction, where all NaNs count as
   the same value, and the results at NaN, zeros and infinities are those of ISO C23 Annex F;
3. no execution reaches an undefined operation (a violated `nsw`, `samesign` or `nneg` flag, an
   out-of-range conversion, a table access out of bounds).

The extracted function is `LibcMath/Extracted/Expf.lean`, produced by `extract/extract.sh` from
`math::double_eval::expf` of llvm-project f0e7941beee3, compiled by clang 23.1.3 at `-O3` for
x86-64 without FMA, in libc's default configuration.

## What is proved

`expfCorrectlyRounded_of_mainRanges` (`LibcMath/Extracted/ExpfMain.lean`): the statement above
holds, provided that for each of the four directions the interpreter returns the correctly rounded
value on the bit patterns in

| range | arguments | count |
|---|---|---|
| `0x32800001`–`0x42B1FFFF` | 2^-26 < x < 89 | 271 712 255 |
| `0xB2800001`–`0xC2CFF1B4` | -103.97 < x < -2^-26 | 273 674 676 |

These are the arguments on which `expf` evaluates its polynomial: 12.7% of all bit patterns. The
theorem depends on no axiom beyond `propext`, `Classical.choice` and `Quot.sound`, and on no
`sorry`, `native_decide` or `bv_decide`. It is assembled from:

- `LibcMath/IR/Semantics.lean`: the meaning of extracted code, including which executions go
  wrong.
- `LibcMath/IR/Interp.lean`: an executable interpreter; when it answers, its answer is a result
  of the function, every other result agrees with it up to the identity of NaNs, and no execution
  goes wrong.
- `LibcMath/Extracted/ExpfPaths/`: the other 87.3% of bit patterns (tiny arguments, overflow,
  underflow, NaNs, infinities, zeros), proved for whole ranges by symbolic execution of the
  interpreter, using the closed forms of the specification in `LibcMath/Functions/ExpRanges.lean`.
- `LibcMath/Exhaustive/`: how statements about ranges of bit patterns combine.

Also proved, and needed for the remaining step: `expOracle` (`LibcMath/Oracle/Exp.lean`), a test
for "this is the correctly rounded exponential" that is sound for every format and rounding
direction, and complete on finite nonzero arguments.

## What is left

The hypothesis of `expfCorrectlyRounded_of_mainRanges` is a finite computation: on each of
545 386 931 bit patterns and in each direction, run the interpreter and the oracle and observe
`true`. `scripts/exhaustive.py` splits it into blocks and turns blocks into Lean theorems of the
form `Run.CheckedOn mode lo hi`, which join into the hypothesis (README, "Exhaustive checking").
Measured costs on one thread of a 2025 desktop processor:

| how a block is established | rests on | per argument | main ranges, four directions |
|---|---|---|---|
| compiled `checkrange` | nothing: a report, not a proof | 30–80 µs | about 40 CPU-hours |
| `native_decide` | the Lean compiler | 0.4–0.5 ms | about 280 CPU-hours |
| `decide +kernel` | the kernel only | 0.35–0.5 s | 2–3 × 10^5 CPU-hours |

The compiled pass has been run (`scripts/manifests/expf-main.tsv`, blocks of 65 536 arguments):

| direction | arguments checked | failures |
|---|---|---|
| nearest | 545 386 931 of 545 386 931 | 0 |
| up | 545 386 931 of 545 386 931 | 0 |
| down | 545 386 931 of 545 386 931 | 0 |
| towardZero | 493 416 883 of 545 386 931 | 0 |

The 793 blocks still marked `pending` in that manifest are all for `towardZero`; `exhaustive.py run`
resumes from it. This pass is evidence that the remaining hypothesis is true. It is not a proof:
the Lean certificates for these blocks have not been generated.

The kernel cost is dominated by the generic interpreter (the oracle takes about 8 ms). The draft
pull request "structured form" replaces the interpreter on these ranges by a direct Lean function,
`expfMain`, which the kernel evaluates 3–4 times faster; its equality with the interpreter is
proved except for one lemma about blocks 15–21, whose proof script elaborates but whose kernel
check did not finish. Completing that lemma, and then making FloatLib's operations cheaper for
the kernel, is the route to a proof that trusts nothing beyond the kernel.

## What the theorem rests on

Beyond Lean's kernel and the three axioms above:

- **The specification.** `Spec.exp` (`LibcMath/Functions.lean`) and FloatLib's definitions of the
  formats and of `Model.roundReal`.
- **The meaning given to LLVM IR**, stated in the module docstring of `Semantics.lean`: plain
  floating-point instructions round in the dynamic rounding direction as FloatLib's operations
  do; `llvm.fmuladd` is a multiplication followed by an addition; the rounding-mode queries of
  libc return the direction in effect; reporting through `errno` and the status flags does not
  change results.
- **The extraction.** clang with the `MarkCoreOps` plugin, the `ir2lean` exporter, and the
  `llvm_func` notation.
- **The compiler back end and the processor**, for the step from IR to machine code.

`scripts/difftest-expf.sh` tests the second and third items against the machine: the interpreter
and the compiled `expf` (with and without the plugin) agree on every argument compared, in all
four directions — about 94 million arguments per direction, including the complete binade [1, 2)
and every seventh bit pattern of the main ranges.

## Beyond `expf`

After the fragment was widened, 73 entrypoints of libc export (`docs/extraction-coverage.md`
describes the survey and the missing pieces), among them `cospif`, `sinpif`, `expm1f`, `log2f`,
`sqrtf`, `asinf`, `atanhf`, `coshf`, `sinhf` and 23 half-precision functions. Each unary one can
follow the route taken here once it has a `Spec` and an oracle. Functions of two arguments and
double precision have too many inputs for this route and need another.
