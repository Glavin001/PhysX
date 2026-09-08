## 2026-09-08: refreshed phase profile after committed deltas/normalization

[Current profile](../../qualification/current-native-phases-20260908/README.md), 256 buildings / 113,664 chunks / 229,376 bonds / 768 rounds / 600 steps, API-v15 ordinary mode with sleeping: tick48 complete diagnostic151.620 ms; GPU stress30.929 overlaps wait32.180; CPU fragment compatibility21.146; correction52.336; GPU rewind copies0.019. Stress alone cannot close the complete-step gap. Investigate native lifecycle work, distinguishing new collision pairs from discarded reusable shape pairs. Actor references/island/report bookkeeping prevent simply retaining old interactions. Profiling is separate from untraced timing.

## 2026-09-08: three-block register budget rejected

Lowering component registers 94 → 80 and allowing three blocks/SM worsens the 256-building / 113,664-chunk / 229,376-bond / 768-shot / 600-step mean 45.181 → 46.793 ms and fracture peak 133.936 → 139.979 ms against shared normalization. Numerical and exact wall gates pass, but idle also fails to improve. Reverted; nominal occupancy is not a performance result. [Evidence](../../qualification/component-residency3-20260908/README.md).

## 2026-09-08: share component normalization reciprocal

One FP64 normalization reciprocal is now computed by the existing component reduction instead of repeated per node. Three 256-building / 113,664-chunk / 229,376-bond / 768-shot / 600-step runs per arm show lower means (44.155–44.881 vs 45.033–46.666 ms), with overlapping fracture peaks (132.604–138.325 vs 136.912–140.902 ms). Accepted as redundant-work deletion; no robust peak, real-time or external-baseline claim. Numerical bit-parity, frozen wall, eight ordinary checks and full every-tick large-scene mapping audit pass. [Evidence](../../qualification/shared-normalization-20260908/README.md). Not yet deployed.

## 2026-09-08: local multilevel retry rejected

Modern coarse caches do not make small-component V-cycles faster: compact local rows still worsen the 256-building loaded peak 138.788 → 257.110 ms (113,664 chunks, 229,376 bonds, 768 shots, 600 steps per arm). The inherited cooperative tile schedule was still slower and stopped early. Exact wall passed for the compact variant; all production edits reverted. [Evidence](../../qualification/local-cycle-modern-20260908/README.md). Do not repeat without a cheaper local hierarchy design and a preserved numerical scheduling contract.

## 2026-09-08: GPU committed deltas delete whole-world CPU observation

API v15 now exposes ordered GPU-compacted changed membership and broken-bond indices across both fracture passes. The Vibe-land consumer preserves unrelated groups and no longer reads/rebuilds all chunk membership on every fracture. [Implementation](COMMITTED_GPU_CHANGES.md), [qualification](../../qualification/vibe-committed-changes-20260908/README.md). Two 256-building / 113,664-chunk / 229,376-bond / 768-shot / 600-step runs per arm: complete mean 54.493/54.837 → 47.698/44.285 ms, CPU observation mean 10.199/11.376 → 3.036/2.874 ms. Loaded peaks overlap and startup remains ~160 ms; no robust peak, 60 Hz or historical external superiority claim. Every-tick full GPU/CPU audit, frozen wall, ordinary lifecycle checks and publication memcheck pass. Stage libraries are isolated pending deployment; check current deployment receipt. The solver also now scales polynomial node values once per node; its separate short screen improved means without proving peak improvement.

## 2026-09-08: accurate warm initialization removes false idle work

See [qualified short screen](../../qualification/vibe-warm-residual-20260908/implementation.md). Native warm starts now initialize with the existing FP64 true-residual operator, removing the adapter FP32 multiply/subtract pair. Native numerical, cancellation, ordinary lifecycle and exact frozen wall checks pass. Downtown pristine-idle mean improves 2.469 → 1.000 ms (27 buildings, 24,105 chunks, 74,543 bonds, 600 steps), with startup still 209.173 ms. The 256-building / 113,664-chunk / 229,376-bond / 768-shot screen does not establish a destruction peak gain (142.666 ms loaded peak versus 140.393 ms deployed). No tolerance or per-frame convergence change. General solved-state reuse remains absent.

