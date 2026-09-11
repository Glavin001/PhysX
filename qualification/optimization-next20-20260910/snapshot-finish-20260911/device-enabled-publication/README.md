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
