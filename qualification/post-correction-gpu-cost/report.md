# GPU rewind cost versus physics replay

256 buildings; 113,664 chunks, 229,376 bonds, 768 projectiles; one 30-second instrumented run / 1800 steps. Direct GPU OFF, sleeping ON, max two physics and two stress evaluations. Every step retained.

CUDA event intervals are read at existing acceptance waits. They include stream scheduling gaps, not just kernel instructions. The CPU replay interval includes scheduling, collision/constraint work, GPU physics and dependencies. GPU restore/install can overlap its start; do not add or blindly subtract these columns.

## Complete-step peak: step 387

22883 bodies, 17120 awake; complete step 102.476 ms.

| Operation | Measured ms |
|---|---:|
| Physics replay — CPU/GPU wall interval | 8.451895 |
| Restore/install — CPU submission (both evaluations) | 0.055975 |
| Restore GPU checkpoint — CUDA interval | 0.020480 |
| Install fragment motion on GPU — CUDA interval | 0.004096 |
| Install shape ownership on GPU — CUDA interval | 0.003072 |
| Copy current state for final splits (no rewind) — CUDA interval | 0.020480 |
| Install final-split motion on GPU — CUDA interval | 0.003392 |
| Install final-split ownership on GPU — CUDA interval | 0.005120 |
| First-pass GPU restore/install interval sum | 0.027648 |

## Largest physics replay: step 314

15733 bodies, 12019 awake; complete step 74.816 ms.

| Operation | Measured ms |
|---|---:|
| Physics replay — CPU/GPU wall interval | 15.090501 |
| Restore/install — CPU submission (both evaluations) | 0.053429 |
| Restore GPU checkpoint — CUDA interval | 0.018240 |
| Install fragment motion on GPU — CUDA interval | 0.006144 |
| Install shape ownership on GPU — CUDA interval | 0.004096 |
| Copy current state for final splits (no rewind) — CUDA interval | 0.014336 |
| Install final-split motion on GPU — CUDA interval | 0.004096 |
| Install final-split ownership on GPU — CUDA interval | 0.003072 |
| First-pass GPU restore/install interval sum | 0.028480 |

This is diagnostic timing, not an untraced peak qualification. The replay interval is not a pure GPU rigid-solver kernel measurement.
