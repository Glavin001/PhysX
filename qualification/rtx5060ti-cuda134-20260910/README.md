# RTX 5060 Ti / CUDA 13.4 migration

Baseline: `471ea8a55bef3d1320a06d65d238f351f9015859`. VM branch: `codex/rtx5060ti-cuda134`.

**Build and profiling ready; physical equivalence is NOT qualified.**

## Environment and source

- RTX 5060 Ti, 16 GB, compute capability 12.0; driver 615.71.09 after authorized reboot.
- CUDA 13.4.59, CMake 3.31.10, Clang 14; NVCC uses installed GCC 12.3.
- Source transfer: 8,493 entries, SHA-256/symlinks checked with zero mismatches. Includes Git history and existing nonignored working files. Excludes generated builds/caches. Old `out/` and `/tmp` captures are NOT backed up by this migration.
- Original checkout is unchanged. Existing unrelated visual-audit documents are excluded from the port commit.
- Probe passed native execution, forced PTX JIT, memcheck, hardware counters and CUDA software tracing. Evidence: `/root/cuda-upgrade-check/postboot.qVQlHO/`.
- Nsight Compute also captured the real destruction motion-slot test successfully. Report: `out/vm-port-20260910/motion-slots-counters.ncu-repz`.

## Build

```bash
cd /root/workspace/physx-2
export PATH="$PWD/.toolchains/build-env/bin:/usr/local/cuda-13.4/bin:$PATH"
python tools/scripts/build-destruction-sdk.py --jobs 8 \
  --cuda /usr/local/cuda-13.4/bin/nvcc --cuda-architectures 120 \
  --cc /usr/bin/clang --cxx /usr/bin/clang++ --gpu-renderer
```

Build/install succeeded. Artifacts: `out/install`, `out/destruction-sdk`; hashes in `sdk-artifacts.json`. Repo-local Python environment includes NumPy for motion audits.

Port changes: architecture selection/guards, C++17 for current CCCL, CUDA 13 context/graph signatures, removed CUB aliases, and new NVCC host-stub symbols for PhysX's private driver-dispatch wrapper. Unsupported CUDART host-stub calls explicitly return errors. No solver fallback or physical-equation change. Architecture 89 remains selectable but is NOT qualified with CUDA 13.4. This branch requires CUDA >=13.4.

## Validation

| Check | Result |
|---|---|
| CPU timing/report tests | 52 passed (34 timing, 11 phase analysis, 7 GPU profile) |
| Standalone GPU lifecycle/topology suite | 8/8 passed |
| Motion-slot memcheck | Passed, zero errors; capacities 1 through 113,664 and invalid/growth cases |
| Broad native/numerical screen | 57/61 passed; includes the 8 standalone tests and resident stress tests |
| Native smoke after loader repair | 6/6 passed; subset of broad suite |
| Single penetration, ordinary API + sleeping | Simulation and geometric/motion invariants passed; exact frozen identity/count gate FAILED |
| Single penetration, Direct GPU configuration | Simulation completed; displaced-wall-chunk invariant FAILED |
| 256-building bombardment, both API modes | Simulation completed; exact-zero position audit FAILED |

The two single-penetration captures each contain 600 steps / 10 simulated seconds, 444 chunks, 896 bonds, one projectile, timestep 1/60, correction limit 1. Ordinary mode: 400 supported chunks, 44 detached, 182 broken bonds, 39 final clusters; projectile clears both walls; collision/render position error zero. Historical golden: 398 supported, 46 detached, 199 broken bonds, 43 clusters. No expected values or tolerances were changed. The golden's historical API mode is not independently requalified on the old machine here; differences must not automatically be attributed to a specific compiler/device cause.

Both bombardment runs: 256 buildings, 113,664 chunks, 229,376 bonds, 256 projectiles, 180 steps / 3 simulated seconds, correction limit 1. Maximum observed position errors: 2.1626548914355226e-5 m (Direct GPU), 1.7298085367656313e-5 m (ordinary API + sleeping). First-difference diagnostic shows identical actor positions and slightly different quaternion values. Matching aligned transform representation did not help and was reverted, along with temporary logging. Cause remains unresolved; no claim of physical equivalence.

The other two broad-suite failures are accepted-property initcheck tests (TGS/PGS). Minimal `scan-probe.cu` reproduces 24 uninitialized-read reports outside PhysX/Blast while exact exclusive sums pass for lengths 1..16. Poisoning output first yields correct overwritten output and no warnings. This implicates CUB/toolkit instrumentation but does not prove the exact cause. Production buffers were NOT pre-cleared; no suppression was added. Both gates remain unqualified.

All captures/logs are under `out/vm-port-20260910/`; small receipts are copied here. Diagnostic captures include rendering/readbacks, and the desktop remained active: timings are NOT isolated performance qualification. No Rust/WASM/game deployment or full endurance/scaling campaign was performed.

## Next work

1. Establish mode-matched original-machine penetration captures; compare the first differing contact/load/stress verdict with the new device/toolchain, preserving equations and assertions.
2. Resolve exact accepted-pose/readback discrepancies without changing physical math merely to satisfy a test.
3. Determine the CUB/initcheck instrumentation issue with the isolated reproducer; keep the gate explicit until resolved.
4. Only then qualify matched workload performance using counters and untraced complete-step timing separately.
