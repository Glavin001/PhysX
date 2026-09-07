// Copyright (c) 2026 NVIDIA Corporation. All rights reserved.

#include "NvBlastExtStressGpu.h"
#include "NvBlastExtStressFormula.h"

/// NV_NORMALIZATION_EPSILON, without dragging NvFoundation into the .cu.
#define NVBLAST_STRESS_NORMALIZATION_EPSILON float(1e-20f)

#include <cub/device/device_reduce.cuh>
#include <cub/device/device_radix_sort.cuh>
#include <cub/device/device_select.cuh>
#include <cub/device/device_scan.cuh>
#include <cub/iterator/counting_input_iterator.cuh>
#include <cuda.h>
#include <cuda_runtime.h>
#include <cooperative_groups.h>

#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <new>
#include <stdexcept>
#include <map>
#include <string>
#include <unordered_map>
#include <vector>

namespace Nv
{
namespace Blast
{
namespace
{

constexpr std::uint32_t kBlockSize = 256;

// Compare on the device against the actual last submitted loads. Match the
// host's float equality, including signed zero and NaN behavior. Static nodes
// have no island; their values are still copied into the persistent baseline.
__global__ void markChangedInputIslands(
    const ExtStressGpuImpulse* next, const ExtStressGpuImpulse* previous,
    const std::uint32_t* nodeIsland, std::uint32_t nodeCount,
    std::uint32_t* dirty)
{
    const std::uint32_t i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= nodeCount) { return; }
    const auto a = next[i];
    const auto b = previous[i];
    const bool equal = a.angular.x == b.angular.x && a.angular.y == b.angular.y
        && a.angular.z == b.angular.z && a.linear.x == b.linear.x
        && a.linear.y == b.linear.y && a.linear.z == b.linear.z;
    if (!equal && nodeIsland[i] != 0xffffffffu)
    {
        atomicExch(dirty + nodeIsland[i], 1u);
    }
}


/// BLAST_GPU_SKIP_DEBUG=1 traces the settled-island decision every 60 solves.
/// Kept in because "islands skipped = 0" has two very different causes -- the
/// mechanism is off, or the scene genuinely never settles -- and they are
/// indistinguishable from the aggregate telemetry.
const bool s_debug = std::getenv("BLAST_GPU_SKIP_DEBUG") != nullptr;

/// BLAST_GPU_WHOLE_RESET_ON_TOPOLOGY=1 restores the pre-incremental behaviour:
/// full warm-start memset + whole-baseline drop on every topology change and
/// every break. Value-checked kill switch for the incremental path below.
/// G1: gather instead of scatter in the right-multiply (default ON, =0
/// restores the atomic scatter).
///
/// The scatter wrote each bond's contribution into its two nodes with
/// atomicAdd -- 3 floats x 2 vectors x 2 nodes = 12 global float atomics per
/// bond, every iteration. That is the dominant cost of the solve (the code
/// said so itself) and it is also why the solve is not reproducible: float
/// addition is not associative and the atomic order is not deterministic, so
/// the same scene gives slightly different impulses every run, which is why
/// every experiment on this tree needs n>=2 arms and a noise floor.
///
/// The gather visits the same bonds and computes the same terms; only the
/// summation moves. Each node loops over its own incident bonds in a fixed
/// CSR order and writes its slot once, exclusively. No atomics, and the
/// per-node sum order is fixed by the topology, so it is reproducible.
///
/// MEASURED, AND IT DOES NOT PAY -- DEFAULT OFF. City-scale A/B, one binary,
/// alternating arms, n=2, in the `stress` bracket (medians, ms):
///
///                       at rest        under load (>800 awake)
///   scatter (atomics)   3.24  3.27     6.87  7.77
///   gather              3.95  3.56     7.12  7.90
///
/// Within-arm spread at rest is 0.03 ms, so +0.5 ms at rest is real, and the
/// load case is a wash inside its own 0.9 ms spread. The premise -- that the
/// twelve atomics per bond dominated -- was not supported: at 230k bonds the
/// atomic traffic spreads across thousands of distinct node addresses and
/// does not serialize the way a single hot address would.
///
/// Why it LOSES at rest: the scatter iterates the compacted ACTIVE BOND list,
/// which is nearly empty once islands settle, so it costs almost nothing.
/// The gather iterates active NODES, and a static node is never settled by
/// design (nodeSettled keeps kNoIsland nodes always live, because they are
/// boundaries shared by every island), so the gather walks the full adjacency
/// of every support node every iteration just to find that all of its bonds
/// are skipped.
///
/// Kept, off by default, for two reasons: it is proven correct (the
/// equivalence harness passes all eight checks, including identical
/// broken-bond counts on every tick), and it is the only atomics-free
/// formulation available if the determinism work resumes -- the reproducible
/// solve needs this half. Turning it on requires first making the active-node
/// list exclude nodes with no active bonds, which is what would restore the
/// compaction the scatter gets for free.
/// Per-kernel timing for the solve, because the external profiler is not
/// available here: ncu needs GPU performance counters, and the driver refuses
/// them without a host-level modprobe setting this container cannot change
/// (ERR_NVGPUCTRPERM). Rather than reason about the kernel mix from source, we
/// measure it.
///
/// BLAST_GPU_KERNEL_PROFILE=1 bypasses the captured graph and launches the
/// same kernels eagerly with a CUDA event around each, accumulating per-name
/// totals. Bypassing the graph is itself informative: the difference between
/// the graph total and the sum of the kernels IS the launch overhead the graph
/// exists to remove.
struct KernelProfile
{
    static constexpr std::size_t kMaxSlots = 512;
    struct Slot
    {
        const char* name{nullptr};
        cudaEvent_t start{nullptr};
        cudaEvent_t stop{nullptr};
    };
    std::vector<Slot> slots;
    std::size_t used{0};
    std::map<std::string, std::pair<double, std::uint32_t>> totals;
    bool active{false};

    void ensure()
    {
        if (slots.empty())
        {
            slots.resize(kMaxSlots);
            for (Slot& slot : slots)
            {
                cudaEventCreate(&slot.start);
                cudaEventCreate(&slot.stop);
            }
        }
    }

    void begin(const char* name, cudaStream_t stream)
    {
        if (!active || used >= kMaxSlots)
        {
            return;
        }
        ensure();
        slots[used].name = name;
        cudaEventRecord(slots[used].start, stream);
    }

    void end(cudaStream_t stream)
    {
        if (!active || used >= kMaxSlots)
        {
            return;
        }
        cudaEventRecord(slots[used].stop, stream);
        ++used;
    }

    /// Drain after a synchronize: event elapsed time is only valid once the
    /// stream has caught up.
    void harvest()
    {
        for (std::size_t i = 0; i < used; ++i)
        {
            float ms = 0.0f;
            if (cudaEventElapsedTime(&ms, slots[i].start, slots[i].stop) == cudaSuccess)
            {
                auto& entry = totals[slots[i].name];
                entry.first += static_cast<double>(ms);
                entry.second += 1;
            }
        }
        used = 0;
    }

    void dump(const char* label, std::uint32_t solves) const
    {
        double grand = 0.0;
        for (const auto& entry : totals)
        {
            grand += entry.second.first;
        }
        std::fprintf(stderr, "\n=== kernel profile (%s), %u solves ===\n", label, solves);
        std::fprintf(
            stderr, "%-34s %10s %9s %10s %7s\n",
            "kernel", "ms/solve", "launches", "us/launch", "share");
        std::vector<std::pair<std::string, std::pair<double, std::uint32_t>>> rows(
            totals.begin(), totals.end());
        std::sort(rows.begin(), rows.end(), [](const auto& a, const auto& b) {
            return a.second.first > b.second.first;
        });
        for (const auto& row : rows)
        {
            const double msPerSolve = row.second.first / std::max(1u, solves);
            const double launchesPerSolve =
                static_cast<double>(row.second.second) / std::max(1u, solves);
            std::fprintf(
                stderr, "%-34s %10.4f %9.1f %10.2f %6.1f%%\n",
                row.first.c_str(), msPerSolve, launchesPerSolve,
                row.second.first * 1000.0 / std::max(1u, row.second.second),
                100.0 * row.second.first / std::max(grand, 1e-9));
        }
        std::fprintf(
            stderr, "%-34s %10.4f\n", "TOTAL (sum of kernels)",
            grand / std::max(1u, solves));
    }
};

/// Mirrors ExtStressSolverImpl::fibreBending() (BLAST_BEND_FIBER): the walk
/// kernel must test the same fibre stresses the host walk does.
static bool bondStressFibreBending()
{
    static const bool enabled = [] {
        const char* raw = std::getenv("BLAST_BEND_FIBER");
        return raw == nullptr || raw[0] != '0';
    }();
    return enabled;
}

static bool kernelProfileEnabled()
{
#ifdef PHYSX_RESIDENT_DESTRUCTION
    return false;
#else
    static const bool enabled = [] {
        const char* raw = std::getenv("BLAST_GPU_KERNEL_PROFILE");
        return raw != nullptr && std::string(raw) != "0";
    }();
    return enabled;
#endif
}

static bool gatherRightMultiplyEnabled()
{
    static const bool enabled = [] {
        // Default ON. This was default-off for one commit after the gather
        // measured SLOWER than the scatter it replaces; that measurement was
        // real but its cause was the static-node degree walk inside the kernel
        // (see gatherRightMultiply), not the gather itself. With that removed
        // the gather wins at load and ties at rest, so it is the path.
        const char* raw = std::getenv("BLAST_GPU_GATHER");
        return raw == nullptr || std::string(raw) != "0";
    }();
    return enabled;
}

/// BLAST_GPU_GRAPH_STATS=1: how often the active lists are actually refreshed,
/// how often the captured graph is re-instantiated, and what the mid-enqueue
/// sync costs. Pure diagnostics. Guessing these three wrong is how a sound
/// idea gets implemented badly and then measured as a regression.
static bool islandTraceEnabled()
{
    static const bool enabled = std::getenv("BLAST_ISLAND_TRACE") != nullptr;
    return enabled;
}

static /// Device-side early exit via a CUDA graph conditional while-node.
///
/// On by default: it is a strict improvement whenever the solve converges
/// before its budget, and identical work when it does not. `BLAST_GPU_COND_LOOP=0`
/// restores the unrolled loop for A/B measurement. Requires CUDA 12.3+ for
/// cudaGraphCondTypeWhile; the toolkit here is 12.8. If any part of the setup
/// is unsupported at runtime the code falls back to the unrolled form, so this
/// can never change the answer -- only the cost.
bool conditionalLoopEnabled()
{
    static const bool enabled = []() {
        const char* raw = std::getenv("BLAST_GPU_COND_LOOP");
        return raw == nullptr || std::string(raw) != "0";
    }();
    return enabled;
}

/// Iterations per condition check in the conditional CG loop. See
/// launchConditionalLoopCaptured for why this is not 1.
std::uint32_t conditionalLoopChunk()
{
    static const std::uint32_t chunk = []() {
        const char* raw = std::getenv("BLAST_GPU_COND_CHUNK");
        const long parsed = raw ? std::atol(raw) : 0;
        return parsed > 0 ? static_cast<std::uint32_t>(std::min(parsed, 64L)) : 2u;
    }();
    return chunk;
}

/// Rebuild the island partition only when a removal actually disconnected
/// something. `BLAST_GPU_DEFER_REPARTITION=0` restores the unconditional
/// rebuild for A/B measurement.
/// Sparse topology upload. `BLAST_GPU_DELTA_UPLOAD=0` forces the whole-array
/// upload, for A/B and as a safety valve.
/// Node-space CGLS: solve for mu with lambda = lambda0 + W mu instead of
/// carrying bond-length vectors through the loop. Default ON.
///
/// Measured on the city scenario: 1.31x at 298k bonds and 1.98x at 1.19M bonds
/// -- the win grows with scale because it is fundamentally about the working
/// set fitting the L2, and the bond-length vectors are what pushed it out.
/// `BLAST_GPU_NODE_SPACE=0` restores the bond-space loop.
/// Block-Jacobi (6x6 per node) preconditioning of the node-space iteration.
/// Default OFF: derivation says it costs 2 matvecs/iteration against a 1.5-3x
/// iteration reduction, i.e. a wash, and this flag exists to MEASURE that
/// rather than assume it. Also the smoother a multigrid V-cycle would need.
bool jacobiEnabled()
{
#ifdef PHYSX_RESIDENT_DESTRUCTION
    return false;
#else
    static const bool enabled = []() {
        const char* raw = std::getenv("BLAST_GPU_JACOBI");
        return raw != nullptr && std::string(raw) != "0";
    }();
    return enabled;
#endif
}

/// Skip within-solve converged islands in the matvec. A/B switch: it saves the
/// matvec work but costs one scattered load per node, so which way it pays
/// depends on how many islands converge early.
bool skipConvergedEnabled()
{
    static const bool e = []() { const char* r = std::getenv("BLAST_GPU_SKIP_CONVERGED"); return r == nullptr || std::string(r) != "0"; }();
    return e;
}

// Fixed-order reductions for reproducible GPU audits. This remains opt-in
// until whole-city timings qualify the additional pass and topology uploads.
bool deterministicReductionsEnabled()
{
    static const bool enabled = [] {
        const char* raw = std::getenv("BLAST_GPU_DETERMINISTIC_REDUCTIONS");
        return raw != nullptr && std::string(raw) != "0";
    }();
    return enabled;
}

bool nodeSpaceEnabled()
{
#ifdef PHYSX_RESIDENT_DESTRUCTION
    return true;
#else
    static const bool enabled = []() {
        const char* raw = std::getenv("BLAST_GPU_NODE_SPACE");
        return raw == nullptr || std::string(raw) != "0";
    }();
    return enabled;
#endif
}

/// Relabel a separated piece locally instead of repartitioning the whole graph.
///
/// DEFAULT OFF: it is a large cost win (fracture tick 3.40 -> 2.23 ms) that
/// measurably changes the physics -- residual/tolerance went 1.05x -> 5.06x,
/// islands over tolerance 1.6% -> 10.5%, and 12% more bonds broke over the same
/// 1200-tick demolition. Something about the incrementally-maintained partition
/// is not equivalent to the rebuilt one and it is not yet understood, so the
/// verified path stays the default. `BLAST_GPU_LOCAL_SPLIT=1` enables it for
/// investigation.
/// Assert the incremental partition against a full rebuild every tick. Debug
/// only: it does the very work the incremental path exists to avoid.
bool verifyPartitionEnabled()
{
    static const bool enabled = []() {
        const char* raw = std::getenv("BLAST_GPU_VERIFY_PARTITION");
        return raw != nullptr && std::string(raw) != "0";
    }();
    return enabled;
}

bool localSplitRelabelEnabled()
{
    static const bool enabled = []() {
        const char* raw = std::getenv("BLAST_GPU_LOCAL_SPLIT");
        return raw != nullptr && std::string(raw) != "0";
    }();
    return enabled;
}

bool deltaUploadEnabled()
{
    static const bool enabled = []() {
        const char* raw = std::getenv("BLAST_GPU_DELTA_UPLOAD");
        return raw == nullptr || std::string(raw) != "0";
    }();
    return enabled;
}

bool deferRepartitionEnabled()
{
    static const bool enabled = []() {
        const char* raw = std::getenv("BLAST_GPU_DEFER_REPARTITION");
        return raw == nullptr || std::string(raw) != "0";
    }();
    return enabled;
}

bool graphStatsEnabled()
{
    static const bool enabled = [] {
        const char* raw = std::getenv("BLAST_GPU_GRAPH_STATS");
        return raw != nullptr && raw[0] == '1';
    }();
    return enabled;
}

/// Bake the captured graph at FULL launch width and stop tracking the active
/// counts on the host. BLAST_GPU_FULL_LAUNCH=0 restores the sized-capture path.
///
/// The active lists still do their job: the kernels walk the compacted lists
/// and bound themselves from DEVICE memory, so a settled city still touches
/// only what moved. All that changes is the LAUNCH DIMENSION, where extra
/// threads return immediately.
///
/// What this buys is measured, not assumed. At baseline the captured graph was
/// being re-instantiated on 45.7% of solves, because graphMatches has an upper
/// bound as well as a lower one -- the cap must also stay within 4x the ideal
/// size, so a scene whose active set keeps shrinking recaptures forever. A
/// fixed full-width cap satisfies both bounds permanently, and once the caps
/// are fixed the counts are not needed on the host at all, which removes the
/// mid-enqueue cudaStreamSynchronize (0.383 ms/solve) as a side effect.
///
/// The first attempt at this forced full width but LEFT the upper bound in
/// place, so every tick failed graphMatches and recaptured. It measured as a
/// regression and was very nearly recorded as a dead end.
///
/// MEASURED, corrected version, default OFF: it does remove the sync
/// (0.423 -> 0.000 ms/solve) but costs more than it saves. gpu_host_work
/// 1.581 -> 3.320 ms and stress_solve p50 14.00 -> 20.52 ms, because every
/// kernel now launches at full width on every iteration. Recapture also did
/// NOT fall (48.0% -> 62.7%), which is the useful part of the result: cap
/// sizing was never what drove recapture. With both cap bounds bypassed
/// entirely the rate stayed high, so the driver is the rest of graphMatches --
/// applyTopologyChange nulls m_graphExec on every fracture tick, and
/// WHOLE_RESET_ON_TOPOLOGY flips warmStart false->true->false around it.
///
/// The route to removing the sync WITHOUT paying full width is therefore to
/// make the launch dimension a performance hint rather than a correctness
/// requirement: grid-stride the solve kernels (they already bound from device
/// memory) so a stale, undersized cap is merely slower, never wrong. Then the
/// counts can come from the previous tick and the sync goes away for free.
static bool fullLaunchCapacity()
{
    static const bool enabled = [] {
        // Default OFF: measured a net regression (see the note above).
        const char* raw = std::getenv("BLAST_GPU_FULL_LAUNCH");
        return raw != nullptr && raw[0] == '1';
    }();
    return enabled;
}

/// Patch the instantiated graph in place instead of re-instantiating it.
/// BLAST_GPU_GRAPH_UPDATE=0 restores destroy + cudaGraphInstantiate.
///
/// Measured: the graph was being re-instantiated on 80% of solves at 0.644 ms
/// each -- 0.516 ms/solve of pure host overhead, MORE than the mid-enqueue
/// sync beside it. applyTopologyChange destroyed it whenever grid sizes or the
/// per-island memset width changed, and graphMatches forces it again whenever
/// the baked launch caps drift outside a 4x band.
///
/// None of that is structural. Every device pointer is allocated once in the
/// constructor and never moves, so a fracture tick changes kernel gridDim, a
/// few scalar arguments and one memset width -- exactly what
/// cudaGraphExecUpdate patches. Only three things change the NODE SET:
/// warmStart (it adds/removes the gather+subtract pair), applyDamage and
/// maxIterations; the latter two are constant in practice.
/// Keep the captured graph's NODE SET independent of warmStart, so a
/// warm-start flip is a parameter change the exec can absorb instead of a
/// rebuild. BLAST_GPU_STABLE_GRAPH=0 restores the branch.
static bool stableGraphEnabled()
{
    static const bool enabled = [] {
        const char* raw = std::getenv("BLAST_GPU_STABLE_GRAPH");
        return raw == nullptr || raw[0] != '0';
    }();
    return enabled;
}

static bool graphUpdateEnabled()
{
#ifdef PHYSX_RESIDENT_DESTRUCTION
    return false;
#else
    static const bool enabled = [] {
        const char* raw = std::getenv("BLAST_GPU_GRAPH_UPDATE");
        return raw == nullptr || raw[0] != '0';
    }();
    return enabled;
#endif
}

static bool wholeResetOnTopology()
{
    static const bool enabled = [] {
        const char* raw = std::getenv("BLAST_GPU_WHOLE_RESET_ON_TOPOLOGY");
        return raw != nullptr && raw[0] == '1';
    }();
    return enabled;
}

struct alignas(16) Vec4
{
    float x;
    float y;
    float z;
    float w;
};

struct alignas(16) AngLin
{
    Vec4 angular;
    Vec4 linear;
};

struct Inertia
{
    float angular;
    float linear;
};

using SolveStatus = ExtStressGpuDeviceStatus;

/// Bonds/nodes that belong to no solvable island (static-static bonds, and
/// static nodes, which are fixed boundaries carrying no coupling).
static constexpr std::uint32_t kNoIsland = 0xFFFFFFFFu;

/// Padded per-island reduction accumulators, as a power-of-two shift. The
/// stride is fixed at compile time so the indexing is a shift rather than a
/// multiply, and so the scratch allocation never has to be resized; the number
/// of slots ACTUALLY summed is chosen per call and is <= 1 << this.
static constexpr std::uint32_t kReductionSlotShiftMax = 5;   // 32 slots
static constexpr std::uint32_t kReductionSlotsMax = 1u << kReductionSlotShiftMax;

/// How often node-space CGLS recomputes q = L pi explicitly rather than
/// advancing it by recurrence. See nodeSpaceMatvec's refresh mode.
///
/// Measured at 8 it cost ~6% of the solve and recovered only ~2% of the
/// residual gap against the CPU reference, so the recurrence is NOT the main
/// source of that gap -- worth knowing before spending more on it. Kept at 16
/// as cheap insurance for very long solves, where drift does compound.
static constexpr std::uint32_t kQRefresh = 16u;

/// A node->bond CSR entry whose bond is gone. The CSR is patched in place on a
/// removal rather than rebuilt, so a node's run keeps its length and the
/// vacated slots are tombstoned. 0xFFFFFFFF cannot collide with a live ref
/// (bond index is masked to 31 bits) and is one compare to test.
static constexpr std::uint32_t kDeadBondRef = 0xFFFFFFFFu;

/**
 * Settled-island skipping: is this BOND's work already done?
 *
 * `skip` is null whenever ExtStressGpuSolveParams::skipSettledIslands is off,
 * which restores the pre-skip behaviour exactly rather than approximately.
 *
 * A kNoIsland bond joins two static nodes. It carries no coupling, the
 * conjugate-gradient update never writes it, and it starts at zero from the
 * construction-time memset -- so its impulse is zero forever and every pass
 * over it is waste. Treating it as permanently settled is what lets the
 * readback list be exactly "the bonds whose impulses can have changed".
 */
__device__ inline bool bondSettled(const std::uint32_t* skip, std::uint32_t island)
{
    return skip != nullptr && (island == kNoIsland || skip[island] != 0u);
}

/**
 * ...and is this NODE's?
 *
 * The opposite rule for kNoIsland: a static node is a boundary SHARED by every
 * island that touches it, so its right-hand side must be rebuilt whichever
 * islands are being solved. (It is multiplied by a zero inverse inertia
 * downstream, so it contributes nothing -- but leaving a stale value there
 * would make a non-finite input outlive the frame that produced it.)
 */
__device__ inline bool nodeSettled(const std::uint32_t* skip, std::uint32_t island)
{
    return skip != nullptr && island != kNoIsland && skip[island] != 0u;
}

void checkCuda(cudaError_t result, const char* operation)
{
    if (result != cudaSuccess)
    {
        throw std::runtime_error(
            std::string(operation) + ": " + cudaGetErrorString(result));
    }
}

void checkDriver(CUresult result, const char* operation)
{
    if (result != CUDA_SUCCESS)
    {
        const char* message = nullptr;
        cuGetErrorString(result, &message);
        throw std::runtime_error(
            std::string(operation) + ": " + (message ? message : "CUDA driver error"));
    }
}

class ContextGuard
{
public:
    explicit ContextGuard(CUcontext context)
        : m_active(context != nullptr)
    {
        if (m_active)
        {
            checkDriver(cuCtxPushCurrent(context), "activate PhysX CUDA context");
        }
    }

