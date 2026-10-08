// Topology rebuild mass properties (pairs under PX_CUMETAL) vs a long-double host reference.
#include "PxgDestructionTopology.cu"
#include <cstdio>
#include <random>
#include <vector>
#include <map>
#include <chrono>
using namespace physx;
int main(int argc,char**argv){
  const unsigned n=argc>1?atoi(argv[1]):3258;std::mt19937 rng(5);std::uniform_real_distribution<double> u(-1,1);
  std::vector<PxgDestructionChunk> chunks(n);std::vector<PxgDestructionBond> bonds;
  unsigned start=0;
  while(start<n){unsigned size=std::min<unsigned>(n-start,1+unsigned(std::abs(u(rng))*(std::abs(u(rng))<0.1?600:12)));
    const double cx=500*u(rng),cy=30+30*u(rng),cz=500*u(rng);
    for(unsigned i=start;i<start+size;++i){auto& c=chunks[i];c.center[0]=cx+10*u(rng);c.center[1]=cy+10*u(rng);c.center[2]=cz+10*u(rng);
      c.mass=std::pow(10.0,2+2*u(rng));for(int k=0;k<3;++k)c.inertia[k]=c.mass*(0.1+std::abs(u(rng)));for(int k=3;k<6;++k)c.inertia[k]=0.05*c.mass*u(rng);
      c.supported=(i%97)==0;if(i>start)bonds.push_back({i-1,i});}
    start+=size;}
  auto* topo=PxgDestructionTopology::create(chunks.data(),n,bonds.data(),unsigned(bonds.size()));
  if(!topo){printf("create failed\n");return 1;}
  auto v=topo->view();
  std::vector<PxgDestructionCluster> clusters(n);cudaMemcpy(clusters.data(),v.clusters,n*sizeof(clusters[0]),cudaMemcpyDeviceToHost);
  std::vector<unsigned> labels(n),roots(n);PxgDestructionTopologyStatus st;cudaMemcpy(&st,v.status,sizeof(st),cudaMemcpyDeviceToHost);
  cudaMemcpy(labels.data(),v.chunkCluster,n*4,cudaMemcpyDeviceToHost);cudaMemcpy(roots.data(),v.activeClusters,n*4,cudaMemcpyDeviceToHost);
  std::map<unsigned,std::vector<unsigned>> members;for(unsigned i=0;i<n;++i)members[labels[i]].push_back(i);
  double worstMass=0,worstCenter=0,worstInertia=0;
  for(unsigned c=0;c<st.clusterCount;++c){const unsigned r=roots[c];auto& ms=members[r];
    long double s[10]={};const auto& ref=chunks[r];
    for(unsigned i:ms){const auto& ch=chunks[i];long double x=(long double)ch.center[0]-ref.center[0],y=(long double)ch.center[1]-ref.center[1],z=(long double)ch.center[2]-ref.center[2],m=ch.mass;
      s[0]+=m;s[1]+=m*x;s[2]+=m*y;s[3]+=m*z;s[4]+=ch.inertia[0]+m*(y*y+z*z);s[5]+=ch.inertia[1]+m*(x*x+z*z);s[6]+=ch.inertia[2]+m*(x*x+y*y);
      s[7]+=ch.inertia[3]-m*x*y;s[8]+=ch.inertia[4]-m*x*z;s[9]+=ch.inertia[5]-m*y*z;}
    const long double m=s[0],ox=s[1]/m,oy=s[2]/m,oz=s[3]/m;
    const long double I[6]={s[4]-m*(oy*oy+oz*oz),s[5]-m*(ox*ox+oz*oz),s[6]-m*(ox*ox+oy*oy),s[7]+m*ox*oy,s[8]+m*ox*oz,s[9]+m*oy*oz};
    const long double C[3]={ref.center[0]+ox,ref.center[1]+oy,ref.center[2]+oz};
    const auto& g=clusters[r];
    worstMass=std::max(worstMass,double(std::fabs((long double)g.mass-m)/m));
    long double scale=0;for(int k=0;k<6;++k)scale=std::max(scale,std::fabs(I[k]));
    for(int k=0;k<6;++k)worstInertia=std::max(worstInertia,double(std::fabs((long double)g.inertia[k]-I[k])/scale));
    for(int k=0;k<3;++k)worstCenter=std::max(worstCenter,double(std::fabs((long double)g.center[k]-C[k])));
    if(g.chunkCount!=ms.size()){printf("chunkCount mismatch\n");return 1;}}
  // Time full rebuilds (one bond break each).
  PxgDestructionEdit* dedit;cudaMalloc(&dedit,sizeof(PxgDestructionEdit));
  double best=1e9;for(int r=0;r<5;++r){cudaDeviceSynchronize();auto t0=std::chrono::steady_clock::now();
    for(int k=0;k<20;++k){PxgDestructionEdit e{PxgDestructionEditKind::BreakBond,unsigned((r*20+k)*7%bonds.size())};cudaMemcpy(dedit,&e,sizeof(e),cudaMemcpyHostToDevice);topo->apply(dedit,1,nullptr,nullptr);}
    cudaDeviceSynchronize();best=std::min(best,std::chrono::duration<double,std::micro>(std::chrono::steady_clock::now()-t0).count()/20);}
  // Random motions in every slot, then break bonds (splits transfer motion); dump for cross-build comparison.
  {std::vector<PxgDestructionClusterMotion> mo(n);for(auto& m:mo){double q[4],l=0;for(int k=0;k<4;++k){q[k]=u(rng);l+=q[k]*q[k];}for(int k=0;k<4;++k)m.orientation[k]=q[k]/std::sqrt(l);
     for(int k=0;k<3;++k){m.origin[k]=500*u(rng);m.linearVelocity[k]=10*u(rng);m.angularVelocity[k]=3*u(rng);}}
   cudaMemcpy(v.motions,mo.data(),n*sizeof(mo[0]),cudaMemcpyHostToDevice);
   PxgDestructionEdit* de;cudaMalloc(&de,64*sizeof(PxgDestructionEdit));std::vector<PxgDestructionEdit> es;
   for(unsigned k=0;k<64;++k)es.push_back({PxgDestructionEditKind::BreakBond,unsigned((k*131+17)%bonds.size())});
   cudaMemcpy(de,es.data(),es.size()*sizeof(es[0]),cudaMemcpyHostToDevice);topo->apply(de,64,nullptr,nullptr);cudaDeviceSynchronize();
   auto w=topo->view();PxgDestructionTopologyStatus s2;cudaMemcpy(&s2,w.status,sizeof(s2),cudaMemcpyDeviceToHost);
   std::vector<unsigned> r2(n),slots(n),ord(n),lab(n);cudaMemcpy(r2.data(),w.activeClusters,n*4,cudaMemcpyDeviceToHost);cudaMemcpy(slots.data(),w.clusterSlots,n*4,cudaMemcpyDeviceToHost);
   cudaMemcpy(ord.data(),w.orderedChunks,n*4,cudaMemcpyDeviceToHost);cudaMemcpy(lab.data(),w.chunkCluster,n*4,cudaMemcpyDeviceToHost);
   cudaMemcpy(mo.data(),w.motions,n*sizeof(mo[0]),cudaMemcpyDeviceToHost);std::vector<PxgDestructionCluster> cl(n);cudaMemcpy(cl.data(),w.clusters,n*sizeof(cl[0]),cudaMemcpyDeviceToHost);
   FILE* f=fopen(argc>2?argv[2]:"topo.txt","w");fprintf(f,"clusters %u\n",s2.clusterCount);
   for(unsigned i=0;i<n;++i)fprintf(f,"o %u %u\n",ord[i],lab[i]);
   for(unsigned c=0;c<s2.clusterCount;++c){unsigned r=r2[c];const auto& m=mo[slots[r]];const auto& g=cl[r];
     fprintf(f,"c %u %.17g %.17g %.17g %.17g %.17g %.17g %.17g %.17g %.17g %.17g %u %u",r,g.mass,g.center[0],g.center[1],g.center[2],g.inertia[0],g.inertia[1],g.inertia[2],g.inertia[3],g.inertia[4],g.inertia[5],g.chunkCount,g.supported);
     fprintf(f," m %.17g %.17g %.17g %.17g %.17g %.17g %.17g %.17g %.17g %.17g %.17g %.17g %.17g\n",m.origin[0],m.origin[1],m.origin[2],m.orientation[0],m.orientation[1],m.orientation[2],m.orientation[3],m.linearVelocity[0],m.linearVelocity[1],m.linearVelocity[2],m.angularVelocity[0],m.angularVelocity[1],m.angularVelocity[2]);}
   fclose(f);}
  printf("n=%u clusters=%u | max rel err mass %.3g inertia(rel to cluster max) %.3g | max abs center err %.3g m | rebuild incl. H2D copy %.1f us\n",n,st.clusterCount,worstMass,worstInertia,worstCenter,best);
  topo->release();
}
