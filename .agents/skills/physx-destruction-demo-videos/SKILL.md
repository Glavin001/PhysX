---
name: physx-destruction-demo-videos
description: Record native destruction demo videos (close-up, city, staggered, tower/bridge/plate scenarios) with honest perf overlays, real-time playback re-timing and FPS counters; run the collision/penetration audits; requalify after physics changes. Use when asked for destruction videos, perf overlays, or to check chunks passing through each other.
---

# Destruction demo videos with perf stats

Everything below was built and verified on 2026-09-18 (commits 2f2b4388 … d7bf6ded on
`claude/realtime-destruction-20260915`). Scripts live in `tools/scripts/demo-videos/`.

## Build first (the pitfall that cost a session)

Everything the demo loads from `physx/` and `blast/` is compiled in `out/sdk-release`; `out/destruction-sdk`
only builds the demo and tests (it has its own copies of the stressgpu objects for tests). After any SDK edit:

```bash
cmake --build out/sdk-release -j 32            # CPU SDK, GPU module, destruction runtime (blast stressgpu)
cmake --build out/destruction-sdk -j 32        # demo + tests (target native_destruction_demo for the demo only)
find out/sdk-release -name "<edited>.o" -printf "%TH:%TM\n"   # confirm the object is fresh before measuring
```

An A/B that compares two runs of a stale binary reports noise as a gain. Keep `out/direct-ab-arms/B/` and
`out/direct-factor-feasibility-20260915/artifacts/` in sync with **both** `libPhysXDestructionGpuRuntime_64.so` and
`libPhysXGpuActivity_64.so` (a stale second module segfaults the warm probes).

## Recording

Demo: `out/destruction-sdk/reference/native_destruction_demo` with `LD_LIBRARY_PATH=physx/bin/linux.x86_64/release`.
Common physics flags (the standing city configuration):

```
--launch-seconds 0 --stress-iterations 8192 --preserve-contact-pairs 1 --gpu-island-repair 1 --gpu-pre-solve-islands 1
--gpu-pre-solve-contacts 1 --gpu-pre-solve-support 1 --gpu-connectivity-owner 0 --frame-strength 40 --record-state 0
--audit-motion 0 --trace-motion 0 --standard-scene 1 --sleeping 1
```

Rendering: `--gpu-render 1 --gpu-resolution 1920x1080 --color-by-cluster 1 --gpu-video out.mp4 --output DIR`
(`DIR` must not exist; `--seconds` must be > 2). Cameras: `--gpu-camera penetration` (one building, close),
`close` (city corner), `mid` (a quarter of the city at building scale), `overview` (whole city, far),
`structure` (frames a synthetic structure). Scenarios:

- through-wall: `--grid 1 --waves 1 --workload single-impact --shot-path through-wall --gpu-camera penetration`
- one building, N shots: `--grid 1 --waves N --workload bombardment --shot-path aerial --gpu-camera penetration`
- city: `--grid 16 --waves 1 --workload bombardment --shot-path aerial` (+ `--launch-seconds 14 --seconds 20` = staggered)
- structures (one per scene, `--grid 1`): `--geometry tower64|bridge64|cantilever64|dense12|panel32` with
  `--impact-target x,y,z` (metres from the structure origin) and `--structure-elevation H` for bridge/cantilever/plate
  (they were authored on the ground). Tower collapse: strength 8, two shots at `0,6,0`, 24 s; standing tower: strength 24.
  Bridge needs strength ≥ 300 (it breaks under its own weight below); dense block needs strength 3 + 120 t shots.
- material/projectile variants: `--material-strength 6|24|100`, `--projectile-mass 18000|120000`.

`tools/scripts/demo-videos/rerecord-all.sh` records the full set (20 scenes) and builds both overlay variants.

## Overlays

- `make-overlay.py RAW.mp4 DIR/native.frames.csv OUT.mp4 "title" ["footer"]`: one tick per frame at 60 fps.
- `make-realtime.py …`: **real-time playback** — each frame is held for max(16.7 ms, its physics step time), so
  heavy ticks slow the video exactly as a game would. Overlay: wall vs sim time, playback factor, FPS (0.5 s and 1 s
  averages of the game-side frame time, capped at 60), physics ms, stress ms, corrected pass, awake bodies,
  cumulative bonds broken, contacts, ticks over budget. Red text while over budget.
  The 0.5 s average is the primary FPS number (1 s hides impact hitches).

Stats use `physics_step_ms` (excludes the renderer) but the CUDA renderer shares the GPU: city256 numbers run
1–2 ms above headless, and the rendered bombardment breaks a different bond count (renderer registers projectile
visuals). Never use `--profile-phases 1` with fine per-shape zones for these numbers (they are gated behind
`PHYSX_DESTRUCTION_PROFILE_FINE=1` because they inflate an impact tick by >10 ms).

Publish real-time versions to `reports/destruction-realtime-ranking-20260915/videos/` and record a table
(ticks, physics mean/max, ticks over 16.7 ms, sim → wall, bonds) in `warm-screen.md`.

## Audits (headless, `--gpu-render 0`)

- `--audit-penetration 1`: per tick, chunk pairs whose centres are closer than 0.9 m (definite interpenetration);
  prints `[penetration] step … pairs … worst …` and a summary. Zero is the expectation for a single building;
  the city shows transient impact compression only (≈500 pair-ticks over the impact ticks, worst < 0.5 m).
- `--log-contacts 1`: contact-report pairs per tick involving a parent body vs others.
- `--trace-pair A,B`: contact events for the shapes of chunks A and B (with `--log-contacts 1`).
- `--audit-motion 1`: published CPU poses vs runtime cluster motions.

Bug fixed with these (d7bf6ded): migrated chunks never got broad-phase pairs with their former neighbours
(device-owner refilter); host refilter is now the default (`PHYSX_DESTRUCTION_HOST_REFILTER=0` = old path).

## Requalification after a physics change

1. g16 identity: two headless 3 s runs must agree (post-fix signature 56,735 bonds; 56,077 was pre-fix).
2. Native tests: `ctest --test-dir out/destruction-sdk -R "^(physx_native_compound_sleep|physx_native_standard_sleep_boundary|physx_native_standard_gpu_islands|physx_native_standard_wake_boundary|physx_native_standard_late_impact|physx_native_gpu_group_filtering|physx_native_gpu_publication|physx_native_gpu_shape_publication)$"`.
3. Continuous 600-tick: `systemctl stop sddm; python3 tools/scripts/run-destruction-ab.py OUT --baseline out/direct-ab-arms/B --seconds 10 --trials 2; systemctl start sddm`
   (the pre-plan A arm no longer runs today's demo; compare against recorded numbers). Order-changing changes must
   also be judged on this 600-tick run, not only the 3 s ensemble (fracture-count differences compound).
4. Warm nine-window screen: `out/direct-factor-feasibility-20260915/requalify-18b.sh` (relinks probes, copies both
   modules, runs `run-warm-suite.py plan-17f.json … --contract-version 4`). Its exact-outcome contract flags any
   physics change by design; judge those runs on timing and motion bounds and re-base the signatures.

## Known open items (2026-09-18)

- Free (toppling) tower remnant: ~100 ms/tick — a 2,300-node free component refactors at ~1 s and each factor
  application costs ms; a free body in flight needs no per-tick stress solve (open, order-changing).
- `chain256` slender column: native destruction stage failure at its first fracture tick (`INCOMPLETE native step`).
- Direct solver limits raised to 4,096 nodes / 262,144 blocks; slots are budget-bound (`BLAST_GPU_NATIVE_DIRECT_BUDGET_MB`).
