#!/usr/bin/env bash
# Autoresearch guard: every kept change must
#  1. reproduce the reference coupled to PhysX in each realtime_peak regime (ram speed,
#     fragments, broken bonds within twice the reference's own spread),
#  2. pass the GPU accuracy gate's quick tier (13 cases, established methods),
#  3. add no micro-tier failure (two predate this work: coupled_impulse, coupled_sleeping).
set -euo pipefail
cd "$(dirname "$0")/.."
SDK=${PHYSX_GPU_SDK:-/Users/glavin/Development/PhysX/out/install/macos-cumetal/release}
PHYSX_ROOT=$SDK CARGO_TARGET_DIR=target/physx-gpu cargo build -q --release -p stress-physx --features gpu --example realtime_peak 2>/dev/null
DYLD_LIBRARY_PATH=$SDK/lib target/physx-gpu/release/examples/realtime_peak --guard 2>/dev/null | grep -E "guard|PEAK_MS"
cargo build -q --release -p stress-gpu --bins 2>/dev/null
STRESS_METHODS=established target/release/stress-gpu-gate --build --quick > /dev/null 2>&1
STRESS_METHODS=established target/release/stress-gpu-gate --quick 2>&1 | tail -1 | grep -q "13 of 13 cases pass"
STRESS_METHODS=established target/release/stress-gpu-gate --build --micro > /dev/null 2>&1
fails=$(STRESS_METHODS=established target/release/stress-gpu-gate --micro 2>&1 | grep -c "FAIL" || true)
[ "$fails" -le 2 ]
echo "guard: pass (quick gate 13/13, micro failures $fails)"
