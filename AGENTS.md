# AGENTS.md — NVIDIA PhysX Repository

## Integrated GPU destruction work

For native destruction implementation, optimization or performance testing, read
[the repository performance skill](.agents/skills/physx-destruction-performance/SKILL.md).
Its [playbook](docs/destruction/PERFORMANCE_PLAYBOOK.md) contains runnable commands;
[findings](docs/destruction/PERFORMANCE_FINDINGS.md) and the
[dated handoff](docs/destruction/PERFORMANCE_HANDOFF.md) distinguish evidence,
rejected experiments and unfinished architecture. Verify dated status against
current source and artifacts.

Current focus is RTX 4090/sm_89, fixed 1/60 timestep, max one correction, and
maximum actual destruction within every-step 8 ms (16.67 ms reported separately).
Preserve physical work and the GPU-resident destination. Source sibling checkouts
`vibe-land-4` and `blast-stress-solver-2` stay read-only. Report complete-step peaks
with workload/chunk/bond counts; do not substitute a narrow timer or average.
Run isolated GPU jobs sequentially without stopping other developers' services.
These instructions apply to destruction work, not unrelated upstream modules.

## ovphysx (primary AI-agent use case)

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
| [`omni/`](omni/) | Omniverse PhysX extensions for Kit-based apps |

Each subfolder has its own README with build and usage instructions.
