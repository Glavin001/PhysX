# CPU synchronization around native correction

256 buildings; 113,664 chunks, 229,376 bonds, 768 projectiles; one 30-second diagnostic / 1800 steps. Direct GPU OFF, sleeping ON, correction limit one, stress evaluation limit two.

No physical behavior is changed by these profiling scopes. Times include instrumentation and are not an untraced performance qualification.

A GPU-completion wait includes unfinished physics, transfer, and scheduling; it is not removable CPU work or a DMA-only measurement. CPU-clock time can include busy waiting. Worker wall intervals use their union, not their sum. Rows can overlap GPU work and each other; do not add them to replay time.

## Complete-step peak: step 396

22895 bodies / 17348 awake; complete step 113.891 ms; replay 8.572 ms.

| Responsibility | Trial/before replay wall ms | Inside replay wall ms | After replay wall ms | CPU time, whole tick (ms) | Calls |
|---|---:|---:|---:|---:|---:|
| Wait for GPU physics and readback completion | 0.001232 | 0.001202 | 0.000000 | 0.002425 | 2 |
| CPU wake/sleep body-status worker tasks | 0.231371 | 0.152895 | 0.000000 | 1.150557 | 18 |
| Collect changed identities for final CPU query observation | 0.002274 | 0.002865 | 0.000000 | 0.005069 | 4 |
| CPU query-tree membership changes | 0.000000 | 0.000000 | 0.005209 | 0.005020 | 1 |
| Commit sleep transitions to GPU (CPU wall, includes waits) | 0.229556 | 0.186098 | 0.011221 | 0.257406 | 42 |
| CPU activity checkpoint | 0.551228 | 0.000000 | 0.000000 | 0.551464 | 1 |
| CPU activity rollback before replay | 0.000000 | 0.749569 | 0.000000 | 0.744096 | 1 |

## Largest replay: step 399

23439 bodies / 17899 awake; complete step 90.186 ms; replay 24.727 ms.

| Responsibility | Trial/before replay wall ms | Inside replay wall ms | After replay wall ms | CPU time, whole tick (ms) | Calls |
|---|---:|---:|---:|---:|---:|
| Wait for GPU physics and readback completion | 0.001243 | 0.001222 | 0.000000 | 0.002454 | 2 |
| CPU wake/sleep body-status worker tasks | 0.221153 | 0.237864 | 0.000000 | 1.485405 | 18 |
| Collect changed identities for final CPU query observation | 0.002866 | 0.003015 | 0.000000 | 0.005791 | 4 |
| CPU query-tree membership changes | 0.000000 | 0.000000 | 0.006883 | 0.006643 | 1 |
| Commit sleep transitions to GPU (CPU wall, includes waits) | 0.316016 | 0.173975 | 0.027964 | 0.368721 | 208 |
| CPU activity checkpoint | 0.422969 | 0.000000 | 0.000000 | 0.423163 | 1 |
| CPU activity rollback before replay | 0.000000 | 0.794362 | 0.000000 | 0.794540 | 1 |

## Largest combined body-readback wait: step 92

597 bodies / 343 awake; complete step 31.359 ms; replay 2.657 ms.

| Responsibility | Trial/before replay wall ms | Inside replay wall ms | After replay wall ms | CPU time, whole tick (ms) | Calls |
|---|---:|---:|---:|---:|---:|
| Wait for GPU physics and readback completion | 0.315989 | 0.311571 | 0.000000 | 0.627617 | 2 |
| CPU wake/sleep body-status worker tasks | 0.003727 | 0.003687 | 0.000000 | 0.007384 | 2 |
| Collect changed identities for final CPU query observation | 0.000000 | 0.000000 | 0.000000 | 0.000000 | 0 |
| CPU query-tree membership changes | 0.000000 | 0.000000 | 0.000000 | 0.000000 | 0 |
| Commit sleep transitions to GPU (CPU wall, includes waits) | 0.016190 | 0.000000 | 0.005279 | 0.020532 | 29 |
| CPU activity checkpoint | 0.014196 | 0.000000 | 0.000000 | 0.014306 | 1 |
| CPU activity rollback before replay | 0.000000 | 0.004208 | 0.000000 | 0.004238 | 1 |

The current body-status workers apply simulation sleep/readiness, not just user-facing mirrors. Deferring them requires provisional activity semantics. Query membership is observation work; queued freeze/unfreeze identities must survive trial rejection and publish once after replay. Public scene publication already occurs once after acceptance.
