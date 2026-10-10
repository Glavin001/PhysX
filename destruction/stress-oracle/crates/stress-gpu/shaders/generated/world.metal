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
    uint wide_bond_groups_0;
    uint wide_bond_table_0;
    uint wide_chunk_table_0;
    uint wide_base_0;
    uint seg_index_0;
    uint seg_count_0;
    uint seg_base_0;
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
    uint threadgroup* g_wide_run_0;
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
    threadgroup uint g_wide_run_1;
    (&kernelContext_11)->g_wide_run_0 = &g_wide_run_1;
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
    threadgroup uint g_wide_run_2;
    (&kernelContext_12)->g_wide_run_0 = &g_wide_run_2;
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
    threadgroup uint g_wide_run_3;
    (&kernelContext_14)->g_wide_run_0 = &g_wide_run_3;
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
    threadgroup uint g_wide_run_4;
    (&kernelContext_15)->g_wide_run_0 = &g_wide_run_4;
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

void ground_contact_0(uint c_9, bool account_0, float3 thread* f_0, float3 thread* t_4, KernelContext_0 thread* kernelContext_16)
{
    ChunkStatic_natural_0 device* _S327 = kernelContext_16->chunks_0+c_9;
    WorldPoint_0 _S328 = chunk_world_0(c_9, kernelContext_16);
    float above_0 = _S328.hi_0.z - kernelContext_16->params_0->ground_hi_0 + (_S328.lo_0.z - kernelContext_16->params_0->ground_lo_0) + _S328.rel_0.z;
    if((above_0 - (float4(_S327->half_0) ).w) > 0.0f)
    {
        return;
    }
    Box_0 _S329 = chunk_box_0(c_9, float3(0.0f) , kernelContext_16);
    float _S330 = kernelContext_16->params_0->ground_modulus_0;
    float _S331 = (float4(_S327->cmat_0) ).x;
    float3 _S332 = float3(0.0f, 0.0f, 1.0f);
    thread Box_0 _S333 = _S329;
    thread Box_0 _S334 = _S329;
    float _S335 = contact_stiffness_0(_S330, &_S333, _S331, &_S334, _S332);
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
        thread Box_0 _S336 = _S329;
        float3 _S337 = sample_point_0(&_S336, s_5);
        if((above_0 + _S337.z) < 0.0f)
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
    chunk_velocity_0(c_9, &vc_1, &wc_1, kernelContext_16);
    thread float4 ledger_2 = float4(*(kernelContext_16->scratch_0+(kernelContext_16->params_0->ledger_base_0 + kernelContext_16->params_0->pair_count_0 + c_9))) ;
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
        thread Box_0 _S338 = _S329;
        float3 _S339 = sample_point_0(&_S338, s_5);
        float _S340 = above_0 + _S339.z;
        if(!(_S340 < 0.0f))
        {
            s_5 = s_5 + 1U;
            continue;
        }
        thread float stored_4;
        thread float diss_3;
        float3 _S341 = penalty_force_0(_S335 / float(max(n_9, 5U)), (float4(_S327->center_0) ).w, kernelContext_16->params_0->ground_friction_0, - _S340, _S332, vc_1 + cross(wc_1, _S339), kernelContext_16->params_0->dt_0, n_9, &stored_4, &diss_3, kernelContext_16);
        *f_0 = *f_0 + _S341;
        *t_4 = *t_4 + cross(_S339, _S341);
        thread float _S342 = ledger_2.y;
        thread float _S343 = ledger_2.z;
        comp_add1_0(&_S342, &_S343, diss_3);
        ledger_2.z = _S343;
        ledger_2.y = _S342;
        s_5 = s_5 + 1U;
    }
    if(account_0)
    {
        *(kernelContext_16->scratch_0+(kernelContext_16->params_0->ledger_base_0 + kernelContext_16->params_0->pair_count_0 + c_9)) = packed_float4(ledger_2) ;
    }
    return;
}

[[kernel]] void contact_sums(uint3 id_2 [[thread_position_in_grid]], Params_0 constant* params_5 [[buffer(0)]], Island_natural_0 device* islands_5 [[buffer(9)]], uint device* index_5 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_5 [[buffer(3)]], packed_float4 device* state_5 [[buffer(6)]], packed_float4 device* scratch_5 [[buffer(8)]], packed_float4 device* contact_state_5 [[buffer(11)]], Impactor_natural_0 device* impactors_5 [[buffer(10)]], packed_float4 device* loads_5 [[buffer(5)]], BondStatic_natural_0 device* bonds_5 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_5 [[buffer(7)]], MaterialTable_0 constant* materials_5 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_17;
    (&kernelContext_17)->params_0 = params_5;
    (&kernelContext_17)->islands_0 = islands_5;
    (&kernelContext_17)->index_0 = index_5;
    (&kernelContext_17)->chunks_0 = chunks_5;
    (&kernelContext_17)->state_0 = state_5;
    (&kernelContext_17)->scratch_0 = scratch_5;
    (&kernelContext_17)->contact_state_0 = contact_state_5;
    (&kernelContext_17)->impactors_0 = impactors_5;
    (&kernelContext_17)->loads_0 = loads_5;
    (&kernelContext_17)->bonds_0 = bonds_5;
    (&kernelContext_17)->bond_dyn_0 = bond_dyn_5;
    (&kernelContext_17)->materials_0 = materials_5;
    threadgroup array<float4, int(256)> g_red_a_5;
    (&kernelContext_17)->g_red_a_0 = &g_red_a_5;
    threadgroup array<float4, int(256)> g_red_b_5;
    (&kernelContext_17)->g_red_b_0 = &g_red_b_5;
    threadgroup uint g_run_5;
    (&kernelContext_17)->g_run_0 = &g_run_5;
    threadgroup uint g_halt_5;
    (&kernelContext_17)->g_halt_0 = &g_halt_5;
    threadgroup uint g_wide_run_5;
    (&kernelContext_17)->g_wide_run_0 = &g_wide_run_5;
    uint g_0 = id_2.x;
    bool _S344;
    if(g_0 >= (params_5->seg_count_0))
    {
        _S344 = true;
    }
    else
    {
        bool _S345 = stopped_0(&kernelContext_17);
        _S344 = _S345;
    }
    if(_S344)
    {
        return;
    }
    uint _S346 = 3U * g_0;
    uint _S347 = (&kernelContext_17)->index_0[(&kernelContext_17)->params_0->seg_index_0 + _S346];
    uint begin_0 = (&kernelContext_17)->index_0[(&kernelContext_17)->params_0->seg_index_0 + _S346 + 1U];
    uint _S348 = (&kernelContext_17)->index_0[(&kernelContext_17)->params_0->seg_index_0 + _S346 + 2U];
    float3 _S349 = float3(0.0f) ;
    thread float3 f_1 = _S349;
    thread float3 t_5 = _S349;
    uint e_1 = begin_0;
    for(;;)
    {
        if(e_1 < _S348)
        {
        }
        else
        {
            break;
        }
        uint entry_1 = (&kernelContext_17)->index_0[e_1];
        if(entry_1 == 2147483648U)
        {
            ground_contact_0(_S347, true, &f_1, &t_5, &kernelContext_17);
            e_1 = e_1 + 1U;
            continue;
        }
        uint _S350 = 2U * entry_1;
        f_1 = f_1 + (float4(*((&kernelContext_17)->scratch_0+((&kernelContext_17)->params_0->slot_base_0 + _S350))) ).xyz;
        t_5 = t_5 + (float4(*((&kernelContext_17)->scratch_0+((&kernelContext_17)->params_0->slot_base_0 + _S350 + 1U))) ).xyz;
        e_1 = e_1 + 1U;
    }
    uint _S351 = 2U * g_0;
    *((&kernelContext_17)->scratch_0+((&kernelContext_17)->params_0->seg_base_0 + _S351)) = packed_float4(float4(f_1, 0.0f)) ;
    *((&kernelContext_17)->scratch_0+((&kernelContext_17)->params_0->seg_base_0 + _S351 + 1U)) = packed_float4(float4(t_5, 0.0f)) ;
    return;
}

bool contact_stopped_0(const Island_natural_0 thread* isl_0, KernelContext_0 thread* kernelContext_18)
{
    uint4 _S352 = uint4((kernelContext_18->islands_0+kernelContext_18->params_0->halt_index_0)->info_0) ;
    bool _S353;
    if(((_S352.z) & 1U) != 0U)
    {
        _S353 = true;
    }
    else
    {
        uint _S354 = _S352.y;
        if(_S354 != 0U)
        {
            _S353 = _S354 <= ((uint4(isl_0->info_0) ).w);
        }
        else
        {
            _S353 = false;
        }
    }
    return _S353;
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

bool contact_stopped_1(const Island_0 thread* isl_1, KernelContext_0 thread* kernelContext_19)
{
    uint4 _S355 = uint4((kernelContext_19->islands_0+kernelContext_19->params_0->halt_index_0)->info_0) ;
    bool _S356;
    if(((_S355.z) & 1U) != 0U)
    {
        _S356 = true;
    }
    else
    {
        uint _S357 = _S355.y;
        if(_S357 != 0U)
        {
            _S356 = _S357 <= (isl_1->info_0.w);
        }
        else
        {
            _S356 = false;
        }
    }
    return _S356;
}

struct Rigid_0
{
    Quat_0 rot_0;
    float3 pos_1;
    float3 pos_err_1;
    float3 vel_1;
    float3 vel_err_1;
    float3 w_3;
    float3 a_6;
    float3 alpha_0;
};

Rigid_0 rigid_of_0(const Island_natural_0 thread* isl_2)
{
    thread Rigid_0 rg_0;
    (&rg_0)->rot_0 = quat_of_0(float4(isl_2->rotation_0) );
    (&rg_0)->pos_1 = (float4(isl_2->position_0) ).xyz;
    (&rg_0)->pos_err_1 = (float4(isl_2->position_err_0) ).xyz;
    (&rg_0)->vel_1 = (float4(isl_2->velocity_0) ).xyz;
    (&rg_0)->vel_err_1 = (float4(isl_2->velocity_err_0) ).xyz;
    (&rg_0)->w_3 = (float4(isl_2->angular_velocity_0) ).xyz;
    float3 _S358 = float3(0.0f) ;
    (&rg_0)->a_6 = _S358;
    (&rg_0)->alpha_0 = _S358;
    return rg_0;
}

Rigid_0 rigid_of_1(const Island_0 thread* isl_3)
{
    thread Rigid_0 rg_1;
    (&rg_1)->rot_0 = quat_of_0(isl_3->rotation_0);
    (&rg_1)->pos_1 = isl_3->position_0.xyz;
    (&rg_1)->pos_err_1 = isl_3->position_err_0.xyz;
    (&rg_1)->vel_1 = isl_3->velocity_0.xyz;
    (&rg_1)->vel_err_1 = isl_3->velocity_err_0.xyz;
    (&rg_1)->w_3 = isl_3->angular_velocity_0.xyz;
    float3 _S359 = float3(0.0f) ;
    (&rg_1)->a_6 = _S359;
    (&rg_1)->alpha_0 = _S359;
    return rg_1;
}

float time_since_0(float4 origin_0, uint k_10, float dt_4, KernelContext_0 thread* kernelContext_20)
{
    return kernelContext_20->params_0->t_hi_0 - origin_0.x + (kernelContext_20->params_0->t_lo_0 - origin_0.y) + float(k_10) * dt_4;
}

float table_eval_0(uint offset_0, uint count_2, float tau_0, KernelContext_0 thread* kernelContext_21)
{
    float4 _S360 = float4(*(kernelContext_21->loads_0+offset_0)) ;
    if(tau_0 <= (_S360.x))
    {
        return _S360.y;
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
        uint _S361 = offset_0 + i_4;
        float4 _S362 = float4(*(kernelContext_21->loads_0+_S361)) ;
        float _S363 = _S362.x;
        if(tau_0 <= _S363)
        {
            float4 _S364 = float4(*(kernelContext_21->loads_0+(_S361 - 1U))) ;
            float _S365 = _S364.x;
            float _S366 = _S364.y;
            return _S366 + (tau_0 - _S365) / max(_S363 - _S365, 1.00000000317107685e-30f) * (_S362.y - _S366);
        }
        i_4 = i_4 + 1U;
    }
    return (float4(*(kernelContext_21->loads_0+(offset_0 + count_2 - 1U))) ).y;
}

float eval_function_0(uint term_0, uint k_11, float dt_5, float shift_0, KernelContext_0 thread* kernelContext_22)
{
    uint _S367 = 5U * term_0;
    uint4 info_2 = (as_type<uint4>((float4(*(kernelContext_22->loads_0+_S367)) )));
    float4 _S368 = float4(*(kernelContext_22->loads_0+(_S367 + 3U))) ;
    float4 _S369 = float4(*(kernelContext_22->loads_0+(_S367 + 4U))) ;
    uint kind_0 = info_2.z;
    if(kind_0 == 0U)
    {
        return _S368.z;
    }
    float _S370 = time_since_0(_S368, k_11, dt_5, kernelContext_22);
    float tau_1 = _S370 + shift_0;
    float shape_1;
    if(kind_0 == 1U)
    {
        if(tau_1 <= 0.0f)
        {
            shape_1 = 0.0f;
        }
        else
        {
            float _S371 = _S369.x;
            if(tau_1 >= _S371)
            {
                shape_1 = _S369.y;
            }
            else
            {
                shape_1 = _S369.y * tau_1 / _S371;
            }
        }
        return shape_1;
    }
    bool _S372;
    if(kind_0 == 2U)
    {
        if(tau_1 < 0.0f)
        {
            _S372 = true;
        }
        else
        {
            _S372 = tau_1 > (_S369.x);
        }
        if(_S372)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S369.y * sin(3.14159274101257324f * tau_1 / _S369.x);
        }
        return shape_1;
    }
    if(kind_0 == 3U)
    {
        float sn_0 = tau_1 / _S369.y;
        if(sn_0 < 0.0f)
        {
            _S372 = true;
        }
        else
        {
            _S372 = sn_0 > 1.0f;
        }
        if(_S372)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S369.x * (1.0f - sn_0) * exp(- _S369.z * sn_0);
        }
        return shape_1;
    }
    if(kind_0 == 4U)
    {
        float _S373 = table_eval_0(info_2.w, (as_type<uint>((_S369.x))), tau_1, kernelContext_22);
        return _S373;
    }
    if(kind_0 == 5U)
    {
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float sn_1 = tau_1 / _S369.x;
        if(sn_1 < 0.0f)
        {
            _S372 = true;
        }
        else
        {
            _S372 = sn_1 > 1.0f;
        }
        if(_S372)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = (1.0f - sn_1) * exp(- _S369.y * sn_1);
        }
        float clearing_0 = _S368.w;
        float relax_0;
        if(clearing_0 > 0.0f)
        {
            relax_0 = max(1.0f - tau_1 / clearing_0, 0.0f);
        }
        else
        {
            relax_0 = 0.0f;
        }
        float _S374 = _S369.w;
        return (_S374 + (_S369.z - _S374) * relax_0) * shape_1;
    }
    float _S375 = _S369.x;
    if(_S375 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp(1.0f - tau_1 / _S375, 0.0f, 1.0f);
}

void chunk_external_0(uint _S376, uint _S377, const Quat_0 thread* _S378, uint _S379, float _S380, bool _S381, float3 thread* _S382, float3 thread* _S383, KernelContext_0 thread* kernelContext_23)
{
    ChunkStatic_natural_0 device* _S384 = kernelContext_23->chunks_0+_S377;
    float3 _S385 = float3(0.0f) ;
    *_S382 = _S385;
    *_S383 = _S385;
    uint4 _S386 = uint4(_S384->load_range_0) ;
    uint term_1 = _S386.x;
    for(;;)
    {
        if(term_1 < (_S386.y))
        {
        }
        else
        {
            break;
        }
        uint _S387 = 5U * term_1;
        uint _S388 = (as_type<uint4>((float4(*(kernelContext_23->loads_0+_S387)) ))).y;
        if(_S388 == 2U)
        {
            term_1 = term_1 + 1U;
            continue;
        }
        float4 _S389 = float4(*(kernelContext_23->loads_0+(_S387 + 1U))) ;
        float4 _S390 = float4(*(kernelContext_23->loads_0+(_S387 + 2U))) ;
        float _S391 = eval_function_0(term_1, _S379, _S380, 0.0f, kernelContext_23);
        float3 fw_0;
        if(_S388 == 0U)
        {
            fw_0 = _S389.xyz * float3(_S391) ;
        }
        else
        {
            float3 _S392 = rotate_0(_S378, _S389.xyz);
            fw_0 = _S392 * float3((- _S391 * _S389.w)) ;
        }
        *_S382 = *_S382 + fw_0;
        float3 _S393 = rotate_0(_S378, _S390.xyz);
        *_S383 = *_S383 + cross(_S393, fw_0);
        term_1 = term_1 + 1U;
    }
    bool _S394;
    if(_S381)
    {
        _S394 = ((uint4(_S384->cinfo_0) ).z) != 0U;
    }
    else
    {
        _S394 = false;
    }
    if(_S394)
    {
        uint4 _S395 = uint4(_S384->cinfo_0) ;
        uint g_1 = _S395.x;
        for(;;)
        {
            if(g_1 < (_S395.y))
            {
            }
            else
            {
                break;
            }
            uint _S396 = 2U * g_1;
            *_S382 = *_S382 + (float4(*(kernelContext_23->scratch_0+(kernelContext_23->params_0->seg_base_0 + _S396))) ).xyz;
            *_S383 = *_S383 + (float4(*(kernelContext_23->scratch_0+(kernelContext_23->params_0->seg_base_0 + _S396 + 1U))) ).xyz;
            g_1 = g_1 + 1U;
        }
    }
    return;
}

