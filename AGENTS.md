# AGENTS.md — PhysX GPU destruction: fresh-session entrypoint

## Current task and machine — updated 2026-09-10

Work in `/root/workspace/physx-2` **on the new VM** (`vast-new` from the old
machine). If already inside the VM, run commands locally; the SSH alias need not
exist there. This is the user's custom embedded destruction project, not an
ovphysx/Python package installation task.

**Resume from:** branch `codex/rtx5060ti-cuda134`, migration commit `795f9c0c`.
Transferred source baseline: `471ea8a55bef3d1320a06d65d238f351f9015859`.
Check actual Git state before work: another session may have advanced it.

- ✅ RTX 5060 Ti 16 GB, CC 12.0 (`sm_120`), driver 615.71.09 after reboot.
- ✅ CUDA 13.4.59; Nsight Compute 2026.3.0; Nsight Systems 2026.3.2.
- ✅ CMake 3.31.10 in `.toolchains/build-env`; Clang 14 for CPU, GCC 12.3 as NVCC host compiler.
- ✅ SDK built/installed; hardware counters captured from an actual destruction motion-slot kernel.
- ⚠️ Physical equivalence is **not qualified** on the new GPU/toolchain. No new performance win has been established by counters.
- No game deployment or Rust/WASM consumer qualification occurred on this VM.

The previous RTX 4090/CUDA 12.8 machine remains a historical reference. Dated
4090-only, unavailable-counter, RAM-build, server-PID and deployment statements in
older documents do **not** describe this VM. This section and the migration report
supersede their environment/status claims, not their physical requirements.

## Objective and decisions to preserve

Maximize physically equivalent destruction work, especially simultaneous
256-building bombardment. 8 ms and 16.67 ms complete-step peaks are milestones,
not permission to leave avoidable work. Focus on destruction/integration added
to PhysX; retain NVIDIA's ordinary rigid-body solver as the foundation.

- User-facing path: `PxDestructionScene`, normal `simulate`/`fetchResults`,
  **Direct GPU mode disabled, sleeping enabled**, current-tick queries/actors.
- Fixed timestep **1/60 second**; **one correction maximum**, hence at most two
  physics advances and two stress/fracture evaluations per tick. Stress runs
  again after corrected physics. Iterations are not correction passes.
- Trial solves actual intact contact impulses → stress/material verdict →
  topology/motion update → rewind/correction of all affected participants →
  second verdict → accepted publication. No predicted/pre-authored breakage.
- GPU owns persistent chunk/bond state and numerical work; one motion per rigid
  cluster, not one independently simulated body per intact chunk. CPU submits
  commands and publishes required accepted actor/query compatibility data.
  **CPU fragment/contact registration prerequisites still remain.** Do not claim
  the final GPU-owned lifecycle is complete.
- Preserve convergence, forces/torques, contact discovery, mass/COM continuity,
  energy/damage and exactly-once commands/events. Do not spend unfinished stress
  convergence across ticks or loosen tests to manufacture performance/parity.
- No production compatibility fallback. This port requires CUDA >=13.4 and
  selected architecture 120; retained architecture 89 is not requalified here.
- Keep source siblings `vibe-land-4` and `blast-stress-solver-2` read-only. Do not
  stop other users' services, desktop or GPU jobs. This handoff does not authorize
  deployment, another reboot, instance deletion or driver changes.

## Validation state: do not restart these investigations from scratch

| Evidence | Status |
|---|---|
| CUDA probe / PTX JIT / memcheck / counters / timeline | ✅ Passed |
| CPU report tests | ✅ 52 passed |
| Broad native/numerical screen | ⚠️ 57/61 passed; includes 8 standalone GPU tests and 6 smoke checks (do not add those again) |
| Motion-slot memcheck | ✅ Zero errors; fixture capacities through 113,664 slots, not a city simulation |
| Ordinary penetration, sleeping on | ⚠️ 600 steps / 10 sim seconds; 444 chunks, 896 bonds, 1 projectile. Both holes, projectile clearance and motion invariants pass. 400 supported, 44 detached, 182 broken bonds, 39 clusters; historical golden is 398/46/199/43. Exact identity gate fails. |
| Direct GPU penetration control | ❌ Same fixture/duration; displaced-wall-chunk invariant fails |
| Two large native audit failures | ❌ 256 buildings, 113,664 chunks, 229,376 bonds, 256 shots, 180 steps. Exact-zero pose assertion fails by ~22 micrometres (Direct GPU) / ~17 micrometres (ordinary + sleep). |
| Other two native failures | ❌ Accepted-properties TGS/PGS initcheck; isolated CUB scan reproduces warnings with correct outputs. Cause unresolved. |

Frozen tests/tolerances were not changed. An aligned-transform pose experiment
did not fix the discrepancy and was reverted; temporary logging was removed.
Do not repeat that unchanged experiment. CUB poisoned-output control clears the
warnings, but **production zeroing/suppression was not added**. A sanitizer issue
is a hypothesis, not an established exemption. Historical golden API-mode parity
has not been independently established in this migration; do not assert a specific
compiler/device cause before comparing matched controls.

