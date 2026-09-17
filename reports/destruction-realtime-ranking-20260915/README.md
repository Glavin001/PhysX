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

**Grid defaults (after the final requalification below):** the component solve runs
four resident CTAs per SM and the batched refactor eight (`BLAST_GPU_NATIVE_SOLVE_BLOCKS`,
`BLAST_GPU_NATIVE_FACTOR_BLOCKS`), both lossless: 3 s bombardment 31.1 → 30.2 ms and the
impact peak 194.6 → 177.9 ms, the only change on this branch that moved the peak.

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

## 6. Handoff: remaining items with scoped designs

Ordered by expected gain per effort on the current runtime (`5f0b72ca`).

1. **R2 ownership migration (impact peak, ~150 ms of GPU-idle CPU per impact tick;
   10–20 ms per sustained tick in `correctedCollisionSolve` host time).** The body
   pool is done and opt-in; the remaining consumers are the shape migration
   (`applyBindings` / `rebindRigidOwner`), contact-manager creation and interaction
   registration, and `PxgGpuContext::update`/`updatePostPartitioning`. The inventory
   and the measured per-consumer costs are in `r2-consumer-inventory.md`. The GPU
   pre-solve island producer already exists; lifting `mPreSolveSleepingDisabled`
   needs authoritative device activity and sleep transitions.
2. **Tiny components (30 % of solve cycles, 1,693 per late solve).** Their cost is
   the per-component CTA epilogue (neighbor cache, rigid inverse, projection,
   monitor matvec, verification, finalize), each a block barrier with 128 threads
   over ≤7 nodes, not the 1.6 PCG iterations. The fix is a group-templated
   variant of `componentStressSolve` and its helpers on a 32-thread tile (four
   components per CTA), dispatched for `count <= 7` from the same work cursor.
   The shared arrays that cap occupancy (`directX`, 24 KB) are not needed there.
   A cheaper partial step: leaf elimination gives the exact static solution of
   loaded tree components in O(n), extending `retireHomogeneousTreeComponent`
   beyond zero input; it removes the iterations but not the epilogue. A first
   implementation (not kept) derived the per-endpoint bond blocks from
   `directBondBlock` and integrated node corrections from the pinned root; on
   the city256 bombardment most of its applications grew the residual and were
   undone, and the run then failed to converge (stage error 4096) while the
   resident analytic columns test failed. The bond-variable/residual sign and
   scaling relation must be taken from `nodeSpaceMatvecBody`'s actual operator
   (including the null-space projection of free components) before retrying.
3. **Refactor throughput — DONE as far as Woodbury goes (2026-09-15/16).**
   Woodbury updates shipped (`StressNativeWoodbury.cuh`, default on): a slot
   that lost at most 16 bonds keeps its factor; the capacitance is only
   semidefinite after a split, so the kept-part solution uses a rank-revealing
   pseudo-inverse (departed rows are never scattered). Exact-equivalent, 63 %
   of refactors replaced, impact peak 182 → 163 ms, mean neutral because every
   split creates a new component that still needs a full factor. The factor
   kernel also skips absent columns of the parent pattern (lossless). Still
   open: a real partitioner (level-structure bisection re-tested: 74 → 67
   levels, no gain) and the solve kernel's narrow-level latency, whose
   per-level cost turned out to be the serial 6×6 finish, not the gathers
   (`warm-screen.md`, diagonal-inverse finish in progress).
4. **R5 island-scoped correction** after R2's device islands exist; the affected
   set must include islands that lose or gain contact after correction.

Measurement recipe for any of these: `run-ab-demo.sh` (histories via
`compare_frames.py`), the nine-window warm screen with relinked probes under
contract v4, and the continuous 600-tick campaign, all documented in
`warm-screen.md`.

## 7. R2 stage 1: impact-tick attribution on the current runtime (2026-09-15)

Phase profile of the first-impact tick (step 82, 256 buildings, 5,204 fragment
bodies, 5,492 migrating shapes), runtime `64edea3f`, pool off / on. Per-scope
profiler cost inflates zones with thousands of scopes: `migrateShapes` reports
22.6 ms but its four per-shape sub-zones total 6.8 ms, so the migration itself
is about 7 ms; zones with one or two scopes are accurate.

| stage (host wall, ms) | pool off | pool on | nature |
|---|---:|---:|---|
| corrected collision + solve (parent) | 94.4 | 97.2 | mostly GPU waits |
| accept correction (+ rigid-state capture) | 28.4 | 21.4 | GPU wait |
| body allocation (`prepare`) | 18.7 | 15.6 | CPU: Sc/island bookkeeping per body, not creation |
| final publication | 17.3 | 20.2 | GPU gather wait + 5,204 direct core writes |
| contact-manager preallocation | 15.9 | 11.0 | CPU: new pairs |
| island insertion | 9.7 | 10.9 | CPU: new pairs |
| interaction registration (scene + shape) | 14.5 | 14.5 | CPU: new pairs |
| shape migration (net of profiler) | ~7 | ~7 | CPU |
| broad-phase wait / post broad-phase | 26.6 | – | GPU wait |

Conclusions for the migration: the pool does not buy the body cost because
the per-body island and scheduler bookkeeping (and, when pooled, the
kinematic-to-dynamic switch) is the cost, not object creation; publication is
already direct core writes; and the largest CPU block is the PhysX new-pair
pipeline (about 40 ms), which is exactly the consumer set that R2 moves to the
device (contact-manager creation, island insertion, interaction registration).
None of these is a bounded change: each requires the GPU-owned ownership
transaction and the sleep-scheduler consumption of device components described
in `r2-consumer-inventory.md`. Recommended first milestone: device-owned
contact-manager preallocation and island insertion for native pairs, gated by
the existing `mPreSolveSleepingDisabled` path, measured on this tick.

### R2 milestone 1 (found, not yet built): the device island producer falls back in 59 % of passes

`native.graph-diagnostics.json` for the profiled bombardment: `cuda_pre_solve_passes`
110, `cuda_pre_solve_fallbacks` 157, `same_pass_reuses` 110, `graph_builds` 424.
`buildPreSolveIslands` (`PxgDestructionRuntime.cu`) only seeds from the previous
components when `mGraphView.generation == mPreSourceGraphGeneration + 1`; a pass
builds the contact graph twice (`prepareIslandRepair.contactGraph`, then
`task.contactGraph` before submit), and when the retained-contact revision
changed in between the second build is not a same-pass reuse, the generation
advances by two, `usable` is false, no labels are produced, and the solver
falls back to CPU island insertion and maintenance for that pass. The 110
successful passes are exactly the 110 same-pass reuses.

Options, in order of safety: (a) run the producer after every graph build so
the seed is always one generation old (one extra producer launch per pass,
device-only cost); (b) make the second build fold its retained-edge delta into
the roster the producer will seed from, so a +2 jump with only retained
changes is accepted; (c) keep a per-generation component snapshot ring so
seeds can skip generations. Expected effect: island insertion and maintenance
(about 12 ms per sustained tick, 20 ms at impact) leave the CPU path in those
passes; the sleeping gate (`mPreSolveSleepingDisabled`) is a separate step.

