// SPDX-License-Identifier: BSD-3-Clause
// Standalone diagnostic: no PhysX/Blast code, allocation nodes, or stream capture.
#include <cuda_runtime.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>

static int currentStep = -1;
static void check(cudaError_t error, const char* operation)
{
    if (error != cudaSuccess)
    {
        std::fprintf(stderr, "step=%d %s: %s\n", currentStep, operation, cudaGetErrorString(error));
        std::exit(1);
    }
}

__global__ void initialize(int* value) { *value = 0; }
__global__ void add(int* value, int parameter) { *value += parameter; }
__global__ void stop(cudaGraphConditionalHandle handle) { cudaGraphSetConditional(handle, 0); }
__global__ void after(int* value) { *value += 1; }

enum Mode { Plain, If, While };

static void kernel(cudaGraph_t graph, cudaGraphNode_t& previous, void* function, void** args)
{
    cudaKernelNodeParams p{};
    p.func = function;
    p.gridDim = p.blockDim = dim3(1);
    p.kernelParams = args;
    cudaGraphNode_t next;
    check(cudaGraphAddKernelNode(&next, graph, previous ? &previous : nullptr,
                                previous ? 1 : 0, &p), "add kernel");
    previous = next;
}

static cudaGraph_t makeGraph(Mode mode, int* value, int parameter)
{
    cudaGraph_t graph;
    check(cudaGraphCreate(&graph, 0), "create graph");
    cudaGraphNode_t previous = nullptr;
    void* valueArgs[] = {&value};
    kernel(graph, previous, (void*)initialize, valueArgs);

    cudaGraph_t body = graph;
    cudaGraphNode_t bodyPrevious = previous;
    cudaGraphConditionalHandle handle = 0;
    if (mode != Plain)
    {
        check(cudaGraphConditionalHandleCreate(&handle, graph, 1, cudaGraphCondAssignDefault), "create handle");
        cudaGraphNodeParams p{};
        p.type = cudaGraphNodeTypeConditional;
        p.conditional.handle = handle;
        p.conditional.type = mode == If ? cudaGraphCondTypeIf : cudaGraphCondTypeWhile;
        p.conditional.size = 1;
        cudaGraphNode_t conditional;
        check(cudaGraphAddNode(&conditional, graph, &previous, 1, &p), "add conditional");
        previous = conditional;
        body = p.conditional.phGraph_out[0];
        bodyPrevious = nullptr;
    }
    void* args[] = {&value, &parameter};
    for (int i = 0; i < 4; ++i)
        kernel(body, bodyPrevious, (void*)add, args);
    if (mode == While)
    {
        void* stopArgs[] = {&handle};
        kernel(body, bodyPrevious, (void*)stop, stopArgs);
    }
    if (mode == Plain)
        previous = bodyPrevious;
    kernel(graph, previous, (void*)after, valueArgs);
    return graph;
}

int main(int argc, char** argv)
{
    if (argc != 2 || (std::strcmp(argv[1], "plain") && std::strcmp(argv[1], "if") && std::strcmp(argv[1], "while")))
    {
        std::fprintf(stderr, "Usage: %s plain|if|while\n", argv[0]);
        return 2;
    }
    const Mode mode = !std::strcmp(argv[1], "plain") ? Plain : (!std::strcmp(argv[1], "if") ? If : While);
    int* value;
    check(cudaMalloc(&value, sizeof(int)), "allocate");
    cudaStream_t stream;
    check(cudaStreamCreateWithFlags(&stream, cudaStreamNonBlocking), "create stream");
    cudaGraph_t graph = nullptr;
    cudaGraphExec_t exec = nullptr;
    unsigned updates = 0, recreates = 0;
    for (int step = 0; step < 500; ++step)
    {
        currentStep = step;
        auto fresh = makeGraph(mode, value, step + 1);
        if (exec)
        {
            cudaGraphExecUpdateResultInfo info{};
            const auto result = cudaGraphExecUpdate(exec, fresh, &info);
            if (result == cudaSuccess && info.result == cudaGraphExecUpdateSuccess)
                ++updates;
            else
            {
                check(result, "update API");
                check(cudaGraphExecDestroy(exec), "destroy exec after incompatible update");
                exec = nullptr;
                ++recreates;
            }
            check(cudaGraphDestroy(graph), "destroy old graph");
        }
        graph = fresh;
        if (!exec)
            check(cudaGraphInstantiate(&exec, graph, 0), "instantiate");
        check(cudaGraphLaunch(exec, stream), "launch");
        int observed;
        check(cudaMemcpyAsync(&observed, value, sizeof(int), cudaMemcpyDeviceToHost, stream), "observe");
        check(cudaStreamSynchronize(stream), "wait");
        if (observed != 4 * (step + 1) + 1)
        {
            std::fprintf(stderr, "step=%d observed=%d expected=%d\n", step, observed, 4 * (step + 1) + 1);
            return 3;
        }
    }
    check(cudaGraphExecDestroy(exec), "destroy exec");
    check(cudaGraphDestroy(graph), "destroy graph");
    check(cudaFree(value), "free");
    check(cudaStreamDestroy(stream), "destroy stream");
    std::printf("mode=%s: 500 correct executions; updates=%u recreates=%u\n", argv[1], updates, recreates);
}
