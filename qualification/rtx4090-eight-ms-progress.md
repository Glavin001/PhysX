# 🎯 RTX 4090 / 8 ms implementation progress

This is a qualified first increment, **not completion of the GPU ownership architecture**.
Physical timestep remains 1/60 second; each step permits at most one correction.

## ✅ Implemented and verified

| Action | Change | Evidence |
|---|---|---|
| 🛡️ GATE | Complete-step timer starts before commands/insertion and ends after mandatory completion; retain startup/allocation spikes | 21 reporting tests; all raw steps preserved |
| 🔁 REPLACE | Native stress iteration is one cooperative CUDA kernel; small workloads use one block | Analytic supported/free columns at 12, 1,536 and 131,072 nodes; existing CPU stress-equivalence test |
| 🗑️ DELETE | Separate per-iteration clearing **launches** | Clearing writes currently remain inside the resident kernel |
| 🗑️ DELETE | Load-producer allocation and device copy into stress inputs | Producer writes the solver-owned input view; zero transfer bytes in analytic tests |
| 🗑️ DELETE | Internal public-contact export, pair/count buffers, pair-buffer growth and two compaction kernels | Borrowed native NP streams; same normal/friction load consumer and ordered buffer lifetime |
| 🛡️ GATE | Frozen 10-second penetration audit | Ball clears both walls; 398 supported, 46 detached, 199 broken bonds, 43 clusters |
| 🛡️ GATE | Exact stable chunk membership over all 600 frames | All 266,400 `[step,chunk,root,cluster_chunks,supported]` observations match the original accepted capture |
| 🛡️ GATE | Native integration and memory checks | Six native tests: destruction, material, collision preparation, checkpoint, resimulation and publication; CUDA memcheck reports zero errors for resident analytic cases |
| 🛡️ GATE | Five 60-second runs for each of three scenes | 54,000 steps; no complete advance exceeds 8 ms |

[Generated deadline report](eight-ms-direct-contacts-qualified/report.html) ·
[Generated phase breakdown](eight-ms-direct-contacts-profile/report.html).

The original complete-timer 10-second baseline averaged 4.800 ms and peaked at
9.396 ms (9 missed deadlines). The resident kernel's five 60-second wall runs
averaged 3.042–3.047 ms and peaked at 6.729 ms. These unequal durations are an
observed improvement, not a matched-duration speedup campaign. After direct
contact consumption, wall runs averaged 3.028–3.046 ms and peaked at 6.571 ms;
the incremental timing difference is small enough that no separate speedup is
claimed for contact export removal.

The detailed capture attributes about 2.207 ms average destruction-stream time
to stress. This includes stream gaps; actual kernel execution is reported
separately. Profiling is not used to qualify the untraced deadline.

## 🔜 Required work remaining

| Action | Responsibility | Current limitation / final change |
|---|---|---|
| 🚚 MIGRATE | Commands and fragment lifecycle | CPU still creates/reserves native bodies and performs ownership bookkeeping; move normal-step allocation/activation/rebinding into GPU ownership transactions |
| 🚚 MIGRATE | Destruction stage decisions | Intermediate host waits/status-driven submission remain; use GPU dependencies and conditional execution |
| 🔁 REPLACE | Checkpoint and correction work sets | Full internal correction remains; derive complete affected contact/constraint sets and validate selective reuse |
| ⚡ OPTIMIZE | Component-local stress | Resident iteration still uses global vectors and legacy reduction layout; pack/tile by component and eliminate clearing writes through producer-owned partials |
| 🔁 REPLACE | Multilevel preconditioner | GPU aggregates, coarse operators and coarse solves are not implemented |
| ⚡ OPTIMIZE | Topology and mass | Further restrict work to changed components and use segmented reductions |
| 🚚 MIGRATE | Sleep / structural activity | GPU-owned validated reuse and sleep/wake qualification remain; current benchmark has sleeping disabled |
| 🗑️ DELETE | Production compatibility surface | Native loop has no unrolled/device fallback, but legacy API/algorithm surface and other integration switches still need removal from the production build |
| 🛡️ GATE | Exact bond identity | Chunk identity history is frozen; exact broken-bond identities are not yet qualified |
| 🛡️ GATE | Scaling/endurance | Four destruction scaling axes, full 10-minute lifecycle endurance, overflow/removal/reinsertion/handle reuse campaign remain |

The 131,072-node analytic test is a stress-kernel correctness test. It does **not**
establish a 131,072-chunk integrated destruction performance result.

## Reproduce

```sh
cmake --build out/sdk-release --target PhysXGpu PhysXDestructionGpuRuntime -j6
cmake -S destruction -B out/destruction-sdk
cmake --build out/destruction-sdk --target native_destruction_demo gpu_resident_stress_test gpu_resident_stress_parity_test -j4
ctest --test-dir out/destruction-sdk -R 'blast_stress_gpu_resident_' --output-on-failure
python3 tools/scripts/run-destruction-penetration-regression.py out/NEW-quality
python3 tools/scripts/run-destruction-timing.py out/NEW-deadlines --gate-only --trials 5 --seconds 60 --report-output qualification/NEW-deadlines
python3 tools/scripts/run-destruction-timing.py out/NEW-profile --case penetration --trials 2 --seconds 10 --gpu-trials 1 --report-output qualification/NEW-profile
```

Performance capture requires an otherwise unused GPU; the runner observes other
processes and refuses conflicting work. It never stops services. Source repos
remain read-only. Reports preserve executable hashes and recorded arguments.

## Rejected shared-vector experiment

On the same 444-chunk / 896-bond penetration fixture (one projectile, 1/60-second
timestep, correction limit one), two 10-second untraced runs with five solver
vectors staged in shared memory averaged 3.919 and 3.904 ms for the complete
advance. The preceding two 10-second runs of the retained implementation
averaged 3.193 and 3.194 ms. The experiment passed the physical audit but was
slower, so its implementation was removed. Its measurements remain in
[eight-ms-shared-smoke/report.html](eight-ms-shared-smoke/report.html). No shared-
vector experiment switch remains in production.

## Mechanical kernel split

Kernel definitions were extracted into private implementation headers, still
compiled by the original CUDA translation unit. Each new header is below 500
lines. Expanding the includes reproduces the source at `00504a89` exactly;
[the extraction record](stress-kernel-refactor.json) records the original and
fragment hashes. Equations, order, kernel boundaries, public API and linkage
were not deliberately changed. The existing host class remains a documented
size exception to avoid combining a structural cleanup with control-flow edits.

The subsequent host-section split extracts construction/release, buffer
allocation, resident API, iteration dispatch, solve submission and graph
execution into six named private member files (102–373 lines each). They remain
inside the original class definition to preserve implicit inlining, member order
and access. The main file is now 4,607 lines; other host topology, observation and
reference scheduling methods remain there. Expanded source still matches
`00504a89` exactly. Nine focused tests and the frozen 10-second, 444-chunk /
896-bond penetration audit passed after this split. No new long performance
campaign was run for the host-only extraction.

## Native storage cleanup and rejected reductions

Removed unused bond-space gradient/direction arrays, reference Jacobi vectors,
inverses/scalars, dense reduction input, an unused CUB workspace and the native
build's reference-only conditional-loop stream. The node reset no longer writes
an unused Jacobi vector. Resident CG equations and ordering are unchanged.
Requested device array storage falls by `64*bonds + 216*nodes + 4*max(nodes,bonds)`
bytes: 156,832 bytes for the 444-node / 896-bond wall, or 35,200,000 bytes for
100,000 stress nodes and 200,000 bonds. This is allocation accounting, not an
integrated large-scene memory/performance qualification; allocator rounding,
CUB scratch and stream overhead are excluded.

Before this cleanup, two fixed-order segmented-reduction candidates passed
physical checks but regressed complete-step cost on the frozen wall. Both were
removed from production. The CTA-per-tile version averaged 4.728–4.747 ms and
missed 12 deadlines; the warp-per-tile version averaged 3.491–3.508 ms, against
3.202–3.205 ms before. Each arm measured two 10-second runs, one projectile,
444 chunks / 896 bonds, timestep 1/60 second and correction limit one. These
short runs reject the regressions; they do not establish the full endurance gate.
See [candidate evidence](stress-resident-cleanup.json). Component-local iteration
remains unfinished; fixed-order reductions alone are not a qualified speedup.

The full CUDA leak check also found the pinned island-skip array was never freed
on solver destruction. Its release is now paired with allocation. The new
`blast_stress_gpu_resident_memory` CTest fails on CUDA memory errors or leaks;
the native analytic test covers GPU-owned topology and complete bond removal
at 12/9, 1,536/1,152 and 131,072/98,304 stress nodes/bonds, plus repeated
unchanged generations. These are numerical/lifecycle tests, not large-world
simulation deadline measurements.

Final validation: 14 focused tests pass, including the registered CUDA memory
check with zero errors and zero leaked bytes; 21 report-accounting tests pass.
The rebuilt artifact preserves the complete frozen wall membership history,
398 supported / 46 detached chunks, 199 broken bonds and correction limit one.
Five 60-second runs of each of the three existing workloads pass all 54,000
complete-step deadlines. On the 444-chunk / 896-bond, single-projectile wall,
mean complete-step time is 3.013–3.027 ms and the largest measured step is
7.037 ms. The idle controls contain 444/896 and 7,104/14,336 chunks/bonds;
sleeping remains disabled. No new speedup is claimed from this storage cleanup.
[Final generated report](eight-ms-storage-final-qualified/report.html) includes
scene population, projectile count, peak cluster count, duration, correction
limit and sleeping settings alongside every measured timing table.

## Integrated world-size and concurrent-impact diagnostics

The optional `impact-corridor` demo layout leaves building zero and the frozen
wall projectile at exactly their original coordinates. Additional structures
sit beside the flight path. The default layout and frozen fixture are unchanged;
the launch-geometry test and complete 10-second frozen identity audit pass.

