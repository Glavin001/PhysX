// Run the shared PhysX GJK/EPA equations; the host invocation is the oracle.
#include <cuda_runtime.h>
#include "foundation/PxMathUtils.h"
#include "GuRefGjkEpa.h"
#include <cmath>
#include <cstdio>
using namespace physx;
struct BoxSupport {
    float x, y, z;
    PX_CUDA_CALLABLE PxVec3 supportLocal(const PxVec3& direction) const {
        return PxVec3(direction.x >= 0 ? x : -x, direction.y >= 0 ? y : -y, direction.z >= 0 ? z : -z);
    }
};
struct Input { BoxSupport a, b; PxTransform poseA, poseB; };
struct Output { float gjkDistance, distance; PxVec3 a, b, axis; };
// Keep the barrier-free solver in its own helper, as in the production contact path.
PX_CUDA_CALLABLE PX_NOINLINE Output evaluate(const BoxSupport& a, const BoxSupport& b, const PxTransform& pa, const PxTransform& pb) {
    Output result{};
    result.distance = Gu::RefGjkEpa::computeGjkDistance(a, b, pa, pb, 100.0f, result.a, result.b, result.axis);
    result.gjkDistance = result.distance;
    if (result.distance == 0)
        result.distance = Gu::RefGjkEpa::computeEpaDepth(a, b, pa, pb, result.a, result.b, result.axis);
    return result;
}
__global__ void reference_contacts(const Input* input, Output* output) {
    const unsigned i = threadIdx.x;
    __shared__ BoxSupport sharedA[4], sharedB[4];
    BoxSupport localA = input[i].a, localB = input[i].b;
    PxTransform poseA = input[i].poseA, poseB = input[i].poseB;
    sharedA[i] = localA; sharedB[i] = localB;
    __syncthreads();
    output[i * 2] = evaluate(sharedA[i], localB, poseA, poseB);
    output[i * 2 + 1] = evaluate(localA, sharedB[i], poseA, poseB);
}
static bool near(float a, float b) { return std::isfinite(a) && std::isfinite(b) && std::fabs(a - b) <= 1e-4f; }
static bool near(const PxVec3& a, const PxVec3& b) { return near(a.x, b.x) && near(a.y, b.y) && near(a.z, b.z); }
int main() {
    Input input[4]; Output expected[4], output[8];
    const float separation[4] = {3.0f, 1.5f, 4.25f, 0.7f};
    for (unsigned i = 0; i < 4; ++i) {
        input[i].a = {1, 1, 1}; input[i].b = {1, 1, 1};
        input[i].poseA = PxTransform(PxIdentity); input[i].poseB = PxTransform(PxVec3(separation[i], 0, 0));
        if (i >= 2) input[i].poseB.q = PxQuat(0, 0, 0.2588190451f, 0.9659258263f);
        expected[i] = evaluate(input[i].a, input[i].b, input[i].poseA, input[i].poseB);
        if (!std::isfinite(expected[i].distance) || std::fabs(expected[i].distance) > 10) return 1;
    }
    if (!near(expected[0].distance, 1.0f) || !near(std::fabs(expected[1].distance), 0.5f)) return 2;
    Input* deviceInput; Output* deviceOutput; cudaStream_t stream;
    if (cudaStreamCreate(&stream) || cudaMalloc(&deviceInput, sizeof(input)) || cudaMalloc(&deviceOutput, sizeof(output))) return 3;
    if (cudaMemcpyAsync(deviceInput, input, sizeof(input), cudaMemcpyHostToDevice, stream)) return 4;
    if (cudaStreamBeginCapture(stream, cudaStreamCaptureModeThreadLocal)) return 5;
    reference_contacts<<<1, 4, 0, stream>>>(deviceInput, deviceOutput);
    cudaGraph_t graph; cudaGraphExec_t executable;
    if (cudaStreamEndCapture(stream, &graph) || cudaGraphInstantiate(&executable, graph, nullptr, nullptr, 0)) return 6;
    for (int replay = 0; replay < 3; ++replay) {
        if (cudaGraphLaunch(executable, stream) || cudaMemcpyAsync(output, deviceOutput, sizeof(output), cudaMemcpyDeviceToHost, stream) || cudaStreamSynchronize(stream)) return 7;
        for (unsigned i = 0; i < 8; ++i) {
            const auto& want = expected[i / 2]; const auto& got = output[i];
            if (!near(got.gjkDistance, want.gjkDistance) || !near(got.distance, want.distance) || !near(got.a, want.a) || !near(got.b, want.b) || !near(got.axis, want.axis)) {
                std::fprintf(stderr, "GJK/EPA mismatch replay %d case %u: distance %.9g expected %.9g; GJK %.9g expected %.9g; pointA (%g,%g,%g) axis (%g,%g,%g)\n", replay, i, got.distance, want.distance, got.gjkDistance, want.gjkDistance, got.a.x, got.a.y, got.a.z, got.axis.x, got.axis.y, got.axis.z); return 8;
            }
        }
    }
    if (cudaGraphExecDestroy(executable) || cudaGraphDestroy(graph) || cudaFree(deviceInput) || cudaFree(deviceOutput) || cudaStreamDestroy(stream)) return 9;
    std::puts("PASS: shared PhysX GJK/EPA separation/penetration/rotated boxes, points/normals, shared/private references and graph replay at 1e-4 tolerance");
}
