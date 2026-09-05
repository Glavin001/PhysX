# GPU load recurrence after quiet frames

This is a fidelity correction, separate from moving stress into the PhysX scene.
The node-space GPU solver retained the previous solve's squared-gradient scalar.
After an impact followed by quiet frames, that scalar could become subnormal.
On the first iteration of a new load, `new / previous` could overflow; multiplying
that infinite coefficient by the freshly zeroed direction vectors produced NaNs.
The solver then retired the loaded island and could report convergence while its
bond forces remained near zero.

The first recurrence coefficient is now explicitly zero, matching the existing
bond-space solver's first-iteration restart. Subsequent iterations and physical
loads, material laws, tolerances, damage accounting, and replay settings retain
their existing behavior. This does not add any simulation passes.

The independent `gpu_quiet_load_test` applies an impulse-like load to a supported
two-node graph, lets it relax for 26 quiet frames, then applies rotated gravity.
Before the fix, both blocking and asynchronous node-space solves returned forces
near `1e-20` for an approximately 19.62 N load. Bond-space solving passed the same
fixture. After the fix, all four variants pass the same `2e-4` relative force
assertion: default node-space, bond-space, deterministic reductions, and unrolled
CUDA graph execution.

The complete native suite after this change and scene integration passes 35/39;
the four recorded baseline failures remain. This fix changes responses in the
previously incorrect regime, so earlier recorded demo timings/trajectories are
historical results, not qualification of the corrected engine.
