// Impact capacity (E, docs/destruction/IMPACT_CAPACITY_DESIGN.md), on the GPU:
// the test plan's failing-first checks. Each structure's elastic solution (the
// stress solve's min-norm forces) is computed here exactly, in double; the
// stage then takes the forces the material evaluation would use -- today the
// elastic ones, with E its own where an island has a bond past capacity.
//
//   destruction_impact_capacity_test            all checks
//   PX_IMPACT_TODAY (compile definition)        the same checks on today's path (no E): they fail
#include "PxDestructionScene.h"
#include "NvBlastExtStressMaterialFormula.h"
#include <cuda_runtime.h>
#include <algorithm>
#include <cfloat>
#include <chrono>
#include <cmath>
#include <cstdio>
#include <cstring>
#include <cstdlib>
#include <stdexcept>
#include <string>
#include <vector>
namespace physx { namespace {
using namespace Nv::Blast;
void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}
template<class T>void allocate(T*& p,size_t n){check(cudaMalloc(&p,std::max(size_t(1),n)*sizeof(T)));}
#include "../src/PxgDestructionImpact.cuh"
#include "../src/PxgDestructionMaterial.cuh"

int failures=0;
void expect(bool ok,const std::string& text){std::printf("  %s %s\n",ok?"ok  ":"FAIL",text.c_str());if(!ok)++failures;}

template<class T>struct Device {
    T* p=nullptr;size_t n=0;
    explicit Device(size_t count):n(count){allocate(p,n);check(cudaMemset(p,0,std::max<size_t>(n,1)*sizeof(T)));}
    Device(const std::vector<T>& v):Device(v.size()){put(v);}
    ~Device(){cudaFree(p);}
    void put(const std::vector<T>& v){if(!v.empty())check(cudaMemcpy(p,v.data(),v.size()*sizeof(T),cudaMemcpyHostToDevice));}
    std::vector<T> get() const{std::vector<T> v(n);if(n)check(cudaMemcpy(v.data(),p,n*sizeof(T),cudaMemcpyDeviceToHost));return v;}
};

// A structure: chunks (mass 0 = anchor), bonds, materials, a load per chunk.
struct Structure {
    std::vector<PxDestructionStressChunk> chunks;
    std::vector<PxDestructionStressBond> bonds;
    std::vector<PxDestructionMaterial> materials;
    std::vector<float> ductile; // per material
    std::vector<PxVec3> force,torque; // per chunk, N and N m about the chunk
    std::vector<PxDestructionBondSection> sections; // per bond when the section model is on
    std::vector<impact::ContactRow> rows;           // coupled contacts (their trial loads already in force/torque)
    PxU32 chunk(PxVec3 p,float mass,float inertia){PxDestructionStressChunk c{};c.position=p;c.mass=mass;c.inertia=inertia;c.cluster=0;
        c.contactIndex=0xffffffffu;c.volume=0;c.material=0;chunks.push_back(c);force.push_back(PxVec3(0));torque.push_back(PxVec3(0));
        return PxU32(chunks.size()-1);}
    void bond(PxU32 a,PxU32 b,PxVec3 centroid,PxVec3 normal,float area,PxU32 material,float compliance=1.0f){
        PxDestructionStressBond x{};x.chunk0=std::min(a,b);x.chunk1=std::max(a,b);x.centroid=centroid;x.normal=normal;x.area=area;x.health=area;
        x.complianceScale=compliance;x.material=material;bonds.push_back(x);}
    PxU32 material(float c,float t,float s,float slip){PxDestructionMaterial m{};m.compressionElasticLimit=0.6f*c;m.compressionFatalLimit=c;
        m.tensionElasticLimit=0.6f*t;m.tensionFatalLimit=t;m.shearElasticLimit=0.6f*s;m.shearFatalLimit=s;materials.push_back(m);ductile.push_back(slip);
        return PxU32(materials.size()-1);}
    void gravity(){for(size_t i=0;i<chunks.size();++i)force[i]+=PxVec3(0,-9.81f,0)*chunks[i].mass;}
};

// The solver's application point offsets (NvBlastExtStressGpu bond setup).
void offsets(const Structure& s,const PxDestructionStressBond& b,PxVec3& o0,PxVec3& o1){
    const auto& c0=s.chunks[b.chunk0];const auto& c1=s.chunks[b.chunk1];
    if(c0.mass<=0){o1=b.centroid-c1.position;o0=-o1;}
    else if(c1.mass<=0){o0=b.centroid-c0.position;o1=-o0;}
    else{o0=(c1.position-c0.position)*0.5f;o1=-o0;}
}
// The elastic solution: minimum sum |lin|^2/w^2 + |ang|^2/(w L)^2 subject to
// every dynamic chunk in equilibrium, in double (the stress solve's answer).
std::vector<PxDestructionVectorPair> elastic(const Structure& s,const std::vector<PxVec3>& F,const std::vector<PxVec3>& T){
    const size_t m=s.bonds.size();std::vector<int> row(s.chunks.size(),-1);int rows=0;
    for(size_t i=0;i<s.chunks.size();++i)if(s.chunks[i].mass>0)row[i]=6*rows++;
    const int R=6*rows,C=int(6*m);
    double L=0;int count=0;
    for(const auto& b:s.bonds){PxVec3 o0,o1;offsets(s,b,o0,o1);
        if(s.chunks[b.chunk0].mass>0){L+=o0.magnitude();++count;}if(s.chunks[b.chunk1].mass>0){L+=o1.magnitude();++count;}}
    L=count?L/count:1.0;
    std::vector<double> A(size_t(R)*C,0.0),W(C,0.0);
    for(size_t k=0;k<m;++k){
        const auto& b=s.bonds[k];PxVec3 o0,o1;offsets(s,b,o0,o1);
        const double w=b.complianceScale;for(int q=0;q<3;++q){W[6*k+q]=w*w;W[6*k+3+q]=w*w*L*L;}
        for(int e=0;e<2;++e){const int r=row[e?b.chunk1:b.chunk0];if(r<0)continue;const PxVec3 o=e?o1:o0;const double sgn=e?-1:1;
            // force rows: sgn * lin; torque rows: sgn*(o x lin - ang)
            for(int q=0;q<3;++q){A[size_t(r+q)*C+6*k+q]+=sgn;A[size_t(r+3+q)*C+6*k+3+q]+=-sgn;}
            const double X[3][3]={{0,-o.z,o.y},{o.z,0,-o.x},{-o.y,o.x,0}};
            for(int a=0;a<3;++a)for(int c=0;c<3;++c)A[size_t(r+3+a)*C+6*k+c]+=sgn*X[a][c];}
    }
    std::vector<double> K(size_t(R)*R,0.0),rhs(R,0.0);
    for(int i=0;i<R;++i)for(int j=0;j<R;++j){double v=0;for(int c=0;c<C;++c)v+=A[size_t(i)*C+c]*W[c]*A[size_t(j)*C+c];K[size_t(i)*R+j]=v;}
    for(size_t i=0;i<s.chunks.size();++i)if(row[i]>=0){const int r=row[i];
        rhs[r]=-F[i].x;rhs[r+1]=-F[i].y;rhs[r+2]=-F[i].z;rhs[r+3]=-T[i].x;rhs[r+4]=-T[i].y;rhs[r+5]=-T[i].z;}
    // Gaussian elimination, partial pivoting.
    std::vector<double> y=rhs;
    for(int c=0;c<R;++c){int p=c;for(int i=c+1;i<R;++i)if(std::fabs(K[size_t(i)*R+c])>std::fabs(K[size_t(p)*R+c]))p=i;
        if(p!=c){for(int j=0;j<R;++j)std::swap(K[size_t(c)*R+j],K[size_t(p)*R+j]);std::swap(y[c],y[p]);}
        const double d=K[size_t(c)*R+c];if(std::fabs(d)<1e-300)throw std::runtime_error("singular elastic system");
        for(int i=c+1;i<R;++i){const double f=K[size_t(i)*R+c]/d;if(f==0)continue;for(int j=c;j<R;++j)K[size_t(i)*R+j]-=f*K[size_t(c)*R+j];y[i]-=f*y[c];}}
    for(int c=R-1;c>=0;--c){double v=y[c];for(int j=c+1;j<R;++j)v-=K[size_t(c)*R+j]*y[j];y[c]=v/K[size_t(c)*R+c];}
    std::vector<PxDestructionVectorPair> J(m);
    for(size_t k=0;k<m;++k){double x[6];for(int q=0;q<6;++q){double v=0;for(int i=0;i<R;++i)v+=A[size_t(i)*C+6*k+q]*y[i];x[q]=W[6*k+q]*v;}
        J[k].linear=PxVec3(float(x[0]),float(x[1]),float(x[2]));J[k].angular=PxVec3(float(x[3]),float(x[4]),float(x[5]));}
    return J;
}

// The stress solve's length scale: the mean distance from a dynamic chunk to
// its bonds' application points.
float lengthScale(const Structure& s){
    double L=0;int count=0;
    for(const auto& b:s.bonds){PxVec3 o0,o1;offsets(s,b,o0,o1);
        if(s.chunks[b.chunk0].mass>0){L+=o0.magnitude();++count;}if(s.chunks[b.chunk1].mass>0){L+=o1.magnitude();++count;}}
    return count?float(L/count):1.0f;
}
// Island labels as the stress topology publishes them: minimum dynamic node of
// each component joined by bonds between dynamic chunks; anchors UINT32_MAX.
void islands(const Structure& s,std::vector<PxU32>& node,std::vector<PxU32>& bond){
    const size_t n=s.chunks.size();std::vector<PxU32> parent(n);for(size_t i=0;i<n;++i)parent[i]=PxU32(i);
    auto root=[&](PxU32 i){while(parent[i]!=i)i=parent[i];return i;};
    for(const auto& b:s.bonds)if(s.chunks[b.chunk0].mass>0 && s.chunks[b.chunk1].mass>0){
        const PxU32 a=root(b.chunk0),c=root(b.chunk1);parent[std::max(a,c)]=std::min(a,c);}
    node.assign(n,0xffffffffu);
    for(size_t i=0;i<n;++i)if(s.chunks[i].mass>0)node[i]=root(PxU32(i));
    bond.assign(s.bonds.size(),0xffffffffu);
    for(size_t k=0;k<s.bonds.size();++k){const auto& b=s.bonds[k];bond[k]=s.chunks[b.chunk0].mass>0?node[b.chunk0]:node[b.chunk1];}
}

// The stage's evaluation of one structure under `F`/`T` from a state `base`
// (forces that balanced the previous loads): elastic forces, then E, then the
// material kernels on what E leaves. Returns the forces the materials used.
struct Result {
    std::vector<PxDestructionVectorPair> elastic,forces;
    std::vector<PxDestructionBondVerdict> verdicts;
    std::vector<PxU32> impact;std::vector<float> accel,rowDelta,slip; impact::Status status{};
    std::vector<PxU32> carried;  // per bond: its island was solved or carried (the next tick's plastic state)
};
// The plastic state carried from the last evaluation (Result::forces, carried, slip).
struct Carry { std::vector<PxDestructionVectorPair> elasticBase; std::vector<PxU32> carried; std::vector<float> slip; };
// The solver's application point of bond b (the chunks' midpoint, or the centroid at a support).
PxVec3 solverPoint(const Structure& s,const PxDestructionStressBond& b){
    PxVec3 o0,o1;offsets(s,b,o0,o1);
    return s.chunks[b.chunk0].mass>0?s.chunks[b.chunk0].position+o0:s.chunks[b.chunk1].position+o1;
}
// Wrenches reported at each bond's centroid (section rotational stiffness):
// M_c = M_P + (c - P) x F; `back` undoes it.
std::vector<PxDestructionVectorPair> atCentroid(const Structure& s,std::vector<PxDestructionVectorPair> J,bool back=false){
    for(size_t k=0;k<J.size();++k){const auto& b=s.bonds[k];const PxVec3 t=(b.centroid-solverPoint(s,b)).cross(J[k].linear);
        J[k].angular+=back?-t:t;}
    return J;
}
// centroid: the elastic forces and the base reported at the bonds' centroids,
// as the stress solve reports them with section rotational stiffness (E's
// settings.solverAtCentroid and the material kernel's momentAtCentroid say so);
// Result's forces are then in that convention too.
Result evaluate(const Structure& s,const std::vector<PxVec3>& F,const std::vector<PxVec3>& T,
    std::vector<PxDestructionVectorPair> base,bool withImpact,impact::Settings settings=impact::Settings{},bool centroid=false,const Carry* carry=nullptr){
    const PxU32 n=PxU32(s.chunks.size()),m=PxU32(s.bonds.size());
    Result out;out.elastic=elastic(s,F,T);
    if(centroid){out.elastic=atCentroid(s,out.elastic);base=atCentroid(s,base);}
    std::vector<PxU32> begin(n+1,0),refs(2*m);
    for(const auto& b:s.bonds){++begin[b.chunk0+1];++begin[b.chunk1+1];}
    for(PxU32 i=0;i<n;++i)begin[i+1]+=begin[i];
    auto cursor=begin;for(PxU32 k=0;k<m;++k){refs[cursor[s.bonds[k].chunk0]++]=k;refs[cursor[s.bonds[k].chunk1]++]=k;}
    std::vector<PxU32> nodeIsland,bondIsland;islands(s,nodeIsland,bondIsland);
    std::vector<PxDestructionVectorPair> inputs(n);
    for(PxU32 i=0;i<n;++i)if(s.chunks[i].mass>0){inputs[i].linear=F[i]/s.chunks[i].mass;inputs[i].angular=-T[i]/s.chunks[i].inertia;}
    std::vector<float> health(m);for(PxU32 k=0;k<m;++k)health[k]=s.bonds[k].health;
    Device<PxDestructionStressChunk> chunks(s.chunks);Device<PxDestructionStressBond> bonds(s.bonds);
    Device<PxDestructionMaterial> materials(s.materials);Device<float> slip(s.ductile),dHealth(health);
    Device<PxU32> dBegin(begin),dRefs(refs),dNode(nodeIsland),dBond(bondIsland);
    Device<PxDestructionVectorPair> dInputs(inputs),dElastic(out.elastic),dBase(base);
    Device<PxDestructionStageStatus> stage(1);Device<PxDestructionBondVerdict> verdicts(m);Device<PxVec3> centroids(m);
    const bool sectionVerdict=!s.sections.empty();
    Device<PxDestructionBondSection> dSections(sectionVerdict?s.sections:std::vector<PxDestructionBondSection>(1));
    cudaStream_t stream;check(cudaStreamCreateWithFlags(&stream,cudaStreamNonBlocking));
    impact::Stage e;e.allocate(n,m);settings.lengthScale=lengthScale(s);
    impact::Inputs in{};in.chunks=chunks.p;in.chunkCount=n;in.bonds=bonds.p;in.bondCount=m;in.materials=materials.p;in.ductileSlip=slip.p;
    in.health=dHealth.p;in.nodeBegin=dBegin.p;in.nodeRefs=dRefs.p;in.nodeIslands=dNode.p;in.bondIslands=dBond.p;
    in.accelerations=dInputs.p;in.elastic=dElastic.p;in.base=dBase.p;in.stage=stage.p;
    if(settings.sectionBending)in.sections=dSections.p;
    Device<impact::ContactRow> dRows(s.rows.empty()?std::vector<impact::ContactRow>(1):s.rows);
    Device<float> dDelta(6*std::max<size_t>(s.rows.size(),1));
    if(!s.rows.empty()){in.rows=dRows.p;in.rowCount=PxU32(s.rows.size());in.rowDelta=dDelta.p;}
    Device<PxDestructionVectorPair> dElasticBase(carry?carry->elasticBase:std::vector<PxDestructionVectorPair>(1));
    Device<PxU32> dCarried(carry?carry->carried:std::vector<PxU32>(1));Device<float> dSlip(carry?carry->slip:std::vector<float>(1));
    if(carry){in.elasticBase=dElasticBase.p;in.carried=dCarried.p;in.slipBefore=dSlip.p;}
    impact::View view{};
#ifndef PX_IMPACT_TODAY
    if(withImpact){e.submit(in,settings,stream);view={e.w.islandFlag,dBond.p,e.w.forces,e.w.verdict};}
#else
    (void)withImpact;(void)settings;
#endif
    evaluateBondMaterials<<<(m+127)/128,128,0,stream>>>(chunks.p,bonds.p,materials.p,dHealth.p,dElastic.p,m,settings.dt,2.0f,
        settings.bendGainMax,true,verdicts.p,centroids.p,stage.p,sectionVerdict,sectionVerdict?dSections.p:nullptr,centroid,view);
    check(cudaStreamSynchronize(stream));check(cudaGetLastError());
    out.verdicts=verdicts.get();
    out.forces=out.elastic;out.impact.assign(m,impact::eNONE);out.accel.assign(6*size_t(n),0.0f);
#ifndef PX_IMPACT_TODAY
    if(withImpact){
        auto flags=std::vector<PxU32>(n);check(cudaMemcpy(flags.data(),e.w.islandFlag,n*sizeof(PxU32),cudaMemcpyDeviceToHost));
        std::vector<PxDestructionVectorPair> f(m);check(cudaMemcpy(f.data(),e.w.forces,m*sizeof(f[0]),cudaMemcpyDeviceToHost));
        std::vector<PxU32> v(m);check(cudaMemcpy(v.data(),e.w.verdict,m*sizeof(PxU32),cudaMemcpyDeviceToHost));
        check(cudaMemcpy(out.accel.data(),e.w.u,6*n*sizeof(float),cudaMemcpyDeviceToHost));
        check(cudaMemcpy(&out.status,e.w.status,sizeof(out.status),cudaMemcpyDeviceToHost));
        out.carried.assign(m,0u);out.slip.assign(m,0.0f);
        std::vector<float> slip(m);check(cudaMemcpy(slip.data(),e.w.slip,m*sizeof(float),cudaMemcpyDeviceToHost));
        for(PxU32 k=0;k<m;++k)if(bondIsland[k]!=0xffffffffu && flags[bondIsland[k]]){out.forces[k]=f[k];out.impact[k]=v[k];out.carried[k]=1u;
            out.slip[k]=(carry?carry->slip[k]:0.0f)+((flags[bondIsland[k]]&1u)?slip[k]:0.0f);}
    }
#endif
    out.rowDelta=dDelta.get();
    e.release();cudaStreamDestroy(stream);
    return out;
}

// Utilisation as the oracle (and E's capacity) defines it, host side.
float utilisation(const Structure& s,PxU32 k,const PxDestructionVectorPair& f,float gainMax=3.0f){
    const auto& b=s.bonds[k];PxVec3 d=s.chunks[b.chunk1].position-s.chunks[b.chunk0].position;
    PxVec3 n=b.normal*(b.normal.dot(d)<0?-1.0f:1.0f);n.normalize();const float a=b.health;
    // The moment about the centroid, where the section is (the solver reports it about P).
    PxVec3 o0,o1;offsets(s,b,o0,o1);
    const PxVec3 P=s.chunks[b.chunk0].mass>0?s.chunks[b.chunk0].position+o0:s.chunks[b.chunk1].position+o1;
    const PxVec3 moment=f.angular+(b.centroid-P).cross(f.linear);
    const float N=f.linear.dot(n)/a,V=(f.linear-n*f.linear.dot(n)).magnitude()/a;
    const float Tw=std::fabs(moment.dot(n))/a,M=(moment-n*moment.dot(n)).magnitude()/a;
    const float gb=std::min(6.0f/std::sqrt(a),gainMax),gt=std::min(4.81f/std::sqrt(a),gainMax);
    const float bend=M*gb,t=std::max(N+bend,0.0f),c=std::max(bend-N,0.0f),sh=V+gt*Tw;
    const auto& m=s.materials[b.material];
    return std::max({c/m.compressionFatalLimit,t/m.tensionFatalLimit,sh/m.shearFatalLimit});
}

// 1. A two-chunk column, its one joint pushed past capacity: the free chunk's
// post-tick momentum is the push minus the joint's capacity times dt, and the
// joint carries exactly its capacity (ductile, slip under its ultimate slip),
// or fractures (brittle). Today: the static solve puts the whole push in it.
void column(){
    std::printf("two-chunk column, pushed past its joint's capacity\n");
    for(int ductile=0;ductile<2;++ductile)for(float push:{20e3f,30e3f}) {
        Structure s;const PxU32 anchor=s.chunk(PxVec3(0,0,0),0,0),top=s.chunk(PxVec3(0,1,0),100,10);
        // 1 MPa tension over 0.01 m^2: a 10 kN joint; 15 mm ultimate slip when ductile.
        const PxU32 mat=s.material(10e6f,1e6f,1e6f,ductile?0.015f:0.0f);
        s.bond(anchor,top,PxVec3(0,0.5f,0),PxVec3(0,1,0),0.01f,mat);
        s.gravity();
        const auto rest=elastic(s,s.force,s.torque);
        auto F=s.force;F[top]+=PxVec3(0,push,0);
        const auto r=evaluate(s,F,s.torque,rest,true);
        const float cap=10e3f,net=push-981.0f;
        char text[256];
        const float carried=r.forces[0].linear.dot(PxVec3(0,1,0));
        // Ductile: slip = 1/2 a dt^2, a = (net - cap)/m: 12.5 mm at 20 kN (holds), 26 mm at 30 kN (breaks).
        const float a=(net-cap)/100.0f,slip=0.5f*a/3600.0f;
        if(ductile && slip<0.015f) {
            std::snprintf(text,sizeof text,"ductile, %.0f kN push: joint carries %.0f N (capacity %.0f), elastic %.0f",push/1e3f,carried,cap,
                r.elastic[0].linear.dot(PxVec3(0,1,0)));
            expect(std::fabs(carried-cap)<0.005f*cap,text);
            std::snprintf(text,sizeof text,"  free chunk's post-tick momentum %.1f N s, expected (push - mg - capacity) dt = %.1f",
                r.accel[6*top+1]*100.0f/60.0f,(net-cap)/60.0f);
            expect(std::fabs(r.accel[6*top+1]*100.0f-(net-cap))<0.01f*(net-cap),text);
            expect(r.impact[0]==impact::eYIELDED && r.verdicts[0].health>0,"  verdict: yielded, not broken");
        } else {
            std::snprintf(text,sizeof text,"%s, %.0f kN push (slip %.1f mm): the joint breaks",ductile?"ductile":"brittle",push/1e3f,slip*1e3f);
            expect(r.impact[0]==impact::eBROKEN && r.verdicts[0].health<=0,text);
            std::snprintf(text,sizeof text,"  free chunk's post-tick momentum %.1f N s = (push - mg) dt = %.1f",r.accel[6*top+1]*100.0f/60.0f,net/60.0f);
            expect(std::fabs(r.accel[6*top+1]*100.0f-net)<0.01f*net,text);
        }
    }
}

// 2. A three-layer wall: a brick skin on its footing, a wall tie across the
// cavity to a timber stud nailed to its sole plate. A hit on the skin that
// fails the skin's joints (brittle mortar and tie) leaves the stud's joint
// below capacity. Today: the static solve sends the hit to every anchor, and
// the stud's joint is past fatal.
Structure wallStructure(){
    Structure s;
    const PxU32 footing=s.chunk(PxVec3(0,-0.1f,0),0,0),plate=s.chunk(PxVec3(0,-0.1f,0.15f),0,0),head=s.chunk(PxVec3(0,1.1f,0.15f),0,0);
    const PxU32 brick=s.chunk(PxVec3(0,0.5f,0),110,9.4f);            // a 1 x 1 x 0.11 m panel of brick veneer, 1900 kg/m^3
    const PxU32 stud=s.chunk(PxVec3(0,0.5f,0.15f),1.7f,0.14f);       // a 45 x 90 mm C24 stud, 1 m, 420 kg/m^3
    // EN 1996-1-1 mortar: 0.3 MPa flexural tension and bed shear; a wall tie
    // pulls out or buckles at ~1-2 kN; two 3.15 mm nails ~1.5 kN (EN 1995-1-1).
    const PxU32 mortar=s.material(6.8e6f,0.3e6f,0.3e6f,0.0f),tieMat=s.material(2e3f/1e-5f,1.5e3f/1e-5f,1e3f/1e-5f,0.0f);
    const PxU32 nailed=s.material(2.5e6f,1.5e3f/4e-3f,1.5e3f/4e-3f,0.015f);
    // Stiffness weights as the bridge forms them, w = sqrt(E/30 GPa A/L):
    // masonry E 6.8 GPa, a steel tie (200 GPa, 10 mm^2, 40 mm cavity), a nailed
    // joint as stiff as cross-grain timber in bearing (0.37 GPa).
    auto weight=[](float E,float A,float L){return std::sqrt(E/30e9f*A/L);};
    s.bond(footing,brick,PxVec3(0,0,0),PxVec3(0,1,0),0.11f,mortar,weight(6.8e9f,0.11f,0.6f));
    s.bond(brick,stud,PxVec3(0,0.5f,0.075f),PxVec3(0,0,1),1e-5f,tieMat,weight(200e9f,1e-5f,0.04f));
    // The stud is nailed to its sole plate and its head plate (the rest of the frame).
    s.bond(plate,stud,PxVec3(0,0,0.15f),PxVec3(0,1,0),4e-3f,nailed,weight(0.37e9f,4e-3f,0.5f));
    s.bond(stud,head,PxVec3(0,1.0f,0.15f),PxVec3(0,1,0),4e-3f,nailed,weight(0.37e9f,4e-3f,0.5f));
    s.gravity();
    (void)footing;(void)plate;(void)head;(void)stud;
    return s;
}
constexpr PxU32 kWallBrick=3;
void wall(){
    std::printf("skin, tie and frame: a hit on the skin\n");
    const Structure s=wallStructure();const PxU32 brick=kWallBrick;
    const auto rest=elastic(s,s.force,s.torque);
    float restUse=0;for(PxU32 k=0;k<s.bonds.size();++k)restUse=std::max(restUse,utilisation(s,k,rest[k]));
    char text[256];std::snprintf(text,sizeof text,"at rest the wall stands (largest utilisation %.2f)",restUse);expect(restUse<1.0f,text);
    // A 100 kg ball at 60 m/s stopped in one tick: M v / dt = 360 kN on the brick.
    auto F=s.force;F[brick]+=PxVec3(0,0,360e3f);
    const auto today=elastic(s,F,s.torque);
    const auto r=evaluate(s,F,s.torque,rest,true);
    const float todayUse=std::max(utilisation(s,2,today[2]),utilisation(s,3,today[3]));
    std::snprintf(text,sizeof text,"today's elastic solve: the stud's joints at %.0fx their capacity",todayUse);
    expect(todayUse>1.0f,text);
    std::snprintf(text,sizeof text,"E: mortar %s, tie %s",r.impact[0]==impact::eBROKEN?"broken":"held",r.impact[1]==impact::eBROKEN?"broken":"held");
    expect(r.impact[0]==impact::eBROKEN && r.impact[1]==impact::eBROKEN,text);
    const float use=std::max(utilisation(s,2,r.forces[2]),utilisation(s,3,r.forces[3]));
    std::snprintf(text,sizeof text,"E: the stud's joints at %.2f of capacity, not broken (%u solves, %u iterations, %u capped)",
        use,r.status.solves,r.status.iterations,r.status.capped);
    expect(use<1.0f && r.verdicts[2].health>0 && r.verdicts[3].health>0,text);
}

// 3. At rest: nothing past capacity, so no island is solved and the material
// verdicts are bit for bit today's.
void rest(){
    std::printf("at rest: verdicts identical to today's\n");
    Structure s;const PxU32 mat=s.material(20e6f,2e6f,2e6f,0.0f),nail=s.material(2.5e6f,0.5e6f,0.5e6f,0.015f);
    std::vector<PxU32> ground;for(int x=0;x<4;++x)ground.push_back(s.chunk(PxVec3(float(x),-0.5f,0),0,0));
    std::vector<PxU32> grid;
    for(int y=0;y<4;++y)for(int x=0;x<4;++x)grid.push_back(s.chunk(PxVec3(float(x),0.5f+y,0),200,30));
    for(int y=0;y<4;++y)for(int x=0;x<4;++x){
        const PxU32 c=grid[4*y+x];
        if(x<3)s.bond(c,grid[4*y+x+1],PxVec3(x+0.5f,0.5f+y,0),PxVec3(1,0,0),0.2f,(x+y)%2?mat:nail);
        if(y<3)s.bond(c,grid[4*(y+1)+x],PxVec3(float(x),1.0f+y,0),PxVec3(0,1,0),0.2f,mat);
        if(!y)s.bond(ground[x],c,PxVec3(float(x),0,0),PxVec3(0,1,0),0.2f,mat);
    }
    s.gravity();
    const auto rest=elastic(s,s.force,s.torque);
    const auto a=evaluate(s,s.force,s.torque,rest,false),b=evaluate(s,s.force,s.torque,rest,true);
    expect(b.status.triggered==0,"no island solved");
    expect(a.verdicts.size()==b.verdicts.size() && !std::memcmp(a.verdicts.data(),b.verdicts.data(),sizeof(a.verdicts[0])*a.verdicts.size()),
        "material verdicts bit-identical with E on");
    // A load that brings bonds past their elastic limit but not to capacity
    // damages them (the sub-fatal rate) exactly as today.
    // The largest of these side loads on the top corner that stays under capacity.
    auto F=s.force;float largest=0;
    for(float load:{10e3f,20e3f,40e3f,60e3f,80e3f,120e3f,160e3f}) {
        auto G=s.force;G[grid[15]]+=PxVec3(load,0,0);const auto J=elastic(s,G,s.torque);
        float use=0;for(PxU32 k=0;k<s.bonds.size();++k)use=std::max(use,utilisation(s,k,J[k]));
        if(use<0.95f){F=G;largest=use;}
    }
    const auto c=evaluate(s,F,s.torque,rest,false),d=evaluate(s,F,s.torque,rest,true);
    PxU32 commands=0;for(const auto& v:c.verdicts)commands+=v.command;
    char text[160];std::snprintf(text,sizeof text,"under capacity (largest utilisation %.2f) with %u bonds past elastic: verdicts bit-identical",largest,commands);
    expect(d.status.triggered==0 && commands>0 && !std::memcmp(c.verdicts.data(),d.verdicts.data(),sizeof(c.verdicts[0])*c.verdicts.size()),text);
}

// 4. With section rotational stiffness the stress solve reports every bond's
// wrench at its centroid. E fed that convention (solverAtCentroid) is the same
// solve as E fed the midpoint convention with its wrench point moved to the
// centroid (momentAtCentroid): the same breaks, and the same forces once
// converted -- the wall's hit, where E breaks the mortar and the tie.
void centroidConvention(){
    std::printf("E fed wrenches at the bonds' centroids (section rotational stiffness)\n");
    Structure s;
    const PxU32 footing=s.chunk(PxVec3(0,-0.1f,0),0,0),plate=s.chunk(PxVec3(0,-0.1f,0.15f),0,0),head=s.chunk(PxVec3(0,1.1f,0.15f),0,0);
    const PxU32 brick=s.chunk(PxVec3(0,0.5f,0),110,9.4f),stud=s.chunk(PxVec3(0,0.5f,0.15f),1.7f,0.14f);
    const PxU32 mortar=s.material(6.8e6f,0.3e6f,0.3e6f,0.0f),tieMat=s.material(2e3f/1e-5f,1.5e3f/1e-5f,1e3f/1e-5f,0.0f);
    const PxU32 nailed=s.material(2.5e6f,1.5e3f/4e-3f,1.5e3f/4e-3f,0.015f);
    auto weight=[](float E,float A,float L){return std::sqrt(E/30e9f*A/L);};
    s.bond(footing,brick,PxVec3(0,0,0),PxVec3(0,1,0),0.11f,mortar,weight(6.8e9f,0.11f,0.6f));
    // Off the chunks' midpoint, so the two conventions differ for this bond.
    s.bond(brick,stud,PxVec3(0,0.8f,0.075f),PxVec3(0,0,1),1e-5f,tieMat,weight(200e9f,1e-5f,0.04f));
    s.bond(plate,stud,PxVec3(0,0,0.15f),PxVec3(0,1,0),4e-3f,nailed,weight(0.37e9f,4e-3f,0.5f));
    s.bond(stud,head,PxVec3(0,1.0f,0.15f),PxVec3(0,1,0),4e-3f,nailed,weight(0.37e9f,4e-3f,0.5f));
    s.gravity();
    const auto rest=elastic(s,s.force,s.torque);
    char text[256];
    for(float hit:{0.0f,360e3f}) {
        auto F=s.force;F[brick]+=PxVec3(0,0,hit);
        impact::Settings midpoint;midpoint.momentAtCentroid=true;
        impact::Settings centroid;centroid.solverAtCentroid=true;
        const auto a=evaluate(s,F,s.torque,rest,true,midpoint),b=evaluate(s,F,s.torque,rest,true,centroid,true);
        const auto bf=atCentroid(s,b.forces,true);
        float worst=0,scale=0;
        for(size_t k=0;k<s.bonds.size();++k){
            worst=std::max({worst,(a.forces[k].linear-bf[k].linear).magnitude(),(a.forces[k].angular-bf[k].angular).magnitude()});
            scale=std::max({scale,a.forces[k].linear.magnitude(),a.forces[k].angular.magnitude()});
        }
        bool same=a.status.triggered==b.status.triggered && a.status.broken==b.status.broken;
        for(size_t k=0;k<s.bonds.size();++k)same=same && a.impact[k]==b.impact[k] && (a.verdicts[k].health>0)==(b.verdicts[k].health>0);
        std::snprintf(text,sizeof text,"%.0f kN hit: %u islands solved, %u broken in both; forces agree to %.1e of the largest (%.0f N)",
            hit/1e3f,b.status.triggered,b.status.broken,scale>0?worst/scale:0.0f,scale);
        expect(same && worst<=2e-4f*scale,text);
        if(hit>0)expect(b.status.triggered>0 && b.impact[0]==impact::eBROKEN && b.impact[1]==impact::eBROKEN,"  the hit is E's: mortar and tie broken");
    }
}

// 5. Ci: crush by the impact's contact pressure Z1 Z2 / (Z1 + Z2) v through the
// masonry crush law (town-kit materials.mjs CRUSH, EN 1996-1-1 f_k 6.8 MPa).
// A steel ball at 60 m/s crushes a brick chunk (~200 MPa against a one-tick
// threshold of ~25 MPa); the same ball at 1 m/s does not; a truck's front,
// whose own crush caps it at 0.16 MPa (EN 1991-1-7 Annex C), does not.
__global__ void impactCrushProbe(PxDestructionCrushProperties m,const float* cases,PxU32 count,float* out)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    const float sigma=impact::impactStress(cases[2*i],1900.0f*sqrtf(6.8e9f/1900.0f),cases[2*i+1]);
    const auto next=impact::crushByImpact(sigma,0.11f*0.5f,105.0f,0.0f,1.0f/60.0f,m,ExtStressCrushState{0,0,0,0,false});
    out[3*i]=sigma;out[3*i+1]=next.damage;out[3*i+2]=next.crushed?1.0f:0.0f;
}
void impactCrush(){
    std::printf("Ci: crush by impact pressure\n");
    PxDestructionCrushProperties m{};const float fc=6.8e6f,k=1.2f;
    m.capPressure=2.5f*fc;m.cohesion=fc*(1-k/3);m.frictionSlope=k;m.crushEnergy=3.5e6f;m.crushViscosity=5.9e5f;
    const float steel=7850.0f*std::sqrt(210e9f/7850.0f),truck=21.7f*std::sqrt(300e3f*5000.0f)/(3.3f*1.6f)/21.7f;
    const std::vector<float> cases={steel,60.0f, steel,1.0f, truck,21.7f};
    Device<float> c(cases),out(9);
    impactCrushProbe<<<1,32>>>(m,c.p,3,out.p);check(cudaDeviceSynchronize());
    const auto r=out.get();char text[160];
    std::snprintf(text,sizeof text,"steel ball at 60 m/s: %.0f MPa, crushed",r[0]/1e6f);expect(r[2]>0.5f,text);
    std::snprintf(text,sizeof text,"steel ball at 1 m/s: %.1f MPa, not crushed",r[3]/1e6f);expect(r[5]<0.5f,text);
    std::snprintf(text,sizeof text,"truck front at 21.7 m/s: %.2f MPa, not crushed",r[6]/1e6f);expect(r[8]<0.5f && std::fabs(r[6]-0.159e6f)<0.01e6f,text);
}

