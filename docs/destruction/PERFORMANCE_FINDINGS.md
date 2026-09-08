# Performance findings and experiment memory

Snapshot: **2026-09-08**. This file preserves conclusions and their limits, not a
claim that the complete native architecture or real-time goal is finished.
Revalidate against current source/runtime before applying them. See the
[playbook](PERFORMANCE_PLAYBOOK.md) for commands and the
[handoff](PERFORMANCE_HANDOFF.md) for outstanding implementation work.

## CPU synchronization and activity rollback are different costs

New explicit profiling scopes separate the GPU-completion/readback wait,
parallel CPU wake/sleep status tasks, query membership updates, activity
checkpoint/restore, and GPU sleep-transition submission. The generated report
uses interval unions for parallel worker wall time, validates both pass receipts,
and preserves unknown GPU-transfer attribution rather than calling a wait DMA time.

One isolated diagnostic: **256 buildings / 113,664 chunks / 229,376 bonds /
768 projectiles / 30 seconds / 1,800 steps**, Direct GPU OFF, sleeping ON,
max one correction and two stress evaluations. At largest replay (step 725,
37,655 bodies / 24,209 awake), the replay interval is **16.925 ms**:

- Readback completion wait: **0.001422 ms** during replay. Most work has already
  completed when this particular boundary is reached; this does not measure
  total DtoH transfer duration or upstream waits.
- CPU body-status workers: **0.858771 ms** wall union during replay.
- CPU query membership: **0.583708 ms** during replay.
- CPU activity restore: **2.260473 ms** during replay; checkpoint earlier in
  the tick is **1.313478 ms**.
- GPU sleep-transition CPU wall scope: **0.283077 ms** during replay, including
  waits and submission. These intervals cannot all be added as critical-path cost.

The largest combined body-readback wait is early step 82: **0.632789 ms**
across both passes (367 bodies / 108 awake). The complete-step peak in this
instrumented run is **134.017 ms**, step 385 (22,874 bodies / 17,273 awake).
This instrumentation-only change establishes no performance gain or regression.
[Generated CPU report](../../qualification/native-cpu-sync/cpu-sync.md),
[GPU restore report](../../qualification/native-cpu-sync/report.md).

Source audit confirms `afterIntegration` currently runs before the destruction
verdict on both passes. Query mirror updates are observation work, but body
status changes feed PhysX island readiness and sleep semantics. Native CPU
activity rollback restores those scheduler decisions after a rejected trial.
Removing only a synchronization call cannot delete the underlying dependency.
The architectural next step is provisional GPU activity/ownership with a single
accepted CPU observation commit, preserving wake propagation, support/stress
inputs, freeze/unfreeze transitions, and immediate post-fetch queries. Do not
substitute optimizing the CPU rollback loop for that migration. Deferring query
membership alone also needs accepted delta reconciliation; a rejected trial's
freeze/unfreeze list cannot simply be discarded because the second list is a
delta, not a full final-state snapshot.

Validation: nine focused correction/sleep/query tests, frozen 10-second
444-chunk/896-bond/one-projectile penetration golden, seven phase analyzer tests,
and four new CPU reporting tests pass. Ordinary-mode golden discrepancy and
full Vibe-land integration remain open as previously recorded.

## Native sleeping scene: second fracture evaluation and contact report deletion

The new policy evaluates stress/fracture after corrected physics as well as
before it, with at most two physics and two stress evaluations per tick.
Additional final-pass fragments inherit corrected end-of-tick motion. See
[implementation and qualification](POST_CORRECTION_FRACTURE.md).

A default inherited from the external demo requested CPU contact reports even
though the native demo had no contact callback. Pending actor-pair reports
blocked correction contact-pair reuse. Removing those unused requests retains
physical collision solving and internal GPU impulse consumption.

Matched native settings, 256 buildings / 113,664 chunks / 229,376 bonds, 767 shots
launched within 12 seconds: two untraced runs per arm, both using the new stress
policy. Complete mean/worst changed from **175.274 / 355.506 ms** to
**59.420 / 118.007 ms**. Candidate has zero reuse fallbacks; chaotic counter
histories differ, with more total broken bonds. Controlled tests and golden
penetration pass separately. [Generated comparison](../../qualification/post-correction-performance/comparison.md).

Two 30-second runs include all 768 projectiles: means **47.12 / 50.12 ms**, peaks
**118.469 / 143.404 ms**, up to 40,926 bodies and 26,039 awake. These improve on
the descriptive Vibe-land work bands but do not establish an equal-input engine
speedup or a 60 Hz result. [Workload comparison](../../qualification/post-correction-no-reports-long/vibe-comparison/comparison.md).

