#include <cuda_runtime.h>
#include <cstdio>
#include <cstdlib>
#include <vector>
#define CHECK(x) do{auto e=(x);if(e!=cudaSuccess){fprintf(stderr,"%s: %s\n",#x,cudaGetErrorString(e));return 2;}}while(0)
__global__ void delay(){const unsigned long long begin=clock64();while(clock64()-begin<1000000000ull){}}
__global__ void selectWork(const cudaGraphDeviceNode_t* nodes,unsigned count,const unsigned* enabled,unsigned* errors) {
 unsigned i=threadIdx.x; if(i<count && cudaGraphKernelNodeSetEnabled(nodes[i],*enabled!=0)!=cudaSuccess)atomicAdd(errors,1u);
}
__global__ void setEnabled(unsigned* enabled,unsigned value){*enabled=value;}

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
 CHECK(cudaStreamBeginCaptureToGraph(stream,body,nullptr,nullptr,0,cudaStreamCaptureModeThreadLocal));
 reset<<<(n+255)/256,256,0,stream>>>(labels,n);connect<<<(m+255)/256,256,0,stream>>>(deviceEdges,m,labels);flatten<<<(n+255)/256,256,0,stream>>>(labels,n);
 cudaGraph_t captured;CHECK(cudaStreamEndCapture(stream,&captured));size_t nodeCount=0;CHECK(cudaGraphGetNodes(graph,nullptr,&nodeCount));std::vector<cudaGraphNode_t> nodes(nodeCount);CHECK(cudaGraphGetNodes(graph,nodes.data(),&nodeCount));
 std::vector<cudaGraphDeviceNode_t> handles;
 for(auto node:nodes){cudaKernelNodeAttrValue attr{};attr.deviceUpdatableKernelNode.deviceUpdatable=1;
 CHECK(cudaGraphKernelNodeSetAttribute(node,cudaKernelNodeAttributeDeviceUpdatableKernelNode,&attr));CHECK(cudaGraphKernelNodeGetAttribute(node,cudaKernelNodeAttributeDeviceUpdatableKernelNode,&attr));handles.push_back(attr.deviceUpdatableKernelNode.devNode);}
 cudaGraphDeviceNode_t* deviceNodes;unsigned *enabled,*errors;CHECK(cudaMalloc(&deviceNodes,handles.size()*sizeof(cudaGraphDeviceNode_t)));CHECK(cudaMemcpy(deviceNodes,handles.data(),handles.size()*sizeof(cudaGraphDeviceNode_t),cudaMemcpyHostToDevice));CHECK(cudaMalloc(&enabled,sizeof(unsigned)));CHECK(cudaMalloc(&errors,sizeof(unsigned)));CHECK(cudaMemset(errors,0,sizeof(unsigned)));
 size_t rootCount=0;CHECK(cudaGraphGetRootNodes(graph,nullptr,&rootCount));std::vector<cudaGraphNode_t> roots(rootCount);CHECK(cudaGraphGetRootNodes(graph,roots.data(),&rootCount));
 cudaKernelNodeParams params{};params.func=(void*)selectWork;params.gridDim=dim3(1);params.blockDim=dim3(32);unsigned count=handles.size();void* parameters[]={&deviceNodes,&count,&enabled,&errors};params.kernelParams=parameters;cudaGraphNode_t control;CHECK(cudaGraphAddKernelNode(&control,graph,nullptr,0,&params));
 for(auto root:roots)CHECK(cudaGraphAddDependencies(graph,&control,&root,nullptr,1));
 CHECK(cudaGraphInstantiate(&executable,graph,0));CHECK(cudaGraphUpload(executable,stream));CHECK(cudaStreamSynchronize(stream));
 std::vector<unsigned> actual(n);
 for(unsigned r=0;r<20;++r){if(delayed)delay<<<1,1,0,producer>>>();CHECK(cudaEventRecord(ready,producer));CHECK(cudaStreamWaitEvent(stream,ready,0));
  if(hostWait)CHECK(cudaEventSynchronize(ready));CHECK(cudaMemsetAsync(labels,0xfe,n*sizeof(unsigned),stream));setEnabled<<<1,1,0,stream>>>(enabled,r%2);CHECK(cudaGraphLaunch(executable,stream));CHECK(cudaStreamSynchronize(stream));CHECK(cudaMemcpy(actual.data(),labels,n*sizeof(unsigned),cudaMemcpyDeviceToHost));
  for(unsigned i=0;i<n;++i)if(actual[i]!=(r%2?(i/1000)*1000:0xfefefefeu)){fprintf(stderr,"bad label %u=%u\n",i,actual[i]);return 3;}}
 unsigned hostErrors=0;CHECK(cudaMemcpy(&hostErrors,errors,sizeof(unsigned),cudaMemcpyDeviceToHost));if(hostErrors){fprintf(stderr,"NODE_UPDATE_ERRORS %u\n",hostErrors);return 4;}
 printf("PASS depth=%u delayed=%u hostWait=%u nodes=%u edges=%u repetitions=20\n",depth,delayed,hostWait,n,m);
 CHECK(cudaGraphExecDestroy(executable));CHECK(cudaGraphDestroy(graph));CHECK(cudaFree(labels));CHECK(cudaFree(deviceNodes));CHECK(cudaFree(enabled));CHECK(cudaFree(errors));CHECK(cudaFree(deviceEdges));CHECK(cudaEventDestroy(ready));CHECK(cudaStreamDestroy(stream));CHECK(cudaStreamDestroy(producer));return 0;
}
