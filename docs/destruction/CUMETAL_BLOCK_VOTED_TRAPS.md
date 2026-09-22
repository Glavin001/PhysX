# Experimental CuMetal block-voted terminal traps

`PX_CUMETAL_BLOCK_VOTED_TRAPS` is **OFF by default and unqualified**. The matching build-helper option is `--cumetal-block-voted-traps`. It requires `PX_GPU_BACKEND=CUMETAL` and `PX_CUMETAL_COOPERATIVE_SINGLE_BLOCK=ON`; direct CUDA configurations and a disabled compiler launch contract are rejected. No NVIDIA default, numerical equation, tolerance, correction limit, warm-start format or public consumer ABI changes.

## Mechanism and scope

The kind-3 terminal case in `StressHierarchyTerminal.cuh::solveTerminalComponent` is an error: its component belongs to the separate native fine solver and must not be dispatched as a multilevel terminal. The option preserves that trap. Each thread first checks owner equality and reads `kind` only when owned. A real full-threadgroup `__syncthreads_or(kind == 3)` occurs **before either owner/kind early return**. All existing callers traverse each component with the full block; valid CUDA collective participation and stable descriptor ownership remain prerequisites. This is not a proof that arbitrary divergent source insertions or corrupted/aliased descriptors would be safe.

The same option caps precisely these host launches at one block:

- `TerminalLevel::apply`: `applyTerminals`; construction and its append graph are unchanged.
- `ResidentCycle::blocks<Passes>`: cooperative `applyCycle<1/2>` and ordinary `applyComponentCycles<1/2>`.
- `launchPersistentStress`: only the hierarchy-preconditioned `persistentStressSolve<true>` launch, selected by `m_deviceTopology`.

Existing grid-stride/virtual-work loops process the complete node/component/island workload. `componentStressSolve` currently uses the polynomial preconditioner and keeps its independent multi-block schedule. `persistentStressSolve<false>` does not call terminal solving and keeps its existing scheduling. The option does not change iteration counts or convergence/retirement decisions. In the one-block preconditioned persistent solver, a block-wide AND vote explicitly publishes the existing uniform retirement result before entering the collective preconditioner. The CUDA/default branch keeps its original retirement expression. This execution hint restores all-warp participation in the current CuMetal translation; it does not establish a general compiler control-flow fix.

Native host and device compilation receive the same definition. CuMetal must independently recognize the block-voted trap and encode `max_grid_blocks=1` in native registration, including ordinary affected kernels with no grid-sync call. Runtime validation must reject larger launches both before capture and at replay. The source cap alone is not sufficient to establish safe execution.

## Qualification still required

The compiler must preserve Clang CUDA `__trap()` inline assembly as an actual trap; silently converting the error to a return is incorrect. Collective lowering must publish the existing asynchronous device error and return the whole block together, without per-lane cancellation polling around later barriers. Changing an error into ordinary nonconvergence is prohibited.

Before enabling the option by default: qualify the compiler's healthy/trapping 96- and 128-thread native fixture, sticky `cudaErrorLaunchFailure`, guards and withheld post-trap writes, native launch bounds through ordinary/cooperative/capture/graph paths, and the original production stress translation unit. Then run the existing hierarchy reference/symmetry/linearity/squared-cycle tests and integrated stress/destruction cases with unchanged precision/tolerances, correction limits and warm starts. A successful compile is not numerical qualification, and a playable video is not a performance measurement.

One-block scheduling can change floating-point summation order in existing multi-block stress reductions even though all terms and equations remain present. Existing numerical oracles and tolerances must decide acceptability; do not claim bit identity or relax the convergence policy. Large workloads may become substantially slower. No speed or real-time claim follows from this execution hint.

The build manifest records whether the hint is enabled, its unqualified status, one-block bound and affected scope. The ordinary build remains non-installing; use the repository helper's dry run/check and explicit test/install actions as usual.

## Standalone fine-diagonal qualifier

The same hint covers `applyFineDiagonal`, whose fine-only factor misuse remains
an explicit device error. All block lanes vote on whether an active node has
`levelBonds` before any tail exit. Zero-node dispatches do not trap. The hinted
path iterates complete nodes with whole-warp grid strides, preserving every
6x6 triangular solve and its FP64 operation order; its hierarchy-operator test
caller launches exactly one block of 256 threads. The original CUDA/default
body and launch grid remain unchanged. Native registration must still enforce
the one-block bound independently of this caller.

The existing full-mask warp solver requires a one-dimensional block with a
positive multiple of 32 threads; the supported caller and dedicated fixture
use 256 threads, with block/grid y and z equal to one. The native one-block
metadata does not enforce this block-shape prerequisite. The hinted node loop
tests the remaining node count before incrementing, avoiding unsigned wrap at
the count limit while keeping the exit uniform within each warp.

The dedicated `tools/tests/cumetal-fine-diagonal.cu` fixture is intended to
qualify node tails, multiple warp iterations, the existing all-lane reference,
an independent dense-system CPU oracle at the unchanged 2e-12 tolerance, output
guards, queued graph snapshots and an isolated sticky-failure process. Source
and fixture availability are not evidence that these checks have executed.
