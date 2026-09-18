# One building, one projectile: why the maximum step was 9.82 ms

Measured against corrected mass-frame implementation `53f7f16f`. No engine,
material, solver or fidelity settings changed for this investigation.

The video's slowest step was **step 82, simulation time 1.38333 s**, when the
projectile first fractured the building. It broke **780 of 896 bonds**, changed
one logical cluster into **377 clusters**, and ran **one correction**. The accepted
step's active-body count was already 378 (fragments, retained owner and projectile
lifecycle accounting). This is a simultaneous first-fracture spike, not a typical
step and not a video-encoding measurement.

## Repeat measurements

All repeats used the same 444 chunks, 896 bonds, projectile, 10-second duration,
60 Hz timestep and one-correction limit. Motion tracing, audits, state recording
and rendering were disabled. Runs were sequential. No external compute process
was listed before the campaign; GPU clocks were not locked and these are not
60-second isolated throughput qualifications.

| Capture | Mean step | Minimum | Maximum / first impact |
|---|---:|---:|---:|
| Original diagnostic video | 1.203 ms | 0.571 ms | 9.824 ms |
| No tracing, repeat 1 | 1.021 ms | 0.461 ms | 8.548 ms |
| No tracing, repeat 2 | 1.034 ms | 0.487 ms | 9.072 ms |
| Host scopes + CUDA stage events | 1.096 ms | 0.556 ms | 8.992 ms |
| Host scopes + full CUPTI activity | 1.332 ms | 0.673 ms | 10.779 ms |

Both untraced repeats averaged approximately **0.52–0.54 ms before impact** and
**0.99 ms during the last two seconds of rubble contacts**. Sleeping remains
disabled in this demo. Every repeat broke 784 bonds in total and used five
corrected steps. Full trajectories were not compared in these timing runs.

Detailed tracing was disabled in the original video. The breakdown below is a
measured reproduction of its first impact, not a retrospective decomposition of
exactly the original 9.824 ms. CUPTI visibly increases elapsed time, particularly
the stress stage, so its timings are shown separately.

## First impact: additive wall-time accounting

Host-scope capture, **8.992 ms total**. All rows below are disjoint; the final
unscoped remainder is explicit rather than being attributed to physics kernels.

| Operation | First impact | Mean across 600 steps |
|---|---:|---:|
| Ordinary trial and remaining scene/task work, excluding checkpoint | 1.123 ms | 0.86748 ms |
| Checkpoint submission | 0.010 ms | 0.00835 ms |
| Submit destruction pipeline | 0.306 ms | 0.12499 ms |
| Wait for submitted GPU destruction work | 3.195 ms | see parent below |
| Reserve fragment bodies | 0.589 ms | see parent below |
| Remaining finish/reservation bookkeeping | 0.00583 ms | see parent below |
| GPU body initialization, including submission/completion | 0.093 ms | 0.00039 ms |
| Prepare collision bindings | 0.137 ms | 0.00267 ms |
| Prepare correction bodies | 0.140 ms | 0.00284 ms |
| Apply CPU ownership/lifecycle bindings | 0.471 ms | 0.00121 ms |
| Restore/install checkpoint motion | 0.042 ms | 0.00017 ms |
| Reset contact caches | 0.006 ms | 0.00007 ms |
| Corrected collision/solve pass | 2.759 ms | 0.01243 ms |
| Accept correction | 0.116 ms | 0.00083 ms |
| **Total** | **8.992 ms** | **1.09578 ms** |

The combined finish/wait/reservation mean is 0.07437 ms. Fragment reservation
itself includes 0.102 ms request readback, 0.443 ms CPU body allocation,
0.022 ms binding upload, 0.008 ms publication and 0.015 ms remaining bookkeeping.

## What is inside the GPU wait?

Consecutive CUDA-event intervals on the destruction stream in the same host-scope
capture:

| GPU-stream stage | First impact |
|---|---:|
| Build contact loads | 0.0512 ms |
| Stress solve | **3.1293 ms** |
| Material/damage evaluation | 0.0195 ms |
| Connectivity, mass and candidate preparation | 0.1177 ms |
| Commit and rebuild stress topology | 0.0308 ms |

These stream intervals include scheduling/dependency gaps. **They overlap the
submission and wait rows above; do not add them to the 8.992 ms.** The CPU starts
waiting while the GPU is still executing the already-submitted work. Eliminating
the host wait call alone would not eliminate that work or its dependency on the
fracture decision. The CPU reservation bridge currently requires the result;
a device-resident lifecycle could remove that host round trip.

The solve reports **191 iterations**, not the configured maximum of 8,192. The
CUPTI capture executed **996 stress/stress-topology kernels**, including 194 calls
each of matrix-vector multiply, direction update, solution update, convergence
reduction and retirement. Conditional CUDA-graph execution groups iterations and
includes guarded tail iterations. There is no claim that every kernel represents
an additional physical iteration or correction.