Seven larger workloads ran twice for ten simulated seconds each, at 1/60-second
timestep and correction limit one, with sleeping disabled. All accepted steps
converged. These are diagnostic runs, not five-by-60-second or endurance gates.
[Generated combined report](destruction-scaling/report.html) includes exact
populations, active-body counts, contact reports, memory samples, every peak,
deadline misses and the separate phase attribution.

- World-size axis: 4, 16, 64 and 256 buildings; one unchanged wall impact.
  Every size retains 199 broken bonds, three corrected steps and 42 additional
  clusters. At 256 buildings (113,664 chunks / 229,376 bonds), complete advances
  average 6.792 ms and peak at 16.162 ms. The 8 ms gate fails; no step in these
  two 10-second runs exceeds 1000/60 ms. This is not a strict 60 Hz qualification.
- Concurrent axis: 16, 64 and 256 aerial projectiles/buildings. With 256 impacts
  on 113,664 chunks / 229,376 bonds, complete advances average 25.170 ms and peak
  at 98.180 ms, reaching 14,096 clusters and 62,582 broken bonds. This fails both
  peak deadlines. Actual destruction work is included, not just static geometry.
- A separate ten-second scoped run of the 256-impact scene peaks at step 82:
  40.595 ms CPU ownership/lifecycle bridge, 32.779 ms correction collision/solve,
  5.582 ms native body reservation and 9.404 ms stress-stream interval. Mean
  stress-stream time is 17.624 ms. GPU stream durations overlap host waits and
  are not additive with the wall partition. The scoped peak is 94.982 ms, not
  the untraced 98.180 ms maximum. Counter histories match through that peak;
  the scoped run ends with one fewer broken bond. Full chaotic physical-quality
  qualification remains open and is disclosed in the report.

This evidence prioritizes GPU fragment allocation/ownership for fracture peaks
and component-local stress/preconditioning for sustained cost. It does not
justify optimizing the CPU ownership bridge into a permanent architecture.
The remaining migration, exact-bond, selective-correction and endurance gates
above still apply.


## GPU-ordered collision and corrected-motion preparation

Collision preparation and corrected-motion preparation now submit consecutive
GPU work without reading a host verdict between stages. The corrected-motion
kernels consume collision validity on device and overwrite every compaction
sentinel even when that prerequisite is invalid. One combined compact status
observation remains before the existing CPU ownership bridge. This replaces
two stage-local waits with one combined boundary; it does not remove CPU
fragment reservation, shape rebinding or the full correction pass.

The native runtime interface documents submission versus observation explicitly.
Exceptional launch failures drain prior writers before publishing rejection.
A new negative fixture poisons the GPU prerequisite after a valid batch and
proves stale host observations cannot retain correction records or mutate native
motion. Existing nonfinite-checkpoint rejection remains covered. Eleven focused
native/accounting checks pass, along with 25 timing-accounting unit tests and five
phase-analysis tests. The full frozen ten-second wall audit keeps the reference
topology identity, clearance, 398 supported chunks and 46 detached chunks.

[Final generated deadline report](preparation-ordered-qualified/report.html):
444 chunks, 896 bonds, one projectile, peak 43 destruction clusters, five runs
of 60 simulated seconds, timestep 1/60 and correction limit one. All 18,000
complete advances fit 8 ms; peak is 6.649 ms and per-run means are 3.010–3.035 ms.
Sleeping is disabled; the timer includes commands, physics, destruction,
correction and mandatory completion, excluding rendering/initialization.
This proves the unchanged wall deadline on this build, not overall plan
completion or the ten-minute lifecycle endurance gate.

[Large diagnostic report](preparation-ordered-impacts64/report.html): 64 buildings
and 64 aerial projectiles, 28,416 chunks and 57,344 bonds, two ten-second runs plus
one separately scoped run. All per-step fracture/correction/cluster counters in
the first untraced run match the pre-change large capture. Peak 3,211 clusters and
14,711 broken bonds remain. Complete advances average 8.985–9.068 ms and peak at
26.120 ms: the 8 ms gate still fails. No overall speedup is claimed from this
orchestration change. The scoped combined preparation boundary is explicitly
reported instead of disappearing into residual time.

[Validation record](preparation-ordered-validation.json) contains source hashes,
artifact/report references and the cross-build counter comparison. Intermediate
diagnostic captures precede final exceptional-error handling; final physical
and five-by-sixty deadline checks use the final build. The major GPU ownership,
component-local stress, selective correction, exact-bond and endurance work
remains required.

## GPU-authoritative narrowphase ownership

The native CUDA ownership transaction now writes both the persistent shape-sim
owner and PhysX narrowphase's shape-to-body remap. Preparation validates both
views before the CPU lifecycle bridge can mutate anything. Narrowphase joins
the transaction's CUDA event before remap growth/uploads and its existing GPU
rigid-to-shape sort. Cooked geometry and shape identities stay persistent.

Native CPU registry updates now observe ownership without marking shape/node/
actor payloads for DMA. Independently queued ordinary PhysX edits remain queued.
CPU actor pointers are used only for explicit contact export: that request takes
a private pinned snapshot and fences its asynchronous consumption. Subsequent
exports wait before reusing that observation storage; normal simulation never
creates, fills or waits on this snapshot. Its event is destroyed under the
existing narrowphase CUDA-context lock.

Twelve focused checks pass, including ordinary persistent-owner bounds/growth/
overflow, native allocation/checkpoint/correction, publication and resimulation.
The native fixture verifies zero ownership-map upload entries after initial
uploads, exact GPU remap/shape-owner agreement, and a unique correct entry in the
Direct GPU API's sorted shape view. A delayed public contact-export test blocks
on a CUDA event, changes the CPU actor pointer, then releases the event and
requires the previously captured actor. Corrupt GPU remaps reject before owner
mutation and cannot leave stale correction records. See the
[validation record](native-remap-validation.json) and
[test log](native-remap-ctest.log).

The final ten-second wall audit preserves the reference topology identity,
398 supported chunks, 46 detached chunks and actual projectile clearance.
[Final generated deadline report](native-remap-final-qualified/report.html):
444 chunks, 896 bonds, one projectile, peak 43 destruction clusters, five runs
of 60 simulated seconds. All 18,000 complete advances fit 8 ms; worst is
7.556 ms and per-run means are 3.019–3.039 ms. Timestep remains 1/60, correction
limit one and sleeping disabled. Commands, physics, destruction, correction and
mandatory completion are included; initialization/rendering are excluded.
The earlier passed gate before observer lifetime hardening remains recorded
separately, with its own artifact hashes; it is not substituted for the final run.

[Large diagnostic report](native-remap-impacts64/report.html): 64 aerial impacts
on 64 buildings, 28,416 chunks and 57,344 bonds, two ten-second untraced runs and
one separately scoped run. Untraced means are 9.002–9.009 ms and the maximum is
23.793 ms; 892 of 1,200 measured steps exceed 8 ms. Peak cluster count is 3,211
and 14,711 bonds break. Per-step fracture/correction/cluster counters match the
previous capture; scoped counters also match the untraced capture. This is a
failed large-workload deadline diagnostic, not a full physical/endurance gate.
No overall speedup is established by these short comparisons.

At the separate scoped peak, CPU ownership/lifecycle still costs 8.478 ms and
correction collision/solve costs 7.366 ms; mean GPU stress-stream time is
6.550 ms. The latter overlaps host waits and must not be added to the CPU wall
partition. CPU fragment allocation, shape lifecycle/refiltering, bounds-request
metadata, component-local stress/preconditioning, selective correction and
endurance remain unfinished. This change removes one duplicated ownership route;
it does not complete GPU ownership of the entire PhysX lifecycle.


## GPU correction bounds and larger 60-second workloads

Full native correction now reads PhysX's existing GPU-sorted rigid-to-shape
index to refresh collision bounds. It no longer walks every CPU shape to build
and upload a bounds list. The native split also stops queuing individual CPU
bounds requests. The kernel selects the live ordinary-rigid prefix, including
ordinary actors, and verifies the sorted owner against the current shape owner.
Required CPU contact invalidation and the ordinary public-rebind path remain.
This removes repeated work; it does not complete GPU lifecycle ownership.

The updated CPU/GPU libraries and consumers build. Twelve focused tests pass,
including a new assertion that native correction uploads no CPU shape-bounds
indices. The ten-second penetration audit keeps the exact reference topology
identity, projectile clearance, 398 supported chunks, 46 detached chunks and
199 broken bonds for the 444-chunk/896-bond building. Physical equations and
settings are unchanged. See [validation](device-bounds-validation.json) and
[test log](device-bounds-ctest.log).

[Generated larger-scene report](device-bounds-large-scenes/report.html) includes
the five × 60-second small baseline and three larger workloads, each measured
twice for 60 seconds plus a separate 60-second CPU/CUDA-event profile. The
complete advance includes commands, insertion, physics, destruction, correction
and mandatory completion. Initial asset/CUDA setup and rendering are excluded;
initialization is separately reported. Every measured peak remains. Sleeping is
disabled, timestep 1/60 and correction limit one throughout.

The single-building baseline passes all 18,000 measured steps under 8 ms, with
a 7.203 ms maximum. With 256 buildings (113,664 chunks, 229,376 bonds) and one
unchanged projectile, the two larger runs average 6.370 ms and peak at 15.305 ms:
all 7,200 advances fit 16.667 ms but 213 miss 8 ms. The 64-projectile case
(28,416 chunks, 57,344 bonds) averages 8.060 ms and peaks at 26.188 ms. The
256-projectile case (113,664 chunks, 229,376 bonds) averages 20.967 ms and peaks
at 100.029 ms, reaching 14,128 destruction clusters and 62,640 broken bonds.
Those simultaneous-impact workloads miss both strict peak targets.

