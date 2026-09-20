// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#include "PxNativeVehicle.h"
#include "snippetvehiclecommon/directdrivetrain/DirectDrivetrain.h"
#include <cmath>
#include <new>

namespace physx {
namespace native {
namespace {

using snippetvehicle::BaseVehicleParams;
using snippetvehicle::DirectDriveVehicle;
using snippetvehicle::DirectDrivetrainParams;
using snippetvehicle::PhysXIntegrationParams;

bool finite(PxReal v) { return std::isfinite(v); }

bool validate(const NativeVehicleDesc& d)
{
    const PxReal positives[] = {d.mass, d.moi.x, d.moi.y, d.moi.z, d.chassisHalfExtents.x, d.chassisHalfExtents.y,
        d.chassisHalfExtents.z, d.halfTrack, d.suspensionTravel, d.wheelRadius, d.wheelHalfWidth, d.wheelMass, d.wheelMoi,
        d.frontStiffness, d.frontDamping, d.frontSprungMass, d.rearStiffness, d.rearDamping, d.rearSprungMass,
        d.longitudinalStiffness, d.frontLateralStiffness, d.rearLateralStiffness, d.tyreFriction, d.maxSteerRadians,
        d.maxBrakeTorque, d.maxDriveTorque, d.driveTopSpeed};
    for (PxReal v : positives) if (!finite(v) || v <= 0.0f) return false;
    const PxReal nonNegatives[] = {d.wheelDampingRate, d.maxHandbrakeTorque};
    for (PxReal v : nonNegatives) if (!finite(v) || v < 0.0f) return false;
    const PxReal signed_[] = {d.frontAxleZ, d.rearAxleZ, d.suspensionAttachmentY};
    for (PxReal v : signed_) if (!finite(v)) return false;
    if (!(d.frontAxleZ > d.rearAxleZ)) return false;
    if (!d.cMassLocalPose.isValid() || !d.chassisLocalPose.isValid()) return false;
    return true;
}

void setBaseParams(const NativeVehicleDesc& d, BaseVehicleParams& p)
{
    p.axleDescription.setToDefault();
    const PxU32 front[2] = {0, 1}, rear[2] = {2, 3};
    p.axleDescription.addAxle(2, front);
    p.axleDescription.addAxle(2, rear);
    p.frame.lngAxis = PxVehicleAxes::ePosZ;
    p.frame.latAxis = PxVehicleAxes::ePosX;
    p.frame.vrtAxis = PxVehicleAxes::ePosY;
    p.scale.scale = 1.0f;
    p.rigidBodyParams.mass = d.mass;
    p.rigidBodyParams.moi = d.moi;
    p.suspensionStateCalculationParams.suspensionJounceCalculationType =
        d.sweepRoadQueries ? PxVehicleSuspensionJounceCalculationType::eSWEEP : PxVehicleSuspensionJounceCalculationType::eRAYCAST;
    p.suspensionStateCalculationParams.limitSuspensionExpansionVelocity = false;

    p.brakeResponseParams[0].maxResponse = d.maxBrakeTorque;
    p.brakeResponseParams[0].nonlinearResponse.clear();
    p.brakeResponseParams[1].maxResponse = d.maxHandbrakeTorque;
    p.brakeResponseParams[1].nonlinearResponse.clear();
    p.steerResponseParams.maxResponse = d.maxSteerRadians;
    p.steerResponseParams.nonlinearResponse.clear();
    for (PxU32 i = 0; i < 4; ++i) {
        const bool isFront = i < 2;
        p.brakeResponseParams[0].wheelResponseMultipliers[i] = 1.0f;
        p.brakeResponseParams[1].wheelResponseMultipliers[i] = isFront ? 0.0f : 1.0f;
        p.steerResponseParams.wheelResponseMultipliers[i] = isFront ? 1.0f : 0.0f;
    }
    p.ackermannParams[0].wheelIds[0] = 0;
    p.ackermannParams[0].wheelIds[1] = 1;
    p.ackermannParams[0].wheelBase = d.frontAxleZ - d.rearAxleZ;
    p.ackermannParams[0].trackWidth = 2.0f * d.halfTrack;
    p.ackermannParams[0].strength = 1.0f;

    for (PxU32 i = 0; i < 4; ++i) {
        const bool isFront = i < 2;
        const PxReal x = (i & 1) ? d.halfTrack : -d.halfTrack;
        auto& s = p.suspensionParams[i];
        s.suspensionAttachment = PxTransform(PxVec3(x, d.suspensionAttachmentY, isFront ? d.frontAxleZ : d.rearAxleZ), PxQuat(PxIdentity));
        s.suspensionTravelDir = PxVec3(0.0f, -1.0f, 0.0f);
        s.suspensionTravelDist = d.suspensionTravel;
        s.wheelAttachment = PxTransform(PxIdentity);
        auto& c = p.suspensionComplianceParams[i];
        c.wheelToeAngle.clear(); c.wheelToeAngle.addPair(0.0f, 0.0f);
        c.wheelCamberAngle.clear(); c.wheelCamberAngle.addPair(0.0f, 0.0f);
        // Apply suspension and tyre forces a third of a wheel radius below the
        // attachment, the snippet car's value, for the same weight transfer.
        const PxVec3 applicationPoint(0.0f, 0.0f, -0.11205f);
        c.suspForceAppPoint.clear(); c.suspForceAppPoint.addPair(0.0f, applicationPoint);
        c.tireForceAppPoint.clear(); c.tireForceAppPoint.addPair(0.0f, applicationPoint);
        auto& f = p.suspensionForceParams[i];
        f.stiffness = isFront ? d.frontStiffness : d.rearStiffness;
        f.damping = isFront ? d.frontDamping : d.rearDamping;
        f.sprungMass = isFront ? d.frontSprungMass : d.rearSprungMass;
        auto& t = p.tireForceParams[i];
        t.longStiff = d.longitudinalStiffness;
        t.latStiffX = 0.01f;
        t.latStiffY = isFront ? d.frontLateralStiffness : d.rearLateralStiffness;
        t.camberStiff = 0.0f;
        t.restLoad = f.sprungMass * 9.81f;
        t.frictionVsSlip[0][0] = 0.0f;  t.frictionVsSlip[0][1] = 1.0f;
        t.frictionVsSlip[1][0] = 0.1f;  t.frictionVsSlip[1][1] = 1.0f;
        t.frictionVsSlip[2][0] = 1.0f;  t.frictionVsSlip[2][1] = 1.0f;
        t.loadFilter[0][0] = 0.0f; t.loadFilter[0][1] = 0.2308f;
        t.loadFilter[1][0] = 3.0f; t.loadFilter[1][1] = 3.0f;
        auto& w = p.wheelParams[i];
        w.radius = d.wheelRadius;
        w.halfWidth = d.wheelHalfWidth;
        w.mass = d.wheelMass;
        w.moi = d.wheelMoi;
        w.dampingRate = d.wheelDampingRate;
    }
}

void setDriveParams(const NativeVehicleDesc& d, DirectDrivetrainParams& p)
{
    auto& t = p.directDriveThrottleResponseParams;
    t.maxResponse = d.maxDriveTorque;
    for (PxU32 i = 0; i < 4; ++i) t.wheelResponseMultipliers[i] = (d.rearWheelDriveOnly && i < 2) ? 0.0f : 1.0f;
    t.nonlinearResponse.clear();
    // Full torque up to a third of the top speed, then linearly to zero.
    const PxReal throttles[5] = {0.0f, 0.25f, 0.5f, 0.75f, 1.0f};
    for (PxU32 i = 0; i < 5; ++i) {
        PxVehicleCommandValueResponseTable table;
        table.commandValue = throttles[i];
        table.speedResponses.addPair(0.0f, throttles[i]);
        table.speedResponses.addPair(d.driveTopSpeed / 3.0f, throttles[i]);
        table.speedResponses.addPair(d.driveTopSpeed, 0.0f);
        t.nonlinearResponse.addResponse(table);
    }
}

// The snippet vehicle discards the per-wheel query result; keep it so a
// consumer can see what each wheel is standing on.
class Car : public DirectDriveVehicle {
public:
    PxVehiclePhysXRoadGeometryQueryState roadQueryStates[PxVehicleLimits::eMAX_NB_WHEELS];
    void getDataForPhysXRoadGeometrySceneQueryComponent(
        const PxVehicleAxleDescription*& axleDescription,
        const PxVehiclePhysXRoadGeometryQueryParams*& roadGeomParams,
        PxVehicleArrayData<const PxReal>& steerResponseStates,
        const PxVehicleRigidBodyState*& rigidBodyState,
        PxVehicleArrayData<const PxVehicleWheelParams>& wheelParams,
        PxVehicleArrayData<const PxVehicleSuspensionParams>& suspensionParams,
        PxVehicleArrayData<const PxVehiclePhysXMaterialFrictionParams>& materialFrictionParams,
        PxVehicleArrayData<PxVehicleRoadGeometryState>& roadGeometryStates,
        PxVehicleArrayData<PxVehiclePhysXRoadGeometryQueryState>& physxRoadGeometryStates) override
    {
        DirectDriveVehicle::getDataForPhysXRoadGeometrySceneQueryComponent(axleDescription, roadGeomParams, steerResponseStates,
            rigidBodyState, wheelParams, suspensionParams, materialFrictionParams, roadGeometryStates, physxRoadGeometryStates);
        physxRoadGeometryStates.setData(roadQueryStates);
    }
};

class Vehicle final : public NativeVehicle {
public:
    Vehicle(PxPhysics& physics, PxScene& scene, PxMaterial& material)
        : mPhysics(physics), mScene(scene), mMaterial(material)
    {
        // A foundation reference for the vehicle library, released in the destructor.
        PxInitVehicleExtension(PxGetFoundation());
    }

