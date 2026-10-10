#include <metal_stdlib>
#include <metal_math>
#include <metal_texture>
using namespace metal;
struct ContactParams_0
{
    float4 gravity_0;
    float dt_0;
    float zeta_0;
    float pair_friction_0;
    uint halt_index_0;
    float ground_hi_0;
    float ground_lo_0;
    float ground_friction_0;
    float ground_modulus_0;
    uint has_ground_0;
    uint pair_count_0;
    uint impactor_count_0;
    uint chunk_count_0;
    uint loads_base_0;
    uint ledger_base_0;
    uint step_start_0;
    uint record_stride_0;
    uint cand_begin_0;
    uint cand_count_0;
    uint cand_base_0;
    uint pad0_0;
};

struct Island_natural_0
{
    packed_uint4 range_0;
    packed_uint4 info_0;
    packed_float4 com_0;
    packed_float4 inertia0_0;
    packed_float4 inertia1_0;
    packed_float4 inertia2_0;
    packed_float4 inv0_0;
    packed_float4 inv1_0;
    packed_float4 inv2_0;
    packed_float4 wcom_0;
    packed_float4 winv0_0;
    packed_float4 winv1_0;
    packed_float4 winv2_0;
    packed_float4 rotation_0;
    packed_float4 position_0;
    packed_float4 position_err_0;
    packed_float4 velocity_0;
    packed_float4 velocity_err_0;
    packed_float4 angular_velocity_0;
    packed_uint4 done_0;
    packed_uint4 probes_0;
    packed_float4 energy_0;
};

struct ChunkStatic_natural_0
{
    packed_float4 center_0;
    packed_float4 inertia0_1;
    packed_float4 inertia1_1;
    packed_float4 inertia2_1;
    packed_float4 inv0_1;
    packed_float4 inv1_1;
    packed_float4 inv2_1;
    packed_float4 scale_0;
    packed_uint4 info_1;
    packed_uint4 load_range_0;
};

struct ContactChunk_natural_0
{
    packed_float4 half_0;
    packed_float4 rot0_0;
    packed_float4 rot1_0;
    packed_float4 rot2_0;
    packed_float4 mat_0;
    packed_float4 start_hi_0;
    packed_float4 start_lo_0;
    packed_uint4 info_2;
};

struct Impactor_natural_0
{
    packed_float4 position_1;
    packed_float4 position_err_1;
    packed_float4 velocity_1;
    packed_float4 velocity_err_1;
    packed_float4 angular_velocity_1;
    packed_float4 rotation_1;
    packed_float4 inertia0_2;
    packed_float4 inertia1_2;
    packed_float4 inertia2_2;
    packed_float4 inv0_2;
    packed_float4 inv1_2;
    packed_float4 inv2_2;
    packed_float4 shape_0;
    packed_float4 half_1;
    packed_float4 mat_1;
    packed_float4 crush_0;
    packed_float4 load_force_0;
    packed_float4 load_torque_0;
    packed_float4 ledger_0;
    packed_uint4 cand_0;
};

struct KernelContext_0
{
    ContactParams_0 constant* params_0;
    Island_natural_0 device* islands_0;
    packed_uint4 device* contact_static_0;
    ChunkStatic_natural_0 device* chunks_0;
    packed_float4 device* state_0;
    ContactChunk_natural_0 device* contact_chunks_0;
    packed_float4 device* contact_out_0;
    packed_float4 device* contact_state_0;
    Impactor_natural_0 device* impactors_0;
    array<float4, int(256)> threadgroup* g_red_a_0;
    array<float4, int(256)> threadgroup* g_red_b_0;
};

bool stopped_0(KernelContext_0 thread* kernelContext_0)
{
    uint4 _S1 = uint4((kernelContext_0->islands_0+kernelContext_0->params_0->halt_index_0)->info_0) ;
    bool _S2;
    if(((_S1.z) & 1U) != 0U)
    {
        _S2 = true;
    }
    else
    {
        _S2 = (_S1.y) != 0U;
    }
    return _S2;
}

struct Quat_0
{
    float w_0;
    float x_0;
    float y_0;
    float z_0;
};

Quat_0 quat_of_0(float4 q_0)
{
    thread Quat_0 r_0;
    (&r_0)->x_0 = q_0.x;
    (&r_0)->y_0 = q_0.y;
    (&r_0)->z_0 = q_0.z;
    (&r_0)->w_0 = q_0.w;
    return r_0;
}

float3 rotate_0(const Quat_0 thread* q_1, float3 v_0)
{
    float3 qv_0 = float3(q_1->x_0, q_1->y_0, q_1->z_0);
    float3 t_0 = cross(qv_0, v_0) * float3(2.0f) ;
    return v_0 + t_0 * float3(q_1->w_0)  + cross(qv_0, t_0);
}

float3 rotate_1(const Quat_0 thread* q_2, float3 v_1)
{
    float3 qv_1 = float3(q_2->x_0, q_2->y_0, q_2->z_0);
    float3 t_1 = cross(qv_1, v_1) * float3(2.0f) ;
    return v_1 + t_1 * float3(q_2->w_0)  + cross(qv_1, t_1);
}

struct WorldPoint_0
{
    float3 hi_0;
    float3 lo_0;
    float3 rel_0;
};

WorldPoint_0 chunk_world_0(uint c_0, KernelContext_0 thread* kernelContext_1)
{
    ChunkStatic_natural_0 device* _S3 = kernelContext_1->chunks_0+c_0;
    Island_natural_0 device* _S4 = kernelContext_1->islands_0+(uint4(_S3->info_1) ).y;
    Quat_0 q_3 = quat_of_0(float4(_S4->rotation_0) );
    thread WorldPoint_0 w_1;
    (&w_1)->hi_0 = (float4(_S4->position_0) ).xyz;
    (&w_1)->lo_0 = (float4(_S4->position_err_0) ).xyz;
    float3 _S5 = (float4(_S3->center_0) ).xyz + (float4(*(kernelContext_1->state_0+4U * c_0)) ).xyz;
    thread Quat_0 _S6 = q_3;
    float3 _S7 = rotate_0(&_S6, _S5);
    (&w_1)->rel_0 = _S7;
    return w_1;
}

float3 world_diff_0(const WorldPoint_0 thread* a_0, const WorldPoint_0 thread* b_0)
{
    return a_0->hi_0 - b_0->hi_0 + (a_0->lo_0 - b_0->lo_0) + (a_0->rel_0 - b_0->rel_0);
}

float3 safe_normalize_0(float3 v_2)
{
    float n_0 = length(v_2);
    float3 _S8;
    if(n_0 > 1.00000000317107685e-30f)
    {
        _S8 = v_2 / float3(n_0) ;
    }
    else
    {
        _S8 = float3(0.0f) ;
    }
    return _S8;
}

Quat_0 from_axis_angle_0(float3 axis_0, float angle_0)
{
    float3 a_1 = safe_normalize_0(axis_0);
    float _S9 = 0.5f * angle_0;
    float s_0 = sin(_S9);
    thread Quat_0 q_4;
    (&q_4)->w_0 = cos(_S9);
    (&q_4)->x_0 = a_1.x * s_0;
    (&q_4)->y_0 = a_1.y * s_0;
    (&q_4)->z_0 = a_1.z * s_0;
    return q_4;
}

struct Box_0
{
    float3 center_1;
    float3 axis0_0;
    float3 axis1_0;
    float3 axis2_0;
    float3 half_2;
};

Box_0 chunk_box_0(uint c_1, float3 center_2, KernelContext_0 thread* kernelContext_2)
{
    ContactChunk_natural_0 cc_0 = kernelContext_2->contact_chunks_0[c_1];
    Quat_0 q_5 = quat_of_0(float4((kernelContext_2->islands_0+(uint4((kernelContext_2->chunks_0+c_1)->info_1) ).y)->rotation_0) );
    float3 th_0 = (float4(*(kernelContext_2->state_0+(4U * c_1 + 1U))) ).xyz;
    Quat_0 hidden_0 = from_axis_angle_0(th_0, length(th_0));
    thread Box_0 b_1;
    (&b_1)->center_1 = center_2;
    float4 _S10 = float4(cc_0.rot0_0) ;
    float4 _S11 = float4(cc_0.rot1_0) ;
    float4 _S12 = float4(cc_0.rot2_0) ;
    float3 _S13 = float3(_S10.x, _S11.x, _S12.x);
    thread Quat_0 _S14 = hidden_0;
    float3 _S15 = rotate_0(&_S14, _S13);
    thread Quat_0 _S16 = q_5;
    float3 _S17 = rotate_0(&_S16, _S15);
    (&b_1)->axis0_0 = _S17;
    float3 _S18 = float3(_S10.y, _S11.y, _S12.y);
    thread Quat_0 _S19 = hidden_0;
    float3 _S20 = rotate_0(&_S19, _S18);
    thread Quat_0 _S21 = q_5;
    float3 _S22 = rotate_0(&_S21, _S20);
    (&b_1)->axis1_0 = _S22;
    float3 _S23 = float3(_S10.z, _S11.z, _S12.z);
    thread Quat_0 _S24 = hidden_0;
    float3 _S25 = rotate_0(&_S24, _S23);
    thread Quat_0 _S26 = q_5;
    float3 _S27 = rotate_0(&_S26, _S25);
    (&b_1)->axis2_0 = _S27;
    (&b_1)->half_2 = (float4(cc_0.half_0) ).xyz;
    return b_1;
}

bool may_overlap_0(const Box_0 thread* a_2, const Box_0 thread* b_2)
{
    float3 _S28 = b_2->center_1 - a_2->center_1;
    float3 _S29 = a_2->half_2;
    float3 _S30 = b_2->half_2;
    float _S31 = 0.00000999999974738f * (length(a_2->half_2) + length(b_2->half_2));
    float3 _S32 = a_2->axis0_0;
    float3 _S33 = a_2->axis1_0;
    float3 _S34 = a_2->axis2_0;
    float3 _S35 = b_2->axis0_0;
    float3 _S36 = b_2->axis1_0;
    float3 _S37 = b_2->axis2_0;
    array<float3, int(6)> _S38 = { { a_2->axis0_0, a_2->axis1_0, a_2->axis2_0, b_2->axis0_0, b_2->axis1_0, b_2->axis2_0 } };
    uint i_0 = 0U;
    for(;;)
    {
        if(i_0 < 15U)
        {
        }
        else
        {
            break;
        }
        float3 l_0;
        if(i_0 < 6U)
        {
            l_0 = _S38[i_0];
        }
        else
        {
            uint _S39 = i_0 - 6U;
            l_0 = cross(_S38[_S39 / 3U], _S38[3U + _S39 % 3U]);
        }
        float len_0 = length(l_0);
        if(len_0 <= 9.99999997475242708e-07f)
        {
            i_0 = i_0 + 1U;
            continue;
        }
        if((abs(dot(_S28, l_0))) > (_S29.x * abs(dot(_S32, l_0)) + _S29.y * abs(dot(_S33, l_0)) + _S29.z * abs(dot(_S34, l_0)) + (_S30.x * abs(dot(_S35, l_0)) + _S30.y * abs(dot(_S36, l_0)) + _S30.z * abs(dot(_S37, l_0))) + _S31 * len_0))
        {
            return false;
        }
        i_0 = i_0 + 1U;
    }
    return true;
}

