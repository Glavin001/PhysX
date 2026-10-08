// The FP64 reference projections of impact_projection_fuzz.cu (plain host C++).
#include "impact_projection_reference.h"
#include <algorithm>
#include <cmath>
#include <utility>
namespace {
// Projection of x (dim <= 3) onto {p : A p <= b} in the metric diag(w), by
// active sets: each subset S (|S| <= dim) gives p = x - W^-1 A_S^T l with
// A_S p = b_S; the KKT point is feasible with l >= 0. The nearest feasible
// candidate is kept (the KKT point is the unique projection).
// A finite sentinel.
constexpr double kNone=1e300;
struct Poly { int dim,rows;double A[6][3],b[6]; };
// Projection of x (dim <= 3) onto {p : A p <= b} in the metric diag(w), by
// active sets. A row with a single coefficient and b = 0 (a sign bound,
// a v <= 0) fixes its coordinate at 0 when active: it is eliminated, not
// carried as a multiplier (an edge of the L1 set where M = 0 otherwise needs
// multipliers 1e9 and loses p to cancellation). For each set Z of active
// bounds and S of other active rows: p_Z = 0, the free coordinates from the
// KKT system, the multipliers of S and Z >= 0, p feasible. The nearest such
// candidate is the projection.
double projectPoly(const Poly& P,const double* w,const double* x,double* out)
{
    int bound[6];
    for(int r=0;r<P.rows;++r){int nz=0,at=-1;for(int d=0;d<P.dim;++d)if(P.A[r][d]!=0.0){++nz;at=d;}bound[r]=(nz==1 && P.b[r]==0.0)?at:-1;}
    double best=kNone;
    for(int mask=0;mask<(1<<P.rows);++mask) {
        bool fixed[3]={false,false,false};int S[6],k=0;bool ok=true;
        for(int r=0;r<P.rows && ok;++r)if(mask&(1<<r)){if(bound[r]>=0){if(fixed[bound[r]])ok=false;fixed[bound[r]]=true;}else S[k++]=r;}
        int nfree=0;for(int d=0;d<P.dim;++d)nfree+=!fixed[d];
        if(!ok || k>nfree)continue;
        // Free coordinates: p = x - W^-1 A_S^T l (restricted), A_S p = b_S.
        double G[6][7];
        for(int i=0;i<k;++i){for(int j=0;j<k;++j){double v=0;for(int d=0;d<P.dim;++d)if(!fixed[d])v+=P.A[S[i]][d]*P.A[S[j]][d]/w[d];G[i][j]=v;}
            double v=0;for(int d=0;d<P.dim;++d)if(!fixed[d])v+=P.A[S[i]][d]*x[d];G[i][k]=v-P.b[S[i]];}
        bool singular=false;
        for(int c=0;c<k && !singular;++c){int piv=c;for(int r=c+1;r<k;++r)if(std::fabs(G[r][c])>std::fabs(G[piv][c]))piv=r;
            if(!(std::fabs(G[piv][c])>1e-300)){singular=true;break;}
            if(piv!=c)for(int j=0;j<=k;++j)std::swap(G[c][j],G[piv][j]);
            for(int r=0;r<k;++r)if(r!=c){const double f=G[r][c]/G[c][c];for(int j=c;j<=k;++j)G[r][j]-=f*G[c][j];}}
        if(singular)continue;
        double l[6],lmax=0.0;for(int i=0;i<k;++i){l[i]=G[i][k]/G[i][i];lmax=std::max(lmax,std::fabs(l[i]));}
        double p[3]={0,0,0};
        for(int d=0;d<P.dim;++d){if(fixed[d])continue;double v=0;for(int i=0;i<k;++i)v+=P.A[S[i]][d]*l[i];p[d]=x[d]-v/w[d];}
        // A fixed coordinate's bound multiplier, from stationarity there:
        // w (0 - x) + sum_S A l + a mu = 0.
        bool neg=false;double mus[3]={0,0,0};
        for(int r=0;r<P.rows;++r)if((mask&(1<<r)) && bound[r]>=0){const int d=bound[r];double v=w[d]*(0.0-x[d]);for(int i=0;i<k;++i)v+=P.A[S[i]][d]*l[i];
            mus[d]=-v/P.A[r][d];lmax=std::max(lmax,std::fabs(mus[d]));}
        for(int i=0;i<k;++i)if(l[i]<-1e-12*lmax)neg=true;
        for(int d=0;d<P.dim;++d)if(fixed[d] && mus[d]<-1e-12*lmax)neg=true;
        if(neg)continue;
        bool feas=true;
        for(int r=0;r<P.rows && feas;++r){double v=0,sc=std::fabs(P.b[r]);for(int d=0;d<P.dim;++d){v+=P.A[r][d]*p[d];sc+=std::fabs(P.A[r][d])*(std::fabs(p[d])+std::fabs(x[d]));}
            if(v>P.b[r]+1e-9*sc)feas=false;}
        if(!feas)continue;
        double dist=0;for(int d=0;d<P.dim;++d)dist+=w[d]*(p[d]-x[d])*(p[d]-x[d]);
        if(dist<best){best=dist;for(int d=0;d<P.dim;++d)out[d]=p[d];}
    }
    return best;
}
// The reference projection of one case (FP64), into ref[6].
}
void projectionReference(const ProjectionCase& c,double* ref)
{
    const ProjectionCase& b=c;const double ml=c.m[0],mt=c.m[1],m0=c.m[2],m1=c.m[3];
    double x[6];for(int q=0;q<6;++q)x[q]=c.x[q];
    if(b.contact) {
        // (N, r = |V|): N <= 0, r + mu N <= 0, r >= 0; weights (ml, ml); no couple.
        const double r=std::hypot(x[1],x[2]);Poly P{2,3,{{1,0,0},{b.mu,1,0},{0,-1,0}},{0,0,0}};
        const double w[2]={ml,ml},xx[2]={x[0],r};double o[2];projectPoly(P,w,xx,o);
        ref[0]=o[0];ref[1]=r>0?x[1]*o[1]/r:0;ref[2]=r>0?x[2]*o[1]/r:0;ref[3]=ref[4]=ref[5]=0;return;
    }
    const double capC=std::min(b.capC,1e3*std::max(b.capT,b.capS));   // the set's defined reach (project)
    if(b.g0>0.0) {
        double best=kNone;
        for(int s0=-1;s0<=1;s0+=2)for(int s1=-1;s1<=1;s1+=2) {
            Poly P{3,4,{{1,b.h0*double(s0),b.h1*double(s1)},{-1,b.g0*double(s0),b.g1*double(s1)},{0,-double(s0),0},{0,0,-double(s1)}},{b.capT,capC,0,0}};
            const double w[3]={ml,m0,m1},xx[3]={x[0],x[4],x[5]};double o[3];
            const double d=projectPoly(P,w,xx,o);if(d<best){best=d;ref[0]=o[0];ref[4]=o[1];ref[5]=o[2];}
        }
    } else {
        // (N, r = |M|), weights (ml, m0 = m1).
        const double r=std::hypot(x[4],x[5]);Poly P{2,3,{{1,b.gb,0},{-1,b.gb,0},{0,-1,0}},{b.capT,capC,0}};
        const double w[2]={ml,m0},xx[2]={x[0],r};double o[2];projectPoly(P,w,xx,o);
        ref[0]=o[0];ref[4]=r>0?x[4]*o[1]/r:0;ref[5]=r>0?x[5]*o[1]/r:0;
    }
    {   // (T, r = |V|): r + gt |T| <= capS; weights (mt, ml).
        const double r=std::hypot(x[1],x[2]);double best=kNone;
        for(int s=-1;s<=1;s+=2) {
            Poly P{2,3,{{b.gt*double(s),1,0},{-double(s),0,0},{0,-1,0}},{b.capS,0,0}};
            const double w[2]={mt,ml},xx[2]={x[3],r};double o[2];
            const double d=projectPoly(P,w,xx,o);if(d<best){best=d;ref[3]=o[0];ref[1]=r>0?x[1]*o[1]/r:0;ref[2]=r>0?x[2]*o[1]/r:0;}
        }
    }
}