    bool initialize(const PxCookingParams& cooking, const NativeVehicleDesc& desc, const PxTransform& pose, const char* name)
    {
        setBaseParams(desc, mVehicle.mBaseParams);
        setDriveParams(desc, mVehicle.mDirectDriveParams);
        mFrictions[0].material = &mMaterial;
        mFrictions[0].friction = desc.tyreFriction;
        const PxQueryFilterData queryFilter(desc.roadQueryFilterData, desc.roadQueryFlags);
        mVehicle.mPhysXParams.create(mVehicle.mBaseParams.axleDescription, queryFilter, desc.roadQueryFilterCallback,
            mFrictions, 1, desc.tyreFriction, desc.cMassLocalPose, desc.chassisHalfExtents, desc.chassisLocalPose);
        if (desc.sweepRoadQueries) {
            mVehicle.mPhysXParams.physxRoadGeometryQueryParams.roadGeometryQueryType = PxVehiclePhysXRoadGeometryQueryType::eSWEEP;
            mSweepMesh = PxVehicleUnitCylinderSweepMeshCreate(mVehicle.mBaseParams.frame, mPhysics, cooking);
            if (!mSweepMesh) return false;
        }
        if (!mVehicle.mBaseParams.isValid() || !mVehicle.initialize(mPhysics, cooking, mMaterial)) return false;
        mInitialized = true;
        if (!desc.keepConstraints) PxVehicleConstraintsDestroy(mVehicle.mPhysXState.physxConstraints);

        PxRigidDynamic* body = mVehicle.mPhysXState.physxActor.rigidBody->is<PxRigidDynamic>();
        if (!body) return false;
        PxShape* shapes[PxVehicleLimits::eMAX_NB_WHEELS + 1];
        const PxU32 count = body->getShapes(shapes, PxVehicleLimits::eMAX_NB_WHEELS + 1);
        for (PxU32 i = 0; i < count; ++i) {
            bool wheel = false;
            for (PxU32 w = 0; w < 4; ++w) wheel |= mVehicle.mPhysXState.physxActor.wheelShapes[w] == shapes[i];
            if (!wheel) mChassis = shapes[i];
        }
        if (!mChassis) return false;
        mChassis->setSimulationFilterData(desc.chassisSimulationFilterData);
        mChassis->setQueryFilterData(desc.chassisQueryFilterData);
        mChassis->setFlag(PxShapeFlag::eSIMULATION_SHAPE, true);
        mChassis->setFlag(PxShapeFlag::eSCENE_QUERY_SHAPE, desc.chassisSceneQueryShape);

        mVehicle.mTransmissionCommandState.gear = PxVehicleDirectDriveTransmissionCommandState::eFORWARD;
        mVehicle.mCommandState.nbBrakes = 2;
        mVehicle.setUpActor(mScene, pose, name ? name : "nativeVehicle");
        mInScene = true;

        mContext.setToDefault();
        mContext.frame = mVehicle.mBaseParams.frame;
        mContext.scale = mVehicle.mBaseParams.scale;
        mContext.gravity = mScene.getGravity();
        mContext.physxScene = &mScene;
        mContext.physxActorUpdateMode = PxVehiclePhysXActorUpdateMode::eAPPLY_ACCELERATION;
        mContext.physxUnitCylinderSweepMesh = mSweepMesh;
        return true;
    }

