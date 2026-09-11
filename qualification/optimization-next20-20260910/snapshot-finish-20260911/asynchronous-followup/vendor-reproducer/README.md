# Draft vendor reproduction — not submitted

Compute Sanitizer reports an out-of-bounds atomic at an address inside a live
synchronously allocated buffer in a nested conditional CUDA graph. This small
CUDA-only program contains no PhysX, CUB, stream-ordered allocations, allocator
reuse, or cross-thread graph launches. The label allocation is 400,000 bytes;
all allocations and input uploads complete before graph creation. Buffers remain
alive until all graph work completes. Graph edges order reset → union → flatten.
Atomic union always links the higher root to the lower root; all input endpoints
are within 100,000 labels. Every successful run checks all 100,000 outputs.

Hardware: RTX 5060 Ti, sm_120, driver 615.71.09, CUDA 13.4.59, Compute Sanitizer
2026.3.0.0 build 38637409. Graphics and an unrelated GPU application remained
active; their identities are recorded in confirmation.json.

```bash
/usr/local/cuda-13.4/bin/nvcc -O3 -lineinfo -arch=sm_120 repro.cu -o repro
./repro 2 1 1
/usr/local/cuda-13.4/bin/compute-sanitizer --tool memcheck --error-exitcode 97 ./repro 2 1 1
/usr/local/cuda-13.4/bin/compute-sanitizer --tool memcheck --error-exitcode 97 --force-synchronization-limit 1000000 ./repro 2 1 1
```

The three arguments select conditional nesting depth, a preceding producer delay,
and a host wait for that producer event. Failures are intermittent: in the new
two-repetition control sequence, both plain runs and both default-checker runs
passed; the second high-limit run failed with 1,971 errors. The earlier default
checker failure is preserved separately. The high limit is **not** a fix.
A high-limit two-stream rendezvous independently retains GPU concurrency; full
blocking launches serialize it. Neither result exempts the integrated engine.

Related reports, not proven to share the same cause:
- https://github.com/NVIDIA/warp/issues/1406
- https://forums.developer.nvidia.com/t/compute-sanitizer-and-cuda-graph-false-positives/373484

Please investigate the sanitizer/driver conditional-graph memory tracking and
explain whether a CUDA contract is violated by this reproducer. The draft and
source are prepared locally only; no external message or upload has been sent.
