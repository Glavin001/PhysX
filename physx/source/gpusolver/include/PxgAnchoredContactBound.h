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


#ifndef PXG_ANCHORED_CONTACT_BOUND_H
#define PXG_ANCHORED_CONTACT_BOUND_H

#include "foundation/PxSimpleTypes.h"
#include "foundation/PxMath.h"
#include "foundation/PxVec3.h"
#include <string.h>

namespace physx
{
// The destruction stage's anchored chunks as the rigid solver's contact prep
// sees them (PxgDestructionRuntime::anchoredContactBoundView; disabled unless
// PX_DESTRUCTION_ANCHORED_CONTACT_BOUND): a chunk of a kinematic (anchored)
// cluster is held in place by its bonds, and a contact can push on it no
// harder than those bonds carry plus the chunk's own inertia. The kinematic
// cluster has none to offer, so without a bound such a chunk is an infinite
// wall: a 110 t meteor at 131 m/s stopped dead by a masonry wall in three
// ticks (some 290 MN against bonds of a few MN).
struct PxgAnchoredContactBoundView
{
	const PxU32*	inputs;		// the contact managers' inputs, 4 words each (shape refs 0, 1; transform cache refs 2, 3), the solver's cmOutputIndex space
	const PxU32*	map;		// transform cache ref -> chunk, 2 words each (ref, chunk), sorted by ref
	PxU32			mapCount;
	PxU32			chunkCount;
	const PxReal*	chunks;		// per chunk, 4 words: unused, its mass (kg), the impact step's bound per point for the corrected pass (N s; 0: none), unused
	const PxU32*	nodeBegin;	// per chunk, its bonds: nodeRefs[nodeBegin[c] .. nodeBegin[c + 1])
	const PxU32*	nodeRefs;
	const PxReal*	bonds;		// per bond, 8 words: its axis (unit, chunk0 -> chunk1), chunk0 (bits), and its compression, tension and
								// shear capacities times the timestep (N s; 0 when it carries nothing: broken, worn out, a crushed end), unused
};

#if PX_CUDA_COMPILER
static __host__ __device__ __forceinline__ PxU32 anchoredContactChunk(const PxgAnchoredContactBoundView& v, const PxU32 ref)
{
	PxU32 a = 0, b = v.mapCount;
	while(a < b) { const PxU32 m = a + (b - a) / 2; if(v.map[2 * m] < ref) a = m + 1; else b = m; }
	return (a < v.mapCount && v.map[2 * a] == ref) ? v.map[2 * a + 1] : 0xffffffffu;
}

// What an anchored chunk's bonds can pass to its anchors over one timestep
// against a force along nf (unit, the force on the chunk): the most that the
// bonds' forces, each inside its fatal capacity (axial: compression C or
// tension T; transverse: shear S, any direction in its plane), add up to along
// nf -- the support function of their capacity sets, per bond (C or T) |a| +
// S t, a and t the axial and transverse shares of nf, summed. A force past it
// cannot be held with every bond inside its capacity, so the verdict breaks
// one: a contact bounded there pushes past no chunk that stays in place.
// (Bending is not counted: the bound is at least the bonds' true capacity.)
static __host__ __device__ __forceinline__ PxReal anchoredChunkImpulse(const PxgAnchoredContactBoundView& v, const PxU32 c, const PxVec3& nf)
{
	PxReal J = 0.0f;
	for(PxU32 slot = v.nodeBegin[c]; slot < v.nodeBegin[c + 1]; ++slot)
	{
		const PxReal* b = v.bonds + 8 * v.nodeRefs[slot];
		if(!(b[4] > 0.0f || b[5] > 0.0f || b[6] > 0.0f))
			continue;
		PxU32 c0; memcpy(&c0, b + 3, sizeof c0);
		const PxReal a = (c0 == c ? 1.0f : -1.0f) * (b[0] * nf.x + b[1] * nf.y + b[2] * nf.z);
		const PxReal t = PxSqrt(PxMax(0.0f, 1.0f - a * a));
		J += (a > 0.0f ? b[4] : b[5]) * PxAbs(a) + b[6] * t;
	}
	return J;
}

// The impulse an anchored chunk can take from a contact over one timestep:
// what its bonds pass to its anchors (anchoredChunkImpulse) plus the momentum
// its own mass takes in following the impactor, m * v_close.
static __host__ __device__ __forceinline__ PxReal anchoredContactImpulse(const PxReal bondsImpulse, const PxReal mass, const PxReal closing)
{
	return bondsImpulse + mass * PxMax(closing, 0.0f);
}

// Per contact point of a pair: the bound when exactly one of its sides is an
// anchored chunk -- a chunk shape on a kinematic body (its cluster, held by its
// supports; kinematic0/1) -- and PX_MAX_REAL otherwise, as PhysX's own
// contacts: the pair's impulse over its points. v0, v1: the two bodies'
// velocities at the start of the pass; normal: the patch's (from shape 1 to
// shape 0: the force on shape 0 is along it).
static __host__ __device__ __forceinline__ PxReal anchoredContactPointBound(const PxgAnchoredContactBoundView& v, const PxU32 cmIndex,
	const bool kinematic0, const bool kinematic1, const PxVec3& v0, const PxVec3& v1, const PxVec3& normal, const PxU32 points)
{
	if(!v.chunks || !v.inputs || !points || kinematic0 == kinematic1)
		return PX_MAX_REAL;
	const PxU32 c = anchoredContactChunk(v, v.inputs[4 * cmIndex + (kinematic0 ? 2 : 3)]);
	if(c >= v.chunkCount)
		return PX_MAX_REAL;	// a kinematic body that is no destructible chunk
	// A chunk the impact step evaluated (its rows) takes what the step delivered
	// there, per point: the step's dynamics decided its bonds.
	const PxReal step = v.chunks[4 * c + 2];
	if(step > 0.0f)
		return step;
	const PxVec3 nf = kinematic0 ? normal : -normal;
	// The closing speed along the normal, either sense (a separating pair takes no impulse).
	const PxReal closing = PxAbs((v1 - v0).dot(normal));
	return anchoredContactImpulse(anchoredChunkImpulse(v, c, nf), v.chunks[4 * c + 1], closing) / PxReal(points);
}

#endif // PX_CUDA_COMPILER

} // namespace physx

#endif
