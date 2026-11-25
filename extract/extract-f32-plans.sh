#!/usr/bin/env bash
# Extract LLVM libc binary32 evaluation and microarch plans at commit e1a5f92db023.
#
#   extract/extract-f32-plans.sh <llvm-project>/libc [family|all]
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
exec python3 "$root/extract/extract_f32_plans.py" "$@"
