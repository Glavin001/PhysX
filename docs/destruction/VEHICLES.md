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

## Constraints and the correction gate

`PxVehicleConstraintsCreate` gives the car one `PxConstraint` per four wheels
(suspension limits and sticky tyres), attached to the chassis and the world.
The native correction pass used to refuse any scene holding a `PxConstraint`
(`canCorrect` required `!mConstraints.size()`), so the first version of this
test destroyed them after creation. The gate is now narrowed: a constraint on
a body the stage does not own is prepared on the CPU from the restored
start-of-step pose (`restoreDestructionActivity` puts `body2World` back to
`mLastTransform`) and its unchanged constant block, so the corrected solve
rebuilds it exactly, and such constraints no longer block correction. A
constraint touching a cluster parent or fragment still does, because that body's
mass and shapes change under it. GPU island repair admits only world-attached
constraints: a constraint joining two bodies is an island edge the contact
components would not see.

`physx_native_vehicle_wall` keeps the constraints and fractures;
`physx_native_vehicle_wall_no_constraints` is the old configuration;
`physx_native_vehicle_wall_constraint_gate` joints the wall itself to the world
and asserts the refusal.

## Why a step was refused: `correctionBlockers`

`PxDestructionStageStatus::correctionBlockers` reports, every step, the
`PxDestructionCorrectionBlocker` bits that would stop a correction: CCD, Direct
GPU sleeping, articulations, a constraint on a stage-owned body, a filter
callback, deformables, particles, speculative-CCD bodies, Direct GPU kinematic
targets. It is set on steps that needed no correction too, so a consumer can
check its scene before the first fracture instead of reading error bit 8 after
it. The gate test asserts the mask is exactly
`eCONSTRAINT_ON_DESTRUCTION_BODY` from the first configured step.

## The packaged vehicle: `PxNativeVehicle.h`

`destruction/vehicle/` builds `libPhysXNativeVehicle_static_64.a`, installed
with the SDK and exported as `PhysXDestruction::NativeVehicle`. It wraps the
snippet direct-drive car so a consumer needs neither the snippet tree nor
rapidjson:

```cpp
physx::native::NativeVehicleDesc desc;      // the two-tonne snippet car
desc.sweepRoadQueries = true;               // ride a cylinder over rubble
desc.roadQueryFlags = PxQueryFlags(PxQueryFlag::eSTATIC | PxQueryFlag::eDYNAMIC);
auto* car = physx::native::NativeVehicle::create(physics, scene, cooking, material, desc, pose);
car->setCommands(throttle, brake, handbrake, steer);
car->step(dt);            // before PxScene::simulate(dt)
auto state = car->state();  // pose, forward speed, per-wheel pose/steer/spin/jounce/road actor
car->release();
```

Chassis collision is on and scene queries off by default so the wheel queries
never see the car itself. `tests/destruction/package-consumer/vehicle_consumer.cpp`
builds against the installed package and drives on a native GPU scene.

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
out/destruction-sdk/reference/native_vehicle_wall_test --sweep     # cylinder sweeps instead of raycasts
```

Sources: `demos/blast-stress-demo/tests/native_vehicle_wall_test.cpp` (the
test, on the packaged helper), `destruction/vehicle/PxNativeVehicle.{h,cpp}`
(the helper, which compiles
`physx/snippets/snippetvehiclecommon/{base,directdrivetrain,physxintegration}`
and links `PhysXVehicle_static_64`).
