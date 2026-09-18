# Native bombardment recording

The demo advances the native PhysX GPU scene once per 1/60-second timestep.
CUDA destruction consumes the solved trial impulses and the internal correction
limit is one. Recording reads committed motion; the renderer later plays those
snapshots at the authored simulation speed. Smooth playback is not evidence
that simulation met its real-time budget.

## Corrected launch protocol

`clear-aerial-ballistic-v2` starts each projectile 48 metres from its target,
above the authored roofline at 24 metres. Its initial velocity aims at a point
in the target building after 1.5 seconds under gravity. Four waves approach
from four cardinal directions. Projectiles start immediately, with the last
launches approximately five seconds before the capture ends.

Before insertion, the demo tests the launch sphere against conservative bounds
of the currently observed chunks and existing projectiles. It raises an
obstructed launch and recomputes the ballistic aim. Remote airborne rubble does
not increase launch height. All subsequent motion/contact response is PhysX's.
This CPU work authors demo inputs; it does not evaluate stress or predict a
fracture verdict.

The old 13-metre launch offsets overlapped preceding buildings: 960 of 1,024
launch sites in the 16x16/four-wave layout intersected actual neighboring wall
boxes. Old captures remain migration diagnostics, not valid bombardment
visual/fidelity evidence. The launch regression checks this defect and 3,072
clear aerial trajectory cases without changing material parameters.

## Observation and audit

`--audit-motion 1` compares every recorded chunk transform to its actual PhysX
GPU owner transform and persistent local shape transform, every physics step.
The position tolerance is 0.001 metre and the normalized quaternion-dot
threshold is `1 - 1e-5`. This checks recording/physical consistency, not the
complete correctness of the constitutive model.

Body-ID uploads precede Direct GPU API pose reads through an explicit CUDA
event. Pageable host staging and PhysX's separate GPU stream must not race on
the shared observation index buffer. Earlier unordered audits sometimes read a
projectile's pose for a building chunk. Both projectile recording and the chunk
audit use the ordered path.

## Video timing overlay

Pass `--frame-telemetry CAPTURE/native.frames.csv` to the recorder's `render`
command. The overlay reports every recorded physics step, including the steps
between video snapshots:

- Physics average/minimum/maximum milliseconds, including native destruction,
  correction and the wait for completion.
- Effective physics steps/second (`1000 / mean_ms`) and real-time factor
  (`16.6666667 / mean_ms` at 60 Hz), plus steps exceeding the deadline.
- Mean capture-tick time, which also includes input placement, explicit GPU
  observation/audit and recording I/O. Setup and offline rendering are excluded.
- Current physics-step time and correction count synchronized with the snapshot.

These capture measurements are not isolated performance qualification or a
whole-game tick benchmark. All 1,800 physics steps are included in a 30-second
capture even when `--record-fps 30` writes only 900 video snapshots. Do not
average instantaneous FPS: throughput is based on total elapsed simulation work.

`tools/scripts/analyze-native-destruction-phases.py CAPTURE --output REPORT.json`
validates step order, convergence and correction counts and writes the same
physics/capture statistics plus p50/p95/p99 and phase breakdowns. CPU/driver
phase intervals are wall time, not individual CUDA kernel durations.
