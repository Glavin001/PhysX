# Native destruction phase profiling

The native destruction path emits optional `GpuDestruction.*` events through
PhysX's existing `PxProfilerCallback`, including release builds. The standalone
demo can collect them without an external profiler:

```sh
out/destruction-sdk/reference/native_destruction_demo \
  --grid 16 --waves 1 --seconds 3 --stress-iterations 2048 \
  --profile-phases 1 --output out/recordings/native-profile-new
python3 tools/scripts/analyze-native-destruction-phases.py \
  out/recordings/native-profile-new \
  --output out/recordings/native-profile-new/phase-summary.json
```

Use a fresh output directory. Profiling defaults off. The collector requires an
unused profiler callback, and must outlive the scene so aborted correction tasks
can finish their events during teardown. Other consumers can install their own
standard callback. These scopes add no CUDA synchronization, alter no physical
settings, and do not change the correction limit. Callback overhead is included
in reported simulation time when profiling is enabled.

`native.phases.csv` contains one row per completed phase: timestep, event name,
context, whether it spans threads, host wall duration, and whether the timestep
was accepted. Completed rows from an incomplete run are marked unaccepted. The
collector pairs opaque event tokens across worker threads and owns buffered event
names through SDK module teardown. The analyzer rejects missing/duplicate phases,
incomplete/unconverged steps, excess correction passes, inconsistent correction
counts and overlapping totals that exceed the measured simulation interval.

## Interpretation

These are **host wall-clock intervals, including GPU waits**, not CUDA kernel
timings. Work submitted asynchronously can finish inside a later measured wait.
Do not label `finishAndReserve` as pure stress-kernel time or infer GPU occupancy
from these measurements.

| Phase | Work included |
| --- | --- |
| `submit` | Contact/pose extraction submission and CUDA stress/topology submission; any implicit waits |
| `finishAndReserve` | Completion wait for submitted stress/material/topology work, compact allocation readback, CPU reservation and returned indices |
| `initializeReserved` | GPU pool growth/initialization and corresponding CPU update bookkeeping |
| `collisionBindings` | GPU collision-ownership preparation |
| `correctionBodies` | GPU correction-body preparation |
| `applyBindings` | Compact metadata readback and internal CPU ownership/query updates |
| `restoreInstall` | GPU checkpoint restore and child/retained body installation, plus CPU dirty-state cleanup |
| `correctedCollisionSolve` | Entire task-graph continuation from correction scheduling to corrected finalization |
| `refilter` | CPU collision/contact invalidation and bound-refresh queuing; **nested inside** `correctedCollisionSolve` |
| `acceptCorrection` | GPU topology/material/motion acceptance and private reservation acceptance |

Never add `refilter` to `correctedCollisionSolve`; the former is already included
in the latter. The analyzer reports their difference separately. Ordinary trial
collision/solve, checkpointing, remaining PhysX work and event overhead appear
in the unmeasured remainder of `physics_step_ms`. No CPU observation or rendering
work is included in the physics interval.

## Measured large-scene result

`out/recordings/native-scale-113664-profiled-20260906` completed 180 steps with
113,664 chunks, 229,376 bonds and 252 launched projectiles. All stress results
converged, and 56 steps used exactly one internal correction. It reached 89,923
clusters and broke 185,011 bonds, matching the earlier short unprofiled run's
endpoint counts. This does not establish identical chaotic trajectories.

Mean wall time **among corrected steps**:

| Work | Mean ms |
| --- | ---: |
| CPU refilter/contact invalidation | 70.00 |
| Rest of corrected collision/solve continuation | 217.86 |
| Ownership application | 17.46 |
| Stress/topology completion plus reservation | 8.25 |
| GPU body initialization | 0.13 |
| Collision-binding preparation | 0.11 |
| Correction-body preparation | 0.23 |
| Restore/install | 0.57 |
| Acceptance | 0.37 |
| Submission | 0.52 |

The complete corrected continuation averages 287.87 ms, including refiltering.
Worst full simulation step was 750.78 ms; all 56 corrected steps missed 16.67 ms.
The whole-run median of 0.54 ms is dominated by the initial intact interval and
must not be presented as active-destruction performance. These are shared-GPU,
three-second diagnostic runs, not isolated or sustained performance qualification.

The immediate optimization target is collision/correction work. Further split
measurement is needed to separate GPU work from CPU interaction creation and
scheduling within the corrected continuation. Selective contact/geometry reuse
still requires validity checks and comparison with the full correction path;
these measurements do not justify omitting any physical work.

The scale capture includes the phase CSV, validated summary, exact executable
and GPU module hashes, source patch and collector source. The final collector
additionally copies event names for safe incomplete-step module teardown. A
fresh small capture validates that change; an intentionally unconverged run
exits incomplete, emits only unaccepted phase rows, and writes no completed
summary. A duplicate-row negative check is rejected by the analyzer. Three
native suites (allocation, resimulation and publication) pass with profiling off.
Existing reference/fidelity failures and the intermittent bounds test remain
open; the full suite was not repeated for this diagnostic change.

## CPU ownership follow-up

See [GPU ownership](GPU_OWNERSHIP.md) for the inherited CPU collision machinery,
our compatibility bridge, and the GPU-compacted owner update. Optional
`GpuDestruction.detail.*` events now cover allocation, interaction registration,
island insertion and other CPU tasks during the corrected continuation. These
intervals can overlap and must not be summed as independent elapsed phases.
