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

bool stopped_0(KernelContext_0 thread* kernelContext_2)
{
    uint4 _S3 = uint4((kernelContext_2->islands_0+kernelContext_2->params_0->halt_index_0)->info_0) ;
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

struct Quat_0
{
    float w_1;
    float x_1;
    float y_1;
    float z_0;
};

Quat_0 quat_of_0(float4 q_0)
{
    thread Quat_0 r_0;
    (&r_0)->x_1 = q_0.x;
    (&r_0)->y_1 = q_0.y;
    (&r_0)->z_0 = q_0.z;
    (&r_0)->w_1 = q_0.w;
    return r_0;
}

float3 rotate_0(const Quat_0 thread* q_1, float3 v_0)
{
    float3 qv_0 = float3(q_1->x_1, q_1->y_1, q_1->z_0);
    float3 t_0 = cross(qv_0, v_0) * float3(2.0f) ;
    return v_0 + t_0 * float3(q_1->w_1)  + cross(qv_0, t_0);
}

float3 rotate_1(const Quat_0 thread* q_2, float3 v_1)
{
    float3 qv_1 = float3(q_2->x_1, q_2->y_1, q_2->z_0);
    float3 t_1 = cross(qv_1, v_1) * float3(2.0f) ;
    return v_1 + t_1 * float3(q_2->w_1)  + cross(qv_1, t_1);
}

struct WorldPoint_0
{
    float3 hi_0;
    float3 lo_0;
    float3 rel_0;
};

WorldPoint_0 chunk_world_0(uint c_0, KernelContext_0 thread* kernelContext_3)
{
    ChunkStatic_natural_0 device* _S5 = kernelContext_3->chunks_0+c_0;
    Island_natural_0 device* _S6 = kernelContext_3->islands_0+(uint4(_S5->info_1) ).y;
    Quat_0 q_3 = quat_of_0(float4(_S6->rotation_0) );
    thread WorldPoint_0 w_2;
    (&w_2)->hi_0 = (float4(_S6->position_0) ).xyz;
    (&w_2)->lo_0 = (float4(_S6->position_err_0) ).xyz;
    float3 _S7 = (float4(_S5->center_0) ).xyz + (float4(*(kernelContext_3->state_0+4U * c_0)) ).xyz;
    thread Quat_0 _S8 = q_3;
    float3 _S9 = rotate_0(&_S8, _S7);
    (&w_2)->rel_0 = _S9;
    return w_2;
}

float3 world_diff_0(const WorldPoint_0 thread* a_2, const WorldPoint_0 thread* b_2)
{
    return a_2->hi_0 - b_2->hi_0 + (a_2->lo_0 - b_2->lo_0) + (a_2->rel_0 - b_2->rel_0);
}

float3 safe_normalize_0(float3 v_2)
{
    float n_0 = length(v_2);
    float3 _S10;
    if(n_0 > 1.00000000317107685e-30f)
    {
        _S10 = v_2 / float3(n_0) ;
    }
    else
    {
        _S10 = float3(0.0f) ;
    }
    return _S10;
}

Quat_0 from_axis_angle_0(float3 axis_0, float angle_0)
{
    float3 a_3 = safe_normalize_0(axis_0);
    float _S11 = 0.5f * angle_0;
    float s_0 = sin(_S11);
    thread Quat_0 q_4;
    (&q_4)->w_1 = cos(_S11);
    (&q_4)->x_1 = a_3.x * s_0;
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

Box_0 chunk_box_0(uint c_1, float3 center_2, KernelContext_0 thread* kernelContext_4)
{
    ChunkStatic_natural_0 device* _S12 = kernelContext_4->chunks_0+c_1;
    Quat_0 q_5 = quat_of_0(float4((kernelContext_4->islands_0+(uint4(_S12->info_1) ).y)->rotation_0) );
    float3 th_0 = (float4(*(kernelContext_4->state_0+(4U * c_1 + 1U))) ).xyz;
    Quat_0 hidden_0 = from_axis_angle_0(th_0, length(th_0));
    thread Box_0 b_3;
    (&b_3)->center_1 = center_2;
    float4 _S13 = float4(_S12->crot0_0) ;
    float4 _S14 = float4(_S12->crot1_0) ;
    float4 _S15 = float4(_S12->crot2_0) ;
    float3 _S16 = float3(_S13.x, _S14.x, _S15.x);
    thread Quat_0 _S17 = hidden_0;
    float3 _S18 = rotate_0(&_S17, _S16);
    thread Quat_0 _S19 = q_5;
    float3 _S20 = rotate_0(&_S19, _S18);
    (&b_3)->axis0_0 = _S20;
    float3 _S21 = float3(_S13.y, _S14.y, _S15.y);
    thread Quat_0 _S22 = hidden_0;
    float3 _S23 = rotate_0(&_S22, _S21);
    thread Quat_0 _S24 = q_5;
    float3 _S25 = rotate_0(&_S24, _S23);
    (&b_3)->axis1_0 = _S25;
    float3 _S26 = float3(_S13.z, _S14.z, _S15.z);
    thread Quat_0 _S27 = hidden_0;
    float3 _S28 = rotate_0(&_S27, _S26);
    thread Quat_0 _S29 = q_5;
    float3 _S30 = rotate_0(&_S29, _S28);
    (&b_3)->axis2_0 = _S30;
    (&b_3)->half_2 = (float4(_S12->half_0) ).xyz;
    float4 _S31 = float4(_S12->cmat_0) ;
    (&b_3)->hull_at_0 = (as_type<uint>((_S31.z)));
    uint _S32 = (as_type<uint>((_S31.w)));
    (&b_3)->hull_v_0 = _S32 & 255U;
    (&b_3)->hull_f_0 = _S32 >> 8U;
    return b_3;
}

uint sample_count_0(const Box_0 thread* b_4)
{
    uint _S33 = b_4->hull_v_0;
    uint _S34;
    if((b_4->hull_v_0) == 0U)
    {
        _S34 = 14U;
    }
    else
    {
        _S34 = _S33 + b_4->hull_f_0;
    }
    return _S34;
}

bool may_overlap_0(const Box_0 thread* a_4, const Box_0 thread* b_5)
{
    float3 _S35 = b_5->center_1 - a_4->center_1;
    float3 _S36 = a_4->half_2;
    float3 _S37 = b_5->half_2;
    float _S38 = 0.00000999999974738f * (length(a_4->half_2) + length(b_5->half_2));
    float3 _S39 = a_4->axis0_0;
    float3 _S40 = a_4->axis1_0;
    float3 _S41 = a_4->axis2_0;
    float3 _S42 = b_5->axis0_0;
    float3 _S43 = b_5->axis1_0;
    float3 _S44 = b_5->axis2_0;
    array<float3, int(6)> _S45 = { { a_4->axis0_0, a_4->axis1_0, a_4->axis2_0, b_5->axis0_0, b_5->axis1_0, b_5->axis2_0 } };
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
            l_0 = _S45[i_0];
        }
        else
        {
            uint _S46 = i_0 - 6U;
            l_0 = cross(_S45[_S46 / 3U], _S45[3U + _S46 % 3U]);
        }
        float len_0 = length(l_0);
        if(len_0 <= 9.99999997475242708e-07f)
        {
            i_0 = i_0 + 1U;
            continue;
        }
        if((abs(dot(_S35, l_0))) > (_S36.x * abs(dot(_S39, l_0)) + _S36.y * abs(dot(_S40, l_0)) + _S36.z * abs(dot(_S41, l_0)) + (_S37.x * abs(dot(_S42, l_0)) + _S37.y * abs(dot(_S43, l_0)) + _S37.z * abs(dot(_S44, l_0))) + _S38 * len_0))
        {
            return false;
        }
        i_0 = i_0 + 1U;
    }
    return true;
}

void chunk_velocity_0(uint c_2, float3 thread* v_3, float3 thread* w_3, KernelContext_0 thread* kernelContext_5)
{
    ChunkStatic_natural_0 device* _S47 = kernelContext_5->chunks_0+c_2;
    Island_natural_0 device* _S48 = kernelContext_5->islands_0+(uint4(_S47->info_1) ).y;
    Quat_0 q_6 = quat_of_0(float4(_S48->rotation_0) );
    uint _S49 = 4U * c_2;
    float3 _S50 = (float4(_S47->center_0) ).xyz + (float4(*(kernelContext_5->state_0+_S49)) ).xyz - (float4(_S48->com_0) ).xyz;
    thread Quat_0 _S51 = q_6;
    float3 _S52 = rotate_0(&_S51, _S50);
    float3 _S53 = (float4(_S48->angular_velocity_0) ).xyz;
    float3 _S54 = (float4(_S48->velocity_0) ).xyz + (float4(_S48->velocity_err_0) ).xyz + cross(_S53, _S52);
    float3 _S55 = (float4(*(kernelContext_5->state_0+(_S49 + 2U))) ).xyz;
    thread Quat_0 _S56 = q_6;
    float3 _S57 = rotate_0(&_S56, _S55);
    *v_3 = _S54 + _S57;
    float3 _S58 = (float4(*(kernelContext_5->state_0+(_S49 + 3U))) ).xyz;
    thread Quat_0 _S59 = q_6;
    float3 _S60 = rotate_0(&_S59, _S58);
    *w_3 = _S53 + _S60;
    return;
}

float3 box_to_world_0(const Box_0 thread* b_6, float3 local_0)
{
    return b_6->axis0_0 * float3(local_0.x)  + b_6->axis1_0 * float3(local_0.y)  + b_6->axis2_0 * float3(local_0.z) ;
}

float3 box_axis_0(const Box_0 thread* b_7, uint k_0)
{
    float3 _S61;
    if(k_0 == 0U)
    {
        _S61 = b_7->axis0_0;
    }
    else
    {
        if(k_0 == 1U)
        {
            _S61 = b_7->axis1_0;
        }
        else
        {
            _S61 = b_7->axis2_0;
        }
    }
    return _S61;
}

float comp3_0(float3 v_4, uint k_1)
{
    float _S62;
    if(k_1 == 0U)
    {
        _S62 = v_4.x;
    }
    else
    {
        if(k_1 == 1U)
        {
            _S62 = v_4.y;
        }
        else
        {
            _S62 = v_4.z;
        }
    }
    return _S62;
}

float3 sample_point_0(const Box_0 thread* b_8, uint i_1, KernelContext_0 thread* kernelContext_6)
{
    uint _S63 = b_8->hull_v_0;
    if((b_8->hull_v_0) != 0U)
    {
        float3 local_1;
        if(i_1 < _S63)
        {
            local_1 = (float4(*(kernelContext_6->loads_0+(b_8->hull_at_0 + i_1))) ).xyz * float3(0.89999997615814209f) ;
        }
        else
        {
            local_1 = (float4(*(kernelContext_6->loads_0+(b_8->hull_at_0 + _S63 + b_8->hull_f_0 + (i_1 - _S63)))) ).xyz;
        }
        float3 _S64 = b_8->center_1;
        float3 _S65 = box_to_world_0(b_8, local_1);
        return _S64 + _S65;
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
        float _S66;
        if((i_1 & 2U) == 0U)
        {
            _S66 = - h_0.y;
        }
        else
        {
            _S66 = h_0.y;
        }
        float _S67;
        if((i_1 & 4U) == 0U)
        {
            _S67 = - h_0.z;
        }
        else
        {
            _S67 = h_0.z;
        }
        return b_8->center_1 + b_8->axis0_0 * float3(sign_0)  + b_8->axis1_0 * float3(_S66)  + b_8->axis2_0 * float3(_S67) ;
    }
    uint _S68 = i_1 - 8U;
    uint axis_1 = _S68 / 2U;
    if((_S68 % 2U) == 0U)
    {
        sign_0 = -1.0f;
    }
    else
    {
        sign_0 = 1.0f;
    }
    float3 _S69 = b_8->center_1;
    float3 _S70 = box_axis_0(b_8, axis_1);
    return _S69 + _S70 * float3((sign_0 * comp3_0(b_8->half_2, axis_1))) ;
}

float3 sample_point_1(const Box_0 thread* b_9, uint i_2, KernelContext_0 thread* kernelContext_7)
{
    uint _S71 = b_9->hull_v_0;
    if((b_9->hull_v_0) != 0U)
    {
        float3 local_2;
        if(i_2 < _S71)
        {
            local_2 = (float4(*(kernelContext_7->loads_0+(b_9->hull_at_0 + i_2))) ).xyz * float3(0.89999997615814209f) ;
        }
        else
        {
            local_2 = (float4(*(kernelContext_7->loads_0+(b_9->hull_at_0 + _S71 + b_9->hull_f_0 + (i_2 - _S71)))) ).xyz;
        }
        float3 _S72 = b_9->center_1;
        float3 _S73 = box_to_world_0(b_9, local_2);
        return _S72 + _S73;
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
        float _S74;
        if((i_2 & 2U) == 0U)
        {
            _S74 = - h_1.y;
        }
        else
        {
            _S74 = h_1.y;
        }
        float _S75;
        if((i_2 & 4U) == 0U)
        {
            _S75 = - h_1.z;
        }
        else
        {
            _S75 = h_1.z;
        }
        return b_9->center_1 + b_9->axis0_0 * float3(sign_1)  + b_9->axis1_0 * float3(_S74)  + b_9->axis2_0 * float3(_S75) ;
    }
    uint _S76 = i_2 - 8U;
    uint axis_2 = _S76 / 2U;
    if((_S76 % 2U) == 0U)
    {
        sign_1 = -1.0f;
    }
    else
    {
        sign_1 = 1.0f;
    }
    float3 _S77 = b_9->center_1;
    float3 _S78 = box_axis_0(b_9, axis_2);
    return _S77 + _S78 * float3((sign_1 * comp3_0(b_9->half_2, axis_2))) ;
}

float3 box_to_local_0(const Box_0 thread* b_10, float3 r_1)
{
    return float3(dot(r_1, b_10->axis0_0), dot(r_1, b_10->axis1_0), dot(r_1, b_10->axis2_0));
}

float hull_signed_distance_0(const Box_0 thread* b_11, float3 local_3, uint thread* face_0, KernelContext_0 thread* kernelContext_8)
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
        float4 _S79 = float4(*(kernelContext_8->loads_0+(b_11->hull_at_0 + b_11->hull_v_0 + f_0))) ;
        float d_0 = dot(_S79.xyz, local_3) - _S79.w;
        if(d_0 > best_0)
        {
            *face_0 = f_0;
            best_0 = d_0;
        }
        f_0 = f_0 + 1U;
    }
    return best_0;
}

bool penetration_0(const Box_0 thread* b_12, float3 p_0, float thread* depth_0, float3 thread* normal_1, KernelContext_0 thread* kernelContext_9)
{
    *depth_0 = 0.0f;
    *normal_1 = float3(0.0f) ;
    float3 r_2 = p_0 - b_12->center_1;
    float3 _S80 = b_12->half_2;
    if((dot(r_2, r_2)) > (dot(b_12->half_2, b_12->half_2) * 1.00001001358032227f))
    {
        return false;
    }
    uint _S81 = b_12->hull_v_0;
    if((b_12->hull_v_0) != 0U)
    {
        float3 _S82 = box_to_local_0(b_12, r_2);
        thread uint face_1;
        float _S83 = hull_signed_distance_0(b_12, _S82, &face_1, kernelContext_9);
        if(!(_S83 < 0.0f))
        {
            return false;
        }
        *depth_0 = - _S83;
        float3 _S84 = box_to_world_0(b_12, (float4(*(kernelContext_9->loads_0+(b_12->hull_at_0 + _S81 + face_1))) ).xyz);
        *normal_1 = _S84;
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
        float3 _S85 = box_axis_0(b_12, k_2);
        float local_4 = dot(r_2, _S85);
        float d_1 = comp3_0(_S80, k_2) - abs(local_4);
        if(d_1 <= 0.0f)
        {
            return false;
        }
        if(d_1 < best_1)
        {
            float _S86;
            if(local_4 >= 0.0f)
            {
                _S86 = 1.0f;
            }
            else
            {
                _S86 = -1.0f;
            }
            best_1 = d_1;
            axis_3 = k_2;
            side_0 = _S86;
        }
        k_2 = k_2 + 1U;
    }
    *depth_0 = best_1;
    float3 _S87 = box_axis_0(b_12, axis_3);
    *normal_1 = _S87 * float3(side_0) ;
    return true;
}

bool penetration_1(const Box_0 thread* b_13, float3 p_1, float thread* depth_1, float3 thread* normal_2, KernelContext_0 thread* kernelContext_10)
{
    *depth_1 = 0.0f;
    *normal_2 = float3(0.0f) ;
    float3 r_3 = p_1 - b_13->center_1;
    float3 _S88 = b_13->half_2;
    if((dot(r_3, r_3)) > (dot(b_13->half_2, b_13->half_2) * 1.00001001358032227f))
    {
        return false;
    }
    uint _S89 = b_13->hull_v_0;
    if((b_13->hull_v_0) != 0U)
    {
        float3 _S90 = box_to_local_0(b_13, r_3);
        thread uint face_2;
        float _S91 = hull_signed_distance_0(b_13, _S90, &face_2, kernelContext_10);
        if(!(_S91 < 0.0f))
        {
            return false;
        }
        *depth_1 = - _S91;
        float3 _S92 = box_to_world_0(b_13, (float4(*(kernelContext_10->loads_0+(b_13->hull_at_0 + _S89 + face_2))) ).xyz);
        *normal_2 = _S92;
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
        float3 _S93 = box_axis_0(b_13, k_3);
        float local_5 = dot(r_3, _S93);
        float d_2 = comp3_0(_S88, k_3) - abs(local_5);
        if(d_2 <= 0.0f)
        {
            return false;
        }
        if(d_2 < best_2)
        {
            float _S94;
            if(local_5 >= 0.0f)
            {
                _S94 = 1.0f;
            }
            else
            {
                _S94 = -1.0f;
            }
            best_2 = d_2;
            axis_4 = k_3;
            side_1 = _S94;
        }
        k_3 = k_3 + 1U;
    }
    *depth_1 = best_2;
    float3 _S95 = box_axis_0(b_13, axis_4);
    *normal_2 = _S95 * float3(side_1) ;
    return true;
}

bool pair_point_0(const Box_0 thread* ba_0, const Box_0 thread* bb_0, uint na_0, uint e_0, float3 thread* p_2, float3 thread* n_1, float thread* d_3, KernelContext_0 thread* kernelContext_11)
{
    if(e_0 < na_0)
    {
        float3 _S96 = sample_point_1(ba_0, e_0, kernelContext_11);
        *p_2 = _S96;
        bool _S97 = penetration_1(bb_0, _S96, d_3, n_1, kernelContext_11);
        return _S97;
    }
    float3 _S98 = sample_point_1(bb_0, e_0 - na_0, kernelContext_11);
    *p_2 = _S98;
    bool _S99 = penetration_1(ba_0, _S98, d_3, n_1, kernelContext_11);
    if(!_S99)
    {
        return false;
    }
    *n_1 = - *n_1;
    return true;
}

bool is_nan_0(float x_2)
{
    return ((as_type<uint>((x_2))) & 2147483647U) > 2139095040U;
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
        float3 _S100 = box_axis_0(b_14, k_4);
        float c_3 = abs(dot(d_4, _S100));
        float h_3 = h_2 + c_3 * comp3_0(b_14->half_2, k_4);
        uint _S101 = k_4 + 1U;
        float area_1 = area_0 + c_3 * 4.0f * comp3_0(b_14->half_2, _S101 % 3U) * comp3_0(b_14->half_2, (k_4 + 2U) % 3U);
        k_4 = _S101;
        h_2 = h_3;
        area_0 = area_1;
    }
    return float2(h_2, area_0);
}

float contact_stiffness_0(float ea_0, const Box_0 thread* a_5, float eb_0, const Box_0 thread* b_15, float3 dir_0)
{
    float3 d_5 = safe_normalize_0(dir_0);
    float2 _S102 = half_thickness_and_area_0(a_5, d_5);
    float2 _S103 = half_thickness_and_area_0(b_15, d_5);
    return min(_S102.y, _S103.y) / (_S102.x / ea_0 + _S103.x / eb_0);
}

float3 penalty_force_0(float k_5, float m_red_0, float friction_0, float depth_2, float3 normal_3, float3 rel_velocity_0, float dt_1, uint points_0, float thread* stored_0, float thread* dissipated_1, KernelContext_0 thread* kernelContext_12)
{
    float c_max_0 = 1.0f / max(float(points_0), 10.0f) * m_red_0 / dt_1;
    float vn_0 = dot(rel_velocity_0, normal_3);
    float _S104 = k_5 * depth_2;
    float _S105 = min(2.0f * kernelContext_12->params_0->zeta_0 * sqrt(k_5 * m_red_0), c_max_0) * vn_0;
    float _S106 = _S104 - _S105;
    float _S107 = max(_S106, 0.0f);
    float3 vt_0 = rel_velocity_0 - normal_3 * float3(vn_0) ;
    float vt_mag_0 = length(vt_0);
    float _S108 = friction_0 * _S107;
    float _S109 = min(_S108, min(c_max_0, _S108 / 0.00100000004749745f) * vt_mag_0);
    float3 ft_0;
    if(vt_mag_0 > 0.0f)
    {
        ft_0 = - vt_0 * float3((_S109 / vt_mag_0)) ;
    }
    else
    {
        ft_0 = float3(0.0f) ;
    }
    *stored_0 = 0.5f * k_5 * depth_2 * depth_2;
    float damping_power_0;
    if(_S106 > 0.0f)
    {
        damping_power_0 = _S105 * vn_0;
    }
    else
    {
        damping_power_0 = _S104 * max(vn_0, 0.0f);
    }
    *dissipated_1 = (damping_power_0 + length(ft_0) * vt_mag_0) * dt_1;
    return normal_3 * float3(_S107)  + ft_0;
}

void comp_add1_0(float thread* sum_0, float thread* err_0, float x_3)
{
    float t_2 = *sum_0 + x_3;
    if((abs(*sum_0)) >= (abs(x_3)))
    {
        *err_0 = *err_0 + (*sum_0 - t_2 + x_3);
    }
    else
    {
        *err_0 = *err_0 + (x_3 - t_2 + *sum_0);
    }
    *sum_0 = t_2;
    return;
}

void cov_or_0(uint island_0, uint bits_0, KernelContext_0 thread* kernelContext_13)
{
    uint _S110 = atomic_fetch_or_explicit(((atomic_uint device*)(&(kernelContext_13->islands_0+island_0)->coverage_0)), bits_0, memory_order_relaxed);
    return;
}

void cov_or_1(uint island_1, uint bits_1, KernelContext_0 thread* kernelContext_14)
{
    uint _S111 = atomic_fetch_or_explicit(((atomic_uint device*)(&(kernelContext_14->islands_0+island_1)->coverage_0)), bits_1, memory_order_relaxed);
    return;
}

void cov_mark_0(uint island_2, uint seen_0, uint bits_2, KernelContext_0 thread* kernelContext_15)
{
    if((bits_2 & (~seen_0)) != 0U)
    {
        cov_or_1(island_2, bits_2, kernelContext_15);
    }
    return;
}

void sentinel_mark_0(uint bits_3, KernelContext_0 thread* kernelContext_16)
{
    cov_mark_0(kernelContext_16->params_0->halt_index_0, (kernelContext_16->islands_0+kernelContext_16->params_0->halt_index_0)->coverage_0, bits_3, kernelContext_16);
    return;
}

