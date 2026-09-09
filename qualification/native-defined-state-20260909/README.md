# Defined GPU lifecycle state and valid topology commit ranges

This continues ranked replacement 1 by making the existing GPU lifecycle state
safe to consume independently of incidental CPU uploads. It does not finish GPU
simulation registration or remove the remaining CPU body/contact prerequisites.

## Production changes

| Responsibility | Change | Work/cost |
|---|---|---|
| GPU bounds bitmap | Allocate bitmap words, not one word per shape; initialize new storage at its reset boundary. | Correct allocation size; initialization only on growth. No per-step clearing pass added. |
| Acceleration history | Define newly allocated acceleration entries, including padding, before a quiet first step can checkpoint/observe them. Preserve existing history. | Zero only the new range on capacity growth; cost remains inside simulation if growth occurs there. |
| Accepted topology | Copy only valid roots and occupied motion slots inside the existing commit completion kernel, using device cluster counts. | Remove two full-capacity DtoD graph nodes. No CPU count readback, new allocation or extra kernel launch. |
| Sleep observation | Copy only the dynamic solver-body range consumed by the ordinary and Direct-GPU sleep tasks. | Delete undefined world/kinematic entries from the transfer; omit an empty transfer. Dynamic sleep behavior is unchanged. |

For the two removed topology copies, the old payload is 108 bytes per capacity
slot (root plus motion). The replacement writes 108 bytes per live cluster and
reads the corresponding root-to-slot mapping. This is logical payload accounting,
not measured DRAM traffic or a predicted time saving. Other topology arrays still
copy broadly; component-local topology and storage replacement remain unfinished.

The commit event still orders all accepted consumers after every copy thread.
Minimum-ID root order, slot generations, physical mass/motion, accepted-only
publication, correction limit and material/stress equations are unchanged. Public
ABI15 and runtime V8 are unchanged; the internal solver call signature was rebuilt
with the matching GPU module. CPU consumer code/static archive is unchanged.

## Diagnosis and regression evidence

The preceding native ordinary-mode fixture reported 43 unfiltered initcheck
errors. The allocation trace showed this sequence: initial host bitmap has no
words; dynamics allocates the first GPU word; a subsequent quiet step skips the
upload; native bounds merging reads the unwritten word. Correcting allocation
units alone did not fix first-use initialization. Initializing at growth removed
that kernel error.

The remaining errors came from acceleration storage before its first producer,
unused CUB root/motion capacity copied during commit, and world/kinematic sleep
records copied without a producer or consumer. Fixing the responsible ranges
removes them without clearing whole runtime arrays every step. Intermediate logs
are retained in [evidence](evidence/), including the unsuccessful units-only trace.
Temporary trace printing was removed from production.

- **52 selected tests pass:** existing native/observation/timing tests, two new
  unfiltered PGS/TGS initialization gates and the topology suite.
- The new TGS initialization gate fails against the immutable preceding V8 module
  pair (CTest exit 8), then passes the candidate. No kernel filter, API-memory
  suppression or relaxed assertion is used.
- The native fixture has 6 authored chunks, 3 bonds and an ordinary body. It
  covers quiet initialization, fracture, one correction/two stress evaluations,
  accepted settings/query ownership and the next ordinary tick. Direct GPU is
  disabled and sleeping enabled.
- CUDA memcheck of that native fixture passes.
- The topology test now observes only valid motion slots and checks nonzero
  accepted motion bit-for-bit against the candidate, including rejection, slot
  reuse and generation exhaustion. Its subsequent full unfiltered initcheck
  passes. This suite includes a 100,000-chunk/200,000-bond topology fixture; it is
  not a full rigid-body performance benchmark.
- Frozen penetration: 444 chunks, 896 bonds, one projectile, 600 steps, original
  Direct GPU on/sleep-off mode; unchanged clearance/topology gate passes with
  398 retained chunks, 46 detached and 199 broken bonds.
- Ordinary penetration: same asset/projectile, 128 steps, Direct GPU off and sleep
  on; the original ordinary-mode reference passes without tolerance changes.

These are scoped clean initialization results, not proof that every engine
workload is sanitizer-clean. Previously recorded conditional-CUB synchronization
and racecheck findings are not addressed or waived by this change.

## Matched complete-step performance

[Generated bombardment report](shots/report.md) · [Generated pristine-idle report](idle/report.md).

256 buildings, 113,664 chunks, 229,376 bonds; 256 simultaneous physical projectiles
or independent zero-shot intact idle. Two runs per arm/regime in ABBA order,
96 steps / 1.6 simulated seconds per run. Direct GPU off, sleeping on, fixed dt1/60,
maximum one correction and two stress evaluations. The complete timer includes
commands, physics, stress, topology, correction and accepted observations. First
steps and allocation spikes are retained; rendering/networking are excluded.

Fracture peaks: baseline 135.974/135.798 ms, candidate 130.360/131.562 ms. This short
screen observes a 3.2% reduction comparing each arm's worst fracture step. Complete
means are nearly unchanged, and the candidate all-step peak is 0.5% higher because
startup remains larger. No repeatability, 60/120 Hz or endurance claim follows
from this short screen. Both idle runs and every raw sample remain in the reports.

All four bombardment runs finish with 71,096 broken bonds, 15,738 reported fragment
bodies and 42 corrected steps. Counts alone do not establish trajectory parity;
the controlled physical and identity gates above are required evidence.

## Reproduction and remaining work

Final artifacts and captures: `out/native-defined-state-20260909`. Baseline:
`out/accepted-settings-final-20260909/candidate` at source commit `6d573e01`.
The screen receipt attests mapped GPU/runtime binaries and benchmark hashes.
Unchanged CPU archive/benchmark artifacts use hard links to that immutable
baseline; mutable SDK outputs are copied into the candidate archive.

Build with the existing SDK targets and `native_destruction_consumers` plus
`destruction_topology_test`. Native gates are the existing CTest selection
`physx_native|destruction_timing|native_prefix|destruction_gpu_topology`.
The same prefix penetration runner and ABBA runner are used; exact commands,
source hashes and results are archived in evidence.

Rebuildable GPU static link archives were copied to RAM with content-hash
verification to preserve storage for evidence. Their generated SDK paths are
symlinks, recorded in `evidence/ram-link-archives.json`. If RAM storage disappears,
remove only those broken generated symlinks and rebuild; no source or recorded
benchmark artifacts were deleted. No game edits, deployment or service changes.

Next remains ranked 1: GPU simulation registration, active scheduling and shape/
contact ownership must replace their CPU prerequisites. Ranked replacements 2–7
remain pending. Valid-range commit copying is a prerequisite cleanup, not a claim
that component-local topology or selective correction is complete.
