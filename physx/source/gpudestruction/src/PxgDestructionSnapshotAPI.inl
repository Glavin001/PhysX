// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
// Included inside Runtime: accepted-state export and fresh-scene restore.
    bool exportState(PxOutputStream& output,const PxCollection& objects) const override {
        if(!mWriteAllowed(mScene) || !mBodyAllocator || !mBodyAllocator->stateExportAllowed() || !configured() || !mTopology || mPending || mPostCorrection
            || mHostStatus->error || mPendingPropertyCapacity || mPendingShapeCapacity)return false;
        try {
            Context current(mContext);
            check(cudaEventSynchronize(mReady));check(cudaEventSynchronize(mInput));
            if(mConsumer)check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(mConsumer)));
            snapshot::Data d=mSnapshotAsset;d.settings.c=mC;d.stage=*mHostStatus;
            const auto t=mTopology->accepted();
            check(cudaMemcpy(&d.topology,t.status,sizeof(d.topology),cudaMemcpyDeviceToHost));
            if(d.topology.invalidEdit || d.topology.slotError || d.topology.clusterCount!=mC)return false;
            snapshot::download(d.chunks,mChunks,mN);snapshot::download(d.clusters,mClusters,mC);
            snapshot::download(d.active,t.activeBonds,mM);snapshot::download(d.roots,t.activeClusters,mC);
            snapshot::download(d.labels,t.chunkCluster,mN);snapshot::download(d.slots,t.clusterSlots,mN);
            snapshot::download(d.slotRoots,t.slotRoots,mN);snapshot::download(d.generations,t.slotGenerations,mN);
            std::vector<PxU32> alive;snapshot::download(alive,t.activeChunks,mN);
            // Native correction currently rejects removal/crushing. Never silently
            // turn a removed chunk back into a live one during import.
            for(auto a:alive)if(a!=1)return false;
            d.motions.resize(mC);
            for(PxU32 i=0;i<mC;++i)check(cudaMemcpy(&d.motions[i],t.motions+d.slots[d.roots[i]],sizeof(d.motions[i]),cudaMemcpyDeviceToHost));
            if(mMaterials){snapshot::download(d.health,mHealth,mM);snapshot::download(d.crush,mCrush,mN);}
            d.shapeIds.resize(mN);d.bodyIds.resize(mC);
            std::map<PxU32,const PxShape*> shapes;std::map<PxU32,const PxRigidDynamic*> bodies;
            for(PxU32 i=0;i<objects.getNbObjects();++i){const auto& o=objects.getObject(i);
                if(const auto* shape=o.is<PxShape>()){const auto index=getShapeContactIndex(*shape);if(index!=PX_INVALID_U32){
                    shapes[index]=shape;const auto* actor=shape->getActor();const auto* body=actor?actor->is<PxRigidDynamic>():nullptr;
                    if(body && objects.getId(*body))bodies[body->getGPUIndex()]=body;}}}
            for(PxU32 i=0;i<mC;++i){const auto it=bodies.find(d.clusters[i].body);
                if(it==bodies.end() || !(d.bodyIds[i]=objects.getId(*it->second)))return false;}
            for(PxU32 i=0;i<mN;++i){const auto it=shapes.find(d.chunks[i].contactIndex);
                if(it==shapes.end() || !(d.shapeIds[i]=objects.getId(*it->second)))return false;
                const auto c=d.chunks[i].cluster;
                if(c>=mC || it->second->getActor()!=bodies.at(d.clusters[c].body))return false;
                d.chunks[i].contactIndex=PX_INVALID_U32;}
            std::map<PxU64,PxU32> native;
            for(PxU32 i=0;i<objects.getNbObjects();++i)if(const auto* body=objects.getObject(i).is<PxRigidDynamic>()){
                const auto id=objects.getId(*body);if(!id || !mBodyAllocator->isValidSource(body->getGPUIndex()))return false;
                native[id]=body->getGPUIndex();}
            std::vector<PxU32> indices;
            for(const auto& entry:native){d.nativeIds.push_back(entry.first);indices.push_back(entry.second);}
            d.settings.nativeCount=PxU32(indices.size());d.nativeBodies.resize(indices.size());
            if(!mBodyAllocator->exportNativeSnapshot(indices.data(),PxU32(indices.size()),d.nativeBodies.data(),sizeof(PxgDestructionNativeSnapshot)))return false;
            for(auto& c:d.clusters)c.body=PX_INVALID_U32;
            return snapshot::write(output,d);
        }catch(...){return false;}
    }
    bool importState(PxInputData& input,const PxCollection& objects) override {
        // Import is intentionally fresh-state only. A caller can prepare an
        // entire replacement world and publish it only after success.
        if(!mWriteAllowed(mScene) || mN || mPending || mFailed)return false;
        bool started=false;
        try {
            snapshot::Data d;if(!snapshot::read(input,d))return false;
            const auto s=d.settings;
            if(d.stage.error || (d.stage.frame && !d.stage.converged) || d.stage.correctionPasses>1
                || (d.stage.frame ? d.stage.stressPasses!=1+d.stage.correctionPasses : d.stage.stressPasses!=0) || d.topology.clusterCount!=s.c
                || d.topology.invalidEdit || d.topology.slotError)return false;
            std::set<PxU64> ids;std::vector<PxRigidDynamic*> bodies(s.c);
            for(PxU32 i=0;i<s.c;++i){auto* object=objects.find(d.bodyIds[i]);
                auto* body=object?object->is<PxRigidDynamic>():nullptr;
                if(!d.bodyIds[i] || !ids.insert(d.bodyIds[i]).second || !body || !body->getScene()
                    || !mBodyAllocator->isValidSource(body->getGPUIndex()))return false;
                bodies[i]=body;d.clusters[i].body=body->getGPUIndex();}
            ids.clear();std::set<PxU32> occupied;
            for(PxU32 i=0;i<s.n;++i){auto& c=d.chunks[i];auto* object=objects.find(d.shapeIds[i]);
                auto* shape=object?object->is<PxShape>():nullptr;
                if(!d.shapeIds[i] || !ids.insert(d.shapeIds[i]).second || !shape || c.cluster>=s.c
                    || shape->getActor()!=bodies[c.cluster])return false;
                c.contactIndex=getShapeContactIndex(*shape);if(c.contactIndex==PX_INVALID_U32)return false;
                if(d.labels[i]!=d.roots[c.cluster])return false;
                if(s.materials){const auto& v=d.crush[i];
                    if(!std::isfinite(v.damage)||v.damage<0||!std::isfinite(v.pressure)||!std::isfinite(v.deviator)
                        ||!std::isfinite(v.utilisation)||v.crushed)return false;}
            }
            for(PxU32 i=0;i<s.c;++i){const auto root=d.roots[i];
                if(root>=s.n || (i && root<=d.roots[i-1]) || d.slots[root]>=s.n)return false;
                const auto slot=d.slots[root];if(!occupied.insert(slot).second || d.slotRoots[slot]!=root || !d.generations[slot])return false;
                const auto& v=d.motions[i];for(double x:v.origin)if(!std::isfinite(x))return false;
                for(double x:v.orientation)if(!std::isfinite(x))return false;
                for(double x:v.linearVelocity)if(!std::isfinite(x))return false;
                for(double x:v.angularVelocity)if(!std::isfinite(x))return false;
            }
            for(PxU32 i=0;i<s.n;++i){
                if(d.slotRoots[i]!=PX_INVALID_U32 && (d.slotRoots[i]>=s.n || d.slots[d.slotRoots[i]]!=i || !occupied.count(i)))return false;
                if(d.slots[i]!=PX_INVALID_U32 && (d.slots[i]>=s.n || d.slotRoots[d.slots[i]]!=i))return false;
            }
            for(PxU32 i=0;i<s.m;++i){if(d.active[i]>1)return false;
                if(s.materials && (!std::isfinite(d.health[i]) || d.health[i]<0 || d.health[i]>d.bonds[i].health
                    || bool(d.active[i])!=(d.health[i]>0)))return false;
            }
            std::vector<PxU32> nativeIndices;ids.clear();
            for(PxU32 i=0;i<s.nativeCount;++i){auto* object=objects.find(d.nativeIds[i]);auto* actor=object?object->is<PxRigidDynamic>():nullptr;
                if(!d.nativeIds[i] || !ids.insert(d.nativeIds[i]).second || !actor || !mBodyAllocator->isValidSource(actor->getGPUIndex()))return false;
                nativeIndices.push_back(actor->getGPUIndex());}
            if(nativeIndices.empty())return false;
            // configure validates the active graph, component ownership, all
            // original geometry, materials and physical mass before mutation.
            const auto desc=d.desc();
            if(!configureStressImpl(desc,&d)){clearStress();return false;}
            started=true;Context current(mContext);const auto t=mTopology->accepted();
            snapshot::upload(t.clusterSlots,d.slots);snapshot::upload(t.slotRoots,d.slotRoots);snapshot::upload(t.slotGenerations,d.generations);
            for(PxU32 i=0;i<s.c;++i)check(cudaMemcpy(const_cast<PxDestructionClusterMotion*>(t.motions)+d.slots[d.roots[i]],
                &d.motions[i],sizeof(d.motions[i]),cudaMemcpyHostToDevice));
            check(cudaMemcpy(const_cast<PxDestructionTopologyStatus*>(t.status),&d.topology,sizeof(d.topology),cudaMemcpyHostToDevice));
            if(mMaterials){snapshot::upload(mHealth,d.health);snapshot::upload(mCrush,d.crush);}
            if(mSolver){
                check(cudaEventRecord(mReady,mStream));
                // Generation zero also requires an initial rebuild. The restored
                // topology may be pristine; force initial solver publication.
                if(!mSolver->updateDeviceTopologyAsync(t.activeBonds,mM,&t.status->generation,nullptr,mReady))throw std::runtime_error("restore stress topology");
                check(cudaEventSynchronize(static_cast<cudaEvent_t>(mSolver->deviceView().readyEvent)));
                // Fresh solver: guesses, settled certificates and factorizations
                // are rebuilt, never deserialized from an earlier execution.
                check(cudaStreamWaitEvent(mStream,static_cast<cudaEvent_t>(mSolver->deviceView().readyEvent),0));
            }
            if(!mBodyAllocator->importNativeSnapshot(nativeIndices.data(),PxU32(nativeIndices.size()),d.nativeBodies.data(),sizeof(PxgDestructionNativeSnapshot)))throw std::runtime_error("restore canonical native bodies");
            *mHostStatus=d.stage;check(cudaMemcpyAsync(mStatus,&d.stage,sizeof(d.stage),cudaMemcpyHostToDevice,mStream));
            check(cudaEventRecord(mReady,mStream));check(cudaEventSynchronize(mReady));return true;
        }catch(...){if(started)clearStress();return false;}
    }
