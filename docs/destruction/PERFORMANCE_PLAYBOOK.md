# PhysX destruction performance playbook

Start here to reproduce performance investigations. Commands are run from the
`physx-2` repository root. Use fresh output names each time; example names below
are placeholders for a unique experiment. Do not overwrite earlier evidence.

Read [measurement rules](PERFORMANCE_MEASUREMENT.md) before interpreting results,
[findings](PERFORMANCE_FINDINGS.md) before selecting another experiment, and the
[dated handoff](PERFORMANCE_HANDOFF.md) before changing implementation. Existing
architecture documents are indexed there. The repository skill is
[physx-destruction-performance](../../.agents/skills/physx-destruction-performance/SKILL.md).

## 1. Establish the exact environment and code

```sh
git status --short
git rev-parse HEAD
nvidia-smi --query-gpu=name,uuid,driver_version,utilization.gpu,memory.used,temperature.gpu --format=csv
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
/usr/local/cuda/bin/nvcc --version
df -h .
```

This machine's native target is RTX 4090/sm_89, CUDA 12.8.93. Recheck rather than
assuming the toolchain is unchanged. The runtime target explicitly uses
`PX_DESTRUCTION_CUDA_ARCHITECTURES=89`; the upstream CMake cache's generic CUDA
architecture value alone does not describe that target.

Do not stop foreign jobs/services. Timing runs must be sequential, without
concurrent builds, sanitizers, rendering or another GPU workload. The runner
records GPU processes, utilization and clocks; clocks are observed, not locked.
A matching binary hash does not guarantee matching thermal/scheduling conditions.

In the current Codex container, default shell execution can fail with
`bwrap: No permissions to create new namespace`. Use the permitted escalation
mechanism for the same authorized workspace command; this is not a compiler or
physics failure. Do not change machine security or services to work around it.

## 2. Build once; keep all ABI consumers matched

For existing build directories, preserve their configured renderer/profiler
settings and incrementally rebuild only affected targets:

```sh
cmake --build out/sdk-release --target PhysX PhysXGpu PhysXDestructionGpuRuntime -j4
cmake --build out/destruction-sdk --target native_destruction_consumers -j3
```

For stress changes, also build the focused test binaries:

```sh
cmake --build out/destruction-sdk --target gpu_resident_stress_test gpu_resident_stress_3d_test gpu_resident_motion_modes_test -j4
```

Fresh checkout/build (broader and slower; do not repeat for each kernel edit):

```sh
python3 tools/scripts/build-destruction-sdk.py --jobs 4 --cuda-architectures 89 --gpu-renderer
```

The renderer is needed for the frozen collision/render audit, not untraced
performance. This helper also builds/imports reference targets and installs the
SDK. See [BUILD.md](BUILD.md) for package consumers; those compatibility targets
are not alternative native production backends.

Important artifacts:

| Artifact | Role |
|---|---|
| `physx/bin/linux.x86_64/release/libPhysXGpuActivity_64.so` | This checkout's GPU PhysX module; the name is **not** `libPhysXGpu_64.so` |
| `physx/bin/linux.x86_64/release/libPhysXDestructionGpuRuntime_64.so` | Integrated CUDA destruction runtime |
| `out/destruction-sdk/reference/native_destruction_demo` | Integrated native executable, despite its historical `reference/` output directory |
| `out/destruction-sdk/reference/native_gpu_collision_test` | Internal lifecycle/collision tests |
| `out/sdk-release/diagnostics/component-work/libPhysXDestructionGpuRuntime_64.so` | Intrusive diagnostic runtime, never the production timing library |

Changes to internal virtual interfaces can change ABI across PhysX, GPU runtime
and statically linked consumers. Never mix an old demo/test with newly rebuilt
modules. `LD_LIBRARY_PATH` can silently select a diagnostic library; inspect
`ldd` and capture hashes. Prefer isolated matching build outputs over in-place
library swaps. Never replace a library while a capture is running.

## 3. Correctness before performance claims

Run tests appropriate to the change, not every suite for every edit:

```sh
ctest --test-dir out/destruction-sdk -R '^blast_stress_gpu_resident_(analytic|3d|motion_modes)$' --output-on-failure
ctest --test-dir out/destruction-sdk -R '^physx_native_gpu_(collision_preparation|contact_properties|retained_registry|contact_lifetime_exhaustion|initialization_failure|connectivity_owner)$' --output-on-failure
python3 tools/scripts/run-destruction-penetration-regression.py out/EXPERIMENT-wall-quality
```

