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
//   3. it stays dynamic over ticks until the hand-back: no event for a full
//      period of its slowest motion (per chunk `quiet` against `period`) and the
//      static verdict on its current topology breaks nothing;
//   4. its breaks reach the topology through the corrected pass (correction limit
//      1), where it is not stepped again: its trial forces and verdicts stand;
//   5. its re-bearing contacts are the kernel's (exContactJoint), their states
//      written into the static law's trial (seqApplyBear).
struct DynamicSequence {
    bool enabled=false;PxU32 cur=0;PxU32 n=0,m=0;
    // Persisted, double-buffered: [cur] the tick's start, [cur ^ 1] this tick's.
    PxU32* chunk[2]{};float* v[2]{};float* quiet[2]{};
    PxU32* bond[2]{};float* J[2]{};float* slip[2]{};
    // Per island id: the first submission's dynamic islands, the second's; per
    // chunk: seeds, the hand-back period (s); per bond: the window's re-bearing
    // states and holds; the trial's published forces (for the corrected pass).
    PxU32 *island{},*run{},*breaks{},*seed{},*bear{},*hold{};float* period{};
    PxDestructionVectorPair* forces{};
    template<class T> static void alloc(T*& p,size_t k){if(cudaMalloc(&p,sizeof(T)*std::max<size_t>(k,1))!=cudaSuccess)throw std::runtime_error("dynamic sequence: allocation");cudaMemset(p,0,sizeof(T)*std::max<size_t>(k,1));}
    void allocate(PxU32 chunks,PxU32 bonds) {
        release();n=chunks;m=bonds;
        for(int b=0;b<2;++b){alloc(chunk[b],n);alloc(v[b],6*size_t(n));alloc(quiet[b],n);alloc(bond[b],m);alloc(J[b],6*size_t(m));alloc(slip[b],2*size_t(m));}
        alloc(island,n);alloc(run,n);alloc(breaks,n);alloc(seed,n);alloc(period,n);alloc(bear,m);alloc(hold,m);alloc(forces,m);
        enabled=true;cur=0;
    }
    void release() {
        for(int b=0;b<2;++b){cudaFree(chunk[b]);cudaFree(v[b]);cudaFree(quiet[b]);cudaFree(bond[b]);cudaFree(J[b]);cudaFree(slip[b]);chunk[b]=bond[b]=nullptr;v[b]=quiet[b]=J[b]=slip[b]=nullptr;}
        for(PxU32* p:{island,run,breaks,seed,bear,hold})cudaFree(p);cudaFree(period);cudaFree(forces);
        island=run=breaks=seed=bear=hold=nullptr;period=nullptr;forces=nullptr;enabled=false;
    }
    // A new tick: last tick's state becomes the start; this tick's starts empty.
    void beginTick(cudaStream_t s) {
        cur^=1u;const PxU32 x=cur^1u;
        cudaMemsetAsync(chunk[x],0,sizeof(PxU32)*n,s);cudaMemsetAsync(bond[x],0,sizeof(PxU32)*m,s);
    }
    // The persisted state's pointers in the explicit step's scratch.
    void bind(impact::ExScratch& t) const {
        const PxU32 x=cur^1u;
        t.pChunk=chunk[cur];t.pChunkn=chunk[x];t.pV=v[cur];t.pVn=v[x];t.pQuiet=quiet[cur];t.pQuietn=quiet[x];
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
// state changed), on an island no impact patch decided. run: the islands to step;
// breaks: the islands whose static verdict breaks a joint (the hand-back's test);
// seed: the changed joints' chunks.
__global__ void seqTrigger(const PxDestructionStressBond* bonds,const float* health,const PxDestructionBondVerdict* verdict,
    const PxU32* bearState,const PxU32* bearTrial,const PxU32* bondIslands,const PxU32* impactFlag,PxU32 count,PxU32 islands,
    PxU32* run,PxU32* breaks,PxU32* seed)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    const float area=health[i];if(!(area>0.0f && area<0.5f*FLT_MAX))return;
    const PxU32 island=bondIslands[i];if(island>=islands || (impactFlag && impactFlag[island]))return;
    const bool broke=verdict[i].health<=0.0f;
    const bool moved=bearState && bearTrial && bearState[i]!=bearTrial[i];
    if(!broke && !moved)return;
    run[island]=1u;if(broke)breaks[island]=1u;
    seed[bonds[i].chunk0]=1u;seed[bonds[i].chunk1]=1u;
}
// 1c. An island already dynamic keeps running until the hand-back: quiet for a full
// period of its slowest motion, and its static verdict breaking nothing.
__global__ void seqKeep(const PxU32* nodeIslands,const PxU32* persisted,const float* quiet,const float* period,
    const PxU32* impactFlag,const PxU32* breaks,PxU32 count,PxU32* run)
{
    const PxU32 c=blockIdx.x*blockDim.x+threadIdx.x;if(c>=count || !(persisted[c]&1u))return;
    const PxU32 i=nodeIslands[c];if(i>=count || (impactFlag && impactFlag[i]))return;
    if(!(quiet[c]>=period[c]) || breaks[i])run[i]=1u;
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
