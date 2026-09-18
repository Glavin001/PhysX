# CPU synchronization around native correction

256 buildings; 113,664 chunks, 229,376 bonds, 768 projectiles; one 30-second diagnostic / 1800 steps. Direct GPU OFF, sleeping ON, correction limit one, stress evaluation limit two.

No physical behavior is changed by these profiling scopes. Times include instrumentation and are not an untraced performance qualification.

A GPU-completion wait includes unfinished physics, transfer, and scheduling; it is not removable CPU work or a DMA-only measurement. CPU-clock time can include busy waiting. Worker wall intervals use their union, not their sum. Rows can overlap GPU work and each other; do not add them to replay time.

## Complete-step peak: step 385

22874 bodies / 17273 awake; complete step 134.017 ms; replay 9.220 ms.

| Responsibility | Trial/before replay wall ms | Inside replay wall ms | After replay wall ms | CPU time, whole tick (ms) | Calls |
|---|---:|---:|---:|---:|---:|
| Wait for GPU physics and readback completion | 0.001313 | 0.001212 | 0.000000 | 0.002494 | 2 |
| CPU wake/sleep body-status worker tasks | 0.437826 | 0.177090 | 0.000000 | 1.678069 | 18 |
| CPU query-tree membership changes | 0.454767 | 0.385078 | 0.000000 | 0.840186 | 2 |
| Commit sleep transitions to GPU (CPU wall, includes waits) | 0.195414 | 0.198831 | 0.010691 | 0.234850 | 46 |
| CPU activity checkpoint | 0.669628 | 0.000000 | 0.000000 | 0.669736 | 1 |
| CPU activity rollback before replay | 0.000000 | 0.837311 | 0.000000 | 0.837521 | 1 |

## Largest replay: step 725

37655 bodies / 24209 awake; complete step 79.253 ms; replay 16.925 ms.

| Responsibility | Trial/before replay wall ms | Inside replay wall ms | After replay wall ms | CPU time, whole tick (ms) | Calls |
|---|---:|---:|---:|---:|---:|
| Wait for GPU physics and readback completion | 0.001253 | 0.001422 | 0.000000 | 0.002645 | 2 |
| CPU wake/sleep body-status worker tasks | 0.556297 | 0.858771 | 0.000000 | 4.071743 | 24 |
| CPU query-tree membership changes | 0.378866 | 0.583708 | 0.000000 | 0.962885 | 2 |
| Commit sleep transitions to GPU (CPU wall, includes waits) | 0.290547 | 0.283077 | 0.012621 | 0.234367 | 47 |
| CPU activity checkpoint | 1.313478 | 0.000000 | 0.000000 | 1.313674 | 1 |
| CPU activity rollback before replay | 0.000000 | 2.260473 | 0.000000 | 2.260670 | 1 |

## Largest combined body-readback wait: step 82

367 bodies / 108 awake; complete step 24.749 ms; replay 2.924 ms.

| Responsibility | Trial/before replay wall ms | Inside replay wall ms | After replay wall ms | CPU time, whole tick (ms) | Calls |
|---|---:|---:|---:|---:|---:|
| Wait for GPU physics and readback completion | 0.312091 | 0.320698 | 0.000000 | 0.632767 | 2 |
| CPU wake/sleep body-status worker tasks | 0.001473 | 0.002244 | 0.000000 | 0.003727 | 2 |
| CPU query-tree membership changes | 0.000000 | 0.000000 | 0.000000 | 0.000000 | 0 |
| Commit sleep transitions to GPU (CPU wall, includes waits) | 0.015395 | 0.000000 | 0.003196 | 0.017756 | 23 |
| CPU activity checkpoint | 0.002224 | 0.000000 | 0.000000 | 0.002245 | 1 |
| CPU activity rollback before replay | 0.000000 | 0.003647 | 0.000000 | 0.003647 | 1 |

The current body-status workers apply simulation sleep/readiness, not just user-facing mirrors. Deferring them requires provisional activity semantics. Query membership is observation work, but freeze/unfreeze deltas must survive trial rejection. Public scene publication already occurs once after acceptance.
