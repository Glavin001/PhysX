# Unresolved CUB / synchronization-check interaction

Compute Sanitizer 2025.1.0.0 (build 35583870), installed CUDA 12.8, RTX 4090 / sm_89.

The unfiltered resident analytic test reports 128 divergent-warp barrier errors in CUB DeviceSelect and stops during GPU topology initialization. The separate reference topology test reproduces the same CUB error. Neither failure is waived or counted as a passing full synchronization audit.

The minimal standalone reproducer selects the same ten ascending indices from twelve flags. Eager and ordinary graph execution pass synccheck. Conditional graph execution passes uninstrumented, but under synccheck it returns an illegal-memory-access error while the checker reports zero detected errors. These results isolate an instrumentation-dependent failure; they do not establish its root cause or prove the library correct.

Reproduce (paths from the repository root):

```sh
/usr/local/cuda/bin/nvcc -std=c++17 -arch=sm_89 -lineinfo qualification/component-stress-cub-synccheck/select.cu -o /tmp/component-cub-select
/usr/local/cuda/bin/compute-sanitizer --tool synccheck --print-limit 2 --error-exitcode 99 /tmp/component-cub-select eager
/usr/local/cuda/bin/compute-sanitizer --tool synccheck --print-limit 2 --error-exitcode 99 /tmp/component-cub-select graph
/usr/local/cuda/bin/compute-sanitizer --tool synccheck --print-limit 2 --error-exitcode 99 /tmp/component-cub-select conditional
/tmp/component-cub-select conditional
```

Separately scoped checks of componentStressSolve, persistentStressSolve and finishComponentStress report zero synchronization errors. Shared-memory race checking of the new component kernels reports zero hazards. The unfiltered memory-access/leak check passes. These are distinct validation scopes, not a substitute for resolving the full synccheck failure.
