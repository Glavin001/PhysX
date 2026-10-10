// End-to-end demo kernel: one explicit substep of a chunk lattice (linear springs
// between neighbouring chunks, gravity, light damping, fixed chunks). Each chunk
// gathers its springs from a CSR adjacency list, so no atomics are needed and the sum
// order is fixed: the pattern the stress solver's bond forces use.

struct StepParams
{
    uint count;
    float dt;
    float stiffness; // spring constant over chunk mass (1/s^2)
    float damping;   // velocity damping rate (1/s)
    float4 gravity;  // xyz (m/s^2)
    float spacing;   // rest distance between neighbours (m)
    uint pad0;
    uint pad1;
    uint pad2;
};

[[vk::binding(0, 0)]] ConstantBuffer<StepParams> params;
[[vk::binding(1, 0)]] StructuredBuffer<uint> adjacency_start; // count + 1 offsets
[[vk::binding(2, 0)]] StructuredBuffer<uint> adjacency;       // neighbour chunk indices
[[vk::binding(3, 0)]] StructuredBuffer<uint> fixed;           // 1: held in place
[[vk::binding(4, 0)]] RWStructuredBuffer<float4> displacement;
[[vk::binding(5, 0)]] RWStructuredBuffer<float4> velocity;
[[vk::binding(6, 0)]] RWStructuredBuffer<float> strain;       // largest spring strain per chunk

// Velocity update from the displacements at the start of the substep.
[shader("compute")]
[numthreads(64, 1, 1)]
void lattice_forces(uint3 id: SV_DispatchThreadID)
{
    uint i = id.x;
    if (i >= params.count)
        return;
    float3 ui = displacement[i].xyz;
    float3 force = float3(0.0);
    float largest = 0.0;
    for (uint k = adjacency_start[i]; k < adjacency_start[i + 1]; k++)
    {
        float3 stretch = displacement[adjacency[k]].xyz - ui;
        force += stretch * params.stiffness;
        largest = max(largest, length(stretch) / params.spacing);
    }
    strain[i] = largest;
    if (fixed[i] != 0)
    {
        velocity[i] = float4(0.0);
        return;
    }
    float3 v = velocity[i].xyz;
    v += (force + params.gravity.xyz - v * params.damping) * params.dt;
    velocity[i] = float4(v, 0.0);
}

// Position update with the new velocities (a separate dispatch: every chunk's force
// above must see the displacements of the start of the substep).
[shader("compute")]
[numthreads(64, 1, 1)]
void lattice_positions(uint3 id: SV_DispatchThreadID)
{
    uint i = id.x;
    if (i >= params.count)
        return;
    displacement[i] = float4(displacement[i].xyz + velocity[i].xyz * params.dt, 0.0);
}
