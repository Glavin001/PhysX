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
// IMPACT_DUMP: each link's wrench blocks on its two nodes (column q: the
// wrench of a unit force q in the bond frame), for an exact (FP64) solve of
// the capped level's problem off line (vibe-land scripts/impact/oracle-level.py).
__global__ void wrenchBlocks(impact::Scratch w,impact::Island is,float* B)
{
    const PxU32 l=blockIdx.x*blockDim.x+threadIdx.x;if(l>=impact::links(is))return;
    const impact::Bond& b=w.bonds[is.b0+l];
    for(int q=0;q<6;++q){float x[6]={0,0,0,0,0,0};x[q]=1.0f;float r0[6]={0,0,0,0,0,0},r1[6]={0,0,0,0,0,0};
        impact::addWrench(b,x,true,r0);impact::addWrench(b,x,false,r1);
        for(int k=0;k<6;++k){B[72*size_t(l)+6*k+q]=r0[k];B[72*size_t(l)+36+6*k+q]=r1[k];}}
}
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
    s.cappedElastic=env("IMPACT_CAPPED_ELASTIC",std::getenv("IMPACT_DUMP")?1.0f:0.0f)!=0.0f;
    s.method=PxU32(env("IMPACT_METHOD",float(s.method)));s.stepDuration=env("IMPACT_STEP_DURATION",s.stepDuration);s.stepRadius=env("IMPACT_STEP_RADIUS",s.stepRadius);
    s.dispatchWork=PxU32(env("IMPACT_DISPATCH_WORK",float(s.dispatchWork)));   // keep dispatches short (a capture's own may be 2^20)
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
    float* trace=nullptr;if(std::getenv("IMPACT_TRACE")){allocate(trace,4*size_t(impact::kTraceCapacity));check(cudaMemset(trace,0,sizeof(float)*4*impact::kTraceCapacity));e.w.trace=trace;if(const char* v=std::getenv("IMPACT_TRACE_SOLVE"))e.w.traceSolve=PxU32(std::atoi(v));
        if(const char* v=std::getenv("IMPACT_TRACE_STRIDE"))e.w.traceStride=PxU32(std::max(1,std::atoi(v)));}
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
    e.recordDispatches=std::getenv("IMPACT_DISPATCH_LOG")!=nullptr;
    // Warm the island kernel's pipeline (built on its first launch: 1.3 s on
    // Metal, which a timed first dispatch would count): no islands, no work.
    check(cudaMemset(e.w.counters,0,sizeof(PxU32)*8));
    impact::stepIslands<<<1,impact::kThreads>>>(in,s,e.w);check(cudaDeviceSynchronize());
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
                std::printf("  step %7u: primal %.3e dual %.3e motion %.3e rho %.3e\n",i*e.w.traceStride,t[4*i],t[4*i+1],t[4*i+2],t[4*i+3]);}
        }
        // IMPACT_REPORT: the joints broken (with their distance from the first
        // contact point) and each coupled row's impulse on its chunk and the
        // impactor's velocity change.
        if(!r && std::getenv("IMPACT_REPORT")) {
            std::vector<PxU32> v(m);check(cudaMemcpy(v.data(),e.w.verdict,sizeof(PxU32)*m,cudaMemcpyDeviceToHost));
            std::vector<PxDestructionStressBond> hb(m);check(cudaMemcpy(hb.data(),in.bonds,sizeof(hb[0])*m,cudaMemcpyDeviceToHost));
            std::vector<PxU32> flags(n);check(cudaMemcpy(flags.data(),e.w.islandFlag,sizeof(PxU32)*n,cudaMemcpyDeviceToHost));
            const PxVec3 hit=hostRows.empty()?PxVec3(0):PxVec3(hostRows[0].point[0],hostRows[0].point[1],hostRows[0].point[2]);
            PxU32 broken=0,yielded=0;std::vector<float> dist;
            for(PxU32 k=0;k<m;++k){if(bondIslands[k]>=n || !flags[bondIslands[k]])continue;
                if(v[k]==impact::eBROKEN){++broken;dist.push_back((hb[k].centroid-hit).magnitude());
                    std::printf("  broken bond %u (chunks %u %u, material %u) at %.2f m from the hit\n",k,hb[k].chunk0,hb[k].chunk1,hb[k].material,dist.back());}
                else if(v[k]==impact::eYIELDED)++yielded;}
            std::sort(dist.begin(),dist.end());
            std::printf("  E's verdict: %u broken (median %.2f m, max %.2f m from the hit), %u yielded\n",broken,dist.empty()?0.0f:dist[dist.size()/2],dist.empty()?0.0f:dist.back(),yielded);
            if(!hostRows.empty()) {
                std::vector<float> d(6*size_t(h.rows)),fo(3*size_t(h.rows));
                check(cudaMemcpy(d.data(),in.rowDelta,sizeof(float)*d.size(),cudaMemcpyDeviceToHost));check(cudaMemcpy(fo.data(),in.rowForce,sizeof(float)*fo.size(),cudaMemcpyDeviceToHost));
                PxVec3 total(0);
                std::vector<PxDestructionStressChunk> hc(n);check(cudaMemcpy(hc.data(),in.chunks,sizeof(hc[0])*n,cudaMemcpyDeviceToHost));
                std::vector<PxDestructionCrushState> cr(in.crushed?n:0);if(in.crushed)check(cudaMemcpy(cr.data(),in.crushed,sizeof(cr[0])*n,cudaMemcpyDeviceToHost));
                for(PxU32 i=0;i<h.rows;++i){const auto& q=hostRows[i];const PxU32 c=q.chunk;
                    if(c<n)std::printf("  row %u: struck chunk %u mass %.4g kg at (%.2f %.2f %.2f), island %u%s, %u points, normal (%.2f %.2f %.2f)\n",i,c,hc[c].mass,
                        hc[c].position.x,hc[c].position.y,hc[c].position.z,nodeIslands[c],(in.crushed && cr[c].crushed)?", crushed":"",q.points,q.normal[0],q.normal[1],q.normal[2]);}
                for(PxU32 i=0;i<h.rows;++i){const auto& q=hostRows[i];const PxVec3 F(fo[3*i],fo[3*i+1],fo[3*i+2]);total+=F*s.dt;
                    std::printf("  row %u: chunk %u body %u, closing (%.2f %.2f %.2f) m/s, trial stop %.3g N s, solved impulse (%.3g %.3g %.3g) N s, impactor dv vs trial (%.3f %.3f %.3f) m/s\n",
                        i,q.chunk,q.body,q.velocity[0],q.velocity[1],q.velocity[2],PxVec3(q.load[0],q.load[1],q.load[2]).magnitude()*s.dt,F.x*s.dt,F.y*s.dt,F.z*s.dt,d[6*i],d[6*i+1],d[6*i+2]);}
                const float M=hostRows[0].im>0.0f?1.0f/hostRows[0].im:0.0f;
                std::printf("  impulse on the struck chunks (all rows): (%.4g %.4g %.4g) N s; the impactor (%.0f kg) closing (%.2f %.2f %.2f) m/s: its momentum %.4g N s\n",
                    total.x,total.y,total.z,M,hostRows[0].velocity[0],hostRows[0].velocity[1],hostRows[0].velocity[2],
                    M*PxVec3(hostRows[0].velocity[0],hostRows[0].velocity[1],hostRows[0].velocity[2]).magnitude());
            }
        }
        if(!r && e.recordDispatches) {
            const double over=env("IMPACT_DISPATCH_LOG",50.0f);
            for(size_t i=0;i<e.dispatchRecord.size();++i){const auto& d=e.dispatchRecord[i];if(d.first<over)continue;
                std::printf("  dispatch %zu: %.1f ms; the first island before it: phase %u level %u rounds %u solve step %u total %u lambda %.3g\n",
                    i,d.first,d.second.phase,d.second.level,d.second.rounds,d.second.solve.it,d.second.total,d.second.lambda);}
        }
        if(!r && s.method==1u && e.stepAllocated) {
            PxU32 count=0;check(cudaMemcpy(&count,e.t.patchCount,4,cudaMemcpyDeviceToHost));
            std::vector<impact::StepPatch> ps(count);if(count)check(cudaMemcpy(ps.data(),e.t.patches,sizeof(ps[0])*count,cudaMemcpyDeviceToHost));
            if(std::getenv("IMPACT_STEP_DEBUG") && count) {
                // A again, before and after its inversion.
                const dim3 g(64,count);
                impact::stepAssemble<<<g,impact::kThreads>>>(in,s,e.w,e.t);impact::stepAssemble2<<<g,impact::kThreads>>>(in,s,e.w,e.t);check(cudaDeviceSynchronize());
                const PxU32 n6=6*ps[0].nodes;std::vector<float> A(size_t(n6)*n6);
                check(cudaMemcpy(A.data(),e.t.Ainv,sizeof(float)*A.size(),cudaMemcpyDeviceToHost));
                PxU32 nf=0,neg=0;float dmin=FLT_MAX,dmax=0,asym=0;for(PxU32 i=0;i<n6;++i){const float d=A[size_t(i)*n6+i];if(!(d>0))++neg;dmin=std::min(dmin,d);dmax=std::max(dmax,d);
                    for(PxU32 j=0;j<n6;++j){const float x=A[size_t(i)*n6+j];if(!std::isfinite(x))++nf;asym=std::max(asym,std::fabs(x-A[size_t(j)*n6+i])/std::max(1e-30f,std::fabs(x)));}}
                std::printf("  step debug A: %u non-finite, %u diagonal <= 0, diagonal %.3g..%.3g, worst asymmetry %.3g\n",nf,neg,dmin,dmax,asym);
                {float worst=0;PxU32 wi=0,wj=0;for(PxU32 i=0;i<n6;++i)for(PxU32 j=i+1;j<n6;++j){const float d=std::fabs(A[size_t(i)*n6+j]-A[size_t(j)*n6+i])/std::sqrt(A[size_t(i)*n6+i]*A[size_t(j)*n6+j]);if(d>worst){worst=d;wi=i;wj=j;}}
                 std::printf("  step debug A: worst asymmetry %.3g of sqrt(A_ii A_jj) at (%u, %u): %.6g vs %.6g; diagonal %.6g %.6g\n",worst,wi,wj,A[size_t(wi)*n6+wj],A[size_t(wj)*n6+wi],A[size_t(wi)*n6+wi],A[size_t(wj)*n6+wj]);}
                {// Cauchy-Schwarz: the worst |A_ij| / sqrt(A_ii A_jj), and the links on those nodes
                 float worst=0;PxU32 wi=0,wj=0;for(PxU32 i=0;i<n6;++i)for(PxU32 j=i+1;j<n6;++j){const float d=std::fabs(A[size_t(i)*n6+j])/std::sqrt(A[size_t(i)*n6+i]*A[size_t(j)*n6+j]);if(d>worst){worst=d;wi=i;wj=j;}}
                 std::printf("  step debug A: worst |A_ij|/sqrt(A_ii A_jj) %.3g at (%u, %u)\n",worst,wi,wj);
                 const PxU32 nl=ps[0].links;std::vector<impact::StepLink> ends(nl);std::vector<impact::Bond> bl(nl);std::vector<PxU32> nc(ps[0].nodes);
                 check(cudaMemcpy(ends.data(),e.t.linkEnds,sizeof(ends[0])*nl,cudaMemcpyDeviceToHost));check(cudaMemcpy(bl.data(),e.t.links,sizeof(bl[0])*nl,cudaMemcpyDeviceToHost));
                 check(cudaMemcpy(nc.data(),e.t.nodeChunk,sizeof(PxU32)*nc.size(),cudaMemcpyDeviceToHost));
                 for(PxU32 l=0;l<nl;++l){const auto& q=ends[l];if(q.a==wi/6||q.b==wi/6||q.a==wj/6||q.b==wj/6)std::printf("    link %u (%s, bond %u, chunks %u %u): ends %d %d; k %.3g %.3g %.3g %.3g\n",l,(q.state&impact::eSL_CONTACT)?"contact":"joint",bl[l].bond,bl[l].c0,bl[l].c1,int(q.a),int(q.b),bl[l].kl,bl[l].kt,bl[l].k0,bl[l].k1);}
                 std::printf("    node %u chunk %u, node %u chunk %u\n",wi/6,nc[wi/6],wj/6,nc[wj/6]);}
                {const PxU32 nl=ps[0].links;std::vector<float> B(size_t(nl)*72);check(cudaMemcpy(B.data(),e.t.B,sizeof(float)*B.size(),cudaMemcpyDeviceToHost));
                 std::vector<impact::StepLink> ends(nl);std::vector<impact::Bond> bl(nl);check(cudaMemcpy(ends.data(),e.t.linkEnds,sizeof(ends[0])*nl,cudaMemcpyDeviceToHost));check(cudaMemcpy(bl.data(),e.t.links,sizeof(bl[0])*nl,cudaMemcpyDeviceToHost));
                 // the diagonal and off-diagonal (rot-x) contributions of each link touching node 70/71
                 for(PxU32 l=0;l<nl;++l){const auto& q=ends[l];if(q.a!=70 && q.b!=70)continue;if(q.state&impact::eSL_CONTACT)continue;
                    float c[6];const float k[6]={bl[l].kl,bl[l].kl,bl[l].kl,bl[l].kt,bl[l].k0,bl[l].k1};for(int t2=0;t2<6;++t2)c[t2]=(k[t2]>0&&k[t2]<1e30f)?k[t2]*1e-6f:0;
                    const int ea=q.a==70?0:1;double d=0;for(int t2=0;t2<6;++t2){const double b=B[72*l+36*ea+6*3+t2];d+=b*b*c[t2];}
                    std::printf("    link %u ends %d %d: rot-x row of node 70: %.3g %.3g %.3g %.3g %.3g %.3g; diag contribution %.4g; o0 (%.3g %.3g %.3g) o1 (%.3g %.3g %.3g) n (%.2f %.2f %.2f)\n",l,int(q.a),int(q.b),
                        B[72*l+36*ea+18],B[72*l+36*ea+19],B[72*l+36*ea+20],B[72*l+36*ea+21],B[72*l+36*ea+22],B[72*l+36*ea+23],d,bl[l].o0[0],bl[l].o0[1],bl[l].o0[2],bl[l].o1[0],bl[l].o1[1],bl[l].o1[2],bl[l].n[0],bl[l].n[1],bl[l].n[2]);}}
                impact::stepScale<<<g,impact::kThreads>>>(e.t,0u);impact::stepScale<<<g,impact::kThreads>>>(e.t,1u);
                for(PxU32 k0=0;k0<n6;k0+=impact::kPanel){impact::stepPanelA<<<count,impact::kThreads>>>(e.t,k0);impact::stepPanelB<<<g,impact::kThreads>>>(e.t,k0);check(cudaDeviceSynchronize());
                    std::vector<float> P(impact::kPanel*impact::kPanel);check(cudaMemcpy(P.data(),e.t.panelP,sizeof(float)*P.size(),cudaMemcpyDeviceToHost));
                    PxU32 bad=0;for(float x:P)bad+=!std::isfinite(x);if(bad){std::printf("  step debug: panel %u's pivot block inverse non-finite\n",k0/impact::kPanel);break;}}
                impact::stepScale<<<g,impact::kThreads>>>(e.t,1u);check(cudaDeviceSynchronize());
                std::vector<float> I(size_t(n6)*n6);check(cudaMemcpy(I.data(),e.t.Ainv,sizeof(float)*I.size(),cudaMemcpyDeviceToHost));
                double worst=0;for(PxU32 i=0;i<n6;i+=7)for(PxU32 j=0;j<n6;j+=5){double v=0;for(PxU32 k=0;k<n6;++k)v+=double(A[size_t(i)*n6+k])*I[size_t(k)*n6+j];worst=std::max(worst,std::fabs(v-(i==j?1.0:0.0)));}
                std::printf("  step debug: |A A^-1 - I| sampled at most %.3g\n",worst);
            }
            for(PxU32 p=0;p<count && std::getenv("IMPACT_STEP_DEBUG");++p){const PxU32 nn=ps[p].nodes,n6=6*nn;
                std::vector<float> m(size_t(nn)*7);check(cudaMemcpy(m.data(),e.t.nodeMass+size_t(p)*impact::kStepNodes*7,sizeof(float)*m.size(),cudaMemcpyDeviceToHost));
                PxU32 zeroI=0,badM=0;for(PxU32 k=0;k<nn;++k){if(!(m[7*k]>0.0f) || !std::isfinite(m[7*k]))++badM;if(!(m[7*k+1]>0.0f))++zeroI;}
                std::vector<float> A(size_t(n6)*n6);check(cudaMemcpy(A.data(),e.t.Ainv+size_t(p)*impact::kStepDof*impact::kStepDof,sizeof(float)*A.size(),cudaMemcpyDeviceToHost));
                PxU32 nonfinite=0;float dmin=FLT_MAX,dmax=0;for(PxU32 i=0;i<n6;++i){const float d=A[size_t(i)*n6+i];if(!std::isfinite(d))++nonfinite;else{dmin=std::min(dmin,d);dmax=std::max(dmax,d);}}
                PxU32 nf=0;for(float x:A)nf+=!std::isfinite(x);
                std::printf("  step debug patch %u: %u nodes with a bad mass, %u with no inertia; A^-1 diagonal %u non-finite, range %.3g..%.3g; %u non-finite entries\n",p,badM,zeroI,nonfinite,dmin,dmax,nf);}
            for(const auto& q:ps)std::printf("  step patch: island %u, %u nodes (radius %.2f m%s), %u joints (%u at capacity at rest), %u contacts, %u impactors; h %.3g ms; %u events, %u solves; broke %u, yielded %u%s\n",
                q.island,q.nodes,q.radius,q.truncated?", shrunk":"",q.joints,q.restOver,q.contacts,q.impactors,q.h*1e3f,q.events,q.solves,q.broken,q.yielded,q.failed?" (FAILED)":"");
        }
        if(!r && std::getenv("IMPACT_DUMP")) {
            PxU32 islands=0;check(cudaMemcpy(&islands,e.w.counters,4,cudaMemcpyDeviceToHost));
            std::vector<impact::IslandState> states(islands);if(islands)check(cudaMemcpy(states.data(),e.w.state,sizeof(states[0])*islands,cudaMemcpyDeviceToHost));
            for(const auto& is:states) {
                if(!is.capped)continue;
                const impact::Island I=is.is;const PxU32 nl=I.nb+I.nr,nn=I.nc+I.ni;
                std::vector<impact::Bond> bl(nl);check(cudaMemcpy(bl.data(),e.w.bonds+I.b0,sizeof(bl[0])*nl,cudaMemcpyDeviceToHost));
                std::vector<impact::Chunk> ch(nn);check(cudaMemcpy(ch.data(),e.w.chunks+I.c0,sizeof(ch[0])*nn,cudaMemcpyDeviceToHost));
                std::vector<float> J(6*size_t(nl)),T(6*size_t(nl)),B(72*size_t(nl));
                check(cudaMemcpy(J.data(),e.w.J+6*size_t(I.b0),sizeof(float)*J.size(),cudaMemcpyDeviceToHost));
                check(cudaMemcpy(T.data(),e.w.T+6*size_t(I.b0),sizeof(float)*T.size(),cudaMemcpyDeviceToHost));
                float* dB;allocate(dB,B.size());wrenchBlocks<<<(nl+127)/128,128>>>(e.w,I,dB);check(cudaDeviceSynchronize());
                check(cudaMemcpy(B.data(),dB,sizeof(float)*B.size(),cudaMemcpyDeviceToHost));cudaFree(dB);
                const float lambda=is.cappedLambda;
                char path[1024];std::snprintf(path,sizeof path,"%s-island%u.bin",std::getenv("IMPACT_DUMP"),is.island);
                FILE* o=std::fopen(path,"wb");if(!o)throw std::runtime_error("cannot write the dump");
                const PxU32 head[4]={nn,nl,I.nb,I.nr};std::fwrite(head,4,4,o);
                const float fh[4]={s.dt,lambda,s.capacityBand,s.capacityTolerance};std::fwrite(fh,4,4,o);
                for(const auto& c:ch){const PxU32 u[2]={c.chunk,c.tensor};std::fwrite(u,4,2,o);
                    float f[14]={c.im,c.ii};for(int q=0;q<6;++q){f[2+q]=c.Iinv[q];f[8+q]=(1.0f-lambda)*c.pb[q]+lambda*c.pf[q]-c.r[q];}std::fwrite(f,4,14,o);}
                for(PxU32 l=0;l<nl;++l){const auto& b=bl[l];const PxU32 u[4]={b.bond,b.c0,b.c1,b.flags};std::fwrite(u,4,4,o);
                    const float mu=(b.flags&impact::eCONTACT)?hostRows[b.bond].friction:0.0f;
                    const float f[14]={b.capC,b.capT,b.capS,b.gb,b.gt,b.g0,b.g1,b.h0,b.h1,b.kl,b.kt,b.k0,b.k1,mu};std::fwrite(f,4,14,o);
                    std::fwrite(&J[6*l],4,6,o);std::fwrite(&T[6*l],4,6,o);std::fwrite(&B[72*l],4,72,o);}
                std::fclose(o);
                // Every bond's centroid and the first contact point (world), for locality.
                std::snprintf(path,sizeof path,"%s-island%u.centroids.bin",std::getenv("IMPACT_DUMP"),is.island);
                o=std::fopen(path,"wb");if(!o)throw std::runtime_error("cannot write the dump");
                {std::vector<PxDestructionStressBond> hb(m);check(cudaMemcpy(hb.data(),in.bonds,sizeof(hb[0])*m,cudaMemcpyDeviceToHost));
                const float hit[3]={hostRows.empty()?0.0f:hostRows[0].point[0],hostRows.empty()?0.0f:hostRows[0].point[1],hostRows.empty()?0.0f:hostRows[0].point[2]};
                std::fwrite(&m,4,1,o);std::fwrite(hit,4,3,o);for(const auto& b:hb)std::fwrite(&b.centroid,4,3,o);}
                std::fclose(o);
                // The capped solve's ADMM state where it stopped (Z, U, the node
                // space y, rho, steps): a level replay resumes from it.
                {std::vector<float> Z(6*size_t(nl)),U(6*size_t(nl)),y(6*size_t(nn));
                check(cudaMemcpy(Z.data(),e.w.Y+6*size_t(I.b0),sizeof(float)*Z.size(),cudaMemcpyDeviceToHost));
                check(cudaMemcpy(U.data(),e.w.Jn+6*size_t(I.b0),sizeof(float)*U.size(),cudaMemcpyDeviceToHost));
                for(PxU32 k=0;k<nn;++k)check(cudaMemcpy(&y[6*k],e.w.cy+6*size_t(ch[k].chunk),sizeof(float)*6,cudaMemcpyDeviceToHost));
                std::snprintf(path,sizeof path,"%s-island%u.state.bin",std::getenv("IMPACT_DUMP"),is.island);
                o=std::fopen(path,"wb");if(!o)throw std::runtime_error("cannot write the dump");
                const float head2[2]={is.solve.rho,float(is.solve.it)};std::fwrite(head2,4,2,o);
                std::fwrite(Z.data(),4,Z.size(),o);std::fwrite(U.data(),4,U.size(),o);std::fwrite(y.data(),4,y.size(),o);std::fclose(o);}
                // The contact rows (all of them, coupled or not) beside it.
                std::snprintf(path,sizeof path,"%s-island%u.rows.bin",std::getenv("IMPACT_DUMP"),is.island);
                o=std::fopen(path,"wb");if(!o)throw std::runtime_error("cannot write the dump");
                {std::vector<PxDestructionCrushState> cr(in.crushed?n:0);if(in.crushed)check(cudaMemcpy(cr.data(),in.crushed,sizeof(cr[0])*n,cudaMemcpyDeviceToHost));
                const PxU32 count=PxU32(hostRows.size());std::fwrite(&count,4,1,o);
                for(const auto& q:hostRows){const PxU32 u[3]={q.chunk,q.body,(q.chunk<n && in.crushed && cr[q.chunk].crushed)?1u:0u};std::fwrite(u,4,3,o);
                    std::fwrite(q.load,4,3,o);std::fwrite(q.torque,4,3,o);std::fwrite(q.velocity,4,3,o);std::fwrite(q.dv,4,3,o);std::fwrite(&q.im,4,1,o);}}
                std::fclose(o);
                // The ramp's state beside it (vibe-land scripts/impact/oracle-ramp.py).
                std::snprintf(path,sizeof path,"%s-island%u.ramp.bin",std::getenv("IMPACT_DUMP"),is.island);
                o=std::fopen(path,"wb");if(!o)throw std::runtime_error("cannot write the dump");
                const float rh[8]={is.first,s.rampFactor,float(s.maxRounds),float(is.rounds),float(is.level),s.elasticIncrementAfterYield?1.0f:0.0f,float(s.rampLevels),0.0f};std::fwrite(rh,4,8,o);
                for(const auto& c:ch){std::fwrite(c.pb,4,6,o);std::fwrite(c.pf,4,6,o);std::fwrite(c.r,4,6,o);}
                std::vector<float> slipBefore(m,0.0f);if(in.slipBefore)check(cudaMemcpy(slipBefore.data(),in.slipBefore,sizeof(float)*m,cudaMemcpyDeviceToHost));
                for(const auto& b:bl){const float f[2]={b.slip,(b.flags&impact::eCONTACT)?0.0f:slipBefore[b.bond]};std::fwrite(f,4,2,o);}
                std::fclose(o);
                std::printf("  dumped island %u (%u nodes, %u links: %u joints, %u contacts) at its capped level lambda %.4g (last converged %.4g) to %s\n",
                    is.island,nn,nl,I.nb,I.nr,lambda,is.snapLambda,path);
            }
        }
        std::printf("%s: %u chunks, %u bonds, %u rows; %u islands, %u solves, %u iterations (%u capped), %u rounds; broke %u, yielded %u; %u contacts, %u impactors; %u diverged (worst bond %d), %u infeasible, %u non-finite, %u energy gains; error %u; %.1f ms in %u dispatches (longest %.1f ms)\n",
            argv[1],n,m,h.rows,st.triggered,st.solves,st.iterations,st.capped,st.rounds,st.broken,st.yielded,st.contacts,st.impactors,st.diverged,int(st.worstBond)-1,st.infeasible,st.nonfinite,st.energyGain,st.error,ms,e.dispatches,e.longestDispatch);
    }
    e.release();return 0;
}
}} // physx
int main(int argc,char** argv){try{return physx::run(argc,argv);}catch(const std::exception& e){std::fprintf(stderr,"error: %s\n",e.what());return 2;}}
