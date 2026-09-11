# Flat topology plus committed-change publication — isolated candidate

Extends the topology-only candidate f8d983013bb2519b73fb72e5fff3499bc90a97bc.
That candidate completed the normal asynchronous memcheck suite at **51/52**,
with the remaining cold-ladder failure in the separate committed-change
publication conditional graph (CUB byte-flag selection).

This candidate uses a GPU-selected flat graph for publication as well. It keeps
initial full publication, rejected-trial silence, cycle-cut bond events, union
of both same-tick commits, and final accepted identities. All host/GPU ordering
and field values are unchanged. A small reusable helper converts CUB memset
nodes to byte-preserving fills and creates the device-updatable body.
The native motion allocator still has its existing cooperative conditional graph;
no unsupported claim that all conditional graphs have been removed is made.

The existing publication regression passes plain and normal asynchronous
memcheck. Native cold ladder and 113,664-chunk first impact each pass both plain
and normal memcheck, two independent one-tick restores. Large late debris also
passes both plain and normal memcheck. All eight screen commands pass; exact
commands and exit codes are in screen-results.json.
No blocking-launch mode, suppression or CPU per-tick wait is added.

The second full 52-scenario memory campaign, matched physical A/B outputs,
correction regressions, full ordinary sleeping wall and unprofiled performance
comparisons are required before retaining this candidate. No application speedup
is claimed. Main worktree/runtime and installed SDK remain unchanged.

Raw artifacts and exact build/test commands:
`out/snapshot-finish-20260911/device-enabled-publication/`.

## Completed qualification and remaining failure

Frozen candidate commit: `d5d0ca49ba37f7273e8532ce77d1beec3bd4df82`.
The full normal asynchronous memcheck suite passes **52/52**, 104 ticks,
623.121 seconds of harness time (instrumented times are not performance data).
Raw: `out/snapshot-finish-20260911/device-enabled-publication-mem-suite/`.
Three physical A/B screens pass: flying rigid bodies, 11,100-chunk initial impact,
and 113,664-chunk late debris. Destruction arrays match exactly; measured body
positions and linear/angular velocities have zero differences. Raw comparisons:
`out/snapshot-finish-20260911/physical-screen-*-comparison.json`.

The separate 29-case correction regression passes plain but fails normal
memcheck with 1,588 reported errors in motion allocation, including an ordinary
API case. This candidate is **not retained**. The ordinary wall was not run by
that gate sequence because it stopped on the correction memory failure.
Raw: `out/snapshot-finish-20260911/publication-correction-{plain,mem}/`.
The next experiment converts that remaining allocation/preparation graph while
preserving cooperative allocation and all capacity/rejection checks.