Audited experiment (option (b)-like, `PHYSX_DESTRUCTION_PRESOLVE_SEED_SKIP=1`,
runtime `63d29cad`, `--audit-islands 1`, 3 s bombardment): device producer
passes 110 → 266 of 267, fallbacks 157 → 1, island boundary audits 534 with 0
failures in both runs, broken bonds identical (56,077), motion audit unchanged
(pre-existing 1.7e-5). The seed inherits node membership only for surviving
node lifetimes and merges the current graph's edges, so skipping the
intermediate retained-only generation over-merges nothing the audits can
detect. Timing and the native suite under the skip follow.

Timing under the skip (3 s bombardment, no audits): 32.7 ms against a 58.8 ms
control in the same run, ratio 0.556, inside the session's 0.54–0.56 band;
native suite unchanged (38/41, the three pre-existing failures). No time is
saved yet because the CPU still inserts island nodes and edges for the three
consumers named above (active-node roster, incremental partitioning,
retained-edge upload); serving every pass from the device producer is the
prerequisite for removing them. The skip therefore stays opt-in
(`PHYSX_DESTRUCTION_PRESOLVE_SEED_SKIP=1`) until milestone 2 replaces those
consumers, at which point it becomes the default together with them.

### R2 milestone 2 (design): replace the three CPU island consumers

With the device producer serving every pass (milestone 1), the CPU island
work that remains on the critical path exists only to feed three consumers:

1. **Solver node ordering** (`PxgGpuContext::update`, `PxgContext.cpp:2255–2380`):
   `mActiveNodeIndex` is assembled from the CPU island sim's active kinematic,
   rigid and articulation lists; it defines `mBodyCount` and the solver body
   order. Device counterpart: the pre-solve component labels plus per-node
   activity from the roster (`live`, static-touch counts). The device already
   produces the labels; producing a compacted active-node list on the device
   (a stream compaction over the roster) and reading it back replaces the
   copy, and the CPU island sim no longer needs to be brought up to date before
   the solve for ordering.
2. **Constraint partitioning** (`PxgConstraintPartition.cpp`): partition edges
   are keyed by the CPU island edge index (`getFirstPartitionEdge(unit.mEdgeIndex)`,
   `mSolverConstants[].mEdgeIndex`, `ShapeInteraction::mEdgeIndex`). Device
   counterpart: `PxgContactGraphIdentity` already carries the edge index and a
   64-bit contact-manager lifetime generation per resident pair
   (`GPU_CONTACT_GRAPH_NEXT.md`); keying partition edges by that identity, and
   allocating the edge slots on the device at pair creation, removes the
   requirement that every new pair be inserted into the CPU island sim before
   the corrected pass. This is the largest piece and the one that retires
   `preallocateContactManagers`/`islandInsertion`/`registerInteractions` from
   the impact tick (about 40 ms) and the per-tick island maintenance.
3. **Retained-edge upload** (`buildDestructionContactGraph`, host loop over the
   retained-contact bitmap): becomes a device-side delta once pair lifetimes
   are device-owned (item 2), leaving no host walk.

Order of work: 1 (bounded, measurable on its own only as CPU time in
`update`), then 2 with the sleeping gate lifted by consuming device component
membership in the sleep scheduler (the `processLostEdges` deactivation loop),
then 3. Milestone 1's seed skip becomes the default with item 1.


## 8. R5 groundwork: map of the corrected pass (2026-09-16)

Where the corrected pass lives (for an island-scoped variant):

- Trigger: `Sc::Scene::finalizationPhase` (`ScPipeline.cpp:2998`): eligibility
  `:3042-3056`, `advanceDestruction` `:3057`; when bonds broke, scene repair
  `:3059-3128` (report-stream teardown, `onResetFiltering`; the fallback
  refilter loop `:3118-3127` visits *all* shapes), `restoreDestructionActivity`
  `:3130`, then re-entry through `stepSetupCollide` + `mCollideStep`
  `:3135-3139`, i.e. the same full pipeline `simulate` uses: updateShapes →
  narrowphase → broadphase → island insertion → registration → solver →
  updateDynamics → postSolver → afterIntegration → destruction finalization.
- Full-scene stages: broadphase update, overlap filtering / contact-manager
  preallocation, island insertion and second-pass island gen, partitioning,
  solver. Already restricted: preserve-pairs repair (`:3082-3116`), GPU
  contact/friction cache reset (`PxgSimulationController.cpp:893-899`),
  `installCorrectionBodies` / `installCollisionOwners`
  (`PxgDestructionRuntime.cu:2012/2030`), writeback skipping `mLastTransform`
  during correction (`PxgContext.cpp:953`).
- Affected sets already known to the runtime: `mHostCorrectionTargets` →
  `correctionBodyIndices` (`PxgDestructionRuntime.cu:675, 2052-2078`); new
  fragments `mHostReservedIndices` → `reservedBodyIndices` (`:1869+`);
  broken clusters `mAffectedClusters` (`:592`); migrating shapes
  `mMigratingCollisionBindings` (`:2030`); controller `mUpdatedMap` /
  `mNewOrUpdatedBodySims` (`PxgSimulationController.cpp:870-884`).
- Islands on the CPU: `mSimpleIslandManager` accurate/speculative
  `IslandSim` (`PxsIslandSim.h:646-691`: `getIsland`, active islands, member
  walk `Island::mRootNode/mLastNode`, `Node::mNextNode`). No per-island
  restore or re-simulation hook exists; nearest hooks are
  `prepareGpuDestructionIslandRepair` (`PxgSimulationController.cpp:657-686`)
  and `restoreHostConnectivity` (`PxsSimpleIslandManager.h:213-225`).
- Restore: `captureDestructionActivity` (`ScPipeline.cpp:2030-2061`, trial
  only) records every active rigid node's wake counters, sleep flags and
  island readiness; `restoreDestructionActivity` (`:2063-2097`) rewinds
  `body2World := mLastTransform`, wake state, re-activates nodes on both
  IslandSims and replays notifications; GPU rigid state is a full-array D2D
  restore (`captureRigidState`/`restoreRigidState`,
  `PxgDestructionRuntime.cu:1777/1851`).

Exactness rule for an island-scoped correction: an island whose bodies had
no trial contact with any affected body (mass/ownership changed, new
fragment, migrated shape) *and* gain no broadphase overlap with an affected
body in the corrected pass has identical inputs in both passes, so its
trial result is its corrected result. The affected closure is therefore
{islands of affected bodies} ∪ {islands with a trial pair to an affected
body} ∪ {islands with a corrected-pass overlap to an affected body}; contact
*loss* is covered because a lost pair was a trial pair. The corrected
broadphase must still run on the affected bodies' bounds (against all
bounds) to find the third set; everything after it (narrowphase,
partitioning, solver, integration) can be restricted to the closure, and
the restore can be skipped for the untouched islands. The cost that this
removes is the full-scene narrowphase/solver/integration of the corrected
pass and its per-stage CPU overhead (~12 ms per corrected pass on the late
city256 window, 17 ms per pass); the remaining risk is engineering: the
`Sc::Scene` pipeline has no partial-scene entry point, so the scoped pass
needs a filtered body/pair set through `stepSetupCollide` or a dedicated
mini-pipeline over the closure.

