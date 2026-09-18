# Standalone CUDA conditional-graph diagnostic

This reproduces an asynchronous illegal-address observation without linking
PhysX or Blast. It is a diagnostic, not a substitute for engine memory checks.
It does not change production graph settings or mask failures.

```sh
python3 tools/diagnostics/cuda-conditional-graph/run.py \
  --nvcc /usr/local/cuda/bin/nvcc \
  --sanitizer /usr/local/cuda/bin/compute-sanitizer \
  --output out/conditional-graph-check
```

The output directory must be new. The script records the exact commands, tool
versions, GPU/driver, source hash, copied source and individual exit codes/logs.
It exits nonzero if any mode fails. No download or driver modification occurs.
For a different GPU, pass the appropriate `--architecture` (default `sm_89`).
CUDA 12.3 or later is needed for conditional-node support.

Each mode runs the same arithmetic: initialize one allocated integer, add a
parameter four times in serial kernels, then add one. All 500 results must equal
`4 * (step + 1) + 1`. Modes are a plain graph, an IF body with default condition
one, and a WHILE body that explicitly clears its condition after the additions.
The IF mode makes no device-side conditional-handle call. The program uses
explicit graph nodes, one nonblocking stream, and ordinary `cudaMalloc`;
there are no allocation nodes, nested bodies or stream capture. Later launches
exercise graph update; an error printed at `step=0` precedes every update and
source-graph destruction.

## Observed on 2026-09-06

RTX 4090, driver 595.71.05, nvcc 12.8.93:

| Instrumentation | Plain | IF | WHILE |
| --- | --- | --- | --- |
| None (both recorded campaigns) | 500 correct | 500 correct | 500 correct |
| Compute Sanitizer 2025.1 / CUDA 12.8 | 500 correct, zero errors | 500 correct, zero errors | error 700, step 0 |
| Compute Sanitizer 2026.1 / CUDA 13.2 | 500 correct, zero errors | error 700, step 0 | error 700, step 0 |

Records: `out/conditional-graph-repro-{12.8,13.2}-20260906/results.json`.
The checked-in qualification record includes the logs and source hash.
The instrumented failures report at `cudaMemcpyAsync`, without a device fault PC.
Earlier variants (including IF with an unused handle argument, body stream
capture, preserving source graphs, a blocking stream and synchronizing before
launch) also failed. This does not prove a specific driver/tool bug. Source
layout and instrumentation can affect the outcome; one clean retry is not a fix.

These results demonstrate a conditional-graph diagnostic failure independent of
the engine. They do **not** establish that the native stress-solver observation
has the same cause, that graph update is faulty, or that native memory safety is
qualified. Keep the original engine failures open and retain asynchronous graph
execution in production. The archived native comparisons using launch blocking
or graph re-instantiation are comparisons, not accepted production workarounds.
