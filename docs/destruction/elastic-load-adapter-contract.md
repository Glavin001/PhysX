# Six-channel physical load adapter

`physx/source/gpudestruction/src/PxgDestructionElasticLoads.cuh` implements the
GPU force/moment conversion required by section 4 of the
[new solver specification](cuda-stress-solver-plan.md). It consumes actual
PhysX destruction record types and feeds the
[fine-equation solver](elastic-operator-contract.md) directly on the device.
It is currently exercised by a standalone native CUDA test. The live scene
producer and accepted material/correction transactions are not wired to it yet.

## Inputs and frames

Use `PxDestructionChunkMassProperties` for positive physical mass, the full
six-entry symmetric inertia tensor about the chunk COM, and its independent
support flag. The legacy stress chunk's scalar inertia and zero support mass
are not physical mass properties. Invalid mass/inertia rejects; no padding,
stiffness, mass or inertia is invented to repair it.

The node partition describes complete **motion aggregates**, not stress islands.
The initial interface uses packed cluster indices from
`PxDestructionStressChunk::cluster`, a node permutation, boundaries and inverse
local offsets. Validation checks complete, unique ownership and mass data.
The producer must supply the current active mapping; sparse/inactive layouts
and stable motion-slot mapping require that producer integration.

The [GPU partition](elastic-partition-contract.md) now provides compact active
mapping, including sparse/deleted chunks and slot validation. It is exercised at
the native boundary in an isolated diagnostic build and supplies device counts
directly to the adapter. General live command/interval publication remains open.

Canonical `referencePositions` must be the exact device positions consumed by
the fine operator. Surface force and torque are already physical force-valued
quantities in the asset frame, with torque about the legacy stress chunk
position. The adapter transports that torque to the canonical origin:

`T_canonical = T_surface + (x_legacy - x_canonical) × F_surface`.

Additional applied wrenches are translation/force first, rotation/moment second,
about the canonical origin, in asset axes. They exclude surface contacts and
gravity. Gravity is world-space acceleration; its force acts at each physical
chunk COM, so its moment is transported to the canonical origin too. An absent
additional-load array explicitly means no additional applied loads.

The supplied motion contains the asset-to-world quaternion and world angular
velocity. Quaternions must be finite and near unit within the supplied profile;
conversion normalizes the admitted quaternion in FP64. This does not change
the engine's stored pose. Full tensor inertia stays in asset axes.

## Inertial relief and supported motion

For `CompleteFreeWrench`, all applied external wrenches must be present and no
chunk may be prescribed. The adapter computes aggregate mass/COM/inertia,
linear acceleration from total force, and Euler angular acceleration including
`omega × (I * omega)`. It subtracts translational, tangential, centrifugal and
intrinsic rotational inertia at each chunk. Both applied and inertial moments
use the same canonical origin. Uniform nonspinning free fall cancels; spin and
nonuniform contact loading generally leave internal response.

Uniform gravity is canceled algebraically in `CompleteFreeWrench`: accumulate
only nongravitational applied wrenches, derive acceleration relative to gravity,
and use that relative acceleration in internal force/moment evaluation. The
receipt still publishes physical acceleration including gravity. The singleton
path also omits gravity from torque about COM. This avoids subtracting rounded
copies of weight/inertia or manufacturing a couple from rounded COM arithmetic.
It preserves arbitrary applied loads and spin; there is no near-zero cutoff.
Acceptance scales still use physical external/inertial wrench magnitudes,
including gravity. [Native regression evidence](../../qualification/elastic-gravity-cancellation-20260910/README.md).

`EngineAcceleration` uses explicitly supplied world linear/angular acceleration,
with linear acceleration defined at the aggregate's physical COM. It does not
also apply the free-wrench acceleration formula. Supported aggregates require
this mode. Unprescribed aggregates additionally require net effective force and
moment balance within the supplied absolute/relative limits. Missing reactions
or inconsistent supplied accelerations are not silently projected away.

Prescribed-node RHS elimination remains the fine solver's job. Producer support
masks, motion ownership and fine-operator constraints must agree. This adapter
does not infer directional constraints, unknown reactions or additional loads.
Aggregate mass properties are currently recomputed for the query; integration
should reuse matching GPU topology-owned aggregate properties when their
producer certificate is available.

A complete free one-node aggregate has only rigid DOFs. Its internal load is
exactly zero; a dedicated path retains the physical acceleration calculation and
input checks while avoiding aggregate reductions and cancellation roundoff.
Supported nodes and supplied-engine-acceleration cases retain the general checks.

## Interval, publication and failure contract