## 9. R2 milestone 2, item 1 re-examined (2026-09-16)

Mapping of the solver node-ordering consumer (`PxgGpuContext::update`,
`physx/source/gpusolver/src/PxgContext.cpp:2234-2381`): the solver body
layout is [world][active kinematics][active rigid dynamics][articulations],
copied from the accurate IslandSim's active lists (`:2371-2381`), whose
order is activation history (push-back / swap-remove,
`PxsIslandSim.h:864-912`), not node index. Order matters: it fixes
`solverBodyIndices[node]` (`preIntegration.cu:58`), slab/warp grouping,
accumulator layout and the host writeback pairing, so a different but
still deterministic order changes floating-point results (not bitwise
histories). Set-only consumers: partitioning (node/edge keyed), island
labels, constraint prep, CPU sleep/wake.

Two facts move item 1 out of the "bounded" class:
1. The device roster's `live` flag (`PxgContext.cpp:2596`) means island-valid,
   not deleted and not kinematic; it equals the active set only when the
   pre-solve sleeping gate disables sleeping. With sleeping on (required),
   "active" is the CPU wake-counter state, so a device active list needs
   device-owned sleep state first (the rest of R2), not just a compaction.
2. Ordering hazard: `buildPreSolveIslands` runs after `update()` has built
   `mActiveNodeIndex` (`PxgContext.cpp:2626-2640`), so the device list would
   have to be produced a phase earlier or consumed one phase late.

No compacted active list exists on the device today; `cub::DeviceSelect`
(order-preserving, hence canonical by node index) would provide one. The
CPU work that exists only to feed this consumer is the island-gen passes
and `restoreDestructionActivity` rebuilding the active lists for the
corrected pass (`ScPipeline.cpp:1160-1212, 1820-1839, 2572-2593,
2063-2096`). Conclusion: R2 item 1 is gated on device sleep state; the
next R2 step with a measurable payoff is therefore item 2 (device-keyed
partition edges, retiring `preallocateContactManagers` /
`islandInsertion` / `registerInteractions` from the impact tick) together
with the device sleep scheduler, i.e. the multi-week core of R2.

### Device sleep verdict audit, cause of the residual (2026-09-16, after R2 steps 1–3)

`PHYSX_DESTRUCTION_DEVICE_SLEEP=2` with the new `PHYSX_DESTRUCTION_DEVICE_SLEEP_DIAG=1`
(device-side contradiction test in `componentSleepVerdicts`, `PxgDestructionRuntime.cu`) on the
g16 3 s bombardment: 763 of 1.72 M solver entries are "device says ready" while the entry's own
solver sleep data is awake, and the island audit's first mismatches are the 256 projectiles at
the impact tick (CPU wake counter 0.333, freshly reset by the solver; device verdict ready).
Two causes, both ordering, neither numerical:
1. The verdict kernels are enqueued from `prepareGpuDestructionIslandRepair`, which runs in
   `destroyManagers` concurrently with the solver task (`processLostContacts3` continues to
   `mPostSolver`, `ScPipeline.cpp:2267`). Depending on which side enqueues first, the device
   reads this pass's or the previous pass's sleep data, while the CPU third pass always uses
   the readiness flags set by the previous tick's `afterIntegration` (sticky flags, restored
   by `restoreDestructionActivity` for corrected passes).
2. Nodes absent from the solver list of the pass that produced the data (fragments born this
   pass, bodies just activated) have no entry; `ownNotReady` is zero-filled, so they default to
   ready, whereas the CPU creates them not ready.
Requirement for the device sleep scheduler (R2 item 1): compute the verdict once per tick on the
solver stream immediately after `integrateCoreParallel` of the accepted pass, from the pre-solve
node labels of that pass (`mPreSolveIslandIds`, stable during the solve, instead of the repair
graph that may be rebuilt concurrently), default missing entries to not ready, and publish it for
both the trial and the corrected third pass of the next tick; CPU-side wakes stay covered by
`mIslandWokenThisFrame`. Only then can mode 1 be qualified as lossless.

Done the same day (increment 2, `warm-screen.md`): with that timing the device-side contradictions
are 0, but 0.8 % of island decisions still differ because the CPU readiness flag has sources the
device cannot see (fragments created ready-for-sleep, cleared only by CPU wake paths). Mode 1
measured +5.7 % bonds broken on g16 (outside the §11 envelope) and stays off. The scheduler
therefore needs device-owned activation state, not only the reduction.
Located (same day, `warm-screen.md`): the residual is PhysX's island-generation-versus-solver race
rule in `afterIntegration` (bodies the island generator deactivates in parallel are rolled back with a
zero wake counter and their solver wake flags discarded, readiness left set). The device verdict would
have to apply the previous tick's `getNodesToDeactivate` list, or the device must own deactivation.

Exact half-step achieved (`warm-screen.md`, modes 4/5): CPU readiness flags reduced per device component
over the repair graph's labels (accurate and speculative sims separately) reproduce every CPU island
sleep decision (0 of 1.34 M disagree) and the control histories bit for bit. Kept off: the synchronous
upload/readback costs ~0.8 ms per tick against a 0.04 ms CPU walk. It establishes that repair-graph
components equal CPU islands for sleep; the remaining work is device-owned readiness sources.
Second half-step (modes 6/7): the readiness flag is mirrored on the device by deltas recorded at every
CPU change (atomic recording; overflow reseeds), the reduction reads the mirror. Exact (0 differences on
3.6 M node checks, histories bit-identical), +1.3 ms per tick from waiting for this pass's repair graph,
off by default. Remaining for device-owned sleep: produce the deltas on the device and consume the
reduction there.

### R5 stage 1 result (2026-09-16): the corrected pass re-simulates ~200× more than it must

`PHYSX_DESTRUCTION_ISLAND_SCOPE_DIAG=1` (PxgSimulationController, at the
correction install) on the g16 3 s bombardment, 143 corrected passes: the
first impact pass affects everything (256 islands, 4,864 new fragments);
every later pass touches 1–21 of ~4,700 active islands and 1–21 of ~10,000
active bodies (correction targets 2–28 per pass). The closure by trial
pairs is already contained in "the island of the affected body"; only
corrected-pass *new* overlaps can extend it.

Implementation route with the least pipeline surgery (design, not built):
1. Scope the restore. `restoreDestructionActivity` currently rewinds every
   active body to `mLastTransform`; instead rewind only bodies of affected
   islands and leave the others at their trial end-of-tick state. The GPU
   `restoreRigidState` (full-array D2D of `PxgBodySim`) becomes a gather over
   the affected body list.
2. Park the untouched islands for the corrected pass with the internal
   activity toggles the restore already uses (`deactivateNode_ForGPUSolver`
   without user notifications): sleeping bodies are neither solved nor
   integrated, so their trial result stands, while a corrected-pass overlap
   between an affected body and a parked body wakes that island through the
   ordinary island-manager path, which is exactly the third closure set.
3. After the corrected pass, re-apply the captured activity (wake counters,
   sleep flags) to the parked islands so the next tick sees the trial state.
