// Test the GPU local solve against the original fine coupling equations.
// This does not reproduce the Cholesky algorithm or use a solver-made answer.
Six hostDiagonalAction(const Fixture& f,unsigned node,Six value){
    Six out{};
    for(unsigned slot=f.begin[node];slot<f.begin[node+1];++slot){
        const auto ref=f.refs[slot];if(ref==Invalid)continue;const auto edge=ref&0x7fffffffu;
        if(f.health[edge]<=0)continue;
        const auto offset=(ref>>31)?f.offset1[edge]:f.offset0[edge];const auto d=f.inverse[node];
        auto flux=factor(value,d,{offset.x,offset.y,offset.z});
        for(double& component:flux)component*=double(f.scale[edge])*f.scale[edge];
        const auto moment=cross({offset.x,offset.y,offset.z},{flux[3],flux[4],flux[5]});
        for(unsigned k=0;k<3;++k){out[k]+=d.x*(flux[k]-moment[k]);out[k+3]+=d.y*flux[k+3];}
    }
    return out;
}
void verifyDiagonalSolve(const Fixture& f,const std::vector<Vector>& rhs,const std::vector<Vector>& solved){
    for(unsigned node=0;node<solved.size();++node){
        bool coupled=false;
        if(f.inverse[node].x>0)for(unsigned slot=f.begin[node];slot<f.begin[node+1];++slot){
            const auto ref=f.refs[slot];if(ref!=Invalid && f.health[ref&0x7fffffffu]>0)coupled=true;
        }
        const auto x=pack(solved[node]);
        if(!coupled){for(double v:x)require(v==0,"zero diagonal row did not yield zero pseudoinverse");continue;}
        const auto b=pack(rhs[node]),product=hostDiagonalAction(f,node,x);
        for(unsigned k=0;k<6;++k)require(std::isfinite(x[k]) && std::abs(product[k]-b[k])<2e-12*std::max(1.,std::abs(b[k])),
                                       "local GPU solve disagrees with fine diagonal coupling");
    }
}
void verifySmoothingBound(const Fixture& f,const std::vector<Vector>& vector){
    // Each two-endpoint bond obeys ||a-b||^2 <= 2||a||^2+2||b||^2.
    // Consequently 0 <= L <= 2J for exact block diagonal J. This gives a
    // certified fixed damping interval without CPU spectral estimation.
    std::vector<Six> x(vector.size());for(unsigned i=0;i<x.size();++i)x[i]=pack(vector[i]);
    const auto lx=hostFineOperator(f,x);double energy=0,bound=0;
    for(unsigned i=0;i<x.size();++i){const auto jx=hostDiagonalAction(f,i,x[i]);
        for(unsigned k=0;k<6;++k){energy+=x[i][k]*lx[i][k];bound+=2*x[i][k]*jx[k];}}
    require(energy>=-2e-12*std::max(1.,bound) && energy<=bound+2e-12*std::max(1.,bound),"certified block smoothing bound violated");
}
