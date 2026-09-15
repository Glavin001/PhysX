# Six-channel GPU fine operator and projected iteration

This implements the fine operator, right-hand side, local block-Jacobi action,
bond response and projected PCG from sections 3–4 and 7 of the
[solver specification](cuda-stress-solver-plan.md). It is a private CUDA
implementation, currently exercised by an independent GPU regression target.
The existing engine stress backend is unchanged. This is not yet an integrated
replacement solver or a performance improvement.

## Implemented equations and ownership

`StressElasticOperator.cuh` stores six-vector entries in translation/force then
rotation/moment order. This differs from some older angular-first Blast types;
an eventual adapter must convert explicitly. Each live interface has one common
point, a proper orthonormal local-to-component frame, a full symmetric positive
definite 6×6 stiffness and a six-entry inelastic reference deformation.

The matrix-free kernel owns one output node. It gathers every live incident
bond and writes that node once. Prescribed nodes and prescribed columns are
zero in the reduced operator. Geometry remains in component reference space.
The RHS separately includes external loads, prescribed motion and inelastic
deformation: `b_d = f_d + sum(G_d^T D z) - K_ds q_s`. Recovery restores prescribed
values and evaluates one wrench and energy per live bond. Deleted bonds return
zero response/energy and contribute no operator or diagonal terms.

The diagonal kernel assembles full 6×6 node blocks and factors them by Cholesky.
The local application solves with those factors; it does not approximate a
coupled block by six independent scalar divisions. Singular blocks report an
error. No stiffness, damping, support or diagonal regularization is invented.
The standalone preparation primitive rejects an isolated free node's zero
diagonal. The projected solver handles its zero-dimensional admissible space
before attempting any factorization.

Bond response is `s = D (Gq-z)`. The endpoint energy gradient is `G_i^T s` and
the physical internal wrench is its negative. These responses must not be
applied again as external rigid-body impulses. Constitutive history is read
only; numerical kernels do not advance material time or publish fractures.

## Caller contract and remaining integration

The caller owns valid device pointers, capacities, numerical indexing and stream
ordering. Input and output vectors must not alias. CSR contains exactly two
references per bond, one at each distinct endpoint, including deleted bonds.
Whole-node prescribed masks are the initial supported constraints. Stable
physical IDs, component handles and directional constraint conversion belong
to the forthcoming adapter, not these local numerical indices.

Clear the validation status before the bond/row validation kernels. Both must
finish before consumers. Their checks cover endpoint ownership, duplicate or
out-of-range adjacency, finite geometry/coefficients, proper frames, stiffness
symmetry and positive pivots. `buildDiagonal` consumes an immutable validation
status and writes a **distinct** numerical status; they must not alias. The
caller must reject either status before using its factors or accepting outputs.
External loads, prescribed values, iterates and validation tolerances must be
finite and admitted by the caller's numerical profile. The projected solver
checks finite input vectors and its explicit numerical profile, then checks
true residuals and node force/torque balance before issuing a linear receipt.

## Projected GPU block-PCG

`StressElasticPcg.cuh` owns the cooperative iteration. `StressElasticSetup.cuh`
prepares reusable factors and modes; `StressElasticPcgBlock.cuh` contains their
private data contract, validation and block operations. The solver
uses exactly 128 threads per component and strides through its node list; there
is no 128-node capacity restriction. Components retire independently. Reductions,
iteration counts, drift checks and convergence decisions remain on the GPU.

The component map must own every unknown exactly once. Whole-node prescribed
supports can be omitted from owned rows: their owner/local entries are `Unowned`,
and they remain immutable boundary inputs to RHS and response recovery. The GPU
validates both directions of the packed/inverse map. Live unknown–unknown bonds
must remain within one component; prescribed boundaries may be shared. Setup
checks connectedness of owned rows without traversing an omitted support and
recognizes anchoring through incident live support bonds. The initial reachability
proof still costs diameter × adjacency work; a native topology producer should
ultimately supply that proof. Prescribed rows included in existing full-matrix
reference fixtures remain valid, but the new producer excludes them.

`StressElasticComponents.cuh` supplies a GPU unknown-component producer. It hooks
minimum roots with integer atomics over live unknown–unknown bonds, derives
immutable labels, stably sorts (root,node) pairs with CUB, scans component starts,
and publishes packed/inverse maps. Prescribed rows sort outside the active prefix;
bonds through prescribed supports never join independent systems. Releasing a
support can join systems and requires repartition, even if no bond was added.
All-prescribed and empty graphs publish zero components. Invalid graph receipts
publish no usable count. Graph validation must finish before the builder begins.