The penetration command is a **10-second heavy quality audit**, not a timing
benchmark. It records render/physics motion, verifies real entry/exit clearance,
retention and topology identity, and writes `quality.json`. Frozen fixture:
444 chunks, 896 bonds, one projectile, 398 supported/retained chunks, 46 detached,
199 broken bonds and 43 final clusters. The golden file is
`tools/profiles/wall-penetration-quality.json`; its exact bond-identity gate is
explicitly **not qualified**. Do not update the golden or loosen assertions to
accept a refactor/optimization.

For GPU memory/lifetime changes, use the relevant fixture separately:

```sh
compute-sanitizer --tool memcheck --error-exitcode 97 out/destruction-sdk/reference/native_gpu_collision_test --contact-properties
compute-sanitizer --tool initcheck --error-exitcode 97 out/destruction-sdk/reference/native_gpu_collision_test --contact-properties
```

A pre-existing rigid-to-shape radix-sort initcheck issue is recorded in the
[handoff](PERFORMANCE_HANDOFF.md). Memcheck passing does not imply initcheck
passing. Compare matching baseline/candidate fixtures before assigning blame;
do not suppress the error or present the suite as clean.

## 4. Short matched peak screen

The ordinary rejection screen uses **256 buildings, 113,664 chunks, 229,376 bonds,
256 simultaneous aerial projectiles**, 180 steps/3 simulated seconds per run:

```sh
python3 tools/scripts/run-destruction-timing.py out/EXPERIMENT-burst --config tools/profiles/destruction-scaling.json --case impacts-256 --trials 2 --seconds 3 --gate-only --phase-scopes --report-output qualification/EXPERIMENT-burst
```

This runs a separate warm-up, two untraced trials and one separately instrumented
phase replay. Every step of each measured trial remains, including insertion,
first CUDA work and first fracture. Warm-up does not remove the first step from
any measured run. The gate targets 8 ms; exit **2** is expected while that gate
or the required duration is unmet. Check `campaign.json`:

- `status: complete`: physics capture completed; inspect report gate failures.
- `status: failed`: inspect `error`, run exit code and corresponding log. A partial
  CSV is not a successful benchmark.
- `status: running`: verify its actual process/session; a file alone is not proof
  the job is alive. Poll a confirmed handle; do not restart after mere timeout.

Generate an explanatory opportunity report from the same capture:

```sh
python3 tools/scripts/destruction-peak-opportunities.py qualification/EXPERIMENT-burst/report.json.gz --case impacts-256 --output qualification/EXPERIMENT-peaks
```

Compare baseline and candidate **one identical case at a time**:

```sh
python3 tools/scripts/compare-destruction-candidates.py --baseline qualification/BASELINE-burst/report.json.gz --candidate qualification/CANDIDATE-burst/report.json.gz --output qualification/EXPERIMENT-comparison
```

The peak-ranking command accepts current gate reports as well as historical
full reports. Add `--capture-root PATH_TO_ARCHIVED_CAMPAIGN` when the original
run directories have moved; frame/summary hashes are checked before ranking.

The comparator archives raw samples and rejects altered samples/configurations.
Do not reuse its output directory with different inputs. Physical counter
history differences require investigation; iteration-count differences are
reported separately. Matching counters are necessary evidence, not a proof of
trajectory equivalence. Interleave fresh control/candidate arms when practical;
within one runner invocation, workload cases are interleaved across trials.

## 5. Sustained destruction capacity, including rubble

The launch-capacity configuration keeps the same 256-building scene and all
256 projectiles. It compares a simultaneous burst with launches spread over
10 simulated seconds (25.6 scheduled launches/s, quantized to 1/60-second steps):

```sh
python3 tools/scripts/run-destruction-timing.py out/EXPERIMENT-capacity --config tools/profiles/destruction-launch-capacity.json --trials 2 --seconds 15 --gate-only --phase-scopes --report-output qualification/EXPERIMENT-capacity/timing
python3 tools/scripts/report-destruction-launch-capacity.py out/EXPERIMENT-capacity/campaign.json --output qualification/EXPERIMENT-capacity
```

Run the second command after capture completion even if the first exits 2 for
its gate. It validates all launches, convergence, correction limit, fracture
totals, sample hashes and timing closure. `capacity.md/json` show complete peaks,
actual broken bonds, net new clusters, rolling one-second destruction rates,
peak work, selected phase samples and late rubble. This reporter currently
expects this exact fixture and at least 15 seconds; do not use it for arbitrary
world sizes without updating its validation and selected phase steps.

