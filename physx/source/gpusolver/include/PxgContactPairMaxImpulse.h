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


#ifndef PXG_CONTACT_PAIR_MAX_IMPULSE_H
#define PXG_CONTACT_PAIR_MAX_IMPULSE_H

#include "foundation/PxSimpleTypes.h"
#include "foundation/PxMath.h"

namespace physx
{
// A contact pair's max impulse per point from its two bodies' values. PhysX's
// own bodies carry a non-negative max contact impulse and the pair takes the
// smaller (PxMin). Two negative values are the destruction stage's corrected
// pass (PxgDestructionRuntime.cu boundImpactContacts, pairwise):
//   -b                 an impactor's bound b: it holds only against a body the
//                      impact step struck (its rows' anchored clusters), the
//                      pairs that step evaluated;
//   -PX_MAX_F32        a struck body (unbounded itself).
// Every other pair of a bounded impactor (debris, the ground, another vehicle
// part) is an ordinary rigid contact: the step never evaluated it, so its
// bound says nothing about it.
static __host__ __device__ __forceinline__ PxReal contactPairMaxImpulse(const PxReal m0, const PxReal m1)
{
	if(m0 >= 0.0f && m1 >= 0.0f)
		return PxMin(m0, m1);
	const bool struck0 = m0 == -PX_MAX_F32, struck1 = m1 == -PX_MAX_F32;
	PxReal m = PxMin(m0 >= 0.0f ? m0 : PX_MAX_F32, m1 >= 0.0f ? m1 : PX_MAX_F32);
	if(struck0 && m1 < 0.0f && !struck1) m = PxMin(m, -m1);
	if(struck1 && m0 < 0.0f && !struck0) m = PxMin(m, -m0);
	return m;
}

} // namespace physx

#endif