All untraced repeated counter histories match, and each separate scoped run
matches its untraced history. The initial 600-step fracture/correction/cluster
histories also match the previous captures at all three larger sizes. All
recorded stress solves converged and correction remains at most one per step.
These counters do not replace complete physical audits or ten-minute lifecycle
endurance at the larger sizes. Only two repetitions were run for each larger
case, so no larger five-run deadline qualification is claimed.

The separate 256-impact scoped peak is 91.468 ms: CPU ownership/lifecycle takes
40.879 ms, correction collision/solve 29.227 ms and CPU fragment reservation
6.691 ms. Mean GPU stress-stream time over that 60-second capture is 16.487 ms;
it overlaps host waiting and must not be added to the CPU wall partition.
Priorities remain GPU lifecycle transactions and component-local resident
stress/preconditioning, followed by validated correction work selection.
These longer runs establish current scaling costs, not a speedup relative to
previous ten-second captures or a hardware bandwidth/compute bound.


## GPU-generated broad-phase refilter selection

The ownership-install kernel now stamps affected persistent shapes with the
current correction generation. Broad phase borrows that GPU array through the
existing NP-to-BP stream dependency and consumes it for updated projections,
newly eligible pair discovery, cache-refilter selection and overflow failure.
Native shape migration no longer constructs or uploads a CPU refilter bitmap.
Ordinary public rebind and required full contact invalidation remain supported.
No extra normal-step kernel or per-step generation clear is introduced; storage
uses eight bytes per shape, with explicit allocation/growth inside the complete
timer. Generation zero disables the view on later ordinary passes.

Twelve focused tests pass. New assertions cover the affected shape's current
GPU stamp, an unmarked ordinary projectile, exact borrowed-view publication,
zero native CPU refilter requests/uploads on valid reuse, and disabling stale
generations on subsequent ordinary steps. Existing bounds, allocation, contact,
correction and public overflow checks remain intact. The ten-second penetration
audit matches the reference topology identity, clearance and retained structure.
See [validation](native-refilter-validation.json) and [test log](native-refilter-ctest.log).

[Generated timing report](native-refilter-scaling/report.html) includes the
444-chunk/896-bond, one-projectile baseline: five 60-second runs, all 18,000
complete advances below 8 ms; mean 3.026 ms and peak
6.762 ms. Two larger diagnostics each use 113,664 chunks and
229,376 bonds, two ten-second measured runs plus a separate ten-second phase
capture. One projectile averages 6.797 ms, peaks at
15.634 ms; 256 simultaneous aerial projectiles average
24.684 ms, peak at 98.047 ms.
Larger workloads still fail the 8 ms gate and are not five-run qualified.
Commands, insertion, physics, destruction, correction and completion are timed;
rendering and initial setup are excluded. Timestep remains 1/60, correction one,
and sleeping disabled. Every measured peak is retained.

Both large workloads preserve the first 600-step fracture/correction/cluster
histories from the preceding 60-second captures. These history checks do not
replace full physical/endurance qualification at scale. No material end-to-end
speedup is claimed from this deletion; sustained stress work and the CPU
ownership/lifecycle bridge remain the dominant measured responsibilities.
In particular, CPU group/type observation and its group upload still remain.
The final GPU lifecycle, component-local stress/preconditioning and validated
correction work selection are still required before the full plan is complete.


## Shared GPU motion identity replaces native collision-group reconstruction

Broad phase now compares NP's authoritative shape-to-motion map for rigid group
identity, including full articulation-link IDs. Static/proxy group handling and
environment filtering retain their existing rules. Both ordinary SAP and
aggregate pair generation use the same comparison. The borrowed map is captured
after NP allocation/growth; existing stream dependencies order its consumption,
with an explicit NP-to-BP join during initialization.

Native owner migration no longer computes CPU actor-based groups or marks the
whole world's contact-distance/group/environment metadata for upload. Native
kinematic/dynamic flag observation retains scheduler and filter metadata while
skipping CPU broad-phase shape reinsertion. No extra simulation kernel, copied
owner buffer or separate native group-ID allocator is introduced. This does not
remove the remaining CPU actor allocation and shape/contact/query lifecycle.

Twelve focused checks pass, with assertions that valid native reuse performs
neither CPU refilter nor group upload. Comparison checks deliberately alias old
CPU groups across different GPU owners and give different groups to one owner;
self collisions remain suppressed and newly separated owners remain eligible.
An additional GPU aggregate control checks two moving members against two static
walls, self collisions enabled/disabled, with native destruction present/absent.
Each of its four variants advances 180 steps. A stationary two-chunk/one-bond
structure enables native grouping; that control does not qualify aggregate
fracture correction. The controlled final positions agree within 1e-5.
See [validation](native-group-validation.json).

[Generated report](native-group-scaling/report.html): the one-projectile,
444-chunk/896-bond penetration scene passes five 60-second runs, all 18,000
complete advances below 8 ms (mean 3.028 ms, peak 6.831 ms).
The original ten-second topology/clearance/motion audit also passes unchanged.
Two large diagnostics each contain 113,664 chunks and 229,376 bonds, with two
ten-second untraced runs plus one separate phase capture. One projectile averages
6.790 ms and peaks at 14.898 ms; 256 projectiles average
24.588 ms and peak at 95.908 ms. Both miss 8 ms.
These complete timers include commands, insertion, physics, destruction,
correction and completion; initialization/rendering are excluded. Timestep is
1/60, correction limit one, sleeping disabled, and every measured peak is kept.

The localized-impact histories match the previous build. For the large
bombardment, one untraced run diverges after step 102 and ends with 62,476 broken
bonds; the other run and the separate profile match the previous 62,582. All
match the previous counters through the impact peak. This variation is retained
in the report and is not treated as proof of harmlessness or complete parity.
No overall speedup is claimed from means with differing trajectories.

A separate ten-second [large motion audit](native-group-large-motion-audit.json)
checks all 113,664 chunks on every step, with the same 256-projectile inputs.
Committed membership, finite poses, CPU-owner/GPU-motion agreement and collision
pose agreement pass existing position/orientation tolerances. Maximum position
error is 0; terminal fracture counts match the
previous capture. This audit does not read the renderer buffer or perform the
full COM/momentum trace, and it does not complete large-scene fidelity or
endurance qualification. The remaining major work is GPU lifecycle allocation,
component-local stress/preconditioning and validated correction work selection.

## Compact GPU component scheduling

The native stress iteration now visits a GPU-resident compact list of live component IDs. Connectivity still uses minimum-node IDs; the list is rebuilt only when GPU topology changes. No physical equations, node reduction order, tolerance or correction limit were changed. This deletes repeated scalar work over unused sparse IDs; it does not yet provide component-local resident vectors or remove the global cooperative barriers.

The runtime, production-kernel analytic tests and reference topology consumers rebuilt. Nine focused tests passed, including CPU numerical parity, native correction/publication and GPU memory checking. Analytic fixtures cover up to 131,072 nodes / 98,304 bonds, sparse IDs, list growth after splitting, empty topology, warm starts and event ordering. The 444-chunk / 896-bond frozen 10-second penetration audit preserves 398 supported chunks, 46 detached chunks, 199 broken bonds and its exact existing topology signature. The separate 113,664-chunk / 229,376-bond / 256-projectile 10-second audit passed committed-pose/membership/collision-owner checks; it is not a full momentum or render-buffer audit.

[Generated timing and phase report](compact-stress-scaling/report.html) · [Validation and before/after comparisons](compact-stress-validation.json). Timings below include the complete command-to-accepted-state advance; no rendering. Sleeping remains disabled.

- penetration: 444 chunks / 896 bonds / 1 projectile(s), 5 × 60 seconds. Mean 3.028 → 2.895 ms; peak 6.831 → 7.041 ms; steps above 8 ms 0 → 0.
- world-256: 113,664 chunks / 229,376 bonds / 1 projectile(s), 2 × 10 seconds. Mean 6.790 → 6.110 ms; peak 14.898 → 14.647 ms; steps above 8 ms 211 → 93.
- impacts-256: 113,664 chunks / 229,376 bonds / 256 projectile(s), 2 × 10 seconds. Mean 24.588 → 23.701 ms; peak 95.908 → 98.298 ms; steps above 8 ms 1038 → 1038.

The small scene passes all 18,000 measured steps under 8 ms. Neither large scene passes the 8 ms peak gate. The bombardment mean is descriptive, not qualified identical-trajectory speedup: repeated histories differ after the impact peak, before and after this change. All compared captures retain matching fracture/correction/cluster counters through their worst step. CPU ownership/lifecycle changes and full resimulation still dominate that fracture spike. No worst-case bombardment improvement is claimed.

A separate reporting fix aggregates the peak cluster count across all measured repeats, with 26 reporter tests passing. It does not change simulation.

## Independent GPU component iteration

GPU topology now builds stable component node ranges and selects components larger than 1,024 nodes for cooperative iteration. Smaller components run independent loops within one CUDA thread block. They share the existing mathematical operator, recurrence and convergence bodies. Their iteration counters and completion state are local; GPU status merging preserves failure from either size specialization. Hot vectors remain in persistent GPU storage; further caching/layout work remains. No CPU topology construction or per-component host submission was introduced.

Nine focused tests passed, including analytic columns through 131,072 nodes / 98,304 bonds, mixed 12/1,024/1,028-node components, sparse IDs, empty topology, warm starts, iteration-cap rejection, native correction/publication and memory checking. The frozen 444-chunk / 896-bond 10-second penetration audit preserves 398 supported chunks, 46 detached chunks, 199 broken bonds and its existing exact topology signature. Separate 10-second motion/ownership audits pass for 28,416 chunks / 57,344 bonds / one projectile and 113,664 chunks / 229,376 bonds / 256 projectiles. They do not replace full momentum or render-buffer audits.

[Generated timings and phase breakdowns](component-stress-scaling/report.html) · [Validation and comparisons](component-stress-validation.json). All timings include the complete advance, use timestep 1/60, correction limit one and sleeping disabled; rendering is excluded.