float3 box_axis_0(const Box_0 thread* b_3, uint k_0)
{
    float3 _S40;
    if(k_0 == 0U)
    {
        _S40 = b_3->axis0_0;
    }
    else
    {
        if(k_0 == 1U)
        {
            _S40 = b_3->axis1_0;
        }
        else
        {
            _S40 = b_3->axis2_0;
        }
    }
    return _S40;
}

float comp3_0(float3 v_3, uint k_1)
{
    float _S41;
    if(k_1 == 0U)
    {
        _S41 = v_3.x;
    }
    else
    {
        if(k_1 == 1U)
        {
            _S41 = v_3.y;
        }
        else
        {
            _S41 = v_3.z;
        }
    }
    return _S41;
}

float3 sample_point_0(const Box_0 thread* b_4, uint i_1)
{
    float sign_0;
    if(i_1 < 8U)
    {
        float3 h_0 = b_4->half_2 * float3(0.89999997615814209f) ;
        if((i_1 & 1U) == 0U)
        {
            sign_0 = - h_0.x;
        }
        else
        {
            sign_0 = h_0.x;
        }
        float _S42;
        if((i_1 & 2U) == 0U)
        {
            _S42 = - h_0.y;
        }
        else
        {
            _S42 = h_0.y;
        }
        float _S43;
        if((i_1 & 4U) == 0U)
        {
            _S43 = - h_0.z;
        }
        else
        {
            _S43 = h_0.z;
        }
        return b_4->center_1 + b_4->axis0_0 * float3(sign_0)  + b_4->axis1_0 * float3(_S42)  + b_4->axis2_0 * float3(_S43) ;
    }
    uint _S44 = i_1 - 8U;
    uint axis_1 = _S44 / 2U;
    if((_S44 % 2U) == 0U)
    {
        sign_0 = -1.0f;
    }
    else
    {
        sign_0 = 1.0f;
    }
    float3 _S45 = b_4->center_1;
    float3 _S46 = box_axis_0(b_4, axis_1);
    return _S45 + _S46 * float3((sign_0 * comp3_0(b_4->half_2, axis_1))) ;
}

bool penetration_0(const Box_0 thread* b_5, float3 p_0, float thread* depth_0, float3 thread* normal_0)
{
    *depth_0 = 0.0f;
    *normal_0 = float3(0.0f) ;
    float3 r_1 = p_0 - b_5->center_1;
    float3 _S47 = b_5->half_2;
    if((dot(r_1, r_1)) > (dot(b_5->half_2, b_5->half_2) * 1.00001001358032227f))
    {
        return false;
    }
    float best_0 = 1.00000001504746622e+30f;
    uint axis_2 = 0U;
    float side_0 = 1.0f;
    uint k_2 = 0U;
    for(;;)
    {
        if(k_2 < 3U)
        {
        }
        else
        {
            break;
        }
        float3 _S48 = box_axis_0(b_5, k_2);
        float local_0 = dot(r_1, _S48);
        float d_0 = comp3_0(_S47, k_2) - abs(local_0);
        if(d_0 <= 0.0f)
        {
            return false;
        }
        if(d_0 < best_0)
        {
            float _S49;
            if(local_0 >= 0.0f)
            {
                _S49 = 1.0f;
            }
            else
            {
                _S49 = -1.0f;
            }
            best_0 = d_0;
            axis_2 = k_2;
            side_0 = _S49;
        }
        k_2 = k_2 + 1U;
    }
    *depth_0 = best_0;
    float3 _S50 = box_axis_0(b_5, axis_2);
    *normal_0 = _S50 * float3(side_0) ;
    return true;
}

float2 half_thickness_and_area_0(const Box_0 thread* b_6, float3 d_1)
{
    uint k_3 = 0U;
    float h_1 = 0.0f;
    float area_0 = 0.0f;
    for(;;)
    {
        if(k_3 < 3U)
        {
        }
        else
        {
            break;
        }
        float3 _S51 = box_axis_0(b_6, k_3);
        float c_2 = abs(dot(d_1, _S51));
        float h_2 = h_1 + c_2 * comp3_0(b_6->half_2, k_3);
        uint _S52 = k_3 + 1U;
        float area_1 = area_0 + c_2 * 4.0f * comp3_0(b_6->half_2, _S52 % 3U) * comp3_0(b_6->half_2, (k_3 + 2U) % 3U);
        k_3 = _S52;
        h_1 = h_2;
        area_0 = area_1;
    }
    return float2(h_1, area_0);
}

float contact_stiffness_0(float ea_0, const Box_0 thread* a_3, float eb_0, const Box_0 thread* b_7, float3 dir_0)
{
    float3 d_2 = safe_normalize_0(dir_0);
    float2 _S53 = half_thickness_and_area_0(a_3, d_2);
    float2 _S54 = half_thickness_and_area_0(b_7, d_2);
    return min(_S53.y, _S54.y) / (_S53.x / ea_0 + _S54.x / eb_0);
}

void chunk_velocity_0(uint c_3, float3 thread* v_4, float3 thread* w_2, KernelContext_0 thread* kernelContext_3)
{
    ChunkStatic_natural_0 device* _S55 = kernelContext_3->chunks_0+c_3;
    Island_natural_0 device* _S56 = kernelContext_3->islands_0+(uint4(_S55->info_1) ).y;
    Quat_0 q_6 = quat_of_0(float4(_S56->rotation_0) );
    uint _S57 = 4U * c_3;
    float3 _S58 = (float4(_S55->center_0) ).xyz + (float4(*(kernelContext_3->state_0+_S57)) ).xyz - (float4(_S56->com_0) ).xyz;
    thread Quat_0 _S59 = q_6;
    float3 _S60 = rotate_0(&_S59, _S58);
    float3 _S61 = (float4(_S56->angular_velocity_0) ).xyz;
    float3 _S62 = (float4(_S56->velocity_0) ).xyz + (float4(_S56->velocity_err_0) ).xyz + cross(_S61, _S60);
    float3 _S63 = (float4(*(kernelContext_3->state_0+(_S57 + 2U))) ).xyz;
    thread Quat_0 _S64 = q_6;
    float3 _S65 = rotate_0(&_S64, _S63);
    *v_4 = _S62 + _S65;
    float3 _S66 = (float4(*(kernelContext_3->state_0+(_S57 + 3U))) ).xyz;
    thread Quat_0 _S67 = q_6;
    float3 _S68 = rotate_0(&_S67, _S66);
    *w_2 = _S61 + _S68;
    return;
}

float3 penalty_force_0(float k_4, float m_red_0, float friction_0, float depth_1, float3 normal_1, float3 rel_velocity_0, float dt_1, uint points_0, float thread* stored_0, float thread* dissipated_0, KernelContext_0 thread* kernelContext_4)
{
    float c_max_0 = 1.0f / max(float(points_0), 10.0f) * m_red_0 / dt_1;
    float vn_0 = dot(rel_velocity_0, normal_1);
    float _S69 = k_4 * depth_1;
    float _S70 = min(2.0f * kernelContext_4->params_0->zeta_0 * sqrt(k_4 * m_red_0), c_max_0) * vn_0;
    float _S71 = _S69 - _S70;
    float _S72 = max(_S71, 0.0f);
    float3 vt_0 = rel_velocity_0 - normal_1 * float3(vn_0) ;
    float vt_mag_0 = length(vt_0);
    float _S73 = friction_0 * _S72;
    float _S74 = min(_S73, min(c_max_0, _S73 / 0.00100000004749745f) * vt_mag_0);
    float3 ft_0;
    if(vt_mag_0 > 0.0f)
    {
        ft_0 = - vt_0 * float3((_S74 / vt_mag_0)) ;
    }
    else
    {
        ft_0 = float3(0.0f) ;
    }
    *stored_0 = 0.5f * k_4 * depth_1 * depth_1;
    float damping_power_0;
    if(_S71 > 0.0f)
    {
        damping_power_0 = _S70 * vn_0;
    }
    else
    {
        damping_power_0 = _S69 * max(vn_0, 0.0f);
    }
    *dissipated_0 = (damping_power_0 + length(ft_0) * vt_mag_0) * dt_1;
    return normal_1 * float3(_S72)  + ft_0;
}

void comp_add1_0(float thread* sum_0, float thread* err_0, float x_1)
{
    float t_2 = *sum_0 + x_1;
    if((abs(*sum_0)) >= (abs(x_1)))
    {
        *err_0 = *err_0 + (*sum_0 - t_2 + x_1);
    }
    else
    {
        *err_0 = *err_0 + (x_1 - t_2 + *sum_0);
    }
    *sum_0 = t_2;
    return;
}

