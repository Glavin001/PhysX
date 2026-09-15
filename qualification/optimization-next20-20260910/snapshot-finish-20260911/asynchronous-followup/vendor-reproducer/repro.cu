#include <cuda_runtime.h>
#include <cstdio>
#include <cstdlib>
#include <vector>
#define CHECK(x) do{auto e=(x);if(e!=cudaSuccess){fprintf(stderr,"%s: %s\n",#x,cudaGetErrorString(e));return 2;}}while(0)
__global__ void delay(){const unsigned long long begin=clock64();while(clock64()-begin<1000000000ull){}}
__global__ void setFlag(cudaGraphConditionalHandle h){cudaGraphSetConditional(h,1);}
__global__ void reset(unsigned* labels,unsigned n){unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i<n)labels[i]=i;}
__device__ unsigned root(unsigned* labels,unsigned i){unsigned p=atomicAdd(labels+i,0u);while(p!=i){i=p;p=atomicAdd(labels+i,0u);}return i;}
__global__ void connect(const uint2* edges,unsigned m,unsigned* labels){unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=m)return;unsigned a=edges[i].x,b=edges[i].y;for(;;){a=root(labels,a);b=root(labels,b);if(a==b)return;unsigned hi=max(a,b),lo=min(a,b);if(atomicCAS(labels+hi,hi,lo)==hi)return;}}
__global__ void flatten(unsigned* labels,unsigned n){unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i<n)atomicExch(labels+i,root(labels,i));}
int main(int argc,char**argv){
 const unsigned depth=argc>1?atoi(argv[1]):2;const bool delayed=argc>2?atoi(argv[2]):true;const bool hostWait=argc>3?atoi(argv[3]):false;
 const unsigned n=100000,m=200000;std::vector<uint2> edges;
 for(unsigned i=1;i<n;++i)if(i%1000)edges.push_back(make_uint2(i-1,i));
 const unsigned unique=edges.size();while(edges.size()<m)edges.push_back(edges[edges.size()%unique]);
 unsigned* labels=nullptr;uint2* deviceEdges=nullptr;cudaStream_t stream,producer;cudaEvent_t ready;
 CHECK(cudaStreamCreateWithFlags(&stream,cudaStreamNonBlocking));CHECK(cudaStreamCreateWithFlags(&producer,cudaStreamNonBlocking));CHECK(cudaEventCreateWithFlags(&ready,cudaEventDisableTiming));
 CHECK(cudaMalloc(&labels,n*sizeof(unsigned)));CHECK(cudaMalloc(&deviceEdges,m*sizeof(uint2)));
 CHECK(cudaMemcpy(deviceEdges,edges.data(),m*sizeof(uint2),cudaMemcpyHostToDevice));CHECK(cudaDeviceSynchronize());
 cudaGraph_t graph,body;cudaGraphExec_t executable;CHECK(cudaGraphCreate(&graph,0));body=graph;
 for(unsigned d=0;d<depth;++d){cudaGraphConditionalHandle h;CHECK(cudaGraphConditionalHandleCreate(&h,graph,0,cudaGraphCondAssignDefault));
  cudaKernelNodeParams k{};k.func=(void*)setFlag;k.gridDim=dim3(1);k.blockDim=dim3(1);void* args[]={&h};k.kernelParams=args;cudaGraphNode_t flag;
  CHECK(cudaGraphAddKernelNode(&flag,body,nullptr,0,&k));
  cudaGraphNodeParams p{};p.type=cudaGraphNodeTypeConditional;p.conditional.handle=h;p.conditional.type=cudaGraphCondTypeIf;p.conditional.size=1;cudaGraphNode_t conditional;
  CHECK(cudaGraphAddNode(&conditional,body,&flag,nullptr,1,&p));body=p.conditional.phGraph_out[0];}
 CHECK(cudaStreamBeginCaptureToGraph(stream,body,nullptr,nullptr,0,cudaStreamCaptureModeThreadLocal));
 reset<<<(n+255)/256,256,0,stream>>>(labels,n);connect<<<(m+255)/256,256,0,stream>>>(deviceEdges,m,labels);flatten<<<(n+255)/256,256,0,stream>>>(labels,n);
 cudaGraph_t captured;CHECK(cudaStreamEndCapture(stream,&captured));CHECK(cudaGraphInstantiate(&executable,graph,0));
 std::vector<unsigned> actual(n);
 for(unsigned r=0;r<3;++r){if(delayed)delay<<<1,1,0,producer>>>();CHECK(cudaEventRecord(ready,producer));CHECK(cudaStreamWaitEvent(stream,ready,0));
  if(hostWait)CHECK(cudaEventSynchronize(ready));CHECK(cudaGraphLaunch(executable,stream));CHECK(cudaStreamSynchronize(stream));CHECK(cudaMemcpy(actual.data(),labels,n*sizeof(unsigned),cudaMemcpyDeviceToHost));
  for(unsigned i=0;i<n;++i)if(actual[i]!=(i/1000)*1000){fprintf(stderr,"bad label %u=%u\n",i,actual[i]);return 3;}}
 printf("PASS depth=%u delayed=%u hostWait=%u nodes=%u edges=%u repetitions=3\n",depth,delayed,hostWait,n,m);
 CHECK(cudaGraphExecDestroy(executable));CHECK(cudaGraphDestroy(graph));CHECK(cudaFree(labels));CHECK(cudaFree(deviceEdges));CHECK(cudaEventDestroy(ready));CHECK(cudaStreamDestroy(stream));CHECK(cudaStreamDestroy(producer));return 0;
}