Committed evidence: [migration report](qualification/rtx5060ti-cuda134-20260910/README.md).
Raw VM captures: `out/vm-port-20260910/`; probe: `/root/cuda-upgrade-check/postboot.qVQlHO/`.
No massive-destruction peak kernels have yet been counter-profiled. The synthetic
probe's utilization numbers say nothing about stress bottlenecks.

## Start working: commands and immediate priorities

```bash
cd /root/workspace/physx-2
git status --short
git log -3 --oneline
nvidia-smi
ps -eo pid,etime,comm,args | grep -E 'nvcc|cicc|ctest|native_destruction|ncu|nsys'
df -h .
export PATH="$PWD/.toolchains/build-env/bin:/usr/local/cuda-13.4/bin:$PATH"
# Incremental build/install; do not discard existing build directories.
python tools/scripts/build-destruction-sdk.py --jobs 8 \
  --cuda /usr/local/cuda-13.4/bin/nvcc --cuda-architectures 120 \
  --cc /usr/bin/clang --cxx /usr/bin/clang++ --gpu-renderer
```

1. Resolve/attribute migration validation failures with matched captures; compare
   the first differing contact/load/stress verdict, not just final counts.
2. Use a separate diagnostic run to locate current 256-building peak scopes,
   then capture selected expensive destruction kernels with hardware counters.
   Exploration can proceed while parity is unresolved, but cannot establish a
   physically equivalent performance win.
3. Resume ranked replacements from [TODO.md](TODO.md). Rank 1 lifecycle is partial;
   the static-registration integration patch is **unapplied**, not a completed win.
4. Measure fresh intact idle and peak destruction separately on matched settings.
   Use untraced complete-step timing for claims; keep first-step/allocation spikes.
   Hardware profiler time, nested scopes and CPU core-ms are not additive wall time.

Every number needs workload, chunks/bonds/projectiles, active work if available,
duration/repeats and timer scope. Do not substitute means/p99 for maximums. Report
fidelity, architecture/maintainability and measured speed separately: a neutral
architectural step may be useful, but is not a speedup.

## Skills, code and evidence routing

Read only the workflow needed; the essential current status is above.

- [VM build and validation skill](.agent/skills/physx-vm-validation/SKILL.md): exact commands, failures, captures and migration pitfalls.
- [Counter profiling skill](.agent/skills/physx-destruction-profiling/SKILL.md): capture selection, measurement separation and counter interpretation.
- [Existing performance skill](.agents/skills/physx-destruction-performance/SKILL.md): optimization method, experiment rules and historical index. Both `.agent/` and `.agents/` intentionally exist; keep old links valid.
- [Optimization inventory](docs/destruction/OPTIMIZATION_INDEX.md), [ranked replacements](docs/destruction/REPLACEMENT_PLAN.md), [failed experiments](docs/destruction/PERFORMANCE_FINDINGS.md): historical mechanisms/evidence, not current-device performance promises.
- Public API: `physx/include/PxDestructionScene.h`; GPU orchestration/topology:
  `physx/source/gpudestruction/src/`; stress: `blast/source/sdk/extensions/stressgpu/`
  and `detail/`; actor bridge: `physx/source/physx/src/NpDestructionBodyAllocator.h`;
  simulation integration: `physx/source/simulationcontroller/src/` and
  `physx/source/gpusimulationcontroller/`; demos/tests: `demos/blast-stress-demo/`.

## Storage and handoff hygiene

8,493 source entries and Git history were copied and hash/symlink-verified.
Old `out/`, build caches and `/tmp` captures were NOT fully migrated. Do not claim
this is a complete old-instance backup or advise deleting it. Old recorded RAM
symlinks are not inputs to this VM's rebuilt SDK. Transfer manifest:
`/root/cuda-upgrade-check/physx-transfer/source-manifest.json`.

Existing `docs/destruction/visual-audit-20260909/` is untracked user WIP; preserve
it and exclude it from unrelated commits. All migration code is committed at
795f9c0c. Use fresh capture directories, preserve failed attempts, and record actual
loaded modules (`/proc/PID/maps` for dynamically loaded libraries), hashes and
commands. `out/sdk-artifacts.json` is refreshed by the build helper; later manual
builds require refreshed attestation. No Git remote push is implied.

At handoff update this dated snapshot, TODO dispositions and evidence links.
Record any live job PID/log instead of leaving a new agent to rerun it. A docs-only
handoff needs link/command review, not another expensive simulation campaign.

## ovphysx (unrelated upstream project)

Self-contained Python/C library for USD-based physics simulation — the fastest
path to running PhysX from Python for reinforcement learning and robotics.

```bash
pip install ovphysx
```

- **Documentation:** https://nvidia-omniverse.github.io/PhysX/ovphysx/index.html
- **Source subfolder:** [`ovphysx/`](ovphysx/)
- **Samples:** `ovphysx/tests/python_samples/` (hello_world.py, clone.py, etc.)

The installed wheel ships `SKILLS.md` with step-by-step playbooks for common
tasks (scene loading, environment cloning, tensor bindings, resetting).

## Other projects in this repo

| Directory | What it is |
|---|---|
| [`physx/`](physx/) | PhysX SDK — C++ real-time physics engine |
| [`blast/`](blast/) | Blast SDK — destruction and fracture simulation |
| [`flow/`](flow/) | Flow SDK — fluid and fire simulation |

Each subfolder has its own README with build and usage instructions.
