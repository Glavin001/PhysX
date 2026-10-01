#pragma once
// Device side of the diagnostic problem capture (StressProblemCapture.cuh)
// that the component solve itself writes: whether this solve is captured, and
// each component's convergence norm, gamma and direction energy per iteration.
// Empty in every production build.
#ifdef BLAST_GPU_NATIVE_PROBLEM_CAPTURE
__device__ unsigned captureStressProblemEnabled;
// [component id][iteration][residual2, gamma, direction energy p'Lp]
__device__ float* capturedStressHistory;
__device__ unsigned capturedStressHistoryLimit;
__device__ __forceinline__ void captureStressHistory(unsigned id,unsigned iteration,unsigned field,float value){
    if(captureStressProblemEnabled && iteration<capturedStressHistoryLimit)
        capturedStressHistory[(std::size_t(id)*capturedStressHistoryLimit+iteration)*3u+field]=value;
}
#define STRESS_CAPTURE_HISTORY(id,iteration,field,value) captureStressHistory(id,iteration,field,value);
#else
#define STRESS_CAPTURE_HISTORY(id,iteration,field,value)
#endif
