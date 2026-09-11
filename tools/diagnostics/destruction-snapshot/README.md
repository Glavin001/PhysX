# Native destruction snapshots

Start with the [complete 52-scenario catalog](../../../qualification/optimization-next20-20260910/snapshot-scenarios.md):
28 original structural/rigid-body cases plus 24 added city cases. The original
bridge, cantilever, chains, flying-body, ladder, panel and tower fixtures remain.
`run-suite.py` selects all 52 cases, or either group, with the same independent
single-tick protocol. Historical continuation measurements remain separately
labeled; the older large-city runner covers only the added 24 cases.

Run the complete saved-input catalog (use a new output directory):

```bash
python3 tools/diagnostics/destruction-snapshot/run-suite.py out/NEW-snapshot-suite \
  --structural-inputs out/snapshot-large-20260911/roundtrip-regressions \
  --city-inputs out/snapshot-large-20260911 \
  --binary out/snapshot-large-20260911/final-artifacts/native_destruction_snapshot_test \
  --artifacts out/snapshot-large-20260911/final-artifacts \
  --repetitions 20 --allow-existing-graphics --allow-compute-pid 435374
```

`--group structural` selects the original 28; `--group city` selects the 24
cities. Repeat `--case NAME` to select specific cases. `--manifest-only` validates
and hashes every selected saved input without using the GPU. The runner records
the stimulus explicitly, runs one GPU process at a time, retains failed cases,
and returns failure if any case fails. Restore and output validation remain
outside the full-tick timer. No source trajectory is re-simulated during replay.

The [public API contract](../../../docs/destruction/SNAPSHOT.md) documents export,
restore, ownership and command boundaries. The source here is also built as
`native_destruction_snapshot_test` and registered as `physx_native_destruction_snapshot`.

`run-probe.py` keeps unique raw outputs, GPU identities, module hashes and optional
sanitizer logs. `build-probe.py` retains the isolated existing-flags build path.
The V20/schema7 suite compares two independently restored worlds, checks exact physical destruction
re-export, corrupt/truncated/missing-ID rejection, pending-command rejection,
material/topology equality, sleep/wake state, free-fall acceleration, exactly-once commands and ten continuation ticks. Solver/contact caches are rebuilt; allocation history is not saved. Large cold/warm structures
reuse `native_scenario_geometry.h`. Timings are short diagnostic continuations,
not independent A/B acceptance samples. Actual results are in the
[qualification record](../../../qualification/optimization-next20-20260910/snapshot-export-restore.md).

Generate the complete scenario table from successful runs:

```bash
python3 tools/diagnostics/destruction-snapshot/report-results.py \
  qualification/optimization-next20-20260910/snapshot-v20-results \
  out/snapshot-20260911/physical-state-v20/final-suite
```

The JSON retains every full-step sample, first-tick samples, export costs and
paired restore/validation costs. Failed historical runs are not relabeled.

Replay saved fixture files in a **new process**, one complete tick per independent
restore (the `.pxbin` and `.destruction` suffixes are added to the prefix):

```bash
python3 tools/diagnostics/destruction-snapshot/run-probe.py out/NEW-file-replay \
  --binary out/destruction-sdk/reference/native_destruction_snapshot_test \
  --artifacts physx/bin/linux.x86_64/release --require-complete-shapes \
  --replay-prefix out/snapshot-20260911/physical-state-v20/final-suite/building-fragmented \
  --repetitions 20 --allow-existing-graphics --allow-compute-pid 435374
```

The wrapper records both input hashes. `replay.json` stores each restore time,
complete tick time, material/correction/convergence counters and differences
from the first independently restored result. No capture-prefix simulation is
run. Use `--projectile-impulse` only when that explicit next stimulus is intended;
it applies the regression's angular setter and 0.1 x impulse to stable body102,
inside the timed tick. The replay helper uses this probe's fixed ordinary GPU,
TGS, gravity/filter/capacity settings; general applications recreate their own
scene configuration before calling the public import API.

## Native city snapshots (large-scene expansion)

`tools/profiles/destruction-snapshot-large.json` adds 24 source states across
25, 64 and 256 buildings: 11,100 / 28,416 / 113,664 authored chunks, with
22,400 / 57,344 / 229,376 bonds. Eight states at each scale cover intact idle,
airborne shots, historical first impact, immediately after impact, cascading
fracture, later loaded fragmentation, three-second debris and ten-second debris.
The last state is not assumed asleep. These reuse the original native benchmark
and `destruction-ordinary-ab.json` materials/solver settings, without synthetic
pre-cut bonds. Source steps are frozen; restored outcome counters remain the
measure of actual work.

Build the corrected runtime and affected harnesses (no engine ABI change):

