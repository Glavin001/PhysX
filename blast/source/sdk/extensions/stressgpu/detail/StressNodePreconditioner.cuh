// Private implementation fragment; included once inside the owning .cu namespace.
// BEGIN UNCHANGED SOURCE
/// Assemble and invert the 6x6 diagonal block of L per node: block-Jacobi.
///
/// L = D C C^T D, so the diagonal block at node i is D_i (sum over incident
/// bonds of A A^T) D_i, where A = [[I, -[r]x],[0, I]] is that bond's coupling
/// block. A A^T works out to
///
///     A A^T = [[ I - [r]x [r]x ,  -[r]x ],
///              [   +[r]x        ,    I   ]]
///
/// and since [r]x [r]x = r r^T - |r|^2 I, the top-left is I - r r^T + |r|^2 I.
/// Note BOTH the sign of that product and the ASYMMETRY of the off-diagonal
/// blocks (-[r]x above, +[r]x below, because [r]x^T = -[r]x). Getting either
/// wrong makes the block non-SPD and the preconditioned iteration diverges
/// outright -- measured, first attempt: residual 9e+04 against 2.6e-02.
///
/// Correctness safety: if the assembled block will not factor, this stores the
/// IDENTITY for that node. A preconditioner that degenerates to no
/// preconditioner is still a valid preconditioner -- it costs iterations, never
/// the answer -- so no input can make this produce a wrong solve.
__global__ void nodeSpaceBuildJacobi(
    float* inverse,                  // 36 floats per node, row major
    const Inertia* inertia,
    const std::uint32_t* nodeBondBegin,
    const std::uint32_t* nodeBondRef,
    const std::uint32_t* node0,
    const std::uint32_t* node1,
    const Vec4* offset0,
    const Vec4* offset1,
    const float* health,
    const float* colScale,
    std::uint32_t nodeCount,
    std::uint32_t bondCount)
{
    const std::uint32_t node = blockIdx.x * blockDim.x + threadIdx.x;
    if (node >= nodeCount)
    {
        return;
    }
    float m[36];
    for (int i = 0; i < 36; ++i) m[i] = 0.0f;

    const Inertia inv = inertia[node];
    const bool dynamic = !(inv.angular == 0.0f && inv.linear == 0.0f);
    if (dynamic)
    {
        for (std::uint32_t i = nodeBondBegin[node]; i < nodeBondBegin[node + 1]; ++i)
        {
            const std::uint32_t ref = nodeBondRef[i];
            if (ref == kDeadBondRef) continue;
            const std::uint32_t bond = ref & 0x7FFFFFFFu;
            if (bond >= bondCount || health[bond] <= 0.0f) continue;
            const Vec4 r = (ref & 0x80000000u) ? offset1[bond] : offset0[bond];
            const float rx = r.x, ry = r.y, rz = r.z;
            const float r2 = rx * rx + ry * ry + rz * rz;
            // Column scale enters the diagonal block as s_j^2 (L_S = D C S^2 C^T D).
            const float w = colScale[bond] * colScale[bond];
            // top-left: I - r r^T + |r|^2 I
            m[0*6+0] += w * (1.0f - rx*rx + r2);  m[0*6+1] += w * (-rx*ry);  m[0*6+2] += w * (-rx*rz);
            m[1*6+0] += w * (-ry*rx);  m[1*6+1] += w * (1.0f - ry*ry + r2);  m[1*6+2] += w * (-ry*rz);
            m[2*6+0] += w * (-rz*rx);  m[2*6+1] += w * (-rz*ry);  m[2*6+2] += w * (1.0f - rz*rz + r2);
            // off-diagonal: -[r]x above the diagonal, +[r]x below.
            const float sx[9] = {0.0f, -rz, ry,  rz, 0.0f, -rx,  -ry, rx, 0.0f};
            for (int a = 0; a < 3; ++a)
                for (int b = 0; b < 3; ++b)
                {
                    m[(a)*6 + (3+b)] += -w * sx[a*3+b];
                    m[(3+a)*6 + (b)] += +w * sx[a*3+b];
                }
            // bottom-right: I
            m[3*6+3] += w;  m[4*6+4] += w;  m[5*6+5] += w;
        }
        // Apply the 0/1 inertia mask on both sides, as L does.
        for (int a = 0; a < 6; ++a)
            for (int b = 0; b < 6; ++b)
            {
                const float da = (a < 3) ? inv.angular : inv.linear;
                const float db = (b < 3) ? inv.angular : inv.linear;
                m[a*6+b] *= da * db;
            }
    }

    // Gauss-Jordan with partial pivoting into `out`, starting from identity.
    float out[36];
    for (int i = 0; i < 36; ++i) out[i] = 0.0f;
    for (int i = 0; i < 6; ++i) out[i*6+i] = 1.0f;

    bool ok = dynamic;
    if (ok)
    {
        for (int col = 0; col < 6 && ok; ++col)
        {
            int piv = col;
            float best = fabsf(m[col*6+col]);
            for (int r2i = col + 1; r2i < 6; ++r2i)
            {
                const float v = fabsf(m[r2i*6+col]);
                if (v > best) { best = v; piv = r2i; }
            }
            if (!(best > 1e-12f)) { ok = false; break; }
            if (piv != col)
                for (int c = 0; c < 6; ++c)
                {
                    float t = m[col*6+c]; m[col*6+c] = m[piv*6+c]; m[piv*6+c] = t;
                    t = out[col*6+c]; out[col*6+c] = out[piv*6+c]; out[piv*6+c] = t;
                }
            const float inv0 = 1.0f / m[col*6+col];
            for (int c = 0; c < 6; ++c) { m[col*6+c] *= inv0; out[col*6+c] *= inv0; }
            for (int r2i = 0; r2i < 6; ++r2i)
            {
                if (r2i == col) continue;
                const float f = m[r2i*6+col];
                if (f == 0.0f) continue;
                for (int c = 0; c < 6; ++c)
                { m[r2i*6+c] -= f * m[col*6+c]; out[r2i*6+c] -= f * out[col*6+c]; }
            }
        }
        for (int i = 0; i < 36 && ok; ++i) if (!isfinite(out[i])) ok = false;
    }
    if (!ok)
    {
        for (int i = 0; i < 36; ++i) out[i] = 0.0f;
        for (int i = 0; i < 6; ++i) out[i*6+i] = 1.0f;   // identity fallback
    }
    for (int i = 0; i < 36; ++i) inverse[node * 36 + i] = out[i];
}

