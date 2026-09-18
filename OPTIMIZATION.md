# Native C++/CUDA optimization workflow

Run commands from `/root/workspace/physx-2`. This workflow implements the user's
2026-09-10 instruction to resume integrated optimization. Read
[the preserved handoff](docs/destruction/HANDOFF-20260910-integrated-ab.md) and
[current experiment ledger](qualification/optimization-20260910/README.md).
The handoff's stopped status is historical; its artifact and correctness warnings
still apply. The user subsequently authorized reversible service/GPU recovery and
rebooted the box on2026-09-12. Desktop and the other project server may be stopped
for exclusive measurements, then restored using their preserved configuration and
original installed SDK. No deployment, permanent service change or driver update.
See the latest AGENTS entry for live jobs and restoration state.

Historical commands below contain the former server PID435374. Never copy that
allowlist onto a new run without checking the current process identity. The active
headless campaign admits no other GPU clients. Shared-GPU runs, when explicitly
selected, remain labeled diagnostics. Use repeated matched A/B controls and inspect
interference before attributing an application improvement.

## Current twenty-experiment continuation

The latest user direction authorizes breaking internal changes and qualified
precision compromises for substantial application gains. This supersedes older
blanket prohibitions on experimenting with reduced precision, while preserving
same-tick contacts → stress/fracture → at most one correction → second stress →
accepted publication. Never overlap stress with physics using stale inputs.

Start from retained E12 and follow the [new adaptive queue](qualification/optimization-next20-20260910/queue.json).
Remove unnecessary work and consider direct/structural algorithms before tuning.
Initially retain all current final equilibrium/physical error limits while
changing intermediate arithmetic. A changed final error envelope requires an
explicit recorded budget, independent force/moment/equilibrium/response/energy
checks and material/trajectory assessment; do not silently rewrite goldens or
call different-quality timings an equal-quality speedup. Existing historical
failures remain unresolved. The previous ten-experiment report is preserved.

## Architectural improvements and neutral results

The user's2026-09-11 clarification permits retaining a correctness-qualified,
performance-neutral change when it clearly improves ownership/ordering or code
reasoning, or enables a specific valuable follow-up that the current design
obstructs. Do not judge solely by immediate speed. Record the concrete benefit,
its next consumer/experiment, complexity and setup/memory costs, and matched
idle/heavy full-step evidence showing no material regression. Label it an
**enabling improvement**, not a measured speedup. Speculative possibilities alone
are insufficient; prefer a reviewable interface/invariant and a concrete next
implementation. Physical-quality gates still apply. Reassess earlier neutral
candidates where this changes the decision; preserve their original evidence.

## Contract and baseline identity

Optimize complete application work: CPU preparation, GPU execution, transfers,
synchronization, allocation/setup, correction and required publication. Use
`complete_step_ms`, retain startup and every measured step, and report separate
initialization costs. Never sum nested GPU durations into CPU waits.

Frozen suite: 256 buildings, 113,664 chunks, 229,376 bonds; pristine idle with
zero projectiles and bombardment with one simultaneous 256-projectile wave.
Ordinary `PxDestructionScene`, Direct GPU off, sleeping on, dt 1/60, at most one
correction/two physics and stress evaluations; 8192 stress iteration cap and
unchanged material, convergence, force/moment, energy and motion requirements.
Measure time to required convergence. No precision relaxation, dropped work or
convergence carried across ticks. The checked-in
[`destruction-ordinary-ab.json`](tools/profiles/destruction-ordinary-ab.json)
preserves the handoff's exact common/case arguments; only its description differs.

Current isolated artifacts, rehashed during setup:

| Arm | Directory | Destruction runtime SHA256 |
|---|---|---|
| A, benchmarked engine | `out/integrated-polynomial-barrier-20260910/A` | `93846c918089a61d5883790fd101199f08ffae701599d715eedf7c247961a126` |
| B, unaccepted barrier candidate | `out/integrated-polynomial-barrier-20260910/B` | `295c1e994322319e6933a3d4918cc46e92170168b1f8e17a33be3186835a2151` |

Both demo hashes are `6779e48efc808e7f8d6c6edc7539bf405388831580cf260de251d897517e054e`.
Both GPU activity module hashes are `63510ee906965de8a44e2c94a825dcfea197cc15ba00da15b126cb5fb29a6406`.
These are the preserved handoff arms. Current experimental source/build state
is recorded in the experiment ledger; `out/install` remains A. The old SDK
attestation does not attest experimental binaries. Preserve these arms. Never infer the loaded arm from an
executable name or `ldd`; verify actual process maps and module hashes.

## Required reporting format

Every performance report leads with both idle and heavy-destruction **complete-step**
results for the same workload, duration and quality: repeated A-before/B/A-after
means, per-run/all-run maxima with step indices, and exact >8 ms, >1000/120 ms
and >1000/60 ms counts **and percentages**. Keep startup steps; separately report
initialization and initialization plus the sum of complete steps. Separate the
first fracture, later loaded steps and idle steady state where useful, without
changing the full-suite denominator or selecting only favorable steps.

Use stage measurements to explain application results: CPU input/preparation,
ordinary physics/contact work, load/stress/material/topology work, fragment
registration, rewind/corrected physics and second stress, and accepted publication.
Label host wall intervals, CUDA event intervals and pure kernel durations distinctly.
GPU work often lies inside a CPU wait; nested/overlapping intervals must never be
added or subtracted as if they were independent costs. Report any unpartitioned
remainder. `physics_step_ms` contains the integrated destruction pipeline; it is
not a measurement of stock PhysX alone. A clean stock-physics/destruction split
cannot be inferred by subtracting stress kernel time.

Unprofiled production-scheduling complete steps decide acceptance. Profiler or
inline-dispatch diagnostic timings explain mechanisms only unless scheduling is
itself the explicitly tested candidate. Mark unavailable stage measurements as
unmeasured; do not substitute stale or differently configured CPU timings. Report
mean gains, peak gains and deadline improvements separately, and retain failed
quality gates and shared-GPU limitations. Current matched starting-point/result
snapshot: [scenario report](qualification/optimization-20260910/status-scenarios.md).

## Semantic scenarios and snapshot replay

The unified saved-input entrypoint is `tools/diagnostics/destruction-snapshot/run-suite.py`;
see its [exact 52-case command](tools/diagnostics/destruction-snapshot/README.md).
It runs 20 independent restores with exactly one complete tick each, with
restore/validation excluded. `--group structural` retains all original 28 cases;
`--group city` selects all 24 native city captures. Historical continuation
results below use a different protocol and are not interchangeable.

The executable **24-case suite (16 native trajectory cases + 8 synthetic
structures)** and its repeatability protocol are documented in
[the semantic suite report](qualification/optimization-next20-20260910/semantic-suite-20260911.md).
Use `tools/profiles/destruction-semantic-suite.json`; do not replace the existing
600-step idle/heavy comparisons with its shorter fixed prefixes. These are full
ticks reached by reconstructed history, **not qualified snapshot restores**.

Build the authoring harness, then freeze the new demo alongside the retained
solver modules in a new isolated directory. The current frozen harness is
`out/semantic-suite-20260911/N13-geometry`; it deliberately uses N13 despite the
shared CUDA source retaining unaccepted N14 work.

```bash
.toolchains/build-env/bin/cmake --build out/destruction-sdk --target native_destruction_demo -j6
python3 tools/scripts/test-destruction-semantic-suite.py
python3 tools/scripts/run-destruction-semantic-suite.py out/NEW-semantic-discovery \
  --baseline out/semantic-suite-20260911/N13-geometry --repeats 1 \
  --allow-existing-graphics --allow-compute-pid 435374
python3 tools/scripts/run-destruction-semantic-suite.py out/NEW-semantic-pilot \
  --baseline out/semantic-suite-20260911/N13-geometry \
  --selection qualification/optimization-next20-20260910/semantic-suite-selection.json \
  --repeats 10 --allow-existing-graphics --allow-compute-pid 435374
python3 tools/scripts/report-destruction-semantic-suite.py out/NEW-semantic-pilot \
  --output out/NEW-semantic-pilot/results.json
```

After inspecting pilot noise, predeclare a NEW fixed-size paired confirmation
(20 below is an example, not a universal sufficient sample count). Both isolated
arms must support the same authoring inputs and already pass relevant correctness
gates. Use the same directory for both arms to run an A/A null control.

```bash
python3 tools/scripts/run-destruction-semantic-suite.py out/NEW-semantic-paired \
  --baseline out/semantic-suite-20260911/N13-geometry --candidate out/NEW-candidate \
  --selection qualification/optimization-next20-20260910/semantic-suite-selection.json \
  --repeats 20 --allow-existing-graphics --allow-compute-pid 435374
python3 tools/scripts/report-destruction-semantic-suite.py out/NEW-semantic-paired \
  --output out/NEW-semantic-paired/results.json
```

