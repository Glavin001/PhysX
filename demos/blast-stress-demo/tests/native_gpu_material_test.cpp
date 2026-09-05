// Native scene GPU material state versus the real imported CPU reference.
// Reference calls and device observations are test-only, outside PxScene steps.
#include "../physx_scene.h"
#include "ext_stress_bridge.h"
#include <PxDestructionScene.h>
#include <cuda.h>
#include <cmath>
#include <cstdio>
#include <memory>
#include <stdexcept>
using namespace physx;
namespace {
void require(bool v,const char* message){if(!v)throw std::runtime_error(message);}
void check(CUresult r){require(r==CUDA_SUCCESS,"CUDA observation failed");}
void near(float a,float b,const char* message){
    if(!std::isfinite(a) || !std::isfinite(b) || std::abs(a-b)>2e-4f*std::max(1.0f,std::abs(b))) {
        std::fprintf(stderr,"%s: native=%g reference=%g\n",message,a,b);throw std::runtime_error(message);
    }
}
struct Release{void operator()(ExtStressSolverHandle* h)const{ext_stress_solver_destroy(h);}};
using Reference=std::unique_ptr<ExtStressSolverHandle,Release>;
ExtStressMaterialDesc referenceMaterial(const PxDestructionMaterial& m){
    ExtStressMaterialDesc r{};r.compression_elastic_limit=m.compressionElasticLimit;r.compression_fatal_limit=m.compressionFatalLimit;
    r.tension_elastic_limit=m.tensionElasticLimit;r.tension_fatal_limit=m.tensionFatalLimit;
    r.shear_elastic_limit=m.shearElasticLimit;r.shear_fatal_limit=m.shearFatalLimit;r.residual_area_fraction=m.residualAreaFraction;
    r.crush_cap_pressure=m.crush.capPressure;r.crush_cohesion=m.crush.cohesion;r.crush_friction_slope=m.crush.frictionSlope;
    r.crush_energy=m.crush.crushEnergy;r.crush_viscosity=m.crush.crushViscosity;
    r.crush_strain_rate_exponent=m.crush.strainRateExponent;r.crush_reference_strain_rate=m.crush.referenceStrainRate;
    r.crush_debris_mass_fraction=m.crush.debrisMassFraction;r.crush_debris_fragment_count=m.crush.debrisFragmentCount;return r;
}
void scenario(blast_demo::PhysXScene& context,PxRigidDynamic& body,const char* name,
    PxDestructionMaterial material,PxVec3 gravity,unsigned frames,float dt,bool expectFracture,bool expectFloor=false)
{
    auto& scene=context.scene();scene.setGravity(gravity);auto* stage=scene.getDestructionScene();
    PxDestructionStressChunk chunks[2]={{PxVec3(0,-1,0),0,0,0,PX_INVALID_U32,1,0},{PxVec3(0),2,1,0,PX_INVALID_U32,1,0}};
    PxDestructionStressBond bond{0,1,PxVec3(0,-0.5f,0),PxVec3(0,-1,0),1,1,1}; // reversed normal must be aligned
    PxDestructionStressCluster cluster{body.getGPUIndex(),PxVec3(0)};
    PxDestructionStressDesc desc;desc.chunks=chunks;desc.chunkCount=2;desc.bonds=&bond;desc.bondCount=1;
    desc.clusters=&cluster;desc.clusterCount=1;desc.materials=&material;desc.materialCount=1;desc.maxIterations=128;desc.tolerance=1e-5f;
    const PxDestructionChunkMassProperties massProperties[2]={
        {{0,-1,0},0,{0,0,0,0,0,0},1},{{0,0,0},2,{1,1,1,0,0,0},0}};
    desc.chunkMassProperties=massProperties;
    require(stage->configureStress(desc),"native material configuration failed");
    auto invalid=desc;invalid.materialCount=1;auto bad=material;bad.residualAreaFraction=2;invalid.materials=&bad;
    require(!stage->configureStress(invalid),"invalid material silently accepted");
    ExtStressNodeDesc rn[2]={{{0,-1,0},0,1,0},{{0,0,0},2,1,1}};
    ExtStressBondDesc rb{{0,-0.5f,0},{0,-1,0},1,0,1,0};
    auto rm=referenceMaterial(material);ExtStressSolverSettingsDesc settings{128,0};
    Reference ref(ext_stress_solver_create(rn,2,&rb,1,&rm,1,&settings));require(bool(ref),"reference create failed");
    ext_stress_solver_set_gpu_accelerated(ref.get(),0);
    const uint32_t nodeMaterials[]={0,0};ext_stress_solver_set_node_materials(ref.get(),nodeMaterials,2);
    float previousHealth=1,previousCrush=0;bool fractured=false;unsigned commandsSeen=0;
    for(unsigned tick=0;tick<frames;++tick){
        const StressVec3 g{gravity.x,gravity.y,gravity.z};ext_stress_solver_add_gravity(ref.get(),&g);
        const float rates[]={0,0};require(ext_stress_solver_set_node_strain_rates(ref.get(),rates,2,dt),"reference rate inputs failed");
        ext_stress_solver_set_delta_time(ref.get(),dt);ext_stress_solver_update(ref.get());
        ExtStressFractureCommands command{};ExtStressBondFracture commandBond;
        uint32_t commandCount=0,bondCount=0;
        // The legacy single-command bridge returns only bond commands. Use
        // the complete per-actor bridge, as the reference adapter does, so
        // chunk-only crushing is part of the verdict under comparison.
        require(ext_stress_solver_generate_fracture_commands_per_actor(ref.get(),&command,1,&commandBond,1,
            &commandCount,&bondCount)==1,"reference verdict failed");
        require(commandCount<=1 && bondCount==command.bondFractureCount,"reference command accounting failed");
        float compression,tension,shear,damage[2],pressure[2],deviator[2];
        ext_stress_solver_get_bond_stresses(ref.get(),&compression,&tension,&shear,1);
        ext_stress_solver_get_node_crush_damage(ref.get(),damage,2);
        ext_stress_solver_get_node_stress_invariants(ref.get(),pressure,deviator,2);
        scene.simulate(dt);PxU32 error=0;const bool complete=scene.fetchResults(true,&error);
        const auto view=stage->getDeviceView();PxDestructionBondVerdict verdict;
        PxDestructionCrushState accepted[2],trial[2];float health;
        PxDestructionTopologyTransactionStatus topologyTransaction;
        PxDestructionTopologyStatus acceptedTopology;
        PxDestructionClusterMassProperties acceptedClusters[2];
        {PxScopedCudaLock lock(*context.cudaContextManager());check(cuEventSynchronize(view.readyEvent));
            check(cuMemcpyDtoH(&health,reinterpret_cast<CUdeviceptr>(view.bondHealth),sizeof(health)));
            check(cuMemcpyDtoH(&verdict,reinterpret_cast<CUdeviceptr>(view.bondVerdicts),sizeof(verdict)));
            check(cuMemcpyDtoH(accepted,reinterpret_cast<CUdeviceptr>(view.chunkCrush),sizeof(accepted)));
            check(cuMemcpyDtoH(trial,reinterpret_cast<CUdeviceptr>(view.trialChunkCrush),sizeof(trial)));
            check(cuMemcpyDtoH(&topologyTransaction,reinterpret_cast<CUdeviceptr>(view.topologyTransaction),sizeof(topologyTransaction)));
            check(cuMemcpyDtoH(&acceptedTopology,reinterpret_cast<CUdeviceptr>(view.acceptedTopology.status),sizeof(acceptedTopology)));
            check(cuMemcpyDtoH(acceptedClusters,reinterpret_cast<CUdeviceptr>(view.acceptedTopology.clusters),sizeof(acceptedClusters)));
        }
        const auto status=stage->getLastStatus();
        near(verdict.damage,command.bondFractureCount?commandBond.health:0,"bond damage parity");
        require(verdict.command==command.bondFractureCount,"bond command decision parity");
        const float nativeCompression=std::max(0.0f,verdict.stressBend-verdict.stressNormal);
        const float nativeTension=std::max(0.0f,verdict.stressNormal+verdict.stressBend);
        near(nativeCompression,compression,"compression parity");near(nativeTension,tension,"tension parity");near(verdict.stressShear,shear,"shear parity");
        near(trial[1].damage,damage[1],"crush damage parity");near(trial[1].pressure,pressure[1],"pressure parity");near(trial[1].deviator,deviator[1],"deviator parity");
        const bool referenceBreak=(command.bondFractureCount && commandBond.health>=previousHealth) || command.chunkFractureCount;
        require(bool(status.brokenBonds || status.crushedChunks)==referenceBreak,"fracture decision parity");
        require(acceptedTopology.generation==0 && acceptedTopology.clusterCount==1 && acceptedClusters[0].mass==2,
            "native trial changed accepted cluster ownership/mass");
        require(!topologyTransaction.error && !topologyTransaction.commits,"unexpected native topology transaction state");
        commandsSeen+=status.bondCommands;
        if(referenceBreak){
            require(topologyTransaction.prepared && topologyTransaction.rebuilds==1,"fracture did not prepare native GPU clusters");
            PxDestructionTopologyStatus candidate;PxDestructionClusterMassProperties clusters[2];PxU32 labels[2],active[2];
            {PxScopedCudaLock lock(*context.cudaContextManager());
                check(cuMemcpyDtoH(&candidate,reinterpret_cast<CUdeviceptr>(view.trialTopology.status),sizeof(candidate)));
                check(cuMemcpyDtoH(clusters,reinterpret_cast<CUdeviceptr>(view.trialTopology.clusters),sizeof(clusters)));
                check(cuMemcpyDtoH(labels,reinterpret_cast<CUdeviceptr>(view.trialTopology.chunkCluster),sizeof(labels)));
                check(cuMemcpyDtoH(active,reinterpret_cast<CUdeviceptr>(view.trialTopology.activeChunks),sizeof(active)));}
            require(candidate.generation==1 && !candidate.invalidEdit,"candidate topology generation invalid");
            require(candidate.clusterCount==(status.crushedChunks?1u:2u),"native candidate cluster membership invalid");
            require(active[0] && labels[0]==0 && clusters[0].mass==0 && clusters[0].supported,"candidate lost authored support");
            if(status.crushedChunks)require(!active[1] && labels[1]==PX_INVALID_U32,"crushed chunk survived candidate graph");
            else require(active[1] && labels[1]==1 && clusters[1].mass==2 && clusters[1].inertia[0]==1,"detached chunk mass/inertia invalid");
            require(!complete && error && status.error==8,"fracture requiring correction was falsely accepted");
            near(health,previousHealth,"failed frame committed bond damage");near(accepted[1].damage,previousCrush,"failed frame committed crush damage");
            // A failed correction retry must start from exactly the accepted
            // material state. Here motion is prescribed, so inputs are identical.
            scene.simulate(dt);require(!scene.fetchResults(true,&error),"retry falsely completed");
            float retryHealth;PxDestructionCrushState retry[2];PxDestructionBondVerdict retryVerdict;
            {PxScopedCudaLock lock(*context.cudaContextManager());
                check(cuMemcpyDtoH(&retryHealth,reinterpret_cast<CUdeviceptr>(view.bondHealth),sizeof(retryHealth)));
                check(cuMemcpyDtoH(retry,reinterpret_cast<CUdeviceptr>(view.chunkCrush),sizeof(retry)));
                check(cuMemcpyDtoH(&retryVerdict,reinterpret_cast<CUdeviceptr>(view.bondVerdicts),sizeof(retryVerdict)));}
            near(retryHealth,health,"retry applied bond damage twice");near(retry[1].damage,accepted[1].damage,"retry applied crush damage twice");
            near(retryVerdict.damage,verdict.damage,"retry changed damage verdict");fractured=true;break;
        }
        require(!topologyTransaction.prepared && !topologyTransaction.rebuilds,"nonfracturing frame rebuilt GPU connectivity");
        require(complete && !error && !status.error,"nonfracturing material step failed");
        near(health,previousHealth-verdict.damage,"accepted health incorrect");near(accepted[1].damage,trial[1].damage,"accepted crush incorrect");
        if(command.bondFractureCount || command.chunkFractureCount){
            ExtStressSplitEvent events[4];ExtStressActor children[4];uint32_t nodes[8],ne=0,nc=0,nn=0;
            require(ext_stress_solver_apply_fracture_commands(ref.get(),&command,1,events,4,children,4,&ne,&nc,nodes,8,&nn),"reference apply failed");
            require(!ne,"subfatal reference unexpectedly split");
        }
        float referenceHealth;ext_stress_solver_get_bond_healths(ref.get(),&referenceHealth,1);near(health,referenceHealth,"multi-frame health parity");
        previousHealth=health;previousCrush=accepted[1].damage;
    }
    require(fractured==expectFracture,"fixture did not exercise expected fracture mode");
    if(expectFloor){near(previousHealth,material.residualAreaFraction,"reinforcement floor not reached");require(commandsSeen,"floor fixture issued no damage");}
    require(stage->clearStress(),"native clear after verdict failed");
    std::printf("%s: parity passed, health=%g crush=%g fracture=%d\n",name,previousHealth,previousCrush,fractured);
}
void rotatingCluster(blast_demo::PhysXScene& context) {
    auto& scene=context.scene();scene.setGravity(PxVec3(0));
    auto* body=context.physics().createRigidDynamic(PxTransform(PxVec3(10,5,0),PxQuat(.35f,PxVec3(0,0,1))));
    require(body,"rotating cluster create failed");
    for(unsigned i=0;i<2;++i) {
        auto* shape=context.physics().createShape(PxBoxGeometry(.25f,.25f,.25f),context.material(),true);
        require(shape,"rotating chunk geometry create failed");shape->setLocalPose(PxTransform(PxVec3(2.0f*i,0,0)));
        require(body->attachShape(*shape),"rotating chunk attach failed");shape->release();
    }
    constexpr float childInertia=1.0f/24.0f;
    body->setMass(2);body->setMassSpaceInertiaTensor(PxVec3(2*childInertia,2+2*childInertia,2+2*childInertia));
    body->setCMassLocalPose(PxTransform(PxVec3(1,0,0)));body->setLinearDamping(0);body->setAngularDamping(0);
    body->setLinearVelocity(PxVec3(3,4,1));body->setAngularVelocity(PxVec3(0,0,2));scene.addActor(*body);
    scene.simulate(1.0f/60);require(scene.fetchResults(true),"rotating warmup failed");
    PxDestructionStressChunk chunks[2]={
        {PxVec3(0),1,childInertia,0,PX_INVALID_U32,.125f,0},
        {PxVec3(2,0,0),1,childInertia,0,PX_INVALID_U32,.125f,0}};
    const PxDestructionChunkMassProperties mass[2]={
        {{0,0,0},1,{childInertia,childInertia,childInertia,0,0,0},0},
        {{2,0,0},1,{childInertia,childInertia,childInertia,0,0,0},0}};
    const PxDestructionStressBond bond{0,1,PxVec3(1,0,0),PxVec3(1,0,0),1,1,1};
    const PxDestructionStressCluster cluster{body->getGPUIndex(),PxVec3(1,0,0)};
    PxDestructionMaterial material;PxDestructionStressDesc desc;
    desc.chunks=chunks;desc.chunkCount=2;desc.bonds=&bond;desc.bondCount=1;desc.clusters=&cluster;desc.clusterCount=1;
    desc.materials=&material;desc.materialCount=1;desc.chunkMassProperties=mass;desc.maxIterations=128;desc.tolerance=1e-5f;
    auto* stage=scene.getDestructionScene();require(stage->configureStress(desc),"rotating native graph configuration failed");
    auto invalid=desc;PxDestructionStressChunk separate[2]={chunks[0],chunks[1]};separate[1].cluster=1;
    const PxDestructionStressCluster duplicateBindings[2]={cluster,cluster};
    invalid.chunks=separate;invalid.clusters=duplicateBindings;invalid.clusterCount=2;invalid.bonds=nullptr;invalid.bondCount=0;
    require(!stage->configureStress(invalid),"disconnected components accepted one shared motion binding");
    scene.simulate(1.0f/60);PxU32 error=0;
    require(!scene.fetchResults(true,&error) && error && stage->getLastStatus().error==8,"rotating fracture was falsely committed");
    const auto view=stage->getDeviceView();PxDestructionClusterMotion motions[2];PxDestructionVectorPair force;
    PxDestructionTopologyTransactionStatus transaction;PxDestructionTopologyStatus accepted,candidate;
    CUdeviceptr buffer,indices;
    {PxScopedCudaLock lock(*context.cudaContextManager());
        check(cuEventSynchronize(view.readyEvent));
        check(cuMemcpyDtoH(motions,reinterpret_cast<CUdeviceptr>(view.trialTopology.motions),sizeof(motions)));
        check(cuMemcpyDtoH(&force,reinterpret_cast<CUdeviceptr>(view.bondForces),sizeof(force)));
        check(cuMemcpyDtoH(&transaction,reinterpret_cast<CUdeviceptr>(view.topologyTransaction),sizeof(transaction)));
        check(cuMemcpyDtoH(&accepted,reinterpret_cast<CUdeviceptr>(view.acceptedTopology.status),sizeof(accepted)));
        check(cuMemcpyDtoH(&candidate,reinterpret_cast<CUdeviceptr>(view.trialTopology.status),sizeof(candidate)));
        check(cuMemAlloc(&buffer,sizeof(PxTransform)));check(cuMemAlloc(&indices,sizeof(PxU32)));
        const auto index=body->getGPUIndex();check(cuMemcpyHtoD(indices,&index,sizeof(index)));}
    auto observe=[&](void* out,size_t bytes,PxRigidDynamicGPUAPIReadType::Enum type) {
        require(scene.getDirectGPUAPI().getRigidDynamicData(reinterpret_cast<void*>(buffer),reinterpret_cast<const PxU32*>(indices),type,1),"rotating body observation failed");
        PxScopedCudaLock lock(*context.cudaContextManager());check(cuMemcpyDtoH(out,buffer,bytes));
    };
    PxTransform pose;PxVec3 linear,angular;
    observe(&pose,sizeof(pose),PxRigidDynamicGPUAPIReadType::eGLOBAL_POSE);
    observe(&linear,sizeof(linear),PxRigidDynamicGPUAPIReadType::eLINEAR_VELOCITY);
    observe(&angular,sizeof(angular),PxRigidDynamicGPUAPIReadType::eANGULAR_VELOCITY);
    require(transaction.prepared && transaction.rebuilds==1 && !transaction.commits && !transaction.error,"rotating topology transaction invalid");
    require(accepted.clusterCount==1 && !accepted.generation && candidate.clusterCount==2 && candidate.generation==1,"rotating trial changed accepted graph");
    near(force.linear.magnitude(),4,"centrifugal bond force analytic check");
    PxVec3 momentum(0);float spinMomentum=0,kinetic=0;
    for(unsigned i=0;i<2;++i) {
        const auto m=motions[i];const PxVec3 r=pose.q.rotate(PxVec3(i?1.0f:-1.0f,0,0));
        const PxVec3 expected=linear+angular.cross(r),v(float(m.linearVelocity[0]),float(m.linearVelocity[1]),float(m.linearVelocity[2]));
        for(unsigned k=0;k<3;++k) {
            near(float(m.origin[k]),pose.p[k],"candidate actor origin continuity");
            near(v[k],expected[k],"offset COM point-velocity continuity");
            near(float(m.angularVelocity[k]),angular[k],"candidate angular velocity continuity");
        }
        near(float(m.orientation[0]),pose.q.x,"orientation x");near(float(m.orientation[1]),pose.q.y,"orientation y");
        near(float(m.orientation[2]),pose.q.z,"orientation z");near(float(m.orientation[3]),pose.q.w,"orientation w");
        momentum+=v;spinMomentum+=childInertia*angular.z+r.cross(v-linear).z;
        kinetic+=.5f*v.magnitudeSquared()+.5f*childInertia*angular.magnitudeSquared();
    }
    for(unsigned k=0;k<3;++k)near(momentum[k],2*linear[k],"candidate linear momentum conservation");
    near(spinMomentum,(2+2*childInertia)*angular.z,"candidate angular momentum conservation");
    near(kinetic,linear.magnitudeSquared()+.5f*(2+2*childInertia)*angular.magnitudeSquared(),"candidate kinetic energy conservation");
    require(stage->clearStress(),"rotating clear failed");
    {PxScopedCudaLock lock(*context.cudaContextManager());check(cuMemFree(buffer));check(cuMemFree(indices));}
    body->release();std::puts("native centrifugal fracture: candidate COM motion, momentum and energy checks passed");
}

}
int main(){try{
    blast_demo::SceneCapacity capacity;capacity.maxBodies=64;capacity.maxShapes=64;capacity.maxContactPairs=4096;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,true,false,true,true);
    auto* body=context.physics().createRigidDynamic(PxTransform(PxVec3(0,5,0)));
    auto* shape=context.physics().createShape(PxBoxGeometry(0.5f,0.5f,0.5f),context.material(),true);
    require(body && shape && body->attachShape(*shape),"native material fixture creation failed");shape->release();
    body->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);context.scene().addActor(*body);
    context.scene().simulate(1.0f/60);require(context.scene().fetchResults(true),"warmup failed");
    PxDestructionMaterial m;m.compressionElasticLimit=10;m.compressionFatalLimit=100;m.residualAreaFraction=.8f;
    scenario(context,*body,"gradual/reinforced compression",m,PxVec3(0,-9.81f,0),100,1.0f/60,false,true);
    scenario(context,*body,"gradual/reinforced tension",m,PxVec3(0,9.81f,0),100,1.0f/60,false,true);
    m.residualAreaFraction=0;m.compressionFatalLimit=30;
    scenario(context,*body,"progressive section loss",m,PxVec3(0,-9.81f,0),100,1.0f/60,true);
    m.compressionElasticLimit=1;m.compressionFatalLimit=2;
    scenario(context,*body,"fatal compression",m,PxVec3(0,-9.81f,0),1,1.0f/120,true);
    m.compressionElasticLimit=10;m.compressionFatalLimit=50;m.shearElasticLimit=5;m.shearFatalLimit=25;
    scenario(context,*body,"combined shear and bending",m,PxVec3(8,-3,4),100,1.0f/60,true);
    m=PxDestructionMaterial{};m.compressionElasticLimit=1e12f;m.compressionFatalLimit=2e12f;
    m.crush.capPressure=2;m.crush.cohesion=1000;
    scenario(context,*body,"bond-driven crush",m,PxVec3(0,-9.81f,0),100,1.0f/60,true);
    scenario(context,*body,"crush timestep",m,PxVec3(0,-9.81f,0),100,1.0f/120,true);
    scenario(context,*body,"crush tension cutoff",m,PxVec3(0,9.81f,0),10,1.0f/60,false);
    body->release();rotatingCluster(context);require(context.healthy() && !context.errors().warningCount(),"unexpected PhysX failure");return 0;
}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