# Performance findings and experiment memory

## 2026-09-08 21:00 UTC: coarse self-response cache and deployed downtown gain

Engine c8405252, game unchanged 5514155. The qualified GPU changes contract coarse self-column angular responses (preserving rounded offset moments), compact validated non-self adjacency while retaining original seed degrees, and parallelize coarse construction/rows. Cache cap is 4,096 resolved coarse nodes. Large resident launch dimensions now reflect eight-lane row work. The inverse-cache builder has a narrow pointer ABI and a caller-side validity guard; compiled component stack is 48 bytes instead of 528, without a proven additional timing gain.

[Generated downtown comparison](../../qualification/vibe-coarse-assembly-20260908/report.md): 27 buildings, 24,105 chunks, 74,543 bonds, three physical rounds, 600 steps / 10 seconds per arm, Direct GPU off, sleeping on, dt 1/60, correction <=1 / stress <=2. Complete loaded/aftermath peak 719.880 -> 130.319 ms; candidate all-step peak 199.904 ms at startup. Pristine idle stays intact. Exact frozen wall and resident analytic/3D/motion checks pass. This is not the 8 ms/60 Hz/endurance gate.

[256-building final control](../../qualification/vibe-coarse-assembly-20260908/256-final-shots/report.md) and [idle](../../qualification/vibe-coarse-assembly-20260908/256-final-idle/report.md): 113,664 chunks, 229,376 bonds, 768 rounds, 600 steps. Baseline all/loaded peaks 151.087 / 135.994 ms; candidate 158.065 / 140.393 ms. No robust scale win is established. Do not generalize the downtown win to bombardment. The new node-traced CUDA profile still assigns 81.4% of aggregate kernel time to the small-component solver; downtown assigns 95.8% to the large solver. These are device-work shares, not additive complete-peak wall partitions.

Rejected: smaller coarse row groups hurt sustained time; reverted while retaining Boolean support parallelism. Grid-constant annotations reduced component code size but did not improve performance; reverted. Do not repeat these experiments without new evidence. The original-level probe is stale for expanded self caches. A subsequent plain FP32 inverse/off-diagonal polynomial candidate passed native analytic and 3D solves but failed the existing independent polynomial operator/symmetry check. It was rejected before wall/performance runs and reverted; the restored FP64 tests pass. See [rejected precision experiment](../../qualification/float-precondition-rejected-20260908/README.md). No precision or tolerance change is deployed.

Runtime 1fb2da375e8323de3301fc2dabf06d804ffe7915c774b583de106ab1e97e7dfb is deployed to the owned city demo, with fresh browser movement/shoot/settle/reset passing. Direct GPU remains off; sleeping remains on. Source repos stay read-only.

An [external reference replay](../../qualification/vibe-coarse-assembly-20260908/external-reference/README.md) failed physical comparability: the original library breaks the untouched city under the native driver's settings. Original tolerance is 1e-3 vs native 1e-5; the replay uses 8192 rather than the historical 32-iteration budget. It does not establish native superiority. Full architectural, matching-baseline and endurance goals remain incomplete.


## 2026-09-08: current two-evaluation work census and corrected phase probe

The [current consumer work report](../../qualification/vibe-component-work-accepted-20260908/report.md)
reconciles all 920 stress evaluations with 600 accepted ticks: 256 buildings /
113,664 chunks / 229,376 bonds / 768 physical rounds over 10 simulated seconds,
Direct GPU API off, sleep on, correction <=1. Instrumentation is separate from
production timing. It now counts polynomial traversals and fine inverse
applications, which the older work report omitted.

