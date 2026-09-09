// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include <PxDestructionScene.h>
#include <cudamanager/PxCudaContextManager.h>
#include <cuda.h>
#include <zlib.h>
#include <memory>
#include <stdexcept>
#include <string>
#include <vector>
namespace blast_demo {
// Optional diagnostic consumer, outside complete-step timing. Observes the last
// stress evaluation and accepted health; it never submits loads or mutates state.
class NativeStressTrace {
    using File=std::unique_ptr<gzFile_s,decltype(&gzclose)>;
    File mBonds{nullptr,gzclose},mLoads{nullptr,gzclose},mMeta{nullptr,gzclose};
    std::vector<physx::PxDestructionVectorPair> mForces,mAccelerations;
    std::vector<physx::PxDestructionBondVerdict> mVerdicts;
    std::vector<float> mHealth,mRates;
    template<class... Args> static void row(File& file,const char* format,Args... args) {
        if(gzprintf(file.get(),format,args...)<=0)throw std::runtime_error("stress trace write failed");
    }
    template<class T> static void read(std::vector<T>& out,const T* device,unsigned count) {
        out.resize(count);
        if(count && (!device || cuMemcpyDtoH(out.data(),CUdeviceptr(device),sizeof(T)*count)!=CUDA_SUCCESS))
            throw std::runtime_error("stress trace readback failed");
    }
public:
    NativeStressTrace(bool enabled,const std::string& directory) {
        if(!enabled)return;
        mBonds.reset(gzopen((directory+"/native.bonds.csv.gz").c_str(),"wb1"));
        mLoads.reset(gzopen((directory+"/native.loads.csv.gz").c_str(),"wb1"));
        mMeta.reset(gzopen((directory+"/native.stress-meta.csv.gz").c_str(),"wb1"));
        if(!mBonds || !mLoads || !mMeta)throw std::runtime_error("stress trace creation failed");
        row(mBonds,"step,bond,accepted_health,trial_health,damage,normal,shear,bend,command,broken,fx,fy,fz,tx,ty,tz\n");
        row(mLoads,"step,chunk,linear_x,linear_y,linear_z,angular_x,angular_y,angular_z,strain_rate\n");
        row(mMeta,"step,chunks,bonds,topology_generation,solved_generation,iterations,converged,stress_passes,broken_bonds,post_correction_broken_bonds\n");
    }
    void observe(unsigned step,const physx::PxDestructionDeviceView& view,physx::PxCudaContextManager& cuda) {
        if(!mBonds)return;
        physx::PxDestructionStageStatus stage{};physx::PxDestructionStressTopologyStatus topology{};
        {
            physx::PxScopedCudaLock lock(cuda);
            if(cuEventSynchronize(view.readyEvent)!=CUDA_SUCCESS
                || cuMemcpyDtoH(&stage,CUdeviceptr(view.status),sizeof(stage))!=CUDA_SUCCESS
                || cuMemcpyDtoH(&topology,CUdeviceptr(view.stressTopology),sizeof(topology))!=CUDA_SUCCESS)
                throw std::runtime_error("stress trace status/event failed");
            read(mForces,view.bondForces,view.bondCount);read(mVerdicts,view.bondVerdicts,view.bondCount);
            read(mHealth,view.bondHealth,view.bondCount);read(mAccelerations,view.nodeAccelerations,view.chunkCount);
            read(mRates,view.strainRates,view.chunkCount);
        }
        if(stage.frame!=step+1 || stage.error)throw std::runtime_error("stress trace did not observe accepted tick");
        row(mMeta,"%u,%u,%u,%llu,%llu,%u,%u,%u,%u,%u\n",step,view.chunkCount,view.bondCount,
            (unsigned long long)topology.generation,(unsigned long long)topology.solvedGeneration,
            stage.iterations,stage.converged,stage.stressPasses,stage.brokenBonds,stage.postCorrectionBrokenBonds);
        for(unsigned i=0;i<view.bondCount;++i) {
            const auto& v=mVerdicts[i];const auto& f=mForces[i];
            row(mBonds,"%u,%u,%.9g,%.9g,%.9g,%.9g,%.9g,%.9g,%u,%u,%.9g,%.9g,%.9g,%.9g,%.9g,%.9g\n",
                step,i,mHealth[i],v.health,v.damage,v.stressNormal,v.stressShear,v.stressBend,v.command,v.broken,
                f.linear.x,f.linear.y,f.linear.z,f.angular.x,f.angular.y,f.angular.z);
        }
        for(unsigned i=0;i<view.chunkCount;++i) {
            const auto& a=mAccelerations[i];row(mLoads,"%u,%u,%.9g,%.9g,%.9g,%.9g,%.9g,%.9g,%.9g\n",step,i,
                a.linear.x,a.linear.y,a.linear.z,a.angular.x,a.angular.y,a.angular.z,mRates[i]);
        }
    }
    void finish(){for(auto* file:{&mBonds,&mLoads,&mMeta})if(*file && gzclose(file->release())!=Z_OK)
        throw std::runtime_error("stress trace close failed");}
};
}