A separate 30-second diagnostic isolates CUDA rewind/install. At its largest
replay (15.090501 ms, 15,733 bodies / 12,019 awake), GPU checkpoint restore is
0.018240 ms and fragment/owner installation is 0.010240 ms. CPU scheduling and
rigid collision/solve remain inside the replay interval. These GPU intervals
can overlap its beginning; do not subtract them blindly or call the remainder
pure GPU solver time. [Generated correction cost](../../qualification/post-correction-gpu-cost/report.md).

Remaining bottleneck: the two GPU stress evaluations dominate the optimized
large-scene instrumented peak. The standard-scene wall still differs from the
Direct-GPU golden: supported 400 versus 398, final clusters 41 versus 43.
Current ordinary topology signature matches its historical ordinary fixture;
CPU/GPU queries, real entry/exit holes and render/collision alignment pass.
The golden remains unchanged and its failure is retained, not waived.

## Earlier capacity evidence changes the priorities

Same scene/physical settings: **256 buildings, 113,664 chunks, 229,376 bonds,
256 aerial projectiles**, 1/60 timestep, maximum one correction, sleeping and
crushing disabled. Two untraced **15-second / 900-step** runs per schedule;
separate warm-ups and instrumented replays. Complete time includes commands,
physics, destruction, correction and mandatory completion, excluding rendering.

| Schedule | Complete mean across runs | Worst complete step | Broken bonds per run | Net new clusters per run |
|---|---:|---:|---:|---:|
| Simultaneous launches | 22.068 ms | 53.780 ms | 62,674 | 13,911 |
| Launches spread over 10 s | 24.082 ms | 37.965 ms | 66,480 | 14,399 |

Neither passes every-step 60 Hz. This is a workload change, not a code speedup.
Staggering reduces the largest burst but increases average cost and total
fracture. Peak rolling one-second actual breakage is 57,666 bonds for the burst
and 7,462 for the staggered schedule; those windows also miss real time. No
maximum sustainable real-time destruction rate has been established.

Selected **separate instrumented** evidence on those same workloads:

- Burst step 82: 5,376 awake bodies; 28,160 broken bonds; ownership/lifecycle
  17.11 ms, correction 27.95 ms, nested CUDA stress 7.64 ms. CPU fragment/contact
  lifecycle is a major mass-fracture opportunity.
- Stagger step 702: 14,670 awake bodies; 86,278 active stress nodes / 134,814
  active stress bonds; 81 broken bonds. CUDA stress **23.31 ms**, ownership
  **0.53 ms**, correction **4.75 ms**. Sustained capacity also requires a major
  stress improvement; removing ownership alone cannot reach the deadline.
- Stagger step 840: no broken bonds and no correction; CUDA stress still
  **20.85 ms**, with 14,909 awake bodies and 134,227 active stress bonds.
  “No fracture” does not mean “no structural computation.” Validated reuse may
  matter here, but cannot be enabled solely from that observation.

[Generated capacity report](../../qualification/destruction-launch-capacity/capacity.md)
contains every run, per-second destruction/work, peak counters and phase samples.
The corresponding [timing report](../../qualification/destruction-launch-capacity/timing/report.md)
contains full gate evidence. All 3,600 untraced steps passed telemetry consistency,
convergence and one-correction checks; that is not trajectory/endurance proof.

## Earlier simultaneous-burst evidence and uncertainty

Frozen short screen: **256 buildings / 113,664 chunks / 229,376 bonds / 256 shots**,
two **3-second / 180-step** untraced runs plus a phase replay, same physical
settings as above. One restored control has mean/worst **16.717 / 53.603 ms**.
Another control with matching demo/GPU/runtime hashes reached **58.579 ms**.
Do not claim a sub-millisecond win from one ordered run or use the smaller
control as the unique truth.

The [ranked code review](../../qualification/peak-investment-review/report.md)
assigns explicit, unvalidated removable fractions to measured exposures, accounts
for the next-slowest step becoming the peak and repeats the model with a second
control. Its fractions are planning hypotheses, not guaranteed savings or a
proved route to 8 ms. Ownership led both controls; stress and contact lifecycle
exchanged positions. Sustained staggered results above add another necessary
axis: stress dominates its late peaks.

## What is already present—do not propose it as missing

