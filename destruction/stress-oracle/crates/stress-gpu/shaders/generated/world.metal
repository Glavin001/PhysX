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
    float travel_0 = length(_S295.hi_0 - _S296.xyz + (_S295.lo_0 - (float4(_S293->start_lo_0) ).xyz) + _S295.rel_0);
    float travel_1;
    if((_S294.w) != 0U)
    {
        float3 th_1 = (float4(*(kernelContext_27->state_0+(4U * c_5 + 1U))) ).xyz;
        Quat_0 _S297 = from_axis_angle_0(th_1, length(th_1));
        thread Quat_0 _S298 = quat_of_0(float4((kernelContext_27->islands_0+(uint4(_S293->info_1) ).y)->rotation_0) );
        thread Quat_0 _S299 = _S297;
        Quat_0 _S300 = quat_mul_0(&_S298, &_S299);
        float4 _S301 = float4(_S293->start_rot_0) ;
        thread Quat_0 _S302 = quat_of_0(float4(- _S301.xyz, _S301.w));
        thread Quat_0 _S303 = _S300;
        Quat_0 _S304 = quat_mul_0(&_S302, &_S303);
        travel_1 = travel_0 + 2.0f * atan2(length(float3(_S304.x_2, _S304.y_1, _S304.z_0)), abs(_S304.w_1)) * (float4(_S293->half_0) ).w;
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
    uint _S305 = pair_lane_count_0(&kernelContext_28);
    uint pair_threads_0 = (&kernelContext_28)->params_0->pair_count_0 * _S305;
    if(i_4 < pair_threads_0)
    {
        bool _S306 = stopped_0(&kernelContext_28);
        bool _S307 = pair_any_0(_S306, _S305);
        if(!_S307)
        {
            uint _S308 = i_4 / _S305;
            uint _S309 = i_4 % _S305;
            pair_contact_0(_S308, _S309, _S305, &kernelContext_28);
        }
        return;
    }
    bool _S310 = stopped_0(&kernelContext_28);
    if(_S310)
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
    bool _S311;
    if(k_7 >= (params_2->cand_count_0))
    {
        _S311 = true;
    }
    else
    {
        bool _S312 = stopped_0(&kernelContext_29);
        _S311 = _S312;
    }
    if(_S311)
    {
        return;
    }
    uint _S313 = 3U * k_7;
    uint at_2 = (&kernelContext_29)->params_0->cand_index_0 + _S313;
    uint c_6 = (&kernelContext_29)->index_0[at_2];
    uint _S314 = (&kernelContext_29)->index_0[at_2 + 2U];
    thread Impactor_natural_0 _S315 = *((&kernelContext_29)->impactors_0+_S314);
    if(((uint4((&_S315)->cand_0) ).z) == 0U)
    {
        _S311 = ((float4((&_S315)->crush_0) ).x) > 0.0f;
    }
    else
    {
        _S311 = false;
    }
    float total_0;
    float ksum_0;
    if(_S311)
    {
        WorldPoint_0 _S316 = chunk_world_0(c_6, &kernelContext_29);
        WorldPoint_0 _S317 = impactor_point_0(_S314, &kernelContext_29);
        thread WorldPoint_0 _S318 = _S316;
        thread WorldPoint_0 _S319 = _S317;
        float3 _S320 = world_diff_0(&_S318, &_S319);
        float4 _S321 = float4((&_S315)->half_1) ;
        if(!((length(_S320)) > (_S321.w + (float4(((&kernelContext_29)->chunks_0+c_6)->half_0) ).w)))
        {
            Box_0 _S322 = impactor_box_1(_S314, float3(0.0f) , _S321.xyz, &kernelContext_29);
            Box_0 _S323 = chunk_box_0(c_6, _S320, &kernelContext_29);
            float _S324 = (float4((&_S315)->mat_0) ).x;
            float _S325 = (float4(((&kernelContext_29)->chunks_0+c_6)->cmat_0) ).x;
            float3 _S326 = _S323.center_1 - _S322.center_1;
            thread Box_0 _S327 = _S322;
            thread Box_0 _S328 = _S323;
            float _S329 = contact_stiffness_0(_S324, &_S327, _S325, &_S328, _S326);
            float _S330 = (float4((&_S315)->crush_0) ).w;
            thread Box_0 _S331 = _S322;
            Box_0 _S332 = impactor_shrunk_0(_S314, _S330, &_S331);
            thread Box_0 _S333 = _S332;
            thread Box_0 _S334 = _S323;
            uint _S335 = impactor_contact_count_0(_S314, _S330, &_S333, &_S334, &kernelContext_29);
            float _S336;
            if(((float4((&_S315)->shape_0) ).x) == 0.0f)
            {
                _S336 = _S329;
            }
            else
            {
                _S336 = _S329 / max(float(_S335), 10.0f);
            }
            uint j_5 = 0U;
            total_0 = 0.0f;
            ksum_0 = 0.0f;
            for(;;)
            {
                if(_S335 > 0U)
                {
                    thread Box_0 _S337 = _S323;
                    uint _S338 = impactor_slots_0(&_S315, &_S337);
                    _S311 = j_5 < _S338;
                }
                else
                {
                    _S311 = false;
                }
                if(_S311)
                {
                }
                else
                {
                    break;
                }
                thread Box_0 _S339 = _S332;
                thread Box_0 _S340 = _S323;
                thread float3 p_9;
                thread float3 nrm_1;
                thread float dep_1;
                bool _S341 = impactor_contact_1(&_S315, _S330, &_S339, &_S340, j_5, &p_9, &nrm_1, &dep_1, &kernelContext_29);
                if(!_S341)
                {
                    j_5 = j_5 + 1U;
                    continue;
                }
                float ksum_1 = ksum_0 + _S336;
                total_0 = total_0 + _S336 * dep_1;
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
    float4 _S342 = float4(*((&kernelContext_29)->scratch_0+((&kernelContext_29)->params_0->cand_base_0 + _S313))) ;
    *((&kernelContext_29)->scratch_0+((&kernelContext_29)->params_0->cand_base_0 + _S313)) = packed_float4(float4(total_0, ksum_0, _S342.z, _S342.w)) ;
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
    bool _S343;
    if(ii_0 >= (params_3->impactor_count_0))
    {
        _S343 = true;
    }
    else
    {
        bool _S344 = stopped_0(&kernelContext_30);
        _S343 = _S344;
    }
    if(_S343)
    {
        return;
    }
    Impactor_natural_0 device* _S345 = (&kernelContext_30)->impactors_0+ii_0;
    float4 _S346 = float4((*_S345).position_err_1) ;
    float4 _S347 = float4((*_S345).velocity_1) ;
    float4 _S348 = float4((*_S345).velocity_err_1) ;
    float4 _S349 = float4((*_S345).angular_velocity_1) ;
    float4 _S350 = float4((*_S345).rotation_1) ;
    float4 _S351 = float4((*_S345).inertia0_2) ;
    float4 _S352 = float4((*_S345).inertia1_2) ;
    float4 _S353 = float4((*_S345).inertia2_2) ;
    float4 _S354 = float4((*_S345).inv0_2) ;
    float4 _S355 = float4((*_S345).inv1_2) ;
    float4 _S356 = float4((*_S345).inv2_2) ;
    float4 _S357 = float4((*_S345).shape_0) ;
    float4 _S358 = float4((*_S345).half_1) ;
    float4 _S359 = float4((*_S345).mat_0) ;
    float4 _S360 = float4((*_S345).crush_0) ;
    float4 _S361 = float4((*_S345).geom_0) ;
    float4 _S362 = float4((*_S345).rotation_err_1) ;
    float4 _S363 = float4((*_S345).ledger_0) ;
    uint4 _S364 = uint4((*_S345).cand_0) ;
    float4 _S365 = float4((*_S345).momentum_1) ;
    float4 _S366 = float4((*_S345).momentum_err_1) ;
    thread Impactor_0 imp_5;
    (&imp_5)->position_1 = float4((*_S345).position_1) ;
    (&imp_5)->position_err_1 = _S346;
    (&imp_5)->velocity_1 = _S347;
    (&imp_5)->velocity_err_1 = _S348;
    (&imp_5)->angular_velocity_1 = _S349;
    (&imp_5)->rotation_1 = _S350;
    (&imp_5)->inertia0_2 = _S351;
    (&imp_5)->inertia1_2 = _S352;
    (&imp_5)->inertia2_2 = _S353;
    (&imp_5)->inv0_2 = _S354;
    (&imp_5)->inv1_2 = _S355;
    (&imp_5)->inv2_2 = _S356;
    (&imp_5)->shape_0 = _S357;
    (&imp_5)->half_1 = _S358;
    (&imp_5)->mat_0 = _S359;
    (&imp_5)->crush_0 = _S360;
    (&imp_5)->geom_0 = _S361;
    (&imp_5)->rotation_err_1 = _S362;
    (&imp_5)->ledger_0 = _S363;
    (&imp_5)->cand_0 = _S364;
    (&imp_5)->momentum_1 = _S365;
    (&imp_5)->momentum_err_1 = _S366;
    float4 _S367 = float4(0.0f) ;
    thread float4 shares_0 = _S367;
    thread float4 unused_0 = _S367;
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
        _S343 = true;
    }
    else
    {
        _S343 = ((&imp_5)->cand_0.z) != 0U;
    }
    if(_S343)
    {
        return;
    }
    (&imp_5)->geom_0 = float4(1.0f, (&imp_5)->crush_0.w, 0.0f, 0.0f);
    float total_1 = shares_0.x;
    if(((&imp_5)->crush_0.x) > 0.0f)
    {
        _S343 = ((&imp_5)->crush_0.z) < ((&imp_5)->crush_0.y);
    }
    else
    {
        _S343 = false;
    }
    if(_S343)
    {
        _S343 = total_1 > ((&imp_5)->crush_0.x);
    }
    else
    {
        _S343 = false;
    }
    if(_S343)
    {
        float extra_0 = (total_1 - (&imp_5)->crush_0.x) / shares_0.y;
        (&imp_5)->crush_0.w = (&imp_5)->crush_0.w + extra_0;
        (&imp_5)->crush_0.z = (&imp_5)->crush_0.z + (&imp_5)->crush_0.x * extra_0;
        float _S368 = (&imp_5)->crush_0.x * extra_0;
        thread float _S369 = (&imp_5)->ledger_0.z;
        thread float _S370 = (&imp_5)->ledger_0.w;
        comp_add1_0(&_S369, &_S370, _S368);
        (&imp_5)->ledger_0.w = _S370;
        (&imp_5)->ledger_0.z = _S369;
        float _S371 = (&imp_5)->crush_0.x * extra_0;
        thread float _S372 = (&imp_5)->ledger_0.x;
        thread float _S373 = (&imp_5)->ledger_0.y;
        comp_add1_0(&_S372, &_S373, _S371);
        (&imp_5)->ledger_0.y = _S373;
        (&imp_5)->ledger_0.x = _S372;
        (&imp_5)->geom_0.x = (&imp_5)->crush_0.x / total_1;
    }
    Impactor_natural_0 device* _S374 = (&kernelContext_30)->impactors_0+ii_0;
    _S374->position_1 = packed_float4(imp_5.position_1) ;
    _S374->position_err_1 = packed_float4(imp_5.position_err_1) ;
    _S374->velocity_1 = packed_float4(imp_5.velocity_1) ;
    _S374->velocity_err_1 = packed_float4(imp_5.velocity_err_1) ;
    _S374->angular_velocity_1 = packed_float4(imp_5.angular_velocity_1) ;
    _S374->rotation_1 = packed_float4(imp_5.rotation_1) ;
    _S374->inertia0_2 = packed_float4(imp_5.inertia0_2) ;
    _S374->inertia1_2 = packed_float4(imp_5.inertia1_2) ;
    _S374->inertia2_2 = packed_float4(imp_5.inertia2_2) ;
    _S374->inv0_2 = packed_float4(imp_5.inv0_2) ;
    _S374->inv1_2 = packed_float4(imp_5.inv1_2) ;
    _S374->inv2_2 = packed_float4(imp_5.inv2_2) ;
    _S374->shape_0 = packed_float4(imp_5.shape_0) ;
    _S374->half_1 = packed_float4(imp_5.half_1) ;
    _S374->mat_0 = packed_float4(imp_5.mat_0) ;
    _S374->crush_0 = packed_float4(imp_5.crush_0) ;
    _S374->geom_0 = packed_float4(imp_5.geom_0) ;
    _S374->rotation_err_1 = packed_float4(imp_5.rotation_err_1) ;
    _S374->ledger_0 = packed_float4(imp_5.ledger_0) ;
    _S374->cand_0 = packed_uint4(imp_5.cand_0) ;
    _S374->momentum_1 = packed_float4(imp_5.momentum_1) ;
    _S374->momentum_err_1 = packed_float4(imp_5.momentum_err_1) ;
    return;
}

void comp_add_0(float3 thread* sum_1, float3 thread* err_1, float3 x_8)
{
    float3 t_3 = *sum_1 + x_8;
    float3 _S375 = abs(x_8);
    *err_1 = *err_1 + (select(x_8, *sum_1, (abs(*sum_1)) >= _S375) - t_3 + select(*sum_1, x_8, (abs(*sum_1)) >= _S375));
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
    thread Quat_0 _S376 = c_7;
    float3 _S377 = rotate_0(&_S376, v_5);
    return _S377;
}

float3 inverse_rotate_1(const Quat_0 thread* q_11, float3 v_6)
{
    thread Quat_0 c_8;
    (&c_8)->w_1 = q_11->w_1;
    (&c_8)->x_2 = - q_11->x_2;
    (&c_8)->y_1 = - q_11->y_1;
    (&c_8)->z_0 = - q_11->z_0;
    thread Quat_0 _S378 = c_8;
    float3 _S379 = rotate_0(&_S378, v_6);
    return _S379;
}

float3 rows_mul_0(float4 r0_0, float4 r1_0, float4 r2_0, float3 v_7)
{
    return float3(dot(r0_0.xyz, v_7), dot(r1_0.xyz, v_7), dot(r2_0.xyz, v_7));
}

float3 world_mul_0(const Quat_0 thread* q_12, float4 r0_1, float4 r1_1, float4 r2_1, float3 v_8)
{
    float3 _S380 = inverse_rotate_1(q_12, v_8);
    float3 _S381 = rotate_1(q_12, rows_mul_0(r0_1, r1_1, r2_1, _S380));
    return _S381;
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
    float4 _S382 = abs(x_9);
    *err_2 = *err_2 + (select(x_9, *sum_2, (abs(*sum_2)) >= _S382) - t_4 + select(*sum_2, x_9, (abs(*sum_2)) >= _S382));
    *sum_2 = t_4;
    return;
}

void quat_accumulate_0(Quat_0 thread* hi_1, float4 thread* lo_1, float4 x_10)
{
    thread Quat_0 _S383 = *hi_1;
    float4 _S384 = quat_vec_0(&_S383);
    thread float4 sum_3 = _S384;
    comp_add4_0(&sum_3, lo_1, x_10);
    float4 t_5 = sum_3 + *lo_1;
    *lo_1 = *lo_1 - (t_5 - sum_3);
    *hi_1 = quat_of_0(t_5);
    return;
}

void turn_left_0(Quat_0 thread* hi_2, float4 thread* lo_2, float3 omega_0, float dt_2)
{
    float _S385 = length(omega_0);
    float angle_2 = _S385 * dt_2;
    if(angle_2 < 1.00000000317107685e-30f)
    {
        return;
    }
    float4 d_12 = turn_minus_one_0(omega_0 / float3(_S385) , angle_2);
    thread Quat_0 dq_0;
    (&dq_0)->x_2 = d_12.x;
    (&dq_0)->y_1 = d_12.y;
    (&dq_0)->z_0 = d_12.z;
    (&dq_0)->w_1 = d_12.w;
    thread Quat_0 _S386 = dq_0;
    thread Quat_0 _S387 = *hi_2;
    Quat_0 _S388 = quat_mul_0(&_S386, &_S387);
    thread Quat_0 _S389 = _S388;
    float4 _S390 = quat_vec_0(&_S389);
    quat_accumulate_0(hi_2, lo_2, _S390);
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
    Island_natural_0 device* _S391 = (&kernelContext_31)->islands_0+(&kernelContext_31)->params_0->halt_index_0;
    Impactor_natural_0 device* _S392 = (&kernelContext_31)->impactors_0+ii_1;
    float4 _S393 = float4((*_S392).position_err_1) ;
    float4 _S394 = float4((*_S392).velocity_1) ;
    float4 _S395 = float4((*_S392).velocity_err_1) ;
    float4 _S396 = float4((*_S392).angular_velocity_1) ;
    float4 _S397 = float4((*_S392).rotation_1) ;
    float4 _S398 = float4((*_S392).inertia0_2) ;
    float4 _S399 = float4((*_S392).inertia1_2) ;
    float4 _S400 = float4((*_S392).inertia2_2) ;
    float4 _S401 = float4((*_S392).inv0_2) ;
    float4 _S402 = float4((*_S392).inv1_2) ;
    float4 _S403 = float4((*_S392).inv2_2) ;
    float4 _S404 = float4((*_S392).shape_0) ;
    float4 _S405 = float4((*_S392).half_1) ;
    float4 _S406 = float4((*_S392).mat_0) ;
    float4 _S407 = float4((*_S392).crush_0) ;
    float4 _S408 = float4((*_S392).geom_0) ;
    float4 _S409 = float4((*_S392).rotation_err_1) ;
    float4 _S410 = float4((*_S392).ledger_0) ;
    uint4 _S411 = uint4((*_S392).cand_0) ;
    float4 _S412 = float4((*_S392).momentum_1) ;
    float4 _S413 = float4((*_S392).momentum_err_1) ;
    thread Impactor_0 imp_6;
    (&imp_6)->position_1 = float4((*_S392).position_1) ;
    (&imp_6)->position_err_1 = _S393;
    (&imp_6)->velocity_1 = _S394;
    (&imp_6)->velocity_err_1 = _S395;
    (&imp_6)->angular_velocity_1 = _S396;
    (&imp_6)->rotation_1 = _S397;
    (&imp_6)->inertia0_2 = _S398;
    (&imp_6)->inertia1_2 = _S399;
    (&imp_6)->inertia2_2 = _S400;
    (&imp_6)->inv0_2 = _S401;
    (&imp_6)->inv1_2 = _S402;
    (&imp_6)->inv2_2 = _S403;
    (&imp_6)->shape_0 = _S404;
    (&imp_6)->half_1 = _S405;
    (&imp_6)->mat_0 = _S406;
    (&imp_6)->crush_0 = _S407;
    (&imp_6)->geom_0 = _S408;
    (&imp_6)->rotation_err_1 = _S409;
    (&imp_6)->ledger_0 = _S410;
    (&imp_6)->cand_0 = _S411;
    (&imp_6)->momentum_1 = _S412;
    (&imp_6)->momentum_err_1 = _S413;
    uint4 _S414 = uint4(_S391->info_0) ;
    bool _S415;
    if(((_S414.z) & 1U) != 0U)
    {
        _S415 = true;
    }
    else
    {
        uint _S416 = _S414.y;
        if(_S416 != 0U)
        {
            _S415 = ((&imp_6)->cand_0.w) >= _S416;
        }
        else
        {
            _S415 = false;
        }
    }
    if(_S415)
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
    float4 _S417 = float4(0.0f) ;
    thread float4 rf_0 = _S417;
    thread float4 rt_0 = _S417;
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
        uint _S418 = 3U * k_9;
        rf_0 = rf_0 + float4(*((&kernelContext_31)->scratch_0+((&kernelContext_31)->params_0->cand_base_0 + _S418 + 1U))) ;
        rt_0 = rt_0 + float4(*((&kernelContext_31)->scratch_0+((&kernelContext_31)->params_0->cand_base_0 + _S418 + 2U))) ;
        k_9 = k_9 + 256U;
    }
    group_sum2_0(tid_3, &rf_0, &rt_0, &kernelContext_31);
    if(tid_3 != 0U)
    {
        return;
    }
    float dt_3 = (&kernelContext_31)->params_0->dt_0;
    float3 _S419 = float3(0.0f) ;
    float3 load_f_0;
    float3 load_t_0;
    if(((&kernelContext_31)->params_0->has_ground_0) != 0U)
    {
        float3 _S420 = (&imp_6)->half_1.xyz;
        thread Impactor_0 _S421 = imp_6;
        Box_0 _S422 = impactor_box_0(&_S421, _S419, _S420);
        float3 _S423 = (&imp_6)->velocity_1.xyz + (&imp_6)->velocity_err_1.xyz;
        float _S424 = (&kernelContext_31)->params_0->ground_modulus_0;
        float _S425 = (&imp_6)->mat_0.x;
        float3 _S426 = float3(0.0f, 0.0f, 1.0f);
        thread Box_0 _S427 = _S422;
        thread Box_0 _S428 = _S422;
        float _S429 = contact_stiffness_0(_S424, &_S427, _S425, &_S428, _S426);
        float _S430 = (&imp_6)->position_1.z - (&kernelContext_31)->params_0->ground_hi_0 + ((&imp_6)->position_err_1.z - (&kernelContext_31)->params_0->ground_lo_0);
        uint total_points_0;
        if(((&imp_6)->shape_0.x) == 0.0f)
        {
            total_points_0 = 1U;
        }
        else
        {
            total_points_0 = 14U;
        }
        float _S431 = _S429 / float(min(total_points_0, 5U));
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
                thread Box_0 _S432 = _S422;
                float3 _S433 = sample_point_0(&_S432, s_2, &kernelContext_31);
                p_10 = _S433;
            }
            if((_S430 + p_10.z) < 0.0f)
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
        load_f_0 = _S419;
        load_t_0 = _S419;
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
                thread Box_0 _S434 = _S422;
                float3 _S435 = sample_point_0(&_S434, s_2, &kernelContext_31);
                p_10 = _S435;
            }
            float depth_4 = - (_S430 + p_10.z);
            if(depth_4 <= 0.0f)
            {
                s_2 = s_2 + 1U;
                continue;
            }
            thread float stored_3;
            thread float diss_2;
            float3 _S436 = penalty_force_0(_S431, (&imp_6)->mat_0.z, (&kernelContext_31)->params_0->ground_friction_0, depth_4, _S426, _S423 + cross((&imp_6)->angular_velocity_1.xyz, p_10), dt_3, below_0, &stored_3, &diss_2, &kernelContext_31);
            float3 load_f_1 = load_f_0 + _S436;
            float3 load_t_1 = load_t_0 + cross(p_10, _S436);
            thread float _S437 = (&imp_6)->ledger_0.x;
            thread float _S438 = (&imp_6)->ledger_0.y;
            comp_add1_0(&_S437, &_S438, diss_2);
            (&imp_6)->ledger_0.y = _S438;
            (&imp_6)->ledger_0.x = _S437;
            load_f_0 = load_f_1;
            load_t_0 = load_t_1;
            s_2 = s_2 + 1U;
        }
    }
    else
    {
        load_f_0 = _S419;
        load_t_0 = _S419;
    }
    float3 load_f_2 = rf_0.xyz + load_f_0;
    float3 load_t_2 = rt_0.xyz + load_t_0;
    float m_2 = (&imp_6)->mat_0.z;
    thread float3 vel_0 = (&imp_6)->velocity_1.xyz;
    thread float3 vel_err_0 = (&imp_6)->velocity_err_1.xyz;
    float3 _S439 = float3(dt_3) ;
    comp_add_0(&vel_0, &vel_err_0, (load_f_2 / float3(m_2)  + (&kernelContext_31)->params_0->gravity_0.xyz) * _S439);
    Quat_0 _S440 = quat_of_0((&imp_6)->rotation_1);
    thread Quat_0 q_14 = _S440;
    thread float4 q_err_0 = (&imp_6)->rotation_err_1;
    thread float3 l_hi_0 = (&imp_6)->momentum_1.xyz;
    thread float3 l_err_0 = (&imp_6)->momentum_err_1.xyz;
    comp_add_0(&l_hi_0, &l_err_0, load_t_2 * _S439);
    float3 l_1 = l_hi_0 + l_err_0;
    thread Quat_0 _S441 = _S440;
    float3 _S442 = world_mul_0(&_S441, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    thread float3 pos_0 = (&imp_6)->position_1.xyz;
    thread float3 pos_err_0 = (&imp_6)->position_err_1.xyz;
    comp_add_0(&pos_0, &pos_err_0, (vel_0 + vel_err_0) * _S439);
    turn_left_0(&q_14, &q_err_0, _S442, dt_3);
    thread Quat_0 _S443 = q_14;
    float3 _S444 = world_mul_0(&_S443, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    (&imp_6)->angular_velocity_1 = float4(_S444, 0.0f);
    thread Quat_0 _S445 = q_14;
    float4 _S446 = quat_vec_0(&_S445);
    (&imp_6)->rotation_1 = _S446;
    (&imp_6)->rotation_err_1 = q_err_0;
    (&imp_6)->momentum_1 = float4(l_hi_0, 0.0f);
    (&imp_6)->momentum_err_1 = float4(l_err_0, 0.0f);
    (&imp_6)->position_1 = float4(pos_0, 0.0f);
    (&imp_6)->position_err_1 = float4(pos_err_0, 0.0f);
    (&imp_6)->velocity_1 = float4(vel_0, 0.0f);
    (&imp_6)->velocity_err_1 = float4(vel_err_0, 0.0f);
    (&imp_6)->cand_0.w = (&imp_6)->cand_0.w + 1U;
    (&imp_6)->geom_0 = float4(1.0f, (&imp_6)->crush_0.w, 0.0f, 0.0f);
    Impactor_natural_0 device* _S447 = (&kernelContext_31)->impactors_0+ii_1;
    _S447->position_1 = packed_float4(imp_6.position_1) ;
    _S447->position_err_1 = packed_float4(imp_6.position_err_1) ;
    _S447->velocity_1 = packed_float4(imp_6.velocity_1) ;
    _S447->velocity_err_1 = packed_float4(imp_6.velocity_err_1) ;
    _S447->angular_velocity_1 = packed_float4(imp_6.angular_velocity_1) ;
    _S447->rotation_1 = packed_float4(imp_6.rotation_1) ;
    _S447->inertia0_2 = packed_float4(imp_6.inertia0_2) ;
    _S447->inertia1_2 = packed_float4(imp_6.inertia1_2) ;
    _S447->inertia2_2 = packed_float4(imp_6.inertia2_2) ;
    _S447->inv0_2 = packed_float4(imp_6.inv0_2) ;
    _S447->inv1_2 = packed_float4(imp_6.inv1_2) ;
    _S447->inv2_2 = packed_float4(imp_6.inv2_2) ;
    _S447->shape_0 = packed_float4(imp_6.shape_0) ;
    _S447->half_1 = packed_float4(imp_6.half_1) ;
    _S447->mat_0 = packed_float4(imp_6.mat_0) ;
    _S447->crush_0 = packed_float4(imp_6.crush_0) ;
    _S447->geom_0 = packed_float4(imp_6.geom_0) ;
    _S447->rotation_err_1 = packed_float4(imp_6.rotation_err_1) ;
    _S447->ledger_0 = packed_float4(imp_6.ledger_0) ;
    _S447->cand_0 = packed_uint4(imp_6.cand_0) ;
    _S447->momentum_1 = packed_float4(imp_6.momentum_1) ;
    _S447->momentum_err_1 = packed_float4(imp_6.momentum_err_1) ;
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
    ChunkStatic_natural_0 device* _S448 = kernelContext_32->chunks_0+c_9;
    WorldPoint_0 _S449 = chunk_world_0(c_9, kernelContext_32);
    float above_0 = _S449.hi_0.z - kernelContext_32->params_0->ground_hi_0 + (_S449.lo_0.z - kernelContext_32->params_0->ground_lo_0) + _S449.rel_0.z;
    if((above_0 - (float4(_S448->half_0) ).w) > 0.0f)
    {
        return;
    }
    Box_0 _S450 = chunk_box_0(c_9, float3(0.0f) , kernelContext_32);
    float _S451 = kernelContext_32->params_0->ground_modulus_0;
    float _S452 = (float4(_S448->cmat_0) ).x;
    float3 _S453 = float3(0.0f, 0.0f, 1.0f);
    thread Box_0 _S454 = _S450;
    thread Box_0 _S455 = _S450;
    float _S456 = contact_stiffness_0(_S451, &_S454, _S452, &_S455, _S453);
    thread Box_0 _S457 = _S450;
    uint _S458 = sample_count_0(&_S457);
    uint s_3 = 0U;
    uint n_8 = 0U;
    for(;;)
    {
        if(s_3 < _S458)
        {
        }
        else
        {
            break;
        }
        thread Box_0 _S459 = _S450;
        float3 _S460 = sample_point_0(&_S459, s_3, kernelContext_32);
        if((above_0 + _S460.z) < 0.0f)
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
        if(s_3 < _S458)
        {
        }
        else
        {
            break;
        }
        thread Box_0 _S461 = _S450;
        float3 _S462 = sample_point_0(&_S461, s_3, kernelContext_32);
        float _S463 = above_0 + _S462.z;
        if(!(_S463 < 0.0f))
        {
            s_3 = s_3 + 1U;
            continue;
        }
        thread float stored_4;
        thread float diss_3;
        float3 _S464 = penalty_force_0(_S456 / float(max(n_8, 5U)), (float4(_S448->center_0) ).w, kernelContext_32->params_0->ground_friction_0, - _S463, _S453, vc_1 + cross(wc_1, _S462), kernelContext_32->params_0->dt_0, n_8, &stored_4, &diss_3, kernelContext_32);
        *f_1 = *f_1 + _S464;
        *t_6 = *t_6 + cross(_S462, _S464);
        thread float _S465 = ledger_2.y;
        thread float _S466 = ledger_2.z;
        comp_add1_0(&_S465, &_S466, diss_3);
        ledger_2.z = _S466;
        ledger_2.y = _S465;
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
    bool _S467;
    if(g_0 >= (params_5->seg_count_0))
    {
        _S467 = true;
    }
    else
    {
        bool _S468 = stopped_0(&kernelContext_33);
        _S467 = _S468;
    }
    if(_S467)
    {
        return;
    }
    uint _S469 = 3U * g_0;
    uint _S470 = (&kernelContext_33)->index_0[(&kernelContext_33)->params_0->seg_index_0 + _S469];
    uint begin_0 = (&kernelContext_33)->index_0[(&kernelContext_33)->params_0->seg_index_0 + _S469 + 1U];
    uint _S471 = (&kernelContext_33)->index_0[(&kernelContext_33)->params_0->seg_index_0 + _S469 + 2U];
    float3 _S472 = float3(0.0f) ;
    thread float3 f_2 = _S472;
    thread float3 t_7 = _S472;
    uint e_2 = begin_0;
    for(;;)
    {
        if(e_2 < _S471)
        {
        }
        else
        {
            break;
        }
        uint entry_1 = (&kernelContext_33)->index_0[e_2];
        if(entry_1 == 2147483648U)
        {
            ground_contact_0(_S470, true, &f_2, &t_7, &kernelContext_33);
            e_2 = e_2 + 1U;
            continue;
        }
        uint _S473 = 2U * entry_1;
        f_2 = f_2 + (float4(*((&kernelContext_33)->scratch_0+((&kernelContext_33)->params_0->slot_base_0 + _S473))) ).xyz;
        t_7 = t_7 + (float4(*((&kernelContext_33)->scratch_0+((&kernelContext_33)->params_0->slot_base_0 + _S473 + 1U))) ).xyz;
        e_2 = e_2 + 1U;
    }
    uint _S474 = 2U * g_0;
    *((&kernelContext_33)->scratch_0+((&kernelContext_33)->params_0->seg_base_0 + _S474)) = packed_float4(float4(f_2, 0.0f)) ;
    *((&kernelContext_33)->scratch_0+((&kernelContext_33)->params_0->seg_base_0 + _S474 + 1U)) = packed_float4(float4(t_7, 0.0f)) ;
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
    uint4 _S475 = uint4((kernelContext_35->islands_0+kernelContext_35->params_0->halt_index_0)->info_0) ;
    bool _S476;
    if(((_S475.z) & 1U) != 0U)
    {
        _S476 = true;
    }
    else
    {
        uint _S477 = _S475.y;
        if(_S477 != 0U)
        {
            _S476 = _S477 <= ((uint4(isl_0->info_0) ).w);
        }
        else
        {
            _S476 = false;
        }
    }
    return _S476;
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
    uint4 _S478 = uint4((kernelContext_36->islands_0+kernelContext_36->params_0->halt_index_0)->info_0) ;
    bool _S479;
    if(((_S478.z) & 1U) != 0U)
    {
        _S479 = true;
    }
    else
    {
        uint _S480 = _S478.y;
        if(_S480 != 0U)
        {
            _S479 = _S480 <= (isl_1->info_0.w);
        }
        else
        {
            _S479 = false;
        }
    }
    return _S479;
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
    float3 _S481 = float3(0.0f) ;
    (&rg_0)->torque_0 = _S481;
    (&rg_0)->a_7 = _S481;
    (&rg_0)->alpha_0 = _S481;
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
    float3 _S482 = float3(0.0f) ;
    (&rg_1)->torque_0 = _S482;
    (&rg_1)->a_7 = _S482;
    (&rg_1)->alpha_0 = _S482;
    return rg_1;
}

float time_since_0(float4 origin_0, uint k_11, float dt_4, KernelContext_0 thread* kernelContext_37)
{
    return kernelContext_37->params_0->t_hi_0 - origin_0.x + (kernelContext_37->params_0->t_lo_0 - origin_0.y) + float(k_11) * dt_4;
}

float table_eval_0(uint offset_0, uint count_3, float tau_0, KernelContext_0 thread* kernelContext_38)
{
    float4 _S483 = float4(*(kernelContext_38->loads_0+offset_0)) ;
    if(tau_0 <= (_S483.x))
    {
        return _S483.y;
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
        uint _S484 = offset_0 + i_5;
        float4 _S485 = float4(*(kernelContext_38->loads_0+_S484)) ;
        float _S486 = _S485.x;
        if(tau_0 <= _S486)
        {
            float4 _S487 = float4(*(kernelContext_38->loads_0+(_S484 - 1U))) ;
            float _S488 = _S487.x;
            float _S489 = _S487.y;
            return _S489 + (tau_0 - _S488) / max(_S486 - _S488, 1.00000000317107685e-30f) * (_S485.y - _S489);
        }
        i_5 = i_5 + 1U;
    }
    return (float4(*(kernelContext_38->loads_0+(offset_0 + count_3 - 1U))) ).y;
}

float eval_function_0(uint term_0, uint k_12, float dt_5, float shift_0, KernelContext_0 thread* kernelContext_39)
{
    uint _S490 = 5U * term_0;
    uint4 info_2 = (as_type<uint4>((float4(*(kernelContext_39->loads_0+_S490)) )));
    float4 _S491 = float4(*(kernelContext_39->loads_0+(_S490 + 3U))) ;
    float4 _S492 = float4(*(kernelContext_39->loads_0+(_S490 + 4U))) ;
    uint kind_0 = info_2.z;
    if(kind_0 == 0U)
    {
        return _S491.z;
    }
    float _S493 = time_since_0(_S491, k_12, dt_5, kernelContext_39);
    float tau_1 = _S493 + shift_0;
    float shape_1;
    if(kind_0 == 1U)
    {
        if(tau_1 <= 0.0f)
        {
            shape_1 = 0.0f;
        }
        else
        {
            float _S494 = _S492.x;
            if(tau_1 >= _S494)
            {
                shape_1 = _S492.y;
            }
            else
            {
                shape_1 = _S492.y * tau_1 / _S494;
            }
        }
        return shape_1;
    }
    bool _S495;
    if(kind_0 == 2U)
    {
        if(tau_1 < 0.0f)
        {
            _S495 = true;
        }
        else
        {
            _S495 = tau_1 > (_S492.x);
        }
        if(_S495)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S492.y * sin(3.14159274101257324f * tau_1 / _S492.x);
        }
        return shape_1;
    }
    if(kind_0 == 3U)
    {
        float sn_0 = tau_1 / _S492.y;
        if(sn_0 < 0.0f)
        {
            _S495 = true;
        }
        else
        {
            _S495 = sn_0 > 1.0f;
        }
        if(_S495)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S492.x * (1.0f - sn_0) * exp(- _S492.z * sn_0);
        }
        return shape_1;
    }
    if(kind_0 == 4U)
    {
        float _S496 = table_eval_0(info_2.w, (as_type<uint>((_S492.x))), tau_1, kernelContext_39);
        return _S496;
    }
    if(kind_0 == 5U)
    {
        (*kernelContext_39->g_seen_0)[1U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float sn_1 = tau_1 / _S492.x;
        if(sn_1 < 0.0f)
        {
            _S495 = true;
        }
        else
        {
            _S495 = sn_1 > 1.0f;
        }
        if(_S495)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = (1.0f - sn_1) * exp(- _S492.y * sn_1);
        }
        float clearing_0 = _S491.w;
        float relax_0;
        if(clearing_0 > 0.0f)
        {
            relax_0 = max(1.0f - tau_1 / clearing_0, 0.0f);
        }
        else
        {
            relax_0 = 0.0f;
        }
        float _S497 = _S492.w;
        return (_S497 + (_S492.z - _S497) * relax_0) * shape_1;
    }
    if(kind_0 == 7U)
    {
        (*kernelContext_39->g_seen_0)[2U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float _S498 = _S492.y;
        if(tau_1 < _S498)
        {
            return _S492.x;
        }
        float s_4 = tau_1 - _S498;
        float _S499 = _S492.w;
        if(s_4 > _S499)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S492.z * sin(3.14159274101257324f * s_4 / _S499);
        }
        return shape_1;
    }
    float _S500 = _S492.x;
    if(_S500 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp(1.0f - tau_1 / _S500, 0.0f, 1.0f);
}

void record_chunk_load_0(uint c_10, float3 f_3, float3 t_8, KernelContext_0 thread* kernelContext_40)
{
    if((kernelContext_40->params_0->solve_mode_0) == 0U)
    {
        return;
    }
    uint _S501 = 2U * c_10;
    *(kernelContext_40->scratch_0+(kernelContext_40->params_0->cload_base_0 + _S501)) = packed_float4(float4(f_3, 0.0f)) ;
    *(kernelContext_40->scratch_0+(kernelContext_40->params_0->cload_base_0 + _S501 + 1U)) = packed_float4(float4(t_8, 0.0f)) ;
    *(kernelContext_40->scratch_0+(kernelContext_40->params_0->cframe_base_0 + _S501)) = packed_float4(float4((float4(*(kernelContext_40->scratch_0+(kernelContext_40->params_0->cframe_base_0 + _S501))) ).xyz + f_3, 0.0f)) ;
    *(kernelContext_40->scratch_0+(kernelContext_40->params_0->cframe_base_0 + _S501 + 1U)) = packed_float4(float4((float4(*(kernelContext_40->scratch_0+(kernelContext_40->params_0->cframe_base_0 + _S501 + 1U))) ).xyz + t_8, 0.0f)) ;
    return;
}

void chunk_loads_0(uint _S502, uint _S503, const Quat_0 thread* _S504, uint _S505, float _S506, bool _S507, float _S508, float3 thread* _S509, float3 thread* _S510, float3 thread* _S511, float3 thread* _S512, KernelContext_0 thread* kernelContext_41)
{
    bool _S513;
    ChunkStatic_natural_0 device* _S514 = kernelContext_41->chunks_0+_S503;
    float3 _S515 = float3(0.0f) ;
    *_S509 = _S515;
    *_S510 = _S515;
    *_S511 = _S515;
    *_S512 = _S515;
    uint4 _S516 = uint4(_S514->load_range_0) ;
    uint term_1 = _S516.x;
    for(;;)
    {
        if(term_1 < (_S516.y))
        {
        }
        else
        {
            break;
        }
        (*kernelContext_41->g_seen_0)[0U] = 1U;
        uint _S517 = 5U * term_1;
        uint _S518 = (as_type<uint4>((float4(*(kernelContext_41->loads_0+_S517)) ))).y;
        bool replacement_0 = _S518 == 2U;
        float4 _S519 = float4(*(kernelContext_41->loads_0+(_S517 + 1U))) ;
        float4 _S520 = float4(*(kernelContext_41->loads_0+(_S517 + 2U))) ;
        float _S521;
        if(replacement_0)
        {
            _S521 = _S508;
        }
        else
        {
            _S521 = 0.0f;
        }
        float _S522 = eval_function_0(term_1, _S505, _S506, _S521, kernelContext_41);
        if(replacement_0)
        {
            float3 _S523 = float3(_S522) ;
            *_S511 = *_S511 + _S519.xyz * _S523;
            *_S512 = *_S512 + _S520.xyz * _S523;
            term_1 = term_1 + 1U;
            continue;
        }
        if(_S518 == 0U)
        {
            _S513 = true;
        }
        else
        {
            _S513 = _S518 == 3U;
        }
        float3 fw_0;
        if(_S513)
        {
            fw_0 = _S519.xyz * float3(_S522) ;
        }
        else
        {
            float3 _S524 = rotate_0(_S504, _S519.xyz);
            fw_0 = _S524 * float3((- _S522 * _S519.w)) ;
        }
        float3 lever_0;
        if(_S518 == 3U)
        {
            lever_0 = _S520.xyz - (float4(*(kernelContext_41->state_0+4U * _S502)) ).xyz;
        }
        else
        {
            lever_0 = _S520.xyz;
        }
        *_S509 = *_S509 + fw_0;
        float3 _S525 = rotate_0(_S504, lever_0);
        *_S510 = *_S510 + cross(_S525, fw_0);
        term_1 = term_1 + 1U;
    }
    if(_S507)
    {
        _S513 = ((uint4(_S514->cinfo_0) ).z) != 0U;
    }
    else
    {
        _S513 = false;
    }
    if(_S513)
    {
        uint4 _S526 = uint4(_S514->cinfo_0) ;
        uint g_1 = _S526.x;
        for(;;)
        {
            if(g_1 < (_S526.y))
            {
            }
            else
            {
                break;
            }
            uint _S527 = 2U * g_1;
            *_S509 = *_S509 + (float4(*(kernelContext_41->scratch_0+(kernelContext_41->params_0->seg_base_0 + _S527))) ).xyz;
            *_S510 = *_S510 + (float4(*(kernelContext_41->scratch_0+(kernelContext_41->params_0->seg_base_0 + _S527 + 1U))) ).xyz;
            g_1 = g_1 + 1U;
        }
    }
    return;
}

void chunk_external_0(uint _S528, uint _S529, const Quat_0 thread* _S530, uint _S531, float _S532, bool _S533, float3 thread* _S534, float3 thread* _S535, KernelContext_0 thread* kernelContext_42)
{
    thread float3 rf_1;
    thread float3 rm_0;
    chunk_loads_0(_S528, _S529, _S530, _S531, _S532, _S533, 0.0f, _S534, _S535, &rf_1, &rm_0, kernelContext_42);
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
    ChunkStatic_natural_0 device* _S536 = kernelContext_44->chunks_0+c_12;
    thread float3 fl_0;
    thread float3 tl_0;
    thread float3 rep_f_0;
    thread float3 rep_m_0;
    chunk_loads_0(c_12, c_12, &rg_2->rot_0, k_14, dt_7, contact_1, 0.0f, &fl_0, &tl_0, &rep_f_0, &rep_m_0, kernelContext_44);
    float4 _S537 = float4(_S536->center_0) ;
    float3 fc_0 = fl_0 + kernelContext_44->params_0->gravity_0.xyz * float3(_S537.w) ;
    float3 _S538 = _S537.xyz;
    float3 _S539 = (float4(isl_4->com_0) ).xyz;
    float3 _S540 = rotate_0(&rg_2->rot_0, _S538 + (float4(*(kernelContext_44->state_0+4U * c_12)) ).xyz - _S539);
    *f_5 = *f_5 + fc_0;
    *t_10 = *t_10 + (cross(_S540, fc_0) + tl_0);
    uint4 _S541 = uint4(_S536->load_range_0) ;
    if((_S541.y) > (_S541.x))
    {
        float3 _S542 = rotate_0(&rg_2->rot_0, rep_f_0);
        *f_5 = *f_5 + _S542;
        float3 _S543 = rotate_0(&rg_2->rot_0, _S538 - _S539);
        float3 _S544 = cross(_S543, _S542);
        float3 _S545 = rotate_0(&rg_2->rot_0, rep_m_0);
        *t_10 = *t_10 + (_S544 + _S545);
    }
    return;
}

void net_load_1(uint c_13, const Island_0 thread* isl_5, const Rigid_0 thread* rg_3, uint k_15, float dt_8, bool contact_2, float3 thread* f_6, float3 thread* t_11, KernelContext_0 thread* kernelContext_45)
{
    ChunkStatic_natural_0 device* _S546 = kernelContext_45->chunks_0+c_13;
    thread float3 fl_1;
    thread float3 tl_1;
    thread float3 rep_f_1;
    thread float3 rep_m_1;
    chunk_loads_0(c_13, c_13, &rg_3->rot_0, k_15, dt_8, contact_2, 0.0f, &fl_1, &tl_1, &rep_f_1, &rep_m_1, kernelContext_45);
    float4 _S547 = float4(_S546->center_0) ;
    float3 fc_1 = fl_1 + kernelContext_45->params_0->gravity_0.xyz * float3(_S547.w) ;
    float3 _S548 = _S547.xyz;
    float3 _S549 = isl_5->com_0.xyz;
    float3 _S550 = rotate_0(&rg_3->rot_0, _S548 + (float4(*(kernelContext_45->state_0+4U * c_13)) ).xyz - _S549);
    *f_6 = *f_6 + fc_1;
    *t_11 = *t_11 + (cross(_S550, fc_1) + tl_1);
    uint4 _S551 = uint4(_S546->load_range_0) ;
    if((_S551.y) > (_S551.x))
    {
        float3 _S552 = rotate_0(&rg_3->rot_0, rep_f_1);
        *f_6 = *f_6 + _S552;
        float3 _S553 = rotate_0(&rg_3->rot_0, _S548 - _S549);
        float3 _S554 = cross(_S553, _S552);
        float3 _S555 = rotate_0(&rg_3->rot_0, rep_m_1);
        *t_11 = *t_11 + (_S554 + _S555);
    }
    return;
}

void rigid_acceleration_0(const Island_natural_0 thread* isl_6, Rigid_0 thread* rg_4, float3 f_7, float3 t_12)
{
    float4 _S556 = float4(isl_6->inertia0_0) ;
    float4 _S557 = float4(isl_6->inertia1_0) ;
    float4 _S558 = float4(isl_6->inertia2_0) ;
    thread Quat_0 _S559 = rg_4->rot_0;
    float3 _S560 = world_mul_0(&_S559, _S556, _S557, _S558, rg_4->w_4);
    rg_4->a_7 = f_7 / float3((float4(isl_6->com_0) ).w) ;
    float4 _S561 = float4(isl_6->inv0_0) ;
    float4 _S562 = float4(isl_6->inv1_0) ;
    float4 _S563 = float4(isl_6->inv2_0) ;
    float3 _S564 = t_12 - cross(rg_4->w_4, _S560);
    thread Quat_0 _S565 = rg_4->rot_0;
    float3 _S566 = world_mul_0(&_S565, _S561, _S562, _S563, _S564);
    rg_4->alpha_0 = _S566;
    rg_4->torque_0 = t_12;
    return;
}

void rigid_acceleration_1(const Island_0 thread* isl_7, Rigid_0 thread* rg_5, float3 f_8, float3 t_13)
{
    thread Quat_0 _S567 = rg_5->rot_0;
    float3 _S568 = world_mul_0(&_S567, isl_7->inertia0_0, isl_7->inertia1_0, isl_7->inertia2_0, rg_5->w_4);
    rg_5->a_7 = f_8 / float3(isl_7->com_0.w) ;
    float3 _S569 = t_13 - cross(rg_5->w_4, _S568);
    thread Quat_0 _S570 = rg_5->rot_0;
    float3 _S571 = world_mul_0(&_S570, isl_7->inv0_0, isl_7->inv1_0, isl_7->inv2_0, _S569);
    rg_5->alpha_0 = _S571;
    rg_5->torque_0 = t_13;
    return;
}

bool is_damaged_0(const JointState_0 thread* st_0)
{
    bool _S572;
    if((st_0->damage_0) > 0.0f)
    {
        _S572 = true;
    }
    else
    {
        _S572 = (st_0->crush_1) > 0.0f;
    }
    return _S572;
}

bool connected_0(const JointState_0 thread* st_1, bool has_rebar_0)
{
    bool _S573;
    if((st_1->damage_0) < 1.0f)
    {
        _S573 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S573 = (st_1->rebar_broken_0) == 0.0f;
        }
        else
        {
            _S573 = false;
        }
    }
    return _S573;
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
    float4 _S574 = float4(b_23->geom0_0) ;
    float area_2 = _S574.x;
    float _S575 = q_lin_0.z;
    float axial_0 = (metal::fast::divide((_S575), (area_2)));
    float4 _S576 = float4(b_23->geom1_0) ;
    float _S577 = (metal::fast::divide((abs(q_ang_0.x)), (_S576.x)));
    float _S578 = (metal::fast::divide((abs(q_ang_0.y)), (_S576.y)));
    float bending_0 = _S577 + _S578;
    float _S579 = q_lin_0.x;
    float _S580 = q_lin_0.y;
    float _S581 = (metal::fast::sqrt((_S579 * _S579 + _S580 * _S580)));
    float _S582 = (metal::fast::divide((_S581), (area_2)));
    float _S583 = (metal::fast::divide((abs(q_ang_0.z)), (_S574.w)));
    float shear_1 = _S582 + _S583;
    thread Measures_0 m_3;
    (&m_3)->tension_0 = axial_0 + bending_0;
    (&m_3)->shear_0 = shear_1;
    float _S584 = - axial_0;
    (&m_3)->normal_compression_0 = max(_S584, 0.0f);
    (&m_3)->compression_0 = _S584 + bending_0;
    (&m_3)->compressive_force_0 = max(- _S575, 0.0f);
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
    float4 _S585 = mat_1->dif_0;
    float ref_0 = mat_1->dif_0.x;
    if(r_6 <= ref_0)
    {
        return 1.0f;
    }
    float _S586 = _S585.z;
    float f_9;
    if(r_6 <= _S586)
    {
        float _S587 = (metal::fast::divide((r_6), (ref_0)));
        float _S588 = (metal::fast::pow((_S587), (_S585.y)));
        f_9 = _S588;
    }
    else
    {
        float _S589 = (metal::fast::divide((_S586), (ref_0)));
        float _S590 = (metal::fast::pow((_S589), (_S585.y)));
        float _S591 = (metal::fast::divide((r_6), (_S586)));
        float _S592 = (metal::fast::pow((_S591), (_S585.w)));
        f_9 = _S590 * _S592;
    }
    return clamp(f_9, 1.0f, mat_1->misc_0.x);
}

