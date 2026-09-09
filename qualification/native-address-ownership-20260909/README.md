# GPU fragment address validation prerequisite

**Ranked replacement 1 remains incomplete.** This change makes native allocation
reject address aliasing before it writes GPU body state. It is retained as a
verified correctness prerequisite for GPU-owned registration, not a performance
win or removal of CPU fragment/contact registration.

## Mechanism and remaining ownership

The previous GPU allocator bounds-checked individual selected addresses, then
wrote fragment motion. Its later CPU materializer checked grant membership and
duplicate targets. A malformed grant could therefore race two GPU body writes
before the CPU rejected it. A request could also read another pending target as
its parent. CPU validation after these writes cannot provide transactional safety.

The resource grant remains an immutable prefix supplied by PhysX's node-handle
allocator. CUDA builds a reverse address-to-grant-ordinal index on resource
changes. Duplicate grants fail on the device; allocation resolves selected
addresses against that index and permits parents only outside the grant or in
its committed prefix. Pending and unused native slots cannot be parents.
Validation completes across the cooperative grid before any canonical body or
owner writes. Mutating a selected address after registration cannot redirect it
to an address outside its registered ordinal.

This is not authentication of an arbitrary resource provider: the PhysX capacity
grant must still contain its own reserved indices and preserve its immutable
prefix. Generation-bearing active registration/reuse remains unfinished.

Costs are explicit: one 32-bit ordinal per allocated body-address slot after a
nonempty fragment grant, a device error word, index initialization/registration
on resource changes and two indexed reads per requested fragment. There is no
reverse-index allocation for pristine scenes without fragment grants, no normal
step index clearing, no CPU decision/readback added and no graph recapture.
Combined storage/address growth builds the index once. Runtime growth remains
inside complete-step timing; spare slots do not become simulated bodies.

**The attempted CPU-check deletion is reverted.** Its direct materialization
fixture bypasses the GPU allocator and requires all-or-nothing rejection of raw
invalid batches. Without the duplicate check it partially constructed objects,
then failed a later valid reservation because node retirement is deferred. The
original assertion and CPU guards remain. The rejection log and semantic patch
are in [evidence](evidence/). Removing the raw materialization dependency belongs
to the remaining simulation-registration replacement; this patch does not claim
that deletion. Physical equations, convergence, correction count, CPU archive,
public ABI15 and private runtime V8 are unchanged.

## Verification

- The new alias test fails against the preceding implementation before the GPU
  changes, then passes the candidate. The negative log is retained; its original
  standalone executable was overwritten by the normal rebuild, not archived.
- Allocation tests cover duplicate grants, pending/unused-parent rejection,
  mutation after registration, valid committed-parent splits, invalid capacities,
  retries, rejection and single consumption at commit. Existing scale cases run
  through 113,664 request slots. These are allocation fixtures, not a full
  113,664-body physics workload and contain no stress bond graph.
- **52 selected tests pass**, including native integration, observations/timing,
  allocation and unfiltered PGS/TGS initialization gates. No assertion is relaxed.
- Allocation memcheck, synccheck and racecheck pass the focused address fixture;
  full allocation initcheck passes all existing scale cases. These are scoped
  checks, not an engine-wide sanitizer claim.
- Frozen penetration: one building, 444 chunks, 896 bonds, one projectile,
  600 steps at 1/60, Direct GPU on/sleep off. Exact unchanged topology gate passes:
  398 supported chunks, 46 detached, 199 broken bonds, both-wall clearance.
- Ordinary penetration: same authored asset, 128 steps, Direct GPU off/sleep on.
  Original mode-matched reference passes with zero maximum compared position
  error; 400 supported chunks, 44 detached, 199 broken bonds. No claim that the
  historical Direct GPU and ordinary modes have identical trajectories.

Both wall modes retain maximum one correction and required stress convergence.
Wall captures are heavy correctness audits, not performance measurements.
[Validation commands/exits](evidence/validation.json) and artifact hashes are
retained alongside the raw captures under `out/native-address-ownership-20260909`.

## Complete-step performance: no speedup established

[Initial bombardment](shots/report.md) · [initial pristine idle](idle/report.md)
· [repeat bombardment](repeat/shots/report.md) · [repeat pristine idle](repeat/idle/report.md).

All screens use 256 buildings, 113,664 chunks, 229,376 bonds and either 256
simultaneous projectiles or an independent empty command tape. Each campaign is
ABBA with two runs per arm/regime, 96 steps / 1.6 simulated seconds per run.
Direct GPU off, sleeping on, dt1/60, maximum one correction/two stress evaluations.
Complete timing includes commands, physics, stress, topology, correction,
capacity growth and accepted observations; rendering/networking are excluded.
First steps and every measured peak remain.

Initial fracture peaks were baseline 131.257/132.857 ms versus candidate
137.538/139.063 ms. This triggered a repeat, not dismissal as timing noise. Repeat
peaks were baseline 127.916/132.008 ms versus candidate 133.231/132.445 ms. The
initial 4.7% worst-fracture increase did not repeat at the same magnitude; a
performance regression is not ruled out. All-step maxima remain dominated by
startup around 156–161 ms. Fresh-idle medians overlap. There is no demonstrated
speedup, five-run/endurance qualification, 60 Hz result or external-backend parity.

All recorded per-step contact, fragment, awake-fragment and broken-bond counts
match across these screens; every destruction run ends with 71,096 broken bonds,
15,738 fragment bodies and 42 corrected steps. This does not replace the
independent physical trajectory oracles.

## Separate phase attribution

[Baseline phases](baseline-phases/report.md) · [candidate phases](candidate-phases/report.md).

Same 256-building/113,664-chunk/229,376-bond/256-shot/96-step workload, one traced
run per arm. At fracture tick48 both have 10,449 fragments, 10,193 awake,
216,220 reported normal contacts, 57,788 cumulative broken bonds and one correction.

- Capacity-growth host scope, including GPU resource work: 0.609407 to 0.692361 ms.
- GPU allocation/preparation: 0.021504 to 0.020480 ms; growth retry 0.378784 to
  0.382976 ms. These intervals overlap host scopes and are not additive.
- Complete diagnostic advance: 139.463 to 143.270 ms; corrected-physics scope
  53.125 to 56.975 ms; stress 30.803 to 30.974 ms.

The larger observed elapsed difference is in corrected physics, not the measured
allocation scopes. A single traced pair does not identify its cause or prove
that address validation cannot affect other work. Preserve this uncertainty.

The initial phase runner declared the candidate GPU file path for the baseline,
although the baseline correctly loaded its own immutable hard link with the
same hash. The stopped runner's receipt is preserved. The corrected runner
verified that existing capture's binary, commands, loaded paths/hashes and exit,
then resumed with the candidate; no baseline simulation was rerun or substituted.

## Reproduction and next action

Build SDK `PhysX`, `PhysXDestructionGpuRuntime`, then the consumer target and
`destruction_motion_slots_test`. Use the existing paired runner with the paths
and command tape in the two screen receipts. `profile-pair.py` reuses the existing
phase reporter and can verify/resume its recorded captures. Immutable module and
consumer hashes are in [candidate-hashes.json](evidence/candidate-hashes.json).
Generated link inputs were hash-verified into RAM to preserve disk space;
no simulation evidence or source sibling was deleted or changed.

Next is still GPU simulation registration: replace CPU active-node/type/iteration
and contact-registration prerequisites with generation-bearing device records,
then make CPU materialization accepted-state publication. The current address
index is consumed by allocation validation; it is not yet the final active-body
roster. Do not mark rank1 complete or advance the implementation order to rank2.
