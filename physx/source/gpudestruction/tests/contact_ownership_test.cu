// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#include <cuda_runtime.h>
#include "../src/PxgDestructionContactOwnership.cuh"
#include <algorithm>
#include <cstdio>
#include <cstring>
#include <stdexcept>
#include <vector>
using namespace physx;
void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}
void require(bool ok,const char* why){if(!ok)throw std::runtime_error(why);}
template<class T> struct Device {
    T* p=nullptr;explicit Device(size_t n){check(cudaMalloc(&p,std::max(size_t(1),n)*sizeof(T)));}
    ~Device(){cudaFree(p);}
    void put(const std::vector<T>& v){if(!v.empty())check(cudaMemcpy(p,v.data(),v.size()*sizeof(T),cudaMemcpyHostToDevice));}
    std::vector<T> get(size_t n){std::vector<T> v(n);if(n)check(cudaMemcpy(v.data(),p,n*sizeof(T),cudaMemcpyDeviceToHost));return v;}
};
int main(){try{
    constexpr PxU32 n=1025;
    std::vector<PxgContactGraphIdentity> ids(n);
    std::vector<PxsContactManagerOutput> outputs(n);
    std::vector<PxReal> rest(n);
    std::vector<PxsTorsionalFrictionData> torsion(n);
    for(PxU32 i=0;i<n;++i){
        ids[i]={13+i,0,123456+i};rest[i]=float(i);
        torsion[i]=PxsTorsionalFrictionData(float(i),float(i+1));
        outputs[i]={};outputs[i].nbContacts=17;outputs[i].nbPatches=3;outputs[i].prevPatches=3;
        outputs[i].statusFlag=i%2?PxsContactManagerStatusFlag::eHAS_TOUCH:PxsContactManagerStatusFlag::eHAS_NO_TOUCH;
        outputs[i].contactForces=reinterpret_cast<PxReal*>(size_t(0x1234));
    }
    Device<PxgContactGraphIdentity> dIds(n);dIds.put(ids);
    Device<PxsContactManagerOutput> dOutputs(n);dOutputs.put(outputs);
    Device<PxReal> dRest(n);dRest.put(rest);
    Device<PxsTorsionalFrictionData> dTorsion(n);dTorsion.put(torsion);
    constexpr PxU32 words=257;
    std::vector<PxgContactManagerInput> inputs(n);
    std::vector<PxU32> manifolds(n*words),empty(words);
    for(PxU32 i=0;i<n;++i)inputs[i]={10000+2*i,10001+2*i,2*i,2*i+1};
    for(PxU32 i=0;i<words;++i)empty[i]=0xc0000000+i;
    for(PxU32 i=0;i<manifolds.size();++i)manifolds[i]=i;
    Device<PxgContactManagerInput> dInputs(n);dInputs.put(inputs);
    Device<PxU32> dManifolds(manifolds.size()),dEmpty(words);dManifolds.put(manifolds);dEmpty.put(empty);
    Device<PxgContactGraphSequence> sequence(1);sequence.put({{900001,0,0}});
    const std::vector<PxU32> selected={0,1,31,32,255,256,511,512,1023,1024};
    for(PxU32 pass=0;pass<3;++pass){
        std::vector<PxgDestructionContactOwnerUpdate> changes;
        for(PxU32 i:selected){
            PxgDestructionContactOwnerUpdate u={};
            u.identity=dIds.p+i;u.output=dOutputs.p+i;u.rest=dRest.p+i;u.torsion=dTorsion.p+i;
            u.oldEdge=ids[i].edgeIndex;u.newEdge=5000+pass*n+i;u.flags=57;
            u.restDistance=-float(i);u.torsionalRadius=3;u.minTorsionalRadius=2;
            const bool reverse=pass==1 || (pass==0 && i%2);
            u.input=dInputs.p+i;u.transform0=inputs[i].transformCacheRef0;u.transform1=inputs[i].transformCacheRef1;
            u.manifold=dManifolds.p+i*words;u.emptyManifold=dEmpty.p;u.manifoldBytes=words*sizeof(PxU32);
            if(i%3==0){u.manifoldBytes=0;u.manifold=nullptr;u.emptyManifold=nullptr;}
            u.baseStatus=i%2?PxsContactManagerStatusFlag::eREQUEST_CONSTRAINTS:PxsContactManagerStatusFlag::eSTATIC_OR_KINEMATIC;
            if(reverse) {
                std::swap(u.transform0,u.transform1);
                std::swap(inputs[i].shapeRef0,inputs[i].shapeRef1);
                std::swap(inputs[i].transformCacheRef0,inputs[i].transformCacheRef1);
                if(u.manifoldBytes)std::copy(empty.begin(),empty.end(),manifolds.begin()+i*words);
            }
            changes.push_back(u);
            ids[i].edgeIndex=u.newEdge;
            outputs[i]={};outputs[i].statusFlag=PxU8(u.baseStatus|PxsContactManagerStatusFlag::eDIRTY_MANAGER);outputs[i].flags=u.flags;
            rest[i]=u.restDistance;torsion[i]=PxsTorsionalFrictionData(3,2);
        }
        if(pass%2)std::reverse(changes.begin(),changes.end());
        Device<PxgDestructionContactOwnerUpdate> update(changes.size());update.put(changes);
        destructionContactOwnership::validate<<<1,128>>>(update.p,PxU32(changes.size()),sequence.p);
        destructionContactOwnership::apply<<<changes.size(),128>>>(update.p,PxU32(changes.size()),sequence.p);
        check(cudaGetLastError());check(cudaDeviceSynchronize());
        const auto actualIds=dIds.get(n);const auto actualOutput=dOutputs.get(n);const auto actualTorsion=dTorsion.get(n);
        require(!std::memcmp(actualIds.data(),ids.data(),n*sizeof(ids[0])),"ownership changed a lifetime or untouched identity");
        require(!std::memcmp(actualOutput.data(),outputs.data(),n*sizeof(outputs[0])),"cached solver output survived or unrelated output changed");
        require(dRest.get(n)==rest && !std::memcmp(actualTorsion.data(),torsion.data(),n*sizeof(torsion[0])),"contact properties were lost or unrelated properties changed");
        const auto actualInputs=dInputs.get(n);
        require(!std::memcmp(actualInputs.data(),inputs.data(),n*sizeof(inputs[0])),"GPU contact endpoint order disagrees with canonical actor order");
        require(dManifolds.get(manifolds.size())==manifolds,"oriented PCM survived reversal or unchanged PCM was overwritten");
        require(sequence.get(1)[0].next==900001 && sequence.get(1)[0].error==0,"ownership consumed pair lifetimes");
    }
    // A stale entry after a valid one must reject the whole batch, then remain
    // latched when a later caller tries to apply without resetting the scene.
    std::vector<PxgDestructionContactOwnerUpdate> bad(2);
    for(PxU32 i=0;i<2;++i)bad[i]={dIds.p+i,dOutputs.p+i,dRest.p+i,dTorsion.p+i,ids[i].edgeIndex,80000+i,0,0,0,0,0};
    for(PxU32 i=0;i<2;++i) {
        bad[i].input=dInputs.p+i;bad[i].transform0=inputs[i].transformCacheRef0;bad[i].transform1=inputs[i].transformCacheRef1;
        bad[i].manifold=dManifolds.p+i*words;bad[i].emptyManifold=dEmpty.p;bad[i].manifoldBytes=words*sizeof(PxU32);
    }
    bad[1].oldEdge=999999;
    Device<PxgDestructionContactOwnerUpdate> update(2);update.put(bad);
    destructionContactOwnership::validate<<<1,128>>>(update.p,2,sequence.p);
    destructionContactOwnership::apply<<<2,128>>>(update.p,2,sequence.p);
    check(cudaDeviceSynchronize());
    require(sequence.get(1)[0].error==2,"stale owner identity did not latch a scene failure");
    const auto unchanged=dIds.get(n);const auto unchangedOutput=dOutputs.get(n);
    require(!std::memcmp(unchanged.data(),ids.data(),n*sizeof(ids[0])) && !std::memcmp(unchangedOutput.data(),outputs.data(),n*sizeof(outputs[0])),"invalid ownership batch partially committed");
    destructionContactOwnership::apply<<<1,128>>>(update.p,1,sequence.p);check(cudaDeviceSynchronize());
    require(dIds.get(n)[0].edgeIndex==ids[0].edgeIndex,"failed scene accepted a subsequent owner change");
    std::puts("GPU contact ownership passed: 1025 persistent pairs, sparse/tail updates, repeat endpoints, unchanged lifetimes, endpoint reversal, cooperative PCM invalidation and atomic stale-batch rejection");return 0;
}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
