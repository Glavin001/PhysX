# Private stress solver implementation sections

These files are included in order by `NvBlastExtStressGpu.cu`, inside its existing
anonymous namespace. The `.inl` member sections are included inside the existing
solver class, preserving member order, access and implicit inlining. These are
**not** independent CUDA compilation units or public headers. Shared types/math
helpers precede the kernel includes. This preserves device inlining and avoids new imports,
exports, linking boundaries or relocatable device code.

| File | Responsibility |
|---|---|
| `StressCouplingKernels.cuh` | Coupling operator, residual initialization, solve setup |
| `StressNodeOperator.cuh` | Sparse node-space operator and its shared mathematical body |
| `StressNodePreconditioner.cuh` | Existing reference block-Jacobi kernels |
| `StressNodeIteration.cuh` | Direction, solution and residual updates |
| `StressTopologyUpdates.cuh` | Existing sparse topology/CSR patch kernels |
| `StressIslandReduction.cuh` | Per-component reductions, convergence and retirement |
| `StressBondIteration.cuh` | Existing reference bond-space iteration kernels |
| `StressDeviceIO.cuh` | Device output conversion and active-work flags |
| `StressMaterialKernels.cuh` | Existing material/stress evaluation and removal compaction |
| `StressResidentIteration.cuh` | Production cooperative iteration for large connected components |
| `StressComponentIteration.cuh` | Independent single-block component iteration, producer-owned norm reductions and combined completion status |
| `StressSolverLifetime.inl` | Construction, destruction and release |
| `StressResidentAPI.inl` | Device solve, device views and GPU topology API |
| `StressBufferAllocation.inl` | Required buffer allocation and initial state; omit unused reference-only storage |
| `StressIterationDispatch.inl` | Iteration launches, cooperative dispatch and reference conditional loop |
| `StressSolveSubmission.inl` | Ordered numerical stages of one solve |
| `StressGraphExecution.inl` | Graph validity, capture, instantiation and execution |

The initial split is a literal extraction: expanding these includes reproduces
the pre-refactor source exactly after removing the two fragment header comments.
The reference routines remain where they were logically; extraction does not
make a legacy path part of native execution or remove one that existed before.

Subsequent numerical/performance edits are qualified separately from the initial
mechanical split. The native allocation path now omits unused bond-space and
Jacobi work arrays; `nodeSpaceReset` accepts a null optional Jacobi vector. The
original extraction hashes describe the extraction commit, not later edits.

## Resident multilevel construction (integration in progress)

`StressHierarchyKernels.cuh` and `StressHierarchyGraph.cuh` are private headers
with their own `Nv::Blast::StressHierarchy` namespace. They are currently compiled
by the independent qualification target, not the production solver.

One cooperative kernel builds connected star aggregates and their sparse coarse
factor entirely on the GPU. Minimum member IDs identify aggregates; these are
preconditioner groups, not physical rigid clusters. Fixed nodes never merge
otherwise independent dynamic components. Device generation and acceptance
control rebuilds; unchanged/rejected transactions do not modify committed output.
A failed build sets an error and does not advance the generation; consumers must
reject its output. Buffers are persistent and execution is CUDA-graph capturable.

For the existing operator `L = B B^T`, `B = D C S`, prolongation `P` maps a coarse
rigid basis at the aggregate origin into mass-scaled fine coordinates. Thus
`D P` is the rigid basis, and the stored coarse factor is exactly `B^T P`: shifted
bond offsets, original column scale and unit coarse inertia. Keep internal
self-edges because rounded fine offsets can leave nonzero coupling. Coefficients
are stored in double precision; this construction does not change the native
solver's arithmetic. The caller must advance the operator generation for changes
to topology, support, geometry, scales or inertia; its exact GPU component labels
and immutable CSR must describe the same accepted state.

The test independently checks connectivity, minimum IDs, full-basis factor
equality, static boundaries, restore/split generations, rejected transactions,
explicit invalid-input errors and a 100,000-node sparse graph. This verifies
construction, not preconditioning convergence or an end-to-end speedup.

`StressHierarchyOperator.cuh` now provides resident prolongation, transpose
restriction and sparse coarse application. Each star member records one bond
back to its seed during aggregation. Traversing the seed's existing adjacency
then enumerates members exactly once, including with parallel bonds. This avoids
a sorted membership copy and floating atomic sums. Warp reductions follow fixed
CSR order; nonleader rows are overwritten with zero by their owning warp.
Coarse application gathers the original adjacency and exact coarse factors,
without a temporary per-bond vector. It retains rounded self-edge contributions.