    ~ContextGuard()
    {
        if (m_active)
        {
            CUcontext popped = nullptr;
            cuCtxPopCurrent(&popped);
        }
    }

private:
    bool m_active;
};

__host__ __device__ Vec4 makeVec(float x, float y, float z)
{
    return {x, y, z, 0.0f};
}

__host__ __device__ Vec4 add(const Vec4& a, const Vec4& b)
{
    return makeVec(a.x + b.x, a.y + b.y, a.z + b.z);
}

__host__ __device__ Vec4 sub(const Vec4& a, const Vec4& b)
{
    return makeVec(a.x - b.x, a.y - b.y, a.z - b.z);
}

__host__ __device__ Vec4 mul(const Vec4& value, float scale)
{
    return makeVec(value.x * scale, value.y * scale, value.z * scale);
}

__host__ __device__ Vec4 cross(const Vec4& a, const Vec4& b)
{
    return makeVec(
        a.y * b.z - a.z * b.y,
        a.z * b.x - a.x * b.z,
        a.x * b.y - a.y * b.x);
}

#include "detail/StressCouplingKernels.cuh"
#include "detail/StressNodeOperator.cuh"
#include "detail/StressNodePreconditioner.cuh"
#include "detail/StressNodeIteration.cuh"
#include "detail/StressTopologyUpdates.cuh"
#include "detail/StressIslandReduction.cuh"
#include "detail/StressBondIteration.cuh"
#include "detail/StressDeviceIO.cuh"
#include "detail/StressMaterialKernels.cuh"
bool bondStressProbe()
{
    static const bool on = [] {
        const char* raw = std::getenv("BLAST_BOND_STRESS_PROBE");
        return raw != nullptr && std::string(raw) != "0";
    }();
    return on;
}

/// std::vector allocator backed by cudaMallocHost.
///
/// The topology upload was a DOUBLE copy: computeIslands and buildNodeBondCsr
/// filled pageable std::vectors, then those were memcpy'd into a pinned staging
/// arena, then DMA'd. Measured, the DMA enqueue cost 0.09 ms and the host
/// memcpy 1.52 ms -- the copy, not the transfer, was the whole cost. Backing
/// the vectors with pinned memory deletes the middle step: the host code writes
/// where the DMA reads.
///
/// Worth recording why the more obvious idea was NOT built. Uploading only the
/// changed bytes sounds strictly better, but 5.048 MB of the 5.31 MB is dirty
/// every fracture tick -- computeIslands renumbers island ids wholesale -- so
/// there is no narrow dirty range to exploit. That was measured first.
template <typename T>
struct PinnedAllocator
{
    using value_type = T;
    PinnedAllocator() noexcept = default;
    template <typename U>
    PinnedAllocator(const PinnedAllocator<U>&) noexcept {}

    T* allocate(std::size_t n)
    {
        void* p = nullptr;
        if (n != 0 && cudaMallocHost(&p, n * sizeof(T)) != cudaSuccess)
        {
            throw std::bad_alloc();
        }
        return static_cast<T*>(p);
    }
    void deallocate(T* p, std::size_t) noexcept
    {
        if (p != nullptr)
        {
            cudaFreeHost(p);
        }
    }
    template <typename U>
    bool operator==(const PinnedAllocator<U>&) const noexcept { return true; }
    template <typename U>
    bool operator!=(const PinnedAllocator<U>&) const noexcept { return false; }
};

template <typename T>
using PinnedVector = std::vector<T, PinnedAllocator<T>>;

struct IslandReductionOrder
{
    std::vector<std::uint32_t> order, partialBegin, rowBegin, cursor;
    std::vector<uint2> tiles;
    std::uint32_t* deviceOrder{nullptr};
    std::uint32_t* devicePartialBegin{nullptr};
    uint2* deviceTiles{nullptr};
};

#include "NvBlastExtStressGpuTopology.cuh"


#include "detail/StressResidentIteration.cuh"
#include "detail/StressComponentIteration.cuh"
class ExtStressGpuSolverImpl final : public ExtStressGpuSolver
{
public:
#include "detail/StressSolverLifetime.inl"
    /// Periodic BLAST_GPU_GRAPH_STATS dump.
    ///
    /// Called from BOTH solve entry points. It used to live inline in
    /// solveAndReadbackImpulses only, so any caller using the plain solve()
    /// path -- which is what a headless harness naturally uses -- got no host
    /// breakdown at all, and the absence looked like "the stats are off"
    /// rather than "you are on the other entry point".
    void maybeDumpStats()
    {
        if (graphStatsEnabled() && m_islandCount > 0)
        {
            accumulateResidualStats();
        }
        if (graphStatsEnabled() && (++m_statSolves % 600u) == 0u)
        {
            fprintf(stderr,
                    "[gpu-graph] solves=%u listRefresh=%u listSkip=%u (%.1f%% refreshed) "
                    "graphRecapture=%u (%.2f%% of solves) midSync=%.4f ms/solve "
                    "| recapture %.4f ms/solve (%.3f each) "
                    "| graphUpdate=%u %.4f ms/solve (%.3f each)\n",
                    m_statSolves, m_statListRefreshes, m_statListSkips,
                    100.0 * double(m_statListRefreshes)
                        / double(m_statListRefreshes + m_statListSkips + 1u),
                    m_statGraphRecaptures,
                    100.0 * double(m_statGraphRecaptures) / double(m_statSolves),
                    m_statMidSyncMs / double(m_statSolves),
                    (m_statCaptureMs + m_statInstantiateMs) / double(m_statSolves),
                    (m_statCaptureMs + m_statInstantiateMs)
                        / double(m_statGraphRecaptures + 1u),
                    m_statGraphUpdates,
                    m_statUpdateMs / double(m_statSolves),
                    m_statUpdateMs / double(m_statGraphUpdates + 1u));
            // Where the HOST time actually goes, split from where it merely
            // waits. Only `plan` and `finish` are reclaimable by writing
            // faster host code; `wait` is the device computing, and shrinking
            // it means less device work or more overlap, not tighter host code.
            fprintf(stderr,
                    "[gpu-host] plan=%.4f (graphUpdate=%.4f, midSync=%.4f, "
                    "other=%.4f | planSkip=%.4f refresh=%.4f topo=%.4f "
                    "[%u calls, %.3f each: islands=%.3f csr=%.3f group=%.3f "
                    "upload=%.3f memset=%.3f | %.2f MB in %u copies, "
                    "stageMemcpy=%.3f, %u growths, %.2f GB/s]) "
                    "wait=%.4f finish=%.4f ms/solve "
                    "| iters=%.1f/solve unconverged=%u (%.1f%% of solves) "
                    "| residual/tolerance: mean=%.2fx max=%.2fx, %.1f%% of islands over tol\n",
                    m_statPlanMs / double(m_statSolves),
                    m_statUpdateMs / double(m_statSolves),
                    m_statMidSyncMs / double(m_statSolves),
                    (m_statPlanMs - m_statUpdateMs) / double(m_statSolves),
                    m_statPlanSkipMs / double(m_statSolves),
                    m_statRefreshMs / double(m_statSolves),
                    m_statTopoMs / double(m_statSolves),
                    m_statTopoCalls,
                    m_statTopoMs / double(m_statTopoCalls + 1u),
                    m_statTopoIslandsMs / double(m_statTopoCalls + 1u),
                    m_statTopoCsrMs / double(m_statTopoCalls + 1u),
                    m_statTopoGroupMs / double(m_statTopoCalls + 1u),
                    m_statTopoUploadMs / double(m_statTopoCalls + 1u),
                    m_statTopoMemsetMs / double(m_statTopoCalls + 1u),
                    double(m_statTopoBytes) / double(m_statTopoCalls + 1u) / 1048576.0,
                    m_statTopoCopies / (m_statTopoCalls + 1u),
                    m_statStageCopyMs / double(m_statTopoCalls + 1u),
                    m_statTopoGrowths,
                    (double(m_statTopoBytes) / 1.0e9)
                        / ((m_statTopoUploadMs > 0.0 ? m_statTopoUploadMs : 1.0) / 1000.0),
                    m_statWaitMs / double(m_statSolves),
                    m_statFinishMs / double(m_statSolves),
                    double(m_statIterations) / double(m_statSolves),
                    m_statUnconverged,
                    100.0 * double(m_statUnconverged) / double(m_statSolves),
                    m_statResCount ? m_statResSum / double(m_statResCount) : 0.0,
                    m_statResMax,
                    m_statResCount
                        ? 100.0 * double(m_statResOverTol) / double(m_statResCount)
                        : 0.0);
        }
    }

    bool solve(
        const ExtStressGpuImpulse* nodeVelocities,
        const ExtStressGpuSolveParams& params) override
    {
        return solveInputs(nodeVelocities, params, false, nullptr);
    }

    bool solveDevice(
        const ExtStressGpuImpulse* nodeVelocities,
        std::uint32_t nodeCount,
        const ExtStressGpuSolveParams& params,
        void* producerReady) override
    {
        if (nodeCount != m_nodeCount) { return false; }
        return solveInputs(nodeVelocities, params, true, producerReady);
    }

#include "detail/StressResidentAPI.inl"
    bool solveInputs(
        const ExtStressGpuImpulse* nodeVelocities,
        const ExtStressGpuSolveParams& params,
        bool deviceInput, void* producerReady)
    {
        m_skipStableUnconverged = params.skipStableUnconverged;
        ContextGuard context(m_cudaContext);
        using HostClock = std::chrono::steady_clock;
        const auto hostMs = [](HostClock::time_point from) {
            return std::chrono::duration<float, std::milli>(HostClock::now() - from)
                .count();
        };
        const auto planStart = HostClock::now();
        if (!enqueueSolve(nodeVelocities, params, deviceInput, producerReady))
        {
            return false;
        }
        // enqueueSolve contains the mid-solve stall in refreshActiveLists, so
        // its own sync time is subtracted out below rather than counted as
        // planning work.
        m_telemetry.hostPlanMilliseconds =
            hostMs(planStart) - m_activeListSyncMilliseconds;
        m_telemetry.hostSyncMilliseconds = m_activeListSyncMilliseconds;
        m_activeListSyncMilliseconds = 0.0f;
        if (m_solveWasNoOp)
        {
            return true;
        }
        const auto waitStart = HostClock::now();
        checkCuda(cudaEventSynchronize(m_statusReady), "wait for stress solve");
        const float solveWaitMs = hostMs(waitStart);
        m_telemetry.hostSyncMilliseconds += solveWaitMs;
        m_statWaitMs += solveWaitMs;
        const auto finishStart = HostClock::now();
        finishSolve();
        m_telemetry.hostFinishMilliseconds = hostMs(finishStart);
        m_statPlanMs += m_telemetry.hostPlanMilliseconds;
        m_statFinishMs += m_telemetry.hostFinishMilliseconds;
        m_statIterations += m_telemetry.iterations;
        if (!m_telemetry.converged) ++m_statUnconverged;
        maybeDumpStats();
        return true;
    }

    bool readbackImpulses(
        ExtStressGpuImpulse* bondImpulses,
        std::uint32_t capacity) override
    {
        ContextGuard context(m_cudaContext);
        if (!bondImpulses || capacity < m_bondCount)
        {
            return false;
        }
        using Clock = std::chrono::steady_clock;
        const auto elapsed = [](Clock::time_point started) {
            return std::chrono::duration<float, std::milli>(Clock::now() - started).count();
        };
        const auto planStarted = Clock::now();
        // Public whole-array contract: the caller has not been told which
        // bonds moved, so every one is copied.
        m_changedBonds.resize(m_bondCount);
        for (std::uint32_t i = 0; i < m_bondCount; ++i)
        {
            m_changedBonds[i] = i;
        }
        enqueueImpulseReadback(false);
        m_telemetry.hostPlanMilliseconds += elapsed(planStarted);
        const auto waitStarted = Clock::now();
        checkCuda(cudaEventSynchronize(m_downloadStop), "wait for impulse readback");
        m_telemetry.hostSyncMilliseconds += elapsed(waitStarted);
        const auto finishStarted = Clock::now();
        finishImpulseReadback(bondImpulses, false);
        m_telemetry.hostFinishMilliseconds += elapsed(finishStarted);
        return true;
    }

    bool solveAndReadbackImpulses(
        const ExtStressGpuImpulse* nodeVelocities,
        const ExtStressGpuSolveParams& params,
        ExtStressGpuImpulse* bondImpulses,
        std::uint32_t capacity) override
    {
        m_skipStableUnconverged = params.skipStableUnconverged;
        ContextGuard context(m_cudaContext);
        // Instrumented here as well as in solve(), because THIS is the entry
        // point production uses -- the adapter calls
        // solveAndReadbackImpulses, and a host split measured only in solve()
        // reported a clean 0.00 ms live while the real path went unmeasured.
        using HostClock = std::chrono::steady_clock;
        const auto hostMs = [](HostClock::time_point from) {
            return std::chrono::duration<float, std::milli>(HostClock::now() - from)
                .count();
        };
        const auto planStart = HostClock::now();
        if (!bondImpulses || capacity < m_bondCount
            || !enqueueSolve(nodeVelocities, params))
        {
            return false;
        }
        m_telemetry.hostPlanMilliseconds =
            hostMs(planStart) - m_activeListSyncMilliseconds;
        m_telemetry.hostSyncMilliseconds = m_activeListSyncMilliseconds;
        m_activeListSyncMilliseconds = 0.0f;
        if (m_solveWasNoOp)
        {
            // Every island settled: the impulses on the device are the ones
            // the caller is already holding, so there is nothing to launch,
            // synchronize on, or copy back.
            return true;
        }
        // The status and impulse copies share one stream. Waiting for the
        // latter completes the upload, solve, status, and impulse readback.
        const bool compacted = m_changedBonds.size() < m_bondCount;
        const auto enqueueStart = HostClock::now();
        enqueueImpulseReadback(compacted);
        m_telemetry.hostPlanMilliseconds += hostMs(enqueueStart);
        const auto waitStart = HostClock::now();
        checkCuda(cudaEventSynchronize(m_downloadStop), "wait for stress solve and readback");
        m_telemetry.hostSyncMilliseconds += hostMs(waitStart);
        const auto finishStart = HostClock::now();
        finishSolve();
        finishImpulseReadback(bondImpulses, compacted);
        m_telemetry.hostFinishMilliseconds = hostMs(finishStart);
        m_statPlanMs += m_telemetry.hostPlanMilliseconds;
        m_statFinishMs += m_telemetry.hostFinishMilliseconds;
        m_statWaitMs += m_telemetry.hostSyncMilliseconds - m_statLastMidSync;
        // Convergence, not just cost. The whole question about the incremental
        // topology path is whether keeping a stale warm start leaves the solve
        // UNCONVERGED at the iteration cap -- an unconverged stress field is
        // what decides which bonds break, so it is a correctness signal, not a
        // performance one.
        m_statIterations += m_telemetry.iterations;
        if (!m_telemetry.converged)
        {
            ++m_statUnconverged;
        }
        // HOW FAR from converged, not just whether. The convergence test is
        // residual^2 <= tolerance^2 per island, so sqrt(gradientSq/deltaSq) is
        // the factor by which an island misses its own tolerance: 1.0 is
        // exactly converged, 10.0 means the residual is ten times the target.
        //
        // This is the number that answers "how much accuracy is the iteration
        // cap costing us". Bonds-broken cannot answer it -- breakage is a
        // threshold crossing on top of a chaotic cascade, so it amplifies a
        // small stress error into a large outcome difference and tells you
        // nothing about the size of the error itself.
        maybeDumpStats();
        return true;
    }

    bool readbackBrokenBonds(
        std::uint32_t* bondIndices,
        std::uint32_t capacity,
        std::uint32_t& count) override
    {
        ContextGuard context(m_cudaContext);
        count = 0;
        checkCuda(
            cudaMemcpy(&count, m_brokenCount, sizeof(count), cudaMemcpyDeviceToHost),
            "read broken bond count");
        if (count > m_bondCount || count > capacity || (count > 0 && !bondIndices))
        {
            return false;
        }
        if (count > 0)
        {
            checkCuda(
                cudaMemcpy(
                    bondIndices,
                    m_brokenBonds,
                    sizeof(std::uint32_t) * count,
                    cudaMemcpyDeviceToHost),
                "read broken bond indices");
        }
        m_telemetry.deviceToHostBytes +=
            sizeof(count) + sizeof(std::uint32_t) * static_cast<std::uint64_t>(count);
        return true;
    }

    bool readbackBondHealth(float* health, std::uint32_t capacity) override
    {
        ContextGuard context(m_cudaContext);
        if (!health || capacity < m_bondCount)
        {
            return false;
        }
        checkCuda(
            cudaMemcpy(
                health,
                m_health,
                sizeof(float) * m_bondCount,
                cudaMemcpyDeviceToHost),
            "read bond health");
        m_telemetry.deviceToHostBytes +=
            sizeof(float) * static_cast<std::uint64_t>(m_bondCount);
        return true;
    }

    bool removeBond(std::uint32_t bondIndex) override
    {
        if (m_deviceTopology || m_deviceTopologyFailed || bondIndex >= m_bondCount)
        {
            return false;
        }
        // Swap-with-last, exactly as ConjugateGradientImpulseSolver does to its
        // own bond and impulse arrays. Both sides must apply the same
        // permutation or the impulse the host reads back belongs to a
        // different bond -- a silent, physics-shaped corruption rather than an
        // error.
        const std::uint32_t last = m_bondCount - 1;
        // The removed bond's island must re-solve: its frozen impulses no
        // longer describe the post-break topology. Nodes are the stable key --
        // island ids get remapped by the repartition this removal triggers.
        m_forceDirtyNodes.push_back(m_hostNode0[bondIndex]);
        m_forceDirtyNodes.push_back(m_hostNode1[bondIndex]);
        // Captured here, before swapWithLast overwrites slot `bondIndex`.
        m_splitChecks.push_back({m_hostNode0[bondIndex], m_hostNode1[bondIndex]});
        // Device impulses must follow the same permutation as the host arrays;
        // replayed in order in applyTopologyChange.
        m_pendingImpulseSwaps.emplace_back(bondIndex, last);
        swapWithLast(m_hostNode0, bondIndex, last);
        swapWithLast(m_hostNode1, bondIndex, last);
        swapWithLast(m_hostOffset0, bondIndex, last);
        swapWithLast(m_hostOffset1, bondIndex, last);
        swapWithLast(m_hostNormals, bondIndex, last);
        swapWithLast(m_hostAreas, bondIndex, last);
        swapWithLast(m_hostColScale, bondIndex, last);
        swapWithLast(m_hostNodeDistances, bondIndex, last);
        swapWithLast(m_hostHealth, bondIndex, last);
        swapWithLast(m_hostBondMaterials, bondIndex, last);
        // The island label travels with the bond, so the existing partition
        // stays self-consistent without being recomputed. That is what lets
        // the repartition be deferred (see shouldRepartition).
        if (bondIndex < m_hostBondIsland.size() && last < m_hostBondIsland.size())
        {
            m_hostBondIsland[bondIndex] = m_hostBondIsland[last];
        }
        // m_bondsByIsland indexes bonds, and two of them just moved.
        m_bondsByIslandValid = false;
        ++m_removalsSinceRepartition;
        // Exactly one live slot changed: `bondIndex` now holds what `last`
        // held. Slots at or past the new bond count are never read again.
        if (bondIndex != last)
        {
            m_changedBondSlots.push_back(bondIndex);
        }
        patchCsrForRemoval(bondIndex, last);
        m_bondCount = last;
        m_topologyDirty = true;
        return true;
    }

    const std::uint32_t* lastChangedBonds(std::uint32_t& count) const override
    {
        count = static_cast<std::uint32_t>(m_changedBonds.size());
        return m_changedBonds.data();
    }


    // ── Device bond-stress walk ────────────────────────────────────────────
    //
    // The reason this exists: the impulses this walk consumes are already
    // resident here, and are copied back to the host every tick for no other
    // purpose than feeding it. On the host it is the largest single cost in
    // the tick and it is linear in TOTAL live bonds, not in activity, so no
    // amount of skipping or CPU fan-out reaches it.

    bool setBondStressTopology(const ExtStressGpuBondStressTopology& topology) override
    {
        if (m_deviceTopology || m_deviceTopologyFailed) return false;
        // Every other public entry point pushes PhysX's CUDA context before
        // touching the device; these did not, so their allocations, streams
        // and launches landed in whatever context the calling thread happened
        // to have -- the primary one -- while the impulses they read were
        // allocated under the guard in PhysX's. Cross-context by construction,
        // and the reason a tiny kernel could not be submitted without the GPU
        // switching contexts around it.
        ContextGuard context(m_cudaContext);
        if (topology.groupCount == 0 || topology.blastBondCount == 0)
        {
            m_bsReady = false;
            return false;
        }
        try
        {
            ensureBondStressCapacity(topology);

            // Static payload, indexed by blast bond: uploaded once per resync
            // because blast bond indices are never permuted.
            uploadBondStress(m_bsBondNode0, topology.bondNode0, topology.blastBondCount, "bs node0");
            uploadBondStress(m_bsBondNode1, topology.bondNode1, topology.blastBondCount, "bs node1");
            uploadBondStress(m_bsBondMaterial, topology.bondMaterial, topology.blastBondCount, "bs material");
            uploadBondStress(m_bsBondNormal, topology.bondNormal, 3u * topology.blastBondCount, "bs normal");
            uploadBondStress(m_bsBondCentroid, topology.bondCentroid, 3u * topology.blastBondCount, "bs centroid");
            uploadBondStress(m_bsBondNodeDisp, topology.bondNodeDisp, 3u * topology.blastBondCount, "bs nodeDisp");

            // syncBonds zeroes every bond's stress when the graph structure
            // changes, because internal bonds stop being updated. Match it.
            checkCuda(cudaMemset(m_bsGroupStressNormal, 0, sizeof(float) * topology.groupCount), "bs clear sn");
            checkCuda(cudaMemset(m_bsGroupStressShear, 0, sizeof(float) * topology.groupCount), "bs clear ss");
            checkCuda(cudaMemset(m_bsGroupStressBend, 0, sizeof(float) * topology.groupCount), "bs clear sb");
            checkCuda(cudaMemset(m_bsGroupNormal, 0, sizeof(float) * 3u * topology.groupCount), "bs clear n");
            checkCuda(cudaMemset(m_bsGroupCentroid, 0, sizeof(float) * 3u * topology.groupCount), "bs clear c");
            m_bsCsrResident = false;
            m_bsHealthResident = false;
            m_bsReady = true;
        }
        catch (const std::exception&)
        {
            m_bsReady = false;
            return false;
        }
        return true;
    }

    bool readbackGroupStresses(
        const float*& stressNormal, const float*& stressShear, const float*& stressBend) override
    {
        // Every other public entry point pushes PhysX's CUDA context before
        // touching the device; these did not, so their allocations, streams
        // and launches landed in whatever context the calling thread happened
        // to have -- the primary one -- while the impulses they read were
        // allocated under the guard in PhysX's. Cross-context by construction,
        // and the reason a tiny kernel could not be submitted without the GPU
        // switching contexts around it.
        ContextGuard context(m_cudaContext);
        if (!m_bsReady || m_bsVectorGroups == 0 || m_bsStream == nullptr)
        {
            return false;
        }
        if (!m_bsStressFetched)
        {
            try
            {
                // On m_bsStream, not the legacy default stream: a blocking
                // cudaMemcpy there implicitly synchronises with EVERY stream
                // on the device, so the lazy fetch would wait on PhysX's whole
                // pipeline. That turned a cheap deferred read into a stall and
                // showed up as a 2.2x spread between otherwise identical arms.
                checkCuda(
                    cudaMemcpyAsync(m_bsHostGroupStressNormal, m_bsGroupStressNormal,
                                    sizeof(float) * m_bsVectorGroups,
                                    cudaMemcpyDeviceToHost, m_bsStream),
                    "bs lazy read sn");
                checkCuda(
                    cudaMemcpyAsync(m_bsHostGroupStressShear, m_bsGroupStressShear,
                                    sizeof(float) * m_bsVectorGroups,
                                    cudaMemcpyDeviceToHost, m_bsStream),
                    "bs lazy read ss");
                checkCuda(
                    cudaMemcpyAsync(m_bsHostGroupStressBend, m_bsGroupStressBend,
                                    sizeof(float) * m_bsVectorGroups,
                                    cudaMemcpyDeviceToHost, m_bsStream),
                    "bs lazy read sb");
                ++m_telemetry.bondStressLazyStressFetches;
                checkCuda(cudaStreamSynchronize(m_bsStream), "bs lazy stress sync");
            }
            catch (const std::exception&)
            {
                return false;
            }
            m_bsStressFetched = true;
        }
        stressNormal = m_bsHostGroupStressNormal;
        stressShear = m_bsHostGroupStressShear;
        stressBend = m_bsHostGroupStressBend;
        return true;
    }

