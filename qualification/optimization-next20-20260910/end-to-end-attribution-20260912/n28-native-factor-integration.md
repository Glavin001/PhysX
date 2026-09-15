# Native factor sharing: integration contract and next decision

Status: source audit and bounded setup experiment prepared; no native implementation or application improvement. Previous goal turn made progress by executing the GPU feasibility probe and changing the next decision. Current work preserves the full optimization goal.

The captured city25 input has 25 equal anchored coefficient systems in its first pass and 25 equal systems in correction, with different loads and different operators between passes. Shared full factors can remove repeated iterative applications, beyond the existing per-node inverse reuse. First-use analysis costs about 47–50 ms in the initial probe; reused factor application takes about 0.34–0.42 ms for 25 loads. Native integration is worthwhile only if preparation and invalidation costs fit the complete-step budget.

## Source-derived boundaries

`StressResidentAPI.inl::solveDeviceAsync` joins the current producer event and consumes the existing shared GPU input array. `StressGraphExecution.inl::executeSolve` currently captures `launchSolve` as one graph. `StressSolveSubmission.inl` initializes loads, tolerance, recurrence and output before/after resident iteration. `StressIterationDispatch.inl::launchPersistentStress` initializes the accurate warm residual, runs component/cooperative iterations and combines their status. `StressNativeSolution.cuh` performs final bond-force recovery. Preserve these producer/consumer and physical verification boundaries.

`StressInverseTopology.cuh::refreshNativeInverseValidity` already records the key invariant: resident offsets, coupling scales and inertia are immutable; accepted bond removals invalidate incident operators. Host mutation paths in `NvBlastExtStressGpu.cu` reject an enabled resident topology. `StressResidentAPI.inl::updateDeviceTopologyAsync` submits the accepted mask/generation. This permits topology-bound factor invalidation, without uploading all coefficients or hashing all nodes on every solve. It does not grant permission to reuse numerical outputs when loads change.

## Proposed ownership

1. At asset preparation, identify exactly equal immutable coefficient descriptions with canonical local node/bond order. Hashes only select candidates; compare complete descriptions before sharing. Do not infer equality from a building label, node count or topology shape alone. General graph-isomorphism matching is unnecessary for correctness; missed sharing remains valid work.
2. At an accepted topology update, preserve factors of unchanged old components. Changed components receive new live-bond and dynamic-row descriptions. Distinct anchors, connectivity and retained row order are part of the identity. Never reuse numeric factors solely because sparsity matches. If the API later admits mutable coefficients, it must invalidate this ownership too.
3. The GPU prepares each current right-hand side, including the existing warm bond contribution, after the current physics producer event. GPU mappings gather multiple loads into shared-factor batches. Solved node corrections remain on GPU for original force recovery, material evaluation and correction logic. Do not add a full-world load download/CPU assembly/reupload on every tick.
4. cuDSS analysis is synchronous and may use CPU reordering, so new patterns need an explicit setup boundary outside graph capture. Cached compatible factor/solve work can be captured only with a supported memory handler and lifetime. A prepared matrix is not a solved current load. Future scheduling may prepare load-independent topology factors while other work proceeds, but solving must still join the current physical inputs and validate the exact coefficient identity.
5. Factor storage is immutable while referenced by any launch; invalidate ownership transactionally and release only after consumers finish. Scope numerical caches to a CUDA context and solver lifetime. Snapshot physical restore clears numerical cache validity; reusable allocation capacity must not secretly retain factors and remove work from a cold-tick measurement.
6. Retain the existing zero-update equilibrium certificate. Skipped equilibrium still does not imply skipped damage. A newly computed direct correction cannot issue a certificate claiming the previously stored rounded forces were already verified; subsequent rounded-force verification remains necessary.

The concrete certificate issue is in `componentStressSolve`: it currently sets
`verifiedStoredOutput` from `warmStart && converged && iterations==0`. That relies
on the node correction starting at zero. Installing a direct correction before
this check would violate that premise, even if the mathematical solution passes
the normal gradient threshold. Integration must first monitor the existing warm
forces, solve only the still-active components, and distinguish seeded/direct
updates when issuing certificates. Otherwise it can either certify an unverified
rounded result or repeatedly solve unchanged warm components and lose existing
idle skips. A shared factor is not itself an equilibrium certificate.

