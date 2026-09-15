# R1 warm nine-window screen (contract v3)

2026-09-15. Candidate: runtime built from commit `0c5c997c` plus the chain-depth
guard (this commit), artifacts `out/direct-factor-feasibility-20260915/artifacts`
(runtime sha256 `aa2ca56f…`). Control: frozen selected artifacts
`out/destruction-baseline-20260913/artifacts` (runtime `d5770a80…`). Same probe
binaries (`out/warm-replay-20260914/{plain,profile}/serialization-probe`), plan
`out/direct-warm-screen-20260915/plan-v3.json`, results `results-v3/`, 291.6 s
GPU-exclusive with desktop management. A0/B/A1 order, two processes × two
restored trajectories × 8 measured ticks (16 for city256 idle). All 27 plain jobs
and both profiles completed.

| window | A0 mean | **B mean** | A1 mean | A0 max | B max | A1 max | 60 Hz misses A0/B/A1 |
|---|---:|---:|---:|---:|---:|---:|---:|
| bridge64 | 1.35 | 1.53 | 1.42 | 1.6 | 1.7 | 1.5 | 0/0/0 |
| chain256 | 1.40 | 1.20 | 1.42 | 1.6 | 1.4 | 1.8 | 0/0/0 |
| dense12 | 1.60 | 1.39 | 1.26 | 1.8 | 1.5 | 1.5 | 0/0/0 |
| tower64 | 1.48 | 1.47 | 1.46 | 3.2 | 2.1 | 1.5 | 0/0/0 |
| city25 impact | 22.64 | **17.06** | 22.62 | 38.0 | 32.7 | 37.4 | 10/9/10 of 16 |
| city256 idle | 1.55 | 1.64 | 1.62 | 2.9 | 2.1 | 2.0 | 0/0/0 of 32 |
| city256 impact | 89.32 | **75.42** | 88.33 | 172.5 | 183.0 | 188.7 | 16/16/16 |
| city256 cascade | 104.61 | **79.85** | 105.62 | 141.5 | 120.5 | 145.0 | 16/16/16 |
| city256 debris | 125.40 | **93.05** | 125.81 | 130.2 | 99.6 | 130.4 | 16/16/16 |

Milliseconds of `complete_step_ms`. The impact peak is unchanged within noise:
that tick is dominated by CPU fragment registration (R2). An earlier v2-contract
run of the same candidate without the chain guard measured city25 impact 15.02,
city256 impact 75.72, cascade 79.27 and debris 94.12 ms, and chain256 2.28 ms
(the chain's 255-level elimination path made the level-synchronous solve slower
than PCG; patterns deeper than half their node count now stay on PCG).

## Physical verdicts

Every candidate window passes contract v3. Work histories (broken bonds,
correction and stress passes, clusters, islands, active nodes/bonds, contacts,
friction anchors) match the control on every tick; active bonds, cluster
membership, crush state, loads and accelerations are byte-identical; motion is
within the frozen bounds (positions and velocities identical, orientation dot
error ≤ 4.8e-7, the same values the A0/A1 control pairs show).

| window | force relative L2 | per-bond max relative (diagnostic) | health max drift |
|---|---:|---:|---:|
| city25 impact | 2.96e-6 | 1.85e-4 | 1.13e-6 |
| city256 impact | 4.90e-6 | 5.07e-4 | 1.19e-6 |
| city256 cascade | 1.49e-6 | 9.89e-3 | 1.07e-6 |
| city256 debris | 2.32e-6 | 3.43e-2 | 3.48e-5 |

Why contract v3: the v2 comparator bounds every force scalar by
`2e-4 × max(1 N, |x|, |y|)`. Two solutions that both satisfy the solver's
relative residual gate (1e-5) differ on the tolerance-level components of large
forces (for example 0.45 N versus 0.001 N beside a 26 kN component), and on
low-force bonds inside high-force components, by amounts that the per-scalar
floor reports as errors of order one. The A0/A1 control pairs are bitwise
identical because they run the same PCG path. The runtime still rejects any tick
whose solve is not converged, so the candidate's solution is certified by the
unchanged gate every tick. Contract v3 therefore gates on exact discrete outcomes,
the frozen motion bounds, a whole-array relative force bound (1e-4) and a health
drift bound (1e-4 remaining-area units over the window), and reports the per-bond
maximum as a diagnostic. `run-warm-suite.py --contract-version 3` selects it.