    bool readbackGroupVectors(const float*& groupNormal, const float*& groupCentroid) override
    {
        // Every other public entry point pushes PhysX's CUDA context before
        // touching the device; these did not, so their allocations, streams
        // and launches landed in whatever context the calling thread happened
        // to have -- the primary one -- while the impulses they read were
        // allocated under the guard in PhysX's. Cross-context by construction,
        // and the reason a tiny kernel could not be submitted without the GPU
        // switching contexts around it.
        ContextGuard context(m_cudaContext);
        if (!m_bsReady || m_bsVectorGroups == 0 || m_bsStream == nullptr)
        {
            return false;
        }
        if (!m_bsVectorsFetched)
        {
            try
            {
                checkCuda(
                    cudaMemcpyAsync(
                        m_bsHostGroupNormal, m_bsGroupNormal,
                        sizeof(float) * 3u * m_bsVectorGroups,
                        cudaMemcpyDeviceToHost, m_bsStream),
                    "bs lazy read normal");
                checkCuda(
                    cudaMemcpyAsync(
                        m_bsHostGroupCentroid, m_bsGroupCentroid,
                        sizeof(float) * 3u * m_bsVectorGroups,
                        cudaMemcpyDeviceToHost, m_bsStream),
                    "bs lazy read centroid");
                ++m_telemetry.bondStressLazyVectorFetches;
                checkCuda(cudaStreamSynchronize(m_bsStream), "bs lazy vector sync");
            }
            catch (const std::exception&)
            {
                return false;
            }
            m_bsVectorsFetched = true;
        }
        groupNormal = m_bsHostGroupNormal;
        groupCentroid = m_bsHostGroupCentroid;
        return true;
    }

    bool updateBondStress(
        const ExtStressGpuBondStressTopology& csr,
        const float* blastBondHealth,
        float unbreakableLimit,
        ExtStressGpuBondStressResult& result) override
    {
        if (m_deviceTopology || m_deviceTopologyFailed) return false;
        // Every other public entry point pushes PhysX's CUDA context before
        // touching the device; these did not, so their allocations, streams
        // and launches landed in whatever context the calling thread happened
        // to have -- the primary one -- while the impulses they read were
        // allocated under the guard in PhysX's. Cross-context by construction,
        // and the reason a tiny kernel could not be submitted without the GPU
        // switching contexts around it.
        ContextGuard context(m_cudaContext);
        if (!m_bsReady
            || csr.groupCount == 0
            || csr.groupCount > m_bsGroupCapacity
            || csr.memberSlotCount > m_bsSlotCapacity
            || csr.blastBondCount > m_bsBondCapacity
            || csr.graphNodeCount > m_bsNodeCapacity
            || csr.materialCount == 0
            || csr.materialElasticLimits == nullptr
            || csr.groupCount > m_bondCount)
        {
            return false;
        }
        try
        {
            const auto bsHostStart = std::chrono::steady_clock::now();
            if (m_bsStream == nullptr)
            {
                // Its own stream, at the highest priority the device offers.
                //
                // The walk does not have to be ordered behind anything on the
                // solver stream: it reads impulses the solve has already
                // synchronised, and deviceImpulsesUsable() is what guarantees
                // that. Sharing a stream only forced it to queue.
                //
                // Standalone this walk costs 0.056 ms at the city's group
                // count and is unaffected by other PROCESSES hammering the
                // GPU (+7%). In-game the identical work was costing 1.183 ms,
                // so what it was waiting for was in this process: PhysX's own
                // rigid-body simulation, in the same context.
                int lo = 0, hi = 0;
                cudaDeviceGetStreamPriorityRange(&lo, &hi);
                cudaStreamCreateWithPriority(&m_bsStream, cudaStreamNonBlocking, hi);
            }
            if (m_bsEvUploadStart == nullptr)
            {
                cudaEventCreate(&m_bsEvUploadStart);
                cudaEventCreate(&m_bsEvUploadStop);
                cudaEventCreate(&m_bsEvKernelStop);
                cudaEventCreate(&m_bsEvReadStop);
            }
            // Probe: what does synchronising cost when there is NOTHING to
            // wait for? Three points, at the exact place in the tick the real
            // walk runs. If an EMPTY sync already costs what the real one
            // does, the fixed cost has nothing to do with our work.
            if (bondStressProbe())
            {
                const auto p0 = std::chrono::steady_clock::now();
                cudaStreamSynchronize(m_bsStream);          // nothing queued
                const auto p1 = std::chrono::steady_clock::now();
                bondStressNullKernel<<<1, 1, 0, m_bsStream>>>();
                cudaStreamSynchronize(m_bsStream);          // FIRST empty launch
                const auto p2 = std::chrono::steady_clock::now();
                bondStressNullKernel<<<1, 1, 0, m_bsStream>>>();
                cudaStreamSynchronize(m_bsStream);          // SECOND, back to back
                const auto p2b = std::chrono::steady_clock::now();
                m_telemetry.bondStressProbeKernel2Ms =
                    std::chrono::duration<float, std::milli>(p2b - p2).count();
                const auto p2c = std::chrono::steady_clock::now();
                cudaMemcpyAsync(m_bsHostCounts, m_bsOverstressedCount,
                                sizeof(std::uint32_t), cudaMemcpyDeviceToHost, m_bsStream);
                cudaStreamSynchronize(m_bsStream);          // one 4-byte D2H
                const auto p3 = std::chrono::steady_clock::now();
                m_telemetry.bondStressProbeEmptyMs =
                    std::chrono::duration<float, std::milli>(p1 - p0).count();
                m_telemetry.bondStressProbeKernelMs =
                    std::chrono::duration<float, std::milli>(p2 - p1).count();
                m_telemetry.bondStressProbeCopyMs =
                    std::chrono::duration<float, std::milli>(p3 - p2c).count();
            }

            const std::uint32_t groups = csr.groupCount;
            m_telemetry.bondStressBytesUp = 0;
            m_telemetry.bondStressBytesDown = 0;
            cudaEventRecord(m_bsEvUploadStart, m_bsStream);

            // Uploads go through PINNED staging, and only when the bytes
            // actually changed.
            //
            // Measured before this: 1.13 MB per call taking 1.250 ms, which is
            // 0.9 GB/s -- pageable-memory speed, not PCIe speed. cudaMemcpyAsync
            // from a std::vector cannot DMA, so it stages through a driver
            // bounce buffer and serialises against the stream. The kernel it
            // was feeding runs in 0.041 ms.
            //
            // The CSR only changes when a bond breaks, and health only changes
            // when something takes damage; at rest neither moves, so both
            // uploads collapse to a compare.
            std::uint64_t bytesUp = 0;
            const auto prepStart = std::chrono::steady_clock::now();
            if (csr.csrDirty || !m_bsCsrResident)
            {
                memcpy(m_bsPinGroupBegin, csr.groupBegin, sizeof(std::uint32_t) * groups);
                memcpy(m_bsPinGroupSize, csr.groupSize, sizeof(std::uint32_t) * groups);
                memcpy(m_bsPinMembers, csr.memberBlastBond,
                       sizeof(std::uint32_t) * csr.memberSlotCount);
                uploadBondStressAsync(m_bsGroupBegin, m_bsPinGroupBegin, groups, "bs groupBegin");
                uploadBondStressAsync(m_bsGroupSize, m_bsPinGroupSize, groups, "bs groupSize");
                uploadBondStressAsync(
                    m_bsMemberBlastBond, m_bsPinMembers, csr.memberSlotCount, "bs members");
                bytesUp += sizeof(std::uint32_t) * (2ull * groups + csr.memberSlotCount);
                m_bsCsrResident = true;
            }
            const std::size_t healthBytes = sizeof(float) * csr.blastBondCount;
            if (!m_bsHealthResident
                || memcmp(m_bsPinHealth, blastBondHealth, healthBytes) != 0)
            {
                memcpy(m_bsPinHealth, blastBondHealth, healthBytes);
                uploadBondStressAsync(
                    m_bsHealth, m_bsPinHealth, csr.blastBondCount, "bs health");
                bytesUp += healthBytes;
                m_bsHealthResident = true;
            }
            // Small, and it can change without a topology rebuild, so it is
            // refreshed every call rather than cached.
            if (csr.materialCount > m_bsMaterialCapacity)
            {
                cudaFree(m_bsMaterialLimits);
                m_bsMaterialLimits = nullptr;
                allocateDevice(m_bsMaterialLimits, 3u * csr.materialCount, "bs alloc materials");
                cudaFreeHost(m_bsPinMaterials);
                allocateHost(m_bsPinMaterials, 3u * csr.materialCount, "bs pin materials");
                m_bsMaterialCapacity = csr.materialCount;
            }
            memcpy(m_bsPinMaterials, csr.materialElasticLimits,
                   sizeof(float) * 3u * csr.materialCount);
            uploadBondStressAsync(
                m_bsMaterialLimits, m_bsPinMaterials, 3u * csr.materialCount, "bs materials");

            checkCuda(
                cudaMemsetAsync(
                    m_bsNodeOverstressed, 0, sizeof(std::uint8_t) * csr.graphNodeCount, m_bsStream),
                "bs clear node mask");
            checkCuda(
                cudaMemsetAsync(m_bsOverstressedCount, 0, 4u * sizeof(std::uint32_t), m_bsStream),
                "bs clear count");
            // Sentinel entry for the exclusive scan, so offset[groups] is the
            // total without a second reduction.
            checkCuda(
                cudaMemsetAsync(
                    m_bsGroupRemoveCount + groups, 0, sizeof(std::uint32_t), m_bsStream),
                "bs clear scan sentinel");

            bytesUp += sizeof(float) * 3ull * csr.materialCount;
            m_telemetry.bondStressBytesUp = bytesUp;
            m_telemetry.bondStressPrepMs =
                std::chrono::duration<float, std::milli>(
                    std::chrono::steady_clock::now() - prepStart).count();
            cudaEventRecord(m_bsEvUploadStop, m_bsStream);

            // Carry each reassigned slot's stored stress with it, so a slot
            // handed to a different group does not answer with the old one's
            // values on any tick that group is not reprocessed.
            for (std::uint32_t i = 0; i < csr.groupSwapCount; ++i)
            {
                const std::uint32_t dst = csr.groupSwapDst[i];
                const std::uint32_t src = csr.groupSwapSrc[i];
                if (dst == src || dst >= m_bsGroupCapacity || src >= m_bsGroupCapacity)
                {
                    continue;
                }
                cudaMemcpyAsync(m_bsGroupStressNormal + dst, m_bsGroupStressNormal + src,
                                sizeof(float), cudaMemcpyDeviceToDevice, m_bsStream);
                cudaMemcpyAsync(m_bsGroupStressShear + dst, m_bsGroupStressShear + src,
                                sizeof(float), cudaMemcpyDeviceToDevice, m_bsStream);
                cudaMemcpyAsync(m_bsGroupStressBend + dst, m_bsGroupStressBend + src,
                                sizeof(float), cudaMemcpyDeviceToDevice, m_bsStream);
                cudaMemcpyAsync(m_bsGroupNormal + 3 * dst, m_bsGroupNormal + 3 * src,
                                sizeof(float) * 3, cudaMemcpyDeviceToDevice, m_bsStream);
                cudaMemcpyAsync(m_bsGroupCentroid + 3 * dst, m_bsGroupCentroid + 3 * src,
                                sizeof(float) * 3, cudaMemcpyDeviceToDevice, m_bsStream);
            }

            const std::uint32_t block = 128;
            const std::uint32_t grid = (groups + block - 1) / block;
            bondStressWalk<<<grid, block, 0, m_bsStream>>>(
                m_bendGainMax,
                bondStressFibreBending() ? 1 : 0,
                m_bsGroupBegin, m_bsGroupSize, m_bsMemberBlastBond,
                m_bsBondNode0, m_bsBondNode1, m_bsBondMaterial,
                m_bsBondNormal, m_bsBondCentroid, m_bsBondNodeDisp,
                m_bsHealth, m_impulses, m_colScales,
                m_lengthScale * m_massScale,
                m_lengthScale * m_lengthScale * m_massScale,
                m_bsMaterialLimits, csr.materialCount,
                unbreakableLimit, groups,
                m_bsGroupStressNormal, m_bsGroupStressShear, m_bsGroupStressBend,
                m_bsGroupNormal, m_bsGroupCentroid,
                m_bsNodeOverstressed, m_bsGroupRemoveCount,
                m_bsRemoveFlag, m_bsOverstressedCount,
                m_bsOverGroupIds, m_bsOverGroupRecords, m_bsOverstressedCount + 1,
                m_bsOverstressedCount + 2, m_bsOverstressedCount + 3);
            checkCuda(cudaGetLastError(), "bs walk launch");

            std::size_t scanBytes = 0;
            checkCuda(
                cub::DeviceScan::ExclusiveSum(
                    nullptr, scanBytes, m_bsGroupRemoveCount, m_bsGroupRemoveOffset,
                    static_cast<int>(groups + 1), m_bsStream),
                "bs scan sizing");
            if (scanBytes > m_bsScanScratchBytes)
            {
                cudaFree(m_bsScanScratch);
                m_bsScanScratch = nullptr;
                allocateDevice(
                    reinterpret_cast<char*&>(m_bsScanScratch), scanBytes, "bs scan scratch");
                m_bsScanScratchBytes = scanBytes;
            }
            checkCuda(
                cub::DeviceScan::ExclusiveSum(
                    m_bsScanScratch, scanBytes, m_bsGroupRemoveCount, m_bsGroupRemoveOffset,
                    static_cast<int>(groups + 1), m_bsStream),
                "bs scan");

            bondStressCompactRemovals<<<grid, block, 0, m_bsStream>>>(
                m_bsGroupBegin, m_bsGroupSize, m_bsMemberBlastBond,
                m_bsRemoveFlag, m_bsGroupRemoveOffset, groups, m_bsRemoveList);
            checkCuda(cudaGetLastError(), "bs compact launch");
            cudaEventRecord(m_bsEvKernelStop, m_bsStream);

            // Fixed-size readbacks first, then one sync, then the removal list
            // whose length we only know after it.
            checkCuda(
                cudaMemcpyAsync(
                    m_bsHostCounts, m_bsOverstressedCount, sizeof(std::uint32_t),
                    cudaMemcpyDeviceToHost, m_bsStream),
                "bs read count");
            checkCuda(
                cudaMemcpyAsync(
                    m_bsHostCounts + 1, m_bsGroupRemoveOffset + groups, sizeof(std::uint32_t),
                    cudaMemcpyDeviceToHost, m_bsStream),
                "bs read remove total");
            checkCuda(
                cudaMemcpyAsync(
                    m_bsHostNodeOverstressed, m_bsNodeOverstressed,
                    sizeof(std::uint8_t) * csr.graphNodeCount,
                    cudaMemcpyDeviceToHost, m_bsStream),
                "bs read node mask");
            // The compact overstressed-group list rides the same readback. Its
            // length is not known until the sync, so a window sized from the
            // last tick is copied speculatively; if the count outgrows it the
            // host falls back to the lazy full fetch for one tick and the
            // window doubles.
            const std::uint32_t overWindow =
                m_bsOverWindow < groups ? m_bsOverWindow : groups;
            checkCuda(
                cudaMemcpyAsync(
                    m_bsHostCounts + 2, m_bsOverstressedCount + 1, sizeof(std::uint32_t),
                    cudaMemcpyDeviceToHost, m_bsStream),
                "bs read over group count");
            checkCuda(
                cudaMemcpyAsync(
                    m_bsHostCounts + 3, m_bsOverstressedCount + 2, 2u * sizeof(std::uint32_t),
                    cudaMemcpyDeviceToHost, m_bsStream),
                "bs read utilisation summary");
            if (overWindow != 0)
            {
                checkCuda(
                    cudaMemcpyAsync(
                        m_bsHostOverGroupIds, m_bsOverGroupIds,
                        sizeof(std::uint32_t) * overWindow,
                        cudaMemcpyDeviceToHost, m_bsStream),
                    "bs read over ids");
                checkCuda(
                    cudaMemcpyAsync(
                        m_bsHostOverGroupRecords, m_bsOverGroupRecords,
                        sizeof(float) * 9u * overWindow,
                        cudaMemcpyDeviceToHost, m_bsStream),
                    "bs read over records");
            }
            m_telemetry.bondStressBytesDown =
                3ull * sizeof(std::uint32_t)
                + sizeof(std::uint8_t) * csr.graphNodeCount
                + (sizeof(std::uint32_t) + 9u * sizeof(float)) * overWindow;
            m_bsVectorsFetched = false;
            m_bsStressFetched = false;
            m_bsVectorGroups = groups;
            cudaEventRecord(m_bsEvReadStop, m_bsStream);
            const auto bsSyncStart = std::chrono::steady_clock::now();
            m_telemetry.bondStressEnqueueMs =
                std::chrono::duration<float, std::milli>(bsSyncStart - prepStart).count()
                - m_telemetry.bondStressPrepMs;
            // Spin, then fall back to blocking.
            //
            // The device work here is ~0.13 ms. cudaStreamSynchronize under
            // the default scheduling policy is free to hand the core back to
            // the OS, and getting it back costs more than the work did.
            // Spinning on a query for a bounded number of iterations covers
            // the common case without giving up the thread; anything longer
            // than that is a real stall and worth blocking on.
            {
                bool done = false;
                for (int spin = 0; spin < 20000; ++spin)
                {
                    const cudaError_t q = cudaStreamQuery(m_bsStream);
                    if (q == cudaSuccess) { done = true; break; }
                    if (q != cudaErrorNotReady) { checkCuda(q, "bs spin"); }
                }
                if (!done)
                {
                    checkCuda(cudaStreamSynchronize(m_bsStream), "bs sync");
                }
            }
            const auto bsSyncEnd = std::chrono::steady_clock::now();
            m_telemetry.bondStressSyncMs =
                std::chrono::duration<float, std::milli>(bsSyncEnd - bsSyncStart).count();
            {
                float up = 0.0f, kern = 0.0f, read = 0.0f;
                cudaEventElapsedTime(&up, m_bsEvUploadStart, m_bsEvUploadStop);
                cudaEventElapsedTime(&kern, m_bsEvUploadStop, m_bsEvKernelStop);
                cudaEventElapsedTime(&read, m_bsEvKernelStop, m_bsEvReadStop);
                m_telemetry.bondStressUploadMs = up;
                m_telemetry.bondStressKernelMs = kern;
                m_telemetry.bondStressReadbackMs = read;
            }

            const std::uint32_t removeCount =
                m_bsHostCounts[1] > csr.memberSlotCount ? csr.memberSlotCount : m_bsHostCounts[1];
            if (removeCount != 0)
            {
                checkCuda(
                    cudaMemcpyAsync(
                        m_bsHostRemoveList, m_bsRemoveList,
                        sizeof(std::uint32_t) * removeCount,
                        cudaMemcpyDeviceToHost, m_bsStream),
                    "bs read removals");
                checkCuda(cudaStreamSynchronize(m_bsStream), "bs sync removals");
            }

            result.bondIndicesToRemove = m_bsHostRemoveList;
            result.removeCount = removeCount;
            result.overstressedBondCount = m_bsHostCounts[0];
            result.nodeOverstressed = m_bsHostNodeOverstressed;
            // Also deferred. Nothing reads a bond's stress unless its node
            // came back flagged, so on a tick with no overstress -- which is
            // every tick of a settled city -- these are never wanted.
            result.groupStressNormal = nullptr;
            result.groupStressShear = nullptr;
            // Left null on purpose: fetched only if someone asks.
            result.groupNormal = nullptr;
            result.groupCentroid = nullptr;
            {
                const std::uint32_t overCount =
                    m_bsHostCounts[2] > groups ? groups : m_bsHostCounts[2];
                const bool complete = overCount <= overWindow;
                result.overGroupIds = m_bsHostOverGroupIds;
                result.overGroupRecords = m_bsHostOverGroupRecords;
                result.overGroupCount = overCount;
                result.overGroupsComplete = complete;
                {
                    const std::uint32_t bits = m_bsHostCounts[3];
                    float utilMax = 0.0f;
                    std::memcpy(&utilMax, &bits, sizeof(float));
                    result.utilisationMax = utilMax;
                    result.bondsAboveHalfUtilisation = m_bsHostCounts[4];
                }
                m_telemetry.bondStressOverGroups = overCount;
                if (!complete)
                {
                    ++m_telemetry.bondStressOverWindowMisses;
                }
                // Track the count with headroom: doubling on a miss, and
                // shrinking only once the count has been well below the window
                // for a while, so a demolition burst does not thrash it.
                std::uint32_t want = overCount * 2u;
                if (want < 256u) want = 256u;
                if (!complete)
                {
                    m_bsOverWindow = want;
                    m_bsOverQuietTicks = 0;
                }
                else if (want * 2u < m_bsOverWindow)
                {
                    if (++m_bsOverQuietTicks > 600u)
                    {
                        m_bsOverWindow = want;
                        m_bsOverQuietTicks = 0;
                    }
                }
                else
                {
                    m_bsOverQuietTicks = 0;
                }
            }
            m_telemetry.bondStressHostMs =
                std::chrono::duration<float, std::milli>(
                    std::chrono::steady_clock::now() - bsHostStart).count();
        }
        catch (const std::exception&)
        {
            return false;
        }
        return true;
    }

    /// Stage a host buffer through pinned memory and enqueue an ASYNC H2D copy
    /// on the solver stream.
    ///
    /// The topology uploads were blocking `cudaMemcpy` straight out of
    /// `std::vector`, i.e. out of PAGEABLE memory, which cannot DMA: the driver
    /// bounces it through its own staging buffer a chunk at a time and the
    /// transfer runs at roughly 0.9 GB/s instead of the ~12 GB/s the link is
    /// good for. At ~2.6 MB per fracture tick that is ~2.2 ms of the host
    /// simply waiting, and it was 64% of all reclaimable host time in the
    /// solve. Exactly the same trap, and the same fix, as the bond-stress CSR.
    ///
    /// Lifetime: the staged bytes must outlive the async copy. The arena is
    /// only ever rewound at the START of applyTopologyChange, and every solve
    /// waits on m_statusReady before the next one begins, so a copy enqueued in
    /// one topology change has necessarily completed before the arena is reused
    /// in the next. Growth is the one case that could overlap a live copy, so
    /// it synchronises first.
    /// How the topology arrays reach the device. Three real modes, because the
    /// obvious two were not enough to find the right answer.
    ///
    ///   pageable : the original -- blocking cudaMemcpy out of pageable
    ///              std::vector, ~0.9 GB/s, 2.6 ms/solve of pure host stall.
    ///   async    : pinned-backed arrays, copies enqueued on the solver stream.
    ///              Host plan time 3.87 -> 1.99 ms/solve, and MEASURABLY WORSE
    ///              overall: the 5.3 MB transfer then overlaps the CG kernels
    ///              and competes with them for memory bandwidth, which cost
    ///              8.25% of device solve time (p=0.021, 16 pairs). The host
    ///              time it saved just became host WAITING, because this phase
    ///              is device-bound.
    ///   sync     : pinned-backed arrays, blocking copy. Keeps the win that
    ///              mattered -- no staging memcpy, and pinned memory DMAs at
    ///              full rate instead of being bounced -- while finishing the
    ///              transfer before the solve is enqueued, so it never steals
    ///              bandwidth from the kernels.
    ///
    /// Default `async` (was `sync`). The measurement above that rejected async
    /// -- 8.25% of device solve time lost to the transfer competing with the CG
    /// kernels for bandwidth -- was taken against a CG loop that has since got
    /// roughly 4x cheaper (padded per-island reductions, device-side early
    /// exit). The competing kernels are now short enough that overlapping wins:
    /// re-measured on a 600-tick demolition at 298k bonds, the fracture tick
    /// goes 5.92 -> 5.47 ms wall, async faster in 3/3 paired runs. Host plan
    /// falls 3.59 -> 2.76 ms and roughly half of that does reappear as host
    /// waiting, exactly as the original note predicted -- but only half, so the
    /// trade is now net positive rather than net negative.
    ///
    /// This is worth re-checking whenever the device solve changes materially
    /// again; it has already flipped once.
    enum class TopoUploadMode { Pageable, Async, Sync };
    static TopoUploadMode topoUploadMode()
    {
        static const TopoUploadMode mode = [] {
            const char* raw = std::getenv("BLAST_TOPO_UPLOAD");
            if (raw != nullptr)
            {
                const std::string value(raw);
                if (value == "pageable") { return TopoUploadMode::Pageable; }
                if (value == "async")    { return TopoUploadMode::Async; }
                if (value == "sync")     { return TopoUploadMode::Sync; }
            }
            return TopoUploadMode::Async;
        }();
        return mode;
    }