Changing launch cadence changes physical history, often total breakage. Report
it as a **capacity comparison**, never an implementation speedup. To find a
capacity boundary, vary one dimension, retain all steps, increase load
geometrically then refine between passing/failing cases. Do not assume
monotonicity. A short passing interval is not a sustainable limit. Retain the
original simultaneous case; do not replace it with an easier schedule.

Other versioned cases in `destruction-scaling.json`: `world-4/16/64/144/256`
(one unchanged through-wall impact in a larger world) and
`impacts-4/16/64/256` (simultaneous bombardment). Ordinary free-body controls in
[NATIVE_SCALING_PROFILE.md](NATIVE_SCALING_PROFILE.md) isolate different work;
they do not approximate dense rubble contacts.

## 6. Candidate qualification and endurance

After short screens and physical tests establish a candidate worth qualifying:

```sh
python3 tools/scripts/run-destruction-timing.py out/EXPERIMENT-long --config tools/profiles/destruction-scaling.json --case impacts-256 --trials 5 --seconds 60 --gate-only --report-output qualification/EXPERIMENT-long
```

For the first frozen 8 ms gate, use the same command with
`--config tools/profiles/wall-penetration-timing.json --case penetration`.
Five 60-second runs must retain **every** measured complete-step peak. Report
8 ms and 1000/60 ms separately; the reporter's exit gate remains 8 ms.
A timing pass alone is not completion: reports currently retain
`quality_endurance_qualified: false`.

The full 10-minute endurance gate also needs repeated impacts, support removal,
settling/wakeups, removal/reinsertion and handle reuse. Merely passing
`--seconds 600` to the current bombardment demo does **not** exercise that whole
lifecycle. No completed comprehensive endurance campaign is claimed. Implement
and validate the missing commands/generator before calling this gate satisfied.

## 7. Deeper diagnostics only when they change the next decision

`--gate-only --phase-scopes` needs no CUPTI. Use it first. For actual kernel/API
activity, the repository pins a separate CUPTI SDK; this does not replace the
CUDA compiler/toolkit:

```sh
python3 tools/scripts/fetch-destruction-cupti.py out/deps/cupti-13.2.86
python3 tools/scripts/build-destruction-sdk.py --jobs 4 --cuda-architectures 89 --gpu-renderer --gpu-profiler --cupti-root out/deps/cupti-13.2.86
```

Reuse an already verified CUPTI directory instead of downloading again. The
fetcher needs network access and refuses an existing output directory. For an
existing consumer build, set `NATIVE_GPU_CUPTI=ON` and
`NATIVE_GPU_CUPTI_ROOT` to that absolute verified path and rebuild the demo.
Omitting `--gate-only` from the runner adds separate full-duration CUPTI captures;
keep duration short while investigating a specific peak. Require complete,
undropped activity before drawing timeline conclusions.

The component diagnostic target is:

```sh
cmake --build out/sdk-release --target PhysXDestructionGpuWorkDiagnostic -j4
```

For the current **Vibe-land consumer**, use the component reporter that maps
one or two evaluations to each accepted tick:

```sh
python3 tools/scripts/report-vibe-component-work.py \
  out/vibe-component-work-accepted-20260908/256-buildings \
  out/vibe-anchored-residual-20260908/candidate-a \
  out/vibe-component-work-accepted-20260908/256-buildings-components.jsonl.gz \
  out/NEW-component-report
python3 tools/scripts/test-vibe-component-work.py
```

The capture runner and runtime/executable hashes are preserved with
[the report](../../qualification/vibe-component-work-accepted-20260908/report.md).
It uses the instrumented consumer executable and the separate diagnostic runtime;
its CPU readbacks/waits and wall times are **not production performance**. A
4-building smoke capture must validate counters before the full 256-building job.
The runner only stops the verified owned server when it has zero players and
restores it afterward; never substitute another service PID. Use fresh capture
paths, validate GPU isolation, and match builds as described above.

The diagnostic now includes polynomial adjacency visits and inverse-application
counts. Subphase counters accumulate in explicitly shared CTA storage and publish
once per CTA, rather than contending on global atomics each iteration. Missing,
inconsistent or out-of-parent subphase totals reject the report. Full raw census
artifacts stay at hashed workspace paths; selected raw records and all solve
summaries are included in the repository report.

