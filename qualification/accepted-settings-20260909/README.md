# GPU-owned physical settings and an sm_89-only native module

Partial ranked replacement 1. Physical settings for a new fragment are now
published from its final GPU body, after both fracture evaluations. CPU source
objects no longer supply those properties between GPU stages. CPU simulation
registration, body-type/activity metadata, iteration scheduling and shape/contact
rebinding remain prerequisites for corrected physics. This is architectural
progress, not completed GPU lifecycle or a demonstrated peak-speed improvement.

## Implementation and costs

- GPU motion creation already inherits physical settings from the canonical
  source body. The final property gather now includes damping, velocity limits,
  depenetration/contact-impulse limits, reporting threshold, offset slop,
  sleep/stabilization thresholds, gravity disabling and axis locks.
- CPU accepted publication applies these values and maintains kinematic property
  backups. It no longer walks a CPU source ancestor to obtain physical settings;
  an ancestor's unpublished properties cannot become a later fragment's input.
- The intermediate CPU bridge still copies solver iteration counts because
  PhysX's existing host scheduler uses them to choose its launch sequence. The
  body type and native-ownership bit remain scheduling/ownership metadata.
  Ordinary CCD registration and other host scheduling are not claimed removed.
- The private accepted record grows from 128 to 172 bytes. Existing private raw
  correction scratch is enlarged and reused after correction; public compact
  trial views retain their storage and layout. Added capacity cost is 44 bytes
  per chunk scratch slot (5,001,216 bytes for 113,664 chunks). A final bounded
  property payload also transfers 44 extra bytes per observed capacity entry.
  No new kernel or intermediate host synchronization is introduced.
- The allocator observation signature changes: private runtime V8, public ABI15.
  CPU, GPU, native demo/tests and the Rust benchmark were rebuilt together.

The PhysX module previously compiled eight architectures despite this native
SDK requiring RTX 4090. Its GPU CMake project now generates only sm_89; the SDK
build helper also sets that architecture before CUDA initialization and rejects
other requests. Actual `cuobjdump` inspection finds 61 ELF device programs, all
sm_89. Module size changes from 349,454,496 to 36,690,808 bytes. No arithmetic flag,
physical equation, timestep or iteration criterion changed. This reduces build
and artifact overhead; it is not evidence of faster simulation.

## Correctness evidence

- The new ordinary-mode property boundary oracle fails against the matching V7
  baseline with `CPU physical settings inherited before corrected GPU simulation`.
  It passes with V8 for both PGS and TGS. The fixture contains 6 chunks, 3 bonds
  and one ordinary body; the new fragment's CPU settings remain unpublished
  during correction, and accepted public getters match the GPU settings.
- The four-chunk/two-bond/two-column fixture plus ordinary sentinel verifies
  settings from both fracture evaluations, alongside its existing one-correction,
  accepted-motion, event and query checks. No third physics pass is introduced.
- All 49 selected native tests pass. CUDA memcheck of the accepted-property
  fixture reports zero errors.
- Historical penetration: 444 chunks, 896 bonds, one projectile, 600 steps,
  Direct GPU on/sleeping off. The unchanged frozen topology/clearance gate passes:
  398 supported chunks, 46 detached and 199 broken bonds.
- Ordinary penetration: the same asset/projectile, 128 steps, Direct GPU off and
  sleeping on. The original ordinary reference passes without relaxed tolerances.
- The build helper rejects architecture 80 explicitly; the actual produced GPU
  module contains only sm_89 programs. The ordinary upstream non-GPU build path
  is unchanged.

Initial compilation exposed the typed CPU lock-flag assignment, which was fixed
with its explicit flag type. Build intermediates were copied to RAM-backed
storage with content-hash verification to avoid storage exhaustion. These are
reproducible object/configuration trees, not source or benchmark evidence.
The executable V7 baseline module remains archived on the ordinary filesystem.

## Earlier short performance screen (before final initialization fix)

[Generated destruction comparison](shots/report.md) · [Generated pristine-idle comparison](idle/report.md).

