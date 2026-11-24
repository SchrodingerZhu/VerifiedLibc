#!/usr/bin/env bash
# Regenerate all extracted `expf` evaluation plans under `LibcMath/Expf/Generated/`.
#
#   extract/extract-expf-plans.sh <llvm-project>/libc
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <llvm-project>/libc" >&2
  exit 1
fi

libc=$1
root=$(cd "$(dirname "$0")/.." && pwd)
out="$root/LibcMath/Expf/Generated"
mkdir -p "$out"

"$root/extract/extract.sh" "$libc" expf math::double_eval::expf expf \
  --namespace=LibcMath.Expf.Generated.DoubleEval \
  --out="$out/DoubleEval.lean"

"$root/extract/extract.sh" "$libc" expf math::double_eval::expf expf \
  --namespace=LibcMath.Expf.Generated.DoubleEvalFma \
  --variant=double_eval_fma \
  --out="$out/DoubleEvalFma.lean" \
  -- -mavx2 -mfma

"$root/extract/extract.sh" "$libc" expf math::integer_eval::expf expf \
  --namespace=LibcMath.Expf.Generated.IntegerEval \
  --out="$out/IntegerEval.lean" \
  -- -DLIBC_MATH_EXPF_IMPL=integer_eval -DLIBC_MATH=0x2C

"$root/extract/extract.sh" "$libc" expf math::static_rounding::expf expf \
  --namespace=LibcMath.Expf.Generated.StaticRounding \
  --out="$out/StaticRounding.lean" \
  -- -DLIBC_MATH_EXPF_IMPL=integer_eval -DLIBC_MATH=0x0C

"$root/extract/extract.sh" "$libc" expf math::float_eval::expf expf \
  --namespace=LibcMath.Expf.Generated.FloatEval \
  --out="$out/FloatEval.lean" \
  -- -mavx2 -mfma -DLIBC_MATH_EXPF_IMPL=float_eval -DLIBC_MATH=0x3F

"$root/extract/extract.sh" "$libc" expf math::float_eval_cr_rn::expf expf \
  --namespace=LibcMath.Expf.Generated.FloatEvalCrRn \
  --out="$out/FloatEvalCrRn.lean" \
  -- -mavx2 -mfma -DLIBC_MATH_EXPF_IMPL=float_eval_cr_rn -DLIBC_MATH=0x3E

echo "Extracted all 6 expf evaluation plans into $out."
