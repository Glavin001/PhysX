#include <metal_stdlib>
#include <metal_math>
#include <metal_texture>
using namespace metal;
struct StepParams_0
{
    uint chunk_count_0;
    uint bond_count_0;
    float dt_0;
    uint pad_0;
};

struct Bond_natural_0
{
    packed_uint4 chunks_0;
    packed_float4 t1_0;
    packed_float4 t2_0;
    packed_float4 normal_0;
    packed_float4 ra_0;
    packed_float4 rb_0;
    packed_float4 k_lin_0;
    packed_float4 k_ang_0;
    packed_float4 c_lin_0;
    packed_float4 c_ang_0;
    packed_float4 section_0;
};

struct Chunk_natural_0
{
    packed_float4 inv_inertia0_0;
    packed_float4 inv_inertia1_0;
    packed_float4 inv_inertia2_0;
    packed_float4 force_0;
    packed_float4 moment_0;
    packed_uint4 support_0;
};

struct KernelContext_0
{
    StepParams_0 constant* params_0;
    Bond_natural_0 device* bonds_0;
    packed_float4 device* state_0;
    packed_float4 device* bond_loads_0;
    Chunk_natural_0 device* chunks_1;
    uint device* chunk_bond_start_0;
    uint device* chunk_bonds_0;
};

float3 get_0(uint chunk_0, uint field_0, KernelContext_0 thread* kernelContext_0)
{
    return (float4(*(kernelContext_0->state_0+(4U * chunk_0 + field_0))) ).xyz;
}

float3 to_local_0(uint _S1, float3 _S2, KernelContext_0 thread* kernelContext_1)
{
    Bond_natural_0 device* _S3 = kernelContext_1->bonds_0+_S1;
    return float3(dot(_S2, (float4(_S3->t1_0) ).xyz), dot(_S2, (float4(_S3->t2_0) ).xyz), dot(_S2, (float4(_S3->normal_0) ).xyz));
}

float3 to_body_0(uint _S4, float3 _S5, KernelContext_0 thread* kernelContext_2)
{
    Bond_natural_0 device* _S6 = kernelContext_2->bonds_0+_S4;
    return (float4(_S6->t1_0) ).xyz * float3(_S5.x)  + (float4(_S6->t2_0) ).xyz * float3(_S5.y)  + (float4(_S6->normal_0) ).xyz * float3(_S5.z) ;
}

