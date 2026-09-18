// A restart must not access nonexistent history. Passing a null previous-norm
// pointer makes the formerly unconditional read fail instead of hiding behind
// whatever bits happened to occupy a CUDA allocation.
namespace MotionModeTest {
__global__ void directionRestart(float* result,const unsigned* iteration,const float* history){
    AngLin pi{},q{},rho{{1,2,3,0},{4,5,6,0}},w{{2,3,4,0},{5,6,7,0}};
    const float norm=1;const unsigned node=0,active=1,counts[2]={0,1};
    nodeSpaceUpdateDirectionBody(&pi,&q,&rho,&w,&norm,history,&node,&active,
        result,1,&node,counts,iteration,0);
    if(!threadIdx.x){result[1]=pi.angular.x;result[2]=pi.linear.z;result[3]=q.angular.x;result[4]=q.linear.z;}
}
void firstDirectionWithoutHistory(){
    Device<float> result(5);Device<unsigned> iteration(1);directionRestart<<<1,kBlockSize>>>(result.data,iteration.data,nullptr);check(cudaGetLastError());check(cudaDeviceSynchronize());
    const auto values=result.get();require(values==std::vector<float>({139,1,6,2,7}),"first direction accessed history or changed restart arithmetic");
    std::puts("first direction: one node, no previous-norm storage, beta=0 and exact output passed");
}
}
