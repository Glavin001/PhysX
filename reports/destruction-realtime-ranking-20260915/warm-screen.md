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

## Contact-pair preservation (plan Phase 0 item 1): neutral with R1 in place

`--preserve-contact-pairs 1` on both arms of the city256 bombardment A/B
(`ab-g16-preserve`): histories identical to the rebuild-all runs on every tick
(bonds broken, post-correction breaks, clusters, contacts, correction status),
34.3 ms versus 33.6 ms with the same runtime and rebuild-all, 55.2 versus 55.5
ms for the baseline runtime. The full-scene refiltering after each correction is
not a measurable cost at this scale once the stress solve is fast; the setting
stays as each profile has it.

## Refactor latency and the deferred stale-factor schedule (negative result)

In the late-debris profile (`results-elastic/city256-debris-nsys`) each
`factorNativeDirect` launch costs 2.7 ms although only 1–7 components refactor:
one 444-node building's elimination chain is latency bound, so the launch time is
the slowest single refactor, twice per tick (5.5 ms of the 84 ms tick on the
critical path, and a 27 ms burst on the impact tick). A deferred schedule
(`BLAST_GPU_NATIVE_DIRECT_DEFERRED=1`) keeps a changed component's old factor as
a preconditioner for this solve, refactors after the completion event, and
guards every application with a true-residual decrease (an application that
grows the residual is undone; a stale factor built under a different pinning is
not applied). It is correct (identical 180-tick histories, 9/9 CTests) but
slower: 39.7 ms versus 33.6 ms, mean per-tick maximum iterations 30 → 202.
After a split the departed nodes stay coupled inside the old factor, so most
stale applications grow the residual (1,447 undone) and those components fall
back to PCG. The switch stays off; the pattern-depth diagnostic
(`BLAST_GPU_NATIVE_DIRECT_DIAG=1` prints the deepest pattern's levels and
narrow-level count) is the input for the remaining options: a dense-top
(supernodal) factorization of the narrow levels, or Woodbury updates that
decouple departed nodes.

## Requalification of the committed default configuration (contract v3, `results-final`)

Runtime `db6f05eb` with every new switch at its default (elastic-margin reuse
off, deferred refactor off, continuing-load relaxation off, body pool off),
same controls, probes and plan as the earlier screens, 286.5 s:

| window | A0 mean | **B mean** | A1 mean | B max | misses A0/B/A1 | force relL2 | health drift |
|---|---:|---:|---:|---:|---:|---:|---:|
| bridge64 / chain256 / dense12 / tower64 | 1.31–1.62 | 1.38–1.52 | 1.31–1.39 | ≤1.8 | 0 | ≤3.1e-7 | 0 |
| city25 impact | 22.68 | **16.25** | 21.73 | 32.6 | 10/9/10 of 16 | 3.0e-6 | 1.1e-6 |
| city256 idle | 1.49 | 1.66 | 1.48 | 1.8 | 0/0/0 of 32 | 2.4e-7 | 0 |
| city256 impact | 88.36 | **71.13** | 88.56 | 160.0 | 16/16/16 | 4.9e-6 | 1.2e-6 |
| city256 cascade | 105.38 | **80.05** | 103.25 | 115.6 | 16/16/16 | 1.5e-6 | 1.1e-6 |
| city256 debris | 124.23 | **92.52** | 125.09 | 97.3 | 16/16/16 | 2.3e-6 | 3.5e-5 |

All nine windows pass; the numbers reproduce the first R1 screen within run
noise, so the converged-load reference, the residual-decrease guard and the
diagnostics changed nothing in the default path.

## Continuous 600-tick A/B/A with elastic-margin reuse (`out/direct-continuous-ab-elastic-20260915`)

Same procedure as the R1 campaign (`run-destruction-ab.py`, two trials per arm,
10 simulated seconds, ordinary APIs, sleeping on, one correction), runtime
`db6f05eb` with `BLAST_GPU_NATIVE_ELASTIC_MARGIN=0.5` (change fraction 0.1),
controls before and after. Physical work counters (bodies, awake bodies,
clusters, contacts, stress nodes/bonds/islands, bonds broken, correction
passes) match the control on every one of the 600 ticks in all four
comparisons; only stress iteration counts differ.

| case | A-before mean | **B mean** | A-after mean | peaks (median) A/B/A | 60 Hz misses A/B/A |
|---|---:|---:|---:|---|---|
| idle-256 | 1.569 | 1.606 | 1.636 | 13.8 / 11.3 / 13.7 | 0 / 0 / 0 of 600 |
| impacts-256 | 51.23 | **29.83** | 51.14 | 182.1 / 150.2 / 179.8 | 519 / **294–300** / 519 of 600 |

For reference the R1-only campaign measured 33.81 ms and 328 misses on the same
fixture. Half of the heavy ticks now meet 60 Hz; the other half are the impact
and cascade ticks whose cost is CPU fragment registration and island repair
(R2), not the stress solve.

## Refactor cost: throughput, not latency (two more measured attempts)

Nsight kernel sums over the 3 s city256 bombardment (267 solves) put
`factorNativeDirect` at 2.77 ms per launch with the original level-parallel
scheme and at 2.77 ms with a right-looking elimination of the narrow tail
(`BLAST_GPU_NATIVE_DIRECT_TOP`, on by default, histories identical, and the
impact tick's maximum PCG iteration count fell from 420 to 28). The launch
time is therefore not the serial level chain but the arithmetic of one CTA on
the dense top: the deepest structure has 380 nodes, 4,741 factor blocks and a
111-column dense top, about 0.1 GFLOP per refactor. A level-structure nested
dissection order (`BLAST_GPU_NATIVE_DIRECT_ORDER=nd`, off) gave more fill
(5,449 blocks), a larger top (124 columns) and 3.16 ms. The remaining options
are a graph partitioner with refinement for the ordering, several CTAs (a
thread block cluster) per refactoring component, or Woodbury updates so that
few-bond removals do not refactor at all. Per sustained tick this is 5.5 ms of
the 84 ms; at the impact tick it is the 27 ms burst.

## R2 step 1 completed: the pre-created fragment body pool is the default

The pool is now enabled by the runtime (`PHYSX_DESTRUCTION_BODY_POOL`, unset or
`auto` = one body per eight chunks clamped to [256, 16384]; `0` disables; a
number sets the count) and opted into on the CPU allocator through an appended
interface call, so the frozen baseline runtime never creates placeholders and
control arms stay valid. What made it work with the GPU pre-solve roster:

- A pooled placeholder is an inactive kinematic body on a granted node handle,
  so it already owns one island lifetime. The allocator exposes that lifetime,
  the runtime uploads it beside the granted addresses, and the GPU birth kernel
  uses it as the base: unchanged for a supported (kinematic) fragment, plus one
  when the fragment becomes dynamic. Claiming switches the body to dynamic as a
  device-owner transaction.
- The first-advance reservation grows the motion storage before the tick's
  address registration; the tick now registers the grown storage rather than
  the caller's pre-growth view (that stale view rejected every grant with
  allocation error 16 → stage error 776).
- Contracts: address grants may own placeholder nodes; the growth-path
  fixtures either opt out (`native_initialization_failure_check.h`) or expect
  no in-tick growth when pooled; the birth-roster check accepts pooled births.

Native GPU suite with the pool on: 38 of 41 pass. The three failures are not
pool-related: `physx_native_gpu_state_initcheck_accepted-properties(-pgs)`
(compute-sanitizer initcheck, uninitialized read in `compactFreeMotionSlots`
during topology init) reproduces with the frozen baseline runtime, and
`physx_native_gpu_bombardment_contacts` (motion audit requires exactly zero
CPU/GPU pose difference; measured 1.7e-5 to 2.2e-5 m, float-ulp level) fails
identically with the baseline runtime and the pool disabled. Both predate this
branch's runtime changes in this build environment and are recorded as open.

Timing with the pool as default (city256 bombardment, 3 s, three interleaved
pairs, same runtime, `PHYSX_DESTRUCTION_BODY_POOL=auto` versus `0`):

| pair | pool on mean / max | pool off mean / max |
|---|---:|---:|
| 1 | 34.69 / 157.7 | 35.16 / 192.3 |
| 2 | 34.26 / 166.6 | 34.31 / 149.8 |
| 3 | 34.92 / 171.3 | 34.54 / 184.6 |

Neutral on the mean, peaks within run noise, histories identical to both the
baseline and the pool-free run. Phase profiles attribute the pool's steady
cost to under 1 ms per sustained tick (`correctedCollisionSolve` +0.95 ms) and
0.5 ms once at the first advance. Its benefit is confined to the impact
window's registration burst measured on the warm probe (88 → 66 ms); the demo's
impact window is unchanged (32.1 vs 32.3 ms).

Pooled nine-window screen (`results-pool`, candidate probes relinked against
the current static SDK because the frozen probe's embedded allocator predates
the appended interface call; runtime with pool and elastic reuse on):

| window | A0 mean | **B mean** | A1 mean | B max | pool-free B (elastic) | v4 verdict |
|---|---:|---:|---:|---:|---:|---|
| city25 impact | 22.87 | **16.79** | 22.31 | 29.3 | 16.79 | exact outcomes, zero motion error |
| city256 idle | 1.52 | 1.68 | 1.65 | 3.3 | 1.86 | pass |
| city256 impact | 90.76 | **74.18** | 88.57 | 174.7 | 73.59 | exact outcomes, zero motion error |
| city256 cascade | 109.06 | **77.56** | 107.49 | 116.3 | 78.66 | exact outcomes, zero motion error |
| city256 debris | 125.82 | **82.50** | 128.85 | 90.3 | 83.85 | exact outcomes, zero motion error |

Contract v3 reports the city windows as failed only through its force bound,
which the elastic-reuse default exceeds by design; the v4 comparator passes
every window with the same health drift as elastic reuse alone. The pool moves
no window beyond run noise, and the continuous campaign with it on measured
30.56 ms and 306–312 misses against 29.83 ms and 294–300 without it (bodies
counter differs by the placeholder count on every tick; all other physical
counters identical). The earlier 88 → 66 ms impact-window figure came from an
older runtime state and does not reproduce once the direct stress solve is in
place: fragment body creation is not the dominant cost of the impact tick.

**Decision.** The pool ships complete but opt-in (`PHYSX_DESTRUCTION_BODY_POOL=auto`
or a count), reversing the earlier recommendation on the strength of these
numbers. Its CPU placeholder creation now happens at configuration time, not
inside the first simulated tick.

## Island repair: the host wait was queued behind the rigid solver (fixed)

Sub-zones inside `GpuDestruction.task.prepareIslandRepair` (late window, per
tick, both passes) showed 6.4 of its 7.1 ms inside `observeContactComponents`,
i.e. the host waiting for the contact-graph completion event. The graph kernels
themselves take under 0.5 ms; aligning the profiled debris tick's host zones
with the Nsight kernel timeline showed the GPU only 13–25 % busy during that
wait, running TGS solver kernels. The graph was submitted on the solver stream
after the rigid solve had been queued, so the host waited for the whole solve.

The narrowphase core now records a "merged outputs ready" event on the solver
stream right after the merged pair inputs, identities and outputs are copied,
and builds the graph on its own non-blocking stream that waits only on that
event (`PHYSX_DESTRUCTION_GRAPH_STREAM=0` restores the old schedule). Late
window per tick: island repair 7.06 → 4.10 ms (observe wait 6.39 → 3.63),
corrected pass 15.6 → 14.1 ms; city256 bombardment 34.7 → 33.5 ms with
identical histories; native suite unchanged (38/41, same three pre-existing
failures). The remaining 3.6 ms is the time for the solver stream to reach the
merge point plus the graph build and readback; attribution continues.

Second step: `observeContactComponents` synchronously copied the graph status
on the legacy default stream (which joins every blocking stream, i.e. the
rigid solver), then ran a radix-sort chain of about twelve launches per graph
and two device-to-host copies per graph, all serialized on the runtime stream
and queued behind the standard-scene body readback on the copy engine
(Nsight: 63 MB of solver-stream device-to-host traffic overlapping the wait).
It now issues the status and label copies asynchronously, joins once, and
builds the member chains on the host in exactly the layout the sorted keys
produced (heads by minimum member, successors by ascending node).

| late window, per tick | before | graph stream | + async observation |
|---|---:|---:|---:|
| island repair (both passes) | 7.06 ms | 4.10 ms | **1.70 ms** |
| of which observe wait | 6.39 | 3.63 | **1.21** |
| city256 bombardment mean (3 s) | 34.7 | 33.5 | **32.4** |

Histories identical to the baseline on every tick (56,077 bonds); native
suite unchanged (38/41, same three pre-existing failures). Against the
baseline runtime the shipped defaults now measure 55.8 → 32.4 ms.

## Refactor on a thread-block cluster (negative result)

`factorNativeDirectCluster` spreads one component's refactor over a cluster of
eight CTAs (columns of wide levels over every warp of the cluster, the dense
top's gathers, scalings and rank-6 pair updates over every thread, cluster
barriers between phases; `BLAST_GPU_NATIVE_DIRECT_CLUSTER=8`). It is
bit-identical in outcome (histories and tests unchanged) but slower: 5.40 ms
per launch versus 2.77 and an 80 ms impact burst versus 27 ms, city256
bombardment 37.2 versus 32.4 ms. Clusters must co-reside on one GPC, so far
fewer components refactor concurrently at impact, and the roughly 450 cluster
barriers per component cost more than the parallel pair updates save. The
default stays single-CTA; the remaining levers are a partitioner with
refinement for the ordering, or Woodbury updates that avoid refactoring.

## Incremental motion modes (R6, lossless)

`constructMotionModes` rebuilt every component's Euler tour, closure, axes and
mode factor on each topology transaction. A per-node changed mask taken from
the old component labels before relabeling (`markChangedStressNodes`) now
restricts every phase to changed components; unchanged ones keep their tour,
positions, closure, axes and factor. Kernel 1.86 → 0.43 ms per launch (about
157 launches per 180 ticks), histories identical, resident motion-mode and
native tests pass. `BLAST_GPU_NATIVE_MOTION_INCREMENTAL=0` restores the full
rebuild.

## Eager refactorization after the topology transaction (lossless)

