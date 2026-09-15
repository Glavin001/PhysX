# Real-time city-scale destruction: ranked optimization analysis

Published 2026-09-15. Offline analysis of the saved measurements (warm full52
2026-09-14, boundary audit, convergence-policy diagnostic, work census, cuDSS and
prepared-factor probes), the source at `13b11af2`, the previous-generation
approach in `vibe-land-4` / `blast-stress-solver-2`, and published literature.
No new runtime, build or GPU measurement; the feasibility gates below are the
first executable follow-up. Branch: `claude/realtime-destruction-20260915`.

**Conclusion.** The remaining 7–11× is not reachable by tuning the existing
PCG kernel or the CPU bookkeeping around it: thirty-plus isolated experiments
since 2026-09-10 sum to about 5%. Two structural changes address the two
regimes that dominate every failing tick, and both are backed by saved
evidence: (1) a **cached direct factorization per anchored component** with
factor lifetime across ticks replaces up to 600 PCG iterations per component
per pass with two triangular solves; (2) a **GPU-authoritative fragment
lifecycle** removes the 50–90 ms of GPU-idle CPU registration at first impact.
A third, cheaper change, **FP32-first numerics**, matters on every target GPU
because consumer Ada/Blackwell run FP64 at 1/64 of FP32.

## 1. Goal, constraints and the measured gap

Target: 60 Hz with headroom (≤8 ms mean, ≤16.67 ms peaks) for 100k+ chunks and
200k+ bonds under sustained bombardment. Hard constraints (user, 2026-09-15):
current-tick contacts → stress → at most one same-tick rewind/correction →
second stress → publication; all fracture verdicts land in the tick that
produced them; ordinary APIs; sleeping enabled and working; no reliance on
freezing or active-body reduction yet. Accepted compromises: tolerance 1e-3 or
looser and bounded iterations with cross-tick continuation, provided a player
would not notice, and provided an impact still breaks a wall in the tick the
projectile hits it.

| City256 (113,664 chunks / 229,376 bonds), warm windows 2026-09-14 | mean ms | peak ms | 60 Hz misses |
|---|---:|---:|---:|
| intact idle | 1.66–1.69 | 3.9 | 0/64 |
| initial impact (256 projectiles) | 88.8–90.1 | 187.8 | 32/32 |
| cascade / fragmented loaded | 77.3–82.2 | 103.1 | 32/32 |
| late debris (17.4k clusters, 300k contacts) | 124.5 | 129.2 | 32/32 |
| continuous heavy, 600 ticks | 50.5–51.7 | 176–195 | 519/600 |

Sources: [warm full52](../destruction-warm-full52-20260914/README.md),
[warm bottlenecks](../destruction-warm-bottlenecks-20260914/README.md),
[boundary audit](../destruction-cpu-gpu-boundaries-20260914/README.md).

## 2. Diagnosis by regime

**Sustained destruction is a stress-solve problem.** Two `componentStressSolve`
passes take 70.4 of the 124.5 ms late-debris tick. The per-component work
census (`out/removal-work-census-20260912`, impacts-256, solves ≥250) shows:

| component class | count per solve | share of iteration×node work | max iterations |
|---|---:|---:|---:|
| anchored, 257–512 nodes | ~251 | **97.9%** | 600 |
| anchored, 129–256 nodes | ~3 | 1.4% | 592 |
| free, ≤16 nodes | ~2,000 (33k rows / 17 solves) | 0.3% | 56 |

Only 193 bonds break per late-debris tick, so each remnant's operator is
unchanged for many ticks. The node-space operator `L = D C S² Cᵀ D`
(`StressNodeOperator.cuh:169-181`) depends on chunk inertia, rest offsets,
compliance and topology; damage does not rescale rows, it only removes bonds.
The kernel is latency/dependency bound, not bandwidth bound: issue activity
10.7%, 109 registers → two 256-thread blocks per SM, 0.09 eligible warps per
scheduler, DRAM 2 GB/s. Its FP64 hierarchy/preconditioner work runs on a GPU
whose FP64 rate is 1/64 of FP32 (RTX 5060 Ti: 0.37 vs 23.7 TFLOPS; the earlier
city capture showed the FP64 pipe 54–61% busy).

