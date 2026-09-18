# Interpretation of the after-shot replay

This is a separate instrumented replay of the existing downtown three-projectile tape, **27 buildings / 24,105 chunks / 74,543 bonds, 600 steps / 10 simulated seconds**, not an exact replay of the user's firing history. No production code or physical settings changed.

The slowest non-fracture step after startup is tick **200**: complete advance **119.804 ms**, of which the CUDA stress interval is **118.113 ms**. It has 29 fragments / 25 awake, 2 projectiles, 469 broken bonds, 109 maximum stress iterations and **no correction**. [Raw selected step](nonfracture-peak.json).

The [generated fracture-peak report](report.md) selects tick 199 at 726.794 ms. Actual rigid-body replay is 1.500 ms. Explicitly timed CUDA stress is 193.649 ms, but large enclosing host scopes (accept-corrected-step and other trial work) remain insufficiently subdivided. They may contain additional GPU work/waits; they are **not evidence of hundreds of milliseconds of CPU calculation**. The GPU stage table must not be treated as complete attribution of that peak.

The evidence prioritizes active stress solving and fracture-time stress/hierarchy work. Idle reuse alone cannot address a step with changing contact loads and active fragments. Before selecting another kernel change, attribute the remaining enclosing scopes and identify which stress components require the expensive iterations. Do not loosen convergence or omit fracture/correction work.
