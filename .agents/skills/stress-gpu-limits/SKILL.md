---
name: stress-gpu-limits
description: Measure and reason about GPU hardware limits and kernel costs for the Slang GPU stress solver (destruction/stress-oracle/crates/stress-gpu), and check its accuracy against stress-ref. Use when optimizing stress-gpu kernels, judging whether a change is expensive (divisions, pow, loads, barriers, loops, dispatches, host waits), checking kernels against the instruction cache / register / spill / threadgroup limits, re-measuring limits on a new chip or OS, or validating a change for accuracy and speed.
---

# stress-gpu limits, costs and the fast check loop

Everything here is committed under `destruction/stress-oracle/crates/stress-gpu` (the
crate) and runs from that directory unless noted. Read results before re-measuring:

- **What is expensive, and the hard limits (measured, Apple M3 Max):**
  [limits/RESULTS_APPLE_M3_MAX.md](../../../destruction/stress-oracle/crates/stress-gpu/limits/RESULTS_APPLE_M3_MAX.md).
  Raw data: `limits/m3_max.toml`; RTX 4090 (documented, unmeasured): `limits/rtx4090.toml`.
- **How each probe works:** [limits/README.md](../../../destruction/stress-oracle/crates/stress-gpu/limits/README.md).

## The check loop for every change

Correctness first, then cost. All three are fast because the slow parts are cached.

1. Accuracy against stress-ref (cached reference runs; from `destruction/stress-oracle`):
   ```
   cargo build --release -p stress-gpu --bin stress-gpu-gate
   ./target/release/stress-gpu-gate --micro      # 25 targeted scenes + knob runs, ~12 s, after every edit
   ./target/release/stress-gpu-gate --quick      # 13 cases, ~30 s, while iterating
   ./target/release/stress-gpu-gate              # 47 cases at full duration, ~4-5 min, before a commit
   ./target/release/stress-gpu-gate --fuzz 30    # seeded scenes, ~1 min, after kernel or scheduling changes
   ```
   `--micro` names the broken semantic (events, fragments, momentum, energy closure) and
   proves each case's code path ran (coverage matrix, `src/coverage.rs`). It also checks
   that batch boundaries and sync cadence change nothing (bitwise), and that wide islands
   and plan horizons stay within 1e-5. Its GPU snapshots report any change. After an
   intended one, run `--accept-snapshots`, which passes the quick gate first.
   `--micro --explain --only NAME` shows a case's events and coverage. Details and how to
   add a case: PLAN.md, "Test tiers".
   The cache (`target/stress-gate-cache`) is keyed by each case's scene and a fingerprint
   of stress-ref's sources, so it refreshes itself when either changes. Missing entries:
   `--build` (CPU only, ~20 min from empty). Force: `--refresh` or `STRESS_GATE_REFRESH=1`.
   Chaotic cases (the reference's own perturbation ensemble scatters its counts by >= 10%)
   are judged by the GPU's ensemble distribution, not one run. Never loosen the gate to make
   a change pass; investigate (see `gate.rs` docs).
2. Static kernel budget (no GPU work; regenerate shaders first if Slang changed:
   `scripts/compile_shaders.sh`):
   ```
   scripts/kernel_budget.sh            # per-kernel instructions, registers, spills, code size vs knees and baseline
   scripts/kernel_budget.sh --update   # accept an intended change as the new baseline
   ```
   Fails on > 5% growth in instructions or code bytes, or any growth in spilled bytes.
3. Hard-limit targets (track progress; several fail today by design, so they are
   `#[ignore]`d in plain `cargo test`):
   ```
   cargo test --release -p stress-gpu --test kernel_limits -- --ignored --nocapture --test-threads 1
   ```
   One test per limit (instruction cache, no spills in hot kernels, spill stack per
   threadgroup, register cap, threadgroup memory, threadgroup size), each printing
   kernel / value / x limit / verdict. Update the status table in the results file when a
   test changes state.
4. Time, when the change is meant to be faster (GPU runs; see conditions below):
   ```
   ./target/release/stress-gpu-latency                         # island kernel us/substep vs bonds per thread (min of repeats)
   ./target/release/stress-gpu-coupled-fps --gpu-only           # PhysX-style frames: idle and destruction, per step mode
   ./target/release/stress-gpu-coupled-fps --gpu-only --pace    # same, frames on 1/60 s ticks
   ```
   Report complete-frame median and worst with chunk/bond counts, in both the idle and the
   destruction regime (repository AGENTS.md rule).

## Re-measuring the limits (per chip or OS update)

```
scripts/limits.sh                         # default probes, ~30 s of GPU; writes limits/<target>.toml
scripts/limits.sh --probes ops,dispatch   # a subset
scripts/limits.sh --repeats 11 --out /tmp/x.toml
```
Opt-in probes: `--coresidency` (bounded spin, blocks the GPU a few ms per point) and
`--watchdog S` (single command buffers up to S seconds: can stall the desktop; never run
it unattended or on a shared machine). After re-measuring, update
`limits/RESULTS_<CHIP>.md` (anonymized: chip, GPU cores, OS, power mode; nothing about the
owner or machine identity).

## Measurement conditions

- The GPU is shared (other developers' services, browsers, the window server). Never stop
  other processes. Check `ioreg -r -d 1 -c IOAccelerator | grep "Device Utilization"`;
  report minimum of N repeats and flag contended runs. Large run-to-run swings (> 20%) mean
  contention: do not draw conclusions from them.
- Warm the GPU first; after 8 ms or more idle the clock drops and kernels run ~4x slower.
- `STRESS_GPU_TIMING=1` timestamps each dispatch in its own wgpu pass (two command buffers
  each): it inflates per-dispatch costs (~5 us apparent vs 1.03 us real). Use it only for
  relative kernel attribution, never for dispatch overhead.
- Shader variants for experiments: edit the Slang, regenerate only Metal with the pinned
  compiler (`docker run ... stress-gpu-slang:2026.19 ... -target metal`, as in
  `scripts/compile_shaders.sh`), rebuild, measure, then restore; check generated MSL when
  using SIMD builtins (Slang drops lane builtins in multi-kernel modules; the code takes the
  lane from the thread index).

## Reasoning about cost (from the measured results)

- Kernels here are latency-bound: one threadgroup per island, long dependent chains. Count
  the hot path in dependent operations at the measured costs, not FLOPs.
- The executed code per substep should stay under the instruction-cache knee (~17 KB
  straight-line, ~10 KB with loads and branches); beyond it every instruction costs ~2-3x.
  Rare paths belong out of line (`[noinline]`), not inlined into the hot path.
- Zero spills in hot kernels; spilled bytes x threads must stay under ~184 KB per group.
- Precise `/` ~37 ns, precise `pow` ~400 ns, `sqrt` ~26 ns, dependent load ~45-55 ns,
  barrier exchange ~110-130 ns, loop iteration ~14 ns, FMA ~1 ns.
- Dispatch inside one pass ~1 us; separate command buffers ~15 us; a blocking host wait
  ~100 us. Grid-wide barriers across threadgroups are not supported on Metal (no forward
  progress guarantee; MSL 3.1 lacks device-scope fences): use them only on CUDA
  (cooperative launch).
- Accuracy constrains cost cuts: whole-kernel fast math and reciprocal division failed the
  gate; replace operations site by site and gate each.