The dominant stress kernels took, in the CUPTI capture:

| Kernel | Calls | Summed GPU execution |
|---|---:|---:|
| Matrix-vector product | 194 | 0.939 ms |
| Update direction | 194 | 0.484 ms |
| Update solution | 194 | 0.477 ms |
| Convergence reduction | 194 | 0.337 ms |
| Retirement/convergence control | 194 | 0.321 ms |
| All stress / stress-topology kernels | 996 | **2.592 ms** |

There were also 394 `memset32` executions (0.389 ms) across this step. The full
traced stress stream interval was 4.591 ms. These small kernel counts, serial
iteration dependencies and gaps identify a concrete scheduling/fusion target;
they do not establish a memory-bandwidth or arithmetic roofline.

## What is inside ordinary physics and correction?

Host scope coverage below is grouped using interval unions, subtracting overlap
with earlier groups. It measures observed wall intervals, not GPU execution.
The trial and correction columns are separate parts of the 8.992 ms capture.

| Observed host work | Trial | Correction |
|---|---:|---:|
| Contact-manager allocation/registration | 0.188 ms | 0.247 ms |
| Broad/narrow-phase completion and callbacks | 0.226 ms | 0.344 ms |
| Island insertion/generation | 0.046 ms | 0.138 ms |
| Dynamics/partition/solver submission | 0.104 ms | 0.295 ms |
| Lost-contact dispatch | 0.004 ms | 0.004 ms |
| **Observed union** | **0.568 ms** | **1.028 ms** |

These groups do not cover every scheduler, driver or task interval. In particular,
1.028 ms must not be presented as the entire CPU cost of correction.

CUPTI provides an independent execution view across **both trial and correction**:

| GPU kernel category | First impact GPU execution sum |
|---|---:|
| Constraint preparation, solving and integration | 0.492 ms |
| Broad phase | 0.085 ms |
| Narrow phase/contact lifecycle | 0.038 ms |
| Body/shape updates | 0.012 ms |
| Shared physics utilities, principally sorts | 0.199 ms |
| Destruction connectivity/mass/slots | 0.050 ms |
| Destruction material/damage | 0.008 ms |

Kernel category sums are not additional wall-time costs and can overlap.
The corrected pass spans **2.787 ms** in the CUPTI run, with **0.781 ms of GPU
activity** and **2.006 ms with no recorded GPU activity from this process**.
Thus most of its elapsed time is outside GPU kernel/copy execution. That remainder
includes CPU bookkeeping, driver/task scheduling, dependencies and tracing;
it is not all useful CPU computation and is not proof the whole GPU was idle.

For the full traced impact, 10.780 ms of timestamped simulation interval contains
4.225 ms GPU activity and 6.555 ms without GPU activity from this process. CPU
process time is 12.463 core-ms because multiple threads run; it cannot be added
to wall time. The original 9.824 ms run was not traced at this level.

## Priorities supported by these measurements

1. **Fuse the small-island stress iteration work on the GPU**, maintaining the
   current convergence criteria and fracture verdict. CUDA graphs already avoid
   a host decision per iteration, but still dispatch many small kernels. This
   addresses the approximately 3.13 ms stress-stream interval at first impact.
2. **Finish GPU-resident fragment and collision lifecycle ownership.** CPU body
   allocation, shape ownership updates, contact registration and island bridges
   remain measurable here. Fixing COM ownership did not remove those bridges.
3. **Reduce correction scheduling and reuse validated collision work.** The
   measured GPU execution is much smaller than the correction wall interval;
   optimizing only contact math misses substantial cost.
4. **Qualify sleeping for steady rubble.** It is disabled in this capture, so
   the approximately 1 ms late-rubble cost is still processing awake work.

The checkpoint copy is only 480 bytes and 0.000896 ms of GPU copy execution
in the traced first impact. It is not the cause of the 9 ms spike. GPU mass,
connectivity and material kernels also are not its dominant cost. No optimizations
or fidelity changes were made in this timing investigation.

## Reproduce and inspect

- Commands and capture conditions: `out/single-impact-timing-20260906/campaign.json`.
- Phase rows and CUDA events: `out/single-impact-timing-20260906/phases/`.
- CUPTI activity, names and validated overlap accounting:
  `out/single-impact-timing-20260906/gpu/native.profile.json` and neighboring files.
- Full result: `qualification/single-impact-timing-20260906.json`.

```bash
python3 tools/scripts/report-single-impact-timing.py \
  out/single-impact-timing-20260906 \
  --output qualification/single-impact-timing-20260906.json
```