[[kernel]] void contact_pairs(uint3 id_0 [[thread_position_in_grid]], ContactParams_0 constant* params_1 [[buffer(0)]], Island_natural_0 device* islands_1 [[buffer(4)]], packed_uint4 device* contact_static_1 [[buffer(5)]], ChunkStatic_natural_0 device* chunks_1 [[buffer(1)]], packed_float4 device* state_1 [[buffer(3)]], ContactChunk_natural_0 device* contact_chunks_1 [[buffer(2)]], packed_float4 device* contact_out_1 [[buffer(8)]], packed_float4 device* contact_state_1 [[buffer(6)]], Impactor_natural_0 device* impactors_1 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_5;
    (&kernelContext_5)->params_0 = params_1;
    (&kernelContext_5)->islands_0 = islands_1;
    (&kernelContext_5)->contact_static_0 = contact_static_1;
    (&kernelContext_5)->chunks_0 = chunks_1;
    (&kernelContext_5)->state_0 = state_1;
    (&kernelContext_5)->contact_chunks_0 = contact_chunks_1;
    (&kernelContext_5)->contact_out_0 = contact_out_1;
    (&kernelContext_5)->contact_state_0 = contact_state_1;
    (&kernelContext_5)->impactors_0 = impactors_1;
    threadgroup array<float4, int(256)> g_red_a_1;
    (&kernelContext_5)->g_red_a_0 = &g_red_a_1;
    threadgroup array<float4, int(256)> g_red_b_1;
    (&kernelContext_5)->g_red_b_0 = &g_red_b_1;
    uint i_2 = id_0.x;
    bool has_state_0;
    if(i_2 >= (params_1->pair_count_0))
    {
        has_state_0 = true;
    }
    else
    {
        bool _S75 = stopped_0(&kernelContext_5);
        has_state_0 = _S75;
    }
    if(has_state_0)
    {
        return;
    }
    uint _S76 = 2U * i_2;
    uint4 _S77 = uint4(*((&kernelContext_5)->contact_static_0+_S76)) ;
    float4 law_0 = (as_type<float4>((uint4(*((&kernelContext_5)->contact_static_0+(_S76 + 1U))) )));
    uint ca_0 = _S77.x;
    uint cb_0 = _S77.y;
    uint slot_0 = _S77.z;
    uint _S78 = _S77.w * 28U;
    float _S79 = law_0.x;
    float _S80 = law_0.y;
    float _S81 = (&kernelContext_5)->params_0->dt_0;
    WorldPoint_0 _S82 = chunk_world_0(ca_0, &kernelContext_5);
    WorldPoint_0 _S83 = chunk_world_0(cb_0, &kernelContext_5);
    thread WorldPoint_0 _S84 = _S83;
    thread WorldPoint_0 _S85 = _S82;
    float3 _S86 = world_diff_0(&_S84, &_S85);
    bool touching_0 = !((length(_S86)) > ((float4((&kernelContext_5)->contact_chunks_0[ca_0].half_0) ).w + (float4((&kernelContext_5)->contact_chunks_0[cb_0].half_0) ).w));
    float4 _S87 = float4(*((&kernelContext_5)->contact_out_0+((&kernelContext_5)->params_0->ledger_base_0 + i_2))) ;
    thread float4 ledger_1 = _S87;
    uint flags_0 = (as_type<uint>((_S87.w)));
    uint e_0;
    if(!touching_0)
    {
        if((flags_0 & 1U) != 0U)
        {
            e_0 = 0U;
            for(;;)
            {
                if(e_0 < 28U)
                {
                }
                else
                {
                    break;
                }
                *((&kernelContext_5)->contact_state_0+(_S78 + e_0)) = packed_float4(float4((as_type<float>((2143289344U))), 0.0f, 0.0f, 0.0f)) ;
                e_0 = e_0 + 1U;
            }
        }
        if((flags_0 & 2U) != 0U)
        {
            uint _S88 = 2U * slot_0;
            packed_float4 _S89 = packed_float4(float4(0.0f) ) ;
            *((&kernelContext_5)->contact_out_0+_S88) = _S89;
            *((&kernelContext_5)->contact_out_0+(_S88 + 1U)) = _S89;
            *((&kernelContext_5)->contact_out_0+(_S88 + 2U)) = _S89;
            *((&kernelContext_5)->contact_out_0+(_S88 + 3U)) = _S89;
        }
        if(flags_0 != 0U)
        {
            has_state_0 = true;
        }
        else
        {
            has_state_0 = (ledger_1.x) != 0.0f;
        }
        if(has_state_0)
        {
            ledger_1.x = 0.0f;
            ledger_1.w = (as_type<float>((0U)));
            *((&kernelContext_5)->contact_out_0+((&kernelContext_5)->params_0->ledger_base_0 + i_2)) = packed_float4(ledger_1) ;
        }
        return;
    }
    float3 _S90 = float3(0.0f) ;
    Box_0 _S91 = chunk_box_0(ca_0, _S90, &kernelContext_5);
    Box_0 _S92 = chunk_box_0(cb_0, _S86, &kernelContext_5);
    thread Box_0 _S93 = _S91;
    thread Box_0 _S94 = _S92;
    bool _S95 = may_overlap_0(&_S93, &_S94);
    uint s_1;
    uint count_0;
    float3 fa_0;
    float3 ta_0;
    float3 fb_0;
    float3 tb_0;
    float stored_sum_0;
    if(_S95)
    {
        thread array<float3, int(28)> pts_0;
        thread array<float3, int(28)> nrm_0;
        thread array<float, int(28)> dep_0;
        thread array<uint, int(28)> idx_0;
        s_1 = 0U;
        count_0 = 0U;
        for(;;)
        {
            if(s_1 < 14U)
            {
            }
            else
            {
                break;
            }
            thread Box_0 _S96 = _S91;
            float3 _S97 = sample_point_0(&_S96, s_1);
            thread Box_0 _S98 = _S92;
            thread float d_3;
            thread float3 n_1;
            bool _S99 = penetration_0(&_S98, _S97, &d_3, &n_1);
            if(_S99)
            {
                pts_0[count_0] = _S97;
                nrm_0[count_0] = n_1;
                dep_0[count_0] = d_3;
                idx_0[count_0] = s_1;
                count_0 = count_0 + 1U;
            }
            s_1 = s_1 + 1U;
        }
        s_1 = 0U;
        for(;;)
        {
            if(s_1 < 14U)
            {
            }
            else
            {
                break;
            }
            thread Box_0 _S100 = _S92;
            float3 _S101 = sample_point_0(&_S100, s_1);
            thread Box_0 _S102 = _S91;
            thread float d_4;
            thread float3 n_2;
            bool _S103 = penetration_0(&_S102, _S101, &d_4, &n_2);
            if(_S103)
            {
                pts_0[count_0] = _S101;
                nrm_0[count_0] = - n_2;
                dep_0[count_0] = d_4;
                idx_0[count_0] = 14U + s_1;
                count_0 = count_0 + 1U;
            }
            s_1 = s_1 + 1U;
        }
        if(count_0 > 0U)
        {
            float _S104 = (float4((&kernelContext_5)->contact_chunks_0[ca_0].mat_0) ).x;
            float _S105 = (float4((&kernelContext_5)->contact_chunks_0[cb_0].mat_0) ).x;
            float3 _S106 = _S92.center_1 - _S91.center_1;
            thread Box_0 _S107 = _S91;
            thread Box_0 _S108 = _S92;
            float _S109 = contact_stiffness_0(_S104, &_S107, _S105, &_S108, _S106);
            thread float3 va0_0;
            thread float3 wa0_0;
            chunk_velocity_0(ca_0, &va0_0, &wa0_0, &kernelContext_5);
            thread float3 vb0_0;
            thread float3 wb0_0;
            chunk_velocity_0(cb_0, &vb0_0, &wb0_0, &kernelContext_5);
            thread array<float, int(28)> eff_0;
            uint j_0 = 0U;
            uint inside_mask_0 = 0U;
            uint engaged_0 = 0U;
            for(;;)
            {
                if(j_0 < count_0)
                {
                }
                else
                {
                    break;
                }
                uint inside_mask_1 = inside_mask_0 | (1U << idx_0[j_0]);
                uint _S110 = _S78 + idx_0[j_0];
                float4 _S111 = float4(*((&kernelContext_5)->contact_state_0+_S110)) ;
                thread float4 entry_0 = _S111;
                float3 p_1 = pts_0[j_0];
                float3 n_3 = nrm_0[j_0];
                if(isnan(_S111.x))
                {
                    has_state_0 = true;
                }
                else
                {
                    has_state_0 = (dot(entry_0.yzw, n_3)) < 0.99000000953674316f;
                }
                if(has_state_0)
                {
                    if((dep_0[j_0]) > (2.0f * abs(dot(va0_0 + cross(wa0_0, p_1) - (vb0_0 + cross(wb0_0, p_1 - _S92.center_1)), n_3)) * _S81 + 9.99999971718068537e-10f))
                    {
                        stored_sum_0 = dep_0[j_0];
                    }
                    else
                    {
                        stored_sum_0 = 0.0f;
                    }
                    entry_0 = float4(stored_sum_0, n_3);
                }
                entry_0.x = min(entry_0.x, dep_0[j_0]);
                *((&kernelContext_5)->contact_state_0+_S110) = packed_float4(entry_0) ;
                float _S112 = dep_0[j_0] - entry_0.x;
                eff_0[j_0] = _S112;
                if(_S112 > 0.0f)
                {
                    engaged_0 = engaged_0 + 1U;
                }
                j_0 = j_0 + 1U;
                inside_mask_0 = inside_mask_1;
            }
            e_0 = 0U;
            for(;;)
            {
                if(e_0 < 28U)
                {
                }
                else
                {
                    break;
                }
                if((inside_mask_0 & (1U << e_0)) == 0U)
                {
                    *((&kernelContext_5)->contact_state_0+(_S78 + e_0)) = packed_float4(float4((as_type<float>((2143289344U))), 0.0f, 0.0f, 0.0f)) ;
                }
                e_0 = e_0 + 1U;
            }
            float _S113 = _S109 / max(float(engaged_0), 10.0f);
            j_0 = 0U;
            fa_0 = _S90;
            ta_0 = _S90;
            fb_0 = _S90;
            tb_0 = _S90;
            stored_sum_0 = 0.0f;
            for(;;)
            {
                if(j_0 < count_0)
                {
                }
                else
                {
                    break;
                }
                if((eff_0[j_0]) <= 0.0f)
                {
                    j_0 = j_0 + 1U;
                    continue;
                }
                float3 _S114 = pts_0[j_0] - _S92.center_1;
                thread float stored_1;
                thread float diss_0;
                float3 _S115 = penalty_force_0(_S113, _S79, _S80, eff_0[j_0], nrm_0[j_0], va0_0 + cross(wa0_0, pts_0[j_0]) - (vb0_0 + cross(wb0_0, _S114)), _S81, engaged_0, &stored_1, &diss_0, &kernelContext_5);
                float3 fa_1 = fa_0 + _S115;
                float3 ta_1 = ta_0 + cross(pts_0[j_0], _S115);
                float3 _S116 = - _S115;
                float3 fb_1 = fb_0 + _S116;
                float3 tb_1 = tb_0 + cross(_S114, _S116);
                float stored_sum_1 = stored_sum_0 + stored_1;
                thread float _S117 = ledger_1.y;
                thread float _S118 = ledger_1.z;
                comp_add1_0(&_S117, &_S118, diss_0);
                ledger_1.z = _S118;
                ledger_1.y = _S117;
                fa_0 = fa_1;
                ta_0 = ta_1;
                fb_0 = fb_1;
                tb_0 = tb_1;
                stored_sum_0 = stored_sum_1;
                j_0 = j_0 + 1U;
            }
            has_state_0 = true;
        }
        else
        {
            has_state_0 = false;
            fa_0 = _S90;
            ta_0 = _S90;
            fb_0 = _S90;
            tb_0 = _S90;
            stored_sum_0 = 0.0f;
        }
    }
    else
    {
        has_state_0 = false;
        fa_0 = _S90;
        ta_0 = _S90;
        fb_0 = _S90;
        tb_0 = _S90;
        stored_sum_0 = 0.0f;
    }
    bool loaded_0;
    if(!has_state_0)
    {
        loaded_0 = (flags_0 & 1U) != 0U;
    }
    else
    {
        loaded_0 = false;
    }
    if(loaded_0)
    {
        e_0 = 0U;
        for(;;)
        {
            if(e_0 < 28U)
            {
            }
            else
            {
                break;
            }
            *((&kernelContext_5)->contact_state_0+(_S78 + e_0)) = packed_float4(float4((as_type<float>((2143289344U))), 0.0f, 0.0f, 0.0f)) ;
            e_0 = e_0 + 1U;
        }
    }
    float3 _S119 = float3(0.0f) ;
    if(any(fa_0 != _S119))
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any(ta_0 != _S119);
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any(fb_0 != _S119);
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any(tb_0 != _S119);
    }
    bool _S120;
    if(loaded_0)
    {
        _S120 = true;
    }
    else
    {
        _S120 = (flags_0 & 2U) != 0U;
    }
    if(_S120)
    {
        uint _S121 = 2U * slot_0;
        *((&kernelContext_5)->contact_out_0+_S121) = packed_float4(float4(fa_0, 0.0f)) ;
        *((&kernelContext_5)->contact_out_0+(_S121 + 1U)) = packed_float4(float4(ta_0, 0.0f)) ;
        *((&kernelContext_5)->contact_out_0+(_S121 + 2U)) = packed_float4(float4(fb_0, 0.0f)) ;
        *((&kernelContext_5)->contact_out_0+(_S121 + 3U)) = packed_float4(float4(tb_0, 0.0f)) ;
    }
    ledger_1.x = stored_sum_0;
    if(has_state_0)
    {
        s_1 = 1U;
    }
    else
    {
        s_1 = 0U;
    }
    if(loaded_0)
    {
        count_0 = 2U;
    }
    else
    {
        count_0 = 0U;
    }
    ledger_1.w = (as_type<float>((s_1 | count_0)));
    *((&kernelContext_5)->contact_out_0+((&kernelContext_5)->params_0->ledger_base_0 + i_2)) = packed_float4(ledger_1) ;
    return;
}

