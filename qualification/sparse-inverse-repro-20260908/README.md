# Reproduced sparse-inverse failure; not a production optimization

The current 256-building work census motivated revisiting the earlier memory-safety rejection. Work stayed in an isolated copy under `out/sparse-inverse-repro-20260908`; no sparse inverse is enabled in production.

The exact-zero coefficient branch again fails the independent polynomial oracle under CUDA 12.8 / sm_89, at an eight-byte global read in the second inverse application. Compute Sanitizer exits 99 with 30 reported errors. The earlier 257-node cached-inverse checks pass before this failure. This confirms that subsequent runtime changes did not resolve the old failure.

Adding address prints for node zero masks the failure: the full small motion-mode suite then passes and memcheck reports zero errors. Printed inverse base/stride/node/row/column values are valid in that instrumented run. That perturbation does **not** diagnose the uninstrumented failure, prove a compiler bug, or qualify the sparse implementation. It must remain excluded until a minimal reproducer or another decisive test explains the memory safety problem.

Both builds use `nvcc -O3 -DNDEBUG -std=c++17 -arch=sm_89 -lineinfo -DPHYSX_RESIDENT_DESTRUCTION`, the isolated stress implementation/tests, public stress include directories, and `-lcuda`. Run `compute-sanitizer --tool memcheck --error-exitcode 99 BINARY small`. The fixture includes the 12-node / 20-bond polynomial oracle, 257 SPD blocks, small motion cases and mixed components. It is not a rigid-body/destruction timing benchmark.

No peak saving is claimed. The production server was restored after each isolated test.