At first split tick 48 (10,449 fragments, 10,193 awake, 216,220 reported normal
contacts, 57,788 cumulative broken bonds), both evaluations require 69,385,024
fine inverse applications and 119,113,158 polynomial live adjacency visits.
Anchored components account for 99.990% of combined outer/polynomial visits.
Only 38.007% of visits now belong to components above 256 updates; the old
high-iteration cohort result must not be copied into the current workload.

Preconditioning is 66.14% of summed instrumented CTA phase cycles; its polynomial
application is 82.61% of precondition subphase cycles. This remains a work-location
measurement, not SM utilization, a hardware roofline or an additive millisecond
breakdown. Subphase global atomics were removed from the iteration loop and
replaced by per-CTA accumulation/publish. A publication bug in the first rewrite
was caught by the zero-counter gate; an actual-macro test now covers this case.
The accepted capture has nonzero subphase totals contained by their parent.
Production preprocessing remains identical with diagnostic flags disabled.

The strongest measured stress target is retained/anchored preconditioning, not
tiny-fragment scheduling. Sparse inverse evaluation remains rejected: current
isolated reproduction still fails memcheck; address prints mask the failure but
do not establish its cause. [Reproduction evidence](../../qualification/sparse-inverse-repro-20260908/README.md).
No production optimization or real-time qualification is claimed by this census.


## 2026-09-08: delete identity residual rewrites for anchored components

`prepareNativeResidualComponent` now returns after producing its RHS when the
validated motion-mode certificate has dimension zero. The prior projection was
already a no-op, but its float/double conversion round trip rewrote both vectors
and synchronized again. Free components retain complete null-mode projection.
Numerical acceptance, precision, iteration order and physical work are unchanged.
Three resident tests, eight ordinary tests and exact frozen penetration pass.

[Generated complete-step comparison](../../qualification/vibe-anchored-residual-20260908/comparison/report.md):
256 buildings / 113,664 chunks / 229,376 bonds / 768 rounds, two 600-step
(10 simulated second) untraced runs per arm. Direct GPU API off, sleeping on,
correction <=1, stress <=2. Baseline complete peaks 158.171/152.782 ms;
candidate 153.169/153.885 ms. Fracture peaks baseline 158.171/146.158 ms;
candidate 146.181/151.395 ms. Ranges overlap; no robust whole-peak or real-time
win is claimed from the lower worst observation. Retained as removal of
redundant work, not an alternative implementation or runtime tuning branch.

Separate instrumented first-split tick 48: CUDA stress over both evaluations
35.978 -> 33.728 ms. Both show 10,449 fragments / 10,193 awake, 216,220 reported
normal contacts, 57,788 broken bonds. Counted states first diverge at tick 76;
this does not prove identical trajectories. See baseline/candidate phase reports
beside the comparison. CUDA durations overlap CPU waits; do not sum them.
Compiler registers/shared/stack footprint is unchanged. Full endurance, strict
peak deadline and historical external-backend superiority remain unqualified.


## 2026-09-08: targeted report repair wins the native game-consumer screen

Engine `69fe462a`, game `45b41d2`. The previous full-world refilter opportunity
is now addressed; do not repeat that optimization. See
[local contact-report repair](LOCAL_CONTACT_REPORT_REPAIR.md), the generated
[comparison](../../qualification/vibe-consumer-local-report-repair-20260908/report.md)
and [new fracture-peak phases](../../qualification/vibe-consumer-local-report-fracture-20260908/report.md).

Workload: 256 buildings / 113,664 chunks / 229,376 bonds / 768 physical rounds,
600 steps (10 simulated seconds), Direct GPU API off, sleep on, correction <=1,
max two stress evaluations. One baseline and two candidate untraced runs with
identical recorded command tapes. Complete peaks: 186.782 -> 151.490/151.405 ms
(startup now largest). Fracture peaks: 186.782 -> 135.903/147.162 ms. Means:
94.641 -> 55.996/57.516 ms. Worse-candidate peak reductions: 18.9% overall,
21.2% fracture. This is a short screen, not an 8 ms/60 Hz/endurance or historical
external-backend superiority qualification. Final broken bonds differ (78,046
baseline; 76,217/76,743 candidate); raw work counts and divergence are published.

