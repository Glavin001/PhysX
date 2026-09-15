# GPU motion partition for the six-channel load adapter

`physx/source/gpudestruction/src/PxgDestructionElasticPartition.cuh` converts the
native topology's active authored chunks into the compact arrays consumed by the
[physical load adapter](elastic-load-adapter-contract.md). It runs on the GPU and
retains its outputs across matching revisions. It is exercised in the isolated
native pre-stress capture and in the device-to-device replay; the installed
engine still uses its existing stress backend.

## Ownership and layout

The source is `PxDestructionTopologyDeviceView`, the current runtime stress-chunk
bindings and canonical double positions in authored order. All belong to the
same frozen evaluation. Native ordered chunks contain a live prefix grouped in
packed runtime-cluster order, followed by inactive chunks. Packed cluster index,
authored root, stable motion slot and slot generation must agree. Slot addresses
are not interchangeable with packed motion indices.

The resulting `Groups` covers complete physical motion aggregates, including
supported chunks. It is **not** a numerical stress-component partition and does
not prescribe solver/factor reuse through eliminated supports.

For each active authored chunk, the producer publishes:

- Authored-to-fine and fine-to-authored maps; inactive authored IDs map to invalid.
- A compact stress-chunk record, full physical mass/inertia and the exact canonical
  position, without rounding or reconstructing it from the legacy float origin.
- Contiguous group boundaries, identity node order and inverse local offsets.

Counts remain inside device `State::groups`. `DeviceGroups` lets validation,
load conversion and receipt gating read them there. Launches use allocated
capacity bounds; no active-count readback is needed to submit the pipeline.
Diagnostic output readback must copy only initialized active prefixes, never
unused capacity. Arrays of authored inverse IDs are initialized for all authored
chunks; compact tails have no meaning.

## Versions, state and lifetime

Zero-initialize `State` once. Supply caller-owned pointer capacities as documented
in `Storage`; `starts` has capacity+1 entries and all other arrays have capacity.
Source arrays, writable output arrays and `State` must not overlap; this is not
an in-place compaction algorithm.
Order `begin`, `clear`, `pack`, `ranges`, `validate`, `finish` on one stream.
After `finish`, gate downstream use through `gate` and propagate that same error
into the adapter/RHS/solver chain. A failed producer publishes zero usable counts
and an invalid receipt; empty launches alone do not certify a valid empty scene.
A valid all-deleted scene and a valid zero-capacity scene are supported.

Identity includes nonzero scene/configuration, canonical-geometry and physical-
mass revisions, plus the native topology generation (which may be zero).
Changing authored support/mass properties changes the mass revision. Replacing a
configuration changes the scene revision. The producer owns these revisions;
this code does not hash every chunk to discover unreported changes.

Reuse requires a ready error-free state, matching revisions/counts and identical
output allocations. Pointer replacement invalidates reuse even when revisions
match. Native topology errors invalidate a cached state. Successful preparation
increments `builds`; failure or counter exhaustion does not publish readiness.

Source arrays and output state must remain frozen until their consumers finish.
For a separate solver stream, use its completion/event dependency before reusing
or overwriting the arrays. The standalone state object does not own that runtime
lifetime or allocate buffers itself.

## Loads and remaining integration

`scatter` maps the frozen authored surface loads and optional additional wrenches
through the retained mapping. Surface torque stays about the legacy stress-chunk
origin; additional torque stays about the canonical origin. The adapter performs
its existing origin transport. An absent additional array means explicitly zero
additional wrenches for that query.

This topology receipt does **not** certify contact completeness, the applied-
command ledger, an impulse duration, prescribed-motion acceleration or correction
history. These require a separate live input producer receipt. In particular,
`captureRigidState` is called both before the trial solve and after corrected
motion; the latter snapshot cannot be treated as original input acceleration.

The isolated native capture uses immutable authored geometry/mass and resets its
partition owner when the runtime is cleared. Its revision constants are valid
for that diagnostic fixture, not a general implementation of scene edit tracking.
The offline replay's completeness remains limited to its stated surface-plus-
gravity case. It publishes no new fracture/material verdict.

Current rebuilds pack the entire configured topology on a revision change.
Retained mappings skip array traversal, but still launch capacity-sized guarded
kernels. This is not the final selective-component or zero-traversal idle path.
A full runtime owner should use producer-owned dirty components and conditional
scheduling, and must attach the resulting layout identity to numerical setup
keys. Fine bond/material conversion, stress-component keys and accepted
trial/correction transactions remain pending.

[Current validation, live captures and counters](../../qualification/elastic-partition-20260910/README.md).

The [native graph binding](elastic-native-graph-contract.md) now supplies deletion
and support state to the numerical graph in authored order. Its unknown partition
is separate from this physical motion partition. A live owner must join these
layouts and their complete load/material interval; numerical mapping readiness
does not make that interval complete.