The caller owns workspace capacities and scratch, orders edits/build/validation/
setup/solve on its stream, and advances layout/support/topology revisions before
changing inputs. Rebuild is explicit, not an idle polling scan. The current
producer rebuilds the whole supplied graph and assigns the supplied setup key and
positive length scale to every new component. Selective repair, per-component
native lifetime/revision production and admission to the live runtime remain open.
CUDA API failures must be checked before using any output.

`Components::activeCount` optionally points to the device count; `count` then
specifies allocation capacity. Setup and solve accept a bounded one-dimensional
grid of 128-thread blocks, and each block walks active components with a shared-
scratch completion barrier between them. No host count readback determines this
dispatch, and unused allocation capacity need not become an equally large launch.
Only active receipts are valid. Omitted prescribed solution/workspace entries are
not traversed or written; recovery uses the separate prescribed input vectors.

Per-component length `L > 0` specifies `T = diag(1,1,1,1/L,1/L,1/L)` and `q=T*x`.
Both the operator and RHS use this scaling. Free components construct all six
analytical modes in scaled coordinates about their mean position; two-pass
modified Gram–Schmidt produces the basis. Each mode is checked against the
actual scaled fine operator. Whole-node support on a connected positive
six-channel graph removes those collective modes. Directional supports remain
outside this implementation's admitted input class.

