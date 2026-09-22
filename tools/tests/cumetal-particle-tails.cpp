// Execute the actual cudaParticleSystem.cu object, including its compacted
// tails.
#include "PxgContactManager.h"
#include "PxgConvexConvexShape.h"
#include "PxgParticleSystem.h"
#include "PxgParticleSystemCoreKernelIndices.h"
#include "PxsCachedTransform.h"
#include "PxsMaterialCore.h"
#include "geometry/PxGeometry.h"
#include <algorithm>
#include <cmath>
#include <cstdio>
#include <cstring>
#include <cuda_runtime.h>
#include <cumetal_driver.h>
#include <stdexcept>
#include <vector>
using namespace physx;
void check(cudaError_t e) {
  if (e != cudaSuccess)
    throw std::runtime_error(cudaGetErrorString(e));
}
void driver(CUresult e) {
  if (e != CUDA_SUCCESS)
    throw std::runtime_error("driver call failed: " + std::to_string(e));
}
void require(bool b, const char *reason) {
  if (!b)
    throw std::runtime_error(reason);
}
template <class T> struct Buffer {
  T *p;
  size_t count;
  explicit Buffer(size_t n) : count(n) { check(cudaMalloc(&p, n * sizeof(T))); }
  ~Buffer() { cudaFree(p); }
  void put(const T *data, cudaStream_t stream) {
    check(cudaMemcpyAsync(p, data, count * sizeof(T), cudaMemcpyHostToDevice,
                          stream));
  }
  void fill(cudaStream_t stream) {
    check(cudaMemsetAsync(p, 0xa5, count * sizeof(T), stream));
  }
  std::vector<T> get(cudaStream_t stream) {
    std::vector<T> v(count);
    check(cudaMemcpyAsync(v.data(), p, count * sizeof(T),
                          cudaMemcpyDeviceToHost, stream));
    check(cudaStreamSynchronize(stream));
    return v;
  }
};
bool sentinel(const void *p, size_t n) {
  const auto *b = static_cast<const unsigned char *>(p);
  return std::all_of(b, b + n, [](unsigned char c) { return c == 0xa5; });
}
bool contact(float x, float y, float z, float w, float expectedW = 0.125f) {
  return std::fabs(x - 1) < 1e-4f && std::fabs(y) < 1e-4f &&
         std::fabs(z) < 1e-4f && std::fabs(w - expectedW) < 1e-4f;
}
int main() {
  try {
    driver(cuInit(0));
    struct Context {
      CUcontext value;
      Context() { driver(cuCtxCreate(&value, 0, 0)); }
      ~Context() { cuCtxDestroy(value); }
    } context;
    size_t moduleCount = 0;
    driver(cumetalGetNativeModules(nullptr, 0, &moduleCount));
    require(moduleCount == 1, "one production module expected");
    CuMetalModuleHandle native;
    driver(cumetalGetNativeModules(&native, 1, &moduleCount));
    CUmodule module;
    driver(cumetalImportNativeModule(&module, native));
    CUfunction ordinary, diffuse;
    driver(
        cuModuleGetFunction(&ordinary, module, "ps_primitivesCollisionLaunch"));
    driver(cuModuleGetFunction(&diffuse, module,
                               "ps_primitivesDiffuseCollisionLaunch"));
    cudaStream_t stream;
    check(cudaStreamCreateWithFlags(&stream, cudaStreamNonBlocking));
    constexpr unsigned maxTests = 513, capacity = 3 * maxTests,
                       dcap =
                           PxgParticleContactInfo::MaxStaticContactsPerParticle;
    Buffer<PxgContactManagerInput> pairs(maxTests);
    Buffer<PxgShape> shapes(3);
    Buffer<PxsCachedTransform> transforms(3);
    Buffer<PxBounds3> bounds(3);
    Buffer<float> distances(3), rest(maxTests);
    Buffer<PxsMaterialData> materials(1);
    Buffer<unsigned> starts(maxTests), total(1), cellStart(1), emptyCell(1),
        cellEnd(1), counters(3), diffuseCounts(3);
    Buffer<int> numDiffuse(1);
    Buffer<float4> positions(1);
    Buffer<PxgParticleSystem> systems(2);
    Buffer<PxNodeIndex> remap(3);
    Buffer<PxgParticlePrimitiveContact> contacts(capacity + 2);
    Buffer<PxU64> particleKeys(capacity + 2);
    Buffer<PxU32> particleTemp(capacity + 2), particleOrder(capacity + 2),
        rigidTemp(capacity + 2), rigidOrder(capacity + 2);
    Buffer<PxNodeIndex> rigidKeys(capacity + 2);
    Buffer<PxgParticleContactInfo> dinfo(dcap + 2);
    Buffer<float> dimpulse(dcap + 2);
    Buffer<PxNodeIndex> dnodes(dcap + 2);
    std::vector<PxgContactManagerInput> hostPairs(maxTests);
    std::vector<unsigned> hostStarts(maxTests);
    std::vector<float> hostRest(maxTests, 0);
    for (unsigned i = 0; i < maxTests; ++i) {
      hostPairs[i] = {0, 1, 0, 1};
      hostStarts[i] = i;
    }
    PxgShape hostShapes[3]{};
    hostShapes[0].type = PxGeometryType::ePARTICLESYSTEM;
    hostShapes[0].particleOrSoftbodyId = 0;
    hostShapes[1].type = PxGeometryType::ePLANE;
    hostShapes[2].type = PxGeometryType::ePARTICLESYSTEM;
    hostShapes[2].particleOrSoftbodyId = 1;
    PxsCachedTransform hostTransforms[3]{};
    for (auto &t : hostTransforms)
      t.transform = PxTransform(PxIdentity);
    PxBounds3 hostBounds[3] = {PxBounds3(PxVec3(0), PxVec3(0.25f)),
                               PxBounds3(PxVec3(0), PxVec3(0.25f)),
                               PxBounds3(PxVec3(0), PxVec3(0.25f))};
    float hostDistances[3] = {0.125f, 0.125f, 0.125f};
    float4 hostPosition = make_float4(0.125f, 0, 0, 1);
    PxNodeIndex hostRemap[3] = {PxNodeIndex(PxU32(5)), PxNodeIndex(PxU32(37)),
                                PxNodeIndex(PxU32(7))};
    unsigned zero = 0, one = 1, empty = 0xffffffffu;
    int intOne = 1;
    PxsMaterialData material{};
    PxgParticleSystem system{};
    system.mCommonData.mGridCellWidth = 1;
    system.mCommonData.mGridSizeX = system.mCommonData.mGridSizeY =
        system.mCommonData.mGridSizeZ = 1;
    system.mCommonData.mNumParticles = 1;
    system.mCommonData.mMaxDiffuseParticles = 1;
    system.mData.mFlags = PxParticleFlags();
    system.mCellStart = cellStart.p;
    system.mCellEnd = cellEnd.p;
    system.mSortedOriginPos_InvMass = positions.p;
    system.mSortedPositions_InvMass = positions.p;
    system.mDiffuseCellStart = cellStart.p;
    system.mDiffuseCellEnd = cellEnd.p;
    system.mDiffuseSortedOriginPos_LifeTime = positions.p;
    system.mDiffuseSortedPos_LifeTime = positions.p;
    system.mNumDiffuseParticles = numDiffuse.p;
    system.mDiffuseOneWayContactInfos = dinfo.p + 1;
    system.mDiffuseOneWayForces = dimpulse.p + 1;
    system.mDiffuseOneWayNodeIndex = dnodes.p + 1;
    system.mDiffuseOneWayContactCount = diffuseCounts.p + 1;
    PxgParticleSystem hostSystems[2] = {system, system};
    hostSystems[1].mCellStart = emptyCell.p;
    hostSystems[1].mDiffuseCellStart = emptyCell.p;
    PxgParticleContactWriter writer{};
    writer.particleContacts = contacts.p + 1;
    writer.numTotalContacts = counters.p + 1;
    writer.contactSortedByParticle = particleKeys.p + 1;
    writer.tempContactByParticle = particleTemp.p + 1;
    writer.contactIndexSortedByParticle = particleOrder.p + 1;
    writer.contactByRigid = rigidKeys.p + 1;
    writer.tempContactByRigid = rigidTemp.p + 1;
    writer.contactIndexSortedByRigid = rigidOrder.p + 1;
    writer.maxContacts = capacity;
    pairs.put(hostPairs.data(), stream);
    starts.put(hostStarts.data(), stream);
    rest.put(hostRest.data(), stream);
    shapes.put(hostShapes, stream);
    transforms.put(hostTransforms, stream);
    bounds.put(hostBounds, stream);
    distances.put(hostDistances, stream);
    positions.put(&hostPosition, stream);
    remap.put(hostRemap, stream);
    cellStart.put(&zero, stream);
    emptyCell.put(&empty, stream);
    cellEnd.put(&one, stream);
    numDiffuse.put(&intOne, stream);
    systems.put(hostSystems, stream);
    materials.put(&material, stream);
    const unsigned sizes[] = {0, 1, 17, 31, 32, 33, 255, 256, 257, 513};
    for (unsigned grid : {1u, 2u})
      for (unsigned mode : {0u, 1u, 2u, 3u})
        for (bool isTGS : {false, true})
          for (unsigned n : sizes) {
            // For grid=1, mode=3, n=513: the first input block contributes
            // 129 live cells, then 256 more. The 385 pending items flush 256
            // and carry 129 through overflowIndex before the final one arrives.
            // Rest distances encode a distinct authored identity for every
            // work item; the plane equation gives w=1/8-i/4096 exactly.
            // Adjacent tags are farther apart than twice the unchanged 1e-4
            // tolerance, so decoding does not demand tighter numerical error.
            // Original dense/sparse/empty cases retain zero rest distance.
            unsigned expectedCount = 0;
            std::vector<bool> live(maxTests);
            for (unsigned i = 0; i < maxTests; ++i) {
              const bool carryHole = mode == 3 && i < 256 && (i % 2) && i != 1;
              const unsigned shape = mode == 2 || (mode == 1 && i % 2) || carryHole ? 2 : 0;
              live[i] = shape == 0;
              hostPairs[i] = {shape, 1, shape, 1};
              hostRest[i] = mode == 3 ? float(i) / 4096.0f : 0.0f;
              if (i < n && live[i]) expectedCount += 3;
            }
            pairs.put(hostPairs.data(), stream);
            rest.put(hostRest.data(), stream);
            std::printf("particle tails grid=%u mode=%u TGS=%u pairs=%u\n",
                        grid, mode, unsigned(isTGS), n);
            std::fflush(stdout);
            total.put(&n, stream);
            contacts.fill(stream);
            particleKeys.fill(stream);
            particleTemp.fill(stream);
            particleOrder.fill(stream);
            rigidKeys.fill(stream);
            rigidTemp.fill(stream);
            rigidOrder.fill(stream);
            dinfo.fill(stream);
            dimpulse.fill(stream);
            dnodes.fill(stream);
            counters.fill(stream);
            diffuseCounts.fill(stream);
            check(cudaMemcpyAsync(counters.p + 1, &zero, sizeof(zero),
                                  cudaMemcpyHostToDevice, stream));
            check(cudaMemcpyAsync(diffuseCounts.p + 1, &zero, sizeof(zero),
                                  cudaMemcpyHostToDevice, stream));
            float tolerance = 1;
            void *args[] = {
                &isTGS,        &n,        &tolerance,   &pairs.p, &shapes.p,
                &transforms.p, &bounds.p, &distances.p, &rest.p,  &materials.p,
                &starts.p,     &total.p,  &systems.p,   &remap.p, &writer};
            cudaGraph_t graph;
            cudaGraphExec_t executable;
            check(cudaStreamBeginCapture(stream,
                                         cudaStreamCaptureModeThreadLocal));
            driver(cuLaunchKernel(ordinary, grid, 1, 1,
                                  PxgParticleSystemKernelBlockDim::PS_COLLISION,
                                  1, 1, 0, (CUstream)stream, args, nullptr));
            driver(cuLaunchKernel(diffuse, grid, 1, 1,
                                  PxgParticleSystemKernelBlockDim::PS_COLLISION,
                                  1, 1, 0, (CUstream)stream, args, nullptr));
            check(cudaStreamEndCapture(stream, &graph));
            check(
                cudaGraphInstantiate(&executable, graph, nullptr, nullptr, 0));
            for (unsigned replay = 0; replay < 3; ++replay)
              check(cudaGraphLaunch(executable, stream));
            auto counts = counters.get(stream),
                 dcounts = diffuseCounts.get(stream);
            require(counts[0] == 0xa5a5a5a5u && counts[2] == 0xa5a5a5a5u &&
                        counts[1] == expectedCount,
                    "ordinary exactly-once count/guards");
            require(dcounts[0] == 0xa5a5a5a5u && dcounts[2] == 0xa5a5a5a5u &&
                        dcounts[1] == expectedCount,
                    "diffuse exactly-once count/guards");
            auto results = contacts.get(stream);
            auto keys = particleKeys.get(stream);
            auto pt = particleTemp.get(stream);
            auto po = particleOrder.get(stream);
            auto rk = rigidKeys.get(stream);
            auto rt = rigidTemp.get(stream);
            auto ro = rigidOrder.get(stream);
            std::vector<unsigned> ordinaryMultiplicity(maxTests), diffuseMultiplicity(maxTests);
            const auto checkContact = [&](float x, float y, float z, float w) {
              unsigned identity = 0;
              if (mode == 3) {
                const float encoded = (0.125f - w) * 4096.0f;
                require(std::isfinite(encoded) && encoded >= -0.5f &&
                            encoded < float(n) - 0.5f,
                        "contact identity outside authored work domain");
                identity = static_cast<unsigned>(std::lround(encoded));
                require(identity < n && live[identity], "contact from an inactive work item");
              }
              require(contact(x, y, z, w, 0.125f - (mode == 3 ? hostRest[identity] : 0.0f)),
                      "contact normal/distance differs from plane equation");
              return identity;
            };
            for (unsigned i = 0; i < capacity + 2; ++i) {
              if (i > 0 && i <= expectedCount) {
                auto &c = results[i];
                const unsigned identity = checkContact(c.normal_pen.x, c.normal_pen.y,
                                                        c.normal_pen.z, c.normal_pen.w);
                ++ordinaryMultiplicity[identity];
                require(c.rigidId == hostRemap[1].getInd() && c.particleId == 0,
                        "ordinary contact ownership");
                require(keys[i] == 0 && pt[i] == 0 && po[i] == i - 1 &&
                            rk[i] == hostRemap[1] && rt[i] == 37 &&
                            ro[i] == i - 1,
                        "ordinary ownership/sort outputs");
              } else {
                require(sentinel(&results[i], sizeof(results[i])) &&
                            sentinel(&keys[i], sizeof(keys[i])) &&
                            sentinel(&pt[i], sizeof(pt[i])) &&
                            sentinel(&po[i], sizeof(po[i])) &&
                            sentinel(&rk[i], sizeof(rk[i])) &&
                            sentinel(&rt[i], sizeof(rt[i])) &&
                            sentinel(&ro[i], sizeof(ro[i])),
                        "ordinary untouched output guards");
              }
            }
            if (mode == 3)
              for (unsigned i = 0; i < maxTests; ++i)
                require(ordinaryMultiplicity[i] == (i < n && live[i] ? 3u : 0u),
                        "ordinary work item dropped or repeated across three replays");
            auto di = dinfo.get(stream);
            auto impulses = dimpulse.get(stream);
            auto nodes = dnodes.get(stream);
            for (unsigned i = 0; i < dcap + 2; ++i) {
              if (i > 0 && i <= std::min(dcap, expectedCount)) {
                auto v = di[i].mNormal_PenW;
                const unsigned identity = checkContact(v.x, v.y, v.z, v.w);
                ++diffuseMultiplicity[identity];
                require(impulses[i] == 0 && nodes[i] == hostRemap[1],
                        "diffuse bounded contact values");
              } else
                require(sentinel(&di[i], sizeof(di[i])) &&
                            sentinel(&impulses[i], sizeof(impulses[i])) &&
                            sentinel(&nodes[i], sizeof(nodes[i])),
                        "diffuse untouched output guards");
            }
            if (mode == 3)
              for (unsigned i = 0; i < maxTests; ++i) {
                // Diffuse publication is capped at 12; scheduling can select
                // any valid subset. Before that cap each work item can appear
                // at most once per replay, while the uncapped count is exact.
                require(diffuseMultiplicity[i] <= (i < n && live[i] ? 3u : 0u),
                        "diffuse inactive or excessively repeated work item");
                if (expectedCount <= dcap)
                  require(diffuseMultiplicity[i] == ordinaryMultiplicity[i],
                          "diffuse work item lost before publication capacity");
              }
            check(cudaGraphExecDestroy(executable));
            check(cudaGraphDestroy(graph));
          }
    check(cudaStreamDestroy(stream));
    driver(cuModuleUnload(module));
    std::puts("PASS: production ordinary/diffuse particle contacts, "
              "dense/sparse/empty/carry cells, partial/full/carry-overflow batches, 1/2 "
              "blocks, PGS/TGS, bounded outputs and three queued replays");
    return 0;
  } catch (const std::exception &e) {
    std::fprintf(stderr, "particle tails: %s\n", e.what());
    return 1;
  }
}