struct Impactor_0
{
    float4 position_1;
    float4 position_err_1;
    float4 velocity_1;
    float4 velocity_err_1;
    float4 angular_velocity_1;
    float4 rotation_1;
    float4 inertia0_2;
    float4 inertia1_2;
    float4 inertia2_2;
    float4 inv0_2;
    float4 inv1_2;
    float4 inv2_2;
    float4 shape_0;
    float4 half_1;
    float4 mat_1;
    float4 crush_0;
    float4 load_force_0;
    float4 load_torque_0;
    float4 ledger_0;
    uint4 cand_0;
};

Box_0 impactor_box_0(const Impactor_0 thread* imp_0, float3 center_3, float3 half_3)
{
    Quat_0 q_7 = quat_of_0(imp_0->rotation_1);
    thread Box_0 b_8;
    (&b_8)->center_1 = center_3;
    float3 _S122 = float3(1.0f, 0.0f, 0.0f);
    thread Quat_0 _S123 = q_7;
    float3 _S124 = rotate_0(&_S123, _S122);
    (&b_8)->axis0_0 = _S124;
    float3 _S125 = float3(0.0f, 1.0f, 0.0f);
    thread Quat_0 _S126 = q_7;
    float3 _S127 = rotate_0(&_S126, _S125);
    (&b_8)->axis1_0 = _S127;
    float3 _S128 = float3(0.0f, 0.0f, 1.0f);
    thread Quat_0 _S129 = q_7;
    float3 _S130 = rotate_0(&_S129, _S128);
    (&b_8)->axis2_0 = _S130;
    (&b_8)->half_2 = half_3;
    return b_8;
}

bool sphere_contact_0(const Box_0 thread* b_9, float3 center_4, float radius_0, float3 thread* point_0, float3 thread* normal_2, float thread* depth_2)
{
    float3 _S131 = float3(0.0f) ;
    *point_0 = _S131;
    *normal_2 = _S131;
    *depth_2 = 0.0f;
    float3 _S132 = b_9->center_1;
    float3 r_2 = center_4 - b_9->center_1;
    float3 _S133 = b_9->axis0_0;
    float3 _S134 = b_9->axis1_0;
    float3 _S135 = b_9->axis2_0;
    float3 local_1 = float3(dot(r_2, b_9->axis0_0), dot(r_2, b_9->axis1_0), dot(r_2, b_9->axis2_0));
    float3 q_8 = clamp(local_1, - b_9->half_2, b_9->half_2);
    float3 d_5 = local_1 - q_8;
    float dist_0 = length(d_5);
    if(dist_0 > 9.999999960041972e-13f)
    {
        if(dist_0 >= radius_0)
        {
            return false;
        }
        float3 dn_0 = d_5 / float3(dist_0) ;
        *normal_2 = _S133 * float3(dn_0.x)  + _S134 * float3(dn_0.y)  + _S135 * float3(dn_0.z) ;
        *point_0 = _S132 + _S133 * float3(q_8.x)  + _S134 * float3(q_8.y)  + _S135 * float3(q_8.z) ;
        *depth_2 = radius_0 - dist_0;
        return true;
    }
    thread float inside_0;
    thread float3 n_4;
    bool _S136 = penetration_0(b_9, center_4, &inside_0, &n_4);
    if(!_S136)
    {
        return false;
    }
    *normal_2 = n_4;
    *point_0 = center_4 - n_4 * float3(min(radius_0, inside_0)) ;
    *depth_2 = radius_0 + inside_0;
    return true;
}

WorldPoint_0 impactor_point_0(uint _S137, KernelContext_0 thread* kernelContext_6)
{
    Impactor_natural_0 device* _S138 = kernelContext_6->impactors_0+_S137;
    thread WorldPoint_0 wi_0;
    (&wi_0)->hi_0 = (float4(_S138->position_1) ).xyz;
    (&wi_0)->lo_0 = (float4(_S138->position_err_1) ).xyz;
    (&wi_0)->rel_0 = float3(0.0f) ;
    return wi_0;
}

Box_0 impactor_box_1(uint _S139, float3 _S140, float3 _S141, KernelContext_0 thread* kernelContext_7)
{
    Quat_0 q_9 = quat_of_0(float4((kernelContext_7->impactors_0+_S139)->rotation_1) );
    thread Box_0 b_10;
    (&b_10)->center_1 = _S140;
    float3 _S142 = float3(1.0f, 0.0f, 0.0f);
    thread Quat_0 _S143 = q_9;
    float3 _S144 = rotate_0(&_S143, _S142);
    (&b_10)->axis0_0 = _S144;
    float3 _S145 = float3(0.0f, 1.0f, 0.0f);
    thread Quat_0 _S146 = q_9;
    float3 _S147 = rotate_0(&_S146, _S145);
    (&b_10)->axis1_0 = _S147;
    float3 _S148 = float3(0.0f, 0.0f, 1.0f);
    thread Quat_0 _S149 = q_9;
    float3 _S150 = rotate_0(&_S149, _S148);
    (&b_10)->axis2_0 = _S150;
    (&b_10)->half_2 = _S141;
    return b_10;
}

uint impactor_points_0(uint _S151, float _S152, const Box_0 thread* _S153, const Box_0 thread* _S154, array<float3, int(28)> thread* _S155, array<float3, int(28)> thread* _S156, array<float, int(28)> thread* _S157, KernelContext_0 thread* kernelContext_8)
{
    float4 _S158 = float4((kernelContext_8->impactors_0+_S151)->shape_0) ;
    uint count_1;
    if((_S158.x) == 0.0f)
    {
        thread float3 p_2;
        thread float3 n_5;
        thread float d_6;
        bool _S159 = sphere_contact_0(_S154, float3(0.0f) , _S158.y - _S152, &p_2, &n_5, &d_6);
        if(_S159)
        {
            (*_S155)[int(0)] = p_2;
            (*_S156)[int(0)] = - n_5;
            (*_S157)[int(0)] = d_6;
            count_1 = 1U;
        }
        else
        {
            count_1 = 0U;
        }
        return count_1;
    }
    thread Box_0 shrunk_0 = *_S153;
    (&shrunk_0)->half_2 = _S153->half_2 - min(float3(_S152) , _S153->half_2 * float3(0.5f) );
    uint s_2 = 0U;
    count_1 = 0U;
    for(;;)
    {
        if(s_2 < 14U)
        {
        }
        else
        {
            break;
        }
        float3 _S160 = sample_point_0(_S154, s_2);
        thread Box_0 _S161 = shrunk_0;
        thread float d_7;
        thread float3 n_6;
        bool _S162 = penetration_0(&_S161, _S160, &d_7, &n_6);
        if(_S162)
        {
            (*_S155)[count_1] = _S160;
            (*_S156)[count_1] = n_6;
            (*_S157)[count_1] = d_7;
            count_1 = count_1 + 1U;
        }
        s_2 = s_2 + 1U;
    }
    s_2 = 0U;
    for(;;)
    {
        if(s_2 < 14U)
        {
        }
        else
        {
            break;
        }
        thread Box_0 _S163 = shrunk_0;
        float3 _S164 = sample_point_0(&_S163, s_2);
        thread float d_8;
        thread float3 n_7;
        bool _S165 = penetration_0(_S154, _S164, &d_8, &n_7);
        if(_S165)
        {
            (*_S155)[count_1] = _S164;
            (*_S156)[count_1] = - n_7;
            (*_S157)[count_1] = d_8;
            count_1 = count_1 + 1U;
        }
        s_2 = s_2 + 1U;
    }
    return count_1;
}

[[kernel]] void impactor_candidates(uint3 id_1 [[thread_position_in_grid]], ContactParams_0 constant* params_2 [[buffer(0)]], Island_natural_0 device* islands_2 [[buffer(4)]], packed_uint4 device* contact_static_2 [[buffer(5)]], ChunkStatic_natural_0 device* chunks_2 [[buffer(1)]], packed_float4 device* state_2 [[buffer(3)]], ContactChunk_natural_0 device* contact_chunks_2 [[buffer(2)]], packed_float4 device* contact_out_2 [[buffer(8)]], packed_float4 device* contact_state_2 [[buffer(6)]], Impactor_natural_0 device* impactors_2 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_9;
    (&kernelContext_9)->params_0 = params_2;
    (&kernelContext_9)->islands_0 = islands_2;
    (&kernelContext_9)->contact_static_0 = contact_static_2;
    (&kernelContext_9)->chunks_0 = chunks_2;
    (&kernelContext_9)->state_0 = state_2;
    (&kernelContext_9)->contact_chunks_0 = contact_chunks_2;
    (&kernelContext_9)->contact_out_0 = contact_out_2;
    (&kernelContext_9)->contact_state_0 = contact_state_2;
    (&kernelContext_9)->impactors_0 = impactors_2;
    threadgroup array<float4, int(256)> g_red_a_2;
    (&kernelContext_9)->g_red_a_0 = &g_red_a_2;
    threadgroup array<float4, int(256)> g_red_b_2;
    (&kernelContext_9)->g_red_b_0 = &g_red_b_2;
    uint _S166 = id_1.x;
    bool _S167;
    if(_S166 >= (params_2->cand_count_0))
    {
        _S167 = true;
    }
    else
    {
        bool _S168 = stopped_0(&kernelContext_9);
        _S167 = _S168;
    }
    if(_S167)
    {
        return;
    }
    uint4 _S169 = uint4(*((&kernelContext_9)->contact_static_0+((&kernelContext_9)->params_0->cand_begin_0 + _S166))) ;
    uint c_4 = _S169.x;
    uint _S170 = _S169.z;
    Impactor_natural_0 device* _S171 = (&kernelContext_9)->impactors_0+_S170;
    Impactor_natural_0 imp_1 = *_S171;
    float total_0;
    float ksum_0;
    if(((uint4((*_S171).cand_0) ).z) == 0U)
    {
        WorldPoint_0 _S172 = chunk_world_0(c_4, &kernelContext_9);
        WorldPoint_0 _S173 = impactor_point_0(_S170, &kernelContext_9);
        thread WorldPoint_0 _S174 = _S172;
        thread WorldPoint_0 _S175 = _S173;
        float3 _S176 = world_diff_0(&_S174, &_S175);
        float4 _S177 = float4(imp_1.half_1) ;
        if(!((length(_S176)) > (_S177.w + (float4((&kernelContext_9)->contact_chunks_0[c_4].half_0) ).w)))
        {
            Box_0 _S178 = impactor_box_1(_S170, float3(0.0f) , _S177.xyz, &kernelContext_9);
            Box_0 _S179 = chunk_box_0(c_4, _S176, &kernelContext_9);
            float _S180 = (float4(imp_1.mat_1) ).x;
            float _S181 = (float4((&kernelContext_9)->contact_chunks_0[c_4].mat_0) ).x;
            float3 _S182 = _S179.center_1 - _S178.center_1;
            thread Box_0 _S183 = _S178;
            thread Box_0 _S184 = _S179;
            float _S185 = contact_stiffness_0(_S180, &_S183, _S181, &_S184, _S182);
            float _S186 = (float4(imp_1.crush_0) ).w;
            thread Box_0 _S187 = _S178;
            thread Box_0 _S188 = _S179;
            thread array<float3, int(28)> pts_1;
            thread array<float3, int(28)> nrm_1;
            thread array<float, int(28)> dep_1;
            uint _S189 = impactor_points_0(_S170, _S186, &_S187, &_S188, &pts_1, &nrm_1, &dep_1, &kernelContext_9);
            float _S190;
            if(((float4(imp_1.shape_0) ).x) == 0.0f)
            {
                _S190 = _S185;
            }
            else
            {
                _S190 = _S185 / max(float(_S189), 10.0f);
            }
            uint j_1 = 0U;
            total_0 = 0.0f;
            ksum_0 = 0.0f;
            for(;;)
            {
                if(j_1 < _S189)
                {
                }
                else
                {
                    break;
                }
                float total_1 = total_0 + _S190 * dep_1[j_1];
                float ksum_1 = ksum_0 + _S190;
                j_1 = j_1 + 1U;
                total_0 = total_1;
                ksum_0 = ksum_1;
            }
        }
        else
        {
            total_0 = 0.0f;
            ksum_0 = 0.0f;
        }
    }
    else
    {
        total_0 = 0.0f;
        ksum_0 = 0.0f;
    }
    uint _S191 = 3U * _S166;
    float4 _S192 = float4(*((&kernelContext_9)->contact_out_0+((&kernelContext_9)->params_0->cand_base_0 + _S191))) ;
    *((&kernelContext_9)->contact_out_0+((&kernelContext_9)->params_0->cand_base_0 + _S191)) = packed_float4(float4(total_0, ksum_0, _S192.z, _S192.w)) ;
    return;
}

