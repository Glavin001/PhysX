# Native topology view for the six-channel solver

`PxgDestructionElasticGraph.cuh` joins an authored six-channel graph to
`PxDestructionTopologyDeviceView`. It uses native bond liveness in place; it does
not copy the large coefficient/history records on each fracture. Operator action,
RHS construction, diagonal preparation, recovery, component construction and PCG
all honor the same frozen mask.

## Inputs and lifetime

Numerical positions, interface points/frames, SPD coefficients, inelastic history
and adjacency use authored chunk/bond order. They must be supplied by the numerical
geometry/material producer. The native endpoint pair must match in order, preserving
the signs of force/moment and inelastic history. Every authored `Bond::live` is one
in this native binding; native `activeBonds` alone represents deletion. Standalone
graphs without a native mask retain their existing `Bond::live` behavior.

Native support flags become whole-node constraints. An inactive chunk is omitted
from the unknown set, and validation requires every incident bond to be inactive.
Thus omission introduces no artificial anchoring. Supported active chunks can
still contribute prescribed reactions and material response even when the unknown
component count is zero. Partial constraints remain unsupported by this binding.

All arrays and the native topology are frozen from preparation until every
consumer finishes. Caller-owned output capacities equal the authored node count;
adjacency capacities follow the fine graph contract. This header does not own
allocations, stream dependencies or physical publication. Mutation while a graph
is in use violates the contract, even if another stream changes only its mask.

## Producer versions and errors

Call `build` at an explicit edit boundary. Scene identity/lifetime, geometry,
stiffness, supports and layout versions are nonzero producer revisions. Native
topology generation, including zero, is read on the device. Advance the applicable
versions before changing data or replacing allocations; a support release can
join unknown systems even without adding a bond. Pointer lifetime/layout changes
must not reuse old setup keys.

`State::ready` and `State::error` describe preparation. `gate` checks those fields,
the current native topology generation/errors and the expected producer revisions.
Its expected key's topology field is unused: native device status is authoritative.
The gate error must feed component construction and the downstream load/RHS/solver
error chain. A host submission error also aborts the chain. Zero components after
rejection never mean a successful empty solve.

Pass `&state->key` to the optional device-key argument of
`Elastic::Partition::build`. The native key then reaches setup without reading a
topology generation or component count on the CPU. Rebuilds currently cover the
whole authored graph; the caller must schedule them on edits. General event-driven
runtime ownership and selective affected-component revisions remain unfinished.

## Qualification limits

The [native graph checks](../../qualification/elastic-native-graph-20260910/README.md)
exercise this binding through the GPU component builder and PCG on independent
small equations. Four existing city captures validate native topology mapping,
including the first correction and a later heavily fractured state. Their geometry
uses captured chunk centers; their SPD interface coefficients are explicitly
algebra-test inputs, not calibrated engine materials. They produce no new material
verdict and do not rerun native physics.

The installed runtime still invokes the legacy stress solver. Next join the live
geometry/material owner and complete load/command interval with these numerical
views, then implement accepted/trial material transactions and physical correction.
The existing CPU fragment/contact registration prerequisites remain. No complete-
step speedup or migration physical-equivalence qualification is established here.