Expected: the corrected pass drops from ~17 ms per pass (~12 ms per
sustained tick) to the cost of a few islands plus the full-scene
broadphase update; the impact tick is unchanged (everything is affected).
Fidelity: mathematically exact for untouched islands; not bitwise
comparable to today's histories because the solver's active set (hence
partition and body order) changes, so qualification is by the physical
gates (contract v4, counters, trajectories), not by identical histories.

#### Parking mechanics (mapped 2026-09-16, before stage 2)

- Activity lives in two places: IG node state (`PxsIslandSim.cpp:776-830`
  `activateNodeInternal`/`deactivateNodeInternal`) and Sc state
  (`mActiveBodies`, `ScScene.cpp:1186/1257`; `BodySim::setActive`,
  `ScSleep.cpp:50`). `deactivateNode_ForGPUSolver`/`activateNode_ForGPUSolver`
  (`PxsIslandSim.h:701-710`) only flip readiness; removal from the active
  list happens in third-pass island gen after the solver, so they cannot park
  an island for the same pass. Parking needs a new IG-level "deactivate now"
  that bypasses `BodySim::setActive` (which asserts `wakeCounter == 0`, zeroes
  velocities and queues user sleep notifications, `ScBodySim.cpp:463-497`).
- The corrected pass refreshes all rigid shape bounds from the GPU body sims
  regardless of activity (`PxgSimulationController.cpp:1190`,
  `PxgSimulationCore.cpp:3265-3305`), so parked bodies carry their trial
  end-of-tick bounds into the corrected broadphase: what the closure needs.
- A contact manager exists only if at least one actor is active in the
  speculative sim (`ScShapeInteraction.h:286-307`); parking both sides in the
  speculative sim destroys the manager (`onDeactivate`, `.cpp:971-995`) and
  its contact cache, which would cost warm starts on every debris pile after
  every correction. Hence park in the accurate sim only (solver list source,
  `PxgContext.cpp:2371-2381`) and keep the speculative sim untouched, provided
  the solver's constraint selection skips edges whose endpoints are both
  inactive in the accurate sim (under verification).
- A new touch between an affected body and a parked one wakes the parked
  island in the same pass (`setEdgesConnected` `ScPipeline.cpp:1790-1820` →
  second-pass island gen → `wakeObjectsUp`), before `PxgGpuContext::update`,
  so the third closure set is handled by the ordinary path; a broadphase
  overlap without a touch does not wake it (correct: no coupling).
- GPU restore (`PxgDestructionRuntime.cu:1777-1875`) is three whole-array D2D
  copies (`PxgBodySim`, previous velocities, accelerations) sized
  `mTotalNumBodies`; a scoped restore is a gather over the affected index
  list, with `installCorrectionBodies`/`acceptCorrection` to be checked for
  full-array assumptions. Bodies absent from `mActiveNodeIndex` are untouched
  by the corrected solve (no pre-integration, solve or writeback).
- Asserts that constrain ordering: `activateNode` requires
  `mActiveNodeIndex == PX_INVALID_NODE` (`PxsIslandSim.cpp:704`),
  `makeEdgeActive` (`:765-766`), `ShapeInteraction::onDeactivate` (`:967-969`),
  `validateDeactivations` (`PxsSimpleIslandManager.cpp:424`),
  `addToActiveList`/`removeFromActiveList` and the kinematic prefix
  (`ScScene.cpp:1188/1260-1298`).

#### Why parking at the island-sim level is not enough (mapped 2026-09-16)

The GPU solver solves exactly the incremental partition, and the partition is
driven by the accurate sim's edge activity: deactivating edges destroy their
`PartitionEdge`s and zero their friction patch counts
(`PxgConstraintPartition.cpp:2130-2213`, `:2202-2210`); activated edges are
re-added only when `activeCMBitmap` says so (`:2248-2270`). There is no
solver-side backstop: `mSolverBodyIndices` is `0xFFFFFFFF` for inactive nodes
(`PxgSolverCore.cpp:292`, `preIntegration.cu:58`) and the constraint prep
would index with it (`constraintBlockPrePrep.cu:879, 1108-1134, 1338`), so an
edge that survives with a parked endpoint is memory corruption, not a skip.
Consequences for the design above:
- Parking a node in the accurate sim (`deactivateNodeInternal`,
  `PxsIslandSim.cpp:805-850`) deactivates its edges to other parked nodes:
  every contact among parked debris loses its partition edge and friction
  anchors on every corrected pass, and re-activation after the pass is
  dropped by `wakeIslands` before the next partition update
  (`PxsSimpleIslandManager.cpp:378-384`), so those contacts would never
  regain partition edges unless re-dirtied. That is both a fidelity change
  (warm starts and friction anchors lost on all piles each correction) and a
  partition rebuild cost of the same order as the pass it replaces.
- Parking must also mirror `deactivateIsland`/`activateIsland`
  (`:943-959`, `:932-941`) including `markIslandInactive`, or a new touch
  wakes a single node with edges to still-parked neighbours.
- Freezing bodies on the GPU instead (mask in pre-integration, solver and
  writeback, affected set from the device pre-solve labels so new touches
  unfreeze exactly) keeps the partition intact and is exact, but it leaves
  every CPU stage of the corrected pass in place; the timeline shows those
  CPU gaps, not the kernels, are most of the 17 ms per pass.

R5 therefore needs partition-level parking: a third edge state in
`PxgIncrementalPartition` ("dormant": keeps `PartitionEdge`s and patches,
excluded from the solve), island-level parking that uses it, a scoped
restore (CPU and GPU gather), and re-activation through the same state on
the next pass. Combined with skipping island insertion / contact-manager
preallocation for dormant islands, it removes the CPU stages as well.
Estimated at several weeks with the physical-gate qualification; the
diagnostic (`PHYSX_DESTRUCTION_ISLAND_SCOPE_DIAG`) and the maps in this
section are the starting point.

### R5 stage 2, first implementation (2026-09-16, env-gated, default off)

`PHYSX_DESTRUCTION_ISLAND_SCOPE=1` (2: stress skip only, 3: parking without
the stress skip; both bisection modes). Pieces:
- `IG::IslandSim::parkIslandForPass` / `unparkIslandForPass` (accurate sim
  only; no edge changes, no notifications; unpark tolerates islands merged or
  woken during the pass) and `collectNeighbourIslands` (inline, used from the
  GPU module).
- `PxgSimulationController`: after the correction bindings, the affected set
  = islands of correction targets and reserved bodies plus every island
  connected to them by an edge (a projectile resting on the kinematic
  building it just split shares no island with the replacement bodies; the
  kinematic building node has hundreds of such edges). Islands with
  kinematic or articulation nodes are never parked. The GPU restore keeps a
  snapshot of the trial end-of-tick state and reinstates it for parked
  bodies (`requestTrialSnapshot` / `reinstateTrialState`), and flags the
  stress components of parked bodies so the corrected stress solve
  republishes their trial result (`setParkedComponentFlags`, the settled
  skip path).
- `Sc::Scene::restoreDestructionActivity` skips the rewind of parked bodies
  and parks their islands; `finalizationPhase` unparks them after the
  corrected pass.
