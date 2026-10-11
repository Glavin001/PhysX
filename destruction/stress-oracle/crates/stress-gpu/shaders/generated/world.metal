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
    uint device_connect_0;
    uint cplan_base_0;
    uint iplan_base_0;
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
    packed_float4 rotation_err_1;
    packed_float4 ledger_0;
    packed_uint4 cand_0;
    packed_float4 momentum_1;
    packed_float4 momentum_err_1;
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
    BondDyn_natural_0 device* bond_dyn_0;
    BondStatic_natural_0 device* bonds_0;
    MaterialTable_0 constant* materials_0;
    array<float4, int(32)> threadgroup* g_part_a_0;
    array<float4, int(32)> threadgroup* g_part_b_0;
    array<uint, int(5)> threadgroup* g_seen_0;
    uint threadgroup* g_wide_run_0;
    array<uint, int(4096)> threadgroup* g_label_0;
    uint threadgroup* g_changed_0;
    uint threadgroup* g_halt_0;
    uint threadgroup* g_run_0;
    array<uint, int(512)> threadgroup* g_label_narrow_0;
    uint threadgroup* g_changed_narrow_0;
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
    uint _S295 = 4U * c_5;
    uint at_2 = kernelContext_26->params_0->cplan_base_0 + _S295;
    float4 _S296 = float4(*(kernelContext_26->scratch_0+at_2)) ;
    float4 _S297 = float4(*(kernelContext_26->scratch_0+(at_2 + 1U))) ;
    float4 _S298 = float4(*(kernelContext_26->scratch_0+(at_2 + 2U))) ;
    float4 _S299 = float4(*(kernelContext_26->scratch_0+(at_2 + 3U))) ;
    WorldPoint_0 _S300 = chunk_world_0(c_5, kernelContext_26);
    float3 moved_0 = _S300.hi_0 - _S296.xyz + (_S300.lo_0 - _S297.xyz) + _S300.rel_0;
    uint _S301 = (uint4(_S293->info_1) ).y;
    float3 _S302 = float3((kernelContext_26->params_0->t_hi_0 - _S299.w + (kernelContext_26->params_0->t_lo_0 - _S297.w) + float((uint4((kernelContext_26->islands_0+_S301)->info_0) ).w - kernelContext_26->params_0->step_start_0) * kernelContext_26->params_0->dt_0)) ;
    float3 _S303 = _S299.xyz * _S302;
    uint _S304 = _S294.w;
    float3 _S305;
    if((_S304 & 2U) != 0U)
    {
        _S305 = float3(0.5f)  * kernelContext_26->params_0->gravity_0.xyz * _S302 * _S302;
    }
    else
    {
        _S305 = float3(0.0f) ;
    }
    float travel_0 = length(moved_0 - (_S303 + _S305));
    float travel_1;
    if((_S304 & 1U) != 0U)
    {
        float3 th_1 = (float4(*(kernelContext_26->state_0+(_S295 + 1U))) ).xyz;
        Quat_0 _S306 = from_axis_angle_0(th_1, length(th_1));
        thread Quat_0 _S307 = quat_of_0(float4((kernelContext_26->islands_0+_S301)->rotation_0) );
        thread Quat_0 _S308 = _S306;
        Quat_0 _S309 = quat_mul_0(&_S307, &_S308);
        thread Quat_0 _S310 = quat_of_0(float4(- _S298.xyz, _S298.w));
        thread Quat_0 _S311 = _S309;
        Quat_0 _S312 = quat_mul_0(&_S310, &_S311);
        travel_1 = travel_0 + 2.0f * atan2(length(float3(_S312.x_2, _S312.y_1, _S312.z_0)), abs(_S312.w_1)) * (float4(_S293->half_0) ).w;
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

void impactor_travel_check_0(uint ii_0, KernelContext_0 thread* kernelContext_27)
{
    Impactor_natural_0 device* _S313 = kernelContext_27->impactors_0+ii_0;
    uint at_3 = kernelContext_27->params_0->iplan_base_0 + 4U * ii_0;
    float4 _S314 = float4(*(kernelContext_27->scratch_0+at_3)) ;
    uint4 _S315 = uint4(_S313->cand_0) ;
    bool _S316;
    if((_S315.z) != 0U)
    {
        _S316 = true;
    }
    else
    {
        _S316 = (_S314.w) <= 0.0f;
    }
    if(_S316)
    {
        return;
    }
    float4 _S317 = float4(*(kernelContext_27->scratch_0+(at_3 + 1U))) ;
    float4 _S318 = float4(*(kernelContext_27->scratch_0+(at_3 + 2U))) ;
    float4 _S319 = float4(*(kernelContext_27->scratch_0+(at_3 + 3U))) ;
    float3 moved_1 = (float4(_S313->position_1) ).xyz - _S314.xyz + ((float4(_S313->position_err_1) ).xyz - _S317.xyz);
    float3 _S320 = float3((kernelContext_27->params_0->t_hi_0 - _S319.w + (kernelContext_27->params_0->t_lo_0 - _S317.w) + float(_S315.w - kernelContext_27->params_0->step_start_0) * kernelContext_27->params_0->dt_0)) ;
    float3 expected_0 = _S319.xyz * _S320 + float3(0.5f)  * kernelContext_27->params_0->gravity_0.xyz * _S320 * _S320;
    Quat_0 _S321 = quat_of_0(float4(_S313->rotation_1) );
    thread Quat_0 _S322 = quat_of_0(float4(- _S318.xyz, _S318.w));
    thread Quat_0 _S323 = _S321;
    Quat_0 _S324 = quat_mul_0(&_S322, &_S323);
    if((length(moved_1 - expected_0) + 2.0f * atan2(length(float3(_S324.x_2, _S324.y_1, _S324.z_0)), abs(_S324.w_1)) * (float4(_S313->half_1) ).w) > (_S314.w))
    {
        (kernelContext_27->islands_0+kernelContext_27->params_0->halt_index_0)->info_0[int(2)] = ((uint4((kernelContext_27->islands_0+kernelContext_27->params_0->halt_index_0)->info_0) ).z) | 1U;
        sentinel_mark_0(1048576U, kernelContext_27);
    }
    return;
}

[[kernel]] void contact_forces(uint3 id_0 [[thread_position_in_grid]], Params_0 constant* params_1 [[buffer(0)]], Island_natural_0 device* islands_1 [[buffer(9)]], uint device* index_1 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_1 [[buffer(3)]], packed_float4 device* state_1 [[buffer(6)]], packed_float4 device* scratch_1 [[buffer(8)]], packed_float4 device* contact_state_1 [[buffer(11)]], packed_float4 device* loads_1 [[buffer(5)]], Impactor_natural_0 device* impactors_1 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_1 [[buffer(7)]], BondStatic_natural_0 device* bonds_1 [[buffer(2)]], MaterialTable_0 constant* materials_1 [[buffer(1)]])
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
    (&kernelContext_28)->bond_dyn_0 = bond_dyn_1;
    (&kernelContext_28)->bonds_0 = bonds_1;
    (&kernelContext_28)->materials_0 = materials_1;
    threadgroup array<float4, int(32)> g_part_a_1;
    (&kernelContext_28)->g_part_a_0 = &g_part_a_1;
    threadgroup array<float4, int(32)> g_part_b_1;
    (&kernelContext_28)->g_part_b_0 = &g_part_b_1;
    threadgroup array<uint, int(5)> g_seen_1;
    (&kernelContext_28)->g_seen_0 = &g_seen_1;
    threadgroup uint g_wide_run_1;
    (&kernelContext_28)->g_wide_run_0 = &g_wide_run_1;
    threadgroup array<uint, int(4096)> g_label_1;
    (&kernelContext_28)->g_label_0 = &g_label_1;
    threadgroup uint g_changed_1;
    (&kernelContext_28)->g_changed_0 = &g_changed_1;
    threadgroup uint g_halt_1;
    (&kernelContext_28)->g_halt_0 = &g_halt_1;
    threadgroup uint g_run_1;
    (&kernelContext_28)->g_run_0 = &g_run_1;
    threadgroup array<uint, int(512)> g_label_narrow_1;
    (&kernelContext_28)->g_label_narrow_0 = &g_label_narrow_1;
    threadgroup uint g_changed_narrow_1;
    (&kernelContext_28)->g_changed_narrow_0 = &g_changed_narrow_1;
    uint i_4 = id_0.x;
    uint _S325 = pair_lane_count_0(&kernelContext_28);
    uint pair_threads_0 = (&kernelContext_28)->params_0->pair_count_0 * _S325;
    if(i_4 < pair_threads_0)
    {
        bool _S326 = stopped_0(&kernelContext_28);
        bool _S327 = pair_any_0(_S326, _S325);
        if(!_S327)
        {
            uint _S328 = i_4 / _S325;
            uint _S329 = i_4 % _S325;
            pair_contact_0(_S328, _S329, _S325, &kernelContext_28);
        }
        return;
    }
    uint j_4 = i_4 - pair_threads_0;
    uint cand_threads_0 = (&kernelContext_28)->params_0->cand_count_0 * _S325;
    if(j_4 < cand_threads_0)
    {
        bool _S330 = stopped_0(&kernelContext_28);
        bool _S331 = pair_any_0(_S330, _S325);
        if(!_S331)
        {
            uint _S332 = j_4 / _S325;
            uint _S333 = j_4 % _S325;
            impactor_candidate_forces_0(_S332, _S333, _S325, &kernelContext_28);
        }
        return;
    }
    uint _S334 = j_4 - cand_threads_0;
    bool _S335;
    if(_S334 < ((&kernelContext_28)->params_0->chunk_count_0))
    {
        bool _S336 = stopped_0(&kernelContext_28);
        _S335 = !_S336;
    }
    else
    {
        _S335 = false;
    }
    if(_S335)
    {
        travel_check_0(_S334, &kernelContext_28);
    }
    else
    {
        if((_S334 - (&kernelContext_28)->params_0->chunk_count_0) < ((&kernelContext_28)->params_0->impactor_count_0))
        {
            bool _S337 = stopped_0(&kernelContext_28);
            _S335 = !_S337;
        }
        else
        {
            _S335 = false;
        }
        if(_S335)
        {
            impactor_travel_check_0(_S334 - (&kernelContext_28)->params_0->chunk_count_0, &kernelContext_28);
        }
    }
    return;
}

uint impactor_contact_count_0(uint _S338, float _S339, const Box_0 thread* _S340, const Box_0 thread* _S341, KernelContext_0 thread* kernelContext_29)
{
    thread Impactor_natural_0 _S342 = *(kernelContext_29->impactors_0+_S338);
    uint j_5 = 0U;
    uint count_2 = 0U;
    for(;;)
    {
        uint _S343 = impactor_slots_1(&_S342, _S341);
        if(j_5 < _S343)
        {
        }
        else
        {
            break;
        }
        thread float3 p_9;
        thread float3 n_9;
        thread float d_11;
        bool _S344 = impactor_contact_2(_S338, _S339, _S340, _S341, j_5, &p_9, &n_9, &d_11, kernelContext_29);
        if(_S344)
        {
            count_2 = count_2 + 1U;
        }
        j_5 = j_5 + 1U;
    }
    return count_2;
}

