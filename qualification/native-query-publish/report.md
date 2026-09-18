# GPU rewind cost versus physics replay

256 buildings; 113,664 chunks, 229,376 bonds, 768 projectiles; one 30-second instrumented run / 1800 steps. Direct GPU OFF, sleeping ON, max two physics and two stress evaluations. Every step retained.

CUDA event intervals are read at existing acceptance waits. They include stream scheduling gaps, not just kernel instructions. The CPU replay interval includes scheduling, collision/constraint work, GPU physics and dependencies. GPU restore/install can overlap its start; do not add or blindly subtract these columns.

## Complete-step peak: step 396

22895 bodies, 17348 awake; complete step 113.891 ms.

| Operation | Measured ms |
|---|---:|
| Physics replay — CPU/GPU wall interval | 8.572364 |
| Restore/install — CPU submission (both evaluations) | 0.053369 |
| Restore GPU checkpoint — CUDA interval | 0.020608 |
| Install fragment motion on GPU — CUDA interval | 0.003072 |
| Install shape ownership on GPU — CUDA interval | 0.004096 |
| Copy current state for final splits (no rewind) — CUDA interval | 0.021216 |
| Install final-split motion on GPU — CUDA interval | 0.005120 |
| Install final-split ownership on GPU — CUDA interval | 0.004096 |
| First-pass GPU restore/install interval sum | 0.027776 |

## Largest physics replay: step 399

23439 bodies, 17899 awake; complete step 90.186 ms.

| Operation | Measured ms |
|---|---:|
| Physics replay — CPU/GPU wall interval | 24.728157 |
| Restore/install — CPU submission (both evaluations) | 0.066064 |
| Restore GPU checkpoint — CUDA interval | 0.022208 |
| Install fragment motion on GPU — CUDA interval | 0.006144 |
| Install shape ownership on GPU — CUDA interval | 0.004096 |
| Copy current state for final splits (no rewind) — CUDA interval | 0.021504 |
| Install final-split motion on GPU — CUDA interval | 0.004352 |
| Install final-split ownership on GPU — CUDA interval | 0.003072 |
| First-pass GPU restore/install interval sum | 0.032448 |

This is diagnostic timing, not an untraced peak qualification. The replay interval is not a pure GPU rigid-solver kernel measurement.
