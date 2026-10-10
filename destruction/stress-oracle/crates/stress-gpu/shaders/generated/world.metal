#include <metal_stdlib>
#include <metal_math>
#include <metal_texture>
using namespace metal;
struct Params_0
{
    float4 gravity_0;
    float dt_0;
    uint fracture_0;
    uint rigid_motion_loads_0;
    uint step_start_0;
    float t_hi_0;
    float t_lo_0;
    uint max_steps_0;
    uint contact_mode_0;
    uint halt_index_0;
    uint chunk_count_0;
    uint pair_count_0;
    uint impactor_count_0;
    uint cand_count_0;
    uint probe_base_0;
    uint probe_stride_0;
    uint slot_base_0;
    uint ledger_base_0;
    uint record_base_0;
    uint record_stride_0;
    uint cand_base_0;
    uint pair_index_0;
    uint cand_index_0;
    float zeta_0;
    float pair_friction_0;
    float ground_hi_0;
    float ground_lo_0;
    float ground_friction_0;
    float ground_modulus_0;
    uint has_ground_0;
    uint pad0_0;
    uint pad1_0;
    uint pad2_0;
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
    packed_float4 half_0;
    packed_float4 crot0_0;
    packed_float4 crot1_0;
    packed_float4 crot2_0;
    packed_float4 cmat_0;
    packed_float4 start_hi_0;
    packed_float4 start_lo_0;
    packed_uint4 cinfo_0;
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
    packed_float4 mat_0;
    packed_float4 crush_0;
    packed_float4 geom_0;
    packed_float4 unused_0;
    packed_float4 ledger_0;
    packed_uint4 cand_0;
};

struct JointBond_natural_0
{
    packed_float4 geom0_0;
    packed_float4 geom1_0;
    packed_float4 stiff0_0;
    packed_float4 stiff1_0;
    packed_float4 rebar0_0;
    packed_float4 rebar1_0;
    packed_uint4 ids_0;
};

struct BondStatic_natural_0
{
    packed_float4 t1_0;
    packed_float4 t2_0;
    packed_float4 normal_0;
    packed_float4 ra_0;
    packed_float4 rb_0;
    packed_float4 centroid_0;
    packed_float4 c_lin_0;
    packed_float4 c_ang_0;
    JointBond_natural_0 law_0;
};

struct JointState_0
{
    float damage_0;
    float crush_1;
    float kappa_0;
    float kappa_c_0;
    float ductility_0;
    float ductility_c_0;
    float fatigue_0;
    float plastic_x_0;
    float plastic_y_0;
    float plastic_t_0;
    float rebar_plastic_0;
    float rebar_slip0_0;
    float rebar_slip1_0;
    float rebar_work_0;
    float rebar_broken_0;
    float strain_rate_0;
    float governing_stress_0;
    float dissipated_0;
    float utilization_0;
    uint mode_0;
};

struct BondDyn_natural_0
{
    JointState_0 js_0;
    packed_float4 force_lin_0;
    packed_float4 force_ang_0;
    packed_float4 sums_0;
    packed_float4 comps_0;
    packed_uint4 events_0;
};

struct JointMaterial_0
{
    float4 strength_0;
    float4 energy_1;
    float4 dif_0;
    float4 misc_0;
    uint4 kind_flags_0;
};

struct MaterialTable_0
{
    array<JointMaterial_0, int(64)> m_0;
};

struct KernelContext_0
{
    Params_0 constant* params_0;
    Island_natural_0 device* islands_0;
    uint device* index_0;
    ChunkStatic_natural_0 device* chunks_0;
    packed_float4 device* state_0;
    packed_float4 device* scratch_0;
    packed_float4 device* contact_state_0;
    Impactor_natural_0 device* impactors_0;
    packed_float4 device* loads_0;
    BondStatic_natural_0 device* bonds_0;
    BondDyn_natural_0 device* bond_dyn_0;
    MaterialTable_0 constant* materials_0;
    array<float4, int(256)> threadgroup* g_red_a_0;
    array<float4, int(256)> threadgroup* g_red_b_0;
    uint threadgroup* g_run_0;
    uint threadgroup* g_halt_0;
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
    ChunkStatic_natural_0 device* _S10 = kernelContext_2->chunks_0+c_1;
    Quat_0 q_5 = quat_of_0(float4((kernelContext_2->islands_0+(uint4(_S10->info_1) ).y)->rotation_0) );
    float3 th_0 = (float4(*(kernelContext_2->state_0+(4U * c_1 + 1U))) ).xyz;
    Quat_0 hidden_0 = from_axis_angle_0(th_0, length(th_0));
    thread Box_0 b_1;
    (&b_1)->center_1 = center_2;
    float4 _S11 = float4(_S10->crot0_0) ;
    float4 _S12 = float4(_S10->crot1_0) ;
    float4 _S13 = float4(_S10->crot2_0) ;
    float3 _S14 = float3(_S11.x, _S12.x, _S13.x);
    thread Quat_0 _S15 = hidden_0;
    float3 _S16 = rotate_0(&_S15, _S14);
    thread Quat_0 _S17 = q_5;
    float3 _S18 = rotate_0(&_S17, _S16);
    (&b_1)->axis0_0 = _S18;
    float3 _S19 = float3(_S11.y, _S12.y, _S13.y);
    thread Quat_0 _S20 = hidden_0;
    float3 _S21 = rotate_0(&_S20, _S19);
    thread Quat_0 _S22 = q_5;
    float3 _S23 = rotate_0(&_S22, _S21);
    (&b_1)->axis1_0 = _S23;
    float3 _S24 = float3(_S11.z, _S12.z, _S13.z);
    thread Quat_0 _S25 = hidden_0;
    float3 _S26 = rotate_0(&_S25, _S24);
    thread Quat_0 _S27 = q_5;
    float3 _S28 = rotate_0(&_S27, _S26);
    (&b_1)->axis2_0 = _S28;
    (&b_1)->half_2 = (float4(_S10->half_0) ).xyz;
    return b_1;
}

bool may_overlap_0(const Box_0 thread* a_2, const Box_0 thread* b_2)
{
    float3 _S29 = b_2->center_1 - a_2->center_1;
    float3 _S30 = a_2->half_2;
    float3 _S31 = b_2->half_2;
    float _S32 = 0.00000999999974738f * (length(a_2->half_2) + length(b_2->half_2));
    float3 _S33 = a_2->axis0_0;
    float3 _S34 = a_2->axis1_0;
    float3 _S35 = a_2->axis2_0;
    float3 _S36 = b_2->axis0_0;
    float3 _S37 = b_2->axis1_0;
    float3 _S38 = b_2->axis2_0;
    array<float3, int(6)> _S39 = { { a_2->axis0_0, a_2->axis1_0, a_2->axis2_0, b_2->axis0_0, b_2->axis1_0, b_2->axis2_0 } };
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
            l_0 = _S39[i_0];
        }
        else
        {
            uint _S40 = i_0 - 6U;
            l_0 = cross(_S39[_S40 / 3U], _S39[3U + _S40 % 3U]);
        }
        float len_0 = length(l_0);
        if(len_0 <= 9.99999997475242708e-07f)
        {
            i_0 = i_0 + 1U;
            continue;
        }
        if((abs(dot(_S29, l_0))) > (_S30.x * abs(dot(_S33, l_0)) + _S30.y * abs(dot(_S34, l_0)) + _S30.z * abs(dot(_S35, l_0)) + (_S31.x * abs(dot(_S36, l_0)) + _S31.y * abs(dot(_S37, l_0)) + _S31.z * abs(dot(_S38, l_0))) + _S32 * len_0))
        {
            return false;
        }
        i_0 = i_0 + 1U;
    }
    return true;
}

float3 box_axis_0(const Box_0 thread* b_3, uint k_0)
{
    float3 _S41;
    if(k_0 == 0U)
    {
        _S41 = b_3->axis0_0;
    }
    else
    {
        if(k_0 == 1U)
        {
            _S41 = b_3->axis1_0;
        }
        else
        {
            _S41 = b_3->axis2_0;
        }
    }
    return _S41;
}

float comp3_0(float3 v_3, uint k_1)
{
    float _S42;
    if(k_1 == 0U)
    {
        _S42 = v_3.x;
    }
    else
    {
        if(k_1 == 1U)
        {
            _S42 = v_3.y;
        }
        else
        {
            _S42 = v_3.z;
        }
    }
    return _S42;
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
        float _S43;
        if((i_1 & 2U) == 0U)
        {
            _S43 = - h_0.y;
        }
        else
        {
            _S43 = h_0.y;
        }
        float _S44;
        if((i_1 & 4U) == 0U)
        {
            _S44 = - h_0.z;
        }
        else
        {
            _S44 = h_0.z;
        }
        return b_4->center_1 + b_4->axis0_0 * float3(sign_0)  + b_4->axis1_0 * float3(_S43)  + b_4->axis2_0 * float3(_S44) ;
    }
    uint _S45 = i_1 - 8U;
    uint axis_1 = _S45 / 2U;
    if((_S45 % 2U) == 0U)
    {
        sign_0 = -1.0f;
    }
    else
    {
        sign_0 = 1.0f;
    }
    float3 _S46 = b_4->center_1;
    float3 _S47 = box_axis_0(b_4, axis_1);
    return _S46 + _S47 * float3((sign_0 * comp3_0(b_4->half_2, axis_1))) ;
}

bool penetration_0(const Box_0 thread* b_5, float3 p_0, float thread* depth_0, float3 thread* normal_1)
{
    *depth_0 = 0.0f;
    *normal_1 = float3(0.0f) ;
    float3 r_1 = p_0 - b_5->center_1;
    float3 _S48 = b_5->half_2;
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
        float3 _S49 = box_axis_0(b_5, k_2);
        float local_0 = dot(r_1, _S49);
        float d_0 = comp3_0(_S48, k_2) - abs(local_0);
        if(d_0 <= 0.0f)
        {
            return false;
        }
        if(d_0 < best_0)
        {
            float _S50;
            if(local_0 >= 0.0f)
            {
                _S50 = 1.0f;
            }
            else
            {
                _S50 = -1.0f;
            }
            best_0 = d_0;
            axis_2 = k_2;
            side_0 = _S50;
        }
        k_2 = k_2 + 1U;
    }
    *depth_0 = best_0;
    float3 _S51 = box_axis_0(b_5, axis_2);
    *normal_1 = _S51 * float3(side_0) ;
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
        float3 _S52 = box_axis_0(b_6, k_3);
        float c_2 = abs(dot(d_1, _S52));
        float h_2 = h_1 + c_2 * comp3_0(b_6->half_2, k_3);
        uint _S53 = k_3 + 1U;
        float area_1 = area_0 + c_2 * 4.0f * comp3_0(b_6->half_2, _S53 % 3U) * comp3_0(b_6->half_2, (k_3 + 2U) % 3U);
        k_3 = _S53;
        h_1 = h_2;
        area_0 = area_1;
    }
    return float2(h_1, area_0);
}

float contact_stiffness_0(float ea_0, const Box_0 thread* a_3, float eb_0, const Box_0 thread* b_7, float3 dir_0)
{
    float3 d_2 = safe_normalize_0(dir_0);
    float2 _S54 = half_thickness_and_area_0(a_3, d_2);
    float2 _S55 = half_thickness_and_area_0(b_7, d_2);
    return min(_S54.y, _S55.y) / (_S54.x / ea_0 + _S55.x / eb_0);
}

void chunk_velocity_0(uint c_3, float3 thread* v_4, float3 thread* w_2, KernelContext_0 thread* kernelContext_3)
{
    ChunkStatic_natural_0 device* _S56 = kernelContext_3->chunks_0+c_3;
    Island_natural_0 device* _S57 = kernelContext_3->islands_0+(uint4(_S56->info_1) ).y;
    Quat_0 q_6 = quat_of_0(float4(_S57->rotation_0) );
    uint _S58 = 4U * c_3;
    float3 _S59 = (float4(_S56->center_0) ).xyz + (float4(*(kernelContext_3->state_0+_S58)) ).xyz - (float4(_S57->com_0) ).xyz;
    thread Quat_0 _S60 = q_6;
    float3 _S61 = rotate_0(&_S60, _S59);
    float3 _S62 = (float4(_S57->angular_velocity_0) ).xyz;
    float3 _S63 = (float4(_S57->velocity_0) ).xyz + (float4(_S57->velocity_err_0) ).xyz + cross(_S62, _S61);
    float3 _S64 = (float4(*(kernelContext_3->state_0+(_S58 + 2U))) ).xyz;
    thread Quat_0 _S65 = q_6;
    float3 _S66 = rotate_0(&_S65, _S64);
    *v_4 = _S63 + _S66;
    float3 _S67 = (float4(*(kernelContext_3->state_0+(_S58 + 3U))) ).xyz;
    thread Quat_0 _S68 = q_6;
    float3 _S69 = rotate_0(&_S68, _S67);
    *w_2 = _S62 + _S69;
    return;
}

float3 penalty_force_0(float k_4, float m_red_0, float friction_0, float depth_1, float3 normal_2, float3 rel_velocity_0, float dt_1, uint points_0, float thread* stored_0, float thread* dissipated_1, KernelContext_0 thread* kernelContext_4)
{
    float c_max_0 = 1.0f / max(float(points_0), 10.0f) * m_red_0 / dt_1;
    float vn_0 = dot(rel_velocity_0, normal_2);
    float _S70 = k_4 * depth_1;
    float _S71 = min(2.0f * kernelContext_4->params_0->zeta_0 * sqrt(k_4 * m_red_0), c_max_0) * vn_0;
    float _S72 = _S70 - _S71;
    float _S73 = max(_S72, 0.0f);
    float3 vt_0 = rel_velocity_0 - normal_2 * float3(vn_0) ;
    float vt_mag_0 = length(vt_0);
    float _S74 = friction_0 * _S73;
    float _S75 = min(_S74, min(c_max_0, _S74 / 0.00100000004749745f) * vt_mag_0);
    float3 ft_0;
    if(vt_mag_0 > 0.0f)
    {
        ft_0 = - vt_0 * float3((_S75 / vt_mag_0)) ;
    }
    else
    {
        ft_0 = float3(0.0f) ;
    }
    *stored_0 = 0.5f * k_4 * depth_1 * depth_1;
    float damping_power_0;
    if(_S72 > 0.0f)
    {
        damping_power_0 = _S71 * vn_0;
    }
    else
    {
        damping_power_0 = _S70 * max(vn_0, 0.0f);
    }
    *dissipated_1 = (damping_power_0 + length(ft_0) * vt_mag_0) * dt_1;
    return normal_2 * float3(_S73)  + ft_0;
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

void pair_contact_0(uint i_2, KernelContext_0 thread* kernelContext_5)
{
    uint at_0 = kernelContext_5->params_0->pair_index_0 + 6U * i_2;
    uint ca_0 = kernelContext_5->index_0[at_0];
    uint cb_0 = kernelContext_5->index_0[at_0 + 1U];
    uint _S76 = kernelContext_5->index_0[at_0 + 3U] * 28U;
    float _S77 = (as_type<float>((kernelContext_5->index_0[at_0 + 4U])));
    float _S78 = (as_type<float>((kernelContext_5->index_0[at_0 + 5U])));
    float _S79 = kernelContext_5->params_0->dt_0;
    uint out_0 = kernelContext_5->params_0->slot_base_0 + 2U * kernelContext_5->index_0[at_0 + 2U];
    WorldPoint_0 _S80 = chunk_world_0(ca_0, kernelContext_5);
    WorldPoint_0 _S81 = chunk_world_0(cb_0, kernelContext_5);
    thread WorldPoint_0 _S82 = _S81;
    thread WorldPoint_0 _S83 = _S80;
    float3 _S84 = world_diff_0(&_S82, &_S83);
    bool touching_0 = !((length(_S84)) > ((float4((kernelContext_5->chunks_0+ca_0)->half_0) ).w + (float4((kernelContext_5->chunks_0+cb_0)->half_0) ).w));
    float4 _S85 = float4(*(kernelContext_5->scratch_0+(kernelContext_5->params_0->ledger_base_0 + i_2))) ;
    thread float4 ledger_1 = _S85;
    uint flags_0 = (as_type<uint>((_S85.w)));
    uint e_0;
    bool has_state_0;
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
                *(kernelContext_5->contact_state_0+(_S76 + e_0)) = packed_float4(float4((as_type<float>((2143289344U))), 0.0f, 0.0f, 0.0f)) ;
                e_0 = e_0 + 1U;
            }
        }
        if((flags_0 & 2U) != 0U)
        {
            e_0 = 0U;
            for(;;)
            {
                if(e_0 < 4U)
                {
                }
                else
                {
                    break;
                }
                *(kernelContext_5->scratch_0+(out_0 + e_0)) = packed_float4(float4(0.0f) ) ;
                e_0 = e_0 + 1U;
            }
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
            *(kernelContext_5->scratch_0+(kernelContext_5->params_0->ledger_base_0 + i_2)) = packed_float4(ledger_1) ;
        }
        return;
    }
    float3 _S86 = float3(0.0f) ;
    Box_0 _S87 = chunk_box_0(ca_0, _S86, kernelContext_5);
    Box_0 _S88 = chunk_box_0(cb_0, _S84, kernelContext_5);
    thread Box_0 _S89 = _S87;
    thread Box_0 _S90 = _S88;
    bool _S91 = may_overlap_0(&_S89, &_S90);
    uint s_1;
    uint count_0;
    float3 fa_0;
    float3 ta_0;
    float3 fb_0;
    float3 tb_0;
    float stored_sum_0;
    if(_S91)
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
            thread Box_0 _S92 = _S87;
            float3 _S93 = sample_point_0(&_S92, s_1);
            thread Box_0 _S94 = _S88;
            thread float d_3;
            thread float3 n_1;
            bool _S95 = penetration_0(&_S94, _S93, &d_3, &n_1);
            if(_S95)
            {
                pts_0[count_0] = _S93;
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
            thread Box_0 _S96 = _S88;
            float3 _S97 = sample_point_0(&_S96, s_1);
            thread Box_0 _S98 = _S87;
            thread float d_4;
            thread float3 n_2;
            bool _S99 = penetration_0(&_S98, _S97, &d_4, &n_2);
            if(_S99)
            {
                pts_0[count_0] = _S97;
                nrm_0[count_0] = - n_2;
                dep_0[count_0] = d_4;
                idx_0[count_0] = 14U + s_1;
                count_0 = count_0 + 1U;
            }
            s_1 = s_1 + 1U;
        }
        if(count_0 > 0U)
        {
            float _S100 = (float4((kernelContext_5->chunks_0+ca_0)->cmat_0) ).x;
            float _S101 = (float4((kernelContext_5->chunks_0+cb_0)->cmat_0) ).x;
            float3 _S102 = _S88.center_1 - _S87.center_1;
            thread Box_0 _S103 = _S87;
            thread Box_0 _S104 = _S88;
            float _S105 = contact_stiffness_0(_S100, &_S103, _S101, &_S104, _S102);
            thread float3 va0_0;
            thread float3 wa0_0;
            chunk_velocity_0(ca_0, &va0_0, &wa0_0, kernelContext_5);
            thread float3 vb0_0;
            thread float3 wb0_0;
            chunk_velocity_0(cb_0, &vb0_0, &wb0_0, kernelContext_5);
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
                uint _S106 = _S76 + idx_0[j_0];
                float4 _S107 = float4(*(kernelContext_5->contact_state_0+_S106)) ;
                thread float4 entry_0 = _S107;
                float3 p_1 = pts_0[j_0];
                float3 n_3 = nrm_0[j_0];
                if(isnan(_S107.x))
                {
                    has_state_0 = true;
                }
                else
                {
                    has_state_0 = (dot(entry_0.yzw, n_3)) < 0.99000000953674316f;
                }
                if(has_state_0)
                {
                    if((dep_0[j_0]) > (2.0f * abs(dot(va0_0 + cross(wa0_0, p_1) - (vb0_0 + cross(wb0_0, p_1 - _S88.center_1)), n_3)) * _S79 + 9.99999971718068537e-10f))
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
                *(kernelContext_5->contact_state_0+_S106) = packed_float4(entry_0) ;
                float _S108 = dep_0[j_0] - entry_0.x;
                eff_0[j_0] = _S108;
                if(_S108 > 0.0f)
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
                    *(kernelContext_5->contact_state_0+(_S76 + e_0)) = packed_float4(float4((as_type<float>((2143289344U))), 0.0f, 0.0f, 0.0f)) ;
                }
                e_0 = e_0 + 1U;
            }
            float _S109 = _S105 / max(float(engaged_0), 10.0f);
            j_0 = 0U;
            fa_0 = _S86;
            ta_0 = _S86;
            fb_0 = _S86;
            tb_0 = _S86;
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
                float3 _S110 = pts_0[j_0] - _S88.center_1;
                thread float stored_1;
                thread float diss_0;
                float3 _S111 = penalty_force_0(_S109, _S77, _S78, eff_0[j_0], nrm_0[j_0], va0_0 + cross(wa0_0, pts_0[j_0]) - (vb0_0 + cross(wb0_0, _S110)), _S79, engaged_0, &stored_1, &diss_0, kernelContext_5);
                float3 fa_1 = fa_0 + _S111;
                float3 ta_1 = ta_0 + cross(pts_0[j_0], _S111);
                float3 _S112 = - _S111;
                float3 fb_1 = fb_0 + _S112;
                float3 tb_1 = tb_0 + cross(_S110, _S112);
                float stored_sum_1 = stored_sum_0 + stored_1;
                thread float _S113 = ledger_1.y;
                thread float _S114 = ledger_1.z;
                comp_add1_0(&_S113, &_S114, diss_0);
                ledger_1.z = _S114;
                ledger_1.y = _S113;
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
            fa_0 = _S86;
            ta_0 = _S86;
            fb_0 = _S86;
            tb_0 = _S86;
            stored_sum_0 = 0.0f;
        }
    }
    else
    {
        has_state_0 = false;
        fa_0 = _S86;
        ta_0 = _S86;
        fb_0 = _S86;
        tb_0 = _S86;
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
            *(kernelContext_5->contact_state_0+(_S76 + e_0)) = packed_float4(float4((as_type<float>((2143289344U))), 0.0f, 0.0f, 0.0f)) ;
            e_0 = e_0 + 1U;
        }
    }
    float3 _S115 = float3(0.0f) ;
    if(any(fa_0 != _S115))
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any(ta_0 != _S115);
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any(fb_0 != _S115);
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any(tb_0 != _S115);
    }
    bool _S116;
    if(loaded_0)
    {
        _S116 = true;
    }
    else
    {
        _S116 = (flags_0 & 2U) != 0U;
    }
    if(_S116)
    {
        *(kernelContext_5->scratch_0+out_0) = packed_float4(float4(fa_0, 0.0f)) ;
        *(kernelContext_5->scratch_0+(out_0 + 1U)) = packed_float4(float4(ta_0, 0.0f)) ;
        *(kernelContext_5->scratch_0+(out_0 + 2U)) = packed_float4(float4(fb_0, 0.0f)) ;
        *(kernelContext_5->scratch_0+(out_0 + 3U)) = packed_float4(float4(tb_0, 0.0f)) ;
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
    *(kernelContext_5->scratch_0+(kernelContext_5->params_0->ledger_base_0 + i_2)) = packed_float4(ledger_1) ;
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
    float4 mat_0;
    float4 crush_0;
    float4 geom_0;
    float4 unused_0;
    float4 ledger_0;
    uint4 cand_0;
};

