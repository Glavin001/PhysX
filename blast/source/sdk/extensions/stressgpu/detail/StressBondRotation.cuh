// Private implementation fragment; included once inside the owning .cu namespace.
// Per-bond rotational stiffness (ExtStressGpuSetBondRotationalStiffness).
//
// The solve minimises sum |S^-1 lambda|^2 over bond impulses lambda in
// equilibrium: the bonds' complementary energy, with S^2 the bond stiffness.
// By default S = s I on all six rows, and the angular rows are measured in
// units of the structure's one length scale Ls (m_lengthScale), so every bond
// is k Ls^2 stiff in rotation about every axis. With rotational stiffness the
// angular block of S is s A, A = R / Ls, R = r0 e0 e0' + r1 e1 e1' + rp n n'
// the radii of gyration of the bond's own section (sqrt(I/A) about each
// principal axis of the patch, sqrt(I_p/A) about the normal): rotational
// stiffness k I / A per axis, k I_p / A in twist.
//
//   B^T, B (bond <-> node): the angular rows carry s A    (angularScale)
//   L = B B^T:              the angular rows carry s^2 W  (angularWeight, W = A^2)
//
// Both are packed symmetric 3x3 (xx yy zz xy xz yz) per bond, or null, in
// which case every caller reproduces the uniform arithmetic exactly.
//
// Shear stiffness (ExtStressGpuSetBondShearStiffness, the Shear template
// argument): the linear block of S is s Al too, Al = n n' + sqrt(gamma) (I -
// n n'), gamma the bond's shear stiffness over its normal stiffness (G/E for a
// joint of one material; a fastened joint's slip over its bearing). Each row is
// then twelve floats: the angular block's six, the linear block's six.
__device__ __forceinline__ Vec4 bondRotationApply(const float* m, const Vec4& v)
{
    return makeVec(m[0] * v.x + m[3] * v.y + m[4] * v.z,
                   m[3] * v.x + m[1] * v.y + m[5] * v.z,
                   m[4] * v.x + m[5] * v.y + m[2] * v.z);
}
#ifdef PHYSX_RESIDENT_DESTRUCTION
// S v for one bond's impulse-space vector (factor = s, with any sign).
template<bool Shear=false>
__device__ __forceinline__ StressHierarchy::Vector bondScaled(const float* angularScale, unsigned bond,
    StressHierarchy::Vector v, StressReal factor)
{
    if (!angularScale) return StressHierarchy::mul(v, factor);
    if constexpr (Shear)
        return {StressHierarchy::mul(StressHierarchy::symmetricApply(angularScale + 12 * size_t(bond), v.angular), factor),
                StressHierarchy::mul(StressHierarchy::symmetricApply(angularScale + 12 * size_t(bond) + 6, v.linear), factor)};
    else
    return {StressHierarchy::mul(StressHierarchy::symmetricApply(angularScale + 6 * size_t(bond), v.angular), factor),
            StressHierarchy::mul(v.linear, factor)};
}
#endif