// 5. The section model (PX_DESTRUCTION_SECTION_BENDING): a 45 x 90 mm post
// standing on its plate, pushed sideways 1.2 m up, past its section's
// bending capacity (|M|/S) though far under the capped-gain formula's
// (3 |M|/A, ~20-40x weaker); a light trim piece on it, pulled off, puts the
// island past capacity whichever formula reads it, so the impact solve runs.
// The elastic verdict breaks the stud's joints; the impact solve, reading the
// same sections, must break them too.
void section(){
    std::printf("section model: a stud past its section's bending capacity\n");
    Structure s;
    const PxU32 plate=s.chunk(PxVec3(0,-0.05f,0),0,0),head=s.chunk(PxVec3(0,2.45f,0),0,0);
    const PxU32 stud=s.chunk(PxVec3(0,1.2f,0),4.0f,1.9f),trim=s.chunk(PxVec3(0,1.2f,0.07f),1.0f,0.01f);
    const PxU32 timber=s.material(21e6f,24e6f,10e6f,0.0f),glue=s.material(1e6f,1e5f,1e5f,0.0f);
    const float b=0.045f,h=0.09f,A=b*h;
    PxDestructionBondSection sec;sec.axis=PxVec3(1,0,0);sec.bendModulus0=b*h*h/6;sec.bendModulus1=h*b*b/6;
    sec.twistModulus=b*h*(b*b+h*h)/(6*std::sqrt(b*b+h*h));sec.gyration0=h/std::sqrt(12.0f);sec.gyration1=b/std::sqrt(12.0f);
    sec.polarGyration=std::sqrt((b*b+h*h)/12);
    s.bond(plate,stud,PxVec3(0,0,0),PxVec3(0,1,0),A,timber);s.sections.push_back(sec);
    (void)head;
    s.bond(stud,trim,PxVec3(0,1.2f,0.045f),PxVec3(0,0,1),1e-4f,glue);s.sections.push_back(PxDestructionBondSection{});
    s.gravity();
    const auto rest=elastic(s,s.force,s.torque);
    auto F=s.force;F[stud]+=PxVec3(0,0,5e3f);F[trim]+=PxVec3(0,0,1e3f);
    impact::Settings on;on.sectionBending=true;if(const char* it=std::getenv("IMPACT_TEST_ITERATIONS"))on.iterations=PxU32(std::atoi(it));
    const auto today=evaluate(s,F,s.torque,rest,false,on);
    const auto r=evaluate(s,F,s.torque,rest,true,on);
    impact::Settings capped;capped.sectionBending=false;
    const auto old=evaluate(s,F,s.torque,rest,true,capped);
    char text[200];
    for(int k=0;k<2;++k)std::printf("    bond %d: normal %.2f MPa shear %.2f MPa bend %.2f MPa; elastic lin %.0f %.0f %.0f ang %.0f %.0f %.0f\n",k,
        today.verdicts[k].stressNormal/1e6f,today.verdicts[k].stressShear/1e6f,today.verdicts[k].stressBend/1e6f,
        today.elastic[k].linear.x,today.elastic[k].linear.y,today.elastic[k].linear.z,today.elastic[k].angular.x,today.elastic[k].angular.y,today.elastic[k].angular.z);
    std::snprintf(text,sizeof text,"the elastic (section) verdict breaks the post's joint (%s)",today.verdicts[0].health<=0?"broken":"held");
    expect(today.verdicts[0].health<=0,text);
    std::snprintf(text,sizeof text,"the impact solve with the section model agrees (%s; %u islands solved)",
        r.verdicts[0].health<=0?"broken":"held",r.status.triggered);
    expect(r.status.triggered==1 && r.verdicts[0].health<=0,text);
    std::printf("    E verdict %u, %u; E forces lin %.0f %.0f %.0f ang %.0f %.0f %.0f; solves %u its %u capped %u rounds %u\n",r.impact[0],r.impact[1],
        r.forces[0].linear.x,r.forces[0].linear.y,r.forces[0].linear.z,r.forces[0].angular.x,r.forces[0].angular.y,r.forces[0].angular.z,
        r.status.solves,r.status.iterations,r.status.capped,r.status.rounds);
    std::printf("    (with the capped-gain cones instead, the impact solve %s it)\n",old.verdicts[0].health>0?"holds":"breaks");
}