```bash
.toolchains/build-env/bin/cmake --build out/sdk-release \
  --target PhysXDestructionGpuRuntime -j6
.toolchains/build-env/bin/cmake --build out/destruction-sdk \
  --target native_destruction_demo native_destruction_snapshot_test native_gpu_correction_body_test -j6
```

Capture each continuous source history once; then benchmark only one full tick
per independently restored file, twenty repetitions:

```bash
python3 tools/diagnostics/destruction-snapshot/run-large-suite.py capture out/NEW-large \
  --binary out/destruction-sdk/reference/native_destruction_demo \
  --artifacts physx/bin/linux.x86_64/release \
  --allow-existing-graphics --allow-compute-pid 435374
python3 tools/diagnostics/destruction-snapshot/run-large-suite.py replay out/NEW-large \
  --binary out/destruction-sdk/reference/native_destruction_snapshot_test \
  --artifacts physx/bin/linux.x86_64/release --repetitions 20 \
  --run-prefix complete \
  --allow-existing-graphics --allow-compute-pid 435374
```

`--case city256-fragmented-loaded` selects one replay. `--run-prefix screen
--repetitions 2` creates a separate correctness screen. Each run directory must
be new; failures remain recorded and the campaign continues to other cases.
The `.scene` sidecar preserves the fixture's capacity, contact reporting and
native contact preparation policy; the `.metadata.json` records source scale,
step and ownership. All four file hashes are recorded. Public destruction state
still contains only physical state/settings, not disposable execution caches.
Capture happens before the source step, outside its timer, after prior commands
are accepted. The simultaneous projectile wave is already present in every
bombardment snapshot; no future launch command is omitted from these inputs.
Twenty samples characterize observed variation, not systematic GPU interference.


The file replay reference is retained as CPU observations of every saved object's
pose, velocities, mass/inertia/COM and role, plus GPU-exported bond health,
topology and damage. The first GPU world is released before the next restore.
This bounds GPU memory to one simulated world plus the empty context template;
it does not reduce the captured scene's capacities or simulation work. Timed
steps precede observation/readback and comparison. Complete sampled runs with
comparison failures return nonzero and retain `passed:false` plus all timings.
Use `report-large-suite.py CAMPAIGN REPORT_DIRECTORY --run-prefix complete` for
the final `complete-*` campaign. Earlier `file-*` and `single-*` campaigns stopped
their timer at fetch; their measurements are retained as engine-step diagnostics.
The final timer also includes the native application's ready-event synchronization,
two compact status transfers and completion checks. Command submission,
simulate/fetch and completion are disjoint intervals in the JSON report.
Large output observation and comparison remain outside the tick timer.
The earlier two-world `file-*` campaign also exhausted GPU memory in two cases;
the CPU reference removes that duplicate-world requirement. Large-case memcheck
reports a topology error on both updated and saved pre-fix runtimes; it is not
waived. See the [investigation](../../../qualification/optimization-next20-20260910/snapshot-large-20260911/investigation.md).

Generate the complete report, including failed comparisons:

```bash
python3 tools/diagnostics/destruction-snapshot/report-large-suite.py \
  out/NEW-large qualification/NEW-large --run-prefix complete
```

Focused correctness and sanitizer commands used for this expansion (choose new
output directories; a nonzero exit is a recorded failure):

```bash
python3 tools/diagnostics/destruction-snapshot/run-probe.py out/NEW-correction \
  --binary out/destruction-sdk/reference/native_gpu_correction_body_test \
  --artifacts physx/bin/linux.x86_64/release --watchdog-seconds 600 \
  --allow-existing-graphics --allow-compute-pid 435374
python3 tools/diagnostics/destruction-snapshot/run-probe.py out/NEW-roundtrips \
  --binary out/destruction-sdk/reference/native_destruction_snapshot_test \
  --artifacts physx/bin/linux.x86_64/release --require-complete-shapes \
  --watchdog-seconds 600 --allow-existing-graphics --allow-compute-pid 435374
python3 tools/diagnostics/destruction-snapshot/run-large-suite.py replay out/NEW-large \
  --binary out/destruction-sdk/reference/native_destruction_snapshot_test \
  --artifacts physx/bin/linux.x86_64/release --repetitions 2 \
  --case city25-initial-impact --run-prefix mem --sanitizer memcheck \
  --allow-existing-graphics --allow-compute-pid 435374
LD_LIBRARY_PATH="$PWD/physx/bin/linux.x86_64/release" \
python3 tools/scripts/run-destruction-penetration-regression.py out/NEW-wall \
  --binary out/destruction-sdk/reference/native_destruction_demo \
  --expected-runtime "$PWD/physx/bin/linux.x86_64/release/libPhysXDestructionGpuRuntime_64.so" \
  --standard-scene --sleeping 1 --tier full
```

PID 435374 is the specifically recorded pre-existing server for this campaign,
not a reusable blanket allowance. Inspect current GPU ownership before a new
run and list only the identities actually accepted for that session.