- penetration: 444 chunks / 896 bonds / 1 projectile(s), 5 × 60 seconds. Mean 2.895 → 2.917 ms; peak 7.041 → 7.881 ms; steps above 8 ms 0 → 0.
- world-256: 113,664 chunks / 229,376 bonds / 1 projectile(s), 2 × 10 seconds. Mean 6.110 → 3.621 ms; peak 14.647 → 9.898 ms; steps above 8 ms 93 → 3.
- impacts-256: 113,664 chunks / 229,376 bonds / 256 projectile(s), 2 × 10 seconds. Mean 23.701 → 19.734 ms; peak 98.298 → 92.772 ms; steps above 8 ms 1038 → 1038.
- New timing gate: 64 buildings, 28,416 chunks / 57,344 bonds / one unchanged projectile; five × 60 seconds, 3.037 ms mean, 7.122 ms worst, 0 missed 8 ms deadlines. This increases retained world complexity, not the amount of simultaneous destruction. It is a passing measured workload, not a completed maximum-size frontier search.

The 256-building cases still fail the 8 ms peak target. World-size counter histories match their baseline. Bombardment repetitions match each other here, but differ from one previous repeat after its impact peak; no full physical parity or identical-trajectory speedup is claimed for that comparison. CPU ownership changes, full correction, and remaining GPU stress cost still need work.

**Additional validation issue retained:** unfiltered synccheck reports CUB DeviceSelect barrier errors in both resident and reference topology tests. A standalone reproducer passes eager/ordinary graph checking and uninstrumented conditional execution, but fails conditional execution under the checker. Root cause remains unresolved. Scoped resident-kernel synccheck and new-kernel racecheck pass; this is not a passing full synchronization audit. See [reproducer and logs](component-stress-cub-synccheck/README.md).

## Producer-owned component reductions and 144-building timing gate

Small-component iterations now produce local norm contributions and reduce them through a fixed warp/block order. The compiled component kernel contains no atomic reduction instructions, and its two reduction-clearing passes are removed. The shared mathematical operator and convergence threshold remain; summation order changes and is independently qualified. Explicit operand handling preserves the global-atomic treatment of subnormals. The larger cooperative and reference paths keep their existing reductions.

Nine focused tests pass, including interleaved IDs across 12/1,024/1,028-node components (2,064 nodes, 2,061 bonds), tiny-load convergence, sparse IDs, empty topology, mixed-size failure propagation, CPU parity, native correction/publication and unfiltered memory checking. Targeted solver synccheck and racecheck pass. The previously recorded full CUB/conditional-graph synccheck issue remains unresolved; no full synchronization qualification is claimed. The frozen 444-chunk / 896-bond penetration audit preserves its exact existing topology signature, 398 supported chunks, 46 detached chunks and 199 broken bonds. Separate 10-second motion/ownership audits pass for the 144-building and 256-projectile cases, without claiming full momentum or render-buffer audits.

[Generated timings and phase report](producer-norm-scaling/report.html) · [Validation](producer-norm-validation.json) · [Rejected-layout comparison](producer-norm-layout-comparison/report.html). Complete advances include commands, physics, destruction, correction and completion; rendering is excluded, sleeping disabled, timestep 1/60 and correction limit one.

- penetration: 444 chunks / 896 bonds / 1 projectile(s), 5 × 60 seconds. Mean 2.917 → 2.817 ms; peak 7.881 → 6.201 ms; steps over 8 ms 0 → 0.
- world-256: 113,664 chunks / 229,376 bonds / 1 projectile(s), 2 × 10 seconds. Mean 3.621 → 3.472 ms; peak 9.898 → 9.526 ms; steps over 8 ms 3 → 4.
- impacts-256: 113,664 chunks / 229,376 bonds / 256 projectile(s), 2 × 10 seconds. Mean 19.734 → 18.896 ms; peak 92.772 → 86.243 ms; steps over 8 ms 1038 → 1038.
- New timing gate: 144 buildings, 63,936 chunks / 129,024 bonds / one projectile, five × 60 seconds. Mean 3.058 ms, worst 7.786 ms, 0 missed 8 ms deadlines in 18,000 measured steps. This expands retained-world work; it does not establish a 144-impact limit or finish the frontier search.

The two residual-vector cache layouts were slower and were removed. Archived snapshots and captures document their rejection; no production cache branch remains. The new comparison generator verifies identical recorded commands and repetition counts before showing performance differences. Neither 256-building workload passes the 8 ms peak gate; CPU ownership/lifecycle changes, correction work and remaining stress cost still limit larger destruction.

## Retained GPU ownership and corrected bounds propagation

The 256-building simultaneous bombardment is the primary optimization workload. Retained shapes no longer cross the CPU ownership bridge or rebuild their persistent pair managers. True migrations still use the CPU lifecycle bridge. The complete GPU ownership transaction remains intact, and restored bounds now mark the existing GPU update flags so broad phase updates its endpoints correctly. No material equations, convergence tolerances, timestep or correction limit changed.

Two intermediate implementations were rejected: unconditional pair recreation created duplicate retained contacts; preserving pairs without dirty-bound propagation left stale endpoints and duplicate pairs after re-entry. Their report directories are explicitly marked rejected. A retained-contact mutation test catches the former, and the new 256-building CTest catches the latter. Neither rejected capture is a qualified speedup.

Eight focused native tests, the new three-second bombardment contact regression and final unfiltered retained-owner memory checking pass. The frozen ten-second penetration audit (444 chunks, 896 bonds, one projectile) preserves 398 supported chunks, 46 detached chunks, 199 broken bonds and its existing topology signature. The ten-second bombardment audit (113,664 chunks, 229,376 bonds, 256 projectiles) passes unique live shape pairs, contact ownership/connectivity, pre-solve metadata, collision/motion agreement and convergence checks over all 600 steps. It produces 14,219 peak clusters and 62,728 broken bonds. Renderer-buffer and full momentum audits remain incomplete.

[Generated three-scene timing and phase report](retained-owner-final-scaling/report.html) · [Bombardment comparison](retained-owner-final-comparison/report.html) · [Validation evidence](retained-owner-validation.json). Timing includes the complete command-to-accepted-state advance, with sleeping disabled, timestep 1/60 and correction limit one; rendering is excluded. The small scene passes five 60-second runs with a 6.663 ms worst step. The 256-building bombardment has a 63.505 ms worst step across two 10-second runs and misses 8 ms on 1,038 of 1,200 steps. These are diagnostic large-scene captures, not five-run qualification. Large fracture histories differ from the committed baseline, so no identical-trajectory speedup or complete physical parity is claimed.

Next work remains removing the CPU fragment/body lifecycle bridge and reducing validated correction work; sustained stress solve cost also remains material. This change does not complete GPU-only lifecycle ownership, sleeping, endurance or the 8 ms bombardment objective.

## Device queue for independent stress components

The small-component kernel now claims its next component from one persistent GPU work cursor. Fixed grid-stride assignment could strand costly components on a block after other blocks finished. The existing initialization kernel resets the cursor, so there is no additional host observation, allocation or clearing pass. Equations, convergence thresholds and per-component reduction order remain unchanged.

Six focused tests pass, including native bombardment/resimulation/publication, CPU numerical parity, analytic fixtures and unfiltered memory checking. The new fixture has 769 uneven components, 13,828 nodes and 13,059 bonds, and checks six quiet/load transitions with both cold and warm starts against analytic axial forces. The fixture explicitly orders host input production before the nonblocking solver stream; an initial missing event was a test harness defect, not a solver regression. Component-kernel synchronization and race checks pass; the previously recorded full CUB/conditional-graph synchronization issue remains unresolved.

The frozen 444-chunk / 896-bond penetration audit retains 398 supported chunks, 46 detached chunks, 199 broken bonds and the existing topology signature. The ten-second 256-building audit (113,664 chunks / 229,376 bonds / 256 projectiles) passes unique shape pairs, contact ownership/connectivity and collision/motion agreement, with 14,219 peak clusters and 62,728 broken bonds. All 600-step fracture/correction/contact/body count histories match the baseline. Stress iteration counts vary between runs, including baseline repeats; this is not a bit-identical-trajectory claim. Full render-buffer, momentum and lifecycle endurance qualification remain incomplete.

[Generated three-scene timings and phases](component-queue-scaling/report.html) · [Bombardment comparison](component-queue-comparison/report.html) · [Validation](component-queue-validation.json). Every timing includes commands through accepted simulation/destruction/correction and mandatory completion; rendering is excluded. Timestep is 1/60, correction limit one, sleeping disabled.

- penetration: 444 chunks / 896 bonds / 1 projectile(s), 5 × 60 seconds. Mean 2.368 → 2.318 ms; peak 6.663 → 6.512 ms; steps above 8 ms 0 → 0.
- impacts-16: 7,104 chunks / 14,336 bonds / 16 projectile(s), 2 × 10 seconds. Mean 4.633 → 4.630 ms; peak 10.162 → 10.358 ms; steps above 8 ms 39 → 39.
- impacts-256: 113,664 chunks / 229,376 bonds / 256 projectile(s), 2 × 10 seconds. Mean 18.661 → 12.145 ms; peak 63.505 → 63.634 ms; steps above 8 ms 1038 → 1038.

The bombardment average improves substantially, but its worst-step deadline remains failed. Separate profiling shows average stress time falling from 12.352 to 6.009 ms; the CPU lifecycle bridge and correction still dominate the largest fracture spike. Next deletion: the single-component convergence path need not perform a block-wide integer tally of one active flag. Full GPU lifecycle migration and correction work selection remain larger requirements.

## Delete the single-component convergence reduction

A resident CUDA block solves one component. Its convergence finalizer already produces the complete active count in one thread, so reducing that one flag through a block-wide shared-memory tree was unnecessary. The finalizer now publishes the flag directly for zero/one-component work; the caller's existing barrier preserves ordering. Floating-point operators, summation order, tolerance, material laws and correction limit are unchanged.