- Constraint pre-prep maps a solver body index of 0xFFFFFFFF (a parked body)
  to the static world (zero response); the writeback skips such rigid
  contacts so their impulse and friction caches and their published
  response keep the trial values.

Findings so far (g4 bombardment, 3 s): flag off is bit-identical to the
baseline; mode 2 (stress skip only) is bit-identical too, i.e. the affected
set and the component skip are exact; modes 1 and 3 keep the CPU/GPU motion
audit at the baseline level (5.6e-6 vs 6.3e-6) but the history diverges from
the first parked correction on (bonds broken 2,993 vs 4,192 over the run).
Because a full corrected pass re-simulates untouched islands with a
different solver active set (different body order), it is itself not
bitwise equal to the trial for those islands, so a bitwise comparison
cannot separate a defect from floating-point chaos here; the next check is
the warm-window contract (16-tick windows, force relL2 and health drift)
with relinked probes, and per-body state comparison right after a parked
correction. A g16 run of mode 1 crashed once in `unparkIslandForPass` on an
island merged away during the pass (guarded since).

### R5 stage 2 outcome (2026-09-16): island-sim parking does not deliver; kept env-gated off

Further iterations on `PHYSX_DESTRUCTION_ISLAND_SCOPE=1` fixed two real
island-sim interaction bugs and reached a crash-free g4 run, but the
approach is not viable as built:

- Bugs found and fixed: (1) the affected set must be computed after the
  correction bindings (the target list is empty at the GPU restore), so the
  GPU keeps a trial snapshot and reinstates parked bodies afterwards;
  (2) parking must clear the node's active flag, otherwise a merge with an
  awake island leaves inactive nodes in an awake island and the sleep pass
  crashes in `deactivateNodeInternal`; (3) a parked node can be queued for
  activation during the pass (`activateNode`: activating list, index into
  that list); unparking such a node through the normal internal activation
  double-activates it and strands a stale active-list entry, which crashed
  the next parking pass. Unpark now skips active-or-activating nodes and
  `validateActiveLists` (trace env) confirms the lists stay consistent.
- Remaining defects: the g16 run still hits a CUDA illegal address late in
  the run (error 700, not localised: the only kernel indexing solver bodies
  by node is the patched pre-prep), the history diverges from the first
  parked correction on even with consistent island state (g4: 3,341 vs
  4,192 bonds; the CPU/GPU motion audit stays at the baseline level, and
  the stress-skip-only mode is bit-identical, so the divergence is on the
  rigid-body side of parked islands: neutralised contacts and skipped
  writebacks change the next tick's warm starts, contact events and
  activity bookkeeping), and it is slower, not faster: g16 late window
  68 ms vs 54 ms, corrected ticks 79 vs 56 ms, because parked bodies still
  go through broadphase, narrowphase and constraint prep, and their
  end-of-tick poses against the affected bodies' start-of-tick poses create
  spurious touches that wake and merge islands.

Conclusion: the cost the corrected pass carries is the full-scene CPU
pipeline (island insertion, contact-manager preallocation, registration,
partition updates) plus narrowphase and prep over all pairs; parking bodies
without removing their pairs from those stages saves only the solve and
integration. The viable R5 remains the partition-level design above
(dormant edges, pairs skipped end to end, exactness qualified by the
physical gates), a multi-week change. The stage-2 code stays in the tree
behind the flag (default off; flag-off is bit-identical to the baseline)
as scaffolding: island park/unpark, neighbour-island closure, trial
snapshot/reinstatement, parked-component stress skip (exact), pre-prep
neutralisation and writeback skip, and the diagnostics
(`PHYSX_DESTRUCTION_ISLAND_SCOPE_DIAG`, `_TRACE`, modes 2 and 3).

## 10. R2 core, stage 0 (2026-09-16): where device-owned activity would start

The pre-solve roster's `live` flag is authored on the CPU from the accurate
island sim (`PxgContext.cpp:2596`: island id valid, not deleted, not
kinematic) and uploaded as node updates (`mPreSolveNodes`); the device
island producer only labels components among live nodes
(`PxgPreSolveIslands.cuh`). Nothing on the device decides activity today.
The R2 core therefore begins with device-owned sleep: consume the solver's
per-body sleep data (`PxgSolverBodySleepData`, rebuilt per pass) on the
device to (a) update roster liveness, (b) emit activation/deactivation
deltas for the CPU island sims and Sc (`wakeObjectsUp`/`putObjectsToSleep`
consumers, `ScSleep.cpp:148-306`) instead of the CPU deriving them from
island gen, and (c) feed `PxgGpuContext::update` a compacted active list
(README §9). Only after that can partition edges be keyed by device pair
identities (§7, item 2), which is what retires island insertion,
contact-manager preallocation and registration from the impact tick. Each
of these is a fidelity-neutral but non-bitwise change (body order), so the
physical gates are the acceptance path from the first step.

## 11. State at the end of 2026-09-16 (session c)

Shipped defaults (all lossless, bit-identical histories on the g16 screen,
11/11 tests, continuous 600-tick counters identical): R1 direct factorization
with Woodbury, pipelined narrow levels, diagonal inverses, 3 CTAs/SM and the
verification skip; R6 incremental mass and motion modes; elastic reuse;
friction-count zero-fill; speculative stress topology from the trial view;
eager refactor on a side stream flushed after the runtime's synchronisations.
Continuous city256: heavy 54.8 → 28.4 ms (60 Hz misses 519 → ~310), idle
1.9 ms; warm nine windows pass under contract v4.

Measured structure of a late corrected tick (g16, 42–50 ms): trial CPU
pipeline ~13 ms, trial stress wait ~7, corrected pass ~11 (CPU stages plus
launch chains, GPU busy 20 %), corrected stress wait ~5. GPU busy 26 % of
the tick; the destruction GPU chain is ~10 ms/tick (two solves of ~255
remnants whose loads change >1 %/tick, refactors, loads).

Closed with measurements (see warm-screen.md): corrected-solve component
skip (mode 2), exact/tolerance input reuse, device-side frozen corrected
pass (mode 4, three variants), more CPU workers, smaller eager refactor
grids, tiny-component dense step, cluster refactor, ND ordering.

Remaining plan items, both multi-week and neither bit-comparable: R2
registry migration (impact tick: ~40 ms new-pair pipeline, 22 ms body
allocation; sustained −2 ms) and a CPU-level scoped corrected pass
(~5 ms per corrected tick, needs a non-renumbering solver body list to be
verifiable). With the two-pass same-tick rewind on this GPU the sustained
floor is ~25 ms at city256 heavy; 16 ms needs either that structure relaxed
or faster hardware.

### Acceptance envelope for order-changing work (R2 core, CPU-level R5), adopted 2026-09-16

Work that changes the solver body order cannot reproduce bit-identical
histories, and the fracture model amplifies bit-level differences into
different break sequences, so the exact gates (contract v4 discrete outcomes,
continuous counter match) do not apply. Until the user overrides it, such
work is accepted when, against the control on the same fixture and run
length: total broken bonds and final cluster count are within 3 %; no tick
breaks more than 2,000 bonds where the control breaks fewer than 200
(collapse without cause); the demo's motion and island-boundary audits pass;
the nine warm windows stay within their motion bounds; and timing is
reported as before (means, peaks, 60 Hz misses). Bit-identical control
runs (A/A) remain required for every lossless change.

