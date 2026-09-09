# Exact peak equations and rejected coarse-space candidates

✅ Captured actual native stress equations before resident iteration, including the original normalized RHS, warm bond forces, initial residual and unchanged acceptance threshold. The isolated `PhysXDestructionGpuProblemDiagnostic` CMake target includes the intrusive capture; production has no capture declarations, graph node, copies or host decisions.

Workload: **256 buildings, 113,664 chunks, 229,376 bonds, 768 physical projectiles, 600 steps / 10 simulated seconds**. Direct GPU off, sleeping on, dt 1/60, maximum one correction and two stress evaluations. Captured solve ordinals 50 and 51 are the two stress evaluations at first major-fracture tick 48. The capture is diagnostic, not a performance result.

[Independent equation/work assessment](report.md), [coarse-space results](coarse-spaces.json), [snapshot hashes](snapshot-hashes.json). Compressed snapshots and the selected solve records are in `snapshots/`; decompress them into a fresh directory before replay. Only solve-50/51 component records are archived; the original complete diagnostic log remains in `out/peak-problem-20260909/capture`.

The independent FP64 recurrence checks the actual true bond-gradient residual. Its polynomial iteration counts closely match the native capture for these four anchored components. This does not establish general floating-point equivalence or full simulation parity.

- ❌ IC0: fewer iterations, but 46–56 sequential triangular levels per application versus two polynomial stages. No CUDA implementation or performance claim.
- ❌ Reprojecting a solved trial-parent solution into the corrected component worsened the two hardest selected cases: 357 → 367 and 341 → 354 independent FP64 updates. Archived script/results record the experiment; it is not a production warm-start change.
- ❌ [Additive six-mode correction](../rigid-additive-20260909/README.md): passed numerical and penetration checks, no peak win.
- ❌ [GPU-cached setup revision](../rigid-additive-cached-20260909/README.md): also passed correctness screening, no convincing peak win and slower idle. Both production implementations and their temporary tests were reverted.
- ⬜ Balanced and larger coarse spaces remain offline mathematical screens only. Dense-product counts in the JSON describe the generic offline implementation, not a lower bound or the optimized analytic six-mode GPU implementation.

## Reproduce

```sh
cmake -S physx/compiler/public -B out/sdk-release
cmake --build out/sdk-release --target PhysXDestructionGpuProblemDiagnostic -j3
# Explicitly load out/sdk-release/diagnostics/stress-problem at process startup.
# Set PHYSX_COMPONENT_WORK_OUTPUT to a fresh JSONL filename.
# Set PHYSX_STRESS_PROBLEM_PREFIX to a fresh output prefix.
# Set PHYSX_STRESS_PROBLEM_SOLVES=50:51 for the frozen 256-building command tape.
OPENBLAS_NUM_THREADS=1 python3 tools/scripts/assess-native-stress-problems.py CAPTURE FRESH_ASSESSMENT
OPENBLAS_NUM_THREADS=1 python3 tools/scripts/assess-native-coarse-spaces.py CAPTURE FRESH_ASSESSMENT/assessment.json FRESH_COARSE.json
```

Configuration uses the existing qualified CUDA/sm89 cache. The archived capture runner is a record of this machine's exact run, including its owned-service checks, not a general deployment script. A future runner must resolve candidate module symlinks when attesting library maps: three byte-identical GPU-module copies were subsequently deduplicated to one immutable local artifact; their recorded content hashes are unchanged.

**No new production speedup, external baseline parity, 60 Hz result or completed architecture is claimed.**

✅ Reproducible CMake diagnostic built successfully. [Capture memcheck](capture-check/capture-memcheck.log) passed on the 2-chunk/1-bond native fixture plus a 513-collider ordinary body. Only requested solve ordinals 0 and 1 were captured, later solves ran without snapshots, and inactive rows contain defined zero RHS/residual values. Restored macro-off production numerical suites passed after both candidate reversions. Fixture warnings about ill-conditioned authored inertia remain visible in the log.
