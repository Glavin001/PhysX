# GPU active motion partition — 10 September 2026

The new private partition converts native authored topology into compact GPU
load-adapter storage, with device-owned counts, stable-slot validation, explicit
revision reuse and downstream error gating. Source is uncommitted WIP on
`1155b7ff`; the installed SDK stress/runtime binaries remain unchanged.

See the [contract](../../docs/destruction/elastic-partition-contract.md) for the
input/lifetime/version requirements and remaining integration work. This is a
motion-aggregate mapping, not a numerical stress-component decomposition.

## Native exercise

An isolated runtime invokes the partition at the real post-contact/pre-stress
boundary. One final diagnostic trajectory uses 256 buildings, 113,664 chunks,
229,376 authored bonds, one 256-shot wave, 180 steps / three simulated seconds,
ordinary API and sleeping enabled. Physical timestep remains 1/60 with at most
one correction. Native snapshots and code/build provenance are under
`out/elastic-partition-20260910/final/`.

The intended captured evaluations are startup, the first-fracture trial and
correction, and the later tick-109 trial. Timings from this copying/instrumented
run are not complete-step performance claims. Desktop graphics remain active.

The final run completed. Device partition receipts show:

| Native tick / evaluation | Motion aggregates | Active chunks | Successful builds | Rebuilt this query |
|---|---:|---:|---:|---|
| 1 / trial | 256 | 113,664 | 1 | yes |
| 83 / trial | 256 | 113,664 | 1 | no |
| 83 / correction | 5,120 | 113,664 | 2 | yes |
| 109 / trial | 10,905 | 113,664 | 3 | yes |

All partition errors are zero. The native trajectory matches the existing
Systems capture's fracture, cluster, contact, correction/evaluation and
stress-active-node/bond histories. Iteration counts differ on 24 later steps,
first at step 132. This is not full physical-equivalence qualification; the
previous migration failures remain unresolved.

## Numerical, sanitizer and counter evidence

All four captured surface-plus-gravity replays pass the independent Newton–Euler
comparison at the existing `2e-11 * (1 + abs(reference))` limit. The mapping,
surface/command scatter, device-count adapter and final authored-order output
restoration all execute on the GPU. Final profile and nonprofile receipt/effective
load buffers are byte-identical.

Five focused CTests pass. The new partition regression covers sparse 137/521-node
layouts, empty/all-deleted topology, canonical positions, load scatter, revision
reuse, output reallocation, splits, duplicate membership, stale topology,
invalid/reused slots, producer errors and invalid output/count bounds.
Both the later native replay and the partition regression pass memcheck,
initcheck, synccheck and racecheck: eight successful sanitizer runs.

The initial sparse-test initcheck failed because diagnostic readbacks copied
unused compact capacity. The test now reads only the initialized active prefix;
no production buffer zeroing or sanitizer suppression was added. This is separate
from the older unresolved CUB warnings. Review also added zero usable counts on
partition failure, with an oversized-topology-count regression that reaches the
downstream adapter gate without inspecting invalid bounds. Earlier failures are
retained under the raw capture directory.

Hardware: RTX 5060 Ti, CUDA 13.4.59, driver 615.71.09, Nsight Compute 2026.3.0.
The counter replay uses tick-109 inputs: 113,664 chunks, 10,905 motion aggregates,
including 9,114 free singletons; 176,336 live bonds are recorded but this replay
does not run the bond solver. One counter capture per selected kernel, ten replay
passes each, cache flush enabled, clocks unlocked, desktop graphics active:

| Selected kernel | Profiler duration | Registers/thread | Achieved occupancy | DRAM / peak | Local/shared spilling requests |
|---|---:|---:|---:|---:|---:|
| Fresh partition `pack` | 88.22 µs | 36 | 81.75% | 65.03% | 0 / 0 |
| Device-count load `build` | 1.95 ms | 118 | 26.58% | 3.82% | 0 / 0 |

These are individual profiler kernel scopes, not full partition cost, complete
physics-step timing or an integrated speedup. Other preparation/scatter/gating
kernels still contribute. The mapping retains unchanged data but currently
launches guarded capacity-sized kernels; final conditional scheduling and
selective dirty-component preparation remain unfinished.

The adapter source is slightly above the 500-line review target after adding
device-count entry points; equations and their owning private helpers remain
together. No unrelated structural extraction or numerical-tolerance change was
made to meet a line count.

[receipt.json](receipt.json) records source/binary/module hashes and exact commands.
[native-analysis.json](native-analysis.json), [reference-check.json](reference-check.json)
and [counters.txt](counters.txt) retain the supporting results. The installed runtime
hash still matches SDK attestation. Current source is preserved in
[source.patch](source.patch). All owned jobs finished.

Next wire a distinct live command/contact interval receipt, prescribed motion,
and general scene/mass/geometry revisions. Native post-correction snapshots are
not original applied-load history. Then provide numerical component/setup keys,
fine bond/material conversion and accepted trial/correction transactions.

## Reproduction

```bash
.toolchains/build-env/bin/cmake -S destruction -B out/destruction-sdk
.toolchains/build-env/bin/cmake --build out/destruction-sdk --target stress_elastic_partition_test stress_elastic_loads_test --parallel 8
.toolchains/build-env/bin/python tools/diagnostics/destruction-load-capture/build.py out/partition-NEW/build
.toolchains/build-env/bin/python tools/diagnostics/destruction-load-capture/run.py out/partition-NEW/native
/usr/local/cuda-13.4/bin/nvcc -std=c++17 -O3 -lineinfo -arch=sm_120 -ccbin /usr/bin/g++-12 \
  -Iphysx/include -Iphysx/source/gpudestruction/src -Iblast/source/sdk/extensions/stressgpu/detail \
  tools/diagnostics/destruction-load-capture/Replay.cu -o out/partition-NEW/replay
.toolchains/build-env/bin/python tools/diagnostics/destruction-load-capture/validate.py \
  --capture out/partition-NEW/native --replay out/partition-NEW/replay --output out/partition-NEW/validation
```

Use fresh output directories and check GPU availability first. These tools do
not stop other jobs or overwrite installed libraries. The validation wrapper
checks independent Newton–Euler equations, focused CTests, replay/partition
sanitizers and counter-output identity. It now selects both `pack` and `build`
for hardware counters.
