// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
// The impact solve's inputs, captured from the stage (PX_DESTRUCTION_IMPACT_CAPTURE)
// for offline replay (tests/impact_capture_replay.cu): raw structs of this
// build, so a capture is read by the same build that wrote it.
// Included inside the runtime's namespace (or a test's), after PxgDestructionImpact.cuh.
#include <cstdio>
#include <vector>
namespace impact {
struct CaptureHeader { char magic[4]; PxU32 version,n,m,materials,rows,settingsBytes,flags; };
enum CaptureFlag : PxU32 { eCAPTURE_SLIP=1, eCAPTURE_STIFFNESS=2, eCAPTURE_ELASTIC_BASE=4, eCAPTURE_CRUSHED=8, eCAPTURE_SECTIONS=16, eCAPTURE_ROWS=32 };
template<class T>inline void captureArray(FILE* f,const T* device,size_t count)
{
    std::vector<T> host(count);
    if(count && device)check(cudaMemcpy(host.data(),device,sizeof(T)*count,cudaMemcpyDeviceToHost));
    if(count)std::fwrite(host.data(),sizeof(T),count,f);
}
// Synchronous: the caller has synchronised the stream.
inline bool writeCapture(const char* path,const Inputs& in,const Settings& s,PxU32 materials)
{
    FILE* f=std::fopen(path,"wb");if(!f)return false;
    PxU32 rows=0;if(in.rows && in.rowCounter){check(cudaMemcpy(&rows,in.rowCounter,sizeof rows,cudaMemcpyDeviceToHost));rows=rows<in.rowCount?rows:in.rowCount;}
    else if(in.rows)rows=in.rowCount;
    CaptureHeader h{{'I','M','P','C'},1,in.chunkCount,in.bondCount,materials,rows,PxU32(sizeof(Settings)),
        (in.ductileSlip?eCAPTURE_SLIP:0u)|(in.stiffness?eCAPTURE_STIFFNESS:0u)|(in.elasticBase?eCAPTURE_ELASTIC_BASE:0u)
        |(in.crushed?eCAPTURE_CRUSHED:0u)|(in.sections?eCAPTURE_SECTIONS:0u)|(rows?eCAPTURE_ROWS:0u)};
    std::fwrite(&h,sizeof h,1,f);std::fwrite(&s,sizeof s,1,f);
    captureArray(f,in.chunks,in.chunkCount);captureArray(f,in.bonds,in.bondCount);captureArray(f,in.materials,materials);
    if(in.ductileSlip)captureArray(f,in.ductileSlip,materials);
    if(in.stiffness)captureArray(f,in.stiffness,materials);
    captureArray(f,in.health,in.bondCount);
    captureArray(f,in.nodeBegin,size_t(in.chunkCount)+1);
    {PxU32 refs=0;check(cudaMemcpy(&refs,in.nodeBegin+in.chunkCount,sizeof refs,cudaMemcpyDeviceToHost));
     std::fwrite(&refs,sizeof refs,1,f);captureArray(f,in.nodeRefs,refs);}
    captureArray(f,in.nodeIslands,in.chunkCount);captureArray(f,in.bondIslands,in.bondCount);
    captureArray(f,in.accelerations,in.chunkCount);captureArray(f,in.elastic,in.bondCount);captureArray(f,in.base,in.bondCount);
    if(in.elasticBase)captureArray(f,in.elasticBase,in.bondCount);
    if(in.crushed)captureArray(f,in.crushed,in.chunkCount);
    if(in.sections)captureArray(f,in.sections,in.bondCount);
    if(rows)captureArray(f,in.rows,rows);
    std::fclose(f);return true;
}
}