Sanitizers with the candidate runtime: `gpu_resident_stress_3d_test` and
`gpu_resident_motion_modes_test` under memcheck, initcheck and synccheck, and
`native_gpu_correction_body_test` under memcheck, all report zero errors
(`out/direct-factor-feasibility-20260915/sanitizers.log`). Not established by
this screen: continuous 600-tick trajectories (running separately) and full52.

## Continuous 600-tick A/B/A (10 simulated seconds, `run-destruction-ab.py`)

Arms `out/direct-ab-arms/{A,B}` (identical demo and GPU module; runtime `d5770a80…`
versus `aa2ca56f…`), config `destruction-ordinary-ab.json`, two trials per arm,
results `out/direct-continuous-ab-20260915/`. Physical work counters (bodies,
awake bodies, clusters, contacts, stress nodes/bonds/islands, bonds broken,
correction passes) match the control on every one of the 600 ticks in both
cases; only stress iteration counts differ.

| case | A-before mean | **B mean** | A-after mean | peaks (median) A/B/A | 60 Hz misses A/B/A |
|---|---:|---:|---:|---|---|
| idle-256 (no projectiles) | 1.580 | 1.585 | 1.644 | 12.0 / 24.7 / 13.7 | 0 / 1 / 0 of 600 |
| impacts-256 (one 256-shot wave) | 51.41 | **33.81** | 51.35 | 183.3 / 181.2 / 184.0 | 519 / **328** / 519 of 600 |

The idle peak is the first tick: the candidate factorizes every initial
component once (about 13 ms extra on tick 0). Initialization rose from about
2.2 s to 2.8 s per process for the host symbolic analysis. Commit `6adc8873`
shares symbolic structures across identical assets and factors every initial
component when device topology is enabled: in a 256-building rerun the
candidate initialized in 2.11 s versus 2.49 s for the control, the first idle
tick took 11.6 ms versus 12.5 ms, idle stayed within 0.1 ms, and the heavy
3 s mean was 54.8 → 36.5 ms with identical histories.

## Full52 warm physical qualification (contract v3, 52/52 pass)

Plan `out/direct-warm-screen-20260915/full52-plan.json` (the 52 windows and hash-checked
preserved controls of the 2026-09-14 full52 baseline), results `full52-v2/`, 297 s.
Every window passes contract v3 and its warm-window repeatability gate. A first
run failed only city64 late debris on repeatability (health differing by 4e-7
between two restores of the same input): slot assignment raced on atomics, so
when the pool was exhausted the set of components falling back to PCG depended on
the race. Assignment is now a deterministic component-order scan (`b6u3jdttk`
build; committed below). Control means below are the historical 2026-09-14
timings, not paired measurements.

| window | control mean | candidate mean | control max | candidate max | 60 Hz misses ctrl/cand |
|---|---:|---:|---:|---:|---:|
| building-fragmented | 3.86 | 3.73 | 4.5 | 4.0 | 0/0 |
| city25-initial-impact | 22.76 | 16.78 | 36.9 | 32.3 | 10/10 |
| city25-post-impact | 19.67 | 14.66 | 29.4 | 24.4 | 8/8 |
| city25-cascading-fracture | 23.39 | 16.24 | 29.5 | 21.2 | 12/12 |
| city25-fragmented-loaded | 15.85 | 8.41 | 28.0 | 17.6 | 2/2 |
| city25-late-debris | 29.77 | 32.63 | 35.6 | 40.9 | 16/16 |
| city25-ten-second-debris | 20.44 | 9.06 | 33.2 | 16.0 | 9/0 |
| city64-initial-impact | 28.64 | 24.22 | 57.8 | 54.6 | 11/12 |
| city64-post-impact | 23.71 | 19.40 | 35.4 | 35.3 | 9/10 |
| city64-cascading-fracture | 20.65 | 16.72 | 31.0 | 27.5 | 6/6 |
| city64-fragmented-loaded | 22.95 | 12.69 | 39.4 | 25.2 | 16/2 |
| city64-late-debris | 49.35 | 48.67 | 51.8 | 56.3 | 16/16 |
| city64-ten-second-debris | 22.98 | 10.69 | 37.8 | 20.7 | 16/4 |
| city256-airborne | 3.78 | 4.12 | 4.1 | 4.4 | 0/0 |
| city256-initial-impact | 88.77 | 71.25 | 175.8 | 158.8 | 16/16 |
| city256-post-impact | 73.20 | 55.59 | 117.1 | 104.8 | 16/16 |
| city256-cascading-fracture | 77.41 | 53.96 | 99.8 | 82.2 | 16/16 |
| city256-fragmented-loaded | 82.20 | 45.65 | 103.1 | 59.6 | 16/16 |
| city256-late-debris | 124.66 | 92.30 | 129.2 | 96.7 | 16/16 |
| city256-ten-second-debris | 41.38 | 26.59 | 58.9 | 38.9 | 16/10 |

