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
    uint threadgroup* g_run_0;
    uint threadgroup* g_halt_0;
    uint threadgroup* g_wide_run_0;
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
    threadgroup uint g_run_1;
    (&kernelContext_28)->g_run_0 = &g_run_1;
    threadgroup uint g_halt_1;
    (&kernelContext_28)->g_halt_0 = &g_halt_1;
    threadgroup uint g_wide_run_1;
    (&kernelContext_28)->g_wide_run_0 = &g_wide_run_1;
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
    threadgroup uint g_run_2;
    (&kernelContext_29)->g_run_0 = &g_run_2;
    threadgroup uint g_halt_2;
    (&kernelContext_29)->g_halt_0 = &g_halt_2;
    threadgroup uint g_wide_run_2;
    (&kernelContext_29)->g_wide_run_0 = &g_wide_run_2;
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
    threadgroup uint g_run_3;
    (&kernelContext_30)->g_run_0 = &g_run_3;
    threadgroup uint g_halt_3;
    (&kernelContext_30)->g_halt_0 = &g_halt_3;
    threadgroup uint g_wide_run_3;
    (&kernelContext_30)->g_wide_run_0 = &g_wide_run_3;
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

void comp_add_0(float3 thread* sum_1, float3 thread* err_1, float3 x_8)
{
    float3 t_3 = *sum_1 + x_8;
    float3 _S382 = abs(x_8);
    *err_1 = *err_1 + (select(x_8, *sum_1, (abs(*sum_1)) >= _S382) - t_3 + select(*sum_1, x_8, (abs(*sum_1)) >= _S382));
    *sum_1 = t_3;
    return;
}

float3 inverse_rotate_0(const Quat_0 thread* q_10, float3 v_5)
{
    thread Quat_0 c_7;
    (&c_7)->w_1 = q_10->w_1;
    (&c_7)->x_2 = - q_10->x_2;
    (&c_7)->y_1 = - q_10->y_1;
    (&c_7)->z_0 = - q_10->z_0;
    thread Quat_0 _S383 = c_7;
    float3 _S384 = rotate_0(&_S383, v_5);
    return _S384;
}

float3 inverse_rotate_1(const Quat_0 thread* q_11, float3 v_6)
{
    thread Quat_0 c_8;
    (&c_8)->w_1 = q_11->w_1;
    (&c_8)->x_2 = - q_11->x_2;
    (&c_8)->y_1 = - q_11->y_1;
    (&c_8)->z_0 = - q_11->z_0;
    thread Quat_0 _S385 = c_8;
    float3 _S386 = rotate_0(&_S385, v_6);
    return _S386;
}

float3 rows_mul_0(float4 r0_0, float4 r1_0, float4 r2_0, float3 v_7)
{
    return float3(dot(r0_0.xyz, v_7), dot(r1_0.xyz, v_7), dot(r2_0.xyz, v_7));
}

float3 world_mul_0(const Quat_0 thread* q_12, float4 r0_1, float4 r1_1, float4 r2_1, float3 v_8)
{
    float3 _S387 = inverse_rotate_1(q_12, v_8);
    float3 _S388 = rotate_1(q_12, rows_mul_0(r0_1, r1_1, r2_1, _S387));
    return _S388;
}

float4 turn_minus_one_0(float3 axis_5, float angle_1)
{
    float s_1 = sin(0.25f * angle_1);
    return float4(axis_5 * float3(sin(0.5f * angle_1)) , -2.0f * s_1 * s_1);
}

float4 quat_vec_0(const Quat_0 thread* q_13)
{
    return float4(q_13->x_2, q_13->y_1, q_13->z_0, q_13->w_1);
}

void comp_add4_0(float4 thread* sum_2, float4 thread* err_2, float4 x_9)
{
    float4 t_4 = *sum_2 + x_9;
    float4 _S389 = abs(x_9);
    *err_2 = *err_2 + (select(x_9, *sum_2, (abs(*sum_2)) >= _S389) - t_4 + select(*sum_2, x_9, (abs(*sum_2)) >= _S389));
    *sum_2 = t_4;
    return;
}

void quat_accumulate_0(Quat_0 thread* hi_1, float4 thread* lo_1, float4 x_10)
{
    thread Quat_0 _S390 = *hi_1;
    float4 _S391 = quat_vec_0(&_S390);
    thread float4 sum_3 = _S391;
    comp_add4_0(&sum_3, lo_1, x_10);
    float4 t_5 = sum_3 + *lo_1;
    *lo_1 = *lo_1 - (t_5 - sum_3);
    *hi_1 = quat_of_0(t_5);
    return;
}

void turn_left_0(Quat_0 thread* hi_2, float4 thread* lo_2, float3 omega_0, float dt_2)
{
    float _S392 = length(omega_0);
    float angle_2 = _S392 * dt_2;
    if(angle_2 < 1.00000000317107685e-30f)
    {
        return;
    }
    float4 d_12 = turn_minus_one_0(omega_0 / float3(_S392) , angle_2);
    thread Quat_0 dq_0;
    (&dq_0)->x_2 = d_12.x;
    (&dq_0)->y_1 = d_12.y;
    (&dq_0)->z_0 = d_12.z;
    (&dq_0)->w_1 = d_12.w;
    thread Quat_0 _S393 = dq_0;
    thread Quat_0 _S394 = *hi_2;
    Quat_0 _S395 = quat_mul_0(&_S393, &_S394);
    thread Quat_0 _S396 = _S395;
    float4 _S397 = quat_vec_0(&_S396);
    quat_accumulate_0(hi_2, lo_2, _S397);
    return;
}

[[kernel]] void impactor_integrate(uint3 group_1 [[threadgroup_position_in_grid]], uint3 thread_1 [[thread_position_in_threadgroup]], Params_0 constant* params_4 [[buffer(0)]], Island_natural_0 device* islands_4 [[buffer(9)]], uint device* index_4 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_4 [[buffer(3)]], packed_float4 device* state_4 [[buffer(6)]], packed_float4 device* scratch_4 [[buffer(8)]], packed_float4 device* contact_state_4 [[buffer(11)]], packed_float4 device* loads_4 [[buffer(5)]], Impactor_natural_0 device* impactors_4 [[buffer(10)]], BondStatic_natural_0 device* bonds_4 [[buffer(2)]], MaterialTable_0 constant* materials_4 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_4 [[buffer(7)]])
{
    float3 p_10;
    thread KernelContext_0 kernelContext_31;
    (&kernelContext_31)->params_0 = params_4;
    (&kernelContext_31)->islands_0 = islands_4;
    (&kernelContext_31)->index_0 = index_4;
    (&kernelContext_31)->chunks_0 = chunks_4;
    (&kernelContext_31)->state_0 = state_4;
    (&kernelContext_31)->scratch_0 = scratch_4;
    (&kernelContext_31)->contact_state_0 = contact_state_4;
    (&kernelContext_31)->loads_0 = loads_4;
    (&kernelContext_31)->impactors_0 = impactors_4;
    (&kernelContext_31)->bonds_0 = bonds_4;
    (&kernelContext_31)->materials_0 = materials_4;
    (&kernelContext_31)->bond_dyn_0 = bond_dyn_4;
    threadgroup array<float4, int(32)> g_part_a_4;
    (&kernelContext_31)->g_part_a_0 = &g_part_a_4;
    threadgroup array<float4, int(32)> g_part_b_4;
    (&kernelContext_31)->g_part_b_0 = &g_part_b_4;
    threadgroup array<uint, int(5)> g_seen_4;
    (&kernelContext_31)->g_seen_0 = &g_seen_4;
    threadgroup uint g_run_4;
    (&kernelContext_31)->g_run_0 = &g_run_4;
    threadgroup uint g_halt_4;
    (&kernelContext_31)->g_halt_0 = &g_halt_4;
    threadgroup uint g_wide_run_4;
    (&kernelContext_31)->g_wide_run_0 = &g_wide_run_4;
    uint ii_1 = group_1.x;
    uint tid_3 = thread_1.x;
    if(ii_1 >= (params_4->impactor_count_0))
    {
        return;
    }
    Island_natural_0 device* _S398 = (&kernelContext_31)->islands_0+(&kernelContext_31)->params_0->halt_index_0;
    Impactor_natural_0 device* _S399 = (&kernelContext_31)->impactors_0+ii_1;
    float4 _S400 = float4((*_S399).position_err_1) ;
    float4 _S401 = float4((*_S399).velocity_1) ;
    float4 _S402 = float4((*_S399).velocity_err_1) ;
    float4 _S403 = float4((*_S399).angular_velocity_1) ;
    float4 _S404 = float4((*_S399).rotation_1) ;
    float4 _S405 = float4((*_S399).inertia0_2) ;
    float4 _S406 = float4((*_S399).inertia1_2) ;
    float4 _S407 = float4((*_S399).inertia2_2) ;
    float4 _S408 = float4((*_S399).inv0_2) ;
    float4 _S409 = float4((*_S399).inv1_2) ;
    float4 _S410 = float4((*_S399).inv2_2) ;
    float4 _S411 = float4((*_S399).shape_0) ;
    float4 _S412 = float4((*_S399).half_1) ;
    float4 _S413 = float4((*_S399).mat_0) ;
    float4 _S414 = float4((*_S399).crush_0) ;
    float4 _S415 = float4((*_S399).geom_0) ;
    float4 _S416 = float4((*_S399).rotation_err_1) ;
    float4 _S417 = float4((*_S399).ledger_0) ;
    uint4 _S418 = uint4((*_S399).cand_0) ;
    float4 _S419 = float4((*_S399).momentum_1) ;
    float4 _S420 = float4((*_S399).momentum_err_1) ;
    thread Impactor_0 imp_6;
    (&imp_6)->position_1 = float4((*_S399).position_1) ;
    (&imp_6)->position_err_1 = _S400;
    (&imp_6)->velocity_1 = _S401;
    (&imp_6)->velocity_err_1 = _S402;
    (&imp_6)->angular_velocity_1 = _S403;
    (&imp_6)->rotation_1 = _S404;
    (&imp_6)->inertia0_2 = _S405;
    (&imp_6)->inertia1_2 = _S406;
    (&imp_6)->inertia2_2 = _S407;
    (&imp_6)->inv0_2 = _S408;
    (&imp_6)->inv1_2 = _S409;
    (&imp_6)->inv2_2 = _S410;
    (&imp_6)->shape_0 = _S411;
    (&imp_6)->half_1 = _S412;
    (&imp_6)->mat_0 = _S413;
    (&imp_6)->crush_0 = _S414;
    (&imp_6)->geom_0 = _S415;
    (&imp_6)->rotation_err_1 = _S416;
    (&imp_6)->ledger_0 = _S417;
    (&imp_6)->cand_0 = _S418;
    (&imp_6)->momentum_1 = _S419;
    (&imp_6)->momentum_err_1 = _S420;
    uint4 _S421 = uint4(_S398->info_0) ;
    bool _S422;
    if(((_S421.z) & 1U) != 0U)
    {
        _S422 = true;
    }
    else
    {
        uint _S423 = _S421.y;
        if(_S423 != 0U)
        {
            _S422 = ((&imp_6)->cand_0.w) >= _S423;
        }
        else
        {
            _S422 = false;
        }
    }
    if(_S422)
    {
        return;
    }
    if(((&imp_6)->cand_0.z) != 0U)
    {
        if(tid_3 == 0U)
        {
            ((&kernelContext_31)->impactors_0+ii_1)->cand_0[int(3)] = (&imp_6)->cand_0.w + 1U;
        }
        return;
    }
    float4 _S424 = float4(0.0f) ;
    thread float4 rf_0 = _S424;
    thread float4 rt_0 = _S424;
    uint k_9 = (&imp_6)->cand_0.x + tid_3;
    for(;;)
    {
        if(k_9 < ((&imp_6)->cand_0.y))
        {
        }
        else
        {
            break;
        }
        uint _S425 = 3U * k_9;
        rf_0 = rf_0 + float4(*((&kernelContext_31)->scratch_0+((&kernelContext_31)->params_0->cand_base_0 + _S425 + 1U))) ;
        rt_0 = rt_0 + float4(*((&kernelContext_31)->scratch_0+((&kernelContext_31)->params_0->cand_base_0 + _S425 + 2U))) ;
        k_9 = k_9 + 256U;
    }
    group_sum2_0(tid_3, &rf_0, &rt_0, &kernelContext_31);
    if(tid_3 != 0U)
    {
        return;
    }
    float dt_3 = (&kernelContext_31)->params_0->dt_0;
    float3 _S426 = float3(0.0f) ;
    float3 load_f_0;
    float3 load_t_0;
    if(((&kernelContext_31)->params_0->has_ground_0) != 0U)
    {
        float3 _S427 = (&imp_6)->half_1.xyz;
        thread Impactor_0 _S428 = imp_6;
        Box_0 _S429 = impactor_box_0(&_S428, _S426, _S427);
        float3 _S430 = (&imp_6)->velocity_1.xyz + (&imp_6)->velocity_err_1.xyz;
        float _S431 = (&kernelContext_31)->params_0->ground_modulus_0;
        float _S432 = (&imp_6)->mat_0.x;
        float3 _S433 = float3(0.0f, 0.0f, 1.0f);
        thread Box_0 _S434 = _S429;
        thread Box_0 _S435 = _S429;
        float _S436 = contact_stiffness_0(_S431, &_S434, _S432, &_S435, _S433);
        float _S437 = (&imp_6)->position_1.z - (&kernelContext_31)->params_0->ground_hi_0 + ((&imp_6)->position_err_1.z - (&kernelContext_31)->params_0->ground_lo_0);
        uint total_points_0;
        if(((&imp_6)->shape_0.x) == 0.0f)
        {
            total_points_0 = 1U;
        }
        else
        {
            total_points_0 = 14U;
        }
        float _S438 = _S436 / float(min(total_points_0, 5U));
        uint s_2 = 0U;
        uint below_0 = 0U;
        for(;;)
        {
            if(s_2 < total_points_0)
            {
            }
            else
            {
                break;
            }
            if(((&imp_6)->shape_0.x) == 0.0f)
            {
                p_10 = float3(0.0f, 0.0f, - (&imp_6)->shape_0.y);
            }
            else
            {
                thread Box_0 _S439 = _S429;
                float3 _S440 = sample_point_0(&_S439, s_2, &kernelContext_31);
                p_10 = _S440;
            }
            if((_S437 + p_10.z) < 0.0f)
            {
                below_0 = below_0 + 1U;
            }
            s_2 = s_2 + 1U;
        }
        if(below_0 > 0U)
        {
            sentinel_mark_0(8U, &kernelContext_31);
        }
        s_2 = 0U;
        load_f_0 = _S426;
        load_t_0 = _S426;
        for(;;)
        {
            if(s_2 < total_points_0)
            {
            }
            else
            {
                break;
            }
            if(((&imp_6)->shape_0.x) == 0.0f)
            {
                p_10 = float3(0.0f, 0.0f, - (&imp_6)->shape_0.y);
            }
            else
            {
                thread Box_0 _S441 = _S429;
                float3 _S442 = sample_point_0(&_S441, s_2, &kernelContext_31);
                p_10 = _S442;
            }
            float depth_4 = - (_S437 + p_10.z);
            if(depth_4 <= 0.0f)
            {
                s_2 = s_2 + 1U;
                continue;
            }
            thread float stored_3;
            thread float diss_2;
            float3 _S443 = penalty_force_0(_S438, (&imp_6)->mat_0.z, (&kernelContext_31)->params_0->ground_friction_0, depth_4, _S433, _S430 + cross((&imp_6)->angular_velocity_1.xyz, p_10), dt_3, below_0, &stored_3, &diss_2, &kernelContext_31);
            float3 load_f_1 = load_f_0 + _S443;
            float3 load_t_1 = load_t_0 + cross(p_10, _S443);
            thread float _S444 = (&imp_6)->ledger_0.x;
            thread float _S445 = (&imp_6)->ledger_0.y;
            comp_add1_0(&_S444, &_S445, diss_2);
            (&imp_6)->ledger_0.y = _S445;
            (&imp_6)->ledger_0.x = _S444;
            load_f_0 = load_f_1;
            load_t_0 = load_t_1;
            s_2 = s_2 + 1U;
        }
    }
    else
    {
        load_f_0 = _S426;
        load_t_0 = _S426;
    }
    float3 load_f_2 = rf_0.xyz + load_f_0;
    float3 load_t_2 = rt_0.xyz + load_t_0;
    float m_2 = (&imp_6)->mat_0.z;
    thread float3 vel_0 = (&imp_6)->velocity_1.xyz;
    thread float3 vel_err_0 = (&imp_6)->velocity_err_1.xyz;
    float3 _S446 = float3(dt_3) ;
    comp_add_0(&vel_0, &vel_err_0, (load_f_2 / float3(m_2)  + (&kernelContext_31)->params_0->gravity_0.xyz) * _S446);
    Quat_0 _S447 = quat_of_0((&imp_6)->rotation_1);
    thread Quat_0 q_14 = _S447;
    thread float4 q_err_0 = (&imp_6)->rotation_err_1;
    thread float3 l_hi_0 = (&imp_6)->momentum_1.xyz;
    thread float3 l_err_0 = (&imp_6)->momentum_err_1.xyz;
    comp_add_0(&l_hi_0, &l_err_0, load_t_2 * _S446);
    float3 l_1 = l_hi_0 + l_err_0;
    thread Quat_0 _S448 = _S447;
    float3 _S449 = world_mul_0(&_S448, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    thread float3 pos_0 = (&imp_6)->position_1.xyz;
    thread float3 pos_err_0 = (&imp_6)->position_err_1.xyz;
    comp_add_0(&pos_0, &pos_err_0, (vel_0 + vel_err_0) * _S446);
    turn_left_0(&q_14, &q_err_0, _S449, dt_3);
    thread Quat_0 _S450 = q_14;
    float3 _S451 = world_mul_0(&_S450, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    (&imp_6)->angular_velocity_1 = float4(_S451, 0.0f);
    thread Quat_0 _S452 = q_14;
    float4 _S453 = quat_vec_0(&_S452);
    (&imp_6)->rotation_1 = _S453;
    (&imp_6)->rotation_err_1 = q_err_0;
    (&imp_6)->momentum_1 = float4(l_hi_0, 0.0f);
    (&imp_6)->momentum_err_1 = float4(l_err_0, 0.0f);
    (&imp_6)->position_1 = float4(pos_0, 0.0f);
    (&imp_6)->position_err_1 = float4(pos_err_0, 0.0f);
    (&imp_6)->velocity_1 = float4(vel_0, 0.0f);
    (&imp_6)->velocity_err_1 = float4(vel_err_0, 0.0f);
    (&imp_6)->cand_0.w = (&imp_6)->cand_0.w + 1U;
    (&imp_6)->geom_0 = float4(1.0f, (&imp_6)->crush_0.w, 0.0f, 0.0f);
    Impactor_natural_0 device* _S454 = (&kernelContext_31)->impactors_0+ii_1;
    _S454->position_1 = packed_float4(imp_6.position_1) ;
    _S454->position_err_1 = packed_float4(imp_6.position_err_1) ;
    _S454->velocity_1 = packed_float4(imp_6.velocity_1) ;
    _S454->velocity_err_1 = packed_float4(imp_6.velocity_err_1) ;
    _S454->angular_velocity_1 = packed_float4(imp_6.angular_velocity_1) ;
    _S454->rotation_1 = packed_float4(imp_6.rotation_1) ;
    _S454->inertia0_2 = packed_float4(imp_6.inertia0_2) ;
    _S454->inertia1_2 = packed_float4(imp_6.inertia1_2) ;
    _S454->inertia2_2 = packed_float4(imp_6.inertia2_2) ;
    _S454->inv0_2 = packed_float4(imp_6.inv0_2) ;
    _S454->inv1_2 = packed_float4(imp_6.inv1_2) ;
    _S454->inv2_2 = packed_float4(imp_6.inv2_2) ;
    _S454->shape_0 = packed_float4(imp_6.shape_0) ;
    _S454->half_1 = packed_float4(imp_6.half_1) ;
    _S454->mat_0 = packed_float4(imp_6.mat_0) ;
    _S454->crush_0 = packed_float4(imp_6.crush_0) ;
    _S454->geom_0 = packed_float4(imp_6.geom_0) ;
    _S454->rotation_err_1 = packed_float4(imp_6.rotation_err_1) ;
    _S454->ledger_0 = packed_float4(imp_6.ledger_0) ;
    _S454->cand_0 = packed_uint4(imp_6.cand_0) ;
    _S454->momentum_1 = packed_float4(imp_6.momentum_1) ;
    _S454->momentum_err_1 = packed_float4(imp_6.momentum_err_1) ;
    uint k_10 = (&imp_6)->cand_0.w - 1U - (&kernelContext_31)->params_0->step_start_0;
    if(k_10 < ((&kernelContext_31)->params_0->record_stride_0))
    {
        uint at_3 = (&kernelContext_31)->params_0->record_base_0 + 2U * (ii_1 * (&kernelContext_31)->params_0->record_stride_0 + k_10);
        *((&kernelContext_31)->scratch_0+at_3) = packed_float4(float4(vel_0 + vel_err_0, 0.0f)) ;
        *((&kernelContext_31)->scratch_0+(at_3 + 1U)) = packed_float4(float4(pos_0 + pos_err_0, 0.0f)) ;
    }
    return;
}

void ground_contact_0(uint c_9, bool account_0, float3 thread* f_1, float3 thread* t_6, KernelContext_0 thread* kernelContext_32)
{
    ChunkStatic_natural_0 device* _S455 = kernelContext_32->chunks_0+c_9;
    WorldPoint_0 _S456 = chunk_world_0(c_9, kernelContext_32);
    float above_0 = _S456.hi_0.z - kernelContext_32->params_0->ground_hi_0 + (_S456.lo_0.z - kernelContext_32->params_0->ground_lo_0) + _S456.rel_0.z;
    if((above_0 - (float4(_S455->half_0) ).w) > 0.0f)
    {
        return;
    }
    Box_0 _S457 = chunk_box_0(c_9, float3(0.0f) , kernelContext_32);
    float _S458 = kernelContext_32->params_0->ground_modulus_0;
    float _S459 = (float4(_S455->cmat_0) ).x;
    float3 _S460 = float3(0.0f, 0.0f, 1.0f);
    thread Box_0 _S461 = _S457;
    thread Box_0 _S462 = _S457;
    float _S463 = contact_stiffness_0(_S458, &_S461, _S459, &_S462, _S460);
    thread Box_0 _S464 = _S457;
    uint _S465 = sample_count_0(&_S464);
    uint s_3 = 0U;
    uint n_8 = 0U;
    for(;;)
    {
        if(s_3 < _S465)
        {
        }
        else
        {
            break;
        }
        thread Box_0 _S466 = _S457;
        float3 _S467 = sample_point_0(&_S466, s_3, kernelContext_32);
        if((above_0 + _S467.z) < 0.0f)
        {
            n_8 = n_8 + 1U;
        }
        s_3 = s_3 + 1U;
    }
    if(n_8 == 0U)
    {
        return;
    }
    sentinel_mark_0(4U, kernelContext_32);
    thread float3 vc_1;
    thread float3 wc_1;
    chunk_velocity_0(c_9, &vc_1, &wc_1, kernelContext_32);
    thread float4 ledger_2 = float4(*(kernelContext_32->scratch_0+(kernelContext_32->params_0->ledger_base_0 + kernelContext_32->params_0->pair_count_0 + c_9))) ;
    s_3 = 0U;
    for(;;)
    {
        if(s_3 < _S465)
        {
        }
        else
        {
            break;
        }
        thread Box_0 _S468 = _S457;
        float3 _S469 = sample_point_0(&_S468, s_3, kernelContext_32);
        float _S470 = above_0 + _S469.z;
        if(!(_S470 < 0.0f))
        {
            s_3 = s_3 + 1U;
            continue;
        }
        thread float stored_4;
        thread float diss_3;
        float3 _S471 = penalty_force_0(_S463 / float(max(n_8, 5U)), (float4(_S455->center_0) ).w, kernelContext_32->params_0->ground_friction_0, - _S470, _S460, vc_1 + cross(wc_1, _S469), kernelContext_32->params_0->dt_0, n_8, &stored_4, &diss_3, kernelContext_32);
        *f_1 = *f_1 + _S471;
        *t_6 = *t_6 + cross(_S469, _S471);
        thread float _S472 = ledger_2.y;
        thread float _S473 = ledger_2.z;
        comp_add1_0(&_S472, &_S473, diss_3);
        ledger_2.z = _S473;
        ledger_2.y = _S472;
        s_3 = s_3 + 1U;
    }
    if(account_0)
    {
        *(kernelContext_32->scratch_0+(kernelContext_32->params_0->ledger_base_0 + kernelContext_32->params_0->pair_count_0 + c_9)) = packed_float4(ledger_2) ;
    }
    return;
}

[[kernel]] void contact_sums(uint3 id_2 [[thread_position_in_grid]], Params_0 constant* params_5 [[buffer(0)]], Island_natural_0 device* islands_5 [[buffer(9)]], uint device* index_5 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_5 [[buffer(3)]], packed_float4 device* state_5 [[buffer(6)]], packed_float4 device* scratch_5 [[buffer(8)]], packed_float4 device* contact_state_5 [[buffer(11)]], packed_float4 device* loads_5 [[buffer(5)]], Impactor_natural_0 device* impactors_5 [[buffer(10)]], BondStatic_natural_0 device* bonds_5 [[buffer(2)]], MaterialTable_0 constant* materials_5 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_5 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_33;
    (&kernelContext_33)->params_0 = params_5;
    (&kernelContext_33)->islands_0 = islands_5;
    (&kernelContext_33)->index_0 = index_5;
    (&kernelContext_33)->chunks_0 = chunks_5;
    (&kernelContext_33)->state_0 = state_5;
    (&kernelContext_33)->scratch_0 = scratch_5;
    (&kernelContext_33)->contact_state_0 = contact_state_5;
    (&kernelContext_33)->loads_0 = loads_5;
    (&kernelContext_33)->impactors_0 = impactors_5;
    (&kernelContext_33)->bonds_0 = bonds_5;
    (&kernelContext_33)->materials_0 = materials_5;
    (&kernelContext_33)->bond_dyn_0 = bond_dyn_5;
    threadgroup array<float4, int(32)> g_part_a_5;
    (&kernelContext_33)->g_part_a_0 = &g_part_a_5;
    threadgroup array<float4, int(32)> g_part_b_5;
    (&kernelContext_33)->g_part_b_0 = &g_part_b_5;
    threadgroup array<uint, int(5)> g_seen_5;
    (&kernelContext_33)->g_seen_0 = &g_seen_5;
    threadgroup uint g_run_5;
    (&kernelContext_33)->g_run_0 = &g_run_5;
    threadgroup uint g_halt_5;
    (&kernelContext_33)->g_halt_0 = &g_halt_5;
    threadgroup uint g_wide_run_5;
    (&kernelContext_33)->g_wide_run_0 = &g_wide_run_5;
    uint g_0 = id_2.x;
    bool _S474;
    if(g_0 >= (params_5->seg_count_0))
    {
        _S474 = true;
    }
    else
    {
        bool _S475 = stopped_0(&kernelContext_33);
        _S474 = _S475;
    }
    if(_S474)
    {
        return;
    }
    uint _S476 = 3U * g_0;
    uint _S477 = (&kernelContext_33)->index_0[(&kernelContext_33)->params_0->seg_index_0 + _S476];
    uint begin_0 = (&kernelContext_33)->index_0[(&kernelContext_33)->params_0->seg_index_0 + _S476 + 1U];
    uint _S478 = (&kernelContext_33)->index_0[(&kernelContext_33)->params_0->seg_index_0 + _S476 + 2U];
    float3 _S479 = float3(0.0f) ;
    thread float3 f_2 = _S479;
    thread float3 t_7 = _S479;
    uint e_2 = begin_0;
    for(;;)
    {
        if(e_2 < _S478)
        {
        }
        else
        {
            break;
        }
        uint entry_1 = (&kernelContext_33)->index_0[e_2];
        if(entry_1 == 2147483648U)
        {
            ground_contact_0(_S477, true, &f_2, &t_7, &kernelContext_33);
            e_2 = e_2 + 1U;
            continue;
        }
        uint _S480 = 2U * entry_1;
        f_2 = f_2 + (float4(*((&kernelContext_33)->scratch_0+((&kernelContext_33)->params_0->slot_base_0 + _S480))) ).xyz;
        t_7 = t_7 + (float4(*((&kernelContext_33)->scratch_0+((&kernelContext_33)->params_0->slot_base_0 + _S480 + 1U))) ).xyz;
        e_2 = e_2 + 1U;
    }
    uint _S481 = 2U * g_0;
    *((&kernelContext_33)->scratch_0+((&kernelContext_33)->params_0->seg_base_0 + _S481)) = packed_float4(float4(f_2, 0.0f)) ;
    *((&kernelContext_33)->scratch_0+((&kernelContext_33)->params_0->seg_base_0 + _S481 + 1U)) = packed_float4(float4(t_7, 0.0f)) ;
    return;
}

void seen_clear_0(uint tid_4, KernelContext_0 thread* kernelContext_34)
{
    if(tid_4 < 5U)
    {
        (*kernelContext_34->g_seen_0)[tid_4] = 0U;
    }
    return;
}

bool contact_stopped_0(const Island_natural_0 thread* isl_0, KernelContext_0 thread* kernelContext_35)
{
    uint4 _S482 = uint4((kernelContext_35->islands_0+kernelContext_35->params_0->halt_index_0)->info_0) ;
    bool _S483;
    if(((_S482.z) & 1U) != 0U)
    {
        _S483 = true;
    }
    else
    {
        uint _S484 = _S482.y;
        if(_S484 != 0U)
        {
            _S483 = _S484 <= ((uint4(isl_0->info_0) ).w);
        }
        else
        {
            _S483 = false;
        }
    }
    return _S483;
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

bool contact_stopped_1(const Island_0 thread* isl_1, KernelContext_0 thread* kernelContext_36)
{
    uint4 _S485 = uint4((kernelContext_36->islands_0+kernelContext_36->params_0->halt_index_0)->info_0) ;
    bool _S486;
    if(((_S485.z) & 1U) != 0U)
    {
        _S486 = true;
    }
    else
    {
        uint _S487 = _S485.y;
        if(_S487 != 0U)
        {
            _S486 = _S487 <= (isl_1->info_0.w);
        }
        else
        {
            _S486 = false;
        }
    }
    return _S486;
}

struct Rigid_0
{
    Quat_0 rot_0;
    float4 rot_err_0;
    float3 pos_1;
    float3 pos_err_1;
    float3 vel_1;
    float3 vel_err_1;
    float3 w_4;
    float3 l_2;
    float3 l_err_1;
    float3 torque_0;
    float3 a_7;
    float3 alpha_0;
};

Rigid_0 rigid_of_0(const Island_natural_0 thread* isl_2)
{
    thread Rigid_0 rg_0;
    (&rg_0)->rot_0 = quat_of_0(float4(isl_2->rotation_0) );
    (&rg_0)->rot_err_0 = float4(isl_2->rotation_err_0) ;
    (&rg_0)->pos_1 = (float4(isl_2->position_0) ).xyz;
    (&rg_0)->pos_err_1 = (float4(isl_2->position_err_0) ).xyz;
    (&rg_0)->vel_1 = (float4(isl_2->velocity_0) ).xyz;
    (&rg_0)->vel_err_1 = (float4(isl_2->velocity_err_0) ).xyz;
    (&rg_0)->w_4 = (float4(isl_2->angular_velocity_0) ).xyz;
    (&rg_0)->l_2 = (float4(isl_2->momentum_0) ).xyz;
    (&rg_0)->l_err_1 = (float4(isl_2->momentum_err_0) ).xyz;
    float3 _S488 = float3(0.0f) ;
    (&rg_0)->torque_0 = _S488;
    (&rg_0)->a_7 = _S488;
    (&rg_0)->alpha_0 = _S488;
    return rg_0;
}

Rigid_0 rigid_of_1(const Island_0 thread* isl_3)
{
    thread Rigid_0 rg_1;
    (&rg_1)->rot_0 = quat_of_0(isl_3->rotation_0);
    (&rg_1)->rot_err_0 = isl_3->rotation_err_0;
    (&rg_1)->pos_1 = isl_3->position_0.xyz;
    (&rg_1)->pos_err_1 = isl_3->position_err_0.xyz;
    (&rg_1)->vel_1 = isl_3->velocity_0.xyz;
    (&rg_1)->vel_err_1 = isl_3->velocity_err_0.xyz;
    (&rg_1)->w_4 = isl_3->angular_velocity_0.xyz;
    (&rg_1)->l_2 = isl_3->momentum_0.xyz;
    (&rg_1)->l_err_1 = isl_3->momentum_err_0.xyz;
    float3 _S489 = float3(0.0f) ;
    (&rg_1)->torque_0 = _S489;
    (&rg_1)->a_7 = _S489;
    (&rg_1)->alpha_0 = _S489;
    return rg_1;
}

float time_since_0(float4 origin_0, uint k_11, float dt_4, KernelContext_0 thread* kernelContext_37)
{
    return kernelContext_37->params_0->t_hi_0 - origin_0.x + (kernelContext_37->params_0->t_lo_0 - origin_0.y) + float(k_11) * dt_4;
}

float table_eval_0(uint offset_0, uint count_3, float tau_0, KernelContext_0 thread* kernelContext_38)
{
    float4 _S490 = float4(*(kernelContext_38->loads_0+offset_0)) ;
    if(tau_0 <= (_S490.x))
    {
        return _S490.y;
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
        uint _S491 = offset_0 + i_5;
        float4 _S492 = float4(*(kernelContext_38->loads_0+_S491)) ;
        float _S493 = _S492.x;
        if(tau_0 <= _S493)
        {
            float4 _S494 = float4(*(kernelContext_38->loads_0+(_S491 - 1U))) ;
            float _S495 = _S494.x;
            float _S496 = _S494.y;
            return _S496 + (tau_0 - _S495) / max(_S493 - _S495, 1.00000000317107685e-30f) * (_S492.y - _S496);
        }
        i_5 = i_5 + 1U;
    }
    return (float4(*(kernelContext_38->loads_0+(offset_0 + count_3 - 1U))) ).y;
}

float eval_function_0(uint term_0, uint k_12, float dt_5, float shift_0, KernelContext_0 thread* kernelContext_39)
{
    uint _S497 = 5U * term_0;
    uint4 info_2 = (as_type<uint4>((float4(*(kernelContext_39->loads_0+_S497)) )));
    float4 _S498 = float4(*(kernelContext_39->loads_0+(_S497 + 3U))) ;
    float4 _S499 = float4(*(kernelContext_39->loads_0+(_S497 + 4U))) ;
    uint kind_0 = info_2.z;
    if(kind_0 == 0U)
    {
        return _S498.z;
    }
    float _S500 = time_since_0(_S498, k_12, dt_5, kernelContext_39);
    float tau_1 = _S500 + shift_0;
    float shape_1;
    if(kind_0 == 1U)
    {
        if(tau_1 <= 0.0f)
        {
            shape_1 = 0.0f;
        }
        else
        {
            float _S501 = _S499.x;
            if(tau_1 >= _S501)
            {
                shape_1 = _S499.y;
            }
            else
            {
                shape_1 = _S499.y * tau_1 / _S501;
            }
        }
        return shape_1;
    }
    bool _S502;
    if(kind_0 == 2U)
    {
        if(tau_1 < 0.0f)
        {
            _S502 = true;
        }
        else
        {
            _S502 = tau_1 > (_S499.x);
        }
        if(_S502)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S499.y * sin(3.14159274101257324f * tau_1 / _S499.x);
        }
        return shape_1;
    }
    if(kind_0 == 3U)
    {
        float sn_0 = tau_1 / _S499.y;
        if(sn_0 < 0.0f)
        {
            _S502 = true;
        }
        else
        {
            _S502 = sn_0 > 1.0f;
        }
        if(_S502)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S499.x * (1.0f - sn_0) * exp(- _S499.z * sn_0);
        }
        return shape_1;
    }
    if(kind_0 == 4U)
    {
        float _S503 = table_eval_0(info_2.w, (as_type<uint>((_S499.x))), tau_1, kernelContext_39);
        return _S503;
    }
    if(kind_0 == 5U)
    {
        (*kernelContext_39->g_seen_0)[1U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float sn_1 = tau_1 / _S499.x;
        if(sn_1 < 0.0f)
        {
            _S502 = true;
        }
        else
        {
            _S502 = sn_1 > 1.0f;
        }
        if(_S502)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = (1.0f - sn_1) * exp(- _S499.y * sn_1);
        }
        float clearing_0 = _S498.w;
        float relax_0;
        if(clearing_0 > 0.0f)
        {
            relax_0 = max(1.0f - tau_1 / clearing_0, 0.0f);
        }
        else
        {
            relax_0 = 0.0f;
        }
        float _S504 = _S499.w;
        return (_S504 + (_S499.z - _S504) * relax_0) * shape_1;
    }
    if(kind_0 == 7U)
    {
        (*kernelContext_39->g_seen_0)[2U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float _S505 = _S499.y;
        if(tau_1 < _S505)
        {
            return _S499.x;
        }
        float s_4 = tau_1 - _S505;
        float _S506 = _S499.w;
        if(s_4 > _S506)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S499.z * sin(3.14159274101257324f * s_4 / _S506);
        }
        return shape_1;
    }
    float _S507 = _S499.x;
    if(_S507 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp(1.0f - tau_1 / _S507, 0.0f, 1.0f);
}

void record_chunk_load_0(uint c_10, float3 f_3, float3 t_8, KernelContext_0 thread* kernelContext_40)
{
    if((kernelContext_40->params_0->solve_mode_0) == 0U)
    {
        return;
    }
    uint _S508 = 2U * c_10;
    *(kernelContext_40->scratch_0+(kernelContext_40->params_0->cload_base_0 + _S508)) = packed_float4(float4(f_3, 0.0f)) ;
    *(kernelContext_40->scratch_0+(kernelContext_40->params_0->cload_base_0 + _S508 + 1U)) = packed_float4(float4(t_8, 0.0f)) ;
    *(kernelContext_40->scratch_0+(kernelContext_40->params_0->cframe_base_0 + _S508)) = packed_float4(float4((float4(*(kernelContext_40->scratch_0+(kernelContext_40->params_0->cframe_base_0 + _S508))) ).xyz + f_3, 0.0f)) ;
    *(kernelContext_40->scratch_0+(kernelContext_40->params_0->cframe_base_0 + _S508 + 1U)) = packed_float4(float4((float4(*(kernelContext_40->scratch_0+(kernelContext_40->params_0->cframe_base_0 + _S508 + 1U))) ).xyz + t_8, 0.0f)) ;
    return;
}

void chunk_loads_0(uint _S509, uint _S510, const Quat_0 thread* _S511, uint _S512, float _S513, bool _S514, float _S515, float3 thread* _S516, float3 thread* _S517, float3 thread* _S518, float3 thread* _S519, KernelContext_0 thread* kernelContext_41)
{
    bool _S520;
    ChunkStatic_natural_0 device* _S521 = kernelContext_41->chunks_0+_S510;
    float3 _S522 = float3(0.0f) ;
    *_S516 = _S522;
    *_S517 = _S522;
    *_S518 = _S522;
    *_S519 = _S522;
    uint4 _S523 = uint4(_S521->load_range_0) ;
    uint term_1 = _S523.x;
    for(;;)
    {
        if(term_1 < (_S523.y))
        {
        }
        else
        {
            break;
        }
        (*kernelContext_41->g_seen_0)[0U] = 1U;
        uint _S524 = 5U * term_1;
        uint _S525 = (as_type<uint4>((float4(*(kernelContext_41->loads_0+_S524)) ))).y;
        bool replacement_0 = _S525 == 2U;
        float4 _S526 = float4(*(kernelContext_41->loads_0+(_S524 + 1U))) ;
        float4 _S527 = float4(*(kernelContext_41->loads_0+(_S524 + 2U))) ;
        float _S528;
        if(replacement_0)
        {
            _S528 = _S515;
        }
        else
        {
            _S528 = 0.0f;
        }
        float _S529 = eval_function_0(term_1, _S512, _S513, _S528, kernelContext_41);
        if(replacement_0)
        {
            float3 _S530 = float3(_S529) ;
            *_S518 = *_S518 + _S526.xyz * _S530;
            *_S519 = *_S519 + _S527.xyz * _S530;
            term_1 = term_1 + 1U;
            continue;
        }
        if(_S525 == 0U)
        {
            _S520 = true;
        }
        else
        {
            _S520 = _S525 == 3U;
        }
        float3 fw_0;
        if(_S520)
        {
            fw_0 = _S526.xyz * float3(_S529) ;
        }
        else
        {
            float3 _S531 = rotate_0(_S511, _S526.xyz);
            fw_0 = _S531 * float3((- _S529 * _S526.w)) ;
        }
        float3 lever_0;
        if(_S525 == 3U)
        {
            lever_0 = _S527.xyz - (float4(*(kernelContext_41->state_0+4U * _S509)) ).xyz;
        }
        else
        {
            lever_0 = _S527.xyz;
        }
        *_S516 = *_S516 + fw_0;
        float3 _S532 = rotate_0(_S511, lever_0);
        *_S517 = *_S517 + cross(_S532, fw_0);
        term_1 = term_1 + 1U;
    }
    if(_S514)
    {
        _S520 = ((uint4(_S521->cinfo_0) ).z) != 0U;
    }
    else
    {
        _S520 = false;
    }
    if(_S520)
    {
        uint4 _S533 = uint4(_S521->cinfo_0) ;
        uint g_1 = _S533.x;
        for(;;)
        {
            if(g_1 < (_S533.y))
            {
            }
            else
            {
                break;
            }
            uint _S534 = 2U * g_1;
            *_S516 = *_S516 + (float4(*(kernelContext_41->scratch_0+(kernelContext_41->params_0->seg_base_0 + _S534))) ).xyz;
            *_S517 = *_S517 + (float4(*(kernelContext_41->scratch_0+(kernelContext_41->params_0->seg_base_0 + _S534 + 1U))) ).xyz;
            g_1 = g_1 + 1U;
        }
    }
    return;
}

void chunk_external_0(uint _S535, uint _S536, const Quat_0 thread* _S537, uint _S538, float _S539, bool _S540, float3 thread* _S541, float3 thread* _S542, KernelContext_0 thread* kernelContext_42)
{
    thread float3 rf_1;
    thread float3 rm_0;
    chunk_loads_0(_S535, _S536, _S537, _S538, _S539, _S540, 0.0f, _S541, _S542, &rf_1, &rm_0, kernelContext_42);
    return;
}

float settled_chunk_load_0(uint c_11, const Quat_0 thread* rot_1, uint k_13, float dt_6, bool contact_0, KernelContext_0 thread* kernelContext_43)
{
    thread float3 f_4;
    thread float3 t_9;
    chunk_external_0(c_11, c_11, rot_1, k_13, dt_6, contact_0, &f_4, &t_9, kernelContext_43);
    record_chunk_load_0(c_11, f_4, t_9, kernelContext_43);
    return length(f_4);
}

void net_load_0(uint c_12, const Island_natural_0 thread* isl_4, const Rigid_0 thread* rg_2, uint k_14, float dt_7, bool contact_1, float3 thread* f_5, float3 thread* t_10, KernelContext_0 thread* kernelContext_44)
{
    ChunkStatic_natural_0 device* _S543 = kernelContext_44->chunks_0+c_12;
    thread float3 fl_0;
    thread float3 tl_0;
    thread float3 rep_f_0;
    thread float3 rep_m_0;
    chunk_loads_0(c_12, c_12, &rg_2->rot_0, k_14, dt_7, contact_1, 0.0f, &fl_0, &tl_0, &rep_f_0, &rep_m_0, kernelContext_44);
    float4 _S544 = float4(_S543->center_0) ;
    float3 fc_0 = fl_0 + kernelContext_44->params_0->gravity_0.xyz * float3(_S544.w) ;
    float3 _S545 = _S544.xyz;
    float3 _S546 = (float4(isl_4->com_0) ).xyz;
    float3 _S547 = rotate_0(&rg_2->rot_0, _S545 + (float4(*(kernelContext_44->state_0+4U * c_12)) ).xyz - _S546);
    *f_5 = *f_5 + fc_0;
    *t_10 = *t_10 + (cross(_S547, fc_0) + tl_0);
    uint4 _S548 = uint4(_S543->load_range_0) ;
    if((_S548.y) > (_S548.x))
    {
        float3 _S549 = rotate_0(&rg_2->rot_0, rep_f_0);
        *f_5 = *f_5 + _S549;
        float3 _S550 = rotate_0(&rg_2->rot_0, _S545 - _S546);
        float3 _S551 = cross(_S550, _S549);
        float3 _S552 = rotate_0(&rg_2->rot_0, rep_m_0);
        *t_10 = *t_10 + (_S551 + _S552);
    }
    return;
}

void net_load_1(uint c_13, const Island_0 thread* isl_5, const Rigid_0 thread* rg_3, uint k_15, float dt_8, bool contact_2, float3 thread* f_6, float3 thread* t_11, KernelContext_0 thread* kernelContext_45)
{
    ChunkStatic_natural_0 device* _S553 = kernelContext_45->chunks_0+c_13;
    thread float3 fl_1;
    thread float3 tl_1;
    thread float3 rep_f_1;
    thread float3 rep_m_1;
    chunk_loads_0(c_13, c_13, &rg_3->rot_0, k_15, dt_8, contact_2, 0.0f, &fl_1, &tl_1, &rep_f_1, &rep_m_1, kernelContext_45);
    float4 _S554 = float4(_S553->center_0) ;
    float3 fc_1 = fl_1 + kernelContext_45->params_0->gravity_0.xyz * float3(_S554.w) ;
    float3 _S555 = _S554.xyz;
    float3 _S556 = isl_5->com_0.xyz;
    float3 _S557 = rotate_0(&rg_3->rot_0, _S555 + (float4(*(kernelContext_45->state_0+4U * c_13)) ).xyz - _S556);
    *f_6 = *f_6 + fc_1;
    *t_11 = *t_11 + (cross(_S557, fc_1) + tl_1);
    uint4 _S558 = uint4(_S553->load_range_0) ;
    if((_S558.y) > (_S558.x))
    {
        float3 _S559 = rotate_0(&rg_3->rot_0, rep_f_1);
        *f_6 = *f_6 + _S559;
        float3 _S560 = rotate_0(&rg_3->rot_0, _S555 - _S556);
        float3 _S561 = cross(_S560, _S559);
        float3 _S562 = rotate_0(&rg_3->rot_0, rep_m_1);
        *t_11 = *t_11 + (_S561 + _S562);
    }
    return;
}

void rigid_acceleration_0(const Island_natural_0 thread* isl_6, Rigid_0 thread* rg_4, float3 f_7, float3 t_12)
{
    float4 _S563 = float4(isl_6->inertia0_0) ;
    float4 _S564 = float4(isl_6->inertia1_0) ;
    float4 _S565 = float4(isl_6->inertia2_0) ;
    thread Quat_0 _S566 = rg_4->rot_0;
    float3 _S567 = world_mul_0(&_S566, _S563, _S564, _S565, rg_4->w_4);
    rg_4->a_7 = f_7 / float3((float4(isl_6->com_0) ).w) ;
    float4 _S568 = float4(isl_6->inv0_0) ;
    float4 _S569 = float4(isl_6->inv1_0) ;
    float4 _S570 = float4(isl_6->inv2_0) ;
    float3 _S571 = t_12 - cross(rg_4->w_4, _S567);
    thread Quat_0 _S572 = rg_4->rot_0;
    float3 _S573 = world_mul_0(&_S572, _S568, _S569, _S570, _S571);
    rg_4->alpha_0 = _S573;
    rg_4->torque_0 = t_12;
    return;
}

void rigid_acceleration_1(const Island_0 thread* isl_7, Rigid_0 thread* rg_5, float3 f_8, float3 t_13)
{
    thread Quat_0 _S574 = rg_5->rot_0;
    float3 _S575 = world_mul_0(&_S574, isl_7->inertia0_0, isl_7->inertia1_0, isl_7->inertia2_0, rg_5->w_4);
    rg_5->a_7 = f_8 / float3(isl_7->com_0.w) ;
    float3 _S576 = t_13 - cross(rg_5->w_4, _S575);
    thread Quat_0 _S577 = rg_5->rot_0;
    float3 _S578 = world_mul_0(&_S577, isl_7->inv0_0, isl_7->inv1_0, isl_7->inv2_0, _S576);
    rg_5->alpha_0 = _S578;
    rg_5->torque_0 = t_13;
    return;
}

bool is_damaged_0(const JointState_0 thread* st_0)
{
    bool _S579;
    if((st_0->damage_0) > 0.0f)
    {
        _S579 = true;
    }
    else
    {
        _S579 = (st_0->crush_1) > 0.0f;
    }
    return _S579;
}

bool connected_0(const JointState_0 thread* st_1, bool has_rebar_0)
{
    bool _S580;
    if((st_1->damage_0) < 1.0f)
    {
        _S580 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S580 = (st_1->rebar_broken_0) == 0.0f;
        }
        else
        {
            _S580 = false;
        }
    }
    return _S580;
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
    float4 _S581 = float4(b_23->geom0_0) ;
    float area_2 = _S581.x;
    float _S582 = q_lin_0.z;
    float axial_0 = (metal::fast::divide((_S582), (area_2)));
    float4 _S583 = float4(b_23->geom1_0) ;
    float _S584 = (metal::fast::divide((abs(q_ang_0.x)), (_S583.x)));
    float _S585 = (metal::fast::divide((abs(q_ang_0.y)), (_S583.y)));
    float bending_0 = _S584 + _S585;
    float _S586 = q_lin_0.x;
    float _S587 = q_lin_0.y;
    float _S588 = (metal::fast::sqrt((_S586 * _S586 + _S587 * _S587)));
    float _S589 = (metal::fast::divide((_S588), (area_2)));
    float _S590 = (metal::fast::divide((abs(q_ang_0.z)), (_S581.w)));
    float shear_1 = _S589 + _S590;
    thread Measures_0 m_3;
    (&m_3)->tension_0 = axial_0 + bending_0;
    (&m_3)->shear_0 = shear_1;
    float _S591 = - axial_0;
    (&m_3)->normal_compression_0 = max(_S591, 0.0f);
    (&m_3)->compression_0 = _S591 + bending_0;
    (&m_3)->compressive_force_0 = max(- _S582, 0.0f);
    return m_3;
}

float expm1_accurate_0(float x_11)
{
    if((abs(x_11)) < 0.00100000004749745f)
    {
        return x_11 * (1.0f + x_11 * (0.5f + x_11 * 0.1666666716337204f));
    }
    return exp(x_11) - 1.0f;
}

float dif_factor_0(const JointMaterial_0 constant* mat_1, float strain_rate_1)
{
    float r_6 = abs(strain_rate_1);
    float4 _S592 = mat_1->dif_0;
    float ref_0 = mat_1->dif_0.x;
    if(r_6 <= ref_0)
    {
        return 1.0f;
    }
    float _S593 = _S592.z;
    float f_9;
    if(r_6 <= _S593)
    {
        float _S594 = (metal::fast::divide((r_6), (ref_0)));
        float _S595 = (metal::fast::pow((_S594), (_S592.y)));
        f_9 = _S595;
    }
    else
    {
        float _S596 = (metal::fast::divide((_S593), (ref_0)));
        float _S597 = (metal::fast::pow((_S596), (_S592.y)));
        float _S598 = (metal::fast::divide((r_6), (_S593)));
        float _S599 = (metal::fast::pow((_S598), (_S592.w)));
        f_9 = _S597 * _S599;
    }
    return clamp(f_9, 1.0f, mat_1->misc_0.x);
}

float fatigue_factor_0(const JointMaterial_0 constant* mat_2, float life_1)
{
    if(((mat_2->kind_flags_0.y) & 64U) == 0U)
    {
        return 1.0f;
    }
    float _S600 = clamp(life_1, 0.0f, 1.0f);
    float _S601 = (metal::fast::divide((1.0f), (mat_2->misc_0.y - 2.0f)));
    float _S602 = (metal::fast::pow((_S600), (_S601)));
    return _S602;
}

float infinity_0()
{
    return (as_type<float>((2139095040U)));
}

float4 failure_indices_0(const JointMaterial_0 constant* mat_3, const JointBond_natural_0 thread* b_24, const Measures_0 thread* m_4, float multiplier_0)
{
    float fc_2 = mat_3->strength_0.y * multiplier_0;
    float _S603 = min(mat_3->strength_0.z * multiplier_0 + mat_3->strength_0.w * m_4->normal_compression_0, mat_3->energy_1.x * multiplier_0);
    thread float4 idx_0;
    float _S604 = (metal::fast::divide((m_4->tension_0), (mat_3->strength_0.x * multiplier_0)));
    idx_0.x = max(_S604, 0.0f);
    float _S605;
    if(_S603 > 0.0f)
    {
        float _S606 = (metal::fast::divide((m_4->shear_0), (_S603)));
        _S605 = _S606;
    }
    else
    {
        _S605 = infinity_0();
    }
    idx_0.y = _S605;
    float _S607 = (metal::fast::divide((m_4->compression_0), (fc_2)));
    idx_0.z = max(_S607, 0.0f);
    float _S608 = (float4(b_24->stiff1_0) ).y;
    if(_S608 > 0.0f)
    {
        float _S609 = (metal::fast::divide((m_4->compressive_force_0), (_S608)));
        _S605 = _S609;
    }
    else
    {
        _S605 = 0.0f;
    }
    idx_0.w = _S605;
    return idx_0;
}

float sq_0(float x_12)
{
    return x_12 * x_12;
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
        float _S610 = (metal::fast::divide((r_7 * (kappa_1 - 1.0f)), (kappa_1 * (r_7 - 1.0f))));
        return min(_S610, 1.0f);
    }
    if(kappa_1 >= (0.5f * (r_7 + 1.0f)))
    {
        return 1.0f;
    }
    float _S611 = (metal::fast::divide((1.0f), (kappa_1)));
    return 1.0f - _S611;
}

