#include <cmath>
#include <cstring>
#include <cstdio>
#include <cfloat>
#include <random>
#include <array>
#include <algorithm>
#include <vector>
#include <cstdio>
#define __device__
#define __forceinline__ inline
static inline unsigned __float_as_uint(float f){unsigned u;std::memcpy(&u,&f,4);return u;}
using std::isfinite;
namespace physx{typedef unsigned PxU32;}
#include "PxDestructionTopologyTypes.h"
#define PX_CUMETAL 1
#include "PxgDestructionBody.cuh"
using namespace physx;
using V=std::array<double,3>;using Q=std::array<double,4>;using M=std::array<V,3>;
M matrix(Q q){const auto [x,y,z,w]=q;return {{{1-2*(y*y+z*z),2*(x*y-z*w),2*(x*z+y*w)},{2*(x*y+z*w),1-2*(x*x+z*z),2*(y*z-x*w)},{2*(x*z-y*w),2*(y*z+x*w),1-2*(x*x+y*y)}}};}
struct R {double m[3],q[4];unsigned ok;};
int main(int argc,char**argv){if(argc>1){FILE* f=fopen(argv[1],"rb");unsigned n;fread(&n,4,1,f);std::vector<double> in(6*n);fread(in.data(),8,6*n,f);std::vector<R> g(n),p(n);fread(g.data(),sizeof(R),n,f);fread(p.data(),sizeof(R),n,f);
 double wg=0,wp=0,wh=0;for(unsigned i=0;i<n;++i){double m[3],q[4],m2[3],q2[4];bool ok=destructionBody::principalFrame(&in[6*i],m,q);destructionBody::principalFramePair(&in[6*i],m2,q2);if(!ok)continue;for(int k=0;k<3;++k){wg=std::max(wg,fabs(g[i].m[k]-m[k])/fabs(m[k]));wp=std::max(wp,fabs(p[i].m[k]-m[k])/fabs(m[k]));wh=std::max(wh,fabs(p[i].m[k]-m2[k])/fabs(m[k]));}}
 std::printf("vs host double: gpu double %.3g gpu pair %.3g; gpu pair vs host pair %.3g\n",wg,wp,wh);return 0;}
std::mt19937 rng(587);std::uniform_real_distribution<double> positive(.1,3);std::normal_distribution<double> nd(0,1);
 double wm=0;unsigned worst=0;
 for(unsigned i=0;i<4096;++i){Q q;double len=0;for(double&x:q){x=nd(rng);len+=x*x;}for(double&x:q)x/=sqrt(len);const M a=matrix(q);
  const V size={positive(rng),positive(rng),positive(rng)};const double scale=pow(10.0,int(i%51)-25);
  V diag={scale*(size[1]*size[1]+size[2]*size[2]),scale*(size[0]*size[0]+size[2]*size[2]),scale*(size[0]*size[0]+size[1]*size[1])};
  M t{};for(unsigned j=0;j<3;++j)for(unsigned k=0;k<3;++k)for(unsigned p=0;p<3;++p)t[j][k]+=a[j][p]*diag[p]*a[k][p];
  const double in[]={t[0][0],t[1][1],t[2][2],t[0][1],t[0][2],t[1][2]};
  double m1[3],q1[4],m2[3],q2[4];bool o1=destructionBody::principalFrame(in,m1,q1),o2=destructionBody::principalFramePair(in,m2,q2);
  if(o1!=o2){std::printf("ok differs %u\n",i);continue;}
  for(int k=0;k<3;++k){double r=fabs(m1[k]-m2[k])/fabs(m1[k]);if(r>wm){wm=r;worst=i;}}}
 std::printf("host: moments worst rel %.3g at %u\n",wm,worst);}