Compatibility is checked before projecting the load. The original unprojected
scaled residual, plus maximum physical node force and torque imbalance, must
pass the supplied limits. Initial guesses, residuals, preconditioned residuals,
directions and corrections remain projected. Local scaled 6×6 Cholesky factors
are fixed during a recurrence. True residuals are recomputed periodically, on
a convergence candidate, on curvature breakdown, and at the iteration limit.
Excessive recurrence drift restarts from the true residual. This follows the
fixed symmetric preconditioner requirement of [PCG](https://petsc.org/release/manualpages/KSP/KSPCG/)
and the compatible-range condition for a [singular system](https://petsc.org/release/manualpages/Mat/MatSetNullSpace/).

`LinearConverged` is only an algebra receipt. It does not accept a material
verdict or authorize engine publication. `PendingIterationLimit` preserves the
current physical-coordinate iterate for a same-input warm restart, but the
cross-launch recurrence/controller is not implemented. Invalid inputs,
incompatible loads, unsupported factor/mode rank, nonfinite arithmetic and
curvature breakdown have explicit statuses. Zero residuals finish without applying
the local preconditioner. Nontrivial components now factor during setup, including
when their first RHS is zero; subsequent loads reuse those factors. Isolated free
nodes skip factorization. A single free node that fails original-row balance cannot be
repaired by iteration and returns incompatibility. No unfinished solve is
accepted or spread across physics ticks.

Every workspace array, input and output allocation must be distinct. Graph and
partition validation errors are immutable during the solve; the caller checks
CUDA completion before inspecting receipts and ignores output on failure.
All receipt bytes have initialized fields, including a true-residual-check
count. This avoids copying undefined structure padding to the host.

## Persistent setup contract

Initialize `SetupState` entries once, then phase-order producer edits, graph and
partition validation, `prepareComponents`, and `solveComponents` on a stream.
Each active component is solved by one 128-thread block at a time; a bounded
grid may process multiple independent components per block. The caller
must retain the basis and factors at the same valid node mapping until setup
is invalidated. The recurrence reads them but does not rebuild or modify them.

`SetupKey` records component identity/generation and topology, geometry,
stiffness, support-mask and layout revisions. Geometry includes positions,
interface points and frames; stiffness includes every live constitutive block.
The producer must advance the relevant revisions before any mutation and must
not reuse an identity/generation or wrap revisions onto a retained certificate.
This is a checked producer-version contract, not a content hash or automatic
detection of unreported writes. Current test fixtures supply the revisions;
device-owned repartition now exists, while native revision/lifetime producers
and full engine integration remain pending.

The setup receipt also matches length scaling and the mode-rank, nullspace and
diagonal-pivot tolerances exactly. Missing/stale setup returns `NeedsSetup` from
the recurrence, without accepting an output. A setup attempt invalidates its
old receipt before writing replacement data. The cache-hit decision is a block
collective before any thread can overwrite the receipt. Different components
have independent setup counts and invalidation.

Load, prescribed-value and inelastic-reference changes do not alter the fine
operator when those other revisions are unchanged. They may reuse setup, but
must rebuild the current RHS and pass a new solve/compatibility/residual check.
Stopping criteria can change without rebuilding the unchanged factors. This is
not a cross-tick convergence or material acceptance certificate.

`SetupStatus::Ready` proves that modes/partition preparation succeeded;
`factorsValid` separately records diagonal factor availability. A numerical
pivot failure cannot be used for iteration, but an independently verified zero
residual does not require those factors. No factor failure is repaired with
extra stiffness. Setup currently scans all relevant adjacency when rebuilt;
only matching setup avoids those scans. The test driver still validates its
partition before each run, outside the cached-setup kernel.

This foundation deliberately has no accepted-output API. The next stages are:

1. Persistent partition construction, producer revision wiring and a bounded solver controller;
   retain the current fine-equation checks when adding structural acceleration.
2. Wire and qualify the live producer for the
   [implemented physical load adapter](elastic-load-adapter-contract.md), including
   actual impulse intervals, inertia/spin, supports, changed ownership and
   exactly-once correction. Standalone PhysX-record and device-handoff tests pass;
   native trajectory provenance is still pending.
3. Event generations, accepted/trial material state, rollback and final publication.
4. Structural acceleration, retained factors and precision choices evaluated
   against this fine model and independent physical acceptance profiles.

Until those stages are qualified, none of the new routines replaces production
stress or changes a material verdict. Tests use FP64 as a numerical starting
point; this is not a qualified consumer-GPU precision/performance policy.

## Independent checks

`elastic_operator_test.cu` assembles dense endpoint matrices directly from the
specified equations; it does not call production device math on the host. It
compares every operator column on a six-node cyclic graph with a rotated frame,
full coupled stiffness and nonzero inelastic and prescribed values. It checks
diagonal action, recovered wrench/energy, supported equilibrium, net internal
force/moment, all six free rigid modes, deletion and fully prescribed graphs.

A separate two-node interface checks analytical compliance under each of six
unit loads, including shear/bending coupling through the moment arm. Another
case checks 129 translated copies: 774 nodes, 1,032 bonds and 129 prescribed
nodes, with CUDA work spanning multiple thread blocks. Invalid stiffness,
frames, geometry, ownership and adjacency are rejected; a deleted/disconnected
dynamic graph reports singular diagonal preparation.

The algebra fixture uses `2e-11 * (1 + abs(reference))` comparison tolerance.
Frame/symmetry validation uses `1e-12`, and local pivot screening uses `1e-14`
relative to the block diagonal scale. These are test-profile constants, not a
release material or near-fracture acceptance policy. The host dense solve is
only an independent reference in the test executable, never an engine fallback.

Build the `stress_elastic_operator_test` target in the existing SDK build;
CTest name: `blast_stress_six_channel_operator`. The target is enabled for CUDA
13.4+ and architecture 120. Evidence:
[initial qualification](../../qualification/six-channel-operator-20260910/README.md).

`stress_elastic_pcg_test` / `blast_stress_six_channel_pcg` additionally checks
supported/free solutions against independent dense oracles, length scales
0.25/1/4, large rigid warm starts, compatible response uniqueness, all six
incompatible force/moment channels, deletion, arbitrary node ordering, fully
prescribed and isolated graphs, finite-data rejection and truthful iteration
limits. A mixed 129-component batch has 774 nodes and 1,032 bonds (989 live);
separate supported/free stars have 137 nodes and 136 bonds each. These are
algebra fixtures with no projectiles or physics timesteps.

The fixture profile uses scaled absolute/relative residual limits 1e-12/1e-10,
unit force/torque scales with 1e-9 imbalance limits, compatibility limits
1e-12 + 1e-11 times scaled RHS norm, relative mode rank 1e-12, absolute
`||A Q_column||` limit 1e-10, relative diagonal pivot 1e-14, drift ratio 0.1,
check interval 7 and cap 300. Negative tests intentionally override individual
fields. These are explicit algebra-test parameters, not a release profile.
See [GPU iteration evidence](../../qualification/six-channel-pcg-20260910/README.md).

The third target `stress_elastic_setup_test` / `blast_stress_six_channel_setup`
checks load/history reuse, coefficient/deletion/support changes, each revision
field, scaling and setup-policy invalidation, changed stopping settings and
selective rebuild of one of two components. The mixed batch also solves twice
with matching solutions/iteration counts and exactly one setup per component.
See [persistent setup and counters](../../qualification/six-channel-setup-20260910/README.md).

## GPU unknown-component producer evidence

Component flags use an explicit hierarchical integer inclusive scan. Atomic
parent halving shortens union traversal while preserving strictly decreasing
minimum-root links. All-prescribed graphs have zero unknown systems, but bond
response, prescribed reactions and material recovery must still run when needed.
See [mapping, validation and selected counters](../../qualification/elastic-components-20260910/README.md).
Native revision production and accepted material integration remain pending.

The optional `Graph::activeBonds` points to a frozen native deletion mask. All
operator, RHS, diagonal, recovery, setup and PCG paths honor it. Native binding
requires authored bond flags to remain one and verifies ordered endpoint identity.
See the [native graph contract](elastic-native-graph-contract.md). Component setup
keys can be supplied by device pointer so native topology generation stays on
the GPU. The standalone path without a native mask retains its existing semantics.