**Calibration (2026-09-16, `warm-screen.md`):** reversing only the partition insertion order of the same
edge set moves the g16 bond total by +23 % (56,077 → 69,243). The ±3 % bound on totals is therefore below
the scene's own order sensitivity and rejects every order-changing change; the rejected candidates
(+5.7 % solver-derived sleep verdicts, +7.7 % narrowphase partition source) lie inside that sensitivity.
The envelope needs an ensemble-based or order-insensitive definition before any order-changing R2 step can
be accepted or refused on evidence.
Ensemble measured (`warm-screen.md`): rotations of the insertion order give 58,237–60,797 bonds and
12,911–14,337 peak clusters; the narrowphase partition source (60,409 / 13,657) and the solver-derived sleep
verdicts (59,271 / 13,346) lie inside. Provisional rule (owner to confirm): accept order-changing candidates
inside the mild-perturbation range with motion audit at the ensemble level and no collapse without cause.
Adopted as the working protocol (2026-09-17): `tools/scripts/run-destruction-order-ensemble.py` runs four
insertion orders per arm and compares ranges and medians. Verdicts: step 4 accepted (inside the control
spread, tick median equal); solver-derived sleep verdicts rejected on cost (+8 ms per tick); pair pool
pre-heat rejected (systematic +10 % bonds in every order, cause open).

## 12. R2 milestone 2 item 2: device-keyed partition edges — code map and plan (2026-09-16)

Keying by the CPU island edge index today: `IG::GPUExternalData::mFirstPartitionEdges`
(`PxsIslandSim.h:460-463`, `getFirstPartitionEdge(edgeIndex)`), `mDestroyedPartitionEdges`
(`:467-472`), `mActiveContactEdges` (`:476`), `CPUExternalData::mEdgeNodeIndices` (`:437-442`),
`AuxCpuData::mConstraintOrCm[edgeId]`/`mInteractions[edgeId]` (`PxsSimpleIslandManager.h:143-146, 312`);
`PartitionEdge::mEdgeIndex` (`PxsPartitionEdge.h:76`, 27-bit domain, `:104`),
`processPartitionEdges` (`:113-127`, the CPU↔NP rebinding hook), `mSolverConstants[uniqueId].mEdgeIndex`
(`PxgConstraintPartition.cpp:904`, `:2395`), `mNpIndexArray` (`:898`, `:2391`, published `:2588`),
`mDestroyedContactEdgeIndices` (pushed `:1702, 1774, 1821, 2207, 2266, 2560`). Downstream: friction
patch counts and index stream sized by `getNbEdgeHandles()` (`PxgContext.cpp:2557-2563`), destroyed-edge
clear (`PxgCudaSolverCore.cpp:314-411`), device reads of `constants->mEdgeIndex`
(`constraintBlockPrePrep.cu:968-969`, `constraintBlockPrep.cu:439`, `constraintBlockPrepTGS.cu:356`,
`artiConstraintPrep2.cu:1301`). The only host read of the CPU edge index into the device identity:
`PxgNarrowphaseCore.cpp:8667-8672` (`mContactGraphEdges[i] = cm->getWorkUnit().mEdgeIndex`, consumed by
`contactIdentity::initialize`, `PxgContactIdentity.cuh:18-32`). `mPartitionIndexArray`/`mPartitionNodeArray`
are already keyed by the pool slot `mUniqueIndex`, not by edge index.

Irreducible host residue per native pair: a `ShapeInteraction*`-shaped report handle
(`constraintBlockPrePrep.cu:981`, `accumulateThresholdStream.cu:545,596,833`), the filter verdict
(`ScPipeline.cpp:687`), and the sleeping-counter contribution (`:1274-1280`). Touch events
(`PxsContext.cpp:529-577`, `ScPipeline.cpp:1792-1823`) and the partition's `Part2_0/Part2_1`
(`PxgConstraintPartition.cpp:2260-2290, 2340-2408`) currently require the CM and a valid `unit.mNpIndex`.

Plan (each step measurable):
1. DONE (2026-09-16, lossless, neutral): device-owned dense slot allocator next to
   `PxgContactGraphSequence` (`PxgContactSlotAllocator`, `PxgContactGraphIdentity::slot`,
   `contactIdentity::reserveSlots/releaseSlots`, kernel `releaseContactSlots` at `removeLostPairs`);
   `native_contact_graph_check` verifies slot uniqueness and allocator counters. The CPU edge index
   still rides in `edgeIndex` until steps 2-5 key their consumers by slot; measurements in
   `warm-screen.md`.
2. DONE (2026-09-16, lossless, neutral): the dense pair slot is host-owned (`PxcNpWorkUnit::mDeviceSlot`,
   allocated at `PxgNphaseImplementationContext::registerContactManager`, recycled after `removeLostPairs`),
   published into the identity, carried in `PxgSolverConstraintManagerConstants::mPairSlot`, and the
   friction patch counts / index stream / destroyed-edge clear are keyed by it (sized by the partition's
   slot capacity). Step 1's device allocator was replaced: the host needs the key before the pass runs.
3. DONE (2026-09-16, lossless, neutral against a full control binary): `mFirstPartitionEdgesBySlot` beside
   `mFirstPartitionEdges`, mirrored at every contact head update; `processPartitionEdges` and the NP
   lost/found patch passes look up by slot. Island-driven loops and joints stay on edge handles.
4. BUILT env-gated (2026-09-16, `PHYSX_DESTRUCTION_PARTITION_NP_SOURCE`; 88 % of items from narrowphase,
   deterministic, +7.7 % bonds pending the envelope recalibration). Sizing: a narrowphase-driven source (touch bitmap ∩ touching output ∩
   either endpoint active) reproduces 89.6 % of the island's activated pairs; the rest are corrected-pass
   re-activations (8.4 %, replay the trial set) and wake re-activations (1.3 %, need per-node pair adjacency).
   Order-changing; qualifies under §11. Original plan: device pair roster feeding `Part2_0/Part2_1`.
5. DONE as part of step 2 (friction counts, friction index stream and destroyed-edge clear are keyed
   by the pair slot; histories bit-identical).
6. RE-SIZED (2026-09-17, `warm-screen.md`): by phase timestamps the four registration stages of the corrected
   impact pass overlap (union 15.7 ms of a 29.2 ms sum); this step removes at most ~7 ms of wall time. The
   24.5 ms serial `preallocateContactManagers` (pool allocation of ~100 k managers, interactions, markers on
   one thread) is the larger, island-independent target. Skip `IslandInsertionTask`, `registerContactManagers` and handle preallocation for native pairs
   (`ScPipeline.cpp:969-1020, 1082-1086, 1220-1247`), keeping `registerInteractions`/
   `registerSceneInteractions`; checkpoint: the ~25 ms of those scopes at the impact tick drop, broken-bond
   totals within the order-changing envelope (§11).