void net_load_0(uint c_10, const Island_natural_0 thread* isl_4, const Rigid_0 thread* rg_2, uint k_12, float dt_6, bool contact_0, float3 thread* f_2, float3 thread* t_6, KernelContext_0 thread* kernelContext_24)
{
    ChunkStatic_natural_0 device* _S397 = kernelContext_24->chunks_0+c_10;
    thread float3 fl_0;
    thread float3 tl_0;
    chunk_external_0(c_10, c_10, &rg_2->rot_0, k_12, dt_6, contact_0, &fl_0, &tl_0, kernelContext_24);
    float4 _S398 = float4(_S397->center_0) ;
    float3 fc_0 = fl_0 + kernelContext_24->params_0->gravity_0.xyz * float3(_S398.w) ;
    float3 _S399 = _S398.xyz;
    float3 _S400 = (float4(isl_4->com_0) ).xyz;
    float3 _S401 = rotate_0(&rg_2->rot_0, _S399 + (float4(*(kernelContext_24->state_0+4U * c_10)) ).xyz - _S400);
    *f_2 = *f_2 + fc_0;
    *t_6 = *t_6 + (cross(_S401, fc_0) + tl_0);
    uint4 _S402 = uint4(_S397->load_range_0) ;
    uint term_2 = _S402.x;
    for(;;)
    {
        if(term_2 < (_S402.y))
        {
        }
        else
        {
            break;
        }
        uint _S403 = 5U * term_2;
        if(((as_type<uint4>((float4(*(kernelContext_24->loads_0+_S403)) ))).y) != 2U)
        {
            term_2 = term_2 + 1U;
            continue;
        }
        float _S404 = eval_function_0(term_2, k_12, dt_6, 0.0f, kernelContext_24);
        float3 _S405 = float3(_S404) ;
        float3 _S406 = rotate_0(&rg_2->rot_0, (float4(*(kernelContext_24->loads_0+(_S403 + 1U))) ).xyz * _S405);
        *f_2 = *f_2 + _S406;
        float3 _S407 = rotate_0(&rg_2->rot_0, _S399 - _S400);
        float3 _S408 = cross(_S407, _S406);
        float3 _S409 = rotate_0(&rg_2->rot_0, (float4(*(kernelContext_24->loads_0+(_S403 + 2U))) ).xyz * _S405);
        *t_6 = *t_6 + (_S408 + _S409);
        term_2 = term_2 + 1U;
    }
    return;
}

void net_load_1(uint c_11, const Island_0 thread* isl_5, const Rigid_0 thread* rg_3, uint k_13, float dt_7, bool contact_1, float3 thread* f_3, float3 thread* t_7, KernelContext_0 thread* kernelContext_25)
{
    ChunkStatic_natural_0 device* _S410 = kernelContext_25->chunks_0+c_11;
    thread float3 fl_1;
    thread float3 tl_1;
    chunk_external_0(c_11, c_11, &rg_3->rot_0, k_13, dt_7, contact_1, &fl_1, &tl_1, kernelContext_25);
    float4 _S411 = float4(_S410->center_0) ;
    float3 fc_1 = fl_1 + kernelContext_25->params_0->gravity_0.xyz * float3(_S411.w) ;
    float3 _S412 = _S411.xyz;
    float3 _S413 = isl_5->com_0.xyz;
    float3 _S414 = rotate_0(&rg_3->rot_0, _S412 + (float4(*(kernelContext_25->state_0+4U * c_11)) ).xyz - _S413);
    *f_3 = *f_3 + fc_1;
    *t_7 = *t_7 + (cross(_S414, fc_1) + tl_1);
    uint4 _S415 = uint4(_S410->load_range_0) ;
    uint term_3 = _S415.x;
    for(;;)
    {
        if(term_3 < (_S415.y))
        {
        }
        else
        {
            break;
        }
        uint _S416 = 5U * term_3;
        if(((as_type<uint4>((float4(*(kernelContext_25->loads_0+_S416)) ))).y) != 2U)
        {
            term_3 = term_3 + 1U;
            continue;
        }
        float _S417 = eval_function_0(term_3, k_13, dt_7, 0.0f, kernelContext_25);
        float3 _S418 = float3(_S417) ;
        float3 _S419 = rotate_0(&rg_3->rot_0, (float4(*(kernelContext_25->loads_0+(_S416 + 1U))) ).xyz * _S418);
        *f_3 = *f_3 + _S419;
        float3 _S420 = rotate_0(&rg_3->rot_0, _S412 - _S413);
        float3 _S421 = cross(_S420, _S419);
        float3 _S422 = rotate_0(&rg_3->rot_0, (float4(*(kernelContext_25->loads_0+(_S416 + 2U))) ).xyz * _S418);
        *t_7 = *t_7 + (_S421 + _S422);
        term_3 = term_3 + 1U;
    }
    return;
}

void group_sum3_0(uint tid_3, float3 thread* a_7, float3 thread* b_12, KernelContext_0 thread* kernelContext_26)
{
    thread float4 x_3 = float4(*a_7, 0.0f);
    thread float4 y_1 = float4(*b_12, 0.0f);
    group_sum2_0(tid_3, &x_3, &y_1, kernelContext_26);
    *a_7 = x_3.xyz;
    *b_12 = y_1.xyz;
    return;
}

void rigid_acceleration_0(const Island_natural_0 thread* isl_6, Rigid_0 thread* rg_4, float3 f_4, float3 t_8)
{
    float4 _S423 = float4(isl_6->inertia0_0) ;
    float4 _S424 = float4(isl_6->inertia1_0) ;
    float4 _S425 = float4(isl_6->inertia2_0) ;
    thread Quat_0 _S426 = rg_4->rot_0;
    float3 _S427 = world_mul_0(&_S426, _S423, _S424, _S425, rg_4->w_3);
    rg_4->a_6 = f_4 / float3((float4(isl_6->com_0) ).w) ;
    float4 _S428 = float4(isl_6->inv0_0) ;
    float4 _S429 = float4(isl_6->inv1_0) ;
    float4 _S430 = float4(isl_6->inv2_0) ;
    float3 _S431 = t_8 - cross(rg_4->w_3, _S427);
    thread Quat_0 _S432 = rg_4->rot_0;
    float3 _S433 = world_mul_0(&_S432, _S428, _S429, _S430, _S431);
    rg_4->alpha_0 = _S433;
    return;
}

void rigid_acceleration_1(const Island_0 thread* isl_7, Rigid_0 thread* rg_5, float3 f_5, float3 t_9)
{
    thread Quat_0 _S434 = rg_5->rot_0;
    float3 _S435 = world_mul_0(&_S434, isl_7->inertia0_0, isl_7->inertia1_0, isl_7->inertia2_0, rg_5->w_3);
    rg_5->a_6 = f_5 / float3(isl_7->com_0.w) ;
    float3 _S436 = t_9 - cross(rg_5->w_3, _S435);
    thread Quat_0 _S437 = rg_5->rot_0;
    float3 _S438 = world_mul_0(&_S437, isl_7->inv0_0, isl_7->inv1_0, isl_7->inv2_0, _S436);
    rg_5->alpha_0 = _S438;
    return;
}

bool connected_0(const JointState_0 thread* st_0, bool has_rebar_0)
{
    bool _S439;
    if((st_0->damage_0) < 1.0f)
    {
        _S439 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S439 = (st_0->rebar_broken_0) == 0.0f;
        }
        else
        {
            _S439 = false;
        }
    }
    return _S439;
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
    float4 _S440 = float4(b_13->geom0_0) ;
    float area_2 = _S440.x;
    float _S441 = q_lin_0.z;
    float axial_0 = _S441 / area_2;
    float4 _S442 = float4(b_13->geom1_0) ;
    float bending_0 = abs(q_ang_0.x) / _S442.x + abs(q_ang_0.y) / _S442.y;
    float _S443 = q_lin_0.x;
    float _S444 = q_lin_0.y;
    float shear_1 = sqrt(_S443 * _S443 + _S444 * _S444) / area_2 + abs(q_ang_0.z) / _S440.w;
    thread Measures_0 m_3;
    (&m_3)->tension_0 = axial_0 + bending_0;
    (&m_3)->shear_0 = shear_1;
    float _S445 = - axial_0;
    (&m_3)->normal_compression_0 = max(_S445, 0.0f);
    (&m_3)->compression_0 = _S445 + bending_0;
    (&m_3)->compressive_force_0 = max(- _S441, 0.0f);
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
    float4 _S446 = mat_1->dif_0;
    float ref_0 = mat_1->dif_0.x;
    if(r_5 <= ref_0)
    {
        return 1.0f;
    }
    float _S447 = _S446.z;
    float f_6;
    if(r_5 <= _S447)
    {
        f_6 = pow(r_5 / ref_0, _S446.y);
    }
    else
    {
        f_6 = pow(_S447 / ref_0, _S446.y) * pow(r_5 / _S447, _S446.w);
    }
    return clamp(f_6, 1.0f, mat_1->misc_0.x);
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
    float fc_2 = mat_3->strength_0.y * multiplier_0;
    float _S448 = min(mat_3->strength_0.z * multiplier_0 + mat_3->strength_0.w * m_4->normal_compression_0, mat_3->energy_1.x * multiplier_0);
    thread float4 idx_1;
    idx_1.x = max(m_4->tension_0 / (mat_3->strength_0.x * multiplier_0), 0.0f);
    float _S449;
    if(_S448 > 0.0f)
    {
        _S449 = m_4->shear_0 / _S448;
    }
    else
    {
        _S449 = infinity_0();
    }
    idx_1.y = _S449;
    idx_1.z = max(m_4->compression_0 / fc_2, 0.0f);
    float _S450 = (float4(b_14->stiff1_0) ).y;
    if(_S450 > 0.0f)
    {
        _S449 = m_4->compressive_force_0 / _S450;
    }
    else
    {
        _S449 = 0.0f;
    }
    idx_1.w = _S449;
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
    float _S451 = max(damage_law_0(kind_2, lambda_0, r_7), d_old_0);
    bool _S452;
    if(_S451 <= d_old_0)
    {
        _S452 = true;
    }
    else
    {
        _S452 = d_old_0 >= 1.0f;
    }
    if(_S452)
    {
        return float2(d_old_0, 0.0f);
    }
    float u0_0 = psi_0 / (lambda_0 * lambda_0);
    float _S453 = max(kappa_old_0, 1.0f);
    if(kind_2 == 0U)
    {
        if(r_7 > 1.0f)
        {
            return float2(_S451, u0_0 * r_7 / (r_7 - 1.0f) * max(min(lambda_0, r_7) - min(_S453, r_7), 0.0f));
        }
        return float2(_S451, (1.0f - d_old_0) * psi_0);
    }
    float ku_0 = 0.5f * (r_7 + 1.0f);
    float plateau_0 = u0_0 * max(min(lambda_0, ku_0) - min(_S453, ku_0), 0.0f);
    float snap_0;
    if(_S451 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return float2(_S451, plateau_0 + snap_0);
}

void compressed_region_0(float w0_0, float w1_0, float dz_0, float ax_0, float ay_0, array<float, int(6)> thread* region_0)
{
    uint count_3;
    float h0_0 = 0.5f * w0_0;
    float h1_0 = 0.5f * w1_0;
    float _S454 = - h0_0;
    float _S455 = - h1_0;
    array<float2, int(4)> _S456 = { { float2(_S454, _S455), float2(h0_0, _S455), float2(h0_0, h1_0), float2(_S454, h1_0) } };
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
        uint _S457 = i_5;
        uint _S458 = i_5 + 1U;
        uint _S459 = _S458 % 4U;
        float _S460 = _S456[i_5].y;
        float _S461 = _S456[i_5].x;
        float fp_0 = dz_0 + ax_0 * _S460 - ay_0 * _S461;
        float _S462 = _S456[_S459].y;
        float _S463 = _S456[_S459].x;
        float fq_0 = dz_0 + ax_0 * _S462 - ay_0 * _S463;
        bool _S464 = fp_0 < 0.0f;
        if(_S464)
        {
            uint _S465 = count_4 + 1U;
            poly_0[count_4] = _S456[_S457];
            count_3 = _S465;
        }
        else
        {
            count_3 = count_4;
        }
        if(_S464 != (fq_0 < 0.0f))
        {
            float t_10 = fp_0 / (fp_0 - fq_0);
            uint _S466 = count_3 + 1U;
            poly_0[count_3] = float2(_S461 + t_10 * (_S463 - _S461), _S460 + t_10 * (_S462 - _S460));
            count_4 = _S466;
        }
        else
        {
            count_4 = count_3;
        }
        i_5 = _S458;
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
    float a_8 = 0.0f;
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
        float _S467 = o_1.x;
        float x0_0 = poly_0[i_5].x - _S467;
        float _S468 = o_1.y;
        float y0_0 = poly_0[i_5].y - _S468;
        uint _S469 = i_5 + 1U;
        uint _S470 = _S469 % count_4;
        float x1_0 = poly_0[_S470].x - _S467;
        float y1_0 = poly_0[_S470].y - _S468;
        float _S471 = x0_0 * y1_0;
        float _S472 = x1_0 * y0_0;
        float cr_0 = _S471 - _S472;
        float a_9 = a_8 + cr_0 / 2.0f;
        float sx_1 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        float sy_1 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        float ixx_1 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        float iyy_1 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        float ixy_1 = ixy_0 + (_S471 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S472) * cr_0 / 24.0f;
        i_5 = _S469;
        a_8 = a_9;
        sx_0 = sx_1;
        sy_0 = sy_1;
        ixx_0 = ixx_1;
        iyy_0 = iyy_1;
        ixy_0 = ixy_1;
    }
    if(a_8 <= 0.0f)
    {
        return;
    }
    float cx_0 = sx_0 / a_8;
    float cy_0 = sy_0 / a_8;
    (*region_0)[int(0)] = a_8;
    (*region_0)[int(1)] = o_1.x + cx_0;
    (*region_0)[int(2)] = o_1.y + cy_0;
    float _S473 = a_8 * cx_0;
    (*region_0)[int(3)] = ixx_0 - _S473 * cx_0;
    (*region_0)[int(4)] = iyy_0 - a_8 * cy_0 * cy_0;
    (*region_0)[int(5)] = ixy_0 - _S473 * cy_0;
    return;
}

float4 no_tension_patch_0(float kn_0, float w0_1, float w1_1, float dz_1, float ax_1, float ay_1)
{
    thread array<float, int(6)> r_8;
    compressed_region_0(w0_1, w1_1, dz_1, ax_1, ay_1, &r_8);
    float a_10 = r_8[int(0)];
    if((r_8[int(0)]) == 0.0f)
    {
        return float4(0.0f) ;
    }
    float k_14 = kn_0 / (w0_1 * w1_1);
    float fc_3 = dz_1 + ax_1 * r_8[int(2)] - ay_1 * r_8[int(1)];
    float _S474 = a_10 * fc_3;
    float _S475 = - ay_1;
    return float4(k_14 * a_10 * fc_3, k_14 * (_S474 * r_8[int(2)] + (_S475 * r_8[int(5)] + ax_1 * r_8[int(4)])), - k_14 * (_S474 * r_8[int(1)] + (_S475 * r_8[int(3)] + ax_1 * r_8[int(5)])), 0.5f * k_14 * (_S474 * fc_3 + ay_1 * ay_1 * r_8[int(3)] + ax_1 * ax_1 * r_8[int(4)] - 2.0f * ax_1 * ay_1 * r_8[int(5)]));
}

float signum_0(float x_6)
{
    float _S476;
    if(((as_type<uint>((x_6))) & 2147483648U) != 0U)
    {
        _S476 = -1.0f;
    }
    else
    {
        _S476 = 1.0f;
    }
    return _S476;
}

