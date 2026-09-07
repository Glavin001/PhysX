// Private implementation fragment; included once inside the owning .cu namespace.
// BEGIN UNCHANGED SOURCE
/// Apply patched node->bond CSR entries. Four slots per removal instead of
/// re-uploading the whole 2*bondCount reference array.
__global__ void scatterNodeBondRefs(
    const std::uint32_t* slots,
    const std::uint32_t* values,
    std::uint32_t count,
    std::uint32_t* nodeBondRef)
{
    const std::uint32_t i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < count)
    {
        nodeBondRef[slots[i]] = values[i];
    }
}

/// One bond's full topology record, for the sparse upload path.
struct alignas(16) BondDelta
{
    Vec4 offset0;
    Vec4 offset1;
    Vec4 normal;
    std::uint32_t node0;
    std::uint32_t node1;
    std::uint32_t material;
    std::uint32_t island;
    float area;
    float nodeDistance;
    float health;
    float colScale;
};

/// Apply a sparse topology update.
///
/// removeBond is swap-with-last, so a removal rewrites exactly ONE live slot
/// (the removed index, which receives the former last bond); everything past
/// the new bond count is simply never read again. The whole-array re-upload
/// this replaces moved ~16 MB per fracture tick to change a few hundred bonds.
__global__ void scatterBondTopology(
    const std::uint32_t* slots,
    const BondDelta* values,
    std::uint32_t count,
    std::uint32_t* node0,
    std::uint32_t* node1,
    Vec4* offset0,
    Vec4* offset1,
    Vec4* normals,
    float* areas,
    float* nodeDistances,
    float* health,
    float* colScales,
    std::uint32_t* materials,
    std::uint32_t* island)
{
    const std::uint32_t i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= count)
    {
        return;
    }
    const std::uint32_t b = slots[i];
    const BondDelta v = values[i];
    colScales[b] = v.colScale;
    node0[b] = v.node0;
    node1[b] = v.node1;
    offset0[b] = v.offset0;
    offset1[b] = v.offset1;
    normals[b] = v.normal;
    areas[b] = v.area;
    nodeDistances[b] = v.nodeDistance;
    health[b] = v.health;
    materials[b] = v.material;
    island[b] = v.island;
}