The direct factors of changed components depend only on the committed
topology, so `updateDeviceTopologyAsync` now launches the slot assignment and
refactor right after recording the consumers' ready event
(`BLAST_GPU_NATIVE_DIRECT_EAGER=0` restores refactor-at-solve). Between the
trial and corrected passes this overlaps the CPU fragment registration; the
solve's own factor launch then finds every slot valid. Late window per tick:
`finishAndReserve` 18.4 → 15.3 ms; city256 bombardment 32.6 → 31.6 ms
(phase-profiled run 34.2 → 31.7), histories identical, 11/11 resident and
native tests. The impact tick is unchanged: its corrected-pass refactor has
no CPU work left to hide behind.

## Where the remaining stress-solve time goes (component census, late window)

Diagnostic runtime (`PhysXDestructionGpuWorkDiagnostic`, `PHYSX_COMPONENT_WORK_OUTPUT`),
city256 bombardment, solves 200–267, tabulated with
`tools/diagnostics/destruction-direct-factor/component_census.py`:

| component size (nodes) | per solve | share of CTA cycles | mean Mcycles | iterations |
|---|---:|---:|---:|---:|
| 2–7 (free debris) | 1,693 | 30 % | 0.18 | 1.6 |
| 8–31 | 180 | 10 % | 0.61 | 0 |
| 128–511 (anchored remnants, direct) | 255 | 60 % | 2.43 | 0 |

Phase clocks put 80 % of all component cycles before the iteration loop's
first monitor: operator caching, the direct application with its two true
residual evaluations and the residual rebuild. The direct-solved remnants
therefore no longer iterate but still cost about 2.4 Mcycles each, dominated
by the two block triangular solves (74 levels, 68 of them narrow, each a
barrier) and two residual matvecs; the 1,693 tiny free components cost
0.18 Mcycles each mostly in per-component setup. Next levers, in order: a
CTA-cooperative dense-top triangular solve (the narrow levels run one warp
while three idle), skipping the second residual evaluation when the first
application already lands under the gate, and batching tiny components per
warp instead of per CTA.

Follow-up: the iteration loop's first monitor recomputed exactly the residual
norm the direct step had just evaluated (the residual is untouched in
between). The direct step now publishes that norm and the first monitor reuses
it; the separate verification pass that the contract requires is unchanged.
Census sweeps per direct-solved remnant 1.3 → 0.7, bombardment 31.6 → 31.1 ms,
histories identical, 11/11 tests. A first attempt without a block barrier
between the publishing thread and the readers diverged around the
preparation's barriers and aborted a step; the barrier is now explicit.

## Final requalification of the shipped defaults (contract v4, `results-final-v4`)

Runtime `29a478bc` at its defaults (direct factorization with eager refactor,
elastic-margin reuse on, contact graph on its own stream, asynchronous
component observation, incremental motion modes; body pool and the negative
experiments off), candidate probes relinked against the current SDK, frozen
baseline controls before and after, 29 jobs, all pass:

| window | A0 mean | **B mean** | A1 mean | B max | misses A0/B/A1 | force relL2 | health drift |
|---|---:|---:|---:|---:|---:|---:|---:|
| bridge64 / chain256 / dense12 / tower64 | 1.36–1.57 | 1.48–1.76 | 1.21–1.57 | ≤2.1 | 0 | ≤3.0e-7 | 0 |
| city25 impact | 23.97 | **15.30** | 23.58 | 35.8 | 10/7/10 of 16 | 1.5e-3 | 1.3e-6 |
| city256 idle | 3.05 | 1.78 | 1.62 | 2.0 | 0/0/0 of 32 | 2.4e-7 | 0 |
| city256 impact | 90.70 | **69.40** | 90.05 | 175.8 | 16/16/16 | 4.4e-4 | 1.3e-6 |
| city256 cascade | 107.99 | **70.87** | 108.71 | 116.5 | 16/16/16 | 1.3e-3 | 1.4e-6 |
| city256 debris | 127.45 | **74.48** | 128.77 | 80.4 | 16/16/16 | 1.9e-2 | 3.6e-5 |

Discrete outcomes exact and motion error zero in every window; the force
deviations are the declared elastic-reuse envelope. Against the plan's
starting point the sustained windows are at 55–58 % of the baseline; the
impact peak is unchanged (CPU registration, R2).

## Final continuous 600-tick A/B/A of the shipped defaults (`out/direct-continuous-ab-final-20260915`)

Same procedure as before (two trials per arm, 10 simulated seconds, ordinary
APIs, sleeping on, one correction), runtime `29a478bc` at its defaults, frozen
baseline runtime as control before and after. Physical work counters identical
on every one of the 600 ticks in all four comparisons.

| case | A-before mean | **B mean** | A-after mean | peaks (median) A/B/A | 60 Hz misses A/B/A |
|---|---:|---:|---:|---|---|
| idle-256 | 1.64 | 1.77 | 1.65 | 14.0 / 12.5 / 13.2 | 0 / 0 / 0 of 600 |
| impacts-256 | 52.34 | **30.69** | 52.27 | 173.4 / 178.3 / 182.5 | 519 / **311** / 519 of 600 |

The idle mean carries the 0.1 ms elastic-reuse scan. The heavy mean is at 59 %
of the baseline with 40 % fewer 60 Hz misses; the remaining misses are the
impact and cascade ticks whose cost is CPU fragment registration (R2).

## Resident CTAs for the component solve (lossless)

The per-component solve is a persistent grid that pulls components from a
device work cursor; it launched two CTAs per SM. With thousands of tiny
components per solve, more resident CTAs simply keep more of them in flight:
`BLAST_GPU_NATIVE_SOLVE_BLOCKS` 2 → 4 measures 31.1 → 30.0 ms on the city256
bombardment (3 → 29.95), histories identical. Four is the new default.

## Refactor grid: more CTAs for the impact burst (lossless)

The batched refactor also launched `sms*2` CTAs, so the impact tick's 256
refactors ran in four rounds. `BLAST_GPU_NATIVE_FACTOR_BLOCKS` 2 → 4 → 8 on
the city256 bombardment: peak tick 194.6 → 185.8 → 177.9 ms, mean
31.0 → 30.7 → 30.2 ms, profiled burst 24.6 → 19.5 ms at four; histories
identical. Eight is the new default. This is the first change on this branch
that moves the impact peak; the rest of that tick is CPU registration (R2).

## Tiny components on 32-thread CTAs (neutral; off by default)

A `Tiny` instantiation of `componentStressSolve` runs components of at most
seven nodes on 32-thread CTAs over a grid stride, without the 24 KB
direct-solve shared array (`BLAST_GPU_NATIVE_TINY_CTAS`, resident CTAs per SM).
It required the preconditioner's warp fold and two other reductions to use
the live warp count. Correct (11/11 tests, identical histories) but neutral:
30.1 → 29.9 ms. The census share it targeted (30 % of component CTA cycles) is
not wall time: the solve kernel's duration is the latency of the slowest
chains, the direct-solved remnants at about 1 ms each (two block triangular
solves over 74 levels plus residual matvecs), and the tiny components already
ran in their shadow. The remaining solve-side lever is therefore the remnant
latency: a CTA-cooperative triangular solve for the narrow levels, where three
of four warps now idle.

## Direct solve, CTA-cooperative narrow rows (negative result, not kept)

Putting the whole CTA on each row of the narrow levels of the block
triangular solves (instead of one warp per row with the other warps idle)
made the solve kernel slower: 3.3 → 4.2 ms per launch, city256 bombardment
30.1 → 31.9 ms, histories identical. The one-to-three rows of a narrow level
then run sequentially behind two block barriers each, which costs more than
the wider dot product saves. The direct solve's latency is barrier-bound, not
bandwidth-bound; shortening it needs fewer levels (ordering), not more lanes
per row.

## Measurement note: paired ratios, not absolute means

Across the last four consecutive 3 s bombardment A/Bs on the same code the
frozen control arm drifted 55.8 → 56.2 → 56.9 → 57.5 ms while the candidate
moved 30.1 → 30.7 → 31.7 → 31.5 ms; the candidate-to-control ratio stayed at
0.54–0.56. Absolute means move with the machine's state over a long session
(the GPU idles at 180 MHz between runs and boosts to 3.09 GHz), so any claim
smaller than about 1.5 ms should be read from the paired ratio or from
interleaved repeats, as done for the body pool.

## Woodbury updates of cached factors (exact-equivalent; mean neutral, peak −19 ms)

`StressNativeWoodbury.cuh` (commits `86ff274c`, `df83bcbc`). A slot whose
component lost at most 16 bonds since its factor keeps the factor of
A_old and solves A_new = A_old − U Uᵀ through the Woodbury identity. The
capacitance C = I − UᵀW is only positive *semi*definite after a split: the
departed part is a free fragment whose rigid modes are null vectors of both
A_new and C. For a residual supported on the kept rows Uᵀy lies in range(C),
so a particular solution of C t = Uᵀy (pivoted Cholesky to find the rank,
explicit inverse of the leading pivot block) gives an exact kept-part
solution with no departed-node bookkeeping; the departed rows are never
scattered. Two attempts before that were numerically wrong or weak: identity
columns on every departed node (exact but capped at eight nodes, so most
fragments refactored) and one identity block per departed fragment (a weak
regularisation: 54 undone direct steps and 5× the PCG iterations). W is
built by entry-parallel level sweeps (a whole CTA per narrow row, lanes over
columns × entry groups); the first build parallelised lanes over columns
only, which serialised the dense top's ~100-entry rows and made a build
cost as much as a refactor.

Result on the city256 g16 3 s bombardment, `BLAST_GPU_NATIVE_DIRECT_DIAG=1`:
histories identical (56,077 bonds, 0 mismatching ticks), accepted direct
steps and PCG iterations identical to the refactor-only path, 0 undone;
2,269 Woodbury builds replace 2,269 of 3,628 refactors. Tick mean is
neutral within the paired-ratio noise (31.3 vs 30.8 ms, controls 56.5 vs
57.0; ratio 0.554 vs 0.540) and the peak drops 182 → 163 ms.

Why the mean does not move: the factor launch time is the maximum over its
CTAs, and almost every transaction still contains at least one full
refactor, because every split creates a *new* component that needs a fresh
factor in the parent pattern (1,359 refactors remain: new fragments, more
than 16 removals at impact, pinning changes). The factor kernel now skips
absent columns of the parent pattern (identity columns with zero couplings
and zero fill), so a small fragment costs only its own columns; that change
is lossless (identical histories) and moved the peak, not the mean.

