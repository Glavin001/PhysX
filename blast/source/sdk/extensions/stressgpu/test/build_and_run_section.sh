#!/bin/bash
# Build and run the real-section bending test (host only, no GPU).
#   SECTION_TEST_LEGACY=1 ./build_and_run_section.sh   grades the capped formula
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
blast="$(cd "$here/../../../../.." && pwd)"
out="${TMPDIR:-/tmp}/blast_section_bending_test"
"${CXX:-c++}" -std=c++17 -O2 -I"$blast/include/extensions/stress" "$here/section_bending_test.cpp" -o "$out"
"$out"