Six focused tests pass: native bombardment contacts, resimulation and publication; CPU numerical parity; resident analytic tests; and unfiltered GPU memory checking. Targeted component synchronization and race checks pass. The existing full CUB/conditional-graph synchronization issue remains unresolved. The frozen 444-chunk / 896-bond penetration audit preserves the existing topology signature, 398 supported chunks, 46 detached chunks and 199 broken bonds. The ten-second 256-building audit (113,664 chunks, 229,376 bonds, 256 projectiles) passes unique shape pairs, contact ownership/connectivity and collision/motion agreement. Every measured 600-step fracture/correction/contact/body count history matches the previous build. Stress iteration counts vary between repetitions; no bit-identical physical trajectory or full renderer/momentum/endurance qualification is claimed.

[Generated three-scene timing and phase report](component-tally-scaling/report.html) · [Bombardment comparison](component-tally-comparison/report.html) · [Validation](component-tally-validation.json). Timings cover commands through accepted physics/destruction/correction and mandatory completion, with timestep 1/60, correction limit one and sleeping disabled. Rendering is excluded.

- penetration: 444 chunks / 896 bonds / 1 projectile(s), 5 × 60 seconds. Mean 2.318 → 2.061 ms; peak 6.512 → 5.983 ms; steps above 8 ms 0 → 0.
- impacts-16: 7,104 chunks / 14,336 bonds / 16 projectile(s), 2 × 10 seconds. Mean 4.630 → 4.093 ms; peak 10.358 → 9.496 ms; steps above 8 ms 39 → 7.
- impacts-256: 113,664 chunks / 229,376 bonds / 256 projectile(s), 2 × 10 seconds. Mean 12.145 → 11.603 ms; peak 63.634 → 63.182 ms; steps above 8 ms 1038 → 1038.

Separate bombardment phase captures show average GPU stress time falling from 6.009 to 5.451 ms. The large-scene peak remains far above 8 ms; CPU fragment lifecycle/ownership and correction still dominate that spike. The next primary responsibility to migrate is native fragment lifecycle, not further tuning of its temporary CPU bridge.

## Reliable fragment-lifecycle timing

Detailed shape migration scopes initially exposed a measurement defect: the demo serialized profiler CSV inside the complete-step timer. That cost is now outside the timer, with recorded per-step timestamps and regression checks rejecting overlap with the current or following step. Tiny migration leaves record wall intervals without repeated thread-clock/ID syscalls; parent scopes retain CPU-clock accounting. The generated table includes commands and mandatory completion and explicitly compares instrumented versus untraced runs. No simulation equations or lifecycle behavior changed.

All 29 timing-accounting tests and three focused native correction/publication/bombardment tests pass. The frozen ten-second penetration quality audit passes unchanged. [Evidence](lifecycle-timing-validation.json) and [generated primary-workload breakdown](lifecycle-verified-impacts-256/report.html).

For 256 buildings / 113,664 chunks / 229,376 bonds / 256 projectiles, two ten-second untraced runs average 11.564–11.668 ms and peak at 63.496–67.850 ms. The separate ten-second instrumented run averages 11.714 ms and peaks at 62.732 ms. Timings cover commands through accepted physics/destruction/correction and mandatory status, with dt 1/60, correction limit one and sleep disabled. These are separate runs, not a decomposition of an untraced peak. Counter histories match; the 8 ms gate still fails.

At the scoped impact peak, CPU reservation takes 5.503 ms, owner/shape validation 6.803 ms, query/actor records 5.563 ms, and complete correction 29.800 ms. Inspection found that validation reconstructs a shape-ID hash table from source actors even though PhysX already owns a persistent shape-ID index. Deleting that copied representation is the next concrete deletion; it does not by itself remove the CPU allocation/ownership bridge. GPU lifecycle migration, selective correction, sleep, endurance and full qualification remain open.

## Delete reconstructed shape identities

The remaining native ownership bridge now resolves shape IDs directly through PhysX's persistent element index. It no longer walks every shape on source actors or builds a duplicate shape hash table. Bounds, liveness, source ownership, supported shape flags and duplicate-binding checks still validate the complete batch before mutation. The same GPU-produced migration order and physical state are used. This deletes redundant CPU work; it does not claim GPU-native body allocation or eliminate the remaining ownership bridge.

Six focused native tests pass. Added negative coverage rejects out-of-range/removed/foreign shape IDs, unlisted source owners, duplicate bindings, partially invalid batches and replacement shapes with another owner. The frozen 444-chunk / 896-bond ten-second penetration audit retains 398 supported chunks, 46 detached chunks, 199 broken bonds, both wall holes and the existing exact topology identity. The separate ten-second bombardment audit checks every chunk's collision/motion ownership, unique shape pairs, contact connectivity and convergence. All 600-step fracture/correction/contact/body counter histories match the baseline; stress iteration counts vary, as in previous repeats. Full large-scene renderer/momentum/endurance audits remain incomplete.

[Generated three-scene report](shared-shape-scaling/report.html) · [Primary complete-step breakdown](shared-shape-impacts-256/report.html) · [Identical-workload comparison](shared-shape-comparison/report.html) · [Validation evidence](shared-shape-validation.json).

Each diagnostic timing capture uses two ten-second untraced runs, plus a separate ten-second scoped run, dt 1/60, correction limit one and sleeping disabled. Timings include commands through accepted physics/destruction/correction and mandatory status; initialization/rendering/report I/O are excluded. No outliers are removed.

- Penetration: 444 chunks / 896 bonds / one projectile, 2.233 ms mean, 6.163 ms worst; no step over 8 ms in 1,200 measured steps. This short regression does not renew five-by-60-second qualification.
- Sixteen simultaneous impacts: 7,104 chunks / 14,336 bonds / sixteen projectiles, 4.130 ms mean, 9.676 ms worst; 12 of 1,200 steps over 8 ms.
- Primary 256-building simultaneous bombardment: 113,664 chunks / 229,376 bonds / 256 projectiles, 11.529 ms mean, 55.572 ms worst; 1,038 of 1,200 steps over 8 ms. The timestamp-verified baseline with identical commands measured 11.616 ms mean and 67.850 ms worst. Two repeats demonstrate an observed change, not a guaranteed peak bound.

The separate scoped impact validation cost drops from 6.803 to 0.741 ms. Its whole-step peak remains 63.244 ms versus 54.110–55.572 ms in untraced repeats; observer/scheduling effects remain explicitly visible. The report now exposes already-recorded trial/correction task spans, clearly marked overlapping and non-additive. Correction contact allocation/registration still performs CPU work. The next required architectural migration remains device-owned fragment/contact lifecycle and solver participation; no alternate CPU optimization architecture was added.


## GPU-owned contact lifetimes

Native GPU pair initialization now reserves globally unique scene-lifetime generations in block-sized batches. The allocator persists across pair-buffer growth, compaction and destruction reconfiguration. The CPU generation counter and retained identity mirror are deleted. Existing manifold initialization also initializes identities; primitive buckets use the same kernel without manifold work. Cache invalidation preserves lifetime identity. CPU-created island-edge IDs still require a four-byte staging upload per new pair, down from the former sixteen-byte identity upload. CPU contact/actor/edge creation and fragment lifecycle remain; this is not complete GPU lifecycle ownership.

Allocator exhaustion latches without wrapping. Trial and correction acceptance consume that state on the GPU; failed steps do not commit topology, material damage or accepted ownership. Seven focused tests pass, including concurrent allocation, slot reuse, tail guards, graph validation, native collision preparation, retained contacts, bombardment, resimulation, publication and deliberate trial/correction exhaustion. CUDA memory, synchronization and race checks pass for the contact-graph test executable. This does not resolve the separately recorded resident topology CUB/conditional-graph synchronization issue. Twenty-nine timing-accounting tests also pass.

The frozen ten-second penetration audit (444 chunks, 896 bonds, one projectile) retains 398 supported chunks, 46 detached chunks, 199 broken bonds, both wall holes, the exact existing topology history and collision/render agreement. The separate ten-second 256-building audit (113,664 chunks, 229,376 bonds, 256 projectiles) passes contact identity/connectivity and chunk motion/ownership checks with 14,219 peak clusters and 62,728 broken bonds. All recorded 600-step fracture/correction/body/contact histories match the previous build. Stress iteration counts vary between repeats, as in the baseline. The large audit does not include renderer-buffer or complete momentum tracing.

[Generated three-scene report](device-contact-scaling/report.html) · [Primary detailed phases](device-contact-impacts-256/report.html) · [Identical-workload comparison](device-contact-comparison/report.html) · [Validation evidence](device-contact-validation.json).

All three diagnostic campaigns contain two ten-second untraced runs and one separate ten-second phase capture. The complete advance includes commands, physics, destruction, correction and mandatory completion; initialization/rendering/report output are excluded. Timestep remains 1/60, correction limit one, sleeping disabled. No outliers are removed.

- Penetration: 444 chunks / 896 bonds / one projectile; mean 2.212 ms, worst 6.097 ms, zero of 1,200 steps above 8 ms. This short regression does not renew five-by-60-second qualification.
- Sixteen simultaneous impacts: 7,104 chunks / 14,336 bonds / sixteen projectiles; mean 4.097 ms, worst 9.330 ms, ten of 1,200 steps above 8 ms.
- Primary 256-building bombardment: 113,664 chunks / 229,376 bonds / 256 projectiles; mean 11.578 ms, worst 60.016 ms, 1,038 of 1,200 steps above 8 ms. The baseline averaged 11.529 ms and peaked at 55.572 ms on identical commands/durations. No end-to-end speedup is demonstrated by this migration.

