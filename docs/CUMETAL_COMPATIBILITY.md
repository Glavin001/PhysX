# PhysX 5.10 / CuMetal qualification inventory

Baseline: `feat/cumetal`, PhysX `cc31f0e1` (2026-09-21), CuMetal
`fee009fbfc332031c8636068a1dae07a336b41d4`, plus the working changes recorded in
each build manifest. The local fork is the physics/destruction source of truth.
The historical CuMetal PhysX 5.6.1 patches have not been applied.

**The restricted rigid-demo GPU library and PhysX host library now build and
link.** This explicitly excludes articulation and diffuse-particle GPU sources;
it is not the full-feature SDK. The original mixed stress gate passes on Apple
GPU, and the bounded two-chunk awake scene now passes native collision, fracture
and one correction (1042). Wider scene coverage, localized wall capture and the
requested offline-rendered video remain pending. Linux CUDA is unexecuted.


## Current checkpoint: restricted rigid-demo GPU and host build/link pass (2026-09-22)

**The first bounded native rigid-body/destruction scene passes on Apple GPU
(1042).** The existing `native_standard_scene_test --awake` completes 60 ticks
with two chunks, one bond, one projectile and one resting control, including
one real fracture/correction. This is restricted-profile scene evidence, not
full GPU compatibility or the complete destruction qualification matrix.

The user now prioritizes a small CLI wall-and-projectile demo: real PhysX GPU
rigid bodies and integrated stress/fracture on Metal, committed body poses and
fracture events in JSON, then a separate offline renderer. The target is
localized fracture with part of the wall retained, not scripted total collapse.
See [the demo-first plan](../../cuda-metal/docs/physx-wall-demo-plan.md).

PhysX run `20260922T064921.451198Z-18276` built and linked `PhysXGpu`,
`PhysXCudaContextManager` and `PhysX`. Its `sdk-artifacts.json` records
`feature_profile: rigid-demo-experimental`, `partial_build: true`,
`status: gpu-build-only`, `tested: false` and `installed: false`.
The GPU artifact is `libPhysXGpuActivity_64.dylib`. Four articulation CUDA files
and `diffuseParticles.cu` are explicitly omitted; their 59 exact kernel names
are optional only for this profile, while all other registrations remain
required. Host classes remain, unsupported feature use reports errors, and
normal CUDA/default builds are unchanged. Convex-core and GPU SDF builder
remain separately disabled. An earlier link failure on `initNarrowphaseKernels24`
was corrected by its matching existing convex-core guard (1003).

Helper safety/configuration checks passed 60/61 initially (999); the remaining
early CUDA-backend rejection check passed after its guard was moved before
dependency globbing. The first scene attempt exposed a production radix-sort
kernel requesting 39,104 shared bytes against Metal's 32,768-byte limit (1020).
The CuMetal launch now uses 512 threads and 19,648 shared bytes; CUDA retains
1,024 threads and 39,104 bytes. Warp width 32 and the 32-block per-axis grid are
unchanged, and the build manifest records these resource choices.

The actual production `WithCount` radix kernels pass all eight sizes
0, 1, 31, 33, 1,023, 1,025, 2,065 and 65,573 (1031). Three axes and all eight
passes match an exact stable CPU key/rank oracle, with guards, direct execution
and two queued graph replays. Forced per-launch synchronization is disabled.
This qualifies that production sort path, not the complete scene.

A reusable integer-shift correction also passes the new Apple M3 Max GPU
fixture (1028), first traced and then untraced with batch size 16. Logical and
arithmetic 32/64-bit shifts cover boundary/oversized counts and queued replay;
unsigned literal operands retain their intended bit pattern. The full NVVM
unit suite passes (`command-agent-shift-unit.log`). This preserves NVPTX behavior
for surviving lowered operations; it does not make undefined CUDA C++ source
operations defined or recover work removed by upstream optimization.

The restricted-profile rebuild passes (1032). Earlier standard scene attempts
crashed while CPU contact reporting read a GPU alias
(1034/1035). A 3-by-3 wall CLI capture completes one frame, converging in eight
stress iterations with no fracture (1036). A 60-frame capture also completes,
but the ball passes through both wall and floor without response; stress reports
zero iterations after the first step and no fracture (1038). Both CLI runs exit
2 because the composition gate fails. Their completed JSON records execution,
not valid physics or an acceptable video.

The contact-stream address mismatch is now isolated: a top-level CPU base was
converted to its GPU alias, while the matching base inside a descriptor retained
its CPU bits. The bounded CuMetal source fix transports 17 CPU bases as explicit
8-byte by-value tokens across six box/sphere/plane/contact-export kernels; actual
GPU streams remain buffer arguments and CUDA signatures remain unchanged. Four
CUDA translation units, matching host syntax and native metadata checks pass
(17 scalar token arguments versus 13 buffer arguments). The opaque CPU-token GPU
fixture passes exact offsets, mapped writes, guards and queued replay on Apple
M3 Max, traced and untraced with batch size 16 (1039/1040).

The production token-patch build and scene/CLI relink pass (PhysX run
`20260922T074547.040321Z-8963`, command 1041). The existing standard awake scene
then passes in 290.32 seconds (1042), with a split at step 6, one correction,
fragment X velocity 5.66958 and projectile X velocity 5.59999. Its unchanged
checks cover accepted simulation, mass/inertia after ownership transfer,
CPU/GPU pose agreement, valid contact extraction, raycast/sweep/overlap ownership,
rejection of observation during an uncommitted step, one public time advance
and no duplicate `onAdvance` publication. The stronger profiler-based query
publication audit and sleeping/multiple-correction variants are not exercised
by `--awake`. This test's wall time is not a performance qualification.

The run emits repeated `artiComputeDependencies` unavailable warnings because
articulation kernels are excluded by the restricted profile. Its raw-address
mode also warns that marking live allocations resident removes cross-stream
concurrency. The test uses `CUMETAL_SYNC_EACH_LAUNCH=0` with explicit observation
boundaries; it is not a zero-warning or general GPU-compatibility result.

The 3-by-3, 120-frame wall CLI run (1043) is live at this checkpoint; no localized
wall-damage or final-video result is claimed. Other mesh/contact token paths,
full-feature SDK acceptance, the broader correction/sleep/warm-start matrix and
Linux CUDA execution remain outstanding. Detailed source scope is recorded in
`out/tests/native-host-address-tokens/production-scope.md` in CuMetal.

### Existing numerical evidence

The full shared production stress source compiles (900), and the original
unmodified mixed-component acceptance test passes on M3 Max (902). Both
contiguous and interleaved layouts cover 2,064 nodes and 2,061 bonds across
12-, 1,024- and 1,028-node components. Existing assertions verify analytic
forces at the original 2e-4 tolerance, rejection when either solver specialization
hits its two-iteration limit, and tiny loads converging at iteration zero with
exactly zero force. This is a full-source stress gate, not full native PhysX
scene or integrated destruction qualification.

- CuMetal's barrier analysis now recognizes builtin grid synchronization and
  propagates it through helper calls. Every barrier-containing call graph must
  remain structured or reject; both dispatcher selection and emission enforce
  this. The formerly unsafe retained retirement helper now compiles without a
  per-lane switch. Eleven focused compiler/Apple-GPU checks pass (899), including
  direct/transitive collective negatives, ordinary barriers, nested loops,
  collective traps, FP64, atomics and queued replay.
- The diagnosis preserved original assertions: inputs and solution were correct
  at cooperative-kernel entry (894), but the old kernel produced a large residual
  from tiny inputs (888). Correct collective lowering resolves that original
  numerical failure (902). Global float atomic adds now flush signed subnormals;
  shared adds preserve them. Boundary, contention, returned-bit and queued-replay
  checks pass for both paths.
- The existing default-OFF one-block CuMetal hint also retains an explicit block
  vote on the uniform retirement result. Its CUDA/default branch stays unchanged.
  No equations, precision, tolerances, correction limits or warm-start formats
  were changed. Runs use IEEE64, binary shim OFF, batch size16, no GPU completion
  tracing and no forced per-kernel synchronization.

**Done:** safe dual-backend workflow, native full-stress compilation, selected
rigid-body/destruction component checks, the original mixed stress gate and
the existing settled-state/warm-reuse test (903). The latter passes byte-exact
repeated reuse, one-ULP/settings/cold/topology invalidation, component-local
certificates and withholding reuse of unconverged results on 64 nodes/62 bonds.
The complete original resident-stress suite (907) stops with a GPU timeout at
131,072 nodes using GPU topology. Asset topology passes at 12, 1,536 and 131,072
nodes; GPU topology passes at 12 and 1,536. The failing kernel is not yet localized.
The selected narrowphase archive now builds with the source-specific soft-body
inlining hint (helper run `20260922T050304.985263Z-40274`); 43 helper safety/configuration
checks pass. This establishes compilation, not scene or soft-body correctness.
The remaining original stress bodies pass (911): uneven cold/warm components
(769 components, 13,828 nodes), large-to-small topology transitions, unaffected
warm columns, and exact settled reuse. Only a host test selector was added;
assertions and tolerances stayed unchanged. A host-marker-only diagnostic (915)
localizes the large case failure to waiting for loaded revision 1; topology
initialization and zero-load revision 0 pass. Kernel attribution remains open.

The complete `PhysXSolverGpu` archive, including multi-block TGS, builds (922).
Production broadphase compiles with the explicit independent-block trap contract
(928); compiler negatives (933), collective GPU regressions (927), and production
ownership-helper numerics (940) pass. The complete motion-allocation suite passes
through 113,664 requests (950), including descriptor refresh between graph
replays (949), growth retries, rejected owners and exactly-once commits.

The next verified build and component milestones are:

- Descriptor pointer-permutation GPU and compiler checks pass (959). The actual
  `PxgDestructionRuntime.cu` compiles again (961), resolving the motion pointer-proof
  regression recorded by the earlier full build.
- `FEMCloth.cu` and `internalConstraints2.cu` compile (962). `softBody.cu` (964),
  `softBodyGM.cu` (966), and `particlesystem.cu` (967) compile with matching host
  launch code checked with the hint OFF and ON. These are GPU-module build
  dependencies, not numerical qualification of cloth, soft bodies or particles.
- The complete `updateBodiesAndShapes.cu` compiles, with host flag OFF/ON checks
  (980). Its actual production object links into the rebound-bounds fixture
  (981). All 14 Apple-GPU cases pass (982): exact transforms/bounds/update flags,
  zero/single/tail and multi-block work, queued captured snapshots, guard storage,
  and isolated invalid-index/capacity/ownership failures. This qualifies the
  bounds-refresh component, not a full correction or ownership transaction.

**In progress:** the restricted GPU module has linked and the bounded awake
scene passes (1042); localized wall capture and broader scene qualification remain
pending. Aggregate source and matching host launch compile
(989); its production numerical/error fixture is still unexecuted. The normal
profile retains three known compiler blockers: `articulationDirectGpuApi.cu:1038`
(994), `diffuseParticles.cu:469` and `forwardDynamic2.cu:990` (995). Omission from
the demo profile is not a fix for these failures. The named `--stage scene`
gate uses matching engine artifacts and keeps testing/install explicit; the
new `native_wall_capture` target does not bypass SDK acceptance. Numbered
component evidence refers to `out/tests/pointer-tuples/command-<number>.log`;
the linked-profile evidence is the PhysX run manifest and `command-03.log`.

**Remaining:** full rigid-body scenes, integrated fracture/ownership/checkpoints,
correction limits 0/1/>1, warm-start round trips, accepted publication, staged
consumer, native video and measured scaling. Linux CUDA has not been executed.
All controlled writes remain in the two repositories; the installed system
toolchain is unchanged.

## Historical checkpoint: full stress builds; first integrated numerical run times out (2026-09-22)

This checkpoint supersedes the compilation frontiers below. The full production
stress translation unit now produces a native object and metallib (829), but
integrated destruction is not numerically qualified.

- The current Metal toolchain accepts the narrow unsigned64 discarded-result
  device min/max path. Eligibility requires relaxed device scope and an unused
  old value. After reachable-code pruning, any remaining ineligible 64-bit
  atomic disables this native path for the entire module. Native operations must
  not race the older lock-based fallback on the same payload: its ordinary
  loads/stores do not participate in native atomic exclusion. Cross-module
  alias compatibility remains unresolved; the generic fallback still encounters
  unavailable fences on this installed toolchain.
- The default-OFF `PX_CUMETAL_PACK_BOND_STRESS_SCALARS` option packages seven
  scalar launch values into one 32-byte record, leaving the 27 pointer arguments
  and all shared equations unchanged. The resulting 28-binding production
  `bondStressWalk` kernel compiles. Its actual shared-source numerical harness
  passes normal and batched execution, including exact stresses and predicates,
  removal ordering, material/fibre cases, stale tails, guards and queued capture
  snapshots (822–823; PhysX run `20260922T013238.835411Z-47258`, two CTest checks).
- All **86 audited CuMetal checks passed** at839 (103.66 seconds), including
  hidden-binding conflict rejection on runtime838. All **12 native component
  checks passed** at840 (7.99 seconds), covering six shared-source components
  in normal and batched settings. These are component gates, not full scenes.
  Binary shim remains disabled; no forced per-launch synchronization is used.
- Ordinary block barriers now request both Metal shared- and device-memory
  ordering. Previously the block path omitted device-memory ordering even though
  one-block persistent solvers use it to publish global workspace. Five focused
  emission/GPU checks pass at845 on compiler844, including cross-warp repeated
  global producer/consumer work at96/128/256 threads and captured replay.
  This is a confirmed compatibility fix, not yet a proven timeout fix. The
  separate legacy AIR and warp-barrier memory contracts remain outside this fix.
- **39 build-helper safety checks pass**. Builds still do not install; controlled
  outputs/caches stay within the two repositories and the current system and
  Xcode installation remain unchanged. The PhysX CuMetal device gate retains
  Apple identity and checks warp width, block capacity and cooperative support;
  the CUDA branch retains its existing RTX4090 requirement.
- The first existing mixed128 full-solver numerical run **fails with
  `cudaErrorLaunchTimeout`** (833 and traced retry834). The trace reports roughly
  18.24 seconds for `persistentStressSolve<true>`, followed by an export failure.
  The same production export kernel passes an isolated exact numerical probe
  at842 (2061 rows, six components, guards/tails, two queued transactions).
  This sequence does not establish the timeout's root cause or qualify the
  preceding numerical results. Diagnose this failure before claiming integrated
  stress correctness or beginning scaling claims.

The production source rebuild with the barrier fix also passes (846), but the
unchanged mixed128 acceptance test still fails with a GPU timeout (848). The
barrier defect was real but its correction is insufficient to resolve this gate.

Still required: complete narrowphase/scene integration (including the separate
soft-body pointer-proof gate), full stress and inertia qualification, fracture
and ownership transitions, checkpoints, correction limits 0/1/>1, warm-start
round trips, convergence/accepted-publication policy, staged NativeScene consumer,
native rendering/video and measured scaling. Linux CUDA has not been executed.
The raw-integer peer-pointer publication gap also remains open. Successful
component tests and native compilation do not complete these gates.

## Historical checkpoint: nested solver loops reach Apple Metal compilation (2026-09-21)

This checkpoint supersedes the historical sections below. Full native GPU scenes,
integrated destruction, Linux CUDA execution and the requested video remain incomplete.

- All **81 audited CuMetal checks passed** on compiler805 (806, 99.54 seconds),
  with the binary shim disabled. The new nested-loop/barrier numerical fixture
  reproduced a compilation failure before the bounded structurizer fix and
  passes exact counts, loop-carried values, shared ordering and queued replay.
  A second reproduced collective do/while trap-exit failure also passes healthy,
  early-break and sticky-failure GPU paths without introducing a CFG dispatcher.
- Two further source-shaped compilation failures are fixed: status-writing
  terminal regions preserve side effects and edge values, and normal branches
  can reconverge around an admitted isolated whole-block trap. Calls and
  collectives are excluded from terminal copying, with explicit size and
  expansion bounds. Ordinary returns and nonreturning loops are not ignored.
  New numerical fixtures pass leader-only status/reporting, exact loop/branch
  values, shared ordering, guards, captured arguments and isolated sticky errors
  at 96/128 threads. Unit tests also check barrier-site counts and rejection cases.
- The particle inlining option is integrated in the normal build helper:
  `--cumetal-particle-inline-threshold 500`. It applies only to the canonical
  `cudaParticleSystem.cu`; default compilation and the CUDA backend are unchanged.
  Both native particle test modes pass, including a genuine compaction carry
  overflow and distinct contact identities that detect dropped/repeated work.
  Evidence: PhysX run `20260921T235839.796848Z-95701`, command04.
