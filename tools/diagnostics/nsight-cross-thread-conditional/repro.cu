// SPDX-License-Identifier: BSD-3-Clause
// Conditional graph created and launched on different, sequential CPU threads.
// No PhysX, Blast, CUB, cooperative kernel, capture, or dynamic library required.
#include <cuda.h>
#include <cuda_runtime.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <thread>

#define CUDA(call) do { const auto e=(call); if(e!=cudaSuccess) { \
    std::fprintf(stderr,"%s: %s\n",#call,cudaGetErrorString(e)); std::exit(2); } } while(0)
#define DRIVER(call) do { const auto e=(call); if(e!=CUDA_SUCCESS) { \
    const char* name=nullptr; cuGetErrorName(e,&name); \
    std::fprintf(stderr,"%s: %s\n",#call,name?name:"unknown"); std::exit(2); } } while(0)

__global__ void setCondition(const unsigned* input,cudaGraphConditionalHandle handle) {
    cudaGraphSetConditional(handle,*input);
}
__global__ void conditionalBody(unsigned* output) { ++*output; }

struct Graph {
    cudaStream_t stream{};
    cudaGraph_t graph{};
    cudaGraphExec_t executable{};
    unsigned *input{},*output{};
    void create() {
        CUDA(cudaStreamCreateWithFlags(&stream,cudaStreamNonBlocking));
        CUDA(cudaMalloc(&input,sizeof(unsigned)));CUDA(cudaMalloc(&output,sizeof(unsigned)));
        CUDA(cudaGraphCreate(&graph,0));
        cudaGraphConditionalHandle handle;
        CUDA(cudaGraphConditionalHandleCreate(&handle,graph,0,cudaGraphCondAssignDefault));
        void* args[]={&input,&handle};cudaKernelNodeParams kernel{};
        kernel.func=reinterpret_cast<void*>(setCondition);
        kernel.gridDim=kernel.blockDim=dim3(1);kernel.kernelParams=args;
        cudaGraphNode_t start;
        CUDA(cudaGraphAddKernelNode(&start,graph,nullptr,0,&kernel));
        cudaGraphNodeParams condition{};condition.type=cudaGraphNodeTypeConditional;
        condition.conditional.handle=handle;condition.conditional.type=cudaGraphCondTypeIf;
        condition.conditional.size=1;cudaGraphNode_t branch;
        CUDA(cudaGraphAddNode(&branch,graph,&start,nullptr,1,&condition));
        void* bodyArgs[]={&output};kernel.func=reinterpret_cast<void*>(conditionalBody);
        kernel.kernelParams=bodyArgs;cudaGraphNode_t body;
        CUDA(cudaGraphAddKernelNode(&body,condition.conditional.phGraph_out[0],nullptr,0,&kernel));
    }
    void upload() {CUDA(cudaGraphUpload(executable,stream));CUDA(cudaStreamSynchronize(stream));}
    void instantiate(bool withUpload=true) {CUDA(cudaGraphInstantiate(&executable,graph,0));if(withUpload)upload();}
    unsigned run() {
        unsigned errors=0;
        for(unsigned i=0;i<8;++i) {
            const unsigned value=i%2;unsigned result=0;
            CUDA(cudaMemcpyAsync(input,&value,sizeof(value),cudaMemcpyHostToDevice,stream));
            CUDA(cudaMemsetAsync(output,0,sizeof(unsigned),stream));
            CUDA(cudaGraphLaunch(executable,stream));
            CUDA(cudaMemcpyAsync(&result,output,sizeof(result),cudaMemcpyDeviceToHost,stream));
            CUDA(cudaStreamSynchronize(stream));
            std::printf("input=%u body=%u expected=%u\n",value,result,value);
            errors+=result!=value;
        }
        return errors;
    }
    void destroy() {
        CUDA(cudaGraphExecDestroy(executable));CUDA(cudaGraphDestroy(graph));
        CUDA(cudaFree(input));CUDA(cudaFree(output));CUDA(cudaStreamDestroy(stream));
    }
};

int main(int argc,char**argv) {
    if(argc!=2 || (std::strcmp(argv[1],"same") && std::strcmp(argv[1],"cross") &&
        std::strcmp(argv[1],"instantiate-worker") && std::strcmp(argv[1],"worker") &&
        std::strcmp(argv[1],"upload-worker") && std::strcmp(argv[1],"reupload-worker"))) {
        std::fprintf(stderr,"Usage: %s same|cross|instantiate-worker|worker|upload-worker|reupload-worker\n",argv[0]);return 2;
    }
    const bool workerCreate=!std::strcmp(argv[1],"worker");
    const bool workerInstantiate=workerCreate || !std::strcmp(argv[1],"instantiate-worker");
    const bool workerUpload=!std::strcmp(argv[1],"upload-worker") || !std::strcmp(argv[1],"reupload-worker");
    const bool workerLaunch=std::strcmp(argv[1],"same")!=0;
    DRIVER(cuInit(0));CUcontext context;
    DRIVER(cuCtxCreate(&context,nullptr,CU_CTX_SCHED_BLOCKING_SYNC|CU_CTX_MAP_HOST,0));
    Graph graph;unsigned errors=0;
    if(!workerCreate)graph.create();
    if(!workerInstantiate)graph.instantiate(std::strcmp(argv[1],"upload-worker")!=0);
    auto launch=[&] {
        if(workerCreate)graph.create();
        if(workerInstantiate)graph.instantiate();
        if(workerUpload)graph.upload();
        errors=graph.run();
    };
    if(workerLaunch) {
        // Graph creation/instantiation are complete before the worker starts.
        // Both threads use the same explicitly pushed CUDA context. There is no
        // concurrent access to graph objects, and join precedes their teardown.
        std::thread worker([&] {
            DRIVER(cuCtxPushCurrent(context));launch();CUcontext popped;
            DRIVER(cuCtxPopCurrent(&popped));
        });worker.join();
    } else launch();
    graph.destroy();DRIVER(cuCtxDestroy(context));
    std::printf("mode=%s errors=%u\n",argv[1],errors);return errors?1:0;
}
