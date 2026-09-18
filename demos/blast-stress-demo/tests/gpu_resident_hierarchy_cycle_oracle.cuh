// Test-only long-double dense oracle for the entire symmetric cycle.
using Wide=long double;
struct DenseFactor {
    unsigned n=0;std::vector<Wide> lower;
    DenseFactor()=default;
    DenseFactor(std::vector<Wide> matrix,unsigned size):n(size),lower(std::move(matrix)){
        bool zero=true;for(auto v:lower)zero=zero && v==0;if(zero){n=0;return;}
        for(unsigned i=0;i<n;++i)for(unsigned j=0;j<=i;++j){Wide sum=lower[i*n+j];for(unsigned k=0;k<j;++k)sum-=lower[i*n+k]*lower[j*n+k];
            if(i==j){require(sum>0,"independent cycle block is not positive definite");lower[i*n+j]=std::sqrt(sum);}else lower[i*n+j]=sum/lower[j*n+j];}
    }
    std::vector<Wide> solve(std::vector<Wide> value)const{
        if(!n){std::fill(value.begin(),value.end(),0);return value;}
        for(unsigned i=0;i<n;++i){for(unsigned j=0;j<i;++j)value[i]-=lower[i*n+j]*value[j];value[i]/=lower[i*n+i];}
        for(int i=int(n)-1;i>=0;--i){for(unsigned j=i+1;j<n;++j)value[i]-=lower[j*n+i]*value[j];value[i]/=lower[i*n+i];}return value;
    }
};
struct DenseCycleLevel {
    unsigned nodes=0,childNodes=0;std::vector<Wide> a,p;std::vector<unsigned> smooth;
    std::vector<DenseFactor> diagonal,terminal;std::vector<std::vector<unsigned>> groups;
};
class DenseCycleOracle {
    std::vector<DenseCycleLevel> levels;
    static std::vector<Wide> multiply(const std::vector<Wide>& a,unsigned rows,unsigned cols,const std::vector<Wide>& x){
        std::vector<Wide> result(rows);for(unsigned i=0;i<rows;++i)for(unsigned j=0;j<cols;++j)result[i]+=a[i*cols+j]*x[j];return result;
    }
    std::vector<Wide> applyLevel(unsigned level,const std::vector<Wide>& rhs)const{
        const auto& d=levels[level];const unsigned dim=d.nodes*6,childDim=d.childNodes*6;std::vector<Wide> x(dim);
        for(unsigned node=0;node<d.nodes;++node)if(d.smooth[node]){std::vector<Wide> row(rhs.begin()+6*node,rhs.begin()+6*node+6);row=d.diagonal[node].solve(row);for(unsigned k=0;k<6;++k)x[6*node+k]=row[k]/2;}
        for(unsigned g=0;g<d.groups.size();++g){std::vector<Wide> b;for(auto node:d.groups[g])for(unsigned k=0;k<6;++k)b.push_back(rhs[6*node+k]);b=d.terminal[g].solve(b);
            for(unsigned i=0;i<d.groups[g].size();++i)for(unsigned k=0;k<6;++k)x[6*d.groups[g][i]+k]=b[6*i+k];}
        if(childDim){const auto ax=multiply(d.a,dim,dim,x);std::vector<Wide> coarse(childDim);
            for(unsigned i=0;i<dim;++i)for(unsigned j=0;j<childDim;++j)coarse[j]+=d.p[i*childDim+j]*(rhs[i]-ax[i]);
            const auto child=applyLevel(level+1,coarse),correction=multiply(d.p,dim,childDim,child);for(unsigned i=0;i<dim;++i)x[i]+=correction[i];}
        const auto ax=multiply(d.a,dim,dim,x);
        for(unsigned node=0;node<d.nodes;++node)if(d.smooth[node]){std::vector<Wide> row(6);for(unsigned k=0;k<6;++k)row[k]=rhs[6*node+k]-ax[6*node+k];row=d.diagonal[node].solve(row);for(unsigned k=0;k<6;++k)x[6*node+k]+=row[k]/2;}
        return x;
    }
public:
    DenseCycleOracle(const Fixture& f,const ResidentHierarchy& hierarchy,cudaStream_t stream){
        levels.resize(hierarchy.levels());
        for(unsigned level=0;level<levels.size();++level){
            auto& d=levels[level];const auto input=hierarchy.input(level);const unsigned n=input.counts?download(input.counts,2,stream)[0]:input.nodes;
            const unsigned m=input.counts?download(input.counts,2,stream)[1]:input.bonds,dim=6*n;d.nodes=n;d.a.resize(size_t(dim)*dim);d.diagonal.resize(n);d.smooth.resize(n);
            const auto labels=download(input.component,n,stream);std::vector<unsigned> identity(n);if(input.identity)identity=download(input.identity,n,stream);else std::iota(identity.begin(),identity.end(),0);
            std::vector<float2> inertia(n,make_float2(1,1));if(!input.levelBonds)inertia=f.inverse;
            std::vector<CoarseBond> edges(m);if(input.levelBonds)edges=download(input.levelBonds,m,stream);
            else for(unsigned e=0;e<m;++e){const auto a=f.offset0[e],b=f.offset1[e];edges[e]={f.a[e],f.b[e],{a.x,a.y,a.z},{b.x,b.y,b.z},f.health[e]>0?double(f.scale[e]):0};}
            for(const auto e:edges)if(e.scale>0){
                std::vector<unsigned> nodes;if(e.a!=Invalid)nodes.push_back(e.a);if(e.b!=Invalid && e.b!=e.a)nodes.push_back(e.b);
                std::vector<Six> columns(nodes.size()*6);
                for(unsigned i=0;i<nodes.size()*6;++i){Six unit{};unit[i%6]=1;const auto node=nodes[i/6];
                    if(e.a==node){const auto v=factor(unit,inertia[node],{e.offset0.x,e.offset0.y,e.offset0.z});for(unsigned k=0;k<6;++k)columns[i][k]+=e.scale*v[k];}
                    if(e.b==node){const auto v=factor(unit,inertia[node],{e.offset1.x,e.offset1.y,e.offset1.z});for(unsigned k=0;k<6;++k)columns[i][k]-=e.scale*v[k];}}
                for(unsigned i=0;i<columns.size();++i)for(unsigned j=0;j<columns.size();++j)for(unsigned k=0;k<6;++k)
                    d.a[(6*nodes[i/6]+i%6)*dim+6*nodes[j/6]+j%6]+=Wide(columns[i][k])*columns[j][k];
            }
            const auto partCount=download(input.partition.count,1,stream)[0];const auto ids=download(input.partition.ids,partCount,stream);
            const auto begin=download(input.partition.begin,f.positions.size(),stream),end=download(input.partition.end,f.positions.size(),stream);
            std::vector<unsigned> order(download(input.partition.nodeCount,1,stream)[0]);if(input.partition.nodes)order=download(input.partition.nodes,order.size(),stream);else std::iota(order.begin(),order.end(),0);
            for(auto id:ids){const unsigned count=end[id]-begin[id];
                if(count>TerminalNodes){for(unsigned i=begin[id];i<end[id];++i)d.smooth[order[i]]=1;continue;}
                std::vector<unsigned> group(order.begin()+begin[id],order.begin()+end[id]);const unsigned size=6*count;std::vector<Wide> matrix(size*size);bool anchored=false;
                for(unsigned i=0;i<size;++i)for(unsigned j=0;j<size;++j)matrix[i*size+j]=d.a[(6*group[i/6]+i%6)*dim+6*group[j/6]+j%6];
                for(auto e:edges)if(e.scale>0){if(e.a!=Invalid && labels[e.a]==id && (e.b==Invalid || labels[e.b]==Invalid))anchored=true;if(e.b!=Invalid && labels[e.b]==id && (e.a==Invalid || labels[e.a]==Invalid))anchored=true;}
                Wide maximum=0;for(unsigned i=0;i<size;++i)maximum=std::max(maximum,matrix[i*size+i]);
                if(!anchored && maximum>0)for(unsigned k=0;k<6;++k)matrix[k*size+k]+=matrix[k*size+k]>0?matrix[k*size+k]:maximum;
                d.groups.push_back(group);d.terminal.emplace_back(matrix,size);
            }
            for(unsigned node=0;node<n;++node)if(d.smooth[node]){std::vector<Wide> block(36);for(unsigned i=0;i<6;++i)for(unsigned j=0;j<6;++j)block[i*6+j]=d.a[(6*node+i)*dim+6*node+j];d.diagonal[node]=DenseFactor(block,6);}
            if(level+1<levels.size()){
                const auto packed=hierarchy.packed(level).buffers();d.childNodes=download(packed.counts,2,stream)[0];const unsigned childDim=6*d.childNodes;d.p.resize(size_t(dim)*childDim);
                const auto roots=download(hierarchy.topology(level).leaders(),n,stream),map=download(packed.nodeMap,n,stream);
                for(unsigned node=0;node<n;++node){const unsigned root=roots[node];if(root==Invalid || map[root]==Invalid)continue;
                    const auto a=f.positions[identity[node]],b=f.positions[identity[root]];const Three offset={double(a.x)-b.x,double(a.y)-b.y,double(a.z)-b.z};
                    for(unsigned k=0;k<6;++k){Three omega{};if(k<3)omega[k]=1;const auto spin=cross(offset,omega);
                        for(unsigned j=0;j<3;++j){d.p[(6*node+j)*childDim+6*map[root]+k]=Wide(k==j)/inertia[node].x;
                            d.p[(6*node+j+3)*childDim+6*map[root]+k]=(Wide(k==j+3)+spin[j])/inertia[node].y;}}
                }
            }
        }
    }
    std::vector<Six> apply(const std::vector<Vector>& rhs)const{
        std::vector<Wide> wide;for(auto v:rhs)for(auto x:pack(v))wide.push_back(x);const auto result=applyLevel(0,wide);std::vector<Six> out(rhs.size());
        for(unsigned i=0;i<result.size();++i)out[i/6][i%6]=double(result[i]);return out;
    }
};