    void stageUpload(void* dst, const void* src, std::size_t bytes, const char* name)
    {
        if (bytes == 0)
        {
            return;
        }
        if (topoUploadMode() == TopoUploadMode::Pageable)
        {
            // Faithfully reproduce the ORIGINAL cost structure for A/B: a
            // BLOCKING copy out of PAGEABLE memory. Copying via a pageable
            // bounce is necessary because the sources are pinned now, and a
            // blocking copy from pinned memory is a different (much faster)
            // thing than the one this change replaced. An arm that does not
            // reproduce the old behaviour measures nothing.
            if (m_pageableBounce.size() < bytes)
            {
                m_pageableBounce.resize(bytes);
            }
            std::memcpy(m_pageableBounce.data(), src, bytes);
            checkCuda(
                cudaMemcpy(dst, m_pageableBounce.data(), bytes, cudaMemcpyHostToDevice),
                name);
            return;
        }
        if (m_topoStagingUsed + bytes > m_topoStagingBytes)
        {
            checkCuda(cudaStreamSynchronize(m_stream), "sync before staging growth");
            const std::size_t want = (m_topoStagingUsed + bytes) * 2u;
            if (m_topoStaging)
            {
                cudaFreeHost(m_topoStaging);
                m_topoStaging = nullptr;
            }
            checkCuda(cudaMallocHost(&m_topoStaging, want), "alloc topology staging");
            ++m_statTopoGrowths;
            m_topoStagingBytes = want;
            m_topoStagingUsed = 0;
        }
        m_statTopoBytes += bytes;
        ++m_statTopoCopies;
        // If the source is ALREADY pinned, DMA straight out of it: no staging
        // copy at all. Querying attributes supports ordinary host pointers
        // without manufacturing an API error (CUDA 11+ reports Unregistered).
        // Genuine CUDA failures must propagate rather than be cleared as a
        // supposedly expected result of a pointer probe.
        cudaPointerAttributes attributes{};
        checkCuda(cudaPointerGetAttributes(&attributes, src), "query topology source memory");
        if (attributes.type == cudaMemoryTypeHost)
        {
            // Async on the SOLVER stream in both modes. A blocking cudaMemcpy
            // would run on the legacy default stream, which implicitly
            // synchronises with every stream on the device -- so each of the
            // fifteen copies would wait for whatever the GPU already had
            // queued. Measured, that made "sync" mode 1.99 ms of mostly
            // waiting, against 0.08 ms for the same bytes enqueued async.
            //
            // Sync mode differs only in WHEN it waits: once, after all fifteen
            // are enqueued (see applyTopologyChange), so the transfer is
            // complete before the solve kernels are enqueued and cannot
            // compete with them for memory bandwidth.
            checkCuda(
                cudaMemcpyAsync(dst, src, bytes, cudaMemcpyHostToDevice, m_stream),
                name);
            return;
        }
        char* slot = static_cast<char*>(m_topoStaging) + m_topoStagingUsed;
        const auto cpStart = StatClock::now();
        std::memcpy(slot, src, bytes);
        m_statStageCopyMs += statMs(cpStart);
        m_topoStagingUsed += bytes;
        checkCuda(
            cudaMemcpyAsync(dst, slot, bytes, cudaMemcpyHostToDevice, m_stream),
            name);
    }

    template <typename T>
    void uploadBondStress(T* dst, const T* src, std::uint32_t count, const char* name)
    {
        checkCuda(cudaMemcpy(dst, src, sizeof(T) * count, cudaMemcpyHostToDevice), name);
    }

    template <typename T>
    void uploadBondStressAsync(T* dst, const T* src, std::uint32_t count, const char* name)
    {
        checkCuda(
            cudaMemcpyAsync(dst, src, sizeof(T) * count, cudaMemcpyHostToDevice, m_bsStream),
            name);
    }

    /// Grow-only: a resync can add groups back, and reallocating on every
    /// shrink would churn for nothing.
    void ensureBondStressCapacity(const ExtStressGpuBondStressTopology& topology)
    {
        if (topology.groupCount > m_bsGroupCapacity)
        {
            freeBondStressGroupBuffers();
            const std::uint32_t n = topology.groupCount;
            allocateDevice(m_bsGroupBegin, n, "bs alloc groupBegin");
            allocateDevice(m_bsGroupSize, n, "bs alloc groupSize");
            allocateDevice(m_bsGroupStressNormal, n, "bs alloc sn");
            allocateDevice(m_bsGroupStressShear, n, "bs alloc ss");
            allocateDevice(m_bsGroupStressBend, n, "bs alloc sb");
            allocateDevice(m_bsOverGroupIds, n, "bs alloc over ids");
            allocateDevice(m_bsOverGroupRecords, 9u * n, "bs alloc over records");
            allocateHost(m_bsHostOverGroupIds, n, "bs host over ids");
            allocateHost(m_bsHostOverGroupRecords, 9u * n, "bs host over records");
            allocateHost(m_bsHostGroupStressBend, n, "bs host sb");
            allocateDevice(m_bsGroupNormal, 3u * n, "bs alloc normal");
            allocateDevice(m_bsGroupCentroid, 3u * n, "bs alloc centroid");
            allocateDevice(m_bsGroupRemoveCount, n + 1u, "bs alloc removeCount");
            allocateDevice(m_bsGroupRemoveOffset, n + 1u, "bs alloc removeOffset");
            allocateHost(m_bsPinGroupBegin, n, "bs pin groupBegin");
            allocateHost(m_bsPinGroupSize, n, "bs pin groupSize");
            allocateHost(m_bsHostGroupStressNormal, n, "bs host sn");
            allocateHost(m_bsHostGroupStressShear, n, "bs host ss");
            allocateHost(m_bsHostGroupNormal, 3u * n, "bs host normal");
            allocateHost(m_bsHostGroupCentroid, 3u * n, "bs host centroid");
            m_bsGroupCapacity = n;
        }
        if (topology.memberSlotCount > m_bsSlotCapacity)
        {
            cudaFree(m_bsMemberBlastBond); m_bsMemberBlastBond = nullptr;
            cudaFree(m_bsRemoveFlag); m_bsRemoveFlag = nullptr;
            cudaFree(m_bsRemoveList); m_bsRemoveList = nullptr;
            cudaFreeHost(m_bsHostRemoveList); m_bsHostRemoveList = nullptr;
            const std::uint32_t n = topology.memberSlotCount;
            allocateDevice(m_bsMemberBlastBond, n, "bs alloc members");
            allocateDevice(m_bsRemoveFlag, n, "bs alloc removeFlag");
            allocateDevice(m_bsRemoveList, n, "bs alloc removeList");
            allocateHost(m_bsHostRemoveList, n, "bs host removeList");
            cudaFreeHost(m_bsPinMembers);
            allocateHost(m_bsPinMembers, n, "bs pin members");
            m_bsCsrResident = false;
            m_bsSlotCapacity = n;
        }
        if (topology.blastBondCount > m_bsBondCapacity)
        {
            cudaFree(m_bsBondNode0); m_bsBondNode0 = nullptr;
            cudaFree(m_bsBondNode1); m_bsBondNode1 = nullptr;
            cudaFree(m_bsBondMaterial); m_bsBondMaterial = nullptr;
            cudaFree(m_bsBondNormal); m_bsBondNormal = nullptr;
            cudaFree(m_bsBondCentroid); m_bsBondCentroid = nullptr;
            cudaFree(m_bsBondNodeDisp); m_bsBondNodeDisp = nullptr;
            cudaFree(m_bsHealth); m_bsHealth = nullptr;
            const std::uint32_t n = topology.blastBondCount;
            allocateDevice(m_bsBondNode0, n, "bs alloc node0");
            allocateDevice(m_bsBondNode1, n, "bs alloc node1");
            allocateDevice(m_bsBondMaterial, n, "bs alloc material");
            allocateDevice(m_bsBondNormal, 3u * n, "bs alloc bnormal");
            allocateDevice(m_bsBondCentroid, 3u * n, "bs alloc bcentroid");
            allocateDevice(m_bsBondNodeDisp, 3u * n, "bs alloc bdisp");
            allocateDevice(m_bsHealth, n, "bs alloc health");
            cudaFreeHost(m_bsPinHealth);
            allocateHost(m_bsPinHealth, n, "bs pin health");
            m_bsHealthResident = false;
            m_bsBondCapacity = n;
        }
        if (topology.graphNodeCount > m_bsNodeCapacity)
        {
            cudaFree(m_bsNodeOverstressed); m_bsNodeOverstressed = nullptr;
            cudaFreeHost(m_bsHostNodeOverstressed); m_bsHostNodeOverstressed = nullptr;
            allocateDevice(m_bsNodeOverstressed, topology.graphNodeCount, "bs alloc node mask");
            allocateHost(
                m_bsHostNodeOverstressed, topology.graphNodeCount, "bs host node mask");
            m_bsNodeCapacity = topology.graphNodeCount;
        }
        if (m_bsOverstressedCount == nullptr)
        {
            // [0] overstressed bonds, [1] overstressed groups,
            // [2] max utilisation (float bits), [3] bonds at >= half utilisation.
            allocateDevice(m_bsOverstressedCount, 4, "bs alloc count");
            // [0] overstressed bonds, [1] removal total, [2] overstressed groups,
            // [3] max utilisation bits, [4] bonds at >= half utilisation.
            allocateHost(m_bsHostCounts, 5, "bs host counts");
        }
    }

    void freeBondStressGroupBuffers()
    {
        cudaFree(m_bsGroupBegin); m_bsGroupBegin = nullptr;
        cudaFree(m_bsGroupSize); m_bsGroupSize = nullptr;
        cudaFree(m_bsGroupStressNormal); m_bsGroupStressNormal = nullptr;
        cudaFree(m_bsGroupStressShear); m_bsGroupStressShear = nullptr;
        cudaFree(m_bsGroupStressBend); m_bsGroupStressBend = nullptr;
        cudaFree(m_bsOverGroupIds); m_bsOverGroupIds = nullptr;
        cudaFree(m_bsOverGroupRecords); m_bsOverGroupRecords = nullptr;
        cudaFreeHost(m_bsHostOverGroupIds); m_bsHostOverGroupIds = nullptr;
        cudaFreeHost(m_bsHostOverGroupRecords); m_bsHostOverGroupRecords = nullptr;
        cudaFreeHost(m_bsHostGroupStressBend); m_bsHostGroupStressBend = nullptr;
        cudaFree(m_bsGroupNormal); m_bsGroupNormal = nullptr;
        cudaFree(m_bsGroupCentroid); m_bsGroupCentroid = nullptr;
        cudaFree(m_bsGroupRemoveCount); m_bsGroupRemoveCount = nullptr;
        cudaFree(m_bsGroupRemoveOffset); m_bsGroupRemoveOffset = nullptr;
        cudaFreeHost(m_bsPinGroupBegin); m_bsPinGroupBegin = nullptr;
        cudaFreeHost(m_bsPinGroupSize); m_bsPinGroupSize = nullptr;
        cudaFreeHost(m_bsHostGroupStressNormal); m_bsHostGroupStressNormal = nullptr;
        cudaFreeHost(m_bsHostGroupStressShear); m_bsHostGroupStressShear = nullptr;
        cudaFreeHost(m_bsHostGroupNormal); m_bsHostGroupNormal = nullptr;
        cudaFreeHost(m_bsHostGroupCentroid); m_bsHostGroupCentroid = nullptr;
    }

    void freeBondStress()
    {
        freeBondStressGroupBuffers();
        cudaFree(m_bsMemberBlastBond);
        cudaFree(m_bsRemoveFlag);
        cudaFree(m_bsRemoveList);
        cudaFree(m_bsBondNode0);
        cudaFree(m_bsBondNode1);
        cudaFree(m_bsBondMaterial);
        cudaFree(m_bsBondNormal);
        cudaFree(m_bsBondCentroid);
        cudaFree(m_bsBondNodeDisp);
        cudaFree(m_bsHealth);
        cudaFree(m_bsNodeOverstressed);
        cudaFree(m_bsOverstressedCount);
        cudaFree(m_bsScanScratch);
        cudaFree(m_bsMaterialLimits);
        cudaFreeHost(m_bsPinMembers);
        cudaFreeHost(m_bsPinHealth);
        cudaFreeHost(m_bsPinMaterials);
        cudaFreeHost(m_bsHostRemoveList);
        cudaFreeHost(m_bsHostNodeOverstressed);
        cudaFreeHost(m_bsHostCounts);
        if (m_bsStream) { cudaStreamDestroy(m_bsStream); m_bsStream = nullptr; }
    }

    bool hasPendingTopologyChange() const override
    {
        return m_topologyDirty || !m_pendingImpulseSwaps.empty();
    }

    bool flushImpulsePermutation() override
    {
        // Every other public entry point pushes PhysX's CUDA context before
        // touching the device; these did not, so their allocations, streams
        // and launches landed in whatever context the calling thread happened
        // to have -- the primary one -- while the impulses they read were
        // allocated under the guard in PhysX's. Cross-context by construction,
        // and the reason a tiny kernel could not be submitted without the GPU
        // switching contexts around it.
        ContextGuard context(m_cudaContext);
        if (m_pendingImpulseSwaps.empty())
        {
            return true;
        }
        try
        {
            for (const auto& swap : m_pendingImpulseSwaps)
            {
                if (swap.first != swap.second)
                {
                    checkCuda(
                        cudaMemcpy(
                            m_impulses + swap.first,
                            m_impulses + swap.second,
                            sizeof(AngLin),
                            cudaMemcpyDeviceToDevice),
                        "flush impulse swap");
                }
            }
            m_pendingImpulseSwaps.clear();
        }
        catch (const std::exception&)
        {
            return false;
        }
        return true;
    }

    void resetWarmStart() override
    {
        ContextGuard context(m_cudaContext);
        if (m_deviceTopology) {
            // Order the reset behind asynchronous topology/solve work instead
            // of racing the nonblocking solver stream through the default one.
            checkCuda(cudaMemsetAsync(m_impulses,0,sizeof(AngLin)*m_bondCount,m_stream), "reset resident warm start");
            checkCuda(cudaEventRecord(m_statusReady,m_stream), "record resident warm reset");
        } else {
            checkCuda(cudaMemset(m_impulses, 0, sizeof(AngLin) * m_bondCount), "reset warm start");
        }
        m_hasWarmStart = false;
        // The impulses these flags certified are gone, so nothing may be
        // skipped against them.
        invalidateSettledBaseline();
    }

    std::uint32_t nodeCount() const override
    {
        return m_nodeCount;
    }

    std::uint32_t bondCount() const override
    {
        return m_bondCount;
    }

    const ExtStressGpuTelemetry& telemetry() const override
    {
        return m_telemetry;
    }

private:
    /// Read back per-island residual^2 and tolerance^2 and record how far past
    /// tolerance the solve stopped. Diagnostic only; gated on graph stats.
    void accumulateResidualStats()
    {
        const std::size_t n = m_islandCount;
        m_statResGrad.resize(n);
        m_statResDelta.resize(n);
        m_statResActive.resize(n);
        if (cudaMemcpy(m_statResGrad.data(), m_gradientSquared,
                       sizeof(float) * n, cudaMemcpyDeviceToHost) != cudaSuccess ||
            cudaMemcpy(m_statResDelta.data(), m_deltaSquared,
                       sizeof(float) * n, cudaMemcpyDeviceToHost) != cudaSuccess ||
            cudaMemcpy(m_statResActive.data(), m_islandActive,
                       sizeof(std::uint32_t) * n, cudaMemcpyDeviceToHost) != cudaSuccess)
        {
            cudaGetLastError();
            return;
        }
        for (std::size_t i = 0; i < n; ++i)
        {
            // The population is "islands this solve SEEDED", i.e. not skipped.
            //
            // Two wrong filters were tried first and both are instructive.
            // Filtering on nothing counts skipped islands, whose deltaSquared
            // and gradientSquared still hold values from whenever they last
            // ran -- that measures history, and it flatters whichever arm
            // skips more (the warm-started one). Filtering on islandActive==1
            // is circular in the other direction: checkConvergencePerIsland
            // CLEARS islandActive when an island converges, so the survivors
            // are by definition the ones that failed, and the answer is always
            // "100% over tolerance".
            //
            // islandSkip is the honest marker: it says what this solve was
            // asked to do, before it knew how it would go.
            if (m_hostIslandSkip != nullptr && m_hostIslandSkip[i] != 0u)
            {
                continue;
            }
            const float d = m_statResDelta[i];
            const float g = m_statResGrad[i];
            if (!(d > 0.0f) || !(g >= 0.0f))
            {
                continue;   // island carries no target: not part of this solve
            }
            const double ratio = std::sqrt(double(g) / double(d));
            m_statResSum += ratio;
            ++m_statResCount;
            if (ratio > m_statResMax) { m_statResMax = ratio; }
            if (ratio > 1.0) { ++m_statResOverTol; }
        }
    }

    bool enqueueSolve(
        const ExtStressGpuImpulse* nodeVelocities,
        const ExtStressGpuSolveParams& params,
        bool deviceInput = false, void* producerReady = nullptr)
    {
        if (m_deviceTopology || m_deviceTopologyFailed) return false;
        // Latch the bending policy the host resolved, so every kernel this
        // solve launches uses the same one the CPU walk does.
        m_bendGainMax = params.bendGainMax;

        if (!nodeVelocities || params.maxIterations == 0)
        {
            return false;
        }
        // Sampled HERE, not in launchSolve: that runs inside CUDA graph
        // capture, where a synchronous memcpy is illegal and returns 900
        // (operation not permitted while capturing) -- which corrupts the
        // capture rather than just failing the read.
        if (islandTraceEnabled())
        {
            checkCuda(cudaStreamSynchronize(m_stream), "island trace pre-sync");
            m_dbgSumBefore = debugImpulseMagnitude();
            m_dbgWarm = params.warmStart && m_hasWarmStart;
        }
        if (m_topologyDirty)
        {
            const auto topoStart = StatClock::now();
            applyTopologyChange();
            m_statTopoMs += statMs(topoStart);
            ++m_statTopoCalls;
        }
        if (m_bondCount == 0)
        {
            return false;   // nothing bonded left; the caller falls back to its CPU path
        }

        m_telemetry = {};
        m_telemetry.islandCount = m_islandCount;
        m_solveWasNoOp = false;

        // The settled baseline certifies "these impulses are what THIS solve
        // would produce". Change the solve -- tolerance, iteration budget,
        // damage, warm start -- and that stops being true: an island left at
        // its own tolerance by a loose solve would be refined by a tighter
        // one, so freezing it would silently pin the scene to the loosest
        // settings it ever ran with. graphMatches is the same test that
        // decides whether the captured CUDA graph is still valid, which is not
        // a coincidence: both ask whether this is the same solve as last time.
        if (!graphMatches(params, params.warmStart && m_hasWarmStart))
        {
            invalidateSettledBaseline();
        }

        // Skipping is only coherent while warm-starting. Without a warm start
        // initializeSolve ZEROES every bond it touches, so a settled island
        // that kept its impulses and a solved one that started from zero would
        // be two different physics in one graph. The kernels apply the same
        // condition (launchSolve), so the two sides cannot drift apart.
        const bool skipping =
            params.skipSettledIslands && params.warmStart && m_hasWarmStart;

        if (deviceInput && producerReady)
        {
            checkCuda(cudaStreamWaitEvent(m_stream,
                reinterpret_cast<cudaEvent_t>(producerReady), 0),
                "wait for device stress producer");
        }
        // Switching back to host input must not compare against an obsolete
        // host mirror. Revalidate the settled baseline on that first host solve.
        if (!deviceInput && !m_hostInputValid)
        {
            invalidateSettledBaseline();
        }
        if (skipping)
        {
            const auto skipStart = StatClock::now();
            if (deviceInput) { planDeviceSettledSkip(nodeVelocities); }
            else { planSettledSkip(nodeVelocities); }
            m_statPlanSkipMs += statMs(skipStart);
        }
        else
        {
            if (!deviceInput)
            {
                std::memcpy(m_hostInput, nodeVelocities,
                    sizeof(ExtStressGpuImpulse) * m_nodeCount);
            }
            std::fill(m_hostIslandSkip, m_hostIslandSkip + m_islandCount, 0u);
            m_changedBonds.resize(m_bondCount);
            for (std::uint32_t i = 0; i < m_bondCount; ++i) { m_changedBonds[i] = i; }
            m_changedNodes.clear();
        }
        m_hostInputValid = !deviceInput;

        const bool noOp = skipping && m_changedNodes.empty()
            && m_telemetry.islandsSkipped == m_islandCount;
        if (noOp && !deviceInput)
        {
            m_solveWasNoOp = true;
            m_changedBonds.clear();
            m_telemetry.converged = true;
            return true;
        }

        checkCuda(cudaEventRecord(m_uploadStart, m_stream), "record upload start");
        if (skipping && !noOp)
        {
            checkCuda(cudaMemcpyAsync(m_islandSkip, m_hostIslandSkip,
                sizeof(std::uint32_t) * m_islandCount, cudaMemcpyHostToDevice,
                m_stream), "upload island skip mask");
            m_telemetry.hostToDeviceBytes +=
                sizeof(std::uint32_t) * static_cast<std::uint64_t>(m_islandCount);
        }
        if (deviceInput)
        {
            checkCuda(cudaMemcpyAsync(m_input, nodeVelocities,
                sizeof(ExtStressGpuImpulse) * m_nodeCount, cudaMemcpyDeviceToDevice,
                m_stream), "copy device stress inputs");
            m_telemetry.deviceToDeviceBytes +=
                sizeof(ExtStressGpuImpulse) * static_cast<std::uint64_t>(m_nodeCount);
        }
        else if (skipping) { uploadChangedVelocities(); }
        else
        {
            checkCuda(cudaMemcpyAsync(m_input, m_hostInput,
                sizeof(ExtStressGpuImpulse) * m_nodeCount, cudaMemcpyHostToDevice,
                m_stream), "upload stress inputs");
            m_telemetry.hostToDeviceBytes +=
                sizeof(ExtStressGpuImpulse) * static_cast<std::uint64_t>(m_nodeCount);
        }
        checkCuda(cudaEventRecord(m_uploadStop, m_stream), "record upload stop");

        if (noOp)
        {
            // Even nodes outside a live island must refresh their baseline.
            // Complete that copy before returning ownership to the producer.
            const auto waitStart = StatClock::now();
            checkCuda(cudaEventSynchronize(m_uploadStop), "wait for device input copy");
            m_activeListSyncMilliseconds += statMs(waitStart);
            m_solveWasNoOp = true;
            m_changedBonds.clear();
            m_telemetry.converged = true;
            return true;
        }

        // After the mask upload (compaction reads it), before the graph
        // launch (the kernels read the lists).
        const auto refreshStart = StatClock::now();
        refreshActiveLists(skipping);
        m_statRefreshMs += statMs(refreshStart);

        checkCuda(cudaEventRecord(m_solveStart, m_stream), "record solve start");
        executeSolve(params);
        checkCuda(cudaEventRecord(m_solveStop, m_stream), "record solve stop");
        checkCuda(
            cudaMemcpyAsync(
                m_hostStatus,
                m_status,
                sizeof(SolveStatus),
                cudaMemcpyDeviceToHost,
                m_stream),
            "read stress status");
        checkCuda(
            cudaMemcpyAsync(
                m_hostIslandConvergedPinned,
                m_islandConverged,
                sizeof(std::uint32_t) * m_islandCount,
                cudaMemcpyDeviceToHost,
                m_stream),
            "read per-island convergence");
        // Bond health is an input to the solve -- but only at the boundary,
        // since the kernels read nothing from it but `health <= 0`. Partial
        // damage therefore cannot change an island's answer, and a BREAK
        // always can. Four bytes per solve buys the difference.
        checkCuda(
            cudaMemcpyAsync(
                m_hostBrokenCount,
                m_brokenCount,
                sizeof(std::uint32_t),
                cudaMemcpyDeviceToHost,
                m_stream),
            "read broken bond count");
        m_telemetry.deviceToHostBytes +=
            sizeof(SolveStatus)
            + sizeof(std::uint32_t) * static_cast<std::uint64_t>(m_islandCount);
        checkCuda(cudaEventRecord(m_statusReady, m_stream), "record status ready");
        return true;
    }

