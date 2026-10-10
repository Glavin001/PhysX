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
    uint i_2 = id_0.x;
    bool _S75;
    if(i_2 >= (params_1->pair_count_0))
    {
        _S75 = true;
    }
    else
    {
        bool _S76 = stopped_0(&kernelContext_5);
        _S75 = _S76;
    }
    if(_S75)
    {
        return;
    }
    uint _S77 = 2U * i_2;
    uint4 _S78 = uint4(*((&kernelContext_5)->contact_static_0+_S77)) ;
    float4 law_0 = (as_type<float4>((uint4(*((&kernelContext_5)->contact_static_0+(_S77 + 1U))) )));
    uint ca_0 = _S78.x;
    uint cb_0 = _S78.y;
    uint slot_0 = _S78.z;
    uint _S79 = _S78.w * 28U;
    float _S80 = law_0.x;
    float _S81 = law_0.y;
    float _S82 = (&kernelContext_5)->params_0->dt_0;
    WorldPoint_0 _S83 = chunk_world_0(ca_0, &kernelContext_5);
    WorldPoint_0 _S84 = chunk_world_0(cb_0, &kernelContext_5);
    thread WorldPoint_0 _S85 = _S84;
    thread WorldPoint_0 _S86 = _S83;
    float3 _S87 = world_diff_0(&_S85, &_S86);
    bool touching_0 = !((length(_S87)) > ((float4((&kernelContext_5)->contact_chunks_0[ca_0].half_0) ).w + (float4((&kernelContext_5)->contact_chunks_0[cb_0].half_0) ).w));
    float3 _S88 = float3(0.0f) ;
    Box_0 _S89 = chunk_box_0(ca_0, _S88, &kernelContext_5);
    Box_0 _S90 = chunk_box_0(cb_0, _S87, &kernelContext_5);
    thread float4 ledger_1 = float4(*((&kernelContext_5)->contact_out_0+((&kernelContext_5)->params_0->ledger_base_0 + i_2))) ;
    if(touching_0)
    {
        thread Box_0 _S91 = _S89;
        thread Box_0 _S92 = _S90;
        bool _S93 = may_overlap_0(&_S91, &_S92);
        _S75 = _S93;
    }
    else
    {
        _S75 = false;
    }
    uint s_1;
    float3 fa_0;
    float3 ta_0;
    float3 fb_0;
    float3 tb_0;
    float stored_sum_0;
    if(_S75)
    {
        thread array<float3, int(28)> pts_0;
        thread array<float3, int(28)> nrm_0;
        thread array<float, int(28)> dep_0;
        thread array<uint, int(28)> idx_0;
        s_1 = 0U;
        uint count_0 = 0U;
        for(;;)
        {
            if(s_1 < 14U)
            {
            }
            else
            {
                break;
            }
            thread Box_0 _S94 = _S89;
            float3 _S95 = sample_point_0(&_S94, s_1);
            thread Box_0 _S96 = _S90;
            thread float d_3;
            thread float3 n_1;
            bool _S97 = penetration_0(&_S96, _S95, &d_3, &n_1);
            if(_S97)
            {
                pts_0[count_0] = _S95;
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
            thread Box_0 _S98 = _S90;
            float3 _S99 = sample_point_0(&_S98, s_1);
            thread Box_0 _S100 = _S89;
            thread float d_4;
            thread float3 n_2;
            bool _S101 = penetration_0(&_S100, _S99, &d_4, &n_2);
            if(_S101)
            {
                pts_0[count_0] = _S99;
                nrm_0[count_0] = - n_2;
                dep_0[count_0] = d_4;
                idx_0[count_0] = 14U + s_1;
                count_0 = count_0 + 1U;
            }
            s_1 = s_1 + 1U;
        }
        uint j_0;
        if(count_0 > 0U)
        {
            float _S102 = (float4((&kernelContext_5)->contact_chunks_0[ca_0].mat_0) ).x;
            float _S103 = (float4((&kernelContext_5)->contact_chunks_0[cb_0].mat_0) ).x;
            float3 _S104 = _S90.center_1 - _S89.center_1;
            thread Box_0 _S105 = _S89;
            thread Box_0 _S106 = _S90;
            float _S107 = contact_stiffness_0(_S102, &_S105, _S103, &_S106, _S104);
            thread float3 va0_0;
            thread float3 wa0_0;
            chunk_velocity_0(ca_0, &va0_0, &wa0_0, &kernelContext_5);
            thread float3 vb0_0;
            thread float3 wb0_0;
            chunk_velocity_0(cb_0, &vb0_0, &wb0_0, &kernelContext_5);
            thread array<float, int(28)> eff_0;
            j_0 = 0U;
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
                uint _S108 = _S79 + idx_0[j_0];
                float4 _S109 = float4(*((&kernelContext_5)->contact_state_0+_S108)) ;
                thread float4 entry_0 = _S109;
                float3 p_1 = pts_0[j_0];
                float3 n_3 = nrm_0[j_0];
                if(isnan(_S109.x))
                {
                    _S75 = true;
                }
                else
                {
                    _S75 = (dot(entry_0.yzw, n_3)) < 0.99000000953674316f;
                }
                if(_S75)
                {
                    if((dep_0[j_0]) > (2.0f * abs(dot(va0_0 + cross(wa0_0, p_1) - (vb0_0 + cross(wb0_0, p_1 - _S90.center_1)), n_3)) * _S82 + 9.99999971718068537e-10f))
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
                *((&kernelContext_5)->contact_state_0+_S108) = packed_float4(entry_0) ;
                float _S110 = dep_0[j_0] - entry_0.x;
                eff_0[j_0] = _S110;
                if(_S110 > 0.0f)
                {
                    engaged_0 = engaged_0 + 1U;
                }
                j_0 = j_0 + 1U;
                inside_mask_0 = inside_mask_1;
            }
            uint e_0 = 0U;
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
                    *((&kernelContext_5)->contact_state_0+(_S79 + e_0)) = packed_float4(float4((as_type<float>((2143289344U))), 0.0f, 0.0f, 0.0f)) ;
                }
                e_0 = e_0 + 1U;
            }
            float _S111 = _S107 / max(float(engaged_0), 10.0f);
            j_0 = 0U;
            fa_0 = _S88;
            ta_0 = _S88;
            fb_0 = _S88;
            tb_0 = _S88;
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
                float3 _S112 = pts_0[j_0] - _S90.center_1;
                thread float stored_1;
                thread float diss_0;
                float3 _S113 = penalty_force_0(_S111, _S80, _S81, eff_0[j_0], nrm_0[j_0], va0_0 + cross(wa0_0, pts_0[j_0]) - (vb0_0 + cross(wb0_0, _S112)), _S82, engaged_0, &stored_1, &diss_0, &kernelContext_5);
                float3 fa_1 = fa_0 + _S113;
                float3 ta_1 = ta_0 + cross(pts_0[j_0], _S113);
                float3 _S114 = - _S113;
                float3 fb_1 = fb_0 + _S114;
                float3 tb_1 = tb_0 + cross(_S112, _S114);
                float stored_sum_1 = stored_sum_0 + stored_1;
                thread float _S115 = ledger_1.y;
                thread float _S116 = ledger_1.z;
                comp_add1_0(&_S115, &_S116, diss_0);
                ledger_1.z = _S116;
                ledger_1.y = _S115;
                fa_0 = fa_1;
                ta_0 = ta_1;
                fb_0 = fb_1;
                tb_0 = tb_1;
                stored_sum_0 = stored_sum_1;
                j_0 = j_0 + 1U;
            }
        }
        else
        {
            j_0 = 0U;
            for(;;)
            {
                if(j_0 < 28U)
                {
                }
                else
                {
                    break;
                }
                *((&kernelContext_5)->contact_state_0+(_S79 + j_0)) = packed_float4(float4((as_type<float>((2143289344U))), 0.0f, 0.0f, 0.0f)) ;
                j_0 = j_0 + 1U;
            }
            stored_sum_0 = 0.0f;
            fa_0 = _S88;
            ta_0 = _S88;
            fb_0 = _S88;
            tb_0 = _S88;
        }
    }
    else
    {
        s_1 = 0U;
        for(;;)
        {
            if(s_1 < 28U)
            {
            }
            else
            {
                break;
            }
            *((&kernelContext_5)->contact_state_0+(_S79 + s_1)) = packed_float4(float4((as_type<float>((2143289344U))), 0.0f, 0.0f, 0.0f)) ;
            s_1 = s_1 + 1U;
        }
        stored_sum_0 = 0.0f;
        fa_0 = _S88;
        ta_0 = _S88;
        fb_0 = _S88;
        tb_0 = _S88;
    }
    ledger_1.x = stored_sum_0;
    *((&kernelContext_5)->contact_out_0+((&kernelContext_5)->params_0->ledger_base_0 + i_2)) = packed_float4(ledger_1) ;
    uint _S117 = 2U * slot_0;
    *((&kernelContext_5)->contact_out_0+_S117) = packed_float4(float4(fa_0, 0.0f)) ;
    *((&kernelContext_5)->contact_out_0+(_S117 + 1U)) = packed_float4(float4(ta_0, 0.0f)) ;
    *((&kernelContext_5)->contact_out_0+(_S117 + 2U)) = packed_float4(float4(fb_0, 0.0f)) ;
    *((&kernelContext_5)->contact_out_0+(_S117 + 3U)) = packed_float4(float4(tb_0, 0.0f)) ;
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
    float3 _S118 = float3(1.0f, 0.0f, 0.0f);
    thread Quat_0 _S119 = q_7;
    float3 _S120 = rotate_0(&_S119, _S118);
    (&b_8)->axis0_0 = _S120;
    float3 _S121 = float3(0.0f, 1.0f, 0.0f);
    thread Quat_0 _S122 = q_7;
    float3 _S123 = rotate_0(&_S122, _S121);
    (&b_8)->axis1_0 = _S123;
    float3 _S124 = float3(0.0f, 0.0f, 1.0f);
    thread Quat_0 _S125 = q_7;
    float3 _S126 = rotate_0(&_S125, _S124);
    (&b_8)->axis2_0 = _S126;
    (&b_8)->half_2 = half_3;
    return b_8;
}