void group_sum2_0(uint tid_0, float4 thread* a_4, float4 thread* b_11, KernelContext_0 thread* kernelContext_10)
{
    (*kernelContext_10->g_red_a_0)[tid_0] = *a_4;
    (*kernelContext_10->g_red_b_0)[tid_0] = *b_11;
    threadgroup_barrier(mem_flags::mem_threadgroup);
    uint s_3 = 128U;
    for(;;)
    {
        if(s_3 > 0U)
        {
        }
        else
        {
            break;
        }
        if(tid_0 < s_3)
        {
            uint _S193 = tid_0 + s_3;
            (*kernelContext_10->g_red_a_0)[tid_0] = (*kernelContext_10->g_red_a_0)[tid_0] + (*kernelContext_10->g_red_a_0)[_S193];
            (*kernelContext_10->g_red_b_0)[tid_0] = (*kernelContext_10->g_red_b_0)[tid_0] + (*kernelContext_10->g_red_b_0)[_S193];
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);
        s_3 = s_3 >> 1U;
    }
    *a_4 = (*kernelContext_10->g_red_a_0)[int(0)];
    *b_11 = (*kernelContext_10->g_red_b_0)[int(0)];
    threadgroup_barrier(mem_flags::mem_threadgroup);
    return;
}

[[kernel]] void contact_impactors(uint3 group_0 [[threadgroup_position_in_grid]], uint3 thread_0 [[thread_position_in_threadgroup]], ContactParams_0 constant* params_3 [[buffer(0)]], Island_natural_0 device* islands_3 [[buffer(4)]], packed_uint4 device* contact_static_3 [[buffer(5)]], ChunkStatic_natural_0 device* chunks_3 [[buffer(1)]], packed_float4 device* state_3 [[buffer(3)]], ContactChunk_natural_0 device* contact_chunks_3 [[buffer(2)]], packed_float4 device* contact_out_3 [[buffer(8)]], packed_float4 device* contact_state_3 [[buffer(6)]], Impactor_natural_0 device* impactors_3 [[buffer(7)]])
{
    float3 p_3;
    thread KernelContext_0 kernelContext_11;
    (&kernelContext_11)->params_0 = params_3;
    (&kernelContext_11)->islands_0 = islands_3;
    (&kernelContext_11)->contact_static_0 = contact_static_3;
    (&kernelContext_11)->chunks_0 = chunks_3;
    (&kernelContext_11)->state_0 = state_3;
    (&kernelContext_11)->contact_chunks_0 = contact_chunks_3;
    (&kernelContext_11)->contact_out_0 = contact_out_3;
    (&kernelContext_11)->contact_state_0 = contact_state_3;
    (&kernelContext_11)->impactors_0 = impactors_3;
    threadgroup array<float4, int(256)> g_red_a_3;
    (&kernelContext_11)->g_red_a_0 = &g_red_a_3;
    threadgroup array<float4, int(256)> g_red_b_3;
    (&kernelContext_11)->g_red_b_0 = &g_red_b_3;
    uint ii_0 = group_0.x;
    uint tid_1 = thread_0.x;
    bool _S194;
    if(ii_0 >= (params_3->impactor_count_0))
    {
        _S194 = true;
    }
    else
    {
        bool _S195 = stopped_0(&kernelContext_11);
        _S194 = _S195;
    }
    if(_S194)
    {
        return;
    }
    Impactor_natural_0 device* _S196 = (&kernelContext_11)->impactors_0+ii_0;
    float4 _S197 = float4((*_S196).position_err_1) ;
    float4 _S198 = float4((*_S196).velocity_1) ;
    float4 _S199 = float4((*_S196).velocity_err_1) ;
    float4 _S200 = float4((*_S196).angular_velocity_1) ;
    float4 _S201 = float4((*_S196).rotation_1) ;
    float4 _S202 = float4((*_S196).inertia0_2) ;
    float4 _S203 = float4((*_S196).inertia1_2) ;
    float4 _S204 = float4((*_S196).inertia2_2) ;
    float4 _S205 = float4((*_S196).inv0_2) ;
    float4 _S206 = float4((*_S196).inv1_2) ;
    float4 _S207 = float4((*_S196).inv2_2) ;
    float4 _S208 = float4((*_S196).shape_0) ;
    float4 _S209 = float4((*_S196).half_1) ;
    float4 _S210 = float4((*_S196).mat_1) ;
    float4 _S211 = float4((*_S196).crush_0) ;
    float4 _S212 = float4((*_S196).load_force_0) ;
    float4 _S213 = float4((*_S196).load_torque_0) ;
    float4 _S214 = float4((*_S196).ledger_0) ;
    uint4 _S215 = uint4((*_S196).cand_0) ;
    thread Impactor_0 imp_2;
    (&imp_2)->position_1 = float4((*_S196).position_1) ;
    (&imp_2)->position_err_1 = _S197;
    (&imp_2)->velocity_1 = _S198;
    (&imp_2)->velocity_err_1 = _S199;
    (&imp_2)->angular_velocity_1 = _S200;
    (&imp_2)->rotation_1 = _S201;
    (&imp_2)->inertia0_2 = _S202;
    (&imp_2)->inertia1_2 = _S203;
    (&imp_2)->inertia2_2 = _S204;
    (&imp_2)->inv0_2 = _S205;
    (&imp_2)->inv1_2 = _S206;
    (&imp_2)->inv2_2 = _S207;
    (&imp_2)->shape_0 = _S208;
    (&imp_2)->half_1 = _S209;
    (&imp_2)->mat_1 = _S210;
    (&imp_2)->crush_0 = _S211;
    (&imp_2)->load_force_0 = _S212;
    (&imp_2)->load_torque_0 = _S213;
    (&imp_2)->ledger_0 = _S214;
    (&imp_2)->cand_0 = _S215;
    float4 _S216 = float4(0.0f) ;
    thread float4 shares_0 = _S216;
    thread float4 unused_0 = _S216;
    uint e_1 = (&imp_2)->cand_0.x + tid_1;
    for(;;)
    {
        if(e_1 < ((&imp_2)->cand_0.y))
        {
        }
        else
        {
            break;
        }
        shares_0 = shares_0 + float4(*((&kernelContext_11)->contact_out_0+((&kernelContext_11)->params_0->cand_base_0 + 3U * (e_1 - (&kernelContext_11)->params_0->cand_begin_0)))) ;
        e_1 = e_1 + 256U;
    }
    group_sum2_0(tid_1, &shares_0, &unused_0, &kernelContext_11);
    if(tid_1 != 0U)
    {
        return;
    }
    float _S217 = (&kernelContext_11)->params_0->dt_0;
    float3 _S218 = float3(0.0f) ;
    float depth_at_start_0 = (&imp_2)->crush_0.w;
    float crush_factor_0;
    float3 load_f_0;
    float3 load_t_0;
    if(((&imp_2)->cand_0.z) == 0U)
    {
        float total_2 = shares_0.x;
        float ksum_2 = shares_0.y;
        if(((&imp_2)->crush_0.x) > 0.0f)
        {
            _S194 = ((&imp_2)->crush_0.z) < ((&imp_2)->crush_0.y);
        }
        else
        {
            _S194 = false;
        }
        if(_S194)
        {
            _S194 = total_2 > ((&imp_2)->crush_0.x);
        }
        else
        {
            _S194 = false;
        }
        if(_S194)
        {
            float extra_0 = (total_2 - (&imp_2)->crush_0.x) / ksum_2;
            (&imp_2)->crush_0.w = (&imp_2)->crush_0.w + extra_0;
            (&imp_2)->crush_0.z = (&imp_2)->crush_0.z + (&imp_2)->crush_0.x * extra_0;
            float _S219 = (&imp_2)->crush_0.x * extra_0;
            thread float _S220 = (&imp_2)->ledger_0.z;
            thread float _S221 = (&imp_2)->ledger_0.w;
            comp_add1_0(&_S220, &_S221, _S219);
            (&imp_2)->ledger_0.w = _S221;
            (&imp_2)->ledger_0.z = _S220;
            float _S222 = (&imp_2)->crush_0.x * extra_0;
            thread float _S223 = (&imp_2)->ledger_0.x;
            thread float _S224 = (&imp_2)->ledger_0.y;
            comp_add1_0(&_S223, &_S224, _S222);
            (&imp_2)->ledger_0.y = _S224;
            (&imp_2)->ledger_0.x = _S223;
            crush_factor_0 = (&imp_2)->crush_0.x / total_2;
        }
        else
        {
            crush_factor_0 = 1.0f;
        }
        if(((&kernelContext_11)->params_0->has_ground_0) != 0U)
        {
            float3 _S225 = (&imp_2)->half_1.xyz;
            thread Impactor_0 _S226 = imp_2;
            Box_0 _S227 = impactor_box_0(&_S226, _S218, _S225);
            float3 _S228 = (&imp_2)->velocity_1.xyz + (&imp_2)->velocity_err_1.xyz;
            float _S229 = (&kernelContext_11)->params_0->ground_modulus_0;
            float _S230 = (&imp_2)->mat_1.x;
            float3 _S231 = float3(0.0f, 0.0f, 1.0f);
            thread Box_0 _S232 = _S227;
            thread Box_0 _S233 = _S227;
            float _S234 = contact_stiffness_0(_S229, &_S232, _S230, &_S233, _S231);
            float _S235 = (&imp_2)->position_1.z - (&kernelContext_11)->params_0->ground_hi_0 + ((&imp_2)->position_err_1.z - (&kernelContext_11)->params_0->ground_lo_0);
            uint total_points_0;
            if(((&imp_2)->shape_0.x) == 0.0f)
            {
                total_points_0 = 1U;
            }
            else
            {
                total_points_0 = 14U;
            }
            float _S236 = _S234 / float(min(total_points_0, 5U));
            uint s_4 = 0U;
            uint below_0 = 0U;
            for(;;)
            {
                if(s_4 < total_points_0)
                {
                }
                else
                {
                    break;
                }
                if(((&imp_2)->shape_0.x) == 0.0f)
                {
                    p_3 = float3(0.0f, 0.0f, - (&imp_2)->shape_0.y);
                }
                else
                {
                    thread Box_0 _S237 = _S227;
                    float3 _S238 = sample_point_0(&_S237, s_4);
                    p_3 = _S238;
                }
                if((_S235 + p_3.z) < 0.0f)
                {
                    below_0 = below_0 + 1U;
                }
                s_4 = s_4 + 1U;
            }
            s_4 = 0U;
            load_f_0 = _S218;
            load_t_0 = _S218;
            for(;;)
            {
                if(s_4 < total_points_0)
                {
                }
                else
                {
                    break;
                }
                if(((&imp_2)->shape_0.x) == 0.0f)
                {
                    p_3 = float3(0.0f, 0.0f, - (&imp_2)->shape_0.y);
                }
                else
                {
                    thread Box_0 _S239 = _S227;
                    float3 _S240 = sample_point_0(&_S239, s_4);
                    p_3 = _S240;
                }
                float depth_3 = - (_S235 + p_3.z);
                if(depth_3 <= 0.0f)
                {
                    s_4 = s_4 + 1U;
                    continue;
                }
                thread float stored_2;
                thread float diss_1;
                float3 _S241 = penalty_force_0(_S236, (&imp_2)->mat_1.z, (&kernelContext_11)->params_0->ground_friction_0, depth_3, _S231, _S228 + cross((&imp_2)->angular_velocity_1.xyz, p_3), _S217, below_0, &stored_2, &diss_1, &kernelContext_11);
                float3 load_f_1 = load_f_0 + _S241;
                float3 load_t_1 = load_t_0 + cross(p_3, _S241);
                thread float _S242 = (&imp_2)->ledger_0.x;
                thread float _S243 = (&imp_2)->ledger_0.y;
                comp_add1_0(&_S242, &_S243, diss_1);
                (&imp_2)->ledger_0.y = _S243;
                (&imp_2)->ledger_0.x = _S242;
                load_f_0 = load_f_1;
                load_t_0 = load_t_1;
                s_4 = s_4 + 1U;
            }
        }
        else
        {
            load_f_0 = _S218;
            load_t_0 = _S218;
        }
    }
    else
    {
        crush_factor_0 = 1.0f;
        load_f_0 = _S218;
        load_t_0 = _S218;
    }
    (&imp_2)->load_force_0 = float4(load_f_0, crush_factor_0);
    (&imp_2)->load_torque_0 = float4(load_t_0, depth_at_start_0);
    Impactor_natural_0 device* _S244 = (&kernelContext_11)->impactors_0+ii_0;
    _S244->position_1 = packed_float4(imp_2.position_1) ;
    _S244->position_err_1 = packed_float4(imp_2.position_err_1) ;
    _S244->velocity_1 = packed_float4(imp_2.velocity_1) ;
    _S244->velocity_err_1 = packed_float4(imp_2.velocity_err_1) ;
    _S244->angular_velocity_1 = packed_float4(imp_2.angular_velocity_1) ;
    _S244->rotation_1 = packed_float4(imp_2.rotation_1) ;
    _S244->inertia0_2 = packed_float4(imp_2.inertia0_2) ;
    _S244->inertia1_2 = packed_float4(imp_2.inertia1_2) ;
    _S244->inertia2_2 = packed_float4(imp_2.inertia2_2) ;
    _S244->inv0_2 = packed_float4(imp_2.inv0_2) ;
    _S244->inv1_2 = packed_float4(imp_2.inv1_2) ;
    _S244->inv2_2 = packed_float4(imp_2.inv2_2) ;
    _S244->shape_0 = packed_float4(imp_2.shape_0) ;
    _S244->half_1 = packed_float4(imp_2.half_1) ;
    _S244->mat_1 = packed_float4(imp_2.mat_1) ;
    _S244->crush_0 = packed_float4(imp_2.crush_0) ;
    _S244->load_force_0 = packed_float4(imp_2.load_force_0) ;
    _S244->load_torque_0 = packed_float4(imp_2.load_torque_0) ;
    _S244->ledger_0 = packed_float4(imp_2.ledger_0) ;
    _S244->cand_0 = packed_uint4(imp_2.cand_0) ;
    return;
}

