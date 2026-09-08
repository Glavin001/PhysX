# GPU rewind cost versus physics replay

256 buildings; 113,664 chunks, 229,376 bonds, 768 projectiles; one 30-second instrumented run / 1800 steps. Direct GPU OFF, sleeping ON, max two physics and two stress evaluations. Every step retained.

CUDA event intervals are read at existing acceptance waits. They include stream scheduling gaps, not just kernel instructions. The CPU replay interval includes scheduling, collision/constraint work, GPU physics and dependencies. GPU restore/install can overlap its start; do not add or blindly subtract these columns.

## Complete-step peak: step 385

22874 bodies, 17273 awake; complete step 134.017 ms.

| Operation | Measured ms |
|---|---:|
| Physics replay — CPU/GPU wall interval | 9.221309 |
| Restore/install — CPU submission (both evaluations) | 0.054831 |
| Restore GPU checkpoint — CUDA interval | 0.021248 |
| Install fragment motion on GPU — CUDA interval | 0.004096 |
| Install shape ownership on GPU — CUDA interval | 0.005120 |
| Copy current state for final splits (no rewind) — CUDA interval | 0.019456 |
| Install final-split motion on GPU — CUDA interval | 0.004096 |
| Install final-split ownership on GPU — CUDA interval | 0.004096 |
| First-pass GPU restore/install interval sum | 0.030464 |

## Largest physics replay: step 725

37655 bodies, 24209 awake; complete step 79.253 ms.

| Operation | Measured ms |
|---|---:|
| Physics replay — CPU/GPU wall interval | 16.925428 |
| Restore/install — CPU submission (both evaluations) | 0.062457 |
| Restore GPU checkpoint — CUDA interval | 0.029696 |
| Install fragment motion on GPU — CUDA interval | 0.005120 |
| Install shape ownership on GPU — CUDA interval | 0.004096 |
| Copy current state for final splits (no rewind) — CUDA interval | 0.027360 |
| Install final-split motion on GPU — CUDA interval | 0.004160 |
| Install final-split ownership on GPU — CUDA interval | 0.004096 |
| First-pass GPU restore/install interval sum | 0.038912 |

This is diagnostic timing, not an untraced peak qualification. The replay interval is not a pure GPU rigid-solver kernel measurement.