[[kernel]] void bond_forces(uint3 id_0 [[thread_position_in_grid]], StepParams_0 constant* params_1 [[buffer(0)]], Bond_natural_0 device* bonds_1 [[buffer(1)]], packed_float4 device* state_1 [[buffer(5)]], packed_float4 device* bond_loads_1 [[buffer(6)]], Chunk_natural_0 device* chunks_2 [[buffer(2)]], uint device* chunk_bond_start_1 [[buffer(3)]], uint device* chunk_bonds_1 [[buffer(4)]])
{
    thread KernelContext_0 kernelContext_3;
    (&kernelContext_3)->params_0 = params_1;
    (&kernelContext_3)->bonds_0 = bonds_1;
    (&kernelContext_3)->state_0 = state_1;
    (&kernelContext_3)->bond_loads_0 = bond_loads_1;
    (&kernelContext_3)->chunks_1 = chunks_2;
    (&kernelContext_3)->chunk_bond_start_0 = chunk_bond_start_1;
    (&kernelContext_3)->chunk_bonds_0 = chunk_bonds_1;
    uint i_0 = id_0.x;
    if(i_0 >= (params_1->bond_count_0))
    {
        return;
    }
    Bond_natural_0 device* _S7 = (&kernelContext_3)->bonds_0+i_0;
    uint4 _S8 = uint4(_S7->chunks_0) ;
    uint ca_0 = _S8.x;
    uint cb_0 = _S8.y;
    float3 ra_1 = (float4(_S7->ra_0) ).xyz;
    float3 rb_1 = (float4(_S7->rb_0) ).xyz;
    float3 _S9 = get_0(cb_0, 0U, &kernelContext_3);
    float3 _S10 = get_0(cb_0, 1U, &kernelContext_3);
    float3 _S11 = _S9 + cross(_S10, rb_1);
    float3 _S12 = get_0(ca_0, 0U, &kernelContext_3);
    float3 _S13 = get_0(ca_0, 1U, &kernelContext_3);
    float3 _S14 = to_local_0(i_0, _S11 - (_S12 + cross(_S13, ra_1)), &kernelContext_3);
    float3 _S15 = get_0(cb_0, 1U, &kernelContext_3);
    float3 _S16 = get_0(ca_0, 1U, &kernelContext_3);
    float3 _S17 = to_local_0(i_0, _S15 - _S16, &kernelContext_3);
    float3 _S18 = get_0(cb_0, 2U, &kernelContext_3);
    float3 _S19 = get_0(cb_0, 3U, &kernelContext_3);
    float3 _S20 = _S18 + cross(_S19, rb_1);
    float3 _S21 = get_0(ca_0, 2U, &kernelContext_3);
    float3 _S22 = get_0(ca_0, 3U, &kernelContext_3);
    float3 _S23 = to_local_0(i_0, _S20 - (_S21 + cross(_S22, ra_1)), &kernelContext_3);
    float3 _S24 = get_0(cb_0, 3U, &kernelContext_3);
    float3 _S25 = get_0(ca_0, 3U, &kernelContext_3);
    float3 _S26 = to_local_0(i_0, _S24 - _S25, &kernelContext_3);
    float3 _S27 = (float4(_S7->k_lin_0) ).xyz * _S14;
    float3 _S28 = (float4(_S7->k_ang_0) ).xyz * _S17;
    float3 q_ang_0 = _S28 + (float4(_S7->c_ang_0) ).xyz * _S26;
    float4 _S29 = float4(_S7->section_0) ;
    float stress_0 = abs(_S27.z) / _S29.x + abs(_S28.x) / _S29.y + abs(_S28.y) / _S29.z;
    float3 _S30 = to_body_0(i_0, _S27 + (float4(_S7->c_lin_0) ).xyz * _S23, &kernelContext_3);
    float3 _S31 = to_body_0(i_0, q_ang_0, &kernelContext_3);
    uint _S32 = 4U * i_0;
    *((&kernelContext_3)->bond_loads_0+_S32) = packed_float4(float4(_S30, stress_0)) ;
    *((&kernelContext_3)->bond_loads_0+(_S32 + 1U)) = packed_float4(float4(_S31 + cross(ra_1, _S30), 0.0f)) ;
    float3 _S33 = - _S30;
    *((&kernelContext_3)->bond_loads_0+(_S32 + 2U)) = packed_float4(float4(_S33, 0.0f)) ;
    *((&kernelContext_3)->bond_loads_0+(_S32 + 3U)) = packed_float4(float4(- _S31 + cross(rb_1, _S33), 0.0f)) ;
    return;
}