// 6. The coupled contact (design step 2): a 1000 kg body at 10 m/s strikes a
// 10 kg chunk standing on an anchor through one joint of 60 kN shear capacity.
// The trial (the anchored cluster kinematic) stops the body in the tick: 600
// kN on the chunk. With the body in the solve, the joint passes on at most its
// capacity over the tick: body and chunk keep p - cap dt = 9000 N s between
// them (8.91 m/s), the joint yielding (ductile) -- or p, the joint broken at
// capacity (brittle: 9.90 m/s). Today (and uncoupled): the body keeps nothing.
void coupled(){
    std::printf("coupled contact: a body pushing a capacity-limited joint\n");
    for(int ductile=0;ductile<2;++ductile) {
        Structure s;const PxU32 anchor=s.chunk(PxVec3(0,0,0),0,0),wall=s.chunk(PxVec3(0,0.5f,0),10.0f,0.5f);
        // 60 kN in shear over 0.01 m^2; compression and tension out of reach.
        const PxU32 mat=s.material(1e12f,1e12f,6e6f,ductile?1.0f:0.0f);
        s.bond(anchor,wall,PxVec3(0,0.25f,0),PxVec3(0,1,0),0.01f,mat);
        const float M=1000.0f,v=10.0f,dt=1.0f/60.0f,cap=60e3f;
        impact::ContactRow row{};row.chunk=wall;row.body=0;row.points=4;row.friction=0.0f;
        const float point[3]={-0.25f,0.5f,0},com[3]={-1.0f,0.5f,0};
        for(int q=0;q<3;++q){row.point[q]=point[q];row.com[q]=com[q];}
        row.normal[0]=1;row.load[0]=M*v/dt;row.velocity[0]=v;row.dv[0]=-v;row.im=1.0f/M;
        row.ii[0]=row.ii[1]=row.ii[2]=1.0f/400.0f;
        s.rows.push_back(row);
        const auto rest=elastic(s,s.force,s.torque);
        auto F=s.force;F[wall]+=PxVec3(row.load[0],0,0);
        impact::Settings settings;if(std::getenv("IMPACT_TEST_UNCOUPLED"))settings.coupledContact=false;
        const auto r=evaluate(s,F,s.torque,rest,true,settings);
        const float expected=ductile?(M*v-cap*dt)/(M+10.0f):M*v/(M+10.0f);
        const float kept=r.rowDelta[0];   // the trial left it at rest: the change is its end velocity
        char text[240];
        std::snprintf(text,sizeof text,"%s joint: the body keeps %.3f m/s, expected %s = %.3f (%u contacts, %u solves, %u capped, %u diverged, %u infeasible)",
            ductile?"ductile":"brittle",kept,ductile?"(p - cap dt)/(M + m)":"p/(M + m)",expected,r.status.contacts,r.status.solves,r.status.capped,r.status.diverged,r.status.infeasible);
        expect(std::fabs(kept-expected)<0.01f*expected,text);
        std::snprintf(text,sizeof text,"  the chunk moves with it: %.3f m/s",r.accel[6*wall]*dt);
        expect(std::fabs(r.accel[6*wall]*dt-expected)<0.01f*expected,text);
        expect(ductile?(r.impact[0]==impact::eYIELDED && r.verdicts[0].health>0):(r.impact[0]==impact::eBROKEN),
            ductile?"  the joint yields and holds":"  the joint breaks");
    }
}

