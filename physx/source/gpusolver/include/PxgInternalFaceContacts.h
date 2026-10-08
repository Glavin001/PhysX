// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
//  * Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//  * Neither the name of NVIDIA CORPORATION nor the names of its
//    contributors may be used to endorse or promote products derived
//    from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS ''AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
// OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// Copyright (c) 2008-2026 NVIDIA Corporation. All rights reserved.
// Copyright (c) 2004-2008 AGEIA Technologies, Inc. All rights reserved.
// Copyright (c) 2001-2004 NovodeX AG. All rights reserved.


#ifndef PXG_INTERNAL_FACE_CONTACTS_H
#define PXG_INTERNAL_FACE_CONTACTS_H

#include "foundation/PxSimpleTypes.h"
#include "foundation/PxVec3.h"
#include "foundation/PxQuat.h"
#include "foundation/PxTransform.h"
#include "PxNodeIndex.h"

namespace physx
{
// Internal faces of compound boxes, as the rigid solver's contact prep sees them
// (PxgDestructionRuntime::internalFaceContactView; disabled unless
// PX_DESTRUCTION_INTERNAL_EDGES). Boxes of one rigid body that sit flush, face
// to face (paving slabs, floor and wall pieces), make one continuous surface,
// but the narrowphase meets each box alone: a body sliding over the seam between
// two of them meets the next box's edge as if it stood proud, along a normal
// tilted back by the edge, and is thrown up and back (the internal-edge problem:
// a 110 t rock skimming paving at 135 m/s left a seam at 22 m/s up). A box face
// is internal while the boxes that cover it (PxDestructionChunkBox::internalFaces,
// PxDestructionStressDesc::chunkFaceNeighbours) all still belong to its rigid
// body: a neighbour broken away or crushed (a body of its own) exposes it again.
//
// The correction is the one triangle meshes get from active edges (Bullet's
// btAdjustInternalEdgeContacts): a convex contact's normal lies in the normal
// cone of the box feature it touches -- a face's normal, the quarter cone between
// two faces at an edge, the octant at a vertex -- so in the box's own axes its
// nonzero components name the faces of that feature. A face that is internal
// continues into its neighbour, so the feature is no edge along it: that
// component is dropped and the normal is the adjoining exposed face's (or the cone
// of the exposed ones). The contact's separation is kept (the depth measured on
// the feature, as Bullet keeps it). A feature whose every face is internal (a body
// already inside the compound) is left alone: its neighbour's own contact, on the
// far side of the face, is what pushes it out. Exact in float: a component is
// dropped, not compared against a tolerance, so a face contact (one component)
// passes unchanged and a patch already corrected is a fixed point.
struct PxgInternalFaceContactView
{
	const PxU32*			inputs;			// the contact managers' inputs, 4 words each (shape refs 0, 1; transform cache refs 2, 3), the solver's cmOutputIndex space
	const PxU8*				transforms;		// the transform cache (PxsCachedTransform, transformStride bytes each, the shape's world pose first), by transform cache ref
	const PxNodeIndex*		owners;			// the shapes' rigid bodies now (the narrowphase's shape -> rigid remap), by transform cache ref
	const PxU32*			map;			// transform cache ref -> chunk, 2 words each (ref, chunk), sorted by ref
	PxU32					mapCount;
	PxU32					chunkCount;
	PxU32					transformStride;
	PxU32					ownerCount;
	const PxU32*			chunks;			// per chunk, 2 words: its box shape's transform cache ref, its internal faces (bits 0..5: 2k -axis k, 2k+1 +axis k; 0: none)
	const PxU32*			faceBegin;		// per chunk face (6 c + f), its covering neighbours: neighbours[faceBegin[6 c + f] .. faceBegin[6 c + f + 1])
	const PxU32*			neighbours;		// the neighbours' transform cache refs
};

#if PX_CUDA_COMPILER
static __device__ __forceinline__ PxU32 internalFaceChunk(const PxgInternalFaceContactView& v, const PxU32 ref)
{
	PxU32 a = 0, b = v.mapCount;
	while(a < b) { const PxU32 m = a + (b - a) / 2; if(v.map[2 * m] < ref) a = m + 1; else b = m; }
	return (a < v.mapCount && v.map[2 * a] == ref) ? v.map[2 * a + 1] : 0xffffffffu;
}

// Face f of chunk c is internal now: marked, and every box covering it is in
// the body of the chunk's own shape (ref).
static __device__ __forceinline__ bool internalFaceNow(const PxgInternalFaceContactView& v, const PxU32 c, const PxU32 f, const PxU32 ref)
{
	if(!((v.chunks[2 * c + 1] >> f) & 1u))
		return false;
	if(ref >= v.ownerCount)
		return false;
	const PxNodeIndex own = v.owners[ref];
	const PxU32 end = v.faceBegin[6 * c + f + 1];
	for(PxU32 i = v.faceBegin[6 * c + f]; i < end; ++i)
	{
		const PxU32 n = v.neighbours[i];
		if(n >= v.ownerCount || !(v.owners[n] == own))
			return false;
	}
	return true;
}

// The outward normal `out` (world) of the box on transform cache ref `ref`, its
// components along internal faces dropped. Returns false (out unchanged) when the
// shape is no marked chunk box, no component was dropped, or every one was.
static __device__ __forceinline__ bool internalFaceCorrect(const PxgInternalFaceContactView& v, const PxU32 ref, PxVec3& out)
{
	const PxU32 c = internalFaceChunk(v, ref);
	if(c >= v.chunkCount || v.chunks[2 * c] != ref || !(v.chunks[2 * c + 1] & 63u))
		return false;
	const PxTransform& pose = *reinterpret_cast<const PxTransform*>(v.transforms + size_t(v.transformStride) * ref);
	const PxVec3 local = pose.q.rotateInv(out);
	PxVec3 kept = local;
	bool dropped = false;
	for(PxU32 k = 0; k < 3; ++k)
	{
		if(local[k] == 0.0f)
			continue;
		if(internalFaceNow(v, c, 2 * k + (local[k] > 0.0f ? 1u : 0u), ref))
		{
			kept[k] = 0.0f;
			dropped = true;
		}
	}
	if(!dropped)
		return false;
	const PxReal m = kept.magnitude();
	if(!(m > 0.0f))
		return false;	// every face of the feature internal: left to the neighbours' contacts
	out = pose.q.rotate(kept * (1.0f / m));
	return true;
}

// A contact patch's normal (from shape 1 to shape 0) corrected for the internal
// faces of either side's box: shape 1's outward normal is the patch normal,
// shape 0's its negative.
static __device__ __forceinline__ void internalFaceContactNormal(const PxgInternalFaceContactView& v, const PxU32 cmIndex, PxVec3& normal)
{
	const PxU32 ref0 = v.inputs[4 * cmIndex + 2], ref1 = v.inputs[4 * cmIndex + 3];
	PxVec3 out = normal;
	if(internalFaceCorrect(v, ref1, out))
		normal = out;
	out = -normal;
	if(internalFaceCorrect(v, ref0, out))
		normal = -out;
}
#endif
}

#endif