- The production fine-diagonal kernel now uses the existing experimental
  block-voted-trap hint before tail exits, then a bounded warp-stride schedule.
  Both native test modes pass exact existing all-lane reference bits, independent
  dense-system solutions at the unchanged strict 2e-12 tolerance, queued input
  snapshots, zero-node behavior, and isolated sticky-error/withheld-output cases.
  Evidence: PhysX run `20260922T000815.599636Z-29565`, command04.
  The supported launch is one 256-thread block; arbitrary partial-warp launches
  are not qualified. Instrumented trap dispatches still bypass command batching.
- **34 build-helper safety checks pass**. Builds remain non-installing, all
  controlled caches/outputs stay inside the two repositories, and the existing
  macOS/Xcode toolchain is unchanged.
- The full solver archive and all five component binaries rebuilt with the
  final compiler (807). **Ten native numerical checks passed** (809, 7.44 seconds):
  TGS, hierarchy packing, contact graphs, particles and fine-diagonal solving,
  each in normal and batched settings. These are component gates, not complete
  scene or integrated destruction qualification.

Remaining compilation gates:

1. Full narrowphase now reaches `softbodySoftbodyMidPhase.cu:642` and fails an
   external-pointer write proof (760). Particle compilation and its numerical
   gate are no longer the blocking source. The failed multi-target command did
   not build the solver; its separate successful result is recorded above.
   An isolated native soft-body compile also passes with inlining threshold500
   (`agent-softbody-inline-probe.json`), but this option has not been integrated
   for that source or numerically qualified.
2. Full stress now passes CuMetal lowering, including nested search loops,
   ancestor continuations and retirement cleanup. Explicit PHI snapshots preserve
   simultaneous edge assignments and shared barriers remain outside divergent
   cleanup. Two new numerical fixtures cover 96/128-thread normal, cooperative
   and captured execution; terminal expansion budgets include PHI copies.
   Apple Metal compilation still fails (808): four diagnostics for unavailable
   fences in the generic unsigned64 atomic-max helper, and three buffer-index
   diagnostics for the 34-argument `bondStressWalk` kernel (27 pointers, seven
   scalars). No native full-stress object or numerical result is claimed.
   See CuMetal `out/tests/production-metal-frontier-799/README.md` for the
   proposed native discarded-result atomic and scalar-packing approaches.
3. Broadphase ownership traps and shape-refresh barrier/error paths still need
   integration. The general raw-integer peer-pointer publication gap remains open.
4. Complete GPU linkage/scene execution; stress and double-precision inertia;
   fracture, ownership, checkpoint restoration, correction limits 0/1/>1,
   warm-start round trips and convergence/publication policy; staged NativeScene
   consumer; native rendering/video; measured idle/destruction scaling and an
   actual CUDA-capable Linux run remain required.

## Historical checkpoint: real CUDA trap reporting (2026-09-21)

This checkpoint supersedes earlier current-build statements below. Full PhysX
GPU scenes, integrated destruction and the native video remain incomplete.

- All **73 audited CuMetal checks pass** on the final compiler (746), including
  real CUDA `__trap()` with 96/128-thread shared-memory work, sticky failures,
  withheld post-trap output, ordinary/cooperative/captured execution and native
  one-block launch bounds. Binary shim is OFF and forced launch synchronization
  is disabled. Trap-instrumented kernels still bypass command-buffer batching;
  this is not a claim that those launches themselves are batched.
- The complete **PhysXSolverGpu archive rebuild passes** (747). Six freshly
  rebuilt TGS, hierarchy and contact-graph numerical checks pass (748), including
  their batched variants. These remain component tests, not a complete PxScene.
- All **30 repository-contained build-helper safety tests pass**, including
  the new option's backend, manifest and launch-contract negatives.
- Native object/executable compilation now forwards device-only `--clang-arg`
  values without changing their quoting/order or leaking them to host builds.
- Exact scalar signed/unsigned 32/64-bit LLVM min/max and unsigned saturating
  subtraction pass numerical boundary, guard/tail and queued-snapshot tests.

Clang implements CUDA `__trap()` using inline PTX. That instruction was previously
silently dropped. The importer now preserves the exact standalone spelling as
LLVM trap plus unreachable, repairs dead continuations/PHIs, and rejects other
trap forms before ignored metadata can hide them. Fully defined literal
integer/null-pointer branch conditions can remove impossible error edges;
dynamic, undef/poison and poison-flagged comparisons are excluded.

PhysX now has default-OFF `--cumetal-block-voted-traps` /
`PX_CUMETAL_BLOCK_VOTED_TRAPS`: a full-block vote before terminal early returns,
paired with one-block bounds only for terminal application, cycles and the
hierarchy-preconditioned persistent solve. Equations, precision, iteration and
correction limits, and warm-start formats remain shared. The option is still
unqualified for production stress; changes in reduction order require the
existing numerical tolerances and convergence tests. Its scope is documented in
PhysX `docs/destruction/CUMETAL_BLOCK_VOTED_TRAPS.md`.

Current remaining gates:

1. Narrowphase: actual particle compilation with O1 now reaches unsupported
   LLVM `freeze` (737). All eight freeze inputs fail LLVM definedness/nonpoison
   proofs; blindly erasing them is not justified. The narrower saved-LLVM
   inlining alternative has no freezes but fails aggregate/PHI representation
   (740). Neither optimized production route is accepted yet.
2. Stress: literal dead-branch cleanup removes spurious unreachable traps, but
   the real translation unit still fails trap helper analysis at `cm_grid_sync`
   (744). Required FP64 classification/math helpers need a narrow audited
   collective-only contract; that implementation and numerical qualification
   remain open. Do not weaken the general barrier rejection.
3. Broader integration: restored hard traps also require requalification of
   broadphase ownership checks inside collectives and the shape-refresh
   barrier prefix. Source audits identify both as real error paths, not no-ops.
4. Complete GPU library/scene execution; integrated stress, inertia, fracture,
   ownership, checkpoints, correction limits 0/1/>1, warm starts and accepted
   publication; staged NativeScene consumer; native renderer/video and measured
   idle/destruction scaling. Linux CUDA execution remains unavailable.

The prior raw-integer peer-pointer publication gap also remains open. No unsafe
reproducer was executed. No system/toolchain changes or installation occurred.
Logs and audits are in CuMetal `out/tests/pointer-tuples/` and
`out/tests/collective-trap-audit/`; exact artifact hashes are recorded in
`out/tests/pointer-tuples/collective-trap-final.json`.

## Historical checkpoint: solver compilation restored (2026-09-21)

This checkpoint supersedes earlier compilation frontiers below. Core PhysX GPU
scene execution and integrated destruction remain incomplete.

Final regression refresh: **all 68 audited CuMetal compiler/runtime checks pass**
on the corrected compiler (720, 81.19 seconds). This includes the new unsafe
marked-export negative and queued Apple-GPU pointer fixtures. The six fresh
PhysX component checks pass separately; the complete 18-test build remains
blocked at narrowphase as recorded below.

| Status | Evidence / next gate |
|---|---|
| Done | Safe backend/preset workflow, local output/cache boundaries, explicit tests and installation; 28 helper safety tests last passed at command 684. Linux execution remains unavailable. |
| Done | Both previously failing production solver sources compile to native Metal objects (707); the full PhysXSolverGpu archive rebuild succeeds (710), including TGS preparation/integration and multiblock solving. |
| Tested components | Existing numerical TGS normal/angular/friction and small hierarchy gates; these are not a complete PxScene result. New nested numeric pointer observations and opaque pointer transport pass on Apple GPU with queued graph replay (703/708). |
| Current limit | Six refreshed native TGS/hierarchy/contact-graph checks pass; the full 18-component rebuild stops at a particle collision pointer-write proof before tests. Full-library and scene qualification remain open. |
| Next compiler blocker | Full stress now passes the descriptor-root and private-field work-budget frontiers, but rejects trap reporting in kernels containing barriers (699). Terminal kind==3 is a real data-dependent error path. Collective error handling must preserve errors and avoid stranded threads. |
| Remaining | Complete GPU dylib linkage and first native TGS scene; integrated stress/fracture/ownership/checkpoints/correction limits/warm starts; relocated NativeScene package; Metal renderer/video; measured scaling and actual Linux CUDA validation. |

The descriptor-root option now obtains real LLVM noalias+readonly metadata by
passing the unchanged original argument record to retirement helpers that do
not access rebound cycle descriptors. Equations, precision and convergence
policy are unchanged. Guarded private-field proofs index both memory effects
and predicate definitions instead of rescanning arithmetic; the work cap is
unchanged, and an overlapping-byte negative still rejects (700/701).

Opaque CPU pointer identifiers may travel through narrowly certified private
records and complete byte copies, or be compared/converted into scalar indices.
Their source and output storage must pass explicit external-storage checks;
private initialization and mixed-space negatives remain enforced. Exact original
CPU identities, null combinations, guards/tails and changed graph snapshots are
checked by the new GPU transport fixture. These values are never dereferenced
as GPU addresses by that fixture.

The remaining contact-preparation failure was isolated to an unrelated kernel's
pointer publication. A bounded kernel-entry analysis now excludes only writers
whose entry sets are conclusively disjoint. Sibling branches, peer threads and
helpers shared across entries remain checked; unknown graphs or exhausted
budgets retain the conservative whole-module check. Synchronized peer-publication
negatives, including a readonly root, still reject (712).

Build 705 solver restoration was followed by a marked-export safety correction;
the final status and hashes are below.
No global installs, system/toolchain changes, native destruction run, or video
were performed. Command logs are under cuda-metal/out/tests/pointer-tuples/.



The final marked-export safety correction passes six focused compiler/GPU
checks (716), and both production solver sources still compile (717). The
refreshed 18-component build then fails **before running its tests** at
cudaParticleSystem.cu:1219:50: psPrimitivesCollision has an unproved/ambiguous
write address before a descriptor copy. This exposes a remaining narrowphase
compiler frontier; full narrowphase compilation is now historical. The fresh
TGS, hierarchy and contact-graph binaries were tested separately: all six
normal/batched checks pass (719, 4.30 seconds). The latest full-stress compile
still fails at the trap/barrier frontier (718).

A parallel review also found a pre-existing raw-integer peer-pointer publication
gap, documented in CuMetal's compiler known gaps. The newly marked export path
now rejects its corresponding negative; broader scalar publication is still
unqualified. No unsafe reproducer was run on GPU.

Current compiler SHA256:
`680279cd230d5084066bbb7b4c438ba4d8e491adfd559a1346bbe7308d60086e`.
Current solver archive SHA256:
`809d4166972c6bc04d0255a693d11ea6659a0ccb247f04cae2a786c56a0346d9`.
Full evidence: cuda-metal/out/tests/pointer-tuples/solver-restored-hashes.json
and PhysX/out/build/macos-cumetal/release/gpu/runs/20260921T224317.504975Z-75478/.

## Requalified requirements

- Linux CUDA 12.8 or newer, architecture 89; no CUDA 13.4 requirement is inherited
  from the previously audited branch.
- Conditional IF graph nodes/handles, capture into an existing graph, graph
  replay, ordered asynchronous copies, and cooperative grid synchronization.
- CUB `DeviceRadixSort::SortPairs/SortKeys`, `DeviceScan::ExclusiveSum`,
  `DeviceSelect::Flagged/If`, counting iterators, and correct scratch sizing.
- FP64 inertia diagonalization including `hypot(1.0, tau)` in
  `physx/source/gpudestruction/src/PxgDestructionBody.cuh`. Software IEEE64 must
  retain the existing precision/tolerances; converting through FP32 is invalid.
- Configurable correction limits (0, 1, and greater than 1) and versioned
  warm-start import/export from this revision.
- No device-updatable graph-node or cluster-launch requirement was found in
  this source. Do not add those older-branch requirements without a new use site.

## Ordered work and acceptance gates

| Stage | Current evidence | Remaining work / exit gate |
|---|---|---|
| Safe workflow | Backend/preset selection; contained outputs/caches; explicit tests/install; path, symlink and stale-cache guards; 28 safety tests; GPU stage with explicit component/test selection | Execute the CUDA build and staged NativeScene consumer on a CUDA-capable Linux host. Linux has path/environment guards; macOS additionally confines child writes with a public sandbox. |
| 1. Host and compilation | PhysX 5.10 Apple Silicon host libraries build. Actual GPU source tree configures without NVIDIA toolkit; context-manager, common-GPU, broadphase, full solver, full articulation and simulation-controller targets compile (optional GPU SDF construction disabled). Full narrowphase compiled historically but the latest rebuild stops at a particle-collision pointer-write proof. Native AOT archive and driver-view fixtures execute on M3 Max. | Complete all GPU translation units and dylib linking, then qualify the integrated context manager/loader, shared-library lifetime, and every launch form used by PhysX. Component compilation is not a scene correctness result. |
| 2. Rigid bodies | Production native pair sort/merge/unique/scan/scatter and aggregate pair collision tests pass on Apple GPU with nested descriptors, graph replay, ownership filtering and bounded reports. Shared GJK/EPA separation, penetration and rotated-box contacts also pass at `1e-4`, in asynchronous/batched graph replays. Exact 64-bit contact lifetime allocation passes tails, carry, exhaustion, replay and invalid-launch checks under an ordered single-block option. The production response publication helper passes PGS/TGS-header contention and ordered replay checks; full solver numerical correctness is still unqualified. Historical reduced PGS fixtures remain separate. | Complete broadphase scene integration, aggregate update/sort/self-collision lifecycle, contacts, general batching/friction, and full TGS. Validate nested pointers, shared memory, warp width 32, atomics, allocation lifetimes, and ordering without per-kernel forced synchronization. No full TGS claim is made here. |
| 3. Destruction primitives | GPU flagged/predicate selection, unsigned 32/64-bit exclusive sums and stable radix sorts pass scratch, ordering and changing graph-replay gates. The existing contact-graph suite passes 100,001 nodes / 201,998 pairs on M3 Max. Cooperative graph attributes, GPU block load/store, maximum-prefix scans and bit-exact double3 construction pass focused gates. Native nested IF handles/default resets/body snapshots and capture-frontier query/update pass focused GPU replay/lifetime tests. Bounded wide records, block count/and/or barriers and explicit IEEE64 FMA pass compiler/GPU gates. | Production transaction/hierarchy integration (remaining trap/barrier error handling); bounded cooperative stress solver execution; complete IEEE64 inertia math. Broader CUB types/APIs and performance remain unqualified. |
| 4. Integrated destruction | Existing fork tests and semantics are retained. | Stress/fracture, ownership and motion allocation, checkpoints, corrected simulation and accepted publication. Exercise correction limits 0/1/>1, warm-start round trips, impacts, sleep/wake and repeated fracture with existing tolerances. |
| 5. Scaling | No destruction performance measurements on Apple GPU yet. | Only after correctness: measure idle/destruction M3 Max workloads, then improve scheduling, scratch, residency, synchronization and large connected components from profiles. |

Stage 1's AOT object fixture is intentionally small. It does not qualify the
whole PhysX translation-unit corpus, relocatable device code across translation
units, TGS, destruction, or runtime cooperative execution.

## Concrete source anchors

- `physx/source/gpudestruction/src/PxgDestructionTopology.cu`: sort, select,
  exclusive scans and the topology transaction include.
- `PxgDestructionTransaction.cuh` and `PxgDestructionPreparationGraph.cuh` in
  that directory: conditional graph handles and `cudaStreamBeginCaptureToGraph`.
- `PxgDestructionRegistration.cuh` and `PxgDestructionMotionSlots.cuh`:
  cooperative launches and `this_grid().sync()`; a CPU loop or unbounded
  cross-threadgroup spin barrier is not a correctness substitute.
- `PxgDestructionRuntime.cu`: 64-bit key sorting, predicate-based compaction,
  collision/motion ownership changes and correction bodies.
- `physx/include/PxDestructionScene.h` and
  `demos/blast-stress-demo/tests/native_gpu_resimulation_test.cpp`: current
  non-convergence behavior retains the warm-started iterate and withholds
  fracture/crush. Do not substitute the old branch's tick-rejection behavior.
- CuMetal `runtime/api/cub/device/*.h`: source-compiled flagged/predicate selection and bounded unsigned exclusive sum/radix sort are GPU-backed; broader forms remain partial or host-backed.
- CuMetal `compiler/metal/src/lower_to_msl.cpp`: audit the FP64 `hypot` path;
  broad “software double supported” status is insufficient.

The first actual source probe of `PxgDestructionTopology.cu` failed on the missing
`cub/device/device_select.cuh` compatibility include. That include and recursive
CUB header installation are now added; this is header coverage, not GPU CUB
implementation. Preserve subsequent compiler failures as inventory evidence
rather than stubbing operations into successful no-ops.

The next source probe reaches the transaction code and fails on missing runtime
`cudaGraphConditionalHandle`, `cudaGraphSetConditional`, `cudaGraphNodeParams`,
`cudaGraphCondTypeIf`, and `cudaStreamBeginCaptureToGraph`. CuMetal's driver-side
conditional type declarations do not constitute an implemented runtime API.

