// Private construction fragment included inside StressHierarchy's namespace.
// Strength-matched aggregation (Input::matched, BLAST_STRESS_MATCHED_HIERARCHY=1).
//
// With bonds of very different stiffness -- above all, per-bond rotational
// stiffness, where thin joints make hinges -- the slow error lives in smooth
// multi-chunk modes: a veneer wall or gable panel bending out of plane, a
// cantilever post rocking on its footing joint. A coarse level captures them
// only when its aggregates are glued by stiff bonds and the soft joints lie
// between aggregates. Hub-first star aggregation ignores stiffness and puts
// soft joints inside aggregates. Here each node proposes to its unmatched
// neighbour with the strongest coupling, normalized
//     strength(e) = ||A_ab(e)||_F / sqrt(n_a n_b),  n = sum of self-block norms,
// and mutual proposals pair (seed: the higher-degree node, then the lower
// index). Unpaired nodes join the strongest adjacent seed; the existing star
// rounds aggregate anything still unowned, so a level always coarsens.
// CPU prototype on captured systems (vibe-land oracle captures): two-storey
// veneer house, iterations to 1e-3 force error 319 -> 93 (rotational
// stiffness on), 114 -> 31 (off); fleet lab post-fracture 57 -> 27.
constexpr unsigned MatchRounds=2;
// ||A_ab||_F^2 of one bond's coupling between its row side (offset ra,
// inertia da) and column side (rb, db): with C^T = [[I,0],[[r]x,I]] and
// S^2 = s^2 diag(W, I), C_a S^2 C_b^T = s^2 [[W + Ra^T Rb, Ra^T], [Rb, I]],
// Ra^T Rb = (ra.rb) I - rb ra^T.
__device__ __forceinline__ StressReal matchBlockNorm2(StressReal3 ra,StressReal3 rb,float2 da,float2 db,StressReal s2,const float* w){
    const StressReal p[3]={ra.x,ra.y,ra.z},q[3]={rb.x,rb.y,rb.z},dot=p[0]*q[0]+p[1]*q[1]+p[2]*q[2];
    StressReal top=0;
    for(unsigned i=0;i<3;++i)for(unsigned j=0;j<3;++j){
        const StressReal wij=w?StressReal(w[symmetricEntry(i,j)]):StressReal(i==j);
        const StressReal m=wij+(i==j?dot:StressReal(0))-q[i]*p[j];top+=m*m;
    }
    const StressReal aa=StressReal(da.x)*db.x,al=StressReal(da.x)*db.y,la=StressReal(da.y)*db.x,ll=StressReal(da.y)*db.y;
    const StressReal ra2=2*(p[0]*p[0]+p[1]*p[1]+p[2]*p[2]),rb2=2*(q[0]*q[0]+q[1]*q[1]+q[2]*q[2]);
    return s2*s2*(aa*aa*top+al*al*ra2+la*la*rb2+ll*ll*3);
}
__device__ __forceinline__ const float* matchWeight(const Input& a,unsigned bond){
    if(!a.angularWeight)return nullptr;
    return a.angularWeight+6*size_t(a.levelBonds?a.bondIdentity[bond]:bond);
}
__device__ __forceinline__ bool matchEligible(const Input& a,unsigned node){
    return node<a.nodes && a.component[node]!=Invalid && !componentUsesFineSolver(a,a.component[node]);
}
// n_a = sum over live, non-self bonds of ||A_aa(e)||_F.
__device__ __forceinline__ void matchNorms(const Input& a,Buffers b,Status* status,unsigned logicalBlock){
    const unsigned node=logicalBlock*blockDim.x+threadIdx.x;if(node>=a.nodes)return;
    b.proposal[node]=Invalid;StressReal sum=0;
    if(matchEligible(a,node)){
        const bool compact=cachedSelfRows(a);const unsigned end=compact?a.nonSelfEnd[node]:a.begin[node+1];
        const float2 d=sourceInertia(a,node);
        for(unsigned i=a.begin[node];i<end;++i){
            const unsigned other=neighbour(a,node,i,status,compact);if(other==Invalid)continue;
            const unsigned ref=compact?a.nonSelfRefs[i]:a.refs[i],bond=ref&0x7fffffffu;
            const StressReal3 r=sourceOffset(a,bond,ref>>31);const StressReal s=sourceScale(a,bond);
            sum+=sqrt(matchBlockNorm2(r,r,d,d,s*s,matchWeight(a,bond)));
        }
    }
    b.norm[node]=sum;
}
// The strongest unowned eligible neighbour, ties to the lower index; Invalid if none.
__device__ __forceinline__ unsigned matchStrongest(const Input& a,Buffers b,Status* status,unsigned node,bool seedsOnly,unsigned& bestBond){
    const bool compact=cachedSelfRows(a);const unsigned end=compact?a.nonSelfEnd[node]:a.begin[node+1];
    const float2 dn=sourceInertia(a,node);unsigned best=Invalid;StressReal strength=-1;bestBond=Invalid;
    for(unsigned i=a.begin[node];i<end;++i){
        const unsigned other=neighbour(a,node,i,status,compact);if(other==Invalid)continue;
        if(seedsOnly?b.owner[other]!=other:b.owner[other]!=Invalid)continue;
        const unsigned ref=compact?a.nonSelfRefs[i]:a.refs[i],bond=ref&0x7fffffffu;const bool back=ref>>31;
        const StressReal s=sourceScale(a,bond);
        const StressReal norm=b.norm[node]*b.norm[other];
        const StressReal value=norm>0?sqrt(matchBlockNorm2(sourceOffset(a,bond,back),sourceOffset(a,bond,!back),dn,sourceInertia(a,other),s*s,matchWeight(a,bond))/norm):StressReal(0);
        if(value>strength || (value==strength && other<best)){strength=value;best=other;bestBond=bond;}
    }
    return best;
}
__device__ __forceinline__ void matchPropose(const Input& a,Buffers b,Status* status,unsigned logicalBlock){
    const unsigned node=logicalBlock*blockDim.x+threadIdx.x;if(node>=a.nodes)return;
    b.seed[node]=Invalid;
    if(!matchEligible(a,node) || b.owner[node]!=Invalid)return;
    unsigned bond;b.seed[node]=matchStrongest(a,b,status,node,false,bond);b.proposal[node]=bond;
}
__device__ __forceinline__ unsigned matchDegree(const Input& a,unsigned node){return a.begin[node+1]-a.begin[node];}
// Mutual proposals pair. Each node writes only its own owner and member bond.
__device__ __forceinline__ void matchAccept(const Input& a,Buffers b,unsigned logicalBlock){
    const unsigned node=logicalBlock*blockDim.x+threadIdx.x;if(node>=a.nodes)return;
    const unsigned other=b.seed[node];
    if(other==Invalid || b.seed[other]!=node)return;
    const unsigned dn=matchDegree(a,node),dp=matchDegree(a,other);
    const unsigned seed=(dn>dp || (dn==dp && node<other))?node:other;
    b.owner[node]=seed;b.memberBond[node]=seed==node?Invalid:b.proposal[node];
}
// Unpaired nodes choose the strongest adjacent seed (read before anyone joins).
__device__ __forceinline__ void matchChooseSeed(const Input& a,Buffers b,Status* status,unsigned logicalBlock){
    const unsigned node=logicalBlock*blockDim.x+threadIdx.x;if(node>=a.nodes)return;
    b.seed[node]=Invalid;
    if(!matchEligible(a,node) || b.owner[node]!=Invalid)return;
    unsigned bond;b.seed[node]=matchStrongest(a,b,status,node,true,bond);b.proposal[node]=bond;
}
__device__ __forceinline__ void matchJoinSeed(const Input& a,Buffers b,unsigned logicalBlock){
    const unsigned node=logicalBlock*blockDim.x+threadIdx.x;if(node>=a.nodes)return;
    const unsigned seed=b.seed[node];
    if(seed!=Invalid){b.owner[node]=seed;b.memberBond[node]=b.proposal[node];}
    b.seed[node]=0;   // the star rounds read seed as a flag
}
