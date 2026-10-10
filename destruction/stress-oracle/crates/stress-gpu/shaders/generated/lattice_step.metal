#include <metal_stdlib>
#include <metal_math>
#include <metal_texture>
using namespace metal;
struct StepParams_0
{
    uint count_0;
    float dt_0;
    float stiffness_0;
    float damping_0;
    float4 gravity_0;
    float spacing_0;
    uint pad0_0;
    uint pad1_0;
    uint pad2_0;
};

struct KernelContext_0
{
    StepParams_0 constant* params_0;
    packed_float4 device* displacement_0;
    uint device* adjacency_start_0;
    uint device* adjacency_0;
    float device* strain_0;
    uint device* fixed_0;
    packed_float4 device* velocity_0;
};

[[kernel]] void lattice_forces(uint3 id_0 [[thread_position_in_grid]], StepParams_0 constant* params_1 [[buffer(0)]], packed_float4 device* displacement_1 [[buffer(4)]], uint device* adjacency_start_1 [[buffer(1)]], uint device* adjacency_1 [[buffer(2)]], float device* strain_1 [[buffer(6)]], uint device* fixed_1 [[buffer(3)]], packed_float4 device* velocity_1 [[buffer(5)]])
{
    thread KernelContext_0 kernelContext_0;
    (&kernelContext_0)->params_0 = params_1;
    (&kernelContext_0)->displacement_0 = displacement_1;
    (&kernelContext_0)->adjacency_start_0 = adjacency_start_1;
    (&kernelContext_0)->adjacency_0 = adjacency_1;
    (&kernelContext_0)->strain_0 = strain_1;
    (&kernelContext_0)->fixed_0 = fixed_1;
    (&kernelContext_0)->velocity_0 = velocity_1;
    uint i_0 = id_0.x;
    if(i_0 >= (params_1->count_0))
    {
        return;
    }
    float3 _S1 = (float4(*((&kernelContext_0)->displacement_0+i_0)) ).xyz;
    float3 _S2 = float3(0.0f) ;
    uint _S3 = (&kernelContext_0)->adjacency_start_0[i_0];
    float largest_0 = 0.0f;
    uint k_0 = _S3;
    float3 force_0 = _S2;
    for(;;)
    {
        if(k_0 < ((&kernelContext_0)->adjacency_start_0)[i_0 + 1U])
        {
        }
        else
        {
            break;
        }
        float3 stretch_0 = (float4(*((&kernelContext_0)->displacement_0+(&kernelContext_0)->adjacency_0[k_0])) ).xyz - _S1;
        float3 force_1 = force_0 + stretch_0 * float3((&kernelContext_0)->params_0->stiffness_0) ;
        float _S4 = max(largest_0, length(stretch_0) / (&kernelContext_0)->params_0->spacing_0);
        uint _S5 = k_0 + 1U;
        largest_0 = _S4;
        k_0 = _S5;
        force_0 = force_1;
    }
    *((&kernelContext_0)->strain_0+i_0) = largest_0;
    if((&kernelContext_0)->fixed_0[i_0] != 0U)
    {
        *((&kernelContext_0)->velocity_0+i_0) = packed_float4(float4(0.0f) ) ;
        return;
    }
    float3 v_0 = (float4(*((&kernelContext_0)->velocity_0+i_0)) ).xyz;
    *((&kernelContext_0)->velocity_0+i_0) = packed_float4(float4(v_0 + (force_0 + (&kernelContext_0)->params_0->gravity_0.xyz - v_0 * float3((&kernelContext_0)->params_0->damping_0) ) * float3((&kernelContext_0)->params_0->dt_0) , 0.0f)) ;
    return;
}

[[kernel]] void lattice_positions(uint3 id_1 [[thread_position_in_grid]], StepParams_0 constant* params_2 [[buffer(0)]], packed_float4 device* displacement_2 [[buffer(4)]], uint device* adjacency_start_2 [[buffer(1)]], uint device* adjacency_2 [[buffer(2)]], float device* strain_2 [[buffer(6)]], uint device* fixed_2 [[buffer(3)]], packed_float4 device* velocity_2 [[buffer(5)]])
{
    thread KernelContext_0 kernelContext_1;
    (&kernelContext_1)->params_0 = params_2;
    (&kernelContext_1)->displacement_0 = displacement_2;
    (&kernelContext_1)->adjacency_start_0 = adjacency_start_2;
    (&kernelContext_1)->adjacency_0 = adjacency_2;
    (&kernelContext_1)->strain_0 = strain_2;
    (&kernelContext_1)->fixed_0 = fixed_2;
    (&kernelContext_1)->velocity_0 = velocity_2;
    uint i_1 = id_1.x;
    if(i_1 >= (params_2->count_0))
    {
        return;
    }
    *((&kernelContext_1)->displacement_0+i_1) = packed_float4(float4((float4(*((&kernelContext_1)->displacement_0+i_1)) ).xyz + (float4(*((&kernelContext_1)->velocity_0+i_1)) ).xyz * float3((&kernelContext_1)->params_0->dt_0) , 0.0f)) ;
    return;
}