The separate primary phase capture peaks at 64.086 ms: fragment reservation is 5.744 ms, CPU query/actor rebinding 6.221 ms, and complete correction 34.120 ms. Average GPU stress-stream time is 5.543 ms. These are instrumented-run measurements, not subdivisions of the untraced 60.016 ms peak; the generated report shows observer variation. Device-owned fragment/contact lifecycle and selective correction remain necessary, alongside stress/preconditioner work, sleeping, endurance and full qualification.


## Device-ordered fragment initialization

Fragment initialization now submits GPU validation and state writes without reading two status records back or waiting for a CPU verdict. Collision preparation consumes the initialization prerequisite on device; corrected-motion preparation consumes the collision prerequisite. The existing combined observation publishes all three verdicts before the remaining CPU ownership bridge. Rejected prerequisites overwrite all compaction sentinels. Reinitialization invalidates previous preparation receipts, and rejection clears a previously initialized count. Exceptional submission failures drain earlier writers before publishing an error. No physical equations, solver settings or accepted load/damage ordering changed.

Eight affected native tests pass, together with 29 timing-accounting tests and a zero-error GPU memory check of the correction-body fixture. New coverage submits invalid initialization across different CUDA streams after a previously valid batch and checks stale-state rejection, unchanged motion, topology and damage, for TGS and PGS. A separate fault injected at the actual scene task-graph initialization boundary verifies rejection before ownership mutation and correction. The initialization/collision/correction timing labels now describe the combined observation boundary explicitly.

The frozen ten-second penetration audit (444 chunks, 896 bonds, one projectile) preserves both wall holes, 398 supported chunks, 46 detached chunks, 199 broken bonds, the existing exact topology history and collision/render agreement. The ten-second 256-building audit (113,664 chunks, 229,376 bonds, 256 projectiles) passes contact identity/connectivity and chunk motion/ownership checks, reaching 14,219 clusters and 62,728 broken bonds. All 600-step fracture/correction/body/contact counter histories match the preceding build. Stress iteration counts vary between repeated runs, as before. Full large-scene renderer/momentum and lifecycle endurance qualification remain open.

[Generated three-scene timing report](device-initialization-scaling/report.html) · [Primary detailed phases](device-initialization-impacts-256/report.html) · [Identical-workload comparison](device-initialization-comparison/report.html) · [Validation evidence](device-initialization-validation.json).

Each diagnostic uses two ten-second untraced runs plus a separate ten-second phase capture; timestep 1/60, correction limit one, sleeping disabled. Complete advances include commands through accepted physics/destruction/correction and mandatory completion; initialization/rendering/report output are excluded. All measured steps remain.

- Penetration: 444 chunks / 896 bonds / one projectile; mean 2.229 ms, worst 6.135 ms, zero of 1,200 steps above 8 ms. This does not renew five-by-60-second qualification.
- Sixteen simultaneous impacts: 7,104 chunks / 14,336 bonds / sixteen projectiles; mean 4.108 ms, worst 9.677 ms, twelve of 1,200 steps above 8 ms.
- Primary bombardment: 113,664 chunks / 229,376 bonds / 256 projectiles; mean 11.554 ms, worst 54.048 ms, 1,038 of 1,200 steps above 8 ms. The identical-input preceding build measured 11.578 ms mean and 60.016 ms worst. The mean is effectively unchanged; two repeats do not establish a reliable peak improvement.

The separate scoped primary peak is 62.630 ms: CPU body reservation 6.298 ms, CPU query/actor rebinding 5.722 ms and complete correction 33.822 ms. Average GPU stress-stream time is 5.455 ms. These are not subdivisions of the untraced peak. This increment removes an intermediate host decision; it does not remove CPU fragment allocation, contact/actor lifecycle, the final completion wait or full correction. Persistent contact reuse through ownership changes requires coordinated actor, edge, filtering and solver-reference updates; retaining old managers alone would leave stale dependencies. Those migrations, selective correction, GPU preconditioning, sleeping and full qualification remain unfinished.


## GPU-selected native motion addresses

CUDA now assigns stable compact fragment requests to a persistent native-address grant and commits consumption only after accepted correction. CPU resource growth grants indices without constructing nodes, BodySims or active bodies. The remaining CPU compatibility bridge constructs records at the exact GPU-selected indices; it cannot choose replacements. The CPU-selected index upload and host overwrite of GPU allocation status are deleted. Capacity growth has its own timing row and remains inside complete-step timing. The public device view distinguishes committed, pending and unused capacity.

Nine native tests and 29 timing-accounting tests pass. New checks cover stable assignment, rejected capacity/mapping/registration, retry without double consumption, deferred retirement, duplicate/ordinary address rejection and overflow before allocation. Native allocation and standalone production allocation kernels pass GPU memory checking; the allocation-kernel fixture also passes synchronization checking. This does not resolve the separate resident topology CUB/conditional graph synchronization qualification gap.

The final ten-second penetration audit preserves the exact frozen topology signature, 398 retained of 444 chunks, 46 detached chunks and 199 broken of 896 bonds, both wall holes, projectile clearance and collision/render agreement. The final 256-building audit covers 113,664 chunks, 229,376 bonds and 256 projectiles for 600 steps, with 14,219 peak clusters, 62,728 broken bonds, 224 corrected steps, zero chunk motion error and zero failures across 1,648 contact/island boundary audits. Every recorded large-scene fracture/correction/body/contact counter history matches the preceding build; stress iteration counts retain baseline variation. Full large-scene renderer/momentum and lifecycle endurance qualification remain open.

[Generated scaling report](device-motion-slots-scaling/report.html) · [Primary detailed phases](device-motion-slots-impacts-256/report.html) · [Identical-workload comparison](device-motion-slots-comparison/report.html) · [Validation evidence](device-motion-slots-validation.json).

Timing: two ten-second untraced runs plus a separate ten-second phase capture per case, timestep 1/60, correction limit one, sleeping disabled. Complete advance includes commands, physics, destruction, correction, capacity growth and mandatory completion; preparation/rendering/report output are excluded. Every measured step remains. One-building and sixteen-building idle controls are also included. These short diagnostics do not establish five-by-60-second or endurance qualification.

- One building, projectile penetration: 444 chunks / 896 bonds / 1 projectiles; mean 2.234 ms, worst 6.382 ms, 0 of 1,200 steps above 8 ms.

- 16 buildings, simultaneous aerial impacts: 7,104 chunks / 14,336 bonds / 16 projectiles; mean 4.111 ms, worst 9.416 ms, 11 of 1,200 steps above 8 ms.

- 256 buildings, simultaneous aerial impacts: 113,664 chunks / 229,376 bonds / 256 projectiles; mean 11.548 ms, worst 59.478 ms, 1,038 of 1,200 steps above 8 ms.


The primary mean is effectively unchanged from 11.554 ms; the prior observed maximum was 54.048 ms. No end-to-end speedup is established. The separate instrumented peak is 60.003 ms: CPU compatibility-body construction 6.697 ms, CPU query/actor rebinding 5.896 ms, complete correction 30.318 ms and exceptional address growth 0.043 ms. Average stress-stream time is 5.487 ms. These phase values belong to the instrumented run, not the untraced 59.478 ms maximum.

GPU motion-slot selection is complete for the present scene-lifetime allocation transaction. This is not full GPU fragment/contact lifecycle: CPU compatibility construction, ownership observations and contact/actor scheduling still remain. Slot storage is reclaimed at runtime clear; general per-asset retirement/reinsertion and generation/handle endurance remain unqualified. Next priorities remain device-owned lifecycle/contact dependencies, GPU correction work sets, resident preconditioning, validated sleeping/activity and the full scaling/endurance gates.


## Delete query-geometry reconstruction during native splits

GPU exclusive shapes now use immutable shape identity in the built-in CPU query pruner. Query hits resolve the current exclusive owner instead of copying mutable ownership into pruner payload keys. This preserves secondary-pruner hash/cache invariants. Native splits retain query handles, geometry, bounds, transforms and dirty registrations; they update only owner lookup and compatibility shape-array membership. The previous remove/reinsert and CPU bounds/transform reconstruction are deleted. Shared shapes and ordinary CPU scenes retain actor-specific payloads. Native destruction rejects unsupported custom query ownership implementations before shape mutation; it does not silently rebuild through a fallback.

Twelve focused native tests and 29 timing-accounting tests pass. Real corrected impacts additionally check persistent query handles, cached/uncached raycasts, overlap, sweep, owner filtering and forced query-tree rebuild. Ordinary CPU/GPU controls check both exclusive and shared shapes, removal and rebuilding. GPU memory checks pass for native resimulation and simultaneous ownership/shape-buffer growth. This is not full resident conditional-graph synchronization qualification.

Broader qualification exposed a bounds-growth failure. The GPU update-flag buffer could lag newly grown shape storage before the end-of-step descriptor reset. Separate commit `130f704c` grows that buffer while preserving pending commands, zeros only new capacity, and updates its existing device descriptor pointer with stream ordering. The strengthened regression combines 257 ownership requests, 1,100 new static shapes and an unrelated ordinary GPU pose-command collision. No assertion was weakened; the original failed test log remains in the evidence.

The ten-second frozen penetration audit preserves the exact topology signature, 398 supported of 444 chunks, 46 detached chunks, 199 broken of 896 bonds, both wall holes and collision/render agreement. The separate ten-second 256-building audit covers 113,664 chunks, 229,376 bonds and 256 projectiles, reaching 14,219 clusters, 62,728 broken bonds and 224 corrected steps. Its chunk motion error is zero and all 1,648 contact/island boundary audits pass. Every recorded 600-step large fracture/correction/body/contact counter history matches the previous build. Full large-scene renderer/momentum, automatic CPU pose-query freshness and lifecycle endurance remain unqualified.

[Generated scaling report](persistent-query-scaling/report.html) · [Primary detailed timing](persistent-query-impacts-256/report.html) · [Identical-workload comparison](persistent-query-comparison/report.html) · [Validation evidence](persistent-query-validation.json).

