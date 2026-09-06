# CPU/GPU ownership in native destruction

The current implementation embeds CUDA destruction in PhysX's scene task graph,
but it does not yet have a device-owned collision lifecycle. Native integration
and GPU execution are separate completion requirements.

## Existing PhysX machinery versus our bridge

| Work | Current implementation | Required direction |
| --- | --- | --- |
| Broadphase candidate generation, supported narrowphase geometry and rigid-body solve | Existing GPU kernels | Keep on GPU |
| Solved-impulse routing, stress/material evaluation, connectivity, cluster mass/inertia and correction motion | Our CUDA destruction runtime | Keep on GPU |
| Contact-manager allocation, interaction registration and part of island bookkeeping | Existing PhysX CPU machinery | Device pair records and solver connectivity for the supported native path |
| Private cluster actor/node reservation and shape ownership mirrors | Our bridge into existing CPU actor/shape machinery | GPU slot/ownership transactions; CPU mirrors only where observations require them |
| Full contact invalidation/recreation after fracture | Our correction invokes the existing CPU collision lifecycle | Device validity checks, ownership resolution and changed-row rebuilding |
| Correction metadata selection/readback | Previously all candidate clusters; now CUDA-selected affected owners | Eventually consume directly in the GPU ownership transaction |
| Setup, commands, memory-capacity allocation, requested observations | CPU application/runtime control | Keep off the per-pair/per-chunk calculation path |

The old all-cluster metadata transfer was our code, not a mandatory GPU PhysX
API requirement. CPU contact-manager and interaction machinery is inherited,
but invoking it across the entire world on correction amplifies its cost.

## Concrete ownership-boundary change

`PxgDestructionRuntime::applyCorrectionBindings()` now consumes the existing
validated, stable CUDA correction work set. A CUDA gather emits only owner IDs
and scheduler/type metadata for affected retained/new clusters. The CPU no
longer reads every candidate cluster or scans unchanged owners' shapes here.
Physical fields remain resident. The new persistent scratch storage costs
24 bytes per authored chunk and allocation failure rejects configuration.

This does not make the resimulation selective: the full rigid checkpoint is
still restored and the normal collision/solve continuation still corrects the
projectile and ordinary participants. The correction limit remains one. Damage,
material settings, stress convergence and solver work are unchanged.

The native impact regression adds 128 unrelated supported structures and checks
that only two affected owners reach the CPU bridge, unchanged owners retain
their shape identities and zero motion, and the projectile response matches the
small fixture. The same test fails against the previous installed runtime with
`CPU owner bridge included unchanged clusters` and passes against the new one.

## Next device integration boundary

GPU broadphase already holds found/lost pairs in `PxgCudaBroadPhaseSap` device
buffers. Today mapped results flow through `Sc::Scene::finishBroadPhase`, CPU
overlap filtering, allocation and registration. `PxgGpuNarrowphaseCore` then
uploads new `PxgContactManagerInput` arrays to run GPU narrowphase.

Replace that round trip with persistent device pair storage, GPU filtering for
explicitly supported filter semantics, and direct narrowphase-input generation.
Pair identity must remain based on persistent shape/chunk IDs; motion references
must resolve current cluster ownership. Ownership or mass changes invalidate
solver rows and incompatible cached impulses. Splits must also discover newly
eligible same-former-cluster pairs. Constraint connectivity, wake state and event
publication must consume those records; adding an unused GPU pair table alone
would not remove the CPU bottleneck.

The complete correction path remains the correctness reference. Unsupported
filter callbacks and other unimplemented features require explicit rejection or
a disclosed reference path, never silently skipped interactions. CPU bookkeeping
must not be described as unavoidable merely because upstream currently does it.

## Measurements and limits

The earlier 113,664-chunk phase capture measured roughly 70 ms of CPU refiltering
per corrected step. The new diagnostic capture keeps that cost: it removes an
all-owner metadata pass, not the CPU collision lifecycle. See the qualification
record for measured phase intervals. These shared-machine diagnostic runs are
not isolated performance qualification and do not establish 60 Hz.

The optional `GpuDestruction.detail.*` scopes in `ScPipeline.cpp` expose CPU task
intervals within correction. Tasks can overlap; do not sum them or label their
unmeasured remainder as GPU time. Profiling remains off by default.

An experimental CPU batch-refilter change was withdrawn together with its new
fixture after that fixture failed to produce the intended trigger reports. The
production path retains the previously tested complete per-shape refilter.
The experiment is preserved in `out/deferred-cpu-batch-refilter.patch`; it is not
a qualified optimization or part of this change.

Qualification: [owner compaction results](qualification/native-sparse-owner-20260906.json).
The 113,664-chunk diagnostic completed 180 steps; ownership application averaged
3.39 ms versus 17.46 ms in the earlier diagnostic, while CPU refiltering still
averaged 73.17 ms. These are not controlled speedup measurements. A 30-second
9-building run rejected step 329 at the 2,048-iteration ceiling. A fresh run with
an 8,192-iteration ceiling completed all 1,800 steps at the same 1e-5 tolerance,
using at most 2,340 iterations. Neither run changes the default iteration cap.
Six focused native tests and the independent SDK build/install passed.

## GPU narrowphase-input construction

[Native contact inputs](GPU_CONTACT_INPUTS.md) now resolve geometry references
from persistent GPU shape instances and omit the corresponding per-pair CPU
preparation tasks. Actual GPU contact generation consumes these descriptors.
Pair creation/filtering, CPU interaction records and solver scheduling remain
unfinished device-integration work; the input upload still crosses the host.