cuDSS matrix dimensions and RHS count are host descriptors, while the native
active-component count is device-owned. Do not introduce a hot CPU count readback
without charging and comparing it. Fixed-capacity GPU-packed RHS batches or
captured size buckets need explicit treatment of inactive columns and conditional
all-clean skipping. A custom device-count-aware factor application, potentially
using Tile for batched arithmetic, remains a distinct implementation option.

Sparse direct solving applies to certified anchored positive-definite systems. Free components need their existing nullspace treatment or a separately qualified projected direct method. A structural algorithm policy may use different solvers for different component sizes and sharing opportunities, with the same final quality. A failed or unsupported solve must not be silently reported as converged.

Selected direct components should ultimately omit their unused iterative
preconditioner construction and recurrence storage/work. Retain topology,
current-load preparation, convergence verification and material evaluation.
An initial integration that still builds both numerical paths must expose that
duplication in its stage accounting; it is not the final ownership architecture.

## Measurements that decide the next implementation

The prepared experiment in `out/native-shared-factor-setup-20260912/` destroys and recreates cuDSS symbolic/numeric state ten times per captured pass, keeping only the initialized context/library and input storage. Each round charges analysis, numeric factorization, solve and data-object lifetime. First-use samples remain visible. This determines whether the initial 47–50 ms is mainly recurring operator work or first-use library cost. No topology-changing simulation or application savings are established by this probe.

Support: new-operator work is well below the measured native iterative stage, with all independent reference and rounded-force gradient checks passing. Refute: recurring setup still consumes the candidate saving, graph/host coordination erases it, or material/physical qualification fails. Planning range remains 0–30 ms active-city full-step saving, low confidence and not additive to prior cohorts. Exposure outside this one city25 snapshot remains unmeasured.

Native qualification then requires charged grouping/mapping/analysis/factor/solve/recovery plus normal graph/event handling, seven-case light A/B/A, all52 physical/timing scenarios, asynchronous memory checks and continuous ordinary/sleeping idle and heavy trajectories. Current application measurements remain [N27's seven-scenario confirmation](n27-confirmation.md); no factor-sharing full-step results exist.

## Corrected probe convergence accounting

The first probe checker compared node residual norm with the captured threshold. That was not the native convergence rule. It now checks `||B^T (rhs - B force)||^2` against the captured squared threshold, both before and after FP32 force rounding. All100 first/final solutions still pass; worst unrounded ratio is 7.19e-16 and worst rounded ratio is 0.008280. This is a corrected diagnostic interpretation, not a changed tolerance. Material response and physical-unit force gates remain separate and pending. Original checks are preserved in `quality.pre-gradient.json` and `check-quality.pre-gradient.py`.


## Native implementation preparation

Isolated source commit `2b1d762645a4728e8ac48fa3369eee1274156927`, parent selected N13+N20 composition `13b11af2e0aeabf4e0070931fbd8a060f383dfaf`, adds `StressSharedFactorPlan.h` and a native capture adapter. The planner groups complete canonical coefficient descriptions and assembles one sparse matrix per exact group. Inputs contain no loads or warm guesses. Positive health magnitude does not enter the resident operator; health liveness and coupling scale do. Member node/bond mappings are retained for later GPU packing/scattering. Prescribed and free boundaries remain distinct, and an anchor flag alone is not a positive-definiteness certificate.

This is preparation/topology code, not a new full-world scan inside each tick. For incremental updates the caller must supply affected component data with a corresponding global mapping; native runtime wiring remains unfinished. No cached factor may survive physical restore validity reset. The header is currently unreferenced by production translation units, so this commit changes no simulation behavior.

Build and offline qualification are complete: release, ASan/UBSan, analytical/negative checks and200 independent native component-matrix comparisons pass. The module is not runtime integrated. Fresh cuDSS setup remains expensive; the supported hybrid route is slower and rejected. See [completed results](n28-results.md) and [large-scale duplicate-work census](n28-duplicate-census.md). Existing main index/source, installed SDK and selected implementation are preserved.
