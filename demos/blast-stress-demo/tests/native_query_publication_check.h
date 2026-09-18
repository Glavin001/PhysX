// Audit query observation boundaries while the existing sleep/impact fixture
// validates raycasts, sweeps, overlaps, ownership and CPU/GPU motion.
class QueryPublicationAudit final : public PxProfilerCallback {
    Sc::Scene& scene;
    bool enabled;
    std::atomic<unsigned> publications{0}, queued{0};
    std::atomic<bool> rejectedPublication{false};
public:
    QueryPublicationAudit(Sc::Scene& s,bool use):scene(s),enabled(use) {
        if(enabled){require(!PxGetProfilerCallback(),"query audit needs unused profiler");PxSetProfilerCallback(this);}
    }
    ~QueryPublicationAudit()override{if(enabled)PxSetProfilerCallback(nullptr);}
    void begin(){publications=0;}
    void verify(){if(enabled)require(publications<=1&&!rejectedPublication,"query membership published before acceptance or more than once");}
    void exercised(){if(enabled)require(queued>0,"fixture never queued provisional query transitions");}
    void* zoneStart(const char* name,bool,uint64_t)override {
        if(!std::strcmp(name,"GpuDestruction.task.queryMembershipQueue"))++queued;
        if(!std::strcmp(name,"GpuDestruction.task.queryMembership")) {
            ++publications;
            if(!scene.isSimulationResultAccepted())rejectedPublication=true;
        }
        return nullptr;
    }
    void zoneEnd(void*,const char*,bool,uint64_t)override{}
    void recordData(float,const char*,uint64_t)override{}
};