    /**
     * Rebuild the compacted active lists when the skip set they encode has
     * changed. One kernel pass per array plus an 8-byte synchronous readback
     * of the counts -- the sync is what lets executeSolve know, on the host,
     * whether the baked launch capacity still covers the lists. In a settled
     * scene the skip set is stable and this runs never; during demolition it
     * runs at most once per tick.
     */
    void refreshActiveLists(bool skipping)
    {
        const std::uint32_t* mask = skipping ? m_islandSkip : nullptr;
        const bool maskChanged = skipping
            && (m_prevIslandSkip.size() != m_islandCount
                || std::memcmp(
                       m_prevIslandSkip.data(),
                       m_hostIslandSkip,
                       sizeof(std::uint32_t) * m_islandCount)
                       != 0);
        if (!m_activeListsDirty && m_prevListsSkipping == skipping && !maskChanged)
        {
            ++m_statListSkips;
            return;
        }
        ++m_statListRefreshes;
        // Flag, then order-preserving select. The flag buffer is shared by the
        // two selects; the stream orders bond-select before node-flag, so the
        // reuse cannot race. DeviceSelect writes each count straight into its
        // m_activeCounts slot, which is why the memset the atomic append
        // needed is gone.
        cub::CountingInputIterator<std::uint32_t> identity(0u);
        flagActiveBonds<<<
            (m_bondCount + kBlockSize - 1) / kBlockSize,
            kBlockSize,
            0,
            m_stream>>>(m_bondIsland, mask, m_bondCount, m_activeFlags);
        checkCuda(
            cub::DeviceSelect::Flagged(
                m_selectScratch,
                m_selectScratchBytes,
                identity,
                m_activeFlags,
                m_activeBonds,
                m_activeCounts,
                static_cast<int>(m_bondCount),
                m_stream),
            "select active bonds");
        flagActiveNodes<<<
            (m_nodeCount + kBlockSize - 1) / kBlockSize,
            kBlockSize,
            0,
            m_stream>>>(m_nodeIsland, mask, m_nodeCount, m_activeFlags);
        checkCuda(
            cub::DeviceSelect::Flagged(
                m_selectScratch,
                m_selectScratchBytes,
                identity,
                m_activeFlags,
                m_activeNodes,
                m_activeCounts + 1,
                static_cast<int>(m_nodeCount),
                m_stream),
            "select active nodes");
        checkCuda(
            cudaMemcpyAsync(
                m_hostActiveCounts,
                m_activeCounts,
                sizeof(std::uint32_t) * 2,
                cudaMemcpyDeviceToHost,
                m_stream),
            "read active counts");
        if (!fullLaunchCapacity())
        {
            // Priced separately: this is the host BLOCKED, not the host
            // working, and only the latter is reclaimable by faster host code.
            const auto syncStart = std::chrono::steady_clock::now();
            checkCuda(cudaStreamSynchronize(m_stream), "sync active counts");
            const double midSync =
                std::chrono::duration<double, std::milli>(
                    std::chrono::steady_clock::now() - syncStart)
                    .count();
            m_activeListSyncMilliseconds += static_cast<float>(midSync);
            m_statMidSyncMs += midSync;
            m_statLastMidSync = midSync;
        }
        if (!fullLaunchCapacity())
        {
            m_activeBondCount = m_hostActiveCounts[0];
            m_activeNodeCount = m_hostActiveCounts[1];
        }
        if (skipping)
        {
            m_prevIslandSkip.assign(m_hostIslandSkip, m_hostIslandSkip + m_islandCount);
        }
        else
        {
            m_prevIslandSkip.clear();
        }
        m_prevListsSkipping = skipping;
        m_activeListsDirty = false;
    }

    /**
     * Decide which islands are settled, and refresh the baseline in the same
     * pass.
     *
     * The predicate is the CPU solver's, unchanged: an island is settled when
     * every one of its DYNAMIC nodes carries a velocity identical to the one
     * it was last solved with, AND that solve reached tolerance. Static nodes
     * are excluded because they are boundaries whose velocity is multiplied by
     * a zero inverse inertia -- they cannot change an island's answer, and
     * including them would make a moving kinematic support re-solve the whole
     * city for nothing.
     */
    void planSettledSkip(const ExtStressGpuImpulse* nodeVelocities)
    {
        const bool haveBaseline = m_settledBaselineValid;
        m_islandDirty.assign(m_islandCount, haveBaseline ? 0u : 1u);
        m_changedNodes.clear();
        for (std::uint32_t i = 0; i < m_nodeCount; ++i)
        {
            if (haveBaseline && velocityBitsEqual(nodeVelocities[i], m_hostInput[i]))
            {
                continue;
            }
            m_hostInput[i] = nodeVelocities[i];
            m_changedNodes.push_back(i);
            const std::uint32_t id = m_hostNodeIsland[i];
            if (id != kNoIsland)
            {
                m_islandDirty[id] = 1;
            }
        }

        finishSettledSkip(haveBaseline);
    }

    void planDeviceSettledSkip(const ExtStressGpuImpulse* nodeVelocities)
    {
        const bool haveBaseline = m_settledBaselineValid;
        m_islandDirty.assign(m_islandCount, haveBaseline ? 0u : 1u);
        m_changedNodes.clear();
        if (haveBaseline)
        {
            checkCuda(cudaMemsetAsync(m_deviceIslandDirty, 0,
                sizeof(std::uint32_t) * m_islandCount, m_stream), "clear input dirty flags");
            markChangedInputIslands<<<(m_nodeCount + kBlockSize - 1) / kBlockSize,
                kBlockSize, 0, m_stream>>>(nodeVelocities, m_input, m_nodeIsland,
                    m_nodeCount, m_deviceIslandDirty);
            checkCuda(cudaGetLastError(), "compare device stress inputs");
            checkCuda(cudaMemcpyAsync(m_hostIslandSkip, m_deviceIslandDirty,
                sizeof(std::uint32_t) * m_islandCount, cudaMemcpyDeviceToHost,
                m_stream), "read input dirty flags");
            m_telemetry.deviceToHostBytes +=
                sizeof(std::uint32_t) * static_cast<std::uint64_t>(m_islandCount);
            checkCuda(cudaEventRecord(m_statusReady, m_stream), "record input flags ready");
            const auto waitStart = StatClock::now();
            checkCuda(cudaEventSynchronize(m_statusReady), "wait for input flags");
            m_activeListSyncMilliseconds += statMs(waitStart);
            for (std::uint32_t k = 0; k < m_islandCount; ++k)
            {
                m_islandDirty[k] = m_hostIslandSkip[k] != 0u;
            }
        }
        finishSettledSkip(haveBaseline);
    }

    void finishSettledSkip(bool haveBaseline)
    {
        // Nodes whose bonds broke or were removed since the last solve: their
        // islands must re-solve regardless of the velocity compare, because
        // frozen impulses no longer describe the changed topology.
        for (const std::uint32_t node : m_forceDirtyNodes)
        {
            if (node < m_nodeCount)
            {
                const std::uint32_t id = m_hostNodeIsland[node];
                if (id != kNoIsland)
                {
                    m_islandDirty[id] = 1;
                }
            }
        }
        m_forceDirtyNodes.clear();

        m_changedBonds.clear();
        std::uint32_t skipped = 0;
        for (std::uint32_t k = 0; k < m_islandCount; ++k)
        {
            // An island may be skipped only once it has CONVERGED. Skipping a
            // stable-but-unconverged island freezes it at whatever partial
            // answer the iteration budget happened to reach, permanently.
            //
            // That was the depth-truncation defect. Conjugate gradient
            // propagates load roughly one graph hop per iteration, so a
            // structure deeper than the budget cannot finish in one solve. It
            // would then go quiet -- inputs unchanged -- and be skipped for
            // ever, pinned at exactly `iterations` panels' worth of load.
            // Measured on a column: footing stress plateaued at exactly
            // 25 panels at 25 iterations and 50 at 50, bit-identical from depth
            // 48 to 128. A 10-floor building is far deeper than that, so the
            // city read as unloaded and stood up under the GPU solver while the
            // CPU solver -- whose skip has always required convergence --
            // collapsed it. One cause, both symptoms.
            //
            // `skipStableUnconverged` was meant to stop unconverged islands
            // re-solving for ever at rest. It cannot do that safely: they never
            // converge BECAUSE they are skipped. The way out is the documented
            // one -- pursue convergence (unconvergedExtraUpdates), converge in
            // the first second, and skip at ~zero cost thereafter.
            const bool skip =
                haveBaseline && !m_islandDirty[k] && m_hostIslandConverged[k] != 0u;
            m_hostIslandSkip[k] = skip ? 1u : 0u;
            if (skip)
            {
                ++skipped;
                continue;
            }
            if (m_bondsByIslandValid)
            {
                for (std::uint32_t t = m_islandBondBegin[k]; t < m_islandBondBegin[k + 1]; ++t)
                {
                    m_changedBonds.push_back(m_bondsByIsland[t]);
                }
            }
        }
        if (!m_bondsByIslandValid)
        {
            // Bonds moved under the island->bond index since it was built, so
            // enumerate from the labels instead, which removeBond keeps
            // current. One pass over bonds rather than a gather per island: no
            // worse than the gather in exactly the case this runs -- a tick on
            // which something broke, where little or nothing is skippable
            // anyway -- and it lets the repartition be deferred.
            m_changedBonds.clear();
            for (std::uint32_t b = 0; b < m_bondCount; ++b)
            {
                const std::uint32_t island = m_hostBondIsland[b];
                if (island != kNoIsland && m_hostIslandSkip[island] == 0u)
                {
                    m_changedBonds.push_back(b);
                }
            }
        }
        m_telemetry.islandsSkipped = skipped;
        if (s_debug)
        {
            std::uint32_t clean = 0;
            std::uint32_t converged = 0;
            for (std::uint32_t k = 0; k < m_islandCount; ++k)
            {
                clean += m_islandDirty[k] ? 0u : 1u;
                converged += m_hostIslandConverged[k] ? 1u : 0u;
            }
            if ((m_debugSolves++ % 60u) == 0u)
            {
                std::fprintf(
                    stderr,
                    "[blast-gpu-skip] nodes %u changed %u | islands %u clean %u converged %u "
                    "skipped %u | bonds %u changed %zu | baseline %d\n",
                    m_nodeCount,
                    static_cast<std::uint32_t>(m_changedNodes.size()),
                    m_islandCount,
                    clean,
                    converged,
                    skipped,
                    m_bondCount,
                    m_changedBonds.size(),
                    haveBaseline ? 1 : 0);
            }
        }
        if (!haveBaseline)
        {
            // Nothing was skipped, and bonds in no island have never been
            // written -- but the caller's mirror has never been written
            // either, so hand it the whole array once.
            m_changedBonds.resize(m_bondCount);
            for (std::uint32_t i = 0; i < m_bondCount; ++i)
            {
                m_changedBonds[i] = i;
            }
        }
    }

    /**
     * Bit-exact velocity comparison, matching stress.cpp's angLin6Equal.
     *
     * Float `==` rather than std::memcmp, because it is the CPU path's own
     * test and both of its disagreements with a byte compare fall the safe
     * way. -0.0f == +0.0f declares a node unchanged, and it is: the right-hand
     * side differs only in the sign of a zero, which no later operation can
     * turn into a different magnitude. NaN != NaN declares it changed, so a
     * poisoned input can never be frozen in place by the skip.
     */
    static bool velocityBitsEqual(
        const ExtStressGpuImpulse& a,
        const ExtStressGpuImpulse& b)
    {
        return a.angular.x == b.angular.x && a.angular.y == b.angular.y
            && a.angular.z == b.angular.z && a.linear.x == b.linear.x
            && a.linear.y == b.linear.y && a.linear.z == b.linear.z;
    }

    /// Push only the node velocities that moved. Falls back to the straight
    /// copy of the whole array once enough of them have: the scatter costs an
    /// index and a kernel launch per node, so below about half it is cheaper
    /// and above it is not. Both write exactly the same device state.
    void uploadChangedVelocities()
    {
        const std::uint32_t count = static_cast<std::uint32_t>(m_changedNodes.size());
        if (count == 0)
        {
            return;     // the device already holds every value this solve needs
        }
        if (static_cast<std::uint64_t>(count) * 2u >= m_nodeCount)
        {
            checkCuda(
                cudaMemcpyAsync(
                    m_input,
                    m_hostInput,
                    sizeof(ExtStressGpuImpulse) * m_nodeCount,
                    cudaMemcpyHostToDevice,
                    m_stream),
                "upload stress inputs");
            m_telemetry.hostToDeviceBytes +=
                sizeof(ExtStressGpuImpulse) * static_cast<std::uint64_t>(m_nodeCount);
            return;
        }
        for (std::uint32_t j = 0; j < count; ++j)
        {
            const std::uint32_t node = m_changedNodes[j];
            m_hostScatterIndices[j] = node;
            m_hostScatterValues[j] = m_hostInput[node];
        }
        checkCuda(
            cudaMemcpyAsync(
                m_scatterIndices,
                m_hostScatterIndices,
                sizeof(std::uint32_t) * count,
                cudaMemcpyHostToDevice,
                m_stream),
            "upload changed node indices");
        checkCuda(
            cudaMemcpyAsync(
                m_scatterValues,
                m_hostScatterValues,
                sizeof(ExtStressGpuImpulse) * count,
                cudaMemcpyHostToDevice,
                m_stream),
            "upload changed node velocities");
        scatterVelocities<<<
            (count + kBlockSize - 1) / kBlockSize,
            kBlockSize,
            0,
            m_stream>>>(m_input, m_scatterIndices, m_scatterValues, count);
        m_telemetry.hostToDeviceBytes +=
            (sizeof(std::uint32_t) + sizeof(ExtStressGpuImpulse))
            * static_cast<std::uint64_t>(count);
    }

    void finishSolve()
    {
        if (m_kernelProfile.active)
        {
            // Elapsed time is only readable once the stream has caught up,
            // and finishSolve is where the caller has already synchronized.
            m_kernelProfile.harvest();
        }
        checkCuda(cudaGetLastError(), "execute stress kernels");
        checkCuda(
            cudaEventElapsedTime(
                &m_telemetry.uploadMilliseconds,
                m_uploadStart,
                m_uploadStop),
            "measure input upload");
        checkCuda(
            cudaEventElapsedTime(
                &m_telemetry.solveMilliseconds,
                m_solveStart,
                m_solveStop),
            "measure stress solve");
        m_telemetry.iterations = m_hostStatus->iterations;
        m_telemetry.converged = m_hostStatus->converged != 0;
        if (islandTraceEnabled())
        {
            const double after = debugImpulseMagnitude();
            m_dbgActive.resize(m_islandCount);
            m_dbgConverged.resize(m_islandCount);
            cudaMemcpy(m_dbgActive.data(), m_islandActive,
                       sizeof(std::uint32_t) * m_islandCount, cudaMemcpyDeviceToHost);
            cudaMemcpy(m_dbgConverged.data(), m_islandConverged,
                       sizeof(std::uint32_t) * m_islandCount, cudaMemcpyDeviceToHost);
            cudaGetLastError();
            std::uint32_t active = 0, conv = 0;
            for (std::uint32_t i = 0; i < m_islandCount; ++i)
            {
                active += (m_dbgActive[i] != 0u) ? 1u : 0u;
                conv += (m_dbgConverged[i] != 0u) ? 1u : 0u;
            }
            static std::uint32_t dbgTick = 0;
            if (dbgTick < 60)
            {
                std::fprintf(stderr,
                             "[island] tick=%-3u warm=%d iters=%-3u conv=%d "
                             "|x|before=%.6f |x|after=%.6f delta=%.6f "
                             "islands=%u active_end=%u converged_end=%u\n",
                             dbgTick, int(m_dbgWarm), unsigned(m_hostStatus->iterations),
                             int(m_hostStatus->converged != 0),
                             m_dbgSumBefore, after, after - m_dbgSumBefore,
                             unsigned(m_islandCount), unsigned(active), unsigned(conv));
            }
            ++dbgTick;
        }
        m_hasWarmStart = true;
        // Carry each solved island's convergence forward as next frame's
        // permission to skip. A skipped island reports nothing, and must not:
        // the flag it still holds is the one that certified the impulses it
        // still holds.
        for (std::uint32_t k = 0; k < m_islandCount; ++k)
        {
            if (m_hostIslandSkip[k] == 0u)
            {
                m_hostIslandConverged[k] = m_hostIslandConvergedPinned[k];
            }
        }
        m_settledBaselineValid = true;
        if (*m_hostBrokenCount != 0u && !wholeResetOnTopology())
        {
            // Per-island invalidation: only the islands whose own bonds broke
            // lose their baseline. The removal path force-dirties the same
            // nodes; this covers damage-driven breaks the adapter has not yet
            // converted to removeBond calls, closing the window the
            // equivalence harness caught (a settled island taking damage from
            // frozen stress and never re-solving after its own bond failed --
            // 322 broken against 287).
            const std::uint32_t count =
                std::min(*m_hostBrokenCount, m_bondCount);
            std::vector<std::uint32_t> broken(count);
            if (count > 0)
            {
                checkCuda(
                    cudaMemcpy(
                        broken.data(),
                        m_brokenBonds,
                        sizeof(std::uint32_t) * count,
                        cudaMemcpyDeviceToHost),
                    "read broken bonds for invalidation");
            }
            for (const std::uint32_t bond : broken)
            {
                if (bond < m_bondCount)
                {
                    m_forceDirtyNodes.push_back(m_hostNode0[bond]);
                    m_forceDirtyNodes.push_back(m_hostNode1[bond]);
                }
            }
        }
        else if (*m_hostBrokenCount != 0u)
        {
            // A bond crossed zero health somewhere, so at least one island's
            // effective topology changed and its frozen impulses no longer
            // describe it. Drop the whole baseline rather than work out which:
            // it is the CPU solver's own rule (stress.cpp removeBond clears
            // m_skipValid), and in a settled scene -- the only place skipping
            // pays -- nothing breaks, so it costs nothing there.
            //
            // Found by the equivalence test, not by inspection: with
            // applyDamage on, skipping produced 322 broken bonds against 287.
            // A settled island keeps taking damage from its frozen stress, and
            // without this it was never re-solved after one of its own bonds
            // failed.
            invalidateSettledBaseline();
        }
    }

    // Allocator-generic: the topology arrays are PinnedVector, not
    // std::vector, so a signature naming the default allocator no longer
    // matches them.
    template <typename T, typename Alloc>
    static void swapWithLast(std::vector<T, Alloc>& values, std::uint32_t index, std::uint32_t last)
    {
        values[index] = values[last];
        values.resize(last);
    }

    /**
     * Fold the removals since the last solve into device state.
     *
     * Deliberately the same observable state a freshly constructed solver
     * would have: re-uploaded topology, a repartition from the surviving
     * bonds, and a cold warm start. The old code got there by destroying the
     * solver; this gets there without releasing and re-cudaMalloc-ing twenty
     * buffers, and -- the reason it matters -- a tick with NO removals now
     * changes nothing at all, so the warm-start impulses and the settled
     * baseline survive into it.
     */
    void applyTopologyChange()
    {
        m_topologyDirty = false;
        m_topoStagingUsed = 0;
        // The host topology arrays are pinned and DMA'd from directly, and the
        // rebuilds below RESIZE them -- which frees that pinned memory. If a
        // copy enqueued last tick were still in flight, that is a use-after-
        // free the driver would read straight through.
        //
        // In practice every solve waits on m_statusReady first, so the copies
        // are long done. "In practice" is not good enough for a dangling DMA:
        // the no-op solve path returns early without waiting, so the guarantee
        // has a hole in it. Waiting on the upload event closes it, and costs
        // nothing when the work has already completed.
        if (m_topoUploadsPending)
        {
            checkCuda(cudaEventSynchronize(m_topoUploadDone), "wait topology uploads");
            m_topoUploadsPending = false;
        }
        // The island partition is about to be remapped; the compacted lists
        // index into the OLD partition and must be rebuilt before next solve.
        m_activeListsDirty = true;
        m_jacobiBuilt = false;   // topology moved: the diagonal blocks are stale
        auto tstep = StatClock::now();
        // Repartitioning is O(nodes + bonds) of pointer-chasing union-find and
        // measured 2.2 ms per fracture tick at 298k bonds -- the single largest
        // cost in the whole tick, device work included. It is also usually
        // unnecessary, because REMOVING A BOND CAN ONLY SPLIT AN ISLAND, NEVER
        // MERGE ONE, and solving two disconnected components as one island is
        // exact: the operator is block-diagonal across them, so the CG iterates
        // are identical. Only the convergence test and the skip granularity are
        // shared, which costs at most a few extra iterations for whichever
        // component converges first.
        //
        // So carry the stale, coarser partition and rebuild on a budget. The
        // labels stay self-consistent because removeBond moves a bond's island
        // label with it.
        // CSR first: the split test walks it, and it has to describe the graph
        // AFTER this tick's removals. Usually it already does, because
        // removeBond patched it in place -- rebuild only once the tombstones
        // have accumulated enough to be worth compacting away.
        const bool csrPatched = m_csrValid && csrPatchAcceptable();
        if (!csrPatched)
        {
            buildNodeBondCsr();
        }
        m_statTopoCsrMs += statMs(tstep); tstep = StatClock::now();
        const bool repartition = shouldRepartition();
        if (repartition)
        {
            computeIslands();
            m_islandCountAtRebuild = m_islandCount;
            m_removalsSinceRepartition = 0;
            // computeIslands rewrote every label, so any deltas queued by a
            // local relabel are stale -- the full upload below carries them.
            m_changedNodeIslandSlots.clear();
            m_changedBondSlots.clear();
        }
        m_splitChecks.clear();
        m_statTopoIslandsMs += statMs(tstep); tstep = StatClock::now();
        if (repartition)
        {
            groupBondsByIsland();
            m_bondsByIslandValid = true;
        }
        m_statTopoGroupMs += statMs(tstep); tstep = StatClock::now();
        // The bond arrays change in a handful of slots per tick; the island
        // arrays only change at all when the partition was rebuilt. Fall back
        // to the full upload whenever the sparse path declines.
        const bool sparse =
            !repartition && uploadNodeIslandDelta() && uploadTopologyDelta();
        if (!sparse)
        {
            uploadTopology();
            uploadIslands();
        }
        else if (!m_inertiaUploaded)
        {
            // Per-node inertia is fixed by prepare(); it was being re-sent on
            // every fracture tick for nothing.
            stageUpload(m_inertia, m_hostInertia.data(),
                        sizeof(Inertia) * m_nodeCount, "upload inertia");
            m_inertiaUploaded = true;
        }
        m_changedBondSlots.clear();
        m_changedNodeIslandSlots.clear();
        if (csrPatched && uploadCsrDelta())
        {
            // nodeBondBegin is untouched by a patch: runs keep their length.
        }
        else
        {
            uploadNodeBondCsr();
        }
        m_changedRefSlots.clear();
        // Includes swap-with-last and local relabel changes, even when the
        // solver deliberately carries a coarser partition between rebuilds.
        uploadReductionOrders();
        checkCuda(cudaEventRecord(m_topoUploadDone, m_stream), "record topology uploads");
        m_topoUploadsPending = true;
        if (topoUploadMode() == TopoUploadMode::Sync)
        {
            // Drain the transfers here, ONCE, so they finish before the solve
            // is enqueued. Letting them ride alongside the CG kernels cost
            // 8.25% of device solve time (p=0.021, 16 pairs) -- the host time
            // it saved merely became host waiting, because this phase is
            // device-bound.
            checkCuda(cudaStreamSynchronize(m_stream), "drain topology uploads");
            m_topoUploadsPending = false;
        }
        m_statTopoUploadMs += statMs(tstep);
        // Grid sizes and the per-island memset lengths are baked into the
        // captured graph, and both just changed -- but they are node
        // PARAMETERS, not structure, so the exec can be patched rather than
        // rebuilt. Destroying it here is what made every fracture tick pay a
        // full re-instantiation. executeSolve now decides, and still falls back
        // to destroy + instantiate if the patch will not take.
        m_graphParamsDirty = true;
        if (!graphUpdateEnabled())
        {
            if (m_graphExec)
            {
                checkCuda(cudaGraphExecDestroy(m_graphExec), "destroy solver graph exec");
                m_graphExec = nullptr;
            }
            if (m_graph)
            {
                checkCuda(cudaGraphDestroy(m_graph), "destroy solver graph");
                m_graph = nullptr;
            }
        }
        if (wholeResetOnTopology())
        {
            const auto memsetStart = StatClock::now();
            // Async, on the solver stream, NOT the synchronous form. Plain
            // cudaMemset runs on the legacy default stream, which implicitly
            // synchronises with every other stream on the device -- so it
            // would have blocked on the topology uploads enqueued just above
            // and handed back exactly the stall they were made async to avoid.
            checkCuda(
                cudaMemsetAsync(
                    m_impulses, 0, sizeof(AngLin) * m_bondCount, m_stream),
                "reset warm start after topology change");
            m_statTopoMemsetMs += statMs(memsetStart);
            m_hasWarmStart = false;
            m_settledBaselineValid = false;
            m_pendingImpulseSwaps.clear();
        }
        else
        {
            // Incremental: a removal only permutes the bond arrays. Every
            // OTHER island is a disconnected component whose inputs and
            // topology are untouched -- its warm-start impulses and settled
            // baseline stay exactly valid, so a fracture tick no longer
            // cold-starts the whole city (the memset above did, every time a
            // bond broke anywhere). The device impulse array replays the same
            // swap-with-last permutation the host arrays already applied; the
            // affected islands re-solve via the force-dirty nodes recorded in
            // removeBond.
            for (const auto& swap : m_pendingImpulseSwaps)
            {
                if (swap.first != swap.second)
                {
                    checkCuda(
                        cudaMemcpyAsync(
                            m_impulses + swap.first,
                            m_impulses + swap.second,
                            sizeof(AngLin),
                            cudaMemcpyDeviceToDevice,
                            m_stream),
                        "replay impulse swap");
                }
            }
            m_pendingImpulseSwaps.clear();
        }
        // Converged flags are keyed by island id, so they cannot survive a
        // renumbering -- but they CAN survive a tick that did not renumber.
        // That distinction matters a lot: wiping unconditionally meant one bond
        // breaking anywhere disabled the settled skip for the entire scene on
        // the next tick, so a long demolition never got to skip anything.
        // The islands actually touched by this tick's removals are dirtied
        // separately, through m_forceDirtyNodes.
        if (repartition)
        {
            m_hostIslandConverged.assign(m_islandCapacity, 0u);
            std::fill(m_hostIslandSkip, m_hostIslandSkip + m_islandCapacity, 0u);
            // Async on the solver stream: the plain form runs on the legacy
            // default stream and implicitly synchronises every stream on the
            // device, including the topology uploads enqueued just above.
            checkCuda(
                cudaMemsetAsync(
                    m_islandConverged, 0,
                    sizeof(std::uint32_t) * m_islandCapacity, m_stream),
                "clear island converged flags");
        }
    }

