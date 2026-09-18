// SPDX-License-Identifier: BSD-3-Clause
// Independent dense G^T D G oracle; no production device helper runs on the CPU.
#include "ElasticTestFixture.h"
#include "../detail/StressElasticAccurate.cuh"
__global__ void accurateAction(E::Graph graph,const E::Vector* x,E::Vector* output,double length) {
    const auto i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=graph.nodes)return;
    const auto value=E::Accurate::row(graph,i,x,length);
    for(unsigned k=0;k<6;++k)output[i].v[k]=E::Accurate::value(value.v[k]);
}

void exercise(Fixture f) {
    Uploaded d(f);require(!d.validate(),"valid fixture rejected");const auto a=f.matrix();const unsigned n=f.size();
    Device<E::Vector> x(f.x.size()),y(f.x.size()),external(f.x.size()),prescribed(f.x.size());
    external.put(f.external);prescribed.put(f.prescribed);
    for(unsigned column=0;column<n;++column) {
        std::vector<E::Vector> v(f.x.size());v[column/6].v[column%6]=1;x.put(v);E::apply<<<1,128>>>(d.graph,x.p,y.p,d.error.p);
        const auto result=y.get();for(unsigned row=0;row<n;++row)near(result[row/6].v[row%6],f.fixed[row/6]||f.fixed[column/6]?0:a[row*n+column],"assembled operator");
        for(double length:{.25,1.,4.}) {
            auto scaled=v;for(auto& value:scaled)for(unsigned k=3;k<6;++k)value.v[k]*=length;x.put(scaled);
            accurateAction<<<1,128>>>(d.graph,x.p,y.p,length);const auto exact=y.get();
            for(unsigned row=0;row<n;++row)near(exact[row/6].v[row%6],f.fixed[row/6]||f.fixed[column/6]?0:a[row*n+column],"compensated assembled operator");
        }

    }
    E::buildRhs<<<1,128>>>(d.graph,external.p,prescribed.p,y.p,d.error.p);auto rhs=y.get();Dense expected(n);
    for(unsigned i=0;i<n;++i)if(!f.fixed[i/6]) {
        expected[i]=f.external[i/6].v[i%6];for(unsigned j=0;j<n;++j)if(f.fixed[j/6])expected[i]-=a[i*n+j]*f.prescribed[j/6].v[j%6];
        for(const auto& b:f.bonds)if(b.live){const auto g=f.G(b);for(unsigned u=0;u<6;++u)for(unsigned v=0;v<6;++v)expected[i]+=g[u*n+i]*b.stiffness.v[6*u+v]*b.inelastic.v[v];}
        near(rhs[i/6].v[i%6],expected[i],"support/inelastic RHS");
    }
    Device<E::Matrix> diagonal(f.x.size()),lower(f.x.size());
    E::buildDiagonal<<<1,128>>>(d.graph,diagonal.p,lower.p,d.limits,d.error.p,d.numerical.p);require(!d.numerical.get()[0],"diagonal factor failed");
    const auto blocks=diagonal.get();for(unsigned i=0;i<f.x.size();++i)for(unsigned j=0;j<6;++j)for(unsigned k=0;k<6;++k)
        near(blocks[i].v[6*j+k],f.fixed[i]?0:a[(6*i+j)*n+6*i+k],"diagonal block");
    E::applyDiagonal<<<1,128>>>(d.graph,lower.p,y.p,x.p,d.numerical.p);const auto inverse=x.get();
    for(unsigned i=0;i<f.x.size();++i)if(!f.fixed[i])for(unsigned row=0;row<6;++row){double value=0;for(unsigned j=0;j<6;++j)value+=blocks[i].v[6*row+j]*inverse[i].v[j];near(value,rhs[i].v[row],"block Jacobi action");}
    std::vector<E::Vector> q(f.x.size());std::vector<unsigned> unknown;
    for(unsigned i=0;i<n;++i)if(!f.fixed[i/6])unknown.push_back(i);
    if(std::count(f.fixed.begin(),f.fixed.end(),1)) {
        Dense reduced(unknown.size()*unknown.size()),b(unknown.size());for(unsigned i=0;i<unknown.size();++i){b[i]=expected[unknown[i]];for(unsigned j=0;j<unknown.size();++j)reduced[i*unknown.size()+j]=a[unknown[i]*n+unknown[j]];}
        if(!unknown.empty()){const auto solution=solve(reduced,b);for(unsigned k=0;k<unknown.size();++k)q[unknown[k]/6].v[unknown[k]%6]=solution[k];}
    }else for(unsigned i=0;i<n;++i)q[i/6].v[i%6]=std::sin(i*.3);
    x.put(q);Device<E::Vector> response(f.bonds.size());Device<double> energy(f.bonds.size());
    E::recover<<<1,128>>>(d.graph,x.p,prescribed.p,response.p,energy.p,d.error.p);const auto s=response.get();const auto en=energy.get();
    E::Accurate::recover<<<1,128>>>(d.graph,x.p,prescribed.p,response.p,energy.p,d.error.p);const auto accurate=response.get();const auto accurateEnergy=energy.get();
    Dense gradient(n);double force[3]{},moment[3]{};
    for(unsigned id=0;id<f.bonds.size();++id) {
        const auto& b=f.bonds[id];const auto g=f.G(b);double deformation[6]{},expectedResponse[6]{},e=0;
        if(b.live)for(unsigned row=0;row<6;++row){deformation[row]=-b.inelastic.v[row];for(unsigned j=0;j<n;++j)deformation[row]+=g[row*n+j]*(f.fixed[j/6]?f.prescribed[j/6].v[j%6]:q[j/6].v[j%6]);}
        if(b.live)for(unsigned row=0;row<6;++row)for(unsigned j=0;j<6;++j)expectedResponse[row]+=b.stiffness.v[6*row+j]*deformation[j];
        for(unsigned k=0;k<6;++k){near(s[id].v[k],expectedResponse[k],"bond wrench");near(accurate[id].v[k],expectedResponse[k],"compensated bond wrench");e+=.5*deformation[k]*expectedResponse[k];}
        near(accurateEnergy[id],e,"compensated energy");near(en[id],e,"elastic energy");require(en[id]>=-1e-13,"negative energy");
        for(unsigned i=0;i<n;++i)for(unsigned k=0;k<6;++k)gradient[i]+=g[k*n+i]*s[id].v[k];
    }
    for(unsigned i=0;i<f.x.size();++i){const auto p=f.x[i];for(unsigned k=0;k<3;++k){force[k]+=gradient[6*i+k];moment[k]+=gradient[6*i+3+k];}
        moment[0]+=p.y*gradient[6*i+2]-p.z*gradient[6*i+1];moment[1]+=p.z*gradient[6*i]-p.x*gradient[6*i+2];moment[2]+=p.x*gradient[6*i+1]-p.y*gradient[6*i];}
    for(unsigned k=0;k<3;++k){near(force[k],0,"net internal force");near(moment[k],0,"net internal moment");}
    if(std::count(f.fixed.begin(),f.fixed.end(),1))for(unsigned i=0;i<n;++i)if(!f.fixed[i/6])near(gradient[i],f.external[i/6].v[i%6],"external plus internal equilibrium");
    if(!std::count(f.fixed.begin(),f.fixed.end(),1))for(unsigned mode=0;mode<6;++mode) {
        std::vector<E::Vector> rigid(f.x.size());for(unsigned i=0;i<f.x.size();++i) {
            if(mode<3)rigid[i].v[mode]=1;
            else {const auto p=f.x[i];rigid[i].v[mode]=1;
                if(mode==3){rigid[i].v[1]=-p.z;rigid[i].v[2]=p.y;}
                if(mode==4){rigid[i].v[0]=p.z;rigid[i].v[2]=-p.x;}
                if(mode==5){rigid[i].v[0]=-p.y;rigid[i].v[1]=p.x;}}
        }
        x.put(rigid);E::apply<<<1,128>>>(d.graph,x.p,y.p,d.error.p);for(const auto& r:y.get())for(double v:r.v)near(v,0,"six rigid null modes");
    }
}
void analyticalChannels() {
    Fixture f;f.x={{0,0,0},{1,0,0}};f.fixed={1,0};f.starts={0,1,2};f.refs={0,0};
    E::Bond bond{};bond.first=0;bond.second=1;bond.live=1;
    for(unsigned i=0;i<3;++i)bond.frame[3*i+i]=1;
    for(unsigned i=0;i<6;++i)bond.stiffness.v[6*i+i]=2+i;
    f.bonds={bond};Uploaded d(f);require(!d.validate(),"analytical interface validation");
    Device<E::Vector> q(2),y(2),prescribed(2),response(1);Device<double> energy(1);prescribed.put(std::vector<E::Vector>(2));
    // Diagonal interface stiffness: support at x=0, load applied at node x=1.
    // Moment balance about the common point gives M_y=T_y-F_z, M_z=T_z+F_y.
    for(unsigned channel=0;channel<6;++channel) {
        double load[6]{};load[channel]=1;std::vector<E::Vector> values(2);auto& v=values[1];
        v.v[3]=load[3]/5;v.v[4]=(load[4]-load[2])/6;v.v[5]=(load[5]+load[1])/7;
        v.v[0]=load[0]/2;v.v[1]=load[1]/3+v.v[5];v.v[2]=load[2]/4-v.v[4];q.put(values);
        E::apply<<<1,128>>>(d.graph,q.p,y.p,d.error.p);const auto result=y.get();
        for(unsigned k=0;k<6;++k){near(result[0].v[k],0,"prescribed row");near(result[1].v[k],load[k],"analytical force/moment compliance");}
        E::recover<<<1,128>>>(d.graph,q.p,prescribed.p,response.p,energy.p,d.error.p);const auto r=response.get()[0];
        const double expected[6]={load[0],load[1],load[2],load[3],load[4]-load[2],load[5]+load[1]};
        for(unsigned k=0;k<6;++k)near(r.v[k],expected[k],"analytical interface wrench");
        near(energy.get()[0],.5*v.v[channel],"analytical work/energy");
    }
}
void replicatedRows() {
    Fixture asset,batch;batch.x.clear();batch.bonds.clear();batch.fixed.clear();batch.starts.clear();batch.refs.clear();
    batch.external.clear();batch.prescribed.clear();const auto a=asset.matrix();const unsigned width=asset.size();
    std::vector<E::Vector> input;
    for(unsigned copy=0;copy<129;++copy) {
        const auto firstNode=batch.x.size(),firstBond=batch.bonds.size();
        for(auto p:asset.x){p.x+=16*copy;batch.x.push_back(p);}
        for(auto e:asset.bonds){e.first+=firstNode;e.second+=firstNode;e.point[0]+=16*copy;batch.bonds.push_back(e);}
        for(unsigned i=0;i<asset.x.size();++i){batch.fixed.push_back(asset.fixed[i]);batch.starts.push_back(batch.refs.size());
            for(unsigned j=asset.starts[i];j<asset.starts[i+1];++j)batch.refs.push_back(firstBond+asset.refs[j]);
            E::Vector v{};for(unsigned k=0;k<6;++k)v.v[k]=std::sin((6*i+k)*.1+copy);input.push_back(v);}
    }
    batch.starts.push_back(batch.refs.size());Uploaded d(batch);require(!d.validate(),"replicated graph validation");
    Device<E::Vector> x(batch.x.size()),y(batch.x.size());x.put(input);
    E::apply<<<(d.graph.nodes+127)/128,128>>>(d.graph,x.p,y.p,d.error.p);const auto output=y.get();
    for(unsigned copy=0;copy<129;++copy)for(unsigned row=0;row<width;++row) {
        double expected=0;if(!asset.fixed[row/6])for(unsigned j=0;j<width;++j)if(!asset.fixed[j/6])expected+=a[row*width+j]*input[copy*asset.x.size()+j/6].v[j%6];
        near(output[copy*asset.x.size()+row/6].v[row%6],expected,"replicated multi-block operator");
    }
}
void invalidFixtures() {
    auto reject=[](Fixture f,uint32_t error){Uploaded d(f);require(d.validate()&error,"invalid input accepted");};
    Fixture isolated;for(auto& b:isolated.bonds)b.live=0;Uploaded disconnected(isolated);require(!disconnected.validate(),"deleted graph validation");
    Device<E::Matrix> diagonal(isolated.x.size()),factors(isolated.x.size());
    E::buildDiagonal<<<1,128>>>(disconnected.graph,diagonal.p,factors.p,disconnected.limits,disconnected.error.p,disconnected.numerical.p);
    require(disconnected.numerical.get()[0]&E::SingularDiagonal,"singular diagonal accepted");
    Fixture f;f.bonds[0].stiffness.v[0]=-1;reject(f,E::InvalidStiffness);
    f=Fixture{};f.bonds[0].stiffness.v[1]+=1;reject(f,E::InvalidStiffness);
    f=Fixture{};f.bonds[0].frame[0]=2;reject(f,E::InvalidFrame);
    f=Fixture{};for(unsigned i=0;i<3;++i)f.bonds[0].frame[3*i]*=-1;reject(f,E::InvalidFrame);
    f=Fixture{};f.bonds[0].point[0]=NAN;reject(f,E::InvalidValue);
    f=Fixture{};f.refs[0]=999;reject(f,E::InvalidGraph);
    f=Fixture{};f.refs[1]=f.refs[0];reject(f,E::InvalidGraph);
    f=Fixture{};f.bonds[0].second=f.bonds[0].first;reject(f,E::InvalidGraph);
}
int main(){try {
    exercise(Fixture{});Fixture f;f.fixed.assign(f.x.size(),0);exercise(f);
    f=Fixture{};f.bonds.back().live=0;exercise(f);
    f=Fixture{};f.fixed.assign(f.x.size(),1);exercise(f);
    analyticalChannels();replicatedRows();invalidFixtures();check(cudaGetLastError());check(cudaDeviceSynchronize());
    std::cout<<"PASS: six-channel GPU gather, full coupled stiffness, prescribed/inelastic RHS, diagonal solve, response/energy, deletion, force/moment balance, six rigid modes, 129 replicated components, rejected invalid inputs\n";
}catch(const std::exception& e){std::cerr<<e.what()<<'\n';return 1;}}
