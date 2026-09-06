// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
// Standalone diagnostic: no PhysX or Blast code or headers are linked.
#include <cuda.h>
#include <cuda_runtime.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <stdexcept>

static void check(cudaError_t result, const char* operation)
{
    if (result == cudaSuccess) return;
    std::fprintf(stderr, "%s: %s (%d)\n", operation, cudaGetErrorString(result), int(result));
    throw std::runtime_error("CUDA runtime operation failed");
}
static void driver(CUresult result, const char* operation)
{
    if (result == CUDA_SUCCESS) return;
    const char* message = nullptr;
    cuGetErrorString(result, &message);
    std::fprintf(stderr, "%s: %s (%d)\n", operation, message ? message : "unknown", int(result));
    throw std::runtime_error("CUDA driver operation failed");
}
#define CUDA_CHECK(call) check(call, #call)
#define DRIVER_CHECK(call) driver(call, #call)

__global__ void setCondition(cudaGraphConditionalHandle handle, unsigned value)
{
    cudaGraphSetConditional(handle, value);
}
__global__ void writeValue(unsigned* output, bool fault)
{
    // --fault is an intentional instrumentation control, never a passing case.
    output[fault ? 1024 : 0] = 42;
}
static cudaGraphNode_t kernel(cudaGraph_t graph, cudaGraphNode_t prior, void* function, void** arguments)
{
    cudaKernelNodeParams params{};
    params.func = function;
    params.gridDim = dim3(1);
    params.blockDim = dim3(1);
    params.kernelParams = arguments;
    cudaGraphNode_t node;
    CUDA_CHECK(cudaGraphAddKernelNode(&node, graph, prior ? &prior : nullptr, prior ? 1 : 0, &params));
    return node;
}
static cudaGraph_t conditional(cudaGraph_t graph, cudaGraphNode_t prior,
    cudaGraphConditionalHandle handle, cudaGraphConditionalNodeType type)
{
    cudaGraphNodeParams params{};
    params.type = cudaGraphNodeTypeConditional;
    params.conditional.handle = handle;
    params.conditional.type = type;
    params.conditional.size = 1;
    cudaGraphNode_t node;
    CUDA_CHECK(cudaGraphAddNode(&node, graph, prior ? &prior : nullptr, prior ? 1 : 0, &params));
    return params.conditional.phGraph_out[0];
}
static void run(const char* mode, bool fault)
{
    cudaStream_t stream;
    CUDA_CHECK(cudaStreamCreateWithFlags(&stream, cudaStreamNonBlocking));
    unsigned* output;
    CUDA_CHECK(cudaMalloc(&output, sizeof(unsigned)));
    cudaGraph_t graph = nullptr;
    cudaGraphExec_t executable = nullptr;
    const bool direct = !std::strcmp(mode, "direct");
    if (!direct)
    {
        CUDA_CHECK(cudaGraphCreate(&graph, 0));
        cudaGraph_t body = graph;
        cudaGraphConditionalHandle a = 0, b = 0;
        unsigned one = 1, zero = 0;
        const bool loop = !std::strcmp(mode, "while");
        if (std::strcmp(mode, "graph"))
        {
            CUDA_CHECK(cudaGraphConditionalHandleCreate(&a, graph, 0, cudaGraphCondAssignDefault));
            void* args[] = {&a, &one};
            auto prior = kernel(graph, nullptr, (void*)setCondition, args);
            body = conditional(graph, prior, a, loop ? cudaGraphCondTypeWhile : cudaGraphCondTypeIf);
            if (!std::strcmp(mode, "nested"))
            {
                CUDA_CHECK(cudaGraphConditionalHandleCreate(&b, graph, 0, cudaGraphCondAssignDefault));
                void* innerArgs[] = {&b, &one};
                prior = kernel(body, nullptr, (void*)setCondition, innerArgs);
                body = conditional(body, prior, b, cudaGraphCondTypeIf);
            }
        }
        void* args[] = {&output, &fault};
        auto prior = kernel(body, nullptr, (void*)writeValue, args);
        if (loop)
        {
            void* endArgs[] = {&a, &zero};
            kernel(body, prior, (void*)setCondition, endArgs);
        }
        CUDA_CHECK(cudaGraphInstantiate(&executable, graph, 0));
    }
    for (unsigned launch = 0; launch < 3; ++launch)
    {
        CUDA_CHECK(cudaMemsetAsync(output, 0, sizeof(unsigned), stream));
        if (direct)
        {
            writeValue<<<1, 1, 0, stream>>>(output, fault);
            CUDA_CHECK(cudaGetLastError());
        }
        else CUDA_CHECK(cudaGraphLaunch(executable, stream));
        CUDA_CHECK(cudaStreamSynchronize(stream));
        unsigned observed = 0;
        CUDA_CHECK(cudaMemcpy(&observed, output, sizeof(observed), cudaMemcpyDeviceToHost));
        if (observed != 42) throw std::runtime_error("valid output was not written");
    }
    if (executable) CUDA_CHECK(cudaGraphExecDestroy(executable));
    if (graph) CUDA_CHECK(cudaGraphDestroy(graph));
    CUDA_CHECK(cudaFree(output));
    CUDA_CHECK(cudaStreamDestroy(stream));
}
int main(int argc, char** argv)
{
    try
    {
        const char* mode = argc > 1 ? argv[1] : "nested";
        if (std::strcmp(mode,"direct") && std::strcmp(mode,"graph") && std::strcmp(mode,"if")
            && std::strcmp(mode,"nested") && std::strcmp(mode,"while"))
            throw std::runtime_error("mode must be direct, graph, if, nested, or while");
        char* end = nullptr;
        const unsigned long count = argc > 2 ? std::strtoul(argv[2], &end, 10) : 256;
        if (!count || count > 100000 || (end && *end)) throw std::runtime_error("invalid iteration count");
        bool reuse = false, fault = false;
        for (int i = 3; i < argc; ++i)
        {
            if (!std::strcmp(argv[i], "--reuse-context")) reuse = true;
            else if (!std::strcmp(argv[i], "--fault")) fault = true;
            else throw std::runtime_error("unknown option");
        }
        DRIVER_CHECK(cuInit(0));
        CUdevice device;
        DRIVER_CHECK(cuDeviceGet(&device, 0));
        CUcontext context = nullptr;
        for (unsigned long i = 0; i < count; ++i)
        {
            if (!context) DRIVER_CHECK(cuCtxCreate(&context, 0, device));
            run(mode, fault);
            if (!reuse || i + 1 == count)
            {
                DRIVER_CHECK(cuCtxDestroy(context));
                context = nullptr;
            }
            std::printf("mode=%s reuse=%u iteration=%lu passed\n", mode, unsigned(reuse), i);
            std::fflush(stdout);
        }
        std::printf("PASS: %lu iterations, %lu checked writes\n", count, count * 3);
        return 0;
    }
    catch (const std::exception& error)
    {
        std::fprintf(stderr, "%s\n", error.what());
        return 1;
    }
}