// 7. An unconverged solve gives no verdict: the wall's hit with a budget of
// one ADMM step per solve. What breaks is what broke in converged solves --
// a subset of the converged evaluation's breaks -- and the evaluation reports
// itself capped. (Before: the capped iterate was judged, and joints broke on it.)
void unconverged(){
    std::printf("an unconverged solve commits nothing\n");
    const Structure s=wallStructure();
    const auto rest=elastic(s,s.force,s.torque);
    auto F=s.force;F[kWallBrick]+=PxVec3(0,0,360e3f);
    impact::Settings budget;budget.iterations=1;
    const auto full=evaluate(s,F,s.torque,rest,true),r=evaluate(s,F,s.torque,rest,true,budget);
    PxU32 broken=0,extra=0;
    for(PxU32 k=0;k<s.bonds.size();++k) {
        const bool b=r.impact[k]==impact::eBROKEN || r.verdicts[k].health<=0,f=full.impact[k]==impact::eBROKEN;
        broken+=b;extra+=b && !f;
    }
    char text[200];std::snprintf(text,sizeof text,"one step per solve: %u capped; %u broken, %u of them not broken by the converged evaluation (expected capped, 0)",
        r.status.capped,broken,extra);
    expect(r.status.capped>0 && extra==0,text);
}
// 8. The evaluation split into dispatches resumes exactly: the wall with
// about one ADMM step per dispatch gives the same forces and verdicts, bit
// for bit, as in one dispatch.
void dispatches(){
    std::printf("an evaluation split into many dispatches is the same evaluation\n");
    const Structure s=wallStructure();
    const auto rest=elastic(s,s.force,s.torque);
    auto F=s.force;F[kWallBrick]+=PxVec3(0,0,360e3f);
    // A dispatch of about one ADMM step (the wall: 6 links and nodes, 5 + 3 per
    // conjugate gradient iteration); a budget for 512 steps, so the dispatch
    // count stays a few thousand.
    impact::Settings one,many;one.evaluationIterations=many.evaluationIterations=512;many.dispatchWork=60;
    const auto a=evaluate(s,F,s.torque,rest,true,one),b=evaluate(s,F,s.torque,rest,true,many);
    const bool same=!std::memcmp(a.forces.data(),b.forces.data(),sizeof(a.forces[0])*a.forces.size())
        && a.impact==b.impact && a.status.iterations==b.status.iterations;
    char text[200];std::snprintf(text,sizeof text,"wall: %u and %u iterations, forces and verdicts %s",a.status.iterations,b.status.iterations,same?"identical":"differ");
    expect(same,text);
}

