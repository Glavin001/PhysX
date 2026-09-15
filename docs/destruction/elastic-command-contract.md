# Explicit chunk-command evaluation

`PxgDestructionElasticCommands.cuh` converts a frozen, authored-chunk-targeted
command batch into two consistent outputs: asset-frame wrenches about canonical
fine-node origins, and world-frame wrenches about physical motion COMs. It runs
on the GPU using the current [active partition](elastic-partition-contract.md).
This is a numerical producer, not yet a public command submission/application
API. The installed V14 runtime does not invoke it or clear its unapportioned-load
correction guard.

## Physical meaning

Each command supplies an authored chunk ID, a world application point, a world
force and a free world couple. `Units::Impulse` instead supplies linear/angular
impulses divided by the batch's explicit positive loading interval. Force-valued
commands are not divided again. Multiple commands on the same chunk add; an
empty batch explicitly removes the previous command loads.

For asset-to-world frame `(R,o)`, canonical node position `x`, point `p`, force
`F` and couple `T`, the node output is:

`F_asset = R^T F`

`T_node = R^T T + (R^T(p-o) - x) × F_asset`.

Body aggregation sums node forces and `T_node + (x-C) × F_asset`, then rotates
the totals to world axes. `C` is the supplied physical aggregate COM in asset
axes. It must belong to the same frozen ownership/mass/frame snapshot; the
native producer remains responsible for supplying it correctly. No unknown
application point, per-chunk force distribution or support reaction is invented
from native acceleration accumulators.

The caller owns time sampling of points, wrenches and frames. This evaluator
does not choose follower-load semantics, reconstruct an impulse already folded
into velocity, or certify that a frozen world point matches a native integration
interval. Native submission and trial/correction sampling must be defined and
qualified before applying these outputs to rigid bodies.

The batch carries tick, original input generation, command generation and loading
duration. A query additionally identifies current ownership and evaluation 0/1.
The same batch can be evaluated against a split partition without cloning its
parent's aggregate wrench onto every child. Re-evaluation is pure: it does not
apply impulses, advance material history, or establish exactly-once physical
command execution.

## Device ordering and rejection

Run `begin → clear → resolve → scatter → aggregate → inspect → finish → gate`
on one stream. Inputs and capacity-bearing storage stay immutable throughout.
`aggregate` uses exactly 128 threads per block, one block per motion group;
other kernels use guarded element ranges. Consumers must check the receipt
against their expected query; outputs from any rejected receipt are unusable.

Generation/partition mismatches, insufficient capacity, inactive/invalid chunks,
unknown units, invalid frames and nonfinite or overflowed wrenches reject.
Resolve validates all commands before scatter can publish any contribution.
Chunk scatter uses FP64 atomics; body totals use grouped block reductions,
avoiding global atomics shared by all commands on a building. Duplicate-command
summation order is not promised bitwise deterministic for arbitrary batches.

The command receipt does not set the load adapter's full-ledger completeness
assertion. Contacts, gravity, damping, locks, prescribed motion and any other
native channels still require their own accounting. Ordinary body force/torque
totals cannot reconstruct where forces acted: opposing chunk forces can yield
zero rigid resultant and nonzero structural response.

## Native scheduler prerequisite (private ABI V13)

`PxgDestructionRuntime::wakeCommandOwners` forwards a compact list of current
native body IDs to the ordinary actor scheduler between accepted steps. The
allocator validates the entire list first, completes pending GPU sleep writes,
then wakes dynamic owners. Kinematic supports remain kinematic. Duplicate IDs
do not duplicate wake notifications. Null nonempty batches, stale/deleted IDs,
disabled actors and calls during simulation reject. This private operation does
not apply forces or expose a new public command submission API. The future
producer must preserve current ID lifetime and serialize normal scene writes.

Pending sleep completion clears native velocity/force storage, so it must finish
before a producer applies a new command. Ordinary CPU input upload can also
replace velocities/accelerations: a future GPU command writer belongs after
that upload and before the original input checkpoint, ordered on the native
stream. Waking alone does not establish that application boundary.

