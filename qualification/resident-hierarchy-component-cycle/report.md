# Component-local resident stress cycles

✅ The sparse cycle operations now share a scheduling policy. A cooperative grid can process a large component; an independent thread block can process its own component using the same equations and scratch ranges. Restriction, smoothing, retained-factor correction and terminal solves remain on the GPU. No host iteration or numerical transfer was added.

✅ Fixed boundary vectors are no longer read and multiplied by zero by the level operator. This removes an unnecessary cross-component read dependency. Fine observation outputs for fixed/omitted rows are still explicitly zero.

✅ Three correctness suites pass. Block-local M and M² match cooperative outputs byte for byte for every checked RHS and every small-fixture basis coordinate, across all original topology transitions. The largest comparison uses 100,000 stress nodes and 199,997 bonds. It deliberately exceeds the native block-owned component threshold of 1,024 nodes to check numerical equivalence; it does not establish a recommended launch size or simulation speed.

✅ Focused CUDA safety passes: memory/leak checking on the 100,000-node/199,997-bond fixture; synchronization and race checking on the 24-node/33-bond shared-support fixture. These check the first cycle transition while replaying the full six-transition topology sequence and rejection checks. The complete new safety matrix has not been rerun; the prior cooperative snapshot's complete audit is recorded separately.

🚧 The native production solver does not yet call this cycle. Binding normalized persistent geometry, attaching hierarchy updates to the native topology transaction and invoking the squared cycle inside resident CGLS remain. No production performance improvement or 8 ms gate is claimed. The unchanged production binaries retain the frozen wall result recorded in the preceding cycle qualification.

Evidence: [validation and source hashes](validation.json), [full numerical checks](correctness.log), [memory](memcheck-large.log), [synchronization](synccheck-supported.log), [races](racecheck-supported.log).
