#pragma once
// CuMetal's equation recorder observes values/work, not GPU timings. Its clock
// call currently invalidates generic-pointer proofs across projection helpers.
// Compile clocks out of that isolated diagnostic rather than altering solver
// operations or weakening pointer checks. Native CUDA diagnostics retain clocks.
#if defined(PX_CUMETAL) && PX_CUMETAL && defined(BLAST_GPU_NATIVE_PROBLEM_CAPTURE)
#define BLAST_COMPONENT_CYCLE_TIMING_AVAILABLE false
__device__ __forceinline__ unsigned long long componentDiagnosticClock(){return 0;}
#else
#define BLAST_COMPONENT_CYCLE_TIMING_AVAILABLE true
__device__ __forceinline__ unsigned long long componentDiagnosticClock(){return clock64();}
#endif