bool sphere_contact_0(const Box_0 thread* b_9, float3 center_4, float radius_0, float3 thread* point_0, float3 thread* normal_2, float thread* depth_2)
{
    float3 _S127 = float3(0.0f) ;
    *point_0 = _S127;
    *normal_2 = _S127;
    *depth_2 = 0.0f;
    float3 _S128 = b_9->center_1;
    float3 r_2 = center_4 - b_9->center_1;
    float3 _S129 = b_9->axis0_0;
    float3 _S130 = b_9->axis1_0;
    float3 _S131 = b_9->axis2_0;
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
        *normal_2 = _S129 * float3(dn_0.x)  + _S130 * float3(dn_0.y)  + _S131 * float3(dn_0.z) ;
        *point_0 = _S128 + _S129 * float3(q_8.x)  + _S130 * float3(q_8.y)  + _S131 * float3(q_8.z) ;
        *depth_2 = radius_0 - dist_0;
        return true;
    }
    thread float inside_0;
    thread float3 n_4;
    bool _S132 = penetration_0(b_9, center_4, &inside_0, &n_4);
    if(!_S132)
    {
        return false;
    }
    *normal_2 = n_4;
    *point_0 = center_4 - n_4 * float3(min(radius_0, inside_0)) ;
    *depth_2 = radius_0 + inside_0;
    return true;
}

uint impactor_points_0(const Impactor_natural_0 thread* imp_1, const Box_0 thread* ib_0, const Box_0 thread* b_10, array<float3, int(28)> thread* pts_1, array<float3, int(28)> thread* nrm_1, array<float, int(28)> thread* dep_1)
{
    float4 _S133 = float4(imp_1->shape_0) ;
    uint count_1;
    if((_S133.x) == 0.0f)
    {
        thread float3 p_2;
        thread float3 n_5;
        thread float d_6;
        bool _S134 = sphere_contact_0(b_10, float3(0.0f) , _S133.y - (float4(imp_1->crush_0) ).w, &p_2, &n_5, &d_6);
        if(_S134)
        {
            (*pts_1)[int(0)] = p_2;
            (*nrm_1)[int(0)] = - n_5;
            (*dep_1)[int(0)] = d_6;
            count_1 = 1U;
        }
        else
        {
            count_1 = 0U;
        }
        return count_1;
    }
    thread Box_0 shrunk_0 = *ib_0;
    (&shrunk_0)->half_2 = ib_0->half_2 - min(float3((float4(imp_1->crush_0) ).w) , ib_0->half_2 * float3(0.5f) );
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
        float3 _S135 = sample_point_0(b_10, s_2);
        thread Box_0 _S136 = shrunk_0;
        thread float d_7;
        thread float3 n_6;
        bool _S137 = penetration_0(&_S136, _S135, &d_7, &n_6);
        if(_S137)
        {
            (*pts_1)[count_1] = _S135;
            (*nrm_1)[count_1] = n_6;
            (*dep_1)[count_1] = d_7;
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
        thread Box_0 _S138 = shrunk_0;
        float3 _S139 = sample_point_0(&_S138, s_2);
        thread float d_8;
        thread float3 n_7;
        bool _S140 = penetration_0(b_10, _S139, &d_8, &n_7);
        if(_S140)
        {
            (*pts_1)[count_1] = _S139;
            (*nrm_1)[count_1] = - n_7;
            (*dep_1)[count_1] = d_8;
            count_1 = count_1 + 1U;
        }
        s_2 = s_2 + 1U;
    }
    return count_1;
}