// 9. A yielded joint carries its plastic state: a 100 kg chunk on two joints
// under a constant 15 kN pull, a stiff ductile one of 10 kN capacity and a
// soft strong one. The elastic solve sends most of the pull to the stiff
// joint, past its capacity, every tick: the impact solve yields it at 10 kN
// and the soft joint takes the rest. The next tick, same load: nothing new
// reaches capacity, so no island is solved, the joints keep the carried
// forces (yielded at 10 kN, 5 kN) and nothing breaks. Today (no carried
// state): solved again every tick.
void carried(){
    std::printf("a yielded joint at constant load: solved once, then carried\n");
    Structure s;const PxU32 anchor=s.chunk(PxVec3(0,0,0),0,0),top=s.chunk(PxVec3(0,1,0),100,10);
    // Tension capacities 10 kN (ductile, 15 mm) and 100 kN over 0.01 m^2.
    const PxU32 weak=s.material(1e9f,1e6f,1e9f,0.015f),strong=s.material(1e9f,10e6f,1e9f,0.0f);
    s.bond(anchor,top,PxVec3(0,0.5f,0),PxVec3(0,1,0),0.01f,weak,1.0f);
    s.bond(anchor,top,PxVec3(0,0.5f,0),PxVec3(0,1,0),0.01f,strong,0.3f);
    const auto rest=elastic(s,s.force,s.torque);
    auto F=s.force;F[top]+=PxVec3(0,15e3f,0);
    impact::Settings fs;if(const char* t=std::getenv("IMPACT_TEST_TOLERANCE"))fs.tolerance=float(std::atof(t));
    if(const char* t=std::getenv("IMPACT_TEST_RAMP"))fs.rampFactor=float(std::atof(t));
    const auto first=evaluate(s,F,s.torque,rest,true,fs);
    char text[240];
    std::snprintf(text,sizeof text,"first tick: solved (%u islands), the stiff joint yields at %.0f N (elastic %.0f), the soft one %.0f N",
        first.status.triggered,first.forces[0].linear.y,first.elastic[0].linear.y,first.forces[1].linear.y);
    // The split between the two (10 kN and 5 kN statically) is the solve's
    // elastic tie-break: at the motion tolerance (0.1 mm over the tick) it is
    // not resolved -- the joints' elastic deformations are micrometres -- and
    // lands within ~10% (1e-6 m resolves it exactly). Checked here: the
    // joints balance the pull and none breaks.
    expect(first.status.triggered==1 && std::fabs(first.forces[0].linear.y+first.forces[1].linear.y-15e3f)<0.01f*15e3f
        && first.verdicts[0].health>0 && first.verdicts[1].health>0,text);
    // The next ticks, same load, from the carried state.
    Carry carry{first.elastic,first.carried,first.slip};
    auto state=first.forces;PxU32 solved=0,broken=0;
    for(int tick=0;tick<5;++tick) {
        const auto next=evaluate(s,F,s.torque,state,true,impact::Settings{},false,std::getenv("IMPACT_TEST_NO_CARRY")?nullptr:&carry);
        solved+=next.status.solves;broken+=(next.verdicts[0].health<=0)+(next.verdicts[1].health<=0);
        if(!tick){std::snprintf(text,sizeof text,"next tick: forces %.0f and %.0f N, verdicts %u %u",next.forces[0].linear.y,next.forces[1].linear.y,next.impact[0],next.impact[1]);
            expect(std::fabs(next.forces[0].linear.y-first.forces[0].linear.y)<50.0f && std::fabs(next.forces[1].linear.y-first.forces[1].linear.y)<50.0f,text);}
        carry={next.elastic,next.carried,next.slip};state=next.forces;
    }
    std::snprintf(text,sizeof text,"five more ticks at the same load: %u solves, %u joints broken (expected 0, 0)",solved,broken);
    expect(solved==0 && broken==0,text);
}

