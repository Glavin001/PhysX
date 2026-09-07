# Compensated FP32 inverse experiment — rejected

🧪 Tested outside production; not linked into the native SDK. The regular FP64 inverse remains the baseline. This experiment does not qualify a precision change in the simulation.

## Scope

97,280 independent six-variable matrix-vector products (the dynamic node count of 256 intact buildings), 100 kernel applications per trial, five alternating trials per implementation. Matrices are manufactured symmetric positive definite matrices, not recorded scene matrices. There are no rigid bodies, bonds, collisions, fracture or correction in this microbenchmark. Timing is CUDA event elapsed time including the repeated launches, excluding packing and initial uploads. No full-scene speed claim follows from this test.

| Implementation | Mean GPU ms per 100 applications | Worst GPU ms |
|---|---|---|
| Native cached FP64 inverse | 1.091200 | 1.094432 |
| Compensated FP32, exact normal exponent adjustment | 1.567430 | 1.568768 |

The candidate is 43.6% slower in this isolated test. Worst relative vector error is 1.363e-14, below the unchanged 2e-12 inverse threshold. This is a screened-out candidate, so no production replacement, frozen-wall run or long benchmark was justified.

The first probe used exactly representable binary input coefficients and general scalbn calls; it was slower and its zero measured error was a weak precision test. It is archived as initial-binary-inputs.jsonl and initial_scalbn.cuh. The final probe uses non-binary coefficients and values, coefficient exponents from -240 to 240 and input exponents from -275 to 275. The finite generated results do not qualify every possible FP64 boundary or ill-conditioned operator.

Compiled baseline component kernel resource observation: 96 registers, 528 bytes stack, 560 bytes shared storage. This is compiler metadata, not hardware-counter evidence or a claim that stack traffic dominates. The inspected inverse-only baseline kernel contains 36 DFMA instructions; the compensated implementation introduces additional normalization, conversion and error-accumulation work. Timing rejects this implementation; it does not prove that every compensated or Tensor Core approach is inferior.

## Reproduce

From the repository root:

```sh
/usr/local/cuda/bin/nvcc -O3 -std=c++17 -arch=sm_89 -DPHYSX_RESIDENT_DESTRUCTION -Iblast/include/extensions/stressgpu -Iblast/include/extensions/stress -Iblast/source/sdk/extensions/stressgpu qualification/compensated-inverse-experiment/probe.cu -lcuda -o /tmp/compensated-inverse-probe
/tmp/compensated-inverse-probe
```

Recorded baseline source is commit 7f185cc5. Later production changes may alter the included inverse; restore that revision in a separate checkout to reproduce the exact baseline. No runtime compatibility or tuning switch was added.
