# Snapshot repeatability and topology ordering fixes — investigation

The original 52-case baseline had nine city health-equality failures. The fixed-order
parallel contact candidate now passes **all 52 cases × 20 independent restores: 1,040 ticks**.
The original frozen replay executable, saved inputs and comparisons are unchanged.
This work keeps physical snapshots, one complete tick per restore, the current
material/convergence settings, and restore/validation outside timing. No speedup
is claimed from diagnostic controls. Installed SDK artifacts remain unchanged. The verified contact-order source fix
is now applied to the working tree; performance acceptance and the older native
qualification gaps remain separate.

## Contact accumulation

In city25 post-impact, all 19 repeats after the reference have differing node
accelerations and surface loads. One repeat propagates the difference into
3,649 bond-force components and two bond health values (maximum 5.960464478e-8).
The source uses concurrent floating-point atomics for contact loads.

A fixed-order, one-thread diagnostic produces byte-identical loads, forces and
health over 20 repeats of that input. The 113,664-chunk late-debris input also
passes all 20 repeats with this control (11,051 new broken bonds, 16,135 output
clusters). This diagnostic is not a production performance candidate.

The parallel candidate sorts integer contact references by authored chunk and
pair/side ordinal, then gives each chunk one writer for load accumulation.
It processes chunks in parallel and retains every contact contribution and
material setting. All 20 post-impact repeats match the fixed-order control's
node accelerations, surface loads, bond forces, health and active bonds byte
for byte. The parallel candidate also passes all 20 repeats of the 113,664-chunk late-debris input. All 52 restored scenarios now pass; continuous physical regression checks are reported separately below.

## Candidate mechanism and acceptance checks

The candidate adds two 64-bit references per contact pair and a second equally
sized sorted array (32 bytes per pair total), plus CUB scratch storage. Capacity
is retained across ticks. First-use allocation and sorting occur inside the
complete-step interval. There is no new contact readback, CPU decision or
explicit CPU/GPU wait. Contact normal/friction counters and the strain-rate
maximum are still updated once per pair; forces, torques and virials have one
writer per chunk. Each contribution keeps the existing float formula and a
round-to-nearest addition. No health or convergence tolerance changes.

This is a reproducibility fix, not yet a performance improvement. Acceptance
requires the full restored-input suite and continued physical regression checks;
any additional sort/allocation cost must remain visible in full-step results.
The fixed order is defined by the current contact pair ordinal, so it does not
promise universal bitwise determinism if the upstream contact producer changes
its pair ordering on another scene, GPU or software revision.

## Native memory-check controls

All controls use the same city25 initial-impact snapshot and two independent
one-tick restores. Successful controls reproduce 3,412 new broken bonds,
537 output clusters, one correction, two stress evaluations and 304 iterations.

| Control | Result |
|---|---|
| Production topology graphs | 114 errors |
| Compile-time topology instrumentation | 6,817 errors |
| Explicit launches with synchronized decisions | PASS, zero errors |
| Existing graphs, device synchronization before and after | PASS, zero errors |
| Existing graphs, synchronization only before | PASS, zero errors |
| Existing graphs, synchronization only after | 155 errors |
| Existing graphs, incoming ready-event synchronization | PASS, zero errors |
| One-time graph upload during initialization | Fails; see controls.json |

These native controls show sensitivity to execution timing and incoming
dependencies. They do not establish a missing application dependency or a
universal synchronization workaround; the CUDA-only control below also fails
with a host event wait. A candidate that lets the native topology
transaction borrow the producer's execution stream still fails (97 findings);
sharing that stream is not a demonstrated fix.

Exact commands, input/module hashes and results are in [controls.json](controls.json).
Raw build scripts, focused patches and logs are under
`out/snapshot-large-20260911/`. The original failures remain failures.

## Delayed standalone producer

The production standalone topology test normally passes memcheck. Adding only
a one-thread GPU delay before the existing producer ready-event record makes
its 100,000-chunk transaction fail with 2,612 findings in `connect`, again
described as out of bounds while inside the live 400,000-byte label allocation.
The modified test passes plain. This reproduces the exposure without native
physics or snapshots. The original stream wait remains present and no topology
data or allocation was changed.
Raw: `out/snapshot-large-20260911/delayed-topology-repro/`.


## CUDA-only control and current priority