float2 return_map_0(float k_15, float total_3, float plastic_0, float cap_0)
{
    float trial_0 = k_15 * (total_3 - plastic_0);
    if((abs(trial_0)) <= cap_0)
    {
        return float2(trial_0, 0.0f);
    }
    float f_7 = cap_0 * signum_0(trial_0);
    return float2(f_7, (trial_0 - f_7) / k_15);
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
    thread Contact_0 c_12;
    float3 _S477 = float3(0.0f) ;
    (&c_12)->q_lin_1 = _S477;
    (&c_12)->q_ang_1 = _S477;
    (&c_12)->energy_2 = 0.0f;
    (&c_12)->diss_4 = 0.0f;
    (&c_12)->plastic_1 = plastic_2;
    uint _S478 = mat_4->kind_flags_0.y;
    if((_S478 & 2U) == 0U)
    {
        return c_12;
    }
    float4 _S479 = float4(b_15->stiff0_0) ;
    float kn_1 = _S479.x;
    float ks_0 = _S479.y;
    float kt_0 = (float4(b_15->stiff1_0) ).x;
    float4 _S480 = float4(b_15->geom0_0) ;
    float w0_2 = _S480.y;
    float w1_2 = _S480.z;
    float diss_5;
    float nc_sum_0;
    float m1_0;
    float m2_0;
    float energy_3;
    if((_S478 & 4U) != 0U)
    {
        float4 p_4 = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        float _S481 = p_4.y;
        float _S482 = p_4.z;
        float _S483 = p_4.w;
        nc_sum_0 = p_4.x;
        m1_0 = _S481;
        m2_0 = _S482;
        energy_3 = _S483;
    }
    else
    {
        float ki_0 = kn_1 * (1.0f - crush_2) / 36.0f;
        float _S484 = d_ang_0.x;
        float _S485 = d_ang_0.y;
        float spread_0 = abs(_S484) * 0.4166666567325592f * w1_2 + abs(_S485) * 0.4166666567325592f * w0_2;
        float _S486 = d_lin_0.z;
        float slack_0 = 9.99999997475242708e-07f * (abs(_S486) + spread_0);
        if((_S486 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S486 + spread_0) < (- slack_0))
            {
                float i1_0 = 2.91666650772094727f * w0_2 * w0_2;
                float i2_0 = 2.91666650772094727f * w1_2 * w1_2;
                float _S487 = ki_0 * _S484 * i2_0;
                float _S488 = ki_0 * _S485 * i1_0;
                float _S489 = 0.5f * ki_0 * (36.0f * _S486 * _S486 + _S484 * _S484 * i2_0 + _S485 * _S485 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S486;
                m1_0 = _S487;
                m2_0 = _S488;
                energy_3 = _S489;
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
                    float _S490 = ((float(i_6) + 0.5f) / 6.0f - 0.5f) * w0_2;
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
                        float di_0 = _S486 + _S484 * s2_0 - _S485 * _S490;
                        if(di_0 < 0.0f)
                        {
                            float f_8 = ki_0 * di_0;
                            float m1_2 = m1_0 + f_8 * s2_0;
                            float m2_2 = m2_0 - f_8 * _S490;
                            float energy_5 = energy_3 + 0.5f * ki_0 * di_0 * di_0;
                            nc_sum_0 = nc_sum_0 + f_8;
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
    (&c_12)->q_lin_1 = float3(0.0f, 0.0f, nc_sum_0);
    (&c_12)->q_ang_1 = float3(m1_0, m2_0, 0.0f);
    float slide_cap_0 = mat_4->strength_0.w * nc_0;
    float _S491 = ks_0 * (d_lin_0.x - plastic_2.x);
    float _S492 = ks_0 * (d_lin_0.y - plastic_2.y);
    float2 trial_1 = float2(_S491, _S492);
    float tn_0 = sqrt(_S491 * _S491 + _S492 * _S492);
    bool _S493;
    if(tn_0 > slide_cap_0)
    {
        _S493 = tn_0 > 0.0f;
    }
    else
    {
        _S493 = false;
    }
    if(_S493)
    {
        float2 dir_1 = trial_1 / float2(tn_0) ;
        float dslip_0 = (tn_0 - slide_cap_0) / ks_0;
        float _S494 = dir_1.x;
        p_5.x = p_5.x + _S494 * dslip_0;
        float _S495 = dir_1.y;
        p_5.y = p_5.y + _S495 * dslip_0;
        (&c_12)->q_lin_1.x = _S494 * slide_cap_0;
        (&c_12)->q_lin_1.y = _S495 * slide_cap_0;
        diss_5 = slide_cap_0 * dslip_0;
    }
    else
    {
        (&c_12)->q_lin_1.x = _S491;
        (&c_12)->q_lin_1.y = _S492;
        diss_5 = 0.0f;
    }
    float2 tq_0 = return_map_0(kt_0, d_ang_0.z, p_5.z, slide_cap_0 * (float4(b_15->geom1_0) ).z);
    float _S496 = tq_0.x;
    float _S497 = tq_0.y;
    float diss_6 = diss_5 + abs(_S496) * abs(_S497);
    p_5.z = p_5.z + _S497;
    (&c_12)->q_ang_1.z = _S496;
    (&c_12)->energy_2 = energy_3 + 0.5f * (sq_0((&c_12)->q_lin_1.x) / ks_0 + sq_0((&c_12)->q_lin_1.y) / ks_0 + sq_0(_S496) / kt_0);
    (&c_12)->diss_4 = diss_6;
    (&c_12)->plastic_1 = p_5;
    return c_12;
}

float life_rate_0(const JointMaterial_0 constant* mat_5, float s_6)
{
    if(s_6 <= 0.0f)
    {
        return 0.0f;
    }
    float _S498 = mat_5->misc_0.y;
    return (_S498 + 1.0f) * pow(s_6, _S498) / mat_5->misc_0.z;
}

struct JointResponse_0
{
    float3 force_lin_1;
    float3 force_ang_1;
    JointState_0 state_6;
    float dissipated_2;
    float overshoot_0;
    float stored_5;
    bool disconnected_0;
    Measures_0 measures_0;
};

JointResponse_0 joint_evaluate_0(const JointMaterial_0 constant* mat_6, const JointBond_natural_0 thread* b_16, const JointState_0 thread* state_7, float3 d_lin_1, float3 d_ang_1, float dt_8, bool fracture_1)
{
    float4 _S499 = float4(b_16->stiff0_0) ;
    float kn_2 = _S499.x;
    float ks_1 = _S499.y;
    float kb1_0 = _S499.z;
    float kb2_0 = _S499.w;
    float4 _S500 = float4(b_16->stiff1_0) ;
    float kt_1 = _S500.x;
    bool has_rebar_1 = (_S500.w) != 0.0f;
    uint kind_3 = mat_6->kind_flags_0.x;
    uint flags_1 = mat_6->kind_flags_0.y;
    bool softening_0 = (flags_1 & 1U) != 0U;
    thread JointState_0 st_1 = *state_7;
    bool _S501 = connected_0(state_7, has_rebar_1);
    float3 qe_lin_0 = d_lin_1 * float3(ks_1, ks_1, kn_2);
    float3 qe_ang_0 = d_ang_1 * float3(kb1_0, kb2_0, kt_1);
    Measures_0 _S502 = stress_measures_0(b_16, qe_lin_0, qe_ang_0);
    float _S503 = max(max(_S502.tension_0, _S502.shear_0), _S502.compression_0);
    bool _S504 = dt_8 > 0.0f;
    float dif_1;
    if(_S504)
    {
        float raw_0 = max((_S503 - (&st_1)->governing_stress_0) / dt_8, 0.0f) / mat_6->misc_0.w;
        float tau_2 = _S500.z;
        if((flags_1 & 16U) != 0U)
        {
            dif_1 = - expm1_accurate_0(- dt_8 / tau_2);
        }
        else
        {
            dif_1 = min(dt_8 / tau_2, 1.0f);
        }
        (&st_1)->strain_rate_0 = (&st_1)->strain_rate_0 + (raw_0 - (&st_1)->strain_rate_0) * dif_1;
        (&st_1)->governing_stress_0 = _S503;
    }
    if((flags_1 & 32U) != 0U)
    {
        float _S505 = dif_factor_0(mat_6, (&st_1)->strain_rate_0);
        dif_1 = _S505;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = (float4(b_16->geom1_0) ).w;
    float _S506 = weibull_0 * dif_1;
    float _S507 = fatigue_factor_0(mat_6, (&st_1)->fatigue_0);
    float multiplier_1 = _S506 * _S507;
    thread Measures_0 _S508 = _S502;
    float4 _S509 = failure_indices_0(mat_6, b_16, &_S508, multiplier_1);
    float _S510 = _S509.x;
    float _S511 = _S509.y;
    (&st_1)->utilization_0 = max(max(_S510, _S511), max(_S509.z, _S509.w));
    float _S512 = d_lin_1.x;
    float _S513 = d_lin_1.y;
    float _S514 = ks_1 * (sq_0(_S512) + sq_0(_S513)) + kb1_0 * sq_0(d_ang_1.x) + kb2_0 * sq_0(d_ang_1.y) + kt_1 * sq_0(d_ang_1.z);
    float _S515 = d_lin_1.z;
    bool _S516 = _S515 > 0.0f;
    if(_S516)
    {
        dif_1 = kn_2 * sq_0(_S515);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S514 + dif_1);
    float psi_c_0;
    if(_S515 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_2 * sq_0(_S515);
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
    bool _S517;
    float3 qc_lin_0;
    if(fracture_1)
    {
        bool _S518 = _S510 >= _S511;
        if(_S518)
        {
            diss_contact_0 = _S510;
        }
        else
        {
            diss_contact_0 = _S511;
        }
        uint mode_ts_0;
        if(_S518)
        {
            mode_ts_0 = 1U;
        }
        else
        {
            mode_ts_0 = 2U;
        }
        if(diss_contact_0 > ((&st_1)->kappa_0))
        {
            _S517 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S517 = false;
        }
        if(_S517)
        {
            _S517 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S517 = false;
        }
        uint mode_c_0;
        if(_S517)
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
            float _S519 = inc_0.x;
            if(_S519 > ((&st_1)->damage_0))
            {
                Contact_0 _S520 = contact_part_0(mat_6, b_16, (&st_1)->crush_1, plastic_3, d_lin_1, d_ang_1);
                float _S521 = max(_S520.energy_2 - (1.0f - (&st_1)->crush_1) * psi_c_0, 0.0f);
                float _S522 = max(inc_0.y - _S521 * (_S519 - (&st_1)->damage_0), 0.0f);
                float _S523 = max((psi_ts_0 - _S521) * (_S519 - (&st_1)->damage_0) - _S522, 0.0f);
                (&st_1)->damage_0 = _S519;
                (&st_1)->mode_0 = mode_ts_0;
                dissipated_3 = _S522;
                overshoot_1 = _S523;
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
        float _S524 = state_7->damage_0;
        if((state_7->damage_0) > 0.0f)
        {
            Contact_0 _S525 = contact_part_0(mat_6, b_16, state_7->crush_1, float3(state_7->plastic_x_0, state_7->plastic_y_0, state_7->plastic_t_0), d_lin_1, d_ang_1);
            qc_lin_0 = qe_ang_0 * float3((1.0f - _S524))  + _S525.q_ang_1 * float3(_S524) ;
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S526 = stress_measures_0(b_16, float3(0.0f, 0.0f, min(qe_lin_0.z, 0.0f)), qc_lin_0);
        thread Measures_0 _S527 = _S526;
        float4 _S528 = failure_indices_0(mat_6, b_16, &_S527, multiplier_1);
        float _S529 = _S528.z;
        float _S530 = _S528.w;
        bool _S531 = _S529 >= _S530;
        if(_S531)
        {
            psi_contact_0 = _S529;
        }
        else
        {
            psi_contact_0 = _S530;
        }
        if(_S531)
        {
            mode_c_0 = 3U;
        }
        else
        {
            mode_c_0 = 4U;
        }
        if(psi_contact_0 > ((&st_1)->kappa_c_0))
        {
            _S517 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S517 = false;
        }
        if(_S517)
        {
            _S517 = psi_c_0 > 0.0f;
        }
        else
        {
            _S517 = false;
        }
        if(_S517)
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
            float _S532 = inc_1.x;
            if(_S532 > ((&st_1)->crush_1))
            {
                float _S533 = inc_1.y;
                float dissipated_4 = dissipated_3 + _S533;
                float overshoot_2 = overshoot_1 + max(psi_c_0 * (_S532 - (&st_1)->crush_1) - _S533, 0.0f);
                (&st_1)->crush_1 = _S532;
                (&st_1)->mode_0 = mode_c_0;
                if(_S532 >= 1.0f)
                {
                    _S517 = ((&st_1)->damage_0) < 1.0f;
                }
                else
                {
                    _S517 = false;
                }
                if(_S517)
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
    float3 _S534 = float3(0.0f) ;
    if(((&st_1)->damage_0) == 0.0f)
    {
        _S517 = (flags_1 & 8U) != 0U;
    }
    else
    {
        _S517 = false;
    }
    float3 qc_ang_0;
    if(!_S517)
    {
        Contact_0 _S535 = contact_part_0(mat_6, b_16, (&st_1)->crush_1, plastic_3, d_lin_1, d_ang_1);
        (&st_1)->plastic_x_0 = _S535.plastic_1.x;
        (&st_1)->plastic_y_0 = _S535.plastic_1.y;
        (&st_1)->plastic_t_0 = _S535.plastic_1.z;
        diss_contact_0 = _S535.diss_4;
        qc_lin_0 = _S535.q_lin_1;
        qc_ang_0 = _S535.q_ang_1;
        psi_contact_0 = _S535.energy_2;
    }
    else
    {
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S534;
        qc_ang_0 = _S534;
        psi_contact_0 = 0.0f;
    }
    float dissipated_6 = dissipated_3 + dmg_0 * diss_contact_0;
    if(_S516)
    {
        intact_normal_0 = kn_2 * _S515;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_1)->crush_1) * kn_2 * _S515;
    }
    float _S536 = 1.0f - dmg_0;
    float3 force_lin_2 = float3(_S536 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S536 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S536 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3 force_ang_2 = qe_ang_0 * float3(_S536)  + qc_ang_0 * float3(dmg_0) ;
    float stored_6 = _S536 * (psi_ts_0 + (1.0f - (&st_1)->crush_1) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S517 = ((&st_1)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S517 = false;
    }
    float stored_7;
    float3 force_lin_3;
    if(_S517)
    {
        float4 _S537 = float4(b_16->rebar0_0) ;
        float k_axial_0 = _S537.x;
        float k_dowel_0 = _S537.y;
        float yield_force_0 = _S537.z;
        float dowel_capacity_0 = _S537.w;
        float2 nr_0 = return_map_0(k_axial_0, _S515, (&st_1)->rebar_plastic_0, yield_force_0);
        float2 v1_0 = return_map_0(k_dowel_0, _S512, (&st_1)->rebar_slip0_0, dowel_capacity_0);
        float2 v2_0 = return_map_0(k_dowel_0, _S513, (&st_1)->rebar_slip1_0, dowel_capacity_0);
        float _S538 = nr_0.y;
        float _S539 = v1_0.y;
        float _S540 = v2_0.y;
        float work_0 = yield_force_0 * abs(_S538) + dowel_capacity_0 * (abs(_S539) + abs(_S540));
        (&st_1)->rebar_plastic_0 = (&st_1)->rebar_plastic_0 + _S538;
        (&st_1)->rebar_slip0_0 = (&st_1)->rebar_slip0_0 + _S539;
        (&st_1)->rebar_slip1_0 = (&st_1)->rebar_slip1_0 + _S540;
        (&st_1)->rebar_work_0 = (&st_1)->rebar_work_0 + work_0;
        float dissipated_7 = dissipated_6 + work_0;
        float _S541 = nr_0.x;
        float _S542 = v1_0.x;
        float _S543 = v2_0.x;
        float elastic_0 = 0.5f * (sq_0(_S541) / k_axial_0 + (sq_0(_S542) + sq_0(_S543)) / k_dowel_0);
        if(fracture_1)
        {
            _S517 = ((&st_1)->rebar_work_0) >= ((float4(b_16->rebar1_0) ).x);
        }
        else
        {
            _S517 = false;
        }
        if(_S517)
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
            force_lin_3 = force_lin_2 + float3(_S542, _S543, _S541);
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
        _S517 = _S504;
    }
    else
    {
        _S517 = false;
    }
    if(_S517)
    {
        _S517 = (flags_1 & 64U) != 0U;
    }
    else
    {
        _S517 = false;
    }
    if(_S517)
    {
        Measures_0 _S544 = stress_measures_0(b_16, force_lin_3, force_ang_2);
        thread Measures_0 _S545 = _S544;
        float4 _S546 = failure_indices_0(mat_6, b_16, &_S545, weibull_0);
        float _S547 = life_rate_0(mat_6, max(max(_S546.x, _S546.y), _S546.z));
        (&st_1)->fatigue_0 = min((&st_1)->fatigue_0 + _S547 * dt_8, 1.0f);
    }
    (&st_1)->dissipated_0 = (&st_1)->dissipated_0 + dissipated_3;
    thread JointResponse_0 resp_0;
    (&resp_0)->force_lin_1 = force_lin_3;
    (&resp_0)->force_ang_1 = force_ang_2;
    (&resp_0)->state_6 = st_1;
    (&resp_0)->dissipated_2 = dissipated_3;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_5 = stored_7;
    if(_S501)
    {
        thread JointState_0 _S548 = st_1;
        bool _S549 = connected_0(&_S548, has_rebar_1);
        _S517 = !_S549;
    }
    else
    {
        _S517 = false;
    }
    (&resp_0)->disconnected_0 = _S517;
    (&resp_0)->measures_0 = _S502;
    return resp_0;
}

void secant_factors_0(const JointBond_natural_0 thread* b_17, const JointState_0 thread* st_2, float3 d_lin_2, float3 thread* f_lin_0, float3 thread* f_ang_0)
{
    float _S550 = st_2->damage_0;
    bool compressed_0 = (d_lin_2.z) < 0.0f;
    float contact_2;
    if(compressed_0)
    {
        contact_2 = _S550;
    }
    else
    {
        contact_2 = 0.0f;
    }
    float _S551 = 1.0f - _S550;
    float _S552 = max(_S551 + contact_2, 9.99999997475242708e-07f);
    float normal_4;
    if(compressed_0)
    {
        normal_4 = max(1.0f - st_2->crush_1, 9.99999997475242708e-07f);
    }
    else
    {
        normal_4 = max(_S551, 9.99999997475242708e-07f);
    }
    *f_lin_0 = float3(_S552, _S552, normal_4);
    *f_ang_0 = float3(_S552) ;
    bool _S553;
    if(((float4(b_17->stiff1_0) ).w) != 0.0f)
    {
        _S553 = (st_2->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S553 = false;
    }
    if(_S553)
    {
        float4 _S554 = float4(b_17->rebar0_0) ;
        float4 _S555 = float4(b_17->stiff0_0) ;
        (*f_lin_0).z = (*f_lin_0).z + _S554.x / _S555.x;
        float _S556 = _S554.y;
        float _S557 = _S555.y;
        (*f_lin_0).x = (*f_lin_0).x + _S556 / _S557;
        (*f_lin_0).y = (*f_lin_0).y + _S556 / _S557;
    }
    return;
}

bool is_damaged_0(const JointState_0 thread* st_3)
{
    bool _S558;
    if((st_3->damage_0) > 0.0f)
    {
        _S558 = true;
    }
    else
    {
        _S558 = (st_3->crush_1) > 0.0f;
    }
    return _S558;
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

float3 to_local_0(uint _S559, float3 _S560, KernelContext_0 thread* kernelContext_27)
{
    BondStatic_natural_0 device* _S561 = kernelContext_27->bonds_0+_S559;
    return float3(dot(_S560, (float4(_S561->t1_0) ).xyz), dot(_S560, (float4(_S561->t2_0) ).xyz), dot(_S560, (float4(_S561->normal_0) ).xyz));
}

float3 to_body_0(uint _S562, float3 _S563, KernelContext_0 thread* kernelContext_28)
{
    BondStatic_natural_0 device* _S564 = kernelContext_28->bonds_0+_S562;
    return (float4(_S564->t1_0) ).xyz * float3(_S563.x)  + (float4(_S564->t2_0) ).xyz * float3(_S563.y)  + (float4(_S564->normal_0) ).xyz * float3(_S563.z) ;
}

bool bond_update_0(uint i_7, float dt_9, bool fracture_2, uint abs_step_0, KernelContext_0 thread* kernelContext_29)
{
    BondStatic_natural_0 device* _S565 = kernelContext_29->bonds_0+i_7;
    BondDyn_natural_0 device* _S566 = kernelContext_29->bond_dyn_0+i_7;
    float4 _S567 = float4((*_S566).force_lin_0) ;
    float4 _S568 = float4((*_S566).force_ang_0) ;
    float4 _S569 = float4((*_S566).sums_0) ;
    float4 _S570 = float4((*_S566).comps_0) ;
    uint4 _S571 = uint4((*_S566).events_0) ;
    thread BondDyn_0 bd_0;
    (&bd_0)->js_0 = (*_S566).js_0;
    (&bd_0)->force_lin_0 = _S567;
    (&bd_0)->force_ang_0 = _S568;
    (&bd_0)->sums_0 = _S569;
    (&bd_0)->comps_0 = _S570;
    (&bd_0)->events_0 = _S571;
    JointBond_natural_0 _S572 = _S565->law_0;
    thread JointBond_natural_0 _S573 = _S565->law_0;
    uint4 _S574 = uint4((&_S573)->ids_0) ;
    float3 ra_1 = (float4(_S565->ra_0) ).xyz;
    float3 rb_1 = (float4(_S565->rb_0) ).xyz;
    uint _S575 = 4U * _S574.y;
    float3 ta_2 = (float4(*(kernelContext_29->state_0+(_S575 + 1U))) ).xyz;
    float3 va_0 = (float4(*(kernelContext_29->state_0+(_S575 + 2U))) ).xyz;
    float3 wa_0 = (float4(*(kernelContext_29->state_0+(_S575 + 3U))) ).xyz;
    uint _S576 = 4U * _S574.z;
    float3 tb_2 = (float4(*(kernelContext_29->state_0+(_S576 + 1U))) ).xyz;
    float3 vb_0 = (float4(*(kernelContext_29->state_0+(_S576 + 2U))) ).xyz;
    float3 wb_0 = (float4(*(kernelContext_29->state_0+(_S576 + 3U))) ).xyz;
    float3 _S577 = to_local_0(i_7, (float4(*(kernelContext_29->state_0+_S576)) ).xyz + cross(tb_2, rb_1) - ((float4(*(kernelContext_29->state_0+_S575)) ).xyz + cross(ta_2, ra_1)), kernelContext_29);
    float3 _S578 = to_local_0(i_7, tb_2 - ta_2, kernelContext_29);
    float3 _S579 = to_local_0(i_7, vb_0 + cross(wb_0, rb_1) - (va_0 + cross(wa_0, ra_1)), kernelContext_29);
    float3 _S580 = to_local_0(i_7, wb_0 - wa_0, kernelContext_29);
    JointState_0 previous_0 = (&bd_0)->js_0;
    _S573 = _S572;
    thread JointState_0 _S581 = (&bd_0)->js_0;
    JointResponse_0 _S582 = joint_evaluate_0(&kernelContext_29->materials_0->m_0[_S574.x], &_S573, &_S581, _S577, _S578, dt_9, fracture_2);
    thread JointState_0 _S583 = _S582.state_6;
    thread float3 f_lin_1;
    thread float3 f_ang_1;
    secant_factors_0(&_S573, &_S583, _S577, &f_lin_1, &f_ang_1);
    float3 qd_lin_0 = _S579 * (float4(_S565->c_lin_0) ).xyz * f_lin_1;
    float3 qd_ang_0 = _S580 * (float4(_S565->c_ang_0) ).xyz * f_ang_1;
    float3 q_lin_2 = _S582.force_lin_1 + qd_lin_0;
    float3 q_ang_2 = _S582.force_ang_1 + qd_ang_0;
    float damped_0 = (dot(qd_lin_0, _S579) + dot(qd_ang_0, _S580)) * dt_9;
    float3 _S584 = to_body_0(i_7, q_lin_2, kernelContext_29);
    float3 _S585 = to_body_0(i_7, q_ang_2, kernelContext_29);
    uint _S586 = 3U * i_7;
    *(kernelContext_29->scratch_0+_S586) = packed_float4(float4(_S584, max(_S582.measures_0.tension_0, _S582.measures_0.compression_0))) ;
    *(kernelContext_29->scratch_0+(_S586 + 1U)) = packed_float4(float4(_S585 + cross(ra_1, _S584), 0.0f)) ;
    *(kernelContext_29->scratch_0+(_S586 + 2U)) = packed_float4(float4(- _S585 + cross(rb_1, - _S584), 0.0f)) ;
    thread float _S587 = (&bd_0)->sums_0.x;
    thread float _S588 = (&bd_0)->comps_0.x;
    comp_add1_0(&_S587, &_S588, _S582.dissipated_2);
    (&bd_0)->comps_0.x = _S588;
    (&bd_0)->sums_0.x = _S587;
    thread float _S589 = (&bd_0)->sums_0.y;
    thread float _S590 = (&bd_0)->comps_0.y;
    comp_add1_0(&_S589, &_S590, _S582.overshoot_0);
    (&bd_0)->comps_0.y = _S590;
    (&bd_0)->sums_0.y = _S589;
    thread float _S591 = (&bd_0)->sums_0.z;
    thread float _S592 = (&bd_0)->comps_0.z;
    comp_add1_0(&_S591, &_S592, damped_0);
    (&bd_0)->comps_0.z = _S592;
    (&bd_0)->sums_0.z = _S591;
    (&bd_0)->force_lin_0 = float4(q_lin_2, _S582.stored_5);
    (&bd_0)->force_ang_0 = float4(q_ang_2, max((&bd_0)->force_ang_0.w, _S582.state_6.utilization_0));
    thread JointState_0 _S593 = previous_0;
    bool _S594 = is_damaged_0(&_S593);
    bool _S595;
    if(!_S594)
    {
        thread JointState_0 _S596 = _S582.state_6;
        bool _S597 = is_damaged_0(&_S596);
        _S595 = _S597;
    }
    else
    {
        _S595 = false;
    }
    if(_S595)
    {
        _S595 = ((&bd_0)->events_0.x) == 0U;
    }
    else
    {
        _S595 = false;
    }
    if(_S595)
    {
        (&bd_0)->events_0.x = abs_step_0;
        (&bd_0)->events_0.w = _S582.state_6.mode_0;
    }
    if(((&bd_0)->events_0.y) == 0U)
    {
        float _S598 = fatigue_factor_0(&kernelContext_29->materials_0->m_0[_S574.x], previous_0.fatigue_0);
        _S595 = _S598 > 0.99000000953674316f;
    }
    else
    {
        _S595 = false;
    }
    if(_S595)
    {
        float _S599 = fatigue_factor_0(&kernelContext_29->materials_0->m_0[_S574.x], _S582.state_6.fatigue_0);
        _S595 = _S599 <= 0.99000000953674316f;
    }
    else
    {
        _S595 = false;
    }
    if(_S595)
    {
        (&bd_0)->events_0.y = abs_step_0;
    }
    if(_S582.disconnected_0)
    {
        (&bd_0)->events_0.z = abs_step_0;
    }
    (&bd_0)->js_0 = _S582.state_6;
    BondDyn_natural_0 device* _S600 = kernelContext_29->bond_dyn_0+i_7;
    _S600->js_0 = bd_0.js_0;
    _S600->force_lin_0 = packed_float4(bd_0.force_lin_0) ;
    _S600->force_ang_0 = packed_float4(bd_0.force_ang_0) ;
    _S600->sums_0 = packed_float4(bd_0.sums_0) ;
    _S600->comps_0 = packed_float4(bd_0.comps_0) ;
    _S600->events_0 = packed_uint4(bd_0.events_0) ;
    return _S582.disconnected_0;
}

void chunk_update_0(uint c_13, const Island_natural_0 thread* isl_8, const Rigid_0 thread* rg_6, float dt_10, bool rml_0, uint step_0, bool contact_3, float thread* work_1, float thread* work_err_0, KernelContext_0 thread* kernelContext_30)
{
    ChunkStatic_natural_0 device* _S601 = kernelContext_30->chunks_0+c_13;
    float3 _S602 = float3(0.0f) ;
    uint _S603 = kernelContext_30->index_0[c_13];
    float peak_0 = 0.0f;
    uint e_2 = _S603;
    float3 fi_0 = _S602;
    float3 mi_0 = _S602;
    for(;;)
    {
        if(e_2 < (kernelContext_30->index_0)[c_13 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_2 = kernelContext_30->index_0[e_2];
        uint _S604 = 3U * (entry_2 >> 1U);
        float4 _S605 = float4(*(kernelContext_30->scratch_0+_S604)) ;
        if((entry_2 & 1U) == 0U)
        {
            float3 mi_1 = mi_0 + (float4(*(kernelContext_30->scratch_0+(_S604 + 1U))) ).xyz;
            fi_0 = fi_0 + _S605.xyz;
            mi_0 = mi_1;
        }
        else
        {
            float3 mi_2 = mi_0 + (float4(*(kernelContext_30->scratch_0+(_S604 + 2U))) ).xyz;
            fi_0 = fi_0 + - _S605.xyz;
            mi_0 = mi_2;
        }
        float _S606 = max(peak_0, _S605.w);
        uint _S607 = e_2 + 1U;
        peak_0 = _S606;
        e_2 = _S607;
    }
    uint _S608 = 4U * c_13;
    float3 u_0 = (float4(*(kernelContext_30->state_0+_S608)) ).xyz;
    uint _S609 = _S608 + 1U;
    float3 th_1 = (float4(*(kernelContext_30->state_0+_S609)) ).xyz;
    uint _S610 = _S608 + 2U;
    float3 v_9 = (float4(*(kernelContext_30->state_0+_S610)) ).xyz;
    uint _S611 = _S608 + 3U;
    float3 w_4 = (float4(*(kernelContext_30->state_0+_S611)) ).xyz;
    float4 _S612 = float4(_S601->center_0) ;
    float mass_0 = _S612.w;
    float3 _S613 = _S612.xyz;
    float3 _S614 = (float4(isl_8->com_0) ).xyz;
    float3 _S615 = rotate_0(&rg_6->rot_0, _S613 + u_0 - _S614);
    thread float3 f_load_0;
    thread float3 t_load_0;
    chunk_external_0(c_13, c_13, &rg_6->rot_0, step_0, dt_10, contact_3, &f_load_0, &t_load_0, kernelContext_30);
    float3 _S616 = float3(mass_0) ;
    float3 f_world_0 = f_load_0 + kernelContext_30->params_0->gravity_0.xyz * _S616;
    float3 t_world_0 = t_load_0;
    float3 f_world_1;
    float3 t_world_1;
    if(rml_0)
    {
        float3 f_world_2 = f_world_0 - (rg_6->a_6 + cross(rg_6->alpha_0, _S615) + cross(rg_6->w_3, cross(rg_6->w_3, _S615))) * _S616;
        float4 _S617 = float4(_S601->inertia0_1) ;
        float4 _S618 = float4(_S601->inertia1_1) ;
        float4 _S619 = float4(_S601->inertia2_1) ;
        float3 _S620 = world_mul_0(&rg_6->rot_0, _S617, _S618, _S619, rg_6->alpha_0);
        float3 _S621 = world_mul_0(&rg_6->rot_0, _S617, _S618, _S619, rg_6->w_3);
        float3 t_world_2 = t_world_0 - (_S620 + cross(rg_6->w_3, _S621));
        f_world_1 = f_world_2;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    float3 _S622 = inverse_rotate_0(&rg_6->rot_0, f_world_1);
    float3 _S623 = inverse_rotate_0(&rg_6->rot_0, t_world_1);
    float3 f_ext_0;
    float3 m_ext_0;
    if(rml_0)
    {
        float3 _S624 = inverse_rotate_0(&rg_6->rot_0, rg_6->w_3);
        float4 _S625 = float4(_S601->inertia0_1) ;
        float4 _S626 = float4(_S601->inertia1_1) ;
        float4 _S627 = float4(_S601->inertia2_1) ;
        float3 i_w_0 = rows_mul_0(_S625, _S626, _S627, w_4);
        float3 m_ext_1 = _S623 - (cross(_S624, i_w_0) + cross(w_4, rows_mul_0(_S625, _S626, _S627, _S624)) + cross(w_4, i_w_0));
        f_ext_0 = _S622 - cross(_S624, v_9) * float3((2.0f * mass_0)) ;
        m_ext_0 = m_ext_1;
    }
    else
    {
        f_ext_0 = _S622;
        m_ext_0 = _S623;
    }
    uint4 _S628 = uint4(_S601->load_range_0) ;
    uint term_4 = _S628.x;
    for(;;)
    {
        if(term_4 < (_S628.y))
        {
        }
        else
        {
            break;
        }
        uint _S629 = 5U * term_4;
        if(((as_type<uint4>((float4(*(kernelContext_30->loads_0+_S629)) ))).y) != 2U)
        {
            term_4 = term_4 + 1U;
            continue;
        }
        float _S630 = eval_function_0(term_4, step_0, dt_10, dt_10, kernelContext_30);
        float3 _S631 = float3(_S630) ;
        float3 m_ext_2 = m_ext_0 + (float4(*(kernelContext_30->loads_0+(_S629 + 2U))) ).xyz * _S631;
        f_ext_0 = f_ext_0 + (float4(*(kernelContext_30->loads_0+(_S629 + 1U))) ).xyz * _S631;
        m_ext_0 = m_ext_2;
        term_4 = term_4 + 1U;
    }
    float3 f_9 = f_ext_0 + fi_0;
    float3 m_5 = m_ext_0 + mi_0;
    uint support_0 = (uint4(_S601->info_1) ).x;
    float3 _S632 = float3((float4(*(kernelContext_30->state_0+_S609)) ).w, (float4(*(kernelContext_30->state_0+_S610)) ).w, (float4(*(kernelContext_30->state_0+_S611)) ).w);
    float3 reaction_0;
    float3 u_1;
    float3 th_2;
    float3 v_10;
    float3 w_5;
    if(support_0 == 1U)
    {
        reaction_0 = - f_9;
        u_1 = u_0;
        th_2 = th_1;
        v_10 = _S602;
        w_5 = _S602;
    }
    else
    {
        float4 _S633 = float4(_S601->scale_0) ;
        float3 w_6 = w_4 + rows_mul_0(float4(_S601->inv0_1) , float4(_S601->inv1_1) , float4(_S601->inv2_1) , m_5) * float3((dt_10 * _S633.z)) ;
        float3 _S634 = float3(dt_10) ;
        float3 th_3 = th_1 + w_6 * _S634;
        if(support_0 == 2U)
        {
            reaction_0 = - f_9;
            u_1 = u_0;
            th_2 = _S602;
        }
        else
        {
            float3 v_11 = v_9 + f_9 * float3((dt_10 * _S633.y)) ;
            float3 u_2 = u_0 + v_11 * _S634;
            reaction_0 = _S632;
            u_1 = u_2;
            th_2 = v_11;
        }
        float3 _S635 = th_2;
        th_2 = th_3;
        v_10 = _S635;
        w_5 = w_6;
    }
    *(kernelContext_30->state_0+_S608) = packed_float4(float4(u_1, peak_0)) ;
    *(kernelContext_30->state_0+_S609) = packed_float4(float4(th_2, reaction_0.x)) ;
    *(kernelContext_30->state_0+_S610) = packed_float4(float4(v_10, reaction_0.y)) ;
    *(kernelContext_30->state_0+_S611) = packed_float4(float4(w_5, reaction_0.z)) ;
    float3 _S636 = rotate_0(&rg_6->rot_0, _S613 + u_1 - _S614);
    float3 _S637 = rg_6->vel_1 + rg_6->vel_err_1 + cross(rg_6->w_3, _S636);
    float3 _S638 = rotate_0(&rg_6->rot_0, v_10);
    float3 v_world_0 = _S637 + _S638;
    float3 _S639 = rotate_0(&rg_6->rot_0, w_5);
    comp_add1_0(work_1, work_err_0, (dot(f_load_0, v_world_0) + dot(t_load_0, rg_6->w_3 + _S639)) * dt_10);
    return;
}

void chunk_update_1(uint c_14, const Island_0 thread* isl_9, const Rigid_0 thread* rg_7, float dt_11, bool rml_1, uint step_1, bool contact_4, float thread* work_2, float thread* work_err_1, KernelContext_0 thread* kernelContext_31)
{
    ChunkStatic_natural_0 device* _S640 = kernelContext_31->chunks_0+c_14;
    float3 _S641 = float3(0.0f) ;
    uint _S642 = kernelContext_31->index_0[c_14];
    float peak_1 = 0.0f;
    uint e_3 = _S642;
    float3 fi_1 = _S641;
    float3 mi_3 = _S641;
    for(;;)
    {
        if(e_3 < (kernelContext_31->index_0)[c_14 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_3 = kernelContext_31->index_0[e_3];
        uint _S643 = 3U * (entry_3 >> 1U);
        float4 _S644 = float4(*(kernelContext_31->scratch_0+_S643)) ;
        if((entry_3 & 1U) == 0U)
        {
            float3 mi_4 = mi_3 + (float4(*(kernelContext_31->scratch_0+(_S643 + 1U))) ).xyz;
            fi_1 = fi_1 + _S644.xyz;
            mi_3 = mi_4;
        }
        else
        {
            float3 mi_5 = mi_3 + (float4(*(kernelContext_31->scratch_0+(_S643 + 2U))) ).xyz;
            fi_1 = fi_1 + - _S644.xyz;
            mi_3 = mi_5;
        }
        float _S645 = max(peak_1, _S644.w);
        uint _S646 = e_3 + 1U;
        peak_1 = _S645;
        e_3 = _S646;
    }
    uint _S647 = 4U * c_14;
    float3 u_3 = (float4(*(kernelContext_31->state_0+_S647)) ).xyz;
    uint _S648 = _S647 + 1U;
    float3 th_4 = (float4(*(kernelContext_31->state_0+_S648)) ).xyz;
    uint _S649 = _S647 + 2U;
    float3 v_12 = (float4(*(kernelContext_31->state_0+_S649)) ).xyz;
    uint _S650 = _S647 + 3U;
    float3 w_7 = (float4(*(kernelContext_31->state_0+_S650)) ).xyz;
    float4 _S651 = float4(_S640->center_0) ;
    float mass_1 = _S651.w;
    float3 _S652 = _S651.xyz;
    float3 _S653 = isl_9->com_0.xyz;
    float3 _S654 = rotate_0(&rg_7->rot_0, _S652 + u_3 - _S653);
    thread float3 f_load_1;
    thread float3 t_load_1;
    chunk_external_0(c_14, c_14, &rg_7->rot_0, step_1, dt_11, contact_4, &f_load_1, &t_load_1, kernelContext_31);
    float3 _S655 = float3(mass_1) ;
    float3 f_world_3 = f_load_1 + kernelContext_31->params_0->gravity_0.xyz * _S655;
    float3 t_world_3 = t_load_1;
    float3 f_world_4;
    float3 t_world_4;
    if(rml_1)
    {
        float3 f_world_5 = f_world_3 - (rg_7->a_6 + cross(rg_7->alpha_0, _S654) + cross(rg_7->w_3, cross(rg_7->w_3, _S654))) * _S655;
        float4 _S656 = float4(_S640->inertia0_1) ;
        float4 _S657 = float4(_S640->inertia1_1) ;
        float4 _S658 = float4(_S640->inertia2_1) ;
        float3 _S659 = world_mul_0(&rg_7->rot_0, _S656, _S657, _S658, rg_7->alpha_0);
        float3 _S660 = world_mul_0(&rg_7->rot_0, _S656, _S657, _S658, rg_7->w_3);
        float3 t_world_5 = t_world_3 - (_S659 + cross(rg_7->w_3, _S660));
        f_world_4 = f_world_5;
        t_world_4 = t_world_5;
    }
    else
    {
        f_world_4 = f_world_3;
        t_world_4 = t_world_3;
    }
    float3 _S661 = inverse_rotate_0(&rg_7->rot_0, f_world_4);
    float3 _S662 = inverse_rotate_0(&rg_7->rot_0, t_world_4);
    float3 f_ext_1;
    float3 m_ext_3;
    if(rml_1)
    {
        float3 _S663 = inverse_rotate_0(&rg_7->rot_0, rg_7->w_3);
        float4 _S664 = float4(_S640->inertia0_1) ;
        float4 _S665 = float4(_S640->inertia1_1) ;
        float4 _S666 = float4(_S640->inertia2_1) ;
        float3 i_w_1 = rows_mul_0(_S664, _S665, _S666, w_7);
        float3 m_ext_4 = _S662 - (cross(_S663, i_w_1) + cross(w_7, rows_mul_0(_S664, _S665, _S666, _S663)) + cross(w_7, i_w_1));
        f_ext_1 = _S661 - cross(_S663, v_12) * float3((2.0f * mass_1)) ;
        m_ext_3 = m_ext_4;
    }
    else
    {
        f_ext_1 = _S661;
        m_ext_3 = _S662;
    }
    uint4 _S667 = uint4(_S640->load_range_0) ;
    uint term_5 = _S667.x;
    for(;;)
    {
        if(term_5 < (_S667.y))
        {
        }
        else
        {
            break;
        }
        uint _S668 = 5U * term_5;
        if(((as_type<uint4>((float4(*(kernelContext_31->loads_0+_S668)) ))).y) != 2U)
        {
            term_5 = term_5 + 1U;
            continue;
        }
        float _S669 = eval_function_0(term_5, step_1, dt_11, dt_11, kernelContext_31);
        float3 _S670 = float3(_S669) ;
        float3 m_ext_5 = m_ext_3 + (float4(*(kernelContext_31->loads_0+(_S668 + 2U))) ).xyz * _S670;
        f_ext_1 = f_ext_1 + (float4(*(kernelContext_31->loads_0+(_S668 + 1U))) ).xyz * _S670;
        m_ext_3 = m_ext_5;
        term_5 = term_5 + 1U;
    }
    float3 f_10 = f_ext_1 + fi_1;
    float3 m_6 = m_ext_3 + mi_3;
    uint support_1 = (uint4(_S640->info_1) ).x;
    float3 _S671 = float3((float4(*(kernelContext_31->state_0+_S648)) ).w, (float4(*(kernelContext_31->state_0+_S649)) ).w, (float4(*(kernelContext_31->state_0+_S650)) ).w);
    float3 reaction_1;
    float3 u_4;
    float3 th_5;
    float3 v_13;
    float3 w_8;
    if(support_1 == 1U)
    {
        reaction_1 = - f_10;
        u_4 = u_3;
        th_5 = th_4;
        v_13 = _S641;
        w_8 = _S641;
    }
    else
    {
        float4 _S672 = float4(_S640->scale_0) ;
        float3 w_9 = w_7 + rows_mul_0(float4(_S640->inv0_1) , float4(_S640->inv1_1) , float4(_S640->inv2_1) , m_6) * float3((dt_11 * _S672.z)) ;
        float3 _S673 = float3(dt_11) ;
        float3 th_6 = th_4 + w_9 * _S673;
        if(support_1 == 2U)
        {
            reaction_1 = - f_10;
            u_4 = u_3;
            th_5 = _S641;
        }
        else
        {
            float3 v_14 = v_12 + f_10 * float3((dt_11 * _S672.y)) ;
            float3 u_5 = u_3 + v_14 * _S673;
            reaction_1 = _S671;
            u_4 = u_5;
            th_5 = v_14;
        }
        float3 _S674 = th_5;
        th_5 = th_6;
        v_13 = _S674;
        w_8 = w_9;
    }
    *(kernelContext_31->state_0+_S647) = packed_float4(float4(u_4, peak_1)) ;
    *(kernelContext_31->state_0+_S648) = packed_float4(float4(th_5, reaction_1.x)) ;
    *(kernelContext_31->state_0+_S649) = packed_float4(float4(v_13, reaction_1.y)) ;
    *(kernelContext_31->state_0+_S650) = packed_float4(float4(w_8, reaction_1.z)) ;
    float3 _S675 = rotate_0(&rg_7->rot_0, _S652 + u_4 - _S653);
    float3 _S676 = rg_7->vel_1 + rg_7->vel_err_1 + cross(rg_7->w_3, _S675);
    float3 _S677 = rotate_0(&rg_7->rot_0, v_13);
    float3 v_world_1 = _S676 + _S677;
    float3 _S678 = rotate_0(&rg_7->rot_0, w_8);
    comp_add1_0(work_2, work_err_1, (dot(f_load_1, v_world_1) + dot(t_load_1, rg_7->w_3 + _S678)) * dt_11);
    return;
}

void integrate_rigid_0(const Island_natural_0 thread* isl_10, Rigid_0 thread* rg_8, float dt_12)
{
    float4 _S679 = float4(isl_10->inertia0_0) ;
    float4 _S680 = float4(isl_10->inertia1_0) ;
    float4 _S681 = float4(isl_10->inertia2_0) ;
    thread Quat_0 _S682 = rg_8->rot_0;
    float3 _S683 = world_mul_0(&_S682, _S679, _S680, _S681, rg_8->w_3);
    thread Quat_0 _S684 = rg_8->rot_0;
    float3 _S685 = world_mul_0(&_S684, _S679, _S680, _S681, rg_8->alpha_0);
    float3 _S686 = float3(dt_12) ;
    float3 l_2 = _S683 + (_S685 + cross(rg_8->w_3, _S683)) * _S686;
    comp_add_0(&rg_8->vel_1, &rg_8->vel_err_1, rg_8->a_6 * _S686);
    float3 vel_2 = rg_8->vel_1 + rg_8->vel_err_1;
    float4 _S687 = float4(isl_10->inv0_0) ;
    float4 _S688 = float4(isl_10->inv1_0) ;
    float4 _S689 = float4(isl_10->inv2_0) ;
    thread Quat_0 _S690 = rg_8->rot_0;
    float3 _S691 = world_mul_0(&_S690, _S687, _S688, _S689, l_2);
    thread Quat_0 _S692 = rg_8->rot_0;
    Quat_0 _S693 = integrate_rotation_0(&_S692, _S691, dt_12);
    float3 _S694 = vel_2 * _S686;
    float3 _S695 = (float4(isl_10->com_0) ).xyz;
    thread Quat_0 _S696 = rg_8->rot_0;
    float3 _S697 = rotate_0(&_S696, _S695);
    thread Quat_0 _S698 = _S693;
    float3 _S699 = rotate_0(&_S698, _S695);
    comp_add_0(&rg_8->pos_1, &rg_8->pos_err_1, _S694 + (_S697 - _S699));
    rg_8->rot_0 = _S693;
    thread Quat_0 _S700 = _S693;
    float3 _S701 = world_mul_0(&_S700, _S687, _S688, _S689, l_2);
    rg_8->w_3 = _S701;
    return;
}

void integrate_rigid_1(const Island_0 thread* isl_11, Rigid_0 thread* rg_9, float dt_13)
{
    thread Quat_0 _S702 = rg_9->rot_0;
    float3 _S703 = world_mul_0(&_S702, isl_11->inertia0_0, isl_11->inertia1_0, isl_11->inertia2_0, rg_9->w_3);
    thread Quat_0 _S704 = rg_9->rot_0;
    float3 _S705 = world_mul_0(&_S704, isl_11->inertia0_0, isl_11->inertia1_0, isl_11->inertia2_0, rg_9->alpha_0);
    float3 _S706 = float3(dt_13) ;
    float3 l_3 = _S703 + (_S705 + cross(rg_9->w_3, _S703)) * _S706;
    comp_add_0(&rg_9->vel_1, &rg_9->vel_err_1, rg_9->a_6 * _S706);
    float3 vel_3 = rg_9->vel_1 + rg_9->vel_err_1;
    float4 _S707 = isl_11->inv0_0;
    float4 _S708 = isl_11->inv1_0;
    float4 _S709 = isl_11->inv2_0;
    thread Quat_0 _S710 = rg_9->rot_0;
    float3 _S711 = world_mul_0(&_S710, isl_11->inv0_0, isl_11->inv1_0, isl_11->inv2_0, l_3);
    thread Quat_0 _S712 = rg_9->rot_0;
    Quat_0 _S713 = integrate_rotation_0(&_S712, _S711, dt_13);
    float3 _S714 = vel_3 * _S706;
    float3 _S715 = isl_11->com_0.xyz;
    thread Quat_0 _S716 = rg_9->rot_0;
    float3 _S717 = rotate_0(&_S716, _S715);
    thread Quat_0 _S718 = _S713;
    float3 _S719 = rotate_0(&_S718, _S715);
    comp_add_0(&rg_9->pos_1, &rg_9->pos_err_1, _S714 + (_S717 - _S719));
    rg_9->rot_0 = _S713;
    thread Quat_0 _S720 = _S713;
    float3 _S721 = world_mul_0(&_S720, _S707, _S708, _S709, l_3);
    rg_9->w_3 = _S721;
    return;
}

void drift_moments_0(uint c_15, float3 thread* tu_0, float3 thread* pv_0, KernelContext_0 thread* kernelContext_32)
{
    ChunkStatic_natural_0 device* _S722 = kernelContext_32->chunks_0+c_15;
    uint _S723 = 4U * c_15;
    float3 _S724 = float3(((float4(_S722->center_0) ).w * (float4(_S722->scale_0) ).x)) ;
    *tu_0 = *tu_0 + (float4(*(kernelContext_32->state_0+_S723)) ).xyz * _S724;
    *pv_0 = *pv_0 + (float4(*(kernelContext_32->state_0+(_S723 + 2U))) ).xyz * _S724;
    return;
}

void drift_angular_0(uint c_16, float3 wcom_1, float3 tr_0, float3 dv_0, float3 thread* lu_0, float3 thread* lv_0, KernelContext_0 thread* kernelContext_33)
{
    ChunkStatic_natural_0 device* _S725 = kernelContext_33->chunks_0+c_16;
    float4 _S726 = float4(_S725->center_0) ;
    float3 r_9 = _S726.xyz - wcom_1;
    uint _S727 = 4U * c_16;
    float3 _S728 = float3(_S726.w) ;
    float4 _S729 = float4(_S725->inertia0_1) ;
    float4 _S730 = float4(_S725->inertia1_1) ;
    float4 _S731 = float4(_S725->inertia2_1) ;
    float3 _S732 = float3((float4(_S725->scale_0) ).x) ;
    *lu_0 = *lu_0 + (cross(r_9, (float4(*(kernelContext_33->state_0+_S727)) ).xyz - tr_0) * _S728 + rows_mul_0(_S729, _S730, _S731, (float4(*(kernelContext_33->state_0+(_S727 + 1U))) ).xyz)) * _S732;
    *lv_0 = *lv_0 + (cross(r_9, (float4(*(kernelContext_33->state_0+(_S727 + 2U))) ).xyz - dv_0) * _S728 + rows_mul_0(_S729, _S730, _S731, (float4(*(kernelContext_33->state_0+(_S727 + 3U))) ).xyz)) * _S732;
    return;
}

void drift_apply_0(uint c_17, float3 wcom_2, float3 tr_1, float3 phi_0, float3 dv_1, float3 dw_0, KernelContext_0 thread* kernelContext_34)
{
    float3 r_10 = (float4((kernelContext_34->chunks_0+c_17)->center_0) ).xyz - wcom_2;
    uint _S733 = 4U * c_17;
    *(kernelContext_34->state_0+_S733) = packed_float4(float4((float4(*(kernelContext_34->state_0+_S733)) ).xyz - (tr_1 + cross(phi_0, r_10)), (float4(*(kernelContext_34->state_0+_S733)) ).w)) ;
    uint _S734 = _S733 + 1U;
    *(kernelContext_34->state_0+_S734) = packed_float4(float4((float4(*(kernelContext_34->state_0+_S734)) ).xyz - phi_0, (float4(*(kernelContext_34->state_0+_S734)) ).w)) ;
    uint _S735 = _S733 + 2U;
    *(kernelContext_34->state_0+_S735) = packed_float4(float4((float4(*(kernelContext_34->state_0+_S735)) ).xyz - (dv_1 + cross(dw_0, r_10)), (float4(*(kernelContext_34->state_0+_S735)) ).w)) ;
    uint _S736 = _S733 + 3U;
    *(kernelContext_34->state_0+_S736) = packed_float4(float4((float4(*(kernelContext_34->state_0+_S736)) ).xyz - dw_0, (float4(*(kernelContext_34->state_0+_S736)) ).w)) ;
    return;
}

void drift_rigid_0(const Island_natural_0 thread* isl_12, Rigid_0 thread* rg_10, float3 tr_2, float3 phi_1, float3 dv_2, float3 dw_1)
{
    float3 wcom_3 = (float4(isl_12->wcom_0) ).xyz;
    Quat_0 rot_1 = rg_10->rot_0;
    float3 _S737 = tr_2 - cross(phi_1, wcom_3);
    thread Quat_0 _S738 = rg_10->rot_0;
    float3 _S739 = rotate_0(&_S738, _S737);
    comp_add_0(&rg_10->pos_1, &rg_10->pos_err_1, _S739);
    Quat_0 _S740 = from_axis_angle_0(phi_1, length(phi_1));
    thread Quat_0 _S741 = rg_10->rot_0;
    thread Quat_0 _S742 = _S740;
    Quat_0 _S743 = quat_mul_0(&_S741, &_S742);
    thread Quat_0 _S744 = _S743;
    Quat_0 _S745 = normalized_0(&_S744);
    rg_10->rot_0 = _S745;
    float3 _S746 = dv_2 + cross(dw_1, (float4(isl_12->com_0) ).xyz - wcom_3);
    thread Quat_0 _S747 = rot_1;
    float3 _S748 = rotate_0(&_S747, _S746);
    comp_add_0(&rg_10->vel_1, &rg_10->vel_err_1, _S748);
    thread Quat_0 _S749 = rot_1;
    float3 _S750 = rotate_0(&_S749, dw_1);
    rg_10->w_3 = rg_10->w_3 + _S750;
    return;
}

void drift_rigid_1(const Island_0 thread* isl_13, Rigid_0 thread* rg_11, float3 tr_3, float3 phi_2, float3 dv_3, float3 dw_2)
{
    float3 wcom_4 = isl_13->wcom_0.xyz;
    Quat_0 rot_2 = rg_11->rot_0;
    float3 _S751 = tr_3 - cross(phi_2, wcom_4);
    thread Quat_0 _S752 = rg_11->rot_0;
    float3 _S753 = rotate_0(&_S752, _S751);
    comp_add_0(&rg_11->pos_1, &rg_11->pos_err_1, _S753);
    Quat_0 _S754 = from_axis_angle_0(phi_2, length(phi_2));
    thread Quat_0 _S755 = rg_11->rot_0;
    thread Quat_0 _S756 = _S754;
    Quat_0 _S757 = quat_mul_0(&_S755, &_S756);
    thread Quat_0 _S758 = _S757;
    Quat_0 _S759 = normalized_0(&_S758);
    rg_11->rot_0 = _S759;
    float3 _S760 = dv_3 + cross(dw_2, isl_13->com_0.xyz - wcom_4);
    thread Quat_0 _S761 = rot_2;
    float3 _S762 = rotate_0(&_S761, _S760);
    comp_add_0(&rg_11->vel_1, &rg_11->vel_err_1, _S762);
    thread Quat_0 _S763 = rot_2;
    float3 _S764 = rotate_0(&_S763, dw_2);
    rg_11->w_3 = rg_11->w_3 + _S764;
    return;
}

void write_probe_0(uint slot_1, uint k_16, float value_0, KernelContext_0 thread* kernelContext_35)
{
    uint at_4 = kernelContext_35->params_0->probe_base_0 * 4U + slot_1 * kernelContext_35->params_0->probe_stride_0 + k_16;
    thread float4 v_15 = float4(*(kernelContext_35->scratch_0+at_4 / 4U)) ;
    v_15[at_4 % 4U] = value_0;
    *(kernelContext_35->scratch_0+at_4 / 4U) = packed_float4(v_15) ;
    return;
}

void record_probes_0(const Island_0 thread* isl_14, const Rigid_0 thread* rg_12, uint k_17, KernelContext_0 thread* kernelContext_36)
{
    uint4 _S765 = isl_14->probes_0;
    uint at_5 = isl_14->probes_0.x;
    for(;;)
    {
        if(at_5 < (_S765.y))
        {
        }
        else
        {
            break;
        }
        uint4 info_3 = (as_type<uint4>((float4(*(kernelContext_36->loads_0+at_5)) )));
        float4 _S766 = float4(*(kernelContext_36->loads_0+(at_5 + 1U))) ;
        float4 _S767 = float4(*(kernelContext_36->loads_0+(at_5 + 2U))) ;
        float4 _S768 = float4(*(kernelContext_36->loads_0+(at_5 + 3U))) ;
        uint kind_4 = info_3.x;
        uint i_8 = info_3.y;
        float value_1;
        if(kind_4 == 0U)
        {
            float3 _S769 = rg_12->pos_1 - _S767.xyz + (rg_12->pos_err_1 - _S768.xyz);
            float3 _S770 = rotate_0(&rg_12->rot_0, (float4((kernelContext_36->chunks_0+i_8)->center_0) ).xyz + (float4(*(kernelContext_36->state_0+4U * i_8)) ).xyz);
            value_1 = dot(_S769 + _S770, _S766.xyz);
        }
        else
        {
            if(kind_4 == 1U)
            {
                uint _S771 = 4U * i_8;
                float3 _S772 = rotate_0(&rg_12->rot_0, (float4((kernelContext_36->chunks_0+i_8)->center_0) ).xyz + (float4(*(kernelContext_36->state_0+_S771)) ).xyz - isl_14->com_0.xyz);
                float3 _S773 = rg_12->vel_1 + rg_12->vel_err_1 + cross(rg_12->w_3, _S772);
                float3 _S774 = rotate_0(&rg_12->rot_0, (float4(*(kernelContext_36->state_0+(_S771 + 2U))) ).xyz);
                value_1 = dot(_S773 + _S774, _S766.xyz);
            }
            else
            {
                if(kind_4 == 2U)
                {
                    uint _S775 = 3U * i_8;
                    float3 f_11 = (float4(*(kernelContext_36->scratch_0+_S775)) ).xyz;
                    bool _S776 = (info_3.z) == 0U;
                    float3 mc_0;
                    if(_S776)
                    {
                        mc_0 = (float4(*(kernelContext_36->scratch_0+(_S775 + 1U))) ).xyz;
                    }
                    else
                    {
                        mc_0 = (float4(*(kernelContext_36->scratch_0+(_S775 + 2U))) ).xyz;
                    }
                    float3 fc_4;
                    if(_S776)
                    {
                        fc_4 = f_11;
                    }
                    else
                    {
                        fc_4 = - f_11;
                    }
                    value_1 = dot(fc_4, _S766.xyz) + dot(mc_0, _S767.xyz);
                }
                else
                {
                    uint _S777 = 4U * i_8;
                    float3 _S778 = rotate_0(&rg_12->rot_0, float3((float4(*(kernelContext_36->state_0+(_S777 + 1U))) ).w, (float4(*(kernelContext_36->state_0+(_S777 + 2U))) ).w, (float4(*(kernelContext_36->state_0+(_S777 + 3U))) ).w));
                    value_1 = dot(_S778, _S766.xyz);
                }
            }
        }
        write_probe_0(info_3.w, k_17, value_1, kernelContext_36);
        at_5 = at_5 + 4U;
    }
    return;
}

void contact_split_at_0(uint at_6, KernelContext_0 thread* kernelContext_37)
{
    uint previous_1 = (uint4((kernelContext_37->islands_0+kernelContext_37->params_0->halt_index_0)->info_0) ).y;
    uint _S779;
    if(previous_1 == 0U)
    {
        _S779 = at_6;
    }
    else
    {
        _S779 = min(previous_1, at_6);
    }
    (kernelContext_37->islands_0+kernelContext_37->params_0->halt_index_0)->info_0[int(1)] = _S779;
    return;
}

[[kernel]] void island_frame(uint3 group_2 [[threadgroup_position_in_grid]], uint3 thread_2 [[thread_position_in_threadgroup]], Params_0 constant* params_6 [[buffer(0)]], Island_natural_0 device* islands_6 [[buffer(9)]], uint device* index_6 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_6 [[buffer(3)]], packed_float4 device* state_8 [[buffer(6)]], packed_float4 device* scratch_6 [[buffer(8)]], packed_float4 device* contact_state_6 [[buffer(11)]], Impactor_natural_0 device* impactors_6 [[buffer(10)]], packed_float4 device* loads_6 [[buffer(5)]], BondStatic_natural_0 device* bonds_6 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_6 [[buffer(7)]], MaterialTable_0 constant* materials_6 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_38;
    (&kernelContext_38)->params_0 = params_6;
    (&kernelContext_38)->islands_0 = islands_6;
    (&kernelContext_38)->index_0 = index_6;
    (&kernelContext_38)->chunks_0 = chunks_6;
    (&kernelContext_38)->state_0 = state_8;
    (&kernelContext_38)->scratch_0 = scratch_6;
    (&kernelContext_38)->contact_state_0 = contact_state_6;
    (&kernelContext_38)->impactors_0 = impactors_6;
    (&kernelContext_38)->loads_0 = loads_6;
    (&kernelContext_38)->bonds_0 = bonds_6;
    (&kernelContext_38)->bond_dyn_0 = bond_dyn_6;
    (&kernelContext_38)->materials_0 = materials_6;
    threadgroup array<float4, int(256)> g_red_a_6;
    (&kernelContext_38)->g_red_a_0 = &g_red_a_6;
    threadgroup array<float4, int(256)> g_red_b_6;
    (&kernelContext_38)->g_red_b_0 = &g_red_b_6;
    threadgroup uint g_run_6;
    (&kernelContext_38)->g_run_0 = &g_run_6;
    threadgroup uint g_halt_6;
    (&kernelContext_38)->g_halt_0 = &g_halt_6;
    threadgroup uint g_wide_run_6;
    (&kernelContext_38)->g_wide_run_0 = &g_wide_run_6;
    uint tid_4 = thread_2.x;
    uint _S780 = group_2.x;
    Island_natural_0 device* _S781 = islands_6+_S780;
    uint4 _S782 = uint4((*_S781).info_0) ;
    float4 _S783 = float4((*_S781).com_0) ;
    float4 _S784 = float4((*_S781).inertia0_0) ;
    float4 _S785 = float4((*_S781).inertia1_0) ;
    float4 _S786 = float4((*_S781).inertia2_0) ;
    float4 _S787 = float4((*_S781).inv0_0) ;
    float4 _S788 = float4((*_S781).inv1_0) ;
    float4 _S789 = float4((*_S781).inv2_0) ;
    float4 _S790 = float4((*_S781).wcom_0) ;
    float4 _S791 = float4((*_S781).winv0_0) ;
    float4 _S792 = float4((*_S781).winv1_0) ;
    float4 _S793 = float4((*_S781).winv2_0) ;
    float4 _S794 = float4((*_S781).rotation_0) ;
    float4 _S795 = float4((*_S781).position_0) ;
    float4 _S796 = float4((*_S781).position_err_0) ;
    float4 _S797 = float4((*_S781).velocity_0) ;
    float4 _S798 = float4((*_S781).velocity_err_0) ;
    float4 _S799 = float4((*_S781).angular_velocity_0) ;
    uint4 _S800 = uint4((*_S781).done_0) ;
    uint4 _S801 = uint4((*_S781).probes_0) ;
    float4 _S802 = float4((*_S781).energy_0) ;
    thread Island_0 isl_15;
    (&isl_15)->range_0 = uint4((*_S781).range_0) ;
    (&isl_15)->info_0 = _S782;
    (&isl_15)->com_0 = _S783;
    (&isl_15)->inertia0_0 = _S784;
    (&isl_15)->inertia1_0 = _S785;
    (&isl_15)->inertia2_0 = _S786;
    (&isl_15)->inv0_0 = _S787;
    (&isl_15)->inv1_0 = _S788;
    (&isl_15)->inv2_0 = _S789;
    (&isl_15)->wcom_0 = _S790;
    (&isl_15)->winv0_0 = _S791;
    (&isl_15)->winv1_0 = _S792;
    (&isl_15)->winv2_0 = _S793;
    (&isl_15)->rotation_0 = _S794;
    (&isl_15)->position_0 = _S795;
    (&isl_15)->position_err_0 = _S796;
    (&isl_15)->velocity_0 = _S797;
    (&isl_15)->velocity_err_0 = _S798;
    (&isl_15)->angular_velocity_0 = _S799;
    (&isl_15)->done_0 = _S800;
    (&isl_15)->probes_0 = _S801;
    (&isl_15)->energy_0 = _S802;
    bool driven_0 = (((&isl_15)->info_0.x) & 2U) != 0U;
    bool _S803 = !((((&isl_15)->info_0.x) & 1U) != 0U);
    bool _S804;
    if(_S803)
    {
        _S804 = !driven_0;
    }
    else
    {
        _S804 = false;
    }
    bool contact_island_0 = (((&isl_15)->info_0.x) & 4U) != 0U;
    bool _S805 = tid_4 == 0U;
    bool _S806;
    uint run_0;
    if(_S805)
    {
        if(contact_island_0 != (((&kernelContext_38)->params_0->contact_mode_0) == 1U))
        {
            _S806 = true;
        }
        else
        {
            _S806 = (((&isl_15)->info_0.x) & 8U) != 0U;
        }
        if(_S806)
        {
            run_0 = 0U;
        }
        else
        {
            run_0 = 1U;
        }
        if(contact_island_0)
        {
            thread Island_0 _S807 = isl_15;
            bool _S808 = contact_stopped_1(&_S807, &kernelContext_38);
            _S806 = _S808;
        }
        else
        {
            _S806 = false;
        }
        if(_S806)
        {
            run_0 = 0U;
        }
        *(&kernelContext_38)->g_run_0 = run_0;
        *(&kernelContext_38)->g_halt_0 = 0U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    if((((&isl_15)->info_0.z) & 1U) != 0U)
    {
        _S806 = true;
    }
    else
    {
        _S806 = (*(&kernelContext_38)->g_run_0) == 0U;
    }
    if(_S806)
    {
        run_0 = 0U;
    }
    else
    {
        run_0 = min((&isl_15)->info_0.y, (&kernelContext_38)->params_0->max_steps_0);
    }
    float _S809 = (&kernelContext_38)->params_0->dt_0;
    bool _S810 = ((&kernelContext_38)->params_0->fracture_0) != 0U;
    bool _S811 = ((&kernelContext_38)->params_0->rigid_motion_loads_0) != 0U;
    thread Island_0 _S812 = isl_15;
    Rigid_0 _S813 = rigid_of_1(&_S812);
    thread Rigid_0 rg_13 = _S813;
    thread float work_3 = 0.0f;
    thread float work_err_2 = 0.0f;
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
        uint abs_step_1 = (&isl_15)->info_0.w + done_1 + 1U;
        uint k_18 = abs_step_1 - 1U - (&kernelContext_38)->params_0->step_start_0;
        uint i_9;
        if(_S803)
        {
            float3 _S814 = float3(0.0f) ;
            thread float3 f_12 = _S814;
            thread float3 t_11 = _S814;
            i_9 = (&isl_15)->range_0.x + tid_4;
            for(;;)
            {
                if(i_9 < ((&isl_15)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                thread Island_0 _S815 = isl_15;
                thread Rigid_0 _S816 = rg_13;
                net_load_1(i_9, &_S815, &_S816, k_18, _S809, contact_island_0, &f_12, &t_11, &kernelContext_38);
                i_9 = i_9 + 256U;
            }
            group_sum3_0(tid_4, &f_12, &t_11, &kernelContext_38);
            thread Island_0 _S817 = isl_15;
            rigid_acceleration_1(&_S817, &rg_13, f_12, t_11);
        }
        i_9 = (&isl_15)->range_0.z + tid_4;
        for(;;)
        {
            if(i_9 < ((&isl_15)->range_0.w))
            {
            }
            else
            {
                break;
            }
            bool _S818 = bond_update_0(i_9, _S809, _S810, abs_step_1, &kernelContext_38);
            if(_S818)
            {
                *(&kernelContext_38)->g_halt_0 = 1U;
            }
            i_9 = i_9 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_18 = (&isl_15)->range_0.x + tid_4;
        for(;;)
        {
            if(c_18 < ((&isl_15)->range_0.y))
            {
            }
            else
            {
                break;
            }
            thread Island_0 _S819 = isl_15;
            thread Rigid_0 _S820 = rg_13;
            chunk_update_1(c_18, &_S819, &_S820, _S809, _S811, k_18, contact_island_0, &work_3, &work_err_2, &kernelContext_38);
            c_18 = c_18 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        if(_S804)
        {
            thread Island_0 _S821 = isl_15;
            integrate_rigid_1(&_S821, &rg_13, _S809);
        }
        if(_S803)
        {
            float3 _S822 = (&isl_15)->wcom_0.xyz;
            float3 _S823 = float3(0.0f) ;
            thread float3 tu_1 = _S823;
            thread float3 pv_1 = _S823;
            uint c_19 = (&isl_15)->range_0.x + tid_4;
            for(;;)
            {
                if(c_19 < ((&isl_15)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_moments_0(c_19, &tu_1, &pv_1, &kernelContext_38);
                c_19 = c_19 + 256U;
            }
            group_sum3_0(tid_4, &tu_1, &pv_1, &kernelContext_38);
            float3 tr_4 = tu_1 / float3((&isl_15)->wcom_0.w) ;
            float3 dv_4 = pv_1 / float3((&isl_15)->wcom_0.w) ;
            thread float3 lu_1 = _S823;
            thread float3 lv_1 = _S823;
            uint c_20 = (&isl_15)->range_0.x + tid_4;
            for(;;)
            {
                if(c_20 < ((&isl_15)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_angular_0(c_20, _S822, tr_4, dv_4, &lu_1, &lv_1, &kernelContext_38);
                c_20 = c_20 + 256U;
            }
            group_sum3_0(tid_4, &lu_1, &lv_1, &kernelContext_38);
            float3 phi_3 = rows_mul_0((&isl_15)->winv0_0, (&isl_15)->winv1_0, (&isl_15)->winv2_0, lu_1);
            float3 dw_3 = rows_mul_0((&isl_15)->winv0_0, (&isl_15)->winv1_0, (&isl_15)->winv2_0, lv_1);
            uint c_21 = (&isl_15)->range_0.x + tid_4;
            for(;;)
            {
                if(c_21 < ((&isl_15)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_apply_0(c_21, _S822, tr_4, phi_3, dv_4, dw_3, &kernelContext_38);
                c_21 = c_21 + 256U;
            }
            if(!driven_0)
            {
                thread Island_0 _S824 = isl_15;
                drift_rigid_1(&_S824, &rg_13, tr_4, phi_3, dv_4, dw_3);
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        }
        if(_S805)
        {
            _S806 = ((&isl_15)->probes_0.y) > ((&isl_15)->probes_0.x);
        }
        else
        {
            _S806 = false;
        }
        if(_S806)
        {
            thread Island_0 _S825 = isl_15;
            thread Rigid_0 _S826 = rg_13;
            record_probes_0(&_S825, &_S826, k_18, &kernelContext_38);
        }
        uint _S827 = done_1 + 1U;
        if((*(&kernelContext_38)->g_halt_0) != 0U)
        {
            done_1 = _S827;
            break;
        }
        done_1 = _S827;
    }
    thread float3 wsum_0 = float3(work_3, work_err_2, 0.0f);
    thread float3 unused_2 = float3(0.0f) ;
    group_sum3_0(tid_4, &wsum_0, &unused_2, &kernelContext_38);
    if(_S805)
    {
        thread Quat_0 _S828 = (&rg_13)->rot_0;
        float4 _S829 = quat_vec_0(&_S828);
        (&isl_15)->rotation_0 = _S829;
        (&isl_15)->position_0 = float4((&rg_13)->pos_1, 0.0f);
        (&isl_15)->position_err_0 = float4((&rg_13)->pos_err_1, 0.0f);
        (&isl_15)->velocity_0 = float4((&rg_13)->vel_1, 0.0f);
        (&isl_15)->velocity_err_0 = float4((&rg_13)->vel_err_1, 0.0f);
        (&isl_15)->angular_velocity_0 = float4((&rg_13)->w_3, 0.0f);
        (&isl_15)->done_0.x = done_1;
        (&isl_15)->info_0.y = (&isl_15)->info_0.y - done_1;
        if((*(&kernelContext_38)->g_halt_0) != 0U)
        {
            _S804 = contact_island_0;
        }
        else
        {
            _S804 = false;
        }
        if(_S804)
        {
            contact_split_at_0((&isl_15)->info_0.w + done_1, &kernelContext_38);
        }
        float _S830 = wsum_0.x;
        thread float _S831 = (&isl_15)->energy_0.x;
        thread float _S832 = (&isl_15)->energy_0.y;
        comp_add1_0(&_S831, &_S832, _S830);
        (&isl_15)->energy_0.x = _S831;
        (&isl_15)->energy_0.y = _S832 + wsum_0.y;
        (&isl_15)->info_0.w = (&isl_15)->info_0.w + done_1;
        if((*(&kernelContext_38)->g_halt_0) != 0U)
        {
            (&isl_15)->info_0.z = ((&isl_15)->info_0.z) | 1U;
        }
        Island_natural_0 device* _S833 = (&kernelContext_38)->islands_0+_S780;
        _S833->range_0 = packed_uint4(isl_15.range_0) ;
        _S833->info_0 = packed_uint4(isl_15.info_0) ;
        _S833->com_0 = packed_float4(isl_15.com_0) ;
        _S833->inertia0_0 = packed_float4(isl_15.inertia0_0) ;
        _S833->inertia1_0 = packed_float4(isl_15.inertia1_0) ;
        _S833->inertia2_0 = packed_float4(isl_15.inertia2_0) ;
        _S833->inv0_0 = packed_float4(isl_15.inv0_0) ;
        _S833->inv1_0 = packed_float4(isl_15.inv1_0) ;
        _S833->inv2_0 = packed_float4(isl_15.inv2_0) ;
        _S833->wcom_0 = packed_float4(isl_15.wcom_0) ;
        _S833->winv0_0 = packed_float4(isl_15.winv0_0) ;
        _S833->winv1_0 = packed_float4(isl_15.winv1_0) ;
        _S833->winv2_0 = packed_float4(isl_15.winv2_0) ;
        _S833->rotation_0 = packed_float4(isl_15.rotation_0) ;
        _S833->position_0 = packed_float4(isl_15.position_0) ;
        _S833->position_err_0 = packed_float4(isl_15.position_err_0) ;
        _S833->velocity_0 = packed_float4(isl_15.velocity_0) ;
        _S833->velocity_err_0 = packed_float4(isl_15.velocity_err_0) ;
        _S833->angular_velocity_0 = packed_float4(isl_15.angular_velocity_0) ;
        _S833->done_0 = packed_uint4(isl_15.done_0) ;
        _S833->probes_0 = packed_uint4(isl_15.probes_0) ;
        _S833->energy_0 = packed_float4(isl_15.energy_0) ;
    }
    return;
}

struct WideGroup_0
{
    uint island_0;
    uint begin_1;
    uint end_0;
    uint first_0;
};

WideGroup_0 wide_group_0(uint table_0, uint g_2, KernelContext_0 thread* kernelContext_39)
{
    thread WideGroup_0 w_10;
    uint _S834 = table_0 + 4U * g_2;
    (&w_10)->island_0 = kernelContext_39->index_0[_S834];
    (&w_10)->begin_1 = kernelContext_39->index_0[_S834 + 1U];
    (&w_10)->end_0 = kernelContext_39->index_0[_S834 + 2U];
    (&w_10)->first_0 = kernelContext_39->index_0[_S834 + 3U];
    return w_10;
}

bool wide_runs_0(const Island_natural_0 thread* isl_16, KernelContext_0 thread* kernelContext_40)
{
    uint4 _S835 = uint4(isl_16->info_0) ;
    bool _S836;
    if(((_S835.z) & 1U) != 0U)
    {
        _S836 = true;
    }
    else
    {
        _S836 = (_S835.y) == 0U;
    }
    if(_S836)
    {
        return false;
    }
    if(((_S835.x) & 4U) == 0U)
    {
        _S836 = true;
    }
    else
    {
        bool _S837 = contact_stopped_0(isl_16, kernelContext_40);
        _S836 = !_S837;
    }
    return _S836;
}

bool wide_enter_0(uint tid_5, const Island_natural_0 thread* isl_17, KernelContext_0 thread* kernelContext_41)
{
    if(tid_5 == 0U)
    {
        bool _S838 = wide_runs_0(isl_17, kernelContext_41);
        int _S839;
        if(_S838)
        {
            _S839 = int(1);
        }
        else
        {
            _S839 = int(0);
        }
        *kernelContext_41->g_wide_run_0 = uint(_S839);
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    return (*kernelContext_41->g_wide_run_0) != 0U;
}

uint wide_step_0(const Island_natural_0 thread* isl_18, KernelContext_0 thread* kernelContext_42)
{
    return (uint4(isl_18->info_0) ).w - kernelContext_42->params_0->step_start_0;
}

uint wide_step_1(const Island_0 thread* isl_19, KernelContext_0 thread* kernelContext_43)
{
    return isl_19->info_0.w - kernelContext_43->params_0->step_start_0;
}

void wide_store_0(uint slot_2, uint p_6, float3 a_11, float3 b_18, KernelContext_0 thread* kernelContext_44)
{
    uint _S840 = 8U * slot_2;
    *(kernelContext_44->scratch_0+(kernelContext_44->params_0->wide_base_0 + _S840 + p_6)) = packed_float4(float4(a_11, 0.0f)) ;
    *(kernelContext_44->scratch_0+(kernelContext_44->params_0->wide_base_0 + _S840 + p_6 + 1U)) = packed_float4(float4(b_18, 0.0f)) ;
    return;
}

bool contact_stopped_2(uint _S841, KernelContext_0 thread* kernelContext_45)
{
    Island_natural_0 device* _S842 = kernelContext_45->islands_0+_S841;
    uint4 _S843 = uint4((kernelContext_45->islands_0+kernelContext_45->params_0->halt_index_0)->info_0) ;
    bool _S844;
    if(((_S843.z) & 1U) != 0U)
    {
        _S844 = true;
    }
    else
    {
        uint _S845 = _S843.y;
        if(_S845 != 0U)
        {
            _S844 = _S845 <= ((uint4(_S842->info_0) ).w);
        }
        else
        {
            _S844 = false;
        }
    }
    return _S844;
}

bool wide_runs_1(uint _S846, KernelContext_0 thread* kernelContext_46)
{
    uint4 _S847 = uint4((kernelContext_46->islands_0+_S846)->info_0) ;
    bool _S848;
    if(((_S847.z) & 1U) != 0U)
    {
        _S848 = true;
    }
    else
    {
        _S848 = (_S847.y) == 0U;
    }
    if(_S848)
    {
        return false;
    }
    if(((_S847.x) & 4U) == 0U)
    {
        _S848 = true;
    }
    else
    {
        bool _S849 = contact_stopped_2(_S846, kernelContext_46);
        _S848 = !_S849;
    }
    return _S848;
}

bool wide_enter_1(uint _S850, uint _S851, KernelContext_0 thread* kernelContext_47)
{
    if(_S850 == 0U)
    {
        bool _S852 = wide_runs_1(_S851, kernelContext_47);
        int _S853;
        if(_S852)
        {
            _S853 = int(1);
        }
        else
        {
            _S853 = int(0);
        }
        *kernelContext_47->g_wide_run_0 = uint(_S853);
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    return (*kernelContext_47->g_wide_run_0) != 0U;
}

[[kernel]] void wide_bonds(uint3 group_3 [[threadgroup_position_in_grid]], uint3 thread_3 [[thread_position_in_threadgroup]], Params_0 constant* params_7 [[buffer(0)]], Island_natural_0 device* islands_7 [[buffer(9)]], uint device* index_7 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_7 [[buffer(3)]], packed_float4 device* state_9 [[buffer(6)]], packed_float4 device* scratch_7 [[buffer(8)]], packed_float4 device* contact_state_7 [[buffer(11)]], Impactor_natural_0 device* impactors_7 [[buffer(10)]], packed_float4 device* loads_7 [[buffer(5)]], BondStatic_natural_0 device* bonds_7 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_7 [[buffer(7)]], MaterialTable_0 constant* materials_7 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_48;
    (&kernelContext_48)->params_0 = params_7;
    (&kernelContext_48)->islands_0 = islands_7;
    (&kernelContext_48)->index_0 = index_7;
    (&kernelContext_48)->chunks_0 = chunks_7;
    (&kernelContext_48)->state_0 = state_9;
    (&kernelContext_48)->scratch_0 = scratch_7;
    (&kernelContext_48)->contact_state_0 = contact_state_7;
    (&kernelContext_48)->impactors_0 = impactors_7;
    (&kernelContext_48)->loads_0 = loads_7;
    (&kernelContext_48)->bonds_0 = bonds_7;
    (&kernelContext_48)->bond_dyn_0 = bond_dyn_7;
    (&kernelContext_48)->materials_0 = materials_7;
    threadgroup array<float4, int(256)> g_red_a_7;
    (&kernelContext_48)->g_red_a_0 = &g_red_a_7;
    threadgroup array<float4, int(256)> g_red_b_7;
    (&kernelContext_48)->g_red_b_0 = &g_red_b_7;
    threadgroup uint g_run_7;
    (&kernelContext_48)->g_run_0 = &g_run_7;
    threadgroup uint g_halt_7;
    (&kernelContext_48)->g_halt_0 = &g_halt_7;
    threadgroup uint g_wide_run_7;
    (&kernelContext_48)->g_wide_run_0 = &g_wide_run_7;
    uint tid_6 = thread_3.x;
    uint _S854 = group_3.x;
    bool bond_group_0 = _S854 < (params_7->wide_bond_groups_0);
    WideGroup_0 wg_0;
    if(bond_group_0)
    {
        WideGroup_0 _S855 = wide_group_0((&kernelContext_48)->params_0->wide_bond_table_0, _S854, &kernelContext_48);
        wg_0 = _S855;
    }
    else
    {
        WideGroup_0 _S856 = wide_group_0((&kernelContext_48)->params_0->wide_chunk_table_0, _S854 - params_7->wide_bond_groups_0, &kernelContext_48);
        wg_0 = _S856;
    }
    WideGroup_0 _S857 = wg_0;
    thread Island_natural_0 _S858 = *((&kernelContext_48)->islands_0+wg_0.island_0);
    bool _S859 = wide_enter_1(tid_6, wg_0.island_0, &kernelContext_48);
    if(!_S859)
    {
        return;
    }
    uint _S860 = wide_step_0(&_S858, &kernelContext_48);
    if(bond_group_0)
    {
        uint i_10 = wg_0.begin_1 + tid_6;
        bool _S861;
        if(i_10 < (wg_0.end_0))
        {
            bool _S862 = bond_update_0(i_10, (&kernelContext_48)->params_0->dt_0, ((&kernelContext_48)->params_0->fracture_0) != 0U, (uint4((&_S858)->info_0) ).w + 1U, &kernelContext_48);
            _S861 = _S862;
        }
        else
        {
            _S861 = false;
        }
        if(_S861)
        {
            ((&kernelContext_48)->islands_0+_S857.island_0)->info_0[int(2)] = ((uint4((&_S858)->info_0) ).z) | 2U;
        }
        return;
    }
    uint _S863 = (uint4((&_S858)->info_0) ).x;
    if((_S863 & 1U) != 0U)
    {
        return;
    }
    float3 _S864 = float3(0.0f) ;
    thread float3 f_13 = _S864;
    thread float3 t_12 = _S864;
    uint c_22 = wg_0.begin_1 + tid_6;
    if(c_22 < (wg_0.end_0))
    {
        Rigid_0 _S865 = rigid_of_0(&_S858);
        float _S866 = (&kernelContext_48)->params_0->dt_0;
        bool _S867 = (_S863 & 4U) != 0U;
        thread Rigid_0 _S868 = _S865;
        net_load_0(c_22, &_S858, &_S868, _S860, _S866, _S867, &f_13, &t_12, &kernelContext_48);
    }
    group_sum3_0(tid_6, &f_13, &t_12, &kernelContext_48);
    if(tid_6 == 0U)
    {
        wide_store_0(_S854 - params_7->wide_bond_groups_0, 0U, f_13, t_12, &kernelContext_48);
    }
    return;
}

void wide_partials_0(uint tid_7, uint first_1, uint count_5, uint p_7, float3 thread* a_12, float3 thread* b_19, KernelContext_0 thread* kernelContext_49)
{
    float4 _S869 = float4(0.0f) ;
    thread float4 x_7 = _S869;
    thread float4 y_2 = _S869;
    uint s_7 = tid_7;
    for(;;)
    {
        if(s_7 < count_5)
        {
        }
        else
        {
            break;
        }
        uint _S870 = 8U * (first_1 + s_7);
        x_7 = x_7 + float4(*(kernelContext_49->scratch_0+(kernelContext_49->params_0->wide_base_0 + _S870 + p_7))) ;
        y_2 = y_2 + float4(*(kernelContext_49->scratch_0+(kernelContext_49->params_0->wide_base_0 + _S870 + p_7 + 1U))) ;
        s_7 = s_7 + 256U;
    }
    group_sum2_0(tid_7, &x_7, &y_2, kernelContext_49);
    *a_12 = x_7.xyz;
    *b_19 = y_2.xyz;
    return;
}

Rigid_0 wide_rigid_frame_0(uint tid_8, const Island_natural_0 thread* isl_20, const WideGroup_0 thread* wg_1, KernelContext_0 thread* kernelContext_50)
{
    Rigid_0 _S871 = rigid_of_0(isl_20);
    thread Rigid_0 rg_14 = _S871;
    if((((uint4(isl_20->info_0) ).x) & 1U) == 0U)
    {
        thread float3 f_14;
        thread float3 t_13;
        wide_partials_0(tid_8, wg_1->first_0, (uint4(isl_20->done_0) ).z, 0U, &f_14, &t_13, kernelContext_50);
        rigid_acceleration_0(isl_20, &rg_14, f_14, t_13);
    }
    return rg_14;
}

[[kernel]] void wide_chunks(uint3 group_4 [[threadgroup_position_in_grid]], uint3 thread_4 [[thread_position_in_threadgroup]], Params_0 constant* params_8 [[buffer(0)]], Island_natural_0 device* islands_8 [[buffer(9)]], uint device* index_8 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_8 [[buffer(3)]], packed_float4 device* state_10 [[buffer(6)]], packed_float4 device* scratch_8 [[buffer(8)]], packed_float4 device* contact_state_8 [[buffer(11)]], Impactor_natural_0 device* impactors_8 [[buffer(10)]], packed_float4 device* loads_8 [[buffer(5)]], BondStatic_natural_0 device* bonds_8 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_8 [[buffer(7)]], MaterialTable_0 constant* materials_8 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_51;
    (&kernelContext_51)->params_0 = params_8;
    (&kernelContext_51)->islands_0 = islands_8;
    (&kernelContext_51)->index_0 = index_8;
    (&kernelContext_51)->chunks_0 = chunks_8;
    (&kernelContext_51)->state_0 = state_10;
    (&kernelContext_51)->scratch_0 = scratch_8;
    (&kernelContext_51)->contact_state_0 = contact_state_8;
    (&kernelContext_51)->impactors_0 = impactors_8;
    (&kernelContext_51)->loads_0 = loads_8;
    (&kernelContext_51)->bonds_0 = bonds_8;
    (&kernelContext_51)->bond_dyn_0 = bond_dyn_8;
    (&kernelContext_51)->materials_0 = materials_8;
    threadgroup array<float4, int(256)> g_red_a_8;
    (&kernelContext_51)->g_red_a_0 = &g_red_a_8;
    threadgroup array<float4, int(256)> g_red_b_8;
    (&kernelContext_51)->g_red_b_0 = &g_red_b_8;
    threadgroup uint g_run_8;
    (&kernelContext_51)->g_run_0 = &g_run_8;
    threadgroup uint g_halt_8;
    (&kernelContext_51)->g_halt_0 = &g_halt_8;
    threadgroup uint g_wide_run_8;
    (&kernelContext_51)->g_wide_run_0 = &g_wide_run_8;
    uint tid_9 = thread_4.x;
    uint _S872 = group_4.x;
    WideGroup_0 _S873 = wide_group_0(params_8->wide_chunk_table_0, _S872, &kernelContext_51);
    thread Island_natural_0 _S874 = *((&kernelContext_51)->islands_0+_S873.island_0);
    bool _S875 = wide_enter_1(tid_9, _S873.island_0, &kernelContext_51);
    if(!_S875)
    {
        return;
    }
    uint _S876 = (uint4((&_S874)->info_0) ).x;
    bool anchored_0 = (_S876 & 1U) != 0U;
    thread WideGroup_0 _S877 = _S873;
    Rigid_0 _S878 = wide_rigid_frame_0(tid_9, &_S874, &_S877, &kernelContext_51);
    thread float work_4 = 0.0f;
    thread float work_err_3 = 0.0f;
    float3 _S879 = float3(0.0f) ;
    thread float3 tu_2 = _S879;
    thread float3 pv_2 = _S879;
    uint c_23 = _S873.begin_1 + tid_9;
    if(c_23 < (_S873.end_0))
    {
        float _S880 = (&kernelContext_51)->params_0->dt_0;
        bool _S881 = ((&kernelContext_51)->params_0->rigid_motion_loads_0) != 0U;
        uint _S882 = wide_step_0(&_S874, &kernelContext_51);
        bool _S883 = (_S876 & 4U) != 0U;
        thread Rigid_0 _S884 = _S878;
        chunk_update_0(c_23, &_S874, &_S884, _S880, _S881, _S882, _S883, &work_4, &work_err_3, &kernelContext_51);
        if(!anchored_0)
        {
            drift_moments_0(c_23, &tu_2, &pv_2, &kernelContext_51);
        }
    }
    thread float3 wsum_1 = float3(work_4, work_err_3, 0.0f);
    thread float3 unused_3 = _S879;
    group_sum3_0(tid_9, &wsum_1, &unused_3, &kernelContext_51);
    bool _S885 = !anchored_0;
    if(_S885)
    {
        group_sum3_0(tid_9, &tu_2, &pv_2, &kernelContext_51);
    }
    if(tid_9 == 0U)
    {
        *((&kernelContext_51)->scratch_0+((&kernelContext_51)->params_0->wide_base_0 + 8U * _S872 + 6U)) = packed_float4(float4(wsum_1, 0.0f)) ;
        if(_S885)
        {
            wide_store_0(_S872, 2U, tu_2, pv_2, &kernelContext_51);
        }
    }
    return;
}

[[kernel]] void wide_drift(uint3 group_5 [[threadgroup_position_in_grid]], uint3 thread_5 [[thread_position_in_threadgroup]], Params_0 constant* params_9 [[buffer(0)]], Island_natural_0 device* islands_9 [[buffer(9)]], uint device* index_9 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_9 [[buffer(3)]], packed_float4 device* state_11 [[buffer(6)]], packed_float4 device* scratch_9 [[buffer(8)]], packed_float4 device* contact_state_9 [[buffer(11)]], Impactor_natural_0 device* impactors_9 [[buffer(10)]], packed_float4 device* loads_9 [[buffer(5)]], BondStatic_natural_0 device* bonds_9 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_9 [[buffer(7)]], MaterialTable_0 constant* materials_9 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_52;
    (&kernelContext_52)->params_0 = params_9;
    (&kernelContext_52)->islands_0 = islands_9;
    (&kernelContext_52)->index_0 = index_9;
    (&kernelContext_52)->chunks_0 = chunks_9;
    (&kernelContext_52)->state_0 = state_11;
    (&kernelContext_52)->scratch_0 = scratch_9;
    (&kernelContext_52)->contact_state_0 = contact_state_9;
    (&kernelContext_52)->impactors_0 = impactors_9;
    (&kernelContext_52)->loads_0 = loads_9;
    (&kernelContext_52)->bonds_0 = bonds_9;
    (&kernelContext_52)->bond_dyn_0 = bond_dyn_9;
    (&kernelContext_52)->materials_0 = materials_9;
    threadgroup array<float4, int(256)> g_red_a_9;
    (&kernelContext_52)->g_red_a_0 = &g_red_a_9;
    threadgroup array<float4, int(256)> g_red_b_9;
    (&kernelContext_52)->g_red_b_0 = &g_red_b_9;
    threadgroup uint g_run_9;
    (&kernelContext_52)->g_run_0 = &g_run_9;
    threadgroup uint g_halt_9;
    (&kernelContext_52)->g_halt_0 = &g_halt_9;
    threadgroup uint g_wide_run_9;
    (&kernelContext_52)->g_wide_run_0 = &g_wide_run_9;
    uint tid_10 = thread_5.x;
    uint _S886 = group_5.x;
    WideGroup_0 _S887 = wide_group_0(params_9->wide_chunk_table_0, _S886, &kernelContext_52);
    Island_natural_0 device* _S888 = (&kernelContext_52)->islands_0+_S887.island_0;
    Island_natural_0 isl_21 = *_S888;
    bool _S889;
    if((((uint4((*_S888).info_0) ).x) & 1U) != 0U)
    {
        _S889 = true;
    }
    else
    {
        bool _S890 = wide_enter_1(tid_10, _S887.island_0, &kernelContext_52);
        _S889 = !_S890;
    }
    if(_S889)
    {
        return;
    }
    thread float3 tu_3;
    thread float3 pv_3;
    wide_partials_0(tid_10, _S887.first_0, (uint4(isl_21.done_0) ).z, 2U, &tu_3, &pv_3, &kernelContext_52);
    float4 _S891 = float4(isl_21.wcom_0) ;
    float3 _S892 = float3(_S891.w) ;
    float3 tr_5 = tu_3 / _S892;
    float3 dv_5 = pv_3 / _S892;
    float3 _S893 = float3(0.0f) ;
    thread float3 lu_2 = _S893;
    thread float3 lv_2 = _S893;
    uint c_24 = _S887.begin_1 + tid_10;
    if(c_24 < (_S887.end_0))
    {
        drift_angular_0(c_24, _S891.xyz, tr_5, dv_5, &lu_2, &lv_2, &kernelContext_52);
    }
    group_sum3_0(tid_10, &lu_2, &lv_2, &kernelContext_52);
    if(tid_10 == 0U)
    {
        wide_store_0(_S886, 4U, lu_2, lv_2, &kernelContext_52);
    }
    return;
}

[[kernel]] void wide_rigid(uint3 group_6 [[threadgroup_position_in_grid]], uint3 thread_6 [[thread_position_in_threadgroup]], Params_0 constant* params_10 [[buffer(0)]], Island_natural_0 device* islands_10 [[buffer(9)]], uint device* index_10 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_10 [[buffer(3)]], packed_float4 device* state_12 [[buffer(6)]], packed_float4 device* scratch_10 [[buffer(8)]], packed_float4 device* contact_state_10 [[buffer(11)]], Impactor_natural_0 device* impactors_10 [[buffer(10)]], packed_float4 device* loads_10 [[buffer(5)]], BondStatic_natural_0 device* bonds_10 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_10 [[buffer(7)]], MaterialTable_0 constant* materials_10 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_53;
    (&kernelContext_53)->params_0 = params_10;
    (&kernelContext_53)->islands_0 = islands_10;
    (&kernelContext_53)->index_0 = index_10;
    (&kernelContext_53)->chunks_0 = chunks_10;
    (&kernelContext_53)->state_0 = state_12;
    (&kernelContext_53)->scratch_0 = scratch_10;
    (&kernelContext_53)->contact_state_0 = contact_state_10;
    (&kernelContext_53)->impactors_0 = impactors_10;
    (&kernelContext_53)->loads_0 = loads_10;
    (&kernelContext_53)->bonds_0 = bonds_10;
    (&kernelContext_53)->bond_dyn_0 = bond_dyn_10;
    (&kernelContext_53)->materials_0 = materials_10;
    threadgroup array<float4, int(256)> g_red_a_10;
    (&kernelContext_53)->g_red_a_0 = &g_red_a_10;
    threadgroup array<float4, int(256)> g_red_b_10;
    (&kernelContext_53)->g_red_b_0 = &g_red_b_10;
    threadgroup uint g_run_10;
    (&kernelContext_53)->g_run_0 = &g_run_10;
    threadgroup uint g_halt_10;
    (&kernelContext_53)->g_halt_0 = &g_halt_10;
    threadgroup uint g_wide_run_10;
    (&kernelContext_53)->g_wide_run_0 = &g_wide_run_10;
    uint tid_11 = thread_6.x;
    uint _S894 = group_6.x;
    WideGroup_0 _S895 = wide_group_0(params_10->wide_chunk_table_0, _S894, &kernelContext_53);
    thread Island_natural_0 _S896 = *((&kernelContext_53)->islands_0+_S895.island_0);
    uint _S897 = (uint4((&_S896)->info_0) ).x;
    bool _S898;
    if((_S897 & 1U) != 0U)
    {
        _S898 = true;
    }
    else
    {
        bool _S899 = wide_enter_1(tid_11, _S895.island_0, &kernelContext_53);
        _S898 = !_S899;
    }
    if(_S898)
    {
        return;
    }
    uint _S900 = (uint4((&_S896)->done_0) ).z;
    thread float3 tu_4;
    thread float3 pv_4;
    wide_partials_0(tid_11, _S895.first_0, _S900, 2U, &tu_4, &pv_4, &kernelContext_53);
    thread float3 lu_3;
    thread float3 lv_3;
    wide_partials_0(tid_11, _S895.first_0, _S900, 4U, &lu_3, &lv_3, &kernelContext_53);
    float4 _S901 = float4((&_S896)->wcom_0) ;
    float3 _S902 = float3(_S901.w) ;
    float3 tr_6 = tu_4 / _S902;
    float3 dv_6 = pv_4 / _S902;
    float4 _S903 = float4((&_S896)->winv0_0) ;
    float4 _S904 = float4((&_S896)->winv1_0) ;
    float4 _S905 = float4((&_S896)->winv2_0) ;
    float3 phi_4 = rows_mul_0(_S903, _S904, _S905, lu_3);
    float3 dw_4 = rows_mul_0(_S903, _S904, _S905, lv_3);
    uint c_25 = _S895.begin_1 + tid_11;
    if(c_25 < (_S895.end_0))
    {
        drift_apply_0(c_25, _S901.xyz, tr_6, phi_4, dv_6, dw_4, &kernelContext_53);
    }
    if(_S894 != (_S895.first_0))
    {
        return;
    }
    thread WideGroup_0 _S906 = _S895;
    Rigid_0 _S907 = wide_rigid_frame_0(tid_11, &_S896, &_S906, &kernelContext_53);
    thread Rigid_0 rg_15 = _S907;
    if(tid_11 != 0U)
    {
        return;
    }
    if(!((_S897 & 2U) != 0U))
    {
        integrate_rigid_0(&_S896, &rg_15, (&kernelContext_53)->params_0->dt_0);
        drift_rigid_0(&_S896, &rg_15, tr_6, phi_4, dv_6, dw_4);
    }
    thread Quat_0 _S908 = (&rg_15)->rot_0;
    float4 _S909 = quat_vec_0(&_S908);
    ((&kernelContext_53)->islands_0+_S895.island_0)->rotation_0 = packed_float4(_S909) ;
    ((&kernelContext_53)->islands_0+_S895.island_0)->position_0 = packed_float4(float4((&rg_15)->pos_1, 0.0f)) ;
    ((&kernelContext_53)->islands_0+_S895.island_0)->position_err_0 = packed_float4(float4((&rg_15)->pos_err_1, 0.0f)) ;
    ((&kernelContext_53)->islands_0+_S895.island_0)->velocity_0 = packed_float4(float4((&rg_15)->vel_1, 0.0f)) ;
    ((&kernelContext_53)->islands_0+_S895.island_0)->velocity_err_0 = packed_float4(float4((&rg_15)->vel_err_1, 0.0f)) ;
    ((&kernelContext_53)->islands_0+_S895.island_0)->angular_velocity_0 = packed_float4(float4((&rg_15)->w_3, 0.0f)) ;
    return;
}

[[kernel]] void wide_end(uint3 group_7 [[threadgroup_position_in_grid]], uint3 thread_7 [[thread_position_in_threadgroup]], Params_0 constant* params_11 [[buffer(0)]], Island_natural_0 device* islands_11 [[buffer(9)]], uint device* index_11 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_11 [[buffer(3)]], packed_float4 device* state_13 [[buffer(6)]], packed_float4 device* scratch_11 [[buffer(8)]], packed_float4 device* contact_state_11 [[buffer(11)]], Impactor_natural_0 device* impactors_11 [[buffer(10)]], packed_float4 device* loads_11 [[buffer(5)]], BondStatic_natural_0 device* bonds_11 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_11 [[buffer(7)]], MaterialTable_0 constant* materials_11 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_54;
    (&kernelContext_54)->params_0 = params_11;
    (&kernelContext_54)->islands_0 = islands_11;
    (&kernelContext_54)->index_0 = index_11;
    (&kernelContext_54)->chunks_0 = chunks_11;
    (&kernelContext_54)->state_0 = state_13;
    (&kernelContext_54)->scratch_0 = scratch_11;
    (&kernelContext_54)->contact_state_0 = contact_state_11;
    (&kernelContext_54)->impactors_0 = impactors_11;
    (&kernelContext_54)->loads_0 = loads_11;
    (&kernelContext_54)->bonds_0 = bonds_11;
    (&kernelContext_54)->bond_dyn_0 = bond_dyn_11;
    (&kernelContext_54)->materials_0 = materials_11;
    threadgroup array<float4, int(256)> g_red_a_11;
    (&kernelContext_54)->g_red_a_0 = &g_red_a_11;
    threadgroup array<float4, int(256)> g_red_b_11;
    (&kernelContext_54)->g_red_b_0 = &g_red_b_11;
    threadgroup uint g_run_11;
    (&kernelContext_54)->g_run_0 = &g_run_11;
    threadgroup uint g_halt_11;
    (&kernelContext_54)->g_halt_0 = &g_halt_11;
    threadgroup uint g_wide_run_11;
    (&kernelContext_54)->g_wide_run_0 = &g_wide_run_11;
    uint tid_12 = thread_7.x;
    uint _S910 = group_7.x;
    WideGroup_0 _S911 = wide_group_0(params_11->wide_chunk_table_0, _S910, &kernelContext_54);
    if(_S910 != (_S911.first_0))
    {
        return;
    }
    Island_natural_0 device* _S912 = (&kernelContext_54)->islands_0+_S911.island_0;
    thread Island_natural_0 _S913 = *_S912;
    uint4 _S914 = uint4((&_S913)->info_0) ;
    float4 _S915 = float4((&_S913)->com_0) ;
    float4 _S916 = float4((&_S913)->inertia0_0) ;
    float4 _S917 = float4((&_S913)->inertia1_0) ;
    float4 _S918 = float4((&_S913)->inertia2_0) ;
    float4 _S919 = float4((&_S913)->inv0_0) ;
    float4 _S920 = float4((&_S913)->inv1_0) ;
    float4 _S921 = float4((&_S913)->inv2_0) ;
    float4 _S922 = float4((&_S913)->wcom_0) ;
    float4 _S923 = float4((&_S913)->winv0_0) ;
    float4 _S924 = float4((&_S913)->winv1_0) ;
    float4 _S925 = float4((&_S913)->winv2_0) ;
    float4 _S926 = float4((&_S913)->rotation_0) ;
    float4 _S927 = float4((&_S913)->position_0) ;
    float4 _S928 = float4((&_S913)->position_err_0) ;
    float4 _S929 = float4((&_S913)->velocity_0) ;
    float4 _S930 = float4((&_S913)->velocity_err_0) ;
    float4 _S931 = float4((&_S913)->angular_velocity_0) ;
    uint4 _S932 = uint4((&_S913)->done_0) ;
    uint4 _S933 = uint4((&_S913)->probes_0) ;
    float4 _S934 = float4((&_S913)->energy_0) ;
    thread Island_0 isl_22;
    (&isl_22)->range_0 = uint4((&_S913)->range_0) ;
    (&isl_22)->info_0 = _S914;
    (&isl_22)->com_0 = _S915;
    (&isl_22)->inertia0_0 = _S916;
    (&isl_22)->inertia1_0 = _S917;
    (&isl_22)->inertia2_0 = _S918;
    (&isl_22)->inv0_0 = _S919;
    (&isl_22)->inv1_0 = _S920;
    (&isl_22)->inv2_0 = _S921;
    (&isl_22)->wcom_0 = _S922;
    (&isl_22)->winv0_0 = _S923;
    (&isl_22)->winv1_0 = _S924;
    (&isl_22)->winv2_0 = _S925;
    (&isl_22)->rotation_0 = _S926;
    (&isl_22)->position_0 = _S927;
    (&isl_22)->position_err_0 = _S928;
    (&isl_22)->velocity_0 = _S929;
    (&isl_22)->velocity_err_0 = _S930;
    (&isl_22)->angular_velocity_0 = _S931;
    (&isl_22)->done_0 = _S932;
    (&isl_22)->probes_0 = _S933;
    (&isl_22)->energy_0 = _S934;
    _S913 = *_S912;
    bool _S935 = wide_enter_0(tid_12, &_S913, &kernelContext_54);
    if(!_S935)
    {
        return;
    }
    thread float3 work_5;
    thread float3 unused_4;
    wide_partials_0(tid_12, _S911.first_0, (&isl_22)->done_0.z, 6U, &work_5, &unused_4, &kernelContext_54);
    if(tid_12 != 0U)
    {
        return;
    }
    thread Island_0 _S936 = isl_22;
    uint _S937 = wide_step_1(&_S936, &kernelContext_54);
    if(((&isl_22)->probes_0.y) > ((&isl_22)->probes_0.x))
    {
        thread Island_0 _S938 = isl_22;
        Rigid_0 _S939 = rigid_of_1(&_S938);
        thread Island_0 _S940 = isl_22;
        thread Rigid_0 _S941 = _S939;
        record_probes_0(&_S940, &_S941, _S937, &kernelContext_54);
    }
    bool halt_0 = (((&isl_22)->info_0.z) & 2U) != 0U;
    bool _S942;
    if(halt_0)
    {
        _S942 = (((&isl_22)->info_0.x) & 4U) != 0U;
    }
    else
    {
        _S942 = false;
    }
    if(_S942)
    {
        contact_split_at_0((&isl_22)->info_0.w + 1U, &kernelContext_54);
    }
    float _S943 = work_5.x;
    thread float _S944 = (&isl_22)->energy_0.x;
    thread float _S945 = (&isl_22)->energy_0.y;
    comp_add1_0(&_S944, &_S945, _S943);
    (&isl_22)->energy_0.x = _S944;
    (&isl_22)->energy_0.y = _S945 + work_5.y;
    (&isl_22)->done_0.x = (&isl_22)->done_0.x + 1U;
    (&isl_22)->info_0.y = (&isl_22)->info_0.y - 1U;
    (&isl_22)->info_0.w = (&isl_22)->info_0.w + 1U;
    if(halt_0)
    {
        (&isl_22)->info_0.z = (((&isl_22)->info_0.z) & 4294967293U) | 1U;
    }
    Island_natural_0 device* _S946 = (&kernelContext_54)->islands_0+_S911.island_0;
    _S946->range_0 = packed_uint4(isl_22.range_0) ;
    _S946->info_0 = packed_uint4(isl_22.info_0) ;
    _S946->com_0 = packed_float4(isl_22.com_0) ;
    _S946->inertia0_0 = packed_float4(isl_22.inertia0_0) ;
    _S946->inertia1_0 = packed_float4(isl_22.inertia1_0) ;
    _S946->inertia2_0 = packed_float4(isl_22.inertia2_0) ;
    _S946->inv0_0 = packed_float4(isl_22.inv0_0) ;
    _S946->inv1_0 = packed_float4(isl_22.inv1_0) ;
    _S946->inv2_0 = packed_float4(isl_22.inv2_0) ;
    _S946->wcom_0 = packed_float4(isl_22.wcom_0) ;
    _S946->winv0_0 = packed_float4(isl_22.winv0_0) ;
    _S946->winv1_0 = packed_float4(isl_22.winv1_0) ;
    _S946->winv2_0 = packed_float4(isl_22.winv2_0) ;
    _S946->rotation_0 = packed_float4(isl_22.rotation_0) ;
    _S946->position_0 = packed_float4(isl_22.position_0) ;
    _S946->position_err_0 = packed_float4(isl_22.position_err_0) ;
    _S946->velocity_0 = packed_float4(isl_22.velocity_0) ;
    _S946->velocity_err_0 = packed_float4(isl_22.velocity_err_0) ;
    _S946->angular_velocity_0 = packed_float4(isl_22.angular_velocity_0) ;
    _S946->done_0 = packed_uint4(isl_22.done_0) ;
    _S946->probes_0 = packed_uint4(isl_22.probes_0) ;
    _S946->energy_0 = packed_float4(isl_22.energy_0) ;
    return;
}

