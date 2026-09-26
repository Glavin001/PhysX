# CuMetal vehicle equation recorder qualification — 2026-09-26

The separate `PhysXDestructionGpuProblemDiagnostic` target now builds and captures
the exact pre-iteration equations for six complete authored vehicles on local
CuMetal. Production equations, precision, runtime selection and materials are
unchanged by these diagnostic fixes.

- Pointer-valued device symbols use the explicit-address CuMetal symbol API.
- Diagnostic scalar/array symbols are cleared/read with symbol transfers;
  `cudaGetSymbolAddress` handles are not ordinary allocations accepted by the
  CuMetal allocation-copy path. The old recorder failed with
  `observe diagnostic overflow: cudaErrorInvalidDevicePointer`.
- Only the CuMetal equation recorder omits `clock64` calls: the clock intrinsic
  invalidated generic pointer proofs across motion projection helpers during
  compilation. Output explicitly labels `cycle_timing_available: false`.
  Work counts and equation copies remain present. CUDA diagnostics keep clocks.
- Recorder exceptions now report their solve ordinal and actual error before
  rethrowing. Incomplete capture still fails closed.

The Vibeland fixture suite (`server/src/physx_runtime/vehicle_fracture_tests.rs`)
ran serially against an isolated ABI 22 overlay. Each model captured 30 intact
free-fall solves and solve 30 at a real 30 kg cannon impact. All six reproduce
non-convergence; the capture does not qualify fracture or timings. Independent
NumPy reconstruction agrees exactly with every captured warm residual. Original
production-module and diagnostic-module iteration counts differ, so this is
not a bitwise or performance comparison. No CUDA/Vast execution was performed.

The companion Vibeland report retains raw equations, hashes, component records,
normal-runtime results and independent spectral diagnostics. The live installed
SDK remains untouched. Numerical convergence and moving-suspension destruction
remain separate unfinished work.
