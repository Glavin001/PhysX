# GPU committed changes — qualification and limits

✅ GPU-selected sparse topology/bond publication replaces the game's full-world
readback and CPU regrouping. Implementation: [API and ownership](../../docs/destruction/COMMITTED_GPU_CHANGES.md).
The consumer keeps ordinary PhysX actors, sleeping, raycasts and the existing wire
format. This is observation ownership work, not a different fracture model.

✅ Publication unit cases and CUDA memcheck pass. Eight ordinary native lifecycle
checks pass. The 600-step frozen wall remains 398 supported / 46 detached chunks
and 199 broken bonds from 444 chunks / 896 bonds / one projectile. The 256-building
600-step heavy audit checks full GPU membership, generations and health against
CPU consumption EVERY tick; it passes and is excluded from timing comparisons.

📈 [Generated publication timings and work](publication.md), [repeated bombardment
comparison](256-shots/report.md), [paired pristine idle](256-idle/report.md).
The bombardment has 256 buildings / 113,664 chunks / 229,376 bonds / 768 physical
projectiles, 600 steps per run, Direct GPU off, sleeping on, max one correction and
two stress evaluations. Two untraced runs per arm use baseline/candidate/candidate/
baseline order; loaded module paths and hashes are verified before waiting for exit.
The baseline is the preceding embedded physical-polynomial implementation.

The baseline complete means are 54.493 / 54.837 ms; candidate 47.698 / 44.285 ms.
CPU event/snapshot means are 10.199 / 11.376 ms versus 3.036 / 2.874 ms. This includes
explicit topology readback plus remaining game observation work; it is not CUDA
kernel time. The candidate's largest destruction peaks (137.259 / 136.942 ms)
overlap one control (136.267 ms); the other control peaks at 143.407 ms. **No robust
large destruction-peak win is established.** All-step peaks remain startup at
roughly 158–162 ms and both deadline gates fail.

❌ This is not every-step 60 Hz, endurance or historical user-land backend parity.
That objective remains active. The earlier external downtown comparator did not
preserve pristine idle and cannot establish superiority. CPU compatibility body
creation and large stress/correction costs remain priorities.

The initial screen also measures downtown idle and three shots: 27 buildings /
24,105 chunks / 74,543 bonds / 600 steps. All original rows, mapped-module receipts,
wall quality, audit rows, source patches and runner scripts are archived here.
The first screen polled process maps throughout execution; the repeated authoritative
comparison stops polling after both module identities are obtained. Neither uses
CUDA tracing or hardware-counter instrumentation. Runtime/build paths remain under
`out/vibe-committed-changes-20260908`.

✅ Deployed engine `cf053e45` / game `97364dd` passed browser join, physical
shooting, movement, settling and reset on the 27-building downtown. The browser
recorded eight shots, 138 broken bonds, 11 fragment bodies (10 sleeping / one
awake in the final server sample), no orphaned chunks or topology-hash mismatch.
Seven COEP/404 resource errors remain in the captured browser output. The
software-rendered browser FPS is not used as a physics-performance measurement.

The deployment receipt and actual mapped module hashes are archived. API v15
changes the device-view return ABI: rebuild consumers and pair matching modules.
The old v14 baseline modules and consumer are preserved under
`out/vibe-committed-changes-20260908/baseline`; do not combine old runtime files
with the newly deployed GPU module. Archived runner scripts describe the
original capture environment and require that pinned baseline library path for
any new comparison after deployment.