Box_0 impactor_box_0(const Impactor_0 thread* imp_0, float3 center_3, float3 half_3)
{
    Quat_0 q_7 = quat_of_0(imp_0->rotation_1);
    thread Box_0 b_8;
    (&b_8)->center_1 = center_3;
    float3 _S117 = float3(1.0f, 0.0f, 0.0f);
    thread Quat_0 _S118 = q_7;
    float3 _S119 = rotate_0(&_S118, _S117);
    (&b_8)->axis0_0 = _S119;
    float3 _S120 = float3(0.0f, 1.0f, 0.0f);
    thread Quat_0 _S121 = q_7;
    float3 _S122 = rotate_0(&_S121, _S120);
    (&b_8)->axis1_0 = _S122;
    float3 _S123 = float3(0.0f, 0.0f, 1.0f);
    thread Quat_0 _S124 = q_7;
    float3 _S125 = rotate_0(&_S124, _S123);
    (&b_8)->axis2_0 = _S125;
    (&b_8)->half_2 = half_3;
    return b_8;
}

bool sphere_contact_0(const Box_0 thread* b_9, float3 center_4, float radius_0, float3 thread* point_0, float3 thread* normal_3, float thread* depth_2)
{
    float3 _S126 = float3(0.0f) ;
    *point_0 = _S126;
    *normal_3 = _S126;
    *depth_2 = 0.0f;
    float3 _S127 = b_9->center_1;
    float3 r_2 = center_4 - b_9->center_1;
    float3 _S128 = b_9->axis0_0;
    float3 _S129 = b_9->axis1_0;
    float3 _S130 = b_9->axis2_0;
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
        *normal_3 = _S128 * float3(dn_0.x)  + _S129 * float3(dn_0.y)  + _S130 * float3(dn_0.z) ;
        *point_0 = _S127 + _S128 * float3(q_8.x)  + _S129 * float3(q_8.y)  + _S130 * float3(q_8.z) ;
        *depth_2 = radius_0 - dist_0;
        return true;
    }
    thread float inside_0;
    thread float3 n_4;
    bool _S131 = penetration_0(b_9, center_4, &inside_0, &n_4);
    if(!_S131)
    {
        return false;
    }
    *normal_3 = n_4;
    *point_0 = center_4 - n_4 * float3(min(radius_0, inside_0)) ;
    *depth_2 = radius_0 + inside_0;
    return true;
}

WorldPoint_0 impactor_point_0(uint _S132, KernelContext_0 thread* kernelContext_6)
{
    Impactor_natural_0 device* _S133 = kernelContext_6->impactors_0+_S132;
    thread WorldPoint_0 wi_0;
    (&wi_0)->hi_0 = (float4(_S133->position_1) ).xyz;
    (&wi_0)->lo_0 = (float4(_S133->position_err_1) ).xyz;
    (&wi_0)->rel_0 = float3(0.0f) ;
    return wi_0;
}

Box_0 impactor_box_1(uint _S134, float3 _S135, float3 _S136, KernelContext_0 thread* kernelContext_7)
{
    Quat_0 q_9 = quat_of_0(float4((kernelContext_7->impactors_0+_S134)->rotation_1) );
    thread Box_0 b_10;
    (&b_10)->center_1 = _S135;
    float3 _S137 = float3(1.0f, 0.0f, 0.0f);
    thread Quat_0 _S138 = q_9;
    float3 _S139 = rotate_0(&_S138, _S137);
    (&b_10)->axis0_0 = _S139;
    float3 _S140 = float3(0.0f, 1.0f, 0.0f);
    thread Quat_0 _S141 = q_9;
    float3 _S142 = rotate_0(&_S141, _S140);
    (&b_10)->axis1_0 = _S142;
    float3 _S143 = float3(0.0f, 0.0f, 1.0f);
    thread Quat_0 _S144 = q_9;
    float3 _S145 = rotate_0(&_S144, _S143);
    (&b_10)->axis2_0 = _S145;
    (&b_10)->half_2 = _S136;
    return b_10;
}

uint impactor_points_0(uint _S146, float _S147, const Box_0 thread* _S148, const Box_0 thread* _S149, array<float3, int(28)> thread* _S150, array<float3, int(28)> thread* _S151, array<float, int(28)> thread* _S152, KernelContext_0 thread* kernelContext_8)
{
    float4 _S153 = float4((kernelContext_8->impactors_0+_S146)->shape_0) ;
    uint count_1;
    if((_S153.x) == 0.0f)
    {
        thread float3 p_2;
        thread float3 n_5;
        thread float d_6;
        bool _S154 = sphere_contact_0(_S149, float3(0.0f) , _S153.y - _S147, &p_2, &n_5, &d_6);
        if(_S154)
        {
            (*_S150)[int(0)] = p_2;
            (*_S151)[int(0)] = - n_5;
            (*_S152)[int(0)] = d_6;
            count_1 = 1U;
        }
        else
        {
            count_1 = 0U;
        }
        return count_1;
    }
    thread Box_0 shrunk_0 = *_S148;
    (&shrunk_0)->half_2 = _S148->half_2 - min(float3(_S147) , _S148->half_2 * float3(0.5f) );
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
        float3 _S155 = sample_point_0(_S149, s_2);
        thread Box_0 _S156 = shrunk_0;
        thread float d_7;
        thread float3 n_6;
        bool _S157 = penetration_0(&_S156, _S155, &d_7, &n_6);
        if(_S157)
        {
            (*_S150)[count_1] = _S155;
            (*_S151)[count_1] = n_6;
            (*_S152)[count_1] = d_7;
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
        thread Box_0 _S158 = shrunk_0;
        float3 _S159 = sample_point_0(&_S158, s_2);
        thread float d_8;
        thread float3 n_7;
        bool _S160 = penetration_0(_S149, _S159, &d_8, &n_7);
        if(_S160)
        {
            (*_S150)[count_1] = _S159;
            (*_S151)[count_1] = - n_7;
            (*_S152)[count_1] = d_8;
            count_1 = count_1 + 1U;
        }
        s_2 = s_2 + 1U;
    }
    return count_1;
}

void impactor_candidate_forces_0(uint k_5, KernelContext_0 thread* kernelContext_9)
{
    uint _S161 = 3U * k_5;
    uint at_1 = kernelContext_9->params_0->cand_index_0 + _S161;
    uint c_4 = kernelContext_9->index_0[at_1];
    uint slot_0 = kernelContext_9->index_0[at_1 + 1U];
    uint _S162 = kernelContext_9->index_0[at_1 + 2U];
    Impactor_natural_0 device* _S163 = kernelContext_9->impactors_0+_S162;
    Impactor_natural_0 imp_1 = *_S163;
    float _S164 = kernelContext_9->params_0->dt_0;
    float3 _S165 = float3(0.0f) ;
    thread float4 data_0 = float4(*(kernelContext_9->scratch_0+(kernelContext_9->params_0->cand_base_0 + _S161))) ;
    float3 f_sum_0;
    float3 t_sum_0;
    float3 imp_f_0;
    float3 imp_t_0;
    if(((uint4((*_S163).cand_0) ).z) == 0U)
    {
        WorldPoint_0 _S166 = chunk_world_0(c_4, kernelContext_9);
        WorldPoint_0 _S167 = impactor_point_0(_S162, kernelContext_9);
        thread WorldPoint_0 _S168 = _S166;
        thread WorldPoint_0 _S169 = _S167;
        float3 _S170 = world_diff_0(&_S168, &_S169);
        float4 _S171 = float4(imp_1.half_1) ;
        if(!((length(_S170)) > (_S171.w + (float4((kernelContext_9->chunks_0+c_4)->half_0) ).w)))
        {
            Box_0 _S172 = impactor_box_1(_S162, _S165, _S171.xyz, kernelContext_9);
            Box_0 _S173 = chunk_box_0(c_4, _S170, kernelContext_9);
            float4 _S174 = float4(imp_1.mat_0) ;
            float _S175 = _S174.x;
            float _S176 = (float4((kernelContext_9->chunks_0+c_4)->cmat_0) ).x;
            float3 _S177 = _S173.center_1 - _S172.center_1;
            thread Box_0 _S178 = _S172;
            thread Box_0 _S179 = _S173;
            float _S180 = contact_stiffness_0(_S175, &_S178, _S176, &_S179, _S177);
            float4 _S181 = float4(imp_1.geom_0) ;
            float _S182 = _S181.y;
            thread Box_0 _S183 = _S172;
            thread Box_0 _S184 = _S173;
            thread array<float3, int(28)> pts_1;
            thread array<float3, int(28)> nrm_1;
            thread array<float, int(28)> dep_1;
            uint _S185 = impactor_points_0(_S162, _S182, &_S183, &_S184, &pts_1, &nrm_1, &dep_1, kernelContext_9);
            bool _S186 = ((float4(imp_1.shape_0) ).x) == 0.0f;
            float _S187;
            if(_S186)
            {
                _S187 = _S180;
            }
            else
            {
                _S187 = _S180 / max(float(_S185), 10.0f);
            }
            uint _S188;
            if(_S186)
            {
                _S188 = 1U;
            }
            else
            {
                _S188 = _S185;
            }
            float m_1 = (float4((kernelContext_9->chunks_0+c_4)->center_0) ).w;
            float _S189 = _S174.z;
            float _S190 = m_1 * _S189 / (m_1 + _S189);
            float _S191;
            if((kernelContext_9->params_0->pair_friction_0) >= 0.0f)
            {
                _S191 = kernelContext_9->params_0->pair_friction_0;
            }
            else
            {
                _S191 = min(_S174.y, (float4((kernelContext_9->chunks_0+c_4)->cmat_0) ).y);
            }
            float3 _S192 = (float4(imp_1.velocity_1) ).xyz + (float4(imp_1.velocity_err_1) ).xyz;
            thread float3 vc_0;
            thread float3 wc_0;
            chunk_velocity_0(c_4, &vc_0, &wc_0, kernelContext_9);
            uint j_1 = 0U;
            f_sum_0 = _S165;
            t_sum_0 = _S165;
            imp_f_0 = _S165;
            imp_t_0 = _S165;
            for(;;)
            {
                if(j_1 < _S185)
                {
                }
                else
                {
                    break;
                }
                float3 _S193 = pts_1[j_1] - _S173.center_1;
                thread float stored_2;
                thread float diss_1;
                float3 _S194 = penalty_force_0(_S187, _S190, _S191, dep_1[j_1] * _S181.x, nrm_1[j_1], vc_0 + cross(wc_0, _S193) - (_S192 + cross((float4(imp_1.angular_velocity_1) ).xyz, pts_1[j_1])), _S164, _S188, &stored_2, &diss_1, kernelContext_9);
                float3 f_sum_1 = f_sum_0 + _S194;
                float3 t_sum_1 = t_sum_0 + cross(_S193, _S194);
                float3 imp_f_1 = imp_f_0 - _S194;
                float3 imp_t_1 = imp_t_0 - cross(pts_1[j_1], _S194);
                thread float _S195 = data_0.z;
                thread float _S196 = data_0.w;
                comp_add1_0(&_S195, &_S196, diss_1);
                data_0.w = _S196;
                data_0.z = _S195;
                j_1 = j_1 + 1U;
                f_sum_0 = f_sum_1;
                t_sum_0 = t_sum_1;
                imp_f_0 = imp_f_1;
                imp_t_0 = imp_t_1;
            }
        }
        else
        {
            f_sum_0 = _S165;
            t_sum_0 = _S165;
            imp_f_0 = _S165;
            imp_t_0 = _S165;
        }
    }
    else
    {
        f_sum_0 = _S165;
        t_sum_0 = _S165;
        imp_f_0 = _S165;
        imp_t_0 = _S165;
    }
    uint _S197 = 2U * slot_0;
    *(kernelContext_9->scratch_0+(kernelContext_9->params_0->slot_base_0 + _S197)) = packed_float4(float4(f_sum_0, 0.0f)) ;
    *(kernelContext_9->scratch_0+(kernelContext_9->params_0->slot_base_0 + _S197 + 1U)) = packed_float4(float4(t_sum_0, 0.0f)) ;
    *(kernelContext_9->scratch_0+(kernelContext_9->params_0->cand_base_0 + _S161)) = packed_float4(data_0) ;
    *(kernelContext_9->scratch_0+(kernelContext_9->params_0->cand_base_0 + _S161 + 1U)) = packed_float4(float4(imp_f_0, 0.0f)) ;
    *(kernelContext_9->scratch_0+(kernelContext_9->params_0->cand_base_0 + _S161 + 2U)) = packed_float4(float4(imp_t_0, 0.0f)) ;
    return;
}

void travel_check_0(uint c_5, KernelContext_0 thread* kernelContext_10)
{
    ChunkStatic_natural_0 device* _S198 = kernelContext_10->chunks_0+c_5;
    if(((uint4(_S198->cinfo_0) ).z) == 0U)
    {
        return;
    }
    WorldPoint_0 _S199 = chunk_world_0(c_5, kernelContext_10);
    float4 _S200 = float4(_S198->start_hi_0) ;
    if((length(_S199.hi_0 - _S200.xyz + (_S199.lo_0 - (float4(_S198->start_lo_0) ).xyz) + _S199.rel_0)) > (_S200.w))
    {
        (kernelContext_10->islands_0+kernelContext_10->params_0->halt_index_0)->info_0[int(2)] = ((uint4((kernelContext_10->islands_0+kernelContext_10->params_0->halt_index_0)->info_0) ).z) | 1U;
    }
    return;
}

[[kernel]] void contact_forces(uint3 id_0 [[thread_position_in_grid]], Params_0 constant* params_1 [[buffer(0)]], Island_natural_0 device* islands_1 [[buffer(9)]], uint device* index_1 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_1 [[buffer(3)]], packed_float4 device* state_1 [[buffer(6)]], packed_float4 device* scratch_1 [[buffer(8)]], packed_float4 device* contact_state_1 [[buffer(11)]], Impactor_natural_0 device* impactors_1 [[buffer(10)]], packed_float4 device* loads_1 [[buffer(5)]], BondStatic_natural_0 device* bonds_1 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_1 [[buffer(7)]], MaterialTable_0 constant* materials_1 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_11;
    (&kernelContext_11)->params_0 = params_1;
    (&kernelContext_11)->islands_0 = islands_1;
    (&kernelContext_11)->index_0 = index_1;
    (&kernelContext_11)->chunks_0 = chunks_1;
    (&kernelContext_11)->state_0 = state_1;
    (&kernelContext_11)->scratch_0 = scratch_1;
    (&kernelContext_11)->contact_state_0 = contact_state_1;
    (&kernelContext_11)->impactors_0 = impactors_1;
    (&kernelContext_11)->loads_0 = loads_1;
    (&kernelContext_11)->bonds_0 = bonds_1;
    (&kernelContext_11)->bond_dyn_0 = bond_dyn_1;
    (&kernelContext_11)->materials_0 = materials_1;
    threadgroup array<float4, int(256)> g_red_a_1;
    (&kernelContext_11)->g_red_a_0 = &g_red_a_1;
    threadgroup array<float4, int(256)> g_red_b_1;
    (&kernelContext_11)->g_red_b_0 = &g_red_b_1;
    threadgroup uint g_run_1;
    (&kernelContext_11)->g_run_0 = &g_run_1;
    threadgroup uint g_halt_1;
    (&kernelContext_11)->g_halt_0 = &g_halt_1;
    uint i_3 = id_0.x;
    bool _S201 = stopped_0(&kernelContext_11);
    if(_S201)
    {
        return;
    }
    if(i_3 < ((&kernelContext_11)->params_0->pair_count_0))
    {
        pair_contact_0(i_3, &kernelContext_11);
    }
    else
    {
        if(i_3 < ((&kernelContext_11)->params_0->pair_count_0 + (&kernelContext_11)->params_0->cand_count_0))
        {
            impactor_candidate_forces_0(i_3 - (&kernelContext_11)->params_0->pair_count_0, &kernelContext_11);
        }
        else
        {
            if(i_3 < ((&kernelContext_11)->params_0->pair_count_0 + (&kernelContext_11)->params_0->cand_count_0 + (&kernelContext_11)->params_0->chunk_count_0))
            {
                travel_check_0(i_3 - (&kernelContext_11)->params_0->pair_count_0 - (&kernelContext_11)->params_0->cand_count_0, &kernelContext_11);
            }
        }
    }
    return;
}

