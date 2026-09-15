# Integrated polynomial barrier A/B — 10 September 2026

Candidate B removes the trailing block barrier from the existing native
polynomial preconditioner. This is an edit to the engine used by the ordinary
`PxDestructionScene` path, not the separate six-channel prototype. Disposition
is **unqualified WIP, stopped by user**. B timing was interrupted by a foreign
GPU process; no completed A/B performance comparison or new counters exist.
[Current handoff](../../docs/destruction/HANDOFF-20260910-integrated-ab.md) records
artifact selection, failed-capture details and the remaining plan.

## Mechanism and dependency proof

Each thread writes `result[nodes[i]]` for its strided node set. Both callers
initially read that identical set: the native preconditioner performs the local
motion-projection sums (free modes) or local normalization maximum (anchored),
and the independent polynomial basis fixture copies those same rows. Free-mode
projection synchronizes in its reduction before coefficients cross threads;
anchored normalization does likewise. The earlier polynomial barrier remains:
its off-diagonal gather actually reads other threads' physical vectors.
No arithmetic, ordering within a row, tolerance, solver, material, iteration,
contact or correction policy changes. No extra allocation or runtime switch.
Compiled native kernel resource usage is unchanged: 110 registers, 48-byte stack,
1600 shared bytes reported by cuobjdump. Static barrier instructions fall 45→44.
These counts are not performance measurements.

## Preserved A and first control

Both arms use RTX 5060 Ti 16 GB, CUDA 13.4.59, sm_120, driver 615.71.09.
A runtime SHA256: `93846c918089a61d5883790fd101199f08ffae701599d715eedf7c247961a126`.
The same native executable and ordinary rigid-body modules are copied into
isolated A/B directories; only B's destruction runtime differs. Actual mapped
runtime paths/hashes are retained in captures. Existing desktop graphics remain;
no clocks are locked and no competing service is stopped.

First untraced screen: two repeats of 180 steps / 3 simulated seconds per case,
plus separate discarded warmups. Each case has 256 buildings, 113,664 chunks,
229,376 bonds. Idle has zero projectiles; bombardment has one 256-projectile
wave. Direct GPU disabled, sleeping enabled, dt 1/60, at most one correction,
8192 iteration cap and unchanged stress/material settings. All steps are kept.

A idle complete-step peaks: 16.185 / 16.360 ms, both startup step 0.
A bombardment peaks: 228.195 / 226.602 ms, both step 82.
Means and exact 120/60 Hz deadline misses are in the raw generated screen report.
The runner returns 2 for the failed deadline gate after completing every run.
This short shared-GPU screen is not endurance or isolated performance qualification.

## Physical checks

Both 600-step / 10-simulated-second ordinary/sleeping penetration captures
(444 chunks, 896 bonds, one projectile) complete simulation and pass hole,
projectile-clearance, motion and COM checks. Recorded poses, decompressed chunk
motion, projectile launch tape and body-state words are byte-identical A/B.
Both retain 400 supported / 44 detached chunks, 182 broken bonds and 39 clusters.
Both original full audits still fail the historical topology-identity golden.
The golden and its tolerances are unchanged. Matched equality is not a resolution
of the remaining migration physical-equivalence gates.

Three rebuilt native numerical CTests pass. Candidate 3D stress memcheck,
initcheck and synccheck pass. Racecheck's 3D target exits 11 without displaying
hazards; this is a failure, not a clean sanitizer result. Unchanged A also fails under racecheck (exit 6, host `free(): invalid pointer`),
whereas B exits 11. These controls do not establish the cause or exempt the test.
The candidate's separate polynomial/motion-mode racecheck passes with zero
hazards. The broad 3D racecheck remains unresolved for both arms.

Raw evidence, isolated binaries, commands, logs, maps, original worktree patch,
one-file candidate patch and generated timing reports:
`out/integrated-polynomial-barrier-20260910/`.
