#include "NvBlastExtStressGpu.h"
#include <cuda_runtime.h>

#include <cmath>
#include <cstdio>
#include <memory>
#include <stdexcept>
#include <vector>

using namespace Nv::Blast;
namespace
{
void require(bool value, const char* message)
{
    if (!value) { throw std::runtime_error(message); }
}
void check(cudaError_t result)
{
    if (result != cudaSuccess) { throw std::runtime_error(cudaGetErrorString(result)); }
}
struct Release { void operator()(ExtStressGpuSolver* p) const { if (p) p->release(); } };
using Solver = std::unique_ptr<ExtStressGpuSolver, Release>;
constexpr unsigned count = 12;
__host__ __device__ ExtStressGpuImpulse load(unsigned i, unsigned revision)
{
    // Three independent columns, the last unanchored. Change only the middle
    // island so the test detects accidental invalidation of unrelated islands.
    const float change = (i / 4 == 1) ? float(revision) : 0.0f;
    return {{0.125f * float(i % 3), 0.0f, 0.25f},
        {0.5f + change, -2.0f * float(i % 4), 0.25f}};
}
__global__ void produce(ExtStressGpuImpulse* output, unsigned revision)
{
    // An intentionally delayed producer in a nonblocking stream makes the
    // event dependency observable. No host upload supplies the input values.
    const auto start = clock64();
    while (clock64() - start < 2000000ull) {}
    const unsigned i = threadIdx.x;
    if (i < count) { output[i] = load(i, revision); }
}
struct Producer
{
    cudaStream_t stream{};
    cudaEvent_t ready{};
    ExtStressGpuImpulse* values{};
    Producer()
    {
        check(cudaStreamCreateWithFlags(&stream, cudaStreamNonBlocking));
        check(cudaEventCreateWithFlags(&ready, cudaEventDisableTiming));
        check(cudaMalloc(&values, count * sizeof(*values)));
        check(cudaMemset(values, 0, count * sizeof(*values)));
    }
    ~Producer()
    {
        cudaStreamSynchronize(stream);
        cudaFree(values); cudaEventDestroy(ready); cudaStreamDestroy(stream);
    }
    void submit(unsigned revision)
    {
        produce<<<1, 32, 0, stream>>>(values, revision);
        check(cudaGetLastError());
        check(cudaEventRecord(ready, stream));
    }
};
void compare(ExtStressGpuSolver& a, ExtStressGpuSolver& b, const char* phase, bool asynchronous = false)
{
    require(a.bondCount() == b.bondCount(), "bond count differs");
    std::vector<ExtStressGpuImpulse> expected(a.bondCount()), actual(a.bondCount());
    require(a.readbackImpulses(expected.data(), expected.size()), "reference readback failed");
    if (asynchronous)
    {
        const auto view = b.deviceView();
        require(view.bondCount == actual.size() && view.bondImpulses && view.readyEvent,
            "invalid asynchronous device view");
        cudaStream_t observer; cudaEvent_t consumed;
        check(cudaStreamCreateWithFlags(&observer, cudaStreamNonBlocking));
        check(cudaEventCreateWithFlags(&consumed, cudaEventDisableTiming));
        check(cudaStreamWaitEvent(observer, reinterpret_cast<cudaEvent_t>(view.readyEvent), 0));
        check(cudaMemcpyAsync(actual.data(), view.bondImpulses, actual.size()*sizeof(actual[0]),
            cudaMemcpyDeviceToHost, observer));
        check(cudaEventRecord(consumed, observer));
        check(cudaEventSynchronize(consumed));
        check(cudaEventDestroy(consumed)); check(cudaStreamDestroy(observer));
    }
    else require(b.readbackImpulses(actual.data(), actual.size()), "device readback failed");
    float peak = 0.0f, error = 0.0f;
    for (unsigned i = 0; i < expected.size(); ++i)
    {
        const auto& a = expected[i]; const auto& b = actual[i];
        const float av[] = {a.angular.x,a.angular.y,a.angular.z,a.linear.x,a.linear.y,a.linear.z};
        const float bv[] = {b.angular.x,b.angular.y,b.angular.z,b.linear.x,b.linear.y,b.linear.z};
        for (unsigned j = 0; j < 6; ++j)
        {
            require(std::isfinite(av[j]) && std::isfinite(bv[j]), "nonfinite impulse");
            peak = fmaxf(peak, fabsf(av[j]));
            error = fmaxf(error, fabsf(av[j] - bv[j]) / fmaxf(1.0f, fabsf(av[j])));
        }
    }
    std::printf("%s: peak=%g maxRelative=%g\n", phase, peak, error);
    require(peak > 0.1f, "reference fixture must carry stress");
    require(error < 2e-4f, "host/device input solutions differ");
}
}
int main()
{
    try
    {
        std::vector<ExtStressGpuNode> nodes(count);
        std::vector<ExtStressGpuBond> bonds;
        for (unsigned i = 0; i < count; ++i)
        {
            const bool fixed = i == 0 || i == 4;
            nodes[i] = {{float(i / 4) * 10.0f, float(i % 4), 0.0f},
                fixed ? 0.0f : 1.0f, fixed ? 0.0f : 0.5f};
            if (i % 4)
            {
                ExtStressGpuBond b{};
                b.node0 = i - 1; b.node1 = i;
                b.centroid[0] = nodes[i].position[0];
                b.centroid[1] = nodes[i].position[1] - 0.5f;
                b.normal[1] = 1.0f;
                bonds.push_back(b);
            }
        }
        Solver host(ExtStressGpuSolver::create(nodes.data(), count, bonds.data(), bonds.size()));
        Solver device(ExtStressGpuSolver::create(nodes.data(), count, bonds.data(), bonds.size()));
        require(host && device, "solver creation failed");
        Producer producer;
        ExtStressGpuSolveParams params;
        params.maxIterations = 128;
        params.tolerance = 1e-5f;
        params.skipSettledIslands = true;
        require(!device->solveDevice(nullptr, count, params), "null input accepted");
        require(!device->solveDevice(producer.values, count-1, params), "wrong count accepted");
        auto run = [&](unsigned revision, bool useDevice, const char* phase)
        {
            std::vector<ExtStressGpuImpulse> inputs(count);
            for (unsigned i = 0; i < count; ++i) { inputs[i] = load(i, revision); }
            require(host->solve(inputs.data(), params), "host solve failed");
            if (useDevice)
            {
                producer.submit(revision);
                require(device->solveDevice(producer.values, count, params, producer.ready), "device solve failed");
                const auto& stats = device->telemetry();
                require(stats.deviceToDeviceBytes == count*sizeof(ExtStressGpuImpulse), "missing device input copy");
                require(stats.hostToDeviceBytes <= stats.islandCount*sizeof(unsigned), "device loads crossed host bus");
                // Mutate immediately on return: solver owns its snapshot and
                // cannot alias the producer buffer during the next solve.
                check(cudaMemset(producer.values, 0, count*sizeof(ExtStressGpuImpulse)));
            }
            else { require(device->solve(inputs.data(), params), "switch to host failed"); }
            compare(*host, *device, phase);
        };
        run(0, true, "cold device producer");
        run(0, true, "warm device producer");
        run(0, true, "settled device producer");
        require(device->telemetry().islandsSkipped == device->telemetry().islandCount,
            "unchanged converged islands were not skipped");
        run(2, true, "changed middle island");
        require(device->telemetry().islandsSkipped == 2, "unrelated islands were not preserved");
        run(2, false, "device to host");
        run(2, true, "host to device");
        require(host->removeBond(4) && device->removeBond(4), "bond removal failed");
        run(2, true, "topology invalidates settled inputs");
        params.warmStart = false;
        run(1, true, "cold restart after removal");
        params.skipSettledIslands = false;
        require(device->prepareDeviceSolve(), "resident preparation failed");
        for (unsigned revision : {0u, 0u, 3u, 1u})
        {
            std::vector<ExtStressGpuImpulse> inputs(count);
            for (unsigned i=0; i<count; ++i) inputs[i]=load(i, revision);
            producer.submit(revision);
            require(device->solveDeviceAsync(producer.values, count, params, producer.ready),
                "asynchronous solve failed");
            const auto& telemetry = device->telemetry();
            require(telemetry.hostToDeviceBytes == 0 && telemetry.deviceToHostBytes == 0,
                "asynchronous stress solve transferred host data");
            require(host->solve(inputs.data(), params), "async reference solve failed");
            compare(*host, *device, "event-ordered resident forces", true);
            params.warmStart = true;
        }
        auto rejected=params; rejected.applyDamage=true;
        require(!device->solveDeviceAsync(producer.values,count,rejected), "async damage silently accepted");
        rejected=params; rejected.skipSettledIslands=true;
        require(!device->solveDeviceAsync(producer.values,count,rejected), "host scheduling silently accepted");
        require(device->removeBond(0) && host->removeBond(0), "async topology removal failed");
        require(!device->solveDeviceAsync(producer.values,count,params), "dirty topology silently accepted");
        require(device->prepareDeviceSolve(), "changed resident graph preparation failed");
        producer.submit(2);
        require(device->solveDeviceAsync(producer.values,count,params,producer.ready), "changed async graph failed");
        std::vector<ExtStressGpuImpulse> inputs(count);
        for(unsigned i=0;i<count;++i) inputs[i]=load(i,2);
        require(host->solve(inputs.data(),params), "changed reference graph failed");
        compare(*host,*device,"resident topology refresh",true);
        run(1, false, "async to CPU-input compatibility");
        // A long quiet interval must not certify a subsequent changed load.
        ExtStressGpuNode quietNodes[2]={{{0,-1,0},0,0},{{0,0,0},2,1}};
        ExtStressGpuBond quietBond{};quietBond.node0=0;quietBond.node1=1;quietBond.centroid[1]=-0.5f;
        Solver quietHost(ExtStressGpuSolver::create(quietNodes,2,&quietBond,1));
        Solver quietDevice(ExtStressGpuSolver::create(quietNodes,2,&quietBond,1));
        require(quietDevice->prepareDeviceSolve(),"quiet graph preparation failed");
        for(unsigned tick=0;tick<34;++tick) {
            ExtStressGpuImpulse quietInputs[2]{};
            if(tick==6) quietInputs[1].linear={100,10,20};
            if(tick==33) quietInputs[1].linear={-3.36383f,-9.21525f,0};
            check(cudaMemcpy(producer.values,quietInputs,sizeof(quietInputs),cudaMemcpyHostToDevice));
            require(quietDevice->solveDeviceAsync(producer.values,2,params),"quiet async solve failed");
            require(quietHost->solve(quietInputs,params),"quiet host solve failed");
            if(tick==33)compare(*quietHost,*quietDevice,"gravity after quiet interval",true);
        }
        std::puts("device input regression passed");
        return 0;
    }
    catch (const std::exception& e) { std::fprintf(stderr, "%s\n", e.what()); return 1; }
}