A separate reduction uses CUDA and the C++ standard library only: 100,000 labels,
200,000 edges, reset/connect/flatten kernels and nested conditional graphs.
Ordinary `cudaMalloc` allocations and their initialization finish before graph
execution. Plain execution passes. One memcheck control reports 2,416 errors
with a producer delay **and a completed host event wait**, again reporting an
atomic inside its live allocation as out of bounds. The delayed event-only,
no-delay and flat-graph memcheck controls pass in this cohort. This demonstrates
that snapshots and PhysX are not required to expose the diagnostic failure;
it does not yet identify the defective component or excuse the native failure.
Raw commands and all outcomes: `out/snapshot-large-20260911/delayed-cuda-repro/`.

The contact-order fix is independent of this investigation. Its default-graph
native memcheck still reports 113 errors. No synchronization diagnostic is
included in the contact candidate, and no sanitizer suppression was added.

Candidate commit: `a68fd705cec9e6f64a65d0ca116a910331b6a1d3`, on isolated branch
`codex/snapshot-stable-routing-20260911`. The full 52-case, 20-restores-per-case campaign completed successfully in
`out/snapshot-large-20260911/stable-suite/`, using the original frozen replay
executable and unchanged comparisons. Focused physical regressions follow it.


## Completed one-tick suite

[Every scenario, stage, spread and exact budget misses](timings.md) and
[machine-readable verification](verification.json). All 1,040 ticks passed the
existing convergence/correction, physical-state and repeatability checks; observed
position and velocity differences are zero. The check also verifies exact input
and loaded module hashes, twenty samples per scenario, and that command +
simulate/fetch + completion equals each complete-step measurement.

| Buildings / chunks / bonds | Restored idle mean / max ms | Initial impact mean / max ms | Late debris mean / max ms |
|---|---:|---:|---:|
| 25 / 11,100 / 22,400 | 9.782 / 12.846 | 40.391 / 50.071 | 70.379 / 90.692 |
| 64 / 28,416 / 57,344 | 15.999 / 19.102 | 64.118 / 80.362 | 134.623 / 171.881 |
| 256 / 113,664 / 229,376 | 62.324 / 82.158 | 242.483 / 278.238 | 403.159 / 502.157 |

Each entry is 20 complete ticks, dt 1/60, ordinary TGS with sleeping enabled.
Idle has zero projectiles; impact/debris snapshots come from one simultaneous
25/64/256-projectile wave. Idle >16.667 ms counts are 0/20, 3/20 and 20/20;
all displayed impact/debris cases miss that budget 20/20. Full >8 ms and >120 Hz
counts, active topology and stage evidence are in the linked report. These are
shared-GPU descriptive measurements, not matched A/B speedup claims or warm
continuous gameplay timings.

Summed harness time: **1,036.48 seconds (17 min 16 s)**. Measured full ticks:
**59.08 seconds**. Excluded restoration: **579.74 seconds**. The remaining
397.66 seconds cover context initialization, validation, teardown and harness
observation. This suite runs only one physics tick per restore; reconstruction
and checking still dominate its wall time. No startup or restore time is folded
into the tick measurements.


## Follow-up physical regressions and retained scope

The candidate passes all 28 original snapshot cases (two restores × ten
continuation ticks, 560 ticks total) and all 29 native correction cases (16
ordinary command guard cases and 13 body/motion cases). The 600-step
ordinary/sleeping wall passes the physical invariant subset and matches the
previous baseline's complete non-timing invariant record exactly: 400 supported
chunks, 44 detached, 182 broken bonds, 39 clusters, identical topology identity,
fracture/correction steps, clearance and COM error. Its historical golden
identity assertion still fails, as it did before this change.
[Exact commands and exit codes](regressions.json).

Retained **as a snapshot repeatability correctness fix**, not a speedup or complete
engine qualification. The tested contact-order source is applied to the main
working tree without modifying its unrelated changes. The exact tested runtime
remains frozen in `out/snapshot-large-20260911/stable-contact-control/`; installed
original A and retained N13 are unchanged. There is no new ABI or file-format
version. Default-graph memcheck remains a recorded failure, and no workaround or
suppression from the diagnostic experiments is retained.


Local runtime rebuilt successfully with:

```bash
.toolchains/build-env/bin/cmake --build out/sdk-release --target PhysXDestructionGpuRuntime -j6
```

Rebuilt module SHA256:
`06c8e588800787592194ecb5f4c349043bbabd9aa2c5eba4eca34ee00d3ff875`.
It passes another 20 independent restores of the formerly failing city25
post-impact state, using the frozen original probe. Exact receipt:
`out/snapshot-large-20260911/stable-rebuilt-post-impact/receipt.json`.
The full 52-case measurements continue to refer to the isolated module identified
in `verification.json`; its source is byte-identical to the rebuilt source.
No owned GPU job remains live after these checks.