Where the sustained tick goes now (`--profile-phases 1`, ticks 60–180,
host wall ms per tick, Woodbury on / off): `finishDetail.waitForGpu` 12.8 /
11.9 (1.7 waits per tick), `correctedCollisionSolve` 12.0 / 11.9 (0.7 per
tick, i.e. ~17 ms per corrected pass), then a tail of 1–2 ms phases
(postBroadPhase 2.1, broadPhaseWait 2.1, prepareIslandRepair 1.5,
applyBindings 1.5, acceptCorrection 1.4, submit 1.3, island maintenance
1.2+1.2, postNarrowPhase 1.1). The two large items are the GPU stress
pipeline wait and the corrected physics pass (R5's target).

Kernel totals over the same 3 s run (`nsys --cuda-graph-trace=node`, needed
because the stress kernels run inside captured graphs; delete the stale
`.sqlite` before `nsys stats` or it reuses the previous export):
`componentStressSolve` 987 ms / 267 launches (3.7 ms avg, 9.7 max);
`factorNativeDirect` 694 ms / 678 launches, of which 521 are empty (≤50 µs)
and 157 carry work (53 in 1.5–3.5 ms, 92 in 3.5–10 ms, 6 above 10 ms);
`massProperties` 100 ms / 158; `constructMotionModes` 68 ms / 157;
`performIncrementalSAP` 203 ms / 266. Per sustained tick the GPU stress
pipeline is therefore ~5.5 ms of solves plus ~2.6 ms of factor launches plus
the transaction kernels, which matches the 12.8 ms `waitForGpu`.

## Nested-dissection ordering re-tested against the solve-bound tick (negative)

With the solve kernel now the largest GPU item (its remnant latency is the
level count of the block triangular solves), the level-structure
nested-dissection order (`BLAST_GPU_NATIVE_DIRECT_ORDER=nd`) was re-run on
the g16 bombardment: levels 74 → 67, narrow levels 68 → 57, blocks
4,741 → 5,449, histories identical, tick ratio 0.579 vs 0.554 for minimum
degree. The bisection order does not produce a shallow tree on this
building graph; it stays off.

## Direct solve: where the remnant cycles go, and why cutting them did not move the tick

Diagnostic sub-phase clocks (commits `40794c66`, `6a503f5b`) on the city256
late window, per solve: pre-monitor 918 of 1,138 Mcycles, of which the
direct applications were 480 (forward narrow levels 210, backward narrow
105, wide levels 132, Woodbury apply 21); the residual norms 113, rebuilds
26. Per forward narrow level: index loads 0.5k, entry loads 2.1k, reduce
0.3k, the serial 6×6 finish by lane 0 with six divisions 5.5k, barrier
0.1k cycles.

Two lossless changes followed. (1) Pipelined narrow levels (commit
`f7f2a2ed`): idle warps gather the next level's early entries into
per-item partials while the current level finishes; correct after an
early-warp distribution fix, but the narrow cycles did not drop (200/117
Mcycles) because the entries were not the chain. (2) Stored diagonal-block
inverses with a lane-parallel row finish (`6a503f5b`): finish 5.5k → 1.9k
cycles per level, direct applications 480 → 359 Mcycles per solve, remnant
mean 2.71 → 2.41 Mcycles. Histories identical for both. Tick ratio 0.553
in both cases: unchanged.

The reason is residency, not latency. `cuobjdump -res-usage`: the solve
kernel uses 128 registers (27 KB shared), so only two CTAs fit per SM and
only 72 of the 144 launched CTAs ever claim work from the cursor (the
census records 72 distinct CTA ids per solve); each carries ~7.8 Mcycles
per solve (max ~10), which is the 3.7 ms launch. The launch is therefore
total cycles ÷ 72, not the longest remnant chain: the remnants are 59 %
of the cycles, the 1,693 tiny free components 33 % (0.2 Mcycles each of
per-component setup), 8–31-node components 8 %. The levers in order are
more resident CTAs (launch bounds at three or four blocks per SM, under
test), fewer per-component fixed cycles for the tiny components, and the
remnant cost reductions above, which now pay proportionally.

## Solve kernel residency: three CTAs per SM (lossless, −1.4 ms)

`__launch_bounds__(kBlockSize, 3)` on `componentStressSolve` caps registers
at 80 (stack 480 → 592 bytes) so 108 of the 144 launched CTAs claim work
instead of 72. city256 g16 3 s bombardment: tick ratio 0.553 → 0.527
(29.8 vs 31.3 ms at a 56.5 ms control), histories identical. Four blocks
per SM (64 registers) spills more and is worse (ratio 0.563). Default is
now three (`BLAST_GPU_SOLVE_MIN_BLOCKS`). Shared memory (27 KB per CTA) is
not the limit at three.

Tiny-component launch re-tested at three resident CTAs per SM
(`BLAST_GPU_NATIVE_TINY_CTAS` 16 and 32): ratios 0.550 and 0.541 against
0.527 for the single launch; histories identical. The separate 32-thread
launch still serialises ahead of the main kernel on the same stream and
costs more than it saves; it stays off. The tiny components' 33 % of solve
cycles remain a target only through their per-component fixed cost inside
the main kernel.

## Measurement note: the warm plan's candidate arm loads a copied runtime

`plan-pool.json` points the B arm at `out/direct-factor-feasibility-20260915/artifacts`,
a *copy* of the runtime made on 2026-09-15 20:18 (the pre-Woodbury final
build), not at `physx/bin`. The `results-solve-v4` screen run on 2026-09-16
therefore re-measured that older build (all nine windows pass; city256
debris 76.3, cascade 75.8, impact 72.6, city25 14.9 ms), and its idle
window (B 2.62 vs A 1.68/1.78 ms) is a repeat of a runtime that measured
1.8 ms the day before: idle is noisy under desktop management. Copy the
current `libPhysXDestructionGpuRuntime_64.so` into that directory before
a warm screen of a new build.

## Dense direct step for tiny components (exact, slower; off by default)

`StressNativeDenseTiny.cuh`: components below the cached-factor minimum
(at most seven nodes) assemble their operator from live bonds into shared
memory, factor it densely and solve, under the same residual gate as the
cached factors. Correct: histories identical, every tiny component
converges in zero PCG iterations (maxIterations 0 across the run,
70,636 dense applications). Slower: tick ratio 0.556 with block barriers
in the factorization and 0.544 with a warp-only version, against 0.527
without it. The tiny components' cost is the per-component fixed work
around the solve (two true-residual evaluations, rebuild, monitors), which
the dense step keeps and adds assembly to; their 1–2 PCG iterations were
not the expensive part. Env `BLAST_GPU_NATIVE_DENSE_TINY=1` enables it.

## Requalification of the current defaults (contract v4, `results-solve2-v4`, 2026-09-16)

Runtime copy refreshed (Woodbury on, absent-column skipping, pipelined
narrow levels, diagonal inverses, three CTAs per SM, dense tiny step off),
11/11 native GPU tests. All nine windows pass; means in ms (A0 / B / A1):
bridge64 1.58/1.55/1.53, chain256 1.69/1.66/1.55, city25 impact
25.2/16.4/23.1, city256 cascade 113.2/71.0/109.1, city256 debris
132.6/80.3/129.2, city256 idle 1.69/1.80/1.71, city256 impact
93.1/69.8/94.8, dense12 1.52/1.43/1.51, tower64 1.48/1.39/1.64. Discrete
outcomes exact, health drift ≤ 3.0e-5, force relL2 ≤ 1.9e-2 on the debris
window (elastic reuse, as before). Against the 2026-09-15 final: cascade
80 → 71, impact 71 → 70, city25 16.3 → 16.4, debris 74–82 (run to run).
The `city256-debris-ncu` job of the plan fails in its check step
(profiled-run comparison), unrelated to the candidate; the nsys job
completes.

## Continuous 600-tick A/B/A of the current defaults (`out/direct-continuous-ab-20260916b`)

Arms `out/direct-ab-arms/{A,B}` with the B runtime refreshed to the
2026-09-16 build, two trials per arm, screen locker already present. Physical
counter differences 0 on every tick of every comparison (only stress
iteration counts differ: 288 → 4 at the impact step).

| case | A-before mean | **B mean** | A-after mean | peaks (median) A/B/A | 60 Hz misses A/B/A |
|---|---:|---:|---:|---|---|
| idle-256 | 1.698 | 1.786 | 1.749 | 14.0 / 14.2 / 14.1 | 0 / 0 / 0 of 600 |
| impacts-256 | 54.73 | **30.18** | 54.55 | 171.7 / 187.5 / 194.7 | 519 / **321–323** / 519 of 600 |

Against the 2026-09-15 final (30.7 ms, 311 misses, controls 52.3): the
mean is 0.5 ms better on a 2.3 ms slower control; the miss count is within
run-to-run noise. The impact peak is unchanged (CPU registration, R2).

## Incremental cluster mass properties (R6, lossless, neutral)

`PxgDestructionTopology.cu`: the per-transaction `massProperties` kernel
(0.64 ms per call, one CTA per cluster with a 10-double block reduction)
now skips every cluster whose member set did not change since the previous
labels (`markChangedClusters` marks the old and new root of every chunk
whose label changed; roots are minimum member indices, chunk properties are
immutable, so an unchanged set has the same root and record, which is kept
instead of being cleared). city256 g16: histories identical, ratio 0.552
(within the 0.53–0.56 run-to-run band of this session). Native tests:
13/14 with the pre-existing `bombardment_contacts` motion audit failing as
on the baseline runtime.

## Session summary (2026-09-16)

Shipped defaults now: cached factors with Woodbury updates, absent-column
skipping, pipelined narrow levels, stored diagonal inverses, three solve
CTAs per SM, elastic reuse, incremental motion modes and mass properties,
eager refactor, async island observation. Measured: warm nine windows all
pass (cascade 71, impact 70, debris 80, idle 1.8 ms), continuous heavy
600-tick 54.7 → 30.2 ms with 60 Hz misses 519 → 321, histories identical
to the baseline in every screen. Not done, with groundwork recorded in the
README: R2 core (device sleep state and device-keyed partition edges) and
R5 island-scoped correction; both are multi-week PhysX-internals projects
that own the remaining 12 ms corrected pass and the CPU phase tail of the
sustained tick, and the 170–190 ms impact peak.

## R2 core increment 1: device sleep verdicts (audit only) and the flat readiness pass

`PHYSX_DESTRUCTION_DEVICE_SLEEP`: 2 audits device component sleep verdicts
(solver sleep flags reduced per accurate contact-graph label, one flag per
node read back) against the CPU's per-island readiness walk; 1 would use
them; 3 is an exact CPU variant (one flat pass over the active node lists
into a per-island bitmap). g16 3 s bombardment: audit 99.9 % agreement
(1.13 M decisions; 4.6 k CPU-only, 5.6 k device-only sleeps). The residual
comes from the CPU readiness flag being a sticky, multi-source state
(set by DEACTIVATE_THIS_FRAME, cleared by wake paths) while the solver's
flags and wake counters are per-frame; an exact device replica needs the
device to own that state (activation deltas both ways), which is the R2
core proper. Mode 3 is exact and neutral: the accurate deactivation zone
goes 0.61 → 0.57 ms per tick and the tick mean 33.2 → 32.9 ms, so the
island maintenance cost (≈2.5 ms per tick across both sims) is in
findPathsAndBreakIslands, removeEdges and deactivateIsland, not in the
readiness walk. Both modes stay off.

## R2 core bound: device-owned connectivity with sleeping disabled (g16, phases)

To bound what the island half of the R2 core can save on sustained ticks,
the existing device-owned connectivity path (`--gpu-connectivity-owner 1`,
only allowed with sleeping off) was measured against owner 0, both with
`--sleeping 0`, ticks 60–180, host wall ms per tick: accurate island
maintenance 1.59 → 0.80, speculative 1.49 → 0.78, prepareIslandRepair
1.97 → 0.47 (about 3 ms of CPU removed), bodyStatusWork 1.04 → 1.10,
afterIntegration 0.66 → 0.87. The tick mean is nevertheless worse
(32.4 → 37.2 ms, peak 189 → 359 ms) and the histories differ (owned
connectivity changes solver inputs). Conclusion: on sustained ticks the
island/sleep part of R2 is worth at most ~3 ms of CPU and the current
owned path does not realise it; the tick remains bound by the GPU stress
wait (11.8 ms) and the corrected collision pass (11.1 ms). R2's remaining
value is the impact-tick registration (item 2, device-keyed pairs); the
sustained tick's next exact lever is skipping the corrected stress solve
for components the correction did not touch (R5 stage 2 mode 2, bit-
identical on g4), measured next.

## Corrected-solve skip for untouched components (mode 2) on g16: no effect, off

`PHYSX_DESTRUCTION_ISLAND_SCOPE=2` interleaved with the default twice on the
g16 3 s bombardment: histories identical, but the direct-step counters are
identical too (eligible 43,735, applied 65,959, elastic skips 206,870 in
both), i.e. no component was actually skipped, and the tick is ~1 ms slower
(33.1/33.7 vs 32.1/32.2 ms) from the affected-set computation. The parked
component flags do not fire on this scene: the cluster body field used to
map parked bodies to stress roots (`PxDestructionStressCluster::body`, a
GPU rigid index) has to be checked against the node-index domain of the
correction targets before this lever can pay (bound: the corrected stress
solve is ~2.5 ms per corrected pass, ~1.5 ms per sustained tick).

## Corrected-solve skip (mode 2), second attempt: fires, inexact, no gain; off

Two defects kept the skip from firing. The parked-root kernel read the
description's static cluster body; the live body index lives in the
per-transaction cluster table (`acceptClusterBindings` writes
`PxDestructionStressCluster::body` from the allocation targets, so
`clusters[chunk.cluster].body` is the current GPU rigid index and matches
the island-sim node-index domain of the parked list). Second, the resident
stress solve is replayed from a captured CUDA graph, so a conditional
launch of the parked-marking kernel was captured once (without flags) and
never replayed with them. The solver now owns a persistent parked-flag
buffer, always marked inside the captured solve after the settled/elastic
writers, and refreshed outside the capture per submission (copy when
flags are armed, cleared otherwise). A `PHYSX_DESTRUCTION_ISLAND_SCOPE_DIAG=1`
line reports per reinstatement: `parked=4560 bodyCapacity=5376
flaggedRoots=4332` on the first g16 correction (142 reinstatements, all
armed).

g16 3 s bombardment, `PHYSX_DESTRUCTION_ISLAND_SCOPE=2` vs default (same build):

| | eligible | applied | accepted | elastic skips | broken bonds | mid (30–100) | late (100–180) | corrected-tick mean |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| default | 43,735 | 65,959 | 43,328 | 206,870 | 53,105 | 19.76 ms | 54.27 ms | 59.86 ms (87 ticks) |
| mode 2 | 39,428 | 61,220 | 39,071 | 144,518 | 53,362 | 20.16 ms | 52.76 ms | 60.43 ms (83 ticks) |

The skip removes 10 % of the direct-step components from the corrected
solve, but histories diverge from tick 94 (broken bonds differ on 77 of
180 ticks; +0.5 % breaks over the run) and the late window moves 1.5 ms,
inside the 3 % band. The divergence is the exactness rule's third set:
mode 2 parks components whose islands have no affected body and no trial
pair to one, but the corrected pass still re-simulates the whole scene, so
islands that gain a corrected-pass overlap with an affected body (and the
solver's re-partitioned iteration order) change those components' inputs
while their trial result is republished. Making it exact needs the
corrected broadphase's overlap set, i.e. the partition-level scoping in
README §8. Bound confirmed small (≤1.5 ms per sustained tick), so the
lever stays off; the always-launched marking kernel with zero flags is
lossless (default run bit-identical to the previous default run,
`skip4-m0-2` vs `skip6-m0`), 11/11 native GPU tests.

## Corrected-pass inputs audit, exact-input reuse, and where the late tick goes (2026-09-16)

Three measurements that close the "scope the second stress solve" idea
and re-attribute the late tick. All on the g16 3 s bombardment.

**Untouched components do not see identical inputs in the corrected pass.**
`BLAST_GPU_NATIVE_PARKED_AUDIT=1` (flags computed as in mode 2 but never
applied) compares every component's node inputs in the corrected solve with
the trial solve's, split by the island-scope parked flag (141 corrected
solves, relative difference against the larger of the two loads):

| | components | any bit changed | > 1e-6 | > 1e-3 | > 1e-1 |
|---|---:|---:|---:|---:|---:|
| parked (island untouched, no trial pair to an affected body) | 188,731 | 39 % | 29 % | 27 % | 19 % |
| live | 59,207 | 77 % | 73 % | 71 % | 66 % |

So 19 % of the components in untouched islands receive loads that differ by
more than 10 % between the two passes. The cause is the correction's
contact/friction cache reset (`resetDestructionContactCaches` /
`resetDestructionFrictionCaches`, needed because the pairs are preserved
across the rewind): the corrected pass solves the whole scene cold, the
trial pass warm. Today's histories are therefore "cold corrected" for every
island on every corrected tick; an island-scoped correction that keeps the
trial result for untouched islands is not bit-comparable to them, only
physically equivalent (a warm-started solve of the same constraints). This
is the divergence seen with mode 2, not an index-domain bug.

**The exact certificate already scopes the corrected solve.** The direct
diagnostic now prints `components=` and `skipped=` per solve: in the late
window the corrected solve skips 1,480–1,860 of 1,800–2,130 components
through the exact settled certificate (identical inputs, unchanged
component) and the elastic margin; only 115–190 components are solved, and
those are the affected remnants. An exact reference-based reuse
(`BLAST_GPU_NATIVE_EXACT_REUSE=1`: bit-identical load to the last converged
solve, no margin) adds 362 skips over the whole run (0.1 %), histories
identical, timing inside the band (late 51.6 vs 51.8 ms, run means 31.0 vs
31.2; the B repeat 35.9 vs 31.6 is a desktop interference outlier). Kept
off: nothing left to skip. The 4.7 ms per late solve is the CTA-cycle
throughput of the ~150 affected remnants plus the tiny-component setup
(census above), not the number of components entering the kernel.

**GPU busy is 26 % of the late tick.** nsys (`--cuda-graph-trace=node`)
over the whole run: 15.9 ms of kernels per tick, of which
`componentStressSolve` 5.1 (3.46 ms avg, 4.70 in the last third),
`factorNativeDirect` 4.0 (3.8 launches per tick, 521 of 678 are empty
0.01 ms launches; the real ones are 2–5 ms), incremental SAP 1.1, all rigid
solver kernels together < 1 ms. In a 55 ms window around a late corrected
tick the GPU is busy 14.2 ms. The per-tick phase timeline of a late
corrected tick (step 150, 42 ms): trial CPU pipeline 0–12.9 ms, wait for
the trial stress result 13.5–21.9, corrected pass 23.0–34.0 (its own GPU
waits: broadphase 1.6, narrowphase ~0.9, solver ~3.0, post-solver 1.6; CPU
sub-phases ~4.5), accept 1.2, submit 0.7, wait for the corrected stress
result 35.8–42.2. `perf` over the late window is flat: the largest self
symbols are `PxgPostSolveWorkerTask` 3.2 %, `IslandSim::processLostEdges`
2.4 %, `PxgBatchRigidStaticConstraintPrePrepTask` 2.0 %, scene-query pruner
refit ~4 % in total, hash-map erases from fragment shape churn ~1.5 %;
`cudaEventSynchronize` and the mapped-flag spin wait are 23 % (the GPU
waits above). No single CPU hotspot above 4 %.

Consequences for the remaining plan: the two stress solves are latency
floors of ~4.7 ms each on this GPU (remnant chains × waves), the corrected
pass is ~11 ms of full-scene CPU pipeline plus small GPU waits, and the
trial pass ~13 ms of the same. Only structural scoping of the corrected
pass on the CPU side (R5 partition-level) or fewer CPU consumers per pass
(R2) move those; both remain multi-week and are not bit-comparable.

## R5 stage 3: frozen corrected pass on the device (mode 4) — physically close, slower; off

`PHYSX_DESTRUCTION_ISLAND_SCOPE=4` keeps the island sim and the incremental
partition untouched and instead (a) reinstates the candidate bodies (active
islands with no correction target, no reserved fragment and no trial edge to
one) to their trial end-of-tick state right after the checkpoint restore,
(b) after the corrected island gen removes the ones a new touch merged into
an affected island (gathered back to the checkpoint and solved normally,
`restoreCheckpointBodies`), (c) removes the frozen bodies from the solver's
active list (`PxgGpuContext::update` takes the controller's filtered list;
their static contacts are not batched, their partitioned contacts become
empty constraints in the pre-prep) and (d) parks their stress components
(trial forces republished, certificates and references preserved). Four
defects had to be fixed on the way; the first is a latent one and stays on
by default:

1. `PxgSolverCore::allocateFrictionCounts` now zero-fills the current
   friction-patch-count generation each solve. The ping-pong buffer kept
   garbage for edges a pass did not visit, and the next pass's warm start
   read patch indices from another pass's batch space (warp MMU fault in
   `getFrictionPatches`, the "late CUDA 700" that also killed modes 1/3).
   Lossless: the default run is bit-identical before and after.