The seven-test native AOT regression run passes vector addition, symbols,
object/archive registration, bounded cooperative execution, and native descriptor
validation, plus shared constant/global storage across native driver and runtime
launches. The existing multi-kernel synchronization fixture
fails on this installed Apple Metal toolchain: emitted `memory_order_seq_cst`
and `thread_scope_*` names are unavailable. Keep that failure visible; do not
replace CUDA fences with no-ops or collective barriers that can deadlock under
divergent control flow. Toolchain capability and lowering semantics both need
qualification before claiming this gate passes.

The user has chosen to retain macOS 14.4 / Xcode 15.4. The public Metal language
specification makes `atomic_thread_fence` and its thread-scope ordering a Metal
3.2 feature. CuMetal's opt-in native `--cooperative-single-block` specialization
uses a device+shared-memory threadgroup barrier for `this_grid().sync()` only
when the native launch ABI enforces exactly one grid block for that kernel.
Ordinary kernels in the same translation unit retain multi-block launches. It does not change
standalone fences. The GPU build enables it through the documented
`PX_CUMETAL_COOPERATIVE_SINGLE_BLOCK` option. Larger
cooperative components will need correct bounded loops or dispatch splitting,
then numerical qualification and measured scaling.

Bounded cooperation was executed on M3 Max with 128 threads, 257 strided device
elements, 16 phases and eight graph replays. Both executable and object modes
pass with binary shim OFF and forced launch synchronization unset. Cross-warp
shared memory and device memory values match the host reference. Tests reject
oversized grids in each dimension, overflow-shaped dimensions, capture, and
graph nodes edited before/after instantiation. The unmodified standalone fence
still appears as a fence in generated MSL. The seven-check run (six pass, the
known fence failure remains) is preserved under PhysX's compiler output at
`runs/20260921T061248.361130Z-17609/command-03.log`.

Two native shared modules with identical internal kernel names also execute
correctly through eight load/unload/reload cycles, preserving a live sibling
module; see CuMetal `out/tests/native-aot-abi4/command-0.log`. This does not yet
qualify destruction unload with outstanding GPU work or captured graphs.

CuMetal now provides explicit native-to-driver module views through
`cumetalGetNativeModules` / `cumetalImportNativeModule`. Focused tests exercise
name lookup, independent modules with identical private kernel names, shared
constant/global storage, borrowed-view unload, cooperative bounds and graph
capture. Native module identities are never reused; views and captured graphs
reject stale use after native unload/reload. Concurrent unload with in-flight
work remains outside the supported lifetime contract. Packed driver launch
arguments and `cuModuleGetGlobal` on these views fail explicitly. PhysX's CuMetal
build now imports these views in the context manager, resolves CUDA names through
the kernel wrangler, and directly loads the GPU dylib. It excludes NVIDIA
`__cudaRegister*` interception and no-op runtime launch shims. This integration
still needs execution with the full GPU module.

The common-GPU build compiles the original `MemCopyBalanced.cu`,
`radixSortImpl.cu`, and `utility.cu` into native objects. It exposed missing
integer min/max libdevice lowering and an invalid null shared-pointer cast;
reusable CuMetal fixes retain the PhysX sources. Boundary-value Apple GPU tests
also caught and fixed missing unsigned/wide CUDA C++ min/max overloads.
Compilation does not establish numerical radix-sort correctness.

`PhysXCuMetalNativePairsTest` now links the actual `broadphase.cu` object and
executes its five native pair kernels through the source-first driver bridge.
It checks empty, tile-boundary and multi-tile found/lost inputs, duplicate and
high-bit keys, two graph replays per case, invalid pairs, overflow, and invalid
aggregate counts. The common block primitive is separately tested for stable
partial-bit ordering, signed/unsigned 32/64-bit keys, and scratch reuse. This
does not yet qualify full broadphase or device-wide GPU CUB operations.

The GPU workflow selects `CUMETAL_USE_METAL_DEVICE_ADDRESSES=1` process-locally.
Without it, descriptor-contained pointers address host aliases and are invalid
for Metal dereferencing. The runtime currently marks all live allocations
resident/read-write in this mode, limiting cross-stream concurrency. Manifests
record that resource policy; forced synchronization after each kernel remains
disabled. External consumers still need this setting pending initialization API
integration.

The full `PhysXBroadphaseGpu` component now builds with CuMetal, including both
native kernel objects and its C++14 host sources. Bounded independent pointer
tag dispatch clears `aggregate.cu`; CuMetal's public texture header now uses
C++14-compatible tag dispatch. Neither result qualifies full broadphase scene
behavior. Narrowphase still requires complete record-contained pointer provenance.
The shared GJK/EPA equations now pass their native numerical gate; the full
component stops later at a tetmesh callback writer pointer. The CuMetal-only `PX_CUMETAL_INLINE_REF_GJK_EPA` hint exposes
local references without changing layouts, equations, precision or iterations;
it is recorded in the build manifest. CUDA retains its original annotations.
The hint initially exposed incorrect GJK results. CuMetal now rejects unproved
nested references rather than silently treating them as device memory, and
transactional loop-reference proofs clear the unchanged GJK/EPA numerical gate. Nested caller specialization now
clears `TestInput` shape assignment (`convexCoreCollision.cu:83`). Finite
function-pointer choices in `GuConvexSupport.h` and dynamic face-point copies
now lower through reusable CuMetal fixes without changing PhysX equations.
Concrete argument-space tuple specialization, scalar
pointer subtraction in `compressOutputContacts.cu`, and unsigned atomic max
in convex heightfield/mesh kernels have been fixed in CuMetal. Contact
compression, triangle collision, convex heightfield/mesh, midphase, and
correlation objects reached earlier compilation gates. The stricter pointer
check still rejects the tetmesh callback in convex core. A subsequent shared-symbol producer fix restores
heightfield/trimesh compilation; their compilation is not correctness evidence.
Contacts remain unqualified.
Destruction compilation also finds the missing counting-iterator include and
the previously recorded conditional graph runtime APIs. These are real source
failures, not grounds for substituting no-op implementations.

## Validation ledger

- **Complete narrowphase / production particle tails (latest):** Both inactive
  tail records in `cudaParticleSystem.cu` are value-initialized and given a valid
  unused particle-system base reference. Active lanes still execute the original
  update; work-index guards prevent fallback access, and all lanes retain warp
  participation. Initialization is shared with CUDA. The particle ConvexCore
  switch now obeys the existing disabled-feature option; CUDA retains that case.
  No equations, precision, tolerances, particle features or new flags changed.
- `PhysXCuMetalParticleTailsTest` links the actual production object and runs
  ordinary/diffuse kernels at 256 threads/block. It covers **108 configurations**:
  0/1/17/31/32/33/255/256/257 input pairs; dense, sparse and empty cells; one/two
  blocks; both PGS/TGS input flags. Three queued graph replays must produce exact
  contact counts, plane normals/separation, ownership/order arrays and bounded
  diffuse writes. Unused output/guard bytes remain unchanged. These are contact
  and tail regressions, not full solver/scene qualification. Traced and untraced
  batch-size-16 execution pass in
  `out/build/macos-cumetal/release/gpu/runs/20260921T160759.277484Z-68599/command-04.log`.
- The **complete selected PhysXNarrowphaseGpu target builds**:
  `out/build/macos-cumetal/release/gpu/runs/20260921T160841.905530Z-70380/command-03.log`.
  Archive: 2,224,944 bytes, SHA256
  `b74dfe03dadf3afd1119b3307d79d326fc6ce851d09ba44e5ef7d0b3c723dbc2`.
  Actual particle object: 137,232 bytes, SHA256
  `2b309817911cce594cd44ed5d9483ebf752357bf76147bad106a90b77b5ab211`.
  This supersedes both old narrowphase particle compile failures; it does not
  qualify every contact feature, full TGS or integrated scene behavior.
- All **twelve** native PhysX gates rebuild/pass with binary shim disabled and
  no forced per-kernel host synchronization:
  `out/build/macos-cumetal/release/gpu/runs/20260921T161017.936272Z-74669/command-04.log`.
  All **24** helper safety tests pass (sibling `command-394.log`), including
  the new target's explicit test selection and wrong-backend rejection. No
  compiler implementation changed this iteration; the previous 32 focused
  compiler/GPU regression results remain applicable.
- Full `PhysXGpu` remains **failed**:
  `out/build/macos-cumetal/release/gpu/runs/20260921T160930.780543Z-72308/command-03.log`.
  It now reports destruction conditional-graph runtime types/functions and the
  missing `cub/iterator/counting_input_iterator.cuh` used by stress compaction.
  Existing host-backed device-wide CUB implementations are not GPU/capture
  qualification even after an iterator header is supplied. Full module linking,
  scene/TGS correctness, GPU CUB, IEEE64 inertia, trap error paths, integrated
  destruction and video remain unfinished. No system changes, installation or
  Linux execution occurred.

- **Mesh-particle field proof:** CuMetal now retains exact constant
  byte addresses in transitive call contexts when protecting a pointer field
  of a caller-owned private allocation. Proven disjoint scalar stores/builtin
  effects may update another field. Unknown offsets, overlapping writes,
  arithmetic overflow and opaque effects remain rejected. Cache entries include
  both the protected field and all invocation offsets; whole-object checks
  cannot reuse field-only results. No PhysX production source changed.
- The actual `particleSystemMeshMidphase.cu` now compiles into a native object,
  clearing the false clobber from `PsTreeContactGenTraverser::contactCount` to
  its separate scratch pointer. The full narrowphase build compiles this source
  but still fails at the inactive-tail pointer in `cudaParticleSystem.cu:1305`:
  `out/build/macos-cumetal/release/gpu/runs/20260921T155458.927745Z-52517/command-03.log`.
  Build object: 63,384 bytes, SHA256
  `e50f0e4da2247b6688551b8eca40f0d962d5762ceeafd68129a131580d2e6046`.
  Compilation is not numerical qualification of particle collision.
- New native nested-call tests pass 512 shared-reference/counter/guard checks
  and three queued graph replays, then run untraced with batch size 16
  (sibling `command-383.log`). Unit negatives cover a second aliased invocation,
  a different protected field clobbered by the same call, dynamic offsets and
  transitive signed-offset overflow. All **32** focused compiler/GPU regressions
  pass (`command-387.log`). All **ten** native PhysX component gates also rebuild
  and pass with binary shim disabled and no forced per-kernel waits:
  `out/build/macos-cumetal/release/gpu/runs/20260921T155624.757249Z-54990/command-04.log`.
- Diagnostic copies only: initializing inactive particle work records clears
  the first pointer error but exposes a ConvexCore payload proof (`command-386.log`).
  Honoring the existing disabled-ConvexCore option in that copy emits MSL
  (`command-388.log`). Neither edit is in production PhysX nor has runtime
  qualification. Any retained source fix needs actual active/inactive-tail
  kernel coverage. No weakened pointer proof or new particle exclusion was added.
- Full GPU integration, scene/TGS correctness, conditional graphs, GPU CUB,
  IEEE64 inertia, inline-PTX trap error paths, integrated destruction and video
  remain unfinished. System/toolchain/install state is unchanged. Linux was
  not executed.

- **Simulation controller / optional SDF construction:** The selected
  complete `PhysXSimulationControllerGpu` target builds with all its particle
  kernels included:
  `out/build/macos-cumetal/release/gpu/runs/20260921T154036.809243Z-28484/command-03.log`.
  Archive: 2,343,096 bytes, SHA256
  `09883d588493ed38f0015942f4c33fce3dc5e5c02d51716ff55ae0c0c572a444`.
  Actual `particlesystem` object: 241,568 bytes, SHA256
  `80865d11e7277864defc5a74221adcee8a63f0e9df58e5befc575da601c91100`.
  `anisotropy`: 51,520 bytes, SHA256
  `ecf9c61e0f45c22b60999e5b70b9d9efe86671b753a72967fcf712cb30ecf492`.
  Compilation is not simulation/particle numerical qualification.
- `PX_CUMETAL_ENABLE_GPU_SDF_BUILDER=OFF` is the explicit macOS default;
  `--cumetal-gpu-sdf-builder` opts in. CUDA retains the original builder and
  rejects this backend-specific flag. The manifest records the choice.
  Only `SDFConstruction.cu`, its 18 builder-only kernel names, `PxgSDFBuilder.cpp`
  and its static registration call are excluded. Existing SDF geometry and
  collision kernels remain included. No generic missing-kernel waiver exists.
  `createSDFBuilder` reports `eINVALID_OPERATION` and returns null before context
  use, allocation or kernel loading. Construction still needs unsupported
  device fences on the retained Xcode; fence semantics were not weakened.
- Both feature states pass the host smoke gate, checking the exact preflight
  helper, error callback and registry scope (0/18 builder kernels, SDF collision
  retained): `host/runs/20260921T152710.388398Z-5694/command-02.log` and
  `host-convexcore-enabled/runs/20260921T152821.851723Z-10261/command-02.log`,
  relative to `out/build/macos-cumetal/release/`. The second tree has both optional
  features enabled. The actual disabled GPU factory object compiles (sibling
  `command-369.log`) and has no unresolved SDF builder references. These checks
  do not exercise the factory through a linked full GPU module, nor qualify
  the enabled GPU service. Helper safety tests are now **24/24** (`command-365.log`).
- CuMetal now lowers scalar LLVM binary32/binary64 `minnum`/`maxnum` exactly with
  integer bit ordering: one quiet NaN yields the other operand, signaling NaNs
  quiet, and subnormal/full binary64 bits are retained. Native tests check
  1,600 results, including signed zeros and single-ULP binary64 distinctions;
  emitted LLVM confirms all four intrinsic paths (`command-367.log`, `368`).
  Half/vector forms and other min/max intrinsic families remain unsupported.
- The actual `particlesystem.cu:2849` conditional selects a local float4 or a
  device-memory float4. CuMetal now lowers direct mixed-space loads lazily and
  stores through mutually exclusive branches using the existing runtime tag.
  It does not invent a device origin. Constant destinations and missing pointer
  payload tags reject. Native tests check 2,048 values/untouched fields across
  private/shared/device memory with three queued graph replays, then untraced
  batch size 16 (`command-373.log`); emitted MSL proves the fixture exercises
  direct tagged accesses (`command-376.log`).
- All **31** focused compiler/GPU regressions pass (`command-375.log`), and all
  **ten** native PhysX component gates rebuild/pass with binary shim disabled
  and no forced per-kernel waits:
  `out/build/macos-cumetal/release/gpu/runs/20260921T154206.989445Z-34077/command-04.log`.
- Full `PhysXGpu` remains **failed** at
  `out/build/macos-cumetal/release/gpu/runs/20260921T154341.305642Z-36561/command-03.log`:
  the two narrowphase particle pointer proofs and missing destruction conditional
  graph APIs remain. This supersedes earlier simulation-controller failures,
  not the remaining full-module or numerical gates. Full TGS, GPU CUB, IEEE64
  inertia, inline-PTX trap error paths, integrated destruction and video remain
  unfinished. No system changes, installation or Linux execution occurred.

- **Global float reduction / complete articulation build:** The
  compiler implements `red.global.add.f32` and its explicit relaxed GPU-scope
  forms through an atomic 32-bit CAS loop. It preserves signed subnormal
  flushing for both inputs and the result, and normal precise-mode ties-even
  addition. Reductions keep their address register as an input, preserve
  generic-pointer metadata across inline-assembly byte views, and guard the
  complete memory operation for either predicate direction. Other reduction
  variants and shared pointers passed to the global-only operation reject.
  No PhysX algorithm, precision, tolerance or build flag changed.
- The native reduction fixture passes on M3 Max with 1,024 contending threads,
  19 boundary pairs (signed zero, input/result subnormals, rounding ties,
  infinities and NaNs), both predicates, existing shared float atomic behavior,
  and three queued graph replays before observation. Provenance plus untraced
  batch size 16 pass (`../cuda-metal/out/tests/pointer-tuples/command-360.log`).
  Unit negatives cover unsupported scope/ordering/type, malformed operands,
  wide payloads and wrong address spaces. All **29** focused compiler/GPU
  regressions pass in sibling `command-362.log`.
- The **complete PhysXArticulationGpu target builds**, superseding its earlier
  reduction failure:
  `out/build/macos-cumetal/release/gpu/runs/20260921T151629.739546Z-85477/command-03.log`.
  Archive: 765,048 bytes, SHA256
  `f2011691e5574303adad770a47b300ffa1aa3e40c380ad39e716eef254c9ca19`.
  Actual `inverseDynamic` native object: 64,672 bytes, SHA256
  `a479e58b75cf2146ad99884ef8f38487d235ee0132a793583f8ba0742964e0da`.
  Compilation does not qualify articulation/TGS numerical scene behavior.
- Full `PhysXGpu` still fails:
  `out/build/macos-cumetal/release/gpu/runs/20260921T151725.286963Z-88260/command-03.log`.
  It confirms the two particle pointer-proof failures and now directly reports
  missing runtime conditional-graph declarations/functions in destruction:
  `cudaGraphConditionalHandle`, `cudaGraphSetConditional`, `cudaGraphNodeParams`,
  conditional IF/default flags and `cudaStreamBeginCaptureToGraph`. No placeholder
  implementations or kernel exclusions were added. Previous simulation-controller
  SDF fences and `llvm.maxnum.f32` remain unqualified; this run stops earlier.
