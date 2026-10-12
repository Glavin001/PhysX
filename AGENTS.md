# AGENTS.md — NVIDIA PhysX Repository

## Integrated GPU destruction work

For native destruction implementation, optimization or performance testing, read
[the repository performance skill](.agents/skills/physx-destruction-performance/SKILL.md).
Its [playbook](docs/destruction/PERFORMANCE_PLAYBOOK.md) contains runnable commands;
[findings](docs/destruction/PERFORMANCE_FINDINGS.md) and the
[dated handoff](docs/destruction/PERFORMANCE_HANDOFF.md) distinguish evidence,
rejected experiments and unfinished architecture. Verify dated status against
current source and artifacts.

For recording the current native GPU destruction demo video, read
[the video skill](.agents/skills/physx-destruction-video/SKILL.md). A 60 fps clip
is not a performance qualification; do not use the old
`record-destruction-demo.py` path unless explicitly asked.

Current focus is RTX 4090/sm_89, fixed 1/60 timestep, max one correction, and
maximum actual destruction within every-step 8 ms (16.67 ms reported separately).
Preserve physical work and the GPU-resident destination. Source sibling checkouts
`vibe-land-4` and `blast-stress-solver-2` stay read-only. Report complete-step peaks
with workload/chunk/bond counts; do not substitute a narrow timer or average.
Every performance comparison must measure both a fresh intact idle scene (no
projectiles/destruction) and peak complete-step cost during recorded destruction.
Keep initialization/first-step spikes visible; zero awake debris after damage is
not an intact-idle measurement. Missing either regime means incomplete qualification.
Run isolated GPU jobs sequentially without stopping other developers' services.
These instructions apply to destruction work, not unrelated upstream modules.

Test destruction solvers per `destruction/stress-oracle/TESTING.md`: physical invariant
checks every frame, a failing test before every fix, and seconds-long reproductions
(fixtures, micro cases) rather than long runs. Oracle quality profiles are proposed in
`destruction/stress-oracle/ORACLE_QUALITY.md`; the layer-contact GPU port in
`destruction/stress-oracle/crates/stress-gpu/LAYER_CONTACT_PORT.md`.

Physical accuracy is not traded for convenience. Never use arbitrary caps, clamps,
thresholds or tuned constants to make a result look right or pass a gate (for
example capping a contact impulse). Every bound or correction must follow from the
physics (stress-owned contact where the rigid-body assumption fails, derived
stability bounds, certificates) and be measured against the stress-ref oracle
(`destruction/stress-oracle`). Intentional approximations for speed are allowed only
when named, switchable and their accuracy cost is measured by the oracle.

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
