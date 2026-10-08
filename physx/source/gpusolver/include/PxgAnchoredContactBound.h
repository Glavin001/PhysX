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
	const PxReal*	chunks;		// per chunk, 4 words: its live bonds' capacity times the timestep (N s), its mass (kg), unused, unused
};

#if PX_CUDA_COMPILER
static __host__ __device__ __forceinline__ PxU32 anchoredContactChunk(const PxgAnchoredContactBoundView& v, const PxU32 ref)
{
	PxU32 a = 0, b = v.mapCount;
	while(a < b) { const PxU32 m = a + (b - a) / 2; if(v.map[2 * m] < ref) a = m + 1; else b = m; }
	return (a < v.mapCount && v.map[2 * a] == ref) ? v.map[2 * a + 1] : 0xffffffffu;
}

// The impulse an anchored chunk can take from a contact over one timestep:
// what its bonds transmit to its anchors, capacity * dt, plus the momentum its
// own mass takes in following the impactor, m * v_close. (Every term is an
// upper bound: the bonds' capacities summed in their strongest sense, the full
// closing speed; so a contact held by intact bonds is never cut short, and
// one past it breaks bonds -- the stage's verdict sees a load at least their
// capacity.)
static __host__ __device__ __forceinline__ PxReal anchoredContactImpulse(const PxReal capacityDt, const PxReal mass, const PxReal closing)
{
	return capacityDt + mass * PxMax(closing, 0.0f);
}

// Per contact point of a pair: the bound when exactly one of its sides is an
// anchored chunk -- a chunk shape on a kinematic body (its cluster, held by its
// supports; kinematic0/1) -- and PX_MAX_REAL otherwise, as PhysX's own
// contacts: the pair's impulse over its points. v0, v1: the two bodies'
// velocities at the start of the pass; normal: the patch's.
static __host__ __device__ __forceinline__ PxReal anchoredContactPointBound(const PxgAnchoredContactBoundView& v, const PxU32 cmIndex,
	const bool kinematic0, const bool kinematic1, const PxVec3& v0, const PxVec3& v1, const PxVec3& normal, const PxU32 points)
{
	if(!v.chunks || !v.inputs || !points || kinematic0 == kinematic1)
		return PX_MAX_REAL;
	const PxU32 c = anchoredContactChunk(v, v.inputs[4 * cmIndex + (kinematic0 ? 2 : 3)]);
	if(c >= v.chunkCount)
		return PX_MAX_REAL;	// a kinematic body that is no destructible chunk
	// The closing speed along the normal, either sense (a separating pair takes no impulse).
	const PxReal closing = PxAbs((v1 - v0).dot(normal));
	return anchoredContactImpulse(v.chunks[4 * c], v.chunks[4 * c + 1], closing) / PxReal(points);
}

#endif // PX_CUDA_COMPILER

} // namespace physx

#endif
