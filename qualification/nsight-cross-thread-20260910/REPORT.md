# Nsight Compute: false conditional branches execute after a cross-thread graph launch

Observed stack: Nsight Compute 2026.3.0.0 (build 38525999), CUDA 13.4.59,
NVIDIA driver 615.71.09, RTX 5060 Ti / sm_120, Linux x86-64.

The attached standalone CUDA program has two one-thread kernels and one IF graph
node. One kernel sets the condition from an input alternating between zero and
one; the conditional body increments an output initially cleared to zero.

All plain runs produce the expected 0/1 outputs. With Nsight attached but counter
collection disabled, instantiating the graph on the main CPU thread and launching
it on a worker causes the body to execute for input zero too. CUDA API calls
return success; the program detects four wrong outputs in eight launches.

## Reproduce

Extract this archive and run inside its `reproducer` directory:

```bash
python3 run.py --output ./results
```

The output directory must be new. Paths to NVCC, Nsight Compute, Compute Sanitizer
and the host compiler can be supplied as arguments; see `python3 run.py --help`.
The runner returns 1 if the numerical failures reproduce and retains every exit
code. Recorded results from the reported stack are included separately.

Or build/run the smallest case directly:

```bash
/usr/local/cuda-13.4/bin/nvcc -std=c++17 -O3 -lineinfo -arch=sm_120 \
  repro.cu -lcuda -o repro
./repro cross
/usr/local/cuda-13.4/bin/ncu --profile-from-start off ./repro cross
/usr/local/cuda-13.4/bin/ncu --profile-from-start off ./repro instantiate-worker
```

Expected: each invocation prints alternating `body=0` and `body=1` and exits 0.
Observed: the profiled `cross` invocation prints `body=1` for all eight inputs and
exits 1. The plain and `instantiate-worker` invocations exit 0.

## Controls

Two repetitions of each combination give the same outcomes:

| Graph creation / instantiation / launch | Plain | Nsight, collection off |
| --- | --- | --- |
| main / main / main | pass | pass |
| main / main / worker | pass | four incorrect outputs |
| main / worker / worker | pass | pass |
| worker / worker / worker | pass | pass |

Moving upload to the worker or uploading again there does not fix the failure
when instantiation stays on the main thread. Cross-thread execution under
Compute Sanitizer memcheck passes with zero findings.

All graph operations are serialized using thread creation/join and stream
completion. The worker explicitly pushes the same CUDA context. There is no
concurrent graph API access, graph update, graph capture, cooperative launch,
CUB, dynamic library, PhysX or Blast dependency. The program follows the
[documented graph access serialization requirement](https://docs.nvidia.com/cuda/cuda-programming-guide/04-special-topics/cuda-graphs.html#using-graph-apis).

This report isolates the observed instrumentation trigger. It does not identify
which profiler/driver component is defective or assert behavior on other versions.