For companion host/CUDA stages, run the same baseline command in another fresh
directory with `--repeats 1 --phase-scopes`, then apply the existing stage analyzer
to each measured `000-FIXTURE-A/scene` directory. These instrumented times remain
separate from unprofiled repetitions. The runner records full command arrays,
mapped module hashes, raw frame hashes and GPU observations. Its shared lock
prevents cooperating A/B wrappers from overlapping. Missing events and changing
predicates are recorded explicitly, not replaced by candidate-selected frames.

The2026-09-11 user direction requires event/structure-specific comparisons in
addition to aggregate idle/heavy runs. Follow the
[semantic scenario and replay contract](qualification/optimization-next20-20260910/semantic-scenarios.md).
Distinguish complete-tick snapshots, integrated stage snapshots and selected
trajectory frames. Do not call the existing correction checkpoint a complete
world snapshot. Freeze event selection and input hashes before candidate timing;
report structural traits, cache/setup policy, output variability and physical
quality alongside per-case complete-step/stage results. Post-fracture quiescence
must be observed, not inferred from elapsed steps. Preserve full trajectories.

Compare the existing fixed semantic frame selections (this is not snapshot replay):

```bash
python3 tools/scripts/report-destruction-semantic-frames.py \
  out/optimization-next20-20260910/N14-response-history/screen \
  --manifest qualification/optimization-next20-20260910/semantic-frame-manifest.json \
  --output qualification/optimization-next20-20260910/semantic-frame-report.json
```

## Environment and build commands

```bash
cd /root/workspace/physx-2
export PATH="$PWD/.toolchains/build-env/bin:/usr/local/cuda-13.4/bin:$PATH"
git status --short
git log -3 --oneline
nvidia-smi --query-gpu=name,uuid,driver_version,utilization.gpu,memory.used,temperature.gpu --format=csv
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
nvcc --version
ncu --version
nsys --version
```

The actual CMake caches select CUDA 13.4, destruction architecture 120, Clang 14
CPU compilation and release builds. NVCC uses GCC 12.3 as host compiler.
`out/sdk-release` configures `physx/compiler/public`; `out/destruction-sdk`
configures `destruction` and imports the native demo/reference tests. Existing
CMake settings include the GPU renderer needed by the frozen wall audit.

For a private destruction CUDA implementation change (no ABI change):

```bash
cmake --build out/sdk-release --target PhysXDestructionGpuRuntime -j6
cmake --build out/destruction-sdk --target gpu_resident_stress_test gpu_resident_stress_3d_test gpu_resident_motion_modes_test -j6
```

For changes spanning native ABI/CPU consumers, rebuild all affected consumers:

```bash
cmake --build out/sdk-release --target PhysX PhysXGpu PhysXDestructionGpuRuntime -j6
cmake --build out/destruction-sdk --target native_destruction_consumers -j6
```

Only for an intentional fresh SDK build/install or after acceptance:

```bash
python tools/scripts/build-destruction-sdk.py --jobs 8 \
  --cuda /usr/local/cuda-13.4/bin/nvcc --cuda-architectures 120 \
  --cc /usr/bin/clang --cxx /usr/bin/clang++ --gpu-renderer
```

The last command installs and refreshes `out/sdk-artifacts.json`; do not run it
to promote an unaccepted experiment. No clean rebuild is needed for each edit.
Builds and heavy CPU analysis must finish before timing. Freeze each candidate
demo, required `.so` modules and any changed static consumers in its own fresh
directory. The runtime is `libPhysXDestructionGpuRuntime_64.so`; the upstream GPU
module is **`libPhysXGpuActivity_64.so`**, not `libPhysXGpu_64.so`.

## Correctness commands

The active full wall gate defaults to ordinary APIs and sleeping enabled. It
compares all 600 ticks against the pre-snapshot reference pinned by
`tools/profiles/wall-penetration-ordinary-reference.json`, including exact
fracture/topology history and the existing physical and trajectory limits.
The original Direct GPU golden is unchanged; `--historical-direct-gpu` selects
that separate historical audit explicitly. The current same-mode wall run passes;
older cross-GPU differences remain historical unqualified evidence.

Current snapshot memory diagnostic (52 scenarios, two restores each):

```bash
python3 tools/diagnostics/destruction-snapshot/run-suite.py out/NEW-blocking-mem-suite \
  --structural-inputs out/snapshot-large-20260911/roundtrip-regressions \
  --city-inputs out/snapshot-large-20260911 \
  --binary out/snapshot-large-20260911/final-artifacts/native_destruction_snapshot_test \
  --artifacts out/snapshot-large-20260911/stable-rebuilt-artifacts \
  --repetitions 2 --sanitizer memcheck --sanitizer-blocking-launches \
  --allow-existing-graphics --allow-compute-pid 435374
.toolchains/build-env/bin/python tools/scripts/test-native-prefix.py
```

Blocking launch mode serializes diagnostic execution and may hide ordering
defects. Its 52-case pass does not clear the asynchronous failure; omit
`--sanitizer-blocking-launches` to investigate that failure. Sanitizer captures
are rejected by the unprofiled timing reporter. Do not use them as performance
measurements or add production synchronization based on this diagnostic alone.


Inspect registered names and run focused GPU tests sequentially:

```bash
ctest --test-dir out/destruction-sdk -N
ctest --test-dir out/destruction-sdk \
  -R '^blast_stress_gpu_resident_(analytic|3d|motion_modes)$' --output-on-failure -j1
ctest --test-dir out/destruction-sdk \
  -R '^physx_native_gpu_(collision_preparation|contact_properties|retained_registry|contact_lifetime_exhaustion|initialization_failure|connectivity_owner)$' \
  --output-on-failure -j1
```

Frozen full ordinary wall audit, selecting B explicitly (use A for its control):

```bash
LD_LIBRARY_PATH="$PWD/out/integrated-polynomial-barrier-20260910/B" \
  python tools/scripts/run-destruction-penetration-regression.py out/NEW-B-wall \
    --binary out/integrated-polynomial-barrier-20260910/B/native_destruction_demo \
    --expected-runtime "$PWD/out/integrated-polynomial-barrier-20260910/B/libPhysXDestructionGpuRuntime_64.so" \
    --standard-scene --sleeping 1 --tier full
compute-sanitizer --tool memcheck --error-exitcode 97 out/destruction-sdk/reference/gpu_resident_stress_3d_test
compute-sanitizer --tool initcheck --error-exitcode 97 out/destruction-sdk/reference/gpu_resident_stress_3d_test
compute-sanitizer --tool synccheck --error-exitcode 97 out/destruction-sdk/reference/gpu_resident_stress_3d_test
compute-sanitizer --tool racecheck --error-exitcode 97 out/destruction-sdk/reference/gpu_resident_motion_modes_test
```

The wall is 600 steps/10 simulated seconds, 444 chunks, 896 bonds, one projectile.
Both preserved A and B pass its geometric/motion invariants and match each other,
but fail the unchanged historical topology golden. Broad 3D racecheck also remains
unresolved on both arms. Other migration failures are in `AGENTS.md`. Do not call
this a clean physical baseline or waive failures. Use independent numerical,
native lifecycle/material/command tests appropriate to each changed boundary,
and compare full city poses/command tapes separately from untraced timing.

CPU-only report/wrapper validation (no CUDA launch):

```bash
python3 tools/scripts/test-destruction-timing.py
python3 tools/scripts/test-native-phase-analysis.py
python3 tools/scripts/test-native-gpu-profile.py
python3 tools/scripts/test-destruction-ab.py
python3 tools/scripts/test-destruction-peak-opportunities.py
```

## Baseline, candidate screens and structured results

First verify A without changing engine source:

```bash
python3 tools/scripts/run-destruction-ab.py out/NEW-baseline \
  --baseline out/integrated-polynomial-barrier-20260910/A \
  --trials 2 --seconds 3 --allow-existing-graphics
```

Then one coherent candidate per A-before/B/A-after campaign, both cases in every
stage, two untraced repeats plus separate warmups per case. Finish correctness
first. For the inherited B, retain its known failed gates in the receipt:

```bash
python3 tools/scripts/run-destruction-ab.py out/NEW-barrier-ab \
  --baseline out/integrated-polynomial-barrier-20260910/A \
  --candidate out/integrated-polynomial-barrier-20260910/B \
  --correctness out/integrated-polynomial-barrier-20260910/B-tests.json \
  --hypothesis 'Remove the polynomial trailing barrier whose consumers initially read their own rows' \
  --trials 2 --seconds 3 --allow-existing-graphics
```

The wrapper reuses `run-destruction-timing.py` and
`compare-destruction-candidates.py`, selecting one case per comparison. It writes
`experiment.json`, exact commands, revision/dirty patch/untracked hashes, config,
arm hashes, per-case campaign/report paths, and comparisons against both A
brackets. The existing runner retains raw frame CSVs, summaries, all samples,
GPU process observations and loaded-module maps. Every output directory must be
new. Independent wrappers share a lock; foreign compute still rejects admission.
Recorded pre-existing graphics are permitted only as diagnostic interference.
The correctness receipt is evidence, not an automatic waiver or acceptance flag.