Construction validates borrowed mass scaling and position data before committing
the generation. Operators read the same accepted views without changing shared
status. Inputs/output must be distinct, and the caller must preserve all borrowed
views until stream completion. The independent test checks P, P^T, P^T L P,
adjointness, nonnegative energy, repeatability and six coherent free rigid modes
with 2e-12 scaled comparisons. This is still an integration foundation: no native
preconditioner or simulation speedup is claimed.

`StressHierarchyDiagonal.cuh` is included inside the construction namespace.
It builds one exact 6x6 fine diagonal block per chunk directly from borrowed
bond coupling, using a warp to hold its 21 lower-triangle coefficients. The
warp performs Cholesky and retains the factor, not a dense inverse. The operator
header supplies a warp-cooperative forward/back solve suitable for inclusion
in a resident V-cycle. Fixed and truly uncoupled rows have zero pseudoinverse.
Nonpositive or nonfinite numerical pivots reject construction; no identity
fallback, diagonal regularization or reduced physical work is substituted.

For the original two-endpoint factor, each bond obeys
`||a-b||^2 <= 2||a||^2 + 2||b||^2`. Thus `0 <= L <= 2J` for its exact block
diagonal J; on nonzero rows the normalized operator has eigenvalues at most 2.
This gives a certified damping interval for the upcoming fine smoother without
a CPU spectral estimate. It does not prove the spectrum of an arbitrary
smoothed/assembled next-level operator, which needs its own bound.

The native topology excludes isolated dynamic rows as well as fixed rows. The
hierarchy accepts these zero rows, and rejects an excluded dynamic row with a
live incident bond. Active hierarchy rows require positive finite angular and
linear scaling; partially constrained coordinates require a different basis and
are explicitly rejected here. Native coordinate upload must use the same length
normalization as existing offsets; it belongs to asset preparation, not solves.

Construction status error bits are 1 for invalid/inconsistent topology, 2 for
nonfinite geometry/bond coefficients, 4 for a stale generation, 8 for invalid
mass scaling, and 16 for an unfactorable local diagonal. Multiple errors may be
combined. Consumers must reject an error before using any hierarchy result.
The local factors alone do not constitute the multilevel preconditioner: its
recursive levels/coarse solve and production CGLS wiring remain unfinished.

## Recursive packed levels

`StressHierarchyViews.cuh` shares access to original fine inputs and exact
double coarse factors. Recursive positions reference persistent authored
origins; no float conversion of coarse coefficients is performed. Actual counts
are device views bounded by allocated capacity. Error bit 32 rejects invalid
counts or an uncommitted/error/stale upstream generation.

`StressHierarchyPacking.cuh`, `StressHierarchyPackingPrimitives.cuh` and
`StressHierarchyPackedLevel.cuh` compact nodes/bonds and build canonical CSR in
one cooperative kernel. Block scans and stable tiled radix passes share
persistent scratch. Only used rows/edges are traversed, with at most one padded
radix tile. Exactly zero coarse columns and their unused variables are retired;
nonzero self-edge moment terms remain. Original fine physical state is unchanged.

The graph is prepared once and replayed through GPU generations. Cooperative
construction snapshots validation decisions before another stage can write the
error flag; all blocks must take the same grid exit. Coarse input generations
must match their committed upstream status. The private `Graph` distinguishes
fine and recursive roles so fine-only diagonal storage is not allocated for
recursive levels. Calling the fine-only diagonal kernel on a coarse view fails
explicitly. Terminal/coarse factors are not implemented yet.

Remaining integration work: classify terminal components on the GPU, construct
and apply small null-space-safe factors, build coarse smoothers, and run a symmetric resident V-cycle twice in
the preconditioned CGLS recurrence. Its authoritative fine operator and stopping
test must remain unchanged. Fine inertia/position normalization must match the
existing asset-preparation scale. Native convergence/fracture and full-step
timing gates are required before claiming a production improvement.


`StressHierarchyTransfers.cuh` restricts and prolongs directly between parent
and compact child vectors. Persistent `nodeSource` maps each compact child to
its parent root; `nodeMap` supplies the inverse mapping. Transfers retain the
same rigid basis and its exact transpose, including inertia scaling. Retired
exact-zero coarse rows contribute zero. No parent-sized intermediate vector or
copy pass is needed.

`StressHierarchyLevelOperator.cuh` applies the current level's operator through
its own compact CSR. It shares the coupling/transpose equations and exact
double coarse coefficients, including both contributions of nonzero self
edges. This supplies the residual operation required by a resident V-cycle;
`applyCoarse` remains the next-level Galerkin qualification operator. Tests
compare both directly against independently composed original fine equations.
