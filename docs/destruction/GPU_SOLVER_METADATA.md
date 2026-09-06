# Persistent GPU solver island metadata

Both native GPU solvers (PGS and TGS) now consume persistent device arrays for
node-to-native-island IDs and per-island static-touch counts. These inputs affect
integration, stabilization and wake behavior. Their numerical meaning and staging
boundary are unchanged. This is an intermediate device-consumer integration;
CPU island maintenance still produces their values.

## Ordering and lifetime

`PxgGpuContext::updatePostPartitioning` stages these inputs before releasing the
lost-contact tasks. The destruction contact graph is finalized later, after
manager retirement. Feeding that later graph directly to the solver would change
which interaction state influences stabilization. The persistent arrays therefore
retain the native pre-solver values until a phase-correct CUDA producer replaces
that CPU producer.

Writes to the accurate native island registry mark 256-entry metadata pages.
Each native island simulation has its own bitmap; accurate and speculative
third-pass tasks do not share it. The accurate task and pre-solver staging are
ordered by the existing task dependencies. The pre-solver publisher acknowledges
its dirty maps before releasing later native island tasks. Changes in those later
tasks remain dirty for the next publication, including correction.

At first use, mode changes, or domain-size changes, the original full arrays are
uploaded. Growth must use a complete upload because the solver buffer allocator
can discard previous contents. Otherwise only dirty pages are staged, unless
page payload would cost at least as much as a full upload. An unchanged pass
submits no metadata transfer or kernel. A CUDA scatter runs on the solver stream
before integration reads the arrays. Invalid internal page descriptors trap;
launch failure enters CUDA abort mode rather than allowing a partial step.

Page commands contain kind, offset, count and 256 values (1,036 bytes). Native
bitmaps yield unique pages. Only the final page may be short. Persistent pinned
and device command staging adds capacity-dependent memory; destination arrays
already existed. This is a transfer optimization, not a memory reduction.

## Diagnostics and independent checks

`native.graph-diagnostics.json` reports metadata submissions (including trial and
correction), full/page/quiet passes, page count, actual payload H2D bytes and the
full-upload equivalent. These counters exclude other solver inputs, component
readback, allocator overhead and diagnostic observations. They are not total
engine traffic or GPU kernel timings.

`--audit-islands 1` additionally captures full native arrays at the pre-solver
boundary and compares the actual solver device buffers after each accepted step.
It verifies the last solver submission of that step, including a correction when
present; it does not independently inspect every intermediate trial buffer.
Diagnostic copies are off in production and are excluded from transfer counters.
Native lifecycle fixtures also compare both full arrays exactly, independent of
the dirty-page staging. Kernel tests check preserved entries, reversed disjoint
page order, repeated updates, partial tails and buffer guards.

## Remaining integration

The CPU still creates/merges/splits its island registry and computes static-touch
counts. CUDA contact components still have a CPU compatibility readback consumer.
Native constraints are still partitioned using existing PhysX machinery, and this
change does not introduce independent correction scheduling. Removing these CPU
producers/readbacks requires a device registry with the correct pre-solver and
post-retirement states, joint and sleep semantics, and validated fallback. A late
contact graph is not an interchangeable solver snapshot.

The audited 64-building capture demonstrates why that work matters: 682 of 706
solver submissions used full metadata uploads during destruction. Sparse paging
alone is not a large-scale rubble solution. See
`qualification/native-solver-metadata-20260906.json` for exact test, capture,
transfer, timing and provenance evidence. The full SDK completion gates and
previous unexplained native crash/real-fracture sanitizer failure remain open.

A subsequent opt-in [CUDA pre-solve producer](GPU_PRE_SOLVE_ISLANDS.md) now
computes phase-correct components and static-support reductions for direct solver
consumption. The native metadata arrays remain available for its reference and
audits; their CPU producer has not yet been removed.

CUDA-produced passes now bypass native metadata staging and upload; the first
native fallback refreshes complete buffers. See
[GPU_PRE_SOLVE_NODE_TRANSACTIONS.md](GPU_PRE_SOLVE_NODE_TRANSACTIONS.md) for current
node transactions, bypass counters and independent selected-input audits.
