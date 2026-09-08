# Retained ordinary contact reports across correction

The native Vibe-land consumer exposed a crash in the 256-building bombardment:
113,664 chunks, 229,376 bonds, 768 scheduled 18,000 kg projectiles at 40 m/s,
Direct GPU API disabled, sleeping enabled, max one correction / two stress passes.
Three runs (untraced and two debugger runs) reached the second wave and crashed
in `PxContactPair::extractContacts`, inlined into the game's `onContact` callback.
The detailed debugger run found a null contact-patch pointer with nonzero count.
This was not a CUDA stress-kernel crash.

Correction cleared the contact-report allocator and actor-pair report list but
retained interaction report stamps. `ShapeInteraction::processUserNotificationAsync`
therefore treated trial actor/shape report entries as already allocated. New pairs
could allocate over those same offsets in the corrected pass. Invalidate the
reported actor reset stamps and advance the internal shape-report stamp before
recycling the trial report storage. Do not increment the public scene timestamp:
one accepted tick still means one timestamp increment.

Validation:

- Eight ordinary native scene tests pass. The callback now validates/extracts
  points, normals and impulses instead of discarding reports; reported-pair reuse
  has its own test. These small fixtures also passed before the fix, so they are
  coverage, not the reproducer for the large-scene crash.
- Frozen 10-second penetration remains 444 chunks / 896 bonds, 398 retained,
  46 detached, 199 broken bonds, topology signature
  `e589eb8317c456147287443232209bb950514a75b5e4fb6783e2de5fe7486d4c`.
- The game consumer completes 600 steps at 4, 64 and 256 buildings (three waves,
  12 / 192 / 768 projectiles). Every step checks committed event/state count
  agreement, no duplicate bond publication, correction ≤1 and stress passes
  exactly 1 + correction. Final shape ownership passes. The 256-building case
  previously crashed before finishing its second wave.
- Browser join/shoot/move/settle/reset passes on the rebuilt server: one building,
  444 chunks / 896 bonds, six rounds, 229 broken bonds, 44 fragment groups.
  Thirty settling samples stay above the floor; reset returns to intact.
  Six browser resource-load errors remain (COEP/404); this is not a clean-resource
  browser audit or exhaustive movement/endurance qualification.

Generated timings and archived debugger/test evidence are in the game checkout:
`docs/reports/embedded-scale-2026-09-08/`. The 256-building complete-step peak is
186.782 ms, with 16,587 fragment bodies / 13,747 awake at tick 139. This fix is a
correctness improvement, not an established speedup. It does not satisfy 60 Hz.

Reproduce from `vibe-land-2` after building the matching engine:

```bash
PHYSX_DESTRUCTION_SDK=/root/workspace/physx-2 \
CARGO_TARGET_DIR=/root/workspace/physx-2/out/vibe-native \
cargo build --release -p vibe-land-destruction --features embedded-destruction \
  --example embedded_city_bench
# Run only on an idle GPU; preserve fresh output paths.
LD_LIBRARY_PATH=/root/workspace/physx-2/physx/bin/linux.x86_64/release:/usr/local/cuda/lib64 \
/root/workspace/physx-2/out/vibe-native/release/examples/embedded_city_bench \
  /tmp/NEW-bombardment/256-buildings 8 600 3
python3 scripts/report-embedded-city-bench.py /tmp/NEW-bombardment /tmp/NEW-report
```

This benchmark drives the real game loader/adapter/accepted-event consumer; it
omits renderer, networking and player simulation. The 17.96 m building spacing
and ordinary game sphere damping differ from the standalone demo. Do not compare
raw times against historical captures as if the inputs were identical. Each
accepted row is streamed to `steps.jsonl`, preserving partial evidence on a later
crash; only a completed run produces the final report.