float fatigue_factor_0(const JointMaterial_0 constant* mat_2, float life_1)
{
    if(((mat_2->kind_flags_0.y) & 64U) == 0U)
    {
        return 1.0f;
    }
    float _S593 = clamp(life_1, 0.0f, 1.0f);
    float _S594 = (metal::fast::divide((1.0f), (mat_2->misc_0.y - 2.0f)));
    float _S595 = (metal::fast::pow((_S593), (_S594)));
    return _S595;
}

float infinity_0()
{
    return (as_type<float>((2139095040U)));
}

float4 failure_indices_0(const JointMaterial_0 constant* mat_3, const JointBond_natural_0 thread* b_24, const Measures_0 thread* m_4, float multiplier_0)
{
    float fc_2 = mat_3->strength_0.y * multiplier_0;
    float _S596 = min(mat_3->strength_0.z * multiplier_0 + mat_3->strength_0.w * m_4->normal_compression_0, mat_3->energy_1.x * multiplier_0);
    thread float4 idx_0;
    float _S597 = (metal::fast::divide((m_4->tension_0), (mat_3->strength_0.x * multiplier_0)));
    idx_0.x = max(_S597, 0.0f);
    float _S598;
    if(_S596 > 0.0f)
    {
        float _S599 = (metal::fast::divide((m_4->shear_0), (_S596)));
        _S598 = _S599;
    }
    else
    {
        _S598 = infinity_0();
    }
    idx_0.y = _S598;
    float _S600 = (metal::fast::divide((m_4->compression_0), (fc_2)));
    idx_0.z = max(_S600, 0.0f);
    float _S601 = (float4(b_24->stiff1_0) ).y;
    if(_S601 > 0.0f)
    {
        float _S602 = (metal::fast::divide((m_4->compressive_force_0), (_S601)));
        _S598 = _S602;
    }
    else
    {
        _S598 = 0.0f;
    }
    idx_0.w = _S598;
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
        float _S603 = (metal::fast::divide((r_7 * (kappa_1 - 1.0f)), (kappa_1 * (r_7 - 1.0f))));
        return min(_S603, 1.0f);
    }
    if(kappa_1 >= (0.5f * (r_7 + 1.0f)))
    {
        return 1.0f;
    }
    float _S604 = (metal::fast::divide((1.0f), (kappa_1)));
    return 1.0f - _S604;
}

