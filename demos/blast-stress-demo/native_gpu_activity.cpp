#include "native_gpu_activity.h"
#include <atomic>
#include <cstdlib>
#include <ctime>
#include <stdexcept>
#include <sys/syscall.h>
#include <unistd.h>
#ifdef NATIVE_GPU_CUPTI
#include <cupti_activity.h>
#include <cupti_callbacks.h>
#include <cupti_result.h>
#include <cupti_version.h>
#include <zlib.h>
#include <fstream>
#include <mutex>
#include <unordered_map>
#endif
namespace blast_demo {
namespace {
std::atomic<bool> tracing{false};
uint64_t clockNs(clockid_t clock){timespec t{};if(clock_gettime(clock,&t))throw std::runtime_error("profile clock failed");return uint64_t(t.tv_sec)*1000000000+t.tv_nsec;}
}
uint64_t nativeProfileTimestamp(){
#ifdef NATIVE_GPU_CUPTI
    if(tracing){uint64_t t=0;if(cuptiGetTimestamp(&t)!=CUPTI_SUCCESS)throw std::runtime_error("CUPTI timestamp failed");return t;}
#endif
    return clockNs(CLOCK_MONOTONIC);
}
uint64_t nativeThreadCpuNs(){return clockNs(CLOCK_THREAD_CPUTIME_ID);}
uint64_t nativeProcessCpuNs(){return clockNs(CLOCK_PROCESS_CPUTIME_ID);}
uint32_t nativeThreadId(){return uint32_t(syscall(SYS_gettid));}
#ifdef NATIVE_GPU_CUPTI
namespace {
void check(CUptiResult r){if(r!=CUPTI_SUCCESS){const char* s=nullptr;cuptiGetResultString(r,&s);throw std::runtime_error(std::string("CUPTI: ")+(s?s:"unknown error"));}}
#if CUPTI_API_VERSION >= 130200
using NativeKernelActivity = CUpti_ActivityKernel11;
#elif CUPTI_API_VERSION >= 130000
using NativeKernelActivity = CUpti_ActivityKernel10;
#else
using NativeKernelActivity = CUpti_ActivityKernel9;
#endif
constexpr CUpti_ActivityKind kinds[]={CUPTI_ACTIVITY_KIND_CONCURRENT_KERNEL,CUPTI_ACTIVITY_KIND_MEMCPY,CUPTI_ACTIVITY_KIND_MEMSET,CUPTI_ACTIVITY_KIND_DRIVER,CUPTI_ACTIVITY_KIND_RUNTIME};
}
struct NativeGpuActivity::Impl {
    static std::atomic<Impl*> current;
    gzFile file=nullptr;
    std::ofstream names;
    std::string directory;
    std::mutex mutex;
    std::unordered_map<std::string,unsigned> nameIds;
    std::atomic<bool> failed{false};
    uint64_t dropped=0,records=0,invalid=0;
    bool finished=false;
    uint32_t runtimeVersion=0;
    size_t graphBufferBytes=0;
    unsigned enabled=0;
    CUpti_SubscriberHandle subscriber{};
    static void CUPTIAPI callback(void*,CUpti_CallbackDomain,CUpti_CallbackId,const void*){}
    static void CUPTIAPI request(uint8_t** buffer,size_t* size,size_t* maxRecords){
        *size=4*1024*1024;*buffer=static_cast<uint8_t*>(std::malloc(*size));*maxRecords=0;
        if(!*buffer){*size=0;if(auto* self=current.load())self->failed=true;}
    }
    unsigned id(const char* name){
        auto entry=nameIds.emplace(name?name:"unknown",unsigned(nameIds.size()));
        if(entry.second)names<<entry.first->second<<'\t'<<entry.first->first<<'\n';
        return entry.first->second;
    }
    void row(char kind,uint64_t start,uint64_t end,uint64_t bytes,unsigned name,unsigned thread,unsigned stream,unsigned correlation){
        if(!start || end<start){++invalid;return;}
        if(gzprintf(file,"%c,%llu,%llu,%llu,%u,%u,%u,%u\n",kind,(unsigned long long)start,(unsigned long long)end,(unsigned long long)bytes,name,thread,stream,correlation)<=0)failed=true;
        ++records;
    }
    static void CUPTIAPI complete(CUcontext context,uint32_t stream,uint8_t* buffer,size_t,size_t valid){
        auto* self=current.load();
        if(!self){std::free(buffer);return;}
        try {
            std::lock_guard<std::mutex> lock(self->mutex);
            CUpti_Activity* record=nullptr;CUptiResult result;
            while((result=cuptiActivityGetNextRecord(buffer,valid,&record))==CUPTI_SUCCESS){
                if(record->kind==CUPTI_ACTIVITY_KIND_CONCURRENT_KERNEL){auto& r=*reinterpret_cast<NativeKernelActivity*>(record);self->row('K',r.start,r.end,0,self->id(r.name),0,r.streamId,r.correlationId);}
                else if(record->kind==CUPTI_ACTIVITY_KIND_MEMCPY){auto& r=*reinterpret_cast<CUpti_ActivityMemcpy6*>(record);const auto name="memcpy_kind_"+std::to_string(r.copyKind);self->row('C',r.start,r.end,r.bytes,self->id(name.c_str()),0,r.streamId,r.correlationId);}
                else if(record->kind==CUPTI_ACTIVITY_KIND_MEMSET){auto& r=*reinterpret_cast<CUpti_ActivityMemset4*>(record);self->row('M',r.start,r.end,r.bytes,self->id("memset"),0,r.streamId,r.correlationId);}
                else if((record->kind==CUPTI_ACTIVITY_KIND_DRIVER || record->kind==CUPTI_ACTIVITY_KIND_RUNTIME)){auto& r=*reinterpret_cast<CUpti_ActivityAPI*>(record);const char* name=nullptr;check(cuptiGetCallbackName(record->kind==CUPTI_ACTIVITY_KIND_DRIVER?CUPTI_CB_DOMAIN_DRIVER_API:CUPTI_CB_DOMAIN_RUNTIME_API,r.cbid,&name));self->row('A',r.start,r.end,0,self->id(name),r.threadId,0,r.correlationId);}
            }
            if(result!=CUPTI_ERROR_MAX_LIMIT_REACHED)self->failed=true;
            size_t dropped=0;check(cuptiActivityGetNumDroppedRecords(context,stream,&dropped));self->dropped+=dropped;
        }catch(...){self->failed=true;}
        std::free(buffer);
    }
    explicit Impl(const std::string& dir,uint64_t requestedBytes):directory(dir){
#if CUPTI_API_VERSION < 130202
        throw std::runtime_error("Full conditional-graph capture requires qualified CUPTI 13.2 Update 2 or newer headers; set NATIVE_GPU_CUPTI_ROOT");
#endif
        if(requestedBytes<16ull*1024*1024 || requestedBytes>4096ull*1024*1024)throw std::runtime_error("CUPTI graph buffer must be 16..4096 MiB");
        if(current)throw std::runtime_error("only one CUPTI collector is supported");
        file=gzopen((dir+"/native.activity.csv.gz").c_str(),"wb1");if(!file)throw std::runtime_error("cannot open activity trace");
        names.open(dir+"/native.activity.names.tsv");if(!names)throw std::runtime_error("cannot open activity names");
        gzputs(file,"kind,start_ns,end_ns,bytes,name_id,thread,stream,correlation\n");
        current=this;
        try {
            check(cuptiSubscribe(&subscriber,callback,this));
#if CUPTI_API_VERSION >= 130200
            check(cuptiGetVersion(&runtimeVersion));
            if(runtimeVersion!=CUPTI_API_VERSION)throw std::runtime_error("CUPTI header/library version mismatch; refusing activity record decoding");
            graphBufferBytes=static_cast<size_t>(requestedBytes);size_t attributeBytes=sizeof(graphBufferBytes);
            // Conditional-loop records can outgrow CUPTI's default device-graph
            // buffer. Configure before CUDA/context creation; host flushes do not
            // substitute for this capacity. Overflow remains an explicit failure.
            check(cuptiActivitySetAttribute(CUPTI_ACTIVITY_ATTR_DEVICE_BUFFER_SIZE_DEVICE_GRAPHS,&attributeBytes,&graphBufferBytes));
            size_t actual=0;attributeBytes=sizeof(actual);
            check(cuptiActivityGetAttribute(CUPTI_ACTIVITY_ATTR_DEVICE_BUFFER_SIZE_DEVICE_GRAPHS,&attributeBytes,&actual));
            if(actual!=graphBufferBytes)throw std::runtime_error("CUPTI did not apply requested device-graph buffer capacity");
#endif
            check(cuptiSetThreadIdType(CUPTI_ACTIVITY_THREAD_ID_TYPE_SYSTEM));
            check(cuptiActivityRegisterCallbacks(request,complete));
            for(auto kind:kinds){check(cuptiActivityEnable(kind));++enabled;}
            tracing=true;
        }catch(...){for(unsigned i=0;i<enabled;++i)cuptiActivityDisable(kinds[i]);cuptiActivityFlushAll(CUPTI_ACTIVITY_FLAG_FLUSH_FORCED);current=nullptr;if(subscriber)cuptiUnsubscribe(subscriber);gzclose(file);file=nullptr;throw;}
    }
    void finish(){
        if(finished)return;
        // Caller has completed the scene and consumer; flush only after that boundary.
        for(unsigned i=0;i<enabled;++i)check(cuptiActivityDisable(kinds[i]));
        check(cuptiActivityFlushAll(CUPTI_ACTIVITY_FLAG_FLUSH_FORCED));
        check(cuptiUnsubscribe(subscriber));
        tracing=false;current=nullptr;finished=true;
        if(gzclose(file)!=Z_OK)failed=true;file=nullptr;names.close();if(!names)failed=true;
        std::ofstream status(directory+"/native.activity.status.json");
        status<<"{\"schema\":2,\"cupti_header_version\":"<<CUPTI_API_VERSION<<",\"cupti_runtime_version\":"<<runtimeVersion<<",\"device_graph_buffer_bytes\":"<<graphBufferBytes<<",\"complete\":"<<(!failed && !dropped && !invalid && records?"true":"false")<<",\"records\":"<<records<<",\"dropped\":"<<dropped<<",\"invalid_timestamps\":"<<invalid<<",\"concurrent_kernel_tracing\":true,\"runtime_and_driver_api\":true,\"clock\":\"CUPTI nanoseconds\"}\n";
        status.close();if(!status || failed || dropped || invalid || !records)throw std::runtime_error("incomplete CUPTI activity capture; see status; if records were dropped, retry the entire run with a larger --gpu-trace-buffer-mb (never accept a truncated trace)");
    }
    ~Impl(){if(!finished){try{finish();}catch(...){}}}
};
std::atomic<NativeGpuActivity::Impl*> NativeGpuActivity::Impl::current{nullptr};
#else
struct NativeGpuActivity::Impl {};
#endif
NativeGpuActivity::NativeGpuActivity(const std::string& directory,uint64_t graphBufferBytes){if(directory.empty())return;
#ifdef NATIVE_GPU_CUPTI
    m.reset(new Impl(directory,graphBufferBytes));
#else
    throw std::runtime_error("--profile-gpu requires configuring NATIVE_GPU_CUPTI=ON with CUDA CUPTI and zlib");
#endif
}
NativeGpuActivity::~NativeGpuActivity()=default;
void NativeGpuActivity::finish(){
#ifdef NATIVE_GPU_CUPTI
    if(m)m->finish();
#endif
}
}
