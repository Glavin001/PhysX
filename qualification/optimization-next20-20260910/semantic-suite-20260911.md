# Semantic complete-tick suite — 2026-09-11

The suite contains **24 executable cases: 16 events/states extracted from actual integrated native simulation runs and eight deliberately authored structural cases**. These are representative game-physics fixtures, not captures from a deployed game or measurements of physical buildings. All24 were observed in the first N13 GPU discovery campaign. Ten independent repetitions per case are complete; all24 predicates pass. See [the measured results](semantic-suite-results.md). No candidate comparison or snapshot-restore qualification is claimed.

Each sample is a full accepted tick reached by a fresh process and its frozen simulation prefix. This is **not full-state snapshot restoration**. It removes ambiguity about which event is measured and avoids advancing the same mutable world repeatedly as if the inputs were unchanged. It still pays the prefix in benchmark wall time. The prefix is reported separately from the selected tick, alongside initialization; we do not claim that this harness yet provides cheap constant-time replay.

The geometry harness uses retained N13 runtime `c1e6faca7af6cba0e65c215d7a8710c5bf3ebf59`, runtime SHA256 `09c96cde6bd60f931fce36f8f4623faf9a624221ab6fcc757b4aa7ee3fc5c8f6`. It adds authoring to the native demo; no numerical kernel, correction policy, tolerance or installed SDK was changed. Source CUDA remains the preserved unaccepted N14 experiment. The new isolated consumer is `out/semantic-suite-20260911/N13-geometry/`.

## Cases and purpose

The tick indices below were frozen from reference discovery before repeat measurement. They are zero-based. Selection depends on physical predicates, never on a timing maximum. R11 is deliberately labelled a subsequent fracture episode: its CSV cannot identify the projectile/contact participants needed to certify rear-wall penetration at that precise tick.

| ID | Case | Tick | Why this case matters |
|---|---|---:|---|
| R01 | Single building: first gravity equilibrium | 0 | Small-work launch/setup floor. |
| R02 | Single building: intact quiescence | 60 | Unavoidable full-tick cost when valid equilibrium can be reused. |
| R03 | City: first gravity equilibrium | 0 | Setup and independent-component scale at 113664 authored chunks. |
| R04 | City: intact quiescence | 60 | Does idle cost grow with retained geometry despite no changed loads? |
| R05 | City: projectiles in flight | 60 | Moving non-destructible bodies with intact stress state; CPU/GPU coordination control. |
| R06 | City: first fracture and correction cascade | 82 | Current-contact stress, fragmentation, correction and second verdict on the critical path. |
| R07 | City: changed loads on fractured topology | 83 | Numerical work without new topology edits; warm-start opportunity. |
| R08 | City: later mass fracture burst | 100 | Large topology transaction after fragmentation has already increased component counts. |
| R09 | City: dense fragment contacts | 106 | Contact/ownership/publication cost with more than 200000 reported contacts. |
| R10 | Wall: first puncture fracture | 17 | Localized onset in the existing geometric penetration fixture; small active topology. |
| R11 | Wall: subsequent fracture episode | 32 | Repeated fracture and invalidation on already damaged geometry; participant trace needed to attribute rear-wall penetration. |
| R12 | Wall: moving fragments after impact | 120 | Late small-component rigid motion and continued equilibrium; not labelled settled. |
| R13 | 16 buildings: first correction cascade | 82 | Intermediate parallelism; compare scaling against city onset. |
| R14 | 16 buildings: loaded fractured state | 83 | Moderate component population with changed loads and no topology transaction. |
| R15 | 16 buildings: fragment contact burst | 84 | Coordination scaling versus the large contact burst, not just total bond count. |
| R16 | One localized impact in a retained city | 17 | Sparse active work within large authored state; exposes global scans/transfers. |
| S01 | 32-node vertical chain | 0 | Short acyclic load path; compare tree algorithms to long-chain scaling. |
| S02 | 256-node vertical chain | 0 | Long load propagation and convergence difficulty without redundant bonds. |
| S03 | 64-node horizontal cantilever | 0 | Bending moments and force/torque coupling over a long path. |
| S04 | 12 cubed solid block | 0 | 1728 nodes and many redundant local cycles; bond work versus node work. |
| S05 | 64-storey hollow frame | 0 | Tall building with slabs and loops; height and bending versus the default 12-storey asset. |
| S06 | 32 by 32 corner-supported panel | 0 | Wide load redistribution with only four supports and many cycles. |
| S07 | 64-span hollow bridge | 0 | Two supported ends, redundant paths and long-span bending. |
| S08 | 128-high ladder with sparse rungs | 0 | Long paths with controlled extra loops; separates chain length from redundancy. |

