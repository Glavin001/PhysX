// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
// The impact solve's inputs, captured from the stage (PX_DESTRUCTION_IMPACT_CAPTURE)
// for offline replay (tests/impact_capture_replay.cu): raw structs of this
// build, so a capture is read by the same build that wrote it.
// Included inside the runtime's namespace (or a test's), after PxgDestructionImpact.cuh.
#include <cstddef>
#include <cstdio>
#include <cstring>
#include <vector>
namespace impact {
struct CaptureHeader { char magic[4]; PxU32 version,n,m,materials,rows,settingsBytes,flags; };
enum CaptureFlag : PxU32 { eCAPTURE_SLIP=1, eCAPTURE_STIFFNESS=2, eCAPTURE_ELASTIC_BASE=4, eCAPTURE_CRUSHED=8, eCAPTURE_SECTIONS=16, eCAPTURE_ROWS=32, eCAPTURE_CARRIED=64, eCAPTURE_SLIP_BEFORE=128, eCAPTURE_ROUTED=256 };
// Version 2: ContactRow ends with `resting` (version 1 rows lack it).
inline std::vector<ContactRow> readCaptureRows(FILE* f,PxU32 version,PxU32 count)
{
    std::vector<ContactRow> rows(count);
    const size_t size=version>=2?sizeof(ContactRow):offsetof(ContactRow,resting);
    std::vector<unsigned char> raw(size*count);
    if(count && std::fread(raw.data(),size,count,f)!=count)return {};
    for(PxU32 i=0;i<count;++i){rows[i]=ContactRow{};std::memcpy(&rows[i],raw.data()+size*i,size);}
    return rows;
}
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
    CaptureHeader h{{'I','M','P','C'},2,in.chunkCount,in.bondCount,materials,rows,PxU32(sizeof(Settings)),
        (in.ductileSlip?eCAPTURE_SLIP:0u)|(in.stiffness?eCAPTURE_STIFFNESS:0u)|(in.elasticBase?eCAPTURE_ELASTIC_BASE:0u)
        |(in.crushed?eCAPTURE_CRUSHED:0u)|(in.sections?eCAPTURE_SECTIONS:0u)|(rows?eCAPTURE_ROWS:0u)
        |(in.carried?eCAPTURE_CARRIED:0u)|(in.slipBefore?eCAPTURE_SLIP_BEFORE:0u)|((rows && in.rowRouted)?eCAPTURE_ROUTED:0u)};
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
    if(in.carried)captureArray(f,in.carried,in.bondCount);
    if(in.slipBefore)captureArray(f,in.slipBefore,in.bondCount);
    if(rows && in.rowRouted)captureArray(f,in.rowRouted,rows);
    std::fclose(f);return true;
}
}
