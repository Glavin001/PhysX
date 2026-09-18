#!/usr/bin/env python3
"""Prepare one immutable ownership observation before its first CPU consumer."""
import argparse,difflib,hashlib,json,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];BASE=ROOT/'out/ownership-scheduling-20260915'
parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--name',default='observation-v2');args=parser.parse_args()
if Path(args.name).name!=args.name:parser.error('name must be a directory basename')
tree=BASE/(args.name+'-source');shutil.copytree(BASE/'build-v1/control-source',tree)
name='physx/source/gpudestruction/src/PxgDestructionRuntime.cu';path=tree/name
old=path.read_text();s=old
def replace(old,new):
    global s
    assert s.count(old)==1,old
    s=s.replace(old,new)
replace('    bool mCompatibilityPrepared=false;', '''    bool mCompatibilityPrepared=false;
    // One owned pinned observation, valid only for this preparation. This is
    // CPU registry input, not a physical cache or an authority over GPU owners.
    void* mCompatibilityReadback=nullptr;
    size_t mCompatibilityReadbackCapacity=0;
    PxvDestructionBodyRequest *mObservedReservations=nullptr,*mObservedOwners=nullptr;
    PxU32 *mObservedReservedIndices=nullptr,*mObservedOwnerIndices=nullptr;
    PxDestructionCollisionBinding* mObservedBindings=nullptr;
    PxU32 mObservedReservationCount=0,mObservedOwnerCount=0,mObservedBindingCount=0;
    PxU64 mObservedFrame=0,mObservedCheckpoint=0,mObservedPreparation=0;
    bool mCompatibilityObservationReady=false;
    void reserveCompatibilityObservation(PxU32 reservations,PxU32 owners,PxU32 bindings) {
        if(reservations>mN || owners>mN || bindings>mN)
            throw std::runtime_error("invalid ownership observation extent");
        const auto aligned=[](size_t n){return (n+15)&~size_t(15);};
        const size_t r=aligned(size_t(reservations)*sizeof(PxvDestructionBodyRequest));
        const size_t ri=aligned(size_t(reservations)*sizeof(PxU32));
        const size_t b=aligned(size_t(bindings)*sizeof(PxDestructionCollisionBinding));
        const size_t o=aligned(size_t(owners)*sizeof(PxvDestructionBodyRequest));
        const size_t oi=aligned(size_t(owners)*sizeof(PxU32));
        const size_t bytes=r+ri+b+o+oi;
        if(bytes>mCompatibilityReadbackCapacity) {
            void* next=nullptr;const size_t capacity=std::max(bytes,mCompatibilityReadbackCapacity*2);
            check(cudaMallocHost(&next,capacity));
            // Previous observations finished at their mandatory join. No GPU
            // operation retains this host destination into another preparation.
            cudaFreeHost(mCompatibilityReadback);mCompatibilityReadback=next;
            mCompatibilityReadbackCapacity=capacity;
        }
        auto* p=static_cast<PxU8*>(mCompatibilityReadback);
        mObservedReservations=reservations?reinterpret_cast<PxvDestructionBodyRequest*>(p):nullptr;
        mObservedReservedIndices=reservations?reinterpret_cast<PxU32*>(p+r):nullptr;
        mObservedBindings=bindings?reinterpret_cast<PxDestructionCollisionBinding*>(p+r+ri):nullptr;
        mObservedOwners=owners?reinterpret_cast<PxvDestructionBodyRequest*>(p+r+ri+b):nullptr;
        mObservedOwnerIndices=owners?reinterpret_cast<PxU32*>(p+r+ri+b+o):nullptr;
        mObservedReservationCount=reservations;mObservedOwnerCount=owners;mObservedBindingCount=bindings;
    }
''')
# Explicit resubmission, new solver passes and teardown invalidate the packet.
s=s.replace('mCompatibilityPrepared=false;', 'mCompatibilityPrepared=false;mCompatibilityObservationReady=false;')
# Undo the member declaration replacement; its field is declared below.
s=s.replace('bool mCompatibilityPrepared=false;mCompatibilityObservationReady=false;', 'bool mCompatibilityPrepared=false;')
s=s.replace('mPreparationObserved=false;', 'mPreparationObserved=false;mCompatibilityObservationReady=false;')
s=s.replace('bool mPreparationObserved=false;mCompatibilityObservationReady=false;', 'bool mPreparationObserved=false;')
replace('        mHostCorrectionTargets.clear();mCorrectionEnabled=false;', '''        mHostCorrectionTargets.clear();mCorrectionEnabled=false;
        cudaFreeHost(mCompatibilityReadback);mCompatibilityReadback=nullptr;mCompatibilityReadbackCapacity=0;
        mCompatibilityObservationReady=false;
        mObservedReservations=mObservedOwners=nullptr;mObservedReservedIndices=mObservedOwnerIndices=nullptr;
        mObservedBindings=nullptr;mObservedReservationCount=mObservedOwnerCount=mObservedBindingCount=0;''')
