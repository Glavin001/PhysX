// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#ifndef PX_NATIVE_VEHICLE_H
#define PX_NATIVE_VEHICLE_H
// A PhysX Vehicle SDK car packaged for scenes that run the native destruction
// stage. Everything the vehicle needs -- a rigid body, suspension raycasts or
// sweeps against the scene, and the constraints that hold a stationary car --
// works on a GPU-dynamics scene with ordinary CPU actor access, which is the
// mode the stage requires. The chassis is a plain PxRigidDynamic, so its
// contact impulses load the stress solver like any other body's.
//
// The defaults are the two-tonne four-wheel car from the vehicle snippets
// (Base.json/DirectDrive.json), so a NativeVehicleDesc left untouched drives.
#include "PxPhysicsAPI.h"

namespace physx {
namespace native {

struct NativeVehicleDesc {
    // Rigid body. The centre of mass sits above and ahead of the actor origin,
    // which is at the rear axle, road level.
    PxReal mass = 2014.4f;
    PxVec3 moi = PxVec3(3200.0f, 3414.0f, 750.0f);
    PxTransform cMassLocalPose = PxTransform(PxVec3(0.0f, 0.55f, 1.594f), PxQuat(PxIdentity));
    // Chassis collision box, in actor space. Simulation on, scene queries off
    // by default so the wheel road queries never see the car itself.
    PxVec3 chassisHalfExtents = PxVec3(0.84097f, 0.65458f, 2.46971f);
    PxTransform chassisLocalPose = PxTransform(PxVec3(0.0f, 0.830066f, 1.37003f), PxQuat(PxIdentity));
    PxFilterData chassisSimulationFilterData;
    PxFilterData chassisQueryFilterData;
    bool chassisSceneQueryShape = false;

    // Wheel layout, in the centre-of-mass frame the vehicle SDK works in.
    PxReal frontAxleZ = 1.26922f;
    PxReal rearAxleZ = -1.594f;
    PxReal halfTrack = 0.795263f;
    PxReal suspensionAttachmentY = -0.107952f;
    PxReal suspensionTravel = 0.221111f;
    PxReal wheelRadius = 0.343252f;
    PxReal wheelHalfWidth = 0.157685f;
    PxReal wheelMass = 20.0f;
    PxReal wheelMoi = 1.17169f;
    PxReal wheelDampingRate = 0.25f;

    // Suspension springs, per axle (N/m, N s/m, kg).
    PxReal frontStiffness = 33245.3f, frontDamping = 8635.2f, frontSprungMass = 560.7f;
    PxReal rearStiffness = 26471.5f, rearDamping = 6875.7f, rearSprungMass = 446.5f;

    // Tyres.
    PxReal longitudinalStiffness = 24525.0f;
    PxReal frontLateralStiffness = 118699.6f;
    PxReal rearLateralStiffness = 143930.8f;
    PxReal tyreFriction = 1.0f;

    // Commands. Drive torque is per driven wheel; the response falls to zero at
    // driveTopSpeed (m/s) so the car has a terminal velocity.
    PxReal maxSteerRadians = 0.523599f;
    PxReal maxBrakeTorque = 1875.0f;
    PxReal maxHandbrakeTorque = 3000.0f;
    PxReal maxDriveTorque = 750.0f;
    PxReal driveTopSpeed = 60.0f;
    bool rearWheelDriveOnly = false;

    // Road geometry. Sweeps ride a cylinder over rubble and kerbs; raycasts are
    // the vehicle snippets' default. Query flags decide whether loose debris
    // counts as road (eDYNAMIC) or only the ground (eSTATIC).
    bool sweepRoadQueries = false;
    PxQueryFlags roadQueryFlags = PxQueryFlags(PxQueryFlag::eSTATIC);
    PxFilterData roadQueryFilterData;
    PxQueryFilterCallback* roadQueryFilterCallback = NULL;

    // The suspension-limit and sticky-tyre PxConstraints. The native stage
    // admits them on a body it does not own; drop them only to reproduce the
    // pre-narrowed-gate configuration.
    bool keepConstraints = true;
};

struct NativeVehicleWheelState {
    PxTransform localPose;      // in the actor frame, as the vehicle SDK places the wheel
    PxReal steerAngle;          // radians
    PxReal rotationSpeed;       // radians per second
    PxReal jounce;              // metres of compression from full droop
    bool onRoad;                // the road query found geometry under the wheel
    const PxRigidActor* roadActor;   // what it found, NULL when nothing
};

struct NativeVehicleState {
    PxTransform pose;           // actor pose
    PxVec3 linearVelocity;
    PxReal forwardSpeed;        // along the chassis +z
    bool sleeping;
    NativeVehicleWheelState wheels[4];
};

class NativeVehicle {
public:
    enum Gear { eREVERSE, eNEUTRAL, eFORWARD };

    // Creates the actor and adds it to the scene at pose. The cooking params
    // must have buildGPUData set on a GPU scene. Returns NULL on invalid input.
    static NativeVehicle* create(PxPhysics& physics, PxScene& scene, const PxCookingParams& cooking,
        PxMaterial& material, const NativeVehicleDesc& desc, const PxTransform& pose, const char* name = NULL);

    // Commands are in [0,1] except steer in [-1,1]; they persist until changed.
    virtual void setCommands(PxReal throttle, PxReal brake, PxReal handbrake, PxReal steer) = 0;
    virtual void setGear(Gear gear) = 0;
    // Runs the vehicle model for one substep group and writes forces to the
    // actor. Call before PxScene::simulate with the same dt.
    virtual void step(PxReal dt) = 0;

    virtual NativeVehicleState state() const = 0;
    virtual PxRigidDynamic* actor() const = 0;
    virtual PxShape* chassisShape() const = 0;
    virtual PxU32 constraintCount() const = 0;

    // Removes the actor from its scene and frees everything.
    virtual void release() = 0;

protected:
    virtual ~NativeVehicle() {}
};

} // namespace native
} // namespace physx
#endif
