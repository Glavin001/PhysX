# Shared multilevel bond responses — rejected from production

The experiment computed each live bond's unscaled response once in persistent GPU scratch and shared it between endpoint gathers. It covered both residual application and retained-factor coarse correction. No nonzero coupling, original residual check or numerical tolerance was removed.

The initial version passed the independent dense V-cycle oracle, symmetry, repeatability and native analytic/3D/motion suites, including the cycle fixture with 100,000 nodes / 199,997 bonds. Focused shared-support racecheck (24 nodes / 33 bonds) and self-edge memcheck (2 nodes / 1 bond) passed. The final screened version additionally skipped terminal components' unused producers; that final version was not fully requalified because performance rejected it first.

With the new cycle enabled in the native small-component solver, the instrumented gravity-only test of 256 intact buildings (113,664 chunks, 229,376 bonds; no rigid-body response, projectile, damage or correction) converged in 40 iterations, but first-solve submission/completion cost was 51.290720 ms. This is not a whole-simulation timing. Later warm solves required one and zero iterations. The existing polynomial implementation's archived screening fixture was substantially cheaper; no matched full-scene performance gain was established, so no bombardment or frozen-wall campaign was justified.

Compiled diagnostic component kernel: 154 registers per thread, 6,712 bytes shared memory and 48 bytes stack. That resource footprint and timing do not identify a hardware-counter bottleneck. Persistent flux storage adds 48 bytes per allocated bond per hierarchy level, approximately 176 MB for this 16-level fixture, which is another cost. No source/runtime change is retained from the experiment.

The patch is based on bffeb767. Source equations and CPU orchestration were not changed. The native runtime stayed on the previously qualified warm-start implementation throughout. The next candidate should avoid this deep hierarchy's traversal cost while providing stronger component-local preconditioning.
