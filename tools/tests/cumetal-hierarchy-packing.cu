// Focused regression for the production hierarchy radix-prefix helpers.
// 72 captured graph replays compare exact integer tile/bin prefixes, all 16
// bins, an empty bin, empty/partial/multiple warp tiles, padding and guards.
// One 256-thread block must cover bins 8..15; 2/3/5 ordinary blocks must give
// the same result. These kernels have no cooperative inter-block barriers.
// Graph replay changes inputs and synchronizes only at the readback boundary.
// Anonymous-namespace kernels also exercise native AOT registration.
//
// Scope: prefix coverage and stream/graph ordering, not a complete packLevel,
// hierarchy solve, floating-point numerical qualification or destruction scene.
// Production equations and tolerances are unchanged.
// Build/test through the repository-contained helper (omit --test to build only):
// python3 -B tools/scripts/build-destruction-sdk.py --preset macos-cumetal \
//   --stage gpu --target PhysXCuMetalHierarchyPackingTest \
//   --generator 'Unix Makefiles' --jobs 4 --test

// Exercise the actual production radix-prefix helpers, without cooperative
// multiblock launches. Ordinary independent warps are ordered by stream/graph.
#include "StressHierarchyPacking.cuh"
#include <cstdio>
#include <stdexcept>
#include <vector>
using namespace Nv::Blast::StressHierarchy;
namespace {
void check(cudaError_t result) {
    if(result!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(result));
}
__global__ void binPrefixes(unsigned* partial,PackingWork* work,unsigned tiles,unsigned capacity) {
    PackingBuffers buffers{};buffers.partial=partial;
    prefixRadixBins(buffers,work,tiles,capacity);
}
__global__ void binTotals(PackingWork* work) {prefixRadixTotals(work);}
}
int main() {
    try {
        constexpr unsigned capacity=67,guard=11,total=2*guard+RadixBins*capacity;
        unsigned* data=nullptr;PackingWork* work=nullptr;cudaStream_t stream;
        check(cudaMalloc(&data,total*sizeof(unsigned)));check(cudaMalloc(&work,sizeof(PackingWork)));
        check(cudaStreamCreateWithFlags(&stream,cudaStreamNonBlocking));
        unsigned scenarios=0;
        for(unsigned blocks:{1u,2u,3u,5u})for(unsigned tiles:{0u,1u,31u,32u,33u,65u}) {
            cudaGraph_t graph;cudaGraphExec_t executable;
            check(cudaStreamBeginCapture(stream,cudaStreamCaptureModeThreadLocal));
            binPrefixes<<<blocks,Threads,0,stream>>>(data+guard,work,tiles,capacity);
            binTotals<<<1,32,0,stream>>>(work);
            check(cudaStreamEndCapture(stream,&graph));
            check(cudaGraphInstantiate(&executable,graph,nullptr,nullptr,0));
            for(unsigned replay=0;replay<3;++replay) {
                const unsigned marker=0xabc00000u+replay;
                std::vector<unsigned> input(total,marker),expected(total),actual(total);
                PackingWork initial{},wanted{},observed{};
                initial.active=wanted.active=0x12340000u+replay;
                for(unsigned bin=0;bin<RadixBins;++bin) {
                    initial.bins[bin]=marker;
                    for(unsigned tile=0;tile<tiles;++tile)
                        input[guard+bin*capacity+tile]=bin==3?0:(bin*13+tile*7+replay*5)%19;
                }
                expected=input;unsigned binOffset=0;
                for(unsigned bin=0;bin<RadixBins;++bin) {
                    unsigned sum=0;
                    for(unsigned tile=0;tile<tiles;++tile) {
                        const unsigned index=guard+bin*capacity+tile;
                        expected[index]=sum;sum+=input[index];
                    }
                    wanted.bins[bin]=binOffset;binOffset+=sum;
                }
                check(cudaMemcpyAsync(data,input.data(),total*sizeof(unsigned),cudaMemcpyHostToDevice,stream));
                check(cudaMemcpyAsync(work,&initial,sizeof(initial),cudaMemcpyHostToDevice,stream));
                check(cudaGraphLaunch(executable,stream));
                check(cudaMemcpyAsync(actual.data(),data,total*sizeof(unsigned),cudaMemcpyDeviceToHost,stream));
                check(cudaMemcpyAsync(&observed,work,sizeof(observed),cudaMemcpyDeviceToHost,stream));
                check(cudaStreamSynchronize(stream)); // Readback boundary, not a per-kernel barrier.
                bool equal=actual==expected && observed.active==wanted.active;
                for(unsigned bin=0;bin<RadixBins;++bin)equal=equal && observed.bins[bin]==wanted.bins[bin];
                if(!equal) {
                    std::fprintf(stderr,"radix-prefix mismatch blocks=%u tiles=%u replay=%u\n",blocks,tiles,replay);
                    throw std::runtime_error("production radix prefix, high bins, padding or active guard changed");
                }
                ++scenarios;
            }
            check(cudaGraphExecDestroy(executable));check(cudaGraphDestroy(graph));
        }
        check(cudaStreamDestroy(stream));check(cudaFree(work));check(cudaFree(data));
        std::printf("PASS %u production radix-prefix graph replays: 1/2/3/5 blocks, all 16 bins, empty and warp-tail tiles, exact integer oracle and guards\n",scenarios);
        return 0;
    } catch(const std::exception& error) {
        std::fprintf(stderr,"radix-prefix test: %s\n",error.what());return 1;
    }
}
