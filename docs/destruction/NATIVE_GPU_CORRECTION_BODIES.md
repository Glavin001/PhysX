# Native GPU correction body inputs

After the actual GPU material verdict, topology preparation, native allocation
and collision-binding preparation, the native task now builds body inputs for
the single resimulation. The candidate geometry and mass describe the chosen
fracture topology; the motion comes from the pre-solve GPU checkpoint. These
records include retained owners as well as newly allocated fragments and exclude
unchanged structures. No motion, inertia or chunk graph is read back to the CPU.

A private installation primitive writes those records to PhysX's actual GPU body
pool after its rigid-state restore. It is tested directly but is not invoked by
normal scene advancement yet. Collision ownership, CPU/island state, supported
constraint state, source command assignment and the single internal replay are
still required before a native split can commit. Normal ownership-changing
steps continue to return incomplete error 8.

## Frames and motion

The input body's world COM frame and local COM frame recover the immutable asset
orientation. A local COM difference determines the new world COM, avoiding the
subtraction of large world-space actor origins. The candidate principal inertia
and local mass frame were already validated by body preparation; the correction
stage reuses them without repeating inertia diagonalization.

Linear velocity is re-expressed at the new COM actually representable by the
float solver:

```
v_new = v_saved + omega_saved × (COM_new_stored - COM_saved)
```

Angular velocity comes from the checkpoint. The same transformation reconciles
optional previous-velocity history, preserving input velocity changes that
arrived before the trial. The actual trial response cannot leak into these
correction inputs. Material laws, solver settings and timestep are unchanged.

The GPU compacts the affected candidate bodies in stable chunk-root order. A
128-byte record holds the candidate body state and its target native body index.
The 32-byte preparation status contains topology and checkpoint generations,
record count, count of affected sources with pending external acceleration,
validity and error bits. Buffers reserve capacity for all configured chunks;
scene-wide growth remains separate work. There is no truncation.

`PxDestructionScene` version 9 exposes diagnostic `correctionBodies` and
`correctionPreparation` device views through the existing ready event. Invalid
batches add stage error 2048; detail bits identify checkpoint source (1), native
mapping (2), invalid/unrepresentable motion or history (4), nonfinite input load
(8), and submission/completion failure (16). A partial diagnostic buffer is not
usable when `valid` is zero.

## Installation and commands

`PxgDestructionRuntime::installCorrectionBodies` is private. It requires the
matching rigid checkpoint to have been restored, sufficient body-pool capacity,
a valid current correction batch and matching optional history buffers. Invalid
requests make no body writes. The kernel reads immutable checkpoint sources,
so updating a retained parent cannot race with its other children reading that
parent. Ordinary bodies and unchanged structures remain as restored.

The shared native body construction preserves physical settings and writes the
new mass, inertia, COM and motion for both retained and new target slots. Geometry
membership, accepted damage/topology, public actors and query membership remain
uncommitted. Island activation and retirement still belong to the missing
complete correction transaction.

A source body's net force/torque command does not identify which persistent
chunk should own its application after splitting. The checkpoint preserves those
inputs, and preparation reports each affected loaded source once. Installation
currently rejects a batch with such unresolved commands before any body write;
it does not drop them or copy the full force onto every child. Explicit chunk
load ownership and correct post-split command application remain completion
gates. Commands on ordinary/unaffected bodies stay in their restored GPU slots
and do not cause this rejection. Body force assignment is not implemented by
this milestone.

## Qualification scope

`physx_native_gpu_correction_bodies` runs an actual native centrifugal fracture
with persistent box shapes, unequal chunk masses, rotated anisotropic inertia
and an offset COM. It verifies:

- Fracture inputs use the original pose/velocity, not the integrated trial state.
- Stored-COM point velocity and linear/angular momentum within existing native
  tolerances; no assertions or tolerances are weakened.
- Retained and newly allocated GPU slots receive their changed physical state.
- Previous velocities reconcile to the new COM, while ordinary bodies and a
  quiet structure remain unchanged by installation.
- TGS/PGS crossed with native sleeping and acceleration tracking on/off.
- Stale generations, missing restore and insufficient capacity reject installation.
- An unresolved affected body command rejects before mutation; an ordinary-body
  force remains intact through rigid restore and candidate installation.
- A nonfinite checkpoint rejects correction preparation without modifying the
  actual native body pool or accepted material/topology.

The fixture does not advance after private body installation. The complete
scene mutation/resimulation transaction is still absent. These checks do not
establish native destruction acceptance or full-scene 60 Hz performance.

```sh
python3 tools/scripts/build-destruction-sdk.py --jobs 4
ctest --test-dir out/destruction-sdk --output-on-failure
/usr/local/cuda/bin/compute-sanitizer --tool memcheck --error-exitcode 99 \
  out/destruction-sdk/reference/native_gpu_correction_body_test
```

The independent SDK build, all ten correction fixture cases, three GPU memory
checks and four installed CPU/GPU consumers pass. The native suite passes 50/55
tests with the same five known failures. Exact commands, hashes and limitations
are in [the qualification record](qualification/native-gpu-correction-bodies-20260906.json).