/// g = N w, and gamma = w^T g accumulated per island.
__global__ void nodeSpaceApplyJacobi(
    AngLin* g,
    const AngLin* w,
    const float* inverse,
    const std::uint32_t* nodeIsland,
    const std::uint32_t* islandActive,
    float* gammaSlots,
    std::uint32_t slotCount,
    const std::uint32_t* activeNodes,
    const std::uint32_t* activeCounts)
{
    const std::uint32_t slot = blockIdx.x * blockDim.x + threadIdx.x;
    if (slot >= activeCounts[1]) return;
    const std::uint32_t node = activeNodes[slot];
    const std::uint32_t island = nodeIsland[node];
    if (island == kNoIsland || !islandActive[island]) return;

    const float wv[6] = {w[node].angular.x, w[node].angular.y, w[node].angular.z,
                         w[node].linear.x, w[node].linear.y, w[node].linear.z};
    const float* M = inverse + node * 36;
    // N MUST BE APPLIED TWICE.
    //
    // CGLS wants P ~ S^+ in bond space. With P = W N B and B(W rho) = L rho,
    // P s = W N L rho, so matching S^+ needs N L = L^+, i.e. N ~ L^-2 -- NOT
    // L^-1. Applying an L^-1 approximation once yields P ~ I, which is the
    // UNPRECONDITIONED operator back again, except perturbed by the
    // approximation error -- a noisy identity, strictly worse than identity.
    // Measured with a single apply: residual 1.52e+00 against 2.59e-02
    // unpreconditioned, stable across three unrelated bug fixes, which is what
    // finally identified this as structural rather than a memory bug.
    float half[6];
    for (int a = 0; a < 6; ++a)
    {
        float acc = 0.0f;
        for (int b = 0; b < 6; ++b) acc += M[a*6+b] * wv[b];
        half[a] = acc;
    }
    float gv[6];
    for (int a = 0; a < 6; ++a)
    {
        float acc = 0.0f;
        for (int b = 0; b < 6; ++b) acc += M[a*6+b] * half[b];
        gv[a] = acc;
    }
    g[node].angular = Vec4{gv[0], gv[1], gv[2], 0.0f};
    g[node].linear = Vec4{gv[3], gv[4], gv[5], 0.0f};
    float gamma = 0.0f;
    for (int a = 0; a < 6; ++a) gamma += wv[a] * gv[a];
    if (slotCount == 0u) gammaSlots[node] = gamma;
    else atomicAdd(&gammaSlots[island * slotCount + (slot & (slotCount - 1u))], gamma);
}