[[kernel]] void impactor_shares(uint3 id_1 [[thread_position_in_grid]], Params_0 constant* params_2 [[buffer(0)]], Island_natural_0 device* islands_2 [[buffer(9)]], uint device* index_2 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_2 [[buffer(3)]], packed_float4 device* state_2 [[buffer(6)]], packed_float4 device* scratch_2 [[buffer(8)]], packed_float4 device* contact_state_2 [[buffer(11)]], Impactor_natural_0 device* impactors_2 [[buffer(10)]], packed_float4 device* loads_2 [[buffer(5)]], BondStatic_natural_0 device* bonds_2 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_2 [[buffer(7)]], MaterialTable_0 constant* materials_2 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_12;
    (&kernelContext_12)->params_0 = params_2;
    (&kernelContext_12)->islands_0 = islands_2;
    (&kernelContext_12)->index_0 = index_2;
    (&kernelContext_12)->chunks_0 = chunks_2;
    (&kernelContext_12)->state_0 = state_2;
    (&kernelContext_12)->scratch_0 = scratch_2;
    (&kernelContext_12)->contact_state_0 = contact_state_2;
    (&kernelContext_12)->impactors_0 = impactors_2;
    (&kernelContext_12)->loads_0 = loads_2;
    (&kernelContext_12)->bonds_0 = bonds_2;
    (&kernelContext_12)->bond_dyn_0 = bond_dyn_2;
    (&kernelContext_12)->materials_0 = materials_2;
    threadgroup array<float4, int(256)> g_red_a_2;
    (&kernelContext_12)->g_red_a_0 = &g_red_a_2;
    threadgroup array<float4, int(256)> g_red_b_2;
    (&kernelContext_12)->g_red_b_0 = &g_red_b_2;
    threadgroup uint g_run_2;
    (&kernelContext_12)->g_run_0 = &g_run_2;
    threadgroup uint g_halt_2;
    (&kernelContext_12)->g_halt_0 = &g_halt_2;
    uint k_6 = id_1.x;
    bool _S202;
    if(k_6 >= (params_2->cand_count_0))
    {
        _S202 = true;
    }
    else
    {
        bool _S203 = stopped_0(&kernelContext_12);
        _S202 = _S203;
    }
    if(_S202)
    {
        return;
    }
    uint _S204 = 3U * k_6;
    uint at_2 = (&kernelContext_12)->params_0->cand_index_0 + _S204;
    uint c_6 = (&kernelContext_12)->index_0[at_2];
    uint _S205 = (&kernelContext_12)->index_0[at_2 + 2U];
    Impactor_natural_0 device* _S206 = (&kernelContext_12)->impactors_0+_S205;
    Impactor_natural_0 imp_2 = *_S206;
    if(((uint4((*_S206).cand_0) ).z) == 0U)
    {
        _S202 = ((float4(imp_2.crush_0) ).x) > 0.0f;
    }
    else
    {
        _S202 = false;
    }
    float total_0;
    float ksum_0;
    if(_S202)
    {
        WorldPoint_0 _S207 = chunk_world_0(c_6, &kernelContext_12);
        WorldPoint_0 _S208 = impactor_point_0(_S205, &kernelContext_12);
        thread WorldPoint_0 _S209 = _S207;
        thread WorldPoint_0 _S210 = _S208;
        float3 _S211 = world_diff_0(&_S209, &_S210);
        float4 _S212 = float4(imp_2.half_1) ;
        if(!((length(_S211)) > (_S212.w + (float4(((&kernelContext_12)->chunks_0+c_6)->half_0) ).w)))
        {
            Box_0 _S213 = impactor_box_1(_S205, float3(0.0f) , _S212.xyz, &kernelContext_12);
            Box_0 _S214 = chunk_box_0(c_6, _S211, &kernelContext_12);
            float _S215 = (float4(imp_2.mat_0) ).x;
            float _S216 = (float4(((&kernelContext_12)->chunks_0+c_6)->cmat_0) ).x;
            float3 _S217 = _S214.center_1 - _S213.center_1;
            thread Box_0 _S218 = _S213;
            thread Box_0 _S219 = _S214;
            float _S220 = contact_stiffness_0(_S215, &_S218, _S216, &_S219, _S217);
            float _S221 = (float4(imp_2.crush_0) ).w;
            thread Box_0 _S222 = _S213;
            thread Box_0 _S223 = _S214;
            thread array<float3, int(28)> pts_2;
            thread array<float3, int(28)> nrm_2;
            thread array<float, int(28)> dep_2;
            uint _S224 = impactor_points_0(_S205, _S221, &_S222, &_S223, &pts_2, &nrm_2, &dep_2, &kernelContext_12);
            float _S225;
            if(((float4(imp_2.shape_0) ).x) == 0.0f)
            {
                _S225 = _S220;
            }
            else
            {
                _S225 = _S220 / max(float(_S224), 10.0f);
            }
            uint j_2 = 0U;
            total_0 = 0.0f;
            ksum_0 = 0.0f;
            for(;;)
            {
                if(j_2 < _S224)
                {
                }
                else
                {
                    break;
                }
                float total_1 = total_0 + _S225 * dep_2[j_2];
                float ksum_1 = ksum_0 + _S225;
                j_2 = j_2 + 1U;
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
    float4 _S226 = float4(*((&kernelContext_12)->scratch_0+((&kernelContext_12)->params_0->cand_base_0 + _S204))) ;
    *((&kernelContext_12)->scratch_0+((&kernelContext_12)->params_0->cand_base_0 + _S204)) = packed_float4(float4(total_0, ksum_0, _S226.z, _S226.w)) ;
    return;
}

void group_sum2_0(uint tid_0, float4 thread* a_4, float4 thread* b_11, KernelContext_0 thread* kernelContext_13)
{
    (*kernelContext_13->g_red_a_0)[tid_0] = *a_4;
    (*kernelContext_13->g_red_b_0)[tid_0] = *b_11;
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
            uint _S227 = tid_0 + s_3;
            (*kernelContext_13->g_red_a_0)[tid_0] = (*kernelContext_13->g_red_a_0)[tid_0] + (*kernelContext_13->g_red_a_0)[_S227];
            (*kernelContext_13->g_red_b_0)[tid_0] = (*kernelContext_13->g_red_b_0)[tid_0] + (*kernelContext_13->g_red_b_0)[_S227];
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);
        s_3 = s_3 >> 1U;
    }
    *a_4 = (*kernelContext_13->g_red_a_0)[int(0)];
    *b_11 = (*kernelContext_13->g_red_b_0)[int(0)];
    threadgroup_barrier(mem_flags::mem_threadgroup);
    return;
}

[[kernel]] void impactor_crush(uint3 group_0 [[threadgroup_position_in_grid]], uint3 thread_0 [[thread_position_in_threadgroup]], Params_0 constant* params_3 [[buffer(0)]], Island_natural_0 device* islands_3 [[buffer(9)]], uint device* index_3 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_3 [[buffer(3)]], packed_float4 device* state_3 [[buffer(6)]], packed_float4 device* scratch_3 [[buffer(8)]], packed_float4 device* contact_state_3 [[buffer(11)]], Impactor_natural_0 device* impactors_3 [[buffer(10)]], packed_float4 device* loads_3 [[buffer(5)]], BondStatic_natural_0 device* bonds_3 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_3 [[buffer(7)]], MaterialTable_0 constant* materials_3 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_14;
    (&kernelContext_14)->params_0 = params_3;
    (&kernelContext_14)->islands_0 = islands_3;
    (&kernelContext_14)->index_0 = index_3;
    (&kernelContext_14)->chunks_0 = chunks_3;
    (&kernelContext_14)->state_0 = state_3;
    (&kernelContext_14)->scratch_0 = scratch_3;
    (&kernelContext_14)->contact_state_0 = contact_state_3;
    (&kernelContext_14)->impactors_0 = impactors_3;
    (&kernelContext_14)->loads_0 = loads_3;
    (&kernelContext_14)->bonds_0 = bonds_3;
    (&kernelContext_14)->bond_dyn_0 = bond_dyn_3;
    (&kernelContext_14)->materials_0 = materials_3;
    threadgroup array<float4, int(256)> g_red_a_3;
    (&kernelContext_14)->g_red_a_0 = &g_red_a_3;
    threadgroup array<float4, int(256)> g_red_b_3;
    (&kernelContext_14)->g_red_b_0 = &g_red_b_3;
    threadgroup uint g_run_3;
    (&kernelContext_14)->g_run_0 = &g_run_3;
    threadgroup uint g_halt_3;
    (&kernelContext_14)->g_halt_0 = &g_halt_3;
    uint ii_0 = group_0.x;
    uint tid_1 = thread_0.x;
    bool _S228;
    if(ii_0 >= (params_3->impactor_count_0))
    {
        _S228 = true;
    }
    else
    {
        bool _S229 = stopped_0(&kernelContext_14);
        _S228 = _S229;
    }
    if(_S228)
    {
        return;
    }
    Impactor_natural_0 device* _S230 = (&kernelContext_14)->impactors_0+ii_0;
    float4 _S231 = float4((*_S230).position_err_1) ;
    float4 _S232 = float4((*_S230).velocity_1) ;
    float4 _S233 = float4((*_S230).velocity_err_1) ;
    float4 _S234 = float4((*_S230).angular_velocity_1) ;
    float4 _S235 = float4((*_S230).rotation_1) ;
    float4 _S236 = float4((*_S230).inertia0_2) ;
    float4 _S237 = float4((*_S230).inertia1_2) ;
    float4 _S238 = float4((*_S230).inertia2_2) ;
    float4 _S239 = float4((*_S230).inv0_2) ;
    float4 _S240 = float4((*_S230).inv1_2) ;
    float4 _S241 = float4((*_S230).inv2_2) ;
    float4 _S242 = float4((*_S230).shape_0) ;
    float4 _S243 = float4((*_S230).half_1) ;
    float4 _S244 = float4((*_S230).mat_0) ;
    float4 _S245 = float4((*_S230).crush_0) ;
    float4 _S246 = float4((*_S230).geom_0) ;
    float4 _S247 = float4((*_S230).unused_0) ;
    float4 _S248 = float4((*_S230).ledger_0) ;
    uint4 _S249 = uint4((*_S230).cand_0) ;
    thread Impactor_0 imp_3;
    (&imp_3)->position_1 = float4((*_S230).position_1) ;
    (&imp_3)->position_err_1 = _S231;
    (&imp_3)->velocity_1 = _S232;
    (&imp_3)->velocity_err_1 = _S233;
    (&imp_3)->angular_velocity_1 = _S234;
    (&imp_3)->rotation_1 = _S235;
    (&imp_3)->inertia0_2 = _S236;
    (&imp_3)->inertia1_2 = _S237;
    (&imp_3)->inertia2_2 = _S238;
    (&imp_3)->inv0_2 = _S239;
    (&imp_3)->inv1_2 = _S240;
    (&imp_3)->inv2_2 = _S241;
    (&imp_3)->shape_0 = _S242;
    (&imp_3)->half_1 = _S243;
    (&imp_3)->mat_0 = _S244;
    (&imp_3)->crush_0 = _S245;
    (&imp_3)->geom_0 = _S246;
    (&imp_3)->unused_0 = _S247;
    (&imp_3)->ledger_0 = _S248;
    (&imp_3)->cand_0 = _S249;
    float4 _S250 = float4(0.0f) ;
    thread float4 shares_0 = _S250;
    thread float4 unused_1 = _S250;
    uint k_7 = (&imp_3)->cand_0.x + tid_1;
    for(;;)
    {
        if(k_7 < ((&imp_3)->cand_0.y))
        {
        }
        else
        {
            break;
        }
        shares_0 = shares_0 + float4(*((&kernelContext_14)->scratch_0+((&kernelContext_14)->params_0->cand_base_0 + 3U * k_7))) ;
        k_7 = k_7 + 256U;
    }
    group_sum2_0(tid_1, &shares_0, &unused_1, &kernelContext_14);
    if(tid_1 != 0U)
    {
        _S228 = true;
    }
    else
    {
        _S228 = ((&imp_3)->cand_0.z) != 0U;
    }
    if(_S228)
    {
        return;
    }
    (&imp_3)->geom_0 = float4(1.0f, (&imp_3)->crush_0.w, 0.0f, 0.0f);
    float total_2 = shares_0.x;
    if(((&imp_3)->crush_0.x) > 0.0f)
    {
        _S228 = ((&imp_3)->crush_0.z) < ((&imp_3)->crush_0.y);
    }
    else
    {
        _S228 = false;
    }
    if(_S228)
    {
        _S228 = total_2 > ((&imp_3)->crush_0.x);
    }
    else
    {
        _S228 = false;
    }
    if(_S228)
    {
        float extra_0 = (total_2 - (&imp_3)->crush_0.x) / shares_0.y;
        (&imp_3)->crush_0.w = (&imp_3)->crush_0.w + extra_0;
        (&imp_3)->crush_0.z = (&imp_3)->crush_0.z + (&imp_3)->crush_0.x * extra_0;
        float _S251 = (&imp_3)->crush_0.x * extra_0;
        thread float _S252 = (&imp_3)->ledger_0.z;
        thread float _S253 = (&imp_3)->ledger_0.w;
        comp_add1_0(&_S252, &_S253, _S251);
        (&imp_3)->ledger_0.w = _S253;
        (&imp_3)->ledger_0.z = _S252;
        float _S254 = (&imp_3)->crush_0.x * extra_0;
        thread float _S255 = (&imp_3)->ledger_0.x;
        thread float _S256 = (&imp_3)->ledger_0.y;
        comp_add1_0(&_S255, &_S256, _S254);
        (&imp_3)->ledger_0.y = _S256;
        (&imp_3)->ledger_0.x = _S255;
        (&imp_3)->geom_0.x = (&imp_3)->crush_0.x / total_2;
    }
    Impactor_natural_0 device* _S257 = (&kernelContext_14)->impactors_0+ii_0;
    _S257->position_1 = packed_float4(imp_3.position_1) ;
    _S257->position_err_1 = packed_float4(imp_3.position_err_1) ;
    _S257->velocity_1 = packed_float4(imp_3.velocity_1) ;
    _S257->velocity_err_1 = packed_float4(imp_3.velocity_err_1) ;
    _S257->angular_velocity_1 = packed_float4(imp_3.angular_velocity_1) ;
    _S257->rotation_1 = packed_float4(imp_3.rotation_1) ;
    _S257->inertia0_2 = packed_float4(imp_3.inertia0_2) ;
    _S257->inertia1_2 = packed_float4(imp_3.inertia1_2) ;
    _S257->inertia2_2 = packed_float4(imp_3.inertia2_2) ;
    _S257->inv0_2 = packed_float4(imp_3.inv0_2) ;
    _S257->inv1_2 = packed_float4(imp_3.inv1_2) ;
    _S257->inv2_2 = packed_float4(imp_3.inv2_2) ;
    _S257->shape_0 = packed_float4(imp_3.shape_0) ;
    _S257->half_1 = packed_float4(imp_3.half_1) ;
    _S257->mat_0 = packed_float4(imp_3.mat_0) ;
    _S257->crush_0 = packed_float4(imp_3.crush_0) ;
    _S257->geom_0 = packed_float4(imp_3.geom_0) ;
    _S257->unused_0 = packed_float4(imp_3.unused_0) ;
    _S257->ledger_0 = packed_float4(imp_3.ledger_0) ;
    _S257->cand_0 = packed_uint4(imp_3.cand_0) ;
    return;
}

void comp_add_0(float3 thread* sum_1, float3 thread* err_1, float3 x_2)
{
    float3 t_3 = *sum_1 + x_2;
    float3 _S258 = abs(x_2);
    *err_1 = *err_1 + (select(x_2, *sum_1, (abs(*sum_1)) >= _S258) - t_3 + select(*sum_1, x_2, (abs(*sum_1)) >= _S258));
    *sum_1 = t_3;
    return;
}

float3 inverse_rotate_0(const Quat_0 thread* q_10, float3 v_5)
{
    thread Quat_0 c_7;
    (&c_7)->w_0 = q_10->w_0;
    (&c_7)->x_0 = - q_10->x_0;
    (&c_7)->y_0 = - q_10->y_0;
    (&c_7)->z_0 = - q_10->z_0;
    thread Quat_0 _S259 = c_7;
    float3 _S260 = rotate_0(&_S259, v_5);
    return _S260;
}

float3 inverse_rotate_1(const Quat_0 thread* q_11, float3 v_6)
{
    thread Quat_0 c_8;
    (&c_8)->w_0 = q_11->w_0;
    (&c_8)->x_0 = - q_11->x_0;
    (&c_8)->y_0 = - q_11->y_0;
    (&c_8)->z_0 = - q_11->z_0;
    thread Quat_0 _S261 = c_8;
    float3 _S262 = rotate_0(&_S261, v_6);
    return _S262;
}

float3 rows_mul_0(float4 r0_0, float4 r1_0, float4 r2_0, float3 v_7)
{
    return float3(dot(r0_0.xyz, v_7), dot(r1_0.xyz, v_7), dot(r2_0.xyz, v_7));
}

float3 world_mul_0(const Quat_0 thread* q_12, float4 r0_1, float4 r1_1, float4 r2_1, float3 v_8)
{
    float3 _S263 = inverse_rotate_1(q_12, v_8);
    float3 _S264 = rotate_1(q_12, rows_mul_0(r0_1, r1_1, r2_1, _S263));
    return _S264;
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

Quat_0 normalized_0(const Quat_0 thread* q_13)
{
    float n_8 = sqrt(q_13->w_0 * q_13->w_0 + q_13->x_0 * q_13->x_0 + q_13->y_0 * q_13->y_0 + q_13->z_0 * q_13->z_0);
    thread Quat_0 r_4;
    (&r_4)->w_0 = q_13->w_0 / n_8;
    (&r_4)->x_0 = q_13->x_0 / n_8;
    (&r_4)->y_0 = q_13->y_0 / n_8;
    (&r_4)->z_0 = q_13->z_0 / n_8;
    return r_4;
}

Quat_0 integrate_rotation_0(const Quat_0 thread* q_14, float3 omega_0, float dt_2)
{
    float angle_1 = length(omega_0) * dt_2;
    if(angle_1 < 1.00000000317107685e-30f)
    {
        return *q_14;
    }
    thread Quat_0 _S265 = from_axis_angle_0(omega_0, angle_1);
    Quat_0 _S266 = quat_mul_0(&_S265, q_14);
    thread Quat_0 _S267 = _S266;
    Quat_0 _S268 = normalized_0(&_S267);
    return _S268;
}

float4 quat_vec_0(const Quat_0 thread* q_15)
{
    return float4(q_15->x_0, q_15->y_0, q_15->z_0, q_15->w_0);
}

[[kernel]] void impactor_integrate(uint3 group_1 [[threadgroup_position_in_grid]], uint3 thread_1 [[thread_position_in_threadgroup]], Params_0 constant* params_4 [[buffer(0)]], Island_natural_0 device* islands_4 [[buffer(9)]], uint device* index_4 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_4 [[buffer(3)]], packed_float4 device* state_4 [[buffer(6)]], packed_float4 device* scratch_4 [[buffer(8)]], packed_float4 device* contact_state_4 [[buffer(11)]], Impactor_natural_0 device* impactors_4 [[buffer(10)]], packed_float4 device* loads_4 [[buffer(5)]], BondStatic_natural_0 device* bonds_4 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_4 [[buffer(7)]], MaterialTable_0 constant* materials_4 [[buffer(1)]])
{
    float3 p_3;
    thread KernelContext_0 kernelContext_15;
    (&kernelContext_15)->params_0 = params_4;
    (&kernelContext_15)->islands_0 = islands_4;
    (&kernelContext_15)->index_0 = index_4;
    (&kernelContext_15)->chunks_0 = chunks_4;
    (&kernelContext_15)->state_0 = state_4;
    (&kernelContext_15)->scratch_0 = scratch_4;
    (&kernelContext_15)->contact_state_0 = contact_state_4;
    (&kernelContext_15)->impactors_0 = impactors_4;
    (&kernelContext_15)->loads_0 = loads_4;
    (&kernelContext_15)->bonds_0 = bonds_4;
    (&kernelContext_15)->bond_dyn_0 = bond_dyn_4;
    (&kernelContext_15)->materials_0 = materials_4;
    threadgroup array<float4, int(256)> g_red_a_4;
    (&kernelContext_15)->g_red_a_0 = &g_red_a_4;
    threadgroup array<float4, int(256)> g_red_b_4;
    (&kernelContext_15)->g_red_b_0 = &g_red_b_4;
    threadgroup uint g_run_4;
    (&kernelContext_15)->g_run_0 = &g_run_4;
    threadgroup uint g_halt_4;
    (&kernelContext_15)->g_halt_0 = &g_halt_4;
    uint ii_1 = group_1.x;
    uint tid_2 = thread_1.x;
    if(ii_1 >= (params_4->impactor_count_0))
    {
        return;
    }
    Island_natural_0 device* _S269 = (&kernelContext_15)->islands_0+(&kernelContext_15)->params_0->halt_index_0;
    Impactor_natural_0 device* _S270 = (&kernelContext_15)->impactors_0+ii_1;
    float4 _S271 = float4((*_S270).position_err_1) ;
    float4 _S272 = float4((*_S270).velocity_1) ;
    float4 _S273 = float4((*_S270).velocity_err_1) ;
    float4 _S274 = float4((*_S270).angular_velocity_1) ;
    float4 _S275 = float4((*_S270).rotation_1) ;
    float4 _S276 = float4((*_S270).inertia0_2) ;
    float4 _S277 = float4((*_S270).inertia1_2) ;
    float4 _S278 = float4((*_S270).inertia2_2) ;
    float4 _S279 = float4((*_S270).inv0_2) ;
    float4 _S280 = float4((*_S270).inv1_2) ;
    float4 _S281 = float4((*_S270).inv2_2) ;
    float4 _S282 = float4((*_S270).shape_0) ;
    float4 _S283 = float4((*_S270).half_1) ;
    float4 _S284 = float4((*_S270).mat_0) ;
    float4 _S285 = float4((*_S270).crush_0) ;
    float4 _S286 = float4((*_S270).geom_0) ;
    float4 _S287 = float4((*_S270).unused_0) ;
    float4 _S288 = float4((*_S270).ledger_0) ;
    uint4 _S289 = uint4((*_S270).cand_0) ;
    thread Impactor_0 imp_4;
    (&imp_4)->position_1 = float4((*_S270).position_1) ;
    (&imp_4)->position_err_1 = _S271;
    (&imp_4)->velocity_1 = _S272;
    (&imp_4)->velocity_err_1 = _S273;
    (&imp_4)->angular_velocity_1 = _S274;
    (&imp_4)->rotation_1 = _S275;
    (&imp_4)->inertia0_2 = _S276;
    (&imp_4)->inertia1_2 = _S277;
    (&imp_4)->inertia2_2 = _S278;
    (&imp_4)->inv0_2 = _S279;
    (&imp_4)->inv1_2 = _S280;
    (&imp_4)->inv2_2 = _S281;
    (&imp_4)->shape_0 = _S282;
    (&imp_4)->half_1 = _S283;
    (&imp_4)->mat_0 = _S284;
    (&imp_4)->crush_0 = _S285;
    (&imp_4)->geom_0 = _S286;
    (&imp_4)->unused_0 = _S287;
    (&imp_4)->ledger_0 = _S288;
    (&imp_4)->cand_0 = _S289;
    bool _S290;
    if(((&imp_4)->cand_0.z) != 0U)
    {
        _S290 = true;
    }
    else
    {
        _S290 = (((uint4(_S269->info_0) ).z) & 1U) != 0U;
    }
    if(_S290)
    {
        _S290 = true;
    }
    else
    {
        uint _S291 = (uint4(_S269->info_0) ).y;
        if(_S291 != 0U)
        {
            _S290 = ((&imp_4)->cand_0.w) >= _S291;
        }
        else
        {
            _S290 = false;
        }
    }
    if(_S290)
    {
        return;
    }
    float4 _S292 = float4(0.0f) ;
    thread float4 rf_0 = _S292;
    thread float4 rt_0 = _S292;
    uint k_8 = (&imp_4)->cand_0.x + tid_2;
    for(;;)
    {
        if(k_8 < ((&imp_4)->cand_0.y))
        {
        }
        else
        {
            break;
        }
        uint _S293 = 3U * k_8;
        rf_0 = rf_0 + float4(*((&kernelContext_15)->scratch_0+((&kernelContext_15)->params_0->cand_base_0 + _S293 + 1U))) ;
        rt_0 = rt_0 + float4(*((&kernelContext_15)->scratch_0+((&kernelContext_15)->params_0->cand_base_0 + _S293 + 2U))) ;
        k_8 = k_8 + 256U;
    }
    group_sum2_0(tid_2, &rf_0, &rt_0, &kernelContext_15);
    if(tid_2 != 0U)
    {
        return;
    }
    float dt_3 = (&kernelContext_15)->params_0->dt_0;
    float3 _S294 = float3(0.0f) ;
    float3 load_f_0;
    float3 load_t_0;
    if(((&kernelContext_15)->params_0->has_ground_0) != 0U)
    {
        float3 _S295 = (&imp_4)->half_1.xyz;
        thread Impactor_0 _S296 = imp_4;
        Box_0 _S297 = impactor_box_0(&_S296, _S294, _S295);
        float3 _S298 = (&imp_4)->velocity_1.xyz + (&imp_4)->velocity_err_1.xyz;
        float _S299 = (&kernelContext_15)->params_0->ground_modulus_0;
        float _S300 = (&imp_4)->mat_0.x;
        float3 _S301 = float3(0.0f, 0.0f, 1.0f);
        thread Box_0 _S302 = _S297;
        thread Box_0 _S303 = _S297;
        float _S304 = contact_stiffness_0(_S299, &_S302, _S300, &_S303, _S301);
        float _S305 = (&imp_4)->position_1.z - (&kernelContext_15)->params_0->ground_hi_0 + ((&imp_4)->position_err_1.z - (&kernelContext_15)->params_0->ground_lo_0);
        uint total_points_0;
        if(((&imp_4)->shape_0.x) == 0.0f)
        {
            total_points_0 = 1U;
        }
        else
        {
            total_points_0 = 14U;
        }
        float _S306 = _S304 / float(min(total_points_0, 5U));
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
            if(((&imp_4)->shape_0.x) == 0.0f)
            {
                p_3 = float3(0.0f, 0.0f, - (&imp_4)->shape_0.y);
            }
            else
            {
                thread Box_0 _S307 = _S297;
                float3 _S308 = sample_point_0(&_S307, s_4);
                p_3 = _S308;
            }
            if((_S305 + p_3.z) < 0.0f)
            {
                below_0 = below_0 + 1U;
            }
            s_4 = s_4 + 1U;
        }
        s_4 = 0U;
        load_f_0 = _S294;
        load_t_0 = _S294;
        for(;;)
        {
            if(s_4 < total_points_0)
            {
            }
            else
            {
                break;
            }
            if(((&imp_4)->shape_0.x) == 0.0f)
            {
                p_3 = float3(0.0f, 0.0f, - (&imp_4)->shape_0.y);
            }
            else
            {
                thread Box_0 _S309 = _S297;
                float3 _S310 = sample_point_0(&_S309, s_4);
                p_3 = _S310;
            }
            float depth_3 = - (_S305 + p_3.z);
            if(depth_3 <= 0.0f)
            {
                s_4 = s_4 + 1U;
                continue;
            }
            thread float stored_3;
            thread float diss_2;
            float3 _S311 = penalty_force_0(_S306, (&imp_4)->mat_0.z, (&kernelContext_15)->params_0->ground_friction_0, depth_3, _S301, _S298 + cross((&imp_4)->angular_velocity_1.xyz, p_3), dt_3, below_0, &stored_3, &diss_2, &kernelContext_15);
            float3 load_f_1 = load_f_0 + _S311;
            float3 load_t_1 = load_t_0 + cross(p_3, _S311);
            thread float _S312 = (&imp_4)->ledger_0.x;
            thread float _S313 = (&imp_4)->ledger_0.y;
            comp_add1_0(&_S312, &_S313, diss_2);
            (&imp_4)->ledger_0.y = _S313;
            (&imp_4)->ledger_0.x = _S312;
            load_f_0 = load_f_1;
            load_t_0 = load_t_1;
            s_4 = s_4 + 1U;
        }
    }
    else
    {
        load_f_0 = _S294;
        load_t_0 = _S294;
    }
    float3 load_f_2 = rf_0.xyz + load_f_0;
    float3 load_t_2 = rt_0.xyz + load_t_0;
    float m_2 = (&imp_4)->mat_0.z;
    thread float3 vel_0 = (&imp_4)->velocity_1.xyz;
    thread float3 vel_err_0 = (&imp_4)->velocity_err_1.xyz;
    float3 _S314 = float3(dt_3) ;
    comp_add_0(&vel_0, &vel_err_0, (load_f_2 / float3(m_2)  + (&kernelContext_15)->params_0->gravity_0.xyz) * _S314);
    Quat_0 q_16 = quat_of_0((&imp_4)->rotation_1);
    float3 _S315 = (&imp_4)->angular_velocity_1.xyz;
    thread Quat_0 _S316 = q_16;
    float3 _S317 = world_mul_0(&_S316, (&imp_4)->inertia0_2, (&imp_4)->inertia1_2, (&imp_4)->inertia2_2, _S315);
    float3 l_1 = _S317 + load_t_2 * _S314;
    thread Quat_0 _S318 = q_16;
    float3 _S319 = world_mul_0(&_S318, (&imp_4)->inv0_2, (&imp_4)->inv1_2, (&imp_4)->inv2_2, l_1);
    thread float3 pos_0 = (&imp_4)->position_1.xyz;
    thread float3 pos_err_0 = (&imp_4)->position_err_1.xyz;
    comp_add_0(&pos_0, &pos_err_0, (vel_0 + vel_err_0) * _S314);
    thread Quat_0 _S320 = q_16;
    Quat_0 _S321 = integrate_rotation_0(&_S320, _S319, dt_3);
    thread Quat_0 _S322 = _S321;
    float3 _S323 = world_mul_0(&_S322, (&imp_4)->inv0_2, (&imp_4)->inv1_2, (&imp_4)->inv2_2, l_1);
    (&imp_4)->angular_velocity_1 = float4(_S323, 0.0f);
    thread Quat_0 _S324 = _S321;
    float4 _S325 = quat_vec_0(&_S324);
    (&imp_4)->rotation_1 = _S325;
    (&imp_4)->position_1 = float4(pos_0, 0.0f);
    (&imp_4)->position_err_1 = float4(pos_err_0, 0.0f);
    (&imp_4)->velocity_1 = float4(vel_0, 0.0f);
    (&imp_4)->velocity_err_1 = float4(vel_err_0, 0.0f);
    (&imp_4)->cand_0.w = (&imp_4)->cand_0.w + 1U;
    (&imp_4)->geom_0 = float4(1.0f, (&imp_4)->crush_0.w, 0.0f, 0.0f);
    Impactor_natural_0 device* _S326 = (&kernelContext_15)->impactors_0+ii_1;
    _S326->position_1 = packed_float4(imp_4.position_1) ;
    _S326->position_err_1 = packed_float4(imp_4.position_err_1) ;
    _S326->velocity_1 = packed_float4(imp_4.velocity_1) ;
    _S326->velocity_err_1 = packed_float4(imp_4.velocity_err_1) ;
    _S326->angular_velocity_1 = packed_float4(imp_4.angular_velocity_1) ;
    _S326->rotation_1 = packed_float4(imp_4.rotation_1) ;
    _S326->inertia0_2 = packed_float4(imp_4.inertia0_2) ;
    _S326->inertia1_2 = packed_float4(imp_4.inertia1_2) ;
    _S326->inertia2_2 = packed_float4(imp_4.inertia2_2) ;
    _S326->inv0_2 = packed_float4(imp_4.inv0_2) ;
    _S326->inv1_2 = packed_float4(imp_4.inv1_2) ;
    _S326->inv2_2 = packed_float4(imp_4.inv2_2) ;
    _S326->shape_0 = packed_float4(imp_4.shape_0) ;
    _S326->half_1 = packed_float4(imp_4.half_1) ;
    _S326->mat_0 = packed_float4(imp_4.mat_0) ;
    _S326->crush_0 = packed_float4(imp_4.crush_0) ;
    _S326->geom_0 = packed_float4(imp_4.geom_0) ;
    _S326->unused_0 = packed_float4(imp_4.unused_0) ;
    _S326->ledger_0 = packed_float4(imp_4.ledger_0) ;
    _S326->cand_0 = packed_uint4(imp_4.cand_0) ;
    uint k_9 = (&imp_4)->cand_0.w - 1U - (&kernelContext_15)->params_0->step_start_0;
    if(k_9 < ((&kernelContext_15)->params_0->record_stride_0))
    {
        uint at_3 = (&kernelContext_15)->params_0->record_base_0 + 2U * (ii_1 * (&kernelContext_15)->params_0->record_stride_0 + k_9);
        *((&kernelContext_15)->scratch_0+at_3) = packed_float4(float4(vel_0 + vel_err_0, 0.0f)) ;
        *((&kernelContext_15)->scratch_0+(at_3 + 1U)) = packed_float4(float4(pos_0 + pos_err_0, 0.0f)) ;
    }
    return;
}

float time_since_0(float4 origin_0, uint k_10, float dt_4, KernelContext_0 thread* kernelContext_16)
{
    return kernelContext_16->params_0->t_hi_0 - origin_0.x + (kernelContext_16->params_0->t_lo_0 - origin_0.y) + float(k_10) * dt_4;
}

float table_eval_0(uint offset_0, uint count_2, float tau_0, KernelContext_0 thread* kernelContext_17)
{
    float4 _S327 = float4(*(kernelContext_17->loads_0+offset_0)) ;
    if(tau_0 <= (_S327.x))
    {
        return _S327.y;
    }
    uint i_4 = 1U;
    for(;;)
    {
        if(i_4 < count_2)
        {
        }
        else
        {
            break;
        }
        uint _S328 = offset_0 + i_4;
        float4 _S329 = float4(*(kernelContext_17->loads_0+_S328)) ;
        float _S330 = _S329.x;
        if(tau_0 <= _S330)
        {
            float4 _S331 = float4(*(kernelContext_17->loads_0+(_S328 - 1U))) ;
            float _S332 = _S331.x;
            float _S333 = _S331.y;
            return _S333 + (tau_0 - _S332) / max(_S330 - _S332, 1.00000000317107685e-30f) * (_S329.y - _S333);
        }
        i_4 = i_4 + 1U;
    }
    return (float4(*(kernelContext_17->loads_0+(offset_0 + count_2 - 1U))) ).y;
}

float eval_function_0(uint term_0, uint k_11, float dt_5, float shift_0, KernelContext_0 thread* kernelContext_18)
{
    uint _S334 = 5U * term_0;
    uint4 info_2 = (as_type<uint4>((float4(*(kernelContext_18->loads_0+_S334)) )));
    float4 _S335 = float4(*(kernelContext_18->loads_0+(_S334 + 3U))) ;
    float4 _S336 = float4(*(kernelContext_18->loads_0+(_S334 + 4U))) ;
    uint kind_0 = info_2.z;
    if(kind_0 == 0U)
    {
        return _S335.z;
    }
    float _S337 = time_since_0(_S335, k_11, dt_5, kernelContext_18);
    float tau_1 = _S337 + shift_0;
    float shape_1;
    if(kind_0 == 1U)
    {
        if(tau_1 <= 0.0f)
        {
            shape_1 = 0.0f;
        }
        else
        {
            float _S338 = _S336.x;
            if(tau_1 >= _S338)
            {
                shape_1 = _S336.y;
            }
            else
            {
                shape_1 = _S336.y * tau_1 / _S338;
            }
        }
        return shape_1;
    }
    bool _S339;
    if(kind_0 == 2U)
    {
        if(tau_1 < 0.0f)
        {
            _S339 = true;
        }
        else
        {
            _S339 = tau_1 > (_S336.x);
        }
        if(_S339)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S336.y * sin(3.14159274101257324f * tau_1 / _S336.x);
        }
        return shape_1;
    }
    if(kind_0 == 3U)
    {
        float sn_0 = tau_1 / _S336.y;
        if(sn_0 < 0.0f)
        {
            _S339 = true;
        }
        else
        {
            _S339 = sn_0 > 1.0f;
        }
        if(_S339)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S336.x * (1.0f - sn_0) * exp(- _S336.z * sn_0);
        }
        return shape_1;
    }
    if(kind_0 == 4U)
    {
        float _S340 = table_eval_0(info_2.w, (as_type<uint>((_S336.x))), tau_1, kernelContext_18);
        return _S340;
    }
    if(kind_0 == 5U)
    {
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float sn_1 = tau_1 / _S336.x;
        if(sn_1 < 0.0f)
        {
            _S339 = true;
        }
        else
        {
            _S339 = sn_1 > 1.0f;
        }
        if(_S339)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = (1.0f - sn_1) * exp(- _S336.y * sn_1);
        }
        float clearing_0 = _S335.w;
        float relax_0;
        if(clearing_0 > 0.0f)
        {
            relax_0 = max(1.0f - tau_1 / clearing_0, 0.0f);
        }
        else
        {
            relax_0 = 0.0f;
        }
        float _S341 = _S336.w;
        return (_S341 + (_S336.z - _S341) * relax_0) * shape_1;
    }
    float _S342 = _S336.x;
    if(_S342 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp(1.0f - tau_1 / _S342, 0.0f, 1.0f);
}

