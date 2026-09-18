# GPU owner installation before CPU compatibility construction

**Partial ranked replacement 1; no demonstrated speedup or real-time claim.**
GPU motion and persistent shape ownership are now installed before CPU fragment
compatibility construction. CPU simulation registration, activity scheduling,
shape rebinding and contact lifecycle still precede corrected physics. Ranked
replacements 2–7 remain pending.

## Responsibility and data flow

The ordinary scene path validates the completed GPU preparation, restores and
installs GPU motion/shape owners, then constructs CPU compatibility records and
applies the remaining CPU registration/rebinding bridge. One upload-suppression
and pending-list compaction follows rebinding; the former duplicate reserved-body
loop and compaction are deleted. Registered acceleration/observation ranges are
still distinct from spare storage. No equations, physical settings, convergence,
command tape or correction/stress budgets changed.

Native shape rebinding now treats resident GPU bounds as authoritative even when
the new CPU placeholder still carries FIRST_BODY_COPY. Letting that flag select
CPU placeholder bounds caused a stale query after the second fracture; the
accepted-query fixture caught it. Ordinary public ownership transfers retain
their existing host-pose/upload rules.

Private runtime factory ABI is V5, rejecting mismatched V4/V5 modules. Public
scene/Rust ABI15 is unchanged. `validatePreparation` now measures validation
separately from `preparationCompletion` (CPU construction), with disjoint report
accounting. Legacy captures remain readable. Required/duplicate phase checks
were strengthened, not relaxed.

## Failures found and repaired

- Manual diagnostic fixtures deliberately stop before correction. They now
  explicitly request compatibility construction before inspecting private CPU
  objects. A missed branch initially dereferenced an absent candidate; it was
  repaired without changing physical assertions. Production upload-suppression
  and acceleration-range assertions run in the actual accepted PGS/TGS path.
- The first split of validation/construction accidentally ended the CUDA context
  guard before compatibility observations. The short performance screen caught
  a large first-fracture stall. In paired software traces of 256 buildings,
  113,664 chunks, 229,376 bonds and 256 shots over 64 steps, tick36 creates
  4,096 awake fragments and breaks 29,184 bonds. The request-readback host scope
  was 0.055 ms baseline, 74.887 ms unguarded candidate, and 0.070 ms after repair.
  GPU restore/install event intervals remained tens of microseconds. These are
  nested diagnostic scopes, not additive production phase timings.
- Construction now has its own scene-context guard, exception handling and an
  explicit stream dependency on installed owners. The unguarded runtime fails
  the new context oracle. Initial regression artifacts remain preserved; do
  not mistake the top-level shots/idle reports for the repaired candidate.

## Verification

All43 affected native/report tests, the full historical wall audit, ordinary
128-step comparison, focused CUDA memcheck and actual phase accounting pass.
See `evidence/` for final suite, physical audit, memory check, negative controls,
phase accounting and hashes. The frozen historical wall uses Direct GPU on and
sleep off; the ordinary reference uses Direct GPU off and sleep on. These mode
contracts remain separate. Controlled wall geometry is 444 chunks,896 bonds,
one projectile; the historical full audit requires 398 retained chunks,
46 detached chunks,199 broken bonds and the exact topology signature.
The ordinary 128-step prefix compares against its complete audited reference.

The six-chunk/three-bond fixture plus one ordinary body verifies actual GPU
owners before CPU construction during both capacity growth and a subsequent
no-growth split. PGS/TGS property fixtures exercise acceleration buffers,
accepted CPU queries/properties, upload suppression and both stress passes.
The baseline fails the stronger ordering oracle for the intended reason.
Broader pre-existing initialization/CUB synchronization findings remain open;
focused memcheck is not an engine-wide sanitizer-clean claim.

## Paired short performance screen

The repaired candidate is under `out/native-owner-context-20260909/candidate`;
baseline is immutable `out/final-properties-20260909/candidate` (73f47b07).
Untraced results: [destruction](context-fixed/shots/report.md) and
[fresh intact idle](context-fixed/idle/report.md). Both reports together are the
paired screen; each deliberately warns when viewed without its companion.

Each arm has two 96-step runs per regime (1.6 simulated seconds),256 buildings,
113,664 chunks,229,376 bonds,256 simultaneous shots or zero idle shots.
Direct GPU off,sleep on,dt1/60,one correction,two stress evaluations maximum.
The complete timer includes commands,physics/destruction and accepted consumer
events/snapshots. All startup peaks remain; rendering/networking are excluded.

Fracture peaks: baseline129.483/130.726 ms,candidate133.577/133.688 ms.
At tick48 both have10,449 fragments,10,193 awake,57,788 broken bonds and216,220
reported contacts. All-step peaks: baseline157.978/155.706 ms,candidate160.353/
158.440 ms. Means: baseline37.581/36.896 ms,candidate37.459/37.139 ms.
Fresh idle all-step peaks: baseline156.155/156.587 ms,candidate158.285/163.874 ms;
startup dominates these. The observed repaired fracture-peak cost is2.3% against
the worst baseline run. It is not labelled a speedup or hidden by the removed
first-fracture regression. Short runs do not establish statistical equivalence,
five60-second qualification, endurance or historical external-backend parity.

## Disposition and next consumer

- Correctness: controlled physical/lifecycle gates and explicit context/order
  negative controls; broader/endurance qualification remains incomplete.
- Architecture: removes CPU constructors/rebinding as prerequisites for actual
  GPU owner installation. The next native registration consumer can use those
  owners without first deriving them from CPU actors.
- Maintainability: one normal owner-installation order and one upload cleanup;
  diagnostic-only stopped transactions explicitly request CPU compatibility.
- Performance: substantial draft regression repaired; remaining observed short
  screen peak cost disclosed above. Retained as partial architectural progress,
  not completed replacement1. CPU compatibility remains on the correction path.

Next remove CPU simulation registration/activity and collision-ownership
consumers as corrected-physics prerequisites. Preserve numerical activation
order, ordinary actors/joints, sleep/wake and current-tick accepted queries.
Do not start ranked structural solver replacement2 before lifecycle1 is complete.