Exit 0 means a completed screen, **not** candidate acceptance. Exit 2 means a
completed deadline failure or physical-counter mismatch (inspect JSON); exit 3
means GPU unavailable and no simulation launched; other failures are incomplete.
Missing process maps, changed artifacts and failed simulations reject comparison.

The existing direct commands remain available:

```bash
LD_LIBRARY_PATH="$PWD/out/integrated-polynomial-barrier-20260910/A" \
  python3 tools/scripts/run-destruction-timing.py out/NEW-A-impacts \
    --binary out/integrated-polynomial-barrier-20260910/A/native_destruction_demo \
    --config tools/profiles/destruction-ordinary-ab.json --case impacts-256 \
    --trials 2 --seconds 3 --gate-only --allow-existing-graphics
python3 tools/scripts/report-destruction-timing.py out/NEW-A-impacts --output out/NEW-A-report
python3 tools/scripts/compare-destruction-candidates.py \
  --baseline out/NEW-A-impacts/report/report.json.gz \
  --candidate out/NEW-B-impacts/report/report.json.gz --output out/NEW-comparison
```

Do not mix 180-step screens with 600-step results. Broaden a promising candidate
to the same A/B/A command with `--trials 3 --seconds 10`. Retain means, p50/p95/p99,
all-step and destruction maxima, exact counts **and percentages** strictly above
8 ms, 1000/120 ms and 1000/60 ms; report per-run values and A drift. Full promotion
also requires the repository's five 60-second trials/endurance and unresolved
fidelity gates. Setup moved out of an impact remains visible in initialization
or startup; it cannot be presented as deleted work.

## Normal-scheduling stage capture

Add `--phase-scopes` to the existing gate runner for a separate CPU-scope/CUDA-event
capture with the same ordinary four-worker binary. This is the appropriate
host-stage companion to unprofiled results; it does not need an inline dispatcher.
Run each arm and both `idle-256` / `impacts-256` cases in fresh directories:

```bash
LD_LIBRARY_PATH="$PWD/out/optimization-20260910/E3-factor-reuse/B" \
  python3 tools/scripts/run-destruction-timing.py out/NEW-E3-idle-phases \
    --binary out/optimization-20260910/E3-factor-reuse/B/native_destruction_demo \
    --config tools/profiles/destruction-ordinary-ab.json --case idle-256 \
    --trials 2 --seconds 3 --gate-only --phase-scopes \
    --allow-existing-graphics --allow-compute-pid 435374
python3 tools/scripts/analyze-native-destruction-phases.py \
  out/optimization-20260910/E3-factor-reuse/production-phases/plain-B-impacts-256/scene \
  --output out/NEW-E3-phase-analysis.json
```

The peak reporter groups final shape publication and the remainder of final
publication into accepted-state publication. Its regression checks conservation
when work moves out of correction acceptance into these scopes. Never drop
unrecognized scopes to make the partition close.

## Systems first, targeted Compute second

Reuse [the completed city profiles](qualification/ncu-city-20260910/README.md)
for A: their mapped runtime hash matches A, and their input arguments match this
scene apart from explicitly diagnostic state recording/phase instrumentation.
Those reports do not describe candidate B. No repeat of the known Nsight
cross-thread conditional-graph failure is needed.

Offline analysis commands (no GPU experiment):

```bash
nsys stats --report cuda_gpu_kern_sum --format csv out/ncu-city-20260910/timeline-inline/trace.sqlite
ncu --import out/ncu-city-20260910/counters-late/stress.ncu-repz --print-summary per-kernel
ncu --import out/ncu-city-20260910/counters-late/stress.ncu-repz --page raw --csv > out/NEW-late-metrics.csv
```

The preserved wrapper records process samples, maps, command arrays and hashes.
For profiles of the preserved one-header B, the existing inline demo is ABI
compatible. The historical capture wrapper still rejects foreign compute by
default; retain that evidence and explicitly record authorized shared identities
when adapting it for a fresh capture. Use a fresh mode suffix on every call:

```bash
LD_LIBRARY_PATH="$PWD/out/integrated-polynomial-barrier-20260910/B" \
DESTRUCTION_PROFILE_BINARY="$PWD/out/ncu-city-20260910/inline-build/native_destruction_demo-ncu-inline" \
  python3 out/ncu-city-20260910/capture.py timeline-B-NEW
LD_LIBRARY_PATH="$PWD/out/integrated-polynomial-barrier-20260910/B" \
DESTRUCTION_PROFILE_BINARY="$PWD/out/ncu-city-20260910/inline-build/native_destruction_demo-ncu-inline" \
DESTRUCTION_PROFILE_COUNT=2 \
  python3 out/ncu-city-20260910/capture.py counters-B-first-NEW 82
LD_LIBRARY_PATH="$PWD/out/integrated-polynomial-barrier-20260910/B" \
DESTRUCTION_PROFILE_BINARY="$PWD/out/ncu-city-20260910/inline-build/native_destruction_demo-ncu-inline" \
  python3 out/ncu-city-20260910/capture.py counters-B-late-NEW 130
.toolchains/build-env/bin/python out/ncu-city-20260910/compare.py plain-inline counters-B-late-NEW
```

`capture.py` runs Systems with `--trace=cuda,nvtx,osrt --sample=none
--cpuctxsw=none --cuda-graph-trace=node`. Compute uses
`--kernel-name-base function --kernel-name regex:componentStressSolve
--launch-skip N --launch-count COUNT --replay-mode kernel --graph-profiling node
--clock-control none --cache-control all`, with separate SpeedOfLight,
MemoryWorkloadAnalysis, SchedulerStats, Occupancy, WarpStateStats, LaunchStats,
ComputeWorkloadAnalysis, InstructionStats and SourceCounters sections. Exact
expanded executable/workload/profile commands are saved in each `receipt.json`.
Use `source-B-NEW 130` instead of `counters-B-late-NEW 130` for SourceCounters and
LaunchStats alone. Revalidate launch mappings if a change alters scheduling.

For later native CPU/ABI changes, rebuild the isolated diagnostic consumer:

```bash
python3 tools/diagnostics/nsight-cross-thread-conditional/build-native-inline.py \
  --target native_destruction_demo --output out/NEW-inline-build
```

Do not use a profiler diagnostic’s inline-dispatch timings to represent the
original four-worker application. E8 separately tests inline dispatch as an
explicit scheduling candidate with ordinary A/B timing and quality gates. Compare
ordinary/inline/profiled command tapes, convergence/correction history and poses.
The full metrics skill is used through targeted persistent reports: its fixed
thresholds and advertised speedups are hypotheses, not acceptance criteria.
NCU does not automatically export CSV; the explicit import command above does.
Avoid whole-trajectory `--set full` and the recorded software-counter timeout.

## Experiment discipline

Maintain the ranked queue in the ledger. Every hypothesis records evidence,
mechanism, scenarios, estimated **application milliseconds** saved, confidence,
cost, and supporting/refuting measurements. Examine unnecessary work, algorithms,
decomposition, coordination and layout before parameter sweeps. Estimates must
state assumptions and must not add overlapping scopes.

One coherent hypothesis per experiment; related C++ and CUDA changes are allowed.
Before execution, record the exact commit plus a dirty patch and untracked-file
hashes when the experiment inherits WIP. Never commit unrelated user changes to
manufacture a clean revision. A completed experiment needs baseline/candidate
source and artifact identities, correctness outcomes (including failures), all
repeated A/B timings, profile paths and an explicit conclusion. Preserve rejected
patches/artifacts; restore only that experiment's changes, using fresh mtimes
and rebuilding affected outputs. Keep the best verified implementation; do not
leave permanent experiment switches or overwrite the preserved A/B arms.

After three unsuccessful experiments in one family, stop that family, revisit
the diagnosis, research relevant primary implementations, and choose another
approach/target. Historical failed shared-inverse caching, forced occupancy,
FP32 preconditioning and local multilevel retries are in
[PERFORMANCE_FINDINGS.md](docs/destruction/PERFORMANCE_FINDINGS.md); do not repeat
them unchanged. Rank the next experiments again after each result.

Isolated experiment commits are retained on `codex/optimization-20260910-*`
evidence branches. Their parent snapshots the existing source/WIP using a
separate index; the user branch/index remain unchanged. Exact IDs are in
`out/optimization-20260910/experiment-commits.json`. Each completed screen also
has `measurements.json` with every repeat, initialization cost, and initialization
plus complete-step sum; this supplements the existing frame reports.

The E3 shared-GPU profile adapter preserves the original profiler wrapper and
adds exact authorized compute identities plus expected loaded-module validation.
Use fresh mode names; construction ordinal 45 maps to step 108 in its recorded
A/B timelines. For the archived E3 artifact:

