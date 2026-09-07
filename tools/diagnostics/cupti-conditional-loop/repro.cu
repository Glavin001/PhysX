// Isolate repeated conditional-kernel activity tracing from PhysX and Blast.
#include "../../../demos/blast-stress-demo/native_gpu_activity.h"
#include <cuda_runtime.h>
#include <cuda.h>
#include <cupti_activity.h>
#include <cstdio>
#include <cstdlib>
#include <stdexcept>
static int step=-1;
static void check(cudaError_t e,const char* s){if(e!=cudaSuccess){std::fprintf(stderr,"step=%d %s: %s (%d)\n",step,s,cudaGetErrorString(e),int(e));throw std::runtime_error(s);}}
#define C(x) check((x),#x)
__global__ void init(int* v){v[0]=0;v[1]=0;}
__global__ void add(int* v){v[0]+=1;}
__global__ void next(int* v,cudaGraphConditionalHandle h){cudaGraphSetConditional(h,++v[1]<256);}
static cudaGraphNode_t node(cudaGraph_t g,cudaGraphNode_t prev,void* fun,void** args){
 cudaKernelNodeParams p{};p.func=fun;p.gridDim=p.blockDim=dim3(1);p.kernelParams=args;cudaGraphNode_t n;
 C(cudaGraphAddKernelNode(&n,g,prev?&prev:nullptr,prev?1:0,&p));return n;
}
int main(int argc,char**argv){try{
 if(argc!=4)return 2;
 const unsigned steps=std::strtoul(argv[2],nullptr,10),bufferMiB=std::strtoul(argv[3],nullptr,10);
 if(!steps || steps>100000 || bufferMiB<16 || bufferMiB>4096)return 2;
 blast_demo::NativeGpuActivity trace(argv[1],uint64_t(bufferMiB)*1024*1024);
 int* v;C(cudaMalloc(&v,2*sizeof(int)));cudaStream_t s;C(cudaStreamCreateWithFlags(&s,cudaStreamNonBlocking));
 cudaGraph_t g;C(cudaGraphCreate(&g,0));void* args[]={&v};auto prev=node(g,nullptr,(void*)init,args);
 cudaGraphConditionalHandle h;C(cudaGraphConditionalHandleCreate(&h,g,1,cudaGraphCondAssignDefault));
 cudaGraphNodeParams p{};p.type=cudaGraphNodeTypeConditional;p.conditional.handle=h;p.conditional.type=cudaGraphCondTypeWhile;p.conditional.size=1;
 cudaGraphNode_t loop;C(cudaGraphAddNode(&loop,g,&prev,1,&p));auto body=p.conditional.phGraph_out[0];prev=nullptr;
 for(int i=0;i<4;++i)prev=node(body,prev,(void*)add,args);
 void* finish[]={&v,&h};node(body,prev,(void*)next,finish);
 cudaGraphExec_t exec;C(cudaGraphInstantiate(&exec,g,0));
 for(step=0;step<int(steps);++step){C(cudaGraphLaunch(exec,s));int result[2];C(cudaMemcpyAsync(result,v,sizeof(result),cudaMemcpyDeviceToHost,s));C(cudaStreamSynchronize(s));if(result[0]!=1024 || result[1]!=256)throw std::runtime_error("wrong arithmetic result");if(step%100==0)std::printf("step %d correct\n",step);}
 C(cudaGraphExecDestroy(exec));C(cudaGraphDestroy(g));C(cudaFree(v));C(cudaStreamDestroy(s));std::printf("%u conditional graph executions correct; expected kernels=%llu\n",steps,1281ull*steps);trace.finish();
 return 0;
}catch(const std::exception&e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