uint impactor_points_1(const Impactor_0 thread* imp_2, const Box_0 thread* ib_1, const Box_0 thread* b_11, array<float3, int(28)> thread* pts_2, array<float3, int(28)> thread* nrm_2, array<float, int(28)> thread* dep_2)
{
    float4 _S141 = imp_2->shape_0;
    uint count_2;
    if((imp_2->shape_0.x) == 0.0f)
    {
        thread float3 p_3;
        thread float3 n_8;
        thread float d_9;
        bool _S142 = sphere_contact_0(b_11, float3(0.0f) , _S141.y - imp_2->crush_0.w, &p_3, &n_8, &d_9);
        if(_S142)
        {
            (*pts_2)[int(0)] = p_3;
            (*nrm_2)[int(0)] = - n_8;
            (*dep_2)[int(0)] = d_9;
            count_2 = 1U;
        }
        else
        {
            count_2 = 0U;
        }
        return count_2;
    }
    thread Box_0 shrunk_1 = *ib_1;
    (&shrunk_1)->half_2 = ib_1->half_2 - min(float3(imp_2->crush_0.w) , ib_1->half_2 * float3(0.5f) );
    uint s_3 = 0U;
    count_2 = 0U;
    for(;;)
    {
        if(s_3 < 14U)
        {
        }
        else
        {
            break;
        }
        float3 _S143 = sample_point_0(b_11, s_3);
        thread Box_0 _S144 = shrunk_1;
        thread float d_10;
        thread float3 n_9;
        bool _S145 = penetration_0(&_S144, _S143, &d_10, &n_9);
        if(_S145)
        {
            (*pts_2)[count_2] = _S143;
            (*nrm_2)[count_2] = n_9;
            (*dep_2)[count_2] = d_10;
            count_2 = count_2 + 1U;
        }
        s_3 = s_3 + 1U;
    }
    s_3 = 0U;
    for(;;)
    {
        if(s_3 < 14U)
        {
        }
        else
        {
            break;
        }
        thread Box_0 _S146 = shrunk_1;
        float3 _S147 = sample_point_0(&_S146, s_3);
        thread float d_11;
        thread float3 n_10;
        bool _S148 = penetration_0(b_11, _S147, &d_11, &n_10);
        if(_S148)
        {
            (*pts_2)[count_2] = _S147;
            (*nrm_2)[count_2] = - n_10;
            (*dep_2)[count_2] = d_11;
            count_2 = count_2 + 1U;
        }
        s_3 = s_3 + 1U;
    }
    return count_2;
}

