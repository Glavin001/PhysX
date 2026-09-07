# Per-thread resident diagonal solve — qualified improvement, incomplete plan

A six-variable Cholesky solve now runs in one CUDA thread for small native
components. The arithmetic order and double precision are unchanged. Independent
operator tests compare every output bit against the previous warp implementation;
those checks and the original native analytic regression pass.

The separately measured 256-building bombardment has 113,664 chunks, 229,376 bonds,
256 projectiles, timestep 1/60 second, correction limit one, and sleep disabled.
Two three-second untraced runs retain all 180 steps each. Complete-step means fell
from 120.537 / 120.239 ms to 21.453 / 21.621 ms; peaks fell from
263.274 / 255.352 ms to 68.424 / 70.349 ms. Every recorded non-timing counter
matches the preceding candidate across all 180 steps in the first repeats.
Separate CUPTI captures show mean componentStressSolve execution falling from
110.218 ms to 12.465 ms. This recovers much of a prior regression; it does not
establish a win over older production baselines or pass the 8 ms gate.

[Generated detailed report](../thread-diagonal-impacts-256/report.html)
contains complete-step accounting, GPU execution versus waits, launch counts,
physical workload counters and peak-step context. The preceding capture is
[also retained](../pivot-local-impacts-256/report.html).

The frozen 10-second one-projectile wall audit (444 chunks / 896 bonds) passes:
398 supported chunks, 46 detached, 199 broken bonds, identical topology signature,
entry and exit holes, COM continuity, and collision/render agreement. It is a heavy
quality audit, not a timing qualification. See wall-quality.json.

Memory and synchronization sanitizers pass the native analytic suite (up to
131,072 nodes / 98,304 bonds). The independent larger 3D tests still fail and
racecheck terminates abnormally; neither is a pass. Logs and observed exit codes
are retained in validation.json. No tolerances or iteration caps were loosened.

The test-only phase probe uses the intact wall graph and gravity input with no
projectile, physics, damage or correction. It partitions summed CTA clock cycles,
not additive multi-SM elapsed time. Instrumentation compiles out of production.
The probe's initial solve converges in 86 iterations; unchanged warm inputs need
zero iterations. This does not justify skipping changing real simulation loads.

Next: remove the same warp scheduling bottleneck from multilevel smoothing,
qualify its sparse operators, and measure whether fewer iterations win overall.
Resolve the existing 3D and racecheck failures, then finish GPU ownership and
correction scheduling and the full timing/endurance campaign.