[[kernel]] void impactor_forces(uint3 id_2 [[thread_position_in_grid]], ContactParams_0 constant* params_4 [[buffer(0)]], Island_natural_0 device* islands_4 [[buffer(4)]], packed_uint4 device* contact_static_4 [[buffer(5)]], ChunkStatic_natural_0 device* chunks_4 [[buffer(1)]], packed_float4 device* state_4 [[buffer(3)]], ContactChunk_natural_0 device* contact_chunks_4 [[buffer(2)]], packed_float4 device* contact_out_4 [[buffer(8)]], packed_float4 device* contact_state_4 [[buffer(6)]], Impactor_natural_0 device* impactors_4 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_12;
    (&kernelContext_12)->params_0 = params_4;
    (&kernelContext_12)->islands_0 = islands_4;
    (&kernelContext_12)->contact_static_0 = contact_static_4;
    (&kernelContext_12)->chunks_0 = chunks_4;
    (&kernelContext_12)->state_0 = state_4;
    (&kernelContext_12)->contact_chunks_0 = contact_chunks_4;
    (&kernelContext_12)->contact_out_0 = contact_out_4;
    (&kernelContext_12)->contact_state_0 = contact_state_4;
    (&kernelContext_12)->impactors_0 = impactors_4;
    threadgroup array<float4, int(256)> g_red_a_4;
    (&kernelContext_12)->g_red_a_0 = &g_red_a_4;
    threadgroup array<float4, int(256)> g_red_b_4;
    (&kernelContext_12)->g_red_b_0 = &g_red_b_4;
    uint _S245 = id_2.x;
    bool _S246;
    if(_S245 >= (params_4->cand_count_0))
    {
        _S246 = true;
    }
    else
    {
        bool _S247 = stopped_0(&kernelContext_12);
        _S246 = _S247;
    }
    if(_S246)
    {
        return;
    }
    uint4 _S248 = uint4(*((&kernelContext_12)->contact_static_0+((&kernelContext_12)->params_0->cand_begin_0 + _S245))) ;
    uint c_5 = _S248.x;
    uint slot_1 = _S248.y;
    uint _S249 = _S248.z;
    Impactor_natural_0 device* _S250 = (&kernelContext_12)->impactors_0+_S249;
    Impactor_natural_0 imp_3 = *_S250;
    float _S251 = (&kernelContext_12)->params_0->dt_0;
    float3 _S252 = float3(0.0f) ;
    uint _S253 = 3U * _S245;
    thread float4 scratch_0 = float4(*((&kernelContext_12)->contact_out_0+((&kernelContext_12)->params_0->cand_base_0 + _S253))) ;
    float3 f_sum_0;
    float3 t_sum_0;
    float3 imp_f_0;
    float3 imp_t_0;
    if(((uint4((*_S250).cand_0) ).z) == 0U)
    {
        WorldPoint_0 _S254 = chunk_world_0(c_5, &kernelContext_12);
        WorldPoint_0 _S255 = impactor_point_0(_S249, &kernelContext_12);
        thread WorldPoint_0 _S256 = _S254;
        thread WorldPoint_0 _S257 = _S255;
        float3 _S258 = world_diff_0(&_S256, &_S257);
        float4 _S259 = float4(imp_3.half_1) ;
        if(!((length(_S258)) > (_S259.w + (float4((&kernelContext_12)->contact_chunks_0[c_5].half_0) ).w)))
        {
            Box_0 _S260 = impactor_box_1(_S249, _S252, _S259.xyz, &kernelContext_12);
            Box_0 _S261 = chunk_box_0(c_5, _S258, &kernelContext_12);
            float4 _S262 = float4(imp_3.mat_1) ;
            float _S263 = _S262.x;
            float _S264 = (float4((&kernelContext_12)->contact_chunks_0[c_5].mat_0) ).x;
            float3 _S265 = _S261.center_1 - _S260.center_1;
            thread Box_0 _S266 = _S260;
            thread Box_0 _S267 = _S261;
            float _S268 = contact_stiffness_0(_S263, &_S266, _S264, &_S267, _S265);
            float _S269 = (float4(imp_3.load_torque_0) ).w;
            thread Box_0 _S270 = _S260;
            thread Box_0 _S271 = _S261;
            thread array<float3, int(28)> pts_2;
            thread array<float3, int(28)> nrm_2;
            thread array<float, int(28)> dep_2;
            uint _S272 = impactor_points_0(_S249, _S269, &_S270, &_S271, &pts_2, &nrm_2, &dep_2, &kernelContext_12);
            bool _S273 = ((float4(imp_3.shape_0) ).x) == 0.0f;
            float _S274;
            if(_S273)
            {
                _S274 = _S268;
            }
            else
            {
                _S274 = _S268 / max(float(_S272), 10.0f);
            }
            uint _S275;
            if(_S273)
            {
                _S275 = 1U;
            }
            else
            {
                _S275 = _S272;
            }
            float m_0 = (float4((&kernelContext_12)->contact_chunks_0[c_5].mat_0) ).z;
            float _S276 = _S262.z;
            float _S277 = m_0 * _S276 / (m_0 + _S276);
            float _S278;
            if(((&kernelContext_12)->params_0->pair_friction_0) >= 0.0f)
            {
                _S278 = (&kernelContext_12)->params_0->pair_friction_0;
            }
            else
            {
                _S278 = min(_S262.y, (float4((&kernelContext_12)->contact_chunks_0[c_5].mat_0) ).y);
            }
            float3 _S279 = (float4(imp_3.velocity_1) ).xyz + (float4(imp_3.velocity_err_1) ).xyz;
            float _S280 = (float4(imp_3.load_force_0) ).w;
            thread float3 vc_0;
            thread float3 wc_0;
            chunk_velocity_0(c_5, &vc_0, &wc_0, &kernelContext_12);
            uint j_2 = 0U;
            f_sum_0 = _S252;
            t_sum_0 = _S252;
            imp_f_0 = _S252;
            imp_t_0 = _S252;
            for(;;)
            {
                if(j_2 < _S272)
                {
                }
                else
                {
                    break;
                }
                float3 _S281 = pts_2[j_2] - _S261.center_1;
                thread float stored_3;
                thread float diss_2;
                float3 _S282 = penalty_force_0(_S274, _S277, _S278, dep_2[j_2] * _S280, nrm_2[j_2], vc_0 + cross(wc_0, _S281) - (_S279 + cross((float4(imp_3.angular_velocity_1) ).xyz, pts_2[j_2])), _S251, _S275, &stored_3, &diss_2, &kernelContext_12);
                float3 f_sum_1 = f_sum_0 + _S282;
                float3 t_sum_1 = t_sum_0 + cross(_S281, _S282);
                float3 imp_f_1 = imp_f_0 - _S282;
                float3 imp_t_1 = imp_t_0 - cross(pts_2[j_2], _S282);
                thread float _S283 = scratch_0.z;
                thread float _S284 = scratch_0.w;
                comp_add1_0(&_S283, &_S284, diss_2);
                scratch_0.w = _S284;
                scratch_0.z = _S283;
                j_2 = j_2 + 1U;
                f_sum_0 = f_sum_1;
                t_sum_0 = t_sum_1;
                imp_f_0 = imp_f_1;
                imp_t_0 = imp_t_1;
            }
        }
        else
        {
            f_sum_0 = _S252;
            t_sum_0 = _S252;
            imp_f_0 = _S252;
            imp_t_0 = _S252;
        }
    }
    else
    {
        f_sum_0 = _S252;
        t_sum_0 = _S252;
        imp_f_0 = _S252;
        imp_t_0 = _S252;
    }
    uint _S285 = 2U * slot_1;
    *((&kernelContext_12)->contact_out_0+_S285) = packed_float4(float4(f_sum_0, 0.0f)) ;
    *((&kernelContext_12)->contact_out_0+(_S285 + 1U)) = packed_float4(float4(t_sum_0, 0.0f)) ;
    *((&kernelContext_12)->contact_out_0+((&kernelContext_12)->params_0->cand_base_0 + _S253)) = packed_float4(scratch_0) ;
    *((&kernelContext_12)->contact_out_0+((&kernelContext_12)->params_0->cand_base_0 + _S253 + 1U)) = packed_float4(float4(imp_f_0, 0.0f)) ;
    *((&kernelContext_12)->contact_out_0+((&kernelContext_12)->params_0->cand_base_0 + _S253 + 2U)) = packed_float4(float4(imp_t_0, 0.0f)) ;
    return;
}