    /// Is the patched CSR still worth using, or have the tombstones piled up?
    ///
    /// Dead entries cost the matvec a load and a compare each; compacting them
    /// away costs a full rebuild. 12.5% is where the rebuild starts paying.
    bool csrPatchAcceptable() const
    {
        const std::size_t total = m_hostNodeBondRef.size();
        return total != 0 && m_deadRefCount * 8u < total;
    }

    /// Upload just the CSR slots a patch touched.
    bool uploadCsrDelta()
    {
        const std::uint32_t count =
            static_cast<std::uint32_t>(m_changedRefSlots.size());
        if (count == 0)
        {
            return true;
        }
        if (count * 8u >= m_hostNodeBondRef.size() || !deltaUploadEnabled())
        {
            return false;
        }
        if (count > m_refDeltaCapacity)
        {
            const std::uint32_t want =
                std::max(count, m_refDeltaCapacity ? m_refDeltaCapacity * 2u : 2048u);
            cudaFree(m_devRefSlots);
            cudaFree(m_devRefValues);
            if (cudaMalloc(&m_devRefSlots, sizeof(std::uint32_t) * want) != cudaSuccess
                || cudaMalloc(&m_devRefValues, sizeof(std::uint32_t) * want) != cudaSuccess)
            {
                cudaGetLastError();
                m_refDeltaCapacity = 0;
                return false;
            }
            m_refDeltaCapacity = want;
        }
        m_refSlots.resize(count);
        m_refValues.resize(count);
        for (std::uint32_t i = 0; i < count; ++i)
        {
            const std::uint32_t pos = m_changedRefSlots[i];
            m_refSlots[i] = pos;
            m_refValues[i] = m_hostNodeBondRef[pos];
        }
        stageUpload(m_devRefSlots, m_refSlots.data(),
                    sizeof(std::uint32_t) * count, "upload csr delta slots");
        stageUpload(m_devRefValues, m_refValues.data(),
                    sizeof(std::uint32_t) * count, "upload csr delta values");
        scatterNodeBondRefs<<<(count + kBlockSize - 1) / kBlockSize, kBlockSize, 0, m_stream>>>(
            m_devRefSlots, m_devRefValues, count, m_nodeBondRef);
        return true;
    }

    /// Upload only the node island labels a local split rewrote.
    bool uploadNodeIslandDelta()
    {
        const std::uint32_t count =
            static_cast<std::uint32_t>(m_changedNodeIslandSlots.size());
        if (count == 0)
        {
            return true;
        }
        if (count * 8u >= m_nodeCount || !deltaUploadEnabled())
        {
            return false;
        }
        if (count > m_nodeIslandDeltaCapacity)
        {
            const std::uint32_t want = std::max(
                count, m_nodeIslandDeltaCapacity ? m_nodeIslandDeltaCapacity * 2u : 2048u);
            cudaFree(m_devNodeIslandSlots);
            cudaFree(m_devNodeIslandValues);
            if (cudaMalloc(&m_devNodeIslandSlots, sizeof(std::uint32_t) * want) != cudaSuccess
                || cudaMalloc(&m_devNodeIslandValues, sizeof(std::uint32_t) * want) != cudaSuccess)
            {
                cudaGetLastError();
                m_nodeIslandDeltaCapacity = 0;
                return false;
            }
            m_nodeIslandDeltaCapacity = want;
        }
        m_nodeIslandSlots.resize(count);
        m_nodeIslandValues.resize(count);
        for (std::uint32_t i = 0; i < count; ++i)
        {
            const std::uint32_t node = m_changedNodeIslandSlots[i];
            m_nodeIslandSlots[i] = node;
            m_nodeIslandValues[i] = m_hostNodeIsland[node];
        }
        stageUpload(m_devNodeIslandSlots, m_nodeIslandSlots.data(),
                    sizeof(std::uint32_t) * count, "upload node island delta slots");
        stageUpload(m_devNodeIslandValues, m_nodeIslandValues.data(),
                    sizeof(std::uint32_t) * count, "upload node island delta values");
        scatterNodeBondRefs<<<(count + kBlockSize - 1) / kBlockSize, kBlockSize, 0, m_stream>>>(
            m_devNodeIslandSlots, m_devNodeIslandValues, count, m_nodeIsland);
        return true;
    }

    /// Rebuild the island partition, or carry the stale one another tick?
    ///
    /// Carrying it is always CORRECT (see applyTopologyChange); it only costs
    /// skip granularity, because two components that have actually separated
    /// keep sharing one convergence flag and one skip decision. Rebuild once
    /// that has had a chance to matter -- measured against the alternative of
    /// rebuilding every tick, which spends 2.2 ms to sharpen a partition that
    /// is usually unchanged.
    bool shouldRepartition()
    {
        // `<`, not `!=`: removeBond shrinks m_bondCount without shrinking the
        // label array, so a stale array is legitimately LONGER than the graph.
        if (m_islandCount == 0 || m_hostBondIsland.size() < m_bondCount)
        {
            return true;   // never partitioned, or the labels do not cover the graph
        }
        // Local relabelling never reuses an id, so the count drifts above the
        // true island number and every per-island array, memset and serial tail
        // scales with the drift. Compact it once it has grown materially.
        if (m_islandCount > m_islandCountAtRebuild + m_islandCountAtRebuild / 4u + 64u)
        {
            return true;
        }
        if (!deferRepartitionEnabled())
        {
            return true;   // A/B control: rebuild every fracture tick, as before
        }
        return applyRemovalSplits();
    }

    /// Did any of this tick's removals actually disconnect something?
    ///
    /// Removing one edge can only ever separate the two sides of THAT edge, so
    /// "did the partition change" is exactly "are these two endpoints still
    /// connected to each other". If they are, the component is unchanged and
    /// the existing labels remain the true partition -- not an approximation of
    /// it. That is what makes deferring the rebuild free of quality cost.
    ///
    /// Deferring on a fixed budget instead was measurably wrong: it let two
    /// components that HAD separated keep sharing one convergence test, so a
    /// large component's tolerance hid a small under-solved one and the
    /// residual went from 0.63x tolerance to 22x, with 42% of islands over.
    ///
    /// The walk is bounded; exhausting the budget reports "split" and forces a
    /// rebuild, which is the conservative direction.
    /// Handle this tick's removals: detect splits, and relabel them LOCALLY
    /// when the separated piece is small. Returns true if a full repartition is
    /// still required.
    ///
    /// Removing one edge can only separate the two sides of THAT edge, so a
    /// bounded walk from one endpoint answers both questions at once: if it
    /// reaches the other endpoint the component is unchanged; if it exhausts
    /// naturally the visited set IS the separated piece, and giving that piece a
    /// fresh island id is the entire partition update. A chunk falling off a
    /// building costs work proportional to the chunk, not to the city.
    ///
    /// Falling back to a full rebuild is always safe -- it is what this
    /// replaces -- so every uncertain case returns true.
    bool applyRemovalSplits()
    {
        constexpr std::uint32_t kVisitBudget = 512u;
        const auto isStatic = [&](std::uint32_t node) {
            return !(m_hostInertia[node].linear > 0.0f);
        };
        m_splitVisited.resize(m_nodeCount, 0u);
        m_affectedIslands.clear();
        for (const auto& pair : m_splitChecks)
        {
            const std::uint32_t from = pair.first;
            const std::uint32_t to = pair.second;
            if (from >= m_nodeCount || to >= m_nodeCount)
            {
                return true;
            }
            // A bond with a static endpoint was already a cut in the partition.
            if (isStatic(from) || isStatic(to))
            {
                continue;
            }
            if (++m_splitStamp == 0u)
            {
                std::fill(m_splitVisited.begin(), m_splitVisited.end(), 0u);
                m_splitStamp = 1u;
            }
            m_splitQueue.clear();
            m_splitQueue.push_back(from);
            m_splitVisited[from] = m_splitStamp;
            bool reconnected = false;
            for (std::size_t qi = 0; qi < m_splitQueue.size() && !reconnected; ++qi)
            {
                if (m_splitQueue.size() > kVisitBudget)
                {
                    return true;   // piece too big to relabel cheaply
                }
                const std::uint32_t node = m_splitQueue[qi];
                for (std::uint32_t i = m_hostNodeBondBegin[node];
                     i < m_hostNodeBondBegin[node + 1]; ++i)
                {
                    const std::uint32_t ref = m_hostNodeBondRef[i];
                    if (ref == kDeadBondRef)
                    {
                        continue;
                    }
                    const std::uint32_t bond = ref & 0x7FFFFFFFu;
                    if (bond >= m_bondCount)
                    {
                        continue;
                    }
                    const std::uint32_t other =
                        (ref & 0x80000000u) ? m_hostNode0[bond] : m_hostNode1[bond];
                    if (other >= m_nodeCount || isStatic(other))
                    {
                        continue;   // static nodes cut the graph, as in the union rule
                    }
                    if (other == to)
                    {
                        reconnected = true;
                        break;
                    }
                    if (m_splitVisited[other] != m_splitStamp)
                    {
                        m_splitVisited[other] = m_splitStamp;
                        m_splitQueue.push_back(other);
                    }
                }
            }
            if (reconnected)
            {
                continue;   // no split: the labels are still the true partition
            }
            if (!localSplitRelabelEnabled() || m_islandCount >= m_islandCapacity)
            {
                return true;   // fall back to a full repartition
            }

            // A split. Do NOT relabel just this side.
            //
            // Relabelling only the BFS-source component is wrong when an island
            // splits three or more ways: the source side gets a fresh id, but
            // the REMAINDER can be two disjoint pieces still sharing the old
            // id. They then share one convergence test, and a large piece's
            // tolerance hides a small under-solved one -- measured as
            // residual/tolerance 1.05x -> 5.06x and 12% more bonds broken.
            //
            // Instead, recompute the partition for the affected island only.
            // That is O(that island), not O(the city).
            m_affectedIslands.push_back(m_hostNodeIsland[from]);
            ++m_statLocalSplits;
        }
        return m_affectedIslands.empty() ? false : !rebuildAffectedIslands();
    }

    /// Diagnostic: is the incrementally-maintained partition IDENTICAL, as a
    /// partition, to what a full computeIslands would produce right now?
    ///
    /// This is the probe that settles whether an observed behaviour difference
    /// is a real partition error or just chaotic amplification of a changed
    /// reduction order. Ids are allowed to differ; only the equivalence classes
    /// must match, so it checks for a bijection both ways.
    ///
    /// Destroys and restores the partition around a full rebuild, so it is
    /// strictly a debug path (BLAST_GPU_VERIFY_PARTITION=1).
    void verifyPartitionAgainstRebuild()
    {
        m_verifyNodeIsland.assign(m_hostNodeIsland.begin(), m_hostNodeIsland.end());
        m_verifyBondIsland.assign(m_hostBondIsland.begin(), m_hostBondIsland.end());
        const std::uint32_t incrementalCount = m_islandCount;

        computeIslands();   // overwrites the labels with the reference partition

        std::map<std::uint32_t, std::uint32_t> incToRef, refToInc;
        std::uint64_t mismatches = 0;
        for (std::uint32_t n = 0; n < m_nodeCount; ++n)
        {
            const std::uint32_t inc = m_verifyNodeIsland[n];
            const std::uint32_t ref = m_hostNodeIsland[n];
            if ((inc == kNoIsland) != (ref == kNoIsland)) { ++mismatches; continue; }
            if (inc == kNoIsland) { continue; }
            auto a = incToRef.emplace(inc, ref);
            if (!a.second && a.first->second != ref) { ++mismatches; }
            auto b = refToInc.emplace(ref, inc);
            if (!b.second && b.first->second != inc) { ++mismatches; }
        }
        std::uint64_t bondMismatches = 0;
        for (std::uint32_t b = 0; b < m_bondCount; ++b)
        {
            const std::uint32_t inc = m_verifyBondIsland[b];
            const std::uint32_t ref = m_hostBondIsland[b];
            if ((inc == kNoIsland) != (ref == kNoIsland)) { ++bondMismatches; continue; }
            if (inc == kNoIsland) { continue; }
            auto it = incToRef.find(inc);
            if (it == incToRef.end() || it->second != ref) { ++bondMismatches; }
        }
        if (mismatches || bondMismatches || ++m_verifyCalls % 200u == 0u)
        {
            std::fprintf(stderr,
                "[partition-verify] call=%llu incrementalIslands=%u referenceIslands=%u "
                "nodeMismatches=%llu bondMismatches=%llu\n",
                static_cast<unsigned long long>(m_verifyCalls),
                incrementalCount, m_islandCount,
                static_cast<unsigned long long>(mismatches),
                static_cast<unsigned long long>(bondMismatches));
        }

        // Put the incremental partition back so the run continues to measure it.
        m_hostNodeIsland.assign(m_verifyNodeIsland.begin(), m_verifyNodeIsland.end());
        m_hostBondIsland.assign(m_verifyBondIsland.begin(), m_verifyBondIsland.end());
        m_islandCount = incrementalCount;
    }

    /// Recompute connected components for just the islands a removal split.
    ///
    /// Correct by construction: every node of an affected island is re-derived
    /// from scratch, so no two disconnected pieces can be left sharing an id.
    /// Returns false if it declines (too much of the graph affected), leaving
    /// the caller to do a full repartition.
    bool rebuildAffectedIslands()
    {
        const auto isStatic = [&](std::uint32_t node) {
            return !(m_hostInertia[node].linear > 0.0f);
        };
        std::sort(m_affectedIslands.begin(), m_affectedIslands.end());
        m_affectedIslands.erase(
            std::unique(m_affectedIslands.begin(), m_affectedIslands.end()),
            m_affectedIslands.end());

        // Gather the affected islands' nodes. One pass over nodes; the union
        // work below is proportional to those islands, not to the graph.
        m_affectedNodes.clear();
        for (std::uint32_t n = 0; n < m_nodeCount; ++n)
        {
            if (isStatic(n))
            {
                continue;
            }
            const std::uint32_t island = m_hostNodeIsland[n];
            if (island != kNoIsland
                && std::binary_search(m_affectedIslands.begin(), m_affectedIslands.end(), island))
            {
                m_affectedNodes.push_back(n);
            }
        }
        // If the affected islands are most of the graph, a full rebuild is both
        // simpler and no more expensive.
        if (m_affectedNodes.size() * 2u >= m_nodeCount)
        {
            return false;
        }

        for (std::uint32_t n : m_affectedNodes)
        {
            m_hostParent[n] = n;
        }
        for (std::uint32_t n : m_affectedNodes)
        {
            for (std::uint32_t i = m_hostNodeBondBegin[n]; i < m_hostNodeBondBegin[n + 1]; ++i)
            {
                const std::uint32_t ref = m_hostNodeBondRef[i];
                if (ref == kDeadBondRef)
                {
                    continue;
                }
                const std::uint32_t bond = ref & 0x7FFFFFFFu;
                if (bond >= m_bondCount)
                {
                    continue;
                }
                const std::uint32_t other =
                    (ref & 0x80000000u) ? m_hostNode0[bond] : m_hostNode1[bond];
                if (other >= m_nodeCount || isStatic(other))
                {
                    continue;   // static nodes cut, exactly as computeIslands does
                }
                unite(n, other);
            }
        }

        // Reuse the affected ids first so the island count does not drift.
        std::size_t nextReuse = 0;
        m_rootRemap.clear();
        for (std::uint32_t n : m_affectedNodes)
        {
            const std::uint32_t root = findRoot(n);
            auto it = m_rootRemap.find(root);
            std::uint32_t id;
            if (it == m_rootRemap.end())
            {
                if (nextReuse < m_affectedIslands.size())
                {
                    id = m_affectedIslands[nextReuse++];
                }
                else if (m_islandCount < m_islandCapacity)
                {
                    id = m_islandCount++;
                }
                else
                {
                    return false;   // out of id space; a full rebuild compacts it
                }
                m_rootRemap.emplace(root, id);
                if (id < m_islandCapacity)
                {
                    // Every piece here changed shape; none may be skipped on trust.
                    m_hostIslandConverged[id] = 0u;
                    m_hostIslandSkip[id] = 0u;
                }
            }
            else
            {
                id = it->second;
            }
            m_hostNodeIsland[n] = id;
            m_changedNodeIslandSlots.push_back(n);
            for (std::uint32_t i = m_hostNodeBondBegin[n]; i < m_hostNodeBondBegin[n + 1]; ++i)
            {
                const std::uint32_t ref = m_hostNodeBondRef[i];
                if (ref == kDeadBondRef)
                {
                    continue;
                }
                const std::uint32_t bond = ref & 0x7FFFFFFFu;
                if (bond >= m_bondCount)
                {
                    continue;
                }
                m_hostBondIsland[bond] = id;
                m_changedBondSlots.push_back(bond);
            }
        }
        m_bondsByIslandValid = false;
        return true;
    }

    /// Forget that anything is settled. Used whenever the impulses the
    /// convergence flags refer to are no longer the ones on the device.
    void invalidateSettledBaseline()
    {
        m_settledBaselineValid = false;
        std::fill(m_hostIslandConverged.begin(), m_hostIslandConverged.end(), 0u);
        if (m_hostIslandSkip)
        {
            std::fill(m_hostIslandSkip, m_hostIslandSkip + m_islandCapacity, 0u);
        }
    }

    void enqueueImpulseReadback(bool compacted)
    {
        const std::uint32_t count = static_cast<std::uint32_t>(m_changedBonds.size());
        checkCuda(cudaEventRecord(m_downloadStart, m_stream), "record readback start");
        if (!compacted)
        {
            checkCuda(
                cudaMemcpyAsync(
                    m_hostImpulses,
                    m_impulses,
                    sizeof(AngLin) * m_bondCount,
                    cudaMemcpyDeviceToHost,
                    m_stream),
                "read stress impulses");
        }
        else if (count > 0)
        {
            // Gather on the device, copy dense. Reading the whole array and
            // discarding most of it would hand back on the PCIe bus and in the
            // host conversion loop exactly what the skip just saved.
            std::memcpy(
                m_hostGatherIndices,
                m_changedBonds.data(),
                sizeof(std::uint32_t) * count);
            checkCuda(
                cudaMemcpyAsync(
                    m_gatherIndices,
                    m_hostGatherIndices,
                    sizeof(std::uint32_t) * count,
                    cudaMemcpyHostToDevice,
                    m_stream),
                "upload changed bond indices");
            gatherImpulses<<<
                (count + kBlockSize - 1) / kBlockSize,
                kBlockSize,
                0,
                m_stream>>>(m_impulses, m_gatherIndices, m_gatherOutput, count);
            checkCuda(
                cudaMemcpyAsync(
                    m_hostImpulses,
                    m_gatherOutput,
                    sizeof(AngLin) * count,
                    cudaMemcpyDeviceToHost,
                    m_stream),
                "read changed stress impulses");
            m_telemetry.hostToDeviceBytes +=
                sizeof(std::uint32_t) * static_cast<std::uint64_t>(count);
        }
        checkCuda(cudaEventRecord(m_downloadStop, m_stream), "record readback stop");
    }

    void finishImpulseReadback(ExtStressGpuImpulse* bondImpulses, bool compacted)
    {
        checkCuda(
            cudaEventElapsedTime(
                &m_telemetry.downloadMilliseconds,
                m_downloadStart,
                m_downloadStop),
            "measure impulse readback");
        const std::uint32_t count = static_cast<std::uint32_t>(m_changedBonds.size());
        const float linearScale = m_lengthScale * m_massScale;
        // Same parenthesization as the device-walk launch arguments.
        const float angularScale = m_lengthScale * m_lengthScale * m_massScale;
        for (std::uint32_t j = 0; j < count; ++j)
        {
            const std::uint32_t bond = m_changedBonds[j];
            const AngLin& value = m_hostImpulses[compacted ? j : bond];
            // Device impulses are also column-scaled (J' = J / colScale).
            const float s_j = m_hostColScale[bond];
            // Device impulses are solver-scaled; this loop already touches
            // every changed bond for the 32 B -> 24 B repack, so converting to
            // physical units here is six multiplies on data already in cache.
            // Doing it on the device instead would need a full-array pass on
            // the non-compacted path -- which is the path taken after every
            // fracture tick, where it would cost as much as it saves.
            // Match bondStressWalk/applyStressDamage: value * (scale * s).
            // (value * scale) * s rounds differently and can change the side
            // of an elastic limit despite an apparently exact host mirror.
            // Sharing each combined factor also saves four multiplies/bond.
            const float physicalAngularScale = angularScale * s_j;
            const float physicalLinearScale = linearScale * s_j;
            bondImpulses[bond].angular =
                {value.angular.x * physicalAngularScale,
                 value.angular.y * physicalAngularScale,
                 value.angular.z * physicalAngularScale};
            bondImpulses[bond].linear =
                {value.linear.x * physicalLinearScale,
                 value.linear.y * physicalLinearScale,
                 value.linear.z * physicalLinearScale};
        }
        m_telemetry.deviceToHostBytes +=
            sizeof(AngLin) * static_cast<std::uint64_t>(count);
    }

