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