The synthetic structures use contiguous box chunks and physical neighboring bonds. Supports and gravity create their loads; no fracture or stress result is prescribed. Their separately authored material-strength scale is1000 and frame multiplier1 so the gravity-equilibrium cases remain intact. This does not change the established wall/city inputs (24/40), solver tolerance1e-5, iteration cap8192 or the one-correction limit. Keep every case's settings fixed in candidate comparisons. The chain pair probes path length; ladder versus chain adds controlled cycles; panel versus block changes support density and spatial load paths; bridge/cantilever add bending; tall frame extends the real building topology. These are cold equilibrium cases, with required preparation charged to the tick, not throughput claims for settled structures.

Independent authoring checks verify chunk/bond counts, connectivity, supports and unknown-subgraph cycle rank. Native convergence/correction gates passed on discovery. These facts do not independently qualify every new geometry's forces/material fidelity: candidate work must retain the existing independent force/moment/response/energy tests and add an appropriate oracle when it changes behavior on these structures.

## Coverage that must remain explicit

Four additional required cases remain open, beyond the24 executable cases: below-threshold contact without fracture; truly settled damaged topology; reawakening of that settled topology; explicit support loss. The current demo's impact completion gate requires fracture, so a subthreshold fixture needs its own appropriate invariant, not a blanket weakening of that gate. The existing N13 wall ends600 ticks with8 awake bodies and4 stress iterations; the city ends with1117 awake bodies and532 iterations. Neither is a demonstrated settled snapshot. A settled candidate must follow fracture and exhibit a sustained60-tick window with stable topology, no new commands, zero awake bodies and converged equilibrium; record current load/cache validity too. A fixed elapsed duration or zero new broken bonds is insufficient.

Current CSV structural counters describe the accepted tick's active stress topology, not a complete pre-tick input inventory. The authored graph census is separate. Richer captures must record supported/free component sizes, contact participants, pre-trial and corrected operator/load state and material damage before attributing a case to penetration, support loss or exact component topology. Existing frozen native load captures can supply diagnostic examples but cannot stand in for all these full-tick inputs.

## Timing and uncertainty protocol