256 buildings, 113,664 chunks, 229,376 bonds; 256 simultaneous physical projectiles
or an independent zero-shot pristine scene. Two runs per arm/regime in ABBA order,
96 steps/1.6 simulated seconds each. Direct GPU off, sleeping on, dt=1/60, at most
one correction and two stress evaluations. Complete timing includes commands,
physics/destruction/correction and accepted observations; every first step is
retained. Rendering/networking are excluded.

Baseline destruction peaks: 133.768/132.739 ms. Candidate: 132.624/134.618 ms.
The observed worst fracture peak is 0.6% higher; this is not dismissed as noise
or claimed as a speedup. Complete means are also slightly higher. The screen
includes both settings publication and architecture restriction, so neither
change's timing contribution is isolated. Idle results are attached separately;
there is no real-time or endurance qualification claim.

The runs have matching final fracture/body/correction counts. Counts alone do
not prove trajectory equivalence; controlled oracles provide the stronger
physical checks above. Full endurance and large connected/sustained-destruction
qualification remain outstanding.

## Final record initialization and qualification

Review found that the `PxVec4` default constructor leaves its lanes undefined.
The private accepted record now uses a plain four-scalar array so that the bounded
unused observation tail is value-initialized. Layout remains 172 bytes, private
ABI V8 and public ABI15 remain unchanged. No physical equation changed.
The final boundary test also exercises inheritance of a locked linear axis.

Final matching CPU/GPU/runtime/native/Rust artifacts were rebuilt. All 49 selected
native tests, both PGS/TGS property boundary tests, frozen 600-step penetration,
ordinary 128-step penetration and the accepted-property CUDA memory check pass.
[Final evidence](evidence/final-validation/) records the exact artifacts and logs.

**Unfiltered initialization audit fails** with 43 reported errors in AABB bitmap
handling, checkpoint/previous-state copies and full-capacity topology copies.
These classes have earlier baseline reproductions documented in
[device-preparation findings](../device-preparation-20260909/README.md).
The current audit reports no final-property-gather location. That is not a clean
initialization claim for the engine; these failures remain unresolved, unsuppressed
and outside the passing checks listed above.

[Final destruction comparison](final-screen/shots/report.md) and
[final pristine-idle comparison](final-screen/idle/report.md) use immutable final
artifacts: 256 buildings, 113,664 chunks, 229,376 bonds, 256 simultaneous shots or
zero-shot intact idle, two runs per arm/regime, 96 complete advances per run.
Direct GPU is off, sleeping is on, dt=1/60, correction is capped at one and stress
evaluation at two. Timers include commands through accepted observations and retain
startup spikes; rendering/networking are excluded.

Final fracture peaks are 142.278/134.217 ms for baseline versus 134.636/131.360 ms
for candidate. The ranges overlap, and the earlier screen above had slightly
higher candidate peaks. These screens do not establish a repeatable speedup.
Final all-step bombardment peaks remain 158.677/159.178 ms for the candidate;
initialization work inside the first advance remains included. Fresh intact-idle
medians are 0.447/0.449 ms, with first-step peaks 158.147/158.459 ms. The complete
comparisons retain all raw steps. Controlled quality checks pass; endurance and
full real-time qualification are not complete.

## Reproduction and next work

Earlier artifacts and raw captures: `out/accepted-settings-20260909`. Final
immutable CPU/GPU/runtime/benchmark artifacts and paired captures are in
`out/accepted-settings-final-20260909`; final functional audits are under the
earlier capture root in `final-validation`. Neither artifact set was overwritten.
Baseline: `out/contact-response-20260909/candidate`, whose GPU symlink now resolves
to the preserved V7 `module/libPhysXGpuActivity_64.so`, not the mutable SDK output.

RAM object directories are recorded in `out/settings-ram-storage.json` and the
previous `out/sdk-release/ram-object-storage.json`. If RAM storage disappears,
remove only the broken generated-directory symlinks and reconfigure/rebuild.

Continue replacement 1 by removing host simulation-registration and scheduling
prerequisites, preserving ordinary sleeping, queries and contact ordering. Then
implement replacements 2–7 in their approved order. No game source edits,
deployment or service changes were made.
