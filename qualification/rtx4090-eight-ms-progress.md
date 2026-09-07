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
