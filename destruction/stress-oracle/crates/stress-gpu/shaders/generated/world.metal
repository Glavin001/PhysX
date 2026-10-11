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
    Island_natural_0 device* _S7 = kernelContext_4->islands_0+(uint4((kernelContext_4->chunks_0+c_0)->info_1) ).y;
    Quat_0 q_3 = quat_of_0(float4(_S7->rotation_0) );
    thread WorldPoint_0 w_2;
    (&w_2)->hi_0 = (float4(_S7->position_0) ).xyz;
    (&w_2)->lo_0 = (float4(_S7->position_err_0) ).xyz;
    float3 _S8 = (float4((kernelContext_4->chunks_0+c_0)->center_0) ).xyz + (float4(*(kernelContext_4->state_0+4U * c_0)) ).xyz;
    thread Quat_0 _S9 = q_3;
    float3 _S10 = rotate_0(&_S9, _S8);
    (&w_2)->rel_0 = _S10;
    return w_2;
}

float3 world_diff_0(const WorldPoint_0 thread* a_2, const WorldPoint_0 thread* b_2)
{
    return a_2->hi_0 - b_2->hi_0 + (a_2->lo_0 - b_2->lo_0) + (a_2->rel_0 - b_2->rel_0);
}

float3 safe_normalize_0(float3 v_2)
{
    float n_0 = length(v_2);
    float3 _S11;
    if(n_0 > 1.00000000317107685e-30f)
    {
        _S11 = v_2 / float3(n_0) ;
    }
    else
    {
        _S11 = float3(0.0f) ;
    }
    return _S11;
}

Quat_0 from_axis_angle_0(float3 axis_0, float angle_0)
{
    float3 a_3 = safe_normalize_0(axis_0);
    float _S12 = 0.5f * angle_0;
    float s_0 = sin(_S12);
    thread Quat_0 q_4;
    (&q_4)->w_1 = cos(_S12);
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
    Quat_0 q_5 = quat_of_0(float4((kernelContext_5->islands_0+(uint4((kernelContext_5->chunks_0+c_1)->info_1) ).y)->rotation_0) );
    float3 th_0 = (float4(*(kernelContext_5->state_0+(4U * c_1 + 1U))) ).xyz;
    Quat_0 hidden_0 = from_axis_angle_0(th_0, length(th_0));
    thread Box_0 b_3;
    (&b_3)->center_1 = center_2;
    float3 _S13 = float3((float4((kernelContext_5->chunks_0+c_1)->crot0_0) ).x, (float4((kernelContext_5->chunks_0+c_1)->crot1_0) ).x, (float4((kernelContext_5->chunks_0+c_1)->crot2_0) ).x);
    thread Quat_0 _S14 = hidden_0;
    float3 _S15 = rotate_0(&_S14, _S13);
    thread Quat_0 _S16 = q_5;
    float3 _S17 = rotate_0(&_S16, _S15);
    (&b_3)->axis0_0 = _S17;
    float3 _S18 = float3((float4((kernelContext_5->chunks_0+c_1)->crot0_0) ).y, (float4((kernelContext_5->chunks_0+c_1)->crot1_0) ).y, (float4((kernelContext_5->chunks_0+c_1)->crot2_0) ).y);
    thread Quat_0 _S19 = hidden_0;
    float3 _S20 = rotate_0(&_S19, _S18);
    thread Quat_0 _S21 = q_5;
    float3 _S22 = rotate_0(&_S21, _S20);
    (&b_3)->axis1_0 = _S22;
    float3 _S23 = float3((float4((kernelContext_5->chunks_0+c_1)->crot0_0) ).z, (float4((kernelContext_5->chunks_0+c_1)->crot1_0) ).z, (float4((kernelContext_5->chunks_0+c_1)->crot2_0) ).z);
    thread Quat_0 _S24 = hidden_0;
    float3 _S25 = rotate_0(&_S24, _S23);
    thread Quat_0 _S26 = q_5;
    float3 _S27 = rotate_0(&_S26, _S25);
    (&b_3)->axis2_0 = _S27;
    (&b_3)->half_2 = (float4((kernelContext_5->chunks_0+c_1)->half_0) ).xyz;
    (&b_3)->hull_at_0 = (as_type<uint>(((float4((kernelContext_5->chunks_0+c_1)->cmat_0) ).z)));
    (&b_3)->hull_v_0 = (as_type<uint>(((float4((kernelContext_5->chunks_0+c_1)->cmat_0) ).w))) & 255U;
    (&b_3)->hull_f_0 = (as_type<uint>(((float4((kernelContext_5->chunks_0+c_1)->cmat_0) ).w))) >> 8U;
    return b_3;
}

uint sample_count_0(const Box_0 thread* b_4)
{
    uint _S28 = b_4->hull_v_0;
    uint _S29;
    if((b_4->hull_v_0) == 0U)
    {
        _S29 = 14U;
    }
    else
    {
        _S29 = _S28 + b_4->hull_f_0;
    }
    return _S29;
}

bool may_overlap_0(const Box_0 thread* a_4, const Box_0 thread* b_5)
{
    float3 _S30 = b_5->center_1 - a_4->center_1;
    float3 _S31 = a_4->half_2;
    float3 _S32 = b_5->half_2;
    float _S33 = 0.00000999999974738f * (length(a_4->half_2) + length(b_5->half_2));
    float3 _S34 = a_4->axis0_0;
    float3 _S35 = a_4->axis1_0;
    float3 _S36 = a_4->axis2_0;
    float3 _S37 = b_5->axis0_0;
    float3 _S38 = b_5->axis1_0;
    float3 _S39 = b_5->axis2_0;
    array<float3, int(6)> _S40 = { { a_4->axis0_0, a_4->axis1_0, a_4->axis2_0, b_5->axis0_0, b_5->axis1_0, b_5->axis2_0 } };
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
            l_0 = _S40[i_0];
        }
        else
        {
            uint _S41 = i_0 - 6U;
            l_0 = cross(_S40[_S41 / 3U], _S40[3U + _S41 % 3U]);
        }
        float len_0 = length(l_0);
        if(len_0 <= 9.99999997475242708e-07f)
        {
            i_0 = i_0 + 1U;
            continue;
        }
        if((abs(dot(_S30, l_0))) > (_S31.x * abs(dot(_S34, l_0)) + _S31.y * abs(dot(_S35, l_0)) + _S31.z * abs(dot(_S36, l_0)) + (_S32.x * abs(dot(_S37, l_0)) + _S32.y * abs(dot(_S38, l_0)) + _S32.z * abs(dot(_S39, l_0))) + _S33 * len_0))
        {
            return false;
        }
        i_0 = i_0 + 1U;
    }
    return true;
}

void chunk_velocity_0(uint c_2, float3 thread* v_3, float3 thread* w_3, KernelContext_0 thread* kernelContext_6)
{
    Island_natural_0 device* _S42 = kernelContext_6->islands_0+(uint4((kernelContext_6->chunks_0+c_2)->info_1) ).y;
    Quat_0 q_6 = quat_of_0(float4(_S42->rotation_0) );
    uint _S43 = 4U * c_2;
    float3 _S44 = (float4((kernelContext_6->chunks_0+c_2)->center_0) ).xyz + (float4(*(kernelContext_6->state_0+_S43)) ).xyz - (float4(_S42->com_0) ).xyz;
    thread Quat_0 _S45 = q_6;
    float3 _S46 = rotate_0(&_S45, _S44);
    float3 _S47 = (float4(_S42->angular_velocity_0) ).xyz;
    float3 _S48 = (float4(_S42->velocity_0) ).xyz + (float4(_S42->velocity_err_0) ).xyz + cross(_S47, _S46);
    float3 _S49 = (float4(*(kernelContext_6->state_0+(_S43 + 2U))) ).xyz;
    thread Quat_0 _S50 = q_6;
    float3 _S51 = rotate_0(&_S50, _S49);
    *v_3 = _S48 + _S51;
    float3 _S52 = (float4(*(kernelContext_6->state_0+(_S43 + 3U))) ).xyz;
    thread Quat_0 _S53 = q_6;
    float3 _S54 = rotate_0(&_S53, _S52);
    *w_3 = _S47 + _S54;
    return;
}

float3 box_to_world_0(const Box_0 thread* b_6, float3 local_0)
{
    return b_6->axis0_0 * float3(local_0.x)  + b_6->axis1_0 * float3(local_0.y)  + b_6->axis2_0 * float3(local_0.z) ;
}

float3 box_axis_0(const Box_0 thread* b_7, uint k_0)
{
    float3 _S55;
    if(k_0 == 0U)
    {
        _S55 = b_7->axis0_0;
    }
    else
    {
        if(k_0 == 1U)
        {
            _S55 = b_7->axis1_0;
        }
        else
        {
            _S55 = b_7->axis2_0;
        }
    }
    return _S55;
}

float comp3_0(float3 v_4, uint k_1)
{
    float _S56;
    if(k_1 == 0U)
    {
        _S56 = v_4.x;
    }
    else
    {
        if(k_1 == 1U)
        {
            _S56 = v_4.y;
        }
        else
        {
            _S56 = v_4.z;
        }
    }
    return _S56;
}

float3 sample_point_0(const Box_0 thread* b_8, uint i_1, KernelContext_0 thread* kernelContext_7)
{
    uint _S57 = b_8->hull_v_0;
    if((b_8->hull_v_0) != 0U)
    {
        float3 local_1;
        if(i_1 < _S57)
        {
            local_1 = (float4(*(kernelContext_7->loads_0+(b_8->hull_at_0 + i_1))) ).xyz * float3(0.89999997615814209f) ;
        }
        else
        {
            local_1 = (float4(*(kernelContext_7->loads_0+(b_8->hull_at_0 + _S57 + b_8->hull_f_0 + (i_1 - _S57)))) ).xyz;
        }
        float3 _S58 = b_8->center_1;
        float3 _S59 = box_to_world_0(b_8, local_1);
        return _S58 + _S59;
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
        float _S60;
        if((i_1 & 2U) == 0U)
        {
            _S60 = - h_0.y;
        }
        else
        {
            _S60 = h_0.y;
        }
        float _S61;
        if((i_1 & 4U) == 0U)
        {
            _S61 = - h_0.z;
        }
        else
        {
            _S61 = h_0.z;
        }
        return b_8->center_1 + b_8->axis0_0 * float3(sign_0)  + b_8->axis1_0 * float3(_S60)  + b_8->axis2_0 * float3(_S61) ;
    }
    uint _S62 = i_1 - 8U;
    uint axis_1 = _S62 / 2U;
    if((_S62 % 2U) == 0U)
    {
        sign_0 = -1.0f;
    }
    else
    {
        sign_0 = 1.0f;
    }
    float3 _S63 = b_8->center_1;
    float3 _S64 = box_axis_0(b_8, axis_1);
    return _S63 + _S64 * float3((sign_0 * comp3_0(b_8->half_2, axis_1))) ;
}

float3 sample_point_1(const Box_0 thread* b_9, uint i_2, KernelContext_0 thread* kernelContext_8)
{
    uint _S65 = b_9->hull_v_0;
    if((b_9->hull_v_0) != 0U)
    {
        float3 local_2;
        if(i_2 < _S65)
        {
            local_2 = (float4(*(kernelContext_8->loads_0+(b_9->hull_at_0 + i_2))) ).xyz * float3(0.89999997615814209f) ;
        }
        else
        {
            local_2 = (float4(*(kernelContext_8->loads_0+(b_9->hull_at_0 + _S65 + b_9->hull_f_0 + (i_2 - _S65)))) ).xyz;
        }
        float3 _S66 = b_9->center_1;
        float3 _S67 = box_to_world_0(b_9, local_2);
        return _S66 + _S67;
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
        float _S68;
        if((i_2 & 2U) == 0U)
        {
            _S68 = - h_1.y;
        }
        else
        {
            _S68 = h_1.y;
        }
        float _S69;
        if((i_2 & 4U) == 0U)
        {
            _S69 = - h_1.z;
        }
        else
        {
            _S69 = h_1.z;
        }
        return b_9->center_1 + b_9->axis0_0 * float3(sign_1)  + b_9->axis1_0 * float3(_S68)  + b_9->axis2_0 * float3(_S69) ;
    }
    uint _S70 = i_2 - 8U;
    uint axis_2 = _S70 / 2U;
    if((_S70 % 2U) == 0U)
    {
        sign_1 = -1.0f;
    }
    else
    {
        sign_1 = 1.0f;
    }
    float3 _S71 = b_9->center_1;
    float3 _S72 = box_axis_0(b_9, axis_2);
    return _S71 + _S72 * float3((sign_1 * comp3_0(b_9->half_2, axis_2))) ;
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
        float4 _S73 = float4(*(kernelContext_9->loads_0+(b_11->hull_at_0 + b_11->hull_v_0 + f_0))) ;
        float d_0 = dot(_S73.xyz, local_3) - _S73.w;
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
    float3 _S74 = b_12->half_2;
    if((dot(r_2, r_2)) > (dot(b_12->half_2, b_12->half_2) * 1.00001001358032227f))
    {
        return false;
    }
    uint _S75 = b_12->hull_v_0;
    if((b_12->hull_v_0) != 0U)
    {
        float3 _S76 = box_to_local_0(b_12, r_2);
        thread uint face_1;
        float _S77 = hull_signed_distance_0(b_12, _S76, &face_1, kernelContext_10);
        if(!(_S77 < 0.0f))
        {
            return false;
        }
        *depth_0 = - _S77;
        float3 _S78 = box_to_world_0(b_12, (float4(*(kernelContext_10->loads_0+(b_12->hull_at_0 + _S75 + face_1))) ).xyz);
        *normal_1 = _S78;
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
        float3 _S79 = box_axis_0(b_12, k_2);
        float local_4 = dot(r_2, _S79);
        float d_1 = comp3_0(_S74, k_2) - abs(local_4);
        if(d_1 <= 0.0f)
        {
            return false;
        }
        if(d_1 < best_1)
        {
            float _S80;
            if(local_4 >= 0.0f)
            {
                _S80 = 1.0f;
            }
            else
            {
                _S80 = -1.0f;
            }
            best_1 = d_1;
            axis_3 = k_2;
            side_0 = _S80;
        }
        k_2 = k_2 + 1U;
    }
    *depth_0 = best_1;
    float3 _S81 = box_axis_0(b_12, axis_3);
    *normal_1 = _S81 * float3(side_0) ;
    return true;
}

bool penetration_1(const Box_0 thread* b_13, float3 p_1, float thread* depth_1, float3 thread* normal_2, KernelContext_0 thread* kernelContext_11)
{
    *depth_1 = 0.0f;
    *normal_2 = float3(0.0f) ;
    float3 r_3 = p_1 - b_13->center_1;
    float3 _S82 = b_13->half_2;
    if((dot(r_3, r_3)) > (dot(b_13->half_2, b_13->half_2) * 1.00001001358032227f))
    {
        return false;
    }
    uint _S83 = b_13->hull_v_0;
    if((b_13->hull_v_0) != 0U)
    {
        float3 _S84 = box_to_local_0(b_13, r_3);
        thread uint face_2;
        float _S85 = hull_signed_distance_0(b_13, _S84, &face_2, kernelContext_11);
        if(!(_S85 < 0.0f))
        {
            return false;
        }
        *depth_1 = - _S85;
        float3 _S86 = box_to_world_0(b_13, (float4(*(kernelContext_11->loads_0+(b_13->hull_at_0 + _S83 + face_2))) ).xyz);
        *normal_2 = _S86;
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
        float3 _S87 = box_axis_0(b_13, k_3);
        float local_5 = dot(r_3, _S87);
        float d_2 = comp3_0(_S82, k_3) - abs(local_5);
        if(d_2 <= 0.0f)
        {
            return false;
        }
        if(d_2 < best_2)
        {
            float _S88;
            if(local_5 >= 0.0f)
            {
                _S88 = 1.0f;
            }
            else
            {
                _S88 = -1.0f;
            }
            best_2 = d_2;
            axis_4 = k_3;
            side_1 = _S88;
        }
        k_3 = k_3 + 1U;
    }
    *depth_1 = best_2;
    float3 _S89 = box_axis_0(b_13, axis_4);
    *normal_2 = _S89 * float3(side_1) ;
    return true;
}

bool pair_point_0(const Box_0 thread* ba_0, const Box_0 thread* bb_0, uint na_0, uint e_0, float3 thread* p_2, float3 thread* n_1, float thread* d_3, KernelContext_0 thread* kernelContext_12)
{
    if(e_0 < na_0)
    {
        float3 _S90 = sample_point_1(ba_0, e_0, kernelContext_12);
        *p_2 = _S90;
        bool _S91 = penetration_1(bb_0, _S90, d_3, n_1, kernelContext_12);
        return _S91;
    }
    float3 _S92 = sample_point_1(bb_0, e_0 - na_0, kernelContext_12);
    *p_2 = _S92;
    bool _S93 = penetration_1(ba_0, _S92, d_3, n_1, kernelContext_12);
    if(!_S93)
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
    uint _S94;
    if(lanes_1 > 1U)
    {
        uint _S95 = simd_sum(x_4);
        _S94 = _S95;
    }
    else
    {
        _S94 = x_4;
    }
    return _S94;
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
        float3 _S96 = box_axis_0(b_14, k_4);
        float c_3 = abs(dot(d_4, _S96));
        float h_3 = h_2 + c_3 * comp3_0(b_14->half_2, k_4);
        uint _S97 = k_4 + 1U;
        float area_1 = area_0 + c_3 * 4.0f * comp3_0(b_14->half_2, _S97 % 3U) * comp3_0(b_14->half_2, (k_4 + 2U) % 3U);
        k_4 = _S97;
        h_2 = h_3;
        area_0 = area_1;
    }
    return float2(h_2, area_0);
}

float contact_stiffness_0(float ea_0, const Box_0 thread* a_5, float eb_0, const Box_0 thread* b_15, float3 dir_0)
{
    float3 d_5 = safe_normalize_0(dir_0);
    float2 _S98 = half_thickness_and_area_0(a_5, d_5);
    float2 _S99 = half_thickness_and_area_0(b_15, d_5);
    return min(_S98.y, _S99.y) / (_S98.x / ea_0 + _S99.x / eb_0);
}

float3 penalty_force_0(float k_5, float m_red_0, float friction_0, float depth_2, float3 normal_3, float3 rel_velocity_0, float dt_1, uint points_0, float thread* stored_0, float thread* dissipated_1, KernelContext_0 thread* kernelContext_13)
{
    float c_max_0 = 1.0f / max(float(points_0), 10.0f) * m_red_0 / dt_1;
    float vn_0 = dot(rel_velocity_0, normal_3);
    float _S100 = k_5 * depth_2;
    float _S101 = min(2.0f * kernelContext_13->params_0->zeta_0 * sqrt(k_5 * m_red_0), c_max_0) * vn_0;
    float _S102 = _S100 - _S101;
    float _S103 = max(_S102, 0.0f);
    float3 vt_0 = rel_velocity_0 - normal_3 * float3(vn_0) ;
    float vt_mag_0 = length(vt_0);
    float _S104 = friction_0 * _S103;
    float _S105 = min(_S104, min(c_max_0, _S104 / 0.00100000004749745f) * vt_mag_0);
    float3 ft_0;
    if(vt_mag_0 > 0.0f)
    {
        ft_0 = - vt_0 * float3((_S105 / vt_mag_0)) ;
    }
    else
    {
        ft_0 = float3(0.0f) ;
    }
    *stored_0 = 0.5f * k_5 * depth_2 * depth_2;
    float damping_power_0;
    if(_S102 > 0.0f)
    {
        damping_power_0 = _S101 * vn_0;
    }
    else
    {
        damping_power_0 = _S100 * max(vn_0, 0.0f);
    }
    *dissipated_1 = (damping_power_0 + length(ft_0) * vt_mag_0) * dt_1;
    return normal_3 * float3(_S103)  + ft_0;
}

float3 pair_sum3_0(float3 x_5, uint lanes_2)
{
    float3 _S106;
    if(lanes_2 > 1U)
    {
        float3 _S107 = simd_sum(x_5);
        _S106 = _S107;
    }
    else
    {
        _S106 = x_5;
    }
    return _S106;
}

float pair_sum_0(float x_6, uint lanes_3)
{
    float _S108;
    if(lanes_3 > 1U)
    {
        float _S109 = simd_sum(x_6);
        _S108 = _S109;
    }
    else
    {
        _S108 = x_6;
    }
    return _S108;
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
    uint _S110 = atomic_fetch_or_explicit(((atomic_uint device*)(&(kernelContext_14->islands_0+island_0)->coverage_0)), bits_0, memory_order_relaxed);
    return;
}

void cov_or_1(uint island_1, uint bits_1, KernelContext_0 thread* kernelContext_15)
{
    uint _S111 = atomic_fetch_or_explicit(((atomic_uint device*)(&(kernelContext_15->islands_0+island_1)->coverage_0)), bits_1, memory_order_relaxed);
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
    uint _S112 = kernelContext_18->index_0[at_0 + 3U];
    float _S113 = (as_type<float>((kernelContext_18->index_0[at_0 + 4U])));
    float _S114 = (as_type<float>((kernelContext_18->index_0[at_0 + 5U])));
    float _S115 = kernelContext_18->params_0->dt_0;
    uint out_0 = kernelContext_18->params_0->slot_base_0 + 2U * kernelContext_18->index_0[at_0 + 2U];
    WorldPoint_0 _S116 = chunk_world_0(ca_0, kernelContext_18);
    WorldPoint_0 _S117 = chunk_world_0(cb_0, kernelContext_18);
    thread WorldPoint_0 _S118 = _S117;
    thread WorldPoint_0 _S119 = _S116;
    float3 _S120 = world_diff_0(&_S118, &_S119);
    bool touching_0 = !((length(_S120)) > ((float4((kernelContext_18->chunks_0+ca_0)->half_0) ).w + (float4((kernelContext_18->chunks_0+cb_0)->half_0) ).w));
    float4 _S121 = float4(*(kernelContext_18->scratch_0+(kernelContext_18->params_0->ledger_base_0 + i_3))) ;
    thread float4 ledger_1 = _S121;
    uint flags_0 = (as_type<uint>((_S121.w)));
    float3 _S122 = float3(0.0f) ;
    Box_0 _S123 = chunk_box_0(ca_0, _S122, kernelContext_18);
    Box_0 _S124 = chunk_box_0(cb_0, _S120, kernelContext_18);
    thread Box_0 _S125 = _S123;
    uint _S126 = sample_count_0(&_S125);
    thread Box_0 _S127 = _S124;
    uint _S128 = sample_count_0(&_S127);
    uint _S129 = _S126 + _S128;
    uint e_1;
    bool has_state_0;
    if(!touching_0)
    {
        if((flags_0 & 1U) != 0U)
        {
            e_1 = lane_0;
            for(;;)
            {
                if(e_1 < _S129)
                {
                }
                else
                {
                    break;
                }
                *(kernelContext_18->contact_state_0+(_S112 + e_1)) = packed_float4(float4((as_type<float>((2143289344U))), 0.0f, 0.0f, 0.0f)) ;
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
    thread Box_0 _S130 = _S123;
    thread Box_0 _S131 = _S124;
    bool _S132 = may_overlap_0(&_S130, &_S131);
    uint count_0;
    float3 fa_0;
    float3 ta_0;
    float3 fb_0;
    float3 tb_0;
    float stored_sum_0;
    float diss_sum_0;
    if(_S132)
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
            if(e_1 < _S129)
            {
            }
            else
            {
                break;
            }
            thread Box_0 _S133 = _S123;
            thread Box_0 _S134 = _S124;
            thread float3 p_3;
            thread float3 n_2;
            thread float d_6;
            bool _S135 = pair_point_0(&_S133, &_S134, _S126, e_1, &p_3, &n_2, &d_6, kernelContext_18);
            if(!_S135)
            {
                uint _S136 = _S112 + e_1;
                if(!is_nan_0((float4(*(kernelContext_18->contact_state_0+_S136)) ).x))
                {
                    *(kernelContext_18->contact_state_0+_S136) = packed_float4(float4((as_type<float>((2143289344U))), 0.0f, 0.0f, 0.0f)) ;
                }
                e_1 = e_1 + lanes_4;
                continue;
            }
            uint _S137 = count_0 + 1U;
            uint _S138 = _S112 + e_1;
            float4 _S139 = float4(*(kernelContext_18->contact_state_0+_S138)) ;
            thread float4 entry_0 = _S139;
            if(is_nan_0(_S139.x))
            {
                has_state_0 = true;
            }
            else
            {
                has_state_0 = (dot(entry_0.yzw, n_2)) < 0.99000000953674316f;
            }
            if(has_state_0)
            {
                if(d_6 > (2.0f * abs(dot(va0_0 + cross(wa0_0, p_3) - (vb0_0 + cross(wb0_0, p_3 - _S124.center_1)), n_2)) * _S115 + 9.99999971718068537e-10f))
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
            *(kernelContext_18->contact_state_0+_S138) = packed_float4(entry_0) ;
            uint engaged_1;
            if((d_6 - entry_0.x) > 0.0f)
            {
                engaged_1 = engaged_0 + 1U;
            }
            else
            {
                engaged_1 = engaged_0;
            }
            count_0 = _S137;
            engaged_0 = engaged_1;
            e_1 = e_1 + lanes_4;
        }
        uint count_1 = pair_count_sum_0(count_0, lanes_4);
        uint engaged_2 = pair_count_sum_0(engaged_0, lanes_4);
        if(count_1 > 0U)
        {
            float _S140 = (float4((kernelContext_18->chunks_0+ca_0)->cmat_0) ).x;
            float _S141 = (float4((kernelContext_18->chunks_0+cb_0)->cmat_0) ).x;
            float3 _S142 = _S124.center_1 - _S123.center_1;
            thread Box_0 _S143 = _S123;
            thread Box_0 _S144 = _S124;
            float _S145 = contact_stiffness_0(_S140, &_S143, _S141, &_S144, _S142);
            float _S146 = _S145 / max(float(engaged_2), 10.0f);
            e_1 = lane_0;
            fa_0 = _S122;
            ta_0 = _S122;
            fb_0 = _S122;
            tb_0 = _S122;
            stored_sum_0 = 0.0f;
            diss_sum_0 = 0.0f;
            for(;;)
            {
                if(e_1 < _S129)
                {
                }
                else
                {
                    break;
                }
                thread Box_0 _S147 = _S123;
                thread Box_0 _S148 = _S124;
                thread float3 p_4;
                thread float3 n_3;
                thread float d_7;
                bool _S149 = pair_point_0(&_S147, &_S148, _S126, e_1, &p_4, &n_3, &d_7, kernelContext_18);
                if(!_S149)
                {
                    e_1 = e_1 + lanes_4;
                    continue;
                }
                float eff_0 = d_7 - (float4(*(kernelContext_18->contact_state_0+(_S112 + e_1))) ).x;
                if(eff_0 <= 0.0f)
                {
                    e_1 = e_1 + lanes_4;
                    continue;
                }
                thread float stored_1;
                thread float diss_0;
                float3 _S150 = penalty_force_0(_S146, _S113, _S114, eff_0, n_3, va0_0 + cross(wa0_0, p_4) - (vb0_0 + cross(wb0_0, p_4 - _S124.center_1)), _S115, engaged_2, &stored_1, &diss_0, kernelContext_18);
                float3 ta_1 = ta_0 + cross(p_4, _S150);
                float3 _S151 = - _S150;
                float3 fb_1 = fb_0 + _S151;
                float3 tb_1 = tb_0 + cross(p_4 - _S124.center_1, _S151);
                float stored_sum_1 = stored_sum_0 + stored_1;
                float diss_sum_1 = diss_sum_0 + diss_0;
                fa_0 = fa_0 + _S150;
                ta_0 = ta_1;
                fb_0 = fb_1;
                tb_0 = tb_1;
                stored_sum_0 = stored_sum_1;
                diss_sum_0 = diss_sum_1;
                e_1 = e_1 + lanes_4;
            }
            float3 _S152 = pair_sum3_0(fa_0, lanes_4);
            float3 _S153 = pair_sum3_0(ta_0, lanes_4);
            float3 _S154 = pair_sum3_0(fb_0, lanes_4);
            float3 _S155 = pair_sum3_0(tb_0, lanes_4);
            float _S156 = pair_sum_0(stored_sum_0, lanes_4);
            float _S157 = pair_sum_0(diss_sum_0, lanes_4);
            has_state_0 = true;
            diss_sum_0 = _S157;
            fa_0 = _S152;
            ta_0 = _S153;
            fb_0 = _S154;
            tb_0 = _S155;
            stored_sum_0 = _S156;
        }
        else
        {
            has_state_0 = false;
            diss_sum_0 = 0.0f;
            fa_0 = _S122;
            ta_0 = _S122;
            fb_0 = _S122;
            tb_0 = _S122;
            stored_sum_0 = 0.0f;
        }
    }
    else
    {
        has_state_0 = false;
        diss_sum_0 = 0.0f;
        fa_0 = _S122;
        ta_0 = _S122;
        fb_0 = _S122;
        tb_0 = _S122;
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
            if(e_1 < _S129)
            {
            }
            else
            {
                break;
            }
            *(kernelContext_18->contact_state_0+(_S112 + e_1)) = packed_float4(float4((as_type<float>((2143289344U))), 0.0f, 0.0f, 0.0f)) ;
            e_1 = e_1 + lanes_4;
        }
    }
    if(lane_0 != 0U)
    {
        return;
    }
    if(has_state_0)
    {
        thread float _S158 = ledger_1.y;
        thread float _S159 = ledger_1.z;
        comp_add1_0(&_S158, &_S159, diss_sum_0);
        ledger_1.z = _S159;
        ledger_1.y = _S158;
    }
    float3 _S160 = float3(0.0f) ;
    if(any(fa_0 != _S160))
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any(ta_0 != _S160);
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any(fb_0 != _S160);
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any(tb_0 != _S160);
    }
    bool _S161;
    if(loaded_0)
    {
        _S161 = true;
    }
    else
    {
        _S161 = (flags_0 & 2U) != 0U;
    }
    if(_S161)
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
    float3 _S162 = float3(1.0f, 0.0f, 0.0f);
    thread Quat_0 _S163 = q_7;
    float3 _S164 = rotate_0(&_S163, _S162);
    (&b_16)->axis0_0 = _S164;
    float3 _S165 = float3(0.0f, 1.0f, 0.0f);
    thread Quat_0 _S166 = q_7;
    float3 _S167 = rotate_0(&_S166, _S165);
    (&b_16)->axis1_0 = _S167;
    float3 _S168 = float3(0.0f, 0.0f, 1.0f);
    thread Quat_0 _S169 = q_7;
    float3 _S170 = rotate_0(&_S169, _S168);
    (&b_16)->axis2_0 = _S170;
    (&b_16)->half_2 = half_3;
    (&b_16)->hull_at_0 = 0U;
    (&b_16)->hull_v_0 = 0U;
    (&b_16)->hull_f_0 = 0U;
    return b_16;
}

uint impactor_slots_0(const Impactor_natural_0 thread* imp_1, const Box_0 thread* b_17)
{
    uint _S171;
    if(((float4(imp_1->shape_0) ).x) == 0.0f)
    {
        _S171 = 1U;
    }
    else
    {
        uint _S172 = sample_count_0(b_17);
        _S171 = _S172 + 14U;
    }
    return _S171;
}

uint impactor_slots_1(const Impactor_natural_0 thread* imp_2, const Box_0 thread* b_18)
{
    uint _S173;
    if(((float4(imp_2->shape_0) ).x) == 0.0f)
    {
        _S173 = 1U;
    }
    else
    {
        uint _S174 = sample_count_0(b_18);
        _S173 = _S174 + 14U;
    }
    return _S173;
}

bool sphere_contact_0(const Box_0 thread* b_19, float3 center_4, float radius_0, float3 thread* point_0, float3 thread* normal_4, float thread* depth_3, KernelContext_0 thread* kernelContext_19)
{
    float3 _S175 = float3(0.0f) ;
    *point_0 = _S175;
    *normal_4 = _S175;
    *depth_3 = 0.0f;
    float3 _S176 = b_19->center_1;
    float3 r_4 = center_4 - b_19->center_1;
    float3 _S177 = b_19->axis0_0;
    float3 _S178 = b_19->axis1_0;
    float3 _S179 = b_19->axis2_0;
    float3 local_6 = float3(dot(r_4, b_19->axis0_0), dot(r_4, b_19->axis1_0), dot(r_4, b_19->axis2_0));
    uint _S180 = b_19->hull_v_0;
    if((b_19->hull_v_0) != 0U)
    {
        thread uint face_3;
        float _S181 = hull_signed_distance_0(b_19, local_6, &face_3, kernelContext_19);
        if(_S181 >= radius_0)
        {
            return false;
        }
        float3 _S182 = box_to_world_0(b_19, (float4(*(kernelContext_19->loads_0+(b_19->hull_at_0 + _S180 + face_3))) ).xyz);
        *normal_4 = _S182;
        *point_0 = center_4 - _S182 * float3(max(_S181, 0.0f)) ;
        *depth_3 = radius_0 - _S181;
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
        *normal_4 = _S177 * float3(dn_0.x)  + _S178 * float3(dn_0.y)  + _S179 * float3(dn_0.z) ;
        *point_0 = _S176 + _S177 * float3(q_8.x)  + _S178 * float3(q_8.y)  + _S179 * float3(q_8.z) ;
        *depth_3 = radius_0 - dist_0;
        return true;
    }
    thread float inside_0;
    thread float3 n_4;
    bool _S183 = penetration_0(b_19, center_4, &inside_0, &n_4, kernelContext_19);
    if(!_S183)
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
    float3 _S184 = float3(0.0f) ;
    *p_5 = _S184;
    *n_5 = _S184;
    *d_9 = 0.0f;
    float4 _S185 = float4(imp_3->shape_0) ;
    if((_S185.x) == 0.0f)
    {
        bool _S186 = sphere_contact_0(b_20, _S184, _S185.y - crush_depth_0, p_5, n_5, d_9, kernelContext_20);
        if(!_S186)
        {
            return false;
        }
        *n_5 = - *n_5;
        return true;
    }
    uint _S187 = sample_count_0(b_20);
    if(j_0 < _S187)
    {
        float3 _S188 = sample_point_0(b_20, j_0, kernelContext_20);
        *p_5 = _S188;
        bool _S189 = penetration_0(shrunk_0, _S188, d_9, n_5, kernelContext_20);
        return _S189;
    }
    float3 _S190 = sample_point_0(shrunk_0, j_0 - _S187, kernelContext_20);
    *p_5 = _S190;
    bool _S191 = penetration_0(b_20, _S190, d_9, n_5, kernelContext_20);
    if(!_S191)
    {
        return false;
    }
    *n_5 = - *n_5;
    return true;
}

bool impactor_contact_1(const Impactor_natural_0 thread* imp_4, float crush_depth_1, const Box_0 thread* shrunk_1, const Box_0 thread* b_21, uint j_1, float3 thread* p_6, float3 thread* n_6, float thread* d_10, KernelContext_0 thread* kernelContext_21)
{
    float3 _S192 = float3(0.0f) ;
    *p_6 = _S192;
    *n_6 = _S192;
    *d_10 = 0.0f;
    float4 _S193 = float4(imp_4->shape_0) ;
    if((_S193.x) == 0.0f)
    {
        bool _S194 = sphere_contact_0(b_21, _S192, _S193.y - crush_depth_1, p_6, n_6, d_10, kernelContext_21);
        if(!_S194)
        {
            return false;
        }
        *n_6 = - *n_6;
        return true;
    }
    uint _S195 = sample_count_0(b_21);
    if(j_1 < _S195)
    {
        float3 _S196 = sample_point_0(b_21, j_1, kernelContext_21);
        *p_6 = _S196;
        bool _S197 = penetration_0(shrunk_1, _S196, d_10, n_6, kernelContext_21);
        return _S197;
    }
    float3 _S198 = sample_point_0(shrunk_1, j_1 - _S195, kernelContext_21);
    *p_6 = _S198;
    bool _S199 = penetration_0(b_21, _S198, d_10, n_6, kernelContext_21);
    if(!_S199)
    {
        return false;
    }
    *n_6 = - *n_6;
    return true;
}

WorldPoint_0 impactor_point_0(uint _S200, KernelContext_0 thread* kernelContext_22)
{
    Impactor_natural_0 device* _S201 = kernelContext_22->impactors_0+_S200;
    thread WorldPoint_0 wi_0;
    (&wi_0)->hi_0 = (float4(_S201->position_1) ).xyz;
    (&wi_0)->lo_0 = (float4(_S201->position_err_1) ).xyz;
    (&wi_0)->rel_0 = float3(0.0f) ;
    return wi_0;
}

Box_0 impactor_box_1(uint _S202, float3 _S203, float3 _S204, KernelContext_0 thread* kernelContext_23)
{
    Quat_0 q_9 = quat_of_0(float4((kernelContext_23->impactors_0+_S202)->rotation_1) );
    thread Box_0 b_22;
    (&b_22)->center_1 = _S203;
    float3 _S205 = float3(1.0f, 0.0f, 0.0f);
    thread Quat_0 _S206 = q_9;
    float3 _S207 = rotate_0(&_S206, _S205);
    (&b_22)->axis0_0 = _S207;
    float3 _S208 = float3(0.0f, 1.0f, 0.0f);
    thread Quat_0 _S209 = q_9;
    float3 _S210 = rotate_0(&_S209, _S208);
    (&b_22)->axis1_0 = _S210;
    float3 _S211 = float3(0.0f, 0.0f, 1.0f);
    thread Quat_0 _S212 = q_9;
    float3 _S213 = rotate_0(&_S212, _S211);
    (&b_22)->axis2_0 = _S213;
    (&b_22)->half_2 = _S204;
    (&b_22)->hull_at_0 = 0U;
    (&b_22)->hull_v_0 = 0U;
    (&b_22)->hull_f_0 = 0U;
    return b_22;
}

Box_0 impactor_shrunk_0(uint _S214, float _S215, const Box_0 thread* _S216)
{
    thread Box_0 shrunk_2 = *_S216;
    (&shrunk_2)->half_2 = _S216->half_2 - min(float3(_S215) , _S216->half_2 * float3(0.5f) );
    return shrunk_2;
}

bool impactor_contact_2(uint _S217, float _S218, const Box_0 thread* _S219, const Box_0 thread* _S220, uint _S221, float3 thread* _S222, float3 thread* _S223, float thread* _S224, KernelContext_0 thread* kernelContext_24)
{
    Impactor_natural_0 _S225 = *(kernelContext_24->impactors_0+_S217);
    float3 _S226 = float3(0.0f) ;
    *_S222 = _S226;
    *_S223 = _S226;
    *_S224 = 0.0f;
    float4 _S227 = float4(_S225.shape_0) ;
    if((_S227.x) == 0.0f)
    {
        bool _S228 = sphere_contact_0(_S220, _S226, _S227.y - _S218, _S222, _S223, _S224, kernelContext_24);
        if(!_S228)
        {
            return false;
        }
        *_S223 = - *_S223;
        return true;
    }
    uint _S229 = sample_count_0(_S220);
    if(_S221 < _S229)
    {
        float3 _S230 = sample_point_0(_S220, _S221, kernelContext_24);
        *_S222 = _S230;
        bool _S231 = penetration_0(_S219, _S230, _S224, _S223, kernelContext_24);
        return _S231;
    }
    float3 _S232 = sample_point_0(_S219, _S221 - _S229, kernelContext_24);
    *_S222 = _S232;
    bool _S233 = penetration_0(_S220, _S232, _S224, _S223, kernelContext_24);
    if(!_S233)
    {
        return false;
    }
    *_S223 = - *_S223;
    return true;
}

void impactor_candidate_forces_0(uint k_6, uint lane_1, uint lanes_5, KernelContext_0 thread* kernelContext_25)
{
    uint _S234;
    bool _S235;
    uint _S236 = 3U * k_6;
    uint at_1 = kernelContext_25->params_0->cand_index_0 + _S236;
    uint c_4 = kernelContext_25->index_0[at_1];
    uint slot_0 = kernelContext_25->index_0[at_1 + 1U];
    uint _S237 = kernelContext_25->index_0[at_1 + 2U];
    thread Impactor_natural_0 _S238 = *(kernelContext_25->impactors_0+_S237);
    float _S239 = kernelContext_25->params_0->dt_0;
    float3 _S240 = float3(0.0f) ;
    thread float4 data_0 = float4(*(kernelContext_25->scratch_0+(kernelContext_25->params_0->cand_base_0 + _S236))) ;
    bool hit_0;
    float3 f_sum_0;
    float3 t_sum_0;
    float3 imp_f_0;
    float3 imp_t_0;
    if(((uint4((&_S238)->cand_0) ).z) == 0U)
    {
        WorldPoint_0 _S241 = chunk_world_0(c_4, kernelContext_25);
        WorldPoint_0 _S242 = impactor_point_0(_S237, kernelContext_25);
        thread WorldPoint_0 _S243 = _S241;
        thread WorldPoint_0 _S244 = _S242;
        float3 _S245 = world_diff_0(&_S243, &_S244);
        float4 _S246 = float4((&_S238)->half_1) ;
        if(!((length(_S245)) > (_S246.w + (float4((kernelContext_25->chunks_0+c_4)->half_0) ).w)))
        {
            Box_0 _S247 = impactor_box_1(_S237, _S240, _S246.xyz, kernelContext_25);
            Box_0 _S248 = chunk_box_0(c_4, _S245, kernelContext_25);
            float4 _S249 = float4((&_S238)->mat_0) ;
            float _S250 = _S249.x;
            float _S251 = (float4((kernelContext_25->chunks_0+c_4)->cmat_0) ).x;
            float3 _S252 = _S248.center_1 - _S247.center_1;
            thread Box_0 _S253 = _S247;
            thread Box_0 _S254 = _S248;
            float _S255 = contact_stiffness_0(_S250, &_S253, _S251, &_S254, _S252);
            float4 _S256 = float4((&_S238)->geom_0) ;
            float _S257 = _S256.y;
            thread Box_0 _S258 = _S247;
            Box_0 _S259 = impactor_shrunk_0(_S237, _S257, &_S258);
            uint j_2 = lane_1;
            uint n_7 = 0U;
            for(;;)
            {
                thread Box_0 _S260 = _S248;
                uint _S261 = impactor_slots_0(&_S238, &_S260);
                _S234 = _S261;
                if(j_2 < _S261)
                {
                }
                else
                {
                    break;
                }
                thread Box_0 _S262 = _S259;
                thread Box_0 _S263 = _S248;
                thread float3 p_7;
                thread float3 nrm_0;
                thread float dep_0;
                bool _S264 = impactor_contact_2(_S237, _S257, &_S262, &_S263, j_2, &p_7, &nrm_0, &dep_0, kernelContext_25);
                if(_S264)
                {
                    n_7 = n_7 + 1U;
                }
                j_2 = j_2 + lanes_5;
            }
            uint n_8 = pair_count_sum_0(n_7, lanes_5);
            bool _S265 = ((float4((&_S238)->shape_0) ).x) == 0.0f;
            float _S266;
            if(_S265)
            {
                _S266 = _S255;
            }
            else
            {
                _S266 = _S255 / max(float(n_8), 10.0f);
            }
            if(_S265)
            {
                j_2 = 1U;
            }
            else
            {
                j_2 = n_8;
            }
            float m_1 = (float4((kernelContext_25->chunks_0+c_4)->center_0) ).w;
            float _S267 = _S249.z;
            float _S268 = m_1 * _S267 / (m_1 + _S267);
            float _S269;
            if((kernelContext_25->params_0->pair_friction_0) >= 0.0f)
            {
                _S269 = kernelContext_25->params_0->pair_friction_0;
            }
            else
            {
                _S269 = min(_S249.y, (float4((kernelContext_25->chunks_0+c_4)->cmat_0) ).y);
            }
            float3 _S270 = (float4((&_S238)->velocity_1) ).xyz + (float4((&_S238)->velocity_err_1) ).xyz;
            thread float3 vc_0;
            thread float3 wc_0;
            chunk_velocity_0(c_4, &vc_0, &wc_0, kernelContext_25);
            hit_0 = false;
            uint j_3 = lane_1;
            f_sum_0 = _S240;
            t_sum_0 = _S240;
            imp_f_0 = _S240;
            imp_t_0 = _S240;
            float diss_sum_2 = 0.0f;
            for(;;)
            {
                bool _S271 = n_8 > 0U;
                _S235 = _S271;
                bool _S272;
                if(_S271)
                {
                    _S272 = j_3 < _S234;
                }
                else
                {
                    _S272 = false;
                }
                if(_S272)
                {
                }
                else
                {
                    break;
                }
                thread Box_0 _S273 = _S259;
                thread Box_0 _S274 = _S248;
                thread float3 p_8;
                thread float3 nrm_1;
                thread float dep_1;
                bool _S275 = impactor_contact_0(&_S238, _S257, &_S273, &_S274, j_3, &p_8, &nrm_1, &dep_1, kernelContext_25);
                if(!_S275)
                {
                    j_3 = j_3 + lanes_5;
                    continue;
                }
                thread float stored_2;
                thread float diss_1;
                float3 _S276 = penalty_force_0(_S266, _S268, _S269, dep_1 * _S256.x, nrm_1, vc_0 + cross(wc_0, p_8 - _S248.center_1) - (_S270 + cross((float4((&_S238)->angular_velocity_1) ).xyz, p_8)), _S239, j_2, &stored_2, &diss_1, kernelContext_25);
                float3 f_sum_1 = f_sum_0 + _S276;
                float3 t_sum_1 = t_sum_0 + cross(p_8 - _S248.center_1, _S276);
                float3 imp_f_1 = imp_f_0 - _S276;
                float3 imp_t_1 = imp_t_0 - cross(p_8, _S276);
                float diss_sum_3 = diss_sum_2 + diss_1;
                hit_0 = true;
                f_sum_0 = f_sum_1;
                t_sum_0 = t_sum_1;
                imp_f_0 = imp_f_1;
                imp_t_0 = imp_t_1;
                diss_sum_2 = diss_sum_3;
                j_3 = j_3 + lanes_5;
            }
            float3 _S277 = pair_sum3_0(f_sum_0, lanes_5);
            float3 _S278 = pair_sum3_0(t_sum_0, lanes_5);
            float3 _S279 = pair_sum3_0(imp_f_0, lanes_5);
            float3 _S280 = pair_sum3_0(imp_t_0, lanes_5);
            float diss_sum_4 = pair_sum_0(diss_sum_2, lanes_5);
            bool _S281 = pair_any_0(hit_0, lanes_5);
            if(_S235)
            {
                thread float _S282 = data_0.z;
                thread float _S283 = data_0.w;
                comp_add1_0(&_S282, &_S283, diss_sum_4);
                data_0.w = _S283;
                data_0.z = _S282;
            }
            hit_0 = _S281;
            f_sum_0 = _S277;
            t_sum_0 = _S278;
            imp_f_0 = _S279;
            imp_t_0 = _S280;
        }
        else
        {
            hit_0 = false;
            f_sum_0 = _S240;
            t_sum_0 = _S240;
            imp_f_0 = _S240;
            imp_t_0 = _S240;
        }
    }
    else
    {
        hit_0 = false;
        f_sum_0 = _S240;
        t_sum_0 = _S240;
        imp_f_0 = _S240;
        imp_t_0 = _S240;
    }
    if(lane_1 != 0U)
    {
        return;
    }
    uint _S284 = 2U * slot_0;
    *(kernelContext_25->scratch_0+(kernelContext_25->params_0->slot_base_0 + _S284)) = packed_float4(float4(f_sum_0, 0.0f)) ;
    *(kernelContext_25->scratch_0+(kernelContext_25->params_0->slot_base_0 + _S284 + 1U)) = packed_float4(float4(t_sum_0, 0.0f)) ;
    *(kernelContext_25->scratch_0+(kernelContext_25->params_0->cand_base_0 + _S236)) = packed_float4(data_0) ;
    *(kernelContext_25->scratch_0+(kernelContext_25->params_0->cand_base_0 + _S236 + 1U)) = packed_float4(float4(imp_f_0, 0.0f)) ;
    *(kernelContext_25->scratch_0+(kernelContext_25->params_0->cand_base_0 + _S236 + 2U)) = packed_float4(float4(imp_t_0, 0.0f)) ;
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
    if(((uint4((kernelContext_26->chunks_0+c_5)->cinfo_0) ).z) == 0U)
    {
        return;
    }
    uint _S285 = 4U * c_5;
    uint at_2 = kernelContext_26->params_0->cplan_base_0 + _S285;
    float4 _S286 = float4(*(kernelContext_26->scratch_0+at_2)) ;
    float4 _S287 = float4(*(kernelContext_26->scratch_0+(at_2 + 1U))) ;
    float4 _S288 = float4(*(kernelContext_26->scratch_0+(at_2 + 2U))) ;
    float4 _S289 = float4(*(kernelContext_26->scratch_0+(at_2 + 3U))) ;
    WorldPoint_0 _S290 = chunk_world_0(c_5, kernelContext_26);
    float3 moved_0 = _S290.hi_0 - _S286.xyz + (_S290.lo_0 - _S287.xyz) + _S290.rel_0;
    float3 _S291 = float3((kernelContext_26->params_0->t_hi_0 - _S289.w + (kernelContext_26->params_0->t_lo_0 - _S287.w) + float((uint4((kernelContext_26->islands_0+(uint4((kernelContext_26->chunks_0+c_5)->info_1) ).y)->info_0) ).w - kernelContext_26->params_0->step_start_0) * kernelContext_26->params_0->dt_0)) ;
    float3 _S292 = _S289.xyz * _S291;
    float3 _S293;
    if((((uint4((kernelContext_26->chunks_0+c_5)->cinfo_0) ).w) & 2U) != 0U)
    {
        _S293 = float3(0.5f)  * kernelContext_26->params_0->gravity_0.xyz * _S291 * _S291;
    }
    else
    {
        _S293 = float3(0.0f) ;
    }
    float travel_0 = length(moved_0 - (_S292 + _S293));
    float travel_1;
    if((((uint4((kernelContext_26->chunks_0+c_5)->cinfo_0) ).w) & 1U) != 0U)
    {
        float3 th_1 = (float4(*(kernelContext_26->state_0+(_S285 + 1U))) ).xyz;
        Quat_0 _S294 = from_axis_angle_0(th_1, length(th_1));
        thread Quat_0 _S295 = quat_of_0(float4((kernelContext_26->islands_0+(uint4((kernelContext_26->chunks_0+c_5)->info_1) ).y)->rotation_0) );
        thread Quat_0 _S296 = _S294;
        Quat_0 _S297 = quat_mul_0(&_S295, &_S296);
        thread Quat_0 _S298 = quat_of_0(float4(- _S288.xyz, _S288.w));
        thread Quat_0 _S299 = _S297;
        Quat_0 _S300 = quat_mul_0(&_S298, &_S299);
        travel_1 = travel_0 + 2.0f * atan2(length(float3(_S300.x_2, _S300.y_1, _S300.z_0)), abs(_S300.w_1)) * (float4((kernelContext_26->chunks_0+c_5)->half_0) ).w;
    }
    else
    {
        travel_1 = travel_0;
    }
    if(travel_1 > (_S286.w))
    {
        (kernelContext_26->islands_0+kernelContext_26->params_0->halt_index_0)->info_0[int(2)] = ((uint4((kernelContext_26->islands_0+kernelContext_26->params_0->halt_index_0)->info_0) ).z) | 1U;
        sentinel_mark_0(1048576U, kernelContext_26);
    }
    return;
}

[[kernel]] void contact_forces(uint3 id_0 [[thread_position_in_grid]], Params_0 constant* params_1 [[buffer(0)]], Island_natural_0 device* islands_1 [[buffer(9)]], uint device* index_1 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_1 [[buffer(3)]], packed_float4 device* state_1 [[buffer(6)]], packed_float4 device* scratch_1 [[buffer(8)]], packed_float4 device* contact_state_1 [[buffer(11)]], packed_float4 device* loads_1 [[buffer(5)]], Impactor_natural_0 device* impactors_1 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_1 [[buffer(7)]], BondStatic_natural_0 device* bonds_1 [[buffer(2)]], MaterialTable_0 constant* materials_1 [[buffer(1)]])
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
    (&kernelContext_27)->bond_dyn_0 = bond_dyn_1;
    (&kernelContext_27)->bonds_0 = bonds_1;
    (&kernelContext_27)->materials_0 = materials_1;
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
    threadgroup array<uint, int(512)> g_label_narrow_1;
    (&kernelContext_27)->g_label_narrow_0 = &g_label_narrow_1;
    threadgroup uint g_changed_narrow_1;
    (&kernelContext_27)->g_changed_narrow_0 = &g_changed_narrow_1;
    uint i_4 = id_0.x;
    uint _S301 = pair_lane_count_0(&kernelContext_27);
    uint pair_threads_0 = (&kernelContext_27)->params_0->pair_count_0 * _S301;
    if(i_4 < pair_threads_0)
    {
        bool _S302 = stopped_0(&kernelContext_27);
        bool _S303 = pair_any_0(_S302, _S301);
        if(!_S303)
        {
            uint _S304 = i_4 / _S301;
            uint _S305 = i_4 % _S301;
            pair_contact_0(_S304, _S305, _S301, &kernelContext_27);
        }
        return;
    }
    uint j_4 = i_4 - pair_threads_0;
    uint cand_threads_0 = (&kernelContext_27)->params_0->cand_count_0 * _S301;
    if(j_4 < cand_threads_0)
    {
        bool _S306 = stopped_0(&kernelContext_27);
        bool _S307 = pair_any_0(_S306, _S301);
        if(!_S307)
        {
            uint _S308 = j_4 / _S301;
            uint _S309 = j_4 % _S301;
            impactor_candidate_forces_0(_S308, _S309, _S301, &kernelContext_27);
        }
        return;
    }
    uint _S310 = j_4 - cand_threads_0;
    bool _S311;
    if(_S310 < ((&kernelContext_27)->params_0->chunk_count_0))
    {
        bool _S312 = stopped_0(&kernelContext_27);
        _S311 = !_S312;
    }
    else
    {
        _S311 = false;
    }
    if(_S311)
    {
        travel_check_0(_S310, &kernelContext_27);
    }
    return;
}

uint impactor_contact_count_0(uint _S313, float _S314, const Box_0 thread* _S315, const Box_0 thread* _S316, KernelContext_0 thread* kernelContext_28)
{
    thread Impactor_natural_0 _S317 = *(kernelContext_28->impactors_0+_S313);
    uint j_5 = 0U;
    uint count_2 = 0U;
    for(;;)
    {
        uint _S318 = impactor_slots_1(&_S317, _S316);
        if(j_5 < _S318)
        {
        }
        else
        {
            break;
        }
        thread float3 p_9;
        thread float3 n_9;
        thread float d_11;
        bool _S319 = impactor_contact_2(_S313, _S314, _S315, _S316, j_5, &p_9, &n_9, &d_11, kernelContext_28);
        if(_S319)
        {
            count_2 = count_2 + 1U;
        }
        j_5 = j_5 + 1U;
    }
    return count_2;
}

[[kernel]] void impactor_shares(uint3 id_1 [[thread_position_in_grid]], Params_0 constant* params_2 [[buffer(0)]], Island_natural_0 device* islands_2 [[buffer(9)]], uint device* index_2 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_2 [[buffer(3)]], packed_float4 device* state_2 [[buffer(6)]], packed_float4 device* scratch_2 [[buffer(8)]], packed_float4 device* contact_state_2 [[buffer(11)]], packed_float4 device* loads_2 [[buffer(5)]], Impactor_natural_0 device* impactors_2 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_2 [[buffer(7)]], BondStatic_natural_0 device* bonds_2 [[buffer(2)]], MaterialTable_0 constant* materials_2 [[buffer(1)]])
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
    (&kernelContext_29)->bond_dyn_0 = bond_dyn_2;
    (&kernelContext_29)->bonds_0 = bonds_2;
    (&kernelContext_29)->materials_0 = materials_2;
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
    threadgroup array<uint, int(512)> g_label_narrow_2;
    (&kernelContext_29)->g_label_narrow_0 = &g_label_narrow_2;
    threadgroup uint g_changed_narrow_2;
    (&kernelContext_29)->g_changed_narrow_0 = &g_changed_narrow_2;
    uint k_7 = id_1.x;
    bool _S320;
    if(k_7 >= (params_2->cand_count_0))
    {
        _S320 = true;
    }
    else
    {
        bool _S321 = stopped_0(&kernelContext_29);
        _S320 = _S321;
    }
    if(_S320)
    {
        return;
    }
    uint _S322 = 3U * k_7;
    uint at_3 = (&kernelContext_29)->params_0->cand_index_0 + _S322;
    uint c_6 = (&kernelContext_29)->index_0[at_3];
    uint _S323 = (&kernelContext_29)->index_0[at_3 + 2U];
    thread Impactor_natural_0 _S324 = *((&kernelContext_29)->impactors_0+_S323);
    if(((uint4((&_S324)->cand_0) ).z) == 0U)
    {
        _S320 = ((float4((&_S324)->crush_0) ).x) > 0.0f;
    }
    else
    {
        _S320 = false;
    }
    float total_0;
    float ksum_0;
    if(_S320)
    {
        WorldPoint_0 _S325 = chunk_world_0(c_6, &kernelContext_29);
        WorldPoint_0 _S326 = impactor_point_0(_S323, &kernelContext_29);
        thread WorldPoint_0 _S327 = _S325;
        thread WorldPoint_0 _S328 = _S326;
        float3 _S329 = world_diff_0(&_S327, &_S328);
        float4 _S330 = float4((&_S324)->half_1) ;
        if(!((length(_S329)) > (_S330.w + (float4(((&kernelContext_29)->chunks_0+c_6)->half_0) ).w)))
        {
            Box_0 _S331 = impactor_box_1(_S323, float3(0.0f) , _S330.xyz, &kernelContext_29);
            Box_0 _S332 = chunk_box_0(c_6, _S329, &kernelContext_29);
            float _S333 = (float4((&_S324)->mat_0) ).x;
            float _S334 = (float4(((&kernelContext_29)->chunks_0+c_6)->cmat_0) ).x;
            float3 _S335 = _S332.center_1 - _S331.center_1;
            thread Box_0 _S336 = _S331;
            thread Box_0 _S337 = _S332;
            float _S338 = contact_stiffness_0(_S333, &_S336, _S334, &_S337, _S335);
            float _S339 = (float4((&_S324)->crush_0) ).w;
            thread Box_0 _S340 = _S331;
            Box_0 _S341 = impactor_shrunk_0(_S323, _S339, &_S340);
            thread Box_0 _S342 = _S341;
            thread Box_0 _S343 = _S332;
            uint _S344 = impactor_contact_count_0(_S323, _S339, &_S342, &_S343, &kernelContext_29);
            float _S345;
            if(((float4((&_S324)->shape_0) ).x) == 0.0f)
            {
                _S345 = _S338;
            }
            else
            {
                _S345 = _S338 / max(float(_S344), 10.0f);
            }
            uint j_6 = 0U;
            total_0 = 0.0f;
            ksum_0 = 0.0f;
            for(;;)
            {
                if(_S344 > 0U)
                {
                    thread Box_0 _S346 = _S332;
                    uint _S347 = impactor_slots_0(&_S324, &_S346);
                    _S320 = j_6 < _S347;
                }
                else
                {
                    _S320 = false;
                }
                if(_S320)
                {
                }
                else
                {
                    break;
                }
                thread Box_0 _S348 = _S341;
                thread Box_0 _S349 = _S332;
                thread float3 p_10;
                thread float3 nrm_2;
                thread float dep_2;
                bool _S350 = impactor_contact_1(&_S324, _S339, &_S348, &_S349, j_6, &p_10, &nrm_2, &dep_2, &kernelContext_29);
                if(!_S350)
                {
                    j_6 = j_6 + 1U;
                    continue;
                }
                float ksum_1 = ksum_0 + _S345;
                total_0 = total_0 + _S345 * dep_2;
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
    float4 _S351 = float4(*((&kernelContext_29)->scratch_0+((&kernelContext_29)->params_0->cand_base_0 + _S322))) ;
    *((&kernelContext_29)->scratch_0+((&kernelContext_29)->params_0->cand_base_0 + _S322)) = packed_float4(float4(total_0, ksum_0, _S351.z, _S351.w)) ;
    return;
}

[[kernel]] void impactor_crush(uint3 group_0 [[threadgroup_position_in_grid]], uint3 thread_0 [[thread_position_in_threadgroup]], Params_0 constant* params_3 [[buffer(0)]], Island_natural_0 device* islands_3 [[buffer(9)]], uint device* index_3 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_3 [[buffer(3)]], packed_float4 device* state_3 [[buffer(6)]], packed_float4 device* scratch_3 [[buffer(8)]], packed_float4 device* contact_state_3 [[buffer(11)]], packed_float4 device* loads_3 [[buffer(5)]], Impactor_natural_0 device* impactors_3 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_3 [[buffer(7)]], BondStatic_natural_0 device* bonds_3 [[buffer(2)]], MaterialTable_0 constant* materials_3 [[buffer(1)]])
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
    (&kernelContext_30)->bond_dyn_0 = bond_dyn_3;
    (&kernelContext_30)->bonds_0 = bonds_3;
    (&kernelContext_30)->materials_0 = materials_3;
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
    threadgroup array<uint, int(512)> g_label_narrow_3;
    (&kernelContext_30)->g_label_narrow_0 = &g_label_narrow_3;
    threadgroup uint g_changed_narrow_3;
    (&kernelContext_30)->g_changed_narrow_0 = &g_changed_narrow_3;
    uint ii_0 = group_0.x;
    uint tid_2 = thread_0.x;
    bool _S352;
    if(ii_0 >= (params_3->impactor_count_0))
    {
        _S352 = true;
    }
    else
    {
        bool _S353 = stopped_0(&kernelContext_30);
        _S352 = _S353;
    }
    if(_S352)
    {
        return;
    }
    Impactor_natural_0 device* _S354 = (&kernelContext_30)->impactors_0+ii_0;
    float4 _S355 = float4((*_S354).position_err_1) ;
    float4 _S356 = float4((*_S354).velocity_1) ;
    float4 _S357 = float4((*_S354).velocity_err_1) ;
    float4 _S358 = float4((*_S354).angular_velocity_1) ;
    float4 _S359 = float4((*_S354).rotation_1) ;
    float4 _S360 = float4((*_S354).inertia0_2) ;
    float4 _S361 = float4((*_S354).inertia1_2) ;
    float4 _S362 = float4((*_S354).inertia2_2) ;
    float4 _S363 = float4((*_S354).inv0_2) ;
    float4 _S364 = float4((*_S354).inv1_2) ;
    float4 _S365 = float4((*_S354).inv2_2) ;
    float4 _S366 = float4((*_S354).shape_0) ;
    float4 _S367 = float4((*_S354).half_1) ;
    float4 _S368 = float4((*_S354).mat_0) ;
    float4 _S369 = float4((*_S354).crush_0) ;
    float4 _S370 = float4((*_S354).geom_0) ;
    float4 _S371 = float4((*_S354).rotation_err_1) ;
    float4 _S372 = float4((*_S354).ledger_0) ;
    uint4 _S373 = uint4((*_S354).cand_0) ;
    float4 _S374 = float4((*_S354).momentum_1) ;
    float4 _S375 = float4((*_S354).momentum_err_1) ;
    thread Impactor_0 imp_5;
    (&imp_5)->position_1 = float4((*_S354).position_1) ;
    (&imp_5)->position_err_1 = _S355;
    (&imp_5)->velocity_1 = _S356;
    (&imp_5)->velocity_err_1 = _S357;
    (&imp_5)->angular_velocity_1 = _S358;
    (&imp_5)->rotation_1 = _S359;
    (&imp_5)->inertia0_2 = _S360;
    (&imp_5)->inertia1_2 = _S361;
    (&imp_5)->inertia2_2 = _S362;
    (&imp_5)->inv0_2 = _S363;
    (&imp_5)->inv1_2 = _S364;
    (&imp_5)->inv2_2 = _S365;
    (&imp_5)->shape_0 = _S366;
    (&imp_5)->half_1 = _S367;
    (&imp_5)->mat_0 = _S368;
    (&imp_5)->crush_0 = _S369;
    (&imp_5)->geom_0 = _S370;
    (&imp_5)->rotation_err_1 = _S371;
    (&imp_5)->ledger_0 = _S372;
    (&imp_5)->cand_0 = _S373;
    (&imp_5)->momentum_1 = _S374;
    (&imp_5)->momentum_err_1 = _S375;
    float4 _S376 = float4(0.0f) ;
    thread float4 shares_0 = _S376;
    thread float4 unused_0 = _S376;
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
        _S352 = true;
    }
    else
    {
        _S352 = ((&imp_5)->cand_0.z) != 0U;
    }
    if(_S352)
    {
        return;
    }
    (&imp_5)->geom_0 = float4(1.0f, (&imp_5)->crush_0.w, 0.0f, 0.0f);
    float total_1 = shares_0.x;
    if(((&imp_5)->crush_0.x) > 0.0f)
    {
        _S352 = ((&imp_5)->crush_0.z) < ((&imp_5)->crush_0.y);
    }
    else
    {
        _S352 = false;
    }
    if(_S352)
    {
        _S352 = total_1 > ((&imp_5)->crush_0.x);
    }
    else
    {
        _S352 = false;
    }
    if(_S352)
    {
        float extra_0 = (total_1 - (&imp_5)->crush_0.x) / shares_0.y;
        (&imp_5)->crush_0.w = (&imp_5)->crush_0.w + extra_0;
        (&imp_5)->crush_0.z = (&imp_5)->crush_0.z + (&imp_5)->crush_0.x * extra_0;
        float _S377 = (&imp_5)->crush_0.x * extra_0;
        thread float _S378 = (&imp_5)->ledger_0.z;
        thread float _S379 = (&imp_5)->ledger_0.w;
        comp_add1_0(&_S378, &_S379, _S377);
        (&imp_5)->ledger_0.w = _S379;
        (&imp_5)->ledger_0.z = _S378;
        float _S380 = (&imp_5)->crush_0.x * extra_0;
        thread float _S381 = (&imp_5)->ledger_0.x;
        thread float _S382 = (&imp_5)->ledger_0.y;
        comp_add1_0(&_S381, &_S382, _S380);
        (&imp_5)->ledger_0.y = _S382;
        (&imp_5)->ledger_0.x = _S381;
        (&imp_5)->geom_0.x = (&imp_5)->crush_0.x / total_1;
    }
    Impactor_natural_0 device* _S383 = (&kernelContext_30)->impactors_0+ii_0;
    _S383->position_1 = packed_float4(imp_5.position_1) ;
    _S383->position_err_1 = packed_float4(imp_5.position_err_1) ;
    _S383->velocity_1 = packed_float4(imp_5.velocity_1) ;
    _S383->velocity_err_1 = packed_float4(imp_5.velocity_err_1) ;
    _S383->angular_velocity_1 = packed_float4(imp_5.angular_velocity_1) ;
    _S383->rotation_1 = packed_float4(imp_5.rotation_1) ;
    _S383->inertia0_2 = packed_float4(imp_5.inertia0_2) ;
    _S383->inertia1_2 = packed_float4(imp_5.inertia1_2) ;
    _S383->inertia2_2 = packed_float4(imp_5.inertia2_2) ;
    _S383->inv0_2 = packed_float4(imp_5.inv0_2) ;
    _S383->inv1_2 = packed_float4(imp_5.inv1_2) ;
    _S383->inv2_2 = packed_float4(imp_5.inv2_2) ;
    _S383->shape_0 = packed_float4(imp_5.shape_0) ;
    _S383->half_1 = packed_float4(imp_5.half_1) ;
    _S383->mat_0 = packed_float4(imp_5.mat_0) ;
    _S383->crush_0 = packed_float4(imp_5.crush_0) ;
    _S383->geom_0 = packed_float4(imp_5.geom_0) ;
    _S383->rotation_err_1 = packed_float4(imp_5.rotation_err_1) ;
    _S383->ledger_0 = packed_float4(imp_5.ledger_0) ;
    _S383->cand_0 = packed_uint4(imp_5.cand_0) ;
    _S383->momentum_1 = packed_float4(imp_5.momentum_1) ;
    _S383->momentum_err_1 = packed_float4(imp_5.momentum_err_1) ;
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
    uint _S384 = table_0 + 4U * g_0;
    (&w_4)->island_3 = kernelContext_31->index_0[_S384];
    (&w_4)->begin_0 = kernelContext_31->index_0[_S384 + 1U];
    (&w_4)->end_0 = kernelContext_31->index_0[_S384 + 2U];
    (&w_4)->first_0 = kernelContext_31->index_0[_S384 + 3U];
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
    uint4 _S385 = uint4((kernelContext_33->islands_0+kernelContext_33->params_0->halt_index_0)->info_0) ;
    bool _S386;
    if(((_S385.z) & 1U) != 0U)
    {
        _S386 = true;
    }
    else
    {
        uint _S387 = _S385.y;
        if(_S387 != 0U)
        {
            _S386 = _S387 <= ((uint4(isl_0->info_0) ).w);
        }
        else
        {
            _S386 = false;
        }
    }
    return _S386;
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
    uint4 _S388 = uint4((kernelContext_34->islands_0+kernelContext_34->params_0->halt_index_0)->info_0) ;
    bool _S389;
    if(((_S388.z) & 1U) != 0U)
    {
        _S389 = true;
    }
    else
    {
        uint _S390 = _S388.y;
        if(_S390 != 0U)
        {
            _S389 = _S390 <= (isl_1->info_0.w);
        }
        else
        {
            _S389 = false;
        }
    }
    return _S389;
}

bool wide_runs_0(const Island_natural_0 thread* isl_2, KernelContext_0 thread* kernelContext_35)
{
    uint4 _S391 = uint4(isl_2->info_0) ;
    bool _S392;
    if(((_S391.z) & 1U) != 0U)
    {
        _S392 = true;
    }
    else
    {
        _S392 = (_S391.y) == 0U;
    }
    if(_S392)
    {
        return false;
    }
    if(((_S391.x) & 4U) == 0U)
    {
        _S392 = true;
    }
    else
    {
        bool _S393 = contact_stopped_0(isl_2, kernelContext_35);
        _S392 = !_S393;
    }
    return _S392;
}

bool wide_enter_0(uint tid_4, const Island_natural_0 thread* isl_3, KernelContext_0 thread* kernelContext_36)
{
    seen_clear_0(tid_4, kernelContext_36);
    if(tid_4 == 0U)
    {
        bool _S394 = wide_runs_0(isl_3, kernelContext_36);
        int _S395;
        if(_S394)
        {
            _S395 = int(1);
        }
        else
        {
            _S395 = int(0);
        }
        *kernelContext_36->g_wide_run_0 = uint(_S395);
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
    float4 _S396 = float4(*(kernelContext_41->loads_0+offset_0)) ;
    if(tau_0 <= (_S396.x))
    {
        return _S396.y;
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
        uint _S397 = offset_0 + i_5;
        float4 _S398 = float4(*(kernelContext_41->loads_0+_S397)) ;
        float _S399 = _S398.x;
        if(tau_0 <= _S399)
        {
            float4 _S400 = float4(*(kernelContext_41->loads_0+(_S397 - 1U))) ;
            float _S401 = _S400.x;
            float _S402 = _S400.y;
            return _S402 + (tau_0 - _S401) / max(_S399 - _S401, 1.00000000317107685e-30f) * (_S398.y - _S402);
        }
        i_5 = i_5 + 1U;
    }
    return (float4(*(kernelContext_41->loads_0+(offset_0 + count_3 - 1U))) ).y;
}

float eval_function_0(uint term_0, uint k_10, float dt_3, float shift_0, KernelContext_0 thread* kernelContext_42)
{
    uint _S403 = 5U * term_0;
    uint4 info_2 = (as_type<uint4>((float4(*(kernelContext_42->loads_0+_S403)) )));
    float4 _S404 = float4(*(kernelContext_42->loads_0+(_S403 + 3U))) ;
    float4 _S405 = float4(*(kernelContext_42->loads_0+(_S403 + 4U))) ;
    uint kind_0 = info_2.z;
    if(kind_0 == 0U)
    {
        return _S404.z;
    }
    float _S406 = time_since_0(_S404, k_10, dt_3, kernelContext_42);
    float tau_1 = _S406 + shift_0;
    float shape_1;
    if(kind_0 == 1U)
    {
        if(tau_1 <= 0.0f)
        {
            shape_1 = 0.0f;
        }
        else
        {
            float _S407 = _S405.x;
            if(tau_1 >= _S407)
            {
                shape_1 = _S405.y;
            }
            else
            {
                shape_1 = _S405.y * tau_1 / _S407;
            }
        }
        return shape_1;
    }
    bool _S408;
    if(kind_0 == 2U)
    {
        if(tau_1 < 0.0f)
        {
            _S408 = true;
        }
        else
        {
            _S408 = tau_1 > (_S405.x);
        }
        if(_S408)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S405.y * sin(3.14159274101257324f * tau_1 / _S405.x);
        }
        return shape_1;
    }
    if(kind_0 == 3U)
    {
        float sn_0 = tau_1 / _S405.y;
        if(sn_0 < 0.0f)
        {
            _S408 = true;
        }
        else
        {
            _S408 = sn_0 > 1.0f;
        }
        if(_S408)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S405.x * (1.0f - sn_0) * exp(- _S405.z * sn_0);
        }
        return shape_1;
    }
    if(kind_0 == 4U)
    {
        float _S409 = table_eval_0(info_2.w, (as_type<uint>((_S405.x))), tau_1, kernelContext_42);
        return _S409;
    }
    if(kind_0 == 5U)
    {
        (*kernelContext_42->g_seen_0)[1U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float sn_1 = tau_1 / _S405.x;
        if(sn_1 < 0.0f)
        {
            _S408 = true;
        }
        else
        {
            _S408 = sn_1 > 1.0f;
        }
        if(_S408)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = (1.0f - sn_1) * exp(- _S405.y * sn_1);
        }
        float clearing_0 = _S404.w;
        float relax_0;
        if(clearing_0 > 0.0f)
        {
            relax_0 = max(1.0f - tau_1 / clearing_0, 0.0f);
        }
        else
        {
            relax_0 = 0.0f;
        }
        float _S410 = _S405.w;
        return (_S410 + (_S405.z - _S410) * relax_0) * shape_1;
    }
    if(kind_0 == 7U)
    {
        (*kernelContext_42->g_seen_0)[2U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float _S411 = _S405.y;
        if(tau_1 < _S411)
        {
            return _S405.x;
        }
        float s_1 = tau_1 - _S411;
        float _S412 = _S405.w;
        if(s_1 > _S412)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S405.z * sin(3.14159274101257324f * s_1 / _S412);
        }
        return shape_1;
    }
    float _S413 = _S405.x;
    if(_S413 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp(1.0f - tau_1 / _S413, 0.0f, 1.0f);
}

void chunk_loads_0(uint c_7, const Quat_0 thread* rot_0, uint k_11, float dt_4, bool contact_0, float rep_shift_0, float3 thread* f_1, float3 thread* t_3, float3 thread* rf_0, float3 thread* rm_0, KernelContext_0 thread* kernelContext_43)
{
    bool _S414;
    float3 _S415 = float3(0.0f) ;
    *f_1 = _S415;
    *t_3 = _S415;
    *rf_0 = _S415;
    *rm_0 = _S415;
    uint term_1 = (uint4((kernelContext_43->chunks_0+c_7)->load_range_0) ).x;
    for(;;)
    {
        if(term_1 < ((uint4((kernelContext_43->chunks_0+c_7)->load_range_0) ).y))
        {
        }
        else
        {
            break;
        }
        (*kernelContext_43->g_seen_0)[0U] = 1U;
        uint _S416 = 5U * term_1;
        uint _S417 = (as_type<uint4>((float4(*(kernelContext_43->loads_0+_S416)) ))).y;
        bool replacement_0 = _S417 == 2U;
        float4 _S418 = float4(*(kernelContext_43->loads_0+(_S416 + 1U))) ;
        float4 _S419 = float4(*(kernelContext_43->loads_0+(_S416 + 2U))) ;
        float _S420;
        if(replacement_0)
        {
            _S420 = rep_shift_0;
        }
        else
        {
            _S420 = 0.0f;
        }
        float _S421 = eval_function_0(term_1, k_11, dt_4, _S420, kernelContext_43);
        if(replacement_0)
        {
            float3 _S422 = float3(_S421) ;
            *rf_0 = *rf_0 + _S418.xyz * _S422;
            *rm_0 = *rm_0 + _S419.xyz * _S422;
            term_1 = term_1 + 1U;
            continue;
        }
        if(_S417 == 0U)
        {
            _S414 = true;
        }
        else
        {
            _S414 = _S417 == 3U;
        }
        float3 fw_0;
        if(_S414)
        {
            fw_0 = _S418.xyz * float3(_S421) ;
        }
        else
        {
            float3 _S423 = rotate_0(rot_0, _S418.xyz);
            fw_0 = _S423 * float3((- _S421 * _S418.w)) ;
        }
        float3 lever_0;
        if(_S417 == 3U)
        {
            lever_0 = _S419.xyz - (float4(*(kernelContext_43->state_0+4U * c_7)) ).xyz;
        }
        else
        {
            lever_0 = _S419.xyz;
        }
        *f_1 = *f_1 + fw_0;
        float3 _S424 = rotate_0(rot_0, lever_0);
        *t_3 = *t_3 + cross(_S424, fw_0);
        term_1 = term_1 + 1U;
    }
    if(contact_0)
    {
        _S414 = ((uint4((kernelContext_43->chunks_0+c_7)->cinfo_0) ).z) != 0U;
    }
    else
    {
        _S414 = false;
    }
    if(_S414)
    {
        uint g_1 = (uint4((kernelContext_43->chunks_0+c_7)->cinfo_0) ).x;
        for(;;)
        {
            if(g_1 < ((uint4((kernelContext_43->chunks_0+c_7)->cinfo_0) ).y))
            {
            }
            else
            {
                break;
            }
            uint _S425 = 2U * g_1;
            *f_1 = *f_1 + (float4(*(kernelContext_43->scratch_0+(kernelContext_43->params_0->seg_base_0 + _S425))) ).xyz;
            *t_3 = *t_3 + (float4(*(kernelContext_43->scratch_0+(kernelContext_43->params_0->seg_base_0 + _S425 + 1U))) ).xyz;
            g_1 = g_1 + 1U;
        }
    }
    return;
}

void chunk_external_0(uint c_8, const Quat_0 thread* rot_1, uint k_12, float dt_5, bool contact_1, float3 thread* f_2, float3 thread* t_4, KernelContext_0 thread* kernelContext_44)
{
    thread float3 rf_1;
    thread float3 rm_1;
    chunk_loads_0(c_8, rot_1, k_12, dt_5, contact_1, 0.0f, f_2, t_4, &rf_1, &rm_1, kernelContext_44);
    return;
}

void record_chunk_load_0(uint c_9, float3 f_3, float3 t_5, KernelContext_0 thread* kernelContext_45)
{
    if((kernelContext_45->params_0->solve_mode_0) == 0U)
    {
        return;
    }
    uint _S426 = 2U * c_9;
    *(kernelContext_45->scratch_0+(kernelContext_45->params_0->cload_base_0 + _S426)) = packed_float4(float4(f_3, 0.0f)) ;
    *(kernelContext_45->scratch_0+(kernelContext_45->params_0->cload_base_0 + _S426 + 1U)) = packed_float4(float4(t_5, 0.0f)) ;
    *(kernelContext_45->scratch_0+(kernelContext_45->params_0->cframe_base_0 + _S426)) = packed_float4(float4((float4(*(kernelContext_45->scratch_0+(kernelContext_45->params_0->cframe_base_0 + _S426))) ).xyz + f_3, 0.0f)) ;
    *(kernelContext_45->scratch_0+(kernelContext_45->params_0->cframe_base_0 + _S426 + 1U)) = packed_float4(float4((float4(*(kernelContext_45->scratch_0+(kernelContext_45->params_0->cframe_base_0 + _S426 + 1U))) ).xyz + t_5, 0.0f)) ;
    return;
}

float settled_chunk_load_0(uint c_10, const Quat_0 thread* rot_2, uint k_13, float dt_6, bool contact_2, KernelContext_0 thread* kernelContext_46)
{
    thread float3 f_4;
    thread float3 t_6;
    chunk_external_0(c_10, rot_2, k_13, dt_6, contact_2, &f_4, &t_6, kernelContext_46);
    record_chunk_load_0(c_10, f_4, t_6, kernelContext_46);
    return length(f_4);
}

uint seen_bits_0(KernelContext_0 thread* kernelContext_47)
{
    uint _S427;
    if(((*kernelContext_47->g_seen_0)[0U]) != 0U)
    {
        _S427 = 32768U;
    }
    else
    {
        _S427 = 0U;
    }
    uint _S428;
    if(((*kernelContext_47->g_seen_0)[1U]) != 0U)
    {
        _S428 = 65536U;
    }
    else
    {
        _S428 = 0U;
    }
    uint _S429 = _S427 | _S428;
    if(((*kernelContext_47->g_seen_0)[2U]) != 0U)
    {
        _S427 = 131072U;
    }
    else
    {
        _S427 = 0U;
    }
    uint _S430 = _S429 | _S427;
    if(((*kernelContext_47->g_seen_0)[3U]) != 0U)
    {
        _S427 = 32U;
    }
    else
    {
        _S427 = 0U;
    }
    uint _S431 = _S430 | _S427;
    if(((*kernelContext_47->g_seen_0)[4U]) != 0U)
    {
        _S427 = 64U;
    }
    else
    {
        _S427 = 0U;
    }
    return _S431 | _S427;
}

bool wide_enter_1(uint _S432, uint _S433, KernelContext_0 thread* kernelContext_48)
{
    thread Island_natural_0 _S434 = *(kernelContext_48->islands_0+_S433);
    seen_clear_0(_S432, kernelContext_48);
    if(_S432 == 0U)
    {
        bool _S435 = wide_runs_0(&_S434, kernelContext_48);
        int _S436;
        if(_S435)
        {
            _S436 = int(1);
        }
        else
        {
            _S436 = int(0);
        }
        *kernelContext_48->g_wide_run_0 = uint(_S436);
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    return (*kernelContext_48->g_wide_run_0) != 0U;
}

[[kernel]] void wide_wake(uint3 group_1 [[threadgroup_position_in_grid]], uint3 thread_1 [[thread_position_in_threadgroup]], Params_0 constant* params_4 [[buffer(0)]], Island_natural_0 device* islands_4 [[buffer(9)]], uint device* index_4 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_4 [[buffer(3)]], packed_float4 device* state_4 [[buffer(6)]], packed_float4 device* scratch_4 [[buffer(8)]], packed_float4 device* contact_state_4 [[buffer(11)]], packed_float4 device* loads_4 [[buffer(5)]], Impactor_natural_0 device* impactors_4 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_4 [[buffer(7)]], BondStatic_natural_0 device* bonds_4 [[buffer(2)]], MaterialTable_0 constant* materials_4 [[buffer(1)]])
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
    (&kernelContext_49)->bond_dyn_0 = bond_dyn_4;
    (&kernelContext_49)->bonds_0 = bonds_4;
    (&kernelContext_49)->materials_0 = materials_4;
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
    threadgroup array<uint, int(512)> g_label_narrow_4;
    (&kernelContext_49)->g_label_narrow_0 = &g_label_narrow_4;
    threadgroup uint g_changed_narrow_4;
    (&kernelContext_49)->g_changed_narrow_0 = &g_changed_narrow_4;
    uint tid_5 = thread_1.x;
    uint _S437 = group_1.x;
    WideGroup_0 _S438 = wide_group_0(params_4->wide_chunk_table_0, _S437, &kernelContext_49);
    if(_S437 != (_S438.first_0))
    {
        return;
    }
    thread Island_natural_0 _S439 = *((&kernelContext_49)->islands_0+_S438.island_3);
    uint4 _S440 = uint4((&_S439)->info_0) ;
    uint _S441 = _S440.x;
    bool _S442;
    if((_S441 & 16U) == 0U)
    {
        _S442 = true;
    }
    else
    {
        bool _S443 = wide_enter_1(tid_5, _S438.island_3, &kernelContext_49);
        _S442 = !_S443;
    }
    if(_S442)
    {
        return;
    }
    Quat_0 _S444 = quat_of_0(float4((&_S439)->rotation_0) );
    bool _S445 = (_S441 & 4U) != 0U;
    float3 _S446 = float3(0.0f) ;
    thread float3 norm_0 = _S446;
    thread float3 unused_1 = _S446;
    uint4 _S447 = uint4((&_S439)->range_0) ;
    uint c_11 = _S447.x + tid_5;
    for(;;)
    {
        if(c_11 < (_S447.y))
        {
        }
        else
        {
            break;
        }
        uint _S448 = wide_step_0(&_S439, &kernelContext_49);
        float _S449 = (&kernelContext_49)->params_0->dt_0;
        thread Quat_0 _S450 = _S444;
        float _S451 = settled_chunk_load_0(c_11, &_S450, _S448, _S449, _S445, &kernelContext_49);
        norm_0.x = norm_0.x + _S451;
        c_11 = c_11 + 256U;
    }
    group_sum3_0(tid_5, &norm_0, &unused_1, &kernelContext_49);
    if(tid_5 != 0U)
    {
        return;
    }
    uint _S452 = seen_bits_0(&kernelContext_49);
    uint cov_0 = 1024U | _S452;
    if(((&kernelContext_49)->params_0->solve_mode_0) == 1U)
    {
        float4 _S453 = float4((&_S439)->energy_0) ;
        _S442 = (abs(norm_0.x - _S453.z)) > (_S453.w);
    }
    else
    {
        _S442 = false;
    }
    uint cov_1;
    if(_S442)
    {
        ((&kernelContext_49)->islands_0+_S438.island_3)->info_0[int(0)] = _S441 & 4294967279U;
        ((&kernelContext_49)->islands_0+_S438.island_3)->info_0[int(2)] = (_S440.z) | 4U;
        cov_1 = cov_0 | 2048U;
    }
    else
    {
        cov_1 = cov_0;
    }
    cov_mark_0(_S438.island_3, (&_S439)->coverage_0, cov_1, &kernelContext_49);
    return;
}

void wide_partials_0(uint tid_6, uint first_1, uint count_4, uint p_11, float3 thread* a_7, float3 thread* b_23, KernelContext_0 thread* kernelContext_50)
{
    float4 _S454 = float4(0.0f) ;
    thread float4 x_8 = _S454;
    thread float4 y_2 = _S454;
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
        uint _S455 = 8U * (first_1 + s_2);
        x_8 = x_8 + float4(*(kernelContext_50->scratch_0+(kernelContext_50->params_0->wide_base_0 + _S455 + p_11))) ;
        y_2 = y_2 + float4(*(kernelContext_50->scratch_0+(kernelContext_50->params_0->wide_base_0 + _S455 + p_11 + 1U))) ;
        s_2 = s_2 + 256U;
    }
    group_sum2_0(tid_6, &x_8, &y_2, kernelContext_50);
    *a_7 = x_8.xyz;
    *b_23 = y_2.xyz;
    return;
}

float3 rows_mul_0(float4 r0_0, float4 r1_0, float4 r2_0, float3 v_5)
{
    return float3(dot(r0_0.xyz, v_5), dot(r1_0.xyz, v_5), dot(r2_0.xyz, v_5));
}

void drift_angular_0(uint c_12, float3 wcom_1, float3 tr_0, float3 dv_0, float3 thread* lu_0, float3 thread* lv_0, KernelContext_0 thread* kernelContext_51)
{
    float3 r_6 = (float4((kernelContext_51->chunks_0+c_12)->center_0) ).xyz - wcom_1;
    uint _S456 = 4U * c_12;
    float3 _S457 = float3((float4((kernelContext_51->chunks_0+c_12)->scale_0) ).x) ;
    *lu_0 = *lu_0 + (cross(r_6, (float4(*(kernelContext_51->state_0+_S456)) ).xyz - tr_0) * float3((float4((kernelContext_51->chunks_0+c_12)->center_0) ).w)  + rows_mul_0(float4((kernelContext_51->chunks_0+c_12)->inertia0_1) , float4((kernelContext_51->chunks_0+c_12)->inertia1_1) , float4((kernelContext_51->chunks_0+c_12)->inertia2_1) , (float4(*(kernelContext_51->state_0+(_S456 + 1U))) ).xyz)) * _S457;
    *lv_0 = *lv_0 + (cross(r_6, (float4(*(kernelContext_51->state_0+(_S456 + 2U))) ).xyz - dv_0) * float3((float4((kernelContext_51->chunks_0+c_12)->center_0) ).w)  + rows_mul_0(float4((kernelContext_51->chunks_0+c_12)->inertia0_1) , float4((kernelContext_51->chunks_0+c_12)->inertia1_1) , float4((kernelContext_51->chunks_0+c_12)->inertia2_1) , (float4(*(kernelContext_51->state_0+(_S456 + 3U))) ).xyz)) * _S457;
    return;
}

void wide_store_0(uint slot_1, uint p_12, float3 a_8, float3 b_24, KernelContext_0 thread* kernelContext_52)
{
    uint _S458 = 8U * slot_1;
    *(kernelContext_52->scratch_0+(kernelContext_52->params_0->wide_base_0 + _S458 + p_12)) = packed_float4(float4(a_8, 0.0f)) ;
    *(kernelContext_52->scratch_0+(kernelContext_52->params_0->wide_base_0 + _S458 + p_12 + 1U)) = packed_float4(float4(b_24, 0.0f)) ;
    return;
}

[[kernel]] void wide_drift(uint3 group_2 [[threadgroup_position_in_grid]], uint3 thread_2 [[thread_position_in_threadgroup]], Params_0 constant* params_5 [[buffer(0)]], Island_natural_0 device* islands_5 [[buffer(9)]], uint device* index_5 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_5 [[buffer(3)]], packed_float4 device* state_5 [[buffer(6)]], packed_float4 device* scratch_5 [[buffer(8)]], packed_float4 device* contact_state_5 [[buffer(11)]], packed_float4 device* loads_5 [[buffer(5)]], Impactor_natural_0 device* impactors_5 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_5 [[buffer(7)]], BondStatic_natural_0 device* bonds_5 [[buffer(2)]], MaterialTable_0 constant* materials_5 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_53;
    (&kernelContext_53)->params_0 = params_5;
    (&kernelContext_53)->islands_0 = islands_5;
    (&kernelContext_53)->index_0 = index_5;
    (&kernelContext_53)->chunks_0 = chunks_5;
    (&kernelContext_53)->state_0 = state_5;
    (&kernelContext_53)->scratch_0 = scratch_5;
    (&kernelContext_53)->contact_state_0 = contact_state_5;
    (&kernelContext_53)->loads_0 = loads_5;
    (&kernelContext_53)->impactors_0 = impactors_5;
    (&kernelContext_53)->bond_dyn_0 = bond_dyn_5;
    (&kernelContext_53)->bonds_0 = bonds_5;
    (&kernelContext_53)->materials_0 = materials_5;
    threadgroup array<float4, int(32)> g_part_a_5;
    (&kernelContext_53)->g_part_a_0 = &g_part_a_5;
    threadgroup array<float4, int(32)> g_part_b_5;
    (&kernelContext_53)->g_part_b_0 = &g_part_b_5;
    threadgroup array<uint, int(5)> g_seen_5;
    (&kernelContext_53)->g_seen_0 = &g_seen_5;
    threadgroup uint g_wide_run_5;
    (&kernelContext_53)->g_wide_run_0 = &g_wide_run_5;
    threadgroup array<uint, int(4096)> g_label_5;
    (&kernelContext_53)->g_label_0 = &g_label_5;
    threadgroup uint g_changed_5;
    (&kernelContext_53)->g_changed_0 = &g_changed_5;
    threadgroup uint g_halt_5;
    (&kernelContext_53)->g_halt_0 = &g_halt_5;
    threadgroup uint g_run_5;
    (&kernelContext_53)->g_run_0 = &g_run_5;
    threadgroup array<uint, int(512)> g_label_narrow_5;
    (&kernelContext_53)->g_label_narrow_0 = &g_label_narrow_5;
    threadgroup uint g_changed_narrow_5;
    (&kernelContext_53)->g_changed_narrow_0 = &g_changed_narrow_5;
    uint tid_7 = thread_2.x;
    uint _S459 = group_2.x;
    WideGroup_0 _S460 = wide_group_0(params_5->wide_chunk_table_0, _S459, &kernelContext_53);
    Island_natural_0 device* _S461 = (&kernelContext_53)->islands_0+_S460.island_3;
    Island_natural_0 isl_7 = *_S461;
    bool _S462;
    if((((uint4((*_S461).info_0) ).x) & 17U) != 0U)
    {
        _S462 = true;
    }
    else
    {
        bool _S463 = wide_enter_1(tid_7, _S460.island_3, &kernelContext_53);
        _S462 = !_S463;
    }
    if(_S462)
    {
        return;
    }
    thread float3 tu_0;
    thread float3 pv_0;
    wide_partials_0(tid_7, _S460.first_0, isl_7.wide_groups_0, 2U, &tu_0, &pv_0, &kernelContext_53);
    float4 _S464 = float4(isl_7.wcom_0) ;
    float3 _S465 = float3(_S464.w) ;
    float3 tr_1 = tu_0 / _S465;
    float3 dv_1 = pv_0 / _S465;
    float3 _S466 = float3(0.0f) ;
    thread float3 lu_1 = _S466;
    thread float3 lv_1 = _S466;
    uint c_13 = _S460.begin_0 + tid_7;
    if(c_13 < (_S460.end_0))
    {
        drift_angular_0(c_13, _S464.xyz, tr_1, dv_1, &lu_1, &lv_1, &kernelContext_53);
    }
    group_sum3_0(tid_7, &lu_1, &lv_1, &kernelContext_53);
    if(tid_7 == 0U)
    {
        wide_store_0(_S459, 4U, lu_1, lv_1, &kernelContext_53);
    }
    return;
}

struct Rigid_0
{
    Quat_0 rot_3;
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
    (&rg_0)->rot_3 = quat_of_0(float4(isl_8->rotation_0) );
    (&rg_0)->rot_err_0 = float4(isl_8->rotation_err_0) ;
    (&rg_0)->pos_0 = (float4(isl_8->position_0) ).xyz;
    (&rg_0)->pos_err_0 = (float4(isl_8->position_err_0) ).xyz;
    (&rg_0)->vel_0 = (float4(isl_8->velocity_0) ).xyz;
    (&rg_0)->vel_err_0 = (float4(isl_8->velocity_err_0) ).xyz;
    (&rg_0)->w_5 = (float4(isl_8->angular_velocity_0) ).xyz;
    (&rg_0)->l_1 = (float4(isl_8->momentum_0) ).xyz;
    (&rg_0)->l_err_0 = (float4(isl_8->momentum_err_0) ).xyz;
    float3 _S467 = float3(0.0f) ;
    (&rg_0)->torque_0 = _S467;
    (&rg_0)->a_9 = _S467;
    (&rg_0)->alpha_0 = _S467;
    return rg_0;
}

Rigid_0 rigid_of_1(const Island_0 thread* isl_9)
{
    thread Rigid_0 rg_1;
    (&rg_1)->rot_3 = quat_of_0(isl_9->rotation_0);
    (&rg_1)->rot_err_0 = isl_9->rotation_err_0;
    (&rg_1)->pos_0 = isl_9->position_0.xyz;
    (&rg_1)->pos_err_0 = isl_9->position_err_0.xyz;
    (&rg_1)->vel_0 = isl_9->velocity_0.xyz;
    (&rg_1)->vel_err_0 = isl_9->velocity_err_0.xyz;
    (&rg_1)->w_5 = isl_9->angular_velocity_0.xyz;
    (&rg_1)->l_1 = isl_9->momentum_0.xyz;
    (&rg_1)->l_err_0 = isl_9->momentum_err_0.xyz;
    float3 _S468 = float3(0.0f) ;
    (&rg_1)->torque_0 = _S468;
    (&rg_1)->a_9 = _S468;
    (&rg_1)->alpha_0 = _S468;
    return rg_1;
}

float3 inverse_rotate_0(const Quat_0 thread* q_10, float3 v_6)
{
    thread Quat_0 c_14;
    (&c_14)->w_1 = q_10->w_1;
    (&c_14)->x_2 = - q_10->x_2;
    (&c_14)->y_1 = - q_10->y_1;
    (&c_14)->z_0 = - q_10->z_0;
    thread Quat_0 _S469 = c_14;
    float3 _S470 = rotate_0(&_S469, v_6);
    return _S470;
}

float3 inverse_rotate_1(const Quat_0 thread* q_11, float3 v_7)
{
    thread Quat_0 c_15;
    (&c_15)->w_1 = q_11->w_1;
    (&c_15)->x_2 = - q_11->x_2;
    (&c_15)->y_1 = - q_11->y_1;
    (&c_15)->z_0 = - q_11->z_0;
    thread Quat_0 _S471 = c_15;
    float3 _S472 = rotate_0(&_S471, v_7);
    return _S472;
}

float3 world_mul_0(const Quat_0 thread* q_12, float4 r0_1, float4 r1_1, float4 r2_1, float3 v_8)
{
    float3 _S473 = inverse_rotate_1(q_12, v_8);
    float3 _S474 = rotate_1(q_12, rows_mul_0(r0_1, r1_1, r2_1, _S473));
    return _S474;
}

void rigid_acceleration_0(const Island_natural_0 thread* isl_10, Rigid_0 thread* rg_2, float3 f_5, float3 t_7)
{
    float4 _S475 = float4(isl_10->inertia0_0) ;
    float4 _S476 = float4(isl_10->inertia1_0) ;
    float4 _S477 = float4(isl_10->inertia2_0) ;
    thread Quat_0 _S478 = rg_2->rot_3;
    float3 _S479 = world_mul_0(&_S478, _S475, _S476, _S477, rg_2->w_5);
    rg_2->a_9 = f_5 / float3((float4(isl_10->com_0) ).w) ;
    float4 _S480 = float4(isl_10->inv0_0) ;
    float4 _S481 = float4(isl_10->inv1_0) ;
    float4 _S482 = float4(isl_10->inv2_0) ;
    float3 _S483 = t_7 - cross(rg_2->w_5, _S479);
    thread Quat_0 _S484 = rg_2->rot_3;
    float3 _S485 = world_mul_0(&_S484, _S480, _S481, _S482, _S483);
    rg_2->alpha_0 = _S485;
    rg_2->torque_0 = t_7;
    return;
}

void rigid_acceleration_1(const Island_0 thread* isl_11, Rigid_0 thread* rg_3, float3 f_6, float3 t_8)
{
    thread Quat_0 _S486 = rg_3->rot_3;
    float3 _S487 = world_mul_0(&_S486, isl_11->inertia0_0, isl_11->inertia1_0, isl_11->inertia2_0, rg_3->w_5);
    rg_3->a_9 = f_6 / float3(isl_11->com_0.w) ;
    float3 _S488 = t_8 - cross(rg_3->w_5, _S487);
    thread Quat_0 _S489 = rg_3->rot_3;
    float3 _S490 = world_mul_0(&_S489, isl_11->inv0_0, isl_11->inv1_0, isl_11->inv2_0, _S488);
    rg_3->alpha_0 = _S490;
    rg_3->torque_0 = t_8;
    return;
}

Rigid_0 wide_rigid_frame_0(uint tid_8, const Island_natural_0 thread* isl_12, const WideGroup_0 thread* wg_0, KernelContext_0 thread* kernelContext_54)
{
    Rigid_0 _S491 = rigid_of_0(isl_12);
    thread Rigid_0 rg_4 = _S491;
    if((((uint4(isl_12->info_0) ).x) & 1U) == 0U)
    {
        thread float3 f_7;
        thread float3 t_9;
        wide_partials_0(tid_8, wg_0->first_0, isl_12->wide_groups_0, 0U, &f_7, &t_9, kernelContext_54);
        rigid_acceleration_0(isl_12, &rg_4, f_7, t_9);
    }
    return rg_4;
}

Rigid_0 wide_rigid_frame_1(uint tid_9, const Island_natural_0 thread* isl_13, const WideGroup_0 thread* wg_1, KernelContext_0 thread* kernelContext_55)
{
    Rigid_0 _S492 = rigid_of_0(isl_13);
    thread Rigid_0 rg_5 = _S492;
    if((((uint4(isl_13->info_0) ).x) & 1U) == 0U)
    {
        thread float3 f_8;
        thread float3 t_10;
        wide_partials_0(tid_9, wg_1->first_0, isl_13->wide_groups_0, 0U, &f_8, &t_10, kernelContext_55);
        rigid_acceleration_0(isl_13, &rg_5, f_8, t_10);
    }
    return rg_5;
}

void comp_add_0(float3 thread* sum_1, float3 thread* err_1, float3 x_9)
{
    float3 t_11 = *sum_1 + x_9;
    float3 _S493 = abs(x_9);
    *err_1 = *err_1 + (select(x_9, *sum_1, (abs(*sum_1)) >= _S493) - t_11 + select(*sum_1, x_9, (abs(*sum_1)) >= _S493));
    *sum_1 = t_11;
    return;
}

float3 turn_difference_0(float3 omega_0, float dt_7, float3 v_9)
{
    float _S494 = length(omega_0);
    float angle_1 = _S494 * dt_7;
    if(angle_1 < 1.00000000317107685e-30f)
    {
        return float3(0.0f) ;
    }
    float3 a_10 = omega_0 / float3(_S494) ;
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
    float4 t_12 = *sum_2 + x_10;
    float4 _S495 = abs(x_10);
    *err_2 = *err_2 + (select(x_10, *sum_2, (abs(*sum_2)) >= _S495) - t_12 + select(*sum_2, x_10, (abs(*sum_2)) >= _S495));
    *sum_2 = t_12;
    return;
}

void quat_accumulate_0(Quat_0 thread* hi_1, float4 thread* lo_1, float4 x_11)
{
    thread Quat_0 _S496 = *hi_1;
    float4 _S497 = quat_vec_0(&_S496);
    thread float4 sum_3 = _S497;
    comp_add4_0(&sum_3, lo_1, x_11);
    float4 t_13 = sum_3 + *lo_1;
    *lo_1 = *lo_1 - (t_13 - sum_3);
    *hi_1 = quat_of_0(t_13);
    return;
}

void turn_left_0(Quat_0 thread* hi_2, float4 thread* lo_2, float3 omega_1, float dt_8)
{
    float _S498 = length(omega_1);
    float angle_3 = _S498 * dt_8;
    if(angle_3 < 1.00000000317107685e-30f)
    {
        return;
    }
    float4 d_12 = turn_minus_one_0(omega_1 / float3(_S498) , angle_3);
    thread Quat_0 dq_0;
    (&dq_0)->x_2 = d_12.x;
    (&dq_0)->y_1 = d_12.y;
    (&dq_0)->z_0 = d_12.z;
    (&dq_0)->w_1 = d_12.w;
    thread Quat_0 _S499 = dq_0;
    thread Quat_0 _S500 = *hi_2;
    Quat_0 _S501 = quat_mul_0(&_S499, &_S500);
    thread Quat_0 _S502 = _S501;
    float4 _S503 = quat_vec_0(&_S502);
    quat_accumulate_0(hi_2, lo_2, _S503);
    return;
}

void integrate_rigid_0(const Island_natural_0 thread* isl_14, Rigid_0 thread* rg_6, float dt_9)
{
    float3 _S504 = float3(dt_9) ;
    comp_add_0(&rg_6->l_1, &rg_6->l_err_0, rg_6->torque_0 * _S504);
    float3 l_2 = rg_6->l_1 + rg_6->l_err_0;
    comp_add_0(&rg_6->vel_0, &rg_6->vel_err_0, rg_6->a_9 * _S504);
    float3 vel_1 = rg_6->vel_0 + rg_6->vel_err_0;
    float4 _S505 = float4(isl_14->inv0_0) ;
    float4 _S506 = float4(isl_14->inv1_0) ;
    float4 _S507 = float4(isl_14->inv2_0) ;
    thread Quat_0 _S508 = rg_6->rot_3;
    float3 _S509 = world_mul_0(&_S508, _S505, _S506, _S507, l_2);
    float3 _S510 = vel_1 * _S504;
    float3 _S511 = (float4(isl_14->com_0) ).xyz;
    thread Quat_0 _S512 = rg_6->rot_3;
    float3 _S513 = rotate_0(&_S512, _S511);
    comp_add_0(&rg_6->pos_0, &rg_6->pos_err_0, _S510 - turn_difference_0(_S509, dt_9, _S513));
    turn_left_0(&rg_6->rot_3, &rg_6->rot_err_0, _S509, dt_9);
    thread Quat_0 _S514 = rg_6->rot_3;
    float3 _S515 = world_mul_0(&_S514, _S505, _S506, _S507, l_2);
    rg_6->w_5 = _S515;
    return;
}

void integrate_rigid_1(const Island_0 thread* isl_15, Rigid_0 thread* rg_7, float dt_10)
{
    float3 _S516 = float3(dt_10) ;
    comp_add_0(&rg_7->l_1, &rg_7->l_err_0, rg_7->torque_0 * _S516);
    float3 l_3 = rg_7->l_1 + rg_7->l_err_0;
    comp_add_0(&rg_7->vel_0, &rg_7->vel_err_0, rg_7->a_9 * _S516);
    float3 vel_2 = rg_7->vel_0 + rg_7->vel_err_0;
    float4 _S517 = isl_15->inv0_0;
    float4 _S518 = isl_15->inv1_0;
    float4 _S519 = isl_15->inv2_0;
    thread Quat_0 _S520 = rg_7->rot_3;
    float3 _S521 = world_mul_0(&_S520, isl_15->inv0_0, isl_15->inv1_0, isl_15->inv2_0, l_3);
    float3 _S522 = vel_2 * _S516;
    float3 _S523 = isl_15->com_0.xyz;
    thread Quat_0 _S524 = rg_7->rot_3;
    float3 _S525 = rotate_0(&_S524, _S523);
    comp_add_0(&rg_7->pos_0, &rg_7->pos_err_0, _S522 - turn_difference_0(_S521, dt_10, _S525));
    turn_left_0(&rg_7->rot_3, &rg_7->rot_err_0, _S521, dt_10);
    thread Quat_0 _S526 = rg_7->rot_3;
    float3 _S527 = world_mul_0(&_S526, _S517, _S518, _S519, l_3);
    rg_7->w_5 = _S527;
    return;
}

void drift_apply_0(uint c_16, float3 wcom_2, float3 tr_2, float3 phi_0, float3 dv_2, float3 dw_0, KernelContext_0 thread* kernelContext_56)
{
    float3 r_7 = (float4((kernelContext_56->chunks_0+c_16)->center_0) ).xyz - wcom_2;
    uint _S528 = 4U * c_16;
    *(kernelContext_56->state_0+_S528) = packed_float4(float4((float4(*(kernelContext_56->state_0+_S528)) ).xyz - (tr_2 + cross(phi_0, r_7)), (float4(*(kernelContext_56->state_0+_S528)) ).w)) ;
    uint _S529 = _S528 + 1U;
    *(kernelContext_56->state_0+_S529) = packed_float4(float4((float4(*(kernelContext_56->state_0+_S529)) ).xyz - phi_0, (float4(*(kernelContext_56->state_0+_S529)) ).w)) ;
    uint _S530 = _S528 + 2U;
    *(kernelContext_56->state_0+_S530) = packed_float4(float4((float4(*(kernelContext_56->state_0+_S530)) ).xyz - (dv_2 + cross(dw_0, r_7)), (float4(*(kernelContext_56->state_0+_S530)) ).w)) ;
    uint _S531 = _S528 + 3U;
    *(kernelContext_56->state_0+_S531) = packed_float4(float4((float4(*(kernelContext_56->state_0+_S531)) ).xyz - dw_0, (float4(*(kernelContext_56->state_0+_S531)) ).w)) ;
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
    thread Quat_0 _S532 = *hi_3;
    thread Quat_0 _S533 = dq_1;
    Quat_0 _S534 = quat_mul_0(&_S532, &_S533);
    thread Quat_0 _S535 = _S534;
    float4 _S536 = quat_vec_0(&_S535);
    quat_accumulate_0(hi_3, lo_3, _S536);
    return;
}

void drift_rigid_0(const Island_natural_0 thread* isl_16, Rigid_0 thread* rg_8, float3 tr_3, float3 phi_2, float3 dv_3, float3 dw_1)
{
    float3 wcom_3 = (float4(isl_16->wcom_0) ).xyz;
    Quat_0 rot_4 = rg_8->rot_3;
    float3 _S537 = tr_3 - cross(phi_2, wcom_3);
    thread Quat_0 _S538 = rg_8->rot_3;
    float3 _S539 = rotate_0(&_S538, _S537);
    comp_add_0(&rg_8->pos_0, &rg_8->pos_err_0, _S539);
    thread Quat_0 _S540 = rg_8->rot_3;
    float3 _S541 = inverse_rotate_0(&_S540, rg_8->w_5);
    float4 _S542 = float4(isl_16->inertia0_0) ;
    float4 _S543 = float4(isl_16->inertia1_0) ;
    float4 _S544 = float4(isl_16->inertia2_0) ;
    float3 _S545 = cross(phi_2, rows_mul_0(_S542, _S543, _S544, _S541)) - rows_mul_0(_S542, _S543, _S544, cross(phi_2, _S541));
    thread Quat_0 _S546 = rg_8->rot_3;
    float3 _S547 = rotate_0(&_S546, _S545);
    turn_right_0(&rg_8->rot_3, &rg_8->rot_err_0, phi_2);
    float3 _S548 = dv_3 + cross(dw_1, (float4(isl_16->com_0) ).xyz - wcom_3);
    thread Quat_0 _S549 = rot_4;
    float3 _S550 = rotate_0(&_S549, _S548);
    comp_add_0(&rg_8->vel_0, &rg_8->vel_err_0, _S550);
    thread Quat_0 _S551 = rot_4;
    float3 _S552 = rotate_0(&_S551, dw_1);
    rg_8->w_5 = rg_8->w_5 + _S552;
    thread Quat_0 _S553 = rg_8->rot_3;
    float3 _S554 = world_mul_0(&_S553, _S542, _S543, _S544, _S552);
    comp_add_0(&rg_8->l_1, &rg_8->l_err_0, _S547 + _S554);
    return;
}

void drift_rigid_1(const Island_0 thread* isl_17, Rigid_0 thread* rg_9, float3 tr_4, float3 phi_3, float3 dv_4, float3 dw_2)
{
    float3 wcom_4 = isl_17->wcom_0.xyz;
    Quat_0 rot_5 = rg_9->rot_3;
    float3 _S555 = tr_4 - cross(phi_3, wcom_4);
    thread Quat_0 _S556 = rg_9->rot_3;
    float3 _S557 = rotate_0(&_S556, _S555);
    comp_add_0(&rg_9->pos_0, &rg_9->pos_err_0, _S557);
    thread Quat_0 _S558 = rg_9->rot_3;
    float3 _S559 = inverse_rotate_0(&_S558, rg_9->w_5);
    float4 _S560 = isl_17->inertia0_0;
    float4 _S561 = isl_17->inertia1_0;
    float4 _S562 = isl_17->inertia2_0;
    float3 _S563 = cross(phi_3, rows_mul_0(isl_17->inertia0_0, isl_17->inertia1_0, isl_17->inertia2_0, _S559)) - rows_mul_0(isl_17->inertia0_0, isl_17->inertia1_0, isl_17->inertia2_0, cross(phi_3, _S559));
    thread Quat_0 _S564 = rg_9->rot_3;
    float3 _S565 = rotate_0(&_S564, _S563);
    turn_right_0(&rg_9->rot_3, &rg_9->rot_err_0, phi_3);
    float3 _S566 = dv_4 + cross(dw_2, isl_17->com_0.xyz - wcom_4);
    thread Quat_0 _S567 = rot_5;
    float3 _S568 = rotate_0(&_S567, _S566);
    comp_add_0(&rg_9->vel_0, &rg_9->vel_err_0, _S568);
    thread Quat_0 _S569 = rot_5;
    float3 _S570 = rotate_0(&_S569, dw_2);
    rg_9->w_5 = rg_9->w_5 + _S570;
    thread Quat_0 _S571 = rg_9->rot_3;
    float3 _S572 = world_mul_0(&_S571, _S560, _S561, _S562, _S570);
    comp_add_0(&rg_9->l_1, &rg_9->l_err_0, _S565 + _S572);
    return;
}

[[kernel]] void wide_rigid(uint3 group_3 [[threadgroup_position_in_grid]], uint3 thread_3 [[thread_position_in_threadgroup]], Params_0 constant* params_6 [[buffer(0)]], Island_natural_0 device* islands_6 [[buffer(9)]], uint device* index_6 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_6 [[buffer(3)]], packed_float4 device* state_6 [[buffer(6)]], packed_float4 device* scratch_6 [[buffer(8)]], packed_float4 device* contact_state_6 [[buffer(11)]], packed_float4 device* loads_6 [[buffer(5)]], Impactor_natural_0 device* impactors_6 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_6 [[buffer(7)]], BondStatic_natural_0 device* bonds_6 [[buffer(2)]], MaterialTable_0 constant* materials_6 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_57;
    (&kernelContext_57)->params_0 = params_6;
    (&kernelContext_57)->islands_0 = islands_6;
    (&kernelContext_57)->index_0 = index_6;
    (&kernelContext_57)->chunks_0 = chunks_6;
    (&kernelContext_57)->state_0 = state_6;
    (&kernelContext_57)->scratch_0 = scratch_6;
    (&kernelContext_57)->contact_state_0 = contact_state_6;
    (&kernelContext_57)->loads_0 = loads_6;
    (&kernelContext_57)->impactors_0 = impactors_6;
    (&kernelContext_57)->bond_dyn_0 = bond_dyn_6;
    (&kernelContext_57)->bonds_0 = bonds_6;
    (&kernelContext_57)->materials_0 = materials_6;
    threadgroup array<float4, int(32)> g_part_a_6;
    (&kernelContext_57)->g_part_a_0 = &g_part_a_6;
    threadgroup array<float4, int(32)> g_part_b_6;
    (&kernelContext_57)->g_part_b_0 = &g_part_b_6;
    threadgroup array<uint, int(5)> g_seen_6;
    (&kernelContext_57)->g_seen_0 = &g_seen_6;
    threadgroup uint g_wide_run_6;
    (&kernelContext_57)->g_wide_run_0 = &g_wide_run_6;
    threadgroup array<uint, int(4096)> g_label_6;
    (&kernelContext_57)->g_label_0 = &g_label_6;
    threadgroup uint g_changed_6;
    (&kernelContext_57)->g_changed_0 = &g_changed_6;
    threadgroup uint g_halt_6;
    (&kernelContext_57)->g_halt_0 = &g_halt_6;
    threadgroup uint g_run_6;
    (&kernelContext_57)->g_run_0 = &g_run_6;
    threadgroup array<uint, int(512)> g_label_narrow_6;
    (&kernelContext_57)->g_label_narrow_0 = &g_label_narrow_6;
    threadgroup uint g_changed_narrow_6;
    (&kernelContext_57)->g_changed_narrow_0 = &g_changed_narrow_6;
    uint tid_10 = thread_3.x;
    uint _S573 = group_3.x;
    WideGroup_0 _S574 = wide_group_0(params_6->wide_chunk_table_0, _S573, &kernelContext_57);
    thread Island_natural_0 _S575 = *((&kernelContext_57)->islands_0+_S574.island_3);
    uint _S576 = (uint4((&_S575)->info_0) ).x;
    bool _S577;
    if((_S576 & 1U) != 0U)
    {
        _S577 = true;
    }
    else
    {
        bool _S578 = wide_enter_1(tid_10, _S574.island_3, &kernelContext_57);
        _S577 = !_S578;
    }
    if(_S577)
    {
        return;
    }
    if((_S576 & 16U) != 0U)
    {
        if(_S573 != (_S574.first_0))
        {
            return;
        }
        thread WideGroup_0 _S579 = _S574;
        Rigid_0 _S580 = wide_rigid_frame_0(tid_10, &_S575, &_S579, &kernelContext_57);
        thread Rigid_0 rs_0 = _S580;
        if(tid_10 != 0U)
        {
            _S577 = true;
        }
        else
        {
            _S577 = (_S576 & 2U) != 0U;
        }
        if(_S577)
        {
            return;
        }
        integrate_rigid_0(&_S575, &rs_0, (&kernelContext_57)->params_0->dt_0);
        thread Quat_0 _S581 = (&rs_0)->rot_3;
        float4 _S582 = quat_vec_0(&_S581);
        ((&kernelContext_57)->islands_0+_S574.island_3)->rotation_0 = packed_float4(_S582) ;
        ((&kernelContext_57)->islands_0+_S574.island_3)->rotation_err_0 = packed_float4((&rs_0)->rot_err_0) ;
        ((&kernelContext_57)->islands_0+_S574.island_3)->position_0 = packed_float4(float4((&rs_0)->pos_0, 0.0f)) ;
        ((&kernelContext_57)->islands_0+_S574.island_3)->position_err_0 = packed_float4(float4((&rs_0)->pos_err_0, 0.0f)) ;
        ((&kernelContext_57)->islands_0+_S574.island_3)->velocity_0 = packed_float4(float4((&rs_0)->vel_0, 0.0f)) ;
        ((&kernelContext_57)->islands_0+_S574.island_3)->velocity_err_0 = packed_float4(float4((&rs_0)->vel_err_0, 0.0f)) ;
        ((&kernelContext_57)->islands_0+_S574.island_3)->angular_velocity_0 = packed_float4(float4((&rs_0)->w_5, 0.0f)) ;
        ((&kernelContext_57)->islands_0+_S574.island_3)->momentum_0 = packed_float4(float4((&rs_0)->l_1, 0.0f)) ;
        ((&kernelContext_57)->islands_0+_S574.island_3)->momentum_err_0 = packed_float4(float4((&rs_0)->l_err_0, 0.0f)) ;
        return;
    }
    thread float3 tu_1;
    thread float3 pv_1;
    wide_partials_0(tid_10, _S574.first_0, (&_S575)->wide_groups_0, 2U, &tu_1, &pv_1, &kernelContext_57);
    thread float3 lu_2;
    thread float3 lv_2;
    wide_partials_0(tid_10, _S574.first_0, (&_S575)->wide_groups_0, 4U, &lu_2, &lv_2, &kernelContext_57);
    float4 _S583 = float4((&_S575)->wcom_0) ;
    float3 _S584 = float3(_S583.w) ;
    float3 tr_5 = tu_1 / _S584;
    float3 dv_5 = pv_1 / _S584;
    float4 _S585 = float4((&_S575)->winv0_0) ;
    float4 _S586 = float4((&_S575)->winv1_0) ;
    float4 _S587 = float4((&_S575)->winv2_0) ;
    float3 phi_4 = rows_mul_0(_S585, _S586, _S587, lu_2);
    float3 dw_3 = rows_mul_0(_S585, _S586, _S587, lv_2);
    uint c_17 = _S574.begin_0 + tid_10;
    if(c_17 < (_S574.end_0))
    {
        drift_apply_0(c_17, _S583.xyz, tr_5, phi_4, dv_5, dw_3, &kernelContext_57);
    }
    if(_S573 != (_S574.first_0))
    {
        return;
    }
    thread WideGroup_0 _S588 = _S574;
    Rigid_0 _S589 = wide_rigid_frame_0(tid_10, &_S575, &_S588, &kernelContext_57);
    thread Rigid_0 rg_10 = _S589;
    if(tid_10 != 0U)
    {
        return;
    }
    if(!((_S576 & 2U) != 0U))
    {
        integrate_rigid_0(&_S575, &rg_10, (&kernelContext_57)->params_0->dt_0);
        drift_rigid_0(&_S575, &rg_10, tr_5, phi_4, dv_5, dw_3);
    }
    thread Quat_0 _S590 = (&rg_10)->rot_3;
    float4 _S591 = quat_vec_0(&_S590);
    ((&kernelContext_57)->islands_0+_S574.island_3)->rotation_0 = packed_float4(_S591) ;
    ((&kernelContext_57)->islands_0+_S574.island_3)->rotation_err_0 = packed_float4((&rg_10)->rot_err_0) ;
    ((&kernelContext_57)->islands_0+_S574.island_3)->position_0 = packed_float4(float4((&rg_10)->pos_0, 0.0f)) ;
    ((&kernelContext_57)->islands_0+_S574.island_3)->position_err_0 = packed_float4(float4((&rg_10)->pos_err_0, 0.0f)) ;
    ((&kernelContext_57)->islands_0+_S574.island_3)->velocity_0 = packed_float4(float4((&rg_10)->vel_0, 0.0f)) ;
    ((&kernelContext_57)->islands_0+_S574.island_3)->velocity_err_0 = packed_float4(float4((&rg_10)->vel_err_0, 0.0f)) ;
    ((&kernelContext_57)->islands_0+_S574.island_3)->angular_velocity_0 = packed_float4(float4((&rg_10)->w_5, 0.0f)) ;
    ((&kernelContext_57)->islands_0+_S574.island_3)->momentum_0 = packed_float4(float4((&rg_10)->l_1, 0.0f)) ;
    ((&kernelContext_57)->islands_0+_S574.island_3)->momentum_err_0 = packed_float4(float4((&rg_10)->l_err_0, 0.0f)) ;
    return;
}

bool connected_0(const JointState_0 thread* st_0, bool has_rebar_0)
{
    bool _S592;
    if((st_0->damage_0) < 1.0f)
    {
        _S592 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S592 = (st_0->rebar_broken_0) == 0.0f;
        }
        else
        {
            _S592 = false;
        }
    }
    return _S592;
}

bool island_connected_0(uint tid_11, const Island_0 thread* isl_18, KernelContext_0 thread* kernelContext_58)
{
    uint _S593 = isl_18->range_0.x;
    uint n_10 = isl_18->range_0.y - _S593;
    bool converged_0;
    if(n_10 > 4096U)
    {
        converged_0 = true;
    }
    else
    {
        converged_0 = (kernelContext_58->params_0->device_connect_0) == 0U;
    }
    if(converged_0)
    {
        return false;
    }
    uint c_18 = tid_11;
    for(;;)
    {
        if(c_18 < n_10)
        {
        }
        else
        {
            break;
        }
        (*kernelContext_58->g_label_0)[c_18] = c_18;
        c_18 = c_18 + 256U;
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
            *kernelContext_58->g_changed_0 = 0U;
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);
        c_18 = tid_11;
        for(;;)
        {
            if(c_18 < n_10)
            {
            }
            else
            {
                break;
            }
            uint gc_0 = _S593 + c_18;
            uint _S594 = kernelContext_58->index_0[gc_0];
            uint l_4 = (*kernelContext_58->g_label_0)[c_18];
            uint e_2 = _S594;
            for(;;)
            {
                if(e_2 < (kernelContext_58->index_0)[gc_0 + 1U])
                {
                }
                else
                {
                    break;
                }
                uint entry_1 = kernelContext_58->index_0[e_2];
                uint bond_0 = entry_1 >> 1U;
                bool _S595 = ((float4((kernelContext_58->bonds_0+bond_0)->law_0.stiff1_0) ).w) != 0.0f;
                thread JointState_0 _S596 = (kernelContext_58->bond_dyn_0+bond_0)->js_0;
                bool _S597 = connected_0(&_S596, _S595);
                if(!_S597)
                {
                    e_2 = e_2 + 1U;
                    continue;
                }
                uint other_0;
                if((entry_1 & 1U) == 0U)
                {
                    other_0 = (uint4((kernelContext_58->bonds_0+bond_0)->law_0.ids_0) ).z;
                }
                else
                {
                    other_0 = (uint4((kernelContext_58->bonds_0+bond_0)->law_0.ids_0) ).y;
                }
                l_4 = min(l_4, (*kernelContext_58->g_label_0)[other_0 - _S593]);
                e_2 = e_2 + 1U;
            }
            uint _S598 = min(l_4, (*kernelContext_58->g_label_0)[l_4]);
            if(_S598 < (*kernelContext_58->g_label_0)[c_18])
            {
                (*kernelContext_58->g_label_0)[c_18] = _S598;
                *kernelContext_58->g_changed_0 = 1U;
            }
            c_18 = c_18 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);
        bool converged_1 = (*kernelContext_58->g_changed_0) == 0U;
        threadgroup_barrier(mem_flags::mem_threadgroup);
        if(converged_1)
        {
            converged_0 = converged_1;
            break;
        }
        uint _S599 = pass_0 + 1U;
        converged_0 = converged_1;
        pass_0 = _S599;
    }
    if(!converged_0)
    {
        return false;
    }
    if(tid_11 == 0U)
    {
        *kernelContext_58->g_changed_0 = 0U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    c_18 = tid_11;
    for(;;)
    {
        if(c_18 < n_10)
        {
        }
        else
        {
            break;
        }
        if(((*kernelContext_58->g_label_0)[c_18]) != 0U)
        {
            *kernelContext_58->g_changed_0 = 1U;
        }
        c_18 = c_18 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    return (*kernelContext_58->g_changed_0) == 0U;
}

void write_probe_0(uint slot_2, uint k_14, float value_0, KernelContext_0 thread* kernelContext_59)
{
    uint at_4 = kernelContext_59->params_0->probe_base_0 * 4U + slot_2 * kernelContext_59->params_0->probe_stride_0 + k_14;
    thread float4 v_10 = float4(*(kernelContext_59->scratch_0+at_4 / 4U)) ;
    v_10[at_4 % 4U] = value_0;
    *(kernelContext_59->scratch_0+at_4 / 4U) = packed_float4(v_10) ;
    return;
}

void record_probes_0(const Island_0 thread* isl_19, const Rigid_0 thread* rg_11, uint k_15, KernelContext_0 thread* kernelContext_60)
{
    uint4 _S600 = isl_19->probes_0;
    uint at_5 = isl_19->probes_0.x;
    for(;;)
    {
        if(at_5 < (_S600.y))
        {
        }
        else
        {
            break;
        }
        uint4 info_3 = (as_type<uint4>((float4(*(kernelContext_60->loads_0+at_5)) )));
        float4 _S601 = float4(*(kernelContext_60->loads_0+(at_5 + 1U))) ;
        float4 _S602 = float4(*(kernelContext_60->loads_0+(at_5 + 2U))) ;
        float4 _S603 = float4(*(kernelContext_60->loads_0+(at_5 + 3U))) ;
        uint kind_1 = info_3.x;
        uint i_6 = info_3.y;
        float value_1;
        if(kind_1 == 0U)
        {
            float3 small_0 = (float4(*(kernelContext_60->state_0+4U * i_6)) ).xyz + float3(_S601.w, _S602.w, _S603.w);
            float3 _S604 = rg_11->pos_0 - _S602.xyz;
            float3 _S605 = rotate_0(&rg_11->rot_3, (float4((kernelContext_60->chunks_0+i_6)->center_0) ).xyz);
            float3 _S606 = _S604 + _S605;
            float3 _S607 = rg_11->pos_err_0 - _S603.xyz;
            float3 _S608 = rotate_0(&rg_11->rot_3, small_0);
            value_1 = dot(_S606 + (_S607 + _S608), _S601.xyz);
        }
        else
        {
            if(kind_1 == 1U)
            {
                uint _S609 = 4U * i_6;
                float3 _S610 = rotate_0(&rg_11->rot_3, (float4((kernelContext_60->chunks_0+i_6)->center_0) ).xyz + (float4(*(kernelContext_60->state_0+_S609)) ).xyz - isl_19->com_0.xyz);
                float3 _S611 = rg_11->vel_0 + rg_11->vel_err_0 + cross(rg_11->w_5, _S610);
                float3 _S612 = rotate_0(&rg_11->rot_3, (float4(*(kernelContext_60->state_0+(_S609 + 2U))) ).xyz);
                value_1 = dot(_S611 + _S612, _S601.xyz);
            }
            else
            {
                if(kind_1 == 2U)
                {
                    uint _S613 = 3U * i_6;
                    float3 f_9 = (float4(*(kernelContext_60->scratch_0+_S613)) ).xyz;
                    bool _S614 = (info_3.z) == 0U;
                    float3 mc_0;
                    if(_S614)
                    {
                        mc_0 = (float4(*(kernelContext_60->scratch_0+(_S613 + 1U))) ).xyz;
                    }
                    else
                    {
                        mc_0 = (float4(*(kernelContext_60->scratch_0+(_S613 + 2U))) ).xyz;
                    }
                    float3 fc_0;
                    if(_S614)
                    {
                        fc_0 = f_9;
                    }
                    else
                    {
                        fc_0 = - f_9;
                    }
                    value_1 = dot(fc_0, _S601.xyz) + dot(mc_0, _S602.xyz);
                }
                else
                {
                    uint _S615 = 4U * i_6;
                    float3 _S616 = rotate_0(&rg_11->rot_3, float3((float4(*(kernelContext_60->state_0+(_S615 + 1U))) ).w, (float4(*(kernelContext_60->state_0+(_S615 + 2U))) ).w, (float4(*(kernelContext_60->state_0+(_S615 + 3U))) ).w));
                    value_1 = dot(_S616, _S601.xyz);
                }
            }
        }
        write_probe_0(info_3.w, k_15, value_1, kernelContext_60);
        at_5 = at_5 + 4U;
    }
    return;
}

void contact_split_at_0(uint at_6, KernelContext_0 thread* kernelContext_61)
{
    uint previous_0 = (uint4((kernelContext_61->islands_0+kernelContext_61->params_0->halt_index_0)->info_0) ).y;
    uint _S617;
    if(previous_0 == 0U)
    {
        _S617 = at_6;
    }
    else
    {
        _S617 = min(previous_0, at_6);
    }
    (kernelContext_61->islands_0+kernelContext_61->params_0->halt_index_0)->info_0[int(1)] = _S617;
    return;
}

[[kernel]] void wide_end(uint3 group_4 [[threadgroup_position_in_grid]], uint3 thread_4 [[thread_position_in_threadgroup]], Params_0 constant* params_7 [[buffer(0)]], Island_natural_0 device* islands_7 [[buffer(9)]], uint device* index_7 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_7 [[buffer(3)]], packed_float4 device* state_7 [[buffer(6)]], packed_float4 device* scratch_7 [[buffer(8)]], packed_float4 device* contact_state_7 [[buffer(11)]], packed_float4 device* loads_7 [[buffer(5)]], Impactor_natural_0 device* impactors_7 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_7 [[buffer(7)]], BondStatic_natural_0 device* bonds_7 [[buffer(2)]], MaterialTable_0 constant* materials_7 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_62;
    (&kernelContext_62)->params_0 = params_7;
    (&kernelContext_62)->islands_0 = islands_7;
    (&kernelContext_62)->index_0 = index_7;
    (&kernelContext_62)->chunks_0 = chunks_7;
    (&kernelContext_62)->state_0 = state_7;
    (&kernelContext_62)->scratch_0 = scratch_7;
    (&kernelContext_62)->contact_state_0 = contact_state_7;
    (&kernelContext_62)->loads_0 = loads_7;
    (&kernelContext_62)->impactors_0 = impactors_7;
    (&kernelContext_62)->bond_dyn_0 = bond_dyn_7;
    (&kernelContext_62)->bonds_0 = bonds_7;
    (&kernelContext_62)->materials_0 = materials_7;
    threadgroup array<float4, int(32)> g_part_a_7;
    (&kernelContext_62)->g_part_a_0 = &g_part_a_7;
    threadgroup array<float4, int(32)> g_part_b_7;
    (&kernelContext_62)->g_part_b_0 = &g_part_b_7;
    threadgroup array<uint, int(5)> g_seen_7;
    (&kernelContext_62)->g_seen_0 = &g_seen_7;
    threadgroup uint g_wide_run_7;
    (&kernelContext_62)->g_wide_run_0 = &g_wide_run_7;
    threadgroup array<uint, int(4096)> g_label_7;
    (&kernelContext_62)->g_label_0 = &g_label_7;
    threadgroup uint g_changed_7;
    (&kernelContext_62)->g_changed_0 = &g_changed_7;
    threadgroup uint g_halt_7;
    (&kernelContext_62)->g_halt_0 = &g_halt_7;
    threadgroup uint g_run_7;
    (&kernelContext_62)->g_run_0 = &g_run_7;
    threadgroup array<uint, int(512)> g_label_narrow_7;
    (&kernelContext_62)->g_label_narrow_0 = &g_label_narrow_7;
    threadgroup uint g_changed_narrow_7;
    (&kernelContext_62)->g_changed_narrow_0 = &g_changed_narrow_7;
    uint tid_12 = thread_4.x;
    uint _S618 = group_4.x;
    WideGroup_0 _S619 = wide_group_0(params_7->wide_chunk_table_0, _S618, &kernelContext_62);
    if(_S618 != (_S619.first_0))
    {
        return;
    }
    Island_natural_0 device* _S620 = (&kernelContext_62)->islands_0+_S619.island_3;
    thread Island_natural_0 _S621 = *_S620;
    uint4 _S622 = uint4((&_S621)->info_0) ;
    float4 _S623 = float4((&_S621)->com_0) ;
    float4 _S624 = float4((&_S621)->inertia0_0) ;
    float4 _S625 = float4((&_S621)->inertia1_0) ;
    float4 _S626 = float4((&_S621)->inertia2_0) ;
    float4 _S627 = float4((&_S621)->inv0_0) ;
    float4 _S628 = float4((&_S621)->inv1_0) ;
    float4 _S629 = float4((&_S621)->inv2_0) ;
    float4 _S630 = float4((&_S621)->wcom_0) ;
    float4 _S631 = float4((&_S621)->winv0_0) ;
    float4 _S632 = float4((&_S621)->winv1_0) ;
    float4 _S633 = float4((&_S621)->winv2_0) ;
    float4 _S634 = float4((&_S621)->rotation_0) ;
    float4 _S635 = float4((&_S621)->position_0) ;
    float4 _S636 = float4((&_S621)->position_err_0) ;
    float4 _S637 = float4((&_S621)->velocity_0) ;
    float4 _S638 = float4((&_S621)->velocity_err_0) ;
    float4 _S639 = float4((&_S621)->angular_velocity_0) ;
    uint4 _S640 = uint4((&_S621)->probes_0) ;
    float4 _S641 = float4((&_S621)->energy_0) ;
    float4 _S642 = float4((&_S621)->rotation_err_0) ;
    float4 _S643 = float4((&_S621)->momentum_0) ;
    float4 _S644 = float4((&_S621)->momentum_err_0) ;
    thread Island_0 isl_20;
    (&isl_20)->range_0 = uint4((&_S621)->range_0) ;
    (&isl_20)->info_0 = _S622;
    (&isl_20)->com_0 = _S623;
    (&isl_20)->inertia0_0 = _S624;
    (&isl_20)->inertia1_0 = _S625;
    (&isl_20)->inertia2_0 = _S626;
    (&isl_20)->inv0_0 = _S627;
    (&isl_20)->inv1_0 = _S628;
    (&isl_20)->inv2_0 = _S629;
    (&isl_20)->wcom_0 = _S630;
    (&isl_20)->winv0_0 = _S631;
    (&isl_20)->winv1_0 = _S632;
    (&isl_20)->winv2_0 = _S633;
    (&isl_20)->rotation_0 = _S634;
    (&isl_20)->position_0 = _S635;
    (&isl_20)->position_err_0 = _S636;
    (&isl_20)->velocity_0 = _S637;
    (&isl_20)->velocity_err_0 = _S638;
    (&isl_20)->angular_velocity_0 = _S639;
    (&isl_20)->done_0 = (&_S621)->done_0;
    (&isl_20)->coverage_0 = (&_S621)->coverage_0;
    (&isl_20)->wide_groups_0 = (&_S621)->wide_groups_0;
    (&isl_20)->done_pad_0 = (&_S621)->done_pad_0;
    (&isl_20)->probes_0 = _S640;
    (&isl_20)->energy_0 = _S641;
    (&isl_20)->rotation_err_0 = _S642;
    (&isl_20)->momentum_0 = _S643;
    (&isl_20)->momentum_err_0 = _S644;
    _S621 = *_S620;
    bool _S645 = wide_enter_0(tid_12, &_S621, &kernelContext_62);
    if(!_S645)
    {
        return;
    }
    thread float3 work_0;
    thread float3 flags_1;
    wide_partials_0(tid_12, _S619.first_0, (&isl_20)->wide_groups_0, 6U, &work_0, &flags_1, &kernelContext_62);
    bool halt_0 = (((&isl_20)->info_0.z) & 2U) != 0U;
    bool whole_0;
    if(halt_0)
    {
        thread Island_0 _S646 = isl_20;
        bool _S647 = island_connected_0(tid_12, &_S646, &kernelContext_62);
        whole_0 = _S647;
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
    thread Island_0 _S648 = isl_20;
    uint _S649 = wide_step_2(&_S648, &kernelContext_62);
    if(((&isl_20)->probes_0.y) > ((&isl_20)->probes_0.x))
    {
        thread Island_0 _S650 = isl_20;
        Rigid_0 _S651 = rigid_of_1(&_S650);
        thread Island_0 _S652 = isl_20;
        thread Rigid_0 _S653 = _S651;
        record_probes_0(&_S652, &_S653, _S649, &kernelContext_62);
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
        contact_split_at_0((&isl_20)->info_0.w + 1U, &kernelContext_62);
    }
    float _S654 = work_0.x;
    thread float _S655 = (&isl_20)->energy_0.x;
    thread float _S656 = (&isl_20)->energy_0.y;
    comp_add1_0(&_S655, &_S656, _S654);
    (&isl_20)->energy_0.x = _S655;
    (&isl_20)->energy_0.y = _S656 + work_0.y;
    (&isl_20)->done_0 = (&isl_20)->done_0 + 1U;
    (&isl_20)->info_0.y = (&isl_20)->info_0.y - 1U;
    (&isl_20)->info_0.w = (&isl_20)->info_0.w + 1U;
    if(halt_1)
    {
        (&isl_20)->info_0.z = (((&isl_20)->info_0.z) & 4294967293U) | 1U;
    }
    uint _S657;
    if(halt_1)
    {
        _S657 = 128U;
    }
    else
    {
        _S657 = 0U;
    }
    uint _S658 = 256U | _S657;
    if(((&isl_20)->probes_0.y) > ((&isl_20)->probes_0.x))
    {
        _S657 = 262144U;
    }
    else
    {
        _S657 = 0U;
    }
    uint _S659 = _S658 | _S657;
    if((((&isl_20)->info_0.x) & 4U) != 0U)
    {
        _S657 = 524288U;
    }
    else
    {
        _S657 = 0U;
    }
    uint _S660 = _S659 | _S657;
    if((flags_1.x) > 0.0f)
    {
        _S657 = 32768U;
    }
    else
    {
        _S657 = 0U;
    }
    uint _S661 = _S660 | _S657;
    if((flags_1.y) > 0.0f)
    {
        _S657 = 65536U;
    }
    else
    {
        _S657 = 0U;
    }
    uint _S662 = _S661 | _S657;
    if((flags_1.z) > 0.0f)
    {
        _S657 = 131072U;
    }
    else
    {
        _S657 = 0U;
    }
    (&isl_20)->coverage_0 = ((&isl_20)->coverage_0) | (_S662 | _S657);
    Island_natural_0 device* _S663 = (&kernelContext_62)->islands_0+_S619.island_3;
    _S663->range_0 = packed_uint4(isl_20.range_0) ;
    _S663->info_0 = packed_uint4(isl_20.info_0) ;
    _S663->com_0 = packed_float4(isl_20.com_0) ;
    _S663->inertia0_0 = packed_float4(isl_20.inertia0_0) ;
    _S663->inertia1_0 = packed_float4(isl_20.inertia1_0) ;
    _S663->inertia2_0 = packed_float4(isl_20.inertia2_0) ;
    _S663->inv0_0 = packed_float4(isl_20.inv0_0) ;
    _S663->inv1_0 = packed_float4(isl_20.inv1_0) ;
    _S663->inv2_0 = packed_float4(isl_20.inv2_0) ;
    _S663->wcom_0 = packed_float4(isl_20.wcom_0) ;
    _S663->winv0_0 = packed_float4(isl_20.winv0_0) ;
    _S663->winv1_0 = packed_float4(isl_20.winv1_0) ;
    _S663->winv2_0 = packed_float4(isl_20.winv2_0) ;
    _S663->rotation_0 = packed_float4(isl_20.rotation_0) ;
    _S663->position_0 = packed_float4(isl_20.position_0) ;
    _S663->position_err_0 = packed_float4(isl_20.position_err_0) ;
    _S663->velocity_0 = packed_float4(isl_20.velocity_0) ;
    _S663->velocity_err_0 = packed_float4(isl_20.velocity_err_0) ;
    _S663->angular_velocity_0 = packed_float4(isl_20.angular_velocity_0) ;
    _S663->done_0 = isl_20.done_0;
    _S663->coverage_0 = isl_20.coverage_0;
    _S663->wide_groups_0 = isl_20.wide_groups_0;
    _S663->done_pad_0 = isl_20.done_pad_0;
    _S663->probes_0 = packed_uint4(isl_20.probes_0) ;
    _S663->energy_0 = packed_float4(isl_20.energy_0) ;
    _S663->rotation_err_0 = packed_float4(isl_20.rotation_err_0) ;
    _S663->momentum_0 = packed_float4(isl_20.momentum_0) ;
    _S663->momentum_err_0 = packed_float4(isl_20.momentum_err_0) ;
    return;
}

uint sv_0(uint c_19, uint slot_3, KernelContext_0 thread* kernelContext_63)
{
    return kernelContext_63->params_0->statics_base_0 + 23U * c_19 + slot_3;
}

void project_load_slot_0(uint tid_13, const Island_natural_0 thread* isl_21, uint slot_4, KernelContext_0 thread* kernelContext_64)
{
    uint _S664;
    float3 _S665 = float3(0.0f) ;
    thread float3 net_f_0 = _S665;
    thread float3 net_m_0 = _S665;
    uint4 _S666 = uint4(isl_21->range_0) ;
    uint _S667 = _S666.x + tid_13;
    uint c_20 = _S667;
    for(;;)
    {
        uint _S668 = _S666.y;
        _S664 = _S668;
        if(c_20 < _S668)
        {
        }
        else
        {
            break;
        }
        uint _S669 = sv_0(c_20, slot_4, kernelContext_64);
        float3 fi_0 = (float4(*(kernelContext_64->scratch_0+_S669)) ).xyz;
        net_f_0 = net_f_0 + fi_0;
        float3 _S670 = cross((float4((kernelContext_64->chunks_0+c_20)->center_0) ).xyz - (float4(isl_21->com_0) ).xyz, fi_0);
        uint _S671 = sv_0(c_20, slot_4 + 1U, kernelContext_64);
        net_m_0 = net_m_0 + (_S670 + (float4(*(kernelContext_64->scratch_0+_S671)) ).xyz);
        c_20 = c_20 + 256U;
    }
    group_sum3_0(tid_13, &net_f_0, &net_m_0, kernelContext_64);
    float4 _S672 = float4(isl_21->com_0) ;
    float3 _S673 = net_f_0 / float3(_S672.w) ;
    float3 _S674 = rows_mul_0(float4(isl_21->inv0_0) , float4(isl_21->inv1_0) , float4(isl_21->inv2_0) , net_m_0);
    c_20 = _S667;
    for(;;)
    {
        if(c_20 < _S664)
        {
        }
        else
        {
            break;
        }
        float3 r_8 = (float4((kernelContext_64->chunks_0+c_20)->center_0) ).xyz - _S672.xyz;
        uint _S675 = sv_0(c_20, slot_4, kernelContext_64);
        *(kernelContext_64->scratch_0+_S675) = packed_float4(float4((float4(*(kernelContext_64->scratch_0+_S675)) ).xyz - (_S673 + cross(_S674, r_8)) * float3((float4((kernelContext_64->chunks_0+c_20)->center_0) ).w) , 0.0f)) ;
        uint _S676 = sv_0(c_20, slot_4 + 1U, kernelContext_64);
        *(kernelContext_64->scratch_0+_S676) = packed_float4(float4((float4(*(kernelContext_64->scratch_0+_S676)) ).xyz - rows_mul_0(float4((kernelContext_64->chunks_0+c_20)->inertia0_1) , float4((kernelContext_64->chunks_0+c_20)->inertia1_1) , float4((kernelContext_64->chunks_0+c_20)->inertia2_1) , _S674), 0.0f)) ;
        c_20 = c_20 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    return;
}

float island_dot_0(uint tid_14, uint c0_0, uint c1_0, uint sa_2, uint sb_2, KernelContext_0 thread* kernelContext_65)
{
    float4 _S677 = float4(0.0f) ;
    thread float4 acc_0 = _S677;
    thread float4 unused_2 = _S677;
    uint c_21 = c0_0 + tid_14;
    for(;;)
    {
        if(c_21 < c1_0)
        {
        }
        else
        {
            break;
        }
        uint _S678 = sv_0(c_21, sa_2, kernelContext_65);
        float3 _S679 = (float4(*(kernelContext_65->scratch_0+_S678)) ).xyz;
        uint _S680 = sv_0(c_21, sb_2, kernelContext_65);
        float _S681 = dot(_S679, (float4(*(kernelContext_65->scratch_0+_S680)) ).xyz);
        uint _S682 = sv_0(c_21, sa_2 + 1U, kernelContext_65);
        float3 _S683 = (float4(*(kernelContext_65->scratch_0+_S682)) ).xyz;
        uint _S684 = sv_0(c_21, sb_2 + 1U, kernelContext_65);
        acc_0.x = acc_0.x + (_S681 + dot(_S683, (float4(*(kernelContext_65->scratch_0+_S684)) ).xyz));
        c_21 = c_21 + 256U;
    }
    group_sum2_0(tid_14, &acc_0, &unused_2, kernelContext_65);
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
    float4 _S685 = float4(b_25->geom0_0) ;
    float area_2 = _S685.x;
    float _S686 = q_lin_0.z;
    float axial_0 = (metal::fast::divide((_S686), (area_2)));
    float4 _S687 = float4(b_25->geom1_0) ;
    float _S688 = (metal::fast::divide((abs(q_ang_0.x)), (_S687.x)));
    float _S689 = (metal::fast::divide((abs(q_ang_0.y)), (_S687.y)));
    float bending_0 = _S688 + _S689;
    float _S690 = q_lin_0.x;
    float _S691 = q_lin_0.y;
    float _S692 = (metal::fast::sqrt((_S690 * _S690 + _S691 * _S691)));
    float _S693 = (metal::fast::divide((_S692), (area_2)));
    float _S694 = (metal::fast::divide((abs(q_ang_0.z)), (_S685.w)));
    float shear_1 = _S693 + _S694;
    thread Measures_0 m_2;
    (&m_2)->tension_0 = axial_0 + bending_0;
    (&m_2)->shear_0 = shear_1;
    float _S695 = - axial_0;
    (&m_2)->normal_compression_0 = max(_S695, 0.0f);
    (&m_2)->compression_0 = _S695 + bending_0;
    (&m_2)->compressive_force_0 = max(- _S686, 0.0f);
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
    float4 _S696 = mat_1->dif_0;
    float ref_0 = mat_1->dif_0.x;
    if(r_9 <= ref_0)
    {
        return 1.0f;
    }
    float _S697 = _S696.z;
    float f_10;
    if(r_9 <= _S697)
    {
        float _S698 = (metal::fast::divide((r_9), (ref_0)));
        float _S699 = (metal::fast::pow((_S698), (_S696.y)));
        f_10 = _S699;
    }
    else
    {
        float _S700 = (metal::fast::divide((_S697), (ref_0)));
        float _S701 = (metal::fast::pow((_S700), (_S696.y)));
        float _S702 = (metal::fast::divide((r_9), (_S697)));
        float _S703 = (metal::fast::pow((_S702), (_S696.w)));
        f_10 = _S701 * _S703;
    }
    return clamp(f_10, 1.0f, mat_1->misc_0.x);
}

float fatigue_factor_0(const JointMaterial_0 constant* mat_2, float life_1)
{
    if(((mat_2->kind_flags_0.y) & 64U) == 0U)
    {
        return 1.0f;
    }
    float _S704 = clamp(life_1, 0.0f, 1.0f);
    float _S705 = (metal::fast::divide((1.0f), (mat_2->misc_0.y - 2.0f)));
    float _S706 = (metal::fast::pow((_S704), (_S705)));
    return _S706;
}

float infinity_0()
{
    return (as_type<float>((2139095040U)));
}

float4 failure_indices_0(const JointMaterial_0 constant* mat_3, const JointBond_natural_0 thread* b_26, const Measures_0 thread* m_3, float multiplier_0)
{
    float fc_1 = mat_3->strength_0.y * multiplier_0;
    float _S707 = min(mat_3->strength_0.z * multiplier_0 + mat_3->strength_0.w * m_3->normal_compression_0, mat_3->energy_1.x * multiplier_0);
    thread float4 idx_0;
    float _S708 = (metal::fast::divide((m_3->tension_0), (mat_3->strength_0.x * multiplier_0)));
    idx_0.x = max(_S708, 0.0f);
    float _S709;
    if(_S707 > 0.0f)
    {
        float _S710 = (metal::fast::divide((m_3->shear_0), (_S707)));
        _S709 = _S710;
    }
    else
    {
        _S709 = infinity_0();
    }
    idx_0.y = _S709;
    float _S711 = (metal::fast::divide((m_3->compression_0), (fc_1)));
    idx_0.z = max(_S711, 0.0f);
    float _S712 = (float4(b_26->stiff1_0) ).y;
    if(_S712 > 0.0f)
    {
        float _S713 = (metal::fast::divide((m_3->compressive_force_0), (_S712)));
        _S709 = _S713;
    }
    else
    {
        _S709 = 0.0f;
    }
    idx_0.w = _S709;
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
        float _S714 = (metal::fast::divide((r_10 * (kappa_1 - 1.0f)), (kappa_1 * (r_10 - 1.0f))));
        return min(_S714, 1.0f);
    }
    if(kappa_1 >= (0.5f * (r_10 + 1.0f)))
    {
        return 1.0f;
    }
    float _S715 = (metal::fast::divide((1.0f), (kappa_1)));
    return 1.0f - _S715;
}

__attribute__((noinline))
float2 damage_increment_0(uint kind_3, float kappa_old_0, float lambda_0, float r_11, float d_old_0, float psi_0)
{
    float _S716 = damage_law_0(kind_3, lambda_0, r_11);
    float _S717 = max(_S716, d_old_0);
    bool _S718;
    if(_S717 <= d_old_0)
    {
        _S718 = true;
    }
    else
    {
        _S718 = d_old_0 >= 1.0f;
    }
    if(_S718)
    {
        return float2(d_old_0, 0.0f);
    }
    float u0_0 = (metal::fast::divide((psi_0), (lambda_0 * lambda_0)));
    float _S719 = max(kappa_old_0, 1.0f);
    if(kind_3 == 0U)
    {
        if(r_11 > 1.0f)
        {
            float _S720 = (metal::fast::divide((u0_0 * r_11), (r_11 - 1.0f)));
            return float2(_S717, _S720 * max(min(lambda_0, r_11) - min(_S719, r_11), 0.0f));
        }
        return float2(_S717, (1.0f - d_old_0) * psi_0);
    }
    float ku_0 = 0.5f * (r_11 + 1.0f);
    float plateau_0 = u0_0 * max(min(lambda_0, ku_0) - min(_S719, ku_0), 0.0f);
    float snap_0;
    if(_S717 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return float2(_S717, plateau_0 + snap_0);
}

void compressed_region_0(float w0_0, float w1_0, float dz_0, float ax_0, float ay_0, array<float, int(6)> thread* region_0)
{
    uint count_5;
    float h0_0 = 0.5f * w0_0;
    float h1_0 = 0.5f * w1_0;
    float _S721 = - h0_0;
    float _S722 = - h1_0;
    array<float2, int(4)> _S723 = { { float2(_S721, _S722), float2(h0_0, _S722), float2(h0_0, h1_0), float2(_S721, h1_0) } };
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
        uint _S724 = i_7;
        uint _S725 = i_7 + 1U;
        uint _S726 = _S725 % 4U;
        float _S727 = _S723[i_7].y;
        float _S728 = _S723[i_7].x;
        float fp_0 = dz_0 + ax_0 * _S727 - ay_0 * _S728;
        float _S729 = _S723[_S726].y;
        float _S730 = _S723[_S726].x;
        float fq_0 = dz_0 + ax_0 * _S729 - ay_0 * _S730;
        bool _S731 = fp_0 < 0.0f;
        if(_S731)
        {
            uint _S732 = count_6 + 1U;
            poly_0[count_6] = _S723[_S724];
            count_5 = _S732;
        }
        else
        {
            count_5 = count_6;
        }
        if(_S731 != (fq_0 < 0.0f))
        {
            float t_14 = fp_0 / (fp_0 - fq_0);
            uint _S733 = count_5 + 1U;
            poly_0[count_5] = float2(_S728 + t_14 * (_S730 - _S728), _S727 + t_14 * (_S729 - _S727));
            count_6 = _S733;
        }
        else
        {
            count_6 = count_5;
        }
        i_7 = _S725;
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
        float _S734 = o_1.x;
        float x0_0 = poly_0[i_7].x - _S734;
        float _S735 = o_1.y;
        float y0_0 = poly_0[i_7].y - _S735;
        uint _S736 = i_7 + 1U;
        uint _S737 = _S736 % count_6;
        float x1_0 = poly_0[_S737].x - _S734;
        float y1_0 = poly_0[_S737].y - _S735;
        float _S738 = x0_0 * y1_0;
        float _S739 = x1_0 * y0_0;
        float cr_0 = _S738 - _S739;
        float a_12 = a_11 + cr_0 / 2.0f;
        float sx_1 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        float sy_1 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        float ixx_1 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        float iyy_1 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        float ixy_1 = ixy_0 + (_S738 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S739) * cr_0 / 24.0f;
        i_7 = _S736;
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
    float _S740 = a_11 * cx_0;
    (*region_0)[int(3)] = ixx_0 - _S740 * cx_0;
    (*region_0)[int(4)] = iyy_0 - a_11 * cy_0 * cy_0;
    (*region_0)[int(5)] = ixy_0 - _S740 * cy_0;
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
    float k_16 = kn_0 / (w0_1 * w1_1);
    float fc_2 = dz_1 + ax_1 * r_12[int(2)] - ay_1 * r_12[int(1)];
    float _S741 = a_13 * fc_2;
    float _S742 = - ay_1;
    return float4(k_16 * a_13 * fc_2, k_16 * (_S741 * r_12[int(2)] + (_S742 * r_12[int(5)] + ax_1 * r_12[int(4)])), - k_16 * (_S741 * r_12[int(1)] + (_S742 * r_12[int(3)] + ax_1 * r_12[int(5)])), 0.5f * k_16 * (_S741 * fc_2 + ay_1 * ay_1 * r_12[int(3)] + ax_1 * ax_1 * r_12[int(4)] - 2.0f * ax_1 * ay_1 * r_12[int(5)]));
}

float signum_0(float x_14)
{
    float _S743;
    if(((as_type<uint>((x_14))) & 2147483648U) != 0U)
    {
        _S743 = -1.0f;
    }
    else
    {
        _S743 = 1.0f;
    }
    return _S743;
}

float2 return_map_0(float k_17, float total_2, float plastic_0, float cap_0)
{
    float trial_0 = k_17 * (total_2 - plastic_0);
    if((abs(trial_0)) <= cap_0)
    {
        return float2(trial_0, 0.0f);
    }
    float f_11 = cap_0 * signum_0(trial_0);
    float _S744 = (metal::fast::divide((trial_0 - f_11), (k_17)));
    return float2(f_11, _S744);
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
    thread Contact_0 c_22;
    float3 _S745 = float3(0.0f) ;
    (&c_22)->q_lin_1 = _S745;
    (&c_22)->q_ang_1 = _S745;
    (&c_22)->energy_2 = 0.0f;
    (&c_22)->diss_2 = 0.0f;
    (&c_22)->plastic_1 = plastic_2;
    uint _S746 = mat_4->kind_flags_0.y;
    if((_S746 & 2U) == 0U)
    {
        return c_22;
    }
    float4 _S747 = float4(b_27->stiff0_0) ;
    float kn_1 = _S747.x;
    float ks_0 = _S747.y;
    float kt_0 = (float4(b_27->stiff1_0) ).x;
    float4 _S748 = float4(b_27->geom0_0) ;
    float w0_2 = _S748.y;
    float w1_2 = _S748.z;
    float diss_3;
    float nc_sum_0;
    float m1_0;
    float m2_0;
    float energy_3;
    if((_S746 & 4U) != 0U)
    {
        float4 p_13 = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        float _S749 = p_13.y;
        float _S750 = p_13.z;
        float _S751 = p_13.w;
        nc_sum_0 = p_13.x;
        m1_0 = _S749;
        m2_0 = _S750;
        energy_3 = _S751;
    }
    else
    {
        float ki_0 = kn_1 * (1.0f - crush_2) / 36.0f;
        float _S752 = d_ang_0.x;
        float _S753 = d_ang_0.y;
        float spread_0 = abs(_S752) * 0.4166666567325592f * w1_2 + abs(_S753) * 0.4166666567325592f * w0_2;
        float _S754 = d_lin_0.z;
        float slack_0 = 9.99999997475242708e-07f * (abs(_S754) + spread_0);
        if((_S754 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S754 + spread_0) < (- slack_0))
            {
                float i1_0 = 2.91666650772094727f * w0_2 * w0_2;
                float i2_0 = 2.91666650772094727f * w1_2 * w1_2;
                float _S755 = ki_0 * _S752 * i2_0;
                float _S756 = ki_0 * _S753 * i1_0;
                float _S757 = 0.5f * ki_0 * (36.0f * _S754 * _S754 + _S752 * _S752 * i2_0 + _S753 * _S753 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S754;
                m1_0 = _S755;
                m2_0 = _S756;
                energy_3 = _S757;
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
                    float _S758 = SPRING_AT_0[i_8] * w0_2;
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
                        float di_0 = _S754 + _S752 * s2_0 - _S753 * _S758;
                        if(di_0 < 0.0f)
                        {
                            float f_12 = ki_0 * di_0;
                            float m1_2 = m1_0 + f_12 * s2_0;
                            float m2_2 = m2_0 - f_12 * _S758;
                            float energy_5 = energy_3 + 0.5f * ki_0 * di_0 * di_0;
                            nc_sum_0 = nc_sum_0 + f_12;
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
    (&c_22)->q_lin_1 = float3(0.0f, 0.0f, nc_sum_0);
    (&c_22)->q_ang_1 = float3(m1_0, m2_0, 0.0f);
    float slide_cap_0 = mat_4->strength_0.w * nc_0;
    float _S759 = ks_0 * (d_lin_0.x - plastic_2.x);
    float _S760 = ks_0 * (d_lin_0.y - plastic_2.y);
    float tn_0 = (metal::fast::sqrt((_S759 * _S759 + _S760 * _S760)));
    bool _S761;
    if(tn_0 > slide_cap_0)
    {
        _S761 = tn_0 > 0.0f;
    }
    else
    {
        _S761 = false;
    }
    if(_S761)
    {
        float _S762 = (metal::fast::divide((_S759), (tn_0)));
        float _S763 = (metal::fast::divide((_S760), (tn_0)));
        float dslip_0 = (metal::fast::divide((tn_0 - slide_cap_0), (ks_0)));
        p_14.x = p_14.x + _S762 * dslip_0;
        p_14.y = p_14.y + _S763 * dslip_0;
        (&c_22)->q_lin_1.x = _S762 * slide_cap_0;
        (&c_22)->q_lin_1.y = _S763 * slide_cap_0;
        diss_3 = slide_cap_0 * dslip_0;
    }
    else
    {
        (&c_22)->q_lin_1.x = _S759;
        (&c_22)->q_lin_1.y = _S760;
        diss_3 = 0.0f;
    }
    float2 tq_0 = return_map_0(kt_0, d_ang_0.z, p_14.z, slide_cap_0 * (float4(b_27->geom1_0) ).z);
    float _S764 = tq_0.x;
    float _S765 = tq_0.y;
    float diss_4 = diss_3 + abs(_S764) * abs(_S765);
    p_14.z = p_14.z + _S765;
    (&c_22)->q_ang_1.z = _S764;
    float _S766 = (metal::fast::divide((sq_0((&c_22)->q_lin_1.x)), (ks_0)));
    float _S767 = (metal::fast::divide((sq_0((&c_22)->q_lin_1.y)), (ks_0)));
    float _S768 = _S766 + _S767;
    float _S769 = (metal::fast::divide((sq_0(_S764)), (kt_0)));
    (&c_22)->energy_2 = energy_3 + 0.5f * (_S768 + _S769);
    (&c_22)->diss_2 = diss_4;
    (&c_22)->plastic_1 = p_14;
    return c_22;
}

float3 contact_offsets_0(const JointMaterial_0 constant* mat_5, const JointBond_natural_0 thread* b_28, float crush_3, float3 plastic_3, float3 d_lin_1, float3 d_ang_1)
{
    uint _S770 = mat_5->kind_flags_0.y;
    if((_S770 & 2U) == 0U)
    {
        return plastic_3;
    }
    float4 _S771 = float4(b_28->stiff0_0) ;
    float kn_2 = _S771.x;
    float ks_1 = _S771.y;
    float kt_1 = (float4(b_28->stiff1_0) ).x;
    float4 _S772 = float4(b_28->geom0_0) ;
    float w0_3 = _S772.y;
    float w1_3 = _S772.z;
    float nc_sum_1;
    if((_S770 & 4U) != 0U)
    {
        float4 _S773 = no_tension_patch_0(kn_2 * (1.0f - crush_3), w0_3, w1_3, d_lin_1.z, d_ang_1.x, d_ang_1.y);
        nc_sum_1 = _S773.x;
    }
    else
    {
        float ki_1 = kn_2 * (1.0f - crush_3) / 36.0f;
        float _S774 = d_ang_1.x;
        float _S775 = d_ang_1.y;
        float spread_1 = abs(_S774) * 0.4166666567325592f * w1_3 + abs(_S775) * 0.4166666567325592f * w0_3;
        float _S776 = d_lin_1.z;
        float slack_1 = 9.99999997475242708e-07f * (abs(_S776) + spread_1);
        if((_S776 - spread_1) > slack_1)
        {
            nc_sum_1 = 0.0f;
        }
        else
        {
            if((_S776 + spread_1) < (- slack_1))
            {
                nc_sum_1 = ki_1 * 36.0f * _S776;
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
                    float _S777 = SPRING_AT_0[i_9] * w0_3;
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
                        float di_1 = _S776 + _S774 * (SPRING_AT_0[j_8] * w1_3) - _S775 * _S777;
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
    float _S778 = ks_1 * (d_lin_1.x - plastic_3.x);
    float _S779 = ks_1 * (d_lin_1.y - plastic_3.y);
    float tn_1 = (metal::fast::sqrt((_S778 * _S778 + _S779 * _S779)));
    bool _S780;
    if(tn_1 > slide_cap_1)
    {
        _S780 = tn_1 > 0.0f;
    }
    else
    {
        _S780 = false;
    }
    if(_S780)
    {
        float _S781 = (metal::fast::divide((_S778), (tn_1)));
        float _S782 = (metal::fast::divide((_S779), (tn_1)));
        float dslip_1 = (metal::fast::divide((tn_1 - slide_cap_1), (ks_1)));
        p_15.x = p_15.x + _S781 * dslip_1;
        p_15.y = p_15.y + _S782 * dslip_1;
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
    float _S783 = mat_6->misc_0.y;
    float _S784 = _S783 + 1.0f;
    float _S785 = (metal::fast::pow((s_5), (_S783)));
    float _S786 = (metal::fast::divide((_S784 * _S785), (mat_6->misc_0.z)));
    return _S786;
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

JointResponse_0 joint_evaluate_0(const JointMaterial_0 constant* mat_7, const JointBond_natural_0 thread* b_29, const JointState_0 thread* state_9, float3 d_lin_2, float3 d_ang_2, float dt_11, bool fracture_1)
{
    float4 _S787 = float4(b_29->stiff0_0) ;
    float kn_3 = _S787.x;
    float ks_2 = _S787.y;
    float kb1_0 = _S787.z;
    float kb2_0 = _S787.w;
    float4 _S788 = float4(b_29->stiff1_0) ;
    float kt_2 = _S788.x;
    bool has_rebar_1 = (_S788.w) != 0.0f;
    uint kind_4 = mat_7->kind_flags_0.x;
    uint flags_2 = mat_7->kind_flags_0.y;
    bool softening_0 = (flags_2 & 1U) != 0U;
    thread JointState_0 st_1 = *state_9;
    bool _S789 = connected_0(state_9, has_rebar_1);
    float3 qe_lin_0 = d_lin_2 * float3(ks_2, ks_2, kn_3);
    float3 qe_ang_0 = d_ang_2 * float3(kb1_0, kb2_0, kt_2);
    Measures_0 _S790 = stress_measures_0(b_29, qe_lin_0, qe_ang_0);
    float _S791 = max(max(_S790.tension_0, _S790.shear_0), _S790.compression_0);
    bool _S792 = dt_11 > 0.0f;
    float dif_1;
    if(_S792)
    {
        float _S793 = (metal::fast::divide((_S791 - (&st_1)->governing_stress_0), (dt_11)));
        float raw_0 = (metal::fast::divide((max(_S793, 0.0f)), (mat_7->misc_0.w)));
        float tau_2 = _S788.z;
        if((flags_2 & 16U) != 0U)
        {
            float _S794 = (metal::fast::divide((dt_11), (tau_2)));
            dif_1 = - expm1_accurate_0(- _S794);
        }
        else
        {
            float _S795 = (metal::fast::divide((dt_11), (tau_2)));
            dif_1 = min(_S795, 1.0f);
        }
        (&st_1)->strain_rate_0 = (&st_1)->strain_rate_0 + (raw_0 - (&st_1)->strain_rate_0) * dif_1;
        (&st_1)->governing_stress_0 = _S791;
    }
    if((flags_2 & 32U) != 0U)
    {
        float _S796 = dif_factor_0(mat_7, (&st_1)->strain_rate_0);
        dif_1 = _S796;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = (float4(b_29->geom1_0) ).w;
    float _S797 = fatigue_factor_0(mat_7, (&st_1)->life_0);
    float multiplier_1 = weibull_0 * dif_1 * _S797;
    thread Measures_0 _S798 = _S790;
    float4 _S799 = failure_indices_0(mat_7, b_29, &_S798, multiplier_1);
    float _S800 = _S799.x;
    float _S801 = _S799.y;
    (&st_1)->utilization_0 = max(max(_S800, _S801), max(_S799.z, _S799.w));
    float _S802 = d_lin_2.x;
    float _S803 = d_lin_2.y;
    float _S804 = ks_2 * (sq_0(_S802) + sq_0(_S803)) + kb1_0 * sq_0(d_ang_2.x) + kb2_0 * sq_0(d_ang_2.y) + kt_2 * sq_0(d_ang_2.z);
    float _S805 = d_lin_2.z;
    bool _S806 = _S805 > 0.0f;
    if(_S806)
    {
        dif_1 = kn_3 * sq_0(_S805);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S804 + dif_1);
    float psi_c_0;
    if(_S805 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_3 * sq_0(_S805);
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
    bool _S807;
    float3 qc_lin_0;
    if(fracture_1)
    {
        bool _S808 = _S800 >= _S801;
        if(_S808)
        {
            diss_contact_0 = _S800;
        }
        else
        {
            diss_contact_0 = _S801;
        }
        uint mode_ts_0;
        if(_S808)
        {
            mode_ts_0 = 1U;
        }
        else
        {
            mode_ts_0 = 2U;
        }
        if(diss_contact_0 > ((&st_1)->kappa_0))
        {
            _S807 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S807 = false;
        }
        if(_S807)
        {
            _S807 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S807 = false;
        }
        uint mode_c_0;
        if(_S807)
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
                float _S809 = (metal::fast::divide((psi_contact_0 * (float4(b_29->geom0_0) ).x * diss_contact_0 * diss_contact_0), (psi_ts_0)));
                intact_normal_0 = _S809;
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
            float _S810 = inc_0.x;
            if(_S810 > ((&st_1)->damage_0))
            {
                Contact_0 _S811 = contact_part_0(mat_7, b_29, (&st_1)->crush_1, plastic_4, d_lin_2, d_ang_2);
                float _S812 = max(_S811.energy_2 - (1.0f - (&st_1)->crush_1) * psi_c_0, 0.0f);
                float _S813 = max(inc_0.y - _S812 * (_S810 - (&st_1)->damage_0), 0.0f);
                float _S814 = max((psi_ts_0 - _S812) * (_S810 - (&st_1)->damage_0) - _S813, 0.0f);
                (&st_1)->damage_0 = _S810;
                (&st_1)->mode_0 = mode_ts_0;
                dissipated_3 = _S813;
                overshoot_1 = _S814;
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
        float _S815 = state_9->damage_0;
        if((state_9->damage_0) > 0.0f)
        {
            Contact_0 _S816 = contact_part_0(mat_7, b_29, state_9->crush_1, float3(state_9->plastic_x_0, state_9->plastic_y_0, state_9->plastic_t_0), d_lin_2, d_ang_2);
            qc_lin_0 = qe_ang_0 * float3((1.0f - _S815))  + _S816.q_ang_1 * float3(_S815) ;
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S817 = stress_measures_0(b_29, float3(0.0f, 0.0f, min(qe_lin_0.z, 0.0f)), qc_lin_0);
        thread Measures_0 _S818 = _S817;
        float4 _S819 = failure_indices_0(mat_7, b_29, &_S818, multiplier_1);
        float _S820 = _S819.z;
        float _S821 = _S819.w;
        bool _S822 = _S820 >= _S821;
        if(_S822)
        {
            psi_contact_0 = _S820;
        }
        else
        {
            psi_contact_0 = _S821;
        }
        if(_S822)
        {
            mode_c_0 = 3U;
        }
        else
        {
            mode_c_0 = 4U;
        }
        if(psi_contact_0 > ((&st_1)->kappa_c_0))
        {
            _S807 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S807 = false;
        }
        if(_S807)
        {
            _S807 = psi_c_0 > 0.0f;
        }
        else
        {
            _S807 = false;
        }
        if(_S807)
        {
            if(softening_0)
            {
                float _S823 = (metal::fast::divide((mat_7->energy_1.w * (float4(b_29->geom0_0) ).x * psi_contact_0 * psi_contact_0), (psi_c_0)));
                intact_normal_0 = _S823;
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
            float _S824 = inc_1.x;
            if(_S824 > ((&st_1)->crush_1))
            {
                float _S825 = inc_1.y;
                float dissipated_4 = dissipated_3 + _S825;
                float overshoot_2 = overshoot_1 + max(psi_c_0 * (_S824 - (&st_1)->crush_1) - _S825, 0.0f);
                (&st_1)->crush_1 = _S824;
                (&st_1)->mode_0 = mode_c_0;
                if(_S824 >= 1.0f)
                {
                    _S807 = ((&st_1)->damage_0) < 1.0f;
                }
                else
                {
                    _S807 = false;
                }
                if(_S807)
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
    float3 _S826 = float3(0.0f) ;
    float3 qc_ang_0;
    if(((&st_1)->damage_0) == 0.0f)
    {
        if((flags_2 & 8U) == 0U)
        {
            float3 _S827 = contact_offsets_0(mat_7, b_29, (&st_1)->crush_1, plastic_4, d_lin_2, d_ang_2);
            (&st_1)->plastic_x_0 = _S827.x;
            (&st_1)->plastic_y_0 = _S827.y;
            (&st_1)->plastic_t_0 = _S827.z;
        }
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S826;
        qc_ang_0 = _S826;
        psi_contact_0 = 0.0f;
    }
    else
    {
        Contact_0 _S828 = contact_part_0(mat_7, b_29, (&st_1)->crush_1, plastic_4, d_lin_2, d_ang_2);
        (&st_1)->plastic_x_0 = _S828.plastic_1.x;
        (&st_1)->plastic_y_0 = _S828.plastic_1.y;
        (&st_1)->plastic_t_0 = _S828.plastic_1.z;
        diss_contact_0 = _S828.diss_2;
        qc_lin_0 = _S828.q_lin_1;
        qc_ang_0 = _S828.q_ang_1;
        psi_contact_0 = _S828.energy_2;
    }
    float dissipated_6 = dissipated_3 + dmg_0 * diss_contact_0;
    if(_S806)
    {
        intact_normal_0 = kn_3 * _S805;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_1)->crush_1) * kn_3 * _S805;
    }
    float _S829 = 1.0f - dmg_0;
    float3 force_lin_2 = float3(_S829 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S829 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S829 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3 force_ang_2 = qe_ang_0 * float3(_S829)  + qc_ang_0 * float3(dmg_0) ;
    float stored_4 = _S829 * (psi_ts_0 + (1.0f - (&st_1)->crush_1) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S807 = ((&st_1)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S807 = false;
    }
    float stored_5;
    float3 force_lin_3;
    if(_S807)
    {
        float4 _S830 = float4(b_29->rebar0_0) ;
        float k_axial_0 = _S830.x;
        float k_dowel_0 = _S830.y;
        float yield_force_0 = _S830.z;
        float dowel_capacity_0 = _S830.w;
        float2 nr_0 = return_map_0(k_axial_0, _S805, (&st_1)->rebar_plastic_0, yield_force_0);
        float2 v1_0 = return_map_0(k_dowel_0, _S802, (&st_1)->rebar_slip0_0, dowel_capacity_0);
        float2 v2_0 = return_map_0(k_dowel_0, _S803, (&st_1)->rebar_slip1_0, dowel_capacity_0);
        float _S831 = nr_0.y;
        float _S832 = v1_0.y;
        float _S833 = v2_0.y;
        float work_1 = yield_force_0 * abs(_S831) + dowel_capacity_0 * (abs(_S832) + abs(_S833));
        (&st_1)->rebar_plastic_0 = (&st_1)->rebar_plastic_0 + _S831;
        (&st_1)->rebar_slip0_0 = (&st_1)->rebar_slip0_0 + _S832;
        (&st_1)->rebar_slip1_0 = (&st_1)->rebar_slip1_0 + _S833;
        (&st_1)->rebar_work_0 = (&st_1)->rebar_work_0 + work_1;
        float dissipated_7 = dissipated_6 + work_1;
        float _S834 = nr_0.x;
        float _S835 = (metal::fast::divide((sq_0(_S834)), (k_axial_0)));
        float _S836 = v1_0.x;
        float _S837 = v2_0.x;
        float _S838 = (metal::fast::divide((sq_0(_S836) + sq_0(_S837)), (k_dowel_0)));
        float elastic_0 = 0.5f * (_S835 + _S838);
        if(fracture_1)
        {
            _S807 = ((&st_1)->rebar_work_0) >= ((float4(b_29->rebar1_0) ).x);
        }
        else
        {
            _S807 = false;
        }
        if(_S807)
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
            force_lin_3 = force_lin_2 + float3(_S836, _S837, _S834);
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
        _S807 = _S792;
    }
    else
    {
        _S807 = false;
    }
    if(_S807)
    {
        _S807 = (flags_2 & 64U) != 0U;
    }
    else
    {
        _S807 = false;
    }
    if(_S807)
    {
        Measures_0 _S839 = stress_measures_0(b_29, force_lin_3, force_ang_2);
        thread Measures_0 _S840 = _S839;
        float4 _S841 = failure_indices_0(mat_7, b_29, &_S840, weibull_0);
        float _S842 = life_rate_0(mat_7, max(max(_S841.x, _S841.y), _S841.z));
        (&st_1)->life_0 = max((&st_1)->life_0 - _S842 * dt_11, 0.0f);
    }
    (&st_1)->dissipated_0 = (&st_1)->dissipated_0 + dissipated_3;
    thread JointResponse_0 resp_0;
    (&resp_0)->force_lin_1 = force_lin_3;
    (&resp_0)->force_ang_1 = force_ang_2;
    (&resp_0)->state_8 = st_1;
    (&resp_0)->dissipated_2 = dissipated_3;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_3 = stored_5;
    if(_S789)
    {
        thread JointState_0 _S843 = st_1;
        bool _S844 = connected_0(&_S843, has_rebar_1);
        _S807 = !_S844;
    }
    else
    {
        _S807 = false;
    }
    (&resp_0)->disconnected_0 = _S807;
    (&resp_0)->fatigue_before_0 = _S797;
    (&resp_0)->measures_0 = _S790;
    return resp_0;
}

float3 to_local_0(uint _S845, float3 _S846, KernelContext_0 thread* kernelContext_66)
{
    BondStatic_natural_0 device* _S847 = kernelContext_66->bonds_0+_S845;
    return float3(dot(_S846, (float4(_S847->t1_0) ).xyz), dot(_S846, (float4(_S847->t2_0) ).xyz), dot(_S846, (float4(_S847->normal_0) ).xyz));
}

void static_kinematics_0(uint _S848, float3 thread* _S849, float3 thread* _S850, KernelContext_0 thread* kernelContext_67)
{
    BondStatic_natural_0 device* _S851 = kernelContext_67->bonds_0+_S848;
    uint4 _S852 = uint4(_S851->law_0.ids_0) ;
    uint ca_1 = _S852.y;
    uint cb_1 = _S852.z;
    uint _S853 = 4U * cb_1;
    uint _S854 = 4U * ca_1;
    float3 _S855 = (float4(*(kernelContext_67->state_0+_S853)) ).xyz - (float4(*(kernelContext_67->state_0+_S854)) ).xyz;
    uint _S856 = sv_0(cb_1, 21U, kernelContext_67);
    float3 _S857 = (float4(*(kernelContext_67->scratch_0+_S856)) ).xyz;
    uint _S858 = sv_0(ca_1, 21U, kernelContext_67);
    float3 du_0 = _S855 + (_S857 - (float4(*(kernelContext_67->scratch_0+_S858)) ).xyz);
    uint _S859 = _S853 + 1U;
    uint _S860 = _S854 + 1U;
    float3 _S861 = (float4(*(kernelContext_67->state_0+_S859)) ).xyz - (float4(*(kernelContext_67->state_0+_S860)) ).xyz;
    uint _S862 = sv_0(cb_1, 22U, kernelContext_67);
    float3 _S863 = (float4(*(kernelContext_67->scratch_0+_S862)) ).xyz;
    uint _S864 = sv_0(ca_1, 22U, kernelContext_67);
    float3 dth_0 = _S861 + (_S863 - (float4(*(kernelContext_67->scratch_0+_S864)) ).xyz);
    float3 _S865 = to_local_0(_S848, du_0 + (cross((float4(*(kernelContext_67->state_0+_S859)) ).xyz + (float4(*(kernelContext_67->scratch_0+_S862)) ).xyz, (float4(_S851->rb_0) ).xyz) - cross((float4(*(kernelContext_67->state_0+_S860)) ).xyz + (float4(*(kernelContext_67->scratch_0+_S864)) ).xyz, (float4(_S851->ra_0) ).xyz)), kernelContext_67);
    *_S849 = _S865;
    float3 _S866 = to_local_0(_S848, dth_0, kernelContext_67);
    *_S850 = _S866;
    return;
}

JointResponse_0 static_response_0(uint i_10, KernelContext_0 thread* kernelContext_68)
{
    BondStatic_natural_0 device* _S867 = kernelContext_68->bonds_0+i_10;
    thread float3 d_lin_3;
    thread float3 d_ang_3;
    static_kinematics_0(i_10, &d_lin_3, &d_ang_3, kernelContext_68);
    thread JointBond_natural_0 _S868 = _S867->law_0;
    _S868 = _S867->law_0;
    thread JointState_0 _S869 = (kernelContext_68->bond_dyn_0+i_10)->js_0;
    JointResponse_0 _S870 = joint_evaluate_0(&kernelContext_68->materials_0->m_0[(uint4((&_S868)->ids_0) ).x], &_S868, &_S869, d_lin_3, d_ang_3, 0.0f, false);
    return _S870;
}

void gather_loads_0(uint c_23, float3 thread* fi_1, float3 thread* mi_0, KernelContext_0 thread* kernelContext_69)
{
    float3 _S871 = float3(0.0f) ;
    *fi_1 = _S871;
    *mi_0 = _S871;
    uint e_3 = kernelContext_69->index_0[c_23];
    for(;;)
    {
        if(e_3 < (kernelContext_69->index_0)[c_23 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_2 = kernelContext_69->index_0[e_3];
        uint bond_1 = entry_2 >> 1U;
        if((entry_2 & 1U) == 0U)
        {
            uint _S872 = 3U * bond_1;
            *fi_1 = *fi_1 + (float4(*(kernelContext_69->scratch_0+_S872)) ).xyz;
            *mi_0 = *mi_0 + (float4(*(kernelContext_69->scratch_0+(_S872 + 1U))) ).xyz;
        }
        else
        {
            uint _S873 = 3U * bond_1;
            *fi_1 = *fi_1 - (float4(*(kernelContext_69->scratch_0+_S873)) ).xyz;
            *mi_0 = *mi_0 + (float4(*(kernelContext_69->scratch_0+(_S873 + 2U))) ).xyz;
        }
        e_3 = e_3 + 1U;
    }
    return;
}

float bond_load_magnitude2_0(uint c_24, KernelContext_0 thread* kernelContext_70)
{
    uint e_4 = kernelContext_70->index_0[c_24];
    float m_4 = 0.0f;
    for(;;)
    {
        if(e_4 < (kernelContext_70->index_0)[c_24 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_3 = kernelContext_70->index_0[e_4];
        uint _S874 = 3U * (entry_3 >> 1U);
        float3 f_13 = (float4(*(kernelContext_70->scratch_0+_S874)) ).xyz;
        float3 t_15;
        if((entry_3 & 1U) == 0U)
        {
            t_15 = (float4(*(kernelContext_70->scratch_0+(_S874 + 1U))) ).xyz;
        }
        else
        {
            t_15 = (float4(*(kernelContext_70->scratch_0+(_S874 + 2U))) ).xyz;
        }
        float m_5 = m_4 + (dot(f_13, f_13) + dot(t_15, t_15));
        e_4 = e_4 + 1U;
        m_4 = m_5;
    }
    return m_4;
}

uint fixed_mask_0(uint c_25, KernelContext_0 thread* kernelContext_71)
{
    uint support_0 = (uint4((kernelContext_71->chunks_0+c_25)->info_1) ).x;
    uint _S875;
    if(support_0 == 1U)
    {
        _S875 = 63U;
    }
    else
    {
        if(support_0 == 2U)
        {
            _S875 = 7U;
        }
        else
        {
            _S875 = 0U;
        }
    }
    return _S875;
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
    float _S876 = st_2->damage_0;
    bool compressed_0 = (d_lin_4.z) < 0.0f;
    float contact_3;
    if(compressed_0)
    {
        contact_3 = _S876;
    }
    else
    {
        contact_3 = 0.0f;
    }
    float _S877 = 1.0f - _S876;
    float _S878 = max(_S877 + contact_3, 9.99999997475242708e-07f);
    float normal_5;
    if(compressed_0)
    {
        normal_5 = max(1.0f - st_2->crush_1, 9.99999997475242708e-07f);
    }
    else
    {
        normal_5 = max(_S877, 9.99999997475242708e-07f);
    }
    *f_lin_0 = float3(_S878, _S878, normal_5);
    *f_ang_0 = float3(_S878) ;
    bool _S879;
    if(((float4(b_30->stiff1_0) ).w) != 0.0f)
    {
        _S879 = (st_2->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S879 = false;
    }
    if(_S879)
    {
        float4 _S880 = float4(b_30->rebar0_0) ;
        float4 _S881 = float4(b_30->stiff0_0) ;
        float _S882 = (metal::fast::divide((_S880.x), (_S881.x)));
        (*f_lin_0).z = (*f_lin_0).z + _S882;
        float _S883 = _S880.y;
        float _S884 = _S881.y;
        float _S885 = (metal::fast::divide((_S883), (_S884)));
        (*f_lin_0).x = (*f_lin_0).x + _S885;
        float _S886 = (metal::fast::divide((_S883), (_S884)));
        (*f_lin_0).y = (*f_lin_0).y + _S886;
    }
    return;
}

uint statics_bond_slot_0(uint i_11, KernelContext_0 thread* kernelContext_72)
{
    return kernelContext_72->params_0->statics_base_0 + 23U * kernelContext_72->params_0->chunk_count_0 + 2U * i_11;
}

void store_inverse_0(uint c_26, const array<float, int(36)> thread* a_14, KernelContext_0 thread* kernelContext_73)
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
    uint i_12 = 0U;
    for(;;)
    {
        bool _S887;
        if(i_12 < 6U)
        {
            _S887 = spd_0;
        }
        else
        {
            _S887 = false;
        }
        if(_S887)
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
            uint _S888 = i_12 * 6U;
            uint _S889 = _S888 + j_9;
            k_18 = 0U;
            sum_4 = (*a_14)[_S889];
            for(;;)
            {
                if(k_18 < j_9)
                {
                }
                else
                {
                    break;
                }
                float sum_5 = sum_4 - l_5[_S888 + k_18] * l_5[j_9 * 6U + k_18];
                k_18 = k_18 + 1U;
                sum_4 = sum_5;
            }
            if(i_12 == j_9)
            {
                if(sum_4 <= 0.0f)
                {
                    spd_0 = false;
                    break;
                }
                l_5[_S888 + i_12] = sqrt(sum_4);
            }
            else
            {
                l_5[_S889] = sum_4 / l_5[j_9 * 6U + j_9];
            }
            j_9 = j_9 + 1U;
        }
        i_12 = i_12 + 1U;
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
            uint _S890 = k_18 * 6U + k_18;
            float _S891 = (*a_14)[_S890];
            if(((*a_14)[_S890]) > 0.0f)
            {
                sum_4 = 1.0f / _S891;
            }
            else
            {
                sum_4 = 0.0f;
            }
            inv_0[_S890] = sum_4;
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
                k_18 = 0U;
                float s_6 = sum_4;
                for(;;)
                {
                    if(k_18 < i_12)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_7 = s_6 - l_5[i_12 * 6U + k_18] * y_3[k_18];
                    k_18 = k_18 + 1U;
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
                uint i_13 = 5U - ii_1;
                k_18 = i_13 + 1U;
                sum_4 = y_3[i_13];
                for(;;)
                {
                    if(k_18 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_8 = sum_4 - l_5[k_18 * 6U + i_13] * x_15[k_18];
                    k_18 = k_18 + 1U;
                    sum_4 = s_8;
                }
                x_15[i_13] = sum_4 / l_5[i_13 * 6U + i_13];
                ii_1 = ii_1 + 1U;
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
        uint _S892 = sv_0(c_26, 12U + j_9, kernelContext_73);
        uint _S893 = 4U * j_9;
        *(kernelContext_73->scratch_0+_S892) = packed_float4(float4(inv_0[_S893], inv_0[_S893 + 1U], inv_0[_S893 + 2U], inv_0[_S893 + 3U])) ;
        j_9 = j_9 + 1U;
    }
    return;
}

void assemble_block_0(uint c_27, KernelContext_0 thread* kernelContext_74)
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
    uint e_5 = kernelContext_74->index_0[c_27];
    for(;;)
    {
        if(e_5 < (kernelContext_74->index_0)[c_27 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_4 = kernelContext_74->index_0[e_5];
        uint i_15 = entry_4 >> 1U;
        bool _S894 = (entry_4 & 1U) != 0U;
        BondStatic_natural_0 device* _S895 = kernelContext_74->bonds_0+i_15;
        uint _S896 = statics_bond_slot_0(i_15, kernelContext_74);
        float4 _S897 = float4(*(kernelContext_74->scratch_0+_S896)) ;
        float4 _S898 = float4(*(kernelContext_74->scratch_0+(_S896 + 1U))) ;
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
            uint _S899 = p_16 % 3U;
            float3 t_16;
            if(_S899 == 0U)
            {
                t_16 = (float4(_S895->t1_0) ).xyz;
            }
            else
            {
                if(_S899 == 1U)
                {
                    t_16 = (float4(_S895->t2_0) ).xyz;
                }
                else
                {
                    t_16 = (float4(_S895->normal_0) ).xyz;
                }
            }
            bool _S900 = p_16 < 3U;
            float3 row_u_0;
            float3 row_t_0;
            if(_S900)
            {
                if(_S894)
                {
                    row_u_0 = t_16;
                }
                else
                {
                    row_u_0 = - t_16;
                }
                if(_S894)
                {
                    row_t_0 = cross((float4(_S895->rb_0) ).xyz, t_16);
                }
                else
                {
                    row_t_0 = - cross((float4(_S895->ra_0) ).xyz, t_16);
                }
            }
            else
            {
                float3 _S901 = float3(0.0f) ;
                if(_S894)
                {
                    row_u_0 = t_16;
                }
                else
                {
                    row_u_0 = - t_16;
                }
                float3 _S902 = row_u_0;
                row_u_0 = _S901;
                row_t_0 = _S902;
            }
            float kp_0;
            if(_S900)
            {
                kp_0 = _S897[p_16];
            }
            else
            {
                kp_0 = _S898[p_16 - 3U];
            }
            if(kp_0 == 0.0f)
            {
                p_16 = p_16 + 1U;
                continue;
            }
            array<float, int(6)> _S903 = { { row_u_0.x, row_u_0.y, row_u_0.z, row_t_0.x, row_t_0.y, row_t_0.z } };
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
                    a_15[r_13 * 6U + q_14] = a_15[r_13 * 6U + q_14] + kp_0 * _S903[r_13] * _S903[q_14];
                    q_14 = q_14 + 1U;
                }
                r_13 = r_13 + 1U;
            }
            p_16 = p_16 + 1U;
        }
        e_5 = e_5 + 1U;
    }
    uint _S904 = fixed_mask_0(c_27, kernelContext_74);
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
        if((_S904 & (1U << p_16)) != 0U)
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
    thread array<float, int(36)> _S905 = a_15;
    store_inverse_0(c_27, &_S905, kernelContext_74);
    return;
}

float block_get_0(uint c_28, uint i_16, uint j_10, KernelContext_0 thread* kernelContext_75)
{
    uint k_20 = i_16 * 6U + j_10;
    uint _S906 = sv_0(c_28, 12U + k_20 / 4U, kernelContext_75);
    return (*(kernelContext_75->scratch_0+_S906))[k_20 % 4U];
}

void precondition_0(uint c_29, KernelContext_0 thread* kernelContext_76)
{
    uint _S907 = sv_0(c_29, 4U, kernelContext_76);
    float4 _S908 = float4(*(kernelContext_76->scratch_0+_S907)) ;
    uint _S909 = sv_0(c_29, 5U, kernelContext_76);
    float4 _S910 = float4(*(kernelContext_76->scratch_0+_S909)) ;
    array<float, int(6)> _S911 = { { _S908.x, _S908.y, _S908.z, _S910.x, _S910.y, _S910.z } };
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
            float _S912 = block_get_0(c_29, i_17, j_11, kernelContext_76);
            float s_10 = s_9 + _S912 * _S911[j_11];
            j_11 = j_11 + 1U;
            s_9 = s_10;
        }
        z_1[i_17] = s_9;
        i_17 = i_17 + 1U;
    }
    uint _S913 = sv_0(c_29, 6U, kernelContext_76);
    *(kernelContext_76->scratch_0+_S913) = packed_float4(float4(z_1[int(0)], z_1[int(1)], z_1[int(2)], 0.0f)) ;
    uint _S914 = sv_0(c_29, 7U, kernelContext_76);
    *(kernelContext_76->scratch_0+_S914) = packed_float4(float4(z_1[int(3)], z_1[int(4)], z_1[int(5)], 0.0f)) ;
    return;
}

void project_displacement_slot_0(uint tid_15, const Island_natural_0 thread* isl_22, uint slot_5, KernelContext_0 thread* kernelContext_77)
{
    uint _S915;
    float3 _S916 = float3(0.0f) ;
    thread float3 p_17 = _S916;
    thread float3 l_6 = _S916;
    uint4 _S917 = uint4(isl_22->range_0) ;
    uint _S918 = _S917.x + tid_15;
    uint c_30 = _S918;
    for(;;)
    {
        uint _S919 = _S917.y;
        _S915 = _S919;
        if(c_30 < _S919)
        {
        }
        else
        {
            break;
        }
        uint _S920 = sv_0(c_30, slot_5, kernelContext_77);
        float3 u_0 = (float4(*(kernelContext_77->scratch_0+_S920)) ).xyz;
        uint _S921 = sv_0(c_30, slot_5 + 1U, kernelContext_77);
        float3 th_2 = (float4(*(kernelContext_77->scratch_0+_S921)) ).xyz;
        float3 r_14 = (float4((kernelContext_77->chunks_0+c_30)->center_0) ).xyz - (float4(isl_22->com_0) ).xyz;
        p_17 = p_17 + u_0 * float3((float4((kernelContext_77->chunks_0+c_30)->center_0) ).w) ;
        l_6 = l_6 + (cross(r_14, u_0) * float3((float4((kernelContext_77->chunks_0+c_30)->center_0) ).w)  + rows_mul_0(float4((kernelContext_77->chunks_0+c_30)->inertia0_1) , float4((kernelContext_77->chunks_0+c_30)->inertia1_1) , float4((kernelContext_77->chunks_0+c_30)->inertia2_1) , th_2));
        c_30 = c_30 + 256U;
    }
    group_sum3_0(tid_15, &p_17, &l_6, kernelContext_77);
    float4 _S922 = float4(isl_22->com_0) ;
    float3 _S923 = p_17 / float3(_S922.w) ;
    float3 _S924 = rows_mul_0(float4(isl_22->inv0_0) , float4(isl_22->inv1_0) , float4(isl_22->inv2_0) , l_6);
    c_30 = _S918;
    for(;;)
    {
        if(c_30 < _S915)
        {
        }
        else
        {
            break;
        }
        float3 r_15 = (float4((kernelContext_77->chunks_0+c_30)->center_0) ).xyz - _S922.xyz;
        uint _S925 = sv_0(c_30, slot_5, kernelContext_77);
        *(kernelContext_77->scratch_0+_S925) = packed_float4(float4((float4(*(kernelContext_77->scratch_0+_S925)) ).xyz - _S923 - cross(_S924, r_15), 0.0f)) ;
        uint _S926 = sv_0(c_30, slot_5 + 1U, kernelContext_77);
        *(kernelContext_77->scratch_0+_S926) = packed_float4(float4((float4(*(kernelContext_77->scratch_0+_S926)) ).xyz - _S924, 0.0f)) ;
        c_30 = c_30 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    return;
}

uint statics_result_slot_0(uint island_4, KernelContext_0 thread* kernelContext_78)
{
    return kernelContext_78->params_0->statics_base_0 + 23U * kernelContext_78->params_0->chunk_count_0 + 2U * kernelContext_78->params_0->statics_bonds_0 + island_4;
}

float3 to_body_0(uint _S927, float3 _S928, KernelContext_0 thread* kernelContext_79)
{
    BondStatic_natural_0 device* _S929 = kernelContext_79->bonds_0+_S927;
    return (float4(_S929->t1_0) ).xyz * float3(_S928.x)  + (float4(_S929->t2_0) ).xyz * float3(_S928.y)  + (float4(_S929->normal_0) ).xyz * float3(_S928.z) ;
}

void write_bond_loads_0(uint _S930, uint _S931, float3 _S932, float3 _S933, float _S934, KernelContext_0 thread* kernelContext_80)
{
    BondStatic_natural_0 device* _S935 = kernelContext_80->bonds_0+_S931;
    float3 _S936 = to_body_0(_S931, _S932, kernelContext_80);
    float3 _S937 = to_body_0(_S931, _S933, kernelContext_80);
    uint _S938 = 3U * _S930;
    *(kernelContext_80->scratch_0+_S938) = packed_float4(float4(_S936, _S934)) ;
    *(kernelContext_80->scratch_0+(_S938 + 1U)) = packed_float4(float4(_S937 + cross((float4(_S935->ra_0) ).xyz, _S936), 0.0f)) ;
    *(kernelContext_80->scratch_0+(_S938 + 2U)) = packed_float4(float4(- _S937 + cross((float4(_S935->rb_0) ).xyz, - _S936), 0.0f)) ;
    return;
}

void bond_kinematics_0(uint _S939, float3 _S940, float3 _S941, float3 _S942, float3 _S943, float3 thread* _S944, float3 thread* _S945, KernelContext_0 thread* kernelContext_81)
{
    BondStatic_natural_0 device* _S946 = kernelContext_81->bonds_0+_S939;
    float3 _S947 = to_local_0(_S939, _S942 + cross(_S943, (float4(_S946->rb_0) ).xyz) - (_S940 + cross(_S941, (float4(_S946->ra_0) ).xyz)), kernelContext_81);
    *_S944 = _S947;
    float3 _S948 = to_local_0(_S939, _S943 - _S941, kernelContext_81);
    *_S945 = _S948;
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
    uint c_31;
    thread KernelContext_0 kernelContext_82;
    (&kernelContext_82)->params_0 = params_8;
    (&kernelContext_82)->islands_0 = islands_8;
    (&kernelContext_82)->index_0 = index_8;
    (&kernelContext_82)->chunks_0 = chunks_8;
    (&kernelContext_82)->state_0 = state_10;
    (&kernelContext_82)->scratch_0 = scratch_8;
    (&kernelContext_82)->contact_state_0 = contact_state_8;
    (&kernelContext_82)->loads_0 = loads_8;
    (&kernelContext_82)->impactors_0 = impactors_8;
    (&kernelContext_82)->bond_dyn_0 = bond_dyn_8;
    (&kernelContext_82)->bonds_0 = bonds_8;
    (&kernelContext_82)->materials_0 = materials_8;
    threadgroup array<float4, int(32)> g_part_a_8;
    (&kernelContext_82)->g_part_a_0 = &g_part_a_8;
    threadgroup array<float4, int(32)> g_part_b_8;
    (&kernelContext_82)->g_part_b_0 = &g_part_b_8;
    threadgroup array<uint, int(5)> g_seen_8;
    (&kernelContext_82)->g_seen_0 = &g_seen_8;
    threadgroup uint g_wide_run_8;
    (&kernelContext_82)->g_wide_run_0 = &g_wide_run_8;
    threadgroup array<uint, int(4096)> g_label_8;
    (&kernelContext_82)->g_label_0 = &g_label_8;
    threadgroup uint g_changed_8;
    (&kernelContext_82)->g_changed_0 = &g_changed_8;
    threadgroup uint g_halt_8;
    (&kernelContext_82)->g_halt_0 = &g_halt_8;
    threadgroup uint g_run_8;
    (&kernelContext_82)->g_run_0 = &g_run_8;
    threadgroup array<uint, int(512)> g_label_narrow_8;
    (&kernelContext_82)->g_label_narrow_0 = &g_label_narrow_8;
    threadgroup uint g_changed_narrow_8;
    (&kernelContext_82)->g_changed_narrow_0 = &g_changed_narrow_8;
    uint tid_16 = thread_5.x;
    uint _S949 = group_5.x;
    thread Island_natural_0 _S950 = *(islands_8+_S949);
    uint4 _S951 = uint4((&_S950)->info_0) ;
    uint _S952 = _S951.z;
    if((_S952 & 8U) == 0U)
    {
        return;
    }
    bool free_0 = ((_S951.x) & 1U) == 0U;
    uint4 _S953 = uint4((&_S950)->range_0) ;
    uint c0_1 = _S953.x;
    uint c1_1 = _S953.y;
    uint b0_0 = _S953.z;
    uint _S954 = _S953.w;
    uint _S955 = c0_1 + tid_16;
    uint c_32 = _S955;
    for(;;)
    {
        if(c_32 < c1_1)
        {
        }
        else
        {
            break;
        }
        uint _S956 = sv_0(c_32, 21U, &kernelContext_82);
        packed_float4 _S957 = packed_float4(float4(0.0f) ) ;
        *((&kernelContext_82)->scratch_0+_S956) = _S957;
        uint _S958 = sv_0(c_32, 22U, &kernelContext_82);
        *((&kernelContext_82)->scratch_0+_S958) = _S957;
        c_32 = c_32 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    if(free_0)
    {
        project_load_slot_0(tid_16, &_S950, 0U, &kernelContext_82);
    }
    float _S959 = island_dot_0(tid_16, c0_1, c1_1, 0U, 0U, &kernelContext_82);
    float _S960 = max(sqrt(_S959), 1.00000000317107685e-30f);
    float _S961 = (&kernelContext_82)->params_0->statics_tol_0;
    uint _S962 = min((&kernelContext_82)->params_0->statics_cg_0, 20U * (c1_1 - c0_1) * 6U + 200U);
    float previous_1 = 1.00000001504746622e+30f;
    float residual_0 = 0.0f;
    uint newton_0 = 0U;
    uint cg_total_0 = 0U;
    for(;;)
    {
        if(newton_0 < ((&kernelContext_82)->params_0->statics_newton_0))
        {
        }
        else
        {
            converged_2 = false;
            break;
        }
        uint _S963 = b0_0 + tid_16;
        i_18 = _S963;
        for(;;)
        {
            if(i_18 < _S954)
            {
            }
            else
            {
                break;
            }
            JointResponse_0 _S964 = static_response_0(i_18, &kernelContext_82);
            write_bond_loads_0(i_18, i_18, _S964.force_lin_1, _S964.force_ang_1, 0.0f, &kernelContext_82);
            i_18 = i_18 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        float4 _S965 = float4(0.0f) ;
        thread float4 magnitude_0 = _S965;
        thread float4 unused_m_0 = _S965;
        c_32 = _S955;
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
            gather_loads_0(c_32, &fi_2, &mi_1, &kernelContext_82);
            float _S966 = bond_load_magnitude2_0(c_32, &kernelContext_82);
            magnitude_0.x = magnitude_0.x + _S966;
            uint _S967 = sv_0(c_32, 0U, &kernelContext_82);
            thread float4 r_lin_0 = float4((float4(*((&kernelContext_82)->scratch_0+_S967)) ).xyz + fi_2, 0.0f);
            uint _S968 = sv_0(c_32, 1U, &kernelContext_82);
            thread float4 r_ang_0 = float4((float4(*((&kernelContext_82)->scratch_0+_S968)) ).xyz + mi_1, 0.0f);
            uint _S969 = fixed_mask_0(c_32, &kernelContext_82);
            hold_0(_S969, &r_lin_0, &r_ang_0, _S965, _S965);
            uint _S970 = sv_0(c_32, 4U, &kernelContext_82);
            *((&kernelContext_82)->scratch_0+_S970) = packed_float4(r_lin_0) ;
            uint _S971 = sv_0(c_32, 5U, &kernelContext_82);
            *((&kernelContext_82)->scratch_0+_S971) = packed_float4(r_ang_0) ;
            c_32 = c_32 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        group_sum2_0(tid_16, &magnitude_0, &unused_m_0, &kernelContext_82);
        if(free_0)
        {
            project_load_slot_0(tid_16, &_S950, 4U, &kernelContext_82);
        }
        float _S972 = island_dot_0(tid_16, c0_1, c1_1, 4U, 4U, &kernelContext_82);
        float residual_1 = sqrt(_S972) / _S960;
        float _S973 = max(0.00100000004749745f, 3.83999986297567375e-06f * sqrt(magnitude_0.x) / _S960);
        if(residual_1 <= _S961)
        {
            converged_2 = true;
        }
        else
        {
            if(residual_1 <= _S973)
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
        uint i_19 = _S963;
        for(;;)
        {
            if(i_19 < _S954)
            {
            }
            else
            {
                break;
            }
            BondStatic_natural_0 device* _S974 = (&kernelContext_82)->bonds_0+i_19;
            thread float3 d_lin_5;
            thread float3 d_ang_4;
            static_kinematics_0(i_19, &d_lin_5, &d_ang_4, &kernelContext_82);
            thread JointBond_natural_0 _S975 = _S974->law_0;
            thread JointState_0 _S976 = ((&kernelContext_82)->bond_dyn_0+i_19)->js_0;
            thread float3 f_lin_1;
            thread float3 f_ang_1;
            secant_factors_0(&_S975, &_S976, d_lin_5, &f_lin_1, &f_ang_1);
            float4 _S977 = float4((&_S975)->stiff0_0) ;
            uint _S978 = statics_bond_slot_0(i_19, &kernelContext_82);
            float _S979 = _S977.y;
            *((&kernelContext_82)->scratch_0+_S978) = packed_float4(float4(_S979 * f_lin_1.x, _S979 * f_lin_1.y, _S977.x * f_lin_1.z, 0.0f)) ;
            *((&kernelContext_82)->scratch_0+(_S978 + 1U)) = packed_float4(float4(_S977.z * f_ang_1.x, _S977.w * f_ang_1.y, (float4((&_S975)->stiff1_0) ).x * f_ang_1.z, 0.0f)) ;
            i_19 = i_19 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_33 = _S955;
        for(;;)
        {
            if(c_33 < c1_1)
            {
            }
            else
            {
                break;
            }
            assemble_block_0(c_33, &kernelContext_82);
            uint _S980 = sv_0(c_33, 2U, &kernelContext_82);
            packed_float4 _S981 = packed_float4(_S965) ;
            *((&kernelContext_82)->scratch_0+_S980) = _S981;
            uint _S982 = sv_0(c_33, 3U, &kernelContext_82);
            *((&kernelContext_82)->scratch_0+_S982) = _S981;
            c_33 = c_33 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_34 = _S955;
        for(;;)
        {
            if(c_34 < c1_1)
            {
            }
            else
            {
                break;
            }
            precondition_0(c_34, &kernelContext_82);
            c_34 = c_34 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        if(free_0)
        {
            project_displacement_slot_0(tid_16, &_S950, 6U, &kernelContext_82);
        }
        uint c_35 = _S955;
        for(;;)
        {
            if(c_35 < c1_1)
            {
            }
            else
            {
                break;
            }
            uint _S983 = sv_0(c_35, 8U, &kernelContext_82);
            packed_float4 device* _S984 = (&kernelContext_82)->scratch_0+_S983;
            uint _S985 = sv_0(c_35, 6U, &kernelContext_82);
            *_S984 = packed_float4(float4(*((&kernelContext_82)->scratch_0+_S985)) ) ;
            uint _S986 = sv_0(c_35, 9U, &kernelContext_82);
            packed_float4 device* _S987 = (&kernelContext_82)->scratch_0+_S986;
            uint _S988 = sv_0(c_35, 7U, &kernelContext_82);
            *_S987 = packed_float4(float4(*((&kernelContext_82)->scratch_0+_S988)) ) ;
            c_35 = c_35 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        float _S989 = island_dot_0(tid_16, c0_1, c1_1, 4U, 6U, &kernelContext_82);
        float _S990 = island_dot_0(tid_16, c0_1, c1_1, 4U, 4U, &kernelContext_82);
        float _S991 = sqrt(_S990);
        float rz_0 = _S989;
        uint k_21 = 0U;
        uint cg_total_1 = cg_total_0;
        for(;;)
        {
            bool _S992;
            if(k_21 < _S962)
            {
                _S992 = _S991 > 0.0f;
            }
            else
            {
                _S992 = false;
            }
            if(_S992)
            {
            }
            else
            {
                cg_total_0 = cg_total_1;
                break;
            }
            uint i_20 = _S963;
            for(;;)
            {
                if(i_20 < _S954)
                {
                }
                else
                {
                    break;
                }
                uint4 _S993 = uint4(((&kernelContext_82)->bonds_0+i_20)->law_0.ids_0) ;
                uint ca_2 = _S993.y;
                uint cb_2 = _S993.z;
                uint _S994 = sv_0(ca_2, 8U, &kernelContext_82);
                float3 _S995 = (float4(*((&kernelContext_82)->scratch_0+_S994)) ).xyz;
                uint _S996 = sv_0(ca_2, 9U, &kernelContext_82);
                float3 _S997 = (float4(*((&kernelContext_82)->scratch_0+_S996)) ).xyz;
                uint _S998 = sv_0(cb_2, 8U, &kernelContext_82);
                float3 _S999 = (float4(*((&kernelContext_82)->scratch_0+_S998)) ).xyz;
                uint _S1000 = sv_0(cb_2, 9U, &kernelContext_82);
                thread float3 d_lin_6;
                thread float3 d_ang_5;
                bond_kinematics_0(i_20, _S995, _S997, _S999, (float4(*((&kernelContext_82)->scratch_0+_S1000)) ).xyz, &d_lin_6, &d_ang_5, &kernelContext_82);
                uint _S1001 = statics_bond_slot_0(i_20, &kernelContext_82);
                write_bond_loads_0(i_20, i_20, d_lin_6 * (float4(*((&kernelContext_82)->scratch_0+_S1001)) ).xyz, d_ang_5 * (float4(*((&kernelContext_82)->scratch_0+(_S1001 + 1U))) ).xyz, 0.0f, &kernelContext_82);
                i_20 = i_20 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            c_31 = _S955;
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
                gather_loads_0(c_31, &fi_3, &mi_2, &kernelContext_82);
                thread float4 ap_lin_0 = float4(- fi_3, 0.0f);
                thread float4 ap_ang_0 = float4(- mi_2, 0.0f);
                uint _S1002 = fixed_mask_0(c_31, &kernelContext_82);
                uint _S1003 = sv_0(c_31, 8U, &kernelContext_82);
                float4 _S1004 = float4(*((&kernelContext_82)->scratch_0+_S1003)) ;
                uint _S1005 = sv_0(c_31, 9U, &kernelContext_82);
                hold_0(_S1002, &ap_lin_0, &ap_ang_0, _S1004, float4(*((&kernelContext_82)->scratch_0+_S1005)) );
                uint _S1006 = sv_0(c_31, 10U, &kernelContext_82);
                *((&kernelContext_82)->scratch_0+_S1006) = packed_float4(ap_lin_0) ;
                uint _S1007 = sv_0(c_31, 11U, &kernelContext_82);
                *((&kernelContext_82)->scratch_0+_S1007) = packed_float4(ap_ang_0) ;
                c_31 = c_31 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            float _S1008 = island_dot_0(tid_16, c0_1, c1_1, 8U, 10U, &kernelContext_82);
            uint _S1009 = cg_total_1 + 1U;
            if(_S1008 <= 0.0f)
            {
                cg_total_0 = _S1009;
                break;
            }
            float _S1010 = rz_0 / _S1008;
            uint c_36 = _S955;
            for(;;)
            {
                if(c_36 < c1_1)
                {
                }
                else
                {
                    break;
                }
                uint _S1011 = sv_0(c_36, 2U, &kernelContext_82);
                packed_float4 device* _S1012 = (&kernelContext_82)->scratch_0+_S1011;
                float3 _S1013 = (float4(*((&kernelContext_82)->scratch_0+_S1011)) ).xyz;
                uint _S1014 = sv_0(c_36, 8U, &kernelContext_82);
                float3 _S1015 = float3(_S1010) ;
                *_S1012 = packed_float4(float4(_S1013 + _S1015 * (float4(*((&kernelContext_82)->scratch_0+_S1014)) ).xyz, 0.0f)) ;
                uint _S1016 = sv_0(c_36, 3U, &kernelContext_82);
                packed_float4 device* _S1017 = (&kernelContext_82)->scratch_0+_S1016;
                float3 _S1018 = (float4(*((&kernelContext_82)->scratch_0+_S1016)) ).xyz;
                uint _S1019 = sv_0(c_36, 9U, &kernelContext_82);
                *_S1017 = packed_float4(float4(_S1018 + _S1015 * (float4(*((&kernelContext_82)->scratch_0+_S1019)) ).xyz, 0.0f)) ;
                uint _S1020 = sv_0(c_36, 4U, &kernelContext_82);
                packed_float4 device* _S1021 = (&kernelContext_82)->scratch_0+_S1020;
                float3 _S1022 = (float4(*((&kernelContext_82)->scratch_0+_S1020)) ).xyz;
                uint _S1023 = sv_0(c_36, 10U, &kernelContext_82);
                *_S1021 = packed_float4(float4(_S1022 - _S1015 * (float4(*((&kernelContext_82)->scratch_0+_S1023)) ).xyz, 0.0f)) ;
                uint _S1024 = sv_0(c_36, 5U, &kernelContext_82);
                packed_float4 device* _S1025 = (&kernelContext_82)->scratch_0+_S1024;
                float3 _S1026 = (float4(*((&kernelContext_82)->scratch_0+_S1024)) ).xyz;
                uint _S1027 = sv_0(c_36, 11U, &kernelContext_82);
                *_S1025 = packed_float4(float4(_S1026 - _S1015 * (float4(*((&kernelContext_82)->scratch_0+_S1027)) ).xyz, 0.0f)) ;
                c_36 = c_36 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            float _S1028 = island_dot_0(tid_16, c0_1, c1_1, 4U, 4U, &kernelContext_82);
            if((sqrt(_S1028)) <= (0.00009999999747379f * _S991))
            {
                cg_total_0 = _S1009;
                break;
            }
            uint c_37 = _S955;
            for(;;)
            {
                if(c_37 < c1_1)
                {
                }
                else
                {
                    break;
                }
                precondition_0(c_37, &kernelContext_82);
                c_37 = c_37 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            if(free_0)
            {
                project_displacement_slot_0(tid_16, &_S950, 6U, &kernelContext_82);
            }
            float _S1029 = island_dot_0(tid_16, c0_1, c1_1, 4U, 6U, &kernelContext_82);
            float _S1030 = _S1029 / rz_0;
            uint c_38 = _S955;
            for(;;)
            {
                if(c_38 < c1_1)
                {
                }
                else
                {
                    break;
                }
                uint _S1031 = sv_0(c_38, 8U, &kernelContext_82);
                packed_float4 device* _S1032 = (&kernelContext_82)->scratch_0+_S1031;
                uint _S1033 = sv_0(c_38, 6U, &kernelContext_82);
                float3 _S1034 = float3(_S1030) ;
                *_S1032 = packed_float4(float4((float4(*((&kernelContext_82)->scratch_0+_S1033)) ).xyz + _S1034 * (float4(*((&kernelContext_82)->scratch_0+_S1031)) ).xyz, 0.0f)) ;
                uint _S1035 = sv_0(c_38, 9U, &kernelContext_82);
                packed_float4 device* _S1036 = (&kernelContext_82)->scratch_0+_S1035;
                uint _S1037 = sv_0(c_38, 7U, &kernelContext_82);
                *_S1036 = packed_float4(float4((float4(*((&kernelContext_82)->scratch_0+_S1037)) ).xyz + _S1034 * (float4(*((&kernelContext_82)->scratch_0+_S1035)) ).xyz, 0.0f)) ;
                c_38 = c_38 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            uint _S1038 = k_21 + 1U;
            rz_0 = _S1029;
            k_21 = _S1038;
            cg_total_1 = _S1009;
        }
        c_31 = _S955;
        for(;;)
        {
            if(c_31 < c1_1)
            {
            }
            else
            {
                break;
            }
            uint _S1039 = 4U * c_31;
            thread float3 u_1 = (float4(*((&kernelContext_82)->state_0+_S1039)) ).xyz;
            uint _S1040 = sv_0(c_31, 21U, &kernelContext_82);
            thread float3 u_lo_0 = (float4(*((&kernelContext_82)->scratch_0+_S1040)) ).xyz;
            uint _S1041 = _S1039 + 1U;
            thread float3 th_3 = (float4(*((&kernelContext_82)->state_0+_S1041)) ).xyz;
            uint _S1042 = sv_0(c_31, 22U, &kernelContext_82);
            thread float3 th_lo_0 = (float4(*((&kernelContext_82)->scratch_0+_S1042)) ).xyz;
            uint _S1043 = sv_0(c_31, 2U, &kernelContext_82);
            comp_add_0(&u_1, &u_lo_0, (float4(*((&kernelContext_82)->scratch_0+_S1043)) ).xyz);
            uint _S1044 = sv_0(c_31, 3U, &kernelContext_82);
            comp_add_0(&th_3, &th_lo_0, (float4(*((&kernelContext_82)->scratch_0+_S1044)) ).xyz);
            *((&kernelContext_82)->state_0+_S1039) = packed_float4(float4(u_1, (float4(*((&kernelContext_82)->state_0+_S1039)) ).w)) ;
            *((&kernelContext_82)->state_0+_S1041) = packed_float4(float4(th_3, (float4(*((&kernelContext_82)->state_0+_S1041)) ).w)) ;
            *((&kernelContext_82)->scratch_0+_S1040) = packed_float4(float4(u_lo_0, 0.0f)) ;
            *((&kernelContext_82)->scratch_0+_S1042) = packed_float4(float4(th_lo_0, 0.0f)) ;
            c_31 = c_31 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint _S1045 = newton_0 + 1U;
        previous_1 = residual_1;
        residual_0 = residual_1;
        newton_0 = _S1045;
    }
    i_18 = b0_0 + tid_16;
    for(;;)
    {
        if(i_18 < _S954)
        {
        }
        else
        {
            break;
        }
        JointResponse_0 _S1046 = static_response_0(i_18, &kernelContext_82);
        BondDyn_natural_0 device* _S1047 = (&kernelContext_82)->bond_dyn_0+i_18;
        float4 _S1048 = float4((*_S1047).force_lin_0) ;
        float4 _S1049 = float4((*_S1047).force_ang_0) ;
        float4 _S1050 = float4((*_S1047).sums_0) ;
        float4 _S1051 = float4((*_S1047).comps_0) ;
        uint4 _S1052 = uint4((*_S1047).events_0) ;
        thread BondDyn_0 bd_0;
        (&bd_0)->js_0 = (*_S1047).js_0;
        (&bd_0)->force_lin_0 = _S1048;
        (&bd_0)->force_ang_0 = _S1049;
        (&bd_0)->sums_0 = _S1050;
        (&bd_0)->comps_0 = _S1051;
        (&bd_0)->events_0 = _S1052;
        (&bd_0)->force_lin_0 = float4(_S1046.force_lin_1, _S1046.stored_3);
        (&bd_0)->force_ang_0 = float4(_S1046.force_ang_1, (&bd_0)->force_ang_0.w);
        BondDyn_natural_0 device* _S1053 = (&kernelContext_82)->bond_dyn_0+i_18;
        _S1053->js_0 = bd_0.js_0;
        _S1053->force_lin_0 = packed_float4(bd_0.force_lin_0) ;
        _S1053->force_ang_0 = packed_float4(bd_0.force_ang_0) ;
        _S1053->sums_0 = packed_float4(bd_0.sums_0) ;
        _S1053->comps_0 = packed_float4(bd_0.comps_0) ;
        _S1053->events_0 = packed_uint4(bd_0.events_0) ;
        write_bond_loads_0(i_18, i_18, _S1046.force_lin_1, _S1046.force_ang_1, max(_S1046.measures_0.tension_0, _S1046.measures_0.compression_0), &kernelContext_82);
        i_18 = i_18 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    c_32 = _S955;
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
        gather_loads_0(c_32, &fi_4, &mi_3, &kernelContext_82);
        uint _S1054 = fixed_mask_0(c_32, &kernelContext_82);
        float3 reaction_0;
        if(_S1054 != 0U)
        {
            uint _S1055 = sv_0(c_32, 0U, &kernelContext_82);
            reaction_0 = - ((float4(*((&kernelContext_82)->scratch_0+_S1055)) ).xyz + fi_4);
        }
        else
        {
            uint _S1056 = 4U * c_32;
            reaction_0 = float3((float4(*((&kernelContext_82)->state_0+(_S1056 + 1U))) ).w, (float4(*((&kernelContext_82)->state_0+(_S1056 + 2U))) ).w, (float4(*((&kernelContext_82)->state_0+(_S1056 + 3U))) ).w);
        }
        uint _S1057 = 4U * c_32;
        uint _S1058 = _S1057 + 1U;
        *((&kernelContext_82)->state_0+_S1058) = packed_float4(float4((float4(*((&kernelContext_82)->state_0+_S1058)) ).xyz, reaction_0.x)) ;
        *((&kernelContext_82)->state_0+(_S1057 + 2U)) = packed_float4(float4(0.0f, 0.0f, 0.0f, reaction_0.y)) ;
        *((&kernelContext_82)->state_0+(_S1057 + 3U)) = packed_float4(float4(0.0f, 0.0f, 0.0f, reaction_0.z)) ;
        c_32 = c_32 + 256U;
    }
    if(tid_16 == 0U)
    {
        uint _S1059 = statics_result_slot_0(_S949, &kernelContext_82);
        packed_float4 device* _S1060 = (&kernelContext_82)->scratch_0+_S1059;
        float _S1061 = (as_type<float>((newton_0)));
        float _S1062 = (as_type<float>((cg_total_0)));
        if(converged_2)
        {
            previous_1 = 1.0f;
        }
        else
        {
            previous_1 = 0.0f;
        }
        *_S1060 = packed_float4(float4(residual_0, _S1061, _S1062, previous_1)) ;
        ((&kernelContext_82)->islands_0+_S949)->info_0[int(2)] = _S952 & 4294967287U;
    }
    return;
}

bool is_damaged_0(const JointState_0 thread* st_3)
{
    bool _S1063;
    if((st_3->damage_0) > 0.0f)
    {
        _S1063 = true;
    }
    else
    {
        _S1063 = (st_3->crush_1) > 0.0f;
    }
    return _S1063;
}

[[kernel]] void settled_fatigue(uint3 group_6 [[threadgroup_position_in_grid]], uint3 thread_6 [[thread_position_in_threadgroup]], Params_0 constant* params_9 [[buffer(0)]], Island_natural_0 device* islands_9 [[buffer(9)]], uint device* index_9 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_9 [[buffer(3)]], packed_float4 device* state_11 [[buffer(6)]], packed_float4 device* scratch_9 [[buffer(8)]], packed_float4 device* contact_state_9 [[buffer(11)]], packed_float4 device* loads_9 [[buffer(5)]], Impactor_natural_0 device* impactors_9 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_9 [[buffer(7)]], BondStatic_natural_0 device* bonds_9 [[buffer(2)]], MaterialTable_0 constant* materials_9 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_83;
    (&kernelContext_83)->params_0 = params_9;
    (&kernelContext_83)->islands_0 = islands_9;
    (&kernelContext_83)->index_0 = index_9;
    (&kernelContext_83)->chunks_0 = chunks_9;
    (&kernelContext_83)->state_0 = state_11;
    (&kernelContext_83)->scratch_0 = scratch_9;
    (&kernelContext_83)->contact_state_0 = contact_state_9;
    (&kernelContext_83)->loads_0 = loads_9;
    (&kernelContext_83)->impactors_0 = impactors_9;
    (&kernelContext_83)->bond_dyn_0 = bond_dyn_9;
    (&kernelContext_83)->bonds_0 = bonds_9;
    (&kernelContext_83)->materials_0 = materials_9;
    threadgroup array<float4, int(32)> g_part_a_9;
    (&kernelContext_83)->g_part_a_0 = &g_part_a_9;
    threadgroup array<float4, int(32)> g_part_b_9;
    (&kernelContext_83)->g_part_b_0 = &g_part_b_9;
    threadgroup array<uint, int(5)> g_seen_9;
    (&kernelContext_83)->g_seen_0 = &g_seen_9;
    threadgroup uint g_wide_run_9;
    (&kernelContext_83)->g_wide_run_0 = &g_wide_run_9;
    threadgroup array<uint, int(4096)> g_label_9;
    (&kernelContext_83)->g_label_0 = &g_label_9;
    threadgroup uint g_changed_9;
    (&kernelContext_83)->g_changed_0 = &g_changed_9;
    threadgroup uint g_halt_9;
    (&kernelContext_83)->g_halt_0 = &g_halt_9;
    threadgroup uint g_run_9;
    (&kernelContext_83)->g_run_0 = &g_run_9;
    threadgroup array<uint, int(512)> g_label_narrow_9;
    (&kernelContext_83)->g_label_narrow_0 = &g_label_narrow_9;
    threadgroup uint g_changed_narrow_9;
    (&kernelContext_83)->g_changed_narrow_0 = &g_changed_narrow_9;
    uint tid_17 = thread_6.x;
    uint _S1064 = group_6.x;
    Island_natural_0 device* _S1065 = islands_9+_S1064;
    Island_natural_0 isl_23 = *_S1065;
    uint4 _S1066 = uint4((*_S1065).info_0) ;
    bool _S1067;
    if(((_S1066.x) & 16U) == 0U)
    {
        _S1067 = true;
    }
    else
    {
        uint4 _S1068 = uint4(isl_23.range_0) ;
        _S1067 = (_S1068.w) == (_S1068.z);
    }
    if(_S1067)
    {
        return;
    }
    seen_clear_0(tid_17, &kernelContext_83);
    if(tid_17 == 0U)
    {
        *(&kernelContext_83)->g_halt_0 = 0U;
        *(&kernelContext_83)->g_run_0 = 0U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    uint _S1069 = _S1066.w;
    uint4 _S1070 = uint4(isl_23.range_0) ;
    uint i_21 = _S1070.z + tid_17;
    for(;;)
    {
        if(i_21 < (_S1070.w))
        {
        }
        else
        {
            break;
        }
        BondStatic_natural_0 device* _S1071 = (&kernelContext_83)->bonds_0+i_21;
        BondDyn_natural_0 device* _S1072 = (&kernelContext_83)->bond_dyn_0+i_21;
        float4 _S1073 = float4((*_S1072).force_lin_0) ;
        float4 _S1074 = float4((*_S1072).force_ang_0) ;
        float4 _S1075 = float4((*_S1072).sums_0) ;
        float4 _S1076 = float4((*_S1072).comps_0) ;
        uint4 _S1077 = uint4((*_S1072).events_0) ;
        thread BondDyn_0 bd_1;
        (&bd_1)->js_0 = (*_S1072).js_0;
        (&bd_1)->force_lin_0 = _S1073;
        (&bd_1)->force_ang_0 = _S1074;
        (&bd_1)->sums_0 = _S1075;
        (&bd_1)->comps_0 = _S1076;
        (&bd_1)->events_0 = _S1077;
        thread JointBond_natural_0 _S1078 = _S1071->law_0;
        uint4 _S1079 = uint4((&_S1078)->ids_0) ;
        uint _S1080 = 4U * _S1079.y;
        uint _S1081 = 4U * _S1079.z;
        thread float3 d_lin_7;
        thread float3 d_ang_6;
        bond_kinematics_0(i_21, (float4(*((&kernelContext_83)->state_0+_S1080)) ).xyz, (float4(*((&kernelContext_83)->state_0+(_S1080 + 1U))) ).xyz, (float4(*((&kernelContext_83)->state_0+_S1081)) ).xyz, (float4(*((&kernelContext_83)->state_0+(_S1081 + 1U))) ).xyz, &d_lin_7, &d_ang_6, &kernelContext_83);
        JointState_0 previous_2 = (&bd_1)->js_0;
        float _S1082 = (&kernelContext_83)->params_0->dt_0;
        bool _S1083 = ((&kernelContext_83)->params_0->fracture_0) != 0U;
        _S1078 = _S1071->law_0;
        thread JointState_0 _S1084 = (&bd_1)->js_0;
        JointResponse_0 _S1085 = joint_evaluate_0(&(&kernelContext_83)->materials_0->m_0[_S1079.x], &_S1078, &_S1084, d_lin_7, d_ang_6, _S1082, _S1083);
        if((_S1085.state_8.damage_0) > (previous_2.damage_0 + 9.99999971718068537e-10f))
        {
            _S1067 = true;
        }
        else
        {
            _S1067 = (_S1085.state_8.crush_1) > (previous_2.crush_1 + 9.99999971718068537e-10f);
        }
        uint flags_3;
        if(_S1067)
        {
            flags_3 = 16U;
        }
        else
        {
            flags_3 = 0U;
        }
        thread float _S1086 = (&bd_1)->sums_0.x;
        thread float _S1087 = (&bd_1)->comps_0.x;
        comp_add1_0(&_S1086, &_S1087, _S1085.dissipated_2);
        (&bd_1)->comps_0.x = _S1087;
        (&bd_1)->sums_0.x = _S1086;
        thread float _S1088 = (&bd_1)->sums_0.y;
        thread float _S1089 = (&bd_1)->comps_0.y;
        comp_add1_0(&_S1088, &_S1089, _S1085.overshoot_0);
        (&bd_1)->comps_0.y = _S1089;
        (&bd_1)->sums_0.y = _S1088;
        (&bd_1)->force_lin_0 = float4(_S1085.force_lin_1, _S1085.stored_3);
        (&bd_1)->force_ang_0 = float4(_S1085.force_ang_1, max((&bd_1)->force_ang_0.w, _S1085.state_8.utilization_0));
        thread JointState_0 _S1090 = previous_2;
        bool _S1091 = is_damaged_0(&_S1090);
        bool _S1092;
        if(!_S1091)
        {
            thread JointState_0 _S1093 = _S1085.state_8;
            bool _S1094 = is_damaged_0(&_S1093);
            _S1092 = _S1094;
        }
        else
        {
            _S1092 = false;
        }
        bool _S1095;
        if(_S1092)
        {
            _S1095 = ((&bd_1)->events_0.x) == 0U;
        }
        else
        {
            _S1095 = false;
        }
        if(_S1095)
        {
            (&bd_1)->events_0.x = _S1069;
            (&bd_1)->events_0.w = _S1085.state_8.mode_0;
            (*(&kernelContext_83)->g_seen_0)[3U] = 1U;
        }
        bool _S1096;
        if(((&bd_1)->events_0.y) == 0U)
        {
            _S1096 = (_S1085.state_8.life_0) != (previous_2.life_0);
        }
        else
        {
            _S1096 = false;
        }
        bool _S1097;
        if(_S1096)
        {
            _S1097 = (_S1085.fatigue_before_0) > 0.99000000953674316f;
        }
        else
        {
            _S1097 = false;
        }
        bool _S1098;
        if(_S1097)
        {
            float _S1099 = fatigue_factor_0(&(&kernelContext_83)->materials_0->m_0[_S1079.x], _S1085.state_8.life_0);
            _S1098 = _S1099 <= 0.99000000953674316f;
        }
        else
        {
            _S1098 = false;
        }
        if(_S1098)
        {
            (&bd_1)->events_0.y = _S1069;
            (*(&kernelContext_83)->g_seen_0)[4U] = 1U;
        }
        uint flags_4;
        if(_S1085.disconnected_0)
        {
            (&bd_1)->events_0.z = _S1069;
            flags_4 = flags_3 | 32U;
        }
        else
        {
            flags_4 = flags_3;
        }
        (&bd_1)->js_0 = _S1085.state_8;
        BondDyn_natural_0 device* _S1100 = (&kernelContext_83)->bond_dyn_0+i_21;
        _S1100->js_0 = bd_1.js_0;
        _S1100->force_lin_0 = packed_float4(bd_1.force_lin_0) ;
        _S1100->force_ang_0 = packed_float4(bd_1.force_ang_0) ;
        _S1100->sums_0 = packed_float4(bd_1.sums_0) ;
        _S1100->comps_0 = packed_float4(bd_1.comps_0) ;
        _S1100->events_0 = packed_uint4(bd_1.events_0) ;
        write_bond_loads_0(i_21, i_21, _S1085.force_lin_1, _S1085.force_ang_1, max(_S1085.measures_0.tension_0, _S1085.measures_0.compression_0), &kernelContext_83);
        if((flags_4 & 16U) != 0U)
        {
            *(&kernelContext_83)->g_halt_0 = 1U;
        }
        if((flags_4 & 32U) != 0U)
        {
            *(&kernelContext_83)->g_run_0 = 1U;
        }
        i_21 = i_21 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    if(tid_17 != 0U)
    {
        return;
    }
    if(((*(&kernelContext_83)->g_halt_0) | (*(&kernelContext_83)->g_run_0)) != 0U)
    {
        uint _S1101 = _S1066.z;
        if((*(&kernelContext_83)->g_halt_0) != 0U)
        {
            i_21 = 16U;
        }
        else
        {
            i_21 = 0U;
        }
        uint _S1102 = _S1101 | i_21;
        if((*(&kernelContext_83)->g_run_0) != 0U)
        {
            i_21 = 32U;
        }
        else
        {
            i_21 = 0U;
        }
        ((&kernelContext_83)->islands_0+_S1064)->info_0[int(2)] = _S1102 | i_21;
    }
    uint _S1103 = (isl_23.coverage_0) | 16384U;
    uint _S1104 = seen_bits_0(&kernelContext_83);
    uint _S1105 = _S1103 | _S1104;
    if((*(&kernelContext_83)->g_run_0) != 0U)
    {
        i_21 = 128U;
    }
    else
    {
        i_21 = 0U;
    }
    ((&kernelContext_83)->islands_0+_S1064)->coverage_0 = _S1105 | i_21;
    return;
}

void impactor_integrate_at_0(uint ii_2, uint tid_18, KernelContext_0 thread* kernelContext_84)
{
    float3 p_18;
    if(ii_2 >= (kernelContext_84->params_0->impactor_count_0))
    {
        return;
    }
    Island_natural_0 device* _S1106 = kernelContext_84->islands_0+kernelContext_84->params_0->halt_index_0;
    Impactor_natural_0 device* _S1107 = kernelContext_84->impactors_0+ii_2;
    float4 _S1108 = float4((*_S1107).position_err_1) ;
    float4 _S1109 = float4((*_S1107).velocity_1) ;
    float4 _S1110 = float4((*_S1107).velocity_err_1) ;
    float4 _S1111 = float4((*_S1107).angular_velocity_1) ;
    float4 _S1112 = float4((*_S1107).rotation_1) ;
    float4 _S1113 = float4((*_S1107).inertia0_2) ;
    float4 _S1114 = float4((*_S1107).inertia1_2) ;
    float4 _S1115 = float4((*_S1107).inertia2_2) ;
    float4 _S1116 = float4((*_S1107).inv0_2) ;
    float4 _S1117 = float4((*_S1107).inv1_2) ;
    float4 _S1118 = float4((*_S1107).inv2_2) ;
    float4 _S1119 = float4((*_S1107).shape_0) ;
    float4 _S1120 = float4((*_S1107).half_1) ;
    float4 _S1121 = float4((*_S1107).mat_0) ;
    float4 _S1122 = float4((*_S1107).crush_0) ;
    float4 _S1123 = float4((*_S1107).geom_0) ;
    float4 _S1124 = float4((*_S1107).rotation_err_1) ;
    float4 _S1125 = float4((*_S1107).ledger_0) ;
    uint4 _S1126 = uint4((*_S1107).cand_0) ;
    float4 _S1127 = float4((*_S1107).momentum_1) ;
    float4 _S1128 = float4((*_S1107).momentum_err_1) ;
    thread Impactor_0 imp_6;
    (&imp_6)->position_1 = float4((*_S1107).position_1) ;
    (&imp_6)->position_err_1 = _S1108;
    (&imp_6)->velocity_1 = _S1109;
    (&imp_6)->velocity_err_1 = _S1110;
    (&imp_6)->angular_velocity_1 = _S1111;
    (&imp_6)->rotation_1 = _S1112;
    (&imp_6)->inertia0_2 = _S1113;
    (&imp_6)->inertia1_2 = _S1114;
    (&imp_6)->inertia2_2 = _S1115;
    (&imp_6)->inv0_2 = _S1116;
    (&imp_6)->inv1_2 = _S1117;
    (&imp_6)->inv2_2 = _S1118;
    (&imp_6)->shape_0 = _S1119;
    (&imp_6)->half_1 = _S1120;
    (&imp_6)->mat_0 = _S1121;
    (&imp_6)->crush_0 = _S1122;
    (&imp_6)->geom_0 = _S1123;
    (&imp_6)->rotation_err_1 = _S1124;
    (&imp_6)->ledger_0 = _S1125;
    (&imp_6)->cand_0 = _S1126;
    (&imp_6)->momentum_1 = _S1127;
    (&imp_6)->momentum_err_1 = _S1128;
    uint4 _S1129 = uint4(_S1106->info_0) ;
    bool _S1130;
    if(((_S1129.z) & 1U) != 0U)
    {
        _S1130 = true;
    }
    else
    {
        uint _S1131 = _S1129.y;
        if(_S1131 != 0U)
        {
            _S1130 = ((&imp_6)->cand_0.w) >= _S1131;
        }
        else
        {
            _S1130 = false;
        }
    }
    if(_S1130)
    {
        return;
    }
    if(((&imp_6)->cand_0.z) != 0U)
    {
        if(tid_18 == 0U)
        {
            (kernelContext_84->impactors_0+ii_2)->cand_0[int(3)] = (&imp_6)->cand_0.w + 1U;
        }
        return;
    }
    float4 _S1132 = float4(0.0f) ;
    thread float4 rf_2 = _S1132;
    thread float4 rt_0 = _S1132;
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
        uint _S1133 = 3U * k_22;
        rf_2 = rf_2 + float4(*(kernelContext_84->scratch_0+(kernelContext_84->params_0->cand_base_0 + _S1133 + 1U))) ;
        rt_0 = rt_0 + float4(*(kernelContext_84->scratch_0+(kernelContext_84->params_0->cand_base_0 + _S1133 + 2U))) ;
        k_22 = k_22 + 256U;
    }
    group_sum2_0(tid_18, &rf_2, &rt_0, kernelContext_84);
    if(tid_18 != 0U)
    {
        return;
    }
    float dt_12 = kernelContext_84->params_0->dt_0;
    float3 _S1134 = float3(0.0f) ;
    float3 load_f_0;
    float3 load_t_0;
    if((kernelContext_84->params_0->has_ground_0) != 0U)
    {
        float3 _S1135 = (&imp_6)->half_1.xyz;
        thread Impactor_0 _S1136 = imp_6;
        Box_0 _S1137 = impactor_box_0(&_S1136, _S1134, _S1135);
        float3 _S1138 = (&imp_6)->velocity_1.xyz + (&imp_6)->velocity_err_1.xyz;
        float _S1139 = kernelContext_84->params_0->ground_modulus_0;
        float _S1140 = (&imp_6)->mat_0.x;
        float3 _S1141 = float3(0.0f, 0.0f, 1.0f);
        thread Box_0 _S1142 = _S1137;
        thread Box_0 _S1143 = _S1137;
        float _S1144 = contact_stiffness_0(_S1139, &_S1142, _S1140, &_S1143, _S1141);
        float _S1145 = (&imp_6)->position_1.z - kernelContext_84->params_0->ground_hi_0 + ((&imp_6)->position_err_1.z - kernelContext_84->params_0->ground_lo_0);
        uint total_points_0;
        if(((&imp_6)->shape_0.x) == 0.0f)
        {
            total_points_0 = 1U;
        }
        else
        {
            total_points_0 = 14U;
        }
        float _S1146 = _S1144 / float(min(total_points_0, 5U));
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
                thread Box_0 _S1147 = _S1137;
                float3 _S1148 = sample_point_0(&_S1147, s_11, kernelContext_84);
                p_18 = _S1148;
            }
            if((_S1145 + p_18.z) < 0.0f)
            {
                below_0 = below_0 + 1U;
            }
            s_11 = s_11 + 1U;
        }
        if(below_0 > 0U)
        {
            sentinel_mark_0(8U, kernelContext_84);
        }
        s_11 = 0U;
        load_f_0 = _S1134;
        load_t_0 = _S1134;
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
                thread Box_0 _S1149 = _S1137;
                float3 _S1150 = sample_point_0(&_S1149, s_11, kernelContext_84);
                p_18 = _S1150;
            }
            float depth_4 = - (_S1145 + p_18.z);
            if(depth_4 <= 0.0f)
            {
                s_11 = s_11 + 1U;
                continue;
            }
            thread float stored_7;
            thread float diss_5;
            float3 _S1151 = penalty_force_0(_S1146, (&imp_6)->mat_0.z, kernelContext_84->params_0->ground_friction_0, depth_4, _S1141, _S1138 + cross((&imp_6)->angular_velocity_1.xyz, p_18), dt_12, below_0, &stored_7, &diss_5, kernelContext_84);
            float3 load_f_1 = load_f_0 + _S1151;
            float3 load_t_1 = load_t_0 + cross(p_18, _S1151);
            thread float _S1152 = (&imp_6)->ledger_0.x;
            thread float _S1153 = (&imp_6)->ledger_0.y;
            comp_add1_0(&_S1152, &_S1153, diss_5);
            (&imp_6)->ledger_0.y = _S1153;
            (&imp_6)->ledger_0.x = _S1152;
            load_f_0 = load_f_1;
            load_t_0 = load_t_1;
            s_11 = s_11 + 1U;
        }
    }
    else
    {
        load_f_0 = _S1134;
        load_t_0 = _S1134;
    }
    float3 load_f_2 = rf_2.xyz + load_f_0;
    float3 load_t_2 = rt_0.xyz + load_t_0;
    float m_6 = (&imp_6)->mat_0.z;
    thread float3 vel_3 = (&imp_6)->velocity_1.xyz;
    thread float3 vel_err_1 = (&imp_6)->velocity_err_1.xyz;
    float3 _S1154 = float3(dt_12) ;
    comp_add_0(&vel_3, &vel_err_1, (load_f_2 / float3(m_6)  + kernelContext_84->params_0->gravity_0.xyz) * _S1154);
    Quat_0 _S1155 = quat_of_0((&imp_6)->rotation_1);
    thread Quat_0 q_15 = _S1155;
    thread float4 q_err_0 = (&imp_6)->rotation_err_1;
    thread float3 l_hi_0 = (&imp_6)->momentum_1.xyz;
    thread float3 l_err_1 = (&imp_6)->momentum_err_1.xyz;
    comp_add_0(&l_hi_0, &l_err_1, load_t_2 * _S1154);
    float3 l_7 = l_hi_0 + l_err_1;
    thread Quat_0 _S1156 = _S1155;
    float3 _S1157 = world_mul_0(&_S1156, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_7);
    thread float3 pos_1 = (&imp_6)->position_1.xyz;
    thread float3 pos_err_1 = (&imp_6)->position_err_1.xyz;
    comp_add_0(&pos_1, &pos_err_1, (vel_3 + vel_err_1) * _S1154);
    turn_left_0(&q_15, &q_err_0, _S1157, dt_12);
    thread Quat_0 _S1158 = q_15;
    float3 _S1159 = world_mul_0(&_S1158, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_7);
    (&imp_6)->angular_velocity_1 = float4(_S1159, 0.0f);
    thread Quat_0 _S1160 = q_15;
    float4 _S1161 = quat_vec_0(&_S1160);
    (&imp_6)->rotation_1 = _S1161;
    (&imp_6)->rotation_err_1 = q_err_0;
    (&imp_6)->momentum_1 = float4(l_hi_0, 0.0f);
    (&imp_6)->momentum_err_1 = float4(l_err_1, 0.0f);
    (&imp_6)->position_1 = float4(pos_1, 0.0f);
    (&imp_6)->position_err_1 = float4(pos_err_1, 0.0f);
    (&imp_6)->velocity_1 = float4(vel_3, 0.0f);
    (&imp_6)->velocity_err_1 = float4(vel_err_1, 0.0f);
    (&imp_6)->cand_0.w = (&imp_6)->cand_0.w + 1U;
    (&imp_6)->geom_0 = float4(1.0f, (&imp_6)->crush_0.w, 0.0f, 0.0f);
    Impactor_natural_0 device* _S1162 = kernelContext_84->impactors_0+ii_2;
    _S1162->position_1 = packed_float4(imp_6.position_1) ;
    _S1162->position_err_1 = packed_float4(imp_6.position_err_1) ;
    _S1162->velocity_1 = packed_float4(imp_6.velocity_1) ;
    _S1162->velocity_err_1 = packed_float4(imp_6.velocity_err_1) ;
    _S1162->angular_velocity_1 = packed_float4(imp_6.angular_velocity_1) ;
    _S1162->rotation_1 = packed_float4(imp_6.rotation_1) ;
    _S1162->inertia0_2 = packed_float4(imp_6.inertia0_2) ;
    _S1162->inertia1_2 = packed_float4(imp_6.inertia1_2) ;
    _S1162->inertia2_2 = packed_float4(imp_6.inertia2_2) ;
    _S1162->inv0_2 = packed_float4(imp_6.inv0_2) ;
    _S1162->inv1_2 = packed_float4(imp_6.inv1_2) ;
    _S1162->inv2_2 = packed_float4(imp_6.inv2_2) ;
    _S1162->shape_0 = packed_float4(imp_6.shape_0) ;
    _S1162->half_1 = packed_float4(imp_6.half_1) ;
    _S1162->mat_0 = packed_float4(imp_6.mat_0) ;
    _S1162->crush_0 = packed_float4(imp_6.crush_0) ;
    _S1162->geom_0 = packed_float4(imp_6.geom_0) ;
    _S1162->rotation_err_1 = packed_float4(imp_6.rotation_err_1) ;
    _S1162->ledger_0 = packed_float4(imp_6.ledger_0) ;
    _S1162->cand_0 = packed_uint4(imp_6.cand_0) ;
    _S1162->momentum_1 = packed_float4(imp_6.momentum_1) ;
    _S1162->momentum_err_1 = packed_float4(imp_6.momentum_err_1) ;
    uint k_23 = (&imp_6)->cand_0.w - 1U - kernelContext_84->params_0->step_start_0;
    if(k_23 < (kernelContext_84->params_0->record_stride_0))
    {
        uint at_7 = kernelContext_84->params_0->record_base_0 + 2U * (ii_2 * kernelContext_84->params_0->record_stride_0 + k_23);
        *(kernelContext_84->scratch_0+at_7) = packed_float4(float4(vel_3 + vel_err_1, 0.0f)) ;
        *(kernelContext_84->scratch_0+(at_7 + 1U)) = packed_float4(float4(pos_1 + pos_err_1, 0.0f)) ;
    }
    return;
}

[[kernel]] void impactor_integrate(uint3 group_7 [[threadgroup_position_in_grid]], uint3 thread_7 [[thread_position_in_threadgroup]], Params_0 constant* params_10 [[buffer(0)]], Island_natural_0 device* islands_10 [[buffer(9)]], uint device* index_10 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_10 [[buffer(3)]], packed_float4 device* state_12 [[buffer(6)]], packed_float4 device* scratch_10 [[buffer(8)]], packed_float4 device* contact_state_10 [[buffer(11)]], packed_float4 device* loads_10 [[buffer(5)]], Impactor_natural_0 device* impactors_10 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_10 [[buffer(7)]], BondStatic_natural_0 device* bonds_10 [[buffer(2)]], MaterialTable_0 constant* materials_10 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_85;
    (&kernelContext_85)->params_0 = params_10;
    (&kernelContext_85)->islands_0 = islands_10;
    (&kernelContext_85)->index_0 = index_10;
    (&kernelContext_85)->chunks_0 = chunks_10;
    (&kernelContext_85)->state_0 = state_12;
    (&kernelContext_85)->scratch_0 = scratch_10;
    (&kernelContext_85)->contact_state_0 = contact_state_10;
    (&kernelContext_85)->loads_0 = loads_10;
    (&kernelContext_85)->impactors_0 = impactors_10;
    (&kernelContext_85)->bond_dyn_0 = bond_dyn_10;
    (&kernelContext_85)->bonds_0 = bonds_10;
    (&kernelContext_85)->materials_0 = materials_10;
    threadgroup array<float4, int(32)> g_part_a_10;
    (&kernelContext_85)->g_part_a_0 = &g_part_a_10;
    threadgroup array<float4, int(32)> g_part_b_10;
    (&kernelContext_85)->g_part_b_0 = &g_part_b_10;
    threadgroup array<uint, int(5)> g_seen_10;
    (&kernelContext_85)->g_seen_0 = &g_seen_10;
    threadgroup uint g_wide_run_10;
    (&kernelContext_85)->g_wide_run_0 = &g_wide_run_10;
    threadgroup array<uint, int(4096)> g_label_10;
    (&kernelContext_85)->g_label_0 = &g_label_10;
    threadgroup uint g_changed_10;
    (&kernelContext_85)->g_changed_0 = &g_changed_10;
    threadgroup uint g_halt_10;
    (&kernelContext_85)->g_halt_0 = &g_halt_10;
    threadgroup uint g_run_10;
    (&kernelContext_85)->g_run_0 = &g_run_10;
    threadgroup array<uint, int(512)> g_label_narrow_10;
    (&kernelContext_85)->g_label_narrow_0 = &g_label_narrow_10;
    threadgroup uint g_changed_narrow_10;
    (&kernelContext_85)->g_changed_narrow_0 = &g_changed_narrow_10;
    impactor_integrate_at_0(group_7.x, thread_7.x, &kernelContext_85);
    return;
}

void ground_contact_0(uint c_39, bool account_0, float3 thread* f_14, float3 thread* t_17, KernelContext_0 thread* kernelContext_86)
{
    WorldPoint_0 _S1163 = chunk_world_0(c_39, kernelContext_86);
    float above_0 = _S1163.hi_0.z - kernelContext_86->params_0->ground_hi_0 + (_S1163.lo_0.z - kernelContext_86->params_0->ground_lo_0) + _S1163.rel_0.z;
    if((above_0 - (float4((kernelContext_86->chunks_0+c_39)->half_0) ).w) > 0.0f)
    {
        return;
    }
    Box_0 _S1164 = chunk_box_0(c_39, float3(0.0f) , kernelContext_86);
    float _S1165 = kernelContext_86->params_0->ground_modulus_0;
    float _S1166 = (float4((kernelContext_86->chunks_0+c_39)->cmat_0) ).x;
    float3 _S1167 = float3(0.0f, 0.0f, 1.0f);
    thread Box_0 _S1168 = _S1164;
    thread Box_0 _S1169 = _S1164;
    float _S1170 = contact_stiffness_0(_S1165, &_S1168, _S1166, &_S1169, _S1167);
    thread Box_0 _S1171 = _S1164;
    uint _S1172 = sample_count_0(&_S1171);
    uint s_12 = 0U;
    uint n_11 = 0U;
    for(;;)
    {
        if(s_12 < _S1172)
        {
        }
        else
        {
            break;
        }
        thread Box_0 _S1173 = _S1164;
        float3 _S1174 = sample_point_0(&_S1173, s_12, kernelContext_86);
        if((above_0 + _S1174.z) < 0.0f)
        {
            n_11 = n_11 + 1U;
        }
        s_12 = s_12 + 1U;
    }
    if(n_11 == 0U)
    {
        return;
    }
    sentinel_mark_0(4U, kernelContext_86);
    thread float3 vc_1;
    thread float3 wc_1;
    chunk_velocity_0(c_39, &vc_1, &wc_1, kernelContext_86);
    thread float4 ledger_2 = float4(*(kernelContext_86->scratch_0+(kernelContext_86->params_0->ledger_base_0 + kernelContext_86->params_0->pair_count_0 + c_39))) ;
    s_12 = 0U;
    for(;;)
    {
        if(s_12 < _S1172)
        {
        }
        else
        {
            break;
        }
        thread Box_0 _S1175 = _S1164;
        float3 _S1176 = sample_point_0(&_S1175, s_12, kernelContext_86);
        float _S1177 = above_0 + _S1176.z;
        if(!(_S1177 < 0.0f))
        {
            s_12 = s_12 + 1U;
            continue;
        }
        thread float stored_8;
        thread float diss_6;
        float3 _S1178 = penalty_force_0(_S1170 / float(max(n_11, 5U)), (float4((kernelContext_86->chunks_0+c_39)->center_0) ).w, kernelContext_86->params_0->ground_friction_0, - _S1177, _S1167, vc_1 + cross(wc_1, _S1176), kernelContext_86->params_0->dt_0, n_11, &stored_8, &diss_6, kernelContext_86);
        *f_14 = *f_14 + _S1178;
        *t_17 = *t_17 + cross(_S1176, _S1178);
        thread float _S1179 = ledger_2.y;
        thread float _S1180 = ledger_2.z;
        comp_add1_0(&_S1179, &_S1180, diss_6);
        ledger_2.z = _S1180;
        ledger_2.y = _S1179;
        s_12 = s_12 + 1U;
    }
    if(account_0)
    {
        *(kernelContext_86->scratch_0+(kernelContext_86->params_0->ledger_base_0 + kernelContext_86->params_0->pair_count_0 + c_39)) = packed_float4(ledger_2) ;
    }
    return;
}

void contact_sum_at_0(uint g_2, KernelContext_0 thread* kernelContext_87)
{
    bool _S1181;
    if(g_2 >= (kernelContext_87->params_0->seg_count_0))
    {
        _S1181 = true;
    }
    else
    {
        bool _S1182 = stopped_0(kernelContext_87);
        _S1181 = _S1182;
    }
    if(_S1181)
    {
        return;
    }
    uint _S1183 = 3U * g_2;
    uint _S1184 = kernelContext_87->index_0[kernelContext_87->params_0->seg_index_0 + _S1183];
    uint begin_1 = kernelContext_87->index_0[kernelContext_87->params_0->seg_index_0 + _S1183 + 1U];
    uint _S1185 = kernelContext_87->index_0[kernelContext_87->params_0->seg_index_0 + _S1183 + 2U];
    float3 _S1186 = float3(0.0f) ;
    thread float3 f_15 = _S1186;
    thread float3 t_18 = _S1186;
    uint e_6 = begin_1;
    for(;;)
    {
        if(e_6 < _S1185)
        {
        }
        else
        {
            break;
        }
        uint entry_5 = kernelContext_87->index_0[e_6];
        if(entry_5 == 2147483648U)
        {
            ground_contact_0(_S1184, true, &f_15, &t_18, kernelContext_87);
            e_6 = e_6 + 1U;
            continue;
        }
        uint _S1187 = 2U * entry_5;
        f_15 = f_15 + (float4(*(kernelContext_87->scratch_0+(kernelContext_87->params_0->slot_base_0 + _S1187))) ).xyz;
        t_18 = t_18 + (float4(*(kernelContext_87->scratch_0+(kernelContext_87->params_0->slot_base_0 + _S1187 + 1U))) ).xyz;
        e_6 = e_6 + 1U;
    }
    uint _S1188 = 2U * g_2;
    *(kernelContext_87->scratch_0+(kernelContext_87->params_0->seg_base_0 + _S1188)) = packed_float4(float4(f_15, 0.0f)) ;
    *(kernelContext_87->scratch_0+(kernelContext_87->params_0->seg_base_0 + _S1188 + 1U)) = packed_float4(float4(t_18, 0.0f)) ;
    return;
}

[[kernel]] void contact_sums(uint3 id_2 [[thread_position_in_grid]], Params_0 constant* params_11 [[buffer(0)]], Island_natural_0 device* islands_11 [[buffer(9)]], uint device* index_11 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_11 [[buffer(3)]], packed_float4 device* state_13 [[buffer(6)]], packed_float4 device* scratch_11 [[buffer(8)]], packed_float4 device* contact_state_11 [[buffer(11)]], packed_float4 device* loads_11 [[buffer(5)]], Impactor_natural_0 device* impactors_11 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_11 [[buffer(7)]], BondStatic_natural_0 device* bonds_11 [[buffer(2)]], MaterialTable_0 constant* materials_11 [[buffer(1)]])
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
    (&kernelContext_88)->bond_dyn_0 = bond_dyn_11;
    (&kernelContext_88)->bonds_0 = bonds_11;
    (&kernelContext_88)->materials_0 = materials_11;
    threadgroup array<float4, int(32)> g_part_a_11;
    (&kernelContext_88)->g_part_a_0 = &g_part_a_11;
    threadgroup array<float4, int(32)> g_part_b_11;
    (&kernelContext_88)->g_part_b_0 = &g_part_b_11;
    threadgroup array<uint, int(5)> g_seen_11;
    (&kernelContext_88)->g_seen_0 = &g_seen_11;
    threadgroup uint g_wide_run_11;
    (&kernelContext_88)->g_wide_run_0 = &g_wide_run_11;
    threadgroup array<uint, int(4096)> g_label_11;
    (&kernelContext_88)->g_label_0 = &g_label_11;
    threadgroup uint g_changed_11;
    (&kernelContext_88)->g_changed_0 = &g_changed_11;
    threadgroup uint g_halt_11;
    (&kernelContext_88)->g_halt_0 = &g_halt_11;
    threadgroup uint g_run_11;
    (&kernelContext_88)->g_run_0 = &g_run_11;
    threadgroup array<uint, int(512)> g_label_narrow_11;
    (&kernelContext_88)->g_label_narrow_0 = &g_label_narrow_11;
    threadgroup uint g_changed_narrow_11;
    (&kernelContext_88)->g_changed_narrow_0 = &g_changed_narrow_11;
    contact_sum_at_0(id_2.x, &kernelContext_88);
    return;
}

void net_load_0(uint c_40, const Island_natural_0 thread* isl_24, const Rigid_0 thread* rg_12, uint k_24, float dt_13, bool contact_4, float3 thread* f_16, float3 thread* t_19, KernelContext_0 thread* kernelContext_89)
{
    thread float3 fl_0;
    thread float3 tl_0;
    thread float3 rep_f_0;
    thread float3 rep_m_0;
    chunk_loads_0(c_40, &rg_12->rot_3, k_24, dt_13, contact_4, 0.0f, &fl_0, &tl_0, &rep_f_0, &rep_m_0, kernelContext_89);
    float3 fc_3 = fl_0 + kernelContext_89->params_0->gravity_0.xyz * float3((float4((kernelContext_89->chunks_0+c_40)->center_0) ).w) ;
    float3 _S1189 = (float4(isl_24->com_0) ).xyz;
    float3 _S1190 = rotate_0(&rg_12->rot_3, (float4((kernelContext_89->chunks_0+c_40)->center_0) ).xyz + (float4(*(kernelContext_89->state_0+4U * c_40)) ).xyz - _S1189);
    *f_16 = *f_16 + fc_3;
    *t_19 = *t_19 + (cross(_S1190, fc_3) + tl_0);
    if(((uint4((kernelContext_89->chunks_0+c_40)->load_range_0) ).y) > ((uint4((kernelContext_89->chunks_0+c_40)->load_range_0) ).x))
    {
        float3 _S1191 = rotate_0(&rg_12->rot_3, rep_f_0);
        *f_16 = *f_16 + _S1191;
        float3 _S1192 = rotate_0(&rg_12->rot_3, (float4((kernelContext_89->chunks_0+c_40)->center_0) ).xyz - _S1189);
        float3 _S1193 = cross(_S1192, _S1191);
        float3 _S1194 = rotate_0(&rg_12->rot_3, rep_m_0);
        *t_19 = *t_19 + (_S1193 + _S1194);
    }
    return;
}

void net_load_1(uint c_41, const Island_0 thread* isl_25, const Rigid_0 thread* rg_13, uint k_25, float dt_14, bool contact_5, float3 thread* f_17, float3 thread* t_20, KernelContext_0 thread* kernelContext_90)
{
    thread float3 fl_1;
    thread float3 tl_1;
    thread float3 rep_f_1;
    thread float3 rep_m_1;
    chunk_loads_0(c_41, &rg_13->rot_3, k_25, dt_14, contact_5, 0.0f, &fl_1, &tl_1, &rep_f_1, &rep_m_1, kernelContext_90);
    float3 fc_4 = fl_1 + kernelContext_90->params_0->gravity_0.xyz * float3((float4((kernelContext_90->chunks_0+c_41)->center_0) ).w) ;
    float3 _S1195 = isl_25->com_0.xyz;
    float3 _S1196 = rotate_0(&rg_13->rot_3, (float4((kernelContext_90->chunks_0+c_41)->center_0) ).xyz + (float4(*(kernelContext_90->state_0+4U * c_41)) ).xyz - _S1195);
    *f_17 = *f_17 + fc_4;
    *t_20 = *t_20 + (cross(_S1196, fc_4) + tl_1);
    if(((uint4((kernelContext_90->chunks_0+c_41)->load_range_0) ).y) > ((uint4((kernelContext_90->chunks_0+c_41)->load_range_0) ).x))
    {
        float3 _S1197 = rotate_0(&rg_13->rot_3, rep_f_1);
        *f_17 = *f_17 + _S1197;
        float3 _S1198 = rotate_0(&rg_13->rot_3, (float4((kernelContext_90->chunks_0+c_41)->center_0) ).xyz - _S1195);
        float3 _S1199 = cross(_S1198, _S1197);
        float3 _S1200 = rotate_0(&rg_13->rot_3, rep_m_1);
        *t_20 = *t_20 + (_S1199 + _S1200);
    }
    return;
}

bool bond_update_0(uint i_22, float dt_15, bool fracture_2, uint abs_step_0, bool wide_0, KernelContext_0 thread* kernelContext_91)
{
    BondStatic_natural_0 device* _S1201 = kernelContext_91->bonds_0+i_22;
    uint4 _S1202 = uint4(_S1201->law_0.ids_0) ;
    float3 ra_1 = (float4(_S1201->ra_0) ).xyz;
    float3 rb_1 = (float4(_S1201->rb_0) ).xyz;
    uint _S1203 = 4U * _S1202.y;
    float3 ta_2 = (float4(*(kernelContext_91->state_0+(_S1203 + 1U))) ).xyz;
    float3 va_0 = (float4(*(kernelContext_91->state_0+(_S1203 + 2U))) ).xyz;
    float3 wa_1 = (float4(*(kernelContext_91->state_0+(_S1203 + 3U))) ).xyz;
    uint _S1204 = 4U * _S1202.z;
    float3 tb_2 = (float4(*(kernelContext_91->state_0+(_S1204 + 1U))) ).xyz;
    float3 vb_0 = (float4(*(kernelContext_91->state_0+(_S1204 + 2U))) ).xyz;
    float3 wb_1 = (float4(*(kernelContext_91->state_0+(_S1204 + 3U))) ).xyz;
    float3 _S1205 = to_local_0(i_22, (float4(*(kernelContext_91->state_0+_S1204)) ).xyz + cross(tb_2, rb_1) - ((float4(*(kernelContext_91->state_0+_S1203)) ).xyz + cross(ta_2, ra_1)), kernelContext_91);
    float3 _S1206 = to_local_0(i_22, tb_2 - ta_2, kernelContext_91);
    float3 _S1207 = to_local_0(i_22, vb_0 + cross(wb_1, rb_1) - (va_0 + cross(wa_1, ra_1)), kernelContext_91);
    float3 _S1208 = to_local_0(i_22, wb_1 - wa_1, kernelContext_91);
    JointState_0 previous_3 = (kernelContext_91->bond_dyn_0+i_22)->js_0;
    thread JointState_0 _S1209 = (kernelContext_91->bond_dyn_0+i_22)->js_0;
    bool _S1210 = is_damaged_0(&_S1209);
    thread JointBond_natural_0 _S1211 = (kernelContext_91->bonds_0+i_22)->law_0;
    thread JointState_0 _S1212 = (kernelContext_91->bond_dyn_0+i_22)->js_0;
    JointResponse_0 _S1213 = joint_evaluate_0(&kernelContext_91->materials_0->m_0[(uint4((kernelContext_91->bonds_0+i_22)->law_0.ids_0) ).x], &_S1211, &_S1212, _S1205, _S1206, dt_15, fracture_2);
    BondStatic_natural_0 device* _S1214 = kernelContext_91->bonds_0+i_22;
    BondDyn_natural_0 device* _S1215 = kernelContext_91->bond_dyn_0+i_22;
    float4 _S1216 = float4((*_S1215).force_lin_0) ;
    float4 _S1217 = float4((*_S1215).force_ang_0) ;
    float4 _S1218 = float4((*_S1215).sums_0) ;
    float4 _S1219 = float4((*_S1215).comps_0) ;
    uint4 _S1220 = uint4((*_S1215).events_0) ;
    thread BondDyn_0 bd_2;
    (&bd_2)->js_0 = (*_S1215).js_0;
    (&bd_2)->force_lin_0 = _S1216;
    (&bd_2)->force_ang_0 = _S1217;
    (&bd_2)->sums_0 = _S1218;
    (&bd_2)->comps_0 = _S1219;
    (&bd_2)->events_0 = _S1220;
    float3 ra_2 = (float4(_S1214->ra_0) ).xyz;
    float3 rb_2 = (float4(_S1214->rb_0) ).xyz;
    thread JointBond_natural_0 _S1221 = _S1214->law_0;
    thread JointState_0 _S1222 = _S1213.state_8;
    thread float3 f_lin_2;
    thread float3 f_ang_2;
    secant_factors_0(&_S1221, &_S1222, _S1205, &f_lin_2, &f_ang_2);
    float3 qd_lin_0 = _S1207 * (float4(_S1214->c_lin_0) ).xyz * f_lin_2;
    float3 qd_ang_0 = _S1208 * (float4(_S1214->c_ang_0) ).xyz * f_ang_2;
    float3 q_lin_2 = _S1213.force_lin_1 + qd_lin_0;
    float3 q_ang_2 = _S1213.force_ang_1 + qd_ang_0;
    float damped_0 = (dot(qd_lin_0, _S1207) + dot(qd_ang_0, _S1208)) * dt_15;
    float3 _S1223 = to_body_0(i_22, q_lin_2, kernelContext_91);
    float3 _S1224 = to_body_0(i_22, q_ang_2, kernelContext_91);
    uint _S1225 = 3U * i_22;
    *(kernelContext_91->scratch_0+_S1225) = packed_float4(float4(_S1223, max(_S1213.measures_0.tension_0, _S1213.measures_0.compression_0))) ;
    *(kernelContext_91->scratch_0+(_S1225 + 1U)) = packed_float4(float4(_S1224 + cross(ra_2, _S1223), 0.0f)) ;
    *(kernelContext_91->scratch_0+(_S1225 + 2U)) = packed_float4(float4(- _S1224 + cross(rb_2, - _S1223), 0.0f)) ;
    thread float _S1226 = (&bd_2)->sums_0.x;
    thread float _S1227 = (&bd_2)->comps_0.x;
    comp_add1_0(&_S1226, &_S1227, _S1213.dissipated_2);
    (&bd_2)->comps_0.x = _S1227;
    (&bd_2)->sums_0.x = _S1226;
    thread float _S1228 = (&bd_2)->sums_0.y;
    thread float _S1229 = (&bd_2)->comps_0.y;
    comp_add1_0(&_S1228, &_S1229, _S1213.overshoot_0);
    (&bd_2)->comps_0.y = _S1229;
    (&bd_2)->sums_0.y = _S1228;
    thread float _S1230 = (&bd_2)->sums_0.z;
    thread float _S1231 = (&bd_2)->comps_0.z;
    comp_add1_0(&_S1230, &_S1231, damped_0);
    (&bd_2)->comps_0.z = _S1231;
    (&bd_2)->sums_0.z = _S1230;
    (&bd_2)->force_lin_0 = float4(q_lin_2, _S1213.stored_3);
    (&bd_2)->force_ang_0 = float4(q_ang_2, max((&bd_2)->force_ang_0.w, _S1213.state_8.utilization_0));
    bool _S1232;
    if(!_S1210)
    {
        thread JointState_0 _S1233 = _S1213.state_8;
        bool _S1234 = is_damaged_0(&_S1233);
        _S1232 = _S1234;
    }
    else
    {
        _S1232 = false;
    }
    if(_S1232)
    {
        _S1232 = ((&bd_2)->events_0.x) == 0U;
    }
    else
    {
        _S1232 = false;
    }
    if(_S1232)
    {
        (&bd_2)->events_0.x = abs_step_0;
        (&bd_2)->events_0.w = _S1213.state_8.mode_0;
        if(wide_0)
        {
            cov_or_0((uint4((&_S1221)->ids_0) ).w, 32U, kernelContext_91);
        }
        else
        {
            (*kernelContext_91->g_seen_0)[3U] = 1U;
        }
    }
    if(((&bd_2)->events_0.y) == 0U)
    {
        _S1232 = (_S1213.state_8.life_0) != (previous_3.life_0);
    }
    else
    {
        _S1232 = false;
    }
    if(_S1232)
    {
        _S1232 = (_S1213.fatigue_before_0) > 0.99000000953674316f;
    }
    else
    {
        _S1232 = false;
    }
    if(_S1232)
    {
        float _S1235 = fatigue_factor_0(&kernelContext_91->materials_0->m_0[(uint4((kernelContext_91->bonds_0+i_22)->law_0.ids_0) ).x], _S1213.state_8.life_0);
        _S1232 = _S1235 <= 0.99000000953674316f;
    }
    else
    {
        _S1232 = false;
    }
    if(_S1232)
    {
        (&bd_2)->events_0.y = abs_step_0;
        if(wide_0)
        {
            cov_or_0((uint4((&_S1221)->ids_0) ).w, 64U, kernelContext_91);
        }
        else
        {
            (*kernelContext_91->g_seen_0)[4U] = 1U;
        }
    }
    if(_S1213.disconnected_0)
    {
        (&bd_2)->events_0.z = abs_step_0;
    }
    (&bd_2)->js_0 = _S1213.state_8;
    BondDyn_natural_0 device* _S1236 = kernelContext_91->bond_dyn_0+i_22;
    _S1236->js_0 = bd_2.js_0;
    _S1236->force_lin_0 = packed_float4(bd_2.force_lin_0) ;
    _S1236->force_ang_0 = packed_float4(bd_2.force_ang_0) ;
    _S1236->sums_0 = packed_float4(bd_2.sums_0) ;
    _S1236->comps_0 = packed_float4(bd_2.comps_0) ;
    _S1236->events_0 = packed_uint4(bd_2.events_0) ;
    return _S1213.disconnected_0;
}

void chunk_update_0(uint c_42, const Island_natural_0 thread* isl_26, const Rigid_0 thread* rg_14, float dt_16, bool rml_0, uint step_0, bool contact_6, float thread* work_2, float thread* work_err_0, KernelContext_0 thread* kernelContext_92)
{
    float3 _S1237 = float3(0.0f) ;
    uint _S1238 = kernelContext_92->index_0[c_42];
    float peak_0 = 0.0f;
    uint e_7 = _S1238;
    float3 fi_5 = _S1237;
    float3 mi_4 = _S1237;
    for(;;)
    {
        if(e_7 < (kernelContext_92->index_0)[c_42 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_6 = kernelContext_92->index_0[e_7];
        uint _S1239 = 3U * (entry_6 >> 1U);
        float4 _S1240 = float4(*(kernelContext_92->scratch_0+_S1239)) ;
        if((entry_6 & 1U) == 0U)
        {
            float3 mi_5 = mi_4 + (float4(*(kernelContext_92->scratch_0+(_S1239 + 1U))) ).xyz;
            fi_5 = fi_5 + _S1240.xyz;
            mi_4 = mi_5;
        }
        else
        {
            float3 mi_6 = mi_4 + (float4(*(kernelContext_92->scratch_0+(_S1239 + 2U))) ).xyz;
            fi_5 = fi_5 + - _S1240.xyz;
            mi_4 = mi_6;
        }
        float _S1241 = max(peak_0, _S1240.w);
        uint _S1242 = e_7 + 1U;
        peak_0 = _S1241;
        e_7 = _S1242;
    }
    uint _S1243 = 4U * c_42;
    float3 u_2 = (float4(*(kernelContext_92->state_0+_S1243)) ).xyz;
    uint _S1244 = _S1243 + 1U;
    float3 th_4 = (float4(*(kernelContext_92->state_0+_S1244)) ).xyz;
    uint _S1245 = _S1243 + 2U;
    float3 v_11 = (float4(*(kernelContext_92->state_0+_S1245)) ).xyz;
    uint _S1246 = _S1243 + 3U;
    float3 w_6 = (float4(*(kernelContext_92->state_0+_S1246)) ).xyz;
    float mass_0 = (float4((kernelContext_92->chunks_0+c_42)->center_0) ).w;
    float3 _S1247 = (float4(isl_26->com_0) ).xyz;
    float3 _S1248 = rotate_0(&rg_14->rot_3, (float4((kernelContext_92->chunks_0+c_42)->center_0) ).xyz + u_2 - _S1247);
    thread float3 f_load_0;
    thread float3 t_load_0;
    thread float3 rep_f_2;
    thread float3 rep_m_2;
    chunk_loads_0(c_42, &rg_14->rot_3, step_0, dt_16, contact_6, dt_16, &f_load_0, &t_load_0, &rep_f_2, &rep_m_2, kernelContext_92);
    record_chunk_load_0(c_42, f_load_0, t_load_0, kernelContext_92);
    float3 _S1249 = float3(mass_0) ;
    float3 f_world_0 = f_load_0 + kernelContext_92->params_0->gravity_0.xyz * _S1249;
    float3 t_world_0 = t_load_0;
    float3 f_world_1;
    float3 t_world_1;
    if(rml_0)
    {
        float3 f_world_2 = f_world_0 - (rg_14->a_9 + cross(rg_14->alpha_0, _S1248) + cross(rg_14->w_5, cross(rg_14->w_5, _S1248))) * _S1249;
        float3 _S1250 = world_mul_0(&rg_14->rot_3, float4((kernelContext_92->chunks_0+c_42)->inertia0_1) , float4((kernelContext_92->chunks_0+c_42)->inertia1_1) , float4((kernelContext_92->chunks_0+c_42)->inertia2_1) , rg_14->alpha_0);
        float3 _S1251 = world_mul_0(&rg_14->rot_3, float4((kernelContext_92->chunks_0+c_42)->inertia0_1) , float4((kernelContext_92->chunks_0+c_42)->inertia1_1) , float4((kernelContext_92->chunks_0+c_42)->inertia2_1) , rg_14->w_5);
        float3 t_world_2 = t_world_0 - (_S1250 + cross(rg_14->w_5, _S1251));
        f_world_1 = f_world_2;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    float3 _S1252 = inverse_rotate_0(&rg_14->rot_3, f_world_1);
    float3 _S1253 = inverse_rotate_0(&rg_14->rot_3, t_world_1);
    float3 f_ext_0;
    float3 m_ext_0;
    if(rml_0)
    {
        float3 _S1254 = inverse_rotate_0(&rg_14->rot_3, rg_14->w_5);
        float3 i_w_0 = rows_mul_0(float4((kernelContext_92->chunks_0+c_42)->inertia0_1) , float4((kernelContext_92->chunks_0+c_42)->inertia1_1) , float4((kernelContext_92->chunks_0+c_42)->inertia2_1) , w_6);
        float3 m_ext_1 = _S1253 - (cross(_S1254, i_w_0) + cross(w_6, rows_mul_0(float4((kernelContext_92->chunks_0+c_42)->inertia0_1) , float4((kernelContext_92->chunks_0+c_42)->inertia1_1) , float4((kernelContext_92->chunks_0+c_42)->inertia2_1) , _S1254)) + cross(w_6, i_w_0));
        f_ext_0 = _S1252 - cross(_S1254, v_11) * float3((2.0f * mass_0)) ;
        m_ext_0 = m_ext_1;
    }
    else
    {
        f_ext_0 = _S1252;
        m_ext_0 = _S1253;
    }
    float3 f_18 = f_ext_0 + rep_f_2 + fi_5;
    float3 m_7 = m_ext_0 + rep_m_2 + mi_4;
    uint support_1 = (uint4((kernelContext_92->chunks_0+c_42)->info_1) ).x;
    float3 _S1255 = float3((float4(*(kernelContext_92->state_0+_S1244)) ).w, (float4(*(kernelContext_92->state_0+_S1245)) ).w, (float4(*(kernelContext_92->state_0+_S1246)) ).w);
    float3 reaction_1;
    float3 u_3;
    float3 th_5;
    float3 v_12;
    float3 w_7;
    if(support_1 == 1U)
    {
        reaction_1 = - f_18;
        u_3 = u_2;
        th_5 = th_4;
        v_12 = _S1237;
        w_7 = _S1237;
    }
    else
    {
        float3 w_8 = w_6 + rows_mul_0(float4((kernelContext_92->chunks_0+c_42)->inv0_1) , float4((kernelContext_92->chunks_0+c_42)->inv1_1) , float4((kernelContext_92->chunks_0+c_42)->inv2_1) , m_7) * float3((dt_16 * (float4((kernelContext_92->chunks_0+c_42)->scale_0) ).z)) ;
        float3 _S1256 = float3(dt_16) ;
        float3 th_6 = th_4 + w_8 * _S1256;
        if(support_1 == 2U)
        {
            reaction_1 = - f_18;
            u_3 = u_2;
            th_5 = _S1237;
        }
        else
        {
            float3 v_13 = v_11 + f_18 * float3((dt_16 * (float4((kernelContext_92->chunks_0+c_42)->scale_0) ).y)) ;
            float3 u_4 = u_2 + v_13 * _S1256;
            reaction_1 = _S1255;
            u_3 = u_4;
            th_5 = v_13;
        }
        float3 _S1257 = th_5;
        th_5 = th_6;
        v_12 = _S1257;
        w_7 = w_8;
    }
    *(kernelContext_92->state_0+_S1243) = packed_float4(float4(u_3, peak_0)) ;
    *(kernelContext_92->state_0+_S1244) = packed_float4(float4(th_5, reaction_1.x)) ;
    *(kernelContext_92->state_0+_S1245) = packed_float4(float4(v_12, reaction_1.y)) ;
    *(kernelContext_92->state_0+_S1246) = packed_float4(float4(w_7, reaction_1.z)) ;
    float3 _S1258 = rotate_0(&rg_14->rot_3, (float4((kernelContext_92->chunks_0+c_42)->center_0) ).xyz + u_3 - _S1247);
    float3 _S1259 = rg_14->vel_0 + rg_14->vel_err_0 + cross(rg_14->w_5, _S1258);
    float3 _S1260 = rotate_0(&rg_14->rot_3, v_12);
    float3 v_world_0 = _S1259 + _S1260;
    float3 _S1261 = rotate_0(&rg_14->rot_3, w_7);
    comp_add1_0(work_2, work_err_0, (dot(f_load_0, v_world_0) + dot(t_load_0, rg_14->w_5 + _S1261)) * dt_16);
    return;
}

void chunk_update_1(uint c_43, const Island_0 thread* isl_27, const Rigid_0 thread* rg_15, float dt_17, bool rml_1, uint step_1, bool contact_7, float thread* work_3, float thread* work_err_1, KernelContext_0 thread* kernelContext_93)
{
    float3 _S1262 = float3(0.0f) ;
    uint _S1263 = kernelContext_93->index_0[c_43];
    float peak_1 = 0.0f;
    uint e_8 = _S1263;
    float3 fi_6 = _S1262;
    float3 mi_7 = _S1262;
    for(;;)
    {
        if(e_8 < (kernelContext_93->index_0)[c_43 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_7 = kernelContext_93->index_0[e_8];
        uint _S1264 = 3U * (entry_7 >> 1U);
        float4 _S1265 = float4(*(kernelContext_93->scratch_0+_S1264)) ;
        if((entry_7 & 1U) == 0U)
        {
            float3 mi_8 = mi_7 + (float4(*(kernelContext_93->scratch_0+(_S1264 + 1U))) ).xyz;
            fi_6 = fi_6 + _S1265.xyz;
            mi_7 = mi_8;
        }
        else
        {
            float3 mi_9 = mi_7 + (float4(*(kernelContext_93->scratch_0+(_S1264 + 2U))) ).xyz;
            fi_6 = fi_6 + - _S1265.xyz;
            mi_7 = mi_9;
        }
        float _S1266 = max(peak_1, _S1265.w);
        uint _S1267 = e_8 + 1U;
        peak_1 = _S1266;
        e_8 = _S1267;
    }
    uint _S1268 = 4U * c_43;
    float3 u_5 = (float4(*(kernelContext_93->state_0+_S1268)) ).xyz;
    uint _S1269 = _S1268 + 1U;
    float3 th_7 = (float4(*(kernelContext_93->state_0+_S1269)) ).xyz;
    uint _S1270 = _S1268 + 2U;
    float3 v_14 = (float4(*(kernelContext_93->state_0+_S1270)) ).xyz;
    uint _S1271 = _S1268 + 3U;
    float3 w_9 = (float4(*(kernelContext_93->state_0+_S1271)) ).xyz;
    float mass_1 = (float4((kernelContext_93->chunks_0+c_43)->center_0) ).w;
    float3 _S1272 = isl_27->com_0.xyz;
    float3 _S1273 = rotate_0(&rg_15->rot_3, (float4((kernelContext_93->chunks_0+c_43)->center_0) ).xyz + u_5 - _S1272);
    thread float3 f_load_1;
    thread float3 t_load_1;
    thread float3 rep_f_3;
    thread float3 rep_m_3;
    chunk_loads_0(c_43, &rg_15->rot_3, step_1, dt_17, contact_7, dt_17, &f_load_1, &t_load_1, &rep_f_3, &rep_m_3, kernelContext_93);
    record_chunk_load_0(c_43, f_load_1, t_load_1, kernelContext_93);
    float3 _S1274 = float3(mass_1) ;
    float3 f_world_3 = f_load_1 + kernelContext_93->params_0->gravity_0.xyz * _S1274;
    float3 t_world_3 = t_load_1;
    float3 f_world_4;
    float3 t_world_4;
    if(rml_1)
    {
        float3 f_world_5 = f_world_3 - (rg_15->a_9 + cross(rg_15->alpha_0, _S1273) + cross(rg_15->w_5, cross(rg_15->w_5, _S1273))) * _S1274;
        float3 _S1275 = world_mul_0(&rg_15->rot_3, float4((kernelContext_93->chunks_0+c_43)->inertia0_1) , float4((kernelContext_93->chunks_0+c_43)->inertia1_1) , float4((kernelContext_93->chunks_0+c_43)->inertia2_1) , rg_15->alpha_0);
        float3 _S1276 = world_mul_0(&rg_15->rot_3, float4((kernelContext_93->chunks_0+c_43)->inertia0_1) , float4((kernelContext_93->chunks_0+c_43)->inertia1_1) , float4((kernelContext_93->chunks_0+c_43)->inertia2_1) , rg_15->w_5);
        float3 t_world_5 = t_world_3 - (_S1275 + cross(rg_15->w_5, _S1276));
        f_world_4 = f_world_5;
        t_world_4 = t_world_5;
    }
    else
    {
        f_world_4 = f_world_3;
        t_world_4 = t_world_3;
    }
    float3 _S1277 = inverse_rotate_0(&rg_15->rot_3, f_world_4);
    float3 _S1278 = inverse_rotate_0(&rg_15->rot_3, t_world_4);
    float3 f_ext_1;
    float3 m_ext_2;
    if(rml_1)
    {
        float3 _S1279 = inverse_rotate_0(&rg_15->rot_3, rg_15->w_5);
        float3 i_w_1 = rows_mul_0(float4((kernelContext_93->chunks_0+c_43)->inertia0_1) , float4((kernelContext_93->chunks_0+c_43)->inertia1_1) , float4((kernelContext_93->chunks_0+c_43)->inertia2_1) , w_9);
        float3 m_ext_3 = _S1278 - (cross(_S1279, i_w_1) + cross(w_9, rows_mul_0(float4((kernelContext_93->chunks_0+c_43)->inertia0_1) , float4((kernelContext_93->chunks_0+c_43)->inertia1_1) , float4((kernelContext_93->chunks_0+c_43)->inertia2_1) , _S1279)) + cross(w_9, i_w_1));
        f_ext_1 = _S1277 - cross(_S1279, v_14) * float3((2.0f * mass_1)) ;
        m_ext_2 = m_ext_3;
    }
    else
    {
        f_ext_1 = _S1277;
        m_ext_2 = _S1278;
    }
    float3 f_19 = f_ext_1 + rep_f_3 + fi_6;
    float3 m_8 = m_ext_2 + rep_m_3 + mi_7;
    uint support_2 = (uint4((kernelContext_93->chunks_0+c_43)->info_1) ).x;
    float3 _S1280 = float3((float4(*(kernelContext_93->state_0+_S1269)) ).w, (float4(*(kernelContext_93->state_0+_S1270)) ).w, (float4(*(kernelContext_93->state_0+_S1271)) ).w);
    float3 reaction_2;
    float3 u_6;
    float3 th_8;
    float3 v_15;
    float3 w_10;
    if(support_2 == 1U)
    {
        reaction_2 = - f_19;
        u_6 = u_5;
        th_8 = th_7;
        v_15 = _S1262;
        w_10 = _S1262;
    }
    else
    {
        float3 w_11 = w_9 + rows_mul_0(float4((kernelContext_93->chunks_0+c_43)->inv0_1) , float4((kernelContext_93->chunks_0+c_43)->inv1_1) , float4((kernelContext_93->chunks_0+c_43)->inv2_1) , m_8) * float3((dt_17 * (float4((kernelContext_93->chunks_0+c_43)->scale_0) ).z)) ;
        float3 _S1281 = float3(dt_17) ;
        float3 th_9 = th_7 + w_11 * _S1281;
        if(support_2 == 2U)
        {
            reaction_2 = - f_19;
            u_6 = u_5;
            th_8 = _S1262;
        }
        else
        {
            float3 v_16 = v_14 + f_19 * float3((dt_17 * (float4((kernelContext_93->chunks_0+c_43)->scale_0) ).y)) ;
            float3 u_7 = u_5 + v_16 * _S1281;
            reaction_2 = _S1280;
            u_6 = u_7;
            th_8 = v_16;
        }
        float3 _S1282 = th_8;
        th_8 = th_9;
        v_15 = _S1282;
        w_10 = w_11;
    }
    *(kernelContext_93->state_0+_S1268) = packed_float4(float4(u_6, peak_1)) ;
    *(kernelContext_93->state_0+_S1269) = packed_float4(float4(th_8, reaction_2.x)) ;
    *(kernelContext_93->state_0+_S1270) = packed_float4(float4(v_15, reaction_2.y)) ;
    *(kernelContext_93->state_0+_S1271) = packed_float4(float4(w_10, reaction_2.z)) ;
    float3 _S1283 = rotate_0(&rg_15->rot_3, (float4((kernelContext_93->chunks_0+c_43)->center_0) ).xyz + u_6 - _S1272);
    float3 _S1284 = rg_15->vel_0 + rg_15->vel_err_0 + cross(rg_15->w_5, _S1283);
    float3 _S1285 = rotate_0(&rg_15->rot_3, v_15);
    float3 v_world_1 = _S1284 + _S1285;
    float3 _S1286 = rotate_0(&rg_15->rot_3, w_10);
    comp_add1_0(work_3, work_err_1, (dot(f_load_1, v_world_1) + dot(t_load_1, rg_15->w_5 + _S1286)) * dt_17);
    return;
}

void drift_moments_0(uint c_44, float3 thread* tu_2, float3 thread* pv_2, KernelContext_0 thread* kernelContext_94)
{
    uint _S1287 = 4U * c_44;
    float3 _S1288 = float3(((float4((kernelContext_94->chunks_0+c_44)->center_0) ).w * (float4((kernelContext_94->chunks_0+c_44)->scale_0) ).x)) ;
    *tu_2 = *tu_2 + (float4(*(kernelContext_94->state_0+_S1287)) ).xyz * _S1288;
    *pv_2 = *pv_2 + (float4(*(kernelContext_94->state_0+(_S1287 + 2U))) ).xyz * _S1288;
    return;
}

bool island_connected_narrow_0(uint tid_19, const Island_0 thread* isl_28, KernelContext_0 thread* kernelContext_95)
{
    uint _S1289 = isl_28->range_0.x;
    uint n_12 = isl_28->range_0.y - _S1289;
    bool converged_3;
    if(n_12 > 512U)
    {
        converged_3 = true;
    }
    else
    {
        converged_3 = (kernelContext_95->params_0->device_connect_0) == 0U;
    }
    if(converged_3)
    {
        return false;
    }
    uint c_45 = tid_19;
    for(;;)
    {
        if(c_45 < n_12)
        {
        }
        else
        {
            break;
        }
        (*kernelContext_95->g_label_narrow_0)[c_45] = c_45;
        c_45 = c_45 + 256U;
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
            *kernelContext_95->g_changed_narrow_0 = 0U;
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);
        c_45 = tid_19;
        for(;;)
        {
            if(c_45 < n_12)
            {
            }
            else
            {
                break;
            }
            uint gc_1 = _S1289 + c_45;
            uint _S1290 = kernelContext_95->index_0[gc_1];
            uint l_8 = (*kernelContext_95->g_label_narrow_0)[c_45];
            uint e_9 = _S1290;
            for(;;)
            {
                if(e_9 < (kernelContext_95->index_0)[gc_1 + 1U])
                {
                }
                else
                {
                    break;
                }
                uint entry_8 = kernelContext_95->index_0[e_9];
                uint bond_2 = entry_8 >> 1U;
                bool _S1291 = ((float4((kernelContext_95->bonds_0+bond_2)->law_0.stiff1_0) ).w) != 0.0f;
                thread JointState_0 _S1292 = (kernelContext_95->bond_dyn_0+bond_2)->js_0;
                bool _S1293 = connected_0(&_S1292, _S1291);
                if(!_S1293)
                {
                    e_9 = e_9 + 1U;
                    continue;
                }
                uint other_1;
                if((entry_8 & 1U) == 0U)
                {
                    other_1 = (uint4((kernelContext_95->bonds_0+bond_2)->law_0.ids_0) ).z;
                }
                else
                {
                    other_1 = (uint4((kernelContext_95->bonds_0+bond_2)->law_0.ids_0) ).y;
                }
                l_8 = min(l_8, (*kernelContext_95->g_label_narrow_0)[other_1 - _S1289]);
                e_9 = e_9 + 1U;
            }
            uint _S1294 = min(l_8, (*kernelContext_95->g_label_narrow_0)[l_8]);
            if(_S1294 < (*kernelContext_95->g_label_narrow_0)[c_45])
            {
                (*kernelContext_95->g_label_narrow_0)[c_45] = _S1294;
                *kernelContext_95->g_changed_narrow_0 = 1U;
            }
            c_45 = c_45 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);
        bool converged_4 = (*kernelContext_95->g_changed_narrow_0) == 0U;
        threadgroup_barrier(mem_flags::mem_threadgroup);
        if(converged_4)
        {
            converged_3 = converged_4;
            break;
        }
        uint _S1295 = pass_1 + 1U;
        converged_3 = converged_4;
        pass_1 = _S1295;
    }
    if(!converged_3)
    {
        return false;
    }
    if(tid_19 == 0U)
    {
        *kernelContext_95->g_changed_narrow_0 = 0U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    c_45 = tid_19;
    for(;;)
    {
        if(c_45 < n_12)
        {
        }
        else
        {
            break;
        }
        if(((*kernelContext_95->g_label_narrow_0)[c_45]) != 0U)
        {
            *kernelContext_95->g_changed_narrow_0 = 1U;
        }
        c_45 = c_45 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    return (*kernelContext_95->g_changed_narrow_0) == 0U;
}

void island_frame_at_0(uint gi_0, uint tid_20, KernelContext_0 thread* kernelContext_96)
{
    bool woke_0;
    Island_natural_0 device* _S1296 = kernelContext_96->islands_0+gi_0;
    uint4 _S1297 = uint4((*_S1296).info_0) ;
    float4 _S1298 = float4((*_S1296).com_0) ;
    float4 _S1299 = float4((*_S1296).inertia0_0) ;
    float4 _S1300 = float4((*_S1296).inertia1_0) ;
    float4 _S1301 = float4((*_S1296).inertia2_0) ;
    float4 _S1302 = float4((*_S1296).inv0_0) ;
    float4 _S1303 = float4((*_S1296).inv1_0) ;
    float4 _S1304 = float4((*_S1296).inv2_0) ;
    float4 _S1305 = float4((*_S1296).wcom_0) ;
    float4 _S1306 = float4((*_S1296).winv0_0) ;
    float4 _S1307 = float4((*_S1296).winv1_0) ;
    float4 _S1308 = float4((*_S1296).winv2_0) ;
    float4 _S1309 = float4((*_S1296).rotation_0) ;
    float4 _S1310 = float4((*_S1296).position_0) ;
    float4 _S1311 = float4((*_S1296).position_err_0) ;
    float4 _S1312 = float4((*_S1296).velocity_0) ;
    float4 _S1313 = float4((*_S1296).velocity_err_0) ;
    float4 _S1314 = float4((*_S1296).angular_velocity_0) ;
    uint4 _S1315 = uint4((*_S1296).probes_0) ;
    float4 _S1316 = float4((*_S1296).energy_0) ;
    float4 _S1317 = float4((*_S1296).rotation_err_0) ;
    float4 _S1318 = float4((*_S1296).momentum_0) ;
    float4 _S1319 = float4((*_S1296).momentum_err_0) ;
    thread Island_0 isl_29;
    (&isl_29)->range_0 = uint4((*_S1296).range_0) ;
    (&isl_29)->info_0 = _S1297;
    (&isl_29)->com_0 = _S1298;
    (&isl_29)->inertia0_0 = _S1299;
    (&isl_29)->inertia1_0 = _S1300;
    (&isl_29)->inertia2_0 = _S1301;
    (&isl_29)->inv0_0 = _S1302;
    (&isl_29)->inv1_0 = _S1303;
    (&isl_29)->inv2_0 = _S1304;
    (&isl_29)->wcom_0 = _S1305;
    (&isl_29)->winv0_0 = _S1306;
    (&isl_29)->winv1_0 = _S1307;
    (&isl_29)->winv2_0 = _S1308;
    (&isl_29)->rotation_0 = _S1309;
    (&isl_29)->position_0 = _S1310;
    (&isl_29)->position_err_0 = _S1311;
    (&isl_29)->velocity_0 = _S1312;
    (&isl_29)->velocity_err_0 = _S1313;
    (&isl_29)->angular_velocity_0 = _S1314;
    (&isl_29)->done_0 = (*_S1296).done_0;
    (&isl_29)->coverage_0 = (*_S1296).coverage_0;
    (&isl_29)->wide_groups_0 = (*_S1296).wide_groups_0;
    (&isl_29)->done_pad_0 = (*_S1296).done_pad_0;
    (&isl_29)->probes_0 = _S1315;
    (&isl_29)->energy_0 = _S1316;
    (&isl_29)->rotation_err_0 = _S1317;
    (&isl_29)->momentum_0 = _S1318;
    (&isl_29)->momentum_err_0 = _S1319;
    bool driven_0 = (((&isl_29)->info_0.x) & 2U) != 0U;
    bool _S1320 = !((((&isl_29)->info_0.x) & 1U) != 0U);
    bool _S1321;
    if(_S1320)
    {
        _S1321 = !driven_0;
    }
    else
    {
        _S1321 = false;
    }
    bool contact_island_0 = (((&isl_29)->info_0.x) & 4U) != 0U;
    bool _S1322 = (((&isl_29)->info_0.x) & 16U) != 0U;
    seen_clear_0(tid_20, kernelContext_96);
    bool _S1323 = tid_20 == 0U;
    bool settled_0;
    uint cov_2;
    if(_S1323)
    {
        if(contact_island_0 != ((kernelContext_96->params_0->contact_mode_0) == 1U))
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
            thread Island_0 _S1324 = isl_29;
            bool _S1325 = contact_stopped_1(&_S1324, kernelContext_96);
            settled_0 = _S1325;
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
    if((((&isl_29)->info_0.z) & 1U) != 0U)
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
        cov_2 = min((&isl_29)->info_0.y, kernelContext_96->params_0->max_steps_0);
    }
    float _S1326 = kernelContext_96->params_0->dt_0;
    bool _S1327 = (kernelContext_96->params_0->fracture_0) != 0U;
    bool _S1328 = (kernelContext_96->params_0->rigid_motion_loads_0) != 0U;
    thread Island_0 _S1329 = isl_29;
    Rigid_0 _S1330 = rigid_of_1(&_S1329);
    thread Rigid_0 rg_16 = _S1330;
    thread float work_4 = 0.0f;
    thread float work_err_2 = 0.0f;
    settled_0 = _S1322;
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
        uint k_26 = abs_step_1 - 1U - kernelContext_96->params_0->step_start_0;
        bool quiet_0 = (((&isl_29)->info_0.x) & 32U) != 0U;
        bool _S1331;
        if(settled_0)
        {
            _S1331 = !quiet_0;
        }
        else
        {
            _S1331 = false;
        }
        bool _S1332;
        bool explicit_step_0;
        uint c_46;
        if(_S1331)
        {
            float3 _S1333 = float3(0.0f) ;
            thread float3 norm_1 = _S1333;
            thread float3 unused0_0 = _S1333;
            c_46 = (&isl_29)->range_0.x + tid_20;
            for(;;)
            {
                if(c_46 < ((&isl_29)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                thread Quat_0 _S1334 = (&rg_16)->rot_3;
                float _S1335 = settled_chunk_load_0(c_46, &_S1334, k_26, _S1326, contact_island_0, kernelContext_96);
                norm_1.x = norm_1.x + _S1335;
                c_46 = c_46 + 256U;
            }
            group_sum3_0(tid_20, &norm_1, &unused0_0, kernelContext_96);
            if((kernelContext_96->params_0->solve_mode_0) == 1U)
            {
                _S1332 = (abs(norm_1.x - (&isl_29)->energy_0.z)) > ((&isl_29)->energy_0.w);
            }
            else
            {
                _S1332 = false;
            }
            if(_S1332)
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
        if(_S1320)
        {
            _S1332 = !quiet_0;
        }
        else
        {
            _S1332 = false;
        }
        if(_S1332)
        {
            float3 _S1336 = float3(0.0f) ;
            thread float3 f_20 = _S1336;
            thread float3 t_21 = _S1336;
            c_46 = (&isl_29)->range_0.x + tid_20;
            for(;;)
            {
                if(c_46 < ((&isl_29)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                thread Island_0 _S1337 = isl_29;
                thread Rigid_0 _S1338 = rg_16;
                net_load_1(c_46, &_S1337, &_S1338, k_26, _S1326, contact_island_0, &f_20, &t_21, kernelContext_96);
                c_46 = c_46 + 256U;
            }
            group_sum3_0(tid_20, &f_20, &t_21, kernelContext_96);
            thread Island_0 _S1339 = isl_29;
            rigid_acceleration_1(&_S1339, &rg_16, f_20, t_21);
        }
        if(!settled_0)
        {
            explicit_step_0 = !quiet_0;
        }
        else
        {
            explicit_step_0 = false;
        }
        uint c_47;
        if(explicit_step_0)
        {
            c_46 = (&isl_29)->range_0.z + tid_20;
            for(;;)
            {
                if(c_46 < ((&isl_29)->range_0.w))
                {
                }
                else
                {
                    break;
                }
                bool _S1340 = bond_update_0(c_46, _S1326, _S1327, abs_step_1, false, kernelContext_96);
                if(_S1340)
                {
                    *kernelContext_96->g_halt_0 = 1U;
                }
                c_46 = c_46 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            c_47 = (&isl_29)->range_0.x + tid_20;
            for(;;)
            {
                if(c_47 < ((&isl_29)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                thread Island_0 _S1341 = isl_29;
                thread Rigid_0 _S1342 = rg_16;
                chunk_update_1(c_47, &_S1341, &_S1342, _S1326, _S1328, k_26, contact_island_0, &work_4, &work_err_2, kernelContext_96);
                c_47 = c_47 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        }
        bool _S1343;
        if(_S1321)
        {
            _S1343 = !quiet_0;
        }
        else
        {
            _S1343 = false;
        }
        if(_S1343)
        {
            thread Island_0 _S1344 = isl_29;
            integrate_rigid_1(&_S1344, &rg_16, _S1326);
        }
        bool _S1345;
        if(_S1320)
        {
            _S1345 = explicit_step_0;
        }
        else
        {
            _S1345 = false;
        }
        if(_S1345)
        {
            float3 _S1346 = (&isl_29)->wcom_0.xyz;
            float3 _S1347 = float3(0.0f) ;
            thread float3 tu_3 = _S1347;
            thread float3 pv_3 = _S1347;
            c_46 = (&isl_29)->range_0.x + tid_20;
            for(;;)
            {
                if(c_46 < ((&isl_29)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_moments_0(c_46, &tu_3, &pv_3, kernelContext_96);
                c_46 = c_46 + 256U;
            }
            group_sum3_0(tid_20, &tu_3, &pv_3, kernelContext_96);
            float3 tr_6 = tu_3 / float3((&isl_29)->wcom_0.w) ;
            float3 dv_6 = pv_3 / float3((&isl_29)->wcom_0.w) ;
            thread float3 lu_3 = _S1347;
            thread float3 lv_3 = _S1347;
            c_47 = (&isl_29)->range_0.x + tid_20;
            for(;;)
            {
                if(c_47 < ((&isl_29)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_angular_0(c_47, _S1346, tr_6, dv_6, &lu_3, &lv_3, kernelContext_96);
                c_47 = c_47 + 256U;
            }
            group_sum3_0(tid_20, &lu_3, &lv_3, kernelContext_96);
            float3 phi_5 = rows_mul_0((&isl_29)->winv0_0, (&isl_29)->winv1_0, (&isl_29)->winv2_0, lu_3);
            float3 dw_4 = rows_mul_0((&isl_29)->winv0_0, (&isl_29)->winv1_0, (&isl_29)->winv2_0, lv_3);
            uint c_48 = (&isl_29)->range_0.x + tid_20;
            for(;;)
            {
                if(c_48 < ((&isl_29)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_apply_0(c_48, _S1346, tr_6, phi_5, dv_6, dw_4, kernelContext_96);
                c_48 = c_48 + 256U;
            }
            if(!driven_0)
            {
                thread Island_0 _S1348 = isl_29;
                drift_rigid_1(&_S1348, &rg_16, tr_6, phi_5, dv_6, dw_4);
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        }
        bool _S1349;
        if(_S1323)
        {
            _S1349 = ((&isl_29)->probes_0.y) > ((&isl_29)->probes_0.x);
        }
        else
        {
            _S1349 = false;
        }
        if(_S1349)
        {
            thread Island_0 _S1350 = isl_29;
            thread Rigid_0 _S1351 = rg_16;
            record_probes_0(&_S1350, &_S1351, k_26, kernelContext_96);
        }
        uint _S1352 = done_1 + 1U;
        bool _S1353;
        if((*kernelContext_96->g_halt_0) != 0U)
        {
            thread Island_0 _S1354 = isl_29;
            bool _S1355 = island_connected_narrow_0(tid_20, &_S1354, kernelContext_96);
            _S1353 = _S1355;
        }
        else
        {
            _S1353 = false;
        }
        bool resumed_1;
        if(_S1353)
        {
            if(_S1323)
            {
                *kernelContext_96->g_halt_0 = 0U;
            }
            threadgroup_barrier(mem_flags::mem_threadgroup);
            resumed_1 = true;
        }
        else
        {
            resumed_1 = resumed_0;
        }
        if((*kernelContext_96->g_halt_0) != 0U)
        {
            done_1 = _S1352;
            resumed_0 = resumed_1;
            break;
        }
        done_1 = _S1352;
        woke_1 = woke_0;
        resumed_0 = resumed_1;
    }
    thread float3 wsum_0 = float3(work_4, work_err_2, 0.0f);
    thread float3 unused_3 = float3(0.0f) ;
    group_sum3_0(tid_20, &wsum_0, &unused_3, kernelContext_96);
    if(_S1323)
    {
        thread Quat_0 _S1356 = (&rg_16)->rot_3;
        float4 _S1357 = quat_vec_0(&_S1356);
        (&isl_29)->rotation_0 = _S1357;
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
        if((*kernelContext_96->g_halt_0) != 0U)
        {
            _S1321 = contact_island_0;
        }
        else
        {
            _S1321 = false;
        }
        if(_S1321)
        {
            contact_split_at_0((&isl_29)->info_0.w + done_1, kernelContext_96);
        }
        float _S1358 = wsum_0.x;
        thread float _S1359 = (&isl_29)->energy_0.x;
        thread float _S1360 = (&isl_29)->energy_0.y;
        comp_add1_0(&_S1359, &_S1360, _S1358);
        (&isl_29)->energy_0.x = _S1359;
        (&isl_29)->energy_0.y = _S1360 + wsum_0.y;
        (&isl_29)->info_0.w = (&isl_29)->info_0.w + done_1;
        if((*kernelContext_96->g_halt_0) != 0U)
        {
            (&isl_29)->info_0.z = ((&isl_29)->info_0.z) | 1U;
        }
        uint _S1361 = seen_bits_0(kernelContext_96);
        if((*kernelContext_96->g_halt_0) != 0U)
        {
            cov_2 = 128U;
        }
        else
        {
            cov_2 = 0U;
        }
        uint _S1362 = _S1361 | cov_2;
        if(woke_0)
        {
            cov_2 = 2048U;
        }
        else
        {
            cov_2 = 0U;
        }
        uint _S1363 = _S1362 | cov_2;
        if(resumed_0)
        {
            cov_2 = 2097280U;
        }
        else
        {
            cov_2 = 0U;
        }
        uint cov_3 = _S1363 | cov_2;
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
                _S1321 = !quiet_1;
            }
            else
            {
                _S1321 = false;
            }
            if(_S1321)
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
        Island_natural_0 device* _S1364 = kernelContext_96->islands_0+gi_0;
        _S1364->range_0 = packed_uint4(isl_29.range_0) ;
        _S1364->info_0 = packed_uint4(isl_29.info_0) ;
        _S1364->com_0 = packed_float4(isl_29.com_0) ;
        _S1364->inertia0_0 = packed_float4(isl_29.inertia0_0) ;
        _S1364->inertia1_0 = packed_float4(isl_29.inertia1_0) ;
        _S1364->inertia2_0 = packed_float4(isl_29.inertia2_0) ;
        _S1364->inv0_0 = packed_float4(isl_29.inv0_0) ;
        _S1364->inv1_0 = packed_float4(isl_29.inv1_0) ;
        _S1364->inv2_0 = packed_float4(isl_29.inv2_0) ;
        _S1364->wcom_0 = packed_float4(isl_29.wcom_0) ;
        _S1364->winv0_0 = packed_float4(isl_29.winv0_0) ;
        _S1364->winv1_0 = packed_float4(isl_29.winv1_0) ;
        _S1364->winv2_0 = packed_float4(isl_29.winv2_0) ;
        _S1364->rotation_0 = packed_float4(isl_29.rotation_0) ;
        _S1364->position_0 = packed_float4(isl_29.position_0) ;
        _S1364->position_err_0 = packed_float4(isl_29.position_err_0) ;
        _S1364->velocity_0 = packed_float4(isl_29.velocity_0) ;
        _S1364->velocity_err_0 = packed_float4(isl_29.velocity_err_0) ;
        _S1364->angular_velocity_0 = packed_float4(isl_29.angular_velocity_0) ;
        _S1364->done_0 = isl_29.done_0;
        _S1364->coverage_0 = isl_29.coverage_0;
        _S1364->wide_groups_0 = isl_29.wide_groups_0;
        _S1364->done_pad_0 = isl_29.done_pad_0;
        _S1364->probes_0 = packed_uint4(isl_29.probes_0) ;
        _S1364->energy_0 = packed_float4(isl_29.energy_0) ;
        _S1364->rotation_err_0 = packed_float4(isl_29.rotation_err_0) ;
        _S1364->momentum_0 = packed_float4(isl_29.momentum_0) ;
        _S1364->momentum_err_0 = packed_float4(isl_29.momentum_err_0) ;
    }
    return;
}

[[kernel]] void island_frame(uint3 group_8 [[threadgroup_position_in_grid]], uint3 thread_8 [[thread_position_in_threadgroup]], Params_0 constant* params_12 [[buffer(0)]], Island_natural_0 device* islands_12 [[buffer(9)]], uint device* index_12 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_12 [[buffer(3)]], packed_float4 device* state_14 [[buffer(6)]], packed_float4 device* scratch_12 [[buffer(8)]], packed_float4 device* contact_state_12 [[buffer(11)]], packed_float4 device* loads_12 [[buffer(5)]], Impactor_natural_0 device* impactors_12 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_12 [[buffer(7)]], BondStatic_natural_0 device* bonds_12 [[buffer(2)]], MaterialTable_0 constant* materials_12 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_97;
    (&kernelContext_97)->params_0 = params_12;
    (&kernelContext_97)->islands_0 = islands_12;
    (&kernelContext_97)->index_0 = index_12;
    (&kernelContext_97)->chunks_0 = chunks_12;
    (&kernelContext_97)->state_0 = state_14;
    (&kernelContext_97)->scratch_0 = scratch_12;
    (&kernelContext_97)->contact_state_0 = contact_state_12;
    (&kernelContext_97)->loads_0 = loads_12;
    (&kernelContext_97)->impactors_0 = impactors_12;
    (&kernelContext_97)->bond_dyn_0 = bond_dyn_12;
    (&kernelContext_97)->bonds_0 = bonds_12;
    (&kernelContext_97)->materials_0 = materials_12;
    threadgroup array<float4, int(32)> g_part_a_12;
    (&kernelContext_97)->g_part_a_0 = &g_part_a_12;
    threadgroup array<float4, int(32)> g_part_b_12;
    (&kernelContext_97)->g_part_b_0 = &g_part_b_12;
    threadgroup array<uint, int(5)> g_seen_12;
    (&kernelContext_97)->g_seen_0 = &g_seen_12;
    threadgroup uint g_wide_run_12;
    (&kernelContext_97)->g_wide_run_0 = &g_wide_run_12;
    threadgroup array<uint, int(4096)> g_label_12;
    (&kernelContext_97)->g_label_0 = &g_label_12;
    threadgroup uint g_changed_12;
    (&kernelContext_97)->g_changed_0 = &g_changed_12;
    threadgroup uint g_halt_12;
    (&kernelContext_97)->g_halt_0 = &g_halt_12;
    threadgroup uint g_run_12;
    (&kernelContext_97)->g_run_0 = &g_run_12;
    threadgroup array<uint, int(512)> g_label_narrow_12;
    (&kernelContext_97)->g_label_narrow_0 = &g_label_narrow_12;
    threadgroup uint g_changed_narrow_12;
    (&kernelContext_97)->g_changed_narrow_0 = &g_changed_narrow_12;
    island_frame_at_0(group_8.x, thread_8.x, &kernelContext_97);
    return;
}

void wide_chunks_at_0(uint gx_0, uint tid_21, KernelContext_0 thread* kernelContext_98)
{
    WideGroup_0 _S1365 = wide_group_0(kernelContext_98->params_0->wide_chunk_table_0, gx_0, kernelContext_98);
    thread Island_natural_0 _S1366 = *(kernelContext_98->islands_0+_S1365.island_3);
    bool _S1367 = wide_enter_1(tid_21, _S1365.island_3, kernelContext_98);
    if(!_S1367)
    {
        return;
    }
    uint _S1368 = (uint4((&_S1366)->info_0) ).x;
    bool anchored_0 = (_S1368 & 1U) != 0U;
    if((_S1368 & 16U) != 0U)
    {
        if(tid_21 == 0U)
        {
            *(kernelContext_98->scratch_0+(kernelContext_98->params_0->wide_base_0 + 8U * gx_0 + 6U)) = packed_float4(float4(0.0f) ) ;
        }
        return;
    }
    thread WideGroup_0 _S1369 = _S1365;
    Rigid_0 _S1370 = wide_rigid_frame_1(tid_21, &_S1366, &_S1369, kernelContext_98);
    thread float work_5 = 0.0f;
    thread float work_err_3 = 0.0f;
    float3 _S1371 = float3(0.0f) ;
    thread float3 tu_4 = _S1371;
    thread float3 pv_4 = _S1371;
    uint c_49 = _S1365.begin_0 + tid_21;
    if(c_49 < (_S1365.end_0))
    {
        float _S1372 = kernelContext_98->params_0->dt_0;
        bool _S1373 = (kernelContext_98->params_0->rigid_motion_loads_0) != 0U;
        uint _S1374 = wide_step_1(&_S1366, kernelContext_98);
        bool _S1375 = (_S1368 & 4U) != 0U;
        thread Rigid_0 _S1376 = _S1370;
        chunk_update_0(c_49, &_S1366, &_S1376, _S1372, _S1373, _S1374, _S1375, &work_5, &work_err_3, kernelContext_98);
        if(!anchored_0)
        {
            drift_moments_0(c_49, &tu_4, &pv_4, kernelContext_98);
        }
    }
    thread float3 wsum_1 = float3(work_5, work_err_3, 0.0f);
    thread float3 unused_4 = _S1371;
    group_sum3_0(tid_21, &wsum_1, &unused_4, kernelContext_98);
    bool _S1377 = !anchored_0;
    if(_S1377)
    {
        group_sum3_0(tid_21, &tu_4, &pv_4, kernelContext_98);
    }
    if(tid_21 == 0U)
    {
        uint _S1378 = 8U * gx_0;
        *(kernelContext_98->scratch_0+(kernelContext_98->params_0->wide_base_0 + _S1378 + 6U)) = packed_float4(float4(wsum_1, 0.0f)) ;
        if(_S1377)
        {
            wide_store_0(gx_0, 2U, tu_4, pv_4, kernelContext_98);
        }
        *(kernelContext_98->scratch_0+(kernelContext_98->params_0->wide_base_0 + _S1378 + 7U)) = packed_float4(float4(float((*kernelContext_98->g_seen_0)[0U]), float((*kernelContext_98->g_seen_0)[1U]), float((*kernelContext_98->g_seen_0)[2U]), 0.0f)) ;
    }
    return;
}

[[kernel]] void wide_chunks(uint3 group_9 [[threadgroup_position_in_grid]], uint3 thread_9 [[thread_position_in_threadgroup]], Params_0 constant* params_13 [[buffer(0)]], Island_natural_0 device* islands_13 [[buffer(9)]], uint device* index_13 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_13 [[buffer(3)]], packed_float4 device* state_15 [[buffer(6)]], packed_float4 device* scratch_13 [[buffer(8)]], packed_float4 device* contact_state_13 [[buffer(11)]], packed_float4 device* loads_13 [[buffer(5)]], Impactor_natural_0 device* impactors_13 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_13 [[buffer(7)]], BondStatic_natural_0 device* bonds_13 [[buffer(2)]], MaterialTable_0 constant* materials_13 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_99;
    (&kernelContext_99)->params_0 = params_13;
    (&kernelContext_99)->islands_0 = islands_13;
    (&kernelContext_99)->index_0 = index_13;
    (&kernelContext_99)->chunks_0 = chunks_13;
    (&kernelContext_99)->state_0 = state_15;
    (&kernelContext_99)->scratch_0 = scratch_13;
    (&kernelContext_99)->contact_state_0 = contact_state_13;
    (&kernelContext_99)->loads_0 = loads_13;
    (&kernelContext_99)->impactors_0 = impactors_13;
    (&kernelContext_99)->bond_dyn_0 = bond_dyn_13;
    (&kernelContext_99)->bonds_0 = bonds_13;
    (&kernelContext_99)->materials_0 = materials_13;
    threadgroup array<float4, int(32)> g_part_a_13;
    (&kernelContext_99)->g_part_a_0 = &g_part_a_13;
    threadgroup array<float4, int(32)> g_part_b_13;
    (&kernelContext_99)->g_part_b_0 = &g_part_b_13;
    threadgroup array<uint, int(5)> g_seen_13;
    (&kernelContext_99)->g_seen_0 = &g_seen_13;
    threadgroup uint g_wide_run_13;
    (&kernelContext_99)->g_wide_run_0 = &g_wide_run_13;
    threadgroup array<uint, int(4096)> g_label_13;
    (&kernelContext_99)->g_label_0 = &g_label_13;
    threadgroup uint g_changed_13;
    (&kernelContext_99)->g_changed_0 = &g_changed_13;
    threadgroup uint g_halt_13;
    (&kernelContext_99)->g_halt_0 = &g_halt_13;
    threadgroup uint g_run_13;
    (&kernelContext_99)->g_run_0 = &g_run_13;
    threadgroup array<uint, int(512)> g_label_narrow_13;
    (&kernelContext_99)->g_label_narrow_0 = &g_label_narrow_13;
    threadgroup uint g_changed_narrow_13;
    (&kernelContext_99)->g_changed_narrow_0 = &g_changed_narrow_13;
    wide_chunks_at_0(group_9.x, thread_9.x, &kernelContext_99);
    return;
}

[[kernel]] void sums_and_impactors(uint3 group_10 [[threadgroup_position_in_grid]], uint3 thread_10 [[thread_position_in_threadgroup]], Params_0 constant* params_14 [[buffer(0)]], Island_natural_0 device* islands_14 [[buffer(9)]], uint device* index_14 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_14 [[buffer(3)]], packed_float4 device* state_16 [[buffer(6)]], packed_float4 device* scratch_14 [[buffer(8)]], packed_float4 device* contact_state_14 [[buffer(11)]], packed_float4 device* loads_14 [[buffer(5)]], Impactor_natural_0 device* impactors_14 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_14 [[buffer(7)]], BondStatic_natural_0 device* bonds_14 [[buffer(2)]], MaterialTable_0 constant* materials_14 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_100;
    (&kernelContext_100)->params_0 = params_14;
    (&kernelContext_100)->islands_0 = islands_14;
    (&kernelContext_100)->index_0 = index_14;
    (&kernelContext_100)->chunks_0 = chunks_14;
    (&kernelContext_100)->state_0 = state_16;
    (&kernelContext_100)->scratch_0 = scratch_14;
    (&kernelContext_100)->contact_state_0 = contact_state_14;
    (&kernelContext_100)->loads_0 = loads_14;
    (&kernelContext_100)->impactors_0 = impactors_14;
    (&kernelContext_100)->bond_dyn_0 = bond_dyn_14;
    (&kernelContext_100)->bonds_0 = bonds_14;
    (&kernelContext_100)->materials_0 = materials_14;
    threadgroup array<float4, int(32)> g_part_a_14;
    (&kernelContext_100)->g_part_a_0 = &g_part_a_14;
    threadgroup array<float4, int(32)> g_part_b_14;
    (&kernelContext_100)->g_part_b_0 = &g_part_b_14;
    threadgroup array<uint, int(5)> g_seen_14;
    (&kernelContext_100)->g_seen_0 = &g_seen_14;
    threadgroup uint g_wide_run_14;
    (&kernelContext_100)->g_wide_run_0 = &g_wide_run_14;
    threadgroup array<uint, int(4096)> g_label_14;
    (&kernelContext_100)->g_label_0 = &g_label_14;
    threadgroup uint g_changed_14;
    (&kernelContext_100)->g_changed_0 = &g_changed_14;
    threadgroup uint g_halt_14;
    (&kernelContext_100)->g_halt_0 = &g_halt_14;
    threadgroup uint g_run_14;
    (&kernelContext_100)->g_run_0 = &g_run_14;
    threadgroup array<uint, int(512)> g_label_narrow_14;
    (&kernelContext_100)->g_label_narrow_0 = &g_label_narrow_14;
    threadgroup uint g_changed_narrow_14;
    (&kernelContext_100)->g_changed_narrow_0 = &g_changed_narrow_14;
    uint sums_groups_0 = (params_14->seg_count_0 + 255U) / 256U;
    uint _S1379 = group_10.x;
    if(_S1379 < sums_groups_0)
    {
        contact_sum_at_0(_S1379 * 256U + thread_10.x, &kernelContext_100);
    }
    else
    {
        impactor_integrate_at_0(_S1379 - sums_groups_0, thread_10.x, &kernelContext_100);
    }
    return;
}

[[kernel]] void islands_and_wide_chunks(uint3 group_11 [[threadgroup_position_in_grid]], uint3 thread_11 [[thread_position_in_threadgroup]], Params_0 constant* params_15 [[buffer(0)]], Island_natural_0 device* islands_15 [[buffer(9)]], uint device* index_15 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_15 [[buffer(3)]], packed_float4 device* state_17 [[buffer(6)]], packed_float4 device* scratch_15 [[buffer(8)]], packed_float4 device* contact_state_15 [[buffer(11)]], packed_float4 device* loads_15 [[buffer(5)]], Impactor_natural_0 device* impactors_15 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_15 [[buffer(7)]], BondStatic_natural_0 device* bonds_15 [[buffer(2)]], MaterialTable_0 constant* materials_15 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_101;
    (&kernelContext_101)->params_0 = params_15;
    (&kernelContext_101)->islands_0 = islands_15;
    (&kernelContext_101)->index_0 = index_15;
    (&kernelContext_101)->chunks_0 = chunks_15;
    (&kernelContext_101)->state_0 = state_17;
    (&kernelContext_101)->scratch_0 = scratch_15;
    (&kernelContext_101)->contact_state_0 = contact_state_15;
    (&kernelContext_101)->loads_0 = loads_15;
    (&kernelContext_101)->impactors_0 = impactors_15;
    (&kernelContext_101)->bond_dyn_0 = bond_dyn_15;
    (&kernelContext_101)->bonds_0 = bonds_15;
    (&kernelContext_101)->materials_0 = materials_15;
    threadgroup array<float4, int(32)> g_part_a_15;
    (&kernelContext_101)->g_part_a_0 = &g_part_a_15;
    threadgroup array<float4, int(32)> g_part_b_15;
    (&kernelContext_101)->g_part_b_0 = &g_part_b_15;
    threadgroup array<uint, int(5)> g_seen_15;
    (&kernelContext_101)->g_seen_0 = &g_seen_15;
    threadgroup uint g_wide_run_15;
    (&kernelContext_101)->g_wide_run_0 = &g_wide_run_15;
    threadgroup array<uint, int(4096)> g_label_15;
    (&kernelContext_101)->g_label_0 = &g_label_15;
    threadgroup uint g_changed_15;
    (&kernelContext_101)->g_changed_0 = &g_changed_15;
    threadgroup uint g_halt_15;
    (&kernelContext_101)->g_halt_0 = &g_halt_15;
    threadgroup uint g_run_15;
    (&kernelContext_101)->g_run_0 = &g_run_15;
    threadgroup array<uint, int(512)> g_label_narrow_15;
    (&kernelContext_101)->g_label_narrow_0 = &g_label_narrow_15;
    threadgroup uint g_changed_narrow_15;
    (&kernelContext_101)->g_changed_narrow_0 = &g_changed_narrow_15;
    uint _S1380 = group_11.x;
    if(_S1380 < (params_15->halt_index_0))
    {
        island_frame_at_0(_S1380, thread_11.x, &kernelContext_101);
    }
    else
    {
        wide_chunks_at_0(_S1380 - params_15->halt_index_0, thread_11.x, &kernelContext_101);
    }
    return;
}

void wide_bonds_at_0(uint gx_1, uint tid_22, KernelContext_0 thread* kernelContext_102)
{
    bool bond_group_0 = gx_1 < (kernelContext_102->params_0->wide_bond_groups_0);
    WideGroup_0 wg_2;
    if(bond_group_0)
    {
        WideGroup_0 _S1381 = wide_group_0(kernelContext_102->params_0->wide_bond_table_0, gx_1, kernelContext_102);
        wg_2 = _S1381;
    }
    else
    {
        WideGroup_0 _S1382 = wide_group_0(kernelContext_102->params_0->wide_chunk_table_0, gx_1 - kernelContext_102->params_0->wide_bond_groups_0, kernelContext_102);
        wg_2 = _S1382;
    }
    WideGroup_0 _S1383 = wg_2;
    thread Island_natural_0 _S1384 = *(kernelContext_102->islands_0+wg_2.island_3);
    bool _S1385 = wide_enter_1(tid_22, wg_2.island_3, kernelContext_102);
    if(!_S1385)
    {
        return;
    }
    uint _S1386 = wide_step_1(&_S1384, kernelContext_102);
    if(bond_group_0)
    {
        uint4 _S1387 = uint4((&_S1384)->info_0) ;
        if(((_S1387.x) & 16U) != 0U)
        {
            return;
        }
        uint i_23 = wg_2.begin_0 + tid_22;
        bool _S1388;
        if(i_23 < (wg_2.end_0))
        {
            bool _S1389 = bond_update_0(i_23, kernelContext_102->params_0->dt_0, (kernelContext_102->params_0->fracture_0) != 0U, _S1387.w + 1U, true, kernelContext_102);
            _S1388 = _S1389;
        }
        else
        {
            _S1388 = false;
        }
        if(_S1388)
        {
            (kernelContext_102->islands_0+_S1383.island_3)->info_0[int(2)] = (_S1387.z) | 2U;
        }
        return;
    }
    uint _S1390 = (uint4((&_S1384)->info_0) ).x;
    if((_S1390 & 1U) != 0U)
    {
        return;
    }
    float3 _S1391 = float3(0.0f) ;
    thread float3 f_21 = _S1391;
    thread float3 t_22 = _S1391;
    uint c_50 = wg_2.begin_0 + tid_22;
    if(c_50 < (wg_2.end_0))
    {
        Rigid_0 _S1392 = rigid_of_0(&_S1384);
        float _S1393 = kernelContext_102->params_0->dt_0;
        bool _S1394 = (_S1390 & 4U) != 0U;
        thread Rigid_0 _S1395 = _S1392;
        net_load_0(c_50, &_S1384, &_S1395, _S1386, _S1393, _S1394, &f_21, &t_22, kernelContext_102);
    }
    group_sum3_0(tid_22, &f_21, &t_22, kernelContext_102);
    if(tid_22 == 0U)
    {
        wide_store_0(gx_1 - kernelContext_102->params_0->wide_bond_groups_0, 0U, f_21, t_22, kernelContext_102);
    }
    return;
}

[[kernel]] void wide_bonds(uint3 group_12 [[threadgroup_position_in_grid]], uint3 thread_12 [[thread_position_in_threadgroup]], Params_0 constant* params_16 [[buffer(0)]], Island_natural_0 device* islands_16 [[buffer(9)]], uint device* index_16 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_16 [[buffer(3)]], packed_float4 device* state_18 [[buffer(6)]], packed_float4 device* scratch_16 [[buffer(8)]], packed_float4 device* contact_state_16 [[buffer(11)]], packed_float4 device* loads_16 [[buffer(5)]], Impactor_natural_0 device* impactors_16 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_16 [[buffer(7)]], BondStatic_natural_0 device* bonds_16 [[buffer(2)]], MaterialTable_0 constant* materials_16 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_103;
    (&kernelContext_103)->params_0 = params_16;
    (&kernelContext_103)->islands_0 = islands_16;
    (&kernelContext_103)->index_0 = index_16;
    (&kernelContext_103)->chunks_0 = chunks_16;
    (&kernelContext_103)->state_0 = state_18;
    (&kernelContext_103)->scratch_0 = scratch_16;
    (&kernelContext_103)->contact_state_0 = contact_state_16;
    (&kernelContext_103)->loads_0 = loads_16;
    (&kernelContext_103)->impactors_0 = impactors_16;
    (&kernelContext_103)->bond_dyn_0 = bond_dyn_16;
    (&kernelContext_103)->bonds_0 = bonds_16;
    (&kernelContext_103)->materials_0 = materials_16;
    threadgroup array<float4, int(32)> g_part_a_16;
    (&kernelContext_103)->g_part_a_0 = &g_part_a_16;
    threadgroup array<float4, int(32)> g_part_b_16;
    (&kernelContext_103)->g_part_b_0 = &g_part_b_16;
    threadgroup array<uint, int(5)> g_seen_16;
    (&kernelContext_103)->g_seen_0 = &g_seen_16;
    threadgroup uint g_wide_run_16;
    (&kernelContext_103)->g_wide_run_0 = &g_wide_run_16;
    threadgroup array<uint, int(4096)> g_label_16;
    (&kernelContext_103)->g_label_0 = &g_label_16;
    threadgroup uint g_changed_16;
    (&kernelContext_103)->g_changed_0 = &g_changed_16;
    threadgroup uint g_halt_16;
    (&kernelContext_103)->g_halt_0 = &g_halt_16;
    threadgroup uint g_run_16;
    (&kernelContext_103)->g_run_0 = &g_run_16;
    threadgroup array<uint, int(512)> g_label_narrow_16;
    (&kernelContext_103)->g_label_narrow_0 = &g_label_narrow_16;
    threadgroup uint g_changed_narrow_16;
    (&kernelContext_103)->g_changed_narrow_0 = &g_changed_narrow_16;
    wide_bonds_at_0(group_12.x, thread_12.x, &kernelContext_103);
    return;
}

[[kernel]] void sums_impactors_bonds(uint3 group_13 [[threadgroup_position_in_grid]], uint3 thread_13 [[thread_position_in_threadgroup]], Params_0 constant* params_17 [[buffer(0)]], Island_natural_0 device* islands_17 [[buffer(9)]], uint device* index_17 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_17 [[buffer(3)]], packed_float4 device* state_19 [[buffer(6)]], packed_float4 device* scratch_17 [[buffer(8)]], packed_float4 device* contact_state_17 [[buffer(11)]], packed_float4 device* loads_17 [[buffer(5)]], Impactor_natural_0 device* impactors_17 [[buffer(10)]], BondDyn_natural_0 device* bond_dyn_17 [[buffer(7)]], BondStatic_natural_0 device* bonds_17 [[buffer(2)]], MaterialTable_0 constant* materials_17 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_104;
    (&kernelContext_104)->params_0 = params_17;
    (&kernelContext_104)->islands_0 = islands_17;
    (&kernelContext_104)->index_0 = index_17;
    (&kernelContext_104)->chunks_0 = chunks_17;
    (&kernelContext_104)->state_0 = state_19;
    (&kernelContext_104)->scratch_0 = scratch_17;
    (&kernelContext_104)->contact_state_0 = contact_state_17;
    (&kernelContext_104)->loads_0 = loads_17;
    (&kernelContext_104)->impactors_0 = impactors_17;
    (&kernelContext_104)->bond_dyn_0 = bond_dyn_17;
    (&kernelContext_104)->bonds_0 = bonds_17;
    (&kernelContext_104)->materials_0 = materials_17;
    threadgroup array<float4, int(32)> g_part_a_17;
    (&kernelContext_104)->g_part_a_0 = &g_part_a_17;
    threadgroup array<float4, int(32)> g_part_b_17;
    (&kernelContext_104)->g_part_b_0 = &g_part_b_17;
    threadgroup array<uint, int(5)> g_seen_17;
    (&kernelContext_104)->g_seen_0 = &g_seen_17;
    threadgroup uint g_wide_run_17;
    (&kernelContext_104)->g_wide_run_0 = &g_wide_run_17;
    threadgroup array<uint, int(4096)> g_label_17;
    (&kernelContext_104)->g_label_0 = &g_label_17;
    threadgroup uint g_changed_17;
    (&kernelContext_104)->g_changed_0 = &g_changed_17;
    threadgroup uint g_halt_17;
    (&kernelContext_104)->g_halt_0 = &g_halt_17;
    threadgroup uint g_run_17;
    (&kernelContext_104)->g_run_0 = &g_run_17;
    threadgroup array<uint, int(512)> g_label_narrow_17;
    (&kernelContext_104)->g_label_narrow_0 = &g_label_narrow_17;
    threadgroup uint g_changed_narrow_17;
    (&kernelContext_104)->g_changed_narrow_0 = &g_changed_narrow_17;
    uint sums_groups_1 = (params_17->seg_count_0 + 255U) / 256U;
    uint _S1396 = max(params_17->impactor_count_0, 1U);
    uint _S1397 = group_13.x;
    if(_S1397 < sums_groups_1)
    {
        contact_sum_at_0(_S1397 * 256U + thread_13.x, &kernelContext_104);
    }
    else
    {
        if(_S1397 < (sums_groups_1 + _S1396))
        {
            impactor_integrate_at_0(_S1397 - sums_groups_1, thread_13.x, &kernelContext_104);
        }
        else
        {
            wide_bonds_at_0(_S1397 - sums_groups_1 - _S1396, thread_13.x, &kernelContext_104);
        }
    }
    return;
}