7. Device retained-edge deltas replacing the host walk (`PxgSimulationController.cpp:816-863`);
   checkpoint: zero host staging in `native.graph-diagnostics.json`.
Step 6 keeps the sleeping gate (`mPreSolveSleepingDisabled`, `PxgContext.h:338`) as analysed in
`r2-consumer-inventory.md:82-84`.

## 13. State at 2026-09-17 (session d): stress-solve residency, closed leads, configuration costs

Shipped defaults added this session (all lossless: identical histories on the g16 screen, 14/14 native
tests, warm nine windows pass under contract v4): R2 steps 1–3 (dense pair slots), stress-solve
occupancy 3 CTAs/SM with dynamic staging, largest-first dispatch, reserved contact pairs
(`PxDestructionStressDesc::reservedContactPairs`), 128-thread solve CTAs and the staging vector in a
per-CTA global scratch. City256 3 s bombardment mean: 31.7 → ~28.5 ms (late window 52 → 47, impact
peak 195 → ~173); the continuous 600-tick A/B of these defaults is in `out/direct-continuous-ab-20260917`.

Closed by measurement (details in `warm-screen.md`): the refactor's 45 % share of GPU kernel time is
hidden behind the CPU pipeline (0.8 ms/tick exposed at the factor-stream join, 12 ms of host slack);
Woodbury cap 32 and slot inheritance; the tiny-component split launch (twice); pinned host allocation
(setup/teardown only); nsys graph-launch API times (tracer artifact); 96/64-thread solve CTAs.

Measured composition of a sustained tick on this machine (19-vCPU Xeon E5-2673 v4 VM at 2.3 GHz,
RTX 5060 Ti): trial rigid pass ~10–13 ms of CPU-bound PhysX pipeline, trial stress solve 4.2 ms on the
device, corrected rigid pass ~11–15 ms, corrected stress 2 ms. Scene-query maintenance of the chunk
shapes is 2.4 ms of that (pruner commit 1.6, bounds sync 0.8), an application choice exposed as demo
knobs with the default unchanged. What remains is the two CPU-bound rigid passes, whose components are
diffuse (island sims 6 %, new-pair pipeline 3 %, activity snapshot/restore 1.7 % of CPU samples; the rest
is PhysX's task chain and GPU waits); the structural answers stay R2 (device-owned lifecycle and islands)
and R5 (partition-level scoping of the corrected pass), both multi-week and order-changing.

## 14. Next increment specified: stress submit before the CPU island chain (R2 item 1 reorder, 2026-09-17)

Kernel timeline of a sustained trial pass under the current defaults (`nsys-node2`): the rigid solver
and integration finish 3.5 ms before the stress solve starts, and the GPU is idle for ~2.5 ms of that
(gaps of 1.3 ms after integration, 0.5 ms after the bounds update, 0.1–0.2 ms between the sleep
finalization uploads, 0.2 ms before the loads). The CPU chain in that window is `afterIntegration`
(body DMA wait 0.75 ms), the accurate and speculative island maintenance (0.75 ms each, parallel),
`finalizeGpuSleep` (sleep commit, 0.5–0.6 ms; its four setter launches are now one, −0.3 ms/tick)
and then `advanceDestruction` (`ScPipeline.cpp`, `finalizationPhase`), whose loads read the body
state *after* the sleep commit zeroed sleeping bodies. Twice per tick this is ~5 ms of the sustained
tick, the largest bounded item left outside R5.

The reorder: (1) build the destruction contact graph as soon as narrowphase outputs are final
(device-only dependency; today launched from `prepareGpuDestructionIslandRepair`); (2) after
integration, reduce readiness and sleep verdicts on the device (mode 6 machinery, measured exact:
0 disagreements, identical histories) and apply the zeroing of newly sleeping bodies with
`zeroNativeSleepMotion` from device verdicts; (3) enqueue loads and the stress solve immediately,
so the solve overlaps the CPU island maintenance; (4) the CPU island sims consume the device
verdicts (mode 6 "use") and the sleep commit becomes idempotent; (5) the verdict/correction join is
unchanged. Exactness rests on the mode-6 audit; the PhysX afterIntegration race rule (IG-deactivated
bodies rolled back) is the one known divergence source and is already handled by that mode's
previous-deactivation list. Expected gain up to ~2.5 ms per pass; cost several days in
`PxgSimulationController`/`Sc::Scene` scheduling plus the ensemble check if any order changes.

**Increment 1 result (2026-09-17, `warm-screen.md`):** the device list from the readiness mirror and the repair-graph
labels misses 11 % of the CPU's real deactivations (decisions carried by the correction restore; device components
that differ from CPU islands), so steps (2)–(4) are order-changing without device-owned activation state. Kept as
the audit mode `PHYSX_DESTRUCTION_DEVICE_SLEEP=8`; the integrate → stress gap (1.95 ms per pass) stays.

## 15. R5 route refined from the measurements (2026-09-17): dormant masks, no island parking

Why the corrected pass is worth ~13 ms of the 20.5 ms tick: an idle tick costs 1.1 ms, so the
pipeline's cost is per active body and pair (10k bodies, 300k pairs), and the closure of a sustained
correction is under 0.5 % of islands. Why parking failed: deactivating and reactivating islands in the
island sim removes and re-inserts their partition edges (68 vs 54 ms late window). Why mode 4 failed:
freezing bodies on the device left the CPU pipeline and the narrowphase running over the whole scene.

Route that follows from both: a per-body *dormant* flag for the corrected pass, consumed by the stages
in cost order and never touching the island sim or the partition structure:
1. Narrowphase: pairs with both bodies dormant are not re-tested and keep their trial outputs
   (`resetDestructionContactCaches` must skip them too); the pass-test lists are filtered per bucket
   with output indexing unchanged. This is the largest item (300k pairs).
2. Constraint prep and solve: edges with a dormant body are skipped in prep; the solver's body update and
   integration skip dormant bodies (mode 4 already removes them from the active list).
3. Post-solve host work: body status and sleep checks skip dormant bodies.
4. Broadphase: dormant bodies keep their trial-end bounds (the scoped restore already leaves them);
   affected bodies' restored bounds are tested against those. This is the one deviation from the
   trial-start/trial-start rule: it changes an overlap only when a dormant body moved across an affected
   body's bound within one tick, which is physically the state the next tick would see. Order-changing
   under §11; the ensemble protocol judges it.
5. Corrected stress solve: components of dormant clusters are already skipped by the exact certificate.
Expected: the corrected pass falls from ~11 ms toward the idle-tick floor plus the closure's work
(2–4 ms), i.e. −7 to −9 ms per sustained tick, the only remaining item of that size. Cost: NP and
solver kernel surgery across PhysX GPU buckets, multi-week; acceptance needs the owner's confirmation
of the §11 ensemble rule because the result is not bit-comparable.