// 10. An elastically held chunk stops the body (the infinite_wall
// `unbreakable` control): the same 1000 kg body at 10 m/s, the chunk's joint
// far beyond any load but soft (k dt^2 ~ 8 against the masses), so in the
// solve body and chunk ride its spring through most of the tick. The rigid
// simulation keeps the held chunk where it is (its cluster is kinematic):
// the solve's velocity would carry the body into it, a tick later the
// trial stops it again -- momentum from nowhere. The trial's answer stands
// (no velocity change); a yielded joint (test 6) lets it through.
void heldStops(){
    std::printf("coupled contact: a chunk held elastically stops the body\n");
    Structure s;const PxU32 anchor=s.chunk(PxVec3(0,0,0),0,0),wall=s.chunk(PxVec3(0,0.5f,0),10.0f,0.5f);
    const PxU32 mat=s.material(1e13f,1e13f,1e13f,0.0f);
    s.bond(anchor,wall,PxVec3(0,0.25f,0),PxVec3(0,1,0),0.01f,mat,1e-3f);   // k = 30 GPa w^2 = 3e4 N/m
    const float M=1000.0f,v=10.0f,dt=1.0f/60.0f;
    impact::ContactRow row{};row.chunk=wall;row.body=0;row.points=4;row.friction=0.0f;
    const float point[3]={-0.25f,0.5f,0},com[3]={-1.0f,0.5f,0};
    for(int q=0;q<3;++q){row.point[q]=point[q];row.com[q]=com[q];}
    row.normal[0]=1;row.load[0]=M*v/dt;row.velocity[0]=v;row.dv[0]=-v;row.im=1.0f/M;row.ii[0]=row.ii[1]=row.ii[2]=1.0f/400.0f;
    s.rows.push_back(row);
    // The trial's elastic forces: the stop load is far past... nothing: give
    // the trigger a reason (a weak trim on the chunk, pulled off).
    const PxU32 trim=s.chunk(PxVec3(0,0.5f,0.1f),1.0f,0.01f),glue=s.material(1e3f,1e3f,1e3f,0.0f);
    s.bond(wall,trim,PxVec3(0,0.5f,0.05f),PxVec3(0,0,1),1e-3f,glue);
    const auto rest=elastic(s,s.force,s.torque);
    auto F=s.force;F[wall]+=PxVec3(row.load[0],0,0);F[trim]+=PxVec3(0,0,100.0f);
    impact::Settings hs;hs.heldStops=!std::getenv("IMPACT_TEST_NO_HOLD");
    const auto r=evaluate(s,F,s.torque,rest,true,hs);
    char text[200];std::snprintf(text,sizeof text,"held joint: the body's velocity change %.3f m/s (expected 0: the trial's stop stands; %u islands, %u contacts)",
        r.rowDelta[0],r.status.triggered,r.status.contacts);
    expect(r.status.triggered==1 && r.status.contacts==1 && std::fabs(r.rowDelta[0])<1e-6f && r.impact[0]!=impact::eBROKEN,text);
}