[[kernel]] void contact_impactors(uint3 id_1 [[thread_position_in_grid]], ContactParams_0 constant* params_2 [[buffer(0)]], Island_natural_0 device* islands_2 [[buffer(4)]], packed_uint4 device* contact_static_2 [[buffer(5)]], ChunkStatic_natural_0 device* chunks_2 [[buffer(1)]], packed_float4 device* state_2 [[buffer(3)]], ContactChunk_natural_0 device* contact_chunks_2 [[buffer(2)]], packed_float4 device* contact_out_2 [[buffer(8)]], packed_float4 device* contact_state_2 [[buffer(6)]], Impactor_natural_0 device* impactors_2 [[buffer(7)]])
{
    uint j_1;
    float crush_factor_0;
    uint total_points_0;
    float3 f_sum_0;
    thread KernelContext_0 kernelContext_6;
    (&kernelContext_6)->params_0 = params_2;
    (&kernelContext_6)->islands_0 = islands_2;
    (&kernelContext_6)->contact_static_0 = contact_static_2;
    (&kernelContext_6)->chunks_0 = chunks_2;
    (&kernelContext_6)->state_0 = state_2;
    (&kernelContext_6)->contact_chunks_0 = contact_chunks_2;
    (&kernelContext_6)->contact_out_0 = contact_out_2;
    (&kernelContext_6)->contact_state_0 = contact_state_2;
    (&kernelContext_6)->impactors_0 = impactors_2;
    uint ii_0 = id_1.x;
    bool _S149;
    if(ii_0 >= (params_2->impactor_count_0))
    {
        _S149 = true;
    }
    else
    {
        bool _S150 = stopped_0(&kernelContext_6);
        _S149 = _S150;
    }
    if(_S149)
    {
        return;
    }
    Impactor_natural_0 device* _S151 = (&kernelContext_6)->impactors_0+ii_0;
    float4 _S152 = float4((*_S151).position_err_1) ;
    float4 _S153 = float4((*_S151).velocity_1) ;
    float4 _S154 = float4((*_S151).velocity_err_1) ;
    float4 _S155 = float4((*_S151).angular_velocity_1) ;
    float4 _S156 = float4((*_S151).rotation_1) ;
    float4 _S157 = float4((*_S151).inertia0_2) ;
    float4 _S158 = float4((*_S151).inertia1_2) ;
    float4 _S159 = float4((*_S151).inertia2_2) ;
    float4 _S160 = float4((*_S151).inv0_2) ;
    float4 _S161 = float4((*_S151).inv1_2) ;
    float4 _S162 = float4((*_S151).inv2_2) ;
    float4 _S163 = float4((*_S151).shape_0) ;
    float4 _S164 = float4((*_S151).half_1) ;
    float4 _S165 = float4((*_S151).mat_1) ;
    float4 _S166 = float4((*_S151).crush_0) ;
    float4 _S167 = float4((*_S151).load_force_0) ;
    float4 _S168 = float4((*_S151).load_torque_0) ;
    float4 _S169 = float4((*_S151).ledger_0) ;
    uint4 _S170 = uint4((*_S151).cand_0) ;
    thread Impactor_0 imp_3;
    (&imp_3)->position_1 = float4((*_S151).position_1) ;
    (&imp_3)->position_err_1 = _S152;
    (&imp_3)->velocity_1 = _S153;
    (&imp_3)->velocity_err_1 = _S154;
    (&imp_3)->angular_velocity_1 = _S155;
    (&imp_3)->rotation_1 = _S156;
    (&imp_3)->inertia0_2 = _S157;
    (&imp_3)->inertia1_2 = _S158;
    (&imp_3)->inertia2_2 = _S159;
    (&imp_3)->inv0_2 = _S160;
    (&imp_3)->inv1_2 = _S161;
    (&imp_3)->inv2_2 = _S162;
    (&imp_3)->shape_0 = _S163;
    (&imp_3)->half_1 = _S164;
    (&imp_3)->mat_1 = _S165;
    (&imp_3)->crush_0 = _S166;
    (&imp_3)->load_force_0 = _S167;
    (&imp_3)->load_torque_0 = _S168;
    (&imp_3)->ledger_0 = _S169;
    (&imp_3)->cand_0 = _S170;
    float _S171 = (&kernelContext_6)->params_0->dt_0;
    float3 _S172 = float3(0.0f) ;
    float3 load_f_0;
    float3 load_t_0;
    if(((&imp_3)->cand_0.z) == 0U)
    {
        thread WorldPoint_0 wi_0;
        (&wi_0)->hi_0 = (&imp_3)->position_1.xyz;
        (&wi_0)->lo_0 = (&imp_3)->position_err_1.xyz;
        (&wi_0)->rel_0 = _S172;
        float3 _S173 = (&imp_3)->half_1.xyz;
        thread Impactor_0 _S174 = imp_3;
        Box_0 _S175 = impactor_box_0(&_S174, _S172, _S173);
        float _S176 = (&imp_3)->half_1.w;
        uint e_1 = (&imp_3)->cand_0.x;
        float total_0 = 0.0f;
        float ksum_0 = 0.0f;
        for(;;)
        {
            if(e_1 < ((&imp_3)->cand_0.y))
            {
            }
            else
            {
                break;
            }
            uint c_4 = (uint4(*((&kernelContext_6)->contact_static_0+e_1)) ).x;
            WorldPoint_0 _S177 = chunk_world_0(c_4, &kernelContext_6);
            thread WorldPoint_0 _S178 = _S177;
            thread WorldPoint_0 _S179 = wi_0;
            float3 _S180 = world_diff_0(&_S178, &_S179);
            if((length(_S180)) > (_S176 + (float4((&kernelContext_6)->contact_chunks_0[c_4].half_0) ).w))
            {
                e_1 = e_1 + 1U;
                continue;
            }
            Box_0 _S181 = chunk_box_0(c_4, _S180, &kernelContext_6);
            float _S182 = (&imp_3)->mat_1.x;
            float _S183 = (float4((&kernelContext_6)->contact_chunks_0[c_4].mat_0) ).x;
            float3 _S184 = _S181.center_1 - _S175.center_1;
            thread Box_0 _S185 = _S175;
            thread Box_0 _S186 = _S181;
            float _S187 = contact_stiffness_0(_S182, &_S185, _S183, &_S186, _S184);
            thread Impactor_0 _S188 = imp_3;
            thread Box_0 _S189 = _S175;
            thread Box_0 _S190 = _S181;
            thread array<float3, int(28)> pts_3;
            thread array<float3, int(28)> nrm_3;
            thread array<float, int(28)> dep_3;
            uint _S191 = impactor_points_1(&_S188, &_S189, &_S190, &pts_3, &nrm_3, &dep_3);
            if(((&imp_3)->shape_0.x) == 0.0f)
            {
                crush_factor_0 = _S187;
            }
            else
            {
                crush_factor_0 = _S187 / max(float(_S191), 10.0f);
            }
            j_1 = 0U;
            float total_1 = total_0;
            float ksum_1 = ksum_0;
            for(;;)
            {
                if(j_1 < _S191)
                {
                }
                else
                {
                    break;
                }
                float total_2 = total_1 + crush_factor_0 * dep_3[j_1];
                float ksum_2 = ksum_1 + crush_factor_0;
                j_1 = j_1 + 1U;
                total_1 = total_2;
                ksum_1 = ksum_2;
            }
            total_0 = total_1;
            ksum_0 = ksum_1;
            e_1 = e_1 + 1U;
        }
        if(((&imp_3)->crush_0.x) > 0.0f)
        {
            _S149 = ((&imp_3)->crush_0.z) < ((&imp_3)->crush_0.y);
        }
        else
        {
            _S149 = false;
        }
        if(_S149)
        {
            _S149 = total_0 > ((&imp_3)->crush_0.x);
        }
        else
        {
            _S149 = false;
        }
        if(_S149)
        {
            float extra_0 = (total_0 - (&imp_3)->crush_0.x) / ksum_0;
            (&imp_3)->crush_0.w = (&imp_3)->crush_0.w + extra_0;
            (&imp_3)->crush_0.z = (&imp_3)->crush_0.z + (&imp_3)->crush_0.x * extra_0;
            float _S192 = (&imp_3)->crush_0.x * extra_0;
            thread float _S193 = (&imp_3)->ledger_0.z;
            thread float _S194 = (&imp_3)->ledger_0.w;
            comp_add1_0(&_S193, &_S194, _S192);
            (&imp_3)->ledger_0.w = _S194;
            (&imp_3)->ledger_0.z = _S193;
            float _S195 = (&imp_3)->crush_0.x * extra_0;
            thread float _S196 = (&imp_3)->ledger_0.x;
            thread float _S197 = (&imp_3)->ledger_0.y;
            comp_add1_0(&_S196, &_S197, _S195);
            (&imp_3)->ledger_0.y = _S197;
            (&imp_3)->ledger_0.x = _S196;
            crush_factor_0 = (&imp_3)->crush_0.x / total_0;
        }
        else
        {
            crush_factor_0 = 1.0f;
        }
        thread Impactor_natural_0 _S198 = *((&kernelContext_6)->impactors_0+ii_0);
        float3 _S199 = (&imp_3)->velocity_1.xyz + (&imp_3)->velocity_err_1.xyz;
        e_1 = (&imp_3)->cand_0.x;
        load_f_0 = _S172;
        load_t_0 = _S172;
        for(;;)
        {
            if(e_1 < ((&imp_3)->cand_0.y))
            {
            }
            else
            {
                break;
            }
            uint c_5 = (uint4(*((&kernelContext_6)->contact_static_0+e_1)) ).x;
            uint slot_1 = (uint4(*((&kernelContext_6)->contact_static_0+e_1)) ).y;
            WorldPoint_0 _S200 = chunk_world_0(c_5, &kernelContext_6);
            thread WorldPoint_0 _S201 = _S200;
            thread WorldPoint_0 _S202 = wi_0;
            float3 _S203 = world_diff_0(&_S201, &_S202);
            float3 t_sum_0;
            if(!((length(_S203)) > (_S176 + (float4((&kernelContext_6)->contact_chunks_0[c_5].half_0) ).w)))
            {
                Box_0 _S204 = chunk_box_0(c_5, _S203, &kernelContext_6);
                float _S205 = (&imp_3)->mat_1.x;
                float _S206 = (float4((&kernelContext_6)->contact_chunks_0[c_5].mat_0) ).x;
                float3 _S207 = _S204.center_1 - _S175.center_1;
                thread Box_0 _S208 = _S175;
                thread Box_0 _S209 = _S204;
                float _S210 = contact_stiffness_0(_S205, &_S208, _S206, &_S209, _S207);
                thread Box_0 _S211 = _S175;
                thread Box_0 _S212 = _S204;
                thread array<float3, int(28)> pts_4;
                thread array<float3, int(28)> nrm_4;
                thread array<float, int(28)> dep_4;
                uint _S213 = impactor_points_0(&_S198, &_S211, &_S212, &pts_4, &nrm_4, &dep_4);
                if(((&imp_3)->shape_0.x) == 0.0f)
                {
                    total_0 = _S210;
                }
                else
                {
                    total_0 = _S210 / max(float(_S213), 10.0f);
                }
                if(((&imp_3)->shape_0.x) == 0.0f)
                {
                    total_points_0 = 1U;
                }
                else
                {
                    total_points_0 = _S213;
                }
                float m_0 = (float4((&kernelContext_6)->contact_chunks_0[c_5].mat_0) ).z;
                float _S214 = m_0 * (&imp_3)->mat_1.z / (m_0 + (&imp_3)->mat_1.z);
                if(((&kernelContext_6)->params_0->pair_friction_0) >= 0.0f)
                {
                    ksum_0 = (&kernelContext_6)->params_0->pair_friction_0;
                }
                else
                {
                    ksum_0 = min((&imp_3)->mat_1.y, (float4((&kernelContext_6)->contact_chunks_0[c_5].mat_0) ).y);
                }
                thread float3 vc_0;
                thread float3 wc_0;
                chunk_velocity_0(c_5, &vc_0, &wc_0, &kernelContext_6);
                j_1 = 0U;
                f_sum_0 = _S172;
                t_sum_0 = _S172;
                float3 load_f_1 = load_f_0;
                float3 load_t_1 = load_t_0;
                for(;;)
                {
                    if(j_1 < _S213)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float3 _S215 = pts_4[j_1] - _S204.center_1;
                    thread float stored_2;
                    thread float diss_1;
                    float3 _S216 = penalty_force_0(total_0, _S214, ksum_0, dep_4[j_1] * crush_factor_0, nrm_4[j_1], vc_0 + cross(wc_0, _S215) - (_S199 + cross((&imp_3)->angular_velocity_1.xyz, pts_4[j_1])), _S171, total_points_0, &stored_2, &diss_1, &kernelContext_6);
                    float3 f_sum_1 = f_sum_0 + _S216;
                    float3 t_sum_1 = t_sum_0 + cross(_S215, _S216);
                    float3 load_f_2 = load_f_1 - _S216;
                    float3 load_t_2 = load_t_1 - cross(pts_4[j_1], _S216);
                    thread float _S217 = (&imp_3)->ledger_0.x;
                    thread float _S218 = (&imp_3)->ledger_0.y;
                    comp_add1_0(&_S217, &_S218, diss_1);
                    (&imp_3)->ledger_0.y = _S218;
                    (&imp_3)->ledger_0.x = _S217;
                    j_1 = j_1 + 1U;
                    f_sum_0 = f_sum_1;
                    t_sum_0 = t_sum_1;
                    load_f_1 = load_f_2;
                    load_t_1 = load_t_2;
                }
                load_f_0 = load_f_1;
                load_t_0 = load_t_1;
            }
            else
            {
                f_sum_0 = _S172;
                t_sum_0 = _S172;
            }
            uint _S219 = 2U * slot_1;
            *((&kernelContext_6)->contact_out_0+_S219) = packed_float4(float4(f_sum_0, 0.0f)) ;
            *((&kernelContext_6)->contact_out_0+(_S219 + 1U)) = packed_float4(float4(t_sum_0, 0.0f)) ;
            e_1 = e_1 + 1U;
        }
        if(((&kernelContext_6)->params_0->has_ground_0) != 0U)
        {
            float _S220 = (&kernelContext_6)->params_0->ground_modulus_0;
            float _S221 = (&imp_3)->mat_1.x;
            float3 _S222 = float3(0.0f, 0.0f, 1.0f);
            thread Box_0 _S223 = _S175;
            thread Box_0 _S224 = _S175;
            float _S225 = contact_stiffness_0(_S220, &_S223, _S221, &_S224, _S222);
            float _S226 = (&imp_3)->position_1.z - (&kernelContext_6)->params_0->ground_hi_0 + ((&imp_3)->position_err_1.z - (&kernelContext_6)->params_0->ground_lo_0);
            if(((&imp_3)->shape_0.x) == 0.0f)
            {
                total_points_0 = 1U;
            }
            else
            {
                total_points_0 = 14U;
            }
            float _S227 = _S225 / float(min(total_points_0, 5U));
            j_1 = 0U;
            uint below_0 = 0U;
            for(;;)
            {
                if(j_1 < total_points_0)
                {
                }
                else
                {
                    break;
                }
                if(((&imp_3)->shape_0.x) == 0.0f)
                {
                    f_sum_0 = float3(0.0f, 0.0f, - (&imp_3)->shape_0.y);
                }
                else
                {
                    thread Box_0 _S228 = _S175;
                    float3 _S229 = sample_point_0(&_S228, j_1);
                    f_sum_0 = _S229;
                }
                if((_S226 + f_sum_0.z) < 0.0f)
                {
                    below_0 = below_0 + 1U;
                }
                j_1 = j_1 + 1U;
            }
            j_1 = 0U;
            for(;;)
            {
                if(j_1 < total_points_0)
                {
                }
                else
                {
                    break;
                }
                if(((&imp_3)->shape_0.x) == 0.0f)
                {
                    f_sum_0 = float3(0.0f, 0.0f, - (&imp_3)->shape_0.y);
                }
                else
                {
                    thread Box_0 _S230 = _S175;
                    float3 _S231 = sample_point_0(&_S230, j_1);
                    f_sum_0 = _S231;
                }
                float depth_3 = - (_S226 + f_sum_0.z);
                if(depth_3 <= 0.0f)
                {
                    j_1 = j_1 + 1U;
                    continue;
                }
                thread float stored_3;
                thread float diss_2;
                float3 _S232 = penalty_force_0(_S227, (&imp_3)->mat_1.z, (&kernelContext_6)->params_0->ground_friction_0, depth_3, _S222, _S199 + cross((&imp_3)->angular_velocity_1.xyz, f_sum_0), _S171, below_0, &stored_3, &diss_2, &kernelContext_6);
                float3 load_f_3 = load_f_0 + _S232;
                float3 load_t_3 = load_t_0 + cross(f_sum_0, _S232);
                thread float _S233 = (&imp_3)->ledger_0.x;
                thread float _S234 = (&imp_3)->ledger_0.y;
                comp_add1_0(&_S233, &_S234, diss_2);
                (&imp_3)->ledger_0.y = _S234;
                (&imp_3)->ledger_0.x = _S233;
                load_f_0 = load_f_3;
                load_t_0 = load_t_3;
                j_1 = j_1 + 1U;
            }
        }
    }
    else
    {
        load_f_0 = _S172;
        load_t_0 = _S172;
    }
    (&imp_3)->load_force_0 = float4(load_f_0, 0.0f);
    (&imp_3)->load_torque_0 = float4(load_t_0, 0.0f);
    Impactor_natural_0 device* _S235 = (&kernelContext_6)->impactors_0+ii_0;
    _S235->position_1 = packed_float4(imp_3.position_1) ;
    _S235->position_err_1 = packed_float4(imp_3.position_err_1) ;
    _S235->velocity_1 = packed_float4(imp_3.velocity_1) ;
    _S235->velocity_err_1 = packed_float4(imp_3.velocity_err_1) ;
    _S235->angular_velocity_1 = packed_float4(imp_3.angular_velocity_1) ;
    _S235->rotation_1 = packed_float4(imp_3.rotation_1) ;
    _S235->inertia0_2 = packed_float4(imp_3.inertia0_2) ;
    _S235->inertia1_2 = packed_float4(imp_3.inertia1_2) ;
    _S235->inertia2_2 = packed_float4(imp_3.inertia2_2) ;
    _S235->inv0_2 = packed_float4(imp_3.inv0_2) ;
    _S235->inv1_2 = packed_float4(imp_3.inv1_2) ;
    _S235->inv2_2 = packed_float4(imp_3.inv2_2) ;
    _S235->shape_0 = packed_float4(imp_3.shape_0) ;
    _S235->half_1 = packed_float4(imp_3.half_1) ;
    _S235->mat_1 = packed_float4(imp_3.mat_1) ;
    _S235->crush_0 = packed_float4(imp_3.crush_0) ;
    _S235->load_force_0 = packed_float4(imp_3.load_force_0) ;
    _S235->load_torque_0 = packed_float4(imp_3.load_torque_0) ;
    _S235->ledger_0 = packed_float4(imp_3.ledger_0) ;
    _S235->cand_0 = packed_uint4(imp_3.cand_0) ;
    return;
}

