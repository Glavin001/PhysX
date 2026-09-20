# Vehicles on the native destruction stage

A PhysX Vehicle SDK car drives on a GPU-dynamics scene with the native
destruction stage configured, rams a bonded brick wall, breaks it and drives
through. `native_vehicle_wall_test` proves it; three ctest cases pin it.

## Why it works

The vehicle SDK is CPU code: it raycasts the scene for road geometry and writes
accelerations to an ordinary `PxRigidDynamic`. Both need ordinary CPU actor
access, which the scene keeps because the native stage itself requires the
Direct GPU API off (`NpScene::getDestructionScene` returns NULL for CCD scenes;
`canCorrect` in `ScPipeline.cpp` refuses Direct GPU sleeping). The chassis is
then just another rigid body; its solved contact impulses load the stress
solver like any projectile's, and the corrected solve re-runs the step against
the fragments it released.

## Evidence

Fracture case: a 2,014 kg direct-drive car (the `Base.json`/`DirectDrive.json`
snippet parameters, transcribed) reaches 10.8 m/s over 14 m, hits a 15 x 6
brick wall (0.4 m pitch, brick density, 159 bonds, bottom course an authored
support below grade) and breaks 139 bonds in one corrected step, releasing all
75 bricks above the support course. Momentum on the impact frame: 21.8 kN s in,
11.3 kN s left in the car and 10.7 kN s in the bricks. The car exits at 5.6 m/s
and keeps accelerating. Asserted: no step error, every wheel raycast finds the
road, `>3 m/s` by frame 60, no bond breaks before contact, momentum
conservation `>80%` on the correction frame, and the chassis clears the wall's
footprint.

Control case (`--no-fracture`): the same wall with `1e12 Pa` limits stops the
car dead at the wall face with zero bonds broken and no step error, so the
breakthrough is stress, not tunnelling through the kinematic parent.

## The known limitation, pinned

`PxVehicleConstraintsCreate` gives the car one `PxConstraint` per four wheels
(suspension limits and sticky tyres). The native correction pass refuses any
scene holding a `PxConstraint` (`canCorrect` requires `!mConstraints.size()`),
so a scene with those constraints drives normally and then fails its first
fracture step: `fetchResults` incomplete, status error bit 8 (correction
required). `physx_native_vehicle_wall_constraint_gate` runs with
`--keep-constraints` and asserts exactly that refusal, so it flips visibly when
the checkpoint learns to roll back constraint state.

The workaround the other two cases use is to destroy the constraints right
after creation; every vehicle component tolerates a NULL constraint table. The
cost is the low-speed sticky-tyre hold and the hard suspension-limit clamp,
neither of which the test needs.

## Two things that looked like bugs and were not

- The vehicle SDK's rigid-body pose is the centre-of-mass frame
  (`actor pose * cMassLocalPose`, 0.55 m above the snippet's actor origin), and
  suspension attachments are relative to it. The actor origin therefore rests a
  few centimetres above the road, not the 0.5 m the snippet starts at.
- An above-ground support course stopped the car while every brick above it was
  already loose: the fragments left the impact frame with one tick of gravity
  and no momentum from the car. Support chunks are unbreakable by construction,
  so the drivable part of a wall has to start above them.

## Reproduce

```
cmake -S destruction -B out/destruction-sdk
cmake --build out/destruction-sdk --target native_vehicle_wall_test -j8
ctest --test-dir out/destruction-sdk -R physx_native_vehicle_wall --output-on-failure
out/destruction-sdk/reference/native_vehicle_wall_test --verbose   # per-frame z, speed, bonds
```

Sources: `demos/blast-stress-demo/tests/native_vehicle_wall_test.cpp`, which
compiles `physx/snippets/snippetvehiclecommon/{base,directdrivetrain,physxintegration}`
directly and links `PhysXVehicle_static_64`.