**First impact is a CPU ownership problem.** In the profiled City256 impact
tick, shape migration (52.0 ms), native body allocation (15.6 ms),
contact-manager preparation (10.5 ms) and interaction registration (~19 ms)
execute with no recorded GPU activity, and corrected broadphase adds 11.8 ms.
The GPU already holds every fragment's mass, motion and shape ownership
before the CPU `BodySim`/`ShapeSim` records are rebuilt; corrected physics
waits for the CPU (`ScPipeline.cpp:3057-3136`,
`NpDestructionBodyAllocator.h:278-352`). Exposure scales with fragments:
7.7 ms at City25, 18.3 ms at City64, 52.0 ms at City256.

**Idle is solved.** Exact settled certificates keep intact cities at ~1.5 ms.

Secondary, deterministic costs: island repair 10–12 ms CPU per active tick
(`observeContactComponents` download plus host processing), `constructMotionModes`
4.8 ms, cluster-mass accumulation 2.1 ms, `onResetFiltering` over every shape
after each correction whenever `preserveUnchangedContactPairs` is false (the API
default; the continuous A/B profile enables it, snapshot captures inherit the
capturing run's setting), and 700–900 kernel launches per active tick.

**Lessons from the previous approach** (`vibe-land-4`, `blast-stress-solver-2`):
the live game ran an unconverged 32-iteration FP32 CGLS and calibrated materials
against truncation; its wall was CPU contact processing (92.7 ms at 492k contact
records) and whole-scene rollback, with GPU utilization ~10%. Its own roadmap
named "static condensation of intact interiors with shared operators/factorisations
for repeated asset instances" as the most promising unbuilt idea. The native
integration removed the contact round trip; it did not yet remove CPU fragment
registration, and it solves a much stricter numerical contract (1e-5, converged).

## 3. Ranked opportunities

Ranking = expected application milliseconds × confidence ÷ cost, with the
fidelity impact stated for each. Gains are hypotheses to be gated; they overlap
and are not additive.

### R1. Cached direct factorization per anchored component, with factor lifetime across ticks

*Mechanism.* Factor each anchored component's operator once (sparse Cholesky,
nested-dissection ordering, FP32 storage), keep the factor until the component's
topology changes, and solve each pass with two triangular solves plus one or two
FP64 residual-refinement steps to reach the existing 1e-5 gate. Bond removals are
rank ≤6 updates: absorb them with a Woodbury/capacitance correction against the
cached factor (Nukala et al., fuse-network fracture: per-break cost O(nnz(L)));
absorb detached node sets with the sub-mesh factor identity (Herholz & Alexa 2018,
"Factor Once"); refactor when accumulated update rank exceeds ~100–200 bonds or
the component splits substantially (Hecht et al. 2012 show incremental sparse
Cholesky beating PCG under limited element changes). Instanced assets share one
offline factor: the census records `unique_anchored_operators = 1` for all 256
intact/impacted buildings, so the first-impact solve of the whole city is one
multi-RHS triangular solve. Refactors run as one CTA per component (1.5k–3k DOF),
batched.

*Evidence.* Census above; tower64 spends 115 ms in a single 2,304-node anchored
PCG (137 iterations) that a cached factor solves in microseconds; the cuDSS
probe measured reused batch solves at 5.54 ms versus 48 ms when every factor was
rebuilt each tick in FP64 through a general solver with a 49 ms analysis phase
([removal implementation](../destruction-removal-implementation-20260913/README.md)).
That failure was in the lifetime policy and the library, not the idea.

*Expected.* Stress 70 → 3–8 ms in sustained debris; tower 108 → <5 ms; impact
stress 40 ms → a batched refactor burst of impacted buildings (~5–10 ms) then
cheap solves; deterministic cost independent of conditioning; the 8192-iteration
failure mode disappears.

*What we lose / risks.* Memory ~1–2 MB of FP32 factor per building-size
component (0.3–0.5 GB per city; budget it). Engineering: batched per-CTA
supernodal Cholesky, Woodbury bookkeeping, free-component nullspace handling,
refactor scheduling. Refactor bursts when thousands of bonds break in one tick
across many components. Ill-conditioned remnants may need extra refinement steps
or a per-component FP64 fallback; the existing FP64 true-residual gate remains
the acceptance test, so fidelity is unchanged.

*Feasibility gate (offline, no runtime change).* On the 256 captured late-debris
remnants (`out/prepared-remnant-20260913/batch-inputs`) and the intact/fractured
parent (`inputs-v3`): (a) nnz(L) and bytes per component under a fill-reducing
ordering; (b) FP32 factor + FP64 refinement error against FP64 direct solves and
the 80-digit reference, at the solver's 1e-5 gate; (c) Woodbury accuracy and cost
for 1..200 removed bonds and detached blocks; (d) CUDA micro-benchmark of batched
per-CTA triangular solves for 250 components (target <2 ms per pass on the
5060 Ti); (e) per-tick broken-bond distribution for the refactor rate.
Go/no-go: (b) passes at ≤3 refinement steps for ≥95% of systems and (d) ≤3 ms.
**Result (2026-09-15): all five gates pass**, see [feasibility.md](feasibility.md): 255 remnants solve in 2.40 ms per GPU pass, every system reaches 1e-5 within one FP64 refinement, Woodbury reuse holds to 200 removed bonds, 128 of 255 operators are unchanged between the two passes of a tick, and sustained ticks break <1 bond on average.