__attribute__((noinline))
float2 damage_increment_0(uint kind_2, float kappa_old_0, float lambda_0, float r_8, float d_old_0, float psi_0)
{
    float _S605 = damage_law_0(kind_2, lambda_0, r_8);
    float _S606 = max(_S605, d_old_0);
    bool _S607;
    if(_S606 <= d_old_0)
    {
        _S607 = true;
    }
    else
    {
        _S607 = d_old_0 >= 1.0f;
    }
    if(_S607)
    {
        return float2(d_old_0, 0.0f);
    }
    float u0_0 = (metal::fast::divide((psi_0), (lambda_0 * lambda_0)));
    float _S608 = max(kappa_old_0, 1.0f);
    if(kind_2 == 0U)
    {
        if(r_8 > 1.0f)
        {
            float _S609 = (metal::fast::divide((u0_0 * r_8), (r_8 - 1.0f)));
            return float2(_S606, _S609 * max(min(lambda_0, r_8) - min(_S608, r_8), 0.0f));
        }
        return float2(_S606, (1.0f - d_old_0) * psi_0);
    }
    float ku_0 = 0.5f * (r_8 + 1.0f);
    float plateau_0 = u0_0 * max(min(lambda_0, ku_0) - min(_S608, ku_0), 0.0f);
    float snap_0;
    if(_S606 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return float2(_S606, plateau_0 + snap_0);
}

void compressed_region_0(float w0_0, float w1_0, float dz_0, float ax_0, float ay_0, array<float, int(6)> thread* region_0)
{
    uint count_4;
    float h0_0 = 0.5f * w0_0;
    float h1_0 = 0.5f * w1_0;
    float _S610 = - h0_0;
    float _S611 = - h1_0;
    array<float2, int(4)> _S612 = { { float2(_S610, _S611), float2(h0_0, _S611), float2(h0_0, h1_0), float2(_S610, h1_0) } };
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
        uint _S613 = i_6;
        uint _S614 = i_6 + 1U;
        uint _S615 = _S614 % 4U;
        float _S616 = _S612[i_6].y;
        float _S617 = _S612[i_6].x;
        float fp_0 = dz_0 + ax_0 * _S616 - ay_0 * _S617;
        float _S618 = _S612[_S615].y;
        float _S619 = _S612[_S615].x;
        float fq_0 = dz_0 + ax_0 * _S618 - ay_0 * _S619;
        bool _S620 = fp_0 < 0.0f;
        if(_S620)
        {
            uint _S621 = count_5 + 1U;
            poly_0[count_5] = _S612[_S613];
            count_4 = _S621;
        }
        else
        {
            count_4 = count_5;
        }
        if(_S620 != (fq_0 < 0.0f))
        {
            float t_14 = fp_0 / (fp_0 - fq_0);
            uint _S622 = count_4 + 1U;
            poly_0[count_4] = float2(_S617 + t_14 * (_S619 - _S617), _S616 + t_14 * (_S618 - _S616));
            count_5 = _S622;
        }
        else
        {
            count_5 = count_4;
        }
        i_6 = _S614;
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
        float _S623 = o_1.x;
        float x0_0 = poly_0[i_6].x - _S623;
        float _S624 = o_1.y;
        float y0_0 = poly_0[i_6].y - _S624;
        uint _S625 = i_6 + 1U;
        uint _S626 = _S625 % count_5;
        float x1_0 = poly_0[_S626].x - _S623;
        float y1_0 = poly_0[_S626].y - _S624;
        float _S627 = x0_0 * y1_0;
        float _S628 = x1_0 * y0_0;
        float cr_0 = _S627 - _S628;
        float a_9 = a_8 + cr_0 / 2.0f;
        float sx_1 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        float sy_1 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        float ixx_1 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        float iyy_1 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        float ixy_1 = ixy_0 + (_S627 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S628) * cr_0 / 24.0f;
        i_6 = _S625;
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
    float _S629 = a_8 * cx_0;
    (*region_0)[int(3)] = ixx_0 - _S629 * cx_0;
    (*region_0)[int(4)] = iyy_0 - a_8 * cy_0 * cy_0;
    (*region_0)[int(5)] = ixy_0 - _S629 * cy_0;
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
    float _S630 = a_10 * fc_3;
    float _S631 = - ay_1;
    return float4(k_16 * a_10 * fc_3, k_16 * (_S630 * r_9[int(2)] + (_S631 * r_9[int(5)] + ax_1 * r_9[int(4)])), - k_16 * (_S630 * r_9[int(1)] + (_S631 * r_9[int(3)] + ax_1 * r_9[int(5)])), 0.5f * k_16 * (_S630 * fc_3 + ay_1 * ay_1 * r_9[int(3)] + ax_1 * ax_1 * r_9[int(4)] - 2.0f * ax_1 * ay_1 * r_9[int(5)]));
}

float signum_0(float x_13)
{
    float _S632;
    if(((as_type<uint>((x_13))) & 2147483648U) != 0U)
    {
        _S632 = -1.0f;
    }
    else
    {
        _S632 = 1.0f;
    }
    return _S632;
}

float2 return_map_0(float k_17, float total_2, float plastic_0, float cap_0)
{
    float trial_0 = k_17 * (total_2 - plastic_0);
    if((abs(trial_0)) <= cap_0)
    {
        return float2(trial_0, 0.0f);
    }
    float f_10 = cap_0 * signum_0(trial_0);
    float _S633 = (metal::fast::divide((trial_0 - f_10), (k_17)));
    return float2(f_10, _S633);
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
    float3 _S634 = float3(0.0f) ;
    (&c_14)->q_lin_1 = _S634;
    (&c_14)->q_ang_1 = _S634;
    (&c_14)->energy_2 = 0.0f;
    (&c_14)->diss_4 = 0.0f;
    (&c_14)->plastic_1 = plastic_2;
    uint _S635 = mat_4->kind_flags_0.y;
    if((_S635 & 2U) == 0U)
    {
        return c_14;
    }
    float4 _S636 = float4(b_25->stiff0_0) ;
    float kn_1 = _S636.x;
    float ks_0 = _S636.y;
    float kt_0 = (float4(b_25->stiff1_0) ).x;
    float4 _S637 = float4(b_25->geom0_0) ;
    float w0_2 = _S637.y;
    float w1_2 = _S637.z;
    float diss_5;
    float nc_sum_0;
    float m1_0;
    float m2_0;
    float energy_3;
    if((_S635 & 4U) != 0U)
    {
        float4 p_11 = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        float _S638 = p_11.y;
        float _S639 = p_11.z;
        float _S640 = p_11.w;
        nc_sum_0 = p_11.x;
        m1_0 = _S638;
        m2_0 = _S639;
        energy_3 = _S640;
    }
    else
    {
        float ki_0 = kn_1 * (1.0f - crush_2) / 36.0f;
        float _S641 = d_ang_0.x;
        float _S642 = d_ang_0.y;
        float spread_0 = abs(_S641) * 0.4166666567325592f * w1_2 + abs(_S642) * 0.4166666567325592f * w0_2;
        float _S643 = d_lin_0.z;
        float slack_0 = 9.99999997475242708e-07f * (abs(_S643) + spread_0);
        if((_S643 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S643 + spread_0) < (- slack_0))
            {
                float i1_0 = 2.91666650772094727f * w0_2 * w0_2;
                float i2_0 = 2.91666650772094727f * w1_2 * w1_2;
                float _S644 = ki_0 * _S641 * i2_0;
                float _S645 = ki_0 * _S642 * i1_0;
                float _S646 = 0.5f * ki_0 * (36.0f * _S643 * _S643 + _S641 * _S641 * i2_0 + _S642 * _S642 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S643;
                m1_0 = _S644;
                m2_0 = _S645;
                energy_3 = _S646;
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
                    float _S647 = SPRING_AT_0[i_7] * w0_2;
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
                        float di_0 = _S643 + _S641 * s2_0 - _S642 * _S647;
                        if(di_0 < 0.0f)
                        {
                            float f_11 = ki_0 * di_0;
                            float m1_2 = m1_0 + f_11 * s2_0;
                            float m2_2 = m2_0 - f_11 * _S647;
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
    float _S648 = ks_0 * (d_lin_0.x - plastic_2.x);
    float _S649 = ks_0 * (d_lin_0.y - plastic_2.y);
    float tn_0 = (metal::fast::sqrt((_S648 * _S648 + _S649 * _S649)));
    bool _S650;
    if(tn_0 > slide_cap_0)
    {
        _S650 = tn_0 > 0.0f;
    }
    else
    {
        _S650 = false;
    }
    if(_S650)
    {
        float _S651 = (metal::fast::divide((_S648), (tn_0)));
        float _S652 = (metal::fast::divide((_S649), (tn_0)));
        float dslip_0 = (metal::fast::divide((tn_0 - slide_cap_0), (ks_0)));
        p_12.x = p_12.x + _S651 * dslip_0;
        p_12.y = p_12.y + _S652 * dslip_0;
        (&c_14)->q_lin_1.x = _S651 * slide_cap_0;
        (&c_14)->q_lin_1.y = _S652 * slide_cap_0;
        diss_5 = slide_cap_0 * dslip_0;
    }
    else
    {
        (&c_14)->q_lin_1.x = _S648;
        (&c_14)->q_lin_1.y = _S649;
        diss_5 = 0.0f;
    }
    float2 tq_0 = return_map_0(kt_0, d_ang_0.z, p_12.z, slide_cap_0 * (float4(b_25->geom1_0) ).z);
    float _S653 = tq_0.x;
    float _S654 = tq_0.y;
    float diss_6 = diss_5 + abs(_S653) * abs(_S654);
    p_12.z = p_12.z + _S654;
    (&c_14)->q_ang_1.z = _S653;
    float _S655 = (metal::fast::divide((sq_0((&c_14)->q_lin_1.x)), (ks_0)));
    float _S656 = (metal::fast::divide((sq_0((&c_14)->q_lin_1.y)), (ks_0)));
    float _S657 = _S655 + _S656;
    float _S658 = (metal::fast::divide((sq_0(_S653)), (kt_0)));
    (&c_14)->energy_2 = energy_3 + 0.5f * (_S657 + _S658);
    (&c_14)->diss_4 = diss_6;
    (&c_14)->plastic_1 = p_12;
    return c_14;
}

float3 contact_offsets_0(const JointMaterial_0 constant* mat_5, const JointBond_natural_0 thread* b_26, float crush_3, float3 plastic_3, float3 d_lin_1, float3 d_ang_1)
{
    uint _S659 = mat_5->kind_flags_0.y;
    if((_S659 & 2U) == 0U)
    {
        return plastic_3;
    }
    float4 _S660 = float4(b_26->stiff0_0) ;
    float kn_2 = _S660.x;
    float ks_1 = _S660.y;
    float kt_1 = (float4(b_26->stiff1_0) ).x;
    float4 _S661 = float4(b_26->geom0_0) ;
    float w0_3 = _S661.y;
    float w1_3 = _S661.z;
    float nc_sum_1;
    if((_S659 & 4U) != 0U)
    {
        float4 _S662 = no_tension_patch_0(kn_2 * (1.0f - crush_3), w0_3, w1_3, d_lin_1.z, d_ang_1.x, d_ang_1.y);
        nc_sum_1 = _S662.x;
    }
    else
    {
        float ki_1 = kn_2 * (1.0f - crush_3) / 36.0f;
        float _S663 = d_ang_1.x;
        float _S664 = d_ang_1.y;
        float spread_1 = abs(_S663) * 0.4166666567325592f * w1_3 + abs(_S664) * 0.4166666567325592f * w0_3;
        float _S665 = d_lin_1.z;
        float slack_1 = 9.99999997475242708e-07f * (abs(_S665) + spread_1);
        if((_S665 - spread_1) > slack_1)
        {
            nc_sum_1 = 0.0f;
        }
        else
        {
            if((_S665 + spread_1) < (- slack_1))
            {
                nc_sum_1 = ki_1 * 36.0f * _S665;
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
                    float _S666 = SPRING_AT_0[i_8] * w0_3;
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
                        float di_1 = _S665 + _S663 * (SPRING_AT_0[j_7] * w1_3) - _S664 * _S666;
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
    float _S667 = ks_1 * (d_lin_1.x - plastic_3.x);
    float _S668 = ks_1 * (d_lin_1.y - plastic_3.y);
    float tn_1 = (metal::fast::sqrt((_S667 * _S667 + _S668 * _S668)));
    bool _S669;
    if(tn_1 > slide_cap_1)
    {
        _S669 = tn_1 > 0.0f;
    }
    else
    {
        _S669 = false;
    }
    if(_S669)
    {
        float _S670 = (metal::fast::divide((_S667), (tn_1)));
        float _S671 = (metal::fast::divide((_S668), (tn_1)));
        float dslip_1 = (metal::fast::divide((tn_1 - slide_cap_1), (ks_1)));
        p_13.x = p_13.x + _S670 * dslip_1;
        p_13.y = p_13.y + _S671 * dslip_1;
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
    float _S672 = mat_6->misc_0.y;
    float _S673 = _S672 + 1.0f;
    float _S674 = (metal::fast::pow((s_5), (_S672)));
    float _S675 = (metal::fast::divide((_S673 * _S674), (mat_6->misc_0.z)));
    return _S675;
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
    float4 _S676 = float4(b_27->stiff0_0) ;
    float kn_3 = _S676.x;
    float ks_2 = _S676.y;
    float kb1_0 = _S676.z;
    float kb2_0 = _S676.w;
    float4 _S677 = float4(b_27->stiff1_0) ;
    float kt_2 = _S677.x;
    bool has_rebar_1 = (_S677.w) != 0.0f;
    uint kind_3 = mat_7->kind_flags_0.x;
    uint flags_1 = mat_7->kind_flags_0.y;
    bool softening_0 = (flags_1 & 1U) != 0U;
    thread JointState_0 st_2 = *state_7;
    bool _S678 = connected_0(state_7, has_rebar_1);
    float3 qe_lin_0 = d_lin_2 * float3(ks_2, ks_2, kn_3);
    float3 qe_ang_0 = d_ang_2 * float3(kb1_0, kb2_0, kt_2);
    Measures_0 _S679 = stress_measures_0(b_27, qe_lin_0, qe_ang_0);
    float _S680 = max(max(_S679.tension_0, _S679.shear_0), _S679.compression_0);
    bool _S681 = dt_9 > 0.0f;
    float dif_1;
    if(_S681)
    {
        float _S682 = (metal::fast::divide((_S680 - (&st_2)->governing_stress_0), (dt_9)));
        float raw_0 = (metal::fast::divide((max(_S682, 0.0f)), (mat_7->misc_0.w)));
        float tau_2 = _S677.z;
        if((flags_1 & 16U) != 0U)
        {
            float _S683 = (metal::fast::divide((dt_9), (tau_2)));
            dif_1 = - expm1_accurate_0(- _S683);
        }
        else
        {
            float _S684 = (metal::fast::divide((dt_9), (tau_2)));
            dif_1 = min(_S684, 1.0f);
        }
        (&st_2)->strain_rate_0 = (&st_2)->strain_rate_0 + (raw_0 - (&st_2)->strain_rate_0) * dif_1;
        (&st_2)->governing_stress_0 = _S680;
    }
    if((flags_1 & 32U) != 0U)
    {
        float _S685 = dif_factor_0(mat_7, (&st_2)->strain_rate_0);
        dif_1 = _S685;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = (float4(b_27->geom1_0) ).w;
    float _S686 = fatigue_factor_0(mat_7, (&st_2)->life_0);
    float multiplier_1 = weibull_0 * dif_1 * _S686;
    thread Measures_0 _S687 = _S679;
    float4 _S688 = failure_indices_0(mat_7, b_27, &_S687, multiplier_1);
    float _S689 = _S688.x;
    float _S690 = _S688.y;
    (&st_2)->utilization_0 = max(max(_S689, _S690), max(_S688.z, _S688.w));
    float _S691 = d_lin_2.x;
    float _S692 = d_lin_2.y;
    float _S693 = ks_2 * (sq_0(_S691) + sq_0(_S692)) + kb1_0 * sq_0(d_ang_2.x) + kb2_0 * sq_0(d_ang_2.y) + kt_2 * sq_0(d_ang_2.z);
    float _S694 = d_lin_2.z;
    bool _S695 = _S694 > 0.0f;
    if(_S695)
    {
        dif_1 = kn_3 * sq_0(_S694);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S693 + dif_1);
    float psi_c_0;
    if(_S694 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_3 * sq_0(_S694);
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
    bool _S696;
    float3 qc_lin_0;
    if(fracture_1)
    {
        bool _S697 = _S689 >= _S690;
        if(_S697)
        {
            diss_contact_0 = _S689;
        }
        else
        {
            diss_contact_0 = _S690;
        }
        uint mode_ts_0;
        if(_S697)
        {
            mode_ts_0 = 1U;
        }
        else
        {
            mode_ts_0 = 2U;
        }
        if(diss_contact_0 > ((&st_2)->kappa_0))
        {
            _S696 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S696 = false;
        }
        if(_S696)
        {
            _S696 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S696 = false;
        }
        uint mode_c_0;
        if(_S696)
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
                float _S698 = (metal::fast::divide((psi_contact_0 * (float4(b_27->geom0_0) ).x * diss_contact_0 * diss_contact_0), (psi_ts_0)));
                intact_normal_0 = _S698;
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
            float _S699 = inc_0.x;
            if(_S699 > ((&st_2)->damage_0))
            {
                Contact_0 _S700 = contact_part_0(mat_7, b_27, (&st_2)->crush_1, plastic_4, d_lin_2, d_ang_2);
                float _S701 = max(_S700.energy_2 - (1.0f - (&st_2)->crush_1) * psi_c_0, 0.0f);
                float _S702 = max(inc_0.y - _S701 * (_S699 - (&st_2)->damage_0), 0.0f);
                float _S703 = max((psi_ts_0 - _S701) * (_S699 - (&st_2)->damage_0) - _S702, 0.0f);
                (&st_2)->damage_0 = _S699;
                (&st_2)->mode_0 = mode_ts_0;
                dissipated_3 = _S702;
                overshoot_1 = _S703;
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
        float _S704 = state_7->damage_0;
        if((state_7->damage_0) > 0.0f)
        {
            Contact_0 _S705 = contact_part_0(mat_7, b_27, state_7->crush_1, float3(state_7->plastic_x_0, state_7->plastic_y_0, state_7->plastic_t_0), d_lin_2, d_ang_2);
            qc_lin_0 = qe_ang_0 * float3((1.0f - _S704))  + _S705.q_ang_1 * float3(_S704) ;
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S706 = stress_measures_0(b_27, float3(0.0f, 0.0f, min(qe_lin_0.z, 0.0f)), qc_lin_0);
        thread Measures_0 _S707 = _S706;
        float4 _S708 = failure_indices_0(mat_7, b_27, &_S707, multiplier_1);
        float _S709 = _S708.z;
        float _S710 = _S708.w;
        bool _S711 = _S709 >= _S710;
        if(_S711)
        {
            psi_contact_0 = _S709;
        }
        else
        {
            psi_contact_0 = _S710;
        }
        if(_S711)
        {
            mode_c_0 = 3U;
        }
        else
        {
            mode_c_0 = 4U;
        }
        if(psi_contact_0 > ((&st_2)->kappa_c_0))
        {
            _S696 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S696 = false;
        }
        if(_S696)
        {
            _S696 = psi_c_0 > 0.0f;
        }
        else
        {
            _S696 = false;
        }
        if(_S696)
        {
            if(softening_0)
            {
                float _S712 = (metal::fast::divide((mat_7->energy_1.w * (float4(b_27->geom0_0) ).x * psi_contact_0 * psi_contact_0), (psi_c_0)));
                intact_normal_0 = _S712;
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
            float _S713 = inc_1.x;
            if(_S713 > ((&st_2)->crush_1))
            {
                float _S714 = inc_1.y;
                float dissipated_4 = dissipated_3 + _S714;
                float overshoot_2 = overshoot_1 + max(psi_c_0 * (_S713 - (&st_2)->crush_1) - _S714, 0.0f);
                (&st_2)->crush_1 = _S713;
                (&st_2)->mode_0 = mode_c_0;
                if(_S713 >= 1.0f)
                {
                    _S696 = ((&st_2)->damage_0) < 1.0f;
                }
                else
                {
                    _S696 = false;
                }
                if(_S696)
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
    float3 _S715 = float3(0.0f) ;
    float3 qc_ang_0;
    if(((&st_2)->damage_0) == 0.0f)
    {
        if((flags_1 & 8U) == 0U)
        {
            float3 _S716 = contact_offsets_0(mat_7, b_27, (&st_2)->crush_1, plastic_4, d_lin_2, d_ang_2);
            (&st_2)->plastic_x_0 = _S716.x;
            (&st_2)->plastic_y_0 = _S716.y;
            (&st_2)->plastic_t_0 = _S716.z;
        }
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S715;
        qc_ang_0 = _S715;
        psi_contact_0 = 0.0f;
    }
    else
    {
        Contact_0 _S717 = contact_part_0(mat_7, b_27, (&st_2)->crush_1, plastic_4, d_lin_2, d_ang_2);
        (&st_2)->plastic_x_0 = _S717.plastic_1.x;
        (&st_2)->plastic_y_0 = _S717.plastic_1.y;
        (&st_2)->plastic_t_0 = _S717.plastic_1.z;
        diss_contact_0 = _S717.diss_4;
        qc_lin_0 = _S717.q_lin_1;
        qc_ang_0 = _S717.q_ang_1;
        psi_contact_0 = _S717.energy_2;
    }
    float dissipated_6 = dissipated_3 + dmg_0 * diss_contact_0;
    if(_S695)
    {
        intact_normal_0 = kn_3 * _S694;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_2)->crush_1) * kn_3 * _S694;
    }
    float _S718 = 1.0f - dmg_0;
    float3 force_lin_2 = float3(_S718 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S718 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S718 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3 force_ang_2 = qe_ang_0 * float3(_S718)  + qc_ang_0 * float3(dmg_0) ;
    float stored_6 = _S718 * (psi_ts_0 + (1.0f - (&st_2)->crush_1) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S696 = ((&st_2)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S696 = false;
    }
    float stored_7;
    float3 force_lin_3;
    if(_S696)
    {
        float4 _S719 = float4(b_27->rebar0_0) ;
        float k_axial_0 = _S719.x;
        float k_dowel_0 = _S719.y;
        float yield_force_0 = _S719.z;
        float dowel_capacity_0 = _S719.w;
        float2 nr_0 = return_map_0(k_axial_0, _S694, (&st_2)->rebar_plastic_0, yield_force_0);
        float2 v1_0 = return_map_0(k_dowel_0, _S691, (&st_2)->rebar_slip0_0, dowel_capacity_0);
        float2 v2_0 = return_map_0(k_dowel_0, _S692, (&st_2)->rebar_slip1_0, dowel_capacity_0);
        float _S720 = nr_0.y;
        float _S721 = v1_0.y;
        float _S722 = v2_0.y;
        float work_0 = yield_force_0 * abs(_S720) + dowel_capacity_0 * (abs(_S721) + abs(_S722));
        (&st_2)->rebar_plastic_0 = (&st_2)->rebar_plastic_0 + _S720;
        (&st_2)->rebar_slip0_0 = (&st_2)->rebar_slip0_0 + _S721;
        (&st_2)->rebar_slip1_0 = (&st_2)->rebar_slip1_0 + _S722;
        (&st_2)->rebar_work_0 = (&st_2)->rebar_work_0 + work_0;
        float dissipated_7 = dissipated_6 + work_0;
        float _S723 = nr_0.x;
        float _S724 = (metal::fast::divide((sq_0(_S723)), (k_axial_0)));
        float _S725 = v1_0.x;
        float _S726 = v2_0.x;
        float _S727 = (metal::fast::divide((sq_0(_S725) + sq_0(_S726)), (k_dowel_0)));
        float elastic_0 = 0.5f * (_S724 + _S727);
        if(fracture_1)
        {
            _S696 = ((&st_2)->rebar_work_0) >= ((float4(b_27->rebar1_0) ).x);
        }
        else
        {
            _S696 = false;
        }
        if(_S696)
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
            force_lin_3 = force_lin_2 + float3(_S725, _S726, _S723);
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
        _S696 = _S681;
    }
    else
    {
        _S696 = false;
    }
    if(_S696)
    {
        _S696 = (flags_1 & 64U) != 0U;
    }
    else
    {
        _S696 = false;
    }
    if(_S696)
    {
        Measures_0 _S728 = stress_measures_0(b_27, force_lin_3, force_ang_2);
        thread Measures_0 _S729 = _S728;
        float4 _S730 = failure_indices_0(mat_7, b_27, &_S729, weibull_0);
        float _S731 = life_rate_0(mat_7, max(max(_S730.x, _S730.y), _S730.z));
        (&st_2)->life_0 = max((&st_2)->life_0 - _S731 * dt_9, 0.0f);
    }
    (&st_2)->dissipated_0 = (&st_2)->dissipated_0 + dissipated_3;
    thread JointResponse_0 resp_0;
    (&resp_0)->force_lin_1 = force_lin_3;
    (&resp_0)->force_ang_1 = force_ang_2;
    (&resp_0)->state_6 = st_2;
    (&resp_0)->dissipated_2 = dissipated_3;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_5 = stored_7;
    if(_S678)
    {
        thread JointState_0 _S732 = st_2;
        bool _S733 = connected_0(&_S732, has_rebar_1);
        _S696 = !_S733;
    }
    else
    {
        _S696 = false;
    }
    (&resp_0)->disconnected_0 = _S696;
    (&resp_0)->fatigue_before_0 = _S686;
    (&resp_0)->measures_0 = _S679;
    return resp_0;
}

void secant_factors_0(const JointBond_natural_0 thread* b_28, const JointState_0 thread* st_3, float3 d_lin_3, float3 thread* f_lin_0, float3 thread* f_ang_0)
{
    float _S734 = st_3->damage_0;
    bool compressed_0 = (d_lin_3.z) < 0.0f;
    float contact_3;
    if(compressed_0)
    {
        contact_3 = _S734;
    }
    else
    {
        contact_3 = 0.0f;
    }
    float _S735 = 1.0f - _S734;
    float _S736 = max(_S735 + contact_3, 9.99999997475242708e-07f);
    float normal_5;
    if(compressed_0)
    {
        normal_5 = max(1.0f - st_3->crush_1, 9.99999997475242708e-07f);
    }
    else
    {
        normal_5 = max(_S735, 9.99999997475242708e-07f);
    }
    *f_lin_0 = float3(_S736, _S736, normal_5);
    *f_ang_0 = float3(_S736) ;
    bool _S737;
    if(((float4(b_28->stiff1_0) ).w) != 0.0f)
    {
        _S737 = (st_3->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S737 = false;
    }
    if(_S737)
    {
        float4 _S738 = float4(b_28->rebar0_0) ;
        float4 _S739 = float4(b_28->stiff0_0) ;
        float _S740 = (metal::fast::divide((_S738.x), (_S739.x)));
        (*f_lin_0).z = (*f_lin_0).z + _S740;
        float _S741 = _S738.y;
        float _S742 = _S739.y;
        float _S743 = (metal::fast::divide((_S741), (_S742)));
        (*f_lin_0).x = (*f_lin_0).x + _S743;
        float _S744 = (metal::fast::divide((_S741), (_S742)));
        (*f_lin_0).y = (*f_lin_0).y + _S744;
    }
    return;
}

float3 to_local_0(uint _S745, float3 _S746, KernelContext_0 thread* kernelContext_46)
{
    BondStatic_natural_0 device* _S747 = kernelContext_46->bonds_0+_S745;
    return float3(dot(_S746, (float4(_S747->t1_0) ).xyz), dot(_S746, (float4(_S747->t2_0) ).xyz), dot(_S746, (float4(_S747->normal_0) ).xyz));
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

float3 to_body_0(uint _S748, float3 _S749, KernelContext_0 thread* kernelContext_47)
{
    BondStatic_natural_0 device* _S750 = kernelContext_47->bonds_0+_S748;
    return (float4(_S750->t1_0) ).xyz * float3(_S749.x)  + (float4(_S750->t2_0) ).xyz * float3(_S749.y)  + (float4(_S750->normal_0) ).xyz * float3(_S749.z) ;
}

bool bond_update_0(uint i_9, float dt_10, bool fracture_2, uint abs_step_0, bool wide_0, KernelContext_0 thread* kernelContext_48)
{
    BondStatic_natural_0 device* _S751 = kernelContext_48->bonds_0+i_9;
    uint4 _S752 = uint4(_S751->law_0.ids_0) ;
    float3 ra_1 = (float4(_S751->ra_0) ).xyz;
    float3 rb_1 = (float4(_S751->rb_0) ).xyz;
    uint _S753 = 4U * _S752.y;
    float3 ta_2 = (float4(*(kernelContext_48->state_0+(_S753 + 1U))) ).xyz;
    float3 va_0 = (float4(*(kernelContext_48->state_0+(_S753 + 2U))) ).xyz;
    float3 wa_1 = (float4(*(kernelContext_48->state_0+(_S753 + 3U))) ).xyz;
    uint _S754 = 4U * _S752.z;
    float3 tb_2 = (float4(*(kernelContext_48->state_0+(_S754 + 1U))) ).xyz;
    float3 vb_0 = (float4(*(kernelContext_48->state_0+(_S754 + 2U))) ).xyz;
    float3 wb_1 = (float4(*(kernelContext_48->state_0+(_S754 + 3U))) ).xyz;
    float3 _S755 = to_local_0(i_9, (float4(*(kernelContext_48->state_0+_S754)) ).xyz + cross(tb_2, rb_1) - ((float4(*(kernelContext_48->state_0+_S753)) ).xyz + cross(ta_2, ra_1)), kernelContext_48);
    float3 _S756 = to_local_0(i_9, tb_2 - ta_2, kernelContext_48);
    float3 _S757 = to_local_0(i_9, vb_0 + cross(wb_1, rb_1) - (va_0 + cross(wa_1, ra_1)), kernelContext_48);
    float3 _S758 = to_local_0(i_9, wb_1 - wa_1, kernelContext_48);
    JointState_0 previous_0 = (kernelContext_48->bond_dyn_0+i_9)->js_0;
    thread JointState_0 _S759 = (kernelContext_48->bond_dyn_0+i_9)->js_0;
    bool _S760 = is_damaged_0(&_S759);
    thread JointBond_natural_0 _S761 = (kernelContext_48->bonds_0+i_9)->law_0;
    thread JointState_0 _S762 = (kernelContext_48->bond_dyn_0+i_9)->js_0;
    JointResponse_0 _S763 = joint_evaluate_0(&kernelContext_48->materials_0->m_0[(uint4((kernelContext_48->bonds_0+i_9)->law_0.ids_0) ).x], &_S761, &_S762, _S755, _S756, dt_10, fracture_2);
    BondStatic_natural_0 device* _S764 = kernelContext_48->bonds_0+i_9;
    BondDyn_natural_0 device* _S765 = kernelContext_48->bond_dyn_0+i_9;
    float4 _S766 = float4((*_S765).force_lin_0) ;
    float4 _S767 = float4((*_S765).force_ang_0) ;
    float4 _S768 = float4((*_S765).sums_0) ;
    float4 _S769 = float4((*_S765).comps_0) ;
    uint4 _S770 = uint4((*_S765).events_0) ;
    thread BondDyn_0 bd_0;
    (&bd_0)->js_0 = (*_S765).js_0;
    (&bd_0)->force_lin_0 = _S766;
    (&bd_0)->force_ang_0 = _S767;
    (&bd_0)->sums_0 = _S768;
    (&bd_0)->comps_0 = _S769;
    (&bd_0)->events_0 = _S770;
    float3 ra_2 = (float4(_S764->ra_0) ).xyz;
    float3 rb_2 = (float4(_S764->rb_0) ).xyz;
    thread JointBond_natural_0 _S771 = _S764->law_0;
    thread JointState_0 _S772 = _S763.state_6;
    thread float3 f_lin_1;
    thread float3 f_ang_1;
    secant_factors_0(&_S771, &_S772, _S755, &f_lin_1, &f_ang_1);
    float3 qd_lin_0 = _S757 * (float4(_S764->c_lin_0) ).xyz * f_lin_1;
    float3 qd_ang_0 = _S758 * (float4(_S764->c_ang_0) ).xyz * f_ang_1;
    float3 q_lin_2 = _S763.force_lin_1 + qd_lin_0;
    float3 q_ang_2 = _S763.force_ang_1 + qd_ang_0;
    float damped_0 = (dot(qd_lin_0, _S757) + dot(qd_ang_0, _S758)) * dt_10;
    float3 _S773 = to_body_0(i_9, q_lin_2, kernelContext_48);
    float3 _S774 = to_body_0(i_9, q_ang_2, kernelContext_48);
    uint _S775 = 3U * i_9;
    *(kernelContext_48->scratch_0+_S775) = packed_float4(float4(_S773, max(_S763.measures_0.tension_0, _S763.measures_0.compression_0))) ;
    *(kernelContext_48->scratch_0+(_S775 + 1U)) = packed_float4(float4(_S774 + cross(ra_2, _S773), 0.0f)) ;
    *(kernelContext_48->scratch_0+(_S775 + 2U)) = packed_float4(float4(- _S774 + cross(rb_2, - _S773), 0.0f)) ;
    thread float _S776 = (&bd_0)->sums_0.x;
    thread float _S777 = (&bd_0)->comps_0.x;
    comp_add1_0(&_S776, &_S777, _S763.dissipated_2);
    (&bd_0)->comps_0.x = _S777;
    (&bd_0)->sums_0.x = _S776;
    thread float _S778 = (&bd_0)->sums_0.y;
    thread float _S779 = (&bd_0)->comps_0.y;
    comp_add1_0(&_S778, &_S779, _S763.overshoot_0);
    (&bd_0)->comps_0.y = _S779;
    (&bd_0)->sums_0.y = _S778;
    thread float _S780 = (&bd_0)->sums_0.z;
    thread float _S781 = (&bd_0)->comps_0.z;
    comp_add1_0(&_S780, &_S781, damped_0);
    (&bd_0)->comps_0.z = _S781;
    (&bd_0)->sums_0.z = _S780;
    (&bd_0)->force_lin_0 = float4(q_lin_2, _S763.stored_5);
    (&bd_0)->force_ang_0 = float4(q_ang_2, max((&bd_0)->force_ang_0.w, _S763.state_6.utilization_0));
    bool _S782;
    if(!_S760)
    {
        thread JointState_0 _S783 = _S763.state_6;
        bool _S784 = is_damaged_0(&_S783);
        _S782 = _S784;
    }
    else
    {
        _S782 = false;
    }
    if(_S782)
    {
        _S782 = ((&bd_0)->events_0.x) == 0U;
    }
    else
    {
        _S782 = false;
    }
    if(_S782)
    {
        (&bd_0)->events_0.x = abs_step_0;
        (&bd_0)->events_0.w = _S763.state_6.mode_0;
        if(wide_0)
        {
            cov_or_0((uint4((&_S771)->ids_0) ).w, 32U, kernelContext_48);
        }
        else
        {
            (*kernelContext_48->g_seen_0)[3U] = 1U;
        }
    }
    if(((&bd_0)->events_0.y) == 0U)
    {
        _S782 = (_S763.state_6.life_0) != (previous_0.life_0);
    }
    else
    {
        _S782 = false;
    }
    if(_S782)
    {
        _S782 = (_S763.fatigue_before_0) > 0.99000000953674316f;
    }
    else
    {
        _S782 = false;
    }
    if(_S782)
    {
        float _S785 = fatigue_factor_0(&kernelContext_48->materials_0->m_0[(uint4((kernelContext_48->bonds_0+i_9)->law_0.ids_0) ).x], _S763.state_6.life_0);
        _S782 = _S785 <= 0.99000000953674316f;
    }
    else
    {
        _S782 = false;
    }
    if(_S782)
    {
        (&bd_0)->events_0.y = abs_step_0;
        if(wide_0)
        {
            cov_or_0((uint4((&_S771)->ids_0) ).w, 64U, kernelContext_48);
        }
        else
        {
            (*kernelContext_48->g_seen_0)[4U] = 1U;
        }
    }
    if(_S763.disconnected_0)
    {
        (&bd_0)->events_0.z = abs_step_0;
    }
    (&bd_0)->js_0 = _S763.state_6;
    BondDyn_natural_0 device* _S786 = kernelContext_48->bond_dyn_0+i_9;
    _S786->js_0 = bd_0.js_0;
    _S786->force_lin_0 = packed_float4(bd_0.force_lin_0) ;
    _S786->force_ang_0 = packed_float4(bd_0.force_ang_0) ;
    _S786->sums_0 = packed_float4(bd_0.sums_0) ;
    _S786->comps_0 = packed_float4(bd_0.comps_0) ;
    _S786->events_0 = packed_uint4(bd_0.events_0) ;
    return _S763.disconnected_0;
}

void chunk_update_0(uint c_15, const Island_natural_0 thread* isl_8, const Rigid_0 thread* rg_6, float dt_11, bool rml_0, uint step_0, bool contact_4, float thread* work_1, float thread* work_err_0, KernelContext_0 thread* kernelContext_49)
{
    ChunkStatic_natural_0 device* _S787 = kernelContext_49->chunks_0+c_15;
    float3 _S788 = float3(0.0f) ;
    uint _S789 = kernelContext_49->index_0[c_15];
    float peak_0 = 0.0f;
    uint e_3 = _S789;
    float3 fi_0 = _S788;
    float3 mi_0 = _S788;
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
        uint _S790 = 3U * (entry_2 >> 1U);
        float4 _S791 = float4(*(kernelContext_49->scratch_0+_S790)) ;
        if((entry_2 & 1U) == 0U)
        {
            float3 mi_1 = mi_0 + (float4(*(kernelContext_49->scratch_0+(_S790 + 1U))) ).xyz;
            fi_0 = fi_0 + _S791.xyz;
            mi_0 = mi_1;
        }
        else
        {
            float3 mi_2 = mi_0 + (float4(*(kernelContext_49->scratch_0+(_S790 + 2U))) ).xyz;
            fi_0 = fi_0 + - _S791.xyz;
            mi_0 = mi_2;
        }
        float _S792 = max(peak_0, _S791.w);
        uint _S793 = e_3 + 1U;
        peak_0 = _S792;
        e_3 = _S793;
    }
    uint _S794 = 4U * c_15;
    float3 u_0 = (float4(*(kernelContext_49->state_0+_S794)) ).xyz;
    uint _S795 = _S794 + 1U;
    float3 th_2 = (float4(*(kernelContext_49->state_0+_S795)) ).xyz;
    uint _S796 = _S794 + 2U;
    float3 v_9 = (float4(*(kernelContext_49->state_0+_S796)) ).xyz;
    uint _S797 = _S794 + 3U;
    float3 w_5 = (float4(*(kernelContext_49->state_0+_S797)) ).xyz;
    float4 _S798 = float4(_S787->center_0) ;
    float mass_0 = _S798.w;
    float3 _S799 = _S798.xyz;
    float3 _S800 = (float4(isl_8->com_0) ).xyz;
    float3 _S801 = rotate_0(&rg_6->rot_0, _S799 + u_0 - _S800);
    thread float3 f_load_0;
    thread float3 t_load_0;
    thread float3 rep_f_2;
    thread float3 rep_m_2;
    chunk_loads_0(c_15, c_15, &rg_6->rot_0, step_0, dt_11, contact_4, dt_11, &f_load_0, &t_load_0, &rep_f_2, &rep_m_2, kernelContext_49);
    record_chunk_load_0(c_15, f_load_0, t_load_0, kernelContext_49);
    float3 _S802 = float3(mass_0) ;
    float3 f_world_0 = f_load_0 + kernelContext_49->params_0->gravity_0.xyz * _S802;
    float3 t_world_0 = t_load_0;
    float3 f_world_1;
    float3 t_world_1;
    if(rml_0)
    {
        float3 f_world_2 = f_world_0 - (rg_6->a_7 + cross(rg_6->alpha_0, _S801) + cross(rg_6->w_4, cross(rg_6->w_4, _S801))) * _S802;
        float4 _S803 = float4(_S787->inertia0_1) ;
        float4 _S804 = float4(_S787->inertia1_1) ;
        float4 _S805 = float4(_S787->inertia2_1) ;
        float3 _S806 = world_mul_0(&rg_6->rot_0, _S803, _S804, _S805, rg_6->alpha_0);
        float3 _S807 = world_mul_0(&rg_6->rot_0, _S803, _S804, _S805, rg_6->w_4);
        float3 t_world_2 = t_world_0 - (_S806 + cross(rg_6->w_4, _S807));
        f_world_1 = f_world_2;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    float3 _S808 = inverse_rotate_0(&rg_6->rot_0, f_world_1);
    float3 _S809 = inverse_rotate_0(&rg_6->rot_0, t_world_1);
    float3 f_ext_0;
    float3 m_ext_0;
    if(rml_0)
    {
        float3 _S810 = inverse_rotate_0(&rg_6->rot_0, rg_6->w_4);
        float4 _S811 = float4(_S787->inertia0_1) ;
        float4 _S812 = float4(_S787->inertia1_1) ;
        float4 _S813 = float4(_S787->inertia2_1) ;
        float3 i_w_0 = rows_mul_0(_S811, _S812, _S813, w_5);
        float3 m_ext_1 = _S809 - (cross(_S810, i_w_0) + cross(w_5, rows_mul_0(_S811, _S812, _S813, _S810)) + cross(w_5, i_w_0));
        f_ext_0 = _S808 - cross(_S810, v_9) * float3((2.0f * mass_0)) ;
        m_ext_0 = m_ext_1;
    }
    else
    {
        f_ext_0 = _S808;
        m_ext_0 = _S809;
    }
    float3 f_12 = f_ext_0 + rep_f_2 + fi_0;
    float3 m_5 = m_ext_0 + rep_m_2 + mi_0;
    uint support_0 = (uint4(_S787->info_1) ).x;
    float3 _S814 = float3((float4(*(kernelContext_49->state_0+_S795)) ).w, (float4(*(kernelContext_49->state_0+_S796)) ).w, (float4(*(kernelContext_49->state_0+_S797)) ).w);
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
        v_10 = _S788;
        w_6 = _S788;
    }
    else
    {
        float4 _S815 = float4(_S787->scale_0) ;
        float3 w_7 = w_5 + rows_mul_0(float4(_S787->inv0_1) , float4(_S787->inv1_1) , float4(_S787->inv2_1) , m_5) * float3((dt_11 * _S815.z)) ;
        float3 _S816 = float3(dt_11) ;
        float3 th_4 = th_2 + w_7 * _S816;
        if(support_0 == 2U)
        {
            reaction_0 = - f_12;
            u_1 = u_0;
            th_3 = _S788;
        }
        else
        {
            float3 v_11 = v_9 + f_12 * float3((dt_11 * _S815.y)) ;
            float3 u_2 = u_0 + v_11 * _S816;
            reaction_0 = _S814;
            u_1 = u_2;
            th_3 = v_11;
        }
        float3 _S817 = th_3;
        th_3 = th_4;
        v_10 = _S817;
        w_6 = w_7;
    }
    *(kernelContext_49->state_0+_S794) = packed_float4(float4(u_1, peak_0)) ;
    *(kernelContext_49->state_0+_S795) = packed_float4(float4(th_3, reaction_0.x)) ;
    *(kernelContext_49->state_0+_S796) = packed_float4(float4(v_10, reaction_0.y)) ;
    *(kernelContext_49->state_0+_S797) = packed_float4(float4(w_6, reaction_0.z)) ;
    float3 _S818 = rotate_0(&rg_6->rot_0, _S799 + u_1 - _S800);
    float3 _S819 = rg_6->vel_1 + rg_6->vel_err_1 + cross(rg_6->w_4, _S818);
    float3 _S820 = rotate_0(&rg_6->rot_0, v_10);
    float3 v_world_0 = _S819 + _S820;
    float3 _S821 = rotate_0(&rg_6->rot_0, w_6);
    comp_add1_0(work_1, work_err_0, (dot(f_load_0, v_world_0) + dot(t_load_0, rg_6->w_4 + _S821)) * dt_11);
    return;
}

void chunk_update_1(uint c_16, const Island_0 thread* isl_9, const Rigid_0 thread* rg_7, float dt_12, bool rml_1, uint step_1, bool contact_5, float thread* work_2, float thread* work_err_1, KernelContext_0 thread* kernelContext_50)
{
    ChunkStatic_natural_0 device* _S822 = kernelContext_50->chunks_0+c_16;
    float3 _S823 = float3(0.0f) ;
    uint _S824 = kernelContext_50->index_0[c_16];
    float peak_1 = 0.0f;
    uint e_4 = _S824;
    float3 fi_1 = _S823;
    float3 mi_3 = _S823;
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
        uint _S825 = 3U * (entry_3 >> 1U);
        float4 _S826 = float4(*(kernelContext_50->scratch_0+_S825)) ;
        if((entry_3 & 1U) == 0U)
        {
            float3 mi_4 = mi_3 + (float4(*(kernelContext_50->scratch_0+(_S825 + 1U))) ).xyz;
            fi_1 = fi_1 + _S826.xyz;
            mi_3 = mi_4;
        }
        else
        {
            float3 mi_5 = mi_3 + (float4(*(kernelContext_50->scratch_0+(_S825 + 2U))) ).xyz;
            fi_1 = fi_1 + - _S826.xyz;
            mi_3 = mi_5;
        }
        float _S827 = max(peak_1, _S826.w);
        uint _S828 = e_4 + 1U;
        peak_1 = _S827;
        e_4 = _S828;
    }
    uint _S829 = 4U * c_16;
    float3 u_3 = (float4(*(kernelContext_50->state_0+_S829)) ).xyz;
    uint _S830 = _S829 + 1U;
    float3 th_5 = (float4(*(kernelContext_50->state_0+_S830)) ).xyz;
    uint _S831 = _S829 + 2U;
    float3 v_12 = (float4(*(kernelContext_50->state_0+_S831)) ).xyz;
    uint _S832 = _S829 + 3U;
    float3 w_8 = (float4(*(kernelContext_50->state_0+_S832)) ).xyz;
    float4 _S833 = float4(_S822->center_0) ;
    float mass_1 = _S833.w;
    float3 _S834 = _S833.xyz;
    float3 _S835 = isl_9->com_0.xyz;
    float3 _S836 = rotate_0(&rg_7->rot_0, _S834 + u_3 - _S835);
    thread float3 f_load_1;
    thread float3 t_load_1;
    thread float3 rep_f_3;
    thread float3 rep_m_3;
    chunk_loads_0(c_16, c_16, &rg_7->rot_0, step_1, dt_12, contact_5, dt_12, &f_load_1, &t_load_1, &rep_f_3, &rep_m_3, kernelContext_50);
    record_chunk_load_0(c_16, f_load_1, t_load_1, kernelContext_50);
    float3 _S837 = float3(mass_1) ;
    float3 f_world_3 = f_load_1 + kernelContext_50->params_0->gravity_0.xyz * _S837;
    float3 t_world_3 = t_load_1;
    float3 f_world_4;
    float3 t_world_4;
    if(rml_1)
    {
        float3 f_world_5 = f_world_3 - (rg_7->a_7 + cross(rg_7->alpha_0, _S836) + cross(rg_7->w_4, cross(rg_7->w_4, _S836))) * _S837;
        float4 _S838 = float4(_S822->inertia0_1) ;
        float4 _S839 = float4(_S822->inertia1_1) ;
        float4 _S840 = float4(_S822->inertia2_1) ;
        float3 _S841 = world_mul_0(&rg_7->rot_0, _S838, _S839, _S840, rg_7->alpha_0);
        float3 _S842 = world_mul_0(&rg_7->rot_0, _S838, _S839, _S840, rg_7->w_4);
        float3 t_world_5 = t_world_3 - (_S841 + cross(rg_7->w_4, _S842));
        f_world_4 = f_world_5;
        t_world_4 = t_world_5;
    }
    else
    {
        f_world_4 = f_world_3;
        t_world_4 = t_world_3;
    }
    float3 _S843 = inverse_rotate_0(&rg_7->rot_0, f_world_4);
    float3 _S844 = inverse_rotate_0(&rg_7->rot_0, t_world_4);
    float3 f_ext_1;
    float3 m_ext_2;
    if(rml_1)
    {
        float3 _S845 = inverse_rotate_0(&rg_7->rot_0, rg_7->w_4);
        float4 _S846 = float4(_S822->inertia0_1) ;
        float4 _S847 = float4(_S822->inertia1_1) ;
        float4 _S848 = float4(_S822->inertia2_1) ;
        float3 i_w_1 = rows_mul_0(_S846, _S847, _S848, w_8);
        float3 m_ext_3 = _S844 - (cross(_S845, i_w_1) + cross(w_8, rows_mul_0(_S846, _S847, _S848, _S845)) + cross(w_8, i_w_1));
        f_ext_1 = _S843 - cross(_S845, v_12) * float3((2.0f * mass_1)) ;
        m_ext_2 = m_ext_3;
    }
    else
    {
        f_ext_1 = _S843;
        m_ext_2 = _S844;
    }
    float3 f_13 = f_ext_1 + rep_f_3 + fi_1;
    float3 m_6 = m_ext_2 + rep_m_3 + mi_3;
    uint support_1 = (uint4(_S822->info_1) ).x;
    float3 _S849 = float3((float4(*(kernelContext_50->state_0+_S830)) ).w, (float4(*(kernelContext_50->state_0+_S831)) ).w, (float4(*(kernelContext_50->state_0+_S832)) ).w);
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
        v_13 = _S823;
        w_9 = _S823;
    }
    else
    {
        float4 _S850 = float4(_S822->scale_0) ;
        float3 w_10 = w_8 + rows_mul_0(float4(_S822->inv0_1) , float4(_S822->inv1_1) , float4(_S822->inv2_1) , m_6) * float3((dt_12 * _S850.z)) ;
        float3 _S851 = float3(dt_12) ;
        float3 th_7 = th_5 + w_10 * _S851;
        if(support_1 == 2U)
        {
            reaction_1 = - f_13;
            u_4 = u_3;
            th_6 = _S823;
        }
        else
        {
            float3 v_14 = v_12 + f_13 * float3((dt_12 * _S850.y)) ;
            float3 u_5 = u_3 + v_14 * _S851;
            reaction_1 = _S849;
            u_4 = u_5;
            th_6 = v_14;
        }
        float3 _S852 = th_6;
        th_6 = th_7;
        v_13 = _S852;
        w_9 = w_10;
    }
    *(kernelContext_50->state_0+_S829) = packed_float4(float4(u_4, peak_1)) ;
    *(kernelContext_50->state_0+_S830) = packed_float4(float4(th_6, reaction_1.x)) ;
    *(kernelContext_50->state_0+_S831) = packed_float4(float4(v_13, reaction_1.y)) ;
    *(kernelContext_50->state_0+_S832) = packed_float4(float4(w_9, reaction_1.z)) ;
    float3 _S853 = rotate_0(&rg_7->rot_0, _S834 + u_4 - _S835);
    float3 _S854 = rg_7->vel_1 + rg_7->vel_err_1 + cross(rg_7->w_4, _S853);
    float3 _S855 = rotate_0(&rg_7->rot_0, v_13);
    float3 v_world_1 = _S854 + _S855;
    float3 _S856 = rotate_0(&rg_7->rot_0, w_9);
    comp_add1_0(work_2, work_err_1, (dot(f_load_1, v_world_1) + dot(t_load_1, rg_7->w_4 + _S856)) * dt_12);
    return;
}

float3 turn_difference_0(float3 omega_1, float dt_13, float3 v_15)
{
    float _S857 = length(omega_1);
    float angle_3 = _S857 * dt_13;
    if(angle_3 < 1.00000000317107685e-30f)
    {
        return float3(0.0f) ;
    }
    float3 a_11 = omega_1 / float3(_S857) ;
    float s_6 = sin(0.5f * angle_3);
    float3 av_0 = cross(a_11, v_15);
    return av_0 * float3(sin(angle_3))  + cross(a_11, av_0) * float3((2.0f * s_6 * s_6)) ;
}

void integrate_rigid_0(const Island_natural_0 thread* isl_10, Rigid_0 thread* rg_8, float dt_14)
{
    float3 _S858 = float3(dt_14) ;
    comp_add_0(&rg_8->l_2, &rg_8->l_err_1, rg_8->torque_0 * _S858);
    float3 l_3 = rg_8->l_2 + rg_8->l_err_1;
    comp_add_0(&rg_8->vel_1, &rg_8->vel_err_1, rg_8->a_7 * _S858);
    float3 vel_2 = rg_8->vel_1 + rg_8->vel_err_1;
    float4 _S859 = float4(isl_10->inv0_0) ;
    float4 _S860 = float4(isl_10->inv1_0) ;
    float4 _S861 = float4(isl_10->inv2_0) ;
    thread Quat_0 _S862 = rg_8->rot_0;
    float3 _S863 = world_mul_0(&_S862, _S859, _S860, _S861, l_3);
    float3 _S864 = vel_2 * _S858;
    float3 _S865 = (float4(isl_10->com_0) ).xyz;
    thread Quat_0 _S866 = rg_8->rot_0;
    float3 _S867 = rotate_0(&_S866, _S865);
    comp_add_0(&rg_8->pos_1, &rg_8->pos_err_1, _S864 - turn_difference_0(_S863, dt_14, _S867));
    turn_left_0(&rg_8->rot_0, &rg_8->rot_err_0, _S863, dt_14);
    thread Quat_0 _S868 = rg_8->rot_0;
    float3 _S869 = world_mul_0(&_S868, _S859, _S860, _S861, l_3);
    rg_8->w_4 = _S869;
    return;
}

void integrate_rigid_1(const Island_0 thread* isl_11, Rigid_0 thread* rg_9, float dt_15)
{
    float3 _S870 = float3(dt_15) ;
    comp_add_0(&rg_9->l_2, &rg_9->l_err_1, rg_9->torque_0 * _S870);
    float3 l_4 = rg_9->l_2 + rg_9->l_err_1;
    comp_add_0(&rg_9->vel_1, &rg_9->vel_err_1, rg_9->a_7 * _S870);
    float3 vel_3 = rg_9->vel_1 + rg_9->vel_err_1;
    float4 _S871 = isl_11->inv0_0;
    float4 _S872 = isl_11->inv1_0;
    float4 _S873 = isl_11->inv2_0;
    thread Quat_0 _S874 = rg_9->rot_0;
    float3 _S875 = world_mul_0(&_S874, isl_11->inv0_0, isl_11->inv1_0, isl_11->inv2_0, l_4);
    float3 _S876 = vel_3 * _S870;
    float3 _S877 = isl_11->com_0.xyz;
    thread Quat_0 _S878 = rg_9->rot_0;
    float3 _S879 = rotate_0(&_S878, _S877);
    comp_add_0(&rg_9->pos_1, &rg_9->pos_err_1, _S876 - turn_difference_0(_S875, dt_15, _S879));
    turn_left_0(&rg_9->rot_0, &rg_9->rot_err_0, _S875, dt_15);
    thread Quat_0 _S880 = rg_9->rot_0;
    float3 _S881 = world_mul_0(&_S880, _S871, _S872, _S873, l_4);
    rg_9->w_4 = _S881;
    return;
}

void drift_moments_0(uint c_17, float3 thread* tu_0, float3 thread* pv_0, KernelContext_0 thread* kernelContext_51)
{
    ChunkStatic_natural_0 device* _S882 = kernelContext_51->chunks_0+c_17;
    uint _S883 = 4U * c_17;
    float3 _S884 = float3(((float4(_S882->center_0) ).w * (float4(_S882->scale_0) ).x)) ;
    *tu_0 = *tu_0 + (float4(*(kernelContext_51->state_0+_S883)) ).xyz * _S884;
    *pv_0 = *pv_0 + (float4(*(kernelContext_51->state_0+(_S883 + 2U))) ).xyz * _S884;
    return;
}

void drift_angular_0(uint c_18, float3 wcom_1, float3 tr_0, float3 dv_0, float3 thread* lu_0, float3 thread* lv_0, KernelContext_0 thread* kernelContext_52)
{
    ChunkStatic_natural_0 device* _S885 = kernelContext_52->chunks_0+c_18;
    float4 _S886 = float4(_S885->center_0) ;
    float3 r_10 = _S886.xyz - wcom_1;
    uint _S887 = 4U * c_18;
    float3 _S888 = float3(_S886.w) ;
    float4 _S889 = float4(_S885->inertia0_1) ;
    float4 _S890 = float4(_S885->inertia1_1) ;
    float4 _S891 = float4(_S885->inertia2_1) ;
    float3 _S892 = float3((float4(_S885->scale_0) ).x) ;
    *lu_0 = *lu_0 + (cross(r_10, (float4(*(kernelContext_52->state_0+_S887)) ).xyz - tr_0) * _S888 + rows_mul_0(_S889, _S890, _S891, (float4(*(kernelContext_52->state_0+(_S887 + 1U))) ).xyz)) * _S892;
    *lv_0 = *lv_0 + (cross(r_10, (float4(*(kernelContext_52->state_0+(_S887 + 2U))) ).xyz - dv_0) * _S888 + rows_mul_0(_S889, _S890, _S891, (float4(*(kernelContext_52->state_0+(_S887 + 3U))) ).xyz)) * _S892;
    return;
}

void drift_apply_0(uint c_19, float3 wcom_2, float3 tr_1, float3 phi_0, float3 dv_1, float3 dw_0, KernelContext_0 thread* kernelContext_53)
{
    float3 r_11 = (float4((kernelContext_53->chunks_0+c_19)->center_0) ).xyz - wcom_2;
    uint _S893 = 4U * c_19;
    *(kernelContext_53->state_0+_S893) = packed_float4(float4((float4(*(kernelContext_53->state_0+_S893)) ).xyz - (tr_1 + cross(phi_0, r_11)), (float4(*(kernelContext_53->state_0+_S893)) ).w)) ;
    uint _S894 = _S893 + 1U;
    *(kernelContext_53->state_0+_S894) = packed_float4(float4((float4(*(kernelContext_53->state_0+_S894)) ).xyz - phi_0, (float4(*(kernelContext_53->state_0+_S894)) ).w)) ;
    uint _S895 = _S893 + 2U;
    *(kernelContext_53->state_0+_S895) = packed_float4(float4((float4(*(kernelContext_53->state_0+_S895)) ).xyz - (dv_1 + cross(dw_0, r_11)), (float4(*(kernelContext_53->state_0+_S895)) ).w)) ;
    uint _S896 = _S893 + 3U;
    *(kernelContext_53->state_0+_S896) = packed_float4(float4((float4(*(kernelContext_53->state_0+_S896)) ).xyz - dw_0, (float4(*(kernelContext_53->state_0+_S896)) ).w)) ;
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
    thread Quat_0 _S897 = *hi_3;
    thread Quat_0 _S898 = dq_1;
    Quat_0 _S899 = quat_mul_0(&_S897, &_S898);
    thread Quat_0 _S900 = _S899;
    float4 _S901 = quat_vec_0(&_S900);
    quat_accumulate_0(hi_3, lo_3, _S901);
    return;
}

void drift_rigid_0(const Island_natural_0 thread* isl_12, Rigid_0 thread* rg_10, float3 tr_2, float3 phi_2, float3 dv_2, float3 dw_1)
{
    float3 wcom_3 = (float4(isl_12->wcom_0) ).xyz;
    Quat_0 rot_2 = rg_10->rot_0;
    float3 _S902 = tr_2 - cross(phi_2, wcom_3);
    thread Quat_0 _S903 = rg_10->rot_0;
    float3 _S904 = rotate_0(&_S903, _S902);
    comp_add_0(&rg_10->pos_1, &rg_10->pos_err_1, _S904);
    thread Quat_0 _S905 = rg_10->rot_0;
    float3 _S906 = inverse_rotate_0(&_S905, rg_10->w_4);
    float4 _S907 = float4(isl_12->inertia0_0) ;
    float4 _S908 = float4(isl_12->inertia1_0) ;
    float4 _S909 = float4(isl_12->inertia2_0) ;
    float3 _S910 = cross(phi_2, rows_mul_0(_S907, _S908, _S909, _S906)) - rows_mul_0(_S907, _S908, _S909, cross(phi_2, _S906));
    thread Quat_0 _S911 = rg_10->rot_0;
    float3 _S912 = rotate_0(&_S911, _S910);
    turn_right_0(&rg_10->rot_0, &rg_10->rot_err_0, phi_2);
    float3 _S913 = dv_2 + cross(dw_1, (float4(isl_12->com_0) ).xyz - wcom_3);
    thread Quat_0 _S914 = rot_2;
    float3 _S915 = rotate_0(&_S914, _S913);
    comp_add_0(&rg_10->vel_1, &rg_10->vel_err_1, _S915);
    thread Quat_0 _S916 = rot_2;
    float3 _S917 = rotate_0(&_S916, dw_1);
    rg_10->w_4 = rg_10->w_4 + _S917;
    thread Quat_0 _S918 = rg_10->rot_0;
    float3 _S919 = world_mul_0(&_S918, _S907, _S908, _S909, _S917);
    comp_add_0(&rg_10->l_2, &rg_10->l_err_1, _S912 + _S919);
    return;
}

void drift_rigid_1(const Island_0 thread* isl_13, Rigid_0 thread* rg_11, float3 tr_3, float3 phi_3, float3 dv_3, float3 dw_2)
{
    float3 wcom_4 = isl_13->wcom_0.xyz;
    Quat_0 rot_3 = rg_11->rot_0;
    float3 _S920 = tr_3 - cross(phi_3, wcom_4);
    thread Quat_0 _S921 = rg_11->rot_0;
    float3 _S922 = rotate_0(&_S921, _S920);
    comp_add_0(&rg_11->pos_1, &rg_11->pos_err_1, _S922);
    thread Quat_0 _S923 = rg_11->rot_0;
    float3 _S924 = inverse_rotate_0(&_S923, rg_11->w_4);
    float4 _S925 = isl_13->inertia0_0;
    float4 _S926 = isl_13->inertia1_0;
    float4 _S927 = isl_13->inertia2_0;
    float3 _S928 = cross(phi_3, rows_mul_0(isl_13->inertia0_0, isl_13->inertia1_0, isl_13->inertia2_0, _S924)) - rows_mul_0(isl_13->inertia0_0, isl_13->inertia1_0, isl_13->inertia2_0, cross(phi_3, _S924));
    thread Quat_0 _S929 = rg_11->rot_0;
    float3 _S930 = rotate_0(&_S929, _S928);
    turn_right_0(&rg_11->rot_0, &rg_11->rot_err_0, phi_3);
    float3 _S931 = dv_3 + cross(dw_2, isl_13->com_0.xyz - wcom_4);
    thread Quat_0 _S932 = rot_3;
    float3 _S933 = rotate_0(&_S932, _S931);
    comp_add_0(&rg_11->vel_1, &rg_11->vel_err_1, _S933);
    thread Quat_0 _S934 = rot_3;
    float3 _S935 = rotate_0(&_S934, dw_2);
    rg_11->w_4 = rg_11->w_4 + _S935;
    thread Quat_0 _S936 = rg_11->rot_0;
    float3 _S937 = world_mul_0(&_S936, _S925, _S926, _S927, _S935);
    comp_add_0(&rg_11->l_2, &rg_11->l_err_1, _S930 + _S937);
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
    uint4 _S938 = isl_14->probes_0;
    uint at_5 = isl_14->probes_0.x;
    for(;;)
    {
        if(at_5 < (_S938.y))
        {
        }
        else
        {
            break;
        }
        uint4 info_3 = (as_type<uint4>((float4(*(kernelContext_55->loads_0+at_5)) )));
        float4 _S939 = float4(*(kernelContext_55->loads_0+(at_5 + 1U))) ;
        float4 _S940 = float4(*(kernelContext_55->loads_0+(at_5 + 2U))) ;
        float4 _S941 = float4(*(kernelContext_55->loads_0+(at_5 + 3U))) ;
        uint kind_4 = info_3.x;
        uint i_10 = info_3.y;
        float value_1;
        if(kind_4 == 0U)
        {
            float3 small_0 = (float4(*(kernelContext_55->state_0+4U * i_10)) ).xyz + float3(_S939.w, _S940.w, _S941.w);
            float3 _S942 = rg_12->pos_1 - _S940.xyz;
            float3 _S943 = rotate_0(&rg_12->rot_0, (float4((kernelContext_55->chunks_0+i_10)->center_0) ).xyz);
            float3 _S944 = _S942 + _S943;
            float3 _S945 = rg_12->pos_err_1 - _S941.xyz;
            float3 _S946 = rotate_0(&rg_12->rot_0, small_0);
            value_1 = dot(_S944 + (_S945 + _S946), _S939.xyz);
        }
        else
        {
            if(kind_4 == 1U)
            {
                uint _S947 = 4U * i_10;
                float3 _S948 = rotate_0(&rg_12->rot_0, (float4((kernelContext_55->chunks_0+i_10)->center_0) ).xyz + (float4(*(kernelContext_55->state_0+_S947)) ).xyz - isl_14->com_0.xyz);
                float3 _S949 = rg_12->vel_1 + rg_12->vel_err_1 + cross(rg_12->w_4, _S948);
                float3 _S950 = rotate_0(&rg_12->rot_0, (float4(*(kernelContext_55->state_0+(_S947 + 2U))) ).xyz);
                value_1 = dot(_S949 + _S950, _S939.xyz);
            }
            else
            {
                if(kind_4 == 2U)
                {
                    uint _S951 = 3U * i_10;
                    float3 f_14 = (float4(*(kernelContext_55->scratch_0+_S951)) ).xyz;
                    bool _S952 = (info_3.z) == 0U;
                    float3 mc_0;
                    if(_S952)
                    {
                        mc_0 = (float4(*(kernelContext_55->scratch_0+(_S951 + 1U))) ).xyz;
                    }
                    else
                    {
                        mc_0 = (float4(*(kernelContext_55->scratch_0+(_S951 + 2U))) ).xyz;
                    }
                    float3 fc_4;
                    if(_S952)
                    {
                        fc_4 = f_14;
                    }
                    else
                    {
                        fc_4 = - f_14;
                    }
                    value_1 = dot(fc_4, _S939.xyz) + dot(mc_0, _S940.xyz);
                }
                else
                {
                    uint _S953 = 4U * i_10;
                    float3 _S954 = rotate_0(&rg_12->rot_0, float3((float4(*(kernelContext_55->state_0+(_S953 + 1U))) ).w, (float4(*(kernelContext_55->state_0+(_S953 + 2U))) ).w, (float4(*(kernelContext_55->state_0+(_S953 + 3U))) ).w));
                    value_1 = dot(_S954, _S939.xyz);
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
    uint _S955;
    if(previous_1 == 0U)
    {
        _S955 = at_6;
    }
    else
    {
        _S955 = min(previous_1, at_6);
    }
    (kernelContext_56->islands_0+kernelContext_56->params_0->halt_index_0)->info_0[int(1)] = _S955;
    return;
}

uint seen_bits_0(KernelContext_0 thread* kernelContext_57)
{
    uint _S956;
    if(((*kernelContext_57->g_seen_0)[0U]) != 0U)
    {
        _S956 = 32768U;
    }
    else
    {
        _S956 = 0U;
    }
    uint _S957;
    if(((*kernelContext_57->g_seen_0)[1U]) != 0U)
    {
        _S957 = 65536U;
    }
    else
    {
        _S957 = 0U;
    }
    uint _S958 = _S956 | _S957;
    if(((*kernelContext_57->g_seen_0)[2U]) != 0U)
    {
        _S956 = 131072U;
    }
    else
    {
        _S956 = 0U;
    }
    uint _S959 = _S958 | _S956;
    if(((*kernelContext_57->g_seen_0)[3U]) != 0U)
    {
        _S956 = 32U;
    }
    else
    {
        _S956 = 0U;
    }
    uint _S960 = _S959 | _S956;
    if(((*kernelContext_57->g_seen_0)[4U]) != 0U)
    {
        _S956 = 64U;
    }
    else
    {
        _S956 = 0U;
    }
    return _S960 | _S956;
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
    uint _S961 = group_2.x;
    Island_natural_0 device* _S962 = islands_6+_S961;
    uint4 _S963 = uint4((*_S962).info_0) ;
    float4 _S964 = float4((*_S962).com_0) ;
    float4 _S965 = float4((*_S962).inertia0_0) ;
    float4 _S966 = float4((*_S962).inertia1_0) ;
    float4 _S967 = float4((*_S962).inertia2_0) ;
    float4 _S968 = float4((*_S962).inv0_0) ;
    float4 _S969 = float4((*_S962).inv1_0) ;
    float4 _S970 = float4((*_S962).inv2_0) ;
    float4 _S971 = float4((*_S962).wcom_0) ;
    float4 _S972 = float4((*_S962).winv0_0) ;
    float4 _S973 = float4((*_S962).winv1_0) ;
    float4 _S974 = float4((*_S962).winv2_0) ;
    float4 _S975 = float4((*_S962).rotation_0) ;
    float4 _S976 = float4((*_S962).position_0) ;
    float4 _S977 = float4((*_S962).position_err_0) ;
    float4 _S978 = float4((*_S962).velocity_0) ;
    float4 _S979 = float4((*_S962).velocity_err_0) ;
    float4 _S980 = float4((*_S962).angular_velocity_0) ;
    uint4 _S981 = uint4((*_S962).probes_0) ;
    float4 _S982 = float4((*_S962).energy_0) ;
    float4 _S983 = float4((*_S962).rotation_err_0) ;
    float4 _S984 = float4((*_S962).momentum_0) ;
    float4 _S985 = float4((*_S962).momentum_err_0) ;
    thread Island_0 isl_15;
    (&isl_15)->range_0 = uint4((*_S962).range_0) ;
    (&isl_15)->info_0 = _S963;
    (&isl_15)->com_0 = _S964;
    (&isl_15)->inertia0_0 = _S965;
    (&isl_15)->inertia1_0 = _S966;
    (&isl_15)->inertia2_0 = _S967;
    (&isl_15)->inv0_0 = _S968;
    (&isl_15)->inv1_0 = _S969;
    (&isl_15)->inv2_0 = _S970;
    (&isl_15)->wcom_0 = _S971;
    (&isl_15)->winv0_0 = _S972;
    (&isl_15)->winv1_0 = _S973;
    (&isl_15)->winv2_0 = _S974;
    (&isl_15)->rotation_0 = _S975;
    (&isl_15)->position_0 = _S976;
    (&isl_15)->position_err_0 = _S977;
    (&isl_15)->velocity_0 = _S978;
    (&isl_15)->velocity_err_0 = _S979;
    (&isl_15)->angular_velocity_0 = _S980;
    (&isl_15)->done_0 = (*_S962).done_0;
    (&isl_15)->coverage_0 = (*_S962).coverage_0;
    (&isl_15)->wide_groups_0 = (*_S962).wide_groups_0;
    (&isl_15)->done_pad_0 = (*_S962).done_pad_0;
    (&isl_15)->probes_0 = _S981;
    (&isl_15)->energy_0 = _S982;
    (&isl_15)->rotation_err_0 = _S983;
    (&isl_15)->momentum_0 = _S984;
    (&isl_15)->momentum_err_0 = _S985;
    bool driven_0 = (((&isl_15)->info_0.x) & 2U) != 0U;
    bool _S986 = !((((&isl_15)->info_0.x) & 1U) != 0U);
    bool _S987;
    if(_S986)
    {
        _S987 = !driven_0;
    }
    else
    {
        _S987 = false;
    }
    bool contact_island_0 = (((&isl_15)->info_0.x) & 4U) != 0U;
    bool _S988 = (((&isl_15)->info_0.x) & 16U) != 0U;
    seen_clear_0(tid_5, &kernelContext_58);
    bool _S989 = tid_5 == 0U;
    bool settled_0;
    uint cov_0;
    if(_S989)
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
            thread Island_0 _S990 = isl_15;
            bool _S991 = contact_stopped_1(&_S990, &kernelContext_58);
            settled_0 = _S991;
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
    float _S992 = (&kernelContext_58)->params_0->dt_0;
    bool _S993 = ((&kernelContext_58)->params_0->fracture_0) != 0U;
    bool _S994 = ((&kernelContext_58)->params_0->rigid_motion_loads_0) != 0U;
    thread Island_0 _S995 = isl_15;
    Rigid_0 _S996 = rigid_of_1(&_S995);
    thread Rigid_0 rg_13 = _S996;
    thread float work_3 = 0.0f;
    thread float work_err_2 = 0.0f;
    settled_0 = _S988;
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
        bool _S997;
        if(settled_0)
        {
            _S997 = !quiet_0;
        }
        else
        {
            _S997 = false;
        }
        bool _S998;
        bool explicit_step_0;
        uint c_20;
        if(_S997)
        {
            float3 _S999 = float3(0.0f) ;
            thread float3 norm_0 = _S999;
            thread float3 unused0_0 = _S999;
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
                thread Quat_0 _S1000 = (&rg_13)->rot_0;
                float _S1001 = settled_chunk_load_0(c_20, &_S1000, k_20, _S992, contact_island_0, &kernelContext_58);
                norm_0.x = norm_0.x + _S1001;
                c_20 = c_20 + 256U;
            }
            group_sum3_0(tid_5, &norm_0, &unused0_0, &kernelContext_58);
            if(((&kernelContext_58)->params_0->solve_mode_0) == 1U)
            {
                _S998 = (abs(norm_0.x - (&isl_15)->energy_0.z)) > ((&isl_15)->energy_0.w);
            }
            else
            {
                _S998 = false;
            }
            if(_S998)
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
        if(_S986)
        {
            _S998 = !quiet_0;
        }
        else
        {
            _S998 = false;
        }
        if(_S998)
        {
            float3 _S1002 = float3(0.0f) ;
            thread float3 f_15 = _S1002;
            thread float3 t_15 = _S1002;
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
                thread Island_0 _S1003 = isl_15;
                thread Rigid_0 _S1004 = rg_13;
                net_load_1(c_20, &_S1003, &_S1004, k_20, _S992, contact_island_0, &f_15, &t_15, &kernelContext_58);
                c_20 = c_20 + 256U;
            }
            group_sum3_0(tid_5, &f_15, &t_15, &kernelContext_58);
            thread Island_0 _S1005 = isl_15;
            rigid_acceleration_1(&_S1005, &rg_13, f_15, t_15);
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
                bool _S1006 = bond_update_0(c_20, _S992, _S993, abs_step_1, false, &kernelContext_58);
                if(_S1006)
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
                thread Island_0 _S1007 = isl_15;
                thread Rigid_0 _S1008 = rg_13;
                chunk_update_1(c_21, &_S1007, &_S1008, _S992, _S994, k_20, contact_island_0, &work_3, &work_err_2, &kernelContext_58);
                c_21 = c_21 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        }
        bool _S1009;
        if(_S987)
        {
            _S1009 = !quiet_0;
        }
        else
        {
            _S1009 = false;
        }
        if(_S1009)
        {
            thread Island_0 _S1010 = isl_15;
            integrate_rigid_1(&_S1010, &rg_13, _S992);
        }
        bool _S1011;
        if(_S986)
        {
            _S1011 = explicit_step_0;
        }
        else
        {
            _S1011 = false;
        }
        if(_S1011)
        {
            float3 _S1012 = (&isl_15)->wcom_0.xyz;
            float3 _S1013 = float3(0.0f) ;
            thread float3 tu_1 = _S1013;
            thread float3 pv_1 = _S1013;
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
            thread float3 lu_1 = _S1013;
            thread float3 lv_1 = _S1013;
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
                drift_angular_0(c_21, _S1012, tr_4, dv_4, &lu_1, &lv_1, &kernelContext_58);
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
                drift_apply_0(c_22, _S1012, tr_4, phi_4, dv_4, dw_3, &kernelContext_58);
                c_22 = c_22 + 256U;
            }
            if(!driven_0)
            {
                thread Island_0 _S1014 = isl_15;
                drift_rigid_1(&_S1014, &rg_13, tr_4, phi_4, dv_4, dw_3);
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        }
        bool _S1015;
        if(_S989)
        {
            _S1015 = ((&isl_15)->probes_0.y) > ((&isl_15)->probes_0.x);
        }
        else
        {
            _S1015 = false;
        }
        if(_S1015)
        {
            thread Island_0 _S1016 = isl_15;
            thread Rigid_0 _S1017 = rg_13;
            record_probes_0(&_S1016, &_S1017, k_20, &kernelContext_58);
        }
        uint _S1018 = done_1 + 1U;
        if((*(&kernelContext_58)->g_halt_0) != 0U)
        {
            done_1 = _S1018;
            break;
        }
        done_1 = _S1018;
        woke_1 = woke_0;
    }
    thread float3 wsum_0 = float3(work_3, work_err_2, 0.0f);
    thread float3 unused_1 = float3(0.0f) ;
    group_sum3_0(tid_5, &wsum_0, &unused_1, &kernelContext_58);
    if(_S989)
    {
        thread Quat_0 _S1019 = (&rg_13)->rot_0;
        float4 _S1020 = quat_vec_0(&_S1019);
        (&isl_15)->rotation_0 = _S1020;
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
            _S987 = contact_island_0;
        }
        else
        {
            _S987 = false;
        }
        if(_S987)
        {
            contact_split_at_0((&isl_15)->info_0.w + done_1, &kernelContext_58);
        }
        float _S1021 = wsum_0.x;
        thread float _S1022 = (&isl_15)->energy_0.x;
        thread float _S1023 = (&isl_15)->energy_0.y;
        comp_add1_0(&_S1022, &_S1023, _S1021);
        (&isl_15)->energy_0.x = _S1022;
        (&isl_15)->energy_0.y = _S1023 + wsum_0.y;
        (&isl_15)->info_0.w = (&isl_15)->info_0.w + done_1;
        if((*(&kernelContext_58)->g_halt_0) != 0U)
        {
            (&isl_15)->info_0.z = ((&isl_15)->info_0.z) | 1U;
        }
        uint _S1024 = seen_bits_0(&kernelContext_58);
        if((*(&kernelContext_58)->g_halt_0) != 0U)
        {
            cov_0 = 128U;
        }
        else
        {
            cov_0 = 0U;
        }
        uint _S1025 = _S1024 | cov_0;
        if(woke_0)
        {
            cov_0 = 2048U;
        }
        else
        {
            cov_0 = 0U;
        }
        uint cov_1 = _S1025 | cov_0;
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
                _S987 = !quiet_1;
            }
            else
            {
                _S987 = false;
            }
            if(_S987)
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
        Island_natural_0 device* _S1026 = (&kernelContext_58)->islands_0+_S961;
        _S1026->range_0 = packed_uint4(isl_15.range_0) ;
        _S1026->info_0 = packed_uint4(isl_15.info_0) ;
        _S1026->com_0 = packed_float4(isl_15.com_0) ;
        _S1026->inertia0_0 = packed_float4(isl_15.inertia0_0) ;
        _S1026->inertia1_0 = packed_float4(isl_15.inertia1_0) ;
        _S1026->inertia2_0 = packed_float4(isl_15.inertia2_0) ;
        _S1026->inv0_0 = packed_float4(isl_15.inv0_0) ;
        _S1026->inv1_0 = packed_float4(isl_15.inv1_0) ;
        _S1026->inv2_0 = packed_float4(isl_15.inv2_0) ;
        _S1026->wcom_0 = packed_float4(isl_15.wcom_0) ;
        _S1026->winv0_0 = packed_float4(isl_15.winv0_0) ;
        _S1026->winv1_0 = packed_float4(isl_15.winv1_0) ;
        _S1026->winv2_0 = packed_float4(isl_15.winv2_0) ;
        _S1026->rotation_0 = packed_float4(isl_15.rotation_0) ;
        _S1026->position_0 = packed_float4(isl_15.position_0) ;
        _S1026->position_err_0 = packed_float4(isl_15.position_err_0) ;
        _S1026->velocity_0 = packed_float4(isl_15.velocity_0) ;
        _S1026->velocity_err_0 = packed_float4(isl_15.velocity_err_0) ;
        _S1026->angular_velocity_0 = packed_float4(isl_15.angular_velocity_0) ;
        _S1026->done_0 = isl_15.done_0;
        _S1026->coverage_0 = isl_15.coverage_0;
        _S1026->wide_groups_0 = isl_15.wide_groups_0;
        _S1026->done_pad_0 = isl_15.done_pad_0;
        _S1026->probes_0 = packed_uint4(isl_15.probes_0) ;
        _S1026->energy_0 = packed_float4(isl_15.energy_0) ;
        _S1026->rotation_err_0 = packed_float4(isl_15.rotation_err_0) ;
        _S1026->momentum_0 = packed_float4(isl_15.momentum_0) ;
        _S1026->momentum_err_0 = packed_float4(isl_15.momentum_err_0) ;
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
    uint _S1027 = table_0 + 4U * g_2;
    (&w_11)->island_3 = kernelContext_59->index_0[_S1027];
    (&w_11)->begin_1 = kernelContext_59->index_0[_S1027 + 1U];
    (&w_11)->end_0 = kernelContext_59->index_0[_S1027 + 2U];
    (&w_11)->first_0 = kernelContext_59->index_0[_S1027 + 3U];
    return w_11;
}

bool wide_runs_0(const Island_natural_0 thread* isl_16, KernelContext_0 thread* kernelContext_60)
{
    uint4 _S1028 = uint4(isl_16->info_0) ;
    bool _S1029;
    if(((_S1028.z) & 1U) != 0U)
    {
        _S1029 = true;
    }
    else
    {
        _S1029 = (_S1028.y) == 0U;
    }
    if(_S1029)
    {
        return false;
    }
    if(((_S1028.x) & 4U) == 0U)
    {
        _S1029 = true;
    }
    else
    {
        bool _S1030 = contact_stopped_0(isl_16, kernelContext_60);
        _S1029 = !_S1030;
    }
    return _S1029;
}

bool wide_enter_0(uint tid_6, const Island_natural_0 thread* isl_17, KernelContext_0 thread* kernelContext_61)
{
    seen_clear_0(tid_6, kernelContext_61);
    if(tid_6 == 0U)
    {
        bool _S1031 = wide_runs_0(isl_17, kernelContext_61);
        int _S1032;
        if(_S1031)
        {
            _S1032 = int(1);
        }
        else
        {
            _S1032 = int(0);
        }
        *kernelContext_61->g_wide_run_0 = uint(_S1032);
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

bool wide_enter_1(uint _S1033, uint _S1034, KernelContext_0 thread* kernelContext_64)
{
    thread Island_natural_0 _S1035 = *(kernelContext_64->islands_0+_S1034);
    seen_clear_0(_S1033, kernelContext_64);
    if(_S1033 == 0U)
    {
        bool _S1036 = wide_runs_0(&_S1035, kernelContext_64);
        int _S1037;
        if(_S1036)
        {
            _S1037 = int(1);
        }
        else
        {
            _S1037 = int(0);
        }
        *kernelContext_64->g_wide_run_0 = uint(_S1037);
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
    uint _S1038 = group_3.x;
    WideGroup_0 _S1039 = wide_group_0(params_7->wide_chunk_table_0, _S1038, &kernelContext_65);
    if(_S1038 != (_S1039.first_0))
    {
        return;
    }
    thread Island_natural_0 _S1040 = *((&kernelContext_65)->islands_0+_S1039.island_3);
    uint4 _S1041 = uint4((&_S1040)->info_0) ;
    uint _S1042 = _S1041.x;
    bool _S1043;
    if((_S1042 & 16U) == 0U)
    {
        _S1043 = true;
    }
    else
    {
        bool _S1044 = wide_enter_1(tid_7, _S1039.island_3, &kernelContext_65);
        _S1043 = !_S1044;
    }
    if(_S1043)
    {
        return;
    }
    Quat_0 _S1045 = quat_of_0(float4((&_S1040)->rotation_0) );
    bool _S1046 = (_S1042 & 4U) != 0U;
    float3 _S1047 = float3(0.0f) ;
    thread float3 norm_1 = _S1047;
    thread float3 unused_2 = _S1047;
    uint4 _S1048 = uint4((&_S1040)->range_0) ;
    uint c_23 = _S1048.x + tid_7;
    for(;;)
    {
        if(c_23 < (_S1048.y))
        {
        }
        else
        {
            break;
        }
        uint _S1049 = wide_step_0(&_S1040, &kernelContext_65);
        float _S1050 = (&kernelContext_65)->params_0->dt_0;
        thread Quat_0 _S1051 = _S1045;
        float _S1052 = settled_chunk_load_0(c_23, &_S1051, _S1049, _S1050, _S1046, &kernelContext_65);
        norm_1.x = norm_1.x + _S1052;
        c_23 = c_23 + 256U;
    }
    group_sum3_0(tid_7, &norm_1, &unused_2, &kernelContext_65);
    if(tid_7 != 0U)
    {
        return;
    }
    uint _S1053 = seen_bits_0(&kernelContext_65);
    uint cov_5 = 1024U | _S1053;
    if(((&kernelContext_65)->params_0->solve_mode_0) == 1U)
    {
        float4 _S1054 = float4((&_S1040)->energy_0) ;
        _S1043 = (abs(norm_1.x - _S1054.z)) > (_S1054.w);
    }
    else
    {
        _S1043 = false;
    }
    uint cov_6;
    if(_S1043)
    {
        ((&kernelContext_65)->islands_0+_S1039.island_3)->info_0[int(0)] = _S1042 & 4294967279U;
        ((&kernelContext_65)->islands_0+_S1039.island_3)->info_0[int(2)] = (_S1041.z) | 4U;
        cov_6 = cov_5 | 2048U;
    }
    else
    {
        cov_6 = cov_5;
    }
    cov_mark_0(_S1039.island_3, (&_S1040)->coverage_0, cov_6, &kernelContext_65);
    return;
}

void wide_store_0(uint slot_2, uint p_14, float3 a_12, float3 b_29, KernelContext_0 thread* kernelContext_66)
{
    uint _S1055 = 8U * slot_2;
    *(kernelContext_66->scratch_0+(kernelContext_66->params_0->wide_base_0 + _S1055 + p_14)) = packed_float4(float4(a_12, 0.0f)) ;
    *(kernelContext_66->scratch_0+(kernelContext_66->params_0->wide_base_0 + _S1055 + p_14 + 1U)) = packed_float4(float4(b_29, 0.0f)) ;
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
    uint _S1056 = group_4.x;
    bool bond_group_0 = _S1056 < (params_8->wide_bond_groups_0);
    WideGroup_0 wg_0;
    if(bond_group_0)
    {
        WideGroup_0 _S1057 = wide_group_0((&kernelContext_67)->params_0->wide_bond_table_0, _S1056, &kernelContext_67);
        wg_0 = _S1057;
    }
    else
    {
        WideGroup_0 _S1058 = wide_group_0((&kernelContext_67)->params_0->wide_chunk_table_0, _S1056 - params_8->wide_bond_groups_0, &kernelContext_67);
        wg_0 = _S1058;
    }
    WideGroup_0 _S1059 = wg_0;
    thread Island_natural_0 _S1060 = *((&kernelContext_67)->islands_0+wg_0.island_3);
    bool _S1061 = wide_enter_1(tid_8, wg_0.island_3, &kernelContext_67);
    if(!_S1061)
    {
        return;
    }
    uint _S1062 = wide_step_0(&_S1060, &kernelContext_67);
    if(bond_group_0)
    {
        uint4 _S1063 = uint4((&_S1060)->info_0) ;
        if(((_S1063.x) & 16U) != 0U)
        {
            return;
        }
        uint i_11 = wg_0.begin_1 + tid_8;
        bool _S1064;
        if(i_11 < (wg_0.end_0))
        {
            bool _S1065 = bond_update_0(i_11, (&kernelContext_67)->params_0->dt_0, ((&kernelContext_67)->params_0->fracture_0) != 0U, _S1063.w + 1U, true, &kernelContext_67);
            _S1064 = _S1065;
        }
        else
        {
            _S1064 = false;
        }
        if(_S1064)
        {
            ((&kernelContext_67)->islands_0+_S1059.island_3)->info_0[int(2)] = (_S1063.z) | 2U;
        }
        return;
    }
    uint _S1066 = (uint4((&_S1060)->info_0) ).x;
    if((_S1066 & 1U) != 0U)
    {
        return;
    }
    float3 _S1067 = float3(0.0f) ;
    thread float3 f_16 = _S1067;
    thread float3 t_16 = _S1067;
    uint c_24 = wg_0.begin_1 + tid_8;
    if(c_24 < (wg_0.end_0))
    {
        Rigid_0 _S1068 = rigid_of_0(&_S1060);
        float _S1069 = (&kernelContext_67)->params_0->dt_0;
        bool _S1070 = (_S1066 & 4U) != 0U;
        thread Rigid_0 _S1071 = _S1068;
        net_load_0(c_24, &_S1060, &_S1071, _S1062, _S1069, _S1070, &f_16, &t_16, &kernelContext_67);
    }
    group_sum3_0(tid_8, &f_16, &t_16, &kernelContext_67);
    if(tid_8 == 0U)
    {
        wide_store_0(_S1056 - params_8->wide_bond_groups_0, 0U, f_16, t_16, &kernelContext_67);
    }
    return;
}

void wide_partials_0(uint tid_9, uint first_1, uint count_6, uint p_15, float3 thread* a_13, float3 thread* b_30, KernelContext_0 thread* kernelContext_68)
{
    float4 _S1072 = float4(0.0f) ;
    thread float4 x_14 = _S1072;
    thread float4 y_2 = _S1072;
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
        uint _S1073 = 8U * (first_1 + s_7);
        x_14 = x_14 + float4(*(kernelContext_68->scratch_0+(kernelContext_68->params_0->wide_base_0 + _S1073 + p_15))) ;
        y_2 = y_2 + float4(*(kernelContext_68->scratch_0+(kernelContext_68->params_0->wide_base_0 + _S1073 + p_15 + 1U))) ;
        s_7 = s_7 + 256U;
    }
    group_sum2_0(tid_9, &x_14, &y_2, kernelContext_68);
    *a_13 = x_14.xyz;
    *b_30 = y_2.xyz;
    return;
}

Rigid_0 wide_rigid_frame_0(uint tid_10, const Island_natural_0 thread* isl_20, const WideGroup_0 thread* wg_1, KernelContext_0 thread* kernelContext_69)
{
    Rigid_0 _S1074 = rigid_of_0(isl_20);
    thread Rigid_0 rg_14 = _S1074;
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
    uint _S1075 = group_5.x;
    WideGroup_0 _S1076 = wide_group_0(params_9->wide_chunk_table_0, _S1075, &kernelContext_70);
    thread Island_natural_0 _S1077 = *((&kernelContext_70)->islands_0+_S1076.island_3);
    bool _S1078 = wide_enter_1(tid_11, _S1076.island_3, &kernelContext_70);
    if(!_S1078)
    {
        return;
    }
    uint _S1079 = (uint4((&_S1077)->info_0) ).x;
    bool anchored_0 = (_S1079 & 1U) != 0U;
    if((_S1079 & 16U) != 0U)
    {
        if(tid_11 == 0U)
        {
            *((&kernelContext_70)->scratch_0+((&kernelContext_70)->params_0->wide_base_0 + 8U * _S1075 + 6U)) = packed_float4(float4(0.0f) ) ;
        }
        return;
    }
    thread WideGroup_0 _S1080 = _S1076;
    Rigid_0 _S1081 = wide_rigid_frame_0(tid_11, &_S1077, &_S1080, &kernelContext_70);
    thread float work_4 = 0.0f;
    thread float work_err_3 = 0.0f;
    float3 _S1082 = float3(0.0f) ;
    thread float3 tu_2 = _S1082;
    thread float3 pv_2 = _S1082;
    uint c_25 = _S1076.begin_1 + tid_11;
    if(c_25 < (_S1076.end_0))
    {
        float _S1083 = (&kernelContext_70)->params_0->dt_0;
        bool _S1084 = ((&kernelContext_70)->params_0->rigid_motion_loads_0) != 0U;
        uint _S1085 = wide_step_0(&_S1077, &kernelContext_70);
        bool _S1086 = (_S1079 & 4U) != 0U;
        thread Rigid_0 _S1087 = _S1081;
        chunk_update_0(c_25, &_S1077, &_S1087, _S1083, _S1084, _S1085, _S1086, &work_4, &work_err_3, &kernelContext_70);
        if(!anchored_0)
        {
            drift_moments_0(c_25, &tu_2, &pv_2, &kernelContext_70);
        }
    }
    thread float3 wsum_1 = float3(work_4, work_err_3, 0.0f);
    thread float3 unused_3 = _S1082;
    group_sum3_0(tid_11, &wsum_1, &unused_3, &kernelContext_70);
    bool _S1088 = !anchored_0;
    if(_S1088)
    {
        group_sum3_0(tid_11, &tu_2, &pv_2, &kernelContext_70);
    }
    if(tid_11 == 0U)
    {
        uint _S1089 = 8U * _S1075;
        *((&kernelContext_70)->scratch_0+((&kernelContext_70)->params_0->wide_base_0 + _S1089 + 6U)) = packed_float4(float4(wsum_1, 0.0f)) ;
        if(_S1088)
        {
            wide_store_0(_S1075, 2U, tu_2, pv_2, &kernelContext_70);
        }
        *((&kernelContext_70)->scratch_0+((&kernelContext_70)->params_0->wide_base_0 + _S1089 + 7U)) = packed_float4(float4(float((*(&kernelContext_70)->g_seen_0)[0U]), float((*(&kernelContext_70)->g_seen_0)[1U]), float((*(&kernelContext_70)->g_seen_0)[2U]), 0.0f)) ;
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
    uint _S1090 = group_6.x;
    WideGroup_0 _S1091 = wide_group_0(params_10->wide_chunk_table_0, _S1090, &kernelContext_71);
    Island_natural_0 device* _S1092 = (&kernelContext_71)->islands_0+_S1091.island_3;
    Island_natural_0 isl_21 = *_S1092;
    bool _S1093;
    if((((uint4((*_S1092).info_0) ).x) & 17U) != 0U)
    {
        _S1093 = true;
    }
    else
    {
        bool _S1094 = wide_enter_1(tid_12, _S1091.island_3, &kernelContext_71);
        _S1093 = !_S1094;
    }
    if(_S1093)
    {
        return;
    }
    thread float3 tu_3;
    thread float3 pv_3;
    wide_partials_0(tid_12, _S1091.first_0, isl_21.wide_groups_0, 2U, &tu_3, &pv_3, &kernelContext_71);
    float4 _S1095 = float4(isl_21.wcom_0) ;
    float3 _S1096 = float3(_S1095.w) ;
    float3 tr_5 = tu_3 / _S1096;
    float3 dv_5 = pv_3 / _S1096;
    float3 _S1097 = float3(0.0f) ;
    thread float3 lu_2 = _S1097;
    thread float3 lv_2 = _S1097;
    uint c_26 = _S1091.begin_1 + tid_12;
    if(c_26 < (_S1091.end_0))
    {
        drift_angular_0(c_26, _S1095.xyz, tr_5, dv_5, &lu_2, &lv_2, &kernelContext_71);
    }
    group_sum3_0(tid_12, &lu_2, &lv_2, &kernelContext_71);
    if(tid_12 == 0U)
    {
        wide_store_0(_S1090, 4U, lu_2, lv_2, &kernelContext_71);
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
    uint _S1098 = group_7.x;
    WideGroup_0 _S1099 = wide_group_0(params_11->wide_chunk_table_0, _S1098, &kernelContext_72);
    thread Island_natural_0 _S1100 = *((&kernelContext_72)->islands_0+_S1099.island_3);
    uint _S1101 = (uint4((&_S1100)->info_0) ).x;
    bool _S1102;
    if((_S1101 & 1U) != 0U)
    {
        _S1102 = true;
    }
    else
    {
        bool _S1103 = wide_enter_1(tid_13, _S1099.island_3, &kernelContext_72);
        _S1102 = !_S1103;
    }
    if(_S1102)
    {
        return;
    }
    if((_S1101 & 16U) != 0U)
    {
        if(_S1098 != (_S1099.first_0))
        {
            return;
        }
        thread WideGroup_0 _S1104 = _S1099;
        Rigid_0 _S1105 = wide_rigid_frame_0(tid_13, &_S1100, &_S1104, &kernelContext_72);
        thread Rigid_0 rs_0 = _S1105;
        if(tid_13 != 0U)
        {
            _S1102 = true;
        }
        else
        {
            _S1102 = (_S1101 & 2U) != 0U;
        }
        if(_S1102)
        {
            return;
        }
        integrate_rigid_0(&_S1100, &rs_0, (&kernelContext_72)->params_0->dt_0);
        thread Quat_0 _S1106 = (&rs_0)->rot_0;
        float4 _S1107 = quat_vec_0(&_S1106);
        ((&kernelContext_72)->islands_0+_S1099.island_3)->rotation_0 = packed_float4(_S1107) ;
        ((&kernelContext_72)->islands_0+_S1099.island_3)->rotation_err_0 = packed_float4((&rs_0)->rot_err_0) ;
        ((&kernelContext_72)->islands_0+_S1099.island_3)->position_0 = packed_float4(float4((&rs_0)->pos_1, 0.0f)) ;
        ((&kernelContext_72)->islands_0+_S1099.island_3)->position_err_0 = packed_float4(float4((&rs_0)->pos_err_1, 0.0f)) ;
        ((&kernelContext_72)->islands_0+_S1099.island_3)->velocity_0 = packed_float4(float4((&rs_0)->vel_1, 0.0f)) ;
        ((&kernelContext_72)->islands_0+_S1099.island_3)->velocity_err_0 = packed_float4(float4((&rs_0)->vel_err_1, 0.0f)) ;
        ((&kernelContext_72)->islands_0+_S1099.island_3)->angular_velocity_0 = packed_float4(float4((&rs_0)->w_4, 0.0f)) ;
        ((&kernelContext_72)->islands_0+_S1099.island_3)->momentum_0 = packed_float4(float4((&rs_0)->l_2, 0.0f)) ;
        ((&kernelContext_72)->islands_0+_S1099.island_3)->momentum_err_0 = packed_float4(float4((&rs_0)->l_err_1, 0.0f)) ;
        return;
    }
    thread float3 tu_4;
    thread float3 pv_4;
    wide_partials_0(tid_13, _S1099.first_0, (&_S1100)->wide_groups_0, 2U, &tu_4, &pv_4, &kernelContext_72);
    thread float3 lu_3;
    thread float3 lv_3;
    wide_partials_0(tid_13, _S1099.first_0, (&_S1100)->wide_groups_0, 4U, &lu_3, &lv_3, &kernelContext_72);
    float4 _S1108 = float4((&_S1100)->wcom_0) ;
    float3 _S1109 = float3(_S1108.w) ;
    float3 tr_6 = tu_4 / _S1109;
    float3 dv_6 = pv_4 / _S1109;
    float4 _S1110 = float4((&_S1100)->winv0_0) ;
    float4 _S1111 = float4((&_S1100)->winv1_0) ;
    float4 _S1112 = float4((&_S1100)->winv2_0) ;
    float3 phi_5 = rows_mul_0(_S1110, _S1111, _S1112, lu_3);
    float3 dw_4 = rows_mul_0(_S1110, _S1111, _S1112, lv_3);
    uint c_27 = _S1099.begin_1 + tid_13;
    if(c_27 < (_S1099.end_0))
    {
        drift_apply_0(c_27, _S1108.xyz, tr_6, phi_5, dv_6, dw_4, &kernelContext_72);
    }
    if(_S1098 != (_S1099.first_0))
    {
        return;
    }
    thread WideGroup_0 _S1113 = _S1099;
    Rigid_0 _S1114 = wide_rigid_frame_0(tid_13, &_S1100, &_S1113, &kernelContext_72);
    thread Rigid_0 rg_15 = _S1114;
    if(tid_13 != 0U)
    {
        return;
    }
    if(!((_S1101 & 2U) != 0U))
    {
        integrate_rigid_0(&_S1100, &rg_15, (&kernelContext_72)->params_0->dt_0);
        drift_rigid_0(&_S1100, &rg_15, tr_6, phi_5, dv_6, dw_4);
    }
    thread Quat_0 _S1115 = (&rg_15)->rot_0;
    float4 _S1116 = quat_vec_0(&_S1115);
    ((&kernelContext_72)->islands_0+_S1099.island_3)->rotation_0 = packed_float4(_S1116) ;
    ((&kernelContext_72)->islands_0+_S1099.island_3)->rotation_err_0 = packed_float4((&rg_15)->rot_err_0) ;
    ((&kernelContext_72)->islands_0+_S1099.island_3)->position_0 = packed_float4(float4((&rg_15)->pos_1, 0.0f)) ;
    ((&kernelContext_72)->islands_0+_S1099.island_3)->position_err_0 = packed_float4(float4((&rg_15)->pos_err_1, 0.0f)) ;
    ((&kernelContext_72)->islands_0+_S1099.island_3)->velocity_0 = packed_float4(float4((&rg_15)->vel_1, 0.0f)) ;
    ((&kernelContext_72)->islands_0+_S1099.island_3)->velocity_err_0 = packed_float4(float4((&rg_15)->vel_err_1, 0.0f)) ;
    ((&kernelContext_72)->islands_0+_S1099.island_3)->angular_velocity_0 = packed_float4(float4((&rg_15)->w_4, 0.0f)) ;
    ((&kernelContext_72)->islands_0+_S1099.island_3)->momentum_0 = packed_float4(float4((&rg_15)->l_2, 0.0f)) ;
    ((&kernelContext_72)->islands_0+_S1099.island_3)->momentum_err_0 = packed_float4(float4((&rg_15)->l_err_1, 0.0f)) ;
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
    uint _S1117 = group_8.x;
    WideGroup_0 _S1118 = wide_group_0(params_12->wide_chunk_table_0, _S1117, &kernelContext_73);
    if(_S1117 != (_S1118.first_0))
    {
        return;
    }
    Island_natural_0 device* _S1119 = (&kernelContext_73)->islands_0+_S1118.island_3;
    thread Island_natural_0 _S1120 = *_S1119;
    uint4 _S1121 = uint4((&_S1120)->info_0) ;
    float4 _S1122 = float4((&_S1120)->com_0) ;
    float4 _S1123 = float4((&_S1120)->inertia0_0) ;
    float4 _S1124 = float4((&_S1120)->inertia1_0) ;
    float4 _S1125 = float4((&_S1120)->inertia2_0) ;
    float4 _S1126 = float4((&_S1120)->inv0_0) ;
    float4 _S1127 = float4((&_S1120)->inv1_0) ;
    float4 _S1128 = float4((&_S1120)->inv2_0) ;
    float4 _S1129 = float4((&_S1120)->wcom_0) ;
    float4 _S1130 = float4((&_S1120)->winv0_0) ;
    float4 _S1131 = float4((&_S1120)->winv1_0) ;
    float4 _S1132 = float4((&_S1120)->winv2_0) ;
    float4 _S1133 = float4((&_S1120)->rotation_0) ;
    float4 _S1134 = float4((&_S1120)->position_0) ;
    float4 _S1135 = float4((&_S1120)->position_err_0) ;
    float4 _S1136 = float4((&_S1120)->velocity_0) ;
    float4 _S1137 = float4((&_S1120)->velocity_err_0) ;
    float4 _S1138 = float4((&_S1120)->angular_velocity_0) ;
    uint4 _S1139 = uint4((&_S1120)->probes_0) ;
    float4 _S1140 = float4((&_S1120)->energy_0) ;
    float4 _S1141 = float4((&_S1120)->rotation_err_0) ;
    float4 _S1142 = float4((&_S1120)->momentum_0) ;
    float4 _S1143 = float4((&_S1120)->momentum_err_0) ;
    thread Island_0 isl_22;
    (&isl_22)->range_0 = uint4((&_S1120)->range_0) ;
    (&isl_22)->info_0 = _S1121;
    (&isl_22)->com_0 = _S1122;
    (&isl_22)->inertia0_0 = _S1123;
    (&isl_22)->inertia1_0 = _S1124;
    (&isl_22)->inertia2_0 = _S1125;
    (&isl_22)->inv0_0 = _S1126;
    (&isl_22)->inv1_0 = _S1127;
    (&isl_22)->inv2_0 = _S1128;
    (&isl_22)->wcom_0 = _S1129;
    (&isl_22)->winv0_0 = _S1130;
    (&isl_22)->winv1_0 = _S1131;
    (&isl_22)->winv2_0 = _S1132;
    (&isl_22)->rotation_0 = _S1133;
    (&isl_22)->position_0 = _S1134;
    (&isl_22)->position_err_0 = _S1135;
    (&isl_22)->velocity_0 = _S1136;
    (&isl_22)->velocity_err_0 = _S1137;
    (&isl_22)->angular_velocity_0 = _S1138;
    (&isl_22)->done_0 = (&_S1120)->done_0;
    (&isl_22)->coverage_0 = (&_S1120)->coverage_0;
    (&isl_22)->wide_groups_0 = (&_S1120)->wide_groups_0;
    (&isl_22)->done_pad_0 = (&_S1120)->done_pad_0;
    (&isl_22)->probes_0 = _S1139;
    (&isl_22)->energy_0 = _S1140;
    (&isl_22)->rotation_err_0 = _S1141;
    (&isl_22)->momentum_0 = _S1142;
    (&isl_22)->momentum_err_0 = _S1143;
    _S1120 = *_S1119;
    bool _S1144 = wide_enter_0(tid_14, &_S1120, &kernelContext_73);
    if(!_S1144)
    {
        return;
    }
    thread float3 work_5;
    thread float3 flags_2;
    wide_partials_0(tid_14, _S1118.first_0, (&isl_22)->wide_groups_0, 6U, &work_5, &flags_2, &kernelContext_73);
    if(tid_14 != 0U)
    {
        return;
    }
    thread Island_0 _S1145 = isl_22;
    uint _S1146 = wide_step_1(&_S1145, &kernelContext_73);
    if(((&isl_22)->probes_0.y) > ((&isl_22)->probes_0.x))
    {
        thread Island_0 _S1147 = isl_22;
        Rigid_0 _S1148 = rigid_of_1(&_S1147);
        thread Island_0 _S1149 = isl_22;
        thread Rigid_0 _S1150 = _S1148;
        record_probes_0(&_S1149, &_S1150, _S1146, &kernelContext_73);
    }
    bool halt_0 = (((&isl_22)->info_0.z) & 2U) != 0U;
    bool _S1151;
    if(halt_0)
    {
        _S1151 = (((&isl_22)->info_0.x) & 4U) != 0U;
    }
    else
    {
        _S1151 = false;
    }
    if(_S1151)
    {
        contact_split_at_0((&isl_22)->info_0.w + 1U, &kernelContext_73);
    }
    float _S1152 = work_5.x;
    thread float _S1153 = (&isl_22)->energy_0.x;
    thread float _S1154 = (&isl_22)->energy_0.y;
    comp_add1_0(&_S1153, &_S1154, _S1152);
    (&isl_22)->energy_0.x = _S1153;
    (&isl_22)->energy_0.y = _S1154 + work_5.y;
    (&isl_22)->done_0 = (&isl_22)->done_0 + 1U;
    (&isl_22)->info_0.y = (&isl_22)->info_0.y - 1U;
    (&isl_22)->info_0.w = (&isl_22)->info_0.w + 1U;
    if(halt_0)
    {
        (&isl_22)->info_0.z = (((&isl_22)->info_0.z) & 4294967293U) | 1U;
    }
    uint _S1155;
    if(halt_0)
    {
        _S1155 = 128U;
    }
    else
    {
        _S1155 = 0U;
    }
    uint _S1156 = 256U | _S1155;
    if(((&isl_22)->probes_0.y) > ((&isl_22)->probes_0.x))
    {
        _S1155 = 262144U;
    }
    else
    {
        _S1155 = 0U;
    }
    uint _S1157 = _S1156 | _S1155;
    if((((&isl_22)->info_0.x) & 4U) != 0U)
    {
        _S1155 = 524288U;
    }
    else
    {
        _S1155 = 0U;
    }
    uint _S1158 = _S1157 | _S1155;
    if((flags_2.x) > 0.0f)
    {
        _S1155 = 32768U;
    }
    else
    {
        _S1155 = 0U;
    }
    uint _S1159 = _S1158 | _S1155;
    if((flags_2.y) > 0.0f)
    {
        _S1155 = 65536U;
    }
    else
    {
        _S1155 = 0U;
    }
    uint _S1160 = _S1159 | _S1155;
    if((flags_2.z) > 0.0f)
    {
        _S1155 = 131072U;
    }
    else
    {
        _S1155 = 0U;
    }
    (&isl_22)->coverage_0 = ((&isl_22)->coverage_0) | (_S1160 | _S1155);
    Island_natural_0 device* _S1161 = (&kernelContext_73)->islands_0+_S1118.island_3;
    _S1161->range_0 = packed_uint4(isl_22.range_0) ;
    _S1161->info_0 = packed_uint4(isl_22.info_0) ;
    _S1161->com_0 = packed_float4(isl_22.com_0) ;
    _S1161->inertia0_0 = packed_float4(isl_22.inertia0_0) ;
    _S1161->inertia1_0 = packed_float4(isl_22.inertia1_0) ;
    _S1161->inertia2_0 = packed_float4(isl_22.inertia2_0) ;
    _S1161->inv0_0 = packed_float4(isl_22.inv0_0) ;
    _S1161->inv1_0 = packed_float4(isl_22.inv1_0) ;
    _S1161->inv2_0 = packed_float4(isl_22.inv2_0) ;
    _S1161->wcom_0 = packed_float4(isl_22.wcom_0) ;
    _S1161->winv0_0 = packed_float4(isl_22.winv0_0) ;
    _S1161->winv1_0 = packed_float4(isl_22.winv1_0) ;
    _S1161->winv2_0 = packed_float4(isl_22.winv2_0) ;
    _S1161->rotation_0 = packed_float4(isl_22.rotation_0) ;
    _S1161->position_0 = packed_float4(isl_22.position_0) ;
    _S1161->position_err_0 = packed_float4(isl_22.position_err_0) ;
    _S1161->velocity_0 = packed_float4(isl_22.velocity_0) ;
    _S1161->velocity_err_0 = packed_float4(isl_22.velocity_err_0) ;
    _S1161->angular_velocity_0 = packed_float4(isl_22.angular_velocity_0) ;
    _S1161->done_0 = isl_22.done_0;
    _S1161->coverage_0 = isl_22.coverage_0;
    _S1161->wide_groups_0 = isl_22.wide_groups_0;
    _S1161->done_pad_0 = isl_22.done_pad_0;
    _S1161->probes_0 = packed_uint4(isl_22.probes_0) ;
    _S1161->energy_0 = packed_float4(isl_22.energy_0) ;
    _S1161->rotation_err_0 = packed_float4(isl_22.rotation_err_0) ;
    _S1161->momentum_0 = packed_float4(isl_22.momentum_0) ;
    _S1161->momentum_err_0 = packed_float4(isl_22.momentum_err_0) ;
    return;
}

uint sv_0(uint c_28, uint slot_3, KernelContext_0 thread* kernelContext_74)
{
    return kernelContext_74->params_0->statics_base_0 + 23U * c_28 + slot_3;
}

void project_load_slot_0(uint tid_15, const Island_natural_0 thread* isl_23, uint slot_4, KernelContext_0 thread* kernelContext_75)
{
    uint _S1162;
    float3 _S1163 = float3(0.0f) ;
    thread float3 net_f_0 = _S1163;
    thread float3 net_m_0 = _S1163;
    uint4 _S1164 = uint4(isl_23->range_0) ;
    uint _S1165 = _S1164.x + tid_15;
    uint c_29 = _S1165;
    for(;;)
    {
        uint _S1166 = _S1164.y;
        _S1162 = _S1166;
        if(c_29 < _S1166)
        {
        }
        else
        {
            break;
        }
        uint _S1167 = sv_0(c_29, slot_4, kernelContext_75);
        float3 fi_2 = (float4(*(kernelContext_75->scratch_0+_S1167)) ).xyz;
        net_f_0 = net_f_0 + fi_2;
        float3 _S1168 = cross((float4((kernelContext_75->chunks_0+c_29)->center_0) ).xyz - (float4(isl_23->com_0) ).xyz, fi_2);
        uint _S1169 = sv_0(c_29, slot_4 + 1U, kernelContext_75);
        net_m_0 = net_m_0 + (_S1168 + (float4(*(kernelContext_75->scratch_0+_S1169)) ).xyz);
        c_29 = c_29 + 256U;
    }
    group_sum3_0(tid_15, &net_f_0, &net_m_0, kernelContext_75);
    float4 _S1170 = float4(isl_23->com_0) ;
    float3 _S1171 = net_f_0 / float3(_S1170.w) ;
    float3 _S1172 = rows_mul_0(float4(isl_23->inv0_0) , float4(isl_23->inv1_0) , float4(isl_23->inv2_0) , net_m_0);
    c_29 = _S1165;
    for(;;)
    {
        if(c_29 < _S1162)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_natural_0 device* _S1173 = kernelContext_75->chunks_0+c_29;
        float4 _S1174 = float4(_S1173->center_0) ;
        float3 r_12 = _S1174.xyz - _S1170.xyz;
        uint _S1175 = sv_0(c_29, slot_4, kernelContext_75);
        *(kernelContext_75->scratch_0+_S1175) = packed_float4(float4((float4(*(kernelContext_75->scratch_0+_S1175)) ).xyz - (_S1171 + cross(_S1172, r_12)) * float3(_S1174.w) , 0.0f)) ;
        uint _S1176 = sv_0(c_29, slot_4 + 1U, kernelContext_75);
        *(kernelContext_75->scratch_0+_S1176) = packed_float4(float4((float4(*(kernelContext_75->scratch_0+_S1176)) ).xyz - rows_mul_0(float4(_S1173->inertia0_1) , float4(_S1173->inertia1_1) , float4(_S1173->inertia2_1) , _S1172), 0.0f)) ;
        c_29 = c_29 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    return;
}

float island_dot_0(uint tid_16, uint c0_0, uint c1_0, uint sa_2, uint sb_2, KernelContext_0 thread* kernelContext_76)
{
    float4 _S1177 = float4(0.0f) ;
    thread float4 acc_0 = _S1177;
    thread float4 unused_4 = _S1177;
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
        uint _S1178 = sv_0(c_30, sa_2, kernelContext_76);
        float3 _S1179 = (float4(*(kernelContext_76->scratch_0+_S1178)) ).xyz;
        uint _S1180 = sv_0(c_30, sb_2, kernelContext_76);
        float _S1181 = dot(_S1179, (float4(*(kernelContext_76->scratch_0+_S1180)) ).xyz);
        uint _S1182 = sv_0(c_30, sa_2 + 1U, kernelContext_76);
        float3 _S1183 = (float4(*(kernelContext_76->scratch_0+_S1182)) ).xyz;
        uint _S1184 = sv_0(c_30, sb_2 + 1U, kernelContext_76);
        acc_0.x = acc_0.x + (_S1181 + dot(_S1183, (float4(*(kernelContext_76->scratch_0+_S1184)) ).xyz));
        c_30 = c_30 + 256U;
    }
    group_sum2_0(tid_16, &acc_0, &unused_4, kernelContext_76);
    return acc_0.x;
}

void static_kinematics_0(uint _S1185, float3 thread* _S1186, float3 thread* _S1187, KernelContext_0 thread* kernelContext_77)
{
    BondStatic_natural_0 device* _S1188 = kernelContext_77->bonds_0+_S1185;
    uint4 _S1189 = uint4(_S1188->law_0.ids_0) ;
    uint ca_1 = _S1189.y;
    uint cb_1 = _S1189.z;
    uint _S1190 = 4U * cb_1;
    uint _S1191 = 4U * ca_1;
    float3 _S1192 = (float4(*(kernelContext_77->state_0+_S1190)) ).xyz - (float4(*(kernelContext_77->state_0+_S1191)) ).xyz;
    uint _S1193 = sv_0(cb_1, 21U, kernelContext_77);
    float3 _S1194 = (float4(*(kernelContext_77->scratch_0+_S1193)) ).xyz;
    uint _S1195 = sv_0(ca_1, 21U, kernelContext_77);
    float3 du_0 = _S1192 + (_S1194 - (float4(*(kernelContext_77->scratch_0+_S1195)) ).xyz);
    uint _S1196 = _S1190 + 1U;
    uint _S1197 = _S1191 + 1U;
    float3 _S1198 = (float4(*(kernelContext_77->state_0+_S1196)) ).xyz - (float4(*(kernelContext_77->state_0+_S1197)) ).xyz;
    uint _S1199 = sv_0(cb_1, 22U, kernelContext_77);
    float3 _S1200 = (float4(*(kernelContext_77->scratch_0+_S1199)) ).xyz;
    uint _S1201 = sv_0(ca_1, 22U, kernelContext_77);
    float3 dth_0 = _S1198 + (_S1200 - (float4(*(kernelContext_77->scratch_0+_S1201)) ).xyz);
    float3 _S1202 = to_local_0(_S1185, du_0 + (cross((float4(*(kernelContext_77->state_0+_S1196)) ).xyz + (float4(*(kernelContext_77->scratch_0+_S1199)) ).xyz, (float4(_S1188->rb_0) ).xyz) - cross((float4(*(kernelContext_77->state_0+_S1197)) ).xyz + (float4(*(kernelContext_77->scratch_0+_S1201)) ).xyz, (float4(_S1188->ra_0) ).xyz)), kernelContext_77);
    *_S1186 = _S1202;
    float3 _S1203 = to_local_0(_S1185, dth_0, kernelContext_77);
    *_S1187 = _S1203;
    return;
}

JointResponse_0 static_response_0(uint i_12, KernelContext_0 thread* kernelContext_78)
{
    BondStatic_natural_0 device* _S1204 = kernelContext_78->bonds_0+i_12;
    thread float3 d_lin_4;
    thread float3 d_ang_3;
    static_kinematics_0(i_12, &d_lin_4, &d_ang_3, kernelContext_78);
    thread JointBond_natural_0 _S1205 = _S1204->law_0;
    _S1205 = _S1204->law_0;
    thread JointState_0 _S1206 = (kernelContext_78->bond_dyn_0+i_12)->js_0;
    JointResponse_0 _S1207 = joint_evaluate_0(&kernelContext_78->materials_0->m_0[(uint4((&_S1205)->ids_0) ).x], &_S1205, &_S1206, d_lin_4, d_ang_3, 0.0f, false);
    return _S1207;
}

void gather_loads_0(uint c_31, float3 thread* fi_3, float3 thread* mi_6, KernelContext_0 thread* kernelContext_79)
{
    float3 _S1208 = float3(0.0f) ;
    *fi_3 = _S1208;
    *mi_6 = _S1208;
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
            uint _S1209 = 3U * bond_0;
            *fi_3 = *fi_3 + (float4(*(kernelContext_79->scratch_0+_S1209)) ).xyz;
            *mi_6 = *mi_6 + (float4(*(kernelContext_79->scratch_0+(_S1209 + 1U))) ).xyz;
        }
        else
        {
            uint _S1210 = 3U * bond_0;
            *fi_3 = *fi_3 - (float4(*(kernelContext_79->scratch_0+_S1210)) ).xyz;
            *mi_6 = *mi_6 + (float4(*(kernelContext_79->scratch_0+(_S1210 + 2U))) ).xyz;
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
        uint _S1211 = 3U * (entry_5 >> 1U);
        float3 f_18 = (float4(*(kernelContext_80->scratch_0+_S1211)) ).xyz;
        float3 t_18;
        if((entry_5 & 1U) == 0U)
        {
            t_18 = (float4(*(kernelContext_80->scratch_0+(_S1211 + 1U))) ).xyz;
        }
        else
        {
            t_18 = (float4(*(kernelContext_80->scratch_0+(_S1211 + 2U))) ).xyz;
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
    uint _S1212;
    if(support_2 == 1U)
    {
        _S1212 = 63U;
    }
    else
    {
        if(support_2 == 2U)
        {
            _S1212 = 7U;
        }
        else
        {
            _S1212 = 0U;
        }
    }
    return _S1212;
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
        bool _S1213;
        if(i_14 < 6U)
        {
            _S1213 = spd_0;
        }
        else
        {
            _S1213 = false;
        }
        if(_S1213)
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
            uint _S1214 = i_14 * 6U;
            uint _S1215 = _S1214 + j_8;
            k_21 = 0U;
            sum_4 = (*a_14)[_S1215];
            for(;;)
            {
                if(k_21 < j_8)
                {
                }
                else
                {
                    break;
                }
                float sum_5 = sum_4 - l_5[_S1214 + k_21] * l_5[j_8 * 6U + k_21];
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
                l_5[_S1214 + i_14] = sqrt(sum_4);
            }
            else
            {
                l_5[_S1215] = sum_4 / l_5[j_8 * 6U + j_8];
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
            uint _S1216 = k_21 * 6U + k_21;
            float _S1217 = (*a_14)[_S1216];
            if(((*a_14)[_S1216]) > 0.0f)
            {
                sum_4 = 1.0f / _S1217;
            }
            else
            {
                sum_4 = 0.0f;
            }
            inv_0[_S1216] = sum_4;
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
        uint _S1218 = sv_0(c_34, 12U + j_8, kernelContext_83);
        uint _S1219 = 4U * j_8;
        *(kernelContext_83->scratch_0+_S1218) = packed_float4(float4(inv_0[_S1219], inv_0[_S1219 + 1U], inv_0[_S1219 + 2U], inv_0[_S1219 + 3U])) ;
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
        bool _S1220 = (entry_6 & 1U) != 0U;
        BondStatic_natural_0 device* _S1221 = kernelContext_84->bonds_0+i_17;
        uint _S1222 = statics_bond_slot_0(i_17, kernelContext_84);
        float4 _S1223 = float4(*(kernelContext_84->scratch_0+_S1222)) ;
        float4 _S1224 = float4(*(kernelContext_84->scratch_0+(_S1222 + 1U))) ;
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
            uint _S1225 = p_16 % 3U;
            float3 t_19;
            if(_S1225 == 0U)
            {
                t_19 = (float4(_S1221->t1_0) ).xyz;
            }
            else
            {
                if(_S1225 == 1U)
                {
                    t_19 = (float4(_S1221->t2_0) ).xyz;
                }
                else
                {
                    t_19 = (float4(_S1221->normal_0) ).xyz;
                }
            }
            bool _S1226 = p_16 < 3U;
            float3 row_u_0;
            float3 row_t_0;
            if(_S1226)
            {
                if(_S1220)
                {
                    row_u_0 = t_19;
                }
                else
                {
                    row_u_0 = - t_19;
                }
                if(_S1220)
                {
                    row_t_0 = cross((float4(_S1221->rb_0) ).xyz, t_19);
                }
                else
                {
                    row_t_0 = - cross((float4(_S1221->ra_0) ).xyz, t_19);
                }
            }
            else
            {
                float3 _S1227 = float3(0.0f) ;
                if(_S1220)
                {
                    row_u_0 = t_19;
                }
                else
                {
                    row_u_0 = - t_19;
                }
                float3 _S1228 = row_u_0;
                row_u_0 = _S1227;
                row_t_0 = _S1228;
            }
            float kp_0;
            if(_S1226)
            {
                kp_0 = _S1223[p_16];
            }
            else
            {
                kp_0 = _S1224[p_16 - 3U];
            }
            if(kp_0 == 0.0f)
            {
                p_16 = p_16 + 1U;
                continue;
            }
            array<float, int(6)> _S1229 = { { row_u_0.x, row_u_0.y, row_u_0.z, row_t_0.x, row_t_0.y, row_t_0.z } };
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
                    a_15[r_13 * 6U + q_15] = a_15[r_13 * 6U + q_15] + kp_0 * _S1229[r_13] * _S1229[q_15];
                    q_15 = q_15 + 1U;
                }
                r_13 = r_13 + 1U;
            }
            p_16 = p_16 + 1U;
        }
        e_7 = e_7 + 1U;
    }
    uint _S1230 = fixed_mask_0(c_35, kernelContext_84);
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
        if((_S1230 & (1U << p_16)) != 0U)
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
    thread array<float, int(36)> _S1231 = a_15;
    store_inverse_0(c_35, &_S1231, kernelContext_84);
    return;
}

float block_get_0(uint c_36, uint i_18, uint j_9, KernelContext_0 thread* kernelContext_85)
{
    uint k_23 = i_18 * 6U + j_9;
    uint _S1232 = sv_0(c_36, 12U + k_23 / 4U, kernelContext_85);
    return (*(kernelContext_85->scratch_0+_S1232))[k_23 % 4U];
}

void precondition_0(uint c_37, KernelContext_0 thread* kernelContext_86)
{
    uint _S1233 = sv_0(c_37, 4U, kernelContext_86);
    float4 _S1234 = float4(*(kernelContext_86->scratch_0+_S1233)) ;
    uint _S1235 = sv_0(c_37, 5U, kernelContext_86);
    float4 _S1236 = float4(*(kernelContext_86->scratch_0+_S1235)) ;
    array<float, int(6)> _S1237 = { { _S1234.x, _S1234.y, _S1234.z, _S1236.x, _S1236.y, _S1236.z } };
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
            float _S1238 = block_get_0(c_37, i_19, j_10, kernelContext_86);
            float s_12 = s_11 + _S1238 * _S1237[j_10];
            j_10 = j_10 + 1U;
            s_11 = s_12;
        }
        z_1[i_19] = s_11;
        i_19 = i_19 + 1U;
    }
    uint _S1239 = sv_0(c_37, 6U, kernelContext_86);
    *(kernelContext_86->scratch_0+_S1239) = packed_float4(float4(z_1[int(0)], z_1[int(1)], z_1[int(2)], 0.0f)) ;
    uint _S1240 = sv_0(c_37, 7U, kernelContext_86);
    *(kernelContext_86->scratch_0+_S1240) = packed_float4(float4(z_1[int(3)], z_1[int(4)], z_1[int(5)], 0.0f)) ;
    return;
}

void project_displacement_slot_0(uint tid_17, const Island_natural_0 thread* isl_24, uint slot_5, KernelContext_0 thread* kernelContext_87)
{
    uint _S1241;
    float3 _S1242 = float3(0.0f) ;
    thread float3 p_17 = _S1242;
    thread float3 l_6 = _S1242;
    uint4 _S1243 = uint4(isl_24->range_0) ;
    uint _S1244 = _S1243.x + tid_17;
    uint c_38 = _S1244;
    for(;;)
    {
        uint _S1245 = _S1243.y;
        _S1241 = _S1245;
        if(c_38 < _S1245)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_natural_0 device* _S1246 = kernelContext_87->chunks_0+c_38;
        uint _S1247 = sv_0(c_38, slot_5, kernelContext_87);
        float3 u_6 = (float4(*(kernelContext_87->scratch_0+_S1247)) ).xyz;
        uint _S1248 = sv_0(c_38, slot_5 + 1U, kernelContext_87);
        float3 th_8 = (float4(*(kernelContext_87->scratch_0+_S1248)) ).xyz;
        float4 _S1249 = float4(_S1246->center_0) ;
        float3 r_14 = _S1249.xyz - (float4(isl_24->com_0) ).xyz;
        float3 _S1250 = float3(_S1249.w) ;
        p_17 = p_17 + u_6 * _S1250;
        l_6 = l_6 + (cross(r_14, u_6) * _S1250 + rows_mul_0(float4(_S1246->inertia0_1) , float4(_S1246->inertia1_1) , float4(_S1246->inertia2_1) , th_8));
        c_38 = c_38 + 256U;
    }
    group_sum3_0(tid_17, &p_17, &l_6, kernelContext_87);
    float4 _S1251 = float4(isl_24->com_0) ;
    float3 _S1252 = p_17 / float3(_S1251.w) ;
    float3 _S1253 = rows_mul_0(float4(isl_24->inv0_0) , float4(isl_24->inv1_0) , float4(isl_24->inv2_0) , l_6);
    c_38 = _S1244;
    for(;;)
    {
        if(c_38 < _S1241)
        {
        }
        else
        {
            break;
        }
        float3 r_15 = (float4((kernelContext_87->chunks_0+c_38)->center_0) ).xyz - _S1251.xyz;
        uint _S1254 = sv_0(c_38, slot_5, kernelContext_87);
        *(kernelContext_87->scratch_0+_S1254) = packed_float4(float4((float4(*(kernelContext_87->scratch_0+_S1254)) ).xyz - _S1252 - cross(_S1253, r_15), 0.0f)) ;
        uint _S1255 = sv_0(c_38, slot_5 + 1U, kernelContext_87);
        *(kernelContext_87->scratch_0+_S1255) = packed_float4(float4((float4(*(kernelContext_87->scratch_0+_S1255)) ).xyz - _S1253, 0.0f)) ;
        c_38 = c_38 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    return;
}

uint statics_result_slot_0(uint island_4, KernelContext_0 thread* kernelContext_88)
{
    return kernelContext_88->params_0->statics_base_0 + 23U * kernelContext_88->params_0->chunk_count_0 + 2U * kernelContext_88->params_0->statics_bonds_0 + island_4;
}

void write_bond_loads_0(uint _S1256, uint _S1257, float3 _S1258, float3 _S1259, float _S1260, KernelContext_0 thread* kernelContext_89)
{
    BondStatic_natural_0 device* _S1261 = kernelContext_89->bonds_0+_S1257;
    float3 _S1262 = to_body_0(_S1257, _S1258, kernelContext_89);
    float3 _S1263 = to_body_0(_S1257, _S1259, kernelContext_89);
    uint _S1264 = 3U * _S1256;
    *(kernelContext_89->scratch_0+_S1264) = packed_float4(float4(_S1262, _S1260)) ;
    *(kernelContext_89->scratch_0+(_S1264 + 1U)) = packed_float4(float4(_S1263 + cross((float4(_S1261->ra_0) ).xyz, _S1262), 0.0f)) ;
    *(kernelContext_89->scratch_0+(_S1264 + 2U)) = packed_float4(float4(- _S1263 + cross((float4(_S1261->rb_0) ).xyz, - _S1262), 0.0f)) ;
    return;
}

void bond_kinematics_0(uint _S1265, float3 _S1266, float3 _S1267, float3 _S1268, float3 _S1269, float3 thread* _S1270, float3 thread* _S1271, KernelContext_0 thread* kernelContext_90)
{
    BondStatic_natural_0 device* _S1272 = kernelContext_90->bonds_0+_S1265;
    float3 _S1273 = to_local_0(_S1265, _S1268 + cross(_S1269, (float4(_S1272->rb_0) ).xyz) - (_S1266 + cross(_S1267, (float4(_S1272->ra_0) ).xyz)), kernelContext_90);
    *_S1270 = _S1273;
    float3 _S1274 = to_local_0(_S1265, _S1269 - _S1267, kernelContext_90);
    *_S1271 = _S1274;
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
    uint _S1275 = group_9.x;
    thread Island_natural_0 _S1276 = *(islands_13+_S1275);
    uint4 _S1277 = uint4((&_S1276)->info_0) ;
    uint _S1278 = _S1277.z;
    if((_S1278 & 8U) == 0U)
    {
        return;
    }
    bool free_0 = ((_S1277.x) & 1U) == 0U;
    uint4 _S1279 = uint4((&_S1276)->range_0) ;
    uint c0_1 = _S1279.x;
    uint c1_1 = _S1279.y;
    uint b0_0 = _S1279.z;
    uint _S1280 = _S1279.w;
    uint _S1281 = c0_1 + tid_18;
    uint c_40 = _S1281;
    for(;;)
    {
        if(c_40 < c1_1)
        {
        }
        else
        {
            break;
        }
        uint _S1282 = sv_0(c_40, 21U, &kernelContext_91);
        packed_float4 _S1283 = packed_float4(float4(0.0f) ) ;
        *((&kernelContext_91)->scratch_0+_S1282) = _S1283;
        uint _S1284 = sv_0(c_40, 22U, &kernelContext_91);
        *((&kernelContext_91)->scratch_0+_S1284) = _S1283;
        c_40 = c_40 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    if(free_0)
    {
        project_load_slot_0(tid_18, &_S1276, 0U, &kernelContext_91);
    }
    float _S1285 = island_dot_0(tid_18, c0_1, c1_1, 0U, 0U, &kernelContext_91);
    float _S1286 = max(sqrt(_S1285), 1.00000000317107685e-30f);
    float _S1287 = (&kernelContext_91)->params_0->statics_tol_0;
    uint _S1288 = min((&kernelContext_91)->params_0->statics_cg_0, 20U * (c1_1 - c0_1) * 6U + 200U);
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
        uint _S1289 = b0_0 + tid_18;
        i_20 = _S1289;
        for(;;)
        {
            if(i_20 < _S1280)
            {
            }
            else
            {
                break;
            }
            JointResponse_0 _S1290 = static_response_0(i_20, &kernelContext_91);
            write_bond_loads_0(i_20, i_20, _S1290.force_lin_1, _S1290.force_ang_1, 0.0f, &kernelContext_91);
            i_20 = i_20 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        float4 _S1291 = float4(0.0f) ;
        thread float4 magnitude_0 = _S1291;
        thread float4 unused_m_0 = _S1291;
        c_40 = _S1281;
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
            float _S1292 = bond_load_magnitude2_0(c_40, &kernelContext_91);
            magnitude_0.x = magnitude_0.x + _S1292;
            uint _S1293 = sv_0(c_40, 0U, &kernelContext_91);
            thread float4 r_lin_0 = float4((float4(*((&kernelContext_91)->scratch_0+_S1293)) ).xyz + fi_4, 0.0f);
            uint _S1294 = sv_0(c_40, 1U, &kernelContext_91);
            thread float4 r_ang_0 = float4((float4(*((&kernelContext_91)->scratch_0+_S1294)) ).xyz + mi_7, 0.0f);
            uint _S1295 = fixed_mask_0(c_40, &kernelContext_91);
            hold_0(_S1295, &r_lin_0, &r_ang_0, _S1291, _S1291);
            uint _S1296 = sv_0(c_40, 4U, &kernelContext_91);
            *((&kernelContext_91)->scratch_0+_S1296) = packed_float4(r_lin_0) ;
            uint _S1297 = sv_0(c_40, 5U, &kernelContext_91);
            *((&kernelContext_91)->scratch_0+_S1297) = packed_float4(r_ang_0) ;
            c_40 = c_40 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        group_sum2_0(tid_18, &magnitude_0, &unused_m_0, &kernelContext_91);
        if(free_0)
        {
            project_load_slot_0(tid_18, &_S1276, 4U, &kernelContext_91);
        }
        float _S1298 = island_dot_0(tid_18, c0_1, c1_1, 4U, 4U, &kernelContext_91);
        float residual_1 = sqrt(_S1298) / _S1286;
        float _S1299 = max(0.00100000004749745f, 3.83999986297567375e-06f * sqrt(magnitude_0.x) / _S1286);
        if(residual_1 <= _S1287)
        {
            converged_0 = true;
        }
        else
        {
            if(residual_1 <= _S1299)
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
        uint i_21 = _S1289;
        for(;;)
        {
            if(i_21 < _S1280)
            {
            }
            else
            {
                break;
            }
            BondStatic_natural_0 device* _S1300 = (&kernelContext_91)->bonds_0+i_21;
            thread float3 d_lin_5;
            thread float3 d_ang_4;
            static_kinematics_0(i_21, &d_lin_5, &d_ang_4, &kernelContext_91);
            thread JointBond_natural_0 _S1301 = _S1300->law_0;
            thread JointState_0 _S1302 = ((&kernelContext_91)->bond_dyn_0+i_21)->js_0;
            thread float3 f_lin_2;
            thread float3 f_ang_2;
            secant_factors_0(&_S1301, &_S1302, d_lin_5, &f_lin_2, &f_ang_2);
            float4 _S1303 = float4((&_S1301)->stiff0_0) ;
            uint _S1304 = statics_bond_slot_0(i_21, &kernelContext_91);
            float _S1305 = _S1303.y;
            *((&kernelContext_91)->scratch_0+_S1304) = packed_float4(float4(_S1305 * f_lin_2.x, _S1305 * f_lin_2.y, _S1303.x * f_lin_2.z, 0.0f)) ;
            *((&kernelContext_91)->scratch_0+(_S1304 + 1U)) = packed_float4(float4(_S1303.z * f_ang_2.x, _S1303.w * f_ang_2.y, (float4((&_S1301)->stiff1_0) ).x * f_ang_2.z, 0.0f)) ;
            i_21 = i_21 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_41 = _S1281;
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
            uint _S1306 = sv_0(c_41, 2U, &kernelContext_91);
            packed_float4 _S1307 = packed_float4(_S1291) ;
            *((&kernelContext_91)->scratch_0+_S1306) = _S1307;
            uint _S1308 = sv_0(c_41, 3U, &kernelContext_91);
            *((&kernelContext_91)->scratch_0+_S1308) = _S1307;
            c_41 = c_41 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_42 = _S1281;
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
            project_displacement_slot_0(tid_18, &_S1276, 6U, &kernelContext_91);
        }
        uint c_43 = _S1281;
        for(;;)
        {
            if(c_43 < c1_1)
            {
            }
            else
            {
                break;
            }
            uint _S1309 = sv_0(c_43, 8U, &kernelContext_91);
            packed_float4 device* _S1310 = (&kernelContext_91)->scratch_0+_S1309;
            uint _S1311 = sv_0(c_43, 6U, &kernelContext_91);
            *_S1310 = packed_float4(float4(*((&kernelContext_91)->scratch_0+_S1311)) ) ;
            uint _S1312 = sv_0(c_43, 9U, &kernelContext_91);
            packed_float4 device* _S1313 = (&kernelContext_91)->scratch_0+_S1312;
            uint _S1314 = sv_0(c_43, 7U, &kernelContext_91);
            *_S1313 = packed_float4(float4(*((&kernelContext_91)->scratch_0+_S1314)) ) ;
            c_43 = c_43 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        float _S1315 = island_dot_0(tid_18, c0_1, c1_1, 4U, 6U, &kernelContext_91);
        float _S1316 = island_dot_0(tid_18, c0_1, c1_1, 4U, 4U, &kernelContext_91);
        float _S1317 = sqrt(_S1316);
        float rz_0 = _S1315;
        uint k_24 = 0U;
        uint cg_total_1 = cg_total_0;
        for(;;)
        {
            bool _S1318;
            if(k_24 < _S1288)
            {
                _S1318 = _S1317 > 0.0f;
            }
            else
            {
                _S1318 = false;
            }
            if(_S1318)
            {
            }
            else
            {
                cg_total_0 = cg_total_1;
                break;
            }
            uint i_22 = _S1289;
            for(;;)
            {
                if(i_22 < _S1280)
                {
                }
                else
                {
                    break;
                }
                uint4 _S1319 = uint4(((&kernelContext_91)->bonds_0+i_22)->law_0.ids_0) ;
                uint ca_2 = _S1319.y;
                uint cb_2 = _S1319.z;
                uint _S1320 = sv_0(ca_2, 8U, &kernelContext_91);
                float3 _S1321 = (float4(*((&kernelContext_91)->scratch_0+_S1320)) ).xyz;
                uint _S1322 = sv_0(ca_2, 9U, &kernelContext_91);
                float3 _S1323 = (float4(*((&kernelContext_91)->scratch_0+_S1322)) ).xyz;
                uint _S1324 = sv_0(cb_2, 8U, &kernelContext_91);
                float3 _S1325 = (float4(*((&kernelContext_91)->scratch_0+_S1324)) ).xyz;
                uint _S1326 = sv_0(cb_2, 9U, &kernelContext_91);
                thread float3 d_lin_6;
                thread float3 d_ang_5;
                bond_kinematics_0(i_22, _S1321, _S1323, _S1325, (float4(*((&kernelContext_91)->scratch_0+_S1326)) ).xyz, &d_lin_6, &d_ang_5, &kernelContext_91);
                uint _S1327 = statics_bond_slot_0(i_22, &kernelContext_91);
                write_bond_loads_0(i_22, i_22, d_lin_6 * (float4(*((&kernelContext_91)->scratch_0+_S1327)) ).xyz, d_ang_5 * (float4(*((&kernelContext_91)->scratch_0+(_S1327 + 1U))) ).xyz, 0.0f, &kernelContext_91);
                i_22 = i_22 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            c_39 = _S1281;
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
                uint _S1328 = fixed_mask_0(c_39, &kernelContext_91);
                uint _S1329 = sv_0(c_39, 8U, &kernelContext_91);
                float4 _S1330 = float4(*((&kernelContext_91)->scratch_0+_S1329)) ;
                uint _S1331 = sv_0(c_39, 9U, &kernelContext_91);
                hold_0(_S1328, &ap_lin_0, &ap_ang_0, _S1330, float4(*((&kernelContext_91)->scratch_0+_S1331)) );
                uint _S1332 = sv_0(c_39, 10U, &kernelContext_91);
                *((&kernelContext_91)->scratch_0+_S1332) = packed_float4(ap_lin_0) ;
                uint _S1333 = sv_0(c_39, 11U, &kernelContext_91);
                *((&kernelContext_91)->scratch_0+_S1333) = packed_float4(ap_ang_0) ;
                c_39 = c_39 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            float _S1334 = island_dot_0(tid_18, c0_1, c1_1, 8U, 10U, &kernelContext_91);
            uint _S1335 = cg_total_1 + 1U;
            if(_S1334 <= 0.0f)
            {
                cg_total_0 = _S1335;
                break;
            }
            float _S1336 = rz_0 / _S1334;
            uint c_44 = _S1281;
            for(;;)
            {
                if(c_44 < c1_1)
                {
                }
                else
                {
                    break;
                }
                uint _S1337 = sv_0(c_44, 2U, &kernelContext_91);
                packed_float4 device* _S1338 = (&kernelContext_91)->scratch_0+_S1337;
                float3 _S1339 = (float4(*((&kernelContext_91)->scratch_0+_S1337)) ).xyz;
                uint _S1340 = sv_0(c_44, 8U, &kernelContext_91);
                float3 _S1341 = float3(_S1336) ;
                *_S1338 = packed_float4(float4(_S1339 + _S1341 * (float4(*((&kernelContext_91)->scratch_0+_S1340)) ).xyz, 0.0f)) ;
                uint _S1342 = sv_0(c_44, 3U, &kernelContext_91);
                packed_float4 device* _S1343 = (&kernelContext_91)->scratch_0+_S1342;
                float3 _S1344 = (float4(*((&kernelContext_91)->scratch_0+_S1342)) ).xyz;
                uint _S1345 = sv_0(c_44, 9U, &kernelContext_91);
                *_S1343 = packed_float4(float4(_S1344 + _S1341 * (float4(*((&kernelContext_91)->scratch_0+_S1345)) ).xyz, 0.0f)) ;
                uint _S1346 = sv_0(c_44, 4U, &kernelContext_91);
                packed_float4 device* _S1347 = (&kernelContext_91)->scratch_0+_S1346;
                float3 _S1348 = (float4(*((&kernelContext_91)->scratch_0+_S1346)) ).xyz;
                uint _S1349 = sv_0(c_44, 10U, &kernelContext_91);
                *_S1347 = packed_float4(float4(_S1348 - _S1341 * (float4(*((&kernelContext_91)->scratch_0+_S1349)) ).xyz, 0.0f)) ;
                uint _S1350 = sv_0(c_44, 5U, &kernelContext_91);
                packed_float4 device* _S1351 = (&kernelContext_91)->scratch_0+_S1350;
                float3 _S1352 = (float4(*((&kernelContext_91)->scratch_0+_S1350)) ).xyz;
                uint _S1353 = sv_0(c_44, 11U, &kernelContext_91);
                *_S1351 = packed_float4(float4(_S1352 - _S1341 * (float4(*((&kernelContext_91)->scratch_0+_S1353)) ).xyz, 0.0f)) ;
                c_44 = c_44 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            float _S1354 = island_dot_0(tid_18, c0_1, c1_1, 4U, 4U, &kernelContext_91);
            if((sqrt(_S1354)) <= (0.00009999999747379f * _S1317))
            {
                cg_total_0 = _S1335;
                break;
            }
            uint c_45 = _S1281;
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
                project_displacement_slot_0(tid_18, &_S1276, 6U, &kernelContext_91);
            }
            float _S1355 = island_dot_0(tid_18, c0_1, c1_1, 4U, 6U, &kernelContext_91);
            float _S1356 = _S1355 / rz_0;
            uint c_46 = _S1281;
            for(;;)
            {
                if(c_46 < c1_1)
                {
                }
                else
                {
                    break;
                }
                uint _S1357 = sv_0(c_46, 8U, &kernelContext_91);
                packed_float4 device* _S1358 = (&kernelContext_91)->scratch_0+_S1357;
                uint _S1359 = sv_0(c_46, 6U, &kernelContext_91);
                float3 _S1360 = float3(_S1356) ;
                *_S1358 = packed_float4(float4((float4(*((&kernelContext_91)->scratch_0+_S1359)) ).xyz + _S1360 * (float4(*((&kernelContext_91)->scratch_0+_S1357)) ).xyz, 0.0f)) ;
                uint _S1361 = sv_0(c_46, 9U, &kernelContext_91);
                packed_float4 device* _S1362 = (&kernelContext_91)->scratch_0+_S1361;
                uint _S1363 = sv_0(c_46, 7U, &kernelContext_91);
                *_S1362 = packed_float4(float4((float4(*((&kernelContext_91)->scratch_0+_S1363)) ).xyz + _S1360 * (float4(*((&kernelContext_91)->scratch_0+_S1361)) ).xyz, 0.0f)) ;
                c_46 = c_46 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            uint _S1364 = k_24 + 1U;
            rz_0 = _S1355;
            k_24 = _S1364;
            cg_total_1 = _S1335;
        }
        c_39 = _S1281;
        for(;;)
        {
            if(c_39 < c1_1)
            {
            }
            else
            {
                break;
            }
            uint _S1365 = 4U * c_39;
            thread float3 u_7 = (float4(*((&kernelContext_91)->state_0+_S1365)) ).xyz;
            uint _S1366 = sv_0(c_39, 21U, &kernelContext_91);
            thread float3 u_lo_0 = (float4(*((&kernelContext_91)->scratch_0+_S1366)) ).xyz;
            uint _S1367 = _S1365 + 1U;
            thread float3 th_9 = (float4(*((&kernelContext_91)->state_0+_S1367)) ).xyz;
            uint _S1368 = sv_0(c_39, 22U, &kernelContext_91);
            thread float3 th_lo_0 = (float4(*((&kernelContext_91)->scratch_0+_S1368)) ).xyz;
            uint _S1369 = sv_0(c_39, 2U, &kernelContext_91);
            comp_add_0(&u_7, &u_lo_0, (float4(*((&kernelContext_91)->scratch_0+_S1369)) ).xyz);
            uint _S1370 = sv_0(c_39, 3U, &kernelContext_91);
            comp_add_0(&th_9, &th_lo_0, (float4(*((&kernelContext_91)->scratch_0+_S1370)) ).xyz);
            *((&kernelContext_91)->state_0+_S1365) = packed_float4(float4(u_7, (float4(*((&kernelContext_91)->state_0+_S1365)) ).w)) ;
            *((&kernelContext_91)->state_0+_S1367) = packed_float4(float4(th_9, (float4(*((&kernelContext_91)->state_0+_S1367)) ).w)) ;
            *((&kernelContext_91)->scratch_0+_S1366) = packed_float4(float4(u_lo_0, 0.0f)) ;
            *((&kernelContext_91)->scratch_0+_S1368) = packed_float4(float4(th_lo_0, 0.0f)) ;
            c_39 = c_39 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint _S1371 = newton_0 + 1U;
        previous_2 = residual_1;
        residual_0 = residual_1;
        newton_0 = _S1371;
    }
    i_20 = b0_0 + tid_18;
    for(;;)
    {
        if(i_20 < _S1280)
        {
        }
        else
        {
            break;
        }
        JointResponse_0 _S1372 = static_response_0(i_20, &kernelContext_91);
        BondDyn_natural_0 device* _S1373 = (&kernelContext_91)->bond_dyn_0+i_20;
        float4 _S1374 = float4((*_S1373).force_lin_0) ;
        float4 _S1375 = float4((*_S1373).force_ang_0) ;
        float4 _S1376 = float4((*_S1373).sums_0) ;
        float4 _S1377 = float4((*_S1373).comps_0) ;
        uint4 _S1378 = uint4((*_S1373).events_0) ;
        thread BondDyn_0 bd_1;
        (&bd_1)->js_0 = (*_S1373).js_0;
        (&bd_1)->force_lin_0 = _S1374;
        (&bd_1)->force_ang_0 = _S1375;
        (&bd_1)->sums_0 = _S1376;
        (&bd_1)->comps_0 = _S1377;
        (&bd_1)->events_0 = _S1378;
        (&bd_1)->force_lin_0 = float4(_S1372.force_lin_1, _S1372.stored_5);
        (&bd_1)->force_ang_0 = float4(_S1372.force_ang_1, (&bd_1)->force_ang_0.w);
        BondDyn_natural_0 device* _S1379 = (&kernelContext_91)->bond_dyn_0+i_20;
        _S1379->js_0 = bd_1.js_0;
        _S1379->force_lin_0 = packed_float4(bd_1.force_lin_0) ;
        _S1379->force_ang_0 = packed_float4(bd_1.force_ang_0) ;
        _S1379->sums_0 = packed_float4(bd_1.sums_0) ;
        _S1379->comps_0 = packed_float4(bd_1.comps_0) ;
        _S1379->events_0 = packed_uint4(bd_1.events_0) ;
        write_bond_loads_0(i_20, i_20, _S1372.force_lin_1, _S1372.force_ang_1, max(_S1372.measures_0.tension_0, _S1372.measures_0.compression_0), &kernelContext_91);
        i_20 = i_20 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    c_40 = _S1281;
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
        uint _S1380 = fixed_mask_0(c_40, &kernelContext_91);
        float3 reaction_2;
        if(_S1380 != 0U)
        {
            uint _S1381 = sv_0(c_40, 0U, &kernelContext_91);
            reaction_2 = - ((float4(*((&kernelContext_91)->scratch_0+_S1381)) ).xyz + fi_6);
        }
        else
        {
            uint _S1382 = 4U * c_40;
            reaction_2 = float3((float4(*((&kernelContext_91)->state_0+(_S1382 + 1U))) ).w, (float4(*((&kernelContext_91)->state_0+(_S1382 + 2U))) ).w, (float4(*((&kernelContext_91)->state_0+(_S1382 + 3U))) ).w);
        }
        uint _S1383 = 4U * c_40;
        uint _S1384 = _S1383 + 1U;
        *((&kernelContext_91)->state_0+_S1384) = packed_float4(float4((float4(*((&kernelContext_91)->state_0+_S1384)) ).xyz, reaction_2.x)) ;
        *((&kernelContext_91)->state_0+(_S1383 + 2U)) = packed_float4(float4(0.0f, 0.0f, 0.0f, reaction_2.y)) ;
        *((&kernelContext_91)->state_0+(_S1383 + 3U)) = packed_float4(float4(0.0f, 0.0f, 0.0f, reaction_2.z)) ;
        c_40 = c_40 + 256U;
    }
    if(tid_18 == 0U)
    {
        uint _S1385 = statics_result_slot_0(_S1275, &kernelContext_91);
        packed_float4 device* _S1386 = (&kernelContext_91)->scratch_0+_S1385;
        float _S1387 = (as_type<float>((newton_0)));
        float _S1388 = (as_type<float>((cg_total_0)));
        if(converged_0)
        {
            previous_2 = 1.0f;
        }
        else
        {
            previous_2 = 0.0f;
        }
        *_S1386 = packed_float4(float4(residual_0, _S1387, _S1388, previous_2)) ;
        ((&kernelContext_91)->islands_0+_S1275)->info_0[int(2)] = _S1278 & 4294967287U;
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
    uint _S1389 = group_10.x;
    Island_natural_0 device* _S1390 = islands_14+_S1389;
    Island_natural_0 isl_25 = *_S1390;
    uint4 _S1391 = uint4((*_S1390).info_0) ;
    bool _S1392;
    if(((_S1391.x) & 16U) == 0U)
    {
        _S1392 = true;
    }
    else
    {
        uint4 _S1393 = uint4(isl_25.range_0) ;
        _S1392 = (_S1393.w) == (_S1393.z);
    }
    if(_S1392)
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
    uint _S1394 = _S1391.w;
    uint4 _S1395 = uint4(isl_25.range_0) ;
    uint i_23 = _S1395.z + tid_19;
    for(;;)
    {
        if(i_23 < (_S1395.w))
        {
        }
        else
        {
            break;
        }
        BondStatic_natural_0 device* _S1396 = (&kernelContext_92)->bonds_0+i_23;
        BondDyn_natural_0 device* _S1397 = (&kernelContext_92)->bond_dyn_0+i_23;
        float4 _S1398 = float4((*_S1397).force_lin_0) ;
        float4 _S1399 = float4((*_S1397).force_ang_0) ;
        float4 _S1400 = float4((*_S1397).sums_0) ;
        float4 _S1401 = float4((*_S1397).comps_0) ;
        uint4 _S1402 = uint4((*_S1397).events_0) ;
        thread BondDyn_0 bd_2;
        (&bd_2)->js_0 = (*_S1397).js_0;
        (&bd_2)->force_lin_0 = _S1398;
        (&bd_2)->force_ang_0 = _S1399;
        (&bd_2)->sums_0 = _S1400;
        (&bd_2)->comps_0 = _S1401;
        (&bd_2)->events_0 = _S1402;
        thread JointBond_natural_0 _S1403 = _S1396->law_0;
        uint4 _S1404 = uint4((&_S1403)->ids_0) ;
        uint _S1405 = 4U * _S1404.y;
        uint _S1406 = 4U * _S1404.z;
        thread float3 d_lin_7;
        thread float3 d_ang_6;
        bond_kinematics_0(i_23, (float4(*((&kernelContext_92)->state_0+_S1405)) ).xyz, (float4(*((&kernelContext_92)->state_0+(_S1405 + 1U))) ).xyz, (float4(*((&kernelContext_92)->state_0+_S1406)) ).xyz, (float4(*((&kernelContext_92)->state_0+(_S1406 + 1U))) ).xyz, &d_lin_7, &d_ang_6, &kernelContext_92);
        JointState_0 previous_3 = (&bd_2)->js_0;
        float _S1407 = (&kernelContext_92)->params_0->dt_0;
        bool _S1408 = ((&kernelContext_92)->params_0->fracture_0) != 0U;
        _S1403 = _S1396->law_0;
        thread JointState_0 _S1409 = (&bd_2)->js_0;
        JointResponse_0 _S1410 = joint_evaluate_0(&(&kernelContext_92)->materials_0->m_0[_S1404.x], &_S1403, &_S1409, d_lin_7, d_ang_6, _S1407, _S1408);
        if((_S1410.state_6.damage_0) > (previous_3.damage_0 + 9.99999971718068537e-10f))
        {
            _S1392 = true;
        }
        else
        {
            _S1392 = (_S1410.state_6.crush_1) > (previous_3.crush_1 + 9.99999971718068537e-10f);
        }
        uint flags_3;
        if(_S1392)
        {
            flags_3 = 16U;
        }
        else
        {
            flags_3 = 0U;
        }
        thread float _S1411 = (&bd_2)->sums_0.x;
        thread float _S1412 = (&bd_2)->comps_0.x;
        comp_add1_0(&_S1411, &_S1412, _S1410.dissipated_2);
        (&bd_2)->comps_0.x = _S1412;
        (&bd_2)->sums_0.x = _S1411;
        thread float _S1413 = (&bd_2)->sums_0.y;
        thread float _S1414 = (&bd_2)->comps_0.y;
        comp_add1_0(&_S1413, &_S1414, _S1410.overshoot_0);
        (&bd_2)->comps_0.y = _S1414;
        (&bd_2)->sums_0.y = _S1413;
        (&bd_2)->force_lin_0 = float4(_S1410.force_lin_1, _S1410.stored_5);
        (&bd_2)->force_ang_0 = float4(_S1410.force_ang_1, max((&bd_2)->force_ang_0.w, _S1410.state_6.utilization_0));
        thread JointState_0 _S1415 = previous_3;
        bool _S1416 = is_damaged_0(&_S1415);
        bool _S1417;
        if(!_S1416)
        {
            thread JointState_0 _S1418 = _S1410.state_6;
            bool _S1419 = is_damaged_0(&_S1418);
            _S1417 = _S1419;
        }
        else
        {
            _S1417 = false;
        }
        bool _S1420;
        if(_S1417)
        {
            _S1420 = ((&bd_2)->events_0.x) == 0U;
        }
        else
        {
            _S1420 = false;
        }
        if(_S1420)
        {
            (&bd_2)->events_0.x = _S1394;
            (&bd_2)->events_0.w = _S1410.state_6.mode_0;
            (*(&kernelContext_92)->g_seen_0)[3U] = 1U;
        }
        bool _S1421;
        if(((&bd_2)->events_0.y) == 0U)
        {
            _S1421 = (_S1410.state_6.life_0) != (previous_3.life_0);
        }
        else
        {
            _S1421 = false;
        }
        bool _S1422;
        if(_S1421)
        {
            _S1422 = (_S1410.fatigue_before_0) > 0.99000000953674316f;
        }
        else
        {
            _S1422 = false;
        }
        bool _S1423;
        if(_S1422)
        {
            float _S1424 = fatigue_factor_0(&(&kernelContext_92)->materials_0->m_0[_S1404.x], _S1410.state_6.life_0);
            _S1423 = _S1424 <= 0.99000000953674316f;
        }
        else
        {
            _S1423 = false;
        }
        if(_S1423)
        {
            (&bd_2)->events_0.y = _S1394;
            (*(&kernelContext_92)->g_seen_0)[4U] = 1U;
        }
        uint flags_4;
        if(_S1410.disconnected_0)
        {
            (&bd_2)->events_0.z = _S1394;
            flags_4 = flags_3 | 32U;
        }
        else
        {
            flags_4 = flags_3;
        }
        (&bd_2)->js_0 = _S1410.state_6;
        BondDyn_natural_0 device* _S1425 = (&kernelContext_92)->bond_dyn_0+i_23;
        _S1425->js_0 = bd_2.js_0;
        _S1425->force_lin_0 = packed_float4(bd_2.force_lin_0) ;
        _S1425->force_ang_0 = packed_float4(bd_2.force_ang_0) ;
        _S1425->sums_0 = packed_float4(bd_2.sums_0) ;
        _S1425->comps_0 = packed_float4(bd_2.comps_0) ;
        _S1425->events_0 = packed_uint4(bd_2.events_0) ;
        write_bond_loads_0(i_23, i_23, _S1410.force_lin_1, _S1410.force_ang_1, max(_S1410.measures_0.tension_0, _S1410.measures_0.compression_0), &kernelContext_92);
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
        uint _S1426 = _S1391.z;
        if((*(&kernelContext_92)->g_halt_0) != 0U)
        {
            i_23 = 16U;
        }
        else
        {
            i_23 = 0U;
        }
        uint _S1427 = _S1426 | i_23;
        if((*(&kernelContext_92)->g_run_0) != 0U)
        {
            i_23 = 32U;
        }
        else
        {
            i_23 = 0U;
        }
        ((&kernelContext_92)->islands_0+_S1389)->info_0[int(2)] = _S1427 | i_23;
    }
    uint _S1428 = (isl_25.coverage_0) | 16384U;
    uint _S1429 = seen_bits_0(&kernelContext_92);
    uint _S1430 = _S1428 | _S1429;
    if((*(&kernelContext_92)->g_run_0) != 0U)
    {
        i_23 = 128U;
    }
    else
    {
        i_23 = 0U;
    }
    ((&kernelContext_92)->islands_0+_S1389)->coverage_0 = _S1430 | i_23;
    return;
}

