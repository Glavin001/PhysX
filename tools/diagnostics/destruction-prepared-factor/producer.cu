// Exercise the same immutable producer on complete saved native worlds.
// The independent checker compares all coefficients with separately assembled
// current operators; these are preparation timings, not application ticks.
#include "PreparedOperator.cuh"
#include "PreparedCoefficientProducer.cuh"
#include <chrono>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <algorithm>
using namespace PreparedStress;
struct CaptureNode { float weights[2], rhs[6], residual[6], threshold; unsigned component; };
struct CaptureBond { unsigned first,second; float offset0[3],offset1[3],health,scale,warm[6]; };
static_assert(sizeof(CaptureNode)==64 && sizeof(CaptureBond)==64,"capture ABI");
template<class T> std::vector<T> load(const std::string& path) {
    std::ifstream f(path,std::ios::binary|std::ios::ate);
    if(!f || size_t(f.tellg())%sizeof(T))throw std::runtime_error("capture size: "+path);
    std::vector<T> values(size_t(f.tellg())/sizeof(T));f.seekg(0);
    f.read(reinterpret_cast<char*>(values.data()),values.size()*sizeof(T));
    if(!f)throw std::runtime_error("capture read: "+path);return values;
}
template<class T> void save(const std::string& path,const std::vector<T>& values) {
    std::ofstream f(path,std::ios::binary);
    f.write(reinterpret_cast<const char*>(values.data()),values.size()*sizeof(T));
    if(!f)throw std::runtime_error("output write: "+path);
}
int main(int argc,char** argv){try{
    if(argc!=5)throw std::runtime_error("parent-prefix current0-prefix current1-prefix output");
    using namespace NativeStressFactors;
    auto start=std::chrono::steady_clock::now();
    auto pn=load<CaptureNode>(std::string(argv[1])+".nodes.bin");
    auto pb=load<CaptureBond>(std::string(argv[1])+".bonds.bin");
    std::vector<Node> nodes;std::vector<Bond> bonds;
    for(auto n:pn)nodes.push_back({n.weights[0],n.weights[1],n.component});
    for(auto b:pb)bonds.push_back({b.first,b.second,{b.offset0[0],b.offset0[1],b.offset0[2]},
        {b.offset1[0],b.offset1[1],b.offset1[2]},b.health,b.scale});
    auto groups=plan(nodes,bonds);
    require(groups.size()==1 && groups[0].members.size()==256,"Expected verified uniform 256-asset fixture");
    const auto& group=groups[0];auto pattern=preparePattern(group);
    std::vector<unsigned> nodeMap,bondMap;
    for(const auto& member:group.members){
        require(member.nodes.size()==pattern.nodeCount && member.bonds.size()==pattern.bondCount,"Member dimensions");
        nodeMap.insert(nodeMap.end(),member.nodes.begin(),member.nodes.end());
        bondMap.insert(bondMap.end(),member.bonds.begin(),member.bonds.end());
    }
    const std::string out=argv[4];save(out+"/pattern.rows.i32",pattern.rowBegin);save(out+"/pattern.cols.i32",pattern.columns);
    const unsigned batch=group.members.size(),entries=pattern.columns.size();
    cudaCheck(cudaSetDevice(0));cudaCheck(cudaFree(nullptr));
    Buffer<int> rowIds(pattern.rowIndices),columns(pattern.columns);
    Buffer<unsigned> termBegin(pattern.termBegin),dn(nodeMap),db(bondMap),dirty(batch);
    Buffer<CoefficientTerm> terms(pattern.terms);
    CoefficientView view{pattern.nodeCount,pattern.bondCount,entries,rowIds.get(),columns.get(),termBegin.get(),terms.get(),dn.get(),db.get()};
    Buffer<double> exact(size_t(batch)*entries);Buffer<float> approximate(size_t(batch)*entries);
    Buffer<float> health(pb.size());Buffer<unsigned> membership(pn.size());Buffer<unsigned char> anchored(pn.size());
    cudaStream_t stream;cudaCheck(cudaStreamCreate(&stream));
    const double setup=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-start).count();
    std::ofstream metrics(out+"/metrics.json");metrics<<std::setprecision(17)<<"{\"scope\":\"GPU coefficient preparation; not native ticks\",\"setup_ms\":"<<setup
        <<",\"immutable_terms\":"<<pattern.terms.size()<<",\"assets\":"<<batch<<",\"epochs\":[";
    std::vector<double> previous(size_t(batch)*entries),result(previous.size());
    std::vector<float> resultFloat(previous.size());
    // Full first state, no-op despite changed inputs, even changed assets,
    // remaining odd assets, then restore all old coefficients.
    for(unsigned epoch=0;epoch<5;++epoch){
        const unsigned state=(epoch==0 || epoch==4)?0:1;
        auto cn=load<CaptureNode>(std::string(argv[2+state])+".nodes.bin");
        auto cb=load<CaptureBond>(std::string(argv[2+state])+".bonds.bin");
        require(cn.size()==pn.size()&&cb.size()==pb.size(),"World dimensions changed");
        std::vector<unsigned> labels(cn.size()),changed(batch,1);std::vector<float> live(cb.size());
        std::vector<unsigned char> supported(cn.size(),0);
        for(size_t i=0;i<cn.size();++i){
            require(cn[i].weights[0]==pn[i].weights[0]&&cn[i].weights[1]==pn[i].weights[1],"Immutable weights changed");
            labels[i]=cn[i].component;require(labels[i]==~0u||labels[i]<cn.size(),"Invalid component label");
        }
        for(size_t i=0;i<cb.size();++i){
            const auto b=cb[i];const auto original=pb[i];
            require(b.first==original.first&&b.second==original.second&&b.scale==original.scale,"Immutable bond changed");
            for(int axis=0;axis<3;++axis)require(b.offset0[axis]==original.offset0[axis]&&b.offset1[axis]==original.offset1[axis],"Immutable offset changed");
            live[i]=b.health;if(b.health<=0 || b.scale==0)continue;
            const auto a=cn[b.first],c=cn[b.second];
            require(a.component==~0u||c.component==~0u||a.component==c.component,"Live bond crosses components");
            if(a.weights[0]==0&&a.weights[1]==0&&c.component!=~0u)supported[c.component]=1;
            if(c.weights[0]==0&&c.weights[1]==0&&a.component!=~0u)supported[a.component]=1;
        }
        for(unsigned asset=0;asset<batch;++asset)
            changed[asset]=epoch==1?0:epoch==2?asset%2==0:epoch==3?asset%2==1:1;
        cudaCheck(cudaMemcpyAsync(health.get(),live.data(),health.bytes(),cudaMemcpyHostToDevice,stream));
        cudaCheck(cudaMemcpyAsync(membership.get(),labels.data(),membership.bytes(),cudaMemcpyHostToDevice,stream));
        cudaCheck(cudaMemcpyAsync(anchored.get(),supported.data(),anchored.bytes(),cudaMemcpyHostToDevice,stream));
        cudaCheck(cudaMemcpyAsync(dirty.get(),changed.data(),dirty.bytes(),cudaMemcpyHostToDevice,stream));
        cudaCheck(cudaStreamSynchronize(stream));
        start=std::chrono::steady_clock::now();
        produceCurrentCoefficients<<<dim3((entries+255)/256,batch),256,0,stream>>>(view,health.get(),membership.get(),anchored.get(),dirty.get(),exact.get(),approximate.get());
        cudaCheck(cudaStreamSynchronize(stream));
        double ms=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-start).count();
        cudaCheck(cudaMemcpy(result.data(),exact.get(),exact.bytes(),cudaMemcpyDeviceToHost));
        cudaCheck(cudaMemcpy(resultFloat.data(),approximate.get(),approximate.bytes(),cudaMemcpyDeviceToHost));
        for(unsigned asset=0;asset<batch;++asset)if(!changed[asset])
            require(std::equal(result.begin()+size_t(asset)*entries,result.begin()+size_t(asset+1)*entries,previous.begin()+size_t(asset)*entries),"Unchanged coefficients written");
        for(size_t i=0;i<result.size();++i)require(resultFloat[i]==float(result[i]),"FP32 projection differs");
        previous=result;save(out+"/epoch-"+std::to_string(epoch)+".values.f64",result);
        if(epoch)metrics<<',';metrics<<"{\"epoch\":"<<epoch<<",\"state\":"<<state<<",\"dirty_assets\":"<<std::count(changed.begin(),changed.end(),1u)<<",\"producer_ms\":"<<ms<<'}';metrics.flush();
    }
    metrics<<"]}\n";cudaCheck(cudaStreamDestroy(stream));return 0;
}catch(const std::exception& error){std::cerr<<error.what()<<'\n';return 1;}}