2. Parked pairs are empty constraints (no contacts, no friction warm start,
   zero published patches): solved as world-vs-world or world-vs-kinematic
   their unit response is zero, and their friction anchors were correlated in
   the world frame and reused by the real bodies next tick (buildings
   collapsed two ticks after every frozen pass, +25 % bonds).
3. Frozen bodies must sit at their trial end-of-tick pose through the
   corrected broadphase/narrowphase, or their persistent contact manifolds
   are updated to a pose one tick behind (same collapse signature with
   single-body islands only).
4. The parked marking runs after the settled/elastic reuse kernels and used
   to leave the component "unverified"; the commit then dropped its
   certificate and reference, so the next trial solve re-solved every
   frozen component (+36 % eligible components).

g16 3 s bombardment, mode 4 vs default (both `--profile-phases 1`):

| | late window | corrected-tick mean | broken bonds | clusters | eligible (direct) | elastic skips |
|---|---:|---:|---:|---:|---:|---:|
| default | 54.0 ms | 60.0 ms | 56,077 | 12,248 | 43,735 | 206,870 |
| mode 4 | 61.2 ms | 68.6 ms | 60,004 | 13,407 | 54,125 | 117,365 |

Per-tick phases (late window, ms): `correctedCollisionSolve` 19.5 vs 14.5
(`detail.updateDynamics` 2.26 vs 0.40 is the finalize: island walk plus two
stream synchronisations; `postBroadPhase` 2.5 vs 2.0; `postNarrowPhase` 1.4
vs 0.9), `restoreInstall` 1.26 vs 0.18 (the install-time reinstate),
`waitForGpu` 16.0 vs 14.0. Histories track the default closely for the
first ten corrected ticks (602/1861/4/329/153 breaks identical or within a
few bonds) and then diverge by the warm-vs-cold difference (+7 % bonds over
the run); 324 of 810k candidate-passes were merged by a new touch (third
closure set, handled exactly).

Why it does not pay: the GPU work the freeze removes is under 1 ms per
corrected pass (rigid solver kernels are ~1 ms per tick in total, the
corrected stress solve already skips 92 % of components through the exact
certificate), while the corrected pass costs ~11 ms of CPU pipeline stages
and launch-latency chains that are unchanged by removing bodies from the
solver list. Even with the overheads made asynchronous the lever is bounded
by the broadphase/narrowphase share (~1–2 ms). Kept off; the mechanism and
its fixes are in place for a CPU-level scoping (island gen, contact-manager
management, post-solve tasks restricted to the closure), which is the only
R5 route with a measurable upside (~5 ms per corrected tick) and remains
multi-week.

## Load-change tolerance skip (R4 variant): remnant loads change by more than 1 % per tick; off

`BLAST_GPU_NATIVE_EXACT_REUSE=1` with `BLAST_GPU_NATIVE_EXACT_REUSE_TOL`
skips a component whose load moved by less than the tolerance (relative L2
against the last converged reference load), with no elastic-margin
condition. g16 3 s bombardment, extra skips over 267 solves: 592 at 1e-4,
1,390 at 1e-3, 5,604 at 1e-2 (eligible 43,735 → 38,457 at 1e-2, −12 %);
histories identical at all three (56,077 broken bonds), late window
53.6–55.5 ms vs 54.0 (noise band). The remnants that are solved every tick
carry debris and impact loads that change by more than 1 % between ticks,
so a tolerance-based skip cannot remove their fixed cost. Off (tolerance 0).

## CPU worker count and the GPU stress path per tick (2026-09-16)

The demo's dispatcher is 4 workers (`PxDefaultCpuDispatcherCreate(4)`, now
overridable with `PHYSX_DEMO_CPU_THREADS`, default unchanged). g16 3 s
bombardment, identical histories: late window 54.9 ms with 4 workers, 57.9
with 8, 62.2 with 16; the impact tick 207 → 223 → 228 ms. The CPU pipeline
is a chain of short stages and GPU synchronisation points, not a pool of
parallel work; more workers only add contention.

The demo's CUDA-event stage timings (`native.phases.csv.device.csv`, late
window, per tick) put the destruction GPU path at 12.8 ms
(`GpuDestruction.cuda.stress`: the two solves, the eager refactor, motion
modes and hierarchy construction) plus contact loads 0.96, topology and
candidates 0.62, allocation/preparation 0.31, materials 0.23. On the
corrected tick 150 the trial stress phase is 7.5 ms and the corrected one
5.6 ms. That matches the 14 ms/tick the CPU spends in `waitForGpu`: the
stress path is the critical GPU chain, and it is bounded by the ~255
remnants that must be solved every tick (their loads change by more than
1 % per tick, so no exact or tolerance skip applies) at ~3 Mcycles each.

## Speculative stress topology and refactor off the acceptance path (default on, lossless)

Attribution with host timers and an aligned nsys timeline showed that
`acceptCorrection` at the impact tick (26 ms) and the sustained tick's
acceptance (1.4 ms/tick) were the eager refactorization: the corrected
topology is committed only after the corrected rigid pass, so the stress
topology rebuild and the changed components' refactor sat between
acceptance and the corrected stress solve. A persistent refactor grid also
stalls every other stream's launches until its work list drains (measured:
a 1-block kernel on the runtime stream waited 22 ms with no event between
it and the previous launch, regardless of stream priority, grid size or
`CUDA_DEVICE_MAX_CONNECTIONS`).

Change: the stress topology is updated speculatively from the *trial* view
right after the trial transaction (`PHYSX_DESTRUCTION_SPECULATIVE_STRESS_TOPOLOGY`,
default 1). A commit deferred to the corrected pass copies the trial status
into the accepted one, so the acceptance-time update finds the same
generation and is a no-op, and the refactor overlaps the corrected rigid
pass. The eager refactor itself runs on a solver side stream and is
launched by the runtime after its own synchronisations
(`flushEagerFactor`, `BLAST_GPU_NATIVE_FACTOR_STREAM`, default 1); every
solver-stream consumer of the direct state joins it first. A correction
that never runs (`discardSpeculativeTopology`, called by the controller
when no corrected pass follows, plus a solve-time safety net) rolls the
solver back: forced rebuild at the accepted generation, hierarchy and
motion-mode level statuses reset, speculatively zeroed bond health restored.

g16 3 s bombardment, two interleaved pairs, histories bit-identical
(56,077 broken bonds, identical to the session's baseline):

| | late window | corrected-tick mean | waitForGpu /tick | accept /tick | impact: accept | impact: wait |
|---|---:|---:|---:|---:|---:|---:|
| off | 54.2 / 53.8 ms | 59.7 / 58.8 | 13.7 / 13.8 | 1.40 | 26.0 | 11.5 |
| on | 52.8 / 52.5 ms | 58.0 / 58.2 | 12.3 / 12.4 | 0.36 | 1.1 | 15.1 |

An earlier pair measured 49.9/50.0 vs 52.9/51.9. The impact tick itself is
roughly neutral (186/156 → 193/202 ms): the 22 ms burst now competes with
the corrected rigid pass's kernels instead of blocking acceptance, and
smaller eager grids (1–4 CTAs per SM) are slower overall. 11/11 tests.

## Continuous 600-tick A/B/A of the 2026-09-16c defaults (`out/direct-continuous-ab-20260916c`)

Same procedure (`run-destruction-ab.py`, two trials per arm, 10 simulated
seconds, ordinary APIs, sleeping on, one correction), candidate arm =
runtime, GPU module and demo at `9707b24f` (friction-count zero-fill,
speculative stress topology, side-stream eager refactor), baseline arm = the
2026-09-15 shipped set. Physical work counters match on every one of the
600 ticks in all four comparisons (0 differences; only stress iteration
counts differ, 288 → 4 at the impact step).

| case | A-before mean | **B mean** | A-after mean | peaks (median) A/B/A | 60 Hz misses A/B/A |
|---|---:|---:|---:|---|---|
| idle-256 | 1.715 | 1.894 | 1.687 | 14.4 / 14.3 / 12.9 | 0 / 0 / 0 of 600 |
| impacts-256 | 54.84 | **28.39** | 54.76 | 185.4 / 197.8 / 208.5 | 519 / **306–315** / 519 of 600 |

Against the previous shipped defaults (30.2 ms, 321 misses, idle 1.79) the
sustained mean improves by 1.8 ms and the idle tick costs 0.1 ms more (the
per-solve friction-count clear and the factor-stream joins). The impact
peak (196–199 ms) lies inside the baseline arm's own spread (178–210 ms).

## Acceptance verification sweep skipped after a reused direct norm (default on, lossless)

When the first monitor reuses the direct step's residual norm, that norm was
evaluated on the residual rebuilt from the same solution (rebuild, prepare,
matvec); the acceptance verification repeated exactly that computation.
`BLAST_GPU_NATIVE_SKIP_VERIFY` (default 1) skips it in that case. g16 3 s
bombardment, two interleaved pairs: histories bit-identical (56,077 broken
bonds); CUDA stress stage 10.15/10.16 → 9.87/9.88 ms per late tick,
`waitForGpu` 12.49/12.56 → 12.22/12.27; the tick itself moves inside the
noise band (late 52.8/49.7 vs 54.1/50.4). 11/11 tests.

## R5 device-side scoping closed: even freezing only isolated bodies is not comparable (mode 4 stays off)

Two follow-ups on mode 4. Its host synchronisations were replaced by pinned
double-buffered staging and its per-growth reallocations (trial snapshot,
parked bitmap, reinstate list) by geometric growth; `restoreInstall` fell
from 5.9–7.5 to 0.26 ms per late tick. Then the candidate set was
restricted to bodies with no island edge and no static contact
(`PHYSX_DESTRUCTION_ISLAND_SCOPE_FREEZE_ISOLATED=1`), whose trial and
corrected states are identical by construction. g16 3 s bombardment:

| | late window | corrected-tick mean | broken bonds | first differing tick |
|---|---:|---:|---:|---|
| default | 51.7 ms | 57.0 | 56,077 | – |
| mode 4, isolated only, reinstate at install | 57.0 ms | 63.2 | 57,432 | 85 (post-correction verdict) |
| mode 4, isolated only, reinstate at finalize | 77.2 ms | 78.5 | 74,243 | 85 |

Even with only isolated bodies frozen the history diverges at the first
frozen pass, because removing any body from the solver's active list
renumbers every other solver body and changes the partition's accumulation
order, so the rigid solve of the unrelated bodies is no longer bit-identical;
the +2.4 % breakage of the install-time variant is chaos amplified by the
fracture model, and the finalize-time variant (bodies at the checkpoint
through narrowphase, reinstated before the solve) is systematically wrong
(+32 %). The mechanism also costs ~3 ms per corrected tick with almost no
body frozen (finalize walk, filtered list, empty constraints). Since neither
a bit-identical reference nor the physical counters can separate a defect
from chaos here, and the upside measured earlier is below 1 ms of GPU work,
device-side island scoping is closed; mode 4 remains available, off.

## Impact-tick CPU profile (perf restricted to step 82) and two lossless follow-ups

`perf record -k CLOCK_MONOTONIC` with the phase timestamps selecting only
the impact tick (227 ms under `--profile-phases 1`, 46k samples): the
demo's own phase profiler is 10–15 % of that tick (per-shape scopes), which
is why unprofiled impact ticks are 180–190 ms; the rest is diffuse PhysX
new-pair work (`ShapeInteraction::createManager` 2.0 %, `runOverlapFilters`
1.2 %, `IslandSim::processNewEdges` 1.2 %, `addPreallocatedContactManager`
0.8 %, contact-manager construction 0.7 %, hash-map creates 1 %, atomics
2.8 %), the allocator's per-shape body lookup (`source()` + hash-map find
2.7 %), and heap/pinned growth (`sysmalloc`, `mprotect`, page faults ~7 %).