Each timing case has two ten-second untraced runs and a separate ten-second instrumented capture: timestep 1/60, correction limit one, sleeping disabled. Complete advances include recorded commands, physics, destruction, correction, runtime growth and mandatory completion; initialization/rendering/report generation are excluded. Every measured step remains. These diagnostics do not establish five-by-60-second or endurance qualification.

- One building, projectile penetration: 444 chunks / 896 bonds / 1 projectiles; mean 2.225 ms, worst 5.796 ms, 0 of 1,200 steps above 8 ms.

- 16 buildings, simultaneous aerial impacts: 7,104 chunks / 14,336 bonds / 16 projectiles; mean 4.135 ms, worst 9.461 ms, 10 of 1,200 steps above 8 ms.

- 256 buildings, simultaneous aerial impacts: 113,664 chunks / 229,376 bonds / 256 projectiles; mean 11.428 ms, worst 49.302 ms, 1,038 of 1,200 steps above 8 ms.


The primary observed worst complete step decreases from 59.478 to 49.302 ms; means change from 11.548 to 11.428 ms. Both new repeats peak below both preceding repeats, but this is a short comparison, not a deadline guarantee. In the separate phase captures, worst-step query/owner cost decreases from 5.896 to 1.591 ms. The current scoped complete peak is 55.081 ms, including 6.764 ms CPU compatibility-body construction and 30.071 ms complete correction. Average GPU stress-stream time is 5.473 ms. Instrumented values are not subdivisions of the untraced peak.

CPU fragment/contact lifecycle, remaining owner metadata observations and full correction still dominate split-time cost. This deletion preserves the intended separation of persistent geometry and changing motion ownership; it does not make CPU query mirrors GPU-resident or finish the native lifecycle migration. Device-owned contact/body scheduling, selective correction, resident preconditioning, validated sleep/activity and full scaling/endurance qualification remain active requirements.

## GPU actor-pair canonicalization: migrated and validated, not a material speedup

Native destruction now sorts and removes duplicate actor pairs on the producing GPU stream before publication. It reuses the existing raw/partitioned PhysX report buffers, retaining raw counts for aggregate handling and overflow diagnostics. The only new persistent scratch is two unsigned tile offsets per 1,024-pair tile of configured capacity. Device counts bound sorting, merge, scan and compaction; no pair-count readback or host decisions occur between stages. CPU pair sorting is retained only for unrelated non-native PhysX operation. Native invalid/overflow batches abort explicitly instead of accepting a truncated contact set.

The implementation uses block radix sorting, stable descending merge ranks, and stable unique compaction. It preserves exact CPU pair ordering, including duplicate keys across tiles and merge runs. Fifty-five production-kernel batches cover empty/singleton inputs, non-power-of-two tails, repeated buffer reuse, all-equal keys, invalid pairs, capacity overflow and up to 1,048,577 pairs. Memory/synchronization/race checks pass. Fifteen integrated native tests and 29 timing tests pass; no assertions were weakened.

The frozen 10-second wall audit preserves 398 supported chunks, 46 detached chunks, 199 broken bonds, exact topology identity, entry/exit holes, clearance step 39, zero collision/render position mismatch and the prior COM tolerance. The separate 256-building audit retains 14,219 peak clusters, 62,728 broken bonds, 224 corrected steps, zero motion mismatch and 1,648 boundary audits with zero failures; it does not enable the expensive large-scene render/COM trace. All 3,600 compared timing steps match prior fracture/correction/cluster/body/contact counter histories.

Each timing case is two untraced 10-second runs plus a separate phase capture, dt=1/60, correction limit one, sleeping disabled. Complete advance includes commands, projectile insertion, physics, destruction, correction and mandatory completion; initialization/rendering/reporting are separate. Every measured spike is retained.

| Case | Chunks | Bonds | Projectiles | Mean complete ms | Maximum complete ms | >8 ms / 1,200 steps |
|---|---:|---:|---:|---:|---:|---:|
| One building, projectile penetration | 444 | 896 | 1 | 2.268457 | 6.245235 | 0 |
| 16 buildings, simultaneous aerial impacts | 7104 | 14336 | 16 | 4.159149 | 9.466100 | 10 |
| 256 buildings, simultaneous aerial impacts | 113664 | 229376 | 256 | 11.379837 | 50.600128 | 1038 |

The comparison does not demonstrate a material end-to-end speedup. This step removes a CPU responsibility from the native data flow; it does not remove the dominant CPU contact creation/registration or fragment compatibility lifecycle. These remain the next structural migration targets. The 8 ms peak and full plan gates remain unmet.

Generated reports: [primary 256-building breakdown](native-pairs-impacts-256/report.html), [same-input comparison](native-pairs-comparison/report.html), [three-scene scaling](native-pairs-scaling/report.html). Evidence: [validation](native-pairs-evidence/validation.json).

## Broad-phase warp scheduling and explicit GPU wait accounting

A synchronized 3-second diagnostic of the 256-building simultaneous bombardment (113,664 chunks, 229,376 bonds, 256 projectiles) showed that correction step 82 spent 7.943691 ms in GPU incremental SAP inside a 9.091029 ms CPU broad-phase scope. The CPU thread spent that interval largely spinning for GPU completion. It was incorrect to treat this entire span as CPU contact bookkeeping; the reports now explicitly expose the nested broad-phase wait. These diagnostic task/kernel durations do not replace untraced complete-step measurements.

Deleted incremental comparison work for refiltered handles: those comparisons were already unconditionally rejected by the consumer and handled by the ownership/insertion discovery pass. This alone was not a useful large-scene speedup. The remaining incremental kernel now shares range lookup within warps and emits reports with warp ballots/aggregated allocation, removing block-wide report scratch/scans/barriers. The actual comparisons, filtering, geometry predicates and complete found/lost sets remain unchanged.

A tempting shortcut that skipped unchanged endpoints failed the new independent brute-force oracle: seed 51, 17 AABBs, minimum/maximum-only movement, 31 found pairs instead of 33. It was removed before building the production SDK. The validated scheduling alternative passed 120 production GPU transition cases (2–257 AABBs, no stress bonds), memory/synchronization/race checks, 15 focused native tests and 30 accounting tests. The isolated candidate was validated before the initially rejected production application was re-reviewed and approved.

The later 3-second trace measured 6.129073 ms for incremental SAP within a 7.408086 ms broad-phase span at the same correction step. This is about 23% less kernel time in that diagnostic comparison, not a proven equivalent reduction in full-step peak or mean. Hardware counters were denied by the host driver permissions; no bandwidth/occupancy classification is asserted.

The final frozen wall audit preserves exact topology and hole identities, 398 supported chunks, 46 detached chunks, 199 broken bonds, clearance step 39, zero render/collision position mismatch and the prior COM tolerance. The 10-second large audit preserves 14,219 peak clusters, 62,728 broken bonds, 224 corrected steps, zero motion mismatch and 1,648 contact/island boundary audits with zero failures. It does not enable a full large-scene render/COM trace. All 3,600 compared counter-history steps across the following scenes match the prior build.

Final complete-advance measurements: two untraced 10-second runs per scene plus separate phase captures; dt=1/60, correction limit one, sleeping disabled. Commands, insertion, physics, stress/destruction, correction and mandatory completion are included. Initialization/rendering/reporting are separate and every measured spike is retained.

| Case | Chunks | Bonds | Projectiles | Mean complete ms | Maximum complete ms | >8 ms / 1,200 steps |
|---|---:|---:|---:|---:|---:|---:|
| One building, projectile penetration | 444 | 896 | 1 | 2.270760 | 6.194569 | 0 |
| 16 buildings, simultaneous aerial impacts | 7104 | 14336 | 16 | 4.154065 | 9.428579 | 8 |
| 256 buildings, simultaneous aerial impacts | 113664 | 229376 | 256 | 11.395363 | 49.174363 | 1038 |

There is no material overall throughput improvement established by these runs, and the 8 ms peak gate remains unmet. Further work includes the CPU fragment/contact compatibility lifecycle, GPU correction work selection, stress/preconditioning, sleep/joint support and full endurance/deadline qualification.

Generated reports: [full primary breakdown](warp-incremental-impacts-256/report.html), [GPU execution versus CPU waiting](warp-incremental-gpu/report.html), [same-input comparison](warp-incremental-comparison/report.html), [three-scene scaling](warp-incremental-scaling/report.html), [validation](warp-incremental-evidence/validation.json).

## Rejected residual caching and worker-count experiments; stronger topology regression

The primary workload remains 256 buildings, 113,664 chunks, 229,376 bonds and 256 simultaneous aerial projectiles. Each implementation below ran two untraced 10-second repetitions plus a separate phase capture, timestep 1/60, correction limit one, sleeping disabled. Complete advance includes commands, physics, stress/destruction, correction, runtime growth and mandatory completion. Initialization/rendering/report generation remain separate and every measured peak is retained.

Four alternatives were tested and removed: an array-of-structures shared residual, a coordinate-separated shared residual, maximum occupancy-sized resident workers, and one worker per multiprocessor. The shared layouts rebuilt an inverse chunk order only on GPU topology changes and used the existing operator, recurrence and reductions. The worker variants changed only integer dispatch capacity. Neither layout nor worker change improved this workload. All four patches are retained as rejected evidence, not selectable production paths.

Complete-step means were 13.486 ms (shared AoS), 13.149 ms (shared SoA), 12.462 ms (maximum workers) and 11.571 ms (one worker), compared with the rebuilt original's 11.379 ms. The rebuilt original's maximum was 51.781 ms, with 1,038 of 1,200 steps exceeding 8 ms. Its separate phase capture attributes 5.537 ms average stream time to stress. These are diagnostic measurements, not a five-by-60-second or endurance qualification. No speedup is claimed; the production solver is fully restored. Higher worker occupancy and shared-memory placement are not, by themselves, evidence of faster complete simulation.

