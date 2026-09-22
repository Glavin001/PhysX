#pragma once
// Optional read-only contact-manager audit for native_wall_capture.
// Use after successful fetchResults + existing device-view readyEvent wait.
#include "PxPhysicsAPI.h"
#include "NpShape.h"
#include "ScShapeSim.h"
#include "ScShapeInteraction.h"
#include "ScElementSimInteraction.h"
#include "PxsContactManager.h"
#include "PxgNarrowphaseCore.h"
#include "PxgSolverCore.h"
#include "PxcNpThreadContext.h"
#include <cuda.h>
#include <vector>
#include <stdexcept>

namespace wall_pair_audit {
using namespace physx;
struct InteractionRecord {
    PxU32 type=0,shape0=0,shape1=0,pairFlags=0,npIndex=PX_INVALID_U32;
    bool hasManager=false,hasTouch=false;PxU32 workFlags=0,workStatusFlags=0;
};
struct ManagerRecord {
    bool newBucket=false,storageReady=false,mergedObserved=false;
    PxU32 mergedIndex=PX_INVALID_U32;PxU64 expectedEpoch=0;
    PxgContactManagerInput mergedInput{};
    PxsContactManagerOutput mergedOutput{};
    bool forcesObserved=false;std::vector<PxReal> forces;
    PxU32 index=0,npIndex=PX_INVALID_U32;
    PxgContactManagerInput input{};
    PxsContactManagerOutput output{};
};
struct Record {
    PxU32 shape0=0,shape1=0;
    bool sameCpuOwner=false;
    std::vector<InteractionRecord> interactions;
    std::vector<ManagerRecord> managers;
};
inline void require(bool ok,const char* message) {
    if(!ok)throw std::runtime_error(message);
}
inline Record read(PxShape& a,PxShape& b,PxCudaContextManager& cuda,PxgGpuNarrowphaseCore& np) {
    auto* sa=static_cast<NpShape&>(a).getCore().getExclusiveSim();
    auto* sb=static_cast<NpShape&>(b).getCore().getExclusiveSim();
    require(sa && sb,"pair audit needs exclusive native shapes");
    std::vector<const Sc::ShapeInteraction*> liveMatches;
    Record result;result.shape0=sa->getElementID();result.shape1=sb->getElementID();
    auto& owner=sa->getActor();result.sameCpuOwner=&owner==&sb->getActor();
    const auto count=owner.getActorInteractionCount();auto** interactions=owner.getActorInteractions();
    for(PxU32 i=0;i<count;++i) {
        const auto* interaction=interactions[i];const auto type=interaction->getType();
        if(type!=Sc::InteractionType::eOVERLAP && type!=Sc::InteractionType::eMARKER
            && type!=Sc::InteractionType::eTRIGGER)continue;
        const auto* element=static_cast<const Sc::ElementSimInteraction*>(interaction);
        if(!((&element->getElement0()==sa && &element->getElement1()==sb)
            || (&element->getElement0()==sb && &element->getElement1()==sa)))continue;
        InteractionRecord row;row.type=PxU32(type);row.shape0=element->getElement0().getElementID();row.shape1=element->getElement1().getElementID();
        if(type==Sc::InteractionType::eOVERLAP) {
            const auto* si=static_cast<const Sc::ShapeInteraction*>(interaction);
            liveMatches.push_back(si);
            const auto* manager=si->getContactManager();row.hasManager=manager!=nullptr;
            row.hasTouch=si->hasTouch()!=0;row.pairFlags=si->getPairFlags();
            if(manager){row.npIndex=manager->getWorkUnit().mNpIndex;row.workFlags=manager->getWorkUnit().mFlags;row.workStatusFlags=manager->getWorkUnit().mStatusFlags;}
        }
        result.interactions.push_back(row);
    }
    // Box/box lives in eBoxBox. Match shape identities via the CPU interaction
    // mirror; never trust stale native host shapeRef geometry descriptors.
    PxScopedCudaLock lock(cuda);
    for(PxU32 phase=0;phase<2;++phase) {
        const auto bucket=GPU_BUCKET_ID::eBoxBox;
        const PxgContactManagers& host=phase?np.getNewContactManagers(bucket):np.getExistingContactManagers(bucket);
        const auto& device=phase?np.getNewGpuContactManagers(bucket):np.getExistingGpuContactManagers(bucket);
        require(host.mShapeInteractions.size()==host.mCpuContactManagerMapping.size(),"pair audit inconsistent host mirrors");
        for(PxU32 i=0;i<host.mShapeInteractions.size();++i) {
            bool retired=false;
            if(!phase && np.mRemovedIndices[bucket]) {
                const auto& removed=*np.mRemovedIndices[bucket];
                for(PxU32 k=0;k<removed.size();++k)if(removed[k]==i)retired=true;
            }
            if(retired)continue;
            const auto* si=host.mShapeInteractions[i];bool matchesLive=false;
            for(const auto* live:liveMatches)if(si==live)matchesLive=true;
            // A pending removed mirror can hold a stale pointer. Compare only
            // to validated live interaction pointers; never dereference it.
            if(!matchesLive)continue;
            ManagerRecord row;row.newBucket=phase!=0;row.index=i;
            const auto* manager=host.mCpuContactManagerMapping[i];
            if(manager)row.npIndex=manager->getWorkUnit().mNpIndex;
            row.storageReady=!phase && manager && row.npIndex==host.computeId(i)
                && PxU64(i)<device.mContactManagerInputData.getSize()/sizeof(row.input)
                && PxU64(i)<device.mContactManagerOutputData.getSize()/sizeof(row.output)
                && device.mContactManagerInputData.getDevicePtr()!=0 && device.mContactManagerOutputData.getDevicePtr()!=0;
            if(row.storageReady) {
                require(cuMemcpyDtoH(&row.input,device.mContactManagerInputData.getDevicePtr()+PxU64(i)*sizeof(row.input),sizeof(row.input))==CUDA_SUCCESS
                    && cuMemcpyDtoH(&row.output,device.mContactManagerOutputData.getDevicePtr()+PxU64(i)*sizeof(row.output),sizeof(row.output))==CUDA_SUCCESS,
                    "pair audit GPU manager read failed");
            }
            row.expectedEpoch=np.mGpuContext->getGpuSolverCore()->mNativeResponseEpoch;
            if(row.storageReady) {
                PxU64 mergedIndex=i;bool pending=false;
                for(PxU32 b=GPU_BUCKET_ID::eConvex;b<=PxU32(bucket);++b) {
                    const auto type=GPU_BUCKET_ID::Enum(b);
                    pending|=np.getNewContactManagers(type).mCpuContactManagerMapping.size()!=0;
                    if(b<PxU32(bucket))mergedIndex+=np.getExistingContactManagers(type).mCpuContactManagerMapping.size();
                }
                const auto& merged=np.getExistingGpuContactManagers(GPU_BUCKET_ID::eConvex);
                if(!pending && mergedIndex<np.mTotalNumPairs
                    && mergedIndex<merged.mContactManagerInputData.getSize()/sizeof(row.mergedInput)
                    && mergedIndex<merged.mContactManagerOutputData.getSize()/sizeof(row.mergedOutput)
                    && mergedIndex<merged.mShapeInteractions.getSize()/sizeof(Sc::ShapeInteraction*)) {
                    row.mergedIndex=PxU32(mergedIndex);const Sc::ShapeInteraction* observed=nullptr;
                    require(cuMemcpyDtoH(&row.mergedInput,merged.mContactManagerInputData.getDevicePtr()+mergedIndex*sizeof(row.mergedInput),sizeof(row.mergedInput))==CUDA_SUCCESS
                        && cuMemcpyDtoH(&row.mergedOutput,merged.mContactManagerOutputData.getDevicePtr()+mergedIndex*sizeof(row.mergedOutput),sizeof(row.mergedOutput))==CUDA_SUCCESS
                        && cuMemcpyDtoH(&observed,merged.mShapeInteractions.getDevicePtr()+mergedIndex*sizeof(observed),sizeof(observed))==CUDA_SUCCESS,
                        "pair audit merged manager read failed");
                    row.mergedObserved=observed==si
                        && row.mergedInput.transformCacheRef0==row.input.transformCacheRef0
                        && row.mergedInput.transformCacheRef1==row.input.transformCacheRef1
                        && row.mergedInput.shapeRef0==row.input.shapeRef0
                        && row.mergedInput.shapeRef1==row.input.shapeRef1;
                }
            }
            if(row.mergedObserved && row.expectedEpoch && row.mergedOutput.nativeResponseEpoch==row.expectedEpoch
                && row.mergedOutput.nbContacts && row.mergedOutput.contactForces) {
                auto& pool=np.mGpuContext->getForceStreamPool();
                const auto token=reinterpret_cast<uintptr_t>(row.mergedOutput.contactForces);
                const auto cpuBase=reinterpret_cast<uintptr_t>(pool.mDataStream);
                const PxU64 capacity=PxMin(PxU64(pool.mDataStreamSize),np.mGpuContext->getGpuSolverCore()->mForceBuffer.getSize());
                const PxU64 bytes=PxU64(row.mergedOutput.nbContacts)*sizeof(PxReal);
                if(cpuBase && token>=cpuBase && (token-cpuBase)%sizeof(PxReal)==0
                    && bytes<=capacity && token-cpuBase<=capacity-bytes && np.mForceAndIndiceStream) {
                    row.forces.resize(row.mergedOutput.nbContacts);
                    require(cuMemcpyDtoH(row.forces.data(),np.mForceAndIndiceStream+(token-cpuBase),bytes)==CUDA_SUCCESS,
                        "pair audit force read failed");row.forcesObserved=true;
                }
            }
            result.managers.push_back(row);
        }
    }
    return result;
}
} // namespace wall_pair_audit