[[kernel]] void contact_gather(uint3 id_2 [[thread_position_in_grid]], ContactParams_0 constant* params_3 [[buffer(0)]], Island_natural_0 device* islands_3 [[buffer(4)]], packed_uint4 device* contact_static_3 [[buffer(5)]], ChunkStatic_natural_0 device* chunks_3 [[buffer(1)]], packed_float4 device* state_3 [[buffer(3)]], ContactChunk_natural_0 device* contact_chunks_3 [[buffer(2)]], packed_float4 device* contact_out_3 [[buffer(8)]], packed_float4 device* contact_state_3 [[buffer(6)]], Impactor_natural_0 device* impactors_3 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_7;
    (&kernelContext_7)->params_0 = params_3;
    (&kernelContext_7)->islands_0 = islands_3;
    (&kernelContext_7)->contact_static_0 = contact_static_3;
    (&kernelContext_7)->chunks_0 = chunks_3;
    (&kernelContext_7)->state_0 = state_3;
    (&kernelContext_7)->contact_chunks_0 = contact_chunks_3;
    (&kernelContext_7)->contact_out_0 = contact_out_3;
    (&kernelContext_7)->contact_state_0 = contact_state_3;
    (&kernelContext_7)->impactors_0 = impactors_3;
    uint c_6 = id_2.x;
    bool _S236;
    if(c_6 >= (params_3->chunk_count_0))
    {
        _S236 = true;
    }
    else
    {
        bool _S237 = stopped_0(&kernelContext_7);
        _S236 = _S237;
    }
    if(_S236)
    {
        return;
    }
    ContactChunk_natural_0 cc_1 = (&kernelContext_7)->contact_chunks_0[c_6];
    uint4 _S238 = uint4(cc_1.info_2) ;
    if(((_S238.z) & 1U) == 0U)
    {
        return;
    }
    WorldPoint_0 _S239 = chunk_world_0(c_6, &kernelContext_7);
    float4 _S240 = float4(cc_1.start_hi_0) ;
    if((length(_S239.hi_0 - _S240.xyz + (_S239.lo_0 - (float4(cc_1.start_lo_0) ).xyz) + _S239.rel_0)) > (_S240.w))
    {
        ((&kernelContext_7)->islands_0+(&kernelContext_7)->params_0->halt_index_0)->info_0[int(2)] = ((uint4(((&kernelContext_7)->islands_0+(&kernelContext_7)->params_0->halt_index_0)->info_0) ).z) | 1U;
        return;
    }
    float3 _S241 = float3(0.0f) ;
    thread float4 ledger_2 = float4(*((&kernelContext_7)->contact_out_0+((&kernelContext_7)->params_0->ledger_base_0 + (&kernelContext_7)->params_0->pair_count_0 + c_6))) ;
    float _S242 = (&kernelContext_7)->params_0->dt_0;
    uint e_2 = _S238.x;
    float3 f_0 = _S241;
    float3 t_3 = _S241;
    for(;;)
    {
        if(e_2 < (_S238.y))
        {
        }
        else
        {
            break;
        }
        uint4 _S243 = uint4(*((&kernelContext_7)->contact_static_0+e_2)) ;
        float3 f_1;
        float3 t_4;
        if((_S243.x) == 0U)
        {
            uint _S244 = 2U * _S243.y;
            float3 t_5 = t_3 + (float4(*((&kernelContext_7)->contact_out_0+(_S244 + 1U))) ).xyz;
            f_1 = f_0 + (float4(*((&kernelContext_7)->contact_out_0+_S244)) ).xyz;
            t_4 = t_5;
            e_2 = e_2 + 1U;
            f_0 = f_1;
            t_3 = t_4;
            continue;
        }
        float above_0 = _S239.hi_0.z - (&kernelContext_7)->params_0->ground_hi_0 + (_S239.lo_0.z - (&kernelContext_7)->params_0->ground_lo_0) + _S239.rel_0.z;
        if((above_0 - (float4(cc_1.half_0) ).w) > 0.0f)
        {
            f_1 = f_0;
            t_4 = t_3;
            e_2 = e_2 + 1U;
            f_0 = f_1;
            t_3 = t_4;
            continue;
        }
        Box_0 _S245 = chunk_box_0(c_6, _S241, &kernelContext_7);
        float _S246 = (&kernelContext_7)->params_0->ground_modulus_0;
        float4 _S247 = float4(cc_1.mat_0) ;
        float _S248 = _S247.x;
        float3 _S249 = float3(0.0f, 0.0f, 1.0f);
        thread Box_0 _S250 = _S245;
        thread Box_0 _S251 = _S245;
        float _S252 = contact_stiffness_0(_S246, &_S250, _S248, &_S251, _S249);
        uint s_4 = 0U;
        uint n_11 = 0U;
        for(;;)
        {
            if(s_4 < 14U)
            {
            }
            else
            {
                break;
            }
            thread Box_0 _S253 = _S245;
            float3 _S254 = sample_point_0(&_S253, s_4);
            if((above_0 + _S254.z) < 0.0f)
            {
                n_11 = n_11 + 1U;
            }
            s_4 = s_4 + 1U;
        }
        thread float3 vc_1;
        thread float3 wc_1;
        chunk_velocity_0(c_6, &vc_1, &wc_1, &kernelContext_7);
        uint s_5 = 0U;
        f_1 = f_0;
        t_4 = t_3;
        for(;;)
        {
            if(s_5 < 14U)
            {
            }
            else
            {
                break;
            }
            thread Box_0 _S255 = _S245;
            float3 _S256 = sample_point_0(&_S255, s_5);
            float _S257 = above_0 + _S256.z;
            float depth_4 = - _S257;
            if(!(_S257 < 0.0f))
            {
                s_5 = s_5 + 1U;
                continue;
            }
            thread float stored_4;
            thread float diss_3;
            float3 _S258 = penalty_force_0(_S252 / float(max(n_11, 5U)), _S247.z, (&kernelContext_7)->params_0->ground_friction_0, depth_4, _S249, vc_1 + cross(wc_1, _S256), _S242, n_11, &stored_4, &diss_3, &kernelContext_7);
            float3 f_2 = f_1 + _S258;
            float3 t_6 = t_4 + cross(_S256, _S258);
            thread float _S259 = ledger_2.y;
            thread float _S260 = ledger_2.z;
            comp_add1_0(&_S259, &_S260, diss_3);
            ledger_2.z = _S260;
            ledger_2.y = _S259;
            f_1 = f_2;
            t_4 = t_6;
            s_5 = s_5 + 1U;
        }
        e_2 = e_2 + 1U;
        f_0 = f_1;
        t_3 = t_4;
    }
    *((&kernelContext_7)->contact_out_0+((&kernelContext_7)->params_0->ledger_base_0 + (&kernelContext_7)->params_0->pair_count_0 + c_6)) = packed_float4(ledger_2) ;
    uint _S261 = 2U * c_6;
    *((&kernelContext_7)->contact_out_0+((&kernelContext_7)->params_0->loads_base_0 + _S261)) = packed_float4(float4(f_0, 0.0f)) ;
    *((&kernelContext_7)->contact_out_0+((&kernelContext_7)->params_0->loads_base_0 + _S261 + 1U)) = packed_float4(float4(t_3, 0.0f)) ;
    return;
}