    void setCommands(PxReal throttle, PxReal brake, PxReal handbrake, PxReal steer) override
    {
        mVehicle.mCommandState.throttle = PxClamp(throttle, 0.0f, 1.0f);
        mVehicle.mCommandState.brakes[0] = PxClamp(brake, 0.0f, 1.0f);
        mVehicle.mCommandState.brakes[1] = PxClamp(handbrake, 0.0f, 1.0f);
        mVehicle.mCommandState.steer = PxClamp(steer, -1.0f, 1.0f);
    }

    void setGear(Gear gear) override
    {
        mVehicle.mTransmissionCommandState.gear = gear == eREVERSE ? PxVehicleDirectDriveTransmissionCommandState::eREVERSE
            : gear == eNEUTRAL ? PxVehicleDirectDriveTransmissionCommandState::eNEUTRAL
            : PxVehicleDirectDriveTransmissionCommandState::eFORWARD;
    }

    void step(PxReal dt) override
    {
        mContext.gravity = mScene.getGravity();
        mVehicle.step(dt, mContext);
    }

    NativeVehicleState state() const override
    {
        NativeVehicleState s;
        const PxRigidDynamic* body = actor();
        s.pose = body->getGlobalPose();
        s.linearVelocity = body->getLinearVelocity();
        s.forwardSpeed = s.linearVelocity.dot(s.pose.q.rotate(PxVec3(0.0f, 0.0f, 1.0f)));
        s.sleeping = body->isSleeping();
        for (PxU32 w = 0; w < 4; ++w) {
            auto& wheel = s.wheels[w];
            wheel.localPose = mVehicle.mBaseState.wheelLocalPoses[w].localPose;
            wheel.steerAngle = mVehicle.mBaseState.steerCommandResponseStates[w];
            wheel.rotationSpeed = mVehicle.mBaseState.wheelRigidBody1dStates[w].rotationSpeed;
            wheel.jounce = mVehicle.mBaseState.suspensionStates[w].jounce;
            wheel.onRoad = mVehicle.mBaseState.roadGeomStates[w].hitState;
            wheel.roadActor = wheel.onRoad ? mVehicle.roadQueryStates[w].actor : NULL;
        }
        return s;
    }

