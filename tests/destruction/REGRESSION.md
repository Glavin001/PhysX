# Destruction regression contract

This suite protects accepted physical results while allowing changes to solver
algorithms, memory layout, scheduling and CPU/GPU ownership. A passing light or
native tier is not full candidate qualification. Performance acceptance remains
the complete real-time tick defined in [OPTIMIZATION.md](../../OPTIMIZATION.md).

## Required behavior

- Current-tick commands and contacts feed stress and material evaluation. A
  fracture permits at most one correction, followed by a second stress pass.
  No stale-contact solve, deferred convergence, lost impulse, duplicated damage
  or partial publication is acceptable.
- Ordinary APIs and sleeping remain enabled. Accepted shapes, connectivity,
  mass/COM/inertia, pose, linear/angular motion and material history must remain
  physically valid. Public handle lifetime safety remains mandatory.
- A solver must satisfy independently recomputed equations, including free-body
  nullspace treatment, and the actual material decisions at the required quality.
  A convergence flag or agreement with an old approximate solution alone is not
  sufficient. Equilibrium alone also does not determine carried self-stress.
- Exact-input settled reuse cannot skip accumulating subfatal material damage.
  Changed loads, topology, support, commands or required quality invalidate reuse
  as appropriate. Memory checks use normal asynchronous execution.

## Physical gates versus implementation diagnostics

The restored-state checker defaults to `canonical-connectivity-v1`. It compares
partitions by authored chunk membership, not internal root numbers. Generation,
array ordering and work/contact counters are reported as implementation
differences. `--strict-implementation` also requires those diagnostics to match.
Physical array schema, authored identity, material health/crush, active bonds,
loads, fracture/correction outcomes, mass properties and the established force
and motion bounds remain mandatory. This is not an approximate-damage policy.
An exported schema remains a contract even if the private memory layout changes.

Continuous wall checking now requires the existing quaternion and linear/angular
velocity columns as well as positions. Missing fields fail; a historical
position-only receipt cannot qualify as complete motion. Internal root labels and
implementation ownership switches can differ if physical results agree. API mode,
sleeping, stimuli, material and numerical settings remain fixed. The tolerances
are the existing wall 1 mm position/COM bound and snapshot 1e-4 m/s, 1e-4 rad/s,
1e-5 quaternion dot-error bounds. Quaternion signs are equivalent and small norm
drift is normalized; nonfinite, zero or malformed quaternions fail.

Hierarchy arithmetic-bit comparisons and the resimulation graph-build count are
diagnostics by default. Set `PHYSX_DESTRUCTION_STRICT_DIAGNOSTICS=1` for an exact
implementation investigation. Independent diagonal solves and both sparse-row
operators still have mandatory equation checks. Rejected-transaction atomicity,
public lifetime rules and exact-reuse invalidation tests remain strict.

The resident 3D oracle independently recomputes the gradient from published
forces. It enforces the existing tolerance plus a calculated FP32 export-rounding
envelope propagated through the absolute forward/transpose operators. It also
requires deliberately corrupted forces to fail. This is an output-rounding
bound, not a fitted performance/precision tradeoff. Existing six-channel force
agreement remains required to detect errors invisible to equilibrium alone.

## New native behavioral fixtures

`native_physics_contract_test` runs ten cases / 336 accepted checked ticks:
free and supported equal-mass three-chunk structures, reordered nodes/bonds, rotated and
translated worlds, a half timestep and a below-elastic load. The free cases check
gravity integration, exactly-once COM impulse, torque-free spin, orientation and
zero internal stress from common rigid motion. Supported cases check axial loads
against supported mass × gravity and accumulated section loss against an
independent scalar material equation, including unchanged external stimulus.
These are small independent oracles; the full52 corpus supplies scale breadth.
Existing impact/correction, native material/crush, wake, compound sleep, hierarchy
and large topology tests are retained rather than replaced by these fixtures.

There is an explicit additional `model-accuracy` tier for unequal-mass axial
equilibrium. The frozen solver fails it: mass equalization substitutes a
geometric-mean mass, giving 27.74687 N instead of 29.43 N for 3 kg above the
support. This is a known model-accuracy limitation, not a passing regression or
an approved tolerance. The ordinary regression tiers protect the existing model;
they do not resolve or certify this broader accuracy requirement. Run this tier
when changing mass normalization, and retain its failure until the model is fixed.

## Commands

Use fresh output paths. The builder and native checks use the shared benchmark
exclusion lock. Build outside GPU captures; never evict another job to run tests.

```bash
# CPU checker, negative-control and measurement-integrity tests; no GPU access.
python3 tools/scripts/run-destruction-regression.py out/NEW-regression-cpu --tier cpu

# Isolated consumers using an existing frozen solver. This does not install or
# rebuild the SDK. Substitute the candidate's frozen solver-build directory.
python3 tools/scripts/build-destruction-regression.py out/NEW-regression-build \
  --solver-build out/n24-component-multilevel-20260912/build/A

python3 tools/scripts/run-destruction-regression.py out/NEW-regression-native \
  --tier native --artifacts out/NEW-regression-build
python3 tools/scripts/run-destruction-regression.py out/NEW-regression-memory \
  --tier sanitizer --artifacts out/NEW-regression-build

# Explicit physical-model audit; currently expected to FAIL, with a failed receipt.
python3 tools/scripts/run-destruction-regression.py out/NEW-model-accuracy \
  --tier model-accuracy --artifacts out/NEW-regression-build
```

Final qualification additionally requires exact candidate/control snapshot
binaries, an attested 52-case input manifest, a compatible candidate demo and an
audited ordinary/sleeping wall reference. These are explicit because a test
binary cannot attest a different application/library composition.

```bash
python3 tools/scripts/run-destruction-regression.py out/NEW-regression-final \
  --tier final --artifacts /absolute/candidate-regression-build \
  --candidate-commit CANDIDATE_COMMIT \
  --snapshot-manifest /absolute/full52/manifest.json \
  --snapshot-binary /absolute/candidate/serialization-probe \
  --control-snapshot-binary /absolute/control/serialization-probe \
  --control-artifacts /absolute/control/runtime-libraries \
  --demo /absolute/candidate/native_destruction_demo \
  --wall-reference /absolute/audited-ordinary-wall
```

Final runs CPU checks, native checks, new-fixture memcheck/initcheck/synccheck,
matched full52 ×20 A/B/A ticks, full52 ×2 asynchronous memory ticks, and the
600-tick ordinary/sleeping wall. Existing scenario collectors own their per-run
locks; contention fails rather than running competing GPU work. The suite does
not promote candidates or interpret failing deadlines as equivalent physics.
Use additional model-specific trajectory/quality cases when an algorithm changes
material precision or affects a behavior not covered by the wall.

`results.json` records exact commands, per-stage status, source/artifact hashes
and diagnostic wall duration. Build receipts attest the actual linked objects,
headers and runtime modules. Failed stages remain failed; an incomplete tier is
not a pass. `PYTHONOPTIMIZE` and `CUDA_LAUNCH_BLOCKING` are cleared by the runner
so assertions and asynchronous checks cannot silently disappear.

For CMake users, the new native oracle is registered as
`physx_native_physics_contract`. Destruction CTests are serialized and labeled;
the serial runner additionally coordinates with other benchmark processes.
The historical [coverage audit](../../reports/destruction-test-coverage-audit/README.md)
remains unchanged. It describes the pre-suite state, not these new results.
