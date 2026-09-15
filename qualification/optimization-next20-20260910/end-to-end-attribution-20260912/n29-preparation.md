# N29 exact current-component solve reuse — unqualified candidate

Isolated source commit `91c27a12b5ea5ec308cfe9187a40a84f1b978bd6`, parent selected N13+N20
`13b11af2e0aeabf4e0070931fbd8a060f383dfaf`. Main source/index and installed SDK
are unchanged. This is written code, not a retained optimization. Runtime and
oracle consumers now compile successfully; numerical tests and timing are still
pending. The [build receipt](n29-build.json) supersedes the deferred build status
below. Source files and exact hashes are in
[n29-preparation.json](n29-preparation.json).

## Current-input equivalence contract

Only active, non-settled, positive-threshold, fully anchored problems fitting
the existing component solver are eligible. The native hierarchy/motion and
operator-generation certificates must be valid. Free components, large cooperative
components and exact-zero special handling keep their original execution.

The ordered comparison covers every component-local node and authored CSR slot,
including dead-slot structure, endpoint orientation, mapped dynamic neighbors,
prescribed-boundary inertia, offsets, live health, scale and warm bond forces.
It also compares original RHS, reconstructed current residual, convergence
threshold and starting active/converged flags. The actual FP64/rounded inverse
coefficients and arithmetic guard choice are compared after their original
cache builder runs. Only the hash is approximate; aliasing requires complete
bitwise comparisons, including on forced collisions in the new test.

All components use the same invocation's iteration cap and warm-start policy.
Node correction and Krylov directions are reset before this boundary. Anchored
projection has zero dimension; the zero-load impulse-mutating path is excluded
by the positive-threshold condition. Numerical recurrence and reduction order
remain the original retained implementation, using matching local node order.

The GPU chooses the first exactly matching earlier component, runs the original
solver for leaders, then scatters the defined correction, residual and status
in a later stream-ordered kernel. No cross-CTA spin wait, host count readback or
previous-tick result is involved. Disposable scratch is not copied: some is
uninitialized on zero-update solves. Original force recovery and each component's
material/damage evaluation remain after scatter. Private workspace is rebuilt
on physical restore and is never serialized as physical state.

This source reasoning still requires executable proof. The18 new cases test
matching components plus changed RHS/residual/warm values/threshold/operator,
CSR order, cached coefficients, arithmetic choice, sleeping/free/inactive/zero
states, nonfinite data, forced hash collision and scatter mapping. They have not
run yet. Original native numerical and integrated physical gates remain mandatory.

## Sequencing and acceptance

Build coordinator884278/session40450 waits for existing collector390717 to exit
with all52 ordinary cases complete. It performs CPU builds only; no GPU screen
is launched automatically. Restoration watcher338813 remains unchanged. The
control source exactly matches the prior plain N24 control, so its verified
runtime is reused, while candidate consumers are rebuilt.

Exact commands: `out/n29-exact-component-reuse-20260912/build.py` and
`build-oracles.py`, orchestrated by `build-after-counters.py`. Do not run these
again over existing outputs or start an overlapping build during collection.
Check the live coordinator and manifests. Then use the unchanged seven-case
matched full-tick screen; any finalist needs all52, asynchronous memory checks
and continuous ordinary/sleeping trajectories. Restore stays outside tick time.
