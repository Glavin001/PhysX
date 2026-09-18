# Rejected fused GPU sleep transaction

Production experiment reverted; never deployed. One paired 256-building screen (113,664 chunks, 229,376 bonds, 768 physical projectiles, 600 steps/10 simulated seconds) plus fresh intact idle does not show an end-to-end gain. Complete means 44.726 → 47.453 ms; destruction peaks 137.744 → 137.112 ms; all-step peaks 159.467 → 164.915 ms. The narrower native physics peak worsened 124.938 → 125.531 ms. See [shots](shots/report.md), [idle](idle/report.md), [diagnostic phases](profile/report.md).

The original diagnostic tick 48 contains 6,345 sleepCommit scopes, mostly never-uploaded fragment placeholders: accepted-step sum/union 4.929 ms, median 0.000742 ms. The candidate still has 6,345 scopes: accepted-step sum 4.842 ms, median 0.000742 ms. This is not one 4.9 ms GPU sleep transaction. Fusion attacked the wrong work; remove initial placeholder notifications instead. Do not add summed parallel CPU durations to wall time.

Nine ordinary lifecycle tests, frozen 444-chunk/896-bond wall, every-tick 256-building GPU/CPU audit and compound sleep CUDA memcheck passed. The new compound test also passes baseline and remains independently useful. It checks 513 rotated/offset colliders and a quiet 2-chunk/1-bond native asset. Initial test setup omitted optional acceleration-history allocation and failed baseline too; enabling that documented scene option fixed the test. No assertions were loosened.

Raw module pair, commands, attestations and samples: out/native-sleep-commit-20260908/screen-2. Production patch and private kernel are archived here. Not endurance, real time or historical external-backend parity.
