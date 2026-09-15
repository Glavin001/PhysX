# N25 local row ownership

**Rejected: no application gain or retained change. Batch19/20.**

[All seven repeated full-step means/maxima, stages, setup and deadline counts](n25-screen.md); [numerical, memory and profile evidence](n25-result.json).

Commit `37d7a3ddbc871d543419fd1a53b1b5a3b634182f` changes only local residual/restriction/correction scheduling. The existing eight-lane-per-row path processes rows concurrently. Cooperative large-component kernels keep their existing grid-wide decomposition. Every bond term, cached self contribution, FP64 arithmetic, current-tick ordering and convergence setting remains required. The isolated empty-child safety correction is inherited.

The evidence is [N24's source-counter diagnosis](n24-equation-profile.json): the old local path serially emulates eight full cooperative row tiles, including empty and disabled contributions. This repeats shuffle/reduction work; source counters alone do not prove a net application saving versus the retained control. The queue estimates0–30ms at active heavy steps with low-to-medium net-benefit confidence.

The control runtime and its native consumers are reused byte-for-byte from the completed N24 follow-up. Only candidate runtime/consumers are rebuilt. Both control and candidate hierarchy test binaries are rebuilt against an expanded checker: **both schedules** independently run the original dense full-basis, symmetry, energy, linearity and repeatability checks. Cross-schedule bit equality becomes a recorded diagnostic because row ownership changes summation order. Cross-schedule error uses the existing2e-12 component-coordinate norm from cycle linearity. Dense reference bounds and all final engine force, health, motion and convergence requirements remain unchanged; no final precision policy has been changed.

Kernel resources remain168 registers and48 stack bytes per thread; removal is the tested mechanism, not a register-count improvement. Candidate storage remains isolated. Main runtime/index and installed SDK are unchanged.

The coordinator completed cycle, native, normal asynchronous memory and120-tick light A/B/A screens. Full-basis mathematical checks, full initcheck/memcheck and targeted synchronization checks pass. Impact/debris final force/health comparisons fail; no quality gate is waived. No full52 or warm finalist extension is warranted for this rejected runtime.

The targeted bridge profile confirms the removed shuffle work, but the remaining component solve still dominates. Tile is not integrated, and this experiment does not establish a Tile speedup. Main runtime/index and installed SDK remain unchanged. The access-only harness passes all three sanitizers: memcheck329.716s, initcheck189.600s and synccheck21.083s, all zero errors. Original full-basis numerical and full memory passes remain separate. Test-only commit71a9deab6e4355138117c6b5cc38bb0940b0170e; main runtime unchanged. Counter collection has resumed from48/52 after a checked empty GPU; restoration watcher338813 remains alive. Establish a new completed boundary before another GPU experiment.
