// Production-object TGS contact-solve component gate. No substitute GPU equations.
// This is NOT contact preparation, a complete timestep, a scene, or destruction.
#include <cuda_runtime.h>
#include <cumetal_driver.h>
#include "PxgSolverBody.h"
#include "PxgSolverConstraintDesc.h"
#include "PxgConstraintBlock.h"
#include "PxgIslandContext.h"
#include "PxgSolverCoreDesc.h"
#include "PxgDynamicsConfiguration.h"
#include <array>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <stdexcept>
#include <string>
#include <vector>

extern "C" void initSolverKernels5();
using namespace physx;
namespace {
void runtime(cudaError_t result, const char* what) {
    if (result != cudaSuccess) throw std::runtime_error(std::string(what) + ": " + cudaGetErrorString(result));
}
void driver(CUresult result, const char* what) {
    if (result == CUDA_SUCCESS) return;
    const char* error = nullptr;
    cuGetErrorString(result, &error);
    throw std::runtime_error(std::string(what) + ": " + (error ? error : "unknown driver error"));
}

// Every allocation has one full typed element at either end as a byte guard.
// sizeof(T) preserves the actual header alignment when the pointer is offset.
template<class T> struct Buffer {
    T* base = nullptr;
    size_t count;
    std::vector<T> guarded;
    explicit Buffer(size_t n) : count(n), guarded(n + 2) {
        std::memset(guarded.data(), 0xa5, sizeof(T) * guarded.size());
        runtime(cudaMalloc(&base, sizeof(T) * guarded.size()), "allocate guarded input");
        runtime(cudaMemcpy(base, guarded.data(), sizeof(T) * guarded.size(), cudaMemcpyHostToDevice), "initialize guards");
    }
    ~Buffer() { if (base) cudaFree(base); }
    Buffer(const Buffer&) = delete;
    T* data() const { return base + 1; }
    void upload(const T* values, cudaStream_t stream) {
        runtime(cudaMemcpyAsync(data(), values, sizeof(T) * count, cudaMemcpyHostToDevice, stream), "upload fixture");
    }
    void download(T* values, cudaStream_t stream) const {
        runtime(cudaMemcpyAsync(values, data(), sizeof(T) * count, cudaMemcpyDeviceToHost, stream), "download fixture");
    }
    void checkGuard() {
        std::array<unsigned char, sizeof(T)> actual{};
        for (const T* address : {base, base + count + 1}) {
            runtime(cudaMemcpy(actual.data(), address, sizeof(T), cudaMemcpyDeviceToHost), "read guard");
            for (auto byte : actual) if (byte != 0xa5) throw std::runtime_error("allocation guard changed");
        }
    }
};

constexpr unsigned Lanes = 32, Bodies = 64, PoolSize = 576, Output = 192, Accumulated = 384;
constexpr float Tolerance = 1e-5f; // Existing fork velocity tolerance; no relaxed Metal tolerance.
float4 vector(float x = 0, float y = 0, float z = 0, float w = 0) { return float4{x, y, z, w}; }
unsigned outputIndex(unsigned body) { return Output + 3 * (body & ~31u) + (body & 31u); }

void close(float actual, float expected, const char* field, unsigned lane) {
    if (!std::isfinite(actual) || std::fabs(actual - expected) > Tolerance) {
        char message[240];
        std::snprintf(message, sizeof(message), "%s lane=%u actual=%.9g expected=%.9g tolerance=%.9g",
                      field, lane, static_cast<double>(actual), static_cast<double>(expected), static_cast<double>(Tolerance));
        throw std::runtime_error(message);
    }
}

struct Oracle { float normal, friction, xA, yA, angularA, xB, yB, angularB; unsigned broken; };

// All cases use unit inverse mass and identity inverse inertia, n=(1,0,0),
// zero separation/target velocity/deltas/restitution, and one active slab.
// Cases 0/1 disable friction; 2/3 have one centered anchor and orthogonal y/z rows.
// Case 1 has rA=(0,+1,0), rB=(0,-1,0), so raXn.z=-1, rbXn.z=+1.
// See README for the analytical impulse derivation from the production source.
bool runCase(CUfunction kernel, bool whole, unsigned scenario, cudaStream_t stream) {
    PxgIslandContext island{};
    island.mBodyCount = Bodies;
    island.mDescCount = Lanes;
    island.mNumPositionIterations = 4;
    island.mNumVelocityIterations = 1;
    island.mNumPartitions = 1;
    island.mBatchCount = 1;
    island.mBiasCoefficients.set(true, true, 4);
    const float bias = island.mBiasCoefficients.rigidContact; // 0.8, actual producer policy.
    auto batch = PxgBlockConstraintBatch(); // Value-init permits explicit PxNodeIndex default constructors.
    batch.mDescStride = Lanes;
    batch.constraintType = PxgSolverConstraintDesc::eCONTACT;
    batch.mask = 0xffffffffu;
    PxgTGSBlockSolverContactHeader contactHeader{};
    PxgTGSBlockSolverFrictionHeader frictionHeader{};
    PxgTGSBlockSolverContactPoint contact{};
    std::array<PxgTGSBlockSolverContactFriction, 2> friction{};
    std::array<PxgSolverReferences, Bodies> references{};
    std::array<PxU32, Bodies> active{};
    std::array<float4, PoolSize> pool{};
    std::array<Oracle, Lanes> expected{};
    const float4 sentinel = vector(812.25f, -613.5f, 414.75f, -215.0f);
    pool.fill(sentinel);
    for (unsigned body = 0; body < Bodies; ++body) {
        references[body].mRemappedBodyIndex = outputIndex(body);
        active[body] = 1; // Bit zero: slab zero is active, exactly one reference.
    }
    for (unsigned lane = 0; lane < Lanes; ++lane) {
        const float speed = 0.5f + float(lane) / 32.0f; // Distinct payload in every SIMD lane.
        const bool angular = scenario == 1, hasFriction = scenario >= 2, sliding = scenario == 3;
        const float tangential = hasFriction ? (sliding ? 2.0f : 0.5f) * speed : 0.0f;
        const float normalImpulse = angular ? speed / 2.0f : speed;
        const float frictionImpulse = hasFriction ? (sliding ? -0.25f * normalImpulse : -bias * tangential) : 0.0f;
        expected[lane] = {normalImpulse, frictionImpulse, -speed + normalImpulse,
            tangential + frictionImpulse, angular ? -normalImpulse : 0.0f,
            speed - normalImpulse, -tangential - frictionImpulse,
            angular ? -normalImpulse : 0.0f, sliding ? 1u : 0u};
        batch.bodyAIndex[lane] = lane;
        batch.bodyBIndex[lane] = Lanes + lane;
        batch.remappedBodyAIndex[lane] = outputIndex(lane);
        batch.remappedBodyBIndex[lane] = outputIndex(Lanes + lane);
        contactHeader.invMass0_1_angDom0_1[lane] = vector(1, 1, 1, 1);
        contactHeader.normal_staticFriction[lane] = vector(1, 0, 0, hasFriction ? (sliding ? 0.3f : 1.0f) : 0.0f);
        contactHeader.numNormalConstr[lane] = 1;
        contactHeader.maxPenBias[lane] = -1000; // Physical depenetration clamp; zero error is unbiased.
        contactHeader.forceWritebackOffset[lane] = 0xffffffffu; // No publication kernel in this component gate.
        contactHeader.biasCoefficient[lane] = bias;
        contact.raXn_extraCoeff[lane] = vector(0, 0, angular ? -1.0f : 0.0f, 0);
        contact.rbXn_targetVelW[lane] = vector(0, 0, angular ? 1.0f : 0.0f, 0);
        contact.maxImpulse[lane] = 1000;
        contact.biasCoefficient[lane] = -240 * bias; // Four position substeps at 60 Hz.
        contact.resp0[lane] = contact.resp1[lane] = angular ? 2 : 1;
        frictionHeader.numFrictionConstr[lane] = hasFriction ? 2 : 0;
        frictionHeader.frictionNormals[0][lane] = vector(0, 1, 0);
        frictionHeader.frictionNormals[1][lane] = vector(0, 0, 1);
        frictionHeader.dynamicFriction[lane] = sliding ? 0.25f : 1.0f;
        frictionHeader.biasCoefficient[lane] = 240; // Strong friction, zero anchor error.
        for (auto& row : friction) row.resp0[lane] = row.resp1[lane] = 1;
        const float4 a = vector(-speed, tangential, 0), b = vector(speed, -tangential, 0);
        if (whole) {
            for (unsigned body : {lane, Lanes + lane}) {
                pool[Accumulated + body] = body == lane ? a : b;
                pool[Accumulated + Bodies + body] = vector();
                pool[Accumulated + 2 * Bodies + body] = vector();
            }
        } else {
            pool[lane] = a;
            pool[lane + 32] = pool[lane + 64] = vector();
            pool[lane + 96] = b;
            pool[lane + 128] = pool[lane + 160] = vector();
        }
    }
    Buffer<PxgIslandContext> dIsland(1);
    Buffer<PxgBlockConstraintBatch> dBatch(1);
    Buffer<PxgTGSBlockSolverContactHeader> dHeader(1);
    Buffer<PxgTGSBlockSolverFrictionHeader> dFrictionHeader(1);
    Buffer<PxgTGSBlockSolverContactPoint> dContact(1);
    Buffer<PxgTGSBlockSolverContactFriction> dFriction(2);
    Buffer<PxgSolverReferences> dReferences(Bodies);
    Buffer<PxU32> dActive(Bodies), dPartitions(1);
    Buffer<float4> dPool(PoolSize);
    Buffer<PxgSolverCoreDesc> dCore(1);
    Buffer<PxgSolverSharedDesc<IterativeSolveDataTGS>> dShared(1);
    PxgSolverCoreDesc core{};
    PxgSolverSharedDesc<IterativeSolveDataTGS> shared{};
    core.islandContextPool = dIsland.data();
    core.constraintsPerPartition = dPartitions.data();
    core.solverBodyReferences = dReferences.data();
    core.numSolverBodies = Bodies;
    core.numSlabs = 1;
    core.numBatches = 1;
    core.accumulatedBodyDeltaVOffset = Accumulated;
    // Joint, articulation, static-contact and transform inputs are not reached:
    // every batch is rigid CONTACT and only grid.y=0 is launched.
    shared.dt = 1.0f / 60;
    shared.stepDt = shared.dt / 4;
    shared.invDtF32 = 60;
    shared.stepInvDtF32 = 240;
    shared.lengthScale = 1;
    shared.iterativeData.blockConstraintBatch = dBatch.data();
    shared.iterativeData.blockContactHeaders = dHeader.data();
    shared.iterativeData.blockFrictionHeaders = dFrictionHeader.data();
    shared.iterativeData.blockContactPoints = dContact.data();
    shared.iterativeData.blockFrictions = dFriction.data();
    shared.iterativeData.solverBodyVelPool = dPool.data();
    shared.iterativeData.solverEncodedReferenceCount = dActive.data();
    PxU32 endPartition = 1, islandIndex = 0, partitionIndex = 0;
    bool doFriction = true;
    float elapsed = 0, minPen = -1e10f;
    void* articulation = nullptr;
    auto corePointer = dCore.data();
    auto sharedPointer = dShared.data();
    void* wholeArgs[] = {&corePointer, &sharedPointer, &islandIndex, &doFriction, &elapsed, &minPen};
    void* unifiedArgs[] = {&corePointer, &sharedPointer, &islandIndex, &partitionIndex, &doFriction, &elapsed, &minPen, &articulation};
    std::array<std::array<float4, PoolSize>, 2> results{};
    std::array<PxgTGSBlockSolverContactPoint, 2> contactResults{};
    std::array<std::array<PxgTGSBlockSolverContactFriction, 2>, 2> frictionResults{};
    std::array<PxgTGSBlockSolverFrictionHeader, 2> frictionHeaderResults{};
    struct FlushBeforeStorageDestruction {
        cudaStream_t stream;
        ~FlushBeforeStorageDestruction() { cudaStreamSynchronize(stream); }
    } flush{stream}; // Also protects async host-storage lifetimes on an exception.
    dIsland.upload(&island, stream); dBatch.upload(&batch, stream); dHeader.upload(&contactHeader, stream);
    dReferences.upload(references.data(), stream); dActive.upload(active.data(), stream);
    dPartitions.upload(&endPartition, stream); dCore.upload(&core, stream); dShared.upload(&shared, stream);
    // Two upload -> real solve -> readback transactions are queued before one
    // synchronization. All async host storage remains alive and immutable.
    for (unsigned replay = 0; replay < 2; ++replay) {
        dPool.upload(pool.data(), stream); dContact.upload(&contact, stream);
        dFriction.upload(friction.data(), stream); dFrictionHeader.upload(&frictionHeader, stream);
        driver(cuLaunchKernel(kernel, 1, 1, 1, whole ? 256 : 32, whole ? 1 : 2, 1,
                              0, reinterpret_cast<CUstream>(stream), whole ? wholeArgs : unifiedArgs, nullptr), "production TGS solve");
        dPool.download(results[replay].data(), stream); dContact.download(&contactResults[replay], stream);
        dFriction.download(frictionResults[replay].data(), stream);
        dFrictionHeader.download(&frictionHeaderResults[replay], stream);
    }
    runtime(cudaStreamSynchronize(stream), "two queued production solves");
    for (unsigned replay = 0; replay < 2; ++replay) {
        for (unsigned lane = 0; lane < Lanes; ++lane) {
            const auto& e = expected[lane];
            for (unsigned side = 0; side < 2; ++side) {
                const unsigned at = outputIndex(lane + Lanes * side);
                const auto v = results[replay][at], w = results[replay][at + 32], d = results[replay][at + 64];
                close(v.x, side ? e.xB : e.xA, "linear x", lane);
                close(v.y, side ? e.yB : e.yA, "linear y", lane);
                close(v.z, 0, "linear z", lane); close(v.w, 0, "angular x", lane);
                close(w.x, 0, "angular y", lane);
                close(w.y, side ? e.angularB : e.angularA, "angular z", lane);
                close(w.z, 0, "linear delta x", lane); close(w.w, 0, "linear delta y", lane);
                close(d.x, 0, "linear delta z", lane); close(d.y, 0, "angular delta x", lane);
                close(d.z, 0, "angular delta y", lane); close(d.w, 0, "angular delta z", lane);
            }
            close(contactResults[replay].appliedForce[lane], e.normal, "normal impulse", lane);
            close(frictionResults[replay][0].appliedForce[lane], e.friction, "tangent impulse", lane);
            close(frictionResults[replay][1].appliedForce[lane], 0, "second tangent impulse", lane);
            if (frictionHeaderResults[replay].broken[lane] != e.broken) throw std::runtime_error("friction clamp state mismatch");
            const auto a = results[replay][outputIndex(lane)], b = results[replay][outputIndex(lane + Lanes)];
            close(a.x + b.x, 0, "linear momentum x", lane); close(a.y + b.y, 0, "linear momentum y", lane);
            if (scenario == 1) {
                const float spinA = results[replay][outputIndex(lane) + 32].y;
                const float spinB = results[replay][outputIndex(lane + Lanes) + 32].y;
                const float speed = 0.5f + float(lane) / 32.0f;
                // Centers (0,-1,0)/(0,+1,0); unit mass/inertia, common origin contact.
                close(a.x - b.x + spinA + spinB, -2 * speed, "total angular momentum z", lane);
            }
        }
        // Inputs/unrelated pool storage may not be overwritten by either kernel.
        for (unsigned i = 0; i < PoolSize; ++i) {
            if (i >= Output && i < Output + 3 * Bodies) continue;
            if (std::memcmp(&results[replay][i], &pool[i], sizeof(float4))) throw std::runtime_error("non-output pool storage changed");
        }
    }
    dIsland.checkGuard(); dBatch.checkGuard(); dHeader.checkGuard(); dFrictionHeader.checkGuard();
    dContact.checkGuard(); dFriction.checkGuard(); dReferences.checkGuard(); dActive.checkGuard();
    dPartitions.checkGuard(); dPool.checkGuard(); dCore.checkGuard(); dShared.checkGuard();
    std::printf("PASS kernel=%s case=%u pairs=32 queued_replays=2 tolerance=1e-5\n", whole ? "solveWholeIslandTGS" : "solveBlockUnified", scenario);
    return true;
}
} // namespace