void ground_contact_0(uint c_9, bool account_0, float3 thread* f_0, float3 thread* t_4, KernelContext_0 thread* kernelContext_19)
{
    ChunkStatic_natural_0 device* _S343 = kernelContext_19->chunks_0+c_9;
    WorldPoint_0 _S344 = chunk_world_0(c_9, kernelContext_19);
    float above_0 = _S344.hi_0.z - kernelContext_19->params_0->ground_hi_0 + (_S344.lo_0.z - kernelContext_19->params_0->ground_lo_0) + _S344.rel_0.z;
    if((above_0 - (float4(_S343->half_0) ).w) > 0.0f)
    {
        return;
    }
    Box_0 _S345 = chunk_box_0(c_9, float3(0.0f) , kernelContext_19);
    float _S346 = kernelContext_19->params_0->ground_modulus_0;
    float _S347 = (float4(_S343->cmat_0) ).x;
    float3 _S348 = float3(0.0f, 0.0f, 1.0f);
    thread Box_0 _S349 = _S345;
    thread Box_0 _S350 = _S345;
    float _S351 = contact_stiffness_0(_S346, &_S349, _S347, &_S350, _S348);
    uint s_5 = 0U;
    uint n_9 = 0U;
    for(;;)
    {
        if(s_5 < 14U)
        {
        }
        else
        {
            break;
        }
        thread Box_0 _S352 = _S345;
        float3 _S353 = sample_point_0(&_S352, s_5);
        if((above_0 + _S353.z) < 0.0f)
        {
            n_9 = n_9 + 1U;
        }
        s_5 = s_5 + 1U;
    }
    if(n_9 == 0U)
    {
        return;
    }
    thread float3 vc_1;
    thread float3 wc_1;
    chunk_velocity_0(c_9, &vc_1, &wc_1, kernelContext_19);
    thread float4 ledger_2 = float4(*(kernelContext_19->scratch_0+(kernelContext_19->params_0->ledger_base_0 + kernelContext_19->params_0->pair_count_0 + c_9))) ;
    s_5 = 0U;
    for(;;)
    {
        if(s_5 < 14U)
        {
        }
        else
        {
            break;
        }
        thread Box_0 _S354 = _S345;
        float3 _S355 = sample_point_0(&_S354, s_5);
        float _S356 = above_0 + _S355.z;
        if(!(_S356 < 0.0f))
        {
            s_5 = s_5 + 1U;
            continue;
        }
        thread float stored_4;
        thread float diss_3;
        float3 _S357 = penalty_force_0(_S351 / float(max(n_9, 5U)), (float4(_S343->center_0) ).w, kernelContext_19->params_0->ground_friction_0, - _S356, _S348, vc_1 + cross(wc_1, _S355), kernelContext_19->params_0->dt_0, n_9, &stored_4, &diss_3, kernelContext_19);
        *f_0 = *f_0 + _S357;
        *t_4 = *t_4 + cross(_S355, _S357);
        thread float _S358 = ledger_2.y;
        thread float _S359 = ledger_2.z;
        comp_add1_0(&_S358, &_S359, diss_3);
        ledger_2.z = _S359;
        ledger_2.y = _S358;
        s_5 = s_5 + 1U;
    }
    if(account_0)
    {
        *(kernelContext_19->scratch_0+(kernelContext_19->params_0->ledger_base_0 + kernelContext_19->params_0->pair_count_0 + c_9)) = packed_float4(ledger_2) ;
    }
    return;
}

void group_sum3_0(uint tid_3, float3 thread* a_6, float3 thread* b_12, KernelContext_0 thread* kernelContext_20)
{
    thread float4 x_3 = float4(*a_6, 0.0f);
    thread float4 y_1 = float4(*b_12, 0.0f);
    group_sum2_0(tid_3, &x_3, &y_1, kernelContext_20);
    *a_6 = x_3.xyz;
    *b_12 = y_1.xyz;
    return;
}

bool connected_0(const JointState_0 thread* st_0, bool has_rebar_0)
{
    bool _S360;
    if((st_0->damage_0) < 1.0f)
    {
        _S360 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S360 = (st_0->rebar_broken_0) == 0.0f;
        }
        else
        {
            _S360 = false;
        }
    }
    return _S360;
}

struct Measures_0
{
    float tension_0;
    float shear_0;
    float normal_compression_0;
    float compression_0;
    float compressive_force_0;
};

Measures_0 stress_measures_0(const JointBond_natural_0 thread* b_13, float3 q_lin_0, float3 q_ang_0)
{
    float4 _S361 = float4(b_13->geom0_0) ;
    float area_2 = _S361.x;
    float _S362 = q_lin_0.z;
    float axial_0 = _S362 / area_2;
    float4 _S363 = float4(b_13->geom1_0) ;
    float bending_0 = abs(q_ang_0.x) / _S363.x + abs(q_ang_0.y) / _S363.y;
    float _S364 = q_lin_0.x;
    float _S365 = q_lin_0.y;
    float shear_1 = sqrt(_S364 * _S364 + _S365 * _S365) / area_2 + abs(q_ang_0.z) / _S361.w;
    thread Measures_0 m_3;
    (&m_3)->tension_0 = axial_0 + bending_0;
    (&m_3)->shear_0 = shear_1;
    float _S366 = - axial_0;
    (&m_3)->normal_compression_0 = max(_S366, 0.0f);
    (&m_3)->compression_0 = _S366 + bending_0;
    (&m_3)->compressive_force_0 = max(- _S362, 0.0f);
    return m_3;
}

float expm1_accurate_0(float x_4)
{
    if((abs(x_4)) < 0.00100000004749745f)
    {
        return x_4 * (1.0f + x_4 * (0.5f + x_4 * 0.1666666716337204f));
    }
    return exp(x_4) - 1.0f;
}

float dif_factor_0(const JointMaterial_0 constant* mat_1, float strain_rate_1)
{
    float r_5 = abs(strain_rate_1);
    float4 _S367 = mat_1->dif_0;
    float ref_0 = mat_1->dif_0.x;
    if(r_5 <= ref_0)
    {
        return 1.0f;
    }
    float _S368 = _S367.z;
    float f_1;
    if(r_5 <= _S368)
    {
        f_1 = pow(r_5 / ref_0, _S367.y);
    }
    else
    {
        f_1 = pow(_S368 / ref_0, _S367.y) * pow(r_5 / _S368, _S367.w);
    }
    return clamp(f_1, 1.0f, mat_1->misc_0.x);
}