void pair_contact_0(uint i_3, KernelContext_0 thread* kernelContext_17)
{
    uint at_0 = kernelContext_17->params_0->pair_index_0 + 6U * i_3;
    uint ca_0 = kernelContext_17->index_0[at_0];
    uint cb_0 = kernelContext_17->index_0[at_0 + 1U];
    uint _S112 = kernelContext_17->index_0[at_0 + 3U];
    float _S113 = (as_type<float>((kernelContext_17->index_0[at_0 + 4U])));
    float _S114 = (as_type<float>((kernelContext_17->index_0[at_0 + 5U])));
    float _S115 = kernelContext_17->params_0->dt_0;
    uint out_0 = kernelContext_17->params_0->slot_base_0 + 2U * kernelContext_17->index_0[at_0 + 2U];
    WorldPoint_0 _S116 = chunk_world_0(ca_0, kernelContext_17);
    WorldPoint_0 _S117 = chunk_world_0(cb_0, kernelContext_17);
    thread WorldPoint_0 _S118 = _S117;
    thread WorldPoint_0 _S119 = _S116;
    float3 _S120 = world_diff_0(&_S118, &_S119);
    bool touching_0 = !((length(_S120)) > ((float4((kernelContext_17->chunks_0+ca_0)->half_0) ).w + (float4((kernelContext_17->chunks_0+cb_0)->half_0) ).w));
    float4 _S121 = float4(*(kernelContext_17->scratch_0+(kernelContext_17->params_0->ledger_base_0 + i_3))) ;
    thread float4 ledger_1 = _S121;
    uint flags_0 = (as_type<uint>((_S121.w)));
    float3 _S122 = float3(0.0f) ;
    Box_0 _S123 = chunk_box_0(ca_0, _S122, kernelContext_17);
    Box_0 _S124 = chunk_box_0(cb_0, _S120, kernelContext_17);
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
            e_1 = 0U;
            for(;;)
            {
                if(e_1 < _S129)
                {
                }
                else
                {
                    break;
                }
                *(kernelContext_17->contact_state_0+(_S112 + e_1)) = packed_float4(float4((as_type<float>((2143289344U))), 0.0f, 0.0f, 0.0f)) ;
                e_1 = e_1 + 1U;
            }
        }
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
                *(kernelContext_17->scratch_0+(out_0 + e_1)) = packed_float4(float4(0.0f) ) ;
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
            *(kernelContext_17->scratch_0+(kernelContext_17->params_0->ledger_base_0 + i_3)) = packed_float4(ledger_1) ;
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
    if(_S132)
    {
        thread float3 va0_0;
        thread float3 wa0_0;
        chunk_velocity_0(ca_0, &va0_0, &wa0_0, kernelContext_17);
        thread float3 vb0_0;
        thread float3 wb0_0;
        chunk_velocity_0(cb_0, &vb0_0, &wb0_0, kernelContext_17);
        e_1 = 0U;
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
            bool _S135 = pair_point_0(&_S133, &_S134, _S126, e_1, &p_3, &n_2, &d_6, kernelContext_17);
            if(!_S135)
            {
                uint _S136 = _S112 + e_1;
                if(!is_nan_0((float4(*(kernelContext_17->contact_state_0+_S136)) ).x))
                {
                    *(kernelContext_17->contact_state_0+_S136) = packed_float4(float4((as_type<float>((2143289344U))), 0.0f, 0.0f, 0.0f)) ;
                }
                e_1 = e_1 + 1U;
                continue;
            }
            uint _S137 = count_0 + 1U;
            uint _S138 = _S112 + e_1;
            float4 _S139 = float4(*(kernelContext_17->contact_state_0+_S138)) ;
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
            *(kernelContext_17->contact_state_0+_S138) = packed_float4(entry_0) ;
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
            e_1 = e_1 + 1U;
        }
        if(count_0 > 0U)
        {
            float _S140 = (float4((kernelContext_17->chunks_0+ca_0)->cmat_0) ).x;
            float _S141 = (float4((kernelContext_17->chunks_0+cb_0)->cmat_0) ).x;
            float3 _S142 = _S124.center_1 - _S123.center_1;
            thread Box_0 _S143 = _S123;
            thread Box_0 _S144 = _S124;
            float _S145 = contact_stiffness_0(_S140, &_S143, _S141, &_S144, _S142);
            float _S146 = _S145 / max(float(engaged_0), 10.0f);
            e_1 = 0U;
            fa_0 = _S122;
            ta_0 = _S122;
            fb_0 = _S122;
            tb_0 = _S122;
            stored_sum_0 = 0.0f;
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
                bool _S149 = pair_point_0(&_S147, &_S148, _S126, e_1, &p_4, &n_3, &d_7, kernelContext_17);
                if(!_S149)
                {
                    e_1 = e_1 + 1U;
                    continue;
                }
                float eff_0 = d_7 - (float4(*(kernelContext_17->contact_state_0+(_S112 + e_1))) ).x;
                if(eff_0 <= 0.0f)
                {
                    e_1 = e_1 + 1U;
                    continue;
                }
                thread float stored_1;
                thread float diss_0;
                float3 _S150 = penalty_force_0(_S146, _S113, _S114, eff_0, n_3, va0_0 + cross(wa0_0, p_4) - (vb0_0 + cross(wb0_0, p_4 - _S124.center_1)), _S115, engaged_0, &stored_1, &diss_0, kernelContext_17);
                float3 fa_1 = fa_0 + _S150;
                float3 ta_1 = ta_0 + cross(p_4, _S150);
                float3 _S151 = - _S150;
                float3 fb_1 = fb_0 + _S151;
                float3 tb_1 = tb_0 + cross(p_4 - _S124.center_1, _S151);
                float stored_sum_1 = stored_sum_0 + stored_1;
                thread float _S152 = ledger_1.y;
                thread float _S153 = ledger_1.z;
                comp_add1_0(&_S152, &_S153, diss_0);
                ledger_1.z = _S153;
                ledger_1.y = _S152;
                fa_0 = fa_1;
                ta_0 = ta_1;
                fb_0 = fb_1;
                tb_0 = tb_1;
                stored_sum_0 = stored_sum_1;
                e_1 = e_1 + 1U;
            }
            has_state_0 = true;
        }
        else
        {
            has_state_0 = false;
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
        e_1 = 0U;
        for(;;)
        {
            if(e_1 < _S129)
            {
            }
            else
            {
                break;
            }
            *(kernelContext_17->contact_state_0+(_S112 + e_1)) = packed_float4(float4((as_type<float>((2143289344U))), 0.0f, 0.0f, 0.0f)) ;
            e_1 = e_1 + 1U;
        }
    }
    float3 _S154 = float3(0.0f) ;
    if(any(fa_0 != _S154))
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any(ta_0 != _S154);
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any(fb_0 != _S154);
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any(tb_0 != _S154);
    }
    bool _S155;
    if(loaded_0)
    {
        _S155 = true;
    }
    else
    {
        _S155 = (flags_0 & 2U) != 0U;
    }
    if(_S155)
    {
        *(kernelContext_17->scratch_0+out_0) = packed_float4(float4(fa_0, 0.0f)) ;
        *(kernelContext_17->scratch_0+(out_0 + 1U)) = packed_float4(float4(ta_0, 0.0f)) ;
        *(kernelContext_17->scratch_0+(out_0 + 2U)) = packed_float4(float4(fb_0, 0.0f)) ;
        *(kernelContext_17->scratch_0+(out_0 + 3U)) = packed_float4(float4(tb_0, 0.0f)) ;
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
    *(kernelContext_17->scratch_0+(kernelContext_17->params_0->ledger_base_0 + i_3)) = packed_float4(ledger_1) ;
    if(loaded_0)
    {
        sentinel_mark_0(1U, kernelContext_17);
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
    float3 _S156 = float3(1.0f, 0.0f, 0.0f);
    thread Quat_0 _S157 = q_7;
    float3 _S158 = rotate_0(&_S157, _S156);
    (&b_16)->axis0_0 = _S158;
    float3 _S159 = float3(0.0f, 1.0f, 0.0f);
    thread Quat_0 _S160 = q_7;
    float3 _S161 = rotate_0(&_S160, _S159);
    (&b_16)->axis1_0 = _S161;
    float3 _S162 = float3(0.0f, 0.0f, 1.0f);
    thread Quat_0 _S163 = q_7;
    float3 _S164 = rotate_0(&_S163, _S162);
    (&b_16)->axis2_0 = _S164;
    (&b_16)->half_2 = half_3;
    (&b_16)->hull_at_0 = 0U;
    (&b_16)->hull_v_0 = 0U;
    (&b_16)->hull_f_0 = 0U;
    return b_16;
}

uint impactor_slots_0(const Impactor_natural_0 thread* imp_1, const Box_0 thread* b_17)
{
    uint _S165;
    if(((float4(imp_1->shape_0) ).x) == 0.0f)
    {
        _S165 = 1U;
    }
    else
    {
        uint _S166 = sample_count_0(b_17);
        _S165 = _S166 + 14U;
    }
    return _S165;
}

uint impactor_slots_1(const Impactor_natural_0 thread* imp_2, const Box_0 thread* b_18)
{
    uint _S167;
    if(((float4(imp_2->shape_0) ).x) == 0.0f)
    {
        _S167 = 1U;
    }
    else
    {
        uint _S168 = sample_count_0(b_18);
        _S167 = _S168 + 14U;
    }
    return _S167;
}

bool sphere_contact_0(const Box_0 thread* b_19, float3 center_4, float radius_0, float3 thread* point_0, float3 thread* normal_4, float thread* depth_3, KernelContext_0 thread* kernelContext_18)
{
    float3 _S169 = float3(0.0f) ;
    *point_0 = _S169;
    *normal_4 = _S169;
    *depth_3 = 0.0f;
    float3 _S170 = b_19->center_1;
    float3 r_4 = center_4 - b_19->center_1;
    float3 _S171 = b_19->axis0_0;
    float3 _S172 = b_19->axis1_0;
    float3 _S173 = b_19->axis2_0;
    float3 local_6 = float3(dot(r_4, b_19->axis0_0), dot(r_4, b_19->axis1_0), dot(r_4, b_19->axis2_0));
    uint _S174 = b_19->hull_v_0;
    if((b_19->hull_v_0) != 0U)
    {
        thread uint face_3;
        float _S175 = hull_signed_distance_0(b_19, local_6, &face_3, kernelContext_18);
        if(_S175 >= radius_0)
        {
            return false;
        }
        float3 _S176 = box_to_world_0(b_19, (float4(*(kernelContext_18->loads_0+(b_19->hull_at_0 + _S174 + face_3))) ).xyz);
        *normal_4 = _S176;
        *point_0 = center_4 - _S176 * float3(max(_S175, 0.0f)) ;
        *depth_3 = radius_0 - _S175;
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
        *normal_4 = _S171 * float3(dn_0.x)  + _S172 * float3(dn_0.y)  + _S173 * float3(dn_0.z) ;
        *point_0 = _S170 + _S171 * float3(q_8.x)  + _S172 * float3(q_8.y)  + _S173 * float3(q_8.z) ;
        *depth_3 = radius_0 - dist_0;
        return true;
    }
    thread float inside_0;
    thread float3 n_4;
    bool _S177 = penetration_0(b_19, center_4, &inside_0, &n_4, kernelContext_18);
    if(!_S177)
    {
        return false;
    }
    *normal_4 = n_4;
    *point_0 = center_4 - n_4 * float3(min(radius_0, inside_0)) ;
    *depth_3 = radius_0 + inside_0;
    return true;
}

bool impactor_contact_0(const Impactor_natural_0 thread* imp_3, float crush_depth_0, const Box_0 thread* shrunk_0, const Box_0 thread* b_20, uint j_0, float3 thread* p_5, float3 thread* n_5, float thread* d_9, KernelContext_0 thread* kernelContext_19)
{
    float3 _S178 = float3(0.0f) ;
    *p_5 = _S178;
    *n_5 = _S178;
    *d_9 = 0.0f;
    float4 _S179 = float4(imp_3->shape_0) ;
    if((_S179.x) == 0.0f)
    {
        bool _S180 = sphere_contact_0(b_20, _S178, _S179.y - crush_depth_0, p_5, n_5, d_9, kernelContext_19);
        if(!_S180)
        {
            return false;
        }
        *n_5 = - *n_5;
        return true;
    }
    uint _S181 = sample_count_0(b_20);
    if(j_0 < _S181)
    {
        float3 _S182 = sample_point_0(b_20, j_0, kernelContext_19);
        *p_5 = _S182;
        bool _S183 = penetration_0(shrunk_0, _S182, d_9, n_5, kernelContext_19);
        return _S183;
    }
    float3 _S184 = sample_point_0(shrunk_0, j_0 - _S181, kernelContext_19);
    *p_5 = _S184;
    bool _S185 = penetration_0(b_20, _S184, d_9, n_5, kernelContext_19);
    if(!_S185)
    {
        return false;
    }
    *n_5 = - *n_5;
    return true;
}

bool impactor_contact_1(const Impactor_natural_0 thread* imp_4, float crush_depth_1, const Box_0 thread* shrunk_1, const Box_0 thread* b_21, uint j_1, float3 thread* p_6, float3 thread* n_6, float thread* d_10, KernelContext_0 thread* kernelContext_20)
{
    float3 _S186 = float3(0.0f) ;
    *p_6 = _S186;
    *n_6 = _S186;
    *d_10 = 0.0f;
    float4 _S187 = float4(imp_4->shape_0) ;
    if((_S187.x) == 0.0f)
    {
        bool _S188 = sphere_contact_0(b_21, _S186, _S187.y - crush_depth_1, p_6, n_6, d_10, kernelContext_20);
        if(!_S188)
        {
            return false;
        }
        *n_6 = - *n_6;
        return true;
    }
    uint _S189 = sample_count_0(b_21);
    if(j_1 < _S189)
    {
        float3 _S190 = sample_point_0(b_21, j_1, kernelContext_20);
        *p_6 = _S190;
        bool _S191 = penetration_0(shrunk_1, _S190, d_10, n_6, kernelContext_20);
        return _S191;
    }
    float3 _S192 = sample_point_0(shrunk_1, j_1 - _S189, kernelContext_20);
    *p_6 = _S192;
    bool _S193 = penetration_0(b_21, _S192, d_10, n_6, kernelContext_20);
    if(!_S193)
    {
        return false;
    }
    *n_6 = - *n_6;
    return true;
}

WorldPoint_0 impactor_point_0(uint _S194, KernelContext_0 thread* kernelContext_21)
{
    Impactor_natural_0 device* _S195 = kernelContext_21->impactors_0+_S194;
    thread WorldPoint_0 wi_0;
    (&wi_0)->hi_0 = (float4(_S195->position_1) ).xyz;
    (&wi_0)->lo_0 = (float4(_S195->position_err_1) ).xyz;
    (&wi_0)->rel_0 = float3(0.0f) ;
    return wi_0;
}

Box_0 impactor_box_1(uint _S196, float3 _S197, float3 _S198, KernelContext_0 thread* kernelContext_22)
{
    Quat_0 q_9 = quat_of_0(float4((kernelContext_22->impactors_0+_S196)->rotation_1) );
    thread Box_0 b_22;
    (&b_22)->center_1 = _S197;
    float3 _S199 = float3(1.0f, 0.0f, 0.0f);
    thread Quat_0 _S200 = q_9;
    float3 _S201 = rotate_0(&_S200, _S199);
    (&b_22)->axis0_0 = _S201;
    float3 _S202 = float3(0.0f, 1.0f, 0.0f);
    thread Quat_0 _S203 = q_9;
    float3 _S204 = rotate_0(&_S203, _S202);
    (&b_22)->axis1_0 = _S204;
    float3 _S205 = float3(0.0f, 0.0f, 1.0f);
    thread Quat_0 _S206 = q_9;
    float3 _S207 = rotate_0(&_S206, _S205);
    (&b_22)->axis2_0 = _S207;
    (&b_22)->half_2 = _S198;
    (&b_22)->hull_at_0 = 0U;
    (&b_22)->hull_v_0 = 0U;
    (&b_22)->hull_f_0 = 0U;
    return b_22;
}

Box_0 impactor_shrunk_0(uint _S208, float _S209, const Box_0 thread* _S210)
{
    thread Box_0 shrunk_2 = *_S210;
    (&shrunk_2)->half_2 = _S210->half_2 - min(float3(_S209) , _S210->half_2 * float3(0.5f) );
    return shrunk_2;
}

bool impactor_contact_2(uint _S211, float _S212, const Box_0 thread* _S213, const Box_0 thread* _S214, uint _S215, float3 thread* _S216, float3 thread* _S217, float thread* _S218, KernelContext_0 thread* kernelContext_23)
{
    Impactor_natural_0 _S219 = *(kernelContext_23->impactors_0+_S211);
    float3 _S220 = float3(0.0f) ;
    *_S216 = _S220;
    *_S217 = _S220;
    *_S218 = 0.0f;
    float4 _S221 = float4(_S219.shape_0) ;
    if((_S221.x) == 0.0f)
    {
        bool _S222 = sphere_contact_0(_S214, _S220, _S221.y - _S212, _S216, _S217, _S218, kernelContext_23);
        if(!_S222)
        {
            return false;
        }
        *_S217 = - *_S217;
        return true;
    }
    uint _S223 = sample_count_0(_S214);
    if(_S215 < _S223)
    {
        float3 _S224 = sample_point_0(_S214, _S215, kernelContext_23);
        *_S216 = _S224;
        bool _S225 = penetration_0(_S213, _S224, _S218, _S217, kernelContext_23);
        return _S225;
    }
    float3 _S226 = sample_point_0(_S213, _S215 - _S223, kernelContext_23);
    *_S216 = _S226;
    bool _S227 = penetration_0(_S214, _S226, _S218, _S217, kernelContext_23);
    if(!_S227)
    {
        return false;
    }
    *_S217 = - *_S217;
    return true;
}

uint impactor_contact_count_0(uint _S228, float _S229, const Box_0 thread* _S230, const Box_0 thread* _S231, KernelContext_0 thread* kernelContext_24)
{
    thread Impactor_natural_0 _S232 = *(kernelContext_24->impactors_0+_S228);
    uint j_2 = 0U;
    uint count_1 = 0U;
    for(;;)
    {
        uint _S233 = impactor_slots_1(&_S232, _S231);
        if(j_2 < _S233)
        {
        }
        else
        {
            break;
        }
        thread float3 p_7;
        thread float3 n_7;
        thread float d_11;
        bool _S234 = impactor_contact_2(_S228, _S229, _S230, _S231, j_2, &p_7, &n_7, &d_11, kernelContext_24);
        if(_S234)
        {
            count_1 = count_1 + 1U;
        }
        j_2 = j_2 + 1U;
    }
    return count_1;
}

void impactor_candidate_forces_0(uint k_6, KernelContext_0 thread* kernelContext_25)
{
    uint _S235 = 3U * k_6;
    uint at_1 = kernelContext_25->params_0->cand_index_0 + _S235;
    uint c_4 = kernelContext_25->index_0[at_1];
    uint slot_0 = kernelContext_25->index_0[at_1 + 1U];
    uint _S236 = kernelContext_25->index_0[at_1 + 2U];
    thread Impactor_natural_0 _S237 = *(kernelContext_25->impactors_0+_S236);
    float _S238 = kernelContext_25->params_0->dt_0;
    float3 _S239 = float3(0.0f) ;
    thread float4 data_0 = float4(*(kernelContext_25->scratch_0+(kernelContext_25->params_0->cand_base_0 + _S235))) ;
    bool hit_0;
    float3 f_sum_0;
    float3 t_sum_0;
    float3 imp_f_0;
    float3 imp_t_0;
    if(((uint4((&_S237)->cand_0) ).z) == 0U)
    {
        WorldPoint_0 _S240 = chunk_world_0(c_4, kernelContext_25);
        WorldPoint_0 _S241 = impactor_point_0(_S236, kernelContext_25);
        thread WorldPoint_0 _S242 = _S240;
        thread WorldPoint_0 _S243 = _S241;
        float3 _S244 = world_diff_0(&_S242, &_S243);
        float4 _S245 = float4((&_S237)->half_1) ;
        if(!((length(_S244)) > (_S245.w + (float4((kernelContext_25->chunks_0+c_4)->half_0) ).w)))
        {
            Box_0 _S246 = impactor_box_1(_S236, _S239, _S245.xyz, kernelContext_25);
            Box_0 _S247 = chunk_box_0(c_4, _S244, kernelContext_25);
            float4 _S248 = float4((&_S237)->mat_0) ;
            float _S249 = _S248.x;
            float _S250 = (float4((kernelContext_25->chunks_0+c_4)->cmat_0) ).x;
            float3 _S251 = _S247.center_1 - _S246.center_1;
            thread Box_0 _S252 = _S246;
            thread Box_0 _S253 = _S247;
            float _S254 = contact_stiffness_0(_S249, &_S252, _S250, &_S253, _S251);
            float4 _S255 = float4((&_S237)->geom_0) ;
            float _S256 = _S255.y;
            thread Box_0 _S257 = _S246;
            Box_0 _S258 = impactor_shrunk_0(_S236, _S256, &_S257);
            thread Box_0 _S259 = _S258;
            thread Box_0 _S260 = _S247;
            uint _S261 = impactor_contact_count_0(_S236, _S256, &_S259, &_S260, kernelContext_25);
            bool _S262 = ((float4((&_S237)->shape_0) ).x) == 0.0f;
            float _S263;
            if(_S262)
            {
                _S263 = _S254;
            }
            else
            {
                _S263 = _S254 / max(float(_S261), 10.0f);
            }
            uint _S264;
            if(_S262)
            {
                _S264 = 1U;
            }
            else
            {
                _S264 = _S261;
            }
            float m_1 = (float4((kernelContext_25->chunks_0+c_4)->center_0) ).w;
            float _S265 = _S248.z;
            float _S266 = m_1 * _S265 / (m_1 + _S265);
            float _S267;
            if((kernelContext_25->params_0->pair_friction_0) >= 0.0f)
            {
                _S267 = kernelContext_25->params_0->pair_friction_0;
            }
            else
            {
                _S267 = min(_S248.y, (float4((kernelContext_25->chunks_0+c_4)->cmat_0) ).y);
            }
            float3 _S268 = (float4((&_S237)->velocity_1) ).xyz + (float4((&_S237)->velocity_err_1) ).xyz;
            thread float3 vc_0;
            thread float3 wc_0;
            chunk_velocity_0(c_4, &vc_0, &wc_0, kernelContext_25);
            hit_0 = false;
            uint j_3 = 0U;
            f_sum_0 = _S239;
            t_sum_0 = _S239;
            imp_f_0 = _S239;
            imp_t_0 = _S239;
            for(;;)
            {
                bool _S269;
                if(_S261 > 0U)
                {
                    thread Box_0 _S270 = _S247;
                    uint _S271 = impactor_slots_0(&_S237, &_S270);
                    _S269 = j_3 < _S271;
                }
                else
                {
                    _S269 = false;
                }
                if(_S269)
                {
                }
                else
                {
                    break;
                }
                thread Box_0 _S272 = _S258;
                thread Box_0 _S273 = _S247;
                thread float3 p_8;
                thread float3 nrm_0;
                thread float dep_0;
                bool _S274 = impactor_contact_0(&_S237, _S256, &_S272, &_S273, j_3, &p_8, &nrm_0, &dep_0, kernelContext_25);
                if(!_S274)
                {
                    j_3 = j_3 + 1U;
                    continue;
                }
                thread float stored_2;
                thread float diss_1;
                float3 _S275 = penalty_force_0(_S263, _S266, _S267, dep_0 * _S255.x, nrm_0, vc_0 + cross(wc_0, p_8 - _S247.center_1) - (_S268 + cross((float4((&_S237)->angular_velocity_1) ).xyz, p_8)), _S238, _S264, &stored_2, &diss_1, kernelContext_25);
                float3 f_sum_1 = f_sum_0 + _S275;
                float3 t_sum_1 = t_sum_0 + cross(p_8 - _S247.center_1, _S275);
                float3 imp_f_1 = imp_f_0 - _S275;
                float3 imp_t_1 = imp_t_0 - cross(p_8, _S275);
                thread float _S276 = data_0.z;
                thread float _S277 = data_0.w;
                comp_add1_0(&_S276, &_S277, diss_1);
                data_0.w = _S277;
                data_0.z = _S276;
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
            f_sum_0 = _S239;
            t_sum_0 = _S239;
            imp_f_0 = _S239;
            imp_t_0 = _S239;
        }
    }
    else
    {
        hit_0 = false;
        f_sum_0 = _S239;
        t_sum_0 = _S239;
        imp_f_0 = _S239;
        imp_t_0 = _S239;
    }
    uint _S278 = 2U * slot_0;
    *(kernelContext_25->scratch_0+(kernelContext_25->params_0->slot_base_0 + _S278)) = packed_float4(float4(f_sum_0, 0.0f)) ;
    *(kernelContext_25->scratch_0+(kernelContext_25->params_0->slot_base_0 + _S278 + 1U)) = packed_float4(float4(t_sum_0, 0.0f)) ;
    *(kernelContext_25->scratch_0+(kernelContext_25->params_0->cand_base_0 + _S235)) = packed_float4(data_0) ;
    *(kernelContext_25->scratch_0+(kernelContext_25->params_0->cand_base_0 + _S235 + 1U)) = packed_float4(float4(imp_f_0, 0.0f)) ;
    *(kernelContext_25->scratch_0+(kernelContext_25->params_0->cand_base_0 + _S235 + 2U)) = packed_float4(float4(imp_t_0, 0.0f)) ;
    if(hit_0)
    {
        sentinel_mark_0(2U, kernelContext_25);
    }
    return;
}

void travel_check_0(uint c_5, KernelContext_0 thread* kernelContext_26)
{
    ChunkStatic_natural_0 device* _S279 = kernelContext_26->chunks_0+c_5;
    if(((uint4(_S279->cinfo_0) ).z) == 0U)
    {
        return;
    }
    WorldPoint_0 _S280 = chunk_world_0(c_5, kernelContext_26);
    float4 _S281 = float4(_S279->start_hi_0) ;
    if((length(_S280.hi_0 - _S281.xyz + (_S280.lo_0 - (float4(_S279->start_lo_0) ).xyz) + _S280.rel_0)) > (_S281.w))
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
    threadgroup uint g_run_1;
    (&kernelContext_27)->g_run_0 = &g_run_1;
    threadgroup uint g_halt_1;
    (&kernelContext_27)->g_halt_0 = &g_halt_1;
    threadgroup uint g_wide_run_1;
    (&kernelContext_27)->g_wide_run_0 = &g_wide_run_1;
    uint i_4 = id_0.x;
    bool _S282 = stopped_0(&kernelContext_27);
    if(_S282)
    {
        return;
    }
    if(i_4 < ((&kernelContext_27)->params_0->pair_count_0))
    {
        pair_contact_0(i_4, &kernelContext_27);
    }
    else
    {
        if(i_4 < ((&kernelContext_27)->params_0->pair_count_0 + (&kernelContext_27)->params_0->cand_count_0))
        {
            impactor_candidate_forces_0(i_4 - (&kernelContext_27)->params_0->pair_count_0, &kernelContext_27);
        }
        else
        {
            if(i_4 < ((&kernelContext_27)->params_0->pair_count_0 + (&kernelContext_27)->params_0->cand_count_0 + (&kernelContext_27)->params_0->chunk_count_0))
            {
                travel_check_0(i_4 - (&kernelContext_27)->params_0->pair_count_0 - (&kernelContext_27)->params_0->cand_count_0, &kernelContext_27);
            }
        }
    }
    return;
}

[[kernel]] void impactor_shares(uint3 id_1 [[thread_position_in_grid]], Params_0 constant* params_2 [[buffer(0)]], Island_natural_0 device* islands_2 [[buffer(9)]], uint device* index_2 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_2 [[buffer(3)]], packed_float4 device* state_2 [[buffer(6)]], packed_float4 device* scratch_2 [[buffer(8)]], packed_float4 device* contact_state_2 [[buffer(11)]], packed_float4 device* loads_2 [[buffer(5)]], Impactor_natural_0 device* impactors_2 [[buffer(10)]], BondStatic_natural_0 device* bonds_2 [[buffer(2)]], MaterialTable_0 constant* materials_2 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_2 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_28;
    (&kernelContext_28)->params_0 = params_2;
    (&kernelContext_28)->islands_0 = islands_2;
    (&kernelContext_28)->index_0 = index_2;
    (&kernelContext_28)->chunks_0 = chunks_2;
    (&kernelContext_28)->state_0 = state_2;
    (&kernelContext_28)->scratch_0 = scratch_2;
    (&kernelContext_28)->contact_state_0 = contact_state_2;
    (&kernelContext_28)->loads_0 = loads_2;
    (&kernelContext_28)->impactors_0 = impactors_2;
    (&kernelContext_28)->bonds_0 = bonds_2;
    (&kernelContext_28)->materials_0 = materials_2;
    (&kernelContext_28)->bond_dyn_0 = bond_dyn_2;
    threadgroup array<float4, int(32)> g_part_a_2;
    (&kernelContext_28)->g_part_a_0 = &g_part_a_2;
    threadgroup array<float4, int(32)> g_part_b_2;
    (&kernelContext_28)->g_part_b_0 = &g_part_b_2;
    threadgroup array<uint, int(5)> g_seen_2;
    (&kernelContext_28)->g_seen_0 = &g_seen_2;
    threadgroup uint g_run_2;
    (&kernelContext_28)->g_run_0 = &g_run_2;
    threadgroup uint g_halt_2;
    (&kernelContext_28)->g_halt_0 = &g_halt_2;
    threadgroup uint g_wide_run_2;
    (&kernelContext_28)->g_wide_run_0 = &g_wide_run_2;
    uint k_7 = id_1.x;
    bool _S283;
    if(k_7 >= (params_2->cand_count_0))
    {
        _S283 = true;
    }
    else
    {
        bool _S284 = stopped_0(&kernelContext_28);
        _S283 = _S284;
    }
    if(_S283)
    {
        return;
    }
    uint _S285 = 3U * k_7;
    uint at_2 = (&kernelContext_28)->params_0->cand_index_0 + _S285;
    uint c_6 = (&kernelContext_28)->index_0[at_2];
    uint _S286 = (&kernelContext_28)->index_0[at_2 + 2U];
    thread Impactor_natural_0 _S287 = *((&kernelContext_28)->impactors_0+_S286);
    if(((uint4((&_S287)->cand_0) ).z) == 0U)
    {
        _S283 = ((float4((&_S287)->crush_0) ).x) > 0.0f;
    }
    else
    {
        _S283 = false;
    }
    float total_0;
    float ksum_0;
    if(_S283)
    {
        WorldPoint_0 _S288 = chunk_world_0(c_6, &kernelContext_28);
        WorldPoint_0 _S289 = impactor_point_0(_S286, &kernelContext_28);
        thread WorldPoint_0 _S290 = _S288;
        thread WorldPoint_0 _S291 = _S289;
        float3 _S292 = world_diff_0(&_S290, &_S291);
        float4 _S293 = float4((&_S287)->half_1) ;
        if(!((length(_S292)) > (_S293.w + (float4(((&kernelContext_28)->chunks_0+c_6)->half_0) ).w)))
        {
            Box_0 _S294 = impactor_box_1(_S286, float3(0.0f) , _S293.xyz, &kernelContext_28);
            Box_0 _S295 = chunk_box_0(c_6, _S292, &kernelContext_28);
            float _S296 = (float4((&_S287)->mat_0) ).x;
            float _S297 = (float4(((&kernelContext_28)->chunks_0+c_6)->cmat_0) ).x;
            float3 _S298 = _S295.center_1 - _S294.center_1;
            thread Box_0 _S299 = _S294;
            thread Box_0 _S300 = _S295;
            float _S301 = contact_stiffness_0(_S296, &_S299, _S297, &_S300, _S298);
            float _S302 = (float4((&_S287)->crush_0) ).w;
            thread Box_0 _S303 = _S294;
            Box_0 _S304 = impactor_shrunk_0(_S286, _S302, &_S303);
            thread Box_0 _S305 = _S304;
            thread Box_0 _S306 = _S295;
            uint _S307 = impactor_contact_count_0(_S286, _S302, &_S305, &_S306, &kernelContext_28);
            float _S308;
            if(((float4((&_S287)->shape_0) ).x) == 0.0f)
            {
                _S308 = _S301;
            }
            else
            {
                _S308 = _S301 / max(float(_S307), 10.0f);
            }
            uint j_4 = 0U;
            total_0 = 0.0f;
            ksum_0 = 0.0f;
            for(;;)
            {
                if(_S307 > 0U)
                {
                    thread Box_0 _S309 = _S295;
                    uint _S310 = impactor_slots_0(&_S287, &_S309);
                    _S283 = j_4 < _S310;
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
                thread Box_0 _S311 = _S304;
                thread Box_0 _S312 = _S295;
                thread float3 p_9;
                thread float3 nrm_1;
                thread float dep_1;
                bool _S313 = impactor_contact_1(&_S287, _S302, &_S311, &_S312, j_4, &p_9, &nrm_1, &dep_1, &kernelContext_28);
                if(!_S313)
                {
                    j_4 = j_4 + 1U;
                    continue;
                }
                float ksum_1 = ksum_0 + _S308;
                total_0 = total_0 + _S308 * dep_1;
                ksum_0 = ksum_1;
                j_4 = j_4 + 1U;
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
    float4 _S314 = float4(*((&kernelContext_28)->scratch_0+((&kernelContext_28)->params_0->cand_base_0 + _S285))) ;
    *((&kernelContext_28)->scratch_0+((&kernelContext_28)->params_0->cand_base_0 + _S285)) = packed_float4(float4(total_0, ksum_0, _S314.z, _S314.w)) ;
    return;
}

[[kernel]] void impactor_crush(uint3 group_0 [[threadgroup_position_in_grid]], uint3 thread_0 [[thread_position_in_threadgroup]], Params_0 constant* params_3 [[buffer(0)]], Island_natural_0 device* islands_3 [[buffer(9)]], uint device* index_3 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_3 [[buffer(3)]], packed_float4 device* state_3 [[buffer(6)]], packed_float4 device* scratch_3 [[buffer(8)]], packed_float4 device* contact_state_3 [[buffer(11)]], packed_float4 device* loads_3 [[buffer(5)]], Impactor_natural_0 device* impactors_3 [[buffer(10)]], BondStatic_natural_0 device* bonds_3 [[buffer(2)]], MaterialTable_0 constant* materials_3 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_3 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_29;
    (&kernelContext_29)->params_0 = params_3;
    (&kernelContext_29)->islands_0 = islands_3;
    (&kernelContext_29)->index_0 = index_3;
    (&kernelContext_29)->chunks_0 = chunks_3;
    (&kernelContext_29)->state_0 = state_3;
    (&kernelContext_29)->scratch_0 = scratch_3;
    (&kernelContext_29)->contact_state_0 = contact_state_3;
    (&kernelContext_29)->loads_0 = loads_3;
    (&kernelContext_29)->impactors_0 = impactors_3;
    (&kernelContext_29)->bonds_0 = bonds_3;
    (&kernelContext_29)->materials_0 = materials_3;
    (&kernelContext_29)->bond_dyn_0 = bond_dyn_3;
    threadgroup array<float4, int(32)> g_part_a_3;
    (&kernelContext_29)->g_part_a_0 = &g_part_a_3;
    threadgroup array<float4, int(32)> g_part_b_3;
    (&kernelContext_29)->g_part_b_0 = &g_part_b_3;
    threadgroup array<uint, int(5)> g_seen_3;
    (&kernelContext_29)->g_seen_0 = &g_seen_3;
    threadgroup uint g_run_3;
    (&kernelContext_29)->g_run_0 = &g_run_3;
    threadgroup uint g_halt_3;
    (&kernelContext_29)->g_halt_0 = &g_halt_3;
    threadgroup uint g_wide_run_3;
    (&kernelContext_29)->g_wide_run_0 = &g_wide_run_3;
    uint ii_0 = group_0.x;
    uint tid_2 = thread_0.x;
    bool _S315;
    if(ii_0 >= (params_3->impactor_count_0))
    {
        _S315 = true;
    }
    else
    {
        bool _S316 = stopped_0(&kernelContext_29);
        _S315 = _S316;
    }
    if(_S315)
    {
        return;
    }
    Impactor_natural_0 device* _S317 = (&kernelContext_29)->impactors_0+ii_0;
    float4 _S318 = float4((*_S317).position_err_1) ;
    float4 _S319 = float4((*_S317).velocity_1) ;
    float4 _S320 = float4((*_S317).velocity_err_1) ;
    float4 _S321 = float4((*_S317).angular_velocity_1) ;
    float4 _S322 = float4((*_S317).rotation_1) ;
    float4 _S323 = float4((*_S317).inertia0_2) ;
    float4 _S324 = float4((*_S317).inertia1_2) ;
    float4 _S325 = float4((*_S317).inertia2_2) ;
    float4 _S326 = float4((*_S317).inv0_2) ;
    float4 _S327 = float4((*_S317).inv1_2) ;
    float4 _S328 = float4((*_S317).inv2_2) ;
    float4 _S329 = float4((*_S317).shape_0) ;
    float4 _S330 = float4((*_S317).half_1) ;
    float4 _S331 = float4((*_S317).mat_0) ;
    float4 _S332 = float4((*_S317).crush_0) ;
    float4 _S333 = float4((*_S317).geom_0) ;
    float4 _S334 = float4((*_S317).rotation_err_1) ;
    float4 _S335 = float4((*_S317).ledger_0) ;
    uint4 _S336 = uint4((*_S317).cand_0) ;
    float4 _S337 = float4((*_S317).momentum_1) ;
    float4 _S338 = float4((*_S317).momentum_err_1) ;
    thread Impactor_0 imp_5;
    (&imp_5)->position_1 = float4((*_S317).position_1) ;
    (&imp_5)->position_err_1 = _S318;
    (&imp_5)->velocity_1 = _S319;
    (&imp_5)->velocity_err_1 = _S320;
    (&imp_5)->angular_velocity_1 = _S321;
    (&imp_5)->rotation_1 = _S322;
    (&imp_5)->inertia0_2 = _S323;
    (&imp_5)->inertia1_2 = _S324;
    (&imp_5)->inertia2_2 = _S325;
    (&imp_5)->inv0_2 = _S326;
    (&imp_5)->inv1_2 = _S327;
    (&imp_5)->inv2_2 = _S328;
    (&imp_5)->shape_0 = _S329;
    (&imp_5)->half_1 = _S330;
    (&imp_5)->mat_0 = _S331;
    (&imp_5)->crush_0 = _S332;
    (&imp_5)->geom_0 = _S333;
    (&imp_5)->rotation_err_1 = _S334;
    (&imp_5)->ledger_0 = _S335;
    (&imp_5)->cand_0 = _S336;
    (&imp_5)->momentum_1 = _S337;
    (&imp_5)->momentum_err_1 = _S338;
    float4 _S339 = float4(0.0f) ;
    thread float4 shares_0 = _S339;
    thread float4 unused_0 = _S339;
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
        shares_0 = shares_0 + float4(*((&kernelContext_29)->scratch_0+((&kernelContext_29)->params_0->cand_base_0 + 3U * k_8))) ;
        k_8 = k_8 + 256U;
    }
    group_sum2_0(tid_2, &shares_0, &unused_0, &kernelContext_29);
    if(tid_2 != 0U)
    {
        _S315 = true;
    }
    else
    {
        _S315 = ((&imp_5)->cand_0.z) != 0U;
    }
    if(_S315)
    {
        return;
    }
    (&imp_5)->geom_0 = float4(1.0f, (&imp_5)->crush_0.w, 0.0f, 0.0f);
    float total_1 = shares_0.x;
    if(((&imp_5)->crush_0.x) > 0.0f)
    {
        _S315 = ((&imp_5)->crush_0.z) < ((&imp_5)->crush_0.y);
    }
    else
    {
        _S315 = false;
    }
    if(_S315)
    {
        _S315 = total_1 > ((&imp_5)->crush_0.x);
    }
    else
    {
        _S315 = false;
    }
    if(_S315)
    {
        float extra_0 = (total_1 - (&imp_5)->crush_0.x) / shares_0.y;
        (&imp_5)->crush_0.w = (&imp_5)->crush_0.w + extra_0;
        (&imp_5)->crush_0.z = (&imp_5)->crush_0.z + (&imp_5)->crush_0.x * extra_0;
        float _S340 = (&imp_5)->crush_0.x * extra_0;
        thread float _S341 = (&imp_5)->ledger_0.z;
        thread float _S342 = (&imp_5)->ledger_0.w;
        comp_add1_0(&_S341, &_S342, _S340);
        (&imp_5)->ledger_0.w = _S342;
        (&imp_5)->ledger_0.z = _S341;
        float _S343 = (&imp_5)->crush_0.x * extra_0;
        thread float _S344 = (&imp_5)->ledger_0.x;
        thread float _S345 = (&imp_5)->ledger_0.y;
        comp_add1_0(&_S344, &_S345, _S343);
        (&imp_5)->ledger_0.y = _S345;
        (&imp_5)->ledger_0.x = _S344;
        (&imp_5)->geom_0.x = (&imp_5)->crush_0.x / total_1;
    }
    Impactor_natural_0 device* _S346 = (&kernelContext_29)->impactors_0+ii_0;
    _S346->position_1 = packed_float4(imp_5.position_1) ;
    _S346->position_err_1 = packed_float4(imp_5.position_err_1) ;
    _S346->velocity_1 = packed_float4(imp_5.velocity_1) ;
    _S346->velocity_err_1 = packed_float4(imp_5.velocity_err_1) ;
    _S346->angular_velocity_1 = packed_float4(imp_5.angular_velocity_1) ;
    _S346->rotation_1 = packed_float4(imp_5.rotation_1) ;
    _S346->inertia0_2 = packed_float4(imp_5.inertia0_2) ;
    _S346->inertia1_2 = packed_float4(imp_5.inertia1_2) ;
    _S346->inertia2_2 = packed_float4(imp_5.inertia2_2) ;
    _S346->inv0_2 = packed_float4(imp_5.inv0_2) ;
    _S346->inv1_2 = packed_float4(imp_5.inv1_2) ;
    _S346->inv2_2 = packed_float4(imp_5.inv2_2) ;
    _S346->shape_0 = packed_float4(imp_5.shape_0) ;
    _S346->half_1 = packed_float4(imp_5.half_1) ;
    _S346->mat_0 = packed_float4(imp_5.mat_0) ;
    _S346->crush_0 = packed_float4(imp_5.crush_0) ;
    _S346->geom_0 = packed_float4(imp_5.geom_0) ;
    _S346->rotation_err_1 = packed_float4(imp_5.rotation_err_1) ;
    _S346->ledger_0 = packed_float4(imp_5.ledger_0) ;
    _S346->cand_0 = packed_uint4(imp_5.cand_0) ;
    _S346->momentum_1 = packed_float4(imp_5.momentum_1) ;
    _S346->momentum_err_1 = packed_float4(imp_5.momentum_err_1) ;
    return;
}

void comp_add_0(float3 thread* sum_1, float3 thread* err_1, float3 x_4)
{
    float3 t_3 = *sum_1 + x_4;
    float3 _S347 = abs(x_4);
    *err_1 = *err_1 + (select(x_4, *sum_1, (abs(*sum_1)) >= _S347) - t_3 + select(*sum_1, x_4, (abs(*sum_1)) >= _S347));
    *sum_1 = t_3;
    return;
}

float3 inverse_rotate_0(const Quat_0 thread* q_10, float3 v_5)
{
    thread Quat_0 c_7;
    (&c_7)->w_1 = q_10->w_1;
    (&c_7)->x_1 = - q_10->x_1;
    (&c_7)->y_1 = - q_10->y_1;
    (&c_7)->z_0 = - q_10->z_0;
    thread Quat_0 _S348 = c_7;
    float3 _S349 = rotate_0(&_S348, v_5);
    return _S349;
}

float3 inverse_rotate_1(const Quat_0 thread* q_11, float3 v_6)
{
    thread Quat_0 c_8;
    (&c_8)->w_1 = q_11->w_1;
    (&c_8)->x_1 = - q_11->x_1;
    (&c_8)->y_1 = - q_11->y_1;
    (&c_8)->z_0 = - q_11->z_0;
    thread Quat_0 _S350 = c_8;
    float3 _S351 = rotate_0(&_S350, v_6);
    return _S351;
}

float3 rows_mul_0(float4 r0_0, float4 r1_0, float4 r2_0, float3 v_7)
{
    return float3(dot(r0_0.xyz, v_7), dot(r1_0.xyz, v_7), dot(r2_0.xyz, v_7));
}

float3 world_mul_0(const Quat_0 thread* q_12, float4 r0_1, float4 r1_1, float4 r2_1, float3 v_8)
{
    float3 _S352 = inverse_rotate_1(q_12, v_8);
    float3 _S353 = rotate_1(q_12, rows_mul_0(r0_1, r1_1, r2_1, _S352));
    return _S353;
}

float4 turn_minus_one_0(float3 axis_5, float angle_1)
{
    float s_1 = sin(0.25f * angle_1);
    return float4(axis_5 * float3(sin(0.5f * angle_1)) , -2.0f * s_1 * s_1);
}

Quat_0 quat_mul_0(const Quat_0 thread* a_6, const Quat_0 thread* o_0)
{
    thread Quat_0 r_5;
    (&r_5)->w_1 = a_6->w_1 * o_0->w_1 - a_6->x_1 * o_0->x_1 - a_6->y_1 * o_0->y_1 - a_6->z_0 * o_0->z_0;
    (&r_5)->x_1 = a_6->w_1 * o_0->x_1 + a_6->x_1 * o_0->w_1 + a_6->y_1 * o_0->z_0 - a_6->z_0 * o_0->y_1;
    (&r_5)->y_1 = a_6->w_1 * o_0->y_1 - a_6->x_1 * o_0->z_0 + a_6->y_1 * o_0->w_1 + a_6->z_0 * o_0->x_1;
    (&r_5)->z_0 = a_6->w_1 * o_0->z_0 + a_6->x_1 * o_0->y_1 - a_6->y_1 * o_0->x_1 + a_6->z_0 * o_0->w_1;
    return r_5;
}

float4 quat_vec_0(const Quat_0 thread* q_13)
{
    return float4(q_13->x_1, q_13->y_1, q_13->z_0, q_13->w_1);
}

void comp_add4_0(float4 thread* sum_2, float4 thread* err_2, float4 x_5)
{
    float4 t_4 = *sum_2 + x_5;
    float4 _S354 = abs(x_5);
    *err_2 = *err_2 + (select(x_5, *sum_2, (abs(*sum_2)) >= _S354) - t_4 + select(*sum_2, x_5, (abs(*sum_2)) >= _S354));
    *sum_2 = t_4;
    return;
}

void quat_accumulate_0(Quat_0 thread* hi_1, float4 thread* lo_1, float4 x_6)
{
    thread Quat_0 _S355 = *hi_1;
    float4 _S356 = quat_vec_0(&_S355);
    thread float4 sum_3 = _S356;
    comp_add4_0(&sum_3, lo_1, x_6);
    float4 t_5 = sum_3 + *lo_1;
    *lo_1 = *lo_1 - (t_5 - sum_3);
    *hi_1 = quat_of_0(t_5);
    return;
}

void turn_left_0(Quat_0 thread* hi_2, float4 thread* lo_2, float3 omega_0, float dt_2)
{
    float _S357 = length(omega_0);
    float angle_2 = _S357 * dt_2;
    if(angle_2 < 1.00000000317107685e-30f)
    {
        return;
    }
    float4 d_12 = turn_minus_one_0(omega_0 / float3(_S357) , angle_2);
    thread Quat_0 dq_0;
    (&dq_0)->x_1 = d_12.x;
    (&dq_0)->y_1 = d_12.y;
    (&dq_0)->z_0 = d_12.z;
    (&dq_0)->w_1 = d_12.w;
    thread Quat_0 _S358 = dq_0;
    thread Quat_0 _S359 = *hi_2;
    Quat_0 _S360 = quat_mul_0(&_S358, &_S359);
    thread Quat_0 _S361 = _S360;
    float4 _S362 = quat_vec_0(&_S361);
    quat_accumulate_0(hi_2, lo_2, _S362);
    return;
}

[[kernel]] void impactor_integrate(uint3 group_1 [[threadgroup_position_in_grid]], uint3 thread_1 [[thread_position_in_threadgroup]], Params_0 constant* params_4 [[buffer(0)]], Island_natural_0 device* islands_4 [[buffer(9)]], uint device* index_4 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_4 [[buffer(3)]], packed_float4 device* state_4 [[buffer(6)]], packed_float4 device* scratch_4 [[buffer(8)]], packed_float4 device* contact_state_4 [[buffer(11)]], packed_float4 device* loads_4 [[buffer(5)]], Impactor_natural_0 device* impactors_4 [[buffer(10)]], BondStatic_natural_0 device* bonds_4 [[buffer(2)]], MaterialTable_0 constant* materials_4 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_4 [[buffer(7)]])
{
    float3 p_10;
    thread KernelContext_0 kernelContext_30;
    (&kernelContext_30)->params_0 = params_4;
    (&kernelContext_30)->islands_0 = islands_4;
    (&kernelContext_30)->index_0 = index_4;
    (&kernelContext_30)->chunks_0 = chunks_4;
    (&kernelContext_30)->state_0 = state_4;
    (&kernelContext_30)->scratch_0 = scratch_4;
    (&kernelContext_30)->contact_state_0 = contact_state_4;
    (&kernelContext_30)->loads_0 = loads_4;
    (&kernelContext_30)->impactors_0 = impactors_4;
    (&kernelContext_30)->bonds_0 = bonds_4;
    (&kernelContext_30)->materials_0 = materials_4;
    (&kernelContext_30)->bond_dyn_0 = bond_dyn_4;
    threadgroup array<float4, int(32)> g_part_a_4;
    (&kernelContext_30)->g_part_a_0 = &g_part_a_4;
    threadgroup array<float4, int(32)> g_part_b_4;
    (&kernelContext_30)->g_part_b_0 = &g_part_b_4;
    threadgroup array<uint, int(5)> g_seen_4;
    (&kernelContext_30)->g_seen_0 = &g_seen_4;
    threadgroup uint g_run_4;
    (&kernelContext_30)->g_run_0 = &g_run_4;
    threadgroup uint g_halt_4;
    (&kernelContext_30)->g_halt_0 = &g_halt_4;
    threadgroup uint g_wide_run_4;
    (&kernelContext_30)->g_wide_run_0 = &g_wide_run_4;
    uint ii_1 = group_1.x;
    uint tid_3 = thread_1.x;
    if(ii_1 >= (params_4->impactor_count_0))
    {
        return;
    }
    Island_natural_0 device* _S363 = (&kernelContext_30)->islands_0+(&kernelContext_30)->params_0->halt_index_0;
    Impactor_natural_0 device* _S364 = (&kernelContext_30)->impactors_0+ii_1;
    float4 _S365 = float4((*_S364).position_err_1) ;
    float4 _S366 = float4((*_S364).velocity_1) ;
    float4 _S367 = float4((*_S364).velocity_err_1) ;
    float4 _S368 = float4((*_S364).angular_velocity_1) ;
    float4 _S369 = float4((*_S364).rotation_1) ;
    float4 _S370 = float4((*_S364).inertia0_2) ;
    float4 _S371 = float4((*_S364).inertia1_2) ;
    float4 _S372 = float4((*_S364).inertia2_2) ;
    float4 _S373 = float4((*_S364).inv0_2) ;
    float4 _S374 = float4((*_S364).inv1_2) ;
    float4 _S375 = float4((*_S364).inv2_2) ;
    float4 _S376 = float4((*_S364).shape_0) ;
    float4 _S377 = float4((*_S364).half_1) ;
    float4 _S378 = float4((*_S364).mat_0) ;
    float4 _S379 = float4((*_S364).crush_0) ;
    float4 _S380 = float4((*_S364).geom_0) ;
    float4 _S381 = float4((*_S364).rotation_err_1) ;
    float4 _S382 = float4((*_S364).ledger_0) ;
    uint4 _S383 = uint4((*_S364).cand_0) ;
    float4 _S384 = float4((*_S364).momentum_1) ;
    float4 _S385 = float4((*_S364).momentum_err_1) ;
    thread Impactor_0 imp_6;
    (&imp_6)->position_1 = float4((*_S364).position_1) ;
    (&imp_6)->position_err_1 = _S365;
    (&imp_6)->velocity_1 = _S366;
    (&imp_6)->velocity_err_1 = _S367;
    (&imp_6)->angular_velocity_1 = _S368;
    (&imp_6)->rotation_1 = _S369;
    (&imp_6)->inertia0_2 = _S370;
    (&imp_6)->inertia1_2 = _S371;
    (&imp_6)->inertia2_2 = _S372;
    (&imp_6)->inv0_2 = _S373;
    (&imp_6)->inv1_2 = _S374;
    (&imp_6)->inv2_2 = _S375;
    (&imp_6)->shape_0 = _S376;
    (&imp_6)->half_1 = _S377;
    (&imp_6)->mat_0 = _S378;
    (&imp_6)->crush_0 = _S379;
    (&imp_6)->geom_0 = _S380;
    (&imp_6)->rotation_err_1 = _S381;
    (&imp_6)->ledger_0 = _S382;
    (&imp_6)->cand_0 = _S383;
    (&imp_6)->momentum_1 = _S384;
    (&imp_6)->momentum_err_1 = _S385;
    uint4 _S386 = uint4(_S363->info_0) ;
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
            _S387 = ((&imp_6)->cand_0.w) >= _S388;
        }
        else
        {
            _S387 = false;
        }
    }
    if(_S387)
    {
        return;
    }
    if(((&imp_6)->cand_0.z) != 0U)
    {
        if(tid_3 == 0U)
        {
            ((&kernelContext_30)->impactors_0+ii_1)->cand_0[int(3)] = (&imp_6)->cand_0.w + 1U;
        }
        return;
    }
    float4 _S389 = float4(0.0f) ;
    thread float4 rf_0 = _S389;
    thread float4 rt_0 = _S389;
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
        uint _S390 = 3U * k_9;
        rf_0 = rf_0 + float4(*((&kernelContext_30)->scratch_0+((&kernelContext_30)->params_0->cand_base_0 + _S390 + 1U))) ;
        rt_0 = rt_0 + float4(*((&kernelContext_30)->scratch_0+((&kernelContext_30)->params_0->cand_base_0 + _S390 + 2U))) ;
        k_9 = k_9 + 256U;
    }
    group_sum2_0(tid_3, &rf_0, &rt_0, &kernelContext_30);
    if(tid_3 != 0U)
    {
        return;
    }
    float dt_3 = (&kernelContext_30)->params_0->dt_0;
    float3 _S391 = float3(0.0f) ;
    float3 load_f_0;
    float3 load_t_0;
    if(((&kernelContext_30)->params_0->has_ground_0) != 0U)
    {
        float3 _S392 = (&imp_6)->half_1.xyz;
        thread Impactor_0 _S393 = imp_6;
        Box_0 _S394 = impactor_box_0(&_S393, _S391, _S392);
        float3 _S395 = (&imp_6)->velocity_1.xyz + (&imp_6)->velocity_err_1.xyz;
        float _S396 = (&kernelContext_30)->params_0->ground_modulus_0;
        float _S397 = (&imp_6)->mat_0.x;
        float3 _S398 = float3(0.0f, 0.0f, 1.0f);
        thread Box_0 _S399 = _S394;
        thread Box_0 _S400 = _S394;
        float _S401 = contact_stiffness_0(_S396, &_S399, _S397, &_S400, _S398);
        float _S402 = (&imp_6)->position_1.z - (&kernelContext_30)->params_0->ground_hi_0 + ((&imp_6)->position_err_1.z - (&kernelContext_30)->params_0->ground_lo_0);
        uint total_points_0;
        if(((&imp_6)->shape_0.x) == 0.0f)
        {
            total_points_0 = 1U;
        }
        else
        {
            total_points_0 = 14U;
        }
        float _S403 = _S401 / float(min(total_points_0, 5U));
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
                thread Box_0 _S404 = _S394;
                float3 _S405 = sample_point_0(&_S404, s_2, &kernelContext_30);
                p_10 = _S405;
            }
            if((_S402 + p_10.z) < 0.0f)
            {
                below_0 = below_0 + 1U;
            }
            s_2 = s_2 + 1U;
        }
        if(below_0 > 0U)
        {
            sentinel_mark_0(8U, &kernelContext_30);
        }
        s_2 = 0U;
        load_f_0 = _S391;
        load_t_0 = _S391;
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
                thread Box_0 _S406 = _S394;
                float3 _S407 = sample_point_0(&_S406, s_2, &kernelContext_30);
                p_10 = _S407;
            }
            float depth_4 = - (_S402 + p_10.z);
            if(depth_4 <= 0.0f)
            {
                s_2 = s_2 + 1U;
                continue;
            }
            thread float stored_3;
            thread float diss_2;
            float3 _S408 = penalty_force_0(_S403, (&imp_6)->mat_0.z, (&kernelContext_30)->params_0->ground_friction_0, depth_4, _S398, _S395 + cross((&imp_6)->angular_velocity_1.xyz, p_10), dt_3, below_0, &stored_3, &diss_2, &kernelContext_30);
            float3 load_f_1 = load_f_0 + _S408;
            float3 load_t_1 = load_t_0 + cross(p_10, _S408);
            thread float _S409 = (&imp_6)->ledger_0.x;
            thread float _S410 = (&imp_6)->ledger_0.y;
            comp_add1_0(&_S409, &_S410, diss_2);
            (&imp_6)->ledger_0.y = _S410;
            (&imp_6)->ledger_0.x = _S409;
            load_f_0 = load_f_1;
            load_t_0 = load_t_1;
            s_2 = s_2 + 1U;
        }
    }
    else
    {
        load_f_0 = _S391;
        load_t_0 = _S391;
    }
    float3 load_f_2 = rf_0.xyz + load_f_0;
    float3 load_t_2 = rt_0.xyz + load_t_0;
    float m_2 = (&imp_6)->mat_0.z;
    thread float3 vel_0 = (&imp_6)->velocity_1.xyz;
    thread float3 vel_err_0 = (&imp_6)->velocity_err_1.xyz;
    float3 _S411 = float3(dt_3) ;
    comp_add_0(&vel_0, &vel_err_0, (load_f_2 / float3(m_2)  + (&kernelContext_30)->params_0->gravity_0.xyz) * _S411);
    Quat_0 _S412 = quat_of_0((&imp_6)->rotation_1);
    thread Quat_0 q_14 = _S412;
    thread float4 q_err_0 = (&imp_6)->rotation_err_1;
    thread float3 l_hi_0 = (&imp_6)->momentum_1.xyz;
    thread float3 l_err_0 = (&imp_6)->momentum_err_1.xyz;
    comp_add_0(&l_hi_0, &l_err_0, load_t_2 * _S411);
    float3 l_1 = l_hi_0 + l_err_0;
    thread Quat_0 _S413 = _S412;
    float3 _S414 = world_mul_0(&_S413, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    thread float3 pos_0 = (&imp_6)->position_1.xyz;
    thread float3 pos_err_0 = (&imp_6)->position_err_1.xyz;
    comp_add_0(&pos_0, &pos_err_0, (vel_0 + vel_err_0) * _S411);
    turn_left_0(&q_14, &q_err_0, _S414, dt_3);
    thread Quat_0 _S415 = q_14;
    float3 _S416 = world_mul_0(&_S415, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    (&imp_6)->angular_velocity_1 = float4(_S416, 0.0f);
    thread Quat_0 _S417 = q_14;
    float4 _S418 = quat_vec_0(&_S417);
    (&imp_6)->rotation_1 = _S418;
    (&imp_6)->rotation_err_1 = q_err_0;
    (&imp_6)->momentum_1 = float4(l_hi_0, 0.0f);
    (&imp_6)->momentum_err_1 = float4(l_err_0, 0.0f);
    (&imp_6)->position_1 = float4(pos_0, 0.0f);
    (&imp_6)->position_err_1 = float4(pos_err_0, 0.0f);
    (&imp_6)->velocity_1 = float4(vel_0, 0.0f);
    (&imp_6)->velocity_err_1 = float4(vel_err_0, 0.0f);
    (&imp_6)->cand_0.w = (&imp_6)->cand_0.w + 1U;
    (&imp_6)->geom_0 = float4(1.0f, (&imp_6)->crush_0.w, 0.0f, 0.0f);
    Impactor_natural_0 device* _S419 = (&kernelContext_30)->impactors_0+ii_1;
    _S419->position_1 = packed_float4(imp_6.position_1) ;
    _S419->position_err_1 = packed_float4(imp_6.position_err_1) ;
    _S419->velocity_1 = packed_float4(imp_6.velocity_1) ;
    _S419->velocity_err_1 = packed_float4(imp_6.velocity_err_1) ;
    _S419->angular_velocity_1 = packed_float4(imp_6.angular_velocity_1) ;
    _S419->rotation_1 = packed_float4(imp_6.rotation_1) ;
    _S419->inertia0_2 = packed_float4(imp_6.inertia0_2) ;
    _S419->inertia1_2 = packed_float4(imp_6.inertia1_2) ;
    _S419->inertia2_2 = packed_float4(imp_6.inertia2_2) ;
    _S419->inv0_2 = packed_float4(imp_6.inv0_2) ;
    _S419->inv1_2 = packed_float4(imp_6.inv1_2) ;
    _S419->inv2_2 = packed_float4(imp_6.inv2_2) ;
    _S419->shape_0 = packed_float4(imp_6.shape_0) ;
    _S419->half_1 = packed_float4(imp_6.half_1) ;
    _S419->mat_0 = packed_float4(imp_6.mat_0) ;
    _S419->crush_0 = packed_float4(imp_6.crush_0) ;
    _S419->geom_0 = packed_float4(imp_6.geom_0) ;
    _S419->rotation_err_1 = packed_float4(imp_6.rotation_err_1) ;
    _S419->ledger_0 = packed_float4(imp_6.ledger_0) ;
    _S419->cand_0 = packed_uint4(imp_6.cand_0) ;
    _S419->momentum_1 = packed_float4(imp_6.momentum_1) ;
    _S419->momentum_err_1 = packed_float4(imp_6.momentum_err_1) ;
    uint k_10 = (&imp_6)->cand_0.w - 1U - (&kernelContext_30)->params_0->step_start_0;
    if(k_10 < ((&kernelContext_30)->params_0->record_stride_0))
    {
        uint at_3 = (&kernelContext_30)->params_0->record_base_0 + 2U * (ii_1 * (&kernelContext_30)->params_0->record_stride_0 + k_10);
        *((&kernelContext_30)->scratch_0+at_3) = packed_float4(float4(vel_0 + vel_err_0, 0.0f)) ;
        *((&kernelContext_30)->scratch_0+(at_3 + 1U)) = packed_float4(float4(pos_0 + pos_err_0, 0.0f)) ;
    }
    return;
}

void ground_contact_0(uint c_9, bool account_0, float3 thread* f_1, float3 thread* t_6, KernelContext_0 thread* kernelContext_31)
{
    ChunkStatic_natural_0 device* _S420 = kernelContext_31->chunks_0+c_9;
    WorldPoint_0 _S421 = chunk_world_0(c_9, kernelContext_31);
    float above_0 = _S421.hi_0.z - kernelContext_31->params_0->ground_hi_0 + (_S421.lo_0.z - kernelContext_31->params_0->ground_lo_0) + _S421.rel_0.z;
    if((above_0 - (float4(_S420->half_0) ).w) > 0.0f)
    {
        return;
    }
    Box_0 _S422 = chunk_box_0(c_9, float3(0.0f) , kernelContext_31);
    float _S423 = kernelContext_31->params_0->ground_modulus_0;
    float _S424 = (float4(_S420->cmat_0) ).x;
    float3 _S425 = float3(0.0f, 0.0f, 1.0f);
    thread Box_0 _S426 = _S422;
    thread Box_0 _S427 = _S422;
    float _S428 = contact_stiffness_0(_S423, &_S426, _S424, &_S427, _S425);
    thread Box_0 _S429 = _S422;
    uint _S430 = sample_count_0(&_S429);
    uint s_3 = 0U;
    uint n_8 = 0U;
    for(;;)
    {
        if(s_3 < _S430)
        {
        }
        else
        {
            break;
        }
        thread Box_0 _S431 = _S422;
        float3 _S432 = sample_point_0(&_S431, s_3, kernelContext_31);
        if((above_0 + _S432.z) < 0.0f)
        {
            n_8 = n_8 + 1U;
        }
        s_3 = s_3 + 1U;
    }
    if(n_8 == 0U)
    {
        return;
    }
    sentinel_mark_0(4U, kernelContext_31);
    thread float3 vc_1;
    thread float3 wc_1;
    chunk_velocity_0(c_9, &vc_1, &wc_1, kernelContext_31);
    thread float4 ledger_2 = float4(*(kernelContext_31->scratch_0+(kernelContext_31->params_0->ledger_base_0 + kernelContext_31->params_0->pair_count_0 + c_9))) ;
    s_3 = 0U;
    for(;;)
    {
        if(s_3 < _S430)
        {
        }
        else
        {
            break;
        }
        thread Box_0 _S433 = _S422;
        float3 _S434 = sample_point_0(&_S433, s_3, kernelContext_31);
        float _S435 = above_0 + _S434.z;
        if(!(_S435 < 0.0f))
        {
            s_3 = s_3 + 1U;
            continue;
        }
        thread float stored_4;
        thread float diss_3;
        float3 _S436 = penalty_force_0(_S428 / float(max(n_8, 5U)), (float4(_S420->center_0) ).w, kernelContext_31->params_0->ground_friction_0, - _S435, _S425, vc_1 + cross(wc_1, _S434), kernelContext_31->params_0->dt_0, n_8, &stored_4, &diss_3, kernelContext_31);
        *f_1 = *f_1 + _S436;
        *t_6 = *t_6 + cross(_S434, _S436);
        thread float _S437 = ledger_2.y;
        thread float _S438 = ledger_2.z;
        comp_add1_0(&_S437, &_S438, diss_3);
        ledger_2.z = _S438;
        ledger_2.y = _S437;
        s_3 = s_3 + 1U;
    }
    if(account_0)
    {
        *(kernelContext_31->scratch_0+(kernelContext_31->params_0->ledger_base_0 + kernelContext_31->params_0->pair_count_0 + c_9)) = packed_float4(ledger_2) ;
    }
    return;
}

[[kernel]] void contact_sums(uint3 id_2 [[thread_position_in_grid]], Params_0 constant* params_5 [[buffer(0)]], Island_natural_0 device* islands_5 [[buffer(9)]], uint device* index_5 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_5 [[buffer(3)]], packed_float4 device* state_5 [[buffer(6)]], packed_float4 device* scratch_5 [[buffer(8)]], packed_float4 device* contact_state_5 [[buffer(11)]], packed_float4 device* loads_5 [[buffer(5)]], Impactor_natural_0 device* impactors_5 [[buffer(10)]], BondStatic_natural_0 device* bonds_5 [[buffer(2)]], MaterialTable_0 constant* materials_5 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_5 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_32;
    (&kernelContext_32)->params_0 = params_5;
    (&kernelContext_32)->islands_0 = islands_5;
    (&kernelContext_32)->index_0 = index_5;
    (&kernelContext_32)->chunks_0 = chunks_5;
    (&kernelContext_32)->state_0 = state_5;
    (&kernelContext_32)->scratch_0 = scratch_5;
    (&kernelContext_32)->contact_state_0 = contact_state_5;
    (&kernelContext_32)->loads_0 = loads_5;
    (&kernelContext_32)->impactors_0 = impactors_5;
    (&kernelContext_32)->bonds_0 = bonds_5;
    (&kernelContext_32)->materials_0 = materials_5;
    (&kernelContext_32)->bond_dyn_0 = bond_dyn_5;
    threadgroup array<float4, int(32)> g_part_a_5;
    (&kernelContext_32)->g_part_a_0 = &g_part_a_5;
    threadgroup array<float4, int(32)> g_part_b_5;
    (&kernelContext_32)->g_part_b_0 = &g_part_b_5;
    threadgroup array<uint, int(5)> g_seen_5;
    (&kernelContext_32)->g_seen_0 = &g_seen_5;
    threadgroup uint g_run_5;
    (&kernelContext_32)->g_run_0 = &g_run_5;
    threadgroup uint g_halt_5;
    (&kernelContext_32)->g_halt_0 = &g_halt_5;
    threadgroup uint g_wide_run_5;
    (&kernelContext_32)->g_wide_run_0 = &g_wide_run_5;
    uint g_0 = id_2.x;
    bool _S439;
    if(g_0 >= (params_5->seg_count_0))
    {
        _S439 = true;
    }
    else
    {
        bool _S440 = stopped_0(&kernelContext_32);
        _S439 = _S440;
    }
    if(_S439)
    {
        return;
    }
    uint _S441 = 3U * g_0;
    uint _S442 = (&kernelContext_32)->index_0[(&kernelContext_32)->params_0->seg_index_0 + _S441];
    uint begin_0 = (&kernelContext_32)->index_0[(&kernelContext_32)->params_0->seg_index_0 + _S441 + 1U];
    uint _S443 = (&kernelContext_32)->index_0[(&kernelContext_32)->params_0->seg_index_0 + _S441 + 2U];
    float3 _S444 = float3(0.0f) ;
    thread float3 f_2 = _S444;
    thread float3 t_7 = _S444;
    uint e_2 = begin_0;
    for(;;)
    {
        if(e_2 < _S443)
        {
        }
        else
        {
            break;
        }
        uint entry_1 = (&kernelContext_32)->index_0[e_2];
        if(entry_1 == 2147483648U)
        {
            ground_contact_0(_S442, true, &f_2, &t_7, &kernelContext_32);
            e_2 = e_2 + 1U;
            continue;
        }
        uint _S445 = 2U * entry_1;
        f_2 = f_2 + (float4(*((&kernelContext_32)->scratch_0+((&kernelContext_32)->params_0->slot_base_0 + _S445))) ).xyz;
        t_7 = t_7 + (float4(*((&kernelContext_32)->scratch_0+((&kernelContext_32)->params_0->slot_base_0 + _S445 + 1U))) ).xyz;
        e_2 = e_2 + 1U;
    }
    uint _S446 = 2U * g_0;
    *((&kernelContext_32)->scratch_0+((&kernelContext_32)->params_0->seg_base_0 + _S446)) = packed_float4(float4(f_2, 0.0f)) ;
    *((&kernelContext_32)->scratch_0+((&kernelContext_32)->params_0->seg_base_0 + _S446 + 1U)) = packed_float4(float4(t_7, 0.0f)) ;
    return;
}

void seen_clear_0(uint tid_4, KernelContext_0 thread* kernelContext_33)
{
    if(tid_4 < 5U)
    {
        (*kernelContext_33->g_seen_0)[tid_4] = 0U;
    }
    return;
}

bool contact_stopped_0(const Island_natural_0 thread* isl_0, KernelContext_0 thread* kernelContext_34)
{
    uint4 _S447 = uint4((kernelContext_34->islands_0+kernelContext_34->params_0->halt_index_0)->info_0) ;
    bool _S448;
    if(((_S447.z) & 1U) != 0U)
    {
        _S448 = true;
    }
    else
    {
        uint _S449 = _S447.y;
        if(_S449 != 0U)
        {
            _S448 = _S449 <= ((uint4(isl_0->info_0) ).w);
        }
        else
        {
            _S448 = false;
        }
    }
    return _S448;
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
    uint4 _S450 = uint4((kernelContext_35->islands_0+kernelContext_35->params_0->halt_index_0)->info_0) ;
    bool _S451;
    if(((_S450.z) & 1U) != 0U)
    {
        _S451 = true;
    }
    else
    {
        uint _S452 = _S450.y;
        if(_S452 != 0U)
        {
            _S451 = _S452 <= (isl_1->info_0.w);
        }
        else
        {
            _S451 = false;
        }
    }
    return _S451;
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
    float3 _S453 = float3(0.0f) ;
    (&rg_0)->torque_0 = _S453;
    (&rg_0)->a_7 = _S453;
    (&rg_0)->alpha_0 = _S453;
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
    float3 _S454 = float3(0.0f) ;
    (&rg_1)->torque_0 = _S454;
    (&rg_1)->a_7 = _S454;
    (&rg_1)->alpha_0 = _S454;
    return rg_1;
}

float time_since_0(float4 origin_0, uint k_11, float dt_4, KernelContext_0 thread* kernelContext_36)
{
    return kernelContext_36->params_0->t_hi_0 - origin_0.x + (kernelContext_36->params_0->t_lo_0 - origin_0.y) + float(k_11) * dt_4;
}

float table_eval_0(uint offset_0, uint count_2, float tau_0, KernelContext_0 thread* kernelContext_37)
{
    float4 _S455 = float4(*(kernelContext_37->loads_0+offset_0)) ;
    if(tau_0 <= (_S455.x))
    {
        return _S455.y;
    }
    uint i_5 = 1U;
    for(;;)
    {
        if(i_5 < count_2)
        {
        }
        else
        {
            break;
        }
        uint _S456 = offset_0 + i_5;
        float4 _S457 = float4(*(kernelContext_37->loads_0+_S456)) ;
        float _S458 = _S457.x;
        if(tau_0 <= _S458)
        {
            float4 _S459 = float4(*(kernelContext_37->loads_0+(_S456 - 1U))) ;
            float _S460 = _S459.x;
            float _S461 = _S459.y;
            return _S461 + (tau_0 - _S460) / max(_S458 - _S460, 1.00000000317107685e-30f) * (_S457.y - _S461);
        }
        i_5 = i_5 + 1U;
    }
    return (float4(*(kernelContext_37->loads_0+(offset_0 + count_2 - 1U))) ).y;
}

float eval_function_0(uint term_0, uint k_12, float dt_5, float shift_0, KernelContext_0 thread* kernelContext_38)
{
    uint _S462 = 5U * term_0;
    uint4 info_2 = (as_type<uint4>((float4(*(kernelContext_38->loads_0+_S462)) )));
    float4 _S463 = float4(*(kernelContext_38->loads_0+(_S462 + 3U))) ;
    float4 _S464 = float4(*(kernelContext_38->loads_0+(_S462 + 4U))) ;
    uint kind_0 = info_2.z;
    if(kind_0 == 0U)
    {
        return _S463.z;
    }
    float _S465 = time_since_0(_S463, k_12, dt_5, kernelContext_38);
    float tau_1 = _S465 + shift_0;
    float shape_1;
    if(kind_0 == 1U)
    {
        if(tau_1 <= 0.0f)
        {
            shape_1 = 0.0f;
        }
        else
        {
            float _S466 = _S464.x;
            if(tau_1 >= _S466)
            {
                shape_1 = _S464.y;
            }
            else
            {
                shape_1 = _S464.y * tau_1 / _S466;
            }
        }
        return shape_1;
    }
    bool _S467;
    if(kind_0 == 2U)
    {
        if(tau_1 < 0.0f)
        {
            _S467 = true;
        }
        else
        {
            _S467 = tau_1 > (_S464.x);
        }
        if(_S467)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S464.y * sin(3.14159274101257324f * tau_1 / _S464.x);
        }
        return shape_1;
    }
    if(kind_0 == 3U)
    {
        float sn_0 = tau_1 / _S464.y;
        if(sn_0 < 0.0f)
        {
            _S467 = true;
        }
        else
        {
            _S467 = sn_0 > 1.0f;
        }
        if(_S467)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S464.x * (1.0f - sn_0) * exp(- _S464.z * sn_0);
        }
        return shape_1;
    }
    if(kind_0 == 4U)
    {
        float _S468 = table_eval_0(info_2.w, (as_type<uint>((_S464.x))), tau_1, kernelContext_38);
        return _S468;
    }
    if(kind_0 == 5U)
    {
        (*kernelContext_38->g_seen_0)[1U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float sn_1 = tau_1 / _S464.x;
        if(sn_1 < 0.0f)
        {
            _S467 = true;
        }
        else
        {
            _S467 = sn_1 > 1.0f;
        }
        if(_S467)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = (1.0f - sn_1) * exp(- _S464.y * sn_1);
        }
        float clearing_0 = _S463.w;
        float relax_0;
        if(clearing_0 > 0.0f)
        {
            relax_0 = max(1.0f - tau_1 / clearing_0, 0.0f);
        }
        else
        {
            relax_0 = 0.0f;
        }
        float _S469 = _S464.w;
        return (_S469 + (_S464.z - _S469) * relax_0) * shape_1;
    }
    if(kind_0 == 7U)
    {
        (*kernelContext_38->g_seen_0)[2U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float _S470 = _S464.y;
        if(tau_1 < _S470)
        {
            return _S464.x;
        }
        float s_4 = tau_1 - _S470;
        float _S471 = _S464.w;
        if(s_4 > _S471)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S464.z * sin(3.14159274101257324f * s_4 / _S471);
        }
        return shape_1;
    }
    float _S472 = _S464.x;
    if(_S472 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp(1.0f - tau_1 / _S472, 0.0f, 1.0f);
}

