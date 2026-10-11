#include <metal_stdlib>
#include <metal_math>
#include <metal_texture>
using namespace metal;
constant array<float, int(6)> SPRING_AT_0 = { { -0.4166666567325592f, -0.25f, -0.0833333358168602f, 0.0833333358168602f, 0.25f, 0.4166666567325592f } };
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
    uint solve_mode_0;
    uint cload_base_0;
    uint cframe_base_0;
    uint statics_base_0;
    uint statics_bonds_0;
    uint statics_newton_0;
    uint statics_cg_0;
    float statics_tol_0;
    uint pair_lanes_0;
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
    uint done_0;
    uint coverage_0;
    uint wide_groups_0;
    uint done_pad_0;
    packed_uint4 probes_0;
    packed_float4 energy_0;
    packed_float4 rotation_err_0;
    packed_float4 momentum_0;
    packed_float4 momentum_err_0;
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
    packed_float4 start_rot_0;
    packed_float4 start_vel_0;
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
    packed_float4 rotation_err_1;
    packed_float4 ledger_0;
    packed_uint4 cand_0;
    packed_float4 momentum_1;
    packed_float4 momentum_err_1;
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

struct JointState_0
{
    float damage_0;
    float crush_1;
    float kappa_0;
    float kappa_c_0;
    float ductility_0;
    float ductility_c_0;
    float life_0;
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

struct KernelContext_0
{
    Params_0 constant* params_0;
    Island_natural_0 device* islands_0;
    uint device* index_0;
    ChunkStatic_natural_0 device* chunks_0;
    packed_float4 device* state_0;
    packed_float4 device* scratch_0;
    packed_float4 device* contact_state_0;
    packed_float4 device* loads_0;
    Impactor_natural_0 device* impactors_0;
    BondStatic_natural_0 device* bonds_0;
    MaterialTable_0 constant* materials_0;
    BondDyn_natural_0 device* bond_dyn_0;
    array<float4, int(32)> threadgroup* g_part_a_0;
    array<float4, int(32)> threadgroup* g_part_b_0;
    array<uint, int(5)> threadgroup* g_seen_0;
    uint threadgroup* g_wide_run_0;
    uint threadgroup* g_halt_0;
    uint threadgroup* g_run_0;
};

void group_sum2_0(uint tid_0, float4 thread* a_0, float4 thread* b_0, KernelContext_0 thread* kernelContext_0)
{
    float4 wa_0 = simd_sum(*a_0);
    float4 wb_0 = simd_sum(*b_0);
    if((tid_0 % 32U) == 0U)
    {
        (*kernelContext_0->g_part_a_0)[tid_0 / 32U] = wa_0;
        (*kernelContext_0->g_part_b_0)[tid_0 / 32U] = wb_0;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    float4 _S1 = (*kernelContext_0->g_part_a_0)[int(0)];
    float4 _S2 = (*kernelContext_0->g_part_b_0)[int(0)];
    uint w_0 = 1U;
    float4 sa_0 = _S1;
    float4 sb_0 = _S2;
    for(;;)
    {
        if(w_0 < 8U)
        {
        }
        else
        {
            break;
        }
        float4 sa_1 = sa_0 + (*kernelContext_0->g_part_a_0)[w_0];
        float4 sb_1 = sb_0 + (*kernelContext_0->g_part_b_0)[w_0];
        w_0 = w_0 + 1U;
        sa_0 = sa_1;
        sb_0 = sb_1;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    *a_0 = sa_0;
    *b_0 = sb_0;
    return;
}

void group_sum3_0(uint tid_1, float3 thread* a_1, float3 thread* b_1, KernelContext_0 thread* kernelContext_1)
{
    thread float4 x_0 = float4(*a_1, 0.0f);
    thread float4 y_0 = float4(*b_1, 0.0f);
    group_sum2_0(tid_1, &x_0, &y_0, kernelContext_1);
    *a_1 = x_0.xyz;
    *b_1 = y_0.xyz;
    return;
}

uint pair_lane_count_0(KernelContext_0 thread* kernelContext_2)
{
    return max(kernelContext_2->params_0->pair_lanes_0, 1U);
}

bool stopped_0(KernelContext_0 thread* kernelContext_3)
{
    uint4 _S3 = uint4((kernelContext_3->islands_0+kernelContext_3->params_0->halt_index_0)->info_0) ;
    bool _S4;
    if(((_S3.z) & 1U) != 0U)
    {
        _S4 = true;
    }
    else
    {
        _S4 = (_S3.y) != 0U;
    }
    return _S4;
}

bool pair_any_0(bool x_1, uint lanes_0)
{
    bool _S5;
    if(lanes_0 > 1U)
    {
        bool _S6 = simd_any(x_1);
        _S5 = _S6;
    }
    else
    {
        _S5 = x_1;
    }
    return _S5;
}

struct Quat_0
{
    float w_1;
    float x_2;
    float y_1;
    float z_0;
};

Quat_0 quat_of_0(float4 q_0)
{
    thread Quat_0 r_0;
    (&r_0)->x_2 = q_0.x;
    (&r_0)->y_1 = q_0.y;
    (&r_0)->z_0 = q_0.z;
    (&r_0)->w_1 = q_0.w;
    return r_0;
}

float3 rotate_0(const Quat_0 thread* q_1, float3 v_0)
{
    float3 qv_0 = float3(q_1->x_2, q_1->y_1, q_1->z_0);
    float3 t_0 = cross(qv_0, v_0) * float3(2.0f) ;
    return v_0 + t_0 * float3(q_1->w_1)  + cross(qv_0, t_0);
}

float3 rotate_1(const Quat_0 thread* q_2, float3 v_1)
{
    float3 qv_1 = float3(q_2->x_2, q_2->y_1, q_2->z_0);
    float3 t_1 = cross(qv_1, v_1) * float3(2.0f) ;
    return v_1 + t_1 * float3(q_2->w_1)  + cross(qv_1, t_1);
}

struct WorldPoint_0
{
    float3 hi_0;
    float3 lo_0;
    float3 rel_0;
};

WorldPoint_0 chunk_world_0(uint c_0, KernelContext_0 thread* kernelContext_4)
{
    ChunkStatic_natural_0 device* _S7 = kernelContext_4->chunks_0+c_0;
    Island_natural_0 device* _S8 = kernelContext_4->islands_0+(uint4(_S7->info_1) ).y;
    Quat_0 q_3 = quat_of_0(float4(_S8->rotation_0) );
    thread WorldPoint_0 w_2;
    (&w_2)->hi_0 = (float4(_S8->position_0) ).xyz;
    (&w_2)->lo_0 = (float4(_S8->position_err_0) ).xyz;
    float3 _S9 = (float4(_S7->center_0) ).xyz + (float4(*(kernelContext_4->state_0+4U * c_0)) ).xyz;
    thread Quat_0 _S10 = q_3;
    float3 _S11 = rotate_0(&_S10, _S9);
    (&w_2)->rel_0 = _S11;
    return w_2;
}

float3 world_diff_0(const WorldPoint_0 thread* a_2, const WorldPoint_0 thread* b_2)
{
    return a_2->hi_0 - b_2->hi_0 + (a_2->lo_0 - b_2->lo_0) + (a_2->rel_0 - b_2->rel_0);
}

float3 safe_normalize_0(float3 v_2)
{
    float n_0 = length(v_2);
    float3 _S12;
    if(n_0 > 1.00000000317107685e-30f)
    {
        _S12 = v_2 / float3(n_0) ;
    }
    else
    {
        _S12 = float3(0.0f) ;
    }
    return _S12;
}

Quat_0 from_axis_angle_0(float3 axis_0, float angle_0)
{
    float3 a_3 = safe_normalize_0(axis_0);
    float _S13 = 0.5f * angle_0;
    float s_0 = sin(_S13);
    thread Quat_0 q_4;
    (&q_4)->w_1 = cos(_S13);
    (&q_4)->x_2 = a_3.x * s_0;
    (&q_4)->y_1 = a_3.y * s_0;
    (&q_4)->z_0 = a_3.z * s_0;
    return q_4;
}

struct Box_0
{
    float3 center_1;
    float3 axis0_0;
    float3 axis1_0;
    float3 axis2_0;
    float3 half_2;
    uint hull_at_0;
    uint hull_v_0;
    uint hull_f_0;
};

Box_0 chunk_box_0(uint c_1, float3 center_2, KernelContext_0 thread* kernelContext_5)
{
    ChunkStatic_natural_0 device* _S14 = kernelContext_5->chunks_0+c_1;
    Quat_0 q_5 = quat_of_0(float4((kernelContext_5->islands_0+(uint4(_S14->info_1) ).y)->rotation_0) );
    float3 th_0 = (float4(*(kernelContext_5->state_0+(4U * c_1 + 1U))) ).xyz;
    Quat_0 hidden_0 = from_axis_angle_0(th_0, length(th_0));
    thread Box_0 b_3;
    (&b_3)->center_1 = center_2;
    float4 _S15 = float4(_S14->crot0_0) ;
    float4 _S16 = float4(_S14->crot1_0) ;
    float4 _S17 = float4(_S14->crot2_0) ;
    float3 _S18 = float3(_S15.x, _S16.x, _S17.x);
    thread Quat_0 _S19 = hidden_0;
    float3 _S20 = rotate_0(&_S19, _S18);
    thread Quat_0 _S21 = q_5;
    float3 _S22 = rotate_0(&_S21, _S20);
    (&b_3)->axis0_0 = _S22;
    float3 _S23 = float3(_S15.y, _S16.y, _S17.y);
    thread Quat_0 _S24 = hidden_0;
    float3 _S25 = rotate_0(&_S24, _S23);
    thread Quat_0 _S26 = q_5;
    float3 _S27 = rotate_0(&_S26, _S25);
    (&b_3)->axis1_0 = _S27;
    float3 _S28 = float3(_S15.z, _S16.z, _S17.z);
    thread Quat_0 _S29 = hidden_0;
    float3 _S30 = rotate_0(&_S29, _S28);
    thread Quat_0 _S31 = q_5;
    float3 _S32 = rotate_0(&_S31, _S30);
    (&b_3)->axis2_0 = _S32;
    (&b_3)->half_2 = (float4(_S14->half_0) ).xyz;
    float4 _S33 = float4(_S14->cmat_0) ;
    (&b_3)->hull_at_0 = (as_type<uint>((_S33.z)));
    uint _S34 = (as_type<uint>((_S33.w)));
    (&b_3)->hull_v_0 = _S34 & 255U;
    (&b_3)->hull_f_0 = _S34 >> 8U;
    return b_3;
}

uint sample_count_0(const Box_0 thread* b_4)
{
    uint _S35 = b_4->hull_v_0;
    uint _S36;
    if((b_4->hull_v_0) == 0U)
    {
        _S36 = 14U;
    }
    else
    {
        _S36 = _S35 + b_4->hull_f_0;
    }
    return _S36;
}

bool may_overlap_0(const Box_0 thread* a_4, const Box_0 thread* b_5)
{
    float3 _S37 = b_5->center_1 - a_4->center_1;
    float3 _S38 = a_4->half_2;
    float3 _S39 = b_5->half_2;
    float _S40 = 0.00000999999974738f * (length(a_4->half_2) + length(b_5->half_2));
    float3 _S41 = a_4->axis0_0;
    float3 _S42 = a_4->axis1_0;
    float3 _S43 = a_4->axis2_0;
    float3 _S44 = b_5->axis0_0;
    float3 _S45 = b_5->axis1_0;
    float3 _S46 = b_5->axis2_0;
    array<float3, int(6)> _S47 = { { a_4->axis0_0, a_4->axis1_0, a_4->axis2_0, b_5->axis0_0, b_5->axis1_0, b_5->axis2_0 } };
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
            l_0 = _S47[i_0];
        }
        else
        {
            uint _S48 = i_0 - 6U;
            l_0 = cross(_S47[_S48 / 3U], _S47[3U + _S48 % 3U]);
        }
        float len_0 = length(l_0);
        if(len_0 <= 9.99999997475242708e-07f)
        {
            i_0 = i_0 + 1U;
            continue;
        }
        if((abs(dot(_S37, l_0))) > (_S38.x * abs(dot(_S41, l_0)) + _S38.y * abs(dot(_S42, l_0)) + _S38.z * abs(dot(_S43, l_0)) + (_S39.x * abs(dot(_S44, l_0)) + _S39.y * abs(dot(_S45, l_0)) + _S39.z * abs(dot(_S46, l_0))) + _S40 * len_0))
        {
            return false;
        }
        i_0 = i_0 + 1U;
    }
    return true;
}

void chunk_velocity_0(uint c_2, float3 thread* v_3, float3 thread* w_3, KernelContext_0 thread* kernelContext_6)
{
    ChunkStatic_natural_0 device* _S49 = kernelContext_6->chunks_0+c_2;
    Island_natural_0 device* _S50 = kernelContext_6->islands_0+(uint4(_S49->info_1) ).y;
    Quat_0 q_6 = quat_of_0(float4(_S50->rotation_0) );
    uint _S51 = 4U * c_2;
    float3 _S52 = (float4(_S49->center_0) ).xyz + (float4(*(kernelContext_6->state_0+_S51)) ).xyz - (float4(_S50->com_0) ).xyz;
    thread Quat_0 _S53 = q_6;
    float3 _S54 = rotate_0(&_S53, _S52);
    float3 _S55 = (float4(_S50->angular_velocity_0) ).xyz;
    float3 _S56 = (float4(_S50->velocity_0) ).xyz + (float4(_S50->velocity_err_0) ).xyz + cross(_S55, _S54);
    float3 _S57 = (float4(*(kernelContext_6->state_0+(_S51 + 2U))) ).xyz;
    thread Quat_0 _S58 = q_6;
    float3 _S59 = rotate_0(&_S58, _S57);
    *v_3 = _S56 + _S59;
    float3 _S60 = (float4(*(kernelContext_6->state_0+(_S51 + 3U))) ).xyz;
    thread Quat_0 _S61 = q_6;
    float3 _S62 = rotate_0(&_S61, _S60);
    *w_3 = _S55 + _S62;
    return;
}

float3 box_to_world_0(const Box_0 thread* b_6, float3 local_0)
{
    return b_6->axis0_0 * float3(local_0.x)  + b_6->axis1_0 * float3(local_0.y)  + b_6->axis2_0 * float3(local_0.z) ;
}

float3 box_axis_0(const Box_0 thread* b_7, uint k_0)
{
    float3 _S63;
    if(k_0 == 0U)
    {
        _S63 = b_7->axis0_0;
    }
    else
    {
        if(k_0 == 1U)
        {
            _S63 = b_7->axis1_0;
        }
        else
        {
            _S63 = b_7->axis2_0;
        }
    }
    return _S63;
}

float comp3_0(float3 v_4, uint k_1)
{
    float _S64;
    if(k_1 == 0U)
    {
        _S64 = v_4.x;
    }
    else
    {
        if(k_1 == 1U)
        {
            _S64 = v_4.y;
        }
        else
        {
            _S64 = v_4.z;
        }
    }
    return _S64;
}

float3 sample_point_0(const Box_0 thread* b_8, uint i_1, KernelContext_0 thread* kernelContext_7)
{
    uint _S65 = b_8->hull_v_0;
    if((b_8->hull_v_0) != 0U)
    {
        float3 local_1;
        if(i_1 < _S65)
        {
            local_1 = (float4(*(kernelContext_7->loads_0+(b_8->hull_at_0 + i_1))) ).xyz * float3(0.89999997615814209f) ;
        }
        else
        {
            local_1 = (float4(*(kernelContext_7->loads_0+(b_8->hull_at_0 + _S65 + b_8->hull_f_0 + (i_1 - _S65)))) ).xyz;
        }
        float3 _S66 = b_8->center_1;
        float3 _S67 = box_to_world_0(b_8, local_1);
        return _S66 + _S67;
    }
    float sign_0;
    if(i_1 < 8U)
    {
        float3 h_0 = b_8->half_2 * float3(0.89999997615814209f) ;
        if((i_1 & 1U) == 0U)
        {
            sign_0 = - h_0.x;
        }
        else
        {
            sign_0 = h_0.x;
        }
        float _S68;
        if((i_1 & 2U) == 0U)
        {
            _S68 = - h_0.y;
        }
        else
        {
            _S68 = h_0.y;
        }
        float _S69;
        if((i_1 & 4U) == 0U)
        {
            _S69 = - h_0.z;
        }
        else
        {
            _S69 = h_0.z;
        }
        return b_8->center_1 + b_8->axis0_0 * float3(sign_0)  + b_8->axis1_0 * float3(_S68)  + b_8->axis2_0 * float3(_S69) ;
    }
    uint _S70 = i_1 - 8U;
    uint axis_1 = _S70 / 2U;
    if((_S70 % 2U) == 0U)
    {
        sign_0 = -1.0f;
    }
    else
    {
        sign_0 = 1.0f;
    }
    float3 _S71 = b_8->center_1;
    float3 _S72 = box_axis_0(b_8, axis_1);
    return _S71 + _S72 * float3((sign_0 * comp3_0(b_8->half_2, axis_1))) ;
}

float3 sample_point_1(const Box_0 thread* b_9, uint i_2, KernelContext_0 thread* kernelContext_8)
{
    uint _S73 = b_9->hull_v_0;
    if((b_9->hull_v_0) != 0U)
    {
        float3 local_2;
        if(i_2 < _S73)
        {
            local_2 = (float4(*(kernelContext_8->loads_0+(b_9->hull_at_0 + i_2))) ).xyz * float3(0.89999997615814209f) ;
        }
        else
        {
            local_2 = (float4(*(kernelContext_8->loads_0+(b_9->hull_at_0 + _S73 + b_9->hull_f_0 + (i_2 - _S73)))) ).xyz;
        }
        float3 _S74 = b_9->center_1;
        float3 _S75 = box_to_world_0(b_9, local_2);
        return _S74 + _S75;
    }
    float sign_1;
    if(i_2 < 8U)
    {
        float3 h_1 = b_9->half_2 * float3(0.89999997615814209f) ;
        if((i_2 & 1U) == 0U)
        {
            sign_1 = - h_1.x;
        }
        else
        {
            sign_1 = h_1.x;
        }
        float _S76;
        if((i_2 & 2U) == 0U)
        {
            _S76 = - h_1.y;
        }
        else
        {
            _S76 = h_1.y;
        }
        float _S77;
        if((i_2 & 4U) == 0U)
        {
            _S77 = - h_1.z;
        }
        else
        {
            _S77 = h_1.z;
        }
        return b_9->center_1 + b_9->axis0_0 * float3(sign_1)  + b_9->axis1_0 * float3(_S76)  + b_9->axis2_0 * float3(_S77) ;
    }
    uint _S78 = i_2 - 8U;
    uint axis_2 = _S78 / 2U;
    if((_S78 % 2U) == 0U)
    {
        sign_1 = -1.0f;
    }
    else
    {
        sign_1 = 1.0f;
    }
    float3 _S79 = b_9->center_1;
    float3 _S80 = box_axis_0(b_9, axis_2);
    return _S79 + _S80 * float3((sign_1 * comp3_0(b_9->half_2, axis_2))) ;
}

float3 box_to_local_0(const Box_0 thread* b_10, float3 r_1)
{
    return float3(dot(r_1, b_10->axis0_0), dot(r_1, b_10->axis1_0), dot(r_1, b_10->axis2_0));
}

float hull_signed_distance_0(const Box_0 thread* b_11, float3 local_3, uint thread* face_0, KernelContext_0 thread* kernelContext_9)
{
    *face_0 = 0U;
    float best_0 = -1.00000001504746622e+30f;
    uint f_0 = 0U;
    for(;;)
    {
        if(f_0 < (b_11->hull_f_0))
        {
        }
        else
        {
            break;
        }
        float4 _S81 = float4(*(kernelContext_9->loads_0+(b_11->hull_at_0 + b_11->hull_v_0 + f_0))) ;
        float d_0 = dot(_S81.xyz, local_3) - _S81.w;
        if(d_0 > best_0)
        {
            *face_0 = f_0;
            best_0 = d_0;
        }
        f_0 = f_0 + 1U;
    }
    return best_0;
}

bool penetration_0(const Box_0 thread* b_12, float3 p_0, float thread* depth_0, float3 thread* normal_1, KernelContext_0 thread* kernelContext_10)
{
    *depth_0 = 0.0f;
    *normal_1 = float3(0.0f) ;
    float3 r_2 = p_0 - b_12->center_1;
    float3 _S82 = b_12->half_2;
    if((dot(r_2, r_2)) > (dot(b_12->half_2, b_12->half_2) * 1.00001001358032227f))
    {
        return false;
    }
    uint _S83 = b_12->hull_v_0;
    if((b_12->hull_v_0) != 0U)
    {
        float3 _S84 = box_to_local_0(b_12, r_2);
        thread uint face_1;
        float _S85 = hull_signed_distance_0(b_12, _S84, &face_1, kernelContext_10);
        if(!(_S85 < 0.0f))
        {
            return false;
        }
        *depth_0 = - _S85;
        float3 _S86 = box_to_world_0(b_12, (float4(*(kernelContext_10->loads_0+(b_12->hull_at_0 + _S83 + face_1))) ).xyz);
        *normal_1 = _S86;
        return true;
    }
    float best_1 = 1.00000001504746622e+30f;
    uint axis_3 = 0U;
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
        float3 _S87 = box_axis_0(b_12, k_2);
        float local_4 = dot(r_2, _S87);
        float d_1 = comp3_0(_S82, k_2) - abs(local_4);
        if(d_1 <= 0.0f)
        {
            return false;
        }
        if(d_1 < best_1)
        {
            float _S88;
            if(local_4 >= 0.0f)
            {
                _S88 = 1.0f;
            }
            else
            {
                _S88 = -1.0f;
            }
            best_1 = d_1;
            axis_3 = k_2;
            side_0 = _S88;
        }
        k_2 = k_2 + 1U;
    }
    *depth_0 = best_1;
    float3 _S89 = box_axis_0(b_12, axis_3);
    *normal_1 = _S89 * float3(side_0) ;
    return true;
}

bool penetration_1(const Box_0 thread* b_13, float3 p_1, float thread* depth_1, float3 thread* normal_2, KernelContext_0 thread* kernelContext_11)
{
    *depth_1 = 0.0f;
    *normal_2 = float3(0.0f) ;
    float3 r_3 = p_1 - b_13->center_1;
    float3 _S90 = b_13->half_2;
    if((dot(r_3, r_3)) > (dot(b_13->half_2, b_13->half_2) * 1.00001001358032227f))
    {
        return false;
    }
    uint _S91 = b_13->hull_v_0;
    if((b_13->hull_v_0) != 0U)
    {
        float3 _S92 = box_to_local_0(b_13, r_3);
        thread uint face_2;
        float _S93 = hull_signed_distance_0(b_13, _S92, &face_2, kernelContext_11);
        if(!(_S93 < 0.0f))
        {
            return false;
        }
        *depth_1 = - _S93;
        float3 _S94 = box_to_world_0(b_13, (float4(*(kernelContext_11->loads_0+(b_13->hull_at_0 + _S91 + face_2))) ).xyz);
        *normal_2 = _S94;
        return true;
    }
    float best_2 = 1.00000001504746622e+30f;
    uint axis_4 = 0U;
    float side_1 = 1.0f;
    uint k_3 = 0U;
    for(;;)
    {
        if(k_3 < 3U)
        {
        }
        else
        {
            break;
        }
        float3 _S95 = box_axis_0(b_13, k_3);
        float local_5 = dot(r_3, _S95);
        float d_2 = comp3_0(_S90, k_3) - abs(local_5);
        if(d_2 <= 0.0f)
        {
            return false;
        }
        if(d_2 < best_2)
        {
            float _S96;
            if(local_5 >= 0.0f)
            {
                _S96 = 1.0f;
            }
            else
            {
                _S96 = -1.0f;
            }
            best_2 = d_2;
            axis_4 = k_3;
            side_1 = _S96;
        }
        k_3 = k_3 + 1U;
    }
    *depth_1 = best_2;
    float3 _S97 = box_axis_0(b_13, axis_4);
    *normal_2 = _S97 * float3(side_1) ;
    return true;
}

bool pair_point_0(const Box_0 thread* ba_0, const Box_0 thread* bb_0, uint na_0, uint e_0, float3 thread* p_2, float3 thread* n_1, float thread* d_3, KernelContext_0 thread* kernelContext_12)
{
    if(e_0 < na_0)
    {
        float3 _S98 = sample_point_1(ba_0, e_0, kernelContext_12);
        *p_2 = _S98;
        bool _S99 = penetration_1(bb_0, _S98, d_3, n_1, kernelContext_12);
        return _S99;
    }
    float3 _S100 = sample_point_1(bb_0, e_0 - na_0, kernelContext_12);
    *p_2 = _S100;
    bool _S101 = penetration_1(ba_0, _S100, d_3, n_1, kernelContext_12);
    if(!_S101)
    {
        return false;
    }
    *n_1 = - *n_1;
    return true;
}

bool is_nan_0(float x_3)
{
    return ((as_type<uint>((x_3))) & 2147483647U) > 2139095040U;
}

uint pair_count_sum_0(uint x_4, uint lanes_1)
{
    uint _S102;
    if(lanes_1 > 1U)
    {
        uint _S103 = simd_sum(x_4);
        _S102 = _S103;
    }
    else
    {
        _S102 = x_4;
    }
    return _S102;
}

float2 half_thickness_and_area_0(const Box_0 thread* b_14, float3 d_4)
{
    uint k_4 = 0U;
    float h_2 = 0.0f;
    float area_0 = 0.0f;
    for(;;)
    {
        if(k_4 < 3U)
        {
        }
        else
        {
            break;
        }
        float3 _S104 = box_axis_0(b_14, k_4);
        float c_3 = abs(dot(d_4, _S104));
        float h_3 = h_2 + c_3 * comp3_0(b_14->half_2, k_4);
        uint _S105 = k_4 + 1U;
        float area_1 = area_0 + c_3 * 4.0f * comp3_0(b_14->half_2, _S105 % 3U) * comp3_0(b_14->half_2, (k_4 + 2U) % 3U);
        k_4 = _S105;
        h_2 = h_3;
        area_0 = area_1;
    }
    return float2(h_2, area_0);
}

float contact_stiffness_0(float ea_0, const Box_0 thread* a_5, float eb_0, const Box_0 thread* b_15, float3 dir_0)
{
    float3 d_5 = safe_normalize_0(dir_0);
    float2 _S106 = half_thickness_and_area_0(a_5, d_5);
    float2 _S107 = half_thickness_and_area_0(b_15, d_5);
    return min(_S106.y, _S107.y) / (_S106.x / ea_0 + _S107.x / eb_0);
}

float3 penalty_force_0(float k_5, float m_red_0, float friction_0, float depth_2, float3 normal_3, float3 rel_velocity_0, float dt_1, uint points_0, float thread* stored_0, float thread* dissipated_1, KernelContext_0 thread* kernelContext_13)
{
    float c_max_0 = 1.0f / max(float(points_0), 10.0f) * m_red_0 / dt_1;
    float vn_0 = dot(rel_velocity_0, normal_3);
    float _S108 = k_5 * depth_2;
    float _S109 = min(2.0f * kernelContext_13->params_0->zeta_0 * sqrt(k_5 * m_red_0), c_max_0) * vn_0;
    float _S110 = _S108 - _S109;
    float _S111 = max(_S110, 0.0f);
    float3 vt_0 = rel_velocity_0 - normal_3 * float3(vn_0) ;
    float vt_mag_0 = length(vt_0);
    float _S112 = friction_0 * _S111;
    float _S113 = min(_S112, min(c_max_0, _S112 / 0.00100000004749745f) * vt_mag_0);
    float3 ft_0;
    if(vt_mag_0 > 0.0f)
    {
        ft_0 = - vt_0 * float3((_S113 / vt_mag_0)) ;
    }
    else
    {
        ft_0 = float3(0.0f) ;
    }
    *stored_0 = 0.5f * k_5 * depth_2 * depth_2;
    float damping_power_0;
    if(_S110 > 0.0f)
    {
        damping_power_0 = _S109 * vn_0;
    }
    else
    {
        damping_power_0 = _S108 * max(vn_0, 0.0f);
    }
    *dissipated_1 = (damping_power_0 + length(ft_0) * vt_mag_0) * dt_1;
    return normal_3 * float3(_S111)  + ft_0;
}

float3 pair_sum3_0(float3 x_5, uint lanes_2)
{
    float3 _S114;
    if(lanes_2 > 1U)
    {
        float3 _S115 = simd_sum(x_5);
        _S114 = _S115;
    }
    else
    {
        _S114 = x_5;
    }
    return _S114;
}

float pair_sum_0(float x_6, uint lanes_3)
{
    float _S116;
    if(lanes_3 > 1U)
    {
        float _S117 = simd_sum(x_6);
        _S116 = _S117;
    }
    else
    {
        _S116 = x_6;
    }
    return _S116;
}

void comp_add1_0(float thread* sum_0, float thread* err_0, float x_7)
{
    float t_2 = *sum_0 + x_7;
    if((abs(*sum_0)) >= (abs(x_7)))
    {
        *err_0 = *err_0 + (*sum_0 - t_2 + x_7);
    }
    else
    {
        *err_0 = *err_0 + (x_7 - t_2 + *sum_0);
    }
    *sum_0 = t_2;
    return;
}

void cov_or_0(uint island_0, uint bits_0, KernelContext_0 thread* kernelContext_14)
{
    uint _S118 = atomic_fetch_or_explicit(((atomic_uint device*)(&(kernelContext_14->islands_0+island_0)->coverage_0)), bits_0, memory_order_relaxed);
    return;
}

void cov_or_1(uint island_1, uint bits_1, KernelContext_0 thread* kernelContext_15)
{
    uint _S119 = atomic_fetch_or_explicit(((atomic_uint device*)(&(kernelContext_15->islands_0+island_1)->coverage_0)), bits_1, memory_order_relaxed);
    return;
}

void cov_mark_0(uint island_2, uint seen_0, uint bits_2, KernelContext_0 thread* kernelContext_16)
{
    if((bits_2 & (~seen_0)) != 0U)
    {
        cov_or_1(island_2, bits_2, kernelContext_16);
    }
    return;
}

void sentinel_mark_0(uint bits_3, KernelContext_0 thread* kernelContext_17)
{
    cov_mark_0(kernelContext_17->params_0->halt_index_0, (kernelContext_17->islands_0+kernelContext_17->params_0->halt_index_0)->coverage_0, bits_3, kernelContext_17);
    return;
}

void pair_contact_0(uint i_3, uint lane_0, uint lanes_4, KernelContext_0 thread* kernelContext_18)
{
    uint at_0 = kernelContext_18->params_0->pair_index_0 + 6U * i_3;
    uint ca_0 = kernelContext_18->index_0[at_0];
    uint cb_0 = kernelContext_18->index_0[at_0 + 1U];
    uint _S120 = kernelContext_18->index_0[at_0 + 3U];
    float _S121 = (as_type<float>((kernelContext_18->index_0[at_0 + 4U])));
    float _S122 = (as_type<float>((kernelContext_18->index_0[at_0 + 5U])));
    float _S123 = kernelContext_18->params_0->dt_0;
    uint out_0 = kernelContext_18->params_0->slot_base_0 + 2U * kernelContext_18->index_0[at_0 + 2U];
    WorldPoint_0 _S124 = chunk_world_0(ca_0, kernelContext_18);
    WorldPoint_0 _S125 = chunk_world_0(cb_0, kernelContext_18);
    thread WorldPoint_0 _S126 = _S125;
    thread WorldPoint_0 _S127 = _S124;
    float3 _S128 = world_diff_0(&_S126, &_S127);
    bool touching_0 = !((length(_S128)) > ((float4((kernelContext_18->chunks_0+ca_0)->half_0) ).w + (float4((kernelContext_18->chunks_0+cb_0)->half_0) ).w));
    float4 _S129 = float4(*(kernelContext_18->scratch_0+(kernelContext_18->params_0->ledger_base_0 + i_3))) ;
    thread float4 ledger_1 = _S129;
    uint flags_0 = (as_type<uint>((_S129.w)));
    float3 _S130 = float3(0.0f) ;
    Box_0 _S131 = chunk_box_0(ca_0, _S130, kernelContext_18);
    Box_0 _S132 = chunk_box_0(cb_0, _S128, kernelContext_18);
    thread Box_0 _S133 = _S131;
    uint _S134 = sample_count_0(&_S133);
    thread Box_0 _S135 = _S132;
    uint _S136 = sample_count_0(&_S135);
    uint _S137 = _S134 + _S136;
    uint e_1;
    bool has_state_0;
    if(!touching_0)
    {
        if((flags_0 & 1U) != 0U)
        {
            e_1 = lane_0;
            for(;;)
            {
                if(e_1 < _S137)
                {
                }
                else
                {
                    break;
                }
                *(kernelContext_18->contact_state_0+(_S120 + e_1)) = packed_float4(float4((as_type<float>((2143289344U))), 0.0f, 0.0f, 0.0f)) ;
                e_1 = e_1 + lanes_4;
            }
        }
        if(lane_0 == 0U)
        {
            if((flags_0 & 2U) != 0U)
            {
                e_1 = 0U;
                for(;;)
                {
                    if(e_1 < 4U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    *(kernelContext_18->scratch_0+(out_0 + e_1)) = packed_float4(float4(0.0f) ) ;
                    e_1 = e_1 + 1U;
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
                *(kernelContext_18->scratch_0+(kernelContext_18->params_0->ledger_base_0 + i_3)) = packed_float4(ledger_1) ;
            }
        }
        return;
    }
    thread Box_0 _S138 = _S131;
    thread Box_0 _S139 = _S132;
    bool _S140 = may_overlap_0(&_S138, &_S139);
    uint count_0;
    float3 fa_0;
    float3 ta_0;
    float3 fb_0;
    float3 tb_0;
    float stored_sum_0;
    float diss_sum_0;
    if(_S140)
    {
        thread float3 va0_0;
        thread float3 wa0_0;
        chunk_velocity_0(ca_0, &va0_0, &wa0_0, kernelContext_18);
        thread float3 vb0_0;
        thread float3 wb0_0;
        chunk_velocity_0(cb_0, &vb0_0, &wb0_0, kernelContext_18);
        e_1 = lane_0;
        count_0 = 0U;
        uint engaged_0 = 0U;
        for(;;)
        {
            if(e_1 < _S137)
            {
            }
            else
            {
                break;
            }
            thread Box_0 _S141 = _S131;
            thread Box_0 _S142 = _S132;
            thread float3 p_3;
            thread float3 n_2;
            thread float d_6;
            bool _S143 = pair_point_0(&_S141, &_S142, _S134, e_1, &p_3, &n_2, &d_6, kernelContext_18);
            if(!_S143)
            {
                uint _S144 = _S120 + e_1;
                if(!is_nan_0((float4(*(kernelContext_18->contact_state_0+_S144)) ).x))
                {
                    *(kernelContext_18->contact_state_0+_S144) = packed_float4(float4((as_type<float>((2143289344U))), 0.0f, 0.0f, 0.0f)) ;
                }
                e_1 = e_1 + lanes_4;
                continue;
            }
            uint _S145 = count_0 + 1U;
            uint _S146 = _S120 + e_1;
            float4 _S147 = float4(*(kernelContext_18->contact_state_0+_S146)) ;
            thread float4 entry_0 = _S147;
            if(is_nan_0(_S147.x))
            {
                has_state_0 = true;
            }
            else
            {
                has_state_0 = (dot(entry_0.yzw, n_2)) < 0.99000000953674316f;
            }
            if(has_state_0)
            {
                if(d_6 > (2.0f * abs(dot(va0_0 + cross(wa0_0, p_3) - (vb0_0 + cross(wb0_0, p_3 - _S132.center_1)), n_2)) * _S123 + 9.99999971718068537e-10f))
                {
                    stored_sum_0 = d_6;
                }
                else
                {
                    stored_sum_0 = 0.0f;
                }
                entry_0 = float4(stored_sum_0, n_2);
            }
            entry_0.x = min(entry_0.x, d_6);
            *(kernelContext_18->contact_state_0+_S146) = packed_float4(entry_0) ;
            uint engaged_1;
            if((d_6 - entry_0.x) > 0.0f)
            {
                engaged_1 = engaged_0 + 1U;
            }
            else
            {
                engaged_1 = engaged_0;
            }
            count_0 = _S145;
            engaged_0 = engaged_1;
            e_1 = e_1 + lanes_4;
        }
        uint count_1 = pair_count_sum_0(count_0, lanes_4);
        uint engaged_2 = pair_count_sum_0(engaged_0, lanes_4);
        if(count_1 > 0U)
        {
            float _S148 = (float4((kernelContext_18->chunks_0+ca_0)->cmat_0) ).x;
            float _S149 = (float4((kernelContext_18->chunks_0+cb_0)->cmat_0) ).x;
            float3 _S150 = _S132.center_1 - _S131.center_1;
            thread Box_0 _S151 = _S131;
            thread Box_0 _S152 = _S132;
            float _S153 = contact_stiffness_0(_S148, &_S151, _S149, &_S152, _S150);
            float _S154 = _S153 / max(float(engaged_2), 10.0f);
            e_1 = lane_0;
            fa_0 = _S130;
            ta_0 = _S130;
            fb_0 = _S130;
            tb_0 = _S130;
            stored_sum_0 = 0.0f;
            diss_sum_0 = 0.0f;
            for(;;)
            {
                if(e_1 < _S137)
                {
                }
                else
                {
                    break;
                }
                thread Box_0 _S155 = _S131;
                thread Box_0 _S156 = _S132;
                thread float3 p_4;
                thread float3 n_3;
                thread float d_7;
                bool _S157 = pair_point_0(&_S155, &_S156, _S134, e_1, &p_4, &n_3, &d_7, kernelContext_18);
                if(!_S157)
                {
                    e_1 = e_1 + lanes_4;
                    continue;
                }
                float eff_0 = d_7 - (float4(*(kernelContext_18->contact_state_0+(_S120 + e_1))) ).x;
                if(eff_0 <= 0.0f)
                {
                    e_1 = e_1 + lanes_4;
                    continue;
                }
                thread float stored_1;
                thread float diss_0;
                float3 _S158 = penalty_force_0(_S154, _S121, _S122, eff_0, n_3, va0_0 + cross(wa0_0, p_4) - (vb0_0 + cross(wb0_0, p_4 - _S132.center_1)), _S123, engaged_2, &stored_1, &diss_0, kernelContext_18);
                float3 ta_1 = ta_0 + cross(p_4, _S158);
                float3 _S159 = - _S158;
                float3 fb_1 = fb_0 + _S159;
                float3 tb_1 = tb_0 + cross(p_4 - _S132.center_1, _S159);
                float stored_sum_1 = stored_sum_0 + stored_1;
                float diss_sum_1 = diss_sum_0 + diss_0;
                fa_0 = fa_0 + _S158;
                ta_0 = ta_1;
                fb_0 = fb_1;
                tb_0 = tb_1;
                stored_sum_0 = stored_sum_1;
                diss_sum_0 = diss_sum_1;
                e_1 = e_1 + lanes_4;
            }
            float3 _S160 = pair_sum3_0(fa_0, lanes_4);
            float3 _S161 = pair_sum3_0(ta_0, lanes_4);
            float3 _S162 = pair_sum3_0(fb_0, lanes_4);
            float3 _S163 = pair_sum3_0(tb_0, lanes_4);
            float _S164 = pair_sum_0(stored_sum_0, lanes_4);
            float _S165 = pair_sum_0(diss_sum_0, lanes_4);
            has_state_0 = true;
            diss_sum_0 = _S165;
            fa_0 = _S160;
            ta_0 = _S161;
            fb_0 = _S162;
            tb_0 = _S163;
            stored_sum_0 = _S164;
        }
        else
        {
            has_state_0 = false;
            diss_sum_0 = 0.0f;
            fa_0 = _S130;
            ta_0 = _S130;
            fb_0 = _S130;
            tb_0 = _S130;
            stored_sum_0 = 0.0f;
        }
    }
    else
    {
        has_state_0 = false;
        diss_sum_0 = 0.0f;
        fa_0 = _S130;
        ta_0 = _S130;
        fb_0 = _S130;
        tb_0 = _S130;
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
        e_1 = lane_0;
        for(;;)
        {
            if(e_1 < _S137)
            {
            }
            else
            {
                break;
            }
            *(kernelContext_18->contact_state_0+(_S120 + e_1)) = packed_float4(float4((as_type<float>((2143289344U))), 0.0f, 0.0f, 0.0f)) ;
            e_1 = e_1 + lanes_4;
        }
    }
    if(lane_0 != 0U)
    {
        return;
    }
    if(has_state_0)
    {
        thread float _S166 = ledger_1.y;
        thread float _S167 = ledger_1.z;
        comp_add1_0(&_S166, &_S167, diss_sum_0);
        ledger_1.z = _S167;
        ledger_1.y = _S166;
    }
    float3 _S168 = float3(0.0f) ;
    if(any(fa_0 != _S168))
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any(ta_0 != _S168);
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any(fb_0 != _S168);
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any(tb_0 != _S168);
    }
    bool _S169;
    if(loaded_0)
    {
        _S169 = true;
    }
    else
    {
        _S169 = (flags_0 & 2U) != 0U;
    }
    if(_S169)
    {
        *(kernelContext_18->scratch_0+out_0) = packed_float4(float4(fa_0, 0.0f)) ;
        *(kernelContext_18->scratch_0+(out_0 + 1U)) = packed_float4(float4(ta_0, 0.0f)) ;
        *(kernelContext_18->scratch_0+(out_0 + 2U)) = packed_float4(float4(fb_0, 0.0f)) ;
        *(kernelContext_18->scratch_0+(out_0 + 3U)) = packed_float4(float4(tb_0, 0.0f)) ;
    }
    ledger_1.x = stored_sum_0;
    if(has_state_0)
    {
        e_1 = 1U;
    }
    else
    {
        e_1 = 0U;
    }
    if(loaded_0)
    {
        count_0 = 2U;
    }
    else
    {
        count_0 = 0U;
    }
    ledger_1.w = (as_type<float>((e_1 | count_0)));
    *(kernelContext_18->scratch_0+(kernelContext_18->params_0->ledger_base_0 + i_3)) = packed_float4(ledger_1) ;
    if(loaded_0)
    {
        sentinel_mark_0(1U, kernelContext_18);
    }
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
    float4 rotation_err_1;
    float4 ledger_0;
    uint4 cand_0;
    float4 momentum_1;
    float4 momentum_err_1;
};

Box_0 impactor_box_0(const Impactor_0 thread* imp_0, float3 center_3, float3 half_3)
{
    Quat_0 q_7 = quat_of_0(imp_0->rotation_1);
    thread Box_0 b_16;
    (&b_16)->center_1 = center_3;
    float3 _S170 = float3(1.0f, 0.0f, 0.0f);
    thread Quat_0 _S171 = q_7;
    float3 _S172 = rotate_0(&_S171, _S170);
    (&b_16)->axis0_0 = _S172;
    float3 _S173 = float3(0.0f, 1.0f, 0.0f);
    thread Quat_0 _S174 = q_7;
    float3 _S175 = rotate_0(&_S174, _S173);
    (&b_16)->axis1_0 = _S175;
    float3 _S176 = float3(0.0f, 0.0f, 1.0f);
    thread Quat_0 _S177 = q_7;
    float3 _S178 = rotate_0(&_S177, _S176);
    (&b_16)->axis2_0 = _S178;
    (&b_16)->half_2 = half_3;
    (&b_16)->hull_at_0 = 0U;
    (&b_16)->hull_v_0 = 0U;
    (&b_16)->hull_f_0 = 0U;
    return b_16;
}

uint impactor_slots_0(const Impactor_natural_0 thread* imp_1, const Box_0 thread* b_17)
{
    uint _S179;
    if(((float4(imp_1->shape_0) ).x) == 0.0f)
    {
        _S179 = 1U;
    }
    else
    {
        uint _S180 = sample_count_0(b_17);
        _S179 = _S180 + 14U;
    }
    return _S179;
}

uint impactor_slots_1(const Impactor_natural_0 thread* imp_2, const Box_0 thread* b_18)
{
    uint _S181;
    if(((float4(imp_2->shape_0) ).x) == 0.0f)
    {
        _S181 = 1U;
    }
    else
    {
        uint _S182 = sample_count_0(b_18);
        _S181 = _S182 + 14U;
    }
    return _S181;
}

bool sphere_contact_0(const Box_0 thread* b_19, float3 center_4, float radius_0, float3 thread* point_0, float3 thread* normal_4, float thread* depth_3, KernelContext_0 thread* kernelContext_19)
{
    float3 _S183 = float3(0.0f) ;
    *point_0 = _S183;
    *normal_4 = _S183;
    *depth_3 = 0.0f;
    float3 _S184 = b_19->center_1;
    float3 r_4 = center_4 - b_19->center_1;
    float3 _S185 = b_19->axis0_0;
    float3 _S186 = b_19->axis1_0;
    float3 _S187 = b_19->axis2_0;
    float3 local_6 = float3(dot(r_4, b_19->axis0_0), dot(r_4, b_19->axis1_0), dot(r_4, b_19->axis2_0));
    uint _S188 = b_19->hull_v_0;
    if((b_19->hull_v_0) != 0U)
    {
        thread uint face_3;
        float _S189 = hull_signed_distance_0(b_19, local_6, &face_3, kernelContext_19);
        if(_S189 >= radius_0)
        {
            return false;
        }
        float3 _S190 = box_to_world_0(b_19, (float4(*(kernelContext_19->loads_0+(b_19->hull_at_0 + _S188 + face_3))) ).xyz);
        *normal_4 = _S190;
        *point_0 = center_4 - _S190 * float3(max(_S189, 0.0f)) ;
        *depth_3 = radius_0 - _S189;
        return true;
    }
    float3 q_8 = clamp(local_6, - b_19->half_2, b_19->half_2);
    float3 d_8 = local_6 - q_8;
    float dist_0 = length(d_8);
    if(dist_0 > 9.999999960041972e-13f)
    {
        if(dist_0 >= radius_0)
        {
            return false;
        }
        float3 dn_0 = d_8 / float3(dist_0) ;
        *normal_4 = _S185 * float3(dn_0.x)  + _S186 * float3(dn_0.y)  + _S187 * float3(dn_0.z) ;
        *point_0 = _S184 + _S185 * float3(q_8.x)  + _S186 * float3(q_8.y)  + _S187 * float3(q_8.z) ;
        *depth_3 = radius_0 - dist_0;
        return true;
    }
    thread float inside_0;
    thread float3 n_4;
    bool _S191 = penetration_0(b_19, center_4, &inside_0, &n_4, kernelContext_19);
    if(!_S191)
    {
        return false;
    }
    *normal_4 = n_4;
    *point_0 = center_4 - n_4 * float3(min(radius_0, inside_0)) ;
    *depth_3 = radius_0 + inside_0;
    return true;
}

bool impactor_contact_0(const Impactor_natural_0 thread* imp_3, float crush_depth_0, const Box_0 thread* shrunk_0, const Box_0 thread* b_20, uint j_0, float3 thread* p_5, float3 thread* n_5, float thread* d_9, KernelContext_0 thread* kernelContext_20)
{
    float3 _S192 = float3(0.0f) ;
    *p_5 = _S192;
    *n_5 = _S192;
    *d_9 = 0.0f;
    float4 _S193 = float4(imp_3->shape_0) ;
    if((_S193.x) == 0.0f)
    {
        bool _S194 = sphere_contact_0(b_20, _S192, _S193.y - crush_depth_0, p_5, n_5, d_9, kernelContext_20);
        if(!_S194)
        {
            return false;
        }
        *n_5 = - *n_5;
        return true;
    }
    uint _S195 = sample_count_0(b_20);
    if(j_0 < _S195)
    {
        float3 _S196 = sample_point_0(b_20, j_0, kernelContext_20);
        *p_5 = _S196;
        bool _S197 = penetration_0(shrunk_0, _S196, d_9, n_5, kernelContext_20);
        return _S197;
    }
    float3 _S198 = sample_point_0(shrunk_0, j_0 - _S195, kernelContext_20);
    *p_5 = _S198;
    bool _S199 = penetration_0(b_20, _S198, d_9, n_5, kernelContext_20);
    if(!_S199)
    {
        return false;
    }
    *n_5 = - *n_5;
    return true;
}

bool impactor_contact_1(const Impactor_natural_0 thread* imp_4, float crush_depth_1, const Box_0 thread* shrunk_1, const Box_0 thread* b_21, uint j_1, float3 thread* p_6, float3 thread* n_6, float thread* d_10, KernelContext_0 thread* kernelContext_21)
{
    float3 _S200 = float3(0.0f) ;
    *p_6 = _S200;
    *n_6 = _S200;
    *d_10 = 0.0f;
    float4 _S201 = float4(imp_4->shape_0) ;
    if((_S201.x) == 0.0f)
    {
        bool _S202 = sphere_contact_0(b_21, _S200, _S201.y - crush_depth_1, p_6, n_6, d_10, kernelContext_21);
        if(!_S202)
        {
            return false;
        }
        *n_6 = - *n_6;
        return true;
    }
    uint _S203 = sample_count_0(b_21);
    if(j_1 < _S203)
    {
        float3 _S204 = sample_point_0(b_21, j_1, kernelContext_21);
        *p_6 = _S204;
        bool _S205 = penetration_0(shrunk_1, _S204, d_10, n_6, kernelContext_21);
        return _S205;
    }
    float3 _S206 = sample_point_0(shrunk_1, j_1 - _S203, kernelContext_21);
    *p_6 = _S206;
    bool _S207 = penetration_0(b_21, _S206, d_10, n_6, kernelContext_21);
    if(!_S207)
    {
        return false;
    }
    *n_6 = - *n_6;
    return true;
}

WorldPoint_0 impactor_point_0(uint _S208, KernelContext_0 thread* kernelContext_22)
{
    Impactor_natural_0 device* _S209 = kernelContext_22->impactors_0+_S208;
    thread WorldPoint_0 wi_0;
    (&wi_0)->hi_0 = (float4(_S209->position_1) ).xyz;
    (&wi_0)->lo_0 = (float4(_S209->position_err_1) ).xyz;
    (&wi_0)->rel_0 = float3(0.0f) ;
    return wi_0;
}

Box_0 impactor_box_1(uint _S210, float3 _S211, float3 _S212, KernelContext_0 thread* kernelContext_23)
{
    Quat_0 q_9 = quat_of_0(float4((kernelContext_23->impactors_0+_S210)->rotation_1) );
    thread Box_0 b_22;
    (&b_22)->center_1 = _S211;
    float3 _S213 = float3(1.0f, 0.0f, 0.0f);
    thread Quat_0 _S214 = q_9;
    float3 _S215 = rotate_0(&_S214, _S213);
    (&b_22)->axis0_0 = _S215;
    float3 _S216 = float3(0.0f, 1.0f, 0.0f);
    thread Quat_0 _S217 = q_9;
    float3 _S218 = rotate_0(&_S217, _S216);
    (&b_22)->axis1_0 = _S218;
    float3 _S219 = float3(0.0f, 0.0f, 1.0f);
    thread Quat_0 _S220 = q_9;
    float3 _S221 = rotate_0(&_S220, _S219);
    (&b_22)->axis2_0 = _S221;
    (&b_22)->half_2 = _S212;
    (&b_22)->hull_at_0 = 0U;
    (&b_22)->hull_v_0 = 0U;
    (&b_22)->hull_f_0 = 0U;
    return b_22;
}

Box_0 impactor_shrunk_0(uint _S222, float _S223, const Box_0 thread* _S224)
{
    thread Box_0 shrunk_2 = *_S224;
    (&shrunk_2)->half_2 = _S224->half_2 - min(float3(_S223) , _S224->half_2 * float3(0.5f) );
    return shrunk_2;
}

bool impactor_contact_2(uint _S225, float _S226, const Box_0 thread* _S227, const Box_0 thread* _S228, uint _S229, float3 thread* _S230, float3 thread* _S231, float thread* _S232, KernelContext_0 thread* kernelContext_24)
{
    Impactor_natural_0 _S233 = *(kernelContext_24->impactors_0+_S225);
    float3 _S234 = float3(0.0f) ;
    *_S230 = _S234;
    *_S231 = _S234;
    *_S232 = 0.0f;
    float4 _S235 = float4(_S233.shape_0) ;
    if((_S235.x) == 0.0f)
    {
        bool _S236 = sphere_contact_0(_S228, _S234, _S235.y - _S226, _S230, _S231, _S232, kernelContext_24);
        if(!_S236)
        {
            return false;
        }
        *_S231 = - *_S231;
        return true;
    }
    uint _S237 = sample_count_0(_S228);
    if(_S229 < _S237)
    {
        float3 _S238 = sample_point_0(_S228, _S229, kernelContext_24);
        *_S230 = _S238;
        bool _S239 = penetration_0(_S227, _S238, _S232, _S231, kernelContext_24);
        return _S239;
    }
    float3 _S240 = sample_point_0(_S227, _S229 - _S237, kernelContext_24);
    *_S230 = _S240;
    bool _S241 = penetration_0(_S228, _S240, _S232, _S231, kernelContext_24);
    if(!_S241)
    {
        return false;
    }
    *_S231 = - *_S231;
    return true;
}

uint impactor_contact_count_0(uint _S242, float _S243, const Box_0 thread* _S244, const Box_0 thread* _S245, KernelContext_0 thread* kernelContext_25)
{
    thread Impactor_natural_0 _S246 = *(kernelContext_25->impactors_0+_S242);
    uint j_2 = 0U;
    uint count_2 = 0U;
    for(;;)
    {
        uint _S247 = impactor_slots_1(&_S246, _S245);
        if(j_2 < _S247)
        {
        }
        else
        {
            break;
        }
        thread float3 p_7;
        thread float3 n_7;
        thread float d_11;
        bool _S248 = impactor_contact_2(_S242, _S243, _S244, _S245, j_2, &p_7, &n_7, &d_11, kernelContext_25);
        if(_S248)
        {
            count_2 = count_2 + 1U;
        }
        j_2 = j_2 + 1U;
    }
    return count_2;
}

void impactor_candidate_forces_0(uint k_6, KernelContext_0 thread* kernelContext_26)
{
    uint _S249 = 3U * k_6;
    uint at_1 = kernelContext_26->params_0->cand_index_0 + _S249;
    uint c_4 = kernelContext_26->index_0[at_1];
    uint slot_0 = kernelContext_26->index_0[at_1 + 1U];
    uint _S250 = kernelContext_26->index_0[at_1 + 2U];
    thread Impactor_natural_0 _S251 = *(kernelContext_26->impactors_0+_S250);
    float _S252 = kernelContext_26->params_0->dt_0;
    float3 _S253 = float3(0.0f) ;
    thread float4 data_0 = float4(*(kernelContext_26->scratch_0+(kernelContext_26->params_0->cand_base_0 + _S249))) ;
    bool hit_0;
    float3 f_sum_0;
    float3 t_sum_0;
    float3 imp_f_0;
    float3 imp_t_0;
    if(((uint4((&_S251)->cand_0) ).z) == 0U)
    {
        WorldPoint_0 _S254 = chunk_world_0(c_4, kernelContext_26);
        WorldPoint_0 _S255 = impactor_point_0(_S250, kernelContext_26);
        thread WorldPoint_0 _S256 = _S254;
        thread WorldPoint_0 _S257 = _S255;
        float3 _S258 = world_diff_0(&_S256, &_S257);
        float4 _S259 = float4((&_S251)->half_1) ;
        if(!((length(_S258)) > (_S259.w + (float4((kernelContext_26->chunks_0+c_4)->half_0) ).w)))
        {
            Box_0 _S260 = impactor_box_1(_S250, _S253, _S259.xyz, kernelContext_26);
            Box_0 _S261 = chunk_box_0(c_4, _S258, kernelContext_26);
            float4 _S262 = float4((&_S251)->mat_0) ;
            float _S263 = _S262.x;
            float _S264 = (float4((kernelContext_26->chunks_0+c_4)->cmat_0) ).x;
            float3 _S265 = _S261.center_1 - _S260.center_1;
            thread Box_0 _S266 = _S260;
            thread Box_0 _S267 = _S261;
            float _S268 = contact_stiffness_0(_S263, &_S266, _S264, &_S267, _S265);
            float4 _S269 = float4((&_S251)->geom_0) ;
            float _S270 = _S269.y;
            thread Box_0 _S271 = _S260;
            Box_0 _S272 = impactor_shrunk_0(_S250, _S270, &_S271);
            thread Box_0 _S273 = _S272;
            thread Box_0 _S274 = _S261;
            uint _S275 = impactor_contact_count_0(_S250, _S270, &_S273, &_S274, kernelContext_26);
            bool _S276 = ((float4((&_S251)->shape_0) ).x) == 0.0f;
            float _S277;
            if(_S276)
            {
                _S277 = _S268;
            }
            else
            {
                _S277 = _S268 / max(float(_S275), 10.0f);
            }
            uint _S278;
            if(_S276)
            {
                _S278 = 1U;
            }
            else
            {
                _S278 = _S275;
            }
            float m_1 = (float4((kernelContext_26->chunks_0+c_4)->center_0) ).w;
            float _S279 = _S262.z;
            float _S280 = m_1 * _S279 / (m_1 + _S279);
            float _S281;
            if((kernelContext_26->params_0->pair_friction_0) >= 0.0f)
            {
                _S281 = kernelContext_26->params_0->pair_friction_0;
            }
            else
            {
                _S281 = min(_S262.y, (float4((kernelContext_26->chunks_0+c_4)->cmat_0) ).y);
            }
            float3 _S282 = (float4((&_S251)->velocity_1) ).xyz + (float4((&_S251)->velocity_err_1) ).xyz;
            thread float3 vc_0;
            thread float3 wc_0;
            chunk_velocity_0(c_4, &vc_0, &wc_0, kernelContext_26);
            hit_0 = false;
            uint j_3 = 0U;
            f_sum_0 = _S253;
            t_sum_0 = _S253;
            imp_f_0 = _S253;
            imp_t_0 = _S253;
            for(;;)
            {
                bool _S283;
                if(_S275 > 0U)
                {
                    thread Box_0 _S284 = _S261;
                    uint _S285 = impactor_slots_0(&_S251, &_S284);
                    _S283 = j_3 < _S285;
                }
                else
                {
                    _S283 = false;
                }
                if(_S283)
                {
                }
                else
                {
                    break;
                }
                thread Box_0 _S286 = _S272;
                thread Box_0 _S287 = _S261;
                thread float3 p_8;
                thread float3 nrm_0;
                thread float dep_0;
                bool _S288 = impactor_contact_0(&_S251, _S270, &_S286, &_S287, j_3, &p_8, &nrm_0, &dep_0, kernelContext_26);
                if(!_S288)
                {
                    j_3 = j_3 + 1U;
                    continue;
                }
                thread float stored_2;
                thread float diss_1;
                float3 _S289 = penalty_force_0(_S277, _S280, _S281, dep_0 * _S269.x, nrm_0, vc_0 + cross(wc_0, p_8 - _S261.center_1) - (_S282 + cross((float4((&_S251)->angular_velocity_1) ).xyz, p_8)), _S252, _S278, &stored_2, &diss_1, kernelContext_26);
                float3 f_sum_1 = f_sum_0 + _S289;
                float3 t_sum_1 = t_sum_0 + cross(p_8 - _S261.center_1, _S289);
                float3 imp_f_1 = imp_f_0 - _S289;
                float3 imp_t_1 = imp_t_0 - cross(p_8, _S289);
                thread float _S290 = data_0.z;
                thread float _S291 = data_0.w;
                comp_add1_0(&_S290, &_S291, diss_1);
                data_0.w = _S291;
                data_0.z = _S290;
                hit_0 = true;
                f_sum_0 = f_sum_1;
                t_sum_0 = t_sum_1;
                imp_f_0 = imp_f_1;
                imp_t_0 = imp_t_1;
                j_3 = j_3 + 1U;
            }
        }
        else
        {
            hit_0 = false;
            f_sum_0 = _S253;
            t_sum_0 = _S253;
            imp_f_0 = _S253;
            imp_t_0 = _S253;
        }
    }
    else
    {
        hit_0 = false;
        f_sum_0 = _S253;
        t_sum_0 = _S253;
        imp_f_0 = _S253;
        imp_t_0 = _S253;
    }
    uint _S292 = 2U * slot_0;
    *(kernelContext_26->scratch_0+(kernelContext_26->params_0->slot_base_0 + _S292)) = packed_float4(float4(f_sum_0, 0.0f)) ;
    *(kernelContext_26->scratch_0+(kernelContext_26->params_0->slot_base_0 + _S292 + 1U)) = packed_float4(float4(t_sum_0, 0.0f)) ;
    *(kernelContext_26->scratch_0+(kernelContext_26->params_0->cand_base_0 + _S249)) = packed_float4(data_0) ;
    *(kernelContext_26->scratch_0+(kernelContext_26->params_0->cand_base_0 + _S249 + 1U)) = packed_float4(float4(imp_f_0, 0.0f)) ;
    *(kernelContext_26->scratch_0+(kernelContext_26->params_0->cand_base_0 + _S249 + 2U)) = packed_float4(float4(imp_t_0, 0.0f)) ;
    if(hit_0)
    {
        sentinel_mark_0(2U, kernelContext_26);
    }
    return;
}

Quat_0 quat_mul_0(const Quat_0 thread* a_6, const Quat_0 thread* o_0)
{
    thread Quat_0 r_5;
    (&r_5)->w_1 = a_6->w_1 * o_0->w_1 - a_6->x_2 * o_0->x_2 - a_6->y_1 * o_0->y_1 - a_6->z_0 * o_0->z_0;
    (&r_5)->x_2 = a_6->w_1 * o_0->x_2 + a_6->x_2 * o_0->w_1 + a_6->y_1 * o_0->z_0 - a_6->z_0 * o_0->y_1;
    (&r_5)->y_1 = a_6->w_1 * o_0->y_1 - a_6->x_2 * o_0->z_0 + a_6->y_1 * o_0->w_1 + a_6->z_0 * o_0->x_2;
    (&r_5)->z_0 = a_6->w_1 * o_0->z_0 + a_6->x_2 * o_0->y_1 - a_6->y_1 * o_0->x_2 + a_6->z_0 * o_0->w_1;
    return r_5;
}

void travel_check_0(uint c_5, KernelContext_0 thread* kernelContext_27)
{
    ChunkStatic_natural_0 device* _S293 = kernelContext_27->chunks_0+c_5;
    uint4 _S294 = uint4(_S293->cinfo_0) ;
    if((_S294.z) == 0U)
    {
        return;
    }
    WorldPoint_0 _S295 = chunk_world_0(c_5, kernelContext_27);
    float4 _S296 = float4(_S293->start_hi_0) ;
    float4 _S297 = float4(_S293->start_lo_0) ;
    float3 moved_0 = _S295.hi_0 - _S296.xyz + (_S295.lo_0 - _S297.xyz) + _S295.rel_0;
    float4 _S298 = float4(_S293->start_vel_0) ;
    uint _S299 = (uint4(_S293->info_1) ).y;
    float3 _S300 = float3((kernelContext_27->params_0->t_hi_0 - _S298.w + (kernelContext_27->params_0->t_lo_0 - _S297.w) + float((uint4((kernelContext_27->islands_0+_S299)->info_0) ).w - kernelContext_27->params_0->step_start_0) * kernelContext_27->params_0->dt_0)) ;
    float3 _S301 = _S298.xyz * _S300;
    uint _S302 = _S294.w;
    float3 _S303;
    if((_S302 & 2U) != 0U)
    {
        _S303 = float3(0.5f)  * kernelContext_27->params_0->gravity_0.xyz * _S300 * _S300;
    }
    else
    {
        _S303 = float3(0.0f) ;
    }
    float travel_0 = length(moved_0 - (_S301 + _S303));
    float travel_1;
    if((_S302 & 1U) != 0U)
    {
        float3 th_1 = (float4(*(kernelContext_27->state_0+(4U * c_5 + 1U))) ).xyz;
        Quat_0 _S304 = from_axis_angle_0(th_1, length(th_1));
        thread Quat_0 _S305 = quat_of_0(float4((kernelContext_27->islands_0+_S299)->rotation_0) );
        thread Quat_0 _S306 = _S304;
        Quat_0 _S307 = quat_mul_0(&_S305, &_S306);
        float4 _S308 = float4(_S293->start_rot_0) ;
        thread Quat_0 _S309 = quat_of_0(float4(- _S308.xyz, _S308.w));
        thread Quat_0 _S310 = _S307;
        Quat_0 _S311 = quat_mul_0(&_S309, &_S310);
        travel_1 = travel_0 + 2.0f * atan2(length(float3(_S311.x_2, _S311.y_1, _S311.z_0)), abs(_S311.w_1)) * (float4(_S293->half_0) ).w;
    }
    else
    {
        travel_1 = travel_0;
    }
    if(travel_1 > (_S296.w))
    {
        (kernelContext_27->islands_0+kernelContext_27->params_0->halt_index_0)->info_0[int(2)] = ((uint4((kernelContext_27->islands_0+kernelContext_27->params_0->halt_index_0)->info_0) ).z) | 1U;
        sentinel_mark_0(1048576U, kernelContext_27);
    }
    return;
}

[[kernel]] void contact_forces(uint3 id_0 [[thread_position_in_grid]], Params_0 constant* params_1 [[buffer(0)]], Island_natural_0 device* islands_1 [[buffer(9)]], uint device* index_1 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_1 [[buffer(3)]], packed_float4 device* state_1 [[buffer(6)]], packed_float4 device* scratch_1 [[buffer(8)]], packed_float4 device* contact_state_1 [[buffer(11)]], packed_float4 device* loads_1 [[buffer(5)]], Impactor_natural_0 device* impactors_1 [[buffer(10)]], BondStatic_natural_0 device* bonds_1 [[buffer(2)]], MaterialTable_0 constant* materials_1 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_1 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_28;
    (&kernelContext_28)->params_0 = params_1;
    (&kernelContext_28)->islands_0 = islands_1;
    (&kernelContext_28)->index_0 = index_1;
    (&kernelContext_28)->chunks_0 = chunks_1;
    (&kernelContext_28)->state_0 = state_1;
    (&kernelContext_28)->scratch_0 = scratch_1;
    (&kernelContext_28)->contact_state_0 = contact_state_1;
    (&kernelContext_28)->loads_0 = loads_1;
    (&kernelContext_28)->impactors_0 = impactors_1;
    (&kernelContext_28)->bonds_0 = bonds_1;
    (&kernelContext_28)->materials_0 = materials_1;
    (&kernelContext_28)->bond_dyn_0 = bond_dyn_1;
    threadgroup array<float4, int(32)> g_part_a_1;
    (&kernelContext_28)->g_part_a_0 = &g_part_a_1;
    threadgroup array<float4, int(32)> g_part_b_1;
    (&kernelContext_28)->g_part_b_0 = &g_part_b_1;
    threadgroup array<uint, int(5)> g_seen_1;
    (&kernelContext_28)->g_seen_0 = &g_seen_1;
    threadgroup uint g_wide_run_1;
    (&kernelContext_28)->g_wide_run_0 = &g_wide_run_1;
    threadgroup uint g_halt_1;
    (&kernelContext_28)->g_halt_0 = &g_halt_1;
    threadgroup uint g_run_1;
    (&kernelContext_28)->g_run_0 = &g_run_1;
    uint i_4 = id_0.x;
    uint _S312 = pair_lane_count_0(&kernelContext_28);
    uint pair_threads_0 = (&kernelContext_28)->params_0->pair_count_0 * _S312;
    if(i_4 < pair_threads_0)
    {
        bool _S313 = stopped_0(&kernelContext_28);
        bool _S314 = pair_any_0(_S313, _S312);
        if(!_S314)
        {
            uint _S315 = i_4 / _S312;
            uint _S316 = i_4 % _S312;
            pair_contact_0(_S315, _S316, _S312, &kernelContext_28);
        }
        return;
    }
    bool _S317 = stopped_0(&kernelContext_28);
    if(_S317)
    {
        return;
    }
    uint j_4 = i_4 - pair_threads_0;
    if(j_4 < ((&kernelContext_28)->params_0->cand_count_0))
    {
        impactor_candidate_forces_0(j_4, &kernelContext_28);
    }
    else
    {
        if(j_4 < ((&kernelContext_28)->params_0->cand_count_0 + (&kernelContext_28)->params_0->chunk_count_0))
        {
            travel_check_0(j_4 - (&kernelContext_28)->params_0->cand_count_0, &kernelContext_28);
        }
    }
    return;
}

[[kernel]] void impactor_shares(uint3 id_1 [[thread_position_in_grid]], Params_0 constant* params_2 [[buffer(0)]], Island_natural_0 device* islands_2 [[buffer(9)]], uint device* index_2 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_2 [[buffer(3)]], packed_float4 device* state_2 [[buffer(6)]], packed_float4 device* scratch_2 [[buffer(8)]], packed_float4 device* contact_state_2 [[buffer(11)]], packed_float4 device* loads_2 [[buffer(5)]], Impactor_natural_0 device* impactors_2 [[buffer(10)]], BondStatic_natural_0 device* bonds_2 [[buffer(2)]], MaterialTable_0 constant* materials_2 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_2 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_29;
    (&kernelContext_29)->params_0 = params_2;
    (&kernelContext_29)->islands_0 = islands_2;
    (&kernelContext_29)->index_0 = index_2;
    (&kernelContext_29)->chunks_0 = chunks_2;
    (&kernelContext_29)->state_0 = state_2;
    (&kernelContext_29)->scratch_0 = scratch_2;
    (&kernelContext_29)->contact_state_0 = contact_state_2;
    (&kernelContext_29)->loads_0 = loads_2;
    (&kernelContext_29)->impactors_0 = impactors_2;
    (&kernelContext_29)->bonds_0 = bonds_2;
    (&kernelContext_29)->materials_0 = materials_2;
    (&kernelContext_29)->bond_dyn_0 = bond_dyn_2;
    threadgroup array<float4, int(32)> g_part_a_2;
    (&kernelContext_29)->g_part_a_0 = &g_part_a_2;
    threadgroup array<float4, int(32)> g_part_b_2;
    (&kernelContext_29)->g_part_b_0 = &g_part_b_2;
    threadgroup array<uint, int(5)> g_seen_2;
    (&kernelContext_29)->g_seen_0 = &g_seen_2;
    threadgroup uint g_wide_run_2;
    (&kernelContext_29)->g_wide_run_0 = &g_wide_run_2;
    threadgroup uint g_halt_2;
    (&kernelContext_29)->g_halt_0 = &g_halt_2;
    threadgroup uint g_run_2;
    (&kernelContext_29)->g_run_0 = &g_run_2;
    uint k_7 = id_1.x;
    bool _S318;
    if(k_7 >= (params_2->cand_count_0))
    {
        _S318 = true;
    }
    else
    {
        bool _S319 = stopped_0(&kernelContext_29);
        _S318 = _S319;
    }
    if(_S318)
    {
        return;
    }
    uint _S320 = 3U * k_7;
    uint at_2 = (&kernelContext_29)->params_0->cand_index_0 + _S320;
    uint c_6 = (&kernelContext_29)->index_0[at_2];
    uint _S321 = (&kernelContext_29)->index_0[at_2 + 2U];
    thread Impactor_natural_0 _S322 = *((&kernelContext_29)->impactors_0+_S321);
    if(((uint4((&_S322)->cand_0) ).z) == 0U)
    {
        _S318 = ((float4((&_S322)->crush_0) ).x) > 0.0f;
    }
    else
    {
        _S318 = false;
    }
    float total_0;
    float ksum_0;
    if(_S318)
    {
        WorldPoint_0 _S323 = chunk_world_0(c_6, &kernelContext_29);
        WorldPoint_0 _S324 = impactor_point_0(_S321, &kernelContext_29);
        thread WorldPoint_0 _S325 = _S323;
        thread WorldPoint_0 _S326 = _S324;
        float3 _S327 = world_diff_0(&_S325, &_S326);
        float4 _S328 = float4((&_S322)->half_1) ;
        if(!((length(_S327)) > (_S328.w + (float4(((&kernelContext_29)->chunks_0+c_6)->half_0) ).w)))
        {
            Box_0 _S329 = impactor_box_1(_S321, float3(0.0f) , _S328.xyz, &kernelContext_29);
            Box_0 _S330 = chunk_box_0(c_6, _S327, &kernelContext_29);
            float _S331 = (float4((&_S322)->mat_0) ).x;
            float _S332 = (float4(((&kernelContext_29)->chunks_0+c_6)->cmat_0) ).x;
            float3 _S333 = _S330.center_1 - _S329.center_1;
            thread Box_0 _S334 = _S329;
            thread Box_0 _S335 = _S330;
            float _S336 = contact_stiffness_0(_S331, &_S334, _S332, &_S335, _S333);
            float _S337 = (float4((&_S322)->crush_0) ).w;
            thread Box_0 _S338 = _S329;
            Box_0 _S339 = impactor_shrunk_0(_S321, _S337, &_S338);
            thread Box_0 _S340 = _S339;
            thread Box_0 _S341 = _S330;
            uint _S342 = impactor_contact_count_0(_S321, _S337, &_S340, &_S341, &kernelContext_29);
            float _S343;
            if(((float4((&_S322)->shape_0) ).x) == 0.0f)
            {
                _S343 = _S336;
            }
            else
            {
                _S343 = _S336 / max(float(_S342), 10.0f);
            }
            uint j_5 = 0U;
            total_0 = 0.0f;
            ksum_0 = 0.0f;
            for(;;)
            {
                if(_S342 > 0U)
                {
                    thread Box_0 _S344 = _S330;
                    uint _S345 = impactor_slots_0(&_S322, &_S344);
                    _S318 = j_5 < _S345;
                }
                else
                {
                    _S318 = false;
                }
                if(_S318)
                {
                }
                else
                {
                    break;
                }
                thread Box_0 _S346 = _S339;
                thread Box_0 _S347 = _S330;
                thread float3 p_9;
                thread float3 nrm_1;
                thread float dep_1;
                bool _S348 = impactor_contact_1(&_S322, _S337, &_S346, &_S347, j_5, &p_9, &nrm_1, &dep_1, &kernelContext_29);
                if(!_S348)
                {
                    j_5 = j_5 + 1U;
                    continue;
                }
                float ksum_1 = ksum_0 + _S343;
                total_0 = total_0 + _S343 * dep_1;
                ksum_0 = ksum_1;
                j_5 = j_5 + 1U;
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
    float4 _S349 = float4(*((&kernelContext_29)->scratch_0+((&kernelContext_29)->params_0->cand_base_0 + _S320))) ;
    *((&kernelContext_29)->scratch_0+((&kernelContext_29)->params_0->cand_base_0 + _S320)) = packed_float4(float4(total_0, ksum_0, _S349.z, _S349.w)) ;
    return;
}

[[kernel]] void impactor_crush(uint3 group_0 [[threadgroup_position_in_grid]], uint3 thread_0 [[thread_position_in_threadgroup]], Params_0 constant* params_3 [[buffer(0)]], Island_natural_0 device* islands_3 [[buffer(9)]], uint device* index_3 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_3 [[buffer(3)]], packed_float4 device* state_3 [[buffer(6)]], packed_float4 device* scratch_3 [[buffer(8)]], packed_float4 device* contact_state_3 [[buffer(11)]], packed_float4 device* loads_3 [[buffer(5)]], Impactor_natural_0 device* impactors_3 [[buffer(10)]], BondStatic_natural_0 device* bonds_3 [[buffer(2)]], MaterialTable_0 constant* materials_3 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_3 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_30;
    (&kernelContext_30)->params_0 = params_3;
    (&kernelContext_30)->islands_0 = islands_3;
    (&kernelContext_30)->index_0 = index_3;
    (&kernelContext_30)->chunks_0 = chunks_3;
    (&kernelContext_30)->state_0 = state_3;
    (&kernelContext_30)->scratch_0 = scratch_3;
    (&kernelContext_30)->contact_state_0 = contact_state_3;
    (&kernelContext_30)->loads_0 = loads_3;
    (&kernelContext_30)->impactors_0 = impactors_3;
    (&kernelContext_30)->bonds_0 = bonds_3;
    (&kernelContext_30)->materials_0 = materials_3;
    (&kernelContext_30)->bond_dyn_0 = bond_dyn_3;
    threadgroup array<float4, int(32)> g_part_a_3;
    (&kernelContext_30)->g_part_a_0 = &g_part_a_3;
    threadgroup array<float4, int(32)> g_part_b_3;
    (&kernelContext_30)->g_part_b_0 = &g_part_b_3;
    threadgroup array<uint, int(5)> g_seen_3;
    (&kernelContext_30)->g_seen_0 = &g_seen_3;
    threadgroup uint g_wide_run_3;
    (&kernelContext_30)->g_wide_run_0 = &g_wide_run_3;
    threadgroup uint g_halt_3;
    (&kernelContext_30)->g_halt_0 = &g_halt_3;
    threadgroup uint g_run_3;
    (&kernelContext_30)->g_run_0 = &g_run_3;
    uint ii_0 = group_0.x;
    uint tid_2 = thread_0.x;
    bool _S350;
    if(ii_0 >= (params_3->impactor_count_0))
    {
        _S350 = true;
    }
    else
    {
        bool _S351 = stopped_0(&kernelContext_30);
        _S350 = _S351;
    }
    if(_S350)
    {
        return;
    }
    Impactor_natural_0 device* _S352 = (&kernelContext_30)->impactors_0+ii_0;
    float4 _S353 = float4((*_S352).position_err_1) ;
    float4 _S354 = float4((*_S352).velocity_1) ;
    float4 _S355 = float4((*_S352).velocity_err_1) ;
    float4 _S356 = float4((*_S352).angular_velocity_1) ;
    float4 _S357 = float4((*_S352).rotation_1) ;
    float4 _S358 = float4((*_S352).inertia0_2) ;
    float4 _S359 = float4((*_S352).inertia1_2) ;
    float4 _S360 = float4((*_S352).inertia2_2) ;
    float4 _S361 = float4((*_S352).inv0_2) ;
    float4 _S362 = float4((*_S352).inv1_2) ;
    float4 _S363 = float4((*_S352).inv2_2) ;
    float4 _S364 = float4((*_S352).shape_0) ;
    float4 _S365 = float4((*_S352).half_1) ;
    float4 _S366 = float4((*_S352).mat_0) ;
    float4 _S367 = float4((*_S352).crush_0) ;
    float4 _S368 = float4((*_S352).geom_0) ;
    float4 _S369 = float4((*_S352).rotation_err_1) ;
    float4 _S370 = float4((*_S352).ledger_0) ;
    uint4 _S371 = uint4((*_S352).cand_0) ;
    float4 _S372 = float4((*_S352).momentum_1) ;
    float4 _S373 = float4((*_S352).momentum_err_1) ;
    thread Impactor_0 imp_5;
    (&imp_5)->position_1 = float4((*_S352).position_1) ;
    (&imp_5)->position_err_1 = _S353;
    (&imp_5)->velocity_1 = _S354;
    (&imp_5)->velocity_err_1 = _S355;
    (&imp_5)->angular_velocity_1 = _S356;
    (&imp_5)->rotation_1 = _S357;
    (&imp_5)->inertia0_2 = _S358;
    (&imp_5)->inertia1_2 = _S359;
    (&imp_5)->inertia2_2 = _S360;
    (&imp_5)->inv0_2 = _S361;
    (&imp_5)->inv1_2 = _S362;
    (&imp_5)->inv2_2 = _S363;
    (&imp_5)->shape_0 = _S364;
    (&imp_5)->half_1 = _S365;
    (&imp_5)->mat_0 = _S366;
    (&imp_5)->crush_0 = _S367;
    (&imp_5)->geom_0 = _S368;
    (&imp_5)->rotation_err_1 = _S369;
    (&imp_5)->ledger_0 = _S370;
    (&imp_5)->cand_0 = _S371;
    (&imp_5)->momentum_1 = _S372;
    (&imp_5)->momentum_err_1 = _S373;
    float4 _S374 = float4(0.0f) ;
    thread float4 shares_0 = _S374;
    thread float4 unused_0 = _S374;
    uint k_8 = (&imp_5)->cand_0.x + tid_2;
    for(;;)
    {
        if(k_8 < ((&imp_5)->cand_0.y))
        {
        }
        else
        {
            break;
        }
        shares_0 = shares_0 + float4(*((&kernelContext_30)->scratch_0+((&kernelContext_30)->params_0->cand_base_0 + 3U * k_8))) ;
        k_8 = k_8 + 256U;
    }
    group_sum2_0(tid_2, &shares_0, &unused_0, &kernelContext_30);
    if(tid_2 != 0U)
    {
        _S350 = true;
    }
    else
    {
        _S350 = ((&imp_5)->cand_0.z) != 0U;
    }
    if(_S350)
    {
        return;
    }
    (&imp_5)->geom_0 = float4(1.0f, (&imp_5)->crush_0.w, 0.0f, 0.0f);
    float total_1 = shares_0.x;
    if(((&imp_5)->crush_0.x) > 0.0f)
    {
        _S350 = ((&imp_5)->crush_0.z) < ((&imp_5)->crush_0.y);
    }
    else
    {
        _S350 = false;
    }
    if(_S350)
    {
        _S350 = total_1 > ((&imp_5)->crush_0.x);
    }
    else
    {
        _S350 = false;
    }
    if(_S350)
    {
        float extra_0 = (total_1 - (&imp_5)->crush_0.x) / shares_0.y;
        (&imp_5)->crush_0.w = (&imp_5)->crush_0.w + extra_0;
        (&imp_5)->crush_0.z = (&imp_5)->crush_0.z + (&imp_5)->crush_0.x * extra_0;
        float _S375 = (&imp_5)->crush_0.x * extra_0;
        thread float _S376 = (&imp_5)->ledger_0.z;
        thread float _S377 = (&imp_5)->ledger_0.w;
        comp_add1_0(&_S376, &_S377, _S375);
        (&imp_5)->ledger_0.w = _S377;
        (&imp_5)->ledger_0.z = _S376;
        float _S378 = (&imp_5)->crush_0.x * extra_0;
        thread float _S379 = (&imp_5)->ledger_0.x;
        thread float _S380 = (&imp_5)->ledger_0.y;
        comp_add1_0(&_S379, &_S380, _S378);
        (&imp_5)->ledger_0.y = _S380;
        (&imp_5)->ledger_0.x = _S379;
        (&imp_5)->geom_0.x = (&imp_5)->crush_0.x / total_1;
    }
    Impactor_natural_0 device* _S381 = (&kernelContext_30)->impactors_0+ii_0;
    _S381->position_1 = packed_float4(imp_5.position_1) ;
    _S381->position_err_1 = packed_float4(imp_5.position_err_1) ;
    _S381->velocity_1 = packed_float4(imp_5.velocity_1) ;
    _S381->velocity_err_1 = packed_float4(imp_5.velocity_err_1) ;
    _S381->angular_velocity_1 = packed_float4(imp_5.angular_velocity_1) ;
    _S381->rotation_1 = packed_float4(imp_5.rotation_1) ;
    _S381->inertia0_2 = packed_float4(imp_5.inertia0_2) ;
    _S381->inertia1_2 = packed_float4(imp_5.inertia1_2) ;
    _S381->inertia2_2 = packed_float4(imp_5.inertia2_2) ;
    _S381->inv0_2 = packed_float4(imp_5.inv0_2) ;
    _S381->inv1_2 = packed_float4(imp_5.inv1_2) ;
    _S381->inv2_2 = packed_float4(imp_5.inv2_2) ;
    _S381->shape_0 = packed_float4(imp_5.shape_0) ;
    _S381->half_1 = packed_float4(imp_5.half_1) ;
    _S381->mat_0 = packed_float4(imp_5.mat_0) ;
    _S381->crush_0 = packed_float4(imp_5.crush_0) ;
    _S381->geom_0 = packed_float4(imp_5.geom_0) ;
    _S381->rotation_err_1 = packed_float4(imp_5.rotation_err_1) ;
    _S381->ledger_0 = packed_float4(imp_5.ledger_0) ;
    _S381->cand_0 = packed_uint4(imp_5.cand_0) ;
    _S381->momentum_1 = packed_float4(imp_5.momentum_1) ;
    _S381->momentum_err_1 = packed_float4(imp_5.momentum_err_1) ;
    return;
}

struct WideGroup_0
{
    uint island_3;
    uint begin_0;
    uint end_0;
    uint first_0;
};

WideGroup_0 wide_group_0(uint table_0, uint g_0, KernelContext_0 thread* kernelContext_31)
{
    thread WideGroup_0 w_4;
    uint _S382 = table_0 + 4U * g_0;
    (&w_4)->island_3 = kernelContext_31->index_0[_S382];
    (&w_4)->begin_0 = kernelContext_31->index_0[_S382 + 1U];
    (&w_4)->end_0 = kernelContext_31->index_0[_S382 + 2U];
    (&w_4)->first_0 = kernelContext_31->index_0[_S382 + 3U];
    return w_4;
}

void seen_clear_0(uint tid_3, KernelContext_0 thread* kernelContext_32)
{
    if(tid_3 < 5U)
    {
        (*kernelContext_32->g_seen_0)[tid_3] = 0U;
    }
    return;
}

bool contact_stopped_0(const Island_natural_0 thread* isl_0, KernelContext_0 thread* kernelContext_33)
{
    uint4 _S383 = uint4((kernelContext_33->islands_0+kernelContext_33->params_0->halt_index_0)->info_0) ;
    bool _S384;
    if(((_S383.z) & 1U) != 0U)
    {
        _S384 = true;
    }
    else
    {
        uint _S385 = _S383.y;
        if(_S385 != 0U)
        {
            _S384 = _S385 <= ((uint4(isl_0->info_0) ).w);
        }
        else
        {
            _S384 = false;
        }
    }
    return _S384;
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
    uint done_0;
    uint coverage_0;
    uint wide_groups_0;
    uint done_pad_0;
    uint4 probes_0;
    float4 energy_0;
    float4 rotation_err_0;
    float4 momentum_0;
    float4 momentum_err_0;
};

bool contact_stopped_1(const Island_0 thread* isl_1, KernelContext_0 thread* kernelContext_34)
{
    uint4 _S386 = uint4((kernelContext_34->islands_0+kernelContext_34->params_0->halt_index_0)->info_0) ;
    bool _S387;
    if(((_S386.z) & 1U) != 0U)
    {
        _S387 = true;
    }
    else
    {
        uint _S388 = _S386.y;
        if(_S388 != 0U)
        {
            _S387 = _S388 <= (isl_1->info_0.w);
        }
        else
        {
            _S387 = false;
        }
    }
    return _S387;
}

bool wide_runs_0(const Island_natural_0 thread* isl_2, KernelContext_0 thread* kernelContext_35)
{
    uint4 _S389 = uint4(isl_2->info_0) ;
    bool _S390;
    if(((_S389.z) & 1U) != 0U)
    {
        _S390 = true;
    }
    else
    {
        _S390 = (_S389.y) == 0U;
    }
    if(_S390)
    {
        return false;
    }
    if(((_S389.x) & 4U) == 0U)
    {
        _S390 = true;
    }
    else
    {
        bool _S391 = contact_stopped_0(isl_2, kernelContext_35);
        _S390 = !_S391;
    }
    return _S390;
}

bool wide_enter_0(uint tid_4, const Island_natural_0 thread* isl_3, KernelContext_0 thread* kernelContext_36)
{
    seen_clear_0(tid_4, kernelContext_36);
    if(tid_4 == 0U)
    {
        bool _S392 = wide_runs_0(isl_3, kernelContext_36);
        int _S393;
        if(_S392)
        {
            _S393 = int(1);
        }
        else
        {
            _S393 = int(0);
        }
        *kernelContext_36->g_wide_run_0 = uint(_S393);
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    return (*kernelContext_36->g_wide_run_0) != 0U;
}

uint wide_step_0(const Island_natural_0 thread* isl_4, KernelContext_0 thread* kernelContext_37)
{
    return (uint4(isl_4->info_0) ).w - kernelContext_37->params_0->step_start_0;
}

uint wide_step_1(const Island_natural_0 thread* isl_5, KernelContext_0 thread* kernelContext_38)
{
    return (uint4(isl_5->info_0) ).w - kernelContext_38->params_0->step_start_0;
}

uint wide_step_2(const Island_0 thread* isl_6, KernelContext_0 thread* kernelContext_39)
{
    return isl_6->info_0.w - kernelContext_39->params_0->step_start_0;
}

float time_since_0(float4 origin_0, uint k_9, float dt_2, KernelContext_0 thread* kernelContext_40)
{
    return kernelContext_40->params_0->t_hi_0 - origin_0.x + (kernelContext_40->params_0->t_lo_0 - origin_0.y) + float(k_9) * dt_2;
}

float table_eval_0(uint offset_0, uint count_3, float tau_0, KernelContext_0 thread* kernelContext_41)
{
    float4 _S394 = float4(*(kernelContext_41->loads_0+offset_0)) ;
    if(tau_0 <= (_S394.x))
    {
        return _S394.y;
    }
    uint i_5 = 1U;
    for(;;)
    {
        if(i_5 < count_3)
        {
        }
        else
        {
            break;
        }
        uint _S395 = offset_0 + i_5;
        float4 _S396 = float4(*(kernelContext_41->loads_0+_S395)) ;
        float _S397 = _S396.x;
        if(tau_0 <= _S397)
        {
            float4 _S398 = float4(*(kernelContext_41->loads_0+(_S395 - 1U))) ;
            float _S399 = _S398.x;
            float _S400 = _S398.y;
            return _S400 + (tau_0 - _S399) / max(_S397 - _S399, 1.00000000317107685e-30f) * (_S396.y - _S400);
        }
        i_5 = i_5 + 1U;
    }
    return (float4(*(kernelContext_41->loads_0+(offset_0 + count_3 - 1U))) ).y;
}

float eval_function_0(uint term_0, uint k_10, float dt_3, float shift_0, KernelContext_0 thread* kernelContext_42)
{
    uint _S401 = 5U * term_0;
    uint4 info_2 = (as_type<uint4>((float4(*(kernelContext_42->loads_0+_S401)) )));
    float4 _S402 = float4(*(kernelContext_42->loads_0+(_S401 + 3U))) ;
    float4 _S403 = float4(*(kernelContext_42->loads_0+(_S401 + 4U))) ;
    uint kind_0 = info_2.z;
    if(kind_0 == 0U)
    {
        return _S402.z;
    }
    float _S404 = time_since_0(_S402, k_10, dt_3, kernelContext_42);
    float tau_1 = _S404 + shift_0;
    float shape_1;
    if(kind_0 == 1U)
    {
        if(tau_1 <= 0.0f)
        {
            shape_1 = 0.0f;
        }
        else
        {
            float _S405 = _S403.x;
            if(tau_1 >= _S405)
            {
                shape_1 = _S403.y;
            }
            else
            {
                shape_1 = _S403.y * tau_1 / _S405;
            }
        }
        return shape_1;
    }
    bool _S406;
    if(kind_0 == 2U)
    {
        if(tau_1 < 0.0f)
        {
            _S406 = true;
        }
        else
        {
            _S406 = tau_1 > (_S403.x);
        }
        if(_S406)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S403.y * sin(3.14159274101257324f * tau_1 / _S403.x);
        }
        return shape_1;
    }
    if(kind_0 == 3U)
    {
        float sn_0 = tau_1 / _S403.y;
        if(sn_0 < 0.0f)
        {
            _S406 = true;
        }
        else
        {
            _S406 = sn_0 > 1.0f;
        }
        if(_S406)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S403.x * (1.0f - sn_0) * exp(- _S403.z * sn_0);
        }
        return shape_1;
    }
    if(kind_0 == 4U)
    {
        float _S407 = table_eval_0(info_2.w, (as_type<uint>((_S403.x))), tau_1, kernelContext_42);
        return _S407;
    }
    if(kind_0 == 5U)
    {
        (*kernelContext_42->g_seen_0)[1U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float sn_1 = tau_1 / _S403.x;
        if(sn_1 < 0.0f)
        {
            _S406 = true;
        }
        else
        {
            _S406 = sn_1 > 1.0f;
        }
        if(_S406)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = (1.0f - sn_1) * exp(- _S403.y * sn_1);
        }
        float clearing_0 = _S402.w;
        float relax_0;
        if(clearing_0 > 0.0f)
        {
            relax_0 = max(1.0f - tau_1 / clearing_0, 0.0f);
        }
        else
        {
            relax_0 = 0.0f;
        }
        float _S408 = _S403.w;
        return (_S408 + (_S403.z - _S408) * relax_0) * shape_1;
    }
    if(kind_0 == 7U)
    {
        (*kernelContext_42->g_seen_0)[2U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float _S409 = _S403.y;
        if(tau_1 < _S409)
        {
            return _S403.x;
        }
        float s_1 = tau_1 - _S409;
        float _S410 = _S403.w;
        if(s_1 > _S410)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S403.z * sin(3.14159274101257324f * s_1 / _S410);
        }
        return shape_1;
    }
    float _S411 = _S403.x;
    if(_S411 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp(1.0f - tau_1 / _S411, 0.0f, 1.0f);
}

void record_chunk_load_0(uint c_7, float3 f_1, float3 t_3, KernelContext_0 thread* kernelContext_43)
{
    if((kernelContext_43->params_0->solve_mode_0) == 0U)
    {
        return;
    }
    uint _S412 = 2U * c_7;
    *(kernelContext_43->scratch_0+(kernelContext_43->params_0->cload_base_0 + _S412)) = packed_float4(float4(f_1, 0.0f)) ;
    *(kernelContext_43->scratch_0+(kernelContext_43->params_0->cload_base_0 + _S412 + 1U)) = packed_float4(float4(t_3, 0.0f)) ;
    *(kernelContext_43->scratch_0+(kernelContext_43->params_0->cframe_base_0 + _S412)) = packed_float4(float4((float4(*(kernelContext_43->scratch_0+(kernelContext_43->params_0->cframe_base_0 + _S412))) ).xyz + f_1, 0.0f)) ;
    *(kernelContext_43->scratch_0+(kernelContext_43->params_0->cframe_base_0 + _S412 + 1U)) = packed_float4(float4((float4(*(kernelContext_43->scratch_0+(kernelContext_43->params_0->cframe_base_0 + _S412 + 1U))) ).xyz + t_3, 0.0f)) ;
    return;
}

void chunk_loads_0(uint _S413, uint _S414, const Quat_0 thread* _S415, uint _S416, float _S417, bool _S418, float _S419, float3 thread* _S420, float3 thread* _S421, float3 thread* _S422, float3 thread* _S423, KernelContext_0 thread* kernelContext_44)
{
    bool _S424;
    ChunkStatic_natural_0 device* _S425 = kernelContext_44->chunks_0+_S414;
    float3 _S426 = float3(0.0f) ;
    *_S420 = _S426;
    *_S421 = _S426;
    *_S422 = _S426;
    *_S423 = _S426;
    uint4 _S427 = uint4(_S425->load_range_0) ;
    uint term_1 = _S427.x;
    for(;;)
    {
        if(term_1 < (_S427.y))
        {
        }
        else
        {
            break;
        }
        (*kernelContext_44->g_seen_0)[0U] = 1U;
        uint _S428 = 5U * term_1;
        uint _S429 = (as_type<uint4>((float4(*(kernelContext_44->loads_0+_S428)) ))).y;
        bool replacement_0 = _S429 == 2U;
        float4 _S430 = float4(*(kernelContext_44->loads_0+(_S428 + 1U))) ;
        float4 _S431 = float4(*(kernelContext_44->loads_0+(_S428 + 2U))) ;
        float _S432;
        if(replacement_0)
        {
            _S432 = _S419;
        }
        else
        {
            _S432 = 0.0f;
        }
        float _S433 = eval_function_0(term_1, _S416, _S417, _S432, kernelContext_44);
        if(replacement_0)
        {
            float3 _S434 = float3(_S433) ;
            *_S422 = *_S422 + _S430.xyz * _S434;
            *_S423 = *_S423 + _S431.xyz * _S434;
            term_1 = term_1 + 1U;
            continue;
        }
        if(_S429 == 0U)
        {
            _S424 = true;
        }
        else
        {
            _S424 = _S429 == 3U;
        }
        float3 fw_0;
        if(_S424)
        {
            fw_0 = _S430.xyz * float3(_S433) ;
        }
        else
        {
            float3 _S435 = rotate_0(_S415, _S430.xyz);
            fw_0 = _S435 * float3((- _S433 * _S430.w)) ;
        }
        float3 lever_0;
        if(_S429 == 3U)
        {
            lever_0 = _S431.xyz - (float4(*(kernelContext_44->state_0+4U * _S413)) ).xyz;
        }
        else
        {
            lever_0 = _S431.xyz;
        }
        *_S420 = *_S420 + fw_0;
        float3 _S436 = rotate_0(_S415, lever_0);
        *_S421 = *_S421 + cross(_S436, fw_0);
        term_1 = term_1 + 1U;
    }
    if(_S418)
    {
        _S424 = ((uint4(_S425->cinfo_0) ).z) != 0U;
    }
    else
    {
        _S424 = false;
    }
    if(_S424)
    {
        uint4 _S437 = uint4(_S425->cinfo_0) ;
        uint g_1 = _S437.x;
        for(;;)
        {
            if(g_1 < (_S437.y))
            {
            }
            else
            {
                break;
            }
            uint _S438 = 2U * g_1;
            *_S420 = *_S420 + (float4(*(kernelContext_44->scratch_0+(kernelContext_44->params_0->seg_base_0 + _S438))) ).xyz;
            *_S421 = *_S421 + (float4(*(kernelContext_44->scratch_0+(kernelContext_44->params_0->seg_base_0 + _S438 + 1U))) ).xyz;
            g_1 = g_1 + 1U;
        }
    }
    return;
}

void chunk_external_0(uint _S439, uint _S440, const Quat_0 thread* _S441, uint _S442, float _S443, bool _S444, float3 thread* _S445, float3 thread* _S446, KernelContext_0 thread* kernelContext_45)
{
    thread float3 rf_0;
    thread float3 rm_0;
    chunk_loads_0(_S439, _S440, _S441, _S442, _S443, _S444, 0.0f, _S445, _S446, &rf_0, &rm_0, kernelContext_45);
    return;
}

float settled_chunk_load_0(uint c_8, const Quat_0 thread* rot_0, uint k_11, float dt_4, bool contact_0, KernelContext_0 thread* kernelContext_46)
{
    thread float3 f_2;
    thread float3 t_4;
    chunk_external_0(c_8, c_8, rot_0, k_11, dt_4, contact_0, &f_2, &t_4, kernelContext_46);
    record_chunk_load_0(c_8, f_2, t_4, kernelContext_46);
    return length(f_2);
}

uint seen_bits_0(KernelContext_0 thread* kernelContext_47)
{
    uint _S447;
    if(((*kernelContext_47->g_seen_0)[0U]) != 0U)
    {
        _S447 = 32768U;
    }
    else
    {
        _S447 = 0U;
    }
    uint _S448;
    if(((*kernelContext_47->g_seen_0)[1U]) != 0U)
    {
        _S448 = 65536U;
    }
    else
    {
        _S448 = 0U;
    }
    uint _S449 = _S447 | _S448;
    if(((*kernelContext_47->g_seen_0)[2U]) != 0U)
    {
        _S447 = 131072U;
    }
    else
    {
        _S447 = 0U;
    }
    uint _S450 = _S449 | _S447;
    if(((*kernelContext_47->g_seen_0)[3U]) != 0U)
    {
        _S447 = 32U;
    }
    else
    {
        _S447 = 0U;
    }
    uint _S451 = _S450 | _S447;
    if(((*kernelContext_47->g_seen_0)[4U]) != 0U)
    {
        _S447 = 64U;
    }
    else
    {
        _S447 = 0U;
    }
    return _S451 | _S447;
}

bool wide_enter_1(uint _S452, uint _S453, KernelContext_0 thread* kernelContext_48)
{
    thread Island_natural_0 _S454 = *(kernelContext_48->islands_0+_S453);
    seen_clear_0(_S452, kernelContext_48);
    if(_S452 == 0U)
    {
        bool _S455 = wide_runs_0(&_S454, kernelContext_48);
        int _S456;
        if(_S455)
        {
            _S456 = int(1);
        }
        else
        {
            _S456 = int(0);
        }
        *kernelContext_48->g_wide_run_0 = uint(_S456);
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    return (*kernelContext_48->g_wide_run_0) != 0U;
}

[[kernel]] void wide_wake(uint3 group_1 [[threadgroup_position_in_grid]], uint3 thread_1 [[thread_position_in_threadgroup]], Params_0 constant* params_4 [[buffer(0)]], Island_natural_0 device* islands_4 [[buffer(9)]], uint device* index_4 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_4 [[buffer(3)]], packed_float4 device* state_4 [[buffer(6)]], packed_float4 device* scratch_4 [[buffer(8)]], packed_float4 device* contact_state_4 [[buffer(11)]], packed_float4 device* loads_4 [[buffer(5)]], Impactor_natural_0 device* impactors_4 [[buffer(10)]], BondStatic_natural_0 device* bonds_4 [[buffer(2)]], MaterialTable_0 constant* materials_4 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_4 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_49;
    (&kernelContext_49)->params_0 = params_4;
    (&kernelContext_49)->islands_0 = islands_4;
    (&kernelContext_49)->index_0 = index_4;
    (&kernelContext_49)->chunks_0 = chunks_4;
    (&kernelContext_49)->state_0 = state_4;
    (&kernelContext_49)->scratch_0 = scratch_4;
    (&kernelContext_49)->contact_state_0 = contact_state_4;
    (&kernelContext_49)->loads_0 = loads_4;
    (&kernelContext_49)->impactors_0 = impactors_4;
    (&kernelContext_49)->bonds_0 = bonds_4;
    (&kernelContext_49)->materials_0 = materials_4;
    (&kernelContext_49)->bond_dyn_0 = bond_dyn_4;
    threadgroup array<float4, int(32)> g_part_a_4;
    (&kernelContext_49)->g_part_a_0 = &g_part_a_4;
    threadgroup array<float4, int(32)> g_part_b_4;
    (&kernelContext_49)->g_part_b_0 = &g_part_b_4;
    threadgroup array<uint, int(5)> g_seen_4;
    (&kernelContext_49)->g_seen_0 = &g_seen_4;
    threadgroup uint g_wide_run_4;
    (&kernelContext_49)->g_wide_run_0 = &g_wide_run_4;
    threadgroup uint g_halt_4;
    (&kernelContext_49)->g_halt_0 = &g_halt_4;
    threadgroup uint g_run_4;
    (&kernelContext_49)->g_run_0 = &g_run_4;
    uint tid_5 = thread_1.x;
    uint _S457 = group_1.x;
    WideGroup_0 _S458 = wide_group_0(params_4->wide_chunk_table_0, _S457, &kernelContext_49);
    if(_S457 != (_S458.first_0))
    {
        return;
    }
    thread Island_natural_0 _S459 = *((&kernelContext_49)->islands_0+_S458.island_3);
    uint4 _S460 = uint4((&_S459)->info_0) ;
    uint _S461 = _S460.x;
    bool _S462;
    if((_S461 & 16U) == 0U)
    {
        _S462 = true;
    }
    else
    {
        bool _S463 = wide_enter_1(tid_5, _S458.island_3, &kernelContext_49);
        _S462 = !_S463;
    }
    if(_S462)
    {
        return;
    }
    Quat_0 _S464 = quat_of_0(float4((&_S459)->rotation_0) );
    bool _S465 = (_S461 & 4U) != 0U;
    float3 _S466 = float3(0.0f) ;
    thread float3 norm_0 = _S466;
    thread float3 unused_1 = _S466;
    uint4 _S467 = uint4((&_S459)->range_0) ;
    uint c_9 = _S467.x + tid_5;
    for(;;)
    {
        if(c_9 < (_S467.y))
        {
        }
        else
        {
            break;
        }
        uint _S468 = wide_step_0(&_S459, &kernelContext_49);
        float _S469 = (&kernelContext_49)->params_0->dt_0;
        thread Quat_0 _S470 = _S464;
        float _S471 = settled_chunk_load_0(c_9, &_S470, _S468, _S469, _S465, &kernelContext_49);
        norm_0.x = norm_0.x + _S471;
        c_9 = c_9 + 256U;
    }
    group_sum3_0(tid_5, &norm_0, &unused_1, &kernelContext_49);
    if(tid_5 != 0U)
    {
        return;
    }
    uint _S472 = seen_bits_0(&kernelContext_49);
    uint cov_0 = 1024U | _S472;
    if(((&kernelContext_49)->params_0->solve_mode_0) == 1U)
    {
        float4 _S473 = float4((&_S459)->energy_0) ;
        _S462 = (abs(norm_0.x - _S473.z)) > (_S473.w);
    }
    else
    {
        _S462 = false;
    }
    uint cov_1;
    if(_S462)
    {
        ((&kernelContext_49)->islands_0+_S458.island_3)->info_0[int(0)] = _S461 & 4294967279U;
        ((&kernelContext_49)->islands_0+_S458.island_3)->info_0[int(2)] = (_S460.z) | 4U;
        cov_1 = cov_0 | 2048U;
    }
    else
    {
        cov_1 = cov_0;
    }
    cov_mark_0(_S458.island_3, (&_S459)->coverage_0, cov_1, &kernelContext_49);
    return;
}

bool is_damaged_0(const JointState_0 thread* st_0)
{
    bool _S474;
    if((st_0->damage_0) > 0.0f)
    {
        _S474 = true;
    }
    else
    {
        _S474 = (st_0->crush_1) > 0.0f;
    }
    return _S474;
}

bool connected_0(const JointState_0 thread* st_1, bool has_rebar_0)
{
    bool _S475;
    if((st_1->damage_0) < 1.0f)
    {
        _S475 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S475 = (st_1->rebar_broken_0) == 0.0f;
        }
        else
        {
            _S475 = false;
        }
    }
    return _S475;
}

struct Measures_0
{
    float tension_0;
    float shear_0;
    float normal_compression_0;
    float compression_0;
    float compressive_force_0;
};

Measures_0 stress_measures_0(const JointBond_natural_0 thread* b_23, float3 q_lin_0, float3 q_ang_0)
{
    float4 _S476 = float4(b_23->geom0_0) ;
    float area_2 = _S476.x;
    float _S477 = q_lin_0.z;
    float axial_0 = (metal::fast::divide((_S477), (area_2)));
    float4 _S478 = float4(b_23->geom1_0) ;
    float _S479 = (metal::fast::divide((abs(q_ang_0.x)), (_S478.x)));
    float _S480 = (metal::fast::divide((abs(q_ang_0.y)), (_S478.y)));
    float bending_0 = _S479 + _S480;
    float _S481 = q_lin_0.x;
    float _S482 = q_lin_0.y;
    float _S483 = (metal::fast::sqrt((_S481 * _S481 + _S482 * _S482)));
    float _S484 = (metal::fast::divide((_S483), (area_2)));
    float _S485 = (metal::fast::divide((abs(q_ang_0.z)), (_S476.w)));
    float shear_1 = _S484 + _S485;
    thread Measures_0 m_2;
    (&m_2)->tension_0 = axial_0 + bending_0;
    (&m_2)->shear_0 = shear_1;
    float _S486 = - axial_0;
    (&m_2)->normal_compression_0 = max(_S486, 0.0f);
    (&m_2)->compression_0 = _S486 + bending_0;
    (&m_2)->compressive_force_0 = max(- _S477, 0.0f);
    return m_2;
}

float expm1_accurate_0(float x_8)
{
    if((abs(x_8)) < 0.00100000004749745f)
    {
        return x_8 * (1.0f + x_8 * (0.5f + x_8 * 0.1666666716337204f));
    }
    return exp(x_8) - 1.0f;
}

float dif_factor_0(const JointMaterial_0 constant* mat_1, float strain_rate_1)
{
    float r_6 = abs(strain_rate_1);
    float4 _S487 = mat_1->dif_0;
    float ref_0 = mat_1->dif_0.x;
    if(r_6 <= ref_0)
    {
        return 1.0f;
    }
    float _S488 = _S487.z;
    float f_3;
    if(r_6 <= _S488)
    {
        float _S489 = (metal::fast::divide((r_6), (ref_0)));
        float _S490 = (metal::fast::pow((_S489), (_S487.y)));
        f_3 = _S490;
    }
    else
    {
        float _S491 = (metal::fast::divide((_S488), (ref_0)));
        float _S492 = (metal::fast::pow((_S491), (_S487.y)));
        float _S493 = (metal::fast::divide((r_6), (_S488)));
        float _S494 = (metal::fast::pow((_S493), (_S487.w)));
        f_3 = _S492 * _S494;
    }
    return clamp(f_3, 1.0f, mat_1->misc_0.x);
}

float fatigue_factor_0(const JointMaterial_0 constant* mat_2, float life_1)
{
    if(((mat_2->kind_flags_0.y) & 64U) == 0U)
    {
        return 1.0f;
    }
    float _S495 = clamp(life_1, 0.0f, 1.0f);
    float _S496 = (metal::fast::divide((1.0f), (mat_2->misc_0.y - 2.0f)));
    float _S497 = (metal::fast::pow((_S495), (_S496)));
    return _S497;
}

float infinity_0()
{
    return (as_type<float>((2139095040U)));
}

float4 failure_indices_0(const JointMaterial_0 constant* mat_3, const JointBond_natural_0 thread* b_24, const Measures_0 thread* m_3, float multiplier_0)
{
    float fc_0 = mat_3->strength_0.y * multiplier_0;
    float _S498 = min(mat_3->strength_0.z * multiplier_0 + mat_3->strength_0.w * m_3->normal_compression_0, mat_3->energy_1.x * multiplier_0);
    thread float4 idx_0;
    float _S499 = (metal::fast::divide((m_3->tension_0), (mat_3->strength_0.x * multiplier_0)));
    idx_0.x = max(_S499, 0.0f);
    float _S500;
    if(_S498 > 0.0f)
    {
        float _S501 = (metal::fast::divide((m_3->shear_0), (_S498)));
        _S500 = _S501;
    }
    else
    {
        _S500 = infinity_0();
    }
    idx_0.y = _S500;
    float _S502 = (metal::fast::divide((m_3->compression_0), (fc_0)));
    idx_0.z = max(_S502, 0.0f);
    float _S503 = (float4(b_24->stiff1_0) ).y;
    if(_S503 > 0.0f)
    {
        float _S504 = (metal::fast::divide((m_3->compressive_force_0), (_S503)));
        _S500 = _S504;
    }
    else
    {
        _S500 = 0.0f;
    }
    idx_0.w = _S500;
    return idx_0;
}

float sq_0(float x_9)
{
    return x_9 * x_9;
}

float damage_law_0(uint kind_1, float kappa_1, float r_7)
{
    if(kappa_1 <= 1.0f)
    {
        return 0.0f;
    }
    if(kind_1 == 0U)
    {
        if(r_7 <= 1.0f)
        {
            return 1.0f;
        }
        float _S505 = (metal::fast::divide((r_7 * (kappa_1 - 1.0f)), (kappa_1 * (r_7 - 1.0f))));
        return min(_S505, 1.0f);
    }
    if(kappa_1 >= (0.5f * (r_7 + 1.0f)))
    {
        return 1.0f;
    }
    float _S506 = (metal::fast::divide((1.0f), (kappa_1)));
    return 1.0f - _S506;
}

__attribute__((noinline))
float2 damage_increment_0(uint kind_2, float kappa_old_0, float lambda_0, float r_8, float d_old_0, float psi_0)
{
    float _S507 = damage_law_0(kind_2, lambda_0, r_8);
    float _S508 = max(_S507, d_old_0);
    bool _S509;
    if(_S508 <= d_old_0)
    {
        _S509 = true;
    }
    else
    {
        _S509 = d_old_0 >= 1.0f;
    }
    if(_S509)
    {
        return float2(d_old_0, 0.0f);
    }
    float u0_0 = (metal::fast::divide((psi_0), (lambda_0 * lambda_0)));
    float _S510 = max(kappa_old_0, 1.0f);
    if(kind_2 == 0U)
    {
        if(r_8 > 1.0f)
        {
            float _S511 = (metal::fast::divide((u0_0 * r_8), (r_8 - 1.0f)));
            return float2(_S508, _S511 * max(min(lambda_0, r_8) - min(_S510, r_8), 0.0f));
        }
        return float2(_S508, (1.0f - d_old_0) * psi_0);
    }
    float ku_0 = 0.5f * (r_8 + 1.0f);
    float plateau_0 = u0_0 * max(min(lambda_0, ku_0) - min(_S510, ku_0), 0.0f);
    float snap_0;
    if(_S508 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return float2(_S508, plateau_0 + snap_0);
}

void compressed_region_0(float w0_0, float w1_0, float dz_0, float ax_0, float ay_0, array<float, int(6)> thread* region_0)
{
    uint count_4;
    float h0_0 = 0.5f * w0_0;
    float h1_0 = 0.5f * w1_0;
    float _S512 = - h0_0;
    float _S513 = - h1_0;
    array<float2, int(4)> _S514 = { { float2(_S512, _S513), float2(h0_0, _S513), float2(h0_0, h1_0), float2(_S512, h1_0) } };
    thread array<float2, int(8)> poly_0;
    uint i_6 = 0U;
    uint count_5 = 0U;
    for(;;)
    {
        if(i_6 < 4U)
        {
        }
        else
        {
            break;
        }
        uint _S515 = i_6;
        uint _S516 = i_6 + 1U;
        uint _S517 = _S516 % 4U;
        float _S518 = _S514[i_6].y;
        float _S519 = _S514[i_6].x;
        float fp_0 = dz_0 + ax_0 * _S518 - ay_0 * _S519;
        float _S520 = _S514[_S517].y;
        float _S521 = _S514[_S517].x;
        float fq_0 = dz_0 + ax_0 * _S520 - ay_0 * _S521;
        bool _S522 = fp_0 < 0.0f;
        if(_S522)
        {
            uint _S523 = count_5 + 1U;
            poly_0[count_5] = _S514[_S515];
            count_4 = _S523;
        }
        else
        {
            count_4 = count_5;
        }
        if(_S522 != (fq_0 < 0.0f))
        {
            float t_5 = fp_0 / (fp_0 - fq_0);
            uint _S524 = count_4 + 1U;
            poly_0[count_4] = float2(_S519 + t_5 * (_S521 - _S519), _S518 + t_5 * (_S520 - _S518));
            count_5 = _S524;
        }
        else
        {
            count_5 = count_4;
        }
        i_6 = _S516;
    }
    count_4 = 0U;
    for(;;)
    {
        if(count_4 < 6U)
        {
        }
        else
        {
            break;
        }
        (*region_0)[count_4] = 0.0f;
        count_4 = count_4 + 1U;
    }
    if(count_5 < 3U)
    {
        return;
    }
    float2 o_1 = poly_0[int(0)];
    i_6 = 0U;
    float a_7 = 0.0f;
    float sx_0 = 0.0f;
    float sy_0 = 0.0f;
    float ixx_0 = 0.0f;
    float iyy_0 = 0.0f;
    float ixy_0 = 0.0f;
    for(;;)
    {
        if(i_6 < count_5)
        {
        }
        else
        {
            break;
        }
        float _S525 = o_1.x;
        float x0_0 = poly_0[i_6].x - _S525;
        float _S526 = o_1.y;
        float y0_0 = poly_0[i_6].y - _S526;
        uint _S527 = i_6 + 1U;
        uint _S528 = _S527 % count_5;
        float x1_0 = poly_0[_S528].x - _S525;
        float y1_0 = poly_0[_S528].y - _S526;
        float _S529 = x0_0 * y1_0;
        float _S530 = x1_0 * y0_0;
        float cr_0 = _S529 - _S530;
        float a_8 = a_7 + cr_0 / 2.0f;
        float sx_1 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        float sy_1 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        float ixx_1 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        float iyy_1 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        float ixy_1 = ixy_0 + (_S529 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S530) * cr_0 / 24.0f;
        i_6 = _S527;
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
    float _S531 = a_7 * cx_0;
    (*region_0)[int(3)] = ixx_0 - _S531 * cx_0;
    (*region_0)[int(4)] = iyy_0 - a_7 * cy_0 * cy_0;
    (*region_0)[int(5)] = ixy_0 - _S531 * cy_0;
    return;
}

__attribute__((noinline))
float4 no_tension_patch_0(float kn_0, float w0_1, float w1_1, float dz_1, float ax_1, float ay_1)
{
    thread array<float, int(6)> r_9;
    compressed_region_0(w0_1, w1_1, dz_1, ax_1, ay_1, &r_9);
    float a_9 = r_9[int(0)];
    if((r_9[int(0)]) == 0.0f)
    {
        return float4(0.0f) ;
    }
    float k_12 = kn_0 / (w0_1 * w1_1);
    float fc_1 = dz_1 + ax_1 * r_9[int(2)] - ay_1 * r_9[int(1)];
    float _S532 = a_9 * fc_1;
    float _S533 = - ay_1;
    return float4(k_12 * a_9 * fc_1, k_12 * (_S532 * r_9[int(2)] + (_S533 * r_9[int(5)] + ax_1 * r_9[int(4)])), - k_12 * (_S532 * r_9[int(1)] + (_S533 * r_9[int(3)] + ax_1 * r_9[int(5)])), 0.5f * k_12 * (_S532 * fc_1 + ay_1 * ay_1 * r_9[int(3)] + ax_1 * ax_1 * r_9[int(4)] - 2.0f * ax_1 * ay_1 * r_9[int(5)]));
}

float signum_0(float x_10)
{
    float _S534;
    if(((as_type<uint>((x_10))) & 2147483648U) != 0U)
    {
        _S534 = -1.0f;
    }
    else
    {
        _S534 = 1.0f;
    }
    return _S534;
}

float2 return_map_0(float k_13, float total_2, float plastic_0, float cap_0)
{
    float trial_0 = k_13 * (total_2 - plastic_0);
    if((abs(trial_0)) <= cap_0)
    {
        return float2(trial_0, 0.0f);
    }
    float f_4 = cap_0 * signum_0(trial_0);
    float _S535 = (metal::fast::divide((trial_0 - f_4), (k_13)));
    return float2(f_4, _S535);
}

struct Contact_0
{
    float3 q_lin_1;
    float3 q_ang_1;
    float energy_2;
    float diss_2;
    float3 plastic_1;
};

__attribute__((noinline))
Contact_0 contact_part_0(const JointMaterial_0 constant* mat_4, const JointBond_natural_0 thread* b_25, float crush_2, float3 plastic_2, float3 d_lin_0, float3 d_ang_0)
{
    thread Contact_0 c_10;
    float3 _S536 = float3(0.0f) ;
    (&c_10)->q_lin_1 = _S536;
    (&c_10)->q_ang_1 = _S536;
    (&c_10)->energy_2 = 0.0f;
    (&c_10)->diss_2 = 0.0f;
    (&c_10)->plastic_1 = plastic_2;
    uint _S537 = mat_4->kind_flags_0.y;
    if((_S537 & 2U) == 0U)
    {
        return c_10;
    }
    float4 _S538 = float4(b_25->stiff0_0) ;
    float kn_1 = _S538.x;
    float ks_0 = _S538.y;
    float kt_0 = (float4(b_25->stiff1_0) ).x;
    float4 _S539 = float4(b_25->geom0_0) ;
    float w0_2 = _S539.y;
    float w1_2 = _S539.z;
    float diss_3;
    float nc_sum_0;
    float m1_0;
    float m2_0;
    float energy_3;
    if((_S537 & 4U) != 0U)
    {
        float4 p_10 = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        float _S540 = p_10.y;
        float _S541 = p_10.z;
        float _S542 = p_10.w;
        nc_sum_0 = p_10.x;
        m1_0 = _S540;
        m2_0 = _S541;
        energy_3 = _S542;
    }
    else
    {
        float ki_0 = kn_1 * (1.0f - crush_2) / 36.0f;
        float _S543 = d_ang_0.x;
        float _S544 = d_ang_0.y;
        float spread_0 = abs(_S543) * 0.4166666567325592f * w1_2 + abs(_S544) * 0.4166666567325592f * w0_2;
        float _S545 = d_lin_0.z;
        float slack_0 = 9.99999997475242708e-07f * (abs(_S545) + spread_0);
        if((_S545 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S545 + spread_0) < (- slack_0))
            {
                float i1_0 = 2.91666650772094727f * w0_2 * w0_2;
                float i2_0 = 2.91666650772094727f * w1_2 * w1_2;
                float _S546 = ki_0 * _S543 * i2_0;
                float _S547 = ki_0 * _S544 * i1_0;
                float _S548 = 0.5f * ki_0 * (36.0f * _S545 * _S545 + _S543 * _S543 * i2_0 + _S544 * _S544 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S545;
                m1_0 = _S546;
                m2_0 = _S547;
                energy_3 = _S548;
            }
            else
            {
                uint i_7 = 0U;
                diss_3 = 0.0f;
                float m1_1 = 0.0f;
                float m2_1 = 0.0f;
                float energy_4 = 0.0f;
                for(;;)
                {
                    if(i_7 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float _S549 = SPRING_AT_0[i_7] * w0_2;
                    uint j_6 = 0U;
                    nc_sum_0 = diss_3;
                    m1_0 = m1_1;
                    m2_0 = m2_1;
                    energy_3 = energy_4;
                    for(;;)
                    {
                        if(j_6 < 6U)
                        {
                        }
                        else
                        {
                            break;
                        }
                        float s2_0 = SPRING_AT_0[j_6] * w1_2;
                        float di_0 = _S545 + _S543 * s2_0 - _S544 * _S549;
                        if(di_0 < 0.0f)
                        {
                            float f_5 = ki_0 * di_0;
                            float m1_2 = m1_0 + f_5 * s2_0;
                            float m2_2 = m2_0 - f_5 * _S549;
                            float energy_5 = energy_3 + 0.5f * ki_0 * di_0 * di_0;
                            nc_sum_0 = nc_sum_0 + f_5;
                            m1_0 = m1_2;
                            m2_0 = m2_2;
                            energy_3 = energy_5;
                        }
                        j_6 = j_6 + 1U;
                    }
                    i_7 = i_7 + 1U;
                    diss_3 = nc_sum_0;
                    m1_1 = m1_0;
                    m2_1 = m2_0;
                    energy_4 = energy_3;
                }
                nc_sum_0 = diss_3;
                m1_0 = m1_1;
                m2_0 = m2_1;
                energy_3 = energy_4;
            }
        }
    }
    float nc_0 = - nc_sum_0;
    thread float3 p_11 = plastic_2;
    (&c_10)->q_lin_1 = float3(0.0f, 0.0f, nc_sum_0);
    (&c_10)->q_ang_1 = float3(m1_0, m2_0, 0.0f);
    float slide_cap_0 = mat_4->strength_0.w * nc_0;
    float _S550 = ks_0 * (d_lin_0.x - plastic_2.x);
    float _S551 = ks_0 * (d_lin_0.y - plastic_2.y);
    float tn_0 = (metal::fast::sqrt((_S550 * _S550 + _S551 * _S551)));
    bool _S552;
    if(tn_0 > slide_cap_0)
    {
        _S552 = tn_0 > 0.0f;
    }
    else
    {
        _S552 = false;
    }
    if(_S552)
    {
        float _S553 = (metal::fast::divide((_S550), (tn_0)));
        float _S554 = (metal::fast::divide((_S551), (tn_0)));
        float dslip_0 = (metal::fast::divide((tn_0 - slide_cap_0), (ks_0)));
        p_11.x = p_11.x + _S553 * dslip_0;
        p_11.y = p_11.y + _S554 * dslip_0;
        (&c_10)->q_lin_1.x = _S553 * slide_cap_0;
        (&c_10)->q_lin_1.y = _S554 * slide_cap_0;
        diss_3 = slide_cap_0 * dslip_0;
    }
    else
    {
        (&c_10)->q_lin_1.x = _S550;
        (&c_10)->q_lin_1.y = _S551;
        diss_3 = 0.0f;
    }
    float2 tq_0 = return_map_0(kt_0, d_ang_0.z, p_11.z, slide_cap_0 * (float4(b_25->geom1_0) ).z);
    float _S555 = tq_0.x;
    float _S556 = tq_0.y;
    float diss_4 = diss_3 + abs(_S555) * abs(_S556);
    p_11.z = p_11.z + _S556;
    (&c_10)->q_ang_1.z = _S555;
    float _S557 = (metal::fast::divide((sq_0((&c_10)->q_lin_1.x)), (ks_0)));
    float _S558 = (metal::fast::divide((sq_0((&c_10)->q_lin_1.y)), (ks_0)));
    float _S559 = _S557 + _S558;
    float _S560 = (metal::fast::divide((sq_0(_S555)), (kt_0)));
    (&c_10)->energy_2 = energy_3 + 0.5f * (_S559 + _S560);
    (&c_10)->diss_2 = diss_4;
    (&c_10)->plastic_1 = p_11;
    return c_10;
}

float3 contact_offsets_0(const JointMaterial_0 constant* mat_5, const JointBond_natural_0 thread* b_26, float crush_3, float3 plastic_3, float3 d_lin_1, float3 d_ang_1)
{
    uint _S561 = mat_5->kind_flags_0.y;
    if((_S561 & 2U) == 0U)
    {
        return plastic_3;
    }
    float4 _S562 = float4(b_26->stiff0_0) ;
    float kn_2 = _S562.x;
    float ks_1 = _S562.y;
    float kt_1 = (float4(b_26->stiff1_0) ).x;
    float4 _S563 = float4(b_26->geom0_0) ;
    float w0_3 = _S563.y;
    float w1_3 = _S563.z;
    float nc_sum_1;
    if((_S561 & 4U) != 0U)
    {
        float4 _S564 = no_tension_patch_0(kn_2 * (1.0f - crush_3), w0_3, w1_3, d_lin_1.z, d_ang_1.x, d_ang_1.y);
        nc_sum_1 = _S564.x;
    }
    else
    {
        float ki_1 = kn_2 * (1.0f - crush_3) / 36.0f;
        float _S565 = d_ang_1.x;
        float _S566 = d_ang_1.y;
        float spread_1 = abs(_S565) * 0.4166666567325592f * w1_3 + abs(_S566) * 0.4166666567325592f * w0_3;
        float _S567 = d_lin_1.z;
        float slack_1 = 9.99999997475242708e-07f * (abs(_S567) + spread_1);
        if((_S567 - spread_1) > slack_1)
        {
            nc_sum_1 = 0.0f;
        }
        else
        {
            if((_S567 + spread_1) < (- slack_1))
            {
                nc_sum_1 = ki_1 * 36.0f * _S567;
            }
            else
            {
                uint i_8 = 0U;
                float nc_sum_2 = 0.0f;
                for(;;)
                {
                    if(i_8 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float _S568 = SPRING_AT_0[i_8] * w0_3;
                    uint j_7 = 0U;
                    nc_sum_1 = nc_sum_2;
                    for(;;)
                    {
                        if(j_7 < 6U)
                        {
                        }
                        else
                        {
                            break;
                        }
                        float di_1 = _S567 + _S565 * (SPRING_AT_0[j_7] * w1_3) - _S566 * _S568;
                        if(di_1 < 0.0f)
                        {
                            nc_sum_1 = nc_sum_1 + ki_1 * di_1;
                        }
                        j_7 = j_7 + 1U;
                    }
                    i_8 = i_8 + 1U;
                    nc_sum_2 = nc_sum_1;
                }
                nc_sum_1 = nc_sum_2;
            }
        }
    }
    float nc_1 = - nc_sum_1;
    thread float3 p_12 = plastic_3;
    float slide_cap_1 = mat_5->strength_0.w * nc_1;
    float _S569 = ks_1 * (d_lin_1.x - plastic_3.x);
    float _S570 = ks_1 * (d_lin_1.y - plastic_3.y);
    float tn_1 = (metal::fast::sqrt((_S569 * _S569 + _S570 * _S570)));
    bool _S571;
    if(tn_1 > slide_cap_1)
    {
        _S571 = tn_1 > 0.0f;
    }
    else
    {
        _S571 = false;
    }
    if(_S571)
    {
        float _S572 = (metal::fast::divide((_S569), (tn_1)));
        float _S573 = (metal::fast::divide((_S570), (tn_1)));
        float dslip_1 = (metal::fast::divide((tn_1 - slide_cap_1), (ks_1)));
        p_12.x = p_12.x + _S572 * dslip_1;
        p_12.y = p_12.y + _S573 * dslip_1;
    }
    float2 tq_1 = return_map_0(kt_1, d_ang_1.z, p_12.z, slide_cap_1 * (float4(b_26->geom1_0) ).z);
    p_12.z = p_12.z + tq_1.y;
    return p_12;
}

float life_rate_0(const JointMaterial_0 constant* mat_6, float s_2)
{
    if(s_2 <= 0.0f)
    {
        return 0.0f;
    }
    float _S574 = mat_6->misc_0.y;
    float _S575 = _S574 + 1.0f;
    float _S576 = (metal::fast::pow((s_2), (_S574)));
    float _S577 = (metal::fast::divide((_S575 * _S576), (mat_6->misc_0.z)));
    return _S577;
}

struct JointResponse_0
{
    float3 force_lin_1;
    float3 force_ang_1;
    JointState_0 state_5;
    float dissipated_2;
    float overshoot_0;
    float stored_3;
    bool disconnected_0;
    float fatigue_before_0;
    Measures_0 measures_0;
};

JointResponse_0 joint_evaluate_0(const JointMaterial_0 constant* mat_7, const JointBond_natural_0 thread* b_27, const JointState_0 thread* state_6, float3 d_lin_2, float3 d_ang_2, float dt_5, bool fracture_1)
{
    float4 _S578 = float4(b_27->stiff0_0) ;
    float kn_3 = _S578.x;
    float ks_2 = _S578.y;
    float kb1_0 = _S578.z;
    float kb2_0 = _S578.w;
    float4 _S579 = float4(b_27->stiff1_0) ;
    float kt_2 = _S579.x;
    bool has_rebar_1 = (_S579.w) != 0.0f;
    uint kind_3 = mat_7->kind_flags_0.x;
    uint flags_1 = mat_7->kind_flags_0.y;
    bool softening_0 = (flags_1 & 1U) != 0U;
    thread JointState_0 st_2 = *state_6;
    bool _S580 = connected_0(state_6, has_rebar_1);
    float3 qe_lin_0 = d_lin_2 * float3(ks_2, ks_2, kn_3);
    float3 qe_ang_0 = d_ang_2 * float3(kb1_0, kb2_0, kt_2);
    Measures_0 _S581 = stress_measures_0(b_27, qe_lin_0, qe_ang_0);
    float _S582 = max(max(_S581.tension_0, _S581.shear_0), _S581.compression_0);
    bool _S583 = dt_5 > 0.0f;
    float dif_1;
    if(_S583)
    {
        float _S584 = (metal::fast::divide((_S582 - (&st_2)->governing_stress_0), (dt_5)));
        float raw_0 = (metal::fast::divide((max(_S584, 0.0f)), (mat_7->misc_0.w)));
        float tau_2 = _S579.z;
        if((flags_1 & 16U) != 0U)
        {
            float _S585 = (metal::fast::divide((dt_5), (tau_2)));
            dif_1 = - expm1_accurate_0(- _S585);
        }
        else
        {
            float _S586 = (metal::fast::divide((dt_5), (tau_2)));
            dif_1 = min(_S586, 1.0f);
        }
        (&st_2)->strain_rate_0 = (&st_2)->strain_rate_0 + (raw_0 - (&st_2)->strain_rate_0) * dif_1;
        (&st_2)->governing_stress_0 = _S582;
    }
    if((flags_1 & 32U) != 0U)
    {
        float _S587 = dif_factor_0(mat_7, (&st_2)->strain_rate_0);
        dif_1 = _S587;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = (float4(b_27->geom1_0) ).w;
    float _S588 = fatigue_factor_0(mat_7, (&st_2)->life_0);
    float multiplier_1 = weibull_0 * dif_1 * _S588;
    thread Measures_0 _S589 = _S581;
    float4 _S590 = failure_indices_0(mat_7, b_27, &_S589, multiplier_1);
    float _S591 = _S590.x;
    float _S592 = _S590.y;
    (&st_2)->utilization_0 = max(max(_S591, _S592), max(_S590.z, _S590.w));
    float _S593 = d_lin_2.x;
    float _S594 = d_lin_2.y;
    float _S595 = ks_2 * (sq_0(_S593) + sq_0(_S594)) + kb1_0 * sq_0(d_ang_2.x) + kb2_0 * sq_0(d_ang_2.y) + kt_2 * sq_0(d_ang_2.z);
    float _S596 = d_lin_2.z;
    bool _S597 = _S596 > 0.0f;
    if(_S597)
    {
        dif_1 = kn_3 * sq_0(_S596);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S595 + dif_1);
    float psi_c_0;
    if(_S596 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_3 * sq_0(_S596);
    }
    else
    {
        psi_c_0 = 0.0f;
    }
    float3 plastic_4 = float3((&st_2)->plastic_x_0, (&st_2)->plastic_y_0, (&st_2)->plastic_t_0);
    float diss_contact_0;
    float psi_contact_0;
    float intact_normal_0;
    float dissipated_3;
    float overshoot_1;
    bool _S598;
    float3 qc_lin_0;
    if(fracture_1)
    {
        bool _S599 = _S591 >= _S592;
        if(_S599)
        {
            diss_contact_0 = _S591;
        }
        else
        {
            diss_contact_0 = _S592;
        }
        uint mode_ts_0;
        if(_S599)
        {
            mode_ts_0 = 1U;
        }
        else
        {
            mode_ts_0 = 2U;
        }
        if(diss_contact_0 > ((&st_2)->kappa_0))
        {
            _S598 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S598 = false;
        }
        if(_S598)
        {
            _S598 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S598 = false;
        }
        uint mode_c_0;
        if(_S598)
        {
            if(mode_ts_0 == 1U)
            {
                psi_contact_0 = mat_7->energy_1.y;
            }
            else
            {
                psi_contact_0 = mat_7->energy_1.z;
            }
            if(softening_0)
            {
                float _S600 = (metal::fast::divide((psi_contact_0 * (float4(b_27->geom0_0) ).x * diss_contact_0 * diss_contact_0), (psi_ts_0)));
                intact_normal_0 = _S600;
            }
            else
            {
                intact_normal_0 = 0.0f;
            }
            (&st_2)->ductility_0 = intact_normal_0;
            if(softening_0)
            {
                mode_c_0 = kind_3;
            }
            else
            {
                mode_c_0 = 0U;
            }
            float2 inc_0 = damage_increment_0(mode_c_0, (&st_2)->kappa_0, diss_contact_0, intact_normal_0, (&st_2)->damage_0, psi_ts_0);
            float _S601 = inc_0.x;
            if(_S601 > ((&st_2)->damage_0))
            {
                Contact_0 _S602 = contact_part_0(mat_7, b_27, (&st_2)->crush_1, plastic_4, d_lin_2, d_ang_2);
                float _S603 = max(_S602.energy_2 - (1.0f - (&st_2)->crush_1) * psi_c_0, 0.0f);
                float _S604 = max(inc_0.y - _S603 * (_S601 - (&st_2)->damage_0), 0.0f);
                float _S605 = max((psi_ts_0 - _S603) * (_S601 - (&st_2)->damage_0) - _S604, 0.0f);
                (&st_2)->damage_0 = _S601;
                (&st_2)->mode_0 = mode_ts_0;
                dissipated_3 = _S604;
                overshoot_1 = _S605;
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
        (&st_2)->kappa_0 = max((&st_2)->kappa_0, diss_contact_0);
        float _S606 = state_6->damage_0;
        if((state_6->damage_0) > 0.0f)
        {
            Contact_0 _S607 = contact_part_0(mat_7, b_27, state_6->crush_1, float3(state_6->plastic_x_0, state_6->plastic_y_0, state_6->plastic_t_0), d_lin_2, d_ang_2);
            qc_lin_0 = qe_ang_0 * float3((1.0f - _S606))  + _S607.q_ang_1 * float3(_S606) ;
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S608 = stress_measures_0(b_27, float3(0.0f, 0.0f, min(qe_lin_0.z, 0.0f)), qc_lin_0);
        thread Measures_0 _S609 = _S608;
        float4 _S610 = failure_indices_0(mat_7, b_27, &_S609, multiplier_1);
        float _S611 = _S610.z;
        float _S612 = _S610.w;
        bool _S613 = _S611 >= _S612;
        if(_S613)
        {
            psi_contact_0 = _S611;
        }
        else
        {
            psi_contact_0 = _S612;
        }
        if(_S613)
        {
            mode_c_0 = 3U;
        }
        else
        {
            mode_c_0 = 4U;
        }
        if(psi_contact_0 > ((&st_2)->kappa_c_0))
        {
            _S598 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S598 = false;
        }
        if(_S598)
        {
            _S598 = psi_c_0 > 0.0f;
        }
        else
        {
            _S598 = false;
        }
        if(_S598)
        {
            if(softening_0)
            {
                float _S614 = (metal::fast::divide((mat_7->energy_1.w * (float4(b_27->geom0_0) ).x * psi_contact_0 * psi_contact_0), (psi_c_0)));
                intact_normal_0 = _S614;
            }
            else
            {
                intact_normal_0 = 0.0f;
            }
            (&st_2)->ductility_c_0 = intact_normal_0;
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
            float2 inc_1 = damage_increment_0(law_1, (&st_2)->kappa_c_0, psi_contact_0, intact_normal_0, (&st_2)->crush_1, psi_c_0);
            float _S615 = inc_1.x;
            if(_S615 > ((&st_2)->crush_1))
            {
                float _S616 = inc_1.y;
                float dissipated_4 = dissipated_3 + _S616;
                float overshoot_2 = overshoot_1 + max(psi_c_0 * (_S615 - (&st_2)->crush_1) - _S616, 0.0f);
                (&st_2)->crush_1 = _S615;
                (&st_2)->mode_0 = mode_c_0;
                if(_S615 >= 1.0f)
                {
                    _S598 = ((&st_2)->damage_0) < 1.0f;
                }
                else
                {
                    _S598 = false;
                }
                if(_S598)
                {
                    float dissipated_5 = dissipated_4 + psi_ts_0 * (1.0f - (&st_2)->damage_0);
                    (&st_2)->damage_0 = 1.0f;
                    dissipated_3 = dissipated_5;
                }
                else
                {
                    dissipated_3 = dissipated_4;
                }
                overshoot_1 = overshoot_2;
            }
        }
        (&st_2)->kappa_c_0 = max((&st_2)->kappa_c_0, psi_contact_0);
    }
    else
    {
        dissipated_3 = 0.0f;
        overshoot_1 = 0.0f;
    }
    float dmg_0 = (&st_2)->damage_0;
    float3 _S617 = float3(0.0f) ;
    float3 qc_ang_0;
    if(((&st_2)->damage_0) == 0.0f)
    {
        if((flags_1 & 8U) == 0U)
        {
            float3 _S618 = contact_offsets_0(mat_7, b_27, (&st_2)->crush_1, plastic_4, d_lin_2, d_ang_2);
            (&st_2)->plastic_x_0 = _S618.x;
            (&st_2)->plastic_y_0 = _S618.y;
            (&st_2)->plastic_t_0 = _S618.z;
        }
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S617;
        qc_ang_0 = _S617;
        psi_contact_0 = 0.0f;
    }
    else
    {
        Contact_0 _S619 = contact_part_0(mat_7, b_27, (&st_2)->crush_1, plastic_4, d_lin_2, d_ang_2);
        (&st_2)->plastic_x_0 = _S619.plastic_1.x;
        (&st_2)->plastic_y_0 = _S619.plastic_1.y;
        (&st_2)->plastic_t_0 = _S619.plastic_1.z;
        diss_contact_0 = _S619.diss_2;
        qc_lin_0 = _S619.q_lin_1;
        qc_ang_0 = _S619.q_ang_1;
        psi_contact_0 = _S619.energy_2;
    }
    float dissipated_6 = dissipated_3 + dmg_0 * diss_contact_0;
    if(_S597)
    {
        intact_normal_0 = kn_3 * _S596;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_2)->crush_1) * kn_3 * _S596;
    }
    float _S620 = 1.0f - dmg_0;
    float3 force_lin_2 = float3(_S620 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S620 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S620 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3 force_ang_2 = qe_ang_0 * float3(_S620)  + qc_ang_0 * float3(dmg_0) ;
    float stored_4 = _S620 * (psi_ts_0 + (1.0f - (&st_2)->crush_1) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S598 = ((&st_2)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S598 = false;
    }
    float stored_5;
    float3 force_lin_3;
    if(_S598)
    {
        float4 _S621 = float4(b_27->rebar0_0) ;
        float k_axial_0 = _S621.x;
        float k_dowel_0 = _S621.y;
        float yield_force_0 = _S621.z;
        float dowel_capacity_0 = _S621.w;
        float2 nr_0 = return_map_0(k_axial_0, _S596, (&st_2)->rebar_plastic_0, yield_force_0);
        float2 v1_0 = return_map_0(k_dowel_0, _S593, (&st_2)->rebar_slip0_0, dowel_capacity_0);
        float2 v2_0 = return_map_0(k_dowel_0, _S594, (&st_2)->rebar_slip1_0, dowel_capacity_0);
        float _S622 = nr_0.y;
        float _S623 = v1_0.y;
        float _S624 = v2_0.y;
        float work_0 = yield_force_0 * abs(_S622) + dowel_capacity_0 * (abs(_S623) + abs(_S624));
        (&st_2)->rebar_plastic_0 = (&st_2)->rebar_plastic_0 + _S622;
        (&st_2)->rebar_slip0_0 = (&st_2)->rebar_slip0_0 + _S623;
        (&st_2)->rebar_slip1_0 = (&st_2)->rebar_slip1_0 + _S624;
        (&st_2)->rebar_work_0 = (&st_2)->rebar_work_0 + work_0;
        float dissipated_7 = dissipated_6 + work_0;
        float _S625 = nr_0.x;
        float _S626 = (metal::fast::divide((sq_0(_S625)), (k_axial_0)));
        float _S627 = v1_0.x;
        float _S628 = v2_0.x;
        float _S629 = (metal::fast::divide((sq_0(_S627) + sq_0(_S628)), (k_dowel_0)));
        float elastic_0 = 0.5f * (_S626 + _S629);
        if(fracture_1)
        {
            _S598 = ((&st_2)->rebar_work_0) >= ((float4(b_27->rebar1_0) ).x);
        }
        else
        {
            _S598 = false;
        }
        if(_S598)
        {
            (&st_2)->rebar_broken_0 = 1.0f;
            float dissipated_8 = dissipated_7 + elastic_0;
            force_lin_3 = force_lin_2;
            dissipated_3 = dissipated_8;
            stored_5 = stored_4;
        }
        else
        {
            float stored_6 = stored_4 + elastic_0;
            force_lin_3 = force_lin_2 + float3(_S627, _S628, _S625);
            dissipated_3 = dissipated_7;
            stored_5 = stored_6;
        }
    }
    else
    {
        force_lin_3 = force_lin_2;
        dissipated_3 = dissipated_6;
        stored_5 = stored_4;
    }
    if(fracture_1)
    {
        _S598 = _S583;
    }
    else
    {
        _S598 = false;
    }
    if(_S598)
    {
        _S598 = (flags_1 & 64U) != 0U;
    }
    else
    {
        _S598 = false;
    }
    if(_S598)
    {
        Measures_0 _S630 = stress_measures_0(b_27, force_lin_3, force_ang_2);
        thread Measures_0 _S631 = _S630;
        float4 _S632 = failure_indices_0(mat_7, b_27, &_S631, weibull_0);
        float _S633 = life_rate_0(mat_7, max(max(_S632.x, _S632.y), _S632.z));
        (&st_2)->life_0 = max((&st_2)->life_0 - _S633 * dt_5, 0.0f);
    }
    (&st_2)->dissipated_0 = (&st_2)->dissipated_0 + dissipated_3;
    thread JointResponse_0 resp_0;
    (&resp_0)->force_lin_1 = force_lin_3;
    (&resp_0)->force_ang_1 = force_ang_2;
    (&resp_0)->state_5 = st_2;
    (&resp_0)->dissipated_2 = dissipated_3;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_3 = stored_5;
    if(_S580)
    {
        thread JointState_0 _S634 = st_2;
        bool _S635 = connected_0(&_S634, has_rebar_1);
        _S598 = !_S635;
    }
    else
    {
        _S598 = false;
    }
    (&resp_0)->disconnected_0 = _S598;
    (&resp_0)->fatigue_before_0 = _S588;
    (&resp_0)->measures_0 = _S581;
    return resp_0;
}

void secant_factors_0(const JointBond_natural_0 thread* b_28, const JointState_0 thread* st_3, float3 d_lin_3, float3 thread* f_lin_0, float3 thread* f_ang_0)
{
    float _S636 = st_3->damage_0;
    bool compressed_0 = (d_lin_3.z) < 0.0f;
    float contact_1;
    if(compressed_0)
    {
        contact_1 = _S636;
    }
    else
    {
        contact_1 = 0.0f;
    }
    float _S637 = 1.0f - _S636;
    float _S638 = max(_S637 + contact_1, 9.99999997475242708e-07f);
    float normal_5;
    if(compressed_0)
    {
        normal_5 = max(1.0f - st_3->crush_1, 9.99999997475242708e-07f);
    }
    else
    {
        normal_5 = max(_S637, 9.99999997475242708e-07f);
    }
    *f_lin_0 = float3(_S638, _S638, normal_5);
    *f_ang_0 = float3(_S638) ;
    bool _S639;
    if(((float4(b_28->stiff1_0) ).w) != 0.0f)
    {
        _S639 = (st_3->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S639 = false;
    }
    if(_S639)
    {
        float4 _S640 = float4(b_28->rebar0_0) ;
        float4 _S641 = float4(b_28->stiff0_0) ;
        float _S642 = (metal::fast::divide((_S640.x), (_S641.x)));
        (*f_lin_0).z = (*f_lin_0).z + _S642;
        float _S643 = _S640.y;
        float _S644 = _S641.y;
        float _S645 = (metal::fast::divide((_S643), (_S644)));
        (*f_lin_0).x = (*f_lin_0).x + _S645;
        float _S646 = (metal::fast::divide((_S643), (_S644)));
        (*f_lin_0).y = (*f_lin_0).y + _S646;
    }
    return;
}

float3 to_local_0(uint _S647, float3 _S648, KernelContext_0 thread* kernelContext_50)
{
    BondStatic_natural_0 device* _S649 = kernelContext_50->bonds_0+_S647;
    return float3(dot(_S648, (float4(_S649->t1_0) ).xyz), dot(_S648, (float4(_S649->t2_0) ).xyz), dot(_S648, (float4(_S649->normal_0) ).xyz));
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

float3 to_body_0(uint _S650, float3 _S651, KernelContext_0 thread* kernelContext_51)
{
    BondStatic_natural_0 device* _S652 = kernelContext_51->bonds_0+_S650;
    return (float4(_S652->t1_0) ).xyz * float3(_S651.x)  + (float4(_S652->t2_0) ).xyz * float3(_S651.y)  + (float4(_S652->normal_0) ).xyz * float3(_S651.z) ;
}

bool bond_update_0(uint i_9, float dt_6, bool fracture_2, uint abs_step_0, bool wide_0, KernelContext_0 thread* kernelContext_52)
{
    BondStatic_natural_0 device* _S653 = kernelContext_52->bonds_0+i_9;
    uint4 _S654 = uint4(_S653->law_0.ids_0) ;
    float3 ra_1 = (float4(_S653->ra_0) ).xyz;
    float3 rb_1 = (float4(_S653->rb_0) ).xyz;
    uint _S655 = 4U * _S654.y;
    float3 ta_2 = (float4(*(kernelContext_52->state_0+(_S655 + 1U))) ).xyz;
    float3 va_0 = (float4(*(kernelContext_52->state_0+(_S655 + 2U))) ).xyz;
    float3 wa_1 = (float4(*(kernelContext_52->state_0+(_S655 + 3U))) ).xyz;
    uint _S656 = 4U * _S654.z;
    float3 tb_2 = (float4(*(kernelContext_52->state_0+(_S656 + 1U))) ).xyz;
    float3 vb_0 = (float4(*(kernelContext_52->state_0+(_S656 + 2U))) ).xyz;
    float3 wb_1 = (float4(*(kernelContext_52->state_0+(_S656 + 3U))) ).xyz;
    float3 _S657 = to_local_0(i_9, (float4(*(kernelContext_52->state_0+_S656)) ).xyz + cross(tb_2, rb_1) - ((float4(*(kernelContext_52->state_0+_S655)) ).xyz + cross(ta_2, ra_1)), kernelContext_52);
    float3 _S658 = to_local_0(i_9, tb_2 - ta_2, kernelContext_52);
    float3 _S659 = to_local_0(i_9, vb_0 + cross(wb_1, rb_1) - (va_0 + cross(wa_1, ra_1)), kernelContext_52);
    float3 _S660 = to_local_0(i_9, wb_1 - wa_1, kernelContext_52);
    JointState_0 previous_0 = (kernelContext_52->bond_dyn_0+i_9)->js_0;
    thread JointState_0 _S661 = (kernelContext_52->bond_dyn_0+i_9)->js_0;
    bool _S662 = is_damaged_0(&_S661);
    thread JointBond_natural_0 _S663 = (kernelContext_52->bonds_0+i_9)->law_0;
    thread JointState_0 _S664 = (kernelContext_52->bond_dyn_0+i_9)->js_0;
    JointResponse_0 _S665 = joint_evaluate_0(&kernelContext_52->materials_0->m_0[(uint4((kernelContext_52->bonds_0+i_9)->law_0.ids_0) ).x], &_S663, &_S664, _S657, _S658, dt_6, fracture_2);
    BondStatic_natural_0 device* _S666 = kernelContext_52->bonds_0+i_9;
    BondDyn_natural_0 device* _S667 = kernelContext_52->bond_dyn_0+i_9;
    float4 _S668 = float4((*_S667).force_lin_0) ;
    float4 _S669 = float4((*_S667).force_ang_0) ;
    float4 _S670 = float4((*_S667).sums_0) ;
    float4 _S671 = float4((*_S667).comps_0) ;
    uint4 _S672 = uint4((*_S667).events_0) ;
    thread BondDyn_0 bd_0;
    (&bd_0)->js_0 = (*_S667).js_0;
    (&bd_0)->force_lin_0 = _S668;
    (&bd_0)->force_ang_0 = _S669;
    (&bd_0)->sums_0 = _S670;
    (&bd_0)->comps_0 = _S671;
    (&bd_0)->events_0 = _S672;
    float3 ra_2 = (float4(_S666->ra_0) ).xyz;
    float3 rb_2 = (float4(_S666->rb_0) ).xyz;
    thread JointBond_natural_0 _S673 = _S666->law_0;
    thread JointState_0 _S674 = _S665.state_5;
    thread float3 f_lin_1;
    thread float3 f_ang_1;
    secant_factors_0(&_S673, &_S674, _S657, &f_lin_1, &f_ang_1);
    float3 qd_lin_0 = _S659 * (float4(_S666->c_lin_0) ).xyz * f_lin_1;
    float3 qd_ang_0 = _S660 * (float4(_S666->c_ang_0) ).xyz * f_ang_1;
    float3 q_lin_2 = _S665.force_lin_1 + qd_lin_0;
    float3 q_ang_2 = _S665.force_ang_1 + qd_ang_0;
    float damped_0 = (dot(qd_lin_0, _S659) + dot(qd_ang_0, _S660)) * dt_6;
    float3 _S675 = to_body_0(i_9, q_lin_2, kernelContext_52);
    float3 _S676 = to_body_0(i_9, q_ang_2, kernelContext_52);
    uint _S677 = 3U * i_9;
    *(kernelContext_52->scratch_0+_S677) = packed_float4(float4(_S675, max(_S665.measures_0.tension_0, _S665.measures_0.compression_0))) ;
    *(kernelContext_52->scratch_0+(_S677 + 1U)) = packed_float4(float4(_S676 + cross(ra_2, _S675), 0.0f)) ;
    *(kernelContext_52->scratch_0+(_S677 + 2U)) = packed_float4(float4(- _S676 + cross(rb_2, - _S675), 0.0f)) ;
    thread float _S678 = (&bd_0)->sums_0.x;
    thread float _S679 = (&bd_0)->comps_0.x;
    comp_add1_0(&_S678, &_S679, _S665.dissipated_2);
    (&bd_0)->comps_0.x = _S679;
    (&bd_0)->sums_0.x = _S678;
    thread float _S680 = (&bd_0)->sums_0.y;
    thread float _S681 = (&bd_0)->comps_0.y;
    comp_add1_0(&_S680, &_S681, _S665.overshoot_0);
    (&bd_0)->comps_0.y = _S681;
    (&bd_0)->sums_0.y = _S680;
    thread float _S682 = (&bd_0)->sums_0.z;
    thread float _S683 = (&bd_0)->comps_0.z;
    comp_add1_0(&_S682, &_S683, damped_0);
    (&bd_0)->comps_0.z = _S683;
    (&bd_0)->sums_0.z = _S682;
    (&bd_0)->force_lin_0 = float4(q_lin_2, _S665.stored_3);
    (&bd_0)->force_ang_0 = float4(q_ang_2, max((&bd_0)->force_ang_0.w, _S665.state_5.utilization_0));
    bool _S684;
    if(!_S662)
    {
        thread JointState_0 _S685 = _S665.state_5;
        bool _S686 = is_damaged_0(&_S685);
        _S684 = _S686;
    }
    else
    {
        _S684 = false;
    }
    if(_S684)
    {
        _S684 = ((&bd_0)->events_0.x) == 0U;
    }
    else
    {
        _S684 = false;
    }
    if(_S684)
    {
        (&bd_0)->events_0.x = abs_step_0;
        (&bd_0)->events_0.w = _S665.state_5.mode_0;
        if(wide_0)
        {
            cov_or_0((uint4((&_S673)->ids_0) ).w, 32U, kernelContext_52);
        }
        else
        {
            (*kernelContext_52->g_seen_0)[3U] = 1U;
        }
    }
    if(((&bd_0)->events_0.y) == 0U)
    {
        _S684 = (_S665.state_5.life_0) != (previous_0.life_0);
    }
    else
    {
        _S684 = false;
    }
    if(_S684)
    {
        _S684 = (_S665.fatigue_before_0) > 0.99000000953674316f;
    }
    else
    {
        _S684 = false;
    }
    if(_S684)
    {
        float _S687 = fatigue_factor_0(&kernelContext_52->materials_0->m_0[(uint4((kernelContext_52->bonds_0+i_9)->law_0.ids_0) ).x], _S665.state_5.life_0);
        _S684 = _S687 <= 0.99000000953674316f;
    }
    else
    {
        _S684 = false;
    }
    if(_S684)
    {
        (&bd_0)->events_0.y = abs_step_0;
        if(wide_0)
        {
            cov_or_0((uint4((&_S673)->ids_0) ).w, 64U, kernelContext_52);
        }
        else
        {
            (*kernelContext_52->g_seen_0)[4U] = 1U;
        }
    }
    if(_S665.disconnected_0)
    {
        (&bd_0)->events_0.z = abs_step_0;
    }
    (&bd_0)->js_0 = _S665.state_5;
    BondDyn_natural_0 device* _S688 = kernelContext_52->bond_dyn_0+i_9;
    _S688->js_0 = bd_0.js_0;
    _S688->force_lin_0 = packed_float4(bd_0.force_lin_0) ;
    _S688->force_ang_0 = packed_float4(bd_0.force_ang_0) ;
    _S688->sums_0 = packed_float4(bd_0.sums_0) ;
    _S688->comps_0 = packed_float4(bd_0.comps_0) ;
    _S688->events_0 = packed_uint4(bd_0.events_0) ;
    return _S665.disconnected_0;
}

struct Rigid_0
{
    Quat_0 rot_1;
    float4 rot_err_0;
    float3 pos_0;
    float3 pos_err_0;
    float3 vel_0;
    float3 vel_err_0;
    float3 w_5;
    float3 l_1;
    float3 l_err_0;
    float3 torque_0;
    float3 a_10;
    float3 alpha_0;
};

Rigid_0 rigid_of_0(const Island_natural_0 thread* isl_7)
{
    thread Rigid_0 rg_0;
    (&rg_0)->rot_1 = quat_of_0(float4(isl_7->rotation_0) );
    (&rg_0)->rot_err_0 = float4(isl_7->rotation_err_0) ;
    (&rg_0)->pos_0 = (float4(isl_7->position_0) ).xyz;
    (&rg_0)->pos_err_0 = (float4(isl_7->position_err_0) ).xyz;
    (&rg_0)->vel_0 = (float4(isl_7->velocity_0) ).xyz;
    (&rg_0)->vel_err_0 = (float4(isl_7->velocity_err_0) ).xyz;
    (&rg_0)->w_5 = (float4(isl_7->angular_velocity_0) ).xyz;
    (&rg_0)->l_1 = (float4(isl_7->momentum_0) ).xyz;
    (&rg_0)->l_err_0 = (float4(isl_7->momentum_err_0) ).xyz;
    float3 _S689 = float3(0.0f) ;
    (&rg_0)->torque_0 = _S689;
    (&rg_0)->a_10 = _S689;
    (&rg_0)->alpha_0 = _S689;
    return rg_0;
}

Rigid_0 rigid_of_1(const Island_0 thread* isl_8)
{
    thread Rigid_0 rg_1;
    (&rg_1)->rot_1 = quat_of_0(isl_8->rotation_0);
    (&rg_1)->rot_err_0 = isl_8->rotation_err_0;
    (&rg_1)->pos_0 = isl_8->position_0.xyz;
    (&rg_1)->pos_err_0 = isl_8->position_err_0.xyz;
    (&rg_1)->vel_0 = isl_8->velocity_0.xyz;
    (&rg_1)->vel_err_0 = isl_8->velocity_err_0.xyz;
    (&rg_1)->w_5 = isl_8->angular_velocity_0.xyz;
    (&rg_1)->l_1 = isl_8->momentum_0.xyz;
    (&rg_1)->l_err_0 = isl_8->momentum_err_0.xyz;
    float3 _S690 = float3(0.0f) ;
    (&rg_1)->torque_0 = _S690;
    (&rg_1)->a_10 = _S690;
    (&rg_1)->alpha_0 = _S690;
    return rg_1;
}

void net_load_0(uint c_11, const Island_natural_0 thread* isl_9, const Rigid_0 thread* rg_2, uint k_14, float dt_7, bool contact_2, float3 thread* f_6, float3 thread* t_6, KernelContext_0 thread* kernelContext_53)
{
    ChunkStatic_natural_0 device* _S691 = kernelContext_53->chunks_0+c_11;
    thread float3 fl_0;
    thread float3 tl_0;
    thread float3 rep_f_0;
    thread float3 rep_m_0;
    chunk_loads_0(c_11, c_11, &rg_2->rot_1, k_14, dt_7, contact_2, 0.0f, &fl_0, &tl_0, &rep_f_0, &rep_m_0, kernelContext_53);
    float4 _S692 = float4(_S691->center_0) ;
    float3 fc_2 = fl_0 + kernelContext_53->params_0->gravity_0.xyz * float3(_S692.w) ;
    float3 _S693 = _S692.xyz;
    float3 _S694 = (float4(isl_9->com_0) ).xyz;
    float3 _S695 = rotate_0(&rg_2->rot_1, _S693 + (float4(*(kernelContext_53->state_0+4U * c_11)) ).xyz - _S694);
    *f_6 = *f_6 + fc_2;
    *t_6 = *t_6 + (cross(_S695, fc_2) + tl_0);
    uint4 _S696 = uint4(_S691->load_range_0) ;
    if((_S696.y) > (_S696.x))
    {
        float3 _S697 = rotate_0(&rg_2->rot_1, rep_f_0);
        *f_6 = *f_6 + _S697;
        float3 _S698 = rotate_0(&rg_2->rot_1, _S693 - _S694);
        float3 _S699 = cross(_S698, _S697);
        float3 _S700 = rotate_0(&rg_2->rot_1, rep_m_0);
        *t_6 = *t_6 + (_S699 + _S700);
    }
    return;
}

void net_load_1(uint c_12, const Island_0 thread* isl_10, const Rigid_0 thread* rg_3, uint k_15, float dt_8, bool contact_3, float3 thread* f_7, float3 thread* t_7, KernelContext_0 thread* kernelContext_54)
{
    ChunkStatic_natural_0 device* _S701 = kernelContext_54->chunks_0+c_12;
    thread float3 fl_1;
    thread float3 tl_1;
    thread float3 rep_f_1;
    thread float3 rep_m_1;
    chunk_loads_0(c_12, c_12, &rg_3->rot_1, k_15, dt_8, contact_3, 0.0f, &fl_1, &tl_1, &rep_f_1, &rep_m_1, kernelContext_54);
    float4 _S702 = float4(_S701->center_0) ;
    float3 fc_3 = fl_1 + kernelContext_54->params_0->gravity_0.xyz * float3(_S702.w) ;
    float3 _S703 = _S702.xyz;
    float3 _S704 = isl_10->com_0.xyz;
    float3 _S705 = rotate_0(&rg_3->rot_1, _S703 + (float4(*(kernelContext_54->state_0+4U * c_12)) ).xyz - _S704);
    *f_7 = *f_7 + fc_3;
    *t_7 = *t_7 + (cross(_S705, fc_3) + tl_1);
    uint4 _S706 = uint4(_S701->load_range_0) ;
    if((_S706.y) > (_S706.x))
    {
        float3 _S707 = rotate_0(&rg_3->rot_1, rep_f_1);
        *f_7 = *f_7 + _S707;
        float3 _S708 = rotate_0(&rg_3->rot_1, _S703 - _S704);
        float3 _S709 = cross(_S708, _S707);
        float3 _S710 = rotate_0(&rg_3->rot_1, rep_m_1);
        *t_7 = *t_7 + (_S709 + _S710);
    }
    return;
}

void wide_store_0(uint slot_1, uint p_13, float3 a_11, float3 b_29, KernelContext_0 thread* kernelContext_55)
{
    uint _S711 = 8U * slot_1;
    *(kernelContext_55->scratch_0+(kernelContext_55->params_0->wide_base_0 + _S711 + p_13)) = packed_float4(float4(a_11, 0.0f)) ;
    *(kernelContext_55->scratch_0+(kernelContext_55->params_0->wide_base_0 + _S711 + p_13 + 1U)) = packed_float4(float4(b_29, 0.0f)) ;
    return;
}

[[kernel]] void wide_bonds(uint3 group_2 [[threadgroup_position_in_grid]], uint3 thread_2 [[thread_position_in_threadgroup]], Params_0 constant* params_5 [[buffer(0)]], Island_natural_0 device* islands_5 [[buffer(9)]], uint device* index_5 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_5 [[buffer(3)]], packed_float4 device* state_7 [[buffer(6)]], packed_float4 device* scratch_5 [[buffer(8)]], packed_float4 device* contact_state_5 [[buffer(11)]], packed_float4 device* loads_5 [[buffer(5)]], Impactor_natural_0 device* impactors_5 [[buffer(10)]], BondStatic_natural_0 device* bonds_5 [[buffer(2)]], MaterialTable_0 constant* materials_5 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_5 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_56;
    (&kernelContext_56)->params_0 = params_5;
    (&kernelContext_56)->islands_0 = islands_5;
    (&kernelContext_56)->index_0 = index_5;
    (&kernelContext_56)->chunks_0 = chunks_5;
    (&kernelContext_56)->state_0 = state_7;
    (&kernelContext_56)->scratch_0 = scratch_5;
    (&kernelContext_56)->contact_state_0 = contact_state_5;
    (&kernelContext_56)->loads_0 = loads_5;
    (&kernelContext_56)->impactors_0 = impactors_5;
    (&kernelContext_56)->bonds_0 = bonds_5;
    (&kernelContext_56)->materials_0 = materials_5;
    (&kernelContext_56)->bond_dyn_0 = bond_dyn_5;
    threadgroup array<float4, int(32)> g_part_a_5;
    (&kernelContext_56)->g_part_a_0 = &g_part_a_5;
    threadgroup array<float4, int(32)> g_part_b_5;
    (&kernelContext_56)->g_part_b_0 = &g_part_b_5;
    threadgroup array<uint, int(5)> g_seen_5;
    (&kernelContext_56)->g_seen_0 = &g_seen_5;
    threadgroup uint g_wide_run_5;
    (&kernelContext_56)->g_wide_run_0 = &g_wide_run_5;
    threadgroup uint g_halt_5;
    (&kernelContext_56)->g_halt_0 = &g_halt_5;
    threadgroup uint g_run_5;
    (&kernelContext_56)->g_run_0 = &g_run_5;
    uint tid_6 = thread_2.x;
    uint _S712 = group_2.x;
    bool bond_group_0 = _S712 < (params_5->wide_bond_groups_0);
    WideGroup_0 wg_0;
    if(bond_group_0)
    {
        WideGroup_0 _S713 = wide_group_0((&kernelContext_56)->params_0->wide_bond_table_0, _S712, &kernelContext_56);
        wg_0 = _S713;
    }
    else
    {
        WideGroup_0 _S714 = wide_group_0((&kernelContext_56)->params_0->wide_chunk_table_0, _S712 - params_5->wide_bond_groups_0, &kernelContext_56);
        wg_0 = _S714;
    }
    WideGroup_0 _S715 = wg_0;
    thread Island_natural_0 _S716 = *((&kernelContext_56)->islands_0+wg_0.island_3);
    bool _S717 = wide_enter_1(tid_6, wg_0.island_3, &kernelContext_56);
    if(!_S717)
    {
        return;
    }
    uint _S718 = wide_step_0(&_S716, &kernelContext_56);
    if(bond_group_0)
    {
        uint4 _S719 = uint4((&_S716)->info_0) ;
        if(((_S719.x) & 16U) != 0U)
        {
            return;
        }
        uint i_10 = wg_0.begin_0 + tid_6;
        bool _S720;
        if(i_10 < (wg_0.end_0))
        {
            bool _S721 = bond_update_0(i_10, (&kernelContext_56)->params_0->dt_0, ((&kernelContext_56)->params_0->fracture_0) != 0U, _S719.w + 1U, true, &kernelContext_56);
            _S720 = _S721;
        }
        else
        {
            _S720 = false;
        }
        if(_S720)
        {
            ((&kernelContext_56)->islands_0+_S715.island_3)->info_0[int(2)] = (_S719.z) | 2U;
        }
        return;
    }
    uint _S722 = (uint4((&_S716)->info_0) ).x;
    if((_S722 & 1U) != 0U)
    {
        return;
    }
    float3 _S723 = float3(0.0f) ;
    thread float3 f_8 = _S723;
    thread float3 t_8 = _S723;
    uint c_13 = wg_0.begin_0 + tid_6;
    if(c_13 < (wg_0.end_0))
    {
        Rigid_0 _S724 = rigid_of_0(&_S716);
        float _S725 = (&kernelContext_56)->params_0->dt_0;
        bool _S726 = (_S722 & 4U) != 0U;
        thread Rigid_0 _S727 = _S724;
        net_load_0(c_13, &_S716, &_S727, _S718, _S725, _S726, &f_8, &t_8, &kernelContext_56);
    }
    group_sum3_0(tid_6, &f_8, &t_8, &kernelContext_56);
    if(tid_6 == 0U)
    {
        wide_store_0(_S712 - params_5->wide_bond_groups_0, 0U, f_8, t_8, &kernelContext_56);
    }
    return;
}

void wide_partials_0(uint tid_7, uint first_1, uint count_6, uint p_14, float3 thread* a_12, float3 thread* b_30, KernelContext_0 thread* kernelContext_57)
{
    float4 _S728 = float4(0.0f) ;
    thread float4 x_11 = _S728;
    thread float4 y_2 = _S728;
    uint s_3 = tid_7;
    for(;;)
    {
        if(s_3 < count_6)
        {
        }
        else
        {
            break;
        }
        uint _S729 = 8U * (first_1 + s_3);
        x_11 = x_11 + float4(*(kernelContext_57->scratch_0+(kernelContext_57->params_0->wide_base_0 + _S729 + p_14))) ;
        y_2 = y_2 + float4(*(kernelContext_57->scratch_0+(kernelContext_57->params_0->wide_base_0 + _S729 + p_14 + 1U))) ;
        s_3 = s_3 + 256U;
    }
    group_sum2_0(tid_7, &x_11, &y_2, kernelContext_57);
    *a_12 = x_11.xyz;
    *b_30 = y_2.xyz;
    return;
}

float3 rows_mul_0(float4 r0_0, float4 r1_0, float4 r2_0, float3 v_5)
{
    return float3(dot(r0_0.xyz, v_5), dot(r1_0.xyz, v_5), dot(r2_0.xyz, v_5));
}

void drift_angular_0(uint c_14, float3 wcom_1, float3 tr_0, float3 dv_0, float3 thread* lu_0, float3 thread* lv_0, KernelContext_0 thread* kernelContext_58)
{
    ChunkStatic_natural_0 device* _S730 = kernelContext_58->chunks_0+c_14;
    float4 _S731 = float4(_S730->center_0) ;
    float3 r_10 = _S731.xyz - wcom_1;
    uint _S732 = 4U * c_14;
    float3 _S733 = float3(_S731.w) ;
    float4 _S734 = float4(_S730->inertia0_1) ;
    float4 _S735 = float4(_S730->inertia1_1) ;
    float4 _S736 = float4(_S730->inertia2_1) ;
    float3 _S737 = float3((float4(_S730->scale_0) ).x) ;
    *lu_0 = *lu_0 + (cross(r_10, (float4(*(kernelContext_58->state_0+_S732)) ).xyz - tr_0) * _S733 + rows_mul_0(_S734, _S735, _S736, (float4(*(kernelContext_58->state_0+(_S732 + 1U))) ).xyz)) * _S737;
    *lv_0 = *lv_0 + (cross(r_10, (float4(*(kernelContext_58->state_0+(_S732 + 2U))) ).xyz - dv_0) * _S733 + rows_mul_0(_S734, _S735, _S736, (float4(*(kernelContext_58->state_0+(_S732 + 3U))) ).xyz)) * _S737;
    return;
}

[[kernel]] void wide_drift(uint3 group_3 [[threadgroup_position_in_grid]], uint3 thread_3 [[thread_position_in_threadgroup]], Params_0 constant* params_6 [[buffer(0)]], Island_natural_0 device* islands_6 [[buffer(9)]], uint device* index_6 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_6 [[buffer(3)]], packed_float4 device* state_8 [[buffer(6)]], packed_float4 device* scratch_6 [[buffer(8)]], packed_float4 device* contact_state_6 [[buffer(11)]], packed_float4 device* loads_6 [[buffer(5)]], Impactor_natural_0 device* impactors_6 [[buffer(10)]], BondStatic_natural_0 device* bonds_6 [[buffer(2)]], MaterialTable_0 constant* materials_6 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_6 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_59;
    (&kernelContext_59)->params_0 = params_6;
    (&kernelContext_59)->islands_0 = islands_6;
    (&kernelContext_59)->index_0 = index_6;
    (&kernelContext_59)->chunks_0 = chunks_6;
    (&kernelContext_59)->state_0 = state_8;
    (&kernelContext_59)->scratch_0 = scratch_6;
    (&kernelContext_59)->contact_state_0 = contact_state_6;
    (&kernelContext_59)->loads_0 = loads_6;
    (&kernelContext_59)->impactors_0 = impactors_6;
    (&kernelContext_59)->bonds_0 = bonds_6;
    (&kernelContext_59)->materials_0 = materials_6;
    (&kernelContext_59)->bond_dyn_0 = bond_dyn_6;
    threadgroup array<float4, int(32)> g_part_a_6;
    (&kernelContext_59)->g_part_a_0 = &g_part_a_6;
    threadgroup array<float4, int(32)> g_part_b_6;
    (&kernelContext_59)->g_part_b_0 = &g_part_b_6;
    threadgroup array<uint, int(5)> g_seen_6;
    (&kernelContext_59)->g_seen_0 = &g_seen_6;
    threadgroup uint g_wide_run_6;
    (&kernelContext_59)->g_wide_run_0 = &g_wide_run_6;
    threadgroup uint g_halt_6;
    (&kernelContext_59)->g_halt_0 = &g_halt_6;
    threadgroup uint g_run_6;
    (&kernelContext_59)->g_run_0 = &g_run_6;
    uint tid_8 = thread_3.x;
    uint _S738 = group_3.x;
    WideGroup_0 _S739 = wide_group_0(params_6->wide_chunk_table_0, _S738, &kernelContext_59);
    Island_natural_0 device* _S740 = (&kernelContext_59)->islands_0+_S739.island_3;
    Island_natural_0 isl_11 = *_S740;
    bool _S741;
    if((((uint4((*_S740).info_0) ).x) & 17U) != 0U)
    {
        _S741 = true;
    }
    else
    {
        bool _S742 = wide_enter_1(tid_8, _S739.island_3, &kernelContext_59);
        _S741 = !_S742;
    }
    if(_S741)
    {
        return;
    }
    thread float3 tu_0;
    thread float3 pv_0;
    wide_partials_0(tid_8, _S739.first_0, isl_11.wide_groups_0, 2U, &tu_0, &pv_0, &kernelContext_59);
    float4 _S743 = float4(isl_11.wcom_0) ;
    float3 _S744 = float3(_S743.w) ;
    float3 tr_1 = tu_0 / _S744;
    float3 dv_1 = pv_0 / _S744;
    float3 _S745 = float3(0.0f) ;
    thread float3 lu_1 = _S745;
    thread float3 lv_1 = _S745;
    uint c_15 = _S739.begin_0 + tid_8;
    if(c_15 < (_S739.end_0))
    {
        drift_angular_0(c_15, _S743.xyz, tr_1, dv_1, &lu_1, &lv_1, &kernelContext_59);
    }
    group_sum3_0(tid_8, &lu_1, &lv_1, &kernelContext_59);
    if(tid_8 == 0U)
    {
        wide_store_0(_S738, 4U, lu_1, lv_1, &kernelContext_59);
    }
    return;
}

float3 inverse_rotate_0(const Quat_0 thread* q_10, float3 v_6)
{
    thread Quat_0 c_16;
    (&c_16)->w_1 = q_10->w_1;
    (&c_16)->x_2 = - q_10->x_2;
    (&c_16)->y_1 = - q_10->y_1;
    (&c_16)->z_0 = - q_10->z_0;
    thread Quat_0 _S746 = c_16;
    float3 _S747 = rotate_0(&_S746, v_6);
    return _S747;
}

float3 inverse_rotate_1(const Quat_0 thread* q_11, float3 v_7)
{
    thread Quat_0 c_17;
    (&c_17)->w_1 = q_11->w_1;
    (&c_17)->x_2 = - q_11->x_2;
    (&c_17)->y_1 = - q_11->y_1;
    (&c_17)->z_0 = - q_11->z_0;
    thread Quat_0 _S748 = c_17;
    float3 _S749 = rotate_0(&_S748, v_7);
    return _S749;
}

float3 world_mul_0(const Quat_0 thread* q_12, float4 r0_1, float4 r1_1, float4 r2_1, float3 v_8)
{
    float3 _S750 = inverse_rotate_1(q_12, v_8);
    float3 _S751 = rotate_1(q_12, rows_mul_0(r0_1, r1_1, r2_1, _S750));
    return _S751;
}

void rigid_acceleration_0(const Island_natural_0 thread* isl_12, Rigid_0 thread* rg_4, float3 f_9, float3 t_9)
{
    float4 _S752 = float4(isl_12->inertia0_0) ;
    float4 _S753 = float4(isl_12->inertia1_0) ;
    float4 _S754 = float4(isl_12->inertia2_0) ;
    thread Quat_0 _S755 = rg_4->rot_1;
    float3 _S756 = world_mul_0(&_S755, _S752, _S753, _S754, rg_4->w_5);
    rg_4->a_10 = f_9 / float3((float4(isl_12->com_0) ).w) ;
    float4 _S757 = float4(isl_12->inv0_0) ;
    float4 _S758 = float4(isl_12->inv1_0) ;
    float4 _S759 = float4(isl_12->inv2_0) ;
    float3 _S760 = t_9 - cross(rg_4->w_5, _S756);
    thread Quat_0 _S761 = rg_4->rot_1;
    float3 _S762 = world_mul_0(&_S761, _S757, _S758, _S759, _S760);
    rg_4->alpha_0 = _S762;
    rg_4->torque_0 = t_9;
    return;
}

void rigid_acceleration_1(const Island_0 thread* isl_13, Rigid_0 thread* rg_5, float3 f_10, float3 t_10)
{
    thread Quat_0 _S763 = rg_5->rot_1;
    float3 _S764 = world_mul_0(&_S763, isl_13->inertia0_0, isl_13->inertia1_0, isl_13->inertia2_0, rg_5->w_5);
    rg_5->a_10 = f_10 / float3(isl_13->com_0.w) ;
    float3 _S765 = t_10 - cross(rg_5->w_5, _S764);
    thread Quat_0 _S766 = rg_5->rot_1;
    float3 _S767 = world_mul_0(&_S766, isl_13->inv0_0, isl_13->inv1_0, isl_13->inv2_0, _S765);
    rg_5->alpha_0 = _S767;
    rg_5->torque_0 = t_10;
    return;
}

Rigid_0 wide_rigid_frame_0(uint tid_9, const Island_natural_0 thread* isl_14, const WideGroup_0 thread* wg_1, KernelContext_0 thread* kernelContext_60)
{
    Rigid_0 _S768 = rigid_of_0(isl_14);
    thread Rigid_0 rg_6 = _S768;
    if((((uint4(isl_14->info_0) ).x) & 1U) == 0U)
    {
        thread float3 f_11;
        thread float3 t_11;
        wide_partials_0(tid_9, wg_1->first_0, isl_14->wide_groups_0, 0U, &f_11, &t_11, kernelContext_60);
        rigid_acceleration_0(isl_14, &rg_6, f_11, t_11);
    }
    return rg_6;
}

Rigid_0 wide_rigid_frame_1(uint tid_10, const Island_natural_0 thread* isl_15, const WideGroup_0 thread* wg_2, KernelContext_0 thread* kernelContext_61)
{
    Rigid_0 _S769 = rigid_of_0(isl_15);
    thread Rigid_0 rg_7 = _S769;
    if((((uint4(isl_15->info_0) ).x) & 1U) == 0U)
    {
        thread float3 f_12;
        thread float3 t_12;
        wide_partials_0(tid_10, wg_2->first_0, isl_15->wide_groups_0, 0U, &f_12, &t_12, kernelContext_61);
        rigid_acceleration_0(isl_15, &rg_7, f_12, t_12);
    }
    return rg_7;
}

void comp_add_0(float3 thread* sum_1, float3 thread* err_1, float3 x_12)
{
    float3 t_13 = *sum_1 + x_12;
    float3 _S770 = abs(x_12);
    *err_1 = *err_1 + (select(x_12, *sum_1, (abs(*sum_1)) >= _S770) - t_13 + select(*sum_1, x_12, (abs(*sum_1)) >= _S770));
    *sum_1 = t_13;
    return;
}

float3 turn_difference_0(float3 omega_0, float dt_9, float3 v_9)
{
    float _S771 = length(omega_0);
    float angle_1 = _S771 * dt_9;
    if(angle_1 < 1.00000000317107685e-30f)
    {
        return float3(0.0f) ;
    }
    float3 a_13 = omega_0 / float3(_S771) ;
    float s_4 = sin(0.5f * angle_1);
    float3 av_0 = cross(a_13, v_9);
    return av_0 * float3(sin(angle_1))  + cross(a_13, av_0) * float3((2.0f * s_4 * s_4)) ;
}

float4 turn_minus_one_0(float3 axis_5, float angle_2)
{
    float s_5 = sin(0.25f * angle_2);
    return float4(axis_5 * float3(sin(0.5f * angle_2)) , -2.0f * s_5 * s_5);
}

float4 quat_vec_0(const Quat_0 thread* q_13)
{
    return float4(q_13->x_2, q_13->y_1, q_13->z_0, q_13->w_1);
}

void comp_add4_0(float4 thread* sum_2, float4 thread* err_2, float4 x_13)
{
    float4 t_14 = *sum_2 + x_13;
    float4 _S772 = abs(x_13);
    *err_2 = *err_2 + (select(x_13, *sum_2, (abs(*sum_2)) >= _S772) - t_14 + select(*sum_2, x_13, (abs(*sum_2)) >= _S772));
    *sum_2 = t_14;
    return;
}

void quat_accumulate_0(Quat_0 thread* hi_1, float4 thread* lo_1, float4 x_14)
{
    thread Quat_0 _S773 = *hi_1;
    float4 _S774 = quat_vec_0(&_S773);
    thread float4 sum_3 = _S774;
    comp_add4_0(&sum_3, lo_1, x_14);
    float4 t_15 = sum_3 + *lo_1;
    *lo_1 = *lo_1 - (t_15 - sum_3);
    *hi_1 = quat_of_0(t_15);
    return;
}

void turn_left_0(Quat_0 thread* hi_2, float4 thread* lo_2, float3 omega_1, float dt_10)
{
    float _S775 = length(omega_1);
    float angle_3 = _S775 * dt_10;
    if(angle_3 < 1.00000000317107685e-30f)
    {
        return;
    }
    float4 d_12 = turn_minus_one_0(omega_1 / float3(_S775) , angle_3);
    thread Quat_0 dq_0;
    (&dq_0)->x_2 = d_12.x;
    (&dq_0)->y_1 = d_12.y;
    (&dq_0)->z_0 = d_12.z;
    (&dq_0)->w_1 = d_12.w;
    thread Quat_0 _S776 = dq_0;
    thread Quat_0 _S777 = *hi_2;
    Quat_0 _S778 = quat_mul_0(&_S776, &_S777);
    thread Quat_0 _S779 = _S778;
    float4 _S780 = quat_vec_0(&_S779);
    quat_accumulate_0(hi_2, lo_2, _S780);
    return;
}

void integrate_rigid_0(const Island_natural_0 thread* isl_16, Rigid_0 thread* rg_8, float dt_11)
{
    float3 _S781 = float3(dt_11) ;
    comp_add_0(&rg_8->l_1, &rg_8->l_err_0, rg_8->torque_0 * _S781);
    float3 l_2 = rg_8->l_1 + rg_8->l_err_0;
    comp_add_0(&rg_8->vel_0, &rg_8->vel_err_0, rg_8->a_10 * _S781);
    float3 vel_1 = rg_8->vel_0 + rg_8->vel_err_0;
    float4 _S782 = float4(isl_16->inv0_0) ;
    float4 _S783 = float4(isl_16->inv1_0) ;
    float4 _S784 = float4(isl_16->inv2_0) ;
    thread Quat_0 _S785 = rg_8->rot_1;
    float3 _S786 = world_mul_0(&_S785, _S782, _S783, _S784, l_2);
    float3 _S787 = vel_1 * _S781;
    float3 _S788 = (float4(isl_16->com_0) ).xyz;
    thread Quat_0 _S789 = rg_8->rot_1;
    float3 _S790 = rotate_0(&_S789, _S788);
    comp_add_0(&rg_8->pos_0, &rg_8->pos_err_0, _S787 - turn_difference_0(_S786, dt_11, _S790));
    turn_left_0(&rg_8->rot_1, &rg_8->rot_err_0, _S786, dt_11);
    thread Quat_0 _S791 = rg_8->rot_1;
    float3 _S792 = world_mul_0(&_S791, _S782, _S783, _S784, l_2);
    rg_8->w_5 = _S792;
    return;
}

void integrate_rigid_1(const Island_0 thread* isl_17, Rigid_0 thread* rg_9, float dt_12)
{
    float3 _S793 = float3(dt_12) ;
    comp_add_0(&rg_9->l_1, &rg_9->l_err_0, rg_9->torque_0 * _S793);
    float3 l_3 = rg_9->l_1 + rg_9->l_err_0;
    comp_add_0(&rg_9->vel_0, &rg_9->vel_err_0, rg_9->a_10 * _S793);
    float3 vel_2 = rg_9->vel_0 + rg_9->vel_err_0;
    float4 _S794 = isl_17->inv0_0;
    float4 _S795 = isl_17->inv1_0;
    float4 _S796 = isl_17->inv2_0;
    thread Quat_0 _S797 = rg_9->rot_1;
    float3 _S798 = world_mul_0(&_S797, isl_17->inv0_0, isl_17->inv1_0, isl_17->inv2_0, l_3);
    float3 _S799 = vel_2 * _S793;
    float3 _S800 = isl_17->com_0.xyz;
    thread Quat_0 _S801 = rg_9->rot_1;
    float3 _S802 = rotate_0(&_S801, _S800);
    comp_add_0(&rg_9->pos_0, &rg_9->pos_err_0, _S799 - turn_difference_0(_S798, dt_12, _S802));
    turn_left_0(&rg_9->rot_1, &rg_9->rot_err_0, _S798, dt_12);
    thread Quat_0 _S803 = rg_9->rot_1;
    float3 _S804 = world_mul_0(&_S803, _S794, _S795, _S796, l_3);
    rg_9->w_5 = _S804;
    return;
}

void drift_apply_0(uint c_18, float3 wcom_2, float3 tr_2, float3 phi_0, float3 dv_2, float3 dw_0, KernelContext_0 thread* kernelContext_62)
{
    float3 r_11 = (float4((kernelContext_62->chunks_0+c_18)->center_0) ).xyz - wcom_2;
    uint _S805 = 4U * c_18;
    *(kernelContext_62->state_0+_S805) = packed_float4(float4((float4(*(kernelContext_62->state_0+_S805)) ).xyz - (tr_2 + cross(phi_0, r_11)), (float4(*(kernelContext_62->state_0+_S805)) ).w)) ;
    uint _S806 = _S805 + 1U;
    *(kernelContext_62->state_0+_S806) = packed_float4(float4((float4(*(kernelContext_62->state_0+_S806)) ).xyz - phi_0, (float4(*(kernelContext_62->state_0+_S806)) ).w)) ;
    uint _S807 = _S805 + 2U;
    *(kernelContext_62->state_0+_S807) = packed_float4(float4((float4(*(kernelContext_62->state_0+_S807)) ).xyz - (dv_2 + cross(dw_0, r_11)), (float4(*(kernelContext_62->state_0+_S807)) ).w)) ;
    uint _S808 = _S805 + 3U;
    *(kernelContext_62->state_0+_S808) = packed_float4(float4((float4(*(kernelContext_62->state_0+_S808)) ).xyz - dw_0, (float4(*(kernelContext_62->state_0+_S808)) ).w)) ;
    return;
}

void turn_right_0(Quat_0 thread* hi_3, float4 thread* lo_3, float3 phi_1)
{
    float angle_4 = length(phi_1);
    if(angle_4 < 1.00000000317107685e-30f)
    {
        return;
    }
    float4 d_13 = turn_minus_one_0(phi_1 / float3(angle_4) , angle_4);
    thread Quat_0 dq_1;
    (&dq_1)->x_2 = d_13.x;
    (&dq_1)->y_1 = d_13.y;
    (&dq_1)->z_0 = d_13.z;
    (&dq_1)->w_1 = d_13.w;
    thread Quat_0 _S809 = *hi_3;
    thread Quat_0 _S810 = dq_1;
    Quat_0 _S811 = quat_mul_0(&_S809, &_S810);
    thread Quat_0 _S812 = _S811;
    float4 _S813 = quat_vec_0(&_S812);
    quat_accumulate_0(hi_3, lo_3, _S813);
    return;
}

void drift_rigid_0(const Island_natural_0 thread* isl_18, Rigid_0 thread* rg_10, float3 tr_3, float3 phi_2, float3 dv_3, float3 dw_1)
{
    float3 wcom_3 = (float4(isl_18->wcom_0) ).xyz;
    Quat_0 rot_2 = rg_10->rot_1;
    float3 _S814 = tr_3 - cross(phi_2, wcom_3);
    thread Quat_0 _S815 = rg_10->rot_1;
    float3 _S816 = rotate_0(&_S815, _S814);
    comp_add_0(&rg_10->pos_0, &rg_10->pos_err_0, _S816);
    thread Quat_0 _S817 = rg_10->rot_1;
    float3 _S818 = inverse_rotate_0(&_S817, rg_10->w_5);
    float4 _S819 = float4(isl_18->inertia0_0) ;
    float4 _S820 = float4(isl_18->inertia1_0) ;
    float4 _S821 = float4(isl_18->inertia2_0) ;
    float3 _S822 = cross(phi_2, rows_mul_0(_S819, _S820, _S821, _S818)) - rows_mul_0(_S819, _S820, _S821, cross(phi_2, _S818));
    thread Quat_0 _S823 = rg_10->rot_1;
    float3 _S824 = rotate_0(&_S823, _S822);
    turn_right_0(&rg_10->rot_1, &rg_10->rot_err_0, phi_2);
    float3 _S825 = dv_3 + cross(dw_1, (float4(isl_18->com_0) ).xyz - wcom_3);
    thread Quat_0 _S826 = rot_2;
    float3 _S827 = rotate_0(&_S826, _S825);
    comp_add_0(&rg_10->vel_0, &rg_10->vel_err_0, _S827);
    thread Quat_0 _S828 = rot_2;
    float3 _S829 = rotate_0(&_S828, dw_1);
    rg_10->w_5 = rg_10->w_5 + _S829;
    thread Quat_0 _S830 = rg_10->rot_1;
    float3 _S831 = world_mul_0(&_S830, _S819, _S820, _S821, _S829);
    comp_add_0(&rg_10->l_1, &rg_10->l_err_0, _S824 + _S831);
    return;
}

void drift_rigid_1(const Island_0 thread* isl_19, Rigid_0 thread* rg_11, float3 tr_4, float3 phi_3, float3 dv_4, float3 dw_2)
{
    float3 wcom_4 = isl_19->wcom_0.xyz;
    Quat_0 rot_3 = rg_11->rot_1;
    float3 _S832 = tr_4 - cross(phi_3, wcom_4);
    thread Quat_0 _S833 = rg_11->rot_1;
    float3 _S834 = rotate_0(&_S833, _S832);
    comp_add_0(&rg_11->pos_0, &rg_11->pos_err_0, _S834);
    thread Quat_0 _S835 = rg_11->rot_1;
    float3 _S836 = inverse_rotate_0(&_S835, rg_11->w_5);
    float4 _S837 = isl_19->inertia0_0;
    float4 _S838 = isl_19->inertia1_0;
    float4 _S839 = isl_19->inertia2_0;
    float3 _S840 = cross(phi_3, rows_mul_0(isl_19->inertia0_0, isl_19->inertia1_0, isl_19->inertia2_0, _S836)) - rows_mul_0(isl_19->inertia0_0, isl_19->inertia1_0, isl_19->inertia2_0, cross(phi_3, _S836));
    thread Quat_0 _S841 = rg_11->rot_1;
    float3 _S842 = rotate_0(&_S841, _S840);
    turn_right_0(&rg_11->rot_1, &rg_11->rot_err_0, phi_3);
    float3 _S843 = dv_4 + cross(dw_2, isl_19->com_0.xyz - wcom_4);
    thread Quat_0 _S844 = rot_3;
    float3 _S845 = rotate_0(&_S844, _S843);
    comp_add_0(&rg_11->vel_0, &rg_11->vel_err_0, _S845);
    thread Quat_0 _S846 = rot_3;
    float3 _S847 = rotate_0(&_S846, dw_2);
    rg_11->w_5 = rg_11->w_5 + _S847;
    thread Quat_0 _S848 = rg_11->rot_1;
    float3 _S849 = world_mul_0(&_S848, _S837, _S838, _S839, _S847);
    comp_add_0(&rg_11->l_1, &rg_11->l_err_0, _S842 + _S849);
    return;
}

[[kernel]] void wide_rigid(uint3 group_4 [[threadgroup_position_in_grid]], uint3 thread_4 [[thread_position_in_threadgroup]], Params_0 constant* params_7 [[buffer(0)]], Island_natural_0 device* islands_7 [[buffer(9)]], uint device* index_7 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_7 [[buffer(3)]], packed_float4 device* state_9 [[buffer(6)]], packed_float4 device* scratch_7 [[buffer(8)]], packed_float4 device* contact_state_7 [[buffer(11)]], packed_float4 device* loads_7 [[buffer(5)]], Impactor_natural_0 device* impactors_7 [[buffer(10)]], BondStatic_natural_0 device* bonds_7 [[buffer(2)]], MaterialTable_0 constant* materials_7 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_7 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_63;
    (&kernelContext_63)->params_0 = params_7;
    (&kernelContext_63)->islands_0 = islands_7;
    (&kernelContext_63)->index_0 = index_7;
    (&kernelContext_63)->chunks_0 = chunks_7;
    (&kernelContext_63)->state_0 = state_9;
    (&kernelContext_63)->scratch_0 = scratch_7;
    (&kernelContext_63)->contact_state_0 = contact_state_7;
    (&kernelContext_63)->loads_0 = loads_7;
    (&kernelContext_63)->impactors_0 = impactors_7;
    (&kernelContext_63)->bonds_0 = bonds_7;
    (&kernelContext_63)->materials_0 = materials_7;
    (&kernelContext_63)->bond_dyn_0 = bond_dyn_7;
    threadgroup array<float4, int(32)> g_part_a_7;
    (&kernelContext_63)->g_part_a_0 = &g_part_a_7;
    threadgroup array<float4, int(32)> g_part_b_7;
    (&kernelContext_63)->g_part_b_0 = &g_part_b_7;
    threadgroup array<uint, int(5)> g_seen_7;
    (&kernelContext_63)->g_seen_0 = &g_seen_7;
    threadgroup uint g_wide_run_7;
    (&kernelContext_63)->g_wide_run_0 = &g_wide_run_7;
    threadgroup uint g_halt_7;
    (&kernelContext_63)->g_halt_0 = &g_halt_7;
    threadgroup uint g_run_7;
    (&kernelContext_63)->g_run_0 = &g_run_7;
    uint tid_11 = thread_4.x;
    uint _S850 = group_4.x;
    WideGroup_0 _S851 = wide_group_0(params_7->wide_chunk_table_0, _S850, &kernelContext_63);
    thread Island_natural_0 _S852 = *((&kernelContext_63)->islands_0+_S851.island_3);
    uint _S853 = (uint4((&_S852)->info_0) ).x;
    bool _S854;
    if((_S853 & 1U) != 0U)
    {
        _S854 = true;
    }
    else
    {
        bool _S855 = wide_enter_1(tid_11, _S851.island_3, &kernelContext_63);
        _S854 = !_S855;
    }
    if(_S854)
    {
        return;
    }
    if((_S853 & 16U) != 0U)
    {
        if(_S850 != (_S851.first_0))
        {
            return;
        }
        thread WideGroup_0 _S856 = _S851;
        Rigid_0 _S857 = wide_rigid_frame_0(tid_11, &_S852, &_S856, &kernelContext_63);
        thread Rigid_0 rs_0 = _S857;
        if(tid_11 != 0U)
        {
            _S854 = true;
        }
        else
        {
            _S854 = (_S853 & 2U) != 0U;
        }
        if(_S854)
        {
            return;
        }
        integrate_rigid_0(&_S852, &rs_0, (&kernelContext_63)->params_0->dt_0);
        thread Quat_0 _S858 = (&rs_0)->rot_1;
        float4 _S859 = quat_vec_0(&_S858);
        ((&kernelContext_63)->islands_0+_S851.island_3)->rotation_0 = packed_float4(_S859) ;
        ((&kernelContext_63)->islands_0+_S851.island_3)->rotation_err_0 = packed_float4((&rs_0)->rot_err_0) ;
        ((&kernelContext_63)->islands_0+_S851.island_3)->position_0 = packed_float4(float4((&rs_0)->pos_0, 0.0f)) ;
        ((&kernelContext_63)->islands_0+_S851.island_3)->position_err_0 = packed_float4(float4((&rs_0)->pos_err_0, 0.0f)) ;
        ((&kernelContext_63)->islands_0+_S851.island_3)->velocity_0 = packed_float4(float4((&rs_0)->vel_0, 0.0f)) ;
        ((&kernelContext_63)->islands_0+_S851.island_3)->velocity_err_0 = packed_float4(float4((&rs_0)->vel_err_0, 0.0f)) ;
        ((&kernelContext_63)->islands_0+_S851.island_3)->angular_velocity_0 = packed_float4(float4((&rs_0)->w_5, 0.0f)) ;
        ((&kernelContext_63)->islands_0+_S851.island_3)->momentum_0 = packed_float4(float4((&rs_0)->l_1, 0.0f)) ;
        ((&kernelContext_63)->islands_0+_S851.island_3)->momentum_err_0 = packed_float4(float4((&rs_0)->l_err_0, 0.0f)) ;
        return;
    }
    thread float3 tu_1;
    thread float3 pv_1;
    wide_partials_0(tid_11, _S851.first_0, (&_S852)->wide_groups_0, 2U, &tu_1, &pv_1, &kernelContext_63);
    thread float3 lu_2;
    thread float3 lv_2;
    wide_partials_0(tid_11, _S851.first_0, (&_S852)->wide_groups_0, 4U, &lu_2, &lv_2, &kernelContext_63);
    float4 _S860 = float4((&_S852)->wcom_0) ;
    float3 _S861 = float3(_S860.w) ;
    float3 tr_5 = tu_1 / _S861;
    float3 dv_5 = pv_1 / _S861;
    float4 _S862 = float4((&_S852)->winv0_0) ;
    float4 _S863 = float4((&_S852)->winv1_0) ;
    float4 _S864 = float4((&_S852)->winv2_0) ;
    float3 phi_4 = rows_mul_0(_S862, _S863, _S864, lu_2);
    float3 dw_3 = rows_mul_0(_S862, _S863, _S864, lv_2);
    uint c_19 = _S851.begin_0 + tid_11;
    if(c_19 < (_S851.end_0))
    {
        drift_apply_0(c_19, _S860.xyz, tr_5, phi_4, dv_5, dw_3, &kernelContext_63);
    }
    if(_S850 != (_S851.first_0))
    {
        return;
    }
    thread WideGroup_0 _S865 = _S851;
    Rigid_0 _S866 = wide_rigid_frame_0(tid_11, &_S852, &_S865, &kernelContext_63);
    thread Rigid_0 rg_12 = _S866;
    if(tid_11 != 0U)
    {
        return;
    }
    if(!((_S853 & 2U) != 0U))
    {
        integrate_rigid_0(&_S852, &rg_12, (&kernelContext_63)->params_0->dt_0);
        drift_rigid_0(&_S852, &rg_12, tr_5, phi_4, dv_5, dw_3);
    }
    thread Quat_0 _S867 = (&rg_12)->rot_1;
    float4 _S868 = quat_vec_0(&_S867);
    ((&kernelContext_63)->islands_0+_S851.island_3)->rotation_0 = packed_float4(_S868) ;
    ((&kernelContext_63)->islands_0+_S851.island_3)->rotation_err_0 = packed_float4((&rg_12)->rot_err_0) ;
    ((&kernelContext_63)->islands_0+_S851.island_3)->position_0 = packed_float4(float4((&rg_12)->pos_0, 0.0f)) ;
    ((&kernelContext_63)->islands_0+_S851.island_3)->position_err_0 = packed_float4(float4((&rg_12)->pos_err_0, 0.0f)) ;
    ((&kernelContext_63)->islands_0+_S851.island_3)->velocity_0 = packed_float4(float4((&rg_12)->vel_0, 0.0f)) ;
    ((&kernelContext_63)->islands_0+_S851.island_3)->velocity_err_0 = packed_float4(float4((&rg_12)->vel_err_0, 0.0f)) ;
    ((&kernelContext_63)->islands_0+_S851.island_3)->angular_velocity_0 = packed_float4(float4((&rg_12)->w_5, 0.0f)) ;
    ((&kernelContext_63)->islands_0+_S851.island_3)->momentum_0 = packed_float4(float4((&rg_12)->l_1, 0.0f)) ;
    ((&kernelContext_63)->islands_0+_S851.island_3)->momentum_err_0 = packed_float4(float4((&rg_12)->l_err_0, 0.0f)) ;
    return;
}

void write_probe_0(uint slot_2, uint k_16, float value_0, KernelContext_0 thread* kernelContext_64)
{
    uint at_3 = kernelContext_64->params_0->probe_base_0 * 4U + slot_2 * kernelContext_64->params_0->probe_stride_0 + k_16;
    thread float4 v_10 = float4(*(kernelContext_64->scratch_0+at_3 / 4U)) ;
    v_10[at_3 % 4U] = value_0;
    *(kernelContext_64->scratch_0+at_3 / 4U) = packed_float4(v_10) ;
    return;
}

void record_probes_0(const Island_0 thread* isl_20, const Rigid_0 thread* rg_13, uint k_17, KernelContext_0 thread* kernelContext_65)
{
    uint4 _S869 = isl_20->probes_0;
    uint at_4 = isl_20->probes_0.x;
    for(;;)
    {
        if(at_4 < (_S869.y))
        {
        }
        else
        {
            break;
        }
        uint4 info_3 = (as_type<uint4>((float4(*(kernelContext_65->loads_0+at_4)) )));
        float4 _S870 = float4(*(kernelContext_65->loads_0+(at_4 + 1U))) ;
        float4 _S871 = float4(*(kernelContext_65->loads_0+(at_4 + 2U))) ;
        float4 _S872 = float4(*(kernelContext_65->loads_0+(at_4 + 3U))) ;
        uint kind_4 = info_3.x;
        uint i_11 = info_3.y;
        float value_1;
        if(kind_4 == 0U)
        {
            float3 small_0 = (float4(*(kernelContext_65->state_0+4U * i_11)) ).xyz + float3(_S870.w, _S871.w, _S872.w);
            float3 _S873 = rg_13->pos_0 - _S871.xyz;
            float3 _S874 = rotate_0(&rg_13->rot_1, (float4((kernelContext_65->chunks_0+i_11)->center_0) ).xyz);
            float3 _S875 = _S873 + _S874;
            float3 _S876 = rg_13->pos_err_0 - _S872.xyz;
            float3 _S877 = rotate_0(&rg_13->rot_1, small_0);
            value_1 = dot(_S875 + (_S876 + _S877), _S870.xyz);
        }
        else
        {
            if(kind_4 == 1U)
            {
                uint _S878 = 4U * i_11;
                float3 _S879 = rotate_0(&rg_13->rot_1, (float4((kernelContext_65->chunks_0+i_11)->center_0) ).xyz + (float4(*(kernelContext_65->state_0+_S878)) ).xyz - isl_20->com_0.xyz);
                float3 _S880 = rg_13->vel_0 + rg_13->vel_err_0 + cross(rg_13->w_5, _S879);
                float3 _S881 = rotate_0(&rg_13->rot_1, (float4(*(kernelContext_65->state_0+(_S878 + 2U))) ).xyz);
                value_1 = dot(_S880 + _S881, _S870.xyz);
            }
            else
            {
                if(kind_4 == 2U)
                {
                    uint _S882 = 3U * i_11;
                    float3 f_13 = (float4(*(kernelContext_65->scratch_0+_S882)) ).xyz;
                    bool _S883 = (info_3.z) == 0U;
                    float3 mc_0;
                    if(_S883)
                    {
                        mc_0 = (float4(*(kernelContext_65->scratch_0+(_S882 + 1U))) ).xyz;
                    }
                    else
                    {
                        mc_0 = (float4(*(kernelContext_65->scratch_0+(_S882 + 2U))) ).xyz;
                    }
                    float3 fc_4;
                    if(_S883)
                    {
                        fc_4 = f_13;
                    }
                    else
                    {
                        fc_4 = - f_13;
                    }
                    value_1 = dot(fc_4, _S870.xyz) + dot(mc_0, _S871.xyz);
                }
                else
                {
                    uint _S884 = 4U * i_11;
                    float3 _S885 = rotate_0(&rg_13->rot_1, float3((float4(*(kernelContext_65->state_0+(_S884 + 1U))) ).w, (float4(*(kernelContext_65->state_0+(_S884 + 2U))) ).w, (float4(*(kernelContext_65->state_0+(_S884 + 3U))) ).w));
                    value_1 = dot(_S885, _S870.xyz);
                }
            }
        }
        write_probe_0(info_3.w, k_17, value_1, kernelContext_65);
        at_4 = at_4 + 4U;
    }
    return;
}

void contact_split_at_0(uint at_5, KernelContext_0 thread* kernelContext_66)
{
    uint previous_1 = (uint4((kernelContext_66->islands_0+kernelContext_66->params_0->halt_index_0)->info_0) ).y;
    uint _S886;
    if(previous_1 == 0U)
    {
        _S886 = at_5;
    }
    else
    {
        _S886 = min(previous_1, at_5);
    }
    (kernelContext_66->islands_0+kernelContext_66->params_0->halt_index_0)->info_0[int(1)] = _S886;
    return;
}

[[kernel]] void wide_end(uint3 group_5 [[threadgroup_position_in_grid]], uint3 thread_5 [[thread_position_in_threadgroup]], Params_0 constant* params_8 [[buffer(0)]], Island_natural_0 device* islands_8 [[buffer(9)]], uint device* index_8 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_8 [[buffer(3)]], packed_float4 device* state_10 [[buffer(6)]], packed_float4 device* scratch_8 [[buffer(8)]], packed_float4 device* contact_state_8 [[buffer(11)]], packed_float4 device* loads_8 [[buffer(5)]], Impactor_natural_0 device* impactors_8 [[buffer(10)]], BondStatic_natural_0 device* bonds_8 [[buffer(2)]], MaterialTable_0 constant* materials_8 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_8 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_67;
    (&kernelContext_67)->params_0 = params_8;
    (&kernelContext_67)->islands_0 = islands_8;
    (&kernelContext_67)->index_0 = index_8;
    (&kernelContext_67)->chunks_0 = chunks_8;
    (&kernelContext_67)->state_0 = state_10;
    (&kernelContext_67)->scratch_0 = scratch_8;
    (&kernelContext_67)->contact_state_0 = contact_state_8;
    (&kernelContext_67)->loads_0 = loads_8;
    (&kernelContext_67)->impactors_0 = impactors_8;
    (&kernelContext_67)->bonds_0 = bonds_8;
    (&kernelContext_67)->materials_0 = materials_8;
    (&kernelContext_67)->bond_dyn_0 = bond_dyn_8;
    threadgroup array<float4, int(32)> g_part_a_8;
    (&kernelContext_67)->g_part_a_0 = &g_part_a_8;
    threadgroup array<float4, int(32)> g_part_b_8;
    (&kernelContext_67)->g_part_b_0 = &g_part_b_8;
    threadgroup array<uint, int(5)> g_seen_8;
    (&kernelContext_67)->g_seen_0 = &g_seen_8;
    threadgroup uint g_wide_run_8;
    (&kernelContext_67)->g_wide_run_0 = &g_wide_run_8;
    threadgroup uint g_halt_8;
    (&kernelContext_67)->g_halt_0 = &g_halt_8;
    threadgroup uint g_run_8;
    (&kernelContext_67)->g_run_0 = &g_run_8;
    uint tid_12 = thread_5.x;
    uint _S887 = group_5.x;
    WideGroup_0 _S888 = wide_group_0(params_8->wide_chunk_table_0, _S887, &kernelContext_67);
    if(_S887 != (_S888.first_0))
    {
        return;
    }
    Island_natural_0 device* _S889 = (&kernelContext_67)->islands_0+_S888.island_3;
    thread Island_natural_0 _S890 = *_S889;
    uint4 _S891 = uint4((&_S890)->info_0) ;
    float4 _S892 = float4((&_S890)->com_0) ;
    float4 _S893 = float4((&_S890)->inertia0_0) ;
    float4 _S894 = float4((&_S890)->inertia1_0) ;
    float4 _S895 = float4((&_S890)->inertia2_0) ;
    float4 _S896 = float4((&_S890)->inv0_0) ;
    float4 _S897 = float4((&_S890)->inv1_0) ;
    float4 _S898 = float4((&_S890)->inv2_0) ;
    float4 _S899 = float4((&_S890)->wcom_0) ;
    float4 _S900 = float4((&_S890)->winv0_0) ;
    float4 _S901 = float4((&_S890)->winv1_0) ;
    float4 _S902 = float4((&_S890)->winv2_0) ;
    float4 _S903 = float4((&_S890)->rotation_0) ;
    float4 _S904 = float4((&_S890)->position_0) ;
    float4 _S905 = float4((&_S890)->position_err_0) ;
    float4 _S906 = float4((&_S890)->velocity_0) ;
    float4 _S907 = float4((&_S890)->velocity_err_0) ;
    float4 _S908 = float4((&_S890)->angular_velocity_0) ;
    uint4 _S909 = uint4((&_S890)->probes_0) ;
    float4 _S910 = float4((&_S890)->energy_0) ;
    float4 _S911 = float4((&_S890)->rotation_err_0) ;
    float4 _S912 = float4((&_S890)->momentum_0) ;
    float4 _S913 = float4((&_S890)->momentum_err_0) ;
    thread Island_0 isl_21;
    (&isl_21)->range_0 = uint4((&_S890)->range_0) ;
    (&isl_21)->info_0 = _S891;
    (&isl_21)->com_0 = _S892;
    (&isl_21)->inertia0_0 = _S893;
    (&isl_21)->inertia1_0 = _S894;
    (&isl_21)->inertia2_0 = _S895;
    (&isl_21)->inv0_0 = _S896;
    (&isl_21)->inv1_0 = _S897;
    (&isl_21)->inv2_0 = _S898;
    (&isl_21)->wcom_0 = _S899;
    (&isl_21)->winv0_0 = _S900;
    (&isl_21)->winv1_0 = _S901;
    (&isl_21)->winv2_0 = _S902;
    (&isl_21)->rotation_0 = _S903;
    (&isl_21)->position_0 = _S904;
    (&isl_21)->position_err_0 = _S905;
    (&isl_21)->velocity_0 = _S906;
    (&isl_21)->velocity_err_0 = _S907;
    (&isl_21)->angular_velocity_0 = _S908;
    (&isl_21)->done_0 = (&_S890)->done_0;
    (&isl_21)->coverage_0 = (&_S890)->coverage_0;
    (&isl_21)->wide_groups_0 = (&_S890)->wide_groups_0;
    (&isl_21)->done_pad_0 = (&_S890)->done_pad_0;
    (&isl_21)->probes_0 = _S909;
    (&isl_21)->energy_0 = _S910;
    (&isl_21)->rotation_err_0 = _S911;
    (&isl_21)->momentum_0 = _S912;
    (&isl_21)->momentum_err_0 = _S913;
    _S890 = *_S889;
    bool _S914 = wide_enter_0(tid_12, &_S890, &kernelContext_67);
    if(!_S914)
    {
        return;
    }
    thread float3 work_1;
    thread float3 flags_2;
    wide_partials_0(tid_12, _S888.first_0, (&isl_21)->wide_groups_0, 6U, &work_1, &flags_2, &kernelContext_67);
    if(tid_12 != 0U)
    {
        return;
    }
    thread Island_0 _S915 = isl_21;
    uint _S916 = wide_step_2(&_S915, &kernelContext_67);
    if(((&isl_21)->probes_0.y) > ((&isl_21)->probes_0.x))
    {
        thread Island_0 _S917 = isl_21;
        Rigid_0 _S918 = rigid_of_1(&_S917);
        thread Island_0 _S919 = isl_21;
        thread Rigid_0 _S920 = _S918;
        record_probes_0(&_S919, &_S920, _S916, &kernelContext_67);
    }
    bool halt_0 = (((&isl_21)->info_0.z) & 2U) != 0U;
    bool _S921;
    if(halt_0)
    {
        _S921 = (((&isl_21)->info_0.x) & 4U) != 0U;
    }
    else
    {
        _S921 = false;
    }
    if(_S921)
    {
        contact_split_at_0((&isl_21)->info_0.w + 1U, &kernelContext_67);
    }
    float _S922 = work_1.x;
    thread float _S923 = (&isl_21)->energy_0.x;
    thread float _S924 = (&isl_21)->energy_0.y;
    comp_add1_0(&_S923, &_S924, _S922);
    (&isl_21)->energy_0.x = _S923;
    (&isl_21)->energy_0.y = _S924 + work_1.y;
    (&isl_21)->done_0 = (&isl_21)->done_0 + 1U;
    (&isl_21)->info_0.y = (&isl_21)->info_0.y - 1U;
    (&isl_21)->info_0.w = (&isl_21)->info_0.w + 1U;
    if(halt_0)
    {
        (&isl_21)->info_0.z = (((&isl_21)->info_0.z) & 4294967293U) | 1U;
    }
    uint _S925;
    if(halt_0)
    {
        _S925 = 128U;
    }
    else
    {
        _S925 = 0U;
    }
    uint _S926 = 256U | _S925;
    if(((&isl_21)->probes_0.y) > ((&isl_21)->probes_0.x))
    {
        _S925 = 262144U;
    }
    else
    {
        _S925 = 0U;
    }
    uint _S927 = _S926 | _S925;
    if((((&isl_21)->info_0.x) & 4U) != 0U)
    {
        _S925 = 524288U;
    }
    else
    {
        _S925 = 0U;
    }
    uint _S928 = _S927 | _S925;
    if((flags_2.x) > 0.0f)
    {
        _S925 = 32768U;
    }
    else
    {
        _S925 = 0U;
    }
    uint _S929 = _S928 | _S925;
    if((flags_2.y) > 0.0f)
    {
        _S925 = 65536U;
    }
    else
    {
        _S925 = 0U;
    }
    uint _S930 = _S929 | _S925;
    if((flags_2.z) > 0.0f)
    {
        _S925 = 131072U;
    }
    else
    {
        _S925 = 0U;
    }
    (&isl_21)->coverage_0 = ((&isl_21)->coverage_0) | (_S930 | _S925);
    Island_natural_0 device* _S931 = (&kernelContext_67)->islands_0+_S888.island_3;
    _S931->range_0 = packed_uint4(isl_21.range_0) ;
    _S931->info_0 = packed_uint4(isl_21.info_0) ;
    _S931->com_0 = packed_float4(isl_21.com_0) ;
    _S931->inertia0_0 = packed_float4(isl_21.inertia0_0) ;
    _S931->inertia1_0 = packed_float4(isl_21.inertia1_0) ;
    _S931->inertia2_0 = packed_float4(isl_21.inertia2_0) ;
    _S931->inv0_0 = packed_float4(isl_21.inv0_0) ;
    _S931->inv1_0 = packed_float4(isl_21.inv1_0) ;
    _S931->inv2_0 = packed_float4(isl_21.inv2_0) ;
    _S931->wcom_0 = packed_float4(isl_21.wcom_0) ;
    _S931->winv0_0 = packed_float4(isl_21.winv0_0) ;
    _S931->winv1_0 = packed_float4(isl_21.winv1_0) ;
    _S931->winv2_0 = packed_float4(isl_21.winv2_0) ;
    _S931->rotation_0 = packed_float4(isl_21.rotation_0) ;
    _S931->position_0 = packed_float4(isl_21.position_0) ;
    _S931->position_err_0 = packed_float4(isl_21.position_err_0) ;
    _S931->velocity_0 = packed_float4(isl_21.velocity_0) ;
    _S931->velocity_err_0 = packed_float4(isl_21.velocity_err_0) ;
    _S931->angular_velocity_0 = packed_float4(isl_21.angular_velocity_0) ;
    _S931->done_0 = isl_21.done_0;
    _S931->coverage_0 = isl_21.coverage_0;
    _S931->wide_groups_0 = isl_21.wide_groups_0;
    _S931->done_pad_0 = isl_21.done_pad_0;
    _S931->probes_0 = packed_uint4(isl_21.probes_0) ;
    _S931->energy_0 = packed_float4(isl_21.energy_0) ;
    _S931->rotation_err_0 = packed_float4(isl_21.rotation_err_0) ;
    _S931->momentum_0 = packed_float4(isl_21.momentum_0) ;
    _S931->momentum_err_0 = packed_float4(isl_21.momentum_err_0) ;
    return;
}

uint sv_0(uint c_20, uint slot_3, KernelContext_0 thread* kernelContext_68)
{
    return kernelContext_68->params_0->statics_base_0 + 23U * c_20 + slot_3;
}

void project_load_slot_0(uint tid_13, const Island_natural_0 thread* isl_22, uint slot_4, KernelContext_0 thread* kernelContext_69)
{
    uint _S932;
    float3 _S933 = float3(0.0f) ;
    thread float3 net_f_0 = _S933;
    thread float3 net_m_0 = _S933;
    uint4 _S934 = uint4(isl_22->range_0) ;
    uint _S935 = _S934.x + tid_13;
    uint c_21 = _S935;
    for(;;)
    {
        uint _S936 = _S934.y;
        _S932 = _S936;
        if(c_21 < _S936)
        {
        }
        else
        {
            break;
        }
        uint _S937 = sv_0(c_21, slot_4, kernelContext_69);
        float3 fi_0 = (float4(*(kernelContext_69->scratch_0+_S937)) ).xyz;
        net_f_0 = net_f_0 + fi_0;
        float3 _S938 = cross((float4((kernelContext_69->chunks_0+c_21)->center_0) ).xyz - (float4(isl_22->com_0) ).xyz, fi_0);
        uint _S939 = sv_0(c_21, slot_4 + 1U, kernelContext_69);
        net_m_0 = net_m_0 + (_S938 + (float4(*(kernelContext_69->scratch_0+_S939)) ).xyz);
        c_21 = c_21 + 256U;
    }
    group_sum3_0(tid_13, &net_f_0, &net_m_0, kernelContext_69);
    float4 _S940 = float4(isl_22->com_0) ;
    float3 _S941 = net_f_0 / float3(_S940.w) ;
    float3 _S942 = rows_mul_0(float4(isl_22->inv0_0) , float4(isl_22->inv1_0) , float4(isl_22->inv2_0) , net_m_0);
    c_21 = _S935;
    for(;;)
    {
        if(c_21 < _S932)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_natural_0 device* _S943 = kernelContext_69->chunks_0+c_21;
        float4 _S944 = float4(_S943->center_0) ;
        float3 r_12 = _S944.xyz - _S940.xyz;
        uint _S945 = sv_0(c_21, slot_4, kernelContext_69);
        *(kernelContext_69->scratch_0+_S945) = packed_float4(float4((float4(*(kernelContext_69->scratch_0+_S945)) ).xyz - (_S941 + cross(_S942, r_12)) * float3(_S944.w) , 0.0f)) ;
        uint _S946 = sv_0(c_21, slot_4 + 1U, kernelContext_69);
        *(kernelContext_69->scratch_0+_S946) = packed_float4(float4((float4(*(kernelContext_69->scratch_0+_S946)) ).xyz - rows_mul_0(float4(_S943->inertia0_1) , float4(_S943->inertia1_1) , float4(_S943->inertia2_1) , _S942), 0.0f)) ;
        c_21 = c_21 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    return;
}

float island_dot_0(uint tid_14, uint c0_0, uint c1_0, uint sa_2, uint sb_2, KernelContext_0 thread* kernelContext_70)
{
    float4 _S947 = float4(0.0f) ;
    thread float4 acc_0 = _S947;
    thread float4 unused_2 = _S947;
    uint c_22 = c0_0 + tid_14;
    for(;;)
    {
        if(c_22 < c1_0)
        {
        }
        else
        {
            break;
        }
        uint _S948 = sv_0(c_22, sa_2, kernelContext_70);
        float3 _S949 = (float4(*(kernelContext_70->scratch_0+_S948)) ).xyz;
        uint _S950 = sv_0(c_22, sb_2, kernelContext_70);
        float _S951 = dot(_S949, (float4(*(kernelContext_70->scratch_0+_S950)) ).xyz);
        uint _S952 = sv_0(c_22, sa_2 + 1U, kernelContext_70);
        float3 _S953 = (float4(*(kernelContext_70->scratch_0+_S952)) ).xyz;
        uint _S954 = sv_0(c_22, sb_2 + 1U, kernelContext_70);
        acc_0.x = acc_0.x + (_S951 + dot(_S953, (float4(*(kernelContext_70->scratch_0+_S954)) ).xyz));
        c_22 = c_22 + 256U;
    }
    group_sum2_0(tid_14, &acc_0, &unused_2, kernelContext_70);
    return acc_0.x;
}

void static_kinematics_0(uint _S955, float3 thread* _S956, float3 thread* _S957, KernelContext_0 thread* kernelContext_71)
{
    BondStatic_natural_0 device* _S958 = kernelContext_71->bonds_0+_S955;
    uint4 _S959 = uint4(_S958->law_0.ids_0) ;
    uint ca_1 = _S959.y;
    uint cb_1 = _S959.z;
    uint _S960 = 4U * cb_1;
    uint _S961 = 4U * ca_1;
    float3 _S962 = (float4(*(kernelContext_71->state_0+_S960)) ).xyz - (float4(*(kernelContext_71->state_0+_S961)) ).xyz;
    uint _S963 = sv_0(cb_1, 21U, kernelContext_71);
    float3 _S964 = (float4(*(kernelContext_71->scratch_0+_S963)) ).xyz;
    uint _S965 = sv_0(ca_1, 21U, kernelContext_71);
    float3 du_0 = _S962 + (_S964 - (float4(*(kernelContext_71->scratch_0+_S965)) ).xyz);
    uint _S966 = _S960 + 1U;
    uint _S967 = _S961 + 1U;
    float3 _S968 = (float4(*(kernelContext_71->state_0+_S966)) ).xyz - (float4(*(kernelContext_71->state_0+_S967)) ).xyz;
    uint _S969 = sv_0(cb_1, 22U, kernelContext_71);
    float3 _S970 = (float4(*(kernelContext_71->scratch_0+_S969)) ).xyz;
    uint _S971 = sv_0(ca_1, 22U, kernelContext_71);
    float3 dth_0 = _S968 + (_S970 - (float4(*(kernelContext_71->scratch_0+_S971)) ).xyz);
    float3 _S972 = to_local_0(_S955, du_0 + (cross((float4(*(kernelContext_71->state_0+_S966)) ).xyz + (float4(*(kernelContext_71->scratch_0+_S969)) ).xyz, (float4(_S958->rb_0) ).xyz) - cross((float4(*(kernelContext_71->state_0+_S967)) ).xyz + (float4(*(kernelContext_71->scratch_0+_S971)) ).xyz, (float4(_S958->ra_0) ).xyz)), kernelContext_71);
    *_S956 = _S972;
    float3 _S973 = to_local_0(_S955, dth_0, kernelContext_71);
    *_S957 = _S973;
    return;
}

JointResponse_0 static_response_0(uint i_12, KernelContext_0 thread* kernelContext_72)
{
    BondStatic_natural_0 device* _S974 = kernelContext_72->bonds_0+i_12;
    thread float3 d_lin_4;
    thread float3 d_ang_3;
    static_kinematics_0(i_12, &d_lin_4, &d_ang_3, kernelContext_72);
    thread JointBond_natural_0 _S975 = _S974->law_0;
    _S975 = _S974->law_0;
    thread JointState_0 _S976 = (kernelContext_72->bond_dyn_0+i_12)->js_0;
    JointResponse_0 _S977 = joint_evaluate_0(&kernelContext_72->materials_0->m_0[(uint4((&_S975)->ids_0) ).x], &_S975, &_S976, d_lin_4, d_ang_3, 0.0f, false);
    return _S977;
}

void gather_loads_0(uint c_23, float3 thread* fi_1, float3 thread* mi_0, KernelContext_0 thread* kernelContext_73)
{
    float3 _S978 = float3(0.0f) ;
    *fi_1 = _S978;
    *mi_0 = _S978;
    uint e_2 = kernelContext_73->index_0[c_23];
    for(;;)
    {
        if(e_2 < (kernelContext_73->index_0)[c_23 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_1 = kernelContext_73->index_0[e_2];
        uint bond_0 = entry_1 >> 1U;
        if((entry_1 & 1U) == 0U)
        {
            uint _S979 = 3U * bond_0;
            *fi_1 = *fi_1 + (float4(*(kernelContext_73->scratch_0+_S979)) ).xyz;
            *mi_0 = *mi_0 + (float4(*(kernelContext_73->scratch_0+(_S979 + 1U))) ).xyz;
        }
        else
        {
            uint _S980 = 3U * bond_0;
            *fi_1 = *fi_1 - (float4(*(kernelContext_73->scratch_0+_S980)) ).xyz;
            *mi_0 = *mi_0 + (float4(*(kernelContext_73->scratch_0+(_S980 + 2U))) ).xyz;
        }
        e_2 = e_2 + 1U;
    }
    return;
}

float bond_load_magnitude2_0(uint c_24, KernelContext_0 thread* kernelContext_74)
{
    uint e_3 = kernelContext_74->index_0[c_24];
    float m_4 = 0.0f;
    for(;;)
    {
        if(e_3 < (kernelContext_74->index_0)[c_24 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_2 = kernelContext_74->index_0[e_3];
        uint _S981 = 3U * (entry_2 >> 1U);
        float3 f_14 = (float4(*(kernelContext_74->scratch_0+_S981)) ).xyz;
        float3 t_16;
        if((entry_2 & 1U) == 0U)
        {
            t_16 = (float4(*(kernelContext_74->scratch_0+(_S981 + 1U))) ).xyz;
        }
        else
        {
            t_16 = (float4(*(kernelContext_74->scratch_0+(_S981 + 2U))) ).xyz;
        }
        float m_5 = m_4 + (dot(f_14, f_14) + dot(t_16, t_16));
        e_3 = e_3 + 1U;
        m_4 = m_5;
    }
    return m_4;
}

uint fixed_mask_0(uint c_25, KernelContext_0 thread* kernelContext_75)
{
    uint support_0 = (uint4((kernelContext_75->chunks_0+c_25)->info_1) ).x;
    uint _S982;
    if(support_0 == 1U)
    {
        _S982 = 63U;
    }
    else
    {
        if(support_0 == 2U)
        {
            _S982 = 7U;
        }
        else
        {
            _S982 = 0U;
        }
    }
    return _S982;
}

void hold_0(uint mask_0, float4 thread* lin_0, float4 thread* ang_0, float4 keep_lin_0, float4 keep_ang_0)
{
    uint d_14 = 0U;
    for(;;)
    {
        if(d_14 < 3U)
        {
        }
        else
        {
            break;
        }
        if((mask_0 & (1U << d_14)) != 0U)
        {
            (*lin_0)[d_14] = keep_lin_0[d_14];
        }
        if((mask_0 & (1U << (d_14 + 3U))) != 0U)
        {
            (*ang_0)[d_14] = keep_ang_0[d_14];
        }
        d_14 = d_14 + 1U;
    }
    return;
}

uint statics_bond_slot_0(uint i_13, KernelContext_0 thread* kernelContext_76)
{
    return kernelContext_76->params_0->statics_base_0 + 23U * kernelContext_76->params_0->chunk_count_0 + 2U * i_13;
}

void store_inverse_0(uint c_26, const array<float, int(36)> thread* a_14, KernelContext_0 thread* kernelContext_77)
{
    uint j_8;
    float sum_4;
    thread array<float, int(36)> l_4;
    uint k_18 = 0U;
    for(;;)
    {
        if(k_18 < 36U)
        {
        }
        else
        {
            break;
        }
        l_4[k_18] = 0.0f;
        k_18 = k_18 + 1U;
    }
    bool spd_0 = true;
    uint i_14 = 0U;
    for(;;)
    {
        bool _S983;
        if(i_14 < 6U)
        {
            _S983 = spd_0;
        }
        else
        {
            _S983 = false;
        }
        if(_S983)
        {
        }
        else
        {
            break;
        }
        j_8 = 0U;
        for(;;)
        {
            if(j_8 <= i_14)
            {
            }
            else
            {
                break;
            }
            uint _S984 = i_14 * 6U;
            uint _S985 = _S984 + j_8;
            k_18 = 0U;
            sum_4 = (*a_14)[_S985];
            for(;;)
            {
                if(k_18 < j_8)
                {
                }
                else
                {
                    break;
                }
                float sum_5 = sum_4 - l_4[_S984 + k_18] * l_4[j_8 * 6U + k_18];
                k_18 = k_18 + 1U;
                sum_4 = sum_5;
            }
            if(i_14 == j_8)
            {
                if(sum_4 <= 0.0f)
                {
                    spd_0 = false;
                    break;
                }
                l_4[_S984 + i_14] = sqrt(sum_4);
            }
            else
            {
                l_4[_S985] = sum_4 / l_4[j_8 * 6U + j_8];
            }
            j_8 = j_8 + 1U;
        }
        i_14 = i_14 + 1U;
    }
    thread array<float, int(36)> inv_0;
    if(!spd_0)
    {
        k_18 = 0U;
        for(;;)
        {
            if(k_18 < 36U)
            {
            }
            else
            {
                break;
            }
            inv_0[k_18] = 0.0f;
            k_18 = k_18 + 1U;
        }
        k_18 = 0U;
        for(;;)
        {
            if(k_18 < 6U)
            {
            }
            else
            {
                break;
            }
            uint _S986 = k_18 * 6U + k_18;
            float _S987 = (*a_14)[_S986];
            if(((*a_14)[_S986]) > 0.0f)
            {
                sum_4 = 1.0f / _S987;
            }
            else
            {
                sum_4 = 0.0f;
            }
            inv_0[_S986] = sum_4;
            k_18 = k_18 + 1U;
        }
    }
    else
    {
        j_8 = 0U;
        for(;;)
        {
            if(j_8 < 6U)
            {
            }
            else
            {
                break;
            }
            thread array<float, int(6)> y_3;
            y_3[int(0)] = 0.0f;
            y_3[int(1)] = 0.0f;
            y_3[int(2)] = 0.0f;
            y_3[int(3)] = 0.0f;
            y_3[int(4)] = 0.0f;
            y_3[int(5)] = 0.0f;
            i_14 = 0U;
            for(;;)
            {
                if(i_14 < 6U)
                {
                }
                else
                {
                    break;
                }
                if(i_14 == j_8)
                {
                    sum_4 = 1.0f;
                }
                else
                {
                    sum_4 = 0.0f;
                }
                k_18 = 0U;
                float s_6 = sum_4;
                for(;;)
                {
                    if(k_18 < i_14)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_7 = s_6 - l_4[i_14 * 6U + k_18] * y_3[k_18];
                    k_18 = k_18 + 1U;
                    s_6 = s_7;
                }
                y_3[i_14] = s_6 / l_4[i_14 * 6U + i_14];
                i_14 = i_14 + 1U;
            }
            thread array<float, int(6)> x_15;
            x_15[int(0)] = 0.0f;
            x_15[int(1)] = 0.0f;
            x_15[int(2)] = 0.0f;
            x_15[int(3)] = 0.0f;
            x_15[int(4)] = 0.0f;
            x_15[int(5)] = 0.0f;
            uint ii_1 = 0U;
            for(;;)
            {
                if(ii_1 < 6U)
                {
                }
                else
                {
                    break;
                }
                uint i_15 = 5U - ii_1;
                k_18 = i_15 + 1U;
                sum_4 = y_3[i_15];
                for(;;)
                {
                    if(k_18 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_8 = sum_4 - l_4[k_18 * 6U + i_15] * x_15[k_18];
                    k_18 = k_18 + 1U;
                    sum_4 = s_8;
                }
                x_15[i_15] = sum_4 / l_4[i_15 * 6U + i_15];
                ii_1 = ii_1 + 1U;
            }
            uint i_16 = 0U;
            for(;;)
            {
                if(i_16 < 6U)
                {
                }
                else
                {
                    break;
                }
                inv_0[i_16 * 6U + j_8] = x_15[i_16];
                i_16 = i_16 + 1U;
            }
            j_8 = j_8 + 1U;
        }
    }
    j_8 = 0U;
    for(;;)
    {
        if(j_8 < 9U)
        {
        }
        else
        {
            break;
        }
        uint _S988 = sv_0(c_26, 12U + j_8, kernelContext_77);
        uint _S989 = 4U * j_8;
        *(kernelContext_77->scratch_0+_S988) = packed_float4(float4(inv_0[_S989], inv_0[_S989 + 1U], inv_0[_S989 + 2U], inv_0[_S989 + 3U])) ;
        j_8 = j_8 + 1U;
    }
    return;
}

void assemble_block_0(uint c_27, KernelContext_0 thread* kernelContext_78)
{
    uint p_15;
    uint r_13;
    thread array<float, int(36)> a_15;
    uint k_19 = 0U;
    for(;;)
    {
        if(k_19 < 36U)
        {
        }
        else
        {
            break;
        }
        a_15[k_19] = 0.0f;
        k_19 = k_19 + 1U;
    }
    uint e_4 = kernelContext_78->index_0[c_27];
    for(;;)
    {
        if(e_4 < (kernelContext_78->index_0)[c_27 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_3 = kernelContext_78->index_0[e_4];
        uint i_17 = entry_3 >> 1U;
        bool _S990 = (entry_3 & 1U) != 0U;
        BondStatic_natural_0 device* _S991 = kernelContext_78->bonds_0+i_17;
        uint _S992 = statics_bond_slot_0(i_17, kernelContext_78);
        float4 _S993 = float4(*(kernelContext_78->scratch_0+_S992)) ;
        float4 _S994 = float4(*(kernelContext_78->scratch_0+(_S992 + 1U))) ;
        p_15 = 0U;
        for(;;)
        {
            if(p_15 < 6U)
            {
            }
            else
            {
                break;
            }
            uint _S995 = p_15 % 3U;
            float3 t_17;
            if(_S995 == 0U)
            {
                t_17 = (float4(_S991->t1_0) ).xyz;
            }
            else
            {
                if(_S995 == 1U)
                {
                    t_17 = (float4(_S991->t2_0) ).xyz;
                }
                else
                {
                    t_17 = (float4(_S991->normal_0) ).xyz;
                }
            }
            bool _S996 = p_15 < 3U;
            float3 row_u_0;
            float3 row_t_0;
            if(_S996)
            {
                if(_S990)
                {
                    row_u_0 = t_17;
                }
                else
                {
                    row_u_0 = - t_17;
                }
                if(_S990)
                {
                    row_t_0 = cross((float4(_S991->rb_0) ).xyz, t_17);
                }
                else
                {
                    row_t_0 = - cross((float4(_S991->ra_0) ).xyz, t_17);
                }
            }
            else
            {
                float3 _S997 = float3(0.0f) ;
                if(_S990)
                {
                    row_u_0 = t_17;
                }
                else
                {
                    row_u_0 = - t_17;
                }
                float3 _S998 = row_u_0;
                row_u_0 = _S997;
                row_t_0 = _S998;
            }
            float kp_0;
            if(_S996)
            {
                kp_0 = _S993[p_15];
            }
            else
            {
                kp_0 = _S994[p_15 - 3U];
            }
            if(kp_0 == 0.0f)
            {
                p_15 = p_15 + 1U;
                continue;
            }
            array<float, int(6)> _S999 = { { row_u_0.x, row_u_0.y, row_u_0.z, row_t_0.x, row_t_0.y, row_t_0.z } };
            r_13 = 0U;
            for(;;)
            {
                if(r_13 < 6U)
                {
                }
                else
                {
                    break;
                }
                uint q_14 = 0U;
                for(;;)
                {
                    if(q_14 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    a_15[r_13 * 6U + q_14] = a_15[r_13 * 6U + q_14] + kp_0 * _S999[r_13] * _S999[q_14];
                    q_14 = q_14 + 1U;
                }
                r_13 = r_13 + 1U;
            }
            p_15 = p_15 + 1U;
        }
        e_4 = e_4 + 1U;
    }
    uint _S1000 = fixed_mask_0(c_27, kernelContext_78);
    p_15 = 0U;
    for(;;)
    {
        if(p_15 < 6U)
        {
        }
        else
        {
            break;
        }
        if((_S1000 & (1U << p_15)) != 0U)
        {
            r_13 = 0U;
            for(;;)
            {
                if(r_13 < 6U)
                {
                }
                else
                {
                    break;
                }
                a_15[p_15 * 6U + r_13] = 0.0f;
                a_15[r_13 * 6U + p_15] = 0.0f;
                r_13 = r_13 + 1U;
            }
            a_15[p_15 * 6U + p_15] = 1.0f;
        }
        p_15 = p_15 + 1U;
    }
    p_15 = 0U;
    for(;;)
    {
        if(p_15 < 6U)
        {
        }
        else
        {
            break;
        }
        if((a_15[p_15 * 6U + p_15]) == 0.0f)
        {
            a_15[p_15 * 6U + p_15] = 1.0f;
        }
        p_15 = p_15 + 1U;
    }
    thread array<float, int(36)> _S1001 = a_15;
    store_inverse_0(c_27, &_S1001, kernelContext_78);
    return;
}

float block_get_0(uint c_28, uint i_18, uint j_9, KernelContext_0 thread* kernelContext_79)
{
    uint k_20 = i_18 * 6U + j_9;
    uint _S1002 = sv_0(c_28, 12U + k_20 / 4U, kernelContext_79);
    return (*(kernelContext_79->scratch_0+_S1002))[k_20 % 4U];
}

void precondition_0(uint c_29, KernelContext_0 thread* kernelContext_80)
{
    uint _S1003 = sv_0(c_29, 4U, kernelContext_80);
    float4 _S1004 = float4(*(kernelContext_80->scratch_0+_S1003)) ;
    uint _S1005 = sv_0(c_29, 5U, kernelContext_80);
    float4 _S1006 = float4(*(kernelContext_80->scratch_0+_S1005)) ;
    array<float, int(6)> _S1007 = { { _S1004.x, _S1004.y, _S1004.z, _S1006.x, _S1006.y, _S1006.z } };
    thread array<float, int(6)> z_1;
    uint i_19 = 0U;
    for(;;)
    {
        if(i_19 < 6U)
        {
        }
        else
        {
            break;
        }
        uint j_10 = 0U;
        float s_9 = 0.0f;
        for(;;)
        {
            if(j_10 < 6U)
            {
            }
            else
            {
                break;
            }
            float _S1008 = block_get_0(c_29, i_19, j_10, kernelContext_80);
            float s_10 = s_9 + _S1008 * _S1007[j_10];
            j_10 = j_10 + 1U;
            s_9 = s_10;
        }
        z_1[i_19] = s_9;
        i_19 = i_19 + 1U;
    }
    uint _S1009 = sv_0(c_29, 6U, kernelContext_80);
    *(kernelContext_80->scratch_0+_S1009) = packed_float4(float4(z_1[int(0)], z_1[int(1)], z_1[int(2)], 0.0f)) ;
    uint _S1010 = sv_0(c_29, 7U, kernelContext_80);
    *(kernelContext_80->scratch_0+_S1010) = packed_float4(float4(z_1[int(3)], z_1[int(4)], z_1[int(5)], 0.0f)) ;
    return;
}

void project_displacement_slot_0(uint tid_15, const Island_natural_0 thread* isl_23, uint slot_5, KernelContext_0 thread* kernelContext_81)
{
    uint _S1011;
    float3 _S1012 = float3(0.0f) ;
    thread float3 p_16 = _S1012;
    thread float3 l_5 = _S1012;
    uint4 _S1013 = uint4(isl_23->range_0) ;
    uint _S1014 = _S1013.x + tid_15;
    uint c_30 = _S1014;
    for(;;)
    {
        uint _S1015 = _S1013.y;
        _S1011 = _S1015;
        if(c_30 < _S1015)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_natural_0 device* _S1016 = kernelContext_81->chunks_0+c_30;
        uint _S1017 = sv_0(c_30, slot_5, kernelContext_81);
        float3 u_0 = (float4(*(kernelContext_81->scratch_0+_S1017)) ).xyz;
        uint _S1018 = sv_0(c_30, slot_5 + 1U, kernelContext_81);
        float3 th_2 = (float4(*(kernelContext_81->scratch_0+_S1018)) ).xyz;
        float4 _S1019 = float4(_S1016->center_0) ;
        float3 r_14 = _S1019.xyz - (float4(isl_23->com_0) ).xyz;
        float3 _S1020 = float3(_S1019.w) ;
        p_16 = p_16 + u_0 * _S1020;
        l_5 = l_5 + (cross(r_14, u_0) * _S1020 + rows_mul_0(float4(_S1016->inertia0_1) , float4(_S1016->inertia1_1) , float4(_S1016->inertia2_1) , th_2));
        c_30 = c_30 + 256U;
    }
    group_sum3_0(tid_15, &p_16, &l_5, kernelContext_81);
    float4 _S1021 = float4(isl_23->com_0) ;
    float3 _S1022 = p_16 / float3(_S1021.w) ;
    float3 _S1023 = rows_mul_0(float4(isl_23->inv0_0) , float4(isl_23->inv1_0) , float4(isl_23->inv2_0) , l_5);
    c_30 = _S1014;
    for(;;)
    {
        if(c_30 < _S1011)
        {
        }
        else
        {
            break;
        }
        float3 r_15 = (float4((kernelContext_81->chunks_0+c_30)->center_0) ).xyz - _S1021.xyz;
        uint _S1024 = sv_0(c_30, slot_5, kernelContext_81);
        *(kernelContext_81->scratch_0+_S1024) = packed_float4(float4((float4(*(kernelContext_81->scratch_0+_S1024)) ).xyz - _S1022 - cross(_S1023, r_15), 0.0f)) ;
        uint _S1025 = sv_0(c_30, slot_5 + 1U, kernelContext_81);
        *(kernelContext_81->scratch_0+_S1025) = packed_float4(float4((float4(*(kernelContext_81->scratch_0+_S1025)) ).xyz - _S1023, 0.0f)) ;
        c_30 = c_30 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    return;
}

uint statics_result_slot_0(uint island_4, KernelContext_0 thread* kernelContext_82)
{
    return kernelContext_82->params_0->statics_base_0 + 23U * kernelContext_82->params_0->chunk_count_0 + 2U * kernelContext_82->params_0->statics_bonds_0 + island_4;
}

void write_bond_loads_0(uint _S1026, uint _S1027, float3 _S1028, float3 _S1029, float _S1030, KernelContext_0 thread* kernelContext_83)
{
    BondStatic_natural_0 device* _S1031 = kernelContext_83->bonds_0+_S1027;
    float3 _S1032 = to_body_0(_S1027, _S1028, kernelContext_83);
    float3 _S1033 = to_body_0(_S1027, _S1029, kernelContext_83);
    uint _S1034 = 3U * _S1026;
    *(kernelContext_83->scratch_0+_S1034) = packed_float4(float4(_S1032, _S1030)) ;
    *(kernelContext_83->scratch_0+(_S1034 + 1U)) = packed_float4(float4(_S1033 + cross((float4(_S1031->ra_0) ).xyz, _S1032), 0.0f)) ;
    *(kernelContext_83->scratch_0+(_S1034 + 2U)) = packed_float4(float4(- _S1033 + cross((float4(_S1031->rb_0) ).xyz, - _S1032), 0.0f)) ;
    return;
}

void bond_kinematics_0(uint _S1035, float3 _S1036, float3 _S1037, float3 _S1038, float3 _S1039, float3 thread* _S1040, float3 thread* _S1041, KernelContext_0 thread* kernelContext_84)
{
    BondStatic_natural_0 device* _S1042 = kernelContext_84->bonds_0+_S1035;
    float3 _S1043 = to_local_0(_S1035, _S1038 + cross(_S1039, (float4(_S1042->rb_0) ).xyz) - (_S1036 + cross(_S1037, (float4(_S1042->ra_0) ).xyz)), kernelContext_84);
    *_S1040 = _S1043;
    float3 _S1044 = to_local_0(_S1035, _S1039 - _S1037, kernelContext_84);
    *_S1041 = _S1044;
    return;
}

[[kernel]] void island_statics(uint3 group_6 [[threadgroup_position_in_grid]], uint3 thread_6 [[thread_position_in_threadgroup]], Params_0 constant* params_9 [[buffer(0)]], Island_natural_0 device* islands_9 [[buffer(9)]], uint device* index_9 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_9 [[buffer(3)]], packed_float4 device* state_11 [[buffer(6)]], packed_float4 device* scratch_9 [[buffer(8)]], packed_float4 device* contact_state_9 [[buffer(11)]], packed_float4 device* loads_9 [[buffer(5)]], Impactor_natural_0 device* impactors_9 [[buffer(10)]], BondStatic_natural_0 device* bonds_9 [[buffer(2)]], MaterialTable_0 constant* materials_9 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_9 [[buffer(7)]])
{
    uint i_20;
    bool converged_0;
    uint c_31;
    thread KernelContext_0 kernelContext_85;
    (&kernelContext_85)->params_0 = params_9;
    (&kernelContext_85)->islands_0 = islands_9;
    (&kernelContext_85)->index_0 = index_9;
    (&kernelContext_85)->chunks_0 = chunks_9;
    (&kernelContext_85)->state_0 = state_11;
    (&kernelContext_85)->scratch_0 = scratch_9;
    (&kernelContext_85)->contact_state_0 = contact_state_9;
    (&kernelContext_85)->loads_0 = loads_9;
    (&kernelContext_85)->impactors_0 = impactors_9;
    (&kernelContext_85)->bonds_0 = bonds_9;
    (&kernelContext_85)->materials_0 = materials_9;
    (&kernelContext_85)->bond_dyn_0 = bond_dyn_9;
    threadgroup array<float4, int(32)> g_part_a_9;
    (&kernelContext_85)->g_part_a_0 = &g_part_a_9;
    threadgroup array<float4, int(32)> g_part_b_9;
    (&kernelContext_85)->g_part_b_0 = &g_part_b_9;
    threadgroup array<uint, int(5)> g_seen_9;
    (&kernelContext_85)->g_seen_0 = &g_seen_9;
    threadgroup uint g_wide_run_9;
    (&kernelContext_85)->g_wide_run_0 = &g_wide_run_9;
    threadgroup uint g_halt_9;
    (&kernelContext_85)->g_halt_0 = &g_halt_9;
    threadgroup uint g_run_9;
    (&kernelContext_85)->g_run_0 = &g_run_9;
    uint tid_16 = thread_6.x;
    uint _S1045 = group_6.x;
    thread Island_natural_0 _S1046 = *(islands_9+_S1045);
    uint4 _S1047 = uint4((&_S1046)->info_0) ;
    uint _S1048 = _S1047.z;
    if((_S1048 & 8U) == 0U)
    {
        return;
    }
    bool free_0 = ((_S1047.x) & 1U) == 0U;
    uint4 _S1049 = uint4((&_S1046)->range_0) ;
    uint c0_1 = _S1049.x;
    uint c1_1 = _S1049.y;
    uint b0_0 = _S1049.z;
    uint _S1050 = _S1049.w;
    uint _S1051 = c0_1 + tid_16;
    uint c_32 = _S1051;
    for(;;)
    {
        if(c_32 < c1_1)
        {
        }
        else
        {
            break;
        }
        uint _S1052 = sv_0(c_32, 21U, &kernelContext_85);
        packed_float4 _S1053 = packed_float4(float4(0.0f) ) ;
        *((&kernelContext_85)->scratch_0+_S1052) = _S1053;
        uint _S1054 = sv_0(c_32, 22U, &kernelContext_85);
        *((&kernelContext_85)->scratch_0+_S1054) = _S1053;
        c_32 = c_32 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    if(free_0)
    {
        project_load_slot_0(tid_16, &_S1046, 0U, &kernelContext_85);
    }
    float _S1055 = island_dot_0(tid_16, c0_1, c1_1, 0U, 0U, &kernelContext_85);
    float _S1056 = max(sqrt(_S1055), 1.00000000317107685e-30f);
    float _S1057 = (&kernelContext_85)->params_0->statics_tol_0;
    uint _S1058 = min((&kernelContext_85)->params_0->statics_cg_0, 20U * (c1_1 - c0_1) * 6U + 200U);
    float previous_2 = 1.00000001504746622e+30f;
    float residual_0 = 0.0f;
    uint newton_0 = 0U;
    uint cg_total_0 = 0U;
    for(;;)
    {
        if(newton_0 < ((&kernelContext_85)->params_0->statics_newton_0))
        {
        }
        else
        {
            converged_0 = false;
            break;
        }
        uint _S1059 = b0_0 + tid_16;
        i_20 = _S1059;
        for(;;)
        {
            if(i_20 < _S1050)
            {
            }
            else
            {
                break;
            }
            JointResponse_0 _S1060 = static_response_0(i_20, &kernelContext_85);
            write_bond_loads_0(i_20, i_20, _S1060.force_lin_1, _S1060.force_ang_1, 0.0f, &kernelContext_85);
            i_20 = i_20 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        float4 _S1061 = float4(0.0f) ;
        thread float4 magnitude_0 = _S1061;
        thread float4 unused_m_0 = _S1061;
        c_32 = _S1051;
        for(;;)
        {
            if(c_32 < c1_1)
            {
            }
            else
            {
                break;
            }
            thread float3 fi_2;
            thread float3 mi_1;
            gather_loads_0(c_32, &fi_2, &mi_1, &kernelContext_85);
            float _S1062 = bond_load_magnitude2_0(c_32, &kernelContext_85);
            magnitude_0.x = magnitude_0.x + _S1062;
            uint _S1063 = sv_0(c_32, 0U, &kernelContext_85);
            thread float4 r_lin_0 = float4((float4(*((&kernelContext_85)->scratch_0+_S1063)) ).xyz + fi_2, 0.0f);
            uint _S1064 = sv_0(c_32, 1U, &kernelContext_85);
            thread float4 r_ang_0 = float4((float4(*((&kernelContext_85)->scratch_0+_S1064)) ).xyz + mi_1, 0.0f);
            uint _S1065 = fixed_mask_0(c_32, &kernelContext_85);
            hold_0(_S1065, &r_lin_0, &r_ang_0, _S1061, _S1061);
            uint _S1066 = sv_0(c_32, 4U, &kernelContext_85);
            *((&kernelContext_85)->scratch_0+_S1066) = packed_float4(r_lin_0) ;
            uint _S1067 = sv_0(c_32, 5U, &kernelContext_85);
            *((&kernelContext_85)->scratch_0+_S1067) = packed_float4(r_ang_0) ;
            c_32 = c_32 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        group_sum2_0(tid_16, &magnitude_0, &unused_m_0, &kernelContext_85);
        if(free_0)
        {
            project_load_slot_0(tid_16, &_S1046, 4U, &kernelContext_85);
        }
        float _S1068 = island_dot_0(tid_16, c0_1, c1_1, 4U, 4U, &kernelContext_85);
        float residual_1 = sqrt(_S1068) / _S1056;
        float _S1069 = max(0.00100000004749745f, 3.83999986297567375e-06f * sqrt(magnitude_0.x) / _S1056);
        if(residual_1 <= _S1057)
        {
            converged_0 = true;
        }
        else
        {
            if(residual_1 <= _S1069)
            {
                converged_0 = residual_1 > (0.5f * previous_2);
            }
            else
            {
                converged_0 = false;
            }
        }
        if(converged_0)
        {
            residual_0 = residual_1;
            converged_0 = true;
            break;
        }
        uint i_21 = _S1059;
        for(;;)
        {
            if(i_21 < _S1050)
            {
            }
            else
            {
                break;
            }
            BondStatic_natural_0 device* _S1070 = (&kernelContext_85)->bonds_0+i_21;
            thread float3 d_lin_5;
            thread float3 d_ang_4;
            static_kinematics_0(i_21, &d_lin_5, &d_ang_4, &kernelContext_85);
            thread JointBond_natural_0 _S1071 = _S1070->law_0;
            thread JointState_0 _S1072 = ((&kernelContext_85)->bond_dyn_0+i_21)->js_0;
            thread float3 f_lin_2;
            thread float3 f_ang_2;
            secant_factors_0(&_S1071, &_S1072, d_lin_5, &f_lin_2, &f_ang_2);
            float4 _S1073 = float4((&_S1071)->stiff0_0) ;
            uint _S1074 = statics_bond_slot_0(i_21, &kernelContext_85);
            float _S1075 = _S1073.y;
            *((&kernelContext_85)->scratch_0+_S1074) = packed_float4(float4(_S1075 * f_lin_2.x, _S1075 * f_lin_2.y, _S1073.x * f_lin_2.z, 0.0f)) ;
            *((&kernelContext_85)->scratch_0+(_S1074 + 1U)) = packed_float4(float4(_S1073.z * f_ang_2.x, _S1073.w * f_ang_2.y, (float4((&_S1071)->stiff1_0) ).x * f_ang_2.z, 0.0f)) ;
            i_21 = i_21 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_33 = _S1051;
        for(;;)
        {
            if(c_33 < c1_1)
            {
            }
            else
            {
                break;
            }
            assemble_block_0(c_33, &kernelContext_85);
            uint _S1076 = sv_0(c_33, 2U, &kernelContext_85);
            packed_float4 _S1077 = packed_float4(_S1061) ;
            *((&kernelContext_85)->scratch_0+_S1076) = _S1077;
            uint _S1078 = sv_0(c_33, 3U, &kernelContext_85);
            *((&kernelContext_85)->scratch_0+_S1078) = _S1077;
            c_33 = c_33 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_34 = _S1051;
        for(;;)
        {
            if(c_34 < c1_1)
            {
            }
            else
            {
                break;
            }
            precondition_0(c_34, &kernelContext_85);
            c_34 = c_34 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        if(free_0)
        {
            project_displacement_slot_0(tid_16, &_S1046, 6U, &kernelContext_85);
        }
        uint c_35 = _S1051;
        for(;;)
        {
            if(c_35 < c1_1)
            {
            }
            else
            {
                break;
            }
            uint _S1079 = sv_0(c_35, 8U, &kernelContext_85);
            packed_float4 device* _S1080 = (&kernelContext_85)->scratch_0+_S1079;
            uint _S1081 = sv_0(c_35, 6U, &kernelContext_85);
            *_S1080 = packed_float4(float4(*((&kernelContext_85)->scratch_0+_S1081)) ) ;
            uint _S1082 = sv_0(c_35, 9U, &kernelContext_85);
            packed_float4 device* _S1083 = (&kernelContext_85)->scratch_0+_S1082;
            uint _S1084 = sv_0(c_35, 7U, &kernelContext_85);
            *_S1083 = packed_float4(float4(*((&kernelContext_85)->scratch_0+_S1084)) ) ;
            c_35 = c_35 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        float _S1085 = island_dot_0(tid_16, c0_1, c1_1, 4U, 6U, &kernelContext_85);
        float _S1086 = island_dot_0(tid_16, c0_1, c1_1, 4U, 4U, &kernelContext_85);
        float _S1087 = sqrt(_S1086);
        float rz_0 = _S1085;
        uint k_21 = 0U;
        uint cg_total_1 = cg_total_0;
        for(;;)
        {
            bool _S1088;
            if(k_21 < _S1058)
            {
                _S1088 = _S1087 > 0.0f;
            }
            else
            {
                _S1088 = false;
            }
            if(_S1088)
            {
            }
            else
            {
                cg_total_0 = cg_total_1;
                break;
            }
            uint i_22 = _S1059;
            for(;;)
            {
                if(i_22 < _S1050)
                {
                }
                else
                {
                    break;
                }
                uint4 _S1089 = uint4(((&kernelContext_85)->bonds_0+i_22)->law_0.ids_0) ;
                uint ca_2 = _S1089.y;
                uint cb_2 = _S1089.z;
                uint _S1090 = sv_0(ca_2, 8U, &kernelContext_85);
                float3 _S1091 = (float4(*((&kernelContext_85)->scratch_0+_S1090)) ).xyz;
                uint _S1092 = sv_0(ca_2, 9U, &kernelContext_85);
                float3 _S1093 = (float4(*((&kernelContext_85)->scratch_0+_S1092)) ).xyz;
                uint _S1094 = sv_0(cb_2, 8U, &kernelContext_85);
                float3 _S1095 = (float4(*((&kernelContext_85)->scratch_0+_S1094)) ).xyz;
                uint _S1096 = sv_0(cb_2, 9U, &kernelContext_85);
                thread float3 d_lin_6;
                thread float3 d_ang_5;
                bond_kinematics_0(i_22, _S1091, _S1093, _S1095, (float4(*((&kernelContext_85)->scratch_0+_S1096)) ).xyz, &d_lin_6, &d_ang_5, &kernelContext_85);
                uint _S1097 = statics_bond_slot_0(i_22, &kernelContext_85);
                write_bond_loads_0(i_22, i_22, d_lin_6 * (float4(*((&kernelContext_85)->scratch_0+_S1097)) ).xyz, d_ang_5 * (float4(*((&kernelContext_85)->scratch_0+(_S1097 + 1U))) ).xyz, 0.0f, &kernelContext_85);
                i_22 = i_22 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            c_31 = _S1051;
            for(;;)
            {
                if(c_31 < c1_1)
                {
                }
                else
                {
                    break;
                }
                thread float3 fi_3;
                thread float3 mi_2;
                gather_loads_0(c_31, &fi_3, &mi_2, &kernelContext_85);
                thread float4 ap_lin_0 = float4(- fi_3, 0.0f);
                thread float4 ap_ang_0 = float4(- mi_2, 0.0f);
                uint _S1098 = fixed_mask_0(c_31, &kernelContext_85);
                uint _S1099 = sv_0(c_31, 8U, &kernelContext_85);
                float4 _S1100 = float4(*((&kernelContext_85)->scratch_0+_S1099)) ;
                uint _S1101 = sv_0(c_31, 9U, &kernelContext_85);
                hold_0(_S1098, &ap_lin_0, &ap_ang_0, _S1100, float4(*((&kernelContext_85)->scratch_0+_S1101)) );
                uint _S1102 = sv_0(c_31, 10U, &kernelContext_85);
                *((&kernelContext_85)->scratch_0+_S1102) = packed_float4(ap_lin_0) ;
                uint _S1103 = sv_0(c_31, 11U, &kernelContext_85);
                *((&kernelContext_85)->scratch_0+_S1103) = packed_float4(ap_ang_0) ;
                c_31 = c_31 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            float _S1104 = island_dot_0(tid_16, c0_1, c1_1, 8U, 10U, &kernelContext_85);
            uint _S1105 = cg_total_1 + 1U;
            if(_S1104 <= 0.0f)
            {
                cg_total_0 = _S1105;
                break;
            }
            float _S1106 = rz_0 / _S1104;
            uint c_36 = _S1051;
            for(;;)
            {
                if(c_36 < c1_1)
                {
                }
                else
                {
                    break;
                }
                uint _S1107 = sv_0(c_36, 2U, &kernelContext_85);
                packed_float4 device* _S1108 = (&kernelContext_85)->scratch_0+_S1107;
                float3 _S1109 = (float4(*((&kernelContext_85)->scratch_0+_S1107)) ).xyz;
                uint _S1110 = sv_0(c_36, 8U, &kernelContext_85);
                float3 _S1111 = float3(_S1106) ;
                *_S1108 = packed_float4(float4(_S1109 + _S1111 * (float4(*((&kernelContext_85)->scratch_0+_S1110)) ).xyz, 0.0f)) ;
                uint _S1112 = sv_0(c_36, 3U, &kernelContext_85);
                packed_float4 device* _S1113 = (&kernelContext_85)->scratch_0+_S1112;
                float3 _S1114 = (float4(*((&kernelContext_85)->scratch_0+_S1112)) ).xyz;
                uint _S1115 = sv_0(c_36, 9U, &kernelContext_85);
                *_S1113 = packed_float4(float4(_S1114 + _S1111 * (float4(*((&kernelContext_85)->scratch_0+_S1115)) ).xyz, 0.0f)) ;
                uint _S1116 = sv_0(c_36, 4U, &kernelContext_85);
                packed_float4 device* _S1117 = (&kernelContext_85)->scratch_0+_S1116;
                float3 _S1118 = (float4(*((&kernelContext_85)->scratch_0+_S1116)) ).xyz;
                uint _S1119 = sv_0(c_36, 10U, &kernelContext_85);
                *_S1117 = packed_float4(float4(_S1118 - _S1111 * (float4(*((&kernelContext_85)->scratch_0+_S1119)) ).xyz, 0.0f)) ;
                uint _S1120 = sv_0(c_36, 5U, &kernelContext_85);
                packed_float4 device* _S1121 = (&kernelContext_85)->scratch_0+_S1120;
                float3 _S1122 = (float4(*((&kernelContext_85)->scratch_0+_S1120)) ).xyz;
                uint _S1123 = sv_0(c_36, 11U, &kernelContext_85);
                *_S1121 = packed_float4(float4(_S1122 - _S1111 * (float4(*((&kernelContext_85)->scratch_0+_S1123)) ).xyz, 0.0f)) ;
                c_36 = c_36 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            float _S1124 = island_dot_0(tid_16, c0_1, c1_1, 4U, 4U, &kernelContext_85);
            if((sqrt(_S1124)) <= (0.00009999999747379f * _S1087))
            {
                cg_total_0 = _S1105;
                break;
            }
            uint c_37 = _S1051;
            for(;;)
            {
                if(c_37 < c1_1)
                {
                }
                else
                {
                    break;
                }
                precondition_0(c_37, &kernelContext_85);
                c_37 = c_37 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            if(free_0)
            {
                project_displacement_slot_0(tid_16, &_S1046, 6U, &kernelContext_85);
            }
            float _S1125 = island_dot_0(tid_16, c0_1, c1_1, 4U, 6U, &kernelContext_85);
            float _S1126 = _S1125 / rz_0;
            uint c_38 = _S1051;
            for(;;)
            {
                if(c_38 < c1_1)
                {
                }
                else
                {
                    break;
                }
                uint _S1127 = sv_0(c_38, 8U, &kernelContext_85);
                packed_float4 device* _S1128 = (&kernelContext_85)->scratch_0+_S1127;
                uint _S1129 = sv_0(c_38, 6U, &kernelContext_85);
                float3 _S1130 = float3(_S1126) ;
                *_S1128 = packed_float4(float4((float4(*((&kernelContext_85)->scratch_0+_S1129)) ).xyz + _S1130 * (float4(*((&kernelContext_85)->scratch_0+_S1127)) ).xyz, 0.0f)) ;
                uint _S1131 = sv_0(c_38, 9U, &kernelContext_85);
                packed_float4 device* _S1132 = (&kernelContext_85)->scratch_0+_S1131;
                uint _S1133 = sv_0(c_38, 7U, &kernelContext_85);
                *_S1132 = packed_float4(float4((float4(*((&kernelContext_85)->scratch_0+_S1133)) ).xyz + _S1130 * (float4(*((&kernelContext_85)->scratch_0+_S1131)) ).xyz, 0.0f)) ;
                c_38 = c_38 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            uint _S1134 = k_21 + 1U;
            rz_0 = _S1125;
            k_21 = _S1134;
            cg_total_1 = _S1105;
        }
        c_31 = _S1051;
        for(;;)
        {
            if(c_31 < c1_1)
            {
            }
            else
            {
                break;
            }
            uint _S1135 = 4U * c_31;
            thread float3 u_1 = (float4(*((&kernelContext_85)->state_0+_S1135)) ).xyz;
            uint _S1136 = sv_0(c_31, 21U, &kernelContext_85);
            thread float3 u_lo_0 = (float4(*((&kernelContext_85)->scratch_0+_S1136)) ).xyz;
            uint _S1137 = _S1135 + 1U;
            thread float3 th_3 = (float4(*((&kernelContext_85)->state_0+_S1137)) ).xyz;
            uint _S1138 = sv_0(c_31, 22U, &kernelContext_85);
            thread float3 th_lo_0 = (float4(*((&kernelContext_85)->scratch_0+_S1138)) ).xyz;
            uint _S1139 = sv_0(c_31, 2U, &kernelContext_85);
            comp_add_0(&u_1, &u_lo_0, (float4(*((&kernelContext_85)->scratch_0+_S1139)) ).xyz);
            uint _S1140 = sv_0(c_31, 3U, &kernelContext_85);
            comp_add_0(&th_3, &th_lo_0, (float4(*((&kernelContext_85)->scratch_0+_S1140)) ).xyz);
            *((&kernelContext_85)->state_0+_S1135) = packed_float4(float4(u_1, (float4(*((&kernelContext_85)->state_0+_S1135)) ).w)) ;
            *((&kernelContext_85)->state_0+_S1137) = packed_float4(float4(th_3, (float4(*((&kernelContext_85)->state_0+_S1137)) ).w)) ;
            *((&kernelContext_85)->scratch_0+_S1136) = packed_float4(float4(u_lo_0, 0.0f)) ;
            *((&kernelContext_85)->scratch_0+_S1138) = packed_float4(float4(th_lo_0, 0.0f)) ;
            c_31 = c_31 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint _S1141 = newton_0 + 1U;
        previous_2 = residual_1;
        residual_0 = residual_1;
        newton_0 = _S1141;
    }
    i_20 = b0_0 + tid_16;
    for(;;)
    {
        if(i_20 < _S1050)
        {
        }
        else
        {
            break;
        }
        JointResponse_0 _S1142 = static_response_0(i_20, &kernelContext_85);
        BondDyn_natural_0 device* _S1143 = (&kernelContext_85)->bond_dyn_0+i_20;
        float4 _S1144 = float4((*_S1143).force_lin_0) ;
        float4 _S1145 = float4((*_S1143).force_ang_0) ;
        float4 _S1146 = float4((*_S1143).sums_0) ;
        float4 _S1147 = float4((*_S1143).comps_0) ;
        uint4 _S1148 = uint4((*_S1143).events_0) ;
        thread BondDyn_0 bd_1;
        (&bd_1)->js_0 = (*_S1143).js_0;
        (&bd_1)->force_lin_0 = _S1144;
        (&bd_1)->force_ang_0 = _S1145;
        (&bd_1)->sums_0 = _S1146;
        (&bd_1)->comps_0 = _S1147;
        (&bd_1)->events_0 = _S1148;
        (&bd_1)->force_lin_0 = float4(_S1142.force_lin_1, _S1142.stored_3);
        (&bd_1)->force_ang_0 = float4(_S1142.force_ang_1, (&bd_1)->force_ang_0.w);
        BondDyn_natural_0 device* _S1149 = (&kernelContext_85)->bond_dyn_0+i_20;
        _S1149->js_0 = bd_1.js_0;
        _S1149->force_lin_0 = packed_float4(bd_1.force_lin_0) ;
        _S1149->force_ang_0 = packed_float4(bd_1.force_ang_0) ;
        _S1149->sums_0 = packed_float4(bd_1.sums_0) ;
        _S1149->comps_0 = packed_float4(bd_1.comps_0) ;
        _S1149->events_0 = packed_uint4(bd_1.events_0) ;
        write_bond_loads_0(i_20, i_20, _S1142.force_lin_1, _S1142.force_ang_1, max(_S1142.measures_0.tension_0, _S1142.measures_0.compression_0), &kernelContext_85);
        i_20 = i_20 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    c_32 = _S1051;
    for(;;)
    {
        if(c_32 < c1_1)
        {
        }
        else
        {
            break;
        }
        thread float3 fi_4;
        thread float3 mi_3;
        gather_loads_0(c_32, &fi_4, &mi_3, &kernelContext_85);
        uint _S1150 = fixed_mask_0(c_32, &kernelContext_85);
        float3 reaction_0;
        if(_S1150 != 0U)
        {
            uint _S1151 = sv_0(c_32, 0U, &kernelContext_85);
            reaction_0 = - ((float4(*((&kernelContext_85)->scratch_0+_S1151)) ).xyz + fi_4);
        }
        else
        {
            uint _S1152 = 4U * c_32;
            reaction_0 = float3((float4(*((&kernelContext_85)->state_0+(_S1152 + 1U))) ).w, (float4(*((&kernelContext_85)->state_0+(_S1152 + 2U))) ).w, (float4(*((&kernelContext_85)->state_0+(_S1152 + 3U))) ).w);
        }
        uint _S1153 = 4U * c_32;
        uint _S1154 = _S1153 + 1U;
        *((&kernelContext_85)->state_0+_S1154) = packed_float4(float4((float4(*((&kernelContext_85)->state_0+_S1154)) ).xyz, reaction_0.x)) ;
        *((&kernelContext_85)->state_0+(_S1153 + 2U)) = packed_float4(float4(0.0f, 0.0f, 0.0f, reaction_0.y)) ;
        *((&kernelContext_85)->state_0+(_S1153 + 3U)) = packed_float4(float4(0.0f, 0.0f, 0.0f, reaction_0.z)) ;
        c_32 = c_32 + 256U;
    }
    if(tid_16 == 0U)
    {
        uint _S1155 = statics_result_slot_0(_S1045, &kernelContext_85);
        packed_float4 device* _S1156 = (&kernelContext_85)->scratch_0+_S1155;
        float _S1157 = (as_type<float>((newton_0)));
        float _S1158 = (as_type<float>((cg_total_0)));
        if(converged_0)
        {
            previous_2 = 1.0f;
        }
        else
        {
            previous_2 = 0.0f;
        }
        *_S1156 = packed_float4(float4(residual_0, _S1157, _S1158, previous_2)) ;
        ((&kernelContext_85)->islands_0+_S1045)->info_0[int(2)] = _S1048 & 4294967287U;
    }
    return;
}

[[kernel]] void settled_fatigue(uint3 group_7 [[threadgroup_position_in_grid]], uint3 thread_7 [[thread_position_in_threadgroup]], Params_0 constant* params_10 [[buffer(0)]], Island_natural_0 device* islands_10 [[buffer(9)]], uint device* index_10 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_10 [[buffer(3)]], packed_float4 device* state_12 [[buffer(6)]], packed_float4 device* scratch_10 [[buffer(8)]], packed_float4 device* contact_state_10 [[buffer(11)]], packed_float4 device* loads_10 [[buffer(5)]], Impactor_natural_0 device* impactors_10 [[buffer(10)]], BondStatic_natural_0 device* bonds_10 [[buffer(2)]], MaterialTable_0 constant* materials_10 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_10 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_86;
    (&kernelContext_86)->params_0 = params_10;
    (&kernelContext_86)->islands_0 = islands_10;
    (&kernelContext_86)->index_0 = index_10;
    (&kernelContext_86)->chunks_0 = chunks_10;
    (&kernelContext_86)->state_0 = state_12;
    (&kernelContext_86)->scratch_0 = scratch_10;
    (&kernelContext_86)->contact_state_0 = contact_state_10;
    (&kernelContext_86)->loads_0 = loads_10;
    (&kernelContext_86)->impactors_0 = impactors_10;
    (&kernelContext_86)->bonds_0 = bonds_10;
    (&kernelContext_86)->materials_0 = materials_10;
    (&kernelContext_86)->bond_dyn_0 = bond_dyn_10;
    threadgroup array<float4, int(32)> g_part_a_10;
    (&kernelContext_86)->g_part_a_0 = &g_part_a_10;
    threadgroup array<float4, int(32)> g_part_b_10;
    (&kernelContext_86)->g_part_b_0 = &g_part_b_10;
    threadgroup array<uint, int(5)> g_seen_10;
    (&kernelContext_86)->g_seen_0 = &g_seen_10;
    threadgroup uint g_wide_run_10;
    (&kernelContext_86)->g_wide_run_0 = &g_wide_run_10;
    threadgroup uint g_halt_10;
    (&kernelContext_86)->g_halt_0 = &g_halt_10;
    threadgroup uint g_run_10;
    (&kernelContext_86)->g_run_0 = &g_run_10;
    uint tid_17 = thread_7.x;
    uint _S1159 = group_7.x;
    Island_natural_0 device* _S1160 = islands_10+_S1159;
    Island_natural_0 isl_24 = *_S1160;
    uint4 _S1161 = uint4((*_S1160).info_0) ;
    bool _S1162;
    if(((_S1161.x) & 16U) == 0U)
    {
        _S1162 = true;
    }
    else
    {
        uint4 _S1163 = uint4(isl_24.range_0) ;
        _S1162 = (_S1163.w) == (_S1163.z);
    }
    if(_S1162)
    {
        return;
    }
    seen_clear_0(tid_17, &kernelContext_86);
    if(tid_17 == 0U)
    {
        *(&kernelContext_86)->g_halt_0 = 0U;
        *(&kernelContext_86)->g_run_0 = 0U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    uint _S1164 = _S1161.w;
    uint4 _S1165 = uint4(isl_24.range_0) ;
    uint i_23 = _S1165.z + tid_17;
    for(;;)
    {
        if(i_23 < (_S1165.w))
        {
        }
        else
        {
            break;
        }
        BondStatic_natural_0 device* _S1166 = (&kernelContext_86)->bonds_0+i_23;
        BondDyn_natural_0 device* _S1167 = (&kernelContext_86)->bond_dyn_0+i_23;
        float4 _S1168 = float4((*_S1167).force_lin_0) ;
        float4 _S1169 = float4((*_S1167).force_ang_0) ;
        float4 _S1170 = float4((*_S1167).sums_0) ;
        float4 _S1171 = float4((*_S1167).comps_0) ;
        uint4 _S1172 = uint4((*_S1167).events_0) ;
        thread BondDyn_0 bd_2;
        (&bd_2)->js_0 = (*_S1167).js_0;
        (&bd_2)->force_lin_0 = _S1168;
        (&bd_2)->force_ang_0 = _S1169;
        (&bd_2)->sums_0 = _S1170;
        (&bd_2)->comps_0 = _S1171;
        (&bd_2)->events_0 = _S1172;
        thread JointBond_natural_0 _S1173 = _S1166->law_0;
        uint4 _S1174 = uint4((&_S1173)->ids_0) ;
        uint _S1175 = 4U * _S1174.y;
        uint _S1176 = 4U * _S1174.z;
        thread float3 d_lin_7;
        thread float3 d_ang_6;
        bond_kinematics_0(i_23, (float4(*((&kernelContext_86)->state_0+_S1175)) ).xyz, (float4(*((&kernelContext_86)->state_0+(_S1175 + 1U))) ).xyz, (float4(*((&kernelContext_86)->state_0+_S1176)) ).xyz, (float4(*((&kernelContext_86)->state_0+(_S1176 + 1U))) ).xyz, &d_lin_7, &d_ang_6, &kernelContext_86);
        JointState_0 previous_3 = (&bd_2)->js_0;
        float _S1177 = (&kernelContext_86)->params_0->dt_0;
        bool _S1178 = ((&kernelContext_86)->params_0->fracture_0) != 0U;
        _S1173 = _S1166->law_0;
        thread JointState_0 _S1179 = (&bd_2)->js_0;
        JointResponse_0 _S1180 = joint_evaluate_0(&(&kernelContext_86)->materials_0->m_0[_S1174.x], &_S1173, &_S1179, d_lin_7, d_ang_6, _S1177, _S1178);
        if((_S1180.state_5.damage_0) > (previous_3.damage_0 + 9.99999971718068537e-10f))
        {
            _S1162 = true;
        }
        else
        {
            _S1162 = (_S1180.state_5.crush_1) > (previous_3.crush_1 + 9.99999971718068537e-10f);
        }
        uint flags_3;
        if(_S1162)
        {
            flags_3 = 16U;
        }
        else
        {
            flags_3 = 0U;
        }
        thread float _S1181 = (&bd_2)->sums_0.x;
        thread float _S1182 = (&bd_2)->comps_0.x;
        comp_add1_0(&_S1181, &_S1182, _S1180.dissipated_2);
        (&bd_2)->comps_0.x = _S1182;
        (&bd_2)->sums_0.x = _S1181;
        thread float _S1183 = (&bd_2)->sums_0.y;
        thread float _S1184 = (&bd_2)->comps_0.y;
        comp_add1_0(&_S1183, &_S1184, _S1180.overshoot_0);
        (&bd_2)->comps_0.y = _S1184;
        (&bd_2)->sums_0.y = _S1183;
        (&bd_2)->force_lin_0 = float4(_S1180.force_lin_1, _S1180.stored_3);
        (&bd_2)->force_ang_0 = float4(_S1180.force_ang_1, max((&bd_2)->force_ang_0.w, _S1180.state_5.utilization_0));
        thread JointState_0 _S1185 = previous_3;
        bool _S1186 = is_damaged_0(&_S1185);
        bool _S1187;
        if(!_S1186)
        {
            thread JointState_0 _S1188 = _S1180.state_5;
            bool _S1189 = is_damaged_0(&_S1188);
            _S1187 = _S1189;
        }
        else
        {
            _S1187 = false;
        }
        bool _S1190;
        if(_S1187)
        {
            _S1190 = ((&bd_2)->events_0.x) == 0U;
        }
        else
        {
            _S1190 = false;
        }
        if(_S1190)
        {
            (&bd_2)->events_0.x = _S1164;
            (&bd_2)->events_0.w = _S1180.state_5.mode_0;
            (*(&kernelContext_86)->g_seen_0)[3U] = 1U;
        }
        bool _S1191;
        if(((&bd_2)->events_0.y) == 0U)
        {
            _S1191 = (_S1180.state_5.life_0) != (previous_3.life_0);
        }
        else
        {
            _S1191 = false;
        }
        bool _S1192;
        if(_S1191)
        {
            _S1192 = (_S1180.fatigue_before_0) > 0.99000000953674316f;
        }
        else
        {
            _S1192 = false;
        }
        bool _S1193;
        if(_S1192)
        {
            float _S1194 = fatigue_factor_0(&(&kernelContext_86)->materials_0->m_0[_S1174.x], _S1180.state_5.life_0);
            _S1193 = _S1194 <= 0.99000000953674316f;
        }
        else
        {
            _S1193 = false;
        }
        if(_S1193)
        {
            (&bd_2)->events_0.y = _S1164;
            (*(&kernelContext_86)->g_seen_0)[4U] = 1U;
        }
        uint flags_4;
        if(_S1180.disconnected_0)
        {
            (&bd_2)->events_0.z = _S1164;
            flags_4 = flags_3 | 32U;
        }
        else
        {
            flags_4 = flags_3;
        }
        (&bd_2)->js_0 = _S1180.state_5;
        BondDyn_natural_0 device* _S1195 = (&kernelContext_86)->bond_dyn_0+i_23;
        _S1195->js_0 = bd_2.js_0;
        _S1195->force_lin_0 = packed_float4(bd_2.force_lin_0) ;
        _S1195->force_ang_0 = packed_float4(bd_2.force_ang_0) ;
        _S1195->sums_0 = packed_float4(bd_2.sums_0) ;
        _S1195->comps_0 = packed_float4(bd_2.comps_0) ;
        _S1195->events_0 = packed_uint4(bd_2.events_0) ;
        write_bond_loads_0(i_23, i_23, _S1180.force_lin_1, _S1180.force_ang_1, max(_S1180.measures_0.tension_0, _S1180.measures_0.compression_0), &kernelContext_86);
        if((flags_4 & 16U) != 0U)
        {
            *(&kernelContext_86)->g_halt_0 = 1U;
        }
        if((flags_4 & 32U) != 0U)
        {
            *(&kernelContext_86)->g_run_0 = 1U;
        }
        i_23 = i_23 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    if(tid_17 != 0U)
    {
        return;
    }
    if(((*(&kernelContext_86)->g_halt_0) | (*(&kernelContext_86)->g_run_0)) != 0U)
    {
        uint _S1196 = _S1161.z;
        if((*(&kernelContext_86)->g_halt_0) != 0U)
        {
            i_23 = 16U;
        }
        else
        {
            i_23 = 0U;
        }
        uint _S1197 = _S1196 | i_23;
        if((*(&kernelContext_86)->g_run_0) != 0U)
        {
            i_23 = 32U;
        }
        else
        {
            i_23 = 0U;
        }
        ((&kernelContext_86)->islands_0+_S1159)->info_0[int(2)] = _S1197 | i_23;
    }
    uint _S1198 = (isl_24.coverage_0) | 16384U;
    uint _S1199 = seen_bits_0(&kernelContext_86);
    uint _S1200 = _S1198 | _S1199;
    if((*(&kernelContext_86)->g_run_0) != 0U)
    {
        i_23 = 128U;
    }
    else
    {
        i_23 = 0U;
    }
    ((&kernelContext_86)->islands_0+_S1159)->coverage_0 = _S1200 | i_23;
    return;
}

void impactor_integrate_at_0(uint ii_2, uint tid_18, KernelContext_0 thread* kernelContext_87)
{
    float3 p_17;
    if(ii_2 >= (kernelContext_87->params_0->impactor_count_0))
    {
        return;
    }
    Island_natural_0 device* _S1201 = kernelContext_87->islands_0+kernelContext_87->params_0->halt_index_0;
    Impactor_natural_0 device* _S1202 = kernelContext_87->impactors_0+ii_2;
    float4 _S1203 = float4((*_S1202).position_err_1) ;
    float4 _S1204 = float4((*_S1202).velocity_1) ;
    float4 _S1205 = float4((*_S1202).velocity_err_1) ;
    float4 _S1206 = float4((*_S1202).angular_velocity_1) ;
    float4 _S1207 = float4((*_S1202).rotation_1) ;
    float4 _S1208 = float4((*_S1202).inertia0_2) ;
    float4 _S1209 = float4((*_S1202).inertia1_2) ;
    float4 _S1210 = float4((*_S1202).inertia2_2) ;
    float4 _S1211 = float4((*_S1202).inv0_2) ;
    float4 _S1212 = float4((*_S1202).inv1_2) ;
    float4 _S1213 = float4((*_S1202).inv2_2) ;
    float4 _S1214 = float4((*_S1202).shape_0) ;
    float4 _S1215 = float4((*_S1202).half_1) ;
    float4 _S1216 = float4((*_S1202).mat_0) ;
    float4 _S1217 = float4((*_S1202).crush_0) ;
    float4 _S1218 = float4((*_S1202).geom_0) ;
    float4 _S1219 = float4((*_S1202).rotation_err_1) ;
    float4 _S1220 = float4((*_S1202).ledger_0) ;
    uint4 _S1221 = uint4((*_S1202).cand_0) ;
    float4 _S1222 = float4((*_S1202).momentum_1) ;
    float4 _S1223 = float4((*_S1202).momentum_err_1) ;
    thread Impactor_0 imp_6;
    (&imp_6)->position_1 = float4((*_S1202).position_1) ;
    (&imp_6)->position_err_1 = _S1203;
    (&imp_6)->velocity_1 = _S1204;
    (&imp_6)->velocity_err_1 = _S1205;
    (&imp_6)->angular_velocity_1 = _S1206;
    (&imp_6)->rotation_1 = _S1207;
    (&imp_6)->inertia0_2 = _S1208;
    (&imp_6)->inertia1_2 = _S1209;
    (&imp_6)->inertia2_2 = _S1210;
    (&imp_6)->inv0_2 = _S1211;
    (&imp_6)->inv1_2 = _S1212;
    (&imp_6)->inv2_2 = _S1213;
    (&imp_6)->shape_0 = _S1214;
    (&imp_6)->half_1 = _S1215;
    (&imp_6)->mat_0 = _S1216;
    (&imp_6)->crush_0 = _S1217;
    (&imp_6)->geom_0 = _S1218;
    (&imp_6)->rotation_err_1 = _S1219;
    (&imp_6)->ledger_0 = _S1220;
    (&imp_6)->cand_0 = _S1221;
    (&imp_6)->momentum_1 = _S1222;
    (&imp_6)->momentum_err_1 = _S1223;
    uint4 _S1224 = uint4(_S1201->info_0) ;
    bool _S1225;
    if(((_S1224.z) & 1U) != 0U)
    {
        _S1225 = true;
    }
    else
    {
        uint _S1226 = _S1224.y;
        if(_S1226 != 0U)
        {
            _S1225 = ((&imp_6)->cand_0.w) >= _S1226;
        }
        else
        {
            _S1225 = false;
        }
    }
    if(_S1225)
    {
        return;
    }
    if(((&imp_6)->cand_0.z) != 0U)
    {
        if(tid_18 == 0U)
        {
            (kernelContext_87->impactors_0+ii_2)->cand_0[int(3)] = (&imp_6)->cand_0.w + 1U;
        }
        return;
    }
    float4 _S1227 = float4(0.0f) ;
    thread float4 rf_1 = _S1227;
    thread float4 rt_0 = _S1227;
    uint k_22 = (&imp_6)->cand_0.x + tid_18;
    for(;;)
    {
        if(k_22 < ((&imp_6)->cand_0.y))
        {
        }
        else
        {
            break;
        }
        uint _S1228 = 3U * k_22;
        rf_1 = rf_1 + float4(*(kernelContext_87->scratch_0+(kernelContext_87->params_0->cand_base_0 + _S1228 + 1U))) ;
        rt_0 = rt_0 + float4(*(kernelContext_87->scratch_0+(kernelContext_87->params_0->cand_base_0 + _S1228 + 2U))) ;
        k_22 = k_22 + 256U;
    }
    group_sum2_0(tid_18, &rf_1, &rt_0, kernelContext_87);
    if(tid_18 != 0U)
    {
        return;
    }
    float dt_13 = kernelContext_87->params_0->dt_0;
    float3 _S1229 = float3(0.0f) ;
    float3 load_f_0;
    float3 load_t_0;
    if((kernelContext_87->params_0->has_ground_0) != 0U)
    {
        float3 _S1230 = (&imp_6)->half_1.xyz;
        thread Impactor_0 _S1231 = imp_6;
        Box_0 _S1232 = impactor_box_0(&_S1231, _S1229, _S1230);
        float3 _S1233 = (&imp_6)->velocity_1.xyz + (&imp_6)->velocity_err_1.xyz;
        float _S1234 = kernelContext_87->params_0->ground_modulus_0;
        float _S1235 = (&imp_6)->mat_0.x;
        float3 _S1236 = float3(0.0f, 0.0f, 1.0f);
        thread Box_0 _S1237 = _S1232;
        thread Box_0 _S1238 = _S1232;
        float _S1239 = contact_stiffness_0(_S1234, &_S1237, _S1235, &_S1238, _S1236);
        float _S1240 = (&imp_6)->position_1.z - kernelContext_87->params_0->ground_hi_0 + ((&imp_6)->position_err_1.z - kernelContext_87->params_0->ground_lo_0);
        uint total_points_0;
        if(((&imp_6)->shape_0.x) == 0.0f)
        {
            total_points_0 = 1U;
        }
        else
        {
            total_points_0 = 14U;
        }
        float _S1241 = _S1239 / float(min(total_points_0, 5U));
        uint s_11 = 0U;
        uint below_0 = 0U;
        for(;;)
        {
            if(s_11 < total_points_0)
            {
            }
            else
            {
                break;
            }
            if(((&imp_6)->shape_0.x) == 0.0f)
            {
                p_17 = float3(0.0f, 0.0f, - (&imp_6)->shape_0.y);
            }
            else
            {
                thread Box_0 _S1242 = _S1232;
                float3 _S1243 = sample_point_0(&_S1242, s_11, kernelContext_87);
                p_17 = _S1243;
            }
            if((_S1240 + p_17.z) < 0.0f)
            {
                below_0 = below_0 + 1U;
            }
            s_11 = s_11 + 1U;
        }
        if(below_0 > 0U)
        {
            sentinel_mark_0(8U, kernelContext_87);
        }
        s_11 = 0U;
        load_f_0 = _S1229;
        load_t_0 = _S1229;
        for(;;)
        {
            if(s_11 < total_points_0)
            {
            }
            else
            {
                break;
            }
            if(((&imp_6)->shape_0.x) == 0.0f)
            {
                p_17 = float3(0.0f, 0.0f, - (&imp_6)->shape_0.y);
            }
            else
            {
                thread Box_0 _S1244 = _S1232;
                float3 _S1245 = sample_point_0(&_S1244, s_11, kernelContext_87);
                p_17 = _S1245;
            }
            float depth_4 = - (_S1240 + p_17.z);
            if(depth_4 <= 0.0f)
            {
                s_11 = s_11 + 1U;
                continue;
            }
            thread float stored_7;
            thread float diss_5;
            float3 _S1246 = penalty_force_0(_S1241, (&imp_6)->mat_0.z, kernelContext_87->params_0->ground_friction_0, depth_4, _S1236, _S1233 + cross((&imp_6)->angular_velocity_1.xyz, p_17), dt_13, below_0, &stored_7, &diss_5, kernelContext_87);
            float3 load_f_1 = load_f_0 + _S1246;
            float3 load_t_1 = load_t_0 + cross(p_17, _S1246);
            thread float _S1247 = (&imp_6)->ledger_0.x;
            thread float _S1248 = (&imp_6)->ledger_0.y;
            comp_add1_0(&_S1247, &_S1248, diss_5);
            (&imp_6)->ledger_0.y = _S1248;
            (&imp_6)->ledger_0.x = _S1247;
            load_f_0 = load_f_1;
            load_t_0 = load_t_1;
            s_11 = s_11 + 1U;
        }
    }
    else
    {
        load_f_0 = _S1229;
        load_t_0 = _S1229;
    }
    float3 load_f_2 = rf_1.xyz + load_f_0;
    float3 load_t_2 = rt_0.xyz + load_t_0;
    float m_6 = (&imp_6)->mat_0.z;
    thread float3 vel_3 = (&imp_6)->velocity_1.xyz;
    thread float3 vel_err_1 = (&imp_6)->velocity_err_1.xyz;
    float3 _S1249 = float3(dt_13) ;
    comp_add_0(&vel_3, &vel_err_1, (load_f_2 / float3(m_6)  + kernelContext_87->params_0->gravity_0.xyz) * _S1249);
    Quat_0 _S1250 = quat_of_0((&imp_6)->rotation_1);
    thread Quat_0 q_15 = _S1250;
    thread float4 q_err_0 = (&imp_6)->rotation_err_1;
    thread float3 l_hi_0 = (&imp_6)->momentum_1.xyz;
    thread float3 l_err_1 = (&imp_6)->momentum_err_1.xyz;
    comp_add_0(&l_hi_0, &l_err_1, load_t_2 * _S1249);
    float3 l_6 = l_hi_0 + l_err_1;
    thread Quat_0 _S1251 = _S1250;
    float3 _S1252 = world_mul_0(&_S1251, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_6);
    thread float3 pos_1 = (&imp_6)->position_1.xyz;
    thread float3 pos_err_1 = (&imp_6)->position_err_1.xyz;
    comp_add_0(&pos_1, &pos_err_1, (vel_3 + vel_err_1) * _S1249);
    turn_left_0(&q_15, &q_err_0, _S1252, dt_13);
    thread Quat_0 _S1253 = q_15;
    float3 _S1254 = world_mul_0(&_S1253, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_6);
    (&imp_6)->angular_velocity_1 = float4(_S1254, 0.0f);
    thread Quat_0 _S1255 = q_15;
    float4 _S1256 = quat_vec_0(&_S1255);
    (&imp_6)->rotation_1 = _S1256;
    (&imp_6)->rotation_err_1 = q_err_0;
    (&imp_6)->momentum_1 = float4(l_hi_0, 0.0f);
    (&imp_6)->momentum_err_1 = float4(l_err_1, 0.0f);
    (&imp_6)->position_1 = float4(pos_1, 0.0f);
    (&imp_6)->position_err_1 = float4(pos_err_1, 0.0f);
    (&imp_6)->velocity_1 = float4(vel_3, 0.0f);
    (&imp_6)->velocity_err_1 = float4(vel_err_1, 0.0f);
    (&imp_6)->cand_0.w = (&imp_6)->cand_0.w + 1U;
    (&imp_6)->geom_0 = float4(1.0f, (&imp_6)->crush_0.w, 0.0f, 0.0f);
    Impactor_natural_0 device* _S1257 = kernelContext_87->impactors_0+ii_2;
    _S1257->position_1 = packed_float4(imp_6.position_1) ;
    _S1257->position_err_1 = packed_float4(imp_6.position_err_1) ;
    _S1257->velocity_1 = packed_float4(imp_6.velocity_1) ;
    _S1257->velocity_err_1 = packed_float4(imp_6.velocity_err_1) ;
    _S1257->angular_velocity_1 = packed_float4(imp_6.angular_velocity_1) ;
    _S1257->rotation_1 = packed_float4(imp_6.rotation_1) ;
    _S1257->inertia0_2 = packed_float4(imp_6.inertia0_2) ;
    _S1257->inertia1_2 = packed_float4(imp_6.inertia1_2) ;
    _S1257->inertia2_2 = packed_float4(imp_6.inertia2_2) ;
    _S1257->inv0_2 = packed_float4(imp_6.inv0_2) ;
    _S1257->inv1_2 = packed_float4(imp_6.inv1_2) ;
    _S1257->inv2_2 = packed_float4(imp_6.inv2_2) ;
    _S1257->shape_0 = packed_float4(imp_6.shape_0) ;
    _S1257->half_1 = packed_float4(imp_6.half_1) ;
    _S1257->mat_0 = packed_float4(imp_6.mat_0) ;
    _S1257->crush_0 = packed_float4(imp_6.crush_0) ;
    _S1257->geom_0 = packed_float4(imp_6.geom_0) ;
    _S1257->rotation_err_1 = packed_float4(imp_6.rotation_err_1) ;
    _S1257->ledger_0 = packed_float4(imp_6.ledger_0) ;
    _S1257->cand_0 = packed_uint4(imp_6.cand_0) ;
    _S1257->momentum_1 = packed_float4(imp_6.momentum_1) ;
    _S1257->momentum_err_1 = packed_float4(imp_6.momentum_err_1) ;
    uint k_23 = (&imp_6)->cand_0.w - 1U - kernelContext_87->params_0->step_start_0;
    if(k_23 < (kernelContext_87->params_0->record_stride_0))
    {
        uint at_6 = kernelContext_87->params_0->record_base_0 + 2U * (ii_2 * kernelContext_87->params_0->record_stride_0 + k_23);
        *(kernelContext_87->scratch_0+at_6) = packed_float4(float4(vel_3 + vel_err_1, 0.0f)) ;
        *(kernelContext_87->scratch_0+(at_6 + 1U)) = packed_float4(float4(pos_1 + pos_err_1, 0.0f)) ;
    }
    return;
}

[[kernel]] void impactor_integrate(uint3 group_8 [[threadgroup_position_in_grid]], uint3 thread_8 [[thread_position_in_threadgroup]], Params_0 constant* params_11 [[buffer(0)]], Island_natural_0 device* islands_11 [[buffer(9)]], uint device* index_11 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_11 [[buffer(3)]], packed_float4 device* state_13 [[buffer(6)]], packed_float4 device* scratch_11 [[buffer(8)]], packed_float4 device* contact_state_11 [[buffer(11)]], packed_float4 device* loads_11 [[buffer(5)]], Impactor_natural_0 device* impactors_11 [[buffer(10)]], BondStatic_natural_0 device* bonds_11 [[buffer(2)]], MaterialTable_0 constant* materials_11 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_11 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_88;
    (&kernelContext_88)->params_0 = params_11;
    (&kernelContext_88)->islands_0 = islands_11;
    (&kernelContext_88)->index_0 = index_11;
    (&kernelContext_88)->chunks_0 = chunks_11;
    (&kernelContext_88)->state_0 = state_13;
    (&kernelContext_88)->scratch_0 = scratch_11;
    (&kernelContext_88)->contact_state_0 = contact_state_11;
    (&kernelContext_88)->loads_0 = loads_11;
    (&kernelContext_88)->impactors_0 = impactors_11;
    (&kernelContext_88)->bonds_0 = bonds_11;
    (&kernelContext_88)->materials_0 = materials_11;
    (&kernelContext_88)->bond_dyn_0 = bond_dyn_11;
    threadgroup array<float4, int(32)> g_part_a_11;
    (&kernelContext_88)->g_part_a_0 = &g_part_a_11;
    threadgroup array<float4, int(32)> g_part_b_11;
    (&kernelContext_88)->g_part_b_0 = &g_part_b_11;
    threadgroup array<uint, int(5)> g_seen_11;
    (&kernelContext_88)->g_seen_0 = &g_seen_11;
    threadgroup uint g_wide_run_11;
    (&kernelContext_88)->g_wide_run_0 = &g_wide_run_11;
    threadgroup uint g_halt_11;
    (&kernelContext_88)->g_halt_0 = &g_halt_11;
    threadgroup uint g_run_11;
    (&kernelContext_88)->g_run_0 = &g_run_11;
    impactor_integrate_at_0(group_8.x, thread_8.x, &kernelContext_88);
    return;
}

void ground_contact_0(uint c_39, bool account_0, float3 thread* f_15, float3 thread* t_18, KernelContext_0 thread* kernelContext_89)
{
    ChunkStatic_natural_0 device* _S1258 = kernelContext_89->chunks_0+c_39;
    WorldPoint_0 _S1259 = chunk_world_0(c_39, kernelContext_89);
    float above_0 = _S1259.hi_0.z - kernelContext_89->params_0->ground_hi_0 + (_S1259.lo_0.z - kernelContext_89->params_0->ground_lo_0) + _S1259.rel_0.z;
    if((above_0 - (float4(_S1258->half_0) ).w) > 0.0f)
    {
        return;
    }
    Box_0 _S1260 = chunk_box_0(c_39, float3(0.0f) , kernelContext_89);
    float _S1261 = kernelContext_89->params_0->ground_modulus_0;
    float _S1262 = (float4(_S1258->cmat_0) ).x;
    float3 _S1263 = float3(0.0f, 0.0f, 1.0f);
    thread Box_0 _S1264 = _S1260;
    thread Box_0 _S1265 = _S1260;
    float _S1266 = contact_stiffness_0(_S1261, &_S1264, _S1262, &_S1265, _S1263);
    thread Box_0 _S1267 = _S1260;
    uint _S1268 = sample_count_0(&_S1267);
    uint s_12 = 0U;
    uint n_8 = 0U;
    for(;;)
    {
        if(s_12 < _S1268)
        {
        }
        else
        {
            break;
        }
        thread Box_0 _S1269 = _S1260;
        float3 _S1270 = sample_point_0(&_S1269, s_12, kernelContext_89);
        if((above_0 + _S1270.z) < 0.0f)
        {
            n_8 = n_8 + 1U;
        }
        s_12 = s_12 + 1U;
    }
    if(n_8 == 0U)
    {
        return;
    }
    sentinel_mark_0(4U, kernelContext_89);
    thread float3 vc_1;
    thread float3 wc_1;
    chunk_velocity_0(c_39, &vc_1, &wc_1, kernelContext_89);
    thread float4 ledger_2 = float4(*(kernelContext_89->scratch_0+(kernelContext_89->params_0->ledger_base_0 + kernelContext_89->params_0->pair_count_0 + c_39))) ;
    s_12 = 0U;
    for(;;)
    {
        if(s_12 < _S1268)
        {
        }
        else
        {
            break;
        }
        thread Box_0 _S1271 = _S1260;
        float3 _S1272 = sample_point_0(&_S1271, s_12, kernelContext_89);
        float _S1273 = above_0 + _S1272.z;
        if(!(_S1273 < 0.0f))
        {
            s_12 = s_12 + 1U;
            continue;
        }
        thread float stored_8;
        thread float diss_6;
        float3 _S1274 = penalty_force_0(_S1266 / float(max(n_8, 5U)), (float4(_S1258->center_0) ).w, kernelContext_89->params_0->ground_friction_0, - _S1273, _S1263, vc_1 + cross(wc_1, _S1272), kernelContext_89->params_0->dt_0, n_8, &stored_8, &diss_6, kernelContext_89);
        *f_15 = *f_15 + _S1274;
        *t_18 = *t_18 + cross(_S1272, _S1274);
        thread float _S1275 = ledger_2.y;
        thread float _S1276 = ledger_2.z;
        comp_add1_0(&_S1275, &_S1276, diss_6);
        ledger_2.z = _S1276;
        ledger_2.y = _S1275;
        s_12 = s_12 + 1U;
    }
    if(account_0)
    {
        *(kernelContext_89->scratch_0+(kernelContext_89->params_0->ledger_base_0 + kernelContext_89->params_0->pair_count_0 + c_39)) = packed_float4(ledger_2) ;
    }
    return;
}

void contact_sum_at_0(uint g_2, KernelContext_0 thread* kernelContext_90)
{
    bool _S1277;
    if(g_2 >= (kernelContext_90->params_0->seg_count_0))
    {
        _S1277 = true;
    }
    else
    {
        bool _S1278 = stopped_0(kernelContext_90);
        _S1277 = _S1278;
    }
    if(_S1277)
    {
        return;
    }
    uint _S1279 = 3U * g_2;
    uint _S1280 = kernelContext_90->index_0[kernelContext_90->params_0->seg_index_0 + _S1279];
    uint begin_1 = kernelContext_90->index_0[kernelContext_90->params_0->seg_index_0 + _S1279 + 1U];
    uint _S1281 = kernelContext_90->index_0[kernelContext_90->params_0->seg_index_0 + _S1279 + 2U];
    float3 _S1282 = float3(0.0f) ;
    thread float3 f_16 = _S1282;
    thread float3 t_19 = _S1282;
    uint e_5 = begin_1;
    for(;;)
    {
        if(e_5 < _S1281)
        {
        }
        else
        {
            break;
        }
        uint entry_4 = kernelContext_90->index_0[e_5];
        if(entry_4 == 2147483648U)
        {
            ground_contact_0(_S1280, true, &f_16, &t_19, kernelContext_90);
            e_5 = e_5 + 1U;
            continue;
        }
        uint _S1283 = 2U * entry_4;
        f_16 = f_16 + (float4(*(kernelContext_90->scratch_0+(kernelContext_90->params_0->slot_base_0 + _S1283))) ).xyz;
        t_19 = t_19 + (float4(*(kernelContext_90->scratch_0+(kernelContext_90->params_0->slot_base_0 + _S1283 + 1U))) ).xyz;
        e_5 = e_5 + 1U;
    }
    uint _S1284 = 2U * g_2;
    *(kernelContext_90->scratch_0+(kernelContext_90->params_0->seg_base_0 + _S1284)) = packed_float4(float4(f_16, 0.0f)) ;
    *(kernelContext_90->scratch_0+(kernelContext_90->params_0->seg_base_0 + _S1284 + 1U)) = packed_float4(float4(t_19, 0.0f)) ;
    return;
}

[[kernel]] void contact_sums(uint3 id_2 [[thread_position_in_grid]], Params_0 constant* params_12 [[buffer(0)]], Island_natural_0 device* islands_12 [[buffer(9)]], uint device* index_12 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_12 [[buffer(3)]], packed_float4 device* state_14 [[buffer(6)]], packed_float4 device* scratch_12 [[buffer(8)]], packed_float4 device* contact_state_12 [[buffer(11)]], packed_float4 device* loads_12 [[buffer(5)]], Impactor_natural_0 device* impactors_12 [[buffer(10)]], BondStatic_natural_0 device* bonds_12 [[buffer(2)]], MaterialTable_0 constant* materials_12 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_12 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_91;
    (&kernelContext_91)->params_0 = params_12;
    (&kernelContext_91)->islands_0 = islands_12;
    (&kernelContext_91)->index_0 = index_12;
    (&kernelContext_91)->chunks_0 = chunks_12;
    (&kernelContext_91)->state_0 = state_14;
    (&kernelContext_91)->scratch_0 = scratch_12;
    (&kernelContext_91)->contact_state_0 = contact_state_12;
    (&kernelContext_91)->loads_0 = loads_12;
    (&kernelContext_91)->impactors_0 = impactors_12;
    (&kernelContext_91)->bonds_0 = bonds_12;
    (&kernelContext_91)->materials_0 = materials_12;
    (&kernelContext_91)->bond_dyn_0 = bond_dyn_12;
    threadgroup array<float4, int(32)> g_part_a_12;
    (&kernelContext_91)->g_part_a_0 = &g_part_a_12;
    threadgroup array<float4, int(32)> g_part_b_12;
    (&kernelContext_91)->g_part_b_0 = &g_part_b_12;
    threadgroup array<uint, int(5)> g_seen_12;
    (&kernelContext_91)->g_seen_0 = &g_seen_12;
    threadgroup uint g_wide_run_12;
    (&kernelContext_91)->g_wide_run_0 = &g_wide_run_12;
    threadgroup uint g_halt_12;
    (&kernelContext_91)->g_halt_0 = &g_halt_12;
    threadgroup uint g_run_12;
    (&kernelContext_91)->g_run_0 = &g_run_12;
    contact_sum_at_0(id_2.x, &kernelContext_91);
    return;
}

void chunk_update_0(uint c_40, const Island_natural_0 thread* isl_25, const Rigid_0 thread* rg_14, float dt_14, bool rml_0, uint step_0, bool contact_4, float thread* work_2, float thread* work_err_0, KernelContext_0 thread* kernelContext_92)
{
    ChunkStatic_natural_0 device* _S1285 = kernelContext_92->chunks_0+c_40;
    float3 _S1286 = float3(0.0f) ;
    uint _S1287 = kernelContext_92->index_0[c_40];
    float peak_0 = 0.0f;
    uint e_6 = _S1287;
    float3 fi_5 = _S1286;
    float3 mi_4 = _S1286;
    for(;;)
    {
        if(e_6 < (kernelContext_92->index_0)[c_40 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_5 = kernelContext_92->index_0[e_6];
        uint _S1288 = 3U * (entry_5 >> 1U);
        float4 _S1289 = float4(*(kernelContext_92->scratch_0+_S1288)) ;
        if((entry_5 & 1U) == 0U)
        {
            float3 mi_5 = mi_4 + (float4(*(kernelContext_92->scratch_0+(_S1288 + 1U))) ).xyz;
            fi_5 = fi_5 + _S1289.xyz;
            mi_4 = mi_5;
        }
        else
        {
            float3 mi_6 = mi_4 + (float4(*(kernelContext_92->scratch_0+(_S1288 + 2U))) ).xyz;
            fi_5 = fi_5 + - _S1289.xyz;
            mi_4 = mi_6;
        }
        float _S1290 = max(peak_0, _S1289.w);
        uint _S1291 = e_6 + 1U;
        peak_0 = _S1290;
        e_6 = _S1291;
    }
    uint _S1292 = 4U * c_40;
    float3 u_2 = (float4(*(kernelContext_92->state_0+_S1292)) ).xyz;
    uint _S1293 = _S1292 + 1U;
    float3 th_4 = (float4(*(kernelContext_92->state_0+_S1293)) ).xyz;
    uint _S1294 = _S1292 + 2U;
    float3 v_11 = (float4(*(kernelContext_92->state_0+_S1294)) ).xyz;
    uint _S1295 = _S1292 + 3U;
    float3 w_6 = (float4(*(kernelContext_92->state_0+_S1295)) ).xyz;
    float4 _S1296 = float4(_S1285->center_0) ;
    float mass_0 = _S1296.w;
    float3 _S1297 = _S1296.xyz;
    float3 _S1298 = (float4(isl_25->com_0) ).xyz;
    float3 _S1299 = rotate_0(&rg_14->rot_1, _S1297 + u_2 - _S1298);
    thread float3 f_load_0;
    thread float3 t_load_0;
    thread float3 rep_f_2;
    thread float3 rep_m_2;
    chunk_loads_0(c_40, c_40, &rg_14->rot_1, step_0, dt_14, contact_4, dt_14, &f_load_0, &t_load_0, &rep_f_2, &rep_m_2, kernelContext_92);
    record_chunk_load_0(c_40, f_load_0, t_load_0, kernelContext_92);
    float3 _S1300 = float3(mass_0) ;
    float3 f_world_0 = f_load_0 + kernelContext_92->params_0->gravity_0.xyz * _S1300;
    float3 t_world_0 = t_load_0;
    float3 f_world_1;
    float3 t_world_1;
    if(rml_0)
    {
        float3 f_world_2 = f_world_0 - (rg_14->a_10 + cross(rg_14->alpha_0, _S1299) + cross(rg_14->w_5, cross(rg_14->w_5, _S1299))) * _S1300;
        float4 _S1301 = float4(_S1285->inertia0_1) ;
        float4 _S1302 = float4(_S1285->inertia1_1) ;
        float4 _S1303 = float4(_S1285->inertia2_1) ;
        float3 _S1304 = world_mul_0(&rg_14->rot_1, _S1301, _S1302, _S1303, rg_14->alpha_0);
        float3 _S1305 = world_mul_0(&rg_14->rot_1, _S1301, _S1302, _S1303, rg_14->w_5);
        float3 t_world_2 = t_world_0 - (_S1304 + cross(rg_14->w_5, _S1305));
        f_world_1 = f_world_2;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    float3 _S1306 = inverse_rotate_0(&rg_14->rot_1, f_world_1);
    float3 _S1307 = inverse_rotate_0(&rg_14->rot_1, t_world_1);
    float3 f_ext_0;
    float3 m_ext_0;
    if(rml_0)
    {
        float3 _S1308 = inverse_rotate_0(&rg_14->rot_1, rg_14->w_5);
        float4 _S1309 = float4(_S1285->inertia0_1) ;
        float4 _S1310 = float4(_S1285->inertia1_1) ;
        float4 _S1311 = float4(_S1285->inertia2_1) ;
        float3 i_w_0 = rows_mul_0(_S1309, _S1310, _S1311, w_6);
        float3 m_ext_1 = _S1307 - (cross(_S1308, i_w_0) + cross(w_6, rows_mul_0(_S1309, _S1310, _S1311, _S1308)) + cross(w_6, i_w_0));
        f_ext_0 = _S1306 - cross(_S1308, v_11) * float3((2.0f * mass_0)) ;
        m_ext_0 = m_ext_1;
    }
    else
    {
        f_ext_0 = _S1306;
        m_ext_0 = _S1307;
    }
    float3 f_17 = f_ext_0 + rep_f_2 + fi_5;
    float3 m_7 = m_ext_0 + rep_m_2 + mi_4;
    uint support_1 = (uint4(_S1285->info_1) ).x;
    float3 _S1312 = float3((float4(*(kernelContext_92->state_0+_S1293)) ).w, (float4(*(kernelContext_92->state_0+_S1294)) ).w, (float4(*(kernelContext_92->state_0+_S1295)) ).w);
    float3 reaction_1;
    float3 u_3;
    float3 th_5;
    float3 v_12;
    float3 w_7;
    if(support_1 == 1U)
    {
        reaction_1 = - f_17;
        u_3 = u_2;
        th_5 = th_4;
        v_12 = _S1286;
        w_7 = _S1286;
    }
    else
    {
        float4 _S1313 = float4(_S1285->scale_0) ;
        float3 w_8 = w_6 + rows_mul_0(float4(_S1285->inv0_1) , float4(_S1285->inv1_1) , float4(_S1285->inv2_1) , m_7) * float3((dt_14 * _S1313.z)) ;
        float3 _S1314 = float3(dt_14) ;
        float3 th_6 = th_4 + w_8 * _S1314;
        if(support_1 == 2U)
        {
            reaction_1 = - f_17;
            u_3 = u_2;
            th_5 = _S1286;
        }
        else
        {
            float3 v_13 = v_11 + f_17 * float3((dt_14 * _S1313.y)) ;
            float3 u_4 = u_2 + v_13 * _S1314;
            reaction_1 = _S1312;
            u_3 = u_4;
            th_5 = v_13;
        }
        float3 _S1315 = th_5;
        th_5 = th_6;
        v_12 = _S1315;
        w_7 = w_8;
    }
    *(kernelContext_92->state_0+_S1292) = packed_float4(float4(u_3, peak_0)) ;
    *(kernelContext_92->state_0+_S1293) = packed_float4(float4(th_5, reaction_1.x)) ;
    *(kernelContext_92->state_0+_S1294) = packed_float4(float4(v_12, reaction_1.y)) ;
    *(kernelContext_92->state_0+_S1295) = packed_float4(float4(w_7, reaction_1.z)) ;
    float3 _S1316 = rotate_0(&rg_14->rot_1, _S1297 + u_3 - _S1298);
    float3 _S1317 = rg_14->vel_0 + rg_14->vel_err_0 + cross(rg_14->w_5, _S1316);
    float3 _S1318 = rotate_0(&rg_14->rot_1, v_12);
    float3 v_world_0 = _S1317 + _S1318;
    float3 _S1319 = rotate_0(&rg_14->rot_1, w_7);
    comp_add1_0(work_2, work_err_0, (dot(f_load_0, v_world_0) + dot(t_load_0, rg_14->w_5 + _S1319)) * dt_14);
    return;
}

void chunk_update_1(uint c_41, const Island_0 thread* isl_26, const Rigid_0 thread* rg_15, float dt_15, bool rml_1, uint step_1, bool contact_5, float thread* work_3, float thread* work_err_1, KernelContext_0 thread* kernelContext_93)
{
    ChunkStatic_natural_0 device* _S1320 = kernelContext_93->chunks_0+c_41;
    float3 _S1321 = float3(0.0f) ;
    uint _S1322 = kernelContext_93->index_0[c_41];
    float peak_1 = 0.0f;
    uint e_7 = _S1322;
    float3 fi_6 = _S1321;
    float3 mi_7 = _S1321;
    for(;;)
    {
        if(e_7 < (kernelContext_93->index_0)[c_41 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_6 = kernelContext_93->index_0[e_7];
        uint _S1323 = 3U * (entry_6 >> 1U);
        float4 _S1324 = float4(*(kernelContext_93->scratch_0+_S1323)) ;
        if((entry_6 & 1U) == 0U)
        {
            float3 mi_8 = mi_7 + (float4(*(kernelContext_93->scratch_0+(_S1323 + 1U))) ).xyz;
            fi_6 = fi_6 + _S1324.xyz;
            mi_7 = mi_8;
        }
        else
        {
            float3 mi_9 = mi_7 + (float4(*(kernelContext_93->scratch_0+(_S1323 + 2U))) ).xyz;
            fi_6 = fi_6 + - _S1324.xyz;
            mi_7 = mi_9;
        }
        float _S1325 = max(peak_1, _S1324.w);
        uint _S1326 = e_7 + 1U;
        peak_1 = _S1325;
        e_7 = _S1326;
    }
    uint _S1327 = 4U * c_41;
    float3 u_5 = (float4(*(kernelContext_93->state_0+_S1327)) ).xyz;
    uint _S1328 = _S1327 + 1U;
    float3 th_7 = (float4(*(kernelContext_93->state_0+_S1328)) ).xyz;
    uint _S1329 = _S1327 + 2U;
    float3 v_14 = (float4(*(kernelContext_93->state_0+_S1329)) ).xyz;
    uint _S1330 = _S1327 + 3U;
    float3 w_9 = (float4(*(kernelContext_93->state_0+_S1330)) ).xyz;
    float4 _S1331 = float4(_S1320->center_0) ;
    float mass_1 = _S1331.w;
    float3 _S1332 = _S1331.xyz;
    float3 _S1333 = isl_26->com_0.xyz;
    float3 _S1334 = rotate_0(&rg_15->rot_1, _S1332 + u_5 - _S1333);
    thread float3 f_load_1;
    thread float3 t_load_1;
    thread float3 rep_f_3;
    thread float3 rep_m_3;
    chunk_loads_0(c_41, c_41, &rg_15->rot_1, step_1, dt_15, contact_5, dt_15, &f_load_1, &t_load_1, &rep_f_3, &rep_m_3, kernelContext_93);
    record_chunk_load_0(c_41, f_load_1, t_load_1, kernelContext_93);
    float3 _S1335 = float3(mass_1) ;
    float3 f_world_3 = f_load_1 + kernelContext_93->params_0->gravity_0.xyz * _S1335;
    float3 t_world_3 = t_load_1;
    float3 f_world_4;
    float3 t_world_4;
    if(rml_1)
    {
        float3 f_world_5 = f_world_3 - (rg_15->a_10 + cross(rg_15->alpha_0, _S1334) + cross(rg_15->w_5, cross(rg_15->w_5, _S1334))) * _S1335;
        float4 _S1336 = float4(_S1320->inertia0_1) ;
        float4 _S1337 = float4(_S1320->inertia1_1) ;
        float4 _S1338 = float4(_S1320->inertia2_1) ;
        float3 _S1339 = world_mul_0(&rg_15->rot_1, _S1336, _S1337, _S1338, rg_15->alpha_0);
        float3 _S1340 = world_mul_0(&rg_15->rot_1, _S1336, _S1337, _S1338, rg_15->w_5);
        float3 t_world_5 = t_world_3 - (_S1339 + cross(rg_15->w_5, _S1340));
        f_world_4 = f_world_5;
        t_world_4 = t_world_5;
    }
    else
    {
        f_world_4 = f_world_3;
        t_world_4 = t_world_3;
    }
    float3 _S1341 = inverse_rotate_0(&rg_15->rot_1, f_world_4);
    float3 _S1342 = inverse_rotate_0(&rg_15->rot_1, t_world_4);
    float3 f_ext_1;
    float3 m_ext_2;
    if(rml_1)
    {
        float3 _S1343 = inverse_rotate_0(&rg_15->rot_1, rg_15->w_5);
        float4 _S1344 = float4(_S1320->inertia0_1) ;
        float4 _S1345 = float4(_S1320->inertia1_1) ;
        float4 _S1346 = float4(_S1320->inertia2_1) ;
        float3 i_w_1 = rows_mul_0(_S1344, _S1345, _S1346, w_9);
        float3 m_ext_3 = _S1342 - (cross(_S1343, i_w_1) + cross(w_9, rows_mul_0(_S1344, _S1345, _S1346, _S1343)) + cross(w_9, i_w_1));
        f_ext_1 = _S1341 - cross(_S1343, v_14) * float3((2.0f * mass_1)) ;
        m_ext_2 = m_ext_3;
    }
    else
    {
        f_ext_1 = _S1341;
        m_ext_2 = _S1342;
    }
    float3 f_18 = f_ext_1 + rep_f_3 + fi_6;
    float3 m_8 = m_ext_2 + rep_m_3 + mi_7;
    uint support_2 = (uint4(_S1320->info_1) ).x;
    float3 _S1347 = float3((float4(*(kernelContext_93->state_0+_S1328)) ).w, (float4(*(kernelContext_93->state_0+_S1329)) ).w, (float4(*(kernelContext_93->state_0+_S1330)) ).w);
    float3 reaction_2;
    float3 u_6;
    float3 th_8;
    float3 v_15;
    float3 w_10;
    if(support_2 == 1U)
    {
        reaction_2 = - f_18;
        u_6 = u_5;
        th_8 = th_7;
        v_15 = _S1321;
        w_10 = _S1321;
    }
    else
    {
        float4 _S1348 = float4(_S1320->scale_0) ;
        float3 w_11 = w_9 + rows_mul_0(float4(_S1320->inv0_1) , float4(_S1320->inv1_1) , float4(_S1320->inv2_1) , m_8) * float3((dt_15 * _S1348.z)) ;
        float3 _S1349 = float3(dt_15) ;
        float3 th_9 = th_7 + w_11 * _S1349;
        if(support_2 == 2U)
        {
            reaction_2 = - f_18;
            u_6 = u_5;
            th_8 = _S1321;
        }
        else
        {
            float3 v_16 = v_14 + f_18 * float3((dt_15 * _S1348.y)) ;
            float3 u_7 = u_5 + v_16 * _S1349;
            reaction_2 = _S1347;
            u_6 = u_7;
            th_8 = v_16;
        }
        float3 _S1350 = th_8;
        th_8 = th_9;
        v_15 = _S1350;
        w_10 = w_11;
    }
    *(kernelContext_93->state_0+_S1327) = packed_float4(float4(u_6, peak_1)) ;
    *(kernelContext_93->state_0+_S1328) = packed_float4(float4(th_8, reaction_2.x)) ;
    *(kernelContext_93->state_0+_S1329) = packed_float4(float4(v_15, reaction_2.y)) ;
    *(kernelContext_93->state_0+_S1330) = packed_float4(float4(w_10, reaction_2.z)) ;
    float3 _S1351 = rotate_0(&rg_15->rot_1, _S1332 + u_6 - _S1333);
    float3 _S1352 = rg_15->vel_0 + rg_15->vel_err_0 + cross(rg_15->w_5, _S1351);
    float3 _S1353 = rotate_0(&rg_15->rot_1, v_15);
    float3 v_world_1 = _S1352 + _S1353;
    float3 _S1354 = rotate_0(&rg_15->rot_1, w_10);
    comp_add1_0(work_3, work_err_1, (dot(f_load_1, v_world_1) + dot(t_load_1, rg_15->w_5 + _S1354)) * dt_15);
    return;
}

void drift_moments_0(uint c_42, float3 thread* tu_2, float3 thread* pv_2, KernelContext_0 thread* kernelContext_94)
{
    ChunkStatic_natural_0 device* _S1355 = kernelContext_94->chunks_0+c_42;
    uint _S1356 = 4U * c_42;
    float3 _S1357 = float3(((float4(_S1355->center_0) ).w * (float4(_S1355->scale_0) ).x)) ;
    *tu_2 = *tu_2 + (float4(*(kernelContext_94->state_0+_S1356)) ).xyz * _S1357;
    *pv_2 = *pv_2 + (float4(*(kernelContext_94->state_0+(_S1356 + 2U))) ).xyz * _S1357;
    return;
}

void island_frame_at_0(uint gi_0, uint tid_19, KernelContext_0 thread* kernelContext_95)
{
    bool woke_0;
    Island_natural_0 device* _S1358 = kernelContext_95->islands_0+gi_0;
    uint4 _S1359 = uint4((*_S1358).info_0) ;
    float4 _S1360 = float4((*_S1358).com_0) ;
    float4 _S1361 = float4((*_S1358).inertia0_0) ;
    float4 _S1362 = float4((*_S1358).inertia1_0) ;
    float4 _S1363 = float4((*_S1358).inertia2_0) ;
    float4 _S1364 = float4((*_S1358).inv0_0) ;
    float4 _S1365 = float4((*_S1358).inv1_0) ;
    float4 _S1366 = float4((*_S1358).inv2_0) ;
    float4 _S1367 = float4((*_S1358).wcom_0) ;
    float4 _S1368 = float4((*_S1358).winv0_0) ;
    float4 _S1369 = float4((*_S1358).winv1_0) ;
    float4 _S1370 = float4((*_S1358).winv2_0) ;
    float4 _S1371 = float4((*_S1358).rotation_0) ;
    float4 _S1372 = float4((*_S1358).position_0) ;
    float4 _S1373 = float4((*_S1358).position_err_0) ;
    float4 _S1374 = float4((*_S1358).velocity_0) ;
    float4 _S1375 = float4((*_S1358).velocity_err_0) ;
    float4 _S1376 = float4((*_S1358).angular_velocity_0) ;
    uint4 _S1377 = uint4((*_S1358).probes_0) ;
    float4 _S1378 = float4((*_S1358).energy_0) ;
    float4 _S1379 = float4((*_S1358).rotation_err_0) ;
    float4 _S1380 = float4((*_S1358).momentum_0) ;
    float4 _S1381 = float4((*_S1358).momentum_err_0) ;
    thread Island_0 isl_27;
    (&isl_27)->range_0 = uint4((*_S1358).range_0) ;
    (&isl_27)->info_0 = _S1359;
    (&isl_27)->com_0 = _S1360;
    (&isl_27)->inertia0_0 = _S1361;
    (&isl_27)->inertia1_0 = _S1362;
    (&isl_27)->inertia2_0 = _S1363;
    (&isl_27)->inv0_0 = _S1364;
    (&isl_27)->inv1_0 = _S1365;
    (&isl_27)->inv2_0 = _S1366;
    (&isl_27)->wcom_0 = _S1367;
    (&isl_27)->winv0_0 = _S1368;
    (&isl_27)->winv1_0 = _S1369;
    (&isl_27)->winv2_0 = _S1370;
    (&isl_27)->rotation_0 = _S1371;
    (&isl_27)->position_0 = _S1372;
    (&isl_27)->position_err_0 = _S1373;
    (&isl_27)->velocity_0 = _S1374;
    (&isl_27)->velocity_err_0 = _S1375;
    (&isl_27)->angular_velocity_0 = _S1376;
    (&isl_27)->done_0 = (*_S1358).done_0;
    (&isl_27)->coverage_0 = (*_S1358).coverage_0;
    (&isl_27)->wide_groups_0 = (*_S1358).wide_groups_0;
    (&isl_27)->done_pad_0 = (*_S1358).done_pad_0;
    (&isl_27)->probes_0 = _S1377;
    (&isl_27)->energy_0 = _S1378;
    (&isl_27)->rotation_err_0 = _S1379;
    (&isl_27)->momentum_0 = _S1380;
    (&isl_27)->momentum_err_0 = _S1381;
    bool driven_0 = (((&isl_27)->info_0.x) & 2U) != 0U;
    bool _S1382 = !((((&isl_27)->info_0.x) & 1U) != 0U);
    bool _S1383;
    if(_S1382)
    {
        _S1383 = !driven_0;
    }
    else
    {
        _S1383 = false;
    }
    bool contact_island_0 = (((&isl_27)->info_0.x) & 4U) != 0U;
    bool _S1384 = (((&isl_27)->info_0.x) & 16U) != 0U;
    seen_clear_0(tid_19, kernelContext_95);
    bool _S1385 = tid_19 == 0U;
    bool settled_0;
    uint cov_2;
    if(_S1385)
    {
        if(contact_island_0 != ((kernelContext_95->params_0->contact_mode_0) == 1U))
        {
            settled_0 = true;
        }
        else
        {
            settled_0 = (((&isl_27)->info_0.x) & 8U) != 0U;
        }
        if(settled_0)
        {
            cov_2 = 0U;
        }
        else
        {
            cov_2 = 1U;
        }
        if(contact_island_0)
        {
            thread Island_0 _S1386 = isl_27;
            bool _S1387 = contact_stopped_1(&_S1386, kernelContext_95);
            settled_0 = _S1387;
        }
        else
        {
            settled_0 = false;
        }
        if(settled_0)
        {
            cov_2 = 0U;
        }
        *kernelContext_95->g_run_0 = cov_2;
        *kernelContext_95->g_halt_0 = 0U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    if((((&isl_27)->info_0.z) & 1U) != 0U)
    {
        settled_0 = true;
    }
    else
    {
        settled_0 = (*kernelContext_95->g_run_0) == 0U;
    }
    if(settled_0)
    {
        cov_2 = 0U;
    }
    else
    {
        cov_2 = min((&isl_27)->info_0.y, kernelContext_95->params_0->max_steps_0);
    }
    float _S1388 = kernelContext_95->params_0->dt_0;
    bool _S1389 = (kernelContext_95->params_0->fracture_0) != 0U;
    bool _S1390 = (kernelContext_95->params_0->rigid_motion_loads_0) != 0U;
    thread Island_0 _S1391 = isl_27;
    Rigid_0 _S1392 = rigid_of_1(&_S1391);
    thread Rigid_0 rg_16 = _S1392;
    thread float work_4 = 0.0f;
    thread float work_err_2 = 0.0f;
    settled_0 = _S1384;
    uint done_1 = 0U;
    bool woke_1 = false;
    for(;;)
    {
        if(done_1 < cov_2)
        {
        }
        else
        {
            woke_0 = woke_1;
            break;
        }
        uint abs_step_1 = (&isl_27)->info_0.w + done_1 + 1U;
        uint k_24 = abs_step_1 - 1U - kernelContext_95->params_0->step_start_0;
        bool quiet_0 = (((&isl_27)->info_0.x) & 32U) != 0U;
        bool _S1393;
        if(settled_0)
        {
            _S1393 = !quiet_0;
        }
        else
        {
            _S1393 = false;
        }
        bool _S1394;
        bool explicit_step_0;
        uint c_43;
        if(_S1393)
        {
            float3 _S1395 = float3(0.0f) ;
            thread float3 norm_1 = _S1395;
            thread float3 unused0_0 = _S1395;
            c_43 = (&isl_27)->range_0.x + tid_19;
            for(;;)
            {
                if(c_43 < ((&isl_27)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                thread Quat_0 _S1396 = (&rg_16)->rot_1;
                float _S1397 = settled_chunk_load_0(c_43, &_S1396, k_24, _S1388, contact_island_0, kernelContext_95);
                norm_1.x = norm_1.x + _S1397;
                c_43 = c_43 + 256U;
            }
            group_sum3_0(tid_19, &norm_1, &unused0_0, kernelContext_95);
            if((kernelContext_95->params_0->solve_mode_0) == 1U)
            {
                _S1394 = (abs(norm_1.x - (&isl_27)->energy_0.z)) > ((&isl_27)->energy_0.w);
            }
            else
            {
                _S1394 = false;
            }
            if(_S1394)
            {
                explicit_step_0 = false;
                woke_0 = true;
            }
            else
            {
                explicit_step_0 = settled_0;
                woke_0 = woke_1;
            }
            settled_0 = explicit_step_0;
        }
        else
        {
            woke_0 = woke_1;
        }
        if(_S1382)
        {
            _S1394 = !quiet_0;
        }
        else
        {
            _S1394 = false;
        }
        if(_S1394)
        {
            float3 _S1398 = float3(0.0f) ;
            thread float3 f_19 = _S1398;
            thread float3 t_20 = _S1398;
            c_43 = (&isl_27)->range_0.x + tid_19;
            for(;;)
            {
                if(c_43 < ((&isl_27)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                thread Island_0 _S1399 = isl_27;
                thread Rigid_0 _S1400 = rg_16;
                net_load_1(c_43, &_S1399, &_S1400, k_24, _S1388, contact_island_0, &f_19, &t_20, kernelContext_95);
                c_43 = c_43 + 256U;
            }
            group_sum3_0(tid_19, &f_19, &t_20, kernelContext_95);
            thread Island_0 _S1401 = isl_27;
            rigid_acceleration_1(&_S1401, &rg_16, f_19, t_20);
        }
        if(!settled_0)
        {
            explicit_step_0 = !quiet_0;
        }
        else
        {
            explicit_step_0 = false;
        }
        uint c_44;
        if(explicit_step_0)
        {
            c_43 = (&isl_27)->range_0.z + tid_19;
            for(;;)
            {
                if(c_43 < ((&isl_27)->range_0.w))
                {
                }
                else
                {
                    break;
                }
                bool _S1402 = bond_update_0(c_43, _S1388, _S1389, abs_step_1, false, kernelContext_95);
                if(_S1402)
                {
                    *kernelContext_95->g_halt_0 = 1U;
                }
                c_43 = c_43 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            c_44 = (&isl_27)->range_0.x + tid_19;
            for(;;)
            {
                if(c_44 < ((&isl_27)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                thread Island_0 _S1403 = isl_27;
                thread Rigid_0 _S1404 = rg_16;
                chunk_update_1(c_44, &_S1403, &_S1404, _S1388, _S1390, k_24, contact_island_0, &work_4, &work_err_2, kernelContext_95);
                c_44 = c_44 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        }
        bool _S1405;
        if(_S1383)
        {
            _S1405 = !quiet_0;
        }
        else
        {
            _S1405 = false;
        }
        if(_S1405)
        {
            thread Island_0 _S1406 = isl_27;
            integrate_rigid_1(&_S1406, &rg_16, _S1388);
        }
        bool _S1407;
        if(_S1382)
        {
            _S1407 = explicit_step_0;
        }
        else
        {
            _S1407 = false;
        }
        if(_S1407)
        {
            float3 _S1408 = (&isl_27)->wcom_0.xyz;
            float3 _S1409 = float3(0.0f) ;
            thread float3 tu_3 = _S1409;
            thread float3 pv_3 = _S1409;
            c_43 = (&isl_27)->range_0.x + tid_19;
            for(;;)
            {
                if(c_43 < ((&isl_27)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_moments_0(c_43, &tu_3, &pv_3, kernelContext_95);
                c_43 = c_43 + 256U;
            }
            group_sum3_0(tid_19, &tu_3, &pv_3, kernelContext_95);
            float3 tr_6 = tu_3 / float3((&isl_27)->wcom_0.w) ;
            float3 dv_6 = pv_3 / float3((&isl_27)->wcom_0.w) ;
            thread float3 lu_3 = _S1409;
            thread float3 lv_3 = _S1409;
            c_44 = (&isl_27)->range_0.x + tid_19;
            for(;;)
            {
                if(c_44 < ((&isl_27)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_angular_0(c_44, _S1408, tr_6, dv_6, &lu_3, &lv_3, kernelContext_95);
                c_44 = c_44 + 256U;
            }
            group_sum3_0(tid_19, &lu_3, &lv_3, kernelContext_95);
            float3 phi_5 = rows_mul_0((&isl_27)->winv0_0, (&isl_27)->winv1_0, (&isl_27)->winv2_0, lu_3);
            float3 dw_4 = rows_mul_0((&isl_27)->winv0_0, (&isl_27)->winv1_0, (&isl_27)->winv2_0, lv_3);
            uint c_45 = (&isl_27)->range_0.x + tid_19;
            for(;;)
            {
                if(c_45 < ((&isl_27)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_apply_0(c_45, _S1408, tr_6, phi_5, dv_6, dw_4, kernelContext_95);
                c_45 = c_45 + 256U;
            }
            if(!driven_0)
            {
                thread Island_0 _S1410 = isl_27;
                drift_rigid_1(&_S1410, &rg_16, tr_6, phi_5, dv_6, dw_4);
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        }
        bool _S1411;
        if(_S1385)
        {
            _S1411 = ((&isl_27)->probes_0.y) > ((&isl_27)->probes_0.x);
        }
        else
        {
            _S1411 = false;
        }
        if(_S1411)
        {
            thread Island_0 _S1412 = isl_27;
            thread Rigid_0 _S1413 = rg_16;
            record_probes_0(&_S1412, &_S1413, k_24, kernelContext_95);
        }
        uint _S1414 = done_1 + 1U;
        if((*kernelContext_95->g_halt_0) != 0U)
        {
            done_1 = _S1414;
            break;
        }
        done_1 = _S1414;
        woke_1 = woke_0;
    }
    thread float3 wsum_0 = float3(work_4, work_err_2, 0.0f);
    thread float3 unused_3 = float3(0.0f) ;
    group_sum3_0(tid_19, &wsum_0, &unused_3, kernelContext_95);
    if(_S1385)
    {
        thread Quat_0 _S1415 = (&rg_16)->rot_1;
        float4 _S1416 = quat_vec_0(&_S1415);
        (&isl_27)->rotation_0 = _S1416;
        (&isl_27)->rotation_err_0 = (&rg_16)->rot_err_0;
        (&isl_27)->position_0 = float4((&rg_16)->pos_0, 0.0f);
        (&isl_27)->position_err_0 = float4((&rg_16)->pos_err_0, 0.0f);
        (&isl_27)->velocity_0 = float4((&rg_16)->vel_0, 0.0f);
        (&isl_27)->velocity_err_0 = float4((&rg_16)->vel_err_0, 0.0f);
        (&isl_27)->angular_velocity_0 = float4((&rg_16)->w_5, 0.0f);
        (&isl_27)->momentum_0 = float4((&rg_16)->l_1, 0.0f);
        (&isl_27)->momentum_err_0 = float4((&rg_16)->l_err_0, 0.0f);
        (&isl_27)->done_0 = done_1;
        (&isl_27)->info_0.y = (&isl_27)->info_0.y - done_1;
        if((*kernelContext_95->g_halt_0) != 0U)
        {
            _S1383 = contact_island_0;
        }
        else
        {
            _S1383 = false;
        }
        if(_S1383)
        {
            contact_split_at_0((&isl_27)->info_0.w + done_1, kernelContext_95);
        }
        float _S1417 = wsum_0.x;
        thread float _S1418 = (&isl_27)->energy_0.x;
        thread float _S1419 = (&isl_27)->energy_0.y;
        comp_add1_0(&_S1418, &_S1419, _S1417);
        (&isl_27)->energy_0.x = _S1418;
        (&isl_27)->energy_0.y = _S1419 + wsum_0.y;
        (&isl_27)->info_0.w = (&isl_27)->info_0.w + done_1;
        if((*kernelContext_95->g_halt_0) != 0U)
        {
            (&isl_27)->info_0.z = ((&isl_27)->info_0.z) | 1U;
        }
        uint _S1420 = seen_bits_0(kernelContext_95);
        if((*kernelContext_95->g_halt_0) != 0U)
        {
            cov_2 = 128U;
        }
        else
        {
            cov_2 = 0U;
        }
        uint _S1421 = _S1420 | cov_2;
        if(woke_0)
        {
            cov_2 = 2048U;
        }
        else
        {
            cov_2 = 0U;
        }
        uint cov_3 = _S1421 | cov_2;
        if(done_1 > 0U)
        {
            bool quiet_1 = (((&isl_27)->info_0.x) & 32U) != 0U;
            if(quiet_1)
            {
                cov_2 = 4096U;
            }
            else
            {
                cov_2 = 0U;
            }
            uint cov_4 = cov_3 | cov_2;
            if((((&isl_27)->info_0.x) & 16U) != 0U)
            {
                _S1383 = !quiet_1;
            }
            else
            {
                _S1383 = false;
            }
            if(_S1383)
            {
                cov_2 = 512U;
            }
            else
            {
                cov_2 = 0U;
            }
            uint cov_5 = cov_4 | cov_2;
            if((kernelContext_95->params_0->contact_mode_0) == 1U)
            {
                cov_2 = 524288U;
            }
            else
            {
                cov_2 = 0U;
            }
            uint cov_6 = cov_5 | cov_2;
            if(((&isl_27)->probes_0.y) > ((&isl_27)->probes_0.x))
            {
                cov_2 = 262144U;
            }
            else
            {
                cov_2 = 0U;
            }
            cov_2 = cov_6 | cov_2;
        }
        else
        {
            cov_2 = cov_3;
        }
        (&isl_27)->coverage_0 = ((&isl_27)->coverage_0) | cov_2;
        if(woke_0)
        {
            (&isl_27)->info_0.x = ((&isl_27)->info_0.x) & 4294967279U;
            (&isl_27)->info_0.z = ((&isl_27)->info_0.z) | 4U;
        }
        Island_natural_0 device* _S1422 = kernelContext_95->islands_0+gi_0;
        _S1422->range_0 = packed_uint4(isl_27.range_0) ;
        _S1422->info_0 = packed_uint4(isl_27.info_0) ;
        _S1422->com_0 = packed_float4(isl_27.com_0) ;
        _S1422->inertia0_0 = packed_float4(isl_27.inertia0_0) ;
        _S1422->inertia1_0 = packed_float4(isl_27.inertia1_0) ;
        _S1422->inertia2_0 = packed_float4(isl_27.inertia2_0) ;
        _S1422->inv0_0 = packed_float4(isl_27.inv0_0) ;
        _S1422->inv1_0 = packed_float4(isl_27.inv1_0) ;
        _S1422->inv2_0 = packed_float4(isl_27.inv2_0) ;
        _S1422->wcom_0 = packed_float4(isl_27.wcom_0) ;
        _S1422->winv0_0 = packed_float4(isl_27.winv0_0) ;
        _S1422->winv1_0 = packed_float4(isl_27.winv1_0) ;
        _S1422->winv2_0 = packed_float4(isl_27.winv2_0) ;
        _S1422->rotation_0 = packed_float4(isl_27.rotation_0) ;
        _S1422->position_0 = packed_float4(isl_27.position_0) ;
        _S1422->position_err_0 = packed_float4(isl_27.position_err_0) ;
        _S1422->velocity_0 = packed_float4(isl_27.velocity_0) ;
        _S1422->velocity_err_0 = packed_float4(isl_27.velocity_err_0) ;
        _S1422->angular_velocity_0 = packed_float4(isl_27.angular_velocity_0) ;
        _S1422->done_0 = isl_27.done_0;
        _S1422->coverage_0 = isl_27.coverage_0;
        _S1422->wide_groups_0 = isl_27.wide_groups_0;
        _S1422->done_pad_0 = isl_27.done_pad_0;
        _S1422->probes_0 = packed_uint4(isl_27.probes_0) ;
        _S1422->energy_0 = packed_float4(isl_27.energy_0) ;
        _S1422->rotation_err_0 = packed_float4(isl_27.rotation_err_0) ;
        _S1422->momentum_0 = packed_float4(isl_27.momentum_0) ;
        _S1422->momentum_err_0 = packed_float4(isl_27.momentum_err_0) ;
    }
    return;
}

[[kernel]] void island_frame(uint3 group_9 [[threadgroup_position_in_grid]], uint3 thread_9 [[thread_position_in_threadgroup]], Params_0 constant* params_13 [[buffer(0)]], Island_natural_0 device* islands_13 [[buffer(9)]], uint device* index_13 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_13 [[buffer(3)]], packed_float4 device* state_15 [[buffer(6)]], packed_float4 device* scratch_13 [[buffer(8)]], packed_float4 device* contact_state_13 [[buffer(11)]], packed_float4 device* loads_13 [[buffer(5)]], Impactor_natural_0 device* impactors_13 [[buffer(10)]], BondStatic_natural_0 device* bonds_13 [[buffer(2)]], MaterialTable_0 constant* materials_13 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_13 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_96;
    (&kernelContext_96)->params_0 = params_13;
    (&kernelContext_96)->islands_0 = islands_13;
    (&kernelContext_96)->index_0 = index_13;
    (&kernelContext_96)->chunks_0 = chunks_13;
    (&kernelContext_96)->state_0 = state_15;
    (&kernelContext_96)->scratch_0 = scratch_13;
    (&kernelContext_96)->contact_state_0 = contact_state_13;
    (&kernelContext_96)->loads_0 = loads_13;
    (&kernelContext_96)->impactors_0 = impactors_13;
    (&kernelContext_96)->bonds_0 = bonds_13;
    (&kernelContext_96)->materials_0 = materials_13;
    (&kernelContext_96)->bond_dyn_0 = bond_dyn_13;
    threadgroup array<float4, int(32)> g_part_a_13;
    (&kernelContext_96)->g_part_a_0 = &g_part_a_13;
    threadgroup array<float4, int(32)> g_part_b_13;
    (&kernelContext_96)->g_part_b_0 = &g_part_b_13;
    threadgroup array<uint, int(5)> g_seen_13;
    (&kernelContext_96)->g_seen_0 = &g_seen_13;
    threadgroup uint g_wide_run_13;
    (&kernelContext_96)->g_wide_run_0 = &g_wide_run_13;
    threadgroup uint g_halt_13;
    (&kernelContext_96)->g_halt_0 = &g_halt_13;
    threadgroup uint g_run_13;
    (&kernelContext_96)->g_run_0 = &g_run_13;
    island_frame_at_0(group_9.x, thread_9.x, &kernelContext_96);
    return;
}

void wide_chunks_at_0(uint gx_0, uint tid_20, KernelContext_0 thread* kernelContext_97)
{
    WideGroup_0 _S1423 = wide_group_0(kernelContext_97->params_0->wide_chunk_table_0, gx_0, kernelContext_97);
    thread Island_natural_0 _S1424 = *(kernelContext_97->islands_0+_S1423.island_3);
    bool _S1425 = wide_enter_1(tid_20, _S1423.island_3, kernelContext_97);
    if(!_S1425)
    {
        return;
    }
    uint _S1426 = (uint4((&_S1424)->info_0) ).x;
    bool anchored_0 = (_S1426 & 1U) != 0U;
    if((_S1426 & 16U) != 0U)
    {
        if(tid_20 == 0U)
        {
            *(kernelContext_97->scratch_0+(kernelContext_97->params_0->wide_base_0 + 8U * gx_0 + 6U)) = packed_float4(float4(0.0f) ) ;
        }
        return;
    }
    thread WideGroup_0 _S1427 = _S1423;
    Rigid_0 _S1428 = wide_rigid_frame_1(tid_20, &_S1424, &_S1427, kernelContext_97);
    thread float work_5 = 0.0f;
    thread float work_err_3 = 0.0f;
    float3 _S1429 = float3(0.0f) ;
    thread float3 tu_4 = _S1429;
    thread float3 pv_4 = _S1429;
    uint c_46 = _S1423.begin_0 + tid_20;
    if(c_46 < (_S1423.end_0))
    {
        float _S1430 = kernelContext_97->params_0->dt_0;
        bool _S1431 = (kernelContext_97->params_0->rigid_motion_loads_0) != 0U;
        uint _S1432 = wide_step_1(&_S1424, kernelContext_97);
        bool _S1433 = (_S1426 & 4U) != 0U;
        thread Rigid_0 _S1434 = _S1428;
        chunk_update_0(c_46, &_S1424, &_S1434, _S1430, _S1431, _S1432, _S1433, &work_5, &work_err_3, kernelContext_97);
        if(!anchored_0)
        {
            drift_moments_0(c_46, &tu_4, &pv_4, kernelContext_97);
        }
    }
    thread float3 wsum_1 = float3(work_5, work_err_3, 0.0f);
    thread float3 unused_4 = _S1429;
    group_sum3_0(tid_20, &wsum_1, &unused_4, kernelContext_97);
    bool _S1435 = !anchored_0;
    if(_S1435)
    {
        group_sum3_0(tid_20, &tu_4, &pv_4, kernelContext_97);
    }
    if(tid_20 == 0U)
    {
        uint _S1436 = 8U * gx_0;
        *(kernelContext_97->scratch_0+(kernelContext_97->params_0->wide_base_0 + _S1436 + 6U)) = packed_float4(float4(wsum_1, 0.0f)) ;
        if(_S1435)
        {
            wide_store_0(gx_0, 2U, tu_4, pv_4, kernelContext_97);
        }
        *(kernelContext_97->scratch_0+(kernelContext_97->params_0->wide_base_0 + _S1436 + 7U)) = packed_float4(float4(float((*kernelContext_97->g_seen_0)[0U]), float((*kernelContext_97->g_seen_0)[1U]), float((*kernelContext_97->g_seen_0)[2U]), 0.0f)) ;
    }
    return;
}

[[kernel]] void wide_chunks(uint3 group_10 [[threadgroup_position_in_grid]], uint3 thread_10 [[thread_position_in_threadgroup]], Params_0 constant* params_14 [[buffer(0)]], Island_natural_0 device* islands_14 [[buffer(9)]], uint device* index_14 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_14 [[buffer(3)]], packed_float4 device* state_16 [[buffer(6)]], packed_float4 device* scratch_14 [[buffer(8)]], packed_float4 device* contact_state_14 [[buffer(11)]], packed_float4 device* loads_14 [[buffer(5)]], Impactor_natural_0 device* impactors_14 [[buffer(10)]], BondStatic_natural_0 device* bonds_14 [[buffer(2)]], MaterialTable_0 constant* materials_14 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_14 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_98;
    (&kernelContext_98)->params_0 = params_14;
    (&kernelContext_98)->islands_0 = islands_14;
    (&kernelContext_98)->index_0 = index_14;
    (&kernelContext_98)->chunks_0 = chunks_14;
    (&kernelContext_98)->state_0 = state_16;
    (&kernelContext_98)->scratch_0 = scratch_14;
    (&kernelContext_98)->contact_state_0 = contact_state_14;
    (&kernelContext_98)->loads_0 = loads_14;
    (&kernelContext_98)->impactors_0 = impactors_14;
    (&kernelContext_98)->bonds_0 = bonds_14;
    (&kernelContext_98)->materials_0 = materials_14;
    (&kernelContext_98)->bond_dyn_0 = bond_dyn_14;
    threadgroup array<float4, int(32)> g_part_a_14;
    (&kernelContext_98)->g_part_a_0 = &g_part_a_14;
    threadgroup array<float4, int(32)> g_part_b_14;
    (&kernelContext_98)->g_part_b_0 = &g_part_b_14;
    threadgroup array<uint, int(5)> g_seen_14;
    (&kernelContext_98)->g_seen_0 = &g_seen_14;
    threadgroup uint g_wide_run_14;
    (&kernelContext_98)->g_wide_run_0 = &g_wide_run_14;
    threadgroup uint g_halt_14;
    (&kernelContext_98)->g_halt_0 = &g_halt_14;
    threadgroup uint g_run_14;
    (&kernelContext_98)->g_run_0 = &g_run_14;
    wide_chunks_at_0(group_10.x, thread_10.x, &kernelContext_98);
    return;
}

[[kernel]] void sums_and_impactors(uint3 group_11 [[threadgroup_position_in_grid]], uint3 thread_11 [[thread_position_in_threadgroup]], Params_0 constant* params_15 [[buffer(0)]], Island_natural_0 device* islands_15 [[buffer(9)]], uint device* index_15 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_15 [[buffer(3)]], packed_float4 device* state_17 [[buffer(6)]], packed_float4 device* scratch_15 [[buffer(8)]], packed_float4 device* contact_state_15 [[buffer(11)]], packed_float4 device* loads_15 [[buffer(5)]], Impactor_natural_0 device* impactors_15 [[buffer(10)]], BondStatic_natural_0 device* bonds_15 [[buffer(2)]], MaterialTable_0 constant* materials_15 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_15 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_99;
    (&kernelContext_99)->params_0 = params_15;
    (&kernelContext_99)->islands_0 = islands_15;
    (&kernelContext_99)->index_0 = index_15;
    (&kernelContext_99)->chunks_0 = chunks_15;
    (&kernelContext_99)->state_0 = state_17;
    (&kernelContext_99)->scratch_0 = scratch_15;
    (&kernelContext_99)->contact_state_0 = contact_state_15;
    (&kernelContext_99)->loads_0 = loads_15;
    (&kernelContext_99)->impactors_0 = impactors_15;
    (&kernelContext_99)->bonds_0 = bonds_15;
    (&kernelContext_99)->materials_0 = materials_15;
    (&kernelContext_99)->bond_dyn_0 = bond_dyn_15;
    threadgroup array<float4, int(32)> g_part_a_15;
    (&kernelContext_99)->g_part_a_0 = &g_part_a_15;
    threadgroup array<float4, int(32)> g_part_b_15;
    (&kernelContext_99)->g_part_b_0 = &g_part_b_15;
    threadgroup array<uint, int(5)> g_seen_15;
    (&kernelContext_99)->g_seen_0 = &g_seen_15;
    threadgroup uint g_wide_run_15;
    (&kernelContext_99)->g_wide_run_0 = &g_wide_run_15;
    threadgroup uint g_halt_15;
    (&kernelContext_99)->g_halt_0 = &g_halt_15;
    threadgroup uint g_run_15;
    (&kernelContext_99)->g_run_0 = &g_run_15;
    uint sums_groups_0 = (params_15->seg_count_0 + 255U) / 256U;
    uint _S1437 = group_11.x;
    if(_S1437 < sums_groups_0)
    {
        contact_sum_at_0(_S1437 * 256U + thread_11.x, &kernelContext_99);
    }
    else
    {
        impactor_integrate_at_0(_S1437 - sums_groups_0, thread_11.x, &kernelContext_99);
    }
    return;
}

[[kernel]] void islands_and_wide_chunks(uint3 group_12 [[threadgroup_position_in_grid]], uint3 thread_12 [[thread_position_in_threadgroup]], Params_0 constant* params_16 [[buffer(0)]], Island_natural_0 device* islands_16 [[buffer(9)]], uint device* index_16 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_16 [[buffer(3)]], packed_float4 device* state_18 [[buffer(6)]], packed_float4 device* scratch_16 [[buffer(8)]], packed_float4 device* contact_state_16 [[buffer(11)]], packed_float4 device* loads_16 [[buffer(5)]], Impactor_natural_0 device* impactors_16 [[buffer(10)]], BondStatic_natural_0 device* bonds_16 [[buffer(2)]], MaterialTable_0 constant* materials_16 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_16 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_100;
    (&kernelContext_100)->params_0 = params_16;
    (&kernelContext_100)->islands_0 = islands_16;
    (&kernelContext_100)->index_0 = index_16;
    (&kernelContext_100)->chunks_0 = chunks_16;
    (&kernelContext_100)->state_0 = state_18;
    (&kernelContext_100)->scratch_0 = scratch_16;
    (&kernelContext_100)->contact_state_0 = contact_state_16;
    (&kernelContext_100)->loads_0 = loads_16;
    (&kernelContext_100)->impactors_0 = impactors_16;
    (&kernelContext_100)->bonds_0 = bonds_16;
    (&kernelContext_100)->materials_0 = materials_16;
    (&kernelContext_100)->bond_dyn_0 = bond_dyn_16;
    threadgroup array<float4, int(32)> g_part_a_16;
    (&kernelContext_100)->g_part_a_0 = &g_part_a_16;
    threadgroup array<float4, int(32)> g_part_b_16;
    (&kernelContext_100)->g_part_b_0 = &g_part_b_16;
    threadgroup array<uint, int(5)> g_seen_16;
    (&kernelContext_100)->g_seen_0 = &g_seen_16;
    threadgroup uint g_wide_run_16;
    (&kernelContext_100)->g_wide_run_0 = &g_wide_run_16;
    threadgroup uint g_halt_16;
    (&kernelContext_100)->g_halt_0 = &g_halt_16;
    threadgroup uint g_run_16;
    (&kernelContext_100)->g_run_0 = &g_run_16;
    uint _S1438 = group_12.x;
    if(_S1438 < (params_16->halt_index_0))
    {
        island_frame_at_0(_S1438, thread_12.x, &kernelContext_100);
    }
    else
    {
        wide_chunks_at_0(_S1438 - params_16->halt_index_0, thread_12.x, &kernelContext_100);
    }
    return;
}