// 11. The section model's projection on a thin section (a drywall screw
// joint in the house: 1 cm^2, g ~ 2.4e3 /m, capacities 600-900 N, metrics
// ~1): the projected point is feasible and no feasible point is nearer (in
// the metric). Before: the active-set enumeration lost every candidate and
// returned the point unchanged, infeasible (N = -4.4 kN against 600 N), and
// the house's solve at rest diverged (4096 steps, split 4e3 x capacity).
__global__ void projectProbe(const float* in,PxU32 count,float* out)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    const float* c=in+9*i;float p[3]={c[0],c[1],c[2]};const float sc[3]={c[3],c[4],c[5]};
    impact::polytope(p,sc,c[6],c[7],c[6],c[7],c[8],c[8]*2.0f/3.0f);
    out[3*i]=p[0];out[3*i+1]=p[1];out[3*i+2]=p[2];
}
void projection(){
    std::printf("the section projection on a thin section\n");
    std::vector<float> cases;std::srand(7);
    auto r=[](float a,float b){return a+(b-a)*float(std::rand())/float(RAND_MAX);};
    const PxU32 n=256;
    for(PxU32 i=0;i<n;++i){const float g0=r(100,2500),g1=r(50,300);
        cases.insert(cases.end(),{r(-6e3f,3e3f),r(0,600),r(0,8),r(0.2f,3),r(0.5f,40),r(0.5f,40),g0,g1,900.0f});}
    Device<float> c(cases),o(3*n);projectProbe<<<(n+63)/64,64>>>(c.p,n,o.p);check(cudaDeviceSynchronize());
    const auto q=o.get();PxU32 infeasible=0,beaten=0;
    for(PxU32 i=0;i<n;++i){
        const float* k=&cases[9*i];const float capT=k[8],capC=k[8]*2.0f/3.0f,g0=k[6],g1=k[7];
        const float w0=k[3]*k[3],w1=k[4]*k[4],w2=k[5]*k[5];
        const float N=q[3*i],m0=q[3*i+1],m1=q[3*i+2],b=g0*m0+g1*m1,tol=1e-4f*(capT+capC);
        if(m0<0 || m1<0 || b+N>capT+tol || b-N>capC+tol){++infeasible;continue;}
        const double d=w0*double(N-k[0])*(N-k[0])+w1*double(m0-k[1])*(m0-k[1])+w2*double(m1-k[2])*(m1-k[2]);
        for(int t=0;t<20000;++t){
            const float n2=r(-capC,capT),a=r(0,1);const float budget=std::min(capT-n2,capC+n2);if(budget<0)continue;
            const float x0=a*budget/g0,x1=r(0,1)*(1-a)*budget/g1;
            const double e=w0*double(n2-k[0])*(n2-k[0])+w1*double(x0-k[1])*(x0-k[1])+w2*double(x1-k[2])*(x1-k[2]);
            if(e<d*(1.0-1e-3)-1e-6){++beaten;break;}
        }
    }
    char text[200];std::snprintf(text,sizeof text,"%u thin-section points: %u projected infeasible, %u with a nearer feasible point (expected 0, 0)",n,infeasible,beaten);
    expect(infeasible==0 && beaten==0,text);
}

