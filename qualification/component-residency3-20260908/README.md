# Rejected three-block resident scheduling

The candidate constrained componentStressSolve to three resident 256-thread blocks per SM and sized its work queue using the compiled occupancy limit. Registers fell 94 → 80, stack grew 48 → 64 bytes. These compiler limits do not measure actual occupancy or prove a latency bottleneck.

Three numerical suites and exact frozen wall pass. [Matched 256-building destruction screen](shots/report.md): 113,664 chunks / 229,376 bonds / 768 physical projectiles / 600 steps each. Relative to the accepted shared-normalization version, mean worsens 45.181 → 46.793 ms and complete fracture peak 133.936 → 139.979 ms. [Pristine idle](idle/report.md) also does not improve. Rejected and reverted before further tests/deployment. No physical thresholds or assertions changed.