[[kernel]] void impactor_shares(uint3 id_1 [[thread_position_in_grid]], Params_0 constant* params_2 [[buffer(0)]], Island_natural_0 device* islands_2 [[buffer(9)]], uint device* index_2 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_2 [[buffer(3)]], packed_float4 device* state_2 [[buffer(6)]], packed_float4 device* scratch_2 [[buffer(8)]], packed_float4 device* contact_state_2 [[buffer(11)]], packed_float4 device* loads_2 [[buffer(5)]], Impactor_natural_0 device* impactors_2 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_2 [[buffer(7)]], BondStatic_natural_0 device* bonds_2 [[buffer(2)]], MaterialTable_0 constant* materials_2 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_30;
    (&kernelContext_30)->params_0 = params_2;
    (&kernelContext_30)->islands_0 = islands_2;
    (&kernelContext_30)->index_0 = index_2;
    (&kernelContext_30)->chunks_0 = chunks_2;
    (&kernelContext_30)->state_0 = state_2;
    (&kernelContext_30)->scratch_0 = scratch_2;
    (&kernelContext_30)->contact_state_0 = contact_state_2;
    (&kernelContext_30)->loads_0 = loads_2;
    (&kernelContext_30)->impactors_0 = impactors_2;
    (&kernelContext_30)->bond_dyn_0 = bond_dyn_2;
    (&kernelContext_30)->bonds_0 = bonds_2;
    (&kernelContext_30)->materials_0 = materials_2;
    threadgroup array<float4, int(32)> g_part_a_2;
    (&kernelContext_30)->g_part_a_0 = &g_part_a_2;
    threadgroup array<float4, int(32)> g_part_b_2;
    (&kernelContext_30)->g_part_b_0 = &g_part_b_2;
    threadgroup array<uint, int(5)> g_seen_2;
    (&kernelContext_30)->g_seen_0 = &g_seen_2;
    threadgroup uint g_wide_run_2;
    (&kernelContext_30)->g_wide_run_0 = &g_wide_run_2;
    threadgroup array<uint, int(4096)> g_label_2;
    (&kernelContext_30)->g_label_0 = &g_label_2;
    threadgroup uint g_changed_2;
    (&kernelContext_30)->g_changed_0 = &g_changed_2;
    threadgroup uint g_halt_2;
    (&kernelContext_30)->g_halt_0 = &g_halt_2;
    threadgroup uint g_run_2;
    (&kernelContext_30)->g_run_0 = &g_run_2;
    threadgroup array<uint, int(512)> g_label_narrow_2;
    (&kernelContext_30)->g_label_narrow_0 = &g_label_narrow_2;
    threadgroup uint g_changed_narrow_2;
    (&kernelContext_30)->g_changed_narrow_0 = &g_changed_narrow_2;
    uint k_7 = id_1.x;
    bool _S345;
    if(k_7 >= (params_2->cand_count_0))
    {
        _S345 = true;
    }
    else
    {
        bool _S346 = stopped_0(&kernelContext_30);
        _S345 = _S346;
    }
    if(_S345)
    {
        return;
    }
    uint _S347 = 3U * k_7;
    uint at_4 = (&kernelContext_30)->params_0->cand_index_0 + _S347;
    uint c_6 = (&kernelContext_30)->index_0[at_4];
    uint _S348 = (&kernelContext_30)->index_0[at_4 + 2U];
    thread Impactor_natural_0 _S349 = *((&kernelContext_30)->impactors_0+_S348);
    if(((uint4((&_S349)->cand_0) ).z) == 0U)
    {
        _S345 = ((float4((&_S349)->crush_0) ).x) > 0.0f;
    }
    else
    {
        _S345 = false;
    }
    float total_0;
    float ksum_0;
    if(_S345)
    {
        WorldPoint_0 _S350 = chunk_world_0(c_6, &kernelContext_30);
        WorldPoint_0 _S351 = impactor_point_0(_S348, &kernelContext_30);
        thread WorldPoint_0 _S352 = _S350;
        thread WorldPoint_0 _S353 = _S351;
        float3 _S354 = world_diff_0(&_S352, &_S353);
        float4 _S355 = float4((&_S349)->half_1) ;
        if(!((length(_S354)) > (_S355.w + (float4(((&kernelContext_30)->chunks_0+c_6)->half_0) ).w)))
        {
            Box_0 _S356 = impactor_box_1(_S348, float3(0.0f) , _S355.xyz, &kernelContext_30);
            Box_0 _S357 = chunk_box_0(c_6, _S354, &kernelContext_30);
            float _S358 = (float4((&_S349)->mat_0) ).x;
            float _S359 = (float4(((&kernelContext_30)->chunks_0+c_6)->cmat_0) ).x;
            float3 _S360 = _S357.center_1 - _S356.center_1;
            thread Box_0 _S361 = _S356;
            thread Box_0 _S362 = _S357;
            float _S363 = contact_stiffness_0(_S358, &_S361, _S359, &_S362, _S360);
            float _S364 = (float4((&_S349)->crush_0) ).w;
            thread Box_0 _S365 = _S356;
            Box_0 _S366 = impactor_shrunk_0(_S348, _S364, &_S365);
            thread Box_0 _S367 = _S366;
            thread Box_0 _S368 = _S357;
            uint _S369 = impactor_contact_count_0(_S348, _S364, &_S367, &_S368, &kernelContext_30);
            float _S370;
            if(((float4((&_S349)->shape_0) ).x) == 0.0f)
            {
                _S370 = _S363;
            }
            else
            {
                _S370 = _S363 / max(float(_S369), 10.0f);
            }
            uint j_6 = 0U;
            total_0 = 0.0f;
            ksum_0 = 0.0f;
            for(;;)
            {
                if(_S369 > 0U)
                {
                    thread Box_0 _S371 = _S357;
                    uint _S372 = impactor_slots_0(&_S349, &_S371);
                    _S345 = j_6 < _S372;
                }
                else
                {
                    _S345 = false;
                }
                if(_S345)
                {
                }
                else
                {
                    break;
                }
                thread Box_0 _S373 = _S366;
                thread Box_0 _S374 = _S357;
                thread float3 p_10;
                thread float3 nrm_2;
                thread float dep_2;
                bool _S375 = impactor_contact_1(&_S349, _S364, &_S373, &_S374, j_6, &p_10, &nrm_2, &dep_2, &kernelContext_30);
                if(!_S375)
                {
                    j_6 = j_6 + 1U;
                    continue;
                }
                float ksum_1 = ksum_0 + _S370;
                total_0 = total_0 + _S370 * dep_2;
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
    float4 _S376 = float4(*((&kernelContext_30)->scratch_0+((&kernelContext_30)->params_0->cand_base_0 + _S347))) ;
    *((&kernelContext_30)->scratch_0+((&kernelContext_30)->params_0->cand_base_0 + _S347)) = packed_float4(float4(total_0, ksum_0, _S376.z, _S376.w)) ;
    return;
}

[[kernel]] void impactor_crush(uint3 group_0 [[threadgroup_position_in_grid]], uint3 thread_0 [[thread_position_in_threadgroup]], Params_0 constant* params_3 [[buffer(0)]], Island_natural_0 device* islands_3 [[buffer(9)]], uint device* index_3 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_3 [[buffer(3)]], packed_float4 device* state_3 [[buffer(6)]], packed_float4 device* scratch_3 [[buffer(8)]], packed_float4 device* contact_state_3 [[buffer(11)]], packed_float4 device* loads_3 [[buffer(5)]], Impactor_natural_0 device* impactors_3 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_3 [[buffer(7)]], BondStatic_natural_0 device* bonds_3 [[buffer(2)]], MaterialTable_0 constant* materials_3 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_31;
    (&kernelContext_31)->params_0 = params_3;
    (&kernelContext_31)->islands_0 = islands_3;
    (&kernelContext_31)->index_0 = index_3;
    (&kernelContext_31)->chunks_0 = chunks_3;
    (&kernelContext_31)->state_0 = state_3;
    (&kernelContext_31)->scratch_0 = scratch_3;
    (&kernelContext_31)->contact_state_0 = contact_state_3;
    (&kernelContext_31)->loads_0 = loads_3;
    (&kernelContext_31)->impactors_0 = impactors_3;
    (&kernelContext_31)->bond_dyn_0 = bond_dyn_3;
    (&kernelContext_31)->bonds_0 = bonds_3;
    (&kernelContext_31)->materials_0 = materials_3;
    threadgroup array<float4, int(32)> g_part_a_3;
    (&kernelContext_31)->g_part_a_0 = &g_part_a_3;
    threadgroup array<float4, int(32)> g_part_b_3;
    (&kernelContext_31)->g_part_b_0 = &g_part_b_3;
    threadgroup array<uint, int(5)> g_seen_3;
    (&kernelContext_31)->g_seen_0 = &g_seen_3;
    threadgroup uint g_wide_run_3;
    (&kernelContext_31)->g_wide_run_0 = &g_wide_run_3;
    threadgroup array<uint, int(4096)> g_label_3;
    (&kernelContext_31)->g_label_0 = &g_label_3;
    threadgroup uint g_changed_3;
    (&kernelContext_31)->g_changed_0 = &g_changed_3;
    threadgroup uint g_halt_3;
    (&kernelContext_31)->g_halt_0 = &g_halt_3;
    threadgroup uint g_run_3;
    (&kernelContext_31)->g_run_0 = &g_run_3;
    threadgroup array<uint, int(512)> g_label_narrow_3;
    (&kernelContext_31)->g_label_narrow_0 = &g_label_narrow_3;
    threadgroup uint g_changed_narrow_3;
    (&kernelContext_31)->g_changed_narrow_0 = &g_changed_narrow_3;
    uint ii_1 = group_0.x;
    uint tid_2 = thread_0.x;
    bool _S377;
    if(ii_1 >= (params_3->impactor_count_0))
    {
        _S377 = true;
    }
    else
    {
        bool _S378 = stopped_0(&kernelContext_31);
        _S377 = _S378;
    }
    if(_S377)
    {
        return;
    }
    Impactor_natural_0 device* _S379 = (&kernelContext_31)->impactors_0+ii_1;
    float4 _S380 = float4((*_S379).position_err_1) ;
    float4 _S381 = float4((*_S379).velocity_1) ;
    float4 _S382 = float4((*_S379).velocity_err_1) ;
    float4 _S383 = float4((*_S379).angular_velocity_1) ;
    float4 _S384 = float4((*_S379).rotation_1) ;
    float4 _S385 = float4((*_S379).inertia0_2) ;
    float4 _S386 = float4((*_S379).inertia1_2) ;
    float4 _S387 = float4((*_S379).inertia2_2) ;
    float4 _S388 = float4((*_S379).inv0_2) ;
    float4 _S389 = float4((*_S379).inv1_2) ;
    float4 _S390 = float4((*_S379).inv2_2) ;
    float4 _S391 = float4((*_S379).shape_0) ;
    float4 _S392 = float4((*_S379).half_1) ;
    float4 _S393 = float4((*_S379).mat_0) ;
    float4 _S394 = float4((*_S379).crush_0) ;
    float4 _S395 = float4((*_S379).geom_0) ;
    float4 _S396 = float4((*_S379).rotation_err_1) ;
    float4 _S397 = float4((*_S379).ledger_0) ;
    uint4 _S398 = uint4((*_S379).cand_0) ;
    float4 _S399 = float4((*_S379).momentum_1) ;
    float4 _S400 = float4((*_S379).momentum_err_1) ;
    thread Impactor_0 imp_5;
    (&imp_5)->position_1 = float4((*_S379).position_1) ;
    (&imp_5)->position_err_1 = _S380;
    (&imp_5)->velocity_1 = _S381;
    (&imp_5)->velocity_err_1 = _S382;
    (&imp_5)->angular_velocity_1 = _S383;
    (&imp_5)->rotation_1 = _S384;
    (&imp_5)->inertia0_2 = _S385;
    (&imp_5)->inertia1_2 = _S386;
    (&imp_5)->inertia2_2 = _S387;
    (&imp_5)->inv0_2 = _S388;
    (&imp_5)->inv1_2 = _S389;
    (&imp_5)->inv2_2 = _S390;
    (&imp_5)->shape_0 = _S391;
    (&imp_5)->half_1 = _S392;
    (&imp_5)->mat_0 = _S393;
    (&imp_5)->crush_0 = _S394;
    (&imp_5)->geom_0 = _S395;
    (&imp_5)->rotation_err_1 = _S396;
    (&imp_5)->ledger_0 = _S397;
    (&imp_5)->cand_0 = _S398;
    (&imp_5)->momentum_1 = _S399;
    (&imp_5)->momentum_err_1 = _S400;
    float4 _S401 = float4(0.0f) ;
    thread float4 shares_0 = _S401;
    thread float4 unused_0 = _S401;
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
        shares_0 = shares_0 + float4(*((&kernelContext_31)->scratch_0+((&kernelContext_31)->params_0->cand_base_0 + 3U * k_8))) ;
        k_8 = k_8 + 256U;
    }
    group_sum2_0(tid_2, &shares_0, &unused_0, &kernelContext_31);
    if(tid_2 != 0U)
    {
        _S377 = true;
    }
    else
    {
        _S377 = ((&imp_5)->cand_0.z) != 0U;
    }
    if(_S377)
    {
        return;
    }
    (&imp_5)->geom_0 = float4(1.0f, (&imp_5)->crush_0.w, 0.0f, 0.0f);
    float total_1 = shares_0.x;
    if(((&imp_5)->crush_0.x) > 0.0f)
    {
        _S377 = ((&imp_5)->crush_0.z) < ((&imp_5)->crush_0.y);
    }
    else
    {
        _S377 = false;
    }
    if(_S377)
    {
        _S377 = total_1 > ((&imp_5)->crush_0.x);
    }
    else
    {
        _S377 = false;
    }
    if(_S377)
    {
        float extra_0 = (total_1 - (&imp_5)->crush_0.x) / shares_0.y;
        (&imp_5)->crush_0.w = (&imp_5)->crush_0.w + extra_0;
        (&imp_5)->crush_0.z = (&imp_5)->crush_0.z + (&imp_5)->crush_0.x * extra_0;
        float _S402 = (&imp_5)->crush_0.x * extra_0;
        thread float _S403 = (&imp_5)->ledger_0.z;
        thread float _S404 = (&imp_5)->ledger_0.w;
        comp_add1_0(&_S403, &_S404, _S402);
        (&imp_5)->ledger_0.w = _S404;
        (&imp_5)->ledger_0.z = _S403;
        float _S405 = (&imp_5)->crush_0.x * extra_0;
        thread float _S406 = (&imp_5)->ledger_0.x;
        thread float _S407 = (&imp_5)->ledger_0.y;
        comp_add1_0(&_S406, &_S407, _S405);
        (&imp_5)->ledger_0.y = _S407;
        (&imp_5)->ledger_0.x = _S406;
        (&imp_5)->geom_0.x = (&imp_5)->crush_0.x / total_1;
    }
    Impactor_natural_0 device* _S408 = (&kernelContext_31)->impactors_0+ii_1;
    _S408->position_1 = packed_float4(imp_5.position_1) ;
    _S408->position_err_1 = packed_float4(imp_5.position_err_1) ;
    _S408->velocity_1 = packed_float4(imp_5.velocity_1) ;
    _S408->velocity_err_1 = packed_float4(imp_5.velocity_err_1) ;
    _S408->angular_velocity_1 = packed_float4(imp_5.angular_velocity_1) ;
    _S408->rotation_1 = packed_float4(imp_5.rotation_1) ;
    _S408->inertia0_2 = packed_float4(imp_5.inertia0_2) ;
    _S408->inertia1_2 = packed_float4(imp_5.inertia1_2) ;
    _S408->inertia2_2 = packed_float4(imp_5.inertia2_2) ;
    _S408->inv0_2 = packed_float4(imp_5.inv0_2) ;
    _S408->inv1_2 = packed_float4(imp_5.inv1_2) ;
    _S408->inv2_2 = packed_float4(imp_5.inv2_2) ;
    _S408->shape_0 = packed_float4(imp_5.shape_0) ;
    _S408->half_1 = packed_float4(imp_5.half_1) ;
    _S408->mat_0 = packed_float4(imp_5.mat_0) ;
    _S408->crush_0 = packed_float4(imp_5.crush_0) ;
    _S408->geom_0 = packed_float4(imp_5.geom_0) ;
    _S408->rotation_err_1 = packed_float4(imp_5.rotation_err_1) ;
    _S408->ledger_0 = packed_float4(imp_5.ledger_0) ;
    _S408->cand_0 = packed_uint4(imp_5.cand_0) ;
    _S408->momentum_1 = packed_float4(imp_5.momentum_1) ;
    _S408->momentum_err_1 = packed_float4(imp_5.momentum_err_1) ;
    return;
}

struct WideGroup_0
{
    uint island_3;
    uint begin_0;
    uint end_0;
    uint first_0;
};

WideGroup_0 wide_group_0(uint table_0, uint g_0, KernelContext_0 thread* kernelContext_32)
{
    thread WideGroup_0 w_4;
    uint _S409 = table_0 + 4U * g_0;
    (&w_4)->island_3 = kernelContext_32->index_0[_S409];
    (&w_4)->begin_0 = kernelContext_32->index_0[_S409 + 1U];
    (&w_4)->end_0 = kernelContext_32->index_0[_S409 + 2U];
    (&w_4)->first_0 = kernelContext_32->index_0[_S409 + 3U];
    return w_4;
}

void seen_clear_0(uint tid_3, KernelContext_0 thread* kernelContext_33)
{
    if(tid_3 < 5U)
    {
        (*kernelContext_33->g_seen_0)[tid_3] = 0U;
    }
    return;
}

bool contact_stopped_0(const Island_natural_0 thread* isl_0, KernelContext_0 thread* kernelContext_34)
{
    uint4 _S410 = uint4((kernelContext_34->islands_0+kernelContext_34->params_0->halt_index_0)->info_0) ;
    bool _S411;
    if(((_S410.z) & 1U) != 0U)
    {
        _S411 = true;
    }
    else
    {
        uint _S412 = _S410.y;
        if(_S412 != 0U)
        {
            _S411 = _S412 <= ((uint4(isl_0->info_0) ).w);
        }
        else
        {
            _S411 = false;
        }
    }
    return _S411;
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

bool contact_stopped_1(const Island_0 thread* isl_1, KernelContext_0 thread* kernelContext_35)
{
    uint4 _S413 = uint4((kernelContext_35->islands_0+kernelContext_35->params_0->halt_index_0)->info_0) ;
    bool _S414;
    if(((_S413.z) & 1U) != 0U)
    {
        _S414 = true;
    }
    else
    {
        uint _S415 = _S413.y;
        if(_S415 != 0U)
        {
            _S414 = _S415 <= (isl_1->info_0.w);
        }
        else
        {
            _S414 = false;
        }
    }
    return _S414;
}

bool wide_runs_0(const Island_natural_0 thread* isl_2, KernelContext_0 thread* kernelContext_36)
{
    uint4 _S416 = uint4(isl_2->info_0) ;
    bool _S417;
    if(((_S416.z) & 1U) != 0U)
    {
        _S417 = true;
    }
    else
    {
        _S417 = (_S416.y) == 0U;
    }
    if(_S417)
    {
        return false;
    }
    if(((_S416.x) & 4U) == 0U)
    {
        _S417 = true;
    }
    else
    {
        bool _S418 = contact_stopped_0(isl_2, kernelContext_36);
        _S417 = !_S418;
    }
    return _S417;
}

bool wide_enter_0(uint tid_4, const Island_natural_0 thread* isl_3, KernelContext_0 thread* kernelContext_37)
{
    seen_clear_0(tid_4, kernelContext_37);
    if(tid_4 == 0U)
    {
        bool _S419 = wide_runs_0(isl_3, kernelContext_37);
        int _S420;
        if(_S419)
        {
            _S420 = int(1);
        }
        else
        {
            _S420 = int(0);
        }
        *kernelContext_37->g_wide_run_0 = uint(_S420);
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    return (*kernelContext_37->g_wide_run_0) != 0U;
}

uint wide_step_0(const Island_natural_0 thread* isl_4, KernelContext_0 thread* kernelContext_38)
{
    return (uint4(isl_4->info_0) ).w - kernelContext_38->params_0->step_start_0;
}

uint wide_step_1(const Island_natural_0 thread* isl_5, KernelContext_0 thread* kernelContext_39)
{
    return (uint4(isl_5->info_0) ).w - kernelContext_39->params_0->step_start_0;
}

uint wide_step_2(const Island_0 thread* isl_6, KernelContext_0 thread* kernelContext_40)
{
    return isl_6->info_0.w - kernelContext_40->params_0->step_start_0;
}

float time_since_0(float4 origin_0, uint k_9, float dt_2, KernelContext_0 thread* kernelContext_41)
{
    return kernelContext_41->params_0->t_hi_0 - origin_0.x + (kernelContext_41->params_0->t_lo_0 - origin_0.y) + float(k_9) * dt_2;
}

float table_eval_0(uint offset_0, uint count_3, float tau_0, KernelContext_0 thread* kernelContext_42)
{
    float4 _S421 = float4(*(kernelContext_42->loads_0+offset_0)) ;
    if(tau_0 <= (_S421.x))
    {
        return _S421.y;
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
        uint _S422 = offset_0 + i_5;
        float4 _S423 = float4(*(kernelContext_42->loads_0+_S422)) ;
        float _S424 = _S423.x;
        if(tau_0 <= _S424)
        {
            float4 _S425 = float4(*(kernelContext_42->loads_0+(_S422 - 1U))) ;
            float _S426 = _S425.x;
            float _S427 = _S425.y;
            return _S427 + (tau_0 - _S426) / max(_S424 - _S426, 1.00000000317107685e-30f) * (_S423.y - _S427);
        }
        i_5 = i_5 + 1U;
    }
    return (float4(*(kernelContext_42->loads_0+(offset_0 + count_3 - 1U))) ).y;
}

float eval_function_0(uint term_0, uint k_10, float dt_3, float shift_0, KernelContext_0 thread* kernelContext_43)
{
    uint _S428 = 5U * term_0;
    uint4 info_2 = (as_type<uint4>((float4(*(kernelContext_43->loads_0+_S428)) )));
    float4 _S429 = float4(*(kernelContext_43->loads_0+(_S428 + 3U))) ;
    float4 _S430 = float4(*(kernelContext_43->loads_0+(_S428 + 4U))) ;
    uint kind_0 = info_2.z;
    if(kind_0 == 0U)
    {
        return _S429.z;
    }
    float _S431 = time_since_0(_S429, k_10, dt_3, kernelContext_43);
    float tau_1 = _S431 + shift_0;
    float shape_1;
    if(kind_0 == 1U)
    {
        if(tau_1 <= 0.0f)
        {
            shape_1 = 0.0f;
        }
        else
        {
            float _S432 = _S430.x;
            if(tau_1 >= _S432)
            {
                shape_1 = _S430.y;
            }
            else
            {
                shape_1 = _S430.y * tau_1 / _S432;
            }
        }
        return shape_1;
    }
    bool _S433;
    if(kind_0 == 2U)
    {
        if(tau_1 < 0.0f)
        {
            _S433 = true;
        }
        else
        {
            _S433 = tau_1 > (_S430.x);
        }
        if(_S433)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S430.y * sin(3.14159274101257324f * tau_1 / _S430.x);
        }
        return shape_1;
    }
    if(kind_0 == 3U)
    {
        float sn_0 = tau_1 / _S430.y;
        if(sn_0 < 0.0f)
        {
            _S433 = true;
        }
        else
        {
            _S433 = sn_0 > 1.0f;
        }
        if(_S433)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S430.x * (1.0f - sn_0) * exp(- _S430.z * sn_0);
        }
        return shape_1;
    }
    if(kind_0 == 4U)
    {
        float _S434 = table_eval_0(info_2.w, (as_type<uint>((_S430.x))), tau_1, kernelContext_43);
        return _S434;
    }
    if(kind_0 == 5U)
    {
        (*kernelContext_43->g_seen_0)[1U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float sn_1 = tau_1 / _S430.x;
        if(sn_1 < 0.0f)
        {
            _S433 = true;
        }
        else
        {
            _S433 = sn_1 > 1.0f;
        }
        if(_S433)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = (1.0f - sn_1) * exp(- _S430.y * sn_1);
        }
        float clearing_0 = _S429.w;
        float relax_0;
        if(clearing_0 > 0.0f)
        {
            relax_0 = max(1.0f - tau_1 / clearing_0, 0.0f);
        }
        else
        {
            relax_0 = 0.0f;
        }
        float _S435 = _S430.w;
        return (_S435 + (_S430.z - _S435) * relax_0) * shape_1;
    }
    if(kind_0 == 7U)
    {
        (*kernelContext_43->g_seen_0)[2U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float _S436 = _S430.y;
        if(tau_1 < _S436)
        {
            return _S430.x;
        }
        float s_1 = tau_1 - _S436;
        float _S437 = _S430.w;
        if(s_1 > _S437)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S430.z * sin(3.14159274101257324f * s_1 / _S437);
        }
        return shape_1;
    }
    float _S438 = _S430.x;
    if(_S438 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp(1.0f - tau_1 / _S438, 0.0f, 1.0f);
}

void record_chunk_load_0(uint c_7, float3 f_1, float3 t_3, KernelContext_0 thread* kernelContext_44)
{
    if((kernelContext_44->params_0->solve_mode_0) == 0U)
    {
        return;
    }
    uint _S439 = 2U * c_7;
    *(kernelContext_44->scratch_0+(kernelContext_44->params_0->cload_base_0 + _S439)) = packed_float4(float4(f_1, 0.0f)) ;
    *(kernelContext_44->scratch_0+(kernelContext_44->params_0->cload_base_0 + _S439 + 1U)) = packed_float4(float4(t_3, 0.0f)) ;
    *(kernelContext_44->scratch_0+(kernelContext_44->params_0->cframe_base_0 + _S439)) = packed_float4(float4((float4(*(kernelContext_44->scratch_0+(kernelContext_44->params_0->cframe_base_0 + _S439))) ).xyz + f_1, 0.0f)) ;
    *(kernelContext_44->scratch_0+(kernelContext_44->params_0->cframe_base_0 + _S439 + 1U)) = packed_float4(float4((float4(*(kernelContext_44->scratch_0+(kernelContext_44->params_0->cframe_base_0 + _S439 + 1U))) ).xyz + t_3, 0.0f)) ;
    return;
}

void chunk_loads_0(uint _S440, uint _S441, const Quat_0 thread* _S442, uint _S443, float _S444, bool _S445, float _S446, float3 thread* _S447, float3 thread* _S448, float3 thread* _S449, float3 thread* _S450, KernelContext_0 thread* kernelContext_45)
{
    bool _S451;
    ChunkStatic_natural_0 device* _S452 = kernelContext_45->chunks_0+_S441;
    float3 _S453 = float3(0.0f) ;
    *_S447 = _S453;
    *_S448 = _S453;
    *_S449 = _S453;
    *_S450 = _S453;
    uint4 _S454 = uint4(_S452->load_range_0) ;
    uint term_1 = _S454.x;
    for(;;)
    {
        if(term_1 < (_S454.y))
        {
        }
        else
        {
            break;
        }
        (*kernelContext_45->g_seen_0)[0U] = 1U;
        uint _S455 = 5U * term_1;
        uint _S456 = (as_type<uint4>((float4(*(kernelContext_45->loads_0+_S455)) ))).y;
        bool replacement_0 = _S456 == 2U;
        float4 _S457 = float4(*(kernelContext_45->loads_0+(_S455 + 1U))) ;
        float4 _S458 = float4(*(kernelContext_45->loads_0+(_S455 + 2U))) ;
        float _S459;
        if(replacement_0)
        {
            _S459 = _S446;
        }
        else
        {
            _S459 = 0.0f;
        }
        float _S460 = eval_function_0(term_1, _S443, _S444, _S459, kernelContext_45);
        if(replacement_0)
        {
            float3 _S461 = float3(_S460) ;
            *_S449 = *_S449 + _S457.xyz * _S461;
            *_S450 = *_S450 + _S458.xyz * _S461;
            term_1 = term_1 + 1U;
            continue;
        }
        if(_S456 == 0U)
        {
            _S451 = true;
        }
        else
        {
            _S451 = _S456 == 3U;
        }
        float3 fw_0;
        if(_S451)
        {
            fw_0 = _S457.xyz * float3(_S460) ;
        }
        else
        {
            float3 _S462 = rotate_0(_S442, _S457.xyz);
            fw_0 = _S462 * float3((- _S460 * _S457.w)) ;
        }
        float3 lever_0;
        if(_S456 == 3U)
        {
            lever_0 = _S458.xyz - (float4(*(kernelContext_45->state_0+4U * _S440)) ).xyz;
        }
        else
        {
            lever_0 = _S458.xyz;
        }
        *_S447 = *_S447 + fw_0;
        float3 _S463 = rotate_0(_S442, lever_0);
        *_S448 = *_S448 + cross(_S463, fw_0);
        term_1 = term_1 + 1U;
    }
    if(_S445)
    {
        _S451 = ((uint4(_S452->cinfo_0) ).z) != 0U;
    }
    else
    {
        _S451 = false;
    }
    if(_S451)
    {
        uint4 _S464 = uint4(_S452->cinfo_0) ;
        uint g_1 = _S464.x;
        for(;;)
        {
            if(g_1 < (_S464.y))
            {
            }
            else
            {
                break;
            }
            uint _S465 = 2U * g_1;
            *_S447 = *_S447 + (float4(*(kernelContext_45->scratch_0+(kernelContext_45->params_0->seg_base_0 + _S465))) ).xyz;
            *_S448 = *_S448 + (float4(*(kernelContext_45->scratch_0+(kernelContext_45->params_0->seg_base_0 + _S465 + 1U))) ).xyz;
            g_1 = g_1 + 1U;
        }
    }
    return;
}

void chunk_external_0(uint _S466, uint _S467, const Quat_0 thread* _S468, uint _S469, float _S470, bool _S471, float3 thread* _S472, float3 thread* _S473, KernelContext_0 thread* kernelContext_46)
{
    thread float3 rf_0;
    thread float3 rm_0;
    chunk_loads_0(_S466, _S467, _S468, _S469, _S470, _S471, 0.0f, _S472, _S473, &rf_0, &rm_0, kernelContext_46);
    return;
}

float settled_chunk_load_0(uint c_8, const Quat_0 thread* rot_0, uint k_11, float dt_4, bool contact_0, KernelContext_0 thread* kernelContext_47)
{
    thread float3 f_2;
    thread float3 t_4;
    chunk_external_0(c_8, c_8, rot_0, k_11, dt_4, contact_0, &f_2, &t_4, kernelContext_47);
    record_chunk_load_0(c_8, f_2, t_4, kernelContext_47);
    return length(f_2);
}

uint seen_bits_0(KernelContext_0 thread* kernelContext_48)
{
    uint _S474;
    if(((*kernelContext_48->g_seen_0)[0U]) != 0U)
    {
        _S474 = 32768U;
    }
    else
    {
        _S474 = 0U;
    }
    uint _S475;
    if(((*kernelContext_48->g_seen_0)[1U]) != 0U)
    {
        _S475 = 65536U;
    }
    else
    {
        _S475 = 0U;
    }
    uint _S476 = _S474 | _S475;
    if(((*kernelContext_48->g_seen_0)[2U]) != 0U)
    {
        _S474 = 131072U;
    }
    else
    {
        _S474 = 0U;
    }
    uint _S477 = _S476 | _S474;
    if(((*kernelContext_48->g_seen_0)[3U]) != 0U)
    {
        _S474 = 32U;
    }
    else
    {
        _S474 = 0U;
    }
    uint _S478 = _S477 | _S474;
    if(((*kernelContext_48->g_seen_0)[4U]) != 0U)
    {
        _S474 = 64U;
    }
    else
    {
        _S474 = 0U;
    }
    return _S478 | _S474;
}

bool wide_enter_1(uint _S479, uint _S480, KernelContext_0 thread* kernelContext_49)
{
    thread Island_natural_0 _S481 = *(kernelContext_49->islands_0+_S480);
    seen_clear_0(_S479, kernelContext_49);
    if(_S479 == 0U)
    {
        bool _S482 = wide_runs_0(&_S481, kernelContext_49);
        int _S483;
        if(_S482)
        {
            _S483 = int(1);
        }
        else
        {
            _S483 = int(0);
        }
        *kernelContext_49->g_wide_run_0 = uint(_S483);
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    return (*kernelContext_49->g_wide_run_0) != 0U;
}

[[kernel]] void wide_wake(uint3 group_1 [[threadgroup_position_in_grid]], uint3 thread_1 [[thread_position_in_threadgroup]], Params_0 constant* params_4 [[buffer(0)]], Island_natural_0 device* islands_4 [[buffer(9)]], uint device* index_4 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_4 [[buffer(3)]], packed_float4 device* state_4 [[buffer(6)]], packed_float4 device* scratch_4 [[buffer(8)]], packed_float4 device* contact_state_4 [[buffer(11)]], packed_float4 device* loads_4 [[buffer(5)]], Impactor_natural_0 device* impactors_4 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_4 [[buffer(7)]], BondStatic_natural_0 device* bonds_4 [[buffer(2)]], MaterialTable_0 constant* materials_4 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_50;
    (&kernelContext_50)->params_0 = params_4;
    (&kernelContext_50)->islands_0 = islands_4;
    (&kernelContext_50)->index_0 = index_4;
    (&kernelContext_50)->chunks_0 = chunks_4;
    (&kernelContext_50)->state_0 = state_4;
    (&kernelContext_50)->scratch_0 = scratch_4;
    (&kernelContext_50)->contact_state_0 = contact_state_4;
    (&kernelContext_50)->loads_0 = loads_4;
    (&kernelContext_50)->impactors_0 = impactors_4;
    (&kernelContext_50)->bond_dyn_0 = bond_dyn_4;
    (&kernelContext_50)->bonds_0 = bonds_4;
    (&kernelContext_50)->materials_0 = materials_4;
    threadgroup array<float4, int(32)> g_part_a_4;
    (&kernelContext_50)->g_part_a_0 = &g_part_a_4;
    threadgroup array<float4, int(32)> g_part_b_4;
    (&kernelContext_50)->g_part_b_0 = &g_part_b_4;
    threadgroup array<uint, int(5)> g_seen_4;
    (&kernelContext_50)->g_seen_0 = &g_seen_4;
    threadgroup uint g_wide_run_4;
    (&kernelContext_50)->g_wide_run_0 = &g_wide_run_4;
    threadgroup array<uint, int(4096)> g_label_4;
    (&kernelContext_50)->g_label_0 = &g_label_4;
    threadgroup uint g_changed_4;
    (&kernelContext_50)->g_changed_0 = &g_changed_4;
    threadgroup uint g_halt_4;
    (&kernelContext_50)->g_halt_0 = &g_halt_4;
    threadgroup uint g_run_4;
    (&kernelContext_50)->g_run_0 = &g_run_4;
    threadgroup array<uint, int(512)> g_label_narrow_4;
    (&kernelContext_50)->g_label_narrow_0 = &g_label_narrow_4;
    threadgroup uint g_changed_narrow_4;
    (&kernelContext_50)->g_changed_narrow_0 = &g_changed_narrow_4;
    uint tid_5 = thread_1.x;
    uint _S484 = group_1.x;
    WideGroup_0 _S485 = wide_group_0(params_4->wide_chunk_table_0, _S484, &kernelContext_50);
    if(_S484 != (_S485.first_0))
    {
        return;
    }
    thread Island_natural_0 _S486 = *((&kernelContext_50)->islands_0+_S485.island_3);
    uint4 _S487 = uint4((&_S486)->info_0) ;
    uint _S488 = _S487.x;
    bool _S489;
    if((_S488 & 16U) == 0U)
    {
        _S489 = true;
    }
    else
    {
        bool _S490 = wide_enter_1(tid_5, _S485.island_3, &kernelContext_50);
        _S489 = !_S490;
    }
    if(_S489)
    {
        return;
    }
    Quat_0 _S491 = quat_of_0(float4((&_S486)->rotation_0) );
    bool _S492 = (_S488 & 4U) != 0U;
    float3 _S493 = float3(0.0f) ;
    thread float3 norm_0 = _S493;
    thread float3 unused_1 = _S493;
    uint4 _S494 = uint4((&_S486)->range_0) ;
    uint c_9 = _S494.x + tid_5;
    for(;;)
    {
        if(c_9 < (_S494.y))
        {
        }
        else
        {
            break;
        }
        uint _S495 = wide_step_0(&_S486, &kernelContext_50);
        float _S496 = (&kernelContext_50)->params_0->dt_0;
        thread Quat_0 _S497 = _S491;
        float _S498 = settled_chunk_load_0(c_9, &_S497, _S495, _S496, _S492, &kernelContext_50);
        norm_0.x = norm_0.x + _S498;
        c_9 = c_9 + 256U;
    }
    group_sum3_0(tid_5, &norm_0, &unused_1, &kernelContext_50);
    if(tid_5 != 0U)
    {
        return;
    }
    uint _S499 = seen_bits_0(&kernelContext_50);
    uint cov_0 = 1024U | _S499;
    if(((&kernelContext_50)->params_0->solve_mode_0) == 1U)
    {
        float4 _S500 = float4((&_S486)->energy_0) ;
        _S489 = (abs(norm_0.x - _S500.z)) > (_S500.w);
    }
    else
    {
        _S489 = false;
    }
    uint cov_1;
    if(_S489)
    {
        ((&kernelContext_50)->islands_0+_S485.island_3)->info_0[int(0)] = _S488 & 4294967279U;
        ((&kernelContext_50)->islands_0+_S485.island_3)->info_0[int(2)] = (_S487.z) | 4U;
        cov_1 = cov_0 | 2048U;
    }
    else
    {
        cov_1 = cov_0;
    }
    cov_mark_0(_S485.island_3, (&_S486)->coverage_0, cov_1, &kernelContext_50);
    return;
}

void wide_partials_0(uint tid_6, uint first_1, uint count_4, uint p_11, float3 thread* a_7, float3 thread* b_23, KernelContext_0 thread* kernelContext_51)
{
    float4 _S501 = float4(0.0f) ;
    thread float4 x_8 = _S501;
    thread float4 y_2 = _S501;
    uint s_2 = tid_6;
    for(;;)
    {
        if(s_2 < count_4)
        {
        }
        else
        {
            break;
        }
        uint _S502 = 8U * (first_1 + s_2);
        x_8 = x_8 + float4(*(kernelContext_51->scratch_0+(kernelContext_51->params_0->wide_base_0 + _S502 + p_11))) ;
        y_2 = y_2 + float4(*(kernelContext_51->scratch_0+(kernelContext_51->params_0->wide_base_0 + _S502 + p_11 + 1U))) ;
        s_2 = s_2 + 256U;
    }
    group_sum2_0(tid_6, &x_8, &y_2, kernelContext_51);
    *a_7 = x_8.xyz;
    *b_23 = y_2.xyz;
    return;
}

float3 rows_mul_0(float4 r0_0, float4 r1_0, float4 r2_0, float3 v_5)
{
    return float3(dot(r0_0.xyz, v_5), dot(r1_0.xyz, v_5), dot(r2_0.xyz, v_5));
}

void drift_angular_0(uint c_10, float3 wcom_1, float3 tr_0, float3 dv_0, float3 thread* lu_0, float3 thread* lv_0, KernelContext_0 thread* kernelContext_52)
{
    ChunkStatic_natural_0 device* _S503 = kernelContext_52->chunks_0+c_10;
    float4 _S504 = float4(_S503->center_0) ;
    float3 r_6 = _S504.xyz - wcom_1;
    uint _S505 = 4U * c_10;
    float3 _S506 = float3(_S504.w) ;
    float4 _S507 = float4(_S503->inertia0_1) ;
    float4 _S508 = float4(_S503->inertia1_1) ;
    float4 _S509 = float4(_S503->inertia2_1) ;
    float3 _S510 = float3((float4(_S503->scale_0) ).x) ;
    *lu_0 = *lu_0 + (cross(r_6, (float4(*(kernelContext_52->state_0+_S505)) ).xyz - tr_0) * _S506 + rows_mul_0(_S507, _S508, _S509, (float4(*(kernelContext_52->state_0+(_S505 + 1U))) ).xyz)) * _S510;
    *lv_0 = *lv_0 + (cross(r_6, (float4(*(kernelContext_52->state_0+(_S505 + 2U))) ).xyz - dv_0) * _S506 + rows_mul_0(_S507, _S508, _S509, (float4(*(kernelContext_52->state_0+(_S505 + 3U))) ).xyz)) * _S510;
    return;
}

void wide_store_0(uint slot_1, uint p_12, float3 a_8, float3 b_24, KernelContext_0 thread* kernelContext_53)
{
    uint _S511 = 8U * slot_1;
    *(kernelContext_53->scratch_0+(kernelContext_53->params_0->wide_base_0 + _S511 + p_12)) = packed_float4(float4(a_8, 0.0f)) ;
    *(kernelContext_53->scratch_0+(kernelContext_53->params_0->wide_base_0 + _S511 + p_12 + 1U)) = packed_float4(float4(b_24, 0.0f)) ;
    return;
}

[[kernel]] void wide_drift(uint3 group_2 [[threadgroup_position_in_grid]], uint3 thread_2 [[thread_position_in_threadgroup]], Params_0 constant* params_5 [[buffer(0)]], Island_natural_0 device* islands_5 [[buffer(9)]], uint device* index_5 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_5 [[buffer(3)]], packed_float4 device* state_5 [[buffer(6)]], packed_float4 device* scratch_5 [[buffer(8)]], packed_float4 device* contact_state_5 [[buffer(11)]], packed_float4 device* loads_5 [[buffer(5)]], Impactor_natural_0 device* impactors_5 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_5 [[buffer(7)]], BondStatic_natural_0 device* bonds_5 [[buffer(2)]], MaterialTable_0 constant* materials_5 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_54;
    (&kernelContext_54)->params_0 = params_5;
    (&kernelContext_54)->islands_0 = islands_5;
    (&kernelContext_54)->index_0 = index_5;
    (&kernelContext_54)->chunks_0 = chunks_5;
    (&kernelContext_54)->state_0 = state_5;
    (&kernelContext_54)->scratch_0 = scratch_5;
    (&kernelContext_54)->contact_state_0 = contact_state_5;
    (&kernelContext_54)->loads_0 = loads_5;
    (&kernelContext_54)->impactors_0 = impactors_5;
    (&kernelContext_54)->bond_dyn_0 = bond_dyn_5;
    (&kernelContext_54)->bonds_0 = bonds_5;
    (&kernelContext_54)->materials_0 = materials_5;
    threadgroup array<float4, int(32)> g_part_a_5;
    (&kernelContext_54)->g_part_a_0 = &g_part_a_5;
    threadgroup array<float4, int(32)> g_part_b_5;
    (&kernelContext_54)->g_part_b_0 = &g_part_b_5;
    threadgroup array<uint, int(5)> g_seen_5;
    (&kernelContext_54)->g_seen_0 = &g_seen_5;
    threadgroup uint g_wide_run_5;
    (&kernelContext_54)->g_wide_run_0 = &g_wide_run_5;
    threadgroup array<uint, int(4096)> g_label_5;
    (&kernelContext_54)->g_label_0 = &g_label_5;
    threadgroup uint g_changed_5;
    (&kernelContext_54)->g_changed_0 = &g_changed_5;
    threadgroup uint g_halt_5;
    (&kernelContext_54)->g_halt_0 = &g_halt_5;
    threadgroup uint g_run_5;
    (&kernelContext_54)->g_run_0 = &g_run_5;
    threadgroup array<uint, int(512)> g_label_narrow_5;
    (&kernelContext_54)->g_label_narrow_0 = &g_label_narrow_5;
    threadgroup uint g_changed_narrow_5;
    (&kernelContext_54)->g_changed_narrow_0 = &g_changed_narrow_5;
    uint tid_7 = thread_2.x;
    uint _S512 = group_2.x;
    WideGroup_0 _S513 = wide_group_0(params_5->wide_chunk_table_0, _S512, &kernelContext_54);
    Island_natural_0 device* _S514 = (&kernelContext_54)->islands_0+_S513.island_3;
    Island_natural_0 isl_7 = *_S514;
    bool _S515;
    if((((uint4((*_S514).info_0) ).x) & 17U) != 0U)
    {
        _S515 = true;
    }
    else
    {
        bool _S516 = wide_enter_1(tid_7, _S513.island_3, &kernelContext_54);
        _S515 = !_S516;
    }
    if(_S515)
    {
        return;
    }
    thread float3 tu_0;
    thread float3 pv_0;
    wide_partials_0(tid_7, _S513.first_0, isl_7.wide_groups_0, 2U, &tu_0, &pv_0, &kernelContext_54);
    float4 _S517 = float4(isl_7.wcom_0) ;
    float3 _S518 = float3(_S517.w) ;
    float3 tr_1 = tu_0 / _S518;
    float3 dv_1 = pv_0 / _S518;
    float3 _S519 = float3(0.0f) ;
    thread float3 lu_1 = _S519;
    thread float3 lv_1 = _S519;
    uint c_11 = _S513.begin_0 + tid_7;
    if(c_11 < (_S513.end_0))
    {
        drift_angular_0(c_11, _S517.xyz, tr_1, dv_1, &lu_1, &lv_1, &kernelContext_54);
    }
    group_sum3_0(tid_7, &lu_1, &lv_1, &kernelContext_54);
    if(tid_7 == 0U)
    {
        wide_store_0(_S512, 4U, lu_1, lv_1, &kernelContext_54);
    }
    return;
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
    float3 a_9;
    float3 alpha_0;
};

Rigid_0 rigid_of_0(const Island_natural_0 thread* isl_8)
{
    thread Rigid_0 rg_0;
    (&rg_0)->rot_1 = quat_of_0(float4(isl_8->rotation_0) );
    (&rg_0)->rot_err_0 = float4(isl_8->rotation_err_0) ;
    (&rg_0)->pos_0 = (float4(isl_8->position_0) ).xyz;
    (&rg_0)->pos_err_0 = (float4(isl_8->position_err_0) ).xyz;
    (&rg_0)->vel_0 = (float4(isl_8->velocity_0) ).xyz;
    (&rg_0)->vel_err_0 = (float4(isl_8->velocity_err_0) ).xyz;
    (&rg_0)->w_5 = (float4(isl_8->angular_velocity_0) ).xyz;
    (&rg_0)->l_1 = (float4(isl_8->momentum_0) ).xyz;
    (&rg_0)->l_err_0 = (float4(isl_8->momentum_err_0) ).xyz;
    float3 _S520 = float3(0.0f) ;
    (&rg_0)->torque_0 = _S520;
    (&rg_0)->a_9 = _S520;
    (&rg_0)->alpha_0 = _S520;
    return rg_0;
}

Rigid_0 rigid_of_1(const Island_0 thread* isl_9)
{
    thread Rigid_0 rg_1;
    (&rg_1)->rot_1 = quat_of_0(isl_9->rotation_0);
    (&rg_1)->rot_err_0 = isl_9->rotation_err_0;
    (&rg_1)->pos_0 = isl_9->position_0.xyz;
    (&rg_1)->pos_err_0 = isl_9->position_err_0.xyz;
    (&rg_1)->vel_0 = isl_9->velocity_0.xyz;
    (&rg_1)->vel_err_0 = isl_9->velocity_err_0.xyz;
    (&rg_1)->w_5 = isl_9->angular_velocity_0.xyz;
    (&rg_1)->l_1 = isl_9->momentum_0.xyz;
    (&rg_1)->l_err_0 = isl_9->momentum_err_0.xyz;
    float3 _S521 = float3(0.0f) ;
    (&rg_1)->torque_0 = _S521;
    (&rg_1)->a_9 = _S521;
    (&rg_1)->alpha_0 = _S521;
    return rg_1;
}

float3 inverse_rotate_0(const Quat_0 thread* q_10, float3 v_6)
{
    thread Quat_0 c_12;
    (&c_12)->w_1 = q_10->w_1;
    (&c_12)->x_2 = - q_10->x_2;
    (&c_12)->y_1 = - q_10->y_1;
    (&c_12)->z_0 = - q_10->z_0;
    thread Quat_0 _S522 = c_12;
    float3 _S523 = rotate_0(&_S522, v_6);
    return _S523;
}

float3 inverse_rotate_1(const Quat_0 thread* q_11, float3 v_7)
{
    thread Quat_0 c_13;
    (&c_13)->w_1 = q_11->w_1;
    (&c_13)->x_2 = - q_11->x_2;
    (&c_13)->y_1 = - q_11->y_1;
    (&c_13)->z_0 = - q_11->z_0;
    thread Quat_0 _S524 = c_13;
    float3 _S525 = rotate_0(&_S524, v_7);
    return _S525;
}

float3 world_mul_0(const Quat_0 thread* q_12, float4 r0_1, float4 r1_1, float4 r2_1, float3 v_8)
{
    float3 _S526 = inverse_rotate_1(q_12, v_8);
    float3 _S527 = rotate_1(q_12, rows_mul_0(r0_1, r1_1, r2_1, _S526));
    return _S527;
}

void rigid_acceleration_0(const Island_natural_0 thread* isl_10, Rigid_0 thread* rg_2, float3 f_3, float3 t_5)
{
    float4 _S528 = float4(isl_10->inertia0_0) ;
    float4 _S529 = float4(isl_10->inertia1_0) ;
    float4 _S530 = float4(isl_10->inertia2_0) ;
    thread Quat_0 _S531 = rg_2->rot_1;
    float3 _S532 = world_mul_0(&_S531, _S528, _S529, _S530, rg_2->w_5);
    rg_2->a_9 = f_3 / float3((float4(isl_10->com_0) ).w) ;
    float4 _S533 = float4(isl_10->inv0_0) ;
    float4 _S534 = float4(isl_10->inv1_0) ;
    float4 _S535 = float4(isl_10->inv2_0) ;
    float3 _S536 = t_5 - cross(rg_2->w_5, _S532);
    thread Quat_0 _S537 = rg_2->rot_1;
    float3 _S538 = world_mul_0(&_S537, _S533, _S534, _S535, _S536);
    rg_2->alpha_0 = _S538;
    rg_2->torque_0 = t_5;
    return;
}

void rigid_acceleration_1(const Island_0 thread* isl_11, Rigid_0 thread* rg_3, float3 f_4, float3 t_6)
{
    thread Quat_0 _S539 = rg_3->rot_1;
    float3 _S540 = world_mul_0(&_S539, isl_11->inertia0_0, isl_11->inertia1_0, isl_11->inertia2_0, rg_3->w_5);
    rg_3->a_9 = f_4 / float3(isl_11->com_0.w) ;
    float3 _S541 = t_6 - cross(rg_3->w_5, _S540);
    thread Quat_0 _S542 = rg_3->rot_1;
    float3 _S543 = world_mul_0(&_S542, isl_11->inv0_0, isl_11->inv1_0, isl_11->inv2_0, _S541);
    rg_3->alpha_0 = _S543;
    rg_3->torque_0 = t_6;
    return;
}

Rigid_0 wide_rigid_frame_0(uint tid_8, const Island_natural_0 thread* isl_12, const WideGroup_0 thread* wg_0, KernelContext_0 thread* kernelContext_55)
{
    Rigid_0 _S544 = rigid_of_0(isl_12);
    thread Rigid_0 rg_4 = _S544;
    if((((uint4(isl_12->info_0) ).x) & 1U) == 0U)
    {
        thread float3 f_5;
        thread float3 t_7;
        wide_partials_0(tid_8, wg_0->first_0, isl_12->wide_groups_0, 0U, &f_5, &t_7, kernelContext_55);
        rigid_acceleration_0(isl_12, &rg_4, f_5, t_7);
    }
    return rg_4;
}

Rigid_0 wide_rigid_frame_1(uint tid_9, const Island_natural_0 thread* isl_13, const WideGroup_0 thread* wg_1, KernelContext_0 thread* kernelContext_56)
{
    Rigid_0 _S545 = rigid_of_0(isl_13);
    thread Rigid_0 rg_5 = _S545;
    if((((uint4(isl_13->info_0) ).x) & 1U) == 0U)
    {
        thread float3 f_6;
        thread float3 t_8;
        wide_partials_0(tid_9, wg_1->first_0, isl_13->wide_groups_0, 0U, &f_6, &t_8, kernelContext_56);
        rigid_acceleration_0(isl_13, &rg_5, f_6, t_8);
    }
    return rg_5;
}

void comp_add_0(float3 thread* sum_1, float3 thread* err_1, float3 x_9)
{
    float3 t_9 = *sum_1 + x_9;
    float3 _S546 = abs(x_9);
    *err_1 = *err_1 + (select(x_9, *sum_1, (abs(*sum_1)) >= _S546) - t_9 + select(*sum_1, x_9, (abs(*sum_1)) >= _S546));
    *sum_1 = t_9;
    return;
}

float3 turn_difference_0(float3 omega_0, float dt_5, float3 v_9)
{
    float _S547 = length(omega_0);
    float angle_1 = _S547 * dt_5;
    if(angle_1 < 1.00000000317107685e-30f)
    {
        return float3(0.0f) ;
    }
    float3 a_10 = omega_0 / float3(_S547) ;
    float s_3 = sin(0.5f * angle_1);
    float3 av_0 = cross(a_10, v_9);
    return av_0 * float3(sin(angle_1))  + cross(a_10, av_0) * float3((2.0f * s_3 * s_3)) ;
}

float4 turn_minus_one_0(float3 axis_5, float angle_2)
{
    float s_4 = sin(0.25f * angle_2);
    return float4(axis_5 * float3(sin(0.5f * angle_2)) , -2.0f * s_4 * s_4);
}

float4 quat_vec_0(const Quat_0 thread* q_13)
{
    return float4(q_13->x_2, q_13->y_1, q_13->z_0, q_13->w_1);
}

void comp_add4_0(float4 thread* sum_2, float4 thread* err_2, float4 x_10)
{
    float4 t_10 = *sum_2 + x_10;
    float4 _S548 = abs(x_10);
    *err_2 = *err_2 + (select(x_10, *sum_2, (abs(*sum_2)) >= _S548) - t_10 + select(*sum_2, x_10, (abs(*sum_2)) >= _S548));
    *sum_2 = t_10;
    return;
}

void quat_accumulate_0(Quat_0 thread* hi_1, float4 thread* lo_1, float4 x_11)
{
    thread Quat_0 _S549 = *hi_1;
    float4 _S550 = quat_vec_0(&_S549);
    thread float4 sum_3 = _S550;
    comp_add4_0(&sum_3, lo_1, x_11);
    float4 t_11 = sum_3 + *lo_1;
    *lo_1 = *lo_1 - (t_11 - sum_3);
    *hi_1 = quat_of_0(t_11);
    return;
}

void turn_left_0(Quat_0 thread* hi_2, float4 thread* lo_2, float3 omega_1, float dt_6)
{
    float _S551 = length(omega_1);
    float angle_3 = _S551 * dt_6;
    if(angle_3 < 1.00000000317107685e-30f)
    {
        return;
    }
    float4 d_12 = turn_minus_one_0(omega_1 / float3(_S551) , angle_3);
    thread Quat_0 dq_0;
    (&dq_0)->x_2 = d_12.x;
    (&dq_0)->y_1 = d_12.y;
    (&dq_0)->z_0 = d_12.z;
    (&dq_0)->w_1 = d_12.w;
    thread Quat_0 _S552 = dq_0;
    thread Quat_0 _S553 = *hi_2;
    Quat_0 _S554 = quat_mul_0(&_S552, &_S553);
    thread Quat_0 _S555 = _S554;
    float4 _S556 = quat_vec_0(&_S555);
    quat_accumulate_0(hi_2, lo_2, _S556);
    return;
}

void integrate_rigid_0(const Island_natural_0 thread* isl_14, Rigid_0 thread* rg_6, float dt_7)
{
    float3 _S557 = float3(dt_7) ;
    comp_add_0(&rg_6->l_1, &rg_6->l_err_0, rg_6->torque_0 * _S557);
    float3 l_2 = rg_6->l_1 + rg_6->l_err_0;
    comp_add_0(&rg_6->vel_0, &rg_6->vel_err_0, rg_6->a_9 * _S557);
    float3 vel_1 = rg_6->vel_0 + rg_6->vel_err_0;
    float4 _S558 = float4(isl_14->inv0_0) ;
    float4 _S559 = float4(isl_14->inv1_0) ;
    float4 _S560 = float4(isl_14->inv2_0) ;
    thread Quat_0 _S561 = rg_6->rot_1;
    float3 _S562 = world_mul_0(&_S561, _S558, _S559, _S560, l_2);
    float3 _S563 = vel_1 * _S557;
    float3 _S564 = (float4(isl_14->com_0) ).xyz;
    thread Quat_0 _S565 = rg_6->rot_1;
    float3 _S566 = rotate_0(&_S565, _S564);
    comp_add_0(&rg_6->pos_0, &rg_6->pos_err_0, _S563 - turn_difference_0(_S562, dt_7, _S566));
    turn_left_0(&rg_6->rot_1, &rg_6->rot_err_0, _S562, dt_7);
    thread Quat_0 _S567 = rg_6->rot_1;
    float3 _S568 = world_mul_0(&_S567, _S558, _S559, _S560, l_2);
    rg_6->w_5 = _S568;
    return;
}

void integrate_rigid_1(const Island_0 thread* isl_15, Rigid_0 thread* rg_7, float dt_8)
{
    float3 _S569 = float3(dt_8) ;
    comp_add_0(&rg_7->l_1, &rg_7->l_err_0, rg_7->torque_0 * _S569);
    float3 l_3 = rg_7->l_1 + rg_7->l_err_0;
    comp_add_0(&rg_7->vel_0, &rg_7->vel_err_0, rg_7->a_9 * _S569);
    float3 vel_2 = rg_7->vel_0 + rg_7->vel_err_0;
    float4 _S570 = isl_15->inv0_0;
    float4 _S571 = isl_15->inv1_0;
    float4 _S572 = isl_15->inv2_0;
    thread Quat_0 _S573 = rg_7->rot_1;
    float3 _S574 = world_mul_0(&_S573, isl_15->inv0_0, isl_15->inv1_0, isl_15->inv2_0, l_3);
    float3 _S575 = vel_2 * _S569;
    float3 _S576 = isl_15->com_0.xyz;
    thread Quat_0 _S577 = rg_7->rot_1;
    float3 _S578 = rotate_0(&_S577, _S576);
    comp_add_0(&rg_7->pos_0, &rg_7->pos_err_0, _S575 - turn_difference_0(_S574, dt_8, _S578));
    turn_left_0(&rg_7->rot_1, &rg_7->rot_err_0, _S574, dt_8);
    thread Quat_0 _S579 = rg_7->rot_1;
    float3 _S580 = world_mul_0(&_S579, _S570, _S571, _S572, l_3);
    rg_7->w_5 = _S580;
    return;
}

void drift_apply_0(uint c_14, float3 wcom_2, float3 tr_2, float3 phi_0, float3 dv_2, float3 dw_0, KernelContext_0 thread* kernelContext_57)
{
    float3 r_7 = (float4((kernelContext_57->chunks_0+c_14)->center_0) ).xyz - wcom_2;
    uint _S581 = 4U * c_14;
    *(kernelContext_57->state_0+_S581) = packed_float4(float4((float4(*(kernelContext_57->state_0+_S581)) ).xyz - (tr_2 + cross(phi_0, r_7)), (float4(*(kernelContext_57->state_0+_S581)) ).w)) ;
    uint _S582 = _S581 + 1U;
    *(kernelContext_57->state_0+_S582) = packed_float4(float4((float4(*(kernelContext_57->state_0+_S582)) ).xyz - phi_0, (float4(*(kernelContext_57->state_0+_S582)) ).w)) ;
    uint _S583 = _S581 + 2U;
    *(kernelContext_57->state_0+_S583) = packed_float4(float4((float4(*(kernelContext_57->state_0+_S583)) ).xyz - (dv_2 + cross(dw_0, r_7)), (float4(*(kernelContext_57->state_0+_S583)) ).w)) ;
    uint _S584 = _S581 + 3U;
    *(kernelContext_57->state_0+_S584) = packed_float4(float4((float4(*(kernelContext_57->state_0+_S584)) ).xyz - dw_0, (float4(*(kernelContext_57->state_0+_S584)) ).w)) ;
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
    thread Quat_0 _S585 = *hi_3;
    thread Quat_0 _S586 = dq_1;
    Quat_0 _S587 = quat_mul_0(&_S585, &_S586);
    thread Quat_0 _S588 = _S587;
    float4 _S589 = quat_vec_0(&_S588);
    quat_accumulate_0(hi_3, lo_3, _S589);
    return;
}

void drift_rigid_0(const Island_natural_0 thread* isl_16, Rigid_0 thread* rg_8, float3 tr_3, float3 phi_2, float3 dv_3, float3 dw_1)
{
    float3 wcom_3 = (float4(isl_16->wcom_0) ).xyz;
    Quat_0 rot_2 = rg_8->rot_1;
    float3 _S590 = tr_3 - cross(phi_2, wcom_3);
    thread Quat_0 _S591 = rg_8->rot_1;
    float3 _S592 = rotate_0(&_S591, _S590);
    comp_add_0(&rg_8->pos_0, &rg_8->pos_err_0, _S592);
    thread Quat_0 _S593 = rg_8->rot_1;
    float3 _S594 = inverse_rotate_0(&_S593, rg_8->w_5);
    float4 _S595 = float4(isl_16->inertia0_0) ;
    float4 _S596 = float4(isl_16->inertia1_0) ;
    float4 _S597 = float4(isl_16->inertia2_0) ;
    float3 _S598 = cross(phi_2, rows_mul_0(_S595, _S596, _S597, _S594)) - rows_mul_0(_S595, _S596, _S597, cross(phi_2, _S594));
    thread Quat_0 _S599 = rg_8->rot_1;
    float3 _S600 = rotate_0(&_S599, _S598);
    turn_right_0(&rg_8->rot_1, &rg_8->rot_err_0, phi_2);
    float3 _S601 = dv_3 + cross(dw_1, (float4(isl_16->com_0) ).xyz - wcom_3);
    thread Quat_0 _S602 = rot_2;
    float3 _S603 = rotate_0(&_S602, _S601);
    comp_add_0(&rg_8->vel_0, &rg_8->vel_err_0, _S603);
    thread Quat_0 _S604 = rot_2;
    float3 _S605 = rotate_0(&_S604, dw_1);
    rg_8->w_5 = rg_8->w_5 + _S605;
    thread Quat_0 _S606 = rg_8->rot_1;
    float3 _S607 = world_mul_0(&_S606, _S595, _S596, _S597, _S605);
    comp_add_0(&rg_8->l_1, &rg_8->l_err_0, _S600 + _S607);
    return;
}

void drift_rigid_1(const Island_0 thread* isl_17, Rigid_0 thread* rg_9, float3 tr_4, float3 phi_3, float3 dv_4, float3 dw_2)
{
    float3 wcom_4 = isl_17->wcom_0.xyz;
    Quat_0 rot_3 = rg_9->rot_1;
    float3 _S608 = tr_4 - cross(phi_3, wcom_4);
    thread Quat_0 _S609 = rg_9->rot_1;
    float3 _S610 = rotate_0(&_S609, _S608);
    comp_add_0(&rg_9->pos_0, &rg_9->pos_err_0, _S610);
    thread Quat_0 _S611 = rg_9->rot_1;
    float3 _S612 = inverse_rotate_0(&_S611, rg_9->w_5);
    float4 _S613 = isl_17->inertia0_0;
    float4 _S614 = isl_17->inertia1_0;
    float4 _S615 = isl_17->inertia2_0;
    float3 _S616 = cross(phi_3, rows_mul_0(isl_17->inertia0_0, isl_17->inertia1_0, isl_17->inertia2_0, _S612)) - rows_mul_0(isl_17->inertia0_0, isl_17->inertia1_0, isl_17->inertia2_0, cross(phi_3, _S612));
    thread Quat_0 _S617 = rg_9->rot_1;
    float3 _S618 = rotate_0(&_S617, _S616);
    turn_right_0(&rg_9->rot_1, &rg_9->rot_err_0, phi_3);
    float3 _S619 = dv_4 + cross(dw_2, isl_17->com_0.xyz - wcom_4);
    thread Quat_0 _S620 = rot_3;
    float3 _S621 = rotate_0(&_S620, _S619);
    comp_add_0(&rg_9->vel_0, &rg_9->vel_err_0, _S621);
    thread Quat_0 _S622 = rot_3;
    float3 _S623 = rotate_0(&_S622, dw_2);
    rg_9->w_5 = rg_9->w_5 + _S623;
    thread Quat_0 _S624 = rg_9->rot_1;
    float3 _S625 = world_mul_0(&_S624, _S613, _S614, _S615, _S623);
    comp_add_0(&rg_9->l_1, &rg_9->l_err_0, _S618 + _S625);
    return;
}

[[kernel]] void wide_rigid(uint3 group_3 [[threadgroup_position_in_grid]], uint3 thread_3 [[thread_position_in_threadgroup]], Params_0 constant* params_6 [[buffer(0)]], Island_natural_0 device* islands_6 [[buffer(9)]], uint device* index_6 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_6 [[buffer(3)]], packed_float4 device* state_6 [[buffer(6)]], packed_float4 device* scratch_6 [[buffer(8)]], packed_float4 device* contact_state_6 [[buffer(11)]], packed_float4 device* loads_6 [[buffer(5)]], Impactor_natural_0 device* impactors_6 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_6 [[buffer(7)]], BondStatic_natural_0 device* bonds_6 [[buffer(2)]], MaterialTable_0 constant* materials_6 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_58;
    (&kernelContext_58)->params_0 = params_6;
    (&kernelContext_58)->islands_0 = islands_6;
    (&kernelContext_58)->index_0 = index_6;
    (&kernelContext_58)->chunks_0 = chunks_6;
    (&kernelContext_58)->state_0 = state_6;
    (&kernelContext_58)->scratch_0 = scratch_6;
    (&kernelContext_58)->contact_state_0 = contact_state_6;
    (&kernelContext_58)->loads_0 = loads_6;
    (&kernelContext_58)->impactors_0 = impactors_6;
    (&kernelContext_58)->bond_dyn_0 = bond_dyn_6;
    (&kernelContext_58)->bonds_0 = bonds_6;
    (&kernelContext_58)->materials_0 = materials_6;
    threadgroup array<float4, int(32)> g_part_a_6;
    (&kernelContext_58)->g_part_a_0 = &g_part_a_6;
    threadgroup array<float4, int(32)> g_part_b_6;
    (&kernelContext_58)->g_part_b_0 = &g_part_b_6;
    threadgroup array<uint, int(5)> g_seen_6;
    (&kernelContext_58)->g_seen_0 = &g_seen_6;
    threadgroup uint g_wide_run_6;
    (&kernelContext_58)->g_wide_run_0 = &g_wide_run_6;
    threadgroup array<uint, int(4096)> g_label_6;
    (&kernelContext_58)->g_label_0 = &g_label_6;
    threadgroup uint g_changed_6;
    (&kernelContext_58)->g_changed_0 = &g_changed_6;
    threadgroup uint g_halt_6;
    (&kernelContext_58)->g_halt_0 = &g_halt_6;
    threadgroup uint g_run_6;
    (&kernelContext_58)->g_run_0 = &g_run_6;
    threadgroup array<uint, int(512)> g_label_narrow_6;
    (&kernelContext_58)->g_label_narrow_0 = &g_label_narrow_6;
    threadgroup uint g_changed_narrow_6;
    (&kernelContext_58)->g_changed_narrow_0 = &g_changed_narrow_6;
    uint tid_10 = thread_3.x;
    uint _S626 = group_3.x;
    WideGroup_0 _S627 = wide_group_0(params_6->wide_chunk_table_0, _S626, &kernelContext_58);
    thread Island_natural_0 _S628 = *((&kernelContext_58)->islands_0+_S627.island_3);
    uint _S629 = (uint4((&_S628)->info_0) ).x;
    bool _S630;
    if((_S629 & 1U) != 0U)
    {
        _S630 = true;
    }
    else
    {
        bool _S631 = wide_enter_1(tid_10, _S627.island_3, &kernelContext_58);
        _S630 = !_S631;
    }
    if(_S630)
    {
        return;
    }
    if((_S629 & 16U) != 0U)
    {
        if(_S626 != (_S627.first_0))
        {
            return;
        }
        thread WideGroup_0 _S632 = _S627;
        Rigid_0 _S633 = wide_rigid_frame_0(tid_10, &_S628, &_S632, &kernelContext_58);
        thread Rigid_0 rs_0 = _S633;
        if(tid_10 != 0U)
        {
            _S630 = true;
        }
        else
        {
            _S630 = (_S629 & 2U) != 0U;
        }
        if(_S630)
        {
            return;
        }
        integrate_rigid_0(&_S628, &rs_0, (&kernelContext_58)->params_0->dt_0);
        thread Quat_0 _S634 = (&rs_0)->rot_1;
        float4 _S635 = quat_vec_0(&_S634);
        ((&kernelContext_58)->islands_0+_S627.island_3)->rotation_0 = packed_float4(_S635) ;
        ((&kernelContext_58)->islands_0+_S627.island_3)->rotation_err_0 = packed_float4((&rs_0)->rot_err_0) ;
        ((&kernelContext_58)->islands_0+_S627.island_3)->position_0 = packed_float4(float4((&rs_0)->pos_0, 0.0f)) ;
        ((&kernelContext_58)->islands_0+_S627.island_3)->position_err_0 = packed_float4(float4((&rs_0)->pos_err_0, 0.0f)) ;
        ((&kernelContext_58)->islands_0+_S627.island_3)->velocity_0 = packed_float4(float4((&rs_0)->vel_0, 0.0f)) ;
        ((&kernelContext_58)->islands_0+_S627.island_3)->velocity_err_0 = packed_float4(float4((&rs_0)->vel_err_0, 0.0f)) ;
        ((&kernelContext_58)->islands_0+_S627.island_3)->angular_velocity_0 = packed_float4(float4((&rs_0)->w_5, 0.0f)) ;
        ((&kernelContext_58)->islands_0+_S627.island_3)->momentum_0 = packed_float4(float4((&rs_0)->l_1, 0.0f)) ;
        ((&kernelContext_58)->islands_0+_S627.island_3)->momentum_err_0 = packed_float4(float4((&rs_0)->l_err_0, 0.0f)) ;
        return;
    }
    thread float3 tu_1;
    thread float3 pv_1;
    wide_partials_0(tid_10, _S627.first_0, (&_S628)->wide_groups_0, 2U, &tu_1, &pv_1, &kernelContext_58);
    thread float3 lu_2;
    thread float3 lv_2;
    wide_partials_0(tid_10, _S627.first_0, (&_S628)->wide_groups_0, 4U, &lu_2, &lv_2, &kernelContext_58);
    float4 _S636 = float4((&_S628)->wcom_0) ;
    float3 _S637 = float3(_S636.w) ;
    float3 tr_5 = tu_1 / _S637;
    float3 dv_5 = pv_1 / _S637;
    float4 _S638 = float4((&_S628)->winv0_0) ;
    float4 _S639 = float4((&_S628)->winv1_0) ;
    float4 _S640 = float4((&_S628)->winv2_0) ;
    float3 phi_4 = rows_mul_0(_S638, _S639, _S640, lu_2);
    float3 dw_3 = rows_mul_0(_S638, _S639, _S640, lv_2);
    uint c_15 = _S627.begin_0 + tid_10;
    if(c_15 < (_S627.end_0))
    {
        drift_apply_0(c_15, _S636.xyz, tr_5, phi_4, dv_5, dw_3, &kernelContext_58);
    }
    if(_S626 != (_S627.first_0))
    {
        return;
    }
    thread WideGroup_0 _S641 = _S627;
    Rigid_0 _S642 = wide_rigid_frame_0(tid_10, &_S628, &_S641, &kernelContext_58);
    thread Rigid_0 rg_10 = _S642;
    if(tid_10 != 0U)
    {
        return;
    }
    if(!((_S629 & 2U) != 0U))
    {
        integrate_rigid_0(&_S628, &rg_10, (&kernelContext_58)->params_0->dt_0);
        drift_rigid_0(&_S628, &rg_10, tr_5, phi_4, dv_5, dw_3);
    }
    thread Quat_0 _S643 = (&rg_10)->rot_1;
    float4 _S644 = quat_vec_0(&_S643);
    ((&kernelContext_58)->islands_0+_S627.island_3)->rotation_0 = packed_float4(_S644) ;
    ((&kernelContext_58)->islands_0+_S627.island_3)->rotation_err_0 = packed_float4((&rg_10)->rot_err_0) ;
    ((&kernelContext_58)->islands_0+_S627.island_3)->position_0 = packed_float4(float4((&rg_10)->pos_0, 0.0f)) ;
    ((&kernelContext_58)->islands_0+_S627.island_3)->position_err_0 = packed_float4(float4((&rg_10)->pos_err_0, 0.0f)) ;
    ((&kernelContext_58)->islands_0+_S627.island_3)->velocity_0 = packed_float4(float4((&rg_10)->vel_0, 0.0f)) ;
    ((&kernelContext_58)->islands_0+_S627.island_3)->velocity_err_0 = packed_float4(float4((&rg_10)->vel_err_0, 0.0f)) ;
    ((&kernelContext_58)->islands_0+_S627.island_3)->angular_velocity_0 = packed_float4(float4((&rg_10)->w_5, 0.0f)) ;
    ((&kernelContext_58)->islands_0+_S627.island_3)->momentum_0 = packed_float4(float4((&rg_10)->l_1, 0.0f)) ;
    ((&kernelContext_58)->islands_0+_S627.island_3)->momentum_err_0 = packed_float4(float4((&rg_10)->l_err_0, 0.0f)) ;
    return;
}

bool connected_0(const JointState_0 thread* st_0, bool has_rebar_0)
{
    bool _S645;
    if((st_0->damage_0) < 1.0f)
    {
        _S645 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S645 = (st_0->rebar_broken_0) == 0.0f;
        }
        else
        {
            _S645 = false;
        }
    }
    return _S645;
}

bool island_connected_0(uint tid_11, const Island_0 thread* isl_18, KernelContext_0 thread* kernelContext_59)
{
    uint _S646 = isl_18->range_0.x;
    uint n_10 = isl_18->range_0.y - _S646;
    bool converged_0;
    if(n_10 > 4096U)
    {
        converged_0 = true;
    }
    else
    {
        converged_0 = (kernelContext_59->params_0->device_connect_0) == 0U;
    }
    if(converged_0)
    {
        return false;
    }
    uint c_16 = tid_11;
    for(;;)
    {
        if(c_16 < n_10)
        {
        }
        else
        {
            break;
        }
        (*kernelContext_59->g_label_0)[c_16] = c_16;
        c_16 = c_16 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    converged_0 = false;
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
        if(tid_11 == 0U)
        {
            *kernelContext_59->g_changed_0 = 0U;
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);
        c_16 = tid_11;
        for(;;)
        {
            if(c_16 < n_10)
            {
            }
            else
            {
                break;
            }
            uint gc_0 = _S646 + c_16;
            uint _S647 = kernelContext_59->index_0[gc_0];
            uint l_4 = (*kernelContext_59->g_label_0)[c_16];
            uint e_2 = _S647;
            for(;;)
            {
                if(e_2 < (kernelContext_59->index_0)[gc_0 + 1U])
                {
                }
                else
                {
                    break;
                }
                uint entry_1 = kernelContext_59->index_0[e_2];
                uint bond_0 = entry_1 >> 1U;
                bool _S648 = ((float4((kernelContext_59->bonds_0+bond_0)->law_0.stiff1_0) ).w) != 0.0f;
                thread JointState_0 _S649 = (kernelContext_59->bond_dyn_0+bond_0)->js_0;
                bool _S650 = connected_0(&_S649, _S648);
                if(!_S650)
                {
                    e_2 = e_2 + 1U;
                    continue;
                }
                uint other_0;
                if((entry_1 & 1U) == 0U)
                {
                    other_0 = (uint4((kernelContext_59->bonds_0+bond_0)->law_0.ids_0) ).z;
                }
                else
                {
                    other_0 = (uint4((kernelContext_59->bonds_0+bond_0)->law_0.ids_0) ).y;
                }
                l_4 = min(l_4, (*kernelContext_59->g_label_0)[other_0 - _S646]);
                e_2 = e_2 + 1U;
            }
            uint _S651 = min(l_4, (*kernelContext_59->g_label_0)[l_4]);
            if(_S651 < (*kernelContext_59->g_label_0)[c_16])
            {
                (*kernelContext_59->g_label_0)[c_16] = _S651;
                *kernelContext_59->g_changed_0 = 1U;
            }
            c_16 = c_16 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);
        bool converged_1 = (*kernelContext_59->g_changed_0) == 0U;
        threadgroup_barrier(mem_flags::mem_threadgroup);
        if(converged_1)
        {
            converged_0 = converged_1;
            break;
        }
        uint _S652 = pass_0 + 1U;
        converged_0 = converged_1;
        pass_0 = _S652;
    }
    if(!converged_0)
    {
        return false;
    }
    if(tid_11 == 0U)
    {
        *kernelContext_59->g_changed_0 = 0U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    c_16 = tid_11;
    for(;;)
    {
        if(c_16 < n_10)
        {
        }
        else
        {
            break;
        }
        if(((*kernelContext_59->g_label_0)[c_16]) != 0U)
        {
            *kernelContext_59->g_changed_0 = 1U;
        }
        c_16 = c_16 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    return (*kernelContext_59->g_changed_0) == 0U;
}

void write_probe_0(uint slot_2, uint k_12, float value_0, KernelContext_0 thread* kernelContext_60)
{
    uint at_5 = kernelContext_60->params_0->probe_base_0 * 4U + slot_2 * kernelContext_60->params_0->probe_stride_0 + k_12;
    thread float4 v_10 = float4(*(kernelContext_60->scratch_0+at_5 / 4U)) ;
    v_10[at_5 % 4U] = value_0;
    *(kernelContext_60->scratch_0+at_5 / 4U) = packed_float4(v_10) ;
    return;
}

void record_probes_0(const Island_0 thread* isl_19, const Rigid_0 thread* rg_11, uint k_13, KernelContext_0 thread* kernelContext_61)
{
    uint4 _S653 = isl_19->probes_0;
    uint at_6 = isl_19->probes_0.x;
    for(;;)
    {
        if(at_6 < (_S653.y))
        {
        }
        else
        {
            break;
        }
        uint4 info_3 = (as_type<uint4>((float4(*(kernelContext_61->loads_0+at_6)) )));
        float4 _S654 = float4(*(kernelContext_61->loads_0+(at_6 + 1U))) ;
        float4 _S655 = float4(*(kernelContext_61->loads_0+(at_6 + 2U))) ;
        float4 _S656 = float4(*(kernelContext_61->loads_0+(at_6 + 3U))) ;
        uint kind_1 = info_3.x;
        uint i_6 = info_3.y;
        float value_1;
        if(kind_1 == 0U)
        {
            float3 small_0 = (float4(*(kernelContext_61->state_0+4U * i_6)) ).xyz + float3(_S654.w, _S655.w, _S656.w);
            float3 _S657 = rg_11->pos_0 - _S655.xyz;
            float3 _S658 = rotate_0(&rg_11->rot_1, (float4((kernelContext_61->chunks_0+i_6)->center_0) ).xyz);
            float3 _S659 = _S657 + _S658;
            float3 _S660 = rg_11->pos_err_0 - _S656.xyz;
            float3 _S661 = rotate_0(&rg_11->rot_1, small_0);
            value_1 = dot(_S659 + (_S660 + _S661), _S654.xyz);
        }
        else
        {
            if(kind_1 == 1U)
            {
                uint _S662 = 4U * i_6;
                float3 _S663 = rotate_0(&rg_11->rot_1, (float4((kernelContext_61->chunks_0+i_6)->center_0) ).xyz + (float4(*(kernelContext_61->state_0+_S662)) ).xyz - isl_19->com_0.xyz);
                float3 _S664 = rg_11->vel_0 + rg_11->vel_err_0 + cross(rg_11->w_5, _S663);
                float3 _S665 = rotate_0(&rg_11->rot_1, (float4(*(kernelContext_61->state_0+(_S662 + 2U))) ).xyz);
                value_1 = dot(_S664 + _S665, _S654.xyz);
            }
            else
            {
                if(kind_1 == 2U)
                {
                    uint _S666 = 3U * i_6;
                    float3 f_7 = (float4(*(kernelContext_61->scratch_0+_S666)) ).xyz;
                    bool _S667 = (info_3.z) == 0U;
                    float3 mc_0;
                    if(_S667)
                    {
                        mc_0 = (float4(*(kernelContext_61->scratch_0+(_S666 + 1U))) ).xyz;
                    }
                    else
                    {
                        mc_0 = (float4(*(kernelContext_61->scratch_0+(_S666 + 2U))) ).xyz;
                    }
                    float3 fc_0;
                    if(_S667)
                    {
                        fc_0 = f_7;
                    }
                    else
                    {
                        fc_0 = - f_7;
                    }
                    value_1 = dot(fc_0, _S654.xyz) + dot(mc_0, _S655.xyz);
                }
                else
                {
                    uint _S668 = 4U * i_6;
                    float3 _S669 = rotate_0(&rg_11->rot_1, float3((float4(*(kernelContext_61->state_0+(_S668 + 1U))) ).w, (float4(*(kernelContext_61->state_0+(_S668 + 2U))) ).w, (float4(*(kernelContext_61->state_0+(_S668 + 3U))) ).w));
                    value_1 = dot(_S669, _S654.xyz);
                }
            }
        }
        write_probe_0(info_3.w, k_13, value_1, kernelContext_61);
        at_6 = at_6 + 4U;
    }
    return;
}

void contact_split_at_0(uint at_7, KernelContext_0 thread* kernelContext_62)
{
    uint previous_0 = (uint4((kernelContext_62->islands_0+kernelContext_62->params_0->halt_index_0)->info_0) ).y;
    uint _S670;
    if(previous_0 == 0U)
    {
        _S670 = at_7;
    }
    else
    {
        _S670 = min(previous_0, at_7);
    }
    (kernelContext_62->islands_0+kernelContext_62->params_0->halt_index_0)->info_0[int(1)] = _S670;
    return;
}

[[kernel]] void wide_end(uint3 group_4 [[threadgroup_position_in_grid]], uint3 thread_4 [[thread_position_in_threadgroup]], Params_0 constant* params_7 [[buffer(0)]], Island_natural_0 device* islands_7 [[buffer(9)]], uint device* index_7 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_7 [[buffer(3)]], packed_float4 device* state_7 [[buffer(6)]], packed_float4 device* scratch_7 [[buffer(8)]], packed_float4 device* contact_state_7 [[buffer(11)]], packed_float4 device* loads_7 [[buffer(5)]], Impactor_natural_0 device* impactors_7 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_7 [[buffer(7)]], BondStatic_natural_0 device* bonds_7 [[buffer(2)]], MaterialTable_0 constant* materials_7 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_63;
    (&kernelContext_63)->params_0 = params_7;
    (&kernelContext_63)->islands_0 = islands_7;
    (&kernelContext_63)->index_0 = index_7;
    (&kernelContext_63)->chunks_0 = chunks_7;
    (&kernelContext_63)->state_0 = state_7;
    (&kernelContext_63)->scratch_0 = scratch_7;
    (&kernelContext_63)->contact_state_0 = contact_state_7;
    (&kernelContext_63)->loads_0 = loads_7;
    (&kernelContext_63)->impactors_0 = impactors_7;
    (&kernelContext_63)->bond_dyn_0 = bond_dyn_7;
    (&kernelContext_63)->bonds_0 = bonds_7;
    (&kernelContext_63)->materials_0 = materials_7;
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
    threadgroup array<uint, int(512)> g_label_narrow_7;
    (&kernelContext_63)->g_label_narrow_0 = &g_label_narrow_7;
    threadgroup uint g_changed_narrow_7;
    (&kernelContext_63)->g_changed_narrow_0 = &g_changed_narrow_7;
    uint tid_12 = thread_4.x;
    uint _S671 = group_4.x;
    WideGroup_0 _S672 = wide_group_0(params_7->wide_chunk_table_0, _S671, &kernelContext_63);
    if(_S671 != (_S672.first_0))
    {
        return;
    }
    Island_natural_0 device* _S673 = (&kernelContext_63)->islands_0+_S672.island_3;
    thread Island_natural_0 _S674 = *_S673;
    uint4 _S675 = uint4((&_S674)->info_0) ;
    float4 _S676 = float4((&_S674)->com_0) ;
    float4 _S677 = float4((&_S674)->inertia0_0) ;
    float4 _S678 = float4((&_S674)->inertia1_0) ;
    float4 _S679 = float4((&_S674)->inertia2_0) ;
    float4 _S680 = float4((&_S674)->inv0_0) ;
    float4 _S681 = float4((&_S674)->inv1_0) ;
    float4 _S682 = float4((&_S674)->inv2_0) ;
    float4 _S683 = float4((&_S674)->wcom_0) ;
    float4 _S684 = float4((&_S674)->winv0_0) ;
    float4 _S685 = float4((&_S674)->winv1_0) ;
    float4 _S686 = float4((&_S674)->winv2_0) ;
    float4 _S687 = float4((&_S674)->rotation_0) ;
    float4 _S688 = float4((&_S674)->position_0) ;
    float4 _S689 = float4((&_S674)->position_err_0) ;
    float4 _S690 = float4((&_S674)->velocity_0) ;
    float4 _S691 = float4((&_S674)->velocity_err_0) ;
    float4 _S692 = float4((&_S674)->angular_velocity_0) ;
    uint4 _S693 = uint4((&_S674)->probes_0) ;
    float4 _S694 = float4((&_S674)->energy_0) ;
    float4 _S695 = float4((&_S674)->rotation_err_0) ;
    float4 _S696 = float4((&_S674)->momentum_0) ;
    float4 _S697 = float4((&_S674)->momentum_err_0) ;
    thread Island_0 isl_20;
    (&isl_20)->range_0 = uint4((&_S674)->range_0) ;
    (&isl_20)->info_0 = _S675;
    (&isl_20)->com_0 = _S676;
    (&isl_20)->inertia0_0 = _S677;
    (&isl_20)->inertia1_0 = _S678;
    (&isl_20)->inertia2_0 = _S679;
    (&isl_20)->inv0_0 = _S680;
    (&isl_20)->inv1_0 = _S681;
    (&isl_20)->inv2_0 = _S682;
    (&isl_20)->wcom_0 = _S683;
    (&isl_20)->winv0_0 = _S684;
    (&isl_20)->winv1_0 = _S685;
    (&isl_20)->winv2_0 = _S686;
    (&isl_20)->rotation_0 = _S687;
    (&isl_20)->position_0 = _S688;
    (&isl_20)->position_err_0 = _S689;
    (&isl_20)->velocity_0 = _S690;
    (&isl_20)->velocity_err_0 = _S691;
    (&isl_20)->angular_velocity_0 = _S692;
    (&isl_20)->done_0 = (&_S674)->done_0;
    (&isl_20)->coverage_0 = (&_S674)->coverage_0;
    (&isl_20)->wide_groups_0 = (&_S674)->wide_groups_0;
    (&isl_20)->done_pad_0 = (&_S674)->done_pad_0;
    (&isl_20)->probes_0 = _S693;
    (&isl_20)->energy_0 = _S694;
    (&isl_20)->rotation_err_0 = _S695;
    (&isl_20)->momentum_0 = _S696;
    (&isl_20)->momentum_err_0 = _S697;
    _S674 = *_S673;
    bool _S698 = wide_enter_0(tid_12, &_S674, &kernelContext_63);
    if(!_S698)
    {
        return;
    }
    thread float3 work_0;
    thread float3 flags_1;
    wide_partials_0(tid_12, _S672.first_0, (&isl_20)->wide_groups_0, 6U, &work_0, &flags_1, &kernelContext_63);
    bool halt_0 = (((&isl_20)->info_0.z) & 2U) != 0U;
    bool whole_0;
    if(halt_0)
    {
        thread Island_0 _S699 = isl_20;
        bool _S700 = island_connected_0(tid_12, &_S699, &kernelContext_63);
        whole_0 = _S700;
    }
    else
    {
        whole_0 = false;
    }
    if(tid_12 != 0U)
    {
        return;
    }
    bool halt_1;
    if(whole_0)
    {
        (&isl_20)->info_0.z = ((&isl_20)->info_0.z) & 4294967293U;
        (&isl_20)->coverage_0 = ((&isl_20)->coverage_0) | 2097280U;
        halt_1 = false;
    }
    else
    {
        halt_1 = halt_0;
    }
    thread Island_0 _S701 = isl_20;
    uint _S702 = wide_step_2(&_S701, &kernelContext_63);
    if(((&isl_20)->probes_0.y) > ((&isl_20)->probes_0.x))
    {
        thread Island_0 _S703 = isl_20;
        Rigid_0 _S704 = rigid_of_1(&_S703);
        thread Island_0 _S705 = isl_20;
        thread Rigid_0 _S706 = _S704;
        record_probes_0(&_S705, &_S706, _S702, &kernelContext_63);
    }
    if(halt_1)
    {
        whole_0 = (((&isl_20)->info_0.x) & 4U) != 0U;
    }
    else
    {
        whole_0 = false;
    }
    if(whole_0)
    {
        contact_split_at_0((&isl_20)->info_0.w + 1U, &kernelContext_63);
    }
    float _S707 = work_0.x;
    thread float _S708 = (&isl_20)->energy_0.x;
    thread float _S709 = (&isl_20)->energy_0.y;
    comp_add1_0(&_S708, &_S709, _S707);
    (&isl_20)->energy_0.x = _S708;
    (&isl_20)->energy_0.y = _S709 + work_0.y;
    (&isl_20)->done_0 = (&isl_20)->done_0 + 1U;
    (&isl_20)->info_0.y = (&isl_20)->info_0.y - 1U;
    (&isl_20)->info_0.w = (&isl_20)->info_0.w + 1U;
    if(halt_1)
    {
        (&isl_20)->info_0.z = (((&isl_20)->info_0.z) & 4294967293U) | 1U;
    }
    uint _S710;
    if(halt_1)
    {
        _S710 = 128U;
    }
    else
    {
        _S710 = 0U;
    }
    uint _S711 = 256U | _S710;
    if(((&isl_20)->probes_0.y) > ((&isl_20)->probes_0.x))
    {
        _S710 = 262144U;
    }
    else
    {
        _S710 = 0U;
    }
    uint _S712 = _S711 | _S710;
    if((((&isl_20)->info_0.x) & 4U) != 0U)
    {
        _S710 = 524288U;
    }
    else
    {
        _S710 = 0U;
    }
    uint _S713 = _S712 | _S710;
    if((flags_1.x) > 0.0f)
    {
        _S710 = 32768U;
    }
    else
    {
        _S710 = 0U;
    }
    uint _S714 = _S713 | _S710;
    if((flags_1.y) > 0.0f)
    {
        _S710 = 65536U;
    }
    else
    {
        _S710 = 0U;
    }
    uint _S715 = _S714 | _S710;
    if((flags_1.z) > 0.0f)
    {
        _S710 = 131072U;
    }
    else
    {
        _S710 = 0U;
    }
    (&isl_20)->coverage_0 = ((&isl_20)->coverage_0) | (_S715 | _S710);
    Island_natural_0 device* _S716 = (&kernelContext_63)->islands_0+_S672.island_3;
    _S716->range_0 = packed_uint4(isl_20.range_0) ;
    _S716->info_0 = packed_uint4(isl_20.info_0) ;
    _S716->com_0 = packed_float4(isl_20.com_0) ;
    _S716->inertia0_0 = packed_float4(isl_20.inertia0_0) ;
    _S716->inertia1_0 = packed_float4(isl_20.inertia1_0) ;
    _S716->inertia2_0 = packed_float4(isl_20.inertia2_0) ;
    _S716->inv0_0 = packed_float4(isl_20.inv0_0) ;
    _S716->inv1_0 = packed_float4(isl_20.inv1_0) ;
    _S716->inv2_0 = packed_float4(isl_20.inv2_0) ;
    _S716->wcom_0 = packed_float4(isl_20.wcom_0) ;
    _S716->winv0_0 = packed_float4(isl_20.winv0_0) ;
    _S716->winv1_0 = packed_float4(isl_20.winv1_0) ;
    _S716->winv2_0 = packed_float4(isl_20.winv2_0) ;
    _S716->rotation_0 = packed_float4(isl_20.rotation_0) ;
    _S716->position_0 = packed_float4(isl_20.position_0) ;
    _S716->position_err_0 = packed_float4(isl_20.position_err_0) ;
    _S716->velocity_0 = packed_float4(isl_20.velocity_0) ;
    _S716->velocity_err_0 = packed_float4(isl_20.velocity_err_0) ;
    _S716->angular_velocity_0 = packed_float4(isl_20.angular_velocity_0) ;
    _S716->done_0 = isl_20.done_0;
    _S716->coverage_0 = isl_20.coverage_0;
    _S716->wide_groups_0 = isl_20.wide_groups_0;
    _S716->done_pad_0 = isl_20.done_pad_0;
    _S716->probes_0 = packed_uint4(isl_20.probes_0) ;
    _S716->energy_0 = packed_float4(isl_20.energy_0) ;
    _S716->rotation_err_0 = packed_float4(isl_20.rotation_err_0) ;
    _S716->momentum_0 = packed_float4(isl_20.momentum_0) ;
    _S716->momentum_err_0 = packed_float4(isl_20.momentum_err_0) ;
    return;
}

uint sv_0(uint c_17, uint slot_3, KernelContext_0 thread* kernelContext_64)
{
    return kernelContext_64->params_0->statics_base_0 + 23U * c_17 + slot_3;
}

void project_load_slot_0(uint tid_13, const Island_natural_0 thread* isl_21, uint slot_4, KernelContext_0 thread* kernelContext_65)
{
    uint _S717;
    float3 _S718 = float3(0.0f) ;
    thread float3 net_f_0 = _S718;
    thread float3 net_m_0 = _S718;
    uint4 _S719 = uint4(isl_21->range_0) ;
    uint _S720 = _S719.x + tid_13;
    uint c_18 = _S720;
    for(;;)
    {
        uint _S721 = _S719.y;
        _S717 = _S721;
        if(c_18 < _S721)
        {
        }
        else
        {
            break;
        }
        uint _S722 = sv_0(c_18, slot_4, kernelContext_65);
        float3 fi_0 = (float4(*(kernelContext_65->scratch_0+_S722)) ).xyz;
        net_f_0 = net_f_0 + fi_0;
        float3 _S723 = cross((float4((kernelContext_65->chunks_0+c_18)->center_0) ).xyz - (float4(isl_21->com_0) ).xyz, fi_0);
        uint _S724 = sv_0(c_18, slot_4 + 1U, kernelContext_65);
        net_m_0 = net_m_0 + (_S723 + (float4(*(kernelContext_65->scratch_0+_S724)) ).xyz);
        c_18 = c_18 + 256U;
    }
    group_sum3_0(tid_13, &net_f_0, &net_m_0, kernelContext_65);
    float4 _S725 = float4(isl_21->com_0) ;
    float3 _S726 = net_f_0 / float3(_S725.w) ;
    float3 _S727 = rows_mul_0(float4(isl_21->inv0_0) , float4(isl_21->inv1_0) , float4(isl_21->inv2_0) , net_m_0);
    c_18 = _S720;
    for(;;)
    {
        if(c_18 < _S717)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_natural_0 device* _S728 = kernelContext_65->chunks_0+c_18;
        float4 _S729 = float4(_S728->center_0) ;
        float3 r_8 = _S729.xyz - _S725.xyz;
        uint _S730 = sv_0(c_18, slot_4, kernelContext_65);
        *(kernelContext_65->scratch_0+_S730) = packed_float4(float4((float4(*(kernelContext_65->scratch_0+_S730)) ).xyz - (_S726 + cross(_S727, r_8)) * float3(_S729.w) , 0.0f)) ;
        uint _S731 = sv_0(c_18, slot_4 + 1U, kernelContext_65);
        *(kernelContext_65->scratch_0+_S731) = packed_float4(float4((float4(*(kernelContext_65->scratch_0+_S731)) ).xyz - rows_mul_0(float4(_S728->inertia0_1) , float4(_S728->inertia1_1) , float4(_S728->inertia2_1) , _S727), 0.0f)) ;
        c_18 = c_18 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    return;
}

float island_dot_0(uint tid_14, uint c0_0, uint c1_0, uint sa_2, uint sb_2, KernelContext_0 thread* kernelContext_66)
{
    float4 _S732 = float4(0.0f) ;
    thread float4 acc_0 = _S732;
    thread float4 unused_2 = _S732;
    uint c_19 = c0_0 + tid_14;
    for(;;)
    {
        if(c_19 < c1_0)
        {
        }
        else
        {
            break;
        }
        uint _S733 = sv_0(c_19, sa_2, kernelContext_66);
        float3 _S734 = (float4(*(kernelContext_66->scratch_0+_S733)) ).xyz;
        uint _S735 = sv_0(c_19, sb_2, kernelContext_66);
        float _S736 = dot(_S734, (float4(*(kernelContext_66->scratch_0+_S735)) ).xyz);
        uint _S737 = sv_0(c_19, sa_2 + 1U, kernelContext_66);
        float3 _S738 = (float4(*(kernelContext_66->scratch_0+_S737)) ).xyz;
        uint _S739 = sv_0(c_19, sb_2 + 1U, kernelContext_66);
        acc_0.x = acc_0.x + (_S736 + dot(_S738, (float4(*(kernelContext_66->scratch_0+_S739)) ).xyz));
        c_19 = c_19 + 256U;
    }
    group_sum2_0(tid_14, &acc_0, &unused_2, kernelContext_66);
    return acc_0.x;
}

struct Measures_0
{
    float tension_0;
    float shear_0;
    float normal_compression_0;
    float compression_0;
    float compressive_force_0;
};

Measures_0 stress_measures_0(const JointBond_natural_0 thread* b_25, float3 q_lin_0, float3 q_ang_0)
{
    float4 _S740 = float4(b_25->geom0_0) ;
    float area_2 = _S740.x;
    float _S741 = q_lin_0.z;
    float axial_0 = (metal::fast::divide((_S741), (area_2)));
    float4 _S742 = float4(b_25->geom1_0) ;
    float _S743 = (metal::fast::divide((abs(q_ang_0.x)), (_S742.x)));
    float _S744 = (metal::fast::divide((abs(q_ang_0.y)), (_S742.y)));
    float bending_0 = _S743 + _S744;
    float _S745 = q_lin_0.x;
    float _S746 = q_lin_0.y;
    float _S747 = (metal::fast::sqrt((_S745 * _S745 + _S746 * _S746)));
    float _S748 = (metal::fast::divide((_S747), (area_2)));
    float _S749 = (metal::fast::divide((abs(q_ang_0.z)), (_S740.w)));
    float shear_1 = _S748 + _S749;
    thread Measures_0 m_2;
    (&m_2)->tension_0 = axial_0 + bending_0;
    (&m_2)->shear_0 = shear_1;
    float _S750 = - axial_0;
    (&m_2)->normal_compression_0 = max(_S750, 0.0f);
    (&m_2)->compression_0 = _S750 + bending_0;
    (&m_2)->compressive_force_0 = max(- _S741, 0.0f);
    return m_2;
}

float expm1_accurate_0(float x_12)
{
    if((abs(x_12)) < 0.00100000004749745f)
    {
        return x_12 * (1.0f + x_12 * (0.5f + x_12 * 0.1666666716337204f));
    }
    return exp(x_12) - 1.0f;
}

float dif_factor_0(const JointMaterial_0 constant* mat_1, float strain_rate_1)
{
    float r_9 = abs(strain_rate_1);
    float4 _S751 = mat_1->dif_0;
    float ref_0 = mat_1->dif_0.x;
    if(r_9 <= ref_0)
    {
        return 1.0f;
    }
    float _S752 = _S751.z;
    float f_8;
    if(r_9 <= _S752)
    {
        float _S753 = (metal::fast::divide((r_9), (ref_0)));
        float _S754 = (metal::fast::pow((_S753), (_S751.y)));
        f_8 = _S754;
    }
    else
    {
        float _S755 = (metal::fast::divide((_S752), (ref_0)));
        float _S756 = (metal::fast::pow((_S755), (_S751.y)));
        float _S757 = (metal::fast::divide((r_9), (_S752)));
        float _S758 = (metal::fast::pow((_S757), (_S751.w)));
        f_8 = _S756 * _S758;
    }
    return clamp(f_8, 1.0f, mat_1->misc_0.x);
}

float fatigue_factor_0(const JointMaterial_0 constant* mat_2, float life_1)
{
    if(((mat_2->kind_flags_0.y) & 64U) == 0U)
    {
        return 1.0f;
    }
    float _S759 = clamp(life_1, 0.0f, 1.0f);
    float _S760 = (metal::fast::divide((1.0f), (mat_2->misc_0.y - 2.0f)));
    float _S761 = (metal::fast::pow((_S759), (_S760)));
    return _S761;
}

float infinity_0()
{
    return (as_type<float>((2139095040U)));
}

float4 failure_indices_0(const JointMaterial_0 constant* mat_3, const JointBond_natural_0 thread* b_26, const Measures_0 thread* m_3, float multiplier_0)
{
    float fc_1 = mat_3->strength_0.y * multiplier_0;
    float _S762 = min(mat_3->strength_0.z * multiplier_0 + mat_3->strength_0.w * m_3->normal_compression_0, mat_3->energy_1.x * multiplier_0);
    thread float4 idx_0;
    float _S763 = (metal::fast::divide((m_3->tension_0), (mat_3->strength_0.x * multiplier_0)));
    idx_0.x = max(_S763, 0.0f);
    float _S764;
    if(_S762 > 0.0f)
    {
        float _S765 = (metal::fast::divide((m_3->shear_0), (_S762)));
        _S764 = _S765;
    }
    else
    {
        _S764 = infinity_0();
    }
    idx_0.y = _S764;
    float _S766 = (metal::fast::divide((m_3->compression_0), (fc_1)));
    idx_0.z = max(_S766, 0.0f);
    float _S767 = (float4(b_26->stiff1_0) ).y;
    if(_S767 > 0.0f)
    {
        float _S768 = (metal::fast::divide((m_3->compressive_force_0), (_S767)));
        _S764 = _S768;
    }
    else
    {
        _S764 = 0.0f;
    }
    idx_0.w = _S764;
    return idx_0;
}

float sq_0(float x_13)
{
    return x_13 * x_13;
}

float damage_law_0(uint kind_2, float kappa_1, float r_10)
{
    if(kappa_1 <= 1.0f)
    {
        return 0.0f;
    }
    if(kind_2 == 0U)
    {
        if(r_10 <= 1.0f)
        {
            return 1.0f;
        }
        float _S769 = (metal::fast::divide((r_10 * (kappa_1 - 1.0f)), (kappa_1 * (r_10 - 1.0f))));
        return min(_S769, 1.0f);
    }
    if(kappa_1 >= (0.5f * (r_10 + 1.0f)))
    {
        return 1.0f;
    }
    float _S770 = (metal::fast::divide((1.0f), (kappa_1)));
    return 1.0f - _S770;
}

__attribute__((noinline))
float2 damage_increment_0(uint kind_3, float kappa_old_0, float lambda_0, float r_11, float d_old_0, float psi_0)
{
    float _S771 = damage_law_0(kind_3, lambda_0, r_11);
    float _S772 = max(_S771, d_old_0);
    bool _S773;
    if(_S772 <= d_old_0)
    {
        _S773 = true;
    }
    else
    {
        _S773 = d_old_0 >= 1.0f;
    }
    if(_S773)
    {
        return float2(d_old_0, 0.0f);
    }
    float u0_0 = (metal::fast::divide((psi_0), (lambda_0 * lambda_0)));
    float _S774 = max(kappa_old_0, 1.0f);
    if(kind_3 == 0U)
    {
        if(r_11 > 1.0f)
        {
            float _S775 = (metal::fast::divide((u0_0 * r_11), (r_11 - 1.0f)));
            return float2(_S772, _S775 * max(min(lambda_0, r_11) - min(_S774, r_11), 0.0f));
        }
        return float2(_S772, (1.0f - d_old_0) * psi_0);
    }
    float ku_0 = 0.5f * (r_11 + 1.0f);
    float plateau_0 = u0_0 * max(min(lambda_0, ku_0) - min(_S774, ku_0), 0.0f);
    float snap_0;
    if(_S772 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return float2(_S772, plateau_0 + snap_0);
}

void compressed_region_0(float w0_0, float w1_0, float dz_0, float ax_0, float ay_0, array<float, int(6)> thread* region_0)
{
    uint count_5;
    float h0_0 = 0.5f * w0_0;
    float h1_0 = 0.5f * w1_0;
    float _S776 = - h0_0;
    float _S777 = - h1_0;
    array<float2, int(4)> _S778 = { { float2(_S776, _S777), float2(h0_0, _S777), float2(h0_0, h1_0), float2(_S776, h1_0) } };
    thread array<float2, int(8)> poly_0;
    uint i_7 = 0U;
    uint count_6 = 0U;
    for(;;)
    {
        if(i_7 < 4U)
        {
        }
        else
        {
            break;
        }
        uint _S779 = i_7;
        uint _S780 = i_7 + 1U;
        uint _S781 = _S780 % 4U;
        float _S782 = _S778[i_7].y;
        float _S783 = _S778[i_7].x;
        float fp_0 = dz_0 + ax_0 * _S782 - ay_0 * _S783;
        float _S784 = _S778[_S781].y;
        float _S785 = _S778[_S781].x;
        float fq_0 = dz_0 + ax_0 * _S784 - ay_0 * _S785;
        bool _S786 = fp_0 < 0.0f;
        if(_S786)
        {
            uint _S787 = count_6 + 1U;
            poly_0[count_6] = _S778[_S779];
            count_5 = _S787;
        }
        else
        {
            count_5 = count_6;
        }
        if(_S786 != (fq_0 < 0.0f))
        {
            float t_12 = fp_0 / (fp_0 - fq_0);
            uint _S788 = count_5 + 1U;
            poly_0[count_5] = float2(_S783 + t_12 * (_S785 - _S783), _S782 + t_12 * (_S784 - _S782));
            count_6 = _S788;
        }
        else
        {
            count_6 = count_5;
        }
        i_7 = _S780;
    }
    count_5 = 0U;
    for(;;)
    {
        if(count_5 < 6U)
        {
        }
        else
        {
            break;
        }
        (*region_0)[count_5] = 0.0f;
        count_5 = count_5 + 1U;
    }
    if(count_6 < 3U)
    {
        return;
    }
    float2 o_1 = poly_0[int(0)];
    i_7 = 0U;
    float a_11 = 0.0f;
    float sx_0 = 0.0f;
    float sy_0 = 0.0f;
    float ixx_0 = 0.0f;
    float iyy_0 = 0.0f;
    float ixy_0 = 0.0f;
    for(;;)
    {
        if(i_7 < count_6)
        {
        }
        else
        {
            break;
        }
        float _S789 = o_1.x;
        float x0_0 = poly_0[i_7].x - _S789;
        float _S790 = o_1.y;
        float y0_0 = poly_0[i_7].y - _S790;
        uint _S791 = i_7 + 1U;
        uint _S792 = _S791 % count_6;
        float x1_0 = poly_0[_S792].x - _S789;
        float y1_0 = poly_0[_S792].y - _S790;
        float _S793 = x0_0 * y1_0;
        float _S794 = x1_0 * y0_0;
        float cr_0 = _S793 - _S794;
        float a_12 = a_11 + cr_0 / 2.0f;
        float sx_1 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        float sy_1 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        float ixx_1 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        float iyy_1 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        float ixy_1 = ixy_0 + (_S793 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S794) * cr_0 / 24.0f;
        i_7 = _S791;
        a_11 = a_12;
        sx_0 = sx_1;
        sy_0 = sy_1;
        ixx_0 = ixx_1;
        iyy_0 = iyy_1;
        ixy_0 = ixy_1;
    }
    if(a_11 <= 0.0f)
    {
        return;
    }
    float cx_0 = sx_0 / a_11;
    float cy_0 = sy_0 / a_11;
    (*region_0)[int(0)] = a_11;
    (*region_0)[int(1)] = o_1.x + cx_0;
    (*region_0)[int(2)] = o_1.y + cy_0;
    float _S795 = a_11 * cx_0;
    (*region_0)[int(3)] = ixx_0 - _S795 * cx_0;
    (*region_0)[int(4)] = iyy_0 - a_11 * cy_0 * cy_0;
    (*region_0)[int(5)] = ixy_0 - _S795 * cy_0;
    return;
}

__attribute__((noinline))
float4 no_tension_patch_0(float kn_0, float w0_1, float w1_1, float dz_1, float ax_1, float ay_1)
{
    thread array<float, int(6)> r_12;
    compressed_region_0(w0_1, w1_1, dz_1, ax_1, ay_1, &r_12);
    float a_13 = r_12[int(0)];
    if((r_12[int(0)]) == 0.0f)
    {
        return float4(0.0f) ;
    }
    float k_14 = kn_0 / (w0_1 * w1_1);
    float fc_2 = dz_1 + ax_1 * r_12[int(2)] - ay_1 * r_12[int(1)];
    float _S796 = a_13 * fc_2;
    float _S797 = - ay_1;
    return float4(k_14 * a_13 * fc_2, k_14 * (_S796 * r_12[int(2)] + (_S797 * r_12[int(5)] + ax_1 * r_12[int(4)])), - k_14 * (_S796 * r_12[int(1)] + (_S797 * r_12[int(3)] + ax_1 * r_12[int(5)])), 0.5f * k_14 * (_S796 * fc_2 + ay_1 * ay_1 * r_12[int(3)] + ax_1 * ax_1 * r_12[int(4)] - 2.0f * ax_1 * ay_1 * r_12[int(5)]));
}

float signum_0(float x_14)
{
    float _S798;
    if(((as_type<uint>((x_14))) & 2147483648U) != 0U)
    {
        _S798 = -1.0f;
    }
    else
    {
        _S798 = 1.0f;
    }
    return _S798;
}

float2 return_map_0(float k_15, float total_2, float plastic_0, float cap_0)
{
    float trial_0 = k_15 * (total_2 - plastic_0);
    if((abs(trial_0)) <= cap_0)
    {
        return float2(trial_0, 0.0f);
    }
    float f_9 = cap_0 * signum_0(trial_0);
    float _S799 = (metal::fast::divide((trial_0 - f_9), (k_15)));
    return float2(f_9, _S799);
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
Contact_0 contact_part_0(const JointMaterial_0 constant* mat_4, const JointBond_natural_0 thread* b_27, float crush_2, float3 plastic_2, float3 d_lin_0, float3 d_ang_0)
{
    thread Contact_0 c_20;
    float3 _S800 = float3(0.0f) ;
    (&c_20)->q_lin_1 = _S800;
    (&c_20)->q_ang_1 = _S800;
    (&c_20)->energy_2 = 0.0f;
    (&c_20)->diss_2 = 0.0f;
    (&c_20)->plastic_1 = plastic_2;
    uint _S801 = mat_4->kind_flags_0.y;
    if((_S801 & 2U) == 0U)
    {
        return c_20;
    }
    float4 _S802 = float4(b_27->stiff0_0) ;
    float kn_1 = _S802.x;
    float ks_0 = _S802.y;
    float kt_0 = (float4(b_27->stiff1_0) ).x;
    float4 _S803 = float4(b_27->geom0_0) ;
    float w0_2 = _S803.y;
    float w1_2 = _S803.z;
    float diss_3;
    float nc_sum_0;
    float m1_0;
    float m2_0;
    float energy_3;
    if((_S801 & 4U) != 0U)
    {
        float4 p_13 = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        float _S804 = p_13.y;
        float _S805 = p_13.z;
        float _S806 = p_13.w;
        nc_sum_0 = p_13.x;
        m1_0 = _S804;
        m2_0 = _S805;
        energy_3 = _S806;
    }
    else
    {
        float ki_0 = kn_1 * (1.0f - crush_2) / 36.0f;
        float _S807 = d_ang_0.x;
        float _S808 = d_ang_0.y;
        float spread_0 = abs(_S807) * 0.4166666567325592f * w1_2 + abs(_S808) * 0.4166666567325592f * w0_2;
        float _S809 = d_lin_0.z;
        float slack_0 = 9.99999997475242708e-07f * (abs(_S809) + spread_0);
        if((_S809 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S809 + spread_0) < (- slack_0))
            {
                float i1_0 = 2.91666650772094727f * w0_2 * w0_2;
                float i2_0 = 2.91666650772094727f * w1_2 * w1_2;
                float _S810 = ki_0 * _S807 * i2_0;
                float _S811 = ki_0 * _S808 * i1_0;
                float _S812 = 0.5f * ki_0 * (36.0f * _S809 * _S809 + _S807 * _S807 * i2_0 + _S808 * _S808 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S809;
                m1_0 = _S810;
                m2_0 = _S811;
                energy_3 = _S812;
            }
            else
            {
                uint i_8 = 0U;
                diss_3 = 0.0f;
                float m1_1 = 0.0f;
                float m2_1 = 0.0f;
                float energy_4 = 0.0f;
                for(;;)
                {
                    if(i_8 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float _S813 = SPRING_AT_0[i_8] * w0_2;
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
                        float di_0 = _S809 + _S807 * s2_0 - _S808 * _S813;
                        if(di_0 < 0.0f)
                        {
                            float f_10 = ki_0 * di_0;
                            float m1_2 = m1_0 + f_10 * s2_0;
                            float m2_2 = m2_0 - f_10 * _S813;
                            float energy_5 = energy_3 + 0.5f * ki_0 * di_0 * di_0;
                            nc_sum_0 = nc_sum_0 + f_10;
                            m1_0 = m1_2;
                            m2_0 = m2_2;
                            energy_3 = energy_5;
                        }
                        j_7 = j_7 + 1U;
                    }
                    i_8 = i_8 + 1U;
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
    thread float3 p_14 = plastic_2;
    (&c_20)->q_lin_1 = float3(0.0f, 0.0f, nc_sum_0);
    (&c_20)->q_ang_1 = float3(m1_0, m2_0, 0.0f);
    float slide_cap_0 = mat_4->strength_0.w * nc_0;
    float _S814 = ks_0 * (d_lin_0.x - plastic_2.x);
    float _S815 = ks_0 * (d_lin_0.y - plastic_2.y);
    float tn_0 = (metal::fast::sqrt((_S814 * _S814 + _S815 * _S815)));
    bool _S816;
    if(tn_0 > slide_cap_0)
    {
        _S816 = tn_0 > 0.0f;
    }
    else
    {
        _S816 = false;
    }
    if(_S816)
    {
        float _S817 = (metal::fast::divide((_S814), (tn_0)));
        float _S818 = (metal::fast::divide((_S815), (tn_0)));
        float dslip_0 = (metal::fast::divide((tn_0 - slide_cap_0), (ks_0)));
        p_14.x = p_14.x + _S817 * dslip_0;
        p_14.y = p_14.y + _S818 * dslip_0;
        (&c_20)->q_lin_1.x = _S817 * slide_cap_0;
        (&c_20)->q_lin_1.y = _S818 * slide_cap_0;
        diss_3 = slide_cap_0 * dslip_0;
    }
    else
    {
        (&c_20)->q_lin_1.x = _S814;
        (&c_20)->q_lin_1.y = _S815;
        diss_3 = 0.0f;
    }
    float2 tq_0 = return_map_0(kt_0, d_ang_0.z, p_14.z, slide_cap_0 * (float4(b_27->geom1_0) ).z);
    float _S819 = tq_0.x;
    float _S820 = tq_0.y;
    float diss_4 = diss_3 + abs(_S819) * abs(_S820);
    p_14.z = p_14.z + _S820;
    (&c_20)->q_ang_1.z = _S819;
    float _S821 = (metal::fast::divide((sq_0((&c_20)->q_lin_1.x)), (ks_0)));
    float _S822 = (metal::fast::divide((sq_0((&c_20)->q_lin_1.y)), (ks_0)));
    float _S823 = _S821 + _S822;
    float _S824 = (metal::fast::divide((sq_0(_S819)), (kt_0)));
    (&c_20)->energy_2 = energy_3 + 0.5f * (_S823 + _S824);
    (&c_20)->diss_2 = diss_4;
    (&c_20)->plastic_1 = p_14;
    return c_20;
}

float3 contact_offsets_0(const JointMaterial_0 constant* mat_5, const JointBond_natural_0 thread* b_28, float crush_3, float3 plastic_3, float3 d_lin_1, float3 d_ang_1)
{
    uint _S825 = mat_5->kind_flags_0.y;
    if((_S825 & 2U) == 0U)
    {
        return plastic_3;
    }
    float4 _S826 = float4(b_28->stiff0_0) ;
    float kn_2 = _S826.x;
    float ks_1 = _S826.y;
    float kt_1 = (float4(b_28->stiff1_0) ).x;
    float4 _S827 = float4(b_28->geom0_0) ;
    float w0_3 = _S827.y;
    float w1_3 = _S827.z;
    float nc_sum_1;
    if((_S825 & 4U) != 0U)
    {
        float4 _S828 = no_tension_patch_0(kn_2 * (1.0f - crush_3), w0_3, w1_3, d_lin_1.z, d_ang_1.x, d_ang_1.y);
        nc_sum_1 = _S828.x;
    }
    else
    {
        float ki_1 = kn_2 * (1.0f - crush_3) / 36.0f;
        float _S829 = d_ang_1.x;
        float _S830 = d_ang_1.y;
        float spread_1 = abs(_S829) * 0.4166666567325592f * w1_3 + abs(_S830) * 0.4166666567325592f * w0_3;
        float _S831 = d_lin_1.z;
        float slack_1 = 9.99999997475242708e-07f * (abs(_S831) + spread_1);
        if((_S831 - spread_1) > slack_1)
        {
            nc_sum_1 = 0.0f;
        }
        else
        {
            if((_S831 + spread_1) < (- slack_1))
            {
                nc_sum_1 = ki_1 * 36.0f * _S831;
            }
            else
            {
                uint i_9 = 0U;
                float nc_sum_2 = 0.0f;
                for(;;)
                {
                    if(i_9 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float _S832 = SPRING_AT_0[i_9] * w0_3;
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
                        float di_1 = _S831 + _S829 * (SPRING_AT_0[j_8] * w1_3) - _S830 * _S832;
                        if(di_1 < 0.0f)
                        {
                            nc_sum_1 = nc_sum_1 + ki_1 * di_1;
                        }
                        j_8 = j_8 + 1U;
                    }
                    i_9 = i_9 + 1U;
                    nc_sum_2 = nc_sum_1;
                }
                nc_sum_1 = nc_sum_2;
            }
        }
    }
    float nc_1 = - nc_sum_1;
    thread float3 p_15 = plastic_3;
    float slide_cap_1 = mat_5->strength_0.w * nc_1;
    float _S833 = ks_1 * (d_lin_1.x - plastic_3.x);
    float _S834 = ks_1 * (d_lin_1.y - plastic_3.y);
    float tn_1 = (metal::fast::sqrt((_S833 * _S833 + _S834 * _S834)));
    bool _S835;
    if(tn_1 > slide_cap_1)
    {
        _S835 = tn_1 > 0.0f;
    }
    else
    {
        _S835 = false;
    }
    if(_S835)
    {
        float _S836 = (metal::fast::divide((_S833), (tn_1)));
        float _S837 = (metal::fast::divide((_S834), (tn_1)));
        float dslip_1 = (metal::fast::divide((tn_1 - slide_cap_1), (ks_1)));
        p_15.x = p_15.x + _S836 * dslip_1;
        p_15.y = p_15.y + _S837 * dslip_1;
    }
    float2 tq_1 = return_map_0(kt_1, d_ang_1.z, p_15.z, slide_cap_1 * (float4(b_28->geom1_0) ).z);
    p_15.z = p_15.z + tq_1.y;
    return p_15;
}

float life_rate_0(const JointMaterial_0 constant* mat_6, float s_5)
{
    if(s_5 <= 0.0f)
    {
        return 0.0f;
    }
    float _S838 = mat_6->misc_0.y;
    float _S839 = _S838 + 1.0f;
    float _S840 = (metal::fast::pow((s_5), (_S838)));
    float _S841 = (metal::fast::divide((_S839 * _S840), (mat_6->misc_0.z)));
    return _S841;
}

struct JointResponse_0
{
    float3 force_lin_1;
    float3 force_ang_1;
    JointState_0 state_8;
    float dissipated_2;
    float overshoot_0;
    float stored_3;
    bool disconnected_0;
    float fatigue_before_0;
    Measures_0 measures_0;
};

JointResponse_0 joint_evaluate_0(const JointMaterial_0 constant* mat_7, const JointBond_natural_0 thread* b_29, const JointState_0 thread* state_9, float3 d_lin_2, float3 d_ang_2, float dt_9, bool fracture_1)
{
    float4 _S842 = float4(b_29->stiff0_0) ;
    float kn_3 = _S842.x;
    float ks_2 = _S842.y;
    float kb1_0 = _S842.z;
    float kb2_0 = _S842.w;
    float4 _S843 = float4(b_29->stiff1_0) ;
    float kt_2 = _S843.x;
    bool has_rebar_1 = (_S843.w) != 0.0f;
    uint kind_4 = mat_7->kind_flags_0.x;
    uint flags_2 = mat_7->kind_flags_0.y;
    bool softening_0 = (flags_2 & 1U) != 0U;
    thread JointState_0 st_1 = *state_9;
    bool _S844 = connected_0(state_9, has_rebar_1);
    float3 qe_lin_0 = d_lin_2 * float3(ks_2, ks_2, kn_3);
    float3 qe_ang_0 = d_ang_2 * float3(kb1_0, kb2_0, kt_2);
    Measures_0 _S845 = stress_measures_0(b_29, qe_lin_0, qe_ang_0);
    float _S846 = max(max(_S845.tension_0, _S845.shear_0), _S845.compression_0);
    bool _S847 = dt_9 > 0.0f;
    float dif_1;
    if(_S847)
    {
        float _S848 = (metal::fast::divide((_S846 - (&st_1)->governing_stress_0), (dt_9)));
        float raw_0 = (metal::fast::divide((max(_S848, 0.0f)), (mat_7->misc_0.w)));
        float tau_2 = _S843.z;
        if((flags_2 & 16U) != 0U)
        {
            float _S849 = (metal::fast::divide((dt_9), (tau_2)));
            dif_1 = - expm1_accurate_0(- _S849);
        }
        else
        {
            float _S850 = (metal::fast::divide((dt_9), (tau_2)));
            dif_1 = min(_S850, 1.0f);
        }
        (&st_1)->strain_rate_0 = (&st_1)->strain_rate_0 + (raw_0 - (&st_1)->strain_rate_0) * dif_1;
        (&st_1)->governing_stress_0 = _S846;
    }
    if((flags_2 & 32U) != 0U)
    {
        float _S851 = dif_factor_0(mat_7, (&st_1)->strain_rate_0);
        dif_1 = _S851;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = (float4(b_29->geom1_0) ).w;
    float _S852 = fatigue_factor_0(mat_7, (&st_1)->life_0);
    float multiplier_1 = weibull_0 * dif_1 * _S852;
    thread Measures_0 _S853 = _S845;
    float4 _S854 = failure_indices_0(mat_7, b_29, &_S853, multiplier_1);
    float _S855 = _S854.x;
    float _S856 = _S854.y;
    (&st_1)->utilization_0 = max(max(_S855, _S856), max(_S854.z, _S854.w));
    float _S857 = d_lin_2.x;
    float _S858 = d_lin_2.y;
    float _S859 = ks_2 * (sq_0(_S857) + sq_0(_S858)) + kb1_0 * sq_0(d_ang_2.x) + kb2_0 * sq_0(d_ang_2.y) + kt_2 * sq_0(d_ang_2.z);
    float _S860 = d_lin_2.z;
    bool _S861 = _S860 > 0.0f;
    if(_S861)
    {
        dif_1 = kn_3 * sq_0(_S860);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S859 + dif_1);
    float psi_c_0;
    if(_S860 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_3 * sq_0(_S860);
    }
    else
    {
        psi_c_0 = 0.0f;
    }
    float3 plastic_4 = float3((&st_1)->plastic_x_0, (&st_1)->plastic_y_0, (&st_1)->plastic_t_0);
    float diss_contact_0;
    float psi_contact_0;
    float intact_normal_0;
    float dissipated_3;
    float overshoot_1;
    bool _S862;
    float3 qc_lin_0;
    if(fracture_1)
    {
        bool _S863 = _S855 >= _S856;
        if(_S863)
        {
            diss_contact_0 = _S855;
        }
        else
        {
            diss_contact_0 = _S856;
        }
        uint mode_ts_0;
        if(_S863)
        {
            mode_ts_0 = 1U;
        }
        else
        {
            mode_ts_0 = 2U;
        }
        if(diss_contact_0 > ((&st_1)->kappa_0))
        {
            _S862 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S862 = false;
        }
        if(_S862)
        {
            _S862 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S862 = false;
        }
        uint mode_c_0;
        if(_S862)
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
                float _S864 = (metal::fast::divide((psi_contact_0 * (float4(b_29->geom0_0) ).x * diss_contact_0 * diss_contact_0), (psi_ts_0)));
                intact_normal_0 = _S864;
            }
            else
            {
                intact_normal_0 = 0.0f;
            }
            (&st_1)->ductility_0 = intact_normal_0;
            if(softening_0)
            {
                mode_c_0 = kind_4;
            }
            else
            {
                mode_c_0 = 0U;
            }
            float2 inc_0 = damage_increment_0(mode_c_0, (&st_1)->kappa_0, diss_contact_0, intact_normal_0, (&st_1)->damage_0, psi_ts_0);
            float _S865 = inc_0.x;
            if(_S865 > ((&st_1)->damage_0))
            {
                Contact_0 _S866 = contact_part_0(mat_7, b_29, (&st_1)->crush_1, plastic_4, d_lin_2, d_ang_2);
                float _S867 = max(_S866.energy_2 - (1.0f - (&st_1)->crush_1) * psi_c_0, 0.0f);
                float _S868 = max(inc_0.y - _S867 * (_S865 - (&st_1)->damage_0), 0.0f);
                float _S869 = max((psi_ts_0 - _S867) * (_S865 - (&st_1)->damage_0) - _S868, 0.0f);
                (&st_1)->damage_0 = _S865;
                (&st_1)->mode_0 = mode_ts_0;
                dissipated_3 = _S868;
                overshoot_1 = _S869;
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
        float _S870 = state_9->damage_0;
        if((state_9->damage_0) > 0.0f)
        {
            Contact_0 _S871 = contact_part_0(mat_7, b_29, state_9->crush_1, float3(state_9->plastic_x_0, state_9->plastic_y_0, state_9->plastic_t_0), d_lin_2, d_ang_2);
            qc_lin_0 = qe_ang_0 * float3((1.0f - _S870))  + _S871.q_ang_1 * float3(_S870) ;
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S872 = stress_measures_0(b_29, float3(0.0f, 0.0f, min(qe_lin_0.z, 0.0f)), qc_lin_0);
        thread Measures_0 _S873 = _S872;
        float4 _S874 = failure_indices_0(mat_7, b_29, &_S873, multiplier_1);
        float _S875 = _S874.z;
        float _S876 = _S874.w;
        bool _S877 = _S875 >= _S876;
        if(_S877)
        {
            psi_contact_0 = _S875;
        }
        else
        {
            psi_contact_0 = _S876;
        }
        if(_S877)
        {
            mode_c_0 = 3U;
        }
        else
        {
            mode_c_0 = 4U;
        }
        if(psi_contact_0 > ((&st_1)->kappa_c_0))
        {
            _S862 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S862 = false;
        }
        if(_S862)
        {
            _S862 = psi_c_0 > 0.0f;
        }
        else
        {
            _S862 = false;
        }
        if(_S862)
        {
            if(softening_0)
            {
                float _S878 = (metal::fast::divide((mat_7->energy_1.w * (float4(b_29->geom0_0) ).x * psi_contact_0 * psi_contact_0), (psi_c_0)));
                intact_normal_0 = _S878;
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
                    mode_ts_0 = kind_4;
                }
                law_1 = mode_ts_0;
            }
            float2 inc_1 = damage_increment_0(law_1, (&st_1)->kappa_c_0, psi_contact_0, intact_normal_0, (&st_1)->crush_1, psi_c_0);
            float _S879 = inc_1.x;
            if(_S879 > ((&st_1)->crush_1))
            {
                float _S880 = inc_1.y;
                float dissipated_4 = dissipated_3 + _S880;
                float overshoot_2 = overshoot_1 + max(psi_c_0 * (_S879 - (&st_1)->crush_1) - _S880, 0.0f);
                (&st_1)->crush_1 = _S879;
                (&st_1)->mode_0 = mode_c_0;
                if(_S879 >= 1.0f)
                {
                    _S862 = ((&st_1)->damage_0) < 1.0f;
                }
                else
                {
                    _S862 = false;
                }
                if(_S862)
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
    float3 _S881 = float3(0.0f) ;
    float3 qc_ang_0;
    if(((&st_1)->damage_0) == 0.0f)
    {
        if((flags_2 & 8U) == 0U)
        {
            float3 _S882 = contact_offsets_0(mat_7, b_29, (&st_1)->crush_1, plastic_4, d_lin_2, d_ang_2);
            (&st_1)->plastic_x_0 = _S882.x;
            (&st_1)->plastic_y_0 = _S882.y;
            (&st_1)->plastic_t_0 = _S882.z;
        }
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S881;
        qc_ang_0 = _S881;
        psi_contact_0 = 0.0f;
    }
    else
    {
        Contact_0 _S883 = contact_part_0(mat_7, b_29, (&st_1)->crush_1, plastic_4, d_lin_2, d_ang_2);
        (&st_1)->plastic_x_0 = _S883.plastic_1.x;
        (&st_1)->plastic_y_0 = _S883.plastic_1.y;
        (&st_1)->plastic_t_0 = _S883.plastic_1.z;
        diss_contact_0 = _S883.diss_2;
        qc_lin_0 = _S883.q_lin_1;
        qc_ang_0 = _S883.q_ang_1;
        psi_contact_0 = _S883.energy_2;
    }
    float dissipated_6 = dissipated_3 + dmg_0 * diss_contact_0;
    if(_S861)
    {
        intact_normal_0 = kn_3 * _S860;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_1)->crush_1) * kn_3 * _S860;
    }
    float _S884 = 1.0f - dmg_0;
    float3 force_lin_2 = float3(_S884 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S884 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S884 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3 force_ang_2 = qe_ang_0 * float3(_S884)  + qc_ang_0 * float3(dmg_0) ;
    float stored_4 = _S884 * (psi_ts_0 + (1.0f - (&st_1)->crush_1) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S862 = ((&st_1)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S862 = false;
    }
    float stored_5;
    float3 force_lin_3;
    if(_S862)
    {
        float4 _S885 = float4(b_29->rebar0_0) ;
        float k_axial_0 = _S885.x;
        float k_dowel_0 = _S885.y;
        float yield_force_0 = _S885.z;
        float dowel_capacity_0 = _S885.w;
        float2 nr_0 = return_map_0(k_axial_0, _S860, (&st_1)->rebar_plastic_0, yield_force_0);
        float2 v1_0 = return_map_0(k_dowel_0, _S857, (&st_1)->rebar_slip0_0, dowel_capacity_0);
        float2 v2_0 = return_map_0(k_dowel_0, _S858, (&st_1)->rebar_slip1_0, dowel_capacity_0);
        float _S886 = nr_0.y;
        float _S887 = v1_0.y;
        float _S888 = v2_0.y;
        float work_1 = yield_force_0 * abs(_S886) + dowel_capacity_0 * (abs(_S887) + abs(_S888));
        (&st_1)->rebar_plastic_0 = (&st_1)->rebar_plastic_0 + _S886;
        (&st_1)->rebar_slip0_0 = (&st_1)->rebar_slip0_0 + _S887;
        (&st_1)->rebar_slip1_0 = (&st_1)->rebar_slip1_0 + _S888;
        (&st_1)->rebar_work_0 = (&st_1)->rebar_work_0 + work_1;
        float dissipated_7 = dissipated_6 + work_1;
        float _S889 = nr_0.x;
        float _S890 = (metal::fast::divide((sq_0(_S889)), (k_axial_0)));
        float _S891 = v1_0.x;
        float _S892 = v2_0.x;
        float _S893 = (metal::fast::divide((sq_0(_S891) + sq_0(_S892)), (k_dowel_0)));
        float elastic_0 = 0.5f * (_S890 + _S893);
        if(fracture_1)
        {
            _S862 = ((&st_1)->rebar_work_0) >= ((float4(b_29->rebar1_0) ).x);
        }
        else
        {
            _S862 = false;
        }
        if(_S862)
        {
            (&st_1)->rebar_broken_0 = 1.0f;
            float dissipated_8 = dissipated_7 + elastic_0;
            force_lin_3 = force_lin_2;
            dissipated_3 = dissipated_8;
            stored_5 = stored_4;
        }
        else
        {
            float stored_6 = stored_4 + elastic_0;
            force_lin_3 = force_lin_2 + float3(_S891, _S892, _S889);
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
        _S862 = _S847;
    }
    else
    {
        _S862 = false;
    }
    if(_S862)
    {
        _S862 = (flags_2 & 64U) != 0U;
    }
    else
    {
        _S862 = false;
    }
    if(_S862)
    {
        Measures_0 _S894 = stress_measures_0(b_29, force_lin_3, force_ang_2);
        thread Measures_0 _S895 = _S894;
        float4 _S896 = failure_indices_0(mat_7, b_29, &_S895, weibull_0);
        float _S897 = life_rate_0(mat_7, max(max(_S896.x, _S896.y), _S896.z));
        (&st_1)->life_0 = max((&st_1)->life_0 - _S897 * dt_9, 0.0f);
    }
    (&st_1)->dissipated_0 = (&st_1)->dissipated_0 + dissipated_3;
    thread JointResponse_0 resp_0;
    (&resp_0)->force_lin_1 = force_lin_3;
    (&resp_0)->force_ang_1 = force_ang_2;
    (&resp_0)->state_8 = st_1;
    (&resp_0)->dissipated_2 = dissipated_3;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_3 = stored_5;
    if(_S844)
    {
        thread JointState_0 _S898 = st_1;
        bool _S899 = connected_0(&_S898, has_rebar_1);
        _S862 = !_S899;
    }
    else
    {
        _S862 = false;
    }
    (&resp_0)->disconnected_0 = _S862;
    (&resp_0)->fatigue_before_0 = _S852;
    (&resp_0)->measures_0 = _S845;
    return resp_0;
}

float3 to_local_0(uint _S900, float3 _S901, KernelContext_0 thread* kernelContext_67)
{
    BondStatic_natural_0 device* _S902 = kernelContext_67->bonds_0+_S900;
    return float3(dot(_S901, (float4(_S902->t1_0) ).xyz), dot(_S901, (float4(_S902->t2_0) ).xyz), dot(_S901, (float4(_S902->normal_0) ).xyz));
}

void static_kinematics_0(uint _S903, float3 thread* _S904, float3 thread* _S905, KernelContext_0 thread* kernelContext_68)
{
    BondStatic_natural_0 device* _S906 = kernelContext_68->bonds_0+_S903;
    uint4 _S907 = uint4(_S906->law_0.ids_0) ;
    uint ca_1 = _S907.y;
    uint cb_1 = _S907.z;
    uint _S908 = 4U * cb_1;
    uint _S909 = 4U * ca_1;
    float3 _S910 = (float4(*(kernelContext_68->state_0+_S908)) ).xyz - (float4(*(kernelContext_68->state_0+_S909)) ).xyz;
    uint _S911 = sv_0(cb_1, 21U, kernelContext_68);
    float3 _S912 = (float4(*(kernelContext_68->scratch_0+_S911)) ).xyz;
    uint _S913 = sv_0(ca_1, 21U, kernelContext_68);
    float3 du_0 = _S910 + (_S912 - (float4(*(kernelContext_68->scratch_0+_S913)) ).xyz);
    uint _S914 = _S908 + 1U;
    uint _S915 = _S909 + 1U;
    float3 _S916 = (float4(*(kernelContext_68->state_0+_S914)) ).xyz - (float4(*(kernelContext_68->state_0+_S915)) ).xyz;
    uint _S917 = sv_0(cb_1, 22U, kernelContext_68);
    float3 _S918 = (float4(*(kernelContext_68->scratch_0+_S917)) ).xyz;
    uint _S919 = sv_0(ca_1, 22U, kernelContext_68);
    float3 dth_0 = _S916 + (_S918 - (float4(*(kernelContext_68->scratch_0+_S919)) ).xyz);
    float3 _S920 = to_local_0(_S903, du_0 + (cross((float4(*(kernelContext_68->state_0+_S914)) ).xyz + (float4(*(kernelContext_68->scratch_0+_S917)) ).xyz, (float4(_S906->rb_0) ).xyz) - cross((float4(*(kernelContext_68->state_0+_S915)) ).xyz + (float4(*(kernelContext_68->scratch_0+_S919)) ).xyz, (float4(_S906->ra_0) ).xyz)), kernelContext_68);
    *_S904 = _S920;
    float3 _S921 = to_local_0(_S903, dth_0, kernelContext_68);
    *_S905 = _S921;
    return;
}

JointResponse_0 static_response_0(uint i_10, KernelContext_0 thread* kernelContext_69)
{
    BondStatic_natural_0 device* _S922 = kernelContext_69->bonds_0+i_10;
    thread float3 d_lin_3;
    thread float3 d_ang_3;
    static_kinematics_0(i_10, &d_lin_3, &d_ang_3, kernelContext_69);
    thread JointBond_natural_0 _S923 = _S922->law_0;
    _S923 = _S922->law_0;
    thread JointState_0 _S924 = (kernelContext_69->bond_dyn_0+i_10)->js_0;
    JointResponse_0 _S925 = joint_evaluate_0(&kernelContext_69->materials_0->m_0[(uint4((&_S923)->ids_0) ).x], &_S923, &_S924, d_lin_3, d_ang_3, 0.0f, false);
    return _S925;
}

void gather_loads_0(uint c_21, float3 thread* fi_1, float3 thread* mi_0, KernelContext_0 thread* kernelContext_70)
{
    float3 _S926 = float3(0.0f) ;
    *fi_1 = _S926;
    *mi_0 = _S926;
    uint e_3 = kernelContext_70->index_0[c_21];
    for(;;)
    {
        if(e_3 < (kernelContext_70->index_0)[c_21 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_2 = kernelContext_70->index_0[e_3];
        uint bond_1 = entry_2 >> 1U;
        if((entry_2 & 1U) == 0U)
        {
            uint _S927 = 3U * bond_1;
            *fi_1 = *fi_1 + (float4(*(kernelContext_70->scratch_0+_S927)) ).xyz;
            *mi_0 = *mi_0 + (float4(*(kernelContext_70->scratch_0+(_S927 + 1U))) ).xyz;
        }
        else
        {
            uint _S928 = 3U * bond_1;
            *fi_1 = *fi_1 - (float4(*(kernelContext_70->scratch_0+_S928)) ).xyz;
            *mi_0 = *mi_0 + (float4(*(kernelContext_70->scratch_0+(_S928 + 2U))) ).xyz;
        }
        e_3 = e_3 + 1U;
    }
    return;
}

float bond_load_magnitude2_0(uint c_22, KernelContext_0 thread* kernelContext_71)
{
    uint e_4 = kernelContext_71->index_0[c_22];
    float m_4 = 0.0f;
    for(;;)
    {
        if(e_4 < (kernelContext_71->index_0)[c_22 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_3 = kernelContext_71->index_0[e_4];
        uint _S929 = 3U * (entry_3 >> 1U);
        float3 f_11 = (float4(*(kernelContext_71->scratch_0+_S929)) ).xyz;
        float3 t_13;
        if((entry_3 & 1U) == 0U)
        {
            t_13 = (float4(*(kernelContext_71->scratch_0+(_S929 + 1U))) ).xyz;
        }
        else
        {
            t_13 = (float4(*(kernelContext_71->scratch_0+(_S929 + 2U))) ).xyz;
        }
        float m_5 = m_4 + (dot(f_11, f_11) + dot(t_13, t_13));
        e_4 = e_4 + 1U;
        m_4 = m_5;
    }
    return m_4;
}

uint fixed_mask_0(uint c_23, KernelContext_0 thread* kernelContext_72)
{
    uint support_0 = (uint4((kernelContext_72->chunks_0+c_23)->info_1) ).x;
    uint _S930;
    if(support_0 == 1U)
    {
        _S930 = 63U;
    }
    else
    {
        if(support_0 == 2U)
        {
            _S930 = 7U;
        }
        else
        {
            _S930 = 0U;
        }
    }
    return _S930;
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

void secant_factors_0(const JointBond_natural_0 thread* b_30, const JointState_0 thread* st_2, float3 d_lin_4, float3 thread* f_lin_0, float3 thread* f_ang_0)
{
    float _S931 = st_2->damage_0;
    bool compressed_0 = (d_lin_4.z) < 0.0f;
    float contact_1;
    if(compressed_0)
    {
        contact_1 = _S931;
    }
    else
    {
        contact_1 = 0.0f;
    }
    float _S932 = 1.0f - _S931;
    float _S933 = max(_S932 + contact_1, 9.99999997475242708e-07f);
    float normal_5;
    if(compressed_0)
    {
        normal_5 = max(1.0f - st_2->crush_1, 9.99999997475242708e-07f);
    }
    else
    {
        normal_5 = max(_S932, 9.99999997475242708e-07f);
    }
    *f_lin_0 = float3(_S933, _S933, normal_5);
    *f_ang_0 = float3(_S933) ;
    bool _S934;
    if(((float4(b_30->stiff1_0) ).w) != 0.0f)
    {
        _S934 = (st_2->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S934 = false;
    }
    if(_S934)
    {
        float4 _S935 = float4(b_30->rebar0_0) ;
        float4 _S936 = float4(b_30->stiff0_0) ;
        float _S937 = (metal::fast::divide((_S935.x), (_S936.x)));
        (*f_lin_0).z = (*f_lin_0).z + _S937;
        float _S938 = _S935.y;
        float _S939 = _S936.y;
        float _S940 = (metal::fast::divide((_S938), (_S939)));
        (*f_lin_0).x = (*f_lin_0).x + _S940;
        float _S941 = (metal::fast::divide((_S938), (_S939)));
        (*f_lin_0).y = (*f_lin_0).y + _S941;
    }
    return;
}

uint statics_bond_slot_0(uint i_11, KernelContext_0 thread* kernelContext_73)
{
    return kernelContext_73->params_0->statics_base_0 + 23U * kernelContext_73->params_0->chunk_count_0 + 2U * i_11;
}

void store_inverse_0(uint c_24, const array<float, int(36)> thread* a_14, KernelContext_0 thread* kernelContext_74)
{
    uint j_9;
    float sum_4;
    thread array<float, int(36)> l_5;
    uint k_16 = 0U;
    for(;;)
    {
        if(k_16 < 36U)
        {
        }
        else
        {
            break;
        }
        l_5[k_16] = 0.0f;
        k_16 = k_16 + 1U;
    }
    bool spd_0 = true;
    uint i_12 = 0U;
    for(;;)
    {
        bool _S942;
        if(i_12 < 6U)
        {
            _S942 = spd_0;
        }
        else
        {
            _S942 = false;
        }
        if(_S942)
        {
        }
        else
        {
            break;
        }
        j_9 = 0U;
        for(;;)
        {
            if(j_9 <= i_12)
            {
            }
            else
            {
                break;
            }
            uint _S943 = i_12 * 6U;
            uint _S944 = _S943 + j_9;
            k_16 = 0U;
            sum_4 = (*a_14)[_S944];
            for(;;)
            {
                if(k_16 < j_9)
                {
                }
                else
                {
                    break;
                }
                float sum_5 = sum_4 - l_5[_S943 + k_16] * l_5[j_9 * 6U + k_16];
                k_16 = k_16 + 1U;
                sum_4 = sum_5;
            }
            if(i_12 == j_9)
            {
                if(sum_4 <= 0.0f)
                {
                    spd_0 = false;
                    break;
                }
                l_5[_S943 + i_12] = sqrt(sum_4);
            }
            else
            {
                l_5[_S944] = sum_4 / l_5[j_9 * 6U + j_9];
            }
            j_9 = j_9 + 1U;
        }
        i_12 = i_12 + 1U;
    }
    thread array<float, int(36)> inv_0;
    if(!spd_0)
    {
        k_16 = 0U;
        for(;;)
        {
            if(k_16 < 36U)
            {
            }
            else
            {
                break;
            }
            inv_0[k_16] = 0.0f;
            k_16 = k_16 + 1U;
        }
        k_16 = 0U;
        for(;;)
        {
            if(k_16 < 6U)
            {
            }
            else
            {
                break;
            }
            uint _S945 = k_16 * 6U + k_16;
            float _S946 = (*a_14)[_S945];
            if(((*a_14)[_S945]) > 0.0f)
            {
                sum_4 = 1.0f / _S946;
            }
            else
            {
                sum_4 = 0.0f;
            }
            inv_0[_S945] = sum_4;
            k_16 = k_16 + 1U;
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
            i_12 = 0U;
            for(;;)
            {
                if(i_12 < 6U)
                {
                }
                else
                {
                    break;
                }
                if(i_12 == j_9)
                {
                    sum_4 = 1.0f;
                }
                else
                {
                    sum_4 = 0.0f;
                }
                k_16 = 0U;
                float s_6 = sum_4;
                for(;;)
                {
                    if(k_16 < i_12)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_7 = s_6 - l_5[i_12 * 6U + k_16] * y_3[k_16];
                    k_16 = k_16 + 1U;
                    s_6 = s_7;
                }
                y_3[i_12] = s_6 / l_5[i_12 * 6U + i_12];
                i_12 = i_12 + 1U;
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
                uint i_13 = 5U - ii_2;
                k_16 = i_13 + 1U;
                sum_4 = y_3[i_13];
                for(;;)
                {
                    if(k_16 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_8 = sum_4 - l_5[k_16 * 6U + i_13] * x_15[k_16];
                    k_16 = k_16 + 1U;
                    sum_4 = s_8;
                }
                x_15[i_13] = sum_4 / l_5[i_13 * 6U + i_13];
                ii_2 = ii_2 + 1U;
            }
            uint i_14 = 0U;
            for(;;)
            {
                if(i_14 < 6U)
                {
                }
                else
                {
                    break;
                }
                inv_0[i_14 * 6U + j_9] = x_15[i_14];
                i_14 = i_14 + 1U;
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
        uint _S947 = sv_0(c_24, 12U + j_9, kernelContext_74);
        uint _S948 = 4U * j_9;
        *(kernelContext_74->scratch_0+_S947) = packed_float4(float4(inv_0[_S948], inv_0[_S948 + 1U], inv_0[_S948 + 2U], inv_0[_S948 + 3U])) ;
        j_9 = j_9 + 1U;
    }
    return;
}

void assemble_block_0(uint c_25, KernelContext_0 thread* kernelContext_75)
{
    uint p_16;
    uint r_13;
    thread array<float, int(36)> a_15;
    uint k_17 = 0U;
    for(;;)
    {
        if(k_17 < 36U)
        {
        }
        else
        {
            break;
        }
        a_15[k_17] = 0.0f;
        k_17 = k_17 + 1U;
    }
    uint e_5 = kernelContext_75->index_0[c_25];
    for(;;)
    {
        if(e_5 < (kernelContext_75->index_0)[c_25 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_4 = kernelContext_75->index_0[e_5];
        uint i_15 = entry_4 >> 1U;
        bool _S949 = (entry_4 & 1U) != 0U;
        BondStatic_natural_0 device* _S950 = kernelContext_75->bonds_0+i_15;
        uint _S951 = statics_bond_slot_0(i_15, kernelContext_75);
        float4 _S952 = float4(*(kernelContext_75->scratch_0+_S951)) ;
        float4 _S953 = float4(*(kernelContext_75->scratch_0+(_S951 + 1U))) ;
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
            uint _S954 = p_16 % 3U;
            float3 t_14;
            if(_S954 == 0U)
            {
                t_14 = (float4(_S950->t1_0) ).xyz;
            }
            else
            {
                if(_S954 == 1U)
                {
                    t_14 = (float4(_S950->t2_0) ).xyz;
                }
                else
                {
                    t_14 = (float4(_S950->normal_0) ).xyz;
                }
            }
            bool _S955 = p_16 < 3U;
            float3 row_u_0;
            float3 row_t_0;
            if(_S955)
            {
                if(_S949)
                {
                    row_u_0 = t_14;
                }
                else
                {
                    row_u_0 = - t_14;
                }
                if(_S949)
                {
                    row_t_0 = cross((float4(_S950->rb_0) ).xyz, t_14);
                }
                else
                {
                    row_t_0 = - cross((float4(_S950->ra_0) ).xyz, t_14);
                }
            }
            else
            {
                float3 _S956 = float3(0.0f) ;
                if(_S949)
                {
                    row_u_0 = t_14;
                }
                else
                {
                    row_u_0 = - t_14;
                }
                float3 _S957 = row_u_0;
                row_u_0 = _S956;
                row_t_0 = _S957;
            }
            float kp_0;
            if(_S955)
            {
                kp_0 = _S952[p_16];
            }
            else
            {
                kp_0 = _S953[p_16 - 3U];
            }
            if(kp_0 == 0.0f)
            {
                p_16 = p_16 + 1U;
                continue;
            }
            array<float, int(6)> _S958 = { { row_u_0.x, row_u_0.y, row_u_0.z, row_t_0.x, row_t_0.y, row_t_0.z } };
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
                    a_15[r_13 * 6U + q_14] = a_15[r_13 * 6U + q_14] + kp_0 * _S958[r_13] * _S958[q_14];
                    q_14 = q_14 + 1U;
                }
                r_13 = r_13 + 1U;
            }
            p_16 = p_16 + 1U;
        }
        e_5 = e_5 + 1U;
    }
    uint _S959 = fixed_mask_0(c_25, kernelContext_75);
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
        if((_S959 & (1U << p_16)) != 0U)
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
    thread array<float, int(36)> _S960 = a_15;
    store_inverse_0(c_25, &_S960, kernelContext_75);
    return;
}

float block_get_0(uint c_26, uint i_16, uint j_10, KernelContext_0 thread* kernelContext_76)
{
    uint k_18 = i_16 * 6U + j_10;
    uint _S961 = sv_0(c_26, 12U + k_18 / 4U, kernelContext_76);
    return (*(kernelContext_76->scratch_0+_S961))[k_18 % 4U];
}

void precondition_0(uint c_27, KernelContext_0 thread* kernelContext_77)
{
    uint _S962 = sv_0(c_27, 4U, kernelContext_77);
    float4 _S963 = float4(*(kernelContext_77->scratch_0+_S962)) ;
    uint _S964 = sv_0(c_27, 5U, kernelContext_77);
    float4 _S965 = float4(*(kernelContext_77->scratch_0+_S964)) ;
    array<float, int(6)> _S966 = { { _S963.x, _S963.y, _S963.z, _S965.x, _S965.y, _S965.z } };
    thread array<float, int(6)> z_1;
    uint i_17 = 0U;
    for(;;)
    {
        if(i_17 < 6U)
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
            float _S967 = block_get_0(c_27, i_17, j_11, kernelContext_77);
            float s_10 = s_9 + _S967 * _S966[j_11];
            j_11 = j_11 + 1U;
            s_9 = s_10;
        }
        z_1[i_17] = s_9;
        i_17 = i_17 + 1U;
    }
    uint _S968 = sv_0(c_27, 6U, kernelContext_77);
    *(kernelContext_77->scratch_0+_S968) = packed_float4(float4(z_1[int(0)], z_1[int(1)], z_1[int(2)], 0.0f)) ;
    uint _S969 = sv_0(c_27, 7U, kernelContext_77);
    *(kernelContext_77->scratch_0+_S969) = packed_float4(float4(z_1[int(3)], z_1[int(4)], z_1[int(5)], 0.0f)) ;
    return;
}

void project_displacement_slot_0(uint tid_15, const Island_natural_0 thread* isl_22, uint slot_5, KernelContext_0 thread* kernelContext_78)
{
    uint _S970;
    float3 _S971 = float3(0.0f) ;
    thread float3 p_17 = _S971;
    thread float3 l_6 = _S971;
    uint4 _S972 = uint4(isl_22->range_0) ;
    uint _S973 = _S972.x + tid_15;
    uint c_28 = _S973;
    for(;;)
    {
        uint _S974 = _S972.y;
        _S970 = _S974;
        if(c_28 < _S974)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_natural_0 device* _S975 = kernelContext_78->chunks_0+c_28;
        uint _S976 = sv_0(c_28, slot_5, kernelContext_78);
        float3 u_0 = (float4(*(kernelContext_78->scratch_0+_S976)) ).xyz;
        uint _S977 = sv_0(c_28, slot_5 + 1U, kernelContext_78);
        float3 th_2 = (float4(*(kernelContext_78->scratch_0+_S977)) ).xyz;
        float4 _S978 = float4(_S975->center_0) ;
        float3 r_14 = _S978.xyz - (float4(isl_22->com_0) ).xyz;
        float3 _S979 = float3(_S978.w) ;
        p_17 = p_17 + u_0 * _S979;
        l_6 = l_6 + (cross(r_14, u_0) * _S979 + rows_mul_0(float4(_S975->inertia0_1) , float4(_S975->inertia1_1) , float4(_S975->inertia2_1) , th_2));
        c_28 = c_28 + 256U;
    }
    group_sum3_0(tid_15, &p_17, &l_6, kernelContext_78);
    float4 _S980 = float4(isl_22->com_0) ;
    float3 _S981 = p_17 / float3(_S980.w) ;
    float3 _S982 = rows_mul_0(float4(isl_22->inv0_0) , float4(isl_22->inv1_0) , float4(isl_22->inv2_0) , l_6);
    c_28 = _S973;
    for(;;)
    {
        if(c_28 < _S970)
        {
        }
        else
        {
            break;
        }
        float3 r_15 = (float4((kernelContext_78->chunks_0+c_28)->center_0) ).xyz - _S980.xyz;
        uint _S983 = sv_0(c_28, slot_5, kernelContext_78);
        *(kernelContext_78->scratch_0+_S983) = packed_float4(float4((float4(*(kernelContext_78->scratch_0+_S983)) ).xyz - _S981 - cross(_S982, r_15), 0.0f)) ;
        uint _S984 = sv_0(c_28, slot_5 + 1U, kernelContext_78);
        *(kernelContext_78->scratch_0+_S984) = packed_float4(float4((float4(*(kernelContext_78->scratch_0+_S984)) ).xyz - _S982, 0.0f)) ;
        c_28 = c_28 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    return;
}

uint statics_result_slot_0(uint island_4, KernelContext_0 thread* kernelContext_79)
{
    return kernelContext_79->params_0->statics_base_0 + 23U * kernelContext_79->params_0->chunk_count_0 + 2U * kernelContext_79->params_0->statics_bonds_0 + island_4;
}

float3 to_body_0(uint _S985, float3 _S986, KernelContext_0 thread* kernelContext_80)
{
    BondStatic_natural_0 device* _S987 = kernelContext_80->bonds_0+_S985;
    return (float4(_S987->t1_0) ).xyz * float3(_S986.x)  + (float4(_S987->t2_0) ).xyz * float3(_S986.y)  + (float4(_S987->normal_0) ).xyz * float3(_S986.z) ;
}

void write_bond_loads_0(uint _S988, uint _S989, float3 _S990, float3 _S991, float _S992, KernelContext_0 thread* kernelContext_81)
{
    BondStatic_natural_0 device* _S993 = kernelContext_81->bonds_0+_S989;
    float3 _S994 = to_body_0(_S989, _S990, kernelContext_81);
    float3 _S995 = to_body_0(_S989, _S991, kernelContext_81);
    uint _S996 = 3U * _S988;
    *(kernelContext_81->scratch_0+_S996) = packed_float4(float4(_S994, _S992)) ;
    *(kernelContext_81->scratch_0+(_S996 + 1U)) = packed_float4(float4(_S995 + cross((float4(_S993->ra_0) ).xyz, _S994), 0.0f)) ;
    *(kernelContext_81->scratch_0+(_S996 + 2U)) = packed_float4(float4(- _S995 + cross((float4(_S993->rb_0) ).xyz, - _S994), 0.0f)) ;
    return;
}

void bond_kinematics_0(uint _S997, float3 _S998, float3 _S999, float3 _S1000, float3 _S1001, float3 thread* _S1002, float3 thread* _S1003, KernelContext_0 thread* kernelContext_82)
{
    BondStatic_natural_0 device* _S1004 = kernelContext_82->bonds_0+_S997;
    float3 _S1005 = to_local_0(_S997, _S1000 + cross(_S1001, (float4(_S1004->rb_0) ).xyz) - (_S998 + cross(_S999, (float4(_S1004->ra_0) ).xyz)), kernelContext_82);
    *_S1002 = _S1005;
    float3 _S1006 = to_local_0(_S997, _S1001 - _S999, kernelContext_82);
    *_S1003 = _S1006;
    return;
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

[[kernel]] void island_statics(uint3 group_5 [[threadgroup_position_in_grid]], uint3 thread_5 [[thread_position_in_threadgroup]], Params_0 constant* params_8 [[buffer(0)]], Island_natural_0 device* islands_8 [[buffer(9)]], uint device* index_8 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_8 [[buffer(3)]], packed_float4 device* state_10 [[buffer(6)]], packed_float4 device* scratch_8 [[buffer(8)]], packed_float4 device* contact_state_8 [[buffer(11)]], packed_float4 device* loads_8 [[buffer(5)]], Impactor_natural_0 device* impactors_8 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_8 [[buffer(7)]], BondStatic_natural_0 device* bonds_8 [[buffer(2)]], MaterialTable_0 constant* materials_8 [[buffer(1)]])
{
    uint i_18;
    bool converged_2;
    uint c_29;
    thread KernelContext_0 kernelContext_83;
    (&kernelContext_83)->params_0 = params_8;
    (&kernelContext_83)->islands_0 = islands_8;
    (&kernelContext_83)->index_0 = index_8;
    (&kernelContext_83)->chunks_0 = chunks_8;
    (&kernelContext_83)->state_0 = state_10;
    (&kernelContext_83)->scratch_0 = scratch_8;
    (&kernelContext_83)->contact_state_0 = contact_state_8;
    (&kernelContext_83)->loads_0 = loads_8;
    (&kernelContext_83)->impactors_0 = impactors_8;
    (&kernelContext_83)->bond_dyn_0 = bond_dyn_8;
    (&kernelContext_83)->bonds_0 = bonds_8;
    (&kernelContext_83)->materials_0 = materials_8;
    threadgroup array<float4, int(32)> g_part_a_8;
    (&kernelContext_83)->g_part_a_0 = &g_part_a_8;
    threadgroup array<float4, int(32)> g_part_b_8;
    (&kernelContext_83)->g_part_b_0 = &g_part_b_8;
    threadgroup array<uint, int(5)> g_seen_8;
    (&kernelContext_83)->g_seen_0 = &g_seen_8;
    threadgroup uint g_wide_run_8;
    (&kernelContext_83)->g_wide_run_0 = &g_wide_run_8;
    threadgroup array<uint, int(4096)> g_label_8;
    (&kernelContext_83)->g_label_0 = &g_label_8;
    threadgroup uint g_changed_8;
    (&kernelContext_83)->g_changed_0 = &g_changed_8;
    threadgroup uint g_halt_8;
    (&kernelContext_83)->g_halt_0 = &g_halt_8;
    threadgroup uint g_run_8;
    (&kernelContext_83)->g_run_0 = &g_run_8;
    threadgroup array<uint, int(512)> g_label_narrow_8;
    (&kernelContext_83)->g_label_narrow_0 = &g_label_narrow_8;
    threadgroup uint g_changed_narrow_8;
    (&kernelContext_83)->g_changed_narrow_0 = &g_changed_narrow_8;
    uint tid_16 = thread_5.x;
    uint _S1007 = group_5.x;
    thread Island_natural_0 _S1008 = *(islands_8+_S1007);
    uint4 _S1009 = uint4((&_S1008)->info_0) ;
    uint _S1010 = _S1009.z;
    if((_S1010 & 8U) == 0U)
    {
        return;
    }
    bool free_0 = ((_S1009.x) & 1U) == 0U;
    uint4 _S1011 = uint4((&_S1008)->range_0) ;
    uint c0_1 = _S1011.x;
    uint c1_1 = _S1011.y;
    uint b0_0 = _S1011.z;
    uint _S1012 = _S1011.w;
    uint _S1013 = c0_1 + tid_16;
    uint c_30 = _S1013;
    for(;;)
    {
        if(c_30 < c1_1)
        {
        }
        else
        {
            break;
        }
        uint _S1014 = sv_0(c_30, 21U, &kernelContext_83);
        packed_float4 _S1015 = packed_float4(float4(0.0f) ) ;
        *((&kernelContext_83)->scratch_0+_S1014) = _S1015;
        uint _S1016 = sv_0(c_30, 22U, &kernelContext_83);
        *((&kernelContext_83)->scratch_0+_S1016) = _S1015;
        c_30 = c_30 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    if(free_0)
    {
        project_load_slot_0(tid_16, &_S1008, 0U, &kernelContext_83);
    }
    float _S1017 = island_dot_0(tid_16, c0_1, c1_1, 0U, 0U, &kernelContext_83);
    float _S1018 = max(sqrt(_S1017), 1.00000000317107685e-30f);
    float _S1019 = (&kernelContext_83)->params_0->statics_tol_0;
    uint _S1020 = min((&kernelContext_83)->params_0->statics_cg_0, 20U * (c1_1 - c0_1) * 6U + 200U);
    float previous_1 = 1.00000001504746622e+30f;
    float residual_0 = 0.0f;
    uint newton_0 = 0U;
    uint cg_total_0 = 0U;
    for(;;)
    {
        if(newton_0 < ((&kernelContext_83)->params_0->statics_newton_0))
        {
        }
        else
        {
            converged_2 = false;
            break;
        }
        uint _S1021 = b0_0 + tid_16;
        i_18 = _S1021;
        for(;;)
        {
            if(i_18 < _S1012)
            {
            }
            else
            {
                break;
            }
            JointResponse_0 _S1022 = static_response_0(i_18, &kernelContext_83);
            write_bond_loads_0(i_18, i_18, _S1022.force_lin_1, _S1022.force_ang_1, 0.0f, &kernelContext_83);
            i_18 = i_18 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        float4 _S1023 = float4(0.0f) ;
        thread float4 magnitude_0 = _S1023;
        thread float4 unused_m_0 = _S1023;
        c_30 = _S1013;
        for(;;)
        {
            if(c_30 < c1_1)
            {
            }
            else
            {
                break;
            }
            thread float3 fi_2;
            thread float3 mi_1;
            gather_loads_0(c_30, &fi_2, &mi_1, &kernelContext_83);
            float _S1024 = bond_load_magnitude2_0(c_30, &kernelContext_83);
            magnitude_0.x = magnitude_0.x + _S1024;
            uint _S1025 = sv_0(c_30, 0U, &kernelContext_83);
            thread float4 r_lin_0 = float4((float4(*((&kernelContext_83)->scratch_0+_S1025)) ).xyz + fi_2, 0.0f);
            uint _S1026 = sv_0(c_30, 1U, &kernelContext_83);
            thread float4 r_ang_0 = float4((float4(*((&kernelContext_83)->scratch_0+_S1026)) ).xyz + mi_1, 0.0f);
            uint _S1027 = fixed_mask_0(c_30, &kernelContext_83);
            hold_0(_S1027, &r_lin_0, &r_ang_0, _S1023, _S1023);
            uint _S1028 = sv_0(c_30, 4U, &kernelContext_83);
            *((&kernelContext_83)->scratch_0+_S1028) = packed_float4(r_lin_0) ;
            uint _S1029 = sv_0(c_30, 5U, &kernelContext_83);
            *((&kernelContext_83)->scratch_0+_S1029) = packed_float4(r_ang_0) ;
            c_30 = c_30 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        group_sum2_0(tid_16, &magnitude_0, &unused_m_0, &kernelContext_83);
        if(free_0)
        {
            project_load_slot_0(tid_16, &_S1008, 4U, &kernelContext_83);
        }
        float _S1030 = island_dot_0(tid_16, c0_1, c1_1, 4U, 4U, &kernelContext_83);
        float residual_1 = sqrt(_S1030) / _S1018;
        float _S1031 = max(0.00100000004749745f, 3.83999986297567375e-06f * sqrt(magnitude_0.x) / _S1018);
        if(residual_1 <= _S1019)
        {
            converged_2 = true;
        }
        else
        {
            if(residual_1 <= _S1031)
            {
                converged_2 = residual_1 > (0.5f * previous_1);
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
        uint i_19 = _S1021;
        for(;;)
        {
            if(i_19 < _S1012)
            {
            }
            else
            {
                break;
            }
            BondStatic_natural_0 device* _S1032 = (&kernelContext_83)->bonds_0+i_19;
            thread float3 d_lin_5;
            thread float3 d_ang_4;
            static_kinematics_0(i_19, &d_lin_5, &d_ang_4, &kernelContext_83);
            thread JointBond_natural_0 _S1033 = _S1032->law_0;
            thread JointState_0 _S1034 = ((&kernelContext_83)->bond_dyn_0+i_19)->js_0;
            thread float3 f_lin_1;
            thread float3 f_ang_1;
            secant_factors_0(&_S1033, &_S1034, d_lin_5, &f_lin_1, &f_ang_1);
            float4 _S1035 = float4((&_S1033)->stiff0_0) ;
            uint _S1036 = statics_bond_slot_0(i_19, &kernelContext_83);
            float _S1037 = _S1035.y;
            *((&kernelContext_83)->scratch_0+_S1036) = packed_float4(float4(_S1037 * f_lin_1.x, _S1037 * f_lin_1.y, _S1035.x * f_lin_1.z, 0.0f)) ;
            *((&kernelContext_83)->scratch_0+(_S1036 + 1U)) = packed_float4(float4(_S1035.z * f_ang_1.x, _S1035.w * f_ang_1.y, (float4((&_S1033)->stiff1_0) ).x * f_ang_1.z, 0.0f)) ;
            i_19 = i_19 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_31 = _S1013;
        for(;;)
        {
            if(c_31 < c1_1)
            {
            }
            else
            {
                break;
            }
            assemble_block_0(c_31, &kernelContext_83);
            uint _S1038 = sv_0(c_31, 2U, &kernelContext_83);
            packed_float4 _S1039 = packed_float4(_S1023) ;
            *((&kernelContext_83)->scratch_0+_S1038) = _S1039;
            uint _S1040 = sv_0(c_31, 3U, &kernelContext_83);
            *((&kernelContext_83)->scratch_0+_S1040) = _S1039;
            c_31 = c_31 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_32 = _S1013;
        for(;;)
        {
            if(c_32 < c1_1)
            {
            }
            else
            {
                break;
            }
            precondition_0(c_32, &kernelContext_83);
            c_32 = c_32 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        if(free_0)
        {
            project_displacement_slot_0(tid_16, &_S1008, 6U, &kernelContext_83);
        }
        uint c_33 = _S1013;
        for(;;)
        {
            if(c_33 < c1_1)
            {
            }
            else
            {
                break;
            }
            uint _S1041 = sv_0(c_33, 8U, &kernelContext_83);
            packed_float4 device* _S1042 = (&kernelContext_83)->scratch_0+_S1041;
            uint _S1043 = sv_0(c_33, 6U, &kernelContext_83);
            *_S1042 = packed_float4(float4(*((&kernelContext_83)->scratch_0+_S1043)) ) ;
            uint _S1044 = sv_0(c_33, 9U, &kernelContext_83);
            packed_float4 device* _S1045 = (&kernelContext_83)->scratch_0+_S1044;
            uint _S1046 = sv_0(c_33, 7U, &kernelContext_83);
            *_S1045 = packed_float4(float4(*((&kernelContext_83)->scratch_0+_S1046)) ) ;
            c_33 = c_33 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        float _S1047 = island_dot_0(tid_16, c0_1, c1_1, 4U, 6U, &kernelContext_83);
        float _S1048 = island_dot_0(tid_16, c0_1, c1_1, 4U, 4U, &kernelContext_83);
        float _S1049 = sqrt(_S1048);
        float rz_0 = _S1047;
        uint k_19 = 0U;
        uint cg_total_1 = cg_total_0;
        for(;;)
        {
            bool _S1050;
            if(k_19 < _S1020)
            {
                _S1050 = _S1049 > 0.0f;
            }
            else
            {
                _S1050 = false;
            }
            if(_S1050)
            {
            }
            else
            {
                cg_total_0 = cg_total_1;
                break;
            }
            uint i_20 = _S1021;
            for(;;)
            {
                if(i_20 < _S1012)
                {
                }
                else
                {
                    break;
                }
                uint4 _S1051 = uint4(((&kernelContext_83)->bonds_0+i_20)->law_0.ids_0) ;
                uint ca_2 = _S1051.y;
                uint cb_2 = _S1051.z;
                uint _S1052 = sv_0(ca_2, 8U, &kernelContext_83);
                float3 _S1053 = (float4(*((&kernelContext_83)->scratch_0+_S1052)) ).xyz;
                uint _S1054 = sv_0(ca_2, 9U, &kernelContext_83);
                float3 _S1055 = (float4(*((&kernelContext_83)->scratch_0+_S1054)) ).xyz;
                uint _S1056 = sv_0(cb_2, 8U, &kernelContext_83);
                float3 _S1057 = (float4(*((&kernelContext_83)->scratch_0+_S1056)) ).xyz;
                uint _S1058 = sv_0(cb_2, 9U, &kernelContext_83);
                thread float3 d_lin_6;
                thread float3 d_ang_5;
                bond_kinematics_0(i_20, _S1053, _S1055, _S1057, (float4(*((&kernelContext_83)->scratch_0+_S1058)) ).xyz, &d_lin_6, &d_ang_5, &kernelContext_83);
                uint _S1059 = statics_bond_slot_0(i_20, &kernelContext_83);
                write_bond_loads_0(i_20, i_20, d_lin_6 * (float4(*((&kernelContext_83)->scratch_0+_S1059)) ).xyz, d_ang_5 * (float4(*((&kernelContext_83)->scratch_0+(_S1059 + 1U))) ).xyz, 0.0f, &kernelContext_83);
                i_20 = i_20 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            c_29 = _S1013;
            for(;;)
            {
                if(c_29 < c1_1)
                {
                }
                else
                {
                    break;
                }
                thread float3 fi_3;
                thread float3 mi_2;
                gather_loads_0(c_29, &fi_3, &mi_2, &kernelContext_83);
                thread float4 ap_lin_0 = float4(- fi_3, 0.0f);
                thread float4 ap_ang_0 = float4(- mi_2, 0.0f);
                uint _S1060 = fixed_mask_0(c_29, &kernelContext_83);
                uint _S1061 = sv_0(c_29, 8U, &kernelContext_83);
                float4 _S1062 = float4(*((&kernelContext_83)->scratch_0+_S1061)) ;
                uint _S1063 = sv_0(c_29, 9U, &kernelContext_83);
                hold_0(_S1060, &ap_lin_0, &ap_ang_0, _S1062, float4(*((&kernelContext_83)->scratch_0+_S1063)) );
                uint _S1064 = sv_0(c_29, 10U, &kernelContext_83);
                *((&kernelContext_83)->scratch_0+_S1064) = packed_float4(ap_lin_0) ;
                uint _S1065 = sv_0(c_29, 11U, &kernelContext_83);
                *((&kernelContext_83)->scratch_0+_S1065) = packed_float4(ap_ang_0) ;
                c_29 = c_29 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            float _S1066 = island_dot_0(tid_16, c0_1, c1_1, 8U, 10U, &kernelContext_83);
            uint _S1067 = cg_total_1 + 1U;
            if(_S1066 <= 0.0f)
            {
                cg_total_0 = _S1067;
                break;
            }
            float _S1068 = rz_0 / _S1066;
            uint c_34 = _S1013;
            for(;;)
            {
                if(c_34 < c1_1)
                {
                }
                else
                {
                    break;
                }
                uint _S1069 = sv_0(c_34, 2U, &kernelContext_83);
                packed_float4 device* _S1070 = (&kernelContext_83)->scratch_0+_S1069;
                float3 _S1071 = (float4(*((&kernelContext_83)->scratch_0+_S1069)) ).xyz;
                uint _S1072 = sv_0(c_34, 8U, &kernelContext_83);
                float3 _S1073 = float3(_S1068) ;
                *_S1070 = packed_float4(float4(_S1071 + _S1073 * (float4(*((&kernelContext_83)->scratch_0+_S1072)) ).xyz, 0.0f)) ;
                uint _S1074 = sv_0(c_34, 3U, &kernelContext_83);
                packed_float4 device* _S1075 = (&kernelContext_83)->scratch_0+_S1074;
                float3 _S1076 = (float4(*((&kernelContext_83)->scratch_0+_S1074)) ).xyz;
                uint _S1077 = sv_0(c_34, 9U, &kernelContext_83);
                *_S1075 = packed_float4(float4(_S1076 + _S1073 * (float4(*((&kernelContext_83)->scratch_0+_S1077)) ).xyz, 0.0f)) ;
                uint _S1078 = sv_0(c_34, 4U, &kernelContext_83);
                packed_float4 device* _S1079 = (&kernelContext_83)->scratch_0+_S1078;
                float3 _S1080 = (float4(*((&kernelContext_83)->scratch_0+_S1078)) ).xyz;
                uint _S1081 = sv_0(c_34, 10U, &kernelContext_83);
                *_S1079 = packed_float4(float4(_S1080 - _S1073 * (float4(*((&kernelContext_83)->scratch_0+_S1081)) ).xyz, 0.0f)) ;
                uint _S1082 = sv_0(c_34, 5U, &kernelContext_83);
                packed_float4 device* _S1083 = (&kernelContext_83)->scratch_0+_S1082;
                float3 _S1084 = (float4(*((&kernelContext_83)->scratch_0+_S1082)) ).xyz;
                uint _S1085 = sv_0(c_34, 11U, &kernelContext_83);
                *_S1083 = packed_float4(float4(_S1084 - _S1073 * (float4(*((&kernelContext_83)->scratch_0+_S1085)) ).xyz, 0.0f)) ;
                c_34 = c_34 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            float _S1086 = island_dot_0(tid_16, c0_1, c1_1, 4U, 4U, &kernelContext_83);
            if((sqrt(_S1086)) <= (0.00009999999747379f * _S1049))
            {
                cg_total_0 = _S1067;
                break;
            }
            uint c_35 = _S1013;
            for(;;)
            {
                if(c_35 < c1_1)
                {
                }
                else
                {
                    break;
                }
                precondition_0(c_35, &kernelContext_83);
                c_35 = c_35 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            if(free_0)
            {
                project_displacement_slot_0(tid_16, &_S1008, 6U, &kernelContext_83);
            }
            float _S1087 = island_dot_0(tid_16, c0_1, c1_1, 4U, 6U, &kernelContext_83);
            float _S1088 = _S1087 / rz_0;
            uint c_36 = _S1013;
            for(;;)
            {
                if(c_36 < c1_1)
                {
                }
                else
                {
                    break;
                }
                uint _S1089 = sv_0(c_36, 8U, &kernelContext_83);
                packed_float4 device* _S1090 = (&kernelContext_83)->scratch_0+_S1089;
                uint _S1091 = sv_0(c_36, 6U, &kernelContext_83);
                float3 _S1092 = float3(_S1088) ;
                *_S1090 = packed_float4(float4((float4(*((&kernelContext_83)->scratch_0+_S1091)) ).xyz + _S1092 * (float4(*((&kernelContext_83)->scratch_0+_S1089)) ).xyz, 0.0f)) ;
                uint _S1093 = sv_0(c_36, 9U, &kernelContext_83);
                packed_float4 device* _S1094 = (&kernelContext_83)->scratch_0+_S1093;
                uint _S1095 = sv_0(c_36, 7U, &kernelContext_83);
                *_S1094 = packed_float4(float4((float4(*((&kernelContext_83)->scratch_0+_S1095)) ).xyz + _S1092 * (float4(*((&kernelContext_83)->scratch_0+_S1093)) ).xyz, 0.0f)) ;
                c_36 = c_36 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            uint _S1096 = k_19 + 1U;
            rz_0 = _S1087;
            k_19 = _S1096;
            cg_total_1 = _S1067;
        }
        c_29 = _S1013;
        for(;;)
        {
            if(c_29 < c1_1)
            {
            }
            else
            {
                break;
            }
            uint _S1097 = 4U * c_29;
            thread float3 u_1 = (float4(*((&kernelContext_83)->state_0+_S1097)) ).xyz;
            uint _S1098 = sv_0(c_29, 21U, &kernelContext_83);
            thread float3 u_lo_0 = (float4(*((&kernelContext_83)->scratch_0+_S1098)) ).xyz;
            uint _S1099 = _S1097 + 1U;
            thread float3 th_3 = (float4(*((&kernelContext_83)->state_0+_S1099)) ).xyz;
            uint _S1100 = sv_0(c_29, 22U, &kernelContext_83);
            thread float3 th_lo_0 = (float4(*((&kernelContext_83)->scratch_0+_S1100)) ).xyz;
            uint _S1101 = sv_0(c_29, 2U, &kernelContext_83);
            comp_add_0(&u_1, &u_lo_0, (float4(*((&kernelContext_83)->scratch_0+_S1101)) ).xyz);
            uint _S1102 = sv_0(c_29, 3U, &kernelContext_83);
            comp_add_0(&th_3, &th_lo_0, (float4(*((&kernelContext_83)->scratch_0+_S1102)) ).xyz);
            *((&kernelContext_83)->state_0+_S1097) = packed_float4(float4(u_1, (float4(*((&kernelContext_83)->state_0+_S1097)) ).w)) ;
            *((&kernelContext_83)->state_0+_S1099) = packed_float4(float4(th_3, (float4(*((&kernelContext_83)->state_0+_S1099)) ).w)) ;
            *((&kernelContext_83)->scratch_0+_S1098) = packed_float4(float4(u_lo_0, 0.0f)) ;
            *((&kernelContext_83)->scratch_0+_S1100) = packed_float4(float4(th_lo_0, 0.0f)) ;
            c_29 = c_29 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint _S1103 = newton_0 + 1U;
        previous_1 = residual_1;
        residual_0 = residual_1;
        newton_0 = _S1103;
    }
    i_18 = b0_0 + tid_16;
    for(;;)
    {
        if(i_18 < _S1012)
        {
        }
        else
        {
            break;
        }
        JointResponse_0 _S1104 = static_response_0(i_18, &kernelContext_83);
        BondDyn_natural_0 device* _S1105 = (&kernelContext_83)->bond_dyn_0+i_18;
        float4 _S1106 = float4((*_S1105).force_lin_0) ;
        float4 _S1107 = float4((*_S1105).force_ang_0) ;
        float4 _S1108 = float4((*_S1105).sums_0) ;
        float4 _S1109 = float4((*_S1105).comps_0) ;
        uint4 _S1110 = uint4((*_S1105).events_0) ;
        thread BondDyn_0 bd_0;
        (&bd_0)->js_0 = (*_S1105).js_0;
        (&bd_0)->force_lin_0 = _S1106;
        (&bd_0)->force_ang_0 = _S1107;
        (&bd_0)->sums_0 = _S1108;
        (&bd_0)->comps_0 = _S1109;
        (&bd_0)->events_0 = _S1110;
        (&bd_0)->force_lin_0 = float4(_S1104.force_lin_1, _S1104.stored_3);
        (&bd_0)->force_ang_0 = float4(_S1104.force_ang_1, (&bd_0)->force_ang_0.w);
        BondDyn_natural_0 device* _S1111 = (&kernelContext_83)->bond_dyn_0+i_18;
        _S1111->js_0 = bd_0.js_0;
        _S1111->force_lin_0 = packed_float4(bd_0.force_lin_0) ;
        _S1111->force_ang_0 = packed_float4(bd_0.force_ang_0) ;
        _S1111->sums_0 = packed_float4(bd_0.sums_0) ;
        _S1111->comps_0 = packed_float4(bd_0.comps_0) ;
        _S1111->events_0 = packed_uint4(bd_0.events_0) ;
        write_bond_loads_0(i_18, i_18, _S1104.force_lin_1, _S1104.force_ang_1, max(_S1104.measures_0.tension_0, _S1104.measures_0.compression_0), &kernelContext_83);
        i_18 = i_18 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    c_30 = _S1013;
    for(;;)
    {
        if(c_30 < c1_1)
        {
        }
        else
        {
            break;
        }
        thread float3 fi_4;
        thread float3 mi_3;
        gather_loads_0(c_30, &fi_4, &mi_3, &kernelContext_83);
        uint _S1112 = fixed_mask_0(c_30, &kernelContext_83);
        float3 reaction_0;
        if(_S1112 != 0U)
        {
            uint _S1113 = sv_0(c_30, 0U, &kernelContext_83);
            reaction_0 = - ((float4(*((&kernelContext_83)->scratch_0+_S1113)) ).xyz + fi_4);
        }
        else
        {
            uint _S1114 = 4U * c_30;
            reaction_0 = float3((float4(*((&kernelContext_83)->state_0+(_S1114 + 1U))) ).w, (float4(*((&kernelContext_83)->state_0+(_S1114 + 2U))) ).w, (float4(*((&kernelContext_83)->state_0+(_S1114 + 3U))) ).w);
        }
        uint _S1115 = 4U * c_30;
        uint _S1116 = _S1115 + 1U;
        *((&kernelContext_83)->state_0+_S1116) = packed_float4(float4((float4(*((&kernelContext_83)->state_0+_S1116)) ).xyz, reaction_0.x)) ;
        *((&kernelContext_83)->state_0+(_S1115 + 2U)) = packed_float4(float4(0.0f, 0.0f, 0.0f, reaction_0.y)) ;
        *((&kernelContext_83)->state_0+(_S1115 + 3U)) = packed_float4(float4(0.0f, 0.0f, 0.0f, reaction_0.z)) ;
        c_30 = c_30 + 256U;
    }
    if(tid_16 == 0U)
    {
        uint _S1117 = statics_result_slot_0(_S1007, &kernelContext_83);
        packed_float4 device* _S1118 = (&kernelContext_83)->scratch_0+_S1117;
        float _S1119 = (as_type<float>((newton_0)));
        float _S1120 = (as_type<float>((cg_total_0)));
        if(converged_2)
        {
            previous_1 = 1.0f;
        }
        else
        {
            previous_1 = 0.0f;
        }
        *_S1118 = packed_float4(float4(residual_0, _S1119, _S1120, previous_1)) ;
        ((&kernelContext_83)->islands_0+_S1007)->info_0[int(2)] = _S1010 & 4294967287U;
    }
    return;
}

bool is_damaged_0(const JointState_0 thread* st_3)
{
    bool _S1121;
    if((st_3->damage_0) > 0.0f)
    {
        _S1121 = true;
    }
    else
    {
        _S1121 = (st_3->crush_1) > 0.0f;
    }
    return _S1121;
}

[[kernel]] void settled_fatigue(uint3 group_6 [[threadgroup_position_in_grid]], uint3 thread_6 [[thread_position_in_threadgroup]], Params_0 constant* params_9 [[buffer(0)]], Island_natural_0 device* islands_9 [[buffer(9)]], uint device* index_9 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_9 [[buffer(3)]], packed_float4 device* state_11 [[buffer(6)]], packed_float4 device* scratch_9 [[buffer(8)]], packed_float4 device* contact_state_9 [[buffer(11)]], packed_float4 device* loads_9 [[buffer(5)]], Impactor_natural_0 device* impactors_9 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_9 [[buffer(7)]], BondStatic_natural_0 device* bonds_9 [[buffer(2)]], MaterialTable_0 constant* materials_9 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_84;
    (&kernelContext_84)->params_0 = params_9;
    (&kernelContext_84)->islands_0 = islands_9;
    (&kernelContext_84)->index_0 = index_9;
    (&kernelContext_84)->chunks_0 = chunks_9;
    (&kernelContext_84)->state_0 = state_11;
    (&kernelContext_84)->scratch_0 = scratch_9;
    (&kernelContext_84)->contact_state_0 = contact_state_9;
    (&kernelContext_84)->loads_0 = loads_9;
    (&kernelContext_84)->impactors_0 = impactors_9;
    (&kernelContext_84)->bond_dyn_0 = bond_dyn_9;
    (&kernelContext_84)->bonds_0 = bonds_9;
    (&kernelContext_84)->materials_0 = materials_9;
    threadgroup array<float4, int(32)> g_part_a_9;
    (&kernelContext_84)->g_part_a_0 = &g_part_a_9;
    threadgroup array<float4, int(32)> g_part_b_9;
    (&kernelContext_84)->g_part_b_0 = &g_part_b_9;
    threadgroup array<uint, int(5)> g_seen_9;
    (&kernelContext_84)->g_seen_0 = &g_seen_9;
    threadgroup uint g_wide_run_9;
    (&kernelContext_84)->g_wide_run_0 = &g_wide_run_9;
    threadgroup array<uint, int(4096)> g_label_9;
    (&kernelContext_84)->g_label_0 = &g_label_9;
    threadgroup uint g_changed_9;
    (&kernelContext_84)->g_changed_0 = &g_changed_9;
    threadgroup uint g_halt_9;
    (&kernelContext_84)->g_halt_0 = &g_halt_9;
    threadgroup uint g_run_9;
    (&kernelContext_84)->g_run_0 = &g_run_9;
    threadgroup array<uint, int(512)> g_label_narrow_9;
    (&kernelContext_84)->g_label_narrow_0 = &g_label_narrow_9;
    threadgroup uint g_changed_narrow_9;
    (&kernelContext_84)->g_changed_narrow_0 = &g_changed_narrow_9;
    uint tid_17 = thread_6.x;
    uint _S1122 = group_6.x;
    Island_natural_0 device* _S1123 = islands_9+_S1122;
    Island_natural_0 isl_23 = *_S1123;
    uint4 _S1124 = uint4((*_S1123).info_0) ;
    bool _S1125;
    if(((_S1124.x) & 16U) == 0U)
    {
        _S1125 = true;
    }
    else
    {
        uint4 _S1126 = uint4(isl_23.range_0) ;
        _S1125 = (_S1126.w) == (_S1126.z);
    }
    if(_S1125)
    {
        return;
    }
    seen_clear_0(tid_17, &kernelContext_84);
    if(tid_17 == 0U)
    {
        *(&kernelContext_84)->g_halt_0 = 0U;
        *(&kernelContext_84)->g_run_0 = 0U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    uint _S1127 = _S1124.w;
    uint4 _S1128 = uint4(isl_23.range_0) ;
    uint i_21 = _S1128.z + tid_17;
    for(;;)
    {
        if(i_21 < (_S1128.w))
        {
        }
        else
        {
            break;
        }
        BondStatic_natural_0 device* _S1129 = (&kernelContext_84)->bonds_0+i_21;
        BondDyn_natural_0 device* _S1130 = (&kernelContext_84)->bond_dyn_0+i_21;
        float4 _S1131 = float4((*_S1130).force_lin_0) ;
        float4 _S1132 = float4((*_S1130).force_ang_0) ;
        float4 _S1133 = float4((*_S1130).sums_0) ;
        float4 _S1134 = float4((*_S1130).comps_0) ;
        uint4 _S1135 = uint4((*_S1130).events_0) ;
        thread BondDyn_0 bd_1;
        (&bd_1)->js_0 = (*_S1130).js_0;
        (&bd_1)->force_lin_0 = _S1131;
        (&bd_1)->force_ang_0 = _S1132;
        (&bd_1)->sums_0 = _S1133;
        (&bd_1)->comps_0 = _S1134;
        (&bd_1)->events_0 = _S1135;
        thread JointBond_natural_0 _S1136 = _S1129->law_0;
        uint4 _S1137 = uint4((&_S1136)->ids_0) ;
        uint _S1138 = 4U * _S1137.y;
        uint _S1139 = 4U * _S1137.z;
        thread float3 d_lin_7;
        thread float3 d_ang_6;
        bond_kinematics_0(i_21, (float4(*((&kernelContext_84)->state_0+_S1138)) ).xyz, (float4(*((&kernelContext_84)->state_0+(_S1138 + 1U))) ).xyz, (float4(*((&kernelContext_84)->state_0+_S1139)) ).xyz, (float4(*((&kernelContext_84)->state_0+(_S1139 + 1U))) ).xyz, &d_lin_7, &d_ang_6, &kernelContext_84);
        JointState_0 previous_2 = (&bd_1)->js_0;
        float _S1140 = (&kernelContext_84)->params_0->dt_0;
        bool _S1141 = ((&kernelContext_84)->params_0->fracture_0) != 0U;
        _S1136 = _S1129->law_0;
        thread JointState_0 _S1142 = (&bd_1)->js_0;
        JointResponse_0 _S1143 = joint_evaluate_0(&(&kernelContext_84)->materials_0->m_0[_S1137.x], &_S1136, &_S1142, d_lin_7, d_ang_6, _S1140, _S1141);
        if((_S1143.state_8.damage_0) > (previous_2.damage_0 + 9.99999971718068537e-10f))
        {
            _S1125 = true;
        }
        else
        {
            _S1125 = (_S1143.state_8.crush_1) > (previous_2.crush_1 + 9.99999971718068537e-10f);
        }
        uint flags_3;
        if(_S1125)
        {
            flags_3 = 16U;
        }
        else
        {
            flags_3 = 0U;
        }
        thread float _S1144 = (&bd_1)->sums_0.x;
        thread float _S1145 = (&bd_1)->comps_0.x;
        comp_add1_0(&_S1144, &_S1145, _S1143.dissipated_2);
        (&bd_1)->comps_0.x = _S1145;
        (&bd_1)->sums_0.x = _S1144;
        thread float _S1146 = (&bd_1)->sums_0.y;
        thread float _S1147 = (&bd_1)->comps_0.y;
        comp_add1_0(&_S1146, &_S1147, _S1143.overshoot_0);
        (&bd_1)->comps_0.y = _S1147;
        (&bd_1)->sums_0.y = _S1146;
        (&bd_1)->force_lin_0 = float4(_S1143.force_lin_1, _S1143.stored_3);
        (&bd_1)->force_ang_0 = float4(_S1143.force_ang_1, max((&bd_1)->force_ang_0.w, _S1143.state_8.utilization_0));
        thread JointState_0 _S1148 = previous_2;
        bool _S1149 = is_damaged_0(&_S1148);
        bool _S1150;
        if(!_S1149)
        {
            thread JointState_0 _S1151 = _S1143.state_8;
            bool _S1152 = is_damaged_0(&_S1151);
            _S1150 = _S1152;
        }
        else
        {
            _S1150 = false;
        }
        bool _S1153;
        if(_S1150)
        {
            _S1153 = ((&bd_1)->events_0.x) == 0U;
        }
        else
        {
            _S1153 = false;
        }
        if(_S1153)
        {
            (&bd_1)->events_0.x = _S1127;
            (&bd_1)->events_0.w = _S1143.state_8.mode_0;
            (*(&kernelContext_84)->g_seen_0)[3U] = 1U;
        }
        bool _S1154;
        if(((&bd_1)->events_0.y) == 0U)
        {
            _S1154 = (_S1143.state_8.life_0) != (previous_2.life_0);
        }
        else
        {
            _S1154 = false;
        }
        bool _S1155;
        if(_S1154)
        {
            _S1155 = (_S1143.fatigue_before_0) > 0.99000000953674316f;
        }
        else
        {
            _S1155 = false;
        }
        bool _S1156;
        if(_S1155)
        {
            float _S1157 = fatigue_factor_0(&(&kernelContext_84)->materials_0->m_0[_S1137.x], _S1143.state_8.life_0);
            _S1156 = _S1157 <= 0.99000000953674316f;
        }
        else
        {
            _S1156 = false;
        }
        if(_S1156)
        {
            (&bd_1)->events_0.y = _S1127;
            (*(&kernelContext_84)->g_seen_0)[4U] = 1U;
        }
        uint flags_4;
        if(_S1143.disconnected_0)
        {
            (&bd_1)->events_0.z = _S1127;
            flags_4 = flags_3 | 32U;
        }
        else
        {
            flags_4 = flags_3;
        }
        (&bd_1)->js_0 = _S1143.state_8;
        BondDyn_natural_0 device* _S1158 = (&kernelContext_84)->bond_dyn_0+i_21;
        _S1158->js_0 = bd_1.js_0;
        _S1158->force_lin_0 = packed_float4(bd_1.force_lin_0) ;
        _S1158->force_ang_0 = packed_float4(bd_1.force_ang_0) ;
        _S1158->sums_0 = packed_float4(bd_1.sums_0) ;
        _S1158->comps_0 = packed_float4(bd_1.comps_0) ;
        _S1158->events_0 = packed_uint4(bd_1.events_0) ;
        write_bond_loads_0(i_21, i_21, _S1143.force_lin_1, _S1143.force_ang_1, max(_S1143.measures_0.tension_0, _S1143.measures_0.compression_0), &kernelContext_84);
        if((flags_4 & 16U) != 0U)
        {
            *(&kernelContext_84)->g_halt_0 = 1U;
        }
        if((flags_4 & 32U) != 0U)
        {
            *(&kernelContext_84)->g_run_0 = 1U;
        }
        i_21 = i_21 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    if(tid_17 != 0U)
    {
        return;
    }
    if(((*(&kernelContext_84)->g_halt_0) | (*(&kernelContext_84)->g_run_0)) != 0U)
    {
        uint _S1159 = _S1124.z;
        if((*(&kernelContext_84)->g_halt_0) != 0U)
        {
            i_21 = 16U;
        }
        else
        {
            i_21 = 0U;
        }
        uint _S1160 = _S1159 | i_21;
        if((*(&kernelContext_84)->g_run_0) != 0U)
        {
            i_21 = 32U;
        }
        else
        {
            i_21 = 0U;
        }
        ((&kernelContext_84)->islands_0+_S1122)->info_0[int(2)] = _S1160 | i_21;
    }
    uint _S1161 = (isl_23.coverage_0) | 16384U;
    uint _S1162 = seen_bits_0(&kernelContext_84);
    uint _S1163 = _S1161 | _S1162;
    if((*(&kernelContext_84)->g_run_0) != 0U)
    {
        i_21 = 128U;
    }
    else
    {
        i_21 = 0U;
    }
    ((&kernelContext_84)->islands_0+_S1122)->coverage_0 = _S1163 | i_21;
    return;
}

void impactor_integrate_at_0(uint ii_3, uint tid_18, KernelContext_0 thread* kernelContext_85)
{
    float3 p_18;
    if(ii_3 >= (kernelContext_85->params_0->impactor_count_0))
    {
        return;
    }
    Island_natural_0 device* _S1164 = kernelContext_85->islands_0+kernelContext_85->params_0->halt_index_0;
    Impactor_natural_0 device* _S1165 = kernelContext_85->impactors_0+ii_3;
    float4 _S1166 = float4((*_S1165).position_err_1) ;
    float4 _S1167 = float4((*_S1165).velocity_1) ;
    float4 _S1168 = float4((*_S1165).velocity_err_1) ;
    float4 _S1169 = float4((*_S1165).angular_velocity_1) ;
    float4 _S1170 = float4((*_S1165).rotation_1) ;
    float4 _S1171 = float4((*_S1165).inertia0_2) ;
    float4 _S1172 = float4((*_S1165).inertia1_2) ;
    float4 _S1173 = float4((*_S1165).inertia2_2) ;
    float4 _S1174 = float4((*_S1165).inv0_2) ;
    float4 _S1175 = float4((*_S1165).inv1_2) ;
    float4 _S1176 = float4((*_S1165).inv2_2) ;
    float4 _S1177 = float4((*_S1165).shape_0) ;
    float4 _S1178 = float4((*_S1165).half_1) ;
    float4 _S1179 = float4((*_S1165).mat_0) ;
    float4 _S1180 = float4((*_S1165).crush_0) ;
    float4 _S1181 = float4((*_S1165).geom_0) ;
    float4 _S1182 = float4((*_S1165).rotation_err_1) ;
    float4 _S1183 = float4((*_S1165).ledger_0) ;
    uint4 _S1184 = uint4((*_S1165).cand_0) ;
    float4 _S1185 = float4((*_S1165).momentum_1) ;
    float4 _S1186 = float4((*_S1165).momentum_err_1) ;
    thread Impactor_0 imp_6;
    (&imp_6)->position_1 = float4((*_S1165).position_1) ;
    (&imp_6)->position_err_1 = _S1166;
    (&imp_6)->velocity_1 = _S1167;
    (&imp_6)->velocity_err_1 = _S1168;
    (&imp_6)->angular_velocity_1 = _S1169;
    (&imp_6)->rotation_1 = _S1170;
    (&imp_6)->inertia0_2 = _S1171;
    (&imp_6)->inertia1_2 = _S1172;
    (&imp_6)->inertia2_2 = _S1173;
    (&imp_6)->inv0_2 = _S1174;
    (&imp_6)->inv1_2 = _S1175;
    (&imp_6)->inv2_2 = _S1176;
    (&imp_6)->shape_0 = _S1177;
    (&imp_6)->half_1 = _S1178;
    (&imp_6)->mat_0 = _S1179;
    (&imp_6)->crush_0 = _S1180;
    (&imp_6)->geom_0 = _S1181;
    (&imp_6)->rotation_err_1 = _S1182;
    (&imp_6)->ledger_0 = _S1183;
    (&imp_6)->cand_0 = _S1184;
    (&imp_6)->momentum_1 = _S1185;
    (&imp_6)->momentum_err_1 = _S1186;
    uint4 _S1187 = uint4(_S1164->info_0) ;
    bool _S1188;
    if(((_S1187.z) & 1U) != 0U)
    {
        _S1188 = true;
    }
    else
    {
        uint _S1189 = _S1187.y;
        if(_S1189 != 0U)
        {
            _S1188 = ((&imp_6)->cand_0.w) >= _S1189;
        }
        else
        {
            _S1188 = false;
        }
    }
    if(_S1188)
    {
        return;
    }
    if(((&imp_6)->cand_0.z) != 0U)
    {
        if(tid_18 == 0U)
        {
            (kernelContext_85->impactors_0+ii_3)->cand_0[int(3)] = (&imp_6)->cand_0.w + 1U;
        }
        return;
    }
    float4 _S1190 = float4(0.0f) ;
    thread float4 rf_1 = _S1190;
    thread float4 rt_0 = _S1190;
    uint k_20 = (&imp_6)->cand_0.x + tid_18;
    for(;;)
    {
        if(k_20 < ((&imp_6)->cand_0.y))
        {
        }
        else
        {
            break;
        }
        uint _S1191 = 3U * k_20;
        rf_1 = rf_1 + float4(*(kernelContext_85->scratch_0+(kernelContext_85->params_0->cand_base_0 + _S1191 + 1U))) ;
        rt_0 = rt_0 + float4(*(kernelContext_85->scratch_0+(kernelContext_85->params_0->cand_base_0 + _S1191 + 2U))) ;
        k_20 = k_20 + 256U;
    }
    group_sum2_0(tid_18, &rf_1, &rt_0, kernelContext_85);
    if(tid_18 != 0U)
    {
        return;
    }
    float dt_10 = kernelContext_85->params_0->dt_0;
    float3 _S1192 = float3(0.0f) ;
    float3 load_f_0;
    float3 load_t_0;
    if((kernelContext_85->params_0->has_ground_0) != 0U)
    {
        float3 _S1193 = (&imp_6)->half_1.xyz;
        thread Impactor_0 _S1194 = imp_6;
        Box_0 _S1195 = impactor_box_0(&_S1194, _S1192, _S1193);
        float3 _S1196 = (&imp_6)->velocity_1.xyz + (&imp_6)->velocity_err_1.xyz;
        float _S1197 = kernelContext_85->params_0->ground_modulus_0;
        float _S1198 = (&imp_6)->mat_0.x;
        float3 _S1199 = float3(0.0f, 0.0f, 1.0f);
        thread Box_0 _S1200 = _S1195;
        thread Box_0 _S1201 = _S1195;
        float _S1202 = contact_stiffness_0(_S1197, &_S1200, _S1198, &_S1201, _S1199);
        float _S1203 = (&imp_6)->position_1.z - kernelContext_85->params_0->ground_hi_0 + ((&imp_6)->position_err_1.z - kernelContext_85->params_0->ground_lo_0);
        uint total_points_0;
        if(((&imp_6)->shape_0.x) == 0.0f)
        {
            total_points_0 = 1U;
        }
        else
        {
            total_points_0 = 14U;
        }
        float _S1204 = _S1202 / float(min(total_points_0, 5U));
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
                thread Box_0 _S1205 = _S1195;
                float3 _S1206 = sample_point_0(&_S1205, s_11, kernelContext_85);
                p_18 = _S1206;
            }
            if((_S1203 + p_18.z) < 0.0f)
            {
                below_0 = below_0 + 1U;
            }
            s_11 = s_11 + 1U;
        }
        if(below_0 > 0U)
        {
            sentinel_mark_0(8U, kernelContext_85);
        }
        s_11 = 0U;
        load_f_0 = _S1192;
        load_t_0 = _S1192;
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
                thread Box_0 _S1207 = _S1195;
                float3 _S1208 = sample_point_0(&_S1207, s_11, kernelContext_85);
                p_18 = _S1208;
            }
            float depth_4 = - (_S1203 + p_18.z);
            if(depth_4 <= 0.0f)
            {
                s_11 = s_11 + 1U;
                continue;
            }
            thread float stored_7;
            thread float diss_5;
            float3 _S1209 = penalty_force_0(_S1204, (&imp_6)->mat_0.z, kernelContext_85->params_0->ground_friction_0, depth_4, _S1199, _S1196 + cross((&imp_6)->angular_velocity_1.xyz, p_18), dt_10, below_0, &stored_7, &diss_5, kernelContext_85);
            float3 load_f_1 = load_f_0 + _S1209;
            float3 load_t_1 = load_t_0 + cross(p_18, _S1209);
            thread float _S1210 = (&imp_6)->ledger_0.x;
            thread float _S1211 = (&imp_6)->ledger_0.y;
            comp_add1_0(&_S1210, &_S1211, diss_5);
            (&imp_6)->ledger_0.y = _S1211;
            (&imp_6)->ledger_0.x = _S1210;
            load_f_0 = load_f_1;
            load_t_0 = load_t_1;
            s_11 = s_11 + 1U;
        }
    }
    else
    {
        load_f_0 = _S1192;
        load_t_0 = _S1192;
    }
    float3 load_f_2 = rf_1.xyz + load_f_0;
    float3 load_t_2 = rt_0.xyz + load_t_0;
    float m_6 = (&imp_6)->mat_0.z;
    thread float3 vel_3 = (&imp_6)->velocity_1.xyz;
    thread float3 vel_err_1 = (&imp_6)->velocity_err_1.xyz;
    float3 _S1212 = float3(dt_10) ;
    comp_add_0(&vel_3, &vel_err_1, (load_f_2 / float3(m_6)  + kernelContext_85->params_0->gravity_0.xyz) * _S1212);
    Quat_0 _S1213 = quat_of_0((&imp_6)->rotation_1);
    thread Quat_0 q_15 = _S1213;
    thread float4 q_err_0 = (&imp_6)->rotation_err_1;
    thread float3 l_hi_0 = (&imp_6)->momentum_1.xyz;
    thread float3 l_err_1 = (&imp_6)->momentum_err_1.xyz;
    comp_add_0(&l_hi_0, &l_err_1, load_t_2 * _S1212);
    float3 l_7 = l_hi_0 + l_err_1;
    thread Quat_0 _S1214 = _S1213;
    float3 _S1215 = world_mul_0(&_S1214, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_7);
    thread float3 pos_1 = (&imp_6)->position_1.xyz;
    thread float3 pos_err_1 = (&imp_6)->position_err_1.xyz;
    comp_add_0(&pos_1, &pos_err_1, (vel_3 + vel_err_1) * _S1212);
    turn_left_0(&q_15, &q_err_0, _S1215, dt_10);
    thread Quat_0 _S1216 = q_15;
    float3 _S1217 = world_mul_0(&_S1216, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_7);
    (&imp_6)->angular_velocity_1 = float4(_S1217, 0.0f);
    thread Quat_0 _S1218 = q_15;
    float4 _S1219 = quat_vec_0(&_S1218);
    (&imp_6)->rotation_1 = _S1219;
    (&imp_6)->rotation_err_1 = q_err_0;
    (&imp_6)->momentum_1 = float4(l_hi_0, 0.0f);
    (&imp_6)->momentum_err_1 = float4(l_err_1, 0.0f);
    (&imp_6)->position_1 = float4(pos_1, 0.0f);
    (&imp_6)->position_err_1 = float4(pos_err_1, 0.0f);
    (&imp_6)->velocity_1 = float4(vel_3, 0.0f);
    (&imp_6)->velocity_err_1 = float4(vel_err_1, 0.0f);
    (&imp_6)->cand_0.w = (&imp_6)->cand_0.w + 1U;
    (&imp_6)->geom_0 = float4(1.0f, (&imp_6)->crush_0.w, 0.0f, 0.0f);
    Impactor_natural_0 device* _S1220 = kernelContext_85->impactors_0+ii_3;
    _S1220->position_1 = packed_float4(imp_6.position_1) ;
    _S1220->position_err_1 = packed_float4(imp_6.position_err_1) ;
    _S1220->velocity_1 = packed_float4(imp_6.velocity_1) ;
    _S1220->velocity_err_1 = packed_float4(imp_6.velocity_err_1) ;
    _S1220->angular_velocity_1 = packed_float4(imp_6.angular_velocity_1) ;
    _S1220->rotation_1 = packed_float4(imp_6.rotation_1) ;
    _S1220->inertia0_2 = packed_float4(imp_6.inertia0_2) ;
    _S1220->inertia1_2 = packed_float4(imp_6.inertia1_2) ;
    _S1220->inertia2_2 = packed_float4(imp_6.inertia2_2) ;
    _S1220->inv0_2 = packed_float4(imp_6.inv0_2) ;
    _S1220->inv1_2 = packed_float4(imp_6.inv1_2) ;
    _S1220->inv2_2 = packed_float4(imp_6.inv2_2) ;
    _S1220->shape_0 = packed_float4(imp_6.shape_0) ;
    _S1220->half_1 = packed_float4(imp_6.half_1) ;
    _S1220->mat_0 = packed_float4(imp_6.mat_0) ;
    _S1220->crush_0 = packed_float4(imp_6.crush_0) ;
    _S1220->geom_0 = packed_float4(imp_6.geom_0) ;
    _S1220->rotation_err_1 = packed_float4(imp_6.rotation_err_1) ;
    _S1220->ledger_0 = packed_float4(imp_6.ledger_0) ;
    _S1220->cand_0 = packed_uint4(imp_6.cand_0) ;
    _S1220->momentum_1 = packed_float4(imp_6.momentum_1) ;
    _S1220->momentum_err_1 = packed_float4(imp_6.momentum_err_1) ;
    uint k_21 = (&imp_6)->cand_0.w - 1U - kernelContext_85->params_0->step_start_0;
    if(k_21 < (kernelContext_85->params_0->record_stride_0))
    {
        uint at_8 = kernelContext_85->params_0->record_base_0 + 2U * (ii_3 * kernelContext_85->params_0->record_stride_0 + k_21);
        *(kernelContext_85->scratch_0+at_8) = packed_float4(float4(vel_3 + vel_err_1, 0.0f)) ;
        *(kernelContext_85->scratch_0+(at_8 + 1U)) = packed_float4(float4(pos_1 + pos_err_1, 0.0f)) ;
    }
    return;
}

[[kernel]] void impactor_integrate(uint3 group_7 [[threadgroup_position_in_grid]], uint3 thread_7 [[thread_position_in_threadgroup]], Params_0 constant* params_10 [[buffer(0)]], Island_natural_0 device* islands_10 [[buffer(9)]], uint device* index_10 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_10 [[buffer(3)]], packed_float4 device* state_12 [[buffer(6)]], packed_float4 device* scratch_10 [[buffer(8)]], packed_float4 device* contact_state_10 [[buffer(11)]], packed_float4 device* loads_10 [[buffer(5)]], Impactor_natural_0 device* impactors_10 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_10 [[buffer(7)]], BondStatic_natural_0 device* bonds_10 [[buffer(2)]], MaterialTable_0 constant* materials_10 [[buffer(1)]])
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
    (&kernelContext_86)->bond_dyn_0 = bond_dyn_10;
    (&kernelContext_86)->bonds_0 = bonds_10;
    (&kernelContext_86)->materials_0 = materials_10;
    threadgroup array<float4, int(32)> g_part_a_10;
    (&kernelContext_86)->g_part_a_0 = &g_part_a_10;
    threadgroup array<float4, int(32)> g_part_b_10;
    (&kernelContext_86)->g_part_b_0 = &g_part_b_10;
    threadgroup array<uint, int(5)> g_seen_10;
    (&kernelContext_86)->g_seen_0 = &g_seen_10;
    threadgroup uint g_wide_run_10;
    (&kernelContext_86)->g_wide_run_0 = &g_wide_run_10;
    threadgroup array<uint, int(4096)> g_label_10;
    (&kernelContext_86)->g_label_0 = &g_label_10;
    threadgroup uint g_changed_10;
    (&kernelContext_86)->g_changed_0 = &g_changed_10;
    threadgroup uint g_halt_10;
    (&kernelContext_86)->g_halt_0 = &g_halt_10;
    threadgroup uint g_run_10;
    (&kernelContext_86)->g_run_0 = &g_run_10;
    threadgroup array<uint, int(512)> g_label_narrow_10;
    (&kernelContext_86)->g_label_narrow_0 = &g_label_narrow_10;
    threadgroup uint g_changed_narrow_10;
    (&kernelContext_86)->g_changed_narrow_0 = &g_changed_narrow_10;
    impactor_integrate_at_0(group_7.x, thread_7.x, &kernelContext_86);
    return;
}

void ground_contact_0(uint c_37, bool account_0, float3 thread* f_12, float3 thread* t_15, KernelContext_0 thread* kernelContext_87)
{
    ChunkStatic_natural_0 device* _S1221 = kernelContext_87->chunks_0+c_37;
    WorldPoint_0 _S1222 = chunk_world_0(c_37, kernelContext_87);
    float above_0 = _S1222.hi_0.z - kernelContext_87->params_0->ground_hi_0 + (_S1222.lo_0.z - kernelContext_87->params_0->ground_lo_0) + _S1222.rel_0.z;
    if((above_0 - (float4(_S1221->half_0) ).w) > 0.0f)
    {
        return;
    }
    Box_0 _S1223 = chunk_box_0(c_37, float3(0.0f) , kernelContext_87);
    float _S1224 = kernelContext_87->params_0->ground_modulus_0;
    float _S1225 = (float4(_S1221->cmat_0) ).x;
    float3 _S1226 = float3(0.0f, 0.0f, 1.0f);
    thread Box_0 _S1227 = _S1223;
    thread Box_0 _S1228 = _S1223;
    float _S1229 = contact_stiffness_0(_S1224, &_S1227, _S1225, &_S1228, _S1226);
    thread Box_0 _S1230 = _S1223;
    uint _S1231 = sample_count_0(&_S1230);
    uint s_12 = 0U;
    uint n_11 = 0U;
    for(;;)
    {
        if(s_12 < _S1231)
        {
        }
        else
        {
            break;
        }
        thread Box_0 _S1232 = _S1223;
        float3 _S1233 = sample_point_0(&_S1232, s_12, kernelContext_87);
        if((above_0 + _S1233.z) < 0.0f)
        {
            n_11 = n_11 + 1U;
        }
        s_12 = s_12 + 1U;
    }
    if(n_11 == 0U)
    {
        return;
    }
    sentinel_mark_0(4U, kernelContext_87);
    thread float3 vc_1;
    thread float3 wc_1;
    chunk_velocity_0(c_37, &vc_1, &wc_1, kernelContext_87);
    thread float4 ledger_2 = float4(*(kernelContext_87->scratch_0+(kernelContext_87->params_0->ledger_base_0 + kernelContext_87->params_0->pair_count_0 + c_37))) ;
    s_12 = 0U;
    for(;;)
    {
        if(s_12 < _S1231)
        {
        }
        else
        {
            break;
        }
        thread Box_0 _S1234 = _S1223;
        float3 _S1235 = sample_point_0(&_S1234, s_12, kernelContext_87);
        float _S1236 = above_0 + _S1235.z;
        if(!(_S1236 < 0.0f))
        {
            s_12 = s_12 + 1U;
            continue;
        }
        thread float stored_8;
        thread float diss_6;
        float3 _S1237 = penalty_force_0(_S1229 / float(max(n_11, 5U)), (float4(_S1221->center_0) ).w, kernelContext_87->params_0->ground_friction_0, - _S1236, _S1226, vc_1 + cross(wc_1, _S1235), kernelContext_87->params_0->dt_0, n_11, &stored_8, &diss_6, kernelContext_87);
        *f_12 = *f_12 + _S1237;
        *t_15 = *t_15 + cross(_S1235, _S1237);
        thread float _S1238 = ledger_2.y;
        thread float _S1239 = ledger_2.z;
        comp_add1_0(&_S1238, &_S1239, diss_6);
        ledger_2.z = _S1239;
        ledger_2.y = _S1238;
        s_12 = s_12 + 1U;
    }
    if(account_0)
    {
        *(kernelContext_87->scratch_0+(kernelContext_87->params_0->ledger_base_0 + kernelContext_87->params_0->pair_count_0 + c_37)) = packed_float4(ledger_2) ;
    }
    return;
}

void contact_sum_at_0(uint g_2, KernelContext_0 thread* kernelContext_88)
{
    bool _S1240;
    if(g_2 >= (kernelContext_88->params_0->seg_count_0))
    {
        _S1240 = true;
    }
    else
    {
        bool _S1241 = stopped_0(kernelContext_88);
        _S1240 = _S1241;
    }
    if(_S1240)
    {
        return;
    }
    uint _S1242 = 3U * g_2;
    uint _S1243 = kernelContext_88->index_0[kernelContext_88->params_0->seg_index_0 + _S1242];
    uint begin_1 = kernelContext_88->index_0[kernelContext_88->params_0->seg_index_0 + _S1242 + 1U];
    uint _S1244 = kernelContext_88->index_0[kernelContext_88->params_0->seg_index_0 + _S1242 + 2U];
    float3 _S1245 = float3(0.0f) ;
    thread float3 f_13 = _S1245;
    thread float3 t_16 = _S1245;
    uint e_6 = begin_1;
    for(;;)
    {
        if(e_6 < _S1244)
        {
        }
        else
        {
            break;
        }
        uint entry_5 = kernelContext_88->index_0[e_6];
        if(entry_5 == 2147483648U)
        {
            ground_contact_0(_S1243, true, &f_13, &t_16, kernelContext_88);
            e_6 = e_6 + 1U;
            continue;
        }
        uint _S1246 = 2U * entry_5;
        f_13 = f_13 + (float4(*(kernelContext_88->scratch_0+(kernelContext_88->params_0->slot_base_0 + _S1246))) ).xyz;
        t_16 = t_16 + (float4(*(kernelContext_88->scratch_0+(kernelContext_88->params_0->slot_base_0 + _S1246 + 1U))) ).xyz;
        e_6 = e_6 + 1U;
    }
    uint _S1247 = 2U * g_2;
    *(kernelContext_88->scratch_0+(kernelContext_88->params_0->seg_base_0 + _S1247)) = packed_float4(float4(f_13, 0.0f)) ;
    *(kernelContext_88->scratch_0+(kernelContext_88->params_0->seg_base_0 + _S1247 + 1U)) = packed_float4(float4(t_16, 0.0f)) ;
    return;
}

[[kernel]] void contact_sums(uint3 id_2 [[thread_position_in_grid]], Params_0 constant* params_11 [[buffer(0)]], Island_natural_0 device* islands_11 [[buffer(9)]], uint device* index_11 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_11 [[buffer(3)]], packed_float4 device* state_13 [[buffer(6)]], packed_float4 device* scratch_11 [[buffer(8)]], packed_float4 device* contact_state_11 [[buffer(11)]], packed_float4 device* loads_11 [[buffer(5)]], Impactor_natural_0 device* impactors_11 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_11 [[buffer(7)]], BondStatic_natural_0 device* bonds_11 [[buffer(2)]], MaterialTable_0 constant* materials_11 [[buffer(1)]])
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
    (&kernelContext_89)->bond_dyn_0 = bond_dyn_11;
    (&kernelContext_89)->bonds_0 = bonds_11;
    (&kernelContext_89)->materials_0 = materials_11;
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
    threadgroup array<uint, int(512)> g_label_narrow_11;
    (&kernelContext_89)->g_label_narrow_0 = &g_label_narrow_11;
    threadgroup uint g_changed_narrow_11;
    (&kernelContext_89)->g_changed_narrow_0 = &g_changed_narrow_11;
    contact_sum_at_0(id_2.x, &kernelContext_89);
    return;
}

void net_load_0(uint c_38, const Island_natural_0 thread* isl_24, const Rigid_0 thread* rg_12, uint k_22, float dt_11, bool contact_2, float3 thread* f_14, float3 thread* t_17, KernelContext_0 thread* kernelContext_90)
{
    ChunkStatic_natural_0 device* _S1248 = kernelContext_90->chunks_0+c_38;
    thread float3 fl_0;
    thread float3 tl_0;
    thread float3 rep_f_0;
    thread float3 rep_m_0;
    chunk_loads_0(c_38, c_38, &rg_12->rot_1, k_22, dt_11, contact_2, 0.0f, &fl_0, &tl_0, &rep_f_0, &rep_m_0, kernelContext_90);
    float4 _S1249 = float4(_S1248->center_0) ;
    float3 fc_3 = fl_0 + kernelContext_90->params_0->gravity_0.xyz * float3(_S1249.w) ;
    float3 _S1250 = _S1249.xyz;
    float3 _S1251 = (float4(isl_24->com_0) ).xyz;
    float3 _S1252 = rotate_0(&rg_12->rot_1, _S1250 + (float4(*(kernelContext_90->state_0+4U * c_38)) ).xyz - _S1251);
    *f_14 = *f_14 + fc_3;
    *t_17 = *t_17 + (cross(_S1252, fc_3) + tl_0);
    uint4 _S1253 = uint4(_S1248->load_range_0) ;
    if((_S1253.y) > (_S1253.x))
    {
        float3 _S1254 = rotate_0(&rg_12->rot_1, rep_f_0);
        *f_14 = *f_14 + _S1254;
        float3 _S1255 = rotate_0(&rg_12->rot_1, _S1250 - _S1251);
        float3 _S1256 = cross(_S1255, _S1254);
        float3 _S1257 = rotate_0(&rg_12->rot_1, rep_m_0);
        *t_17 = *t_17 + (_S1256 + _S1257);
    }
    return;
}

void net_load_1(uint c_39, const Island_0 thread* isl_25, const Rigid_0 thread* rg_13, uint k_23, float dt_12, bool contact_3, float3 thread* f_15, float3 thread* t_18, KernelContext_0 thread* kernelContext_91)
{
    ChunkStatic_natural_0 device* _S1258 = kernelContext_91->chunks_0+c_39;
    thread float3 fl_1;
    thread float3 tl_1;
    thread float3 rep_f_1;
    thread float3 rep_m_1;
    chunk_loads_0(c_39, c_39, &rg_13->rot_1, k_23, dt_12, contact_3, 0.0f, &fl_1, &tl_1, &rep_f_1, &rep_m_1, kernelContext_91);
    float4 _S1259 = float4(_S1258->center_0) ;
    float3 fc_4 = fl_1 + kernelContext_91->params_0->gravity_0.xyz * float3(_S1259.w) ;
    float3 _S1260 = _S1259.xyz;
    float3 _S1261 = isl_25->com_0.xyz;
    float3 _S1262 = rotate_0(&rg_13->rot_1, _S1260 + (float4(*(kernelContext_91->state_0+4U * c_39)) ).xyz - _S1261);
    *f_15 = *f_15 + fc_4;
    *t_18 = *t_18 + (cross(_S1262, fc_4) + tl_1);
    uint4 _S1263 = uint4(_S1258->load_range_0) ;
    if((_S1263.y) > (_S1263.x))
    {
        float3 _S1264 = rotate_0(&rg_13->rot_1, rep_f_1);
        *f_15 = *f_15 + _S1264;
        float3 _S1265 = rotate_0(&rg_13->rot_1, _S1260 - _S1261);
        float3 _S1266 = cross(_S1265, _S1264);
        float3 _S1267 = rotate_0(&rg_13->rot_1, rep_m_1);
        *t_18 = *t_18 + (_S1266 + _S1267);
    }
    return;
}

bool bond_update_0(uint i_22, float dt_13, bool fracture_2, uint abs_step_0, bool wide_0, KernelContext_0 thread* kernelContext_92)
{
    BondStatic_natural_0 device* _S1268 = kernelContext_92->bonds_0+i_22;
    uint4 _S1269 = uint4(_S1268->law_0.ids_0) ;
    float3 ra_1 = (float4(_S1268->ra_0) ).xyz;
    float3 rb_1 = (float4(_S1268->rb_0) ).xyz;
    uint _S1270 = 4U * _S1269.y;
    float3 ta_2 = (float4(*(kernelContext_92->state_0+(_S1270 + 1U))) ).xyz;
    float3 va_0 = (float4(*(kernelContext_92->state_0+(_S1270 + 2U))) ).xyz;
    float3 wa_1 = (float4(*(kernelContext_92->state_0+(_S1270 + 3U))) ).xyz;
    uint _S1271 = 4U * _S1269.z;
    float3 tb_2 = (float4(*(kernelContext_92->state_0+(_S1271 + 1U))) ).xyz;
    float3 vb_0 = (float4(*(kernelContext_92->state_0+(_S1271 + 2U))) ).xyz;
    float3 wb_1 = (float4(*(kernelContext_92->state_0+(_S1271 + 3U))) ).xyz;
    float3 _S1272 = to_local_0(i_22, (float4(*(kernelContext_92->state_0+_S1271)) ).xyz + cross(tb_2, rb_1) - ((float4(*(kernelContext_92->state_0+_S1270)) ).xyz + cross(ta_2, ra_1)), kernelContext_92);
    float3 _S1273 = to_local_0(i_22, tb_2 - ta_2, kernelContext_92);
    float3 _S1274 = to_local_0(i_22, vb_0 + cross(wb_1, rb_1) - (va_0 + cross(wa_1, ra_1)), kernelContext_92);
    float3 _S1275 = to_local_0(i_22, wb_1 - wa_1, kernelContext_92);
    JointState_0 previous_3 = (kernelContext_92->bond_dyn_0+i_22)->js_0;
    thread JointState_0 _S1276 = (kernelContext_92->bond_dyn_0+i_22)->js_0;
    bool _S1277 = is_damaged_0(&_S1276);
    thread JointBond_natural_0 _S1278 = (kernelContext_92->bonds_0+i_22)->law_0;
    thread JointState_0 _S1279 = (kernelContext_92->bond_dyn_0+i_22)->js_0;
    JointResponse_0 _S1280 = joint_evaluate_0(&kernelContext_92->materials_0->m_0[(uint4((kernelContext_92->bonds_0+i_22)->law_0.ids_0) ).x], &_S1278, &_S1279, _S1272, _S1273, dt_13, fracture_2);
    BondStatic_natural_0 device* _S1281 = kernelContext_92->bonds_0+i_22;
    BondDyn_natural_0 device* _S1282 = kernelContext_92->bond_dyn_0+i_22;
    float4 _S1283 = float4((*_S1282).force_lin_0) ;
    float4 _S1284 = float4((*_S1282).force_ang_0) ;
    float4 _S1285 = float4((*_S1282).sums_0) ;
    float4 _S1286 = float4((*_S1282).comps_0) ;
    uint4 _S1287 = uint4((*_S1282).events_0) ;
    thread BondDyn_0 bd_2;
    (&bd_2)->js_0 = (*_S1282).js_0;
    (&bd_2)->force_lin_0 = _S1283;
    (&bd_2)->force_ang_0 = _S1284;
    (&bd_2)->sums_0 = _S1285;
    (&bd_2)->comps_0 = _S1286;
    (&bd_2)->events_0 = _S1287;
    float3 ra_2 = (float4(_S1281->ra_0) ).xyz;
    float3 rb_2 = (float4(_S1281->rb_0) ).xyz;
    thread JointBond_natural_0 _S1288 = _S1281->law_0;
    thread JointState_0 _S1289 = _S1280.state_8;
    thread float3 f_lin_2;
    thread float3 f_ang_2;
    secant_factors_0(&_S1288, &_S1289, _S1272, &f_lin_2, &f_ang_2);
    float3 qd_lin_0 = _S1274 * (float4(_S1281->c_lin_0) ).xyz * f_lin_2;
    float3 qd_ang_0 = _S1275 * (float4(_S1281->c_ang_0) ).xyz * f_ang_2;
    float3 q_lin_2 = _S1280.force_lin_1 + qd_lin_0;
    float3 q_ang_2 = _S1280.force_ang_1 + qd_ang_0;
    float damped_0 = (dot(qd_lin_0, _S1274) + dot(qd_ang_0, _S1275)) * dt_13;
    float3 _S1290 = to_body_0(i_22, q_lin_2, kernelContext_92);
    float3 _S1291 = to_body_0(i_22, q_ang_2, kernelContext_92);
    uint _S1292 = 3U * i_22;
    *(kernelContext_92->scratch_0+_S1292) = packed_float4(float4(_S1290, max(_S1280.measures_0.tension_0, _S1280.measures_0.compression_0))) ;
    *(kernelContext_92->scratch_0+(_S1292 + 1U)) = packed_float4(float4(_S1291 + cross(ra_2, _S1290), 0.0f)) ;
    *(kernelContext_92->scratch_0+(_S1292 + 2U)) = packed_float4(float4(- _S1291 + cross(rb_2, - _S1290), 0.0f)) ;
    thread float _S1293 = (&bd_2)->sums_0.x;
    thread float _S1294 = (&bd_2)->comps_0.x;
    comp_add1_0(&_S1293, &_S1294, _S1280.dissipated_2);
    (&bd_2)->comps_0.x = _S1294;
    (&bd_2)->sums_0.x = _S1293;
    thread float _S1295 = (&bd_2)->sums_0.y;
    thread float _S1296 = (&bd_2)->comps_0.y;
    comp_add1_0(&_S1295, &_S1296, _S1280.overshoot_0);
    (&bd_2)->comps_0.y = _S1296;
    (&bd_2)->sums_0.y = _S1295;
    thread float _S1297 = (&bd_2)->sums_0.z;
    thread float _S1298 = (&bd_2)->comps_0.z;
    comp_add1_0(&_S1297, &_S1298, damped_0);
    (&bd_2)->comps_0.z = _S1298;
    (&bd_2)->sums_0.z = _S1297;
    (&bd_2)->force_lin_0 = float4(q_lin_2, _S1280.stored_3);
    (&bd_2)->force_ang_0 = float4(q_ang_2, max((&bd_2)->force_ang_0.w, _S1280.state_8.utilization_0));
    bool _S1299;
    if(!_S1277)
    {
        thread JointState_0 _S1300 = _S1280.state_8;
        bool _S1301 = is_damaged_0(&_S1300);
        _S1299 = _S1301;
    }
    else
    {
        _S1299 = false;
    }
    if(_S1299)
    {
        _S1299 = ((&bd_2)->events_0.x) == 0U;
    }
    else
    {
        _S1299 = false;
    }
    if(_S1299)
    {
        (&bd_2)->events_0.x = abs_step_0;
        (&bd_2)->events_0.w = _S1280.state_8.mode_0;
        if(wide_0)
        {
            cov_or_0((uint4((&_S1288)->ids_0) ).w, 32U, kernelContext_92);
        }
        else
        {
            (*kernelContext_92->g_seen_0)[3U] = 1U;
        }
    }
    if(((&bd_2)->events_0.y) == 0U)
    {
        _S1299 = (_S1280.state_8.life_0) != (previous_3.life_0);
    }
    else
    {
        _S1299 = false;
    }
    if(_S1299)
    {
        _S1299 = (_S1280.fatigue_before_0) > 0.99000000953674316f;
    }
    else
    {
        _S1299 = false;
    }
    if(_S1299)
    {
        float _S1302 = fatigue_factor_0(&kernelContext_92->materials_0->m_0[(uint4((kernelContext_92->bonds_0+i_22)->law_0.ids_0) ).x], _S1280.state_8.life_0);
        _S1299 = _S1302 <= 0.99000000953674316f;
    }
    else
    {
        _S1299 = false;
    }
    if(_S1299)
    {
        (&bd_2)->events_0.y = abs_step_0;
        if(wide_0)
        {
            cov_or_0((uint4((&_S1288)->ids_0) ).w, 64U, kernelContext_92);
        }
        else
        {
            (*kernelContext_92->g_seen_0)[4U] = 1U;
        }
    }
    if(_S1280.disconnected_0)
    {
        (&bd_2)->events_0.z = abs_step_0;
    }
    (&bd_2)->js_0 = _S1280.state_8;
    BondDyn_natural_0 device* _S1303 = kernelContext_92->bond_dyn_0+i_22;
    _S1303->js_0 = bd_2.js_0;
    _S1303->force_lin_0 = packed_float4(bd_2.force_lin_0) ;
    _S1303->force_ang_0 = packed_float4(bd_2.force_ang_0) ;
    _S1303->sums_0 = packed_float4(bd_2.sums_0) ;
    _S1303->comps_0 = packed_float4(bd_2.comps_0) ;
    _S1303->events_0 = packed_uint4(bd_2.events_0) ;
    return _S1280.disconnected_0;
}

void chunk_update_0(uint c_40, const Island_natural_0 thread* isl_26, const Rigid_0 thread* rg_14, float dt_14, bool rml_0, uint step_0, bool contact_4, float thread* work_2, float thread* work_err_0, KernelContext_0 thread* kernelContext_93)
{
    ChunkStatic_natural_0 device* _S1304 = kernelContext_93->chunks_0+c_40;
    float3 _S1305 = float3(0.0f) ;
    uint _S1306 = kernelContext_93->index_0[c_40];
    float peak_0 = 0.0f;
    uint e_7 = _S1306;
    float3 fi_5 = _S1305;
    float3 mi_4 = _S1305;
    for(;;)
    {
        if(e_7 < (kernelContext_93->index_0)[c_40 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_6 = kernelContext_93->index_0[e_7];
        uint _S1307 = 3U * (entry_6 >> 1U);
        float4 _S1308 = float4(*(kernelContext_93->scratch_0+_S1307)) ;
        if((entry_6 & 1U) == 0U)
        {
            float3 mi_5 = mi_4 + (float4(*(kernelContext_93->scratch_0+(_S1307 + 1U))) ).xyz;
            fi_5 = fi_5 + _S1308.xyz;
            mi_4 = mi_5;
        }
        else
        {
            float3 mi_6 = mi_4 + (float4(*(kernelContext_93->scratch_0+(_S1307 + 2U))) ).xyz;
            fi_5 = fi_5 + - _S1308.xyz;
            mi_4 = mi_6;
        }
        float _S1309 = max(peak_0, _S1308.w);
        uint _S1310 = e_7 + 1U;
        peak_0 = _S1309;
        e_7 = _S1310;
    }
    uint _S1311 = 4U * c_40;
    float3 u_2 = (float4(*(kernelContext_93->state_0+_S1311)) ).xyz;
    uint _S1312 = _S1311 + 1U;
    float3 th_4 = (float4(*(kernelContext_93->state_0+_S1312)) ).xyz;
    uint _S1313 = _S1311 + 2U;
    float3 v_11 = (float4(*(kernelContext_93->state_0+_S1313)) ).xyz;
    uint _S1314 = _S1311 + 3U;
    float3 w_6 = (float4(*(kernelContext_93->state_0+_S1314)) ).xyz;
    float4 _S1315 = float4(_S1304->center_0) ;
    float mass_0 = _S1315.w;
    float3 _S1316 = _S1315.xyz;
    float3 _S1317 = (float4(isl_26->com_0) ).xyz;
    float3 _S1318 = rotate_0(&rg_14->rot_1, _S1316 + u_2 - _S1317);
    thread float3 f_load_0;
    thread float3 t_load_0;
    thread float3 rep_f_2;
    thread float3 rep_m_2;
    chunk_loads_0(c_40, c_40, &rg_14->rot_1, step_0, dt_14, contact_4, dt_14, &f_load_0, &t_load_0, &rep_f_2, &rep_m_2, kernelContext_93);
    record_chunk_load_0(c_40, f_load_0, t_load_0, kernelContext_93);
    float3 _S1319 = float3(mass_0) ;
    float3 f_world_0 = f_load_0 + kernelContext_93->params_0->gravity_0.xyz * _S1319;
    float3 t_world_0 = t_load_0;
    float3 f_world_1;
    float3 t_world_1;
    if(rml_0)
    {
        float3 f_world_2 = f_world_0 - (rg_14->a_9 + cross(rg_14->alpha_0, _S1318) + cross(rg_14->w_5, cross(rg_14->w_5, _S1318))) * _S1319;
        float4 _S1320 = float4(_S1304->inertia0_1) ;
        float4 _S1321 = float4(_S1304->inertia1_1) ;
        float4 _S1322 = float4(_S1304->inertia2_1) ;
        float3 _S1323 = world_mul_0(&rg_14->rot_1, _S1320, _S1321, _S1322, rg_14->alpha_0);
        float3 _S1324 = world_mul_0(&rg_14->rot_1, _S1320, _S1321, _S1322, rg_14->w_5);
        float3 t_world_2 = t_world_0 - (_S1323 + cross(rg_14->w_5, _S1324));
        f_world_1 = f_world_2;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    float3 _S1325 = inverse_rotate_0(&rg_14->rot_1, f_world_1);
    float3 _S1326 = inverse_rotate_0(&rg_14->rot_1, t_world_1);
    float3 f_ext_0;
    float3 m_ext_0;
    if(rml_0)
    {
        float3 _S1327 = inverse_rotate_0(&rg_14->rot_1, rg_14->w_5);
        float4 _S1328 = float4(_S1304->inertia0_1) ;
        float4 _S1329 = float4(_S1304->inertia1_1) ;
        float4 _S1330 = float4(_S1304->inertia2_1) ;
        float3 i_w_0 = rows_mul_0(_S1328, _S1329, _S1330, w_6);
        float3 m_ext_1 = _S1326 - (cross(_S1327, i_w_0) + cross(w_6, rows_mul_0(_S1328, _S1329, _S1330, _S1327)) + cross(w_6, i_w_0));
        f_ext_0 = _S1325 - cross(_S1327, v_11) * float3((2.0f * mass_0)) ;
        m_ext_0 = m_ext_1;
    }
    else
    {
        f_ext_0 = _S1325;
        m_ext_0 = _S1326;
    }
    float3 f_16 = f_ext_0 + rep_f_2 + fi_5;
    float3 m_7 = m_ext_0 + rep_m_2 + mi_4;
    uint support_1 = (uint4(_S1304->info_1) ).x;
    float3 _S1331 = float3((float4(*(kernelContext_93->state_0+_S1312)) ).w, (float4(*(kernelContext_93->state_0+_S1313)) ).w, (float4(*(kernelContext_93->state_0+_S1314)) ).w);
    float3 reaction_1;
    float3 u_3;
    float3 th_5;
    float3 v_12;
    float3 w_7;
    if(support_1 == 1U)
    {
        reaction_1 = - f_16;
        u_3 = u_2;
        th_5 = th_4;
        v_12 = _S1305;
        w_7 = _S1305;
    }
    else
    {
        float4 _S1332 = float4(_S1304->scale_0) ;
        float3 w_8 = w_6 + rows_mul_0(float4(_S1304->inv0_1) , float4(_S1304->inv1_1) , float4(_S1304->inv2_1) , m_7) * float3((dt_14 * _S1332.z)) ;
        float3 _S1333 = float3(dt_14) ;
        float3 th_6 = th_4 + w_8 * _S1333;
        if(support_1 == 2U)
        {
            reaction_1 = - f_16;
            u_3 = u_2;
            th_5 = _S1305;
        }
        else
        {
            float3 v_13 = v_11 + f_16 * float3((dt_14 * _S1332.y)) ;
            float3 u_4 = u_2 + v_13 * _S1333;
            reaction_1 = _S1331;
            u_3 = u_4;
            th_5 = v_13;
        }
        float3 _S1334 = th_5;
        th_5 = th_6;
        v_12 = _S1334;
        w_7 = w_8;
    }
    *(kernelContext_93->state_0+_S1311) = packed_float4(float4(u_3, peak_0)) ;
    *(kernelContext_93->state_0+_S1312) = packed_float4(float4(th_5, reaction_1.x)) ;
    *(kernelContext_93->state_0+_S1313) = packed_float4(float4(v_12, reaction_1.y)) ;
    *(kernelContext_93->state_0+_S1314) = packed_float4(float4(w_7, reaction_1.z)) ;
    float3 _S1335 = rotate_0(&rg_14->rot_1, _S1316 + u_3 - _S1317);
    float3 _S1336 = rg_14->vel_0 + rg_14->vel_err_0 + cross(rg_14->w_5, _S1335);
    float3 _S1337 = rotate_0(&rg_14->rot_1, v_12);
    float3 v_world_0 = _S1336 + _S1337;
    float3 _S1338 = rotate_0(&rg_14->rot_1, w_7);
    comp_add1_0(work_2, work_err_0, (dot(f_load_0, v_world_0) + dot(t_load_0, rg_14->w_5 + _S1338)) * dt_14);
    return;
}

void chunk_update_1(uint c_41, const Island_0 thread* isl_27, const Rigid_0 thread* rg_15, float dt_15, bool rml_1, uint step_1, bool contact_5, float thread* work_3, float thread* work_err_1, KernelContext_0 thread* kernelContext_94)
{
    ChunkStatic_natural_0 device* _S1339 = kernelContext_94->chunks_0+c_41;
    float3 _S1340 = float3(0.0f) ;
    uint _S1341 = kernelContext_94->index_0[c_41];
    float peak_1 = 0.0f;
    uint e_8 = _S1341;
    float3 fi_6 = _S1340;
    float3 mi_7 = _S1340;
    for(;;)
    {
        if(e_8 < (kernelContext_94->index_0)[c_41 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_7 = kernelContext_94->index_0[e_8];
        uint _S1342 = 3U * (entry_7 >> 1U);
        float4 _S1343 = float4(*(kernelContext_94->scratch_0+_S1342)) ;
        if((entry_7 & 1U) == 0U)
        {
            float3 mi_8 = mi_7 + (float4(*(kernelContext_94->scratch_0+(_S1342 + 1U))) ).xyz;
            fi_6 = fi_6 + _S1343.xyz;
            mi_7 = mi_8;
        }
        else
        {
            float3 mi_9 = mi_7 + (float4(*(kernelContext_94->scratch_0+(_S1342 + 2U))) ).xyz;
            fi_6 = fi_6 + - _S1343.xyz;
            mi_7 = mi_9;
        }
        float _S1344 = max(peak_1, _S1343.w);
        uint _S1345 = e_8 + 1U;
        peak_1 = _S1344;
        e_8 = _S1345;
    }
    uint _S1346 = 4U * c_41;
    float3 u_5 = (float4(*(kernelContext_94->state_0+_S1346)) ).xyz;
    uint _S1347 = _S1346 + 1U;
    float3 th_7 = (float4(*(kernelContext_94->state_0+_S1347)) ).xyz;
    uint _S1348 = _S1346 + 2U;
    float3 v_14 = (float4(*(kernelContext_94->state_0+_S1348)) ).xyz;
    uint _S1349 = _S1346 + 3U;
    float3 w_9 = (float4(*(kernelContext_94->state_0+_S1349)) ).xyz;
    float4 _S1350 = float4(_S1339->center_0) ;
    float mass_1 = _S1350.w;
    float3 _S1351 = _S1350.xyz;
    float3 _S1352 = isl_27->com_0.xyz;
    float3 _S1353 = rotate_0(&rg_15->rot_1, _S1351 + u_5 - _S1352);
    thread float3 f_load_1;
    thread float3 t_load_1;
    thread float3 rep_f_3;
    thread float3 rep_m_3;
    chunk_loads_0(c_41, c_41, &rg_15->rot_1, step_1, dt_15, contact_5, dt_15, &f_load_1, &t_load_1, &rep_f_3, &rep_m_3, kernelContext_94);
    record_chunk_load_0(c_41, f_load_1, t_load_1, kernelContext_94);
    float3 _S1354 = float3(mass_1) ;
    float3 f_world_3 = f_load_1 + kernelContext_94->params_0->gravity_0.xyz * _S1354;
    float3 t_world_3 = t_load_1;
    float3 f_world_4;
    float3 t_world_4;
    if(rml_1)
    {
        float3 f_world_5 = f_world_3 - (rg_15->a_9 + cross(rg_15->alpha_0, _S1353) + cross(rg_15->w_5, cross(rg_15->w_5, _S1353))) * _S1354;
        float4 _S1355 = float4(_S1339->inertia0_1) ;
        float4 _S1356 = float4(_S1339->inertia1_1) ;
        float4 _S1357 = float4(_S1339->inertia2_1) ;
        float3 _S1358 = world_mul_0(&rg_15->rot_1, _S1355, _S1356, _S1357, rg_15->alpha_0);
        float3 _S1359 = world_mul_0(&rg_15->rot_1, _S1355, _S1356, _S1357, rg_15->w_5);
        float3 t_world_5 = t_world_3 - (_S1358 + cross(rg_15->w_5, _S1359));
        f_world_4 = f_world_5;
        t_world_4 = t_world_5;
    }
    else
    {
        f_world_4 = f_world_3;
        t_world_4 = t_world_3;
    }
    float3 _S1360 = inverse_rotate_0(&rg_15->rot_1, f_world_4);
    float3 _S1361 = inverse_rotate_0(&rg_15->rot_1, t_world_4);
    float3 f_ext_1;
    float3 m_ext_2;
    if(rml_1)
    {
        float3 _S1362 = inverse_rotate_0(&rg_15->rot_1, rg_15->w_5);
        float4 _S1363 = float4(_S1339->inertia0_1) ;
        float4 _S1364 = float4(_S1339->inertia1_1) ;
        float4 _S1365 = float4(_S1339->inertia2_1) ;
        float3 i_w_1 = rows_mul_0(_S1363, _S1364, _S1365, w_9);
        float3 m_ext_3 = _S1361 - (cross(_S1362, i_w_1) + cross(w_9, rows_mul_0(_S1363, _S1364, _S1365, _S1362)) + cross(w_9, i_w_1));
        f_ext_1 = _S1360 - cross(_S1362, v_14) * float3((2.0f * mass_1)) ;
        m_ext_2 = m_ext_3;
    }
    else
    {
        f_ext_1 = _S1360;
        m_ext_2 = _S1361;
    }
    float3 f_17 = f_ext_1 + rep_f_3 + fi_6;
    float3 m_8 = m_ext_2 + rep_m_3 + mi_7;
    uint support_2 = (uint4(_S1339->info_1) ).x;
    float3 _S1366 = float3((float4(*(kernelContext_94->state_0+_S1347)) ).w, (float4(*(kernelContext_94->state_0+_S1348)) ).w, (float4(*(kernelContext_94->state_0+_S1349)) ).w);
    float3 reaction_2;
    float3 u_6;
    float3 th_8;
    float3 v_15;
    float3 w_10;
    if(support_2 == 1U)
    {
        reaction_2 = - f_17;
        u_6 = u_5;
        th_8 = th_7;
        v_15 = _S1340;
        w_10 = _S1340;
    }
    else
    {
        float4 _S1367 = float4(_S1339->scale_0) ;
        float3 w_11 = w_9 + rows_mul_0(float4(_S1339->inv0_1) , float4(_S1339->inv1_1) , float4(_S1339->inv2_1) , m_8) * float3((dt_15 * _S1367.z)) ;
        float3 _S1368 = float3(dt_15) ;
        float3 th_9 = th_7 + w_11 * _S1368;
        if(support_2 == 2U)
        {
            reaction_2 = - f_17;
            u_6 = u_5;
            th_8 = _S1340;
        }
        else
        {
            float3 v_16 = v_14 + f_17 * float3((dt_15 * _S1367.y)) ;
            float3 u_7 = u_5 + v_16 * _S1368;
            reaction_2 = _S1366;
            u_6 = u_7;
            th_8 = v_16;
        }
        float3 _S1369 = th_8;
        th_8 = th_9;
        v_15 = _S1369;
        w_10 = w_11;
    }
    *(kernelContext_94->state_0+_S1346) = packed_float4(float4(u_6, peak_1)) ;
    *(kernelContext_94->state_0+_S1347) = packed_float4(float4(th_8, reaction_2.x)) ;
    *(kernelContext_94->state_0+_S1348) = packed_float4(float4(v_15, reaction_2.y)) ;
    *(kernelContext_94->state_0+_S1349) = packed_float4(float4(w_10, reaction_2.z)) ;
    float3 _S1370 = rotate_0(&rg_15->rot_1, _S1351 + u_6 - _S1352);
    float3 _S1371 = rg_15->vel_0 + rg_15->vel_err_0 + cross(rg_15->w_5, _S1370);
    float3 _S1372 = rotate_0(&rg_15->rot_1, v_15);
    float3 v_world_1 = _S1371 + _S1372;
    float3 _S1373 = rotate_0(&rg_15->rot_1, w_10);
    comp_add1_0(work_3, work_err_1, (dot(f_load_1, v_world_1) + dot(t_load_1, rg_15->w_5 + _S1373)) * dt_15);
    return;
}

void drift_moments_0(uint c_42, float3 thread* tu_2, float3 thread* pv_2, KernelContext_0 thread* kernelContext_95)
{
    ChunkStatic_natural_0 device* _S1374 = kernelContext_95->chunks_0+c_42;
    uint _S1375 = 4U * c_42;
    float3 _S1376 = float3(((float4(_S1374->center_0) ).w * (float4(_S1374->scale_0) ).x)) ;
    *tu_2 = *tu_2 + (float4(*(kernelContext_95->state_0+_S1375)) ).xyz * _S1376;
    *pv_2 = *pv_2 + (float4(*(kernelContext_95->state_0+(_S1375 + 2U))) ).xyz * _S1376;
    return;
}

bool island_connected_narrow_0(uint tid_19, const Island_0 thread* isl_28, KernelContext_0 thread* kernelContext_96)
{
    uint _S1377 = isl_28->range_0.x;
    uint n_12 = isl_28->range_0.y - _S1377;
    bool converged_3;
    if(n_12 > 512U)
    {
        converged_3 = true;
    }
    else
    {
        converged_3 = (kernelContext_96->params_0->device_connect_0) == 0U;
    }
    if(converged_3)
    {
        return false;
    }
    uint c_43 = tid_19;
    for(;;)
    {
        if(c_43 < n_12)
        {
        }
        else
        {
            break;
        }
        (*kernelContext_96->g_label_narrow_0)[c_43] = c_43;
        c_43 = c_43 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    converged_3 = false;
    uint pass_1 = 0U;
    for(;;)
    {
        if(pass_1 <= n_12)
        {
        }
        else
        {
            break;
        }
        if(tid_19 == 0U)
        {
            *kernelContext_96->g_changed_narrow_0 = 0U;
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);
        c_43 = tid_19;
        for(;;)
        {
            if(c_43 < n_12)
            {
            }
            else
            {
                break;
            }
            uint gc_1 = _S1377 + c_43;
            uint _S1378 = kernelContext_96->index_0[gc_1];
            uint l_8 = (*kernelContext_96->g_label_narrow_0)[c_43];
            uint e_9 = _S1378;
            for(;;)
            {
                if(e_9 < (kernelContext_96->index_0)[gc_1 + 1U])
                {
                }
                else
                {
                    break;
                }
                uint entry_8 = kernelContext_96->index_0[e_9];
                uint bond_2 = entry_8 >> 1U;
                bool _S1379 = ((float4((kernelContext_96->bonds_0+bond_2)->law_0.stiff1_0) ).w) != 0.0f;
                thread JointState_0 _S1380 = (kernelContext_96->bond_dyn_0+bond_2)->js_0;
                bool _S1381 = connected_0(&_S1380, _S1379);
                if(!_S1381)
                {
                    e_9 = e_9 + 1U;
                    continue;
                }
                uint other_1;
                if((entry_8 & 1U) == 0U)
                {
                    other_1 = (uint4((kernelContext_96->bonds_0+bond_2)->law_0.ids_0) ).z;
                }
                else
                {
                    other_1 = (uint4((kernelContext_96->bonds_0+bond_2)->law_0.ids_0) ).y;
                }
                l_8 = min(l_8, (*kernelContext_96->g_label_narrow_0)[other_1 - _S1377]);
                e_9 = e_9 + 1U;
            }
            uint _S1382 = min(l_8, (*kernelContext_96->g_label_narrow_0)[l_8]);
            if(_S1382 < (*kernelContext_96->g_label_narrow_0)[c_43])
            {
                (*kernelContext_96->g_label_narrow_0)[c_43] = _S1382;
                *kernelContext_96->g_changed_narrow_0 = 1U;
            }
            c_43 = c_43 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);
        bool converged_4 = (*kernelContext_96->g_changed_narrow_0) == 0U;
        threadgroup_barrier(mem_flags::mem_threadgroup);
        if(converged_4)
        {
            converged_3 = converged_4;
            break;
        }
        uint _S1383 = pass_1 + 1U;
        converged_3 = converged_4;
        pass_1 = _S1383;
    }
    if(!converged_3)
    {
        return false;
    }
    if(tid_19 == 0U)
    {
        *kernelContext_96->g_changed_narrow_0 = 0U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    c_43 = tid_19;
    for(;;)
    {
        if(c_43 < n_12)
        {
        }
        else
        {
            break;
        }
        if(((*kernelContext_96->g_label_narrow_0)[c_43]) != 0U)
        {
            *kernelContext_96->g_changed_narrow_0 = 1U;
        }
        c_43 = c_43 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    return (*kernelContext_96->g_changed_narrow_0) == 0U;
}

void island_frame_at_0(uint gi_0, uint tid_20, KernelContext_0 thread* kernelContext_97)
{
    bool woke_0;
    Island_natural_0 device* _S1384 = kernelContext_97->islands_0+gi_0;
    uint4 _S1385 = uint4((*_S1384).info_0) ;
    float4 _S1386 = float4((*_S1384).com_0) ;
    float4 _S1387 = float4((*_S1384).inertia0_0) ;
    float4 _S1388 = float4((*_S1384).inertia1_0) ;
    float4 _S1389 = float4((*_S1384).inertia2_0) ;
    float4 _S1390 = float4((*_S1384).inv0_0) ;
    float4 _S1391 = float4((*_S1384).inv1_0) ;
    float4 _S1392 = float4((*_S1384).inv2_0) ;
    float4 _S1393 = float4((*_S1384).wcom_0) ;
    float4 _S1394 = float4((*_S1384).winv0_0) ;
    float4 _S1395 = float4((*_S1384).winv1_0) ;
    float4 _S1396 = float4((*_S1384).winv2_0) ;
    float4 _S1397 = float4((*_S1384).rotation_0) ;
    float4 _S1398 = float4((*_S1384).position_0) ;
    float4 _S1399 = float4((*_S1384).position_err_0) ;
    float4 _S1400 = float4((*_S1384).velocity_0) ;
    float4 _S1401 = float4((*_S1384).velocity_err_0) ;
    float4 _S1402 = float4((*_S1384).angular_velocity_0) ;
    uint4 _S1403 = uint4((*_S1384).probes_0) ;
    float4 _S1404 = float4((*_S1384).energy_0) ;
    float4 _S1405 = float4((*_S1384).rotation_err_0) ;
    float4 _S1406 = float4((*_S1384).momentum_0) ;
    float4 _S1407 = float4((*_S1384).momentum_err_0) ;
    thread Island_0 isl_29;
    (&isl_29)->range_0 = uint4((*_S1384).range_0) ;
    (&isl_29)->info_0 = _S1385;
    (&isl_29)->com_0 = _S1386;
    (&isl_29)->inertia0_0 = _S1387;
    (&isl_29)->inertia1_0 = _S1388;
    (&isl_29)->inertia2_0 = _S1389;
    (&isl_29)->inv0_0 = _S1390;
    (&isl_29)->inv1_0 = _S1391;
    (&isl_29)->inv2_0 = _S1392;
    (&isl_29)->wcom_0 = _S1393;
    (&isl_29)->winv0_0 = _S1394;
    (&isl_29)->winv1_0 = _S1395;
    (&isl_29)->winv2_0 = _S1396;
    (&isl_29)->rotation_0 = _S1397;
    (&isl_29)->position_0 = _S1398;
    (&isl_29)->position_err_0 = _S1399;
    (&isl_29)->velocity_0 = _S1400;
    (&isl_29)->velocity_err_0 = _S1401;
    (&isl_29)->angular_velocity_0 = _S1402;
    (&isl_29)->done_0 = (*_S1384).done_0;
    (&isl_29)->coverage_0 = (*_S1384).coverage_0;
    (&isl_29)->wide_groups_0 = (*_S1384).wide_groups_0;
    (&isl_29)->done_pad_0 = (*_S1384).done_pad_0;
    (&isl_29)->probes_0 = _S1403;
    (&isl_29)->energy_0 = _S1404;
    (&isl_29)->rotation_err_0 = _S1405;
    (&isl_29)->momentum_0 = _S1406;
    (&isl_29)->momentum_err_0 = _S1407;
    bool driven_0 = (((&isl_29)->info_0.x) & 2U) != 0U;
    bool _S1408 = !((((&isl_29)->info_0.x) & 1U) != 0U);
    bool _S1409;
    if(_S1408)
    {
        _S1409 = !driven_0;
    }
    else
    {
        _S1409 = false;
    }
    bool contact_island_0 = (((&isl_29)->info_0.x) & 4U) != 0U;
    bool _S1410 = (((&isl_29)->info_0.x) & 16U) != 0U;
    seen_clear_0(tid_20, kernelContext_97);
    bool _S1411 = tid_20 == 0U;
    bool settled_0;
    uint cov_2;
    if(_S1411)
    {
        if(contact_island_0 != ((kernelContext_97->params_0->contact_mode_0) == 1U))
        {
            settled_0 = true;
        }
        else
        {
            settled_0 = (((&isl_29)->info_0.x) & 8U) != 0U;
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
            thread Island_0 _S1412 = isl_29;
            bool _S1413 = contact_stopped_1(&_S1412, kernelContext_97);
            settled_0 = _S1413;
        }
        else
        {
            settled_0 = false;
        }
        if(settled_0)
        {
            cov_2 = 0U;
        }
        *kernelContext_97->g_run_0 = cov_2;
        *kernelContext_97->g_halt_0 = 0U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    if((((&isl_29)->info_0.z) & 1U) != 0U)
    {
        settled_0 = true;
    }
    else
    {
        settled_0 = (*kernelContext_97->g_run_0) == 0U;
    }
    if(settled_0)
    {
        cov_2 = 0U;
    }
    else
    {
        cov_2 = min((&isl_29)->info_0.y, kernelContext_97->params_0->max_steps_0);
    }
    float _S1414 = kernelContext_97->params_0->dt_0;
    bool _S1415 = (kernelContext_97->params_0->fracture_0) != 0U;
    bool _S1416 = (kernelContext_97->params_0->rigid_motion_loads_0) != 0U;
    thread Island_0 _S1417 = isl_29;
    Rigid_0 _S1418 = rigid_of_1(&_S1417);
    thread Rigid_0 rg_16 = _S1418;
    thread float work_4 = 0.0f;
    thread float work_err_2 = 0.0f;
    settled_0 = _S1410;
    uint done_1 = 0U;
    bool woke_1 = false;
    bool resumed_0 = false;
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
        uint abs_step_1 = (&isl_29)->info_0.w + done_1 + 1U;
        uint k_24 = abs_step_1 - 1U - kernelContext_97->params_0->step_start_0;
        bool quiet_0 = (((&isl_29)->info_0.x) & 32U) != 0U;
        bool _S1419;
        if(settled_0)
        {
            _S1419 = !quiet_0;
        }
        else
        {
            _S1419 = false;
        }
        bool _S1420;
        bool explicit_step_0;
        uint c_44;
        if(_S1419)
        {
            float3 _S1421 = float3(0.0f) ;
            thread float3 norm_1 = _S1421;
            thread float3 unused0_0 = _S1421;
            c_44 = (&isl_29)->range_0.x + tid_20;
            for(;;)
            {
                if(c_44 < ((&isl_29)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                thread Quat_0 _S1422 = (&rg_16)->rot_1;
                float _S1423 = settled_chunk_load_0(c_44, &_S1422, k_24, _S1414, contact_island_0, kernelContext_97);
                norm_1.x = norm_1.x + _S1423;
                c_44 = c_44 + 256U;
            }
            group_sum3_0(tid_20, &norm_1, &unused0_0, kernelContext_97);
            if((kernelContext_97->params_0->solve_mode_0) == 1U)
            {
                _S1420 = (abs(norm_1.x - (&isl_29)->energy_0.z)) > ((&isl_29)->energy_0.w);
            }
            else
            {
                _S1420 = false;
            }
            if(_S1420)
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
        if(_S1408)
        {
            _S1420 = !quiet_0;
        }
        else
        {
            _S1420 = false;
        }
        if(_S1420)
        {
            float3 _S1424 = float3(0.0f) ;
            thread float3 f_18 = _S1424;
            thread float3 t_19 = _S1424;
            c_44 = (&isl_29)->range_0.x + tid_20;
            for(;;)
            {
                if(c_44 < ((&isl_29)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                thread Island_0 _S1425 = isl_29;
                thread Rigid_0 _S1426 = rg_16;
                net_load_1(c_44, &_S1425, &_S1426, k_24, _S1414, contact_island_0, &f_18, &t_19, kernelContext_97);
                c_44 = c_44 + 256U;
            }
            group_sum3_0(tid_20, &f_18, &t_19, kernelContext_97);
            thread Island_0 _S1427 = isl_29;
            rigid_acceleration_1(&_S1427, &rg_16, f_18, t_19);
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
            c_44 = (&isl_29)->range_0.z + tid_20;
            for(;;)
            {
                if(c_44 < ((&isl_29)->range_0.w))
                {
                }
                else
                {
                    break;
                }
                bool _S1428 = bond_update_0(c_44, _S1414, _S1415, abs_step_1, false, kernelContext_97);
                if(_S1428)
                {
                    *kernelContext_97->g_halt_0 = 1U;
                }
                c_44 = c_44 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            c_45 = (&isl_29)->range_0.x + tid_20;
            for(;;)
            {
                if(c_45 < ((&isl_29)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                thread Island_0 _S1429 = isl_29;
                thread Rigid_0 _S1430 = rg_16;
                chunk_update_1(c_45, &_S1429, &_S1430, _S1414, _S1416, k_24, contact_island_0, &work_4, &work_err_2, kernelContext_97);
                c_45 = c_45 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        }
        bool _S1431;
        if(_S1409)
        {
            _S1431 = !quiet_0;
        }
        else
        {
            _S1431 = false;
        }
        if(_S1431)
        {
            thread Island_0 _S1432 = isl_29;
            integrate_rigid_1(&_S1432, &rg_16, _S1414);
        }
        bool _S1433;
        if(_S1408)
        {
            _S1433 = explicit_step_0;
        }
        else
        {
            _S1433 = false;
        }
        if(_S1433)
        {
            float3 _S1434 = (&isl_29)->wcom_0.xyz;
            float3 _S1435 = float3(0.0f) ;
            thread float3 tu_3 = _S1435;
            thread float3 pv_3 = _S1435;
            c_44 = (&isl_29)->range_0.x + tid_20;
            for(;;)
            {
                if(c_44 < ((&isl_29)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_moments_0(c_44, &tu_3, &pv_3, kernelContext_97);
                c_44 = c_44 + 256U;
            }
            group_sum3_0(tid_20, &tu_3, &pv_3, kernelContext_97);
            float3 tr_6 = tu_3 / float3((&isl_29)->wcom_0.w) ;
            float3 dv_6 = pv_3 / float3((&isl_29)->wcom_0.w) ;
            thread float3 lu_3 = _S1435;
            thread float3 lv_3 = _S1435;
            c_45 = (&isl_29)->range_0.x + tid_20;
            for(;;)
            {
                if(c_45 < ((&isl_29)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_angular_0(c_45, _S1434, tr_6, dv_6, &lu_3, &lv_3, kernelContext_97);
                c_45 = c_45 + 256U;
            }
            group_sum3_0(tid_20, &lu_3, &lv_3, kernelContext_97);
            float3 phi_5 = rows_mul_0((&isl_29)->winv0_0, (&isl_29)->winv1_0, (&isl_29)->winv2_0, lu_3);
            float3 dw_4 = rows_mul_0((&isl_29)->winv0_0, (&isl_29)->winv1_0, (&isl_29)->winv2_0, lv_3);
            uint c_46 = (&isl_29)->range_0.x + tid_20;
            for(;;)
            {
                if(c_46 < ((&isl_29)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_apply_0(c_46, _S1434, tr_6, phi_5, dv_6, dw_4, kernelContext_97);
                c_46 = c_46 + 256U;
            }
            if(!driven_0)
            {
                thread Island_0 _S1436 = isl_29;
                drift_rigid_1(&_S1436, &rg_16, tr_6, phi_5, dv_6, dw_4);
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        }
        bool _S1437;
        if(_S1411)
        {
            _S1437 = ((&isl_29)->probes_0.y) > ((&isl_29)->probes_0.x);
        }
        else
        {
            _S1437 = false;
        }
        if(_S1437)
        {
            thread Island_0 _S1438 = isl_29;
            thread Rigid_0 _S1439 = rg_16;
            record_probes_0(&_S1438, &_S1439, k_24, kernelContext_97);
        }
        uint _S1440 = done_1 + 1U;
        bool _S1441;
        if((*kernelContext_97->g_halt_0) != 0U)
        {
            thread Island_0 _S1442 = isl_29;
            bool _S1443 = island_connected_narrow_0(tid_20, &_S1442, kernelContext_97);
            _S1441 = _S1443;
        }
        else
        {
            _S1441 = false;
        }
        bool resumed_1;
        if(_S1441)
        {
            if(_S1411)
            {
                *kernelContext_97->g_halt_0 = 0U;
            }
            threadgroup_barrier(mem_flags::mem_threadgroup);
            resumed_1 = true;
        }
        else
        {
            resumed_1 = resumed_0;
        }
        if((*kernelContext_97->g_halt_0) != 0U)
        {
            done_1 = _S1440;
            resumed_0 = resumed_1;
            break;
        }
        done_1 = _S1440;
        woke_1 = woke_0;
        resumed_0 = resumed_1;
    }
    thread float3 wsum_0 = float3(work_4, work_err_2, 0.0f);
    thread float3 unused_3 = float3(0.0f) ;
    group_sum3_0(tid_20, &wsum_0, &unused_3, kernelContext_97);
    if(_S1411)
    {
        thread Quat_0 _S1444 = (&rg_16)->rot_1;
        float4 _S1445 = quat_vec_0(&_S1444);
        (&isl_29)->rotation_0 = _S1445;
        (&isl_29)->rotation_err_0 = (&rg_16)->rot_err_0;
        (&isl_29)->position_0 = float4((&rg_16)->pos_0, 0.0f);
        (&isl_29)->position_err_0 = float4((&rg_16)->pos_err_0, 0.0f);
        (&isl_29)->velocity_0 = float4((&rg_16)->vel_0, 0.0f);
        (&isl_29)->velocity_err_0 = float4((&rg_16)->vel_err_0, 0.0f);
        (&isl_29)->angular_velocity_0 = float4((&rg_16)->w_5, 0.0f);
        (&isl_29)->momentum_0 = float4((&rg_16)->l_1, 0.0f);
        (&isl_29)->momentum_err_0 = float4((&rg_16)->l_err_0, 0.0f);
        (&isl_29)->done_0 = done_1;
        (&isl_29)->info_0.y = (&isl_29)->info_0.y - done_1;
        if((*kernelContext_97->g_halt_0) != 0U)
        {
            _S1409 = contact_island_0;
        }
        else
        {
            _S1409 = false;
        }
        if(_S1409)
        {
            contact_split_at_0((&isl_29)->info_0.w + done_1, kernelContext_97);
        }
        float _S1446 = wsum_0.x;
        thread float _S1447 = (&isl_29)->energy_0.x;
        thread float _S1448 = (&isl_29)->energy_0.y;
        comp_add1_0(&_S1447, &_S1448, _S1446);
        (&isl_29)->energy_0.x = _S1447;
        (&isl_29)->energy_0.y = _S1448 + wsum_0.y;
        (&isl_29)->info_0.w = (&isl_29)->info_0.w + done_1;
        if((*kernelContext_97->g_halt_0) != 0U)
        {
            (&isl_29)->info_0.z = ((&isl_29)->info_0.z) | 1U;
        }
        uint _S1449 = seen_bits_0(kernelContext_97);
        if((*kernelContext_97->g_halt_0) != 0U)
        {
            cov_2 = 128U;
        }
        else
        {
            cov_2 = 0U;
        }
        uint _S1450 = _S1449 | cov_2;
        if(woke_0)
        {
            cov_2 = 2048U;
        }
        else
        {
            cov_2 = 0U;
        }
        uint _S1451 = _S1450 | cov_2;
        if(resumed_0)
        {
            cov_2 = 2097280U;
        }
        else
        {
            cov_2 = 0U;
        }
        uint cov_3 = _S1451 | cov_2;
        if(done_1 > 0U)
        {
            bool quiet_1 = (((&isl_29)->info_0.x) & 32U) != 0U;
            if(quiet_1)
            {
                cov_2 = 4096U;
            }
            else
            {
                cov_2 = 0U;
            }
            uint cov_4 = cov_3 | cov_2;
            if((((&isl_29)->info_0.x) & 16U) != 0U)
            {
                _S1409 = !quiet_1;
            }
            else
            {
                _S1409 = false;
            }
            if(_S1409)
            {
                cov_2 = 512U;
            }
            else
            {
                cov_2 = 0U;
            }
            uint cov_5 = cov_4 | cov_2;
            if((kernelContext_97->params_0->contact_mode_0) == 1U)
            {
                cov_2 = 524288U;
            }
            else
            {
                cov_2 = 0U;
            }
            uint cov_6 = cov_5 | cov_2;
            if(((&isl_29)->probes_0.y) > ((&isl_29)->probes_0.x))
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
        (&isl_29)->coverage_0 = ((&isl_29)->coverage_0) | cov_2;
        if(woke_0)
        {
            (&isl_29)->info_0.x = ((&isl_29)->info_0.x) & 4294967279U;
            (&isl_29)->info_0.z = ((&isl_29)->info_0.z) | 4U;
        }
        Island_natural_0 device* _S1452 = kernelContext_97->islands_0+gi_0;
        _S1452->range_0 = packed_uint4(isl_29.range_0) ;
        _S1452->info_0 = packed_uint4(isl_29.info_0) ;
        _S1452->com_0 = packed_float4(isl_29.com_0) ;
        _S1452->inertia0_0 = packed_float4(isl_29.inertia0_0) ;
        _S1452->inertia1_0 = packed_float4(isl_29.inertia1_0) ;
        _S1452->inertia2_0 = packed_float4(isl_29.inertia2_0) ;
        _S1452->inv0_0 = packed_float4(isl_29.inv0_0) ;
        _S1452->inv1_0 = packed_float4(isl_29.inv1_0) ;
        _S1452->inv2_0 = packed_float4(isl_29.inv2_0) ;
        _S1452->wcom_0 = packed_float4(isl_29.wcom_0) ;
        _S1452->winv0_0 = packed_float4(isl_29.winv0_0) ;
        _S1452->winv1_0 = packed_float4(isl_29.winv1_0) ;
        _S1452->winv2_0 = packed_float4(isl_29.winv2_0) ;
        _S1452->rotation_0 = packed_float4(isl_29.rotation_0) ;
        _S1452->position_0 = packed_float4(isl_29.position_0) ;
        _S1452->position_err_0 = packed_float4(isl_29.position_err_0) ;
        _S1452->velocity_0 = packed_float4(isl_29.velocity_0) ;
        _S1452->velocity_err_0 = packed_float4(isl_29.velocity_err_0) ;
        _S1452->angular_velocity_0 = packed_float4(isl_29.angular_velocity_0) ;
        _S1452->done_0 = isl_29.done_0;
        _S1452->coverage_0 = isl_29.coverage_0;
        _S1452->wide_groups_0 = isl_29.wide_groups_0;
        _S1452->done_pad_0 = isl_29.done_pad_0;
        _S1452->probes_0 = packed_uint4(isl_29.probes_0) ;
        _S1452->energy_0 = packed_float4(isl_29.energy_0) ;
        _S1452->rotation_err_0 = packed_float4(isl_29.rotation_err_0) ;
        _S1452->momentum_0 = packed_float4(isl_29.momentum_0) ;
        _S1452->momentum_err_0 = packed_float4(isl_29.momentum_err_0) ;
    }
    return;
}

[[kernel]] void island_frame(uint3 group_8 [[threadgroup_position_in_grid]], uint3 thread_8 [[thread_position_in_threadgroup]], Params_0 constant* params_12 [[buffer(0)]], Island_natural_0 device* islands_12 [[buffer(9)]], uint device* index_12 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_12 [[buffer(3)]], packed_float4 device* state_14 [[buffer(6)]], packed_float4 device* scratch_12 [[buffer(8)]], packed_float4 device* contact_state_12 [[buffer(11)]], packed_float4 device* loads_12 [[buffer(5)]], Impactor_natural_0 device* impactors_12 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_12 [[buffer(7)]], BondStatic_natural_0 device* bonds_12 [[buffer(2)]], MaterialTable_0 constant* materials_12 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_98;
    (&kernelContext_98)->params_0 = params_12;
    (&kernelContext_98)->islands_0 = islands_12;
    (&kernelContext_98)->index_0 = index_12;
    (&kernelContext_98)->chunks_0 = chunks_12;
    (&kernelContext_98)->state_0 = state_14;
    (&kernelContext_98)->scratch_0 = scratch_12;
    (&kernelContext_98)->contact_state_0 = contact_state_12;
    (&kernelContext_98)->loads_0 = loads_12;
    (&kernelContext_98)->impactors_0 = impactors_12;
    (&kernelContext_98)->bond_dyn_0 = bond_dyn_12;
    (&kernelContext_98)->bonds_0 = bonds_12;
    (&kernelContext_98)->materials_0 = materials_12;
    threadgroup array<float4, int(32)> g_part_a_12;
    (&kernelContext_98)->g_part_a_0 = &g_part_a_12;
    threadgroup array<float4, int(32)> g_part_b_12;
    (&kernelContext_98)->g_part_b_0 = &g_part_b_12;
    threadgroup array<uint, int(5)> g_seen_12;
    (&kernelContext_98)->g_seen_0 = &g_seen_12;
    threadgroup uint g_wide_run_12;
    (&kernelContext_98)->g_wide_run_0 = &g_wide_run_12;
    threadgroup array<uint, int(4096)> g_label_12;
    (&kernelContext_98)->g_label_0 = &g_label_12;
    threadgroup uint g_changed_12;
    (&kernelContext_98)->g_changed_0 = &g_changed_12;
    threadgroup uint g_halt_12;
    (&kernelContext_98)->g_halt_0 = &g_halt_12;
    threadgroup uint g_run_12;
    (&kernelContext_98)->g_run_0 = &g_run_12;
    threadgroup array<uint, int(512)> g_label_narrow_12;
    (&kernelContext_98)->g_label_narrow_0 = &g_label_narrow_12;
    threadgroup uint g_changed_narrow_12;
    (&kernelContext_98)->g_changed_narrow_0 = &g_changed_narrow_12;
    island_frame_at_0(group_8.x, thread_8.x, &kernelContext_98);
    return;
}

void wide_chunks_at_0(uint gx_0, uint tid_21, KernelContext_0 thread* kernelContext_99)
{
    WideGroup_0 _S1453 = wide_group_0(kernelContext_99->params_0->wide_chunk_table_0, gx_0, kernelContext_99);
    thread Island_natural_0 _S1454 = *(kernelContext_99->islands_0+_S1453.island_3);
    bool _S1455 = wide_enter_1(tid_21, _S1453.island_3, kernelContext_99);
    if(!_S1455)
    {
        return;
    }
    uint _S1456 = (uint4((&_S1454)->info_0) ).x;
    bool anchored_0 = (_S1456 & 1U) != 0U;
    if((_S1456 & 16U) != 0U)
    {
        if(tid_21 == 0U)
        {
            *(kernelContext_99->scratch_0+(kernelContext_99->params_0->wide_base_0 + 8U * gx_0 + 6U)) = packed_float4(float4(0.0f) ) ;
        }
        return;
    }
    thread WideGroup_0 _S1457 = _S1453;
    Rigid_0 _S1458 = wide_rigid_frame_1(tid_21, &_S1454, &_S1457, kernelContext_99);
    thread float work_5 = 0.0f;
    thread float work_err_3 = 0.0f;
    float3 _S1459 = float3(0.0f) ;
    thread float3 tu_4 = _S1459;
    thread float3 pv_4 = _S1459;
    uint c_47 = _S1453.begin_0 + tid_21;
    if(c_47 < (_S1453.end_0))
    {
        float _S1460 = kernelContext_99->params_0->dt_0;
        bool _S1461 = (kernelContext_99->params_0->rigid_motion_loads_0) != 0U;
        uint _S1462 = wide_step_1(&_S1454, kernelContext_99);
        bool _S1463 = (_S1456 & 4U) != 0U;
        thread Rigid_0 _S1464 = _S1458;
        chunk_update_0(c_47, &_S1454, &_S1464, _S1460, _S1461, _S1462, _S1463, &work_5, &work_err_3, kernelContext_99);
        if(!anchored_0)
        {
            drift_moments_0(c_47, &tu_4, &pv_4, kernelContext_99);
        }
    }
    thread float3 wsum_1 = float3(work_5, work_err_3, 0.0f);
    thread float3 unused_4 = _S1459;
    group_sum3_0(tid_21, &wsum_1, &unused_4, kernelContext_99);
    bool _S1465 = !anchored_0;
    if(_S1465)
    {
        group_sum3_0(tid_21, &tu_4, &pv_4, kernelContext_99);
    }
    if(tid_21 == 0U)
    {
        uint _S1466 = 8U * gx_0;
        *(kernelContext_99->scratch_0+(kernelContext_99->params_0->wide_base_0 + _S1466 + 6U)) = packed_float4(float4(wsum_1, 0.0f)) ;
        if(_S1465)
        {
            wide_store_0(gx_0, 2U, tu_4, pv_4, kernelContext_99);
        }
        *(kernelContext_99->scratch_0+(kernelContext_99->params_0->wide_base_0 + _S1466 + 7U)) = packed_float4(float4(float((*kernelContext_99->g_seen_0)[0U]), float((*kernelContext_99->g_seen_0)[1U]), float((*kernelContext_99->g_seen_0)[2U]), 0.0f)) ;
    }
    return;
}

[[kernel]] void wide_chunks(uint3 group_9 [[threadgroup_position_in_grid]], uint3 thread_9 [[thread_position_in_threadgroup]], Params_0 constant* params_13 [[buffer(0)]], Island_natural_0 device* islands_13 [[buffer(9)]], uint device* index_13 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_13 [[buffer(3)]], packed_float4 device* state_15 [[buffer(6)]], packed_float4 device* scratch_13 [[buffer(8)]], packed_float4 device* contact_state_13 [[buffer(11)]], packed_float4 device* loads_13 [[buffer(5)]], Impactor_natural_0 device* impactors_13 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_13 [[buffer(7)]], BondStatic_natural_0 device* bonds_13 [[buffer(2)]], MaterialTable_0 constant* materials_13 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_100;
    (&kernelContext_100)->params_0 = params_13;
    (&kernelContext_100)->islands_0 = islands_13;
    (&kernelContext_100)->index_0 = index_13;
    (&kernelContext_100)->chunks_0 = chunks_13;
    (&kernelContext_100)->state_0 = state_15;
    (&kernelContext_100)->scratch_0 = scratch_13;
    (&kernelContext_100)->contact_state_0 = contact_state_13;
    (&kernelContext_100)->loads_0 = loads_13;
    (&kernelContext_100)->impactors_0 = impactors_13;
    (&kernelContext_100)->bond_dyn_0 = bond_dyn_13;
    (&kernelContext_100)->bonds_0 = bonds_13;
    (&kernelContext_100)->materials_0 = materials_13;
    threadgroup array<float4, int(32)> g_part_a_13;
    (&kernelContext_100)->g_part_a_0 = &g_part_a_13;
    threadgroup array<float4, int(32)> g_part_b_13;
    (&kernelContext_100)->g_part_b_0 = &g_part_b_13;
    threadgroup array<uint, int(5)> g_seen_13;
    (&kernelContext_100)->g_seen_0 = &g_seen_13;
    threadgroup uint g_wide_run_13;
    (&kernelContext_100)->g_wide_run_0 = &g_wide_run_13;
    threadgroup array<uint, int(4096)> g_label_13;
    (&kernelContext_100)->g_label_0 = &g_label_13;
    threadgroup uint g_changed_13;
    (&kernelContext_100)->g_changed_0 = &g_changed_13;
    threadgroup uint g_halt_13;
    (&kernelContext_100)->g_halt_0 = &g_halt_13;
    threadgroup uint g_run_13;
    (&kernelContext_100)->g_run_0 = &g_run_13;
    threadgroup array<uint, int(512)> g_label_narrow_13;
    (&kernelContext_100)->g_label_narrow_0 = &g_label_narrow_13;
    threadgroup uint g_changed_narrow_13;
    (&kernelContext_100)->g_changed_narrow_0 = &g_changed_narrow_13;
    wide_chunks_at_0(group_9.x, thread_9.x, &kernelContext_100);
    return;
}

[[kernel]] void sums_and_impactors(uint3 group_10 [[threadgroup_position_in_grid]], uint3 thread_10 [[thread_position_in_threadgroup]], Params_0 constant* params_14 [[buffer(0)]], Island_natural_0 device* islands_14 [[buffer(9)]], uint device* index_14 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_14 [[buffer(3)]], packed_float4 device* state_16 [[buffer(6)]], packed_float4 device* scratch_14 [[buffer(8)]], packed_float4 device* contact_state_14 [[buffer(11)]], packed_float4 device* loads_14 [[buffer(5)]], Impactor_natural_0 device* impactors_14 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_14 [[buffer(7)]], BondStatic_natural_0 device* bonds_14 [[buffer(2)]], MaterialTable_0 constant* materials_14 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_101;
    (&kernelContext_101)->params_0 = params_14;
    (&kernelContext_101)->islands_0 = islands_14;
    (&kernelContext_101)->index_0 = index_14;
    (&kernelContext_101)->chunks_0 = chunks_14;
    (&kernelContext_101)->state_0 = state_16;
    (&kernelContext_101)->scratch_0 = scratch_14;
    (&kernelContext_101)->contact_state_0 = contact_state_14;
    (&kernelContext_101)->loads_0 = loads_14;
    (&kernelContext_101)->impactors_0 = impactors_14;
    (&kernelContext_101)->bond_dyn_0 = bond_dyn_14;
    (&kernelContext_101)->bonds_0 = bonds_14;
    (&kernelContext_101)->materials_0 = materials_14;
    threadgroup array<float4, int(32)> g_part_a_14;
    (&kernelContext_101)->g_part_a_0 = &g_part_a_14;
    threadgroup array<float4, int(32)> g_part_b_14;
    (&kernelContext_101)->g_part_b_0 = &g_part_b_14;
    threadgroup array<uint, int(5)> g_seen_14;
    (&kernelContext_101)->g_seen_0 = &g_seen_14;
    threadgroup uint g_wide_run_14;
    (&kernelContext_101)->g_wide_run_0 = &g_wide_run_14;
    threadgroup array<uint, int(4096)> g_label_14;
    (&kernelContext_101)->g_label_0 = &g_label_14;
    threadgroup uint g_changed_14;
    (&kernelContext_101)->g_changed_0 = &g_changed_14;
    threadgroup uint g_halt_14;
    (&kernelContext_101)->g_halt_0 = &g_halt_14;
    threadgroup uint g_run_14;
    (&kernelContext_101)->g_run_0 = &g_run_14;
    threadgroup array<uint, int(512)> g_label_narrow_14;
    (&kernelContext_101)->g_label_narrow_0 = &g_label_narrow_14;
    threadgroup uint g_changed_narrow_14;
    (&kernelContext_101)->g_changed_narrow_0 = &g_changed_narrow_14;
    uint sums_groups_0 = (params_14->seg_count_0 + 255U) / 256U;
    uint _S1467 = group_10.x;
    if(_S1467 < sums_groups_0)
    {
        contact_sum_at_0(_S1467 * 256U + thread_10.x, &kernelContext_101);
    }
    else
    {
        impactor_integrate_at_0(_S1467 - sums_groups_0, thread_10.x, &kernelContext_101);
    }
    return;
}

[[kernel]] void islands_and_wide_chunks(uint3 group_11 [[threadgroup_position_in_grid]], uint3 thread_11 [[thread_position_in_threadgroup]], Params_0 constant* params_15 [[buffer(0)]], Island_natural_0 device* islands_15 [[buffer(9)]], uint device* index_15 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_15 [[buffer(3)]], packed_float4 device* state_17 [[buffer(6)]], packed_float4 device* scratch_15 [[buffer(8)]], packed_float4 device* contact_state_15 [[buffer(11)]], packed_float4 device* loads_15 [[buffer(5)]], Impactor_natural_0 device* impactors_15 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_15 [[buffer(7)]], BondStatic_natural_0 device* bonds_15 [[buffer(2)]], MaterialTable_0 constant* materials_15 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_102;
    (&kernelContext_102)->params_0 = params_15;
    (&kernelContext_102)->islands_0 = islands_15;
    (&kernelContext_102)->index_0 = index_15;
    (&kernelContext_102)->chunks_0 = chunks_15;
    (&kernelContext_102)->state_0 = state_17;
    (&kernelContext_102)->scratch_0 = scratch_15;
    (&kernelContext_102)->contact_state_0 = contact_state_15;
    (&kernelContext_102)->loads_0 = loads_15;
    (&kernelContext_102)->impactors_0 = impactors_15;
    (&kernelContext_102)->bond_dyn_0 = bond_dyn_15;
    (&kernelContext_102)->bonds_0 = bonds_15;
    (&kernelContext_102)->materials_0 = materials_15;
    threadgroup array<float4, int(32)> g_part_a_15;
    (&kernelContext_102)->g_part_a_0 = &g_part_a_15;
    threadgroup array<float4, int(32)> g_part_b_15;
    (&kernelContext_102)->g_part_b_0 = &g_part_b_15;
    threadgroup array<uint, int(5)> g_seen_15;
    (&kernelContext_102)->g_seen_0 = &g_seen_15;
    threadgroup uint g_wide_run_15;
    (&kernelContext_102)->g_wide_run_0 = &g_wide_run_15;
    threadgroup array<uint, int(4096)> g_label_15;
    (&kernelContext_102)->g_label_0 = &g_label_15;
    threadgroup uint g_changed_15;
    (&kernelContext_102)->g_changed_0 = &g_changed_15;
    threadgroup uint g_halt_15;
    (&kernelContext_102)->g_halt_0 = &g_halt_15;
    threadgroup uint g_run_15;
    (&kernelContext_102)->g_run_0 = &g_run_15;
    threadgroup array<uint, int(512)> g_label_narrow_15;
    (&kernelContext_102)->g_label_narrow_0 = &g_label_narrow_15;
    threadgroup uint g_changed_narrow_15;
    (&kernelContext_102)->g_changed_narrow_0 = &g_changed_narrow_15;
    uint _S1468 = group_11.x;
    if(_S1468 < (params_15->halt_index_0))
    {
        island_frame_at_0(_S1468, thread_11.x, &kernelContext_102);
    }
    else
    {
        wide_chunks_at_0(_S1468 - params_15->halt_index_0, thread_11.x, &kernelContext_102);
    }
    return;
}

void wide_bonds_at_0(uint gx_1, uint tid_22, KernelContext_0 thread* kernelContext_103)
{
    bool bond_group_0 = gx_1 < (kernelContext_103->params_0->wide_bond_groups_0);
    WideGroup_0 wg_2;
    if(bond_group_0)
    {
        WideGroup_0 _S1469 = wide_group_0(kernelContext_103->params_0->wide_bond_table_0, gx_1, kernelContext_103);
        wg_2 = _S1469;
    }
    else
    {
        WideGroup_0 _S1470 = wide_group_0(kernelContext_103->params_0->wide_chunk_table_0, gx_1 - kernelContext_103->params_0->wide_bond_groups_0, kernelContext_103);
        wg_2 = _S1470;
    }
    WideGroup_0 _S1471 = wg_2;
    thread Island_natural_0 _S1472 = *(kernelContext_103->islands_0+wg_2.island_3);
    bool _S1473 = wide_enter_1(tid_22, wg_2.island_3, kernelContext_103);
    if(!_S1473)
    {
        return;
    }
    uint _S1474 = wide_step_1(&_S1472, kernelContext_103);
    if(bond_group_0)
    {
        uint4 _S1475 = uint4((&_S1472)->info_0) ;
        if(((_S1475.x) & 16U) != 0U)
        {
            return;
        }
        uint i_23 = wg_2.begin_0 + tid_22;
        bool _S1476;
        if(i_23 < (wg_2.end_0))
        {
            bool _S1477 = bond_update_0(i_23, kernelContext_103->params_0->dt_0, (kernelContext_103->params_0->fracture_0) != 0U, _S1475.w + 1U, true, kernelContext_103);
            _S1476 = _S1477;
        }
        else
        {
            _S1476 = false;
        }
        if(_S1476)
        {
            (kernelContext_103->islands_0+_S1471.island_3)->info_0[int(2)] = (_S1475.z) | 2U;
        }
        return;
    }
    uint _S1478 = (uint4((&_S1472)->info_0) ).x;
    if((_S1478 & 1U) != 0U)
    {
        return;
    }
    float3 _S1479 = float3(0.0f) ;
    thread float3 f_19 = _S1479;
    thread float3 t_20 = _S1479;
    uint c_48 = wg_2.begin_0 + tid_22;
    if(c_48 < (wg_2.end_0))
    {
        Rigid_0 _S1480 = rigid_of_0(&_S1472);
        float _S1481 = kernelContext_103->params_0->dt_0;
        bool _S1482 = (_S1478 & 4U) != 0U;
        thread Rigid_0 _S1483 = _S1480;
        net_load_0(c_48, &_S1472, &_S1483, _S1474, _S1481, _S1482, &f_19, &t_20, kernelContext_103);
    }
    group_sum3_0(tid_22, &f_19, &t_20, kernelContext_103);
    if(tid_22 == 0U)
    {
        wide_store_0(gx_1 - kernelContext_103->params_0->wide_bond_groups_0, 0U, f_19, t_20, kernelContext_103);
    }
    return;
}

[[kernel]] void wide_bonds(uint3 group_12 [[threadgroup_position_in_grid]], uint3 thread_12 [[thread_position_in_threadgroup]], Params_0 constant* params_16 [[buffer(0)]], Island_natural_0 device* islands_16 [[buffer(9)]], uint device* index_16 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_16 [[buffer(3)]], packed_float4 device* state_18 [[buffer(6)]], packed_float4 device* scratch_16 [[buffer(8)]], packed_float4 device* contact_state_16 [[buffer(11)]], packed_float4 device* loads_16 [[buffer(5)]], Impactor_natural_0 device* impactors_16 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_16 [[buffer(7)]], BondStatic_natural_0 device* bonds_16 [[buffer(2)]], MaterialTable_0 constant* materials_16 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_104;
    (&kernelContext_104)->params_0 = params_16;
    (&kernelContext_104)->islands_0 = islands_16;
    (&kernelContext_104)->index_0 = index_16;
    (&kernelContext_104)->chunks_0 = chunks_16;
    (&kernelContext_104)->state_0 = state_18;
    (&kernelContext_104)->scratch_0 = scratch_16;
    (&kernelContext_104)->contact_state_0 = contact_state_16;
    (&kernelContext_104)->loads_0 = loads_16;
    (&kernelContext_104)->impactors_0 = impactors_16;
    (&kernelContext_104)->bond_dyn_0 = bond_dyn_16;
    (&kernelContext_104)->bonds_0 = bonds_16;
    (&kernelContext_104)->materials_0 = materials_16;
    threadgroup array<float4, int(32)> g_part_a_16;
    (&kernelContext_104)->g_part_a_0 = &g_part_a_16;
    threadgroup array<float4, int(32)> g_part_b_16;
    (&kernelContext_104)->g_part_b_0 = &g_part_b_16;
    threadgroup array<uint, int(5)> g_seen_16;
    (&kernelContext_104)->g_seen_0 = &g_seen_16;
    threadgroup uint g_wide_run_16;
    (&kernelContext_104)->g_wide_run_0 = &g_wide_run_16;
    threadgroup array<uint, int(4096)> g_label_16;
    (&kernelContext_104)->g_label_0 = &g_label_16;
    threadgroup uint g_changed_16;
    (&kernelContext_104)->g_changed_0 = &g_changed_16;
    threadgroup uint g_halt_16;
    (&kernelContext_104)->g_halt_0 = &g_halt_16;
    threadgroup uint g_run_16;
    (&kernelContext_104)->g_run_0 = &g_run_16;
    threadgroup array<uint, int(512)> g_label_narrow_16;
    (&kernelContext_104)->g_label_narrow_0 = &g_label_narrow_16;
    threadgroup uint g_changed_narrow_16;
    (&kernelContext_104)->g_changed_narrow_0 = &g_changed_narrow_16;
    wide_bonds_at_0(group_12.x, thread_12.x, &kernelContext_104);
    return;
}

[[kernel]] void sums_impactors_bonds(uint3 group_13 [[threadgroup_position_in_grid]], uint3 thread_13 [[thread_position_in_threadgroup]], Params_0 constant* params_17 [[buffer(0)]], Island_natural_0 device* islands_17 [[buffer(9)]], uint device* index_17 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_17 [[buffer(3)]], packed_float4 device* state_19 [[buffer(6)]], packed_float4 device* scratch_17 [[buffer(8)]], packed_float4 device* contact_state_17 [[buffer(11)]], packed_float4 device* loads_17 [[buffer(5)]], Impactor_natural_0 device* impactors_17 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_17 [[buffer(7)]], BondStatic_natural_0 device* bonds_17 [[buffer(2)]], MaterialTable_0 constant* materials_17 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_105;
    (&kernelContext_105)->params_0 = params_17;
    (&kernelContext_105)->islands_0 = islands_17;
    (&kernelContext_105)->index_0 = index_17;
    (&kernelContext_105)->chunks_0 = chunks_17;
    (&kernelContext_105)->state_0 = state_19;
    (&kernelContext_105)->scratch_0 = scratch_17;
    (&kernelContext_105)->contact_state_0 = contact_state_17;
    (&kernelContext_105)->loads_0 = loads_17;
    (&kernelContext_105)->impactors_0 = impactors_17;
    (&kernelContext_105)->bond_dyn_0 = bond_dyn_17;
    (&kernelContext_105)->bonds_0 = bonds_17;
    (&kernelContext_105)->materials_0 = materials_17;
    threadgroup array<float4, int(32)> g_part_a_17;
    (&kernelContext_105)->g_part_a_0 = &g_part_a_17;
    threadgroup array<float4, int(32)> g_part_b_17;
    (&kernelContext_105)->g_part_b_0 = &g_part_b_17;
    threadgroup array<uint, int(5)> g_seen_17;
    (&kernelContext_105)->g_seen_0 = &g_seen_17;
    threadgroup uint g_wide_run_17;
    (&kernelContext_105)->g_wide_run_0 = &g_wide_run_17;
    threadgroup array<uint, int(4096)> g_label_17;
    (&kernelContext_105)->g_label_0 = &g_label_17;
    threadgroup uint g_changed_17;
    (&kernelContext_105)->g_changed_0 = &g_changed_17;
    threadgroup uint g_halt_17;
    (&kernelContext_105)->g_halt_0 = &g_halt_17;
    threadgroup uint g_run_17;
    (&kernelContext_105)->g_run_0 = &g_run_17;
    threadgroup array<uint, int(512)> g_label_narrow_17;
    (&kernelContext_105)->g_label_narrow_0 = &g_label_narrow_17;
    threadgroup uint g_changed_narrow_17;
    (&kernelContext_105)->g_changed_narrow_0 = &g_changed_narrow_17;
    uint sums_groups_1 = (params_17->seg_count_0 + 255U) / 256U;
    uint _S1484 = max(params_17->impactor_count_0, 1U);
    uint _S1485 = group_13.x;
    if(_S1485 < sums_groups_1)
    {
        contact_sum_at_0(_S1485 * 256U + thread_13.x, &kernelContext_105);
    }
    else
    {
        if(_S1485 < (sums_groups_1 + _S1484))
        {
            impactor_integrate_at_0(_S1485 - sums_groups_1, thread_13.x, &kernelContext_105);
        }
        else
        {
            wide_bonds_at_0(_S1485 - sums_groups_1 - _S1484, thread_13.x, &kernelContext_105);
        }
    }
    return;
}