void comp_add_0(float3 thread* sum_1, float3 thread* err_1, float3 x_2)
{
    float3 t_7 = *sum_1 + x_2;
    float3 _S262 = abs(x_2);
    *err_1 = *err_1 + (select(x_2, *sum_1, (abs(*sum_1)) >= _S262) - t_7 + select(*sum_1, x_2, (abs(*sum_1)) >= _S262));
    *sum_1 = t_7;
    return;
}

float3 inverse_rotate_0(const Quat_0 thread* q_9, float3 v_5)
{
    thread Quat_0 c_7;
    (&c_7)->w_0 = q_9->w_0;
    (&c_7)->x_0 = - q_9->x_0;
    (&c_7)->y_0 = - q_9->y_0;
    (&c_7)->z_0 = - q_9->z_0;
    thread Quat_0 _S263 = c_7;
    float3 _S264 = rotate_0(&_S263, v_5);
    return _S264;
}

float3 rows_mul_0(float4 r0_0, float4 r1_0, float4 r2_0, float3 v_6)
{
    return float3(dot(r0_0.xyz, v_6), dot(r1_0.xyz, v_6), dot(r2_0.xyz, v_6));
}

float3 world_mul_0(const Quat_0 thread* q_10, float4 r0_1, float4 r1_1, float4 r2_1, float3 v_7)
{
    float3 _S265 = inverse_rotate_0(q_10, v_7);
    float3 _S266 = rotate_1(q_10, rows_mul_0(r0_1, r1_1, r2_1, _S265));
    return _S266;
}