All alternatives and the restored implementation passed CPU numerical parity, resident analytic tests and CUDA memory checking. Their frozen 444-chunk / 896-bond single-projectile wall audits preserve 398 supported chunks, 46 detached chunks, 199 broken bonds, exact topology signature, clearance step 39, entry/exit holes and zero collision/render position mismatch. All 6,000 candidate/restored large-scene steps compared against the earlier retained build match fracture, correction, cluster, body and contact counters; this is narrower than full large-scene trajectory or exact bond-identity equivalence.

The retained code change is an analytic regression: a free 1,040-chunk / 1,039-bond structure with permuted authored IDs transitions from one cooperative component to two 520-chunk components and then four 260-chunk components. Twelve warm/quiet/load solves check exact topology generations, convergence and analytic surviving-bond forces at the existing 2e-4 absolute tolerance. Cuts carry zero force in the independent analytic mode; no solver-generated expected forces are used. This protects future GPU component layouts and preconditioning across splitting.

Next structural priorities remain GPU-resident multilevel preconditioning and the CPU fragment/contact lifecycle migration. Normal native solves currently reject settled-result skipping, so simply bypassing components based on previous activity is not a valid optimization under the current fidelity contract. The performance, sleep/joint, lifecycle, selective-correction and endurance requirements remain incomplete.

[Generated implementation comparison](component-residency-comparison/report.html) · [Restored primary timing breakdown](component-restored-impacts-256/report.html) · [Validation and rejected patches](component-residual-evidence/validation.json).

Reproduce the retained numerical regression and diagnostic benchmark:

```sh
cmake --build out/destruction-sdk --target gpu_resident_stress_test gpu_resident_stress_parity_test -j4
ctest --test-dir out/destruction-sdk -R '^blast_stress_gpu_resident_(analytic|cpu_parity|memory)$' --output-on-failure
python3 tools/scripts/run-destruction-penetration-regression.py out/NEW-wall-quality
python3 tools/scripts/run-destruction-timing.py out/NEW-bombardment --config tools/profiles/destruction-scaling.json --case impacts-256 --trials 2 --seconds 10 --gate-only --phase-scopes --report-output qualification/NEW-bombardment
```

## GPU hierarchy construction foundation (not yet a solver speedup)

A single cooperative CUDA kernel now builds connected preconditioner aggregates
and the exact coarse sparse factor from resident CSR, component labels and bond
coefficients. Persistent device generations control construction; unchanged
accepted graphs skip rebuilding. Rejected transactions preserve outputs, while
invalid builds fail explicitly. No CPU matrix assembly or numerical readback is
used. This code is currently qualified independently, not linked into the native
production solve; transfer/application and multilevel integration remain next.

Captured-graph correctness, memory/leak, synchronization and race checks all pass.
Fixtures include static boundaries, singleton/empty graphs, split/restore states,
internal coarse self-edges, a 257-node star and a 100,000-node / 199,997-bond graph.
Small fixtures check every coarse basis column against an independent B^T P
calculation at 2e-12 scaled tolerance. The large fixture verifies connectivity
and canonical ownership, not every basis column. A multi-kernel conditional
construction was rejected after sanitizer failures; the retained cooperative
implementation passes the complete checks without filtering or suppressions.

The frozen ten-second single-projectile regression (444 chunks, 896 bonds,
dt=1/60, one correction maximum) passes: 398 supported chunks, 46 detached,
199 broken bonds, exact topology/hole identities and clearance step 39.
The production solver remains unchanged, so no simulation speedup is claimed.
The 256-building benchmark, full GPU lifecycle migration, sleep/joint support,
selective correction and endurance/8 ms peak gates remain incomplete.

[Construction validation](resident-hierarchy-construction/validation.json) ·
[Automated test results](resident-hierarchy-construction/tests.log) ·
[Frozen wall regression](resident-hierarchy-construction/wall-quality.json).

## Resident transfers and sparse coarse application

The first-level hierarchy now applies its rigid prolongation P, restriction P^T
and exact sparse coarse operator P^T L P on the GPU. It reuses seed adjacency
instead of constructing/sorting a second membership CSR, handles parallel bonds
without duplicate contributions, and uses deterministic warp sums rather than
floating-point atomics. No CPU assembly, numerical transfer, per-application
allocation or temporary per-bond response vector is required. Construction
validates shared inertia/positions; operator kernels read accepted state.

The captured-graph correctness, memory/leak, synchronization and race checks all
pass. Independent small-fixture full-basis comparisons and large-fixture vector
checks use 2e-12 scaled tolerance. Tests include six free rigid modes, adjointness,
nonnegative energy, repeatability, invalid mass scaling and recovery, plus six
topology transitions on 100,000 nodes / 199,997 bonds. This is a sparse algebra
fixture, not the 256-building simulation. The frozen ten-second 444-chunk /
896-bond, one-projectile penetration regression remains exact with correction
limit one: 398 supported chunks, 46 detached and 199 broken bonds.

This code is still independent of production CGLS. Next are smoothing, recursive
coarsening/coarse solve, native integration and primary-workload qualification.
No new simulation performance result or full-plan completion is claimed.

[Operator validation](resident-hierarchy-operator/validation.json) ·
[Tests](resident-hierarchy-operator/tests.log) ·
[Wall audit](resident-hierarchy-operator/wall-quality.json).

## Resident local factors for multilevel smoothing

GPU hierarchy construction now builds exact per-chunk 6x6 block-diagonal
Cholesky factors directly from shared fine coupling. Each warp retains only
21 lower-triangle coefficients and performs forward/back substitution on the
GPU. This supplies the local solve needed by the upcoming V-cycle. It does not
assemble an inverse, estimate a spectrum on the CPU, allocate in an iteration or
fall back to a different solver. A bond-energy inequality certifies L <= 2J for
the fine operator, providing a safe smoothing interval. Coarse levels require
their own qualification.

The independent checks compare local solves against the original coupling
equations at 2e-12 scaled tolerance, including every scalar basis load in small
fixtures. They also cover native-style omitted isolated dynamic rows, rejection
of omitted live rows, failure on an unfactorable finite-input block, recovery
after failure, and a 100,000-node / 199,997-bond sparse fixture through six
transitions. Captured correctness, CUDA memory/leak, synchronization and race
checks pass. The frozen ten-second wall remains exact (444 chunks, 896 bonds,
one projectile, dt=1/60, correction limit one, 398 supported, 46 detached,
199 broken bonds). No tolerance was loosened.

These are still private hierarchy qualification targets, not a production
preconditioner. Recursive coarsening, a null-space-safe terminal solve, resident
V-cycle/CGLS integration, affected-component reuse and primary-workload timing
remain. No new simulation speedup or 8 ms qualification is claimed.

[Local factor report](resident-hierarchy-diagonal/report.md) ·
[Validation](resident-hierarchy-diagonal/validation.json).

## Recursive GPU hierarchy and compact sparse levels

Recursive construction now keeps counts, coefficients, canonical CSR, ancestry
and generation/recovery decisions on the GPU. One cooperative packing kernel
replaces the rejected conditional CUB implementation. It processes used extents,
reuses persistent scratch, applies stable tiled radix sorting and parallel row
prefixes, and deletes only exact-zero coarse rows/columns. The original fine
physical operator and state are unchanged. An error-gate race found during
qualification was fixed with a uniform device decision before the next stage.

The complete captured correctness, memory/leak, synchronization and race suite
passes without relaxed tolerances or timeouts. It covers three levels for small
fixtures and eight for a 100,000-node / 199,997-bond sparse graph across six
transitions. The initial connected state reaches 66 packed nodes / 195 bonds
and then 30 aggregate groups at the eighth level. These are algebra sizes, not
a claim about fewer physical chunks/bonds. Independent original-fine equations
validate composed factors and coarse application at 2e-12 scaled tolerance;
small fixtures sweep full basis columns. Reuse, rejected publication, overflow,
stale upstream generations, invalid origins and recovery are also checked.

The frozen ten-second 444-chunk / 896-bond one-projectile wall audit remains
exact with correction limit one: 398 supported chunks, 46 detached, 199 broken
bonds, the same hole identities and clearance, and unchanged production binary
hashes. Terminal solve, compact-vector V-cycle, native CGLS integration and
affected-component reuse remain before benchmarking a candidate. The primary
256-building scene, full GPU lifecycle/sleep/joint/selective-correction work and
8 ms/endurance gates are still incomplete. No simulation speedup is claimed.

[Generated recursive report](resident-hierarchy-recursive/report.md) ·
[Validation and rejected experiments](resident-hierarchy-recursive/validation.json).


## Compact hierarchy transfers and current-level operator

Direct GPU transfers now address compact level vectors without an intermediate copy. The current-level CSR operator passes independent original-fine-equation checks, including recursive self-edge moments. Correctness/memory/synchronization/race checks and the frozen 10-second 444-chunk / 896-bond wall regression pass. See `resident-hierarchy-transfers/report.md`. Production integration remains unfinished; no new 256-building performance claim.


## Native component-order contract for resident coarse levels

Packing consumes the GPU partition and retains component-contiguous coarse vectors/ranges without another sort. Exact equations/transfers, corruption/recovery, CUDA memory/synchronization/race audits, and the frozen 10-second 444-chunk / 896-bond penetration regression pass. See `resident-hierarchy-partitions/report.md`. Terminal factors, V-cycle and production binding remain; no 256-building speedup is claimed.


## Resident small-component terminal factors and solves

GPU terminal factors/triangular solves now pass independent equations, symmetry, free-body and explicit failure/recovery checks at the existing tolerance. All CUDA safety audits pass, including large application scheduling within the 100,000-node / 199,997-bond hierarchy. The frozen 10-second 444-chunk / 896-bond wall fixture remains exact. See `resident-hierarchy-terminals/report.md`. Terminal retirement/shared storage, coarse smoothers, V-cycle and production CGLS integration remain; no new production performance result is claimed.