- All **ten** native PhysX component gates rebuild/pass with the final compiler,
  binary shim disabled and no forced per-kernel host synchronization:
  `out/build/macos-cumetal/release/gpu/runs/20260921T152014.097301Z-95366/command-04.log`.
  Full GPU linking, scene correctness, inline PTX trap error paths, GPU CUB,
  conditional transactions, IEEE64 inertia, integrated destruction and video
  remain incomplete. No install, system changes or Linux execution occurred.

- **Wide bit operations / pointer PHI joins:** CuMetal imports
  `__nv_clzll`, `__nv_popcll` and `__nv_ffsll` with the exact `i32(i64)`
  signature. Native tests check 960 exact 32/64-bit results, including zero,
  every single-bit mask, every single-bit-cleared mask and patterned values;
  five malformed signatures per intrinsic reject. The first-set-bit lowering
  explicitly converts the trailing-zero count to its result width.
- A pointer PHI edge's existing `undef` refinement now materializes typed null
  with generic-null metadata. Poison remains rejected, and real pointers gain
  no null metadata or address-space cast permission. A defined CUDA loop checks
  96 empty/nonempty results across private/shared/device pointers. Both new
  fixtures pass on M3 Max with provenance and then untraced batch dispatches.
  Sibling `command-347.log` records these focused checks; **28** focused compiler
  and GPU regressions pass in `command-349.log` after relinking unit tests.
- Actual `articulationDirectGpuApi.cu`, `forwardDynamic2.cu` and
  `internalConstraints2.cu` compile to native objects. The full articulation
  target still fails on `red.global.add.f32` through `atomic.cuh:152` in
  `inverseDynamic.cu`:
  `out/build/macos-cumetal/release/gpu/runs/20260921T150304.274861Z-62749/command-03.log`.
  This supersedes earlier bit-count/null-cast failures. Artifacts (bytes; SHA256):
  `articulationDirectGpuApi`: 116208;
  `69ffb724189c1bcdee94f1dc2e670d0c214292640220c3d972cd39ea656eecb7`.
  `forwardDynamic2`: 268184;
  `e8b4f5c6b3f225c3ba6c8a6f6e19f4a6a1a9d37e966e182e836ad929ea420261`.
  `internalConstraints2`: 279920;
  `27b12d01ad008a0dfc6f8f92d024ef2e2f48f8594a9eb5a0e181d7d3bc758b3f`.
- All **ten** native PhysX gates rebuild and pass with the final compiler,
  binary shim disabled, and no forced per-kernel host synchronization:
  `out/build/macos-cumetal/release/gpu/runs/20260921T150413.706487Z-66810/command-04.log`.
  This validates the existing component gates, not full articulation/TGS or
  destruction. No PhysX equation, tolerance, precision or execution option was
  changed for these compiler fixes. macOS 14.4 / Xcode 15.4 remain unchanged;
  no install, Linux execution or video is claimed.

- **Response stamps / full solver compilation:** CuMetal now defaults
  `PX_CUMETAL_SPLIT_RESPONSE_STAMP=ON`. Every patch writer in a pass stores the
  same epoch, and readers/next pass join all writers. Two 32-bit atomic stores
  preserve the final 64-bit stamp under this protocol; ABI, equations and
  general CuMetal atomic/fence semantics are unchanged. The helper records
  the option and ordering contract. `--cumetal-atomic-response-stamp` opts back
  into wide atomic exchange; CUDA retains that original branch by default.
  See [the source ordering audit](CUMETAL_CONTACT_RESPONSE.md).
- The new `PhysXCuMetalContactResponseTest` calls the actual publication helper
  with real PGS/TGS header layouts, 1,024 patch threads, four exact 64-bit epochs,
  skipped contacts and whole-record sentinel checks. Three graph replays queue
  before observation, followed by two writer streams and event-joined readers.
  Both native variants pass; all **ten** native PhysX gates pass with the final
  sources and binary shim disabled:
  `out/build/macos-cumetal/release/gpu/runs/20260921T144551.818212Z-41124/command-04.log`.
  Raw-address mode still serializes resource hazards; no cross-stream hardware
  overlap or full TGS numerical claim is made. The 23 helper tests pass in
  sibling `command-333.log`; original atomic-branch frontend compilation passes
  in `command-335.log`, which is not NVIDIA/Linux execution.
- The complete `PhysXSolverGpu` target now builds, including all PGS/TGS source
  files, initially in
  `out/build/macos-cumetal/release/gpu/runs/20260921T143930.845461Z-27969/command-03.log`,
  and after the header change below in
  `out/build/macos-cumetal/release/gpu/runs/20260921T144504.840553Z-38472/command-03.log`.
  The latter run then fails in articulation; the overall run is not a pass.
  Final solver archive: 988,400 bytes, SHA256
  `d7057b9366161a9d86272878bb48b942fe78296a59f14335a7cec77a50e4f95e`.
  Actual TGS object: 144,080 bytes, SHA256
  `4db52f9d89ca39b2e1dec78aaa40a1fb0242f995e562892965ab1376f4745081`.
  Broadphase also builds in `out/build/macos-cumetal/release/gpu/runs/20260921T144026.986389Z-30587/command-03.log`.