Quat_0 quat_mul_0(const Quat_0 thread* a_4, const Quat_0 thread* o_0)
{
    thread Quat_0 r_3;
    (&r_3)->w_0 = a_4->w_0 * o_0->w_0 - a_4->x_0 * o_0->x_0 - a_4->y_0 * o_0->y_0 - a_4->z_0 * o_0->z_0;
    (&r_3)->x_0 = a_4->w_0 * o_0->x_0 + a_4->x_0 * o_0->w_0 + a_4->y_0 * o_0->z_0 - a_4->z_0 * o_0->y_0;
    (&r_3)->y_0 = a_4->w_0 * o_0->y_0 - a_4->x_0 * o_0->z_0 + a_4->y_0 * o_0->w_0 + a_4->z_0 * o_0->x_0;
    (&r_3)->z_0 = a_4->w_0 * o_0->z_0 + a_4->x_0 * o_0->y_0 - a_4->y_0 * o_0->x_0 + a_4->z_0 * o_0->w_0;
    return r_3;
}

Quat_0 normalized_0(const Quat_0 thread* q_11)
{
    float n_12 = sqrt(q_11->w_0 * q_11->w_0 + q_11->x_0 * q_11->x_0 + q_11->y_0 * q_11->y_0 + q_11->z_0 * q_11->z_0);
    thread Quat_0 r_4;
    (&r_4)->w_0 = q_11->w_0 / n_12;
    (&r_4)->x_0 = q_11->x_0 / n_12;
    (&r_4)->y_0 = q_11->y_0 / n_12;
    (&r_4)->z_0 = q_11->z_0 / n_12;
    return r_4;
}

Quat_0 integrate_rotation_0(const Quat_0 thread* q_12, float3 omega_0, float dt_2)
{
    float angle_1 = length(omega_0) * dt_2;
    if(angle_1 < 1.00000000317107685e-30f)
    {
        return *q_12;
    }
    thread Quat_0 _S267 = from_axis_angle_0(omega_0, angle_1);
    Quat_0 _S268 = quat_mul_0(&_S267, q_12);
    thread Quat_0 _S269 = _S268;
    Quat_0 _S270 = normalized_0(&_S269);
    return _S270;
}

float4 quat_vec_0(const Quat_0 thread* q_13)
{
    return float4(q_13->x_0, q_13->y_0, q_13->z_0, q_13->w_0);
}

