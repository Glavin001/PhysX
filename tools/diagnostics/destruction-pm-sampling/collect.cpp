// SPDX-License-Identifier: BSD-3-Clause
// Device-wide CUPTI PM sampling in a separate process. No target injection/replay.
#include <cuda.h>
#include <cupti.h>
#include <cupti_target.h>
#include <cupti_profiler_target.h>
#include <cupti_profiler_host.h>
#include <cupti_pmsampling.h>
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>
#include <thread>
#include <spawn.h>
#include <sys/wait.h>
#include <signal.h>
#include <unistd.h>
extern char** environ;
static volatile sig_atomic_t interrupted=0;
static void interrupt(int signal) {interrupted=signal;}
#define PARAM(type,name) type name{type##_STRUCT_SIZE}
static void check(CUptiResult result,const char* operation) {
    if(result==CUPTI_SUCCESS)return;
    const char* why=nullptr;cuptiGetResultString(result,&why);
    throw std::runtime_error(std::string(operation)+": "+(why?why:"unknown CUPTI error"));
}
#define CUPTI(call) check(call,#call)
static uint64_t now() {
    return std::chrono::duration_cast<std::chrono::nanoseconds>(
        std::chrono::steady_clock::now().time_since_epoch()).count();
}
class Collector {
    CUpti_Profiler_Host_Object* host=nullptr;
    CUpti_PmSampling_Object* target=nullptr;
    std::vector<uint8_t> availability,config,counter;
    std::vector<std::string> names;
    std::vector<const char*> metrics;
    bool active=false;
    uint64_t samples=0,previousEnd=0,invalidTimestamps=0,maxOverlap=0;
    std::ofstream csv,clock;
    void reset() {
        PARAM(CUpti_PmSampling_CounterDataImage_Initialize_Params,p);
        p.pPmSamplingObject=target;p.counterDataSize=counter.size();p.pCounterData=counter.data();
        CUPTI(cuptiPmSamplingCounterDataImageInitialize(&p));
    }
public:
    Collector(const std::filesystem::path& directory,const std::string& list) {
        if(!std::filesystem::create_directory(directory))throw std::runtime_error("output must be a new directory");
        csv.open(directory/"samples.csv");clock.open(directory/"clock.csv");
        csv.exceptions(std::ios::badbit|std::ios::failbit);clock.exceptions(std::ios::badbit|std::ios::failbit);
        clock<<"steady_before_ns,cupti_ns,steady_after_ns\n";
        std::istringstream input(list);std::string name;
        while(std::getline(input,name,',')) {
            if(name.empty() || name.find_first_not_of("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_.")!=std::string::npos)
                throw std::runtime_error("invalid metric name");
            names.push_back(name);
        }
        if(names.empty())throw std::runtime_error("no metrics");
        for(const auto& n:names)metrics.push_back(n.c_str());
        csv<<"sample,start_ns,end_ns,timestamp_valid,overlap_ns";for(const auto& n:names)csv<<','<<n;csv<<'\n'<<std::setprecision(17);
    }
    void initialize(const std::filesystem::path& directory) {
        if(cuInit(0)!=CUDA_SUCCESS)throw std::runtime_error("cuInit failed");
        PARAM(CUpti_Profiler_Initialize_Params,init);CUPTI(cuptiProfilerInitialize(&init));
        PARAM(CUpti_Device_GetChipName_Params,chip);chip.deviceIndex=0;CUPTI(cuptiDeviceGetChipName(&chip));
        PARAM(CUpti_PmSampling_GetCounterAvailability_Params,available);available.deviceIndex=0;
        CUPTI(cuptiPmSamplingGetCounterAvailability(&available));availability.resize(available.counterAvailabilityImageSize);
        available.pCounterAvailabilityImage=availability.data();CUPTI(cuptiPmSamplingGetCounterAvailability(&available));
        PARAM(CUpti_Profiler_Host_Initialize_Params,h);
        h.profilerType=CUPTI_PROFILER_TYPE_PM_SAMPLING;h.pChipName=chip.pChipName;h.pCounterAvailabilityImage=availability.data();
        CUPTI(cuptiProfilerHostInitialize(&h));host=h.pHostObject;
        PARAM(CUpti_Profiler_Host_ConfigAddMetrics_Params,add);
        add.pHostObject=host;add.ppMetricNames=metrics.data();add.numMetrics=metrics.size();CUPTI(cuptiProfilerHostConfigAddMetrics(&add));
        PARAM(CUpti_Profiler_Host_GetConfigImageSize_Params,size);size.pHostObject=host;CUPTI(cuptiProfilerHostGetConfigImageSize(&size));
        config.resize(size.configImageSize);
        PARAM(CUpti_Profiler_Host_GetConfigImage_Params,image);image.pHostObject=host;image.pConfigImage=config.data();image.configImageSize=config.size();
        CUPTI(cuptiProfilerHostGetConfigImage(&image));
        PARAM(CUpti_Profiler_Host_GetNumOfPasses_Params,passes);passes.pConfigImage=config.data();passes.configImageSize=config.size();
        CUPTI(cuptiProfilerHostGetNumOfPasses(&passes));
        if(passes.numOfPasses!=1)throw std::runtime_error("metrics require "+std::to_string(passes.numOfPasses)+" passes; split the metric set");
        std::ofstream cfg(directory/"config.bin",std::ios::binary);cfg.exceptions(std::ios::badbit|std::ios::failbit);
        cfg.write(reinterpret_cast<const char*>(config.data()),config.size());cfg.close();
        PARAM(CUpti_PmSampling_Enable_Params,enable);enable.deviceIndex=0;CUPTI(cuptiPmSamplingEnable(&enable));target=enable.pPmSamplingObject;
        PARAM(CUpti_PmSampling_SetConfig_Params,set);
        set.pPmSamplingObject=target;set.configSize=config.size();set.pConfig=config.data();
        set.hardwareBufferSize=128*1024*1024;set.samplingInterval=100000;
        set.triggerMode=CUPTI_PM_SAMPLING_TRIGGER_MODE_GPU_TIME_INTERVAL;
        CUPTI(cuptiPmSamplingSetConfig(&set));
        PARAM(CUpti_PmSampling_GetCounterDataSize_Params,data);
        data.pPmSamplingObject=target;data.numMetrics=metrics.size();data.pMetricNames=metrics.data();data.maxSamples=5000;
        CUPTI(cuptiPmSamplingGetCounterDataSize(&data));counter.resize(data.counterDataSize);reset();
        std::ofstream meta(directory/"sampling.json");meta.exceptions(std::ios::badbit|std::ios::failbit);
        uint32_t version=0;CUPTI(cuptiGetVersion(&version));
        meta<<"{\"schema\":1,\"device\":0,\"chip\":\""<<chip.pChipName<<"\",\"cupti_version\":"<<version
            <<",\"interval_ns\":100000,\"hardware_buffer_bytes\":134217728,\"max_samples_per_decode\":5000,\"passes\":1,\"scope\":\"device-wide, includes other contexts\",\"first_sample_suspect\":true}\n";
    }
    void stamp() {
        const auto before=now();uint64_t timestamp=0;CUPTI(cuptiGetTimestamp(&timestamp));const auto after=now();
        clock<<before<<','<<timestamp<<','<<after<<'\n';clock.flush();
    }
    void start() {
        stamp();PARAM(CUpti_PmSampling_Start_Params,p);p.pPmSamplingObject=target;
        CUPTI(cuptiPmSamplingStart(&p));active=true;
    }
    void stop() {
        PARAM(CUpti_PmSampling_Stop_Params,p);p.pPmSamplingObject=target;
        CUPTI(cuptiPmSamplingStop(&p));active=false;stamp();
    }
    bool decode() {
        PARAM(CUpti_PmSampling_DecodeData_Params,d);
        d.pPmSamplingObject=target;d.pCounterDataImage=counter.data();d.counterDataImageSize=counter.size();
        CUPTI(cuptiPmSamplingDecodeData(&d));if(d.overflow)throw std::runtime_error("hardware sample buffer overflow");
        PARAM(CUpti_PmSampling_GetCounterDataInfo_Params,info);
        info.pCounterDataImage=counter.data();info.counterDataImageSize=counter.size();CUPTI(cuptiPmSamplingGetCounterDataInfo(&info));
        for(size_t i=0;i<info.numCompletedSamples;++i) {
            PARAM(CUpti_PmSampling_CounterData_GetSampleInfo_Params,t);
            t.pPmSamplingObject=target;t.pCounterDataImage=counter.data();t.counterDataImageSize=counter.size();t.sampleIndex=i;
            CUPTI(cuptiPmSamplingCounterDataGetSampleInfo(&t));
            const uint64_t overlap=samples && t.startTimestamp<previousEnd?previousEnd-t.startTimestamp:0;
            const bool valid=samples && t.endTimestamp>t.startTimestamp && !overlap;
            if(!valid)++invalidTimestamps;maxOverlap=std::max(maxOverlap,overlap);
            std::vector<double> values(metrics.size());
            PARAM(CUpti_Profiler_Host_EvaluateToGpuValues_Params,e);
            e.pHostObject=host;e.pCounterDataImage=counter.data();e.counterDataImageSize=counter.size();e.ppMetricNames=metrics.data();
            e.numMetrics=metrics.size();e.rangeIndex=i;e.pMetricValues=values.data();CUPTI(cuptiProfilerHostEvaluateToGpuValues(&e));
            csv<<samples++<<','<<t.startTimestamp<<','<<t.endTimestamp<<','<<valid<<','<<overlap;for(auto value:values)csv<<','<<value;csv<<'\n';previousEnd=t.endTimestamp;
        }
        csv.flush();reset();return d.decodeStopReason==CUPTI_PM_SAMPLING_DECODE_STOP_REASON_END_OF_RECORDS;
    }
    void finish(int code,const std::filesystem::path& directory) {
        if(!samples)throw std::runtime_error("no counter samples");
        std::ofstream result(directory/"result.json");result.exceptions(std::ios::badbit|std::ios::failbit);
        result<<"{\"samples\":"<<samples<<",\"child_exit_code\":"<<code<<",\"invalid_timestamp_samples\":"<<invalidTimestamps<<",\"max_overlap_ns\":"<<maxOverlap<<",\"overflow\":false,\"final_drain_complete\":true}\n";
    }
    ~Collector() {
        if(active){PARAM(CUpti_PmSampling_Stop_Params,p);p.pPmSamplingObject=target;cuptiPmSamplingStop(&p);}
        if(target){PARAM(CUpti_PmSampling_Disable_Params,p);p.pPmSamplingObject=target;cuptiPmSamplingDisable(&p);}
        if(host){PARAM(CUpti_Profiler_Host_Deinitialize_Params,p);p.pHostObject=host;cuptiProfilerHostDeinitialize(&p);}
        PARAM(CUpti_Profiler_DeInitialize_Params,p);cuptiProfilerDeInitialize(&p);
    }
};
int main(int argc,char** argv) {
    pid_t child=-1;
    signal(SIGINT,interrupt);signal(SIGTERM,interrupt);
    try {
        if(argc<5 || std::string(argv[3])!="--")throw std::runtime_error("usage: collect NEW_OUTPUT METRIC,LIST -- PROGRAM ARGS...");
        const std::filesystem::path directory(argv[1]);Collector sampler(directory,argv[2]);sampler.initialize(directory);sampler.start();
        posix_spawnattr_t attributes;
        if(posix_spawnattr_init(&attributes))throw std::runtime_error("spawn attributes failed");
        const int group=posix_spawnattr_setpgroup(&attributes,0);
        const int flags=posix_spawnattr_setflags(&attributes,POSIX_SPAWN_SETPGROUP);
        if(group || flags){posix_spawnattr_destroy(&attributes);throw std::runtime_error("spawn group failed");}
        const int spawned=posix_spawnp(&child,argv[4],nullptr,&attributes,argv+4,environ);
        posix_spawnattr_destroy(&attributes);
        if(spawned){child=-1;throw std::runtime_error("posix_spawn failed: "+std::to_string(spawned));}
        const auto start=now();int status=0;
        for(;;) {
            if(interrupted)throw std::runtime_error("sampling interrupted");
            sampler.decode();const auto found=waitpid(child,&status,WNOHANG);
            if(found==child){child=-1;break;}
            if(found<0)throw std::runtime_error("waitpid failed");
            if(now()-start>120000000000ull)throw std::runtime_error("target exceeded 120-second diagnostic watchdog");
            std::this_thread::sleep_for(std::chrono::milliseconds(10));
        }
        sampler.stop();bool drained=false;
        for(unsigned i=0;i<1000 && !drained;++i)drained=sampler.decode();
        if(!drained)throw std::runtime_error("final counter drain incomplete");
        const int code=WIFEXITED(status)?WEXITSTATUS(status):128+WTERMSIG(status);sampler.finish(code,directory);return code;
    }catch(const std::exception& e) {
        if(child>0){kill(-child,SIGKILL);waitpid(child,nullptr,0);}
        std::fprintf(stderr,"PM sampling failed: %s\n",e.what());return 1;
    }
}