- CuMetal provides the required mixed `int`/`unsigned int` min/max overloads in
  both argument orders, implementing unsigned promotion from the
  [public CUDA 12.8 contract](https://docs.nvidia.com/cuda/archive/12.8.0/cuda-math-api/cuda_math_api/group__CUDA__MATH__INT.html).
  Host/device boundary cross-products, result types and existing native-AOT
  signed/unsigned wide overloads pass (sibling `command-337.log`). No NVIDIA
  headers were copied. This clears `SDFConstruction.cu:208` without a PhysX edit.
- Remaining component failures: simulation-controller SDF construction reaches
  unavailable device fences, while particle `anisotropy.cu` reaches unsupported
  `llvm.maxnum.f32`:
  `out/build/macos-cumetal/release/gpu/runs/20260921T144417.126727Z-36856/command-03.log`.
  Articulation reaches inline `red.global.add.f32`, `__nv_clzll`, `__nv_popcll`
  and invalid emitted null-pointer casts (`articulationDirectGpuApi.cu`): the
  `144504` log above. Narrowphase retains its particle pointer-proof failures.
  No optional particle/SDF/articulation exclusion or missing-kernel waiver was
  added. The previously recorded inline PTX trap omission remains unresolved.
- Full scene/TGS numerics, destruction primitives, integrated destruction,
  corrected publication, warm-start qualification, scaling and video remain
  unfinished. Linux execution is unavailable. No install or system changes.

- **Runtime-valued memset / prior regression:** CuMetal normalizes
  nonvolatile runtime-length or runtime-byte LLVM memset into GPU byte loops.
  Zero work bypasses stores; length/index widths, i8 truncation and storage
  spaces are preserved. Constant fills keep wider stores; volatile fills are
  still rejected. No PhysX source workaround was needed.
- All **25** focused compiler/GPU gates pass in sibling
  `out/tests/pointer-tuples/command-329.log`. The new fill test checks every byte
  and guard in private/shared/device storage, negative and large fill values,
  unaligned and zero ranges, cross-warp visibility and three queued graph
  replays; it also passes untraced with dispatch batch size 16. Full provenance
  is preserved in sibling `out/tests/pointer-tuples/memset-final-lasttest.log`.
- All **eight** native PhysX numerical GPU gates pass after the final compiler
  rebuild, with the binary shim disabled:
  `out/build/macos-cumetal/release/gpu/runs/20260921T143029.318082Z-17381/command-04.log`.
  Actual `artiConstraintPrep2.cu` now emits a 116,944-byte native AOT object,
  SHA256 `833279073ec26206d1e8e7fe94a0424160fe21819a1ad97451c02cc1c3ab77cf`.
- Full solver still **fails** in
  `out/build/macos-cumetal/release/gpu/runs/20260921T142756.858659Z-11478/command-03.log`.
  The dynamic-byte memset failure is cleared; `solverMultiBlockTGS.cu` still
  needs the fence-dependent 64-bit response stamp in `PxgContactResponse.cuh`.
  This is separate from contact lifetime allocation. General wide atomics,
  full contacts/TGS, integrated destruction and native video remain unqualified.
  Linux CUDA execution remains unavailable. No system changes or installs.

- **Ordered contact lifetimes:** CuMetal defaults
  `PX_CUMETAL_SERIAL_CONTACT_IDS=ON`. One GPU block reserves exact 64-bit
  lifetime ranges with unchanged exhaustion rules. Launches sharing a sequence
  must be ordered on one stream or through events; production uses the
  narrowphase stream. Invalid launch dimensions latch error mask 4 before
  counter/identity mutation. Manifold-only resets retain their existing grid.
  The helper records the option and ordering contract in the manifest.
  `--cumetal-parallel-contact-ids` opts back into atomic multi-block allocation,
  still unqualified on Xcode 15.4. CUDA keeps the original concurrent allocator.
- The original allocator tests now live in shared
  `physx/source/gpudestruction/tests/contact_identity_test.cuh`, used by both the
  full contact graph test and `PhysXCuMetalContactIdsTest`. Existing tails,
  uniqueness, retained storage, reuse and exhaustion checks remain. New cases
  check low-word carry, three queued graph replays, empty work and five invalid
  dimension configurations. Both native variants pass; all **eight** native
  PhysX numerical gates pass in
  `out/build/macos-cumetal/release/gpu/runs/20260921T142101.524912Z-98912/command-04.log`.
  The 22 helper safety tests pass in sibling `command-318.log`.
- The full contact graph source passes Clang/CuMetal frontend compilation with
  both serial and atomic branches (sibling `command-321.log`, `command-322.log`).
  These are not Linux CUDA runs or full graph numerical passes. The production
  host launch compiles (`command-324.log`). Actual `pairManagement.cu` emits a
  41,608-byte native AOT object, SHA256
  `701538fed55dc2a9f788d7549428a5ccd13cac13b908b5e0c96e4f7bbd77aa54`.
- Full narrowphase remains **failed**, now without the pair-management fence
  error:
  `out/build/macos-cumetal/release/gpu/runs/20260921T141319.819095Z-94387/command-03.log`.
  Remaining failures: an incoming uninitialized pointer at
  `cudaParticleSystem.cu:1305`, and an unproved field clobber through
  `bv32TreeTraversal` at `particleSystemMeshMidphase.cu:326`. Particle support
  remains in the build/registry; no exclusion or relaxed proof was retained.
- The required solver inventory also remains **failed**:
  `out/build/macos-cumetal/release/gpu/runs/20260921T142228.811660Z-3390/command-03.log`.
  `artiConstraintPrep2.cu` reaches an unsupported dynamic-byte LLVM memset;
  `solverMultiBlockTGS.cu` reaches wide-atomic fences unavailable on Xcode 15.4.
  The contact-ID execution option does not fix general wide atomics. Full TGS,
  integrated destruction and native video remain unfinished. No system change,
  installation, Linux execution or numerical relaxation was performed.

- **Optional ConvexCore boundary / finite trap math (prior gate):** the helper now
  defaults `PX_CUMETAL_ENABLE_CONVEX_CORE=OFF` and records `optional_features` in
  manifests. `--cumetal-convex-core` opts in explicitly for investigation. CUDA
  keeps its original source list and kernel registry. Exactly the optional five
  names/source/dispatch methods are excluded; required missing/ambiguous lookup
  errors are unchanged. In this CuMetal SDK, creation, geometry mutation,
  attachment and scene insertion reject ConvexCore, including restored actors,
  batches, collections, aggregates and articulation links. This also restricts
  CPU scenes in the disabled-feature SDK; the enabled host variant retains it.
- Host release tests pass with the option **off**:
  `out/build/macos-cumetal/release/host/runs/20260921T134204.522913Z-43301/command-02.log`
  and **on**:
  `out/build/macos-cumetal/release/host-convexcore-enabled/runs/20260921T134414.851795Z-47498/command-02.log`.
  Rejection tests deliberately model restored unsupported geometry through an
  internal test seam; they cover factory/mutation/attachment and actor, batch,
  collection and aggregate insertion. Both modified narrowphase host objects
  compile (`../cuda-metal/out/tests/pointer-tuples/command-315.log`). The helper's
  21 safety tests pass (`command-300.log` in that sibling test directory).
- CuMetal accepts audited scalar float32 sqrt/fabs/tanh/min/max/fmin/fmax calls
  in trap-capable graphs, retaining integer builtin behavior and rejecting
  unknown or malformed signatures and unaudited software-double variants.
  `llvm.trap` immediately before `unreachable` becomes one reporting terminator;
  other placements fail. Native GPU regression checks math results, independent
  healthy/faulted streams, sticky launch failure and an untraced batch-enabled
  run. All 23 focused compiler/GPU gates pass in sibling `command-312.log`.
- All six native PhysX numerical GPU gates pass after these changes:
  `out/build/macos-cumetal/release/gpu/runs/20260921T135540.981567Z-74491/command-04.log`.
  The actual sphere collision source now compiles to a 137,912-byte native AOT
  object (SHA256 `f60167b28f6408578a730b6e74348d8dc3d957e61c702902249d231c4993e137`).
- Full narrowphase remains **failed**:
  `out/build/macos-cumetal/release/gpu/runs/20260921T135720.378696Z-76904/command-03.log`.
  `cudaParticleSystem.cu:1305` reads a `PxgCellData::particleSystem` pointer on a
  path without initialization. Particle support is outside the initial rigid
  destruction scope but remains in the current build/registry; no particle
  exclusion or pointer-proof relaxation has been made.
  Required `pairManagement.cu` also fails in the installed Metal compiler:
  `contactIdentity::reserve` uses 64-bit atomic add/CAS, whose current CuMetal
  lock helpers emit `memory_order_seq_cst` / `thread_scope_device` fences missing
  from this toolchain. The emitted source is preserved in the sibling
  `out/tests/pointer-tuples/pair-management.msl` (`command-314.log`). Keeping
  macOS 14.4/Xcode 15.4 requires a proved execution/resource alternative; removing
  fences or reducing generation widths would not be a correctness fix.
- **Discovered, not fixed:** source-first inline PTX `asm volatile("trap;")` is
  omitted by the existing inline-assembly importer. A blanket rejection exposed
  PhysX's ownership-capacity guard (`PxgBroadPhaseGroups.h:20`) and was not
  retained. The standard LLVM trap fixture passes, but it does not qualify this
  inline form or trap cancellation around barriers/collectives. Valid-input
  numerical gates do not establish the failure-path contract. This remains a
  required correctness gap before integrated native acceptance.
- No system upgrade, global installation, staged install, Linux execution,
  physics equation/precision/tolerance changes, destruction run or video. Full
  contacts/TGS, destruction primitives, integrated correction/warm-start tests
  and measured scaling remain outstanding.


- CuMetal caches complete successful preservation proofs by protected
  allocation, function and actual allocation/storage facts (16,384-entry cap;
  existing analysis budgets unchanged). Shared/private calls to the same helper
  remain separate. Early local failures are freshly checked after helper facts
  settle, and only proved producers replace provisional descriptor defaults.
- Exact integer equality/inequality guards follow formal/actual SSA values
  across calls. Facts are bounded and discarded at definitions, joins and copy
  snapshots. Tests reject mismatched/reversed guards, partial writes, backedge-only
  initialization, different memory snapshots and cross-context aliasing.
- Sixteen focused gates pass (sibling `command-296.log`). The nested-capture GPU
  case now also preserves an address-exposed private cell across shared writes
  and reads a conditional cell only for a matching valid index, with three graph
  replays and untraced batching. All six native PhysX numerical GPU gates pass:
  `out/build/macos-cumetal/release/gpu/runs/20260921T132512.686688Z-16503/command-04.log`.
- Full narrowphase still fails:
  `out/build/macos-cumetal/release/gpu/runs/20260921T132807.696660Z-21032/command-03.log`.
  The remaining `PointsCore` producer rejection is across `makeConvexShape` at
  `convexCoreCollision.cu:531`; later support selection is not correlated with
  the factory's different geometry-tagged representations. The prior callback
  budget, mixed shared/private write and invalid-index initialization failures
  are cleared. Full contacts/TGS, integrated destruction and native video are
  not qualified. No equations, tolerances, source hints, system changes or
  installations changed; Linux CUDA execution remains unavailable.
- Scope audit: the native demo creates boxes and sphere projectiles, and native
  collision tests also exercise convex meshes. No `PxConvexCore`/`eCONVEXCORE`
  use was found in `demos/blast-stress-demo` or `physx/source/gpudestruction`.
  The failing source defines five optional ConvexCore geometry kernels. The
  later boundary in this ledger supersedes the originally unimplemented scope
  audit; excluding this optional feature does not establish ConvexCore support.

- The previously rejected nested private-capture fixture now executes on
  Apple GPU. `functional_cumetalc_captured_descriptor_callback` checks four
  warps, 512 side effects per replay, three graph replays, and an untraced
  batch size of 16. Fourteen focused gates pass (sibling `command-272.log`);
  rebuilt PTX/MSL and scalar-zero-guard gates pass (`command-274.log`).
- CuMetal now follows contained typed pointer captures, checking disjoint byte
  ranges and escapes. Allocation identity may cross calls; memory proof states
  retain their caller frames. Tests reject partial and transitive writes, loop
  clobbers, scalar address escapes and exported containers. A positive test
  covers a capture made from an outer helper's formal reference. Late proofs
  detach provisional descriptor flows before defaults; captured helper fields
  cannot skip proof merely because their allocation identity is unresolved.
- All six native PhysX numerical GPU gates pass with the corrected compiler:
  `out/build/macos-cumetal/release/gpu/runs/20260921T125840.532407Z-91273/command-04.log`.
  An intermediate strict-check regression in block scan was corrected before
  this run. The existing multiple-direct-object typed-record contract remains.
- Full narrowphase still fails:
  `out/build/macos-cumetal/release/gpu/runs/20260921T125930.826260Z-93652/command-03.log`.
  The remaining rejection is `convexCoreCollision.cu:1006:54`, where a captured
  shared reference lacks a proved preserved caller-frame object through the
  traversal helper. The small nested-capture gate is now qualified, but full
  contacts, TGS, integrated destruction and video are not. No equations,
  tolerances, source hints, system toolchain or installations changed. Linux
  CUDA execution remains unavailable.

- CuMetal now carries proved allocation identities through each call's formal
  arguments; the visited key includes the function and its bindings. Repeated
  helpers cannot borrow another invocation's disjointness. Unknown origins,
  mixed destinations, and exhausted proof budgets remain conservative failures.
- Existing scalar inverse-trigonometric, bit-scan and signed-absolute-value
  builtins have read-only effects. `sincos`/`sincospi` instead record both scalar
  output writes, four or eight bytes each. Malformed/unmarked calls reject.
  This changes effect analysis, not math implementations or tolerances.
- Thirteen focused gates pass (sibling `command-244.log`), including nested
  call aliasing, exact output widths and aliased-output cases. Rebuilt PTX/MSL
  and scalar-zero-guard integration tests also pass (`command-248.log`). All
  six native PhysX GPU gates pass:
  `out/build/macos-cumetal/release/gpu/runs/20260921T122935.184458Z-57972/command-04.log`.
- The full narrowphase build still fails:
  `out/build/macos-cumetal/release/gpu/runs/20260921T123054.659184Z-60344/command-03.log`.
  Improved diagnostics identify `Contact32::addPoints` at
  `convexCoreCollision.cu:784` (unresolved address-space mask zero), while
  checking the byte-copied `PointsCore` pointer at `GuConvexSupport.h:362`.
  Earlier `acos`, `sincos` and bit-scan effect failures are cleared; shared
  contact/capture provenance remains incomplete. Full narrowphase, TGS,
  destruction and video are unfinished. No Linux execution, staged installation,
  system changes, numerical relaxation, or new PhysX source hint.


- CuMetal now proves preservation of a captured private record across calls
  whose transitive writes are in concrete nonprivate storage or separate owned
  allocations. Other writes still require the complete no-escape alias closure.
  Unknown calls reject except the existing read-only scalar builtin allowlist;
  C++ `const` is not treated as proof of a read-only implementation.
- Twelve focused gates pass (sibling `command-223.log`), including device/shared
  disjoint-write positives, indirect captured-clobber negatives and transitive
  opaque-call rejection. All six native PhysX GPU gates pass:
  `out/build/macos-cumetal/release/gpu/runs/20260921T121027.341398Z-33740/command-04.log`.
- The old convex-core callback-clobber failure is cleared. Full narrowphase now
  rejects a later mesh-descriptor proof at `convexCoreCollision.cu:674`, across
  `generateContacts` at line 1242:
  `out/build/macos-cumetal/release/gpu/runs/20260921T121133.071135Z-36106/command-03.log`.
  The separate nested private-capture fixture still fails before GPU execution
  (sibling `command-224.log`). Call-context aliasing and captured-reference origin
  work remain. Full narrowphase, TGS, destruction and video are incomplete.
  No Linux execution, installation, system changes or numerical relaxations.


- Mesh-midphase compilation is restored. CuMetal was discarding a proved
  reference origin when its raw incoming argument had no layout yet; it now
  retains the proved base/offset so a later typed field access supplies that
  layout. Unknown/integer-derived origins and incomplete reference initializers
  still reject. No address-space default or alias guarantee was added.
- The new focused regression fails before the fix (sibling `command-208.log`)
  and passes afterward. Twelve focused gates pass (`command-213.log`); the GPU
  record-builder fixture checks 160 values per replay, including raw shared
  scratch referenced by a local record, across three graph replays and an
  untraced batch-16 pass. The actual `convexMeshMidphase.cu` compiles to a native
  object (`command-211.log`, SHA-256
  `dfbebd9ab7c0d83b4c0abc66b85ee3a457c7be71b1107bcbac07b887e9c99e2d`).
  This is compilation evidence, not full numerical midphase qualification.
  All six native PhysX gates pass:
  `out/build/macos-cumetal/release/gpu/runs/20260921T115930.639794Z-18989/command-04.log`.
- The latest full build still rejects the convex-core callback proof:
  `out/build/macos-cumetal/release/gpu/runs/20260921T120034.568352Z-21366/command-03.log`.
  It stops before scheduling midphase; the native-object evidence above is a
  separate source compilation. Inlining both convex callbacks in a temporary
  source copy only moves the failure to `Contact32::addPoints`
  (`command-214.log`); no such hint was applied to PhysX. Full narrowphase,
  TGS, destruction and video remain unfinished. No Linux execution, installation,
  system changes, or numerical relaxations were performed.


- The unresolved `TrimeshBvh::getTriBarycentric` vertex pointer was traced to
  the device FEM cloth descriptor. CuMetal now applies its external descriptor
  pointer contract before validating exact local copies: concrete global
  storage, no resolved producer, and no possibly external pointer store are
  required. Local/shared and mixed storage do not receive this early default.
  Existing private producers and pointer clobber checks remain intact.
- Twelve focused compiler/GPU gates pass (sibling `command-199.log`). The
  record-builder fixture checks 128 results per replay, including host-uploaded
  device descriptors copied and read through separate helpers. Three graph
  replays and an untraced batch-16 pass execute on Apple GPU. Unit negatives
  cover uninitialized and partially overwritten local input records. All six
  native PhysX gates pass:
  `out/build/macos-cumetal/release/gpu/runs/20260921T114835.273767Z-98645/command-04.log`.
- Latest full narrowphase attempt:
  `out/build/macos-cumetal/release/gpu/runs/20260921T114931.212791Z-1884/command-03.log`.
  Convex-core compilation advances to an unproved callback clobber at
  `GuConvexSupport.h:362` / `convexCoreCollision.cu:589` (sibling `command-194.log`).
  The broader build also reaches an unresolved BV32 pointer at
  `convexMeshMidphase.cu:102`. Disabling only the descriptor fix reproduces the
  latter (`command-201.log`); the temporary diagnostic switch was removed.
  Earlier midphase object compilation is historical, not current qualification.
  Full narrowphase, TGS, destruction and video remain unfinished. No Linux
  execution, staged installation, system changes or numerical relaxations.


- Complete memcpy byte ranges now recover their original pointer producer
  across unaligned buffers without changing byte operations or layouts. The
  proof requires all eight bytes from one copy group, consistent source offsets
  and disjoint storage, with at most 128 operations per candidate. Partial
  groups, clobbers and unresolved aliases reject. Owned helper records use
  exact producer bindings; final enforcement waits for origin recovery. The
  existing no-escape proof now covers direct scratch writes as well as calls.
- Twelve focused compiler/GPU gates pass in sibling `command-184.log`; the
  diagnostic-only rebuild passes the unit gate in `command-187.log`. The new
  byte-record GPU fixture retains memcpy byte operations and checks 96 values
  per replay for private/shared/device pointees at odd offsets. The transfer
  gate additionally checks 192 swap/ordered-copy values across a warp barrier.
  Both use three graph replays and an untraced batch-16 run. All six native
  PhysX GPU tests pass:
  `out/build/macos-cumetal/release/gpu/runs/20260921T113038.982491Z-75769/command-04.log`.
- Latest full narrowphase failure:
  `out/build/macos-cumetal/release/gpu/runs/20260921T113444.687775Z-81953/command-03.log`.
  The precise reproduction (sibling `command-186.log`) identifies `trimeshVerts`
  in `TrimeshBvh::getTriBarycentric`, `convexCoreCollision.cu:678`, with an
  unresolved pointee-space mask of zero. The earlier byte-store failure is no
  longer the first diagnostic; full convex-core contacts are not qualified.
  Captured private wrappers, full TGS, integrated destruction and video remain
  incomplete. Linux CUDA was not run. No installation or system changes.


- Call-output proofs now remove the mixed-field `readTriangleMesh` compilation
  failure without PhysX source edits. Every returning path must initialize the
  requested pointer field; disjoint scalar writes are preserved. Typed local
  pointer inputs need their own reaching-store proof, so a partial overwrite
  cannot hide behind a known record layout or a freshly initialized output.
  The proof has a 16-active-call bound plus existing analysis budgets.
  Eleven focused compiler/GPU gates pass in sibling
  `out/tests/pointer-tuples/command-158.log`, including branching builders with
  private/shared/device pointees, loaded offsets, scalar writes, three graph
  replays and an untraced batch-16 run. Negative cases cover missing paths,
  preexisting caller values, partial writes, opaque calls and partial/volatile
  typed input pointers; nested complete builders pass.
- The actual `convexMeshMidphase.cu` produces a native object with the hardened
  compiler (sibling `command-159.log`), and all six native PhysX GPU regression
  gates pass:
  `out/build/macos-cumetal/release/gpu/runs/20260921T111156.991212Z-50431/command-04.log`.
  Object compilation is not full midphase numerical qualification.
- The latest full narrowphase attempt still rejects raw-byte `PointsCore`
  initialization at `GuConvexSupport.h:362`:
  `out/build/macos-cumetal/release/gpu/runs/20260921T111251.438772Z-52401/command-03.log`.
  The private-wrapper callback reproduction also still rejects (sibling
  `command-160.log`). Full narrowphase/TGS, integrated destruction and video
  remain incomplete; Linux CUDA was not executed. No installation or system
  toolchain changes were made.


- Pointer-transfer summaries now remove the real `PxSwap` failure without
  changing PhysX source. Complete pointer-cell loads before any write are
  treated as entry snapshots; aliased arguments preserve the last-write
  result. Calls and writes remain emitted. Partial/volatile/uninitialized and
  read-after-write cases reject. Ten focused compiler/GPU gates pass in sibling
  `out/tests/pointer-tuples/command-142.log`, including conditional/self-swaps
  with separate private/shared/device pointer cells, 96 results per replay,
  three graph replays and an untraced batch-16 run.
- All six native PhysX GPU gates pass after this correction:
  `out/build/macos-cumetal/release/gpu/runs/20260921T105513.988567Z-31430/command-04.log`.
  The real `trimeshCollision.cu` now produces its native AOT object (50,672 bytes,
  SHA-256 `516eab7f8736a74ff83bea6a1fafc7ce83ea36e1698d5f2c0d45faf05d69aa31`).
  Object compilation does not qualify full trimesh collision behavior.
- Latest full narrowphase failure:
  `out/build/macos-cumetal/release/gpu/runs/20260921T105339.352768Z-26864/command-03.log`.
  `GuConvexSupport.h:362` still copies `PointsCore` through raw bytes, and
  `convexMeshMidphase.cu:1449` loads a pointer initialized by the mixed-field
  `readTriangleMesh` helper. The nested captured-callback gap remains open.
  Full narrowphase/TGS, integrated destruction and native video are incomplete.
  Linux CUDA was not executed. No installation or system/toolchain changes.


- Complete aligned typed aggregate copies now preserve pointer leaves and
  storage provenance in CuMetal. Partial/unaligned/unknown-layout copies retain
  byte lowering; volatile copies remain rejected. Eight focused compiler/GPU
  gates pass in sibling `out/tests/pointer-tuples/command-103.log`; the stronger
  private-memory dereference assertion passes in `command-105.log`. The new
  direct shared-copy test covers four warps, exactly 128 writes and three graph
  replays, including an additional run with tracing off and batch size 16.
- Exact constructor writes, identity-return origin propagation and bounded
  no-escape private-object proofs now qualify direct repeated callbacks. Calls
  retain their side effects. Failed local reference proofs remain rejected even
  when a syntactic layout slot exists; partial writes and indirect captured
  clobbers are negative tests. Kernel by-value descriptor copies explicitly
  retain device pointer leaves, while helper copies stay generic.
  Nine focused compiler/GPU gates pass in sibling
  `out/tests/pointer-tuples/command-134.log`, including four warps, three callback
  invocations per thread and exactly 512 side effects on each of three graph
  replays. The callback test repeats with tracing off and batch size 16.
- All six native PhysX gates pass after the constructor/origin corrections:
  `out/build/macos-cumetal/release/gpu/runs/20260921T103639.833601Z-6890/command-04.log`.
  The callback captured inside another private wrapper remains unsupported:
  the fixture's `CUMETAL_TEST_CAPTURED_CALLBACK` variant fails before shader
  emission (sibling `command-127.log`). It is not a registered passing test.
  An experimental containment proof did not resolve its cross-function
  initialization chain and was removed.
- The latest full narrowphase attempt fails under the stricter local-field
  checks at `dataReadWriteHelper.cuh:347` (pointer swapping) and
  `GuConvexSupport.h:362` (raw-byte `PointsCore` initialization):
  `out/build/macos-cumetal/release/gpu/runs/20260921T103812.125559Z-9405/command-03.log`.
  These diagnostics supersede the earlier first failure at the BVH callback in
  `convexCoreCollision.cu:1162`; that captured-reference gap is still open.
  Full narrowphase/TGS, integrated destruction and native video remain
  unqualified. Linux CUDA execution remains unavailable. macOS 14.4 and Xcode
  15.4 remain unchanged at the user's request; Metal 3.2 standalone fence
  operations remain a separate toolchain constraint. No system or staged
  installation occurred during this work.


- Transactional reference proofs now cover loops anchored by one syntactic
  initializer address. They verify first-entry initialization and every
  intervening write/call, then check actual reaching sources; failed proofs
  roll back all dependent cached addresses. Guarded nonnegative signed indices
  can prove scratch writes disjoint, with checked arithmetic. Wrong-edge,
  bypassed and other-value guards, volatile reads, clobbers, uninitialized
  first entries and overflowing offsets remain rejected. The bound is
  1,048,576 steps per function, 16,777,216 per module and four rewrite rounds.
  Six compiler/Apple-GPU gates pass in sibling
  `out/tests/pointer-tuples/command-89.log`, including a descending signed loop,
  reference records, direct rebinding and negative signed widening.
- The unchanged shared GJK/EPA numerical gate now **passes on Apple M3 Max**
  in asynchronous and batched modes, checking separation/penetration/rotated
  boxes, points/normals, both shared/private support orientations and three
  captured replays at `1e-4` tolerance:
  `out/build/macos-cumetal/release/gpu/runs/20260921T093419.707637Z-36155/command-04.log`.
  Production pair/aggregate gates also pass (4/4):
  `out/build/macos-cumetal/release/gpu/runs/20260921T093612.486164Z-43998/command-04.log`.
- Final rebuild against the per-function-budget compiler passes all six native
  PhysX GPU gates (pair, aggregate and shared GJK/EPA; asynchronous and batched):
  `out/build/macos-cumetal/release/gpu/runs/20260921T093944.258074Z-50279/command-04.log`.
- The full `PhysXNarrowphaseGpu` attempt now reaches the tetmesh callback's
  `sh.writer.totalContactCount` at `convexCoreCollision.cu:1162`. Per-function
  analysis allowances remove the previous exhausted-budget diagnostic, but
  this nested shared descriptor pointer still has no proven slot/producer:
  `out/build/macos-cumetal/release/gpu/runs/20260921T093720.436313Z-45859/command-03.log`.
  It is rejected before emitting an unqualified shader. Full narrowphase/TGS,
  integrated destruction, scaling and video remain incomplete. Linux CUDA was
  not executed; no installation or system/toolchain change was made.

- Final shared-symbol correction connects stores and loads of direct shared
  pointer variables. The 32-lane GPU publication case and five related gates
  pass (`../cuda-metal/out/tests/pointer-tuples/command-49.log`); mixed
  private/device symbol producers are rejected without a tag (`command-51.log`).
  Production pair/aggregate builds and tests pass again (4/4):
  `out/build/macos-cumetal/release/gpu/runs/20260921T085021.438502Z-84970/command-04.log`.
  The final narrowphase attempt restores heightfield/trimesh compilation but
  still rejects the nested reference at `GuRefGjkEpa.h:79`:
  `out/build/macos-cumetal/release/gpu/runs/20260921T085140.272185Z-87754/command-03.log`.

- `PhysXCuMetalReferenceGjkTest` runs the shared reference GJK/EPA equations
  against CPU results for separation, penetration and rotated boxes. It checks
  distances, contact points and normals at `1e-4`, both shared/private support
  orientations and three captured replays. It **failed numerically** on Apple
  M3 Max in asynchronous and batched modes: a unit gap became GJK distance zero,
  then EPA returned `FLT_MAX`. Evidence:
  `out/build/macos-cumetal/release/gpu/runs/20260921T083138.348688Z-34135/command-04.log`.
  Diagnostic inputs, bounds and support vertices were correct; the first
  closest-point calculation was wrong. Temporary instrumentation was removed.
- CuMetal now rejects a local/shared pointer load when both its slot and its
  producer are unresolved. The numerical gate consequently stops at
  `GuRefGjkEpa.h:79` instead of emitting the incorrect shader:
  `out/build/macos-cumetal/release/gpu/runs/20260921T084600.892088Z-72738/command-03.log`.
  Production narrowphase also stops at that reference and at
  `convexHeightfield.cu:323` / `convexMesh.cu:681`:
  `out/build/macos-cumetal/release/gpu/runs/20260921T084632.368719Z-74639/command-03.log`.
  This intentional rejection replaces unsafe compilation; object-specific
  pointer provenance remains required. Existing typed host-descriptor copies
  still pass, but layout-wide field defaults are not a general provenance proof.
- Scalar LLVM funnel shifts, lifetime markers and typed record/null selects now
  lower through reusable CuMetal fixes. Six focused compiler/Apple-GPU gates
  pass at sibling `out/tests/pointer-tuples/command-47.log`, including the new
  nested-reference negative test. The helper's 20 safety tests pass at
  `out/tests/pointer-tuples/command-28.log`. No staging install was performed.

- Production `doAggPairCollisions` now executes through `PhysXCuMetalNativeAggregatesTest`.
  It links the actual `aggregate.cu` native object and checks aggregate/aggregate
  plus both aggregate/single orientations. Sizes 2, 17 and 35 cross warp and
  mask-word boundaries (up to 1,295 expected overlaps). Found/lost/persistent,
  removed/dead/filtered cases, same-owner suppression and different-owner
  admission, graph replay, multi-warp dispatch and bounded report writes are
  checked against host bounds comparisons. No GPU equations are duplicated.
  Combined pair and aggregate gates pass (4/4) in traced asynchronous and batched
  modes at `out/build/macos-cumetal/release/gpu/runs/20260921T081114.556428Z-88144/command-04.log`.
  Successful Apple M3 Max dispatch provenance is now retained in these per-run
  logs. The helper still requires explicit `--test` and never installs from a
  partial GPU gate. Its 20 safety tests pass at sibling CuMetal
  `out/tests/pointer-tuples/command-19.log`.
- Narrowphase's record-reference failure was revalidated against current source.
  Diagnostic inspection confirms `Convex::mS` and `Convex::mPose` receive both
  shared and private references. A single layout-wide tag is insufficient;
  object/call-site provenance must preserve these different contexts without
  changing record bytes or guessing address tags. Temporary instrumentation
  was removed. This remains an implementation gap, not a toolchain upgrade request.

- Production pair tests rerun after the independent pointer-tuple/header changes pass in
  both traced asynchronous and batched modes (2/2):
  `out/build/macos-cumetal/release/gpu/runs/20260921T075804.687312Z-56495/command-04.log`.
  The helper refreshed the partial component manifest and executable hash;
  this run did not install either project.
- Concrete pointer-context and signed pointer-difference Apple-GPU gates pass;
  unsigned/signed atomic min/max also passes, including high-bit values, old
  return values, and contended shared reductions. Together with NVVM and PTX
  helper compiler regressions, 4/4 pass at CuMetal
  `out/tests/atomic-minmax/command-2.log`.
- Finite-dispatch, dynamic-copy and NVVM regression gates pass (3/3) in CuMetal
  `out/tests/finite-dispatch/command-6.log`. GPU checks cover divergent function
  choices, aggregate results, exactly-once effects, a following barrier, and
  zero/unaligned copy ranges across device/private/shared storage. Unknown
  function pointers, mismatched signatures and volatile copies remain rejected.
  The extended scalar-return dispatch GPU case also passes in
  `out/tests/finite-dispatch/command-7.log`.
- Nested wrapper, pointer, finite-dispatch, dynamic-copy and compiler tests pass
  (6/6) in CuMetal `out/tests/nested-pointer-contexts/command-2.log`.
  Single-tag void/scalar calls now cover device/shared/private choices, pointer
  offsets, and exactly-once mutation; the GPU test and explicit rejection of
  untagged record loads pass in `out/tests/nested-pointer-contexts/command-8.log`.
- Earlier narrowphase compilation reached the record-reference
  failure before the inline hint and fail-closed guard at `out/build/macos-cumetal/release/gpu/runs/20260921T075948.484535Z-62524/command-03.log`.
  The installed macOS 14.4/Xcode 15.4 toolchain is retained at the user's request;
  standalone fence limitations remain recorded above.
- Full broadphase now builds after independent pointer-tag dispatch and C++14
  public-header fixes:
  `out/build/macos-cumetal/release/gpu/runs/20260921T075708.351130Z-53284/command-03.log`.
  Compiler/GPU pointer regressions pass (7/7) in CuMetal
  `out/tests/pointer-tuples/command-11.log`; C++14 header and affected GPU
  regressions pass (3/3) in `out/tests/pointer-tuples/command-14.log`.
  Tests cover eight pointers in two correlated groups, all four device/shared
  combinations, scalar/void results, exactly-once effects, and explicit
  rejection above 16 independent tuple combinations. The independent aggregate pair gate below adds numerical coverage; complete
  broadphase scene behavior remains unqualified.

- Executed: 20 repository-local Python safety tests; macOS release host build
  and host smoke test (ARM SIMD matrix, FPU reset/restore, serialization platform
  tag, and a CPU scene gravity step); relocated CuMetal staged-package consumer;
  native AOT two-module archive compile/link and correct Apple M3 Max execution,
  binary shim OFF. GPU trace is in CuMetal
  `out/tests/native-aot-object/gpu-run-confined.log`.
- ABI 4 staged package consumer and the final native descriptor negative tests:
  CuMetal `out/tests/native-aot-final/command-1.log` and `command-2.log`.
  Installation is development staging; it is not a claim that the failed
  standalone-fence test or the PhysX GPU gates pass.
- Host build manifest/logs: PhysX
  `out/build/macos-cumetal/release/host/`.
- Actual common-GPU component build passed at
  `out/build/macos-cumetal/release/gpu/runs/20260921T063606.697685Z-64480/command-03.log`.
  Integer min/max, null/shared helper calls, and native AOT lifecycle regression
  plus two compiler unit tests passed at CuMetal
  `out/tests/physx-common-compat/command-3.log`.
- Production native pair component test passed at PhysX
  `out/build/macos-cumetal/release/gpu/runs/20260921T064918.970400Z-92999/command-04.log`.
  Standalone block-sort positive/negative gate passed at CuMetal
  `out/tests/block-radix/command-1.log`.
- Both traced and untraced (16-dispatch batching enabled) native pair tests passed:
  `out/build/macos-cumetal/release/gpu/runs/20260921T065347.358982Z-5970/command-04.log`.
  The GPU-enabled PhysX host library and context-manager build also passed:
  `out/build/macos-cumetal/release/gpu/runs/20260921T065004.499492Z-95181/command-03.log`.
  Existing host CUB consumers plus the new GPU sort gate passed at CuMetal
  `out/tests/block-radix/command-3.log`.
- Full GPU build failure details:
  `out/build/macos-cumetal/release/gpu/runs/20260921T063733.298120Z-69216/command-03.log`;
  subsequent aggregate broadphase failure after block sort was implemented:
  `out/build/macos-cumetal/release/gpu/runs/20260921T064216.972509Z-79037/command-03.log`.
- Compiler build/test/install manifest/logs: PhysX
  `out/build/macos-cumetal/release/compiler/`.
- Not completed: Linux CUDA build/runtime (unavailable), full GPU module build,
  full TGS numerical
  tests, integrated Apple destruction, relocated PhysX NativeScene package
  consumer, destruction scaling. No historical result is counted as a new run.

Manifests and test logs describe individual runs, not release certification.
An unavailable or failed check is not a pass.

## Shared-source policy

Keep destruction equations, convergence decisions, correction limits and
warm-start representation shared. Put reusable compiler/runtime fixes in
CuMetal. Any later PhysX Metal-specific build flag must name the exact execution
or resource choice, retain the CUDA path, and add equivalence tests. Do not
weaken tolerances or introduce a separate Metal destruction implementation.

## Added final goal: macOS destruction video

Follow `.agents/skills/physx-destruction-video/SKILL.md` after integrated Metal
destruction is correct. Its current machine/rendering instructions describe a
Linux RTX 4090 CUDA/OpenGL implementation; the user has explicitly requested
porting the native capture path to macOS. This extends the earlier milestone to
include rendering after the simulation gates.

Render committed GPU cluster/projectile poses with the same ready/read-complete
event ownership rules. Port the demo renderer to Metal without scripted fracture,
CPU orchestration of physics, or use of the obsolete offline recorder. Keep
the flagship authored parameters (256 buildings, four waves, 30 seconds,
1,800 frames, 1080p H.264 at 60 fps); use the skill's documented 64-building
fallback only if needed and label it. A hero capture uses one correction maximum
as a capture setting, while the SDK still supports and tests 0/1/>1.

Deliver the captioned MP4, completed `native.summary.json`, `native.frames.csv`,
source/artifact hashes, actual Apple GPU identity, counts and camera setting.
Validate frame count and decode the final H.264. Label shared-GPU measurements
and do not infer real-time performance from playback rate. ffmpeg and ffprobe
are already installed in this session; no installation has been performed.


### GPU flagged compaction and counting iterator

Source-compiled `cub::DeviceSelect::Flagged` now executes three ordered GPU
kernels without host readback, allocation or synchronization. A per-block scan
records local ranks, one block scans block counts in tiles, and stable scatter
writes selected values. Same-stream scratch reuse and capture/replay retain the
same path. Null-scratch queries enqueue nothing; negative lengths and undersized
scratch reject before enqueue. CUB 2.x `CountingInputIterator` now supplies the
required index sequence without allocating an input array.

The M3 Max gate passes 55 configurations through 229,376 items, including
0/1/31/32/255/256/257 and multi-tile prefix boundaries 65,535/65,536/65,537.
None/all/alternating/pseudorandom/boundary flags cover stable ordering, pointer
and counting inputs, 32/64-bit selected counts, null empty inputs, unaligned
scratch, all untouched output and scratch guards, and two selections sharing
scratch. Three queued graph replays change their inputs on the GPU. Both traced
native AOT and untraced batch-size-16 runs pass with raw Metal device addresses
and the binary shim disabled. This qualifies flagged compaction, not integrated
destruction or throughput. The prefix step's single-block tiled execution and
broader iterator/value types still need measured scaling and qualification.

The test exposed a separate Metal 3.1 remainder miscompile: `(x >> 16) % 7`
could exceed its divisor. CuMetal now emits the exact quotient identity for
unsigned scalar remainders through 32 bits. A separate native GPU gate passes
393,216 arithmetic results and queued replay; compiler tests keep signed and
64-bit forms separate. No physics equation or tolerance was changed.

Evidence (2026-09-21): CuMetal `out/tests/pointer-tuples/command-404.log`
passes both new gates; final 32/64-bit compaction coverage passes `command-411.log`.
The 32 existing focused compiler/GPU regressions pass `command-406.log`, the
host-only CUB compatibility gate passes `command-405.log`, and extended width/
signedness compiler tests pass `command-408.log`. All 12 actual PhysX native
gates pass `gpu/runs/20260921T162851.915826Z-1667/command-04.log` beneath PhysX's
`out/build/macos-cumetal/release/`.

The full GPU build still fails on conditional graph APIs
(`gpu/runs/20260921T162653.666396Z-95495/command-03.log`); the complete narrowphase
component rebuilds successfully. A direct build of actual `NvBlastExtStressGpu.cu`
now passes its missing counting-iterator include and reaches `make_double3`,
cooperative graph-node attribute APIs, and missing `cub/block/block_load.cuh`
(`command-409.log`). Existing host block-load loops are not a GPU implementation.
`DeviceSelect::If`/`Unique`, device-wide sort/scan, conditional transactions,
bounded cooperative solver execution and FP64 inertia remain unfinished.
Full TGS scenes, correction limits, warm starts, integrated publication and
video acceptance remain unqualified. Linux CUDA execution is unavailable.
macOS 14.4 / Xcode 15.4 are unchanged; no installation was performed.


### GPU CUB primitives and the existing destruction contact-graph suite

The required source-compiled CUB paths now execute on GPU: flagged/predicate
selection, matching unsigned 32/64-bit `ExclusiveSum`, and stable unsigned
32/64-bit `SortKeys`/`SortPairs` (including descending and partial-bit forms).
They use caller scratch and ordered GPU launches, with no host readback,
allocation or stream synchronization. Size queries and rejected lengths,
scratch sizes or bit ranges enqueue nothing. CPU-only translation units retain
explicit host compatibility; this is not full CUB API/type coverage.

New numerical gates on M3 Max:

- Predicate selection: 32 configurations through 113,664 records, stable
  aggregate copies, counting inputs, device-pointer predicates, exact invocation
  counts and guarded outputs. Predicates may be device-only functions.
- Exclusive sum: 88 configurations through 229,377 entries, unsigned 32/64-bit
  wrap/carry, exact in-place and disjoint output, counting input, tiled block
  prefixes and guarded unaligned scratch. Signed/floating/mixed-width values
  reject at compilation; inclusive/custom-op scans remain host-backed.
- Radix sort: 70 configurations through 229,376 entries, 32/64-bit unsigned
  keys, stable pairs with unsigned 32-bit values, full/partial/empty bit ranges,
  ascending/descending ordering and both DoubleBuffer current sides. Signed,
  floating and narrow keys reject at compilation. The one-bit LSD passes and
  single-block tiled count prefixes are a correctness baseline; throughput and
  broader trivially-copyable value types are unqualified.

Each gate performs three queued replays with inputs changed on GPU, reuses
scratch for multiple operations, checks untouched inputs/outputs/guards, and
passes both traced native AOT and untraced batch-size-16 execution with raw Metal
device addresses and the binary shim disabled. Final CuMetal evidence is
`out/tests/pointer-tuples/command-421.log`: all seven selected GPU/host CUB gates
pass, including unsupported-type rejection. The 24 repository-boundary/build
safety tests pass `command-422.log`, including the new target's scope checks.

The PhysX helper now exposes `PhysXCuMetalContactGraphTest`, compiling the
unchanged `physx/source/gpudestruction/tests/contact_graph_test.cu` against its
actual shared headers. Its 100,001-node / 201,998-pair campaign passes shuffled
ordering, independent reference connectivity, rebuilds after deletion, precise
membership heads/successors through the new GPU 64-bit sort, lifetime reuse and
exhaustion, retained registry transactions, sparse metadata updates, static and
kinematic boundaries, touch/response rules and invalid-input cases. The source
prints historical CUDA labels, but native-AOT provenance identifies Apple M3 Max.
The tests retain their existing observation synchronization; no forced
per-kernel synchronization environment option is enabled.

Run this component explicitly:

```sh
python3 -B tools/scripts/build-destruction-sdk.py --preset macos-cumetal --stage gpu --target PhysXCuMetalContactGraphTest --test --generator 'Unix Makefiles'
```

Both contact-graph modes first pass
`gpu/runs/20260921T164638.950889Z-15335/command-04.log`. All 14 selected native
PhysX gates then pass `gpu/runs/20260921T164948.696946Z-25300/command-04.log`,
with source/toolchain/options/artifact hashes in that run's `sdk-artifacts.json`.
These paths are beneath PhysX `out/build/macos-cumetal/release/`.

The full `PhysXGpu` rebuild still fails on conditional graph types and APIs in
`PxgDestructionTransaction.cuh`
(`gpu/runs/20260921T165059.604715Z-27431/command-03.log`); full narrowphase
continues to compile. Blast's previously observed `make_double3`, cooperative
graph-node attributes and GPU block-load gaps remain open. Conditional capture,
bounded cooperative stress solving, IEEE64 inertia and inline-PTX trap behavior
still need implementation/qualification. Full TGS scene correctness, correction
limits, warm-start round trips, accepted integrated destruction, scaling and
video remain unfinished. No system changes, installs or Linux execution occurred.


## Cooperative graph attributes and block movement (2026-09-21)

CuMetal now implements Runtime kernel-node cooperative set/get/copy attributes.
Explicit and captured launches retain the mode through clone, instantiation,
parameter changes and replay. Executable updates reject changes of cooperative
mode before modifying node state. Replay enforces cooperative dimensions and
the stricter native single-block ABI; clearing an attribute cannot bypass that
ABI. Null, non-kernel and unsupported-attribute inputs reject. Attribute changes
do not provide general multi-block grid synchronization. Driver cooperative
capture attribute parity remains unqualified.

The native cooperative gate checks graph snapshots, both directions of rejected
updates, preserved argument values, accepted same-mode updates and oversized
replay. It also rejects dimensions whose true product is `2^64 + 4` rather than
mistaking integer wraparound for four resident blocks. Existing cross-warp/shared
and device-memory cooperative phase results remain exact. Linked and native
object forms run with tracing and with untraced batch size 16.

The source-first CUB block load/store headers are device-callable and expose
the `.cuh` includes used by Blast. Direct/vectorize/transpose/warp-transpose
policies preserve the final blocked arrangement using scalar GPU accesses;
striped policy uses striped registers. Policy-specific coalescing optimizations
are not implemented. Seventy native configurations cover full/tail tiles,
unsigned 32/64-bit values, row-major 3D blocks, preserved invalid loads, explicit
defaults, guarded stores, counting iterators, guards and queued graph replay.
Six invalid template specializations reject before producing artifacts.

`cub::Max` and the CUDA-order scalar custom-scan/aggregate overloads close
the next packing interface. Unsigned-32/signed-64 prefix tests cover custom
initial values, every-thread aggregates, aliased input/output and 3D blocks.
The added `make_double3` constructor preserves all binary64 bits, including
signed zeros, subnormals, one-ULP distinctions, infinities and NaN payloads.
That constructor test is not evidence of complete double-precision inertia math.

All fourteen existing PhysX component gates pass after these changes:
`out/build/macos-cumetal/release/gpu/runs/20260921T171451.436610Z-56084/command-04.log`
(15.93 seconds). The manifest records the current sources, options and artifact
hashes. These are the seven named component tests in traced and untraced batched
modes; full TGS and integrated destruction remain unqualified.

The unchanged `NvBlastExtStressGpu.cu` probe now passes the formerly missing
`make_double3`, cooperative attributes, block load/store and maximum-scan
interfaces. Its first remaining errors are conditional handle/set operations in
`StressHierarchyDemand.cuh`, followed by conditional graph construction and
solver loop operations. Probe log: CuMetal
`out/tests/pointer-tuples/command-435.log`. This is still a frontend failure,
not proof that the entire stress translation unit compiles or executes.

The legacy cooperative runtime test also passes when run directly against a
reference metallib generated under CuMetal's output tree (`command-438.log`).
Its old CTest harness attempted Apple's default external module/cache paths;
the repository write sandbox denied those writes (`command-434.log`). The
reference was rebuilt with an explicit local module cache and linked using the
installed toolchain's direct executable. Do not treat that harness as safe for
an unrestricted test-suite run. No system upgrade, install, Linux execution,
physics equation change, precision reduction or native video is claimed.


## GPU predicate dispatch and native conditional scope (2026-09-21)

The internal Metal backend now supports a GPU-resident unsigned-32 predicate
on a dispatch. A fixed Metal 2.4 helper produces either the configured grid or
zero threadgroups; public indirect dispatch then runs or skips the target.
The CPU does not read the predicate or wait after each kernel. The predicate
buffer participates in stream resource ordering even when absent from the
target's arguments. No source kernel rewrite, system upgrade or private API
is involved. This is infrastructure for conditional graph execution, not an
implementation of CUDA conditional graph nodes yet.

`functional_metal_backend_predicate` and `_batched` pass on M3 Max / Xcode 15.4
(`cuda-metal/out/tests/pointer-tuples/command-453.log`). Each checks 50 changing
GPU decisions in split, same-stream and cross-stream configurations, with
3D grids and dynamic shared-memory barriers. Predicates include zero, one,
the high bit and all bits set. A 127-group dispatch still completes after its
first thread clears the original predicate, proving the dispatch decision was
made before body execution. Invalid offsets, short/foreign buffers, missing
buffers, timed calls and watchdog-sliced predicated launches reject. GPU traces
say `dispatch=gpu_predicate`; command success alone is not evidence that a
nonzero number of body threadgroups ran.

The helper pipeline compiles once on first use and currently allocates a
12-byte indirect buffer per gated dispatch. Pooling and throughput remain
unmeasured. Graph integration must snapshot a branch decision once per body,
not reevaluate a mutable condition handle for every body kernel. Conditional
copies/fills and capture into existing graphs were implemented in the follow-up
below; handle ownership/default reset, nested IF nodes and graph/executable
lifetimes still need integration.

**Native scope requalified from current source:**
`physx/source/gpudestruction/runtime/CMakeLists.txt` defines
`PHYSX_RESIDENT_DESTRUCTION`. Under that definition,
`blast/source/sdk/extensions/stressgpu/detail/StressIterationDispatch.inl`
routes `launchConditionalLoop` directly to `launchPersistentStress` (around
lines 292-295). The existing cooperative solver retains `params.maxIterations`
and GPU convergence decisions. The conditional WHILE graph path is for the
nonresident solver. Its API references still need to compile, but WHILE graph
execution is not an initial native-destruction runtime requirement. No PhysX
flag or equation was changed to obtain this distinction. Nested IF transactions
in PhysX topology and Blast hierarchy remain required.

The existing backend ordering test passes against the repository-local
reference library (`command-450.log`), and all twelve focused graph/CUB gates
pass (`command-451.log`). All fourteen PhysX component tests also pass with
the new backend:
`out/build/macos-cumetal/release/gpu/runs/20260921T173207.720162Z-75255/command-04.log`
(18.98 seconds). Binary shim remains disabled. These checks do not qualify the
integrated loader, full TGS, stress/inertia/fracture, correction limits,
warm-start round trips, scaling or the requested native video. Linux execution
and installation remain unavailable/not performed.


## GPU branch operations and capture into existing graphs (2026-09-21)

The Metal backend now has GPU condition reset/snapshot operations and gated byte
copies and typed fills. A snapshot combines a condition with its optional parent
and is independent of subsequent writes to the original condition. Recomputing
a nested snapshot when its parent is false clears stale branch state. Sixty
cases exercise these rules, 1/2/4-byte fills, unaligned copies, grid-stride tails,
guards, rejected ranges and cross-stream ordering, in both traced and batched
execution. No host condition readback or per-kernel synchronization is used.
These are runtime primitives, not separate Metal destruction equations.

`cudaStreamBeginCaptureToGraph` now captures into a supplied graph using the
specified initial dependencies. Stream frontiers and event fork/join edges are
preserved, and each capture session has a distinct ID. Empty-node construction
and dependency queries make this topology directly testable. Invalid/duplicate/
foreign dependencies, malformed edges, active graph/stream destruction and
incorrect end-capture stream/thread are rejected. Nonzero edge semantics and
independent simultaneous captures into one graph remain unsupported; broader
capture invalidation and extended dependency-update APIs remain unqualified.
This follows the [CUDA 12.8 stream capture contract](https://docs.nvidia.com/cuda/archive/12.8.0/cuda-runtime-api/group__CUDART__STREAM.html).

The native CUDA fixture captures two GPU branches plus a D2D checkpoint copy,
clones/instantiates the graph, destroys its graph sources, and validates nine
queued replays with 1,025 guarded elements. Both traced and batched runs pass on
M3 Max / macOS 14.4 / Xcode 15.4 with the binary shim disabled. Focused backend
and graph tests pass in CuMetal `out/tests/pointer-tuples/command-463.log`;
new capture and related native cooperative/CUB tests pass in `command-466.log`
(7 tests, 22.64 seconds). No system components were changed or installed.

**Remaining:** connect the tested GPU snapshots, resets, copies and fills to
real conditional handle ownership, device setters, nested IF graph nodes and
executable lifetimes. Capture support alone does not make the native destruction
transaction compile or execute. Full TGS, stress/FP64 inertia, ownership,
checkpoints, correction limits 0/1/>1, warm-start round trips, accepted fracture,
scaling and the requested video remain unqualified. No Linux result is claimed.

Follow-up regression evidence: captured-library GPU/CPU replay and graph user-object
lifetime tests all pass (`command-468.log`). The latter's diagnostic temporary
file is explicitly redirected into CuMetal `out/tests/pointer-tuples/tmp`; the
repository write sandbox remains active. All fourteen existing PhysX component
tests pass against this runtime in
`out/build/macos-cumetal/release/gpu/runs/20260921T175651.514399Z-99916/command-04.log`
(17.21 seconds), with the helper's source/options/hash manifest refreshed.


## Native conditional IF graphs and hierarchy compiler prerequisites (2026-09-21)

CuMetal now implements GPU-owned conditional handles, the device setter, optional
per-launch default reset, single-body IF nodes, and nested branch snapshots.
Each body keeps its entry decision even if a body kernel clears the original
handle. A false parent clears its child's snapshot on subsequent launches.
One-dimensional D2D/mapped-memory copies and byte/typed fills execute under the
same GPU predicate. No condition is read on the CPU and no per-kernel host wait
is added. Native tests queue 40 launches across two executables and two streams,
destroy source graphs and executables before final synchronization, and verify
branch effects, checkpoint copies, guards and default resets over 1,025 elements.
Default/raw-address modes and traced/batched execution pass on M3 Max, using
macOS 14.4 / Xcode 15.4 and binary shim OFF.

This is a bounded implementation. WHILE, SWITCH, two-body IF, conditional graph
cloning, executable updates, and executable node-parameter edits reject.
Conditional bodies accept native kernels without printf/child-launch queues,
empty nodes, one-dimensional device copies and fills. Host callbacks, library
closures, events, memory allocation/free, 3D/host copies and child-graph nodes
reject even in a false branch. A condition belongs to one node in its creating
graph or a descendant; unused handles and invalid ownership reject. Owned body
graphs cannot be separately instantiated/destroyed. Executables retain condition
storage. Launches in one condition family are serialized by an encoding mutex
and GPU buffer dependencies, including across streams; concurrent throughput
is unqualified. These restrictions are explicit rather than emulated no-ops.

`cudaStreamGetCaptureInfo_v2` and its C++ overload expose the active graph and
borrowed dependency frontier. `cudaStreamUpdateCaptureDependencies` supports
adding or replacing dependencies. Invalid/foreign/duplicate dependencies and
inactive-stream updates reject without mutation. The capture tests verify reuse
of the borrowed array and captured-node dependencies. Extended edge APIs and
complete CUDA capture invalidation remain unqualified. This closes the missing
capture interfaces used by the current Blast source.

Further generic compiler gates now cover 32-field / 128-leaf bounded aggregate
reconstruction, including nested pointer records. Exact SSA field producers are
retained through nested insert/extract chains; unknown aggregate pointer
producers still reject. GPU tests check record snapshots after source mutation,
by-value helper copies, device/shared/private pointees, literal-null-only fields,
and nullable shared/private fields. Only a complete proof of literal-null
initializers permits a concrete null representation; an uninitialized incoming
path is not accepted. Broader out-of-line aggregate pointer returns and opaque
whole-record pointer loads remain outside this qualified subset.

CUDA block-wide count/and/or barriers now lower to fixed-width SIMD partials
plus a 128-byte, explicitly aligned shared scratch array. Two threadgroup
barriers preserve device/shared visibility and scratch reuse through nested
calls. Twelve block shapes (including partial warps, 3D blocks and 1,024 threads),
17 changing vote rounds, three blocks and three queued launches pass exact
checks. Divergent block-barrier participation is not supported CUDA usage;
this work does not add a multi-block barrier.

The explicit `__fma_rn(double,double,double)` spelling now reaches CuMetal's
existing software IEEE64 fused operation. A native test matches host `std::fma`
bit-for-bit for finite/non-NaN results over 2,063 boundary/random cases, including
subnormals, rounding ties, signed zero, cancellation and overflow-sensitive
fusion; NaNs are checked by classification. This does not qualify the remaining
double-precision inertia operations or change PhysX tolerances.

These changes advance actual Blast compilation past missing conditional/capture
APIs, aggregate bounds, block votes and the FMA spelling. The unchanged resident
hierarchy test now stops in a private-field proof in `StressHierarchyKernels.cuh`
(`construct`, value %2488; `command-556.log`). It has not executed numerically on
Apple GPU. The production stress source stops in `initializeMotionForest` at
`StressMotionForest.cuh:46` (`command-557.log`). Both remain compilation gates. Full TGS, bounded resident stress, FP64 inertia,
transactions/ownership/checkpoints, correction limits 0/1/>1, warm-start round
trips, convergence/fracture policy, scaling and the native video remain open.
Linux execution and installation have not been performed. No system components,
global configuration, PhysX equations or numerical tolerances were changed.


The follow-up pointer analysis settles nested descriptor dependencies before
revalidating private fields, retaining the final rejection for unresolved
pointees. Restoring the original early check or single descriptor pass fails
its respective focused regression (`command-542.log`, `command-551.log`).
A well-formed grid-sync builtin now preserves an owned private record, including
through helpers; this rule does not classify shared/device storage as read-only.
Malformed argument/result signatures reject. The cooperative GPU test checks
private/shared/device/nullable fields across 16 phases, queued direct/graph and
driver launches, native link/object paths, and traced/batched execution.

All 55 audited compiler/graph/capture/CUB regressions pass with these retained
changes: `cuda-metal/out/tests/pointer-tuples/command-553.log`, 69.01 seconds.
The expanded cooperative GPU regression also passed independently in
`command-549.log`. No global dependency or toolchain change was required.


All 14 existing native PhysX GPU regressions rebuild and pass with the retained
compiler changes (18.02 seconds):
`PhysX/out/build/macos-cumetal/release/gpu/runs/20260921T192426.567485Z-18862/command-04.log`.
The run uses the source-first backend, software IEEE64, the existing bounded
cooperative option, binary shim OFF, and the existing traced/batched variants.
It does not qualify a full TGS scene or integrated destruction. No installation
or Linux/CUDA execution was performed.


## Descriptor slices and caller-owned record helpers (2026-09-21)

The compiler now retains complete pointer fields when Clang copies a constant
byte range from a known alloca or by-value descriptor. This covers the five
trailing pointers copied from the twelve-pointer PhysX `Buffers` record.
It checks object bounds, complete eight-byte fields, and actual alignment.
A weaker memcpy annotation can be strengthened only by explicit root alignment
and the exact offset. Unknown ranges, partial pointers and genuinely unaligned
copies retain the byte path; no pointee space is guessed from a byte width.

A new native GPU test exposed an incorrect result when a shared helper received
records containing different pointer spaces from two callers. Selected calls
with statically identified private record objects now receive separately
analyzed helper bodies. Fields and bytes are unchanged. The transformation is
bounded to 64 selected calls and 500,000 cloned operations within the existing
specialization limit. Uninitialized or unresolved selected owned fields reject;
a mixed-origin 65-call case explicitly rejects instead of assuming device
storage. More indirect record ownership remains outside this qualified subset.

The descriptor test checks 64 values over three queued pairs of kernels,
including device, private, shared and nullable pointer fields. It passes on M3
Max in traced and batched modes with raw addresses, the binary shim disabled,
and no forced synchronization after each launch. The full 56-test audited
compiler/graph/capture/CUB regression selection passes in 70.49 seconds:
`cuda-metal/out/tests/pointer-tuples/command-583.log`.

Module-wide alias analysis now uses the existing module allowance instead of
consuming the first function's proof budget. Proven nonprivate addresses are
excluded from private-object capture analysis; unknown and mixed origins still
participate. Neither pointer-proof criteria nor the total module cap was
relaxed. The actual hierarchy qualifier passes the former descriptor-copy
boundary and now stops at `CycleWork<true>::enabled`'s optional field in
`StressHierarchyCycle.cuh:19` (`command-584.log`). Large solver functions still
hit proof limits. The full stress translation unit now reaches
`projectMotionComponent` in `StressMotionModes.cuh:86`, where a partial
intervening store remains unproved (`command-585.log`). These are compilation
boundaries, not successful native destruction executions.

All changes are reusable CuMetal compiler work. PhysX equations, tolerances,
correction limits, warm starts and convergence policy were not modified.
The current macOS/Xcode toolchain remains unchanged. Linux execution,
installation, integrated destruction and the native video remain unperformed.


## Raw-address byte preservation and native regression refresh (2026-09-21)

The descriptor-slice refresh exposed an intermittent contact-graph failure:
valid input with 100,001 nodes and 201,998 pairs sometimes reported an invalid
identity. Repeats reproduced the failure after 11 and 31 successful runs.
Failure-only diagnostics now report the input sizes and expected/actual status;
assertions and synchronization are unchanged.

A separate deterministic GPU regression found that runtime payload scanning
rewrote ordinary integers when their bits matched an allocation address.
This affected host-to-device copies and scalar/aggregate arguments; readback
also converted GPU pointer bits to CPU mappings even in raw-address mode.
The raw-address path now preserves those bytes and public pointer identity.
Conservative resource residency collection remains in place. The legacy
host-address mode retains its historical relocation heuristic and remains
unqualified for arbitrary address-shaped integer payloads.

The new test exercises seven payload patterns across synchronous/asynchronous
copies in both directions, scalar arguments and a record containing a real
GPU pointer alongside unrelated integer bits. It fails before the repair
(`cuda-metal/out/tests/pointer-tuples/command-594.log`) and passes afterward
in traced and batched Apple-GPU execution (`command-596.log`).

Current M3 Max / macOS 14.4 / Xcode 15.4 evidence:

- 100 consecutive batched native contact-graph runs pass after the repair:
  `cuda-metal/out/tests/pointer-tuples/command-597.log` (137.80 seconds total).
- All 57 audited compiler/runtime/graph/capture/CUB regression checks pass:
  `cuda-metal/out/tests/pointer-tuples/command-600.log` (67.63 seconds).
- All 14 native PhysX GPU component checks rebuild and pass through the safe
  build helper, traced and batched, in 17.57 seconds. Evidence:
  `PhysX/out/build/macos-cumetal/release/gpu/runs/20260921T200506.056456Z-86479/command-04.log`.
  The updated `gpu/sdk-artifacts.json` records selected targets, source hashes,
  compiler versions, numerical options, artifact hashes and a partial-build status.

These runs use raw Metal addresses with the binary shim disabled and no forced
synchronization after each kernel. The tested runtime SHA256 is
`20f45bbe164055c254b055a42a8839196e84dd3e3bec93cc7e13a7490dd0ad7a`;
the compiler SHA256 is
`72f784a418ef22db5f4959d7e4cd427ffe7b8d7bbd583fd4430b435fa3f80d4c`.
Elapsed test-suite times are not simulation performance measurements.

The compilation boundaries from the preceding section remain: the resident
hierarchy's `CycleWork<true>::enabled` optional mask, and the full stress source's
private-field proof for `a.partition.begin` in `projectMotionComponent`.
Full TGS scene execution, integrated destruction, correction-limit and warm-start
qualification, measured scaling and the native video remain unfinished. No Linux
CUDA execution, installation or system/toolchain changes were performed.


## Opaque record copies and parallel qualification audit (2026-09-21)

Complete, aligned copies from an opaque source into a declared local object now
retain whole generic pointer fields. This recognizes the record representation,
not the pointee origin. Partial/unaligned/unknown destinations and explicit
address-space pointer declarations do not receive this recovery. Earlier typed
source and descriptor-slice behavior remains unchanged.

A new bounded external-copy proof checks all reaching CFG and caller prefixes,
including backedges, before using a host-supplied descriptor assumption. An
integer representation of a private pointer previously bypassed the pointer-store
check; the new negative case reproduced acceptance and now rejects. Scalar,
atomic, byte-copy and helper clobbers also reject. Private/shared scratch writes
are disjoint. Unknown calls and incomplete summaries fail closed. This initial
proof deliberately rejects all preceding global writes, even when a future
range analysis could prove them disjoint. Budgets remain bounded (one million
operations per query, sixteen million cumulatively); successful proofs are not
cached across changing address-space facts.

Call preservation may now check up to 64 distinct owned allocations for a helper
formal, preserving it only if every candidate is preserved. Dynamic clobbers and
excess candidates reject. LLVM memory intrinsics without an alignment annotation
use alignment one instead of throwing an exception.

The new Apple-GPU fixture checks complete external record copies, two nested
pointers, a 29-element boundary and 96 exact results across three queued
snapshots with intervening GPU updates. All 58 audited compiler/runtime/graph/
CUB checks pass (67.69 seconds), including this fixture in traced and batched
execution: `cuda-metal/out/tests/pointer-tuples/command-629.log`.
The binary shim remains OFF; forced synchronization after every launch is OFF.

The production stress compile still fails. Its current final diagnostic is a
private-field proof budget exhaustion in `CycleWork<false>::enabled`, at
`StressHierarchyCycle.cuh:19:123` (`command-630.log`). The resident hierarchy test
still rejects the optional active pointer in `CycleWork<true>::enabled`, offset
8 (`command-631.log`). Compilation progress is not full stress qualification.

A parallel source audit specifies the next real TGS scene gate: GPU-required
scene creation, gravity, dynamic/static contact, friction, angular response,
position and velocity iterations, followed by the existing native kinematic
baseline without changing tolerances. Its checklist is recorded in
`cuda-metal/out/tests/pointer-tuples/first-full-tgs-gate.md`. The whole-island
kernel declares 45,312 bytes of shared arrays before compiler scratch; actual
pipeline/device limits still need checking. Backend-aware native SDK/test
linking and the full GPU library remain prerequisites.

Full TGS scene execution, integrated destruction, correction/warm-start tests,
scaling and the native video remain incomplete. Linux CUDA was not executed.
No system/toolchain changes or installation were performed.

All 14 existing native PhysX component checks also rebuild and pass through the
safe helper (traced and batched). Evidence:
`PhysX/out/build/macos-cumetal/release/gpu/runs/20260921T203821.125926Z-49174/command-04.log`.
The refreshed `gpu/sdk-artifacts.json` records a tested partial build, with no installation.

Tested `cumetalc` SHA256: `ac18dd06fb81be78addd1a87c853c763d4a986efb7fc2a1913d7f0e4ddf03f23`.

Tested `libcumetal.dylib` SHA256: `c8ef2fcdc7e45912c7563b663b565bd11efdda27bd875a6a9d4bba9e5cc697f4`.


## First production TGS contact and resident hierarchy numerical gates (2026-09-21)

Status: component correctness demonstrated on M3 Max; complete GPU scenes,
integrated destruction, Linux execution, packaging acceptance and video remain
unqualified. The current macOS/Xcode installation is unchanged.

- The production solver archive compiles. A real Metal pipeline probe initially
  rejected `solveWholeIslandTGS`: its four 944-entry vector arrays required
  45,312 bytes against the device's 32,768-byte threadgroup limit. The shared
  host/device capacity option now defaults to 512 on CuMetal (944 on CUDA),
  yielding a measured 24,576-byte pipeline allocation. Host selection preserves
  the existing partitioned solver for larger islands. The option changes
  resource/scheduling choices, not solver equations or numerical tolerances.
  Both whole-island and partitioned pipelines load with valid launch geometry.
- The actual `solveWholeIslandTGS` and `solveBlockUnified` kernels pass normal
  impulse, angular response, sticking-friction and sliding-friction checks:
  eight kernel/case combinations, 32 contact pairs and two queued transactions
  per case, at the existing 1e-5 tolerance. Checks include analytical impulses,
  velocities, momentum, friction state and untouched buffers. Evidence:
  `cuda-metal/out/tests/pointer-tuples/command-654.log` and
  `tgs-numerical/first-run.json`. This does not qualify broadphase-to-integration
  timesteps or a complete TGS scene. The permanent helper target is
  `PhysXCuMetalTgsContactsTest`.
- The production resident hierarchy qualifier now compiles and passes
  `--cycle path 0`: 24 nodes, 23 bonds, seven levels and two transitions,
  including dense-reference, squared-capture, symmetry and linearity checks.
  Evidence: `cuda-metal/out/tests/pointer-tuples/command-659.log`. Its bounded
  single-block mode uses the same hierarchy equations and software FP64.
  Radix-bin prefix scheduling now uses warp-stride ownership so eight warps
  cover all sixteen bins; existing two-or-more-block assignments and barriers
  remain unchanged. This small hierarchy test is not full stress convergence,
  fracture or large-component qualification.
- Private-field proof traversal now indexes memory effects, reducing real work
  without increasing proof limits. Guarded paths still inspect SSA definitions.
  Complete aligned zero fills retain eight-byte integer-zero stores, and exact
  full-field zero writes prove null without inventing an address space.
  Partial, nonzero, conflicting and volatile cases retain conservative handling.
  All 60 audited compiler/runtime regressions pass after these changes,
  including native object/library registration and its new host unit:
  `cuda-metal/out/tests/pointer-tuples/command-670.log`.

The full production stress translation unit still has a pointer-representation
blocker in `persistentStressSolve`, at the `CycleLevel` field at byte offset 312
(`StressHierarchyCycle.cuh:103` in compile666). Earlier inspection of the
neighboring offset-304 failure found a loaded pointer followed by a variable
record index losing layout needed by the local-field proof. A fix
must distinguish field representation from allocation identity and prove
preservation across earlier writes; assuming that descriptors and output buffers
cannot alias is not acceptable. Some large proofs also remain bounded/unresolved.
The short anonymous-kernel registration failure exposed by compile662 is
fixed: bounded name candidates must uniquely match an actual typed Metal kernel.
Missing and ambiguous matches reject. The native object/archive/dynamic-library
GPU regression and host negative tests pass (665/669; together again in670).
The permanent hierarchy packing test also passes: 72 graph replays in each of
traced and batched modes, spanning 1/2/3/5 blocks, all sixteen bins, empty/tail
tiles and unchanged padding. This qualifies prefix coverage, not complete
integrated packing or destruction.

The remaining acceptance sequence is:

1. Compile/link the complete `PhysXGpu` and `PhysXDestructionGpuRuntime` libraries
   and verify native registration and macOS loading with the binary shim disabled.
2. Finish backend-specific SDK/demo CMake branches: CUDA toolkit discovery,
   CUDA language targets and Linux linker assumptions still occur in the demo
   and topology project. The explicit SDK gates remain until these are real.
3. Execute a required-GPU TGS scene through contacts, preparation, scheduling,
   propagation, integration and successful result retrieval. Component tests
   alone do not establish that PhysX GPU works end to end.
4. Execute native stress, fracture, ownership, checkpoint restoration,
   correction limits 0/1/>1, warm-start round trips, convergence/fracture
   withholding and exactly-once publication at the existing tolerances.
5. Explicitly stage/install and test a relocated external
   `PhysXDestruction::NativeScene` consumer inside an authorized repository.
6. Add a Metal renderer consuming the same accepted GPU instance/pose buffers
   with producer/consumer synchronization. The current NVIDIA EGL/CUDA-OpenGL
   interop renderer cannot run through CuMetal's unsupported graphics-interop
   stubs. Preserve shared instance-generation and physics sources.
7. Produce native 1920x1080/60 H.264 (the existing demo requests 960x540), verify
   completed capture metadata, frame count and decoding, and retain provenance.
   Playback rate is not a simulation performance claim. Measure idle and full
   destruction workloads only after correctness.

All 18 native PhysX component checks rebuild and pass through the safe helper
(17.53 seconds); the manifest records a tested partial build and `installed=false`.
Evidence: `PhysX/out/build/macos-cumetal/release/gpu/runs/20260921T211745.473125Z-51834/command-04.log`
and `gpu/sdk-artifacts.json`. All 27 build-helper safety tests also pass
(`cuda-metal/out/tests/pointer-tuples/command-664.log`).

Current tested `cumetalc` SHA256: `49287ebe9e250af1b780d10dbb8a8321982f3a4804a766da34c006934ed9e6fc`.

Current tested `libcumetal.dylib` SHA256: `ab142036938642711045de9f9327c9afe9abb8e47d19b01bb7de6ff7e321a553`.


## Descriptor views and native SDK configuration (2026-09-21)

This checkpoint supersedes the preceding compiler/build status; it is work in
progress. Native destruction, a complete GPU TGS scene, staged SDK consumption,
Linux execution and the video remain unqualified. No system changes or install
were performed.

- Verified typed descriptor indexing now retains bounded layout/field metadata
  separately from allocation identity. Complete pointer fields at known offsets
  survive whole-record dynamic indexing. Unknown byte offsets, conflicting
  layouts and incomplete/unaligned fields do not acquire this metadata. Earlier
  potentially aliasing writes still prevent assuming host-supplied pointers.
- All 62 audited CuMetal compiler/runtime checks pass (command-678.log), including
  a new importer unit and an Apple-GPU indexed-descriptor graph fixture. The
  fixture uses 53 active lanes, four queued snapshot/update pairs and three
  captured replays with exact integer and guard checks.
- The full stress translation unit advances past the missing CycleLevel layout
  at offset 312, but still fails: an earlier RHS write cannot yet be proved
  disjoint from the later descriptor copy (StressNativePreconditioner.cuh:11
  before StressNativeNullspace.cuh:6; command-677.log). Allocation inspection
  supports a narrow descriptor-root contract; that contract is not yet qualified.
- SDK/demo/topology CMake targets now have CUDA and CuMetal branches. Six
  configure/export/prerequisite negative probes pass (command-675.log). The real
  destruction SDK configures against same-build host archives (command-679.log),
  without discovering an NVIDIA toolkit. This is configuration evidence, not
  completed runtime linkage or an installable package. The Python helper's SDK
  acceptance guard remains in place.
- The real topology library and rigid-iteration-limit test build, and its native
  Apple-GPU test passes (commands 680/681). It covers 0, 1, 257, 4,099 and 113,664
  bodies, repeated workspace use, active-only reductions and invalid inputs.
  The binary shim is off; raw Metal addresses are on and per-launch forced
  synchronization is off. This does not exercise stress fracture or GPU scenes.

The latest attempted rebuild of the 18 PhysX component checks **failed before
running the tests**, superseding the earlier all-18-pass build status for this
compiler snapshot. New descriptor tags over-constrain pointer values that
PhysX carries as CPU identifiers/offsets: accumulateThresholdStream.cu:545 and
constraintBlockPrePrep.cu:984. These cases need a proved distinction between
carrying pointer bits and dereferencing GPU pointers. Removing preservation
checks from real descriptor accesses is not an acceptable fix.

Failure evidence: PhysX/out/build/macos-cumetal/release/gpu/runs/
20260921T214208.670843Z-15446/command-03.log and
cuda-metal/out/tests/pointer-tuples/helper-native-eighteen-descriptor-view.log.
The earlier TGS/hierarchy numerical results remain historical evidence; they
are not a successful rebuild of the current snapshot.

Parallel work is divided among compiler representation/proof, shared PhysX
stress-kernel argument integration, and SDK/link/export audit. GPU execution is
serialized. Next gates are restoration of the component rebuild, complete
stress/runtime compilation and registration, then a required-GPU TGS scene,
integrated destruction correctness and a Metal rendering consumer for capture.


## Restricted descriptor roots and parallel work (2026-09-21)

All **65 audited CuMetal compiler/runtime checks pass** on the current snapshot
(command-690.log, 72.49 seconds), including the new real Apple-GPU readonly-root
fixture. All **28 build-helper safety checks pass** (command-684.log). These do
not restore the failed PhysX component rebuild recorded above.

The compiler now imports explicit LLVM noalias/readonly contracts on non-byval
kernel arguments. Descriptor preservation can use them only through a bounded
GEP/cast chain ending at that exact kernel argument. It never extends the
contract to loaded nested pointers, helper arguments, integer round trips or
merged roots. LLVM function-attribute inference runs after the existing
normalization; C++ const alone does not supply the contract. The GPU fixture
copies an opaque descriptor after writing through a deliberately aliased nested
output pointer, checks exact values/guards/tails across queued updates and three
graph replays, and runs without per-kernel synchronization. Removing restrict
from the fixture fails compilation, confirming that this tests the new proof.

Pointer values used purely as integer observations or null checks have a
separate bounded byte representation path. It currently accepts only source
storage directly derived from an explicit external kernel argument; private,
shared, byval, helper and nested-loaded sources retain their original pointer
initialization checks. A broader intermediate implementation failed existing
negative tests and was narrowed; the full existing LLVM-to-Metal unit passes
again. The production PhysX pointer-payload transport cases remain unresolved.

PhysX has a default-OFF experimental `--cumetal-explicit-hierarchy-root` hint
(`PX_CUMETAL_EXPLICIT_HIERARCHY_ROOT`). It exposes the separately allocated
hierarchy descriptors at both stress kernel entry points, with matching launch
arguments and a local copy of the original argument record. Equations,
correction limits, warm starts and nested-pointee aliases are unchanged. CUDA
rejects the helper option; normal builds retain their original signatures.

The production opt-in compile **still fails** at the same descriptor-preservation
frontier (command-689.log). Its actual normalized LLVM has noalias on the new
root but does **not** infer readonly for the component kernel or preconditioned
persistent kernel. Therefore the compiler correctly refuses the shortcut.
The small compile/GPU fixture does not establish the full production contract.
Next work must address that missing proof and the shared/private pointer-payload
transport regressions before complete library linkage and GPU scene tests.

The SDK audit also identified a relocation gate: copied build dylibs may retain
build-directory runtime search paths. Generated CMake exports use prefix-relative
paths and CuMetal::Runtime, but a staged, relocated NativeScene consumer must
verify the actual libraries loaded after the complete dylibs exist.