replace('        if(mCompatibilityPrepared)return true;','        if(mCompatibilityPrepared && mCompatibilityObservationReady)return true;')
start=s.index('        std::vector<PxvDestructionBodyRequest> requests(requested);mHostReservedIndices.resize(requested);')
end=s.index('        bool allocated=false;',start)
s=s[:start]+'''        const PxU32 owners=mHostCompletion->correction.count;
        const PxU32 migrating=mHostCompletion->collision.migrating;
        reserveCompatibilityObservation(requested,owners,migrating);
        mHostReservedIndices.resize(requested);
        {
            PxProfileScoped requestProfile(mProfiler,"GpuDestruction.compatibility.ownershipReadback",false,mProfileContext);
            // These immutable descriptors were produced with the current
            // correction inputs, before CPU BodySim construction. Gather once
            // here; applyCorrectionBindings has no remaining GPU producer.
            if(owners)gatherCorrectionOwnerMetadata<<<(owners+127)/128,128,0,mStream>>>(
                mCompactCorrectionBodies,owners,mCandidateSlots,mBodyRequests,mCorrectionOwnerRequests,mCorrectionOwnerTargets);
            check(cudaGetLastError());
            if(requested) {
                check(cudaMemcpyAsync(mObservedReservations,mCompactBodyRequests,requested*sizeof(*mBodyRequests),cudaMemcpyDeviceToHost,mStream));
                check(cudaMemcpyAsync(mObservedReservedIndices,mReturnedBodyIndices,requested*sizeof(PxU32),cudaMemcpyDeviceToHost,mStream));
            }
            if(migrating)check(cudaMemcpyAsync(mObservedBindings,mMigratingCollisionBindings,migrating*sizeof(*mObservedBindings),cudaMemcpyDeviceToHost,mStream));
            if(owners) {
                check(cudaMemcpyAsync(mObservedOwners,mCorrectionOwnerRequests,owners*sizeof(*mObservedOwners),cudaMemcpyDeviceToHost,mStream));
                check(cudaMemcpyAsync(mObservedOwnerIndices,mCorrectionOwnerTargets,owners*sizeof(PxU32),cudaMemcpyDeviceToHost,mStream));
            }
            check(cudaEventRecord(mReady,mStream));check(cudaEventSynchronize(mReady));
            if(requested)std::copy(mObservedReservedIndices,mObservedReservedIndices+requested,mHostReservedIndices.begin());
            mObservedFrame=mHostStatus->frame;mObservedCheckpoint=mCheckpointGeneration;
            mObservedPreparation=mHostBodyPreparation->generation;mCompatibilityObservationReady=true;
        }
''' + s[end:]
replace('allocated=mBodyAllocator && mBodyAllocator->prepare(requests.data(),requested,indices.data());',
    'allocated=mBodyAllocator && mBodyAllocator->prepare(mObservedReservations,requested,mHostReservedIndices.data());')
start=s.index('            Context current(mContext);check(cudaEventSynchronize(mReady));',s.index('    bool applyCorrectionBindings() override'))
end=s.index('\n        }catch(...){mFailed=true;return false;}',start)
s=s[:start]+'''            // CPU binding work consumes the already joined preparation packet.
            // No host verdict is uploaded and no simulation work moves a tick.
            if(!mCompatibilityPrepared || !mCompatibilityObservationReady
                || mObservedFrame!=mHostStatus->frame || mObservedCheckpoint!=mCheckpointGeneration
                || mObservedPreparation!=mHostBodyPreparation->generation
                || mObservedReservationCount!=mHostBodyAllocation.reserved
                || mObservedOwnerCount!=mHostCompletion->correction.count
                || mObservedBindingCount!=mHostCompletion->collision.migrating)return false;
            Context current(mContext);
            mHostCorrectionTargets.resize(mObservedOwnerCount);
            if(mObservedOwnerCount)std::copy(mObservedOwnerIndices,mObservedOwnerIndices+mObservedOwnerCount,mHostCorrectionTargets.begin());
            return mBodyAllocator->applyBindings(mObservedBindings,mObservedBindingCount,
                mObservedOwners,mHostCorrectionTargets.data(),mObservedOwnerCount);''' + s[end:]
# Explicit failure cleanup: partial copy submission may leave no new event.
s=s.replace('bool mCompatibilityObservationReady=false;', 'bool mCompatibilityObservationReady=false;\n    bool mCompatibilityReadbackPending=false;')
s=s.replace('        cudaEventSynchronize(mPreReady);cudaEventSynchronize(mReady);', '        cudaEventSynchronize(mPreReady);cudaEventSynchronize(mReady);\n        // A failed copy submission may not have recorded a new completion event.\n        // Drain the owned stream before releasing its pinned destination.\n        if(mCompatibilityReadbackPending)cudaStreamSynchronize(mStream);\n        mCompatibilityReadbackPending=false;')
s=s.replace('            if(requested) {\n                check(cudaMemcpyAsync(mObservedReservations', '            mCompatibilityReadbackPending=true;\n            if(requested) {\n                check(cudaMemcpyAsync(mObservedReservations')
s=s.replace('            if(requested)std::copy(mObservedReservedIndices', '            mCompatibilityReadbackPending=false;\n            if(requested)std::copy(mObservedReservedIndices')
path.write_text(s)
(BASE/(args.name+'.patch')).write_text(''.join(difflib.unified_diff(old.splitlines(True),s.splitlines(True),fromfile='a/'+name,tofile='b/'+name)))
(BASE/(args.name+'-preparation.json')).write_text(json.dumps(dict(status='prepared_not_built',baseline='13b11af2',source=str(tree),changes={name:hashlib.sha256(path.read_bytes()).hexdigest()}),indent=2)+'\n')
print(tree)