float fatigue_factor_0(const JointMaterial_0 constant* mat_2, float fatigue_1)
{
    if(((mat_2->kind_flags_0.y) & 64U) == 0U)
    {
        return 1.0f;
    }
    return pow(1.0f - clamp(fatigue_1, 0.0f, 1.0f), 1.0f / (mat_2->misc_0.y - 2.0f));
}

float infinity_0()
{
    return (as_type<float>((2139095040U)));
}

float4 failure_indices_0(const JointMaterial_0 constant* mat_3, const JointBond_natural_0 thread* b_14, const Measures_0 thread* m_4, float multiplier_0)
{
    float fc_0 = mat_3->strength_0.y * multiplier_0;
    float _S369 = min(mat_3->strength_0.z * multiplier_0 + mat_3->strength_0.w * m_4->normal_compression_0, mat_3->energy_1.x * multiplier_0);
    thread float4 idx_1;
    idx_1.x = max(m_4->tension_0 / (mat_3->strength_0.x * multiplier_0), 0.0f);
    float _S370;
    if(_S369 > 0.0f)
    {
        _S370 = m_4->shear_0 / _S369;
    }
    else
    {
        _S370 = infinity_0();
    }
    idx_1.y = _S370;
    idx_1.z = max(m_4->compression_0 / fc_0, 0.0f);
    float _S371 = (float4(b_14->stiff1_0) ).y;
    if(_S371 > 0.0f)
    {
        _S370 = m_4->compressive_force_0 / _S371;
    }
    else
    {
        _S370 = 0.0f;
    }
    idx_1.w = _S370;
    return idx_1;
}

float sq_0(float x_5)
{
    return x_5 * x_5;
}

float damage_law_0(uint kind_1, float kappa_1, float r_6)
{
    if(kappa_1 <= 1.0f)
    {
        return 0.0f;
    }
    if(kind_1 == 0U)
    {
        if(r_6 <= 1.0f)
        {
            return 1.0f;
        }
        return min(r_6 * (kappa_1 - 1.0f) / (kappa_1 * (r_6 - 1.0f)), 1.0f);
    }
    if(kappa_1 >= (0.5f * (r_6 + 1.0f)))
    {
        return 1.0f;
    }
    return 1.0f - 1.0f / kappa_1;
}

