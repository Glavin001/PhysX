#include "extensions/stressphysx/NvBlastExtStressPhysXGpuActivity.h"
#include <extensions/PxCudaHelpersExt.h>
#include <limits>
#include <new>
#include <algorithm>
#include <vector>

namespace Nv { namespace Blast {
using namespace physx;
using physx::Ext::PxCudaHelpersExt;

bool ExtStressPhysXGpuActivity::configureScene(PxSceneDesc& desc)
{
#if defined(PX_DIRECT_GPU_SLEEPING_VERSION) && PX_SUPPORT_GPU_PHYSX
    PxSceneDesc candidate = desc;
    candidate.flags |= PxSceneFlag::eENABLE_DIRECT_GPU_API | PxSceneFlag::eENABLE_DIRECT_GPU_SLEEPING;
    candidate.flags &= ~PxSceneFlags(PxSceneFlag::eDISABLE_SLEEPING);
    if (!candidate.isValid()) return false;
    desc = candidate;
    return true;
#else
    (void)desc;
    return false;
#endif
}
namespace {
bool activityAvailable(PxScene& scene)
{
#if defined(PX_DIRECT_GPU_SLEEPING_VERSION) && PX_SUPPORT_GPU_PHYSX
    const auto flags = scene.getFlags();
    return scene.getCudaContextManager() && flags.isSet(PxSceneFlag::eENABLE_DIRECT_GPU_API)
        && flags.isSet(PxSceneFlag::eENABLE_DIRECT_GPU_SLEEPING)
        && !flags.isSet(PxSceneFlag::eDISABLE_SLEEPING);
#else
    (void)scene;
    return false;
#endif
}
class Activity final : public ExtStressPhysXGpuActivity
{
    PxScene& m_scene;
    PxCudaContextManager* m_cuda;
    PxRigidDynamicGPUIndex* m_indices = nullptr;
    uint32_t m_capacity = 0;
#if PX_SUPPORT_GPU_PHYSX
    CUstream m_uploadStream = nullptr;
    CUevent m_copyReady = nullptr, m_writeReady = nullptr;
#endif
    std::vector<PxRigidDynamicGPUIndex> m_hostIndices;
    std::vector<PxRigidDynamicGPUIndex> m_sortedIndices;
public:
    explicit Activity(PxScene& scene) : m_scene(scene), m_cuda(scene.getCudaContextManager()) {}
    bool available() const override { return activityAvailable(m_scene); }
    void release() override
    {
#if PX_SUPPORT_GPU_PHYSX
        if(m_cuda) {
            PxScopedCudaLock lock(*m_cuda);
            auto* cuda=m_cuda->getCudaContext();
            if(m_uploadStream)cuda->streamSynchronize(m_uploadStream);
            if(m_copyReady)cuda->eventDestroy(m_copyReady);
            if(m_writeReady)cuda->eventDestroy(m_writeReady);
            if(m_uploadStream)cuda->streamDestroy(m_uploadStream);
        }
        if (m_indices) PxCudaHelpersExt::freeDeviceBuffer(*m_cuda, m_indices);
#endif
        delete this;
    }
    bool write(PxRigidDynamic* const* bodies, uint32_t count, const void* values,
               PxRigidDynamicGPUAPIWriteType::Enum type, void* ready) override
    {
#if PX_SUPPORT_GPU_PHYSX
        if (!available() || !bodies || !count || !values) return false;
        switch (type)
        {
        case PxRigidDynamicGPUAPIWriteType::eGLOBAL_POSE:
        case PxRigidDynamicGPUAPIWriteType::eLINEAR_VELOCITY:
        case PxRigidDynamicGPUAPIWriteType::eANGULAR_VELOCITY:
        case PxRigidDynamicGPUAPIWriteType::eFORCE:
        case PxRigidDynamicGPUAPIWriteType::eTORQUE:
            break;
        default: return false;
        }
        m_hostIndices.clear();
        m_hostIndices.reserve(count);
        for (uint32_t i = 0; i < count; ++i)
        {
            auto* body = bodies[i];
            if (!body || body->getScene() != &m_scene
                || body->getRigidBodyFlags().isSet(PxRigidBodyFlag::eKINEMATIC)) return false;
            const auto index = body->getGPUIndex();
            if (index == std::numeric_limits<PxRigidDynamicGPUIndex>::max()) return false;
            m_hostIndices.push_back(index);
        }
        m_sortedIndices.assign(m_hostIndices.begin(), m_hostIndices.end());
        std::sort(m_sortedIndices.begin(), m_sortedIndices.end());
        if (std::adjacent_find(m_sortedIndices.begin(), m_sortedIndices.end()) != m_sortedIndices.end())
            return false;
        if (count > m_capacity)
        {
            auto* next = PxCudaHelpersExt::allocDeviceBuffer<PxRigidDynamicGPUIndex>(*m_cuda, count);
            if (!next) return false;
            PxCudaHelpersExt::freeDeviceBuffer(*m_cuda, m_indices);
            m_indices = next;
            m_capacity = count;
        }
        {
            PxScopedCudaLock lock(*m_cuda);
            auto* cuda=m_cuda->getCudaContext();
            if((!m_uploadStream && cuda->streamCreate(&m_uploadStream,1u)!=0)
                || (!m_copyReady && cuda->eventCreate(&m_copyReady,2u)!=0)
                || (!m_writeReady && cuda->eventCreate(&m_writeReady,2u)!=0))return false;
            // Pageable HtoD can return after staging. Join its default-stream
            // completion with the caller's values producer before the write.
            if(cuda->memcpyHtoD(reinterpret_cast<CUdeviceptr>(m_indices),
                m_hostIndices.data(),size_t(count)*sizeof(*m_indices))!=0
                || cuda->eventRecord(m_copyReady,nullptr)!=0
                || cuda->streamWaitEvent(m_uploadStream,m_copyReady,0)!=0
                || (ready && cuda->streamWaitEvent(m_uploadStream,reinterpret_cast<CUevent>(ready),0)!=0)
                || cuda->eventRecord(m_writeReady,m_uploadStream)!=0)return false;
        }
        // CPU island activation must precede the next solve. The Direct GPU
        // metadata upload preserves current device pose, velocity and forces.
        for (uint32_t i = 0; i < count; ++i) bodies[i]->wakeUp();
        return m_scene.getDirectGPUAPI().setRigidDynamicData(values, m_indices, type,
            count, m_writeReady);
#else
        (void)bodies; (void)count; (void)values; (void)type; (void)ready;
        return false;
#endif
    }
};
}
ExtStressPhysXGpuActivity* ExtStressPhysXGpuActivity::create(PxScene& scene)
{
    return new (std::nothrow) Activity(scene);
}
}} // namespace Nv::Blast
