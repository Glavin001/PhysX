// The impact study's first contact tick (vibe-land structures/town-kit/scripts/
// impact-e-replay.py export) through the stage's impact-capacity solve (E).
//
//   destruction_impact_replay PROBLEM.impe OUT.gpu [iterations] [tolerance] [rampLevels] [stiffnessScale] [rampFactor] [elasticIncrementAfterYield]
//
// OUT.gpu: m verdicts (u32: 0 none, 1 held, 2 yielded, 3 broken), m forces
// (6 f32, the stress solver's convention), n accelerations (6 f32), then the
// solve's status. Compare with the oracle: impact-e-replay.py compare.
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
template<class T>T* upload(const std::vector<T>& v){T* p;allocate(p,v.size());if(!v.empty())check(cudaMemcpy(p,v.data(),v.size()*sizeof(T),cudaMemcpyHostToDevice));return p;}
struct Reader {
    FILE* f;explicit Reader(const char* path):f(std::fopen(path,"rb")){if(!f)throw std::runtime_error("cannot open problem");}
    ~Reader(){std::fclose(f);}
    template<class T>T get(){T v;if(std::fread(&v,sizeof v,1,f)!=1)throw std::runtime_error("short problem file");return v;}
};
int run(int argc,char** argv){
    if(argc<3){std::fprintf(stderr,"usage: %s PROBLEM.impe OUT.gpu [iterations] [tolerance] [rampLevels] [stiffnessScale] [rampFactor] [elasticIncrementAfterYield]\n",argv[0]);return 2;}
    Reader r(argv[1]);
    char magic[4];for(char& c:magic)c=r.get<char>();if(std::memcmp(magic,"IMPE",4) || r.get<PxU32>()!=1)throw std::runtime_error("not an impact problem");
    const PxU32 n=r.get<PxU32>(),m=r.get<PxU32>(),materialCount=r.get<PxU32>();
    impact::Settings s;s.dt=r.get<float>();s.bendGainMax=r.get<float>();
    if(argc>3)s.iterations=PxU32(std::atoi(argv[3]));
    if(argc>4)s.tolerance=float(std::atof(argv[4]));
    if(argc>5)s.rampLevels=PxU32(std::atoi(argv[5]));
    // The exported weights are the oracle's, w = sqrt(E/30 GPa A/L), not normalised.
    s.stiffness=30e9f;if(argc>6)s.stiffnessScale=float(std::atof(argv[6]));
    s.momentAtCentroid=!std::getenv("IMPACT_MOMENT_AT_SOLVER_POINT");   // the oracle's convention
    if(argc>7)s.rampFactor=float(std::atof(argv[7]));
    if(argc>8)s.elasticIncrementAfterYield=std::atoi(argv[8])!=0;
    if(const char* v=std::getenv("IMPACT_INNER"))s.innerIterations=PxU32(std::atoi(v));
    std::vector<PxDestructionStressChunk> chunks(n);std::vector<PxDestructionVectorPair> accel(n);
    for(PxU32 i=0;i<n;++i){
        float v[11];for(float& x:v)x=r.get<float>();
        auto& c=chunks[i];c={};c.position=PxVec3(v[0],v[1],v[2]);c.mass=v[3];c.inertia=v[4];c.cluster=0;c.contactIndex=0xffffffffu;
        if(c.mass>0){accel[i].linear=PxVec3(v[5],v[6],v[7])/c.mass;accel[i].angular=-PxVec3(v[8],v[9],v[10])/c.inertia;}
    }
    std::vector<PxDestructionMaterial> materials(materialCount);std::vector<float> slip(materialCount);
    for(PxU32 k=0;k<materialCount;++k){
        auto& mt=materials[k];mt={};mt.compressionFatalLimit=r.get<float>();mt.tensionFatalLimit=r.get<float>();mt.shearFatalLimit=r.get<float>();
        mt.compressionElasticLimit=0.6f*mt.compressionFatalLimit;mt.tensionElasticLimit=0.6f*mt.tensionFatalLimit;mt.shearElasticLimit=0.6f*mt.shearFatalLimit;
        slip[k]=r.get<float>();
    }
    std::vector<PxDestructionStressBond> bonds(m);std::vector<float> health(m);
    for(PxU32 k=0;k<m;++k){
        auto& b=bonds[k];b={};b.chunk0=r.get<PxU32>();b.chunk1=r.get<PxU32>();b.material=r.get<PxU32>();
        float v[8];for(float& x:v)x=r.get<float>();
        b.centroid=PxVec3(v[0],v[1],v[2]);b.normal=PxVec3(v[3],v[4],v[5]);b.area=b.health=health[k]=v[6];b.complianceScale=v[7];
    }
    std::vector<PxDestructionVectorPair> base(m),elastic(m);
    for(auto* J:{&base,&elastic})for(PxU32 k=0;k<m;++k){float v[6];for(float& x:v)x=r.get<float>();(*J)[k].linear=PxVec3(v[0],v[1],v[2]);(*J)[k].angular=PxVec3(v[3],v[4],v[5]);}
    s.lengthScale=r.get<float>();
    // Topology: node CSR and the stress islands (minimum dynamic node per component).
    std::vector<PxU32> begin(n+1,0),refs(2*m);
    for(const auto& b:bonds){++begin[b.chunk0+1];++begin[b.chunk1+1];}
    for(PxU32 i=0;i<n;++i)begin[i+1]+=begin[i];
    auto cursor=begin;for(PxU32 k=0;k<m;++k){refs[cursor[bonds[k].chunk0]++]=k;refs[cursor[bonds[k].chunk1]++]=k;}
    std::vector<PxU32> parent(n);for(PxU32 i=0;i<n;++i)parent[i]=i;
    auto root=[&](PxU32 i){while(parent[i]!=i)i=parent[i]=parent[parent[i]];return i;};
    for(const auto& b:bonds)if(chunks[b.chunk0].mass>0 && chunks[b.chunk1].mass>0){const PxU32 a=root(b.chunk0),c=root(b.chunk1);parent[std::max(a,c)]=std::min(a,c);}
    std::vector<PxU32> nodeIsland(n,0xffffffffu),bondIsland(m,0xffffffffu);
    for(PxU32 i=0;i<n;++i)if(chunks[i].mass>0)nodeIsland[i]=root(i);
    for(PxU32 k=0;k<m;++k)bondIsland[k]=chunks[bonds[k].chunk0].mass>0?nodeIsland[bonds[k].chunk0]:nodeIsland[bonds[k].chunk1];
    impact::Inputs in{};
    in.chunks=upload(chunks);in.chunkCount=n;in.bonds=upload(bonds);in.bondCount=m;in.materials=upload(materials);in.ductileSlip=upload(slip);
    in.health=upload(health);in.nodeBegin=upload(begin);in.nodeRefs=upload(refs);in.nodeIslands=upload(nodeIsland);in.bondIslands=upload(bondIsland);
    in.accelerations=upload(accel);in.elastic=upload(elastic);in.base=upload(base);
    PxDestructionStageStatus stage{};in.stage=upload(std::vector<PxDestructionStageStatus>{stage});
    cudaStream_t stream;check(cudaStreamCreateWithFlags(&stream,cudaStreamNonBlocking));
    impact::Stage e;e.allocate(n,m);
    impact::SolveRecord* log;allocate(log,impact::kLogCapacity);e.w.log=log;
    float* breaks;allocate(breaks,2*size_t(m));check(cudaMemset(breaks,0,sizeof(float)*2*m));e.w.breaks=breaks;

    // Once to warm the pipelines, then timed.
    e.submit(in,s,stream);check(cudaStreamSynchronize(stream));
    const auto t0=std::chrono::steady_clock::now();
    e.submit(in,s,stream);check(cudaStreamSynchronize(stream));check(cudaGetLastError());
    const double ms=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-t0).count();
    std::vector<PxU32> verdict(m),flags(n);std::vector<PxDestructionVectorPair> forces(m);std::vector<float> u(6*size_t(n));impact::Status status{};
    check(cudaMemcpy(verdict.data(),e.w.verdict,m*sizeof(PxU32),cudaMemcpyDeviceToHost));
    check(cudaMemcpy(flags.data(),e.w.islandFlag,n*sizeof(PxU32),cudaMemcpyDeviceToHost));
    check(cudaMemcpy(forces.data(),e.w.forces,m*sizeof(forces[0]),cudaMemcpyDeviceToHost));
    check(cudaMemcpy(u.data(),e.w.u,u.size()*sizeof(float),cudaMemcpyDeviceToHost));
    check(cudaMemcpy(&status,e.w.status,sizeof status,cudaMemcpyDeviceToHost));
    for(PxU32 k=0;k<m;++k)if(bondIsland[k]==0xffffffffu || !flags[bondIsland[k]]){verdict[k]=impact::eNONE;forces[k]=elastic[k];}
    FILE* o=std::fopen(argv[2],"wb");if(!o)throw std::runtime_error("cannot write output");
    std::fwrite(verdict.data(),sizeof(PxU32),m,o);std::fwrite(forces.data(),sizeof(forces[0]),m,o);std::fwrite(u.data(),sizeof(float),u.size(),o);
    std::fwrite(&status,sizeof status,1,o);
    std::vector<float> br(2*size_t(m));check(cudaMemcpy(br.data(),breaks,sizeof(float)*br.size(),cudaMemcpyDeviceToHost));
    std::fwrite(br.data(),sizeof(float),br.size(),o);std::fclose(o);
    if(std::getenv("IMPACT_LOG")) {
        std::vector<impact::SolveRecord> rec(impact::kLogCapacity);check(cudaMemcpy(rec.data(),log,sizeof(rec[0])*rec.size(),cudaMemcpyDeviceToHost));
        for(PxU32 i=0;i<std::min(status.solves,impact::kLogCapacity);++i)
            std::printf("  solve %2u: level %u lambda %.4f clipped %4u broken so far %4u: %5u iterations%s, last change %.2e\n",
                i,rec[i].level,rec[i].lambda,rec[i].clipped,rec[i].broken,rec[i].iterations,rec[i].capped?" (capped)":"",rec[i].change);
    }
    PxU32 broken=0,yielded=0;for(PxU32 v:verdict){broken+=v==impact::eBROKEN;yielded+=v==impact::eYIELDED;}
    std::printf("%u chunks, %u bonds: %u islands solved, %u solves, %u iterations (%u capped), largest %u rounds; broken %u, yielded %u; error %u; %.1f ms\n",
        n,m,status.triggered,status.solves,status.iterations,status.capped,status.rounds,broken,yielded,status.error,ms);
    e.release();return 0;
}
}} // physx
int main(int argc,char** argv){try{return physx::run(argc,argv);}catch(const std::exception& e){std::fprintf(stderr,"error: %s\n",e.what());return 2;}}