The native regression uses **ordinary API** force/torque controls. In the
correction-enabled path, `Sc::BodySim::updateForces` submits velocity deltas;
`updateBodyExternalVelocitiesLaunch` folds them into velocity before the original
checkpoint. They must not be applied again from an inferred acceleration. With
correction disabled, enabling optional body-acceleration reporting instead
retains acceleration accumulators at that boundary. The test checks both exact
representations and their resulting impulse, with TGS and PGS. Direct GPU force
writes are a third, separately tested input route and cannot define ordinary API
expectations. Aggregate native inputs still cannot reconstruct chunk application
points or certify the full structural load ledger.

## Native pre-addition history (private ABI V14)

`commandInputHistory()` supplies sparse `PxgDestructionCommandInput` records
from correction-enabled ordinary native uploads. The producer is called inside
`PxgSimulationCore::updateBodies`, after body initialization/property upload and
immediately before `updateBodyExternalVelocitiesLaunch` adds velocity deltas.
Each 64-byte record carries body ID, upload flags, exact pre-addition linear and
angular velocities, and the submitted linear/angular deltas. Kind zero is an
upload without an additive velocity command; kind one is valid; kind two marks
an invalid source. A 16-byte device status provides count, input generation and
error bits. Consumers wait on the original checkpoint ready event and require a
matching generation and zero status error before using valid records.

This avoids trying to recover a small initial velocity by subtracting a large
rounded delta. It writes only the uploaded list, with retained geometrically
grown storage; there is no new full body-pool checkpoint copy. A corrected-motion
refresh retains the history, the next original input boundary replaces it, and
clear invalidates it. Borrowed-reader lifetime rules match the original checkpoint.

The record is command-free **relative to that ordinary additive upload**, not a
complete command-free scene snapshot. Direct GPU commands, spatial application
points, force/impulse modes and the physical interval must still be supplied by
an authoritative producer. Non-additive host velocity uploads are not relabeled
as invertible force histories. Body IDs join the same generation's original
chunk ancestry; they must not be mistaken for current recycled fragment IDs.
The production correction still uses its existing checkpoint and rejection guard;
this history is not permission to redistribute unknown body-level loads. The
native capture now stamps nonzero ordinary additive commands by body and original
input generation. Both graph and explicit correction preparation inspect that
stamp together with checkpoint accumulators, counting each affected source once.
Zero commands and commands on unrelated bodies do not reject the correction.
Invalid or stale command receipts reject preparation explicitly (error bit 64).
Direct GPU mode without host uploads publishes an explicit empty ordinary history;
its direct force accumulators remain checked.
The stamp buffer grows geometrically and is initialized only on allocation;
ordinary captures touch only commanded IDs, and later generations ignore old
stamps. This closes an ordinary-API guard bypass; spatial replay is still pending.
[Native guard evidence](../../qualification/ordinary-command-correction-20260910/README.md)
records the reproduction, both preparation paths, sanitizer results and unchanged
wall identity, plus the smaller Nsight attachment failure.

[Native capture evidence](../../qualification/elastic-command-inputs-20260910/README.md)
includes native force/torque controls, correction refresh retention, the rounding
counterexample, memory/sanitizer results and hardware counters from both an
actual native scene and a large standalone producer fixture.

## Checked native velocity transaction

`PxgDestructionElasticCommandMotion.cuh` consumes the command evaluator's device
receipt and world/body-COM wrenches. Its checked binding records carry native
body ID, node lifetime and prescribed-support status. It computes native
velocity candidates from current inverse mass and rotated principal inverse
inertia, validates the whole batch, then writes only the two velocity vectors.
Native pose, inverse properties, acceleration accumulators, sleep flags and all
unselected slots remain unchanged. Structural loads on prescribed supports stay
in the command evaluator even though their dynamic response is zero. Infinite
translation mass does not suppress a dynamic body's finite rotational response.

