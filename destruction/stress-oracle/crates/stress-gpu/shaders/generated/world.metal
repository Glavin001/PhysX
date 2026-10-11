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
    uint pc_steps_0;
    uint pc_base_0;
    uint pi_base_0;
    uint bond_count_0;
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
    array<uint, int(4096)> threadgroup* g_label_0;
    uint threadgroup* g_changed_0;
    uint threadgroup* g_halt_0;
    uint threadgroup* g_run_0;
    uint threadgroup* g_flag_0;
    array<uint, int(1024)> threadgroup* g_mode_0;
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

void impactor_candidate_forces_0(uint k_6, uint lane_1, uint lanes_5, KernelContext_0 thread* kernelContext_25)
{
    uint _S242;
    bool _S243;
    uint _S244 = 3U * k_6;
    uint at_1 = kernelContext_25->params_0->cand_index_0 + _S244;
    uint c_4 = kernelContext_25->index_0[at_1];
    uint slot_0 = kernelContext_25->index_0[at_1 + 1U];
    uint _S245 = kernelContext_25->index_0[at_1 + 2U];
    thread Impactor_natural_0 _S246 = *(kernelContext_25->impactors_0+_S245);
    float _S247 = kernelContext_25->params_0->dt_0;
    float3 _S248 = float3(0.0f) ;
    thread float4 data_0 = float4(*(kernelContext_25->scratch_0+(kernelContext_25->params_0->cand_base_0 + _S244))) ;
    bool hit_0;
    float3 f_sum_0;
    float3 t_sum_0;
    float3 imp_f_0;
    float3 imp_t_0;
    if(((uint4((&_S246)->cand_0) ).z) == 0U)
    {
        WorldPoint_0 _S249 = chunk_world_0(c_4, kernelContext_25);
        WorldPoint_0 _S250 = impactor_point_0(_S245, kernelContext_25);
        thread WorldPoint_0 _S251 = _S249;
        thread WorldPoint_0 _S252 = _S250;
        float3 _S253 = world_diff_0(&_S251, &_S252);
        float4 _S254 = float4((&_S246)->half_1) ;
        if(!((length(_S253)) > (_S254.w + (float4((kernelContext_25->chunks_0+c_4)->half_0) ).w)))
        {
            Box_0 _S255 = impactor_box_1(_S245, _S248, _S254.xyz, kernelContext_25);
            Box_0 _S256 = chunk_box_0(c_4, _S253, kernelContext_25);
            float4 _S257 = float4((&_S246)->mat_0) ;
            float _S258 = _S257.x;
            float _S259 = (float4((kernelContext_25->chunks_0+c_4)->cmat_0) ).x;
            float3 _S260 = _S256.center_1 - _S255.center_1;
            thread Box_0 _S261 = _S255;
            thread Box_0 _S262 = _S256;
            float _S263 = contact_stiffness_0(_S258, &_S261, _S259, &_S262, _S260);
            float4 _S264 = float4((&_S246)->geom_0) ;
            float _S265 = _S264.y;
            thread Box_0 _S266 = _S255;
            Box_0 _S267 = impactor_shrunk_0(_S245, _S265, &_S266);
            uint j_2 = lane_1;
            uint n_7 = 0U;
            for(;;)
            {
                thread Box_0 _S268 = _S256;
                uint _S269 = impactor_slots_0(&_S246, &_S268);
                _S242 = _S269;
                if(j_2 < _S269)
                {
                }
                else
                {
                    break;
                }
                thread Box_0 _S270 = _S267;
                thread Box_0 _S271 = _S256;
                thread float3 p_7;
                thread float3 nrm_0;
                thread float dep_0;
                bool _S272 = impactor_contact_2(_S245, _S265, &_S270, &_S271, j_2, &p_7, &nrm_0, &dep_0, kernelContext_25);
                if(_S272)
                {
                    n_7 = n_7 + 1U;
                }
                j_2 = j_2 + lanes_5;
            }
            uint n_8 = pair_count_sum_0(n_7, lanes_5);
            bool _S273 = ((float4((&_S246)->shape_0) ).x) == 0.0f;
            float _S274;
            if(_S273)
            {
                _S274 = _S263;
            }
            else
            {
                _S274 = _S263 / max(float(n_8), 10.0f);
            }
            if(_S273)
            {
                j_2 = 1U;
            }
            else
            {
                j_2 = n_8;
            }
            float m_1 = (float4((kernelContext_25->chunks_0+c_4)->center_0) ).w;
            float _S275 = _S257.z;
            float _S276 = m_1 * _S275 / (m_1 + _S275);
            float _S277;
            if((kernelContext_25->params_0->pair_friction_0) >= 0.0f)
            {
                _S277 = kernelContext_25->params_0->pair_friction_0;
            }
            else
            {
                _S277 = min(_S257.y, (float4((kernelContext_25->chunks_0+c_4)->cmat_0) ).y);
            }
            float3 _S278 = (float4((&_S246)->velocity_1) ).xyz + (float4((&_S246)->velocity_err_1) ).xyz;
            thread float3 vc_0;
            thread float3 wc_0;
            chunk_velocity_0(c_4, &vc_0, &wc_0, kernelContext_25);
            hit_0 = false;
            uint j_3 = lane_1;
            f_sum_0 = _S248;
            t_sum_0 = _S248;
            imp_f_0 = _S248;
            imp_t_0 = _S248;
            float diss_sum_2 = 0.0f;
            for(;;)
            {
                bool _S279 = n_8 > 0U;
                _S243 = _S279;
                bool _S280;
                if(_S279)
                {
                    _S280 = j_3 < _S242;
                }
                else
                {
                    _S280 = false;
                }
                if(_S280)
                {
                }
                else
                {
                    break;
                }
                thread Box_0 _S281 = _S267;
                thread Box_0 _S282 = _S256;
                thread float3 p_8;
                thread float3 nrm_1;
                thread float dep_1;
                bool _S283 = impactor_contact_0(&_S246, _S265, &_S281, &_S282, j_3, &p_8, &nrm_1, &dep_1, kernelContext_25);
                if(!_S283)
                {
                    j_3 = j_3 + lanes_5;
                    continue;
                }
                thread float stored_2;
                thread float diss_1;
                float3 _S284 = penalty_force_0(_S274, _S276, _S277, dep_1 * _S264.x, nrm_1, vc_0 + cross(wc_0, p_8 - _S256.center_1) - (_S278 + cross((float4((&_S246)->angular_velocity_1) ).xyz, p_8)), _S247, j_2, &stored_2, &diss_1, kernelContext_25);
                float3 f_sum_1 = f_sum_0 + _S284;
                float3 t_sum_1 = t_sum_0 + cross(p_8 - _S256.center_1, _S284);
                float3 imp_f_1 = imp_f_0 - _S284;
                float3 imp_t_1 = imp_t_0 - cross(p_8, _S284);
                float diss_sum_3 = diss_sum_2 + diss_1;
                hit_0 = true;
                f_sum_0 = f_sum_1;
                t_sum_0 = t_sum_1;
                imp_f_0 = imp_f_1;
                imp_t_0 = imp_t_1;
                diss_sum_2 = diss_sum_3;
                j_3 = j_3 + lanes_5;
            }
            float3 _S285 = pair_sum3_0(f_sum_0, lanes_5);
            float3 _S286 = pair_sum3_0(t_sum_0, lanes_5);
            float3 _S287 = pair_sum3_0(imp_f_0, lanes_5);
            float3 _S288 = pair_sum3_0(imp_t_0, lanes_5);
            float diss_sum_4 = pair_sum_0(diss_sum_2, lanes_5);
            bool _S289 = pair_any_0(hit_0, lanes_5);
            if(_S243)
            {
                thread float _S290 = data_0.z;
                thread float _S291 = data_0.w;
                comp_add1_0(&_S290, &_S291, diss_sum_4);
                data_0.w = _S291;
                data_0.z = _S290;
            }
            hit_0 = _S289;
            f_sum_0 = _S285;
            t_sum_0 = _S286;
            imp_f_0 = _S287;
            imp_t_0 = _S288;
        }
        else
        {
            hit_0 = false;
            f_sum_0 = _S248;
            t_sum_0 = _S248;
            imp_f_0 = _S248;
            imp_t_0 = _S248;
        }
    }
    else
    {
        hit_0 = false;
        f_sum_0 = _S248;
        t_sum_0 = _S248;
        imp_f_0 = _S248;
        imp_t_0 = _S248;
    }
    if(lane_1 != 0U)
    {
        return;
    }
    uint _S292 = 2U * slot_0;
    *(kernelContext_25->scratch_0+(kernelContext_25->params_0->slot_base_0 + _S292)) = packed_float4(float4(f_sum_0, 0.0f)) ;
    *(kernelContext_25->scratch_0+(kernelContext_25->params_0->slot_base_0 + _S292 + 1U)) = packed_float4(float4(t_sum_0, 0.0f)) ;
    *(kernelContext_25->scratch_0+(kernelContext_25->params_0->cand_base_0 + _S244)) = packed_float4(data_0) ;
    *(kernelContext_25->scratch_0+(kernelContext_25->params_0->cand_base_0 + _S244 + 1U)) = packed_float4(float4(imp_f_0, 0.0f)) ;
    *(kernelContext_25->scratch_0+(kernelContext_25->params_0->cand_base_0 + _S244 + 2U)) = packed_float4(float4(imp_t_0, 0.0f)) ;
    if(hit_0)
    {
        sentinel_mark_0(2U, kernelContext_25);
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

void travel_check_0(uint c_5, KernelContext_0 thread* kernelContext_26)
{
    ChunkStatic_natural_0 device* _S293 = kernelContext_26->chunks_0+c_5;
    uint4 _S294 = uint4(_S293->cinfo_0) ;
    if((_S294.z) == 0U)
    {
        return;
    }
    WorldPoint_0 _S295 = chunk_world_0(c_5, kernelContext_26);
    float4 _S296 = float4(_S293->start_hi_0) ;
    float4 _S297 = float4(_S293->start_lo_0) ;
    float3 moved_0 = _S295.hi_0 - _S296.xyz + (_S295.lo_0 - _S297.xyz) + _S295.rel_0;
    float4 _S298 = float4(_S293->start_vel_0) ;
    uint _S299 = (uint4(_S293->info_1) ).y;
    float3 _S300 = float3((kernelContext_26->params_0->t_hi_0 - _S298.w + (kernelContext_26->params_0->t_lo_0 - _S297.w) + float((uint4((kernelContext_26->islands_0+_S299)->info_0) ).w - kernelContext_26->params_0->step_start_0) * kernelContext_26->params_0->dt_0)) ;
    float3 _S301 = _S298.xyz * _S300;
    uint _S302 = _S294.w;
    float3 _S303;
    if((_S302 & 2U) != 0U)
    {
        _S303 = float3(0.5f)  * kernelContext_26->params_0->gravity_0.xyz * _S300 * _S300;
    }
    else
    {
        _S303 = float3(0.0f) ;
    }
    float travel_0 = length(moved_0 - (_S301 + _S303));
    float travel_1;
    if((_S302 & 1U) != 0U)
    {
        float3 th_1 = (float4(*(kernelContext_26->state_0+(4U * c_5 + 1U))) ).xyz;
        Quat_0 _S304 = from_axis_angle_0(th_1, length(th_1));
        thread Quat_0 _S305 = quat_of_0(float4((kernelContext_26->islands_0+_S299)->rotation_0) );
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
        (kernelContext_26->islands_0+kernelContext_26->params_0->halt_index_0)->info_0[int(2)] = ((uint4((kernelContext_26->islands_0+kernelContext_26->params_0->halt_index_0)->info_0) ).z) | 1U;
        sentinel_mark_0(1048576U, kernelContext_26);
    }
    return;
}

[[kernel]] void contact_forces(uint3 id_0 [[thread_position_in_grid]], Params_0 constant* params_1 [[buffer(0)]], Island_natural_0 device* islands_1 [[buffer(9)]], uint device* index_1 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_1 [[buffer(3)]], packed_float4 device* state_1 [[buffer(6)]], packed_float4 device* scratch_1 [[buffer(8)]], packed_float4 device* contact_state_1 [[buffer(11)]], packed_float4 device* loads_1 [[buffer(5)]], Impactor_natural_0 device* impactors_1 [[buffer(10)]], BondStatic_natural_0 device* bonds_1 [[buffer(2)]], MaterialTable_0 constant* materials_1 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_1 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_27;
    (&kernelContext_27)->params_0 = params_1;
    (&kernelContext_27)->islands_0 = islands_1;
    (&kernelContext_27)->index_0 = index_1;
    (&kernelContext_27)->chunks_0 = chunks_1;
    (&kernelContext_27)->state_0 = state_1;
    (&kernelContext_27)->scratch_0 = scratch_1;
    (&kernelContext_27)->contact_state_0 = contact_state_1;
    (&kernelContext_27)->loads_0 = loads_1;
    (&kernelContext_27)->impactors_0 = impactors_1;
    (&kernelContext_27)->bonds_0 = bonds_1;
    (&kernelContext_27)->materials_0 = materials_1;
    (&kernelContext_27)->bond_dyn_0 = bond_dyn_1;
    threadgroup array<float4, int(32)> g_part_a_1;
    (&kernelContext_27)->g_part_a_0 = &g_part_a_1;
    threadgroup array<float4, int(32)> g_part_b_1;
    (&kernelContext_27)->g_part_b_0 = &g_part_b_1;
    threadgroup array<uint, int(5)> g_seen_1;
    (&kernelContext_27)->g_seen_0 = &g_seen_1;
    threadgroup uint g_wide_run_1;
    (&kernelContext_27)->g_wide_run_0 = &g_wide_run_1;
    threadgroup array<uint, int(4096)> g_label_1;
    (&kernelContext_27)->g_label_0 = &g_label_1;
    threadgroup uint g_changed_1;
    (&kernelContext_27)->g_changed_0 = &g_changed_1;
    threadgroup uint g_halt_1;
    (&kernelContext_27)->g_halt_0 = &g_halt_1;
    threadgroup uint g_run_1;
    (&kernelContext_27)->g_run_0 = &g_run_1;
    threadgroup uint g_flag_1;
    (&kernelContext_27)->g_flag_0 = &g_flag_1;
    threadgroup array<uint, int(1024)> g_mode_1;
    (&kernelContext_27)->g_mode_0 = &g_mode_1;
    uint i_4 = id_0.x;
    uint _S312 = pair_lane_count_0(&kernelContext_27);
    uint pair_threads_0 = (&kernelContext_27)->params_0->pair_count_0 * _S312;
    if(i_4 < pair_threads_0)
    {
        bool _S313 = stopped_0(&kernelContext_27);
        bool _S314 = pair_any_0(_S313, _S312);
        if(!_S314)
        {
            uint _S315 = i_4 / _S312;
            uint _S316 = i_4 % _S312;
            pair_contact_0(_S315, _S316, _S312, &kernelContext_27);
        }
        return;
    }
    uint j_4 = i_4 - pair_threads_0;
    uint cand_threads_0 = (&kernelContext_27)->params_0->cand_count_0 * _S312;
    if(j_4 < cand_threads_0)
    {
        bool _S317 = stopped_0(&kernelContext_27);
        bool _S318 = pair_any_0(_S317, _S312);
        if(!_S318)
        {
            uint _S319 = j_4 / _S312;
            uint _S320 = j_4 % _S312;
            impactor_candidate_forces_0(_S319, _S320, _S312, &kernelContext_27);
        }
        return;
    }
    uint _S321 = j_4 - cand_threads_0;
    bool _S322;
    if(_S321 < ((&kernelContext_27)->params_0->chunk_count_0))
    {
        bool _S323 = stopped_0(&kernelContext_27);
        _S322 = !_S323;
    }
    else
    {
        _S322 = false;
    }
    if(_S322)
    {
        travel_check_0(_S321, &kernelContext_27);
    }
    return;
}

uint impactor_contact_count_0(uint _S324, float _S325, const Box_0 thread* _S326, const Box_0 thread* _S327, KernelContext_0 thread* kernelContext_28)
{
    thread Impactor_natural_0 _S328 = *(kernelContext_28->impactors_0+_S324);
    uint j_5 = 0U;
    uint count_2 = 0U;
    for(;;)
    {
        uint _S329 = impactor_slots_1(&_S328, _S327);
        if(j_5 < _S329)
        {
        }
        else
        {
            break;
        }
        thread float3 p_9;
        thread float3 n_9;
        thread float d_11;
        bool _S330 = impactor_contact_2(_S324, _S325, _S326, _S327, j_5, &p_9, &n_9, &d_11, kernelContext_28);
        if(_S330)
        {
            count_2 = count_2 + 1U;
        }
        j_5 = j_5 + 1U;
    }
    return count_2;
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
    threadgroup array<uint, int(4096)> g_label_2;
    (&kernelContext_29)->g_label_0 = &g_label_2;
    threadgroup uint g_changed_2;
    (&kernelContext_29)->g_changed_0 = &g_changed_2;
    threadgroup uint g_halt_2;
    (&kernelContext_29)->g_halt_0 = &g_halt_2;
    threadgroup uint g_run_2;
    (&kernelContext_29)->g_run_0 = &g_run_2;
    threadgroup uint g_flag_2;
    (&kernelContext_29)->g_flag_0 = &g_flag_2;
    threadgroup array<uint, int(1024)> g_mode_2;
    (&kernelContext_29)->g_mode_0 = &g_mode_2;
    uint k_7 = id_1.x;
    bool _S331;
    if(k_7 >= (params_2->cand_count_0))
    {
        _S331 = true;
    }
    else
    {
        bool _S332 = stopped_0(&kernelContext_29);
        _S331 = _S332;
    }
    if(_S331)
    {
        return;
    }
    uint _S333 = 3U * k_7;
    uint at_2 = (&kernelContext_29)->params_0->cand_index_0 + _S333;
    uint c_6 = (&kernelContext_29)->index_0[at_2];
    uint _S334 = (&kernelContext_29)->index_0[at_2 + 2U];
    thread Impactor_natural_0 _S335 = *((&kernelContext_29)->impactors_0+_S334);
    if(((uint4((&_S335)->cand_0) ).z) == 0U)
    {
        _S331 = ((float4((&_S335)->crush_0) ).x) > 0.0f;
    }
    else
    {
        _S331 = false;
    }
    float total_0;
    float ksum_0;
    if(_S331)
    {
        WorldPoint_0 _S336 = chunk_world_0(c_6, &kernelContext_29);
        WorldPoint_0 _S337 = impactor_point_0(_S334, &kernelContext_29);
        thread WorldPoint_0 _S338 = _S336;
        thread WorldPoint_0 _S339 = _S337;
        float3 _S340 = world_diff_0(&_S338, &_S339);
        float4 _S341 = float4((&_S335)->half_1) ;
        if(!((length(_S340)) > (_S341.w + (float4(((&kernelContext_29)->chunks_0+c_6)->half_0) ).w)))
        {
            Box_0 _S342 = impactor_box_1(_S334, float3(0.0f) , _S341.xyz, &kernelContext_29);
            Box_0 _S343 = chunk_box_0(c_6, _S340, &kernelContext_29);
            float _S344 = (float4((&_S335)->mat_0) ).x;
            float _S345 = (float4(((&kernelContext_29)->chunks_0+c_6)->cmat_0) ).x;
            float3 _S346 = _S343.center_1 - _S342.center_1;
            thread Box_0 _S347 = _S342;
            thread Box_0 _S348 = _S343;
            float _S349 = contact_stiffness_0(_S344, &_S347, _S345, &_S348, _S346);
            float _S350 = (float4((&_S335)->crush_0) ).w;
            thread Box_0 _S351 = _S342;
            Box_0 _S352 = impactor_shrunk_0(_S334, _S350, &_S351);
            thread Box_0 _S353 = _S352;
            thread Box_0 _S354 = _S343;
            uint _S355 = impactor_contact_count_0(_S334, _S350, &_S353, &_S354, &kernelContext_29);
            float _S356;
            if(((float4((&_S335)->shape_0) ).x) == 0.0f)
            {
                _S356 = _S349;
            }
            else
            {
                _S356 = _S349 / max(float(_S355), 10.0f);
            }
            uint j_6 = 0U;
            total_0 = 0.0f;
            ksum_0 = 0.0f;
            for(;;)
            {
                if(_S355 > 0U)
                {
                    thread Box_0 _S357 = _S343;
                    uint _S358 = impactor_slots_0(&_S335, &_S357);
                    _S331 = j_6 < _S358;
                }
                else
                {
                    _S331 = false;
                }
                if(_S331)
                {
                }
                else
                {
                    break;
                }
                thread Box_0 _S359 = _S352;
                thread Box_0 _S360 = _S343;
                thread float3 p_10;
                thread float3 nrm_2;
                thread float dep_2;
                bool _S361 = impactor_contact_1(&_S335, _S350, &_S359, &_S360, j_6, &p_10, &nrm_2, &dep_2, &kernelContext_29);
                if(!_S361)
                {
                    j_6 = j_6 + 1U;
                    continue;
                }
                float ksum_1 = ksum_0 + _S356;
                total_0 = total_0 + _S356 * dep_2;
                ksum_0 = ksum_1;
                j_6 = j_6 + 1U;
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
    float4 _S362 = float4(*((&kernelContext_29)->scratch_0+((&kernelContext_29)->params_0->cand_base_0 + _S333))) ;
    *((&kernelContext_29)->scratch_0+((&kernelContext_29)->params_0->cand_base_0 + _S333)) = packed_float4(float4(total_0, ksum_0, _S362.z, _S362.w)) ;
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
    threadgroup array<uint, int(4096)> g_label_3;
    (&kernelContext_30)->g_label_0 = &g_label_3;
    threadgroup uint g_changed_3;
    (&kernelContext_30)->g_changed_0 = &g_changed_3;
    threadgroup uint g_halt_3;
    (&kernelContext_30)->g_halt_0 = &g_halt_3;
    threadgroup uint g_run_3;
    (&kernelContext_30)->g_run_0 = &g_run_3;
    threadgroup uint g_flag_3;
    (&kernelContext_30)->g_flag_0 = &g_flag_3;
    threadgroup array<uint, int(1024)> g_mode_3;
    (&kernelContext_30)->g_mode_0 = &g_mode_3;
    uint ii_0 = group_0.x;
    uint tid_2 = thread_0.x;
    bool _S363;
    if(ii_0 >= (params_3->impactor_count_0))
    {
        _S363 = true;
    }
    else
    {
        bool _S364 = stopped_0(&kernelContext_30);
        _S363 = _S364;
    }
    if(_S363)
    {
        return;
    }
    Impactor_natural_0 device* _S365 = (&kernelContext_30)->impactors_0+ii_0;
    float4 _S366 = float4((*_S365).position_err_1) ;
    float4 _S367 = float4((*_S365).velocity_1) ;
    float4 _S368 = float4((*_S365).velocity_err_1) ;
    float4 _S369 = float4((*_S365).angular_velocity_1) ;
    float4 _S370 = float4((*_S365).rotation_1) ;
    float4 _S371 = float4((*_S365).inertia0_2) ;
    float4 _S372 = float4((*_S365).inertia1_2) ;
    float4 _S373 = float4((*_S365).inertia2_2) ;
    float4 _S374 = float4((*_S365).inv0_2) ;
    float4 _S375 = float4((*_S365).inv1_2) ;
    float4 _S376 = float4((*_S365).inv2_2) ;
    float4 _S377 = float4((*_S365).shape_0) ;
    float4 _S378 = float4((*_S365).half_1) ;
    float4 _S379 = float4((*_S365).mat_0) ;
    float4 _S380 = float4((*_S365).crush_0) ;
    float4 _S381 = float4((*_S365).geom_0) ;
    float4 _S382 = float4((*_S365).rotation_err_1) ;
    float4 _S383 = float4((*_S365).ledger_0) ;
    uint4 _S384 = uint4((*_S365).cand_0) ;
    float4 _S385 = float4((*_S365).momentum_1) ;
    float4 _S386 = float4((*_S365).momentum_err_1) ;
    thread Impactor_0 imp_5;
    (&imp_5)->position_1 = float4((*_S365).position_1) ;
    (&imp_5)->position_err_1 = _S366;
    (&imp_5)->velocity_1 = _S367;
    (&imp_5)->velocity_err_1 = _S368;
    (&imp_5)->angular_velocity_1 = _S369;
    (&imp_5)->rotation_1 = _S370;
    (&imp_5)->inertia0_2 = _S371;
    (&imp_5)->inertia1_2 = _S372;
    (&imp_5)->inertia2_2 = _S373;
    (&imp_5)->inv0_2 = _S374;
    (&imp_5)->inv1_2 = _S375;
    (&imp_5)->inv2_2 = _S376;
    (&imp_5)->shape_0 = _S377;
    (&imp_5)->half_1 = _S378;
    (&imp_5)->mat_0 = _S379;
    (&imp_5)->crush_0 = _S380;
    (&imp_5)->geom_0 = _S381;
    (&imp_5)->rotation_err_1 = _S382;
    (&imp_5)->ledger_0 = _S383;
    (&imp_5)->cand_0 = _S384;
    (&imp_5)->momentum_1 = _S385;
    (&imp_5)->momentum_err_1 = _S386;
    float4 _S387 = float4(0.0f) ;
    thread float4 shares_0 = _S387;
    thread float4 unused_0 = _S387;
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
        _S363 = true;
    }
    else
    {
        _S363 = ((&imp_5)->cand_0.z) != 0U;
    }
    if(_S363)
    {
        return;
    }
    (&imp_5)->geom_0 = float4(1.0f, (&imp_5)->crush_0.w, 0.0f, 0.0f);
    float total_1 = shares_0.x;
    if(((&imp_5)->crush_0.x) > 0.0f)
    {
        _S363 = ((&imp_5)->crush_0.z) < ((&imp_5)->crush_0.y);
    }
    else
    {
        _S363 = false;
    }
    if(_S363)
    {
        _S363 = total_1 > ((&imp_5)->crush_0.x);
    }
    else
    {
        _S363 = false;
    }
    if(_S363)
    {
        float extra_0 = (total_1 - (&imp_5)->crush_0.x) / shares_0.y;
        (&imp_5)->crush_0.w = (&imp_5)->crush_0.w + extra_0;
        (&imp_5)->crush_0.z = (&imp_5)->crush_0.z + (&imp_5)->crush_0.x * extra_0;
        float _S388 = (&imp_5)->crush_0.x * extra_0;
        thread float _S389 = (&imp_5)->ledger_0.z;
        thread float _S390 = (&imp_5)->ledger_0.w;
        comp_add1_0(&_S389, &_S390, _S388);
        (&imp_5)->ledger_0.w = _S390;
        (&imp_5)->ledger_0.z = _S389;
        float _S391 = (&imp_5)->crush_0.x * extra_0;
        thread float _S392 = (&imp_5)->ledger_0.x;
        thread float _S393 = (&imp_5)->ledger_0.y;
        comp_add1_0(&_S392, &_S393, _S391);
        (&imp_5)->ledger_0.y = _S393;
        (&imp_5)->ledger_0.x = _S392;
        (&imp_5)->geom_0.x = (&imp_5)->crush_0.x / total_1;
    }
    Impactor_natural_0 device* _S394 = (&kernelContext_30)->impactors_0+ii_0;
    _S394->position_1 = packed_float4(imp_5.position_1) ;
    _S394->position_err_1 = packed_float4(imp_5.position_err_1) ;
    _S394->velocity_1 = packed_float4(imp_5.velocity_1) ;
    _S394->velocity_err_1 = packed_float4(imp_5.velocity_err_1) ;
    _S394->angular_velocity_1 = packed_float4(imp_5.angular_velocity_1) ;
    _S394->rotation_1 = packed_float4(imp_5.rotation_1) ;
    _S394->inertia0_2 = packed_float4(imp_5.inertia0_2) ;
    _S394->inertia1_2 = packed_float4(imp_5.inertia1_2) ;
    _S394->inertia2_2 = packed_float4(imp_5.inertia2_2) ;
    _S394->inv0_2 = packed_float4(imp_5.inv0_2) ;
    _S394->inv1_2 = packed_float4(imp_5.inv1_2) ;
    _S394->inv2_2 = packed_float4(imp_5.inv2_2) ;
    _S394->shape_0 = packed_float4(imp_5.shape_0) ;
    _S394->half_1 = packed_float4(imp_5.half_1) ;
    _S394->mat_0 = packed_float4(imp_5.mat_0) ;
    _S394->crush_0 = packed_float4(imp_5.crush_0) ;
    _S394->geom_0 = packed_float4(imp_5.geom_0) ;
    _S394->rotation_err_1 = packed_float4(imp_5.rotation_err_1) ;
    _S394->ledger_0 = packed_float4(imp_5.ledger_0) ;
    _S394->cand_0 = packed_uint4(imp_5.cand_0) ;
    _S394->momentum_1 = packed_float4(imp_5.momentum_1) ;
    _S394->momentum_err_1 = packed_float4(imp_5.momentum_err_1) ;
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
    uint _S395 = table_0 + 4U * g_0;
    (&w_4)->island_3 = kernelContext_31->index_0[_S395];
    (&w_4)->begin_0 = kernelContext_31->index_0[_S395 + 1U];
    (&w_4)->end_0 = kernelContext_31->index_0[_S395 + 2U];
    (&w_4)->first_0 = kernelContext_31->index_0[_S395 + 3U];
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
    uint4 _S396 = uint4((kernelContext_33->islands_0+kernelContext_33->params_0->halt_index_0)->info_0) ;
    bool _S397;
    if(((_S396.z) & 1U) != 0U)
    {
        _S397 = true;
    }
    else
    {
        uint _S398 = _S396.y;
        if(_S398 != 0U)
        {
            _S397 = _S398 <= ((uint4(isl_0->info_0) ).w);
        }
        else
        {
            _S397 = false;
        }
    }
    return _S397;
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
    uint4 _S399 = uint4((kernelContext_34->islands_0+kernelContext_34->params_0->halt_index_0)->info_0) ;
    bool _S400;
    if(((_S399.z) & 1U) != 0U)
    {
        _S400 = true;
    }
    else
    {
        uint _S401 = _S399.y;
        if(_S401 != 0U)
        {
            _S400 = _S401 <= (isl_1->info_0.w);
        }
        else
        {
            _S400 = false;
        }
    }
    return _S400;
}

bool wide_runs_0(const Island_natural_0 thread* isl_2, KernelContext_0 thread* kernelContext_35)
{
    uint4 _S402 = uint4(isl_2->info_0) ;
    bool _S403;
    if(((_S402.z) & 1U) != 0U)
    {
        _S403 = true;
    }
    else
    {
        _S403 = (_S402.y) == 0U;
    }
    if(_S403)
    {
        return false;
    }
    if(((_S402.x) & 4U) == 0U)
    {
        _S403 = true;
    }
    else
    {
        bool _S404 = contact_stopped_0(isl_2, kernelContext_35);
        _S403 = !_S404;
    }
    return _S403;
}

bool wide_enter_0(uint tid_4, const Island_natural_0 thread* isl_3, KernelContext_0 thread* kernelContext_36)
{
    seen_clear_0(tid_4, kernelContext_36);
    if(tid_4 == 0U)
    {
        bool _S405 = wide_runs_0(isl_3, kernelContext_36);
        int _S406;
        if(_S405)
        {
            _S406 = int(1);
        }
        else
        {
            _S406 = int(0);
        }
        *kernelContext_36->g_wide_run_0 = uint(_S406);
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
    float4 _S407 = float4(*(kernelContext_41->loads_0+offset_0)) ;
    if(tau_0 <= (_S407.x))
    {
        return _S407.y;
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
        uint _S408 = offset_0 + i_5;
        float4 _S409 = float4(*(kernelContext_41->loads_0+_S408)) ;
        float _S410 = _S409.x;
        if(tau_0 <= _S410)
        {
            float4 _S411 = float4(*(kernelContext_41->loads_0+(_S408 - 1U))) ;
            float _S412 = _S411.x;
            float _S413 = _S411.y;
            return _S413 + (tau_0 - _S412) / max(_S410 - _S412, 1.00000000317107685e-30f) * (_S409.y - _S413);
        }
        i_5 = i_5 + 1U;
    }
    return (float4(*(kernelContext_41->loads_0+(offset_0 + count_3 - 1U))) ).y;
}

float eval_function_0(uint term_0, uint k_10, float dt_3, float shift_0, KernelContext_0 thread* kernelContext_42)
{
    uint _S414 = 5U * term_0;
    uint4 info_2 = (as_type<uint4>((float4(*(kernelContext_42->loads_0+_S414)) )));
    float4 _S415 = float4(*(kernelContext_42->loads_0+(_S414 + 3U))) ;
    float4 _S416 = float4(*(kernelContext_42->loads_0+(_S414 + 4U))) ;
    uint kind_0 = info_2.z;
    if(kind_0 == 0U)
    {
        return _S415.z;
    }
    float _S417 = time_since_0(_S415, k_10, dt_3, kernelContext_42);
    float tau_1 = _S417 + shift_0;
    float shape_1;
    if(kind_0 == 1U)
    {
        if(tau_1 <= 0.0f)
        {
            shape_1 = 0.0f;
        }
        else
        {
            float _S418 = _S416.x;
            if(tau_1 >= _S418)
            {
                shape_1 = _S416.y;
            }
            else
            {
                shape_1 = _S416.y * tau_1 / _S418;
            }
        }
        return shape_1;
    }
    bool _S419;
    if(kind_0 == 2U)
    {
        if(tau_1 < 0.0f)
        {
            _S419 = true;
        }
        else
        {
            _S419 = tau_1 > (_S416.x);
        }
        if(_S419)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S416.y * sin(3.14159274101257324f * tau_1 / _S416.x);
        }
        return shape_1;
    }
    if(kind_0 == 3U)
    {
        float sn_0 = tau_1 / _S416.y;
        if(sn_0 < 0.0f)
        {
            _S419 = true;
        }
        else
        {
            _S419 = sn_0 > 1.0f;
        }
        if(_S419)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S416.x * (1.0f - sn_0) * exp(- _S416.z * sn_0);
        }
        return shape_1;
    }
    if(kind_0 == 4U)
    {
        float _S420 = table_eval_0(info_2.w, (as_type<uint>((_S416.x))), tau_1, kernelContext_42);
        return _S420;
    }
    if(kind_0 == 5U)
    {
        (*kernelContext_42->g_seen_0)[1U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float sn_1 = tau_1 / _S416.x;
        if(sn_1 < 0.0f)
        {
            _S419 = true;
        }
        else
        {
            _S419 = sn_1 > 1.0f;
        }
        if(_S419)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = (1.0f - sn_1) * exp(- _S416.y * sn_1);
        }
        float clearing_0 = _S415.w;
        float relax_0;
        if(clearing_0 > 0.0f)
        {
            relax_0 = max(1.0f - tau_1 / clearing_0, 0.0f);
        }
        else
        {
            relax_0 = 0.0f;
        }
        float _S421 = _S416.w;
        return (_S421 + (_S416.z - _S421) * relax_0) * shape_1;
    }
    if(kind_0 == 7U)
    {
        (*kernelContext_42->g_seen_0)[2U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float _S422 = _S416.y;
        if(tau_1 < _S422)
        {
            return _S416.x;
        }
        float s_1 = tau_1 - _S422;
        float _S423 = _S416.w;
        if(s_1 > _S423)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S416.z * sin(3.14159274101257324f * s_1 / _S423);
        }
        return shape_1;
    }
    float _S424 = _S416.x;
    if(_S424 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp(1.0f - tau_1 / _S424, 0.0f, 1.0f);
}

void record_chunk_load_0(uint c_7, float3 f_1, float3 t_3, KernelContext_0 thread* kernelContext_43)
{
    if((kernelContext_43->params_0->solve_mode_0) == 0U)
    {
        return;
    }
    uint _S425 = 2U * c_7;
    *(kernelContext_43->scratch_0+(kernelContext_43->params_0->cload_base_0 + _S425)) = packed_float4(float4(f_1, 0.0f)) ;
    *(kernelContext_43->scratch_0+(kernelContext_43->params_0->cload_base_0 + _S425 + 1U)) = packed_float4(float4(t_3, 0.0f)) ;
    *(kernelContext_43->scratch_0+(kernelContext_43->params_0->cframe_base_0 + _S425)) = packed_float4(float4((float4(*(kernelContext_43->scratch_0+(kernelContext_43->params_0->cframe_base_0 + _S425))) ).xyz + f_1, 0.0f)) ;
    *(kernelContext_43->scratch_0+(kernelContext_43->params_0->cframe_base_0 + _S425 + 1U)) = packed_float4(float4((float4(*(kernelContext_43->scratch_0+(kernelContext_43->params_0->cframe_base_0 + _S425 + 1U))) ).xyz + t_3, 0.0f)) ;
    return;
}

void chunk_loads_0(uint _S426, uint _S427, const Quat_0 thread* _S428, uint _S429, float _S430, bool _S431, float _S432, float3 thread* _S433, float3 thread* _S434, float3 thread* _S435, float3 thread* _S436, KernelContext_0 thread* kernelContext_44)
{
    bool _S437;
    ChunkStatic_natural_0 device* _S438 = kernelContext_44->chunks_0+_S427;
    float3 _S439 = float3(0.0f) ;
    *_S433 = _S439;
    *_S434 = _S439;
    *_S435 = _S439;
    *_S436 = _S439;
    uint4 _S440 = uint4(_S438->load_range_0) ;
    uint term_1 = _S440.x;
    for(;;)
    {
        if(term_1 < (_S440.y))
        {
        }
        else
        {
            break;
        }
        (*kernelContext_44->g_seen_0)[0U] = 1U;
        uint _S441 = 5U * term_1;
        uint _S442 = (as_type<uint4>((float4(*(kernelContext_44->loads_0+_S441)) ))).y;
        bool replacement_0 = _S442 == 2U;
        float4 _S443 = float4(*(kernelContext_44->loads_0+(_S441 + 1U))) ;
        float4 _S444 = float4(*(kernelContext_44->loads_0+(_S441 + 2U))) ;
        float _S445;
        if(replacement_0)
        {
            _S445 = _S432;
        }
        else
        {
            _S445 = 0.0f;
        }
        float _S446 = eval_function_0(term_1, _S429, _S430, _S445, kernelContext_44);
        if(replacement_0)
        {
            float3 _S447 = float3(_S446) ;
            *_S435 = *_S435 + _S443.xyz * _S447;
            *_S436 = *_S436 + _S444.xyz * _S447;
            term_1 = term_1 + 1U;
            continue;
        }
        if(_S442 == 0U)
        {
            _S437 = true;
        }
        else
        {
            _S437 = _S442 == 3U;
        }
        float3 fw_0;
        if(_S437)
        {
            fw_0 = _S443.xyz * float3(_S446) ;
        }
        else
        {
            float3 _S448 = rotate_0(_S428, _S443.xyz);
            fw_0 = _S448 * float3((- _S446 * _S443.w)) ;
        }
        float3 lever_0;
        if(_S442 == 3U)
        {
            lever_0 = _S444.xyz - (float4(*(kernelContext_44->state_0+4U * _S426)) ).xyz;
        }
        else
        {
            lever_0 = _S444.xyz;
        }
        *_S433 = *_S433 + fw_0;
        float3 _S449 = rotate_0(_S428, lever_0);
        *_S434 = *_S434 + cross(_S449, fw_0);
        term_1 = term_1 + 1U;
    }
    if(_S431)
    {
        _S437 = ((uint4(_S438->cinfo_0) ).z) != 0U;
    }
    else
    {
        _S437 = false;
    }
    if(_S437)
    {
        uint4 _S450 = uint4(_S438->cinfo_0) ;
        uint g_1 = _S450.x;
        for(;;)
        {
            if(g_1 < (_S450.y))
            {
            }
            else
            {
                break;
            }
            uint _S451 = 2U * g_1;
            *_S433 = *_S433 + (float4(*(kernelContext_44->scratch_0+(kernelContext_44->params_0->seg_base_0 + _S451))) ).xyz;
            *_S434 = *_S434 + (float4(*(kernelContext_44->scratch_0+(kernelContext_44->params_0->seg_base_0 + _S451 + 1U))) ).xyz;
            g_1 = g_1 + 1U;
        }
    }
    return;
}

void chunk_external_0(uint _S452, uint _S453, const Quat_0 thread* _S454, uint _S455, float _S456, bool _S457, float3 thread* _S458, float3 thread* _S459, KernelContext_0 thread* kernelContext_45)
{
    thread float3 rf_0;
    thread float3 rm_0;
    chunk_loads_0(_S452, _S453, _S454, _S455, _S456, _S457, 0.0f, _S458, _S459, &rf_0, &rm_0, kernelContext_45);
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
    uint _S460;
    if(((*kernelContext_47->g_seen_0)[0U]) != 0U)
    {
        _S460 = 32768U;
    }
    else
    {
        _S460 = 0U;
    }
    uint _S461;
    if(((*kernelContext_47->g_seen_0)[1U]) != 0U)
    {
        _S461 = 65536U;
    }
    else
    {
        _S461 = 0U;
    }
    uint _S462 = _S460 | _S461;
    if(((*kernelContext_47->g_seen_0)[2U]) != 0U)
    {
        _S460 = 131072U;
    }
    else
    {
        _S460 = 0U;
    }
    uint _S463 = _S462 | _S460;
    if(((*kernelContext_47->g_seen_0)[3U]) != 0U)
    {
        _S460 = 32U;
    }
    else
    {
        _S460 = 0U;
    }
    uint _S464 = _S463 | _S460;
    if(((*kernelContext_47->g_seen_0)[4U]) != 0U)
    {
        _S460 = 64U;
    }
    else
    {
        _S460 = 0U;
    }
    return _S464 | _S460;
}

bool wide_enter_1(uint _S465, uint _S466, KernelContext_0 thread* kernelContext_48)
{
    thread Island_natural_0 _S467 = *(kernelContext_48->islands_0+_S466);
    seen_clear_0(_S465, kernelContext_48);
    if(_S465 == 0U)
    {
        bool _S468 = wide_runs_0(&_S467, kernelContext_48);
        int _S469;
        if(_S468)
        {
            _S469 = int(1);
        }
        else
        {
            _S469 = int(0);
        }
        *kernelContext_48->g_wide_run_0 = uint(_S469);
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
    threadgroup array<uint, int(4096)> g_label_4;
    (&kernelContext_49)->g_label_0 = &g_label_4;
    threadgroup uint g_changed_4;
    (&kernelContext_49)->g_changed_0 = &g_changed_4;
    threadgroup uint g_halt_4;
    (&kernelContext_49)->g_halt_0 = &g_halt_4;
    threadgroup uint g_run_4;
    (&kernelContext_49)->g_run_0 = &g_run_4;
    threadgroup uint g_flag_4;
    (&kernelContext_49)->g_flag_0 = &g_flag_4;
    threadgroup array<uint, int(1024)> g_mode_4;
    (&kernelContext_49)->g_mode_0 = &g_mode_4;
    uint tid_5 = thread_1.x;
    uint _S470 = group_1.x;
    WideGroup_0 _S471 = wide_group_0(params_4->wide_chunk_table_0, _S470, &kernelContext_49);
    if(_S470 != (_S471.first_0))
    {
        return;
    }
    thread Island_natural_0 _S472 = *((&kernelContext_49)->islands_0+_S471.island_3);
    uint4 _S473 = uint4((&_S472)->info_0) ;
    uint _S474 = _S473.x;
    bool _S475;
    if((_S474 & 16U) == 0U)
    {
        _S475 = true;
    }
    else
    {
        bool _S476 = wide_enter_1(tid_5, _S471.island_3, &kernelContext_49);
        _S475 = !_S476;
    }
    if(_S475)
    {
        return;
    }
    Quat_0 _S477 = quat_of_0(float4((&_S472)->rotation_0) );
    bool _S478 = (_S474 & 4U) != 0U;
    float3 _S479 = float3(0.0f) ;
    thread float3 norm_0 = _S479;
    thread float3 unused_1 = _S479;
    uint4 _S480 = uint4((&_S472)->range_0) ;
    uint c_9 = _S480.x + tid_5;
    for(;;)
    {
        if(c_9 < (_S480.y))
        {
        }
        else
        {
            break;
        }
        uint _S481 = wide_step_0(&_S472, &kernelContext_49);
        float _S482 = (&kernelContext_49)->params_0->dt_0;
        thread Quat_0 _S483 = _S477;
        float _S484 = settled_chunk_load_0(c_9, &_S483, _S481, _S482, _S478, &kernelContext_49);
        norm_0.x = norm_0.x + _S484;
        c_9 = c_9 + 256U;
    }
    group_sum3_0(tid_5, &norm_0, &unused_1, &kernelContext_49);
    if(tid_5 != 0U)
    {
        return;
    }
    uint _S485 = seen_bits_0(&kernelContext_49);
    uint cov_0 = 1024U | _S485;
    if(((&kernelContext_49)->params_0->solve_mode_0) == 1U)
    {
        float4 _S486 = float4((&_S472)->energy_0) ;
        _S475 = (abs(norm_0.x - _S486.z)) > (_S486.w);
    }
    else
    {
        _S475 = false;
    }
    uint cov_1;
    if(_S475)
    {
        ((&kernelContext_49)->islands_0+_S471.island_3)->info_0[int(0)] = _S474 & 4294967279U;
        ((&kernelContext_49)->islands_0+_S471.island_3)->info_0[int(2)] = (_S473.z) | 4U;
        cov_1 = cov_0 | 2048U;
    }
    else
    {
        cov_1 = cov_0;
    }
    cov_mark_0(_S471.island_3, (&_S472)->coverage_0, cov_1, &kernelContext_49);
    return;
}

bool is_damaged_0(const JointState_0 thread* st_0)
{
    bool _S487;
    if((st_0->damage_0) > 0.0f)
    {
        _S487 = true;
    }
    else
    {
        _S487 = (st_0->crush_1) > 0.0f;
    }
    return _S487;
}

bool connected_0(const JointState_0 thread* st_1, bool has_rebar_0)
{
    bool _S488;
    if((st_1->damage_0) < 1.0f)
    {
        _S488 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S488 = (st_1->rebar_broken_0) == 0.0f;
        }
        else
        {
            _S488 = false;
        }
    }
    return _S488;
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
    float4 _S489 = float4(b_23->geom0_0) ;
    float area_2 = _S489.x;
    float _S490 = q_lin_0.z;
    float axial_0 = (metal::fast::divide((_S490), (area_2)));
    float4 _S491 = float4(b_23->geom1_0) ;
    float _S492 = (metal::fast::divide((abs(q_ang_0.x)), (_S491.x)));
    float _S493 = (metal::fast::divide((abs(q_ang_0.y)), (_S491.y)));
    float bending_0 = _S492 + _S493;
    float _S494 = q_lin_0.x;
    float _S495 = q_lin_0.y;
    float _S496 = (metal::fast::sqrt((_S494 * _S494 + _S495 * _S495)));
    float _S497 = (metal::fast::divide((_S496), (area_2)));
    float _S498 = (metal::fast::divide((abs(q_ang_0.z)), (_S489.w)));
    float shear_1 = _S497 + _S498;
    thread Measures_0 m_2;
    (&m_2)->tension_0 = axial_0 + bending_0;
    (&m_2)->shear_0 = shear_1;
    float _S499 = - axial_0;
    (&m_2)->normal_compression_0 = max(_S499, 0.0f);
    (&m_2)->compression_0 = _S499 + bending_0;
    (&m_2)->compressive_force_0 = max(- _S490, 0.0f);
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
    float4 _S500 = mat_1->dif_0;
    float ref_0 = mat_1->dif_0.x;
    if(r_6 <= ref_0)
    {
        return 1.0f;
    }
    float _S501 = _S500.z;
    float f_3;
    if(r_6 <= _S501)
    {
        float _S502 = (metal::fast::divide((r_6), (ref_0)));
        float _S503 = (metal::fast::pow((_S502), (_S500.y)));
        f_3 = _S503;
    }
    else
    {
        float _S504 = (metal::fast::divide((_S501), (ref_0)));
        float _S505 = (metal::fast::pow((_S504), (_S500.y)));
        float _S506 = (metal::fast::divide((r_6), (_S501)));
        float _S507 = (metal::fast::pow((_S506), (_S500.w)));
        f_3 = _S505 * _S507;
    }
    return clamp(f_3, 1.0f, mat_1->misc_0.x);
}

float fatigue_factor_0(const JointMaterial_0 constant* mat_2, float life_1)
{
    if(((mat_2->kind_flags_0.y) & 64U) == 0U)
    {
        return 1.0f;
    }
    float _S508 = clamp(life_1, 0.0f, 1.0f);
    float _S509 = (metal::fast::divide((1.0f), (mat_2->misc_0.y - 2.0f)));
    float _S510 = (metal::fast::pow((_S508), (_S509)));
    return _S510;
}

float infinity_0()
{
    return (as_type<float>((2139095040U)));
}

float4 failure_indices_0(const JointMaterial_0 constant* mat_3, const JointBond_natural_0 thread* b_24, const Measures_0 thread* m_3, float multiplier_0)
{
    float fc_0 = mat_3->strength_0.y * multiplier_0;
    float _S511 = min(mat_3->strength_0.z * multiplier_0 + mat_3->strength_0.w * m_3->normal_compression_0, mat_3->energy_1.x * multiplier_0);
    thread float4 idx_0;
    float _S512 = (metal::fast::divide((m_3->tension_0), (mat_3->strength_0.x * multiplier_0)));
    idx_0.x = max(_S512, 0.0f);
    float _S513;
    if(_S511 > 0.0f)
    {
        float _S514 = (metal::fast::divide((m_3->shear_0), (_S511)));
        _S513 = _S514;
    }
    else
    {
        _S513 = infinity_0();
    }
    idx_0.y = _S513;
    float _S515 = (metal::fast::divide((m_3->compression_0), (fc_0)));
    idx_0.z = max(_S515, 0.0f);
    float _S516 = (float4(b_24->stiff1_0) ).y;
    if(_S516 > 0.0f)
    {
        float _S517 = (metal::fast::divide((m_3->compressive_force_0), (_S516)));
        _S513 = _S517;
    }
    else
    {
        _S513 = 0.0f;
    }
    idx_0.w = _S513;
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
        float _S518 = (metal::fast::divide((r_7 * (kappa_1 - 1.0f)), (kappa_1 * (r_7 - 1.0f))));
        return min(_S518, 1.0f);
    }
    if(kappa_1 >= (0.5f * (r_7 + 1.0f)))
    {
        return 1.0f;
    }
    float _S519 = (metal::fast::divide((1.0f), (kappa_1)));
    return 1.0f - _S519;
}

__attribute__((noinline))
float2 damage_increment_0(uint kind_2, float kappa_old_0, float lambda_0, float r_8, float d_old_0, float psi_0)
{
    float _S520 = damage_law_0(kind_2, lambda_0, r_8);
    float _S521 = max(_S520, d_old_0);
    bool _S522;
    if(_S521 <= d_old_0)
    {
        _S522 = true;
    }
    else
    {
        _S522 = d_old_0 >= 1.0f;
    }
    if(_S522)
    {
        return float2(d_old_0, 0.0f);
    }
    float u0_0 = (metal::fast::divide((psi_0), (lambda_0 * lambda_0)));
    float _S523 = max(kappa_old_0, 1.0f);
    if(kind_2 == 0U)
    {
        if(r_8 > 1.0f)
        {
            float _S524 = (metal::fast::divide((u0_0 * r_8), (r_8 - 1.0f)));
            return float2(_S521, _S524 * max(min(lambda_0, r_8) - min(_S523, r_8), 0.0f));
        }
        return float2(_S521, (1.0f - d_old_0) * psi_0);
    }
    float ku_0 = 0.5f * (r_8 + 1.0f);
    float plateau_0 = u0_0 * max(min(lambda_0, ku_0) - min(_S523, ku_0), 0.0f);
    float snap_0;
    if(_S521 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return float2(_S521, plateau_0 + snap_0);
}

void compressed_region_0(float w0_0, float w1_0, float dz_0, float ax_0, float ay_0, array<float, int(6)> thread* region_0)
{
    uint count_4;
    float h0_0 = 0.5f * w0_0;
    float h1_0 = 0.5f * w1_0;
    float _S525 = - h0_0;
    float _S526 = - h1_0;
    array<float2, int(4)> _S527 = { { float2(_S525, _S526), float2(h0_0, _S526), float2(h0_0, h1_0), float2(_S525, h1_0) } };
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
        uint _S528 = i_6;
        uint _S529 = i_6 + 1U;
        uint _S530 = _S529 % 4U;
        float _S531 = _S527[i_6].y;
        float _S532 = _S527[i_6].x;
        float fp_0 = dz_0 + ax_0 * _S531 - ay_0 * _S532;
        float _S533 = _S527[_S530].y;
        float _S534 = _S527[_S530].x;
        float fq_0 = dz_0 + ax_0 * _S533 - ay_0 * _S534;
        bool _S535 = fp_0 < 0.0f;
        if(_S535)
        {
            uint _S536 = count_5 + 1U;
            poly_0[count_5] = _S527[_S528];
            count_4 = _S536;
        }
        else
        {
            count_4 = count_5;
        }
        if(_S535 != (fq_0 < 0.0f))
        {
            float t_5 = fp_0 / (fp_0 - fq_0);
            uint _S537 = count_4 + 1U;
            poly_0[count_4] = float2(_S532 + t_5 * (_S534 - _S532), _S531 + t_5 * (_S533 - _S531));
            count_5 = _S537;
        }
        else
        {
            count_5 = count_4;
        }
        i_6 = _S529;
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
        float _S538 = o_1.x;
        float x0_0 = poly_0[i_6].x - _S538;
        float _S539 = o_1.y;
        float y0_0 = poly_0[i_6].y - _S539;
        uint _S540 = i_6 + 1U;
        uint _S541 = _S540 % count_5;
        float x1_0 = poly_0[_S541].x - _S538;
        float y1_0 = poly_0[_S541].y - _S539;
        float _S542 = x0_0 * y1_0;
        float _S543 = x1_0 * y0_0;
        float cr_0 = _S542 - _S543;
        float a_8 = a_7 + cr_0 / 2.0f;
        float sx_1 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        float sy_1 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        float ixx_1 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        float iyy_1 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        float ixy_1 = ixy_0 + (_S542 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S543) * cr_0 / 24.0f;
        i_6 = _S540;
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
    float _S544 = a_7 * cx_0;
    (*region_0)[int(3)] = ixx_0 - _S544 * cx_0;
    (*region_0)[int(4)] = iyy_0 - a_7 * cy_0 * cy_0;
    (*region_0)[int(5)] = ixy_0 - _S544 * cy_0;
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
    float _S545 = a_9 * fc_1;
    float _S546 = - ay_1;
    return float4(k_12 * a_9 * fc_1, k_12 * (_S545 * r_9[int(2)] + (_S546 * r_9[int(5)] + ax_1 * r_9[int(4)])), - k_12 * (_S545 * r_9[int(1)] + (_S546 * r_9[int(3)] + ax_1 * r_9[int(5)])), 0.5f * k_12 * (_S545 * fc_1 + ay_1 * ay_1 * r_9[int(3)] + ax_1 * ax_1 * r_9[int(4)] - 2.0f * ax_1 * ay_1 * r_9[int(5)]));
}

float signum_0(float x_10)
{
    float _S547;
    if(((as_type<uint>((x_10))) & 2147483648U) != 0U)
    {
        _S547 = -1.0f;
    }
    else
    {
        _S547 = 1.0f;
    }
    return _S547;
}

float2 return_map_0(float k_13, float total_2, float plastic_0, float cap_0)
{
    float trial_0 = k_13 * (total_2 - plastic_0);
    if((abs(trial_0)) <= cap_0)
    {
        return float2(trial_0, 0.0f);
    }
    float f_4 = cap_0 * signum_0(trial_0);
    float _S548 = (metal::fast::divide((trial_0 - f_4), (k_13)));
    return float2(f_4, _S548);
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
    float3 _S549 = float3(0.0f) ;
    (&c_10)->q_lin_1 = _S549;
    (&c_10)->q_ang_1 = _S549;
    (&c_10)->energy_2 = 0.0f;
    (&c_10)->diss_2 = 0.0f;
    (&c_10)->plastic_1 = plastic_2;
    uint _S550 = mat_4->kind_flags_0.y;
    if((_S550 & 2U) == 0U)
    {
        return c_10;
    }
    float4 _S551 = float4(b_25->stiff0_0) ;
    float kn_1 = _S551.x;
    float ks_0 = _S551.y;
    float kt_0 = (float4(b_25->stiff1_0) ).x;
    float4 _S552 = float4(b_25->geom0_0) ;
    float w0_2 = _S552.y;
    float w1_2 = _S552.z;
    float diss_3;
    float nc_sum_0;
    float m1_0;
    float m2_0;
    float energy_3;
    if((_S550 & 4U) != 0U)
    {
        float4 p_11 = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        float _S553 = p_11.y;
        float _S554 = p_11.z;
        float _S555 = p_11.w;
        nc_sum_0 = p_11.x;
        m1_0 = _S553;
        m2_0 = _S554;
        energy_3 = _S555;
    }
    else
    {
        float ki_0 = kn_1 * (1.0f - crush_2) / 36.0f;
        float _S556 = d_ang_0.x;
        float _S557 = d_ang_0.y;
        float spread_0 = abs(_S556) * 0.4166666567325592f * w1_2 + abs(_S557) * 0.4166666567325592f * w0_2;
        float _S558 = d_lin_0.z;
        float slack_0 = 9.99999997475242708e-07f * (abs(_S558) + spread_0);
        if((_S558 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S558 + spread_0) < (- slack_0))
            {
                float i1_0 = 2.91666650772094727f * w0_2 * w0_2;
                float i2_0 = 2.91666650772094727f * w1_2 * w1_2;
                float _S559 = ki_0 * _S556 * i2_0;
                float _S560 = ki_0 * _S557 * i1_0;
                float _S561 = 0.5f * ki_0 * (36.0f * _S558 * _S558 + _S556 * _S556 * i2_0 + _S557 * _S557 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S558;
                m1_0 = _S559;
                m2_0 = _S560;
                energy_3 = _S561;
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
                    float _S562 = SPRING_AT_0[i_7] * w0_2;
                    uint j_7 = 0U;
                    nc_sum_0 = diss_3;
                    m1_0 = m1_1;
                    m2_0 = m2_1;
                    energy_3 = energy_4;
                    for(;;)
                    {
                        if(j_7 < 6U)
                        {
                        }
                        else
                        {
                            break;
                        }
                        float s2_0 = SPRING_AT_0[j_7] * w1_2;
                        float di_0 = _S558 + _S556 * s2_0 - _S557 * _S562;
                        if(di_0 < 0.0f)
                        {
                            float f_5 = ki_0 * di_0;
                            float m1_2 = m1_0 + f_5 * s2_0;
                            float m2_2 = m2_0 - f_5 * _S562;
                            float energy_5 = energy_3 + 0.5f * ki_0 * di_0 * di_0;
                            nc_sum_0 = nc_sum_0 + f_5;
                            m1_0 = m1_2;
                            m2_0 = m2_2;
                            energy_3 = energy_5;
                        }
                        j_7 = j_7 + 1U;
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
    thread float3 p_12 = plastic_2;
    (&c_10)->q_lin_1 = float3(0.0f, 0.0f, nc_sum_0);
    (&c_10)->q_ang_1 = float3(m1_0, m2_0, 0.0f);
    float slide_cap_0 = mat_4->strength_0.w * nc_0;
    float _S563 = ks_0 * (d_lin_0.x - plastic_2.x);
    float _S564 = ks_0 * (d_lin_0.y - plastic_2.y);
    float tn_0 = (metal::fast::sqrt((_S563 * _S563 + _S564 * _S564)));
    bool _S565;
    if(tn_0 > slide_cap_0)
    {
        _S565 = tn_0 > 0.0f;
    }
    else
    {
        _S565 = false;
    }
    if(_S565)
    {
        float _S566 = (metal::fast::divide((_S563), (tn_0)));
        float _S567 = (metal::fast::divide((_S564), (tn_0)));
        float dslip_0 = (metal::fast::divide((tn_0 - slide_cap_0), (ks_0)));
        p_12.x = p_12.x + _S566 * dslip_0;
        p_12.y = p_12.y + _S567 * dslip_0;
        (&c_10)->q_lin_1.x = _S566 * slide_cap_0;
        (&c_10)->q_lin_1.y = _S567 * slide_cap_0;
        diss_3 = slide_cap_0 * dslip_0;
    }
    else
    {
        (&c_10)->q_lin_1.x = _S563;
        (&c_10)->q_lin_1.y = _S564;
        diss_3 = 0.0f;
    }
    float2 tq_0 = return_map_0(kt_0, d_ang_0.z, p_12.z, slide_cap_0 * (float4(b_25->geom1_0) ).z);
    float _S568 = tq_0.x;
    float _S569 = tq_0.y;
    float diss_4 = diss_3 + abs(_S568) * abs(_S569);
    p_12.z = p_12.z + _S569;
    (&c_10)->q_ang_1.z = _S568;
    float _S570 = (metal::fast::divide((sq_0((&c_10)->q_lin_1.x)), (ks_0)));
    float _S571 = (metal::fast::divide((sq_0((&c_10)->q_lin_1.y)), (ks_0)));
    float _S572 = _S570 + _S571;
    float _S573 = (metal::fast::divide((sq_0(_S568)), (kt_0)));
    (&c_10)->energy_2 = energy_3 + 0.5f * (_S572 + _S573);
    (&c_10)->diss_2 = diss_4;
    (&c_10)->plastic_1 = p_12;
    return c_10;
}

float3 contact_offsets_0(const JointMaterial_0 constant* mat_5, const JointBond_natural_0 thread* b_26, float crush_3, float3 plastic_3, float3 d_lin_1, float3 d_ang_1)
{
    uint _S574 = mat_5->kind_flags_0.y;
    if((_S574 & 2U) == 0U)
    {
        return plastic_3;
    }
    float4 _S575 = float4(b_26->stiff0_0) ;
    float kn_2 = _S575.x;
    float ks_1 = _S575.y;
    float kt_1 = (float4(b_26->stiff1_0) ).x;
    float4 _S576 = float4(b_26->geom0_0) ;
    float w0_3 = _S576.y;
    float w1_3 = _S576.z;
    float nc_sum_1;
    if((_S574 & 4U) != 0U)
    {
        float4 _S577 = no_tension_patch_0(kn_2 * (1.0f - crush_3), w0_3, w1_3, d_lin_1.z, d_ang_1.x, d_ang_1.y);
        nc_sum_1 = _S577.x;
    }
    else
    {
        float ki_1 = kn_2 * (1.0f - crush_3) / 36.0f;
        float _S578 = d_ang_1.x;
        float _S579 = d_ang_1.y;
        float spread_1 = abs(_S578) * 0.4166666567325592f * w1_3 + abs(_S579) * 0.4166666567325592f * w0_3;
        float _S580 = d_lin_1.z;
        float slack_1 = 9.99999997475242708e-07f * (abs(_S580) + spread_1);
        if((_S580 - spread_1) > slack_1)
        {
            nc_sum_1 = 0.0f;
        }
        else
        {
            if((_S580 + spread_1) < (- slack_1))
            {
                nc_sum_1 = ki_1 * 36.0f * _S580;
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
                    float _S581 = SPRING_AT_0[i_8] * w0_3;
                    uint j_8 = 0U;
                    nc_sum_1 = nc_sum_2;
                    for(;;)
                    {
                        if(j_8 < 6U)
                        {
                        }
                        else
                        {
                            break;
                        }
                        float di_1 = _S580 + _S578 * (SPRING_AT_0[j_8] * w1_3) - _S579 * _S581;
                        if(di_1 < 0.0f)
                        {
                            nc_sum_1 = nc_sum_1 + ki_1 * di_1;
                        }
                        j_8 = j_8 + 1U;
                    }
                    i_8 = i_8 + 1U;
                    nc_sum_2 = nc_sum_1;
                }
                nc_sum_1 = nc_sum_2;
            }
        }
    }
    float nc_1 = - nc_sum_1;
    thread float3 p_13 = plastic_3;
    float slide_cap_1 = mat_5->strength_0.w * nc_1;
    float _S582 = ks_1 * (d_lin_1.x - plastic_3.x);
    float _S583 = ks_1 * (d_lin_1.y - plastic_3.y);
    float tn_1 = (metal::fast::sqrt((_S582 * _S582 + _S583 * _S583)));
    bool _S584;
    if(tn_1 > slide_cap_1)
    {
        _S584 = tn_1 > 0.0f;
    }
    else
    {
        _S584 = false;
    }
    if(_S584)
    {
        float _S585 = (metal::fast::divide((_S582), (tn_1)));
        float _S586 = (metal::fast::divide((_S583), (tn_1)));
        float dslip_1 = (metal::fast::divide((tn_1 - slide_cap_1), (ks_1)));
        p_13.x = p_13.x + _S585 * dslip_1;
        p_13.y = p_13.y + _S586 * dslip_1;
    }
    float2 tq_1 = return_map_0(kt_1, d_ang_1.z, p_13.z, slide_cap_1 * (float4(b_26->geom1_0) ).z);
    p_13.z = p_13.z + tq_1.y;
    return p_13;
}

float life_rate_0(const JointMaterial_0 constant* mat_6, float s_2)
{
    if(s_2 <= 0.0f)
    {
        return 0.0f;
    }
    float _S587 = mat_6->misc_0.y;
    float _S588 = _S587 + 1.0f;
    float _S589 = (metal::fast::pow((s_2), (_S587)));
    float _S590 = (metal::fast::divide((_S588 * _S589), (mat_6->misc_0.z)));
    return _S590;
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
    float4 _S591 = float4(b_27->stiff0_0) ;
    float kn_3 = _S591.x;
    float ks_2 = _S591.y;
    float kb1_0 = _S591.z;
    float kb2_0 = _S591.w;
    float4 _S592 = float4(b_27->stiff1_0) ;
    float kt_2 = _S592.x;
    bool has_rebar_1 = (_S592.w) != 0.0f;
    uint kind_3 = mat_7->kind_flags_0.x;
    uint flags_1 = mat_7->kind_flags_0.y;
    bool softening_0 = (flags_1 & 1U) != 0U;
    thread JointState_0 st_2 = *state_6;
    bool _S593 = connected_0(state_6, has_rebar_1);
    float3 qe_lin_0 = d_lin_2 * float3(ks_2, ks_2, kn_3);
    float3 qe_ang_0 = d_ang_2 * float3(kb1_0, kb2_0, kt_2);
    Measures_0 _S594 = stress_measures_0(b_27, qe_lin_0, qe_ang_0);
    float _S595 = max(max(_S594.tension_0, _S594.shear_0), _S594.compression_0);
    bool _S596 = dt_5 > 0.0f;
    float dif_1;
    if(_S596)
    {
        float _S597 = (metal::fast::divide((_S595 - (&st_2)->governing_stress_0), (dt_5)));
        float raw_0 = (metal::fast::divide((max(_S597, 0.0f)), (mat_7->misc_0.w)));
        float tau_2 = _S592.z;
        if((flags_1 & 16U) != 0U)
        {
            float _S598 = (metal::fast::divide((dt_5), (tau_2)));
            dif_1 = - expm1_accurate_0(- _S598);
        }
        else
        {
            float _S599 = (metal::fast::divide((dt_5), (tau_2)));
            dif_1 = min(_S599, 1.0f);
        }
        (&st_2)->strain_rate_0 = (&st_2)->strain_rate_0 + (raw_0 - (&st_2)->strain_rate_0) * dif_1;
        (&st_2)->governing_stress_0 = _S595;
    }
    if((flags_1 & 32U) != 0U)
    {
        float _S600 = dif_factor_0(mat_7, (&st_2)->strain_rate_0);
        dif_1 = _S600;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = (float4(b_27->geom1_0) ).w;
    float _S601 = fatigue_factor_0(mat_7, (&st_2)->life_0);
    float multiplier_1 = weibull_0 * dif_1 * _S601;
    thread Measures_0 _S602 = _S594;
    float4 _S603 = failure_indices_0(mat_7, b_27, &_S602, multiplier_1);
    float _S604 = _S603.x;
    float _S605 = _S603.y;
    (&st_2)->utilization_0 = max(max(_S604, _S605), max(_S603.z, _S603.w));
    float _S606 = d_lin_2.x;
    float _S607 = d_lin_2.y;
    float _S608 = ks_2 * (sq_0(_S606) + sq_0(_S607)) + kb1_0 * sq_0(d_ang_2.x) + kb2_0 * sq_0(d_ang_2.y) + kt_2 * sq_0(d_ang_2.z);
    float _S609 = d_lin_2.z;
    bool _S610 = _S609 > 0.0f;
    if(_S610)
    {
        dif_1 = kn_3 * sq_0(_S609);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S608 + dif_1);
    float psi_c_0;
    if(_S609 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_3 * sq_0(_S609);
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
    bool _S611;
    float3 qc_lin_0;
    if(fracture_1)
    {
        bool _S612 = _S604 >= _S605;
        if(_S612)
        {
            diss_contact_0 = _S604;
        }
        else
        {
            diss_contact_0 = _S605;
        }
        uint mode_ts_0;
        if(_S612)
        {
            mode_ts_0 = 1U;
        }
        else
        {
            mode_ts_0 = 2U;
        }
        if(diss_contact_0 > ((&st_2)->kappa_0))
        {
            _S611 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S611 = false;
        }
        if(_S611)
        {
            _S611 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S611 = false;
        }
        uint mode_c_0;
        if(_S611)
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
                float _S613 = (metal::fast::divide((psi_contact_0 * (float4(b_27->geom0_0) ).x * diss_contact_0 * diss_contact_0), (psi_ts_0)));
                intact_normal_0 = _S613;
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
            float _S614 = inc_0.x;
            if(_S614 > ((&st_2)->damage_0))
            {
                Contact_0 _S615 = contact_part_0(mat_7, b_27, (&st_2)->crush_1, plastic_4, d_lin_2, d_ang_2);
                float _S616 = max(_S615.energy_2 - (1.0f - (&st_2)->crush_1) * psi_c_0, 0.0f);
                float _S617 = max(inc_0.y - _S616 * (_S614 - (&st_2)->damage_0), 0.0f);
                float _S618 = max((psi_ts_0 - _S616) * (_S614 - (&st_2)->damage_0) - _S617, 0.0f);
                (&st_2)->damage_0 = _S614;
                (&st_2)->mode_0 = mode_ts_0;
                dissipated_3 = _S617;
                overshoot_1 = _S618;
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
        float _S619 = state_6->damage_0;
        if((state_6->damage_0) > 0.0f)
        {
            Contact_0 _S620 = contact_part_0(mat_7, b_27, state_6->crush_1, float3(state_6->plastic_x_0, state_6->plastic_y_0, state_6->plastic_t_0), d_lin_2, d_ang_2);
            qc_lin_0 = qe_ang_0 * float3((1.0f - _S619))  + _S620.q_ang_1 * float3(_S619) ;
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S621 = stress_measures_0(b_27, float3(0.0f, 0.0f, min(qe_lin_0.z, 0.0f)), qc_lin_0);
        thread Measures_0 _S622 = _S621;
        float4 _S623 = failure_indices_0(mat_7, b_27, &_S622, multiplier_1);
        float _S624 = _S623.z;
        float _S625 = _S623.w;
        bool _S626 = _S624 >= _S625;
        if(_S626)
        {
            psi_contact_0 = _S624;
        }
        else
        {
            psi_contact_0 = _S625;
        }
        if(_S626)
        {
            mode_c_0 = 3U;
        }
        else
        {
            mode_c_0 = 4U;
        }
        if(psi_contact_0 > ((&st_2)->kappa_c_0))
        {
            _S611 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S611 = false;
        }
        if(_S611)
        {
            _S611 = psi_c_0 > 0.0f;
        }
        else
        {
            _S611 = false;
        }
        if(_S611)
        {
            if(softening_0)
            {
                float _S627 = (metal::fast::divide((mat_7->energy_1.w * (float4(b_27->geom0_0) ).x * psi_contact_0 * psi_contact_0), (psi_c_0)));
                intact_normal_0 = _S627;
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
            float _S628 = inc_1.x;
            if(_S628 > ((&st_2)->crush_1))
            {
                float _S629 = inc_1.y;
                float dissipated_4 = dissipated_3 + _S629;
                float overshoot_2 = overshoot_1 + max(psi_c_0 * (_S628 - (&st_2)->crush_1) - _S629, 0.0f);
                (&st_2)->crush_1 = _S628;
                (&st_2)->mode_0 = mode_c_0;
                if(_S628 >= 1.0f)
                {
                    _S611 = ((&st_2)->damage_0) < 1.0f;
                }
                else
                {
                    _S611 = false;
                }
                if(_S611)
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
    float3 _S630 = float3(0.0f) ;
    float3 qc_ang_0;
    if(((&st_2)->damage_0) == 0.0f)
    {
        if((flags_1 & 8U) == 0U)
        {
            float3 _S631 = contact_offsets_0(mat_7, b_27, (&st_2)->crush_1, plastic_4, d_lin_2, d_ang_2);
            (&st_2)->plastic_x_0 = _S631.x;
            (&st_2)->plastic_y_0 = _S631.y;
            (&st_2)->plastic_t_0 = _S631.z;
        }
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S630;
        qc_ang_0 = _S630;
        psi_contact_0 = 0.0f;
    }
    else
    {
        Contact_0 _S632 = contact_part_0(mat_7, b_27, (&st_2)->crush_1, plastic_4, d_lin_2, d_ang_2);
        (&st_2)->plastic_x_0 = _S632.plastic_1.x;
        (&st_2)->plastic_y_0 = _S632.plastic_1.y;
        (&st_2)->plastic_t_0 = _S632.plastic_1.z;
        diss_contact_0 = _S632.diss_2;
        qc_lin_0 = _S632.q_lin_1;
        qc_ang_0 = _S632.q_ang_1;
        psi_contact_0 = _S632.energy_2;
    }
    float dissipated_6 = dissipated_3 + dmg_0 * diss_contact_0;
    if(_S610)
    {
        intact_normal_0 = kn_3 * _S609;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_2)->crush_1) * kn_3 * _S609;
    }
    float _S633 = 1.0f - dmg_0;
    float3 force_lin_2 = float3(_S633 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S633 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S633 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3 force_ang_2 = qe_ang_0 * float3(_S633)  + qc_ang_0 * float3(dmg_0) ;
    float stored_4 = _S633 * (psi_ts_0 + (1.0f - (&st_2)->crush_1) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S611 = ((&st_2)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S611 = false;
    }
    float stored_5;
    float3 force_lin_3;
    if(_S611)
    {
        float4 _S634 = float4(b_27->rebar0_0) ;
        float k_axial_0 = _S634.x;
        float k_dowel_0 = _S634.y;
        float yield_force_0 = _S634.z;
        float dowel_capacity_0 = _S634.w;
        float2 nr_0 = return_map_0(k_axial_0, _S609, (&st_2)->rebar_plastic_0, yield_force_0);
        float2 v1_0 = return_map_0(k_dowel_0, _S606, (&st_2)->rebar_slip0_0, dowel_capacity_0);
        float2 v2_0 = return_map_0(k_dowel_0, _S607, (&st_2)->rebar_slip1_0, dowel_capacity_0);
        float _S635 = nr_0.y;
        float _S636 = v1_0.y;
        float _S637 = v2_0.y;
        float work_0 = yield_force_0 * abs(_S635) + dowel_capacity_0 * (abs(_S636) + abs(_S637));
        (&st_2)->rebar_plastic_0 = (&st_2)->rebar_plastic_0 + _S635;
        (&st_2)->rebar_slip0_0 = (&st_2)->rebar_slip0_0 + _S636;
        (&st_2)->rebar_slip1_0 = (&st_2)->rebar_slip1_0 + _S637;
        (&st_2)->rebar_work_0 = (&st_2)->rebar_work_0 + work_0;
        float dissipated_7 = dissipated_6 + work_0;
        float _S638 = nr_0.x;
        float _S639 = (metal::fast::divide((sq_0(_S638)), (k_axial_0)));
        float _S640 = v1_0.x;
        float _S641 = v2_0.x;
        float _S642 = (metal::fast::divide((sq_0(_S640) + sq_0(_S641)), (k_dowel_0)));
        float elastic_0 = 0.5f * (_S639 + _S642);
        if(fracture_1)
        {
            _S611 = ((&st_2)->rebar_work_0) >= ((float4(b_27->rebar1_0) ).x);
        }
        else
        {
            _S611 = false;
        }
        if(_S611)
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
            force_lin_3 = force_lin_2 + float3(_S640, _S641, _S638);
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
        _S611 = _S596;
    }
    else
    {
        _S611 = false;
    }
    if(_S611)
    {
        _S611 = (flags_1 & 64U) != 0U;
    }
    else
    {
        _S611 = false;
    }
    if(_S611)
    {
        Measures_0 _S643 = stress_measures_0(b_27, force_lin_3, force_ang_2);
        thread Measures_0 _S644 = _S643;
        float4 _S645 = failure_indices_0(mat_7, b_27, &_S644, weibull_0);
        float _S646 = life_rate_0(mat_7, max(max(_S645.x, _S645.y), _S645.z));
        (&st_2)->life_0 = max((&st_2)->life_0 - _S646 * dt_5, 0.0f);
    }
    (&st_2)->dissipated_0 = (&st_2)->dissipated_0 + dissipated_3;
    thread JointResponse_0 resp_0;
    (&resp_0)->force_lin_1 = force_lin_3;
    (&resp_0)->force_ang_1 = force_ang_2;
    (&resp_0)->state_5 = st_2;
    (&resp_0)->dissipated_2 = dissipated_3;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_3 = stored_5;
    if(_S593)
    {
        thread JointState_0 _S647 = st_2;
        bool _S648 = connected_0(&_S647, has_rebar_1);
        _S611 = !_S648;
    }
    else
    {
        _S611 = false;
    }
    (&resp_0)->disconnected_0 = _S611;
    (&resp_0)->fatigue_before_0 = _S601;
    (&resp_0)->measures_0 = _S594;
    return resp_0;
}

void secant_factors_0(const JointBond_natural_0 thread* b_28, const JointState_0 thread* st_3, float3 d_lin_3, float3 thread* f_lin_0, float3 thread* f_ang_0)
{
    float _S649 = st_3->damage_0;
    bool compressed_0 = (d_lin_3.z) < 0.0f;
    float contact_1;
    if(compressed_0)
    {
        contact_1 = _S649;
    }
    else
    {
        contact_1 = 0.0f;
    }
    float _S650 = 1.0f - _S649;
    float _S651 = max(_S650 + contact_1, 9.99999997475242708e-07f);
    float normal_5;
    if(compressed_0)
    {
        normal_5 = max(1.0f - st_3->crush_1, 9.99999997475242708e-07f);
    }
    else
    {
        normal_5 = max(_S650, 9.99999997475242708e-07f);
    }
    *f_lin_0 = float3(_S651, _S651, normal_5);
    *f_ang_0 = float3(_S651) ;
    bool _S652;
    if(((float4(b_28->stiff1_0) ).w) != 0.0f)
    {
        _S652 = (st_3->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S652 = false;
    }
    if(_S652)
    {
        float4 _S653 = float4(b_28->rebar0_0) ;
        float4 _S654 = float4(b_28->stiff0_0) ;
        float _S655 = (metal::fast::divide((_S653.x), (_S654.x)));
        (*f_lin_0).z = (*f_lin_0).z + _S655;
        float _S656 = _S653.y;
        float _S657 = _S654.y;
        float _S658 = (metal::fast::divide((_S656), (_S657)));
        (*f_lin_0).x = (*f_lin_0).x + _S658;
        float _S659 = (metal::fast::divide((_S656), (_S657)));
        (*f_lin_0).y = (*f_lin_0).y + _S659;
    }
    return;
}

float3 to_local_0(uint _S660, float3 _S661, KernelContext_0 thread* kernelContext_50)
{
    BondStatic_natural_0 device* _S662 = kernelContext_50->bonds_0+_S660;
    return float3(dot(_S661, (float4(_S662->t1_0) ).xyz), dot(_S661, (float4(_S662->t2_0) ).xyz), dot(_S661, (float4(_S662->normal_0) ).xyz));
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

float3 to_body_0(uint _S663, float3 _S664, KernelContext_0 thread* kernelContext_51)
{
    BondStatic_natural_0 device* _S665 = kernelContext_51->bonds_0+_S663;
    return (float4(_S665->t1_0) ).xyz * float3(_S664.x)  + (float4(_S665->t2_0) ).xyz * float3(_S664.y)  + (float4(_S665->normal_0) ).xyz * float3(_S664.z) ;
}

bool bond_update_0(uint i_9, float dt_6, bool fracture_2, uint abs_step_0, bool wide_0, KernelContext_0 thread* kernelContext_52)
{
    BondStatic_natural_0 device* _S666 = kernelContext_52->bonds_0+i_9;
    uint4 _S667 = uint4(_S666->law_0.ids_0) ;
    float3 ra_1 = (float4(_S666->ra_0) ).xyz;
    float3 rb_1 = (float4(_S666->rb_0) ).xyz;
    uint _S668 = 4U * _S667.y;
    float3 ta_2 = (float4(*(kernelContext_52->state_0+(_S668 + 1U))) ).xyz;
    float3 va_0 = (float4(*(kernelContext_52->state_0+(_S668 + 2U))) ).xyz;
    float3 wa_1 = (float4(*(kernelContext_52->state_0+(_S668 + 3U))) ).xyz;
    uint _S669 = 4U * _S667.z;
    float3 tb_2 = (float4(*(kernelContext_52->state_0+(_S669 + 1U))) ).xyz;
    float3 vb_0 = (float4(*(kernelContext_52->state_0+(_S669 + 2U))) ).xyz;
    float3 wb_1 = (float4(*(kernelContext_52->state_0+(_S669 + 3U))) ).xyz;
    float3 _S670 = to_local_0(i_9, (float4(*(kernelContext_52->state_0+_S669)) ).xyz + cross(tb_2, rb_1) - ((float4(*(kernelContext_52->state_0+_S668)) ).xyz + cross(ta_2, ra_1)), kernelContext_52);
    float3 _S671 = to_local_0(i_9, tb_2 - ta_2, kernelContext_52);
    float3 _S672 = to_local_0(i_9, vb_0 + cross(wb_1, rb_1) - (va_0 + cross(wa_1, ra_1)), kernelContext_52);
    float3 _S673 = to_local_0(i_9, wb_1 - wa_1, kernelContext_52);
    JointState_0 previous_0 = (kernelContext_52->bond_dyn_0+i_9)->js_0;
    thread JointState_0 _S674 = (kernelContext_52->bond_dyn_0+i_9)->js_0;
    bool _S675 = is_damaged_0(&_S674);
    thread JointBond_natural_0 _S676 = (kernelContext_52->bonds_0+i_9)->law_0;
    thread JointState_0 _S677 = (kernelContext_52->bond_dyn_0+i_9)->js_0;
    JointResponse_0 _S678 = joint_evaluate_0(&kernelContext_52->materials_0->m_0[(uint4((kernelContext_52->bonds_0+i_9)->law_0.ids_0) ).x], &_S676, &_S677, _S670, _S671, dt_6, fracture_2);
    BondStatic_natural_0 device* _S679 = kernelContext_52->bonds_0+i_9;
    BondDyn_natural_0 device* _S680 = kernelContext_52->bond_dyn_0+i_9;
    float4 _S681 = float4((*_S680).force_lin_0) ;
    float4 _S682 = float4((*_S680).force_ang_0) ;
    float4 _S683 = float4((*_S680).sums_0) ;
    float4 _S684 = float4((*_S680).comps_0) ;
    uint4 _S685 = uint4((*_S680).events_0) ;
    thread BondDyn_0 bd_0;
    (&bd_0)->js_0 = (*_S680).js_0;
    (&bd_0)->force_lin_0 = _S681;
    (&bd_0)->force_ang_0 = _S682;
    (&bd_0)->sums_0 = _S683;
    (&bd_0)->comps_0 = _S684;
    (&bd_0)->events_0 = _S685;
    float3 ra_2 = (float4(_S679->ra_0) ).xyz;
    float3 rb_2 = (float4(_S679->rb_0) ).xyz;
    thread JointBond_natural_0 _S686 = _S679->law_0;
    thread JointState_0 _S687 = _S678.state_5;
    thread float3 f_lin_1;
    thread float3 f_ang_1;
    secant_factors_0(&_S686, &_S687, _S670, &f_lin_1, &f_ang_1);
    float3 qd_lin_0 = _S672 * (float4(_S679->c_lin_0) ).xyz * f_lin_1;
    float3 qd_ang_0 = _S673 * (float4(_S679->c_ang_0) ).xyz * f_ang_1;
    float3 q_lin_2 = _S678.force_lin_1 + qd_lin_0;
    float3 q_ang_2 = _S678.force_ang_1 + qd_ang_0;
    float damped_0 = (dot(qd_lin_0, _S672) + dot(qd_ang_0, _S673)) * dt_6;
    float3 _S688 = to_body_0(i_9, q_lin_2, kernelContext_52);
    float3 _S689 = to_body_0(i_9, q_ang_2, kernelContext_52);
    uint _S690 = 3U * i_9;
    *(kernelContext_52->scratch_0+_S690) = packed_float4(float4(_S688, max(_S678.measures_0.tension_0, _S678.measures_0.compression_0))) ;
    *(kernelContext_52->scratch_0+(_S690 + 1U)) = packed_float4(float4(_S689 + cross(ra_2, _S688), 0.0f)) ;
    *(kernelContext_52->scratch_0+(_S690 + 2U)) = packed_float4(float4(- _S689 + cross(rb_2, - _S688), 0.0f)) ;
    thread float _S691 = (&bd_0)->sums_0.x;
    thread float _S692 = (&bd_0)->comps_0.x;
    comp_add1_0(&_S691, &_S692, _S678.dissipated_2);
    (&bd_0)->comps_0.x = _S692;
    (&bd_0)->sums_0.x = _S691;
    thread float _S693 = (&bd_0)->sums_0.y;
    thread float _S694 = (&bd_0)->comps_0.y;
    comp_add1_0(&_S693, &_S694, _S678.overshoot_0);
    (&bd_0)->comps_0.y = _S694;
    (&bd_0)->sums_0.y = _S693;
    thread float _S695 = (&bd_0)->sums_0.z;
    thread float _S696 = (&bd_0)->comps_0.z;
    comp_add1_0(&_S695, &_S696, damped_0);
    (&bd_0)->comps_0.z = _S696;
    (&bd_0)->sums_0.z = _S695;
    (&bd_0)->force_lin_0 = float4(q_lin_2, _S678.stored_3);
    (&bd_0)->force_ang_0 = float4(q_ang_2, max((&bd_0)->force_ang_0.w, _S678.state_5.utilization_0));
    bool _S697;
    if(!_S675)
    {
        thread JointState_0 _S698 = _S678.state_5;
        bool _S699 = is_damaged_0(&_S698);
        _S697 = _S699;
    }
    else
    {
        _S697 = false;
    }
    if(_S697)
    {
        _S697 = ((&bd_0)->events_0.x) == 0U;
    }
    else
    {
        _S697 = false;
    }
    if(_S697)
    {
        (&bd_0)->events_0.x = abs_step_0;
        (&bd_0)->events_0.w = _S678.state_5.mode_0;
        if(wide_0)
        {
            cov_or_0((uint4((&_S686)->ids_0) ).w, 32U, kernelContext_52);
        }
        else
        {
            (*kernelContext_52->g_seen_0)[3U] = 1U;
        }
    }
    if(((&bd_0)->events_0.y) == 0U)
    {
        _S697 = (_S678.state_5.life_0) != (previous_0.life_0);
    }
    else
    {
        _S697 = false;
    }
    if(_S697)
    {
        _S697 = (_S678.fatigue_before_0) > 0.99000000953674316f;
    }
    else
    {
        _S697 = false;
    }
    if(_S697)
    {
        float _S700 = fatigue_factor_0(&kernelContext_52->materials_0->m_0[(uint4((kernelContext_52->bonds_0+i_9)->law_0.ids_0) ).x], _S678.state_5.life_0);
        _S697 = _S700 <= 0.99000000953674316f;
    }
    else
    {
        _S697 = false;
    }
    if(_S697)
    {
        (&bd_0)->events_0.y = abs_step_0;
        if(wide_0)
        {
            cov_or_0((uint4((&_S686)->ids_0) ).w, 64U, kernelContext_52);
        }
        else
        {
            (*kernelContext_52->g_seen_0)[4U] = 1U;
        }
    }
    if(_S678.disconnected_0)
    {
        (&bd_0)->events_0.z = abs_step_0;
    }
    (&bd_0)->js_0 = _S678.state_5;
    BondDyn_natural_0 device* _S701 = kernelContext_52->bond_dyn_0+i_9;
    _S701->js_0 = bd_0.js_0;
    _S701->force_lin_0 = packed_float4(bd_0.force_lin_0) ;
    _S701->force_ang_0 = packed_float4(bd_0.force_ang_0) ;
    _S701->sums_0 = packed_float4(bd_0.sums_0) ;
    _S701->comps_0 = packed_float4(bd_0.comps_0) ;
    _S701->events_0 = packed_uint4(bd_0.events_0) ;
    return _S678.disconnected_0;
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
    float3 _S702 = float3(0.0f) ;
    (&rg_0)->torque_0 = _S702;
    (&rg_0)->a_10 = _S702;
    (&rg_0)->alpha_0 = _S702;
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
    float3 _S703 = float3(0.0f) ;
    (&rg_1)->torque_0 = _S703;
    (&rg_1)->a_10 = _S703;
    (&rg_1)->alpha_0 = _S703;
    return rg_1;
}

void net_load_0(uint c_11, const Island_natural_0 thread* isl_9, const Rigid_0 thread* rg_2, uint k_14, float dt_7, bool contact_2, float3 thread* f_6, float3 thread* t_6, KernelContext_0 thread* kernelContext_53)
{
    ChunkStatic_natural_0 device* _S704 = kernelContext_53->chunks_0+c_11;
    thread float3 fl_0;
    thread float3 tl_0;
    thread float3 rep_f_0;
    thread float3 rep_m_0;
    chunk_loads_0(c_11, c_11, &rg_2->rot_1, k_14, dt_7, contact_2, 0.0f, &fl_0, &tl_0, &rep_f_0, &rep_m_0, kernelContext_53);
    float4 _S705 = float4(_S704->center_0) ;
    float3 fc_2 = fl_0 + kernelContext_53->params_0->gravity_0.xyz * float3(_S705.w) ;
    float3 _S706 = _S705.xyz;
    float3 _S707 = (float4(isl_9->com_0) ).xyz;
    float3 _S708 = rotate_0(&rg_2->rot_1, _S706 + (float4(*(kernelContext_53->state_0+4U * c_11)) ).xyz - _S707);
    *f_6 = *f_6 + fc_2;
    *t_6 = *t_6 + (cross(_S708, fc_2) + tl_0);
    uint4 _S709 = uint4(_S704->load_range_0) ;
    if((_S709.y) > (_S709.x))
    {
        float3 _S710 = rotate_0(&rg_2->rot_1, rep_f_0);
        *f_6 = *f_6 + _S710;
        float3 _S711 = rotate_0(&rg_2->rot_1, _S706 - _S707);
        float3 _S712 = cross(_S711, _S710);
        float3 _S713 = rotate_0(&rg_2->rot_1, rep_m_0);
        *t_6 = *t_6 + (_S712 + _S713);
    }
    return;
}

void net_load_1(uint c_12, const Island_0 thread* isl_10, const Rigid_0 thread* rg_3, uint k_15, float dt_8, bool contact_3, float3 thread* f_7, float3 thread* t_7, KernelContext_0 thread* kernelContext_54)
{
    ChunkStatic_natural_0 device* _S714 = kernelContext_54->chunks_0+c_12;
    thread float3 fl_1;
    thread float3 tl_1;
    thread float3 rep_f_1;
    thread float3 rep_m_1;
    chunk_loads_0(c_12, c_12, &rg_3->rot_1, k_15, dt_8, contact_3, 0.0f, &fl_1, &tl_1, &rep_f_1, &rep_m_1, kernelContext_54);
    float4 _S715 = float4(_S714->center_0) ;
    float3 fc_3 = fl_1 + kernelContext_54->params_0->gravity_0.xyz * float3(_S715.w) ;
    float3 _S716 = _S715.xyz;
    float3 _S717 = isl_10->com_0.xyz;
    float3 _S718 = rotate_0(&rg_3->rot_1, _S716 + (float4(*(kernelContext_54->state_0+4U * c_12)) ).xyz - _S717);
    *f_7 = *f_7 + fc_3;
    *t_7 = *t_7 + (cross(_S718, fc_3) + tl_1);
    uint4 _S719 = uint4(_S714->load_range_0) ;
    if((_S719.y) > (_S719.x))
    {
        float3 _S720 = rotate_0(&rg_3->rot_1, rep_f_1);
        *f_7 = *f_7 + _S720;
        float3 _S721 = rotate_0(&rg_3->rot_1, _S716 - _S717);
        float3 _S722 = cross(_S721, _S720);
        float3 _S723 = rotate_0(&rg_3->rot_1, rep_m_1);
        *t_7 = *t_7 + (_S722 + _S723);
    }
    return;
}

void wide_store_0(uint slot_1, uint p_14, float3 a_11, float3 b_29, KernelContext_0 thread* kernelContext_55)
{
    uint _S724 = 8U * slot_1;
    *(kernelContext_55->scratch_0+(kernelContext_55->params_0->wide_base_0 + _S724 + p_14)) = packed_float4(float4(a_11, 0.0f)) ;
    *(kernelContext_55->scratch_0+(kernelContext_55->params_0->wide_base_0 + _S724 + p_14 + 1U)) = packed_float4(float4(b_29, 0.0f)) ;
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
    threadgroup array<uint, int(4096)> g_label_5;
    (&kernelContext_56)->g_label_0 = &g_label_5;
    threadgroup uint g_changed_5;
    (&kernelContext_56)->g_changed_0 = &g_changed_5;
    threadgroup uint g_halt_5;
    (&kernelContext_56)->g_halt_0 = &g_halt_5;
    threadgroup uint g_run_5;
    (&kernelContext_56)->g_run_0 = &g_run_5;
    threadgroup uint g_flag_5;
    (&kernelContext_56)->g_flag_0 = &g_flag_5;
    threadgroup array<uint, int(1024)> g_mode_5;
    (&kernelContext_56)->g_mode_0 = &g_mode_5;
    uint tid_6 = thread_2.x;
    uint _S725 = group_2.x;
    bool bond_group_0 = _S725 < (params_5->wide_bond_groups_0);
    WideGroup_0 wg_0;
    if(bond_group_0)
    {
        WideGroup_0 _S726 = wide_group_0((&kernelContext_56)->params_0->wide_bond_table_0, _S725, &kernelContext_56);
        wg_0 = _S726;
    }
    else
    {
        WideGroup_0 _S727 = wide_group_0((&kernelContext_56)->params_0->wide_chunk_table_0, _S725 - params_5->wide_bond_groups_0, &kernelContext_56);
        wg_0 = _S727;
    }
    WideGroup_0 _S728 = wg_0;
    thread Island_natural_0 _S729 = *((&kernelContext_56)->islands_0+wg_0.island_3);
    bool _S730 = wide_enter_1(tid_6, wg_0.island_3, &kernelContext_56);
    if(!_S730)
    {
        return;
    }
    uint _S731 = wide_step_0(&_S729, &kernelContext_56);
    if(bond_group_0)
    {
        uint4 _S732 = uint4((&_S729)->info_0) ;
        if(((_S732.x) & 16U) != 0U)
        {
            return;
        }
        uint i_10 = wg_0.begin_0 + tid_6;
        bool _S733;
        if(i_10 < (wg_0.end_0))
        {
            bool _S734 = bond_update_0(i_10, (&kernelContext_56)->params_0->dt_0, ((&kernelContext_56)->params_0->fracture_0) != 0U, _S732.w + 1U, true, &kernelContext_56);
            _S733 = _S734;
        }
        else
        {
            _S733 = false;
        }
        if(_S733)
        {
            ((&kernelContext_56)->islands_0+_S728.island_3)->info_0[int(2)] = (_S732.z) | 2U;
        }
        return;
    }
    uint _S735 = (uint4((&_S729)->info_0) ).x;
    if((_S735 & 1U) != 0U)
    {
        return;
    }
    float3 _S736 = float3(0.0f) ;
    thread float3 f_8 = _S736;
    thread float3 t_8 = _S736;
    uint c_13 = wg_0.begin_0 + tid_6;
    if(c_13 < (wg_0.end_0))
    {
        Rigid_0 _S737 = rigid_of_0(&_S729);
        float _S738 = (&kernelContext_56)->params_0->dt_0;
        bool _S739 = (_S735 & 4U) != 0U;
        thread Rigid_0 _S740 = _S737;
        net_load_0(c_13, &_S729, &_S740, _S731, _S738, _S739, &f_8, &t_8, &kernelContext_56);
    }
    group_sum3_0(tid_6, &f_8, &t_8, &kernelContext_56);
    if(tid_6 == 0U)
    {
        wide_store_0(_S725 - params_5->wide_bond_groups_0, 0U, f_8, t_8, &kernelContext_56);
    }
    return;
}

void wide_partials_0(uint tid_7, uint first_1, uint count_6, uint p_15, float3 thread* a_12, float3 thread* b_30, KernelContext_0 thread* kernelContext_57)
{
    float4 _S741 = float4(0.0f) ;
    thread float4 x_11 = _S741;
    thread float4 y_2 = _S741;
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
        uint _S742 = 8U * (first_1 + s_3);
        x_11 = x_11 + float4(*(kernelContext_57->scratch_0+(kernelContext_57->params_0->wide_base_0 + _S742 + p_15))) ;
        y_2 = y_2 + float4(*(kernelContext_57->scratch_0+(kernelContext_57->params_0->wide_base_0 + _S742 + p_15 + 1U))) ;
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
    ChunkStatic_natural_0 device* _S743 = kernelContext_58->chunks_0+c_14;
    float4 _S744 = float4(_S743->center_0) ;
    float3 r_10 = _S744.xyz - wcom_1;
    uint _S745 = 4U * c_14;
    float3 _S746 = float3(_S744.w) ;
    float4 _S747 = float4(_S743->inertia0_1) ;
    float4 _S748 = float4(_S743->inertia1_1) ;
    float4 _S749 = float4(_S743->inertia2_1) ;
    float3 _S750 = float3((float4(_S743->scale_0) ).x) ;
    *lu_0 = *lu_0 + (cross(r_10, (float4(*(kernelContext_58->state_0+_S745)) ).xyz - tr_0) * _S746 + rows_mul_0(_S747, _S748, _S749, (float4(*(kernelContext_58->state_0+(_S745 + 1U))) ).xyz)) * _S750;
    *lv_0 = *lv_0 + (cross(r_10, (float4(*(kernelContext_58->state_0+(_S745 + 2U))) ).xyz - dv_0) * _S746 + rows_mul_0(_S747, _S748, _S749, (float4(*(kernelContext_58->state_0+(_S745 + 3U))) ).xyz)) * _S750;
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
    threadgroup array<uint, int(4096)> g_label_6;
    (&kernelContext_59)->g_label_0 = &g_label_6;
    threadgroup uint g_changed_6;
    (&kernelContext_59)->g_changed_0 = &g_changed_6;
    threadgroup uint g_halt_6;
    (&kernelContext_59)->g_halt_0 = &g_halt_6;
    threadgroup uint g_run_6;
    (&kernelContext_59)->g_run_0 = &g_run_6;
    threadgroup uint g_flag_6;
    (&kernelContext_59)->g_flag_0 = &g_flag_6;
    threadgroup array<uint, int(1024)> g_mode_6;
    (&kernelContext_59)->g_mode_0 = &g_mode_6;
    uint tid_8 = thread_3.x;
    uint _S751 = group_3.x;
    WideGroup_0 _S752 = wide_group_0(params_6->wide_chunk_table_0, _S751, &kernelContext_59);
    Island_natural_0 device* _S753 = (&kernelContext_59)->islands_0+_S752.island_3;
    Island_natural_0 isl_11 = *_S753;
    bool _S754;
    if((((uint4((*_S753).info_0) ).x) & 17U) != 0U)
    {
        _S754 = true;
    }
    else
    {
        bool _S755 = wide_enter_1(tid_8, _S752.island_3, &kernelContext_59);
        _S754 = !_S755;
    }
    if(_S754)
    {
        return;
    }
    thread float3 tu_0;
    thread float3 pv_0;
    wide_partials_0(tid_8, _S752.first_0, isl_11.wide_groups_0, 2U, &tu_0, &pv_0, &kernelContext_59);
    float4 _S756 = float4(isl_11.wcom_0) ;
    float3 _S757 = float3(_S756.w) ;
    float3 tr_1 = tu_0 / _S757;
    float3 dv_1 = pv_0 / _S757;
    float3 _S758 = float3(0.0f) ;
    thread float3 lu_1 = _S758;
    thread float3 lv_1 = _S758;
    uint c_15 = _S752.begin_0 + tid_8;
    if(c_15 < (_S752.end_0))
    {
        drift_angular_0(c_15, _S756.xyz, tr_1, dv_1, &lu_1, &lv_1, &kernelContext_59);
    }
    group_sum3_0(tid_8, &lu_1, &lv_1, &kernelContext_59);
    if(tid_8 == 0U)
    {
        wide_store_0(_S751, 4U, lu_1, lv_1, &kernelContext_59);
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
    thread Quat_0 _S759 = c_16;
    float3 _S760 = rotate_0(&_S759, v_6);
    return _S760;
}

float3 inverse_rotate_1(const Quat_0 thread* q_11, float3 v_7)
{
    thread Quat_0 c_17;
    (&c_17)->w_1 = q_11->w_1;
    (&c_17)->x_2 = - q_11->x_2;
    (&c_17)->y_1 = - q_11->y_1;
    (&c_17)->z_0 = - q_11->z_0;
    thread Quat_0 _S761 = c_17;
    float3 _S762 = rotate_0(&_S761, v_7);
    return _S762;
}

float3 world_mul_0(const Quat_0 thread* q_12, float4 r0_1, float4 r1_1, float4 r2_1, float3 v_8)
{
    float3 _S763 = inverse_rotate_1(q_12, v_8);
    float3 _S764 = rotate_1(q_12, rows_mul_0(r0_1, r1_1, r2_1, _S763));
    return _S764;
}

void rigid_acceleration_0(const Island_natural_0 thread* isl_12, Rigid_0 thread* rg_4, float3 f_9, float3 t_9)
{
    float4 _S765 = float4(isl_12->inertia0_0) ;
    float4 _S766 = float4(isl_12->inertia1_0) ;
    float4 _S767 = float4(isl_12->inertia2_0) ;
    thread Quat_0 _S768 = rg_4->rot_1;
    float3 _S769 = world_mul_0(&_S768, _S765, _S766, _S767, rg_4->w_5);
    rg_4->a_10 = f_9 / float3((float4(isl_12->com_0) ).w) ;
    float4 _S770 = float4(isl_12->inv0_0) ;
    float4 _S771 = float4(isl_12->inv1_0) ;
    float4 _S772 = float4(isl_12->inv2_0) ;
    float3 _S773 = t_9 - cross(rg_4->w_5, _S769);
    thread Quat_0 _S774 = rg_4->rot_1;
    float3 _S775 = world_mul_0(&_S774, _S770, _S771, _S772, _S773);
    rg_4->alpha_0 = _S775;
    rg_4->torque_0 = t_9;
    return;
}

void rigid_acceleration_1(const Island_0 thread* isl_13, Rigid_0 thread* rg_5, float3 f_10, float3 t_10)
{
    thread Quat_0 _S776 = rg_5->rot_1;
    float3 _S777 = world_mul_0(&_S776, isl_13->inertia0_0, isl_13->inertia1_0, isl_13->inertia2_0, rg_5->w_5);
    rg_5->a_10 = f_10 / float3(isl_13->com_0.w) ;
    float3 _S778 = t_10 - cross(rg_5->w_5, _S777);
    thread Quat_0 _S779 = rg_5->rot_1;
    float3 _S780 = world_mul_0(&_S779, isl_13->inv0_0, isl_13->inv1_0, isl_13->inv2_0, _S778);
    rg_5->alpha_0 = _S780;
    rg_5->torque_0 = t_10;
    return;
}

Rigid_0 wide_rigid_frame_0(uint tid_9, const Island_natural_0 thread* isl_14, const WideGroup_0 thread* wg_1, KernelContext_0 thread* kernelContext_60)
{
    Rigid_0 _S781 = rigid_of_0(isl_14);
    thread Rigid_0 rg_6 = _S781;
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
    Rigid_0 _S782 = rigid_of_0(isl_15);
    thread Rigid_0 rg_7 = _S782;
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
    float3 _S783 = abs(x_12);
    *err_1 = *err_1 + (select(x_12, *sum_1, (abs(*sum_1)) >= _S783) - t_13 + select(*sum_1, x_12, (abs(*sum_1)) >= _S783));
    *sum_1 = t_13;
    return;
}

float3 turn_difference_0(float3 omega_0, float dt_9, float3 v_9)
{
    float _S784 = length(omega_0);
    float angle_1 = _S784 * dt_9;
    if(angle_1 < 1.00000000317107685e-30f)
    {
        return float3(0.0f) ;
    }
    float3 a_13 = omega_0 / float3(_S784) ;
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
    float4 _S785 = abs(x_13);
    *err_2 = *err_2 + (select(x_13, *sum_2, (abs(*sum_2)) >= _S785) - t_14 + select(*sum_2, x_13, (abs(*sum_2)) >= _S785));
    *sum_2 = t_14;
    return;
}

void quat_accumulate_0(Quat_0 thread* hi_1, float4 thread* lo_1, float4 x_14)
{
    thread Quat_0 _S786 = *hi_1;
    float4 _S787 = quat_vec_0(&_S786);
    thread float4 sum_3 = _S787;
    comp_add4_0(&sum_3, lo_1, x_14);
    float4 t_15 = sum_3 + *lo_1;
    *lo_1 = *lo_1 - (t_15 - sum_3);
    *hi_1 = quat_of_0(t_15);
    return;
}

void turn_left_0(Quat_0 thread* hi_2, float4 thread* lo_2, float3 omega_1, float dt_10)
{
    float _S788 = length(omega_1);
    float angle_3 = _S788 * dt_10;
    if(angle_3 < 1.00000000317107685e-30f)
    {
        return;
    }
    float4 d_12 = turn_minus_one_0(omega_1 / float3(_S788) , angle_3);
    thread Quat_0 dq_0;
    (&dq_0)->x_2 = d_12.x;
    (&dq_0)->y_1 = d_12.y;
    (&dq_0)->z_0 = d_12.z;
    (&dq_0)->w_1 = d_12.w;
    thread Quat_0 _S789 = dq_0;
    thread Quat_0 _S790 = *hi_2;
    Quat_0 _S791 = quat_mul_0(&_S789, &_S790);
    thread Quat_0 _S792 = _S791;
    float4 _S793 = quat_vec_0(&_S792);
    quat_accumulate_0(hi_2, lo_2, _S793);
    return;
}

void integrate_rigid_0(const Island_natural_0 thread* isl_16, Rigid_0 thread* rg_8, float dt_11)
{
    float3 _S794 = float3(dt_11) ;
    comp_add_0(&rg_8->l_1, &rg_8->l_err_0, rg_8->torque_0 * _S794);
    float3 l_2 = rg_8->l_1 + rg_8->l_err_0;
    comp_add_0(&rg_8->vel_0, &rg_8->vel_err_0, rg_8->a_10 * _S794);
    float3 vel_1 = rg_8->vel_0 + rg_8->vel_err_0;
    float4 _S795 = float4(isl_16->inv0_0) ;
    float4 _S796 = float4(isl_16->inv1_0) ;
    float4 _S797 = float4(isl_16->inv2_0) ;
    thread Quat_0 _S798 = rg_8->rot_1;
    float3 _S799 = world_mul_0(&_S798, _S795, _S796, _S797, l_2);
    float3 _S800 = vel_1 * _S794;
    float3 _S801 = (float4(isl_16->com_0) ).xyz;
    thread Quat_0 _S802 = rg_8->rot_1;
    float3 _S803 = rotate_0(&_S802, _S801);
    comp_add_0(&rg_8->pos_0, &rg_8->pos_err_0, _S800 - turn_difference_0(_S799, dt_11, _S803));
    turn_left_0(&rg_8->rot_1, &rg_8->rot_err_0, _S799, dt_11);
    thread Quat_0 _S804 = rg_8->rot_1;
    float3 _S805 = world_mul_0(&_S804, _S795, _S796, _S797, l_2);
    rg_8->w_5 = _S805;
    return;
}

void integrate_rigid_1(const Island_0 thread* isl_17, Rigid_0 thread* rg_9, float dt_12)
{
    float3 _S806 = float3(dt_12) ;
    comp_add_0(&rg_9->l_1, &rg_9->l_err_0, rg_9->torque_0 * _S806);
    float3 l_3 = rg_9->l_1 + rg_9->l_err_0;
    comp_add_0(&rg_9->vel_0, &rg_9->vel_err_0, rg_9->a_10 * _S806);
    float3 vel_2 = rg_9->vel_0 + rg_9->vel_err_0;
    float4 _S807 = isl_17->inv0_0;
    float4 _S808 = isl_17->inv1_0;
    float4 _S809 = isl_17->inv2_0;
    thread Quat_0 _S810 = rg_9->rot_1;
    float3 _S811 = world_mul_0(&_S810, isl_17->inv0_0, isl_17->inv1_0, isl_17->inv2_0, l_3);
    float3 _S812 = vel_2 * _S806;
    float3 _S813 = isl_17->com_0.xyz;
    thread Quat_0 _S814 = rg_9->rot_1;
    float3 _S815 = rotate_0(&_S814, _S813);
    comp_add_0(&rg_9->pos_0, &rg_9->pos_err_0, _S812 - turn_difference_0(_S811, dt_12, _S815));
    turn_left_0(&rg_9->rot_1, &rg_9->rot_err_0, _S811, dt_12);
    thread Quat_0 _S816 = rg_9->rot_1;
    float3 _S817 = world_mul_0(&_S816, _S807, _S808, _S809, l_3);
    rg_9->w_5 = _S817;
    return;
}

void drift_apply_0(uint c_18, float3 wcom_2, float3 tr_2, float3 phi_0, float3 dv_2, float3 dw_0, KernelContext_0 thread* kernelContext_62)
{
    float3 r_11 = (float4((kernelContext_62->chunks_0+c_18)->center_0) ).xyz - wcom_2;
    uint _S818 = 4U * c_18;
    *(kernelContext_62->state_0+_S818) = packed_float4(float4((float4(*(kernelContext_62->state_0+_S818)) ).xyz - (tr_2 + cross(phi_0, r_11)), (float4(*(kernelContext_62->state_0+_S818)) ).w)) ;
    uint _S819 = _S818 + 1U;
    *(kernelContext_62->state_0+_S819) = packed_float4(float4((float4(*(kernelContext_62->state_0+_S819)) ).xyz - phi_0, (float4(*(kernelContext_62->state_0+_S819)) ).w)) ;
    uint _S820 = _S818 + 2U;
    *(kernelContext_62->state_0+_S820) = packed_float4(float4((float4(*(kernelContext_62->state_0+_S820)) ).xyz - (dv_2 + cross(dw_0, r_11)), (float4(*(kernelContext_62->state_0+_S820)) ).w)) ;
    uint _S821 = _S818 + 3U;
    *(kernelContext_62->state_0+_S821) = packed_float4(float4((float4(*(kernelContext_62->state_0+_S821)) ).xyz - dw_0, (float4(*(kernelContext_62->state_0+_S821)) ).w)) ;
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
    thread Quat_0 _S822 = *hi_3;
    thread Quat_0 _S823 = dq_1;
    Quat_0 _S824 = quat_mul_0(&_S822, &_S823);
    thread Quat_0 _S825 = _S824;
    float4 _S826 = quat_vec_0(&_S825);
    quat_accumulate_0(hi_3, lo_3, _S826);
    return;
}

void drift_rigid_0(const Island_natural_0 thread* isl_18, Rigid_0 thread* rg_10, float3 tr_3, float3 phi_2, float3 dv_3, float3 dw_1)
{
    float3 wcom_3 = (float4(isl_18->wcom_0) ).xyz;
    Quat_0 rot_2 = rg_10->rot_1;
    float3 _S827 = tr_3 - cross(phi_2, wcom_3);
    thread Quat_0 _S828 = rg_10->rot_1;
    float3 _S829 = rotate_0(&_S828, _S827);
    comp_add_0(&rg_10->pos_0, &rg_10->pos_err_0, _S829);
    thread Quat_0 _S830 = rg_10->rot_1;
    float3 _S831 = inverse_rotate_0(&_S830, rg_10->w_5);
    float4 _S832 = float4(isl_18->inertia0_0) ;
    float4 _S833 = float4(isl_18->inertia1_0) ;
    float4 _S834 = float4(isl_18->inertia2_0) ;
    float3 _S835 = cross(phi_2, rows_mul_0(_S832, _S833, _S834, _S831)) - rows_mul_0(_S832, _S833, _S834, cross(phi_2, _S831));
    thread Quat_0 _S836 = rg_10->rot_1;
    float3 _S837 = rotate_0(&_S836, _S835);
    turn_right_0(&rg_10->rot_1, &rg_10->rot_err_0, phi_2);
    float3 _S838 = dv_3 + cross(dw_1, (float4(isl_18->com_0) ).xyz - wcom_3);
    thread Quat_0 _S839 = rot_2;
    float3 _S840 = rotate_0(&_S839, _S838);
    comp_add_0(&rg_10->vel_0, &rg_10->vel_err_0, _S840);
    thread Quat_0 _S841 = rot_2;
    float3 _S842 = rotate_0(&_S841, dw_1);
    rg_10->w_5 = rg_10->w_5 + _S842;
    thread Quat_0 _S843 = rg_10->rot_1;
    float3 _S844 = world_mul_0(&_S843, _S832, _S833, _S834, _S842);
    comp_add_0(&rg_10->l_1, &rg_10->l_err_0, _S837 + _S844);
    return;
}

void drift_rigid_1(const Island_0 thread* isl_19, Rigid_0 thread* rg_11, float3 tr_4, float3 phi_3, float3 dv_4, float3 dw_2)
{
    float3 wcom_4 = isl_19->wcom_0.xyz;
    Quat_0 rot_3 = rg_11->rot_1;
    float3 _S845 = tr_4 - cross(phi_3, wcom_4);
    thread Quat_0 _S846 = rg_11->rot_1;
    float3 _S847 = rotate_0(&_S846, _S845);
    comp_add_0(&rg_11->pos_0, &rg_11->pos_err_0, _S847);
    thread Quat_0 _S848 = rg_11->rot_1;
    float3 _S849 = inverse_rotate_0(&_S848, rg_11->w_5);
    float4 _S850 = isl_19->inertia0_0;
    float4 _S851 = isl_19->inertia1_0;
    float4 _S852 = isl_19->inertia2_0;
    float3 _S853 = cross(phi_3, rows_mul_0(isl_19->inertia0_0, isl_19->inertia1_0, isl_19->inertia2_0, _S849)) - rows_mul_0(isl_19->inertia0_0, isl_19->inertia1_0, isl_19->inertia2_0, cross(phi_3, _S849));
    thread Quat_0 _S854 = rg_11->rot_1;
    float3 _S855 = rotate_0(&_S854, _S853);
    turn_right_0(&rg_11->rot_1, &rg_11->rot_err_0, phi_3);
    float3 _S856 = dv_4 + cross(dw_2, isl_19->com_0.xyz - wcom_4);
    thread Quat_0 _S857 = rot_3;
    float3 _S858 = rotate_0(&_S857, _S856);
    comp_add_0(&rg_11->vel_0, &rg_11->vel_err_0, _S858);
    thread Quat_0 _S859 = rot_3;
    float3 _S860 = rotate_0(&_S859, dw_2);
    rg_11->w_5 = rg_11->w_5 + _S860;
    thread Quat_0 _S861 = rg_11->rot_1;
    float3 _S862 = world_mul_0(&_S861, _S850, _S851, _S852, _S860);
    comp_add_0(&rg_11->l_1, &rg_11->l_err_0, _S855 + _S862);
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
    threadgroup array<uint, int(4096)> g_label_7;
    (&kernelContext_63)->g_label_0 = &g_label_7;
    threadgroup uint g_changed_7;
    (&kernelContext_63)->g_changed_0 = &g_changed_7;
    threadgroup uint g_halt_7;
    (&kernelContext_63)->g_halt_0 = &g_halt_7;
    threadgroup uint g_run_7;
    (&kernelContext_63)->g_run_0 = &g_run_7;
    threadgroup uint g_flag_7;
    (&kernelContext_63)->g_flag_0 = &g_flag_7;
    threadgroup array<uint, int(1024)> g_mode_7;
    (&kernelContext_63)->g_mode_0 = &g_mode_7;
    uint tid_11 = thread_4.x;
    uint _S863 = group_4.x;
    WideGroup_0 _S864 = wide_group_0(params_7->wide_chunk_table_0, _S863, &kernelContext_63);
    thread Island_natural_0 _S865 = *((&kernelContext_63)->islands_0+_S864.island_3);
    uint _S866 = (uint4((&_S865)->info_0) ).x;
    bool _S867;
    if((_S866 & 1U) != 0U)
    {
        _S867 = true;
    }
    else
    {
        bool _S868 = wide_enter_1(tid_11, _S864.island_3, &kernelContext_63);
        _S867 = !_S868;
    }
    if(_S867)
    {
        return;
    }
    if((_S866 & 16U) != 0U)
    {
        if(_S863 != (_S864.first_0))
        {
            return;
        }
        thread WideGroup_0 _S869 = _S864;
        Rigid_0 _S870 = wide_rigid_frame_0(tid_11, &_S865, &_S869, &kernelContext_63);
        thread Rigid_0 rs_0 = _S870;
        if(tid_11 != 0U)
        {
            _S867 = true;
        }
        else
        {
            _S867 = (_S866 & 2U) != 0U;
        }
        if(_S867)
        {
            return;
        }
        integrate_rigid_0(&_S865, &rs_0, (&kernelContext_63)->params_0->dt_0);
        thread Quat_0 _S871 = (&rs_0)->rot_1;
        float4 _S872 = quat_vec_0(&_S871);
        ((&kernelContext_63)->islands_0+_S864.island_3)->rotation_0 = packed_float4(_S872) ;
        ((&kernelContext_63)->islands_0+_S864.island_3)->rotation_err_0 = packed_float4((&rs_0)->rot_err_0) ;
        ((&kernelContext_63)->islands_0+_S864.island_3)->position_0 = packed_float4(float4((&rs_0)->pos_0, 0.0f)) ;
        ((&kernelContext_63)->islands_0+_S864.island_3)->position_err_0 = packed_float4(float4((&rs_0)->pos_err_0, 0.0f)) ;
        ((&kernelContext_63)->islands_0+_S864.island_3)->velocity_0 = packed_float4(float4((&rs_0)->vel_0, 0.0f)) ;
        ((&kernelContext_63)->islands_0+_S864.island_3)->velocity_err_0 = packed_float4(float4((&rs_0)->vel_err_0, 0.0f)) ;
        ((&kernelContext_63)->islands_0+_S864.island_3)->angular_velocity_0 = packed_float4(float4((&rs_0)->w_5, 0.0f)) ;
        ((&kernelContext_63)->islands_0+_S864.island_3)->momentum_0 = packed_float4(float4((&rs_0)->l_1, 0.0f)) ;
        ((&kernelContext_63)->islands_0+_S864.island_3)->momentum_err_0 = packed_float4(float4((&rs_0)->l_err_0, 0.0f)) ;
        return;
    }
    thread float3 tu_1;
    thread float3 pv_1;
    wide_partials_0(tid_11, _S864.first_0, (&_S865)->wide_groups_0, 2U, &tu_1, &pv_1, &kernelContext_63);
    thread float3 lu_2;
    thread float3 lv_2;
    wide_partials_0(tid_11, _S864.first_0, (&_S865)->wide_groups_0, 4U, &lu_2, &lv_2, &kernelContext_63);
    float4 _S873 = float4((&_S865)->wcom_0) ;
    float3 _S874 = float3(_S873.w) ;
    float3 tr_5 = tu_1 / _S874;
    float3 dv_5 = pv_1 / _S874;
    float4 _S875 = float4((&_S865)->winv0_0) ;
    float4 _S876 = float4((&_S865)->winv1_0) ;
    float4 _S877 = float4((&_S865)->winv2_0) ;
    float3 phi_4 = rows_mul_0(_S875, _S876, _S877, lu_2);
    float3 dw_3 = rows_mul_0(_S875, _S876, _S877, lv_2);
    uint c_19 = _S864.begin_0 + tid_11;
    if(c_19 < (_S864.end_0))
    {
        drift_apply_0(c_19, _S873.xyz, tr_5, phi_4, dv_5, dw_3, &kernelContext_63);
    }
    if(_S863 != (_S864.first_0))
    {
        return;
    }
    thread WideGroup_0 _S878 = _S864;
    Rigid_0 _S879 = wide_rigid_frame_0(tid_11, &_S865, &_S878, &kernelContext_63);
    thread Rigid_0 rg_12 = _S879;
    if(tid_11 != 0U)
    {
        return;
    }
    if(!((_S866 & 2U) != 0U))
    {
        integrate_rigid_0(&_S865, &rg_12, (&kernelContext_63)->params_0->dt_0);
        drift_rigid_0(&_S865, &rg_12, tr_5, phi_4, dv_5, dw_3);
    }
    thread Quat_0 _S880 = (&rg_12)->rot_1;
    float4 _S881 = quat_vec_0(&_S880);
    ((&kernelContext_63)->islands_0+_S864.island_3)->rotation_0 = packed_float4(_S881) ;
    ((&kernelContext_63)->islands_0+_S864.island_3)->rotation_err_0 = packed_float4((&rg_12)->rot_err_0) ;
    ((&kernelContext_63)->islands_0+_S864.island_3)->position_0 = packed_float4(float4((&rg_12)->pos_0, 0.0f)) ;
    ((&kernelContext_63)->islands_0+_S864.island_3)->position_err_0 = packed_float4(float4((&rg_12)->pos_err_0, 0.0f)) ;
    ((&kernelContext_63)->islands_0+_S864.island_3)->velocity_0 = packed_float4(float4((&rg_12)->vel_0, 0.0f)) ;
    ((&kernelContext_63)->islands_0+_S864.island_3)->velocity_err_0 = packed_float4(float4((&rg_12)->vel_err_0, 0.0f)) ;
    ((&kernelContext_63)->islands_0+_S864.island_3)->angular_velocity_0 = packed_float4(float4((&rg_12)->w_5, 0.0f)) ;
    ((&kernelContext_63)->islands_0+_S864.island_3)->momentum_0 = packed_float4(float4((&rg_12)->l_1, 0.0f)) ;
    ((&kernelContext_63)->islands_0+_S864.island_3)->momentum_err_0 = packed_float4(float4((&rg_12)->l_err_0, 0.0f)) ;
    return;
}

bool island_connected_0(uint tid_12, const Island_0 thread* isl_20, KernelContext_0 thread* kernelContext_64)
{
    uint _S882 = isl_20->range_0.x;
    uint n_10 = isl_20->range_0.y - _S882;
    if(n_10 > 4096U)
    {
        return false;
    }
    uint c_20 = tid_12;
    for(;;)
    {
        if(c_20 < n_10)
        {
        }
        else
        {
            break;
        }
        (*kernelContext_64->g_label_0)[c_20] = c_20;
        c_20 = c_20 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    bool converged_0 = false;
    uint pass_0 = 0U;
    for(;;)
    {
        if(pass_0 <= n_10)
        {
        }
        else
        {
            break;
        }
        if(tid_12 == 0U)
        {
            *kernelContext_64->g_changed_0 = 0U;
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);
        c_20 = tid_12;
        for(;;)
        {
            if(c_20 < n_10)
            {
            }
            else
            {
                break;
            }
            uint gc_0 = _S882 + c_20;
            uint _S883 = kernelContext_64->index_0[gc_0];
            uint l_4 = (*kernelContext_64->g_label_0)[c_20];
            uint e_2 = _S883;
            for(;;)
            {
                if(e_2 < (kernelContext_64->index_0)[gc_0 + 1U])
                {
                }
                else
                {
                    break;
                }
                uint entry_1 = kernelContext_64->index_0[e_2];
                uint bond_0 = entry_1 >> 1U;
                bool _S884 = ((float4((kernelContext_64->bonds_0+bond_0)->law_0.stiff1_0) ).w) != 0.0f;
                thread JointState_0 _S885 = (kernelContext_64->bond_dyn_0+bond_0)->js_0;
                bool _S886 = connected_0(&_S885, _S884);
                if(!_S886)
                {
                    e_2 = e_2 + 1U;
                    continue;
                }
                uint other_0;
                if((entry_1 & 1U) == 0U)
                {
                    other_0 = (uint4((kernelContext_64->bonds_0+bond_0)->law_0.ids_0) ).z;
                }
                else
                {
                    other_0 = (uint4((kernelContext_64->bonds_0+bond_0)->law_0.ids_0) ).y;
                }
                l_4 = min(l_4, (*kernelContext_64->g_label_0)[other_0 - _S882]);
                e_2 = e_2 + 1U;
            }
            uint _S887 = min(l_4, (*kernelContext_64->g_label_0)[l_4]);
            if(_S887 < (*kernelContext_64->g_label_0)[c_20])
            {
                (*kernelContext_64->g_label_0)[c_20] = _S887;
                *kernelContext_64->g_changed_0 = 1U;
            }
            c_20 = c_20 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);
        bool converged_1 = (*kernelContext_64->g_changed_0) == 0U;
        threadgroup_barrier(mem_flags::mem_threadgroup);
        if(converged_1)
        {
            converged_0 = converged_1;
            break;
        }
        uint _S888 = pass_0 + 1U;
        converged_0 = converged_1;
        pass_0 = _S888;
    }
    if(!converged_0)
    {
        return false;
    }
    if(tid_12 == 0U)
    {
        *kernelContext_64->g_changed_0 = 0U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    c_20 = tid_12;
    for(;;)
    {
        if(c_20 < n_10)
        {
        }
        else
        {
            break;
        }
        if(((*kernelContext_64->g_label_0)[c_20]) != 0U)
        {
            *kernelContext_64->g_changed_0 = 1U;
        }
        c_20 = c_20 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    return (*kernelContext_64->g_changed_0) == 0U;
}

void write_probe_0(uint slot_2, uint k_16, float value_0, KernelContext_0 thread* kernelContext_65)
{
    uint at_3 = kernelContext_65->params_0->probe_base_0 * 4U + slot_2 * kernelContext_65->params_0->probe_stride_0 + k_16;
    thread float4 v_10 = float4(*(kernelContext_65->scratch_0+at_3 / 4U)) ;
    v_10[at_3 % 4U] = value_0;
    *(kernelContext_65->scratch_0+at_3 / 4U) = packed_float4(v_10) ;
    return;
}

void record_probes_0(const Island_0 thread* isl_21, const Rigid_0 thread* rg_13, uint k_17, KernelContext_0 thread* kernelContext_66)
{
    uint4 _S889 = isl_21->probes_0;
    uint at_4 = isl_21->probes_0.x;
    for(;;)
    {
        if(at_4 < (_S889.y))
        {
        }
        else
        {
            break;
        }
        uint4 info_3 = (as_type<uint4>((float4(*(kernelContext_66->loads_0+at_4)) )));
        float4 _S890 = float4(*(kernelContext_66->loads_0+(at_4 + 1U))) ;
        float4 _S891 = float4(*(kernelContext_66->loads_0+(at_4 + 2U))) ;
        float4 _S892 = float4(*(kernelContext_66->loads_0+(at_4 + 3U))) ;
        uint kind_4 = info_3.x;
        uint i_11 = info_3.y;
        float value_1;
        if(kind_4 == 0U)
        {
            float3 small_0 = (float4(*(kernelContext_66->state_0+4U * i_11)) ).xyz + float3(_S890.w, _S891.w, _S892.w);
            float3 _S893 = rg_13->pos_0 - _S891.xyz;
            float3 _S894 = rotate_0(&rg_13->rot_1, (float4((kernelContext_66->chunks_0+i_11)->center_0) ).xyz);
            float3 _S895 = _S893 + _S894;
            float3 _S896 = rg_13->pos_err_0 - _S892.xyz;
            float3 _S897 = rotate_0(&rg_13->rot_1, small_0);
            value_1 = dot(_S895 + (_S896 + _S897), _S890.xyz);
        }
        else
        {
            if(kind_4 == 1U)
            {
                uint _S898 = 4U * i_11;
                float3 _S899 = rotate_0(&rg_13->rot_1, (float4((kernelContext_66->chunks_0+i_11)->center_0) ).xyz + (float4(*(kernelContext_66->state_0+_S898)) ).xyz - isl_21->com_0.xyz);
                float3 _S900 = rg_13->vel_0 + rg_13->vel_err_0 + cross(rg_13->w_5, _S899);
                float3 _S901 = rotate_0(&rg_13->rot_1, (float4(*(kernelContext_66->state_0+(_S898 + 2U))) ).xyz);
                value_1 = dot(_S900 + _S901, _S890.xyz);
            }
            else
            {
                if(kind_4 == 2U)
                {
                    uint _S902 = 3U * i_11;
                    float3 f_13 = (float4(*(kernelContext_66->scratch_0+_S902)) ).xyz;
                    bool _S903 = (info_3.z) == 0U;
                    float3 mc_0;
                    if(_S903)
                    {
                        mc_0 = (float4(*(kernelContext_66->scratch_0+(_S902 + 1U))) ).xyz;
                    }
                    else
                    {
                        mc_0 = (float4(*(kernelContext_66->scratch_0+(_S902 + 2U))) ).xyz;
                    }
                    float3 fc_4;
                    if(_S903)
                    {
                        fc_4 = f_13;
                    }
                    else
                    {
                        fc_4 = - f_13;
                    }
                    value_1 = dot(fc_4, _S890.xyz) + dot(mc_0, _S891.xyz);
                }
                else
                {
                    uint _S904 = 4U * i_11;
                    float3 _S905 = rotate_0(&rg_13->rot_1, float3((float4(*(kernelContext_66->state_0+(_S904 + 1U))) ).w, (float4(*(kernelContext_66->state_0+(_S904 + 2U))) ).w, (float4(*(kernelContext_66->state_0+(_S904 + 3U))) ).w));
                    value_1 = dot(_S905, _S890.xyz);
                }
            }
        }
        write_probe_0(info_3.w, k_17, value_1, kernelContext_66);
        at_4 = at_4 + 4U;
    }
    return;
}

void contact_split_at_0(uint at_5, KernelContext_0 thread* kernelContext_67)
{
    uint previous_1 = (uint4((kernelContext_67->islands_0+kernelContext_67->params_0->halt_index_0)->info_0) ).y;
    uint _S906;
    if(previous_1 == 0U)
    {
        _S906 = at_5;
    }
    else
    {
        _S906 = min(previous_1, at_5);
    }
    (kernelContext_67->islands_0+kernelContext_67->params_0->halt_index_0)->info_0[int(1)] = _S906;
    return;
}

[[kernel]] void wide_end(uint3 group_5 [[threadgroup_position_in_grid]], uint3 thread_5 [[thread_position_in_threadgroup]], Params_0 constant* params_8 [[buffer(0)]], Island_natural_0 device* islands_8 [[buffer(9)]], uint device* index_8 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_8 [[buffer(3)]], packed_float4 device* state_10 [[buffer(6)]], packed_float4 device* scratch_8 [[buffer(8)]], packed_float4 device* contact_state_8 [[buffer(11)]], packed_float4 device* loads_8 [[buffer(5)]], Impactor_natural_0 device* impactors_8 [[buffer(10)]], BondStatic_natural_0 device* bonds_8 [[buffer(2)]], MaterialTable_0 constant* materials_8 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_8 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_68;
    (&kernelContext_68)->params_0 = params_8;
    (&kernelContext_68)->islands_0 = islands_8;
    (&kernelContext_68)->index_0 = index_8;
    (&kernelContext_68)->chunks_0 = chunks_8;
    (&kernelContext_68)->state_0 = state_10;
    (&kernelContext_68)->scratch_0 = scratch_8;
    (&kernelContext_68)->contact_state_0 = contact_state_8;
    (&kernelContext_68)->loads_0 = loads_8;
    (&kernelContext_68)->impactors_0 = impactors_8;
    (&kernelContext_68)->bonds_0 = bonds_8;
    (&kernelContext_68)->materials_0 = materials_8;
    (&kernelContext_68)->bond_dyn_0 = bond_dyn_8;
    threadgroup array<float4, int(32)> g_part_a_8;
    (&kernelContext_68)->g_part_a_0 = &g_part_a_8;
    threadgroup array<float4, int(32)> g_part_b_8;
    (&kernelContext_68)->g_part_b_0 = &g_part_b_8;
    threadgroup array<uint, int(5)> g_seen_8;
    (&kernelContext_68)->g_seen_0 = &g_seen_8;
    threadgroup uint g_wide_run_8;
    (&kernelContext_68)->g_wide_run_0 = &g_wide_run_8;
    threadgroup array<uint, int(4096)> g_label_8;
    (&kernelContext_68)->g_label_0 = &g_label_8;
    threadgroup uint g_changed_8;
    (&kernelContext_68)->g_changed_0 = &g_changed_8;
    threadgroup uint g_halt_8;
    (&kernelContext_68)->g_halt_0 = &g_halt_8;
    threadgroup uint g_run_8;
    (&kernelContext_68)->g_run_0 = &g_run_8;
    threadgroup uint g_flag_8;
    (&kernelContext_68)->g_flag_0 = &g_flag_8;
    threadgroup array<uint, int(1024)> g_mode_8;
    (&kernelContext_68)->g_mode_0 = &g_mode_8;
    uint tid_13 = thread_5.x;
    uint _S907 = group_5.x;
    WideGroup_0 _S908 = wide_group_0(params_8->wide_chunk_table_0, _S907, &kernelContext_68);
    if(_S907 != (_S908.first_0))
    {
        return;
    }
    Island_natural_0 device* _S909 = (&kernelContext_68)->islands_0+_S908.island_3;
    thread Island_natural_0 _S910 = *_S909;
    uint4 _S911 = uint4((&_S910)->info_0) ;
    float4 _S912 = float4((&_S910)->com_0) ;
    float4 _S913 = float4((&_S910)->inertia0_0) ;
    float4 _S914 = float4((&_S910)->inertia1_0) ;
    float4 _S915 = float4((&_S910)->inertia2_0) ;
    float4 _S916 = float4((&_S910)->inv0_0) ;
    float4 _S917 = float4((&_S910)->inv1_0) ;
    float4 _S918 = float4((&_S910)->inv2_0) ;
    float4 _S919 = float4((&_S910)->wcom_0) ;
    float4 _S920 = float4((&_S910)->winv0_0) ;
    float4 _S921 = float4((&_S910)->winv1_0) ;
    float4 _S922 = float4((&_S910)->winv2_0) ;
    float4 _S923 = float4((&_S910)->rotation_0) ;
    float4 _S924 = float4((&_S910)->position_0) ;
    float4 _S925 = float4((&_S910)->position_err_0) ;
    float4 _S926 = float4((&_S910)->velocity_0) ;
    float4 _S927 = float4((&_S910)->velocity_err_0) ;
    float4 _S928 = float4((&_S910)->angular_velocity_0) ;
    uint4 _S929 = uint4((&_S910)->probes_0) ;
    float4 _S930 = float4((&_S910)->energy_0) ;
    float4 _S931 = float4((&_S910)->rotation_err_0) ;
    float4 _S932 = float4((&_S910)->momentum_0) ;
    float4 _S933 = float4((&_S910)->momentum_err_0) ;
    thread Island_0 isl_22;
    (&isl_22)->range_0 = uint4((&_S910)->range_0) ;
    (&isl_22)->info_0 = _S911;
    (&isl_22)->com_0 = _S912;
    (&isl_22)->inertia0_0 = _S913;
    (&isl_22)->inertia1_0 = _S914;
    (&isl_22)->inertia2_0 = _S915;
    (&isl_22)->inv0_0 = _S916;
    (&isl_22)->inv1_0 = _S917;
    (&isl_22)->inv2_0 = _S918;
    (&isl_22)->wcom_0 = _S919;
    (&isl_22)->winv0_0 = _S920;
    (&isl_22)->winv1_0 = _S921;
    (&isl_22)->winv2_0 = _S922;
    (&isl_22)->rotation_0 = _S923;
    (&isl_22)->position_0 = _S924;
    (&isl_22)->position_err_0 = _S925;
    (&isl_22)->velocity_0 = _S926;
    (&isl_22)->velocity_err_0 = _S927;
    (&isl_22)->angular_velocity_0 = _S928;
    (&isl_22)->done_0 = (&_S910)->done_0;
    (&isl_22)->coverage_0 = (&_S910)->coverage_0;
    (&isl_22)->wide_groups_0 = (&_S910)->wide_groups_0;
    (&isl_22)->done_pad_0 = (&_S910)->done_pad_0;
    (&isl_22)->probes_0 = _S929;
    (&isl_22)->energy_0 = _S930;
    (&isl_22)->rotation_err_0 = _S931;
    (&isl_22)->momentum_0 = _S932;
    (&isl_22)->momentum_err_0 = _S933;
    _S910 = *_S909;
    bool _S934 = wide_enter_0(tid_13, &_S910, &kernelContext_68);
    if(!_S934)
    {
        return;
    }
    thread float3 work_1;
    thread float3 flags_2;
    wide_partials_0(tid_13, _S908.first_0, (&isl_22)->wide_groups_0, 6U, &work_1, &flags_2, &kernelContext_68);
    bool halt_0 = (((&isl_22)->info_0.z) & 2U) != 0U;
    bool whole_0;
    if(halt_0)
    {
        thread Island_0 _S935 = isl_22;
        bool _S936 = island_connected_0(tid_13, &_S935, &kernelContext_68);
        whole_0 = _S936;
    }
    else
    {
        whole_0 = false;
    }
    if(tid_13 != 0U)
    {
        return;
    }
    bool halt_1;
    if(whole_0)
    {
        (&isl_22)->info_0.z = ((&isl_22)->info_0.z) & 4294967293U;
        (&isl_22)->coverage_0 = ((&isl_22)->coverage_0) | 128U;
        halt_1 = false;
    }
    else
    {
        halt_1 = halt_0;
    }
    thread Island_0 _S937 = isl_22;
    uint _S938 = wide_step_2(&_S937, &kernelContext_68);
    if(((&isl_22)->probes_0.y) > ((&isl_22)->probes_0.x))
    {
        thread Island_0 _S939 = isl_22;
        Rigid_0 _S940 = rigid_of_1(&_S939);
        thread Island_0 _S941 = isl_22;
        thread Rigid_0 _S942 = _S940;
        record_probes_0(&_S941, &_S942, _S938, &kernelContext_68);
    }
    if(halt_1)
    {
        whole_0 = (((&isl_22)->info_0.x) & 4U) != 0U;
    }
    else
    {
        whole_0 = false;
    }
    if(whole_0)
    {
        contact_split_at_0((&isl_22)->info_0.w + 1U, &kernelContext_68);
    }
    float _S943 = work_1.x;
    thread float _S944 = (&isl_22)->energy_0.x;
    thread float _S945 = (&isl_22)->energy_0.y;
    comp_add1_0(&_S944, &_S945, _S943);
    (&isl_22)->energy_0.x = _S944;
    (&isl_22)->energy_0.y = _S945 + work_1.y;
    (&isl_22)->done_0 = (&isl_22)->done_0 + 1U;
    (&isl_22)->info_0.y = (&isl_22)->info_0.y - 1U;
    (&isl_22)->info_0.w = (&isl_22)->info_0.w + 1U;
    if(halt_1)
    {
        (&isl_22)->info_0.z = (((&isl_22)->info_0.z) & 4294967293U) | 1U;
    }
    uint _S946;
    if(halt_1)
    {
        _S946 = 128U;
    }
    else
    {
        _S946 = 0U;
    }
    uint _S947 = 256U | _S946;
    if(((&isl_22)->probes_0.y) > ((&isl_22)->probes_0.x))
    {
        _S946 = 262144U;
    }
    else
    {
        _S946 = 0U;
    }
    uint _S948 = _S947 | _S946;
    if((((&isl_22)->info_0.x) & 4U) != 0U)
    {
        _S946 = 524288U;
    }
    else
    {
        _S946 = 0U;
    }
    uint _S949 = _S948 | _S946;
    if((flags_2.x) > 0.0f)
    {
        _S946 = 32768U;
    }
    else
    {
        _S946 = 0U;
    }
    uint _S950 = _S949 | _S946;
    if((flags_2.y) > 0.0f)
    {
        _S946 = 65536U;
    }
    else
    {
        _S946 = 0U;
    }
    uint _S951 = _S950 | _S946;
    if((flags_2.z) > 0.0f)
    {
        _S946 = 131072U;
    }
    else
    {
        _S946 = 0U;
    }
    (&isl_22)->coverage_0 = ((&isl_22)->coverage_0) | (_S951 | _S946);
    Island_natural_0 device* _S952 = (&kernelContext_68)->islands_0+_S908.island_3;
    _S952->range_0 = packed_uint4(isl_22.range_0) ;
    _S952->info_0 = packed_uint4(isl_22.info_0) ;
    _S952->com_0 = packed_float4(isl_22.com_0) ;
    _S952->inertia0_0 = packed_float4(isl_22.inertia0_0) ;
    _S952->inertia1_0 = packed_float4(isl_22.inertia1_0) ;
    _S952->inertia2_0 = packed_float4(isl_22.inertia2_0) ;
    _S952->inv0_0 = packed_float4(isl_22.inv0_0) ;
    _S952->inv1_0 = packed_float4(isl_22.inv1_0) ;
    _S952->inv2_0 = packed_float4(isl_22.inv2_0) ;
    _S952->wcom_0 = packed_float4(isl_22.wcom_0) ;
    _S952->winv0_0 = packed_float4(isl_22.winv0_0) ;
    _S952->winv1_0 = packed_float4(isl_22.winv1_0) ;
    _S952->winv2_0 = packed_float4(isl_22.winv2_0) ;
    _S952->rotation_0 = packed_float4(isl_22.rotation_0) ;
    _S952->position_0 = packed_float4(isl_22.position_0) ;
    _S952->position_err_0 = packed_float4(isl_22.position_err_0) ;
    _S952->velocity_0 = packed_float4(isl_22.velocity_0) ;
    _S952->velocity_err_0 = packed_float4(isl_22.velocity_err_0) ;
    _S952->angular_velocity_0 = packed_float4(isl_22.angular_velocity_0) ;
    _S952->done_0 = isl_22.done_0;
    _S952->coverage_0 = isl_22.coverage_0;
    _S952->wide_groups_0 = isl_22.wide_groups_0;
    _S952->done_pad_0 = isl_22.done_pad_0;
    _S952->probes_0 = packed_uint4(isl_22.probes_0) ;
    _S952->energy_0 = packed_float4(isl_22.energy_0) ;
    _S952->rotation_err_0 = packed_float4(isl_22.rotation_err_0) ;
    _S952->momentum_0 = packed_float4(isl_22.momentum_0) ;
    _S952->momentum_err_0 = packed_float4(isl_22.momentum_err_0) ;
    return;
}

uint sv_0(uint c_21, uint slot_3, KernelContext_0 thread* kernelContext_69)
{
    return kernelContext_69->params_0->statics_base_0 + 23U * c_21 + slot_3;
}

void project_load_slot_0(uint tid_14, const Island_natural_0 thread* isl_23, uint slot_4, KernelContext_0 thread* kernelContext_70)
{
    uint _S953;
    float3 _S954 = float3(0.0f) ;
    thread float3 net_f_0 = _S954;
    thread float3 net_m_0 = _S954;
    uint4 _S955 = uint4(isl_23->range_0) ;
    uint _S956 = _S955.x + tid_14;
    uint c_22 = _S956;
    for(;;)
    {
        uint _S957 = _S955.y;
        _S953 = _S957;
        if(c_22 < _S957)
        {
        }
        else
        {
            break;
        }
        uint _S958 = sv_0(c_22, slot_4, kernelContext_70);
        float3 fi_0 = (float4(*(kernelContext_70->scratch_0+_S958)) ).xyz;
        net_f_0 = net_f_0 + fi_0;
        float3 _S959 = cross((float4((kernelContext_70->chunks_0+c_22)->center_0) ).xyz - (float4(isl_23->com_0) ).xyz, fi_0);
        uint _S960 = sv_0(c_22, slot_4 + 1U, kernelContext_70);
        net_m_0 = net_m_0 + (_S959 + (float4(*(kernelContext_70->scratch_0+_S960)) ).xyz);
        c_22 = c_22 + 256U;
    }
    group_sum3_0(tid_14, &net_f_0, &net_m_0, kernelContext_70);
    float4 _S961 = float4(isl_23->com_0) ;
    float3 _S962 = net_f_0 / float3(_S961.w) ;
    float3 _S963 = rows_mul_0(float4(isl_23->inv0_0) , float4(isl_23->inv1_0) , float4(isl_23->inv2_0) , net_m_0);
    c_22 = _S956;
    for(;;)
    {
        if(c_22 < _S953)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_natural_0 device* _S964 = kernelContext_70->chunks_0+c_22;
        float4 _S965 = float4(_S964->center_0) ;
        float3 r_12 = _S965.xyz - _S961.xyz;
        uint _S966 = sv_0(c_22, slot_4, kernelContext_70);
        *(kernelContext_70->scratch_0+_S966) = packed_float4(float4((float4(*(kernelContext_70->scratch_0+_S966)) ).xyz - (_S962 + cross(_S963, r_12)) * float3(_S965.w) , 0.0f)) ;
        uint _S967 = sv_0(c_22, slot_4 + 1U, kernelContext_70);
        *(kernelContext_70->scratch_0+_S967) = packed_float4(float4((float4(*(kernelContext_70->scratch_0+_S967)) ).xyz - rows_mul_0(float4(_S964->inertia0_1) , float4(_S964->inertia1_1) , float4(_S964->inertia2_1) , _S963), 0.0f)) ;
        c_22 = c_22 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    return;
}

float island_dot_0(uint tid_15, uint c0_0, uint c1_0, uint sa_2, uint sb_2, KernelContext_0 thread* kernelContext_71)
{
    float4 _S968 = float4(0.0f) ;
    thread float4 acc_0 = _S968;
    thread float4 unused_2 = _S968;
    uint c_23 = c0_0 + tid_15;
    for(;;)
    {
        if(c_23 < c1_0)
        {
        }
        else
        {
            break;
        }
        uint _S969 = sv_0(c_23, sa_2, kernelContext_71);
        float3 _S970 = (float4(*(kernelContext_71->scratch_0+_S969)) ).xyz;
        uint _S971 = sv_0(c_23, sb_2, kernelContext_71);
        float _S972 = dot(_S970, (float4(*(kernelContext_71->scratch_0+_S971)) ).xyz);
        uint _S973 = sv_0(c_23, sa_2 + 1U, kernelContext_71);
        float3 _S974 = (float4(*(kernelContext_71->scratch_0+_S973)) ).xyz;
        uint _S975 = sv_0(c_23, sb_2 + 1U, kernelContext_71);
        acc_0.x = acc_0.x + (_S972 + dot(_S974, (float4(*(kernelContext_71->scratch_0+_S975)) ).xyz));
        c_23 = c_23 + 256U;
    }
    group_sum2_0(tid_15, &acc_0, &unused_2, kernelContext_71);
    return acc_0.x;
}

void static_kinematics_0(uint _S976, float3 thread* _S977, float3 thread* _S978, KernelContext_0 thread* kernelContext_72)
{
    BondStatic_natural_0 device* _S979 = kernelContext_72->bonds_0+_S976;
    uint4 _S980 = uint4(_S979->law_0.ids_0) ;
    uint ca_1 = _S980.y;
    uint cb_1 = _S980.z;
    uint _S981 = 4U * cb_1;
    uint _S982 = 4U * ca_1;
    float3 _S983 = (float4(*(kernelContext_72->state_0+_S981)) ).xyz - (float4(*(kernelContext_72->state_0+_S982)) ).xyz;
    uint _S984 = sv_0(cb_1, 21U, kernelContext_72);
    float3 _S985 = (float4(*(kernelContext_72->scratch_0+_S984)) ).xyz;
    uint _S986 = sv_0(ca_1, 21U, kernelContext_72);
    float3 du_0 = _S983 + (_S985 - (float4(*(kernelContext_72->scratch_0+_S986)) ).xyz);
    uint _S987 = _S981 + 1U;
    uint _S988 = _S982 + 1U;
    float3 _S989 = (float4(*(kernelContext_72->state_0+_S987)) ).xyz - (float4(*(kernelContext_72->state_0+_S988)) ).xyz;
    uint _S990 = sv_0(cb_1, 22U, kernelContext_72);
    float3 _S991 = (float4(*(kernelContext_72->scratch_0+_S990)) ).xyz;
    uint _S992 = sv_0(ca_1, 22U, kernelContext_72);
    float3 dth_0 = _S989 + (_S991 - (float4(*(kernelContext_72->scratch_0+_S992)) ).xyz);
    float3 _S993 = to_local_0(_S976, du_0 + (cross((float4(*(kernelContext_72->state_0+_S987)) ).xyz + (float4(*(kernelContext_72->scratch_0+_S990)) ).xyz, (float4(_S979->rb_0) ).xyz) - cross((float4(*(kernelContext_72->state_0+_S988)) ).xyz + (float4(*(kernelContext_72->scratch_0+_S992)) ).xyz, (float4(_S979->ra_0) ).xyz)), kernelContext_72);
    *_S977 = _S993;
    float3 _S994 = to_local_0(_S976, dth_0, kernelContext_72);
    *_S978 = _S994;
    return;
}

JointResponse_0 static_response_0(uint i_12, KernelContext_0 thread* kernelContext_73)
{
    BondStatic_natural_0 device* _S995 = kernelContext_73->bonds_0+i_12;
    thread float3 d_lin_4;
    thread float3 d_ang_3;
    static_kinematics_0(i_12, &d_lin_4, &d_ang_3, kernelContext_73);
    thread JointBond_natural_0 _S996 = _S995->law_0;
    _S996 = _S995->law_0;
    thread JointState_0 _S997 = (kernelContext_73->bond_dyn_0+i_12)->js_0;
    JointResponse_0 _S998 = joint_evaluate_0(&kernelContext_73->materials_0->m_0[(uint4((&_S996)->ids_0) ).x], &_S996, &_S997, d_lin_4, d_ang_3, 0.0f, false);
    return _S998;
}

void gather_loads_0(uint c_24, float3 thread* fi_1, float3 thread* mi_0, KernelContext_0 thread* kernelContext_74)
{
    float3 _S999 = float3(0.0f) ;
    *fi_1 = _S999;
    *mi_0 = _S999;
    uint e_3 = kernelContext_74->index_0[c_24];
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
        uint bond_1 = entry_2 >> 1U;
        if((entry_2 & 1U) == 0U)
        {
            uint _S1000 = 3U * bond_1;
            *fi_1 = *fi_1 + (float4(*(kernelContext_74->scratch_0+_S1000)) ).xyz;
            *mi_0 = *mi_0 + (float4(*(kernelContext_74->scratch_0+(_S1000 + 1U))) ).xyz;
        }
        else
        {
            uint _S1001 = 3U * bond_1;
            *fi_1 = *fi_1 - (float4(*(kernelContext_74->scratch_0+_S1001)) ).xyz;
            *mi_0 = *mi_0 + (float4(*(kernelContext_74->scratch_0+(_S1001 + 2U))) ).xyz;
        }
        e_3 = e_3 + 1U;
    }
    return;
}

float bond_load_magnitude2_0(uint c_25, KernelContext_0 thread* kernelContext_75)
{
    uint e_4 = kernelContext_75->index_0[c_25];
    float m_4 = 0.0f;
    for(;;)
    {
        if(e_4 < (kernelContext_75->index_0)[c_25 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_3 = kernelContext_75->index_0[e_4];
        uint _S1002 = 3U * (entry_3 >> 1U);
        float3 f_14 = (float4(*(kernelContext_75->scratch_0+_S1002)) ).xyz;
        float3 t_16;
        if((entry_3 & 1U) == 0U)
        {
            t_16 = (float4(*(kernelContext_75->scratch_0+(_S1002 + 1U))) ).xyz;
        }
        else
        {
            t_16 = (float4(*(kernelContext_75->scratch_0+(_S1002 + 2U))) ).xyz;
        }
        float m_5 = m_4 + (dot(f_14, f_14) + dot(t_16, t_16));
        e_4 = e_4 + 1U;
        m_4 = m_5;
    }
    return m_4;
}

uint fixed_mask_0(uint c_26, KernelContext_0 thread* kernelContext_76)
{
    uint support_0 = (uint4((kernelContext_76->chunks_0+c_26)->info_1) ).x;
    uint _S1003;
    if(support_0 == 1U)
    {
        _S1003 = 63U;
    }
    else
    {
        if(support_0 == 2U)
        {
            _S1003 = 7U;
        }
        else
        {
            _S1003 = 0U;
        }
    }
    return _S1003;
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

uint statics_bond_slot_0(uint i_13, KernelContext_0 thread* kernelContext_77)
{
    return kernelContext_77->params_0->statics_base_0 + 23U * kernelContext_77->params_0->chunk_count_0 + 2U * i_13;
}

void store_inverse_0(uint c_27, const array<float, int(36)> thread* a_14, KernelContext_0 thread* kernelContext_78)
{
    uint j_9;
    float sum_4;
    thread array<float, int(36)> l_5;
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
        l_5[k_18] = 0.0f;
        k_18 = k_18 + 1U;
    }
    bool spd_0 = true;
    uint i_14 = 0U;
    for(;;)
    {
        bool _S1004;
        if(i_14 < 6U)
        {
            _S1004 = spd_0;
        }
        else
        {
            _S1004 = false;
        }
        if(_S1004)
        {
        }
        else
        {
            break;
        }
        j_9 = 0U;
        for(;;)
        {
            if(j_9 <= i_14)
            {
            }
            else
            {
                break;
            }
            uint _S1005 = i_14 * 6U;
            uint _S1006 = _S1005 + j_9;
            k_18 = 0U;
            sum_4 = (*a_14)[_S1006];
            for(;;)
            {
                if(k_18 < j_9)
                {
                }
                else
                {
                    break;
                }
                float sum_5 = sum_4 - l_5[_S1005 + k_18] * l_5[j_9 * 6U + k_18];
                k_18 = k_18 + 1U;
                sum_4 = sum_5;
            }
            if(i_14 == j_9)
            {
                if(sum_4 <= 0.0f)
                {
                    spd_0 = false;
                    break;
                }
                l_5[_S1005 + i_14] = sqrt(sum_4);
            }
            else
            {
                l_5[_S1006] = sum_4 / l_5[j_9 * 6U + j_9];
            }
            j_9 = j_9 + 1U;
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
            uint _S1007 = k_18 * 6U + k_18;
            float _S1008 = (*a_14)[_S1007];
            if(((*a_14)[_S1007]) > 0.0f)
            {
                sum_4 = 1.0f / _S1008;
            }
            else
            {
                sum_4 = 0.0f;
            }
            inv_0[_S1007] = sum_4;
            k_18 = k_18 + 1U;
        }
    }
    else
    {
        j_9 = 0U;
        for(;;)
        {
            if(j_9 < 6U)
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
                if(i_14 == j_9)
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
                    float s_7 = s_6 - l_5[i_14 * 6U + k_18] * y_3[k_18];
                    k_18 = k_18 + 1U;
                    s_6 = s_7;
                }
                y_3[i_14] = s_6 / l_5[i_14 * 6U + i_14];
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
                    float s_8 = sum_4 - l_5[k_18 * 6U + i_15] * x_15[k_18];
                    k_18 = k_18 + 1U;
                    sum_4 = s_8;
                }
                x_15[i_15] = sum_4 / l_5[i_15 * 6U + i_15];
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
                inv_0[i_16 * 6U + j_9] = x_15[i_16];
                i_16 = i_16 + 1U;
            }
            j_9 = j_9 + 1U;
        }
    }
    j_9 = 0U;
    for(;;)
    {
        if(j_9 < 9U)
        {
        }
        else
        {
            break;
        }
        uint _S1009 = sv_0(c_27, 12U + j_9, kernelContext_78);
        uint _S1010 = 4U * j_9;
        *(kernelContext_78->scratch_0+_S1009) = packed_float4(float4(inv_0[_S1010], inv_0[_S1010 + 1U], inv_0[_S1010 + 2U], inv_0[_S1010 + 3U])) ;
        j_9 = j_9 + 1U;
    }
    return;
}

void assemble_block_0(uint c_28, KernelContext_0 thread* kernelContext_79)
{
    uint p_16;
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
    uint e_5 = kernelContext_79->index_0[c_28];
    for(;;)
    {
        if(e_5 < (kernelContext_79->index_0)[c_28 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_4 = kernelContext_79->index_0[e_5];
        uint i_17 = entry_4 >> 1U;
        bool _S1011 = (entry_4 & 1U) != 0U;
        BondStatic_natural_0 device* _S1012 = kernelContext_79->bonds_0+i_17;
        uint _S1013 = statics_bond_slot_0(i_17, kernelContext_79);
        float4 _S1014 = float4(*(kernelContext_79->scratch_0+_S1013)) ;
        float4 _S1015 = float4(*(kernelContext_79->scratch_0+(_S1013 + 1U))) ;
        p_16 = 0U;
        for(;;)
        {
            if(p_16 < 6U)
            {
            }
            else
            {
                break;
            }
            uint _S1016 = p_16 % 3U;
            float3 t_17;
            if(_S1016 == 0U)
            {
                t_17 = (float4(_S1012->t1_0) ).xyz;
            }
            else
            {
                if(_S1016 == 1U)
                {
                    t_17 = (float4(_S1012->t2_0) ).xyz;
                }
                else
                {
                    t_17 = (float4(_S1012->normal_0) ).xyz;
                }
            }
            bool _S1017 = p_16 < 3U;
            float3 row_u_0;
            float3 row_t_0;
            if(_S1017)
            {
                if(_S1011)
                {
                    row_u_0 = t_17;
                }
                else
                {
                    row_u_0 = - t_17;
                }
                if(_S1011)
                {
                    row_t_0 = cross((float4(_S1012->rb_0) ).xyz, t_17);
                }
                else
                {
                    row_t_0 = - cross((float4(_S1012->ra_0) ).xyz, t_17);
                }
            }
            else
            {
                float3 _S1018 = float3(0.0f) ;
                if(_S1011)
                {
                    row_u_0 = t_17;
                }
                else
                {
                    row_u_0 = - t_17;
                }
                float3 _S1019 = row_u_0;
                row_u_0 = _S1018;
                row_t_0 = _S1019;
            }
            float kp_0;
            if(_S1017)
            {
                kp_0 = _S1014[p_16];
            }
            else
            {
                kp_0 = _S1015[p_16 - 3U];
            }
            if(kp_0 == 0.0f)
            {
                p_16 = p_16 + 1U;
                continue;
            }
            array<float, int(6)> _S1020 = { { row_u_0.x, row_u_0.y, row_u_0.z, row_t_0.x, row_t_0.y, row_t_0.z } };
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
                    a_15[r_13 * 6U + q_14] = a_15[r_13 * 6U + q_14] + kp_0 * _S1020[r_13] * _S1020[q_14];
                    q_14 = q_14 + 1U;
                }
                r_13 = r_13 + 1U;
            }
            p_16 = p_16 + 1U;
        }
        e_5 = e_5 + 1U;
    }
    uint _S1021 = fixed_mask_0(c_28, kernelContext_79);
    p_16 = 0U;
    for(;;)
    {
        if(p_16 < 6U)
        {
        }
        else
        {
            break;
        }
        if((_S1021 & (1U << p_16)) != 0U)
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
                a_15[p_16 * 6U + r_13] = 0.0f;
                a_15[r_13 * 6U + p_16] = 0.0f;
                r_13 = r_13 + 1U;
            }
            a_15[p_16 * 6U + p_16] = 1.0f;
        }
        p_16 = p_16 + 1U;
    }
    p_16 = 0U;
    for(;;)
    {
        if(p_16 < 6U)
        {
        }
        else
        {
            break;
        }
        if((a_15[p_16 * 6U + p_16]) == 0.0f)
        {
            a_15[p_16 * 6U + p_16] = 1.0f;
        }
        p_16 = p_16 + 1U;
    }
    thread array<float, int(36)> _S1022 = a_15;
    store_inverse_0(c_28, &_S1022, kernelContext_79);
    return;
}

float block_get_0(uint c_29, uint i_18, uint j_10, KernelContext_0 thread* kernelContext_80)
{
    uint k_20 = i_18 * 6U + j_10;
    uint _S1023 = sv_0(c_29, 12U + k_20 / 4U, kernelContext_80);
    return (*(kernelContext_80->scratch_0+_S1023))[k_20 % 4U];
}

void precondition_0(uint c_30, KernelContext_0 thread* kernelContext_81)
{
    uint _S1024 = sv_0(c_30, 4U, kernelContext_81);
    float4 _S1025 = float4(*(kernelContext_81->scratch_0+_S1024)) ;
    uint _S1026 = sv_0(c_30, 5U, kernelContext_81);
    float4 _S1027 = float4(*(kernelContext_81->scratch_0+_S1026)) ;
    array<float, int(6)> _S1028 = { { _S1025.x, _S1025.y, _S1025.z, _S1027.x, _S1027.y, _S1027.z } };
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
        uint j_11 = 0U;
        float s_9 = 0.0f;
        for(;;)
        {
            if(j_11 < 6U)
            {
            }
            else
            {
                break;
            }
            float _S1029 = block_get_0(c_30, i_19, j_11, kernelContext_81);
            float s_10 = s_9 + _S1029 * _S1028[j_11];
            j_11 = j_11 + 1U;
            s_9 = s_10;
        }
        z_1[i_19] = s_9;
        i_19 = i_19 + 1U;
    }
    uint _S1030 = sv_0(c_30, 6U, kernelContext_81);
    *(kernelContext_81->scratch_0+_S1030) = packed_float4(float4(z_1[int(0)], z_1[int(1)], z_1[int(2)], 0.0f)) ;
    uint _S1031 = sv_0(c_30, 7U, kernelContext_81);
    *(kernelContext_81->scratch_0+_S1031) = packed_float4(float4(z_1[int(3)], z_1[int(4)], z_1[int(5)], 0.0f)) ;
    return;
}

void project_displacement_slot_0(uint tid_16, const Island_natural_0 thread* isl_24, uint slot_5, KernelContext_0 thread* kernelContext_82)
{
    uint _S1032;
    float3 _S1033 = float3(0.0f) ;
    thread float3 p_17 = _S1033;
    thread float3 l_6 = _S1033;
    uint4 _S1034 = uint4(isl_24->range_0) ;
    uint _S1035 = _S1034.x + tid_16;
    uint c_31 = _S1035;
    for(;;)
    {
        uint _S1036 = _S1034.y;
        _S1032 = _S1036;
        if(c_31 < _S1036)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_natural_0 device* _S1037 = kernelContext_82->chunks_0+c_31;
        uint _S1038 = sv_0(c_31, slot_5, kernelContext_82);
        float3 u_0 = (float4(*(kernelContext_82->scratch_0+_S1038)) ).xyz;
        uint _S1039 = sv_0(c_31, slot_5 + 1U, kernelContext_82);
        float3 th_2 = (float4(*(kernelContext_82->scratch_0+_S1039)) ).xyz;
        float4 _S1040 = float4(_S1037->center_0) ;
        float3 r_14 = _S1040.xyz - (float4(isl_24->com_0) ).xyz;
        float3 _S1041 = float3(_S1040.w) ;
        p_17 = p_17 + u_0 * _S1041;
        l_6 = l_6 + (cross(r_14, u_0) * _S1041 + rows_mul_0(float4(_S1037->inertia0_1) , float4(_S1037->inertia1_1) , float4(_S1037->inertia2_1) , th_2));
        c_31 = c_31 + 256U;
    }
    group_sum3_0(tid_16, &p_17, &l_6, kernelContext_82);
    float4 _S1042 = float4(isl_24->com_0) ;
    float3 _S1043 = p_17 / float3(_S1042.w) ;
    float3 _S1044 = rows_mul_0(float4(isl_24->inv0_0) , float4(isl_24->inv1_0) , float4(isl_24->inv2_0) , l_6);
    c_31 = _S1035;
    for(;;)
    {
        if(c_31 < _S1032)
        {
        }
        else
        {
            break;
        }
        float3 r_15 = (float4((kernelContext_82->chunks_0+c_31)->center_0) ).xyz - _S1042.xyz;
        uint _S1045 = sv_0(c_31, slot_5, kernelContext_82);
        *(kernelContext_82->scratch_0+_S1045) = packed_float4(float4((float4(*(kernelContext_82->scratch_0+_S1045)) ).xyz - _S1043 - cross(_S1044, r_15), 0.0f)) ;
        uint _S1046 = sv_0(c_31, slot_5 + 1U, kernelContext_82);
        *(kernelContext_82->scratch_0+_S1046) = packed_float4(float4((float4(*(kernelContext_82->scratch_0+_S1046)) ).xyz - _S1044, 0.0f)) ;
        c_31 = c_31 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    return;
}

uint statics_result_slot_0(uint island_4, KernelContext_0 thread* kernelContext_83)
{
    return kernelContext_83->params_0->statics_base_0 + 23U * kernelContext_83->params_0->chunk_count_0 + 2U * kernelContext_83->params_0->statics_bonds_0 + island_4;
}

void write_bond_loads_0(uint _S1047, uint _S1048, float3 _S1049, float3 _S1050, float _S1051, KernelContext_0 thread* kernelContext_84)
{
    BondStatic_natural_0 device* _S1052 = kernelContext_84->bonds_0+_S1048;
    float3 _S1053 = to_body_0(_S1048, _S1049, kernelContext_84);
    float3 _S1054 = to_body_0(_S1048, _S1050, kernelContext_84);
    uint _S1055 = 3U * _S1047;
    *(kernelContext_84->scratch_0+_S1055) = packed_float4(float4(_S1053, _S1051)) ;
    *(kernelContext_84->scratch_0+(_S1055 + 1U)) = packed_float4(float4(_S1054 + cross((float4(_S1052->ra_0) ).xyz, _S1053), 0.0f)) ;
    *(kernelContext_84->scratch_0+(_S1055 + 2U)) = packed_float4(float4(- _S1054 + cross((float4(_S1052->rb_0) ).xyz, - _S1053), 0.0f)) ;
    return;
}

void bond_kinematics_0(uint _S1056, float3 _S1057, float3 _S1058, float3 _S1059, float3 _S1060, float3 thread* _S1061, float3 thread* _S1062, KernelContext_0 thread* kernelContext_85)
{
    BondStatic_natural_0 device* _S1063 = kernelContext_85->bonds_0+_S1056;
    float3 _S1064 = to_local_0(_S1056, _S1059 + cross(_S1060, (float4(_S1063->rb_0) ).xyz) - (_S1057 + cross(_S1058, (float4(_S1063->ra_0) ).xyz)), kernelContext_85);
    *_S1061 = _S1064;
    float3 _S1065 = to_local_0(_S1056, _S1060 - _S1058, kernelContext_85);
    *_S1062 = _S1065;
    return;
}

[[kernel]] void island_statics(uint3 group_6 [[threadgroup_position_in_grid]], uint3 thread_6 [[thread_position_in_threadgroup]], Params_0 constant* params_9 [[buffer(0)]], Island_natural_0 device* islands_9 [[buffer(9)]], uint device* index_9 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_9 [[buffer(3)]], packed_float4 device* state_11 [[buffer(6)]], packed_float4 device* scratch_9 [[buffer(8)]], packed_float4 device* contact_state_9 [[buffer(11)]], packed_float4 device* loads_9 [[buffer(5)]], Impactor_natural_0 device* impactors_9 [[buffer(10)]], BondStatic_natural_0 device* bonds_9 [[buffer(2)]], MaterialTable_0 constant* materials_9 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_9 [[buffer(7)]])
{
    uint i_20;
    bool converged_2;
    uint c_32;
    thread KernelContext_0 kernelContext_86;
    (&kernelContext_86)->params_0 = params_9;
    (&kernelContext_86)->islands_0 = islands_9;
    (&kernelContext_86)->index_0 = index_9;
    (&kernelContext_86)->chunks_0 = chunks_9;
    (&kernelContext_86)->state_0 = state_11;
    (&kernelContext_86)->scratch_0 = scratch_9;
    (&kernelContext_86)->contact_state_0 = contact_state_9;
    (&kernelContext_86)->loads_0 = loads_9;
    (&kernelContext_86)->impactors_0 = impactors_9;
    (&kernelContext_86)->bonds_0 = bonds_9;
    (&kernelContext_86)->materials_0 = materials_9;
    (&kernelContext_86)->bond_dyn_0 = bond_dyn_9;
    threadgroup array<float4, int(32)> g_part_a_9;
    (&kernelContext_86)->g_part_a_0 = &g_part_a_9;
    threadgroup array<float4, int(32)> g_part_b_9;
    (&kernelContext_86)->g_part_b_0 = &g_part_b_9;
    threadgroup array<uint, int(5)> g_seen_9;
    (&kernelContext_86)->g_seen_0 = &g_seen_9;
    threadgroup uint g_wide_run_9;
    (&kernelContext_86)->g_wide_run_0 = &g_wide_run_9;
    threadgroup array<uint, int(4096)> g_label_9;
    (&kernelContext_86)->g_label_0 = &g_label_9;
    threadgroup uint g_changed_9;
    (&kernelContext_86)->g_changed_0 = &g_changed_9;
    threadgroup uint g_halt_9;
    (&kernelContext_86)->g_halt_0 = &g_halt_9;
    threadgroup uint g_run_9;
    (&kernelContext_86)->g_run_0 = &g_run_9;
    threadgroup uint g_flag_9;
    (&kernelContext_86)->g_flag_0 = &g_flag_9;
    threadgroup array<uint, int(1024)> g_mode_9;
    (&kernelContext_86)->g_mode_0 = &g_mode_9;
    uint tid_17 = thread_6.x;
    uint _S1066 = group_6.x;
    thread Island_natural_0 _S1067 = *(islands_9+_S1066);
    uint4 _S1068 = uint4((&_S1067)->info_0) ;
    uint _S1069 = _S1068.z;
    if((_S1069 & 8U) == 0U)
    {
        return;
    }
    bool free_0 = ((_S1068.x) & 1U) == 0U;
    uint4 _S1070 = uint4((&_S1067)->range_0) ;
    uint c0_1 = _S1070.x;
    uint c1_1 = _S1070.y;
    uint b0_0 = _S1070.z;
    uint _S1071 = _S1070.w;
    uint _S1072 = c0_1 + tid_17;
    uint c_33 = _S1072;
    for(;;)
    {
        if(c_33 < c1_1)
        {
        }
        else
        {
            break;
        }
        uint _S1073 = sv_0(c_33, 21U, &kernelContext_86);
        packed_float4 _S1074 = packed_float4(float4(0.0f) ) ;
        *((&kernelContext_86)->scratch_0+_S1073) = _S1074;
        uint _S1075 = sv_0(c_33, 22U, &kernelContext_86);
        *((&kernelContext_86)->scratch_0+_S1075) = _S1074;
        c_33 = c_33 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    if(free_0)
    {
        project_load_slot_0(tid_17, &_S1067, 0U, &kernelContext_86);
    }
    float _S1076 = island_dot_0(tid_17, c0_1, c1_1, 0U, 0U, &kernelContext_86);
    float _S1077 = max(sqrt(_S1076), 1.00000000317107685e-30f);
    float _S1078 = (&kernelContext_86)->params_0->statics_tol_0;
    uint _S1079 = min((&kernelContext_86)->params_0->statics_cg_0, 20U * (c1_1 - c0_1) * 6U + 200U);
    float previous_2 = 1.00000001504746622e+30f;
    float residual_0 = 0.0f;
    uint newton_0 = 0U;
    uint cg_total_0 = 0U;
    for(;;)
    {
        if(newton_0 < ((&kernelContext_86)->params_0->statics_newton_0))
        {
        }
        else
        {
            converged_2 = false;
            break;
        }
        uint _S1080 = b0_0 + tid_17;
        i_20 = _S1080;
        for(;;)
        {
            if(i_20 < _S1071)
            {
            }
            else
            {
                break;
            }
            JointResponse_0 _S1081 = static_response_0(i_20, &kernelContext_86);
            write_bond_loads_0(i_20, i_20, _S1081.force_lin_1, _S1081.force_ang_1, 0.0f, &kernelContext_86);
            i_20 = i_20 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        float4 _S1082 = float4(0.0f) ;
        thread float4 magnitude_0 = _S1082;
        thread float4 unused_m_0 = _S1082;
        c_33 = _S1072;
        for(;;)
        {
            if(c_33 < c1_1)
            {
            }
            else
            {
                break;
            }
            thread float3 fi_2;
            thread float3 mi_1;
            gather_loads_0(c_33, &fi_2, &mi_1, &kernelContext_86);
            float _S1083 = bond_load_magnitude2_0(c_33, &kernelContext_86);
            magnitude_0.x = magnitude_0.x + _S1083;
            uint _S1084 = sv_0(c_33, 0U, &kernelContext_86);
            thread float4 r_lin_0 = float4((float4(*((&kernelContext_86)->scratch_0+_S1084)) ).xyz + fi_2, 0.0f);
            uint _S1085 = sv_0(c_33, 1U, &kernelContext_86);
            thread float4 r_ang_0 = float4((float4(*((&kernelContext_86)->scratch_0+_S1085)) ).xyz + mi_1, 0.0f);
            uint _S1086 = fixed_mask_0(c_33, &kernelContext_86);
            hold_0(_S1086, &r_lin_0, &r_ang_0, _S1082, _S1082);
            uint _S1087 = sv_0(c_33, 4U, &kernelContext_86);
            *((&kernelContext_86)->scratch_0+_S1087) = packed_float4(r_lin_0) ;
            uint _S1088 = sv_0(c_33, 5U, &kernelContext_86);
            *((&kernelContext_86)->scratch_0+_S1088) = packed_float4(r_ang_0) ;
            c_33 = c_33 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        group_sum2_0(tid_17, &magnitude_0, &unused_m_0, &kernelContext_86);
        if(free_0)
        {
            project_load_slot_0(tid_17, &_S1067, 4U, &kernelContext_86);
        }
        float _S1089 = island_dot_0(tid_17, c0_1, c1_1, 4U, 4U, &kernelContext_86);
        float residual_1 = sqrt(_S1089) / _S1077;
        float _S1090 = max(0.00100000004749745f, 3.83999986297567375e-06f * sqrt(magnitude_0.x) / _S1077);
        if(residual_1 <= _S1078)
        {
            converged_2 = true;
        }
        else
        {
            if(residual_1 <= _S1090)
            {
                converged_2 = residual_1 > (0.5f * previous_2);
            }
            else
            {
                converged_2 = false;
            }
        }
        if(converged_2)
        {
            residual_0 = residual_1;
            converged_2 = true;
            break;
        }
        uint i_21 = _S1080;
        for(;;)
        {
            if(i_21 < _S1071)
            {
            }
            else
            {
                break;
            }
            BondStatic_natural_0 device* _S1091 = (&kernelContext_86)->bonds_0+i_21;
            thread float3 d_lin_5;
            thread float3 d_ang_4;
            static_kinematics_0(i_21, &d_lin_5, &d_ang_4, &kernelContext_86);
            thread JointBond_natural_0 _S1092 = _S1091->law_0;
            thread JointState_0 _S1093 = ((&kernelContext_86)->bond_dyn_0+i_21)->js_0;
            thread float3 f_lin_2;
            thread float3 f_ang_2;
            secant_factors_0(&_S1092, &_S1093, d_lin_5, &f_lin_2, &f_ang_2);
            float4 _S1094 = float4((&_S1092)->stiff0_0) ;
            uint _S1095 = statics_bond_slot_0(i_21, &kernelContext_86);
            float _S1096 = _S1094.y;
            *((&kernelContext_86)->scratch_0+_S1095) = packed_float4(float4(_S1096 * f_lin_2.x, _S1096 * f_lin_2.y, _S1094.x * f_lin_2.z, 0.0f)) ;
            *((&kernelContext_86)->scratch_0+(_S1095 + 1U)) = packed_float4(float4(_S1094.z * f_ang_2.x, _S1094.w * f_ang_2.y, (float4((&_S1092)->stiff1_0) ).x * f_ang_2.z, 0.0f)) ;
            i_21 = i_21 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_34 = _S1072;
        for(;;)
        {
            if(c_34 < c1_1)
            {
            }
            else
            {
                break;
            }
            assemble_block_0(c_34, &kernelContext_86);
            uint _S1097 = sv_0(c_34, 2U, &kernelContext_86);
            packed_float4 _S1098 = packed_float4(_S1082) ;
            *((&kernelContext_86)->scratch_0+_S1097) = _S1098;
            uint _S1099 = sv_0(c_34, 3U, &kernelContext_86);
            *((&kernelContext_86)->scratch_0+_S1099) = _S1098;
            c_34 = c_34 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_35 = _S1072;
        for(;;)
        {
            if(c_35 < c1_1)
            {
            }
            else
            {
                break;
            }
            precondition_0(c_35, &kernelContext_86);
            c_35 = c_35 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        if(free_0)
        {
            project_displacement_slot_0(tid_17, &_S1067, 6U, &kernelContext_86);
        }
        uint c_36 = _S1072;
        for(;;)
        {
            if(c_36 < c1_1)
            {
            }
            else
            {
                break;
            }
            uint _S1100 = sv_0(c_36, 8U, &kernelContext_86);
            packed_float4 device* _S1101 = (&kernelContext_86)->scratch_0+_S1100;
            uint _S1102 = sv_0(c_36, 6U, &kernelContext_86);
            *_S1101 = packed_float4(float4(*((&kernelContext_86)->scratch_0+_S1102)) ) ;
            uint _S1103 = sv_0(c_36, 9U, &kernelContext_86);
            packed_float4 device* _S1104 = (&kernelContext_86)->scratch_0+_S1103;
            uint _S1105 = sv_0(c_36, 7U, &kernelContext_86);
            *_S1104 = packed_float4(float4(*((&kernelContext_86)->scratch_0+_S1105)) ) ;
            c_36 = c_36 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        float _S1106 = island_dot_0(tid_17, c0_1, c1_1, 4U, 6U, &kernelContext_86);
        float _S1107 = island_dot_0(tid_17, c0_1, c1_1, 4U, 4U, &kernelContext_86);
        float _S1108 = sqrt(_S1107);
        float rz_0 = _S1106;
        uint k_21 = 0U;
        uint cg_total_1 = cg_total_0;
        for(;;)
        {
            bool _S1109;
            if(k_21 < _S1079)
            {
                _S1109 = _S1108 > 0.0f;
            }
            else
            {
                _S1109 = false;
            }
            if(_S1109)
            {
            }
            else
            {
                cg_total_0 = cg_total_1;
                break;
            }
            uint i_22 = _S1080;
            for(;;)
            {
                if(i_22 < _S1071)
                {
                }
                else
                {
                    break;
                }
                uint4 _S1110 = uint4(((&kernelContext_86)->bonds_0+i_22)->law_0.ids_0) ;
                uint ca_2 = _S1110.y;
                uint cb_2 = _S1110.z;
                uint _S1111 = sv_0(ca_2, 8U, &kernelContext_86);
                float3 _S1112 = (float4(*((&kernelContext_86)->scratch_0+_S1111)) ).xyz;
                uint _S1113 = sv_0(ca_2, 9U, &kernelContext_86);
                float3 _S1114 = (float4(*((&kernelContext_86)->scratch_0+_S1113)) ).xyz;
                uint _S1115 = sv_0(cb_2, 8U, &kernelContext_86);
                float3 _S1116 = (float4(*((&kernelContext_86)->scratch_0+_S1115)) ).xyz;
                uint _S1117 = sv_0(cb_2, 9U, &kernelContext_86);
                thread float3 d_lin_6;
                thread float3 d_ang_5;
                bond_kinematics_0(i_22, _S1112, _S1114, _S1116, (float4(*((&kernelContext_86)->scratch_0+_S1117)) ).xyz, &d_lin_6, &d_ang_5, &kernelContext_86);
                uint _S1118 = statics_bond_slot_0(i_22, &kernelContext_86);
                write_bond_loads_0(i_22, i_22, d_lin_6 * (float4(*((&kernelContext_86)->scratch_0+_S1118)) ).xyz, d_ang_5 * (float4(*((&kernelContext_86)->scratch_0+(_S1118 + 1U))) ).xyz, 0.0f, &kernelContext_86);
                i_22 = i_22 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            c_32 = _S1072;
            for(;;)
            {
                if(c_32 < c1_1)
                {
                }
                else
                {
                    break;
                }
                thread float3 fi_3;
                thread float3 mi_2;
                gather_loads_0(c_32, &fi_3, &mi_2, &kernelContext_86);
                thread float4 ap_lin_0 = float4(- fi_3, 0.0f);
                thread float4 ap_ang_0 = float4(- mi_2, 0.0f);
                uint _S1119 = fixed_mask_0(c_32, &kernelContext_86);
                uint _S1120 = sv_0(c_32, 8U, &kernelContext_86);
                float4 _S1121 = float4(*((&kernelContext_86)->scratch_0+_S1120)) ;
                uint _S1122 = sv_0(c_32, 9U, &kernelContext_86);
                hold_0(_S1119, &ap_lin_0, &ap_ang_0, _S1121, float4(*((&kernelContext_86)->scratch_0+_S1122)) );
                uint _S1123 = sv_0(c_32, 10U, &kernelContext_86);
                *((&kernelContext_86)->scratch_0+_S1123) = packed_float4(ap_lin_0) ;
                uint _S1124 = sv_0(c_32, 11U, &kernelContext_86);
                *((&kernelContext_86)->scratch_0+_S1124) = packed_float4(ap_ang_0) ;
                c_32 = c_32 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            float _S1125 = island_dot_0(tid_17, c0_1, c1_1, 8U, 10U, &kernelContext_86);
            uint _S1126 = cg_total_1 + 1U;
            if(_S1125 <= 0.0f)
            {
                cg_total_0 = _S1126;
                break;
            }
            float _S1127 = rz_0 / _S1125;
            uint c_37 = _S1072;
            for(;;)
            {
                if(c_37 < c1_1)
                {
                }
                else
                {
                    break;
                }
                uint _S1128 = sv_0(c_37, 2U, &kernelContext_86);
                packed_float4 device* _S1129 = (&kernelContext_86)->scratch_0+_S1128;
                float3 _S1130 = (float4(*((&kernelContext_86)->scratch_0+_S1128)) ).xyz;
                uint _S1131 = sv_0(c_37, 8U, &kernelContext_86);
                float3 _S1132 = float3(_S1127) ;
                *_S1129 = packed_float4(float4(_S1130 + _S1132 * (float4(*((&kernelContext_86)->scratch_0+_S1131)) ).xyz, 0.0f)) ;
                uint _S1133 = sv_0(c_37, 3U, &kernelContext_86);
                packed_float4 device* _S1134 = (&kernelContext_86)->scratch_0+_S1133;
                float3 _S1135 = (float4(*((&kernelContext_86)->scratch_0+_S1133)) ).xyz;
                uint _S1136 = sv_0(c_37, 9U, &kernelContext_86);
                *_S1134 = packed_float4(float4(_S1135 + _S1132 * (float4(*((&kernelContext_86)->scratch_0+_S1136)) ).xyz, 0.0f)) ;
                uint _S1137 = sv_0(c_37, 4U, &kernelContext_86);
                packed_float4 device* _S1138 = (&kernelContext_86)->scratch_0+_S1137;
                float3 _S1139 = (float4(*((&kernelContext_86)->scratch_0+_S1137)) ).xyz;
                uint _S1140 = sv_0(c_37, 10U, &kernelContext_86);
                *_S1138 = packed_float4(float4(_S1139 - _S1132 * (float4(*((&kernelContext_86)->scratch_0+_S1140)) ).xyz, 0.0f)) ;
                uint _S1141 = sv_0(c_37, 5U, &kernelContext_86);
                packed_float4 device* _S1142 = (&kernelContext_86)->scratch_0+_S1141;
                float3 _S1143 = (float4(*((&kernelContext_86)->scratch_0+_S1141)) ).xyz;
                uint _S1144 = sv_0(c_37, 11U, &kernelContext_86);
                *_S1142 = packed_float4(float4(_S1143 - _S1132 * (float4(*((&kernelContext_86)->scratch_0+_S1144)) ).xyz, 0.0f)) ;
                c_37 = c_37 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            float _S1145 = island_dot_0(tid_17, c0_1, c1_1, 4U, 4U, &kernelContext_86);
            if((sqrt(_S1145)) <= (0.00009999999747379f * _S1108))
            {
                cg_total_0 = _S1126;
                break;
            }
            uint c_38 = _S1072;
            for(;;)
            {
                if(c_38 < c1_1)
                {
                }
                else
                {
                    break;
                }
                precondition_0(c_38, &kernelContext_86);
                c_38 = c_38 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            if(free_0)
            {
                project_displacement_slot_0(tid_17, &_S1067, 6U, &kernelContext_86);
            }
            float _S1146 = island_dot_0(tid_17, c0_1, c1_1, 4U, 6U, &kernelContext_86);
            float _S1147 = _S1146 / rz_0;
            uint c_39 = _S1072;
            for(;;)
            {
                if(c_39 < c1_1)
                {
                }
                else
                {
                    break;
                }
                uint _S1148 = sv_0(c_39, 8U, &kernelContext_86);
                packed_float4 device* _S1149 = (&kernelContext_86)->scratch_0+_S1148;
                uint _S1150 = sv_0(c_39, 6U, &kernelContext_86);
                float3 _S1151 = float3(_S1147) ;
                *_S1149 = packed_float4(float4((float4(*((&kernelContext_86)->scratch_0+_S1150)) ).xyz + _S1151 * (float4(*((&kernelContext_86)->scratch_0+_S1148)) ).xyz, 0.0f)) ;
                uint _S1152 = sv_0(c_39, 9U, &kernelContext_86);
                packed_float4 device* _S1153 = (&kernelContext_86)->scratch_0+_S1152;
                uint _S1154 = sv_0(c_39, 7U, &kernelContext_86);
                *_S1153 = packed_float4(float4((float4(*((&kernelContext_86)->scratch_0+_S1154)) ).xyz + _S1151 * (float4(*((&kernelContext_86)->scratch_0+_S1152)) ).xyz, 0.0f)) ;
                c_39 = c_39 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            uint _S1155 = k_21 + 1U;
            rz_0 = _S1146;
            k_21 = _S1155;
            cg_total_1 = _S1126;
        }
        c_32 = _S1072;
        for(;;)
        {
            if(c_32 < c1_1)
            {
            }
            else
            {
                break;
            }
            uint _S1156 = 4U * c_32;
            thread float3 u_1 = (float4(*((&kernelContext_86)->state_0+_S1156)) ).xyz;
            uint _S1157 = sv_0(c_32, 21U, &kernelContext_86);
            thread float3 u_lo_0 = (float4(*((&kernelContext_86)->scratch_0+_S1157)) ).xyz;
            uint _S1158 = _S1156 + 1U;
            thread float3 th_3 = (float4(*((&kernelContext_86)->state_0+_S1158)) ).xyz;
            uint _S1159 = sv_0(c_32, 22U, &kernelContext_86);
            thread float3 th_lo_0 = (float4(*((&kernelContext_86)->scratch_0+_S1159)) ).xyz;
            uint _S1160 = sv_0(c_32, 2U, &kernelContext_86);
            comp_add_0(&u_1, &u_lo_0, (float4(*((&kernelContext_86)->scratch_0+_S1160)) ).xyz);
            uint _S1161 = sv_0(c_32, 3U, &kernelContext_86);
            comp_add_0(&th_3, &th_lo_0, (float4(*((&kernelContext_86)->scratch_0+_S1161)) ).xyz);
            *((&kernelContext_86)->state_0+_S1156) = packed_float4(float4(u_1, (float4(*((&kernelContext_86)->state_0+_S1156)) ).w)) ;
            *((&kernelContext_86)->state_0+_S1158) = packed_float4(float4(th_3, (float4(*((&kernelContext_86)->state_0+_S1158)) ).w)) ;
            *((&kernelContext_86)->scratch_0+_S1157) = packed_float4(float4(u_lo_0, 0.0f)) ;
            *((&kernelContext_86)->scratch_0+_S1159) = packed_float4(float4(th_lo_0, 0.0f)) ;
            c_32 = c_32 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint _S1162 = newton_0 + 1U;
        previous_2 = residual_1;
        residual_0 = residual_1;
        newton_0 = _S1162;
    }
    i_20 = b0_0 + tid_17;
    for(;;)
    {
        if(i_20 < _S1071)
        {
        }
        else
        {
            break;
        }
        JointResponse_0 _S1163 = static_response_0(i_20, &kernelContext_86);
        BondDyn_natural_0 device* _S1164 = (&kernelContext_86)->bond_dyn_0+i_20;
        float4 _S1165 = float4((*_S1164).force_lin_0) ;
        float4 _S1166 = float4((*_S1164).force_ang_0) ;
        float4 _S1167 = float4((*_S1164).sums_0) ;
        float4 _S1168 = float4((*_S1164).comps_0) ;
        uint4 _S1169 = uint4((*_S1164).events_0) ;
        thread BondDyn_0 bd_1;
        (&bd_1)->js_0 = (*_S1164).js_0;
        (&bd_1)->force_lin_0 = _S1165;
        (&bd_1)->force_ang_0 = _S1166;
        (&bd_1)->sums_0 = _S1167;
        (&bd_1)->comps_0 = _S1168;
        (&bd_1)->events_0 = _S1169;
        (&bd_1)->force_lin_0 = float4(_S1163.force_lin_1, _S1163.stored_3);
        (&bd_1)->force_ang_0 = float4(_S1163.force_ang_1, (&bd_1)->force_ang_0.w);
        BondDyn_natural_0 device* _S1170 = (&kernelContext_86)->bond_dyn_0+i_20;
        _S1170->js_0 = bd_1.js_0;
        _S1170->force_lin_0 = packed_float4(bd_1.force_lin_0) ;
        _S1170->force_ang_0 = packed_float4(bd_1.force_ang_0) ;
        _S1170->sums_0 = packed_float4(bd_1.sums_0) ;
        _S1170->comps_0 = packed_float4(bd_1.comps_0) ;
        _S1170->events_0 = packed_uint4(bd_1.events_0) ;
        write_bond_loads_0(i_20, i_20, _S1163.force_lin_1, _S1163.force_ang_1, max(_S1163.measures_0.tension_0, _S1163.measures_0.compression_0), &kernelContext_86);
        i_20 = i_20 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    c_33 = _S1072;
    for(;;)
    {
        if(c_33 < c1_1)
        {
        }
        else
        {
            break;
        }
        thread float3 fi_4;
        thread float3 mi_3;
        gather_loads_0(c_33, &fi_4, &mi_3, &kernelContext_86);
        uint _S1171 = fixed_mask_0(c_33, &kernelContext_86);
        float3 reaction_0;
        if(_S1171 != 0U)
        {
            uint _S1172 = sv_0(c_33, 0U, &kernelContext_86);
            reaction_0 = - ((float4(*((&kernelContext_86)->scratch_0+_S1172)) ).xyz + fi_4);
        }
        else
        {
            uint _S1173 = 4U * c_33;
            reaction_0 = float3((float4(*((&kernelContext_86)->state_0+(_S1173 + 1U))) ).w, (float4(*((&kernelContext_86)->state_0+(_S1173 + 2U))) ).w, (float4(*((&kernelContext_86)->state_0+(_S1173 + 3U))) ).w);
        }
        uint _S1174 = 4U * c_33;
        uint _S1175 = _S1174 + 1U;
        *((&kernelContext_86)->state_0+_S1175) = packed_float4(float4((float4(*((&kernelContext_86)->state_0+_S1175)) ).xyz, reaction_0.x)) ;
        *((&kernelContext_86)->state_0+(_S1174 + 2U)) = packed_float4(float4(0.0f, 0.0f, 0.0f, reaction_0.y)) ;
        *((&kernelContext_86)->state_0+(_S1174 + 3U)) = packed_float4(float4(0.0f, 0.0f, 0.0f, reaction_0.z)) ;
        c_33 = c_33 + 256U;
    }
    if(tid_17 == 0U)
    {
        uint _S1176 = statics_result_slot_0(_S1066, &kernelContext_86);
        packed_float4 device* _S1177 = (&kernelContext_86)->scratch_0+_S1176;
        float _S1178 = (as_type<float>((newton_0)));
        float _S1179 = (as_type<float>((cg_total_0)));
        if(converged_2)
        {
            previous_2 = 1.0f;
        }
        else
        {
            previous_2 = 0.0f;
        }
        *_S1177 = packed_float4(float4(residual_0, _S1178, _S1179, previous_2)) ;
        ((&kernelContext_86)->islands_0+_S1066)->info_0[int(2)] = _S1069 & 4294967287U;
    }
    return;
}

[[kernel]] void settled_fatigue(uint3 group_7 [[threadgroup_position_in_grid]], uint3 thread_7 [[thread_position_in_threadgroup]], Params_0 constant* params_10 [[buffer(0)]], Island_natural_0 device* islands_10 [[buffer(9)]], uint device* index_10 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_10 [[buffer(3)]], packed_float4 device* state_12 [[buffer(6)]], packed_float4 device* scratch_10 [[buffer(8)]], packed_float4 device* contact_state_10 [[buffer(11)]], packed_float4 device* loads_10 [[buffer(5)]], Impactor_natural_0 device* impactors_10 [[buffer(10)]], BondStatic_natural_0 device* bonds_10 [[buffer(2)]], MaterialTable_0 constant* materials_10 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_10 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_87;
    (&kernelContext_87)->params_0 = params_10;
    (&kernelContext_87)->islands_0 = islands_10;
    (&kernelContext_87)->index_0 = index_10;
    (&kernelContext_87)->chunks_0 = chunks_10;
    (&kernelContext_87)->state_0 = state_12;
    (&kernelContext_87)->scratch_0 = scratch_10;
    (&kernelContext_87)->contact_state_0 = contact_state_10;
    (&kernelContext_87)->loads_0 = loads_10;
    (&kernelContext_87)->impactors_0 = impactors_10;
    (&kernelContext_87)->bonds_0 = bonds_10;
    (&kernelContext_87)->materials_0 = materials_10;
    (&kernelContext_87)->bond_dyn_0 = bond_dyn_10;
    threadgroup array<float4, int(32)> g_part_a_10;
    (&kernelContext_87)->g_part_a_0 = &g_part_a_10;
    threadgroup array<float4, int(32)> g_part_b_10;
    (&kernelContext_87)->g_part_b_0 = &g_part_b_10;
    threadgroup array<uint, int(5)> g_seen_10;
    (&kernelContext_87)->g_seen_0 = &g_seen_10;
    threadgroup uint g_wide_run_10;
    (&kernelContext_87)->g_wide_run_0 = &g_wide_run_10;
    threadgroup array<uint, int(4096)> g_label_10;
    (&kernelContext_87)->g_label_0 = &g_label_10;
    threadgroup uint g_changed_10;
    (&kernelContext_87)->g_changed_0 = &g_changed_10;
    threadgroup uint g_halt_10;
    (&kernelContext_87)->g_halt_0 = &g_halt_10;
    threadgroup uint g_run_10;
    (&kernelContext_87)->g_run_0 = &g_run_10;
    threadgroup uint g_flag_10;
    (&kernelContext_87)->g_flag_0 = &g_flag_10;
    threadgroup array<uint, int(1024)> g_mode_10;
    (&kernelContext_87)->g_mode_0 = &g_mode_10;
    uint tid_18 = thread_7.x;
    uint _S1180 = group_7.x;
    Island_natural_0 device* _S1181 = islands_10+_S1180;
    Island_natural_0 isl_25 = *_S1181;
    uint4 _S1182 = uint4((*_S1181).info_0) ;
    bool _S1183;
    if(((_S1182.x) & 16U) == 0U)
    {
        _S1183 = true;
    }
    else
    {
        uint4 _S1184 = uint4(isl_25.range_0) ;
        _S1183 = (_S1184.w) == (_S1184.z);
    }
    if(_S1183)
    {
        return;
    }
    seen_clear_0(tid_18, &kernelContext_87);
    if(tid_18 == 0U)
    {
        *(&kernelContext_87)->g_halt_0 = 0U;
        *(&kernelContext_87)->g_run_0 = 0U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    uint _S1185 = _S1182.w;
    uint4 _S1186 = uint4(isl_25.range_0) ;
    uint i_23 = _S1186.z + tid_18;
    for(;;)
    {
        if(i_23 < (_S1186.w))
        {
        }
        else
        {
            break;
        }
        BondStatic_natural_0 device* _S1187 = (&kernelContext_87)->bonds_0+i_23;
        BondDyn_natural_0 device* _S1188 = (&kernelContext_87)->bond_dyn_0+i_23;
        float4 _S1189 = float4((*_S1188).force_lin_0) ;
        float4 _S1190 = float4((*_S1188).force_ang_0) ;
        float4 _S1191 = float4((*_S1188).sums_0) ;
        float4 _S1192 = float4((*_S1188).comps_0) ;
        uint4 _S1193 = uint4((*_S1188).events_0) ;
        thread BondDyn_0 bd_2;
        (&bd_2)->js_0 = (*_S1188).js_0;
        (&bd_2)->force_lin_0 = _S1189;
        (&bd_2)->force_ang_0 = _S1190;
        (&bd_2)->sums_0 = _S1191;
        (&bd_2)->comps_0 = _S1192;
        (&bd_2)->events_0 = _S1193;
        thread JointBond_natural_0 _S1194 = _S1187->law_0;
        uint4 _S1195 = uint4((&_S1194)->ids_0) ;
        uint _S1196 = 4U * _S1195.y;
        uint _S1197 = 4U * _S1195.z;
        thread float3 d_lin_7;
        thread float3 d_ang_6;
        bond_kinematics_0(i_23, (float4(*((&kernelContext_87)->state_0+_S1196)) ).xyz, (float4(*((&kernelContext_87)->state_0+(_S1196 + 1U))) ).xyz, (float4(*((&kernelContext_87)->state_0+_S1197)) ).xyz, (float4(*((&kernelContext_87)->state_0+(_S1197 + 1U))) ).xyz, &d_lin_7, &d_ang_6, &kernelContext_87);
        JointState_0 previous_3 = (&bd_2)->js_0;
        float _S1198 = (&kernelContext_87)->params_0->dt_0;
        bool _S1199 = ((&kernelContext_87)->params_0->fracture_0) != 0U;
        _S1194 = _S1187->law_0;
        thread JointState_0 _S1200 = (&bd_2)->js_0;
        JointResponse_0 _S1201 = joint_evaluate_0(&(&kernelContext_87)->materials_0->m_0[_S1195.x], &_S1194, &_S1200, d_lin_7, d_ang_6, _S1198, _S1199);
        if((_S1201.state_5.damage_0) > (previous_3.damage_0 + 9.99999971718068537e-10f))
        {
            _S1183 = true;
        }
        else
        {
            _S1183 = (_S1201.state_5.crush_1) > (previous_3.crush_1 + 9.99999971718068537e-10f);
        }
        uint flags_3;
        if(_S1183)
        {
            flags_3 = 16U;
        }
        else
        {
            flags_3 = 0U;
        }
        thread float _S1202 = (&bd_2)->sums_0.x;
        thread float _S1203 = (&bd_2)->comps_0.x;
        comp_add1_0(&_S1202, &_S1203, _S1201.dissipated_2);
        (&bd_2)->comps_0.x = _S1203;
        (&bd_2)->sums_0.x = _S1202;
        thread float _S1204 = (&bd_2)->sums_0.y;
        thread float _S1205 = (&bd_2)->comps_0.y;
        comp_add1_0(&_S1204, &_S1205, _S1201.overshoot_0);
        (&bd_2)->comps_0.y = _S1205;
        (&bd_2)->sums_0.y = _S1204;
        (&bd_2)->force_lin_0 = float4(_S1201.force_lin_1, _S1201.stored_3);
        (&bd_2)->force_ang_0 = float4(_S1201.force_ang_1, max((&bd_2)->force_ang_0.w, _S1201.state_5.utilization_0));
        thread JointState_0 _S1206 = previous_3;
        bool _S1207 = is_damaged_0(&_S1206);
        bool _S1208;
        if(!_S1207)
        {
            thread JointState_0 _S1209 = _S1201.state_5;
            bool _S1210 = is_damaged_0(&_S1209);
            _S1208 = _S1210;
        }
        else
        {
            _S1208 = false;
        }
        bool _S1211;
        if(_S1208)
        {
            _S1211 = ((&bd_2)->events_0.x) == 0U;
        }
        else
        {
            _S1211 = false;
        }
        if(_S1211)
        {
            (&bd_2)->events_0.x = _S1185;
            (&bd_2)->events_0.w = _S1201.state_5.mode_0;
            (*(&kernelContext_87)->g_seen_0)[3U] = 1U;
        }
        bool _S1212;
        if(((&bd_2)->events_0.y) == 0U)
        {
            _S1212 = (_S1201.state_5.life_0) != (previous_3.life_0);
        }
        else
        {
            _S1212 = false;
        }
        bool _S1213;
        if(_S1212)
        {
            _S1213 = (_S1201.fatigue_before_0) > 0.99000000953674316f;
        }
        else
        {
            _S1213 = false;
        }
        bool _S1214;
        if(_S1213)
        {
            float _S1215 = fatigue_factor_0(&(&kernelContext_87)->materials_0->m_0[_S1195.x], _S1201.state_5.life_0);
            _S1214 = _S1215 <= 0.99000000953674316f;
        }
        else
        {
            _S1214 = false;
        }
        if(_S1214)
        {
            (&bd_2)->events_0.y = _S1185;
            (*(&kernelContext_87)->g_seen_0)[4U] = 1U;
        }
        uint flags_4;
        if(_S1201.disconnected_0)
        {
            (&bd_2)->events_0.z = _S1185;
            flags_4 = flags_3 | 32U;
        }
        else
        {
            flags_4 = flags_3;
        }
        (&bd_2)->js_0 = _S1201.state_5;
        BondDyn_natural_0 device* _S1216 = (&kernelContext_87)->bond_dyn_0+i_23;
        _S1216->js_0 = bd_2.js_0;
        _S1216->force_lin_0 = packed_float4(bd_2.force_lin_0) ;
        _S1216->force_ang_0 = packed_float4(bd_2.force_ang_0) ;
        _S1216->sums_0 = packed_float4(bd_2.sums_0) ;
        _S1216->comps_0 = packed_float4(bd_2.comps_0) ;
        _S1216->events_0 = packed_uint4(bd_2.events_0) ;
        write_bond_loads_0(i_23, i_23, _S1201.force_lin_1, _S1201.force_ang_1, max(_S1201.measures_0.tension_0, _S1201.measures_0.compression_0), &kernelContext_87);
        if((flags_4 & 16U) != 0U)
        {
            *(&kernelContext_87)->g_halt_0 = 1U;
        }
        if((flags_4 & 32U) != 0U)
        {
            *(&kernelContext_87)->g_run_0 = 1U;
        }
        i_23 = i_23 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    if(tid_18 != 0U)
    {
        return;
    }
    if(((*(&kernelContext_87)->g_halt_0) | (*(&kernelContext_87)->g_run_0)) != 0U)
    {
        uint _S1217 = _S1182.z;
        if((*(&kernelContext_87)->g_halt_0) != 0U)
        {
            i_23 = 16U;
        }
        else
        {
            i_23 = 0U;
        }
        uint _S1218 = _S1217 | i_23;
        if((*(&kernelContext_87)->g_run_0) != 0U)
        {
            i_23 = 32U;
        }
        else
        {
            i_23 = 0U;
        }
        ((&kernelContext_87)->islands_0+_S1180)->info_0[int(2)] = _S1218 | i_23;
    }
    uint _S1219 = (isl_25.coverage_0) | 16384U;
    uint _S1220 = seen_bits_0(&kernelContext_87);
    uint _S1221 = _S1219 | _S1220;
    if((*(&kernelContext_87)->g_run_0) != 0U)
    {
        i_23 = 128U;
    }
    else
    {
        i_23 = 0U;
    }
    ((&kernelContext_87)->islands_0+_S1180)->coverage_0 = _S1221 | i_23;
    return;
}

void impactor_integrate_at_0(uint ii_2, uint tid_19, KernelContext_0 thread* kernelContext_88)
{
    float3 p_18;
    if(ii_2 >= (kernelContext_88->params_0->impactor_count_0))
    {
        return;
    }
    Island_natural_0 device* _S1222 = kernelContext_88->islands_0+kernelContext_88->params_0->halt_index_0;
    Impactor_natural_0 device* _S1223 = kernelContext_88->impactors_0+ii_2;
    float4 _S1224 = float4((*_S1223).position_err_1) ;
    float4 _S1225 = float4((*_S1223).velocity_1) ;
    float4 _S1226 = float4((*_S1223).velocity_err_1) ;
    float4 _S1227 = float4((*_S1223).angular_velocity_1) ;
    float4 _S1228 = float4((*_S1223).rotation_1) ;
    float4 _S1229 = float4((*_S1223).inertia0_2) ;
    float4 _S1230 = float4((*_S1223).inertia1_2) ;
    float4 _S1231 = float4((*_S1223).inertia2_2) ;
    float4 _S1232 = float4((*_S1223).inv0_2) ;
    float4 _S1233 = float4((*_S1223).inv1_2) ;
    float4 _S1234 = float4((*_S1223).inv2_2) ;
    float4 _S1235 = float4((*_S1223).shape_0) ;
    float4 _S1236 = float4((*_S1223).half_1) ;
    float4 _S1237 = float4((*_S1223).mat_0) ;
    float4 _S1238 = float4((*_S1223).crush_0) ;
    float4 _S1239 = float4((*_S1223).geom_0) ;
    float4 _S1240 = float4((*_S1223).rotation_err_1) ;
    float4 _S1241 = float4((*_S1223).ledger_0) ;
    uint4 _S1242 = uint4((*_S1223).cand_0) ;
    float4 _S1243 = float4((*_S1223).momentum_1) ;
    float4 _S1244 = float4((*_S1223).momentum_err_1) ;
    thread Impactor_0 imp_6;
    (&imp_6)->position_1 = float4((*_S1223).position_1) ;
    (&imp_6)->position_err_1 = _S1224;
    (&imp_6)->velocity_1 = _S1225;
    (&imp_6)->velocity_err_1 = _S1226;
    (&imp_6)->angular_velocity_1 = _S1227;
    (&imp_6)->rotation_1 = _S1228;
    (&imp_6)->inertia0_2 = _S1229;
    (&imp_6)->inertia1_2 = _S1230;
    (&imp_6)->inertia2_2 = _S1231;
    (&imp_6)->inv0_2 = _S1232;
    (&imp_6)->inv1_2 = _S1233;
    (&imp_6)->inv2_2 = _S1234;
    (&imp_6)->shape_0 = _S1235;
    (&imp_6)->half_1 = _S1236;
    (&imp_6)->mat_0 = _S1237;
    (&imp_6)->crush_0 = _S1238;
    (&imp_6)->geom_0 = _S1239;
    (&imp_6)->rotation_err_1 = _S1240;
    (&imp_6)->ledger_0 = _S1241;
    (&imp_6)->cand_0 = _S1242;
    (&imp_6)->momentum_1 = _S1243;
    (&imp_6)->momentum_err_1 = _S1244;
    uint4 _S1245 = uint4(_S1222->info_0) ;
    bool _S1246;
    if(((_S1245.z) & 1U) != 0U)
    {
        _S1246 = true;
    }
    else
    {
        uint _S1247 = _S1245.y;
        if(_S1247 != 0U)
        {
            _S1246 = ((&imp_6)->cand_0.w) >= _S1247;
        }
        else
        {
            _S1246 = false;
        }
    }
    if(_S1246)
    {
        return;
    }
    if(((&imp_6)->cand_0.z) != 0U)
    {
        if(tid_19 == 0U)
        {
            (kernelContext_88->impactors_0+ii_2)->cand_0[int(3)] = (&imp_6)->cand_0.w + 1U;
        }
        return;
    }
    float4 _S1248 = float4(0.0f) ;
    thread float4 rf_1 = _S1248;
    thread float4 rt_0 = _S1248;
    uint k_22 = (&imp_6)->cand_0.x + tid_19;
    for(;;)
    {
        if(k_22 < ((&imp_6)->cand_0.y))
        {
        }
        else
        {
            break;
        }
        uint _S1249 = 3U * k_22;
        rf_1 = rf_1 + float4(*(kernelContext_88->scratch_0+(kernelContext_88->params_0->cand_base_0 + _S1249 + 1U))) ;
        rt_0 = rt_0 + float4(*(kernelContext_88->scratch_0+(kernelContext_88->params_0->cand_base_0 + _S1249 + 2U))) ;
        k_22 = k_22 + 256U;
    }
    group_sum2_0(tid_19, &rf_1, &rt_0, kernelContext_88);
    if(tid_19 != 0U)
    {
        return;
    }
    float dt_13 = kernelContext_88->params_0->dt_0;
    float3 _S1250 = float3(0.0f) ;
    float3 load_f_0;
    float3 load_t_0;
    if((kernelContext_88->params_0->has_ground_0) != 0U)
    {
        float3 _S1251 = (&imp_6)->half_1.xyz;
        thread Impactor_0 _S1252 = imp_6;
        Box_0 _S1253 = impactor_box_0(&_S1252, _S1250, _S1251);
        float3 _S1254 = (&imp_6)->velocity_1.xyz + (&imp_6)->velocity_err_1.xyz;
        float _S1255 = kernelContext_88->params_0->ground_modulus_0;
        float _S1256 = (&imp_6)->mat_0.x;
        float3 _S1257 = float3(0.0f, 0.0f, 1.0f);
        thread Box_0 _S1258 = _S1253;
        thread Box_0 _S1259 = _S1253;
        float _S1260 = contact_stiffness_0(_S1255, &_S1258, _S1256, &_S1259, _S1257);
        float _S1261 = (&imp_6)->position_1.z - kernelContext_88->params_0->ground_hi_0 + ((&imp_6)->position_err_1.z - kernelContext_88->params_0->ground_lo_0);
        uint total_points_0;
        if(((&imp_6)->shape_0.x) == 0.0f)
        {
            total_points_0 = 1U;
        }
        else
        {
            total_points_0 = 14U;
        }
        float _S1262 = _S1260 / float(min(total_points_0, 5U));
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
                p_18 = float3(0.0f, 0.0f, - (&imp_6)->shape_0.y);
            }
            else
            {
                thread Box_0 _S1263 = _S1253;
                float3 _S1264 = sample_point_0(&_S1263, s_11, kernelContext_88);
                p_18 = _S1264;
            }
            if((_S1261 + p_18.z) < 0.0f)
            {
                below_0 = below_0 + 1U;
            }
            s_11 = s_11 + 1U;
        }
        if(below_0 > 0U)
        {
            sentinel_mark_0(8U, kernelContext_88);
        }
        s_11 = 0U;
        load_f_0 = _S1250;
        load_t_0 = _S1250;
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
                p_18 = float3(0.0f, 0.0f, - (&imp_6)->shape_0.y);
            }
            else
            {
                thread Box_0 _S1265 = _S1253;
                float3 _S1266 = sample_point_0(&_S1265, s_11, kernelContext_88);
                p_18 = _S1266;
            }
            float depth_4 = - (_S1261 + p_18.z);
            if(depth_4 <= 0.0f)
            {
                s_11 = s_11 + 1U;
                continue;
            }
            thread float stored_7;
            thread float diss_5;
            float3 _S1267 = penalty_force_0(_S1262, (&imp_6)->mat_0.z, kernelContext_88->params_0->ground_friction_0, depth_4, _S1257, _S1254 + cross((&imp_6)->angular_velocity_1.xyz, p_18), dt_13, below_0, &stored_7, &diss_5, kernelContext_88);
            float3 load_f_1 = load_f_0 + _S1267;
            float3 load_t_1 = load_t_0 + cross(p_18, _S1267);
            thread float _S1268 = (&imp_6)->ledger_0.x;
            thread float _S1269 = (&imp_6)->ledger_0.y;
            comp_add1_0(&_S1268, &_S1269, diss_5);
            (&imp_6)->ledger_0.y = _S1269;
            (&imp_6)->ledger_0.x = _S1268;
            load_f_0 = load_f_1;
            load_t_0 = load_t_1;
            s_11 = s_11 + 1U;
        }
    }
    else
    {
        load_f_0 = _S1250;
        load_t_0 = _S1250;
    }
    float3 load_f_2 = rf_1.xyz + load_f_0;
    float3 load_t_2 = rt_0.xyz + load_t_0;
    float m_6 = (&imp_6)->mat_0.z;
    thread float3 vel_3 = (&imp_6)->velocity_1.xyz;
    thread float3 vel_err_1 = (&imp_6)->velocity_err_1.xyz;
    float3 _S1270 = float3(dt_13) ;
    comp_add_0(&vel_3, &vel_err_1, (load_f_2 / float3(m_6)  + kernelContext_88->params_0->gravity_0.xyz) * _S1270);
    Quat_0 _S1271 = quat_of_0((&imp_6)->rotation_1);
    thread Quat_0 q_15 = _S1271;
    thread float4 q_err_0 = (&imp_6)->rotation_err_1;
    thread float3 l_hi_0 = (&imp_6)->momentum_1.xyz;
    thread float3 l_err_1 = (&imp_6)->momentum_err_1.xyz;
    comp_add_0(&l_hi_0, &l_err_1, load_t_2 * _S1270);
    float3 l_7 = l_hi_0 + l_err_1;
    thread Quat_0 _S1272 = _S1271;
    float3 _S1273 = world_mul_0(&_S1272, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_7);
    thread float3 pos_1 = (&imp_6)->position_1.xyz;
    thread float3 pos_err_1 = (&imp_6)->position_err_1.xyz;
    comp_add_0(&pos_1, &pos_err_1, (vel_3 + vel_err_1) * _S1270);
    turn_left_0(&q_15, &q_err_0, _S1273, dt_13);
    thread Quat_0 _S1274 = q_15;
    float3 _S1275 = world_mul_0(&_S1274, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_7);
    (&imp_6)->angular_velocity_1 = float4(_S1275, 0.0f);
    thread Quat_0 _S1276 = q_15;
    float4 _S1277 = quat_vec_0(&_S1276);
    (&imp_6)->rotation_1 = _S1277;
    (&imp_6)->rotation_err_1 = q_err_0;
    (&imp_6)->momentum_1 = float4(l_hi_0, 0.0f);
    (&imp_6)->momentum_err_1 = float4(l_err_1, 0.0f);
    (&imp_6)->position_1 = float4(pos_1, 0.0f);
    (&imp_6)->position_err_1 = float4(pos_err_1, 0.0f);
    (&imp_6)->velocity_1 = float4(vel_3, 0.0f);
    (&imp_6)->velocity_err_1 = float4(vel_err_1, 0.0f);
    (&imp_6)->cand_0.w = (&imp_6)->cand_0.w + 1U;
    (&imp_6)->geom_0 = float4(1.0f, (&imp_6)->crush_0.w, 0.0f, 0.0f);
    Impactor_natural_0 device* _S1278 = kernelContext_88->impactors_0+ii_2;
    _S1278->position_1 = packed_float4(imp_6.position_1) ;
    _S1278->position_err_1 = packed_float4(imp_6.position_err_1) ;
    _S1278->velocity_1 = packed_float4(imp_6.velocity_1) ;
    _S1278->velocity_err_1 = packed_float4(imp_6.velocity_err_1) ;
    _S1278->angular_velocity_1 = packed_float4(imp_6.angular_velocity_1) ;
    _S1278->rotation_1 = packed_float4(imp_6.rotation_1) ;
    _S1278->inertia0_2 = packed_float4(imp_6.inertia0_2) ;
    _S1278->inertia1_2 = packed_float4(imp_6.inertia1_2) ;
    _S1278->inertia2_2 = packed_float4(imp_6.inertia2_2) ;
    _S1278->inv0_2 = packed_float4(imp_6.inv0_2) ;
    _S1278->inv1_2 = packed_float4(imp_6.inv1_2) ;
    _S1278->inv2_2 = packed_float4(imp_6.inv2_2) ;
    _S1278->shape_0 = packed_float4(imp_6.shape_0) ;
    _S1278->half_1 = packed_float4(imp_6.half_1) ;
    _S1278->mat_0 = packed_float4(imp_6.mat_0) ;
    _S1278->crush_0 = packed_float4(imp_6.crush_0) ;
    _S1278->geom_0 = packed_float4(imp_6.geom_0) ;
    _S1278->rotation_err_1 = packed_float4(imp_6.rotation_err_1) ;
    _S1278->ledger_0 = packed_float4(imp_6.ledger_0) ;
    _S1278->cand_0 = packed_uint4(imp_6.cand_0) ;
    _S1278->momentum_1 = packed_float4(imp_6.momentum_1) ;
    _S1278->momentum_err_1 = packed_float4(imp_6.momentum_err_1) ;
    uint k_23 = (&imp_6)->cand_0.w - 1U - kernelContext_88->params_0->step_start_0;
    if(k_23 < (kernelContext_88->params_0->record_stride_0))
    {
        uint at_6 = kernelContext_88->params_0->record_base_0 + 2U * (ii_2 * kernelContext_88->params_0->record_stride_0 + k_23);
        *(kernelContext_88->scratch_0+at_6) = packed_float4(float4(vel_3 + vel_err_1, 0.0f)) ;
        *(kernelContext_88->scratch_0+(at_6 + 1U)) = packed_float4(float4(pos_1 + pos_err_1, 0.0f)) ;
    }
    return;
}

[[kernel]] void impactor_integrate(uint3 group_8 [[threadgroup_position_in_grid]], uint3 thread_8 [[thread_position_in_threadgroup]], Params_0 constant* params_11 [[buffer(0)]], Island_natural_0 device* islands_11 [[buffer(9)]], uint device* index_11 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_11 [[buffer(3)]], packed_float4 device* state_13 [[buffer(6)]], packed_float4 device* scratch_11 [[buffer(8)]], packed_float4 device* contact_state_11 [[buffer(11)]], packed_float4 device* loads_11 [[buffer(5)]], Impactor_natural_0 device* impactors_11 [[buffer(10)]], BondStatic_natural_0 device* bonds_11 [[buffer(2)]], MaterialTable_0 constant* materials_11 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_11 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_89;
    (&kernelContext_89)->params_0 = params_11;
    (&kernelContext_89)->islands_0 = islands_11;
    (&kernelContext_89)->index_0 = index_11;
    (&kernelContext_89)->chunks_0 = chunks_11;
    (&kernelContext_89)->state_0 = state_13;
    (&kernelContext_89)->scratch_0 = scratch_11;
    (&kernelContext_89)->contact_state_0 = contact_state_11;
    (&kernelContext_89)->loads_0 = loads_11;
    (&kernelContext_89)->impactors_0 = impactors_11;
    (&kernelContext_89)->bonds_0 = bonds_11;
    (&kernelContext_89)->materials_0 = materials_11;
    (&kernelContext_89)->bond_dyn_0 = bond_dyn_11;
    threadgroup array<float4, int(32)> g_part_a_11;
    (&kernelContext_89)->g_part_a_0 = &g_part_a_11;
    threadgroup array<float4, int(32)> g_part_b_11;
    (&kernelContext_89)->g_part_b_0 = &g_part_b_11;
    threadgroup array<uint, int(5)> g_seen_11;
    (&kernelContext_89)->g_seen_0 = &g_seen_11;
    threadgroup uint g_wide_run_11;
    (&kernelContext_89)->g_wide_run_0 = &g_wide_run_11;
    threadgroup array<uint, int(4096)> g_label_11;
    (&kernelContext_89)->g_label_0 = &g_label_11;
    threadgroup uint g_changed_11;
    (&kernelContext_89)->g_changed_0 = &g_changed_11;
    threadgroup uint g_halt_11;
    (&kernelContext_89)->g_halt_0 = &g_halt_11;
    threadgroup uint g_run_11;
    (&kernelContext_89)->g_run_0 = &g_run_11;
    threadgroup uint g_flag_11;
    (&kernelContext_89)->g_flag_0 = &g_flag_11;
    threadgroup array<uint, int(1024)> g_mode_11;
    (&kernelContext_89)->g_mode_0 = &g_mode_11;
    impactor_integrate_at_0(group_8.x, thread_8.x, &kernelContext_89);
    return;
}

void ground_contact_0(uint c_40, bool account_0, float3 thread* f_15, float3 thread* t_18, KernelContext_0 thread* kernelContext_90)
{
    ChunkStatic_natural_0 device* _S1279 = kernelContext_90->chunks_0+c_40;
    WorldPoint_0 _S1280 = chunk_world_0(c_40, kernelContext_90);
    float above_0 = _S1280.hi_0.z - kernelContext_90->params_0->ground_hi_0 + (_S1280.lo_0.z - kernelContext_90->params_0->ground_lo_0) + _S1280.rel_0.z;
    if((above_0 - (float4(_S1279->half_0) ).w) > 0.0f)
    {
        return;
    }
    Box_0 _S1281 = chunk_box_0(c_40, float3(0.0f) , kernelContext_90);
    float _S1282 = kernelContext_90->params_0->ground_modulus_0;
    float _S1283 = (float4(_S1279->cmat_0) ).x;
    float3 _S1284 = float3(0.0f, 0.0f, 1.0f);
    thread Box_0 _S1285 = _S1281;
    thread Box_0 _S1286 = _S1281;
    float _S1287 = contact_stiffness_0(_S1282, &_S1285, _S1283, &_S1286, _S1284);
    thread Box_0 _S1288 = _S1281;
    uint _S1289 = sample_count_0(&_S1288);
    uint s_12 = 0U;
    uint n_11 = 0U;
    for(;;)
    {
        if(s_12 < _S1289)
        {
        }
        else
        {
            break;
        }
        thread Box_0 _S1290 = _S1281;
        float3 _S1291 = sample_point_0(&_S1290, s_12, kernelContext_90);
        if((above_0 + _S1291.z) < 0.0f)
        {
            n_11 = n_11 + 1U;
        }
        s_12 = s_12 + 1U;
    }
    if(n_11 == 0U)
    {
        return;
    }
    sentinel_mark_0(4U, kernelContext_90);
    thread float3 vc_1;
    thread float3 wc_1;
    chunk_velocity_0(c_40, &vc_1, &wc_1, kernelContext_90);
    thread float4 ledger_2 = float4(*(kernelContext_90->scratch_0+(kernelContext_90->params_0->ledger_base_0 + kernelContext_90->params_0->pair_count_0 + c_40))) ;
    s_12 = 0U;
    for(;;)
    {
        if(s_12 < _S1289)
        {
        }
        else
        {
            break;
        }
        thread Box_0 _S1292 = _S1281;
        float3 _S1293 = sample_point_0(&_S1292, s_12, kernelContext_90);
        float _S1294 = above_0 + _S1293.z;
        if(!(_S1294 < 0.0f))
        {
            s_12 = s_12 + 1U;
            continue;
        }
        thread float stored_8;
        thread float diss_6;
        float3 _S1295 = penalty_force_0(_S1287 / float(max(n_11, 5U)), (float4(_S1279->center_0) ).w, kernelContext_90->params_0->ground_friction_0, - _S1294, _S1284, vc_1 + cross(wc_1, _S1293), kernelContext_90->params_0->dt_0, n_11, &stored_8, &diss_6, kernelContext_90);
        *f_15 = *f_15 + _S1295;
        *t_18 = *t_18 + cross(_S1293, _S1295);
        thread float _S1296 = ledger_2.y;
        thread float _S1297 = ledger_2.z;
        comp_add1_0(&_S1296, &_S1297, diss_6);
        ledger_2.z = _S1297;
        ledger_2.y = _S1296;
        s_12 = s_12 + 1U;
    }
    if(account_0)
    {
        *(kernelContext_90->scratch_0+(kernelContext_90->params_0->ledger_base_0 + kernelContext_90->params_0->pair_count_0 + c_40)) = packed_float4(ledger_2) ;
    }
    return;
}

void contact_sum_at_0(uint g_2, KernelContext_0 thread* kernelContext_91)
{
    bool _S1298;
    if(g_2 >= (kernelContext_91->params_0->seg_count_0))
    {
        _S1298 = true;
    }
    else
    {
        bool _S1299 = stopped_0(kernelContext_91);
        _S1298 = _S1299;
    }
    if(_S1298)
    {
        return;
    }
    uint _S1300 = 3U * g_2;
    uint _S1301 = kernelContext_91->index_0[kernelContext_91->params_0->seg_index_0 + _S1300];
    uint begin_1 = kernelContext_91->index_0[kernelContext_91->params_0->seg_index_0 + _S1300 + 1U];
    uint _S1302 = kernelContext_91->index_0[kernelContext_91->params_0->seg_index_0 + _S1300 + 2U];
    float3 _S1303 = float3(0.0f) ;
    thread float3 f_16 = _S1303;
    thread float3 t_19 = _S1303;
    uint e_6 = begin_1;
    for(;;)
    {
        if(e_6 < _S1302)
        {
        }
        else
        {
            break;
        }
        uint entry_5 = kernelContext_91->index_0[e_6];
        if(entry_5 == 2147483648U)
        {
            ground_contact_0(_S1301, true, &f_16, &t_19, kernelContext_91);
            e_6 = e_6 + 1U;
            continue;
        }
        uint _S1304 = 2U * entry_5;
        f_16 = f_16 + (float4(*(kernelContext_91->scratch_0+(kernelContext_91->params_0->slot_base_0 + _S1304))) ).xyz;
        t_19 = t_19 + (float4(*(kernelContext_91->scratch_0+(kernelContext_91->params_0->slot_base_0 + _S1304 + 1U))) ).xyz;
        e_6 = e_6 + 1U;
    }
    uint _S1305 = 2U * g_2;
    *(kernelContext_91->scratch_0+(kernelContext_91->params_0->seg_base_0 + _S1305)) = packed_float4(float4(f_16, 0.0f)) ;
    *(kernelContext_91->scratch_0+(kernelContext_91->params_0->seg_base_0 + _S1305 + 1U)) = packed_float4(float4(t_19, 0.0f)) ;
    return;
}

[[kernel]] void contact_sums(uint3 id_2 [[thread_position_in_grid]], Params_0 constant* params_12 [[buffer(0)]], Island_natural_0 device* islands_12 [[buffer(9)]], uint device* index_12 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_12 [[buffer(3)]], packed_float4 device* state_14 [[buffer(6)]], packed_float4 device* scratch_12 [[buffer(8)]], packed_float4 device* contact_state_12 [[buffer(11)]], packed_float4 device* loads_12 [[buffer(5)]], Impactor_natural_0 device* impactors_12 [[buffer(10)]], BondStatic_natural_0 device* bonds_12 [[buffer(2)]], MaterialTable_0 constant* materials_12 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_12 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_92;
    (&kernelContext_92)->params_0 = params_12;
    (&kernelContext_92)->islands_0 = islands_12;
    (&kernelContext_92)->index_0 = index_12;
    (&kernelContext_92)->chunks_0 = chunks_12;
    (&kernelContext_92)->state_0 = state_14;
    (&kernelContext_92)->scratch_0 = scratch_12;
    (&kernelContext_92)->contact_state_0 = contact_state_12;
    (&kernelContext_92)->loads_0 = loads_12;
    (&kernelContext_92)->impactors_0 = impactors_12;
    (&kernelContext_92)->bonds_0 = bonds_12;
    (&kernelContext_92)->materials_0 = materials_12;
    (&kernelContext_92)->bond_dyn_0 = bond_dyn_12;
    threadgroup array<float4, int(32)> g_part_a_12;
    (&kernelContext_92)->g_part_a_0 = &g_part_a_12;
    threadgroup array<float4, int(32)> g_part_b_12;
    (&kernelContext_92)->g_part_b_0 = &g_part_b_12;
    threadgroup array<uint, int(5)> g_seen_12;
    (&kernelContext_92)->g_seen_0 = &g_seen_12;
    threadgroup uint g_wide_run_12;
    (&kernelContext_92)->g_wide_run_0 = &g_wide_run_12;
    threadgroup array<uint, int(4096)> g_label_12;
    (&kernelContext_92)->g_label_0 = &g_label_12;
    threadgroup uint g_changed_12;
    (&kernelContext_92)->g_changed_0 = &g_changed_12;
    threadgroup uint g_halt_12;
    (&kernelContext_92)->g_halt_0 = &g_halt_12;
    threadgroup uint g_run_12;
    (&kernelContext_92)->g_run_0 = &g_run_12;
    threadgroup uint g_flag_12;
    (&kernelContext_92)->g_flag_0 = &g_flag_12;
    threadgroup array<uint, int(1024)> g_mode_12;
    (&kernelContext_92)->g_mode_0 = &g_mode_12;
    contact_sum_at_0(id_2.x, &kernelContext_92);
    return;
}

void chunk_update_0(uint c_41, const Island_natural_0 thread* isl_26, const Rigid_0 thread* rg_14, float dt_14, bool rml_0, uint step_0, bool contact_4, float thread* work_2, float thread* work_err_0, KernelContext_0 thread* kernelContext_93)
{
    ChunkStatic_natural_0 device* _S1306 = kernelContext_93->chunks_0+c_41;
    float3 _S1307 = float3(0.0f) ;
    uint _S1308 = kernelContext_93->index_0[c_41];
    float peak_0 = 0.0f;
    uint e_7 = _S1308;
    float3 fi_5 = _S1307;
    float3 mi_4 = _S1307;
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
        uint _S1309 = 3U * (entry_6 >> 1U);
        float4 _S1310 = float4(*(kernelContext_93->scratch_0+_S1309)) ;
        if((entry_6 & 1U) == 0U)
        {
            float3 mi_5 = mi_4 + (float4(*(kernelContext_93->scratch_0+(_S1309 + 1U))) ).xyz;
            fi_5 = fi_5 + _S1310.xyz;
            mi_4 = mi_5;
        }
        else
        {
            float3 mi_6 = mi_4 + (float4(*(kernelContext_93->scratch_0+(_S1309 + 2U))) ).xyz;
            fi_5 = fi_5 + - _S1310.xyz;
            mi_4 = mi_6;
        }
        float _S1311 = max(peak_0, _S1310.w);
        uint _S1312 = e_7 + 1U;
        peak_0 = _S1311;
        e_7 = _S1312;
    }
    uint _S1313 = 4U * c_41;
    float3 u_2 = (float4(*(kernelContext_93->state_0+_S1313)) ).xyz;
    uint _S1314 = _S1313 + 1U;
    float3 th_4 = (float4(*(kernelContext_93->state_0+_S1314)) ).xyz;
    uint _S1315 = _S1313 + 2U;
    float3 v_11 = (float4(*(kernelContext_93->state_0+_S1315)) ).xyz;
    uint _S1316 = _S1313 + 3U;
    float3 w_6 = (float4(*(kernelContext_93->state_0+_S1316)) ).xyz;
    float4 _S1317 = float4(_S1306->center_0) ;
    float mass_0 = _S1317.w;
    float3 _S1318 = _S1317.xyz;
    float3 _S1319 = (float4(isl_26->com_0) ).xyz;
    float3 _S1320 = rotate_0(&rg_14->rot_1, _S1318 + u_2 - _S1319);
    thread float3 f_load_0;
    thread float3 t_load_0;
    thread float3 rep_f_2;
    thread float3 rep_m_2;
    chunk_loads_0(c_41, c_41, &rg_14->rot_1, step_0, dt_14, contact_4, dt_14, &f_load_0, &t_load_0, &rep_f_2, &rep_m_2, kernelContext_93);
    record_chunk_load_0(c_41, f_load_0, t_load_0, kernelContext_93);
    float3 _S1321 = float3(mass_0) ;
    float3 f_world_0 = f_load_0 + kernelContext_93->params_0->gravity_0.xyz * _S1321;
    float3 t_world_0 = t_load_0;
    float3 f_world_1;
    float3 t_world_1;
    if(rml_0)
    {
        float3 f_world_2 = f_world_0 - (rg_14->a_10 + cross(rg_14->alpha_0, _S1320) + cross(rg_14->w_5, cross(rg_14->w_5, _S1320))) * _S1321;
        float4 _S1322 = float4(_S1306->inertia0_1) ;
        float4 _S1323 = float4(_S1306->inertia1_1) ;
        float4 _S1324 = float4(_S1306->inertia2_1) ;
        float3 _S1325 = world_mul_0(&rg_14->rot_1, _S1322, _S1323, _S1324, rg_14->alpha_0);
        float3 _S1326 = world_mul_0(&rg_14->rot_1, _S1322, _S1323, _S1324, rg_14->w_5);
        float3 t_world_2 = t_world_0 - (_S1325 + cross(rg_14->w_5, _S1326));
        f_world_1 = f_world_2;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    float3 _S1327 = inverse_rotate_0(&rg_14->rot_1, f_world_1);
    float3 _S1328 = inverse_rotate_0(&rg_14->rot_1, t_world_1);
    float3 f_ext_0;
    float3 m_ext_0;
    if(rml_0)
    {
        float3 _S1329 = inverse_rotate_0(&rg_14->rot_1, rg_14->w_5);
        float4 _S1330 = float4(_S1306->inertia0_1) ;
        float4 _S1331 = float4(_S1306->inertia1_1) ;
        float4 _S1332 = float4(_S1306->inertia2_1) ;
        float3 i_w_0 = rows_mul_0(_S1330, _S1331, _S1332, w_6);
        float3 m_ext_1 = _S1328 - (cross(_S1329, i_w_0) + cross(w_6, rows_mul_0(_S1330, _S1331, _S1332, _S1329)) + cross(w_6, i_w_0));
        f_ext_0 = _S1327 - cross(_S1329, v_11) * float3((2.0f * mass_0)) ;
        m_ext_0 = m_ext_1;
    }
    else
    {
        f_ext_0 = _S1327;
        m_ext_0 = _S1328;
    }
    float3 f_17 = f_ext_0 + rep_f_2 + fi_5;
    float3 m_7 = m_ext_0 + rep_m_2 + mi_4;
    uint support_1 = (uint4(_S1306->info_1) ).x;
    float3 _S1333 = float3((float4(*(kernelContext_93->state_0+_S1314)) ).w, (float4(*(kernelContext_93->state_0+_S1315)) ).w, (float4(*(kernelContext_93->state_0+_S1316)) ).w);
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
        v_12 = _S1307;
        w_7 = _S1307;
    }
    else
    {
        float4 _S1334 = float4(_S1306->scale_0) ;
        float3 w_8 = w_6 + rows_mul_0(float4(_S1306->inv0_1) , float4(_S1306->inv1_1) , float4(_S1306->inv2_1) , m_7) * float3((dt_14 * _S1334.z)) ;
        float3 _S1335 = float3(dt_14) ;
        float3 th_6 = th_4 + w_8 * _S1335;
        if(support_1 == 2U)
        {
            reaction_1 = - f_17;
            u_3 = u_2;
            th_5 = _S1307;
        }
        else
        {
            float3 v_13 = v_11 + f_17 * float3((dt_14 * _S1334.y)) ;
            float3 u_4 = u_2 + v_13 * _S1335;
            reaction_1 = _S1333;
            u_3 = u_4;
            th_5 = v_13;
        }
        float3 _S1336 = th_5;
        th_5 = th_6;
        v_12 = _S1336;
        w_7 = w_8;
    }
    *(kernelContext_93->state_0+_S1313) = packed_float4(float4(u_3, peak_0)) ;
    *(kernelContext_93->state_0+_S1314) = packed_float4(float4(th_5, reaction_1.x)) ;
    *(kernelContext_93->state_0+_S1315) = packed_float4(float4(v_12, reaction_1.y)) ;
    *(kernelContext_93->state_0+_S1316) = packed_float4(float4(w_7, reaction_1.z)) ;
    float3 _S1337 = rotate_0(&rg_14->rot_1, _S1318 + u_3 - _S1319);
    float3 _S1338 = rg_14->vel_0 + rg_14->vel_err_0 + cross(rg_14->w_5, _S1337);
    float3 _S1339 = rotate_0(&rg_14->rot_1, v_12);
    float3 v_world_0 = _S1338 + _S1339;
    float3 _S1340 = rotate_0(&rg_14->rot_1, w_7);
    comp_add1_0(work_2, work_err_0, (dot(f_load_0, v_world_0) + dot(t_load_0, rg_14->w_5 + _S1340)) * dt_14);
    return;
}

void chunk_update_1(uint c_42, const Island_0 thread* isl_27, const Rigid_0 thread* rg_15, float dt_15, bool rml_1, uint step_1, bool contact_5, float thread* work_3, float thread* work_err_1, KernelContext_0 thread* kernelContext_94)
{
    ChunkStatic_natural_0 device* _S1341 = kernelContext_94->chunks_0+c_42;
    float3 _S1342 = float3(0.0f) ;
    uint _S1343 = kernelContext_94->index_0[c_42];
    float peak_1 = 0.0f;
    uint e_8 = _S1343;
    float3 fi_6 = _S1342;
    float3 mi_7 = _S1342;
    for(;;)
    {
        if(e_8 < (kernelContext_94->index_0)[c_42 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_7 = kernelContext_94->index_0[e_8];
        uint _S1344 = 3U * (entry_7 >> 1U);
        float4 _S1345 = float4(*(kernelContext_94->scratch_0+_S1344)) ;
        if((entry_7 & 1U) == 0U)
        {
            float3 mi_8 = mi_7 + (float4(*(kernelContext_94->scratch_0+(_S1344 + 1U))) ).xyz;
            fi_6 = fi_6 + _S1345.xyz;
            mi_7 = mi_8;
        }
        else
        {
            float3 mi_9 = mi_7 + (float4(*(kernelContext_94->scratch_0+(_S1344 + 2U))) ).xyz;
            fi_6 = fi_6 + - _S1345.xyz;
            mi_7 = mi_9;
        }
        float _S1346 = max(peak_1, _S1345.w);
        uint _S1347 = e_8 + 1U;
        peak_1 = _S1346;
        e_8 = _S1347;
    }
    uint _S1348 = 4U * c_42;
    float3 u_5 = (float4(*(kernelContext_94->state_0+_S1348)) ).xyz;
    uint _S1349 = _S1348 + 1U;
    float3 th_7 = (float4(*(kernelContext_94->state_0+_S1349)) ).xyz;
    uint _S1350 = _S1348 + 2U;
    float3 v_14 = (float4(*(kernelContext_94->state_0+_S1350)) ).xyz;
    uint _S1351 = _S1348 + 3U;
    float3 w_9 = (float4(*(kernelContext_94->state_0+_S1351)) ).xyz;
    float4 _S1352 = float4(_S1341->center_0) ;
    float mass_1 = _S1352.w;
    float3 _S1353 = _S1352.xyz;
    float3 _S1354 = isl_27->com_0.xyz;
    float3 _S1355 = rotate_0(&rg_15->rot_1, _S1353 + u_5 - _S1354);
    thread float3 f_load_1;
    thread float3 t_load_1;
    thread float3 rep_f_3;
    thread float3 rep_m_3;
    chunk_loads_0(c_42, c_42, &rg_15->rot_1, step_1, dt_15, contact_5, dt_15, &f_load_1, &t_load_1, &rep_f_3, &rep_m_3, kernelContext_94);
    record_chunk_load_0(c_42, f_load_1, t_load_1, kernelContext_94);
    float3 _S1356 = float3(mass_1) ;
    float3 f_world_3 = f_load_1 + kernelContext_94->params_0->gravity_0.xyz * _S1356;
    float3 t_world_3 = t_load_1;
    float3 f_world_4;
    float3 t_world_4;
    if(rml_1)
    {
        float3 f_world_5 = f_world_3 - (rg_15->a_10 + cross(rg_15->alpha_0, _S1355) + cross(rg_15->w_5, cross(rg_15->w_5, _S1355))) * _S1356;
        float4 _S1357 = float4(_S1341->inertia0_1) ;
        float4 _S1358 = float4(_S1341->inertia1_1) ;
        float4 _S1359 = float4(_S1341->inertia2_1) ;
        float3 _S1360 = world_mul_0(&rg_15->rot_1, _S1357, _S1358, _S1359, rg_15->alpha_0);
        float3 _S1361 = world_mul_0(&rg_15->rot_1, _S1357, _S1358, _S1359, rg_15->w_5);
        float3 t_world_5 = t_world_3 - (_S1360 + cross(rg_15->w_5, _S1361));
        f_world_4 = f_world_5;
        t_world_4 = t_world_5;
    }
    else
    {
        f_world_4 = f_world_3;
        t_world_4 = t_world_3;
    }
    float3 _S1362 = inverse_rotate_0(&rg_15->rot_1, f_world_4);
    float3 _S1363 = inverse_rotate_0(&rg_15->rot_1, t_world_4);
    float3 f_ext_1;
    float3 m_ext_2;
    if(rml_1)
    {
        float3 _S1364 = inverse_rotate_0(&rg_15->rot_1, rg_15->w_5);
        float4 _S1365 = float4(_S1341->inertia0_1) ;
        float4 _S1366 = float4(_S1341->inertia1_1) ;
        float4 _S1367 = float4(_S1341->inertia2_1) ;
        float3 i_w_1 = rows_mul_0(_S1365, _S1366, _S1367, w_9);
        float3 m_ext_3 = _S1363 - (cross(_S1364, i_w_1) + cross(w_9, rows_mul_0(_S1365, _S1366, _S1367, _S1364)) + cross(w_9, i_w_1));
        f_ext_1 = _S1362 - cross(_S1364, v_14) * float3((2.0f * mass_1)) ;
        m_ext_2 = m_ext_3;
    }
    else
    {
        f_ext_1 = _S1362;
        m_ext_2 = _S1363;
    }
    float3 f_18 = f_ext_1 + rep_f_3 + fi_6;
    float3 m_8 = m_ext_2 + rep_m_3 + mi_7;
    uint support_2 = (uint4(_S1341->info_1) ).x;
    float3 _S1368 = float3((float4(*(kernelContext_94->state_0+_S1349)) ).w, (float4(*(kernelContext_94->state_0+_S1350)) ).w, (float4(*(kernelContext_94->state_0+_S1351)) ).w);
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
        v_15 = _S1342;
        w_10 = _S1342;
    }
    else
    {
        float4 _S1369 = float4(_S1341->scale_0) ;
        float3 w_11 = w_9 + rows_mul_0(float4(_S1341->inv0_1) , float4(_S1341->inv1_1) , float4(_S1341->inv2_1) , m_8) * float3((dt_15 * _S1369.z)) ;
        float3 _S1370 = float3(dt_15) ;
        float3 th_9 = th_7 + w_11 * _S1370;
        if(support_2 == 2U)
        {
            reaction_2 = - f_18;
            u_6 = u_5;
            th_8 = _S1342;
        }
        else
        {
            float3 v_16 = v_14 + f_18 * float3((dt_15 * _S1369.y)) ;
            float3 u_7 = u_5 + v_16 * _S1370;
            reaction_2 = _S1368;
            u_6 = u_7;
            th_8 = v_16;
        }
        float3 _S1371 = th_8;
        th_8 = th_9;
        v_15 = _S1371;
        w_10 = w_11;
    }
    *(kernelContext_94->state_0+_S1348) = packed_float4(float4(u_6, peak_1)) ;
    *(kernelContext_94->state_0+_S1349) = packed_float4(float4(th_8, reaction_2.x)) ;
    *(kernelContext_94->state_0+_S1350) = packed_float4(float4(v_15, reaction_2.y)) ;
    *(kernelContext_94->state_0+_S1351) = packed_float4(float4(w_10, reaction_2.z)) ;
    float3 _S1372 = rotate_0(&rg_15->rot_1, _S1353 + u_6 - _S1354);
    float3 _S1373 = rg_15->vel_0 + rg_15->vel_err_0 + cross(rg_15->w_5, _S1372);
    float3 _S1374 = rotate_0(&rg_15->rot_1, v_15);
    float3 v_world_1 = _S1373 + _S1374;
    float3 _S1375 = rotate_0(&rg_15->rot_1, w_10);
    comp_add1_0(work_3, work_err_1, (dot(f_load_1, v_world_1) + dot(t_load_1, rg_15->w_5 + _S1375)) * dt_15);
    return;
}

void drift_moments_0(uint c_43, float3 thread* tu_2, float3 thread* pv_2, KernelContext_0 thread* kernelContext_95)
{
    ChunkStatic_natural_0 device* _S1376 = kernelContext_95->chunks_0+c_43;
    uint _S1377 = 4U * c_43;
    float3 _S1378 = float3(((float4(_S1376->center_0) ).w * (float4(_S1376->scale_0) ).x)) ;
    *tu_2 = *tu_2 + (float4(*(kernelContext_95->state_0+_S1377)) ).xyz * _S1378;
    *pv_2 = *pv_2 + (float4(*(kernelContext_95->state_0+(_S1377 + 2U))) ).xyz * _S1378;
    return;
}

void island_frame_at_0(uint gi_0, uint tid_20, KernelContext_0 thread* kernelContext_96)
{
    bool woke_0;
    Island_natural_0 device* _S1379 = kernelContext_96->islands_0+gi_0;
    uint4 _S1380 = uint4((*_S1379).info_0) ;
    float4 _S1381 = float4((*_S1379).com_0) ;
    float4 _S1382 = float4((*_S1379).inertia0_0) ;
    float4 _S1383 = float4((*_S1379).inertia1_0) ;
    float4 _S1384 = float4((*_S1379).inertia2_0) ;
    float4 _S1385 = float4((*_S1379).inv0_0) ;
    float4 _S1386 = float4((*_S1379).inv1_0) ;
    float4 _S1387 = float4((*_S1379).inv2_0) ;
    float4 _S1388 = float4((*_S1379).wcom_0) ;
    float4 _S1389 = float4((*_S1379).winv0_0) ;
    float4 _S1390 = float4((*_S1379).winv1_0) ;
    float4 _S1391 = float4((*_S1379).winv2_0) ;
    float4 _S1392 = float4((*_S1379).rotation_0) ;
    float4 _S1393 = float4((*_S1379).position_0) ;
    float4 _S1394 = float4((*_S1379).position_err_0) ;
    float4 _S1395 = float4((*_S1379).velocity_0) ;
    float4 _S1396 = float4((*_S1379).velocity_err_0) ;
    float4 _S1397 = float4((*_S1379).angular_velocity_0) ;
    uint4 _S1398 = uint4((*_S1379).probes_0) ;
    float4 _S1399 = float4((*_S1379).energy_0) ;
    float4 _S1400 = float4((*_S1379).rotation_err_0) ;
    float4 _S1401 = float4((*_S1379).momentum_0) ;
    float4 _S1402 = float4((*_S1379).momentum_err_0) ;
    thread Island_0 isl_28;
    (&isl_28)->range_0 = uint4((*_S1379).range_0) ;
    (&isl_28)->info_0 = _S1380;
    (&isl_28)->com_0 = _S1381;
    (&isl_28)->inertia0_0 = _S1382;
    (&isl_28)->inertia1_0 = _S1383;
    (&isl_28)->inertia2_0 = _S1384;
    (&isl_28)->inv0_0 = _S1385;
    (&isl_28)->inv1_0 = _S1386;
    (&isl_28)->inv2_0 = _S1387;
    (&isl_28)->wcom_0 = _S1388;
    (&isl_28)->winv0_0 = _S1389;
    (&isl_28)->winv1_0 = _S1390;
    (&isl_28)->winv2_0 = _S1391;
    (&isl_28)->rotation_0 = _S1392;
    (&isl_28)->position_0 = _S1393;
    (&isl_28)->position_err_0 = _S1394;
    (&isl_28)->velocity_0 = _S1395;
    (&isl_28)->velocity_err_0 = _S1396;
    (&isl_28)->angular_velocity_0 = _S1397;
    (&isl_28)->done_0 = (*_S1379).done_0;
    (&isl_28)->coverage_0 = (*_S1379).coverage_0;
    (&isl_28)->wide_groups_0 = (*_S1379).wide_groups_0;
    (&isl_28)->done_pad_0 = (*_S1379).done_pad_0;
    (&isl_28)->probes_0 = _S1398;
    (&isl_28)->energy_0 = _S1399;
    (&isl_28)->rotation_err_0 = _S1400;
    (&isl_28)->momentum_0 = _S1401;
    (&isl_28)->momentum_err_0 = _S1402;
    bool driven_0 = (((&isl_28)->info_0.x) & 2U) != 0U;
    bool _S1403 = !((((&isl_28)->info_0.x) & 1U) != 0U);
    bool _S1404;
    if(_S1403)
    {
        _S1404 = !driven_0;
    }
    else
    {
        _S1404 = false;
    }
    bool contact_island_0 = (((&isl_28)->info_0.x) & 4U) != 0U;
    bool _S1405 = (((&isl_28)->info_0.x) & 16U) != 0U;
    seen_clear_0(tid_20, kernelContext_96);
    bool _S1406 = tid_20 == 0U;
    bool settled_0;
    uint cov_2;
    if(_S1406)
    {
        if(contact_island_0 != ((kernelContext_96->params_0->contact_mode_0) == 1U))
        {
            settled_0 = true;
        }
        else
        {
            settled_0 = (((&isl_28)->info_0.x) & 8U) != 0U;
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
            thread Island_0 _S1407 = isl_28;
            bool _S1408 = contact_stopped_1(&_S1407, kernelContext_96);
            settled_0 = _S1408;
        }
        else
        {
            settled_0 = false;
        }
        if(settled_0)
        {
            cov_2 = 0U;
        }
        *kernelContext_96->g_run_0 = cov_2;
        *kernelContext_96->g_halt_0 = 0U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    if((((&isl_28)->info_0.z) & 1U) != 0U)
    {
        settled_0 = true;
    }
    else
    {
        settled_0 = (*kernelContext_96->g_run_0) == 0U;
    }
    if(settled_0)
    {
        cov_2 = 0U;
    }
    else
    {
        cov_2 = min((&isl_28)->info_0.y, kernelContext_96->params_0->max_steps_0);
    }
    float _S1409 = kernelContext_96->params_0->dt_0;
    bool _S1410 = (kernelContext_96->params_0->fracture_0) != 0U;
    bool _S1411 = (kernelContext_96->params_0->rigid_motion_loads_0) != 0U;
    thread Island_0 _S1412 = isl_28;
    Rigid_0 _S1413 = rigid_of_1(&_S1412);
    thread Rigid_0 rg_16 = _S1413;
    thread float work_4 = 0.0f;
    thread float work_err_2 = 0.0f;
    settled_0 = _S1405;
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
        uint abs_step_1 = (&isl_28)->info_0.w + done_1 + 1U;
        uint k_24 = abs_step_1 - 1U - kernelContext_96->params_0->step_start_0;
        bool quiet_0 = (((&isl_28)->info_0.x) & 32U) != 0U;
        bool _S1414;
        if(settled_0)
        {
            _S1414 = !quiet_0;
        }
        else
        {
            _S1414 = false;
        }
        bool _S1415;
        bool explicit_step_0;
        uint c_44;
        if(_S1414)
        {
            float3 _S1416 = float3(0.0f) ;
            thread float3 norm_1 = _S1416;
            thread float3 unused0_0 = _S1416;
            c_44 = (&isl_28)->range_0.x + tid_20;
            for(;;)
            {
                if(c_44 < ((&isl_28)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                thread Quat_0 _S1417 = (&rg_16)->rot_1;
                float _S1418 = settled_chunk_load_0(c_44, &_S1417, k_24, _S1409, contact_island_0, kernelContext_96);
                norm_1.x = norm_1.x + _S1418;
                c_44 = c_44 + 256U;
            }
            group_sum3_0(tid_20, &norm_1, &unused0_0, kernelContext_96);
            if((kernelContext_96->params_0->solve_mode_0) == 1U)
            {
                _S1415 = (abs(norm_1.x - (&isl_28)->energy_0.z)) > ((&isl_28)->energy_0.w);
            }
            else
            {
                _S1415 = false;
            }
            if(_S1415)
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
        if(_S1403)
        {
            _S1415 = !quiet_0;
        }
        else
        {
            _S1415 = false;
        }
        if(_S1415)
        {
            float3 _S1419 = float3(0.0f) ;
            thread float3 f_19 = _S1419;
            thread float3 t_20 = _S1419;
            c_44 = (&isl_28)->range_0.x + tid_20;
            for(;;)
            {
                if(c_44 < ((&isl_28)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                thread Island_0 _S1420 = isl_28;
                thread Rigid_0 _S1421 = rg_16;
                net_load_1(c_44, &_S1420, &_S1421, k_24, _S1409, contact_island_0, &f_19, &t_20, kernelContext_96);
                c_44 = c_44 + 256U;
            }
            group_sum3_0(tid_20, &f_19, &t_20, kernelContext_96);
            thread Island_0 _S1422 = isl_28;
            rigid_acceleration_1(&_S1422, &rg_16, f_19, t_20);
        }
        if(!settled_0)
        {
            explicit_step_0 = !quiet_0;
        }
        else
        {
            explicit_step_0 = false;
        }
        uint c_45;
        if(explicit_step_0)
        {
            c_44 = (&isl_28)->range_0.z + tid_20;
            for(;;)
            {
                if(c_44 < ((&isl_28)->range_0.w))
                {
                }
                else
                {
                    break;
                }
                bool _S1423 = bond_update_0(c_44, _S1409, _S1410, abs_step_1, false, kernelContext_96);
                if(_S1423)
                {
                    *kernelContext_96->g_halt_0 = 1U;
                }
                c_44 = c_44 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            c_45 = (&isl_28)->range_0.x + tid_20;
            for(;;)
            {
                if(c_45 < ((&isl_28)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                thread Island_0 _S1424 = isl_28;
                thread Rigid_0 _S1425 = rg_16;
                chunk_update_1(c_45, &_S1424, &_S1425, _S1409, _S1411, k_24, contact_island_0, &work_4, &work_err_2, kernelContext_96);
                c_45 = c_45 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        }
        bool _S1426;
        if(_S1404)
        {
            _S1426 = !quiet_0;
        }
        else
        {
            _S1426 = false;
        }
        if(_S1426)
        {
            thread Island_0 _S1427 = isl_28;
            integrate_rigid_1(&_S1427, &rg_16, _S1409);
        }
        bool _S1428;
        if(_S1403)
        {
            _S1428 = explicit_step_0;
        }
        else
        {
            _S1428 = false;
        }
        if(_S1428)
        {
            float3 _S1429 = (&isl_28)->wcom_0.xyz;
            float3 _S1430 = float3(0.0f) ;
            thread float3 tu_3 = _S1430;
            thread float3 pv_3 = _S1430;
            c_44 = (&isl_28)->range_0.x + tid_20;
            for(;;)
            {
                if(c_44 < ((&isl_28)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_moments_0(c_44, &tu_3, &pv_3, kernelContext_96);
                c_44 = c_44 + 256U;
            }
            group_sum3_0(tid_20, &tu_3, &pv_3, kernelContext_96);
            float3 tr_6 = tu_3 / float3((&isl_28)->wcom_0.w) ;
            float3 dv_6 = pv_3 / float3((&isl_28)->wcom_0.w) ;
            thread float3 lu_3 = _S1430;
            thread float3 lv_3 = _S1430;
            c_45 = (&isl_28)->range_0.x + tid_20;
            for(;;)
            {
                if(c_45 < ((&isl_28)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_angular_0(c_45, _S1429, tr_6, dv_6, &lu_3, &lv_3, kernelContext_96);
                c_45 = c_45 + 256U;
            }
            group_sum3_0(tid_20, &lu_3, &lv_3, kernelContext_96);
            float3 phi_5 = rows_mul_0((&isl_28)->winv0_0, (&isl_28)->winv1_0, (&isl_28)->winv2_0, lu_3);
            float3 dw_4 = rows_mul_0((&isl_28)->winv0_0, (&isl_28)->winv1_0, (&isl_28)->winv2_0, lv_3);
            uint c_46 = (&isl_28)->range_0.x + tid_20;
            for(;;)
            {
                if(c_46 < ((&isl_28)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_apply_0(c_46, _S1429, tr_6, phi_5, dv_6, dw_4, kernelContext_96);
                c_46 = c_46 + 256U;
            }
            if(!driven_0)
            {
                thread Island_0 _S1431 = isl_28;
                drift_rigid_1(&_S1431, &rg_16, tr_6, phi_5, dv_6, dw_4);
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        }
        bool _S1432;
        if(_S1406)
        {
            _S1432 = ((&isl_28)->probes_0.y) > ((&isl_28)->probes_0.x);
        }
        else
        {
            _S1432 = false;
        }
        if(_S1432)
        {
            thread Island_0 _S1433 = isl_28;
            thread Rigid_0 _S1434 = rg_16;
            record_probes_0(&_S1433, &_S1434, k_24, kernelContext_96);
        }
        uint _S1435 = done_1 + 1U;
        if((*kernelContext_96->g_halt_0) != 0U)
        {
            done_1 = _S1435;
            break;
        }
        done_1 = _S1435;
        woke_1 = woke_0;
    }
    thread float3 wsum_0 = float3(work_4, work_err_2, 0.0f);
    thread float3 unused_3 = float3(0.0f) ;
    group_sum3_0(tid_20, &wsum_0, &unused_3, kernelContext_96);
    if(_S1406)
    {
        thread Quat_0 _S1436 = (&rg_16)->rot_1;
        float4 _S1437 = quat_vec_0(&_S1436);
        (&isl_28)->rotation_0 = _S1437;
        (&isl_28)->rotation_err_0 = (&rg_16)->rot_err_0;
        (&isl_28)->position_0 = float4((&rg_16)->pos_0, 0.0f);
        (&isl_28)->position_err_0 = float4((&rg_16)->pos_err_0, 0.0f);
        (&isl_28)->velocity_0 = float4((&rg_16)->vel_0, 0.0f);
        (&isl_28)->velocity_err_0 = float4((&rg_16)->vel_err_0, 0.0f);
        (&isl_28)->angular_velocity_0 = float4((&rg_16)->w_5, 0.0f);
        (&isl_28)->momentum_0 = float4((&rg_16)->l_1, 0.0f);
        (&isl_28)->momentum_err_0 = float4((&rg_16)->l_err_0, 0.0f);
        (&isl_28)->done_0 = done_1;
        (&isl_28)->info_0.y = (&isl_28)->info_0.y - done_1;
        if((*kernelContext_96->g_halt_0) != 0U)
        {
            _S1404 = contact_island_0;
        }
        else
        {
            _S1404 = false;
        }
        if(_S1404)
        {
            contact_split_at_0((&isl_28)->info_0.w + done_1, kernelContext_96);
        }
        float _S1438 = wsum_0.x;
        thread float _S1439 = (&isl_28)->energy_0.x;
        thread float _S1440 = (&isl_28)->energy_0.y;
        comp_add1_0(&_S1439, &_S1440, _S1438);
        (&isl_28)->energy_0.x = _S1439;
        (&isl_28)->energy_0.y = _S1440 + wsum_0.y;
        (&isl_28)->info_0.w = (&isl_28)->info_0.w + done_1;
        if((*kernelContext_96->g_halt_0) != 0U)
        {
            (&isl_28)->info_0.z = ((&isl_28)->info_0.z) | 1U;
        }
        uint _S1441 = seen_bits_0(kernelContext_96);
        if((*kernelContext_96->g_halt_0) != 0U)
        {
            cov_2 = 128U;
        }
        else
        {
            cov_2 = 0U;
        }
        uint _S1442 = _S1441 | cov_2;
        if(woke_0)
        {
            cov_2 = 2048U;
        }
        else
        {
            cov_2 = 0U;
        }
        uint cov_3 = _S1442 | cov_2;
        if(done_1 > 0U)
        {
            bool quiet_1 = (((&isl_28)->info_0.x) & 32U) != 0U;
            if(quiet_1)
            {
                cov_2 = 4096U;
            }
            else
            {
                cov_2 = 0U;
            }
            uint cov_4 = cov_3 | cov_2;
            if((((&isl_28)->info_0.x) & 16U) != 0U)
            {
                _S1404 = !quiet_1;
            }
            else
            {
                _S1404 = false;
            }
            if(_S1404)
            {
                cov_2 = 512U;
            }
            else
            {
                cov_2 = 0U;
            }
            uint cov_5 = cov_4 | cov_2;
            if((kernelContext_96->params_0->contact_mode_0) == 1U)
            {
                cov_2 = 524288U;
            }
            else
            {
                cov_2 = 0U;
            }
            uint cov_6 = cov_5 | cov_2;
            if(((&isl_28)->probes_0.y) > ((&isl_28)->probes_0.x))
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
        (&isl_28)->coverage_0 = ((&isl_28)->coverage_0) | cov_2;
        if(woke_0)
        {
            (&isl_28)->info_0.x = ((&isl_28)->info_0.x) & 4294967279U;
            (&isl_28)->info_0.z = ((&isl_28)->info_0.z) | 4U;
        }
        Island_natural_0 device* _S1443 = kernelContext_96->islands_0+gi_0;
        _S1443->range_0 = packed_uint4(isl_28.range_0) ;
        _S1443->info_0 = packed_uint4(isl_28.info_0) ;
        _S1443->com_0 = packed_float4(isl_28.com_0) ;
        _S1443->inertia0_0 = packed_float4(isl_28.inertia0_0) ;
        _S1443->inertia1_0 = packed_float4(isl_28.inertia1_0) ;
        _S1443->inertia2_0 = packed_float4(isl_28.inertia2_0) ;
        _S1443->inv0_0 = packed_float4(isl_28.inv0_0) ;
        _S1443->inv1_0 = packed_float4(isl_28.inv1_0) ;
        _S1443->inv2_0 = packed_float4(isl_28.inv2_0) ;
        _S1443->wcom_0 = packed_float4(isl_28.wcom_0) ;
        _S1443->winv0_0 = packed_float4(isl_28.winv0_0) ;
        _S1443->winv1_0 = packed_float4(isl_28.winv1_0) ;
        _S1443->winv2_0 = packed_float4(isl_28.winv2_0) ;
        _S1443->rotation_0 = packed_float4(isl_28.rotation_0) ;
        _S1443->position_0 = packed_float4(isl_28.position_0) ;
        _S1443->position_err_0 = packed_float4(isl_28.position_err_0) ;
        _S1443->velocity_0 = packed_float4(isl_28.velocity_0) ;
        _S1443->velocity_err_0 = packed_float4(isl_28.velocity_err_0) ;
        _S1443->angular_velocity_0 = packed_float4(isl_28.angular_velocity_0) ;
        _S1443->done_0 = isl_28.done_0;
        _S1443->coverage_0 = isl_28.coverage_0;
        _S1443->wide_groups_0 = isl_28.wide_groups_0;
        _S1443->done_pad_0 = isl_28.done_pad_0;
        _S1443->probes_0 = packed_uint4(isl_28.probes_0) ;
        _S1443->energy_0 = packed_float4(isl_28.energy_0) ;
        _S1443->rotation_err_0 = packed_float4(isl_28.rotation_err_0) ;
        _S1443->momentum_0 = packed_float4(isl_28.momentum_0) ;
        _S1443->momentum_err_0 = packed_float4(isl_28.momentum_err_0) ;
    }
    return;
}

[[kernel]] void island_frame(uint3 group_9 [[threadgroup_position_in_grid]], uint3 thread_9 [[thread_position_in_threadgroup]], Params_0 constant* params_13 [[buffer(0)]], Island_natural_0 device* islands_13 [[buffer(9)]], uint device* index_13 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_13 [[buffer(3)]], packed_float4 device* state_15 [[buffer(6)]], packed_float4 device* scratch_13 [[buffer(8)]], packed_float4 device* contact_state_13 [[buffer(11)]], packed_float4 device* loads_13 [[buffer(5)]], Impactor_natural_0 device* impactors_13 [[buffer(10)]], BondStatic_natural_0 device* bonds_13 [[buffer(2)]], MaterialTable_0 constant* materials_13 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_13 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_97;
    (&kernelContext_97)->params_0 = params_13;
    (&kernelContext_97)->islands_0 = islands_13;
    (&kernelContext_97)->index_0 = index_13;
    (&kernelContext_97)->chunks_0 = chunks_13;
    (&kernelContext_97)->state_0 = state_15;
    (&kernelContext_97)->scratch_0 = scratch_13;
    (&kernelContext_97)->contact_state_0 = contact_state_13;
    (&kernelContext_97)->loads_0 = loads_13;
    (&kernelContext_97)->impactors_0 = impactors_13;
    (&kernelContext_97)->bonds_0 = bonds_13;
    (&kernelContext_97)->materials_0 = materials_13;
    (&kernelContext_97)->bond_dyn_0 = bond_dyn_13;
    threadgroup array<float4, int(32)> g_part_a_13;
    (&kernelContext_97)->g_part_a_0 = &g_part_a_13;
    threadgroup array<float4, int(32)> g_part_b_13;
    (&kernelContext_97)->g_part_b_0 = &g_part_b_13;
    threadgroup array<uint, int(5)> g_seen_13;
    (&kernelContext_97)->g_seen_0 = &g_seen_13;
    threadgroup uint g_wide_run_13;
    (&kernelContext_97)->g_wide_run_0 = &g_wide_run_13;
    threadgroup array<uint, int(4096)> g_label_13;
    (&kernelContext_97)->g_label_0 = &g_label_13;
    threadgroup uint g_changed_13;
    (&kernelContext_97)->g_changed_0 = &g_changed_13;
    threadgroup uint g_halt_13;
    (&kernelContext_97)->g_halt_0 = &g_halt_13;
    threadgroup uint g_run_13;
    (&kernelContext_97)->g_run_0 = &g_run_13;
    threadgroup uint g_flag_13;
    (&kernelContext_97)->g_flag_0 = &g_flag_13;
    threadgroup array<uint, int(1024)> g_mode_13;
    (&kernelContext_97)->g_mode_0 = &g_mode_13;
    island_frame_at_0(group_9.x, thread_9.x, &kernelContext_97);
    return;
}

void wide_chunks_at_0(uint gx_0, uint tid_21, KernelContext_0 thread* kernelContext_98)
{
    WideGroup_0 _S1444 = wide_group_0(kernelContext_98->params_0->wide_chunk_table_0, gx_0, kernelContext_98);
    thread Island_natural_0 _S1445 = *(kernelContext_98->islands_0+_S1444.island_3);
    bool _S1446 = wide_enter_1(tid_21, _S1444.island_3, kernelContext_98);
    if(!_S1446)
    {
        return;
    }
    uint _S1447 = (uint4((&_S1445)->info_0) ).x;
    bool anchored_0 = (_S1447 & 1U) != 0U;
    if((_S1447 & 16U) != 0U)
    {
        if(tid_21 == 0U)
        {
            *(kernelContext_98->scratch_0+(kernelContext_98->params_0->wide_base_0 + 8U * gx_0 + 6U)) = packed_float4(float4(0.0f) ) ;
        }
        return;
    }
    thread WideGroup_0 _S1448 = _S1444;
    Rigid_0 _S1449 = wide_rigid_frame_1(tid_21, &_S1445, &_S1448, kernelContext_98);
    thread float work_5 = 0.0f;
    thread float work_err_3 = 0.0f;
    float3 _S1450 = float3(0.0f) ;
    thread float3 tu_4 = _S1450;
    thread float3 pv_4 = _S1450;
    uint c_47 = _S1444.begin_0 + tid_21;
    if(c_47 < (_S1444.end_0))
    {
        float _S1451 = kernelContext_98->params_0->dt_0;
        bool _S1452 = (kernelContext_98->params_0->rigid_motion_loads_0) != 0U;
        uint _S1453 = wide_step_1(&_S1445, kernelContext_98);
        bool _S1454 = (_S1447 & 4U) != 0U;
        thread Rigid_0 _S1455 = _S1449;
        chunk_update_0(c_47, &_S1445, &_S1455, _S1451, _S1452, _S1453, _S1454, &work_5, &work_err_3, kernelContext_98);
        if(!anchored_0)
        {
            drift_moments_0(c_47, &tu_4, &pv_4, kernelContext_98);
        }
    }
    thread float3 wsum_1 = float3(work_5, work_err_3, 0.0f);
    thread float3 unused_4 = _S1450;
    group_sum3_0(tid_21, &wsum_1, &unused_4, kernelContext_98);
    bool _S1456 = !anchored_0;
    if(_S1456)
    {
        group_sum3_0(tid_21, &tu_4, &pv_4, kernelContext_98);
    }
    if(tid_21 == 0U)
    {
        uint _S1457 = 8U * gx_0;
        *(kernelContext_98->scratch_0+(kernelContext_98->params_0->wide_base_0 + _S1457 + 6U)) = packed_float4(float4(wsum_1, 0.0f)) ;
        if(_S1456)
        {
            wide_store_0(gx_0, 2U, tu_4, pv_4, kernelContext_98);
        }
        *(kernelContext_98->scratch_0+(kernelContext_98->params_0->wide_base_0 + _S1457 + 7U)) = packed_float4(float4(float((*kernelContext_98->g_seen_0)[0U]), float((*kernelContext_98->g_seen_0)[1U]), float((*kernelContext_98->g_seen_0)[2U]), 0.0f)) ;
    }
    return;
}

[[kernel]] void wide_chunks(uint3 group_10 [[threadgroup_position_in_grid]], uint3 thread_10 [[thread_position_in_threadgroup]], Params_0 constant* params_14 [[buffer(0)]], Island_natural_0 device* islands_14 [[buffer(9)]], uint device* index_14 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_14 [[buffer(3)]], packed_float4 device* state_16 [[buffer(6)]], packed_float4 device* scratch_14 [[buffer(8)]], packed_float4 device* contact_state_14 [[buffer(11)]], packed_float4 device* loads_14 [[buffer(5)]], Impactor_natural_0 device* impactors_14 [[buffer(10)]], BondStatic_natural_0 device* bonds_14 [[buffer(2)]], MaterialTable_0 constant* materials_14 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_14 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_99;
    (&kernelContext_99)->params_0 = params_14;
    (&kernelContext_99)->islands_0 = islands_14;
    (&kernelContext_99)->index_0 = index_14;
    (&kernelContext_99)->chunks_0 = chunks_14;
    (&kernelContext_99)->state_0 = state_16;
    (&kernelContext_99)->scratch_0 = scratch_14;
    (&kernelContext_99)->contact_state_0 = contact_state_14;
    (&kernelContext_99)->loads_0 = loads_14;
    (&kernelContext_99)->impactors_0 = impactors_14;
    (&kernelContext_99)->bonds_0 = bonds_14;
    (&kernelContext_99)->materials_0 = materials_14;
    (&kernelContext_99)->bond_dyn_0 = bond_dyn_14;
    threadgroup array<float4, int(32)> g_part_a_14;
    (&kernelContext_99)->g_part_a_0 = &g_part_a_14;
    threadgroup array<float4, int(32)> g_part_b_14;
    (&kernelContext_99)->g_part_b_0 = &g_part_b_14;
    threadgroup array<uint, int(5)> g_seen_14;
    (&kernelContext_99)->g_seen_0 = &g_seen_14;
    threadgroup uint g_wide_run_14;
    (&kernelContext_99)->g_wide_run_0 = &g_wide_run_14;
    threadgroup array<uint, int(4096)> g_label_14;
    (&kernelContext_99)->g_label_0 = &g_label_14;
    threadgroup uint g_changed_14;
    (&kernelContext_99)->g_changed_0 = &g_changed_14;
    threadgroup uint g_halt_14;
    (&kernelContext_99)->g_halt_0 = &g_halt_14;
    threadgroup uint g_run_14;
    (&kernelContext_99)->g_run_0 = &g_run_14;
    threadgroup uint g_flag_14;
    (&kernelContext_99)->g_flag_0 = &g_flag_14;
    threadgroup array<uint, int(1024)> g_mode_14;
    (&kernelContext_99)->g_mode_0 = &g_mode_14;
    wide_chunks_at_0(group_10.x, thread_10.x, &kernelContext_99);
    return;
}

[[kernel]] void sums_and_impactors(uint3 group_11 [[threadgroup_position_in_grid]], uint3 thread_11 [[thread_position_in_threadgroup]], Params_0 constant* params_15 [[buffer(0)]], Island_natural_0 device* islands_15 [[buffer(9)]], uint device* index_15 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_15 [[buffer(3)]], packed_float4 device* state_17 [[buffer(6)]], packed_float4 device* scratch_15 [[buffer(8)]], packed_float4 device* contact_state_15 [[buffer(11)]], packed_float4 device* loads_15 [[buffer(5)]], Impactor_natural_0 device* impactors_15 [[buffer(10)]], BondStatic_natural_0 device* bonds_15 [[buffer(2)]], MaterialTable_0 constant* materials_15 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_15 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_100;
    (&kernelContext_100)->params_0 = params_15;
    (&kernelContext_100)->islands_0 = islands_15;
    (&kernelContext_100)->index_0 = index_15;
    (&kernelContext_100)->chunks_0 = chunks_15;
    (&kernelContext_100)->state_0 = state_17;
    (&kernelContext_100)->scratch_0 = scratch_15;
    (&kernelContext_100)->contact_state_0 = contact_state_15;
    (&kernelContext_100)->loads_0 = loads_15;
    (&kernelContext_100)->impactors_0 = impactors_15;
    (&kernelContext_100)->bonds_0 = bonds_15;
    (&kernelContext_100)->materials_0 = materials_15;
    (&kernelContext_100)->bond_dyn_0 = bond_dyn_15;
    threadgroup array<float4, int(32)> g_part_a_15;
    (&kernelContext_100)->g_part_a_0 = &g_part_a_15;
    threadgroup array<float4, int(32)> g_part_b_15;
    (&kernelContext_100)->g_part_b_0 = &g_part_b_15;
    threadgroup array<uint, int(5)> g_seen_15;
    (&kernelContext_100)->g_seen_0 = &g_seen_15;
    threadgroup uint g_wide_run_15;
    (&kernelContext_100)->g_wide_run_0 = &g_wide_run_15;
    threadgroup array<uint, int(4096)> g_label_15;
    (&kernelContext_100)->g_label_0 = &g_label_15;
    threadgroup uint g_changed_15;
    (&kernelContext_100)->g_changed_0 = &g_changed_15;
    threadgroup uint g_halt_15;
    (&kernelContext_100)->g_halt_0 = &g_halt_15;
    threadgroup uint g_run_15;
    (&kernelContext_100)->g_run_0 = &g_run_15;
    threadgroup uint g_flag_15;
    (&kernelContext_100)->g_flag_0 = &g_flag_15;
    threadgroup array<uint, int(1024)> g_mode_15;
    (&kernelContext_100)->g_mode_0 = &g_mode_15;
    uint sums_groups_0 = (params_15->seg_count_0 + 255U) / 256U;
    uint _S1458 = group_11.x;
    if(_S1458 < sums_groups_0)
    {
        contact_sum_at_0(_S1458 * 256U + thread_11.x, &kernelContext_100);
    }
    else
    {
        impactor_integrate_at_0(_S1458 - sums_groups_0, thread_11.x, &kernelContext_100);
    }
    return;
}

[[kernel]] void islands_and_wide_chunks(uint3 group_12 [[threadgroup_position_in_grid]], uint3 thread_12 [[thread_position_in_threadgroup]], Params_0 constant* params_16 [[buffer(0)]], Island_natural_0 device* islands_16 [[buffer(9)]], uint device* index_16 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_16 [[buffer(3)]], packed_float4 device* state_18 [[buffer(6)]], packed_float4 device* scratch_16 [[buffer(8)]], packed_float4 device* contact_state_16 [[buffer(11)]], packed_float4 device* loads_16 [[buffer(5)]], Impactor_natural_0 device* impactors_16 [[buffer(10)]], BondStatic_natural_0 device* bonds_16 [[buffer(2)]], MaterialTable_0 constant* materials_16 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_16 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_101;
    (&kernelContext_101)->params_0 = params_16;
    (&kernelContext_101)->islands_0 = islands_16;
    (&kernelContext_101)->index_0 = index_16;
    (&kernelContext_101)->chunks_0 = chunks_16;
    (&kernelContext_101)->state_0 = state_18;
    (&kernelContext_101)->scratch_0 = scratch_16;
    (&kernelContext_101)->contact_state_0 = contact_state_16;
    (&kernelContext_101)->loads_0 = loads_16;
    (&kernelContext_101)->impactors_0 = impactors_16;
    (&kernelContext_101)->bonds_0 = bonds_16;
    (&kernelContext_101)->materials_0 = materials_16;
    (&kernelContext_101)->bond_dyn_0 = bond_dyn_16;
    threadgroup array<float4, int(32)> g_part_a_16;
    (&kernelContext_101)->g_part_a_0 = &g_part_a_16;
    threadgroup array<float4, int(32)> g_part_b_16;
    (&kernelContext_101)->g_part_b_0 = &g_part_b_16;
    threadgroup array<uint, int(5)> g_seen_16;
    (&kernelContext_101)->g_seen_0 = &g_seen_16;
    threadgroup uint g_wide_run_16;
    (&kernelContext_101)->g_wide_run_0 = &g_wide_run_16;
    threadgroup array<uint, int(4096)> g_label_16;
    (&kernelContext_101)->g_label_0 = &g_label_16;
    threadgroup uint g_changed_16;
    (&kernelContext_101)->g_changed_0 = &g_changed_16;
    threadgroup uint g_halt_16;
    (&kernelContext_101)->g_halt_0 = &g_halt_16;
    threadgroup uint g_run_16;
    (&kernelContext_101)->g_run_0 = &g_run_16;
    threadgroup uint g_flag_16;
    (&kernelContext_101)->g_flag_0 = &g_flag_16;
    threadgroup array<uint, int(1024)> g_mode_16;
    (&kernelContext_101)->g_mode_0 = &g_mode_16;
    uint _S1459 = group_12.x;
    if(_S1459 < (params_16->halt_index_0))
    {
        island_frame_at_0(_S1459, thread_12.x, &kernelContext_101);
    }
    else
    {
        wide_chunks_at_0(_S1459 - params_16->halt_index_0, thread_12.x, &kernelContext_101);
    }
    return;
}

uint pc_k_0(const Island_0 thread* isl_29, KernelContext_0 thread* kernelContext_102)
{
    return isl_29->info_0.w - kernelContext_102->params_0->step_start_0;
}

void pc_store_rigid_0(uint i_24, const Rigid_0 thread* rg_17, KernelContext_0 thread* kernelContext_103)
{
    uint at_7 = kernelContext_103->params_0->pi_base_0 + 16U * i_24;
    packed_float4 device* _S1460 = kernelContext_103->scratch_0+at_7;
    float4 _S1461 = quat_vec_0(&rg_17->rot_1);
    *_S1460 = packed_float4(_S1461) ;
    *(kernelContext_103->scratch_0+(at_7 + 1U)) = packed_float4(rg_17->rot_err_0) ;
    *(kernelContext_103->scratch_0+(at_7 + 2U)) = packed_float4(float4(rg_17->pos_0, 0.0f)) ;
    *(kernelContext_103->scratch_0+(at_7 + 3U)) = packed_float4(float4(rg_17->pos_err_0, 0.0f)) ;
    *(kernelContext_103->scratch_0+(at_7 + 4U)) = packed_float4(float4(rg_17->vel_0, 0.0f)) ;
    *(kernelContext_103->scratch_0+(at_7 + 5U)) = packed_float4(float4(rg_17->vel_err_0, 0.0f)) ;
    *(kernelContext_103->scratch_0+(at_7 + 6U)) = packed_float4(float4(rg_17->w_5, 0.0f)) ;
    *(kernelContext_103->scratch_0+(at_7 + 7U)) = packed_float4(float4(rg_17->l_1, 0.0f)) ;
    *(kernelContext_103->scratch_0+(at_7 + 8U)) = packed_float4(float4(rg_17->l_err_0, 0.0f)) ;
    *(kernelContext_103->scratch_0+(at_7 + 9U)) = packed_float4(float4(rg_17->torque_0, 0.0f)) ;
    *(kernelContext_103->scratch_0+(at_7 + 10U)) = packed_float4(float4(rg_17->a_10, 0.0f)) ;
    *(kernelContext_103->scratch_0+(at_7 + 11U)) = packed_float4(float4(rg_17->alpha_0, 0.0f)) ;
    return;
}

Rigid_0 pc_load_rigid_0(uint i_25, KernelContext_0 thread* kernelContext_104)
{
    uint at_8 = kernelContext_104->params_0->pi_base_0 + 16U * i_25;
    thread Rigid_0 rg_18;
    (&rg_18)->rot_1 = quat_of_0(float4(*(kernelContext_104->scratch_0+at_8)) );
    (&rg_18)->rot_err_0 = float4(*(kernelContext_104->scratch_0+(at_8 + 1U))) ;
    (&rg_18)->pos_0 = (float4(*(kernelContext_104->scratch_0+(at_8 + 2U))) ).xyz;
    (&rg_18)->pos_err_0 = (float4(*(kernelContext_104->scratch_0+(at_8 + 3U))) ).xyz;
    (&rg_18)->vel_0 = (float4(*(kernelContext_104->scratch_0+(at_8 + 4U))) ).xyz;
    (&rg_18)->vel_err_0 = (float4(*(kernelContext_104->scratch_0+(at_8 + 5U))) ).xyz;
    (&rg_18)->w_5 = (float4(*(kernelContext_104->scratch_0+(at_8 + 6U))) ).xyz;
    (&rg_18)->l_1 = (float4(*(kernelContext_104->scratch_0+(at_8 + 7U))) ).xyz;
    (&rg_18)->l_err_0 = (float4(*(kernelContext_104->scratch_0+(at_8 + 8U))) ).xyz;
    (&rg_18)->torque_0 = (float4(*(kernelContext_104->scratch_0+(at_8 + 9U))) ).xyz;
    (&rg_18)->a_10 = (float4(*(kernelContext_104->scratch_0+(at_8 + 10U))) ).xyz;
    (&rg_18)->alpha_0 = (float4(*(kernelContext_104->scratch_0+(at_8 + 11U))) ).xyz;
    return rg_18;
}

bool contact_stopped_2(uint _S1462, KernelContext_0 thread* kernelContext_105)
{
    Island_natural_0 device* _S1463 = kernelContext_105->islands_0+_S1462;
    uint4 _S1464 = uint4((kernelContext_105->islands_0+kernelContext_105->params_0->halt_index_0)->info_0) ;
    bool _S1465;
    if(((_S1464.z) & 1U) != 0U)
    {
        _S1465 = true;
    }
    else
    {
        uint _S1466 = _S1464.y;
        if(_S1466 != 0U)
        {
            _S1465 = _S1466 <= ((uint4(_S1463->info_0) ).w);
        }
        else
        {
            _S1465 = false;
        }
    }
    return _S1465;
}

uint pc_k_1(uint _S1467, KernelContext_0 thread* kernelContext_106)
{
    return (uint4((kernelContext_106->islands_0+_S1467)->info_0) ).w - kernelContext_106->params_0->step_start_0;
}

void pc_sum_0(uint _S1468, float3 thread* _S1469, float3 thread* _S1470, KernelContext_0 thread* kernelContext_107)
{
    uint4 _S1471 = uint4((kernelContext_107->islands_0+_S1468)->range_0) ;
    uint c_48 = _S1471.x;
    for(;;)
    {
        if(c_48 < (_S1471.y))
        {
        }
        else
        {
            break;
        }
        uint _S1472 = 2U * c_48;
        *_S1469 = *_S1469 + (float4(*(kernelContext_107->scratch_0+(kernelContext_107->params_0->pc_base_0 + _S1472))) ).xyz;
        *_S1470 = *_S1470 + (float4(*(kernelContext_107->scratch_0+(kernelContext_107->params_0->pc_base_0 + _S1472 + 1U))) ).xyz;
        c_48 = c_48 + 1U;
    }
    return;
}

Rigid_0 rigid_of_2(uint _S1473, KernelContext_0 thread* kernelContext_108)
{
    Island_natural_0 device* _S1474 = kernelContext_108->islands_0+_S1473;
    thread Rigid_0 rg_19;
    (&rg_19)->rot_1 = quat_of_0(float4(_S1474->rotation_0) );
    (&rg_19)->rot_err_0 = float4(_S1474->rotation_err_0) ;
    (&rg_19)->pos_0 = (float4(_S1474->position_0) ).xyz;
    (&rg_19)->pos_err_0 = (float4(_S1474->position_err_0) ).xyz;
    (&rg_19)->vel_0 = (float4(_S1474->velocity_0) ).xyz;
    (&rg_19)->vel_err_0 = (float4(_S1474->velocity_err_0) ).xyz;
    (&rg_19)->w_5 = (float4(_S1474->angular_velocity_0) ).xyz;
    (&rg_19)->l_1 = (float4(_S1474->momentum_0) ).xyz;
    (&rg_19)->l_err_0 = (float4(_S1474->momentum_err_0) ).xyz;
    float3 _S1475 = float3(0.0f) ;
    (&rg_19)->torque_0 = _S1475;
    (&rg_19)->a_10 = _S1475;
    (&rg_19)->alpha_0 = _S1475;
    return rg_19;
}

void net_load_2(uint _S1476, uint _S1477, const Rigid_0 thread* _S1478, uint _S1479, float _S1480, bool _S1481, float3 thread* _S1482, float3 thread* _S1483, KernelContext_0 thread* kernelContext_109)
{
    Island_natural_0 _S1484 = *(kernelContext_109->islands_0+_S1477);
    ChunkStatic_natural_0 device* _S1485 = kernelContext_109->chunks_0+_S1476;
    thread float3 fl_2;
    thread float3 tl_2;
    thread float3 rep_f_4;
    thread float3 rep_m_4;
    chunk_loads_0(_S1476, _S1476, &_S1478->rot_1, _S1479, _S1480, _S1481, 0.0f, &fl_2, &tl_2, &rep_f_4, &rep_m_4, kernelContext_109);
    float4 _S1486 = float4(_S1485->center_0) ;
    float3 fc_5 = fl_2 + kernelContext_109->params_0->gravity_0.xyz * float3(_S1486.w) ;
    float3 _S1487 = _S1486.xyz;
    float3 _S1488 = (float4(_S1484.com_0) ).xyz;
    float3 _S1489 = rotate_0(&_S1478->rot_1, _S1487 + (float4(*(kernelContext_109->state_0+4U * _S1476)) ).xyz - _S1488);
    *_S1482 = *_S1482 + fc_5;
    *_S1483 = *_S1483 + (cross(_S1489, fc_5) + tl_2);
    uint4 _S1490 = uint4(_S1485->load_range_0) ;
    if((_S1490.y) > (_S1490.x))
    {
        float3 _S1491 = rotate_0(&_S1478->rot_1, rep_f_4);
        *_S1482 = *_S1482 + _S1491;
        float3 _S1492 = rotate_0(&_S1478->rot_1, _S1487 - _S1488);
        float3 _S1493 = cross(_S1492, _S1491);
        float3 _S1494 = rotate_0(&_S1478->rot_1, rep_m_4);
        *_S1483 = *_S1483 + (_S1493 + _S1494);
    }
    return;
}

void chunk_update_2(uint _S1495, uint _S1496, const Rigid_0 thread* _S1497, float _S1498, bool _S1499, uint _S1500, bool _S1501, float thread* _S1502, float thread* _S1503, KernelContext_0 thread* kernelContext_110)
{
    Island_natural_0 device* _S1504 = kernelContext_110->islands_0+_S1496;
    ChunkStatic_natural_0 device* _S1505 = kernelContext_110->chunks_0+_S1495;
    float3 _S1506 = float3(0.0f) ;
    uint _S1507 = kernelContext_110->index_0[_S1495];
    float peak_2 = 0.0f;
    uint e_9 = _S1507;
    float3 fi_7 = _S1506;
    float3 mi_10 = _S1506;
    for(;;)
    {
        if(e_9 < (kernelContext_110->index_0)[_S1495 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_8 = kernelContext_110->index_0[e_9];
        uint _S1508 = 3U * (entry_8 >> 1U);
        float4 _S1509 = float4(*(kernelContext_110->scratch_0+_S1508)) ;
        if((entry_8 & 1U) == 0U)
        {
            float3 mi_11 = mi_10 + (float4(*(kernelContext_110->scratch_0+(_S1508 + 1U))) ).xyz;
            fi_7 = fi_7 + _S1509.xyz;
            mi_10 = mi_11;
        }
        else
        {
            float3 mi_12 = mi_10 + (float4(*(kernelContext_110->scratch_0+(_S1508 + 2U))) ).xyz;
            fi_7 = fi_7 + - _S1509.xyz;
            mi_10 = mi_12;
        }
        float _S1510 = max(peak_2, _S1509.w);
        uint _S1511 = e_9 + 1U;
        peak_2 = _S1510;
        e_9 = _S1511;
    }
    uint _S1512 = 4U * _S1495;
    float3 u_8 = (float4(*(kernelContext_110->state_0+_S1512)) ).xyz;
    uint _S1513 = _S1512 + 1U;
    float3 th_10 = (float4(*(kernelContext_110->state_0+_S1513)) ).xyz;
    uint _S1514 = _S1512 + 2U;
    float3 v_17 = (float4(*(kernelContext_110->state_0+_S1514)) ).xyz;
    uint _S1515 = _S1512 + 3U;
    float3 w_12 = (float4(*(kernelContext_110->state_0+_S1515)) ).xyz;
    float4 _S1516 = float4(_S1505->center_0) ;
    float mass_2 = _S1516.w;
    float3 _S1517 = _S1516.xyz;
    float3 _S1518 = (float4(_S1504->com_0) ).xyz;
    float3 _S1519 = rotate_0(&_S1497->rot_1, _S1517 + u_8 - _S1518);
    thread float3 f_load_2;
    thread float3 t_load_2;
    thread float3 rep_f_5;
    thread float3 rep_m_5;
    chunk_loads_0(_S1495, _S1495, &_S1497->rot_1, _S1500, _S1498, _S1501, _S1498, &f_load_2, &t_load_2, &rep_f_5, &rep_m_5, kernelContext_110);
    record_chunk_load_0(_S1495, f_load_2, t_load_2, kernelContext_110);
    float3 _S1520 = float3(mass_2) ;
    float3 f_world_6 = f_load_2 + kernelContext_110->params_0->gravity_0.xyz * _S1520;
    float3 t_world_6 = t_load_2;
    float3 f_world_7;
    float3 t_world_7;
    if(_S1499)
    {
        float3 f_world_8 = f_world_6 - (_S1497->a_10 + cross(_S1497->alpha_0, _S1519) + cross(_S1497->w_5, cross(_S1497->w_5, _S1519))) * _S1520;
        float4 _S1521 = float4(_S1505->inertia0_1) ;
        float4 _S1522 = float4(_S1505->inertia1_1) ;
        float4 _S1523 = float4(_S1505->inertia2_1) ;
        float3 _S1524 = world_mul_0(&_S1497->rot_1, _S1521, _S1522, _S1523, _S1497->alpha_0);
        float3 _S1525 = world_mul_0(&_S1497->rot_1, _S1521, _S1522, _S1523, _S1497->w_5);
        float3 t_world_8 = t_world_6 - (_S1524 + cross(_S1497->w_5, _S1525));
        f_world_7 = f_world_8;
        t_world_7 = t_world_8;
    }
    else
    {
        f_world_7 = f_world_6;
        t_world_7 = t_world_6;
    }
    float3 _S1526 = inverse_rotate_0(&_S1497->rot_1, f_world_7);
    float3 _S1527 = inverse_rotate_0(&_S1497->rot_1, t_world_7);
    float3 f_ext_2;
    float3 m_ext_4;
    if(_S1499)
    {
        float3 _S1528 = inverse_rotate_0(&_S1497->rot_1, _S1497->w_5);
        float4 _S1529 = float4(_S1505->inertia0_1) ;
        float4 _S1530 = float4(_S1505->inertia1_1) ;
        float4 _S1531 = float4(_S1505->inertia2_1) ;
        float3 i_w_2 = rows_mul_0(_S1529, _S1530, _S1531, w_12);
        float3 m_ext_5 = _S1527 - (cross(_S1528, i_w_2) + cross(w_12, rows_mul_0(_S1529, _S1530, _S1531, _S1528)) + cross(w_12, i_w_2));
        f_ext_2 = _S1526 - cross(_S1528, v_17) * float3((2.0f * mass_2)) ;
        m_ext_4 = m_ext_5;
    }
    else
    {
        f_ext_2 = _S1526;
        m_ext_4 = _S1527;
    }
    float3 f_20 = f_ext_2 + rep_f_5 + fi_7;
    float3 m_9 = m_ext_4 + rep_m_5 + mi_10;
    uint support_3 = (uint4(_S1505->info_1) ).x;
    float3 _S1532 = float3((float4(*(kernelContext_110->state_0+_S1513)) ).w, (float4(*(kernelContext_110->state_0+_S1514)) ).w, (float4(*(kernelContext_110->state_0+_S1515)) ).w);
    float3 reaction_3;
    float3 u_9;
    float3 th_11;
    float3 v_18;
    float3 w_13;
    if(support_3 == 1U)
    {
        reaction_3 = - f_20;
        u_9 = u_8;
        th_11 = th_10;
        v_18 = _S1506;
        w_13 = _S1506;
    }
    else
    {
        float4 _S1533 = float4(_S1505->scale_0) ;
        float3 w_14 = w_12 + rows_mul_0(float4(_S1505->inv0_1) , float4(_S1505->inv1_1) , float4(_S1505->inv2_1) , m_9) * float3((_S1498 * _S1533.z)) ;
        float3 _S1534 = float3(_S1498) ;
        float3 th_12 = th_10 + w_14 * _S1534;
        if(support_3 == 2U)
        {
            reaction_3 = - f_20;
            u_9 = u_8;
            th_11 = _S1506;
        }
        else
        {
            float3 v_19 = v_17 + f_20 * float3((_S1498 * _S1533.y)) ;
            float3 u_10 = u_8 + v_19 * _S1534;
            reaction_3 = _S1532;
            u_9 = u_10;
            th_11 = v_19;
        }
        float3 _S1535 = th_11;
        th_11 = th_12;
        v_18 = _S1535;
        w_13 = w_14;
    }
    *(kernelContext_110->state_0+_S1512) = packed_float4(float4(u_9, peak_2)) ;
    *(kernelContext_110->state_0+_S1513) = packed_float4(float4(th_11, reaction_3.x)) ;
    *(kernelContext_110->state_0+_S1514) = packed_float4(float4(v_18, reaction_3.y)) ;
    *(kernelContext_110->state_0+_S1515) = packed_float4(float4(w_13, reaction_3.z)) ;
    float3 _S1536 = rotate_0(&_S1497->rot_1, _S1517 + u_9 - _S1518);
    float3 _S1537 = _S1497->vel_0 + _S1497->vel_err_0 + cross(_S1497->w_5, _S1536);
    float3 _S1538 = rotate_0(&_S1497->rot_1, v_18);
    float3 v_world_2 = _S1537 + _S1538;
    float3 _S1539 = rotate_0(&_S1497->rot_1, w_13);
    comp_add1_0(_S1502, _S1503, (dot(f_load_2, v_world_2) + dot(t_load_2, _S1497->w_5 + _S1539)) * _S1498);
    return;
}

[[kernel]] void contact_frames(uint3 group_13 [[threadgroup_position_in_grid]], uint3 thread_13 [[thread_position_in_threadgroup]], Params_0 constant* params_17 [[buffer(0)]], Island_natural_0 device* islands_17 [[buffer(9)]], uint device* index_17 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_17 [[buffer(3)]], packed_float4 device* state_19 [[buffer(6)]], packed_float4 device* scratch_17 [[buffer(8)]], packed_float4 device* contact_state_17 [[buffer(11)]], packed_float4 device* loads_17 [[buffer(5)]], Impactor_natural_0 device* impactors_17 [[buffer(10)]], BondStatic_natural_0 device* bonds_17 [[buffer(2)]], MaterialTable_0 constant* materials_17 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_17 [[buffer(7)]])
{
    uint mode_1;
    uint mode_2;
    uint mode_3;
    bool contact_6;
    bool _S1540;
    uint c_49;
    thread KernelContext_0 kernelContext_111;
    (&kernelContext_111)->params_0 = params_17;
    (&kernelContext_111)->islands_0 = islands_17;
    (&kernelContext_111)->index_0 = index_17;
    (&kernelContext_111)->chunks_0 = chunks_17;
    (&kernelContext_111)->state_0 = state_19;
    (&kernelContext_111)->scratch_0 = scratch_17;
    (&kernelContext_111)->contact_state_0 = contact_state_17;
    (&kernelContext_111)->loads_0 = loads_17;
    (&kernelContext_111)->impactors_0 = impactors_17;
    (&kernelContext_111)->bonds_0 = bonds_17;
    (&kernelContext_111)->materials_0 = materials_17;
    (&kernelContext_111)->bond_dyn_0 = bond_dyn_17;
    threadgroup array<float4, int(32)> g_part_a_17;
    (&kernelContext_111)->g_part_a_0 = &g_part_a_17;
    threadgroup array<float4, int(32)> g_part_b_17;
    (&kernelContext_111)->g_part_b_0 = &g_part_b_17;
    threadgroup array<uint, int(5)> g_seen_17;
    (&kernelContext_111)->g_seen_0 = &g_seen_17;
    threadgroup uint g_wide_run_17;
    (&kernelContext_111)->g_wide_run_0 = &g_wide_run_17;
    threadgroup array<uint, int(4096)> g_label_17;
    (&kernelContext_111)->g_label_0 = &g_label_17;
    threadgroup uint g_changed_17;
    (&kernelContext_111)->g_changed_0 = &g_changed_17;
    threadgroup uint g_halt_17;
    (&kernelContext_111)->g_halt_0 = &g_halt_17;
    threadgroup uint g_run_17;
    (&kernelContext_111)->g_run_0 = &g_run_17;
    threadgroup uint g_flag_17;
    (&kernelContext_111)->g_flag_0 = &g_flag_17;
    threadgroup array<uint, int(1024)> g_mode_17;
    (&kernelContext_111)->g_mode_0 = &g_mode_17;
    uint _S1541 = thread_13.x;
    uint _S1542 = params_17->halt_index_0;
    float _S1543 = params_17->dt_0;
    bool _S1544 = (params_17->fracture_0) != 0U;
    bool _S1545 = (params_17->rigid_motion_loads_0) != 0U;
    bool _S1546 = (params_17->solve_mode_0) == 1U;
    uint s_13 = 0U;
    for(;;)
    {
        if(s_13 < ((&kernelContext_111)->params_0->pc_steps_0))
        {
        }
        else
        {
            break;
        }
        seen_clear_0(_S1541, &kernelContext_111);
        bool _S1547 = _S1541 == 0U;
        if(_S1547)
        {
            *(&kernelContext_111)->g_flag_0 = 0U;
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);
        uint i_26 = _S1541;
        for(;;)
        {
            if(i_26 < _S1542)
            {
            }
            else
            {
                break;
            }
            uint4 _S1548 = uint4(((&kernelContext_111)->islands_0+i_26)->info_0) ;
            uint x_16 = _S1548.x;
            if((x_16 & 4U) != 0U)
            {
                contact_6 = (x_16 & 2U) == 0U;
            }
            else
            {
                contact_6 = false;
            }
            if(contact_6)
            {
                _S1540 = ((_S1548.z) & 1U) == 0U;
            }
            else
            {
                _S1540 = false;
            }
            bool _S1549;
            if(_S1540)
            {
                _S1549 = (_S1548.y) > 0U;
            }
            else
            {
                _S1549 = false;
            }
            bool _S1550;
            if(_S1549)
            {
                bool _S1551 = contact_stopped_2(i_26, &kernelContext_111);
                _S1550 = !_S1551;
            }
            else
            {
                _S1550 = false;
            }
            if(_S1550)
            {
                bool quiet_2 = (x_16 & 32U) != 0U;
                bool settled_1 = (x_16 & 16U) != 0U;
                bool _S1552;
                if(!((x_16 & 1U) != 0U))
                {
                    _S1552 = !quiet_2;
                }
                else
                {
                    _S1552 = false;
                }
                if(_S1552)
                {
                    mode_1 = 13U;
                }
                else
                {
                    mode_1 = 1U;
                }
                bool _S1553;
                if(!settled_1)
                {
                    _S1553 = !quiet_2;
                }
                else
                {
                    _S1553 = false;
                }
                if(_S1553)
                {
                    mode_2 = mode_1 | 2U;
                }
                else
                {
                    mode_2 = mode_1;
                }
                bool _S1554;
                if(settled_1)
                {
                    _S1554 = !quiet_2;
                }
                else
                {
                    _S1554 = false;
                }
                if(_S1554)
                {
                    mode_3 = mode_2 | 128U;
                }
                else
                {
                    mode_3 = mode_2;
                }
                *(&kernelContext_111)->g_flag_0 = 1U;
                mode_1 = mode_3;
            }
            else
            {
                mode_1 = 0U;
            }
            (*(&kernelContext_111)->g_mode_0)[i_26] = mode_1;
            i_26 = i_26 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);
        if((*(&kernelContext_111)->g_flag_0) == 0U)
        {
            break;
        }
        uint _S1555 = _S1541 % 32U;
        mode_1 = _S1541 / 32U;
        for(;;)
        {
            if(mode_1 < ((&kernelContext_111)->params_0->pair_count_0))
            {
            }
            else
            {
                break;
            }
            bool _S1556 = stopped_0(&kernelContext_111);
            bool _S1557 = pair_any_0(_S1556, 32U);
            if(!_S1557)
            {
                pair_contact_0(mode_1, _S1555, 32U, &kernelContext_111);
            }
            mode_1 = mode_1 + 8U;
        }
        mode_2 = _S1541 / 32U;
        for(;;)
        {
            if(mode_2 < ((&kernelContext_111)->params_0->cand_count_0))
            {
            }
            else
            {
                break;
            }
            bool _S1558 = stopped_0(&kernelContext_111);
            bool _S1559 = pair_any_0(_S1558, 32U);
            if(!_S1559)
            {
                impactor_candidate_forces_0(mode_2, _S1555, 32U, &kernelContext_111);
            }
            mode_2 = mode_2 + 8U;
        }
        mode_3 = _S1541;
        for(;;)
        {
            if(mode_3 < ((&kernelContext_111)->params_0->chunk_count_0))
            {
            }
            else
            {
                break;
            }
            travel_check_0(mode_3, &kernelContext_111);
            mode_3 = mode_3 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        if((((uint4(((&kernelContext_111)->islands_0+params_17->halt_index_0)->info_0) ).z) & 1U) != 0U)
        {
            break;
        }
        uint g_3 = _S1541;
        for(;;)
        {
            if(g_3 < ((&kernelContext_111)->params_0->seg_count_0))
            {
            }
            else
            {
                break;
            }
            contact_sum_at_0(g_3, &kernelContext_111);
            g_3 = g_3 + 256U;
        }
        uint ii_3 = 0U;
        for(;;)
        {
            if(ii_3 < ((&kernelContext_111)->params_0->impactor_count_0))
            {
            }
            else
            {
                break;
            }
            impactor_integrate_at_0(ii_3, _S1541, &kernelContext_111);
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            ii_3 = ii_3 + 1U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_50 = _S1541;
        for(;;)
        {
            if(c_50 < ((&kernelContext_111)->params_0->chunk_count_0))
            {
            }
            else
            {
                break;
            }
            uint i_27 = (uint4(((&kernelContext_111)->chunks_0+c_50)->info_1) ).y;
            if((((*(&kernelContext_111)->g_mode_0)[i_27]) & 128U) == 0U)
            {
                c_50 = c_50 + 256U;
                continue;
            }
            Quat_0 _S1560 = quat_of_0(float4(((&kernelContext_111)->islands_0+i_27)->rotation_0) );
            uint _S1561 = pc_k_1(i_27, &kernelContext_111);
            thread Quat_0 _S1562 = _S1560;
            float _S1563 = settled_chunk_load_0(c_50, &_S1562, _S1561, _S1543, true, &kernelContext_111);
            uint _S1564 = 2U * c_50;
            *((&kernelContext_111)->scratch_0+((&kernelContext_111)->params_0->pc_base_0 + _S1564)) = packed_float4(float4(_S1563, 0.0f, 0.0f, 0.0f)) ;
            *((&kernelContext_111)->scratch_0+((&kernelContext_111)->params_0->pc_base_0 + _S1564 + 1U)) = packed_float4(float4(0.0f) ) ;
            c_50 = c_50 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint i_28 = _S1541;
        for(;;)
        {
            if(i_28 < _S1542)
            {
            }
            else
            {
                break;
            }
            uint mode_4 = (*(&kernelContext_111)->g_mode_0)[i_28];
            if((((*(&kernelContext_111)->g_mode_0)[i_28]) & 128U) == 0U)
            {
                i_28 = i_28 + 256U;
                continue;
            }
            Island_natural_0 isl_30 = *((&kernelContext_111)->islands_0+i_28);
            float3 _S1565 = float3(0.0f) ;
            thread float3 norm_2 = _S1565;
            thread float3 unused_5 = _S1565;
            pc_sum_0(i_28, &norm_2, &unused_5, &kernelContext_111);
            if(_S1546)
            {
                float4 _S1566 = float4(isl_30.energy_0) ;
                contact_6 = (abs(norm_2.x - _S1566.z)) > (_S1566.w);
            }
            else
            {
                contact_6 = false;
            }
            if(contact_6)
            {
                (*(&kernelContext_111)->g_mode_0)[i_28] = (mode_4 | 2U) | 64U;
            }
            i_28 = i_28 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_51 = _S1541;
        for(;;)
        {
            if(c_51 < ((&kernelContext_111)->params_0->chunk_count_0))
            {
            }
            else
            {
                break;
            }
            uint i_29 = (uint4(((&kernelContext_111)->chunks_0+c_51)->info_1) ).y;
            if((((*(&kernelContext_111)->g_mode_0)[i_29]) & 4U) == 0U)
            {
                c_51 = c_51 + 256U;
                continue;
            }
            float3 _S1567 = float3(0.0f) ;
            thread float3 f_21 = _S1567;
            thread float3 t_21 = _S1567;
            Rigid_0 _S1568 = rigid_of_2(i_29, &kernelContext_111);
            uint _S1569 = pc_k_1(i_29, &kernelContext_111);
            thread Rigid_0 _S1570 = _S1568;
            net_load_2(c_51, i_29, &_S1570, _S1569, _S1543, true, &f_21, &t_21, &kernelContext_111);
            uint _S1571 = 2U * c_51;
            *((&kernelContext_111)->scratch_0+((&kernelContext_111)->params_0->pc_base_0 + _S1571)) = packed_float4(float4(f_21, 0.0f)) ;
            *((&kernelContext_111)->scratch_0+((&kernelContext_111)->params_0->pc_base_0 + _S1571 + 1U)) = packed_float4(float4(t_21, 0.0f)) ;
            c_51 = c_51 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint i_30 = _S1541;
        for(;;)
        {
            if(i_30 < _S1542)
            {
            }
            else
            {
                break;
            }
            uint mode_5 = (*(&kernelContext_111)->g_mode_0)[i_30];
            if((((*(&kernelContext_111)->g_mode_0)[i_30]) & 1U) == 0U)
            {
                i_30 = i_30 + 256U;
                continue;
            }
            thread Island_natural_0 _S1572 = *((&kernelContext_111)->islands_0+i_30);
            Rigid_0 _S1573 = rigid_of_2(i_30, &kernelContext_111);
            thread Rigid_0 rg_20 = _S1573;
            if((mode_5 & 4U) != 0U)
            {
                float3 _S1574 = float3(0.0f) ;
                thread float3 f_22 = _S1574;
                thread float3 t_22 = _S1574;
                pc_sum_0(i_30, &f_22, &t_22, &kernelContext_111);
                rigid_acceleration_0(&_S1572, &rg_20, f_22, t_22);
            }
            thread Rigid_0 _S1575 = rg_20;
            pc_store_rigid_0(i_30, &_S1575, &kernelContext_111);
            if((mode_5 & 6U) == 6U)
            {
                (*(&kernelContext_111)->g_mode_0)[i_30] = mode_5 | 16U;
            }
            i_30 = i_30 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint b_31 = _S1541;
        for(;;)
        {
            if(b_31 < ((&kernelContext_111)->params_0->bond_count_0))
            {
            }
            else
            {
                break;
            }
            uint i_31 = (uint4(((&kernelContext_111)->bonds_0+b_31)->law_0.ids_0) ).w;
            uint mode_6 = (*(&kernelContext_111)->g_mode_0)[i_31];
            if((((*(&kernelContext_111)->g_mode_0)[i_31]) & 2U) == 0U)
            {
                b_31 = b_31 + 256U;
                continue;
            }
            uint4 _S1576 = uint4(((&kernelContext_111)->islands_0+i_31)->info_0) ;
            bool _S1577 = bond_update_0(b_31, _S1543, _S1544, _S1576.w + 1U, ((_S1576.x) & 8U) != 0U, &kernelContext_111);
            if(_S1577)
            {
                (*(&kernelContext_111)->g_mode_0)[i_31] = mode_6 | 32U;
            }
            b_31 = b_31 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_52 = _S1541;
        for(;;)
        {
            if(c_52 < ((&kernelContext_111)->params_0->chunk_count_0))
            {
            }
            else
            {
                break;
            }
            uint i_32 = (uint4(((&kernelContext_111)->chunks_0+c_52)->info_1) ).y;
            if((((*(&kernelContext_111)->g_mode_0)[i_32]) & 2U) == 0U)
            {
                c_52 = c_52 + 256U;
                continue;
            }
            thread float work_6 = 0.0f;
            thread float work_err_4 = 0.0f;
            Rigid_0 _S1578 = pc_load_rigid_0(i_32, &kernelContext_111);
            uint _S1579 = pc_k_1(i_32, &kernelContext_111);
            thread Rigid_0 _S1580 = _S1578;
            chunk_update_2(c_52, i_32, &_S1580, _S1543, _S1545, _S1579, true, &work_6, &work_err_4, &kernelContext_111);
            uint _S1581 = 2U * c_52;
            *((&kernelContext_111)->scratch_0+((&kernelContext_111)->params_0->pc_base_0 + _S1581)) = packed_float4(float4(work_6, work_err_4, 0.0f, 0.0f)) ;
            *((&kernelContext_111)->scratch_0+((&kernelContext_111)->params_0->pc_base_0 + _S1581 + 1U)) = packed_float4(float4(0.0f) ) ;
            c_52 = c_52 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint i_33 = _S1541;
        for(;;)
        {
            if(i_33 < _S1542)
            {
            }
            else
            {
                break;
            }
            uint mode_7 = (*(&kernelContext_111)->g_mode_0)[i_33];
            if((((*(&kernelContext_111)->g_mode_0)[i_33]) & 1U) == 0U)
            {
                i_33 = i_33 + 256U;
                continue;
            }
            Island_natural_0 device* _S1582 = (&kernelContext_111)->islands_0+i_33;
            uint4 _S1583 = uint4((*_S1582).info_0) ;
            float4 _S1584 = float4((*_S1582).com_0) ;
            float4 _S1585 = float4((*_S1582).inertia0_0) ;
            float4 _S1586 = float4((*_S1582).inertia1_0) ;
            float4 _S1587 = float4((*_S1582).inertia2_0) ;
            float4 _S1588 = float4((*_S1582).inv0_0) ;
            float4 _S1589 = float4((*_S1582).inv1_0) ;
            float4 _S1590 = float4((*_S1582).inv2_0) ;
            float4 _S1591 = float4((*_S1582).wcom_0) ;
            float4 _S1592 = float4((*_S1582).winv0_0) ;
            float4 _S1593 = float4((*_S1582).winv1_0) ;
            float4 _S1594 = float4((*_S1582).winv2_0) ;
            float4 _S1595 = float4((*_S1582).rotation_0) ;
            float4 _S1596 = float4((*_S1582).position_0) ;
            float4 _S1597 = float4((*_S1582).position_err_0) ;
            float4 _S1598 = float4((*_S1582).velocity_0) ;
            float4 _S1599 = float4((*_S1582).velocity_err_0) ;
            float4 _S1600 = float4((*_S1582).angular_velocity_0) ;
            uint4 _S1601 = uint4((*_S1582).probes_0) ;
            float4 _S1602 = float4((*_S1582).energy_0) ;
            float4 _S1603 = float4((*_S1582).rotation_err_0) ;
            float4 _S1604 = float4((*_S1582).momentum_0) ;
            float4 _S1605 = float4((*_S1582).momentum_err_0) ;
            thread Island_0 isl_31;
            (&isl_31)->range_0 = uint4((*_S1582).range_0) ;
            (&isl_31)->info_0 = _S1583;
            (&isl_31)->com_0 = _S1584;
            (&isl_31)->inertia0_0 = _S1585;
            (&isl_31)->inertia1_0 = _S1586;
            (&isl_31)->inertia2_0 = _S1587;
            (&isl_31)->inv0_0 = _S1588;
            (&isl_31)->inv1_0 = _S1589;
            (&isl_31)->inv2_0 = _S1590;
            (&isl_31)->wcom_0 = _S1591;
            (&isl_31)->winv0_0 = _S1592;
            (&isl_31)->winv1_0 = _S1593;
            (&isl_31)->winv2_0 = _S1594;
            (&isl_31)->rotation_0 = _S1595;
            (&isl_31)->position_0 = _S1596;
            (&isl_31)->position_err_0 = _S1597;
            (&isl_31)->velocity_0 = _S1598;
            (&isl_31)->velocity_err_0 = _S1599;
            (&isl_31)->angular_velocity_0 = _S1600;
            (&isl_31)->done_0 = (*_S1582).done_0;
            (&isl_31)->coverage_0 = (*_S1582).coverage_0;
            (&isl_31)->wide_groups_0 = (*_S1582).wide_groups_0;
            (&isl_31)->done_pad_0 = (*_S1582).done_pad_0;
            (&isl_31)->probes_0 = _S1601;
            (&isl_31)->energy_0 = _S1602;
            (&isl_31)->rotation_err_0 = _S1603;
            (&isl_31)->momentum_0 = _S1604;
            (&isl_31)->momentum_err_0 = _S1605;
            Rigid_0 _S1606 = pc_load_rigid_0(i_33, &kernelContext_111);
            thread Rigid_0 rg_21 = _S1606;
            if((mode_7 & 2U) != 0U)
            {
                thread float work_7 = 0.0f;
                thread float work_err_5 = 0.0f;
                c_49 = (&isl_31)->range_0.x;
                for(;;)
                {
                    if(c_49 < ((&isl_31)->range_0.y))
                    {
                    }
                    else
                    {
                        break;
                    }
                    float4 _S1607 = float4(*((&kernelContext_111)->scratch_0+((&kernelContext_111)->params_0->pc_base_0 + 2U * c_49))) ;
                    comp_add1_0(&work_7, &work_err_5, _S1607.x);
                    work_err_5 = work_err_5 + _S1607.y;
                    c_49 = c_49 + 1U;
                }
                thread float _S1608 = (&isl_31)->energy_0.x;
                thread float _S1609 = (&isl_31)->energy_0.y;
                comp_add1_0(&_S1608, &_S1609, work_7);
                (&isl_31)->energy_0.x = _S1608;
                (&isl_31)->energy_0.y = _S1609 + work_err_5;
                ((&kernelContext_111)->islands_0+i_33)->energy_0 = packed_float4((&isl_31)->energy_0) ;
            }
            if((mode_7 & 8U) != 0U)
            {
                thread Island_0 _S1610 = isl_31;
                integrate_rigid_1(&_S1610, &rg_21, _S1543);
            }
            thread Rigid_0 _S1611 = rg_21;
            pc_store_rigid_0(i_33, &_S1611, &kernelContext_111);
            i_33 = i_33 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        c_49 = _S1541;
        for(;;)
        {
            if(c_49 < ((&kernelContext_111)->params_0->chunk_count_0))
            {
            }
            else
            {
                break;
            }
            if((((*(&kernelContext_111)->g_mode_0)[(uint4(((&kernelContext_111)->chunks_0+c_49)->info_1) ).y]) & 16U) == 0U)
            {
                c_49 = c_49 + 256U;
                continue;
            }
            float3 _S1612 = float3(0.0f) ;
            thread float3 tu_5 = _S1612;
            thread float3 pv_5 = _S1612;
            drift_moments_0(c_49, &tu_5, &pv_5, &kernelContext_111);
            uint _S1613 = 2U * c_49;
            *((&kernelContext_111)->scratch_0+((&kernelContext_111)->params_0->pc_base_0 + _S1613)) = packed_float4(float4(tu_5, 0.0f)) ;
            *((&kernelContext_111)->scratch_0+((&kernelContext_111)->params_0->pc_base_0 + _S1613 + 1U)) = packed_float4(float4(pv_5, 0.0f)) ;
            c_49 = c_49 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint i_34 = _S1541;
        for(;;)
        {
            if(i_34 < _S1542)
            {
            }
            else
            {
                break;
            }
            if((((*(&kernelContext_111)->g_mode_0)[i_34]) & 16U) == 0U)
            {
                i_34 = i_34 + 256U;
                continue;
            }
            Island_natural_0 device* _S1614 = (&kernelContext_111)->islands_0+i_34;
            float3 _S1615 = float3(0.0f) ;
            thread float3 tu_6 = _S1615;
            thread float3 pv_6 = _S1615;
            pc_sum_0(i_34, &tu_6, &pv_6, &kernelContext_111);
            uint _S1616 = 16U * i_34;
            float3 _S1617 = float3((float4((*_S1614).wcom_0) ).w) ;
            *((&kernelContext_111)->scratch_0+((&kernelContext_111)->params_0->pi_base_0 + _S1616 + 12U)) = packed_float4(float4(tu_6 / _S1617, 0.0f)) ;
            *((&kernelContext_111)->scratch_0+((&kernelContext_111)->params_0->pi_base_0 + _S1616 + 13U)) = packed_float4(float4(pv_6 / _S1617, 0.0f)) ;
            i_34 = i_34 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_53 = _S1541;
        for(;;)
        {
            if(c_53 < ((&kernelContext_111)->params_0->chunk_count_0))
            {
            }
            else
            {
                break;
            }
            uint i_35 = (uint4(((&kernelContext_111)->chunks_0+c_53)->info_1) ).y;
            if((((*(&kernelContext_111)->g_mode_0)[i_35]) & 16U) == 0U)
            {
                c_53 = c_53 + 256U;
                continue;
            }
            float3 _S1618 = float3(0.0f) ;
            thread float3 lu_4 = _S1618;
            thread float3 lv_4 = _S1618;
            uint _S1619 = 16U * i_35;
            drift_angular_0(c_53, (float4(((&kernelContext_111)->islands_0+i_35)->wcom_0) ).xyz, (float4(*((&kernelContext_111)->scratch_0+((&kernelContext_111)->params_0->pi_base_0 + _S1619 + 12U))) ).xyz, (float4(*((&kernelContext_111)->scratch_0+((&kernelContext_111)->params_0->pi_base_0 + _S1619 + 13U))) ).xyz, &lu_4, &lv_4, &kernelContext_111);
            uint _S1620 = 2U * c_53;
            *((&kernelContext_111)->scratch_0+((&kernelContext_111)->params_0->pc_base_0 + _S1620)) = packed_float4(float4(lu_4, 0.0f)) ;
            *((&kernelContext_111)->scratch_0+((&kernelContext_111)->params_0->pc_base_0 + _S1620 + 1U)) = packed_float4(float4(lv_4, 0.0f)) ;
            c_53 = c_53 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint i_36 = _S1541;
        for(;;)
        {
            if(i_36 < _S1542)
            {
            }
            else
            {
                break;
            }
            if((((*(&kernelContext_111)->g_mode_0)[i_36]) & 16U) == 0U)
            {
                i_36 = i_36 + 256U;
                continue;
            }
            Island_natural_0 device* _S1621 = (&kernelContext_111)->islands_0+i_36;
            float3 _S1622 = float3(0.0f) ;
            thread float3 lu_5 = _S1622;
            thread float3 lv_5 = _S1622;
            pc_sum_0(i_36, &lu_5, &lv_5, &kernelContext_111);
            uint _S1623 = 16U * i_36;
            float4 _S1624 = float4((*_S1621).winv0_0) ;
            float4 _S1625 = float4((*_S1621).winv1_0) ;
            float4 _S1626 = float4((*_S1621).winv2_0) ;
            *((&kernelContext_111)->scratch_0+((&kernelContext_111)->params_0->pi_base_0 + _S1623 + 14U)) = packed_float4(float4(rows_mul_0(_S1624, _S1625, _S1626, lu_5), 0.0f)) ;
            *((&kernelContext_111)->scratch_0+((&kernelContext_111)->params_0->pi_base_0 + _S1623 + 15U)) = packed_float4(float4(rows_mul_0(_S1624, _S1625, _S1626, lv_5), 0.0f)) ;
            i_36 = i_36 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_54 = _S1541;
        for(;;)
        {
            if(c_54 < ((&kernelContext_111)->params_0->chunk_count_0))
            {
            }
            else
            {
                break;
            }
            uint i_37 = (uint4(((&kernelContext_111)->chunks_0+c_54)->info_1) ).y;
            if((((*(&kernelContext_111)->g_mode_0)[i_37]) & 16U) == 0U)
            {
                c_54 = c_54 + 256U;
                continue;
            }
            uint at_9 = (&kernelContext_111)->params_0->pi_base_0 + 16U * i_37;
            drift_apply_0(c_54, (float4(((&kernelContext_111)->islands_0+i_37)->wcom_0) ).xyz, (float4(*((&kernelContext_111)->scratch_0+(at_9 + 12U))) ).xyz, (float4(*((&kernelContext_111)->scratch_0+(at_9 + 14U))) ).xyz, (float4(*((&kernelContext_111)->scratch_0+(at_9 + 13U))) ).xyz, (float4(*((&kernelContext_111)->scratch_0+(at_9 + 15U))) ).xyz, &kernelContext_111);
            c_54 = c_54 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        if(_S1547)
        {
            *(&kernelContext_111)->g_flag_0 = 0U;
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);
        uint i_38 = _S1541;
        for(;;)
        {
            if(i_38 < _S1542)
            {
            }
            else
            {
                break;
            }
            if((((*(&kernelContext_111)->g_mode_0)[i_38]) & 32U) != 0U)
            {
                *(&kernelContext_111)->g_flag_0 = 1U;
            }
            i_38 = i_38 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);
        uint c_55;
        uint pass_1;
        uint i_39;
        uint c_56;
        uint e_10;
        uint other_1;
        if((*(&kernelContext_111)->g_flag_0) != 0U)
        {
            c_55 = _S1541;
            for(;;)
            {
                if(c_55 < ((&kernelContext_111)->params_0->chunk_count_0))
                {
                }
                else
                {
                    break;
                }
                if((((*(&kernelContext_111)->g_mode_0)[(uint4(((&kernelContext_111)->chunks_0+c_55)->info_1) ).y]) & 32U) != 0U)
                {
                    *((&kernelContext_111)->scratch_0+((&kernelContext_111)->params_0->pc_base_0 + 2U * c_55)) = packed_float4(float4((as_type<float>((c_55))), 0.0f, 0.0f, 0.0f)) ;
                }
                c_55 = c_55 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            pass_1 = 0U;
            for(;;)
            {
                if(pass_1 <= ((&kernelContext_111)->params_0->chunk_count_0))
                {
                }
                else
                {
                    break;
                }
                if(_S1547)
                {
                    *(&kernelContext_111)->g_flag_0 = 0U;
                }
                threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
                i_39 = _S1541;
                for(;;)
                {
                    if(i_39 < ((&kernelContext_111)->params_0->chunk_count_0))
                    {
                    }
                    else
                    {
                        break;
                    }
                    if((((*(&kernelContext_111)->g_mode_0)[(uint4(((&kernelContext_111)->chunks_0+i_39)->info_1) ).y]) & 32U) == 0U)
                    {
                        i_39 = i_39 + 256U;
                        continue;
                    }
                    uint _S1627 = 2U * i_39;
                    uint _S1628 = (&kernelContext_111)->index_0[i_39];
                    c_56 = (as_type<uint>(((float4(*((&kernelContext_111)->scratch_0+((&kernelContext_111)->params_0->pc_base_0 + _S1627))) ).x)));
                    e_10 = _S1628;
                    for(;;)
                    {
                        if(e_10 < ((&kernelContext_111)->index_0)[i_39 + 1U])
                        {
                        }
                        else
                        {
                            break;
                        }
                        uint entry_9 = (&kernelContext_111)->index_0[e_10];
                        uint bond_2 = entry_9 >> 1U;
                        bool _S1629 = ((float4(((&kernelContext_111)->bonds_0+bond_2)->law_0.stiff1_0) ).w) != 0.0f;
                        thread JointState_0 _S1630 = ((&kernelContext_111)->bond_dyn_0+bond_2)->js_0;
                        bool _S1631 = connected_0(&_S1630, _S1629);
                        if(!_S1631)
                        {
                            e_10 = e_10 + 1U;
                            continue;
                        }
                        if((entry_9 & 1U) == 0U)
                        {
                            other_1 = (uint4(((&kernelContext_111)->bonds_0+bond_2)->law_0.ids_0) ).z;
                        }
                        else
                        {
                            other_1 = (uint4(((&kernelContext_111)->bonds_0+bond_2)->law_0.ids_0) ).y;
                        }
                        c_56 = min(c_56, (as_type<uint>(((float4(*((&kernelContext_111)->scratch_0+((&kernelContext_111)->params_0->pc_base_0 + 2U * other_1))) ).x))));
                        e_10 = e_10 + 1U;
                    }
                    uint _S1632 = min(c_56, (as_type<uint>(((float4(*((&kernelContext_111)->scratch_0+((&kernelContext_111)->params_0->pc_base_0 + 2U * c_56))) ).x))));
                    if(_S1632 < (as_type<uint>(((float4(*((&kernelContext_111)->scratch_0+((&kernelContext_111)->params_0->pc_base_0 + _S1627))) ).x))))
                    {
                        *((&kernelContext_111)->scratch_0+((&kernelContext_111)->params_0->pc_base_0 + _S1627)) = packed_float4(float4((as_type<float>((_S1632))), 0.0f, 0.0f, 0.0f)) ;
                        *(&kernelContext_111)->g_flag_0 = 1U;
                    }
                    i_39 = i_39 + 256U;
                }
                threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
                bool changed_0 = (*(&kernelContext_111)->g_flag_0) != 0U;
                threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
                if(!changed_0)
                {
                    break;
                }
                pass_1 = pass_1 + 1U;
            }
            i_39 = _S1541;
            for(;;)
            {
                if(i_39 < _S1542)
                {
                }
                else
                {
                    break;
                }
                if((((*(&kernelContext_111)->g_mode_0)[i_39]) & 32U) == 0U)
                {
                    i_39 = i_39 + 256U;
                    continue;
                }
                uint4 _S1633 = uint4(((&kernelContext_111)->islands_0+i_39)->range_0) ;
                uint _S1634 = _S1633.x;
                contact_6 = true;
                c_56 = _S1634;
                for(;;)
                {
                    if(c_56 < (_S1633.y))
                    {
                    }
                    else
                    {
                        break;
                    }
                    if(contact_6)
                    {
                        contact_6 = (as_type<uint>(((float4(*((&kernelContext_111)->scratch_0+((&kernelContext_111)->params_0->pc_base_0 + 2U * c_56))) ).x))) == _S1634;
                    }
                    else
                    {
                        contact_6 = false;
                    }
                    c_56 = c_56 + 1U;
                }
                if(!contact_6)
                {
                    (*(&kernelContext_111)->g_mode_0)[i_39] = ((*(&kernelContext_111)->g_mode_0)[i_39]) | 256U;
                }
                i_39 = i_39 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        }
        if(_S1547)
        {
            *(&kernelContext_111)->g_flag_0 = 0U;
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);
        uint _S1635 = seen_bits_0(&kernelContext_111);
        i_39 = _S1541;
        for(;;)
        {
            if(i_39 < _S1542)
            {
            }
            else
            {
                break;
            }
            uint mode_8 = (*(&kernelContext_111)->g_mode_0)[i_39];
            if((((*(&kernelContext_111)->g_mode_0)[i_39]) & 1U) == 0U)
            {
                i_39 = i_39 + 256U;
                continue;
            }
            Island_natural_0 device* _S1636 = (&kernelContext_111)->islands_0+i_39;
            uint4 _S1637 = uint4((*_S1636).info_0) ;
            float4 _S1638 = float4((*_S1636).com_0) ;
            float4 _S1639 = float4((*_S1636).inertia0_0) ;
            float4 _S1640 = float4((*_S1636).inertia1_0) ;
            float4 _S1641 = float4((*_S1636).inertia2_0) ;
            float4 _S1642 = float4((*_S1636).inv0_0) ;
            float4 _S1643 = float4((*_S1636).inv1_0) ;
            float4 _S1644 = float4((*_S1636).inv2_0) ;
            float4 _S1645 = float4((*_S1636).wcom_0) ;
            float4 _S1646 = float4((*_S1636).winv0_0) ;
            float4 _S1647 = float4((*_S1636).winv1_0) ;
            float4 _S1648 = float4((*_S1636).winv2_0) ;
            float4 _S1649 = float4((*_S1636).rotation_0) ;
            float4 _S1650 = float4((*_S1636).position_0) ;
            float4 _S1651 = float4((*_S1636).position_err_0) ;
            float4 _S1652 = float4((*_S1636).velocity_0) ;
            float4 _S1653 = float4((*_S1636).velocity_err_0) ;
            float4 _S1654 = float4((*_S1636).angular_velocity_0) ;
            uint4 _S1655 = uint4((*_S1636).probes_0) ;
            float4 _S1656 = float4((*_S1636).energy_0) ;
            float4 _S1657 = float4((*_S1636).rotation_err_0) ;
            float4 _S1658 = float4((*_S1636).momentum_0) ;
            float4 _S1659 = float4((*_S1636).momentum_err_0) ;
            thread Island_0 isl_32;
            (&isl_32)->range_0 = uint4((*_S1636).range_0) ;
            (&isl_32)->info_0 = _S1637;
            (&isl_32)->com_0 = _S1638;
            (&isl_32)->inertia0_0 = _S1639;
            (&isl_32)->inertia1_0 = _S1640;
            (&isl_32)->inertia2_0 = _S1641;
            (&isl_32)->inv0_0 = _S1642;
            (&isl_32)->inv1_0 = _S1643;
            (&isl_32)->inv2_0 = _S1644;
            (&isl_32)->wcom_0 = _S1645;
            (&isl_32)->winv0_0 = _S1646;
            (&isl_32)->winv1_0 = _S1647;
            (&isl_32)->winv2_0 = _S1648;
            (&isl_32)->rotation_0 = _S1649;
            (&isl_32)->position_0 = _S1650;
            (&isl_32)->position_err_0 = _S1651;
            (&isl_32)->velocity_0 = _S1652;
            (&isl_32)->velocity_err_0 = _S1653;
            (&isl_32)->angular_velocity_0 = _S1654;
            (&isl_32)->done_0 = (*_S1636).done_0;
            (&isl_32)->coverage_0 = (*_S1636).coverage_0;
            (&isl_32)->wide_groups_0 = (*_S1636).wide_groups_0;
            (&isl_32)->done_pad_0 = (*_S1636).done_pad_0;
            (&isl_32)->probes_0 = _S1655;
            (&isl_32)->energy_0 = _S1656;
            (&isl_32)->rotation_err_0 = _S1657;
            (&isl_32)->momentum_0 = _S1658;
            (&isl_32)->momentum_err_0 = _S1659;
            Rigid_0 _S1660 = pc_load_rigid_0(i_39, &kernelContext_111);
            thread Rigid_0 rg_22 = _S1660;
            if((mode_8 & 16U) != 0U)
            {
                contact_6 = (((&isl_32)->info_0.x) & 2U) == 0U;
            }
            else
            {
                contact_6 = false;
            }
            if(contact_6)
            {
                uint at_10 = (&kernelContext_111)->params_0->pi_base_0 + 16U * i_39;
                float3 _S1661 = (float4(*((&kernelContext_111)->scratch_0+(at_10 + 12U))) ).xyz;
                float3 _S1662 = (float4(*((&kernelContext_111)->scratch_0+(at_10 + 14U))) ).xyz;
                float3 _S1663 = (float4(*((&kernelContext_111)->scratch_0+(at_10 + 13U))) ).xyz;
                float3 _S1664 = (float4(*((&kernelContext_111)->scratch_0+(at_10 + 15U))) ).xyz;
                thread Island_0 _S1665 = isl_32;
                drift_rigid_1(&_S1665, &rg_22, _S1661, _S1662, _S1663, _S1664);
            }
            thread Quat_0 _S1666 = (&rg_22)->rot_1;
            float4 _S1667 = quat_vec_0(&_S1666);
            (&isl_32)->rotation_0 = _S1667;
            (&isl_32)->rotation_err_0 = (&rg_22)->rot_err_0;
            (&isl_32)->position_0 = float4((&rg_22)->pos_0, 0.0f);
            (&isl_32)->position_err_0 = float4((&rg_22)->pos_err_0, 0.0f);
            (&isl_32)->velocity_0 = float4((&rg_22)->vel_0, 0.0f);
            (&isl_32)->velocity_err_0 = float4((&rg_22)->vel_err_0, 0.0f);
            (&isl_32)->angular_velocity_0 = float4((&rg_22)->w_5, 0.0f);
            (&isl_32)->momentum_0 = float4((&rg_22)->l_1, 0.0f);
            (&isl_32)->momentum_err_0 = float4((&rg_22)->l_err_0, 0.0f);
            if(((&isl_32)->probes_0.y) > ((&isl_32)->probes_0.x))
            {
                thread Island_0 _S1668 = isl_32;
                uint _S1669 = pc_k_0(&_S1668, &kernelContext_111);
                thread Island_0 _S1670 = isl_32;
                thread Rigid_0 _S1671 = rg_22;
                record_probes_0(&_S1670, &_S1671, _S1669, &kernelContext_111);
            }
            (&isl_32)->done_0 = (&isl_32)->done_0 + 1U;
            (&isl_32)->info_0.y = (&isl_32)->info_0.y - 1U;
            (&isl_32)->info_0.w = (&isl_32)->info_0.w + 1U;
            bool quiet_3 = (((&isl_32)->info_0.x) & 32U) != 0U;
            uint _S1672 = _S1635 | 524288U;
            if((((&isl_32)->info_0.x) & 8U) != 0U)
            {
                c_55 = 256U;
            }
            else
            {
                c_55 = 0U;
            }
            uint _S1673 = _S1672 | c_55;
            if(((&isl_32)->probes_0.y) > ((&isl_32)->probes_0.x))
            {
                pass_1 = 262144U;
            }
            else
            {
                pass_1 = 0U;
            }
            uint _S1674 = _S1673 | pass_1;
            if(quiet_3)
            {
                c_56 = 4096U;
            }
            else
            {
                c_56 = 0U;
            }
            uint _S1675 = _S1674 | c_56;
            if((mode_8 & 128U) != 0U)
            {
                _S1540 = (mode_8 & 64U) == 0U;
            }
            else
            {
                _S1540 = false;
            }
            if(_S1540)
            {
                e_10 = 512U;
            }
            else
            {
                e_10 = 0U;
            }
            uint _S1676 = _S1675 | e_10;
            if((mode_8 & 32U) != 0U)
            {
                other_1 = 128U;
            }
            else
            {
                other_1 = 0U;
            }
            uint _S1677 = _S1676 | other_1;
            bool _S1678 = (mode_8 & 64U) != 0U;
            uint _S1679;
            if(_S1678)
            {
                _S1679 = 2048U;
            }
            else
            {
                _S1679 = 0U;
            }
            (&isl_32)->coverage_0 = ((&isl_32)->coverage_0) | (_S1677 | _S1679);
            if(_S1678)
            {
                (&isl_32)->info_0.x = ((&isl_32)->info_0.x) & 4294967279U;
                (&isl_32)->info_0.z = ((&isl_32)->info_0.z) | 4U;
            }
            if((mode_8 & 256U) != 0U)
            {
                contact_split_at_0((&isl_32)->info_0.w, &kernelContext_111);
                (&isl_32)->info_0.z = ((&isl_32)->info_0.z) | 1U;
                *(&kernelContext_111)->g_flag_0 = 1U;
            }
            Island_natural_0 device* _S1680 = (&kernelContext_111)->islands_0+i_39;
            _S1680->range_0 = packed_uint4(isl_32.range_0) ;
            _S1680->info_0 = packed_uint4(isl_32.info_0) ;
            _S1680->com_0 = packed_float4(isl_32.com_0) ;
            _S1680->inertia0_0 = packed_float4(isl_32.inertia0_0) ;
            _S1680->inertia1_0 = packed_float4(isl_32.inertia1_0) ;
            _S1680->inertia2_0 = packed_float4(isl_32.inertia2_0) ;
            _S1680->inv0_0 = packed_float4(isl_32.inv0_0) ;
            _S1680->inv1_0 = packed_float4(isl_32.inv1_0) ;
            _S1680->inv2_0 = packed_float4(isl_32.inv2_0) ;
            _S1680->wcom_0 = packed_float4(isl_32.wcom_0) ;
            _S1680->winv0_0 = packed_float4(isl_32.winv0_0) ;
            _S1680->winv1_0 = packed_float4(isl_32.winv1_0) ;
            _S1680->winv2_0 = packed_float4(isl_32.winv2_0) ;
            _S1680->rotation_0 = packed_float4(isl_32.rotation_0) ;
            _S1680->position_0 = packed_float4(isl_32.position_0) ;
            _S1680->position_err_0 = packed_float4(isl_32.position_err_0) ;
            _S1680->velocity_0 = packed_float4(isl_32.velocity_0) ;
            _S1680->velocity_err_0 = packed_float4(isl_32.velocity_err_0) ;
            _S1680->angular_velocity_0 = packed_float4(isl_32.angular_velocity_0) ;
            _S1680->done_0 = isl_32.done_0;
            _S1680->coverage_0 = isl_32.coverage_0;
            _S1680->wide_groups_0 = isl_32.wide_groups_0;
            _S1680->done_pad_0 = isl_32.done_pad_0;
            _S1680->probes_0 = packed_uint4(isl_32.probes_0) ;
            _S1680->energy_0 = packed_float4(isl_32.energy_0) ;
            _S1680->rotation_err_0 = packed_float4(isl_32.rotation_err_0) ;
            _S1680->momentum_0 = packed_float4(isl_32.momentum_0) ;
            _S1680->momentum_err_0 = packed_float4(isl_32.momentum_err_0) ;
            i_39 = i_39 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        if((*(&kernelContext_111)->g_flag_0) != 0U)
        {
            break;
        }
        s_13 = s_13 + 1U;
    }
    return;
}