```bash
LD_LIBRARY_PATH="$PWD/out/optimization-20260910/E3-factor-reuse/B" \
DESTRUCTION_PROFILE_ARTIFACTS="$PWD/out/optimization-20260910/E3-factor-reuse/B" \
DESTRUCTION_PROFILE_BINARY="$PWD/out/ncu-city-20260910/inline-build/native_destruction_demo-ncu-inline" \
DESTRUCTION_ALLOW_COMPUTE_PID=435374 \
  python3 out/optimization-20260910/E3-factor-reuse/profiles/capture.py timeline-E3-NEW
LD_LIBRARY_PATH="$PWD/out/optimization-20260910/E3-factor-reuse/B" \
DESTRUCTION_PROFILE_ARTIFACTS="$PWD/out/optimization-20260910/E3-factor-reuse/B" \
DESTRUCTION_PROFILE_BINARY="$PWD/out/ncu-city-20260910/inline-build/native_destruction_demo-ncu-inline" \
DESTRUCTION_ALLOW_COMPUTE_PID=435374 \
DESTRUCTION_PROFILE_KERNEL='regex:(^|::)construct$' \
DESTRUCTION_PROFILE_COUNT=1 \
  python3 out/optimization-20260910/E3-factor-reuse/profiles/capture.py counters-E3-NEW 45
```

Repeat with the preserved A artifact directory for the matching counter control.
Map launch ordinals again if code/workload changes; ordinal 0 is initialization,
not measured step 0. Preserve full trajectories and compare poses/counters after
profiling. Do not equate aggregate kernel savings with complete-step savings.

## Retained result after the ten-experiment batch

Retained source/local runtime/tests: E12, isolated commit
`8bde0e228f576fed58fdcb9c4c4ed11da922250a`. Installed SDK remains original A.
Use the [final scenario/stage report](qualification/optimization-20260910/status-scenarios.md)
and [selection hashes](qualification/optimization-20260910/selected-implementation.json).
E12 combines E3 factor reuse and E10 block-Jacobi; its final matched baseline is
E3, not original A. Earlier original-A comparisons remain separate evidence.

Exact final comparison command (choose a new output directory for another run):

```bash
python3 tools/scripts/run-destruction-ab.py out/NEW-E12-ab-600 \
  --baseline out/optimization-20260910/E3-factor-reuse/B \
  --candidate out/optimization-20260910/E12-composition/B \
  --correctness out/optimization-20260910/E12-composition/receipt.json \
  --hypothesis 'E3 factor reuse plus E10 block-Jacobi improves full-suite complete-step time beyond incumbent E3 at unchanged quality' \
  --trials 3 --seconds 10 --allow-existing-graphics --allow-compute-pid 435374
python3 out/optimization-20260910/summarize-screen.py out/NEW-E12-ab-600
```

Final correctness used the three numerical CTests and 3D memory/init/sync checks
in `out/optimization-20260910/E12-composition/run-checks.py`, plus the unchanged
ordinary/sleeping full wall command above. The historical wall golden still
fails; the invariant subset and four exact original-A wall outputs pass. That
is a relative comparison, not a waiver of the historical gate.

Exact profile entry points used `timeline-B` and `counters-B-late 130`; fresh
output names below avoid overwriting their reports. Run one GPU job at a time:

```bash
python3 out/optimization-20260910/E12-composition/profiles/run-B.py timeline-NEW
python3 out/optimization-20260910/E12-composition/profiles/run-B.py counters-NEW 130
```

The captured command arrays, module maps and hashes are in each output's receipt.
Both use the frozen 180-step heavy workload; the counter command targets only
`componentStressSolve` launch 130 (mapped to step 108). Complete new and reused
counter/timeline histories were checked against exact recorded poses. Separate
normal four-worker host scopes for both scenarios are retained under
`out/optimization-20260910/E12-composition/production-phases/`, including aligned
step 82/103/108 checkpoints and signed timestamp-bookend closure residuals.
Profiler/phase runs are diagnostic; unprofiled full steps decide acceptance.

## First-class destruction snapshot restore (2026-09-11)

Physical-state save/load is implemented as V20/schema7 with fresh numerical
caches. Follow `docs/destruction/SNAPSHOT.md`. The 28-case regression compares two
independent restores, checks exact physical state before stepping, then validates
ten full ticks at the existing quality and motion bounds. All 28 cases pass in
`out/snapshot-20260911/physical-state-v20/final-suite/`.

Build matching V20 consumers and run the native probe with the contract's exact
commands. Generate structured per-scenario results with:

```bash
python3 tools/diagnostics/destruction-snapshot/report-results.py \
  qualification/optimization-next20-20260910/snapshot-v20-results \
  out/snapshot-20260911/physical-state-v20/final-suite
```

See [current qualification](qualification/optimization-next20-20260910/snapshot-export-restore.md)
and [all scenario measurements](qualification/optimization-next20-20260910/snapshot-v20-results.md).
Report reconstruction/setup separately from full-step time. The restored first
tick and warm continuations are distinct scopes. Continuous city trajectory
benchmarks and their physical gates remain required; the earlier 24-case
performance suite has not been migrated to frozen one-tick inputs. Historical
V19 exact-continuation failures remain recorded, but CPU pool/contact-order
serialization is no longer a feature prerequisite. Snapshot correctness is not
an optimization speedup, and retained N13 / installed SDK are unchanged.

Six saved states now also pass 20 independent one-tick replays each in new
processes. [Measurements and scopes](qualification/optimization-next20-20260910/snapshot-v20-file-replay.md)
and [exact replay command](tools/diagnostics/destruction-snapshot/README.md).
The first-fracture input exercises one correction and two stress evaluations.
Five targeted memchecks and nine surrounding native CTests pass. The full
28-case memcheck hit its harness limit and remains explicitly incomplete.

### Large restored city suite (2026-09-11)

The [complete 52-scenario catalog](qualification/optimization-next20-20260910/snapshot-scenarios.md)
also lists all 28 original structural/rigid-body cases. The city expansion does
not replace them. Their historical continuation measurements and the newer
independent single-tick protocol are labeled separately.