- Pre-sizing scene limits and GPU dynamics storage
  (`PHYSX_DEMO_SCENE_LIMITS=1`, off by default): impact 190–206 vs 178–188 ms,
  no gain; the demo already scales the GPU dynamics config.
- Resolving each body once per binding batch (validation, scheduling,
  migration and publication reuse the resolved pointers; duplicate shapes
  tracked in a bitmap instead of a hash map): bit-identical, impact 181–183
  vs 178–188 ms (inside the ±10 ms spread of that tick), 11/11 tests. Kept.

## Warm screen caught a regression of the incremental cluster mass properties (fixed)

The nine-window screen for the 2026-09-16c defaults (`results-16c-v4`)
passed eight windows and failed `city256-debris-B` at the first replayed
tick with stage error 128 (solver-body preparation): 5,949 candidate
clusters had zero mass and inertia. Cause: since the incremental cluster
mass properties (R6, this morning) only clusters whose membership changed
against the accepted labels are recomputed, but the transaction never
copied the accepted cluster table into the trial topology, so after a
snapshot restore (and after any rejected transaction) the trial carried
stale masses for every unchanged cluster. The g16 demo never replays a
snapshot and commits every transaction, which is why the continuous and
g16 screens stayed bit-identical. Fix: the trial copies the accepted
cluster table at prepare (`PxgDestructionTransaction.cuh`; a device copy
of ~9 MB per transaction, tens of microseconds). The failing probe passes;
the screen is rerun as `results-16d-v4`.

## Warm nine-window screen of the 2026-09-16d defaults (contract v4, `results-16d-v4`)

Candidate = runtime, GPU module and probes at `b5144342` (all lossless defaults of the day plus the cluster-table fix); controls A0/A1 = the 2026-09-13 baseline artifacts. All nine windows pass. Means in ms (A0 / B / A1); the 09-16 morning screen (`results-solve2-v4`) is in brackets:

| window | A0 mean | B mean | A1 mean | A0 max | B max | A1 max | misses A0/B/A1 | B force relL2 | B health drift | B check |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| bridge64 | 1.47 | 1.57 | 1.48 | 1.77 | 2.01 | 1.73 | 0/0/0 of 16 | 3.00e-07 | 0.0e+00 | passed |
| chain256 | 1.76 | 1.48 | 1.82 | 2.02 | 1.74 | 2.27 | 0/0/0 of 16 | 8.31e-08 | 0.0e+00 | passed |
| city25-impact | 24.20 | 16.25 | 24.23 | 44.66 | 39.69 | 40.26 | 10/8/10 of 16 | 1.53e-03 | 1.1e-06 | passed |
| city256-cascade | 112.23 | 69.00 | 113.17 | 152.51 | 109.35 | 158.10 | 16/16/16 of 16 | 1.25e-03 | 1.1e-06 | passed |
| city256-debris | 131.18 | 77.33 | 131.48 | 136.29 | 83.90 | 134.77 | 16/16/16 of 16 | 1.89e-02 | 3.0e-05 | passed |
| city256-idle | 1.72 | 1.92 | 1.78 | 2.02 | 2.41 | 4.89 | 0/0/0 of 32 | 2.39e-07 | 0.0e+00 | passed |
| city256-impact | 93.79 | 68.58 | 93.28 | 197.42 | 189.00 | 191.76 | 16/16/16 of 16 | 4.37e-04 | 1.2e-06 | passed |
| dense12 | 1.51 | 1.79 | 1.73 | 1.75 | 2.14 | 2.16 | 0/0/0 of 16 | 4.42e-08 | 0.0e+00 | passed |
| tower64 | 1.43 | 1.46 | 1.45 | 1.59 | 1.75 | 2.18 | 0/0/0 of 16 | 4.60e-08 | 0.0e+00 | passed |

cascade 69.0 [71.0], impact 68.6 [69.8], debris 77.3 [80.3], city25 16.3 [16.4], idle 1.92 [1.80]; force relL2 and health drift unchanged from the previous screen (the stress solves are bit-identical), so the movement is the acceptance and refactor scheduling.

## R2 milestone 2 item 2, step 1: device-owned contact slot allocator (lossless, neutral)

Every NP pair now carries a device-owned dense slot next to its lifetime generation (`PxgContactGraphIdentity::slot`, `PxgContactSlotAllocator` in `PxgContactManager.h`). Slots are reserved per block inside `initializeManifolds` (free list first, then the high-water mark; `PxgContactIdentity.cuh`) and returned by a new kernel `releaseContactSlots` launched at `removeLostPairs`, before compaction moves the retired rows. The host tracks only an upper bound of live slots to size the free list (doubling, 64 K floor); no host code reads or assigns slot values. The CPU island edge index stays in `edgeIndex`, so this step changes no solver input: it is the dense key that steps 2 to 5 of README §12 will use for `PartitionEdge`, solver constants, friction counts and the destroyed-edge clear.

Qualification: `destruction_gpu_contact_graph` gained a slot test (70 K concurrent allocations on two streams, release of every third row, LIFO reuse before high-water growth, latched capacity error); `native_contact_graph_check.h` now also requires unique in-range slots among live rows and consistent allocator counters, and 36/36 native GPU tests pass including every test that includes that check. g16 3 s bombardment, interleaved control (committed tree) and candidate, four trials each: histories bit-identical (all counters, 56,077 bonds broken, 99/180 misses each), means in ms:

| arm | trial means | avg | peaks |
|---|---|---:|---|
| control `de647cfb` | 31.70, 31.31, 31.88, 30.14 | 31.26 | 181.7, 195.4, 189.7, 195.5 |
| candidate (slots) | 31.60, 32.05, 31.43, 31.21 | 31.57 | 191.1, 199.7, 191.4, 193.4 |

Neutral within the control spread (mean +0.3 ms, peak +3 ms against a 14 ms peak spread). Cost model: one extra launch per bucket per pass with retirements, and 4 bytes per slot.

## R2 milestone 2 item 2, step 2: friction state keyed by a dense pair slot instead of island edge handles (lossless, neutral)

Step 1's device-side allocator could not feed the partition: the host needs the key when it creates `PartitionEdge`s and solver constants, before the pass runs. The slot is therefore host-owned now (`PxgGpuNarrowphaseCore::allocateContactSlot`, called from `PxgNphaseImplementationContext::registerContactManager` for every contact manager, GPU buckets and fallback alike) and stored in the work unit's former padding word (`PxcNpWorkUnit::mDeviceSlot`). It survives refreshes, is retired at unregister, and is recycled only after `removeLostPairs` has compacted the retired device row. The identity kernel publishes it into `PxgContactGraphIdentity::slot`; the device allocator, its release kernel and counters are gone.

The solver constants gained `mPairSlot` (joints carry the invalid slot). Contact pre-prep now keys `prevFrictionPatchCount`, `currFrictionPatchCount` and the friction index stream by the slot; the friction buffers are sized by the partition's monotone slot capacity instead of `getNbEdgeHandles()`; every "destroyed contact edge" push (lost touch, deactivated, activated, destroyed partition edge) records the slot, obtained from the work unit or, for destroyed partition edges, from the solver constants; the frozen-static-edge clear of mode 4 maps through the slot too. Consequence for step 6: the friction domain no longer references island edge handles, so native pairs without a CPU island edge can keep friction warm starts.

Qualification: `destruction_gpu_contact_graph` checks slot publication; `native_contact_graph_check` requires unique in-range slots among live rows; 36/36 native GPU tests. g16 3 s bombardment, four candidate trials against the four control trials of step 1 (control binary = `de647cfb` PhysX; histories bit-identical, 56,077 bonds, 99/180 misses):

| window (mean over 4 trials, ms) | control | slot-keyed |
|---|---:|---:|
| pre-impact ticks 0–79 | 4.93 | 4.88 |
| impact ticks 80–99 | 55.89 | 56.28 |
| late ticks 100–179 | 51.44 | 51.43 |
| run mean | 31.26 | 31.28 |
| peak tick 82 | 181.7, 195.4, 189.7, 195.5 | 149.4, 200.5, 207.7, 208.1 |

Neutral; the peak tick (the first impact, dominated by allocation growth) has a wider spread in the candidate but the same mean (190 vs 191).

## R2 milestone 2 item 2, step 3: contact partition edges reachable by pair slot (lossless, neutral)

`IG::GPUExternalData` gained `mFirstPartitionEdgesBySlot`, a second head map for contact partition edges keyed by the pair slot. The GPU partition mirrors every head update of a contact edge into it (`updatePartitionEdgeLinkedListHead`, `removeEdge`, the deferred removal in the found/lost patch pass, deactivated contacts, and the destroyed-partition-edge loop, where the island manager has already nulled the edge-handle head). The narrowphase-driven lookups now use the slot map: `processPartitionEdges` (the CPU↔NP rebinding hook), the lost-patch and found-patch passes. Island-driven loops (activated, deactivated, destroyed edges) and joints stay on the edge-handle map; those are the loops step 6 replaces for native pairs.

A first version read the slot from the solver constants on every patch removal (a cold 16-byte line per removal) and measured +0.6 ms; the mirror now touches the constants only when the removed patch is the list head, and the explicit clears cover the island-nulled cases. Because the earlier controls were library swaps only, a full control binary was built from `de647cfb` (`out/direct-factor-feasibility-20260915/control-de647cfb-bin`) and the g16 3 s bombardment was run interleaved, four trials per arm (histories bit-identical, 56,077 bonds, 99/180 misses):

| window (mean over 4 trials, ms) | control `de647cfb` | steps 1–3 |
|---|---:|---:|
| pre-impact ticks 0–79 | 4.87 | 4.91 |
| impact ticks 80–99 | 54.28 | 54.94 |
| late ticks 100–179 | 49.93 | 49.93 |
| run mean | 30.39 | 30.48 |
| peak tick 82 | 178.2, 186.1, 193.9, 177.5 | 182.0, 193.1, 183.4, 198.3 |

Neutral. The control binary directory is the reference for the remaining steps.

## Warm nine-window screen of R2 steps 1–3 (contract v4, `results-r2s3-v4`)

Candidate = runtime, GPU module and probes at `48854ccb` (steps 1–3 plus the sleep-audit diagnostic; probes rebuilt because `PxcNpWorkUnit` gained the slot word); controls A0/A1 = the 2026-09-13 baseline artifacts. All nine windows pass; force relL2 and health drift are identical to `results-16d-v4`, so the stress solves are bit-identical and only scheduling noise moves. Means in ms (A0 / B / A1), previous screen's B in brackets:

| window | A0 | B | A1 | B max | misses A0/B/A1 | B check |
|---|---:|---:|---:|---:|---:|---|
| bridge64 | 1.26 | 1.52 | 1.69 | 2.12 | 0/0/0 of 16 | passed |
| chain256 | 1.43 | 1.66 | 1.60 | 2.02 | 0/0/0 of 16 | passed |
| city25-impact | 23.59 | 15.94 [16.25] | 23.78 | 35.74 | 10/7/10 of 16 | passed |
| city256-cascade | 112.21 | 68.21 [69.00] | 110.84 | 106.41 | 16/16/16 of 16 | passed |
| city256-debris | 130.13 | 79.24 [77.33] | 129.93 | 86.89 | 16/16/16 of 16 | passed |
| city256-idle | 2.86 | 1.77 [1.92] | 1.75 | 2.07 | 0/0/0 of 32 | passed |
| city256-impact | 92.34 | 68.85 [68.58] | 93.91 | 186.49 | 16/16/16 of 16 | passed |
| dense12 | 1.63 | 1.63 | 1.51 | 1.91 | 0/0/0 of 16 | passed |
| tower64 | 1.61 | 1.61 | 1.50 | 2.14 | 0/0/0 of 16 | passed |

The optional `city256-debris-ncu` profiling job after the nine windows timed out under its 180 s watchdog (the nsys job completed); it is not part of the contract.

## Device sleep verdicts re-timed (R2 item 1, increment 2): device-side exact, CPU residual remains; mode 1 measured and kept off

The verdict is now enqueued on the solver stream right after `integrateCoreParallel` of every pass (`PxgSimulationController::enqueueDestructionSleepVerdicts`, called from `PxgGpuContext::update`), from that pass's pre-solve node labels (`mPreLabels`, stable during the solve) with nodes absent from the solver list defaulting to not ready; the pending verdict is published when the next tick's trial pass prepares its island repair, and a corrected pass reuses the published one (`publishComponentSleepVerdicts` / `componentSleepVerdicts` in `PxgDestructionRuntime`). Device-side contradiction test (`PHYSX_DESTRUCTION_DEVICE_SLEEP_DIAG=1`): 0 of 454 k solver entries (was 763 of 1.72 M).

The island audit (`PHYSX_DESTRUCTION_DEVICE_SLEEP=2`, g16 3 s bombardment) still disagrees on 0.8 % of island decisions (1.069 M decisions: 4,154 CPU-only sleeps, 4,399 device-only). The samples are now the CPU's sticky readiness: fragments are created with the ready flag (inactive at creation), the solver's first pass reports them moving (`solverWakeCounter` 0.44, `ACTIVATE_THIS_FRAME`), the CPU island still deactivates the single-body island because the flag is only cleared by CPU wake paths, and the device says not ready. An exact replica therefore needs the CPU's flag sources on the device (creation state, user wakes, kinematic touches), i.e. device-owned activation, not a better reduction.

`PHYSX_DESTRUCTION_DEVICE_SLEEP=1` (device verdicts decide) on the same run, two trials: 59,271 and 59,272 bonds broken against 56,077 (+5.7 %, outside the 3 % envelope of §11), clusters 11,285 / 11,318 against 10,945 at t = 2 s, motion audit position error ≤ 2.2e-5. More fragments stay awake at birth (physically the more faithful behaviour), but it is an order-changing default that fails the envelope, so it stays off.

Default path after the change (mode 0), interleaved against the control binary, three trials each, histories bit-identical: 31.82 → 31.80 ms; late window 52.34 → 52.42; 36/36 native GPU tests after relinking the test binaries (the runtime vtable changed).

## Sleep audit residual: the fragment birth wake counter is not the cause (negative result)