[[kernel]] void impactor_integrate(uint3 id_3 [[thread_position_in_grid]], ContactParams_0 constant* params_4 [[buffer(0)]], Island_natural_0 device* islands_4 [[buffer(4)]], packed_uint4 device* contact_static_4 [[buffer(5)]], ChunkStatic_natural_0 device* chunks_4 [[buffer(1)]], packed_float4 device* state_4 [[buffer(3)]], ContactChunk_natural_0 device* contact_chunks_4 [[buffer(2)]], packed_float4 device* contact_out_4 [[buffer(8)]], packed_float4 device* contact_state_4 [[buffer(6)]], Impactor_natural_0 device* impactors_4 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_8;
    (&kernelContext_8)->params_0 = params_4;
    (&kernelContext_8)->islands_0 = islands_4;
    (&kernelContext_8)->contact_static_0 = contact_static_4;
    (&kernelContext_8)->chunks_0 = chunks_4;
    (&kernelContext_8)->state_0 = state_4;
    (&kernelContext_8)->contact_chunks_0 = contact_chunks_4;
    (&kernelContext_8)->contact_out_0 = contact_out_4;
    (&kernelContext_8)->contact_state_0 = contact_state_4;
    (&kernelContext_8)->impactors_0 = impactors_4;
    uint ii_1 = id_3.x;
    if(ii_1 >= (params_4->impactor_count_0))
    {
        return;
    }
    Island_natural_0 device* _S271 = (&kernelContext_8)->islands_0+(&kernelContext_8)->params_0->halt_index_0;
    Impactor_natural_0 device* _S272 = (&kernelContext_8)->impactors_0+ii_1;
    float4 _S273 = float4((*_S272).position_err_1) ;
    float4 _S274 = float4((*_S272).velocity_1) ;
    float4 _S275 = float4((*_S272).velocity_err_1) ;
    float4 _S276 = float4((*_S272).angular_velocity_1) ;
    float4 _S277 = float4((*_S272).rotation_1) ;
    float4 _S278 = float4((*_S272).inertia0_2) ;
    float4 _S279 = float4((*_S272).inertia1_2) ;
    float4 _S280 = float4((*_S272).inertia2_2) ;
    float4 _S281 = float4((*_S272).inv0_2) ;
    float4 _S282 = float4((*_S272).inv1_2) ;
    float4 _S283 = float4((*_S272).inv2_2) ;
    float4 _S284 = float4((*_S272).shape_0) ;
    float4 _S285 = float4((*_S272).half_1) ;
    float4 _S286 = float4((*_S272).mat_1) ;
    float4 _S287 = float4((*_S272).crush_0) ;
    float4 _S288 = float4((*_S272).load_force_0) ;
    float4 _S289 = float4((*_S272).load_torque_0) ;
    float4 _S290 = float4((*_S272).ledger_0) ;
    uint4 _S291 = uint4((*_S272).cand_0) ;
    thread Impactor_0 imp_4;
    (&imp_4)->position_1 = float4((*_S272).position_1) ;
    (&imp_4)->position_err_1 = _S273;
    (&imp_4)->velocity_1 = _S274;
    (&imp_4)->velocity_err_1 = _S275;
    (&imp_4)->angular_velocity_1 = _S276;
    (&imp_4)->rotation_1 = _S277;
    (&imp_4)->inertia0_2 = _S278;
    (&imp_4)->inertia1_2 = _S279;
    (&imp_4)->inertia2_2 = _S280;
    (&imp_4)->inv0_2 = _S281;
    (&imp_4)->inv1_2 = _S282;
    (&imp_4)->inv2_2 = _S283;
    (&imp_4)->shape_0 = _S284;
    (&imp_4)->half_1 = _S285;
    (&imp_4)->mat_1 = _S286;
    (&imp_4)->crush_0 = _S287;
    (&imp_4)->load_force_0 = _S288;
    (&imp_4)->load_torque_0 = _S289;
    (&imp_4)->ledger_0 = _S290;
    (&imp_4)->cand_0 = _S291;
    bool _S292;
    if(((&imp_4)->cand_0.z) != 0U)
    {
        _S292 = true;
    }
    else
    {
        _S292 = (((uint4(_S271->info_0) ).z) & 1U) != 0U;
    }
    if(_S292)
    {
        _S292 = true;
    }
    else
    {
        uint _S293 = (uint4(_S271->info_0) ).y;
        if(_S293 != 0U)
        {
            _S292 = ((&imp_4)->cand_0.w) >= _S293;
        }
        else
        {
            _S292 = false;
        }
    }
    if(_S292)
    {
        return;
    }
    (&imp_4)->cand_0.w = (&imp_4)->cand_0.w + 1U;
    float dt_3 = (&kernelContext_8)->params_0->dt_0;
    float m_1 = (&imp_4)->mat_1.z;
    thread float3 vel_0 = (&imp_4)->velocity_1.xyz;
    thread float3 vel_err_0 = (&imp_4)->velocity_err_1.xyz;
    float3 _S294 = float3(dt_3) ;
    comp_add_0(&vel_0, &vel_err_0, ((&imp_4)->load_force_0.xyz / float3(m_1)  + (&kernelContext_8)->params_0->gravity_0.xyz) * _S294);
    Quat_0 q_14 = quat_of_0((&imp_4)->rotation_1);
    float3 _S295 = (&imp_4)->angular_velocity_1.xyz;
    thread Quat_0 _S296 = q_14;
    float3 _S297 = world_mul_0(&_S296, (&imp_4)->inertia0_2, (&imp_4)->inertia1_2, (&imp_4)->inertia2_2, _S295);
    float3 l_1 = _S297 + (&imp_4)->load_torque_0.xyz * _S294;
    thread Quat_0 _S298 = q_14;
    float3 _S299 = world_mul_0(&_S298, (&imp_4)->inv0_2, (&imp_4)->inv1_2, (&imp_4)->inv2_2, l_1);
    thread float3 pos_0 = (&imp_4)->position_1.xyz;
    thread float3 pos_err_0 = (&imp_4)->position_err_1.xyz;
    comp_add_0(&pos_0, &pos_err_0, (vel_0 + vel_err_0) * _S294);
    thread Quat_0 _S300 = q_14;
    Quat_0 _S301 = integrate_rotation_0(&_S300, _S299, dt_3);
    thread Quat_0 _S302 = _S301;
    float3 _S303 = world_mul_0(&_S302, (&imp_4)->inv0_2, (&imp_4)->inv1_2, (&imp_4)->inv2_2, l_1);
    (&imp_4)->angular_velocity_1 = float4(_S303, 0.0f);
    thread Quat_0 _S304 = _S301;
    float4 _S305 = quat_vec_0(&_S304);
    (&imp_4)->rotation_1 = _S305;
    (&imp_4)->position_1 = float4(pos_0, 0.0f);
    (&imp_4)->position_err_1 = float4(pos_err_0, 0.0f);
    (&imp_4)->velocity_1 = float4(vel_0, 0.0f);
    (&imp_4)->velocity_err_1 = float4(vel_err_0, 0.0f);
    Impactor_natural_0 device* _S306 = (&kernelContext_8)->impactors_0+ii_1;
    _S306->position_1 = packed_float4(imp_4.position_1) ;
    _S306->position_err_1 = packed_float4(imp_4.position_err_1) ;
    _S306->velocity_1 = packed_float4(imp_4.velocity_1) ;
    _S306->velocity_err_1 = packed_float4(imp_4.velocity_err_1) ;
    _S306->angular_velocity_1 = packed_float4(imp_4.angular_velocity_1) ;
    _S306->rotation_1 = packed_float4(imp_4.rotation_1) ;
    _S306->inertia0_2 = packed_float4(imp_4.inertia0_2) ;
    _S306->inertia1_2 = packed_float4(imp_4.inertia1_2) ;
    _S306->inertia2_2 = packed_float4(imp_4.inertia2_2) ;
    _S306->inv0_2 = packed_float4(imp_4.inv0_2) ;
    _S306->inv1_2 = packed_float4(imp_4.inv1_2) ;
    _S306->inv2_2 = packed_float4(imp_4.inv2_2) ;
    _S306->shape_0 = packed_float4(imp_4.shape_0) ;
    _S306->half_1 = packed_float4(imp_4.half_1) ;
    _S306->mat_1 = packed_float4(imp_4.mat_1) ;
    _S306->crush_0 = packed_float4(imp_4.crush_0) ;
    _S306->load_force_0 = packed_float4(imp_4.load_force_0) ;
    _S306->load_torque_0 = packed_float4(imp_4.load_torque_0) ;
    _S306->ledger_0 = packed_float4(imp_4.ledger_0) ;
    _S306->cand_0 = packed_uint4(imp_4.cand_0) ;
    uint k_5 = (&imp_4)->cand_0.w - 1U - (&kernelContext_8)->params_0->step_start_0;
    if(k_5 < ((&kernelContext_8)->params_0->record_stride_0))
    {
        uint at_0 = (&kernelContext_8)->params_0->loads_base_0 + 2U * (&kernelContext_8)->params_0->chunk_count_0 + 2U * (ii_1 * (&kernelContext_8)->params_0->record_stride_0 + k_5);
        *((&kernelContext_8)->contact_out_0+at_0) = packed_float4(float4(vel_0 + vel_err_0, 0.0f)) ;
        *((&kernelContext_8)->contact_out_0+(at_0 + 1U)) = packed_float4(float4(pos_0 + pos_err_0, 0.0f)) ;
    }
    return;
}

