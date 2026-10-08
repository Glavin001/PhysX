// A captured impact-solve evaluation (the stage's PX_DESTRUCTION_IMPACT_CAPTURE)
// through the impact solve again, timed, with every solve's record: what an
// impact tick costs and why (island sizes, levels, rounds, iterations).
//
//   destruction_impact_capture_replay CAPTURE.impc [runs]
//
// Settings overrides (A/B, diagnostics): IMPACT_ITERATIONS, IMPACT_INNER,
// IMPACT_TOLERANCE, IMPACT_RAMP_FACTOR, IMPACT_RAMP_LEVELS, IMPACT_MAX_ROUNDS,
// IMPACT_COUPLED (0/1). IMPACT_QUIET=1 prints the summary only.
#include "PxDestructionScene.h"
#include "NvBlastExtStressMaterialFormula.h"
#include <cuda_runtime.h>
#include <algorithm>
#include <cfloat>
#include <chrono>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <stdexcept>
#include <vector>
namespace physx { namespace {
using namespace Nv::Blast;
void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}
template<class T>void allocate(T*& p,size_t n){check(cudaMalloc(&p,std::max(size_t(1),n)*sizeof(T)));}
#include "../src/PxgDestructionImpact.cuh"
#include "../src/PxgDestructionImpactCapture.cuh"
// Every bond whose elastic forces are past the impact solve's capacity (the
// trigger), with what it is: IMPACT_TRIGGER_REPORT=1.
struct TriggerRow { PxU32 bond,material,chunk0,chunk1; float utilisation,area,live,s0,s1,zt,g0,g1,gb,gt,N,V,T,M0,M1; };
__global__ void triggerReport(impact::Inputs in,impact::Settings s,TriggerRow* out,PxU32* count,PxU32 capacity)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=in.bondCount)return;
    if(in.bondIslands[i]>=in.chunkCount || !impact::bondMember(in,i))return;
    impact::Bond b;if(!impact::prepareBond(in,s,i,b))return;
    float x[6];impact::toLocal(b,in.elastic[i],x);
    const float u=impact::utilisation(b,x);if(u<1.0f)return;
    const PxU32 k=atomicAdd(count,1u);if(k>=capacity)return;
    const auto bond=in.bonds[i];const auto sec=in.sections?in.sections[i]:PxDestructionBondSection{};
    out[k]={i,bond.material,bond.chunk0,bond.chunk1,u,bond.area,in.health[i],sec.bendModulus0,sec.bendModulus1,sec.twistModulus,b.g0,b.g1,b.gb,b.gt,
        x[0],sqrtf(x[1]*x[1]+x[2]*x[2]),x[3],x[4],x[5]};
}
struct File {
    FILE* f;explicit File(const char* path):f(std::fopen(path,"rb")){if(!f)throw std::runtime_error("cannot open capture");}
    ~File(){std::fclose(f);}
    template<class T>std::vector<T> read(size_t n){std::vector<T> v(n);if(n && std::fread(v.data(),sizeof(T),n,f)!=n)throw std::runtime_error("short capture");return v;}
    template<class T>T one(){return read<T>(1)[0];}
};
template<class T>T* upload(const std::vector<T>& v){T* p;allocate(p,v.size());if(!v.empty())check(cudaMemcpy(p,v.data(),v.size()*sizeof(T),cudaMemcpyHostToDevice));return p;}
float env(const char* name,float fallback){const char* v=std::getenv(name);return v && *v?float(std::atof(v)):fallback;}
int run(int argc,char** argv){
    if(argc<2){std::fprintf(stderr,"usage: %s CAPTURE.impc [runs]\n",argv[0]);return 2;}
    File f(argv[1]);
    const auto h=f.one<impact::CaptureHeader>();
    if(std::memcmp(h.magic,"IMPC",4) || h.version!=1 || h.settingsBytes>sizeof(impact::Settings))throw std::runtime_error("not a capture of this build");
    // Settings appended since the capture keep their defaults.
    impact::Settings s{};{const auto raw=f.read<unsigned char>(h.settingsBytes);std::memcpy(&s,raw.data(),h.settingsBytes);}
    s.iterations=PxU32(env("IMPACT_ITERATIONS",float(s.iterations)));s.innerIterations=PxU32(env("IMPACT_INNER",float(s.innerIterations)));
    s.tolerance=env("IMPACT_TOLERANCE",s.tolerance);s.rampFactor=env("IMPACT_RAMP_FACTOR",s.rampFactor);
    s.rampLevels=PxU32(env("IMPACT_RAMP_LEVELS",float(s.rampLevels)));s.maxRounds=PxU32(env("IMPACT_MAX_ROUNDS",float(s.maxRounds)));
    s.coupledContact=env("IMPACT_COUPLED",s.coupledContact?1.0f:0.0f)!=0.0f;
    s.evaluationIterations=PxU32(env("IMPACT_EVAL_ITERATIONS",float(s.evaluationIterations)));
    s.relaxation=env("IMPACT_RELAXATION",s.relaxation);
    s.innerTolerance=env("IMPACT_INNER_TOLERANCE",s.innerTolerance);
    s.andersonDepth=PxU32(env("IMPACT_ANDERSON",float(s.andersonDepth)));
    const PxU32 n=h.n,m=h.m;
    impact::Inputs in{};in.chunkCount=n;in.bondCount=m;
    in.chunks=upload(f.read<PxDestructionStressChunk>(n));in.bonds=upload(f.read<PxDestructionStressBond>(m));
    in.materials=upload(f.read<PxDestructionMaterial>(h.materials));
    if(h.flags&impact::eCAPTURE_SLIP)in.ductileSlip=upload(f.read<float>(h.materials));
    if(h.flags&impact::eCAPTURE_STIFFNESS)in.stiffness=upload(f.read<float>(h.materials));
    in.health=upload(f.read<float>(m));
    in.nodeBegin=upload(f.read<PxU32>(size_t(n)+1));
    const PxU32 refs=f.one<PxU32>();in.nodeRefs=upload(f.read<PxU32>(refs));
    const auto nodeIslands=f.read<PxU32>(n),bondIslands=f.read<PxU32>(m);
    in.nodeIslands=upload(nodeIslands);in.bondIslands=upload(bondIslands);
    in.accelerations=upload(f.read<PxDestructionVectorPair>(n));in.elastic=upload(f.read<PxDestructionVectorPair>(m));
    in.base=upload(f.read<PxDestructionVectorPair>(m));
    if(h.flags&impact::eCAPTURE_ELASTIC_BASE)in.elasticBase=upload(f.read<PxDestructionVectorPair>(m));
    if(h.flags&impact::eCAPTURE_CRUSHED)in.crushed=upload(f.read<PxDestructionCrushState>(n));
    if(h.flags&impact::eCAPTURE_SECTIONS)in.sections=upload(f.read<PxDestructionBondSection>(m));
    std::vector<float> zero(6*size_t(std::max(h.rows,1u)),0.0f);
    std::vector<impact::ContactRow> hostRows;
    if(h.flags&impact::eCAPTURE_ROWS){hostRows=f.read<impact::ContactRow>(h.rows);in.rows=upload(hostRows);in.rowCount=h.rows;in.rowDelta=upload(zero);in.rowForce=upload(zero);}
    if(h.flags&impact::eCAPTURE_CARRIED)in.carried=upload(f.read<PxU32>(m));
    if(h.flags&impact::eCAPTURE_SLIP_BEFORE)in.slipBefore=upload(f.read<float>(m));
    in.stage=upload(std::vector<PxDestructionStageStatus>(1));
    cudaStream_t stream;check(cudaStreamCreateWithFlags(&stream,cudaStreamNonBlocking));
    impact::Stage e;e.allocate(n,m);
    impact::SolveRecord* log;allocate(log,impact::kLogCapacity);e.w.log=log;
    float* trace=nullptr;if(std::getenv("IMPACT_TRACE")){allocate(trace,4*size_t(impact::kTraceCapacity));check(cudaMemset(trace,0,sizeof(float)*4*impact::kTraceCapacity));e.w.trace=trace;if(const char* v=std::getenv("IMPACT_TRACE_SOLVE"))e.w.traceSolve=PxU32(std::atoi(v));}
    float* linkRes=nullptr;const size_t links=size_t(m)+impact::kContactCapacity;
    if(trace){allocate(linkRes,6*links);check(cudaMemset(linkRes,0,sizeof(float)*6*links));e.w.linkResidual=linkRes;}
    // Island sizes as the stage has them.
    std::vector<PxU32> islandBonds(n,0),islandChunks(n,0);
    for(PxU32 k=0;k<m;++k)if(bondIslands[k]<n)++islandBonds[bondIslands[k]];
    for(PxU32 i=0;i<n;++i)if(nodeIslands[i]<n)++islandChunks[nodeIslands[i]];
    if(std::getenv("IMPACT_TRIGGER_REPORT")) {
        const PxU32 capacity=4096;TriggerRow* rows;allocate(rows,capacity);PxU32* count;allocate(count,1);check(cudaMemset(count,0,4));
        triggerReport<<<(m+127)/128,128>>>(in,s,rows,count,capacity);check(cudaDeviceSynchronize());
        PxU32 c=0;check(cudaMemcpy(&c,count,4,cudaMemcpyDeviceToHost));std::vector<TriggerRow> r(std::min(c,capacity));
        if(!r.empty())check(cudaMemcpy(r.data(),rows,sizeof(r[0])*r.size(),cudaMemcpyDeviceToHost));
        std::sort(r.begin(),r.end(),[](const TriggerRow& a,const TriggerRow& b){return a.utilisation>b.utilisation;});
        const auto chunks=std::vector<PxDestructionStressChunk>();(void)chunks;
        std::printf("bonds past capacity in the elastic solve: %u (sections %s, section rotation %s)\n",c,s.sectionBending?"on":"off",s.sectionRotation?"on":"off");
        std::printf("bond,material,chunk0,chunk1,utilisation,area,live,S0,S1,Zt,g0,g1,gb,gt,N,V,T,M0,M1\n");
        for(const auto& x:r)std::printf("%u,%u,%u,%u,%.3f,%.4g,%.4g,%.4g,%.4g,%.4g,%.4g,%.4g,%.4g,%.4g,%.4g,%.4g,%.4g,%.4g,%.4g\n",x.bond,x.material,x.chunk0,x.chunk1,x.utilisation,x.area,x.live,
            x.s0,x.s1,x.zt,x.g0,x.g1,x.gb,x.gt,x.N,x.V,x.T,x.M0,x.M1);
    }
    const int runs=argc>2?std::atoi(argv[2]):1;
    for(int r=0;r<runs;++r) {
        const auto t0=std::chrono::steady_clock::now();
        e.submit(in,s,stream);check(cudaStreamSynchronize(stream));check(cudaGetLastError());
        const double ms=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-t0).count();
        impact::Status st{};check(cudaMemcpy(&st,e.w.status,sizeof st,cudaMemcpyDeviceToHost));
        if(!r && !std::getenv("IMPACT_QUIET")) {
            std::vector<impact::SolveRecord> rec(impact::kLogCapacity);check(cudaMemcpy(rec.data(),log,sizeof(rec[0])*rec.size(),cudaMemcpyDeviceToHost));
            for(PxU32 i=0;i<std::min(st.solves,impact::kLogCapacity);++i)
                std::printf("  solve %3u: island %u (%u bonds, %u chunks; %u links, %u nodes) level %2u lambda %.3g clipped %4u broken %4u: %5u iterations%s, residual %.2e\n",
                    i,rec[i].island,islandBonds[rec[i].island],islandChunks[rec[i].island],rec[i].links,rec[i].nodes,rec[i].level,rec[i].lambda,rec[i].clipped,rec[i].broken,
                    rec[i].iterations,rec[i].capped?" (capped)":"",rec[i].change);
        }
        if(trace && !r) {
            std::vector<float> t(4*size_t(impact::kTraceCapacity));check(cudaMemcpy(t.data(),trace,sizeof(float)*t.size(),cudaMemcpyDeviceToHost));
            // The links with the largest residuals at the end, with what they are.
            std::vector<float> lr(6*links);check(cudaMemcpy(lr.data(),linkRes,sizeof(float)*lr.size(),cudaMemcpyDeviceToHost));
            std::vector<impact::Bond> bl(links);check(cudaMemcpy(bl.data(),e.w.bonds,sizeof(impact::Bond)*links,cudaMemcpyDeviceToHost));
            std::vector<float> J(6*links),Z(6*links);check(cudaMemcpy(Z.data(),e.w.Y,sizeof(float)*Z.size(),cudaMemcpyDeviceToHost));
            std::vector<PxU32> order;for(PxU32 l=0;l<links;++l)if(lr[6*l]>0.0f || lr[6*l+1]>0.0f)order.push_back(l);
            std::sort(order.begin(),order.end(),[&](PxU32 a,PxU32 b){return std::max(lr[6*a],lr[6*a+1]*1e4f)>std::max(lr[6*b],lr[6*b+1]*1e4f);});
            for(PxU32 i=0;i<std::min<size_t>(order.size(),12);++i){const PxU32 l=order[i];const auto& b=bl[l];
                std::printf("  link %u (bond %u, chunks %u %u, flags %u): primal %.3e dual %.3e (lin %.2e ang %.2e, floors %.2e %.2e); caps C %.3g T %.3g S %.3g, area %.3g, gains gb %.3g gt %.3g g0 %.3g g1 %.3g, k %.3g %.3g %.3g %.3g; Z %.3g %.3g %.3g | %.3g %.3g %.3g\n",
                    l,b.bond,b.c0,b.c1,b.flags,lr[6*l],lr[6*l+1],lr[6*l+2],lr[6*l+3],lr[6*l+4],lr[6*l+5],b.capC,b.capT,b.capS,b.area,b.gb,b.gt,b.g0,b.g1,b.kl,b.kt,b.k0,b.k1,
                    Z[6*l],Z[6*l+1],Z[6*l+2],Z[6*l+3],Z[6*l+4],Z[6*l+5]);}
            const PxU32 every=PxU32(std::max(1,std::atoi(std::getenv("IMPACT_TRACE"))));
            for(PxU32 i=0;i<impact::kTraceCapacity;i+=every){if(t[4*i]==0.0f && t[4*i+1]==0.0f && t[4*i+3]==0.0f)break;
                std::printf("  step %5u: primal %.3e dual %.3e motion %.3e rho %.3e\n",i,t[4*i],t[4*i+1],t[4*i+2],t[4*i+3]);}
        }
        std::printf("%s: %u chunks, %u bonds, %u rows; %u islands, %u solves, %u iterations (%u capped), %u rounds; broke %u, yielded %u; %u contacts, %u impactors; %u diverged (worst bond %d), %u infeasible, %u non-finite, %u energy gains; error %u; %.1f ms in %u dispatches (longest %.1f ms)\n",
            argv[1],n,m,h.rows,st.triggered,st.solves,st.iterations,st.capped,st.rounds,st.broken,st.yielded,st.contacts,st.impactors,st.diverged,int(st.worstBond)-1,st.infeasible,st.nonfinite,st.energyGain,st.error,ms,e.dispatches,e.longestDispatch);
    }
    e.release();return 0;
}
}} // physx
int main(int argc,char** argv){try{return physx::run(argc,argv);}catch(const std::exception& e){std::fprintf(stderr,"error: %s\n",e.what());return 2;}}
