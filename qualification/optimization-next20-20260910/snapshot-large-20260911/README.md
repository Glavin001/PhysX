# Large native scene snapshot campaign

This is the **24-case city expansion**. The original structural cases remain in the [complete 52-scenario catalog](../snapshot-scenarios.md), now measured with the same independent one-tick protocol in a separate campaign.

Each sample restores the same physical file and runs one complete tick, including current physics, stress, at most one correction, second stress and accepted publication. Source histories use the original native benchmark and unchanged ordinary A/B settings. Restore/setup and output validation are separate from tick time. No solver/contact caches are serialized. Shared GPU; these are descriptive fresh-restored timings, not gameplay speedups or matched candidate comparisons.

Measured ticks total **54.46 s**. Restoration totals 551.07 s and is **excluded** from every full-step sample. Context/process setup, validation, teardown and harness overhead account for the remaining 415.12 s of summed replay harness time.

**24/24 scenarios produced all requested samples; 15/24 pass the strict repeatability gate.** Failed cases retain diagnostic timings. Source capture, correctness screens and sanitizers are excluded from the replay wall total (1020.64 s).

Repeatability is distinct from memory and physical-equivalence qualification. See [investigation and validation limits](investigation.md), including the large-case sanitizer failure on both the updated and saved pre-fix runtimes.

| Scenario | Chunks / bonds | Input clusters | Ticks measured | Output comparison | Mean / peak full tick ms |
|---|---:|---:|---:|---|---:|
| city25-intact-idle | 11100 / 22400 | 25 | 20 | PASS | 11.113 / 21.975 |
| city25-airborne | 11100 / 22400 | 25 | 20 | PASS | 12.107 / 18.479 |
| city25-initial-impact | 11100 / 22400 | 25 | 20 | PASS | 44.796 / 53.138 |
| city25-post-impact | 11100 / 22400 | 526 | 20 | FAIL: bond-health equality | 24.240 / 33.632 |
| city25-cascading-fracture | 11100 / 22400 | 600 | 20 | PASS | 40.561 / 52.502 |
| city25-fragmented-loaded | 11100 / 22400 | 1282 | 20 | PASS | 55.292 / 68.102 |
| city25-late-debris | 11100 / 22400 | 1488 | 20 | FAIL: bond-health equality | 72.481 / 90.525 |
| city25-ten-second-debris | 11100 / 22400 | 1683 | 20 | FAIL: bond-health equality | 74.306 / 87.830 |
| city64-intact-idle | 28416 / 57344 | 64 | 20 | PASS | 18.986 / 25.729 |
| city64-airborne | 28416 / 57344 | 64 | 20 | PASS | 19.901 / 23.106 |
| city64-initial-impact | 28416 / 57344 | 64 | 20 | PASS | 68.260 / 91.882 |
| city64-post-impact | 28416 / 57344 | 1320 | 20 | PASS | 40.462 / 54.142 |
| city64-cascading-fracture | 28416 / 57344 | 1460 | 20 | PASS | 62.321 / 76.200 |
| city64-fragmented-loaded | 28416 / 57344 | 3010 | 20 | FAIL: bond-health equality | 97.738 / 128.962 |
| city64-late-debris | 28416 / 57344 | 3957 | 20 | FAIL: bond-health equality | 148.717 / 176.702 |
| city64-ten-second-debris | 28416 / 57344 | 4565 | 20 | FAIL: bond-health equality | 106.140 / 128.426 |
| city256-intact-idle | 113664 / 229376 | 256 | 20 | PASS | 69.177 / 85.129 |
| city256-airborne | 113664 / 229376 | 256 | 20 | PASS | 75.031 / 84.846 |
| city256-initial-impact | 113664 / 229376 | 256 | 20 | PASS | 260.453 / 288.678 |
| city256-post-impact | 113664 / 229376 | 5204 | 20 | PASS | 149.502 / 172.789 |
| city256-cascading-fracture | 113664 / 229376 | 5827 | 20 | PASS | 210.019 / 242.847 |
| city256-fragmented-loaded | 113664 / 229376 | 10905 | 20 | FAIL: bond-health equality | 323.701 / 363.873 |
| city256-late-debris | 113664 / 229376 | 12214 | 20 | FAIL: bond-health equality | 463.076 / 502.288 |
| city256-ten-second-debris | 113664 / 229376 | 14795 | 20 | FAIL: bond-health equality | 274.528 / 357.086 |

[Timing spread, restore costs, budget misses and active work](timings.md). Every source hash, raw path, failure log and sample statistics are in [catalog.json](catalog.json).

The ten-second debris state is not assumed asleep or converged to rest. Fixed source-step names describe historical events; actual restored bond/correction counters describe the measured work. Continuous warm city trajectories remain necessary to evaluate normal gameplay cache reuse.

## Restored versus uninterrupted source context

These are separate execution histories. Restored and uninterrupted paths produce different fracture verdicts; the cause and physical significance are not yet qualified. Independent-restore success does not establish equivalence to uninterrupted gameplay. No exact-continuation requirement is reinstated here, and these differences are not hidden as speedups.

| Scenario | Source → restored new broken bonds | Source → restored output clusters |
|---|---|---|
| city25-intact-idle | 0 → [0] | 25 → [25] |
| city25-airborne | 0 → [0] | 25 → [25] |
| city25-initial-impact | 2824 → [3412] | 526 → [537] |
| city25-post-impact | 0 → [0] | 526 → [526] |
| city25-cascading-fracture | 9 → [10] | 609 → [610] |
| city25-fragmented-loaded | 1 → [100] | 1283 → [1321] |
| city25-late-debris | 0 → [1424] | 1488 → [2063] |
| city25-ten-second-debris | 0 → [184] | 1683 → [1776] |
| city64-intact-idle | 0 → [0] | 64 → [64] |
| city64-airborne | 0 → [0] | 64 → [64] |
| city64-initial-impact | 7247 → [8760] | 1320 → [1364] |
| city64-post-impact | 0 → [0] | 1320 → [1320] |
| city64-cascading-fracture | 12 → [13] | 1472 → [1473] |
| city64-fragmented-loaded | 11 → [425] | 3010 → [3144] |
| city64-late-debris | 0 → [2768] | 3957 → [5130] |
| city64-ten-second-debris | 0 → [202] | 4565 → [4705] |
| city256-intact-idle | 0 → [0] | 256 → [256] |
| city256-airborne | 0 → [0] | 256 → [256] |
| city256-initial-impact | 28596 → [34802] | 5204 → [5417] |
| city256-post-impact | 0 → [0] | 5204 → [5204] |
| city256-cascading-fracture | 23 → [25] | 5850 → [5852] |
| city256-fragmented-loaded | 24 → [1229] | 10910 → [11382] |
| city256-late-debris | 80 → [11051] | 12248 → [16135] |
| city256-ten-second-debris | 0 → [819] | 14795 → [15187] |
