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