The producer writes an `Interval` after its frozen load channels are complete.
It records tick, input and ownership generations, evaluation 0/1, an explicit
completeness assertion and positive loading duration. The adapter requires an
exact match to the expected interval. A force-valued surface load has already
been divided by its producer's impulse interval: the adapter never divides it
again. The completeness bit is a producer obligation, not a numerical proof
that all engine commands/contacts were supplied.

Native topology generation zero is a valid initial ownership generation. The
load generation must still be nonzero; zero-initialized unpublished inputs are
not accepted. Preserve the actual native float interval promoted to double when
matching a capture, rather than substituting a separately rounded constant.

Each output receipt carries that interval. Before numerical consumption, the
GPU `gate` checks both readiness and expected interval, then sets a nonzero
downstream error on failure. Consequently an old successful receipt, a stale
ownership mapping or rejected loads cannot become a converged zero-load solve.
Phase-order validation, build, gate, RHS assembly and iteration on the stream;
keep all input/output capacities and lifetimes valid. Outputs from a failed
receipt are unusable. No material time, fracture, rigid velocity or accepted
scene state changes in this adapter.

The test profile uses quaternion tolerance 1e-6, relative inertia pivot 1e-14,
and force/moment closure limits `1e-11 + 1e-11 * scale`; scale is the larger sum
of external and inertial wrench magnitudes. These are explicit algebra-test
settings, not release calibration or a native impulse-timeline qualification.

## Validation and next integration

Independent host Newton–Euler equations use explicit rotation matrices and a
dense three-variable solve. Fixtures cover free fall, anisotropic spin, gravity,
surface and additional loads, shifted moment origins, world-frame invariance,
supported and prescribed-acceleration bodies, invalid mass/inertia/ownership,
stale frames/ownership/evaluation/intervals, incomplete loads, and nonfinite
torque. The adapter also hands its device output to RHS assembly and projected
PCG, whose original-row residual check passes without a host load round-trip.
Another check rejects an old successful adapter receipt at that same boundary.

The initial handoff exposed differing device moment origins: one legacy float
position and fine double position differed by ~1.19e-8 m. That left a projected
compatibility defect of ~2.52e-9 and correctly failed. Canonical device origins
plus explicit torque transport fixed the handoff without relaxing convergence.
This does not attribute or resolve the historical native pose audit failures.

[Standalone evidence](../../qualification/six-channel-loads-20260910/README.md).
[Real native capture and replay](../../qualification/live-loads-20260910/README.md)
now covers startup, first-fracture trial/correction and a later peak: 113,664
chunks, up to 10,905 motion aggregates. Independent equations, four focused CTests,
all four replay sanitizers and byte-identical counter replay outputs pass. The
native command ledger remains uncertified; replay completeness applies only to
its explicitly defined captured-surface-plus-gravity numerical case.

The established capture belongs inside `PxgDestructionRuntime::advance`, after
`routeContacts` and before the existing stress dispatch. Preserve that exact
evaluation's motion membership, pose, full mass data, load interval and command
ledger. A post-`fetchResults` accepted-topology view alone is insufficient to
assume that its ownership matches the earlier contact/load evaluation, because
the intervening material verdict can change topology. Qualify real trial and
corrected inputs before replacing the backend or publishing new fractures.

The [V11 native input-history boundary](../../qualification/elastic-input-history-20260910/README.md)
now retains original post-command/pre-solve body arrays separately from the
current corrected-motion checkpoint. Its borrowed view expires at the next
BeforeSolve capture or clear; consumers must join the ready event and finish
before then. Corrected refresh rotates two reusable allocations without another
full-array copy. Raw original body indices cannot address newly born fragments;
ancestry/slot-generation mapping and an explicit complete command/contact interval
receipt remain prerequisites. Retention alone does not certify load completeness
or authorize restoring original state over corrected motion.

The [V12 authored ancestry producer](../../qualification/elastic-input-owners-20260910/README.md)
now supplies original native body/root/slot/generation per active authored chunk.
Wait for the input checkpoint event and require its device ownership receipt to
be valid with the matching input generation before joining. Current fragments
resolve original parents through authored chunks; they must not treat saved
slots as current handles. The mapping survives correction and expires with the
original body view. Ancestry is necessary but does not define command allocation
or certify interval completeness; the correction guard for unapportioned source
forces/torques remains until that physical producer is qualified.

The [explicit command evaluator](elastic-command-contract.md) now generates
the `additional` node wrenches from frozen chunk-targeted world points, forces
and couples (or explicitly timed impulses). It also produces consistent body
resultants. Its command-only receipt is not the complete native load interval;
the full producer still must account for the remaining channels and actual
trial/correction command application.