Sequence on one exclusive native stream:
`begin → clearClaims → prepare → seal → apply → commit`.
Duplicate native IDs, stale/deleted lifetimes, invalid support/mass combinations,
nonfinite wrenches or velocity overflow reject before any body mutation. Sparse
claim clearing touches selected IDs only. The caller supplies capacities and
keeps source arrays and native motion immutable throughout the transaction.
History and receipt allocations are mandatory; initialize history once to zero.

An exact duplicate query/native epoch is an explicit no-op. A correction may
follow evaluation zero only with the same tick/input/command generation and
interval, evaluation one and a newer native input epoch. A later trial requires
newer tick/input/command/native epochs. The native producer owns those epochs;
changing a number does not establish physical rewind correctness.

**The correction input must be command-free.** The existing original checkpoint
is post-command, so it cannot simply be restored and receive these deltas again.
The native integration must retain an uncommanded baseline or exactly account
for original command contributions before distributing them to changed owners.
The application interval must equal the evaluator's impulse-normalization
interval and the intended native advance. This transaction cannot infer either
requirement from body velocities. Gravity, damping, gyroscopic integration,
locks, contacts and constraints remain ordinary PhysX work.

[Standalone transaction evidence](../../qualification/elastic-command-motion-20260910/README.md)
uses actual `PxgBodySim` storage, a device evaluator handoff and an explicit
one-to-two synthetic rewind. The installed runtime does not invoke these kernels.
It remains protected by its loaded-source guard; live post-upload/pre-checkpoint
application, command-free correction input and complete stress/material ledger
publication remain required integration work.

## Corrected child baseline join

`PxgDestructionElasticCommandBaseline.cuh` joins V14 sparse upload history,
original authored-chunk ancestry and the current partition. A persistent native
body index is initialized once; input generations invalidate untouched entries.
Only recorded command IDs are reset/indexed. Every child validates that all its
chunks have the same original body/root/slot/generation, then transfers the
original rigid velocity field to its supplied rewound world COM:

`v_child = v_before + omega_before × (COM_child - COM_original)`.

If that original body has a captured ordinary delta, the saved pre-addition
velocity is used directly. Otherwise the matching original checkpoint supplies
the baseline. A missing record is not evidence that every other command channel
was absent. The join does not subtract rounded velocity changes and does not
invent how a body-level force was distributed among chunks.

Run `begin → clearSelected → indexCommands → finishIndex → resolve → finish`
on one stream; `resolve` uses exactly 128 threads per child. Initialize index
storage (including newly grown capacity) to zero once. Inputs are immutable for
their generation. Child COMs must be at the rewound input pose, not end-of-trial
positions. Status errors, stale generations, duplicate command records, mixed
ancestry and nonfinite transfer reject. Intermediate output is unusable unless
the final receipt is ready and error-free.

The command-motion consumer accepts this optional corrected baseline only for
evaluation one, with matching original input, topology and group count. It
preserves the current target's inverse mass and native metadata while using the
validated baseline velocities. It rejects a failed/stale baseline before native
writes. The combined receipt checks still do not prove that all spatial commands
match the ordinary upload history; the live producer must establish that ledger.

[Join and replay evidence](../../qualification/elastic-command-baseline-20260910/README.md)
includes rigid-transfer/linear/angular-momentum oracles, invalid input checks and
a device baseline→spatial command→native write chain. Runtime V14 provides input
history but does not invoke this join or the new command-motion application yet.

## Evidence

[Qualification](../../qualification/elastic-commands-20260910/README.md) includes
independent wrench oracles, a split batch, zero-resultant axial loading, explicit
expiration, stale/invalid inputs and a device command-to-load-adapter handoff.
[Native wake bridge evidence](../../qualification/elastic-command-wake-20260910/README.md)
records the eight scheduler/control combinations, memory check and preserved
failed test assumptions. Native command production/application and accepted
trial/correction transactions remain pending; the wake hook alone does not
complete them.
