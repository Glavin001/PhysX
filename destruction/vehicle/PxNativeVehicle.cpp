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

template<typename T>
void setDriveParams(const T& d, DirectDrivetrainParams& p)
{
    auto& t = p.directDriveThrottleResponseParams;
    t.maxResponse = d.maxDriveTorque;
    for (PxU32 i = 0; i < 4; ++i) t.wheelResponseMultipliers[i] = ((d.rearWheelDriveOnly && i < 2) || (d.frontWheelDriveOnly && i >= 2)) ? 0.0f : 1.0f;
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

// One native constraint identity per wheel lets destruction attribute solved
// suspension-limit/sticky loads without dividing an aggregate by guesswork.
// Keep the SDK shader and its padded constant layout: only slot zero is active.
// eOUTPUT_FORCE requests writeback; it does not change the constraint law.
PxU32 wheelConstraintSolverPrep(Px1DConstraint* rows, PxVec3p& offset, PxU32 capacity,
    PxConstraintInvMassScale& scale, const void* block, const PxTransform& a,
    const PxTransform& b, bool extended, PxVec3p& ca, PxVec3p& cb)
{
    const PxU32 count = vehicleConstraintSolverPrep(rows, offset, capacity, scale, block, a, b, extended, ca, cb);
    for (PxU32 i=0; i<count; ++i) rows[i].flags |= Px1DConstraintFlag::eOUTPUT_FORCE;
    return count;
}
class WheelConstraintConnector final : public PxVehicleConstraintConnector {
    PxVehiclePhysXConstraintState* mSource;
    PxVehiclePhysXConstraintState mBlock[PxVehiclePhysXConstraintLimits::eNB_WHEELS_PER_PXCONSTRAINT];
public:
    explicit WheelConstraintConnector(PxVehiclePhysXConstraintState* source) : mSource(source) {
        for (auto& state : mBlock) state.setToDefault();
    }
    void* prepareData() override { mBlock[0] = *mSource; return mBlock; }
    const void* getConstantBlock() const override { return mBlock; }
    PxConstraintSolverPrep getPrep() const override { return wheelConstraintSolverPrep; }
};

bool createWheelConstraints(PxPhysics& physics, PxRigidBody& actor, PxVehiclePhysXConstraints& constraints)
{
    static_assert(PxVehiclePhysXConstraintLimits::eNB_CONSTRAINTS_PER_VEHICLE >= 4,
        "Native four-wheel wrapper needs four constraint slots");
    PxVehicleConstraintsDestroy(constraints);
    const PxConstraintShaderTable shaders = {wheelConstraintSolverPrep, visualiseVehicleConstraint, PxConstraintFlag::Enum(0)};
    for (PxU32 w=0; w<4; ++w) {
        void* memory = PX_ALLOC(sizeof(WheelConstraintConnector), "NativeVehicleWheelConstraint");
        if (!memory) return false;
        auto* connector = PX_PLACEMENT_NEW(memory, WheelConstraintConnector)(&constraints.constraintStates[w]);
        constraints.constraintConnectors[w] = connector;
        constraints.constraints[w] = physics.createConstraint(&actor, nullptr, *connector, shaders,
            sizeof(PxVehiclePhysXConstraintState)*PxVehiclePhysXConstraintLimits::eNB_WHEELS_PER_PXCONSTRAINT);
        if (!constraints.constraints[w]) return false;
    }
    return true;
}

// The snippet vehicle discards the per-wheel query result; keep it so a
// consumer can see what each wheel is standing on.
class Car : public DirectDriveVehicle {
public:
    NativeVehicleStepLoads loads;
    // Vehicle geometry uses the chassis axes at the current COM. The principal
    // inertia axes may rotate after fracture and must not rotate the drivetrain.
    PxQuat massFrameRotation{PxIdentity};
    PxTransform suspensionActorAttachments[4];
    void captureAttachments(const PxTransform& massPose) {
        for (PxU32 w=0; w<4; ++w) {
            auto& suspension = mBaseParams.suspensionParams[w];
            suspensionActorAttachments[w] = massPose * suspension.suspensionAttachment;
            suspension.suspensionTravelDir = massPose.q.rotate(suspension.suspensionTravelDir);
        }
    }
    void refreshMassProperties() {
        const auto& actor = *mPhysXState.physxActor.rigidBody;
        const PxTransform massPose = actor.getCMassLocalPose();
        massFrameRotation = massPose.q;
        mBaseParams.rigidBodyParams.mass = actor.getMass();
        mBaseParams.rigidBodyParams.moi = actor.getMassSpaceInertiaTensor();
        for (PxU32 w=0; w<4; ++w) {
            auto& attachment = mBaseParams.suspensionParams[w].suspensionAttachment;
            attachment = suspensionActorAttachments[w];
            attachment.p -= massPose.p;
        }
    }
    class ActorBegin : public PxVehicleComponent {
        Car& car;
    public:
        explicit ActorBegin(Car& vehicle) : car(vehicle) {}
        bool update(PxReal dt, const PxVehicleSimulationContext& context) override {
            if (!car.PxVehiclePhysXActorBeginComponent::update(dt, context)) return false;
            car.mBaseState.rigidBodyState.pose.q = car.mPhysXState.physxActor.rigidBody->getGlobalPose().q;
            return true;
        }
    } actorBegin{*this};
    class ActorEnd : public PxVehicleComponent {
        Car& car;
    public:
        explicit ActorEnd(Car& vehicle) : car(vehicle) {}
        bool update(PxReal dt, const PxVehicleSimulationContext& context) override {
            PxTransform saved[4];
            const PxTransform toPrincipal(PxVec3(0), car.massFrameRotation.getConjugate());
            for (PxU32 w=0; w<4; ++w) {
                auto& pose = car.mBaseState.wheelLocalPoses[w].localPose;
                saved[w] = pose;
                pose = toPrincipal * pose;
            }
            const bool result = car.PxVehiclePhysXActorEndComponent::update(dt, context);
            for (PxU32 w=0; w<4; ++w) car.mBaseState.wheelLocalPoses[w].localPose = saved[w];
            return result;
        }
    } actorEnd{*this};
    // Decorate the existing SDK component. Its force law, call order and
    // substep count remain unchanged; no copy of the drivetrain is maintained.
    class LoadObserver : public PxVehicleComponent {
        Car& car;
    public:
        explicit LoadObserver(Car& vehicle) : car(vehicle) {}
        bool update(PxReal dt, const PxVehicleSimulationContext& context) override {
            const auto& state = car.mBaseState;
            const auto& params = car.mBaseParams.rigidBodyParams;
            const PxVec3 offset = state.rigidBodyState.pose.p - car.loads.centerOfMassPose.p;
            const PxMat33 rotation(state.rigidBodyState.pose.q * car.massFrameRotation);
            const PxMat33 inverseInertia = rotation * PxMat33::createDiagonal(
                PxVec3(1/params.moi.x, 1/params.moi.y, 1/params.moi.z)) * rotation.getTranspose();
            for (PxU32 w=0; w<4; ++w) {
                const auto& suspension = state.suspensionForces[w];
                const auto& tire = state.tireForces[w];
                const PxVec3 force = tire.forces[0] + tire.forces[1];
                const PxVec3 torque = tire.torques[0] + tire.torques[1];
                auto& output = car.loads.wheels[w];
                output.suspensionImpulse += suspension.force * dt;
                output.tireImpulse += force * dt;
                output.suspensionAngularImpulse += (suspension.torque + offset.cross(suspension.force)) * dt;
                output.tireAngularImpulse += (torque + offset.cross(force)) * dt;
                output.angularVelocityChange += inverseInertia * ((suspension.torque + torque) * dt);
            }
            car.loads.gravityImpulse += context.gravity * (params.mass * dt);
            car.loads.externalImpulse += state.rigidBodyState.externalForce * dt;
            car.loads.externalAngularImpulse += (state.rigidBodyState.externalTorque
                + offset.cross(state.rigidBodyState.externalForce)) * dt;
            car.loads.duration += dt;
            ++car.loads.substeps;
            auto& pose = car.mBaseState.rigidBodyState.pose;
            pose.q = pose.q * car.massFrameRotation;
            const bool result = car.PxVehicleRigidBodyComponent::update(dt, context);
            pose.q = pose.q * car.massFrameRotation.getConjugate();
            return result;
        }
    } loadObserver{*this};
    void initComponentSequence(bool beginEnd) override {
        DirectDriveVehicle::initComponentSequence(beginEnd);
#if defined(PX_VEHICLE_COMPONENT_REPLACEMENT_VERSION)
        const bool replaced = mComponentSequence.replace(static_cast<PxVehicleRigidBodyComponent*>(this), &loadObserver);
        PX_ASSERT(replaced);PX_UNUSED(replaced);
        if (beginEnd) {
            const bool beginReplaced = mComponentSequence.replace(static_cast<PxVehiclePhysXActorBeginComponent*>(this), &actorBegin);
            const bool endReplaced = mComponentSequence.replace(static_cast<PxVehiclePhysXActorEndComponent*>(this), &actorEnd);
            PX_ASSERT(beginReplaced && endReplaced);PX_UNUSED(beginReplaced);PX_UNUSED(endReplaced);
        }
#endif
    }

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
        mTuning.frontStiffness = desc.frontStiffness;
        mTuning.rearStiffness = desc.rearStiffness;
        mTuning.frontDamping = desc.frontDamping;
        mTuning.rearDamping = desc.rearDamping;
        mTuning.tyreFriction = desc.tyreFriction;
        mTuning.maxSteerRadians = desc.maxSteerRadians;
        mTuning.maxDriveTorque = desc.maxDriveTorque;
        mTuning.maxBrakeTorque = desc.maxBrakeTorque;
        mTuning.maxHandbrakeTorque = desc.maxHandbrakeTorque;
        mTuning.driveTopSpeed = desc.driveTopSpeed;
        if (desc.frontWheelDriveOnly && desc.rearWheelDriveOnly) return false;
        mTuning.frontWheelDriveOnly = desc.frontWheelDriveOnly;
        mTuning.rearWheelDriveOnly = desc.rearWheelDriveOnly;
        mTargetTuning = mTuning;
        mFrontDrive = desc.rearWheelDriveOnly ? 0.0f : 1.0f;
        mRearDrive = desc.frontWheelDriveOnly ? 0.0f : 1.0f;
        setBaseParams(desc, mVehicle.mBaseParams);
        mVehicle.captureAttachments(desc.cMassLocalPose);
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
        if (desc.keepConstraints && !createWheelConstraints(mPhysics, *body, mVehicle.mPhysXState.physxConstraints)) return false;
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

    bool setTuning(const NativeVehicleTuning& tuning) override
    {
        if (!PxIsFinite(tuning.frontStiffness) || tuning.frontStiffness <= 0.0f) return false;
        if (!PxIsFinite(tuning.rearStiffness) || tuning.rearStiffness <= 0.0f) return false;
        if (!PxIsFinite(tuning.frontDamping) || tuning.frontDamping <= 0.0f) return false;
        if (!PxIsFinite(tuning.rearDamping) || tuning.rearDamping <= 0.0f) return false;
        if (!PxIsFinite(tuning.tyreFriction) || tuning.tyreFriction <= 0.0f) return false;
        if (!PxIsFinite(tuning.maxSteerRadians) || tuning.maxSteerRadians <= 0.0f) return false;
        if (!PxIsFinite(tuning.maxDriveTorque) || tuning.maxDriveTorque <= 0.0f) return false;
        if (!PxIsFinite(tuning.maxBrakeTorque) || tuning.maxBrakeTorque <= 0.0f) return false;
        if (!PxIsFinite(tuning.maxHandbrakeTorque) || tuning.maxHandbrakeTorque <= 0.0f) return false;
        if (!PxIsFinite(tuning.driveTopSpeed) || tuning.driveTopSpeed <= 0.0f) return false;
        if (tuning.maxSteerRadians > PxHalfPi) return false;
        if (tuning.frontWheelDriveOnly && tuning.rearWheelDriveOnly) return false;
        mTargetTuning = tuning;
        mTuningRemaining = 0.2f;
        actor()->wakeUp();
        return true;
    }

    bool setFunctionalState(PxU32 wheelMask, bool drivelineConnected) override
    {
        if (wheelMask & ~15u) return false;
        mWheelMask = wheelMask;
        mDrivelineConnected = drivelineConnected;
        auto& axles = mVehicle.mBaseParams.axleDescription;
        axles.setToDefault();
        for (PxU32 axle=0; axle<2; ++axle) {
            PxU32 ids[2], count=0;
            for (PxU32 w=2*axle; w<2*axle+2; ++w)
                if (wheelMask & (1u<<w)) ids[count++]=w;
            if (count) axles.addAxle(count, ids);
        }
        for (PxU32 w=0; w<4; ++w) if (!(wheelMask & (1u<<w))) {
            auto& state=mVehicle.mBaseState;
            state.wheelRigidBody1dStates[w].setToDefault();
            state.roadGeomStates[w].setToDefault();
            state.suspensionStates[w].setToDefault();
            state.suspensionForces[w].setToDefault();
            state.tireForces[w].setToDefault();
            state.tireStickyStates[w].setToDefault();
            mVehicle.mPhysXState.physxConstraints.constraintStates[w].setToDefault();
        }
        PxVehicleConstraintsDirtyStateUpdate(mVehicle.mPhysXState.physxConstraints);
        actor()->wakeUp();
        return true;
    }

    bool setDriveConnectionMask(PxU32 wheelMask) override
    {
        if (wheelMask & ~15u) return false;
        mDriveConnectionMask = wheelMask;
        actor()->wakeUp();
        return true;
    }

    void advanceTuning(PxReal dt)
    {
        if (mTuningRemaining <= 0.0f || dt <= 0.0f) return;
        const PxReal alpha = PxMin(1.0f, dt / mTuningRemaining);
        mTuning.frontStiffness += (mTargetTuning.frontStiffness - mTuning.frontStiffness) * alpha;
        mTuning.rearStiffness += (mTargetTuning.rearStiffness - mTuning.rearStiffness) * alpha;
        mTuning.frontDamping += (mTargetTuning.frontDamping - mTuning.frontDamping) * alpha;
        mTuning.rearDamping += (mTargetTuning.rearDamping - mTuning.rearDamping) * alpha;
        mTuning.tyreFriction += (mTargetTuning.tyreFriction - mTuning.tyreFriction) * alpha;
        mTuning.maxSteerRadians += (mTargetTuning.maxSteerRadians - mTuning.maxSteerRadians) * alpha;
        mTuning.maxDriveTorque += (mTargetTuning.maxDriveTorque - mTuning.maxDriveTorque) * alpha;
        mTuning.maxBrakeTorque += (mTargetTuning.maxBrakeTorque - mTuning.maxBrakeTorque) * alpha;
        mTuning.maxHandbrakeTorque += (mTargetTuning.maxHandbrakeTorque - mTuning.maxHandbrakeTorque) * alpha;
        mTuning.driveTopSpeed += (mTargetTuning.driveTopSpeed - mTuning.driveTopSpeed) * alpha;
        mFrontDrive += ((mTargetTuning.rearWheelDriveOnly ? 0.0f : 1.0f) - mFrontDrive) * alpha;
        mRearDrive += ((mTargetTuning.frontWheelDriveOnly ? 0.0f : 1.0f) - mRearDrive) * alpha;
        mTuningRemaining = PxMax(0.0f, mTuningRemaining - dt);
        auto& base = mVehicle.mBaseParams;
        base.brakeResponseParams[0].maxResponse = mTuning.maxBrakeTorque;
        base.brakeResponseParams[1].maxResponse = mTuning.maxHandbrakeTorque;
        base.steerResponseParams.maxResponse = mTuning.maxSteerRadians;
        mFrictions[0].friction = mTuning.tyreFriction;
        for (PxU32 i = 0; i < 4; ++i) {
            base.suspensionForceParams[i].stiffness = i < 2 ? mTuning.frontStiffness : mTuning.rearStiffness;
            base.suspensionForceParams[i].damping = i < 2 ? mTuning.frontDamping : mTuning.rearDamping;
            mVehicle.mPhysXParams.physxMaterialFrictionParams[i].defaultFriction = mTuning.tyreFriction;
        }
        setDriveParams(mTuning, mVehicle.mDirectDriveParams);
        auto& throttle = mVehicle.mDirectDriveParams.directDriveThrottleResponseParams;
        throttle.wheelResponseMultipliers[0] = throttle.wheelResponseMultipliers[1] = mFrontDrive;
        throttle.wheelResponseMultipliers[2] = throttle.wheelResponseMultipliers[3] = mRearDrive;
    }

    void step(PxReal dt) override
    {
        mVehicle.refreshMassProperties();
        advanceTuning(dt);
        auto& throttle = mVehicle.mDirectDriveParams.directDriveThrottleResponseParams;
        for (PxU32 w=0; w<4; ++w)
            throttle.wheelResponseMultipliers[w] = mDrivelineConnected && (mWheelMask & mDriveConnectionMask & (1u<<w))
                ? (w<2 ? mFrontDrive : mRearDrive) : 0.0f;
        mContext.gravity = mScene.getGravity();
        mVehicle.loads = NativeVehicleStepLoads{};
#if defined(PX_VEHICLE_COMPONENT_REPLACEMENT_VERSION)
        mVehicle.loads.available = true;
#endif
        mVehicle.loads.centerOfMassPose = actor()->getGlobalPose() * actor()->getCMassLocalPose();
        mVehicle.step(dt, mContext);
        if (dt > 0 && !actor()->isSleeping()) {
            const auto& state = mVehicle.mBaseState.rigidBodyState;
            mVehicle.loads.actorLinearAcceleration = (state.linearVelocity - state.previousLinearVelocity) / dt;
            mVehicle.loads.actorAngularAcceleration = (state.angularVelocity - state.previousAngularVelocity) / dt;
        }
    }

    NativeVehicleStepLoads stepLoads() const override { return mVehicle.loads; }

    NativeVehicleState state() const override
    {
        NativeVehicleState s;
        const PxRigidDynamic* body = actor();
        s.pose = body->getGlobalPose();
        s.driveConnectionMask = mDrivelineConnected ? mDriveConnectionMask & mWheelMask : 0;
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

    PxConstraint* wheelConstraint(PxU32 wheel) const override {
        return wheel < 4 ? mVehicle.mPhysXState.physxConstraints.constraints[wheel] : nullptr;
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
    NativeVehicleTuning mTuning, mTargetTuning;
    PxReal mTuningRemaining = 0.0f;
    PxReal mFrontDrive = 1.0f;
    PxReal mRearDrive = 1.0f;
    PxU32 mWheelMask = 15;
    PxU32 mDriveConnectionMask = 15;
    bool mDrivelineConnected = true;
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
