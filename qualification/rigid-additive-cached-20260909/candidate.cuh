// Six rigid component modes supply a small additive coarse correction:
// P_new = P_polynomial + Z (Z^T B B^T Z)^-1 Z^T. The physical operator,
// residual acceptance and final bond recovery are unchanged. Only anchored
// components use this SPD coarse space; free-body null modes remain projected.
__device__ __noinline__ void buildNativeRigidCoarse(const PersistentStressArgs& a,
    const unsigned* nodes,unsigned count,unsigned id,NativeRigidCoarse& coarse)
{
    using namespace StressHierarchy;
    __shared__ double partial[21][kBlockSize/32];
    double gram[21]{};
    const auto input=a.hierarchy.cycle.levels[0].input;
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x){const unsigned node=nodes[i];
        for(unsigned slot=input.begin[node];slot<input.begin[node+1];++slot){
            const unsigned ref=input.refs[slot];if(ref==Invalid)continue;
            const unsigned edge=ref&0x7fffffffu;if(input.health[edge]<=0)continue;
            const bool back=ref>>31;const unsigned other=back?input.node0[edge]:input.node1[edge];
            const bool fixed=input.component[other]==Invalid;
            // Exactly one visit per live edge, including self and fixed edges.
            if(!fixed && (other<node || (other==node && back)))continue;
            auto r=StressHierarchy::add(a.hierarchy.modes.position[node],sourceOffset(input,edge,back));
            if(!fixed)r=StressHierarchy::sub(r,StressHierarchy::add(a.hierarchy.modes.position[other],sourceOffset(input,edge,!back)));
            const double xyz[3]={r.x,r.y,r.z},norm=motionDot(r,r),w=double(input.scale[edge])*input.scale[edge];
            for(unsigned row=0;row<6;++row)for(unsigned col=0;col<=row;++col){double value=0;
                if(row<3)value=(row==col?norm+double(fixed):0)-xyz[row]*xyz[col];
                else if(fixed && col<3){const double3 axis={double(col==0),double(col==1),double(col==2)};value=motionEntry(StressHierarchy::cross(r,axis),row-3);}
                else if(fixed && row==col)value=1;
                gram[triangle(row,col)]+=w*value;
            }
        }
    }
    reduceMotionValues(gram,partial);
    if(!threadIdx.x){
        coarse.valid=1;
        for(unsigned i=0;i<6;++i){const double value=gram[triangle(i,i)];
            if(!(value>0) || !isfinite(value)){coarse.valid=0;break;}coarse.scale[i]=1/sqrt(value);}
        for(unsigned row=0;coarse.valid && row<6;++row)for(unsigned col=0;col<=row;++col){
            double value=gram[triangle(row,col)]*coarse.scale[row]*coarse.scale[col];
            for(unsigned k=0;k<col;++k)value-=coarse.factor[triangle(row,k)]*coarse.factor[triangle(col,k)];
            if(row==col){if(!(value>0) || !isfinite(value)){coarse.valid=0;break;}value=sqrt(value);}
            else value/=coarse.factor[triangle(col,col)];coarse.factor[triangle(row,col)]=value;
        }
        if(!coarse.valid)a.hierarchy.failed[id]=1;
    }
    __syncthreads();
}
__device__ __noinline__ void addNativeRigidCoarse(const PersistentStressArgs& a,
    const unsigned* nodes,unsigned count,NativeRigidCoarse& coarse,StressHierarchy::Vector* result)
{
    using namespace StressHierarchy;
    if(!coarse.valid)return;
    __shared__ double partial[6][kBlockSize/32];double sums[6]{};
    const auto input=a.hierarchy.cycle.levels[0].input;
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x){const unsigned node=nodes[i];
        const auto value=restrictValue(a.hierarchy.rhs[node],a.hierarchy.modes.position[node],input.inertia[node]);
        sums[0]+=value.angular.x;sums[1]+=value.angular.y;sums[2]+=value.angular.z;
        sums[3]+=value.linear.x;sums[4]+=value.linear.y;sums[5]+=value.linear.z;
    }
    reduceMotionValues(sums,partial);
    if(!threadIdx.x){
        for(unsigned row=0;row<6;++row){double value=sums[row]*coarse.scale[row];
            for(unsigned col=0;col<row;++col)value-=coarse.factor[triangle(row,col)]*coarse.coefficient[col];
            coarse.coefficient[row]=value/coarse.factor[triangle(row,row)];}
        for(int row=5;row>=0;--row){double value=coarse.coefficient[row];
            for(unsigned col=row+1;col<6;++col)value-=coarse.factor[triangle(col,row)]*coarse.coefficient[col];
            coarse.coefficient[row]=value/coarse.factor[triangle(row,row)];}
        for(unsigned i=0;i<6;++i)coarse.coefficient[i]*=coarse.scale[i];
    }
    __syncthreads();
    const auto* c=coarse.coefficient;const Vector value={{c[0],c[1],c[2]},{c[3],c[4],c[5]}};
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x){const unsigned node=nodes[i];
        result[node]=StressHierarchy::add(result[node],prolongValue(value,a.hierarchy.modes.position[node],input.inertia[node]));}
    __syncthreads();
}
