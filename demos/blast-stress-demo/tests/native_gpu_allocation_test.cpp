// Native PxScene fracture task owns allocation; the application never allocates
// candidate actors or reads graph/motion data to drive this transaction.
#include "../physx_scene.h"
#include "NpScene.h"
#include "NpRigidDynamic.h"
#include "ScBodySim.h"
#include <PxDestructionScene.h>
#include <cuda.h>
#include <cstdio>
#include <stdexcept>
#include <vector>
using namespace physx;
namespace {
void require(bool value,const char* message){if(!value)throw std::runtime_error(message);}
void check(CUresult result){require(result==CUDA_SUCCESS,"CUDA observation failed");}
void step(PxScene& scene){scene.simulate(1.0f/60);PxU32 error=0;require(scene.fetchResults(true,&error)&&!error,"ordinary step failed");}
struct Deleted : PxDeletionListener {
    unsigned count=0;
    void onRelease(const PxBase*,void*,PxDeletionEventFlag::Enum) override {++count;}
};
void run(bool sleeping) {
    blast_demo::SceneCapacity capacity;blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,true,false,sleeping,sleeping);
    auto& scene=context.scene();auto& internal=static_cast<NpScene&>(scene);auto& physics=context.physics();auto& cuda=*context.cudaContextManager();
    scene.setGravity(PxVec3(0,-9.81f,0));
    auto* parent=physics.createRigidDynamic(PxTransform(PxVec3(0,20,0)));
    parent->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
    auto* shape=physics.createShape(PxBoxGeometry(.5f,.5f,.5f),context.material(),true);require(parent->attachShape(*shape),"geometry setup failed");shape->release();
    scene.addActor(*parent);step(scene);auto* stage=scene.getDestructionScene();require(stage,"native scene missing");
    const auto parentIndex=parent->getGPUIndex();const auto shapeIndex=scene.getDirectGPUAPI().getShapeContactIndex(*shape);
    Deleted deleted;physics.registerDeletionListener(deleted,PxDeletionEventFlag::eUSER_RELEASE|PxDeletionEventFlag::eMEMORY_RELEASE);
    auto configure=[&](unsigned n,bool fractures){
        std::vector<PxDestructionStressChunk> chunks(n);std::vector<PxDestructionChunkMassProperties> mass(n);
        std::vector<PxDestructionStressBond> bonds(n-1);
        for(unsigned i=0;i<n;++i) {
            const PxVec3 position(0,float(i),0);chunks[i]={position,i?1.0f:0.0f,i?1.0f:0.0f,0,PX_INVALID_U32};
            mass[i]={};mass[i].center[1]=i;mass[i].mass=i?1:0;mass[i].supported=i?0:1;
            mass[i].inertia[0]=mass[i].inertia[1]=mass[i].inertia[2]=i?1:0;
            if(i)bonds[i-1]={0,i,position*.5f,PxVec3(0,1,0),1,1,1};
        }
        const PxDestructionStressCluster cluster{parentIndex,PxVec3(0)};PxDestructionMaterial material;
        if(!fractures){material.compressionElasticLimit=1e12f;material.compressionFatalLimit=2e12f;}
        PxDestructionStressDesc desc;desc.chunks=chunks.data();desc.chunkCount=n;desc.chunkMassProperties=mass.data();desc.bonds=bonds.data();desc.bondCount=n-1;
        desc.clusters=&cluster;desc.clusterCount=1;desc.materials=&material;desc.materialCount=1;desc.maxIterations=128;desc.tolerance=1e-5f;
        require(stage->configureStress(desc),"native allocation graph configuration failed");
        auto invalid=desc;auto bad=cluster;bad.body=0xfffffffeu;invalid.clusters=&bad;
        require(!stage->configureStress(invalid),"unallocated GPU body index accepted as a source");
    };
    auto observe=[&](unsigned n){
        const auto view=stage->getDeviceView();require(view.bodyAllocation && view.trialBodyIndices,"allocation device view missing");
        PxDestructionBodyAllocationStatus status;PxDestructionTopologyStatus accepted;std::vector<PxU32> indices(n);
        {PxScopedCudaLock lock(cuda);check(cuEventSynchronize(view.readyEvent));
            check(cuMemcpyDtoH(&status,reinterpret_cast<CUdeviceptr>(view.bodyAllocation),sizeof(status)));
            check(cuMemcpyDtoH(&accepted,reinterpret_cast<CUdeviceptr>(view.acceptedTopology.status),sizeof(accepted)));
            require(status.valid && !status.error && status.count==n && status.reserved==n-1 && status.generation==1,"native reservation batch mismatch");
            check(cuMemcpyDtoH(indices.data(),reinterpret_cast<CUdeviceptr>(view.trialBodyIndices),n*sizeof(PxU32)));
        }
        require(!accepted.generation && accepted.clusterCount==1,"reservation committed fracture topology");
        require(indices[0]==parentIndex,"existing owner was needlessly replaced");
        require(internal.getNbDestructionBodyCandidates()==n-1,"native candidate count mismatch");
        require(scene.getNbActors(PxActorTypeFlag::eRIGID_DYNAMIC)==1,"uncommitted reservations published as actors");
        require(parent->getNbShapes()==1 && shape->getActor()==parent && scene.getDirectGPUAPI().getShapeContactIndex(*shape)==shapeIndex,"reservation changed persistent geometry ownership");
        for(unsigned i=1;i<n;++i) {
            auto* candidate=internal.getDestructionBodyCandidate(i);require(candidate,"native BodySim reservation missing");
            require(candidate->getNpScene()==&internal && candidate->getCore().getInternalIslandNodeIndex().index()==indices[i],"reserved node mapping invalid");
            require(candidate->getCore().getSim() && !candidate->getCore().getSim()->isActive() && !candidate->getShapeManager().getNbShapes(),"reserved candidate participates in ordinary dynamics");
            require(indices[i]!=parentIndex,"candidate aliased accepted motion owner");
        }
        require(!deleted.count,"private allocation leaked a user deletion event");return indices;
    };
    auto fracture=[&]{scene.simulate(1.0f/60);PxU32 error=0;require(!scene.fetchResults(true,&error)&&error&&stage->getLastStatus().error==8,"unimplemented correction falsely completed or reservation failed");};
    configure(2,false);step(scene);require(!internal.getNbDestructionBodyCandidates(),"intact cluster allocated per-chunk motion slots");
    configure(2,true);fracture();const auto first=observe(2);
    // An uncommitted slot must not be accepted as a new graph's source:
    // reconfiguration would release that reservation while retaining its ID.
    PxDestructionStressChunk privateChunk{PxVec3(0),1,1,0,PX_INVALID_U32};
    PxDestructionStressCluster privateBinding{first[1],PxVec3(0)};
    PxDestructionStressDesc privateDesc;privateDesc.chunks=&privateChunk;privateDesc.chunkCount=1;
    privateDesc.clusters=&privateBinding;privateDesc.clusterCount=1;
    require(!stage->configureStress(privateDesc),"uncommitted reserved node accepted as a source body");
    require(observe(2)==first,"rejected source binding changed pending reservations");
    physics.unregisterDeletionListener(deleted);
    auto* removed=physics.createRigidDynamic(PxTransform(PxIdentity));scene.addActor(*removed);
    const PxU32 removedIndex=removed->getGPUIndex();removed->release();
    physics.registerDeletionListener(deleted,PxDeletionEventFlag::eUSER_RELEASE|PxDeletionEventFlag::eMEMORY_RELEASE);
    privateBinding.body=removedIndex;
    require(!stage->configureStress(privateDesc),"released source survived deferred island-node deletion");
    require(observe(2)==first,"rejected deleted source changed reservations");
    for(unsigned i=0;i<3;++i){fracture();require(observe(2)==first,"identical verdict retry replaced its reserved node IDs");}
    // Clear a pending reservation before the normal GPU body upload, then grow
    // far past the first request. No truncation and no public actor inflation.
    configure(257,true);require(!internal.getNbDestructionBodyCandidates(),"reconfiguration retained old reservations");fracture();const auto grown=observe(257);
    fracture();require(observe(257)==grown,"grown reservations were not reused");
    configure(3,true);fracture();observe(3);
    require(stage->clearStress(),"clear native graph failed");require(!internal.getNbDestructionBodyCandidates() && !deleted.count,"clear leaked reservations or trial events");
    step(scene);require(!deleted.count,"delayed private deletion event leaked after upload");
    // Only one split among many existing clusters: the GPU returns one body
    // allocation request and retains every other node binding on device.
    constexpr unsigned retained=64;
    std::vector<PxRigidDynamic*> unchanged;std::vector<PxDestructionStressCluster> clusterBindings(1+retained);
    clusterBindings[0]={parentIndex,PxVec3(0)};
    for(unsigned i=0;i<retained;++i) {
        auto* actor=physics.createRigidDynamic(PxTransform(PxVec3(float(i),50,0)));
        actor->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);scene.addActor(*actor);unchanged.push_back(actor);
        clusterBindings[i+1]={actor->getGPUIndex(),PxVec3(0)};
    }
    step(scene);
    std::vector<PxDestructionStressChunk> quietChunks(2+retained);
    std::vector<PxDestructionChunkMassProperties> quietMass(2+retained);
    for(unsigned i=0;i<quietChunks.size();++i) {
        quietChunks[i]={PxVec3(0),i==1?1.0f:0.0f,i==1?1.0f:0.0f,i<2?0:i-1,PX_INVALID_U32};
        quietMass[i]={};quietMass[i].mass=i==1?1:0;quietMass[i].supported=i==1?0:1;
        for(unsigned k=0;k<3;++k)quietMass[i].inertia[k]=i==1?1:0;
    }
    quietChunks[0].position.y=-1;quietMass[0].center[1]=-1;
    PxDestructionStressBond quietBond{0,1,PxVec3(0,-.5f,0),PxVec3(0,1,0),1,1,1};PxDestructionMaterial quietMaterial;
    PxDestructionStressDesc quietDesc;quietDesc.chunks=quietChunks.data();quietDesc.chunkCount=unsigned(quietChunks.size());quietDesc.chunkMassProperties=quietMass.data();
    quietDesc.clusters=clusterBindings.data();quietDesc.clusterCount=unsigned(clusterBindings.size());quietDesc.bonds=&quietBond;quietDesc.bondCount=1;
    quietDesc.materials=&quietMaterial;quietDesc.materialCount=1;require(stage->configureStress(quietDesc),"quiet world configuration failed");fracture();
    const auto quietView=stage->getDeviceView();PxDestructionBodyAllocationStatus quietAllocation;PxDestructionBodyPreparationStatus quietPreparation;PxU32 quietIndices[retained+2];
    {PxScopedCudaLock lock(cuda);check(cuEventSynchronize(quietView.readyEvent));
        check(cuMemcpyDtoH(&quietAllocation,reinterpret_cast<CUdeviceptr>(quietView.bodyAllocation),sizeof(quietAllocation)));
        check(cuMemcpyDtoH(&quietPreparation,reinterpret_cast<CUdeviceptr>(quietView.bodyPreparation),sizeof(quietPreparation)));
        check(cuMemcpyDtoH(quietIndices,reinterpret_cast<CUdeviceptr>(quietView.trialBodyIndices),sizeof(quietIndices)));}
    require(quietAllocation.valid && quietAllocation.count==retained+2 && quietAllocation.reserved==1 && quietPreparation.allocationRequests==1,
        "unchanged clusters entered the host allocation request set");
    require(quietIndices[0]==parentIndex && quietIndices[1]!=parentIndex && internal.getNbDestructionBodyCandidates()==1,"sparse split reservation mapping failed");
    for(unsigned i=0;i<retained;++i)require(quietIndices[i+2]==clusterBindings[i+1].body,"unchanged cluster binding was replaced");
    require(scene.getNbActors(PxActorTypeFlag::eRIGID_DYNAMIC)==retained+1 && !deleted.count,"sparse split published trial actors/events");
    require(stage->clearStress() && !internal.getNbDestructionBodyCandidates() && !deleted.count,"sparse split cleanup leaked");
    physics.unregisterDeletionListener(deleted);for(auto* actor:unchanged)actor->release();parent->release();require(context.healthy(),"native allocation GPU health failed");
    std::puts("native cluster allocation: intact no allocation, real node reservations, unchanged owner reuse, retry stability, 256-child growth, pending-upload removal, private actor/event isolation passed");
}
void teardown() {
    // Leave an uncommitted reservation alive through scene teardown. Scene must
    // release it while BodySim/island/controller pools still exist.
    blast_demo::SceneCapacity capacity;blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,true,false,true,true);
    auto& scene=context.scene();auto* parent=context.physics().createRigidDynamic(PxTransform(PxIdentity));
    parent->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);scene.addActor(*parent);step(scene);
    PxDestructionStressChunk chunks[2]={{PxVec3(0),0,0,0,PX_INVALID_U32},{PxVec3(0,1,0),1,1,0,PX_INVALID_U32}};
    PxDestructionChunkMassProperties mass[2]={{{0,0,0},0,{0,0,0,0,0,0},1},{{0,1,0},1,{1,1,1,0,0,0},0}};
    PxDestructionStressBond bond{0,1,PxVec3(0,.5f,0),PxVec3(0,1,0),1,1,1};PxDestructionStressCluster cluster{parent->getGPUIndex(),PxVec3(0)};PxDestructionMaterial material;
    PxDestructionStressDesc desc;desc.chunks=chunks;desc.chunkCount=2;desc.chunkMassProperties=mass;desc.bonds=&bond;desc.bondCount=1;desc.clusters=&cluster;desc.clusterCount=1;desc.materials=&material;desc.materialCount=1;
    auto* stage=scene.getDestructionScene();require(stage->configureStress(desc),"teardown configuration failed");scene.setGravity(PxVec3(0,-9.81f,0));scene.simulate(1.0f/60);PxU32 error=0;
    require(!scene.fetchResults(true,&error)&&error&&static_cast<NpScene&>(scene).getNbDestructionBodyCandidates()==1,"teardown fixture did not reserve body");
    // Parent removal is permitted after completed fetch; its slot can outlive
    // that actor until the scene discards the uncommitted transaction.
    parent->release();
}
}
int main(){try{run(true);run(false);teardown();return 0;}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
