#!/usr/bin/env bash
# Autoresearch metric: the worst complete frame (ms) of the GPU stress solver coupled to
# PhysX with GPU dynamics (CuMetal on macOS), over the realtime_peak regimes (fresh idle
# house, rammed free wall, rammed house; 0.25 s each). Prints one number.
#   PHYSX_GPU_SDK=<GPU PhysX install> scripts/realtime_verify.sh
set -euo pipefail
cd "$(dirname "$0")/.."
SDK=${PHYSX_GPU_SDK:-/Users/glavin/Development/PhysX/out/install/macos-cumetal/release}
PHYSX_ROOT=$SDK CARGO_TARGET_DIR=target/physx-gpu cargo build -q --release -p stress-physx --features gpu --example realtime_peak 2>/dev/null
DYLD_LIBRARY_PATH=$SDK/lib target/physx-gpu/release/examples/realtime_peak "$@" 2>/dev/null | grep '^PEAK_MS' | awk '{print $2}'