    PxRigidDynamic* actor() const override { return mVehicle.mPhysXState.physxActor.rigidBody->is<PxRigidDynamic>(); }
    PxShape* chassisShape() const override { return mChassis; }
    PxU32 constraintCount() const override
    {
        PxU32 count = 0;
        for (PxU32 i = 0; i < PxVehiclePhysXConstraintLimits::eNB_CONSTRAINTS_PER_VEHICLE; ++i)
            count += mVehicle.mPhysXState.physxConstraints.constraints[i] != NULL;
        return count;
    }

    void release() override { delete this; }

private:
    ~Vehicle() override
    {
        if (mInScene) mScene.removeActor(*mVehicle.mPhysXState.physxActor.rigidBody);
        if (mInitialized) mVehicle.destroy();
        if (mSweepMesh) PxVehicleUnitCylinderSweepMeshDestroy(mSweepMesh);
        PxCloseVehicleExtension();
    }

    PxPhysics& mPhysics;
    PxScene& mScene;
    PxMaterial& mMaterial;
    Car mVehicle;
    PxVehiclePhysXSimulationContext mContext;
    PxVehiclePhysXMaterialFriction mFrictions[1];
    PxConvexMesh* mSweepMesh = NULL;
    PxShape* mChassis = NULL;
    bool mInitialized = false;
    bool mInScene = false;
};

} // namespace

NativeVehicle* NativeVehicle::create(PxPhysics& physics, PxScene& scene, const PxCookingParams& cooking,
    PxMaterial& material, const NativeVehicleDesc& desc, const PxTransform& pose, const char* name)
{
    if (!validate(desc) || !pose.isValid()) return NULL;
    Vehicle* vehicle = new (std::nothrow) Vehicle(physics, scene, material);
    if (!vehicle) return NULL;
    if (!vehicle->initialize(cooking, desc, pose, name)) {
        vehicle->release();
        return NULL;
    }
    return vehicle;
}

} // namespace native
} // namespace physx