__attribute__((noinline))
float2 damage_increment_0(uint kind_2, float kappa_old_0, float lambda_0, float r_8, float d_old_0, float psi_0)
{
    float _S612 = damage_law_0(kind_2, lambda_0, r_8);
    float _S613 = max(_S612, d_old_0);
    bool _S614;
    if(_S613 <= d_old_0)
    {
        _S614 = true;
    }
    else
    {
        _S614 = d_old_0 >= 1.0f;
    }
    if(_S614)
    {
        return float2(d_old_0, 0.0f);
    }
    float u0_0 = (metal::fast::divide((psi_0), (lambda_0 * lambda_0)));
    float _S615 = max(kappa_old_0, 1.0f);
    if(kind_2 == 0U)
    {
        if(r_8 > 1.0f)
        {
            float _S616 = (metal::fast::divide((u0_0 * r_8), (r_8 - 1.0f)));
            return float2(_S613, _S616 * max(min(lambda_0, r_8) - min(_S615, r_8), 0.0f));
        }
        return float2(_S613, (1.0f - d_old_0) * psi_0);
    }
    float ku_0 = 0.5f * (r_8 + 1.0f);
    float plateau_0 = u0_0 * max(min(lambda_0, ku_0) - min(_S615, ku_0), 0.0f);
    float snap_0;
    if(_S613 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return float2(_S613, plateau_0 + snap_0);
}

void compressed_region_0(float w0_0, float w1_0, float dz_0, float ax_0, float ay_0, array<float, int(6)> thread* region_0)
{
    uint count_4;
    float h0_0 = 0.5f * w0_0;
    float h1_0 = 0.5f * w1_0;
    float _S617 = - h0_0;
    float _S618 = - h1_0;
    array<float2, int(4)> _S619 = { { float2(_S617, _S618), float2(h0_0, _S618), float2(h0_0, h1_0), float2(_S617, h1_0) } };
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
        uint _S620 = i_6;
        uint _S621 = i_6 + 1U;
        uint _S622 = _S621 % 4U;
        float _S623 = _S619[i_6].y;
        float _S624 = _S619[i_6].x;
        float fp_0 = dz_0 + ax_0 * _S623 - ay_0 * _S624;
        float _S625 = _S619[_S622].y;
        float _S626 = _S619[_S622].x;
        float fq_0 = dz_0 + ax_0 * _S625 - ay_0 * _S626;
        bool _S627 = fp_0 < 0.0f;
        if(_S627)
        {
            uint _S628 = count_5 + 1U;
            poly_0[count_5] = _S619[_S620];
            count_4 = _S628;
        }
        else
        {
            count_4 = count_5;
        }
        if(_S627 != (fq_0 < 0.0f))
        {
            float t_14 = fp_0 / (fp_0 - fq_0);
            uint _S629 = count_4 + 1U;
            poly_0[count_4] = float2(_S624 + t_14 * (_S626 - _S624), _S623 + t_14 * (_S625 - _S623));
            count_5 = _S629;
        }
        else
        {
            count_5 = count_4;
        }
        i_6 = _S621;
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
    float a_8 = 0.0f;
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
        float _S630 = o_1.x;
        float x0_0 = poly_0[i_6].x - _S630;
        float _S631 = o_1.y;
        float y0_0 = poly_0[i_6].y - _S631;
        uint _S632 = i_6 + 1U;
        uint _S633 = _S632 % count_5;
        float x1_0 = poly_0[_S633].x - _S630;
        float y1_0 = poly_0[_S633].y - _S631;
        float _S634 = x0_0 * y1_0;
        float _S635 = x1_0 * y0_0;
        float cr_0 = _S634 - _S635;
        float a_9 = a_8 + cr_0 / 2.0f;
        float sx_1 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        float sy_1 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        float ixx_1 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        float iyy_1 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        float ixy_1 = ixy_0 + (_S634 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S635) * cr_0 / 24.0f;
        i_6 = _S632;
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
    float _S636 = a_8 * cx_0;
    (*region_0)[int(3)] = ixx_0 - _S636 * cx_0;
    (*region_0)[int(4)] = iyy_0 - a_8 * cy_0 * cy_0;
    (*region_0)[int(5)] = ixy_0 - _S636 * cy_0;
    return;
}

__attribute__((noinline))
float4 no_tension_patch_0(float kn_0, float w0_1, float w1_1, float dz_1, float ax_1, float ay_1)
{
    thread array<float, int(6)> r_9;
    compressed_region_0(w0_1, w1_1, dz_1, ax_1, ay_1, &r_9);
    float a_10 = r_9[int(0)];
    if((r_9[int(0)]) == 0.0f)
    {
        return float4(0.0f) ;
    }
    float k_16 = kn_0 / (w0_1 * w1_1);
    float fc_3 = dz_1 + ax_1 * r_9[int(2)] - ay_1 * r_9[int(1)];
    float _S637 = a_10 * fc_3;
    float _S638 = - ay_1;
    return float4(k_16 * a_10 * fc_3, k_16 * (_S637 * r_9[int(2)] + (_S638 * r_9[int(5)] + ax_1 * r_9[int(4)])), - k_16 * (_S637 * r_9[int(1)] + (_S638 * r_9[int(3)] + ax_1 * r_9[int(5)])), 0.5f * k_16 * (_S637 * fc_3 + ay_1 * ay_1 * r_9[int(3)] + ax_1 * ax_1 * r_9[int(4)] - 2.0f * ax_1 * ay_1 * r_9[int(5)]));
}

float signum_0(float x_13)
{
    float _S639;
    if(((as_type<uint>((x_13))) & 2147483648U) != 0U)
    {
        _S639 = -1.0f;
    }
    else
    {
        _S639 = 1.0f;
    }
    return _S639;
}

float2 return_map_0(float k_17, float total_2, float plastic_0, float cap_0)
{
    float trial_0 = k_17 * (total_2 - plastic_0);
    if((abs(trial_0)) <= cap_0)
    {
        return float2(trial_0, 0.0f);
    }
    float f_10 = cap_0 * signum_0(trial_0);
    float _S640 = (metal::fast::divide((trial_0 - f_10), (k_17)));
    return float2(f_10, _S640);
}

struct Contact_0
{
    float3 q_lin_1;
    float3 q_ang_1;
    float energy_2;
    float diss_4;
    float3 plastic_1;
};

__attribute__((noinline))
Contact_0 contact_part_0(const JointMaterial_0 constant* mat_4, const JointBond_natural_0 thread* b_25, float crush_2, float3 plastic_2, float3 d_lin_0, float3 d_ang_0)
{
    thread Contact_0 c_14;
    float3 _S641 = float3(0.0f) ;
    (&c_14)->q_lin_1 = _S641;
    (&c_14)->q_ang_1 = _S641;
    (&c_14)->energy_2 = 0.0f;
    (&c_14)->diss_4 = 0.0f;
    (&c_14)->plastic_1 = plastic_2;
    uint _S642 = mat_4->kind_flags_0.y;
    if((_S642 & 2U) == 0U)
    {
        return c_14;
    }
    float4 _S643 = float4(b_25->stiff0_0) ;
    float kn_1 = _S643.x;
    float ks_0 = _S643.y;
    float kt_0 = (float4(b_25->stiff1_0) ).x;
    float4 _S644 = float4(b_25->geom0_0) ;
    float w0_2 = _S644.y;
    float w1_2 = _S644.z;
    float diss_5;
    float nc_sum_0;
    float m1_0;
    float m2_0;
    float energy_3;
    if((_S642 & 4U) != 0U)
    {
        float4 p_11 = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        float _S645 = p_11.y;
        float _S646 = p_11.z;
        float _S647 = p_11.w;
        nc_sum_0 = p_11.x;
        m1_0 = _S645;
        m2_0 = _S646;
        energy_3 = _S647;
    }
    else
    {
        float ki_0 = kn_1 * (1.0f - crush_2) / 36.0f;
        float _S648 = d_ang_0.x;
        float _S649 = d_ang_0.y;
        float spread_0 = abs(_S648) * 0.4166666567325592f * w1_2 + abs(_S649) * 0.4166666567325592f * w0_2;
        float _S650 = d_lin_0.z;
        float slack_0 = 9.99999997475242708e-07f * (abs(_S650) + spread_0);
        if((_S650 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S650 + spread_0) < (- slack_0))
            {
                float i1_0 = 2.91666650772094727f * w0_2 * w0_2;
                float i2_0 = 2.91666650772094727f * w1_2 * w1_2;
                float _S651 = ki_0 * _S648 * i2_0;
                float _S652 = ki_0 * _S649 * i1_0;
                float _S653 = 0.5f * ki_0 * (36.0f * _S650 * _S650 + _S648 * _S648 * i2_0 + _S649 * _S649 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S650;
                m1_0 = _S651;
                m2_0 = _S652;
                energy_3 = _S653;
            }
            else
            {
                uint i_7 = 0U;
                diss_5 = 0.0f;
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
                    float _S654 = SPRING_AT_0[i_7] * w0_2;
                    uint j_6 = 0U;
                    nc_sum_0 = diss_5;
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
                        float di_0 = _S650 + _S648 * s2_0 - _S649 * _S654;
                        if(di_0 < 0.0f)
                        {
                            float f_11 = ki_0 * di_0;
                            float m1_2 = m1_0 + f_11 * s2_0;
                            float m2_2 = m2_0 - f_11 * _S654;
                            float energy_5 = energy_3 + 0.5f * ki_0 * di_0 * di_0;
                            nc_sum_0 = nc_sum_0 + f_11;
                            m1_0 = m1_2;
                            m2_0 = m2_2;
                            energy_3 = energy_5;
                        }
                        j_6 = j_6 + 1U;
                    }
                    i_7 = i_7 + 1U;
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
    thread float3 p_12 = plastic_2;
    (&c_14)->q_lin_1 = float3(0.0f, 0.0f, nc_sum_0);
    (&c_14)->q_ang_1 = float3(m1_0, m2_0, 0.0f);
    float slide_cap_0 = mat_4->strength_0.w * nc_0;
    float _S655 = ks_0 * (d_lin_0.x - plastic_2.x);
    float _S656 = ks_0 * (d_lin_0.y - plastic_2.y);
    float tn_0 = (metal::fast::sqrt((_S655 * _S655 + _S656 * _S656)));
    bool _S657;
    if(tn_0 > slide_cap_0)
    {
        _S657 = tn_0 > 0.0f;
    }
    else
    {
        _S657 = false;
    }
    if(_S657)
    {
        float _S658 = (metal::fast::divide((_S655), (tn_0)));
        float _S659 = (metal::fast::divide((_S656), (tn_0)));
        float dslip_0 = (metal::fast::divide((tn_0 - slide_cap_0), (ks_0)));
        p_12.x = p_12.x + _S658 * dslip_0;
        p_12.y = p_12.y + _S659 * dslip_0;
        (&c_14)->q_lin_1.x = _S658 * slide_cap_0;
        (&c_14)->q_lin_1.y = _S659 * slide_cap_0;
        diss_5 = slide_cap_0 * dslip_0;
    }
    else
    {
        (&c_14)->q_lin_1.x = _S655;
        (&c_14)->q_lin_1.y = _S656;
        diss_5 = 0.0f;
    }
    float2 tq_0 = return_map_0(kt_0, d_ang_0.z, p_12.z, slide_cap_0 * (float4(b_25->geom1_0) ).z);
    float _S660 = tq_0.x;
    float _S661 = tq_0.y;
    float diss_6 = diss_5 + abs(_S660) * abs(_S661);
    p_12.z = p_12.z + _S661;
    (&c_14)->q_ang_1.z = _S660;
    float _S662 = (metal::fast::divide((sq_0((&c_14)->q_lin_1.x)), (ks_0)));
    float _S663 = (metal::fast::divide((sq_0((&c_14)->q_lin_1.y)), (ks_0)));
    float _S664 = _S662 + _S663;
    float _S665 = (metal::fast::divide((sq_0(_S660)), (kt_0)));
    (&c_14)->energy_2 = energy_3 + 0.5f * (_S664 + _S665);
    (&c_14)->diss_4 = diss_6;
    (&c_14)->plastic_1 = p_12;
    return c_14;
}

float3 contact_offsets_0(const JointMaterial_0 constant* mat_5, const JointBond_natural_0 thread* b_26, float crush_3, float3 plastic_3, float3 d_lin_1, float3 d_ang_1)
{
    uint _S666 = mat_5->kind_flags_0.y;
    if((_S666 & 2U) == 0U)
    {
        return plastic_3;
    }
    float4 _S667 = float4(b_26->stiff0_0) ;
    float kn_2 = _S667.x;
    float ks_1 = _S667.y;
    float kt_1 = (float4(b_26->stiff1_0) ).x;
    float4 _S668 = float4(b_26->geom0_0) ;
    float w0_3 = _S668.y;
    float w1_3 = _S668.z;
    float nc_sum_1;
    if((_S666 & 4U) != 0U)
    {
        float4 _S669 = no_tension_patch_0(kn_2 * (1.0f - crush_3), w0_3, w1_3, d_lin_1.z, d_ang_1.x, d_ang_1.y);
        nc_sum_1 = _S669.x;
    }
    else
    {
        float ki_1 = kn_2 * (1.0f - crush_3) / 36.0f;
        float _S670 = d_ang_1.x;
        float _S671 = d_ang_1.y;
        float spread_1 = abs(_S670) * 0.4166666567325592f * w1_3 + abs(_S671) * 0.4166666567325592f * w0_3;
        float _S672 = d_lin_1.z;
        float slack_1 = 9.99999997475242708e-07f * (abs(_S672) + spread_1);
        if((_S672 - spread_1) > slack_1)
        {
            nc_sum_1 = 0.0f;
        }
        else
        {
            if((_S672 + spread_1) < (- slack_1))
            {
                nc_sum_1 = ki_1 * 36.0f * _S672;
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
                    float _S673 = SPRING_AT_0[i_8] * w0_3;
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
                        float di_1 = _S672 + _S670 * (SPRING_AT_0[j_7] * w1_3) - _S671 * _S673;
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
    thread float3 p_13 = plastic_3;
    float slide_cap_1 = mat_5->strength_0.w * nc_1;
    float _S674 = ks_1 * (d_lin_1.x - plastic_3.x);
    float _S675 = ks_1 * (d_lin_1.y - plastic_3.y);
    float tn_1 = (metal::fast::sqrt((_S674 * _S674 + _S675 * _S675)));
    bool _S676;
    if(tn_1 > slide_cap_1)
    {
        _S676 = tn_1 > 0.0f;
    }
    else
    {
        _S676 = false;
    }
    if(_S676)
    {
        float _S677 = (metal::fast::divide((_S674), (tn_1)));
        float _S678 = (metal::fast::divide((_S675), (tn_1)));
        float dslip_1 = (metal::fast::divide((tn_1 - slide_cap_1), (ks_1)));
        p_13.x = p_13.x + _S677 * dslip_1;
        p_13.y = p_13.y + _S678 * dslip_1;
    }
    float2 tq_1 = return_map_0(kt_1, d_ang_1.z, p_13.z, slide_cap_1 * (float4(b_26->geom1_0) ).z);
    p_13.z = p_13.z + tq_1.y;
    return p_13;
}

float life_rate_0(const JointMaterial_0 constant* mat_6, float s_5)
{
    if(s_5 <= 0.0f)
    {
        return 0.0f;
    }
    float _S679 = mat_6->misc_0.y;
    float _S680 = _S679 + 1.0f;
    float _S681 = (metal::fast::pow((s_5), (_S679)));
    float _S682 = (metal::fast::divide((_S680 * _S681), (mat_6->misc_0.z)));
    return _S682;
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
    float fatigue_before_0;
    Measures_0 measures_0;
};

JointResponse_0 joint_evaluate_0(const JointMaterial_0 constant* mat_7, const JointBond_natural_0 thread* b_27, const JointState_0 thread* state_7, float3 d_lin_2, float3 d_ang_2, float dt_9, bool fracture_1)
{
    float4 _S683 = float4(b_27->stiff0_0) ;
    float kn_3 = _S683.x;
    float ks_2 = _S683.y;
    float kb1_0 = _S683.z;
    float kb2_0 = _S683.w;
    float4 _S684 = float4(b_27->stiff1_0) ;
    float kt_2 = _S684.x;
    bool has_rebar_1 = (_S684.w) != 0.0f;
    uint kind_3 = mat_7->kind_flags_0.x;
    uint flags_1 = mat_7->kind_flags_0.y;
    bool softening_0 = (flags_1 & 1U) != 0U;
    thread JointState_0 st_2 = *state_7;
    bool _S685 = connected_0(state_7, has_rebar_1);
    float3 qe_lin_0 = d_lin_2 * float3(ks_2, ks_2, kn_3);
    float3 qe_ang_0 = d_ang_2 * float3(kb1_0, kb2_0, kt_2);
    Measures_0 _S686 = stress_measures_0(b_27, qe_lin_0, qe_ang_0);
    float _S687 = max(max(_S686.tension_0, _S686.shear_0), _S686.compression_0);
    bool _S688 = dt_9 > 0.0f;
    float dif_1;
    if(_S688)
    {
        float _S689 = (metal::fast::divide((_S687 - (&st_2)->governing_stress_0), (dt_9)));
        float raw_0 = (metal::fast::divide((max(_S689, 0.0f)), (mat_7->misc_0.w)));
        float tau_2 = _S684.z;
        if((flags_1 & 16U) != 0U)
        {
            float _S690 = (metal::fast::divide((dt_9), (tau_2)));
            dif_1 = - expm1_accurate_0(- _S690);
        }
        else
        {
            float _S691 = (metal::fast::divide((dt_9), (tau_2)));
            dif_1 = min(_S691, 1.0f);
        }
        (&st_2)->strain_rate_0 = (&st_2)->strain_rate_0 + (raw_0 - (&st_2)->strain_rate_0) * dif_1;
        (&st_2)->governing_stress_0 = _S687;
    }
    if((flags_1 & 32U) != 0U)
    {
        float _S692 = dif_factor_0(mat_7, (&st_2)->strain_rate_0);
        dif_1 = _S692;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = (float4(b_27->geom1_0) ).w;
    float _S693 = fatigue_factor_0(mat_7, (&st_2)->life_0);
    float multiplier_1 = weibull_0 * dif_1 * _S693;
    thread Measures_0 _S694 = _S686;
    float4 _S695 = failure_indices_0(mat_7, b_27, &_S694, multiplier_1);
    float _S696 = _S695.x;
    float _S697 = _S695.y;
    (&st_2)->utilization_0 = max(max(_S696, _S697), max(_S695.z, _S695.w));
    float _S698 = d_lin_2.x;
    float _S699 = d_lin_2.y;
    float _S700 = ks_2 * (sq_0(_S698) + sq_0(_S699)) + kb1_0 * sq_0(d_ang_2.x) + kb2_0 * sq_0(d_ang_2.y) + kt_2 * sq_0(d_ang_2.z);
    float _S701 = d_lin_2.z;
    bool _S702 = _S701 > 0.0f;
    if(_S702)
    {
        dif_1 = kn_3 * sq_0(_S701);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S700 + dif_1);
    float psi_c_0;
    if(_S701 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_3 * sq_0(_S701);
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
    bool _S703;
    float3 qc_lin_0;
    if(fracture_1)
    {
        bool _S704 = _S696 >= _S697;
        if(_S704)
        {
            diss_contact_0 = _S696;
        }
        else
        {
            diss_contact_0 = _S697;
        }
        uint mode_ts_0;
        if(_S704)
        {
            mode_ts_0 = 1U;
        }
        else
        {
            mode_ts_0 = 2U;
        }
        if(diss_contact_0 > ((&st_2)->kappa_0))
        {
            _S703 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S703 = false;
        }
        if(_S703)
        {
            _S703 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S703 = false;
        }
        uint mode_c_0;
        if(_S703)
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
                float _S705 = (metal::fast::divide((psi_contact_0 * (float4(b_27->geom0_0) ).x * diss_contact_0 * diss_contact_0), (psi_ts_0)));
                intact_normal_0 = _S705;
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
            float _S706 = inc_0.x;
            if(_S706 > ((&st_2)->damage_0))
            {
                Contact_0 _S707 = contact_part_0(mat_7, b_27, (&st_2)->crush_1, plastic_4, d_lin_2, d_ang_2);
                float _S708 = max(_S707.energy_2 - (1.0f - (&st_2)->crush_1) * psi_c_0, 0.0f);
                float _S709 = max(inc_0.y - _S708 * (_S706 - (&st_2)->damage_0), 0.0f);
                float _S710 = max((psi_ts_0 - _S708) * (_S706 - (&st_2)->damage_0) - _S709, 0.0f);
                (&st_2)->damage_0 = _S706;
                (&st_2)->mode_0 = mode_ts_0;
                dissipated_3 = _S709;
                overshoot_1 = _S710;
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
        float _S711 = state_7->damage_0;
        if((state_7->damage_0) > 0.0f)
        {
            Contact_0 _S712 = contact_part_0(mat_7, b_27, state_7->crush_1, float3(state_7->plastic_x_0, state_7->plastic_y_0, state_7->plastic_t_0), d_lin_2, d_ang_2);
            qc_lin_0 = qe_ang_0 * float3((1.0f - _S711))  + _S712.q_ang_1 * float3(_S711) ;
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S713 = stress_measures_0(b_27, float3(0.0f, 0.0f, min(qe_lin_0.z, 0.0f)), qc_lin_0);
        thread Measures_0 _S714 = _S713;
        float4 _S715 = failure_indices_0(mat_7, b_27, &_S714, multiplier_1);
        float _S716 = _S715.z;
        float _S717 = _S715.w;
        bool _S718 = _S716 >= _S717;
        if(_S718)
        {
            psi_contact_0 = _S716;
        }
        else
        {
            psi_contact_0 = _S717;
        }
        if(_S718)
        {
            mode_c_0 = 3U;
        }
        else
        {
            mode_c_0 = 4U;
        }
        if(psi_contact_0 > ((&st_2)->kappa_c_0))
        {
            _S703 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S703 = false;
        }
        if(_S703)
        {
            _S703 = psi_c_0 > 0.0f;
        }
        else
        {
            _S703 = false;
        }
        if(_S703)
        {
            if(softening_0)
            {
                float _S719 = (metal::fast::divide((mat_7->energy_1.w * (float4(b_27->geom0_0) ).x * psi_contact_0 * psi_contact_0), (psi_c_0)));
                intact_normal_0 = _S719;
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
            float _S720 = inc_1.x;
            if(_S720 > ((&st_2)->crush_1))
            {
                float _S721 = inc_1.y;
                float dissipated_4 = dissipated_3 + _S721;
                float overshoot_2 = overshoot_1 + max(psi_c_0 * (_S720 - (&st_2)->crush_1) - _S721, 0.0f);
                (&st_2)->crush_1 = _S720;
                (&st_2)->mode_0 = mode_c_0;
                if(_S720 >= 1.0f)
                {
                    _S703 = ((&st_2)->damage_0) < 1.0f;
                }
                else
                {
                    _S703 = false;
                }
                if(_S703)
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
    float3 _S722 = float3(0.0f) ;
    float3 qc_ang_0;
    if(((&st_2)->damage_0) == 0.0f)
    {
        if((flags_1 & 8U) == 0U)
        {
            float3 _S723 = contact_offsets_0(mat_7, b_27, (&st_2)->crush_1, plastic_4, d_lin_2, d_ang_2);
            (&st_2)->plastic_x_0 = _S723.x;
            (&st_2)->plastic_y_0 = _S723.y;
            (&st_2)->plastic_t_0 = _S723.z;
        }
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S722;
        qc_ang_0 = _S722;
        psi_contact_0 = 0.0f;
    }
    else
    {
        Contact_0 _S724 = contact_part_0(mat_7, b_27, (&st_2)->crush_1, plastic_4, d_lin_2, d_ang_2);
        (&st_2)->plastic_x_0 = _S724.plastic_1.x;
        (&st_2)->plastic_y_0 = _S724.plastic_1.y;
        (&st_2)->plastic_t_0 = _S724.plastic_1.z;
        diss_contact_0 = _S724.diss_4;
        qc_lin_0 = _S724.q_lin_1;
        qc_ang_0 = _S724.q_ang_1;
        psi_contact_0 = _S724.energy_2;
    }
    float dissipated_6 = dissipated_3 + dmg_0 * diss_contact_0;
    if(_S702)
    {
        intact_normal_0 = kn_3 * _S701;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_2)->crush_1) * kn_3 * _S701;
    }
    float _S725 = 1.0f - dmg_0;
    float3 force_lin_2 = float3(_S725 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S725 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S725 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3 force_ang_2 = qe_ang_0 * float3(_S725)  + qc_ang_0 * float3(dmg_0) ;
    float stored_6 = _S725 * (psi_ts_0 + (1.0f - (&st_2)->crush_1) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S703 = ((&st_2)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S703 = false;
    }
    float stored_7;
    float3 force_lin_3;
    if(_S703)
    {
        float4 _S726 = float4(b_27->rebar0_0) ;
        float k_axial_0 = _S726.x;
        float k_dowel_0 = _S726.y;
        float yield_force_0 = _S726.z;
        float dowel_capacity_0 = _S726.w;
        float2 nr_0 = return_map_0(k_axial_0, _S701, (&st_2)->rebar_plastic_0, yield_force_0);
        float2 v1_0 = return_map_0(k_dowel_0, _S698, (&st_2)->rebar_slip0_0, dowel_capacity_0);
        float2 v2_0 = return_map_0(k_dowel_0, _S699, (&st_2)->rebar_slip1_0, dowel_capacity_0);
        float _S727 = nr_0.y;
        float _S728 = v1_0.y;
        float _S729 = v2_0.y;
        float work_0 = yield_force_0 * abs(_S727) + dowel_capacity_0 * (abs(_S728) + abs(_S729));
        (&st_2)->rebar_plastic_0 = (&st_2)->rebar_plastic_0 + _S727;
        (&st_2)->rebar_slip0_0 = (&st_2)->rebar_slip0_0 + _S728;
        (&st_2)->rebar_slip1_0 = (&st_2)->rebar_slip1_0 + _S729;
        (&st_2)->rebar_work_0 = (&st_2)->rebar_work_0 + work_0;
        float dissipated_7 = dissipated_6 + work_0;
        float _S730 = nr_0.x;
        float _S731 = (metal::fast::divide((sq_0(_S730)), (k_axial_0)));
        float _S732 = v1_0.x;
        float _S733 = v2_0.x;
        float _S734 = (metal::fast::divide((sq_0(_S732) + sq_0(_S733)), (k_dowel_0)));
        float elastic_0 = 0.5f * (_S731 + _S734);
        if(fracture_1)
        {
            _S703 = ((&st_2)->rebar_work_0) >= ((float4(b_27->rebar1_0) ).x);
        }
        else
        {
            _S703 = false;
        }
        if(_S703)
        {
            (&st_2)->rebar_broken_0 = 1.0f;
            float dissipated_8 = dissipated_7 + elastic_0;
            force_lin_3 = force_lin_2;
            dissipated_3 = dissipated_8;
            stored_7 = stored_6;
        }
        else
        {
            float stored_8 = stored_6 + elastic_0;
            force_lin_3 = force_lin_2 + float3(_S732, _S733, _S730);
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
        _S703 = _S688;
    }
    else
    {
        _S703 = false;
    }
    if(_S703)
    {
        _S703 = (flags_1 & 64U) != 0U;
    }
    else
    {
        _S703 = false;
    }
    if(_S703)
    {
        Measures_0 _S735 = stress_measures_0(b_27, force_lin_3, force_ang_2);
        thread Measures_0 _S736 = _S735;
        float4 _S737 = failure_indices_0(mat_7, b_27, &_S736, weibull_0);
        float _S738 = life_rate_0(mat_7, max(max(_S737.x, _S737.y), _S737.z));
        (&st_2)->life_0 = max((&st_2)->life_0 - _S738 * dt_9, 0.0f);
    }
    (&st_2)->dissipated_0 = (&st_2)->dissipated_0 + dissipated_3;
    thread JointResponse_0 resp_0;
    (&resp_0)->force_lin_1 = force_lin_3;
    (&resp_0)->force_ang_1 = force_ang_2;
    (&resp_0)->state_6 = st_2;
    (&resp_0)->dissipated_2 = dissipated_3;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_5 = stored_7;
    if(_S685)
    {
        thread JointState_0 _S739 = st_2;
        bool _S740 = connected_0(&_S739, has_rebar_1);
        _S703 = !_S740;
    }
    else
    {
        _S703 = false;
    }
    (&resp_0)->disconnected_0 = _S703;
    (&resp_0)->fatigue_before_0 = _S693;
    (&resp_0)->measures_0 = _S686;
    return resp_0;
}

void secant_factors_0(const JointBond_natural_0 thread* b_28, const JointState_0 thread* st_3, float3 d_lin_3, float3 thread* f_lin_0, float3 thread* f_ang_0)
{
    float _S741 = st_3->damage_0;
    bool compressed_0 = (d_lin_3.z) < 0.0f;
    float contact_3;
    if(compressed_0)
    {
        contact_3 = _S741;
    }
    else
    {
        contact_3 = 0.0f;
    }
    float _S742 = 1.0f - _S741;
    float _S743 = max(_S742 + contact_3, 9.99999997475242708e-07f);
    float normal_5;
    if(compressed_0)
    {
        normal_5 = max(1.0f - st_3->crush_1, 9.99999997475242708e-07f);
    }
    else
    {
        normal_5 = max(_S742, 9.99999997475242708e-07f);
    }
    *f_lin_0 = float3(_S743, _S743, normal_5);
    *f_ang_0 = float3(_S743) ;
    bool _S744;
    if(((float4(b_28->stiff1_0) ).w) != 0.0f)
    {
        _S744 = (st_3->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S744 = false;
    }
    if(_S744)
    {
        float4 _S745 = float4(b_28->rebar0_0) ;
        float4 _S746 = float4(b_28->stiff0_0) ;
        float _S747 = (metal::fast::divide((_S745.x), (_S746.x)));
        (*f_lin_0).z = (*f_lin_0).z + _S747;
        float _S748 = _S745.y;
        float _S749 = _S746.y;
        float _S750 = (metal::fast::divide((_S748), (_S749)));
        (*f_lin_0).x = (*f_lin_0).x + _S750;
        float _S751 = (metal::fast::divide((_S748), (_S749)));
        (*f_lin_0).y = (*f_lin_0).y + _S751;
    }
    return;
}

float3 to_local_0(uint _S752, float3 _S753, KernelContext_0 thread* kernelContext_46)
{
    BondStatic_natural_0 device* _S754 = kernelContext_46->bonds_0+_S752;
    return float3(dot(_S753, (float4(_S754->t1_0) ).xyz), dot(_S753, (float4(_S754->t2_0) ).xyz), dot(_S753, (float4(_S754->normal_0) ).xyz));
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

float3 to_body_0(uint _S755, float3 _S756, KernelContext_0 thread* kernelContext_47)
{
    BondStatic_natural_0 device* _S757 = kernelContext_47->bonds_0+_S755;
    return (float4(_S757->t1_0) ).xyz * float3(_S756.x)  + (float4(_S757->t2_0) ).xyz * float3(_S756.y)  + (float4(_S757->normal_0) ).xyz * float3(_S756.z) ;
}

bool bond_update_0(uint i_9, float dt_10, bool fracture_2, uint abs_step_0, bool wide_0, KernelContext_0 thread* kernelContext_48)
{
    BondStatic_natural_0 device* _S758 = kernelContext_48->bonds_0+i_9;
    uint4 _S759 = uint4(_S758->law_0.ids_0) ;
    float3 ra_1 = (float4(_S758->ra_0) ).xyz;
    float3 rb_1 = (float4(_S758->rb_0) ).xyz;
    uint _S760 = 4U * _S759.y;
    float3 ta_2 = (float4(*(kernelContext_48->state_0+(_S760 + 1U))) ).xyz;
    float3 va_0 = (float4(*(kernelContext_48->state_0+(_S760 + 2U))) ).xyz;
    float3 wa_1 = (float4(*(kernelContext_48->state_0+(_S760 + 3U))) ).xyz;
    uint _S761 = 4U * _S759.z;
    float3 tb_2 = (float4(*(kernelContext_48->state_0+(_S761 + 1U))) ).xyz;
    float3 vb_0 = (float4(*(kernelContext_48->state_0+(_S761 + 2U))) ).xyz;
    float3 wb_1 = (float4(*(kernelContext_48->state_0+(_S761 + 3U))) ).xyz;
    float3 _S762 = to_local_0(i_9, (float4(*(kernelContext_48->state_0+_S761)) ).xyz + cross(tb_2, rb_1) - ((float4(*(kernelContext_48->state_0+_S760)) ).xyz + cross(ta_2, ra_1)), kernelContext_48);
    float3 _S763 = to_local_0(i_9, tb_2 - ta_2, kernelContext_48);
    float3 _S764 = to_local_0(i_9, vb_0 + cross(wb_1, rb_1) - (va_0 + cross(wa_1, ra_1)), kernelContext_48);
    float3 _S765 = to_local_0(i_9, wb_1 - wa_1, kernelContext_48);
    JointState_0 previous_0 = (kernelContext_48->bond_dyn_0+i_9)->js_0;
    thread JointState_0 _S766 = (kernelContext_48->bond_dyn_0+i_9)->js_0;
    bool _S767 = is_damaged_0(&_S766);
    thread JointBond_natural_0 _S768 = (kernelContext_48->bonds_0+i_9)->law_0;
    thread JointState_0 _S769 = (kernelContext_48->bond_dyn_0+i_9)->js_0;
    JointResponse_0 _S770 = joint_evaluate_0(&kernelContext_48->materials_0->m_0[(uint4((kernelContext_48->bonds_0+i_9)->law_0.ids_0) ).x], &_S768, &_S769, _S762, _S763, dt_10, fracture_2);
    BondStatic_natural_0 device* _S771 = kernelContext_48->bonds_0+i_9;
    BondDyn_natural_0 device* _S772 = kernelContext_48->bond_dyn_0+i_9;
    float4 _S773 = float4((*_S772).force_lin_0) ;
    float4 _S774 = float4((*_S772).force_ang_0) ;
    float4 _S775 = float4((*_S772).sums_0) ;
    float4 _S776 = float4((*_S772).comps_0) ;
    uint4 _S777 = uint4((*_S772).events_0) ;
    thread BondDyn_0 bd_0;
    (&bd_0)->js_0 = (*_S772).js_0;
    (&bd_0)->force_lin_0 = _S773;
    (&bd_0)->force_ang_0 = _S774;
    (&bd_0)->sums_0 = _S775;
    (&bd_0)->comps_0 = _S776;
    (&bd_0)->events_0 = _S777;
    float3 ra_2 = (float4(_S771->ra_0) ).xyz;
    float3 rb_2 = (float4(_S771->rb_0) ).xyz;
    thread JointBond_natural_0 _S778 = _S771->law_0;
    thread JointState_0 _S779 = _S770.state_6;
    thread float3 f_lin_1;
    thread float3 f_ang_1;
    secant_factors_0(&_S778, &_S779, _S762, &f_lin_1, &f_ang_1);
    float3 qd_lin_0 = _S764 * (float4(_S771->c_lin_0) ).xyz * f_lin_1;
    float3 qd_ang_0 = _S765 * (float4(_S771->c_ang_0) ).xyz * f_ang_1;
    float3 q_lin_2 = _S770.force_lin_1 + qd_lin_0;
    float3 q_ang_2 = _S770.force_ang_1 + qd_ang_0;
    float damped_0 = (dot(qd_lin_0, _S764) + dot(qd_ang_0, _S765)) * dt_10;
    float3 _S780 = to_body_0(i_9, q_lin_2, kernelContext_48);
    float3 _S781 = to_body_0(i_9, q_ang_2, kernelContext_48);
    uint _S782 = 3U * i_9;
    *(kernelContext_48->scratch_0+_S782) = packed_float4(float4(_S780, max(_S770.measures_0.tension_0, _S770.measures_0.compression_0))) ;
    *(kernelContext_48->scratch_0+(_S782 + 1U)) = packed_float4(float4(_S781 + cross(ra_2, _S780), 0.0f)) ;
    *(kernelContext_48->scratch_0+(_S782 + 2U)) = packed_float4(float4(- _S781 + cross(rb_2, - _S780), 0.0f)) ;
    thread float _S783 = (&bd_0)->sums_0.x;
    thread float _S784 = (&bd_0)->comps_0.x;
    comp_add1_0(&_S783, &_S784, _S770.dissipated_2);
    (&bd_0)->comps_0.x = _S784;
    (&bd_0)->sums_0.x = _S783;
    thread float _S785 = (&bd_0)->sums_0.y;
    thread float _S786 = (&bd_0)->comps_0.y;
    comp_add1_0(&_S785, &_S786, _S770.overshoot_0);
    (&bd_0)->comps_0.y = _S786;
    (&bd_0)->sums_0.y = _S785;
    thread float _S787 = (&bd_0)->sums_0.z;
    thread float _S788 = (&bd_0)->comps_0.z;
    comp_add1_0(&_S787, &_S788, damped_0);
    (&bd_0)->comps_0.z = _S788;
    (&bd_0)->sums_0.z = _S787;
    (&bd_0)->force_lin_0 = float4(q_lin_2, _S770.stored_5);
    (&bd_0)->force_ang_0 = float4(q_ang_2, max((&bd_0)->force_ang_0.w, _S770.state_6.utilization_0));
    bool _S789;
    if(!_S767)
    {
        thread JointState_0 _S790 = _S770.state_6;
        bool _S791 = is_damaged_0(&_S790);
        _S789 = _S791;
    }
    else
    {
        _S789 = false;
    }
    if(_S789)
    {
        _S789 = ((&bd_0)->events_0.x) == 0U;
    }
    else
    {
        _S789 = false;
    }
    if(_S789)
    {
        (&bd_0)->events_0.x = abs_step_0;
        (&bd_0)->events_0.w = _S770.state_6.mode_0;
        if(wide_0)
        {
            cov_or_0((uint4((&_S778)->ids_0) ).w, 32U, kernelContext_48);
        }
        else
        {
            (*kernelContext_48->g_seen_0)[3U] = 1U;
        }
    }
    if(((&bd_0)->events_0.y) == 0U)
    {
        _S789 = (_S770.state_6.life_0) != (previous_0.life_0);
    }
    else
    {
        _S789 = false;
    }
    if(_S789)
    {
        _S789 = (_S770.fatigue_before_0) > 0.99000000953674316f;
    }
    else
    {
        _S789 = false;
    }
    if(_S789)
    {
        float _S792 = fatigue_factor_0(&kernelContext_48->materials_0->m_0[(uint4((kernelContext_48->bonds_0+i_9)->law_0.ids_0) ).x], _S770.state_6.life_0);
        _S789 = _S792 <= 0.99000000953674316f;
    }
    else
    {
        _S789 = false;
    }
    if(_S789)
    {
        (&bd_0)->events_0.y = abs_step_0;
        if(wide_0)
        {
            cov_or_0((uint4((&_S778)->ids_0) ).w, 64U, kernelContext_48);
        }
        else
        {
            (*kernelContext_48->g_seen_0)[4U] = 1U;
        }
    }
    if(_S770.disconnected_0)
    {
        (&bd_0)->events_0.z = abs_step_0;
    }
    (&bd_0)->js_0 = _S770.state_6;
    BondDyn_natural_0 device* _S793 = kernelContext_48->bond_dyn_0+i_9;
    _S793->js_0 = bd_0.js_0;
    _S793->force_lin_0 = packed_float4(bd_0.force_lin_0) ;
    _S793->force_ang_0 = packed_float4(bd_0.force_ang_0) ;
    _S793->sums_0 = packed_float4(bd_0.sums_0) ;
    _S793->comps_0 = packed_float4(bd_0.comps_0) ;
    _S793->events_0 = packed_uint4(bd_0.events_0) ;
    return _S770.disconnected_0;
}

void chunk_update_0(uint c_15, const Island_natural_0 thread* isl_8, const Rigid_0 thread* rg_6, float dt_11, bool rml_0, uint step_0, bool contact_4, float thread* work_1, float thread* work_err_0, KernelContext_0 thread* kernelContext_49)
{
    ChunkStatic_natural_0 device* _S794 = kernelContext_49->chunks_0+c_15;
    float3 _S795 = float3(0.0f) ;
    uint _S796 = kernelContext_49->index_0[c_15];
    float peak_0 = 0.0f;
    uint e_3 = _S796;
    float3 fi_0 = _S795;
    float3 mi_0 = _S795;
    for(;;)
    {
        if(e_3 < (kernelContext_49->index_0)[c_15 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_2 = kernelContext_49->index_0[e_3];
        uint _S797 = 3U * (entry_2 >> 1U);
        float4 _S798 = float4(*(kernelContext_49->scratch_0+_S797)) ;
        if((entry_2 & 1U) == 0U)
        {
            float3 mi_1 = mi_0 + (float4(*(kernelContext_49->scratch_0+(_S797 + 1U))) ).xyz;
            fi_0 = fi_0 + _S798.xyz;
            mi_0 = mi_1;
        }
        else
        {
            float3 mi_2 = mi_0 + (float4(*(kernelContext_49->scratch_0+(_S797 + 2U))) ).xyz;
            fi_0 = fi_0 + - _S798.xyz;
            mi_0 = mi_2;
        }
        float _S799 = max(peak_0, _S798.w);
        uint _S800 = e_3 + 1U;
        peak_0 = _S799;
        e_3 = _S800;
    }
    uint _S801 = 4U * c_15;
    float3 u_0 = (float4(*(kernelContext_49->state_0+_S801)) ).xyz;
    uint _S802 = _S801 + 1U;
    float3 th_2 = (float4(*(kernelContext_49->state_0+_S802)) ).xyz;
    uint _S803 = _S801 + 2U;
    float3 v_9 = (float4(*(kernelContext_49->state_0+_S803)) ).xyz;
    uint _S804 = _S801 + 3U;
    float3 w_5 = (float4(*(kernelContext_49->state_0+_S804)) ).xyz;
    float4 _S805 = float4(_S794->center_0) ;
    float mass_0 = _S805.w;
    float3 _S806 = _S805.xyz;
    float3 _S807 = (float4(isl_8->com_0) ).xyz;
    float3 _S808 = rotate_0(&rg_6->rot_0, _S806 + u_0 - _S807);
    thread float3 f_load_0;
    thread float3 t_load_0;
    thread float3 rep_f_2;
    thread float3 rep_m_2;
    chunk_loads_0(c_15, c_15, &rg_6->rot_0, step_0, dt_11, contact_4, dt_11, &f_load_0, &t_load_0, &rep_f_2, &rep_m_2, kernelContext_49);
    record_chunk_load_0(c_15, f_load_0, t_load_0, kernelContext_49);
    float3 _S809 = float3(mass_0) ;
    float3 f_world_0 = f_load_0 + kernelContext_49->params_0->gravity_0.xyz * _S809;
    float3 t_world_0 = t_load_0;
    float3 f_world_1;
    float3 t_world_1;
    if(rml_0)
    {
        float3 f_world_2 = f_world_0 - (rg_6->a_7 + cross(rg_6->alpha_0, _S808) + cross(rg_6->w_4, cross(rg_6->w_4, _S808))) * _S809;
        float4 _S810 = float4(_S794->inertia0_1) ;
        float4 _S811 = float4(_S794->inertia1_1) ;
        float4 _S812 = float4(_S794->inertia2_1) ;
        float3 _S813 = world_mul_0(&rg_6->rot_0, _S810, _S811, _S812, rg_6->alpha_0);
        float3 _S814 = world_mul_0(&rg_6->rot_0, _S810, _S811, _S812, rg_6->w_4);
        float3 t_world_2 = t_world_0 - (_S813 + cross(rg_6->w_4, _S814));
        f_world_1 = f_world_2;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    float3 _S815 = inverse_rotate_0(&rg_6->rot_0, f_world_1);
    float3 _S816 = inverse_rotate_0(&rg_6->rot_0, t_world_1);
    float3 f_ext_0;
    float3 m_ext_0;
    if(rml_0)
    {
        float3 _S817 = inverse_rotate_0(&rg_6->rot_0, rg_6->w_4);
        float4 _S818 = float4(_S794->inertia0_1) ;
        float4 _S819 = float4(_S794->inertia1_1) ;
        float4 _S820 = float4(_S794->inertia2_1) ;
        float3 i_w_0 = rows_mul_0(_S818, _S819, _S820, w_5);
        float3 m_ext_1 = _S816 - (cross(_S817, i_w_0) + cross(w_5, rows_mul_0(_S818, _S819, _S820, _S817)) + cross(w_5, i_w_0));
        f_ext_0 = _S815 - cross(_S817, v_9) * float3((2.0f * mass_0)) ;
        m_ext_0 = m_ext_1;
    }
    else
    {
        f_ext_0 = _S815;
        m_ext_0 = _S816;
    }
    float3 f_12 = f_ext_0 + rep_f_2 + fi_0;
    float3 m_5 = m_ext_0 + rep_m_2 + mi_0;
    uint support_0 = (uint4(_S794->info_1) ).x;
    float3 _S821 = float3((float4(*(kernelContext_49->state_0+_S802)) ).w, (float4(*(kernelContext_49->state_0+_S803)) ).w, (float4(*(kernelContext_49->state_0+_S804)) ).w);
    float3 reaction_0;
    float3 u_1;
    float3 th_3;
    float3 v_10;
    float3 w_6;
    if(support_0 == 1U)
    {
        reaction_0 = - f_12;
        u_1 = u_0;
        th_3 = th_2;
        v_10 = _S795;
        w_6 = _S795;
    }
    else
    {
        float4 _S822 = float4(_S794->scale_0) ;
        float3 w_7 = w_5 + rows_mul_0(float4(_S794->inv0_1) , float4(_S794->inv1_1) , float4(_S794->inv2_1) , m_5) * float3((dt_11 * _S822.z)) ;
        float3 _S823 = float3(dt_11) ;
        float3 th_4 = th_2 + w_7 * _S823;
        if(support_0 == 2U)
        {
            reaction_0 = - f_12;
            u_1 = u_0;
            th_3 = _S795;
        }
        else
        {
            float3 v_11 = v_9 + f_12 * float3((dt_11 * _S822.y)) ;
            float3 u_2 = u_0 + v_11 * _S823;
            reaction_0 = _S821;
            u_1 = u_2;
            th_3 = v_11;
        }
        float3 _S824 = th_3;
        th_3 = th_4;
        v_10 = _S824;
        w_6 = w_7;
    }
    *(kernelContext_49->state_0+_S801) = packed_float4(float4(u_1, peak_0)) ;
    *(kernelContext_49->state_0+_S802) = packed_float4(float4(th_3, reaction_0.x)) ;
    *(kernelContext_49->state_0+_S803) = packed_float4(float4(v_10, reaction_0.y)) ;
    *(kernelContext_49->state_0+_S804) = packed_float4(float4(w_6, reaction_0.z)) ;
    float3 _S825 = rotate_0(&rg_6->rot_0, _S806 + u_1 - _S807);
    float3 _S826 = rg_6->vel_1 + rg_6->vel_err_1 + cross(rg_6->w_4, _S825);
    float3 _S827 = rotate_0(&rg_6->rot_0, v_10);
    float3 v_world_0 = _S826 + _S827;
    float3 _S828 = rotate_0(&rg_6->rot_0, w_6);
    comp_add1_0(work_1, work_err_0, (dot(f_load_0, v_world_0) + dot(t_load_0, rg_6->w_4 + _S828)) * dt_11);
    return;
}

void chunk_update_1(uint c_16, const Island_0 thread* isl_9, const Rigid_0 thread* rg_7, float dt_12, bool rml_1, uint step_1, bool contact_5, float thread* work_2, float thread* work_err_1, KernelContext_0 thread* kernelContext_50)
{
    ChunkStatic_natural_0 device* _S829 = kernelContext_50->chunks_0+c_16;
    float3 _S830 = float3(0.0f) ;
    uint _S831 = kernelContext_50->index_0[c_16];
    float peak_1 = 0.0f;
    uint e_4 = _S831;
    float3 fi_1 = _S830;
    float3 mi_3 = _S830;
    for(;;)
    {
        if(e_4 < (kernelContext_50->index_0)[c_16 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_3 = kernelContext_50->index_0[e_4];
        uint _S832 = 3U * (entry_3 >> 1U);
        float4 _S833 = float4(*(kernelContext_50->scratch_0+_S832)) ;
        if((entry_3 & 1U) == 0U)
        {
            float3 mi_4 = mi_3 + (float4(*(kernelContext_50->scratch_0+(_S832 + 1U))) ).xyz;
            fi_1 = fi_1 + _S833.xyz;
            mi_3 = mi_4;
        }
        else
        {
            float3 mi_5 = mi_3 + (float4(*(kernelContext_50->scratch_0+(_S832 + 2U))) ).xyz;
            fi_1 = fi_1 + - _S833.xyz;
            mi_3 = mi_5;
        }
        float _S834 = max(peak_1, _S833.w);
        uint _S835 = e_4 + 1U;
        peak_1 = _S834;
        e_4 = _S835;
    }
    uint _S836 = 4U * c_16;
    float3 u_3 = (float4(*(kernelContext_50->state_0+_S836)) ).xyz;
    uint _S837 = _S836 + 1U;
    float3 th_5 = (float4(*(kernelContext_50->state_0+_S837)) ).xyz;
    uint _S838 = _S836 + 2U;
    float3 v_12 = (float4(*(kernelContext_50->state_0+_S838)) ).xyz;
    uint _S839 = _S836 + 3U;
    float3 w_8 = (float4(*(kernelContext_50->state_0+_S839)) ).xyz;
    float4 _S840 = float4(_S829->center_0) ;
    float mass_1 = _S840.w;
    float3 _S841 = _S840.xyz;
    float3 _S842 = isl_9->com_0.xyz;
    float3 _S843 = rotate_0(&rg_7->rot_0, _S841 + u_3 - _S842);
    thread float3 f_load_1;
    thread float3 t_load_1;
    thread float3 rep_f_3;
    thread float3 rep_m_3;
    chunk_loads_0(c_16, c_16, &rg_7->rot_0, step_1, dt_12, contact_5, dt_12, &f_load_1, &t_load_1, &rep_f_3, &rep_m_3, kernelContext_50);
    record_chunk_load_0(c_16, f_load_1, t_load_1, kernelContext_50);
    float3 _S844 = float3(mass_1) ;
    float3 f_world_3 = f_load_1 + kernelContext_50->params_0->gravity_0.xyz * _S844;
    float3 t_world_3 = t_load_1;
    float3 f_world_4;
    float3 t_world_4;
    if(rml_1)
    {
        float3 f_world_5 = f_world_3 - (rg_7->a_7 + cross(rg_7->alpha_0, _S843) + cross(rg_7->w_4, cross(rg_7->w_4, _S843))) * _S844;
        float4 _S845 = float4(_S829->inertia0_1) ;
        float4 _S846 = float4(_S829->inertia1_1) ;
        float4 _S847 = float4(_S829->inertia2_1) ;
        float3 _S848 = world_mul_0(&rg_7->rot_0, _S845, _S846, _S847, rg_7->alpha_0);
        float3 _S849 = world_mul_0(&rg_7->rot_0, _S845, _S846, _S847, rg_7->w_4);
        float3 t_world_5 = t_world_3 - (_S848 + cross(rg_7->w_4, _S849));
        f_world_4 = f_world_5;
        t_world_4 = t_world_5;
    }
    else
    {
        f_world_4 = f_world_3;
        t_world_4 = t_world_3;
    }
    float3 _S850 = inverse_rotate_0(&rg_7->rot_0, f_world_4);
    float3 _S851 = inverse_rotate_0(&rg_7->rot_0, t_world_4);
    float3 f_ext_1;
    float3 m_ext_2;
    if(rml_1)
    {
        float3 _S852 = inverse_rotate_0(&rg_7->rot_0, rg_7->w_4);
        float4 _S853 = float4(_S829->inertia0_1) ;
        float4 _S854 = float4(_S829->inertia1_1) ;
        float4 _S855 = float4(_S829->inertia2_1) ;
        float3 i_w_1 = rows_mul_0(_S853, _S854, _S855, w_8);
        float3 m_ext_3 = _S851 - (cross(_S852, i_w_1) + cross(w_8, rows_mul_0(_S853, _S854, _S855, _S852)) + cross(w_8, i_w_1));
        f_ext_1 = _S850 - cross(_S852, v_12) * float3((2.0f * mass_1)) ;
        m_ext_2 = m_ext_3;
    }
    else
    {
        f_ext_1 = _S850;
        m_ext_2 = _S851;
    }
    float3 f_13 = f_ext_1 + rep_f_3 + fi_1;
    float3 m_6 = m_ext_2 + rep_m_3 + mi_3;
    uint support_1 = (uint4(_S829->info_1) ).x;
    float3 _S856 = float3((float4(*(kernelContext_50->state_0+_S837)) ).w, (float4(*(kernelContext_50->state_0+_S838)) ).w, (float4(*(kernelContext_50->state_0+_S839)) ).w);
    float3 reaction_1;
    float3 u_4;
    float3 th_6;
    float3 v_13;
    float3 w_9;
    if(support_1 == 1U)
    {
        reaction_1 = - f_13;
        u_4 = u_3;
        th_6 = th_5;
        v_13 = _S830;
        w_9 = _S830;
    }
    else
    {
        float4 _S857 = float4(_S829->scale_0) ;
        float3 w_10 = w_8 + rows_mul_0(float4(_S829->inv0_1) , float4(_S829->inv1_1) , float4(_S829->inv2_1) , m_6) * float3((dt_12 * _S857.z)) ;
        float3 _S858 = float3(dt_12) ;
        float3 th_7 = th_5 + w_10 * _S858;
        if(support_1 == 2U)
        {
            reaction_1 = - f_13;
            u_4 = u_3;
            th_6 = _S830;
        }
        else
        {
            float3 v_14 = v_12 + f_13 * float3((dt_12 * _S857.y)) ;
            float3 u_5 = u_3 + v_14 * _S858;
            reaction_1 = _S856;
            u_4 = u_5;
            th_6 = v_14;
        }
        float3 _S859 = th_6;
        th_6 = th_7;
        v_13 = _S859;
        w_9 = w_10;
    }
    *(kernelContext_50->state_0+_S836) = packed_float4(float4(u_4, peak_1)) ;
    *(kernelContext_50->state_0+_S837) = packed_float4(float4(th_6, reaction_1.x)) ;
    *(kernelContext_50->state_0+_S838) = packed_float4(float4(v_13, reaction_1.y)) ;
    *(kernelContext_50->state_0+_S839) = packed_float4(float4(w_9, reaction_1.z)) ;
    float3 _S860 = rotate_0(&rg_7->rot_0, _S841 + u_4 - _S842);
    float3 _S861 = rg_7->vel_1 + rg_7->vel_err_1 + cross(rg_7->w_4, _S860);
    float3 _S862 = rotate_0(&rg_7->rot_0, v_13);
    float3 v_world_1 = _S861 + _S862;
    float3 _S863 = rotate_0(&rg_7->rot_0, w_9);
    comp_add1_0(work_2, work_err_1, (dot(f_load_1, v_world_1) + dot(t_load_1, rg_7->w_4 + _S863)) * dt_12);
    return;
}

float3 turn_difference_0(float3 omega_1, float dt_13, float3 v_15)
{
    float _S864 = length(omega_1);
    float angle_3 = _S864 * dt_13;
    if(angle_3 < 1.00000000317107685e-30f)
    {
        return float3(0.0f) ;
    }
    float3 a_11 = omega_1 / float3(_S864) ;
    float s_6 = sin(0.5f * angle_3);
    float3 av_0 = cross(a_11, v_15);
    return av_0 * float3(sin(angle_3))  + cross(a_11, av_0) * float3((2.0f * s_6 * s_6)) ;
}

void integrate_rigid_0(const Island_natural_0 thread* isl_10, Rigid_0 thread* rg_8, float dt_14)
{
    float3 _S865 = float3(dt_14) ;
    comp_add_0(&rg_8->l_2, &rg_8->l_err_1, rg_8->torque_0 * _S865);
    float3 l_3 = rg_8->l_2 + rg_8->l_err_1;
    comp_add_0(&rg_8->vel_1, &rg_8->vel_err_1, rg_8->a_7 * _S865);
    float3 vel_2 = rg_8->vel_1 + rg_8->vel_err_1;
    float4 _S866 = float4(isl_10->inv0_0) ;
    float4 _S867 = float4(isl_10->inv1_0) ;
    float4 _S868 = float4(isl_10->inv2_0) ;
    thread Quat_0 _S869 = rg_8->rot_0;
    float3 _S870 = world_mul_0(&_S869, _S866, _S867, _S868, l_3);
    float3 _S871 = vel_2 * _S865;
    float3 _S872 = (float4(isl_10->com_0) ).xyz;
    thread Quat_0 _S873 = rg_8->rot_0;
    float3 _S874 = rotate_0(&_S873, _S872);
    comp_add_0(&rg_8->pos_1, &rg_8->pos_err_1, _S871 - turn_difference_0(_S870, dt_14, _S874));
    turn_left_0(&rg_8->rot_0, &rg_8->rot_err_0, _S870, dt_14);
    thread Quat_0 _S875 = rg_8->rot_0;
    float3 _S876 = world_mul_0(&_S875, _S866, _S867, _S868, l_3);
    rg_8->w_4 = _S876;
    return;
}

void integrate_rigid_1(const Island_0 thread* isl_11, Rigid_0 thread* rg_9, float dt_15)
{
    float3 _S877 = float3(dt_15) ;
    comp_add_0(&rg_9->l_2, &rg_9->l_err_1, rg_9->torque_0 * _S877);
    float3 l_4 = rg_9->l_2 + rg_9->l_err_1;
    comp_add_0(&rg_9->vel_1, &rg_9->vel_err_1, rg_9->a_7 * _S877);
    float3 vel_3 = rg_9->vel_1 + rg_9->vel_err_1;
    float4 _S878 = isl_11->inv0_0;
    float4 _S879 = isl_11->inv1_0;
    float4 _S880 = isl_11->inv2_0;
    thread Quat_0 _S881 = rg_9->rot_0;
    float3 _S882 = world_mul_0(&_S881, isl_11->inv0_0, isl_11->inv1_0, isl_11->inv2_0, l_4);
    float3 _S883 = vel_3 * _S877;
    float3 _S884 = isl_11->com_0.xyz;
    thread Quat_0 _S885 = rg_9->rot_0;
    float3 _S886 = rotate_0(&_S885, _S884);
    comp_add_0(&rg_9->pos_1, &rg_9->pos_err_1, _S883 - turn_difference_0(_S882, dt_15, _S886));
    turn_left_0(&rg_9->rot_0, &rg_9->rot_err_0, _S882, dt_15);
    thread Quat_0 _S887 = rg_9->rot_0;
    float3 _S888 = world_mul_0(&_S887, _S878, _S879, _S880, l_4);
    rg_9->w_4 = _S888;
    return;
}

void drift_moments_0(uint c_17, float3 thread* tu_0, float3 thread* pv_0, KernelContext_0 thread* kernelContext_51)
{
    ChunkStatic_natural_0 device* _S889 = kernelContext_51->chunks_0+c_17;
    uint _S890 = 4U * c_17;
    float3 _S891 = float3(((float4(_S889->center_0) ).w * (float4(_S889->scale_0) ).x)) ;
    *tu_0 = *tu_0 + (float4(*(kernelContext_51->state_0+_S890)) ).xyz * _S891;
    *pv_0 = *pv_0 + (float4(*(kernelContext_51->state_0+(_S890 + 2U))) ).xyz * _S891;
    return;
}

void drift_angular_0(uint c_18, float3 wcom_1, float3 tr_0, float3 dv_0, float3 thread* lu_0, float3 thread* lv_0, KernelContext_0 thread* kernelContext_52)
{
    ChunkStatic_natural_0 device* _S892 = kernelContext_52->chunks_0+c_18;
    float4 _S893 = float4(_S892->center_0) ;
    float3 r_10 = _S893.xyz - wcom_1;
    uint _S894 = 4U * c_18;
    float3 _S895 = float3(_S893.w) ;
    float4 _S896 = float4(_S892->inertia0_1) ;
    float4 _S897 = float4(_S892->inertia1_1) ;
    float4 _S898 = float4(_S892->inertia2_1) ;
    float3 _S899 = float3((float4(_S892->scale_0) ).x) ;
    *lu_0 = *lu_0 + (cross(r_10, (float4(*(kernelContext_52->state_0+_S894)) ).xyz - tr_0) * _S895 + rows_mul_0(_S896, _S897, _S898, (float4(*(kernelContext_52->state_0+(_S894 + 1U))) ).xyz)) * _S899;
    *lv_0 = *lv_0 + (cross(r_10, (float4(*(kernelContext_52->state_0+(_S894 + 2U))) ).xyz - dv_0) * _S895 + rows_mul_0(_S896, _S897, _S898, (float4(*(kernelContext_52->state_0+(_S894 + 3U))) ).xyz)) * _S899;
    return;
}

void drift_apply_0(uint c_19, float3 wcom_2, float3 tr_1, float3 phi_0, float3 dv_1, float3 dw_0, KernelContext_0 thread* kernelContext_53)
{
    float3 r_11 = (float4((kernelContext_53->chunks_0+c_19)->center_0) ).xyz - wcom_2;
    uint _S900 = 4U * c_19;
    *(kernelContext_53->state_0+_S900) = packed_float4(float4((float4(*(kernelContext_53->state_0+_S900)) ).xyz - (tr_1 + cross(phi_0, r_11)), (float4(*(kernelContext_53->state_0+_S900)) ).w)) ;
    uint _S901 = _S900 + 1U;
    *(kernelContext_53->state_0+_S901) = packed_float4(float4((float4(*(kernelContext_53->state_0+_S901)) ).xyz - phi_0, (float4(*(kernelContext_53->state_0+_S901)) ).w)) ;
    uint _S902 = _S900 + 2U;
    *(kernelContext_53->state_0+_S902) = packed_float4(float4((float4(*(kernelContext_53->state_0+_S902)) ).xyz - (dv_1 + cross(dw_0, r_11)), (float4(*(kernelContext_53->state_0+_S902)) ).w)) ;
    uint _S903 = _S900 + 3U;
    *(kernelContext_53->state_0+_S903) = packed_float4(float4((float4(*(kernelContext_53->state_0+_S903)) ).xyz - dw_0, (float4(*(kernelContext_53->state_0+_S903)) ).w)) ;
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
    thread Quat_0 _S904 = *hi_3;
    thread Quat_0 _S905 = dq_1;
    Quat_0 _S906 = quat_mul_0(&_S904, &_S905);
    thread Quat_0 _S907 = _S906;
    float4 _S908 = quat_vec_0(&_S907);
    quat_accumulate_0(hi_3, lo_3, _S908);
    return;
}

void drift_rigid_0(const Island_natural_0 thread* isl_12, Rigid_0 thread* rg_10, float3 tr_2, float3 phi_2, float3 dv_2, float3 dw_1)
{
    float3 wcom_3 = (float4(isl_12->wcom_0) ).xyz;
    Quat_0 rot_2 = rg_10->rot_0;
    float3 _S909 = tr_2 - cross(phi_2, wcom_3);
    thread Quat_0 _S910 = rg_10->rot_0;
    float3 _S911 = rotate_0(&_S910, _S909);
    comp_add_0(&rg_10->pos_1, &rg_10->pos_err_1, _S911);
    thread Quat_0 _S912 = rg_10->rot_0;
    float3 _S913 = inverse_rotate_0(&_S912, rg_10->w_4);
    float4 _S914 = float4(isl_12->inertia0_0) ;
    float4 _S915 = float4(isl_12->inertia1_0) ;
    float4 _S916 = float4(isl_12->inertia2_0) ;
    float3 _S917 = cross(phi_2, rows_mul_0(_S914, _S915, _S916, _S913)) - rows_mul_0(_S914, _S915, _S916, cross(phi_2, _S913));
    thread Quat_0 _S918 = rg_10->rot_0;
    float3 _S919 = rotate_0(&_S918, _S917);
    turn_right_0(&rg_10->rot_0, &rg_10->rot_err_0, phi_2);
    float3 _S920 = dv_2 + cross(dw_1, (float4(isl_12->com_0) ).xyz - wcom_3);
    thread Quat_0 _S921 = rot_2;
    float3 _S922 = rotate_0(&_S921, _S920);
    comp_add_0(&rg_10->vel_1, &rg_10->vel_err_1, _S922);
    thread Quat_0 _S923 = rot_2;
    float3 _S924 = rotate_0(&_S923, dw_1);
    rg_10->w_4 = rg_10->w_4 + _S924;
    thread Quat_0 _S925 = rg_10->rot_0;
    float3 _S926 = world_mul_0(&_S925, _S914, _S915, _S916, _S924);
    comp_add_0(&rg_10->l_2, &rg_10->l_err_1, _S919 + _S926);
    return;
}

void drift_rigid_1(const Island_0 thread* isl_13, Rigid_0 thread* rg_11, float3 tr_3, float3 phi_3, float3 dv_3, float3 dw_2)
{
    float3 wcom_4 = isl_13->wcom_0.xyz;
    Quat_0 rot_3 = rg_11->rot_0;
    float3 _S927 = tr_3 - cross(phi_3, wcom_4);
    thread Quat_0 _S928 = rg_11->rot_0;
    float3 _S929 = rotate_0(&_S928, _S927);
    comp_add_0(&rg_11->pos_1, &rg_11->pos_err_1, _S929);
    thread Quat_0 _S930 = rg_11->rot_0;
    float3 _S931 = inverse_rotate_0(&_S930, rg_11->w_4);
    float4 _S932 = isl_13->inertia0_0;
    float4 _S933 = isl_13->inertia1_0;
    float4 _S934 = isl_13->inertia2_0;
    float3 _S935 = cross(phi_3, rows_mul_0(isl_13->inertia0_0, isl_13->inertia1_0, isl_13->inertia2_0, _S931)) - rows_mul_0(isl_13->inertia0_0, isl_13->inertia1_0, isl_13->inertia2_0, cross(phi_3, _S931));
    thread Quat_0 _S936 = rg_11->rot_0;
    float3 _S937 = rotate_0(&_S936, _S935);
    turn_right_0(&rg_11->rot_0, &rg_11->rot_err_0, phi_3);
    float3 _S938 = dv_3 + cross(dw_2, isl_13->com_0.xyz - wcom_4);
    thread Quat_0 _S939 = rot_3;
    float3 _S940 = rotate_0(&_S939, _S938);
    comp_add_0(&rg_11->vel_1, &rg_11->vel_err_1, _S940);
    thread Quat_0 _S941 = rot_3;
    float3 _S942 = rotate_0(&_S941, dw_2);
    rg_11->w_4 = rg_11->w_4 + _S942;
    thread Quat_0 _S943 = rg_11->rot_0;
    float3 _S944 = world_mul_0(&_S943, _S932, _S933, _S934, _S942);
    comp_add_0(&rg_11->l_2, &rg_11->l_err_1, _S937 + _S944);
    return;
}

void write_probe_0(uint slot_1, uint k_18, float value_0, KernelContext_0 thread* kernelContext_54)
{
    uint at_4 = kernelContext_54->params_0->probe_base_0 * 4U + slot_1 * kernelContext_54->params_0->probe_stride_0 + k_18;
    thread float4 v_16 = float4(*(kernelContext_54->scratch_0+at_4 / 4U)) ;
    v_16[at_4 % 4U] = value_0;
    *(kernelContext_54->scratch_0+at_4 / 4U) = packed_float4(v_16) ;
    return;
}

void record_probes_0(const Island_0 thread* isl_14, const Rigid_0 thread* rg_12, uint k_19, KernelContext_0 thread* kernelContext_55)
{
    uint4 _S945 = isl_14->probes_0;
    uint at_5 = isl_14->probes_0.x;
    for(;;)
    {
        if(at_5 < (_S945.y))
        {
        }
        else
        {
            break;
        }
        uint4 info_3 = (as_type<uint4>((float4(*(kernelContext_55->loads_0+at_5)) )));
        float4 _S946 = float4(*(kernelContext_55->loads_0+(at_5 + 1U))) ;
        float4 _S947 = float4(*(kernelContext_55->loads_0+(at_5 + 2U))) ;
        float4 _S948 = float4(*(kernelContext_55->loads_0+(at_5 + 3U))) ;
        uint kind_4 = info_3.x;
        uint i_10 = info_3.y;
        float value_1;
        if(kind_4 == 0U)
        {
            float3 small_0 = (float4(*(kernelContext_55->state_0+4U * i_10)) ).xyz + float3(_S946.w, _S947.w, _S948.w);
            float3 _S949 = rg_12->pos_1 - _S947.xyz;
            float3 _S950 = rotate_0(&rg_12->rot_0, (float4((kernelContext_55->chunks_0+i_10)->center_0) ).xyz);
            float3 _S951 = _S949 + _S950;
            float3 _S952 = rg_12->pos_err_1 - _S948.xyz;
            float3 _S953 = rotate_0(&rg_12->rot_0, small_0);
            value_1 = dot(_S951 + (_S952 + _S953), _S946.xyz);
        }
        else
        {
            if(kind_4 == 1U)
            {
                uint _S954 = 4U * i_10;
                float3 _S955 = rotate_0(&rg_12->rot_0, (float4((kernelContext_55->chunks_0+i_10)->center_0) ).xyz + (float4(*(kernelContext_55->state_0+_S954)) ).xyz - isl_14->com_0.xyz);
                float3 _S956 = rg_12->vel_1 + rg_12->vel_err_1 + cross(rg_12->w_4, _S955);
                float3 _S957 = rotate_0(&rg_12->rot_0, (float4(*(kernelContext_55->state_0+(_S954 + 2U))) ).xyz);
                value_1 = dot(_S956 + _S957, _S946.xyz);
            }
            else
            {
                if(kind_4 == 2U)
                {
                    uint _S958 = 3U * i_10;
                    float3 f_14 = (float4(*(kernelContext_55->scratch_0+_S958)) ).xyz;
                    bool _S959 = (info_3.z) == 0U;
                    float3 mc_0;
                    if(_S959)
                    {
                        mc_0 = (float4(*(kernelContext_55->scratch_0+(_S958 + 1U))) ).xyz;
                    }
                    else
                    {
                        mc_0 = (float4(*(kernelContext_55->scratch_0+(_S958 + 2U))) ).xyz;
                    }
                    float3 fc_4;
                    if(_S959)
                    {
                        fc_4 = f_14;
                    }
                    else
                    {
                        fc_4 = - f_14;
                    }
                    value_1 = dot(fc_4, _S946.xyz) + dot(mc_0, _S947.xyz);
                }
                else
                {
                    uint _S960 = 4U * i_10;
                    float3 _S961 = rotate_0(&rg_12->rot_0, float3((float4(*(kernelContext_55->state_0+(_S960 + 1U))) ).w, (float4(*(kernelContext_55->state_0+(_S960 + 2U))) ).w, (float4(*(kernelContext_55->state_0+(_S960 + 3U))) ).w));
                    value_1 = dot(_S961, _S946.xyz);
                }
            }
        }
        write_probe_0(info_3.w, k_19, value_1, kernelContext_55);
        at_5 = at_5 + 4U;
    }
    return;
}

void contact_split_at_0(uint at_6, KernelContext_0 thread* kernelContext_56)
{
    uint previous_1 = (uint4((kernelContext_56->islands_0+kernelContext_56->params_0->halt_index_0)->info_0) ).y;
    uint _S962;
    if(previous_1 == 0U)
    {
        _S962 = at_6;
    }
    else
    {
        _S962 = min(previous_1, at_6);
    }
    (kernelContext_56->islands_0+kernelContext_56->params_0->halt_index_0)->info_0[int(1)] = _S962;
    return;
}

uint seen_bits_0(KernelContext_0 thread* kernelContext_57)
{
    uint _S963;
    if(((*kernelContext_57->g_seen_0)[0U]) != 0U)
    {
        _S963 = 32768U;
    }
    else
    {
        _S963 = 0U;
    }
    uint _S964;
    if(((*kernelContext_57->g_seen_0)[1U]) != 0U)
    {
        _S964 = 65536U;
    }
    else
    {
        _S964 = 0U;
    }
    uint _S965 = _S963 | _S964;
    if(((*kernelContext_57->g_seen_0)[2U]) != 0U)
    {
        _S963 = 131072U;
    }
    else
    {
        _S963 = 0U;
    }
    uint _S966 = _S965 | _S963;
    if(((*kernelContext_57->g_seen_0)[3U]) != 0U)
    {
        _S963 = 32U;
    }
    else
    {
        _S963 = 0U;
    }
    uint _S967 = _S966 | _S963;
    if(((*kernelContext_57->g_seen_0)[4U]) != 0U)
    {
        _S963 = 64U;
    }
    else
    {
        _S963 = 0U;
    }
    return _S967 | _S963;
}

[[kernel]] void island_frame(uint3 group_2 [[threadgroup_position_in_grid]], uint3 thread_2 [[thread_position_in_threadgroup]], Params_0 constant* params_6 [[buffer(0)]], Island_natural_0 device* islands_6 [[buffer(9)]], uint device* index_6 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_6 [[buffer(3)]], packed_float4 device* state_8 [[buffer(6)]], packed_float4 device* scratch_6 [[buffer(8)]], packed_float4 device* contact_state_6 [[buffer(11)]], packed_float4 device* loads_6 [[buffer(5)]], Impactor_natural_0 device* impactors_6 [[buffer(10)]], BondStatic_natural_0 device* bonds_6 [[buffer(2)]], MaterialTable_0 constant* materials_6 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_6 [[buffer(7)]])
{
    bool woke_0;
    thread KernelContext_0 kernelContext_58;
    (&kernelContext_58)->params_0 = params_6;
    (&kernelContext_58)->islands_0 = islands_6;
    (&kernelContext_58)->index_0 = index_6;
    (&kernelContext_58)->chunks_0 = chunks_6;
    (&kernelContext_58)->state_0 = state_8;
    (&kernelContext_58)->scratch_0 = scratch_6;
    (&kernelContext_58)->contact_state_0 = contact_state_6;
    (&kernelContext_58)->loads_0 = loads_6;
    (&kernelContext_58)->impactors_0 = impactors_6;
    (&kernelContext_58)->bonds_0 = bonds_6;
    (&kernelContext_58)->materials_0 = materials_6;
    (&kernelContext_58)->bond_dyn_0 = bond_dyn_6;
    threadgroup array<float4, int(32)> g_part_a_6;
    (&kernelContext_58)->g_part_a_0 = &g_part_a_6;
    threadgroup array<float4, int(32)> g_part_b_6;
    (&kernelContext_58)->g_part_b_0 = &g_part_b_6;
    threadgroup array<uint, int(5)> g_seen_6;
    (&kernelContext_58)->g_seen_0 = &g_seen_6;
    threadgroup uint g_run_6;
    (&kernelContext_58)->g_run_0 = &g_run_6;
    threadgroup uint g_halt_6;
    (&kernelContext_58)->g_halt_0 = &g_halt_6;
    threadgroup uint g_wide_run_6;
    (&kernelContext_58)->g_wide_run_0 = &g_wide_run_6;
    uint tid_5 = thread_2.x;
    uint _S968 = group_2.x;
    Island_natural_0 device* _S969 = islands_6+_S968;
    uint4 _S970 = uint4((*_S969).info_0) ;
    float4 _S971 = float4((*_S969).com_0) ;
    float4 _S972 = float4((*_S969).inertia0_0) ;
    float4 _S973 = float4((*_S969).inertia1_0) ;
    float4 _S974 = float4((*_S969).inertia2_0) ;
    float4 _S975 = float4((*_S969).inv0_0) ;
    float4 _S976 = float4((*_S969).inv1_0) ;
    float4 _S977 = float4((*_S969).inv2_0) ;
    float4 _S978 = float4((*_S969).wcom_0) ;
    float4 _S979 = float4((*_S969).winv0_0) ;
    float4 _S980 = float4((*_S969).winv1_0) ;
    float4 _S981 = float4((*_S969).winv2_0) ;
    float4 _S982 = float4((*_S969).rotation_0) ;
    float4 _S983 = float4((*_S969).position_0) ;
    float4 _S984 = float4((*_S969).position_err_0) ;
    float4 _S985 = float4((*_S969).velocity_0) ;
    float4 _S986 = float4((*_S969).velocity_err_0) ;
    float4 _S987 = float4((*_S969).angular_velocity_0) ;
    uint4 _S988 = uint4((*_S969).probes_0) ;
    float4 _S989 = float4((*_S969).energy_0) ;
    float4 _S990 = float4((*_S969).rotation_err_0) ;
    float4 _S991 = float4((*_S969).momentum_0) ;
    float4 _S992 = float4((*_S969).momentum_err_0) ;
    thread Island_0 isl_15;
    (&isl_15)->range_0 = uint4((*_S969).range_0) ;
    (&isl_15)->info_0 = _S970;
    (&isl_15)->com_0 = _S971;
    (&isl_15)->inertia0_0 = _S972;
    (&isl_15)->inertia1_0 = _S973;
    (&isl_15)->inertia2_0 = _S974;
    (&isl_15)->inv0_0 = _S975;
    (&isl_15)->inv1_0 = _S976;
    (&isl_15)->inv2_0 = _S977;
    (&isl_15)->wcom_0 = _S978;
    (&isl_15)->winv0_0 = _S979;
    (&isl_15)->winv1_0 = _S980;
    (&isl_15)->winv2_0 = _S981;
    (&isl_15)->rotation_0 = _S982;
    (&isl_15)->position_0 = _S983;
    (&isl_15)->position_err_0 = _S984;
    (&isl_15)->velocity_0 = _S985;
    (&isl_15)->velocity_err_0 = _S986;
    (&isl_15)->angular_velocity_0 = _S987;
    (&isl_15)->done_0 = (*_S969).done_0;
    (&isl_15)->coverage_0 = (*_S969).coverage_0;
    (&isl_15)->wide_groups_0 = (*_S969).wide_groups_0;
    (&isl_15)->done_pad_0 = (*_S969).done_pad_0;
    (&isl_15)->probes_0 = _S988;
    (&isl_15)->energy_0 = _S989;
    (&isl_15)->rotation_err_0 = _S990;
    (&isl_15)->momentum_0 = _S991;
    (&isl_15)->momentum_err_0 = _S992;
    bool driven_0 = (((&isl_15)->info_0.x) & 2U) != 0U;
    bool _S993 = !((((&isl_15)->info_0.x) & 1U) != 0U);
    bool _S994;
    if(_S993)
    {
        _S994 = !driven_0;
    }
    else
    {
        _S994 = false;
    }
    bool contact_island_0 = (((&isl_15)->info_0.x) & 4U) != 0U;
    bool _S995 = (((&isl_15)->info_0.x) & 16U) != 0U;
    seen_clear_0(tid_5, &kernelContext_58);
    bool _S996 = tid_5 == 0U;
    bool settled_0;
    uint cov_0;
    if(_S996)
    {
        if(contact_island_0 != (((&kernelContext_58)->params_0->contact_mode_0) == 1U))
        {
            settled_0 = true;
        }
        else
        {
            settled_0 = (((&isl_15)->info_0.x) & 8U) != 0U;
        }
        if(settled_0)
        {
            cov_0 = 0U;
        }
        else
        {
            cov_0 = 1U;
        }
        if(contact_island_0)
        {
            thread Island_0 _S997 = isl_15;
            bool _S998 = contact_stopped_1(&_S997, &kernelContext_58);
            settled_0 = _S998;
        }
        else
        {
            settled_0 = false;
        }
        if(settled_0)
        {
            cov_0 = 0U;
        }
        *(&kernelContext_58)->g_run_0 = cov_0;
        *(&kernelContext_58)->g_halt_0 = 0U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    if((((&isl_15)->info_0.z) & 1U) != 0U)
    {
        settled_0 = true;
    }
    else
    {
        settled_0 = (*(&kernelContext_58)->g_run_0) == 0U;
    }
    if(settled_0)
    {
        cov_0 = 0U;
    }
    else
    {
        cov_0 = min((&isl_15)->info_0.y, (&kernelContext_58)->params_0->max_steps_0);
    }
    float _S999 = (&kernelContext_58)->params_0->dt_0;
    bool _S1000 = ((&kernelContext_58)->params_0->fracture_0) != 0U;
    bool _S1001 = ((&kernelContext_58)->params_0->rigid_motion_loads_0) != 0U;
    thread Island_0 _S1002 = isl_15;
    Rigid_0 _S1003 = rigid_of_1(&_S1002);
    thread Rigid_0 rg_13 = _S1003;
    thread float work_3 = 0.0f;
    thread float work_err_2 = 0.0f;
    settled_0 = _S995;
    uint done_1 = 0U;
    bool woke_1 = false;
    for(;;)
    {
        if(done_1 < cov_0)
        {
        }
        else
        {
            woke_0 = woke_1;
            break;
        }
        uint abs_step_1 = (&isl_15)->info_0.w + done_1 + 1U;
        uint k_20 = abs_step_1 - 1U - (&kernelContext_58)->params_0->step_start_0;
        bool quiet_0 = (((&isl_15)->info_0.x) & 32U) != 0U;
        bool _S1004;
        if(settled_0)
        {
            _S1004 = !quiet_0;
        }
        else
        {
            _S1004 = false;
        }
        bool _S1005;
        bool explicit_step_0;
        uint c_20;
        if(_S1004)
        {
            float3 _S1006 = float3(0.0f) ;
            thread float3 norm_0 = _S1006;
            thread float3 unused0_0 = _S1006;
            c_20 = (&isl_15)->range_0.x + tid_5;
            for(;;)
            {
                if(c_20 < ((&isl_15)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                thread Quat_0 _S1007 = (&rg_13)->rot_0;
                float _S1008 = settled_chunk_load_0(c_20, &_S1007, k_20, _S999, contact_island_0, &kernelContext_58);
                norm_0.x = norm_0.x + _S1008;
                c_20 = c_20 + 256U;
            }
            group_sum3_0(tid_5, &norm_0, &unused0_0, &kernelContext_58);
            if(((&kernelContext_58)->params_0->solve_mode_0) == 1U)
            {
                _S1005 = (abs(norm_0.x - (&isl_15)->energy_0.z)) > ((&isl_15)->energy_0.w);
            }
            else
            {
                _S1005 = false;
            }
            if(_S1005)
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
        if(_S993)
        {
            _S1005 = !quiet_0;
        }
        else
        {
            _S1005 = false;
        }
        if(_S1005)
        {
            float3 _S1009 = float3(0.0f) ;
            thread float3 f_15 = _S1009;
            thread float3 t_15 = _S1009;
            c_20 = (&isl_15)->range_0.x + tid_5;
            for(;;)
            {
                if(c_20 < ((&isl_15)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                thread Island_0 _S1010 = isl_15;
                thread Rigid_0 _S1011 = rg_13;
                net_load_1(c_20, &_S1010, &_S1011, k_20, _S999, contact_island_0, &f_15, &t_15, &kernelContext_58);
                c_20 = c_20 + 256U;
            }
            group_sum3_0(tid_5, &f_15, &t_15, &kernelContext_58);
            thread Island_0 _S1012 = isl_15;
            rigid_acceleration_1(&_S1012, &rg_13, f_15, t_15);
        }
        if(!settled_0)
        {
            explicit_step_0 = !quiet_0;
        }
        else
        {
            explicit_step_0 = false;
        }
        uint c_21;
        if(explicit_step_0)
        {
            c_20 = (&isl_15)->range_0.z + tid_5;
            for(;;)
            {
                if(c_20 < ((&isl_15)->range_0.w))
                {
                }
                else
                {
                    break;
                }
                bool _S1013 = bond_update_0(c_20, _S999, _S1000, abs_step_1, false, &kernelContext_58);
                if(_S1013)
                {
                    *(&kernelContext_58)->g_halt_0 = 1U;
                }
                c_20 = c_20 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            c_21 = (&isl_15)->range_0.x + tid_5;
            for(;;)
            {
                if(c_21 < ((&isl_15)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                thread Island_0 _S1014 = isl_15;
                thread Rigid_0 _S1015 = rg_13;
                chunk_update_1(c_21, &_S1014, &_S1015, _S999, _S1001, k_20, contact_island_0, &work_3, &work_err_2, &kernelContext_58);
                c_21 = c_21 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        }
        bool _S1016;
        if(_S994)
        {
            _S1016 = !quiet_0;
        }
        else
        {
            _S1016 = false;
        }
        if(_S1016)
        {
            thread Island_0 _S1017 = isl_15;
            integrate_rigid_1(&_S1017, &rg_13, _S999);
        }
        bool _S1018;
        if(_S993)
        {
            _S1018 = explicit_step_0;
        }
        else
        {
            _S1018 = false;
        }
        if(_S1018)
        {
            float3 _S1019 = (&isl_15)->wcom_0.xyz;
            float3 _S1020 = float3(0.0f) ;
            thread float3 tu_1 = _S1020;
            thread float3 pv_1 = _S1020;
            c_20 = (&isl_15)->range_0.x + tid_5;
            for(;;)
            {
                if(c_20 < ((&isl_15)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_moments_0(c_20, &tu_1, &pv_1, &kernelContext_58);
                c_20 = c_20 + 256U;
            }
            group_sum3_0(tid_5, &tu_1, &pv_1, &kernelContext_58);
            float3 tr_4 = tu_1 / float3((&isl_15)->wcom_0.w) ;
            float3 dv_4 = pv_1 / float3((&isl_15)->wcom_0.w) ;
            thread float3 lu_1 = _S1020;
            thread float3 lv_1 = _S1020;
            c_21 = (&isl_15)->range_0.x + tid_5;
            for(;;)
            {
                if(c_21 < ((&isl_15)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_angular_0(c_21, _S1019, tr_4, dv_4, &lu_1, &lv_1, &kernelContext_58);
                c_21 = c_21 + 256U;
            }
            group_sum3_0(tid_5, &lu_1, &lv_1, &kernelContext_58);
            float3 phi_4 = rows_mul_0((&isl_15)->winv0_0, (&isl_15)->winv1_0, (&isl_15)->winv2_0, lu_1);
            float3 dw_3 = rows_mul_0((&isl_15)->winv0_0, (&isl_15)->winv1_0, (&isl_15)->winv2_0, lv_1);
            uint c_22 = (&isl_15)->range_0.x + tid_5;
            for(;;)
            {
                if(c_22 < ((&isl_15)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_apply_0(c_22, _S1019, tr_4, phi_4, dv_4, dw_3, &kernelContext_58);
                c_22 = c_22 + 256U;
            }
            if(!driven_0)
            {
                thread Island_0 _S1021 = isl_15;
                drift_rigid_1(&_S1021, &rg_13, tr_4, phi_4, dv_4, dw_3);
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        }
        bool _S1022;
        if(_S996)
        {
            _S1022 = ((&isl_15)->probes_0.y) > ((&isl_15)->probes_0.x);
        }
        else
        {
            _S1022 = false;
        }
        if(_S1022)
        {
            thread Island_0 _S1023 = isl_15;
            thread Rigid_0 _S1024 = rg_13;
            record_probes_0(&_S1023, &_S1024, k_20, &kernelContext_58);
        }
        uint _S1025 = done_1 + 1U;
        if((*(&kernelContext_58)->g_halt_0) != 0U)
        {
            done_1 = _S1025;
            break;
        }
        done_1 = _S1025;
        woke_1 = woke_0;
    }
    thread float3 wsum_0 = float3(work_3, work_err_2, 0.0f);
    thread float3 unused_1 = float3(0.0f) ;
    group_sum3_0(tid_5, &wsum_0, &unused_1, &kernelContext_58);
    if(_S996)
    {
        thread Quat_0 _S1026 = (&rg_13)->rot_0;
        float4 _S1027 = quat_vec_0(&_S1026);
        (&isl_15)->rotation_0 = _S1027;
        (&isl_15)->rotation_err_0 = (&rg_13)->rot_err_0;
        (&isl_15)->position_0 = float4((&rg_13)->pos_1, 0.0f);
        (&isl_15)->position_err_0 = float4((&rg_13)->pos_err_1, 0.0f);
        (&isl_15)->velocity_0 = float4((&rg_13)->vel_1, 0.0f);
        (&isl_15)->velocity_err_0 = float4((&rg_13)->vel_err_1, 0.0f);
        (&isl_15)->angular_velocity_0 = float4((&rg_13)->w_4, 0.0f);
        (&isl_15)->momentum_0 = float4((&rg_13)->l_2, 0.0f);
        (&isl_15)->momentum_err_0 = float4((&rg_13)->l_err_1, 0.0f);
        (&isl_15)->done_0 = done_1;
        (&isl_15)->info_0.y = (&isl_15)->info_0.y - done_1;
        if((*(&kernelContext_58)->g_halt_0) != 0U)
        {
            _S994 = contact_island_0;
        }
        else
        {
            _S994 = false;
        }
        if(_S994)
        {
            contact_split_at_0((&isl_15)->info_0.w + done_1, &kernelContext_58);
        }
        float _S1028 = wsum_0.x;
        thread float _S1029 = (&isl_15)->energy_0.x;
        thread float _S1030 = (&isl_15)->energy_0.y;
        comp_add1_0(&_S1029, &_S1030, _S1028);
        (&isl_15)->energy_0.x = _S1029;
        (&isl_15)->energy_0.y = _S1030 + wsum_0.y;
        (&isl_15)->info_0.w = (&isl_15)->info_0.w + done_1;
        if((*(&kernelContext_58)->g_halt_0) != 0U)
        {
            (&isl_15)->info_0.z = ((&isl_15)->info_0.z) | 1U;
        }
        uint _S1031 = seen_bits_0(&kernelContext_58);
        if((*(&kernelContext_58)->g_halt_0) != 0U)
        {
            cov_0 = 128U;
        }
        else
        {
            cov_0 = 0U;
        }
        uint _S1032 = _S1031 | cov_0;
        if(woke_0)
        {
            cov_0 = 2048U;
        }
        else
        {
            cov_0 = 0U;
        }
        uint cov_1 = _S1032 | cov_0;
        if(done_1 > 0U)
        {
            bool quiet_1 = (((&isl_15)->info_0.x) & 32U) != 0U;
            if(quiet_1)
            {
                cov_0 = 4096U;
            }
            else
            {
                cov_0 = 0U;
            }
            uint cov_2 = cov_1 | cov_0;
            if((((&isl_15)->info_0.x) & 16U) != 0U)
            {
                _S994 = !quiet_1;
            }
            else
            {
                _S994 = false;
            }
            if(_S994)
            {
                cov_0 = 512U;
            }
            else
            {
                cov_0 = 0U;
            }
            uint cov_3 = cov_2 | cov_0;
            if(((&kernelContext_58)->params_0->contact_mode_0) == 1U)
            {
                cov_0 = 524288U;
            }
            else
            {
                cov_0 = 0U;
            }
            uint cov_4 = cov_3 | cov_0;
            if(((&isl_15)->probes_0.y) > ((&isl_15)->probes_0.x))
            {
                cov_0 = 262144U;
            }
            else
            {
                cov_0 = 0U;
            }
            cov_0 = cov_4 | cov_0;
        }
        else
        {
            cov_0 = cov_1;
        }
        (&isl_15)->coverage_0 = ((&isl_15)->coverage_0) | cov_0;
        if(woke_0)
        {
            (&isl_15)->info_0.x = ((&isl_15)->info_0.x) & 4294967279U;
            (&isl_15)->info_0.z = ((&isl_15)->info_0.z) | 4U;
        }
        Island_natural_0 device* _S1033 = (&kernelContext_58)->islands_0+_S968;
        _S1033->range_0 = packed_uint4(isl_15.range_0) ;
        _S1033->info_0 = packed_uint4(isl_15.info_0) ;
        _S1033->com_0 = packed_float4(isl_15.com_0) ;
        _S1033->inertia0_0 = packed_float4(isl_15.inertia0_0) ;
        _S1033->inertia1_0 = packed_float4(isl_15.inertia1_0) ;
        _S1033->inertia2_0 = packed_float4(isl_15.inertia2_0) ;
        _S1033->inv0_0 = packed_float4(isl_15.inv0_0) ;
        _S1033->inv1_0 = packed_float4(isl_15.inv1_0) ;
        _S1033->inv2_0 = packed_float4(isl_15.inv2_0) ;
        _S1033->wcom_0 = packed_float4(isl_15.wcom_0) ;
        _S1033->winv0_0 = packed_float4(isl_15.winv0_0) ;
        _S1033->winv1_0 = packed_float4(isl_15.winv1_0) ;
        _S1033->winv2_0 = packed_float4(isl_15.winv2_0) ;
        _S1033->rotation_0 = packed_float4(isl_15.rotation_0) ;
        _S1033->position_0 = packed_float4(isl_15.position_0) ;
        _S1033->position_err_0 = packed_float4(isl_15.position_err_0) ;
        _S1033->velocity_0 = packed_float4(isl_15.velocity_0) ;
        _S1033->velocity_err_0 = packed_float4(isl_15.velocity_err_0) ;
        _S1033->angular_velocity_0 = packed_float4(isl_15.angular_velocity_0) ;
        _S1033->done_0 = isl_15.done_0;
        _S1033->coverage_0 = isl_15.coverage_0;
        _S1033->wide_groups_0 = isl_15.wide_groups_0;
        _S1033->done_pad_0 = isl_15.done_pad_0;
        _S1033->probes_0 = packed_uint4(isl_15.probes_0) ;
        _S1033->energy_0 = packed_float4(isl_15.energy_0) ;
        _S1033->rotation_err_0 = packed_float4(isl_15.rotation_err_0) ;
        _S1033->momentum_0 = packed_float4(isl_15.momentum_0) ;
        _S1033->momentum_err_0 = packed_float4(isl_15.momentum_err_0) ;
    }
    return;
}

struct WideGroup_0
{
    uint island_3;
    uint begin_1;
    uint end_0;
    uint first_0;
};

WideGroup_0 wide_group_0(uint table_0, uint g_2, KernelContext_0 thread* kernelContext_59)
{
    thread WideGroup_0 w_11;
    uint _S1034 = table_0 + 4U * g_2;
    (&w_11)->island_3 = kernelContext_59->index_0[_S1034];
    (&w_11)->begin_1 = kernelContext_59->index_0[_S1034 + 1U];
    (&w_11)->end_0 = kernelContext_59->index_0[_S1034 + 2U];
    (&w_11)->first_0 = kernelContext_59->index_0[_S1034 + 3U];
    return w_11;
}

bool wide_runs_0(const Island_natural_0 thread* isl_16, KernelContext_0 thread* kernelContext_60)
{
    uint4 _S1035 = uint4(isl_16->info_0) ;
    bool _S1036;
    if(((_S1035.z) & 1U) != 0U)
    {
        _S1036 = true;
    }
    else
    {
        _S1036 = (_S1035.y) == 0U;
    }
    if(_S1036)
    {
        return false;
    }
    if(((_S1035.x) & 4U) == 0U)
    {
        _S1036 = true;
    }
    else
    {
        bool _S1037 = contact_stopped_0(isl_16, kernelContext_60);
        _S1036 = !_S1037;
    }
    return _S1036;
}

bool wide_enter_0(uint tid_6, const Island_natural_0 thread* isl_17, KernelContext_0 thread* kernelContext_61)
{
    seen_clear_0(tid_6, kernelContext_61);
    if(tid_6 == 0U)
    {
        bool _S1038 = wide_runs_0(isl_17, kernelContext_61);
        int _S1039;
        if(_S1038)
        {
            _S1039 = int(1);
        }
        else
        {
            _S1039 = int(0);
        }
        *kernelContext_61->g_wide_run_0 = uint(_S1039);
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    return (*kernelContext_61->g_wide_run_0) != 0U;
}

uint wide_step_0(const Island_natural_0 thread* isl_18, KernelContext_0 thread* kernelContext_62)
{
    return (uint4(isl_18->info_0) ).w - kernelContext_62->params_0->step_start_0;
}

uint wide_step_1(const Island_0 thread* isl_19, KernelContext_0 thread* kernelContext_63)
{
    return isl_19->info_0.w - kernelContext_63->params_0->step_start_0;
}

bool wide_enter_1(uint _S1040, uint _S1041, KernelContext_0 thread* kernelContext_64)
{
    thread Island_natural_0 _S1042 = *(kernelContext_64->islands_0+_S1041);
    seen_clear_0(_S1040, kernelContext_64);
    if(_S1040 == 0U)
    {
        bool _S1043 = wide_runs_0(&_S1042, kernelContext_64);
        int _S1044;
        if(_S1043)
        {
            _S1044 = int(1);
        }
        else
        {
            _S1044 = int(0);
        }
        *kernelContext_64->g_wide_run_0 = uint(_S1044);
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    return (*kernelContext_64->g_wide_run_0) != 0U;
}

[[kernel]] void wide_wake(uint3 group_3 [[threadgroup_position_in_grid]], uint3 thread_3 [[thread_position_in_threadgroup]], Params_0 constant* params_7 [[buffer(0)]], Island_natural_0 device* islands_7 [[buffer(9)]], uint device* index_7 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_7 [[buffer(3)]], packed_float4 device* state_9 [[buffer(6)]], packed_float4 device* scratch_7 [[buffer(8)]], packed_float4 device* contact_state_7 [[buffer(11)]], packed_float4 device* loads_7 [[buffer(5)]], Impactor_natural_0 device* impactors_7 [[buffer(10)]], BondStatic_natural_0 device* bonds_7 [[buffer(2)]], MaterialTable_0 constant* materials_7 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_7 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_65;
    (&kernelContext_65)->params_0 = params_7;
    (&kernelContext_65)->islands_0 = islands_7;
    (&kernelContext_65)->index_0 = index_7;
    (&kernelContext_65)->chunks_0 = chunks_7;
    (&kernelContext_65)->state_0 = state_9;
    (&kernelContext_65)->scratch_0 = scratch_7;
    (&kernelContext_65)->contact_state_0 = contact_state_7;
    (&kernelContext_65)->loads_0 = loads_7;
    (&kernelContext_65)->impactors_0 = impactors_7;
    (&kernelContext_65)->bonds_0 = bonds_7;
    (&kernelContext_65)->materials_0 = materials_7;
    (&kernelContext_65)->bond_dyn_0 = bond_dyn_7;
    threadgroup array<float4, int(32)> g_part_a_7;
    (&kernelContext_65)->g_part_a_0 = &g_part_a_7;
    threadgroup array<float4, int(32)> g_part_b_7;
    (&kernelContext_65)->g_part_b_0 = &g_part_b_7;
    threadgroup array<uint, int(5)> g_seen_7;
    (&kernelContext_65)->g_seen_0 = &g_seen_7;
    threadgroup uint g_run_7;
    (&kernelContext_65)->g_run_0 = &g_run_7;
    threadgroup uint g_halt_7;
    (&kernelContext_65)->g_halt_0 = &g_halt_7;
    threadgroup uint g_wide_run_7;
    (&kernelContext_65)->g_wide_run_0 = &g_wide_run_7;
    uint tid_7 = thread_3.x;
    uint _S1045 = group_3.x;
    WideGroup_0 _S1046 = wide_group_0(params_7->wide_chunk_table_0, _S1045, &kernelContext_65);
    if(_S1045 != (_S1046.first_0))
    {
        return;
    }
    thread Island_natural_0 _S1047 = *((&kernelContext_65)->islands_0+_S1046.island_3);
    uint4 _S1048 = uint4((&_S1047)->info_0) ;
    uint _S1049 = _S1048.x;
    bool _S1050;
    if((_S1049 & 16U) == 0U)
    {
        _S1050 = true;
    }
    else
    {
        bool _S1051 = wide_enter_1(tid_7, _S1046.island_3, &kernelContext_65);
        _S1050 = !_S1051;
    }
    if(_S1050)
    {
        return;
    }
    Quat_0 _S1052 = quat_of_0(float4((&_S1047)->rotation_0) );
    bool _S1053 = (_S1049 & 4U) != 0U;
    float3 _S1054 = float3(0.0f) ;
    thread float3 norm_1 = _S1054;
    thread float3 unused_2 = _S1054;
    uint4 _S1055 = uint4((&_S1047)->range_0) ;
    uint c_23 = _S1055.x + tid_7;
    for(;;)
    {
        if(c_23 < (_S1055.y))
        {
        }
        else
        {
            break;
        }
        uint _S1056 = wide_step_0(&_S1047, &kernelContext_65);
        float _S1057 = (&kernelContext_65)->params_0->dt_0;
        thread Quat_0 _S1058 = _S1052;
        float _S1059 = settled_chunk_load_0(c_23, &_S1058, _S1056, _S1057, _S1053, &kernelContext_65);
        norm_1.x = norm_1.x + _S1059;
        c_23 = c_23 + 256U;
    }
    group_sum3_0(tid_7, &norm_1, &unused_2, &kernelContext_65);
    if(tid_7 != 0U)
    {
        return;
    }
    uint _S1060 = seen_bits_0(&kernelContext_65);
    uint cov_5 = 1024U | _S1060;
    if(((&kernelContext_65)->params_0->solve_mode_0) == 1U)
    {
        float4 _S1061 = float4((&_S1047)->energy_0) ;
        _S1050 = (abs(norm_1.x - _S1061.z)) > (_S1061.w);
    }
    else
    {
        _S1050 = false;
    }
    uint cov_6;
    if(_S1050)
    {
        ((&kernelContext_65)->islands_0+_S1046.island_3)->info_0[int(0)] = _S1049 & 4294967279U;
        ((&kernelContext_65)->islands_0+_S1046.island_3)->info_0[int(2)] = (_S1048.z) | 4U;
        cov_6 = cov_5 | 2048U;
    }
    else
    {
        cov_6 = cov_5;
    }
    cov_mark_0(_S1046.island_3, (&_S1047)->coverage_0, cov_6, &kernelContext_65);
    return;
}

void wide_store_0(uint slot_2, uint p_14, float3 a_12, float3 b_29, KernelContext_0 thread* kernelContext_66)
{
    uint _S1062 = 8U * slot_2;
    *(kernelContext_66->scratch_0+(kernelContext_66->params_0->wide_base_0 + _S1062 + p_14)) = packed_float4(float4(a_12, 0.0f)) ;
    *(kernelContext_66->scratch_0+(kernelContext_66->params_0->wide_base_0 + _S1062 + p_14 + 1U)) = packed_float4(float4(b_29, 0.0f)) ;
    return;
}

[[kernel]] void wide_bonds(uint3 group_4 [[threadgroup_position_in_grid]], uint3 thread_4 [[thread_position_in_threadgroup]], Params_0 constant* params_8 [[buffer(0)]], Island_natural_0 device* islands_8 [[buffer(9)]], uint device* index_8 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_8 [[buffer(3)]], packed_float4 device* state_10 [[buffer(6)]], packed_float4 device* scratch_8 [[buffer(8)]], packed_float4 device* contact_state_8 [[buffer(11)]], packed_float4 device* loads_8 [[buffer(5)]], Impactor_natural_0 device* impactors_8 [[buffer(10)]], BondStatic_natural_0 device* bonds_8 [[buffer(2)]], MaterialTable_0 constant* materials_8 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_8 [[buffer(7)]])
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
    threadgroup uint g_run_8;
    (&kernelContext_67)->g_run_0 = &g_run_8;
    threadgroup uint g_halt_8;
    (&kernelContext_67)->g_halt_0 = &g_halt_8;
    threadgroup uint g_wide_run_8;
    (&kernelContext_67)->g_wide_run_0 = &g_wide_run_8;
    uint tid_8 = thread_4.x;
    uint _S1063 = group_4.x;
    bool bond_group_0 = _S1063 < (params_8->wide_bond_groups_0);
    WideGroup_0 wg_0;
    if(bond_group_0)
    {
        WideGroup_0 _S1064 = wide_group_0((&kernelContext_67)->params_0->wide_bond_table_0, _S1063, &kernelContext_67);
        wg_0 = _S1064;
    }
    else
    {
        WideGroup_0 _S1065 = wide_group_0((&kernelContext_67)->params_0->wide_chunk_table_0, _S1063 - params_8->wide_bond_groups_0, &kernelContext_67);
        wg_0 = _S1065;
    }
    WideGroup_0 _S1066 = wg_0;
    thread Island_natural_0 _S1067 = *((&kernelContext_67)->islands_0+wg_0.island_3);
    bool _S1068 = wide_enter_1(tid_8, wg_0.island_3, &kernelContext_67);
    if(!_S1068)
    {
        return;
    }
    uint _S1069 = wide_step_0(&_S1067, &kernelContext_67);
    if(bond_group_0)
    {
        uint4 _S1070 = uint4((&_S1067)->info_0) ;
        if(((_S1070.x) & 16U) != 0U)
        {
            return;
        }
        uint i_11 = wg_0.begin_1 + tid_8;
        bool _S1071;
        if(i_11 < (wg_0.end_0))
        {
            bool _S1072 = bond_update_0(i_11, (&kernelContext_67)->params_0->dt_0, ((&kernelContext_67)->params_0->fracture_0) != 0U, _S1070.w + 1U, true, &kernelContext_67);
            _S1071 = _S1072;
        }
        else
        {
            _S1071 = false;
        }
        if(_S1071)
        {
            ((&kernelContext_67)->islands_0+_S1066.island_3)->info_0[int(2)] = (_S1070.z) | 2U;
        }
        return;
    }
    uint _S1073 = (uint4((&_S1067)->info_0) ).x;
    if((_S1073 & 1U) != 0U)
    {
        return;
    }
    float3 _S1074 = float3(0.0f) ;
    thread float3 f_16 = _S1074;
    thread float3 t_16 = _S1074;
    uint c_24 = wg_0.begin_1 + tid_8;
    if(c_24 < (wg_0.end_0))
    {
        Rigid_0 _S1075 = rigid_of_0(&_S1067);
        float _S1076 = (&kernelContext_67)->params_0->dt_0;
        bool _S1077 = (_S1073 & 4U) != 0U;
        thread Rigid_0 _S1078 = _S1075;
        net_load_0(c_24, &_S1067, &_S1078, _S1069, _S1076, _S1077, &f_16, &t_16, &kernelContext_67);
    }
    group_sum3_0(tid_8, &f_16, &t_16, &kernelContext_67);
    if(tid_8 == 0U)
    {
        wide_store_0(_S1063 - params_8->wide_bond_groups_0, 0U, f_16, t_16, &kernelContext_67);
    }
    return;
}

void wide_partials_0(uint tid_9, uint first_1, uint count_6, uint p_15, float3 thread* a_13, float3 thread* b_30, KernelContext_0 thread* kernelContext_68)
{
    float4 _S1079 = float4(0.0f) ;
    thread float4 x_14 = _S1079;
    thread float4 y_2 = _S1079;
    uint s_7 = tid_9;
    for(;;)
    {
        if(s_7 < count_6)
        {
        }
        else
        {
            break;
        }
        uint _S1080 = 8U * (first_1 + s_7);
        x_14 = x_14 + float4(*(kernelContext_68->scratch_0+(kernelContext_68->params_0->wide_base_0 + _S1080 + p_15))) ;
        y_2 = y_2 + float4(*(kernelContext_68->scratch_0+(kernelContext_68->params_0->wide_base_0 + _S1080 + p_15 + 1U))) ;
        s_7 = s_7 + 256U;
    }
    group_sum2_0(tid_9, &x_14, &y_2, kernelContext_68);
    *a_13 = x_14.xyz;
    *b_30 = y_2.xyz;
    return;
}

Rigid_0 wide_rigid_frame_0(uint tid_10, const Island_natural_0 thread* isl_20, const WideGroup_0 thread* wg_1, KernelContext_0 thread* kernelContext_69)
{
    Rigid_0 _S1081 = rigid_of_0(isl_20);
    thread Rigid_0 rg_14 = _S1081;
    if((((uint4(isl_20->info_0) ).x) & 1U) == 0U)
    {
        thread float3 f_17;
        thread float3 t_17;
        wide_partials_0(tid_10, wg_1->first_0, isl_20->wide_groups_0, 0U, &f_17, &t_17, kernelContext_69);
        rigid_acceleration_0(isl_20, &rg_14, f_17, t_17);
    }
    return rg_14;
}

[[kernel]] void wide_chunks(uint3 group_5 [[threadgroup_position_in_grid]], uint3 thread_5 [[thread_position_in_threadgroup]], Params_0 constant* params_9 [[buffer(0)]], Island_natural_0 device* islands_9 [[buffer(9)]], uint device* index_9 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_9 [[buffer(3)]], packed_float4 device* state_11 [[buffer(6)]], packed_float4 device* scratch_9 [[buffer(8)]], packed_float4 device* contact_state_9 [[buffer(11)]], packed_float4 device* loads_9 [[buffer(5)]], Impactor_natural_0 device* impactors_9 [[buffer(10)]], BondStatic_natural_0 device* bonds_9 [[buffer(2)]], MaterialTable_0 constant* materials_9 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_9 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_70;
    (&kernelContext_70)->params_0 = params_9;
    (&kernelContext_70)->islands_0 = islands_9;
    (&kernelContext_70)->index_0 = index_9;
    (&kernelContext_70)->chunks_0 = chunks_9;
    (&kernelContext_70)->state_0 = state_11;
    (&kernelContext_70)->scratch_0 = scratch_9;
    (&kernelContext_70)->contact_state_0 = contact_state_9;
    (&kernelContext_70)->loads_0 = loads_9;
    (&kernelContext_70)->impactors_0 = impactors_9;
    (&kernelContext_70)->bonds_0 = bonds_9;
    (&kernelContext_70)->materials_0 = materials_9;
    (&kernelContext_70)->bond_dyn_0 = bond_dyn_9;
    threadgroup array<float4, int(32)> g_part_a_9;
    (&kernelContext_70)->g_part_a_0 = &g_part_a_9;
    threadgroup array<float4, int(32)> g_part_b_9;
    (&kernelContext_70)->g_part_b_0 = &g_part_b_9;
    threadgroup array<uint, int(5)> g_seen_9;
    (&kernelContext_70)->g_seen_0 = &g_seen_9;
    threadgroup uint g_run_9;
    (&kernelContext_70)->g_run_0 = &g_run_9;
    threadgroup uint g_halt_9;
    (&kernelContext_70)->g_halt_0 = &g_halt_9;
    threadgroup uint g_wide_run_9;
    (&kernelContext_70)->g_wide_run_0 = &g_wide_run_9;
    uint tid_11 = thread_5.x;
    uint _S1082 = group_5.x;
    WideGroup_0 _S1083 = wide_group_0(params_9->wide_chunk_table_0, _S1082, &kernelContext_70);
    thread Island_natural_0 _S1084 = *((&kernelContext_70)->islands_0+_S1083.island_3);
    bool _S1085 = wide_enter_1(tid_11, _S1083.island_3, &kernelContext_70);
    if(!_S1085)
    {
        return;
    }
    uint _S1086 = (uint4((&_S1084)->info_0) ).x;
    bool anchored_0 = (_S1086 & 1U) != 0U;
    if((_S1086 & 16U) != 0U)
    {
        if(tid_11 == 0U)
        {
            *((&kernelContext_70)->scratch_0+((&kernelContext_70)->params_0->wide_base_0 + 8U * _S1082 + 6U)) = packed_float4(float4(0.0f) ) ;
        }
        return;
    }
    thread WideGroup_0 _S1087 = _S1083;
    Rigid_0 _S1088 = wide_rigid_frame_0(tid_11, &_S1084, &_S1087, &kernelContext_70);
    thread float work_4 = 0.0f;
    thread float work_err_3 = 0.0f;
    float3 _S1089 = float3(0.0f) ;
    thread float3 tu_2 = _S1089;
    thread float3 pv_2 = _S1089;
    uint c_25 = _S1083.begin_1 + tid_11;
    if(c_25 < (_S1083.end_0))
    {
        float _S1090 = (&kernelContext_70)->params_0->dt_0;
        bool _S1091 = ((&kernelContext_70)->params_0->rigid_motion_loads_0) != 0U;
        uint _S1092 = wide_step_0(&_S1084, &kernelContext_70);
        bool _S1093 = (_S1086 & 4U) != 0U;
        thread Rigid_0 _S1094 = _S1088;
        chunk_update_0(c_25, &_S1084, &_S1094, _S1090, _S1091, _S1092, _S1093, &work_4, &work_err_3, &kernelContext_70);
        if(!anchored_0)
        {
            drift_moments_0(c_25, &tu_2, &pv_2, &kernelContext_70);
        }
    }
    thread float3 wsum_1 = float3(work_4, work_err_3, 0.0f);
    thread float3 unused_3 = _S1089;
    group_sum3_0(tid_11, &wsum_1, &unused_3, &kernelContext_70);
    bool _S1095 = !anchored_0;
    if(_S1095)
    {
        group_sum3_0(tid_11, &tu_2, &pv_2, &kernelContext_70);
    }
    if(tid_11 == 0U)
    {
        uint _S1096 = 8U * _S1082;
        *((&kernelContext_70)->scratch_0+((&kernelContext_70)->params_0->wide_base_0 + _S1096 + 6U)) = packed_float4(float4(wsum_1, 0.0f)) ;
        if(_S1095)
        {
            wide_store_0(_S1082, 2U, tu_2, pv_2, &kernelContext_70);
        }
        *((&kernelContext_70)->scratch_0+((&kernelContext_70)->params_0->wide_base_0 + _S1096 + 7U)) = packed_float4(float4(float((*(&kernelContext_70)->g_seen_0)[0U]), float((*(&kernelContext_70)->g_seen_0)[1U]), float((*(&kernelContext_70)->g_seen_0)[2U]), 0.0f)) ;
    }
    return;
}

[[kernel]] void wide_drift(uint3 group_6 [[threadgroup_position_in_grid]], uint3 thread_6 [[thread_position_in_threadgroup]], Params_0 constant* params_10 [[buffer(0)]], Island_natural_0 device* islands_10 [[buffer(9)]], uint device* index_10 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_10 [[buffer(3)]], packed_float4 device* state_12 [[buffer(6)]], packed_float4 device* scratch_10 [[buffer(8)]], packed_float4 device* contact_state_10 [[buffer(11)]], packed_float4 device* loads_10 [[buffer(5)]], Impactor_natural_0 device* impactors_10 [[buffer(10)]], BondStatic_natural_0 device* bonds_10 [[buffer(2)]], MaterialTable_0 constant* materials_10 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_10 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_71;
    (&kernelContext_71)->params_0 = params_10;
    (&kernelContext_71)->islands_0 = islands_10;
    (&kernelContext_71)->index_0 = index_10;
    (&kernelContext_71)->chunks_0 = chunks_10;
    (&kernelContext_71)->state_0 = state_12;
    (&kernelContext_71)->scratch_0 = scratch_10;
    (&kernelContext_71)->contact_state_0 = contact_state_10;
    (&kernelContext_71)->loads_0 = loads_10;
    (&kernelContext_71)->impactors_0 = impactors_10;
    (&kernelContext_71)->bonds_0 = bonds_10;
    (&kernelContext_71)->materials_0 = materials_10;
    (&kernelContext_71)->bond_dyn_0 = bond_dyn_10;
    threadgroup array<float4, int(32)> g_part_a_10;
    (&kernelContext_71)->g_part_a_0 = &g_part_a_10;
    threadgroup array<float4, int(32)> g_part_b_10;
    (&kernelContext_71)->g_part_b_0 = &g_part_b_10;
    threadgroup array<uint, int(5)> g_seen_10;
    (&kernelContext_71)->g_seen_0 = &g_seen_10;
    threadgroup uint g_run_10;
    (&kernelContext_71)->g_run_0 = &g_run_10;
    threadgroup uint g_halt_10;
    (&kernelContext_71)->g_halt_0 = &g_halt_10;
    threadgroup uint g_wide_run_10;
    (&kernelContext_71)->g_wide_run_0 = &g_wide_run_10;
    uint tid_12 = thread_6.x;
    uint _S1097 = group_6.x;
    WideGroup_0 _S1098 = wide_group_0(params_10->wide_chunk_table_0, _S1097, &kernelContext_71);
    Island_natural_0 device* _S1099 = (&kernelContext_71)->islands_0+_S1098.island_3;
    Island_natural_0 isl_21 = *_S1099;
    bool _S1100;
    if((((uint4((*_S1099).info_0) ).x) & 17U) != 0U)
    {
        _S1100 = true;
    }
    else
    {
        bool _S1101 = wide_enter_1(tid_12, _S1098.island_3, &kernelContext_71);
        _S1100 = !_S1101;
    }
    if(_S1100)
    {
        return;
    }
    thread float3 tu_3;
    thread float3 pv_3;
    wide_partials_0(tid_12, _S1098.first_0, isl_21.wide_groups_0, 2U, &tu_3, &pv_3, &kernelContext_71);
    float4 _S1102 = float4(isl_21.wcom_0) ;
    float3 _S1103 = float3(_S1102.w) ;
    float3 tr_5 = tu_3 / _S1103;
    float3 dv_5 = pv_3 / _S1103;
    float3 _S1104 = float3(0.0f) ;
    thread float3 lu_2 = _S1104;
    thread float3 lv_2 = _S1104;
    uint c_26 = _S1098.begin_1 + tid_12;
    if(c_26 < (_S1098.end_0))
    {
        drift_angular_0(c_26, _S1102.xyz, tr_5, dv_5, &lu_2, &lv_2, &kernelContext_71);
    }
    group_sum3_0(tid_12, &lu_2, &lv_2, &kernelContext_71);
    if(tid_12 == 0U)
    {
        wide_store_0(_S1097, 4U, lu_2, lv_2, &kernelContext_71);
    }
    return;
}

[[kernel]] void wide_rigid(uint3 group_7 [[threadgroup_position_in_grid]], uint3 thread_7 [[thread_position_in_threadgroup]], Params_0 constant* params_11 [[buffer(0)]], Island_natural_0 device* islands_11 [[buffer(9)]], uint device* index_11 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_11 [[buffer(3)]], packed_float4 device* state_13 [[buffer(6)]], packed_float4 device* scratch_11 [[buffer(8)]], packed_float4 device* contact_state_11 [[buffer(11)]], packed_float4 device* loads_11 [[buffer(5)]], Impactor_natural_0 device* impactors_11 [[buffer(10)]], BondStatic_natural_0 device* bonds_11 [[buffer(2)]], MaterialTable_0 constant* materials_11 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_11 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_72;
    (&kernelContext_72)->params_0 = params_11;
    (&kernelContext_72)->islands_0 = islands_11;
    (&kernelContext_72)->index_0 = index_11;
    (&kernelContext_72)->chunks_0 = chunks_11;
    (&kernelContext_72)->state_0 = state_13;
    (&kernelContext_72)->scratch_0 = scratch_11;
    (&kernelContext_72)->contact_state_0 = contact_state_11;
    (&kernelContext_72)->loads_0 = loads_11;
    (&kernelContext_72)->impactors_0 = impactors_11;
    (&kernelContext_72)->bonds_0 = bonds_11;
    (&kernelContext_72)->materials_0 = materials_11;
    (&kernelContext_72)->bond_dyn_0 = bond_dyn_11;
    threadgroup array<float4, int(32)> g_part_a_11;
    (&kernelContext_72)->g_part_a_0 = &g_part_a_11;
    threadgroup array<float4, int(32)> g_part_b_11;
    (&kernelContext_72)->g_part_b_0 = &g_part_b_11;
    threadgroup array<uint, int(5)> g_seen_11;
    (&kernelContext_72)->g_seen_0 = &g_seen_11;
    threadgroup uint g_run_11;
    (&kernelContext_72)->g_run_0 = &g_run_11;
    threadgroup uint g_halt_11;
    (&kernelContext_72)->g_halt_0 = &g_halt_11;
    threadgroup uint g_wide_run_11;
    (&kernelContext_72)->g_wide_run_0 = &g_wide_run_11;
    uint tid_13 = thread_7.x;
    uint _S1105 = group_7.x;
    WideGroup_0 _S1106 = wide_group_0(params_11->wide_chunk_table_0, _S1105, &kernelContext_72);
    thread Island_natural_0 _S1107 = *((&kernelContext_72)->islands_0+_S1106.island_3);
    uint _S1108 = (uint4((&_S1107)->info_0) ).x;
    bool _S1109;
    if((_S1108 & 1U) != 0U)
    {
        _S1109 = true;
    }
    else
    {
        bool _S1110 = wide_enter_1(tid_13, _S1106.island_3, &kernelContext_72);
        _S1109 = !_S1110;
    }
    if(_S1109)
    {
        return;
    }
    if((_S1108 & 16U) != 0U)
    {
        if(_S1105 != (_S1106.first_0))
        {
            return;
        }
        thread WideGroup_0 _S1111 = _S1106;
        Rigid_0 _S1112 = wide_rigid_frame_0(tid_13, &_S1107, &_S1111, &kernelContext_72);
        thread Rigid_0 rs_0 = _S1112;
        if(tid_13 != 0U)
        {
            _S1109 = true;
        }
        else
        {
            _S1109 = (_S1108 & 2U) != 0U;
        }
        if(_S1109)
        {
            return;
        }
        integrate_rigid_0(&_S1107, &rs_0, (&kernelContext_72)->params_0->dt_0);
        thread Quat_0 _S1113 = (&rs_0)->rot_0;
        float4 _S1114 = quat_vec_0(&_S1113);
        ((&kernelContext_72)->islands_0+_S1106.island_3)->rotation_0 = packed_float4(_S1114) ;
        ((&kernelContext_72)->islands_0+_S1106.island_3)->rotation_err_0 = packed_float4((&rs_0)->rot_err_0) ;
        ((&kernelContext_72)->islands_0+_S1106.island_3)->position_0 = packed_float4(float4((&rs_0)->pos_1, 0.0f)) ;
        ((&kernelContext_72)->islands_0+_S1106.island_3)->position_err_0 = packed_float4(float4((&rs_0)->pos_err_1, 0.0f)) ;
        ((&kernelContext_72)->islands_0+_S1106.island_3)->velocity_0 = packed_float4(float4((&rs_0)->vel_1, 0.0f)) ;
        ((&kernelContext_72)->islands_0+_S1106.island_3)->velocity_err_0 = packed_float4(float4((&rs_0)->vel_err_1, 0.0f)) ;
        ((&kernelContext_72)->islands_0+_S1106.island_3)->angular_velocity_0 = packed_float4(float4((&rs_0)->w_4, 0.0f)) ;
        ((&kernelContext_72)->islands_0+_S1106.island_3)->momentum_0 = packed_float4(float4((&rs_0)->l_2, 0.0f)) ;
        ((&kernelContext_72)->islands_0+_S1106.island_3)->momentum_err_0 = packed_float4(float4((&rs_0)->l_err_1, 0.0f)) ;
        return;
    }
    thread float3 tu_4;
    thread float3 pv_4;
    wide_partials_0(tid_13, _S1106.first_0, (&_S1107)->wide_groups_0, 2U, &tu_4, &pv_4, &kernelContext_72);
    thread float3 lu_3;
    thread float3 lv_3;
    wide_partials_0(tid_13, _S1106.first_0, (&_S1107)->wide_groups_0, 4U, &lu_3, &lv_3, &kernelContext_72);
    float4 _S1115 = float4((&_S1107)->wcom_0) ;
    float3 _S1116 = float3(_S1115.w) ;
    float3 tr_6 = tu_4 / _S1116;
    float3 dv_6 = pv_4 / _S1116;
    float4 _S1117 = float4((&_S1107)->winv0_0) ;
    float4 _S1118 = float4((&_S1107)->winv1_0) ;
    float4 _S1119 = float4((&_S1107)->winv2_0) ;
    float3 phi_5 = rows_mul_0(_S1117, _S1118, _S1119, lu_3);
    float3 dw_4 = rows_mul_0(_S1117, _S1118, _S1119, lv_3);
    uint c_27 = _S1106.begin_1 + tid_13;
    if(c_27 < (_S1106.end_0))
    {
        drift_apply_0(c_27, _S1115.xyz, tr_6, phi_5, dv_6, dw_4, &kernelContext_72);
    }
    if(_S1105 != (_S1106.first_0))
    {
        return;
    }
    thread WideGroup_0 _S1120 = _S1106;
    Rigid_0 _S1121 = wide_rigid_frame_0(tid_13, &_S1107, &_S1120, &kernelContext_72);
    thread Rigid_0 rg_15 = _S1121;
    if(tid_13 != 0U)
    {
        return;
    }
    if(!((_S1108 & 2U) != 0U))
    {
        integrate_rigid_0(&_S1107, &rg_15, (&kernelContext_72)->params_0->dt_0);
        drift_rigid_0(&_S1107, &rg_15, tr_6, phi_5, dv_6, dw_4);
    }
    thread Quat_0 _S1122 = (&rg_15)->rot_0;
    float4 _S1123 = quat_vec_0(&_S1122);
    ((&kernelContext_72)->islands_0+_S1106.island_3)->rotation_0 = packed_float4(_S1123) ;
    ((&kernelContext_72)->islands_0+_S1106.island_3)->rotation_err_0 = packed_float4((&rg_15)->rot_err_0) ;
    ((&kernelContext_72)->islands_0+_S1106.island_3)->position_0 = packed_float4(float4((&rg_15)->pos_1, 0.0f)) ;
    ((&kernelContext_72)->islands_0+_S1106.island_3)->position_err_0 = packed_float4(float4((&rg_15)->pos_err_1, 0.0f)) ;
    ((&kernelContext_72)->islands_0+_S1106.island_3)->velocity_0 = packed_float4(float4((&rg_15)->vel_1, 0.0f)) ;
    ((&kernelContext_72)->islands_0+_S1106.island_3)->velocity_err_0 = packed_float4(float4((&rg_15)->vel_err_1, 0.0f)) ;
    ((&kernelContext_72)->islands_0+_S1106.island_3)->angular_velocity_0 = packed_float4(float4((&rg_15)->w_4, 0.0f)) ;
    ((&kernelContext_72)->islands_0+_S1106.island_3)->momentum_0 = packed_float4(float4((&rg_15)->l_2, 0.0f)) ;
    ((&kernelContext_72)->islands_0+_S1106.island_3)->momentum_err_0 = packed_float4(float4((&rg_15)->l_err_1, 0.0f)) ;
    return;
}

[[kernel]] void wide_end(uint3 group_8 [[threadgroup_position_in_grid]], uint3 thread_8 [[thread_position_in_threadgroup]], Params_0 constant* params_12 [[buffer(0)]], Island_natural_0 device* islands_12 [[buffer(9)]], uint device* index_12 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_12 [[buffer(3)]], packed_float4 device* state_14 [[buffer(6)]], packed_float4 device* scratch_12 [[buffer(8)]], packed_float4 device* contact_state_12 [[buffer(11)]], packed_float4 device* loads_12 [[buffer(5)]], Impactor_natural_0 device* impactors_12 [[buffer(10)]], BondStatic_natural_0 device* bonds_12 [[buffer(2)]], MaterialTable_0 constant* materials_12 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_12 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_73;
    (&kernelContext_73)->params_0 = params_12;
    (&kernelContext_73)->islands_0 = islands_12;
    (&kernelContext_73)->index_0 = index_12;
    (&kernelContext_73)->chunks_0 = chunks_12;
    (&kernelContext_73)->state_0 = state_14;
    (&kernelContext_73)->scratch_0 = scratch_12;
    (&kernelContext_73)->contact_state_0 = contact_state_12;
    (&kernelContext_73)->loads_0 = loads_12;
    (&kernelContext_73)->impactors_0 = impactors_12;
    (&kernelContext_73)->bonds_0 = bonds_12;
    (&kernelContext_73)->materials_0 = materials_12;
    (&kernelContext_73)->bond_dyn_0 = bond_dyn_12;
    threadgroup array<float4, int(32)> g_part_a_12;
    (&kernelContext_73)->g_part_a_0 = &g_part_a_12;
    threadgroup array<float4, int(32)> g_part_b_12;
    (&kernelContext_73)->g_part_b_0 = &g_part_b_12;
    threadgroup array<uint, int(5)> g_seen_12;
    (&kernelContext_73)->g_seen_0 = &g_seen_12;
    threadgroup uint g_run_12;
    (&kernelContext_73)->g_run_0 = &g_run_12;
    threadgroup uint g_halt_12;
    (&kernelContext_73)->g_halt_0 = &g_halt_12;
    threadgroup uint g_wide_run_12;
    (&kernelContext_73)->g_wide_run_0 = &g_wide_run_12;
    uint tid_14 = thread_8.x;
    uint _S1124 = group_8.x;
    WideGroup_0 _S1125 = wide_group_0(params_12->wide_chunk_table_0, _S1124, &kernelContext_73);
    if(_S1124 != (_S1125.first_0))
    {
        return;
    }
    Island_natural_0 device* _S1126 = (&kernelContext_73)->islands_0+_S1125.island_3;
    thread Island_natural_0 _S1127 = *_S1126;
    uint4 _S1128 = uint4((&_S1127)->info_0) ;
    float4 _S1129 = float4((&_S1127)->com_0) ;
    float4 _S1130 = float4((&_S1127)->inertia0_0) ;
    float4 _S1131 = float4((&_S1127)->inertia1_0) ;
    float4 _S1132 = float4((&_S1127)->inertia2_0) ;
    float4 _S1133 = float4((&_S1127)->inv0_0) ;
    float4 _S1134 = float4((&_S1127)->inv1_0) ;
    float4 _S1135 = float4((&_S1127)->inv2_0) ;
    float4 _S1136 = float4((&_S1127)->wcom_0) ;
    float4 _S1137 = float4((&_S1127)->winv0_0) ;
    float4 _S1138 = float4((&_S1127)->winv1_0) ;
    float4 _S1139 = float4((&_S1127)->winv2_0) ;
    float4 _S1140 = float4((&_S1127)->rotation_0) ;
    float4 _S1141 = float4((&_S1127)->position_0) ;
    float4 _S1142 = float4((&_S1127)->position_err_0) ;
    float4 _S1143 = float4((&_S1127)->velocity_0) ;
    float4 _S1144 = float4((&_S1127)->velocity_err_0) ;
    float4 _S1145 = float4((&_S1127)->angular_velocity_0) ;
    uint4 _S1146 = uint4((&_S1127)->probes_0) ;
    float4 _S1147 = float4((&_S1127)->energy_0) ;
    float4 _S1148 = float4((&_S1127)->rotation_err_0) ;
    float4 _S1149 = float4((&_S1127)->momentum_0) ;
    float4 _S1150 = float4((&_S1127)->momentum_err_0) ;
    thread Island_0 isl_22;
    (&isl_22)->range_0 = uint4((&_S1127)->range_0) ;
    (&isl_22)->info_0 = _S1128;
    (&isl_22)->com_0 = _S1129;
    (&isl_22)->inertia0_0 = _S1130;
    (&isl_22)->inertia1_0 = _S1131;
    (&isl_22)->inertia2_0 = _S1132;
    (&isl_22)->inv0_0 = _S1133;
    (&isl_22)->inv1_0 = _S1134;
    (&isl_22)->inv2_0 = _S1135;
    (&isl_22)->wcom_0 = _S1136;
    (&isl_22)->winv0_0 = _S1137;
    (&isl_22)->winv1_0 = _S1138;
    (&isl_22)->winv2_0 = _S1139;
    (&isl_22)->rotation_0 = _S1140;
    (&isl_22)->position_0 = _S1141;
    (&isl_22)->position_err_0 = _S1142;
    (&isl_22)->velocity_0 = _S1143;
    (&isl_22)->velocity_err_0 = _S1144;
    (&isl_22)->angular_velocity_0 = _S1145;
    (&isl_22)->done_0 = (&_S1127)->done_0;
    (&isl_22)->coverage_0 = (&_S1127)->coverage_0;
    (&isl_22)->wide_groups_0 = (&_S1127)->wide_groups_0;
    (&isl_22)->done_pad_0 = (&_S1127)->done_pad_0;
    (&isl_22)->probes_0 = _S1146;
    (&isl_22)->energy_0 = _S1147;
    (&isl_22)->rotation_err_0 = _S1148;
    (&isl_22)->momentum_0 = _S1149;
    (&isl_22)->momentum_err_0 = _S1150;
    _S1127 = *_S1126;
    bool _S1151 = wide_enter_0(tid_14, &_S1127, &kernelContext_73);
    if(!_S1151)
    {
        return;
    }
    thread float3 work_5;
    thread float3 flags_2;
    wide_partials_0(tid_14, _S1125.first_0, (&isl_22)->wide_groups_0, 6U, &work_5, &flags_2, &kernelContext_73);
    if(tid_14 != 0U)
    {
        return;
    }
    thread Island_0 _S1152 = isl_22;
    uint _S1153 = wide_step_1(&_S1152, &kernelContext_73);
    if(((&isl_22)->probes_0.y) > ((&isl_22)->probes_0.x))
    {
        thread Island_0 _S1154 = isl_22;
        Rigid_0 _S1155 = rigid_of_1(&_S1154);
        thread Island_0 _S1156 = isl_22;
        thread Rigid_0 _S1157 = _S1155;
        record_probes_0(&_S1156, &_S1157, _S1153, &kernelContext_73);
    }
    bool halt_0 = (((&isl_22)->info_0.z) & 2U) != 0U;
    bool _S1158;
    if(halt_0)
    {
        _S1158 = (((&isl_22)->info_0.x) & 4U) != 0U;
    }
    else
    {
        _S1158 = false;
    }
    if(_S1158)
    {
        contact_split_at_0((&isl_22)->info_0.w + 1U, &kernelContext_73);
    }
    float _S1159 = work_5.x;
    thread float _S1160 = (&isl_22)->energy_0.x;
    thread float _S1161 = (&isl_22)->energy_0.y;
    comp_add1_0(&_S1160, &_S1161, _S1159);
    (&isl_22)->energy_0.x = _S1160;
    (&isl_22)->energy_0.y = _S1161 + work_5.y;
    (&isl_22)->done_0 = (&isl_22)->done_0 + 1U;
    (&isl_22)->info_0.y = (&isl_22)->info_0.y - 1U;
    (&isl_22)->info_0.w = (&isl_22)->info_0.w + 1U;
    if(halt_0)
    {
        (&isl_22)->info_0.z = (((&isl_22)->info_0.z) & 4294967293U) | 1U;
    }
    uint _S1162;
    if(halt_0)
    {
        _S1162 = 128U;
    }
    else
    {
        _S1162 = 0U;
    }
    uint _S1163 = 256U | _S1162;
    if(((&isl_22)->probes_0.y) > ((&isl_22)->probes_0.x))
    {
        _S1162 = 262144U;
    }
    else
    {
        _S1162 = 0U;
    }
    uint _S1164 = _S1163 | _S1162;
    if((((&isl_22)->info_0.x) & 4U) != 0U)
    {
        _S1162 = 524288U;
    }
    else
    {
        _S1162 = 0U;
    }
    uint _S1165 = _S1164 | _S1162;
    if((flags_2.x) > 0.0f)
    {
        _S1162 = 32768U;
    }
    else
    {
        _S1162 = 0U;
    }
    uint _S1166 = _S1165 | _S1162;
    if((flags_2.y) > 0.0f)
    {
        _S1162 = 65536U;
    }
    else
    {
        _S1162 = 0U;
    }
    uint _S1167 = _S1166 | _S1162;
    if((flags_2.z) > 0.0f)
    {
        _S1162 = 131072U;
    }
    else
    {
        _S1162 = 0U;
    }
    (&isl_22)->coverage_0 = ((&isl_22)->coverage_0) | (_S1167 | _S1162);
    Island_natural_0 device* _S1168 = (&kernelContext_73)->islands_0+_S1125.island_3;
    _S1168->range_0 = packed_uint4(isl_22.range_0) ;
    _S1168->info_0 = packed_uint4(isl_22.info_0) ;
    _S1168->com_0 = packed_float4(isl_22.com_0) ;
    _S1168->inertia0_0 = packed_float4(isl_22.inertia0_0) ;
    _S1168->inertia1_0 = packed_float4(isl_22.inertia1_0) ;
    _S1168->inertia2_0 = packed_float4(isl_22.inertia2_0) ;
    _S1168->inv0_0 = packed_float4(isl_22.inv0_0) ;
    _S1168->inv1_0 = packed_float4(isl_22.inv1_0) ;
    _S1168->inv2_0 = packed_float4(isl_22.inv2_0) ;
    _S1168->wcom_0 = packed_float4(isl_22.wcom_0) ;
    _S1168->winv0_0 = packed_float4(isl_22.winv0_0) ;
    _S1168->winv1_0 = packed_float4(isl_22.winv1_0) ;
    _S1168->winv2_0 = packed_float4(isl_22.winv2_0) ;
    _S1168->rotation_0 = packed_float4(isl_22.rotation_0) ;
    _S1168->position_0 = packed_float4(isl_22.position_0) ;
    _S1168->position_err_0 = packed_float4(isl_22.position_err_0) ;
    _S1168->velocity_0 = packed_float4(isl_22.velocity_0) ;
    _S1168->velocity_err_0 = packed_float4(isl_22.velocity_err_0) ;
    _S1168->angular_velocity_0 = packed_float4(isl_22.angular_velocity_0) ;
    _S1168->done_0 = isl_22.done_0;
    _S1168->coverage_0 = isl_22.coverage_0;
    _S1168->wide_groups_0 = isl_22.wide_groups_0;
    _S1168->done_pad_0 = isl_22.done_pad_0;
    _S1168->probes_0 = packed_uint4(isl_22.probes_0) ;
    _S1168->energy_0 = packed_float4(isl_22.energy_0) ;
    _S1168->rotation_err_0 = packed_float4(isl_22.rotation_err_0) ;
    _S1168->momentum_0 = packed_float4(isl_22.momentum_0) ;
    _S1168->momentum_err_0 = packed_float4(isl_22.momentum_err_0) ;
    return;
}

uint sv_0(uint c_28, uint slot_3, KernelContext_0 thread* kernelContext_74)
{
    return kernelContext_74->params_0->statics_base_0 + 23U * c_28 + slot_3;
}

void project_load_slot_0(uint tid_15, const Island_natural_0 thread* isl_23, uint slot_4, KernelContext_0 thread* kernelContext_75)
{
    uint _S1169;
    float3 _S1170 = float3(0.0f) ;
    thread float3 net_f_0 = _S1170;
    thread float3 net_m_0 = _S1170;
    uint4 _S1171 = uint4(isl_23->range_0) ;
    uint _S1172 = _S1171.x + tid_15;
    uint c_29 = _S1172;
    for(;;)
    {
        uint _S1173 = _S1171.y;
        _S1169 = _S1173;
        if(c_29 < _S1173)
        {
        }
        else
        {
            break;
        }
        uint _S1174 = sv_0(c_29, slot_4, kernelContext_75);
        float3 fi_2 = (float4(*(kernelContext_75->scratch_0+_S1174)) ).xyz;
        net_f_0 = net_f_0 + fi_2;
        float3 _S1175 = cross((float4((kernelContext_75->chunks_0+c_29)->center_0) ).xyz - (float4(isl_23->com_0) ).xyz, fi_2);
        uint _S1176 = sv_0(c_29, slot_4 + 1U, kernelContext_75);
        net_m_0 = net_m_0 + (_S1175 + (float4(*(kernelContext_75->scratch_0+_S1176)) ).xyz);
        c_29 = c_29 + 256U;
    }
    group_sum3_0(tid_15, &net_f_0, &net_m_0, kernelContext_75);
    float4 _S1177 = float4(isl_23->com_0) ;
    float3 _S1178 = net_f_0 / float3(_S1177.w) ;
    float3 _S1179 = rows_mul_0(float4(isl_23->inv0_0) , float4(isl_23->inv1_0) , float4(isl_23->inv2_0) , net_m_0);
    c_29 = _S1172;
    for(;;)
    {
        if(c_29 < _S1169)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_natural_0 device* _S1180 = kernelContext_75->chunks_0+c_29;
        float4 _S1181 = float4(_S1180->center_0) ;
        float3 r_12 = _S1181.xyz - _S1177.xyz;
        uint _S1182 = sv_0(c_29, slot_4, kernelContext_75);
        *(kernelContext_75->scratch_0+_S1182) = packed_float4(float4((float4(*(kernelContext_75->scratch_0+_S1182)) ).xyz - (_S1178 + cross(_S1179, r_12)) * float3(_S1181.w) , 0.0f)) ;
        uint _S1183 = sv_0(c_29, slot_4 + 1U, kernelContext_75);
        *(kernelContext_75->scratch_0+_S1183) = packed_float4(float4((float4(*(kernelContext_75->scratch_0+_S1183)) ).xyz - rows_mul_0(float4(_S1180->inertia0_1) , float4(_S1180->inertia1_1) , float4(_S1180->inertia2_1) , _S1179), 0.0f)) ;
        c_29 = c_29 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    return;
}

float island_dot_0(uint tid_16, uint c0_0, uint c1_0, uint sa_2, uint sb_2, KernelContext_0 thread* kernelContext_76)
{
    float4 _S1184 = float4(0.0f) ;
    thread float4 acc_0 = _S1184;
    thread float4 unused_4 = _S1184;
    uint c_30 = c0_0 + tid_16;
    for(;;)
    {
        if(c_30 < c1_0)
        {
        }
        else
        {
            break;
        }
        uint _S1185 = sv_0(c_30, sa_2, kernelContext_76);
        float3 _S1186 = (float4(*(kernelContext_76->scratch_0+_S1185)) ).xyz;
        uint _S1187 = sv_0(c_30, sb_2, kernelContext_76);
        float _S1188 = dot(_S1186, (float4(*(kernelContext_76->scratch_0+_S1187)) ).xyz);
        uint _S1189 = sv_0(c_30, sa_2 + 1U, kernelContext_76);
        float3 _S1190 = (float4(*(kernelContext_76->scratch_0+_S1189)) ).xyz;
        uint _S1191 = sv_0(c_30, sb_2 + 1U, kernelContext_76);
        acc_0.x = acc_0.x + (_S1188 + dot(_S1190, (float4(*(kernelContext_76->scratch_0+_S1191)) ).xyz));
        c_30 = c_30 + 256U;
    }
    group_sum2_0(tid_16, &acc_0, &unused_4, kernelContext_76);
    return acc_0.x;
}

void static_kinematics_0(uint _S1192, float3 thread* _S1193, float3 thread* _S1194, KernelContext_0 thread* kernelContext_77)
{
    BondStatic_natural_0 device* _S1195 = kernelContext_77->bonds_0+_S1192;
    uint4 _S1196 = uint4(_S1195->law_0.ids_0) ;
    uint ca_1 = _S1196.y;
    uint cb_1 = _S1196.z;
    uint _S1197 = 4U * cb_1;
    uint _S1198 = 4U * ca_1;
    float3 _S1199 = (float4(*(kernelContext_77->state_0+_S1197)) ).xyz - (float4(*(kernelContext_77->state_0+_S1198)) ).xyz;
    uint _S1200 = sv_0(cb_1, 21U, kernelContext_77);
    float3 _S1201 = (float4(*(kernelContext_77->scratch_0+_S1200)) ).xyz;
    uint _S1202 = sv_0(ca_1, 21U, kernelContext_77);
    float3 du_0 = _S1199 + (_S1201 - (float4(*(kernelContext_77->scratch_0+_S1202)) ).xyz);
    uint _S1203 = _S1197 + 1U;
    uint _S1204 = _S1198 + 1U;
    float3 _S1205 = (float4(*(kernelContext_77->state_0+_S1203)) ).xyz - (float4(*(kernelContext_77->state_0+_S1204)) ).xyz;
    uint _S1206 = sv_0(cb_1, 22U, kernelContext_77);
    float3 _S1207 = (float4(*(kernelContext_77->scratch_0+_S1206)) ).xyz;
    uint _S1208 = sv_0(ca_1, 22U, kernelContext_77);
    float3 dth_0 = _S1205 + (_S1207 - (float4(*(kernelContext_77->scratch_0+_S1208)) ).xyz);
    float3 _S1209 = to_local_0(_S1192, du_0 + (cross((float4(*(kernelContext_77->state_0+_S1203)) ).xyz + (float4(*(kernelContext_77->scratch_0+_S1206)) ).xyz, (float4(_S1195->rb_0) ).xyz) - cross((float4(*(kernelContext_77->state_0+_S1204)) ).xyz + (float4(*(kernelContext_77->scratch_0+_S1208)) ).xyz, (float4(_S1195->ra_0) ).xyz)), kernelContext_77);
    *_S1193 = _S1209;
    float3 _S1210 = to_local_0(_S1192, dth_0, kernelContext_77);
    *_S1194 = _S1210;
    return;
}

JointResponse_0 static_response_0(uint i_12, KernelContext_0 thread* kernelContext_78)
{
    BondStatic_natural_0 device* _S1211 = kernelContext_78->bonds_0+i_12;
    thread float3 d_lin_4;
    thread float3 d_ang_3;
    static_kinematics_0(i_12, &d_lin_4, &d_ang_3, kernelContext_78);
    thread JointBond_natural_0 _S1212 = _S1211->law_0;
    _S1212 = _S1211->law_0;
    thread JointState_0 _S1213 = (kernelContext_78->bond_dyn_0+i_12)->js_0;
    JointResponse_0 _S1214 = joint_evaluate_0(&kernelContext_78->materials_0->m_0[(uint4((&_S1212)->ids_0) ).x], &_S1212, &_S1213, d_lin_4, d_ang_3, 0.0f, false);
    return _S1214;
}

void gather_loads_0(uint c_31, float3 thread* fi_3, float3 thread* mi_6, KernelContext_0 thread* kernelContext_79)
{
    float3 _S1215 = float3(0.0f) ;
    *fi_3 = _S1215;
    *mi_6 = _S1215;
    uint e_5 = kernelContext_79->index_0[c_31];
    for(;;)
    {
        if(e_5 < (kernelContext_79->index_0)[c_31 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_4 = kernelContext_79->index_0[e_5];
        uint bond_0 = entry_4 >> 1U;
        if((entry_4 & 1U) == 0U)
        {
            uint _S1216 = 3U * bond_0;
            *fi_3 = *fi_3 + (float4(*(kernelContext_79->scratch_0+_S1216)) ).xyz;
            *mi_6 = *mi_6 + (float4(*(kernelContext_79->scratch_0+(_S1216 + 1U))) ).xyz;
        }
        else
        {
            uint _S1217 = 3U * bond_0;
            *fi_3 = *fi_3 - (float4(*(kernelContext_79->scratch_0+_S1217)) ).xyz;
            *mi_6 = *mi_6 + (float4(*(kernelContext_79->scratch_0+(_S1217 + 2U))) ).xyz;
        }
        e_5 = e_5 + 1U;
    }
    return;
}

float bond_load_magnitude2_0(uint c_32, KernelContext_0 thread* kernelContext_80)
{
    uint e_6 = kernelContext_80->index_0[c_32];
    float m_7 = 0.0f;
    for(;;)
    {
        if(e_6 < (kernelContext_80->index_0)[c_32 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_5 = kernelContext_80->index_0[e_6];
        uint _S1218 = 3U * (entry_5 >> 1U);
        float3 f_18 = (float4(*(kernelContext_80->scratch_0+_S1218)) ).xyz;
        float3 t_18;
        if((entry_5 & 1U) == 0U)
        {
            t_18 = (float4(*(kernelContext_80->scratch_0+(_S1218 + 1U))) ).xyz;
        }
        else
        {
            t_18 = (float4(*(kernelContext_80->scratch_0+(_S1218 + 2U))) ).xyz;
        }
        float m_8 = m_7 + (dot(f_18, f_18) + dot(t_18, t_18));
        e_6 = e_6 + 1U;
        m_7 = m_8;
    }
    return m_7;
}

uint fixed_mask_0(uint c_33, KernelContext_0 thread* kernelContext_81)
{
    uint support_2 = (uint4((kernelContext_81->chunks_0+c_33)->info_1) ).x;
    uint _S1219;
    if(support_2 == 1U)
    {
        _S1219 = 63U;
    }
    else
    {
        if(support_2 == 2U)
        {
            _S1219 = 7U;
        }
        else
        {
            _S1219 = 0U;
        }
    }
    return _S1219;
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

uint statics_bond_slot_0(uint i_13, KernelContext_0 thread* kernelContext_82)
{
    return kernelContext_82->params_0->statics_base_0 + 23U * kernelContext_82->params_0->chunk_count_0 + 2U * i_13;
}

void store_inverse_0(uint c_34, const array<float, int(36)> thread* a_14, KernelContext_0 thread* kernelContext_83)
{
    uint j_8;
    float sum_4;
    thread array<float, int(36)> l_5;
    uint k_21 = 0U;
    for(;;)
    {
        if(k_21 < 36U)
        {
        }
        else
        {
            break;
        }
        l_5[k_21] = 0.0f;
        k_21 = k_21 + 1U;
    }
    bool spd_0 = true;
    uint i_14 = 0U;
    for(;;)
    {
        bool _S1220;
        if(i_14 < 6U)
        {
            _S1220 = spd_0;
        }
        else
        {
            _S1220 = false;
        }
        if(_S1220)
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
            uint _S1221 = i_14 * 6U;
            uint _S1222 = _S1221 + j_8;
            k_21 = 0U;
            sum_4 = (*a_14)[_S1222];
            for(;;)
            {
                if(k_21 < j_8)
                {
                }
                else
                {
                    break;
                }
                float sum_5 = sum_4 - l_5[_S1221 + k_21] * l_5[j_8 * 6U + k_21];
                k_21 = k_21 + 1U;
                sum_4 = sum_5;
            }
            if(i_14 == j_8)
            {
                if(sum_4 <= 0.0f)
                {
                    spd_0 = false;
                    break;
                }
                l_5[_S1221 + i_14] = sqrt(sum_4);
            }
            else
            {
                l_5[_S1222] = sum_4 / l_5[j_8 * 6U + j_8];
            }
            j_8 = j_8 + 1U;
        }
        i_14 = i_14 + 1U;
    }
    thread array<float, int(36)> inv_0;
    if(!spd_0)
    {
        k_21 = 0U;
        for(;;)
        {
            if(k_21 < 36U)
            {
            }
            else
            {
                break;
            }
            inv_0[k_21] = 0.0f;
            k_21 = k_21 + 1U;
        }
        k_21 = 0U;
        for(;;)
        {
            if(k_21 < 6U)
            {
            }
            else
            {
                break;
            }
            uint _S1223 = k_21 * 6U + k_21;
            float _S1224 = (*a_14)[_S1223];
            if(((*a_14)[_S1223]) > 0.0f)
            {
                sum_4 = 1.0f / _S1224;
            }
            else
            {
                sum_4 = 0.0f;
            }
            inv_0[_S1223] = sum_4;
            k_21 = k_21 + 1U;
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
                k_21 = 0U;
                float s_8 = sum_4;
                for(;;)
                {
                    if(k_21 < i_14)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_9 = s_8 - l_5[i_14 * 6U + k_21] * y_3[k_21];
                    k_21 = k_21 + 1U;
                    s_8 = s_9;
                }
                y_3[i_14] = s_8 / l_5[i_14 * 6U + i_14];
                i_14 = i_14 + 1U;
            }
            thread array<float, int(6)> x_15;
            x_15[int(0)] = 0.0f;
            x_15[int(1)] = 0.0f;
            x_15[int(2)] = 0.0f;
            x_15[int(3)] = 0.0f;
            x_15[int(4)] = 0.0f;
            x_15[int(5)] = 0.0f;
            uint ii_2 = 0U;
            for(;;)
            {
                if(ii_2 < 6U)
                {
                }
                else
                {
                    break;
                }
                uint i_15 = 5U - ii_2;
                k_21 = i_15 + 1U;
                sum_4 = y_3[i_15];
                for(;;)
                {
                    if(k_21 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_10 = sum_4 - l_5[k_21 * 6U + i_15] * x_15[k_21];
                    k_21 = k_21 + 1U;
                    sum_4 = s_10;
                }
                x_15[i_15] = sum_4 / l_5[i_15 * 6U + i_15];
                ii_2 = ii_2 + 1U;
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
        uint _S1225 = sv_0(c_34, 12U + j_8, kernelContext_83);
        uint _S1226 = 4U * j_8;
        *(kernelContext_83->scratch_0+_S1225) = packed_float4(float4(inv_0[_S1226], inv_0[_S1226 + 1U], inv_0[_S1226 + 2U], inv_0[_S1226 + 3U])) ;
        j_8 = j_8 + 1U;
    }
    return;
}

void assemble_block_0(uint c_35, KernelContext_0 thread* kernelContext_84)
{
    uint p_16;
    uint r_13;
    thread array<float, int(36)> a_15;
    uint k_22 = 0U;
    for(;;)
    {
        if(k_22 < 36U)
        {
        }
        else
        {
            break;
        }
        a_15[k_22] = 0.0f;
        k_22 = k_22 + 1U;
    }
    uint e_7 = kernelContext_84->index_0[c_35];
    for(;;)
    {
        if(e_7 < (kernelContext_84->index_0)[c_35 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_6 = kernelContext_84->index_0[e_7];
        uint i_17 = entry_6 >> 1U;
        bool _S1227 = (entry_6 & 1U) != 0U;
        BondStatic_natural_0 device* _S1228 = kernelContext_84->bonds_0+i_17;
        uint _S1229 = statics_bond_slot_0(i_17, kernelContext_84);
        float4 _S1230 = float4(*(kernelContext_84->scratch_0+_S1229)) ;
        float4 _S1231 = float4(*(kernelContext_84->scratch_0+(_S1229 + 1U))) ;
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
            uint _S1232 = p_16 % 3U;
            float3 t_19;
            if(_S1232 == 0U)
            {
                t_19 = (float4(_S1228->t1_0) ).xyz;
            }
            else
            {
                if(_S1232 == 1U)
                {
                    t_19 = (float4(_S1228->t2_0) ).xyz;
                }
                else
                {
                    t_19 = (float4(_S1228->normal_0) ).xyz;
                }
            }
            bool _S1233 = p_16 < 3U;
            float3 row_u_0;
            float3 row_t_0;
            if(_S1233)
            {
                if(_S1227)
                {
                    row_u_0 = t_19;
                }
                else
                {
                    row_u_0 = - t_19;
                }
                if(_S1227)
                {
                    row_t_0 = cross((float4(_S1228->rb_0) ).xyz, t_19);
                }
                else
                {
                    row_t_0 = - cross((float4(_S1228->ra_0) ).xyz, t_19);
                }
            }
            else
            {
                float3 _S1234 = float3(0.0f) ;
                if(_S1227)
                {
                    row_u_0 = t_19;
                }
                else
                {
                    row_u_0 = - t_19;
                }
                float3 _S1235 = row_u_0;
                row_u_0 = _S1234;
                row_t_0 = _S1235;
            }
            float kp_0;
            if(_S1233)
            {
                kp_0 = _S1230[p_16];
            }
            else
            {
                kp_0 = _S1231[p_16 - 3U];
            }
            if(kp_0 == 0.0f)
            {
                p_16 = p_16 + 1U;
                continue;
            }
            array<float, int(6)> _S1236 = { { row_u_0.x, row_u_0.y, row_u_0.z, row_t_0.x, row_t_0.y, row_t_0.z } };
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
                uint q_15 = 0U;
                for(;;)
                {
                    if(q_15 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    a_15[r_13 * 6U + q_15] = a_15[r_13 * 6U + q_15] + kp_0 * _S1236[r_13] * _S1236[q_15];
                    q_15 = q_15 + 1U;
                }
                r_13 = r_13 + 1U;
            }
            p_16 = p_16 + 1U;
        }
        e_7 = e_7 + 1U;
    }
    uint _S1237 = fixed_mask_0(c_35, kernelContext_84);
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
        if((_S1237 & (1U << p_16)) != 0U)
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
    thread array<float, int(36)> _S1238 = a_15;
    store_inverse_0(c_35, &_S1238, kernelContext_84);
    return;
}

float block_get_0(uint c_36, uint i_18, uint j_9, KernelContext_0 thread* kernelContext_85)
{
    uint k_23 = i_18 * 6U + j_9;
    uint _S1239 = sv_0(c_36, 12U + k_23 / 4U, kernelContext_85);
    return (*(kernelContext_85->scratch_0+_S1239))[k_23 % 4U];
}

void precondition_0(uint c_37, KernelContext_0 thread* kernelContext_86)
{
    uint _S1240 = sv_0(c_37, 4U, kernelContext_86);
    float4 _S1241 = float4(*(kernelContext_86->scratch_0+_S1240)) ;
    uint _S1242 = sv_0(c_37, 5U, kernelContext_86);
    float4 _S1243 = float4(*(kernelContext_86->scratch_0+_S1242)) ;
    array<float, int(6)> _S1244 = { { _S1241.x, _S1241.y, _S1241.z, _S1243.x, _S1243.y, _S1243.z } };
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
        float s_11 = 0.0f;
        for(;;)
        {
            if(j_10 < 6U)
            {
            }
            else
            {
                break;
            }
            float _S1245 = block_get_0(c_37, i_19, j_10, kernelContext_86);
            float s_12 = s_11 + _S1245 * _S1244[j_10];
            j_10 = j_10 + 1U;
            s_11 = s_12;
        }
        z_1[i_19] = s_11;
        i_19 = i_19 + 1U;
    }
    uint _S1246 = sv_0(c_37, 6U, kernelContext_86);
    *(kernelContext_86->scratch_0+_S1246) = packed_float4(float4(z_1[int(0)], z_1[int(1)], z_1[int(2)], 0.0f)) ;
    uint _S1247 = sv_0(c_37, 7U, kernelContext_86);
    *(kernelContext_86->scratch_0+_S1247) = packed_float4(float4(z_1[int(3)], z_1[int(4)], z_1[int(5)], 0.0f)) ;
    return;
}

void project_displacement_slot_0(uint tid_17, const Island_natural_0 thread* isl_24, uint slot_5, KernelContext_0 thread* kernelContext_87)
{
    uint _S1248;
    float3 _S1249 = float3(0.0f) ;
    thread float3 p_17 = _S1249;
    thread float3 l_6 = _S1249;
    uint4 _S1250 = uint4(isl_24->range_0) ;
    uint _S1251 = _S1250.x + tid_17;
    uint c_38 = _S1251;
    for(;;)
    {
        uint _S1252 = _S1250.y;
        _S1248 = _S1252;
        if(c_38 < _S1252)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_natural_0 device* _S1253 = kernelContext_87->chunks_0+c_38;
        uint _S1254 = sv_0(c_38, slot_5, kernelContext_87);
        float3 u_6 = (float4(*(kernelContext_87->scratch_0+_S1254)) ).xyz;
        uint _S1255 = sv_0(c_38, slot_5 + 1U, kernelContext_87);
        float3 th_8 = (float4(*(kernelContext_87->scratch_0+_S1255)) ).xyz;
        float4 _S1256 = float4(_S1253->center_0) ;
        float3 r_14 = _S1256.xyz - (float4(isl_24->com_0) ).xyz;
        float3 _S1257 = float3(_S1256.w) ;
        p_17 = p_17 + u_6 * _S1257;
        l_6 = l_6 + (cross(r_14, u_6) * _S1257 + rows_mul_0(float4(_S1253->inertia0_1) , float4(_S1253->inertia1_1) , float4(_S1253->inertia2_1) , th_8));
        c_38 = c_38 + 256U;
    }
    group_sum3_0(tid_17, &p_17, &l_6, kernelContext_87);
    float4 _S1258 = float4(isl_24->com_0) ;
    float3 _S1259 = p_17 / float3(_S1258.w) ;
    float3 _S1260 = rows_mul_0(float4(isl_24->inv0_0) , float4(isl_24->inv1_0) , float4(isl_24->inv2_0) , l_6);
    c_38 = _S1251;
    for(;;)
    {
        if(c_38 < _S1248)
        {
        }
        else
        {
            break;
        }
        float3 r_15 = (float4((kernelContext_87->chunks_0+c_38)->center_0) ).xyz - _S1258.xyz;
        uint _S1261 = sv_0(c_38, slot_5, kernelContext_87);
        *(kernelContext_87->scratch_0+_S1261) = packed_float4(float4((float4(*(kernelContext_87->scratch_0+_S1261)) ).xyz - _S1259 - cross(_S1260, r_15), 0.0f)) ;
        uint _S1262 = sv_0(c_38, slot_5 + 1U, kernelContext_87);
        *(kernelContext_87->scratch_0+_S1262) = packed_float4(float4((float4(*(kernelContext_87->scratch_0+_S1262)) ).xyz - _S1260, 0.0f)) ;
        c_38 = c_38 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    return;
}

uint statics_result_slot_0(uint island_4, KernelContext_0 thread* kernelContext_88)
{
    return kernelContext_88->params_0->statics_base_0 + 23U * kernelContext_88->params_0->chunk_count_0 + 2U * kernelContext_88->params_0->statics_bonds_0 + island_4;
}

void write_bond_loads_0(uint _S1263, uint _S1264, float3 _S1265, float3 _S1266, float _S1267, KernelContext_0 thread* kernelContext_89)
{
    BondStatic_natural_0 device* _S1268 = kernelContext_89->bonds_0+_S1264;
    float3 _S1269 = to_body_0(_S1264, _S1265, kernelContext_89);
    float3 _S1270 = to_body_0(_S1264, _S1266, kernelContext_89);
    uint _S1271 = 3U * _S1263;
    *(kernelContext_89->scratch_0+_S1271) = packed_float4(float4(_S1269, _S1267)) ;
    *(kernelContext_89->scratch_0+(_S1271 + 1U)) = packed_float4(float4(_S1270 + cross((float4(_S1268->ra_0) ).xyz, _S1269), 0.0f)) ;
    *(kernelContext_89->scratch_0+(_S1271 + 2U)) = packed_float4(float4(- _S1270 + cross((float4(_S1268->rb_0) ).xyz, - _S1269), 0.0f)) ;
    return;
}

void bond_kinematics_0(uint _S1272, float3 _S1273, float3 _S1274, float3 _S1275, float3 _S1276, float3 thread* _S1277, float3 thread* _S1278, KernelContext_0 thread* kernelContext_90)
{
    BondStatic_natural_0 device* _S1279 = kernelContext_90->bonds_0+_S1272;
    float3 _S1280 = to_local_0(_S1272, _S1275 + cross(_S1276, (float4(_S1279->rb_0) ).xyz) - (_S1273 + cross(_S1274, (float4(_S1279->ra_0) ).xyz)), kernelContext_90);
    *_S1277 = _S1280;
    float3 _S1281 = to_local_0(_S1272, _S1276 - _S1274, kernelContext_90);
    *_S1278 = _S1281;
    return;
}

[[kernel]] void island_statics(uint3 group_9 [[threadgroup_position_in_grid]], uint3 thread_9 [[thread_position_in_threadgroup]], Params_0 constant* params_13 [[buffer(0)]], Island_natural_0 device* islands_13 [[buffer(9)]], uint device* index_13 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_13 [[buffer(3)]], packed_float4 device* state_15 [[buffer(6)]], packed_float4 device* scratch_13 [[buffer(8)]], packed_float4 device* contact_state_13 [[buffer(11)]], packed_float4 device* loads_13 [[buffer(5)]], Impactor_natural_0 device* impactors_13 [[buffer(10)]], BondStatic_natural_0 device* bonds_13 [[buffer(2)]], MaterialTable_0 constant* materials_13 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_13 [[buffer(7)]])
{
    uint i_20;
    bool converged_0;
    uint c_39;
    thread KernelContext_0 kernelContext_91;
    (&kernelContext_91)->params_0 = params_13;
    (&kernelContext_91)->islands_0 = islands_13;
    (&kernelContext_91)->index_0 = index_13;
    (&kernelContext_91)->chunks_0 = chunks_13;
    (&kernelContext_91)->state_0 = state_15;
    (&kernelContext_91)->scratch_0 = scratch_13;
    (&kernelContext_91)->contact_state_0 = contact_state_13;
    (&kernelContext_91)->loads_0 = loads_13;
    (&kernelContext_91)->impactors_0 = impactors_13;
    (&kernelContext_91)->bonds_0 = bonds_13;
    (&kernelContext_91)->materials_0 = materials_13;
    (&kernelContext_91)->bond_dyn_0 = bond_dyn_13;
    threadgroup array<float4, int(32)> g_part_a_13;
    (&kernelContext_91)->g_part_a_0 = &g_part_a_13;
    threadgroup array<float4, int(32)> g_part_b_13;
    (&kernelContext_91)->g_part_b_0 = &g_part_b_13;
    threadgroup array<uint, int(5)> g_seen_13;
    (&kernelContext_91)->g_seen_0 = &g_seen_13;
    threadgroup uint g_run_13;
    (&kernelContext_91)->g_run_0 = &g_run_13;
    threadgroup uint g_halt_13;
    (&kernelContext_91)->g_halt_0 = &g_halt_13;
    threadgroup uint g_wide_run_13;
    (&kernelContext_91)->g_wide_run_0 = &g_wide_run_13;
    uint tid_18 = thread_9.x;
    uint _S1282 = group_9.x;
    thread Island_natural_0 _S1283 = *(islands_13+_S1282);
    uint4 _S1284 = uint4((&_S1283)->info_0) ;
    uint _S1285 = _S1284.z;
    if((_S1285 & 8U) == 0U)
    {
        return;
    }
    bool free_0 = ((_S1284.x) & 1U) == 0U;
    uint4 _S1286 = uint4((&_S1283)->range_0) ;
    uint c0_1 = _S1286.x;
    uint c1_1 = _S1286.y;
    uint b0_0 = _S1286.z;
    uint _S1287 = _S1286.w;
    uint _S1288 = c0_1 + tid_18;
    uint c_40 = _S1288;
    for(;;)
    {
        if(c_40 < c1_1)
        {
        }
        else
        {
            break;
        }
        uint _S1289 = sv_0(c_40, 21U, &kernelContext_91);
        packed_float4 _S1290 = packed_float4(float4(0.0f) ) ;
        *((&kernelContext_91)->scratch_0+_S1289) = _S1290;
        uint _S1291 = sv_0(c_40, 22U, &kernelContext_91);
        *((&kernelContext_91)->scratch_0+_S1291) = _S1290;
        c_40 = c_40 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    if(free_0)
    {
        project_load_slot_0(tid_18, &_S1283, 0U, &kernelContext_91);
    }
    float _S1292 = island_dot_0(tid_18, c0_1, c1_1, 0U, 0U, &kernelContext_91);
    float _S1293 = max(sqrt(_S1292), 1.00000000317107685e-30f);
    float _S1294 = (&kernelContext_91)->params_0->statics_tol_0;
    uint _S1295 = min((&kernelContext_91)->params_0->statics_cg_0, 20U * (c1_1 - c0_1) * 6U + 200U);
    float previous_2 = 1.00000001504746622e+30f;
    float residual_0 = 0.0f;
    uint newton_0 = 0U;
    uint cg_total_0 = 0U;
    for(;;)
    {
        if(newton_0 < ((&kernelContext_91)->params_0->statics_newton_0))
        {
        }
        else
        {
            converged_0 = false;
            break;
        }
        uint _S1296 = b0_0 + tid_18;
        i_20 = _S1296;
        for(;;)
        {
            if(i_20 < _S1287)
            {
            }
            else
            {
                break;
            }
            JointResponse_0 _S1297 = static_response_0(i_20, &kernelContext_91);
            write_bond_loads_0(i_20, i_20, _S1297.force_lin_1, _S1297.force_ang_1, 0.0f, &kernelContext_91);
            i_20 = i_20 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        float4 _S1298 = float4(0.0f) ;
        thread float4 magnitude_0 = _S1298;
        thread float4 unused_m_0 = _S1298;
        c_40 = _S1288;
        for(;;)
        {
            if(c_40 < c1_1)
            {
            }
            else
            {
                break;
            }
            thread float3 fi_4;
            thread float3 mi_7;
            gather_loads_0(c_40, &fi_4, &mi_7, &kernelContext_91);
            float _S1299 = bond_load_magnitude2_0(c_40, &kernelContext_91);
            magnitude_0.x = magnitude_0.x + _S1299;
            uint _S1300 = sv_0(c_40, 0U, &kernelContext_91);
            thread float4 r_lin_0 = float4((float4(*((&kernelContext_91)->scratch_0+_S1300)) ).xyz + fi_4, 0.0f);
            uint _S1301 = sv_0(c_40, 1U, &kernelContext_91);
            thread float4 r_ang_0 = float4((float4(*((&kernelContext_91)->scratch_0+_S1301)) ).xyz + mi_7, 0.0f);
            uint _S1302 = fixed_mask_0(c_40, &kernelContext_91);
            hold_0(_S1302, &r_lin_0, &r_ang_0, _S1298, _S1298);
            uint _S1303 = sv_0(c_40, 4U, &kernelContext_91);
            *((&kernelContext_91)->scratch_0+_S1303) = packed_float4(r_lin_0) ;
            uint _S1304 = sv_0(c_40, 5U, &kernelContext_91);
            *((&kernelContext_91)->scratch_0+_S1304) = packed_float4(r_ang_0) ;
            c_40 = c_40 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        group_sum2_0(tid_18, &magnitude_0, &unused_m_0, &kernelContext_91);
        if(free_0)
        {
            project_load_slot_0(tid_18, &_S1283, 4U, &kernelContext_91);
        }
        float _S1305 = island_dot_0(tid_18, c0_1, c1_1, 4U, 4U, &kernelContext_91);
        float residual_1 = sqrt(_S1305) / _S1293;
        float _S1306 = max(0.00100000004749745f, 3.83999986297567375e-06f * sqrt(magnitude_0.x) / _S1293);
        if(residual_1 <= _S1294)
        {
            converged_0 = true;
        }
        else
        {
            if(residual_1 <= _S1306)
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
        uint i_21 = _S1296;
        for(;;)
        {
            if(i_21 < _S1287)
            {
            }
            else
            {
                break;
            }
            BondStatic_natural_0 device* _S1307 = (&kernelContext_91)->bonds_0+i_21;
            thread float3 d_lin_5;
            thread float3 d_ang_4;
            static_kinematics_0(i_21, &d_lin_5, &d_ang_4, &kernelContext_91);
            thread JointBond_natural_0 _S1308 = _S1307->law_0;
            thread JointState_0 _S1309 = ((&kernelContext_91)->bond_dyn_0+i_21)->js_0;
            thread float3 f_lin_2;
            thread float3 f_ang_2;
            secant_factors_0(&_S1308, &_S1309, d_lin_5, &f_lin_2, &f_ang_2);
            float4 _S1310 = float4((&_S1308)->stiff0_0) ;
            uint _S1311 = statics_bond_slot_0(i_21, &kernelContext_91);
            float _S1312 = _S1310.y;
            *((&kernelContext_91)->scratch_0+_S1311) = packed_float4(float4(_S1312 * f_lin_2.x, _S1312 * f_lin_2.y, _S1310.x * f_lin_2.z, 0.0f)) ;
            *((&kernelContext_91)->scratch_0+(_S1311 + 1U)) = packed_float4(float4(_S1310.z * f_ang_2.x, _S1310.w * f_ang_2.y, (float4((&_S1308)->stiff1_0) ).x * f_ang_2.z, 0.0f)) ;
            i_21 = i_21 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_41 = _S1288;
        for(;;)
        {
            if(c_41 < c1_1)
            {
            }
            else
            {
                break;
            }
            assemble_block_0(c_41, &kernelContext_91);
            uint _S1313 = sv_0(c_41, 2U, &kernelContext_91);
            packed_float4 _S1314 = packed_float4(_S1298) ;
            *((&kernelContext_91)->scratch_0+_S1313) = _S1314;
            uint _S1315 = sv_0(c_41, 3U, &kernelContext_91);
            *((&kernelContext_91)->scratch_0+_S1315) = _S1314;
            c_41 = c_41 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_42 = _S1288;
        for(;;)
        {
            if(c_42 < c1_1)
            {
            }
            else
            {
                break;
            }
            precondition_0(c_42, &kernelContext_91);
            c_42 = c_42 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        if(free_0)
        {
            project_displacement_slot_0(tid_18, &_S1283, 6U, &kernelContext_91);
        }
        uint c_43 = _S1288;
        for(;;)
        {
            if(c_43 < c1_1)
            {
            }
            else
            {
                break;
            }
            uint _S1316 = sv_0(c_43, 8U, &kernelContext_91);
            packed_float4 device* _S1317 = (&kernelContext_91)->scratch_0+_S1316;
            uint _S1318 = sv_0(c_43, 6U, &kernelContext_91);
            *_S1317 = packed_float4(float4(*((&kernelContext_91)->scratch_0+_S1318)) ) ;
            uint _S1319 = sv_0(c_43, 9U, &kernelContext_91);
            packed_float4 device* _S1320 = (&kernelContext_91)->scratch_0+_S1319;
            uint _S1321 = sv_0(c_43, 7U, &kernelContext_91);
            *_S1320 = packed_float4(float4(*((&kernelContext_91)->scratch_0+_S1321)) ) ;
            c_43 = c_43 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        float _S1322 = island_dot_0(tid_18, c0_1, c1_1, 4U, 6U, &kernelContext_91);
        float _S1323 = island_dot_0(tid_18, c0_1, c1_1, 4U, 4U, &kernelContext_91);
        float _S1324 = sqrt(_S1323);
        float rz_0 = _S1322;
        uint k_24 = 0U;
        uint cg_total_1 = cg_total_0;
        for(;;)
        {
            bool _S1325;
            if(k_24 < _S1295)
            {
                _S1325 = _S1324 > 0.0f;
            }
            else
            {
                _S1325 = false;
            }
            if(_S1325)
            {
            }
            else
            {
                cg_total_0 = cg_total_1;
                break;
            }
            uint i_22 = _S1296;
            for(;;)
            {
                if(i_22 < _S1287)
                {
                }
                else
                {
                    break;
                }
                uint4 _S1326 = uint4(((&kernelContext_91)->bonds_0+i_22)->law_0.ids_0) ;
                uint ca_2 = _S1326.y;
                uint cb_2 = _S1326.z;
                uint _S1327 = sv_0(ca_2, 8U, &kernelContext_91);
                float3 _S1328 = (float4(*((&kernelContext_91)->scratch_0+_S1327)) ).xyz;
                uint _S1329 = sv_0(ca_2, 9U, &kernelContext_91);
                float3 _S1330 = (float4(*((&kernelContext_91)->scratch_0+_S1329)) ).xyz;
                uint _S1331 = sv_0(cb_2, 8U, &kernelContext_91);
                float3 _S1332 = (float4(*((&kernelContext_91)->scratch_0+_S1331)) ).xyz;
                uint _S1333 = sv_0(cb_2, 9U, &kernelContext_91);
                thread float3 d_lin_6;
                thread float3 d_ang_5;
                bond_kinematics_0(i_22, _S1328, _S1330, _S1332, (float4(*((&kernelContext_91)->scratch_0+_S1333)) ).xyz, &d_lin_6, &d_ang_5, &kernelContext_91);
                uint _S1334 = statics_bond_slot_0(i_22, &kernelContext_91);
                write_bond_loads_0(i_22, i_22, d_lin_6 * (float4(*((&kernelContext_91)->scratch_0+_S1334)) ).xyz, d_ang_5 * (float4(*((&kernelContext_91)->scratch_0+(_S1334 + 1U))) ).xyz, 0.0f, &kernelContext_91);
                i_22 = i_22 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            c_39 = _S1288;
            for(;;)
            {
                if(c_39 < c1_1)
                {
                }
                else
                {
                    break;
                }
                thread float3 fi_5;
                thread float3 mi_8;
                gather_loads_0(c_39, &fi_5, &mi_8, &kernelContext_91);
                thread float4 ap_lin_0 = float4(- fi_5, 0.0f);
                thread float4 ap_ang_0 = float4(- mi_8, 0.0f);
                uint _S1335 = fixed_mask_0(c_39, &kernelContext_91);
                uint _S1336 = sv_0(c_39, 8U, &kernelContext_91);
                float4 _S1337 = float4(*((&kernelContext_91)->scratch_0+_S1336)) ;
                uint _S1338 = sv_0(c_39, 9U, &kernelContext_91);
                hold_0(_S1335, &ap_lin_0, &ap_ang_0, _S1337, float4(*((&kernelContext_91)->scratch_0+_S1338)) );
                uint _S1339 = sv_0(c_39, 10U, &kernelContext_91);
                *((&kernelContext_91)->scratch_0+_S1339) = packed_float4(ap_lin_0) ;
                uint _S1340 = sv_0(c_39, 11U, &kernelContext_91);
                *((&kernelContext_91)->scratch_0+_S1340) = packed_float4(ap_ang_0) ;
                c_39 = c_39 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            float _S1341 = island_dot_0(tid_18, c0_1, c1_1, 8U, 10U, &kernelContext_91);
            uint _S1342 = cg_total_1 + 1U;
            if(_S1341 <= 0.0f)
            {
                cg_total_0 = _S1342;
                break;
            }
            float _S1343 = rz_0 / _S1341;
            uint c_44 = _S1288;
            for(;;)
            {
                if(c_44 < c1_1)
                {
                }
                else
                {
                    break;
                }
                uint _S1344 = sv_0(c_44, 2U, &kernelContext_91);
                packed_float4 device* _S1345 = (&kernelContext_91)->scratch_0+_S1344;
                float3 _S1346 = (float4(*((&kernelContext_91)->scratch_0+_S1344)) ).xyz;
                uint _S1347 = sv_0(c_44, 8U, &kernelContext_91);
                float3 _S1348 = float3(_S1343) ;
                *_S1345 = packed_float4(float4(_S1346 + _S1348 * (float4(*((&kernelContext_91)->scratch_0+_S1347)) ).xyz, 0.0f)) ;
                uint _S1349 = sv_0(c_44, 3U, &kernelContext_91);
                packed_float4 device* _S1350 = (&kernelContext_91)->scratch_0+_S1349;
                float3 _S1351 = (float4(*((&kernelContext_91)->scratch_0+_S1349)) ).xyz;
                uint _S1352 = sv_0(c_44, 9U, &kernelContext_91);
                *_S1350 = packed_float4(float4(_S1351 + _S1348 * (float4(*((&kernelContext_91)->scratch_0+_S1352)) ).xyz, 0.0f)) ;
                uint _S1353 = sv_0(c_44, 4U, &kernelContext_91);
                packed_float4 device* _S1354 = (&kernelContext_91)->scratch_0+_S1353;
                float3 _S1355 = (float4(*((&kernelContext_91)->scratch_0+_S1353)) ).xyz;
                uint _S1356 = sv_0(c_44, 10U, &kernelContext_91);
                *_S1354 = packed_float4(float4(_S1355 - _S1348 * (float4(*((&kernelContext_91)->scratch_0+_S1356)) ).xyz, 0.0f)) ;
                uint _S1357 = sv_0(c_44, 5U, &kernelContext_91);
                packed_float4 device* _S1358 = (&kernelContext_91)->scratch_0+_S1357;
                float3 _S1359 = (float4(*((&kernelContext_91)->scratch_0+_S1357)) ).xyz;
                uint _S1360 = sv_0(c_44, 11U, &kernelContext_91);
                *_S1358 = packed_float4(float4(_S1359 - _S1348 * (float4(*((&kernelContext_91)->scratch_0+_S1360)) ).xyz, 0.0f)) ;
                c_44 = c_44 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            float _S1361 = island_dot_0(tid_18, c0_1, c1_1, 4U, 4U, &kernelContext_91);
            if((sqrt(_S1361)) <= (0.00009999999747379f * _S1324))
            {
                cg_total_0 = _S1342;
                break;
            }
            uint c_45 = _S1288;
            for(;;)
            {
                if(c_45 < c1_1)
                {
                }
                else
                {
                    break;
                }
                precondition_0(c_45, &kernelContext_91);
                c_45 = c_45 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            if(free_0)
            {
                project_displacement_slot_0(tid_18, &_S1283, 6U, &kernelContext_91);
            }
            float _S1362 = island_dot_0(tid_18, c0_1, c1_1, 4U, 6U, &kernelContext_91);
            float _S1363 = _S1362 / rz_0;
            uint c_46 = _S1288;
            for(;;)
            {
                if(c_46 < c1_1)
                {
                }
                else
                {
                    break;
                }
                uint _S1364 = sv_0(c_46, 8U, &kernelContext_91);
                packed_float4 device* _S1365 = (&kernelContext_91)->scratch_0+_S1364;
                uint _S1366 = sv_0(c_46, 6U, &kernelContext_91);
                float3 _S1367 = float3(_S1363) ;
                *_S1365 = packed_float4(float4((float4(*((&kernelContext_91)->scratch_0+_S1366)) ).xyz + _S1367 * (float4(*((&kernelContext_91)->scratch_0+_S1364)) ).xyz, 0.0f)) ;
                uint _S1368 = sv_0(c_46, 9U, &kernelContext_91);
                packed_float4 device* _S1369 = (&kernelContext_91)->scratch_0+_S1368;
                uint _S1370 = sv_0(c_46, 7U, &kernelContext_91);
                *_S1369 = packed_float4(float4((float4(*((&kernelContext_91)->scratch_0+_S1370)) ).xyz + _S1367 * (float4(*((&kernelContext_91)->scratch_0+_S1368)) ).xyz, 0.0f)) ;
                c_46 = c_46 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            uint _S1371 = k_24 + 1U;
            rz_0 = _S1362;
            k_24 = _S1371;
            cg_total_1 = _S1342;
        }
        c_39 = _S1288;
        for(;;)
        {
            if(c_39 < c1_1)
            {
            }
            else
            {
                break;
            }
            uint _S1372 = 4U * c_39;
            thread float3 u_7 = (float4(*((&kernelContext_91)->state_0+_S1372)) ).xyz;
            uint _S1373 = sv_0(c_39, 21U, &kernelContext_91);
            thread float3 u_lo_0 = (float4(*((&kernelContext_91)->scratch_0+_S1373)) ).xyz;
            uint _S1374 = _S1372 + 1U;
            thread float3 th_9 = (float4(*((&kernelContext_91)->state_0+_S1374)) ).xyz;
            uint _S1375 = sv_0(c_39, 22U, &kernelContext_91);
            thread float3 th_lo_0 = (float4(*((&kernelContext_91)->scratch_0+_S1375)) ).xyz;
            uint _S1376 = sv_0(c_39, 2U, &kernelContext_91);
            comp_add_0(&u_7, &u_lo_0, (float4(*((&kernelContext_91)->scratch_0+_S1376)) ).xyz);
            uint _S1377 = sv_0(c_39, 3U, &kernelContext_91);
            comp_add_0(&th_9, &th_lo_0, (float4(*((&kernelContext_91)->scratch_0+_S1377)) ).xyz);
            *((&kernelContext_91)->state_0+_S1372) = packed_float4(float4(u_7, (float4(*((&kernelContext_91)->state_0+_S1372)) ).w)) ;
            *((&kernelContext_91)->state_0+_S1374) = packed_float4(float4(th_9, (float4(*((&kernelContext_91)->state_0+_S1374)) ).w)) ;
            *((&kernelContext_91)->scratch_0+_S1373) = packed_float4(float4(u_lo_0, 0.0f)) ;
            *((&kernelContext_91)->scratch_0+_S1375) = packed_float4(float4(th_lo_0, 0.0f)) ;
            c_39 = c_39 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint _S1378 = newton_0 + 1U;
        previous_2 = residual_1;
        residual_0 = residual_1;
        newton_0 = _S1378;
    }
    i_20 = b0_0 + tid_18;
    for(;;)
    {
        if(i_20 < _S1287)
        {
        }
        else
        {
            break;
        }
        JointResponse_0 _S1379 = static_response_0(i_20, &kernelContext_91);
        BondDyn_natural_0 device* _S1380 = (&kernelContext_91)->bond_dyn_0+i_20;
        float4 _S1381 = float4((*_S1380).force_lin_0) ;
        float4 _S1382 = float4((*_S1380).force_ang_0) ;
        float4 _S1383 = float4((*_S1380).sums_0) ;
        float4 _S1384 = float4((*_S1380).comps_0) ;
        uint4 _S1385 = uint4((*_S1380).events_0) ;
        thread BondDyn_0 bd_1;
        (&bd_1)->js_0 = (*_S1380).js_0;
        (&bd_1)->force_lin_0 = _S1381;
        (&bd_1)->force_ang_0 = _S1382;
        (&bd_1)->sums_0 = _S1383;
        (&bd_1)->comps_0 = _S1384;
        (&bd_1)->events_0 = _S1385;
        (&bd_1)->force_lin_0 = float4(_S1379.force_lin_1, _S1379.stored_5);
        (&bd_1)->force_ang_0 = float4(_S1379.force_ang_1, (&bd_1)->force_ang_0.w);
        BondDyn_natural_0 device* _S1386 = (&kernelContext_91)->bond_dyn_0+i_20;
        _S1386->js_0 = bd_1.js_0;
        _S1386->force_lin_0 = packed_float4(bd_1.force_lin_0) ;
        _S1386->force_ang_0 = packed_float4(bd_1.force_ang_0) ;
        _S1386->sums_0 = packed_float4(bd_1.sums_0) ;
        _S1386->comps_0 = packed_float4(bd_1.comps_0) ;
        _S1386->events_0 = packed_uint4(bd_1.events_0) ;
        write_bond_loads_0(i_20, i_20, _S1379.force_lin_1, _S1379.force_ang_1, max(_S1379.measures_0.tension_0, _S1379.measures_0.compression_0), &kernelContext_91);
        i_20 = i_20 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    c_40 = _S1288;
    for(;;)
    {
        if(c_40 < c1_1)
        {
        }
        else
        {
            break;
        }
        thread float3 fi_6;
        thread float3 mi_9;
        gather_loads_0(c_40, &fi_6, &mi_9, &kernelContext_91);
        uint _S1387 = fixed_mask_0(c_40, &kernelContext_91);
        float3 reaction_2;
        if(_S1387 != 0U)
        {
            uint _S1388 = sv_0(c_40, 0U, &kernelContext_91);
            reaction_2 = - ((float4(*((&kernelContext_91)->scratch_0+_S1388)) ).xyz + fi_6);
        }
        else
        {
            uint _S1389 = 4U * c_40;
            reaction_2 = float3((float4(*((&kernelContext_91)->state_0+(_S1389 + 1U))) ).w, (float4(*((&kernelContext_91)->state_0+(_S1389 + 2U))) ).w, (float4(*((&kernelContext_91)->state_0+(_S1389 + 3U))) ).w);
        }
        uint _S1390 = 4U * c_40;
        uint _S1391 = _S1390 + 1U;
        *((&kernelContext_91)->state_0+_S1391) = packed_float4(float4((float4(*((&kernelContext_91)->state_0+_S1391)) ).xyz, reaction_2.x)) ;
        *((&kernelContext_91)->state_0+(_S1390 + 2U)) = packed_float4(float4(0.0f, 0.0f, 0.0f, reaction_2.y)) ;
        *((&kernelContext_91)->state_0+(_S1390 + 3U)) = packed_float4(float4(0.0f, 0.0f, 0.0f, reaction_2.z)) ;
        c_40 = c_40 + 256U;
    }
    if(tid_18 == 0U)
    {
        uint _S1392 = statics_result_slot_0(_S1282, &kernelContext_91);
        packed_float4 device* _S1393 = (&kernelContext_91)->scratch_0+_S1392;
        float _S1394 = (as_type<float>((newton_0)));
        float _S1395 = (as_type<float>((cg_total_0)));
        if(converged_0)
        {
            previous_2 = 1.0f;
        }
        else
        {
            previous_2 = 0.0f;
        }
        *_S1393 = packed_float4(float4(residual_0, _S1394, _S1395, previous_2)) ;
        ((&kernelContext_91)->islands_0+_S1282)->info_0[int(2)] = _S1285 & 4294967287U;
    }
    return;
}

[[kernel]] void settled_fatigue(uint3 group_10 [[threadgroup_position_in_grid]], uint3 thread_10 [[thread_position_in_threadgroup]], Params_0 constant* params_14 [[buffer(0)]], Island_natural_0 device* islands_14 [[buffer(9)]], uint device* index_14 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_14 [[buffer(3)]], packed_float4 device* state_16 [[buffer(6)]], packed_float4 device* scratch_14 [[buffer(8)]], packed_float4 device* contact_state_14 [[buffer(11)]], packed_float4 device* loads_14 [[buffer(5)]], Impactor_natural_0 device* impactors_14 [[buffer(10)]], BondStatic_natural_0 device* bonds_14 [[buffer(2)]], MaterialTable_0 constant* materials_14 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_14 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_92;
    (&kernelContext_92)->params_0 = params_14;
    (&kernelContext_92)->islands_0 = islands_14;
    (&kernelContext_92)->index_0 = index_14;
    (&kernelContext_92)->chunks_0 = chunks_14;
    (&kernelContext_92)->state_0 = state_16;
    (&kernelContext_92)->scratch_0 = scratch_14;
    (&kernelContext_92)->contact_state_0 = contact_state_14;
    (&kernelContext_92)->loads_0 = loads_14;
    (&kernelContext_92)->impactors_0 = impactors_14;
    (&kernelContext_92)->bonds_0 = bonds_14;
    (&kernelContext_92)->materials_0 = materials_14;
    (&kernelContext_92)->bond_dyn_0 = bond_dyn_14;
    threadgroup array<float4, int(32)> g_part_a_14;
    (&kernelContext_92)->g_part_a_0 = &g_part_a_14;
    threadgroup array<float4, int(32)> g_part_b_14;
    (&kernelContext_92)->g_part_b_0 = &g_part_b_14;
    threadgroup array<uint, int(5)> g_seen_14;
    (&kernelContext_92)->g_seen_0 = &g_seen_14;
    threadgroup uint g_run_14;
    (&kernelContext_92)->g_run_0 = &g_run_14;
    threadgroup uint g_halt_14;
    (&kernelContext_92)->g_halt_0 = &g_halt_14;
    threadgroup uint g_wide_run_14;
    (&kernelContext_92)->g_wide_run_0 = &g_wide_run_14;
    uint tid_19 = thread_10.x;
    uint _S1396 = group_10.x;
    Island_natural_0 device* _S1397 = islands_14+_S1396;
    Island_natural_0 isl_25 = *_S1397;
    uint4 _S1398 = uint4((*_S1397).info_0) ;
    bool _S1399;
    if(((_S1398.x) & 16U) == 0U)
    {
        _S1399 = true;
    }
    else
    {
        uint4 _S1400 = uint4(isl_25.range_0) ;
        _S1399 = (_S1400.w) == (_S1400.z);
    }
    if(_S1399)
    {
        return;
    }
    seen_clear_0(tid_19, &kernelContext_92);
    if(tid_19 == 0U)
    {
        *(&kernelContext_92)->g_halt_0 = 0U;
        *(&kernelContext_92)->g_run_0 = 0U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    uint _S1401 = _S1398.w;
    uint4 _S1402 = uint4(isl_25.range_0) ;
    uint i_23 = _S1402.z + tid_19;
    for(;;)
    {
        if(i_23 < (_S1402.w))
        {
        }
        else
        {
            break;
        }
        BondStatic_natural_0 device* _S1403 = (&kernelContext_92)->bonds_0+i_23;
        BondDyn_natural_0 device* _S1404 = (&kernelContext_92)->bond_dyn_0+i_23;
        float4 _S1405 = float4((*_S1404).force_lin_0) ;
        float4 _S1406 = float4((*_S1404).force_ang_0) ;
        float4 _S1407 = float4((*_S1404).sums_0) ;
        float4 _S1408 = float4((*_S1404).comps_0) ;
        uint4 _S1409 = uint4((*_S1404).events_0) ;
        thread BondDyn_0 bd_2;
        (&bd_2)->js_0 = (*_S1404).js_0;
        (&bd_2)->force_lin_0 = _S1405;
        (&bd_2)->force_ang_0 = _S1406;
        (&bd_2)->sums_0 = _S1407;
        (&bd_2)->comps_0 = _S1408;
        (&bd_2)->events_0 = _S1409;
        thread JointBond_natural_0 _S1410 = _S1403->law_0;
        uint4 _S1411 = uint4((&_S1410)->ids_0) ;
        uint _S1412 = 4U * _S1411.y;
        uint _S1413 = 4U * _S1411.z;
        thread float3 d_lin_7;
        thread float3 d_ang_6;
        bond_kinematics_0(i_23, (float4(*((&kernelContext_92)->state_0+_S1412)) ).xyz, (float4(*((&kernelContext_92)->state_0+(_S1412 + 1U))) ).xyz, (float4(*((&kernelContext_92)->state_0+_S1413)) ).xyz, (float4(*((&kernelContext_92)->state_0+(_S1413 + 1U))) ).xyz, &d_lin_7, &d_ang_6, &kernelContext_92);
        JointState_0 previous_3 = (&bd_2)->js_0;
        float _S1414 = (&kernelContext_92)->params_0->dt_0;
        bool _S1415 = ((&kernelContext_92)->params_0->fracture_0) != 0U;
        _S1410 = _S1403->law_0;
        thread JointState_0 _S1416 = (&bd_2)->js_0;
        JointResponse_0 _S1417 = joint_evaluate_0(&(&kernelContext_92)->materials_0->m_0[_S1411.x], &_S1410, &_S1416, d_lin_7, d_ang_6, _S1414, _S1415);
        if((_S1417.state_6.damage_0) > (previous_3.damage_0 + 9.99999971718068537e-10f))
        {
            _S1399 = true;
        }
        else
        {
            _S1399 = (_S1417.state_6.crush_1) > (previous_3.crush_1 + 9.99999971718068537e-10f);
        }
        uint flags_3;
        if(_S1399)
        {
            flags_3 = 16U;
        }
        else
        {
            flags_3 = 0U;
        }
        thread float _S1418 = (&bd_2)->sums_0.x;
        thread float _S1419 = (&bd_2)->comps_0.x;
        comp_add1_0(&_S1418, &_S1419, _S1417.dissipated_2);
        (&bd_2)->comps_0.x = _S1419;
        (&bd_2)->sums_0.x = _S1418;
        thread float _S1420 = (&bd_2)->sums_0.y;
        thread float _S1421 = (&bd_2)->comps_0.y;
        comp_add1_0(&_S1420, &_S1421, _S1417.overshoot_0);
        (&bd_2)->comps_0.y = _S1421;
        (&bd_2)->sums_0.y = _S1420;
        (&bd_2)->force_lin_0 = float4(_S1417.force_lin_1, _S1417.stored_5);
        (&bd_2)->force_ang_0 = float4(_S1417.force_ang_1, max((&bd_2)->force_ang_0.w, _S1417.state_6.utilization_0));
        thread JointState_0 _S1422 = previous_3;
        bool _S1423 = is_damaged_0(&_S1422);
        bool _S1424;
        if(!_S1423)
        {
            thread JointState_0 _S1425 = _S1417.state_6;
            bool _S1426 = is_damaged_0(&_S1425);
            _S1424 = _S1426;
        }
        else
        {
            _S1424 = false;
        }
        bool _S1427;
        if(_S1424)
        {
            _S1427 = ((&bd_2)->events_0.x) == 0U;
        }
        else
        {
            _S1427 = false;
        }
        if(_S1427)
        {
            (&bd_2)->events_0.x = _S1401;
            (&bd_2)->events_0.w = _S1417.state_6.mode_0;
            (*(&kernelContext_92)->g_seen_0)[3U] = 1U;
        }
        bool _S1428;
        if(((&bd_2)->events_0.y) == 0U)
        {
            _S1428 = (_S1417.state_6.life_0) != (previous_3.life_0);
        }
        else
        {
            _S1428 = false;
        }
        bool _S1429;
        if(_S1428)
        {
            _S1429 = (_S1417.fatigue_before_0) > 0.99000000953674316f;
        }
        else
        {
            _S1429 = false;
        }
        bool _S1430;
        if(_S1429)
        {
            float _S1431 = fatigue_factor_0(&(&kernelContext_92)->materials_0->m_0[_S1411.x], _S1417.state_6.life_0);
            _S1430 = _S1431 <= 0.99000000953674316f;
        }
        else
        {
            _S1430 = false;
        }
        if(_S1430)
        {
            (&bd_2)->events_0.y = _S1401;
            (*(&kernelContext_92)->g_seen_0)[4U] = 1U;
        }
        uint flags_4;
        if(_S1417.disconnected_0)
        {
            (&bd_2)->events_0.z = _S1401;
            flags_4 = flags_3 | 32U;
        }
        else
        {
            flags_4 = flags_3;
        }
        (&bd_2)->js_0 = _S1417.state_6;
        BondDyn_natural_0 device* _S1432 = (&kernelContext_92)->bond_dyn_0+i_23;
        _S1432->js_0 = bd_2.js_0;
        _S1432->force_lin_0 = packed_float4(bd_2.force_lin_0) ;
        _S1432->force_ang_0 = packed_float4(bd_2.force_ang_0) ;
        _S1432->sums_0 = packed_float4(bd_2.sums_0) ;
        _S1432->comps_0 = packed_float4(bd_2.comps_0) ;
        _S1432->events_0 = packed_uint4(bd_2.events_0) ;
        write_bond_loads_0(i_23, i_23, _S1417.force_lin_1, _S1417.force_ang_1, max(_S1417.measures_0.tension_0, _S1417.measures_0.compression_0), &kernelContext_92);
        if((flags_4 & 16U) != 0U)
        {
            *(&kernelContext_92)->g_halt_0 = 1U;
        }
        if((flags_4 & 32U) != 0U)
        {
            *(&kernelContext_92)->g_run_0 = 1U;
        }
        i_23 = i_23 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    if(tid_19 != 0U)
    {
        return;
    }
    if(((*(&kernelContext_92)->g_halt_0) | (*(&kernelContext_92)->g_run_0)) != 0U)
    {
        uint _S1433 = _S1398.z;
        if((*(&kernelContext_92)->g_halt_0) != 0U)
        {
            i_23 = 16U;
        }
        else
        {
            i_23 = 0U;
        }
        uint _S1434 = _S1433 | i_23;
        if((*(&kernelContext_92)->g_run_0) != 0U)
        {
            i_23 = 32U;
        }
        else
        {
            i_23 = 0U;
        }
        ((&kernelContext_92)->islands_0+_S1396)->info_0[int(2)] = _S1434 | i_23;
    }
    uint _S1435 = (isl_25.coverage_0) | 16384U;
    uint _S1436 = seen_bits_0(&kernelContext_92);
    uint _S1437 = _S1435 | _S1436;
    if((*(&kernelContext_92)->g_run_0) != 0U)
    {
        i_23 = 128U;
    }
    else
    {
        i_23 = 0U;
    }
    ((&kernelContext_92)->islands_0+_S1396)->coverage_0 = _S1437 | i_23;
    return;
}

