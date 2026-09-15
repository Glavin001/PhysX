// Native captured-equation feasibility probe. Not a simulation benchmark.
#include <cuda_runtime.h>
#include <cudss.h>
#include <chrono>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>
using Clock=std::chrono::steady_clock;
void ck(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}
void dsCheck(cudssStatus_t e,const char* call,int line){if(e!=CUDSS_STATUS_SUCCESS)throw std::runtime_error("cuDSS status "+std::to_string(int(e))+" at line "+std::to_string(line)+": "+call);}
#define ds(call) dsCheck((call),#call,__LINE__)
template<class T>std::vector<T> read(const std::string& p,size_t n){std::ifstream f(p,std::ios::binary|std::ios::ate);if(!f||size_t(f.tellg())!=n*sizeof(T))throw std::runtime_error("Input length: "+p);std::vector<T> v(n);f.seekg(0);f.read(reinterpret_cast<char*>(v.data()),n*sizeof(T));if(!f)throw std::runtime_error("Input read failed");return v;}
template<class T>T* alloc(size_t n){T* p=nullptr;ck(cudaMalloc(&p,n*sizeof(T)));return p;}
int main(int argc,char** argv){try{
 if(argc!=6 && argc!=7)throw std::runtime_error("prefix n nnz nrhs output-prefix [fresh-operator-repeats]");
 const int freshRepeats=argc==7?std::stoi(argv[6]):0;
 if(freshRepeats<0 || freshRepeats>1000)throw std::runtime_error("Invalid fresh-operator repeat count");
 const std::string in=argv[1],out=argv[5];const int n=std::stoi(argv[2]),nnz=std::stoi(argv[3]),nrhs=std::stoi(argv[4]);if(n<=0||nnz<=0||nrhs<=0)throw std::runtime_error("Invalid dimensions");
 auto rows=read<int>(in+".rows.i32",n+1),cols=read<int>(in+".cols.i32",nnz);auto vals=read<double>(in+".values.f64",nnz),rhs=read<double>(in+".rhs.f64",size_t(n)*nrhs);
 auto start=Clock::now();ck(cudaSetDevice(0));ck(cudaFree(nullptr));cudaStream_t stream;ck(cudaStreamCreate(&stream));
 cudssHandle_t h;ds(cudssCreate(&h));ds(cudssSetStream(h,stream));cudssConfig_t cfg;ds(cudssConfigCreate(&cfg));cudssData_t data;ds(cudssDataCreate(h,&data));// cuDSS deterministic mode supports single RHS only. This multi-RHS diagnostic
 // measures default mode and independently checks first/final numerical output.
 int deterministic=0;ds(cudssConfigSet(cfg,CUDSS_CONFIG_DETERMINISTIC_MODE,&deterministic,sizeof(deterministic)));
 const double setup=std::chrono::duration<double,std::milli>(Clock::now()-start).count();
 auto allocationStart=Clock::now();
 auto* dr=alloc<int>(n+1);auto* dc=alloc<int>(nnz);auto* dv=alloc<double>(nnz);auto* db=alloc<double>(size_t(n)*nrhs);auto* dx=alloc<double>(size_t(n)*nrhs);
 const double allocation=std::chrono::duration<double,std::milli>(Clock::now()-allocationStart).count();
 auto timed=[&](auto fn){auto t=Clock::now();fn();ck(cudaStreamSynchronize(stream));return std::chrono::duration<double,std::milli>(Clock::now()-t).count();};
 const double upload=timed([&]{ck(cudaMemcpyAsync(dr,rows.data(),rows.size()*sizeof(int),cudaMemcpyHostToDevice,stream));ck(cudaMemcpyAsync(dc,cols.data(),cols.size()*sizeof(int),cudaMemcpyHostToDevice,stream));ck(cudaMemcpyAsync(dv,vals.data(),vals.size()*sizeof(double),cudaMemcpyHostToDevice,stream));ck(cudaMemcpyAsync(db,rhs.data(),rhs.size()*sizeof(double),cudaMemcpyHostToDevice,stream));});
 auto wrapperStart=Clock::now();
 cudssMatrix_t A,B,X;ds(cudssMatrixCreateCsr(&A,n,n,nnz,dr,nullptr,dc,dv,CUDSS_R_32I,CUDSS_R_32I,CUDSS_R_64F,CUDSS_MTYPE_SPD,CUDSS_MVIEW_FULL,CUDSS_BASE_ZERO));ds(cudssMatrixCreateDn(&B,n,nrhs,n,db,CUDSS_R_64F,CUDSS_LAYOUT_COL_MAJOR));ds(cudssMatrixCreateDn(&X,n,nrhs,n,dx,CUDSS_R_64F,CUDSS_LAYOUT_COL_MAJOR));
 const double wrappers=std::chrono::duration<double,std::milli>(Clock::now()-wrapperStart).count();
 auto info=[&]{int v=-1;size_t written=0;ds(cudssDataGet(h,data,CUDSS_DATA_INFO,&v,sizeof(v),&written));if(v!=0)throw std::runtime_error("Solver numerical info "+std::to_string(v));};
 auto phase=[&](int flag){auto t=Clock::now();ds(cudssExecute(h,flag,cfg,data,A,X,B));ck(cudaStreamSynchronize(stream));info();return std::chrono::duration<double,std::milli>(Clock::now()-t).count();};
 const double analysis=phase(CUDSS_PHASE_ANALYSIS),factor=phase(CUDSS_PHASE_FACTORIZATION),firstSolve=phase(CUDSS_PHASE_SOLVE);
 const double firstPipeline=std::chrono::duration<double,std::milli>(Clock::now()-start).count();
 std::vector<double> firstX(size_t(n)*nrhs);ck(cudaMemcpy(firstX.data(),dx,firstX.size()*sizeof(double),cudaMemcpyDeviceToHost));
 std::vector<double> refactor,solve;
 for(int i=0;i<5;++i)refactor.push_back(phase(CUDSS_PHASE_REFACTORIZATION));
 for(int i=0;i<20;++i)solve.push_back(phase(CUDSS_PHASE_SOLVE));
 // Rebuild symbolic/numeric state with library/context already initialized.
 // This measures fresh operator work; no symbolic state or numeric factors survive.
 std::vector<double> freshAnalysis,freshFactor,freshSolve,freshPipeline;
 for(int i=0;i<freshRepeats;++i){
  auto t=Clock::now();ds(cudssDataDestroy(h,data));ds(cudssDataCreate(h,&data));
  freshAnalysis.push_back(phase(CUDSS_PHASE_ANALYSIS));
  freshFactor.push_back(phase(CUDSS_PHASE_FACTORIZATION));
  freshSolve.push_back(phase(CUDSS_PHASE_SOLVE));
  freshPipeline.push_back(std::chrono::duration<double,std::milli>(Clock::now()-t).count());
 }
 std::vector<double> x(size_t(n)*nrhs);const double download=timed([&]{ck(cudaMemcpyAsync(x.data(),dx,x.size()*sizeof(double),cudaMemcpyDeviceToHost,stream));});
 {std::ifstream maps("/proc/self/maps");std::ofstream saved(out+".maps");saved<<maps.rdbuf();}
 ds(cudssMatrixDestroy(A));ds(cudssMatrixDestroy(B));ds(cudssMatrixDestroy(X));ds(cudssDataDestroy(h,data));ds(cudssConfigDestroy(cfg));ds(cudssDestroy(h));ck(cudaFree(dr));ck(cudaFree(dc));ck(cudaFree(dv));ck(cudaFree(db));ck(cudaFree(dx));ck(cudaStreamDestroy(stream));
 std::ofstream firstFile(out+".first-solution.f64",std::ios::binary);firstFile.write(reinterpret_cast<char*>(firstX.data()),firstX.size()*sizeof(double));firstFile.close();if(!firstFile)throw std::runtime_error("First output failure");
 std::ofstream f(out+".solution.f64",std::ios::binary);f.write(reinterpret_cast<char*>(x.data()),x.size()*sizeof(double));f.close();if(!f)throw std::runtime_error("Output failure");
 std::ofstream j(out+".json");j<<std::setprecision(17)<<"{\"status\":\"library_probe_complete_quality_pending\",\"scope\":\"Captured mathematical system only; not native simulation or full-step timing\",\"deterministic\":false,\"n\":"<<n<<",\"nnz\":"<<nnz<<",\"nrhs\":"<<nrhs<<",\"context_handle_setup_ms\":"<<setup<<",\"input_upload_ms\":"<<upload<<",\"analysis_ms\":"<<analysis<<",\"first_factor_ms\":"<<factor<<",\"first_solve_ms\":"<<firstSolve<<",\"output_download_ms\":"<<download;
 j<<",\"device_allocation_ms\":"<<allocation<<",\"matrix_wrapper_setup_ms\":"<<wrappers<<",\"first_pipeline_wall_ms\":"<<firstPipeline;
 auto array=[&](const char* name,const auto& v){j<<",\""<<name<<"\":[";for(size_t i=0;i<v.size();++i){if(i)j<<',';j<<v[i];}j<<']';};array("refactor_ms",refactor);array("reused_solve_ms",solve);array("fresh_analysis_ms",freshAnalysis);array("fresh_factor_ms",freshFactor);array("fresh_solve_ms",freshSolve);array("fresh_operator_pipeline_ms",freshPipeline);j<<"}\n";j.close();if(!j)throw std::runtime_error("JSON output failure");return 0;
 }catch(const std::exception& e){std::cerr<<e.what()<<'\n';return 1;}}