### R2. GPU-authoritative fragment lifecycle and GPU-owned contact islands with sleeping

*Mechanism.* The 2026-09-15 [ownership hypothesis](../destruction-gpu-ownership-hypothesis-20260915/README.md):
one private ownership transaction (body/shape IDs, generations, mass/motion,
changed ownership) consumed directly by collision and solver registration so
corrected physics no longer waits for CPU `BodySim` construction and per-shape
`rebindRigidOwner`; then authoritative device representations for island
membership, activity and sleep/wake so the `mPreSolveSleepingDisabled` guard in
`PxgContext.h` can be lifted without bypassing host responsibilities. Cheaper
intermediate steps that still count: pre-created fragment record pools,
O(changed) refiltering instead of `onResetFiltering` over every shape
(`ScPipeline.cpp:3115-3124`), and qualifying `preserveUnchangedContactPairs=true`.

*Evidence.* 15.6 + 52.0 ms of GPU-idle CPU time at City256 impact; island
repair 10–12 ms on every active tick; prototype E1 proved that deduplicating
visits (20× fewer) is not enough, so the per-shape re-registration itself must go.

*Expected.* Impact peak 188 → ~110 ms alone, ~40 ms combined with R1; sustained
ticks −10 ms. Relative importance grows on a 5090 (4.7× the SMs shrink GPU time,
not CPU time). *What we lose.* Nothing physical; highest engineering cost (PhysX
island manager, contact-manager pools, sleep lifecycle).

### R3. FP32-first numerics on 1/64-FP64 hardware

*Mechanism.* Move every per-iteration FP64 path (hierarchy coarse coefficients,
terminal Cholesky, mixed-inverse fallback rows, FP64 normalization reductions) to
FP32 with compensated accumulation in reductions only; keep FP64 for one
true-residual gate per component and a per-component FP64 fallback when it fails.
Applies to R1's refinement loop or, until R1 lands, to the current PCG.

*Evidence.* FP64 pipe 54–61% busy in the city capture; 109 registers; Vibe's
multilevel research measured 1.8× at identical iteration counts from
float-inside-preconditioner. Prior FP32 attempts failed a symmetry check
(implementation defect) or kept FP64 fallback rows (N13); none tested FP32-first
with a single FP64 acceptance gate. *Expected.* 1.5–3× on the stress kernel plus
occupancy from fewer registers. *What we lose.* Nothing at the acceptance gate;
failing components pay a fallback solve.

### R4. Verdict-aware stopping and bounded iteration with continuation (accepted compromise)

*Mechanism.* Stop a component's iteration when the residual bound cannot flip
any bond's damage verdict: 1e-3 (or the component's margin to its nearest limit)
unless a bond's stress lies within a band of an elastic/fatal limit, in which
case tighten for that component only. Add a per-tick iteration budget with
warm-started continuation for slowly changing loads, but require components with
a new event (fresh contact impulse above a threshold, i.e. an impact) to iterate
to the verdict-safe tolerance in that tick so the rewind verdict is faithful.

*Evidence.* [Convergence policy](../destruction-convergence-policy-20260913/README.md):
1e-3 alone 55.1 → 45.4 ms heavy mean with identical broken-bond identities in the
impact tick (health drift ≤8.8e-5; +4.7% bonds over the run); a blind 32-cap gave
23 ms but 41% fewer breaks and 52% force error at impact, exactly the case the
event rule excludes. *Expected.* −15–20% on sustained ticks now; largely moot for
anchored components after R1. *What we lose.* Health accumulates ~1e-3 relative
error; fracture timing can drift by a few bonds among tens of thousands. Needs
its own acceptance envelope (bond identity on event ticks, bounded health drift,
trajectory/energy checks). Low cost; do early.

### R5. Island-scoped correction