1. Discover events once on the retained reference. Freeze fixture/command/settings hashes, selected indices, predicates and reference raw frame hashes. A repeated/candidate run uses those indices; a changed event fails its semantic predicate instead of selecting a different tick.
2. Use a separate process warmup and **10 independent process repetitions as a pilot**. Do not treat adjacent ticks or repeated calls without restoration as independent copies of one input. Keep all timing samples; never trim slow tails to manufacture stability.
3. From the pilot, choose the effect that matters in application milliseconds and the fixed size of a NEW confirmation campaign. The report includes a rough variance-based planning estimate for max(0.05ms,1%); this is an initial practical target, not an accuracy tolerance or power guarantee. Choose20,40 or100 paired repetitions as warranted, and freeze the count before inspecting confirmation results. If100 is insufficient, say inconclusive and address interference/measurement design. Do not keep sampling until a p-value passes.
4. Confirmation interleaves one adjacent A/B pair per fixture/block, with balanced randomized AB/BA order and randomized fixture order. Only one process uses this project's GPU at a time; wrappers share a lock. Preserve temperature, graphics clocks, utilization, memory and exact allowed process identities. Shared GPU measurements remain diagnostic. Do not stop the other project's server or claim that repetition removes its systematic interference.
5. Report every case's n, raw full-tick samples, mean/median, standard deviation/CV, observed maximum, exact budget counts and percentages. Descriptive mean bootstrap95 intervals appear only at n>=10; p95 is withheld below20 and p99 below100. These are sample-size conventions, not promises of tail precision. Maxima are observed maxima, never worst-case bounds.
6. Report paired savings in milliseconds and95% descriptive intervals, results split by AB/BA order, and a two-sided randomization test conditional on the actual balanced order allocation. Correct the full24-case family with Holm; never silently test only favorable cases. Ten pairs have very coarse randomization resolution and generally cannot support a suite-wide claim. Confidence intervals do not prove physical equivalence. Report regressions and output variation even when a mean improves.
7. Inspect temporal drift (including first/second-half diagnostics), order effects and A/A controls. Bootstrap intervals assume sufficiently independent repetitions; strong autocorrelation or changing interference makes them descriptive only. Use a fresh controlled confirmation session or block-aware analysis when that assumption fails. Do not remove hot/slow runs after seeing the candidate label.
8. Full-tick time includes commands, CPU work, current physics/contact processing, stress/material/topology, correction, waits/transfers and mandatory accepted completion. Required preparation remains charged; benchmark reconstruction/restore and optional recording are separately reported. Companion host/CUDA scopes explain the tick; nested GPU durations are not added to host waits. `physics_step_ms` includes destruction and is not stock PhysX time.
9. Verify discrete physical/command/contact histories and continuous force/moment/pose/energy quality. Report A/A numerical variation separately from A/B errors; never automatically enlarge tolerances. Continue multi-tick idle/heavy and endurance checks to expose startup, accumulated error and repeated invalidation.

Randomized interleaving is supported by the [Google Benchmark guide](https://github.com/google/benchmark/blob/main/docs/user_guide.md); blocking for nuisance factors follows the [NIST experimental-design guidance](https://www.itl.nist.gov/div898/handbook/pri/section3/pri332.htm). Those sources motivate the design; they do not predict a variance reduction for this GPU.

## Restoration work needed for cheap single-tick replay

The logical transition is a function of **complete** physical state and current commands; the engine is not currently implemented as a self-contained pure function. Inventory physical and implementation state separately:

| Boundary | State that must be restored or correctly reconstructed | Why it matters |
|---|---|---|
| Accepted rigid world | Poses, velocities, inertia/mass/COM, sleep/wake timers, kinematics, joints, shapes/filters, contact manifolds and physics warm-start history | Determines this tick's actual contacts and impulses |
| Destruction | Authored identities, live bonds/chunks, health/damage, topology, supports, motion ownership and generation/lifetime maps | Determines the operator and material decisions |
| Commands/correction | Pending ordered commands, original input history, ancestry, exactly-once stamps, tick/evaluation state | Prevents duplication, stale inputs or missing correction participants |
| CPU compatibility | Actor/shape/body registration, query bounds and publication state, allocator lifetimes | Required by ordinary PhysX and corrected collision discovery |
| Numerical caches | Operator keys/factors, warm solution/response history, convergence certificates | Physical validity and warm versus cold cost; never trust stale pointer bytes |
| Execution resources | Capacities, stream/event readiness, conditional graph/task bindings and scratch ownership | Avoids leaked state between repetitions; distinguish benchmark restore from mandatory setup |

A restore implementation must pass untouched-versus-restored one-tick AND short-continuation comparisons, restore A after B without contamination, and preserve cold/warm semantics across implementation changes. Existing `captureRigidState` is a correction checkpoint for selected arrays, not proof that this inventory is closed. Until then, fixed-prefix execution is the honest complete-tick reference. A post-contact stress replay is a complementary stage test, not a substitute for the full tick.

## Reproduce

Exact commands are in `OPTIMIZATION.md`. Raw discovery: `out/semantic-suite-20260911/discovery/`; repeated baseline: `out/semantic-suite-20260911/repeatability-10/`. The manifest, each command, loaded module maps/hashes, raw frame hashes, GPU samples and complete summaries are retained. `tools/scripts/report-destruction-semantic-suite.py` produces structured results. The existing600-step incumbent comparison remains separate; neither these prefixes nor synthetic cold ticks replace it. This is measurement setup, not a newly completed optimization experiment or a promoted N14 result.