Use `tools/profiles/destruction-snapshot-large.json` for 24 native saved states:
25/64/256 buildings (11,100/28,416/113,664 chunks), eight phases each. Capture
with the existing native demo and frozen ordinary A/B settings, then run
`tools/diagnostics/destruction-snapshot/run-large-suite.py replay` with twenty
independent restores and exactly one tick per sample. See the
[commands](tools/diagnostics/destruction-snapshot/README.md#native-city-snapshots-large-scene-expansion)
and [complete catalog](qualification/optimization-next20-20260910/snapshot-large-20260911/README.md).
The `.scene` and metadata sidecars are hashed along with both physical streams.
Report failed repeatability explicitly, even when all timed ticks converge and
satisfy the correction cap. Twenty samples do not remove systematic interference.
Cold restoration rebuilds solver/contact caches: compare these ticks with other
restored ticks, retaining continuous warm city tests for gameplay qualification.
Use the `complete-*` campaign for the aligned full-step timer (command submission,
simulate/fetch, ready-event synchronization and two compact completion transfers).
Earlier `file-*` and `single-*` captures are engine-step diagnostics. Large-case
memory qualification remains open: the initial-impact memcheck fails in topology
atomics on both the updated and saved pre-fix runtimes. Repeatability passes do
not waive this or the restored-versus-uninterrupted physical-verdict differences.
See the [failure investigation](qualification/optimization-next20-20260910/snapshot-large-20260911/investigation.md).


## Current flat-graph qualification (2026-09-11)

Candidate `8589185e659c8316b1828b7847b8780eb0f11006` is frozen under
`out/snapshot-finish-20260911/device-enabled-split/`. It replaces destruction
conditional graphs with GPU-enabled flat graphs and allocation grid barriers
with four ordered GPU phases. Full 52-case matched physical/timing qualification,
52-case normal asynchronous memcheck and the 600-tick ordinary idle/heavy A/B/A
are complete. The fix is retained for correctness/architecture, with no verified
speedup; possible small idle cost remains disclosed in the [warm report](qualification/optimization-next20-20260910/snapshot-finish-20260911/device-enabled-split/warm/README.md).
Main source is applied and runtime rebuilt; focused post-build correction memory
and four restored physical comparisons pass.
Installed SDK remains unchanged. The prior publication-only candidate
passes 52/52 asynchronous memory checks but fails the separate correction check.
This split candidate passes that correction check and the ordinary sleeping wall.
Do not use instrumented milliseconds as performance evidence.

Exact isolated build and focused correctness commands:

```bash
python3 out/snapshot-finish-20260911/device-enabled-split/build.py
python3 out/snapshot-finish-20260911/device-enabled-split/build-motion-test.py
python3 out/snapshot-finish-20260911/run-split-motion-screen.py
python3 out/snapshot-finish-20260911/run-split-native-gates.py
```

Those recorded scripts have fixed evidence destinations and have already run;
use new destinations for any changed implementation. The asynchronous full suite
uses no blocking-launch or synchronization-limit flags:

```bash
python3 tools/diagnostics/destruction-snapshot/run-suite.py out/NEW-flat-mem-suite \
  --structural-inputs out/snapshot-large-20260911/roundtrip-regressions \
  --city-inputs out/snapshot-large-20260911 \
  --binary out/snapshot-large-20260911/final-artifacts/native_destruction_snapshot_test \
  --artifacts out/snapshot-finish-20260911/device-enabled-split \
  --repetitions 2 --sanitizer memcheck \
  --allow-existing-graphics --allow-compute-pid 435374
```

Current matched A-before / B / A-after per scenario uses20 /20 /20 independent restores,
one full tick each. Every arm uses the same observation binary; all observation
readbacks, physical comparisons and restore work are outside the tick timer.
Persistent post-tick destruction state and load arrays must match exactly.
Derived bond forces use the existing `2e-4` scaled component numerical bound
from the resident analytic force regression; rigid physical state uses
the existing position/velocity/orientation bounds. This is stricter than comparing
fracture counts alone. The report preserves separate controls, descriptive intervals,
means/maxima, 120/60 Hz misses, command/simulate-fetch/completion stages and excluded
restore time. Shared-GPU variation remains a qualification limit.

```bash
python3 tools/diagnostics/destruction-snapshot/run-matched.py out/NEW-flat-matched \
  --manifest out/snapshot-finish-20260911/device-enabled-split-mem-suite/manifest.json \
  --binary out/snapshot-finish-20260911/physical-ab-probe-v3/serialization-probe \
  --baseline-artifacts out/snapshot-large-20260911/stable-rebuilt-artifacts \
  --candidate-artifacts out/snapshot-finish-20260911/device-enabled-split \
  --candidate-commit 8589185e659c8316b1828b7847b8780eb0f11006 \
  --allow-existing-graphics --allow-compute-pid 435374
```

Run one GPU candidate at a time. Do not rebuild or modify frozen arms during a
campaign. A performance-neutral correctness-qualified result may be retained as
an enabling improvement only with explicit evidence of no material scenario
regression; it is not a speedup. Continuous trajectory qualification remains
separate from fresh-cache restored ticks.


The first flat-graph matched campaign's new force-byte checker also rejected an
unchanged A/A control. See the [measured checker correction](qualification/optimization-next20-20260910/snapshot-finish-20260911/device-enabled-split/force-comparison-correction/README.md).
Use the current comparator with finite-value and existing scaled-force checks;
do not change the exact material/topology checks or solver tolerances. The first
12 cases are preserved/rechecked; the remaining 40 use
`out/snapshot-finish-20260911/device-enabled-split/remaining-manifest.json` and
output `out/snapshot-finish-20260911/split-matched-remaining/`.

The native demo now defaults to ordinary APIs with sleeping enabled. Historical
Direct GPU control tests explicitly pass `--standard-scene 0` to preserve their
frozen workload. Verify the current default itself without mode/sleep overrides:

```bash
flock -n out/destruction-ab.lock env \
  LD_LIBRARY_PATH="$PWD/out/snapshot-finish-20260911/device-enabled-split" \
  python3 tools/scripts/run-destruction-penetration-regression.py out/NEW-default-wall \
  --exercise-demo-defaults \
  --binary out/snapshot-finish-20260911/ordinary-default-demo/native_destruction_demo \
  --expected-runtime out/snapshot-finish-20260911/device-enabled-split/libPhysXDestructionGpuRuntime_64.so
```


### Final flat-graph local build and verification

The 52-case result is in
`qualification/optimization-next20-20260910/snapshot-finish-20260911/device-enabled-split/matched/`.
The corresponding 20-candidate-sample suite takes 1,051.10 seconds of harness
wall time, including 579.41 seconds of restoration excluded from the measured
58.69 seconds of full ticks. Scenario weighting makes this total unsuitable as
an application speedup claim. Continue to run both restored semantic cases and
continuous ordinary/sleeping idle/heavy trajectories.

```bash
.toolchains/build-env/bin/cmake --build out/sdk-release --target PhysXDestructionGpuRuntime -j6
python3 out/snapshot-finish-20260911/verify-local-promotion.py
```

The local verification freezes the rebuilt runtime with the qualified unchanged
GPU activity module, runs normal asynchronous native correction memcheck, then
checks two restored ticks each for dense interconnections, a cold ladder,
11,100-chunk impact and 113,664-chunk late debris against the qualified candidate
physical outputs. The script uses the existing GPU admission/provenance wrapper;
it never times restoration. It reuses completed capture receipts and creates separate observation captures
when needed; failed checker attempts remain preserved. See the final report for hashes and commands. No SDK install is implied.

## Reusable physical snapshot workspace (2026-09-11)

Use the qualified storage-reuse path described in
[the reset report](qualification/optimization-next20-20260910/snapshot-reset-20260911/README.md).
All 52 cases ×20 still execute one complete tick per independently reconstructed
physical input. Reuse allocation capacity and immutable decoded input only;
invalidate contact history, solver guesses and certificates. Restore, physical
validation and teardown remain outside `complete_step_ms`, with separate timers.
The first allocation is reported separately from the following 19 resets.
Do not claim warm-gameplay performance from these fresh-cache restored ticks.

Build the normal local runtime/demo and a matching probe (output paths must be new):

```bash
.toolchains/build-env/bin/cmake --build out/sdk-release \
  --target PhysXDestructionGpuRuntime -j6
.toolchains/build-env/bin/cmake --build out/destruction-sdk \
  --target native_destruction_demo -j6
python3 tools/diagnostics/destruction-snapshot/build-probe.py out/NEW-reset-probe
```

The helper constructor now optionally accepts PhysX's pinned allocator callback;
rebuild matching consumers. Its default remains the normal allocator. The replay
harness supplies a bounded pool. No install step is part of this workflow.

Correctness and asynchronous memory (same 52 inputs; two ticks each):

```bash
python3 tools/diagnostics/destruction-snapshot/run-suite.py out/NEW-reset-mem \
  --structural-inputs out/snapshot-large-20260911/roundtrip-regressions \
  --city-inputs out/snapshot-large-20260911 \
  --binary out/NEW-reset-probe/serialization-probe \
  --artifacts physx/bin/linux.x86_64/release \
  --repetitions 2 --sanitizer memcheck \
  --allow-existing-graphics --allow-compute-pid 435374
```

Repeated benchmark, input/output checks and the structured cost report:

```bash
PHYSX_SNAPSHOT_DUMP_OBSERVATIONS=first \
python3 tools/diagnostics/destruction-snapshot/run-suite.py out/NEW-reset-full20 \
  --structural-inputs out/snapshot-large-20260911/roundtrip-regressions \
  --city-inputs out/snapshot-large-20260911 \
  --binary out/NEW-reset-probe/serialization-probe \
  --artifacts physx/bin/linux.x86_64/release \
  --repetitions 20 --allow-existing-graphics --allow-compute-pid 435374
python3 tools/diagnostics/destruction-snapshot/report-replay-costs.py out/NEW-reset-report \
  --suite out/NEW-reset-full20 \
  --reference qualification/optimization-next20-20260910/snapshot-finish-20260911/device-enabled-split/matched/report.json
```

The report checks every scenario against the qualified physical reference and
preserves all samples, stage timings, spread, maxima, deadline misses and retained
memory. It rejects mixed artifacts, sanitizer timings and missing/failed cases.
Use the existing continuous ordinary/sleeping wall and matched idle/heavy commands
above for application qualification. Do not redirect a wall wrapper's stdout into
its own `OUTPUT.log`; use a different driver-log name.

The full frozen reset result is 388.529 s harness /58.473 s ticks /127.149 s
restore. The 52-case asynchronous memory campaign passes. Large repeated resets
remain 371–468 ms (idle/impact/late debris), exceeding some full ticks. Next profile
immutable destruction-asset preparation and runtime allocation lifecycle; record
setup gains separately from application gains. No new N-series experiment or
continuous speedup is credited for this work.

## Thirty-second candidate screen

Start routine optimization experiments with the frozen seven-case light preset:
bridge, long chain, dense 3D connectivity, an explicit command, 11,100-chunk first
impact, 113,664-chunk intact idle, and 113,664-chunk late debris. It runs 40 complete
ticks using fixed per-case repetition counts. It targets **30 seconds for one arm**,
including input hashing, startup, restore, checks, teardown and report generation.
Use the [profile](tools/profiles/destruction-snapshot-light.json) and
[calibration/coverage report](qualification/optimization-next20-20260910/snapshot-light-20260911/README.md).

```bash
python3 tools/diagnostics/destruction-snapshot/run-suite.py out/NEW-light \
  --preset light \
  --structural-inputs out/snapshot-large-20260911/roundtrip-regressions \
  --city-inputs out/snapshot-large-20260911 \
  --binary out/snapshot-reset-20260911/local-probe/serialization-probe \
  --artifacts out/snapshot-reset-20260911/local-artifacts \
  --allow-existing-graphics --allow-compute-pid 435374
```

Select matching candidate probe/runtime artifacts after relevant builds. Run one
arm at a time; compare a frozen baseline and candidate with this same preset.
An A/B pair takes about one minute, or A/B/A about90 seconds. Shared-GPU clocks
and load can make the budget drift; every run records actual wall time and
`within_target` without silently dropping cases or samples.

The preset retains physical import re-export equality, same-input repeatability,
convergence/damage/motion checks, and expected fracture/correction/cluster counts.
It disables only large diagnostic observation dumps. `report.md` / `report.json`
include per-scenario full-step mean, peak, median, spread, phase timings, deadline
misses, active work and raw-sample paths. `suite-summary.json` records total wall
time. A failed physical/counter gate exits unsuccessfully. Being within the wall
budget is independent of correctness.

This is a **screening gate**, not acceptance. Three samples in the largest cases
cannot establish a small speedup or tail-latency improvement. Reject clear quality
failures; prioritize promising changes and expand uncertain signals. Before
retaining a candidate, run the full52-case ×20 benchmark and cross-build physical
comparison from the reusable-workspace section above (with observation dumps),
plus the full asynchronous memory and continuous ordinary/sleeping physical and
matched idle/heavy gates. Keep all52 cases, tolerances and full-step scope unchanged.
The full preset remains the default; the light preset disallows case/repetition
overrides so candidates cannot quietly change its workload.

## Per-scenario hardware-counter atlas

Use the isolated profiling probe and the existing saved scenario manifest. The
normal benchmark probe contains no enabled profiling markers. Only the first of
two independent restored ticks is analyzed; the second checks repeatability.
Nsight Systems captures through normal process exit to drain CUDA activity;
analysis selects only the first tick. Missing CUDA-event warnings reject the
capture. The four declared NVTX ranges must all be closed and bounded. Generic
NVTX collection warnings are retained explicitly in the report.
Full-step NVTX ranges exclude restore and validation. Profiled wall times never
enter the unprofiled performance reports.

```bash
python3 tools/diagnostics/destruction-snapshot/build-probe.py out/NEW-profile-probe --profile
python3 tools/diagnostics/destruction-snapshot/profile-suite.py out/NEW-light-counters \
  --manifest out/snapshot-light-20260911/full-manifest/manifest.json \
  --preset light --counter-mode pm \
  --binary out/NEW-profile-probe/serialization-probe \
  --artifacts out/snapshot-reset-20260911/local-artifacts \
  --allow-existing-graphics --allow-compute-pid 435374
python3 tools/diagnostics/destruction-snapshot/profile-suite.py out/NEW-full-counters \
  --manifest out/snapshot-light-20260911/full-manifest/manifest.json \
  --preset full --counter-mode pm --reuse out/NEW-light-counters \
  --binary out/NEW-profile-probe/serialization-probe \
  --artifacts out/snapshot-reset-20260911/local-artifacts \
  --allow-existing-graphics --allow-compute-pid 435374
python3 tools/diagnostics/destruction-snapshot/report-profile-suite.py \
  out/NEW-full-counters out/NEW-counter-atlas \
  --baseline qualification/optimization-next20-20260910/snapshot-reset-20260911/report.json
```

The PM mode reuses the existing external CUPTI collector at
`out/destruction-pm-sampling-20260910/final-build/collect`. Rebuild it if absent with
`python3 tools/diagnostics/destruction-pm-sampling/build.py` followed by that output
path. The wrapper records its binary hash. It runs Nsight Systems CUDA/NVTX tracing
alongside device-wide hardware sampling at100 microseconds. It checks target exit,
physical repeatability, overflow, complete draining, clock alignment and sample
coverage. GPU process ownership includes the collector and its simulation child;
foreign workloads remain explicitly recorded, never stopped.

Each case retains `.nsys-rep`, SQLite, PM raw CSV, clock anchors, decoded JSON,
commands, tool versions, input hashes and loaded-module hashes. Hardware sampling
includes other GPU contexts. Per-kernel interior records exclude flagged/boundary
samples; very short kernels can have no usable samples. PM elapsed resident-warps
percentage is not NCU achieved active occupancy. FP64 pipeline utilization,
eligible-warps and detailed warp stalls are unavailable from this four-counter
single-pass PM configuration.

For supported cases, `--counter-mode full` adds targeted Nsight Compute full
metrics for the dominant family and stress if different. `--counter-mode hardware`
requests a smaller hardware set. With the historical2026.3.0 collector, this source captures detailed
non-fracturing cases, but the native first-fracture case aborts under NCU full
kernel replay, hardware-only kernel replay, and hardware-only application replay
with `free(): invalid next size (fast)`. Preserve those reports as **unqualified**;
use the qualified2025.3.1 collector below for detailed fracture counters. PM
remains separate sampled coverage. Do not repeat those unchanged failed
captures or modify production simulation to accommodate the profiler. A standalone
profiler report without successful physical continuation is not acceptance.

Use the atlas to rank hypotheses, not to promise gains from fixed occupancy or
bandwidth thresholds. CUDA API durations may include GPU waits; overlapping kernel
and API durations are not additive. Time without traced GPU activity includes CPU
work, submission gaps and tracing overhead. Cold restored first-tick uploads can
differ substantially from warm continuous gameplay; verify a proposed saving on
both workloads before accepting an application optimization.


### Qualified Nsight Compute collector and physical counter gate

The detailed counter workflow now pins **Nsight Compute2025.3.1**, already installed
at `/opt/nvidia/nsight-compute/2025.3.1/ncu`. Version2026.3.0 aborts inside its
injected worker library on the fracture/correction path even with no matching
kernel and no hardware collection. Keep its failed reports as diagnostics; do not
change simulation behavior to make that version run. Exact corruption origin is
unresolved. The2025.3.1 path uses the same application/runtime/input artifacts.

`profile-suite.py` now defaults to `--counter-mode full`. Pass `--counter-mode pm`
explicitly for device-wide sampling. All full-counter captures enable physical
observation dumps outside the tick and compare against the qualified unprofiled
reference; reuse requires matching collector identity and a passed physical
comparison. Detailed coverage is the dominant kernel family plus component stress
if different, first two matching launches per family, for every scenario.

```bash
python3 tools/diagnostics/destruction-snapshot/profile-suite.py out/NEW-light-ncu \
  --manifest out/snapshot-light-20260911/full-manifest/manifest.json \
  --preset light --counter-mode full \
  --ncu-binary /opt/nvidia/nsight-compute/2025.3.1/ncu \
  --binary out/snapshot-counters-20260911/probe/serialization-probe \
  --artifacts out/snapshot-reset-20260911/local-artifacts \
  --physical-reference out/snapshot-reset-20260911/prepared-full20 \
  --reuse out/snapshot-counters-20260911/full-drained \
  --allow-existing-graphics --allow-compute-pid 435374
python3 tools/diagnostics/destruction-snapshot/profile-suite.py out/NEW-full-ncu \
  --manifest out/snapshot-light-20260911/full-manifest/manifest.json \
  --preset full --counter-mode full --reuse out/NEW-light-ncu \
  --binary out/snapshot-counters-20260911/probe/serialization-probe \
  --artifacts out/snapshot-reset-20260911/local-artifacts \
  --physical-reference out/snapshot-reset-20260911/prepared-full20 \
  --allow-existing-graphics --allow-compute-pid 435374
python3 tools/diagnostics/destruction-snapshot/audit-counter-suite.py \
  out/NEW-full-ncu out/NEW-full-ncu/qualification.json
python3 tools/diagnostics/destruction-snapshot/report-profile-suite.py \
  out/NEW-full-ncu out/NEW-full-ncu-report \
  --baseline qualification/optimization-next20-20260910/snapshot-reset-20260911/report.json
```

For a newly built candidate, supply matching probe/runtime artifacts, matching
physical references and newly qualified timelines. Never reuse baseline counters
for changed code. Use a new output directory for every capture. An audit requires
all manifest scenarios, full metric fields, completed physical ticks, matched
modules/inputs and successful physical comparisons. The normal benchmark remains
separate and rejects profiled receipts. [Diagnosis and qualification](qualification/optimization-next20-20260910/ncu-fix-20260912/README.md).

## CPU and significant-kernel attribution (2026-09-12)

The user authorized reversible service/GPU recovery and rebooted the host.
All52 CPU scenarios now qualify, including the reduced-tracing city64-impact
retry and every city256 stage. Preserve the original faulted capture. The
other project's server was temporarily stopped for recovery/capture and its
restart configuration is private; never commit its environment. This session
permission supersedes the older no-service-interruption notes, not unrelated
permanent driver/toolkit or deployment changes.

Use the [current tier report](qualification/optimization-next20-20260910/end-to-end-attribution-20260912/coverage-tiers.md)
and [diagnosis](qualification/optimization-next20-20260910/end-to-end-attribution-20260912/README.md).
The52 CPU profiles preserve CPU samples, scheduling, complete GPU activity,
CUDA/OS caller stacks, native phase thread clocks and same-trace disjoint wall
accounting. Exact options and unresolved/throttled samples stay in each receipt.
GPU allocation/all-API tracing is separate (`--nsys-allocation-trace`); its removal
is not a proven explanation of the original firmware fault. Normal benchmark
binaries and all runtime libraries are unchanged.

```bash
python3 tools/diagnostics/destruction-snapshot/build-probe.py out/NEW-attribution-probe --profile
python3 tools/diagnostics/destruction-snapshot/test-attribution.py
python3 tools/diagnostics/destruction-snapshot/profile-cpu-suite.py \
  out/end-to-end-attribution-20260912/cpu-full --resume \
  --manifest out/snapshot-light-20260911/full-manifest/manifest.json \
  --binary out/end-to-end-attribution-20260912/probe/serialization-probe \
  --artifacts out/snapshot-reset-20260911/local-artifacts --allow-existing-graphics
python3 tools/diagnostics/destruction-snapshot/report-attribution-suite.py \
  out/end-to-end-attribution-20260912/cpu-full out/NEW-attribution-report
```

For a standalone CPU capture, use `run-probe.py --profiler nsys --nsys-cpu`
with the same binary/artifacts and a frozen replay prefix. Export its report:
`nsys export --type sqlite --output CAPTURE/trace.sqlite CAPTURE/trace.nsys-rep`.
Run `compare-observations.py REFERENCE CAPTURE CAPTURE/physical-comparison.json`
then `analyze-attribution.py CAPTURE`. Existing comparison outputs are immutable;
use a new output filename for a repeated audit. Do not subtract GPU profiler
intervals from unprofiled application milliseconds.

Archived2026.2.1 and2026.1.1 reproduce the2026.3.0 injection heap abort on fracture.
The stable2025.3.1 pin skips individual conditional nodes. Graph-level capture
works with **optional host analysis rules disabled**: otherwise the collector's
own process segfaults. The matching city25-impact control crashes with rules on;
rules off captures all18 expected graph invocations and passes physical checks.
This retains full hardware metrics but cannot supply individual conditional-node
or instruction-source metrics. Raw failed reports/core diagnostics remain local.

```bash
python3 tools/diagnostics/destruction-snapshot/profile-graph-suite.py \
  out/end-to-end-attribution-20260912/graphs-full --resume \
  --timeline-campaign out/ncu-fix-20260912/full \
  --manifest out/snapshot-light-20260911/full-manifest/manifest.json \
  --binary out/snapshot-counters-20260911/probe/serialization-probe \
  --artifacts out/snapshot-reset-20260911/local-artifacts \
  --reuse-pilot out/end-to-end-attribution-20260912/ncu-2025-graph-no-rules-pilot \
  --allow-existing-graphics
python3 tools/diagnostics/destruction-snapshot/profile-config-suite.py \
  out/end-to-end-attribution-20260912/configs-full --resume \
  --timeline-campaign out/ncu-fix-20260912/full \
  --manifest out/snapshot-light-20260911/full-manifest/manifest.json \
  --binary out/snapshot-counters-20260911/probe/serialization-probe \
  --artifacts out/snapshot-reset-20260911/local-artifacts \
  --threshold-ms 0.1 --coverage 0.99 --ncu-replay kernel --reuse-other-replay-mode
```

The ordinary-kernel supplement selects every family costing at least0.1ms,
plus enough ordinary families to cover99% of matched kernel duration together
with the graph tier. It captures the first and slowest observed
invocation at every distinct grid/block/shared-memory configuration. The common
invocation filter can select extras, which are explicitly audited. All original
invocation timings remain in Systems. This is representative configuration
coverage, **not all-invocation counter coverage**. Set `--threshold-ms 0` to
include every ordinary family, or use `profile-kernel-suite.py` for the existing
all-invocation selection/audit when the chosen collector supports those nodes.
Its99%-GPU-duration policy is a configurable coverage budget, not a diagnosis.
Graph-level and kernel-level counter totals must never be added together.

Continuous warm captures remain separate from restored physical-state ticks.
The following collects180 ordinary/sleeping ticks each for113,664-chunk idle and
heavy destruction, with unprofiled controls. CPU sampling at10million reference
cycles avoids the OS-throttling warnings observed at500,000; both sets are retained.

```bash
python3 tools/diagnostics/destruction-snapshot/profile-warm-suite.py \
  out/NEW-warm-attribution --sampling-period 10000000 \
  --binary out/destruction-sdk/reference/native_destruction_demo \
  --artifacts out/snapshot-reset-20260911/local-artifacts \
  --args-root out/end-to-end-attribution-20260912 --allow-existing-graphics
python3 tools/diagnostics/destruction-snapshot/analyze-warm-attribution.py CAPTURE
python3 tools/diagnostics/destruction-snapshot/report-attribution-tiers.py \
  out/end-to-end-attribution-20260912 \
  qualification/optimization-next20-20260910/end-to-end-attribution-20260912
```

`warm-reduced-sampling/` is the current continuous campaign. Native frame clocks
anchor the trace; timer-boundary time outside those anchors stays explicitly
unlocated. Per-tick physical work/convergence/correction counters match controls;
this is not a new body-pose/force equivalence test or candidate optimization.
The fixed20-sample full-suite and600-tick final acceptance gates still apply.
Do not call a tier complete until its campaign and inventory/physical audits pass.

Transfer census across all52 snapshots and continuous checkpoints (reuses existing traces):

```bash
python3 tools/diagnostics/destruction-snapshot/report-dataflow-suite.py \
  out/end-to-end-attribution-20260912 \
  qualification/optimization-next20-20260910/end-to-end-attribution-20260912
```

### Current counter interpretation and isolated CPU follow-up

```bash
python3 tools/diagnostics/destruction-snapshot/summarize-counter-configs.py \
  out/end-to-end-attribution-20260912 \
  qualification/optimization-next20-20260910/end-to-end-attribution-20260912
```

The report ranks ordinary families by matched Systems duration and preserves
metric units, missing values and invalid ratios. Representative ranges are not
weighted averages or complete-step savings. Graph counters remain a separate tier.

N20 requalification uses isolated statically linked A/B consumers in
`out/n20-requalification-20260912/build/`, with freshly compiled native
correctness consumers in `fresh-native/{A,B}`. The demo and plain probe control hashes
match the existing baseline; both sets now pass their fresh gates.
After all profiler jobs have ended, run serially on the admitted GPU:

```bash
python3 out/n20-requalification-20260912/run-native-gates.py --arm A
python3 out/n20-requalification-20260912/run-native-gates.py --arm B
```

These reuse16 discovered native commands and three normal asynchronous memory
gates per arm, preserving arguments, working directory and timeout.
`run-probe.py --test-args-json FILE` supplies exact test arguments without adding
a snapshot output argument. Both arms pass16 native commands and three normal
asynchronous memory checks. The corrected light/targeted/warm screens are recorded
in the current N20 follow-up report; all52 final comparison remains pending.
N10 operator caches already exist;
N02 residual-projection removal remains rejected and must not be requeued.

### Physical trait and instruction-level reviews

The following completed offline reviews reuse the qualified observations and
NCU report. Use fresh raw export filenames when repeating an instruction review.
They launch no simulation and provide no candidate speedup evidence.

```bash
python3 tools/diagnostics/destruction-snapshot/summarize-physical-traits.py \
  out/snapshot-reset-20260911/prepared-full20 \
  qualification/optimization-next20-20260910/end-to-end-attribution-20260912/report.json \
  qualification/optimization-next20-20260910/end-to-end-attribution-20260912
/opt/nvidia/nsight-compute/2025.3.1/ncu \
  --import out/ncu-fix-20260912/full/tower64-cold-counters-0/counters.ncu-rep \
  --page source --print-source cuda,sass --csv \
  > out/end-to-end-attribution-20260912/tower64-source.csv
/opt/nvidia/nsight-compute/2025.3.1/ncu \
  --import out/ncu-fix-20260912/full/tower64-cold-counters-0/counters.ncu-rep \
  --page source --print-source sass --csv \
  > out/end-to-end-attribution-20260912/tower64-sass.csv
python3 tools/diagnostics/destruction-snapshot/analyze-source-counters.py \
  out/ncu-fix-20260912/full/tower64-cold-counters-0 \
  out/end-to-end-attribution-20260912/tower64-source.csv \
  out/end-to-end-attribution-20260912/tower64-sass.csv \
  qualification/optimization-next20-20260910/end-to-end-attribution-20260912/tower-source-review.json
```

The instruction audit requires one captured kernel, checks every source-correlated
metric against the complete SASS export, and counts each instruction address once.
Ambiguous source locations and unmapped instructions remain explicit. Source stall
counts are not wall-time fractions. Physical cluster counts are post-tick traits,
not weighted solver work or exact operator-equivalence certificates.


### CPU-candidate light comparisons and the current capture gap

`run-matched.py --candidate-binary` selects the relinked CPU candidate while
`--binary` selects the control. This is required for static PhysX changes; swapping
GPU libraries alone cannot test them. Both binary/module identities are frozen
for the campaign and checked against each run receipt. Context setup, restore and
validation stay outside the complete-tick timer. Reports include convergence work,
phase means, full-step means/maxima, peak sample indices and exact budget misses.
`--control-repetitions` and `--candidate-repetitions` must match. Historical
10/20/10 results retain physical evidence but have unequal first-use weighting;
do not infer a small speedup from those timing means. Equal-length600-tick
continuous comparisons remain a separate valid protocol.

The seven frozen light inputs use40 ticks in EACH A-before/B/A-after cohort:
120 ticks total,80 control and40 candidate. Equal per-process lengths give
first-use ticks equal weight. Preserve all samples; do not warm up or discard
startup ticks. No physical input, case count or quality bound changes. The normal
40-tick single-arm light preset remains unchanged. The earlier84-tick matched
screen is timing-unqualified because its shorter controls over-weighted first use;
see `first-use-bias.json`.

```bash
python3 tools/diagnostics/destruction-snapshot/run-matched.py out/NEW-cpu-light \
  --manifest out/snapshot-light-20260911/confirmation/manifest.json \
  --use-case-repetitions \
  --binary out/n20-requalification-20260912/build/A/serialization-probe \
  --candidate-binary out/n20-requalification-20260912/build/B/serialization-probe \
  --baseline-artifacts out/snapshot-reset-20260911/local-artifacts \
  --candidate-artifacts out/snapshot-reset-20260911/local-artifacts \
  --candidate-commit b7918affda83942dba04e8626db696cca7fd283a
```

The old `run-in-counter-gap.py` signal-based coordinator has ended. The current
counter parent supports `--pause-file`: create the file, let the current capture
and audits finish, and require campaign status `paused` before starting a separate
GPU job. Deleting the file resumes collection. `run-full-after-counter.py` now
uses that boundary for the N20 full52 screen and resumes collection on success.
The restoration watcher remains responsible for returning desktop/server after
collection; it reuses an already completed screen instead of rerunning it.

N06's isolated build in `out/n06-granularity-20260912/build/{A,B}` changes only the
host launch policy: one cooperative block for complete problems through4096 nodes,
with the existing multilevel preconditioner and small-component threshold intact.
This separate N06a pilot is rejected, not combined with N20. Its build recipe is
`build-isolated.py`; `preparation.json` records commit
`c76c60678f42e8e62cdfab02d8b317df69b3fbdb`. Normal asynchronous memory and physical
checks pass; dense/tower full-step means worsen32.106→513.374ms and
109.121→2284.911ms. The original broader N06 decomposition remains untested.


Refresh the public artifact index after campaigns finish. It hashes public
receipts/build recipes, reuses the audited counter-report digests, and excludes
private recovery environments/crash data and actively changing campaign files:

```bash
python3 tools/diagnostics/destruction-snapshot/index-attribution-artifacts.py \
  out/end-to-end-attribution-20260912 \
  qualification/optimization-next20-20260910/end-to-end-attribution-20260912
```


The pinned2025 collector's recorded commands explicitly use cache control `all`
and clock control `none`; actual clocks remain driver-managed. Its local CLI
clock default is `base`, but the wrapper overrides it. The command audit in
`collector-policies.json` records the effective policy; inspect telemetry for
actual frequency. Counter times/cache behavior do not
replace normal unprofiled application measurements. For a concrete cross-kernel
cache hypothesis, use a separately declared application-replay/cache-control-none
pilot and original quality gates; do not change the whole atlas opportunistically.

### Resumable counter collection and current final-screen commands

The current39 qualified ordinary-counter cases include city64 initial-impact's
completed240-record capture recovered after its parent was paused. Recovery
requires matching binary, modules, inputs, full metric policy, selected
configurations, collector hashes and fault audit, then reruns counter inventory
and physical comparisons. Partial GPU captures remain failed attempts. No good
capture is overwritten or silently treated as qualified.

Remaining larger cases now pilot application replay because kernel replay's
memory-backup cost grew sharply with world size. The city25 pilot did not prove
application replay faster; keep per-case replay mode and collection duration.
The3600-second watchdog is a capture limit, not an application performance budget.

```bash
python3 tools/diagnostics/destruction-snapshot/profile-config-suite.py \
  out/end-to-end-attribution-20260912/configs-full --resume \
  --timeline-campaign out/ncu-fix-20260912/full \
  --manifest out/snapshot-light-20260911/full-manifest/manifest.json \
  --binary out/snapshot-counters-20260911/probe/serialization-probe \
  --artifacts out/snapshot-reset-20260911/local-artifacts \
  --coverage .99 --ncu-replay application --reuse-other-replay-mode \
  --watchdog-seconds 3600 \
  --pause-file out/end-to-end-attribution-20260912/counter-pause
```

Do not start a second parent when this command is already live. Create the pause
file to request a GPU gap; inspect `configs-full/campaign.json` until `paused`.
Deleting it resumes the next capture. Never use profiler timings for acceptance.

### Current isolated final gates and semantic confirmation (2026-09-12)

N20 now completes all52 physical A/B/A comparisons, with20 ticks in each process
and3,120 checked full ticks. Its final normal asynchronous memory suite uses:

```bash
python3 tools/diagnostics/destruction-snapshot/run-suite.py out/NEW-n20-full52-memcheck \
  --structural-inputs out/snapshot-large-20260911/roundtrip-regressions \
  --city-inputs out/snapshot-large-20260911 \
  --binary out/n20-requalification-20260912/build/B/serialization-probe \
  --artifacts out/snapshot-reset-20260911/local-artifacts \
  --repetitions 2 --sanitizer memcheck
```

The live instance is already owned by `out/n20-requalification-20260912/run-final-memory.py`;
do not start a second GPU job. It temporarily stops the paused counter parent,
then resumes it after this gate. CPU-only builds may accompany diagnostics;
all builds finish before any plain timing. The next serial screen coordinator
is `out/end-to-end-attribution-20260912/run-next-isolated-screens.py`.

Fixed semantic frames can be extracted from completed ordinary native runs:

```bash
python3 tools/scripts/report-destruction-semantic-frames.py \
  out/n20-requalification-20260912/warm180-confirm \
  --manifest out/n20-requalification-20260912/warm180-confirm/semantic-manifest.json \
  --run-manifest out/n20-requalification-20260912/warm180-confirm/campaign.json \
  --output out/NEW-n20-warm180-semantic.json
```

The confirmation has four independent processes per A-before/B/A-after stage,
180 ticks each, heavy only, using the original event predicates. Every work and
convergence counter is compared to the corresponding600-tick control prefix.
Corresponding trajectory events are not identical-input restored snapshots.
Keep the600-tick means/peaks/deadlines alongside them. Stage values are native
command, integrated physics/destruction, and completion—not kernel-only time.

N15 is rejected after its seven-case light screen and existing physical/memory
gates: small compiler-resource reductions produce no verified full-step gain.
Current full scenario evidence: [N20](qualification/optimization-next20-20260910/end-to-end-attribution-20260912/n20-final.md),
[N15](qualification/optimization-next20-20260910/end-to-end-attribution-20260912/n15-result.md).

Exact N20 final comparison (the existing queue driver runs this once at a paused
boundary; use a fresh output when repeating):

```bash
python3 tools/diagnostics/destruction-snapshot/run-matched.py out/NEW-n20-full52 \
  --manifest out/snapshot-light-20260911/full-manifest/manifest.json \
  --binary out/n20-requalification-20260912/build/A/serialization-probe \
  --candidate-binary out/n20-requalification-20260912/build/B/serialization-probe \
  --baseline-artifacts out/snapshot-reset-20260911/local-artifacts \
  --candidate-artifacts out/snapshot-reset-20260911/local-artifacts \
  --candidate-commit b7918affda83942dba04e8626db696cca7fd283a
python3 tools/diagnostics/destruction-snapshot/test-matched.py
python3 tools/diagnostics/destruction-snapshot/test-attribution.py
```

Default equal20/20/20 counts mean3,120 full ticks across52 cases. Current corrected
light, targeted confirmation, reversed impact repeat, two trials of600 warm ticks
per stage/scenario and CPU attribution are in
[the N20 follow-up](qualification/optimization-next20-20260910/end-to-end-attribution-20260912/n20-followup.md).
The large restored-debris gain is not a warm gameplay gain; no N20 retention yet.

N15's separate isolated build applies anchored/free templates only to its copied
stress sources. Existing numerical oracle consumers are freshly built against
each arm's exact runtime stress object; the motion-mode oracle compiles its
included implementation from that arm's source copy. No main runtime mutation:

```bash
python3 out/n15-anchored-20260912/build-isolated.py
python3 out/n15-anchored-20260912/build-oracles.py
```

These recipes refuse to overwrite their output directories. Build status and
commands are recorded under `build/build.json` and `oracles/build.json`; GPU
qualification remains separate. Finish builds and heavy analysis before timings.