The 32 small/idle windows average 1.56 ms (candidate) versus 1.52 ms (control).
Open: city25 late debris (29.8 → 32.6 ms) and city64 late debris (49.4 → 48.7 ms) show
no gain against their unpaired controls; both are small-city late-debris windows and
need a paired A/B and a per-component diagnostic before drawing a conclusion.

## Frozen 600-tick ordinary/sleeping wall (`run-destruction-penetration-regression.py --tier full`)

Candidate runtime `out/direct-ab-arms/B`, results `out/direct-wall-20260915/quality.json`:
status passed; topology identity sha256 identical to the pinned ordinary
reference; 400 supported / 44 detached / 182 broken bonds and 1 correction per
step maximum, exactly as the reference; maximum position error 0.0 m; cluster
COM error 2.0e-6 m (same as reference); peak physics tick 17.85 ms versus the
reference run's 26.95 ms.

## R2 first step: pre-created fragment body pool (opt-in, measured, not default)

The GPU motion-slot allocator hands out granted node handles sequentially, so the
CPU can pre-create private placeholder bodies bound to those handles and take
them at fracture instead of creating and adding a `BodySim` inside the tick
(`NpDestructionBodyAllocator` placeholders; `PHYSX_DESTRUCTION_BODY_POOL=N|auto`).
256-building bombardment A/B, 3 s, identical physical histories, pool `auto`
(14,208 placeholders reserved at the first advance):

| window | control | R1 alone | R1 + pool |
|---|---:|---:|---:|
| impact tick 82 | 173.8 ms | ≈176–183 ms | 161.5 ms |
| ticks 82–99 mean | 88.0 ms | ≈76–79 ms | 66.1 ms |
| first idle tick (pool creation) | 12.5 ms | 11.6 ms | 29.3 ms |

The frozen wall passes with the pool on (identical topology, 400/44/182, zero
position error, peak 16.9 ms). It is **not** the default because placeholders
are island nodes: eight native lifecycle tests assert that address capacity
creates no simulation bodies and that CPU edge flood fill matches the GPU
contact components, and both audits see the shape-less placeholder nodes.
Placeholders are now created kinematic, which keeps them out of the dynamic
island flood-fill audit (`retained_registry` passes with the pool on). Still
failing with the pool on, and therefore the concrete R2 consumer list: the
explicit contract that address grants create no simulation bodies
(`native_gpu_allocation_test`), and the GPU pre-solve island registry, which
treats granted handles as unborn until allocation and so labels islands
differently once placeholder nodes exist (`GPU island audit partition:
node=4 expected=4 gpu=2`), plus the node-birth acknowledgement and
first-advance placement of the creation cost. The code stays opt-in.
Stream priorities for the destruction and stress streams (`PHYSX_DESTRUCTION_STREAM_PRIORITY`,
`BLAST_GPU_STREAM_PRIORITY`) measured no change (36.3 vs 36.5 ms) and stay on.

## R4: continuing-load tolerance relaxation (implemented, off by default, measured neutral)

`relaxNativeContinuingTolerance` (solver) keeps the strict tolerance for any
component without a verified stored input, with a changed topology, or whose
load changed by more than `BLAST_GPU_NATIVE_CONTINUING_CHANGE` (0.1) of the
stored load; other components use `BLAST_GPU_NATIVE_CONTINUING_TOLERANCE`
(0 = off). Impacts therefore still get the strict same-tick verdict. With the
direct factorization in place the relaxation is neutral: city256 bombardment
36.19 ms (1e-3) versus 36.3–36.5 ms (strict), identical histories, mean of the
per-tick maximum iteration count 30.5 versus 30.6, because the direct step
already reaches 1e-5 in one application. It remains available for PCG-only
configurations.

## R6: elastic-margin reuse (implemented, off by default, measured, declared compromise)