int main() {
    std::setvbuf(stdout, nullptr, _IOLBF, 0);
    // This intentionally exercises all 32 contact lanes / 64 bodies. A smaller
    // legal production capacity must reject this fixture before any dispatch;
    // silently launching would overrun the actual whole-island shared arrays.
    if (PXG_TGS_WHOLE_ISLAND_MAX_BODIES < Bodies) {
        std::fprintf(stderr, "FAIL production TGS fixture requires %u body/slab entries; compiled capacity=%u\n",
                     Bodies, unsigned(PXG_TGS_WHOLE_ISLAND_MAX_BODIES));
        return 1;
    }
    std::printf("production_tgs_capacity=%u fixture_bodies=%u slabs=1\n",
                unsigned(PXG_TGS_WHOLE_ISLAND_MAX_BODIES), Bodies);
    if (!std::getenv("CUMETAL_USE_METAL_DEVICE_ADDRESSES") || std::strcmp(std::getenv("CUMETAL_USE_METAL_DEVICE_ADDRESSES"), "1") ||
        !std::getenv("CUMETAL_SYNC_EACH_LAUNCH") || std::strcmp(std::getenv("CUMETAL_SYNC_EACH_LAUNCH"), "0")) {
        std::fprintf(stderr, "FAIL require raw Metal addresses and explicit CUMETAL_SYNC_EACH_LAUNCH=0\n"); return 1;
    }
    CUcontext context = nullptr;
    cudaStream_t stream = nullptr;
    std::vector<CUmodule> modules;
    int result = 1;
    try {
        initSolverKernels5();
        driver(cuInit(0), "initialize driver");
        driver(cuCtxCreate(&context, 0, 0), "create context");
        runtime(cudaStreamCreate(&stream), "create ordered stream");
        size_t count = 0;
        driver(cumetalGetNativeModules(nullptr, 0, &count), "count native modules");
        std::vector<CuMetalModuleHandle> native(count);
        driver(cumetalGetNativeModules(native.data(), native.size(), &count), "enumerate native modules");
        for (auto handle : native) {
            CUmodule module = nullptr;
            driver(cumetalImportNativeModule(&module, handle), "import production module"); modules.push_back(module);
        }
        for (const char* name : {"solveWholeIslandTGS", "solveBlockUnified"}) {
            CUfunction kernel = nullptr;
            unsigned matches = 0;
            for (auto module : modules) {
                CUfunction candidate = nullptr;
                auto status = cuModuleGetFunction(&candidate, module, name);
                if (status == CUDA_SUCCESS) { ++matches; kernel = candidate; }
                else if (status != CUDA_ERROR_NOT_FOUND) driver(status, "resolve production kernel");
            }
            if (matches != 1) throw std::runtime_error("production kernel must resolve exactly once");
            driver(cuFuncLoad(kernel), "prepare real production pipeline");
            const bool whole = std::strcmp(name, "solveWholeIslandTGS") == 0;
            for (unsigned scenario = 0; scenario < 4; ++scenario) runCase(kernel, whole, scenario, stream);
        }
        std::puts("PASS production TGS contact-solve components; prep/integration/full timestep/scene/destruction NOT QUALIFIED");
        result = 0;
    } catch (const std::exception& error) { std::fprintf(stderr, "FAIL %s\n", error.what()); }
    // Flush pending operations before destroying module/stream/context on failure.
    if (stream) { cudaStreamSynchronize(stream); cudaStreamDestroy(stream); }
    for (auto module : modules) cuModuleUnload(module);
    if (context) cuCtxDestroy(context);
    return result;
}
