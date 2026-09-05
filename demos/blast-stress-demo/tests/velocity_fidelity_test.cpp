// Physical regression for the inherited PhysX 100 rad/s ceiling. The
// expectations come from angular impulse, inertia and centrifugal tension.
#include "../physx_scene.h"
#include <NvBlastExtStressPhysX.h>
#include <NvBlastExtStressPhysXGpuHostMirror.h>
#include <cmath>
#include <cstdio>
#include <memory>
#include <stdexcept>
#include <string>
#include <vector>

using namespace Nv::Blast;
using namespace physx;
using namespace blast_demo;
namespace {
constexpr float dt = 1.0f / 60.0f;
void require(bool ok, const char* message) { if (!ok) throw std::runtime_error(message); }
template<class T> struct Release { void operator()(T* p) const { if (p) p->release(); } };
using Destructible = std::unique_ptr<ExtStressPhysXDestructible, Release<ExtStressPhysXDestructible>>;
using Mirror = std::unique_ptr<ExtStressPhysXGpuHostMirror, Release<ExtStressPhysXGpuHostMirror>>;
std::vector<ExtStressPhysXBodySnapshot> bodies(ExtStressPhysXDestructible& d) {
    std::vector<ExtStressPhysXBodySnapshot> result(2);
    const auto count = d.getBodySnapshots(result.data(), result.size());
    require(count <= result.size(), "two-node fixture returned too many bodies");
    result.resize(count);
    return result;
}
void step(PhysXScene& context, ExtStressPhysXDestructible& d, Mirror& mirror) {
    context.scene().simulate(dt);
    require(context.scene().fetchResults(true), "fetchResults failed");
    if (mirror) {
        // Only the stable pointers are consumed before host publication.
        std::vector<PxRigidDynamic*> actors;
        for (const auto& b : bodies(d)) actors.push_back(b.body);
        require(mirror->synchronize(actors.data(), actors.size()), "GPU motion observation failed");
    }
}
Destructible makeRotor(PhysXScene& context, float tensileLimit) {
    ExtStressPhysXNodeDesc nodes[2];
    for (unsigned i = 0; i < 2; ++i) {
        nodes[i].centroid = PxVec3(i ? 0.55f : -0.55f, 0, 0);
        nodes[i].mass = 1.0f;
        nodes[i].volume = 1.0f;
        nodes[i].geometry.localPose = PxTransform(nodes[i].centroid);
        nodes[i].geometry.halfExtents = PxVec3(0.5f);
    }
    ExtStressPhysXBondDesc bond;
    bond.node0 = 0; bond.node1 = 1;
    bond.centroid = PxVec3(0); bond.normal = PxVec3(1, 0, 0); bond.area = 1.0f;
    ExtStressPhysXMaterial material;
    material.compressionElasticLimit = material.shearElasticLimit = 1.0e12f;
    material.compressionFatalLimit = material.shearFatalLimit = 2.0e12f;
    material.tensionElasticLimit = tensileLimit;
    material.tensionFatalLimit = tensileLimit * 2;
    ExtStressPhysXDesc desc;
    desc.physics = &context.physics(); desc.scene = &context.scene(); desc.material = &context.material();
    desc.nodes = nodes; desc.nodeCount = 2; desc.bonds = &bond; desc.bondCount = 1;
    desc.stressMaterials = &material; desc.stressMaterialCount = 1;
    // Keep the fast fragments far from the scene's ground plane, including
    // speculative CCD's swept bounds. This fixture measures force-free coast.
    desc.worldTransform = PxTransform(PxVec3(0, 200, 0));
    desc.settings.linearDamping = desc.settings.angularDamping = 0;
    desc.settings.applyExcessForces = false;
    desc.settings.minimumSeparationVelocity = 0;
    desc.settings.gpuStressSolver = context.gpuActive();
    desc.settings.gpuStressMinimumBondCount = 0;
    desc.settings.maxSolverIterationsPerFrame = 64;
    Destructible d(ExtStressPhysXDestructible::create(desc));
    require(bool(d), "rotor creation failed");
    return d;
}
void testRotor(PhysXScene& context, Mirror& mirror, float speed, float tensileLimit, bool shouldBreak) {
    auto d = makeRotor(context, tensileLimit);
    auto initial = bodies(*d);
    require(initial.size() == 1 && !initial[0].kinematic, "rotor must be a free rigid body");
    auto* parent = initial[0].body;
    const float inertia = parent->getMassSpaceInertiaTensor().z;
    parent->addTorque(PxVec3(0, 0, inertia * speed), PxForceMode::eIMPULSE);
    step(context, *d, mirror);
    const auto spun = bodies(*d);
    std::printf("spin=%.1f measured=%.6f inertia=%.6f\n", speed, spun[0].angularVelocity.z, inertia);
    require(std::abs(spun[0].angularVelocity.z - speed) < 0.02f, "angular impulse was clipped during integration");
    require(d->captureResimulationSnapshot() == 1, "rotor capture failed");
    const PxVec3 center = spun[0].globalPose.transform(spun[0].centerOfMassLocalPose.p);
    require(d->tick(dt, PxVec3(0)), "centrifugal stress tick failed");
    auto after = bodies(*d);
    float compression = 0, tension = 0, shear = 0;
    d->getBondStresses(&compression, &tension, &shear, 1);
    std::printf("centrifugal: speed=%.1f bodies=%zu compression=%.6g tension=%.6g shear=%.6g expected_tension=%.6g\n",
        speed, after.size(), compression, tension, shear, 0.55f * speed * speed);
    require(after.size() == (shouldBreak ? 2u : 1u), "centrifugal fracture verdict disagrees with tensile load");
    require(d->usesGpuStressSolver() == context.gpuActive(), "unexpected stress solver backend");
    if (!shouldBreak) {
        const float expectedTension = 0.55f * speed * speed; // m*omega^2*r/area
        require(std::abs(tension - expectedTension) < expectedTension * 1.0e-4f,
                "centrifugal tension disagrees with m*omega^2*r/area");
        require(compression < 0.001f && shear < 0.001f, "radial spin generated non-tensile stress");
    }
    require(d->restoreResimulationSnapshot(), "rotor replay restore failed");
    after = bodies(*d);
    PxVec3 linearMomentum(0), angularMomentum(0);
    for (const auto& b : after) {
        const PxTransform com = b.globalPose * b.centerOfMassLocalPose;
        const PxVec3 r = com.p - center;
        const PxVec3 momentum = b.linearVelocity * b.mass;
        const PxVec3 omegaLocal = com.q.rotateInv(b.angularVelocity);
        linearMomentum += momentum;
        angularMomentum += r.cross(momentum) + com.q.rotate(b.body->getMassSpaceInertiaTensor().multiply(omegaLocal));
        require(std::abs(b.angularVelocity.z - speed) < 0.02f, "fracture replay lost inherited spin");
    }
    require(linearMomentum.magnitude() < 0.01f, "fracture replay changed linear momentum");
    require((angularMomentum - PxVec3(0, 0, inertia * speed)).magnitude() < 0.1f, "fracture replay changed angular momentum");
    // A new child must not regain the default ceiling on its first GPU step.
    for (unsigned i = 0; i < 4; ++i) {
        step(context, *d, mirror);
        for (const auto& b : bodies(*d)) {
            require(b.globalPose.isFinite() && b.angularVelocity.isFinite(), "nonfinite spinning body state");
            if (std::abs(b.angularVelocity.z - speed) >= 0.05f)
                std::printf("coast failure: step=%u id=%llu spin=%.9g max_spin=%.9g linear=(%.9g,%.9g,%.9g)\n",
                    i, (unsigned long long)b.bodyId, b.angularVelocity.z, b.body->getMaxAngularVelocity(),
                    b.linearVelocity.x, b.linearVelocity.y, b.linearVelocity.z);
            require(std::abs(b.angularVelocity.z - speed) < 0.05f, "free rotor or fracture child lost angular momentum");
        }
    }
    std::printf("rotor passed: speed=%.1f bodies=%zu momentum_error=%.6g\n", speed, after.size(),
        (angularMomentum - PxVec3(0, 0, inertia * speed)).magnitude());
}
}
int main(int argc, char** argv) {
    try {
        const std::string mode = argc > 1 ? argv[1] : "cpu";
        require(mode == "cpu" || mode == "gpu" || mode == "direct", "unknown physics mode");
        const bool gpu = mode != "cpu", direct = mode == "direct";
        PhysXScene context(gpu ? PhysicsMode::Gpu : PhysicsMode::Cpu, gpu, SceneCapacity{}, nullptr,
                           direct, false, direct, direct);
        context.scene().setGravity(PxVec3(0));
        Mirror mirror(direct ? ExtStressPhysXGpuHostMirror::create(context.scene()) : nullptr);
        require(!direct || (mirror && mirror->available()), "Direct GPU host observation unavailable");
        testRotor(context, mirror, 50, 50000, false);
        testRotor(context, mirror, 500, 1.0e12f, false);
        testRotor(context, mirror, 500, 50000, true);
        testRotor(context, mirror, -500, 50000, true);
        require(context.healthy() && context.errors().warningCount() == 0, "PhysX reported an error or warning");
        std::printf("velocity fidelity passed (%s)\n", mode.c_str());
    } catch (const std::exception& error) {
        std::fprintf(stderr, "velocity fidelity failed: %s\n", error.what());
        return 1;
    }
}