    void prepare(const ExtStressGpuNode* nodes, const ExtStressGpuBond* bonds)
    {
        m_hostNode0.resize(m_bondCount);
        m_hostNode1.resize(m_bondCount);
        m_hostOffset0.resize(m_bondCount);
        m_hostOffset1.resize(m_bondCount);
        m_hostInertia.resize(m_nodeCount);
        m_hostNormals.resize(m_bondCount);
        m_hostAreas.resize(m_bondCount);
        m_hostColScale.resize(m_bondCount);
        m_hostNodeDistances.resize(m_bondCount);
        m_hostHealth.resize(m_bondCount);
        m_hostBondMaterials.resize(m_bondCount);

        double logMass = 0.0;
        std::uint32_t massCount = 0;
        for (std::uint32_t i = 0; i < m_nodeCount; ++i)
        {
            if (nodes[i].mass > 0.0f)
            {
                logMass += std::log(nodes[i].mass);
                ++massCount;
            }
            m_hostInertia[i] = {
                nodes[i].inertia > 0.0f ? 1.0f : 0.0f,
                nodes[i].mass > 0.0f ? 1.0f : 0.0f};
        }
        m_massScale =
            massCount ? static_cast<float>(std::exp(logMass / massCount)) : 1.0f;

        double lengthSum = 0.0;
        std::uint32_t offsetCount = 0;
        for (std::uint32_t i = 0; i < m_bondCount; ++i)
        {
            if (bonds[i].node0 >= m_nodeCount || bonds[i].node1 >= m_nodeCount)
            {
                throw std::runtime_error("GPU stress bond node index is out of range");
            }
            m_hostNode0[i] = bonds[i].node0;
            m_hostNode1[i] = bonds[i].node1;
            const ExtStressGpuNode& first = nodes[bonds[i].node0];
            const ExtStressGpuNode& second = nodes[bonds[i].node1];
            const Vec4 displacement = makeVec(
                second.position[0] - first.position[0],
                second.position[1] - first.position[1],
                second.position[2] - first.position[2]);
            const float distance = std::sqrt(
                displacement.x * displacement.x
                + displacement.y * displacement.y
                + displacement.z * displacement.z);
            Vec4 normal = makeVec(
                bonds[i].normal[0],
                bonds[i].normal[1],
                bonds[i].normal[2]);
            float normalLength = std::sqrt(
                normal.x * normal.x + normal.y * normal.y + normal.z * normal.z);
            if (!(normalLength > 0.0f))
            {
                normal = distance > 0.0f
                    ? mul(displacement, 1.0f / distance)
                    : makeVec(1.0f, 0.0f, 0.0f);
            }
            else
            {
                normal = mul(normal, 1.0f / normalLength);
                const float alignment =
                    normal.x * displacement.x
                    + normal.y * displacement.y
                    + normal.z * displacement.z;
                if (alignment < 0.0f)
                {
                    normal = mul(normal, -1.0f);
                }
            }
            m_hostNormals[i] = normal;
            m_hostAreas[i] = bonds[i].area > 0.0f ? bonds[i].area : 1.0f;
            m_hostColScale[i] = bonds[i].colScale > 0.0f ? bonds[i].colScale : 1.0f;
            m_hostNodeDistances[i] = distance > 1.0e-6f ? distance : 1.0f;
            m_hostHealth[i] = std::max(0.0f, bonds[i].health);
            m_hostBondMaterials[i] =
                bonds[i].material < m_materialCount ? bonds[i].material : 0;
            Vec4 offset0{};
            Vec4 offset1{};
            if (first.mass <= 0.0f)
            {
                offset1 = makeVec(
                    bonds[i].centroid[0] - second.position[0],
                    bonds[i].centroid[1] - second.position[1],
                    bonds[i].centroid[2] - second.position[2]);
                offset0 = mul(offset1, -1.0f);
            }
            else if (second.mass <= 0.0f)
            {
                offset0 = makeVec(
                    bonds[i].centroid[0] - first.position[0],
                    bonds[i].centroid[1] - first.position[1],
                    bonds[i].centroid[2] - first.position[2]);
                offset1 = mul(offset0, -1.0f);
            }
            else
            {
                offset0 = makeVec(
                    0.5f * (second.position[0] - first.position[0]),
                    0.5f * (second.position[1] - first.position[1]),
                    0.5f * (second.position[2] - first.position[2]));
                offset1 = mul(offset0, -1.0f);
            }
            if (first.mass > 0.0f)
            {
                lengthSum += std::sqrt(
                    offset0.x * offset0.x + offset0.y * offset0.y + offset0.z * offset0.z);
                ++offsetCount;
            }
            if (second.mass > 0.0f)
            {
                lengthSum += std::sqrt(
                    offset1.x * offset1.x + offset1.y * offset1.y + offset1.z * offset1.z);
                ++offsetCount;
            }
            m_hostOffset0[i] = offset0;
            m_hostOffset1[i] = offset1;
        }
        m_lengthScale =
            offsetCount ? static_cast<float>(lengthSum / offsetCount) : 1.0f;
        if (!(m_lengthScale > 0.0f))
        {
            m_lengthScale = 1.0f;
        }
        const float reciprocalLength = 1.0f / m_lengthScale;
        for (std::uint32_t i = 0; i < m_bondCount; ++i)
        {
            m_hostOffset0[i] = mul(m_hostOffset0[i], reciprocalLength);
            m_hostOffset1[i] = mul(m_hostOffset1[i], reciprocalLength);
        }
    }

#include "detail/StressBufferAllocation.inl"
    /**
     * Group bonds by island, once.
     *
     * The partition cannot change under a live solver -- a broken bond is
     * expressed as zero health, and any real topology change goes through a
     * new solver -- so this CSR is built at construction and read every frame
     * to answer "which bonds belong to the islands I am solving?" in time
     * proportional to that answer rather than to the whole graph.
     */
    void groupBondsByIsland()
    {
        m_islandBondBegin.assign(m_islandCount + 1, 0u);
        for (std::uint32_t b = 0; b < m_bondCount; ++b)
        {
            if (m_hostBondIsland[b] != kNoIsland)
            {
                ++m_islandBondBegin[m_hostBondIsland[b] + 1];
            }
        }
        for (std::uint32_t k = 0; k < m_islandCount; ++k)
        {
            m_islandBondBegin[k + 1] += m_islandBondBegin[k];
        }
        m_bondsByIsland.resize(m_islandBondBegin[m_islandCount]);
        m_groupCursor.assign(
            m_islandBondBegin.begin(), m_islandBondBegin.end());
        std::vector<std::uint32_t>& cursor = m_groupCursor;
        for (std::uint32_t b = 0; b < m_bondCount; ++b)
        {
            const std::uint32_t island = m_hostBondIsland[b];
            if (island != kNoIsland)
            {
                m_bondsByIsland[cursor[island]++] = b;
            }
        }
    }

    /// Partition the graph into islands, matching the CPU solver's rule
    /// exactly (stress.cpp solveIslandAware): union only across bonds whose
    /// endpoints are both dynamic, because a static (zero-mass) node is a fixed
    /// boundary that transmits no coupling and therefore cuts the graph. The
    /// partitions must agree for CPU and GPU results to agree.
    void computeIslands()
    {
        m_hostParent.resize(m_nodeCount);
        for (std::uint32_t i = 0; i < m_nodeCount; ++i)
        {
            m_hostParent[i] = i;
        }
        // A node is static exactly when prepare() gave it a zero inverse
        // inertia, so the partition can be rebuilt from the host mirrors alone
        // -- which is what lets a bond removal repartition in place instead of
        // going back to the caller's descriptors.
        const auto isStatic = [&](std::uint32_t node) {
            return !(m_hostInertia[node].linear > 0.0f);
        };
        for (std::uint32_t b = 0; b < m_bondCount; ++b)
        {
            const std::uint32_t n0 = m_hostNode0[b];
            const std::uint32_t n1 = m_hostNode1[b];
            if (n0 >= m_nodeCount || n1 >= m_nodeCount)
            {
                continue;
            }
            if (isStatic(n0) || isStatic(n1))
            {
                continue; // cut at static nodes
            }
            unite(n0, n1);
        }

        // Generation stamping instead of re-filling the id map: this used to
        // clear three arrays totalling ~1.6 MB on every fracture tick, all of
        // which are then overwritten by the loops below. Only m_hostRootIsland
        // is read before it is written, and a stamp answers "written this
        // rebuild?" without touching memory proportional to the graph.
        if (++m_rootIslandGeneration == 0u)
        {
            // Wrapped: the stamps would alias the new generation.
            std::fill(m_hostRootStamp.begin(), m_hostRootStamp.end(), 0u);
            m_rootIslandGeneration = 1u;
        }
        m_hostRootIsland.resize(m_nodeCount);
        m_hostRootStamp.resize(m_nodeCount, 0u);
        m_hostBondIsland.resize(m_bondCount);
        m_islandCount = 0;
        for (std::uint32_t b = 0; b < m_bondCount; ++b)
        {
            const std::uint32_t n0 = m_hostNode0[b];
            const std::uint32_t n1 = m_hostNode1[b];
            if (n0 >= m_nodeCount || n1 >= m_nodeCount)
            {
                m_hostBondIsland[b] = kNoIsland;
                continue;
            }
            const bool s0 = isStatic(n0);
            const bool s1 = isStatic(n1);
            if (s0 && s1)
            {
                m_hostBondIsland[b] = kNoIsland; // degenerate: no coupling
                continue;
            }
            const std::uint32_t rep = findRoot(s0 ? n1 : n0);
            if (m_hostRootStamp[rep] != m_rootIslandGeneration)
            {
                m_hostRootStamp[rep] = m_rootIslandGeneration;
                m_hostRootIsland[rep] = m_islandCount++;
            }
            m_hostBondIsland[b] = m_hostRootIsland[rep];
        }

        // Static nodes stay unassigned: they are boundaries, excluded from the
        // per-island residual just as they are from the CPU sub-systems.
        m_hostNodeIsland.resize(m_nodeCount);
        for (std::uint32_t i = 0; i < m_nodeCount; ++i)
        {
            if (isStatic(i))
            {
                m_hostNodeIsland[i] = kNoIsland;
                continue;
            }
            const std::uint32_t rep = findRoot(i);
            // A dynamic node with no surviving bond never had an id created
            // for it, and must stay unassigned exactly as before.
            m_hostNodeIsland[i] = m_hostRootStamp[rep] == m_rootIslandGeneration
                ? m_hostRootIsland[rep] : kNoIsland;
        }
        if (m_islandCount == 0)
        {
            m_islandCount = 1; // keep buffers valid on a graph with no coupling
        }
    }

    std::uint32_t findRoot(std::uint32_t node)
    {
        while (m_hostParent[node] != node)
        {
            m_hostParent[node] = m_hostParent[m_hostParent[node]];
            node = m_hostParent[node];
        }
        return node;
    }

    void unite(std::uint32_t a, std::uint32_t b)
    {
        const std::uint32_t ra = findRoot(a);
        const std::uint32_t rb = findRoot(b);
        if (ra != rb)
        {
            m_hostParent[rb] = ra;
        }
    }

    /// Build the node -> incident-bond CSR the gather right-multiply walks.
    ///
    /// Pure host work over mirrors that already exist, done wherever topology
    /// is (re)built, so the per-iteration kernel never has to discover which
    /// bonds touch a node. Each ref packs the bond index with the endpoint
    /// bit (bit 31) that selects the sign convention -- a bond appears in
    /// both of its nodes' lists, once per side.
    ///
    /// A kNoIsland bond (static-static) is included: the kernel skips it via
    /// bondSettled exactly as the scatter did, and excluding it here would
    /// make the CSR disagree with the scatter path under BLAST_GPU_GATHER=0.
    void buildNodeBondCsr()
    {
        m_hostNodeBondBegin.assign(m_nodeCount + 1, 0u);
        for (std::uint32_t bond = 0; bond < m_bondCount; ++bond)
        {
            ++m_hostNodeBondBegin[m_hostNode0[bond] + 1];
            ++m_hostNodeBondBegin[m_hostNode1[bond] + 1];
        }
        for (std::uint32_t node = 0; node < m_nodeCount; ++node)
        {
            m_hostNodeBondBegin[node + 1] += m_hostNodeBondBegin[node];
        }
        // resize, not assign: every slot is written by the scatter below, so
        // the value-fill was ~2.4 MB of pointless stores per fracture tick.
        m_hostNodeBondRef.resize(m_hostNodeBondBegin[m_nodeCount]);
        // Reused across ticks; this was a fresh heap allocation every rebuild.
        m_csrCursor.assign(
            m_hostNodeBondBegin.begin(), m_hostNodeBondBegin.end());
        std::vector<std::uint32_t>& cursor = m_csrCursor;
        // Ascending bond order within each node's list: the sum order is then
        // a pure function of topology, which is what makes the gather
        // reproducible run to run.
        // Remember where each bond's two refs landed, so a removal can patch
        // them in O(1) instead of rebuilding the whole CSR.
        m_hostBondRefPos.resize(2u * static_cast<std::size_t>(m_bondCount));
        for (std::uint32_t bond = 0; bond < m_bondCount; ++bond)
        {
            const std::uint32_t p0 = cursor[m_hostNode0[bond]]++;
            const std::uint32_t p1 = cursor[m_hostNode1[bond]]++;
            m_hostNodeBondRef[p0] = bond;
            m_hostNodeBondRef[p1] = bond | 0x80000000u;
            m_hostBondRefPos[2u * bond] = p0;
            m_hostBondRefPos[2u * bond + 1u] = p1;
        }
        m_deadRefCount = 0;
        m_csrValid = true;
        m_changedRefSlots.clear();
    }

    /// Patch the CSR for one swap-with-last removal, in place.
    ///
    /// Node degrees change but their CSR RUNS do not move, so tombstoning the
    /// removed bond's two entries and retargeting the moved bond's two entries
    /// is the whole update -- four slots, versus rebuilding 2*bondCount entries
    /// and re-uploading them (measured 0.82 ms per fracture tick at 298k bonds).
    void patchCsrForRemoval(std::uint32_t removed, std::uint32_t last)
    {
        if (!m_csrValid || 2u * static_cast<std::size_t>(last) + 1u >= m_hostBondRefPos.size())
        {
            m_csrValid = false;
            return;
        }
        const std::uint32_t deadA = m_hostBondRefPos[2u * removed];
        const std::uint32_t deadB = m_hostBondRefPos[2u * removed + 1u];
        m_hostNodeBondRef[deadA] = kDeadBondRef;
        m_hostNodeBondRef[deadB] = kDeadBondRef;
        m_changedRefSlots.push_back(deadA);
        m_changedRefSlots.push_back(deadB);
        m_deadRefCount += 2;

        if (last != removed)
        {
            const std::uint32_t moveA = m_hostBondRefPos[2u * last];
            const std::uint32_t moveB = m_hostBondRefPos[2u * last + 1u];
            // Keep the endpoint bit; only the bond index changes.
            m_hostNodeBondRef[moveA] = removed;
            m_hostNodeBondRef[moveB] = removed | 0x80000000u;
            m_changedRefSlots.push_back(moveA);
            m_changedRefSlots.push_back(moveB);
            m_hostBondRefPos[2u * removed] = moveA;
            m_hostBondRefPos[2u * removed + 1u] = moveB;
        }
    }

    void uploadNodeBondCsr()
    {
        if (m_hostNodeBondBegin.empty())
        {
            return;
        }
        stageUpload(m_nodeBondBegin, m_hostNodeBondBegin.data(), sizeof(std::uint32_t) * m_hostNodeBondBegin.size(), "upload node-bond csr offsets");
        if (!m_hostNodeBondRef.empty())
        {
            stageUpload(m_nodeBondRef, m_hostNodeBondRef.data(), sizeof(std::uint32_t) * m_hostNodeBondRef.size(), "upload node-bond csr refs");
        }
    }

    /// Sparse alternative to uploadTopology + uploadIslands.
    ///
    /// Returns false when the change set is too large to be worth it, or does
    /// not cover everything that moved -- the caller then does the full upload.
    /// Correctness never depends on this returning true.
    bool uploadTopologyDelta()
    {
        const std::uint32_t count =
            static_cast<std::uint32_t>(m_changedBondSlots.size());
        if (count == 0)
        {
            return true;   // nothing moved; the device already matches
        }
        // Below ~1/8 of the graph the sparse path wins; above it the gather,
        // the extra kernel and the indirection cost more than a clean stream.
        if (count * 8u >= m_bondCount || !deltaUploadEnabled())
        {
            return false;
        }
        if (count > m_deltaCapacity)
        {
            const std::uint32_t want = std::max(count, m_deltaCapacity ? m_deltaCapacity * 2u : 1024u);
            cudaFree(m_devDeltaSlots);
            cudaFree(m_devDeltaValues);
            if (cudaMalloc(&m_devDeltaSlots, sizeof(std::uint32_t) * want) != cudaSuccess
                || cudaMalloc(&m_devDeltaValues, sizeof(BondDelta) * want) != cudaSuccess)
            {
                cudaGetLastError();
                m_deltaCapacity = 0;
                return false;
            }
            m_deltaCapacity = want;
        }
        m_deltaSlots.resize(count);
        m_deltaValues.resize(count);
        for (std::uint32_t i = 0; i < count; ++i)
        {
            const std::uint32_t b = m_changedBondSlots[i];
            if (b >= m_bondCount)
            {
                // The slot was itself removed later in the same tick; it is
                // past the live range now, so nothing needs to reach the device.
                m_deltaSlots[i] = 0u;
                m_deltaValues[i] = BondDelta{};
                m_deltaValues[i].island = kNoIsland;
                m_deltaSlots[i] = m_bondCount ? m_bondCount - 1u : 0u;
                continue;
            }
            m_deltaSlots[i] = b;
            BondDelta& v = m_deltaValues[i];
            v.offset0 = m_hostOffset0[b];
            v.offset1 = m_hostOffset1[b];
            v.normal = m_hostNormals[b];
            v.node0 = m_hostNode0[b];
            v.node1 = m_hostNode1[b];
            v.material = m_hostBondMaterials[b];
            v.island = b < m_hostBondIsland.size() ? m_hostBondIsland[b] : kNoIsland;
            v.area = m_hostAreas[b];
            v.nodeDistance = m_hostNodeDistances[b];
            v.health = m_hostHealth[b];
            v.colScale = m_hostColScale[b];
        }
        stageUpload(m_devDeltaSlots, m_deltaSlots.data(),
                    sizeof(std::uint32_t) * count, "upload delta slots");
        stageUpload(m_devDeltaValues, m_deltaValues.data(),
                    sizeof(BondDelta) * count, "upload delta values");
        scatterBondTopology<<<(count + kBlockSize - 1) / kBlockSize, kBlockSize, 0, m_stream>>>(
            m_devDeltaSlots, m_devDeltaValues, count,
            m_node0, m_node1, m_offset0, m_offset1, m_normals,
            m_areas, m_nodeDistances, m_health, m_colScales, m_bondMaterials, m_bondIsland);
        return true;
    }

    void uploadReductionOrders()
    {
        if (!deterministicReductionsEnabled()) return;
        for (std::uint32_t kind = 0; kind < 2u; ++kind)
        {
            auto& order = m_reductionOrder[kind];
            const auto& labels = kind ? m_hostNodeIsland : m_hostBondIsland;
            const auto count = kind ? m_nodeCount : m_bondCount;
            order.rowBegin.assign(m_islandCount + 1u, 0u);
            for (std::uint32_t i = 0; i < count; ++i)
                if (labels[i] != kNoIsland) ++order.rowBegin[labels[i] + 1u];
            for (std::uint32_t i = 0; i < m_islandCount; ++i)
                order.rowBegin[i + 1u] += order.rowBegin[i];
            order.cursor = order.rowBegin;
            order.order.resize(order.rowBegin.back());
            for (std::uint32_t i = 0; i < count; ++i)
                if (labels[i] != kNoIsland) order.order[order.cursor[labels[i]]++] = i;
            order.tiles.clear();
            order.partialBegin.resize(m_islandCount + 1u);
            for (std::uint32_t i = 0; i < m_islandCount; ++i)
            {
                order.partialBegin[i] = static_cast<std::uint32_t>(order.tiles.size());
                for (auto begin = order.rowBegin[i]; begin < order.rowBegin[i + 1u];)
                {
                    const auto end = begin + std::min(kDeterministicTileSize, order.rowBegin[i + 1u] - begin);
                    order.tiles.push_back(make_uint2(begin, end));
                    begin = end;
                }
            }
            order.partialBegin[m_islandCount] = static_cast<std::uint32_t>(order.tiles.size());
            stageUpload(order.deviceOrder, order.order.data(), sizeof(std::uint32_t) * order.order.size(), "upload reduction index order");
            stageUpload(order.deviceTiles, order.tiles.data(), sizeof(uint2) * order.tiles.size(), "upload reduction tiles");
            stageUpload(order.devicePartialBegin, order.partialBegin.data(), sizeof(std::uint32_t) * order.partialBegin.size(), "upload reduction island offsets");
        }
    }

    // Producers either fill padded atomic slots or unique dense contributions.
    // Clearing the exact live element count also zeroes inactive/static rows.
    // Graph launch caps can be rounded up beyond the allocation: do not use them
    // for dense scratch lengths.
    float* clearReduction(cudaStream_t stream, std::uint32_t kind, std::uint32_t slots)
    {
        float* output = slots ? m_reduceSlots : m_reductionInput;
        const std::size_t count = slots ? static_cast<std::size_t>(m_islandCount) * slots
                                       : (kind ? m_nodeCount : m_bondCount);
        checkCuda(cudaMemsetAsync(output, 0, sizeof(float) * count, stream), "clear island reduction");
        return output;
    }

    const float* finishReductionTiles(cudaStream_t stream, std::uint32_t kind)
    {
        if (!deterministicReductionsEnabled()) return m_reduceSlots;
        const auto& order = m_reductionOrder[kind];
        if (m_deviceTopology || !order.tiles.empty())
        {
            m_kernelProfile.begin("reduceIslandTiles", stream);
            const unsigned blocks = m_deviceTopology ? std::min(2560u,kind ? m_nodeCount : m_bondCount)
                                                     : static_cast<unsigned>(order.tiles.size());
            reduceIslandTiles<<<blocks, kBlockSize, 0, stream>>>(
                m_reductionInput, order.deviceOrder, order.deviceTiles, m_deterministicPartials,
                m_deviceTopology ? order.devicePartialBegin+m_islandCount : nullptr);
            m_kernelProfile.end(stream);
        }
        return m_deterministicPartials;
    }

    const std::uint32_t* reductionPartialBegin(std::uint32_t kind) const
    {
        return deterministicReductionsEnabled() ? m_reductionOrder[kind].devicePartialBegin : nullptr;
    }

    void uploadIslands()
    {
        stageUpload(m_bondIsland, m_hostBondIsland.data(), sizeof(std::uint32_t) * m_bondCount, "upload bond island ids");
        stageUpload(m_nodeIsland, m_hostNodeIsland.data(), sizeof(std::uint32_t) * m_nodeCount, "upload node island ids");
    }

    void uploadTopology()
    {
        stageUpload(m_node0, m_hostNode0.data(), sizeof(std::uint32_t) * m_bondCount, "upload node0");
        stageUpload(m_node1, m_hostNode1.data(), sizeof(std::uint32_t) * m_bondCount, "upload node1");
        stageUpload(m_offset0, m_hostOffset0.data(), sizeof(Vec4) * m_bondCount, "upload offset0");
        stageUpload(m_offset1, m_hostOffset1.data(), sizeof(Vec4) * m_bondCount, "upload offset1");
        stageUpload(m_inertia, m_hostInertia.data(), sizeof(Inertia) * m_nodeCount, "upload inertia");
        stageUpload(m_normals, m_hostNormals.data(), sizeof(Vec4) * m_bondCount, "upload normals");
        stageUpload(m_areas, m_hostAreas.data(), sizeof(float) * m_bondCount, "upload areas");
        stageUpload(m_colScales, m_hostColScale.data(), sizeof(float) * m_bondCount, "upload compliance weights");
        stageUpload(m_nodeDistances, m_hostNodeDistances.data(), sizeof(float) * m_bondCount, "upload node distances");
        stageUpload(m_health, m_hostHealth.data(), sizeof(float) * m_bondCount, "upload health");
        stageUpload(m_bondMaterials, m_hostBondMaterials.data(), sizeof(std::uint32_t) * m_bondCount, "upload bond materials");
        stageUpload(m_materials, m_hostMaterials.data(), sizeof(ExtStressGpuMaterial) * m_materialCount, "upload material table");
    }

