// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#ifndef PXG_HOST_ADDRESS_TOKEN_H
#define PXG_HOST_ADDRESS_TOKEN_H

#include "foundation/PxSimpleTypes.h"

// CPU contact-stream addresses are opaque identities on the GPU: kernels add
// offsets, store them for CPU readback, or subtract matching CPU bases. They
// must never dereference these tokens. Actual GPU stream pointers are separate.
// A CuMetal top-level pointer argument binds a Metal buffer and changes to its
// GPU virtual address. A by-value wrapper instead preserves the CPU bits.
// CUDA retains its original pointer signatures and launch parameter bytes.
#if defined(PX_CUMETAL)
namespace physx
{
    template<typename T> struct PxgHostAddressToken { T* value; };
    static_assert(sizeof(PxgHostAddressToken<void>) == sizeof(void*), "Host address token size");
    static_assert(alignof(PxgHostAddressToken<void>) == alignof(void*), "Host address token alignment");
}
#define PXG_HOST_ADDRESS_PARAMETER(T, Q, N) physx::PxgHostAddressToken<T> N##Token
#define PXG_HOST_ADDRESS_DECODE(T, Q, N) T* Q N = N##Token.value;
#define PXG_HOST_ADDRESS_CAPTURE(T, N) const physx::PxgHostAddressToken<T> N##Token = {N};
#define PXG_HOST_ADDRESS_KERNEL_PARAM(N) PX_CUDA_KERNEL_PARAM(N##Token)
#else
#define PXG_HOST_ADDRESS_PARAMETER(T, Q, N) T* Q N
#define PXG_HOST_ADDRESS_DECODE(T, Q, N)
#define PXG_HOST_ADDRESS_CAPTURE(T, N)
#define PXG_HOST_ADDRESS_KERNEL_PARAM(N) PX_CUDA_KERNEL_PARAM(N)
#endif

#endif
