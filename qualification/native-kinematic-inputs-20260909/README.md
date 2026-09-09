# GPU kinematic solver inputs

**Retained as partial ranked replacement 1, with short-screen costs disclosed.
No demonstrated speedup, lifecycle completion or real-time claim.**

## Responsibility moved

Native ordinary PGS/TGS now construct complete kinematic solver records on the
GPU. The CPU solver-body pool and solver-input upload contain only the world
record. CPU kinematic CCD-history maintenance remains; existing authored target
commands, activity scheduling and compatibility objects remain CPU responsibilities.
This does not remove CPU fragment registration or shape rebinding before correction.

Destruction-owned kinematic motion comes directly from the installed GPU body.
Ordinary prescribed kinematics need a distinct input: their freshly submitted
pose/velocity differs from the persistent GPU collision state under the existing
native update policy. The existing upload kernel records that prescribed motion;
the existing solver initialization kernel consumes it. There is no extra kernel,
contact export/reimport, new host decision or CPU solver-record conversion.

The prescribed-motion input survives inactive frames and reuse of command staging.
It occupies **80 bytes per allocated GPU node** (including validity and alignment),
retained across capacity growth. Growth initialization and allocation are included
in the complete-step timer. Destruction placeholders do not copy their motion into
this input. The current allocation is indexed by the body domain, rather than
packed only for ordinary kinematics; this storage cost remains explicit. It creates
no simulated spare bodies. Existing upload producers invalidate reused dynamic
slots and write new prescribed inputs before consumption. Clear/reconfigure keeps
ordinary input updates current. First native enable can seed an already stationary
ordinary kinematic from its accepted ordinary GPU body state.

Next consumer: GPU simulation registration can initialize kinematic solver rows
without CPU PxsBodyCore solver-input construction. Remaining prerequisites include
CPU iteration/activity metadata, CCD history, ActorSim/island/contact registration
and shape rebinding. Ranked replacements 2–7 have not started.

## Rejected intermediate implementations

- Reading all ordinary kinematic inputs from persistent GPU collision state used
  stale prescribed poses/velocities. Forcing those commands into collision state
  changed the mode-matched trajectory. That behavior change is removed.
- Borrowing transient upload rows through a generation index correctly rejected
  a stationary contacted kinematic after clear/reconfigure: there was no new
  command row. That index is removed. Required prescribed input lifetime is now
  explicit and maintained by the existing GPU producer.
- A new reuse fixture initially omitted the required correction mode and then
  expected a solver row for an isolated kinematic. The final fixture enables one
  correction and uses real dynamic cargo contacts; analytic assertions remain.

## Verification

- All **44** affected native, ordinary, sleep/wake, collision, correction, query,
  publication and accounting tests passed. The subsequently expanded kinematic
  test and its memory check also passed.
- Two chunks/one bond plus ordinary platform, cargo and sentinel: six 64-step
  cases cover PGS/TGS, translation/rotation, offset COM, settling/wake,
  clear/reconfigure, continuous native operation and late native enable.
  GPU solver inputs match the independent ordinary CPU producer. Motion and CCD
  match the recorded native baseline at unchanged 1e-5 component tolerance.
  The original reference prefix is byte-identical; new rows came only from the
  immutable committed baseline. [Provenance](evidence/reference-provenance.json).
- Two chunks/one bond with dynamic cargo: 12 kinematic lifetimes per solver,
  including 10 reused GPU node IDs per case. Analytic pose and velocity checks
  reject inherited stale inputs. The CPU-input baseline fails the new architecture
  oracle with the expected CPU-record diagnostic.
- CUDA memcheck reports zero errors for the expanded kinematic suite. This is
  focused memory-access evidence, not an engine-wide sanitizer-clean claim;
  previously recorded broader initialization/CUB findings remain unresolved.
- Historical wall: 444 chunks, 896 bonds, one projectile, 600 steps/10 seconds;
  exact topology signature, 398 supported chunks, 46 detached, 199 broken bonds,
  both-wall clearance, converged stress and maximum one correction pass.
  This historical fixture uses Direct GPU mode, with sleeping disabled.
- Ordinary wall: same asset/projectile, Direct GPU off and sleeping on;
  128-step mode-matched prefix passes with zero observed position difference.
  Its reference remains distinct from the historical fixture.

Builds required reduced compilation concurrency because temporary compiler files
exhausted storage at eight jobs. The final two-job build succeeded. No service,
deployment or source-sibling changes were made. Public ABI15 and private factory
V5 remain unchanged; shared body physical layout is unchanged. Rebuild internal
GPU/test consumers for the changed private simulation-core layout.

## Matched timing screen

**256 buildings, 113,664 chunks, 229,376 bonds; 256 physical projectiles or an
independent zero-shot intact scene.** Two runs per arm/regime in ABBA order,
96 steps/1.6 simulated seconds per run. Direct GPU off, sleeping on, dt=1/60,
one correction maximum and two stress evaluations maximum. The authoritative
complete timer includes commands, physics, destruction, correction, growth and
accepted observations/events, retaining first-step spikes; rendering/networking
are excluded. These are short isolated screens, not full endurance qualification.

[Generated destruction comparison](shots/report.md) and
[generated pristine-idle comparison](idle/report.md) preserve every sample.
Baseline fracture peaks: 133.942/130.033 ms; candidate: 135.104/134.470 ms.
The worst candidate fracture peak is observed 0.9% higher, not dismissed as noise
and not a speedup. Loaded means are also slightly higher in this screen.
Idle median ranges overlap; candidate's worst first-step idle peak is 1.6% higher.
The screen does not establish a reliable long-run effect or physical equivalence
from counts alone. First counted-state divergence is tick74 in baseline repeats
and both candidate comparisons.

At tick48 both candidate runs report 10,449 fragment bodies, 10,193 awake,
57,788 cumulative broken bonds, 216,220 normal contacts and one correction/two
stress evaluations. Source equations, tolerances and command tapes are unchanged.

The measured tradeoff is retained because it removes a concrete CPU solver-input
prerequisite without changing physical outputs in controlled fixtures. It is not
claimed to address the dominant registration/contact/stress peak by itself.

Immutable matching artifacts: `out/native-kinematic-inputs-20260909/candidate`.
Baseline: `out/native-owner-context-20260909/candidate` (commit 72011356).
Commands, hashes, raw samples, quality results and failure diagnostics remain in
[evidence](evidence/) and the corresponding `out` capture.