Hypothesis: fragments are reserved with a zero wake counter (`NpDestructionBodyAllocator::reserve`) and keep it when installed, so the CPU scheduler treats them as about to sleep and the island manager deactivates them before they move. Test: an env-gated reset of the CPU wake counter to the scene's reset value at install (before `setActive`/`notifyNotReadyForSleeping`), rebuilt PhysX. Result on the g16 3 s bombardment: histories bit-identical to the control (56,077 bonds, all counters), the mode 2 audit unchanged (4,219 CPU-only, 4,354 device-only of 1.106 M decisions), and the sampled roots still show `wake=0, solverWake=0.44, rootReady=1, ACTIVATE_THIS_FRAME` at the third pass. The CPU value written at install does not survive to the first third pass, so the zero wake counter and the ready flag of these nodes come from a later step of the lifecycle (correction restore or GPU sleep finalization), not from birth. The experiment was reverted; mode 1 with the birth reset also reproduced the earlier +5.7 % (59,282 bonds).

## Sleep audit residual located: the island-generation-versus-solver race rule (diagnostics committed)

The audit print now carries the pass (trial/corrected, tick counter) and the node's pre-solve lifetime, and the corrected pass merges the trial's verdict for nodes born in that tick (`componentSleepVerdictsForCorrection`), which did not change the counts (4,214 CPU-only, 4,410 device-only of 1.09 M). Every sampled mismatch is a trial pass, a single-body island of an early-born fragment (lifetime stamp 1), CPU wake counter 0 with the readiness flag set, while the body's solver record says `ACTIVATE_THIS_FRAME` with wake counter 0.44. That is PhysX's own race resolution in `afterIntegration` (`ScPipeline.cpp`, "permit the IG to make the authoritative decision"): island generation deactivates islands in parallel with the solver, and a body the island generator deactivated in the same tick is rolled back to its start-of-tick state with a zero wake counter, its solver wake flags discarded, and its readiness flag left set. The device verdict is built from the solver's data, so it says awake; the CPU says asleep. Bodies in that state can be re-activated by island generation without their readiness being cleared, which is why the CPU sleeps them again at the next third pass.

Consequence: an exact device replica must apply the previous tick's island deactivation list (`getNodesToDeactivate`) over the solver-derived verdict, i.e. the CPU race rule has to be fed to the device, or the device has to own deactivation outright (device-owned activation state, R2 item 1). Neither is a bounded change on top of the current pipeline; both are recorded in README §9. Mode 1 stays off.

## Device reduction of island sleep decisions is exact (modes 4/5; lossless, kept off for cost)

Half-step toward device-owned sleep: the CPU stays the source of per-node readiness (the sticky `isReadyForSleeping` flag, rigid dynamics only), uploaded as one byte per node at island repair time, and the per-island "all members ready" reduction runs on the device over the repair graph's component labels (`reduceCpuReadiness`, `PxgDestructionRuntime.cu`), on the runtime's own stream so the third island pass does not wait for the solver. Each island sim gets its own reduction: the accurate sim over the accurate labels, the speculative sim over the speculative labels. The result is consumed exactly where the CPU walk was (`PxsIslandSim.cpp`, mode 4 uses it, mode 5 audits it), without the "woken this frame" guard since CPU wakes are already in the flags.

Three things had to be right, each found by the audit: (1) reduce over the repair graph built after this pass's narrowphase, not the pre-solve labels, otherwise pairs whose touch was found this pass leave device components finer than CPU islands (7,261 disagreements); (2) drop the woken guard for CPU-sourced readiness (3,472 CPU-only disagreements); (3) reduce the speculative sim over the speculative labels (the last 4,827). With all three, `PHYSX_DESTRUCTION_DEVICE_SLEEP=5` reports 0 disagreements in both sims on the g16 3 s bombardment (accurate 802,816 decisions, speculative 540,672), and `PHYSX_DESTRUCTION_DEVICE_SLEEP=4` reproduces the control histories bit for bit (56,077 bonds, every counter identical), 36/36 native GPU tests.

Cost, interleaved against the control binary, three trials each (ms): run mean 30.77 → 31.57, pre-impact 5.02 → 4.97, impact window 55.58 → 57.36, late 50.33 → 51.73. Two uploads, two reductions and two synchronous readbacks per pass replace a 0.04 ms CPU walk, so the mode stays off. Its value is what it proves: the device components of the repair graph are exactly the CPU islands for sleep purposes, and the island deactivation decision can be produced on the device with no fidelity change. The next R2 core step is to move the readiness sources (solver deactivate/activate flags, CPU wakes, creation state) onto the device so the upload disappears and the CPU island walk for native bodies can go.

## Device-resident readiness state by deltas is exact (modes 6/7; lossless, kept off for cost)

Second half-step toward device-owned sleep: the CPU still runs its readiness sources, but every change of the island sim's `isReadyForSleeping` flag (node creation, activation, solver-driven deactivation, correction restore) is recorded as a delta (`IslandSim::noteReadiness`, atomic slot counter into a preallocated buffer, overflow reported so the consumer reseeds) and replayed into a per-sim device mirror (`applyReadinessDeltas`: last write wins, resolved in parallel by a highest-index pass; pinned staging, no host sync). The reduction of the previous section then reads the mirror (`reduceMirroredReadiness`); the per-node upload of the previous mode is gone. A first version recorded deltas into a plain array from multi-threaded island tasks and was nondeterministic (three trials: 53,126 / 53,112 / 53,122 bonds at t = 2 s); the atomic recording fixed it.

Verification (`PHYSX_DESTRUCTION_DEVICE_SLEEP=7`, g16 3 s bombardment): mirror equals the CPU flag on every node checked (accurate 1,807,775 checks, speculative 1,807,775, 0 differences); island decisions agree on all 1.34 M; `PHYSX_DESTRUCTION_DEVICE_SLEEP=6` reproduces the control histories bit for bit in three trials (56,077 bonds, all counters); 36/36 native GPU tests.

Cost, interleaved against the control binary, three trials each (ms): run mean 32.26 → 33.52, pre-impact 5.09 → 5.06, impact window 56.22 → 58.33, late 53.44 → 55.78. The remaining cost is not the replay (one delta upload and two small kernels per sim) but the third island pass now waiting for this pass's repair graph build, which the CPU walk never needed. That wait is inherent while the reduction uses this pass's labels, so the mode stays off. What it establishes: the sleep readiness state now lives on the device, exact, maintained by deltas; the next step is to produce those deltas on the device (solver deactivate/activate flags after integration, creation and correction-restore deltas from the runtime) and to consume the reduction there, at which point the CPU island walk for native bodies and the wait both disappear.

## R2 step 4 sizing: what a narrowphase-driven partition source can reproduce (audits committed, off)

Step 4 replaces the island sim's activated-contact list, from which the GPU partition creates new partition edges (`updateIncrementalIslands_Part2_0`), with a narrowphase-driven source. Two env-gated audits on the g16 3 s bombardment (256 passes, 81 of them corrected) measure it:

- `PHYSX_DESTRUCTION_PARTITION_SOURCE_AUDIT=1` (partition): of 210,602 patch items reaching the partition from activated contacts, 96 % are new touches of this pass (`prevPatches == 0`), 4 % are already-touching pairs woken by island activation.
- `PHYSX_DESTRUCTION_PARTITION_NP_AUDIT=1` (scene, `updateDynamics`): the scene's touch-found event array covers only 32 % of the island's activated pairs, because for GPU narrowphase the events of first-pass managers are not in that array at this point; the low-level touch-event bitmap (`PxsContext::getContactManagerTouchEvents`, new accessor) with touch taken from this pass's narrowphase output covers 89 %, and only with an either-dynamic-endpoint-active gate: a both-endpoints gate rejects 121,476 pairs that the island sim activates by waking the second endpoint. Coverage: 189,886 of 211,835 island items; missing 21,949, of which 17,804 are corrected-pass re-activations of pairs the trial already activated (a trial-to-corrected carry of the set recovers only part of them) and 2,825 are wake re-activations of already-touching pairs; 2,342 pairs are in the narrowphase set but not activated by the island sim (2,215 of them with the edge inactive).

Design consequence for step 4: the source is (touch bitmap ∩ touching per narrowphase output ∩ either endpoint active), plus a replay of the trial pass's set in corrected passes, plus an activation-event source for woken pairs (the device readiness deltas already record activations per node; the pair set of a woken node needs per-node adjacency from the pair roster). Partition insertion order will differ from the island order, so the swap is order-changing and qualifies under §11, not by identical histories.

## R2 step 4 built env-gated, and the acceptance envelope is miscalibrated (order-only change: +23 % bonds)

`PHYSX_DESTRUCTION_PARTITION_NP_SOURCE=1`: the scene builds the candidate list for new partition edges from the low-level touch bitmap (touching per this pass's narrowphase output, either dynamic endpoint active, corrected passes replay the trial's list) and hands it through a new `Dy::Context::setPartitionCandidateEdges` hook; the partition's second pass takes new touches from it and only the residual (woken already-touching pairs and source gaps) from the island's activated list, still gated by the island's active-contact bitmap as the activity oracle for now. On the g16 3 s bombardment: 194,041 items from narrowphase, 26,660 residual (88 % / 12 %), three trials identical (13,657 peak clusters, motion audit 1.7e-5), 14/14 tests. Bonds broken 60,409 against 56,077 (+7.7 %), which the §11 envelope rejects.

Calibration (`PHYSX_DESTRUCTION_PARTITION_REVERSE_AUDIT=1`, default source, same set of partition edges, insertion order reversed): 69,243 bonds (+23 %), 12,389 clusters at t = 2 s against 10,945, deterministic over two trials. A pure order change moves the total three times more than either rejected candidate did. The bombardment cascade is chaotic at the level of bond totals, so a ±3 % bound on totals cannot distinguish a defect from an insertion order; every order-changing R2 step (sleep verdicts from solver data, this source, steps 6 and 7, CPU-level scoped correction) would fail it.

Consequence: the envelope for order-changing work must be statistical over an ensemble of order perturbations (the reversed and narrowphase orders are two samples: 56,077 / 60,409 / 69,243), or use order-insensitive gates (motion audit bounds, no collapse without cause, per-building damage distributions, the warm windows' physical traits), and a candidate is accepted when it lies inside that ensemble. Setting that bound is a decision for the owner; until then both env-gated paths stay off.

## Order-perturbation ensemble for the g16 bombardment (provisional acceptance rule)

Same set of partition edges, only the insertion order of the island's activated list changed (`PHYSX_DESTRUCTION_PARTITION_ROTATE_AUDIT=k` rotates by k, `_REVERSE_AUDIT=1` reverses), motion audit on, one trial each (all deterministic):

| variant | bonds broken (3 s) | peak clusters | motion audit error |
|---|---:|---:|---:|
| baseline order | 56,077 | 12,248 | 0 |
| rotate 7 | 58,680 | 13,280 | 2.2e-5 |
| rotate 101 | 60,797 | 14,337 | 1.7e-5 |
| rotate 1013 | 58,237 | 12,911 | 2.2e-5 |
| reverse | 69,243 | 16,080 | 0 |
| candidate: narrowphase partition source | 60,409 | 13,657 | 1.7e-5 |
| candidate: solver-derived sleep verdicts (mode 1) | 59,271 | 13,346 | 1.7e-5 |

Provisional rule for order-changing work (assumption until the owner confirms it): a candidate is accepted when its bond total and peak cluster count lie within the range of the mild order perturbations of the same baseline (rotations; here 58,237–60,797 bonds, 12,911–14,337 clusters), its motion audit error is at the ensemble's level, and it shows no collapse without cause. Under this rule both candidates are indistinguishable from an insertion-order change and pass. The baseline order is the lowest of all samples, which suggests the island's activation order happens to be a favourable one, not a physically special one. Both candidates remain off by default because neither improves the tick on its own; they are accepted foundations for steps 6 and 7.

## Impact tick, corrected pass: the registration stages measured by timestamps (re-prioritization of R2 steps 6/7)

From the recorded phase timestamps of the profiled impact tick (step 82, `perf-impact/native.phases.csv`, corrected pass), host wall per stage and their overlap on the worker threads:

| stage | wall (ms) | notes |
|---|---:|---|
| preallocateContactManagers | 24.5 | one thread, serial: contact-manager pool preallocation, shape-interaction and marker pool allocations, pair compaction, per batch of 256 pairs |
| postBroadPhase | 13.4 | GPU wait |
| registerSceneInteractions | 11.9 | runs in parallel with registerInteractions (10.2 ms of overlap) |
| registerInteractions | 10.2 | kept by every R2 step |
| islandInsertion | 6.6 | 3.9 ms of it overlaps the two registrations |
| postBroadPhaseStage2 | 6.6 | |
| registerContactManagers | 0.5 | |

Union span of the four registration stages 15.7 ms against a 29.2 ms sum. Consequence: steps 6 and 7 (skip island insertion, contact-manager registration and handle preallocation for native pairs) can remove at most about 7 ms of wall time on this tick, not the 25–40 ms the §7 attribution suggested when the stages were read as serial. The largest single CPU block, the 24.5 ms serial contact-manager preallocation, is independent of the island manager and of device-owned activation; it is the pool allocation of ~100 k contact managers, shape interactions and markers on one thread. That is the next impact-tick target and it needs no order-changing work: batch or per-thread pool allocation, or retaining the trial's records for the corrected pass. The trial pass of the same tick spends 0.8 ms here because the fragments do not exist yet.

## Pair pool pre-heat (env-gated, off): removes cold slab growth from the impact peak but changes the cascade

`PHYSX_DESTRUCTION_PREHEAT_PAIRS=N` allocates and releases N contact managers, shape interactions and N/4 markers at the first `simulate`, so the first impact's corrected pass finds warm free lists instead of growing slabs on one thread (the 24.5 ms serial `preallocateContactManagers`). It is order-changing by construction: warm free lists assign contact-manager indices in a different order than cold growth, the touch-event bitmap is walked in index order, and that order feeds island activation and partition insertion. g16 3 s bombardment, N = 150,000, motion audit on, two deterministic trials: impact tick 194.0 → 186.8 / 166.7 ms, but 63,923 bonds (+14 %, outside the mild-perturbation range of 58,237–60,797 and near the reversed order's 69,243), 14,044 peak clusters, and a run mean of 44 ms against 31.5 because the heavier cascade does more work. Initialization +0.1–0.2 s. Under the provisional rule this is rejected; more precisely, its effect on the peak cannot be separated from its effect on the trajectory. Kept off.

Conclusion of the calibration series: on this scene, any change to the order in which pairs are created, activated or inserted, including allocation-only changes, produces a different cascade with bond totals spread over 56 k to 69 k and tick means spread accordingly. Evaluating order-changing work needs an ensemble protocol (several perturbations per arm, compare distributions of bonds, clusters, misses and peaks), not single-run totals. Setting that protocol is the owner's decision recorded in README §11.