[[kernel]] void contact_gather(uint3 id_3 [[thread_position_in_grid]], ContactParams_0 constant* params_5 [[buffer(0)]], Island_natural_0 device* islands_5 [[buffer(4)]], packed_uint4 device* contact_static_5 [[buffer(5)]], ChunkStatic_natural_0 device* chunks_5 [[buffer(1)]], packed_float4 device* state_5 [[buffer(3)]], ContactChunk_natural_0 device* contact_chunks_5 [[buffer(2)]], packed_float4 device* contact_out_5 [[buffer(8)]], packed_float4 device* contact_state_5 [[buffer(6)]], Impactor_natural_0 device* impactors_5 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_13;
    (&kernelContext_13)->params_0 = params_5;
    (&kernelContext_13)->islands_0 = islands_5;
    (&kernelContext_13)->contact_static_0 = contact_static_5;
    (&kernelContext_13)->chunks_0 = chunks_5;
    (&kernelContext_13)->state_0 = state_5;
    (&kernelContext_13)->contact_chunks_0 = contact_chunks_5;
    (&kernelContext_13)->contact_out_0 = contact_out_5;
    (&kernelContext_13)->contact_state_0 = contact_state_5;
    (&kernelContext_13)->impactors_0 = impactors_5;
    threadgroup array<float4, int(256)> g_red_a_5;
    (&kernelContext_13)->g_red_a_0 = &g_red_a_5;
    threadgroup array<float4, int(256)> g_red_b_5;
    (&kernelContext_13)->g_red_b_0 = &g_red_b_5;
    uint c_6 = id_3.x;
    bool _S286;
    if(c_6 >= (params_5->chunk_count_0))
    {
        _S286 = true;
    }
    else
    {
        bool _S287 = stopped_0(&kernelContext_13);
        _S286 = _S287;
    }
    if(_S286)
    {
        return;
    }
    ContactChunk_natural_0 cc_1 = (&kernelContext_13)->contact_chunks_0[c_6];
    uint4 _S288 = uint4(cc_1.info_2) ;
    if(((_S288.z) & 1U) == 0U)
    {
        return;
    }
    WorldPoint_0 _S289 = chunk_world_0(c_6, &kernelContext_13);
    float4 _S290 = float4(cc_1.start_hi_0) ;
    if((length(_S289.hi_0 - _S290.xyz + (_S289.lo_0 - (float4(cc_1.start_lo_0) ).xyz) + _S289.rel_0)) > (_S290.w))
    {
        ((&kernelContext_13)->islands_0+(&kernelContext_13)->params_0->halt_index_0)->info_0[int(2)] = ((uint4(((&kernelContext_13)->islands_0+(&kernelContext_13)->params_0->halt_index_0)->info_0) ).z) | 1U;
        return;
    }
    float3 _S291 = float3(0.0f) ;
    thread float4 ledger_2 = float4(*((&kernelContext_13)->contact_out_0+((&kernelContext_13)->params_0->ledger_base_0 + (&kernelContext_13)->params_0->pair_count_0 + c_6))) ;
    float _S292 = (&kernelContext_13)->params_0->dt_0;
    uint e_2 = _S288.x;
    float3 f_0 = _S291;
    float3 t_3 = _S291;
    for(;;)
    {
        if(e_2 < (_S288.y))
        {
        }
        else
        {
            break;
        }
        uint4 _S293 = uint4(*((&kernelContext_13)->contact_static_0+e_2)) ;
        float3 f_1;
        float3 t_4;
        if((_S293.x) == 0U)
        {
            uint _S294 = 2U * _S293.y;
            float3 t_5 = t_3 + (float4(*((&kernelContext_13)->contact_out_0+(_S294 + 1U))) ).xyz;
            f_1 = f_0 + (float4(*((&kernelContext_13)->contact_out_0+_S294)) ).xyz;
            t_4 = t_5;
            e_2 = e_2 + 1U;
            f_0 = f_1;
            t_3 = t_4;
            continue;
        }
        float above_0 = _S289.hi_0.z - (&kernelContext_13)->params_0->ground_hi_0 + (_S289.lo_0.z - (&kernelContext_13)->params_0->ground_lo_0) + _S289.rel_0.z;
        if((above_0 - (float4(cc_1.half_0) ).w) > 0.0f)
        {
            f_1 = f_0;
            t_4 = t_3;
            e_2 = e_2 + 1U;
            f_0 = f_1;
            t_3 = t_4;
            continue;
        }
        Box_0 _S295 = chunk_box_0(c_6, _S291, &kernelContext_13);
        float _S296 = (&kernelContext_13)->params_0->ground_modulus_0;
        float4 _S297 = float4(cc_1.mat_0) ;
        float _S298 = _S297.x;
        float3 _S299 = float3(0.0f, 0.0f, 1.0f);
        thread Box_0 _S300 = _S295;
        thread Box_0 _S301 = _S295;
        float _S302 = contact_stiffness_0(_S296, &_S300, _S298, &_S301, _S299);
        uint s_5 = 0U;
        uint n_8 = 0U;
        for(;;)
        {
            if(s_5 < 14U)
            {
            }
            else
            {
                break;
            }
            thread Box_0 _S303 = _S295;
            float3 _S304 = sample_point_0(&_S303, s_5);
            if((above_0 + _S304.z) < 0.0f)
            {
                n_8 = n_8 + 1U;
            }
            s_5 = s_5 + 1U;
        }
        thread float3 vc_1;
        thread float3 wc_1;
        chunk_velocity_0(c_6, &vc_1, &wc_1, &kernelContext_13);
        uint s_6 = 0U;
        f_1 = f_0;
        t_4 = t_3;
        for(;;)
        {
            if(s_6 < 14U)
            {
            }
            else
            {
                break;
            }
            thread Box_0 _S305 = _S295;
            float3 _S306 = sample_point_0(&_S305, s_6);
            float _S307 = above_0 + _S306.z;
            float depth_4 = - _S307;
            if(!(_S307 < 0.0f))
            {
                s_6 = s_6 + 1U;
                continue;
            }
            thread float stored_4;
            thread float diss_3;
            float3 _S308 = penalty_force_0(_S302 / float(max(n_8, 5U)), _S297.z, (&kernelContext_13)->params_0->ground_friction_0, depth_4, _S299, vc_1 + cross(wc_1, _S306), _S292, n_8, &stored_4, &diss_3, &kernelContext_13);
            float3 f_2 = f_1 + _S308;
            float3 t_6 = t_4 + cross(_S306, _S308);
            thread float _S309 = ledger_2.y;
            thread float _S310 = ledger_2.z;
            comp_add1_0(&_S309, &_S310, diss_3);
            ledger_2.z = _S310;
            ledger_2.y = _S309;
            f_1 = f_2;
            t_4 = t_6;
            s_6 = s_6 + 1U;
        }
        e_2 = e_2 + 1U;
        f_0 = f_1;
        t_3 = t_4;
    }
    *((&kernelContext_13)->contact_out_0+((&kernelContext_13)->params_0->ledger_base_0 + (&kernelContext_13)->params_0->pair_count_0 + c_6)) = packed_float4(ledger_2) ;
    uint _S311 = 2U * c_6;
    *((&kernelContext_13)->contact_out_0+((&kernelContext_13)->params_0->loads_base_0 + _S311)) = packed_float4(float4(f_0, 0.0f)) ;
    *((&kernelContext_13)->contact_out_0+((&kernelContext_13)->params_0->loads_base_0 + _S311 + 1U)) = packed_float4(float4(t_3, 0.0f)) ;
    return;
}

void comp_add_0(float3 thread* sum_1, float3 thread* err_1, float3 x_2)
{
    float3 t_7 = *sum_1 + x_2;
    float3 _S312 = abs(x_2);
    *err_1 = *err_1 + (select(x_2, *sum_1, (abs(*sum_1)) >= _S312) - t_7 + select(*sum_1, x_2, (abs(*sum_1)) >= _S312));
    *sum_1 = t_7;
    return;
}

float3 inverse_rotate_0(const Quat_0 thread* q_10, float3 v_5)
{
    thread Quat_0 c_7;
    (&c_7)->w_0 = q_10->w_0;
    (&c_7)->x_0 = - q_10->x_0;
    (&c_7)->y_0 = - q_10->y_0;
    (&c_7)->z_0 = - q_10->z_0;
    thread Quat_0 _S313 = c_7;
    float3 _S314 = rotate_0(&_S313, v_5);
    return _S314;
}

float3 rows_mul_0(float4 r0_0, float4 r1_0, float4 r2_0, float3 v_6)
{
    return float3(dot(r0_0.xyz, v_6), dot(r1_0.xyz, v_6), dot(r2_0.xyz, v_6));
}

float3 world_mul_0(const Quat_0 thread* q_11, float4 r0_1, float4 r1_1, float4 r2_1, float3 v_7)
{
    float3 _S315 = inverse_rotate_0(q_11, v_7);
    float3 _S316 = rotate_1(q_11, rows_mul_0(r0_1, r1_1, r2_1, _S315));
    return _S316;
}

Quat_0 quat_mul_0(const Quat_0 thread* a_5, const Quat_0 thread* o_0)
{
    thread Quat_0 r_3;
    (&r_3)->w_0 = a_5->w_0 * o_0->w_0 - a_5->x_0 * o_0->x_0 - a_5->y_0 * o_0->y_0 - a_5->z_0 * o_0->z_0;
    (&r_3)->x_0 = a_5->w_0 * o_0->x_0 + a_5->x_0 * o_0->w_0 + a_5->y_0 * o_0->z_0 - a_5->z_0 * o_0->y_0;
    (&r_3)->y_0 = a_5->w_0 * o_0->y_0 - a_5->x_0 * o_0->z_0 + a_5->y_0 * o_0->w_0 + a_5->z_0 * o_0->x_0;
    (&r_3)->z_0 = a_5->w_0 * o_0->z_0 + a_5->x_0 * o_0->y_0 - a_5->y_0 * o_0->x_0 + a_5->z_0 * o_0->w_0;
    return r_3;
}

Quat_0 normalized_0(const Quat_0 thread* q_12)
{
    float n_9 = sqrt(q_12->w_0 * q_12->w_0 + q_12->x_0 * q_12->x_0 + q_12->y_0 * q_12->y_0 + q_12->z_0 * q_12->z_0);
    thread Quat_0 r_4;
    (&r_4)->w_0 = q_12->w_0 / n_9;
    (&r_4)->x_0 = q_12->x_0 / n_9;
    (&r_4)->y_0 = q_12->y_0 / n_9;
    (&r_4)->z_0 = q_12->z_0 / n_9;
    return r_4;
}

