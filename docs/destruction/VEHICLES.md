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

## The questions a game asks before shipping a car

All in `native_vehicle_wall_test`, all passing, each under a second:

| ctest | what it proves |
|---|---|
| `physx_native_vehicle_parked_sleeps` (`--park`) | A car parked where a round pushes a wall's bricks onto and against it goes to sleep with the rubble (car asleep at frame 51, every fragment by frame 149), and full throttle wakes it on the first frame. The vehicle SDK applies its forces with `autowake` off and wakes only on a throttle or steer intent, so a parked car cannot hold a contact island awake -- the reason `/city` lost its vehicle. |
| `physx_native_vehicle_rubble_crossing` (`--rubble`) | Sweep road queries with `eDYNAMIC` bodies as road: the car crosses a 6 m field of 160 loose half-bricks at ~5 m/s, rising 0.35 m over them, with bricks reported as the road actor under the wheels. Debris a car can climb is smaller than its wheel radius; a 0.38 m brick is a kerb, and the snippet car's 0.13 m bumper clearance bulldozes it, so the test raises the chassis 0.27 m. |
| `physx_native_vehicle_force_replay` (`--remote-fracture`) | A round fractures the wall while the car accelerates 40 m away. On every correction frame the car's speed gain equals its uncorrected neighbours' (worst 10.7 %, most exact), so the checkpoint replays the vehicle's `addForce` once, neither dropped nor doubled. |
| `physx_native_vehicle_scale` (`--scale`) | Beside a 600-brick wall the vehicle's own step -- the model plus four scene queries against GPU-resident bodies -- costs 10 µs per frame. |
| `physx_native_vehicle_wall_sweep` (`--sweep`) | The ram with cylinder sweeps instead of raycasts. |

## The demonstration video

`/root/recordings/vehicle-destruction-demo.mp4`: three clips from the same
executable. A 22-brick, 12-course wall of 0.35 m bricks; the car, its roof
trimmed to fit under the course boundary at 1.40 m, punches a car-sized hole
at 13.6 m/s -- 179 of 494 bonds, 55 bricks released, 209 standing, 40 of
them in the seven courses over the hole -- and keeps 8.2 m/s. First on the
chase camera, then from a fixed front view that shows the arch, then the
raised-clearance car crossing 160 loose half-bricks.

```
native_vehicle_wall_test --demo   --frames 480 --state demo-wall.twstate
native_vehicle_wall_test --rubble --frames 360 --state demo-rubble.twstate
blast-mini-city-recorder render --state demo-wall.twstate --output demo-wall.mp4 \
    --camera 3 --chase-part 1 --compact-hud --no-sleep-tint --ground-y 0 --title "..."
blast-mini-city-recorder render --state demo-wall.twstate --output demo-wall-front.mp4 \
    --camera 1 --focus-center 0 -5.5 -1 --focus-radius 5.5 --camera-margin 0 ...
ffmpeg -f concat -safe 0 -i list.txt -c copy vehicle-destruction-demo.mp4
```

Chunks are coloured by rigid body: the recording carries a per-frame group per
pose (TWSTATE1 format 3) numbered in order of first sight, so the intact wall
is one colour and every released body keeps its own hue for the rest of the
clip. That is how the video shows, at a glance, which bricks travel together.

`--chase-part N` replaces the fourth pane with a camera that follows the
centroid of the actors of part `N` (the chassis is part 1), trailing 9 m
behind and 3.2 m up along the subject's own motion, smoothed.

Why the hole is a hole. The trial solve meets an immovable wall, so the stress
solver is loaded with the full stopping impulse, an upper bound on what a
yielding wall would see. With brick-scale mortar (20 kPa tension) that load
decayed below the limits nowhere in a 7 m wall and 274 of 352 bonds went in
one step, every brick its own body -- the colouring showed it. With mortar at
150 kPa tension, 200 kPa shear and 600 kPa compression the shatter zone is the
car's own outline plus a brick, and the seven courses above carry their 2.5 m
span (about 30 kPa of bond tension) as an arch. `--wall-strength` scales the
limits: at 0.5 the wall comes down, at 2 the hole is too small and the car
stops in it.

Two vehicles, deliberately. The snippet car's 0.13 m bumper is a bulldozer
blade against loose bricks and is what carries it through a wall; a car with
0.40 m of clearance lets the bricks under, climbs its own debris and
high-centres in the hole it made. Clearance is what crosses a *scattered*
field. A brick house with a roof slab was tried first: head-on the car stopped
under the lintel because its roof was taller than the hole; at the corner the
joined walls stayed kinematic. The tall wall with the car sized to the course
boundary is what gives a hole and an arch.

## A stage fault found on the way, pinned

`physx_native_fragment_resting_on_static` (`--resting-course`, no car) is
registered `WILL_FAIL`. A wall whose first released course rests on the ground
plane is opened by a round; the two seven-brick halves of that course are
released, never touch the ground, and free-fall out of the world (y = -291 m
after eight seconds, zero angular velocity). Single bricks knocked away land
normally, and lifting the wall 5 cm so the course must *create* its ground
pair after release makes every fragment rest. The pair a chunk had with the
static ground while its owner was kinematic (which PhysX kills by default)
is not re-evaluated when ownership migrates to a dynamic fragment:
`PxgAABBManager::refilterBounds` in the device-owner path requests no
refilter and keeps the old group. The same run also leaves six top-course
bricks asleep 1.2 m below the ground. It reproduces without any vehicle and
without the vehicle's constraints, in under a second. The parked-car fixture
lifts its wall 5 cm until this is fixed.

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