Ordinary reports now select only their active dynamic shapes for CPU report
relationship repair, keeping unrelated GPU managers/islands. Static boundaries
and sleepers are excluded. Trigger/modifier/CPU-contact fallback remains complete.
Eight ordinary tests, an additional reported-reuse sleep-boundary comparison,
and exact frozen penetration pass. The optimized server was rebuilt without the
profiling feature and passed browser join/shoot/move/settle/reset on 444 chunks /
896 bonds with six rounds (310 broken bonds, 74 fragments). Public demo remains
one building; six known browser COEP/404 resource errors remain.

Remaining measured opportunity: the initial large split at tick 48, not the old
late refilter peak. New diagnostic fracture peak: 10,449 fragments / 10,193 awake,
256 projectiles present, 216,220 reported normal contacts, 57,788 cumulative breaks;
CUDA stress 33.479 ms, compatibility body creation 20.397 ms, correction 51.371 ms.
GPU completion/stress dominates the ten worst fracture steps. Subsequent corrected
step 78: correction 20.411 ms, refilter 0.016651 ms, GPU completion wait 52.013 ms.
These are different physical states; use untraced comparison for speed claims.

Game `embedded-profiling` is optional and excluded from the production dependency
graph. It reuses the SDK profiler through Rust and writes host/CUDA phase CSVs.
`report-vibe-consumer-phases.py --fracture-peak` uses existing disjoint accounting;
`compare-vibe-consumer-bench.py` checks input tapes/settings and archives full rows.
Never mix instrumented samples into the untraced report. Capture roots are
`out/vibe-game-local-report-repair-20260908` and
`out/vibe-game-local-report-phases-20260908`. The source reference repos remain
read-only. The full goal is still incomplete.


## 2026-09-08: actual Vibe-land consumer scale screen and contact-report crash

Engine `6ef3fd47`, game `5ec74bf` (vibe-land-2). See
[contact report correction](CONTACT_REPORT_CORRECTION.md). The game now has an
`embedded_city_bench` example and validated automatic report generator. Four
buildings per asset let 64 wire asset IDs represent 256 independent buildings.

Three baseline 256-building attempts crashed during the second wave in CPU
`onContact` / `PxContactPair::extractContacts`. Correction recycled trial report
storage without invalidating retained actor/shape report stamps. The fix preserves
ordinary callbacks and the single accepted scene timestamp. Eight ordinary native
tests, the unchanged frozen penetration signature, and browser play/reset pass.

Fixed isolated screens: one 600-step / 10-second run each, 4/64/256 buildings,
1,776/28,416/113,664 chunks, 3,584/57,344/229,376 bonds, 12/192/768 physical
18,000 kg spheres at 40 m/s in three waves. Direct GPU API off, sleep on,
correction <=1 and exactly one additional stress evaluation after correction.
Complete-step peaks: 40.234 / 70.608 / 186.782 ms. This is not a performance win
or a 60 Hz qualification. First-step setup remains measured; no peaks discarded.

At the 256-building peak (tick 139): 256 projectiles present, 16,587 fragment
bodies / 13,747 awake, 16,843 total destruction clusters, 400,481 reported native
normal-contact count, 72,407 cumulative broken bonds, one correction/two stress
passes. Native advance = 169.699817 ms; accepted game event/snapshot processing =
17.081810 ms. These disjoint intervals do not identify native CPU vs CUDA limits.
Next useful measurement is the existing internal phase profiler on this exact
consumer workload, not another unmatched standalone scene or optimization of the
legacy CPU bridge. Accepted GPU event/topology deltas remain a final-owner gap,
but removing all current observation cost would still miss 60 Hz substantially.

Game report: `vibe-land-2/docs/reports/embedded-scale-2026-09-08/report.md` with
compressed raw samples, command tapes, build receipts and debugger captures.
Native capture root: `out/vibe-game-screen-20260908-fixed2`. The live public game
was restored to the tested one-building scene. Larger browser/network/endurance
qualification and matched external-backend speed superiority remain unproven.