## Ensemble evaluation of the three env-gated candidates (`tools/scripts/run-destruction-order-ensemble.py`)

Four insertion orders per arm (baseline, rotated by 7, 101, 1013; the rotation also applies to the narrowphase candidate list), g16 3 s bombardment, motion audit on, all runs deterministic:

| arm | bonds (min–max, median) | peak clusters | tick mean ms (median) | peak tick ms | misses |
|---|---|---|---|---|---|
| control | 56,077–60,797 (58,458) | 12,248–14,337 | 31.0–35.8 (33.1) | 144–206 | 99/180 |
| step 4 narrowphase partition source | 57,552–60,409 (59,249) | 12,920–13,657 | 32.1–33.9 (32.9) | 148–198 | 99/180 |
| solver-derived device sleep verdicts (mode 1) | 58,106–60,232 (59,568) | 13,134–13,863 | 38.4–42.8 (40.9) | 175–202 | 99/180 |
| pair pool pre-heat | 63,472–64,683 (64,048) | 13,871–14,232 | 38.7–42.4 (42.1) | 180–204 | 99/180 |

Verdicts under the ensemble protocol:
- **Step 4 accepted.** Bonds, clusters, tick mean and peaks all lie inside the control's spread; the median tick is the same. It is physically and temporally indistinguishable from an insertion-order perturbation. It stays off only because it improves nothing by itself; it is a qualified building block for steps 6 and 7.
- **Mode 1 rejected on cost.** Physically inside the spread, but 8 ms per tick slower in every order: keeping fragments awake that the CPU would put to sleep at birth costs solver work. Modes 4 and 6 (exact reductions of CPU readiness) remain the sleep foundation.
- **Pre-heat rejected.** A systematic shift, not an order effect: every rotation breaks 63–65 k bonds against the control's 56–61 k, with heavier ticks. Warm pools change more than the index order (memory placement of interactions and managers reaches pointer-ordered containers); the cause is not established and the 24.5 ms serial preallocation remains an open target that needs an index-preserving pool path instead.

The protocol itself (four orders per arm, compare ranges and medians of bonds, clusters, tick mean, peak, misses; motion audit and no-collapse as hard gates) is adopted provisionally for all order-changing work; the owner can change the orders or the count.

## Stress solve occupancy: dense-tiny path confined to the Tiny instantiation (lossless, default on)

`componentStressSolve` uses 80 registers (3 CTAs per SM by registers with 256 threads) but was carrying 34,400 bytes of static shared memory: the direct-step staging vector (24,576), the dense-tiny path's matrix (7,056, `StressNativeDenseTiny.cuh`, a path that is off by default and was measured slower) and small reductions. With 102,400 bytes per SM that admits only 2 CTAs per SM, 800 bytes short of 3, which matches the earlier "72 active CTAs of 144" finding. The dense-tiny path is now compiled only into the Tiny instantiation, so the large instantiation's shared memory drops to 27,344 bytes and 3 CTAs fit (82 KB).

g16 3 s bombardment, interleaved against the control binary, three trials each, histories bit-identical (56,077 bonds, all counters):

| | control | 3 CTAs/SM |
|---|---:|---:|
| run mean (ms) | 31.70 (31.51–31.88) | 31.02 (30.72–31.40) |
| late window (ms) | 52.44 | 50.90 |
| peak tick | 183–199 | 183–202 |

Consistent 0.7 ms per tick, 1.5 ms on the late window, from the remnant solve's throughput. A fourth CTA per SM would need shared memory under 25,600 bytes (the staging vector alone is 24,576 for the 1,024-node resident cap) and 64 registers; not pursued.

## Stress solve staging in dynamic shared memory sized by the largest component (lossless, default on); 4 blocks/SM measured, not better

The large `componentStressSolve` instantiation now stages the direct step in dynamic shared memory sized at launch to 6 floats per node of the largest component (a one-time reduction at setup, `maxComponentNodes`, read back once outside stream capture; components only split after configuration, so the bound holds for every later solve; a component beyond it would be skipped like an oversized one, which cannot occur). Static shared memory drops from 27,344 to 2,768 bytes; on city256 the dynamic block is 10.7 KB (444-node buildings). Occupancy is now register-bound at 3 CTAs per SM (80 registers × 256 threads).

g16 3 s bombardment, interleaved against the control binary, three trials each, histories bit-identical: run mean 32.91 → 31.85 ms, late window 54.71 → 52.60 (this A/B includes the previous commit's occupancy change; the staging alone is neutral to slightly positive within the noise band and removes the shared-memory ceiling). Launch bounds of 4 blocks per SM (64 registers, stack 576 → 624 bytes) measured against the 3-block module: 30.15 → 30.42 ms, not better; 3 stays. `BLAST_GPU_NATIVE_DIRECT_CAPACITY` overrides the bound for experiments.

Device-stage profile after both occupancy commits (`--profile-phases 1`, g16, ticks 120–170): stress 9.54 → 7.88 ms per tick (two solves), commit and stress topology 1.47, topology and candidates 0.76, contact loads 0.74; profiled tick mean 31.4 ms, late window 51.4. The stress solve is still the largest GPU block on the tick's critical path; the remaining levers on it are a register diet toward 4 CTAs per SM without spills (R3's FP32 refinement is the candidate) and fewer barrier levels per remnant.

## Impact tick: page-touched slab reserve for the pair pools (bit-identical; env-gated, recommended)

`PHYSX_DESTRUCTION_PREFAULT_PAIRS=N` reserves raw slabs for N contact managers, N shape interactions and N/4 interaction markers at the first `simulate`, touching their pages, and the pools' growth paths (`Cm::PoolList::takeSlab`, `PxPoolBase::allocateSlab`) consume those slabs before calling the allocator. No element is constructed and no free list is touched, so allocation order is identical to cold growth; the earlier pre-heat's systematic shift is absent. g16 3 s bombardment, `--profile-phases 1`, three interleaved pairs, histories bit-identical:

| | no reserve | reserve 150 k |
|---|---|---|
| preallocateContactManagers at the impact tick, trial + corrected (ms) | 21.6 / 18.4 / 8.5 | 5.1 / 2.3 / 5.9 |
| impact tick (ms) | 223.6 / 202.0 / 203.7 | 203.2 / 207.1 / 197.2 |
| run mean (ms) | 31.25 | 31.36 |
| initialization (s) | 3.21 / 3.13 / 2.76 | 2.96 / 2.95 / 3.05 |

The serial preallocation was mostly first-touch page faults on ~80 MB of fresh slabs. Env-gated because N is a scene-scale choice (about 550 bytes per pair); a scene-description field is the right home for it.

## Warm nine-window screen of the occupancy defaults (contract v4, `results-occ-v4`)

Candidate = runtime and GPU module at `6cf194b1` (dense-tiny path confined to the Tiny instantiation, dynamic-shared direct staging), controls A0/A1 = the 2026-09-13 baseline artifacts. All nine windows pass; force relL2 and health drift identical to the previous screens (stress solves bit-identical). B means in ms, previous screen in brackets: city25-impact 16.47 [15.94], city256-cascade 66.13 [68.21], city256-debris 74.91 [79.24], city256-idle 1.79 [1.77], city256-impact 64.36 [68.85]; small windows within noise (bridge64 1.42, chain256 1.59, dense12 1.65, tower64 1.61). City256 impact max 169.6 [186.5].

## Reserved contact pairs as a scene setting (bit-identical; demo default 1.5 pairs per chunk)

`PxDestructionStressDesc::reservedContactPairs` carries the page-touched slab reserve through the runtime and the simulation controller to `Sc::Scene`, which serves it at the next step after configuration (the environment variable still overrides). The demo sets `--reserve-pairs N` or, by default, 1.5 pairs per chunk capped at 1 M (170 k for city256, about 94 MB). g16 3 s bombardment, profiled, three interleaved pairs against the control binary, histories bit-identical, 36/36 tests: preallocateContactManagers at the impact tick 13.9 / 15.1 / 12.0 → 7.7 / 5.0 / 5.3 ms; impact tick 187 / 236 / 231 → 164 / 203 / 222 ms; initialization 2.99 / 3.70 / 2.87 → 2.92 / 2.95 / 2.93 s; run means equal within noise under profiling.

## Stress solve: largest-first component dispatch (lossless, default on)

The persistent solve claims components from a device work cursor in live-list order, and the live list is ascending by component id, so the longest level chains (the largest remnants) could be claimed last and extend the solve's tail. The topology build now also produces a dispatch permutation: a stable descending radix sort by node count over all ids (dead ids key 0) whose first `islandCount` entries are the live ids largest first, ties by ascending id. Only the solve kernels read it (`componentsForSolve`); every other consumer keeps the ascending list, which the hierarchy's residency pools identify components by (a first attempt that reordered the live list itself tripped that check, stage error 64). `BLAST_GPU_NATIVE_LARGEST_FIRST=0` restores list order.

g16 3 s bombardment, same binary, interleaved off/on, three pairs, histories bit-identical: run mean 31.80 → 31.39 ms, late window 51.86 → 51.03 ms, each pair in the same direction.

## Sustained tick, CPU side (2026-09-17 diagnosis)

Phase timestamps of the profiled run: of a 43.8 ms profiled tick span only 13.1 ms is GPU wait; the rest is CPU-bound pipeline in many pieces of about a millisecond (island maintenance of both sims 1.7 + 1.7, island repair preparation 1.6 and component observation 1.2, activity restore 1.4 and checkpoint 0.8, body status work 1.3, sleep commit 1.1, submit 1.2, bindings 1.1, post-narrowphase 1.4 + 0.9, deactivation 0.8 + 0.7). A CUDA API trace (nsys) counts about 244 driver launches, 104 runtime launches and 10 graph launches per tick, issued from four worker threads nearly equally, so roughly 5 ms of CPU per tick is launch overhead in the driver; a perf profile of the sustained window puts 20 % of CPU samples in the driver and 27 % in the kernel (page accounting and mapping), with PhysX proper at 26 % and the GPU module at 17 %. All pinned host allocations happen before the first kernel, so initialization is not part of the tick. glibc malloc tuning against mmap churn was neutral (30.69 vs 30.61 ms). The scene-query pruner refit for moved shapes is about 3.5 % of the sustained CPU (a scene configuration choice for applications that do not query fragments).

## Launch overhead lead closed: tracer artifact (graph launches cost 23 µs in-process, not 4 ms)

An nsys CUDA API trace attributed 660 µs on average (4 ms for the stress topology transaction graph, up to 6 ms) to each `cudaGraphLaunch`, about 7 ms per tick, and 13–21 µs to each kernel launch across the four worker threads. A microbenchmark showed graph launches of 10–400 nodes, conditional or not, cost 2–5 µs; a one-worker trace showed plain launches halve in cost without threads competing (13 → 7.6 µs) while graph launches stayed at 660 µs; and an in-process timer around the topology graph submission (`BLAST_GPU_TOPOLOGY_LAUNCH_DIAG=1`) measured 23 µs average, 185 µs maximum. The graph-launch figures were the tracer's own instrumentation cost. Conclusion: CUDA launch overhead is not a material part of the sustained tick, and API durations under nsys must not be used to size launch costs on this stack. The sustained tick remains a serial chain of PhysX's rigid pipeline run twice, the destruction host phases, and the GPU waits; thread count 2–4 makes no difference (six is slightly worse).

## Direct-factor rebuilds: where they come from and what a larger Woodbury cap costs (2026-09-17)

The kernel summary of a traced bombardment run puts `factorNativeDirect` at 44.7 % of all GPU kernel time (744 ms over 324 launches, 2.4–2.8 ms each, about 1.3 launches per tick), with the solve waiting on it. New diagnostic counters (`BLAST_GPU_NATIVE_DIRECT_DIAG=1`: refactor size buckets, reasons, inheritance and Woodbury-failure counts) attribute the 1,359 full refactors of the run: 1,116 are components with more than 256 present nodes (building remnants, ~350 nodes on average), 256 of them the first factors at the impact, 860 on slots that had a valid factor and were invalidated. Not a single one is a lost identity (slot inheritance to the largest child at a split, added as `BLAST_GPU_NATIVE_SLOT_INHERIT`, moved 31 of 63,053 slots and changed nothing; off by default) and Woodbury never failed. The invalidations come from `trackNativeDirectRemovedBonds`: a slot is invalidated once its cumulative removed bonds pass `kWoodburyMaxBonds` (16), and a remnant under bombardment loses about six bonds per tick, so every large remnant refactors every few ticks.

Raising the cap to 32 (pool budget 1 GB, 407 buffers) cut the large refactors to 862 (invalidated 606) but made the tick slower, 30.6 → 32.5 ms interleaved, histories bit-identical: the correction is applied at every solve as a dense rows × 6k mat-vec per stale remnant (W is rows × 96 floats at k = 16, 0.9 MB per remnant, twice per tick for ~250 remnants), so the cap doubles that bandwidth and costs more than the refactors it saves. The cap stays at 16. The remaining lever on this item is the refactor's own latency (a ~380-node level chain on one CTA; ordering, cooperative rows and CTA clusters were all measured slower) or a cheaper correction representation (e.g. half-precision W, order-changing).

## Eager refactor exposure measured on the device: already hidden (join diagnostic)

`BLAST_GPU_NATIVE_FACTOR_JOIN_DIAG=1` records timed events on the solver stream immediately before and after each wait on the factor stream's completion event, so the elapsed time is the solver stream's idle time caused by a refactor still running when the solve needed it. City256 bombardment, 3 s: 300 pending joins in 631 joins, exposed wait 0.48 ms per pending join on average (maximum 7.9 ms at the impact burst), 139 ms over the run, about 0.8 ms per sustained tick; the host issued the eager launch 12 ms before the join on average, five times the launch's 2.4 ms duration. The refactor's 45 % share of GPU kernel time is therefore not on the tick's critical path, and neither its latency nor a cheaper Woodbury representation is a tick lever; this closes the direct-factor item.