| Status | Mechanism | Important limit |
|---|---|---|
| ✅ | Exact GPU stress components, stable ordering and minimum-ID connectivity | Not equivalent to motion clusters or correction dependency islands |
| ✅ | Component-local resident iteration, independent convergence retirement and dynamic CTA work queue | The native path is not launching one kernel for every iteration |
| ✅ | Two-stage polynomial preconditioner in the current small-component path | Extra sparse work can offset iteration reduction; not a general multilevel small-component solver |
| ✅ | Unchanged local inverse retention and unaffected bond warm starts | General unaffected hierarchy retention is still incomplete |
| ✅ | Unchanged topology-generation bypass and unused recursive hierarchy-tail skip | Not general across-timestep settled-stress reuse |
| ✅ | GPU pre-solve connectivity/lifetime history preserved during storage growth | Initial bootstrap and CPU lifecycle deltas still exist |
| ✅ | Internal solved-contact load consumption, GPU topology/mass/motion and device views | CPU actor/shape/contact compatibility lifecycle remains |
| 🟡 | Persistent native GPU contact-property table | WIP prerequisite for GPU contact admission; no established peak improvement |
| ⬜ | Validated settled-island reuse across timesteps | Native API rejects general skipSettledIslands/skipStableUnconverged flags |
| ⬜ | Fully GPU-owned fragment/contact lifecycle, selective correction, sleep/joint/CCD qualification | Full intended architecture is not finished |

Detailed source-side/native comparisons and original source hashes are in
[OPTIMIZATION_INDEX.md](OPTIMIZATION_INDEX.md) and its JSON. That inventory has
older dated evidence; use this file's links for later experiments rather than
silently treating its historical performance numbers as current.

## Tried, rejected or reverted

The references below carry their own workload, settings and qualification
scope. Do not retry the same mechanism merely under a different name.

| Status | Experiment | What was learned / requirement before revisiting |
|---|---|---|
| ❌ | Four-stage polynomial | Fewer updates did not establish a whole-peak win. Additional preconditioner cost matters. See commit `ab30a85b` and its qualification artifacts. |
| ❌ | Partial shared cache, unscaled polynomial vector | Cache lookup/shared-storage cost; short screen did not establish improvement. Native tests alone were insufficient. |
| ❌ | Partial shared cache, scaled vector + CSR-local ordinals | Frozen wall passed; complete worst peak worsened in fresh controls. Local caching is not the same as making the full recurrence local. |
| ❌ | Colored symmetric sweeps | Numerical/work reduction did not qualify the implementation; consult [recorded rejection](../../qualification/colored-sweep-evaluation/report.html). |
| ❌ | Stable dead-adjacency compaction | Removed dead visits but did not establish complete-peak improvement. Consult [adjacency experiment](../../qualification/adjacency-evaluation/report.html). |
| ❌ | Shared multilevel responses, compensated FP32 inverse, exact-zero inverse bypass | Prior rejected experiments; inspect commits `a62d9eec`, `22aa605f`, `bffeb767` and recorded tests before repeating. |

For the shared-cache experiments, [the preserved patch/rejection notes](../../qualification/polynomial-shared/README.md)
record both variants. On the **256-building / 113,664-chunk / 229,376-bond /
256-shot, two 3-second runs per arm** fresh comparison, baseline mean/worst was
**16.717 / 53.603 ms**; scaled-cache candidate **16.755 / 56.664 ms**. No proven
speedup. Shared storage increased from 560 to 25,136 bytes/block; the scaled
variant increased registers from 96 to 128. These are compiler resource counts,
not measured occupancy. Candidate sanitizer/endurance qualification was not
completed. Both cache variants were reverted from production.

## Implementation lessons to retain

- Final GPU ownership needs lifecycle redesign, not just moving arithmetic.
  CPU `NpRigidDynamic`, `BodySim`, shape/query and contact-manager records still
  have consumers. Device-selected indices do not mean CPU allocation is gone.
- Geometry and motion are separate: immutable chunk collision identity persists
  while cluster motion ownership changes. Fix rendering/COM/reparenting through
  the same committed transforms; never repair the picture with unrelated offsets.
- Preserve newly eligible fragment pairs and invalidate incompatible contact
  rows/impulses after ownership changes. Existing pair identity/lifetime tests
  are more informative than “the building breaks.”
- Share one mathematical operator between workload specializations. Splitting
  private includes can aid maintenance; changing translation-unit/linkage,
  inlining or arithmetic is not a mechanical refactor.
- A strong preconditioner should reduce time, not only iterations. Sparse
  elasticity is not automatically a dense GEMM/Tensor Core problem. Precision
  experiments require authoritative residual and physical-output checks.
- Compute valid settled-reuse certificates from all relevant inputs. Source
  CPU/WASM/Rapier heuristics and cross-frame iteration policies are references,
  not drop-in native CUDA optimizations under the current fidelity contract.
- Keep failed experiments and exact runtime hashes. Do not preserve abandoned
  alternate kernels as production compatibility branches.
- Do not replay whole campaigns for tiny edits without a new question. Inspect
  existing evidence, use focused tests and a short rejection screen, then spend
  long-run qualification on candidates that survived.
