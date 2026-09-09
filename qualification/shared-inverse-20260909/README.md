# Rejected resident inverse-coefficient cache

Candidate: copy the ten FP64 coefficients for each component of at most 512 nodes into a 40 KiB shared cache once, only on iteration one if the solve needs it; reuse that cache throughout the component recurrence. No neighbor-index mapping, new host work, precision changes, tolerance changes or different arithmetic. Larger components retain the same global coefficients. Compiled resources: 96 registers / 48-byte stack / 41,528 shared bytes versus baseline 94 / 48 / 568. The eager-copy precursor was compiled but not timed; the qualified candidate is lazy.

Correctness passed: three resident numerical suites, 771 independent physical blocks, cache equality for reordered IDs and 1/257/512/513/771-node sizes, complete polynomial basis equality, CUDA memcheck, nine ordinary native lifecycle tests, compound sleep memcheck, exact 444-chunk/896-bond/one-projectile frozen wall, and heavy every-tick GPU/CPU mapping audit for the 256-building workload. No assertions or physical settings were weakened.

The first pair was inconclusive (complete loaded peak 154.816 → 140.555 ms, mean 46.023 → 50.279 ms). A follow-up isolates shared-capacity cost: the control uses exact baseline arithmetic/source and reserves 40,960 unused dynamic shared bytes per component block, equal to the cache's added capacity. This is a diagnostic target only, never production.

Follow-up, **256 buildings / 113,664 chunks / 229,376 bonds / 768 physical rounds / 600 steps (10 simulated seconds) per run**, identical commands, Direct GPU off, sleeping on, one correction maximum:

- Baseline before/after: complete mean 44.718 / 44.372 ms; loaded peak 135.694 / 135.824 ms.
- Capacity-only control: mean 48.727 ms; loaded peak 140.635 ms.
- Cache: mean 49.805 ms; loaded peak 143.359 ms.

Each arm also has a fresh intact-idle run; startup spikes remain included. Reserving shared capacity itself is costly here; caching does not recover that cost. This supports rejecting this cache, not a proved bandwidth/compute/occupancy bottleneck or a guaranteed hardware-counter explanation. All source/test cache edits are reverted and archived in rejected.patch. No live deployment. No end-to-end or historical external-baseline performance win.

Raw artifacts and exact mapped module receipts: out/shared-inverse-20260909/{screen,capacity-screen}. Capacity control source is isolated under capacity-control-source; production has no diagnostic execution switch. The previous eager precursor and final lazy modules are independently preserved under out/vibe-coarse-assembly-20260908.