Re-simulate only PhysX islands that contain a fractured body plus islands newly
connected (or disconnected) by corrected motion; untouched islands keep their
trial result exactly. Evidence: corrected broadphase 11.8 ms + contact-manager
preparation 10.5 ms at impact; 300k contacts across 17k clusters mostly untouched
by 193 breaks. Vibe's attempt diverged 12.8 m by missing contact-loss coupling,
so affected-set closure must include contact gain and loss. Expected −10–25 ms on
impact ticks, −5–10 ms sustained, scene dependent. Do after R2 puts island
ownership on the GPU.

### R6. Cheap deterministic wins

Analytic rigid modes instead of `constructMotionModes` (4.8 → <0.2 ms);
incremental cluster mass/inertia (2.1 ms); a lossless tiny-component pre-filter
(some incident bond of any node carries ≥ |load|/degree, so if that lower bound
is below every elastic limit for a whole component its solve can be skipped
exactly); launch consolidation and Programmatic Dependent Launch (CUDA 13.4);
stream priority for stress versus the rigid solve; warp-per-component dispatch
for ≤32-node components. Grid/block sweeps alone are known not to help.

### Deferred or rejected

Freezing/merging settled debris and other active-body reduction: later, per user.
Applying second-pass verdicts next tick: rejected (not physically identical).
Do not repeat: shared inverse caches, three-block register budgets, local
multilevel V-cycles, cuDSS rebuild-every-tick, masked cuDSS refactorization
([findings](../../docs/destruction/PERFORMANCE_FINDINGS.md)).

## 4. Execution order

1. **Phase 0 (≈1 week):** qualify `--preserve-contact-pairs 1`; implement R4
   with its acceptance envelope; R6 motion modes and incremental mass; one NCU
   capture confirming the FP64-pipe share on the warm-debris kernel.
2. **Phase 1 (≈2–3 weeks, offline):** R1 gates (a)–(e) and the R3 FP32 replay;
   R2 consumer inventory in parallel.
3. **Phase 2 (≈6–10 weeks):** R1 in `blast/source/sdk/extensions/stressgpu/`,
   wired through `solveDeviceAsync` (`PxgDestructionRuntime.cu:1444`) with the
   current PCG as per-component fallback.
4. **Phase 3 (≈8–12 weeks, parallel):** R2 per its existing checklist and 10 ms
   contract, then R5.
5. **Phase 4:** full52 warm, uninterrupted 600-tick trajectories, and a
   4090/5090-class re-run to confirm the CPU/GPU balance.

Verification for every runtime change: nine-window warm screen with matched
controls ([fast measurement reference](../../.agents/skills/physx-destruction-performance/references/fast-warm-measurement.md)),
means, peaks, 60 Hz misses and stages; physical gates unchanged unless the change
is a declared compromise with its own envelope; finalists also pass full52,
uninterrupted trajectories, the 600-tick ordinary/sleeping wall, snapshot round
trips and sanitizers.

## 5. Implementation status (2026-09-15, same day)

R1 is implemented on this branch (commits `2a97d7a6`, `0c5c997c`) in
`blast/source/sdk/extensions/stressgpu/detail/StressNativeDirect*.{cuh,inl}` and
wired into the resident solve graph. It keeps the physical contract untouched:
the direct step only proposes a solution that the unchanged residual monitor and
verification accept or hand to PCG. Native demo A/B against the frozen selected
runtime, 3 s, ordinary APIs, sleeping on, one correction, physical histories
(bonds broken per tick, post-correction breaks, clusters, contacts, corrections)
identical on every tick:

| scenario (180 ticks) | baseline mean ms | R1 mean ms | max stress iterations |
|---|---:|---:|---:|
| city25 bombardment | 12.69 | 9.83 | 640 → 64 |
| city256 bombardment, all ticks | 55.05 | 37.16 | 788 → 420 (one tick) |
| city256 cascade window (ticks 100–139) | 93.9 | 63.0 | |
| city256 late window (ticks 140–179) | 103.1 | 70.0 | |

Kernel profile of the candidate (Nsight Systems, 267 solves): `componentStressSolve`
5.4 ms per solve (was ≈35 ms per pass at this scale), `factorNativeDirect` 2.95 ms
per solve with a 27 ms burst on the impact tick when every building refactors.
The impact peak is unchanged because it is CPU registration (R2). Remaining
solver work: supernodal treatment of the dense top of each elimination tree
(refactor latency), Woodbury updates for few-bond removals, and warp-level
handling of the thousands of tiny free components that still serialize per CTA.
**Status of the other items.** R3 is largely subsumed: the direct path runs in
FP32 with one FP64 residual product per refinement, and the FP64 preconditioner
work now only runs for components left on PCG. R4 (verdict-aware stopping) lost
most of its value once anchored and free components converge before iterating
(mean max iterations 316 → 31 in the 256-building run); it remains useful only
for the PCG fallback and is deprioritized. R6's motion-mode/mass work per topology
change (~2.7 ms per sustained tick in the candidate profile) and R2 (the impact
peak and ~15 ms per sustained tick of GPU-idle CPU time) are the next targets.
Routing components smaller than eight nodes through the direct path was measured
worse (39.7 vs 37.2 ms) and is not enabled.