float2 damage_increment_0(uint kind_2, float kappa_old_0, float lambda_0, float r_7, float d_old_0, float psi_0)
{
    float _S372 = max(damage_law_0(kind_2, lambda_0, r_7), d_old_0);
    bool _S373;
    if(_S372 <= d_old_0)
    {
        _S373 = true;
    }
    else
    {
        _S373 = d_old_0 >= 1.0f;
    }
    if(_S373)
    {
        return float2(d_old_0, 0.0f);
    }
    float u0_0 = psi_0 / (lambda_0 * lambda_0);
    float _S374 = max(kappa_old_0, 1.0f);
    if(kind_2 == 0U)
    {
        if(r_7 > 1.0f)
        {
            return float2(_S372, u0_0 * r_7 / (r_7 - 1.0f) * max(min(lambda_0, r_7) - min(_S374, r_7), 0.0f));
        }
        return float2(_S372, (1.0f - d_old_0) * psi_0);
    }
    float ku_0 = 0.5f * (r_7 + 1.0f);
    float plateau_0 = u0_0 * max(min(lambda_0, ku_0) - min(_S374, ku_0), 0.0f);
    float snap_0;
    if(_S372 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return float2(_S372, plateau_0 + snap_0);
}

void compressed_region_0(float w0_0, float w1_0, float dz_0, float ax_0, float ay_0, array<float, int(6)> thread* region_0)
{
    uint count_3;
    float h0_0 = 0.5f * w0_0;
    float h1_0 = 0.5f * w1_0;
    float _S375 = - h0_0;
    float _S376 = - h1_0;
    array<float2, int(4)> _S377 = { { float2(_S375, _S376), float2(h0_0, _S376), float2(h0_0, h1_0), float2(_S375, h1_0) } };
    thread array<float2, int(8)> poly_0;
    uint i_5 = 0U;
    uint count_4 = 0U;
    for(;;)
    {
        if(i_5 < 4U)
        {
        }
        else
        {
            break;
        }
        uint _S378 = i_5;
        uint _S379 = i_5 + 1U;
        uint _S380 = _S379 % 4U;
        float _S381 = _S377[i_5].y;
        float _S382 = _S377[i_5].x;
        float fp_0 = dz_0 + ax_0 * _S381 - ay_0 * _S382;
        float _S383 = _S377[_S380].y;
        float _S384 = _S377[_S380].x;
        float fq_0 = dz_0 + ax_0 * _S383 - ay_0 * _S384;
        bool _S385 = fp_0 < 0.0f;
        if(_S385)
        {
            uint _S386 = count_4 + 1U;
            poly_0[count_4] = _S377[_S378];
            count_3 = _S386;
        }
        else
        {
            count_3 = count_4;
        }
        if(_S385 != (fq_0 < 0.0f))
        {
            float t_5 = fp_0 / (fp_0 - fq_0);
            uint _S387 = count_3 + 1U;
            poly_0[count_3] = float2(_S382 + t_5 * (_S384 - _S382), _S381 + t_5 * (_S383 - _S381));
            count_4 = _S387;
        }
        else
        {
            count_4 = count_3;
        }
        i_5 = _S379;
    }
    count_3 = 0U;
    for(;;)
    {
        if(count_3 < 6U)
        {
        }
        else
        {
            break;
        }
        (*region_0)[count_3] = 0.0f;
        count_3 = count_3 + 1U;
    }
    if(count_4 < 3U)
    {
        return;
    }
    float2 o_1 = poly_0[int(0)];
    i_5 = 0U;
    float a_7 = 0.0f;
    float sx_0 = 0.0f;
    float sy_0 = 0.0f;
    float ixx_0 = 0.0f;
    float iyy_0 = 0.0f;
    float ixy_0 = 0.0f;
    for(;;)
    {
        if(i_5 < count_4)
        {
        }
        else
        {
            break;
        }
        float _S388 = o_1.x;
        float x0_0 = poly_0[i_5].x - _S388;
        float _S389 = o_1.y;
        float y0_0 = poly_0[i_5].y - _S389;
        uint _S390 = i_5 + 1U;
        uint _S391 = _S390 % count_4;
        float x1_0 = poly_0[_S391].x - _S388;
        float y1_0 = poly_0[_S391].y - _S389;
        float _S392 = x0_0 * y1_0;
        float _S393 = x1_0 * y0_0;
        float cr_0 = _S392 - _S393;
        float a_8 = a_7 + cr_0 / 2.0f;
        float sx_1 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        float sy_1 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        float ixx_1 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        float iyy_1 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        float ixy_1 = ixy_0 + (_S392 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S393) * cr_0 / 24.0f;
        i_5 = _S390;
        a_7 = a_8;
        sx_0 = sx_1;
        sy_0 = sy_1;
        ixx_0 = ixx_1;
        iyy_0 = iyy_1;
        ixy_0 = ixy_1;
    }
    if(a_7 <= 0.0f)
    {
        return;
    }
    float cx_0 = sx_0 / a_7;
    float cy_0 = sy_0 / a_7;
    (*region_0)[int(0)] = a_7;
    (*region_0)[int(1)] = o_1.x + cx_0;
    (*region_0)[int(2)] = o_1.y + cy_0;
    float _S394 = a_7 * cx_0;
    (*region_0)[int(3)] = ixx_0 - _S394 * cx_0;
    (*region_0)[int(4)] = iyy_0 - a_7 * cy_0 * cy_0;
    (*region_0)[int(5)] = ixy_0 - _S394 * cy_0;
    return;
}

float4 no_tension_patch_0(float kn_0, float w0_1, float w1_1, float dz_1, float ax_1, float ay_1)
{
    thread array<float, int(6)> r_8;
    compressed_region_0(w0_1, w1_1, dz_1, ax_1, ay_1, &r_8);
    float a_9 = r_8[int(0)];
    if((r_8[int(0)]) == 0.0f)
    {
        return float4(0.0f) ;
    }
    float k_12 = kn_0 / (w0_1 * w1_1);
    float fc_1 = dz_1 + ax_1 * r_8[int(2)] - ay_1 * r_8[int(1)];
    float _S395 = a_9 * fc_1;
    float _S396 = - ay_1;
    return float4(k_12 * a_9 * fc_1, k_12 * (_S395 * r_8[int(2)] + (_S396 * r_8[int(5)] + ax_1 * r_8[int(4)])), - k_12 * (_S395 * r_8[int(1)] + (_S396 * r_8[int(3)] + ax_1 * r_8[int(5)])), 0.5f * k_12 * (_S395 * fc_1 + ay_1 * ay_1 * r_8[int(3)] + ax_1 * ax_1 * r_8[int(4)] - 2.0f * ax_1 * ay_1 * r_8[int(5)]));
}

float signum_0(float x_6)
{
    float _S397;
    if(((as_type<uint>((x_6))) & 2147483648U) != 0U)
    {
        _S397 = -1.0f;
    }
    else
    {
        _S397 = 1.0f;
    }
    return _S397;
}

float2 return_map_0(float k_13, float total_3, float plastic_0, float cap_0)
{
    float trial_0 = k_13 * (total_3 - plastic_0);
    if((abs(trial_0)) <= cap_0)
    {
        return float2(trial_0, 0.0f);
    }
    float f_2 = cap_0 * signum_0(trial_0);
    return float2(f_2, (trial_0 - f_2) / k_13);
}

struct Contact_0
{
    float3 q_lin_1;
    float3 q_ang_1;
    float energy_2;
    float diss_4;
    float3 plastic_1;
};

Contact_0 contact_part_0(const JointMaterial_0 constant* mat_4, const JointBond_natural_0 thread* b_15, float crush_2, float3 plastic_2, float3 d_lin_0, float3 d_ang_0)
{
    thread Contact_0 c_10;
    float3 _S398 = float3(0.0f) ;
    (&c_10)->q_lin_1 = _S398;
    (&c_10)->q_ang_1 = _S398;
    (&c_10)->energy_2 = 0.0f;
    (&c_10)->diss_4 = 0.0f;
    (&c_10)->plastic_1 = plastic_2;
    uint _S399 = mat_4->kind_flags_0.y;
    if((_S399 & 2U) == 0U)
    {
        return c_10;
    }
    float4 _S400 = float4(b_15->stiff0_0) ;
    float kn_1 = _S400.x;
    float ks_0 = _S400.y;
    float kt_0 = (float4(b_15->stiff1_0) ).x;
    float4 _S401 = float4(b_15->geom0_0) ;
    float w0_2 = _S401.y;
    float w1_2 = _S401.z;
    float diss_5;
    float nc_sum_0;
    float m1_0;
    float m2_0;
    float energy_3;
    if((_S399 & 4U) != 0U)
    {
        float4 p_4 = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        float _S402 = p_4.y;
        float _S403 = p_4.z;
        float _S404 = p_4.w;
        nc_sum_0 = p_4.x;
        m1_0 = _S402;
        m2_0 = _S403;
        energy_3 = _S404;
    }
    else
    {
        float ki_0 = kn_1 * (1.0f - crush_2) / 36.0f;
        float _S405 = d_ang_0.x;
        float _S406 = d_ang_0.y;
        float spread_0 = abs(_S405) * 0.4166666567325592f * w1_2 + abs(_S406) * 0.4166666567325592f * w0_2;
        float _S407 = d_lin_0.z;
        float slack_0 = 9.99999997475242708e-07f * (abs(_S407) + spread_0);
        if((_S407 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S407 + spread_0) < (- slack_0))
            {
                float i1_0 = 2.91666650772094727f * w0_2 * w0_2;
                float i2_0 = 2.91666650772094727f * w1_2 * w1_2;
                float _S408 = ki_0 * _S405 * i2_0;
                float _S409 = ki_0 * _S406 * i1_0;
                float _S410 = 0.5f * ki_0 * (36.0f * _S407 * _S407 + _S405 * _S405 * i2_0 + _S406 * _S406 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S407;
                m1_0 = _S408;
                m2_0 = _S409;
                energy_3 = _S410;
            }
            else
            {
                uint i_6 = 0U;
                diss_5 = 0.0f;
                float m1_1 = 0.0f;
                float m2_1 = 0.0f;
                float energy_4 = 0.0f;
                for(;;)
                {
                    if(i_6 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float _S411 = ((float(i_6) + 0.5f) / 6.0f - 0.5f) * w0_2;
                    uint j_3 = 0U;
                    nc_sum_0 = diss_5;
                    m1_0 = m1_1;
                    m2_0 = m2_1;
                    energy_3 = energy_4;
                    for(;;)
                    {
                        if(j_3 < 6U)
                        {
                        }
                        else
                        {
                            break;
                        }
                        float s2_0 = ((float(j_3) + 0.5f) / 6.0f - 0.5f) * w1_2;
                        float di_0 = _S407 + _S405 * s2_0 - _S406 * _S411;
                        if(di_0 < 0.0f)
                        {
                            float f_3 = ki_0 * di_0;
                            float m1_2 = m1_0 + f_3 * s2_0;
                            float m2_2 = m2_0 - f_3 * _S411;
                            float energy_5 = energy_3 + 0.5f * ki_0 * di_0 * di_0;
                            nc_sum_0 = nc_sum_0 + f_3;
                            m1_0 = m1_2;
                            m2_0 = m2_2;
                            energy_3 = energy_5;
                        }
                        j_3 = j_3 + 1U;
                    }
                    i_6 = i_6 + 1U;
                    diss_5 = nc_sum_0;
                    m1_1 = m1_0;
                    m2_1 = m2_0;
                    energy_4 = energy_3;
                }
                nc_sum_0 = diss_5;
                m1_0 = m1_1;
                m2_0 = m2_1;
                energy_3 = energy_4;
            }
        }
    }
    float nc_0 = - nc_sum_0;
    thread float3 p_5 = plastic_2;
    (&c_10)->q_lin_1 = float3(0.0f, 0.0f, nc_sum_0);
    (&c_10)->q_ang_1 = float3(m1_0, m2_0, 0.0f);
    float slide_cap_0 = mat_4->strength_0.w * nc_0;
    float _S412 = ks_0 * (d_lin_0.x - plastic_2.x);
    float _S413 = ks_0 * (d_lin_0.y - plastic_2.y);
    float2 trial_1 = float2(_S412, _S413);
    float tn_0 = sqrt(_S412 * _S412 + _S413 * _S413);
    bool _S414;
    if(tn_0 > slide_cap_0)
    {
        _S414 = tn_0 > 0.0f;
    }
    else
    {
        _S414 = false;
    }
    if(_S414)
    {
        float2 dir_1 = trial_1 / float2(tn_0) ;
        float dslip_0 = (tn_0 - slide_cap_0) / ks_0;
        float _S415 = dir_1.x;
        p_5.x = p_5.x + _S415 * dslip_0;
        float _S416 = dir_1.y;
        p_5.y = p_5.y + _S416 * dslip_0;
        (&c_10)->q_lin_1.x = _S415 * slide_cap_0;
        (&c_10)->q_lin_1.y = _S416 * slide_cap_0;
        diss_5 = slide_cap_0 * dslip_0;
    }
    else
    {
        (&c_10)->q_lin_1.x = _S412;
        (&c_10)->q_lin_1.y = _S413;
        diss_5 = 0.0f;
    }
    float2 tq_0 = return_map_0(kt_0, d_ang_0.z, p_5.z, slide_cap_0 * (float4(b_15->geom1_0) ).z);
    float _S417 = tq_0.x;
    float _S418 = tq_0.y;
    float diss_6 = diss_5 + abs(_S417) * abs(_S418);
    p_5.z = p_5.z + _S418;
    (&c_10)->q_ang_1.z = _S417;
    (&c_10)->energy_2 = energy_3 + 0.5f * (sq_0((&c_10)->q_lin_1.x) / ks_0 + sq_0((&c_10)->q_lin_1.y) / ks_0 + sq_0(_S417) / kt_0);
    (&c_10)->diss_4 = diss_6;
    (&c_10)->plastic_1 = p_5;
    return c_10;
}

float life_rate_0(const JointMaterial_0 constant* mat_5, float s_6)
{
    if(s_6 <= 0.0f)
    {
        return 0.0f;
    }
    float _S419 = mat_5->misc_0.y;
    return (_S419 + 1.0f) * pow(s_6, _S419) / mat_5->misc_0.z;
}

struct JointResponse_0
{
    float3 force_lin_1;
    float3 force_ang_1;
    JointState_0 state_5;
    float dissipated_2;
    float overshoot_0;
    float stored_5;
    bool disconnected_0;
    Measures_0 measures_0;
};

JointResponse_0 joint_evaluate_0(const JointMaterial_0 constant* mat_6, const JointBond_natural_0 thread* b_16, const JointState_0 thread* state_6, float3 d_lin_1, float3 d_ang_1, float dt_6, bool fracture_1)
{
    float4 _S420 = float4(b_16->stiff0_0) ;
    float kn_2 = _S420.x;
    float ks_1 = _S420.y;
    float kb1_0 = _S420.z;
    float kb2_0 = _S420.w;
    float4 _S421 = float4(b_16->stiff1_0) ;
    float kt_1 = _S421.x;
    bool has_rebar_1 = (_S421.w) != 0.0f;
    uint kind_3 = mat_6->kind_flags_0.x;
    uint flags_1 = mat_6->kind_flags_0.y;
    bool softening_0 = (flags_1 & 1U) != 0U;
    thread JointState_0 st_1 = *state_6;
    bool _S422 = connected_0(state_6, has_rebar_1);
    float3 qe_lin_0 = d_lin_1 * float3(ks_1, ks_1, kn_2);
    float3 qe_ang_0 = d_ang_1 * float3(kb1_0, kb2_0, kt_1);
    Measures_0 _S423 = stress_measures_0(b_16, qe_lin_0, qe_ang_0);
    float _S424 = max(max(_S423.tension_0, _S423.shear_0), _S423.compression_0);
    bool _S425 = dt_6 > 0.0f;
    float dif_1;
    if(_S425)
    {
        float raw_0 = max((_S424 - (&st_1)->governing_stress_0) / dt_6, 0.0f) / mat_6->misc_0.w;
        float tau_2 = _S421.z;
        if((flags_1 & 16U) != 0U)
        {
            dif_1 = - expm1_accurate_0(- dt_6 / tau_2);
        }
        else
        {
            dif_1 = min(dt_6 / tau_2, 1.0f);
        }
        (&st_1)->strain_rate_0 = (&st_1)->strain_rate_0 + (raw_0 - (&st_1)->strain_rate_0) * dif_1;
        (&st_1)->governing_stress_0 = _S424;
    }
    if((flags_1 & 32U) != 0U)
    {
        float _S426 = dif_factor_0(mat_6, (&st_1)->strain_rate_0);
        dif_1 = _S426;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = (float4(b_16->geom1_0) ).w;
    float _S427 = weibull_0 * dif_1;
    float _S428 = fatigue_factor_0(mat_6, (&st_1)->fatigue_0);
    float multiplier_1 = _S427 * _S428;
    thread Measures_0 _S429 = _S423;
    float4 _S430 = failure_indices_0(mat_6, b_16, &_S429, multiplier_1);
    float _S431 = _S430.x;
    float _S432 = _S430.y;
    (&st_1)->utilization_0 = max(max(_S431, _S432), max(_S430.z, _S430.w));
    float _S433 = d_lin_1.x;
    float _S434 = d_lin_1.y;
    float _S435 = ks_1 * (sq_0(_S433) + sq_0(_S434)) + kb1_0 * sq_0(d_ang_1.x) + kb2_0 * sq_0(d_ang_1.y) + kt_1 * sq_0(d_ang_1.z);
    float _S436 = d_lin_1.z;
    bool _S437 = _S436 > 0.0f;
    if(_S437)
    {
        dif_1 = kn_2 * sq_0(_S436);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S435 + dif_1);
    float psi_c_0;
    if(_S436 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_2 * sq_0(_S436);
    }
    else
    {
        psi_c_0 = 0.0f;
    }
    float3 plastic_3 = float3((&st_1)->plastic_x_0, (&st_1)->plastic_y_0, (&st_1)->plastic_t_0);
    float diss_contact_0;
    float psi_contact_0;
    float intact_normal_0;
    float dissipated_3;
    float overshoot_1;
    bool _S438;
    float3 qc_lin_0;
    if(fracture_1)
    {
        bool _S439 = _S431 >= _S432;
        if(_S439)
        {
            diss_contact_0 = _S431;
        }
        else
        {
            diss_contact_0 = _S432;
        }
        uint mode_ts_0;
        if(_S439)
        {
            mode_ts_0 = 1U;
        }
        else
        {
            mode_ts_0 = 2U;
        }
        if(diss_contact_0 > ((&st_1)->kappa_0))
        {
            _S438 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S438 = false;
        }
        if(_S438)
        {
            _S438 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S438 = false;
        }
        uint mode_c_0;
        if(_S438)
        {
            if(mode_ts_0 == 1U)
            {
                psi_contact_0 = mat_6->energy_1.y;
            }
            else
            {
                psi_contact_0 = mat_6->energy_1.z;
            }
            if(softening_0)
            {
                intact_normal_0 = psi_contact_0 * (float4(b_16->geom0_0) ).x * diss_contact_0 * diss_contact_0 / psi_ts_0;
            }
            else
            {
                intact_normal_0 = 0.0f;
            }
            (&st_1)->ductility_0 = intact_normal_0;
            if(softening_0)
            {
                mode_c_0 = kind_3;
            }
            else
            {
                mode_c_0 = 0U;
            }
            float2 inc_0 = damage_increment_0(mode_c_0, (&st_1)->kappa_0, diss_contact_0, intact_normal_0, (&st_1)->damage_0, psi_ts_0);
            float _S440 = inc_0.x;
            if(_S440 > ((&st_1)->damage_0))
            {
                Contact_0 _S441 = contact_part_0(mat_6, b_16, (&st_1)->crush_1, plastic_3, d_lin_1, d_ang_1);
                float _S442 = max(_S441.energy_2 - (1.0f - (&st_1)->crush_1) * psi_c_0, 0.0f);
                float _S443 = max(inc_0.y - _S442 * (_S440 - (&st_1)->damage_0), 0.0f);
                float _S444 = max((psi_ts_0 - _S442) * (_S440 - (&st_1)->damage_0) - _S443, 0.0f);
                (&st_1)->damage_0 = _S440;
                (&st_1)->mode_0 = mode_ts_0;
                dissipated_3 = _S443;
                overshoot_1 = _S444;
            }
            else
            {
                dissipated_3 = 0.0f;
                overshoot_1 = 0.0f;
            }
        }
        else
        {
            dissipated_3 = 0.0f;
            overshoot_1 = 0.0f;
        }
        (&st_1)->kappa_0 = max((&st_1)->kappa_0, diss_contact_0);
        float _S445 = state_6->damage_0;
        if((state_6->damage_0) > 0.0f)
        {
            Contact_0 _S446 = contact_part_0(mat_6, b_16, state_6->crush_1, float3(state_6->plastic_x_0, state_6->plastic_y_0, state_6->plastic_t_0), d_lin_1, d_ang_1);
            qc_lin_0 = qe_ang_0 * float3((1.0f - _S445))  + _S446.q_ang_1 * float3(_S445) ;
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S447 = stress_measures_0(b_16, float3(0.0f, 0.0f, min(qe_lin_0.z, 0.0f)), qc_lin_0);
        thread Measures_0 _S448 = _S447;
        float4 _S449 = failure_indices_0(mat_6, b_16, &_S448, multiplier_1);
        float _S450 = _S449.z;
        float _S451 = _S449.w;
        bool _S452 = _S450 >= _S451;
        if(_S452)
        {
            psi_contact_0 = _S450;
        }
        else
        {
            psi_contact_0 = _S451;
        }
        if(_S452)
        {
            mode_c_0 = 3U;
        }
        else
        {
            mode_c_0 = 4U;
        }
        if(psi_contact_0 > ((&st_1)->kappa_c_0))
        {
            _S438 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S438 = false;
        }
        if(_S438)
        {
            _S438 = psi_c_0 > 0.0f;
        }
        else
        {
            _S438 = false;
        }
        if(_S438)
        {
            if(softening_0)
            {
                intact_normal_0 = mat_6->energy_1.w * (float4(b_16->geom0_0) ).x * psi_contact_0 * psi_contact_0 / psi_c_0;
            }
            else
            {
                intact_normal_0 = 0.0f;
            }
            (&st_1)->ductility_c_0 = intact_normal_0;
            uint law_1;
            if(!softening_0)
            {
                law_1 = 0U;
            }
            else
            {
                if(mode_c_0 == 4U)
                {
                    mode_ts_0 = 1U;
                }
                else
                {
                    mode_ts_0 = kind_3;
                }
                law_1 = mode_ts_0;
            }
            float2 inc_1 = damage_increment_0(law_1, (&st_1)->kappa_c_0, psi_contact_0, intact_normal_0, (&st_1)->crush_1, psi_c_0);
            float _S453 = inc_1.x;
            if(_S453 > ((&st_1)->crush_1))
            {
                float _S454 = inc_1.y;
                float dissipated_4 = dissipated_3 + _S454;
                float overshoot_2 = overshoot_1 + max(psi_c_0 * (_S453 - (&st_1)->crush_1) - _S454, 0.0f);
                (&st_1)->crush_1 = _S453;
                (&st_1)->mode_0 = mode_c_0;
                if(_S453 >= 1.0f)
                {
                    _S438 = ((&st_1)->damage_0) < 1.0f;
                }
                else
                {
                    _S438 = false;
                }
                if(_S438)
                {
                    float dissipated_5 = dissipated_4 + psi_ts_0 * (1.0f - (&st_1)->damage_0);
                    (&st_1)->damage_0 = 1.0f;
                    dissipated_3 = dissipated_5;
                }
                else
                {
                    dissipated_3 = dissipated_4;
                }
                overshoot_1 = overshoot_2;
            }
        }
        (&st_1)->kappa_c_0 = max((&st_1)->kappa_c_0, psi_contact_0);
    }
    else
    {
        dissipated_3 = 0.0f;
        overshoot_1 = 0.0f;
    }
    float dmg_0 = (&st_1)->damage_0;
    float3 _S455 = float3(0.0f) ;
    if(((&st_1)->damage_0) == 0.0f)
    {
        _S438 = (flags_1 & 8U) != 0U;
    }
    else
    {
        _S438 = false;
    }
    float3 qc_ang_0;
    if(!_S438)
    {
        Contact_0 _S456 = contact_part_0(mat_6, b_16, (&st_1)->crush_1, plastic_3, d_lin_1, d_ang_1);
        (&st_1)->plastic_x_0 = _S456.plastic_1.x;
        (&st_1)->plastic_y_0 = _S456.plastic_1.y;
        (&st_1)->plastic_t_0 = _S456.plastic_1.z;
        diss_contact_0 = _S456.diss_4;
        qc_lin_0 = _S456.q_lin_1;
        qc_ang_0 = _S456.q_ang_1;
        psi_contact_0 = _S456.energy_2;
    }
    else
    {
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S455;
        qc_ang_0 = _S455;
        psi_contact_0 = 0.0f;
    }
    float dissipated_6 = dissipated_3 + dmg_0 * diss_contact_0;
    if(_S437)
    {
        intact_normal_0 = kn_2 * _S436;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_1)->crush_1) * kn_2 * _S436;
    }
    float _S457 = 1.0f - dmg_0;
    float3 force_lin_2 = float3(_S457 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S457 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S457 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3 force_ang_2 = qe_ang_0 * float3(_S457)  + qc_ang_0 * float3(dmg_0) ;
    float stored_6 = _S457 * (psi_ts_0 + (1.0f - (&st_1)->crush_1) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S438 = ((&st_1)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S438 = false;
    }
    float stored_7;
    float3 force_lin_3;
    if(_S438)
    {
        float4 _S458 = float4(b_16->rebar0_0) ;
        float k_axial_0 = _S458.x;
        float k_dowel_0 = _S458.y;
        float yield_force_0 = _S458.z;
        float dowel_capacity_0 = _S458.w;
        float2 nr_0 = return_map_0(k_axial_0, _S436, (&st_1)->rebar_plastic_0, yield_force_0);
        float2 v1_0 = return_map_0(k_dowel_0, _S433, (&st_1)->rebar_slip0_0, dowel_capacity_0);
        float2 v2_0 = return_map_0(k_dowel_0, _S434, (&st_1)->rebar_slip1_0, dowel_capacity_0);
        float _S459 = nr_0.y;
        float _S460 = v1_0.y;
        float _S461 = v2_0.y;
        float work_0 = yield_force_0 * abs(_S459) + dowel_capacity_0 * (abs(_S460) + abs(_S461));
        (&st_1)->rebar_plastic_0 = (&st_1)->rebar_plastic_0 + _S459;
        (&st_1)->rebar_slip0_0 = (&st_1)->rebar_slip0_0 + _S460;
        (&st_1)->rebar_slip1_0 = (&st_1)->rebar_slip1_0 + _S461;
        (&st_1)->rebar_work_0 = (&st_1)->rebar_work_0 + work_0;
        float dissipated_7 = dissipated_6 + work_0;
        float _S462 = nr_0.x;
        float _S463 = v1_0.x;
        float _S464 = v2_0.x;
        float elastic_0 = 0.5f * (sq_0(_S462) / k_axial_0 + (sq_0(_S463) + sq_0(_S464)) / k_dowel_0);
        if(fracture_1)
        {
            _S438 = ((&st_1)->rebar_work_0) >= ((float4(b_16->rebar1_0) ).x);
        }
        else
        {
            _S438 = false;
        }
        if(_S438)
        {
            (&st_1)->rebar_broken_0 = 1.0f;
            float dissipated_8 = dissipated_7 + elastic_0;
            force_lin_3 = force_lin_2;
            dissipated_3 = dissipated_8;
            stored_7 = stored_6;
        }
        else
        {
            float stored_8 = stored_6 + elastic_0;
            force_lin_3 = force_lin_2 + float3(_S463, _S464, _S462);
            dissipated_3 = dissipated_7;
            stored_7 = stored_8;
        }
    }
    else
    {
        force_lin_3 = force_lin_2;
        dissipated_3 = dissipated_6;
        stored_7 = stored_6;
    }
    if(fracture_1)
    {
        _S438 = _S425;
    }
    else
    {
        _S438 = false;
    }
    if(_S438)
    {
        _S438 = (flags_1 & 64U) != 0U;
    }
    else
    {
        _S438 = false;
    }
    if(_S438)
    {
        Measures_0 _S465 = stress_measures_0(b_16, force_lin_3, force_ang_2);
        thread Measures_0 _S466 = _S465;
        float4 _S467 = failure_indices_0(mat_6, b_16, &_S466, weibull_0);
        float _S468 = life_rate_0(mat_6, max(max(_S467.x, _S467.y), _S467.z));
        (&st_1)->fatigue_0 = min((&st_1)->fatigue_0 + _S468 * dt_6, 1.0f);
    }
    (&st_1)->dissipated_0 = (&st_1)->dissipated_0 + dissipated_3;
    thread JointResponse_0 resp_0;
    (&resp_0)->force_lin_1 = force_lin_3;
    (&resp_0)->force_ang_1 = force_ang_2;
    (&resp_0)->state_5 = st_1;
    (&resp_0)->dissipated_2 = dissipated_3;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_5 = stored_7;
    if(_S422)
    {
        thread JointState_0 _S469 = st_1;
        bool _S470 = connected_0(&_S469, has_rebar_1);
        _S438 = !_S470;
    }
    else
    {
        _S438 = false;
    }
    (&resp_0)->disconnected_0 = _S438;
    (&resp_0)->measures_0 = _S423;
    return resp_0;
}

void secant_factors_0(const JointBond_natural_0 thread* b_17, const JointState_0 thread* st_2, float3 d_lin_2, float3 thread* f_lin_0, float3 thread* f_ang_0)
{
    float _S471 = st_2->damage_0;
    bool compressed_0 = (d_lin_2.z) < 0.0f;
    float contact_0;
    if(compressed_0)
    {
        contact_0 = _S471;
    }
    else
    {
        contact_0 = 0.0f;
    }
    float _S472 = 1.0f - _S471;
    float _S473 = max(_S472 + contact_0, 9.99999997475242708e-07f);
    float normal_4;
    if(compressed_0)
    {
        normal_4 = max(1.0f - st_2->crush_1, 9.99999997475242708e-07f);
    }
    else
    {
        normal_4 = max(_S472, 9.99999997475242708e-07f);
    }
    *f_lin_0 = float3(_S473, _S473, normal_4);
    *f_ang_0 = float3(_S473) ;
    bool _S474;
    if(((float4(b_17->stiff1_0) ).w) != 0.0f)
    {
        _S474 = (st_2->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S474 = false;
    }
    if(_S474)
    {
        float4 _S475 = float4(b_17->rebar0_0) ;
        float4 _S476 = float4(b_17->stiff0_0) ;
        (*f_lin_0).z = (*f_lin_0).z + _S475.x / _S476.x;
        float _S477 = _S475.y;
        float _S478 = _S476.y;
        (*f_lin_0).x = (*f_lin_0).x + _S477 / _S478;
        (*f_lin_0).y = (*f_lin_0).y + _S477 / _S478;
    }
    return;
}

bool is_damaged_0(const JointState_0 thread* st_3)
{
    bool _S479;
    if((st_3->damage_0) > 0.0f)
    {
        _S479 = true;
    }
    else
    {
        _S479 = (st_3->crush_1) > 0.0f;
    }
    return _S479;
}

struct BondDyn_0
{
    JointState_0 js_0;
    float4 force_lin_0;
    float4 force_ang_0;
    float4 sums_0;
    float4 comps_0;
    uint4 events_0;
};

float3 to_local_0(uint _S480, float3 _S481, KernelContext_0 thread* kernelContext_21)
{
    BondStatic_natural_0 device* _S482 = kernelContext_21->bonds_0+_S480;
    return float3(dot(_S481, (float4(_S482->t1_0) ).xyz), dot(_S481, (float4(_S482->t2_0) ).xyz), dot(_S481, (float4(_S482->normal_0) ).xyz));
}

float3 to_body_0(uint _S483, float3 _S484, KernelContext_0 thread* kernelContext_22)
{
    BondStatic_natural_0 device* _S485 = kernelContext_22->bonds_0+_S483;
    return (float4(_S485->t1_0) ).xyz * float3(_S484.x)  + (float4(_S485->t2_0) ).xyz * float3(_S484.y)  + (float4(_S485->normal_0) ).xyz * float3(_S484.z) ;
}

void bond_update_0(uint i_7, float dt_7, bool fracture_2, uint abs_step_0, KernelContext_0 thread* kernelContext_23)
{
    BondStatic_natural_0 device* _S486 = kernelContext_23->bonds_0+i_7;
    BondDyn_natural_0 device* _S487 = kernelContext_23->bond_dyn_0+i_7;
    float4 _S488 = float4((*_S487).force_lin_0) ;
    float4 _S489 = float4((*_S487).force_ang_0) ;
    float4 _S490 = float4((*_S487).sums_0) ;
    float4 _S491 = float4((*_S487).comps_0) ;
    uint4 _S492 = uint4((*_S487).events_0) ;
    thread BondDyn_0 bd_0;
    (&bd_0)->js_0 = (*_S487).js_0;
    (&bd_0)->force_lin_0 = _S488;
    (&bd_0)->force_ang_0 = _S489;
    (&bd_0)->sums_0 = _S490;
    (&bd_0)->comps_0 = _S491;
    (&bd_0)->events_0 = _S492;
    JointBond_natural_0 _S493 = _S486->law_0;
    thread JointBond_natural_0 _S494 = _S486->law_0;
    uint4 _S495 = uint4((&_S494)->ids_0) ;
    float3 ra_1 = (float4(_S486->ra_0) ).xyz;
    float3 rb_1 = (float4(_S486->rb_0) ).xyz;
    uint _S496 = 4U * _S495.y;
    float3 ta_2 = (float4(*(kernelContext_23->state_0+(_S496 + 1U))) ).xyz;
    float3 va_0 = (float4(*(kernelContext_23->state_0+(_S496 + 2U))) ).xyz;
    float3 wa_0 = (float4(*(kernelContext_23->state_0+(_S496 + 3U))) ).xyz;
    uint _S497 = 4U * _S495.z;
    float3 tb_2 = (float4(*(kernelContext_23->state_0+(_S497 + 1U))) ).xyz;
    float3 vb_0 = (float4(*(kernelContext_23->state_0+(_S497 + 2U))) ).xyz;
    float3 wb_0 = (float4(*(kernelContext_23->state_0+(_S497 + 3U))) ).xyz;
    float3 _S498 = to_local_0(i_7, (float4(*(kernelContext_23->state_0+_S497)) ).xyz + cross(tb_2, rb_1) - ((float4(*(kernelContext_23->state_0+_S496)) ).xyz + cross(ta_2, ra_1)), kernelContext_23);
    float3 _S499 = to_local_0(i_7, tb_2 - ta_2, kernelContext_23);
    float3 _S500 = to_local_0(i_7, vb_0 + cross(wb_0, rb_1) - (va_0 + cross(wa_0, ra_1)), kernelContext_23);
    float3 _S501 = to_local_0(i_7, wb_0 - wa_0, kernelContext_23);
    JointState_0 previous_0 = (&bd_0)->js_0;
    _S494 = _S493;
    thread JointState_0 _S502 = (&bd_0)->js_0;
    JointResponse_0 _S503 = joint_evaluate_0(&kernelContext_23->materials_0->m_0[_S495.x], &_S494, &_S502, _S498, _S499, dt_7, fracture_2);
    thread JointState_0 _S504 = _S503.state_5;
    thread float3 f_lin_1;
    thread float3 f_ang_1;
    secant_factors_0(&_S494, &_S504, _S498, &f_lin_1, &f_ang_1);
    float3 qd_lin_0 = _S500 * (float4(_S486->c_lin_0) ).xyz * f_lin_1;
    float3 qd_ang_0 = _S501 * (float4(_S486->c_ang_0) ).xyz * f_ang_1;
    float3 q_lin_2 = _S503.force_lin_1 + qd_lin_0;
    float3 q_ang_2 = _S503.force_ang_1 + qd_ang_0;
    float damped_0 = (dot(qd_lin_0, _S500) + dot(qd_ang_0, _S501)) * dt_7;
    float3 _S505 = to_body_0(i_7, q_lin_2, kernelContext_23);
    float3 _S506 = to_body_0(i_7, q_ang_2, kernelContext_23);
    uint _S507 = 3U * i_7;
    *(kernelContext_23->scratch_0+_S507) = packed_float4(float4(_S505, max(_S503.measures_0.tension_0, _S503.measures_0.compression_0))) ;
    *(kernelContext_23->scratch_0+(_S507 + 1U)) = packed_float4(float4(_S506 + cross(ra_1, _S505), 0.0f)) ;
    *(kernelContext_23->scratch_0+(_S507 + 2U)) = packed_float4(float4(- _S506 + cross(rb_1, - _S505), 0.0f)) ;
    thread float _S508 = (&bd_0)->sums_0.x;
    thread float _S509 = (&bd_0)->comps_0.x;
    comp_add1_0(&_S508, &_S509, _S503.dissipated_2);
    (&bd_0)->comps_0.x = _S509;
    (&bd_0)->sums_0.x = _S508;
    thread float _S510 = (&bd_0)->sums_0.y;
    thread float _S511 = (&bd_0)->comps_0.y;
    comp_add1_0(&_S510, &_S511, _S503.overshoot_0);
    (&bd_0)->comps_0.y = _S511;
    (&bd_0)->sums_0.y = _S510;
    thread float _S512 = (&bd_0)->sums_0.z;
    thread float _S513 = (&bd_0)->comps_0.z;
    comp_add1_0(&_S512, &_S513, damped_0);
    (&bd_0)->comps_0.z = _S513;
    (&bd_0)->sums_0.z = _S512;
    (&bd_0)->force_lin_0 = float4(q_lin_2, _S503.stored_5);
    (&bd_0)->force_ang_0 = float4(q_ang_2, max((&bd_0)->force_ang_0.w, _S503.state_5.utilization_0));
    thread JointState_0 _S514 = previous_0;
    bool _S515 = is_damaged_0(&_S514);
    bool _S516;
    if(!_S515)
    {
        thread JointState_0 _S517 = _S503.state_5;
        bool _S518 = is_damaged_0(&_S517);
        _S516 = _S518;
    }
    else
    {
        _S516 = false;
    }
    if(_S516)
    {
        _S516 = ((&bd_0)->events_0.x) == 0U;
    }
    else
    {
        _S516 = false;
    }
    if(_S516)
    {
        (&bd_0)->events_0.x = abs_step_0;
        (&bd_0)->events_0.w = _S503.state_5.mode_0;
    }
    if(((&bd_0)->events_0.y) == 0U)
    {
        float _S519 = fatigue_factor_0(&kernelContext_23->materials_0->m_0[_S495.x], previous_0.fatigue_0);
        _S516 = _S519 > 0.99000000953674316f;
    }
    else
    {
        _S516 = false;
    }
    if(_S516)
    {
        float _S520 = fatigue_factor_0(&kernelContext_23->materials_0->m_0[_S495.x], _S503.state_5.fatigue_0);
        _S516 = _S520 <= 0.99000000953674316f;
    }
    else
    {
        _S516 = false;
    }
    if(_S516)
    {
        (&bd_0)->events_0.y = abs_step_0;
    }
    if(_S503.disconnected_0)
    {
        (&bd_0)->events_0.z = abs_step_0;
        *kernelContext_23->g_halt_0 = 1U;
    }
    (&bd_0)->js_0 = _S503.state_5;
    BondDyn_natural_0 device* _S521 = kernelContext_23->bond_dyn_0+i_7;
    _S521->js_0 = bd_0.js_0;
    _S521->force_lin_0 = packed_float4(bd_0.force_lin_0) ;
    _S521->force_ang_0 = packed_float4(bd_0.force_ang_0) ;
    _S521->sums_0 = packed_float4(bd_0.sums_0) ;
    _S521->comps_0 = packed_float4(bd_0.comps_0) ;
    _S521->events_0 = packed_uint4(bd_0.events_0) ;
    return;
}

struct Island_0
{
    uint4 range_0;
    uint4 info_0;
    float4 com_0;
    float4 inertia0_0;
    float4 inertia1_0;
    float4 inertia2_0;
    float4 inv0_0;
    float4 inv1_0;
    float4 inv2_0;
    float4 wcom_0;
    float4 winv0_0;
    float4 winv1_0;
    float4 winv2_0;
    float4 rotation_0;
    float4 position_0;
    float4 position_err_0;
    float4 velocity_0;
    float4 velocity_err_0;
    float4 angular_velocity_0;
    uint4 done_0;
    uint4 probes_0;
    float4 energy_0;
};

struct Rigid_0
{
    Quat_0 rot_0;
    float3 pos_1;
    float3 pos_err_1;
    float3 vel_1;
    float3 vel_err_1;
    float3 w_3;
    float3 a_10;
    float3 alpha_0;
};

void chunk_external_0(uint _S522, uint _S523, const Quat_0 thread* _S524, uint _S525, float _S526, bool _S527, bool _S528, float3 thread* _S529, float3 thread* _S530, KernelContext_0 thread* kernelContext_24)
{
    ChunkStatic_natural_0 device* _S531 = kernelContext_24->chunks_0+_S523;
    float3 _S532 = float3(0.0f) ;
    *_S529 = _S532;
    *_S530 = _S532;
    uint4 _S533 = uint4(_S531->load_range_0) ;
    uint term_1 = _S533.x;
    for(;;)
    {
        if(term_1 < (_S533.y))
        {
        }
        else
        {
            break;
        }
        uint _S534 = 5U * term_1;
        uint _S535 = (as_type<uint4>((float4(*(kernelContext_24->loads_0+_S534)) ))).y;
        if(_S535 == 2U)
        {
            term_1 = term_1 + 1U;
            continue;
        }
        float4 _S536 = float4(*(kernelContext_24->loads_0+(_S534 + 1U))) ;
        float4 _S537 = float4(*(kernelContext_24->loads_0+(_S534 + 2U))) ;
        float _S538 = eval_function_0(term_1, _S525, _S526, 0.0f, kernelContext_24);
        float3 fw_0;
        if(_S535 == 0U)
        {
            fw_0 = _S536.xyz * float3(_S538) ;
        }
        else
        {
            float3 _S539 = rotate_0(_S524, _S536.xyz);
            fw_0 = _S539 * float3((- _S538 * _S536.w)) ;
        }
        *_S529 = *_S529 + fw_0;
        float3 _S540 = rotate_0(_S524, _S537.xyz);
        *_S530 = *_S530 + cross(_S540, fw_0);
        term_1 = term_1 + 1U;
    }
    bool _S541;
    if(_S527)
    {
        _S541 = ((uint4(_S531->cinfo_0) ).z) != 0U;
    }
    else
    {
        _S541 = false;
    }
    if(_S541)
    {
        uint4 _S542 = uint4(_S531->cinfo_0) ;
        uint e_1 = _S542.x;
        for(;;)
        {
            if(e_1 < (_S542.y))
            {
            }
            else
            {
                break;
            }
            uint entry_1 = kernelContext_24->index_0[e_1];
            if(entry_1 == 2147483648U)
            {
                ground_contact_0(_S522, _S528, _S529, _S530, kernelContext_24);
                e_1 = e_1 + 1U;
                continue;
            }
            uint _S543 = 2U * entry_1;
            *_S529 = *_S529 + (float4(*(kernelContext_24->scratch_0+(kernelContext_24->params_0->slot_base_0 + _S543))) ).xyz;
            *_S530 = *_S530 + (float4(*(kernelContext_24->scratch_0+(kernelContext_24->params_0->slot_base_0 + _S543 + 1U))) ).xyz;
            e_1 = e_1 + 1U;
        }
    }
    return;
}

void chunk_update_0(uint c_11, const Island_0 thread* isl_0, const Rigid_0 thread* rg_0, float dt_8, bool rml_0, uint step_0, bool contact_1, float thread* work_1, float thread* work_err_0, KernelContext_0 thread* kernelContext_25)
{
    ChunkStatic_natural_0 device* _S544 = kernelContext_25->chunks_0+c_11;
    float3 _S545 = float3(0.0f) ;
    uint _S546 = kernelContext_25->index_0[c_11];
    float peak_0 = 0.0f;
    uint e_2 = _S546;
    float3 fi_0 = _S545;
    float3 mi_0 = _S545;
    for(;;)
    {
        if(e_2 < (kernelContext_25->index_0)[c_11 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_2 = kernelContext_25->index_0[e_2];
        uint _S547 = 3U * (entry_2 >> 1U);
        float4 _S548 = float4(*(kernelContext_25->scratch_0+_S547)) ;
        if((entry_2 & 1U) == 0U)
        {
            float3 mi_1 = mi_0 + (float4(*(kernelContext_25->scratch_0+(_S547 + 1U))) ).xyz;
            fi_0 = fi_0 + _S548.xyz;
            mi_0 = mi_1;
        }
        else
        {
            float3 mi_2 = mi_0 + (float4(*(kernelContext_25->scratch_0+(_S547 + 2U))) ).xyz;
            fi_0 = fi_0 + - _S548.xyz;
            mi_0 = mi_2;
        }
        float _S549 = max(peak_0, _S548.w);
        uint _S550 = e_2 + 1U;
        peak_0 = _S549;
        e_2 = _S550;
    }
    uint _S551 = 4U * c_11;
    float3 u_0 = (float4(*(kernelContext_25->state_0+_S551)) ).xyz;
    uint _S552 = _S551 + 1U;
    float3 th_1 = (float4(*(kernelContext_25->state_0+_S552)) ).xyz;
    uint _S553 = _S551 + 2U;
    float3 v_9 = (float4(*(kernelContext_25->state_0+_S553)) ).xyz;
    uint _S554 = _S551 + 3U;
    float3 w_4 = (float4(*(kernelContext_25->state_0+_S554)) ).xyz;
    float4 _S555 = float4(_S544->center_0) ;
    float mass_0 = _S555.w;
    float3 _S556 = _S555.xyz;
    float3 _S557 = isl_0->com_0.xyz;
    float3 _S558 = rotate_0(&rg_0->rot_0, _S556 + u_0 - _S557);
    thread float3 f_load_0;
    thread float3 t_load_0;
    chunk_external_0(c_11, c_11, &rg_0->rot_0, step_0, dt_8, contact_1, true, &f_load_0, &t_load_0, kernelContext_25);
    float3 _S559 = float3(mass_0) ;
    float3 f_world_0 = f_load_0 + kernelContext_25->params_0->gravity_0.xyz * _S559;
    float3 t_world_0 = t_load_0;
    float3 f_world_1;
    float3 t_world_1;
    if(rml_0)
    {
        float3 f_world_2 = f_world_0 - (rg_0->a_10 + cross(rg_0->alpha_0, _S558) + cross(rg_0->w_3, cross(rg_0->w_3, _S558))) * _S559;
        float4 _S560 = float4(_S544->inertia0_1) ;
        float4 _S561 = float4(_S544->inertia1_1) ;
        float4 _S562 = float4(_S544->inertia2_1) ;
        float3 _S563 = world_mul_0(&rg_0->rot_0, _S560, _S561, _S562, rg_0->alpha_0);
        float3 _S564 = world_mul_0(&rg_0->rot_0, _S560, _S561, _S562, rg_0->w_3);
        float3 t_world_2 = t_world_0 - (_S563 + cross(rg_0->w_3, _S564));
        f_world_1 = f_world_2;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    float3 _S565 = inverse_rotate_0(&rg_0->rot_0, f_world_1);
    float3 _S566 = inverse_rotate_0(&rg_0->rot_0, t_world_1);
    float3 f_ext_0;
    float3 m_ext_0;
    if(rml_0)
    {
        float3 _S567 = inverse_rotate_0(&rg_0->rot_0, rg_0->w_3);
        float4 _S568 = float4(_S544->inertia0_1) ;
        float4 _S569 = float4(_S544->inertia1_1) ;
        float4 _S570 = float4(_S544->inertia2_1) ;
        float3 i_w_0 = rows_mul_0(_S568, _S569, _S570, w_4);
        float3 m_ext_1 = _S566 - (cross(_S567, i_w_0) + cross(w_4, rows_mul_0(_S568, _S569, _S570, _S567)) + cross(w_4, i_w_0));
        f_ext_0 = _S565 - cross(_S567, v_9) * float3((2.0f * mass_0)) ;
        m_ext_0 = m_ext_1;
    }
    else
    {
        f_ext_0 = _S565;
        m_ext_0 = _S566;
    }
    uint4 _S571 = uint4(_S544->load_range_0) ;
    uint term_2 = _S571.x;
    for(;;)
    {
        if(term_2 < (_S571.y))
        {
        }
        else
        {
            break;
        }
        uint _S572 = 5U * term_2;
        if(((as_type<uint4>((float4(*(kernelContext_25->loads_0+_S572)) ))).y) != 2U)
        {
            term_2 = term_2 + 1U;
            continue;
        }
        float _S573 = eval_function_0(term_2, step_0, dt_8, dt_8, kernelContext_25);
        float3 _S574 = float3(_S573) ;
        float3 m_ext_2 = m_ext_0 + (float4(*(kernelContext_25->loads_0+(_S572 + 2U))) ).xyz * _S574;
        f_ext_0 = f_ext_0 + (float4(*(kernelContext_25->loads_0+(_S572 + 1U))) ).xyz * _S574;
        m_ext_0 = m_ext_2;
        term_2 = term_2 + 1U;
    }
    float3 f_4 = f_ext_0 + fi_0;
    float3 m_5 = m_ext_0 + mi_0;
    uint support_0 = (uint4(_S544->info_1) ).x;
    float3 _S575 = float3((float4(*(kernelContext_25->state_0+_S552)) ).w, (float4(*(kernelContext_25->state_0+_S553)) ).w, (float4(*(kernelContext_25->state_0+_S554)) ).w);
    float3 reaction_0;
    float3 u_1;
    float3 th_2;
    float3 v_10;
    float3 w_5;
    if(support_0 == 1U)
    {
        reaction_0 = - f_4;
        u_1 = u_0;
        th_2 = th_1;
        v_10 = _S545;
        w_5 = _S545;
    }
    else
    {
        float4 _S576 = float4(_S544->scale_0) ;
        float3 w_6 = w_4 + rows_mul_0(float4(_S544->inv0_1) , float4(_S544->inv1_1) , float4(_S544->inv2_1) , m_5) * float3((dt_8 * _S576.z)) ;
        float3 _S577 = float3(dt_8) ;
        float3 th_3 = th_1 + w_6 * _S577;
        if(support_0 == 2U)
        {
            reaction_0 = - f_4;
            u_1 = u_0;
            th_2 = _S545;
        }
        else
        {
            float3 v_11 = v_9 + f_4 * float3((dt_8 * _S576.y)) ;
            float3 u_2 = u_0 + v_11 * _S577;
            reaction_0 = _S575;
            u_1 = u_2;
            th_2 = v_11;
        }
        float3 _S578 = th_2;
        th_2 = th_3;
        v_10 = _S578;
        w_5 = w_6;
    }
    *(kernelContext_25->state_0+_S551) = packed_float4(float4(u_1, peak_0)) ;
    *(kernelContext_25->state_0+_S552) = packed_float4(float4(th_2, reaction_0.x)) ;
    *(kernelContext_25->state_0+_S553) = packed_float4(float4(v_10, reaction_0.y)) ;
    *(kernelContext_25->state_0+_S554) = packed_float4(float4(w_5, reaction_0.z)) ;
    float3 _S579 = rotate_0(&rg_0->rot_0, _S556 + u_1 - _S557);
    float3 _S580 = rg_0->vel_1 + rg_0->vel_err_1 + cross(rg_0->w_3, _S579);
    float3 _S581 = rotate_0(&rg_0->rot_0, v_10);
    float3 v_world_0 = _S580 + _S581;
    float3 _S582 = rotate_0(&rg_0->rot_0, w_5);
    comp_add1_0(work_1, work_err_0, (dot(f_load_0, v_world_0) + dot(t_load_0, rg_0->w_3 + _S582)) * dt_8);
    return;
}

void write_probe_0(uint slot_1, uint k_14, float value_0, KernelContext_0 thread* kernelContext_26)
{
    uint at_4 = kernelContext_26->params_0->probe_base_0 * 4U + slot_1 * kernelContext_26->params_0->probe_stride_0 + k_14;
    thread float4 v_12 = float4(*(kernelContext_26->scratch_0+at_4 / 4U)) ;
    v_12[at_4 % 4U] = value_0;
    *(kernelContext_26->scratch_0+at_4 / 4U) = packed_float4(v_12) ;
    return;
}

void record_probes_0(const Island_0 thread* isl_1, const Rigid_0 thread* rg_1, uint k_15, KernelContext_0 thread* kernelContext_27)
{
    uint4 _S583 = isl_1->probes_0;
    uint at_5 = isl_1->probes_0.x;
    for(;;)
    {
        if(at_5 < (_S583.y))
        {
        }
        else
        {
            break;
        }
        uint4 info_3 = (as_type<uint4>((float4(*(kernelContext_27->loads_0+at_5)) )));
        float4 _S584 = float4(*(kernelContext_27->loads_0+(at_5 + 1U))) ;
        float4 _S585 = float4(*(kernelContext_27->loads_0+(at_5 + 2U))) ;
        float4 _S586 = float4(*(kernelContext_27->loads_0+(at_5 + 3U))) ;
        uint kind_4 = info_3.x;
        uint i_8 = info_3.y;
        float value_1;
        if(kind_4 == 0U)
        {
            float3 _S587 = rg_1->pos_1 - _S585.xyz + (rg_1->pos_err_1 - _S586.xyz);
            float3 _S588 = rotate_0(&rg_1->rot_0, (float4((kernelContext_27->chunks_0+i_8)->center_0) ).xyz + (float4(*(kernelContext_27->state_0+4U * i_8)) ).xyz);
            value_1 = dot(_S587 + _S588, _S584.xyz);
        }
        else
        {
            if(kind_4 == 1U)
            {
                uint _S589 = 4U * i_8;
                float3 _S590 = rotate_0(&rg_1->rot_0, (float4((kernelContext_27->chunks_0+i_8)->center_0) ).xyz + (float4(*(kernelContext_27->state_0+_S589)) ).xyz - isl_1->com_0.xyz);
                float3 _S591 = rg_1->vel_1 + rg_1->vel_err_1 + cross(rg_1->w_3, _S590);
                float3 _S592 = rotate_0(&rg_1->rot_0, (float4(*(kernelContext_27->state_0+(_S589 + 2U))) ).xyz);
                value_1 = dot(_S591 + _S592, _S584.xyz);
            }
            else
            {
                if(kind_4 == 2U)
                {
                    uint _S593 = 3U * i_8;
                    float3 f_5 = (float4(*(kernelContext_27->scratch_0+_S593)) ).xyz;
                    bool _S594 = (info_3.z) == 0U;
                    float3 mc_0;
                    if(_S594)
                    {
                        mc_0 = (float4(*(kernelContext_27->scratch_0+(_S593 + 1U))) ).xyz;
                    }
                    else
                    {
                        mc_0 = (float4(*(kernelContext_27->scratch_0+(_S593 + 2U))) ).xyz;
                    }
                    float3 fc_2;
                    if(_S594)
                    {
                        fc_2 = f_5;
                    }
                    else
                    {
                        fc_2 = - f_5;
                    }
                    value_1 = dot(fc_2, _S584.xyz) + dot(mc_0, _S585.xyz);
                }
                else
                {
                    uint _S595 = 4U * i_8;
                    float3 _S596 = rotate_0(&rg_1->rot_0, float3((float4(*(kernelContext_27->state_0+(_S595 + 1U))) ).w, (float4(*(kernelContext_27->state_0+(_S595 + 2U))) ).w, (float4(*(kernelContext_27->state_0+(_S595 + 3U))) ).w));
                    value_1 = dot(_S596, _S584.xyz);
                }
            }
        }
        write_probe_0(info_3.w, k_15, value_1, kernelContext_27);
        at_5 = at_5 + 4U;
    }
    return;
}

[[kernel]] void island_frame(uint3 group_2 [[threadgroup_position_in_grid]], uint3 thread_2 [[thread_position_in_threadgroup]], Params_0 constant* params_5 [[buffer(0)]], Island_natural_0 device* islands_5 [[buffer(9)]], uint device* index_5 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_5 [[buffer(3)]], packed_float4 device* state_7 [[buffer(6)]], packed_float4 device* scratch_5 [[buffer(8)]], packed_float4 device* contact_state_5 [[buffer(11)]], Impactor_natural_0 device* impactors_5 [[buffer(10)]], packed_float4 device* loads_5 [[buffer(5)]], BondStatic_natural_0 device* bonds_5 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_5 [[buffer(7)]], MaterialTable_0 constant* materials_5 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_28;
    (&kernelContext_28)->params_0 = params_5;
    (&kernelContext_28)->islands_0 = islands_5;
    (&kernelContext_28)->index_0 = index_5;
    (&kernelContext_28)->chunks_0 = chunks_5;
    (&kernelContext_28)->state_0 = state_7;
    (&kernelContext_28)->scratch_0 = scratch_5;
    (&kernelContext_28)->contact_state_0 = contact_state_5;
    (&kernelContext_28)->impactors_0 = impactors_5;
    (&kernelContext_28)->loads_0 = loads_5;
    (&kernelContext_28)->bonds_0 = bonds_5;
    (&kernelContext_28)->bond_dyn_0 = bond_dyn_5;
    (&kernelContext_28)->materials_0 = materials_5;
    threadgroup array<float4, int(256)> g_red_a_5;
    (&kernelContext_28)->g_red_a_0 = &g_red_a_5;
    threadgroup array<float4, int(256)> g_red_b_5;
    (&kernelContext_28)->g_red_b_0 = &g_red_b_5;
    threadgroup uint g_run_5;
    (&kernelContext_28)->g_run_0 = &g_run_5;
    threadgroup uint g_halt_5;
    (&kernelContext_28)->g_halt_0 = &g_halt_5;
    uint tid_4 = thread_2.x;
    uint _S597 = group_2.x;
    Island_natural_0 device* _S598 = islands_5+_S597;
    uint4 _S599 = uint4((*_S598).info_0) ;
    float4 _S600 = float4((*_S598).com_0) ;
    float4 _S601 = float4((*_S598).inertia0_0) ;
    float4 _S602 = float4((*_S598).inertia1_0) ;
    float4 _S603 = float4((*_S598).inertia2_0) ;
    float4 _S604 = float4((*_S598).inv0_0) ;
    float4 _S605 = float4((*_S598).inv1_0) ;
    float4 _S606 = float4((*_S598).inv2_0) ;
    float4 _S607 = float4((*_S598).wcom_0) ;
    float4 _S608 = float4((*_S598).winv0_0) ;
    float4 _S609 = float4((*_S598).winv1_0) ;
    float4 _S610 = float4((*_S598).winv2_0) ;
    float4 _S611 = float4((*_S598).rotation_0) ;
    float4 _S612 = float4((*_S598).position_0) ;
    float4 _S613 = float4((*_S598).position_err_0) ;
    float4 _S614 = float4((*_S598).velocity_0) ;
    float4 _S615 = float4((*_S598).velocity_err_0) ;
    float4 _S616 = float4((*_S598).angular_velocity_0) ;
    uint4 _S617 = uint4((*_S598).done_0) ;
    uint4 _S618 = uint4((*_S598).probes_0) ;
    float4 _S619 = float4((*_S598).energy_0) ;
    thread Island_0 isl_2;
    (&isl_2)->range_0 = uint4((*_S598).range_0) ;
    (&isl_2)->info_0 = _S599;
    (&isl_2)->com_0 = _S600;
    (&isl_2)->inertia0_0 = _S601;
    (&isl_2)->inertia1_0 = _S602;
    (&isl_2)->inertia2_0 = _S603;
    (&isl_2)->inv0_0 = _S604;
    (&isl_2)->inv1_0 = _S605;
    (&isl_2)->inv2_0 = _S606;
    (&isl_2)->wcom_0 = _S607;
    (&isl_2)->winv0_0 = _S608;
    (&isl_2)->winv1_0 = _S609;
    (&isl_2)->winv2_0 = _S610;
    (&isl_2)->rotation_0 = _S611;
    (&isl_2)->position_0 = _S612;
    (&isl_2)->position_err_0 = _S613;
    (&isl_2)->velocity_0 = _S614;
    (&isl_2)->velocity_err_0 = _S615;
    (&isl_2)->angular_velocity_0 = _S616;
    (&isl_2)->done_0 = _S617;
    (&isl_2)->probes_0 = _S618;
    (&isl_2)->energy_0 = _S619;
    bool driven_0 = (((&isl_2)->info_0.x) & 2U) != 0U;
    bool _S620 = !((((&isl_2)->info_0.x) & 1U) != 0U);
    bool _S621;
    if(_S620)
    {
        _S621 = !driven_0;
    }
    else
    {
        _S621 = false;
    }
    bool contact_island_0 = (((&isl_2)->info_0.x) & 4U) != 0U;
    bool _S622 = tid_4 == 0U;
    bool _S623;
    uint run_0;
    if(_S622)
    {
        Island_natural_0 device* _S624 = (&kernelContext_28)->islands_0+(&kernelContext_28)->params_0->halt_index_0;
        if(contact_island_0 != (((&kernelContext_28)->params_0->contact_mode_0) == 1U))
        {
            run_0 = 0U;
        }
        else
        {
            run_0 = 1U;
        }
        if(contact_island_0)
        {
            uint4 _S625 = uint4(_S624->info_0) ;
            if(((_S625.z) & 1U) != 0U)
            {
                _S623 = true;
            }
            else
            {
                uint _S626 = _S625.y;
                if(_S626 != 0U)
                {
                    _S623 = _S626 <= ((&isl_2)->info_0.w);
                }
                else
                {
                    _S623 = false;
                }
            }
        }
        else
        {
            _S623 = false;
        }
        if(_S623)
        {
            run_0 = 0U;
        }
        *(&kernelContext_28)->g_run_0 = run_0;
        *(&kernelContext_28)->g_halt_0 = 0U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    if((((&isl_2)->info_0.z) & 1U) != 0U)
    {
        _S623 = true;
    }
    else
    {
        _S623 = (*(&kernelContext_28)->g_run_0) == 0U;
    }
    if(_S623)
    {
        run_0 = 0U;
    }
    else
    {
        run_0 = min((&isl_2)->info_0.y, (&kernelContext_28)->params_0->max_steps_0);
    }
    float _S627 = (&kernelContext_28)->params_0->dt_0;
    bool _S628 = ((&kernelContext_28)->params_0->fracture_0) != 0U;
    bool _S629 = ((&kernelContext_28)->params_0->rigid_motion_loads_0) != 0U;
    float3 _S630 = (&kernelContext_28)->params_0->gravity_0.xyz;
    float _S631 = (&isl_2)->com_0.w;
    thread Rigid_0 rg_2;
    (&rg_2)->rot_0 = quat_of_0((&isl_2)->rotation_0);
    (&rg_2)->pos_1 = (&isl_2)->position_0.xyz;
    (&rg_2)->pos_err_1 = (&isl_2)->position_err_0.xyz;
    (&rg_2)->vel_1 = (&isl_2)->velocity_0.xyz;
    (&rg_2)->vel_err_1 = (&isl_2)->velocity_err_0.xyz;
    (&rg_2)->w_3 = (&isl_2)->angular_velocity_0.xyz;
    float3 _S632 = float3(0.0f) ;
    (&rg_2)->a_10 = _S632;
    (&rg_2)->alpha_0 = _S632;
    thread float work_2 = 0.0f;
    thread float work_err_1 = 0.0f;
    uint done_1 = 0U;
    for(;;)
    {
        if(done_1 < run_0)
        {
        }
        else
        {
            break;
        }
        uint abs_step_1 = (&isl_2)->info_0.w + done_1 + 1U;
        uint k_16 = abs_step_1 - 1U - (&kernelContext_28)->params_0->step_start_0;
        uint i_9;
        uint c_12;
        if(_S620)
        {
            thread float3 f_6 = _S632;
            thread float3 t_6 = _S632;
            i_9 = (&isl_2)->range_0.x + tid_4;
            for(;;)
            {
                if(i_9 < ((&isl_2)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                ChunkStatic_natural_0 device* _S633 = (&kernelContext_28)->chunks_0+i_9;
                thread Quat_0 _S634 = (&rg_2)->rot_0;
                thread float3 fl_0;
                thread float3 tl_0;
                chunk_external_0(i_9, i_9, &_S634, k_16, _S627, contact_island_0, false, &fl_0, &tl_0, &kernelContext_28);
                float4 _S635 = float4(_S633->center_0) ;
                float3 fc_3 = fl_0 + _S630 * float3(_S635.w) ;
                float3 _S636 = _S635.xyz;
                float3 _S637 = _S636 + (float4(*((&kernelContext_28)->state_0+4U * i_9)) ).xyz - (&isl_2)->com_0.xyz;
                thread Quat_0 _S638 = (&rg_2)->rot_0;
                float3 _S639 = rotate_0(&_S638, _S637);
                f_6 = f_6 + fc_3;
                t_6 = t_6 + (cross(_S639, fc_3) + tl_0);
                uint4 _S640 = uint4(_S633->load_range_0) ;
                c_12 = _S640.x;
                for(;;)
                {
                    if(c_12 < (_S640.y))
                    {
                    }
                    else
                    {
                        break;
                    }
                    uint _S641 = 5U * c_12;
                    if(((as_type<uint4>((float4(*((&kernelContext_28)->loads_0+_S641)) ))).y) != 2U)
                    {
                        c_12 = c_12 + 1U;
                        continue;
                    }
                    float _S642 = eval_function_0(c_12, k_16, _S627, 0.0f, &kernelContext_28);
                    float3 _S643 = float3(_S642) ;
                    float3 _S644 = (float4(*((&kernelContext_28)->loads_0+(_S641 + 1U))) ).xyz * _S643;
                    thread Quat_0 _S645 = (&rg_2)->rot_0;
                    float3 _S646 = rotate_0(&_S645, _S644);
                    f_6 = f_6 + _S646;
                    float3 _S647 = _S636 - (&isl_2)->com_0.xyz;
                    thread Quat_0 _S648 = (&rg_2)->rot_0;
                    float3 _S649 = rotate_0(&_S648, _S647);
                    float3 _S650 = cross(_S649, _S646);
                    float3 _S651 = (float4(*((&kernelContext_28)->loads_0+(_S641 + 2U))) ).xyz * _S643;
                    thread Quat_0 _S652 = (&rg_2)->rot_0;
                    float3 _S653 = rotate_0(&_S652, _S651);
                    t_6 = t_6 + (_S650 + _S653);
                    c_12 = c_12 + 1U;
                }
                i_9 = i_9 + 256U;
            }
            group_sum3_0(tid_4, &f_6, &t_6, &kernelContext_28);
            thread Quat_0 _S654 = (&rg_2)->rot_0;
            float3 _S655 = world_mul_0(&_S654, (&isl_2)->inertia0_0, (&isl_2)->inertia1_0, (&isl_2)->inertia2_0, (&rg_2)->w_3);
            (&rg_2)->a_10 = f_6 / float3(_S631) ;
            float3 _S656 = t_6 - cross((&rg_2)->w_3, _S655);
            thread Quat_0 _S657 = (&rg_2)->rot_0;
            float3 _S658 = world_mul_0(&_S657, (&isl_2)->inv0_0, (&isl_2)->inv1_0, (&isl_2)->inv2_0, _S656);
            (&rg_2)->alpha_0 = _S658;
        }
        i_9 = (&isl_2)->range_0.z + tid_4;
        for(;;)
        {
            if(i_9 < ((&isl_2)->range_0.w))
            {
            }
            else
            {
                break;
            }
            bond_update_0(i_9, _S627, _S628, abs_step_1, &kernelContext_28);
            i_9 = i_9 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        c_12 = (&isl_2)->range_0.x + tid_4;
        for(;;)
        {
            if(c_12 < ((&isl_2)->range_0.y))
            {
            }
            else
            {
                break;
            }
            thread Island_0 _S659 = isl_2;
            thread Rigid_0 _S660 = rg_2;
            chunk_update_0(c_12, &_S659, &_S660, _S627, _S629, k_16, contact_island_0, &work_2, &work_err_1, &kernelContext_28);
            c_12 = c_12 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        if(_S621)
        {
            thread Quat_0 _S661 = (&rg_2)->rot_0;
            float3 _S662 = world_mul_0(&_S661, (&isl_2)->inertia0_0, (&isl_2)->inertia1_0, (&isl_2)->inertia2_0, (&rg_2)->w_3);
            thread Quat_0 _S663 = (&rg_2)->rot_0;
            float3 _S664 = world_mul_0(&_S663, (&isl_2)->inertia0_0, (&isl_2)->inertia1_0, (&isl_2)->inertia2_0, (&rg_2)->alpha_0);
            float3 _S665 = float3(_S627) ;
            float3 l_2 = _S662 + (_S664 + cross((&rg_2)->w_3, _S662)) * _S665;
            comp_add_0(&(&rg_2)->vel_1, &(&rg_2)->vel_err_1, (&rg_2)->a_10 * _S665);
            float3 vel_2 = (&rg_2)->vel_1 + (&rg_2)->vel_err_1;
            thread Quat_0 _S666 = (&rg_2)->rot_0;
            float3 _S667 = world_mul_0(&_S666, (&isl_2)->inv0_0, (&isl_2)->inv1_0, (&isl_2)->inv2_0, l_2);
            thread Quat_0 _S668 = (&rg_2)->rot_0;
            Quat_0 _S669 = integrate_rotation_0(&_S668, _S667, _S627);
            float3 _S670 = vel_2 * _S665;
            float3 _S671 = (&isl_2)->com_0.xyz;
            thread Quat_0 _S672 = (&rg_2)->rot_0;
            float3 _S673 = rotate_0(&_S672, _S671);
            float3 _S674 = (&isl_2)->com_0.xyz;
            thread Quat_0 _S675 = _S669;
            float3 _S676 = rotate_0(&_S675, _S674);
            comp_add_0(&(&rg_2)->pos_1, &(&rg_2)->pos_err_1, _S670 + (_S673 - _S676));
            (&rg_2)->rot_0 = _S669;
            thread Quat_0 _S677 = _S669;
            float3 _S678 = world_mul_0(&_S677, (&isl_2)->inv0_0, (&isl_2)->inv1_0, (&isl_2)->inv2_0, l_2);
            (&rg_2)->w_3 = _S678;
        }
        if(_S620)
        {
            float3 wcom_1 = (&isl_2)->wcom_0.xyz;
            float wmass_0 = (&isl_2)->wcom_0.w;
            thread float3 tu_0 = _S632;
            thread float3 pv_0 = _S632;
            uint c_13 = (&isl_2)->range_0.x + tid_4;
            for(;;)
            {
                if(c_13 < ((&isl_2)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                ChunkStatic_natural_0 device* _S679 = (&kernelContext_28)->chunks_0+c_13;
                uint _S680 = 4U * c_13;
                float3 _S681 = float3(((float4(_S679->center_0) ).w * (float4(_S679->scale_0) ).x)) ;
                tu_0 = tu_0 + (float4(*((&kernelContext_28)->state_0+_S680)) ).xyz * _S681;
                pv_0 = pv_0 + (float4(*((&kernelContext_28)->state_0+(_S680 + 2U))) ).xyz * _S681;
                c_13 = c_13 + 256U;
            }
            group_sum3_0(tid_4, &tu_0, &pv_0, &kernelContext_28);
            float3 _S682 = float3(wmass_0) ;
            float3 tr_0 = tu_0 / _S682;
            float3 dv_0 = pv_0 / _S682;
            thread float3 lu_0 = _S632;
            thread float3 lv_0 = _S632;
            uint c_14 = (&isl_2)->range_0.x + tid_4;
            for(;;)
            {
                if(c_14 < ((&isl_2)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                ChunkStatic_natural_0 device* _S683 = (&kernelContext_28)->chunks_0+c_14;
                float4 _S684 = float4(_S683->center_0) ;
                float3 r_9 = _S684.xyz - wcom_1;
                uint _S685 = 4U * c_14;
                float3 _S686 = float3(_S684.w) ;
                float4 _S687 = float4(_S683->inertia0_1) ;
                float4 _S688 = float4(_S683->inertia1_1) ;
                float4 _S689 = float4(_S683->inertia2_1) ;
                float3 _S690 = float3((float4(_S683->scale_0) ).x) ;
                lu_0 = lu_0 + (cross(r_9, (float4(*((&kernelContext_28)->state_0+_S685)) ).xyz - tr_0) * _S686 + rows_mul_0(_S687, _S688, _S689, (float4(*((&kernelContext_28)->state_0+(_S685 + 1U))) ).xyz)) * _S690;
                lv_0 = lv_0 + (cross(r_9, (float4(*((&kernelContext_28)->state_0+(_S685 + 2U))) ).xyz - dv_0) * _S686 + rows_mul_0(_S687, _S688, _S689, (float4(*((&kernelContext_28)->state_0+(_S685 + 3U))) ).xyz)) * _S690;
                c_14 = c_14 + 256U;
            }
            group_sum3_0(tid_4, &lu_0, &lv_0, &kernelContext_28);
            float3 phi_0 = rows_mul_0((&isl_2)->winv0_0, (&isl_2)->winv1_0, (&isl_2)->winv2_0, lu_0);
            float3 dw_0 = rows_mul_0((&isl_2)->winv0_0, (&isl_2)->winv1_0, (&isl_2)->winv2_0, lv_0);
            uint c_15 = (&isl_2)->range_0.x + tid_4;
            for(;;)
            {
                if(c_15 < ((&isl_2)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                float3 r_10 = (float4(((&kernelContext_28)->chunks_0+c_15)->center_0) ).xyz - wcom_1;
                uint _S691 = 4U * c_15;
                *((&kernelContext_28)->state_0+_S691) = packed_float4(float4((float4(*((&kernelContext_28)->state_0+_S691)) ).xyz - (tr_0 + cross(phi_0, r_10)), (float4(*((&kernelContext_28)->state_0+_S691)) ).w)) ;
                uint _S692 = _S691 + 1U;
                *((&kernelContext_28)->state_0+_S692) = packed_float4(float4((float4(*((&kernelContext_28)->state_0+_S692)) ).xyz - phi_0, (float4(*((&kernelContext_28)->state_0+_S692)) ).w)) ;
                uint _S693 = _S691 + 2U;
                *((&kernelContext_28)->state_0+_S693) = packed_float4(float4((float4(*((&kernelContext_28)->state_0+_S693)) ).xyz - (dv_0 + cross(dw_0, r_10)), (float4(*((&kernelContext_28)->state_0+_S693)) ).w)) ;
                uint _S694 = _S691 + 3U;
                *((&kernelContext_28)->state_0+_S694) = packed_float4(float4((float4(*((&kernelContext_28)->state_0+_S694)) ).xyz - dw_0, (float4(*((&kernelContext_28)->state_0+_S694)) ).w)) ;
                c_15 = c_15 + 256U;
            }
            if(!driven_0)
            {
                Quat_0 rot_1 = (&rg_2)->rot_0;
                float3 _S695 = tr_0 - cross(phi_0, wcom_1);
                thread Quat_0 _S696 = (&rg_2)->rot_0;
                float3 _S697 = rotate_0(&_S696, _S695);
                comp_add_0(&(&rg_2)->pos_1, &(&rg_2)->pos_err_1, _S697);
                Quat_0 _S698 = from_axis_angle_0(phi_0, length(phi_0));
                thread Quat_0 _S699 = (&rg_2)->rot_0;
                thread Quat_0 _S700 = _S698;
                Quat_0 _S701 = quat_mul_0(&_S699, &_S700);
                thread Quat_0 _S702 = _S701;
                Quat_0 _S703 = normalized_0(&_S702);
                (&rg_2)->rot_0 = _S703;
                float3 _S704 = dv_0 + cross(dw_0, (&isl_2)->com_0.xyz - wcom_1);
                thread Quat_0 _S705 = rot_1;
                float3 _S706 = rotate_0(&_S705, _S704);
                comp_add_0(&(&rg_2)->vel_1, &(&rg_2)->vel_err_1, _S706);
                thread Quat_0 _S707 = rot_1;
                float3 _S708 = rotate_0(&_S707, dw_0);
                (&rg_2)->w_3 = (&rg_2)->w_3 + _S708;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        }
        if(_S622)
        {
            _S623 = ((&isl_2)->probes_0.y) > ((&isl_2)->probes_0.x);
        }
        else
        {
            _S623 = false;
        }
        if(_S623)
        {
            thread Island_0 _S709 = isl_2;
            thread Rigid_0 _S710 = rg_2;
            record_probes_0(&_S709, &_S710, k_16, &kernelContext_28);
        }
        uint _S711 = done_1 + 1U;
        if((*(&kernelContext_28)->g_halt_0) != 0U)
        {
            done_1 = _S711;
            break;
        }
        done_1 = _S711;
    }
    thread float3 wsum_0 = float3(work_2, work_err_1, 0.0f);
    thread float3 unused_2 = _S632;
    group_sum3_0(tid_4, &wsum_0, &unused_2, &kernelContext_28);
    if(_S622)
    {
        thread Quat_0 _S712 = (&rg_2)->rot_0;
        float4 _S713 = quat_vec_0(&_S712);
        (&isl_2)->rotation_0 = _S713;
        (&isl_2)->position_0 = float4((&rg_2)->pos_1, 0.0f);
        (&isl_2)->position_err_0 = float4((&rg_2)->pos_err_1, 0.0f);
        (&isl_2)->velocity_0 = float4((&rg_2)->vel_1, 0.0f);
        (&isl_2)->velocity_err_0 = float4((&rg_2)->vel_err_1, 0.0f);
        (&isl_2)->angular_velocity_0 = float4((&rg_2)->w_3, 0.0f);
        (&isl_2)->done_0.x = done_1;
        (&isl_2)->info_0.y = (&isl_2)->info_0.y - done_1;
        if((*(&kernelContext_28)->g_halt_0) != 0U)
        {
            _S621 = contact_island_0;
        }
        else
        {
            _S621 = false;
        }
        if(_S621)
        {
            uint at_6 = (&isl_2)->info_0.w + done_1;
            uint previous_1 = (uint4(((&kernelContext_28)->islands_0+(&kernelContext_28)->params_0->halt_index_0)->info_0) ).y;
            if(previous_1 == 0U)
            {
                run_0 = at_6;
            }
            else
            {
                run_0 = min(previous_1, at_6);
            }
            ((&kernelContext_28)->islands_0+(&kernelContext_28)->params_0->halt_index_0)->info_0[int(1)] = run_0;
        }
        float _S714 = wsum_0.x;
        thread float _S715 = (&isl_2)->energy_0.x;
        thread float _S716 = (&isl_2)->energy_0.y;
        comp_add1_0(&_S715, &_S716, _S714);
        (&isl_2)->energy_0.x = _S715;
        (&isl_2)->energy_0.y = _S716 + wsum_0.y;
        (&isl_2)->info_0.w = (&isl_2)->info_0.w + done_1;
        if((*(&kernelContext_28)->g_halt_0) != 0U)
        {
            (&isl_2)->info_0.z = ((&isl_2)->info_0.z) | 1U;
        }
        Island_natural_0 device* _S717 = (&kernelContext_28)->islands_0+_S597;
        _S717->range_0 = packed_uint4(isl_2.range_0) ;
        _S717->info_0 = packed_uint4(isl_2.info_0) ;
        _S717->com_0 = packed_float4(isl_2.com_0) ;
        _S717->inertia0_0 = packed_float4(isl_2.inertia0_0) ;
        _S717->inertia1_0 = packed_float4(isl_2.inertia1_0) ;
        _S717->inertia2_0 = packed_float4(isl_2.inertia2_0) ;
        _S717->inv0_0 = packed_float4(isl_2.inv0_0) ;
        _S717->inv1_0 = packed_float4(isl_2.inv1_0) ;
        _S717->inv2_0 = packed_float4(isl_2.inv2_0) ;
        _S717->wcom_0 = packed_float4(isl_2.wcom_0) ;
        _S717->winv0_0 = packed_float4(isl_2.winv0_0) ;
        _S717->winv1_0 = packed_float4(isl_2.winv1_0) ;
        _S717->winv2_0 = packed_float4(isl_2.winv2_0) ;
        _S717->rotation_0 = packed_float4(isl_2.rotation_0) ;
        _S717->position_0 = packed_float4(isl_2.position_0) ;
        _S717->position_err_0 = packed_float4(isl_2.position_err_0) ;
        _S717->velocity_0 = packed_float4(isl_2.velocity_0) ;
        _S717->velocity_err_0 = packed_float4(isl_2.velocity_err_0) ;
        _S717->angular_velocity_0 = packed_float4(isl_2.angular_velocity_0) ;
        _S717->done_0 = packed_uint4(isl_2.done_0) ;
        _S717->probes_0 = packed_uint4(isl_2.probes_0) ;
        _S717->energy_0 = packed_float4(isl_2.energy_0) ;
    }
    return;
}