void record_chunk_load_0(uint c_10, float3 f_3, float3 t_8, KernelContext_0 thread* kernelContext_39)
{
    if((kernelContext_39->params_0->solve_mode_0) == 0U)
    {
        return;
    }
    uint _S473 = 2U * c_10;
    *(kernelContext_39->scratch_0+(kernelContext_39->params_0->cload_base_0 + _S473)) = packed_float4(float4(f_3, 0.0f)) ;
    *(kernelContext_39->scratch_0+(kernelContext_39->params_0->cload_base_0 + _S473 + 1U)) = packed_float4(float4(t_8, 0.0f)) ;
    *(kernelContext_39->scratch_0+(kernelContext_39->params_0->cframe_base_0 + _S473)) = packed_float4(float4((float4(*(kernelContext_39->scratch_0+(kernelContext_39->params_0->cframe_base_0 + _S473))) ).xyz + f_3, 0.0f)) ;
    *(kernelContext_39->scratch_0+(kernelContext_39->params_0->cframe_base_0 + _S473 + 1U)) = packed_float4(float4((float4(*(kernelContext_39->scratch_0+(kernelContext_39->params_0->cframe_base_0 + _S473 + 1U))) ).xyz + t_8, 0.0f)) ;
    return;
}

void chunk_loads_0(uint _S474, uint _S475, const Quat_0 thread* _S476, uint _S477, float _S478, bool _S479, float _S480, float3 thread* _S481, float3 thread* _S482, float3 thread* _S483, float3 thread* _S484, KernelContext_0 thread* kernelContext_40)
{
    bool _S485;
    ChunkStatic_natural_0 device* _S486 = kernelContext_40->chunks_0+_S475;
    float3 _S487 = float3(0.0f) ;
    *_S481 = _S487;
    *_S482 = _S487;
    *_S483 = _S487;
    *_S484 = _S487;
    uint4 _S488 = uint4(_S486->load_range_0) ;
    uint term_1 = _S488.x;
    for(;;)
    {
        if(term_1 < (_S488.y))
        {
        }
        else
        {
            break;
        }
        (*kernelContext_40->g_seen_0)[0U] = 1U;
        uint _S489 = 5U * term_1;
        uint _S490 = (as_type<uint4>((float4(*(kernelContext_40->loads_0+_S489)) ))).y;
        bool replacement_0 = _S490 == 2U;
        float4 _S491 = float4(*(kernelContext_40->loads_0+(_S489 + 1U))) ;
        float4 _S492 = float4(*(kernelContext_40->loads_0+(_S489 + 2U))) ;
        float _S493;
        if(replacement_0)
        {
            _S493 = _S480;
        }
        else
        {
            _S493 = 0.0f;
        }
        float _S494 = eval_function_0(term_1, _S477, _S478, _S493, kernelContext_40);
        if(replacement_0)
        {
            float3 _S495 = float3(_S494) ;
            *_S483 = *_S483 + _S491.xyz * _S495;
            *_S484 = *_S484 + _S492.xyz * _S495;
            term_1 = term_1 + 1U;
            continue;
        }
        if(_S490 == 0U)
        {
            _S485 = true;
        }
        else
        {
            _S485 = _S490 == 3U;
        }
        float3 fw_0;
        if(_S485)
        {
            fw_0 = _S491.xyz * float3(_S494) ;
        }
        else
        {
            float3 _S496 = rotate_0(_S476, _S491.xyz);
            fw_0 = _S496 * float3((- _S494 * _S491.w)) ;
        }
        float3 lever_0;
        if(_S490 == 3U)
        {
            lever_0 = _S492.xyz - (float4(*(kernelContext_40->state_0+4U * _S474)) ).xyz;
        }
        else
        {
            lever_0 = _S492.xyz;
        }
        *_S481 = *_S481 + fw_0;
        float3 _S497 = rotate_0(_S476, lever_0);
        *_S482 = *_S482 + cross(_S497, fw_0);
        term_1 = term_1 + 1U;
    }
    if(_S479)
    {
        _S485 = ((uint4(_S486->cinfo_0) ).z) != 0U;
    }
    else
    {
        _S485 = false;
    }
    if(_S485)
    {
        uint4 _S498 = uint4(_S486->cinfo_0) ;
        uint g_1 = _S498.x;
        for(;;)
        {
            if(g_1 < (_S498.y))
            {
            }
            else
            {
                break;
            }
            uint _S499 = 2U * g_1;
            *_S481 = *_S481 + (float4(*(kernelContext_40->scratch_0+(kernelContext_40->params_0->seg_base_0 + _S499))) ).xyz;
            *_S482 = *_S482 + (float4(*(kernelContext_40->scratch_0+(kernelContext_40->params_0->seg_base_0 + _S499 + 1U))) ).xyz;
            g_1 = g_1 + 1U;
        }
    }
    return;
}

void chunk_external_0(uint _S500, uint _S501, const Quat_0 thread* _S502, uint _S503, float _S504, bool _S505, float3 thread* _S506, float3 thread* _S507, KernelContext_0 thread* kernelContext_41)
{
    thread float3 rf_1;
    thread float3 rm_0;
    chunk_loads_0(_S500, _S501, _S502, _S503, _S504, _S505, 0.0f, _S506, _S507, &rf_1, &rm_0, kernelContext_41);
    return;
}

float settled_chunk_load_0(uint c_11, const Quat_0 thread* rot_1, uint k_13, float dt_6, bool contact_0, KernelContext_0 thread* kernelContext_42)
{
    thread float3 f_4;
    thread float3 t_9;
    chunk_external_0(c_11, c_11, rot_1, k_13, dt_6, contact_0, &f_4, &t_9, kernelContext_42);
    record_chunk_load_0(c_11, f_4, t_9, kernelContext_42);
    return length(f_4);
}

void net_load_0(uint c_12, const Island_natural_0 thread* isl_4, const Rigid_0 thread* rg_2, uint k_14, float dt_7, bool contact_1, float3 thread* f_5, float3 thread* t_10, KernelContext_0 thread* kernelContext_43)
{
    ChunkStatic_natural_0 device* _S508 = kernelContext_43->chunks_0+c_12;
    thread float3 fl_0;
    thread float3 tl_0;
    thread float3 rep_f_0;
    thread float3 rep_m_0;
    chunk_loads_0(c_12, c_12, &rg_2->rot_0, k_14, dt_7, contact_1, 0.0f, &fl_0, &tl_0, &rep_f_0, &rep_m_0, kernelContext_43);
    float4 _S509 = float4(_S508->center_0) ;
    float3 fc_0 = fl_0 + kernelContext_43->params_0->gravity_0.xyz * float3(_S509.w) ;
    float3 _S510 = _S509.xyz;
    float3 _S511 = (float4(isl_4->com_0) ).xyz;
    float3 _S512 = rotate_0(&rg_2->rot_0, _S510 + (float4(*(kernelContext_43->state_0+4U * c_12)) ).xyz - _S511);
    *f_5 = *f_5 + fc_0;
    *t_10 = *t_10 + (cross(_S512, fc_0) + tl_0);
    uint4 _S513 = uint4(_S508->load_range_0) ;
    if((_S513.y) > (_S513.x))
    {
        float3 _S514 = rotate_0(&rg_2->rot_0, rep_f_0);
        *f_5 = *f_5 + _S514;
        float3 _S515 = rotate_0(&rg_2->rot_0, _S510 - _S511);
        float3 _S516 = cross(_S515, _S514);
        float3 _S517 = rotate_0(&rg_2->rot_0, rep_m_0);
        *t_10 = *t_10 + (_S516 + _S517);
    }
    return;
}

void net_load_1(uint c_13, const Island_0 thread* isl_5, const Rigid_0 thread* rg_3, uint k_15, float dt_8, bool contact_2, float3 thread* f_6, float3 thread* t_11, KernelContext_0 thread* kernelContext_44)
{
    ChunkStatic_natural_0 device* _S518 = kernelContext_44->chunks_0+c_13;
    thread float3 fl_1;
    thread float3 tl_1;
    thread float3 rep_f_1;
    thread float3 rep_m_1;
    chunk_loads_0(c_13, c_13, &rg_3->rot_0, k_15, dt_8, contact_2, 0.0f, &fl_1, &tl_1, &rep_f_1, &rep_m_1, kernelContext_44);
    float4 _S519 = float4(_S518->center_0) ;
    float3 fc_1 = fl_1 + kernelContext_44->params_0->gravity_0.xyz * float3(_S519.w) ;
    float3 _S520 = _S519.xyz;
    float3 _S521 = isl_5->com_0.xyz;
    float3 _S522 = rotate_0(&rg_3->rot_0, _S520 + (float4(*(kernelContext_44->state_0+4U * c_13)) ).xyz - _S521);
    *f_6 = *f_6 + fc_1;
    *t_11 = *t_11 + (cross(_S522, fc_1) + tl_1);
    uint4 _S523 = uint4(_S518->load_range_0) ;
    if((_S523.y) > (_S523.x))
    {
        float3 _S524 = rotate_0(&rg_3->rot_0, rep_f_1);
        *f_6 = *f_6 + _S524;
        float3 _S525 = rotate_0(&rg_3->rot_0, _S520 - _S521);
        float3 _S526 = cross(_S525, _S524);
        float3 _S527 = rotate_0(&rg_3->rot_0, rep_m_1);
        *t_11 = *t_11 + (_S526 + _S527);
    }
    return;
}

void rigid_acceleration_0(const Island_natural_0 thread* isl_6, Rigid_0 thread* rg_4, float3 f_7, float3 t_12)
{
    float4 _S528 = float4(isl_6->inertia0_0) ;
    float4 _S529 = float4(isl_6->inertia1_0) ;
    float4 _S530 = float4(isl_6->inertia2_0) ;
    thread Quat_0 _S531 = rg_4->rot_0;
    float3 _S532 = world_mul_0(&_S531, _S528, _S529, _S530, rg_4->w_4);
    rg_4->a_7 = f_7 / float3((float4(isl_6->com_0) ).w) ;
    float4 _S533 = float4(isl_6->inv0_0) ;
    float4 _S534 = float4(isl_6->inv1_0) ;
    float4 _S535 = float4(isl_6->inv2_0) ;
    float3 _S536 = t_12 - cross(rg_4->w_4, _S532);
    thread Quat_0 _S537 = rg_4->rot_0;
    float3 _S538 = world_mul_0(&_S537, _S533, _S534, _S535, _S536);
    rg_4->alpha_0 = _S538;
    rg_4->torque_0 = t_12;
    return;
}

void rigid_acceleration_1(const Island_0 thread* isl_7, Rigid_0 thread* rg_5, float3 f_8, float3 t_13)
{
    thread Quat_0 _S539 = rg_5->rot_0;
    float3 _S540 = world_mul_0(&_S539, isl_7->inertia0_0, isl_7->inertia1_0, isl_7->inertia2_0, rg_5->w_4);
    rg_5->a_7 = f_8 / float3(isl_7->com_0.w) ;
    float3 _S541 = t_13 - cross(rg_5->w_4, _S540);
    thread Quat_0 _S542 = rg_5->rot_0;
    float3 _S543 = world_mul_0(&_S542, isl_7->inv0_0, isl_7->inv1_0, isl_7->inv2_0, _S541);
    rg_5->alpha_0 = _S543;
    rg_5->torque_0 = t_13;
    return;
}

bool is_damaged_0(const JointState_0 thread* st_0)
{
    bool _S544;
    if((st_0->damage_0) > 0.0f)
    {
        _S544 = true;
    }
    else
    {
        _S544 = (st_0->crush_1) > 0.0f;
    }
    return _S544;
}

bool connected_0(const JointState_0 thread* st_1, bool has_rebar_0)
{
    bool _S545;
    if((st_1->damage_0) < 1.0f)
    {
        _S545 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S545 = (st_1->rebar_broken_0) == 0.0f;
        }
        else
        {
            _S545 = false;
        }
    }
    return _S545;
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
    float4 _S546 = float4(b_23->geom0_0) ;
    float area_2 = _S546.x;
    float _S547 = q_lin_0.z;
    float axial_0 = (metal::fast::divide((_S547), (area_2)));
    float4 _S548 = float4(b_23->geom1_0) ;
    float _S549 = (metal::fast::divide((abs(q_ang_0.x)), (_S548.x)));
    float _S550 = (metal::fast::divide((abs(q_ang_0.y)), (_S548.y)));
    float bending_0 = _S549 + _S550;
    float _S551 = q_lin_0.x;
    float _S552 = q_lin_0.y;
    float _S553 = (metal::fast::sqrt((_S551 * _S551 + _S552 * _S552)));
    float _S554 = (metal::fast::divide((_S553), (area_2)));
    float _S555 = (metal::fast::divide((abs(q_ang_0.z)), (_S546.w)));
    float shear_1 = _S554 + _S555;
    thread Measures_0 m_3;
    (&m_3)->tension_0 = axial_0 + bending_0;
    (&m_3)->shear_0 = shear_1;
    float _S556 = - axial_0;
    (&m_3)->normal_compression_0 = max(_S556, 0.0f);
    (&m_3)->compression_0 = _S556 + bending_0;
    (&m_3)->compressive_force_0 = max(- _S547, 0.0f);
    return m_3;
}

float expm1_accurate_0(float x_7)
{
    if((abs(x_7)) < 0.00100000004749745f)
    {
        return x_7 * (1.0f + x_7 * (0.5f + x_7 * 0.1666666716337204f));
    }
    return exp(x_7) - 1.0f;
}

float dif_factor_0(const JointMaterial_0 constant* mat_1, float strain_rate_1)
{
    float r_6 = abs(strain_rate_1);
    float4 _S557 = mat_1->dif_0;
    float ref_0 = mat_1->dif_0.x;
    if(r_6 <= ref_0)
    {
        return 1.0f;
    }
    float _S558 = _S557.z;
    float f_9;
    if(r_6 <= _S558)
    {
        float _S559 = (metal::fast::divide((r_6), (ref_0)));
        float _S560 = (metal::fast::pow((_S559), (_S557.y)));
        f_9 = _S560;
    }
    else
    {
        float _S561 = (metal::fast::divide((_S558), (ref_0)));
        float _S562 = (metal::fast::pow((_S561), (_S557.y)));
        float _S563 = (metal::fast::divide((r_6), (_S558)));
        float _S564 = (metal::fast::pow((_S563), (_S557.w)));
        f_9 = _S562 * _S564;
    }
    return clamp(f_9, 1.0f, mat_1->misc_0.x);
}

float fatigue_factor_0(const JointMaterial_0 constant* mat_2, float life_1)
{
    if(((mat_2->kind_flags_0.y) & 64U) == 0U)
    {
        return 1.0f;
    }
    float _S565 = clamp(life_1, 0.0f, 1.0f);
    float _S566 = (metal::fast::divide((1.0f), (mat_2->misc_0.y - 2.0f)));
    float _S567 = (metal::fast::pow((_S565), (_S566)));
    return _S567;
}

float infinity_0()
{
    return (as_type<float>((2139095040U)));
}

float4 failure_indices_0(const JointMaterial_0 constant* mat_3, const JointBond_natural_0 thread* b_24, const Measures_0 thread* m_4, float multiplier_0)
{
    float fc_2 = mat_3->strength_0.y * multiplier_0;
    float _S568 = min(mat_3->strength_0.z * multiplier_0 + mat_3->strength_0.w * m_4->normal_compression_0, mat_3->energy_1.x * multiplier_0);
    thread float4 idx_0;
    float _S569 = (metal::fast::divide((m_4->tension_0), (mat_3->strength_0.x * multiplier_0)));
    idx_0.x = max(_S569, 0.0f);
    float _S570;
    if(_S568 > 0.0f)
    {
        float _S571 = (metal::fast::divide((m_4->shear_0), (_S568)));
        _S570 = _S571;
    }
    else
    {
        _S570 = infinity_0();
    }
    idx_0.y = _S570;
    float _S572 = (metal::fast::divide((m_4->compression_0), (fc_2)));
    idx_0.z = max(_S572, 0.0f);
    float _S573 = (float4(b_24->stiff1_0) ).y;
    if(_S573 > 0.0f)
    {
        float _S574 = (metal::fast::divide((m_4->compressive_force_0), (_S573)));
        _S570 = _S574;
    }
    else
    {
        _S570 = 0.0f;
    }
    idx_0.w = _S570;
    return idx_0;
}

