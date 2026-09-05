// Exercises native PxScene simulation only. CUDA driver copies below are test
// observations; the application links neither Blast nor the CUDA runtime.
#include "../physx_scene.h"
#include <PxDestructionScene.h>
#include <PxContact.h>
#include <cuda.h>
#include <cmath>
#include <cstdio>
#include <stdexcept>
#include <vector>
using namespace physx;
namespace {
void require(bool ok,const char* message) { if(!ok)throw std::runtime_error(message); }
void check(CUresult r) { require(r==CUDA_SUCCESS,"CUDA driver operation failed"); }
template<class T> void read(T* dst,const T* src,size_t count) {
    if(count)check(cuMemcpyDtoH(dst,reinterpret_cast<CUdeviceptr>(src),sizeof(T)*count));
}
void step(PxScene& scene) {
    scene.simulate(1.0f/60.0f);PxU32 error=~0u;
    require(scene.fetchResults(true,&error) && !error,"native simulation step incomplete");
}
float relative(PxVec3 a,PxVec3 b) { return (a-b).magnitude()/PxMax(1.0f,b.magnitude()); }
void accumulate(PxDestructionSurfaceLoad& out,PxVec3 force,PxVec3 r) {
    out.force+=force;out.torque+=r.cross(force);
    out.virial[0]+=r.x*force.x;out.virial[1]+=r.y*force.y;out.virial[2]+=r.z*force.z;
    out.virial[3]+=0.5f*(r.x*force.y+r.y*force.x);
    out.virial[4]+=0.5f*(r.x*force.z+r.z*force.x);
    out.virial[5]+=0.5f*(r.y*force.z+r.z*force.y);
}
void exercise(bool materials=false,bool bonded=true) {
    blast_demo::SceneCapacity capacity;capacity.maxBodies=64;capacity.maxShapes=64;capacity.maxContactPairs=4096;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,true,false,true,true);
    auto& scene=context.scene();auto& cuda=*context.cudaContextManager();
    scene.setGravity(PxVec3(0));
    auto* stage=scene.getDestructionScene();require(stage,"native destruction stage unavailable");
    // Rotation and offset make accidental world/local frame mixing observable.
    const PxTransform pose(PxVec3(1,5,2),PxQuat(0.35f,PxVec3(0,0,1)));
    auto* cluster=context.physics().createRigidDynamic(pose);
    auto* shape=context.physics().createShape(PxBoxGeometry(0.5f,0.5f,0.5f),context.material(),true);
    require(cluster && shape && cluster->attachShape(*shape),"cluster setup failed");
    cluster->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);scene.addActor(*cluster);shape->release();
    auto* projectile=context.physics().createRigidDynamic(pose*PxTransform(PxVec3(-2,0.2f,0)));
    auto* shotShape=context.physics().createShape(PxSphereGeometry(0.2f),context.material(),true);
    require(projectile && shotShape && projectile->attachShape(*shotShape),"projectile setup failed");
    shotShape->release();projectile->setMass(2);projectile->setMassSpaceInertiaTensor(PxVec3(0.032f));
    projectile->setLinearDamping(0);projectile->setAngularDamping(0);
    projectile->setLinearVelocity(pose.q.rotate(PxVec3(12,1,2)));scene.addActor(*projectile);
    step(scene); // initializes body and persistent shape contact indices
    PxDestructionStressChunk chunks[2]={{PxVec3(0,-1,0),0,0,0,PX_INVALID_U32},
        {PxVec3(0),2,1,0,scene.getDirectGPUAPI().getShapeContactIndex(*shape)}};
    require(chunks[1].contactIndex!=PX_INVALID_U32,"missing persistent contact identity");
    PxDestructionStressBond bond{0,1,PxVec3(0,-0.5f,0),PxVec3(0,1,0),1,1,1};
    PxDestructionStressCluster motion{cluster->getGPUIndex(),PxVec3(0)};
    PxDestructionStressDesc desc;desc.chunks=chunks;desc.chunkCount=2;desc.bonds=&bond;desc.bondCount=1;
    desc.clusters=&motion;desc.clusterCount=1;desc.maxIterations=64;desc.tolerance=1e-5f;
    PxDestructionMaterial material;
    if(materials) {
        material.compressionElasticLimit=1e15f;material.compressionFatalLimit=2e15f;
        material.crush.capPressure=1e15f;material.crush.cohesion=1e15f;
        desc.materials=&material;desc.materialCount=1;chunks[0].volume=chunks[1].volume=1;
    }
    if(!bonded){desc.bonds=nullptr;desc.bondCount=0;}
    require(stage->configureStress(desc),"native graph configuration failed");
    auto invalid=desc;invalid.tolerance=0;require(!stage->configureStress(invalid),"invalid graph accepted");
    CUdeviceptr pairsDevice,countDevice,velocityDevice,indexDevice;
    CUstream observer;CUevent consumed;
    { PxScopedCudaLock lock(cuda);
        check(cuMemAlloc(&pairsDevice,4096*sizeof(PxGpuContactPair)));check(cuMemAlloc(&countDevice,sizeof(PxU32)));
        check(cuMemAlloc(&velocityDevice,sizeof(PxTransform)));check(cuMemAlloc(&indexDevice,sizeof(PxU32)));
        const auto index=projectile->getGPUIndex();check(cuMemcpyHtoD(indexDevice,&index,sizeof(index)));
        check(cuStreamCreate(&observer,CU_STREAM_NON_BLOCKING));check(cuEventCreate(&consumed,CU_EVENT_DISABLE_TIMING));
    }
    auto velocity=[&]() {
        require(scene.getDirectGPUAPI().getRigidDynamicData(reinterpret_cast<void*>(velocityDevice),
            reinterpret_cast<const PxU32*>(indexDevice),PxRigidDynamicGPUAPIReadType::eLINEAR_VELOCITY,1),"velocity observation failed");
        PxVec3 v;PxScopedCudaLock lock(cuda);read(&v,reinterpret_cast<const PxVec3*>(velocityDevice),1);return v;
    };
    auto observe=[&](void* out,size_t bytes,PxRigidDynamicGPUAPIReadType::Enum type) {
        require(scene.getDirectGPUAPI().getRigidDynamicData(reinterpret_cast<void*>(velocityDevice),
            reinterpret_cast<const PxU32*>(indexDevice),type,1),"body state observation failed");
        PxScopedCudaLock lock(cuda);check(cuMemcpyDtoH(out,velocityDevice,bytes));
    };
    bool normal=false,friction=false;float worstMomentum=0,worstWrench=0,peakRate=0;unsigned stressFrames=0;
    for(unsigned tick=0;tick<32;++tick) {
        const PxVec3 before=velocity();step(scene);const PxVec3 after=velocity();
        PxVec3 spin;PxTransform shotPose;
        observe(&spin,sizeof(spin),PxRigidDynamicGPUAPIReadType::eANGULAR_VELOCITY);
        observe(&shotPose,sizeof(shotPose),PxRigidDynamicGPUAPIReadType::eGLOBAL_POSE);
        const auto view=stage->getDeviceView();PxDestructionVectorPair inputs[2],forces;
        PxDestructionSurfaceLoad surface[2];PxDestructionStageStatus status;float rates[2]={};
        { PxScopedCudaLock lock(cuda);
            check(cuStreamWaitEvent(observer,view.readyEvent,0));
            check(cuMemcpyDtoHAsync(inputs,reinterpret_cast<CUdeviceptr>(view.nodeAccelerations),sizeof(inputs),observer));
            check(cuMemcpyDtoHAsync(surface,reinterpret_cast<CUdeviceptr>(view.surfaceLoads),sizeof(surface),observer));
            if(bonded)check(cuMemcpyDtoHAsync(&forces,reinterpret_cast<CUdeviceptr>(view.bondForces),sizeof(forces),observer));
            else require(!view.bondForces && !view.bondCount,"bondless graph allocated a stiffness solve");
            if(materials)check(cuMemcpyDtoHAsync(rates,reinterpret_cast<CUdeviceptr>(view.strainRates),sizeof(rates),observer));
            check(cuMemcpyDtoHAsync(&status,reinterpret_cast<CUdeviceptr>(view.status),sizeof(status),observer));
            check(cuEventRecord(consumed,observer));check(cuEventSynchronize(consumed));
        }
        stage->setConsumerEvent(consumed);
        require(status.frame==tick+1 && !status.error && status.converged,"native stage completion invalid");
        require(stage->getLastStatus().frame==status.frame,"CPU completion observation stale");
        require(inputs[1].angular.isZero(),"native stage changed reference angular load semantics");
        require(relative(inputs[1].linear,surface[1].force/2)<2e-4f,"native force conversion changed");
        if(bonded)require(relative(forces.linear,surface[1].force)<2e-4f || relative(-forces.linear,surface[1].force)<2e-4f,
            "single supported bond does not balance applied load");
        const PxVec3 expectedImpulse=-(after-before)*2;
        const PxVec3 actualImpulse=pose.q.rotate(surface[1].force)/60;
        worstMomentum=PxMax(worstMomentum,(actualImpulse-expectedImpulse).magnitude());
        require((actualImpulse-expectedImpulse).magnitude()<0.025f,"native loads disagree with projectile momentum");
        normal|=status.normalContacts>0;friction|=status.frictionAnchors>0;
        stressFrames+=forces.linear.magnitude()>0.01f;
        // Independently decode the actual solved stream on the CPU for torque,
        // virial, friction and chunk identity assertions. No stress callback.
        require(scene.getDirectGPUAPI().copyContactData(reinterpret_cast<void*>(pairsDevice),
            reinterpret_cast<PxU32*>(countDevice),4096),"contact observation failed");
        PxDestructionSurfaceLoad expected{};float expectedRate=0;
        auto sampleRate=[&](PxVec3 point,PxVec3 impulse) {
            if(impulse.isZero())return;
            const PxVec3 pointVelocity=after+spin.cross(point-shotPose.p); // COM is at actor origin
            const float closing=pointVelocity.dot(impulse/impulse.magnitude());
            expectedRate=PxMax(expectedRate,closing); // cube-root volume is 1
        };
        { PxScopedCudaLock lock(cuda);PxU32 count;read(&count,reinterpret_cast<PxU32*>(countDevice),1);
            require(count<=4096,"test observation overflow");std::vector<PxGpuContactPair> pairs(count);
            read(pairs.data(),reinterpret_cast<PxGpuContactPair*>(pairsDevice),count);
            for(auto p:pairs) {
                if(p.actor0!=cluster && p.actor1!=cluster)continue;
                const float sign=p.actor0==cluster?1.0f:-1.0f;
                std::vector<PxContactPatch> patches(p.nbPatches);read(patches.data(),reinterpret_cast<PxContactPatch*>(p.contactPatches),p.nbPatches);
                std::vector<PxContact> points(p.nbContacts);read(points.data(),reinterpret_cast<PxContact*>(p.contactPoints),p.nbContacts);
                std::vector<float> impulses(p.nbContacts);read(impulses.data(),p.contactForces,p.nbContacts);
                PxContactStreamIterator it(reinterpret_cast<PxU8*>(patches.data()),reinterpret_cast<PxU8*>(points.data()),NULL,p.nbPatches,p.nbContacts);
                unsigned j=0;
                while(it.hasNextPatch()){it.nextPatch();while(it.hasNextContact()){it.nextContact();
                    const PxVec3 impulse=it.getContactNormal()*impulses[j++]*sign;
                    sampleRate(it.getContactPoint(),impulse);
                    accumulate(expected,pose.q.rotateInv(impulse)*60,pose.transformInv(it.getContactPoint()));}}
                if(p.frictionPatches) {
                    std::vector<PxFrictionPatch> anchors(p.nbPatches);read(anchors.data(),reinterpret_cast<PxFrictionPatch*>(p.frictionPatches),p.nbPatches);
                    PxFrictionAnchorStreamIterator fit(reinterpret_cast<PxU8*>(patches.data()),reinterpret_cast<PxU8*>(anchors.data()),p.nbPatches);
                    while(fit.hasNextPatch()){fit.nextPatch();while(fit.hasNextFrictionAnchor()){fit.nextFrictionAnchor();
                        sampleRate(fit.getPosition(),fit.getImpulse()*sign);
                        accumulate(expected,pose.q.rotateInv(fit.getImpulse())*sign*60,pose.transformInv(fit.getPosition()));}}
                }
            }
        }
        if(relative(surface[1].force,expected.force)>=2e-4f || relative(surface[1].torque,expected.torque)>=2e-4f)
            std::fprintf(stderr,"tick %u normal %u friction %u force GPU(%g,%g,%g) CPU(%g,%g,%g) torque GPU(%g,%g,%g) CPU(%g,%g,%g)\n",
                tick,status.normalContacts,status.frictionAnchors,surface[1].force.x,surface[1].force.y,surface[1].force.z,
                expected.force.x,expected.force.y,expected.force.z,surface[1].torque.x,surface[1].torque.y,surface[1].torque.z,
                expected.torque.x,expected.torque.y,expected.torque.z);
        if(materials) {
            if(std::abs(rates[1]-expectedRate)>=2e-4f*PxMax(1.0f,expectedRate))
                std::fprintf(stderr,"strain rate GPU=%g CPU=%g at tick %u\n",rates[1],expectedRate,tick);
            require(std::abs(rates[1]-expectedRate)<2e-4f*PxMax(1.0f,expectedRate),"post-solve contact strain-rate parity");
            require(rates[0]==0,"uncontacted support received strain rate");peakRate=PxMax(peakRate,rates[1]);
            if(!bonded) {
                PxDestructionCrushState crush[2];PxScopedCudaLock lock(cuda);read(crush,view.chunkCrush,2);
                const float pressure=-(expected.virial[0]+expected.virial[1]+expected.virial[2])/3;
                require(std::abs(crush[1].pressure-pressure)<2e-4f*PxMax(1.0f,std::abs(pressure)),"bondless contact crush pressure");
                require(!crush[1].damage && !status.bondCommands && !status.iterations,"bondless material stage ran fictitious bond work");
            }
        }
        worstWrench=PxMax(worstWrench,relative(surface[1].torque,expected.torque));
        require(relative(surface[1].force,expected.force)<2e-4f && relative(surface[1].torque,expected.torque)<2e-4f,
            "native contact wrench differs from solved stream");
        for(unsigned k=0;k<6;++k)require(std::abs(surface[1].virial[k]-expected.virial[k])/PxMax(1.0f,std::abs(expected.virial[k]))<2e-4f,
            "native contact virial differs from solved stream");
    }
    require(normal && friction && (!bonded || stressFrames),"impact did not exercise normal/friction stress");
    require(!materials || peakRate>0,"contact material fixture never exercised nonzero strain rate");
    scene.removeActor(*projectile);projectile->release();
    scene.setGravity(PxVec3(0,-9.81f,0));step(scene);
    const auto gravityStatus=stage->getLastStatus();
    std::printf("gravity stage frame=%llu iters=%u converged=%u contacts=%u\n",
        (unsigned long long)gravityStatus.frame,gravityStatus.iterations,gravityStatus.converged,gravityStatus.normalContacts);
    {PxScopedCudaLock lock(cuda);PxDestructionVectorPair forces,inputs[2];PxDestructionSurfaceLoad surface[2];
        const auto view=stage->getDeviceView();check(cuEventSynchronize(view.readyEvent));
        if(bonded)read(&forces,view.bondForces,1);read(inputs,view.nodeAccelerations,2);read(surface,view.surfaceLoads,2);
        if(materials && !bonded) {
            PxDestructionCrushState crush[2];read(crush,view.chunkCrush,2);
            require(!crush[1].damage && !crush[1].pressure && !crush[1].deviator,"gravity alone artificially crushed an unbonded chunk");
        }
        require(relative(inputs[1].linear,pose.q.rotateInv(scene.getGravity()))<2e-4f,"gravity frame conversion incorrect");
        std::printf("gravity force=(%g,%g,%g) magnitude=%g accel=(%g,%g,%g)\n",forces.linear.x,forces.linear.y,forces.linear.z,
            forces.linear.magnitude(),inputs[1].linear.x,inputs[1].linear.y,inputs[1].linear.z);
        if(bonded)require(std::abs(forces.linear.magnitude()-19.62f)<0.001f,"supported gravity load incorrect");
        require(surface[1].force.isZero() && surface[1].torque.isZero(),"empty frame retained stale contacts");
    }
    require(stage->clearStress(),"clear failed");require(stage->getDeviceView().chunkCount==0,"clear retained graph");
    step(scene);require(stage->configureStress(desc),"reconfiguration failed");step(scene);
    require(stage->getLastStatus().frame==1,"reconfiguration retained frame state");require(stage->clearStress(),"final clear failed");
    {PxScopedCudaLock lock(cuda);check(cuMemFree(pairsDevice));check(cuMemFree(countDevice));check(cuMemFree(velocityDevice));check(cuMemFree(indexDevice));
        check(cuEventDestroy(consumed));check(cuStreamDestroy(observer));}
    cluster->release();require(context.healthy() && !context.errors().warningCount(),"PhysX warning or capacity failure");
    std::printf("native scene GPU stress passed: %u impact frames; momentum error %g; torque relative error %g\n",stressFrames,worstMomentum,worstWrench);
}
}
int main() {
    try {
        {blast_demo::PhysXScene cpu(blast_demo::PhysicsMode::Cpu,false,{},nullptr);
         require(!cpu.scene().getDestructionScene(),"CPU scene exposed GPU stage");step(cpu.scene());}
        exercise();exercise(true);exercise(true,false);return 0;
    }catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}
}