Snapshot: **2026-09-08**. This file preserves conclusions and their limits, not a
claim that the complete native architecture or real-time goal is finished.
Revalidate against current source/runtime before applying them. See the
[playbook](PERFORMANCE_PLAYBOOK.md) for commands and the
[handoff](PERFORMANCE_HANDOFF.md) for outstanding implementation work.

## Query membership now publishes once after acceptance

Native GPU freeze/unfreeze callbacks collect a sparse union of changed shape
identities. `finalizationPhase` reconciles their query membership from final
body ownership/activity once, after both stress/fracture evaluations complete.
Trial delta identities survive rejection. Ordinary non-destruction PhysX is
unchanged. This is CPU query observation work; CPU physical activity rollback,
body/shape DMA and ownership lifecycle are not removed by this change.
[Implementation and limits](ACCEPTED_QUERY_OBSERVATION.md).

One isolated **256-building / 113,664-chunk / 229,376-bond / 768-projectile /
30-second / 1,800-step diagnostic**, Direct GPU OFF, sleeping ON, limit one
correction/two stress evaluations, passes the per-step final-publication checks.
Its complete peak is **113.891 ms** at step 396 (22,895 bodies / 17,348 awake).
At that step, identity collection across both passes is **0.005139 ms**, final
query membership is **0.005209 ms**, and query membership work inside replay is
zero. These are instrumented intervals, not a matched peak speedup claim.
[Generated phase report](../../qualification/native-query-publish/cpu-sync.md).

Nine focused tests pass. The no-report sleep/late-impact fixture additionally
requires actual queued transitions and at most one accepted query publication
per tick while checking scene queries and body motion. Six CPU report tests,
seven general phase tests and the unchanged frozen penetration golden pass.

The two-run, 12-second untraced screen includes 767 shots per run (the final
scheduled shot is beyond that duration). Baseline mean/worst **59.420 / 118.007
ms** versus candidate **57.481 / 124.409 ms**: **no demonstrated peak gain**.
The candidate's worst peak is higher. No every-step deadline passes. The
comparator returns 1 because chaotic physical counter histories differ; all
raw histories remain. This change is retained for accepted-observation data
flow and controlled functional tests, not accepted as a verified peak-speed
optimization. [Generated comparison](../../qualification/native-query-publish-comparison/comparison.md).

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
| ❌ | Descending component-size dispatch queue | Numerical/penetration tests pass and averages improve, but two matched native game-consumer runs per arm did not improve complete or fracture peaks. Reverted; see [screen and preserved patch](../../qualification/vibe-stress-order-20260908/comparison/report.md). This is not the earlier committed dynamic queue. |
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

## 2026-09-08: downtown idle — coarse-row parallelism

The actual 27-building city (24,105 chunks, 74,543 bonds) exposed a different
bottleneck from 256 independent small buildings. An isolated pristine-idle
phase capture measured about 38.4 ms in GPU stress, with only three reported
iterations. CUDA node tracing identified persistentStressSolve. Internal
clock probes attributed its cost to coarse residual/restriction/correction
reductions: one level retained 35,534 bond columns for only 21 nodes. Eight
lanes per row serialized long rows; terminal triangular solves were small.

The qualified change distributes coarse rows across full blocks, shares the
schedule with the local cycle, and retains FP64/all contributions. A new
24-node/1,472-bond fixture checks every basis against the dense oracle and
exact local/cooperative equality. The first experimental schedule differed
between local/cooperative summation orders and failed that equality; it was
corrected without weakening assertions. No converged-result reuse, material
change, iteration reduction or artificial sleeping was introduced.

See `qualification/vibe-downtown-idle-fix-20260908/report.md` for paired idle
and impact measurements and startup failures. The 256-building destruction
peak remains outside real-time; do not present this as completion of that goal.
Diagnostic probes and trace runtimes are archived under
`out/vibe-idle-fix-20260908`; production contains no probe prints.