float sq_0(float x_8)
{
    return x_8 * x_8;
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
        float _S575 = (metal::fast::divide((r_7 * (kappa_1 - 1.0f)), (kappa_1 * (r_7 - 1.0f))));
        return min(_S575, 1.0f);
    }
    if(kappa_1 >= (0.5f * (r_7 + 1.0f)))
    {
        return 1.0f;
    }
    float _S576 = (metal::fast::divide((1.0f), (kappa_1)));
    return 1.0f - _S576;
}

__attribute__((noinline))
float2 damage_increment_0(uint kind_2, float kappa_old_0, float lambda_0, float r_8, float d_old_0, float psi_0)
{
    float _S577 = damage_law_0(kind_2, lambda_0, r_8);
    float _S578 = max(_S577, d_old_0);
    bool _S579;
    if(_S578 <= d_old_0)
    {
        _S579 = true;
    }
    else
    {
        _S579 = d_old_0 >= 1.0f;
    }
    if(_S579)
    {
        return float2(d_old_0, 0.0f);
    }
    float u0_0 = (metal::fast::divide((psi_0), (lambda_0 * lambda_0)));
    float _S580 = max(kappa_old_0, 1.0f);
    if(kind_2 == 0U)
    {
        if(r_8 > 1.0f)
        {
            float _S581 = (metal::fast::divide((u0_0 * r_8), (r_8 - 1.0f)));
            return float2(_S578, _S581 * max(min(lambda_0, r_8) - min(_S580, r_8), 0.0f));
        }
        return float2(_S578, (1.0f - d_old_0) * psi_0);
    }
    float ku_0 = 0.5f * (r_8 + 1.0f);
    float plateau_0 = u0_0 * max(min(lambda_0, ku_0) - min(_S580, ku_0), 0.0f);
    float snap_0;
    if(_S578 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return float2(_S578, plateau_0 + snap_0);
}

void compressed_region_0(float w0_0, float w1_0, float dz_0, float ax_0, float ay_0, array<float, int(6)> thread* region_0)
{
    uint count_3;
    float h0_0 = 0.5f * w0_0;
    float h1_0 = 0.5f * w1_0;
    float _S582 = - h0_0;
    float _S583 = - h1_0;
    array<float2, int(4)> _S584 = { { float2(_S582, _S583), float2(h0_0, _S583), float2(h0_0, h1_0), float2(_S582, h1_0) } };
    thread array<float2, int(8)> poly_0;
    uint i_6 = 0U;
    uint count_4 = 0U;
    for(;;)
    {
        if(i_6 < 4U)
        {
        }
        else
        {
            break;
        }
        uint _S585 = i_6;
        uint _S586 = i_6 + 1U;
        uint _S587 = _S586 % 4U;
        float _S588 = _S584[i_6].y;
        float _S589 = _S584[i_6].x;
        float fp_0 = dz_0 + ax_0 * _S588 - ay_0 * _S589;
        float _S590 = _S584[_S587].y;
        float _S591 = _S584[_S587].x;
        float fq_0 = dz_0 + ax_0 * _S590 - ay_0 * _S591;
        bool _S592 = fp_0 < 0.0f;
        if(_S592)
        {
            uint _S593 = count_4 + 1U;
            poly_0[count_4] = _S584[_S585];
            count_3 = _S593;
        }
        else
        {
            count_3 = count_4;
        }
        if(_S592 != (fq_0 < 0.0f))
        {
            float t_14 = fp_0 / (fp_0 - fq_0);
            uint _S594 = count_3 + 1U;
            poly_0[count_3] = float2(_S589 + t_14 * (_S591 - _S589), _S588 + t_14 * (_S590 - _S588));
            count_4 = _S594;
        }
        else
        {
            count_4 = count_3;
        }
        i_6 = _S586;
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
    i_6 = 0U;
    float a_8 = 0.0f;
    float sx_0 = 0.0f;
    float sy_0 = 0.0f;
    float ixx_0 = 0.0f;
    float iyy_0 = 0.0f;
    float ixy_0 = 0.0f;
    for(;;)
    {
        if(i_6 < count_4)
        {
        }
        else
        {
            break;
        }
        float _S595 = o_1.x;
        float x0_0 = poly_0[i_6].x - _S595;
        float _S596 = o_1.y;
        float y0_0 = poly_0[i_6].y - _S596;
        uint _S597 = i_6 + 1U;
        uint _S598 = _S597 % count_4;
        float x1_0 = poly_0[_S598].x - _S595;
        float y1_0 = poly_0[_S598].y - _S596;
        float _S599 = x0_0 * y1_0;
        float _S600 = x1_0 * y0_0;
        float cr_0 = _S599 - _S600;
        float a_9 = a_8 + cr_0 / 2.0f;
        float sx_1 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        float sy_1 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        float ixx_1 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        float iyy_1 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        float ixy_1 = ixy_0 + (_S599 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S600) * cr_0 / 24.0f;
        i_6 = _S597;
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
    float _S601 = a_8 * cx_0;
    (*region_0)[int(3)] = ixx_0 - _S601 * cx_0;
    (*region_0)[int(4)] = iyy_0 - a_8 * cy_0 * cy_0;
    (*region_0)[int(5)] = ixy_0 - _S601 * cy_0;
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
    float _S602 = a_10 * fc_3;
    float _S603 = - ay_1;
    return float4(k_16 * a_10 * fc_3, k_16 * (_S602 * r_9[int(2)] + (_S603 * r_9[int(5)] + ax_1 * r_9[int(4)])), - k_16 * (_S602 * r_9[int(1)] + (_S603 * r_9[int(3)] + ax_1 * r_9[int(5)])), 0.5f * k_16 * (_S602 * fc_3 + ay_1 * ay_1 * r_9[int(3)] + ax_1 * ax_1 * r_9[int(4)] - 2.0f * ax_1 * ay_1 * r_9[int(5)]));
}

float signum_0(float x_9)
{
    float _S604;
    if(((as_type<uint>((x_9))) & 2147483648U) != 0U)
    {
        _S604 = -1.0f;
    }
    else
    {
        _S604 = 1.0f;
    }
    return _S604;
}

float2 return_map_0(float k_17, float total_2, float plastic_0, float cap_0)
{
    float trial_0 = k_17 * (total_2 - plastic_0);
    if((abs(trial_0)) <= cap_0)
    {
        return float2(trial_0, 0.0f);
    }
    float f_10 = cap_0 * signum_0(trial_0);
    float _S605 = (metal::fast::divide((trial_0 - f_10), (k_17)));
    return float2(f_10, _S605);
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
    float3 _S606 = float3(0.0f) ;
    (&c_14)->q_lin_1 = _S606;
    (&c_14)->q_ang_1 = _S606;
    (&c_14)->energy_2 = 0.0f;
    (&c_14)->diss_4 = 0.0f;
    (&c_14)->plastic_1 = plastic_2;
    uint _S607 = mat_4->kind_flags_0.y;
    if((_S607 & 2U) == 0U)
    {
        return c_14;
    }
    float4 _S608 = float4(b_25->stiff0_0) ;
    float kn_1 = _S608.x;
    float ks_0 = _S608.y;
    float kt_0 = (float4(b_25->stiff1_0) ).x;
    float4 _S609 = float4(b_25->geom0_0) ;
    float w0_2 = _S609.y;
    float w1_2 = _S609.z;
    float diss_5;
    float nc_sum_0;
    float m1_0;
    float m2_0;
    float energy_3;
    if((_S607 & 4U) != 0U)
    {
        float4 p_11 = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        float _S610 = p_11.y;
        float _S611 = p_11.z;
        float _S612 = p_11.w;
        nc_sum_0 = p_11.x;
        m1_0 = _S610;
        m2_0 = _S611;
        energy_3 = _S612;
    }
    else
    {
        float ki_0 = kn_1 * (1.0f - crush_2) / 36.0f;
        float _S613 = d_ang_0.x;
        float _S614 = d_ang_0.y;
        float spread_0 = abs(_S613) * 0.4166666567325592f * w1_2 + abs(_S614) * 0.4166666567325592f * w0_2;
        float _S615 = d_lin_0.z;
        float slack_0 = 9.99999997475242708e-07f * (abs(_S615) + spread_0);
        if((_S615 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S615 + spread_0) < (- slack_0))
            {
                float i1_0 = 2.91666650772094727f * w0_2 * w0_2;
                float i2_0 = 2.91666650772094727f * w1_2 * w1_2;
                float _S616 = ki_0 * _S613 * i2_0;
                float _S617 = ki_0 * _S614 * i1_0;
                float _S618 = 0.5f * ki_0 * (36.0f * _S615 * _S615 + _S613 * _S613 * i2_0 + _S614 * _S614 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S615;
                m1_0 = _S616;
                m2_0 = _S617;
                energy_3 = _S618;
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
                    float _S619 = SPRING_AT_0[i_7] * w0_2;
                    uint j_5 = 0U;
                    nc_sum_0 = diss_5;
                    m1_0 = m1_1;
                    m2_0 = m2_1;
                    energy_3 = energy_4;
                    for(;;)
                    {
                        if(j_5 < 6U)
                        {
                        }
                        else
                        {
                            break;
                        }
                        float s2_0 = SPRING_AT_0[j_5] * w1_2;
                        float di_0 = _S615 + _S613 * s2_0 - _S614 * _S619;
                        if(di_0 < 0.0f)
                        {
                            float f_11 = ki_0 * di_0;
                            float m1_2 = m1_0 + f_11 * s2_0;
                            float m2_2 = m2_0 - f_11 * _S619;
                            float energy_5 = energy_3 + 0.5f * ki_0 * di_0 * di_0;
                            nc_sum_0 = nc_sum_0 + f_11;
                            m1_0 = m1_2;
                            m2_0 = m2_2;
                            energy_3 = energy_5;
                        }
                        j_5 = j_5 + 1U;
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
    float _S620 = ks_0 * (d_lin_0.x - plastic_2.x);
    float _S621 = ks_0 * (d_lin_0.y - plastic_2.y);
    float tn_0 = (metal::fast::sqrt((_S620 * _S620 + _S621 * _S621)));
    bool _S622;
    if(tn_0 > slide_cap_0)
    {
        _S622 = tn_0 > 0.0f;
    }
    else
    {
        _S622 = false;
    }
    if(_S622)
    {
        float _S623 = (metal::fast::divide((_S620), (tn_0)));
        float _S624 = (metal::fast::divide((_S621), (tn_0)));
        float dslip_0 = (metal::fast::divide((tn_0 - slide_cap_0), (ks_0)));
        p_12.x = p_12.x + _S623 * dslip_0;
        p_12.y = p_12.y + _S624 * dslip_0;
        (&c_14)->q_lin_1.x = _S623 * slide_cap_0;
        (&c_14)->q_lin_1.y = _S624 * slide_cap_0;
        diss_5 = slide_cap_0 * dslip_0;
    }
    else
    {
        (&c_14)->q_lin_1.x = _S620;
        (&c_14)->q_lin_1.y = _S621;
        diss_5 = 0.0f;
    }
    float2 tq_0 = return_map_0(kt_0, d_ang_0.z, p_12.z, slide_cap_0 * (float4(b_25->geom1_0) ).z);
    float _S625 = tq_0.x;
    float _S626 = tq_0.y;
    float diss_6 = diss_5 + abs(_S625) * abs(_S626);
    p_12.z = p_12.z + _S626;
    (&c_14)->q_ang_1.z = _S625;
    float _S627 = (metal::fast::divide((sq_0((&c_14)->q_lin_1.x)), (ks_0)));
    float _S628 = (metal::fast::divide((sq_0((&c_14)->q_lin_1.y)), (ks_0)));
    float _S629 = _S627 + _S628;
    float _S630 = (metal::fast::divide((sq_0(_S625)), (kt_0)));
    (&c_14)->energy_2 = energy_3 + 0.5f * (_S629 + _S630);
    (&c_14)->diss_4 = diss_6;
    (&c_14)->plastic_1 = p_12;
    return c_14;
}

float3 contact_offsets_0(const JointMaterial_0 constant* mat_5, const JointBond_natural_0 thread* b_26, float crush_3, float3 plastic_3, float3 d_lin_1, float3 d_ang_1)
{
    uint _S631 = mat_5->kind_flags_0.y;
    if((_S631 & 2U) == 0U)
    {
        return plastic_3;
    }
    float4 _S632 = float4(b_26->stiff0_0) ;
    float kn_2 = _S632.x;
    float ks_1 = _S632.y;
    float kt_1 = (float4(b_26->stiff1_0) ).x;
    float4 _S633 = float4(b_26->geom0_0) ;
    float w0_3 = _S633.y;
    float w1_3 = _S633.z;
    float nc_sum_1;
    if((_S631 & 4U) != 0U)
    {
        float4 _S634 = no_tension_patch_0(kn_2 * (1.0f - crush_3), w0_3, w1_3, d_lin_1.z, d_ang_1.x, d_ang_1.y);
        nc_sum_1 = _S634.x;
    }
    else
    {
        float ki_1 = kn_2 * (1.0f - crush_3) / 36.0f;
        float _S635 = d_ang_1.x;
        float _S636 = d_ang_1.y;
        float spread_1 = abs(_S635) * 0.4166666567325592f * w1_3 + abs(_S636) * 0.4166666567325592f * w0_3;
        float _S637 = d_lin_1.z;
        float slack_1 = 9.99999997475242708e-07f * (abs(_S637) + spread_1);
        if((_S637 - spread_1) > slack_1)
        {
            nc_sum_1 = 0.0f;
        }
        else
        {
            if((_S637 + spread_1) < (- slack_1))
            {
                nc_sum_1 = ki_1 * 36.0f * _S637;
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
                    float _S638 = SPRING_AT_0[i_8] * w0_3;
                    uint j_6 = 0U;
                    nc_sum_1 = nc_sum_2;
                    for(;;)
                    {
                        if(j_6 < 6U)
                        {
                        }
                        else
                        {
                            break;
                        }
                        float di_1 = _S637 + _S635 * (SPRING_AT_0[j_6] * w1_3) - _S636 * _S638;
                        if(di_1 < 0.0f)
                        {
                            nc_sum_1 = nc_sum_1 + ki_1 * di_1;
                        }
                        j_6 = j_6 + 1U;
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
    float _S639 = ks_1 * (d_lin_1.x - plastic_3.x);
    float _S640 = ks_1 * (d_lin_1.y - plastic_3.y);
    float tn_1 = (metal::fast::sqrt((_S639 * _S639 + _S640 * _S640)));
    bool _S641;
    if(tn_1 > slide_cap_1)
    {
        _S641 = tn_1 > 0.0f;
    }
    else
    {
        _S641 = false;
    }
    if(_S641)
    {
        float _S642 = (metal::fast::divide((_S639), (tn_1)));
        float _S643 = (metal::fast::divide((_S640), (tn_1)));
        float dslip_1 = (metal::fast::divide((tn_1 - slide_cap_1), (ks_1)));
        p_13.x = p_13.x + _S642 * dslip_1;
        p_13.y = p_13.y + _S643 * dslip_1;
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
    float _S644 = mat_6->misc_0.y;
    float _S645 = _S644 + 1.0f;
    float _S646 = (metal::fast::pow((s_5), (_S644)));
    float _S647 = (metal::fast::divide((_S645 * _S646), (mat_6->misc_0.z)));
    return _S647;
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
    float4 _S648 = float4(b_27->stiff0_0) ;
    float kn_3 = _S648.x;
    float ks_2 = _S648.y;
    float kb1_0 = _S648.z;
    float kb2_0 = _S648.w;
    float4 _S649 = float4(b_27->stiff1_0) ;
    float kt_2 = _S649.x;
    bool has_rebar_1 = (_S649.w) != 0.0f;
    uint kind_3 = mat_7->kind_flags_0.x;
    uint flags_1 = mat_7->kind_flags_0.y;
    bool softening_0 = (flags_1 & 1U) != 0U;
    thread JointState_0 st_2 = *state_7;
    bool _S650 = connected_0(state_7, has_rebar_1);
    float3 qe_lin_0 = d_lin_2 * float3(ks_2, ks_2, kn_3);
    float3 qe_ang_0 = d_ang_2 * float3(kb1_0, kb2_0, kt_2);
    Measures_0 _S651 = stress_measures_0(b_27, qe_lin_0, qe_ang_0);
    float _S652 = max(max(_S651.tension_0, _S651.shear_0), _S651.compression_0);
    bool _S653 = dt_9 > 0.0f;
    float dif_1;
    if(_S653)
    {
        float _S654 = (metal::fast::divide((_S652 - (&st_2)->governing_stress_0), (dt_9)));
        float raw_0 = (metal::fast::divide((max(_S654, 0.0f)), (mat_7->misc_0.w)));
        float tau_2 = _S649.z;
        if((flags_1 & 16U) != 0U)
        {
            float _S655 = (metal::fast::divide((dt_9), (tau_2)));
            dif_1 = - expm1_accurate_0(- _S655);
        }
        else
        {
            float _S656 = (metal::fast::divide((dt_9), (tau_2)));
            dif_1 = min(_S656, 1.0f);
        }
        (&st_2)->strain_rate_0 = (&st_2)->strain_rate_0 + (raw_0 - (&st_2)->strain_rate_0) * dif_1;
        (&st_2)->governing_stress_0 = _S652;
    }
    if((flags_1 & 32U) != 0U)
    {
        float _S657 = dif_factor_0(mat_7, (&st_2)->strain_rate_0);
        dif_1 = _S657;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = (float4(b_27->geom1_0) ).w;
    float _S658 = fatigue_factor_0(mat_7, (&st_2)->life_0);
    float multiplier_1 = weibull_0 * dif_1 * _S658;
    thread Measures_0 _S659 = _S651;
    float4 _S660 = failure_indices_0(mat_7, b_27, &_S659, multiplier_1);
    float _S661 = _S660.x;
    float _S662 = _S660.y;
    (&st_2)->utilization_0 = max(max(_S661, _S662), max(_S660.z, _S660.w));
    float _S663 = d_lin_2.x;
    float _S664 = d_lin_2.y;
    float _S665 = ks_2 * (sq_0(_S663) + sq_0(_S664)) + kb1_0 * sq_0(d_ang_2.x) + kb2_0 * sq_0(d_ang_2.y) + kt_2 * sq_0(d_ang_2.z);
    float _S666 = d_lin_2.z;
    bool _S667 = _S666 > 0.0f;
    if(_S667)
    {
        dif_1 = kn_3 * sq_0(_S666);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S665 + dif_1);
    float psi_c_0;
    if(_S666 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_3 * sq_0(_S666);
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
    bool _S668;
    float3 qc_lin_0;
    if(fracture_1)
    {
        bool _S669 = _S661 >= _S662;
        if(_S669)
        {
            diss_contact_0 = _S661;
        }
        else
        {
            diss_contact_0 = _S662;
        }
        uint mode_ts_0;
        if(_S669)
        {
            mode_ts_0 = 1U;
        }
        else
        {
            mode_ts_0 = 2U;
        }
        if(diss_contact_0 > ((&st_2)->kappa_0))
        {
            _S668 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S668 = false;
        }
        if(_S668)
        {
            _S668 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S668 = false;
        }
        uint mode_c_0;
        if(_S668)
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
                float _S670 = (metal::fast::divide((psi_contact_0 * (float4(b_27->geom0_0) ).x * diss_contact_0 * diss_contact_0), (psi_ts_0)));
                intact_normal_0 = _S670;
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
            float _S671 = inc_0.x;
            if(_S671 > ((&st_2)->damage_0))
            {
                Contact_0 _S672 = contact_part_0(mat_7, b_27, (&st_2)->crush_1, plastic_4, d_lin_2, d_ang_2);
                float _S673 = max(_S672.energy_2 - (1.0f - (&st_2)->crush_1) * psi_c_0, 0.0f);
                float _S674 = max(inc_0.y - _S673 * (_S671 - (&st_2)->damage_0), 0.0f);
                float _S675 = max((psi_ts_0 - _S673) * (_S671 - (&st_2)->damage_0) - _S674, 0.0f);
                (&st_2)->damage_0 = _S671;
                (&st_2)->mode_0 = mode_ts_0;
                dissipated_3 = _S674;
                overshoot_1 = _S675;
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
        float _S676 = state_7->damage_0;
        if((state_7->damage_0) > 0.0f)
        {
            Contact_0 _S677 = contact_part_0(mat_7, b_27, state_7->crush_1, float3(state_7->plastic_x_0, state_7->plastic_y_0, state_7->plastic_t_0), d_lin_2, d_ang_2);
            qc_lin_0 = qe_ang_0 * float3((1.0f - _S676))  + _S677.q_ang_1 * float3(_S676) ;
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S678 = stress_measures_0(b_27, float3(0.0f, 0.0f, min(qe_lin_0.z, 0.0f)), qc_lin_0);
        thread Measures_0 _S679 = _S678;
        float4 _S680 = failure_indices_0(mat_7, b_27, &_S679, multiplier_1);
        float _S681 = _S680.z;
        float _S682 = _S680.w;
        bool _S683 = _S681 >= _S682;
        if(_S683)
        {
            psi_contact_0 = _S681;
        }
        else
        {
            psi_contact_0 = _S682;
        }
        if(_S683)
        {
            mode_c_0 = 3U;
        }
        else
        {
            mode_c_0 = 4U;
        }
        if(psi_contact_0 > ((&st_2)->kappa_c_0))
        {
            _S668 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S668 = false;
        }
        if(_S668)
        {
            _S668 = psi_c_0 > 0.0f;
        }
        else
        {
            _S668 = false;
        }
        if(_S668)
        {
            if(softening_0)
            {
                float _S684 = (metal::fast::divide((mat_7->energy_1.w * (float4(b_27->geom0_0) ).x * psi_contact_0 * psi_contact_0), (psi_c_0)));
                intact_normal_0 = _S684;
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
            float _S685 = inc_1.x;
            if(_S685 > ((&st_2)->crush_1))
            {
                float _S686 = inc_1.y;
                float dissipated_4 = dissipated_3 + _S686;
                float overshoot_2 = overshoot_1 + max(psi_c_0 * (_S685 - (&st_2)->crush_1) - _S686, 0.0f);
                (&st_2)->crush_1 = _S685;
                (&st_2)->mode_0 = mode_c_0;
                if(_S685 >= 1.0f)
                {
                    _S668 = ((&st_2)->damage_0) < 1.0f;
                }
                else
                {
                    _S668 = false;
                }
                if(_S668)
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
    float3 _S687 = float3(0.0f) ;
    float3 qc_ang_0;
    if(((&st_2)->damage_0) == 0.0f)
    {
        if((flags_1 & 8U) == 0U)
        {
            float3 _S688 = contact_offsets_0(mat_7, b_27, (&st_2)->crush_1, plastic_4, d_lin_2, d_ang_2);
            (&st_2)->plastic_x_0 = _S688.x;
            (&st_2)->plastic_y_0 = _S688.y;
            (&st_2)->plastic_t_0 = _S688.z;
        }
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S687;
        qc_ang_0 = _S687;
        psi_contact_0 = 0.0f;
    }
    else
    {
        Contact_0 _S689 = contact_part_0(mat_7, b_27, (&st_2)->crush_1, plastic_4, d_lin_2, d_ang_2);
        (&st_2)->plastic_x_0 = _S689.plastic_1.x;
        (&st_2)->plastic_y_0 = _S689.plastic_1.y;
        (&st_2)->plastic_t_0 = _S689.plastic_1.z;
        diss_contact_0 = _S689.diss_4;
        qc_lin_0 = _S689.q_lin_1;
        qc_ang_0 = _S689.q_ang_1;
        psi_contact_0 = _S689.energy_2;
    }
    float dissipated_6 = dissipated_3 + dmg_0 * diss_contact_0;
    if(_S667)
    {
        intact_normal_0 = kn_3 * _S666;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_2)->crush_1) * kn_3 * _S666;
    }
    float _S690 = 1.0f - dmg_0;
    float3 force_lin_2 = float3(_S690 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S690 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S690 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3 force_ang_2 = qe_ang_0 * float3(_S690)  + qc_ang_0 * float3(dmg_0) ;
    float stored_6 = _S690 * (psi_ts_0 + (1.0f - (&st_2)->crush_1) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S668 = ((&st_2)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S668 = false;
    }
    float stored_7;
    float3 force_lin_3;
    if(_S668)
    {
        float4 _S691 = float4(b_27->rebar0_0) ;
        float k_axial_0 = _S691.x;
        float k_dowel_0 = _S691.y;
        float yield_force_0 = _S691.z;
        float dowel_capacity_0 = _S691.w;
        float2 nr_0 = return_map_0(k_axial_0, _S666, (&st_2)->rebar_plastic_0, yield_force_0);
        float2 v1_0 = return_map_0(k_dowel_0, _S663, (&st_2)->rebar_slip0_0, dowel_capacity_0);
        float2 v2_0 = return_map_0(k_dowel_0, _S664, (&st_2)->rebar_slip1_0, dowel_capacity_0);
        float _S692 = nr_0.y;
        float _S693 = v1_0.y;
        float _S694 = v2_0.y;
        float work_0 = yield_force_0 * abs(_S692) + dowel_capacity_0 * (abs(_S693) + abs(_S694));
        (&st_2)->rebar_plastic_0 = (&st_2)->rebar_plastic_0 + _S692;
        (&st_2)->rebar_slip0_0 = (&st_2)->rebar_slip0_0 + _S693;
        (&st_2)->rebar_slip1_0 = (&st_2)->rebar_slip1_0 + _S694;
        (&st_2)->rebar_work_0 = (&st_2)->rebar_work_0 + work_0;
        float dissipated_7 = dissipated_6 + work_0;
        float _S695 = nr_0.x;
        float _S696 = (metal::fast::divide((sq_0(_S695)), (k_axial_0)));
        float _S697 = v1_0.x;
        float _S698 = v2_0.x;
        float _S699 = (metal::fast::divide((sq_0(_S697) + sq_0(_S698)), (k_dowel_0)));
        float elastic_0 = 0.5f * (_S696 + _S699);
        if(fracture_1)
        {
            _S668 = ((&st_2)->rebar_work_0) >= ((float4(b_27->rebar1_0) ).x);
        }
        else
        {
            _S668 = false;
        }
        if(_S668)
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
            force_lin_3 = force_lin_2 + float3(_S697, _S698, _S695);
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
        _S668 = _S653;
    }
    else
    {
        _S668 = false;
    }
    if(_S668)
    {
        _S668 = (flags_1 & 64U) != 0U;
    }
    else
    {
        _S668 = false;
    }
    if(_S668)
    {
        Measures_0 _S700 = stress_measures_0(b_27, force_lin_3, force_ang_2);
        thread Measures_0 _S701 = _S700;
        float4 _S702 = failure_indices_0(mat_7, b_27, &_S701, weibull_0);
        float _S703 = life_rate_0(mat_7, max(max(_S702.x, _S702.y), _S702.z));
        (&st_2)->life_0 = max((&st_2)->life_0 - _S703 * dt_9, 0.0f);
    }
    (&st_2)->dissipated_0 = (&st_2)->dissipated_0 + dissipated_3;
    thread JointResponse_0 resp_0;
    (&resp_0)->force_lin_1 = force_lin_3;
    (&resp_0)->force_ang_1 = force_ang_2;
    (&resp_0)->state_6 = st_2;
    (&resp_0)->dissipated_2 = dissipated_3;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_5 = stored_7;
    if(_S650)
    {
        thread JointState_0 _S704 = st_2;
        bool _S705 = connected_0(&_S704, has_rebar_1);
        _S668 = !_S705;
    }
    else
    {
        _S668 = false;
    }
    (&resp_0)->disconnected_0 = _S668;
    (&resp_0)->fatigue_before_0 = _S658;
    (&resp_0)->measures_0 = _S651;
    return resp_0;
}

void secant_factors_0(const JointBond_natural_0 thread* b_28, const JointState_0 thread* st_3, float3 d_lin_3, float3 thread* f_lin_0, float3 thread* f_ang_0)
{
    float _S706 = st_3->damage_0;
    bool compressed_0 = (d_lin_3.z) < 0.0f;
    float contact_3;
    if(compressed_0)
    {
        contact_3 = _S706;
    }
    else
    {
        contact_3 = 0.0f;
    }
    float _S707 = 1.0f - _S706;
    float _S708 = max(_S707 + contact_3, 9.99999997475242708e-07f);
    float normal_5;
    if(compressed_0)
    {
        normal_5 = max(1.0f - st_3->crush_1, 9.99999997475242708e-07f);
    }
    else
    {
        normal_5 = max(_S707, 9.99999997475242708e-07f);
    }
    *f_lin_0 = float3(_S708, _S708, normal_5);
    *f_ang_0 = float3(_S708) ;
    bool _S709;
    if(((float4(b_28->stiff1_0) ).w) != 0.0f)
    {
        _S709 = (st_3->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S709 = false;
    }
    if(_S709)
    {
        float4 _S710 = float4(b_28->rebar0_0) ;
        float4 _S711 = float4(b_28->stiff0_0) ;
        float _S712 = (metal::fast::divide((_S710.x), (_S711.x)));
        (*f_lin_0).z = (*f_lin_0).z + _S712;
        float _S713 = _S710.y;
        float _S714 = _S711.y;
        float _S715 = (metal::fast::divide((_S713), (_S714)));
        (*f_lin_0).x = (*f_lin_0).x + _S715;
        float _S716 = (metal::fast::divide((_S713), (_S714)));
        (*f_lin_0).y = (*f_lin_0).y + _S716;
    }
    return;
}

float3 to_local_0(uint _S717, float3 _S718, KernelContext_0 thread* kernelContext_45)
{
    BondStatic_natural_0 device* _S719 = kernelContext_45->bonds_0+_S717;
    return float3(dot(_S718, (float4(_S719->t1_0) ).xyz), dot(_S718, (float4(_S719->t2_0) ).xyz), dot(_S718, (float4(_S719->normal_0) ).xyz));
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

float3 to_body_0(uint _S720, float3 _S721, KernelContext_0 thread* kernelContext_46)
{
    BondStatic_natural_0 device* _S722 = kernelContext_46->bonds_0+_S720;
    return (float4(_S722->t1_0) ).xyz * float3(_S721.x)  + (float4(_S722->t2_0) ).xyz * float3(_S721.y)  + (float4(_S722->normal_0) ).xyz * float3(_S721.z) ;
}

bool bond_update_0(uint i_9, float dt_10, bool fracture_2, uint abs_step_0, bool wide_0, KernelContext_0 thread* kernelContext_47)
{
    BondStatic_natural_0 device* _S723 = kernelContext_47->bonds_0+i_9;
    uint4 _S724 = uint4(_S723->law_0.ids_0) ;
    float3 ra_1 = (float4(_S723->ra_0) ).xyz;
    float3 rb_1 = (float4(_S723->rb_0) ).xyz;
    uint _S725 = 4U * _S724.y;
    float3 ta_2 = (float4(*(kernelContext_47->state_0+(_S725 + 1U))) ).xyz;
    float3 va_0 = (float4(*(kernelContext_47->state_0+(_S725 + 2U))) ).xyz;
    float3 wa_1 = (float4(*(kernelContext_47->state_0+(_S725 + 3U))) ).xyz;
    uint _S726 = 4U * _S724.z;
    float3 tb_2 = (float4(*(kernelContext_47->state_0+(_S726 + 1U))) ).xyz;
    float3 vb_0 = (float4(*(kernelContext_47->state_0+(_S726 + 2U))) ).xyz;
    float3 wb_1 = (float4(*(kernelContext_47->state_0+(_S726 + 3U))) ).xyz;
    float3 _S727 = to_local_0(i_9, (float4(*(kernelContext_47->state_0+_S726)) ).xyz + cross(tb_2, rb_1) - ((float4(*(kernelContext_47->state_0+_S725)) ).xyz + cross(ta_2, ra_1)), kernelContext_47);
    float3 _S728 = to_local_0(i_9, tb_2 - ta_2, kernelContext_47);
    float3 _S729 = to_local_0(i_9, vb_0 + cross(wb_1, rb_1) - (va_0 + cross(wa_1, ra_1)), kernelContext_47);
    float3 _S730 = to_local_0(i_9, wb_1 - wa_1, kernelContext_47);
    JointState_0 previous_0 = (kernelContext_47->bond_dyn_0+i_9)->js_0;
    thread JointState_0 _S731 = (kernelContext_47->bond_dyn_0+i_9)->js_0;
    bool _S732 = is_damaged_0(&_S731);
    thread JointBond_natural_0 _S733 = (kernelContext_47->bonds_0+i_9)->law_0;
    thread JointState_0 _S734 = (kernelContext_47->bond_dyn_0+i_9)->js_0;
    JointResponse_0 _S735 = joint_evaluate_0(&kernelContext_47->materials_0->m_0[(uint4((kernelContext_47->bonds_0+i_9)->law_0.ids_0) ).x], &_S733, &_S734, _S727, _S728, dt_10, fracture_2);
    BondStatic_natural_0 device* _S736 = kernelContext_47->bonds_0+i_9;
    BondDyn_natural_0 device* _S737 = kernelContext_47->bond_dyn_0+i_9;
    float4 _S738 = float4((*_S737).force_lin_0) ;
    float4 _S739 = float4((*_S737).force_ang_0) ;
    float4 _S740 = float4((*_S737).sums_0) ;
    float4 _S741 = float4((*_S737).comps_0) ;
    uint4 _S742 = uint4((*_S737).events_0) ;
    thread BondDyn_0 bd_0;
    (&bd_0)->js_0 = (*_S737).js_0;
    (&bd_0)->force_lin_0 = _S738;
    (&bd_0)->force_ang_0 = _S739;
    (&bd_0)->sums_0 = _S740;
    (&bd_0)->comps_0 = _S741;
    (&bd_0)->events_0 = _S742;
    float3 ra_2 = (float4(_S736->ra_0) ).xyz;
    float3 rb_2 = (float4(_S736->rb_0) ).xyz;
    thread JointBond_natural_0 _S743 = _S736->law_0;
    thread JointState_0 _S744 = _S735.state_6;
    thread float3 f_lin_1;
    thread float3 f_ang_1;
    secant_factors_0(&_S743, &_S744, _S727, &f_lin_1, &f_ang_1);
    float3 qd_lin_0 = _S729 * (float4(_S736->c_lin_0) ).xyz * f_lin_1;
    float3 qd_ang_0 = _S730 * (float4(_S736->c_ang_0) ).xyz * f_ang_1;
    float3 q_lin_2 = _S735.force_lin_1 + qd_lin_0;
    float3 q_ang_2 = _S735.force_ang_1 + qd_ang_0;
    float damped_0 = (dot(qd_lin_0, _S729) + dot(qd_ang_0, _S730)) * dt_10;
    float3 _S745 = to_body_0(i_9, q_lin_2, kernelContext_47);
    float3 _S746 = to_body_0(i_9, q_ang_2, kernelContext_47);
    uint _S747 = 3U * i_9;
    *(kernelContext_47->scratch_0+_S747) = packed_float4(float4(_S745, max(_S735.measures_0.tension_0, _S735.measures_0.compression_0))) ;
    *(kernelContext_47->scratch_0+(_S747 + 1U)) = packed_float4(float4(_S746 + cross(ra_2, _S745), 0.0f)) ;
    *(kernelContext_47->scratch_0+(_S747 + 2U)) = packed_float4(float4(- _S746 + cross(rb_2, - _S745), 0.0f)) ;
    thread float _S748 = (&bd_0)->sums_0.x;
    thread float _S749 = (&bd_0)->comps_0.x;
    comp_add1_0(&_S748, &_S749, _S735.dissipated_2);
    (&bd_0)->comps_0.x = _S749;
    (&bd_0)->sums_0.x = _S748;
    thread float _S750 = (&bd_0)->sums_0.y;
    thread float _S751 = (&bd_0)->comps_0.y;
    comp_add1_0(&_S750, &_S751, _S735.overshoot_0);
    (&bd_0)->comps_0.y = _S751;
    (&bd_0)->sums_0.y = _S750;
    thread float _S752 = (&bd_0)->sums_0.z;
    thread float _S753 = (&bd_0)->comps_0.z;
    comp_add1_0(&_S752, &_S753, damped_0);
    (&bd_0)->comps_0.z = _S753;
    (&bd_0)->sums_0.z = _S752;
    (&bd_0)->force_lin_0 = float4(q_lin_2, _S735.stored_5);
    (&bd_0)->force_ang_0 = float4(q_ang_2, max((&bd_0)->force_ang_0.w, _S735.state_6.utilization_0));
    bool _S754;
    if(!_S732)
    {
        thread JointState_0 _S755 = _S735.state_6;
        bool _S756 = is_damaged_0(&_S755);
        _S754 = _S756;
    }
    else
    {
        _S754 = false;
    }
    if(_S754)
    {
        _S754 = ((&bd_0)->events_0.x) == 0U;
    }
    else
    {
        _S754 = false;
    }
    if(_S754)
    {
        (&bd_0)->events_0.x = abs_step_0;
        (&bd_0)->events_0.w = _S735.state_6.mode_0;
        if(wide_0)
        {
            cov_or_0((uint4((&_S743)->ids_0) ).w, 32U, kernelContext_47);
        }
        else
        {
            (*kernelContext_47->g_seen_0)[3U] = 1U;
        }
    }
    if(((&bd_0)->events_0.y) == 0U)
    {
        _S754 = (_S735.state_6.life_0) != (previous_0.life_0);
    }
    else
    {
        _S754 = false;
    }
    if(_S754)
    {
        _S754 = (_S735.fatigue_before_0) > 0.99000000953674316f;
    }
    else
    {
        _S754 = false;
    }
    if(_S754)
    {
        float _S757 = fatigue_factor_0(&kernelContext_47->materials_0->m_0[(uint4((kernelContext_47->bonds_0+i_9)->law_0.ids_0) ).x], _S735.state_6.life_0);
        _S754 = _S757 <= 0.99000000953674316f;
    }
    else
    {
        _S754 = false;
    }
    if(_S754)
    {
        (&bd_0)->events_0.y = abs_step_0;
        if(wide_0)
        {
            cov_or_0((uint4((&_S743)->ids_0) ).w, 64U, kernelContext_47);
        }
        else
        {
            (*kernelContext_47->g_seen_0)[4U] = 1U;
        }
    }
    if(_S735.disconnected_0)
    {
        (&bd_0)->events_0.z = abs_step_0;
    }
    (&bd_0)->js_0 = _S735.state_6;
    BondDyn_natural_0 device* _S758 = kernelContext_47->bond_dyn_0+i_9;
    _S758->js_0 = bd_0.js_0;
    _S758->force_lin_0 = packed_float4(bd_0.force_lin_0) ;
    _S758->force_ang_0 = packed_float4(bd_0.force_ang_0) ;
    _S758->sums_0 = packed_float4(bd_0.sums_0) ;
    _S758->comps_0 = packed_float4(bd_0.comps_0) ;
    _S758->events_0 = packed_uint4(bd_0.events_0) ;
    return _S735.disconnected_0;
}

void chunk_update_0(uint c_15, const Island_natural_0 thread* isl_8, const Rigid_0 thread* rg_6, float dt_11, bool rml_0, uint step_0, bool contact_4, float thread* work_1, float thread* work_err_0, KernelContext_0 thread* kernelContext_48)
{
    ChunkStatic_natural_0 device* _S759 = kernelContext_48->chunks_0+c_15;
    float3 _S760 = float3(0.0f) ;
    uint _S761 = kernelContext_48->index_0[c_15];
    float peak_0 = 0.0f;
    uint e_3 = _S761;
    float3 fi_0 = _S760;
    float3 mi_0 = _S760;
    for(;;)
    {
        if(e_3 < (kernelContext_48->index_0)[c_15 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_2 = kernelContext_48->index_0[e_3];
        uint _S762 = 3U * (entry_2 >> 1U);
        float4 _S763 = float4(*(kernelContext_48->scratch_0+_S762)) ;
        if((entry_2 & 1U) == 0U)
        {
            float3 mi_1 = mi_0 + (float4(*(kernelContext_48->scratch_0+(_S762 + 1U))) ).xyz;
            fi_0 = fi_0 + _S763.xyz;
            mi_0 = mi_1;
        }
        else
        {
            float3 mi_2 = mi_0 + (float4(*(kernelContext_48->scratch_0+(_S762 + 2U))) ).xyz;
            fi_0 = fi_0 + - _S763.xyz;
            mi_0 = mi_2;
        }
        float _S764 = max(peak_0, _S763.w);
        uint _S765 = e_3 + 1U;
        peak_0 = _S764;
        e_3 = _S765;
    }
    uint _S766 = 4U * c_15;
    float3 u_0 = (float4(*(kernelContext_48->state_0+_S766)) ).xyz;
    uint _S767 = _S766 + 1U;
    float3 th_1 = (float4(*(kernelContext_48->state_0+_S767)) ).xyz;
    uint _S768 = _S766 + 2U;
    float3 v_9 = (float4(*(kernelContext_48->state_0+_S768)) ).xyz;
    uint _S769 = _S766 + 3U;
    float3 w_5 = (float4(*(kernelContext_48->state_0+_S769)) ).xyz;
    float4 _S770 = float4(_S759->center_0) ;
    float mass_0 = _S770.w;
    float3 _S771 = _S770.xyz;
    float3 _S772 = (float4(isl_8->com_0) ).xyz;
    float3 _S773 = rotate_0(&rg_6->rot_0, _S771 + u_0 - _S772);
    thread float3 f_load_0;
    thread float3 t_load_0;
    thread float3 rep_f_2;
    thread float3 rep_m_2;
    chunk_loads_0(c_15, c_15, &rg_6->rot_0, step_0, dt_11, contact_4, dt_11, &f_load_0, &t_load_0, &rep_f_2, &rep_m_2, kernelContext_48);
    record_chunk_load_0(c_15, f_load_0, t_load_0, kernelContext_48);
    float3 _S774 = float3(mass_0) ;
    float3 f_world_0 = f_load_0 + kernelContext_48->params_0->gravity_0.xyz * _S774;
    float3 t_world_0 = t_load_0;
    float3 f_world_1;
    float3 t_world_1;
    if(rml_0)
    {
        float3 f_world_2 = f_world_0 - (rg_6->a_7 + cross(rg_6->alpha_0, _S773) + cross(rg_6->w_4, cross(rg_6->w_4, _S773))) * _S774;
        float4 _S775 = float4(_S759->inertia0_1) ;
        float4 _S776 = float4(_S759->inertia1_1) ;
        float4 _S777 = float4(_S759->inertia2_1) ;
        float3 _S778 = world_mul_0(&rg_6->rot_0, _S775, _S776, _S777, rg_6->alpha_0);
        float3 _S779 = world_mul_0(&rg_6->rot_0, _S775, _S776, _S777, rg_6->w_4);
        float3 t_world_2 = t_world_0 - (_S778 + cross(rg_6->w_4, _S779));
        f_world_1 = f_world_2;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    float3 _S780 = inverse_rotate_0(&rg_6->rot_0, f_world_1);
    float3 _S781 = inverse_rotate_0(&rg_6->rot_0, t_world_1);
    float3 f_ext_0;
    float3 m_ext_0;
    if(rml_0)
    {
        float3 _S782 = inverse_rotate_0(&rg_6->rot_0, rg_6->w_4);
        float4 _S783 = float4(_S759->inertia0_1) ;
        float4 _S784 = float4(_S759->inertia1_1) ;
        float4 _S785 = float4(_S759->inertia2_1) ;
        float3 i_w_0 = rows_mul_0(_S783, _S784, _S785, w_5);
        float3 m_ext_1 = _S781 - (cross(_S782, i_w_0) + cross(w_5, rows_mul_0(_S783, _S784, _S785, _S782)) + cross(w_5, i_w_0));
        f_ext_0 = _S780 - cross(_S782, v_9) * float3((2.0f * mass_0)) ;
        m_ext_0 = m_ext_1;
    }
    else
    {
        f_ext_0 = _S780;
        m_ext_0 = _S781;
    }
    float3 f_12 = f_ext_0 + rep_f_2 + fi_0;
    float3 m_5 = m_ext_0 + rep_m_2 + mi_0;
    uint support_0 = (uint4(_S759->info_1) ).x;
    float3 _S786 = float3((float4(*(kernelContext_48->state_0+_S767)) ).w, (float4(*(kernelContext_48->state_0+_S768)) ).w, (float4(*(kernelContext_48->state_0+_S769)) ).w);
    float3 reaction_0;
    float3 u_1;
    float3 th_2;
    float3 v_10;
    float3 w_6;
    if(support_0 == 1U)
    {
        reaction_0 = - f_12;
        u_1 = u_0;
        th_2 = th_1;
        v_10 = _S760;
        w_6 = _S760;
    }
    else
    {
        float4 _S787 = float4(_S759->scale_0) ;
        float3 w_7 = w_5 + rows_mul_0(float4(_S759->inv0_1) , float4(_S759->inv1_1) , float4(_S759->inv2_1) , m_5) * float3((dt_11 * _S787.z)) ;
        float3 _S788 = float3(dt_11) ;
        float3 th_3 = th_1 + w_7 * _S788;
        if(support_0 == 2U)
        {
            reaction_0 = - f_12;
            u_1 = u_0;
            th_2 = _S760;
        }
        else
        {
            float3 v_11 = v_9 + f_12 * float3((dt_11 * _S787.y)) ;
            float3 u_2 = u_0 + v_11 * _S788;
            reaction_0 = _S786;
            u_1 = u_2;
            th_2 = v_11;
        }
        float3 _S789 = th_2;
        th_2 = th_3;
        v_10 = _S789;
        w_6 = w_7;
    }
    *(kernelContext_48->state_0+_S766) = packed_float4(float4(u_1, peak_0)) ;
    *(kernelContext_48->state_0+_S767) = packed_float4(float4(th_2, reaction_0.x)) ;
    *(kernelContext_48->state_0+_S768) = packed_float4(float4(v_10, reaction_0.y)) ;
    *(kernelContext_48->state_0+_S769) = packed_float4(float4(w_6, reaction_0.z)) ;
    float3 _S790 = rotate_0(&rg_6->rot_0, _S771 + u_1 - _S772);
    float3 _S791 = rg_6->vel_1 + rg_6->vel_err_1 + cross(rg_6->w_4, _S790);
    float3 _S792 = rotate_0(&rg_6->rot_0, v_10);
    float3 v_world_0 = _S791 + _S792;
    float3 _S793 = rotate_0(&rg_6->rot_0, w_6);
    comp_add1_0(work_1, work_err_0, (dot(f_load_0, v_world_0) + dot(t_load_0, rg_6->w_4 + _S793)) * dt_11);
    return;
}

void chunk_update_1(uint c_16, const Island_0 thread* isl_9, const Rigid_0 thread* rg_7, float dt_12, bool rml_1, uint step_1, bool contact_5, float thread* work_2, float thread* work_err_1, KernelContext_0 thread* kernelContext_49)
{
    ChunkStatic_natural_0 device* _S794 = kernelContext_49->chunks_0+c_16;
    float3 _S795 = float3(0.0f) ;
    uint _S796 = kernelContext_49->index_0[c_16];
    float peak_1 = 0.0f;
    uint e_4 = _S796;
    float3 fi_1 = _S795;
    float3 mi_3 = _S795;
    for(;;)
    {
        if(e_4 < (kernelContext_49->index_0)[c_16 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_3 = kernelContext_49->index_0[e_4];
        uint _S797 = 3U * (entry_3 >> 1U);
        float4 _S798 = float4(*(kernelContext_49->scratch_0+_S797)) ;
        if((entry_3 & 1U) == 0U)
        {
            float3 mi_4 = mi_3 + (float4(*(kernelContext_49->scratch_0+(_S797 + 1U))) ).xyz;
            fi_1 = fi_1 + _S798.xyz;
            mi_3 = mi_4;
        }
        else
        {
            float3 mi_5 = mi_3 + (float4(*(kernelContext_49->scratch_0+(_S797 + 2U))) ).xyz;
            fi_1 = fi_1 + - _S798.xyz;
            mi_3 = mi_5;
        }
        float _S799 = max(peak_1, _S798.w);
        uint _S800 = e_4 + 1U;
        peak_1 = _S799;
        e_4 = _S800;
    }
    uint _S801 = 4U * c_16;
    float3 u_3 = (float4(*(kernelContext_49->state_0+_S801)) ).xyz;
    uint _S802 = _S801 + 1U;
    float3 th_4 = (float4(*(kernelContext_49->state_0+_S802)) ).xyz;
    uint _S803 = _S801 + 2U;
    float3 v_12 = (float4(*(kernelContext_49->state_0+_S803)) ).xyz;
    uint _S804 = _S801 + 3U;
    float3 w_8 = (float4(*(kernelContext_49->state_0+_S804)) ).xyz;
    float4 _S805 = float4(_S794->center_0) ;
    float mass_1 = _S805.w;
    float3 _S806 = _S805.xyz;
    float3 _S807 = isl_9->com_0.xyz;
    float3 _S808 = rotate_0(&rg_7->rot_0, _S806 + u_3 - _S807);
    thread float3 f_load_1;
    thread float3 t_load_1;
    thread float3 rep_f_3;
    thread float3 rep_m_3;
    chunk_loads_0(c_16, c_16, &rg_7->rot_0, step_1, dt_12, contact_5, dt_12, &f_load_1, &t_load_1, &rep_f_3, &rep_m_3, kernelContext_49);
    record_chunk_load_0(c_16, f_load_1, t_load_1, kernelContext_49);
    float3 _S809 = float3(mass_1) ;
    float3 f_world_3 = f_load_1 + kernelContext_49->params_0->gravity_0.xyz * _S809;
    float3 t_world_3 = t_load_1;
    float3 f_world_4;
    float3 t_world_4;
    if(rml_1)
    {
        float3 f_world_5 = f_world_3 - (rg_7->a_7 + cross(rg_7->alpha_0, _S808) + cross(rg_7->w_4, cross(rg_7->w_4, _S808))) * _S809;
        float4 _S810 = float4(_S794->inertia0_1) ;
        float4 _S811 = float4(_S794->inertia1_1) ;
        float4 _S812 = float4(_S794->inertia2_1) ;
        float3 _S813 = world_mul_0(&rg_7->rot_0, _S810, _S811, _S812, rg_7->alpha_0);
        float3 _S814 = world_mul_0(&rg_7->rot_0, _S810, _S811, _S812, rg_7->w_4);
        float3 t_world_5 = t_world_3 - (_S813 + cross(rg_7->w_4, _S814));
        f_world_4 = f_world_5;
        t_world_4 = t_world_5;
    }
    else
    {
        f_world_4 = f_world_3;
        t_world_4 = t_world_3;
    }
    float3 _S815 = inverse_rotate_0(&rg_7->rot_0, f_world_4);
    float3 _S816 = inverse_rotate_0(&rg_7->rot_0, t_world_4);
    float3 f_ext_1;
    float3 m_ext_2;
    if(rml_1)
    {
        float3 _S817 = inverse_rotate_0(&rg_7->rot_0, rg_7->w_4);
        float4 _S818 = float4(_S794->inertia0_1) ;
        float4 _S819 = float4(_S794->inertia1_1) ;
        float4 _S820 = float4(_S794->inertia2_1) ;
        float3 i_w_1 = rows_mul_0(_S818, _S819, _S820, w_8);
        float3 m_ext_3 = _S816 - (cross(_S817, i_w_1) + cross(w_8, rows_mul_0(_S818, _S819, _S820, _S817)) + cross(w_8, i_w_1));
        f_ext_1 = _S815 - cross(_S817, v_12) * float3((2.0f * mass_1)) ;
        m_ext_2 = m_ext_3;
    }
    else
    {
        f_ext_1 = _S815;
        m_ext_2 = _S816;
    }
    float3 f_13 = f_ext_1 + rep_f_3 + fi_1;
    float3 m_6 = m_ext_2 + rep_m_3 + mi_3;
    uint support_1 = (uint4(_S794->info_1) ).x;
    float3 _S821 = float3((float4(*(kernelContext_49->state_0+_S802)) ).w, (float4(*(kernelContext_49->state_0+_S803)) ).w, (float4(*(kernelContext_49->state_0+_S804)) ).w);
    float3 reaction_1;
    float3 u_4;
    float3 th_5;
    float3 v_13;
    float3 w_9;
    if(support_1 == 1U)
    {
        reaction_1 = - f_13;
        u_4 = u_3;
        th_5 = th_4;
        v_13 = _S795;
        w_9 = _S795;
    }
    else
    {
        float4 _S822 = float4(_S794->scale_0) ;
        float3 w_10 = w_8 + rows_mul_0(float4(_S794->inv0_1) , float4(_S794->inv1_1) , float4(_S794->inv2_1) , m_6) * float3((dt_12 * _S822.z)) ;
        float3 _S823 = float3(dt_12) ;
        float3 th_6 = th_4 + w_10 * _S823;
        if(support_1 == 2U)
        {
            reaction_1 = - f_13;
            u_4 = u_3;
            th_5 = _S795;
        }
        else
        {
            float3 v_14 = v_12 + f_13 * float3((dt_12 * _S822.y)) ;
            float3 u_5 = u_3 + v_14 * _S823;
            reaction_1 = _S821;
            u_4 = u_5;
            th_5 = v_14;
        }
        float3 _S824 = th_5;
        th_5 = th_6;
        v_13 = _S824;
        w_9 = w_10;
    }
    *(kernelContext_49->state_0+_S801) = packed_float4(float4(u_4, peak_1)) ;
    *(kernelContext_49->state_0+_S802) = packed_float4(float4(th_5, reaction_1.x)) ;
    *(kernelContext_49->state_0+_S803) = packed_float4(float4(v_13, reaction_1.y)) ;
    *(kernelContext_49->state_0+_S804) = packed_float4(float4(w_9, reaction_1.z)) ;
    float3 _S825 = rotate_0(&rg_7->rot_0, _S806 + u_4 - _S807);
    float3 _S826 = rg_7->vel_1 + rg_7->vel_err_1 + cross(rg_7->w_4, _S825);
    float3 _S827 = rotate_0(&rg_7->rot_0, v_13);
    float3 v_world_1 = _S826 + _S827;
    float3 _S828 = rotate_0(&rg_7->rot_0, w_9);
    comp_add1_0(work_2, work_err_1, (dot(f_load_1, v_world_1) + dot(t_load_1, rg_7->w_4 + _S828)) * dt_12);
    return;
}

float3 turn_difference_0(float3 omega_1, float dt_13, float3 v_15)
{
    float _S829 = length(omega_1);
    float angle_3 = _S829 * dt_13;
    if(angle_3 < 1.00000000317107685e-30f)
    {
        return float3(0.0f) ;
    }
    float3 a_11 = omega_1 / float3(_S829) ;
    float s_6 = sin(0.5f * angle_3);
    float3 av_0 = cross(a_11, v_15);
    return av_0 * float3(sin(angle_3))  + cross(a_11, av_0) * float3((2.0f * s_6 * s_6)) ;
}

void integrate_rigid_0(const Island_natural_0 thread* isl_10, Rigid_0 thread* rg_8, float dt_14)
{
    float3 _S830 = float3(dt_14) ;
    comp_add_0(&rg_8->l_2, &rg_8->l_err_1, rg_8->torque_0 * _S830);
    float3 l_3 = rg_8->l_2 + rg_8->l_err_1;
    comp_add_0(&rg_8->vel_1, &rg_8->vel_err_1, rg_8->a_7 * _S830);
    float3 vel_2 = rg_8->vel_1 + rg_8->vel_err_1;
    float4 _S831 = float4(isl_10->inv0_0) ;
    float4 _S832 = float4(isl_10->inv1_0) ;
    float4 _S833 = float4(isl_10->inv2_0) ;
    thread Quat_0 _S834 = rg_8->rot_0;
    float3 _S835 = world_mul_0(&_S834, _S831, _S832, _S833, l_3);
    float3 _S836 = vel_2 * _S830;
    float3 _S837 = (float4(isl_10->com_0) ).xyz;
    thread Quat_0 _S838 = rg_8->rot_0;
    float3 _S839 = rotate_0(&_S838, _S837);
    comp_add_0(&rg_8->pos_1, &rg_8->pos_err_1, _S836 - turn_difference_0(_S835, dt_14, _S839));
    turn_left_0(&rg_8->rot_0, &rg_8->rot_err_0, _S835, dt_14);
    thread Quat_0 _S840 = rg_8->rot_0;
    float3 _S841 = world_mul_0(&_S840, _S831, _S832, _S833, l_3);
    rg_8->w_4 = _S841;
    return;
}

void integrate_rigid_1(const Island_0 thread* isl_11, Rigid_0 thread* rg_9, float dt_15)
{
    float3 _S842 = float3(dt_15) ;
    comp_add_0(&rg_9->l_2, &rg_9->l_err_1, rg_9->torque_0 * _S842);
    float3 l_4 = rg_9->l_2 + rg_9->l_err_1;
    comp_add_0(&rg_9->vel_1, &rg_9->vel_err_1, rg_9->a_7 * _S842);
    float3 vel_3 = rg_9->vel_1 + rg_9->vel_err_1;
    float4 _S843 = isl_11->inv0_0;
    float4 _S844 = isl_11->inv1_0;
    float4 _S845 = isl_11->inv2_0;
    thread Quat_0 _S846 = rg_9->rot_0;
    float3 _S847 = world_mul_0(&_S846, isl_11->inv0_0, isl_11->inv1_0, isl_11->inv2_0, l_4);
    float3 _S848 = vel_3 * _S842;
    float3 _S849 = isl_11->com_0.xyz;
    thread Quat_0 _S850 = rg_9->rot_0;
    float3 _S851 = rotate_0(&_S850, _S849);
    comp_add_0(&rg_9->pos_1, &rg_9->pos_err_1, _S848 - turn_difference_0(_S847, dt_15, _S851));
    turn_left_0(&rg_9->rot_0, &rg_9->rot_err_0, _S847, dt_15);
    thread Quat_0 _S852 = rg_9->rot_0;
    float3 _S853 = world_mul_0(&_S852, _S843, _S844, _S845, l_4);
    rg_9->w_4 = _S853;
    return;
}

void drift_moments_0(uint c_17, float3 thread* tu_0, float3 thread* pv_0, KernelContext_0 thread* kernelContext_50)
{
    ChunkStatic_natural_0 device* _S854 = kernelContext_50->chunks_0+c_17;
    uint _S855 = 4U * c_17;
    float3 _S856 = float3(((float4(_S854->center_0) ).w * (float4(_S854->scale_0) ).x)) ;
    *tu_0 = *tu_0 + (float4(*(kernelContext_50->state_0+_S855)) ).xyz * _S856;
    *pv_0 = *pv_0 + (float4(*(kernelContext_50->state_0+(_S855 + 2U))) ).xyz * _S856;
    return;
}

void drift_angular_0(uint c_18, float3 wcom_1, float3 tr_0, float3 dv_0, float3 thread* lu_0, float3 thread* lv_0, KernelContext_0 thread* kernelContext_51)
{
    ChunkStatic_natural_0 device* _S857 = kernelContext_51->chunks_0+c_18;
    float4 _S858 = float4(_S857->center_0) ;
    float3 r_10 = _S858.xyz - wcom_1;
    uint _S859 = 4U * c_18;
    float3 _S860 = float3(_S858.w) ;
    float4 _S861 = float4(_S857->inertia0_1) ;
    float4 _S862 = float4(_S857->inertia1_1) ;
    float4 _S863 = float4(_S857->inertia2_1) ;
    float3 _S864 = float3((float4(_S857->scale_0) ).x) ;
    *lu_0 = *lu_0 + (cross(r_10, (float4(*(kernelContext_51->state_0+_S859)) ).xyz - tr_0) * _S860 + rows_mul_0(_S861, _S862, _S863, (float4(*(kernelContext_51->state_0+(_S859 + 1U))) ).xyz)) * _S864;
    *lv_0 = *lv_0 + (cross(r_10, (float4(*(kernelContext_51->state_0+(_S859 + 2U))) ).xyz - dv_0) * _S860 + rows_mul_0(_S861, _S862, _S863, (float4(*(kernelContext_51->state_0+(_S859 + 3U))) ).xyz)) * _S864;
    return;
}

void drift_apply_0(uint c_19, float3 wcom_2, float3 tr_1, float3 phi_0, float3 dv_1, float3 dw_0, KernelContext_0 thread* kernelContext_52)
{
    float3 r_11 = (float4((kernelContext_52->chunks_0+c_19)->center_0) ).xyz - wcom_2;
    uint _S865 = 4U * c_19;
    *(kernelContext_52->state_0+_S865) = packed_float4(float4((float4(*(kernelContext_52->state_0+_S865)) ).xyz - (tr_1 + cross(phi_0, r_11)), (float4(*(kernelContext_52->state_0+_S865)) ).w)) ;
    uint _S866 = _S865 + 1U;
    *(kernelContext_52->state_0+_S866) = packed_float4(float4((float4(*(kernelContext_52->state_0+_S866)) ).xyz - phi_0, (float4(*(kernelContext_52->state_0+_S866)) ).w)) ;
    uint _S867 = _S865 + 2U;
    *(kernelContext_52->state_0+_S867) = packed_float4(float4((float4(*(kernelContext_52->state_0+_S867)) ).xyz - (dv_1 + cross(dw_0, r_11)), (float4(*(kernelContext_52->state_0+_S867)) ).w)) ;
    uint _S868 = _S865 + 3U;
    *(kernelContext_52->state_0+_S868) = packed_float4(float4((float4(*(kernelContext_52->state_0+_S868)) ).xyz - dw_0, (float4(*(kernelContext_52->state_0+_S868)) ).w)) ;
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
    (&dq_1)->x_1 = d_13.x;
    (&dq_1)->y_1 = d_13.y;
    (&dq_1)->z_0 = d_13.z;
    (&dq_1)->w_1 = d_13.w;
    thread Quat_0 _S869 = *hi_3;
    thread Quat_0 _S870 = dq_1;
    Quat_0 _S871 = quat_mul_0(&_S869, &_S870);
    thread Quat_0 _S872 = _S871;
    float4 _S873 = quat_vec_0(&_S872);
    quat_accumulate_0(hi_3, lo_3, _S873);
    return;
}

void drift_rigid_0(const Island_natural_0 thread* isl_12, Rigid_0 thread* rg_10, float3 tr_2, float3 phi_2, float3 dv_2, float3 dw_1)
{
    float3 wcom_3 = (float4(isl_12->wcom_0) ).xyz;
    Quat_0 rot_2 = rg_10->rot_0;
    float3 _S874 = tr_2 - cross(phi_2, wcom_3);
    thread Quat_0 _S875 = rg_10->rot_0;
    float3 _S876 = rotate_0(&_S875, _S874);
    comp_add_0(&rg_10->pos_1, &rg_10->pos_err_1, _S876);
    thread Quat_0 _S877 = rg_10->rot_0;
    float3 _S878 = inverse_rotate_0(&_S877, rg_10->w_4);
    float4 _S879 = float4(isl_12->inertia0_0) ;
    float4 _S880 = float4(isl_12->inertia1_0) ;
    float4 _S881 = float4(isl_12->inertia2_0) ;
    float3 _S882 = cross(phi_2, rows_mul_0(_S879, _S880, _S881, _S878)) - rows_mul_0(_S879, _S880, _S881, cross(phi_2, _S878));
    thread Quat_0 _S883 = rg_10->rot_0;
    float3 _S884 = rotate_0(&_S883, _S882);
    turn_right_0(&rg_10->rot_0, &rg_10->rot_err_0, phi_2);
    float3 _S885 = dv_2 + cross(dw_1, (float4(isl_12->com_0) ).xyz - wcom_3);
    thread Quat_0 _S886 = rot_2;
    float3 _S887 = rotate_0(&_S886, _S885);
    comp_add_0(&rg_10->vel_1, &rg_10->vel_err_1, _S887);
    thread Quat_0 _S888 = rot_2;
    float3 _S889 = rotate_0(&_S888, dw_1);
    rg_10->w_4 = rg_10->w_4 + _S889;
    thread Quat_0 _S890 = rg_10->rot_0;
    float3 _S891 = world_mul_0(&_S890, _S879, _S880, _S881, _S889);
    comp_add_0(&rg_10->l_2, &rg_10->l_err_1, _S884 + _S891);
    return;
}

void drift_rigid_1(const Island_0 thread* isl_13, Rigid_0 thread* rg_11, float3 tr_3, float3 phi_3, float3 dv_3, float3 dw_2)
{
    float3 wcom_4 = isl_13->wcom_0.xyz;
    Quat_0 rot_3 = rg_11->rot_0;
    float3 _S892 = tr_3 - cross(phi_3, wcom_4);
    thread Quat_0 _S893 = rg_11->rot_0;
    float3 _S894 = rotate_0(&_S893, _S892);
    comp_add_0(&rg_11->pos_1, &rg_11->pos_err_1, _S894);
    thread Quat_0 _S895 = rg_11->rot_0;
    float3 _S896 = inverse_rotate_0(&_S895, rg_11->w_4);
    float4 _S897 = isl_13->inertia0_0;
    float4 _S898 = isl_13->inertia1_0;
    float4 _S899 = isl_13->inertia2_0;
    float3 _S900 = cross(phi_3, rows_mul_0(isl_13->inertia0_0, isl_13->inertia1_0, isl_13->inertia2_0, _S896)) - rows_mul_0(isl_13->inertia0_0, isl_13->inertia1_0, isl_13->inertia2_0, cross(phi_3, _S896));
    thread Quat_0 _S901 = rg_11->rot_0;
    float3 _S902 = rotate_0(&_S901, _S900);
    turn_right_0(&rg_11->rot_0, &rg_11->rot_err_0, phi_3);
    float3 _S903 = dv_3 + cross(dw_2, isl_13->com_0.xyz - wcom_4);
    thread Quat_0 _S904 = rot_3;
    float3 _S905 = rotate_0(&_S904, _S903);
    comp_add_0(&rg_11->vel_1, &rg_11->vel_err_1, _S905);
    thread Quat_0 _S906 = rot_3;
    float3 _S907 = rotate_0(&_S906, dw_2);
    rg_11->w_4 = rg_11->w_4 + _S907;
    thread Quat_0 _S908 = rg_11->rot_0;
    float3 _S909 = world_mul_0(&_S908, _S897, _S898, _S899, _S907);
    comp_add_0(&rg_11->l_2, &rg_11->l_err_1, _S902 + _S909);
    return;
}

void write_probe_0(uint slot_1, uint k_18, float value_0, KernelContext_0 thread* kernelContext_53)
{
    uint at_4 = kernelContext_53->params_0->probe_base_0 * 4U + slot_1 * kernelContext_53->params_0->probe_stride_0 + k_18;
    thread float4 v_16 = float4(*(kernelContext_53->scratch_0+at_4 / 4U)) ;
    v_16[at_4 % 4U] = value_0;
    *(kernelContext_53->scratch_0+at_4 / 4U) = packed_float4(v_16) ;
    return;
}

void record_probes_0(const Island_0 thread* isl_14, const Rigid_0 thread* rg_12, uint k_19, KernelContext_0 thread* kernelContext_54)
{
    uint4 _S910 = isl_14->probes_0;
    uint at_5 = isl_14->probes_0.x;
    for(;;)
    {
        if(at_5 < (_S910.y))
        {
        }
        else
        {
            break;
        }
        uint4 info_3 = (as_type<uint4>((float4(*(kernelContext_54->loads_0+at_5)) )));
        float4 _S911 = float4(*(kernelContext_54->loads_0+(at_5 + 1U))) ;
        float4 _S912 = float4(*(kernelContext_54->loads_0+(at_5 + 2U))) ;
        float4 _S913 = float4(*(kernelContext_54->loads_0+(at_5 + 3U))) ;
        uint kind_4 = info_3.x;
        uint i_10 = info_3.y;
        float value_1;
        if(kind_4 == 0U)
        {
            float3 small_0 = (float4(*(kernelContext_54->state_0+4U * i_10)) ).xyz + float3(_S911.w, _S912.w, _S913.w);
            float3 _S914 = rg_12->pos_1 - _S912.xyz;
            float3 _S915 = rotate_0(&rg_12->rot_0, (float4((kernelContext_54->chunks_0+i_10)->center_0) ).xyz);
            float3 _S916 = _S914 + _S915;
            float3 _S917 = rg_12->pos_err_1 - _S913.xyz;
            float3 _S918 = rotate_0(&rg_12->rot_0, small_0);
            value_1 = dot(_S916 + (_S917 + _S918), _S911.xyz);
        }
        else
        {
            if(kind_4 == 1U)
            {
                uint _S919 = 4U * i_10;
                float3 _S920 = rotate_0(&rg_12->rot_0, (float4((kernelContext_54->chunks_0+i_10)->center_0) ).xyz + (float4(*(kernelContext_54->state_0+_S919)) ).xyz - isl_14->com_0.xyz);
                float3 _S921 = rg_12->vel_1 + rg_12->vel_err_1 + cross(rg_12->w_4, _S920);
                float3 _S922 = rotate_0(&rg_12->rot_0, (float4(*(kernelContext_54->state_0+(_S919 + 2U))) ).xyz);
                value_1 = dot(_S921 + _S922, _S911.xyz);
            }
            else
            {
                if(kind_4 == 2U)
                {
                    uint _S923 = 3U * i_10;
                    float3 f_14 = (float4(*(kernelContext_54->scratch_0+_S923)) ).xyz;
                    bool _S924 = (info_3.z) == 0U;
                    float3 mc_0;
                    if(_S924)
                    {
                        mc_0 = (float4(*(kernelContext_54->scratch_0+(_S923 + 1U))) ).xyz;
                    }
                    else
                    {
                        mc_0 = (float4(*(kernelContext_54->scratch_0+(_S923 + 2U))) ).xyz;
                    }
                    float3 fc_4;
                    if(_S924)
                    {
                        fc_4 = f_14;
                    }
                    else
                    {
                        fc_4 = - f_14;
                    }
                    value_1 = dot(fc_4, _S911.xyz) + dot(mc_0, _S912.xyz);
                }
                else
                {
                    uint _S925 = 4U * i_10;
                    float3 _S926 = rotate_0(&rg_12->rot_0, float3((float4(*(kernelContext_54->state_0+(_S925 + 1U))) ).w, (float4(*(kernelContext_54->state_0+(_S925 + 2U))) ).w, (float4(*(kernelContext_54->state_0+(_S925 + 3U))) ).w));
                    value_1 = dot(_S926, _S911.xyz);
                }
            }
        }
        write_probe_0(info_3.w, k_19, value_1, kernelContext_54);
        at_5 = at_5 + 4U;
    }
    return;
}

void contact_split_at_0(uint at_6, KernelContext_0 thread* kernelContext_55)
{
    uint previous_1 = (uint4((kernelContext_55->islands_0+kernelContext_55->params_0->halt_index_0)->info_0) ).y;
    uint _S927;
    if(previous_1 == 0U)
    {
        _S927 = at_6;
    }
    else
    {
        _S927 = min(previous_1, at_6);
    }
    (kernelContext_55->islands_0+kernelContext_55->params_0->halt_index_0)->info_0[int(1)] = _S927;
    return;
}

uint seen_bits_0(KernelContext_0 thread* kernelContext_56)
{
    uint _S928;
    if(((*kernelContext_56->g_seen_0)[0U]) != 0U)
    {
        _S928 = 32768U;
    }
    else
    {
        _S928 = 0U;
    }
    uint _S929;
    if(((*kernelContext_56->g_seen_0)[1U]) != 0U)
    {
        _S929 = 65536U;
    }
    else
    {
        _S929 = 0U;
    }
    uint _S930 = _S928 | _S929;
    if(((*kernelContext_56->g_seen_0)[2U]) != 0U)
    {
        _S928 = 131072U;
    }
    else
    {
        _S928 = 0U;
    }
    uint _S931 = _S930 | _S928;
    if(((*kernelContext_56->g_seen_0)[3U]) != 0U)
    {
        _S928 = 32U;
    }
    else
    {
        _S928 = 0U;
    }
    uint _S932 = _S931 | _S928;
    if(((*kernelContext_56->g_seen_0)[4U]) != 0U)
    {
        _S928 = 64U;
    }
    else
    {
        _S928 = 0U;
    }
    return _S932 | _S928;
}

[[kernel]] void island_frame(uint3 group_2 [[threadgroup_position_in_grid]], uint3 thread_2 [[thread_position_in_threadgroup]], Params_0 constant* params_6 [[buffer(0)]], Island_natural_0 device* islands_6 [[buffer(9)]], uint device* index_6 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_6 [[buffer(3)]], packed_float4 device* state_8 [[buffer(6)]], packed_float4 device* scratch_6 [[buffer(8)]], packed_float4 device* contact_state_6 [[buffer(11)]], packed_float4 device* loads_6 [[buffer(5)]], Impactor_natural_0 device* impactors_6 [[buffer(10)]], BondStatic_natural_0 device* bonds_6 [[buffer(2)]], MaterialTable_0 constant* materials_6 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_6 [[buffer(7)]])
{
    bool woke_0;
    thread KernelContext_0 kernelContext_57;
    (&kernelContext_57)->params_0 = params_6;
    (&kernelContext_57)->islands_0 = islands_6;
    (&kernelContext_57)->index_0 = index_6;
    (&kernelContext_57)->chunks_0 = chunks_6;
    (&kernelContext_57)->state_0 = state_8;
    (&kernelContext_57)->scratch_0 = scratch_6;
    (&kernelContext_57)->contact_state_0 = contact_state_6;
    (&kernelContext_57)->loads_0 = loads_6;
    (&kernelContext_57)->impactors_0 = impactors_6;
    (&kernelContext_57)->bonds_0 = bonds_6;
    (&kernelContext_57)->materials_0 = materials_6;
    (&kernelContext_57)->bond_dyn_0 = bond_dyn_6;
    threadgroup array<float4, int(32)> g_part_a_6;
    (&kernelContext_57)->g_part_a_0 = &g_part_a_6;
    threadgroup array<float4, int(32)> g_part_b_6;
    (&kernelContext_57)->g_part_b_0 = &g_part_b_6;
    threadgroup array<uint, int(5)> g_seen_6;
    (&kernelContext_57)->g_seen_0 = &g_seen_6;
    threadgroup uint g_run_6;
    (&kernelContext_57)->g_run_0 = &g_run_6;
    threadgroup uint g_halt_6;
    (&kernelContext_57)->g_halt_0 = &g_halt_6;
    threadgroup uint g_wide_run_6;
    (&kernelContext_57)->g_wide_run_0 = &g_wide_run_6;
    uint tid_5 = thread_2.x;
    uint _S933 = group_2.x;
    Island_natural_0 device* _S934 = islands_6+_S933;
    uint4 _S935 = uint4((*_S934).info_0) ;
    float4 _S936 = float4((*_S934).com_0) ;
    float4 _S937 = float4((*_S934).inertia0_0) ;
    float4 _S938 = float4((*_S934).inertia1_0) ;
    float4 _S939 = float4((*_S934).inertia2_0) ;
    float4 _S940 = float4((*_S934).inv0_0) ;
    float4 _S941 = float4((*_S934).inv1_0) ;
    float4 _S942 = float4((*_S934).inv2_0) ;
    float4 _S943 = float4((*_S934).wcom_0) ;
    float4 _S944 = float4((*_S934).winv0_0) ;
    float4 _S945 = float4((*_S934).winv1_0) ;
    float4 _S946 = float4((*_S934).winv2_0) ;
    float4 _S947 = float4((*_S934).rotation_0) ;
    float4 _S948 = float4((*_S934).position_0) ;
    float4 _S949 = float4((*_S934).position_err_0) ;
    float4 _S950 = float4((*_S934).velocity_0) ;
    float4 _S951 = float4((*_S934).velocity_err_0) ;
    float4 _S952 = float4((*_S934).angular_velocity_0) ;
    uint4 _S953 = uint4((*_S934).probes_0) ;
    float4 _S954 = float4((*_S934).energy_0) ;
    float4 _S955 = float4((*_S934).rotation_err_0) ;
    float4 _S956 = float4((*_S934).momentum_0) ;
    float4 _S957 = float4((*_S934).momentum_err_0) ;
    thread Island_0 isl_15;
    (&isl_15)->range_0 = uint4((*_S934).range_0) ;
    (&isl_15)->info_0 = _S935;
    (&isl_15)->com_0 = _S936;
    (&isl_15)->inertia0_0 = _S937;
    (&isl_15)->inertia1_0 = _S938;
    (&isl_15)->inertia2_0 = _S939;
    (&isl_15)->inv0_0 = _S940;
    (&isl_15)->inv1_0 = _S941;
    (&isl_15)->inv2_0 = _S942;
    (&isl_15)->wcom_0 = _S943;
    (&isl_15)->winv0_0 = _S944;
    (&isl_15)->winv1_0 = _S945;
    (&isl_15)->winv2_0 = _S946;
    (&isl_15)->rotation_0 = _S947;
    (&isl_15)->position_0 = _S948;
    (&isl_15)->position_err_0 = _S949;
    (&isl_15)->velocity_0 = _S950;
    (&isl_15)->velocity_err_0 = _S951;
    (&isl_15)->angular_velocity_0 = _S952;
    (&isl_15)->done_0 = (*_S934).done_0;
    (&isl_15)->coverage_0 = (*_S934).coverage_0;
    (&isl_15)->wide_groups_0 = (*_S934).wide_groups_0;
    (&isl_15)->done_pad_0 = (*_S934).done_pad_0;
    (&isl_15)->probes_0 = _S953;
    (&isl_15)->energy_0 = _S954;
    (&isl_15)->rotation_err_0 = _S955;
    (&isl_15)->momentum_0 = _S956;
    (&isl_15)->momentum_err_0 = _S957;
    bool driven_0 = (((&isl_15)->info_0.x) & 2U) != 0U;
    bool _S958 = !((((&isl_15)->info_0.x) & 1U) != 0U);
    bool _S959;
    if(_S958)
    {
        _S959 = !driven_0;
    }
    else
    {
        _S959 = false;
    }
    bool contact_island_0 = (((&isl_15)->info_0.x) & 4U) != 0U;
    bool _S960 = (((&isl_15)->info_0.x) & 16U) != 0U;
    seen_clear_0(tid_5, &kernelContext_57);
    bool _S961 = tid_5 == 0U;
    bool settled_0;
    uint cov_0;
    if(_S961)
    {
        if(contact_island_0 != (((&kernelContext_57)->params_0->contact_mode_0) == 1U))
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
            thread Island_0 _S962 = isl_15;
            bool _S963 = contact_stopped_1(&_S962, &kernelContext_57);
            settled_0 = _S963;
        }
        else
        {
            settled_0 = false;
        }
        if(settled_0)
        {
            cov_0 = 0U;
        }
        *(&kernelContext_57)->g_run_0 = cov_0;
        *(&kernelContext_57)->g_halt_0 = 0U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    if((((&isl_15)->info_0.z) & 1U) != 0U)
    {
        settled_0 = true;
    }
    else
    {
        settled_0 = (*(&kernelContext_57)->g_run_0) == 0U;
    }
    if(settled_0)
    {
        cov_0 = 0U;
    }
    else
    {
        cov_0 = min((&isl_15)->info_0.y, (&kernelContext_57)->params_0->max_steps_0);
    }
    float _S964 = (&kernelContext_57)->params_0->dt_0;
    bool _S965 = ((&kernelContext_57)->params_0->fracture_0) != 0U;
    bool _S966 = ((&kernelContext_57)->params_0->rigid_motion_loads_0) != 0U;
    thread Island_0 _S967 = isl_15;
    Rigid_0 _S968 = rigid_of_1(&_S967);
    thread Rigid_0 rg_13 = _S968;
    thread float work_3 = 0.0f;
    thread float work_err_2 = 0.0f;
    settled_0 = _S960;
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
        uint k_20 = abs_step_1 - 1U - (&kernelContext_57)->params_0->step_start_0;
        bool quiet_0 = (((&isl_15)->info_0.x) & 32U) != 0U;
        bool _S969;
        if(settled_0)
        {
            _S969 = !quiet_0;
        }
        else
        {
            _S969 = false;
        }
        bool _S970;
        bool explicit_step_0;
        uint c_20;
        if(_S969)
        {
            float3 _S971 = float3(0.0f) ;
            thread float3 norm_0 = _S971;
            thread float3 unused0_0 = _S971;
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
                thread Quat_0 _S972 = (&rg_13)->rot_0;
                float _S973 = settled_chunk_load_0(c_20, &_S972, k_20, _S964, contact_island_0, &kernelContext_57);
                norm_0.x = norm_0.x + _S973;
                c_20 = c_20 + 256U;
            }
            group_sum3_0(tid_5, &norm_0, &unused0_0, &kernelContext_57);
            if(((&kernelContext_57)->params_0->solve_mode_0) == 1U)
            {
                _S970 = (abs(norm_0.x - (&isl_15)->energy_0.z)) > ((&isl_15)->energy_0.w);
            }
            else
            {
                _S970 = false;
            }
            if(_S970)
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
        if(_S958)
        {
            _S970 = !quiet_0;
        }
        else
        {
            _S970 = false;
        }
        if(_S970)
        {
            float3 _S974 = float3(0.0f) ;
            thread float3 f_15 = _S974;
            thread float3 t_15 = _S974;
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
                thread Island_0 _S975 = isl_15;
                thread Rigid_0 _S976 = rg_13;
                net_load_1(c_20, &_S975, &_S976, k_20, _S964, contact_island_0, &f_15, &t_15, &kernelContext_57);
                c_20 = c_20 + 256U;
            }
            group_sum3_0(tid_5, &f_15, &t_15, &kernelContext_57);
            thread Island_0 _S977 = isl_15;
            rigid_acceleration_1(&_S977, &rg_13, f_15, t_15);
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
                bool _S978 = bond_update_0(c_20, _S964, _S965, abs_step_1, false, &kernelContext_57);
                if(_S978)
                {
                    *(&kernelContext_57)->g_halt_0 = 1U;
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
                thread Island_0 _S979 = isl_15;
                thread Rigid_0 _S980 = rg_13;
                chunk_update_1(c_21, &_S979, &_S980, _S964, _S966, k_20, contact_island_0, &work_3, &work_err_2, &kernelContext_57);
                c_21 = c_21 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        }
        bool _S981;
        if(_S959)
        {
            _S981 = !quiet_0;
        }
        else
        {
            _S981 = false;
        }
        if(_S981)
        {
            thread Island_0 _S982 = isl_15;
            integrate_rigid_1(&_S982, &rg_13, _S964);
        }
        bool _S983;
        if(_S958)
        {
            _S983 = explicit_step_0;
        }
        else
        {
            _S983 = false;
        }
        if(_S983)
        {
            float3 _S984 = (&isl_15)->wcom_0.xyz;
            float3 _S985 = float3(0.0f) ;
            thread float3 tu_1 = _S985;
            thread float3 pv_1 = _S985;
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
                drift_moments_0(c_20, &tu_1, &pv_1, &kernelContext_57);
                c_20 = c_20 + 256U;
            }
            group_sum3_0(tid_5, &tu_1, &pv_1, &kernelContext_57);
            float3 tr_4 = tu_1 / float3((&isl_15)->wcom_0.w) ;
            float3 dv_4 = pv_1 / float3((&isl_15)->wcom_0.w) ;
            thread float3 lu_1 = _S985;
            thread float3 lv_1 = _S985;
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
                drift_angular_0(c_21, _S984, tr_4, dv_4, &lu_1, &lv_1, &kernelContext_57);
                c_21 = c_21 + 256U;
            }
            group_sum3_0(tid_5, &lu_1, &lv_1, &kernelContext_57);
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
                drift_apply_0(c_22, _S984, tr_4, phi_4, dv_4, dw_3, &kernelContext_57);
                c_22 = c_22 + 256U;
            }
            if(!driven_0)
            {
                thread Island_0 _S986 = isl_15;
                drift_rigid_1(&_S986, &rg_13, tr_4, phi_4, dv_4, dw_3);
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        }
        bool _S987;
        if(_S961)
        {
            _S987 = ((&isl_15)->probes_0.y) > ((&isl_15)->probes_0.x);
        }
        else
        {
            _S987 = false;
        }
        if(_S987)
        {
            thread Island_0 _S988 = isl_15;
            thread Rigid_0 _S989 = rg_13;
            record_probes_0(&_S988, &_S989, k_20, &kernelContext_57);
        }
        uint _S990 = done_1 + 1U;
        if((*(&kernelContext_57)->g_halt_0) != 0U)
        {
            done_1 = _S990;
            break;
        }
        done_1 = _S990;
        woke_1 = woke_0;
    }
    thread float3 wsum_0 = float3(work_3, work_err_2, 0.0f);
    thread float3 unused_1 = float3(0.0f) ;
    group_sum3_0(tid_5, &wsum_0, &unused_1, &kernelContext_57);
    if(_S961)
    {
        thread Quat_0 _S991 = (&rg_13)->rot_0;
        float4 _S992 = quat_vec_0(&_S991);
        (&isl_15)->rotation_0 = _S992;
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
        if((*(&kernelContext_57)->g_halt_0) != 0U)
        {
            _S959 = contact_island_0;
        }
        else
        {
            _S959 = false;
        }
        if(_S959)
        {
            contact_split_at_0((&isl_15)->info_0.w + done_1, &kernelContext_57);
        }
        float _S993 = wsum_0.x;
        thread float _S994 = (&isl_15)->energy_0.x;
        thread float _S995 = (&isl_15)->energy_0.y;
        comp_add1_0(&_S994, &_S995, _S993);
        (&isl_15)->energy_0.x = _S994;
        (&isl_15)->energy_0.y = _S995 + wsum_0.y;
        (&isl_15)->info_0.w = (&isl_15)->info_0.w + done_1;
        if((*(&kernelContext_57)->g_halt_0) != 0U)
        {
            (&isl_15)->info_0.z = ((&isl_15)->info_0.z) | 1U;
        }
        uint _S996 = seen_bits_0(&kernelContext_57);
        if((*(&kernelContext_57)->g_halt_0) != 0U)
        {
            cov_0 = 128U;
        }
        else
        {
            cov_0 = 0U;
        }
        uint _S997 = _S996 | cov_0;
        if(woke_0)
        {
            cov_0 = 2048U;
        }
        else
        {
            cov_0 = 0U;
        }
        uint cov_1 = _S997 | cov_0;
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
                _S959 = !quiet_1;
            }
            else
            {
                _S959 = false;
            }
            if(_S959)
            {
                cov_0 = 512U;
            }
            else
            {
                cov_0 = 0U;
            }
            uint cov_3 = cov_2 | cov_0;
            if(((&kernelContext_57)->params_0->contact_mode_0) == 1U)
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
        Island_natural_0 device* _S998 = (&kernelContext_57)->islands_0+_S933;
        _S998->range_0 = packed_uint4(isl_15.range_0) ;
        _S998->info_0 = packed_uint4(isl_15.info_0) ;
        _S998->com_0 = packed_float4(isl_15.com_0) ;
        _S998->inertia0_0 = packed_float4(isl_15.inertia0_0) ;
        _S998->inertia1_0 = packed_float4(isl_15.inertia1_0) ;
        _S998->inertia2_0 = packed_float4(isl_15.inertia2_0) ;
        _S998->inv0_0 = packed_float4(isl_15.inv0_0) ;
        _S998->inv1_0 = packed_float4(isl_15.inv1_0) ;
        _S998->inv2_0 = packed_float4(isl_15.inv2_0) ;
        _S998->wcom_0 = packed_float4(isl_15.wcom_0) ;
        _S998->winv0_0 = packed_float4(isl_15.winv0_0) ;
        _S998->winv1_0 = packed_float4(isl_15.winv1_0) ;
        _S998->winv2_0 = packed_float4(isl_15.winv2_0) ;
        _S998->rotation_0 = packed_float4(isl_15.rotation_0) ;
        _S998->position_0 = packed_float4(isl_15.position_0) ;
        _S998->position_err_0 = packed_float4(isl_15.position_err_0) ;
        _S998->velocity_0 = packed_float4(isl_15.velocity_0) ;
        _S998->velocity_err_0 = packed_float4(isl_15.velocity_err_0) ;
        _S998->angular_velocity_0 = packed_float4(isl_15.angular_velocity_0) ;
        _S998->done_0 = isl_15.done_0;
        _S998->coverage_0 = isl_15.coverage_0;
        _S998->wide_groups_0 = isl_15.wide_groups_0;
        _S998->done_pad_0 = isl_15.done_pad_0;
        _S998->probes_0 = packed_uint4(isl_15.probes_0) ;
        _S998->energy_0 = packed_float4(isl_15.energy_0) ;
        _S998->rotation_err_0 = packed_float4(isl_15.rotation_err_0) ;
        _S998->momentum_0 = packed_float4(isl_15.momentum_0) ;
        _S998->momentum_err_0 = packed_float4(isl_15.momentum_err_0) ;
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

WideGroup_0 wide_group_0(uint table_0, uint g_2, KernelContext_0 thread* kernelContext_58)
{
    thread WideGroup_0 w_11;
    uint _S999 = table_0 + 4U * g_2;
    (&w_11)->island_3 = kernelContext_58->index_0[_S999];
    (&w_11)->begin_1 = kernelContext_58->index_0[_S999 + 1U];
    (&w_11)->end_0 = kernelContext_58->index_0[_S999 + 2U];
    (&w_11)->first_0 = kernelContext_58->index_0[_S999 + 3U];
    return w_11;
}

bool wide_runs_0(const Island_natural_0 thread* isl_16, KernelContext_0 thread* kernelContext_59)
{
    uint4 _S1000 = uint4(isl_16->info_0) ;
    bool _S1001;
    if(((_S1000.z) & 1U) != 0U)
    {
        _S1001 = true;
    }
    else
    {
        _S1001 = (_S1000.y) == 0U;
    }
    if(_S1001)
    {
        return false;
    }
    if(((_S1000.x) & 4U) == 0U)
    {
        _S1001 = true;
    }
    else
    {
        bool _S1002 = contact_stopped_0(isl_16, kernelContext_59);
        _S1001 = !_S1002;
    }
    return _S1001;
}

bool wide_enter_0(uint tid_6, const Island_natural_0 thread* isl_17, KernelContext_0 thread* kernelContext_60)
{
    seen_clear_0(tid_6, kernelContext_60);
    if(tid_6 == 0U)
    {
        bool _S1003 = wide_runs_0(isl_17, kernelContext_60);
        int _S1004;
        if(_S1003)
        {
            _S1004 = int(1);
        }
        else
        {
            _S1004 = int(0);
        }
        *kernelContext_60->g_wide_run_0 = uint(_S1004);
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    return (*kernelContext_60->g_wide_run_0) != 0U;
}

uint wide_step_0(const Island_natural_0 thread* isl_18, KernelContext_0 thread* kernelContext_61)
{
    return (uint4(isl_18->info_0) ).w - kernelContext_61->params_0->step_start_0;
}

uint wide_step_1(const Island_0 thread* isl_19, KernelContext_0 thread* kernelContext_62)
{
    return isl_19->info_0.w - kernelContext_62->params_0->step_start_0;
}

bool wide_enter_1(uint _S1005, uint _S1006, KernelContext_0 thread* kernelContext_63)
{
    thread Island_natural_0 _S1007 = *(kernelContext_63->islands_0+_S1006);
    seen_clear_0(_S1005, kernelContext_63);
    if(_S1005 == 0U)
    {
        bool _S1008 = wide_runs_0(&_S1007, kernelContext_63);
        int _S1009;
        if(_S1008)
        {
            _S1009 = int(1);
        }
        else
        {
            _S1009 = int(0);
        }
        *kernelContext_63->g_wide_run_0 = uint(_S1009);
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    return (*kernelContext_63->g_wide_run_0) != 0U;
}

[[kernel]] void wide_wake(uint3 group_3 [[threadgroup_position_in_grid]], uint3 thread_3 [[thread_position_in_threadgroup]], Params_0 constant* params_7 [[buffer(0)]], Island_natural_0 device* islands_7 [[buffer(9)]], uint device* index_7 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_7 [[buffer(3)]], packed_float4 device* state_9 [[buffer(6)]], packed_float4 device* scratch_7 [[buffer(8)]], packed_float4 device* contact_state_7 [[buffer(11)]], packed_float4 device* loads_7 [[buffer(5)]], Impactor_natural_0 device* impactors_7 [[buffer(10)]], BondStatic_natural_0 device* bonds_7 [[buffer(2)]], MaterialTable_0 constant* materials_7 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_7 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_64;
    (&kernelContext_64)->params_0 = params_7;
    (&kernelContext_64)->islands_0 = islands_7;
    (&kernelContext_64)->index_0 = index_7;
    (&kernelContext_64)->chunks_0 = chunks_7;
    (&kernelContext_64)->state_0 = state_9;
    (&kernelContext_64)->scratch_0 = scratch_7;
    (&kernelContext_64)->contact_state_0 = contact_state_7;
    (&kernelContext_64)->loads_0 = loads_7;
    (&kernelContext_64)->impactors_0 = impactors_7;
    (&kernelContext_64)->bonds_0 = bonds_7;
    (&kernelContext_64)->materials_0 = materials_7;
    (&kernelContext_64)->bond_dyn_0 = bond_dyn_7;
    threadgroup array<float4, int(32)> g_part_a_7;
    (&kernelContext_64)->g_part_a_0 = &g_part_a_7;
    threadgroup array<float4, int(32)> g_part_b_7;
    (&kernelContext_64)->g_part_b_0 = &g_part_b_7;
    threadgroup array<uint, int(5)> g_seen_7;
    (&kernelContext_64)->g_seen_0 = &g_seen_7;
    threadgroup uint g_run_7;
    (&kernelContext_64)->g_run_0 = &g_run_7;
    threadgroup uint g_halt_7;
    (&kernelContext_64)->g_halt_0 = &g_halt_7;
    threadgroup uint g_wide_run_7;
    (&kernelContext_64)->g_wide_run_0 = &g_wide_run_7;
    uint tid_7 = thread_3.x;
    uint _S1010 = group_3.x;
    WideGroup_0 _S1011 = wide_group_0(params_7->wide_chunk_table_0, _S1010, &kernelContext_64);
    if(_S1010 != (_S1011.first_0))
    {
        return;
    }
    thread Island_natural_0 _S1012 = *((&kernelContext_64)->islands_0+_S1011.island_3);
    uint4 _S1013 = uint4((&_S1012)->info_0) ;
    uint _S1014 = _S1013.x;
    bool _S1015;
    if((_S1014 & 16U) == 0U)
    {
        _S1015 = true;
    }
    else
    {
        bool _S1016 = wide_enter_1(tid_7, _S1011.island_3, &kernelContext_64);
        _S1015 = !_S1016;
    }
    if(_S1015)
    {
        return;
    }
    Quat_0 _S1017 = quat_of_0(float4((&_S1012)->rotation_0) );
    bool _S1018 = (_S1014 & 4U) != 0U;
    float3 _S1019 = float3(0.0f) ;
    thread float3 norm_1 = _S1019;
    thread float3 unused_2 = _S1019;
    uint4 _S1020 = uint4((&_S1012)->range_0) ;
    uint c_23 = _S1020.x + tid_7;
    for(;;)
    {
        if(c_23 < (_S1020.y))
        {
        }
        else
        {
            break;
        }
        uint _S1021 = wide_step_0(&_S1012, &kernelContext_64);
        float _S1022 = (&kernelContext_64)->params_0->dt_0;
        thread Quat_0 _S1023 = _S1017;
        float _S1024 = settled_chunk_load_0(c_23, &_S1023, _S1021, _S1022, _S1018, &kernelContext_64);
        norm_1.x = norm_1.x + _S1024;
        c_23 = c_23 + 256U;
    }
    group_sum3_0(tid_7, &norm_1, &unused_2, &kernelContext_64);
    if(tid_7 != 0U)
    {
        return;
    }
    uint _S1025 = seen_bits_0(&kernelContext_64);
    uint cov_5 = 1024U | _S1025;
    if(((&kernelContext_64)->params_0->solve_mode_0) == 1U)
    {
        float4 _S1026 = float4((&_S1012)->energy_0) ;
        _S1015 = (abs(norm_1.x - _S1026.z)) > (_S1026.w);
    }
    else
    {
        _S1015 = false;
    }
    uint cov_6;
    if(_S1015)
    {
        ((&kernelContext_64)->islands_0+_S1011.island_3)->info_0[int(0)] = _S1014 & 4294967279U;
        ((&kernelContext_64)->islands_0+_S1011.island_3)->info_0[int(2)] = (_S1013.z) | 4U;
        cov_6 = cov_5 | 2048U;
    }
    else
    {
        cov_6 = cov_5;
    }
    cov_mark_0(_S1011.island_3, (&_S1012)->coverage_0, cov_6, &kernelContext_64);
    return;
}

void wide_store_0(uint slot_2, uint p_14, float3 a_12, float3 b_29, KernelContext_0 thread* kernelContext_65)
{
    uint _S1027 = 8U * slot_2;
    *(kernelContext_65->scratch_0+(kernelContext_65->params_0->wide_base_0 + _S1027 + p_14)) = packed_float4(float4(a_12, 0.0f)) ;
    *(kernelContext_65->scratch_0+(kernelContext_65->params_0->wide_base_0 + _S1027 + p_14 + 1U)) = packed_float4(float4(b_29, 0.0f)) ;
    return;
}

[[kernel]] void wide_bonds(uint3 group_4 [[threadgroup_position_in_grid]], uint3 thread_4 [[thread_position_in_threadgroup]], Params_0 constant* params_8 [[buffer(0)]], Island_natural_0 device* islands_8 [[buffer(9)]], uint device* index_8 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_8 [[buffer(3)]], packed_float4 device* state_10 [[buffer(6)]], packed_float4 device* scratch_8 [[buffer(8)]], packed_float4 device* contact_state_8 [[buffer(11)]], packed_float4 device* loads_8 [[buffer(5)]], Impactor_natural_0 device* impactors_8 [[buffer(10)]], BondStatic_natural_0 device* bonds_8 [[buffer(2)]], MaterialTable_0 constant* materials_8 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_8 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_66;
    (&kernelContext_66)->params_0 = params_8;
    (&kernelContext_66)->islands_0 = islands_8;
    (&kernelContext_66)->index_0 = index_8;
    (&kernelContext_66)->chunks_0 = chunks_8;
    (&kernelContext_66)->state_0 = state_10;
    (&kernelContext_66)->scratch_0 = scratch_8;
    (&kernelContext_66)->contact_state_0 = contact_state_8;
    (&kernelContext_66)->loads_0 = loads_8;
    (&kernelContext_66)->impactors_0 = impactors_8;
    (&kernelContext_66)->bonds_0 = bonds_8;
    (&kernelContext_66)->materials_0 = materials_8;
    (&kernelContext_66)->bond_dyn_0 = bond_dyn_8;
    threadgroup array<float4, int(32)> g_part_a_8;
    (&kernelContext_66)->g_part_a_0 = &g_part_a_8;
    threadgroup array<float4, int(32)> g_part_b_8;
    (&kernelContext_66)->g_part_b_0 = &g_part_b_8;
    threadgroup array<uint, int(5)> g_seen_8;
    (&kernelContext_66)->g_seen_0 = &g_seen_8;
    threadgroup uint g_run_8;
    (&kernelContext_66)->g_run_0 = &g_run_8;
    threadgroup uint g_halt_8;
    (&kernelContext_66)->g_halt_0 = &g_halt_8;
    threadgroup uint g_wide_run_8;
    (&kernelContext_66)->g_wide_run_0 = &g_wide_run_8;
    uint tid_8 = thread_4.x;
    uint _S1028 = group_4.x;
    bool bond_group_0 = _S1028 < (params_8->wide_bond_groups_0);
    WideGroup_0 wg_0;
    if(bond_group_0)
    {
        WideGroup_0 _S1029 = wide_group_0((&kernelContext_66)->params_0->wide_bond_table_0, _S1028, &kernelContext_66);
        wg_0 = _S1029;
    }
    else
    {
        WideGroup_0 _S1030 = wide_group_0((&kernelContext_66)->params_0->wide_chunk_table_0, _S1028 - params_8->wide_bond_groups_0, &kernelContext_66);
        wg_0 = _S1030;
    }
    WideGroup_0 _S1031 = wg_0;
    thread Island_natural_0 _S1032 = *((&kernelContext_66)->islands_0+wg_0.island_3);
    bool _S1033 = wide_enter_1(tid_8, wg_0.island_3, &kernelContext_66);
    if(!_S1033)
    {
        return;
    }
    uint _S1034 = wide_step_0(&_S1032, &kernelContext_66);
    if(bond_group_0)
    {
        uint4 _S1035 = uint4((&_S1032)->info_0) ;
        if(((_S1035.x) & 16U) != 0U)
        {
            return;
        }
        uint i_11 = wg_0.begin_1 + tid_8;
        bool _S1036;
        if(i_11 < (wg_0.end_0))
        {
            bool _S1037 = bond_update_0(i_11, (&kernelContext_66)->params_0->dt_0, ((&kernelContext_66)->params_0->fracture_0) != 0U, _S1035.w + 1U, true, &kernelContext_66);
            _S1036 = _S1037;
        }
        else
        {
            _S1036 = false;
        }
        if(_S1036)
        {
            ((&kernelContext_66)->islands_0+_S1031.island_3)->info_0[int(2)] = (_S1035.z) | 2U;
        }
        return;
    }
    uint _S1038 = (uint4((&_S1032)->info_0) ).x;
    if((_S1038 & 1U) != 0U)
    {
        return;
    }
    float3 _S1039 = float3(0.0f) ;
    thread float3 f_16 = _S1039;
    thread float3 t_16 = _S1039;
    uint c_24 = wg_0.begin_1 + tid_8;
    if(c_24 < (wg_0.end_0))
    {
        Rigid_0 _S1040 = rigid_of_0(&_S1032);
        float _S1041 = (&kernelContext_66)->params_0->dt_0;
        bool _S1042 = (_S1038 & 4U) != 0U;
        thread Rigid_0 _S1043 = _S1040;
        net_load_0(c_24, &_S1032, &_S1043, _S1034, _S1041, _S1042, &f_16, &t_16, &kernelContext_66);
    }
    group_sum3_0(tid_8, &f_16, &t_16, &kernelContext_66);
    if(tid_8 == 0U)
    {
        wide_store_0(_S1028 - params_8->wide_bond_groups_0, 0U, f_16, t_16, &kernelContext_66);
    }
    return;
}

void wide_partials_0(uint tid_9, uint first_1, uint count_5, uint p_15, float3 thread* a_13, float3 thread* b_30, KernelContext_0 thread* kernelContext_67)
{
    float4 _S1044 = float4(0.0f) ;
    thread float4 x_10 = _S1044;
    thread float4 y_2 = _S1044;
    uint s_7 = tid_9;
    for(;;)
    {
        if(s_7 < count_5)
        {
        }
        else
        {
            break;
        }
        uint _S1045 = 8U * (first_1 + s_7);
        x_10 = x_10 + float4(*(kernelContext_67->scratch_0+(kernelContext_67->params_0->wide_base_0 + _S1045 + p_15))) ;
        y_2 = y_2 + float4(*(kernelContext_67->scratch_0+(kernelContext_67->params_0->wide_base_0 + _S1045 + p_15 + 1U))) ;
        s_7 = s_7 + 256U;
    }
    group_sum2_0(tid_9, &x_10, &y_2, kernelContext_67);
    *a_13 = x_10.xyz;
    *b_30 = y_2.xyz;
    return;
}

Rigid_0 wide_rigid_frame_0(uint tid_10, const Island_natural_0 thread* isl_20, const WideGroup_0 thread* wg_1, KernelContext_0 thread* kernelContext_68)
{
    Rigid_0 _S1046 = rigid_of_0(isl_20);
    thread Rigid_0 rg_14 = _S1046;
    if((((uint4(isl_20->info_0) ).x) & 1U) == 0U)
    {
        thread float3 f_17;
        thread float3 t_17;
        wide_partials_0(tid_10, wg_1->first_0, isl_20->wide_groups_0, 0U, &f_17, &t_17, kernelContext_68);
        rigid_acceleration_0(isl_20, &rg_14, f_17, t_17);
    }
    return rg_14;
}

[[kernel]] void wide_chunks(uint3 group_5 [[threadgroup_position_in_grid]], uint3 thread_5 [[thread_position_in_threadgroup]], Params_0 constant* params_9 [[buffer(0)]], Island_natural_0 device* islands_9 [[buffer(9)]], uint device* index_9 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_9 [[buffer(3)]], packed_float4 device* state_11 [[buffer(6)]], packed_float4 device* scratch_9 [[buffer(8)]], packed_float4 device* contact_state_9 [[buffer(11)]], packed_float4 device* loads_9 [[buffer(5)]], Impactor_natural_0 device* impactors_9 [[buffer(10)]], BondStatic_natural_0 device* bonds_9 [[buffer(2)]], MaterialTable_0 constant* materials_9 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_9 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_69;
    (&kernelContext_69)->params_0 = params_9;
    (&kernelContext_69)->islands_0 = islands_9;
    (&kernelContext_69)->index_0 = index_9;
    (&kernelContext_69)->chunks_0 = chunks_9;
    (&kernelContext_69)->state_0 = state_11;
    (&kernelContext_69)->scratch_0 = scratch_9;
    (&kernelContext_69)->contact_state_0 = contact_state_9;
    (&kernelContext_69)->loads_0 = loads_9;
    (&kernelContext_69)->impactors_0 = impactors_9;
    (&kernelContext_69)->bonds_0 = bonds_9;
    (&kernelContext_69)->materials_0 = materials_9;
    (&kernelContext_69)->bond_dyn_0 = bond_dyn_9;
    threadgroup array<float4, int(32)> g_part_a_9;
    (&kernelContext_69)->g_part_a_0 = &g_part_a_9;
    threadgroup array<float4, int(32)> g_part_b_9;
    (&kernelContext_69)->g_part_b_0 = &g_part_b_9;
    threadgroup array<uint, int(5)> g_seen_9;
    (&kernelContext_69)->g_seen_0 = &g_seen_9;
    threadgroup uint g_run_9;
    (&kernelContext_69)->g_run_0 = &g_run_9;
    threadgroup uint g_halt_9;
    (&kernelContext_69)->g_halt_0 = &g_halt_9;
    threadgroup uint g_wide_run_9;
    (&kernelContext_69)->g_wide_run_0 = &g_wide_run_9;
    uint tid_11 = thread_5.x;
    uint _S1047 = group_5.x;
    WideGroup_0 _S1048 = wide_group_0(params_9->wide_chunk_table_0, _S1047, &kernelContext_69);
    thread Island_natural_0 _S1049 = *((&kernelContext_69)->islands_0+_S1048.island_3);
    bool _S1050 = wide_enter_1(tid_11, _S1048.island_3, &kernelContext_69);
    if(!_S1050)
    {
        return;
    }
    uint _S1051 = (uint4((&_S1049)->info_0) ).x;
    bool anchored_0 = (_S1051 & 1U) != 0U;
    if((_S1051 & 16U) != 0U)
    {
        if(tid_11 == 0U)
        {
            *((&kernelContext_69)->scratch_0+((&kernelContext_69)->params_0->wide_base_0 + 8U * _S1047 + 6U)) = packed_float4(float4(0.0f) ) ;
        }
        return;
    }
    thread WideGroup_0 _S1052 = _S1048;
    Rigid_0 _S1053 = wide_rigid_frame_0(tid_11, &_S1049, &_S1052, &kernelContext_69);
    thread float work_4 = 0.0f;
    thread float work_err_3 = 0.0f;
    float3 _S1054 = float3(0.0f) ;
    thread float3 tu_2 = _S1054;
    thread float3 pv_2 = _S1054;
    uint c_25 = _S1048.begin_1 + tid_11;
    if(c_25 < (_S1048.end_0))
    {
        float _S1055 = (&kernelContext_69)->params_0->dt_0;
        bool _S1056 = ((&kernelContext_69)->params_0->rigid_motion_loads_0) != 0U;
        uint _S1057 = wide_step_0(&_S1049, &kernelContext_69);
        bool _S1058 = (_S1051 & 4U) != 0U;
        thread Rigid_0 _S1059 = _S1053;
        chunk_update_0(c_25, &_S1049, &_S1059, _S1055, _S1056, _S1057, _S1058, &work_4, &work_err_3, &kernelContext_69);
        if(!anchored_0)
        {
            drift_moments_0(c_25, &tu_2, &pv_2, &kernelContext_69);
        }
    }
    thread float3 wsum_1 = float3(work_4, work_err_3, 0.0f);
    thread float3 unused_3 = _S1054;
    group_sum3_0(tid_11, &wsum_1, &unused_3, &kernelContext_69);
    bool _S1060 = !anchored_0;
    if(_S1060)
    {
        group_sum3_0(tid_11, &tu_2, &pv_2, &kernelContext_69);
    }
    if(tid_11 == 0U)
    {
        uint _S1061 = 8U * _S1047;
        *((&kernelContext_69)->scratch_0+((&kernelContext_69)->params_0->wide_base_0 + _S1061 + 6U)) = packed_float4(float4(wsum_1, 0.0f)) ;
        if(_S1060)
        {
            wide_store_0(_S1047, 2U, tu_2, pv_2, &kernelContext_69);
        }
        *((&kernelContext_69)->scratch_0+((&kernelContext_69)->params_0->wide_base_0 + _S1061 + 7U)) = packed_float4(float4(float((*(&kernelContext_69)->g_seen_0)[0U]), float((*(&kernelContext_69)->g_seen_0)[1U]), float((*(&kernelContext_69)->g_seen_0)[2U]), 0.0f)) ;
    }
    return;
}

[[kernel]] void wide_drift(uint3 group_6 [[threadgroup_position_in_grid]], uint3 thread_6 [[thread_position_in_threadgroup]], Params_0 constant* params_10 [[buffer(0)]], Island_natural_0 device* islands_10 [[buffer(9)]], uint device* index_10 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_10 [[buffer(3)]], packed_float4 device* state_12 [[buffer(6)]], packed_float4 device* scratch_10 [[buffer(8)]], packed_float4 device* contact_state_10 [[buffer(11)]], packed_float4 device* loads_10 [[buffer(5)]], Impactor_natural_0 device* impactors_10 [[buffer(10)]], BondStatic_natural_0 device* bonds_10 [[buffer(2)]], MaterialTable_0 constant* materials_10 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_10 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_70;
    (&kernelContext_70)->params_0 = params_10;
    (&kernelContext_70)->islands_0 = islands_10;
    (&kernelContext_70)->index_0 = index_10;
    (&kernelContext_70)->chunks_0 = chunks_10;
    (&kernelContext_70)->state_0 = state_12;
    (&kernelContext_70)->scratch_0 = scratch_10;
    (&kernelContext_70)->contact_state_0 = contact_state_10;
    (&kernelContext_70)->loads_0 = loads_10;
    (&kernelContext_70)->impactors_0 = impactors_10;
    (&kernelContext_70)->bonds_0 = bonds_10;
    (&kernelContext_70)->materials_0 = materials_10;
    (&kernelContext_70)->bond_dyn_0 = bond_dyn_10;
    threadgroup array<float4, int(32)> g_part_a_10;
    (&kernelContext_70)->g_part_a_0 = &g_part_a_10;
    threadgroup array<float4, int(32)> g_part_b_10;
    (&kernelContext_70)->g_part_b_0 = &g_part_b_10;
    threadgroup array<uint, int(5)> g_seen_10;
    (&kernelContext_70)->g_seen_0 = &g_seen_10;
    threadgroup uint g_run_10;
    (&kernelContext_70)->g_run_0 = &g_run_10;
    threadgroup uint g_halt_10;
    (&kernelContext_70)->g_halt_0 = &g_halt_10;
    threadgroup uint g_wide_run_10;
    (&kernelContext_70)->g_wide_run_0 = &g_wide_run_10;
    uint tid_12 = thread_6.x;
    uint _S1062 = group_6.x;
    WideGroup_0 _S1063 = wide_group_0(params_10->wide_chunk_table_0, _S1062, &kernelContext_70);
    Island_natural_0 device* _S1064 = (&kernelContext_70)->islands_0+_S1063.island_3;
    Island_natural_0 isl_21 = *_S1064;
    bool _S1065;
    if((((uint4((*_S1064).info_0) ).x) & 17U) != 0U)
    {
        _S1065 = true;
    }
    else
    {
        bool _S1066 = wide_enter_1(tid_12, _S1063.island_3, &kernelContext_70);
        _S1065 = !_S1066;
    }
    if(_S1065)
    {
        return;
    }
    thread float3 tu_3;
    thread float3 pv_3;
    wide_partials_0(tid_12, _S1063.first_0, isl_21.wide_groups_0, 2U, &tu_3, &pv_3, &kernelContext_70);
    float4 _S1067 = float4(isl_21.wcom_0) ;
    float3 _S1068 = float3(_S1067.w) ;
    float3 tr_5 = tu_3 / _S1068;
    float3 dv_5 = pv_3 / _S1068;
    float3 _S1069 = float3(0.0f) ;
    thread float3 lu_2 = _S1069;
    thread float3 lv_2 = _S1069;
    uint c_26 = _S1063.begin_1 + tid_12;
    if(c_26 < (_S1063.end_0))
    {
        drift_angular_0(c_26, _S1067.xyz, tr_5, dv_5, &lu_2, &lv_2, &kernelContext_70);
    }
    group_sum3_0(tid_12, &lu_2, &lv_2, &kernelContext_70);
    if(tid_12 == 0U)
    {
        wide_store_0(_S1062, 4U, lu_2, lv_2, &kernelContext_70);
    }
    return;
}

[[kernel]] void wide_rigid(uint3 group_7 [[threadgroup_position_in_grid]], uint3 thread_7 [[thread_position_in_threadgroup]], Params_0 constant* params_11 [[buffer(0)]], Island_natural_0 device* islands_11 [[buffer(9)]], uint device* index_11 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_11 [[buffer(3)]], packed_float4 device* state_13 [[buffer(6)]], packed_float4 device* scratch_11 [[buffer(8)]], packed_float4 device* contact_state_11 [[buffer(11)]], packed_float4 device* loads_11 [[buffer(5)]], Impactor_natural_0 device* impactors_11 [[buffer(10)]], BondStatic_natural_0 device* bonds_11 [[buffer(2)]], MaterialTable_0 constant* materials_11 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_11 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_71;
    (&kernelContext_71)->params_0 = params_11;
    (&kernelContext_71)->islands_0 = islands_11;
    (&kernelContext_71)->index_0 = index_11;
    (&kernelContext_71)->chunks_0 = chunks_11;
    (&kernelContext_71)->state_0 = state_13;
    (&kernelContext_71)->scratch_0 = scratch_11;
    (&kernelContext_71)->contact_state_0 = contact_state_11;
    (&kernelContext_71)->loads_0 = loads_11;
    (&kernelContext_71)->impactors_0 = impactors_11;
    (&kernelContext_71)->bonds_0 = bonds_11;
    (&kernelContext_71)->materials_0 = materials_11;
    (&kernelContext_71)->bond_dyn_0 = bond_dyn_11;
    threadgroup array<float4, int(32)> g_part_a_11;
    (&kernelContext_71)->g_part_a_0 = &g_part_a_11;
    threadgroup array<float4, int(32)> g_part_b_11;
    (&kernelContext_71)->g_part_b_0 = &g_part_b_11;
    threadgroup array<uint, int(5)> g_seen_11;
    (&kernelContext_71)->g_seen_0 = &g_seen_11;
    threadgroup uint g_run_11;
    (&kernelContext_71)->g_run_0 = &g_run_11;
    threadgroup uint g_halt_11;
    (&kernelContext_71)->g_halt_0 = &g_halt_11;
    threadgroup uint g_wide_run_11;
    (&kernelContext_71)->g_wide_run_0 = &g_wide_run_11;
    uint tid_13 = thread_7.x;
    uint _S1070 = group_7.x;
    WideGroup_0 _S1071 = wide_group_0(params_11->wide_chunk_table_0, _S1070, &kernelContext_71);
    thread Island_natural_0 _S1072 = *((&kernelContext_71)->islands_0+_S1071.island_3);
    uint _S1073 = (uint4((&_S1072)->info_0) ).x;
    bool _S1074;
    if((_S1073 & 1U) != 0U)
    {
        _S1074 = true;
    }
    else
    {
        bool _S1075 = wide_enter_1(tid_13, _S1071.island_3, &kernelContext_71);
        _S1074 = !_S1075;
    }
    if(_S1074)
    {
        return;
    }
    if((_S1073 & 16U) != 0U)
    {
        if(_S1070 != (_S1071.first_0))
        {
            return;
        }
        thread WideGroup_0 _S1076 = _S1071;
        Rigid_0 _S1077 = wide_rigid_frame_0(tid_13, &_S1072, &_S1076, &kernelContext_71);
        thread Rigid_0 rs_0 = _S1077;
        if(tid_13 != 0U)
        {
            _S1074 = true;
        }
        else
        {
            _S1074 = (_S1073 & 2U) != 0U;
        }
        if(_S1074)
        {
            return;
        }
        integrate_rigid_0(&_S1072, &rs_0, (&kernelContext_71)->params_0->dt_0);
        thread Quat_0 _S1078 = (&rs_0)->rot_0;
        float4 _S1079 = quat_vec_0(&_S1078);
        ((&kernelContext_71)->islands_0+_S1071.island_3)->rotation_0 = packed_float4(_S1079) ;
        ((&kernelContext_71)->islands_0+_S1071.island_3)->rotation_err_0 = packed_float4((&rs_0)->rot_err_0) ;
        ((&kernelContext_71)->islands_0+_S1071.island_3)->position_0 = packed_float4(float4((&rs_0)->pos_1, 0.0f)) ;
        ((&kernelContext_71)->islands_0+_S1071.island_3)->position_err_0 = packed_float4(float4((&rs_0)->pos_err_1, 0.0f)) ;
        ((&kernelContext_71)->islands_0+_S1071.island_3)->velocity_0 = packed_float4(float4((&rs_0)->vel_1, 0.0f)) ;
        ((&kernelContext_71)->islands_0+_S1071.island_3)->velocity_err_0 = packed_float4(float4((&rs_0)->vel_err_1, 0.0f)) ;
        ((&kernelContext_71)->islands_0+_S1071.island_3)->angular_velocity_0 = packed_float4(float4((&rs_0)->w_4, 0.0f)) ;
        ((&kernelContext_71)->islands_0+_S1071.island_3)->momentum_0 = packed_float4(float4((&rs_0)->l_2, 0.0f)) ;
        ((&kernelContext_71)->islands_0+_S1071.island_3)->momentum_err_0 = packed_float4(float4((&rs_0)->l_err_1, 0.0f)) ;
        return;
    }
    thread float3 tu_4;
    thread float3 pv_4;
    wide_partials_0(tid_13, _S1071.first_0, (&_S1072)->wide_groups_0, 2U, &tu_4, &pv_4, &kernelContext_71);
    thread float3 lu_3;
    thread float3 lv_3;
    wide_partials_0(tid_13, _S1071.first_0, (&_S1072)->wide_groups_0, 4U, &lu_3, &lv_3, &kernelContext_71);
    float4 _S1080 = float4((&_S1072)->wcom_0) ;
    float3 _S1081 = float3(_S1080.w) ;
    float3 tr_6 = tu_4 / _S1081;
    float3 dv_6 = pv_4 / _S1081;
    float4 _S1082 = float4((&_S1072)->winv0_0) ;
    float4 _S1083 = float4((&_S1072)->winv1_0) ;
    float4 _S1084 = float4((&_S1072)->winv2_0) ;
    float3 phi_5 = rows_mul_0(_S1082, _S1083, _S1084, lu_3);
    float3 dw_4 = rows_mul_0(_S1082, _S1083, _S1084, lv_3);
    uint c_27 = _S1071.begin_1 + tid_13;
    if(c_27 < (_S1071.end_0))
    {
        drift_apply_0(c_27, _S1080.xyz, tr_6, phi_5, dv_6, dw_4, &kernelContext_71);
    }
    if(_S1070 != (_S1071.first_0))
    {
        return;
    }
    thread WideGroup_0 _S1085 = _S1071;
    Rigid_0 _S1086 = wide_rigid_frame_0(tid_13, &_S1072, &_S1085, &kernelContext_71);
    thread Rigid_0 rg_15 = _S1086;
    if(tid_13 != 0U)
    {
        return;
    }
    if(!((_S1073 & 2U) != 0U))
    {
        integrate_rigid_0(&_S1072, &rg_15, (&kernelContext_71)->params_0->dt_0);
        drift_rigid_0(&_S1072, &rg_15, tr_6, phi_5, dv_6, dw_4);
    }
    thread Quat_0 _S1087 = (&rg_15)->rot_0;
    float4 _S1088 = quat_vec_0(&_S1087);
    ((&kernelContext_71)->islands_0+_S1071.island_3)->rotation_0 = packed_float4(_S1088) ;
    ((&kernelContext_71)->islands_0+_S1071.island_3)->rotation_err_0 = packed_float4((&rg_15)->rot_err_0) ;
    ((&kernelContext_71)->islands_0+_S1071.island_3)->position_0 = packed_float4(float4((&rg_15)->pos_1, 0.0f)) ;
    ((&kernelContext_71)->islands_0+_S1071.island_3)->position_err_0 = packed_float4(float4((&rg_15)->pos_err_1, 0.0f)) ;
    ((&kernelContext_71)->islands_0+_S1071.island_3)->velocity_0 = packed_float4(float4((&rg_15)->vel_1, 0.0f)) ;
    ((&kernelContext_71)->islands_0+_S1071.island_3)->velocity_err_0 = packed_float4(float4((&rg_15)->vel_err_1, 0.0f)) ;
    ((&kernelContext_71)->islands_0+_S1071.island_3)->angular_velocity_0 = packed_float4(float4((&rg_15)->w_4, 0.0f)) ;
    ((&kernelContext_71)->islands_0+_S1071.island_3)->momentum_0 = packed_float4(float4((&rg_15)->l_2, 0.0f)) ;
    ((&kernelContext_71)->islands_0+_S1071.island_3)->momentum_err_0 = packed_float4(float4((&rg_15)->l_err_1, 0.0f)) ;
    return;
}

[[kernel]] void wide_end(uint3 group_8 [[threadgroup_position_in_grid]], uint3 thread_8 [[thread_position_in_threadgroup]], Params_0 constant* params_12 [[buffer(0)]], Island_natural_0 device* islands_12 [[buffer(9)]], uint device* index_12 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_12 [[buffer(3)]], packed_float4 device* state_14 [[buffer(6)]], packed_float4 device* scratch_12 [[buffer(8)]], packed_float4 device* contact_state_12 [[buffer(11)]], packed_float4 device* loads_12 [[buffer(5)]], Impactor_natural_0 device* impactors_12 [[buffer(10)]], BondStatic_natural_0 device* bonds_12 [[buffer(2)]], MaterialTable_0 constant* materials_12 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_12 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_72;
    (&kernelContext_72)->params_0 = params_12;
    (&kernelContext_72)->islands_0 = islands_12;
    (&kernelContext_72)->index_0 = index_12;
    (&kernelContext_72)->chunks_0 = chunks_12;
    (&kernelContext_72)->state_0 = state_14;
    (&kernelContext_72)->scratch_0 = scratch_12;
    (&kernelContext_72)->contact_state_0 = contact_state_12;
    (&kernelContext_72)->loads_0 = loads_12;
    (&kernelContext_72)->impactors_0 = impactors_12;
    (&kernelContext_72)->bonds_0 = bonds_12;
    (&kernelContext_72)->materials_0 = materials_12;
    (&kernelContext_72)->bond_dyn_0 = bond_dyn_12;
    threadgroup array<float4, int(32)> g_part_a_12;
    (&kernelContext_72)->g_part_a_0 = &g_part_a_12;
    threadgroup array<float4, int(32)> g_part_b_12;
    (&kernelContext_72)->g_part_b_0 = &g_part_b_12;
    threadgroup array<uint, int(5)> g_seen_12;
    (&kernelContext_72)->g_seen_0 = &g_seen_12;
    threadgroup uint g_run_12;
    (&kernelContext_72)->g_run_0 = &g_run_12;
    threadgroup uint g_halt_12;
    (&kernelContext_72)->g_halt_0 = &g_halt_12;
    threadgroup uint g_wide_run_12;
    (&kernelContext_72)->g_wide_run_0 = &g_wide_run_12;
    uint tid_14 = thread_8.x;
    uint _S1089 = group_8.x;
    WideGroup_0 _S1090 = wide_group_0(params_12->wide_chunk_table_0, _S1089, &kernelContext_72);
    if(_S1089 != (_S1090.first_0))
    {
        return;
    }
    Island_natural_0 device* _S1091 = (&kernelContext_72)->islands_0+_S1090.island_3;
    thread Island_natural_0 _S1092 = *_S1091;
    uint4 _S1093 = uint4((&_S1092)->info_0) ;
    float4 _S1094 = float4((&_S1092)->com_0) ;
    float4 _S1095 = float4((&_S1092)->inertia0_0) ;
    float4 _S1096 = float4((&_S1092)->inertia1_0) ;
    float4 _S1097 = float4((&_S1092)->inertia2_0) ;
    float4 _S1098 = float4((&_S1092)->inv0_0) ;
    float4 _S1099 = float4((&_S1092)->inv1_0) ;
    float4 _S1100 = float4((&_S1092)->inv2_0) ;
    float4 _S1101 = float4((&_S1092)->wcom_0) ;
    float4 _S1102 = float4((&_S1092)->winv0_0) ;
    float4 _S1103 = float4((&_S1092)->winv1_0) ;
    float4 _S1104 = float4((&_S1092)->winv2_0) ;
    float4 _S1105 = float4((&_S1092)->rotation_0) ;
    float4 _S1106 = float4((&_S1092)->position_0) ;
    float4 _S1107 = float4((&_S1092)->position_err_0) ;
    float4 _S1108 = float4((&_S1092)->velocity_0) ;
    float4 _S1109 = float4((&_S1092)->velocity_err_0) ;
    float4 _S1110 = float4((&_S1092)->angular_velocity_0) ;
    uint4 _S1111 = uint4((&_S1092)->probes_0) ;
    float4 _S1112 = float4((&_S1092)->energy_0) ;
    float4 _S1113 = float4((&_S1092)->rotation_err_0) ;
    float4 _S1114 = float4((&_S1092)->momentum_0) ;
    float4 _S1115 = float4((&_S1092)->momentum_err_0) ;
    thread Island_0 isl_22;
    (&isl_22)->range_0 = uint4((&_S1092)->range_0) ;
    (&isl_22)->info_0 = _S1093;
    (&isl_22)->com_0 = _S1094;
    (&isl_22)->inertia0_0 = _S1095;
    (&isl_22)->inertia1_0 = _S1096;
    (&isl_22)->inertia2_0 = _S1097;
    (&isl_22)->inv0_0 = _S1098;
    (&isl_22)->inv1_0 = _S1099;
    (&isl_22)->inv2_0 = _S1100;
    (&isl_22)->wcom_0 = _S1101;
    (&isl_22)->winv0_0 = _S1102;
    (&isl_22)->winv1_0 = _S1103;
    (&isl_22)->winv2_0 = _S1104;
    (&isl_22)->rotation_0 = _S1105;
    (&isl_22)->position_0 = _S1106;
    (&isl_22)->position_err_0 = _S1107;
    (&isl_22)->velocity_0 = _S1108;
    (&isl_22)->velocity_err_0 = _S1109;
    (&isl_22)->angular_velocity_0 = _S1110;
    (&isl_22)->done_0 = (&_S1092)->done_0;
    (&isl_22)->coverage_0 = (&_S1092)->coverage_0;
    (&isl_22)->wide_groups_0 = (&_S1092)->wide_groups_0;
    (&isl_22)->done_pad_0 = (&_S1092)->done_pad_0;
    (&isl_22)->probes_0 = _S1111;
    (&isl_22)->energy_0 = _S1112;
    (&isl_22)->rotation_err_0 = _S1113;
    (&isl_22)->momentum_0 = _S1114;
    (&isl_22)->momentum_err_0 = _S1115;
    _S1092 = *_S1091;
    bool _S1116 = wide_enter_0(tid_14, &_S1092, &kernelContext_72);
    if(!_S1116)
    {
        return;
    }
    thread float3 work_5;
    thread float3 flags_2;
    wide_partials_0(tid_14, _S1090.first_0, (&isl_22)->wide_groups_0, 6U, &work_5, &flags_2, &kernelContext_72);
    if(tid_14 != 0U)
    {
        return;
    }
    thread Island_0 _S1117 = isl_22;
    uint _S1118 = wide_step_1(&_S1117, &kernelContext_72);
    if(((&isl_22)->probes_0.y) > ((&isl_22)->probes_0.x))
    {
        thread Island_0 _S1119 = isl_22;
        Rigid_0 _S1120 = rigid_of_1(&_S1119);
        thread Island_0 _S1121 = isl_22;
        thread Rigid_0 _S1122 = _S1120;
        record_probes_0(&_S1121, &_S1122, _S1118, &kernelContext_72);
    }
    bool halt_0 = (((&isl_22)->info_0.z) & 2U) != 0U;
    bool _S1123;
    if(halt_0)
    {
        _S1123 = (((&isl_22)->info_0.x) & 4U) != 0U;
    }
    else
    {
        _S1123 = false;
    }
    if(_S1123)
    {
        contact_split_at_0((&isl_22)->info_0.w + 1U, &kernelContext_72);
    }
    float _S1124 = work_5.x;
    thread float _S1125 = (&isl_22)->energy_0.x;
    thread float _S1126 = (&isl_22)->energy_0.y;
    comp_add1_0(&_S1125, &_S1126, _S1124);
    (&isl_22)->energy_0.x = _S1125;
    (&isl_22)->energy_0.y = _S1126 + work_5.y;
    (&isl_22)->done_0 = (&isl_22)->done_0 + 1U;
    (&isl_22)->info_0.y = (&isl_22)->info_0.y - 1U;
    (&isl_22)->info_0.w = (&isl_22)->info_0.w + 1U;
    if(halt_0)
    {
        (&isl_22)->info_0.z = (((&isl_22)->info_0.z) & 4294967293U) | 1U;
    }
    uint _S1127;
    if(halt_0)
    {
        _S1127 = 128U;
    }
    else
    {
        _S1127 = 0U;
    }
    uint _S1128 = 256U | _S1127;
    if(((&isl_22)->probes_0.y) > ((&isl_22)->probes_0.x))
    {
        _S1127 = 262144U;
    }
    else
    {
        _S1127 = 0U;
    }
    uint _S1129 = _S1128 | _S1127;
    if((((&isl_22)->info_0.x) & 4U) != 0U)
    {
        _S1127 = 524288U;
    }
    else
    {
        _S1127 = 0U;
    }
    uint _S1130 = _S1129 | _S1127;
    if((flags_2.x) > 0.0f)
    {
        _S1127 = 32768U;
    }
    else
    {
        _S1127 = 0U;
    }
    uint _S1131 = _S1130 | _S1127;
    if((flags_2.y) > 0.0f)
    {
        _S1127 = 65536U;
    }
    else
    {
        _S1127 = 0U;
    }
    uint _S1132 = _S1131 | _S1127;
    if((flags_2.z) > 0.0f)
    {
        _S1127 = 131072U;
    }
    else
    {
        _S1127 = 0U;
    }
    (&isl_22)->coverage_0 = ((&isl_22)->coverage_0) | (_S1132 | _S1127);
    Island_natural_0 device* _S1133 = (&kernelContext_72)->islands_0+_S1090.island_3;
    _S1133->range_0 = packed_uint4(isl_22.range_0) ;
    _S1133->info_0 = packed_uint4(isl_22.info_0) ;
    _S1133->com_0 = packed_float4(isl_22.com_0) ;
    _S1133->inertia0_0 = packed_float4(isl_22.inertia0_0) ;
    _S1133->inertia1_0 = packed_float4(isl_22.inertia1_0) ;
    _S1133->inertia2_0 = packed_float4(isl_22.inertia2_0) ;
    _S1133->inv0_0 = packed_float4(isl_22.inv0_0) ;
    _S1133->inv1_0 = packed_float4(isl_22.inv1_0) ;
    _S1133->inv2_0 = packed_float4(isl_22.inv2_0) ;
    _S1133->wcom_0 = packed_float4(isl_22.wcom_0) ;
    _S1133->winv0_0 = packed_float4(isl_22.winv0_0) ;
    _S1133->winv1_0 = packed_float4(isl_22.winv1_0) ;
    _S1133->winv2_0 = packed_float4(isl_22.winv2_0) ;
    _S1133->rotation_0 = packed_float4(isl_22.rotation_0) ;
    _S1133->position_0 = packed_float4(isl_22.position_0) ;
    _S1133->position_err_0 = packed_float4(isl_22.position_err_0) ;
    _S1133->velocity_0 = packed_float4(isl_22.velocity_0) ;
    _S1133->velocity_err_0 = packed_float4(isl_22.velocity_err_0) ;
    _S1133->angular_velocity_0 = packed_float4(isl_22.angular_velocity_0) ;
    _S1133->done_0 = isl_22.done_0;
    _S1133->coverage_0 = isl_22.coverage_0;
    _S1133->wide_groups_0 = isl_22.wide_groups_0;
    _S1133->done_pad_0 = isl_22.done_pad_0;
    _S1133->probes_0 = packed_uint4(isl_22.probes_0) ;
    _S1133->energy_0 = packed_float4(isl_22.energy_0) ;
    _S1133->rotation_err_0 = packed_float4(isl_22.rotation_err_0) ;
    _S1133->momentum_0 = packed_float4(isl_22.momentum_0) ;
    _S1133->momentum_err_0 = packed_float4(isl_22.momentum_err_0) ;
    return;
}

uint sv_0(uint c_28, uint slot_3, KernelContext_0 thread* kernelContext_73)
{
    return kernelContext_73->params_0->statics_base_0 + 23U * c_28 + slot_3;
}

void project_load_slot_0(uint tid_15, const Island_natural_0 thread* isl_23, uint slot_4, KernelContext_0 thread* kernelContext_74)
{
    uint _S1134;
    float3 _S1135 = float3(0.0f) ;
    thread float3 net_f_0 = _S1135;
    thread float3 net_m_0 = _S1135;
    uint4 _S1136 = uint4(isl_23->range_0) ;
    uint _S1137 = _S1136.x + tid_15;
    uint c_29 = _S1137;
    for(;;)
    {
        uint _S1138 = _S1136.y;
        _S1134 = _S1138;
        if(c_29 < _S1138)
        {
        }
        else
        {
            break;
        }
        uint _S1139 = sv_0(c_29, slot_4, kernelContext_74);
        float3 fi_2 = (float4(*(kernelContext_74->scratch_0+_S1139)) ).xyz;
        net_f_0 = net_f_0 + fi_2;
        float3 _S1140 = cross((float4((kernelContext_74->chunks_0+c_29)->center_0) ).xyz - (float4(isl_23->com_0) ).xyz, fi_2);
        uint _S1141 = sv_0(c_29, slot_4 + 1U, kernelContext_74);
        net_m_0 = net_m_0 + (_S1140 + (float4(*(kernelContext_74->scratch_0+_S1141)) ).xyz);
        c_29 = c_29 + 256U;
    }
    group_sum3_0(tid_15, &net_f_0, &net_m_0, kernelContext_74);
    float4 _S1142 = float4(isl_23->com_0) ;
    float3 _S1143 = net_f_0 / float3(_S1142.w) ;
    float3 _S1144 = rows_mul_0(float4(isl_23->inv0_0) , float4(isl_23->inv1_0) , float4(isl_23->inv2_0) , net_m_0);
    c_29 = _S1137;
    for(;;)
    {
        if(c_29 < _S1134)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_natural_0 device* _S1145 = kernelContext_74->chunks_0+c_29;
        float4 _S1146 = float4(_S1145->center_0) ;
        float3 r_12 = _S1146.xyz - _S1142.xyz;
        uint _S1147 = sv_0(c_29, slot_4, kernelContext_74);
        *(kernelContext_74->scratch_0+_S1147) = packed_float4(float4((float4(*(kernelContext_74->scratch_0+_S1147)) ).xyz - (_S1143 + cross(_S1144, r_12)) * float3(_S1146.w) , 0.0f)) ;
        uint _S1148 = sv_0(c_29, slot_4 + 1U, kernelContext_74);
        *(kernelContext_74->scratch_0+_S1148) = packed_float4(float4((float4(*(kernelContext_74->scratch_0+_S1148)) ).xyz - rows_mul_0(float4(_S1145->inertia0_1) , float4(_S1145->inertia1_1) , float4(_S1145->inertia2_1) , _S1144), 0.0f)) ;
        c_29 = c_29 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    return;
}

float island_dot_0(uint tid_16, uint c0_0, uint c1_0, uint sa_2, uint sb_2, KernelContext_0 thread* kernelContext_75)
{
    float4 _S1149 = float4(0.0f) ;
    thread float4 acc_0 = _S1149;
    thread float4 unused_4 = _S1149;
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
        uint _S1150 = sv_0(c_30, sa_2, kernelContext_75);
        float3 _S1151 = (float4(*(kernelContext_75->scratch_0+_S1150)) ).xyz;
        uint _S1152 = sv_0(c_30, sb_2, kernelContext_75);
        float _S1153 = dot(_S1151, (float4(*(kernelContext_75->scratch_0+_S1152)) ).xyz);
        uint _S1154 = sv_0(c_30, sa_2 + 1U, kernelContext_75);
        float3 _S1155 = (float4(*(kernelContext_75->scratch_0+_S1154)) ).xyz;
        uint _S1156 = sv_0(c_30, sb_2 + 1U, kernelContext_75);
        acc_0.x = acc_0.x + (_S1153 + dot(_S1155, (float4(*(kernelContext_75->scratch_0+_S1156)) ).xyz));
        c_30 = c_30 + 256U;
    }
    group_sum2_0(tid_16, &acc_0, &unused_4, kernelContext_75);
    return acc_0.x;
}

void static_kinematics_0(uint _S1157, float3 thread* _S1158, float3 thread* _S1159, KernelContext_0 thread* kernelContext_76)
{
    BondStatic_natural_0 device* _S1160 = kernelContext_76->bonds_0+_S1157;
    uint4 _S1161 = uint4(_S1160->law_0.ids_0) ;
    uint ca_1 = _S1161.y;
    uint cb_1 = _S1161.z;
    uint _S1162 = 4U * cb_1;
    uint _S1163 = 4U * ca_1;
    float3 _S1164 = (float4(*(kernelContext_76->state_0+_S1162)) ).xyz - (float4(*(kernelContext_76->state_0+_S1163)) ).xyz;
    uint _S1165 = sv_0(cb_1, 21U, kernelContext_76);
    float3 _S1166 = (float4(*(kernelContext_76->scratch_0+_S1165)) ).xyz;
    uint _S1167 = sv_0(ca_1, 21U, kernelContext_76);
    float3 du_0 = _S1164 + (_S1166 - (float4(*(kernelContext_76->scratch_0+_S1167)) ).xyz);
    uint _S1168 = _S1162 + 1U;
    uint _S1169 = _S1163 + 1U;
    float3 _S1170 = (float4(*(kernelContext_76->state_0+_S1168)) ).xyz - (float4(*(kernelContext_76->state_0+_S1169)) ).xyz;
    uint _S1171 = sv_0(cb_1, 22U, kernelContext_76);
    float3 _S1172 = (float4(*(kernelContext_76->scratch_0+_S1171)) ).xyz;
    uint _S1173 = sv_0(ca_1, 22U, kernelContext_76);
    float3 dth_0 = _S1170 + (_S1172 - (float4(*(kernelContext_76->scratch_0+_S1173)) ).xyz);
    float3 _S1174 = to_local_0(_S1157, du_0 + (cross((float4(*(kernelContext_76->state_0+_S1168)) ).xyz + (float4(*(kernelContext_76->scratch_0+_S1171)) ).xyz, (float4(_S1160->rb_0) ).xyz) - cross((float4(*(kernelContext_76->state_0+_S1169)) ).xyz + (float4(*(kernelContext_76->scratch_0+_S1173)) ).xyz, (float4(_S1160->ra_0) ).xyz)), kernelContext_76);
    *_S1158 = _S1174;
    float3 _S1175 = to_local_0(_S1157, dth_0, kernelContext_76);
    *_S1159 = _S1175;
    return;
}

JointResponse_0 static_response_0(uint i_12, KernelContext_0 thread* kernelContext_77)
{
    BondStatic_natural_0 device* _S1176 = kernelContext_77->bonds_0+i_12;
    thread float3 d_lin_4;
    thread float3 d_ang_3;
    static_kinematics_0(i_12, &d_lin_4, &d_ang_3, kernelContext_77);
    thread JointBond_natural_0 _S1177 = _S1176->law_0;
    _S1177 = _S1176->law_0;
    thread JointState_0 _S1178 = (kernelContext_77->bond_dyn_0+i_12)->js_0;
    JointResponse_0 _S1179 = joint_evaluate_0(&kernelContext_77->materials_0->m_0[(uint4((&_S1177)->ids_0) ).x], &_S1177, &_S1178, d_lin_4, d_ang_3, 0.0f, false);
    return _S1179;
}

void gather_loads_0(uint c_31, float3 thread* fi_3, float3 thread* mi_6, KernelContext_0 thread* kernelContext_78)
{
    float3 _S1180 = float3(0.0f) ;
    *fi_3 = _S1180;
    *mi_6 = _S1180;
    uint e_5 = kernelContext_78->index_0[c_31];
    for(;;)
    {
        if(e_5 < (kernelContext_78->index_0)[c_31 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_4 = kernelContext_78->index_0[e_5];
        uint bond_0 = entry_4 >> 1U;
        if((entry_4 & 1U) == 0U)
        {
            uint _S1181 = 3U * bond_0;
            *fi_3 = *fi_3 + (float4(*(kernelContext_78->scratch_0+_S1181)) ).xyz;
            *mi_6 = *mi_6 + (float4(*(kernelContext_78->scratch_0+(_S1181 + 1U))) ).xyz;
        }
        else
        {
            uint _S1182 = 3U * bond_0;
            *fi_3 = *fi_3 - (float4(*(kernelContext_78->scratch_0+_S1182)) ).xyz;
            *mi_6 = *mi_6 + (float4(*(kernelContext_78->scratch_0+(_S1182 + 2U))) ).xyz;
        }
        e_5 = e_5 + 1U;
    }
    return;
}

float bond_load_magnitude2_0(uint c_32, KernelContext_0 thread* kernelContext_79)
{
    uint e_6 = kernelContext_79->index_0[c_32];
    float m_7 = 0.0f;
    for(;;)
    {
        if(e_6 < (kernelContext_79->index_0)[c_32 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_5 = kernelContext_79->index_0[e_6];
        uint _S1183 = 3U * (entry_5 >> 1U);
        float3 f_18 = (float4(*(kernelContext_79->scratch_0+_S1183)) ).xyz;
        float3 t_18;
        if((entry_5 & 1U) == 0U)
        {
            t_18 = (float4(*(kernelContext_79->scratch_0+(_S1183 + 1U))) ).xyz;
        }
        else
        {
            t_18 = (float4(*(kernelContext_79->scratch_0+(_S1183 + 2U))) ).xyz;
        }
        float m_8 = m_7 + (dot(f_18, f_18) + dot(t_18, t_18));
        e_6 = e_6 + 1U;
        m_7 = m_8;
    }
    return m_7;
}

uint fixed_mask_0(uint c_33, KernelContext_0 thread* kernelContext_80)
{
    uint support_2 = (uint4((kernelContext_80->chunks_0+c_33)->info_1) ).x;
    uint _S1184;
    if(support_2 == 1U)
    {
        _S1184 = 63U;
    }
    else
    {
        if(support_2 == 2U)
        {
            _S1184 = 7U;
        }
        else
        {
            _S1184 = 0U;
        }
    }
    return _S1184;
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

uint statics_bond_slot_0(uint i_13, KernelContext_0 thread* kernelContext_81)
{
    return kernelContext_81->params_0->statics_base_0 + 23U * kernelContext_81->params_0->chunk_count_0 + 2U * i_13;
}

void store_inverse_0(uint c_34, const array<float, int(36)> thread* a_14, KernelContext_0 thread* kernelContext_82)
{
    uint j_7;
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
        bool _S1185;
        if(i_14 < 6U)
        {
            _S1185 = spd_0;
        }
        else
        {
            _S1185 = false;
        }
        if(_S1185)
        {
        }
        else
        {
            break;
        }
        j_7 = 0U;
        for(;;)
        {
            if(j_7 <= i_14)
            {
            }
            else
            {
                break;
            }
            uint _S1186 = i_14 * 6U;
            uint _S1187 = _S1186 + j_7;
            k_21 = 0U;
            sum_4 = (*a_14)[_S1187];
            for(;;)
            {
                if(k_21 < j_7)
                {
                }
                else
                {
                    break;
                }
                float sum_5 = sum_4 - l_5[_S1186 + k_21] * l_5[j_7 * 6U + k_21];
                k_21 = k_21 + 1U;
                sum_4 = sum_5;
            }
            if(i_14 == j_7)
            {
                if(sum_4 <= 0.0f)
                {
                    spd_0 = false;
                    break;
                }
                l_5[_S1186 + i_14] = sqrt(sum_4);
            }
            else
            {
                l_5[_S1187] = sum_4 / l_5[j_7 * 6U + j_7];
            }
            j_7 = j_7 + 1U;
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
            uint _S1188 = k_21 * 6U + k_21;
            float _S1189 = (*a_14)[_S1188];
            if(((*a_14)[_S1188]) > 0.0f)
            {
                sum_4 = 1.0f / _S1189;
            }
            else
            {
                sum_4 = 0.0f;
            }
            inv_0[_S1188] = sum_4;
            k_21 = k_21 + 1U;
        }
    }
    else
    {
        j_7 = 0U;
        for(;;)
        {
            if(j_7 < 6U)
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
                if(i_14 == j_7)
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
            thread array<float, int(6)> x_11;
            x_11[int(0)] = 0.0f;
            x_11[int(1)] = 0.0f;
            x_11[int(2)] = 0.0f;
            x_11[int(3)] = 0.0f;
            x_11[int(4)] = 0.0f;
            x_11[int(5)] = 0.0f;
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
                    float s_10 = sum_4 - l_5[k_21 * 6U + i_15] * x_11[k_21];
                    k_21 = k_21 + 1U;
                    sum_4 = s_10;
                }
                x_11[i_15] = sum_4 / l_5[i_15 * 6U + i_15];
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
                inv_0[i_16 * 6U + j_7] = x_11[i_16];
                i_16 = i_16 + 1U;
            }
            j_7 = j_7 + 1U;
        }
    }
    j_7 = 0U;
    for(;;)
    {
        if(j_7 < 9U)
        {
        }
        else
        {
            break;
        }
        uint _S1190 = sv_0(c_34, 12U + j_7, kernelContext_82);
        uint _S1191 = 4U * j_7;
        *(kernelContext_82->scratch_0+_S1190) = packed_float4(float4(inv_0[_S1191], inv_0[_S1191 + 1U], inv_0[_S1191 + 2U], inv_0[_S1191 + 3U])) ;
        j_7 = j_7 + 1U;
    }
    return;
}

void assemble_block_0(uint c_35, KernelContext_0 thread* kernelContext_83)
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
    uint e_7 = kernelContext_83->index_0[c_35];
    for(;;)
    {
        if(e_7 < (kernelContext_83->index_0)[c_35 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_6 = kernelContext_83->index_0[e_7];
        uint i_17 = entry_6 >> 1U;
        bool _S1192 = (entry_6 & 1U) != 0U;
        BondStatic_natural_0 device* _S1193 = kernelContext_83->bonds_0+i_17;
        uint _S1194 = statics_bond_slot_0(i_17, kernelContext_83);
        float4 _S1195 = float4(*(kernelContext_83->scratch_0+_S1194)) ;
        float4 _S1196 = float4(*(kernelContext_83->scratch_0+(_S1194 + 1U))) ;
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
            uint _S1197 = p_16 % 3U;
            float3 t_19;
            if(_S1197 == 0U)
            {
                t_19 = (float4(_S1193->t1_0) ).xyz;
            }
            else
            {
                if(_S1197 == 1U)
                {
                    t_19 = (float4(_S1193->t2_0) ).xyz;
                }
                else
                {
                    t_19 = (float4(_S1193->normal_0) ).xyz;
                }
            }
            bool _S1198 = p_16 < 3U;
            float3 row_u_0;
            float3 row_t_0;
            if(_S1198)
            {
                if(_S1192)
                {
                    row_u_0 = t_19;
                }
                else
                {
                    row_u_0 = - t_19;
                }
                if(_S1192)
                {
                    row_t_0 = cross((float4(_S1193->rb_0) ).xyz, t_19);
                }
                else
                {
                    row_t_0 = - cross((float4(_S1193->ra_0) ).xyz, t_19);
                }
            }
            else
            {
                float3 _S1199 = float3(0.0f) ;
                if(_S1192)
                {
                    row_u_0 = t_19;
                }
                else
                {
                    row_u_0 = - t_19;
                }
                float3 _S1200 = row_u_0;
                row_u_0 = _S1199;
                row_t_0 = _S1200;
            }
            float kp_0;
            if(_S1198)
            {
                kp_0 = _S1195[p_16];
            }
            else
            {
                kp_0 = _S1196[p_16 - 3U];
            }
            if(kp_0 == 0.0f)
            {
                p_16 = p_16 + 1U;
                continue;
            }
            array<float, int(6)> _S1201 = { { row_u_0.x, row_u_0.y, row_u_0.z, row_t_0.x, row_t_0.y, row_t_0.z } };
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
                    a_15[r_13 * 6U + q_15] = a_15[r_13 * 6U + q_15] + kp_0 * _S1201[r_13] * _S1201[q_15];
                    q_15 = q_15 + 1U;
                }
                r_13 = r_13 + 1U;
            }
            p_16 = p_16 + 1U;
        }
        e_7 = e_7 + 1U;
    }
    uint _S1202 = fixed_mask_0(c_35, kernelContext_83);
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
        if((_S1202 & (1U << p_16)) != 0U)
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
    thread array<float, int(36)> _S1203 = a_15;
    store_inverse_0(c_35, &_S1203, kernelContext_83);
    return;
}

float block_get_0(uint c_36, uint i_18, uint j_8, KernelContext_0 thread* kernelContext_84)
{
    uint k_23 = i_18 * 6U + j_8;
    uint _S1204 = sv_0(c_36, 12U + k_23 / 4U, kernelContext_84);
    return (*(kernelContext_84->scratch_0+_S1204))[k_23 % 4U];
}

void precondition_0(uint c_37, KernelContext_0 thread* kernelContext_85)
{
    uint _S1205 = sv_0(c_37, 4U, kernelContext_85);
    float4 _S1206 = float4(*(kernelContext_85->scratch_0+_S1205)) ;
    uint _S1207 = sv_0(c_37, 5U, kernelContext_85);
    float4 _S1208 = float4(*(kernelContext_85->scratch_0+_S1207)) ;
    array<float, int(6)> _S1209 = { { _S1206.x, _S1206.y, _S1206.z, _S1208.x, _S1208.y, _S1208.z } };
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
        uint j_9 = 0U;
        float s_11 = 0.0f;
        for(;;)
        {
            if(j_9 < 6U)
            {
            }
            else
            {
                break;
            }
            float _S1210 = block_get_0(c_37, i_19, j_9, kernelContext_85);
            float s_12 = s_11 + _S1210 * _S1209[j_9];
            j_9 = j_9 + 1U;
            s_11 = s_12;
        }
        z_1[i_19] = s_11;
        i_19 = i_19 + 1U;
    }
    uint _S1211 = sv_0(c_37, 6U, kernelContext_85);
    *(kernelContext_85->scratch_0+_S1211) = packed_float4(float4(z_1[int(0)], z_1[int(1)], z_1[int(2)], 0.0f)) ;
    uint _S1212 = sv_0(c_37, 7U, kernelContext_85);
    *(kernelContext_85->scratch_0+_S1212) = packed_float4(float4(z_1[int(3)], z_1[int(4)], z_1[int(5)], 0.0f)) ;
    return;
}

void project_displacement_slot_0(uint tid_17, const Island_natural_0 thread* isl_24, uint slot_5, KernelContext_0 thread* kernelContext_86)
{
    uint _S1213;
    float3 _S1214 = float3(0.0f) ;
    thread float3 p_17 = _S1214;
    thread float3 l_6 = _S1214;
    uint4 _S1215 = uint4(isl_24->range_0) ;
    uint _S1216 = _S1215.x + tid_17;
    uint c_38 = _S1216;
    for(;;)
    {
        uint _S1217 = _S1215.y;
        _S1213 = _S1217;
        if(c_38 < _S1217)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_natural_0 device* _S1218 = kernelContext_86->chunks_0+c_38;
        uint _S1219 = sv_0(c_38, slot_5, kernelContext_86);
        float3 u_6 = (float4(*(kernelContext_86->scratch_0+_S1219)) ).xyz;
        uint _S1220 = sv_0(c_38, slot_5 + 1U, kernelContext_86);
        float3 th_7 = (float4(*(kernelContext_86->scratch_0+_S1220)) ).xyz;
        float4 _S1221 = float4(_S1218->center_0) ;
        float3 r_14 = _S1221.xyz - (float4(isl_24->com_0) ).xyz;
        float3 _S1222 = float3(_S1221.w) ;
        p_17 = p_17 + u_6 * _S1222;
        l_6 = l_6 + (cross(r_14, u_6) * _S1222 + rows_mul_0(float4(_S1218->inertia0_1) , float4(_S1218->inertia1_1) , float4(_S1218->inertia2_1) , th_7));
        c_38 = c_38 + 256U;
    }
    group_sum3_0(tid_17, &p_17, &l_6, kernelContext_86);
    float4 _S1223 = float4(isl_24->com_0) ;
    float3 _S1224 = p_17 / float3(_S1223.w) ;
    float3 _S1225 = rows_mul_0(float4(isl_24->inv0_0) , float4(isl_24->inv1_0) , float4(isl_24->inv2_0) , l_6);
    c_38 = _S1216;
    for(;;)
    {
        if(c_38 < _S1213)
        {
        }
        else
        {
            break;
        }
        float3 r_15 = (float4((kernelContext_86->chunks_0+c_38)->center_0) ).xyz - _S1223.xyz;
        uint _S1226 = sv_0(c_38, slot_5, kernelContext_86);
        *(kernelContext_86->scratch_0+_S1226) = packed_float4(float4((float4(*(kernelContext_86->scratch_0+_S1226)) ).xyz - _S1224 - cross(_S1225, r_15), 0.0f)) ;
        uint _S1227 = sv_0(c_38, slot_5 + 1U, kernelContext_86);
        *(kernelContext_86->scratch_0+_S1227) = packed_float4(float4((float4(*(kernelContext_86->scratch_0+_S1227)) ).xyz - _S1225, 0.0f)) ;
        c_38 = c_38 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    return;
}

uint statics_result_slot_0(uint island_4, KernelContext_0 thread* kernelContext_87)
{
    return kernelContext_87->params_0->statics_base_0 + 23U * kernelContext_87->params_0->chunk_count_0 + 2U * kernelContext_87->params_0->statics_bonds_0 + island_4;
}

void write_bond_loads_0(uint _S1228, uint _S1229, float3 _S1230, float3 _S1231, float _S1232, KernelContext_0 thread* kernelContext_88)
{
    BondStatic_natural_0 device* _S1233 = kernelContext_88->bonds_0+_S1229;
    float3 _S1234 = to_body_0(_S1229, _S1230, kernelContext_88);
    float3 _S1235 = to_body_0(_S1229, _S1231, kernelContext_88);
    uint _S1236 = 3U * _S1228;
    *(kernelContext_88->scratch_0+_S1236) = packed_float4(float4(_S1234, _S1232)) ;
    *(kernelContext_88->scratch_0+(_S1236 + 1U)) = packed_float4(float4(_S1235 + cross((float4(_S1233->ra_0) ).xyz, _S1234), 0.0f)) ;
    *(kernelContext_88->scratch_0+(_S1236 + 2U)) = packed_float4(float4(- _S1235 + cross((float4(_S1233->rb_0) ).xyz, - _S1234), 0.0f)) ;
    return;
}

void bond_kinematics_0(uint _S1237, float3 _S1238, float3 _S1239, float3 _S1240, float3 _S1241, float3 thread* _S1242, float3 thread* _S1243, KernelContext_0 thread* kernelContext_89)
{
    BondStatic_natural_0 device* _S1244 = kernelContext_89->bonds_0+_S1237;
    float3 _S1245 = to_local_0(_S1237, _S1240 + cross(_S1241, (float4(_S1244->rb_0) ).xyz) - (_S1238 + cross(_S1239, (float4(_S1244->ra_0) ).xyz)), kernelContext_89);
    *_S1242 = _S1245;
    float3 _S1246 = to_local_0(_S1237, _S1241 - _S1239, kernelContext_89);
    *_S1243 = _S1246;
    return;
}

[[kernel]] void island_statics(uint3 group_9 [[threadgroup_position_in_grid]], uint3 thread_9 [[thread_position_in_threadgroup]], Params_0 constant* params_13 [[buffer(0)]], Island_natural_0 device* islands_13 [[buffer(9)]], uint device* index_13 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_13 [[buffer(3)]], packed_float4 device* state_15 [[buffer(6)]], packed_float4 device* scratch_13 [[buffer(8)]], packed_float4 device* contact_state_13 [[buffer(11)]], packed_float4 device* loads_13 [[buffer(5)]], Impactor_natural_0 device* impactors_13 [[buffer(10)]], BondStatic_natural_0 device* bonds_13 [[buffer(2)]], MaterialTable_0 constant* materials_13 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_13 [[buffer(7)]])
{
    uint i_20;
    bool converged_0;
    uint c_39;
    thread KernelContext_0 kernelContext_90;
    (&kernelContext_90)->params_0 = params_13;
    (&kernelContext_90)->islands_0 = islands_13;
    (&kernelContext_90)->index_0 = index_13;
    (&kernelContext_90)->chunks_0 = chunks_13;
    (&kernelContext_90)->state_0 = state_15;
    (&kernelContext_90)->scratch_0 = scratch_13;
    (&kernelContext_90)->contact_state_0 = contact_state_13;
    (&kernelContext_90)->loads_0 = loads_13;
    (&kernelContext_90)->impactors_0 = impactors_13;
    (&kernelContext_90)->bonds_0 = bonds_13;
    (&kernelContext_90)->materials_0 = materials_13;
    (&kernelContext_90)->bond_dyn_0 = bond_dyn_13;
    threadgroup array<float4, int(32)> g_part_a_13;
    (&kernelContext_90)->g_part_a_0 = &g_part_a_13;
    threadgroup array<float4, int(32)> g_part_b_13;
    (&kernelContext_90)->g_part_b_0 = &g_part_b_13;
    threadgroup array<uint, int(5)> g_seen_13;
    (&kernelContext_90)->g_seen_0 = &g_seen_13;
    threadgroup uint g_run_13;
    (&kernelContext_90)->g_run_0 = &g_run_13;
    threadgroup uint g_halt_13;
    (&kernelContext_90)->g_halt_0 = &g_halt_13;
    threadgroup uint g_wide_run_13;
    (&kernelContext_90)->g_wide_run_0 = &g_wide_run_13;
    uint tid_18 = thread_9.x;
    uint _S1247 = group_9.x;
    thread Island_natural_0 _S1248 = *(islands_13+_S1247);
    uint4 _S1249 = uint4((&_S1248)->info_0) ;
    uint _S1250 = _S1249.z;
    if((_S1250 & 8U) == 0U)
    {
        return;
    }
    bool free_0 = ((_S1249.x) & 1U) == 0U;
    uint4 _S1251 = uint4((&_S1248)->range_0) ;
    uint c0_1 = _S1251.x;
    uint c1_1 = _S1251.y;
    uint b0_0 = _S1251.z;
    uint _S1252 = _S1251.w;
    uint _S1253 = c0_1 + tid_18;
    uint c_40 = _S1253;
    for(;;)
    {
        if(c_40 < c1_1)
        {
        }
        else
        {
            break;
        }
        uint _S1254 = sv_0(c_40, 21U, &kernelContext_90);
        packed_float4 _S1255 = packed_float4(float4(0.0f) ) ;
        *((&kernelContext_90)->scratch_0+_S1254) = _S1255;
        uint _S1256 = sv_0(c_40, 22U, &kernelContext_90);
        *((&kernelContext_90)->scratch_0+_S1256) = _S1255;
        c_40 = c_40 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    if(free_0)
    {
        project_load_slot_0(tid_18, &_S1248, 0U, &kernelContext_90);
    }
    float _S1257 = island_dot_0(tid_18, c0_1, c1_1, 0U, 0U, &kernelContext_90);
    float _S1258 = max(sqrt(_S1257), 1.00000000317107685e-30f);
    float _S1259 = (&kernelContext_90)->params_0->statics_tol_0;
    uint _S1260 = min((&kernelContext_90)->params_0->statics_cg_0, 20U * (c1_1 - c0_1) * 6U + 200U);
    float previous_2 = 1.00000001504746622e+30f;
    float residual_0 = 0.0f;
    uint newton_0 = 0U;
    uint cg_total_0 = 0U;
    for(;;)
    {
        if(newton_0 < ((&kernelContext_90)->params_0->statics_newton_0))
        {
        }
        else
        {
            converged_0 = false;
            break;
        }
        uint _S1261 = b0_0 + tid_18;
        i_20 = _S1261;
        for(;;)
        {
            if(i_20 < _S1252)
            {
            }
            else
            {
                break;
            }
            JointResponse_0 _S1262 = static_response_0(i_20, &kernelContext_90);
            write_bond_loads_0(i_20, i_20, _S1262.force_lin_1, _S1262.force_ang_1, 0.0f, &kernelContext_90);
            i_20 = i_20 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        float4 _S1263 = float4(0.0f) ;
        thread float4 magnitude_0 = _S1263;
        thread float4 unused_m_0 = _S1263;
        c_40 = _S1253;
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
            gather_loads_0(c_40, &fi_4, &mi_7, &kernelContext_90);
            float _S1264 = bond_load_magnitude2_0(c_40, &kernelContext_90);
            magnitude_0.x = magnitude_0.x + _S1264;
            uint _S1265 = sv_0(c_40, 0U, &kernelContext_90);
            thread float4 r_lin_0 = float4((float4(*((&kernelContext_90)->scratch_0+_S1265)) ).xyz + fi_4, 0.0f);
            uint _S1266 = sv_0(c_40, 1U, &kernelContext_90);
            thread float4 r_ang_0 = float4((float4(*((&kernelContext_90)->scratch_0+_S1266)) ).xyz + mi_7, 0.0f);
            uint _S1267 = fixed_mask_0(c_40, &kernelContext_90);
            hold_0(_S1267, &r_lin_0, &r_ang_0, _S1263, _S1263);
            uint _S1268 = sv_0(c_40, 4U, &kernelContext_90);
            *((&kernelContext_90)->scratch_0+_S1268) = packed_float4(r_lin_0) ;
            uint _S1269 = sv_0(c_40, 5U, &kernelContext_90);
            *((&kernelContext_90)->scratch_0+_S1269) = packed_float4(r_ang_0) ;
            c_40 = c_40 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        group_sum2_0(tid_18, &magnitude_0, &unused_m_0, &kernelContext_90);
        if(free_0)
        {
            project_load_slot_0(tid_18, &_S1248, 4U, &kernelContext_90);
        }
        float _S1270 = island_dot_0(tid_18, c0_1, c1_1, 4U, 4U, &kernelContext_90);
        float residual_1 = sqrt(_S1270) / _S1258;
        float _S1271 = max(0.00100000004749745f, 3.83999986297567375e-06f * sqrt(magnitude_0.x) / _S1258);
        if(residual_1 <= _S1259)
        {
            converged_0 = true;
        }
        else
        {
            if(residual_1 <= _S1271)
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
        uint i_21 = _S1261;
        for(;;)
        {
            if(i_21 < _S1252)
            {
            }
            else
            {
                break;
            }
            BondStatic_natural_0 device* _S1272 = (&kernelContext_90)->bonds_0+i_21;
            thread float3 d_lin_5;
            thread float3 d_ang_4;
            static_kinematics_0(i_21, &d_lin_5, &d_ang_4, &kernelContext_90);
            thread JointBond_natural_0 _S1273 = _S1272->law_0;
            thread JointState_0 _S1274 = ((&kernelContext_90)->bond_dyn_0+i_21)->js_0;
            thread float3 f_lin_2;
            thread float3 f_ang_2;
            secant_factors_0(&_S1273, &_S1274, d_lin_5, &f_lin_2, &f_ang_2);
            float4 _S1275 = float4((&_S1273)->stiff0_0) ;
            uint _S1276 = statics_bond_slot_0(i_21, &kernelContext_90);
            float _S1277 = _S1275.y;
            *((&kernelContext_90)->scratch_0+_S1276) = packed_float4(float4(_S1277 * f_lin_2.x, _S1277 * f_lin_2.y, _S1275.x * f_lin_2.z, 0.0f)) ;
            *((&kernelContext_90)->scratch_0+(_S1276 + 1U)) = packed_float4(float4(_S1275.z * f_ang_2.x, _S1275.w * f_ang_2.y, (float4((&_S1273)->stiff1_0) ).x * f_ang_2.z, 0.0f)) ;
            i_21 = i_21 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_41 = _S1253;
        for(;;)
        {
            if(c_41 < c1_1)
            {
            }
            else
            {
                break;
            }
            assemble_block_0(c_41, &kernelContext_90);
            uint _S1278 = sv_0(c_41, 2U, &kernelContext_90);
            packed_float4 _S1279 = packed_float4(_S1263) ;
            *((&kernelContext_90)->scratch_0+_S1278) = _S1279;
            uint _S1280 = sv_0(c_41, 3U, &kernelContext_90);
            *((&kernelContext_90)->scratch_0+_S1280) = _S1279;
            c_41 = c_41 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_42 = _S1253;
        for(;;)
        {
            if(c_42 < c1_1)
            {
            }
            else
            {
                break;
            }
            precondition_0(c_42, &kernelContext_90);
            c_42 = c_42 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        if(free_0)
        {
            project_displacement_slot_0(tid_18, &_S1248, 6U, &kernelContext_90);
        }
        uint c_43 = _S1253;
        for(;;)
        {
            if(c_43 < c1_1)
            {
            }
            else
            {
                break;
            }
            uint _S1281 = sv_0(c_43, 8U, &kernelContext_90);
            packed_float4 device* _S1282 = (&kernelContext_90)->scratch_0+_S1281;
            uint _S1283 = sv_0(c_43, 6U, &kernelContext_90);
            *_S1282 = packed_float4(float4(*((&kernelContext_90)->scratch_0+_S1283)) ) ;
            uint _S1284 = sv_0(c_43, 9U, &kernelContext_90);
            packed_float4 device* _S1285 = (&kernelContext_90)->scratch_0+_S1284;
            uint _S1286 = sv_0(c_43, 7U, &kernelContext_90);
            *_S1285 = packed_float4(float4(*((&kernelContext_90)->scratch_0+_S1286)) ) ;
            c_43 = c_43 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        float _S1287 = island_dot_0(tid_18, c0_1, c1_1, 4U, 6U, &kernelContext_90);
        float _S1288 = island_dot_0(tid_18, c0_1, c1_1, 4U, 4U, &kernelContext_90);
        float _S1289 = sqrt(_S1288);
        float rz_0 = _S1287;
        uint k_24 = 0U;
        uint cg_total_1 = cg_total_0;
        for(;;)
        {
            bool _S1290;
            if(k_24 < _S1260)
            {
                _S1290 = _S1289 > 0.0f;
            }
            else
            {
                _S1290 = false;
            }
            if(_S1290)
            {
            }
            else
            {
                cg_total_0 = cg_total_1;
                break;
            }
            uint i_22 = _S1261;
            for(;;)
            {
                if(i_22 < _S1252)
                {
                }
                else
                {
                    break;
                }
                uint4 _S1291 = uint4(((&kernelContext_90)->bonds_0+i_22)->law_0.ids_0) ;
                uint ca_2 = _S1291.y;
                uint cb_2 = _S1291.z;
                uint _S1292 = sv_0(ca_2, 8U, &kernelContext_90);
                float3 _S1293 = (float4(*((&kernelContext_90)->scratch_0+_S1292)) ).xyz;
                uint _S1294 = sv_0(ca_2, 9U, &kernelContext_90);
                float3 _S1295 = (float4(*((&kernelContext_90)->scratch_0+_S1294)) ).xyz;
                uint _S1296 = sv_0(cb_2, 8U, &kernelContext_90);
                float3 _S1297 = (float4(*((&kernelContext_90)->scratch_0+_S1296)) ).xyz;
                uint _S1298 = sv_0(cb_2, 9U, &kernelContext_90);
                thread float3 d_lin_6;
                thread float3 d_ang_5;
                bond_kinematics_0(i_22, _S1293, _S1295, _S1297, (float4(*((&kernelContext_90)->scratch_0+_S1298)) ).xyz, &d_lin_6, &d_ang_5, &kernelContext_90);
                uint _S1299 = statics_bond_slot_0(i_22, &kernelContext_90);
                write_bond_loads_0(i_22, i_22, d_lin_6 * (float4(*((&kernelContext_90)->scratch_0+_S1299)) ).xyz, d_ang_5 * (float4(*((&kernelContext_90)->scratch_0+(_S1299 + 1U))) ).xyz, 0.0f, &kernelContext_90);
                i_22 = i_22 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            c_39 = _S1253;
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
                gather_loads_0(c_39, &fi_5, &mi_8, &kernelContext_90);
                thread float4 ap_lin_0 = float4(- fi_5, 0.0f);
                thread float4 ap_ang_0 = float4(- mi_8, 0.0f);
                uint _S1300 = fixed_mask_0(c_39, &kernelContext_90);
                uint _S1301 = sv_0(c_39, 8U, &kernelContext_90);
                float4 _S1302 = float4(*((&kernelContext_90)->scratch_0+_S1301)) ;
                uint _S1303 = sv_0(c_39, 9U, &kernelContext_90);
                hold_0(_S1300, &ap_lin_0, &ap_ang_0, _S1302, float4(*((&kernelContext_90)->scratch_0+_S1303)) );
                uint _S1304 = sv_0(c_39, 10U, &kernelContext_90);
                *((&kernelContext_90)->scratch_0+_S1304) = packed_float4(ap_lin_0) ;
                uint _S1305 = sv_0(c_39, 11U, &kernelContext_90);
                *((&kernelContext_90)->scratch_0+_S1305) = packed_float4(ap_ang_0) ;
                c_39 = c_39 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            float _S1306 = island_dot_0(tid_18, c0_1, c1_1, 8U, 10U, &kernelContext_90);
            uint _S1307 = cg_total_1 + 1U;
            if(_S1306 <= 0.0f)
            {
                cg_total_0 = _S1307;
                break;
            }
            float _S1308 = rz_0 / _S1306;
            uint c_44 = _S1253;
            for(;;)
            {
                if(c_44 < c1_1)
                {
                }
                else
                {
                    break;
                }
                uint _S1309 = sv_0(c_44, 2U, &kernelContext_90);
                packed_float4 device* _S1310 = (&kernelContext_90)->scratch_0+_S1309;
                float3 _S1311 = (float4(*((&kernelContext_90)->scratch_0+_S1309)) ).xyz;
                uint _S1312 = sv_0(c_44, 8U, &kernelContext_90);
                float3 _S1313 = float3(_S1308) ;
                *_S1310 = packed_float4(float4(_S1311 + _S1313 * (float4(*((&kernelContext_90)->scratch_0+_S1312)) ).xyz, 0.0f)) ;
                uint _S1314 = sv_0(c_44, 3U, &kernelContext_90);
                packed_float4 device* _S1315 = (&kernelContext_90)->scratch_0+_S1314;
                float3 _S1316 = (float4(*((&kernelContext_90)->scratch_0+_S1314)) ).xyz;
                uint _S1317 = sv_0(c_44, 9U, &kernelContext_90);
                *_S1315 = packed_float4(float4(_S1316 + _S1313 * (float4(*((&kernelContext_90)->scratch_0+_S1317)) ).xyz, 0.0f)) ;
                uint _S1318 = sv_0(c_44, 4U, &kernelContext_90);
                packed_float4 device* _S1319 = (&kernelContext_90)->scratch_0+_S1318;
                float3 _S1320 = (float4(*((&kernelContext_90)->scratch_0+_S1318)) ).xyz;
                uint _S1321 = sv_0(c_44, 10U, &kernelContext_90);
                *_S1319 = packed_float4(float4(_S1320 - _S1313 * (float4(*((&kernelContext_90)->scratch_0+_S1321)) ).xyz, 0.0f)) ;
                uint _S1322 = sv_0(c_44, 5U, &kernelContext_90);
                packed_float4 device* _S1323 = (&kernelContext_90)->scratch_0+_S1322;
                float3 _S1324 = (float4(*((&kernelContext_90)->scratch_0+_S1322)) ).xyz;
                uint _S1325 = sv_0(c_44, 11U, &kernelContext_90);
                *_S1323 = packed_float4(float4(_S1324 - _S1313 * (float4(*((&kernelContext_90)->scratch_0+_S1325)) ).xyz, 0.0f)) ;
                c_44 = c_44 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            float _S1326 = island_dot_0(tid_18, c0_1, c1_1, 4U, 4U, &kernelContext_90);
            if((sqrt(_S1326)) <= (0.00009999999747379f * _S1289))
            {
                cg_total_0 = _S1307;
                break;
            }
            uint c_45 = _S1253;
            for(;;)
            {
                if(c_45 < c1_1)
                {
                }
                else
                {
                    break;
                }
                precondition_0(c_45, &kernelContext_90);
                c_45 = c_45 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            if(free_0)
            {
                project_displacement_slot_0(tid_18, &_S1248, 6U, &kernelContext_90);
            }
            float _S1327 = island_dot_0(tid_18, c0_1, c1_1, 4U, 6U, &kernelContext_90);
            float _S1328 = _S1327 / rz_0;
            uint c_46 = _S1253;
            for(;;)
            {
                if(c_46 < c1_1)
                {
                }
                else
                {
                    break;
                }
                uint _S1329 = sv_0(c_46, 8U, &kernelContext_90);
                packed_float4 device* _S1330 = (&kernelContext_90)->scratch_0+_S1329;
                uint _S1331 = sv_0(c_46, 6U, &kernelContext_90);
                float3 _S1332 = float3(_S1328) ;
                *_S1330 = packed_float4(float4((float4(*((&kernelContext_90)->scratch_0+_S1331)) ).xyz + _S1332 * (float4(*((&kernelContext_90)->scratch_0+_S1329)) ).xyz, 0.0f)) ;
                uint _S1333 = sv_0(c_46, 9U, &kernelContext_90);
                packed_float4 device* _S1334 = (&kernelContext_90)->scratch_0+_S1333;
                uint _S1335 = sv_0(c_46, 7U, &kernelContext_90);
                *_S1334 = packed_float4(float4((float4(*((&kernelContext_90)->scratch_0+_S1335)) ).xyz + _S1332 * (float4(*((&kernelContext_90)->scratch_0+_S1333)) ).xyz, 0.0f)) ;
                c_46 = c_46 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            uint _S1336 = k_24 + 1U;
            rz_0 = _S1327;
            k_24 = _S1336;
            cg_total_1 = _S1307;
        }
        c_39 = _S1253;
        for(;;)
        {
            if(c_39 < c1_1)
            {
            }
            else
            {
                break;
            }
            uint _S1337 = 4U * c_39;
            thread float3 u_7 = (float4(*((&kernelContext_90)->state_0+_S1337)) ).xyz;
            uint _S1338 = sv_0(c_39, 21U, &kernelContext_90);
            thread float3 u_lo_0 = (float4(*((&kernelContext_90)->scratch_0+_S1338)) ).xyz;
            uint _S1339 = _S1337 + 1U;
            thread float3 th_8 = (float4(*((&kernelContext_90)->state_0+_S1339)) ).xyz;
            uint _S1340 = sv_0(c_39, 22U, &kernelContext_90);
            thread float3 th_lo_0 = (float4(*((&kernelContext_90)->scratch_0+_S1340)) ).xyz;
            uint _S1341 = sv_0(c_39, 2U, &kernelContext_90);
            comp_add_0(&u_7, &u_lo_0, (float4(*((&kernelContext_90)->scratch_0+_S1341)) ).xyz);
            uint _S1342 = sv_0(c_39, 3U, &kernelContext_90);
            comp_add_0(&th_8, &th_lo_0, (float4(*((&kernelContext_90)->scratch_0+_S1342)) ).xyz);
            *((&kernelContext_90)->state_0+_S1337) = packed_float4(float4(u_7, (float4(*((&kernelContext_90)->state_0+_S1337)) ).w)) ;
            *((&kernelContext_90)->state_0+_S1339) = packed_float4(float4(th_8, (float4(*((&kernelContext_90)->state_0+_S1339)) ).w)) ;
            *((&kernelContext_90)->scratch_0+_S1338) = packed_float4(float4(u_lo_0, 0.0f)) ;
            *((&kernelContext_90)->scratch_0+_S1340) = packed_float4(float4(th_lo_0, 0.0f)) ;
            c_39 = c_39 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint _S1343 = newton_0 + 1U;
        previous_2 = residual_1;
        residual_0 = residual_1;
        newton_0 = _S1343;
    }
    i_20 = b0_0 + tid_18;
    for(;;)
    {
        if(i_20 < _S1252)
        {
        }
        else
        {
            break;
        }
        JointResponse_0 _S1344 = static_response_0(i_20, &kernelContext_90);
        BondDyn_natural_0 device* _S1345 = (&kernelContext_90)->bond_dyn_0+i_20;
        float4 _S1346 = float4((*_S1345).force_lin_0) ;
        float4 _S1347 = float4((*_S1345).force_ang_0) ;
        float4 _S1348 = float4((*_S1345).sums_0) ;
        float4 _S1349 = float4((*_S1345).comps_0) ;
        uint4 _S1350 = uint4((*_S1345).events_0) ;
        thread BondDyn_0 bd_1;
        (&bd_1)->js_0 = (*_S1345).js_0;
        (&bd_1)->force_lin_0 = _S1346;
        (&bd_1)->force_ang_0 = _S1347;
        (&bd_1)->sums_0 = _S1348;
        (&bd_1)->comps_0 = _S1349;
        (&bd_1)->events_0 = _S1350;
        (&bd_1)->force_lin_0 = float4(_S1344.force_lin_1, _S1344.stored_5);
        (&bd_1)->force_ang_0 = float4(_S1344.force_ang_1, (&bd_1)->force_ang_0.w);
        BondDyn_natural_0 device* _S1351 = (&kernelContext_90)->bond_dyn_0+i_20;
        _S1351->js_0 = bd_1.js_0;
        _S1351->force_lin_0 = packed_float4(bd_1.force_lin_0) ;
        _S1351->force_ang_0 = packed_float4(bd_1.force_ang_0) ;
        _S1351->sums_0 = packed_float4(bd_1.sums_0) ;
        _S1351->comps_0 = packed_float4(bd_1.comps_0) ;
        _S1351->events_0 = packed_uint4(bd_1.events_0) ;
        write_bond_loads_0(i_20, i_20, _S1344.force_lin_1, _S1344.force_ang_1, max(_S1344.measures_0.tension_0, _S1344.measures_0.compression_0), &kernelContext_90);
        i_20 = i_20 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    c_40 = _S1253;
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
        gather_loads_0(c_40, &fi_6, &mi_9, &kernelContext_90);
        uint _S1352 = fixed_mask_0(c_40, &kernelContext_90);
        float3 reaction_2;
        if(_S1352 != 0U)
        {
            uint _S1353 = sv_0(c_40, 0U, &kernelContext_90);
            reaction_2 = - ((float4(*((&kernelContext_90)->scratch_0+_S1353)) ).xyz + fi_6);
        }
        else
        {
            uint _S1354 = 4U * c_40;
            reaction_2 = float3((float4(*((&kernelContext_90)->state_0+(_S1354 + 1U))) ).w, (float4(*((&kernelContext_90)->state_0+(_S1354 + 2U))) ).w, (float4(*((&kernelContext_90)->state_0+(_S1354 + 3U))) ).w);
        }
        uint _S1355 = 4U * c_40;
        uint _S1356 = _S1355 + 1U;
        *((&kernelContext_90)->state_0+_S1356) = packed_float4(float4((float4(*((&kernelContext_90)->state_0+_S1356)) ).xyz, reaction_2.x)) ;
        *((&kernelContext_90)->state_0+(_S1355 + 2U)) = packed_float4(float4(0.0f, 0.0f, 0.0f, reaction_2.y)) ;
        *((&kernelContext_90)->state_0+(_S1355 + 3U)) = packed_float4(float4(0.0f, 0.0f, 0.0f, reaction_2.z)) ;
        c_40 = c_40 + 256U;
    }
    if(tid_18 == 0U)
    {
        uint _S1357 = statics_result_slot_0(_S1247, &kernelContext_90);
        packed_float4 device* _S1358 = (&kernelContext_90)->scratch_0+_S1357;
        float _S1359 = (as_type<float>((newton_0)));
        float _S1360 = (as_type<float>((cg_total_0)));
        if(converged_0)
        {
            previous_2 = 1.0f;
        }
        else
        {
            previous_2 = 0.0f;
        }
        *_S1358 = packed_float4(float4(residual_0, _S1359, _S1360, previous_2)) ;
        ((&kernelContext_90)->islands_0+_S1247)->info_0[int(2)] = _S1250 & 4294967287U;
    }
    return;
}

[[kernel]] void settled_fatigue(uint3 group_10 [[threadgroup_position_in_grid]], uint3 thread_10 [[thread_position_in_threadgroup]], Params_0 constant* params_14 [[buffer(0)]], Island_natural_0 device* islands_14 [[buffer(9)]], uint device* index_14 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_14 [[buffer(3)]], packed_float4 device* state_16 [[buffer(6)]], packed_float4 device* scratch_14 [[buffer(8)]], packed_float4 device* contact_state_14 [[buffer(11)]], packed_float4 device* loads_14 [[buffer(5)]], Impactor_natural_0 device* impactors_14 [[buffer(10)]], BondStatic_natural_0 device* bonds_14 [[buffer(2)]], MaterialTable_0 constant* materials_14 [[buffer(1)]], BondDyn_natural_0 device* bond_dyn_14 [[buffer(7)]])
{
    thread KernelContext_0 kernelContext_91;
    (&kernelContext_91)->params_0 = params_14;
    (&kernelContext_91)->islands_0 = islands_14;
    (&kernelContext_91)->index_0 = index_14;
    (&kernelContext_91)->chunks_0 = chunks_14;
    (&kernelContext_91)->state_0 = state_16;
    (&kernelContext_91)->scratch_0 = scratch_14;
    (&kernelContext_91)->contact_state_0 = contact_state_14;
    (&kernelContext_91)->loads_0 = loads_14;
    (&kernelContext_91)->impactors_0 = impactors_14;
    (&kernelContext_91)->bonds_0 = bonds_14;
    (&kernelContext_91)->materials_0 = materials_14;
    (&kernelContext_91)->bond_dyn_0 = bond_dyn_14;
    threadgroup array<float4, int(32)> g_part_a_14;
    (&kernelContext_91)->g_part_a_0 = &g_part_a_14;
    threadgroup array<float4, int(32)> g_part_b_14;
    (&kernelContext_91)->g_part_b_0 = &g_part_b_14;
    threadgroup array<uint, int(5)> g_seen_14;
    (&kernelContext_91)->g_seen_0 = &g_seen_14;
    threadgroup uint g_run_14;
    (&kernelContext_91)->g_run_0 = &g_run_14;
    threadgroup uint g_halt_14;
    (&kernelContext_91)->g_halt_0 = &g_halt_14;
    threadgroup uint g_wide_run_14;
    (&kernelContext_91)->g_wide_run_0 = &g_wide_run_14;
    uint tid_19 = thread_10.x;
    uint _S1361 = group_10.x;
    Island_natural_0 device* _S1362 = islands_14+_S1361;
    Island_natural_0 isl_25 = *_S1362;
    uint4 _S1363 = uint4((*_S1362).info_0) ;
    bool _S1364;
    if(((_S1363.x) & 16U) == 0U)
    {
        _S1364 = true;
    }
    else
    {
        uint4 _S1365 = uint4(isl_25.range_0) ;
        _S1364 = (_S1365.w) == (_S1365.z);
    }
    if(_S1364)
    {
        return;
    }
    seen_clear_0(tid_19, &kernelContext_91);
    if(tid_19 == 0U)
    {
        *(&kernelContext_91)->g_halt_0 = 0U;
        *(&kernelContext_91)->g_run_0 = 0U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    uint _S1366 = _S1363.w;
    uint4 _S1367 = uint4(isl_25.range_0) ;
    uint i_23 = _S1367.z + tid_19;
    for(;;)
    {
        if(i_23 < (_S1367.w))
        {
        }
        else
        {
            break;
        }
        BondStatic_natural_0 device* _S1368 = (&kernelContext_91)->bonds_0+i_23;
        BondDyn_natural_0 device* _S1369 = (&kernelContext_91)->bond_dyn_0+i_23;
        float4 _S1370 = float4((*_S1369).force_lin_0) ;
        float4 _S1371 = float4((*_S1369).force_ang_0) ;
        float4 _S1372 = float4((*_S1369).sums_0) ;
        float4 _S1373 = float4((*_S1369).comps_0) ;
        uint4 _S1374 = uint4((*_S1369).events_0) ;
        thread BondDyn_0 bd_2;
        (&bd_2)->js_0 = (*_S1369).js_0;
        (&bd_2)->force_lin_0 = _S1370;
        (&bd_2)->force_ang_0 = _S1371;
        (&bd_2)->sums_0 = _S1372;
        (&bd_2)->comps_0 = _S1373;
        (&bd_2)->events_0 = _S1374;
        thread JointBond_natural_0 _S1375 = _S1368->law_0;
        uint4 _S1376 = uint4((&_S1375)->ids_0) ;
        uint _S1377 = 4U * _S1376.y;
        uint _S1378 = 4U * _S1376.z;
        thread float3 d_lin_7;
        thread float3 d_ang_6;
        bond_kinematics_0(i_23, (float4(*((&kernelContext_91)->state_0+_S1377)) ).xyz, (float4(*((&kernelContext_91)->state_0+(_S1377 + 1U))) ).xyz, (float4(*((&kernelContext_91)->state_0+_S1378)) ).xyz, (float4(*((&kernelContext_91)->state_0+(_S1378 + 1U))) ).xyz, &d_lin_7, &d_ang_6, &kernelContext_91);
        JointState_0 previous_3 = (&bd_2)->js_0;
        float _S1379 = (&kernelContext_91)->params_0->dt_0;
        bool _S1380 = ((&kernelContext_91)->params_0->fracture_0) != 0U;
        _S1375 = _S1368->law_0;
        thread JointState_0 _S1381 = (&bd_2)->js_0;
        JointResponse_0 _S1382 = joint_evaluate_0(&(&kernelContext_91)->materials_0->m_0[_S1376.x], &_S1375, &_S1381, d_lin_7, d_ang_6, _S1379, _S1380);
        if((_S1382.state_6.damage_0) > (previous_3.damage_0 + 9.99999971718068537e-10f))
        {
            _S1364 = true;
        }
        else
        {
            _S1364 = (_S1382.state_6.crush_1) > (previous_3.crush_1 + 9.99999971718068537e-10f);
        }
        uint flags_3;
        if(_S1364)
        {
            flags_3 = 16U;
        }
        else
        {
            flags_3 = 0U;
        }
        thread float _S1383 = (&bd_2)->sums_0.x;
        thread float _S1384 = (&bd_2)->comps_0.x;
        comp_add1_0(&_S1383, &_S1384, _S1382.dissipated_2);
        (&bd_2)->comps_0.x = _S1384;
        (&bd_2)->sums_0.x = _S1383;
        thread float _S1385 = (&bd_2)->sums_0.y;
        thread float _S1386 = (&bd_2)->comps_0.y;
        comp_add1_0(&_S1385, &_S1386, _S1382.overshoot_0);
        (&bd_2)->comps_0.y = _S1386;
        (&bd_2)->sums_0.y = _S1385;
        (&bd_2)->force_lin_0 = float4(_S1382.force_lin_1, _S1382.stored_5);
        (&bd_2)->force_ang_0 = float4(_S1382.force_ang_1, max((&bd_2)->force_ang_0.w, _S1382.state_6.utilization_0));
        thread JointState_0 _S1387 = previous_3;
        bool _S1388 = is_damaged_0(&_S1387);
        bool _S1389;
        if(!_S1388)
        {
            thread JointState_0 _S1390 = _S1382.state_6;
            bool _S1391 = is_damaged_0(&_S1390);
            _S1389 = _S1391;
        }
        else
        {
            _S1389 = false;
        }
        bool _S1392;
        if(_S1389)
        {
            _S1392 = ((&bd_2)->events_0.x) == 0U;
        }
        else
        {
            _S1392 = false;
        }
        if(_S1392)
        {
            (&bd_2)->events_0.x = _S1366;
            (&bd_2)->events_0.w = _S1382.state_6.mode_0;
            (*(&kernelContext_91)->g_seen_0)[3U] = 1U;
        }
        bool _S1393;
        if(((&bd_2)->events_0.y) == 0U)
        {
            _S1393 = (_S1382.state_6.life_0) != (previous_3.life_0);
        }
        else
        {
            _S1393 = false;
        }
        bool _S1394;
        if(_S1393)
        {
            _S1394 = (_S1382.fatigue_before_0) > 0.99000000953674316f;
        }
        else
        {
            _S1394 = false;
        }
        bool _S1395;
        if(_S1394)
        {
            float _S1396 = fatigue_factor_0(&(&kernelContext_91)->materials_0->m_0[_S1376.x], _S1382.state_6.life_0);
            _S1395 = _S1396 <= 0.99000000953674316f;
        }
        else
        {
            _S1395 = false;
        }
        if(_S1395)
        {
            (&bd_2)->events_0.y = _S1366;
            (*(&kernelContext_91)->g_seen_0)[4U] = 1U;
        }
        uint flags_4;
        if(_S1382.disconnected_0)
        {
            (&bd_2)->events_0.z = _S1366;
            flags_4 = flags_3 | 32U;
        }
        else
        {
            flags_4 = flags_3;
        }
        (&bd_2)->js_0 = _S1382.state_6;
        BondDyn_natural_0 device* _S1397 = (&kernelContext_91)->bond_dyn_0+i_23;
        _S1397->js_0 = bd_2.js_0;
        _S1397->force_lin_0 = packed_float4(bd_2.force_lin_0) ;
        _S1397->force_ang_0 = packed_float4(bd_2.force_ang_0) ;
        _S1397->sums_0 = packed_float4(bd_2.sums_0) ;
        _S1397->comps_0 = packed_float4(bd_2.comps_0) ;
        _S1397->events_0 = packed_uint4(bd_2.events_0) ;
        write_bond_loads_0(i_23, i_23, _S1382.force_lin_1, _S1382.force_ang_1, max(_S1382.measures_0.tension_0, _S1382.measures_0.compression_0), &kernelContext_91);
        if((flags_4 & 16U) != 0U)
        {
            *(&kernelContext_91)->g_halt_0 = 1U;
        }
        if((flags_4 & 32U) != 0U)
        {
            *(&kernelContext_91)->g_run_0 = 1U;
        }
        i_23 = i_23 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    if(tid_19 != 0U)
    {
        return;
    }
    if(((*(&kernelContext_91)->g_halt_0) | (*(&kernelContext_91)->g_run_0)) != 0U)
    {
        uint _S1398 = _S1363.z;
        if((*(&kernelContext_91)->g_halt_0) != 0U)
        {
            i_23 = 16U;
        }
        else
        {
            i_23 = 0U;
        }
        uint _S1399 = _S1398 | i_23;
        if((*(&kernelContext_91)->g_run_0) != 0U)
        {
            i_23 = 32U;
        }
        else
        {
            i_23 = 0U;
        }
        ((&kernelContext_91)->islands_0+_S1361)->info_0[int(2)] = _S1399 | i_23;
    }
    uint _S1400 = (isl_25.coverage_0) | 16384U;
    uint _S1401 = seen_bits_0(&kernelContext_91);
    uint _S1402 = _S1400 | _S1401;
    if((*(&kernelContext_91)->g_run_0) != 0U)
    {
        i_23 = 128U;
    }
    else
    {
        i_23 = 0U;
    }
    ((&kernelContext_91)->islands_0+_S1361)->coverage_0 = _S1402 | i_23;
    return;
}