Mechanism. The runtime's material pass now also writes each bond's elastic
utilization (largest stress / elastic-limit ratio; a bond without a limit
reports 1) and hands the array to the solver with the topology transaction
(`updateDeviceTopologyAsync(..., bondUtilization)`). The solver keeps, per
component, the load of its last fresh **converged** solve (`references` in the
settled cache; weaker than the exact-settled certificate, which needs a
zero-iteration verification solve and therefore almost never exists in a
moving scene: the first attempt gated on the certificate fired zero times and
was neutral). `beginNativeElasticReuse` then skips a component this tick when
every live bond was below `BLAST_GPU_NATIVE_ELASTIC_MARGIN` of its elastic
limit at the last material pass and the load changed by less than
`BLAST_GPU_NATIVE_ELASTIC_CHANGE` (0.1) of the reference load: no damage can
accrue below the elastic limit, so the fracture verdict is unchanged and the
stored forces are republished. Impacts, changed topology and large load changes
never qualify. Skipped components keep their reference, so the deviation is
bounded by one change fraction and does not accumulate. The R4 relaxation now
gates on the same reference.

Fidelity envelope (this is the declared compromise; contract v4 reports forces
without gating them):

| window (results-elastic, v4) | discrete outcomes | motion | health drift | force relL2 | max per-bond scaled | max abs |
|---|---|---|---:|---:|---:|---:|
| city25 impact | exact | pass | 1.1e-6 (as v3) | 1.5e-3 | 0.24 | 2.9 kN |
| city256 impact | exact | pass | 1.2e-6 (as v3) | 4.4e-4 | 0.73 | 6.9 kN |
| city256 cascade | exact | pass | 1.1e-6 (as v3) | 1.3e-3 | 1.00 | 66 kN |
| city256 debris | exact | pass | 3.5e-5 (as v3) | 1.9e-2 | 1.85 | 928 kN |
| city256 idle, bridge, chain, dense, tower | exact | pass | 0 | ≤3.4e-7 | 0 | 0 |

Read the last column as: on a heavy debris cluster whose total load moved by
under 10 %, one far-from-limit bond's republished force is stale by up to
928 kN (1.85× its own reference norm). Damage is unaffected (the health drift
is identical to the lossless run), broken-bond identities and cluster
partitions are exact in every window, and the 180-tick city256 bombardment
A/B breaks the same 56,077 bonds tick for tick. What is lost is the accuracy
of the *reported* stress on components that are provably not going to break
this tick; anything that visualises or queries per-bond stress sees a
republished value up to one change fraction old.

Timing (nine-window warm screen, same controls and probes as the v3 screen,
`out/direct-warm-screen-20260915/results-elastic`, 287.9 s):

| window | A0 mean | **B mean** | A1 mean | B (R1 only, v3 screen) | B max | misses A0/B/A1 |
|---|---:|---:|---:|---:|---:|---:|
| city25 impact | 22.40 | **16.79** | 22.94 | 17.06 | 31.8 | 10/9/10 of 16 |
| city256 idle | 1.63 | 1.86 | 1.63 | 1.64 | 2.2 | 0/0/0 of 32 |
| city256 impact | 90.54 | **73.59** | 89.93 | 75.42 | 187.5 | 16/16/16 |
| city256 cascade | 106.49 | **78.66** | 103.93 | 79.85 | 121.1 | 16/16/16 |
| city256 debris | 125.29 | **83.85** | 124.37 | 93.05 | 89.4 | 16/16/16 |
| bridge/chain/dense/tower | 1.42–1.52 | 1.32–1.47 | 1.15–1.49 | 1.20–1.53 | ≤1.8 | 0 |

City256 bombardment A/B (native demo, 3 s, 180 ticks, `ab-g16-elastic2`):
33.6 ms mean with the skip versus 36.3–36.7 ms without (R1 only) and 55 ms
baseline; 206,870 component skips over 267 solves (about 775 per solve; the
skipped components are the small settled-debris clusters, so the per-tick
maximum iteration count is unchanged at 30.5). Idle costs about 0.2 ms for the
scan itself (1.64 → 1.86 ms); the kernel visits every component each tick and
could be folded into the settled-reuse scan. The feature stays env-gated and
off by default until the envelope above is accepted; recommended setting when
enabled: margin 0.5, change fraction 0.1. A tighter change fraction of 0.03
(`ab-g16-elastic3`) keeps 147,479 of the skips and 34.8 ms, so most of the
gain survives a three-times-smaller staleness bound if the envelope above is
judged too loose.
