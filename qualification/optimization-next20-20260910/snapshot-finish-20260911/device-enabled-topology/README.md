# GPU-selected flat topology graphs — isolated candidate

Hypothesis: replace nested conditional transaction bodies with flat graphs whose
kernel nodes are enabled/disabled by a preceding GPU selector. Keep GPU counts,
validation, kernel dependency order, current-tick inputs, accepted publication
and at most one correction. This removes the conditional topology graph path
that fails asynchronous memory checking, without introducing a CPU wait.

Application savings estimate: unproven, initially 0 ms. Confidence in fixing the
diagnostic is moderate after the native impact pass; confidence in performance
is low until matched full-tick measurements. A verified performance-neutral
result can enable reliable asynchronous correctness and profiling of topology.
Copy kernels replace transaction memcpy nodes; CUB memset nodes become equivalent
byte fills so the GPU can skip the whole body. Initial graph uploads and device
node-handle storage add setup/memory costs. These must be recorded separately.

Existing guards reject malformed counts/edits and aborted transactions. Device
node-update failures trap rather than proceeding with an unknown work mask.
The scheduler must not use programmatic dependent launch; ordinary completion
edges ensure every selector finishes before the selected body can execute.

## Current evidence

- Standalone mechanism: 20 alternating disabled/enabled iterations pass plain,
  normal memcheck with a host producer wait, and normal memcheck without that
  host wait. Disabled iterations preserve deliberately poisoned labels.
- Existing topology suite passes plain and normal memcheck, including empty,
  invalid, overflowed and aborted transactions, discard/commit-once and
  100,000 chunks / 200,000 bonds.
- First native attempt rejected a CUB memset node at import. Its failed receipt
  is retained; filling those bytes with a skippable kernel resolves the unsupported
  graph-node type. No runtime/timing result from that attempt is accepted.
- Native 25-building initial impact passes two independent restored ticks both
  plain and under **default asynchronous memcheck**, zero memory errors. Each
  tick reports 3,412 new broken bonds, 537 output clusters, 304 maximum stress
  iterations, one correction, two stress evaluations, and strict repeatability.
- Full 52-scenario normal memcheck is running at
  `out/snapshot-finish-20260911/device-enabled-mem-suite`.

This candidate is not retained in the main worktree or installed. Its runtime is
`c22bd54340da110048549cb4f216b54c886a7decac6b4e7c4d527d5bcc15b787`.
No application speedup is claimed. Required next gates: complete 52-case memory
suite, correction regressions, full ordinary/sleeping wall, physical A/B output
checks and repeated unprofiled complete-step comparisons across all scenarios.
Keep the preceding stable implementation if any required gate fails.

[CUDA device-node API](https://docs.nvidia.com/cuda/cuda-runtime-api/structcudaGraphKernelNodeUpdate.html).
Exact local API requirements were also checked in CUDA 13.4 headers: device
updatable graphs require upload before execution and cannot use graph-exec
update or multiple instantiation. This implementation obeys those constraints.