Addendum (increment 1 result, 2026-09-17): a dormant broad-phase alone is neither exact nor faster
(the corrected broad phase tests trial-end bounds and its cost is the created-handle/refilter region
path), and removing dormant bodies from the solver alone (mode 4) is slower. The narrowphase step is
the one that has to come first, and its scope is now known: for the city scene only the box-box,
box-plane and sphere kernels plus the manifold reset and the output compaction iterate the pair
lists, but retaining trial outputs for untested pairs crosses the per-pass double-buffered contact
and patch streams (dormant pairs would point into the previous pass's buffer while the solver, the
loads and the compaction read the current one). The dormant design therefore needs a per-pair
"retained output" indirection in the stream pools before any kernel skip pays off; that is the first
real R5 work item, and it is multi-week.

Correction to the addendum (same day, from the node-level kernel trace): the narrowphase kernels are
not where the corrected pass spends its time. Per pass, `boxBoxNphase_Kernel` is 0.17 ms, the
sphere and plane kernels 0.01 ms, the manifold reset 0.002 ms; the contact-constraint prep is 0.5 ms,
the solver about 1.2 ms, the broad phase 1.5–2 ms. All GPU kernels of a corrected pass sum to about
4 ms of its 11 ms; the other 7 ms are the CPU sides of its ~15 stages (activity restore 1.2, AABB
manager update and DMA, narrowphase result processing over all pairs ~1, island and partition update
~1.5, post-solve body status and sleep work ~2, sleep commit 0.5, acceptance 0.3) and their launch
and wait latencies. A dormant mask therefore pays only when it filters the CPU per-body and per-pair
loops of those stages (Sc and Pxg, dozens of sites), not when it skips device kernels; skipping the
narrowphase kernels alone (with retained outputs) would save ~0.15 ms per pass. That reorders the R5
work: first the CPU-side filtered lists (activity restore, NP result processing, post-solve body
status, island maintenance), then constraint prep and solver skips, then the broad-phase insertion
fast path. Expected value is unchanged (−7 to −9 ms per sustained tick) and so is the cost.

## 16. Impact-tick program, state after the first day (2026-09-17)

User decisions recorded the same day: no artificial caps on simultaneous destruction, one long frame
per mass event is acceptable, the same-tick correction is mandatory, and the CPU-visible publication
may lag a tick. Shipped since §13 (all lossless, histories identical on the five counters):

| change | sustained mean | 256-impact tick |
|---|---:|---:|
| state at §13 | 23.0 ms | 134 ms |
| no-op acceptance transaction skipped (was joining the refactor burst) | 21.9 | 129 |
| pipeline streams above least priority, device copies as kernels | | |
| burst flushed after the binding readback | 21.7 | 116 |
| corrected pass's burst flushed immediately (late-flush flag had deferred it) | 21.6 | 114 |

Findings that bound the rest of the impact tick (warm-screen.md has the probes): on this GPU and
driver nothing from other streams is dispatched while the fresh-factor burst runs, whatever the
priority, residency or chunking, so the burst's ~22 ms (256 buildings) is hidden only where the CPU
works alone; the corrected broad phase's 12–19 ms is `performIncrementalSAP` undoing the trial's
motion of thousands of scattered chunks (refiltered shapes are marked "new" for overlap discovery
but not re-inserted; no bounds are created at fracture); the CPU bookkeeping (allocation 8, migration
13, registration and island insertion ~8, publication 7 ms) is the R2 registry migration.

Order of the remaining program, per the user's decisions: CPU record creation and publication may
be moved off the tick (a tick late) but the device-side corrected pass must not change; then R2
steps 6–7; then R5 dormant masks for the sustained corrected pass.

## 17. R5 dormant corrected pass: the exact recipe, and why mode 4 still loses (2026-09-17, session e)

Mode 4 (frozen bodies removed from the solver, CPU pipeline untouched) re-measured on today's build: 23.65 vs
22.34 ms mean, 60,004 bonds (inside the §11 mild range). The corrected pass gets slower, not faster: every
CPU stage still walks the whole scene and the frozen bookkeeping adds ~1 ms. The route that pays is a
per-body *dormant* flag consumed by every stage, and the analysis below fixes what "exact" means for it.

**Affected set.** PhysX evaluates broad phase and narrowphase at start-of-step poses. The corrected pass
restores start-of-step poses, so its pair set equals the trial's pair set (fragments inherit their chunks'
shapes; the only new pairs are intra-fracture chunk pairs found by the refilter). Islands are formed by
touching pairs, so the affected set A is exactly the trial islands containing a fractured body, plus the new
fragment bodies; no iterative closure is needed (Vibe's divergence came from a different treatment of
bounds, below). Everything else is dormant, D.

**What D keeps.** Its trial end-of-tick state: body pose/velocity/sleep data on the device, CPU activity
and wake counters, island edges, contact manifolds and friction patches, narrowphase outputs and touch
status. A keeps the shipped semantics (restore to start of step, cold contact caches, re-run).

**Pairs across the boundary.** Every A–D pair is non-touching (a touching pair would have merged the
islands). In the corrected pass those pairs must produce no contact and no touch event, whatever the
narrowphase computes with d at a wrong pose; D–D pairs must produce no event either. The cheap exact
implementation: run the corrected broad phase and narrowphase with *all* transform-cache and bounds entries
restored to start of step (as today; only the body-sim state of D is left at trial end), so every pair's
narrowphase inputs are identical to the trial's and its outputs are bit-identical; then skip the CPU touch
processing for pairs without an A body (their events already fired in the trial), neutralise D's
constraints in prep (the existing parked-contact path keeps their trial writeback), skip D in integration
and in the post-solve body status and sleep checks, and let the post-integration cache/bounds update (which
covers all active bodies) put D's cache and bounds back to trial end. The corrected broad phase then moves
no D box (its bounds are at start of step in the SAP and in the bounds array alike) and reports only A's
deltas. Nothing depends on the island sim being parked, so the partition structure is untouched.

**Bit-identity and acceptance.** A's results are independent of D's presence (constraints are applied per
island in partition order; neutralised D constraints keep their batch slots), so a dormant pass reproduces
today's corrected pass for A bit-for-bit while D keeps warm trial results instead of a cold re-solve. The
five-counter identity therefore cannot judge the first dormant build (D's results differ from today's cold
re-solve by construction); the §11 ensemble judges it once, and every later cost-cutting step is judged by
identity against that first build. A slow reference (full corrected pass, then D's device state and pair
outputs overwritten from trial snapshots) would give the same semantics for cross-checking but needs
snapshots of the manifold and friction buffers (~60 MB per pass), so it is a debugging tool, not a default.

**Cost model.** Sustained corrected pass today ≈ 11.5 ms: restore 1.1, broad phase 2.7, registration 0.5,
narrowphase 1.3, island/partition 1.2, lost contacts 0.6, solver and integrate wait 3.1, body status and
sleep 1.0, acceptance 0.3. With D dormant: restore scoped (exists), broad phase ~1.3 (A's boxes plus the
fragment refilter), narrowphase kernels unchanged (0.2 ms) but result processing scoped, prep/solver over
A's constraints only, integrate over A, body status over A. Expected −6 to −8 ms per sustained tick; the
work is the per-stage filters (Sc and Pxg, dozens of loops) and the neutralisation of D's constraints
without renumbering the solver bodies (mode 4 renumbered, which is what made even isolated bodies
non-comparable). Multi-week; the first increment is the CPU touch-processing and body-status filters,
measured with the ensemble protocol.
