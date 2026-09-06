# Native destruction timing and scaling diagnostics

The native demo has optional CUPTI tracing that records concurrent GPU kernels,
copies, memsets, and CUDA driver/runtime API intervals. It does not synchronize
individual kernels or replay them. The host callback records timestamped scopes,
OS thread IDs, and thread CPU-clock deltas. Frame rows include process CPU time,
registered versus active body counts, contact-manager work, and stress topology.

Build with CUDA CUPTI and zlib:

```sh
python3 tools/scripts/build-destruction-sdk.py --jobs 4 --gpu-profiler
```

Or, for an already built SDK:

```sh
cmake -S destruction -B out/destruction-sdk -DNATIVE_GPU_CUPTI=ON
cmake --build out/destruction-sdk --target native_destruction_demo -j4
```

CUPTI is optional and off by default. Requesting `--profile-gpu 1` from a build
without CUPTI fails explicitly. `--profile-phases 1` needs no CUPTI. Its CPU clocks
and timestamps remain available, but GPU kernel timelines require CUPTI.

Workloads:

- `--workload idle`: intact, supported buildings; no shots, zero fracture required.
- `--workload single-impact`: one actual projectile; fracture required.
- `--workload bombardment --waves 2 --launch-seconds 1`: an early burst followed by
  collision and rubble motion. `--launch-seconds 7` spreads the same projectiles.
- `--workload idle --free-bodies 96000`: an explicit ordinary-body control. Bodies
  are spaced three meters apart, move at 0.1 m/s without gravity, and start clear
  of the building and ground. It does not approximate the contact-rich workload.

All destruction workloads preserve the normal impulse-driven model and one
correction limit. No new sleep suppression, collision filtering, force limiter,
or stress approximation is introduced. The current integrated correction path
already requires sleeping disabled; the report makes that limitation explicit.

Run the matrix sequentially so benchmark processes do not compete with one another:

```sh
python3 tools/scripts/run-native-scaling-profile.py out/my-scaling --seconds 12 --trials 3
python3 tools/scripts/run-native-scaling-profile.py out/my-controls --seconds 12 --trials 3 --controls
```

Trial zero captures CUPTI and host phases; later trials disable those diagnostics
for baseline timings. Existing GPU processes are recorded and never stopped.
`--resume` skips recorded runs and verifies the executable hash. Failed runs keep
logs and partial captures and do not prevent independent cases from running.

For each successful capture, analyze it, then combine campaigns:

```sh
python3 tools/scripts/analyze-native-gpu-profile.py out/my-scaling/burst-g8-t0
# Repeat analysis for each completed capture in the campaign.
python3 tools/scripts/report-native-scaling-profile.py out/my-scaling out/my-controls \
  --output docs/destruction/qualification/my-scaling.md
python3 tools/scripts/test-native-gpu-profile.py
```

The report command requires analyzed successful captures. It chooses the latest
traced capture and latest campaign's baseline repeats for each workload. Its JSON
contains kernel names/source classification, all CPU phases, min/mean/percentiles/
maxima, counters and per-workload correlations. Raw frames, scope intervals,
compressed GPU activities, names, and capture-completeness checks remain in `out`.

Interpretation rules:

- GPU busy time is a union clipped to simulation/fetch boundaries. Never add
  concurrent kernels or nested host scopes to infer elapsed simulation time.
- CPU time is **core-ms**, not wall-ms; it includes busy waiting and profiler or
  driver execution. Detached spans cannot be assigned synchronous task CPU time.
- Frame time without activity from this process is not proof of global GPU
  idleness. Other GPU processes, host dependencies, scheduling, and launch gaps
  can contribute.
- Checkpoint GPU copies are matched to CPU submission scopes by CUPTI correlation
  IDs. Copy execution may outlive that scope. Source scopes use `PxProfileScoped`
  directly so they remain available in release builds.
- `pre_solve_pairs` counts GPU contact-manager processing across trial/correction.
  Legacy public contact/solver-row counters are incomplete for GPU work. The
  compatibility `stress_solve_ms` zero field is not a stress measurement; use the
  GPU trace or explicitly labeled destruction-stream CUDA event intervals.
- Stress topology counters are fixed-size diagnostic reads after simulation.
  They describe graph membership, not each iteration's nonconverged work set.
- A run with dropped activity records, invalid timestamps, failed simulation,
  or nonconvergence cannot be used as a successful benchmark.
- No strict 60 Hz qualification is claimed from short windows on a shared GPU.
  A low mean does not compensate for missed step deadlines.

Current results: [scaling and bottlenecks](qualification/scaling-bottlenecks-20260906.md).
