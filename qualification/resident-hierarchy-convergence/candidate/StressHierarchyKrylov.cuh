// Right-preconditioned flexible GMRES candidate. Not yet bound to native solve.
// The residual remains b-L*x: no assumed rigid null space, projected load, or
// change to the physical operator. Qualification must precede native adoption.
#pragma once
#include "StressHierarchyCycle.cuh"
namespace Nv { namespace Blast { namespace StressHierarchy {
constexpr unsigned KrylovRestart=32;
struct KrylovState {
    double h[(KrylovRestart+1)*KrylovRestart],c[KrylovRestart],s[KrylovRestart];
    double rhs[KrylovRestart+1],y[KrylovRestart],residual[KrylovRestart+1];
    double value,threshold,gradient,initialGradient,beta;
    unsigned iterations,converged,error;
};
struct KrylovView {
    CycleDeviceView cycle;
    const Vector* rhs;
    Vector *x,*r,*v,*z;
    KrylovState *results,*cooperative;
    double* partial;
    unsigned maxIterations;
    double tolerance;
};
__device__ __forceinline__ double dot(Vector a,Vector b){
    return a.angular.x*b.angular.x+a.angular.y*b.angular.y+a.angular.z*b.angular.z
        +a.linear.x*b.linear.x+a.linear.y*b.linear.y+a.linear.z*b.linear.z;
}
template<bool Local>struct KrylovWork {
    Input input;unsigned id;KrylovState* state;double* partial;
    __device__ unsigned first()const{if constexpr(Local)return threadIdx.x;else return blockIdx.x*blockDim.x+threadIdx.x;}
    __device__ unsigned stride()const{if constexpr(Local)return blockDim.x;else return gridDim.x*blockDim.x;}
    __device__ unsigned count()const{return input.partition.end[id]-input.partition.begin[id];}
    __device__ unsigned node(unsigned i)const{return orderedNode(input,input.partition.begin[id]+i);}
    __device__ void sync()const{if constexpr(Local)__syncthreads();else cooperative_groups::this_grid().sync();}
    __device__ double sum(double value)const{
        __shared__ double warps[Threads/32];value=warpSum(value);
        if(!(threadIdx.x&31u))warps[threadIdx.x/32]=value;__syncthreads();
        if(!threadIdx.x){double total=0;for(unsigned i=0;i<blockDim.x/32;++i)total+=warps[i];
            if constexpr(Local)state->value=total;else partial[blockIdx.x]=total;}
        sync();if constexpr(!Local){if(!first()){double total=0;for(unsigned i=0;i<gridDim.x;++i)total+=partial[i];state->value=total;}sync();}
        const double result=state->value;sync();return result;
    }
    __device__ double inner(const Vector* a,const Vector* b)const{
        double value=0;for(unsigned i=first();i<count();i+=stride()){const auto n=node(i);value+=dot(a[n],b[n]);}return sum(value);
    }
    __device__ void multiply(const Vector* a,Vector* b)const{
        for(unsigned i=first()/32;i<count();i+=stride()/32){const auto n=node(i);const auto value=warpSum(levelRowContribution(input,n,a));if(!(threadIdx.x&31u))b[n]=value;}sync();
    }
    // ||B^T r||^2 is the original native convergence quantity. Own each bond
    // exactly once, including bonds whose first endpoint is prescribed.
    __device__ double gradient(const Vector* r)const{
        double value=0;
        for(unsigned i=first();i<count();i+=stride()){const auto n=node(i);
            for(unsigned slot=input.begin[n];slot<input.begin[n+1];++slot){const auto ref=input.refs[slot];if(ref==Invalid)continue;
                const unsigned edge=ref&0x7fffffffu;if(sourceHealth(input,edge)<=0)continue;
                const auto a=sourceFirst(input,edge),b=sourceSecond(input,edge);
                const bool dynamicA=a!=Invalid && input.component[a]!=Invalid;
                if((ref>>31) && dynamicA)continue;
                Vector x{},y{};
                if(dynamicA)x=couple(scaledValue(r[a],sourceInertia(input,a)),sourceOffset(input,edge,false));
                if(b!=Invalid && input.component[b]!=Invalid)y=couple(scaledValue(r[b],sourceInertia(input,b)),sourceOffset(input,edge,true));
                const auto difference=mul(sub(x,y),sourceScale(input,edge));value+=dot(difference,difference);
            }
        }
        return sum(value);
    }
};
__device__ __forceinline__ void krylovLeastSquares(KrylovState& s,unsigned j){
    // Apply the new column's stored plane rotations, then introduce one more.
    for(unsigned k=0;k<j;++k){const double a=s.h[k*KrylovRestart+j],b=s.h[(k+1)*KrylovRestart+j];
        s.h[k*KrylovRestart+j]=s.c[k]*a+s.s[k]*b;s.h[(k+1)*KrylovRestart+j]=-s.s[k]*a+s.c[k]*b;}
    const double a=s.h[j*KrylovRestart+j],b=s.h[(j+1)*KrylovRestart+j],length=hypot(a,b);
    if(!(length>0) || !isfinite(length)){s.error=2;return;}
    s.c[j]=a/length;s.s[j]=b/length;s.h[j*KrylovRestart+j]=length;s.h[(j+1)*KrylovRestart+j]=0;
    s.rhs[j+1]=-s.s[j]*s.rhs[j];s.rhs[j]*=s.c[j];
    for(int row=int(j);row>=0;--row){double value=s.rhs[row];for(unsigned k=row+1;k<=j;++k)value-=s.h[row*KrylovRestart+k]*s.y[k];
        s.y[row]=value/s.h[row*KrylovRestart+row];if(!isfinite(s.y[row]))s.error=2;}
    // Reconstruct the physical residual in the Arnoldi basis, not a norm of
    // the transformed residual. Reverse the Givens rotations of its tail.
    for(unsigned k=0;k<=j;++k)s.residual[k]=0;s.residual[j+1]=s.rhs[j+1];
    for(int k=int(j);k>=0;--k){const double a=s.residual[k],b=s.residual[k+1];s.residual[k]=s.c[k]*a-s.s[k]*b;s.residual[k+1]=s.s[k]*a+s.c[k]*b;}
}
template<bool Local>
__device__ void solveKrylovComponent(KrylovView a,KrylovWork<Local> work,TerminalShared& terminal){
    auto& s=*work.state;const size_t n=work.input.nodes;
    if(!work.first())s={};work.sync();
    for(unsigned i=work.first();i<work.count();i+=work.stride()){const auto node=work.node(i);a.x[node]={};a.r[node]=a.rhs[node];}work.sync();
    const double initial=work.gradient(a.r);
    if(!work.first()){s.initialGradient=s.gradient=initial;s.threshold=initial*a.tolerance*a.tolerance;
        s.converged=initial<=s.threshold;if(!isfinite(initial) || !(a.tolerance>0))s.error=1;}
    work.sync();
    while(!s.converged && !s.error && s.iterations<a.maxIterations){
        const double norm=sqrt(work.inner(a.r,a.r));
        if(!work.first()){s.beta=norm;for(unsigned k=0;k<=KrylovRestart;++k)s.rhs[k]=0;s.rhs[0]=norm;if(!(norm>0)||!isfinite(norm))s.error=2;}
        work.sync();if(s.error)break;
        for(unsigned i=work.first();i<work.count();i+=work.stride()){const auto node=work.node(i);a.v[node]=mul(a.r[node],1/norm);}work.sync();
        for(unsigned j=0;j<KrylovRestart && s.iterations<a.maxIterations;++j){
            const Vector* source=a.v+j*n;Vector* direction=a.z+j*n;Vector* next=a.v+(j+1)*n;
            // Start every solve with one inexpensive residual direction. Simple
            // load modes can finish before paying for multilevel work. FGMRES
            // stores each actual Z column, so this varying preconditioner needs
            // neither a recurrence restart nor a second execution backend.
            if(!s.iterations){for(unsigned i=work.first();i<work.count();i+=work.stride()){const auto node=work.node(i);direction[node]=source[node];}work.sync();}
            else cyclePass<Local>(a.cycle.levels,a.cycle.depth,a.cycle.pool,terminal,source,direction,work.id);
            work.multiply(direction,next);
            // Two-pass modified Gram-Schmidt controls loss of orthogonality
            // when accepted residuals approach the solver's accuracy target.
            for(unsigned pass=0;pass<2;++pass)for(unsigned k=0;k<=j;++k){
                const auto basis=a.v+k*n;const double coefficient=work.inner(basis,next);
                if(!work.first()){if(!pass)s.h[k*KrylovRestart+j]=coefficient;else s.h[k*KrylovRestart+j]+=coefficient;}
                for(unsigned i=work.first();i<work.count();i+=work.stride()){const auto node=work.node(i);next[node]=sub(next[node],mul(basis[node],coefficient));}work.sync();
            }
            const double length=sqrt(work.inner(next,next));
            if(!work.first()){s.h[(j+1)*KrylovRestart+j]=length;krylovLeastSquares(s,j);++s.iterations;}
            work.sync();if(s.error)break;
            for(unsigned i=work.first();i<work.count();i+=work.stride()){const auto node=work.node(i);next[node]=length>0?mul(next[node],1/length):Vector{};
                Vector residual{};for(unsigned k=0;k<=j+1;++k)residual=add(residual,mul(a.v[k*n+node],s.residual[k]));a.r[node]=residual;}
            work.sync();const double gradient=work.gradient(a.r);
            if(!work.first()){s.gradient=gradient;if(!isfinite(gradient))s.error=2;}work.sync();
            const bool commit=s.gradient<=s.threshold || j+1==KrylovRestart || s.iterations==a.maxIterations || length==0;
            if(commit){
                for(unsigned i=work.first();i<work.count();i+=work.stride()){const auto node=work.node(i);Vector change{};
                    for(unsigned k=0;k<=j;++k)change=add(change,mul(a.z[k*n+node],s.y[k]));a.x[node]=add(a.x[node],change);}work.sync();
                work.multiply(a.x,a.r);
                for(unsigned i=work.first();i<work.count();i+=work.stride()){const auto node=work.node(i);a.r[node]=sub(a.rhs[node],a.r[node]);}work.sync();
                const double accepted=work.gradient(a.r);
                if(!work.first()){s.gradient=accepted;s.converged=accepted<=s.threshold;if(!isfinite(accepted)||(!s.converged && length==0))s.error=2;}
                work.sync();break;
            }
        }
    }
    if(!work.first())a.results[work.id]=s;work.sync();
}
template<bool Local>
__global__ void residentKrylov(KrylovView a){
    __shared__ TerminalShared terminal;__shared__ KrylovState local;
    const auto input=resolvedInput(a.cycle.levels[0].input);
    // A cooperative qualification launch owns one complete component. The
    // batched block schedule owns disjoint ranges from the native partition.
    if constexpr(!Local){if(*input.partition.count!=1){if(!blockIdx.x && !threadIdx.x){a.results[0]={};a.results[0].error=8;}return;}}
    for(unsigned slot=Local?blockIdx.x:0;slot<*input.partition.count;slot+=Local?gridDim.x:1){
        const unsigned id=input.partition.ids[slot];auto* state=Local?&local:a.cooperative;
        KrylovWork<Local> work{input,id,state,a.partial};
        if(!usable(a.cycle.status) || a.cycle.status->generation!=*input.generation){if(!work.first()){a.results[id]={};a.results[id].error=4;}work.sync();continue;}
        solveKrylovComponent(a,work,terminal);
    }
}
}}}
