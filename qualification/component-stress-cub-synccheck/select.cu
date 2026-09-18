#include <cub/cub.cuh>
#include <cuda_runtime.h>
#include <cstdio>
#include <stdexcept>
#include <string>
void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}
__global__ void condition(cudaGraphConditionalHandle handle){cudaGraphSetConditional(handle,1);}
int main(int argc,char** argv){try{
 const std::string mode=argc>1?argv[1]:"eager";
 unsigned *flags,*output,*count;void* scratch=nullptr;size_t bytes=0;
 check(cudaMalloc(&flags,12*sizeof(unsigned)));check(cudaMalloc(&output,12*sizeof(unsigned)));check(cudaMalloc(&count,sizeof(unsigned)));
 const unsigned host[]={0,1,1,1,1,1,1,1,0,1,1,1};check(cudaMemcpy(flags,host,sizeof(host),cudaMemcpyHostToDevice));
 cub::CountingInputIterator<unsigned> ids(0u);
 check(cub::DeviceSelect::Flagged(nullptr,bytes,ids,flags,output,count,12));check(cudaMalloc(&scratch,bytes));
 cudaStream_t stream;check(cudaStreamCreateWithFlags(&stream,cudaStreamNonBlocking));
 cudaGraph_t graph=nullptr;cudaGraphExec_t exec=nullptr;
 if(mode=="graph")check(cudaStreamBeginCapture(stream,cudaStreamCaptureModeThreadLocal));
 if(mode=="conditional"){
  check(cudaGraphCreate(&graph,0));cudaGraphConditionalHandle handle;
  check(cudaGraphConditionalHandleCreate(&handle,graph,1,cudaGraphCondAssignDefault));
  cudaGraphNodeParams params{};params.type=cudaGraphNodeTypeConditional;params.conditional.handle=handle;params.conditional.type=cudaGraphCondTypeIf;params.conditional.size=1;
  cudaGraphNode_t node;check(cudaGraphAddNode(&node,graph,nullptr,0,&params));
  check(cudaStreamBeginCaptureToGraph(stream,params.conditional.phGraph_out[0],nullptr,nullptr,0,cudaStreamCaptureModeThreadLocal));
 }
 check(cub::DeviceSelect::Flagged(scratch,bytes,ids,flags,output,count,12,stream));
 if(mode!="eager"){
  cudaGraph_t captured=nullptr;check(cudaStreamEndCapture(stream,&captured));if(!graph)graph=captured;
  check(cudaGraphInstantiate(&exec,graph,0));check(cudaGraphLaunch(exec,stream));
 }
 check(cudaStreamSynchronize(stream));unsigned n=0;check(cudaMemcpy(&n,count,sizeof(n),cudaMemcpyDeviceToHost));
 unsigned result[12];check(cudaMemcpy(result,output,n*sizeof(unsigned),cudaMemcpyDeviceToHost));
 if(n!=10)throw std::runtime_error("wrong count");
 unsigned slot=0;for(unsigned i=0;i<12;++i)if(host[i] && result[slot++]!=i)throw std::runtime_error("wrong order");
 printf("%s: stable selection of 10/12 rows passed\n",mode.c_str());
 if(exec)check(cudaGraphExecDestroy(exec));if(graph)check(cudaGraphDestroy(graph));check(cudaStreamDestroy(stream));
 check(cudaFree(flags));check(cudaFree(output));check(cudaFree(count));check(cudaFree(scratch));return 0;
}catch(const std::exception& e){fprintf(stderr,"%s\n",e.what());return 1;}}
