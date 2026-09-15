// Diagnostic: reproduce the topology's shared CUB scratch-size lifecycle.
#include <cub/cub.cuh>
#include <cuda_runtime.h>
#include <cstdio>
#include <vector>
#include <algorithm>
int main(){
    for(int n:{2,256,513}){
        unsigned *in,*out,*indices,*order,*count;
        cudaMalloc(&in,n*4);cudaMalloc(&out,n*4);cudaMalloc(&indices,n*4);
        cudaMalloc(&order,n*4);cudaMalloc(&count,4);
        size_t sort=0,select=0,scan=0;
        cub::DeviceRadixSort::SortPairs(nullptr,sort,in,out,indices,order,n);
        cub::DeviceSelect::Flagged(nullptr,select,indices,in,order,count,n);
        cub::DeviceScan::ExclusiveSum(nullptr,scan,in,out,n);
        size_t bytes=std::max({sort,select,scan});void* scratch=nullptr;
        const auto alloc=cudaMalloc(&scratch,bytes);
        std::vector<unsigned> input(n,1),result(n);cudaMemcpy(in,input.data(),n*4,cudaMemcpyHostToDevice);
        cudaMemset(out,0xcd,n*4);
        const size_t before=bytes;auto status=cub::DeviceScan::ExclusiveSum(scratch,bytes,in,out,n);
        auto copy=cudaMemcpy(result.data(),out,n*4,cudaMemcpyDeviceToHost);
        bool ok=alloc==cudaSuccess && status==cudaSuccess && copy==cudaSuccess;
        for(int i=0;i<n;++i)ok &= result[i]==unsigned(i);
        printf("n=%d sort=%zu select=%zu scan=%zu before=%zu after=%zu ptr=%p alloc=%d scan_status=%d copy=%d valid=%d first=%u last=%u\n",n,sort,select,scan,before,bytes,scratch,int(alloc),int(status),int(copy),ok,result[0],result.back());
        cudaFree(scratch);cudaFree(in);cudaFree(out);cudaFree(indices);cudaFree(order);cudaFree(count);
        if(!ok)return 1;
    }
}
