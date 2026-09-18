# Native GPU rigid-state checkpoint

The native GPU simulation now captures its rigid-body state after body/command
upload and before the ordinary solver runs. This is the rigid-state portion of
the single-resimulation transaction. It is created automatically when native
chunk topology is configured, including when no fracture occurs, so the original
inputs are available if the later impulse-driven verdict requires correction.

The checkpoint does not rewind the scene automatically. Native ownership-changing
fractures still return an incomplete step. Restoring CPU/island state, contact
and constraint state, applying cluster/shape edits, running one correction solve
and publishing accepted output remain unfinished. A raw body-array restoration
alone is not a valid full-scene rewind.

## Captured state and ordering

`PxgSimulationController::postCopyToBodySim` captures the GPU body pool after
`updateBodies` and `updateArticulations` have submitted uploaded inputs, before
releasing the continuation that advances dynamics. The copies use PhysX's scene
CUDA stream. The internal checkpoint view has a ready event that orders reads
and restoration on other streams; normal capture does not synchronize with the
CPU or copy motion to it.

The saved arrays contain:

- Every slot in the current native body pool, including ordinary rigid bodies,
  projectiles, joint-connected bodies, kinematics, sleeping bodies and pool holes.
- The complete 240-byte `PxgBodySim`: transforms, mass/inertia, velocities,
  physical settings, sleep accumulators and unconsumed external accelerations.
- Previous velocities and observed accelerations when those optional buffers
  are enabled, another 64 bytes per slot.

An articulation's body-pool entries may be present, but this does not capture
its full reduced-coordinate state. D6-connected ordinary rigid bodies are
covered by the rigid arrays; the D6 constraint's own state still needs separate
correction accounting.

Storage grows geometrically and is reused across steps. The copied extent is
the actual body-pool count, never a per-chunk independent motion allocation.
Allocation/submission failure invalidates the checkpoint and makes the native
step incomplete. No required body records are truncated. This establishes the
full-body baseline before a later validated selective checkpoint optimization.

## Internal restoration primitive

`PxgDestructionRuntime::restoreRigidState` restores those arrays on a supplied
PhysX CUDA stream. It rejects stale generations, insufficient destination
capacity and missing optional arrays before writing any device state. Checkpoint
generations are not reused by clear/reconfiguration. Clear also retires the
checkpoint event's pending operation before freeing storage.

The eventual correction task must restore these original inputs and then apply
fractured body candidates. That ordering also covers new bodies allocated into
holes in the old body pool. Candidate state currently represents the provisional
trial motion; it must be reconciled with the checkpoint before the correction
solve. Repeating CPU commands after restoring their uploaded GPU accelerations
would double-apply them and is not permitted.

The primitive is private, and normal simulation does not call it yet. It does
not restore CPU body mirrors, island activation, solver caches, contact managers,
CCD histories, joint state or emitted notifications. No full resimulation or
unchanged-fidelity performance claim follows from these tests.

## Qualification coverage

`physx_native_gpu_rigid_checkpoint` uses ordinary native simulation to check:

- A projectile contacting the ground and another body connected through a locked
  D6 joint: both checkpoint velocities precede their actual trial response.
- Newly uploaded mass/pose, and a Direct GPU force captured before integration
  consumes it. The internal restore recovers the consumed acceleration too.
- TGS and PGS crossed with native sleeping and acceleration tracking on/off.
- Growth by 257 ordinary native bodies without losing any body slot.
- Clear/reconfiguration, stale-generation rejection and undersized/partial
  restore rejection without modifying the destination.
- Byte-for-byte restoration of actual GPU body, previous-velocity and observed
  acceleration arrays, ordered through a separate nonblocking CUDA stream.

The fixture does not advance physics after the raw restore, because the complete
scene correction transaction is not implemented yet.

```sh
python3 tools/scripts/build-destruction-sdk.py --jobs 4
ctest --test-dir out/destruction-sdk --output-on-failure
/usr/local/cuda/bin/compute-sanitizer --tool memcheck --error-exitcode 99 \
  out/destruction-sdk/reference/native_gpu_checkpoint_test
```

The independent SDK build, all eight checkpoint modes, three GPU memory checks
and four installed CPU/GPU consumers pass. The native suite passes 49/54 tests
with the same five known failures. Exact commands, source hashes and limits are
in [the qualification record](qualification/native-gpu-rigid-checkpoint-20260906.json).