Two other leads were closed by measurement at the same time: pinned host allocation (`cuMemHostAlloc` via PhysX's pinned linear allocator, 18 % of all CPU samples of a whole-process perf profile) occurs only during setup (0.25–2 s) and teardown, with 0–2 samples per quarter second during the sustained window, so it is not a tick cost; and the 32-thread tiny-component launch (`BLAST_GPU_NATIVE_TINY_CTAS=16/32`) trades −0.3/−0.4 ms on the trial solve for +0.5 ms on the corrected solve (its extra serialized launch), net neutral, and stays off.

## Stress solve: 128-thread CTAs (lossless, −1.2 ms/tick, default on)

Node-level graph tracing (`nsys --cuda-graph-trace=node`) put the trial solve kernel at 5.7 ms and the corrected solve at 1.5 ms per sustained tick, the largest single item on the critical path after the two rigid passes. The component chain is barrier-latency bound (74 levels, 68 narrower than the eight warps of a 256-thread CTA) while the launch is throughput bound (total cycles ÷ resident CTAs, 3 per SM at 80 registers), so most resident warps idle at barriers. Launching the large instantiation with 128 threads keeps the per-level latency (narrow levels use one warp) and doubles the resident components (6 CTAs per SM by registers, 84 KB shared). `BLAST_GPU_NATIVE_SOLVE_THREADS` (default 128; the persistent grid scales by 256/threads). The narrow-level pipeline indexed its per-warp scratch by the pattern's eight-warp top level; it now raises the top level to the launch's warp count (compute-sanitizer memcheck clean at 128 threads on a grid-4 run).

| threads | trial solve span | corrected span | tick mean (3 runs) | late 90+ | peak |
|---|---:|---:|---:|---:|---:|
| 256 (before) | 5.93 ms | 2.09 | 29.76 [29.35, 29.79, 30.14] | 49.3 | 183 |
| 128 | 4.46 | 2.01 | 28.54 [28.58, 28.84, 28.19] | 46.9 | 171 |
| 64 | 4.16 | 2.32 | 28.59 [28.97, 28.87, 27.92] | 47.0 | 177 |
| 32 | 4.92 | 3.07 | 29.97 (1 run) | 49.2 | — |

Histories identical for every thread count (five counters, 56,077 bonds). 64 threads is shared-memory bound at 7 CTAs per SM (13.4 KB each: 2.8 KB static plus the 6-float-per-node staging vector of the largest component) and its corrected solve, with few components, pays the halved warps per component; 128 is the default. 14/14 native tests. The next residency lever is the staging vector: moving it out of shared memory would let 64-thread CTAs reach 12 per SM (registers) and 96-thread CTAs 8.

## Warm nine-window screen of the 128-thread solve default (contract v4, `results-thr128-v4`)

All nine windows pass (candidate B against paired controls A0/A1 of the 09-14 runtime): city256 cascade 66.2 ms (controls 112.0/112.0), impact 67.7 (92.5/94.6), debris 74.6 (128.4/132.1), city25 impact 17.5 (22.9/23.8), idle 3.8 (2.7/1.7; the idle window's spread between the two controls is of the same size). Force and health signatures are within the contract (debris relL2 1.9e-2 from the elastic reuse, unchanged). The windows are 16 ticks each, so the sustained −1.2 ms is inside their spread; the 3 s bombardment (three interleaved runs) is the measurement of record.

## Stress solve: staging vector in a per-CTA global scratch (lossless, −0.9 ms/tick, default on)

With 128-thread CTAs the launch is register-bound at 6 CTAs per SM, but the 64-thread launch was shared-memory bound at 7 (13.4 KB per CTA, of which 10.6 KB is the 6-float-per-node staging vector of the largest component). `BLAST_GPU_NATIVE_SOLVE_STAGING=1` (default) moves that vector to a per-CTA global scratch allocated once at setup for the widest persistent grid (grid × 6 × capacity floats, 12 MB at city256), so the solve launches with only its 2.8 KB static shared memory. The chain's reads of just-written x entries become L1/L2 accesses (block-level coherence across `__syncthreads`), which cost nothing measurable: the trial solve span is 4.24 ms against 4.46 with shared staging at 128 threads, 3.95 at 96 threads.

| arm (5 interleaved runs, desktop active) | tick mean | sd | late 90+ | peak |
|---|---:|---:|---:|---:|
| shared staging, 128 threads | 29.37 | 0.53 | 48.3 | 184 |
| global staging, 128 threads | 28.49 | 0.32 | 46.9 | 173 |

Global staging wins in all five pairs; 96 threads (28.59, two runs) and 64 threads (28.91, now 12 CTAs per SM but a slower corrected solve) do not beat 128. Histories identical (56,077 bonds, five counters), 14/14 native tests, compute-sanitizer memcheck clean on a grid-4 run. A first measurement of this change taken minutes after the warm screen restored the desktop session showed every CPU phase 15–20 % slower and was discarded: measurements must not start while a fresh desktop login is settling.

## Scene-query maintenance of chunk shapes: 2.4 ms of the sustained tick (application configuration; demo default unchanged)

The steady-state perf profile puts about 4 % of CPU samples in the scene-query pruner (`BVHPartialRefitData::refitMarkedNodes`, `PruningPool::updateAndInflateBounds`, `markNodeForRefit`, `AABBTreeBuildNode::subdivide`). The demo issues no scene queries, but every chunk shape carries `eSCENE_QUERY_SHAPE` (PhysX's default), so `fetchResults` syncs the bounds of every moved fragment into the dynamic pruner, refits the tree and rebuilds it periodically. Two new demo knobs measure it (two interleaved runs each, city256 bombardment, histories identical):

| configuration | tick mean | late 90+ | peak |
|---|---:|---:|---:|
| default (`eBUILD_ENABLED_COMMIT_ENABLED`, all chunks queryable) | 29.56 | 48.7 | 185 |
| `PHYSX_DEMO_SQ_UPDATE_MODE=1` (build only; refit deferred to the first query) | 27.91 | 46.1 | 169 |
| `PHYSX_DEMO_SQ_UPDATE_MODE=2` (no scene-query work) | 27.96 | 46.1 | 166 |
| `--scene-query-shapes 0` (chunks not queryable) | 27.14 | 44.6 | 167 |

So the pruner commit costs about 1.6 ms per tick and the mandatory bounds sync of ~10k moving fragments a further 0.8 ms. This is PhysX's scene-query system, not the destruction pipeline, and whether a game needs fragments queryable is the application's choice (bullets and line-of-sight against debris versus intact buildings). The demo default stays at PhysX's default so every earlier measurement remains comparable; an application targeting the plan's budget should use build-only mode (queries stay correct, the refit moves to the first query of the frame) or exclude debris from queries.

## Continuous 600-tick A/B/A of the 2026-09-17 defaults (`out/direct-continuous-ab-20260917`)

Candidate = commit `0e0fb2a3` binaries (R2 steps 1–3, solve occupancy 3/SM with dynamic staging, largest-first dispatch, reserved contact pairs, 128-thread solve CTAs, global staging); baseline = the session's fixed A arm. Two trials per arm, baseline measured before and after.

| case | baseline mean | candidate mean | 60 Hz misses (of 600) | peak | counters |
|---|---:|---:|---:|---:|---|
| impacts-256 (heavy) | 53.2–54.6 ms | 25.6–25.8 | 519 → 270/283 | 187–196 → 160–162 | identical (28,596 bonds) |
| idle-256 | 1.31 steady (first tick 13.5) | 1.68 steady (first tick 38.2) | 0 → 1 | 13 → 39 | identical |

Heavy: 54.4 → 25.7 ms against 28.4 at the previous continuous A/B (0fb405e1). Idle: the single miss is the first tick, which now pays the page-touched pair-pool reserve (about 40–60 ms once, 9 ms with `--reserve-pairs 0`) instead of the impact tick; the +0.37 ms steady idle difference could not be attributed to any one default (toggling 256-thread shared staging, the pair reserve, largest-first and 2 CTAs/SM individually gave 1.36–1.69 ms, the same spread as repeated default runs with the desktop active), so it stays recorded as an unexplained drift within the idle noise band.

## CPU dispatcher wake-up latency: 4.6 ms of the sustained tick (demo default changed to yield-thread workers)

The sustained tick is a chain of a few hundred small PhysX and destruction tasks across four workers, and the demo created its `PxDefaultCpuDispatcher` in PhysX's default `eWAIT_FOR_WORK` mode, where every task hand-off to an idle worker is a semaphore wake-up (a futex round trip on this VM). `PHYSX_DEMO_DISPATCHER_MODE` selects the mode (0 wait, 1 yield thread, 2 yield processor with `PHYSX_DEMO_DISPATCHER_SPIN`); two interleaved city256 bombardment runs each, histories identical (five counters):

| dispatcher | workers | tick mean | late 90+ | peak |
|---|---:|---:|---:|---:|
| wait for work (old default) | 4 | 27.30 | 45.1 | 165 |
| yield processor (spin 1000) | 4 | 22.67 | 37.6 | 128 |
| yield thread | 4 | 22.67 | 37.8 | 125 |
| yield thread | 3 | 23.03 | 38.4 | 126 |
| yield thread | 6 | 23.72 | 39.6 | 129 |
| yield thread | 8 | 24.24 | 40.5 | 136 |
| yield thread + `PHYSX_DEMO_SQ_UPDATE_MODE=1` | 4 | 22.21 | 37.2 | 125 |

The demo default is now yield-thread with four workers (the earlier "2–4 workers equal, 6 worse" finding was measured under wake-up latency; it still holds under spinning). This is application configuration, like a game's job system, not a runtime change: the runtime A/B arms remain comparable because each arm carries its own demo binary, and the report states which dispatcher a number was taken with. From here every measurement uses the new default unless stated.

## Continuous 600-tick A/B/A with the yield-thread demo (`out/direct-continuous-ab-20260917b`)

Same runtime as the previous campaign, candidate demo with yield-thread workers; baseline arm unchanged (wait-for-work demo, 09-15 runtime). Two trials per arm, baseline before and after.

| case | baseline mean | candidate mean | 60 Hz misses (of 600) | peak | counters |
|---|---:|---:|---:|---:|---|
| impacts-256 (heavy) | 54.2–54.8 ms | 20.5–20.6 | 519 → 248 | 184–217 → 127–132 | identical (28,596 bonds) |
| idle-256 | 1.63–1.82 | 1.12–1.13 | 0 → 1 (first tick, pair reserve) | 14–15 → 36 | identical |

The idle difference of the previous campaign (1.31 → 1.68) reverses under spinning workers (1.8 → 1.13): the idle tick, too, was dominated by task wake-up latency. Against the plan's starting point (continuous heavy 50.5–51.7 ms, 519 misses) the sustained tick is now 2.5× faster with identical physics; the ≤8 ms target remains 2.5× away, in the two CPU-bound rigid passes.

## Motion-mode build: compacted changed-arc list (lossless, −0.28 ms/tick, default on)

The cooperative motion-mode construction (rigid modes of free components, rebuilt for the components changed by a topology transaction) filtered its Euler-tour pointer-jumping rounds by a per-node changed mask but still swept all 458k arcs of the scene for 19 rounds, each with a grid sync. The cut-counting sweep now also compacts the changed forest arcs into a device list (`BLAST_GPU_NATIVE_MOTION_ARCS`, default 1), the jump rounds and the tour check visit only that list, and the round count is bounded by its length (further rounds only copy finished values). Device `commitAndStressTopology` span 0.80 → 0.66 ms per pass (two passes per tick); tick 23.83 → 23.67 ms (two runs each, within noise); histories identical; 14/14 tests; compute-sanitizer memcheck clean.

## Sleep finalization: one fused zeroing launch instead of four generic setters (lossless, −0.3 ms/tick, default on)

Native sleep finalization (`finalizeSleepingRigidBodies`) zeroed a sleeping body's linear velocity, angular velocity, force and torque through four `setRigidDynamicData` calls, each taking the CUDA context lock and launching its own kernel; the kernel trace showed them 120–170 µs apart on the critical path between integration and the stress-solve submit, twice per tick. `zeroNativeSleepMotion` makes the same writes (velocities, previous velocities, external accelerations) in one launch (`PHYSX_DESTRUCTION_SLEEP_FUSED`, default 1). City256 bombardment, two runs each: 23.13 → 22.81 ms mean (late window 38.6 → 38.0), histories identical, 14/14 tests. The remaining chain between the rigid solver's end and the stress solve (about 2.5 ms per pass: body DMA wait, island maintenance of both sims, sleep commit) is R2 item 1 territory: device-owned sleep decisions would let the stress solve start right after integration while the CPU island work runs alongside.

## Warm nine-window screen of the 2026-09-17d defaults (contract v4, `results-17d-v4`)

Candidate = commit `4d75227f` runtime and GPU module (128-thread solve CTAs, global staging, motion-arc compaction, fused sleep zeroing) against the paired 09-14 controls. All nine windows pass; force and health signatures are identical to every screen since `results-16d-v4` (same relL2 and drift values), consistent with the identical histories measured on the g16 runs.

| window | controls A0/A1 | candidate B |
|---|---:|---:|
| city256 cascade | 113.8 / 107.7 ms | 63.9 |
| city256 impact | 95.6 / 91.7 | 65.9 |
| city256 debris | 131.2 / 129.9 | 73.4 |
| city25 impact | 23.8 / 23.3 | 15.9 |
| city256 idle | 5.4 / 1.5 | 1.8 |
| bridge64 / chain256 / dense12 / tower64 | 1.4–1.7 | 1.4–1.6 |

## Early trial stress submission (README §14 increment): built, exact, neutral; env-gated off

`PHYSX_DESTRUCTION_EARLY_SUBMIT=1` arms the controller at the end of the third island pass with the scene's sleep commit (pending bodies plus the accurate island sim's deactivation set, the same set `afterIntegration` commits later) and has the GPU solver task report its launch issue; whichever arrives second joins the simulation-core stream to the solver stream, runs the commit, builds the contact graph and submits loads and the stress solve, so the solve is enqueued behind integration on the device without the CPU post-solve chain. Two things had to be learned on the way: the solver's contact/patch streams flip in `postSolver`, so a submission before it reads the current index (the first attempt read the other stream and faulted in the load routing); and with a `streamWaitEvent` on the solver's launches the runtime needs no host wait.

Result: histories identical (five counters), 14/14 tests, compute-sanitizer clean; tick 23.92 → 23.78 ms over three interleaved runs (noise). The phase timeline explains it: the "2.2 ms CPU post-solve chain" between island maintenance and the sleep commit was almost entirely the body DMA wait for the GPU solver, so the trial pass is GPU-serial (rigid solver → loads → topology → stress solve) and an earlier host submission cannot shorten it; the early trigger also sits behind the island maintenance (~2 ms after the solver launch issue), and the exact commit's rollback gather joins the solver stream on the host. The code stays as an option (off). The remaining lever on the trial pass is therefore the device chain itself, and on the corrected pass the R5 scoping.
