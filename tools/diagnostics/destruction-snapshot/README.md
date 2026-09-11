# Native destruction snapshots

The [public API contract](../../../docs/destruction/SNAPSHOT.md) documents export,
restore, ownership and command boundaries. The source here is also built as
`native_destruction_snapshot_test` and registered as `physx_native_destruction_snapshot`.

`run-probe.py` keeps unique raw outputs, GPU identities, module hashes and optional
sanitizer logs. `build-probe.py` retains the isolated existing-flags build path.
The V20/schema7 suite compares two independently restored worlds, checks exact physical destruction
re-export, corrupt/truncated/missing-ID rejection, pending-command rejection,
material/topology equality, sleep/wake state, free-fall acceleration, exactly-once commands and ten continuation ticks. Solver/contact caches are rebuilt; allocation history is not saved. Large cold/warm structures
reuse `native_scenario_geometry.h`. Timings are short diagnostic continuations,
not independent A/B acceptance samples. Actual results are in the
[qualification record](../../../qualification/optimization-next20-20260910/snapshot-export-restore.md).

Generate the complete scenario table from successful runs:

```bash
python3 tools/diagnostics/destruction-snapshot/report-results.py \
  qualification/optimization-next20-20260910/snapshot-v20-results \
  out/snapshot-20260911/physical-state-v20/final-suite
```

The JSON retains every full-step sample, first-tick samples, export costs and
paired restore/validation costs. Failed historical runs are not relabeled.

Replay saved fixture files in a **new process**, one complete tick per independent
restore (the `.pxbin` and `.destruction` suffixes are added to the prefix):

```bash
python3 tools/diagnostics/destruction-snapshot/run-probe.py out/NEW-file-replay \
  --binary out/destruction-sdk/reference/native_destruction_snapshot_test \
  --artifacts physx/bin/linux.x86_64/release --require-complete-shapes \
  --replay-prefix out/snapshot-20260911/physical-state-v20/final-suite/building-fragmented \
  --repetitions 20 --allow-existing-graphics --allow-compute-pid 435374
```

The wrapper records both input hashes. `replay.json` stores each restore time,
complete tick time, material/correction/convergence counters and differences
from the first independently restored result. No capture-prefix simulation is
run. Use `--projectile-impulse` only when that explicit next stimulus is intended;
it applies the regression's angular setter and 0.1 x impulse to stable body102,
inside the timed tick. The replay helper uses this probe's fixed ordinary GPU,
TGS, gravity/filter/capacity settings; general applications recreate their own
scene configuration before calling the public import API.
