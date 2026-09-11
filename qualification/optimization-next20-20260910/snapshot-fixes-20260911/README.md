# Snapshot repeatability and topology ordering fixes — investigation

The 52-case baseline is measured but has nine city health-equality failures.
This work keeps physical snapshots, one complete tick per restore, the current
material/convergence settings, and restore/validation outside timing. No speedup
is claimed from diagnostic controls. Production/installed artifacts remain
unchanged while the candidates are tested.

## Contact accumulation

In city25 post-impact, all 19 repeats after the reference have differing node
accelerations and surface loads. One repeat propagates the difference into
3,649 bond-force components and two bond health values (maximum 5.960464478e-8).
The source uses concurrent floating-point atomics for contact loads.

A fixed-order, one-thread diagnostic produces byte-identical loads, forces and
health over 20 repeats of that input. The 113,664-chunk late-debris input also
passes all 20 repeats with this control (11,051 new broken bonds, 16,135 output
clusters). This diagnostic is not a production performance candidate.

The parallel candidate sorts integer contact references by authored chunk and
pair/side ordinal, then gives each chunk one writer for load accumulation.
It processes chunks in parallel and retains every contact contribution and
material setting. All 20 post-impact repeats match the fixed-order control's
node accelerations, surface loads, bond forces, health and active bonds byte
for byte. The parallel candidate also passes all 20 repeats of the 113,664-chunk late-debris input. Full-suite qualification remains pending.

## Native memory-check controls

All controls use the same city25 initial-impact snapshot and two independent
one-tick restores. Successful controls reproduce 3,412 new broken bonds,
537 output clusters, one correction, two stress evaluations and 304 iterations.

| Control | Result |
|---|---|
| Production topology graphs | 114 errors |
| Compile-time topology instrumentation | 6,817 errors |
| Explicit launches with synchronized decisions | PASS, zero errors |
| Existing graphs, device synchronization before and after | PASS, zero errors |
| Existing graphs, synchronization only before | PASS, zero errors |
| Existing graphs, synchronization only after | 155 errors |
| Existing graphs, incoming ready-event synchronization | PASS, zero errors |
| One-time graph upload during initialization | Fails; see controls.json |

This narrows the exposure to the incoming stream/event boundary. It does not
by itself distinguish missing application ordering from sanitizer handling of
otherwise valid event dependencies. A candidate that lets the native topology
transaction borrow the producer's execution stream still fails (97 findings);
sharing that stream is not a demonstrated fix.

Exact commands, input/module hashes and results are in [controls.json](controls.json).
Raw build scripts, focused patches and logs are under
`out/snapshot-large-20260911/`. The original failures remain failures.

## Delayed standalone producer

The production standalone topology test normally passes memcheck. Adding only
a one-thread GPU delay before the existing producer ready-event record makes
its 100,000-chunk transaction fail with 2,612 findings in `connect`, again
described as out of bounds while inside the live 400,000-byte label allocation.
The modified test passes plain. This reproduces the exposure without native
physics or snapshots; a CUDA-only reduction is in progress. The original
stream wait remains present and no topology data or allocation was changed.
Raw: `out/snapshot-large-20260911/delayed-topology-repro/`.