R6 elastic-margin reuse is implemented (env-gated, off by default): the
material pass exports per-bond elastic utilization, the solver keeps the load of
each component's last converged solve, and components whose bonds all sit below
half their elastic limit and whose load moved by under 10 % republish stored
forces. City256 late debris 93 → 84 ms, bombardment 36.5 → 33.6 ms, discrete
outcomes and health drift identical in every window and over 180 bombardment
ticks; republished forces on those provably-safe components are stale by up to
one change fraction (measured up to 1.85× a bond's reference norm on a heavy
debris cluster). Contract v4 (`--contract-version 4`) reports that force
deviation instead of gating it. Details and the envelope: [warm-screen.md](warm-screen.md#r6-elastic-margin-reuse-implemented-off-by-default-measured-declared-compromise).

Contact-pair preservation measured neutral with identical histories. A deferred
refactor schedule using stale factors as preconditioners measured slower and
stays off; refactor latency (2.7 ms per launch, one building's level chain) is
the remaining solver-side target, ahead of R2/R5. See
[warm-screen.md](warm-screen.md).

The R2 body pool is complete (placeholder-aware GPU births, configure-time
creation, runtime-driven opt-in, contracts updated) but measured neutral on
every plan metric with the direct solve in place, so it ships opt-in
(`PHYSX_DESTRUCTION_BODY_POOL=auto`). Details: [warm-screen.md](warm-screen.md).

Island repair (the largest CPU-only sustained-tick cost after registration)
went from 7.1 to 1.7 ms per tick by building the contact graph on its own
stream after the narrowphase merge and by making the component observation
asynchronous with host-built member chains; bombardment 34.7 → 32.4 ms,
histories identical. See [warm-screen.md](warm-screen.md).

**Final state of this branch (2026-09-15, commit `29a478bc` + records).**
Nine-window warm screen under contract v4: all pass, city256 debris 127 → 74
ms, cascade 108 → 71, impact 91 → 69, city25 impact 24 → 15. Continuous
600-tick heavy campaign: 52.3 → 30.7 ms mean, 60 Hz misses 519 → 311, peaks
unchanged, physical counters identical every tick.

Continuous 600-tick heavy run with elastic reuse enabled: 51.2 → 29.8 ms mean,
60 Hz misses 519 → 294–300 of 600, peak 182 → 150 ms, physical counters
identical on every tick (R1 alone: 33.8 ms, 328 misses).

Full52 warm qualification passes 52/52 under contract v3 (city256 late debris 124.7 → 92.3 ms, fragmented 82.2 → 45.7). Continuous 600-tick heavy run: 51.4 → 33.8 ms mean, 60 Hz misses 519 → 328 of 600, identical physical work counters every tick. Official nine-window warm screen (all windows pass contract v3; city25 impact 22.6 → 17.1 ms, city256 cascade 105 → 80 ms, debris 125 → 93 ms, impact 89 → 75 ms, idle unchanged): [warm-screen.md](warm-screen.md).

## References

- Hecht, Lee, Shewchuk, O'Brien. Updated Sparse Cholesky Factors for Corotational
  Elastodynamics. ACM TOG 31(5), 2012.
- Herholz, Alexa. Factor Once: Reusing Cholesky Factorizations on Sub-Meshes.
  ACM TOG 37(6), 2018. Herholz, Sorkine-Hornung. Sparse Cholesky Updates for
  Interactive Mesh Parameterization. ACM TOG 39(6), 2020.
- Nukala, Šimunović. An Efficient Algorithm for Simulating Fracture Using Large
  Fuse Networks. J. Phys. A, 2003 (arXiv cond-mat/0503719).
- Haidar, Bayraktar, Tomov, Dongarra, Higham. Mixed-precision iterative
  refinement using tensor cores on GPUs. Proc. R. Soc. A 476, 2020.
- Sellán et al. Breaking Good: Fracture Modes for Realtime Destruction. ACM TOG
  2022 (precomputed-mode alternative; noted, not adopted: no stress propagation).
- NVIDIA CUDA 13.4 release notes (Programmatic Dependent Launch, Tile IR).
