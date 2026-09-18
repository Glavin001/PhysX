# Audited complete-step snapshot comparison

All **52 scenarios / 2,080 full ticks** pass: 20 candidate samples and 20 total
controls per case (10 before, 10 after), fixed saved inputs, no profiler, restore
and validation outside the tick timer. The audit checks input, binary and loaded
module hashes; raw sample counts; phase-time conservation; physical comparisons;
convergence/completion, correction/evaluation limits; and all repeatability gates.
Every structural and 11,100 / 28,416 / 113,664-chunk city case is preserved in
report.json/report.md. Physical receipts retain exact state/load hashes, numerical
force differences at the existing bound, and unchanged rigid-state error limits.

The candidate's complete 20-sample suite uses 1,051.10 s of harness wall time:
58.6884 s of measured ticks and 579.4125 s of excluded restore. Combined controls
use 60.0106 s of measured ticks and 581.3357 s of excluded restore. These suite
sums are **not a game-workload speedup**, and shared-GPU control drift prevents
claiming an overall or peak gain. Context startup, observation, validation and
teardown occupy the remaining harness time outside the tick metric.

The chain256-warm combined-control interval initially suggested a slowdown while
its two controls drifted (7.571 versus 6.456 ms). An independent equal-sized
20/20/20 confirmation passes physical comparisons and is neutral: candidate
7.237 ms versus controls 7.323/7.180 ms; descriptive saved-time interval
[-0.486, 0.505] ms. Preserve both cohorts; the original data was not removed.

These results support the fix's snapshot correctness and show mixed performance,
not a universal speedup. The planned continuous ordinary/sleeping 600-tick
idle/heavy comparison is still required before runtime retention. The original
runtime, installed SDK and best N13 performance artifacts remain preserved.