Quat_0 integrate_rotation_0(const Quat_0 thread* q_13, float3 omega_0, float dt_2)
{
    float angle_1 = length(omega_0) * dt_2;
    if(angle_1 < 1.00000000317107685e-30f)
    {
        return *q_13;
    }
    thread Quat_0 _S317 = from_axis_angle_0(omega_0, angle_1);
    Quat_0 _S318 = quat_mul_0(&_S317, q_13);
    thread Quat_0 _S319 = _S318;
    Quat_0 _S320 = normalized_0(&_S319);
    return _S320;
}

float4 quat_vec_0(const Quat_0 thread* q_14)
{
    return float4(q_14->x_0, q_14->y_0, q_14->z_0, q_14->w_0);
}

[[kernel]] void impactor_integrate(uint3 group_1 [[threadgroup_position_in_grid]], uint3 thread_1 [[thread_position_in_threadgroup]], ContactParams_0 constant* params_6 [[buffer(0)]], Island_natural_0 device* islands_6 [[buffer(4)]], packed_uint4 device* contact_static_6 [[buffer(5)]], ChunkStatic_natural_0 device* chunks_6 [[buffer(1)]], packed_float4 device* state_6 [[buffer(3)]], ContactChunk_natural_0 device* contact_chunks_6 [[buffer(2)]], packed_float4 device* contact_out_6 [[buffer(8)]], packed_float4 device* contact_state_6 [[buffer(6)]], Impactor_natural_0 device* impactors_6 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_14;
    (&kernelContext_14)->params_0 = params_6;
    (&kernelContext_14)->islands_0 = islands_6;
    (&kernelContext_14)->contact_static_0 = contact_static_6;
    (&kernelContext_14)->chunks_0 = chunks_6;
    (&kernelContext_14)->state_0 = state_6;
    (&kernelContext_14)->contact_chunks_0 = contact_chunks_6;
    (&kernelContext_14)->contact_out_0 = contact_out_6;
    (&kernelContext_14)->contact_state_0 = contact_state_6;
    (&kernelContext_14)->impactors_0 = impactors_6;
    threadgroup array<float4, int(256)> g_red_a_6;
    (&kernelContext_14)->g_red_a_0 = &g_red_a_6;
    threadgroup array<float4, int(256)> g_red_b_6;
    (&kernelContext_14)->g_red_b_0 = &g_red_b_6;
    uint ii_1 = group_1.x;
    uint tid_2 = thread_1.x;
    if(ii_1 >= (params_6->impactor_count_0))
    {
        return;
    }
    Island_natural_0 device* _S321 = (&kernelContext_14)->islands_0+(&kernelContext_14)->params_0->halt_index_0;
    Impactor_natural_0 device* _S322 = (&kernelContext_14)->impactors_0+ii_1;
    float4 _S323 = float4((*_S322).position_err_1) ;
    float4 _S324 = float4((*_S322).velocity_1) ;
    float4 _S325 = float4((*_S322).velocity_err_1) ;
    float4 _S326 = float4((*_S322).angular_velocity_1) ;
    float4 _S327 = float4((*_S322).rotation_1) ;
    float4 _S328 = float4((*_S322).inertia0_2) ;
    float4 _S329 = float4((*_S322).inertia1_2) ;
    float4 _S330 = float4((*_S322).inertia2_2) ;
    float4 _S331 = float4((*_S322).inv0_2) ;
    float4 _S332 = float4((*_S322).inv1_2) ;
    float4 _S333 = float4((*_S322).inv2_2) ;
    float4 _S334 = float4((*_S322).shape_0) ;
    float4 _S335 = float4((*_S322).half_1) ;
    float4 _S336 = float4((*_S322).mat_1) ;
    float4 _S337 = float4((*_S322).crush_0) ;
    float4 _S338 = float4((*_S322).load_force_0) ;
    float4 _S339 = float4((*_S322).load_torque_0) ;
    float4 _S340 = float4((*_S322).ledger_0) ;
    uint4 _S341 = uint4((*_S322).cand_0) ;
    thread Impactor_0 imp_4;
    (&imp_4)->position_1 = float4((*_S322).position_1) ;
    (&imp_4)->position_err_1 = _S323;
    (&imp_4)->velocity_1 = _S324;
    (&imp_4)->velocity_err_1 = _S325;
    (&imp_4)->angular_velocity_1 = _S326;
    (&imp_4)->rotation_1 = _S327;
    (&imp_4)->inertia0_2 = _S328;
    (&imp_4)->inertia1_2 = _S329;
    (&imp_4)->inertia2_2 = _S330;
    (&imp_4)->inv0_2 = _S331;
    (&imp_4)->inv1_2 = _S332;
    (&imp_4)->inv2_2 = _S333;
    (&imp_4)->shape_0 = _S334;
    (&imp_4)->half_1 = _S335;
    (&imp_4)->mat_1 = _S336;
    (&imp_4)->crush_0 = _S337;
    (&imp_4)->load_force_0 = _S338;
    (&imp_4)->load_torque_0 = _S339;
    (&imp_4)->ledger_0 = _S340;
    (&imp_4)->cand_0 = _S341;
    bool _S342;
    if(((&imp_4)->cand_0.z) != 0U)
    {
        _S342 = true;
    }
    else
    {
        _S342 = (((uint4(_S321->info_0) ).z) & 1U) != 0U;
    }
    if(_S342)
    {
        _S342 = true;
    }
    else
    {
        uint _S343 = (uint4(_S321->info_0) ).y;
        if(_S343 != 0U)
        {
            _S342 = ((&imp_4)->cand_0.w) >= _S343;
        }
        else
        {
            _S342 = false;
        }
    }
    if(_S342)
    {
        return;
    }
    float4 _S344 = float4(0.0f) ;
    thread float4 rf_0 = _S344;
    thread float4 rt_0 = _S344;
    uint e_3 = (&imp_4)->cand_0.x + tid_2;
    for(;;)
    {
        if(e_3 < ((&imp_4)->cand_0.y))
        {
        }
        else
        {
            break;
        }
        uint _S345 = 3U * (e_3 - (&kernelContext_14)->params_0->cand_begin_0);
        rf_0 = rf_0 + float4(*((&kernelContext_14)->contact_out_0+((&kernelContext_14)->params_0->cand_base_0 + _S345 + 1U))) ;
        rt_0 = rt_0 + float4(*((&kernelContext_14)->contact_out_0+((&kernelContext_14)->params_0->cand_base_0 + _S345 + 2U))) ;
        e_3 = e_3 + 256U;
    }
    group_sum2_0(tid_2, &rf_0, &rt_0, &kernelContext_14);
    if(tid_2 != 0U)
    {
        return;
    }
    (&imp_4)->cand_0.w = (&imp_4)->cand_0.w + 1U;
    float dt_3 = (&kernelContext_14)->params_0->dt_0;
    float m_1 = (&imp_4)->mat_1.z;
    thread float3 vel_0 = (&imp_4)->velocity_1.xyz;
    thread float3 vel_err_0 = (&imp_4)->velocity_err_1.xyz;
    float3 load_t_2 = rt_0.xyz + (&imp_4)->load_torque_0.xyz;
    float3 _S346 = float3(dt_3) ;
    comp_add_0(&vel_0, &vel_err_0, ((rf_0.xyz + (&imp_4)->load_force_0.xyz) / float3(m_1)  + (&kernelContext_14)->params_0->gravity_0.xyz) * _S346);
    Quat_0 q_15 = quat_of_0((&imp_4)->rotation_1);
    float3 _S347 = (&imp_4)->angular_velocity_1.xyz;
    thread Quat_0 _S348 = q_15;
    float3 _S349 = world_mul_0(&_S348, (&imp_4)->inertia0_2, (&imp_4)->inertia1_2, (&imp_4)->inertia2_2, _S347);
    float3 l_1 = _S349 + load_t_2 * _S346;
    thread Quat_0 _S350 = q_15;
    float3 _S351 = world_mul_0(&_S350, (&imp_4)->inv0_2, (&imp_4)->inv1_2, (&imp_4)->inv2_2, l_1);
    thread float3 pos_0 = (&imp_4)->position_1.xyz;
    thread float3 pos_err_0 = (&imp_4)->position_err_1.xyz;
    comp_add_0(&pos_0, &pos_err_0, (vel_0 + vel_err_0) * _S346);
    thread Quat_0 _S352 = q_15;
    Quat_0 _S353 = integrate_rotation_0(&_S352, _S351, dt_3);
    thread Quat_0 _S354 = _S353;
    float3 _S355 = world_mul_0(&_S354, (&imp_4)->inv0_2, (&imp_4)->inv1_2, (&imp_4)->inv2_2, l_1);
    (&imp_4)->angular_velocity_1 = float4(_S355, 0.0f);
    thread Quat_0 _S356 = _S353;
    float4 _S357 = quat_vec_0(&_S356);
    (&imp_4)->rotation_1 = _S357;
    (&imp_4)->position_1 = float4(pos_0, 0.0f);
    (&imp_4)->position_err_1 = float4(pos_err_0, 0.0f);
    (&imp_4)->velocity_1 = float4(vel_0, 0.0f);
    (&imp_4)->velocity_err_1 = float4(vel_err_0, 0.0f);
    Impactor_natural_0 device* _S358 = (&kernelContext_14)->impactors_0+ii_1;
    _S358->position_1 = packed_float4(imp_4.position_1) ;
    _S358->position_err_1 = packed_float4(imp_4.position_err_1) ;
    _S358->velocity_1 = packed_float4(imp_4.velocity_1) ;
    _S358->velocity_err_1 = packed_float4(imp_4.velocity_err_1) ;
    _S358->angular_velocity_1 = packed_float4(imp_4.angular_velocity_1) ;
    _S358->rotation_1 = packed_float4(imp_4.rotation_1) ;
    _S358->inertia0_2 = packed_float4(imp_4.inertia0_2) ;
    _S358->inertia1_2 = packed_float4(imp_4.inertia1_2) ;
    _S358->inertia2_2 = packed_float4(imp_4.inertia2_2) ;
    _S358->inv0_2 = packed_float4(imp_4.inv0_2) ;
    _S358->inv1_2 = packed_float4(imp_4.inv1_2) ;
    _S358->inv2_2 = packed_float4(imp_4.inv2_2) ;
    _S358->shape_0 = packed_float4(imp_4.shape_0) ;
    _S358->half_1 = packed_float4(imp_4.half_1) ;
    _S358->mat_1 = packed_float4(imp_4.mat_1) ;
    _S358->crush_0 = packed_float4(imp_4.crush_0) ;
    _S358->load_force_0 = packed_float4(imp_4.load_force_0) ;
    _S358->load_torque_0 = packed_float4(imp_4.load_torque_0) ;
    _S358->ledger_0 = packed_float4(imp_4.ledger_0) ;
    _S358->cand_0 = packed_uint4(imp_4.cand_0) ;
    uint k_5 = (&imp_4)->cand_0.w - 1U - (&kernelContext_14)->params_0->step_start_0;
    if(k_5 < ((&kernelContext_14)->params_0->record_stride_0))
    {
        uint at_0 = (&kernelContext_14)->params_0->loads_base_0 + 2U * (&kernelContext_14)->params_0->chunk_count_0 + 2U * (ii_1 * (&kernelContext_14)->params_0->record_stride_0 + k_5);
        *((&kernelContext_14)->contact_out_0+at_0) = packed_float4(float4(vel_0 + vel_err_0, 0.0f)) ;
        *((&kernelContext_14)->contact_out_0+(at_0 + 1U)) = packed_float4(float4(pos_0 + pos_err_0, 0.0f)) ;
    }
    return;
}

