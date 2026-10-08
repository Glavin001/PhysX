// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
// Included inside the runtime namespace, after PxgDestructionRebearing.cuh.
//
// The dynamic sequence (PX_DESTRUCTION_DYNAMIC_SEQUENCE=1, with the explicit
// impact step; vibe-land FIDELITY_AUDIT C10, docs/calibration/house-headers.md
// "Sequencing (C10)"). The static verdict breaks every overloaded joint of an
// island in one elastic snapshot, including the joints the first failure would
// have relieved: a removal beside a door unzips the wall. Here an island whose
// static verdict would change its topology -- a joint broken, a re-bearing
// contact's fastenings failed, lifted or closed -- is decided by the explicit
// step instead (PxgDestructionImpactExplicit.cuh, "The dynamic sequence"):
//   1. the trigger (trial pass, after the static verdict): such an island, not
//      already an impact patch's, runs a dynamic patch;
//   2. its start: the last accepted forces (the tick before) on the current
//      topology at rest, or, for an island already dynamic, the persisted state
//      of its last window (per bond its force and contact slip, per chunk its
//      velocity): DynamicSequence's start and next buffers, next committed at the
//      next tick's start;
//   3. it stays dynamic over ticks until it freezes: no activity (an event, a
//      contact slipping, opening or closing) for a full period of its slowest
//      motion (exSequencePeriod). A frozen island is not handed back to the static
//      verdict -- its min-norm, bilateral distribution is another of the many
//      friction equilibria, and its re-bearing law would break a contact the window
//      holds stuck, so the island would ping-pong -- it is held at its frozen forces
//      plus the static solve's elastic increment since the freeze (exact by
//      superposition while its topology is the frozen one), and it thaws, resuming
//      from its persisted state, when that carried force reaches an event (a joint at
//      capacity, a contact lifting, sliding or crushing) or its topology changes
//      (seqThaw); freezes and thaws are counted (counters, cycles per chunk);
//   4. its breaks reach the topology through the corrected pass (correction limit
//      1), where it is not stepped again: its trial forces and verdicts stand. An
//      island whose static verdict changes its topology only in the corrected pass
//      (after the trial's split) runs a dynamic patch there, committed in the tick;
//   5. its re-bearing contacts are the kernel's (exContactJoint), their states
//      written into the static law's trial (seqApplyBear).
struct DynamicSequence {
    bool enabled=false;PxU32 cur=0;PxU32 n=0,m=0;
    // Persisted, double-buffered: [cur] the tick's start, [cur ^ 1] this tick's.
    PxU32* chunk[2]{};float* v[2]{};float* quiet[2]{};float* periodBuf[2]{};
    PxU32* bond[2]{};float* J[2]{};float* slip[2]{};
    // Per island id: the first submission's dynamic islands, the second's; per
    // chunk: seeds, the hand-back period (s); per bond: the window's re-bearing
    // states and holds; the trial's published forces (for the corrected pass).
    PxU32 *island{},*run{},*breaks{},*seed{},*bear{},*hold{},*frozen{},*thaw{},*cycles{},*counters{};
    PxDestructionVectorPair *forces{},*frozenForce{},*freezeElastic{};
    // The trial pass's static forces, per frame ([cur] the last frame's: a new dynamic patch's start).
    PxDestructionVectorPair* trialForces[2]{};
    template<class T> static void alloc(T*& p,size_t k){if(cudaMalloc(&p,sizeof(T)*std::max<size_t>(k,1))!=cudaSuccess)throw std::runtime_error("dynamic sequence: allocation");cudaMemset(p,0,sizeof(T)*std::max<size_t>(k,1));}
    void allocate(PxU32 chunks,PxU32 bonds) {
        release();n=chunks;m=bonds;
        for(int b=0;b<2;++b){alloc(chunk[b],n);alloc(v[b],6*size_t(n));alloc(quiet[b],n);alloc(periodBuf[b],n);alloc(bond[b],m);alloc(J[b],6*size_t(m));alloc(slip[b],2*size_t(m));}
        alloc(island,n);alloc(run,n);alloc(breaks,n);alloc(seed,n);alloc(frozen,n);alloc(thaw,n);alloc(cycles,n);alloc(counters,4);
        alloc(bear,m);alloc(hold,m);alloc(forces,m);alloc(frozenForce,m);alloc(freezeElastic,m);alloc(trialForces[0],m);alloc(trialForces[1],m);
        enabled=true;cur=0;
    }
    void release() {
        for(int b=0;b<2;++b){cudaFree(chunk[b]);cudaFree(v[b]);cudaFree(quiet[b]);cudaFree(periodBuf[b]);cudaFree(bond[b]);cudaFree(J[b]);cudaFree(slip[b]);
            chunk[b]=bond[b]=nullptr;v[b]=quiet[b]=periodBuf[b]=J[b]=slip[b]=nullptr;}
        for(PxU32* p:{island,run,breaks,seed,bear,hold,frozen,thaw,cycles,counters})cudaFree(p);
        for(PxDestructionVectorPair* p:{forces,frozenForce,freezeElastic,trialForces[0],trialForces[1]})cudaFree(p);trialForces[0]=trialForces[1]=nullptr;
        island=run=breaks=seed=bear=hold=frozen=thaw=cycles=counters=nullptr;forces=frozenForce=freezeElastic=nullptr;enabled=false;
    }
    // A new tick: last tick's state becomes the start; this tick's starts empty.
    void beginTick(cudaStream_t s) {
        cur^=1u;const PxU32 x=cur^1u;
        cudaMemsetAsync(chunk[x],0,sizeof(PxU32)*n,s);cudaMemsetAsync(bond[x],0,sizeof(PxU32)*m,s);
    }
    // The persisted state's pointers in the explicit step's scratch.
    void bind(impact::ExScratch& t) const {
        const PxU32 x=cur^1u;
        t.pChunk=chunk[cur];t.pChunkn=chunk[x];t.pV=v[cur];t.pVn=v[x];t.pQuiet=quiet[cur];t.pQuietn=quiet[x];t.pPeriod=periodBuf[cur];t.pPeriodn=periodBuf[x];
        t.frozenForce=frozenForce;t.freezeElastic=freezeElastic;t.seqCycles=cycles;t.seqCounters=counters;t.seqBase=trialForces[cur];
        t.pBond=bond[cur];t.pBondn=bond[x];t.pJ=J[cur];t.pJn=J[x];t.pSlip=slip[cur];t.pSlipn=slip[x];
        t.seqBear=bear;t.seqHold=hold;t.seqSeed=seed;
    }
    const PxU32* startChunks() const {return chunk[cur];}
    const PxU32* tickChunks() const {return chunk[cur^1u];}
};
// 1a. The islands already dynamic (their persisted chunks), and those chunks as seeds.
__global__ void seqMarkPersisted(const PxU32* nodeIslands,const PxU32* persisted,PxU32 count,PxU32* island,PxU32* seed)
{
    const PxU32 c=blockIdx.x*blockDim.x+threadIdx.x;if(c>=count)return;
    seed[c]=0u;
    if(!(persisted[c]&1u))return;
    seed[c]=1u;const PxU32 i=nodeIslands[c];if(i<count)island[i]=1u;
}
// 1b. The trigger: per bond the static verdict's change (broken; its re-bearing
// state changed), on an island no impact patch decided and not frozen. run: the islands
// to step; breaks: the islands whose static verdict breaks a joint (diagnostics);
// seed: the changed joints' chunks.
__global__ void seqTrigger(const PxDestructionStressBond* bonds,const float* health,const PxDestructionBondVerdict* verdict,
    const PxU32* bearState,const PxU32* bearTrial,const PxU32* bondIslands,const PxU32* impactFlag,const PxU32* frozen,PxU32 count,PxU32 islands,
    PxU32* run,PxU32* breaks,PxU32* seed)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    const float area=health[i];if(!(area>0.0f && area<0.5f*FLT_MAX))return;
    // (a frozen island answers to its carried forces, not to the static verdict: seqThaw)
    const PxU32 island=bondIslands[i];if(island>=islands || (impactFlag && impactFlag[island]) || (frozen && frozen[island]))return;
    const bool broke=verdict[i].health<=0.0f;
    const bool moved=bearState && bearTrial && bearState[i]!=bearTrial[i];
    if(!broke && !moved)return;
    run[island]=1u;if(broke)breaks[island]=1u;
    seed[bonds[i].chunk0]=1u;seed[bonds[i].chunk1]=1u;
}
// 1c. An island already dynamic, not frozen, keeps running.
__global__ void seqKeep(const PxU32* nodeIslands,const PxU32* persisted,const PxU32* impactFlag,PxU32 count,PxU32* run)
{
    const PxU32 c=blockIdx.x*blockDim.x+threadIdx.x;if(c>=count || (persisted[c]&3u)!=1u)return;
    const PxU32 i=nodeIslands[c];if(i<count && !(impactFlag && impactFlag[i]))run[i]=1u;
}
// 1d. The frozen islands (a frozen chunk's; an impact patch has already thawed one into
// a dynamic patch).
__global__ void seqMarkFrozen(const PxU32* nodeIslands,const PxU32* persisted,const PxU32* impactFlag,PxU32 count,PxU32* frozen)
{
    const PxU32 c=blockIdx.x*blockDim.x+threadIdx.x;if(c>=count || !(persisted[c]&2u))return;
    const PxU32 i=nodeIslands[c];if(i<count && !(impactFlag && impactFlag[i]))frozen[i]=1u;
}
// The carried force of a frozen joint (solver frame): frozen plus the elastic increment.
__device__ __forceinline__ PxDestructionVectorPair seqCarried(const PxDestructionVectorPair& f,const PxDestructionVectorPair& a,const PxDestructionVectorPair& z)
{
    PxDestructionVectorPair c;c.linear=f.linear+(a.linear-z.linear);c.angular=f.angular+(a.angular-z.angular);return c;
}
// 1e. The thaw: a frozen island's joint whose carried force reaches an event (a bond at
// capacity within the band; a contact lifting, sliding past mu C, crushing), or that its
// topology lost (broken since the freeze: no longer a member), thaws its island.
__global__ void seqThaw(impact::Inputs in,impact::Settings s,const PxU32* persistedBond,const PxDestructionVectorPair* frozenForce,
    const PxDestructionVectorPair* freezeElastic,const PxU32* frozen,PxU32* thaw)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=in.bondCount || !(persistedBond[i]&4u))return;
    const PxU32 island=in.bondIslands[i];if(island>=in.chunkCount || !frozen[island])return;
    impact::Bond b;
    if(!impact::bondMember(in,i) || !impact::prepareBond(in,s,i,b)){thaw[island]=1u;return;}
    float x[6];impact::toLocal(b,seqCarried(frozenForce[i],in.elastic[i],freezeElastic[i]),x);
    const float band=s.capacityBand;bool event;
    if(persistedBond[i]&2u) {
        const float C=-x[0],V=sqrtf(x[1]*x[1]+x[2]*x[2]),T=fabsf(x[3]);
        const float bend=b.g0>0.0f?b.g0*fabsf(x[4])+b.g1*fabsf(x[5]):b.gb*sqrtf(x[4]*x[4]+x[5]*x[5]);
        event=!(C>0.0f) || V+b.gt*T>impact::exContactMu(b,s.dynamicFriction)*C || bend+C>=(1.0f-band)*b.capC;
    } else event=impact::utilisation(b,x)>=1.0f-band;
    if(event)thaw[island]=1u;
}
// 1f. Each frozen island: thawed (run as a dynamic patch from its persisted state), or held.
__global__ void seqResolveFrozen(const PxU32* frozen,const PxU32* thaw,PxU32 count,PxU32* run,PxU32* counters)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count || !frozen[i])return;
    if(thaw[i]){run[i]=1u;atomicAdd(counters+1,1u);}else atomicAdd(counters+2,1u);
}
// 1g. A held frozen island: its carried forces stand (the impact view, its contacts held),
// and its state carries over to the next tick.
__global__ void seqHoldFrozenBonds(const PxU32* bondIslands,const PxU32* frozen,const PxU32* thaw,const PxU32* persistedBond,
    const PxDestructionVectorPair* elastic,const PxDestructionVectorPair* frozenForce,const PxDestructionVectorPair* freezeElastic,
    const float* J,const float* slip,PxU32* bondNext,float* Jn,float* slipNext,PxDestructionVectorPair* forces,PxU32* verdict,PxU32* hold,PxU32 count,PxU32 islands)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    const PxU32 island=bondIslands[i];if(island>=islands || !frozen[island] || thaw[island])return;
    const PxU32 st=persistedBond[i];if(!(st&1u))return;
    forces[i]=(st&4u)?seqCarried(frozenForce[i],elastic[i],freezeElastic[i]):elastic[i];verdict[i]=impact::eHELD;hold[i]=(st&2u)?1u:0u;
    bondNext[i]=st;for(int q=0;q<6;++q)Jn[6*size_t(i)+q]=J[6*size_t(i)+q];slipNext[2*size_t(i)]=slip[2*size_t(i)];slipNext[2*size_t(i)+1]=slip[2*size_t(i)+1];
}
__global__ void seqHoldFrozenChunks(const PxU32* nodeIslands,const PxU32* frozen,const PxU32* thaw,const PxU32* chunk,const float* v,const float* quiet,const float* period,
    PxU32* chunkNext,float* vNext,float* quietNext,float* periodNext,PxU32* islandFlag,PxU32 count,float dt)
{
    const PxU32 c=blockIdx.x*blockDim.x+threadIdx.x;if(c>=count || !(chunk[c]&2u))return;
    const PxU32 i=nodeIslands[c];if(i>=count || !frozen[i] || thaw[i])return;
    chunkNext[c]=chunk[c];for(int q=0;q<6;++q)vNext[6*size_t(c)+q]=v[6*size_t(c)+q];quietNext[c]=quiet[c]+dt;periodNext[c]=period[c];
    islandFlag[i]=1u;
}
// 3b. The window's re-bearing states into the static law's trial (after rebearVerdicts).
__global__ void seqApplyBear(const PxU32* bear,PxU32* trial,PxU32 count)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i<count && bear[i]!=0xffffffffu)trial[i]=bear[i];
}
// 4. The corrected pass: the trial's dynamic islands (now renumbered) keep the
// trial window's forces and verdicts (every live joint held; its breaks are applied).
__global__ void seqHoldMark(const PxU32* nodeIslands,const PxU32* tick,const PxU32* impactFlag,PxU32 count,PxU32* mark)
{
    const PxU32 c=blockIdx.x*blockDim.x+threadIdx.x;if(c>=count || !(tick[c]&1u))return;
    const PxU32 i=nodeIslands[c];if(i<count && !(impactFlag && impactFlag[i]))mark[i]=1u;
}
__global__ void seqHoldBonds(const PxU32* bondIslands,const PxU32* mark,const PxDestructionVectorPair* saved,
    PxDestructionVectorPair* forces,PxU32* verdict,PxU32 count,PxU32 islands)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    const PxU32 island=bondIslands[i];if(island>=islands || !mark[island])return;
    forces[i]=saved[i];verdict[i]=impact::eHELD;
}
__global__ void seqHoldIslands(const PxU32* mark,PxU32* islandFlag,PxU32 count)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i<count && mark[i])islandFlag[i]=1u;
}
// 2b. A submission's dynamic islands are done: the next round (the islands past the
// evaluation's kExPatches slots) takes the rest.
__global__ void seqDoneIslands(impact::ExScratch t,PxU32* run,PxU32 count)
{
    const PxU32 p=threadIdx.x;if(p>=*t.patchCount)return;
    const PxU32 i=t.patches[p].island;if(i<count)run[i]=0u;
}
