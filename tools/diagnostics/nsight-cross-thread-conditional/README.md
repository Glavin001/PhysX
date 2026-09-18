# Nsight conditional graphs across CPU threads

A standalone reproducer for incorrect conditional-branch execution under Nsight
Compute 2026.3.0, CUDA 13.4.59, driver 615.71.09, RTX 5060 Ti. No PhysX, Blast,
CUB, cooperative kernels, stream capture or dynamic library is required.

```bash
python3 tools/diagnostics/nsight-cross-thread-conditional/run.py \
  --output out/NEW-cross-thread-repro
```

The output directory must be new. This builds the copied CUDA source, records
versions, GPU state, commands, return codes, actual loaded modules and hashes,
and runs two repetitions of six thread-placement controls, plain and attached
with counter collection disabled. A final cross-thread memcheck is included.
The runner returns **1 when the profiler failures reproduce**, retaining their
nonzero exits rather than treating incorrect computation as success.

The graph has two one-thread kernels and one IF node. Eight launches alternate
input 0/1. The conditional body must execute zero/one times respectively. CPU
thread creation/join serialize graph operations, CUDA stream synchronization
completes each launch, and the worker explicitly pushes the same CUDA context.
This follows NVIDIA's requirement to [serialize access to graph objects](https://docs.nvidia.com/cuda/cuda-programming-guide/04-special-topics/cuda-graphs.html#using-graph-apis).

| Mode | Graph creation | Instantiation | Upload | Launch | Plain | Nsight attachment |
| --- | --- | --- | --- | --- | --- | --- |
| same | main | main | main | main | pass | pass |
| cross | main | main | main | worker | pass | **four false branches execute** |
| instantiate-worker | main | worker | worker | worker | pass | pass |
| worker | worker | worker | worker | worker | pass | pass |
| upload-worker | main | main | worker | worker | pass | **four false branches execute** |
| reupload-worker | main | main | main, worker | worker | pass | **four false branches execute** |

All six plain variants pass twice. The three failing attached variants fail in
both repetitions; cross-thread memcheck passes. This isolates an instrumentation
failure associated with the instantiation/launch thread boundary in the tested
stack. It does not identify the defective vendor component or establish behavior
on other driver/toolkit/profiler versions. No driver changes or profiler patches
are included. [Evidence](../../../qualification/nsight-cross-thread-20260910/README.md).

## Native diagnostic with inline CPU task dispatch

A separate helper copies the native scene setup with PhysX's existing zero-worker
inline dispatcher, compiling against the current built SDK. It changes CPU task
scheduling in an isolated executable. It does not alter production libraries,
solver settings, conditional branches or installed scene configuration.

```bash
python3 tools/diagnostics/nsight-cross-thread-conditional/build-native-inline.py \
  --output out/NEW-native-inline
/usr/local/cuda-13.4/bin/ncu --profile-from-start off \
  out/NEW-native-inline/native_gpu_correction_body_test-ncu-inline
```

The 29-case native correction fixture passes plain, attached with collection off,
and with selected hardware counters. This provides a profiling diagnostic; CPU
or complete-step timings from it cannot represent the production four-worker
configuration. The helper also accepts `--target native_destruction_demo`, but
city-scale physical-history matching and peak counter captures using that target
remain to be validated. Do that before making a production bottleneck claim.