**Known tool gap:** `run-destruction-component-capture.py` and its component-work
reporter expect the older embedded-frame report schema. Current gate reports
have a list under `runs` and raw frames in the capture directories; blindly
feeding the new report can fail *after* an expensive diagnostic simulation.
Adapt/validate the reader before using it on current captures. The historical
[component report](../../qualification/component-work-bombardment-256/report.md)
remains useful evidence for its recorded runtime, not current millisecond
attribution. Its work counters omit later polynomial-preconditioner traversals.

## 8. Preserve and regenerate evidence

Keep `campaign.json`, all referenced run directories, logs, frame/launch CSV.gz,
summary/graph JSON, phase/activity files when captured, reports, configuration,
source patch (including untracked new source files), Git revision and actual
binary/library hashes. HEAD alone does not identify WIP. Generated reports are
not a replacement for their raw inputs.

```sh
python3 tools/scripts/report-destruction-timing.py out/EXPERIMENT-burst --output qualification/EXPERIMENT-burst-regenerated
```

Regeneration does not rerun physics and can still exit 2 for a failed gate.
Do not delete an active output directory to free space. Compress only after
completion (the runner does so losslessly). `--resume` is for an identical
recorded configuration/artifact set after a real failed/interrupted run; it is
not a way to mix code versions or reinterpret a live job.

The latest launch-capacity capture is archived under
`qualification/destruction-launch-capacity/capture`, including all eight runs,
logs and the original campaign manifest. `source.patch`, the new private include
snapshot and `source-snapshot.json` beside it preserve the producing WIP. To
regenerate that archived evidence without a GPU simulation:

```sh
python3 tools/scripts/report-destruction-timing.py qualification/destruction-launch-capacity/capture --output out/ARCHIVE-review/timing
python3 tools/scripts/report-destruction-launch-capacity.py qualification/destruction-launch-capacity/capture/campaign.json --output out/ARCHIVE-review
python3 tools/scripts/destruction-peak-opportunities.py qualification/destruction-launch-capacity/timing/report.json.gz --case stagger-256-10s --capture-root qualification/destruction-launch-capacity/capture --output out/ARCHIVE-review/peaks-staggered
```

The first command still exits 2 because the historical performance gate failed;
that is expected evidence, not a reason to rerun physics. Other historical
reports may still depend on ignored `out/` inputs; inspect their manifests before
assuming they can be regenerated after cleanup.

When changing reporting logic, run its relevant checks independently of GPU
measurement:

```sh
python3 tools/scripts/test-destruction-timing.py
python3 tools/scripts/test-native-phase-analysis.py
python3 tools/scripts/test-destruction-peak-opportunities.py
```


## Fast wall rejection tiers

Use the same frozen scenario duration and physical inputs; `--steps` caps only
execution. In particular, the demo preserves the original launch window rather
than deriving a different command schedule from the shortened run.

```bash
python3 tools/scripts/test-native-prefix.py
python3 tools/scripts/run-destruction-penetration-regression.py out/EXPERIMENT-early --tier early --reference out/AUDITED-MODE-MATCHED-REFERENCE --expected-runtime /absolute/candidate/libPhysXDestructionGpuRuntime_64.so
python3 tools/scripts/run-destruction-penetration-regression.py out/EXPERIMENT-screen --tier screen --reference out/AUDITED-MODE-MATCHED-REFERENCE --expected-runtime /absolute/candidate/libPhysXDestructionGpuRuntime_64.so
```

Use the matching isolated `LD_LIBRARY_PATH` and add `--standard-scene` for Direct
GPU off/sleep on. Prefix reference captures must contain `quality.json`, physical
settings and artifact attestations; the historical Direct GPU reference must pass
the existing frozen identity gate. An ordinary-mode physical reference does not
resolve the known difference from the historical golden. Never use one mode as
the other mode's reference or regenerate a golden to accept a change.

The early tier runs 32 steps, compares topology identities, projectile/chunk/COM
positions with the existing 1 mm tolerance, correction/stress pass counts and
convergence. The screen tier runs 128 steps and additionally applies the existing
rear-clearance and two-second hole checks. The default full tier retains the
600-step exact identity/count oracle. A prefix pass is not full qualification.

This implementation compares after the bounded run and reports its first observed
difference. It does not yet stop a native advance at the first online failure or
implement a diagnostic ring. Execution and validation durations are recorded
separately. These motion-observed captures are never performance measurements.
