# Ordinary API and sleeping are the native demo defaults

`native_destruction_main.cpp` now initializes `standardScene=true` and retains
`standardSleeping=true`. Snapshot replay and the wall wrapper already explicitly
selected this mode; this closes the standalone demo default mismatch. Historical
Direct GPU tests now explicitly pass `--standard-scene 0`, preserving their
existing workload and expected results rather than silently changing them.
The Direct GPU audit wrapper likewise supplies the explicit legacy option.

A newly built isolated demo completed 600 wall ticks with **neither
`--standard-scene` nor `--sleeping` in its command**. The reported actual scene
has Direct GPU false and sleeping true, and the pinned ordinary reference's
physical counters, all trajectory checks and convergence pass with zero maximum
position difference. Exact artifacts and command are in capture/build receipts.

The initial post-run verifier rejected the omitted options as unequal raw command
lists. Its revised comparison checks effective mode/sleep settings from the actual
scene, and rejects any contradictory explicit option. Other command settings
remain exact. The existing GPU capture was reanalyzed with the new verifier;
no simulation or reference was rerun/modified to obtain agreement. All **16**
verifier tests pass, including explicit/default equivalence, contradictory
API/sleep options, changed solver settings, wrong physical modes and late errors.
These are validation-tool corrections, not changes to physical tolerances.
The matching flat-graph candidate runtime remains frozen at commit 8589185e.