[[kernel]] void chunk_integrate(uint3 id_1 [[thread_position_in_grid]], StepParams_0 constant* params_2 [[buffer(0)]], Bond_natural_0 device* bonds_2 [[buffer(1)]], packed_float4 device* state_2 [[buffer(5)]], packed_float4 device* bond_loads_2 [[buffer(6)]], Chunk_natural_0 device* chunks_3 [[buffer(2)]], uint device* chunk_bond_start_2 [[buffer(3)]], uint device* chunk_bonds_2 [[buffer(4)]])
{
    thread KernelContext_0 kernelContext_4;
    (&kernelContext_4)->params_0 = params_2;
    (&kernelContext_4)->bonds_0 = bonds_2;
    (&kernelContext_4)->state_0 = state_2;
    (&kernelContext_4)->bond_loads_0 = bond_loads_2;
    (&kernelContext_4)->chunks_1 = chunks_3;
    (&kernelContext_4)->chunk_bond_start_0 = chunk_bond_start_2;
    (&kernelContext_4)->chunk_bonds_0 = chunk_bonds_2;
    uint c_0 = id_1.x;
    if(c_0 >= (params_2->chunk_count_0))
    {
        return;
    }
    Chunk_natural_0 ch_0 = (&kernelContext_4)->chunks_1[c_0];
    float3 _S34 = float3(0.0f) ;
    uint _S35 = (&kernelContext_4)->chunk_bond_start_0[c_0];
    float stress_1 = 0.0f;
    uint k_0 = _S35;
    float3 fi_0 = _S34;
    float3 mi_0 = _S34;
    for(;;)
    {
        if(k_0 < ((&kernelContext_4)->chunk_bond_start_0)[c_0 + 1U])
        {
        }
        else
        {
            break;
        }
        uint e_0 = (&kernelContext_4)->chunk_bonds_0[k_0];
        uint _S36 = 4U * (e_0 >> 1U);
        uint _S37 = _S36 + 2U * (e_0 & 1U);
        float3 fi_1 = fi_0 + (float4(*((&kernelContext_4)->bond_loads_0+_S37)) ).xyz;
        float3 mi_1 = mi_0 + (float4(*((&kernelContext_4)->bond_loads_0+(_S37 + 1U))) ).xyz;
        float _S38 = max(stress_1, (float4(*((&kernelContext_4)->bond_loads_0+_S36)) ).w);
        uint _S39 = k_0 + 1U;
        stress_1 = _S38;
        k_0 = _S39;
        fi_0 = fi_1;
        mi_0 = mi_1;
    }
    float4 _S40 = float4(ch_0.force_0) ;
    float3 f_0 = _S40.xyz + fi_0;
    float4 _S41 = float4(ch_0.moment_0) ;
    float3 m_0 = _S41.xyz + mi_0;
    float dt_1 = (&kernelContext_4)->params_0->dt_0;
    float3 alpha_0 = float3(dot((float4(ch_0.inv_inertia0_0) ).xyz, m_0), dot((float4(ch_0.inv_inertia1_0) ).xyz, m_0), dot((float4(ch_0.inv_inertia2_0) ).xyz, m_0)) * float3(_S41.w) ;
    float3 _S42 = get_0(c_0, 0U, &kernelContext_4);
    float3 _S43 = get_0(c_0, 1U, &kernelContext_4);
    float3 _S44 = get_0(c_0, 2U, &kernelContext_4);
    float3 _S45 = get_0(c_0, 3U, &kernelContext_4);
    uint support_1 = (uint4(ch_0.support_0) ).x;
    float3 uc_0;
    float3 tc_0;
    float3 vc_0;
    float3 wc_0;
    if(support_1 == 1U)
    {
        uc_0 = _S42;
        tc_0 = _S43;
        vc_0 = _S34;
        wc_0 = _S34;
    }
    else
    {
        float3 _S46 = float3(dt_1) ;
        float3 wc_1 = _S45 + alpha_0 * _S46;
        float3 tc_1 = _S43 + wc_1 * _S46;
        if(support_1 == 2U)
        {
            uc_0 = _S42;
            tc_0 = _S34;
        }
        else
        {
            float3 vc_1 = _S44 + f_0 * float3((dt_1 * _S40.w)) ;
            uc_0 = _S42 + vc_1 * _S46;
            tc_0 = vc_1;
        }
        float3 _S47 = tc_0;
        tc_0 = tc_1;
        vc_0 = _S47;
        wc_0 = wc_1;
    }
    uint _S48 = 4U * c_0;
    *((&kernelContext_4)->state_0+_S48) = packed_float4(float4(uc_0, stress_1)) ;
    *((&kernelContext_4)->state_0+(_S48 + 1U)) = packed_float4(float4(tc_0, 0.0f)) ;
    *((&kernelContext_4)->state_0+(_S48 + 2U)) = packed_float4(float4(vc_0, 0.0f)) ;
    *((&kernelContext_4)->state_0+(_S48 + 3U)) = packed_float4(float4(wc_0, 0.0f)) ;
    return;
}

