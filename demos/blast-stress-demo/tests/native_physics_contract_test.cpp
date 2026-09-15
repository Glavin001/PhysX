// Independent public-scene physics/material oracles, ordinary APIs + sleeping.
// No solver recurrence, component ID, allocation count or iteration count golden.
#include "../physx_scene.h"
#include <PxDestructionScene.h>
#include <cuda.h>
#include <array>
#include <cmath>
#include <cstdio>
#include <stdexcept>
#include <vector>
using namespace physx;
namespace {
void require(bool ok,const char* text){if(!ok)throw std::runtime_error(text);}
void near(double a,double b,double tolerance,const char* text){
    if(!std::isfinite(a)||!std::isfinite(b)||std::abs(a-b)>tolerance){
        std::fprintf(stderr,"%s actual=%.12g expected=%.12g tolerance=%.4g\n",text,a,b,tolerance);
        throw std::runtime_error(text);
    }
}
void step(PxScene& scene,float dt){scene.simulate(dt);PxU32 error=0;require(scene.fetchResults(true,&error)&&!error,"full native step failed");}
template<class T>void read(PxCudaContextManager& cuda,CUevent ready,const T* source,T* target,size_t n){
    PxScopedCudaLock lock(cuda);require(cuEventSynchronize(ready)==CUDA_SUCCESS,"observation not ready");
    require(cuMemcpyDtoH(target,reinterpret_cast<CUdeviceptr>(source),n*sizeof(T))==CUDA_SUCCESS,"observation copy failed");
}
void run(bool supported,bool permuted,bool rotated,float dt,float gravityMagnitude,bool heterogeneous=false){
    blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,false,false);
    auto& scene=context.scene();auto& physics=context.physics();
    require(!(scene.getFlags()&PxSceneFlag::eENABLE_DIRECT_GPU_API) && !(scene.getFlags()&PxSceneFlag::eDISABLE_SLEEPING),"ordinary sleeping contract changed");
    const PxQuat rotation=rotated?PxQuat(.7f,PxVec3(1,2,3).getNormalized()):PxQuat(PxIdentity);
    const PxVec3 gravity=rotation.rotate(PxVec3(0,-gravityMagnitude,0));scene.setGravity(gravity);
    const PxVec3 origin=rotated?PxVec3(13,120,-7):PxVec3(0,100,0);
    auto* body=physics.createRigidDynamic(PxTransform(origin,rotation));require(body,"body creation failed");
    const float totalMass=heterogeneous?(supported?3.f:4.f):(supported?2.f:3.f);
    const float center=heterogeneous?(supported?5.0f/3:1.25f):(supported?1.5f:1.f);
    const float axialInertia=totalMass/6,transverseInertia=heterogeneous?(supported?7.f/6:41.f/12):(supported?5.f/6:2.5f);
    body->setMass(totalMass);body->setMassSpaceInertiaTensor(PxVec3(transverseInertia,axialInertia,transverseInertia));
    body->setCMassLocalPose(PxTransform(PxVec3(0,center,0)));
    body->setLinearDamping(0);body->setAngularDamping(0);
    body->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,supported);
    const PxVec3 spin=rotation.rotate(PxVec3(0,.25f,0));
    if(!supported)body->setAngularVelocity(spin);
    std::array<PxShape*,3> shapes{};
    for(unsigned i=0;i<3;++i){
        shapes[i]=physics.createShape(PxBoxGeometry(.45f,.45f,.45f),context.material(),true);
        require(shapes[i],"shape creation failed");shapes[i]->setLocalPose(PxTransform(PxVec3(0,float(i),0)));
        require(body->attachShape(*shapes[i]),"shape attachment failed");
    }
    scene.addActor(*body);step(scene,dt);
    auto* stage=scene.getDestructionScene();require(stage,"native destruction unavailable");
    // Permute authored nodes and bond storage independently of physical geometry.
    const std::array<unsigned,3> order=permuted?std::array<unsigned,3>{2,0,1}:std::array<unsigned,3>{0,1,2};
    std::array<unsigned,3> index{};for(unsigned i=0;i<3;++i)index[order[i]]=i;
    std::array<PxDestructionStressChunk,3> chunks{};
    std::array<PxDestructionChunkMassProperties,3> mass{};
    for(unsigned i=0;i<3;++i){const unsigned authored=order[i];const float m=authored==0?(supported?0.0f:1.0f):(heterogeneous?float(authored):1.f);
        chunks[i]={PxVec3(0,float(authored),0),m,m/6,0,stage->getShapeContactIndex(*shapes[authored]),1,0};
        mass[i].center[1]=authored;mass[i].mass=m;mass[i].supported=supported&&authored==0;
        mass[i].inertia[0]=mass[i].inertia[1]=mass[i].inertia[2]=m/6;
    }
    std::array<PxDestructionStressBond,2> bonds{};
    for(unsigned e=0;e<2;++e){unsigned physical=permuted?1-e:e;
        const auto first=std::min(index[physical],index[physical+1]),second=std::max(index[physical],index[physical+1]);
        bonds[e]={first,second,PxVec3(0,float(physical)+.5f,0),PxVec3(0,-1,0),1,1,1,0};}
    PxDestructionMaterial material;material.compressionElasticLimit=10;material.compressionFatalLimit=40;
    material.tensionElasticLimit=material.shearElasticLimit=1e8f;
    material.tensionFatalLimit=material.shearFatalLimit=2e8f;
    PxDestructionStressCluster cluster{body->getGPUIndex(),PxVec3(0,center,0)};
    PxDestructionStressDesc desc;desc.chunks=chunks.data();desc.chunkCount=3;desc.bonds=bonds.data();desc.bondCount=2;
    desc.clusters=&cluster;desc.clusterCount=1;desc.chunkMassProperties=mass.data();desc.materials=&material;desc.materialCount=1;
    desc.maxIterations=256;desc.tolerance=1e-5f;desc.internalCorrectionLimit=1;
    require(stage->configureStress(desc),"native graph configuration failed");
    const auto initial=body->getGlobalPose();const PxVec3 initialVelocity=body->getLinearVelocity();
    double health[2]={1,1};const unsigned ticks=supported?16:60;
    for(unsigned tick=0;tick<ticks;++tick){
        const PxVec3 impulse=rotation.rotate(PxVec3(3,0,0));
        if(!supported&&tick==15)body->addForce(impulse,PxForceMode::eIMPULSE);
        step(scene,dt);const auto status=stage->getLastStatus();
        require(!status.error&&status.converged&&status.frame==tick+1&&status.stressPasses==1+status.correctionPasses&&status.correctionPasses<=1,"invalid accepted stress/correction state");
        require(!status.brokenBonds&&!status.crushedChunks,"stable fixture spuriously fractured");
        const auto view=stage->getDeviceView();std::array<PxDestructionVectorPair,2> forces;std::array<float,2> observed;
        read(*context.cudaContextManager(),view.readyEvent,view.bondForces,forces.data(),2);
        read(*context.cudaContextManager(),view.readyEvent,view.bondHealth,observed.data(),2);
        for(unsigned e=0;e<2;++e){const unsigned physical=permuted?1-e:e;
            const double load=supported?(physical==0?totalMass:(heterogeneous?2.f:1.f))*gravityMagnitude:0;
            near(forces[e].linear.magnitude(),load,2e-3,"independent axial equilibrium");
            near(forces[e].angular.magnitude(),0,2e-3,"axial load acquired bending");
            // Independent scalar section-loss equation. In this statically
            // determinate column load is mg regardless of bond health/cache.
            const double utilization=std::max(0.0,(load/health[physical]-10)/30);
            require(utilization<1,"fixture crossed fatal threshold unexpectedly");
            health[physical]-=health[physical]*utilization*dt*2;
            near(observed[e],health[physical],3e-5,"equilibrium reuse skipped or duplicated material damage");
        }
        if(!supported){
            const auto expected=initialVelocity+gravity*(float(tick+1)*dt)+(tick>=15?impulse/totalMass:PxVec3(0));
            near((body->getLinearVelocity()-expected).magnitude(),0,2e-4,"free-body gravity/impulse momentum");
            const float n=float(tick+1);
            const auto expectedPosition=initial.p+initialVelocity*(n*dt)+gravity*(dt*dt*n*(n+1)*.5f)+(tick>=15?impulse/totalMass*(float(tick-14)*dt):PxVec3(0));
            near((body->getGlobalPose().p-expectedPosition).magnitude(),0,1e-3,"free-body full-step trajectory");
            near((body->getAngularVelocity()-spin).magnitude(),0,1e-4,"COM impulse changed angular momentum");
            const auto expectedOrientation=initial.q*PxQuat(.25f*n*dt,PxVec3(0,1,0));
            near(1-std::abs(body->getGlobalPose().q.getNormalized().dot(expectedOrientation.getNormalized())),0,1e-5,"torque-free orientation integration");
        }
    }
    require(stage->clearStress(),"stress clear failed");for(auto* shape:shapes)shape->release();body->release();
    require(context.healthy(),"PhysX reported GPU failure");
    std::printf("physical contract supported=%u permutation=%u rotation=%u dt=%g gravity=%g ticks=%u passed\n",supported,permuted,rotated,dt,gravityMagnitude,ticks);
}
}
int main(int argc,char** argv){try{
    // An explicit physical-model audit, not a golden for the current mass
    // equalization heuristic. Its known control failure must remain visible.
    if(argc==2&&std::string(argv[1])=="--unequal-mass"){run(true,false,false,1.0f/60,9.81f,true);return 0;}
    require(argc==1,"unknown physical contract argument");
    for(bool supported:{false,true})for(bool permuted:{false,true})for(bool rotated:{false,true})run(supported,permuted,rotated,1.0f/60,9.81f);
    run(true,false,false,1.0f/120,9.81f);run(true,true,true,1.0f/60,3);
    return 0;
}catch(const std::exception& e){std::fprintf(stderr,"native physical contract failed: %s\n",e.what());return 1;}}