// 12. The detectors. A projection corrupted on purpose (faultInjection: the
// first link's point scaled 10x out of its set) is counted infeasible and
// its solve stops as diverged, with no verdict from it; the healthy wall
// reports neither.
void detectors(){
    std::printf("the impact solve's bug detectors\n");
    const Structure s=wallStructure();
    const auto rest=elastic(s,s.force,s.torque);
    auto F=s.force;F[kWallBrick]+=PxVec3(0,0,360e3f);
    impact::Settings healthy,broken;broken.faultInjection=1;
    const auto a=evaluate(s,F,s.torque,rest,true,healthy),b=evaluate(s,F,s.torque,rest,true,broken);
    char text[240];
    std::snprintf(text,sizeof text,"healthy: %u diverged, %u infeasible projections (expected 0, 0)",a.status.diverged,a.status.infeasible);
    expect(a.status.diverged==0 && a.status.infeasible==0,text);
    PxU32 extra=0;for(PxU32 k=0;k<s.bonds.size();++k)extra+=(b.impact[k]==impact::eBROKEN) && a.impact[k]!=impact::eBROKEN;
    std::snprintf(text,sizeof text,"corrupted projection: %u diverged (worst bond %d), %u infeasible, %u breaks beyond the healthy solve's (expected >0, >0, 0)",
        b.status.diverged,int(b.status.worstBond)-1,b.status.infeasible,extra);
    expect(b.status.diverged>0 && b.status.infeasible>0 && extra==0,text);
}
// 13. Every projection lands in its set: thin, thick and odd sections (L1
// sets with gains 1-3e3 /m and either axis dominant, capacities from equal to
// 100:1 either way), round cones and the shear triangle, metrics 1e-6-1e6.
__global__ void fuzzProbe(const impact::Bond* bonds,const float* points,PxU32 count,PxU32* infeasible)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    impact::Bond b=bonds[i];float x[6];for(int q=0;q<6;++q)x[q]=points[6*i+q];
    const float* m=points+6*count+4*i;
    impact::project(b,x,m[0],m[1],m[2],m[3]);
    if(!impact::feasible(b,x,1e-4f))atomicAdd(infeasible,1u);
}
void fuzz(){
    std::printf("projections land in their sets (fuzz)\n");
    std::srand(11);auto r=[](float a,float b){return a+(b-a)*float(std::rand())/float(RAND_MAX);};
    auto lg=[&](float a,float b){return std::exp(r(std::log(a),std::log(b)));};
    const PxU32 n=4096;std::vector<impact::Bond> bonds(n);std::vector<float> pts(6*n),metric(4*n);
    for(PxU32 i=0;i<n;++i){
        impact::Bond b{};b.flags=impact::eALIVE;const float a=lg(1e-5f,1.0f);b.area=a;
        b.capT=lg(1e2f,1e7f);b.capC=b.capT*lg(0.01f,100.0f);b.capS=b.capT*lg(0.1f,10.0f);
        const int kind=i%3;
        if(kind==0){b.g0=lg(1.0f,3e3f);b.g1=lg(1.0f,3e3f);b.gb=b.g0;b.gt=lg(1.0f,3e3f);   // L1 section, half of them bearing joints
            if(i%2){b.h0=lg(5.0f,200.0f);b.h1=lg(5.0f,200.0f);}else{b.h0=b.g0;b.h1=b.g1;}}
        else {b.gb=lg(0.3f,3e3f);b.gt=lg(0.3f,3e3f);}                                    // round cones
        bonds[i]=b;
        const float F=b.capT+b.capC,M=F/std::min(b.gb,b.g0>0?std::min(b.g0,b.g1):b.gb);
        for(int q=0;q<3;++q)pts[6*i+q]=r(-10*F,10*F);for(int q=3;q<6;++q)pts[6*i+q]=r(-10*M,10*M);
        const float ml=lg(1e-6f,1e6f),ma=lg(1e-6f,1e6f);
        metric[4*i]=ml;metric[4*i+1]=lg(1e-6f,1e6f);metric[4*i+2]=kind==0?lg(1e-6f,1e6f):ma;metric[4*i+3]=kind==0?lg(1e-6f,1e6f):ma;
    }
    pts.insert(pts.end(),metric.begin(),metric.end());
    Device<impact::Bond> db(bonds);Device<float> dp(pts);Device<PxU32> bad(1);
    fuzzProbe<<<(n+127)/128,128>>>(db.p,dp.p,n,bad.p);check(cudaDeviceSynchronize());
    char text[160];std::snprintf(text,sizeof text,"%u projections (L1, round, shear; metrics 1e-6-1e6): %u infeasible (expected 0)",n,bad.get()[0]);
    expect(bad.get()[0]==0,text);
}

// 14. A bearing joint (PX_DESTRUCTION_BEARING_JOINTS; vibe-land
// physx-bridge/tests/bearing_joint.rs): a 45 x 90 mm stud end-nailed to its
// plate, 285 N down on it and a moment about the plate's long axis. Its
// fasteners carry T = M/(d/2) - C. At 11.7 N m (e 41 mm < 45 mm) the contact
// bears and the nails carry nothing: the joint holds though the glued
// patch's fibre stress is past the nails' capacity. At 20 N m the nails
// carry 159 N, past a 0.9 x 159 N capacity: it breaks. The impact solve
// (its island taken by a trim pulled off the stud) agrees with the verdict.
void bearing(){
    std::printf("bearing joint: a stud on its plate, graded by its nails\n");
    for(int heavy=0;heavy<2;++heavy) {
        Structure s;
        const PxU32 plate=s.chunk(PxVec3(0,-0.025f,0),0,0),stud=s.chunk(PxVec3(0,0.25f,0),0.85f,0.02f),trim=s.chunk(PxVec3(0,0.25f,0.06f),0.1f,0.001f);
        const float b=0.045f,h=0.09f,A=b*h,M=heavy?20.0f:11.7f,C=285.0f;
        const float nails=std::max(M/(h/2)-C,0.0f),fibre=std::max(M/(b*h*h/6)-C/A,0.0f);
        // Tension capacity: the nails' (0.9 of their load when they carry one),
        // below the glued fibre stress either way.
        const float tF=heavy?0.9f*nails/A:0.5f*fibre;
        const PxU32 nailed=s.material(10e6f,tF,1e6f,0.0f),glue=s.material(1e3f,1e3f,1e3f,0.0f);
        PxDestructionBondSection sec;sec.axis=PxVec3(1,0,0);sec.bendModulus0=b*h*h/6;sec.bendModulus1=h*b*b/6;
        sec.twistModulus=b*h*(b*b+h*h)/(6*std::sqrt(b*b+h*h));sec.gyration0=h/std::sqrt(12.0f);sec.gyration1=b/std::sqrt(12.0f);
        sec.polarGyration=std::sqrt((b*b+h*h)/12);sec.bearingDepth0=h/2;sec.bearingDepth1=b/2;
        s.bond(plate,stud,PxVec3(0,0,0),PxVec3(0,1,0),A,nailed);s.sections.push_back(sec);
        s.bond(stud,trim,PxVec3(0,0.25f,0.0225f),PxVec3(0,0,1),1e-4f,glue);s.sections.push_back(PxDestructionBondSection{});
        auto F=s.force,T=s.torque;F[stud]+=PxVec3(0,-C,0);T[stud]+=PxVec3(M,0,0);
        const auto rest=elastic(s,s.force,s.torque);
        F[trim]+=PxVec3(0,0,10.0f);
        // The stud is light (0.85 kg): at the default motion tolerance (0.1 mm
        // over the tick) the solve may leave ~0.9 N m of its moment unbalanced,
        // 14% of the nails' capacity through d/2, and stop at 0.996 of it
        // (recorded in the design doc). 1e-6 m resolves it.
        impact::Settings on;on.sectionBending=true;on.tolerance=1e-6f;
        if(const char* t=std::getenv("IMPACT_TEST_TOLERANCE"))on.tolerance=float(std::atof(t));
        const auto today=evaluate(s,F,T,rest,false,on),r=evaluate(s,F,T,rest,true,on);
        char text[260];
        std::snprintf(text,sizeof text,"%.1f N m: nails carry %.0f N (fibre %.0f kPa, capacity %.0f kPa): the verdict %s it, the impact solve %s it (%u islands)",
            M,nails,fibre/1e3f,tF/1e3f,today.verdicts[0].health<=0?"breaks":"holds",r.verdicts[0].health<=0?"breaks":"holds",r.status.triggered);
        std::printf("    E verdict %u; forces lin %.1f %.1f %.1f ang %.2f %.2f %.2f; elastic lin %.1f %.1f %.1f ang %.2f %.2f %.2f; %u solves %u steps %u capped %u diverged\n",r.impact[0],
            r.forces[0].linear.x,r.forces[0].linear.y,r.forces[0].linear.z,r.forces[0].angular.x,r.forces[0].angular.y,r.forces[0].angular.z,
            r.elastic[0].linear.x,r.elastic[0].linear.y,r.elastic[0].linear.z,r.elastic[0].angular.x,r.elastic[0].angular.y,r.elastic[0].angular.z,
            r.status.solves,r.status.iterations,r.status.capped,r.status.diverged);
        expect(r.status.triggered==1 && (today.verdicts[0].health<=0)==bool(heavy) && (r.verdicts[0].health<=0)==bool(heavy),text);
    }
}

}} // physx

int main(int argc,char** argv){
    (void)argc;(void)argv;
    try{if(const char* only=std::getenv("IMPACT_TEST_ONLY")){if(!std::strcmp(only,"unconverged"))physx::unconverged();if(!std::strcmp(only,"dispatches"))physx::dispatches();if(!std::strcmp(only,"carried"))physx::carried();if(!std::strcmp(only,"held"))physx::heldStops();if(!std::strcmp(only,"projection"))physx::projection();if(!std::strcmp(only,"detectors"))physx::detectors();if(!std::strcmp(only,"fuzz"))physx::fuzz();if(!std::strcmp(only,"bearing"))physx::bearing();if(!std::strcmp(only,"coupled"))physx::coupled();}else{physx::column();physx::wall();physx::rest();physx::centroidConvention();physx::impactCrush();physx::section();physx::coupled();physx::unconverged();physx::dispatches();physx::carried();physx::heldStops();physx::projection();physx::detectors();physx::fuzz();physx::bearing();}}
    catch(const std::exception& e){std::printf("error: %s\n",e.what());return 2;}
    std::printf("%s (%d failed)\n",physx::failures?"FAILED":"passed",physx::failures);
    return physx::failures?1:0;
}
