#include "extensions/stressphysx/NvBlastExtStressPhysXGpuHostMirror.h"
#include <PxDirectGPUAPI.h>
#include <extensions/PxCudaHelpersExt.h>
#include <algorithm>
#include <limits>
#include <new>
#include <vector>

namespace Nv { namespace Blast {
using namespace physx;
using physx::Ext::PxCudaHelpersExt;
namespace {
class Mirror final : public ExtStressPhysXGpuHostMirror
{
    PxScene& m_scene;
    PxCudaContextManager* m_cuda;
    PxU8* m_host = nullptr;
    PxU8* m_device = nullptr;
    CUstream m_stream = nullptr;
    CUevent m_ready = nullptr;
    uint32_t m_capacity = 0;
    std::vector<PxRigidDynamicGPUIndex> m_indices;
    std::vector<uint32_t> m_seen;
    uint32_t m_epoch = 0;
    static constexpr size_t stride = sizeof(PxRigidDynamicGPUIndex) + sizeof(PxTransform) + 2*sizeof(PxVec3);
public:
    explicit Mirror(PxScene& scene) : m_scene(scene), m_cuda(scene.getCudaContextManager()) {}
    bool available() const override
    {
#if defined(PX_DIRECT_GPU_HOST_ACCESS_VERSION) && PX_SUPPORT_GPU_PHYSX
        return m_cuda && m_scene.getFlags().isSet(PxSceneFlag::eENABLE_DIRECT_GPU_HOST_ACCESS);
#else
        return false;
#endif
    }
    void release() override
    {
#if PX_SUPPORT_GPU_PHYSX
        if(m_cuda)
        {
            // Drain before freeing even after a failed asynchronous operation.
            { PxScopedCudaLock lock(*m_cuda);
              auto* cuda = m_cuda->getCudaContext();
              if(m_stream) { cuda->streamSynchronize(m_stream); cuda->streamDestroy(m_stream); }
              if(m_ready) cuda->eventDestroy(m_ready); }
            PxCudaHelpersExt::freeDeviceBuffer(*m_cuda, m_device);
            PxCudaHelpersExt::freePinnedHostBuffer(*m_cuda, m_host);
        }
#endif
        delete this;
    }
    bool synchronize(PxRigidDynamic* const* bodies, uint32_t count) override
    {
#if defined(PX_DIRECT_GPU_HOST_ACCESS_VERSION) && PX_SUPPORT_GPU_PHYSX
        if(!available()) return false;
        if(!count) return true;
        if(!bodies) return false;
        m_indices.clear(); m_indices.reserve(count);
        if(++m_epoch == 0) { std::fill(m_seen.begin(),m_seen.end(),0); ++m_epoch; }
        for(uint32_t i=0; i<count; ++i)
        {
            if(!bodies[i] || bodies[i]->getScene() != &m_scene) return false;
            const auto id = bodies[i]->getGPUIndex();
            if(id == std::numeric_limits<PxRigidDynamicGPUIndex>::max()) return false;
            if(size_t(id)>=m_seen.size()) m_seen.resize(size_t(id)+1,0);
            if(m_seen[id]==m_epoch) return false;
            m_seen[id]=m_epoch;
            m_indices.push_back(id);
        }
        if(!reserve(count)) return false;
        const size_t indicesBytes = size_t(m_capacity)*sizeof(PxRigidDynamicGPUIndex);
        const size_t posesOffset = indicesBytes;
        const size_t linearOffset = posesOffset + size_t(m_capacity)*sizeof(PxTransform);
        const size_t angularOffset = linearOffset + size_t(m_capacity)*sizeof(PxVec3);
        auto* indices = reinterpret_cast<PxRigidDynamicGPUIndex*>(m_device);
        auto* poses = reinterpret_cast<PxTransform*>(m_device+posesOffset);
        auto* linear = reinterpret_cast<PxVec3*>(m_device+linearOffset);
        auto* angular = reinterpret_cast<PxVec3*>(m_device+angularOffset);
        // Upload from pinned storage so the three gathers can share the same
        // dependency event. All later transfers use the same ordered stream.
        std::copy(m_indices.begin(), m_indices.end(), reinterpret_cast<PxRigidDynamicGPUIndex*>(m_host));
        bool uploaded = false;
        {
            PxScopedCudaLock lock(*m_cuda); auto* cuda = m_cuda->getCudaContext();
            uploaded = cuda->memcpyHtoDAsync(reinterpret_cast<CUdeviceptr>(indices), m_host,
                size_t(count)*sizeof(*indices), m_stream) == 0
                && cuda->eventRecord(m_ready, m_stream) == 0;
        }
        if(!uploaded) return drain(false);
        auto& api = m_scene.getDirectGPUAPI();
        // Re-recording ready is safe: each call waits for the prior recording
        // before it records completion on PhysX's ordered stream.
        bool ok = api.getRigidDynamicData(poses, indices,
            PxRigidDynamicGPUAPIReadType::eGLOBAL_POSE, count, m_ready, m_ready);
        ok = api.getRigidDynamicData(linear, indices,
            PxRigidDynamicGPUAPIReadType::eLINEAR_VELOCITY, count, m_ready, m_ready) && ok;
        ok = api.getRigidDynamicData(angular, indices,
            PxRigidDynamicGPUAPIReadType::eANGULAR_VELOCITY, count, m_ready, m_ready) && ok;
        {
            PxScopedCudaLock lock(*m_cuda); auto* cuda = m_cuda->getCudaContext();
            ok = (cuda->streamWaitEvent(m_stream,m_ready,0)==0) && ok;
            ok = (cuda->memcpyDtoHAsync(m_host+posesOffset, reinterpret_cast<CUdeviceptr>(poses),
                size_t(count)*sizeof(*poses),m_stream)==0) && ok;
            ok = (cuda->memcpyDtoHAsync(m_host+linearOffset, reinterpret_cast<CUdeviceptr>(linear),
                size_t(count)*sizeof(*linear),m_stream)==0) && ok;
            ok = (cuda->memcpyDtoHAsync(m_host+angularOffset, reinterpret_cast<CUdeviceptr>(angular),
                size_t(count)*sizeof(*angular),m_stream)==0) && ok;
        }
        if(!drain(ok)) return false;
        return api.publishRigidDynamicHostData(bodies, reinterpret_cast<PxTransform*>(m_host+posesOffset),
            reinterpret_cast<PxVec3*>(m_host+linearOffset), reinterpret_cast<PxVec3*>(m_host+angularOffset), count);
#else
        (void)bodies; (void)count; return false;
#endif
    }
private:
#if PX_SUPPORT_GPU_PHYSX
    bool drain(bool ok)
    {
        PxScopedCudaLock lock(*m_cuda);
        return m_cuda->getCudaContext()->streamSynchronize(m_stream)==0 && ok;
    }
    bool reserve(uint32_t count)
    {
        if(!m_stream || !m_ready)
        {
            PxScopedCudaLock lock(*m_cuda); auto* cuda = m_cuda->getCudaContext();
            if(!m_stream && cuda->streamCreate(&m_stream,1)!=0) return false;
            if(!m_ready && cuda->eventCreate(&m_ready,2)!=0) return false;
        }
        if(count<=m_capacity) return true;
        const uint32_t capacity = count > std::numeric_limits<uint32_t>::max()/2 ? count
            : std::max(count, std::min(std::numeric_limits<uint32_t>::max()/2,m_capacity)*2);
        if(size_t(capacity)>std::numeric_limits<size_t>::max()/stride) return false;
        auto* device = PxCudaHelpersExt::allocDeviceBuffer<PxU8>(*m_cuda,size_t(capacity)*stride);
        auto* host = PxCudaHelpersExt::allocPinnedHostBuffer<PxU8>(*m_cuda,size_t(capacity)*stride);
        if(!device || !host)
        {
            PxCudaHelpersExt::freeDeviceBuffer(*m_cuda,device);
            PxCudaHelpersExt::freePinnedHostBuffer(*m_cuda,host);
            return false;
        }
        PxCudaHelpersExt::freeDeviceBuffer(*m_cuda,m_device);
        PxCudaHelpersExt::freePinnedHostBuffer(*m_cuda,m_host);
        m_device=device; m_host=host; m_capacity=capacity;
        return true;
    }
#endif
};
}
ExtStressPhysXGpuHostMirror* ExtStressPhysXGpuHostMirror::create(PxScene& scene)
{ return new(std::nothrow) Mirror(scene); }
} }