    /// Per-island reduction. Replaces the whole-graph cub::DeviceReduce, which
    /// imposed a grid-wide barrier every iteration and produced a single
    /// residual that could not distinguish a converged island from a starved
    /// one.
    void reduceByIsland(
        cudaStream_t stream,
        const AngLin* values,
        const std::uint32_t* island,
        const std::uint32_t* islandSkip,
        const std::uint32_t* activeList,
        std::uint32_t whichCount,
        std::uint32_t launchCap,
        float* result)
    {
        const std::uint32_t slots = reductionSlots(launchCap);
        float* output = clearReduction(stream, whichCount, slots);
        m_kernelProfile.begin("accumulateSquaredByIsland", stream);
        accumulateSquaredByIsland<<<
            (launchCap + kBlockSize - 1) / kBlockSize,
            kBlockSize,
            0,
            stream>>>(
            values,
            island,
            islandSkip,
            output,
            activeList,
            m_activeCounts,
            whichCount,
            slots);
        m_kernelProfile.end(stream);
        const float* partials = finishReductionTiles(stream, whichCount);
        m_kernelProfile.begin("finalizeIslandReduction", stream);
        finalizeIslandReduction<<<
            (m_islandCount + kBlockSize - 1) / kBlockSize,
            kBlockSize,
            0,
            stream>>>(partials, result, m_islandCount, slots, reductionPartialBegin(whichCount));
        m_kernelProfile.end(stream);
    }

    /// How many accumulators to spread each island's atomics across.
    ///
    /// Padding buys contention relief proportional to the slot count and costs
    /// a second pass proportional to islandCount * slots. It is worth it only
    /// when islands are large: at ~2,760 elements per island (the intact city)
    /// 32 slots turn 2,760-way serialization into 86-way; at ~4 elements per
    /// island (fully fractured) there is no contention to relieve and the wide
    /// second pass would be pure loss. Round down to a power of two so the
    /// kernel can mask instead of divide.
    std::uint32_t reductionSlots(std::uint32_t elements) const
    {
        if (deterministicReductionsEnabled()) return 0u;
        if (m_islandCount == 0)
        {
            return 1u;
        }
        const std::uint32_t perIsland = elements / m_islandCount;
        std::uint32_t slots = 1u;
        // One slot per 8 elements, so a slot is never contended by fewer
        // atomics than the second pass costs to read it back.
        while (slots < kReductionSlotsMax && slots * 8u < perIsland)
        {
            slots <<= 1u;
        }
        return slots;
    }

    void rightMultiply(
        cudaStream_t stream, const AngLin* bonds, AngLin* nodes,
        const std::uint32_t* islandSkip)
    {
        if (gatherRightMultiplyEnabled())
        {
            // No memset: every active node writes its own slot. No scaleNodes
            // either: the inverse-inertia scale is folded into the write. Two
            // graph nodes become one, and twelve global float atomics per
            // bond become zero.
            m_kernelProfile.begin("gatherRightMultiply", stream);
            gatherRightMultiply<<<
                (m_graphNodeCap + kBlockSize - 1) / kBlockSize,
                kBlockSize,
                0,
                stream>>>(
                nodes,
                bonds,
                m_nodeBondBegin,
                m_nodeBondRef,
                m_offset0,
                m_offset1,
                m_health,
                m_colScales,
                m_bondIsland,
                islandSkip,
                m_inertia,
                m_activeNodes,
                m_activeCounts);
            m_kernelProfile.end(stream);
            return;
        }
        checkCuda(
            cudaMemsetAsync(
                nodes,
                0,
                sizeof(AngLin) * m_nodeCount,
                stream),
            "clear node product");
        m_kernelProfile.begin("couplingRightMultiply", stream);
        couplingRightMultiply<<<
            (m_graphBondCap + kBlockSize - 1) / kBlockSize,
            kBlockSize,
            0,
            stream>>>(
            nodes,
            bonds,
            m_node0,
            m_node1,
            m_offset0,
            m_offset1,
            m_health,
            m_colScales,
            m_bondIsland,
            islandSkip,
            m_activeBonds,
            m_activeCounts);
        m_kernelProfile.end(stream);
        m_kernelProfile.begin("scaleNodes", stream);
        scaleNodes<<<
            (m_graphNodeCap + kBlockSize - 1) / kBlockSize,
            kBlockSize,
            0,
            stream>>>(
            nodes,
            m_inertia,
            m_activeNodes,
            m_activeCounts);
        m_kernelProfile.end(stream);
    }

    /// Sum of |impulse| over all bonds, read back from the device.
    /// Debug only: a full D2H copy, gated on BLAST_ISLAND_TRACE.
    double debugImpulseMagnitude()
    {
        m_dbgImpulses.resize(m_bondCount);
        if (cudaMemcpy(m_dbgImpulses.data(), m_impulses,
                       sizeof(AngLin) * m_bondCount,
                       cudaMemcpyDeviceToHost) != cudaSuccess)
        {
            cudaGetLastError();
            return -1.0;
        }
        double total = 0.0;
        for (const AngLin& v : m_dbgImpulses)
        {
            total += (std::fabs(double(v.linear.x)) + std::fabs(double(v.linear.y))
                   + std::fabs(double(v.linear.z))) * double(m_lengthScale * m_massScale);
        }
        return total;
    }

#include "detail/StressIterationDispatch.inl"
#include "detail/StressSolveSubmission.inl"
#include "detail/StressGraphExecution.inl"
    std::uint32_t m_nodeCount;
    std::uint32_t m_bondCount;
    CUcontext m_cudaContext{nullptr};
    DeviceStressTopology* m_deviceTopology{nullptr};
    bool m_deviceTopologyFailed{false};
    float m_massScale{1.0f};
    float m_lengthScale{1.0f};
    bool m_hasWarmStart{false};
    std::vector<AngLin> m_dbgImpulses;
    std::vector<std::uint32_t> m_dbgActive;
    std::vector<std::uint32_t> m_dbgConverged;
    double m_dbgSumBefore{0.0};
    bool m_dbgWarm{false};
    ExtStressGpuTelemetry m_telemetry{};

    PinnedVector<std::uint32_t> m_hostNode0;
    PinnedVector<std::uint32_t> m_hostNode1;
    PinnedVector<Vec4> m_hostOffset0;
    PinnedVector<Vec4> m_hostOffset1;
    PinnedVector<Inertia> m_hostInertia;
    PinnedVector<Vec4> m_hostNormals;
    PinnedVector<float> m_hostAreas;
    /// Per-bond compliance weight, the CPU processor's column scale.
    PinnedVector<float> m_hostColScale;
    PinnedVector<float> m_hostNodeDistances;
    PinnedVector<float> m_hostHealth;
    PinnedVector<std::uint32_t> m_hostBondMaterials;
    PinnedVector<ExtStressGpuMaterial> m_hostMaterials;

    std::uint32_t* m_node0{nullptr};
    std::uint32_t* m_node1{nullptr};
    Vec4* m_offset0{nullptr};
    Vec4* m_offset1{nullptr};
    Inertia* m_inertia{nullptr};
    Vec4* m_normals{nullptr};
    /// Bending policy, taken from solve params so the device matches the host.
    float m_bendGainMax{0.0f};
    float* m_areas{nullptr};
    // Per-bond compliance weight, uploaded verbatim from the CPU processor.
    float* m_colScales{nullptr};
    float* m_nodeDistances{nullptr};
    float* m_health{nullptr};
    std::uint32_t* m_bondMaterials{nullptr};
    ExtStressGpuMaterial* m_materials{nullptr};
    std::uint32_t m_materialCount{0};
    std::uint32_t* m_brokenBonds{nullptr};
    std::uint32_t* m_brokenCount{nullptr};
    ExtStressGpuImpulse* m_input{nullptr};
    AngLin* m_impulses{nullptr};
    AngLin* m_rhs{nullptr};
    AngLin* m_gradient{nullptr};
    AngLin* m_direction{nullptr};
    AngLin* m_residual{nullptr};
    AngLin* m_projectedDirection{nullptr};
    float* m_reductionInput{nullptr};
    float* m_deterministicPartials{nullptr};
    IslandReductionOrder m_reductionOrder[2]; // bond, node (activeCounts convention)
    float* m_gradientSquared{nullptr};
    /// Padded scratch for the per-island reduction; see accumulateSquaredByIsland.
    float* m_reduceSlots{nullptr};
    /// Device-side CG loop counter; advanced by retireDegenerateIslands.
    std::uint32_t* m_iteration{nullptr};
    /// Scratch reused across topology rebuilds; see computeIslands /
    /// buildNodeBondCsr / groupBondsByIsland.
    std::vector<std::uint32_t> m_hostRootStamp;
    std::uint32_t m_rootIslandGeneration{0};
    std::vector<std::uint32_t> m_csrCursor;
    std::vector<std::uint32_t> m_groupCursor;
    /// Bond removals since the island partition was last rebuilt.
    std::uint32_t m_removalsSinceRepartition{0};
    /// False when swap-with-last moved bonds out from under m_bondsByIsland.
    bool m_bondsByIslandValid{true};
    /// Endpoint pairs of the bonds removed since the last topology apply.
    std::vector<std::pair<std::uint32_t, std::uint32_t>> m_splitChecks;
    std::vector<std::uint32_t> m_splitVisited;
    std::vector<std::uint32_t> m_splitQueue;
    std::uint32_t m_splitStamp{0};
    /// Bond slots rewritten since the last topology upload.
    std::vector<std::uint32_t> m_changedBondSlots;
    PinnedVector<std::uint32_t> m_deltaSlots;
    PinnedVector<BondDelta> m_deltaValues;
    std::uint32_t* m_devDeltaSlots{nullptr};
    BondDelta* m_devDeltaValues{nullptr};
    std::uint32_t m_deltaCapacity{0};
    /// Per-node inertia never changes after prepare(); upload it once.
    bool m_inertiaUploaded{false};
    AngLin* m_nsPi{nullptr};
    AngLin* m_nsQ{nullptr};
    AngLin* m_nsW{nullptr};
    AngLin* m_nsMu{nullptr};
    AngLin* m_nsG{nullptr};
    AngLin* m_nsW2{nullptr};
    float* m_nsJacobi{nullptr};
    float* m_nsGamma{nullptr};
    float* m_nsGammaPrev{nullptr};
    bool m_jacobiBuilt{false};
    /// Position of each bond's two CSR refs; lets a removal patch in O(1).
    std::vector<std::uint32_t> m_hostBondRefPos;
    std::vector<std::uint32_t> m_changedRefSlots;
    PinnedVector<std::uint32_t> m_refSlots;
    PinnedVector<std::uint32_t> m_refValues;
    std::uint32_t* m_devRefSlots{nullptr};
    std::uint32_t* m_devRefValues{nullptr};
    std::uint32_t m_refDeltaCapacity{0};
    std::size_t m_deadRefCount{0};
    bool m_csrValid{false};
    std::vector<std::uint32_t> m_changedNodeIslandSlots;
    PinnedVector<std::uint32_t> m_nodeIslandSlots;
    PinnedVector<std::uint32_t> m_nodeIslandValues;
    std::uint32_t* m_devNodeIslandSlots{nullptr};
    std::uint32_t* m_devNodeIslandValues{nullptr};
    std::uint32_t m_nodeIslandDeltaCapacity{0};
    std::uint64_t m_statLocalSplits{0};
    std::uint32_t m_islandCountAtRebuild{0};
    std::vector<std::uint32_t> m_affectedIslands;
    std::vector<std::uint32_t> m_affectedNodes;
    std::map<std::uint32_t, std::uint32_t> m_rootRemap;
    std::vector<std::uint32_t> m_verifyNodeIsland;
    std::vector<std::uint32_t> m_verifyBondIsland;
    std::uint64_t m_verifyCalls{0};
    std::uint64_t m_statConditionalLoops{0};
    /// Per-island conjugate-gradient state. Islands are disconnected
    /// components: they must converge and step independently, matching the CPU
    /// solver's per-island sub-solves.
    std::uint32_t* m_islandActive{nullptr};
    /// Set when an island reaches tolerance; kept separate from `active`
    /// because a degenerate island also goes inactive, and only a CONVERGED
    /// one has earned the right to be skipped next frame.
    std::uint32_t* m_islandConverged{nullptr};
    /// This frame's decision, one entry per island, uploaded before the graph
    /// runs. 1 = settled, do not touch.
    std::uint32_t* m_islandSkip{nullptr};
    std::uint32_t* m_deviceIslandDirty{nullptr};
    KernelProfile m_kernelProfile;
    std::uint32_t m_profiledSolves{0};
    std::uint32_t* m_blockActiveCounts{nullptr};
    std::uint32_t* m_nodeBondBegin{nullptr};
    std::uint32_t* m_nodeBondRef{nullptr};
    std::uint32_t* m_bondIsland{nullptr};
    std::uint32_t* m_nodeIsland{nullptr};
    std::uint32_t m_islandCount{1};
    std::uint32_t m_islandCapacity{1};
    /// Set by removeBond; consumed by applyTopologyChange on the next solve.
    bool m_topologyDirty{false};
    /// See ExtStressGpuSolveParams::skipStableUnconverged.
    bool m_skipStableUnconverged{false};
    /// Device-impulse permutations recorded by removeBond, replayed at the
    /// next applyTopologyChange so device and host bond order stay identical.
    std::vector<std::pair<std::uint32_t, std::uint32_t>> m_pendingImpulseSwaps;
    /// Nodes whose bonds broke or were removed; consumed by planSettledSkip.
    std::vector<std::uint32_t> m_forceDirtyNodes;
    /// Bonds grouped by island (CSR), built once: the partition is fixed for
    /// the solver's lifetime.
    std::vector<std::uint32_t> m_islandBondBegin;
    std::vector<std::uint32_t> m_bondsByIsland;
    /// Host-side settled state. m_hostIslandConverged is the baseline carried
    /// between frames; m_settledBaselineValid says whether it refers to
    /// anything.
    std::vector<std::uint32_t> m_hostIslandConverged;
    std::vector<std::uint8_t> m_islandDirty;
    std::vector<std::uint32_t> m_changedNodes;
    std::vector<std::uint32_t> m_changedBonds;
    bool m_settledBaselineValid{false};
    /// Set when a solve() call found nothing to do at all, so the caller can
    /// skip its own post-solve work too.
    bool m_solveWasNoOp{false};
    /// Time spent BLOCKED inside refreshActiveLists this solve, kept apart
    /// from planning work so the host split means something.
    float m_activeListSyncMilliseconds{0.0f};
    std::uint32_t m_debugSolves{0};
    std::uint32_t* m_scatterIndices{nullptr};
    ExtStressGpuImpulse* m_scatterValues{nullptr};
    std::uint32_t* m_gatherIndices{nullptr};
    AngLin* m_gatherOutput{nullptr};
    std::vector<std::uint32_t> m_hostParent;
    std::vector<std::uint32_t> m_hostRootIsland;
    /// G1: node -> incident-bond CSR (offsets, and refs packing bond index +
    /// endpoint bit). Host-built at every topology change, uploaded once.
    PinnedVector<std::uint32_t> m_hostNodeBondBegin;
    PinnedVector<std::uint32_t> m_hostNodeBondRef;
    PinnedVector<std::uint32_t> m_hostBondIsland;
    PinnedVector<std::uint32_t> m_hostNodeIsland;
    float* m_projectedDirectionSquared{nullptr};
    float* m_deltaSquared{nullptr};
    float* m_previousGradientSquared{nullptr};
    SolveStatus* m_status{nullptr};
    /// Pinned staging that doubles as the settled baseline: a byte-exact
    /// record of the velocities the device currently holds.
    ExtStressGpuImpulse* m_hostInput{nullptr};
    bool m_hostInputValid{true};
    AngLin* m_hostImpulses{nullptr};
    ExtStressGpuImpulse* m_devicePhysicalImpulses{nullptr};
    SolveStatus* m_hostStatus{nullptr};
    std::uint32_t* m_hostBrokenCount{nullptr};
    std::uint32_t* m_hostIslandSkip{nullptr};
    std::uint32_t* m_hostIslandConvergedPinned{nullptr};
    std::uint32_t* m_hostScatterIndices{nullptr};
    ExtStressGpuImpulse* m_hostScatterValues{nullptr};
    std::uint32_t* m_hostGatherIndices{nullptr};
    cudaEvent_t m_uploadStart{};
    cudaEvent_t m_uploadStop{};
    cudaEvent_t m_solveStart{};
    cudaEvent_t m_solveStop{};
    cudaEvent_t m_statusReady{};
    cudaEvent_t m_downloadStart{};
    cudaEvent_t m_downloadStop{};
    cudaStream_t m_stream{};
    /// Capture-only stream for the conditional loop body graph.
    cudaStream_t m_bodyStream{};
    cudaGraph_t m_graph{};
    cudaGraphExec_t m_graphExec{};
    ExtStressGpuSolveParams m_graphParams{};
    bool m_graphWarmStart{false};
    // Active-set state: the solve kernels walk these compacted lists so a
    // tick costs what is moving, not what exists. Rebuilt (one device pass)
    // only when the skip set or the topology changes; counts live at
    // m_activeCounts[0]=bonds / [1]=nodes and are read by the kernels from
    // device memory, so their CONTENTS never force a graph recapture -- only
    // outgrowing the baked launch capacity does (executeSolve).
    std::uint32_t* m_activeBonds{nullptr};
    std::uint32_t* m_activeNodes{nullptr};
    std::uint32_t* m_activeCounts{nullptr};
    /// Shared 0/1 flag buffer for the two DeviceSelect compactions, sized
    /// max(bonds, nodes); stream order serializes the reuse.
    std::uint32_t* m_activeFlags{nullptr};
    void* m_selectScratch{nullptr};
    std::size_t m_selectScratchBytes{0};
    std::uint32_t* m_hostActiveCounts{nullptr};
    std::uint32_t m_activeBondCount{0};
    std::uint32_t m_activeNodeCount{0};
    std::uint32_t m_graphBondCap{0};
    std::uint32_t m_graphNodeCap{0};
    std::vector<std::uint32_t> m_prevIslandSkip;
    bool m_prevListsSkipping{false};
    bool m_activeListsDirty{true};
    std::uint32_t m_statSolves{0};
    std::uint32_t m_statListRefreshes{0};
    std::uint32_t m_statListSkips{0};
    std::uint32_t m_statGraphRecaptures{0};
    double m_statMidSyncMs{0.0};
    double m_statPlanMs{0.0};
    std::uint64_t m_statIterations{0};
    std::uint32_t m_statUnconverged{0};
    std::vector<float> m_statResGrad;
    std::vector<float> m_statResDelta;
    std::vector<std::uint32_t> m_statResActive;
    double m_statResSum{0.0};
    double m_statResMax{0.0};
    std::uint64_t m_statResCount{0};
    std::uint64_t m_statResOverTol{0};
    double m_statFinishMs{0.0};
    double m_statWaitMs{0.0};
    double m_statLastMidSync{0.0};

    /// Class-scope host timer. solve() has its own local HostClock/hostMs
    /// lambda; enqueueSolve needs the same thing and cannot see them.
    using StatClock = std::chrono::steady_clock;
    static double statMs(StatClock::time_point from)
    {
        return std::chrono::duration<double, std::milli>(StatClock::now() - from)
            .count();
    }
    double m_statPlanSkipMs{0.0};
    double m_statTopoMs{0.0};
    double m_statTopoIslandsMs{0.0};
    double m_statTopoCsrMs{0.0};
    double m_statTopoGroupMs{0.0};
    double m_statTopoUploadMs{0.0};
    double m_statTopoMemsetMs{0.0};
    void* m_topoStaging{nullptr};
    std::size_t m_topoStagingBytes{0};
    std::size_t m_topoStagingUsed{0};
    cudaEvent_t m_topoUploadDone{nullptr};
    bool m_topoUploadsPending{false};
    std::vector<char> m_pageableBounce;
    std::uint64_t m_statTopoBytes{0};
    std::uint32_t m_statTopoCopies{0};
    std::uint32_t m_statTopoGrowths{0};
    double m_statStageCopyMs{0.0};
    std::uint32_t m_statTopoCalls{0};
    double m_statRefreshMs{0.0};
    double m_statCaptureMs{0.0};
    double m_statInstantiateMs{0.0};
    std::uint32_t m_statGraphUpdates{0};
    double m_statUpdateMs{0.0};
    bool m_graphParamsDirty{false};

    // Device bond-stress walk. Capacities grow only.
    std::uint32_t* m_bsGroupBegin{nullptr};
    std::uint32_t* m_bsGroupSize{nullptr};
    std::uint32_t* m_bsMemberBlastBond{nullptr};
    std::uint32_t* m_bsBondNode0{nullptr};
    std::uint32_t* m_bsBondNode1{nullptr};
    std::uint32_t* m_bsBondMaterial{nullptr};
    float* m_bsBondNormal{nullptr};
    float* m_bsBondCentroid{nullptr};
    float* m_bsBondNodeDisp{nullptr};
    float* m_bsHealth{nullptr};
    float* m_bsGroupStressNormal{nullptr};
    float* m_bsGroupStressShear{nullptr};
    float* m_bsGroupStressBend{nullptr};
    float* m_bsGroupNormal{nullptr};
    float* m_bsGroupCentroid{nullptr};
    std::uint32_t* m_bsOverGroupIds{nullptr};
    float* m_bsOverGroupRecords{nullptr};
    std::uint32_t* m_bsHostOverGroupIds{nullptr};
    float* m_bsHostOverGroupRecords{nullptr};
    float* m_bsHostGroupStressBend{nullptr};
    std::uint32_t m_bsOverWindow{256};
    std::uint32_t m_bsOverQuietTicks{0};
    std::uint8_t* m_bsNodeOverstressed{nullptr};
    std::uint32_t* m_bsGroupRemoveCount{nullptr};
    std::uint32_t* m_bsGroupRemoveOffset{nullptr};
    std::uint32_t* m_bsRemoveFlag{nullptr};
    std::uint32_t* m_bsRemoveList{nullptr};
    std::uint32_t* m_bsOverstressedCount{nullptr};
    void* m_bsScanScratch{nullptr};
    std::size_t m_bsScanScratchBytes{0};
    std::uint32_t* m_bsHostRemoveList{nullptr};
    std::uint8_t* m_bsHostNodeOverstressed{nullptr};
    float* m_bsHostGroupStressNormal{nullptr};
    float* m_bsHostGroupStressShear{nullptr};
    float* m_bsHostGroupNormal{nullptr};
    float* m_bsHostGroupCentroid{nullptr};
    std::uint32_t* m_bsHostCounts{nullptr};
    std::uint32_t m_bsGroupCapacity{0};
    std::uint32_t m_bsSlotCapacity{0};
    std::uint32_t m_bsNodeCapacity{0};
    std::uint32_t m_bsBondCapacity{0};
    float* m_bsMaterialLimits{nullptr};
    std::uint32_t m_bsMaterialCapacity{0};
    bool m_bsReady{false};
    /// Pinned staging: pageable source memory cannot DMA.
    std::uint32_t* m_bsPinGroupBegin{nullptr};
    std::uint32_t* m_bsPinGroupSize{nullptr};
    std::uint32_t* m_bsPinMembers{nullptr};
    float* m_bsPinHealth{nullptr};
    float* m_bsPinMaterials{nullptr};
    bool m_bsCsrResident{false};
    bool m_bsHealthResident{false};
    bool m_bsVectorsFetched{false};
    bool m_bsStressFetched{false};
    std::uint32_t m_bsVectorGroups{0};
    cudaStream_t m_bsStream{nullptr};
    cudaEvent_t m_bsEvUploadStart{nullptr};
    cudaEvent_t m_bsEvUploadStop{nullptr};
    cudaEvent_t m_bsEvKernelStop{nullptr};
    cudaEvent_t m_bsEvReadStop{nullptr};
};

} // namespace

ExtStressGpuSolver* ExtStressGpuSolver::create(
    const ExtStressGpuNode* nodes,
    std::uint32_t nodeCount,
    const ExtStressGpuBond* bonds,
    std::uint32_t bondCount,
    const ExtStressGpuMaterial* materials,
    std::uint32_t materialCount,
    void* cudaContext)
{
    if (!nodes || !bonds || nodeCount == 0 || bondCount == 0)
    {
        return nullptr;
    }
    try
    {
        return new ExtStressGpuSolverImpl(
            nodes,
            nodeCount,
            bonds,
            bondCount,
            materials,
            materialCount,
            reinterpret_cast<CUcontext>(cudaContext));
    }
    catch (...)
    {
        return nullptr;
    }
}

} // namespace Blast
} // namespace Nv
