// Kernel-level timing of mass-property variants on city-like clusters (contiguous members).
#include "PxgDestructionTopology.cu"
#include <cstdio>
#include <random>
#include <vector>
#include <chrono>
using namespace physx;
namespace physx { namespace {
using namespace destructionPair;
// V1: as shipped but final outputs stored without double rounding (hi only) -> isolates value() cost
template<int V> __global__ void massVariant(const PxgDestructionChunk* chunks, const ChunkPairs* pairs,
    const unsigned* order, const unsigned* begins, const unsigned* ends, PxgDestructionCluster* clusters,
    const unsigned* roots, const PxgDestructionTopologyStatus* status) {
    const unsigned lane=threadIdx.x&31u,warp=(blockIdx.x*blockDim.x+threadIdx.x)>>5,warps=(gridDim.x*blockDim.x)>>5;
    for (unsigned cidx=warp; cidx<status->clusterCount; cidx+=warps) {
        const unsigned r=roots[cidx];
        const ChunkPairs reference=pairs[r];
        Pair v[10];for(unsigned k=0;k<10;++k)v[k]=pair(0.0f);
        unsigned support=0;
        for (unsigned j=begins[r]+lane; j<ends[r]; j+=32) {
            const unsigned id=order[j];const ChunkPairs c=pairs[id];
            const Pair x=sub(c.center[0],reference.center[0]),y=sub(c.center[1],reference.center[1]),
                z=sub(c.center[2],reference.center[2]),m=c.mass;
            v[0]=add(v[0],m);v[1]=add(v[1],mul(m,x));v[2]=add(v[2],mul(m,y));v[3]=add(v[3],mul(m,z));
            v[4]=add(v[4],add(c.inertia[0],mul(m,add(mul(y,y),mul(z,z)))));
            v[5]=add(v[5],add(c.inertia[1],mul(m,add(mul(x,x),mul(z,z)))));
            v[6]=add(v[6],add(c.inertia[2],mul(m,add(mul(x,x),mul(y,y)))));
            v[7]=add(v[7],sub(c.inertia[3],mul(mul(m,x),y)));
            v[8]=add(v[8],sub(c.inertia[4],mul(mul(m,x),z)));
            v[9]=add(v[9],sub(c.inertia[5],mul(mul(m,y),z)));
            if(V!=3)support|=chunks[id].supported;
        }
        for (unsigned offset=16; offset; offset>>=1) {
            for (unsigned k=0;k<10;++k) v[k]=add(v[k],shuffleDown(v[k],offset));
            support|=__shfl_down_sync(0xffffffffu,support,offset);
        }
        if (!lane) {
            if(V==2){float* o=reinterpret_cast<float*>(clusters+r);for(int k=0;k<10;++k)o[k]=v[k].hi;continue;}
            PxgDestructionCluster out{};
            const Pair m=v[0];
            out.mass=V==1?double(m.hi):value(m);
            Pair offset[3];
            for (unsigned k=0;k<3;++k) {
                offset[k]=m.hi>0?div(v[k+1],m):pair(0.0f);
                const Pair c=add(reference.center[k],offset[k]);out.center[k]=V==1?double(c.hi):value(c);
            }
            const Pair x=offset[0],y=offset[1],z=offset[2];
            const Pair I[6]={sub(v[4],mul(m,add(mul(y,y),mul(z,z)))),sub(v[5],mul(m,add(mul(x,x),mul(z,z)))),sub(v[6],mul(m,add(mul(x,x),mul(y,y)))),
              add(v[7],mul(mul(m,x),y)),add(v[8],mul(mul(m,x),z)),add(v[9],mul(mul(m,y),z))};
            for(int k=0;k<6;++k)out.inertia[k]=V==1?double(I[k].hi):value(I[k]);
            out.chunkCount=ends[r]-begins[r];
            out.supported=support;
            clusters[r]=out;
        }
    }
}
__global__ void emptyKernel(const PxgDestructionTopologyStatus* s){}
}}
int main(int argc,char**argv){
  const unsigned n=3258;std::mt19937 rng(5);std::uniform_real_distribution<double> u(-1,1);
  std::vector<PxgDestructionChunk> chunks(n);std::vector<unsigned> order(n),begins(n),ends(n),roots;
  unsigned start=0;
  while(start<n){unsigned size=std::min<unsigned>(n-start,1+unsigned(std::abs(u(rng))*(std::abs(u(rng))<0.05?800:8)));
    const double cx=500*u(rng),cy=30+30*u(rng),cz=500*u(rng);roots.push_back(start);
    for(unsigned i=start;i<start+size;++i){auto& c=chunks[i];c.center[0]=cx+10*u(rng);c.center[1]=cy+10*u(rng);c.center[2]=cz+10*u(rng);
      c.mass=std::pow(10.0,2+2*u(rng));for(int k=0;k<3;++k)c.inertia[k]=c.mass*(0.1+std::abs(u(rng)));for(int k=3;k<6;++k)c.inertia[k]=0.05*c.mass*u(rng);
      c.supported=(i%97)==0;order[i]=i;begins[i]=start;ends[i]=start+size;}
    start+=size;}
  std::vector<ChunkPairs> pairs(n);auto split=[](double d){const float hi=float(d);return Pair{hi,float(d-double(hi))};};
  for(unsigned i=0;i<n;++i){for(int k=0;k<3;++k)pairs[i].center[k]=split(chunks[i].center[k]);pairs[i].mass=split(chunks[i].mass);for(int k=0;k<6;++k)pairs[i].inertia[k]=split(chunks[i].inertia[k]);}
  PxgDestructionTopologyStatus st{};st.clusterCount=unsigned(roots.size());
  auto up=[](const auto& v){using T=typename std::decay_t<decltype(v)>::value_type;T* d;cudaMalloc(&d,v.size()*sizeof(T));cudaMemcpy(d,v.data(),v.size()*sizeof(T),cudaMemcpyHostToDevice);return d;};
  auto* dch=up(chunks);auto* dp=up(pairs);auto* dord=up(order);auto* db=up(begins);auto* de=up(ends);auto* dr=up(roots);
  auto* dst=up(std::vector<PxgDestructionTopologyStatus>{st});PxgDestructionCluster* dcl;cudaMalloc(&dcl,n*sizeof(PxgDestructionCluster));
  unsigned* labels;cudaMalloc(&labels,n*4);unsigned* alive;cudaMalloc(&alive,n*4);
  auto time=[&](auto f){double best=1e9;for(int r=0;r<5;++r){cudaDeviceSynchronize();auto t0=std::chrono::steady_clock::now();for(int k=0;k<30;++k)f();
    auto e=cudaDeviceSynchronize();if(e)printf("err %s\n",cudaGetErrorString(e));best=std::min(best,std::chrono::duration<double,std::micro>(std::chrono::steady_clock::now()-t0).count()/30);}return best;};
  const unsigned g8=std::min((n+7)/8,2560u);
  printf("clusters %zu\n",roots.size());
  printf("empty          %.1f us\n",time([&]{emptyKernel<<<1,32>>>(dst);}));
  printf("double (block) %.1f us\n",time([&]{massProperties<<<std::min(n,2560u),256>>>(dch,labels,alive,dord,db,de,dcl,dr,dst);}));
  printf("pairs shipped  %.1f us\n",time([&]{massPropertiesPairs<<<g8,256>>>(dch,dp,dord,db,de,dcl,dr,dst);}));
  printf("pairs V1 hi    %.1f us\n",time([&]{massVariant<1><<<g8,256>>>(dch,dp,dord,db,de,dcl,dr,dst);}));
  printf("pairs V2 raw   %.1f us\n",time([&]{massVariant<2><<<g8,256>>>(dch,dp,dord,db,de,dcl,dr,dst);}));
  printf("pairs V3 nosup %.1f us\n",time([&]{massVariant<3><<<g8,256>>>(dch,dp,dord,db,de,dcl,dr,dst);}));
  printf("pairs V0 g=64  %.1f us\n",time([&]{massVariant<0><<<64,256>>>(dch,dp,dord,db,de,dcl,dr,dst);}));
}
