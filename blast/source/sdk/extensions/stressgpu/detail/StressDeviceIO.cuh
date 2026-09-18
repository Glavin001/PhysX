// Private implementation fragment; included once inside the owning .cu namespace.
// BEGIN UNCHANGED SOURCE
/// Pack the impulses of the islands that were actually solved into a dense
/// block, so the device-to-host copy and the host's conversion loop cost what
/// changed rather than what exists.
__global__ void exportPhysicalImpulses(const AngLin* impulses, const float* colScales,
    ExtStressGpuImpulse* output, unsigned count, float angularScale, float linearScale)
{
    const unsigned i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= count) return;
    const auto v = impulses[i];
    const float a = angularScale * colScales[i], l = linearScale * colScales[i];
    output[i] = {{v.angular.x*a, v.angular.y*a, v.angular.z*a},
                 {v.linear.x*l, v.linear.y*l, v.linear.z*l}};
}

__global__ void gatherImpulses(
    const AngLin* impulses,
    const std::uint32_t* indices,
    AngLin* output,
    std::uint32_t count)
{
    const std::uint32_t index = blockIdx.x * blockDim.x + threadIdx.x;
    if (index < count)
    {
        output[index] = impulses[indices[index]];
    }
}

/// Write only the node velocities that changed. The device keeps the rest from
/// the previous upload, which is why they are known to be unchanged at all.
__global__ void scatterVelocities(
    ExtStressGpuImpulse* input,
    const std::uint32_t* indices,
    const ExtStressGpuImpulse* values,
    std::uint32_t count)
{
    const std::uint32_t index = blockIdx.x * blockDim.x + threadIdx.x;
    if (index < count)
    {
        input[indices[index]] = values[index];
    }
}

/// Flag the entries the compacted index lists should keep. One pass over the
/// raw arrays per REBUILD (skip-set or topology change), instead of one pass
/// per kernel per iteration per tick. The predicates are bondSettled /
/// nodeSettled themselves, so the lists cannot disagree with the guards.
///
/// The flags feed cub::DeviceSelect::Flagged rather than an atomicAdd append:
/// select preserves index order, so a compacted list walks memory in the same
/// ascending order the underlying bond/node arrays are laid out in. With the
/// atomic append the order was whatever the scheduler raced out, and every CG
/// kernel's global loads through the list were uncoalesced -- invisible while
/// most islands skip, ~2x kernel time when nothing skips (fresh whole-map
/// cascade, the regime the solver exists for).
__global__ void flagActiveBonds(
    const std::uint32_t* bondIsland,
    const std::uint32_t* islandSkip,
    std::uint32_t bondCount,
    std::uint32_t* flags)
{
    const std::uint32_t bond = blockIdx.x * blockDim.x + threadIdx.x;
    if (bond < bondCount)
    {
        flags[bond] = bondSettled(islandSkip, bondIsland[bond]) ? 0u : 1u;
    }
}

__global__ void flagActiveNodes(
    const std::uint32_t* nodeIsland,
    const std::uint32_t* islandSkip,
    std::uint32_t nodeCount,
    std::uint32_t* flags)
{
    const std::uint32_t node = blockIdx.x * blockDim.x + threadIdx.x;
    if (node < nodeCount)
    {
        flags[node] = nodeSettled(islandSkip, nodeIsland[node]) ? 0u : 1u;
    }
}

