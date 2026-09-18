// Independent long-double assembled operator / polynomial oracle. Actual CUDA
// private implementation is called for every basis vector; no public test API.
namespace MotionModeTest {
__global__ void polynomialBasis(PersistentStressArgs a,const unsigned* nodes,unsigned count,unsigned column,Vector* matrix,unsigned stride){
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x){const unsigned node=nodes[i];double x[6]{};if(column/6==node)x[column%6]=1;
        a.hierarchy.rhs[node]={{x[0],x[1],x[2]},{x[3],x[4],x[5]}};}
    __syncthreads();const auto* result=preconditionNativePolynomial(a,nodes,count);
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x){const unsigned node=nodes[i];matrix[size_t(column)*stride+node]=result[node];}
}
void polynomialOperator(){
    constexpr unsigned n=12,size=6*n;
    for(unsigned anchored=0;anchored<2;++anchored){
        Fixture f(n);for(unsigned i=1;i<n;++i){f.edge(i-1,i);if(i>2)f.edge(i-3,i);}
        if(anchored)f.inertia[0]={0,0};f.csr();
        std::vector<long double> matrix(size*size),inverse(size*size);
        // Assemble B B^T directly from each independent physical bond column.
        for(unsigned e=0;e<f.a.size();++e)for(unsigned k=0;k<6;++k){
            std::vector<long double> column(size);
            for(unsigned side=0;side<2;++side){const unsigned node=side?f.b[e]:f.a[e];const auto offset=side?f.offset1[e]:f.offset0[e];
                Three force{},moment{};if(k<3)moment[k]=1;else force[k-3]=1;
                moment=minus(moment,product(coord(offset),force));const long double sign=side?-1:1;
                for(unsigned d=0;d<3;++d){column[node*6+d]=sign*f.inertia[node].angular*moment[d];column[node*6+3+d]=sign*f.inertia[node].linear*force[d];}}
            for(unsigned row=0;row<size;++row)for(unsigned col=0;col<size;++col)matrix[row*size+col]+=column[row]*column[col];
        }
        std::vector<double> packed(n*10);std::vector<unsigned> labels(n,0),order;
        for(unsigned node=0;node<n;++node){
            if(anchored && !node){labels[node]=Invalid;continue;}order.push_back(node);
            long double work[6][12]{};
            for(unsigned row=0;row<6;++row){for(unsigned col=0;col<6;++col)work[row][col]=matrix[(node*6+row)*size+node*6+col];work[row][row+6]=1;}
            for(unsigned k=0;k<6;++k){const auto pivot=work[k][k];require(pivot>0,"polynomial oracle diagonal is not SPD");for(auto& x:work[k])x/=pivot;
                for(unsigned row=0;row<6;++row)if(row!=k){const auto scale=work[row][k];for(unsigned col=0;col<12;++col)work[row][col]-=scale*work[k][col];}}
            for(unsigned row=0;row<6;++row)for(unsigned col=0;col<6;++col){inverse[(node*6+row)*size+node*6+col]=work[row][col+6];if(row<3 && row>=col)packed[size_t(row*(row+1)/2+col)*n+node]=double(work[row][col+6]);}
            // Pack the independent dense operator into the production rigid
            // block layout. The long-double full polynomial oracle is unchanged.
            const long double c=matrix[(node*6+3)*size+node*6+3];
            packed[6*n+node]=double(matrix[(node*6+5)*size+node*6+1]/c);
            packed[7*n+node]=double(matrix[(node*6+3)*size+node*6+2]/c);
            packed[8*n+node]=double(matrix[(node*6+4)*size+node*6+0]/c);
            packed[9*n+node]=double(1/c);
        }
        Device<unsigned> a(f.a.size()),b(f.b.size()),begin(f.begin.size()),refs(f.refs.size()),component(n),nodes(order.size());
        Device<float> health(f.health.size()),scale(f.scale.size());Device<float4> offset0(f.offset0.size()),offset1(f.offset1.size());Device<float2> inertia(n);
        Device<double> factors(packed.size());Device<Vector> rhs(n),out(n),scratch(n),physical(n),columns(size*n);Device<CycleLevel> level(1);
        a.put(f.a);b.put(f.b);begin.put(f.begin);refs.put(f.refs);component.put(labels);nodes.put(order);health.put(f.health);scale.put(f.scale);offset0.put(f.offset0);offset1.put(f.offset1);factors.put(packed);
        std::vector<float2> mass(n);for(unsigned i=0;i<n;++i)mass[i]={f.inertia[i].angular,f.inertia[i].linear};inertia.put(mass);
        CycleLevel descriptor{};descriptor.residual=physical.data;descriptor.input={n,unsigned(f.a.size()),begin.data,refs.data,a.data,b.data,component.data,health.data,scale.data,nullptr,offset0.data,offset1.data,inertia.data,nullptr,nullptr};level.put({descriptor});
        PersistentStressArgs args{};args.hierarchy.cycle.levels=level.data;args.hierarchy.cycle.intermediate=scratch.data;args.hierarchy.rhs=rhs.data;args.hierarchy.result=out.data;args.hierarchy.fineInverse=factors.data;args.hierarchy.inverseStride=n;
        for(unsigned column=anchored?6:0;column<size;++column)polynomialBasis<<<1,kBlockSize>>>(args,nodes.data,order.size(),column,columns.data,n);
        check(cudaGetLastError());check(cudaDeviceSynchronize());const auto observed=columns.get();
        auto multiply=[&](const std::vector<long double>& m,const std::vector<long double>& x){std::vector<long double> y(size);for(unsigned r=0;r<size;++r)for(unsigned c=0;c<size;++c)y[r]+=m[r*size+c]*x[c];return y;};
        long double worst=0,symmetry=0;std::vector<long double> actual(size*size);
        for(unsigned column=anchored?6:0;column<size;++column){std::vector<long double> x(size),r(size);r[column]=1;
            // Independent dense long-double block inverse is the candidate
            // preconditioner oracle. Accuracy and SPD limits are unchanged.
            x=multiply(inverse,r);
            for(unsigned node=0;node<n;++node){auto y=unpack(observed[size_t(column)*n+node]);for(unsigned k=0;k<6;++k){const auto row=node*6+k;actual[row*size+column]=y[k];worst=std::max(worst,fabsl(y[k]-x[row])/(1+fabsl(x[row])));}}
        }
        for(unsigned row=anchored?6:0;row<size;++row)for(unsigned col=anchored?6:0;col<size;++col)symmetry=std::max(symmetry,fabsl(actual[row*size+col]-actual[col*size+row])/(1+fabsl(actual[row*size+col])));
        require(worst<2e-11L && symmetry<2e-11L,"polynomial differs from independent operator or loses symmetry");
        // Full dynamic-subspace Cholesky verifies positive definiteness, even
        // for a free component whose physical operator itself is singular.
        for(unsigned k=anchored?6:0;k<size;++k){long double d=actual[k*size+k];for(unsigned j=anchored?6:0;j<k;++j)d-=actual[k*size+j]*actual[k*size+j];require(d>0,"polynomial not positive definite");actual[k*size+k]=sqrtl(d);
            for(unsigned row=k+1;row<size;++row){long double v=actual[row*size+k];for(unsigned j=anchored?6:0;j<k;++j)v-=actual[row*size+j]*actual[k*size+j];actual[row*size+k]=v/actual[k*size+k];}}
        std::printf("polynomial oracle nodes=%u bonds=%zu anchored=%u all_basis=true relative_error=%.3Lg symmetry_error=%.3Lg SPD=true\n",n,f.a.size(),anchored,worst,symmetry);
    }
}
}
