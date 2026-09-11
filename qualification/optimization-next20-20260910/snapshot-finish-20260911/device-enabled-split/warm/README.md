# Continuous ordinary/sleeping confirmation

256 buildings, 113,664 chunks, 229,376 bonds; 0 or 256 projectiles. Two 600-tick measured trials in A-before/B/A-after order, plus excluded separate warmups. Normal unprofiled execution. Full tick includes CPU/GPU work and at most one correction; initialization recorded separately. Shared GPU with the authorized existing server/graphics; no isolated performance claim.

| Stage | Scenario | Trial | Mean ms | Max ms | 120 Hz misses | 60 Hz misses | Initialization ms |
|---|---|---:|---:|---:|---:|---:|---:|
| A-after | idle-256 | 1 | 1.544 | 13.756 | 1/600 | 0/600 | 2195.760 |
| A-after | idle-256 | 2 | 1.769 | 14.575 | 1/600 | 0/600 | 2219.140 |
| A-after | impacts-256 | 1 | 54.765 | 202.023 | 519/600 | 519/600 | 2110.250 |
| A-after | impacts-256 | 2 | 55.136 | 207.905 | 519/600 | 519/600 | 2155.168 |
| A-before | idle-256 | 1 | 1.709 | 13.990 | 1/600 | 0/600 | 2195.916 |
| A-before | idle-256 | 2 | 1.678 | 12.048 | 1/600 | 0/600 | 2162.979 |
| A-before | impacts-256 | 1 | 54.936 | 177.557 | 519/600 | 519/600 | 2178.441 |
| A-before | impacts-256 | 2 | 54.945 | 205.845 | 519/600 | 519/600 | 2149.911 |
| B | idle-256 | 1 | 1.694 | 14.923 | 1/600 | 0/600 | 2236.042 |
| B | idle-256 | 2 | 1.830 | 14.813 | 1/600 | 0/600 | 2197.081 |
| B | impacts-256 | 1 | 54.990 | 178.072 | 519/600 | 519/600 | 2154.990 |
| B | impacts-256 | 2 | 54.596 | 184.494 | 519/600 | 519/600 | 2139.503 |

All four comparisons have no physical-counter or iteration-history differences. All 7,200 measured ticks converge and obey correction/evaluation limits. Controlled quality failures and chaotic history changes are empty. Wrapper exit 2 records unmet performance/endurance gates, not a failed simulation: heavy misses 519/600 at both budgets; idle misses 1/600 at 120 Hz and 0/600 at 60 Hz. Two 10-second trials do not satisfy the longer formal endurance protocol.

Heavy means overlap controls; peak reductions are not established under control variability. Candidate idle pooled mean is 1.762 ms, versus 1.694 before / 1.657 after (0.068–0.106 ms higher); individual control means span 1.544–1.769 ms. This possible small cost is retained explicitly, not described as a proven wash or speedup. The retention rationale is fixing normal asynchronous correctness diagnostics and removing fragile conditional/cooperative graph machinery, enabling the previously blocked CPU lifetime-capacity experiment N20. Further performance qualification must include idle.

`metrics.json` records complete-step command/combined-physics-and-stress/completion means and initialization. The combined physics stage cannot identify stock PhysX versus destruction cost. Detailed restored-stage measurements remain in the 52-case matched report; this capture is not a new kernel profile.
