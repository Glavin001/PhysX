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
    BondStatic_natural_0 device* bonds_0;
    BondDyn_natural_0 device* bond_dyn_0;
    MaterialTable_0 constant* materials_0;
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

[[kernel]] void contact_forces(uint3 id_0 [[thread_position_in_grid]], Params_0 constant* params_1 [[buffer(0)]], Island_natural_0 device* islands_1 [[buffer(9)]], uint device* index_1 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_1 [[buffer(3)]], packed_float4 device* state_1 [[buffer(6)]], packed_float4 device* scratch_1 [[buffer(8)]], packed_float4 device* contact_state_1 [[buffer(11)]], packed_float4 device* loads_1 [[buffer(5)]], Impactor_natural_0 device* impactors_1 [[buffer(10)]], BondStatic_natural_0 device* bonds_1 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_1 [[buffer(7)]], MaterialTable_0 constant* materials_1 [[buffer(1)]])
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
    (&kernelContext_27)->bond_dyn_0 = bond_dyn_1;
    (&kernelContext_27)->materials_0 = materials_1;
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

[[kernel]] void impactor_shares(uint3 id_1 [[thread_position_in_grid]], Params_0 constant* params_2 [[buffer(0)]], Island_natural_0 device* islands_2 [[buffer(9)]], uint device* index_2 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_2 [[buffer(3)]], packed_float4 device* state_2 [[buffer(6)]], packed_float4 device* scratch_2 [[buffer(8)]], packed_float4 device* contact_state_2 [[buffer(11)]], packed_float4 device* loads_2 [[buffer(5)]], Impactor_natural_0 device* impactors_2 [[buffer(10)]], BondStatic_natural_0 device* bonds_2 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_2 [[buffer(7)]], MaterialTable_0 constant* materials_2 [[buffer(1)]])
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
    (&kernelContext_28)->bond_dyn_0 = bond_dyn_2;
    (&kernelContext_28)->materials_0 = materials_2;
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

[[kernel]] void impactor_crush(uint3 group_0 [[threadgroup_position_in_grid]], uint3 thread_0 [[thread_position_in_threadgroup]], Params_0 constant* params_3 [[buffer(0)]], Island_natural_0 device* islands_3 [[buffer(9)]], uint device* index_3 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_3 [[buffer(3)]], packed_float4 device* state_3 [[buffer(6)]], packed_float4 device* scratch_3 [[buffer(8)]], packed_float4 device* contact_state_3 [[buffer(11)]], packed_float4 device* loads_3 [[buffer(5)]], Impactor_natural_0 device* impactors_3 [[buffer(10)]], BondStatic_natural_0 device* bonds_3 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_3 [[buffer(7)]], MaterialTable_0 constant* materials_3 [[buffer(1)]])
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
    (&kernelContext_29)->bond_dyn_0 = bond_dyn_3;
    (&kernelContext_29)->materials_0 = materials_3;
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

[[kernel]] void impactor_integrate(uint3 group_1 [[threadgroup_position_in_grid]], uint3 thread_1 [[thread_position_in_threadgroup]], Params_0 constant* params_4 [[buffer(0)]], Island_natural_0 device* islands_4 [[buffer(9)]], uint device* index_4 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_4 [[buffer(3)]], packed_float4 device* state_4 [[buffer(6)]], packed_float4 device* scratch_4 [[buffer(8)]], packed_float4 device* contact_state_4 [[buffer(11)]], packed_float4 device* loads_4 [[buffer(5)]], Impactor_natural_0 device* impactors_4 [[buffer(10)]], BondStatic_natural_0 device* bonds_4 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_4 [[buffer(7)]], MaterialTable_0 constant* materials_4 [[buffer(1)]])
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
    (&kernelContext_30)->bond_dyn_0 = bond_dyn_4;
    (&kernelContext_30)->materials_0 = materials_4;
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
    bool _S386;
    if(((&imp_6)->cand_0.z) != 0U)
    {
        _S386 = true;
    }
    else
    {
        _S386 = (((uint4(_S363->info_0) ).z) & 1U) != 0U;
    }
    if(_S386)
    {
        _S386 = true;
    }
    else
    {
        uint _S387 = (uint4(_S363->info_0) ).y;
        if(_S387 != 0U)
        {
            _S386 = ((&imp_6)->cand_0.w) >= _S387;
        }
        else
        {
            _S386 = false;
        }
    }
    if(_S386)
    {
        return;
    }
    float4 _S388 = float4(0.0f) ;
    thread float4 rf_0 = _S388;
    thread float4 rt_0 = _S388;
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
        uint _S389 = 3U * k_9;
        rf_0 = rf_0 + float4(*((&kernelContext_30)->scratch_0+((&kernelContext_30)->params_0->cand_base_0 + _S389 + 1U))) ;
        rt_0 = rt_0 + float4(*((&kernelContext_30)->scratch_0+((&kernelContext_30)->params_0->cand_base_0 + _S389 + 2U))) ;
        k_9 = k_9 + 256U;
    }
    group_sum2_0(tid_3, &rf_0, &rt_0, &kernelContext_30);
    if(tid_3 != 0U)
    {
        return;
    }
    float dt_3 = (&kernelContext_30)->params_0->dt_0;
    float3 _S390 = float3(0.0f) ;
    float3 load_f_0;
    float3 load_t_0;
    if(((&kernelContext_30)->params_0->has_ground_0) != 0U)
    {
        float3 _S391 = (&imp_6)->half_1.xyz;
        thread Impactor_0 _S392 = imp_6;
        Box_0 _S393 = impactor_box_0(&_S392, _S390, _S391);
        float3 _S394 = (&imp_6)->velocity_1.xyz + (&imp_6)->velocity_err_1.xyz;
        float _S395 = (&kernelContext_30)->params_0->ground_modulus_0;
        float _S396 = (&imp_6)->mat_0.x;
        float3 _S397 = float3(0.0f, 0.0f, 1.0f);
        thread Box_0 _S398 = _S393;
        thread Box_0 _S399 = _S393;
        float _S400 = contact_stiffness_0(_S395, &_S398, _S396, &_S399, _S397);
        float _S401 = (&imp_6)->position_1.z - (&kernelContext_30)->params_0->ground_hi_0 + ((&imp_6)->position_err_1.z - (&kernelContext_30)->params_0->ground_lo_0);
        uint total_points_0;
        if(((&imp_6)->shape_0.x) == 0.0f)
        {
            total_points_0 = 1U;
        }
        else
        {
            total_points_0 = 14U;
        }
        float _S402 = _S400 / float(min(total_points_0, 5U));
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
                thread Box_0 _S403 = _S393;
                float3 _S404 = sample_point_0(&_S403, s_2, &kernelContext_30);
                p_10 = _S404;
            }
            if((_S401 + p_10.z) < 0.0f)
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
        load_f_0 = _S390;
        load_t_0 = _S390;
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
                thread Box_0 _S405 = _S393;
                float3 _S406 = sample_point_0(&_S405, s_2, &kernelContext_30);
                p_10 = _S406;
            }
            float depth_4 = - (_S401 + p_10.z);
            if(depth_4 <= 0.0f)
            {
                s_2 = s_2 + 1U;
                continue;
            }
            thread float stored_3;
            thread float diss_2;
            float3 _S407 = penalty_force_0(_S402, (&imp_6)->mat_0.z, (&kernelContext_30)->params_0->ground_friction_0, depth_4, _S397, _S394 + cross((&imp_6)->angular_velocity_1.xyz, p_10), dt_3, below_0, &stored_3, &diss_2, &kernelContext_30);
            float3 load_f_1 = load_f_0 + _S407;
            float3 load_t_1 = load_t_0 + cross(p_10, _S407);
            thread float _S408 = (&imp_6)->ledger_0.x;
            thread float _S409 = (&imp_6)->ledger_0.y;
            comp_add1_0(&_S408, &_S409, diss_2);
            (&imp_6)->ledger_0.y = _S409;
            (&imp_6)->ledger_0.x = _S408;
            load_f_0 = load_f_1;
            load_t_0 = load_t_1;
            s_2 = s_2 + 1U;
        }
    }
    else
    {
        load_f_0 = _S390;
        load_t_0 = _S390;
    }
    float3 load_f_2 = rf_0.xyz + load_f_0;
    float3 load_t_2 = rt_0.xyz + load_t_0;
    float m_2 = (&imp_6)->mat_0.z;
    thread float3 vel_0 = (&imp_6)->velocity_1.xyz;
    thread float3 vel_err_0 = (&imp_6)->velocity_err_1.xyz;
    float3 _S410 = float3(dt_3) ;
    comp_add_0(&vel_0, &vel_err_0, (load_f_2 / float3(m_2)  + (&kernelContext_30)->params_0->gravity_0.xyz) * _S410);
    Quat_0 _S411 = quat_of_0((&imp_6)->rotation_1);
    thread Quat_0 q_14 = _S411;
    thread float4 q_err_0 = (&imp_6)->rotation_err_1;
    thread float3 l_hi_0 = (&imp_6)->momentum_1.xyz;
    thread float3 l_err_0 = (&imp_6)->momentum_err_1.xyz;
    comp_add_0(&l_hi_0, &l_err_0, load_t_2 * _S410);
    float3 l_1 = l_hi_0 + l_err_0;
    thread Quat_0 _S412 = _S411;
    float3 _S413 = world_mul_0(&_S412, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    thread float3 pos_0 = (&imp_6)->position_1.xyz;
    thread float3 pos_err_0 = (&imp_6)->position_err_1.xyz;
    comp_add_0(&pos_0, &pos_err_0, (vel_0 + vel_err_0) * _S410);
    turn_left_0(&q_14, &q_err_0, _S413, dt_3);
    thread Quat_0 _S414 = q_14;
    float3 _S415 = world_mul_0(&_S414, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    (&imp_6)->angular_velocity_1 = float4(_S415, 0.0f);
    thread Quat_0 _S416 = q_14;
    float4 _S417 = quat_vec_0(&_S416);
    (&imp_6)->rotation_1 = _S417;
    (&imp_6)->rotation_err_1 = q_err_0;
    (&imp_6)->momentum_1 = float4(l_hi_0, 0.0f);
    (&imp_6)->momentum_err_1 = float4(l_err_0, 0.0f);
    (&imp_6)->position_1 = float4(pos_0, 0.0f);
    (&imp_6)->position_err_1 = float4(pos_err_0, 0.0f);
    (&imp_6)->velocity_1 = float4(vel_0, 0.0f);
    (&imp_6)->velocity_err_1 = float4(vel_err_0, 0.0f);
    (&imp_6)->cand_0.w = (&imp_6)->cand_0.w + 1U;
    (&imp_6)->geom_0 = float4(1.0f, (&imp_6)->crush_0.w, 0.0f, 0.0f);
    Impactor_natural_0 device* _S418 = (&kernelContext_30)->impactors_0+ii_1;
    _S418->position_1 = packed_float4(imp_6.position_1) ;
    _S418->position_err_1 = packed_float4(imp_6.position_err_1) ;
    _S418->velocity_1 = packed_float4(imp_6.velocity_1) ;
    _S418->velocity_err_1 = packed_float4(imp_6.velocity_err_1) ;
    _S418->angular_velocity_1 = packed_float4(imp_6.angular_velocity_1) ;
    _S418->rotation_1 = packed_float4(imp_6.rotation_1) ;
    _S418->inertia0_2 = packed_float4(imp_6.inertia0_2) ;
    _S418->inertia1_2 = packed_float4(imp_6.inertia1_2) ;
    _S418->inertia2_2 = packed_float4(imp_6.inertia2_2) ;
    _S418->inv0_2 = packed_float4(imp_6.inv0_2) ;
    _S418->inv1_2 = packed_float4(imp_6.inv1_2) ;
    _S418->inv2_2 = packed_float4(imp_6.inv2_2) ;
    _S418->shape_0 = packed_float4(imp_6.shape_0) ;
    _S418->half_1 = packed_float4(imp_6.half_1) ;
    _S418->mat_0 = packed_float4(imp_6.mat_0) ;
    _S418->crush_0 = packed_float4(imp_6.crush_0) ;
    _S418->geom_0 = packed_float4(imp_6.geom_0) ;
    _S418->rotation_err_1 = packed_float4(imp_6.rotation_err_1) ;
    _S418->ledger_0 = packed_float4(imp_6.ledger_0) ;
    _S418->cand_0 = packed_uint4(imp_6.cand_0) ;
    _S418->momentum_1 = packed_float4(imp_6.momentum_1) ;
    _S418->momentum_err_1 = packed_float4(imp_6.momentum_err_1) ;
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
    ChunkStatic_natural_0 device* _S419 = kernelContext_31->chunks_0+c_9;
    WorldPoint_0 _S420 = chunk_world_0(c_9, kernelContext_31);
    float above_0 = _S420.hi_0.z - kernelContext_31->params_0->ground_hi_0 + (_S420.lo_0.z - kernelContext_31->params_0->ground_lo_0) + _S420.rel_0.z;
    if((above_0 - (float4(_S419->half_0) ).w) > 0.0f)
    {
        return;
    }
    Box_0 _S421 = chunk_box_0(c_9, float3(0.0f) , kernelContext_31);
    float _S422 = kernelContext_31->params_0->ground_modulus_0;
    float _S423 = (float4(_S419->cmat_0) ).x;
    float3 _S424 = float3(0.0f, 0.0f, 1.0f);
    thread Box_0 _S425 = _S421;
    thread Box_0 _S426 = _S421;
    float _S427 = contact_stiffness_0(_S422, &_S425, _S423, &_S426, _S424);
    thread Box_0 _S428 = _S421;
    uint _S429 = sample_count_0(&_S428);
    uint s_3 = 0U;
    uint n_8 = 0U;
    for(;;)
    {
        if(s_3 < _S429)
        {
        }
        else
        {
            break;
        }
        thread Box_0 _S430 = _S421;
        float3 _S431 = sample_point_0(&_S430, s_3, kernelContext_31);
        if((above_0 + _S431.z) < 0.0f)
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
        if(s_3 < _S429)
        {
        }
        else
        {
            break;
        }
        thread Box_0 _S432 = _S421;
        float3 _S433 = sample_point_0(&_S432, s_3, kernelContext_31);
        float _S434 = above_0 + _S433.z;
        if(!(_S434 < 0.0f))
        {
            s_3 = s_3 + 1U;
            continue;
        }
        thread float stored_4;
        thread float diss_3;
        float3 _S435 = penalty_force_0(_S427 / float(max(n_8, 5U)), (float4(_S419->center_0) ).w, kernelContext_31->params_0->ground_friction_0, - _S434, _S424, vc_1 + cross(wc_1, _S433), kernelContext_31->params_0->dt_0, n_8, &stored_4, &diss_3, kernelContext_31);
        *f_1 = *f_1 + _S435;
        *t_6 = *t_6 + cross(_S433, _S435);
        thread float _S436 = ledger_2.y;
        thread float _S437 = ledger_2.z;
        comp_add1_0(&_S436, &_S437, diss_3);
        ledger_2.z = _S437;
        ledger_2.y = _S436;
        s_3 = s_3 + 1U;
    }
    if(account_0)
    {
        *(kernelContext_31->scratch_0+(kernelContext_31->params_0->ledger_base_0 + kernelContext_31->params_0->pair_count_0 + c_9)) = packed_float4(ledger_2) ;
    }
    return;
}

[[kernel]] void contact_sums(uint3 id_2 [[thread_position_in_grid]], Params_0 constant* params_5 [[buffer(0)]], Island_natural_0 device* islands_5 [[buffer(9)]], uint device* index_5 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_5 [[buffer(3)]], packed_float4 device* state_5 [[buffer(6)]], packed_float4 device* scratch_5 [[buffer(8)]], packed_float4 device* contact_state_5 [[buffer(11)]], packed_float4 device* loads_5 [[buffer(5)]], Impactor_natural_0 device* impactors_5 [[buffer(10)]], BondStatic_natural_0 device* bonds_5 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_5 [[buffer(7)]], MaterialTable_0 constant* materials_5 [[buffer(1)]])
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
    (&kernelContext_32)->bond_dyn_0 = bond_dyn_5;
    (&kernelContext_32)->materials_0 = materials_5;
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
    bool _S438;
    if(g_0 >= (params_5->seg_count_0))
    {
        _S438 = true;
    }
    else
    {
        bool _S439 = stopped_0(&kernelContext_32);
        _S438 = _S439;
    }
    if(_S438)
    {
        return;
    }
    uint _S440 = 3U * g_0;
    uint _S441 = (&kernelContext_32)->index_0[(&kernelContext_32)->params_0->seg_index_0 + _S440];
    uint begin_0 = (&kernelContext_32)->index_0[(&kernelContext_32)->params_0->seg_index_0 + _S440 + 1U];
    uint _S442 = (&kernelContext_32)->index_0[(&kernelContext_32)->params_0->seg_index_0 + _S440 + 2U];
    float3 _S443 = float3(0.0f) ;
    thread float3 f_2 = _S443;
    thread float3 t_7 = _S443;
    uint e_2 = begin_0;
    for(;;)
    {
        if(e_2 < _S442)
        {
        }
        else
        {
            break;
        }
        uint entry_1 = (&kernelContext_32)->index_0[e_2];
        if(entry_1 == 2147483648U)
        {
            ground_contact_0(_S441, true, &f_2, &t_7, &kernelContext_32);
            e_2 = e_2 + 1U;
            continue;
        }
        uint _S444 = 2U * entry_1;
        f_2 = f_2 + (float4(*((&kernelContext_32)->scratch_0+((&kernelContext_32)->params_0->slot_base_0 + _S444))) ).xyz;
        t_7 = t_7 + (float4(*((&kernelContext_32)->scratch_0+((&kernelContext_32)->params_0->slot_base_0 + _S444 + 1U))) ).xyz;
        e_2 = e_2 + 1U;
    }
    uint _S445 = 2U * g_0;
    *((&kernelContext_32)->scratch_0+((&kernelContext_32)->params_0->seg_base_0 + _S445)) = packed_float4(float4(f_2, 0.0f)) ;
    *((&kernelContext_32)->scratch_0+((&kernelContext_32)->params_0->seg_base_0 + _S445 + 1U)) = packed_float4(float4(t_7, 0.0f)) ;
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
    uint4 _S446 = uint4((kernelContext_34->islands_0+kernelContext_34->params_0->halt_index_0)->info_0) ;
    bool _S447;
    if(((_S446.z) & 1U) != 0U)
    {
        _S447 = true;
    }
    else
    {
        uint _S448 = _S446.y;
        if(_S448 != 0U)
        {
            _S447 = _S448 <= ((uint4(isl_0->info_0) ).w);
        }
        else
        {
            _S447 = false;
        }
    }
    return _S447;
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
    uint4 _S449 = uint4((kernelContext_35->islands_0+kernelContext_35->params_0->halt_index_0)->info_0) ;
    bool _S450;
    if(((_S449.z) & 1U) != 0U)
    {
        _S450 = true;
    }
    else
    {
        uint _S451 = _S449.y;
        if(_S451 != 0U)
        {
            _S450 = _S451 <= (isl_1->info_0.w);
        }
        else
        {
            _S450 = false;
        }
    }
    return _S450;
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
    float3 _S452 = float3(0.0f) ;
    (&rg_0)->torque_0 = _S452;
    (&rg_0)->a_7 = _S452;
    (&rg_0)->alpha_0 = _S452;
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
    float3 _S453 = float3(0.0f) ;
    (&rg_1)->torque_0 = _S453;
    (&rg_1)->a_7 = _S453;
    (&rg_1)->alpha_0 = _S453;
    return rg_1;
}

void write_probe_0(uint slot_1, uint k_11, float value_0, KernelContext_0 thread* kernelContext_36)
{
    uint at_4 = kernelContext_36->params_0->probe_base_0 * 4U + slot_1 * kernelContext_36->params_0->probe_stride_0 + k_11;
    thread float4 v_9 = float4(*(kernelContext_36->scratch_0+at_4 / 4U)) ;
    v_9[at_4 % 4U] = value_0;
    *(kernelContext_36->scratch_0+at_4 / 4U) = packed_float4(v_9) ;
    return;
}

void record_probes_0(const Island_0 thread* isl_4, const Rigid_0 thread* rg_2, uint k_12, KernelContext_0 thread* kernelContext_37)
{
    uint4 _S454 = isl_4->probes_0;
    uint at_5 = isl_4->probes_0.x;
    for(;;)
    {
        if(at_5 < (_S454.y))
        {
        }
        else
        {
            break;
        }
        uint4 info_2 = (as_type<uint4>((float4(*(kernelContext_37->loads_0+at_5)) )));
        float4 _S455 = float4(*(kernelContext_37->loads_0+(at_5 + 1U))) ;
        float4 _S456 = float4(*(kernelContext_37->loads_0+(at_5 + 2U))) ;
        float4 _S457 = float4(*(kernelContext_37->loads_0+(at_5 + 3U))) ;
        uint kind_0 = info_2.x;
        uint i_5 = info_2.y;
        float value_1;
        if(kind_0 == 0U)
        {
            float3 small_0 = (float4(*(kernelContext_37->state_0+4U * i_5)) ).xyz + float3(_S455.w, _S456.w, _S457.w);
            float3 _S458 = rg_2->pos_1 - _S456.xyz;
            float3 _S459 = rotate_0(&rg_2->rot_0, (float4((kernelContext_37->chunks_0+i_5)->center_0) ).xyz);
            float3 _S460 = _S458 + _S459;
            float3 _S461 = rg_2->pos_err_1 - _S457.xyz;
            float3 _S462 = rotate_0(&rg_2->rot_0, small_0);
            value_1 = dot(_S460 + (_S461 + _S462), _S455.xyz);
        }
        else
        {
            if(kind_0 == 1U)
            {
                uint _S463 = 4U * i_5;
                float3 _S464 = rotate_0(&rg_2->rot_0, (float4((kernelContext_37->chunks_0+i_5)->center_0) ).xyz + (float4(*(kernelContext_37->state_0+_S463)) ).xyz - isl_4->com_0.xyz);
                float3 _S465 = rg_2->vel_1 + rg_2->vel_err_1 + cross(rg_2->w_4, _S464);
                float3 _S466 = rotate_0(&rg_2->rot_0, (float4(*(kernelContext_37->state_0+(_S463 + 2U))) ).xyz);
                value_1 = dot(_S465 + _S466, _S455.xyz);
            }
            else
            {
                if(kind_0 == 2U)
                {
                    uint _S467 = 3U * i_5;
                    float3 f_3 = (float4(*(kernelContext_37->scratch_0+_S467)) ).xyz;
                    bool _S468 = (info_2.z) == 0U;
                    float3 mc_0;
                    if(_S468)
                    {
                        mc_0 = (float4(*(kernelContext_37->scratch_0+(_S467 + 1U))) ).xyz;
                    }
                    else
                    {
                        mc_0 = (float4(*(kernelContext_37->scratch_0+(_S467 + 2U))) ).xyz;
                    }
                    float3 fc_0;
                    if(_S468)
                    {
                        fc_0 = f_3;
                    }
                    else
                    {
                        fc_0 = - f_3;
                    }
                    value_1 = dot(fc_0, _S455.xyz) + dot(mc_0, _S456.xyz);
                }
                else
                {
                    uint _S469 = 4U * i_5;
                    float3 _S470 = rotate_0(&rg_2->rot_0, float3((float4(*(kernelContext_37->state_0+(_S469 + 1U))) ).w, (float4(*(kernelContext_37->state_0+(_S469 + 2U))) ).w, (float4(*(kernelContext_37->state_0+(_S469 + 3U))) ).w));
                    value_1 = dot(_S470, _S455.xyz);
                }
            }
        }
        write_probe_0(info_2.w, k_12, value_1, kernelContext_37);
        at_5 = at_5 + 4U;
    }
    return;
}

float time_since_0(float4 origin_0, uint k_13, float dt_4, KernelContext_0 thread* kernelContext_38)
{
    return kernelContext_38->params_0->t_hi_0 - origin_0.x + (kernelContext_38->params_0->t_lo_0 - origin_0.y) + float(k_13) * dt_4;
}

float table_eval_0(uint offset_0, uint count_2, float tau_0, KernelContext_0 thread* kernelContext_39)
{
    float4 _S471 = float4(*(kernelContext_39->loads_0+offset_0)) ;
    if(tau_0 <= (_S471.x))
    {
        return _S471.y;
    }
    uint i_6 = 1U;
    for(;;)
    {
        if(i_6 < count_2)
        {
        }
        else
        {
            break;
        }
        uint _S472 = offset_0 + i_6;
        float4 _S473 = float4(*(kernelContext_39->loads_0+_S472)) ;
        float _S474 = _S473.x;
        if(tau_0 <= _S474)
        {
            float4 _S475 = float4(*(kernelContext_39->loads_0+(_S472 - 1U))) ;
            float _S476 = _S475.x;
            float _S477 = _S475.y;
            return _S477 + (tau_0 - _S476) / max(_S474 - _S476, 1.00000000317107685e-30f) * (_S473.y - _S477);
        }
        i_6 = i_6 + 1U;
    }
    return (float4(*(kernelContext_39->loads_0+(offset_0 + count_2 - 1U))) ).y;
}

float eval_function_0(uint term_0, uint k_14, float dt_5, float shift_0, KernelContext_0 thread* kernelContext_40)
{
    uint _S478 = 5U * term_0;
    uint4 info_3 = (as_type<uint4>((float4(*(kernelContext_40->loads_0+_S478)) )));
    float4 _S479 = float4(*(kernelContext_40->loads_0+(_S478 + 3U))) ;
    float4 _S480 = float4(*(kernelContext_40->loads_0+(_S478 + 4U))) ;
    uint kind_1 = info_3.z;
    if(kind_1 == 0U)
    {
        return _S479.z;
    }
    float _S481 = time_since_0(_S479, k_14, dt_5, kernelContext_40);
    float tau_1 = _S481 + shift_0;
    float shape_1;
    if(kind_1 == 1U)
    {
        if(tau_1 <= 0.0f)
        {
            shape_1 = 0.0f;
        }
        else
        {
            float _S482 = _S480.x;
            if(tau_1 >= _S482)
            {
                shape_1 = _S480.y;
            }
            else
            {
                shape_1 = _S480.y * tau_1 / _S482;
            }
        }
        return shape_1;
    }
    bool _S483;
    if(kind_1 == 2U)
    {
        if(tau_1 < 0.0f)
        {
            _S483 = true;
        }
        else
        {
            _S483 = tau_1 > (_S480.x);
        }
        if(_S483)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S480.y * sin(3.14159274101257324f * tau_1 / _S480.x);
        }
        return shape_1;
    }
    if(kind_1 == 3U)
    {
        float sn_0 = tau_1 / _S480.y;
        if(sn_0 < 0.0f)
        {
            _S483 = true;
        }
        else
        {
            _S483 = sn_0 > 1.0f;
        }
        if(_S483)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S480.x * (1.0f - sn_0) * exp(- _S480.z * sn_0);
        }
        return shape_1;
    }
    if(kind_1 == 4U)
    {
        float _S484 = table_eval_0(info_3.w, (as_type<uint>((_S480.x))), tau_1, kernelContext_40);
        return _S484;
    }
    if(kind_1 == 5U)
    {
        (*kernelContext_40->g_seen_0)[1U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float sn_1 = tau_1 / _S480.x;
        if(sn_1 < 0.0f)
        {
            _S483 = true;
        }
        else
        {
            _S483 = sn_1 > 1.0f;
        }
        if(_S483)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = (1.0f - sn_1) * exp(- _S480.y * sn_1);
        }
        float clearing_0 = _S479.w;
        float relax_0;
        if(clearing_0 > 0.0f)
        {
            relax_0 = max(1.0f - tau_1 / clearing_0, 0.0f);
        }
        else
        {
            relax_0 = 0.0f;
        }
        float _S485 = _S480.w;
        return (_S485 + (_S480.z - _S485) * relax_0) * shape_1;
    }
    if(kind_1 == 7U)
    {
        (*kernelContext_40->g_seen_0)[2U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float _S486 = _S480.y;
        if(tau_1 < _S486)
        {
            return _S480.x;
        }
        float s_4 = tau_1 - _S486;
        float _S487 = _S480.w;
        if(s_4 > _S487)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S480.z * sin(3.14159274101257324f * s_4 / _S487);
        }
        return shape_1;
    }
    float _S488 = _S480.x;
    if(_S488 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp(1.0f - tau_1 / _S488, 0.0f, 1.0f);
}

void record_chunk_load_0(uint c_10, float3 f_4, float3 t_8, KernelContext_0 thread* kernelContext_41)
{
    if((kernelContext_41->params_0->solve_mode_0) == 0U)
    {
        return;
    }
    uint _S489 = 2U * c_10;
    *(kernelContext_41->scratch_0+(kernelContext_41->params_0->cload_base_0 + _S489)) = packed_float4(float4(f_4, 0.0f)) ;
    *(kernelContext_41->scratch_0+(kernelContext_41->params_0->cload_base_0 + _S489 + 1U)) = packed_float4(float4(t_8, 0.0f)) ;
    *(kernelContext_41->scratch_0+(kernelContext_41->params_0->cframe_base_0 + _S489)) = packed_float4(float4((float4(*(kernelContext_41->scratch_0+(kernelContext_41->params_0->cframe_base_0 + _S489))) ).xyz + f_4, 0.0f)) ;
    *(kernelContext_41->scratch_0+(kernelContext_41->params_0->cframe_base_0 + _S489 + 1U)) = packed_float4(float4((float4(*(kernelContext_41->scratch_0+(kernelContext_41->params_0->cframe_base_0 + _S489 + 1U))) ).xyz + t_8, 0.0f)) ;
    return;
}

void chunk_external_0(uint _S490, uint _S491, const Quat_0 thread* _S492, uint _S493, float _S494, bool _S495, float3 thread* _S496, float3 thread* _S497, KernelContext_0 thread* kernelContext_42)
{
    bool _S498;
    ChunkStatic_natural_0 device* _S499 = kernelContext_42->chunks_0+_S491;
    float3 _S500 = float3(0.0f) ;
    *_S496 = _S500;
    *_S497 = _S500;
    uint4 _S501 = uint4(_S499->load_range_0) ;
    uint term_1 = _S501.x;
    for(;;)
    {
        if(term_1 < (_S501.y))
        {
        }
        else
        {
            break;
        }
        (*kernelContext_42->g_seen_0)[0U] = 1U;
        uint _S502 = 5U * term_1;
        uint _S503 = (as_type<uint4>((float4(*(kernelContext_42->loads_0+_S502)) ))).y;
        if(_S503 == 2U)
        {
            term_1 = term_1 + 1U;
            continue;
        }
        float4 _S504 = float4(*(kernelContext_42->loads_0+(_S502 + 1U))) ;
        float4 _S505 = float4(*(kernelContext_42->loads_0+(_S502 + 2U))) ;
        float _S506 = eval_function_0(term_1, _S493, _S494, 0.0f, kernelContext_42);
        if(_S503 == 0U)
        {
            _S498 = true;
        }
        else
        {
            _S498 = _S503 == 3U;
        }
        float3 fw_0;
        if(_S498)
        {
            fw_0 = _S504.xyz * float3(_S506) ;
        }
        else
        {
            float3 _S507 = rotate_0(_S492, _S504.xyz);
            fw_0 = _S507 * float3((- _S506 * _S504.w)) ;
        }
        float3 lever_0;
        if(_S503 == 3U)
        {
            lever_0 = _S505.xyz - (float4(*(kernelContext_42->state_0+4U * _S490)) ).xyz;
        }
        else
        {
            lever_0 = _S505.xyz;
        }
        *_S496 = *_S496 + fw_0;
        float3 _S508 = rotate_0(_S492, lever_0);
        *_S497 = *_S497 + cross(_S508, fw_0);
        term_1 = term_1 + 1U;
    }
    if(_S495)
    {
        _S498 = ((uint4(_S499->cinfo_0) ).z) != 0U;
    }
    else
    {
        _S498 = false;
    }
    if(_S498)
    {
        uint4 _S509 = uint4(_S499->cinfo_0) ;
        uint g_1 = _S509.x;
        for(;;)
        {
            if(g_1 < (_S509.y))
            {
            }
            else
            {
                break;
            }
            uint _S510 = 2U * g_1;
            *_S496 = *_S496 + (float4(*(kernelContext_42->scratch_0+(kernelContext_42->params_0->seg_base_0 + _S510))) ).xyz;
            *_S497 = *_S497 + (float4(*(kernelContext_42->scratch_0+(kernelContext_42->params_0->seg_base_0 + _S510 + 1U))) ).xyz;
            g_1 = g_1 + 1U;
        }
    }
    return;
}

float settled_chunk_load_0(uint c_11, const Quat_0 thread* rot_1, uint k_15, float dt_6, bool contact_0, KernelContext_0 thread* kernelContext_43)
{
    thread float3 f_5;
    thread float3 t_9;
    chunk_external_0(c_11, c_11, rot_1, k_15, dt_6, contact_0, &f_5, &t_9, kernelContext_43);
    record_chunk_load_0(c_11, f_5, t_9, kernelContext_43);
    return length(f_5);
}

void net_load_0(uint c_12, const Island_natural_0 thread* isl_5, const Rigid_0 thread* rg_3, uint k_16, float dt_7, bool contact_1, float3 thread* f_6, float3 thread* t_10, KernelContext_0 thread* kernelContext_44)
{
    ChunkStatic_natural_0 device* _S511 = kernelContext_44->chunks_0+c_12;
    thread float3 fl_0;
    thread float3 tl_0;
    chunk_external_0(c_12, c_12, &rg_3->rot_0, k_16, dt_7, contact_1, &fl_0, &tl_0, kernelContext_44);
    float4 _S512 = float4(_S511->center_0) ;
    float3 fc_1 = fl_0 + kernelContext_44->params_0->gravity_0.xyz * float3(_S512.w) ;
    float3 _S513 = _S512.xyz;
    float3 _S514 = (float4(isl_5->com_0) ).xyz;
    float3 _S515 = rotate_0(&rg_3->rot_0, _S513 + (float4(*(kernelContext_44->state_0+4U * c_12)) ).xyz - _S514);
    *f_6 = *f_6 + fc_1;
    *t_10 = *t_10 + (cross(_S515, fc_1) + tl_0);
    uint4 _S516 = uint4(_S511->load_range_0) ;
    uint term_2 = _S516.x;
    for(;;)
    {
        if(term_2 < (_S516.y))
        {
        }
        else
        {
            break;
        }
        uint _S517 = 5U * term_2;
        if(((as_type<uint4>((float4(*(kernelContext_44->loads_0+_S517)) ))).y) != 2U)
        {
            term_2 = term_2 + 1U;
            continue;
        }
        float _S518 = eval_function_0(term_2, k_16, dt_7, 0.0f, kernelContext_44);
        float3 _S519 = float3(_S518) ;
        float3 _S520 = rotate_0(&rg_3->rot_0, (float4(*(kernelContext_44->loads_0+(_S517 + 1U))) ).xyz * _S519);
        *f_6 = *f_6 + _S520;
        float3 _S521 = rotate_0(&rg_3->rot_0, _S513 - _S514);
        float3 _S522 = cross(_S521, _S520);
        float3 _S523 = rotate_0(&rg_3->rot_0, (float4(*(kernelContext_44->loads_0+(_S517 + 2U))) ).xyz * _S519);
        *t_10 = *t_10 + (_S522 + _S523);
        term_2 = term_2 + 1U;
    }
    return;
}

void net_load_1(uint c_13, const Island_0 thread* isl_6, const Rigid_0 thread* rg_4, uint k_17, float dt_8, bool contact_2, float3 thread* f_7, float3 thread* t_11, KernelContext_0 thread* kernelContext_45)
{
    ChunkStatic_natural_0 device* _S524 = kernelContext_45->chunks_0+c_13;
    thread float3 fl_1;
    thread float3 tl_1;
    chunk_external_0(c_13, c_13, &rg_4->rot_0, k_17, dt_8, contact_2, &fl_1, &tl_1, kernelContext_45);
    float4 _S525 = float4(_S524->center_0) ;
    float3 fc_2 = fl_1 + kernelContext_45->params_0->gravity_0.xyz * float3(_S525.w) ;
    float3 _S526 = _S525.xyz;
    float3 _S527 = isl_6->com_0.xyz;
    float3 _S528 = rotate_0(&rg_4->rot_0, _S526 + (float4(*(kernelContext_45->state_0+4U * c_13)) ).xyz - _S527);
    *f_7 = *f_7 + fc_2;
    *t_11 = *t_11 + (cross(_S528, fc_2) + tl_1);
    uint4 _S529 = uint4(_S524->load_range_0) ;
    uint term_3 = _S529.x;
    for(;;)
    {
        if(term_3 < (_S529.y))
        {
        }
        else
        {
            break;
        }
        uint _S530 = 5U * term_3;
        if(((as_type<uint4>((float4(*(kernelContext_45->loads_0+_S530)) ))).y) != 2U)
        {
            term_3 = term_3 + 1U;
            continue;
        }
        float _S531 = eval_function_0(term_3, k_17, dt_8, 0.0f, kernelContext_45);
        float3 _S532 = float3(_S531) ;
        float3 _S533 = rotate_0(&rg_4->rot_0, (float4(*(kernelContext_45->loads_0+(_S530 + 1U))) ).xyz * _S532);
        *f_7 = *f_7 + _S533;
        float3 _S534 = rotate_0(&rg_4->rot_0, _S526 - _S527);
        float3 _S535 = cross(_S534, _S533);
        float3 _S536 = rotate_0(&rg_4->rot_0, (float4(*(kernelContext_45->loads_0+(_S530 + 2U))) ).xyz * _S532);
        *t_11 = *t_11 + (_S535 + _S536);
        term_3 = term_3 + 1U;
    }
    return;
}

void rigid_acceleration_0(const Island_natural_0 thread* isl_7, Rigid_0 thread* rg_5, float3 f_8, float3 t_12)
{
    float4 _S537 = float4(isl_7->inertia0_0) ;
    float4 _S538 = float4(isl_7->inertia1_0) ;
    float4 _S539 = float4(isl_7->inertia2_0) ;
    thread Quat_0 _S540 = rg_5->rot_0;
    float3 _S541 = world_mul_0(&_S540, _S537, _S538, _S539, rg_5->w_4);
    rg_5->a_7 = f_8 / float3((float4(isl_7->com_0) ).w) ;
    float4 _S542 = float4(isl_7->inv0_0) ;
    float4 _S543 = float4(isl_7->inv1_0) ;
    float4 _S544 = float4(isl_7->inv2_0) ;
    float3 _S545 = t_12 - cross(rg_5->w_4, _S541);
    thread Quat_0 _S546 = rg_5->rot_0;
    float3 _S547 = world_mul_0(&_S546, _S542, _S543, _S544, _S545);
    rg_5->alpha_0 = _S547;
    rg_5->torque_0 = t_12;
    return;
}

void rigid_acceleration_1(const Island_0 thread* isl_8, Rigid_0 thread* rg_6, float3 f_9, float3 t_13)
{
    thread Quat_0 _S548 = rg_6->rot_0;
    float3 _S549 = world_mul_0(&_S548, isl_8->inertia0_0, isl_8->inertia1_0, isl_8->inertia2_0, rg_6->w_4);
    rg_6->a_7 = f_9 / float3(isl_8->com_0.w) ;
    float3 _S550 = t_13 - cross(rg_6->w_4, _S549);
    thread Quat_0 _S551 = rg_6->rot_0;
    float3 _S552 = world_mul_0(&_S551, isl_8->inv0_0, isl_8->inv1_0, isl_8->inv2_0, _S550);
    rg_6->alpha_0 = _S552;
    rg_6->torque_0 = t_13;
    return;
}

float3 turn_difference_0(float3 omega_1, float dt_9, float3 v_10)
{
    float _S553 = length(omega_1);
    float angle_3 = _S553 * dt_9;
    if(angle_3 < 1.00000000317107685e-30f)
    {
        return float3(0.0f) ;
    }
    float3 a_8 = omega_1 / float3(_S553) ;
    float s_5 = sin(0.5f * angle_3);
    float3 av_0 = cross(a_8, v_10);
    return av_0 * float3(sin(angle_3))  + cross(a_8, av_0) * float3((2.0f * s_5 * s_5)) ;
}

void integrate_rigid_0(const Island_natural_0 thread* isl_9, Rigid_0 thread* rg_7, float dt_10)
{
    float3 _S554 = float3(dt_10) ;
    comp_add_0(&rg_7->l_2, &rg_7->l_err_1, rg_7->torque_0 * _S554);
    float3 l_3 = rg_7->l_2 + rg_7->l_err_1;
    comp_add_0(&rg_7->vel_1, &rg_7->vel_err_1, rg_7->a_7 * _S554);
    float3 vel_2 = rg_7->vel_1 + rg_7->vel_err_1;
    float4 _S555 = float4(isl_9->inv0_0) ;
    float4 _S556 = float4(isl_9->inv1_0) ;
    float4 _S557 = float4(isl_9->inv2_0) ;
    thread Quat_0 _S558 = rg_7->rot_0;
    float3 _S559 = world_mul_0(&_S558, _S555, _S556, _S557, l_3);
    float3 _S560 = vel_2 * _S554;
    float3 _S561 = (float4(isl_9->com_0) ).xyz;
    thread Quat_0 _S562 = rg_7->rot_0;
    float3 _S563 = rotate_0(&_S562, _S561);
    comp_add_0(&rg_7->pos_1, &rg_7->pos_err_1, _S560 - turn_difference_0(_S559, dt_10, _S563));
    turn_left_0(&rg_7->rot_0, &rg_7->rot_err_0, _S559, dt_10);
    thread Quat_0 _S564 = rg_7->rot_0;
    float3 _S565 = world_mul_0(&_S564, _S555, _S556, _S557, l_3);
    rg_7->w_4 = _S565;
    return;
}

void integrate_rigid_1(const Island_0 thread* isl_10, Rigid_0 thread* rg_8, float dt_11)
{
    float3 _S566 = float3(dt_11) ;
    comp_add_0(&rg_8->l_2, &rg_8->l_err_1, rg_8->torque_0 * _S566);
    float3 l_4 = rg_8->l_2 + rg_8->l_err_1;
    comp_add_0(&rg_8->vel_1, &rg_8->vel_err_1, rg_8->a_7 * _S566);
    float3 vel_3 = rg_8->vel_1 + rg_8->vel_err_1;
    float4 _S567 = isl_10->inv0_0;
    float4 _S568 = isl_10->inv1_0;
    float4 _S569 = isl_10->inv2_0;
    thread Quat_0 _S570 = rg_8->rot_0;
    float3 _S571 = world_mul_0(&_S570, isl_10->inv0_0, isl_10->inv1_0, isl_10->inv2_0, l_4);
    float3 _S572 = vel_3 * _S566;
    float3 _S573 = isl_10->com_0.xyz;
    thread Quat_0 _S574 = rg_8->rot_0;
    float3 _S575 = rotate_0(&_S574, _S573);
    comp_add_0(&rg_8->pos_1, &rg_8->pos_err_1, _S572 - turn_difference_0(_S571, dt_11, _S575));
    turn_left_0(&rg_8->rot_0, &rg_8->rot_err_0, _S571, dt_11);
    thread Quat_0 _S576 = rg_8->rot_0;
    float3 _S577 = world_mul_0(&_S576, _S567, _S568, _S569, l_4);
    rg_8->w_4 = _S577;
    return;
}

bool connected_0(const JointState_0 thread* st_0, bool has_rebar_0)
{
    bool _S578;
    if((st_0->damage_0) < 1.0f)
    {
        _S578 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S578 = (st_0->rebar_broken_0) == 0.0f;
        }
        else
        {
            _S578 = false;
        }
    }
    return _S578;
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
    float4 _S579 = float4(b_23->geom0_0) ;
    float area_2 = _S579.x;
    float _S580 = q_lin_0.z;
    float axial_0 = (metal::fast::divide((_S580), (area_2)));
    float4 _S581 = float4(b_23->geom1_0) ;
    float _S582 = (metal::fast::divide((abs(q_ang_0.x)), (_S581.x)));
    float _S583 = (metal::fast::divide((abs(q_ang_0.y)), (_S581.y)));
    float bending_0 = _S582 + _S583;
    float _S584 = q_lin_0.x;
    float _S585 = q_lin_0.y;
    float _S586 = (metal::fast::sqrt((_S584 * _S584 + _S585 * _S585)));
    float _S587 = (metal::fast::divide((_S586), (area_2)));
    float _S588 = (metal::fast::divide((abs(q_ang_0.z)), (_S579.w)));
    float shear_1 = _S587 + _S588;
    thread Measures_0 m_3;
    (&m_3)->tension_0 = axial_0 + bending_0;
    (&m_3)->shear_0 = shear_1;
    float _S589 = - axial_0;
    (&m_3)->normal_compression_0 = max(_S589, 0.0f);
    (&m_3)->compression_0 = _S589 + bending_0;
    (&m_3)->compressive_force_0 = max(- _S580, 0.0f);
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
    float4 _S590 = mat_1->dif_0;
    float ref_0 = mat_1->dif_0.x;
    if(r_6 <= ref_0)
    {
        return 1.0f;
    }
    float _S591 = _S590.z;
    float f_10;
    if(r_6 <= _S591)
    {
        float _S592 = (metal::fast::divide((r_6), (ref_0)));
        float _S593 = (metal::fast::pow((_S592), (_S590.y)));
        f_10 = _S593;
    }
    else
    {
        float _S594 = (metal::fast::divide((_S591), (ref_0)));
        float _S595 = (metal::fast::pow((_S594), (_S590.y)));
        float _S596 = (metal::fast::divide((r_6), (_S591)));
        float _S597 = (metal::fast::pow((_S596), (_S590.w)));
        f_10 = _S595 * _S597;
    }
    return clamp(f_10, 1.0f, mat_1->misc_0.x);
}

float fatigue_factor_0(const JointMaterial_0 constant* mat_2, float life_1)
{
    if(((mat_2->kind_flags_0.y) & 64U) == 0U)
    {
        return 1.0f;
    }
    float _S598 = clamp(life_1, 0.0f, 1.0f);
    float _S599 = (metal::fast::divide((1.0f), (mat_2->misc_0.y - 2.0f)));
    float _S600 = (metal::fast::pow((_S598), (_S599)));
    return _S600;
}

float infinity_0()
{
    return (as_type<float>((2139095040U)));
}

float4 failure_indices_0(const JointMaterial_0 constant* mat_3, const JointBond_natural_0 thread* b_24, const Measures_0 thread* m_4, float multiplier_0)
{
    float fc_3 = mat_3->strength_0.y * multiplier_0;
    float _S601 = min(mat_3->strength_0.z * multiplier_0 + mat_3->strength_0.w * m_4->normal_compression_0, mat_3->energy_1.x * multiplier_0);
    thread float4 idx_0;
    float _S602 = (metal::fast::divide((m_4->tension_0), (mat_3->strength_0.x * multiplier_0)));
    idx_0.x = max(_S602, 0.0f);
    float _S603;
    if(_S601 > 0.0f)
    {
        float _S604 = (metal::fast::divide((m_4->shear_0), (_S601)));
        _S603 = _S604;
    }
    else
    {
        _S603 = infinity_0();
    }
    idx_0.y = _S603;
    float _S605 = (metal::fast::divide((m_4->compression_0), (fc_3)));
    idx_0.z = max(_S605, 0.0f);
    float _S606 = (float4(b_24->stiff1_0) ).y;
    if(_S606 > 0.0f)
    {
        float _S607 = (metal::fast::divide((m_4->compressive_force_0), (_S606)));
        _S603 = _S607;
    }
    else
    {
        _S603 = 0.0f;
    }
    idx_0.w = _S603;
    return idx_0;
}

float sq_0(float x_8)
{
    return x_8 * x_8;
}

float damage_law_0(uint kind_2, float kappa_1, float r_7)
{
    if(kappa_1 <= 1.0f)
    {
        return 0.0f;
    }
    if(kind_2 == 0U)
    {
        if(r_7 <= 1.0f)
        {
            return 1.0f;
        }
        float _S608 = (metal::fast::divide((r_7 * (kappa_1 - 1.0f)), (kappa_1 * (r_7 - 1.0f))));
        return min(_S608, 1.0f);
    }
    if(kappa_1 >= (0.5f * (r_7 + 1.0f)))
    {
        return 1.0f;
    }
    float _S609 = (metal::fast::divide((1.0f), (kappa_1)));
    return 1.0f - _S609;
}

__attribute__((noinline))
float2 damage_increment_0(uint kind_3, float kappa_old_0, float lambda_0, float r_8, float d_old_0, float psi_0)
{
    float _S610 = damage_law_0(kind_3, lambda_0, r_8);
    float _S611 = max(_S610, d_old_0);
    bool _S612;
    if(_S611 <= d_old_0)
    {
        _S612 = true;
    }
    else
    {
        _S612 = d_old_0 >= 1.0f;
    }
    if(_S612)
    {
        return float2(d_old_0, 0.0f);
    }
    float u0_0 = (metal::fast::divide((psi_0), (lambda_0 * lambda_0)));
    float _S613 = max(kappa_old_0, 1.0f);
    if(kind_3 == 0U)
    {
        if(r_8 > 1.0f)
        {
            float _S614 = (metal::fast::divide((u0_0 * r_8), (r_8 - 1.0f)));
            return float2(_S611, _S614 * max(min(lambda_0, r_8) - min(_S613, r_8), 0.0f));
        }
        return float2(_S611, (1.0f - d_old_0) * psi_0);
    }
    float ku_0 = 0.5f * (r_8 + 1.0f);
    float plateau_0 = u0_0 * max(min(lambda_0, ku_0) - min(_S613, ku_0), 0.0f);
    float snap_0;
    if(_S611 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return float2(_S611, plateau_0 + snap_0);
}

void compressed_region_0(float w0_0, float w1_0, float dz_0, float ax_0, float ay_0, array<float, int(6)> thread* region_0)
{
    uint count_3;
    float h0_0 = 0.5f * w0_0;
    float h1_0 = 0.5f * w1_0;
    float _S615 = - h0_0;
    float _S616 = - h1_0;
    array<float2, int(4)> _S617 = { { float2(_S615, _S616), float2(h0_0, _S616), float2(h0_0, h1_0), float2(_S615, h1_0) } };
    thread array<float2, int(8)> poly_0;
    uint i_7 = 0U;
    uint count_4 = 0U;
    for(;;)
    {
        if(i_7 < 4U)
        {
        }
        else
        {
            break;
        }
        uint _S618 = i_7;
        uint _S619 = i_7 + 1U;
        uint _S620 = _S619 % 4U;
        float _S621 = _S617[i_7].y;
        float _S622 = _S617[i_7].x;
        float fp_0 = dz_0 + ax_0 * _S621 - ay_0 * _S622;
        float _S623 = _S617[_S620].y;
        float _S624 = _S617[_S620].x;
        float fq_0 = dz_0 + ax_0 * _S623 - ay_0 * _S624;
        bool _S625 = fp_0 < 0.0f;
        if(_S625)
        {
            uint _S626 = count_4 + 1U;
            poly_0[count_4] = _S617[_S618];
            count_3 = _S626;
        }
        else
        {
            count_3 = count_4;
        }
        if(_S625 != (fq_0 < 0.0f))
        {
            float t_14 = fp_0 / (fp_0 - fq_0);
            uint _S627 = count_3 + 1U;
            poly_0[count_3] = float2(_S622 + t_14 * (_S624 - _S622), _S621 + t_14 * (_S623 - _S621));
            count_4 = _S627;
        }
        else
        {
            count_4 = count_3;
        }
        i_7 = _S619;
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
    i_7 = 0U;
    float a_9 = 0.0f;
    float sx_0 = 0.0f;
    float sy_0 = 0.0f;
    float ixx_0 = 0.0f;
    float iyy_0 = 0.0f;
    float ixy_0 = 0.0f;
    for(;;)
    {
        if(i_7 < count_4)
        {
        }
        else
        {
            break;
        }
        float _S628 = o_1.x;
        float x0_0 = poly_0[i_7].x - _S628;
        float _S629 = o_1.y;
        float y0_0 = poly_0[i_7].y - _S629;
        uint _S630 = i_7 + 1U;
        uint _S631 = _S630 % count_4;
        float x1_0 = poly_0[_S631].x - _S628;
        float y1_0 = poly_0[_S631].y - _S629;
        float _S632 = x0_0 * y1_0;
        float _S633 = x1_0 * y0_0;
        float cr_0 = _S632 - _S633;
        float a_10 = a_9 + cr_0 / 2.0f;
        float sx_1 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        float sy_1 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        float ixx_1 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        float iyy_1 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        float ixy_1 = ixy_0 + (_S632 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S633) * cr_0 / 24.0f;
        i_7 = _S630;
        a_9 = a_10;
        sx_0 = sx_1;
        sy_0 = sy_1;
        ixx_0 = ixx_1;
        iyy_0 = iyy_1;
        ixy_0 = ixy_1;
    }
    if(a_9 <= 0.0f)
    {
        return;
    }
    float cx_0 = sx_0 / a_9;
    float cy_0 = sy_0 / a_9;
    (*region_0)[int(0)] = a_9;
    (*region_0)[int(1)] = o_1.x + cx_0;
    (*region_0)[int(2)] = o_1.y + cy_0;
    float _S634 = a_9 * cx_0;
    (*region_0)[int(3)] = ixx_0 - _S634 * cx_0;
    (*region_0)[int(4)] = iyy_0 - a_9 * cy_0 * cy_0;
    (*region_0)[int(5)] = ixy_0 - _S634 * cy_0;
    return;
}

__attribute__((noinline))
float4 no_tension_patch_0(float kn_0, float w0_1, float w1_1, float dz_1, float ax_1, float ay_1)
{
    thread array<float, int(6)> r_9;
    compressed_region_0(w0_1, w1_1, dz_1, ax_1, ay_1, &r_9);
    float a_11 = r_9[int(0)];
    if((r_9[int(0)]) == 0.0f)
    {
        return float4(0.0f) ;
    }
    float k_18 = kn_0 / (w0_1 * w1_1);
    float fc_4 = dz_1 + ax_1 * r_9[int(2)] - ay_1 * r_9[int(1)];
    float _S635 = a_11 * fc_4;
    float _S636 = - ay_1;
    return float4(k_18 * a_11 * fc_4, k_18 * (_S635 * r_9[int(2)] + (_S636 * r_9[int(5)] + ax_1 * r_9[int(4)])), - k_18 * (_S635 * r_9[int(1)] + (_S636 * r_9[int(3)] + ax_1 * r_9[int(5)])), 0.5f * k_18 * (_S635 * fc_4 + ay_1 * ay_1 * r_9[int(3)] + ax_1 * ax_1 * r_9[int(4)] - 2.0f * ax_1 * ay_1 * r_9[int(5)]));
}

float signum_0(float x_9)
{
    float _S637;
    if(((as_type<uint>((x_9))) & 2147483648U) != 0U)
    {
        _S637 = -1.0f;
    }
    else
    {
        _S637 = 1.0f;
    }
    return _S637;
}

float2 return_map_0(float k_19, float total_2, float plastic_0, float cap_0)
{
    float trial_0 = k_19 * (total_2 - plastic_0);
    if((abs(trial_0)) <= cap_0)
    {
        return float2(trial_0, 0.0f);
    }
    float f_11 = cap_0 * signum_0(trial_0);
    float _S638 = (metal::fast::divide((trial_0 - f_11), (k_19)));
    return float2(f_11, _S638);
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
    float3 _S639 = float3(0.0f) ;
    (&c_14)->q_lin_1 = _S639;
    (&c_14)->q_ang_1 = _S639;
    (&c_14)->energy_2 = 0.0f;
    (&c_14)->diss_4 = 0.0f;
    (&c_14)->plastic_1 = plastic_2;
    uint _S640 = mat_4->kind_flags_0.y;
    if((_S640 & 2U) == 0U)
    {
        return c_14;
    }
    float4 _S641 = float4(b_25->stiff0_0) ;
    float kn_1 = _S641.x;
    float ks_0 = _S641.y;
    float kt_0 = (float4(b_25->stiff1_0) ).x;
    float4 _S642 = float4(b_25->geom0_0) ;
    float w0_2 = _S642.y;
    float w1_2 = _S642.z;
    float diss_5;
    float nc_sum_0;
    float m1_0;
    float m2_0;
    float energy_3;
    if((_S640 & 4U) != 0U)
    {
        float4 p_11 = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        float _S643 = p_11.y;
        float _S644 = p_11.z;
        float _S645 = p_11.w;
        nc_sum_0 = p_11.x;
        m1_0 = _S643;
        m2_0 = _S644;
        energy_3 = _S645;
    }
    else
    {
        float ki_0 = kn_1 * (1.0f - crush_2) / 36.0f;
        float _S646 = d_ang_0.x;
        float _S647 = d_ang_0.y;
        float spread_0 = abs(_S646) * 0.4166666567325592f * w1_2 + abs(_S647) * 0.4166666567325592f * w0_2;
        float _S648 = d_lin_0.z;
        float slack_0 = 9.99999997475242708e-07f * (abs(_S648) + spread_0);
        if((_S648 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S648 + spread_0) < (- slack_0))
            {
                float i1_0 = 2.91666650772094727f * w0_2 * w0_2;
                float i2_0 = 2.91666650772094727f * w1_2 * w1_2;
                float _S649 = ki_0 * _S646 * i2_0;
                float _S650 = ki_0 * _S647 * i1_0;
                float _S651 = 0.5f * ki_0 * (36.0f * _S648 * _S648 + _S646 * _S646 * i2_0 + _S647 * _S647 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S648;
                m1_0 = _S649;
                m2_0 = _S650;
                energy_3 = _S651;
            }
            else
            {
                uint i_8 = 0U;
                diss_5 = 0.0f;
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
                    float _S652 = SPRING_AT_0[i_8] * w0_2;
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
                        float di_0 = _S648 + _S646 * s2_0 - _S647 * _S652;
                        if(di_0 < 0.0f)
                        {
                            float f_12 = ki_0 * di_0;
                            float m1_2 = m1_0 + f_12 * s2_0;
                            float m2_2 = m2_0 - f_12 * _S652;
                            float energy_5 = energy_3 + 0.5f * ki_0 * di_0 * di_0;
                            nc_sum_0 = nc_sum_0 + f_12;
                            m1_0 = m1_2;
                            m2_0 = m2_2;
                            energy_3 = energy_5;
                        }
                        j_5 = j_5 + 1U;
                    }
                    i_8 = i_8 + 1U;
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
    float _S653 = ks_0 * (d_lin_0.x - plastic_2.x);
    float _S654 = ks_0 * (d_lin_0.y - plastic_2.y);
    float tn_0 = (metal::fast::sqrt((_S653 * _S653 + _S654 * _S654)));
    bool _S655;
    if(tn_0 > slide_cap_0)
    {
        _S655 = tn_0 > 0.0f;
    }
    else
    {
        _S655 = false;
    }
    if(_S655)
    {
        float _S656 = (metal::fast::divide((_S653), (tn_0)));
        float _S657 = (metal::fast::divide((_S654), (tn_0)));
        float dslip_0 = (metal::fast::divide((tn_0 - slide_cap_0), (ks_0)));
        p_12.x = p_12.x + _S656 * dslip_0;
        p_12.y = p_12.y + _S657 * dslip_0;
        (&c_14)->q_lin_1.x = _S656 * slide_cap_0;
        (&c_14)->q_lin_1.y = _S657 * slide_cap_0;
        diss_5 = slide_cap_0 * dslip_0;
    }
    else
    {
        (&c_14)->q_lin_1.x = _S653;
        (&c_14)->q_lin_1.y = _S654;
        diss_5 = 0.0f;
    }
    float2 tq_0 = return_map_0(kt_0, d_ang_0.z, p_12.z, slide_cap_0 * (float4(b_25->geom1_0) ).z);
    float _S658 = tq_0.x;
    float _S659 = tq_0.y;
    float diss_6 = diss_5 + abs(_S658) * abs(_S659);
    p_12.z = p_12.z + _S659;
    (&c_14)->q_ang_1.z = _S658;
    float _S660 = (metal::fast::divide((sq_0((&c_14)->q_lin_1.x)), (ks_0)));
    float _S661 = (metal::fast::divide((sq_0((&c_14)->q_lin_1.y)), (ks_0)));
    float _S662 = _S660 + _S661;
    float _S663 = (metal::fast::divide((sq_0(_S658)), (kt_0)));
    (&c_14)->energy_2 = energy_3 + 0.5f * (_S662 + _S663);
    (&c_14)->diss_4 = diss_6;
    (&c_14)->plastic_1 = p_12;
    return c_14;
}

float3 contact_offsets_0(const JointMaterial_0 constant* mat_5, const JointBond_natural_0 thread* b_26, float crush_3, float3 plastic_3, float3 d_lin_1, float3 d_ang_1)
{
    uint _S664 = mat_5->kind_flags_0.y;
    if((_S664 & 2U) == 0U)
    {
        return plastic_3;
    }
    float4 _S665 = float4(b_26->stiff0_0) ;
    float kn_2 = _S665.x;
    float ks_1 = _S665.y;
    float kt_1 = (float4(b_26->stiff1_0) ).x;
    float4 _S666 = float4(b_26->geom0_0) ;
    float w0_3 = _S666.y;
    float w1_3 = _S666.z;
    float nc_sum_1;
    if((_S664 & 4U) != 0U)
    {
        float4 _S667 = no_tension_patch_0(kn_2 * (1.0f - crush_3), w0_3, w1_3, d_lin_1.z, d_ang_1.x, d_ang_1.y);
        nc_sum_1 = _S667.x;
    }
    else
    {
        float ki_1 = kn_2 * (1.0f - crush_3) / 36.0f;
        float _S668 = d_ang_1.x;
        float _S669 = d_ang_1.y;
        float spread_1 = abs(_S668) * 0.4166666567325592f * w1_3 + abs(_S669) * 0.4166666567325592f * w0_3;
        float _S670 = d_lin_1.z;
        float slack_1 = 9.99999997475242708e-07f * (abs(_S670) + spread_1);
        if((_S670 - spread_1) > slack_1)
        {
            nc_sum_1 = 0.0f;
        }
        else
        {
            if((_S670 + spread_1) < (- slack_1))
            {
                nc_sum_1 = ki_1 * 36.0f * _S670;
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
                    float _S671 = SPRING_AT_0[i_9] * w0_3;
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
                        float di_1 = _S670 + _S668 * (SPRING_AT_0[j_6] * w1_3) - _S669 * _S671;
                        if(di_1 < 0.0f)
                        {
                            nc_sum_1 = nc_sum_1 + ki_1 * di_1;
                        }
                        j_6 = j_6 + 1U;
                    }
                    i_9 = i_9 + 1U;
                    nc_sum_2 = nc_sum_1;
                }
                nc_sum_1 = nc_sum_2;
            }
        }
    }
    float nc_1 = - nc_sum_1;
    thread float3 p_13 = plastic_3;
    float slide_cap_1 = mat_5->strength_0.w * nc_1;
    float _S672 = ks_1 * (d_lin_1.x - plastic_3.x);
    float _S673 = ks_1 * (d_lin_1.y - plastic_3.y);
    float tn_1 = (metal::fast::sqrt((_S672 * _S672 + _S673 * _S673)));
    bool _S674;
    if(tn_1 > slide_cap_1)
    {
        _S674 = tn_1 > 0.0f;
    }
    else
    {
        _S674 = false;
    }
    if(_S674)
    {
        float _S675 = (metal::fast::divide((_S672), (tn_1)));
        float _S676 = (metal::fast::divide((_S673), (tn_1)));
        float dslip_1 = (metal::fast::divide((tn_1 - slide_cap_1), (ks_1)));
        p_13.x = p_13.x + _S675 * dslip_1;
        p_13.y = p_13.y + _S676 * dslip_1;
    }
    float2 tq_1 = return_map_0(kt_1, d_ang_1.z, p_13.z, slide_cap_1 * (float4(b_26->geom1_0) ).z);
    p_13.z = p_13.z + tq_1.y;
    return p_13;
}

float life_rate_0(const JointMaterial_0 constant* mat_6, float s_6)
{
    if(s_6 <= 0.0f)
    {
        return 0.0f;
    }
    float _S677 = mat_6->misc_0.y;
    float _S678 = _S677 + 1.0f;
    float _S679 = (metal::fast::pow((s_6), (_S677)));
    float _S680 = (metal::fast::divide((_S678 * _S679), (mat_6->misc_0.z)));
    return _S680;
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

JointResponse_0 joint_evaluate_0(const JointMaterial_0 constant* mat_7, const JointBond_natural_0 thread* b_27, const JointState_0 thread* state_7, float3 d_lin_2, float3 d_ang_2, float dt_12, bool fracture_1)
{
    float4 _S681 = float4(b_27->stiff0_0) ;
    float kn_3 = _S681.x;
    float ks_2 = _S681.y;
    float kb1_0 = _S681.z;
    float kb2_0 = _S681.w;
    float4 _S682 = float4(b_27->stiff1_0) ;
    float kt_2 = _S682.x;
    bool has_rebar_1 = (_S682.w) != 0.0f;
    uint kind_4 = mat_7->kind_flags_0.x;
    uint flags_1 = mat_7->kind_flags_0.y;
    bool softening_0 = (flags_1 & 1U) != 0U;
    thread JointState_0 st_1 = *state_7;
    bool _S683 = connected_0(state_7, has_rebar_1);
    float3 qe_lin_0 = d_lin_2 * float3(ks_2, ks_2, kn_3);
    float3 qe_ang_0 = d_ang_2 * float3(kb1_0, kb2_0, kt_2);
    Measures_0 _S684 = stress_measures_0(b_27, qe_lin_0, qe_ang_0);
    float _S685 = max(max(_S684.tension_0, _S684.shear_0), _S684.compression_0);
    bool _S686 = dt_12 > 0.0f;
    float dif_1;
    if(_S686)
    {
        float _S687 = (metal::fast::divide((_S685 - (&st_1)->governing_stress_0), (dt_12)));
        float raw_0 = (metal::fast::divide((max(_S687, 0.0f)), (mat_7->misc_0.w)));
        float tau_2 = _S682.z;
        if((flags_1 & 16U) != 0U)
        {
            float _S688 = (metal::fast::divide((dt_12), (tau_2)));
            dif_1 = - expm1_accurate_0(- _S688);
        }
        else
        {
            float _S689 = (metal::fast::divide((dt_12), (tau_2)));
            dif_1 = min(_S689, 1.0f);
        }
        (&st_1)->strain_rate_0 = (&st_1)->strain_rate_0 + (raw_0 - (&st_1)->strain_rate_0) * dif_1;
        (&st_1)->governing_stress_0 = _S685;
    }
    if((flags_1 & 32U) != 0U)
    {
        float _S690 = dif_factor_0(mat_7, (&st_1)->strain_rate_0);
        dif_1 = _S690;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = (float4(b_27->geom1_0) ).w;
    float _S691 = weibull_0 * dif_1;
    float _S692 = fatigue_factor_0(mat_7, (&st_1)->life_0);
    float multiplier_1 = _S691 * _S692;
    thread Measures_0 _S693 = _S684;
    float4 _S694 = failure_indices_0(mat_7, b_27, &_S693, multiplier_1);
    float _S695 = _S694.x;
    float _S696 = _S694.y;
    (&st_1)->utilization_0 = max(max(_S695, _S696), max(_S694.z, _S694.w));
    float _S697 = d_lin_2.x;
    float _S698 = d_lin_2.y;
    float _S699 = ks_2 * (sq_0(_S697) + sq_0(_S698)) + kb1_0 * sq_0(d_ang_2.x) + kb2_0 * sq_0(d_ang_2.y) + kt_2 * sq_0(d_ang_2.z);
    float _S700 = d_lin_2.z;
    bool _S701 = _S700 > 0.0f;
    if(_S701)
    {
        dif_1 = kn_3 * sq_0(_S700);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S699 + dif_1);
    float psi_c_0;
    if(_S700 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_3 * sq_0(_S700);
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
    bool _S702;
    float3 qc_lin_0;
    if(fracture_1)
    {
        bool _S703 = _S695 >= _S696;
        if(_S703)
        {
            diss_contact_0 = _S695;
        }
        else
        {
            diss_contact_0 = _S696;
        }
        uint mode_ts_0;
        if(_S703)
        {
            mode_ts_0 = 1U;
        }
        else
        {
            mode_ts_0 = 2U;
        }
        if(diss_contact_0 > ((&st_1)->kappa_0))
        {
            _S702 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S702 = false;
        }
        if(_S702)
        {
            _S702 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S702 = false;
        }
        uint mode_c_0;
        if(_S702)
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
                float _S704 = (metal::fast::divide((psi_contact_0 * (float4(b_27->geom0_0) ).x * diss_contact_0 * diss_contact_0), (psi_ts_0)));
                intact_normal_0 = _S704;
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
            float _S705 = inc_0.x;
            if(_S705 > ((&st_1)->damage_0))
            {
                Contact_0 _S706 = contact_part_0(mat_7, b_27, (&st_1)->crush_1, plastic_4, d_lin_2, d_ang_2);
                float _S707 = max(_S706.energy_2 - (1.0f - (&st_1)->crush_1) * psi_c_0, 0.0f);
                float _S708 = max(inc_0.y - _S707 * (_S705 - (&st_1)->damage_0), 0.0f);
                float _S709 = max((psi_ts_0 - _S707) * (_S705 - (&st_1)->damage_0) - _S708, 0.0f);
                (&st_1)->damage_0 = _S705;
                (&st_1)->mode_0 = mode_ts_0;
                dissipated_3 = _S708;
                overshoot_1 = _S709;
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
        float _S710 = state_7->damage_0;
        if((state_7->damage_0) > 0.0f)
        {
            Contact_0 _S711 = contact_part_0(mat_7, b_27, state_7->crush_1, float3(state_7->plastic_x_0, state_7->plastic_y_0, state_7->plastic_t_0), d_lin_2, d_ang_2);
            qc_lin_0 = qe_ang_0 * float3((1.0f - _S710))  + _S711.q_ang_1 * float3(_S710) ;
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S712 = stress_measures_0(b_27, float3(0.0f, 0.0f, min(qe_lin_0.z, 0.0f)), qc_lin_0);
        thread Measures_0 _S713 = _S712;
        float4 _S714 = failure_indices_0(mat_7, b_27, &_S713, multiplier_1);
        float _S715 = _S714.z;
        float _S716 = _S714.w;
        bool _S717 = _S715 >= _S716;
        if(_S717)
        {
            psi_contact_0 = _S715;
        }
        else
        {
            psi_contact_0 = _S716;
        }
        if(_S717)
        {
            mode_c_0 = 3U;
        }
        else
        {
            mode_c_0 = 4U;
        }
        if(psi_contact_0 > ((&st_1)->kappa_c_0))
        {
            _S702 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S702 = false;
        }
        if(_S702)
        {
            _S702 = psi_c_0 > 0.0f;
        }
        else
        {
            _S702 = false;
        }
        if(_S702)
        {
            if(softening_0)
            {
                float _S718 = (metal::fast::divide((mat_7->energy_1.w * (float4(b_27->geom0_0) ).x * psi_contact_0 * psi_contact_0), (psi_c_0)));
                intact_normal_0 = _S718;
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
            float _S719 = inc_1.x;
            if(_S719 > ((&st_1)->crush_1))
            {
                float _S720 = inc_1.y;
                float dissipated_4 = dissipated_3 + _S720;
                float overshoot_2 = overshoot_1 + max(psi_c_0 * (_S719 - (&st_1)->crush_1) - _S720, 0.0f);
                (&st_1)->crush_1 = _S719;
                (&st_1)->mode_0 = mode_c_0;
                if(_S719 >= 1.0f)
                {
                    _S702 = ((&st_1)->damage_0) < 1.0f;
                }
                else
                {
                    _S702 = false;
                }
                if(_S702)
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
    float3 _S721 = float3(0.0f) ;
    float3 qc_ang_0;
    if(((&st_1)->damage_0) == 0.0f)
    {
        if((flags_1 & 8U) == 0U)
        {
            float3 _S722 = contact_offsets_0(mat_7, b_27, (&st_1)->crush_1, plastic_4, d_lin_2, d_ang_2);
            (&st_1)->plastic_x_0 = _S722.x;
            (&st_1)->plastic_y_0 = _S722.y;
            (&st_1)->plastic_t_0 = _S722.z;
        }
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S721;
        qc_ang_0 = _S721;
        psi_contact_0 = 0.0f;
    }
    else
    {
        Contact_0 _S723 = contact_part_0(mat_7, b_27, (&st_1)->crush_1, plastic_4, d_lin_2, d_ang_2);
        (&st_1)->plastic_x_0 = _S723.plastic_1.x;
        (&st_1)->plastic_y_0 = _S723.plastic_1.y;
        (&st_1)->plastic_t_0 = _S723.plastic_1.z;
        diss_contact_0 = _S723.diss_4;
        qc_lin_0 = _S723.q_lin_1;
        qc_ang_0 = _S723.q_ang_1;
        psi_contact_0 = _S723.energy_2;
    }
    float dissipated_6 = dissipated_3 + dmg_0 * diss_contact_0;
    if(_S701)
    {
        intact_normal_0 = kn_3 * _S700;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_1)->crush_1) * kn_3 * _S700;
    }
    float _S724 = 1.0f - dmg_0;
    float3 force_lin_2 = float3(_S724 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S724 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S724 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3 force_ang_2 = qe_ang_0 * float3(_S724)  + qc_ang_0 * float3(dmg_0) ;
    float stored_6 = _S724 * (psi_ts_0 + (1.0f - (&st_1)->crush_1) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S702 = ((&st_1)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S702 = false;
    }
    float stored_7;
    float3 force_lin_3;
    if(_S702)
    {
        float4 _S725 = float4(b_27->rebar0_0) ;
        float k_axial_0 = _S725.x;
        float k_dowel_0 = _S725.y;
        float yield_force_0 = _S725.z;
        float dowel_capacity_0 = _S725.w;
        float2 nr_0 = return_map_0(k_axial_0, _S700, (&st_1)->rebar_plastic_0, yield_force_0);
        float2 v1_0 = return_map_0(k_dowel_0, _S697, (&st_1)->rebar_slip0_0, dowel_capacity_0);
        float2 v2_0 = return_map_0(k_dowel_0, _S698, (&st_1)->rebar_slip1_0, dowel_capacity_0);
        float _S726 = nr_0.y;
        float _S727 = v1_0.y;
        float _S728 = v2_0.y;
        float work_0 = yield_force_0 * abs(_S726) + dowel_capacity_0 * (abs(_S727) + abs(_S728));
        (&st_1)->rebar_plastic_0 = (&st_1)->rebar_plastic_0 + _S726;
        (&st_1)->rebar_slip0_0 = (&st_1)->rebar_slip0_0 + _S727;
        (&st_1)->rebar_slip1_0 = (&st_1)->rebar_slip1_0 + _S728;
        (&st_1)->rebar_work_0 = (&st_1)->rebar_work_0 + work_0;
        float dissipated_7 = dissipated_6 + work_0;
        float _S729 = nr_0.x;
        float _S730 = (metal::fast::divide((sq_0(_S729)), (k_axial_0)));
        float _S731 = v1_0.x;
        float _S732 = v2_0.x;
        float _S733 = (metal::fast::divide((sq_0(_S731) + sq_0(_S732)), (k_dowel_0)));
        float elastic_0 = 0.5f * (_S730 + _S733);
        if(fracture_1)
        {
            _S702 = ((&st_1)->rebar_work_0) >= ((float4(b_27->rebar1_0) ).x);
        }
        else
        {
            _S702 = false;
        }
        if(_S702)
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
            force_lin_3 = force_lin_2 + float3(_S731, _S732, _S729);
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
        _S702 = _S686;
    }
    else
    {
        _S702 = false;
    }
    if(_S702)
    {
        _S702 = (flags_1 & 64U) != 0U;
    }
    else
    {
        _S702 = false;
    }
    if(_S702)
    {
        Measures_0 _S734 = stress_measures_0(b_27, force_lin_3, force_ang_2);
        thread Measures_0 _S735 = _S734;
        float4 _S736 = failure_indices_0(mat_7, b_27, &_S735, weibull_0);
        float _S737 = life_rate_0(mat_7, max(max(_S736.x, _S736.y), _S736.z));
        (&st_1)->life_0 = max((&st_1)->life_0 - _S737 * dt_12, 0.0f);
    }
    (&st_1)->dissipated_0 = (&st_1)->dissipated_0 + dissipated_3;
    thread JointResponse_0 resp_0;
    (&resp_0)->force_lin_1 = force_lin_3;
    (&resp_0)->force_ang_1 = force_ang_2;
    (&resp_0)->state_6 = st_1;
    (&resp_0)->dissipated_2 = dissipated_3;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_5 = stored_7;
    if(_S683)
    {
        thread JointState_0 _S738 = st_1;
        bool _S739 = connected_0(&_S738, has_rebar_1);
        _S702 = !_S739;
    }
    else
    {
        _S702 = false;
    }
    (&resp_0)->disconnected_0 = _S702;
    (&resp_0)->measures_0 = _S684;
    return resp_0;
}

void secant_factors_0(const JointBond_natural_0 thread* b_28, const JointState_0 thread* st_2, float3 d_lin_3, float3 thread* f_lin_0, float3 thread* f_ang_0)
{
    float _S740 = st_2->damage_0;
    bool compressed_0 = (d_lin_3.z) < 0.0f;
    float contact_3;
    if(compressed_0)
    {
        contact_3 = _S740;
    }
    else
    {
        contact_3 = 0.0f;
    }
    float _S741 = 1.0f - _S740;
    float _S742 = max(_S741 + contact_3, 9.99999997475242708e-07f);
    float normal_5;
    if(compressed_0)
    {
        normal_5 = max(1.0f - st_2->crush_1, 9.99999997475242708e-07f);
    }
    else
    {
        normal_5 = max(_S741, 9.99999997475242708e-07f);
    }
    *f_lin_0 = float3(_S742, _S742, normal_5);
    *f_ang_0 = float3(_S742) ;
    bool _S743;
    if(((float4(b_28->stiff1_0) ).w) != 0.0f)
    {
        _S743 = (st_2->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S743 = false;
    }
    if(_S743)
    {
        float4 _S744 = float4(b_28->rebar0_0) ;
        float4 _S745 = float4(b_28->stiff0_0) ;
        float _S746 = (metal::fast::divide((_S744.x), (_S745.x)));
        (*f_lin_0).z = (*f_lin_0).z + _S746;
        float _S747 = _S744.y;
        float _S748 = _S745.y;
        float _S749 = (metal::fast::divide((_S747), (_S748)));
        (*f_lin_0).x = (*f_lin_0).x + _S749;
        float _S750 = (metal::fast::divide((_S747), (_S748)));
        (*f_lin_0).y = (*f_lin_0).y + _S750;
    }
    return;
}

bool is_damaged_0(const JointState_0 thread* st_3)
{
    bool _S751;
    if((st_3->damage_0) > 0.0f)
    {
        _S751 = true;
    }
    else
    {
        _S751 = (st_3->crush_1) > 0.0f;
    }
    return _S751;
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

float3 to_local_0(uint _S752, float3 _S753, KernelContext_0 thread* kernelContext_46)
{
    BondStatic_natural_0 device* _S754 = kernelContext_46->bonds_0+_S752;
    return float3(dot(_S753, (float4(_S754->t1_0) ).xyz), dot(_S753, (float4(_S754->t2_0) ).xyz), dot(_S753, (float4(_S754->normal_0) ).xyz));
}

float3 to_body_0(uint _S755, float3 _S756, KernelContext_0 thread* kernelContext_47)
{
    BondStatic_natural_0 device* _S757 = kernelContext_47->bonds_0+_S755;
    return (float4(_S757->t1_0) ).xyz * float3(_S756.x)  + (float4(_S757->t2_0) ).xyz * float3(_S756.y)  + (float4(_S757->normal_0) ).xyz * float3(_S756.z) ;
}

bool bond_update_0(uint i_10, float dt_13, bool fracture_2, uint abs_step_0, bool wide_0, KernelContext_0 thread* kernelContext_48)
{
    BondStatic_natural_0 device* _S758 = kernelContext_48->bonds_0+i_10;
    BondDyn_natural_0 device* _S759 = kernelContext_48->bond_dyn_0+i_10;
    float4 _S760 = float4((*_S759).force_lin_0) ;
    float4 _S761 = float4((*_S759).force_ang_0) ;
    float4 _S762 = float4((*_S759).sums_0) ;
    float4 _S763 = float4((*_S759).comps_0) ;
    uint4 _S764 = uint4((*_S759).events_0) ;
    thread BondDyn_0 bd_0;
    (&bd_0)->js_0 = (*_S759).js_0;
    (&bd_0)->force_lin_0 = _S760;
    (&bd_0)->force_ang_0 = _S761;
    (&bd_0)->sums_0 = _S762;
    (&bd_0)->comps_0 = _S763;
    (&bd_0)->events_0 = _S764;
    JointBond_natural_0 _S765 = _S758->law_0;
    thread JointBond_natural_0 _S766 = _S758->law_0;
    uint4 _S767 = uint4((&_S766)->ids_0) ;
    float3 ra_1 = (float4(_S758->ra_0) ).xyz;
    float3 rb_1 = (float4(_S758->rb_0) ).xyz;
    uint _S768 = 4U * _S767.y;
    float3 ta_2 = (float4(*(kernelContext_48->state_0+(_S768 + 1U))) ).xyz;
    float3 va_0 = (float4(*(kernelContext_48->state_0+(_S768 + 2U))) ).xyz;
    float3 wa_1 = (float4(*(kernelContext_48->state_0+(_S768 + 3U))) ).xyz;
    uint _S769 = 4U * _S767.z;
    float3 tb_2 = (float4(*(kernelContext_48->state_0+(_S769 + 1U))) ).xyz;
    float3 vb_0 = (float4(*(kernelContext_48->state_0+(_S769 + 2U))) ).xyz;
    float3 wb_1 = (float4(*(kernelContext_48->state_0+(_S769 + 3U))) ).xyz;
    float3 _S770 = to_local_0(i_10, (float4(*(kernelContext_48->state_0+_S769)) ).xyz + cross(tb_2, rb_1) - ((float4(*(kernelContext_48->state_0+_S768)) ).xyz + cross(ta_2, ra_1)), kernelContext_48);
    float3 _S771 = to_local_0(i_10, tb_2 - ta_2, kernelContext_48);
    float3 _S772 = to_local_0(i_10, vb_0 + cross(wb_1, rb_1) - (va_0 + cross(wa_1, ra_1)), kernelContext_48);
    float3 _S773 = to_local_0(i_10, wb_1 - wa_1, kernelContext_48);
    JointState_0 previous_0 = (&bd_0)->js_0;
    _S766 = _S765;
    thread JointState_0 _S774 = (&bd_0)->js_0;
    JointResponse_0 _S775 = joint_evaluate_0(&kernelContext_48->materials_0->m_0[_S767.x], &_S766, &_S774, _S770, _S771, dt_13, fracture_2);
    thread JointState_0 _S776 = _S775.state_6;
    thread float3 f_lin_1;
    thread float3 f_ang_1;
    secant_factors_0(&_S766, &_S776, _S770, &f_lin_1, &f_ang_1);
    float3 qd_lin_0 = _S772 * (float4(_S758->c_lin_0) ).xyz * f_lin_1;
    float3 qd_ang_0 = _S773 * (float4(_S758->c_ang_0) ).xyz * f_ang_1;
    float3 q_lin_2 = _S775.force_lin_1 + qd_lin_0;
    float3 q_ang_2 = _S775.force_ang_1 + qd_ang_0;
    float damped_0 = (dot(qd_lin_0, _S772) + dot(qd_ang_0, _S773)) * dt_13;
    float3 _S777 = to_body_0(i_10, q_lin_2, kernelContext_48);
    float3 _S778 = to_body_0(i_10, q_ang_2, kernelContext_48);
    uint _S779 = 3U * i_10;
    *(kernelContext_48->scratch_0+_S779) = packed_float4(float4(_S777, max(_S775.measures_0.tension_0, _S775.measures_0.compression_0))) ;
    *(kernelContext_48->scratch_0+(_S779 + 1U)) = packed_float4(float4(_S778 + cross(ra_1, _S777), 0.0f)) ;
    *(kernelContext_48->scratch_0+(_S779 + 2U)) = packed_float4(float4(- _S778 + cross(rb_1, - _S777), 0.0f)) ;
    thread float _S780 = (&bd_0)->sums_0.x;
    thread float _S781 = (&bd_0)->comps_0.x;
    comp_add1_0(&_S780, &_S781, _S775.dissipated_2);
    (&bd_0)->comps_0.x = _S781;
    (&bd_0)->sums_0.x = _S780;
    thread float _S782 = (&bd_0)->sums_0.y;
    thread float _S783 = (&bd_0)->comps_0.y;
    comp_add1_0(&_S782, &_S783, _S775.overshoot_0);
    (&bd_0)->comps_0.y = _S783;
    (&bd_0)->sums_0.y = _S782;
    thread float _S784 = (&bd_0)->sums_0.z;
    thread float _S785 = (&bd_0)->comps_0.z;
    comp_add1_0(&_S784, &_S785, damped_0);
    (&bd_0)->comps_0.z = _S785;
    (&bd_0)->sums_0.z = _S784;
    (&bd_0)->force_lin_0 = float4(q_lin_2, _S775.stored_5);
    (&bd_0)->force_ang_0 = float4(q_ang_2, max((&bd_0)->force_ang_0.w, _S775.state_6.utilization_0));
    thread JointState_0 _S786 = previous_0;
    bool _S787 = is_damaged_0(&_S786);
    bool _S788;
    if(!_S787)
    {
        thread JointState_0 _S789 = _S775.state_6;
        bool _S790 = is_damaged_0(&_S789);
        _S788 = _S790;
    }
    else
    {
        _S788 = false;
    }
    if(_S788)
    {
        _S788 = ((&bd_0)->events_0.x) == 0U;
    }
    else
    {
        _S788 = false;
    }
    if(_S788)
    {
        (&bd_0)->events_0.x = abs_step_0;
        (&bd_0)->events_0.w = _S775.state_6.mode_0;
        if(wide_0)
        {
            cov_or_0(_S767.w, 32U, kernelContext_48);
        }
        else
        {
            (*kernelContext_48->g_seen_0)[3U] = 1U;
        }
    }
    if(((&bd_0)->events_0.y) == 0U)
    {
        float _S791 = fatigue_factor_0(&kernelContext_48->materials_0->m_0[_S767.x], previous_0.life_0);
        _S788 = _S791 > 0.99000000953674316f;
    }
    else
    {
        _S788 = false;
    }
    if(_S788)
    {
        float _S792 = fatigue_factor_0(&kernelContext_48->materials_0->m_0[_S767.x], _S775.state_6.life_0);
        _S788 = _S792 <= 0.99000000953674316f;
    }
    else
    {
        _S788 = false;
    }
    if(_S788)
    {
        (&bd_0)->events_0.y = abs_step_0;
        if(wide_0)
        {
            cov_or_0(_S767.w, 64U, kernelContext_48);
        }
        else
        {
            (*kernelContext_48->g_seen_0)[4U] = 1U;
        }
    }
    if(_S775.disconnected_0)
    {
        (&bd_0)->events_0.z = abs_step_0;
    }
    (&bd_0)->js_0 = _S775.state_6;
    BondDyn_natural_0 device* _S793 = kernelContext_48->bond_dyn_0+i_10;
    _S793->js_0 = bd_0.js_0;
    _S793->force_lin_0 = packed_float4(bd_0.force_lin_0) ;
    _S793->force_ang_0 = packed_float4(bd_0.force_ang_0) ;
    _S793->sums_0 = packed_float4(bd_0.sums_0) ;
    _S793->comps_0 = packed_float4(bd_0.comps_0) ;
    _S793->events_0 = packed_uint4(bd_0.events_0) ;
    return _S775.disconnected_0;
}

void chunk_update_0(uint c_15, const Island_natural_0 thread* isl_11, const Rigid_0 thread* rg_9, float dt_14, bool rml_0, uint step_0, bool contact_4, float thread* work_1, float thread* work_err_0, KernelContext_0 thread* kernelContext_49)
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
    float3 th_1 = (float4(*(kernelContext_49->state_0+_S802)) ).xyz;
    uint _S803 = _S801 + 2U;
    float3 v_11 = (float4(*(kernelContext_49->state_0+_S803)) ).xyz;
    uint _S804 = _S801 + 3U;
    float3 w_5 = (float4(*(kernelContext_49->state_0+_S804)) ).xyz;
    float4 _S805 = float4(_S794->center_0) ;
    float mass_0 = _S805.w;
    float3 _S806 = _S805.xyz;
    float3 _S807 = (float4(isl_11->com_0) ).xyz;
    float3 _S808 = rotate_0(&rg_9->rot_0, _S806 + u_0 - _S807);
    thread float3 f_load_0;
    thread float3 t_load_0;
    chunk_external_0(c_15, c_15, &rg_9->rot_0, step_0, dt_14, contact_4, &f_load_0, &t_load_0, kernelContext_49);
    record_chunk_load_0(c_15, f_load_0, t_load_0, kernelContext_49);
    float3 _S809 = float3(mass_0) ;
    float3 f_world_0 = f_load_0 + kernelContext_49->params_0->gravity_0.xyz * _S809;
    float3 t_world_0 = t_load_0;
    float3 f_world_1;
    float3 t_world_1;
    if(rml_0)
    {
        float3 f_world_2 = f_world_0 - (rg_9->a_7 + cross(rg_9->alpha_0, _S808) + cross(rg_9->w_4, cross(rg_9->w_4, _S808))) * _S809;
        float4 _S810 = float4(_S794->inertia0_1) ;
        float4 _S811 = float4(_S794->inertia1_1) ;
        float4 _S812 = float4(_S794->inertia2_1) ;
        float3 _S813 = world_mul_0(&rg_9->rot_0, _S810, _S811, _S812, rg_9->alpha_0);
        float3 _S814 = world_mul_0(&rg_9->rot_0, _S810, _S811, _S812, rg_9->w_4);
        float3 t_world_2 = t_world_0 - (_S813 + cross(rg_9->w_4, _S814));
        f_world_1 = f_world_2;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    float3 _S815 = inverse_rotate_0(&rg_9->rot_0, f_world_1);
    float3 _S816 = inverse_rotate_0(&rg_9->rot_0, t_world_1);
    float3 f_ext_0;
    float3 m_ext_0;
    if(rml_0)
    {
        float3 _S817 = inverse_rotate_0(&rg_9->rot_0, rg_9->w_4);
        float4 _S818 = float4(_S794->inertia0_1) ;
        float4 _S819 = float4(_S794->inertia1_1) ;
        float4 _S820 = float4(_S794->inertia2_1) ;
        float3 i_w_0 = rows_mul_0(_S818, _S819, _S820, w_5);
        float3 m_ext_1 = _S816 - (cross(_S817, i_w_0) + cross(w_5, rows_mul_0(_S818, _S819, _S820, _S817)) + cross(w_5, i_w_0));
        f_ext_0 = _S815 - cross(_S817, v_11) * float3((2.0f * mass_0)) ;
        m_ext_0 = m_ext_1;
    }
    else
    {
        f_ext_0 = _S815;
        m_ext_0 = _S816;
    }
    uint4 _S821 = uint4(_S794->load_range_0) ;
    uint term_4 = _S821.x;
    for(;;)
    {
        if(term_4 < (_S821.y))
        {
        }
        else
        {
            break;
        }
        uint _S822 = 5U * term_4;
        if(((as_type<uint4>((float4(*(kernelContext_49->loads_0+_S822)) ))).y) != 2U)
        {
            term_4 = term_4 + 1U;
            continue;
        }
        float _S823 = eval_function_0(term_4, step_0, dt_14, dt_14, kernelContext_49);
        float3 _S824 = float3(_S823) ;
        float3 m_ext_2 = m_ext_0 + (float4(*(kernelContext_49->loads_0+(_S822 + 2U))) ).xyz * _S824;
        f_ext_0 = f_ext_0 + (float4(*(kernelContext_49->loads_0+(_S822 + 1U))) ).xyz * _S824;
        m_ext_0 = m_ext_2;
        term_4 = term_4 + 1U;
    }
    float3 f_13 = f_ext_0 + fi_0;
    float3 m_5 = m_ext_0 + mi_0;
    uint support_0 = (uint4(_S794->info_1) ).x;
    float3 _S825 = float3((float4(*(kernelContext_49->state_0+_S802)) ).w, (float4(*(kernelContext_49->state_0+_S803)) ).w, (float4(*(kernelContext_49->state_0+_S804)) ).w);
    float3 reaction_0;
    float3 u_1;
    float3 th_2;
    float3 v_12;
    float3 w_6;
    if(support_0 == 1U)
    {
        reaction_0 = - f_13;
        u_1 = u_0;
        th_2 = th_1;
        v_12 = _S795;
        w_6 = _S795;
    }
    else
    {
        float4 _S826 = float4(_S794->scale_0) ;
        float3 w_7 = w_5 + rows_mul_0(float4(_S794->inv0_1) , float4(_S794->inv1_1) , float4(_S794->inv2_1) , m_5) * float3((dt_14 * _S826.z)) ;
        float3 _S827 = float3(dt_14) ;
        float3 th_3 = th_1 + w_7 * _S827;
        if(support_0 == 2U)
        {
            reaction_0 = - f_13;
            u_1 = u_0;
            th_2 = _S795;
        }
        else
        {
            float3 v_13 = v_11 + f_13 * float3((dt_14 * _S826.y)) ;
            float3 u_2 = u_0 + v_13 * _S827;
            reaction_0 = _S825;
            u_1 = u_2;
            th_2 = v_13;
        }
        float3 _S828 = th_2;
        th_2 = th_3;
        v_12 = _S828;
        w_6 = w_7;
    }
    *(kernelContext_49->state_0+_S801) = packed_float4(float4(u_1, peak_0)) ;
    *(kernelContext_49->state_0+_S802) = packed_float4(float4(th_2, reaction_0.x)) ;
    *(kernelContext_49->state_0+_S803) = packed_float4(float4(v_12, reaction_0.y)) ;
    *(kernelContext_49->state_0+_S804) = packed_float4(float4(w_6, reaction_0.z)) ;
    float3 _S829 = rotate_0(&rg_9->rot_0, _S806 + u_1 - _S807);
    float3 _S830 = rg_9->vel_1 + rg_9->vel_err_1 + cross(rg_9->w_4, _S829);
    float3 _S831 = rotate_0(&rg_9->rot_0, v_12);
    float3 v_world_0 = _S830 + _S831;
    float3 _S832 = rotate_0(&rg_9->rot_0, w_6);
    comp_add1_0(work_1, work_err_0, (dot(f_load_0, v_world_0) + dot(t_load_0, rg_9->w_4 + _S832)) * dt_14);
    return;
}

void chunk_update_1(uint c_16, const Island_0 thread* isl_12, const Rigid_0 thread* rg_10, float dt_15, bool rml_1, uint step_1, bool contact_5, float thread* work_2, float thread* work_err_1, KernelContext_0 thread* kernelContext_50)
{
    ChunkStatic_natural_0 device* _S833 = kernelContext_50->chunks_0+c_16;
    float3 _S834 = float3(0.0f) ;
    uint _S835 = kernelContext_50->index_0[c_16];
    float peak_1 = 0.0f;
    uint e_4 = _S835;
    float3 fi_1 = _S834;
    float3 mi_3 = _S834;
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
        uint _S836 = 3U * (entry_3 >> 1U);
        float4 _S837 = float4(*(kernelContext_50->scratch_0+_S836)) ;
        if((entry_3 & 1U) == 0U)
        {
            float3 mi_4 = mi_3 + (float4(*(kernelContext_50->scratch_0+(_S836 + 1U))) ).xyz;
            fi_1 = fi_1 + _S837.xyz;
            mi_3 = mi_4;
        }
        else
        {
            float3 mi_5 = mi_3 + (float4(*(kernelContext_50->scratch_0+(_S836 + 2U))) ).xyz;
            fi_1 = fi_1 + - _S837.xyz;
            mi_3 = mi_5;
        }
        float _S838 = max(peak_1, _S837.w);
        uint _S839 = e_4 + 1U;
        peak_1 = _S838;
        e_4 = _S839;
    }
    uint _S840 = 4U * c_16;
    float3 u_3 = (float4(*(kernelContext_50->state_0+_S840)) ).xyz;
    uint _S841 = _S840 + 1U;
    float3 th_4 = (float4(*(kernelContext_50->state_0+_S841)) ).xyz;
    uint _S842 = _S840 + 2U;
    float3 v_14 = (float4(*(kernelContext_50->state_0+_S842)) ).xyz;
    uint _S843 = _S840 + 3U;
    float3 w_8 = (float4(*(kernelContext_50->state_0+_S843)) ).xyz;
    float4 _S844 = float4(_S833->center_0) ;
    float mass_1 = _S844.w;
    float3 _S845 = _S844.xyz;
    float3 _S846 = isl_12->com_0.xyz;
    float3 _S847 = rotate_0(&rg_10->rot_0, _S845 + u_3 - _S846);
    thread float3 f_load_1;
    thread float3 t_load_1;
    chunk_external_0(c_16, c_16, &rg_10->rot_0, step_1, dt_15, contact_5, &f_load_1, &t_load_1, kernelContext_50);
    record_chunk_load_0(c_16, f_load_1, t_load_1, kernelContext_50);
    float3 _S848 = float3(mass_1) ;
    float3 f_world_3 = f_load_1 + kernelContext_50->params_0->gravity_0.xyz * _S848;
    float3 t_world_3 = t_load_1;
    float3 f_world_4;
    float3 t_world_4;
    if(rml_1)
    {
        float3 f_world_5 = f_world_3 - (rg_10->a_7 + cross(rg_10->alpha_0, _S847) + cross(rg_10->w_4, cross(rg_10->w_4, _S847))) * _S848;
        float4 _S849 = float4(_S833->inertia0_1) ;
        float4 _S850 = float4(_S833->inertia1_1) ;
        float4 _S851 = float4(_S833->inertia2_1) ;
        float3 _S852 = world_mul_0(&rg_10->rot_0, _S849, _S850, _S851, rg_10->alpha_0);
        float3 _S853 = world_mul_0(&rg_10->rot_0, _S849, _S850, _S851, rg_10->w_4);
        float3 t_world_5 = t_world_3 - (_S852 + cross(rg_10->w_4, _S853));
        f_world_4 = f_world_5;
        t_world_4 = t_world_5;
    }
    else
    {
        f_world_4 = f_world_3;
        t_world_4 = t_world_3;
    }
    float3 _S854 = inverse_rotate_0(&rg_10->rot_0, f_world_4);
    float3 _S855 = inverse_rotate_0(&rg_10->rot_0, t_world_4);
    float3 f_ext_1;
    float3 m_ext_3;
    if(rml_1)
    {
        float3 _S856 = inverse_rotate_0(&rg_10->rot_0, rg_10->w_4);
        float4 _S857 = float4(_S833->inertia0_1) ;
        float4 _S858 = float4(_S833->inertia1_1) ;
        float4 _S859 = float4(_S833->inertia2_1) ;
        float3 i_w_1 = rows_mul_0(_S857, _S858, _S859, w_8);
        float3 m_ext_4 = _S855 - (cross(_S856, i_w_1) + cross(w_8, rows_mul_0(_S857, _S858, _S859, _S856)) + cross(w_8, i_w_1));
        f_ext_1 = _S854 - cross(_S856, v_14) * float3((2.0f * mass_1)) ;
        m_ext_3 = m_ext_4;
    }
    else
    {
        f_ext_1 = _S854;
        m_ext_3 = _S855;
    }
    uint4 _S860 = uint4(_S833->load_range_0) ;
    uint term_5 = _S860.x;
    for(;;)
    {
        if(term_5 < (_S860.y))
        {
        }
        else
        {
            break;
        }
        uint _S861 = 5U * term_5;
        if(((as_type<uint4>((float4(*(kernelContext_50->loads_0+_S861)) ))).y) != 2U)
        {
            term_5 = term_5 + 1U;
            continue;
        }
        float _S862 = eval_function_0(term_5, step_1, dt_15, dt_15, kernelContext_50);
        float3 _S863 = float3(_S862) ;
        float3 m_ext_5 = m_ext_3 + (float4(*(kernelContext_50->loads_0+(_S861 + 2U))) ).xyz * _S863;
        f_ext_1 = f_ext_1 + (float4(*(kernelContext_50->loads_0+(_S861 + 1U))) ).xyz * _S863;
        m_ext_3 = m_ext_5;
        term_5 = term_5 + 1U;
    }
    float3 f_14 = f_ext_1 + fi_1;
    float3 m_6 = m_ext_3 + mi_3;
    uint support_1 = (uint4(_S833->info_1) ).x;
    float3 _S864 = float3((float4(*(kernelContext_50->state_0+_S841)) ).w, (float4(*(kernelContext_50->state_0+_S842)) ).w, (float4(*(kernelContext_50->state_0+_S843)) ).w);
    float3 reaction_1;
    float3 u_4;
    float3 th_5;
    float3 v_15;
    float3 w_9;
    if(support_1 == 1U)
    {
        reaction_1 = - f_14;
        u_4 = u_3;
        th_5 = th_4;
        v_15 = _S834;
        w_9 = _S834;
    }
    else
    {
        float4 _S865 = float4(_S833->scale_0) ;
        float3 w_10 = w_8 + rows_mul_0(float4(_S833->inv0_1) , float4(_S833->inv1_1) , float4(_S833->inv2_1) , m_6) * float3((dt_15 * _S865.z)) ;
        float3 _S866 = float3(dt_15) ;
        float3 th_6 = th_4 + w_10 * _S866;
        if(support_1 == 2U)
        {
            reaction_1 = - f_14;
            u_4 = u_3;
            th_5 = _S834;
        }
        else
        {
            float3 v_16 = v_14 + f_14 * float3((dt_15 * _S865.y)) ;
            float3 u_5 = u_3 + v_16 * _S866;
            reaction_1 = _S864;
            u_4 = u_5;
            th_5 = v_16;
        }
        float3 _S867 = th_5;
        th_5 = th_6;
        v_15 = _S867;
        w_9 = w_10;
    }
    *(kernelContext_50->state_0+_S840) = packed_float4(float4(u_4, peak_1)) ;
    *(kernelContext_50->state_0+_S841) = packed_float4(float4(th_5, reaction_1.x)) ;
    *(kernelContext_50->state_0+_S842) = packed_float4(float4(v_15, reaction_1.y)) ;
    *(kernelContext_50->state_0+_S843) = packed_float4(float4(w_9, reaction_1.z)) ;
    float3 _S868 = rotate_0(&rg_10->rot_0, _S845 + u_4 - _S846);
    float3 _S869 = rg_10->vel_1 + rg_10->vel_err_1 + cross(rg_10->w_4, _S868);
    float3 _S870 = rotate_0(&rg_10->rot_0, v_15);
    float3 v_world_1 = _S869 + _S870;
    float3 _S871 = rotate_0(&rg_10->rot_0, w_9);
    comp_add1_0(work_2, work_err_1, (dot(f_load_1, v_world_1) + dot(t_load_1, rg_10->w_4 + _S871)) * dt_15);
    return;
}

void drift_moments_0(uint c_17, float3 thread* tu_0, float3 thread* pv_0, KernelContext_0 thread* kernelContext_51)
{
    ChunkStatic_natural_0 device* _S872 = kernelContext_51->chunks_0+c_17;
    uint _S873 = 4U * c_17;
    float3 _S874 = float3(((float4(_S872->center_0) ).w * (float4(_S872->scale_0) ).x)) ;
    *tu_0 = *tu_0 + (float4(*(kernelContext_51->state_0+_S873)) ).xyz * _S874;
    *pv_0 = *pv_0 + (float4(*(kernelContext_51->state_0+(_S873 + 2U))) ).xyz * _S874;
    return;
}

void drift_angular_0(uint c_18, float3 wcom_1, float3 tr_0, float3 dv_0, float3 thread* lu_0, float3 thread* lv_0, KernelContext_0 thread* kernelContext_52)
{
    ChunkStatic_natural_0 device* _S875 = kernelContext_52->chunks_0+c_18;
    float4 _S876 = float4(_S875->center_0) ;
    float3 r_10 = _S876.xyz - wcom_1;
    uint _S877 = 4U * c_18;
    float3 _S878 = float3(_S876.w) ;
    float4 _S879 = float4(_S875->inertia0_1) ;
    float4 _S880 = float4(_S875->inertia1_1) ;
    float4 _S881 = float4(_S875->inertia2_1) ;
    float3 _S882 = float3((float4(_S875->scale_0) ).x) ;
    *lu_0 = *lu_0 + (cross(r_10, (float4(*(kernelContext_52->state_0+_S877)) ).xyz - tr_0) * _S878 + rows_mul_0(_S879, _S880, _S881, (float4(*(kernelContext_52->state_0+(_S877 + 1U))) ).xyz)) * _S882;
    *lv_0 = *lv_0 + (cross(r_10, (float4(*(kernelContext_52->state_0+(_S877 + 2U))) ).xyz - dv_0) * _S878 + rows_mul_0(_S879, _S880, _S881, (float4(*(kernelContext_52->state_0+(_S877 + 3U))) ).xyz)) * _S882;
    return;
}

void drift_apply_0(uint c_19, float3 wcom_2, float3 tr_1, float3 phi_0, float3 dv_1, float3 dw_0, KernelContext_0 thread* kernelContext_53)
{
    float3 r_11 = (float4((kernelContext_53->chunks_0+c_19)->center_0) ).xyz - wcom_2;
    uint _S883 = 4U * c_19;
    *(kernelContext_53->state_0+_S883) = packed_float4(float4((float4(*(kernelContext_53->state_0+_S883)) ).xyz - (tr_1 + cross(phi_0, r_11)), (float4(*(kernelContext_53->state_0+_S883)) ).w)) ;
    uint _S884 = _S883 + 1U;
    *(kernelContext_53->state_0+_S884) = packed_float4(float4((float4(*(kernelContext_53->state_0+_S884)) ).xyz - phi_0, (float4(*(kernelContext_53->state_0+_S884)) ).w)) ;
    uint _S885 = _S883 + 2U;
    *(kernelContext_53->state_0+_S885) = packed_float4(float4((float4(*(kernelContext_53->state_0+_S885)) ).xyz - (dv_1 + cross(dw_0, r_11)), (float4(*(kernelContext_53->state_0+_S885)) ).w)) ;
    uint _S886 = _S883 + 3U;
    *(kernelContext_53->state_0+_S886) = packed_float4(float4((float4(*(kernelContext_53->state_0+_S886)) ).xyz - dw_0, (float4(*(kernelContext_53->state_0+_S886)) ).w)) ;
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
    thread Quat_0 _S887 = *hi_3;
    thread Quat_0 _S888 = dq_1;
    Quat_0 _S889 = quat_mul_0(&_S887, &_S888);
    thread Quat_0 _S890 = _S889;
    float4 _S891 = quat_vec_0(&_S890);
    quat_accumulate_0(hi_3, lo_3, _S891);
    return;
}

void drift_rigid_0(const Island_natural_0 thread* isl_13, Rigid_0 thread* rg_11, float3 tr_2, float3 phi_2, float3 dv_2, float3 dw_1)
{
    float3 wcom_3 = (float4(isl_13->wcom_0) ).xyz;
    Quat_0 rot_2 = rg_11->rot_0;
    float3 _S892 = tr_2 - cross(phi_2, wcom_3);
    thread Quat_0 _S893 = rg_11->rot_0;
    float3 _S894 = rotate_0(&_S893, _S892);
    comp_add_0(&rg_11->pos_1, &rg_11->pos_err_1, _S894);
    thread Quat_0 _S895 = rg_11->rot_0;
    float3 _S896 = inverse_rotate_0(&_S895, rg_11->w_4);
    float4 _S897 = float4(isl_13->inertia0_0) ;
    float4 _S898 = float4(isl_13->inertia1_0) ;
    float4 _S899 = float4(isl_13->inertia2_0) ;
    float3 _S900 = cross(phi_2, rows_mul_0(_S897, _S898, _S899, _S896)) - rows_mul_0(_S897, _S898, _S899, cross(phi_2, _S896));
    thread Quat_0 _S901 = rg_11->rot_0;
    float3 _S902 = rotate_0(&_S901, _S900);
    turn_right_0(&rg_11->rot_0, &rg_11->rot_err_0, phi_2);
    float3 _S903 = dv_2 + cross(dw_1, (float4(isl_13->com_0) ).xyz - wcom_3);
    thread Quat_0 _S904 = rot_2;
    float3 _S905 = rotate_0(&_S904, _S903);
    comp_add_0(&rg_11->vel_1, &rg_11->vel_err_1, _S905);
    thread Quat_0 _S906 = rot_2;
    float3 _S907 = rotate_0(&_S906, dw_1);
    rg_11->w_4 = rg_11->w_4 + _S907;
    thread Quat_0 _S908 = rg_11->rot_0;
    float3 _S909 = world_mul_0(&_S908, _S897, _S898, _S899, _S907);
    comp_add_0(&rg_11->l_2, &rg_11->l_err_1, _S902 + _S909);
    return;
}

void drift_rigid_1(const Island_0 thread* isl_14, Rigid_0 thread* rg_12, float3 tr_3, float3 phi_3, float3 dv_3, float3 dw_2)
{
    float3 wcom_4 = isl_14->wcom_0.xyz;
    Quat_0 rot_3 = rg_12->rot_0;
    float3 _S910 = tr_3 - cross(phi_3, wcom_4);
    thread Quat_0 _S911 = rg_12->rot_0;
    float3 _S912 = rotate_0(&_S911, _S910);
    comp_add_0(&rg_12->pos_1, &rg_12->pos_err_1, _S912);
    thread Quat_0 _S913 = rg_12->rot_0;
    float3 _S914 = inverse_rotate_0(&_S913, rg_12->w_4);
    float4 _S915 = isl_14->inertia0_0;
    float4 _S916 = isl_14->inertia1_0;
    float4 _S917 = isl_14->inertia2_0;
    float3 _S918 = cross(phi_3, rows_mul_0(isl_14->inertia0_0, isl_14->inertia1_0, isl_14->inertia2_0, _S914)) - rows_mul_0(isl_14->inertia0_0, isl_14->inertia1_0, isl_14->inertia2_0, cross(phi_3, _S914));
    thread Quat_0 _S919 = rg_12->rot_0;
    float3 _S920 = rotate_0(&_S919, _S918);
    turn_right_0(&rg_12->rot_0, &rg_12->rot_err_0, phi_3);
    float3 _S921 = dv_3 + cross(dw_2, isl_14->com_0.xyz - wcom_4);
    thread Quat_0 _S922 = rot_3;
    float3 _S923 = rotate_0(&_S922, _S921);
    comp_add_0(&rg_12->vel_1, &rg_12->vel_err_1, _S923);
    thread Quat_0 _S924 = rot_3;
    float3 _S925 = rotate_0(&_S924, dw_2);
    rg_12->w_4 = rg_12->w_4 + _S925;
    thread Quat_0 _S926 = rg_12->rot_0;
    float3 _S927 = world_mul_0(&_S926, _S915, _S916, _S917, _S925);
    comp_add_0(&rg_12->l_2, &rg_12->l_err_1, _S920 + _S927);
    return;
}

void contact_split_at_0(uint at_6, KernelContext_0 thread* kernelContext_54)
{
    uint previous_1 = (uint4((kernelContext_54->islands_0+kernelContext_54->params_0->halt_index_0)->info_0) ).y;
    uint _S928;
    if(previous_1 == 0U)
    {
        _S928 = at_6;
    }
    else
    {
        _S928 = min(previous_1, at_6);
    }
    (kernelContext_54->islands_0+kernelContext_54->params_0->halt_index_0)->info_0[int(1)] = _S928;
    return;
}

uint seen_bits_0(KernelContext_0 thread* kernelContext_55)
{
    uint _S929;
    if(((*kernelContext_55->g_seen_0)[0U]) != 0U)
    {
        _S929 = 32768U;
    }
    else
    {
        _S929 = 0U;
    }
    uint _S930;
    if(((*kernelContext_55->g_seen_0)[1U]) != 0U)
    {
        _S930 = 65536U;
    }
    else
    {
        _S930 = 0U;
    }
    uint _S931 = _S929 | _S930;
    if(((*kernelContext_55->g_seen_0)[2U]) != 0U)
    {
        _S929 = 131072U;
    }
    else
    {
        _S929 = 0U;
    }
    uint _S932 = _S931 | _S929;
    if(((*kernelContext_55->g_seen_0)[3U]) != 0U)
    {
        _S929 = 32U;
    }
    else
    {
        _S929 = 0U;
    }
    uint _S933 = _S932 | _S929;
    if(((*kernelContext_55->g_seen_0)[4U]) != 0U)
    {
        _S929 = 64U;
    }
    else
    {
        _S929 = 0U;
    }
    return _S933 | _S929;
}

[[kernel]] void island_frame(uint3 group_2 [[threadgroup_position_in_grid]], uint3 thread_2 [[thread_position_in_threadgroup]], Params_0 constant* params_6 [[buffer(0)]], Island_natural_0 device* islands_6 [[buffer(9)]], uint device* index_6 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_6 [[buffer(3)]], packed_float4 device* state_8 [[buffer(6)]], packed_float4 device* scratch_6 [[buffer(8)]], packed_float4 device* contact_state_6 [[buffer(11)]], packed_float4 device* loads_6 [[buffer(5)]], Impactor_natural_0 device* impactors_6 [[buffer(10)]], BondStatic_natural_0 device* bonds_6 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_6 [[buffer(7)]], MaterialTable_0 constant* materials_6 [[buffer(1)]])
{
    bool woke_0;
    thread KernelContext_0 kernelContext_56;
    (&kernelContext_56)->params_0 = params_6;
    (&kernelContext_56)->islands_0 = islands_6;
    (&kernelContext_56)->index_0 = index_6;
    (&kernelContext_56)->chunks_0 = chunks_6;
    (&kernelContext_56)->state_0 = state_8;
    (&kernelContext_56)->scratch_0 = scratch_6;
    (&kernelContext_56)->contact_state_0 = contact_state_6;
    (&kernelContext_56)->loads_0 = loads_6;
    (&kernelContext_56)->impactors_0 = impactors_6;
    (&kernelContext_56)->bonds_0 = bonds_6;
    (&kernelContext_56)->bond_dyn_0 = bond_dyn_6;
    (&kernelContext_56)->materials_0 = materials_6;
    threadgroup array<float4, int(32)> g_part_a_6;
    (&kernelContext_56)->g_part_a_0 = &g_part_a_6;
    threadgroup array<float4, int(32)> g_part_b_6;
    (&kernelContext_56)->g_part_b_0 = &g_part_b_6;
    threadgroup array<uint, int(5)> g_seen_6;
    (&kernelContext_56)->g_seen_0 = &g_seen_6;
    threadgroup uint g_run_6;
    (&kernelContext_56)->g_run_0 = &g_run_6;
    threadgroup uint g_halt_6;
    (&kernelContext_56)->g_halt_0 = &g_halt_6;
    threadgroup uint g_wide_run_6;
    (&kernelContext_56)->g_wide_run_0 = &g_wide_run_6;
    uint tid_5 = thread_2.x;
    uint _S934 = group_2.x;
    Island_natural_0 device* _S935 = islands_6+_S934;
    uint4 _S936 = uint4((*_S935).info_0) ;
    float4 _S937 = float4((*_S935).com_0) ;
    float4 _S938 = float4((*_S935).inertia0_0) ;
    float4 _S939 = float4((*_S935).inertia1_0) ;
    float4 _S940 = float4((*_S935).inertia2_0) ;
    float4 _S941 = float4((*_S935).inv0_0) ;
    float4 _S942 = float4((*_S935).inv1_0) ;
    float4 _S943 = float4((*_S935).inv2_0) ;
    float4 _S944 = float4((*_S935).wcom_0) ;
    float4 _S945 = float4((*_S935).winv0_0) ;
    float4 _S946 = float4((*_S935).winv1_0) ;
    float4 _S947 = float4((*_S935).winv2_0) ;
    float4 _S948 = float4((*_S935).rotation_0) ;
    float4 _S949 = float4((*_S935).position_0) ;
    float4 _S950 = float4((*_S935).position_err_0) ;
    float4 _S951 = float4((*_S935).velocity_0) ;
    float4 _S952 = float4((*_S935).velocity_err_0) ;
    float4 _S953 = float4((*_S935).angular_velocity_0) ;
    uint4 _S954 = uint4((*_S935).probes_0) ;
    float4 _S955 = float4((*_S935).energy_0) ;
    float4 _S956 = float4((*_S935).rotation_err_0) ;
    float4 _S957 = float4((*_S935).momentum_0) ;
    float4 _S958 = float4((*_S935).momentum_err_0) ;
    thread Island_0 isl_15;
    (&isl_15)->range_0 = uint4((*_S935).range_0) ;
    (&isl_15)->info_0 = _S936;
    (&isl_15)->com_0 = _S937;
    (&isl_15)->inertia0_0 = _S938;
    (&isl_15)->inertia1_0 = _S939;
    (&isl_15)->inertia2_0 = _S940;
    (&isl_15)->inv0_0 = _S941;
    (&isl_15)->inv1_0 = _S942;
    (&isl_15)->inv2_0 = _S943;
    (&isl_15)->wcom_0 = _S944;
    (&isl_15)->winv0_0 = _S945;
    (&isl_15)->winv1_0 = _S946;
    (&isl_15)->winv2_0 = _S947;
    (&isl_15)->rotation_0 = _S948;
    (&isl_15)->position_0 = _S949;
    (&isl_15)->position_err_0 = _S950;
    (&isl_15)->velocity_0 = _S951;
    (&isl_15)->velocity_err_0 = _S952;
    (&isl_15)->angular_velocity_0 = _S953;
    (&isl_15)->done_0 = (*_S935).done_0;
    (&isl_15)->coverage_0 = (*_S935).coverage_0;
    (&isl_15)->wide_groups_0 = (*_S935).wide_groups_0;
    (&isl_15)->done_pad_0 = (*_S935).done_pad_0;
    (&isl_15)->probes_0 = _S954;
    (&isl_15)->energy_0 = _S955;
    (&isl_15)->rotation_err_0 = _S956;
    (&isl_15)->momentum_0 = _S957;
    (&isl_15)->momentum_err_0 = _S958;
    bool driven_0 = (((&isl_15)->info_0.x) & 2U) != 0U;
    bool _S959 = !((((&isl_15)->info_0.x) & 1U) != 0U);
    bool _S960;
    if(_S959)
    {
        _S960 = !driven_0;
    }
    else
    {
        _S960 = false;
    }
    bool contact_island_0 = (((&isl_15)->info_0.x) & 4U) != 0U;
    bool _S961 = (((&isl_15)->info_0.x) & 16U) != 0U;
    seen_clear_0(tid_5, &kernelContext_56);
    bool _S962 = tid_5 == 0U;
    bool settled_0;
    uint cov_0;
    if(_S962)
    {
        if(contact_island_0 != (((&kernelContext_56)->params_0->contact_mode_0) == 1U))
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
            thread Island_0 _S963 = isl_15;
            bool _S964 = contact_stopped_1(&_S963, &kernelContext_56);
            settled_0 = _S964;
        }
        else
        {
            settled_0 = false;
        }
        if(settled_0)
        {
            cov_0 = 0U;
        }
        *(&kernelContext_56)->g_run_0 = cov_0;
        *(&kernelContext_56)->g_halt_0 = 0U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    if((((&isl_15)->info_0.z) & 1U) != 0U)
    {
        settled_0 = true;
    }
    else
    {
        settled_0 = (*(&kernelContext_56)->g_run_0) == 0U;
    }
    if(settled_0)
    {
        cov_0 = 0U;
    }
    else
    {
        cov_0 = min((&isl_15)->info_0.y, (&kernelContext_56)->params_0->max_steps_0);
    }
    float _S965 = (&kernelContext_56)->params_0->dt_0;
    bool _S966 = ((&kernelContext_56)->params_0->fracture_0) != 0U;
    bool _S967 = ((&kernelContext_56)->params_0->rigid_motion_loads_0) != 0U;
    thread Island_0 _S968 = isl_15;
    Rigid_0 _S969 = rigid_of_1(&_S968);
    thread Rigid_0 rg_13 = _S969;
    thread float work_3 = 0.0f;
    thread float work_err_2 = 0.0f;
    settled_0 = _S961;
    uint done_1 = 0U;
    bool woke_1 = false;
    uint s_7 = 0U;
    for(;;)
    {
        if(s_7 < cov_0)
        {
        }
        else
        {
            woke_0 = woke_1;
            break;
        }
        uint abs_step_1 = (&isl_15)->info_0.w + s_7 + 1U;
        uint k_20 = abs_step_1 - 1U - (&kernelContext_56)->params_0->step_start_0;
        bool _S970;
        bool settled_1;
        if((((&isl_15)->info_0.x) & 32U) != 0U)
        {
            if(_S962)
            {
                _S970 = ((&isl_15)->probes_0.y) > ((&isl_15)->probes_0.x);
            }
            else
            {
                _S970 = false;
            }
            if(_S970)
            {
                thread Island_0 _S971 = isl_15;
                thread Rigid_0 _S972 = rg_13;
                record_probes_0(&_S971, &_S972, k_20, &kernelContext_56);
            }
            uint _S973 = s_7 + 1U;
            settled_1 = settled_0;
            done_1 = _S973;
            woke_0 = woke_1;
            uint _S974 = s_7 + 1U;
            settled_0 = settled_1;
            woke_1 = woke_0;
            s_7 = _S974;
            continue;
        }
        uint i_11;
        if(settled_0)
        {
            float3 _S975 = float3(0.0f) ;
            thread float3 norm_0 = _S975;
            thread float3 unused0_0 = _S975;
            i_11 = (&isl_15)->range_0.x + tid_5;
            for(;;)
            {
                if(i_11 < ((&isl_15)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                thread Quat_0 _S976 = (&rg_13)->rot_0;
                float _S977 = settled_chunk_load_0(i_11, &_S976, k_20, _S965, contact_island_0, &kernelContext_56);
                norm_0.x = norm_0.x + _S977;
                i_11 = i_11 + 256U;
            }
            group_sum3_0(tid_5, &norm_0, &unused0_0, &kernelContext_56);
            if(((&kernelContext_56)->params_0->solve_mode_0) == 1U)
            {
                _S970 = (abs(norm_0.x - (&isl_15)->energy_0.z)) > ((&isl_15)->energy_0.w);
            }
            else
            {
                _S970 = false;
            }
            if(_S970)
            {
                settled_1 = false;
                woke_0 = true;
            }
            else
            {
                settled_1 = settled_0;
                woke_0 = woke_1;
            }
        }
        else
        {
            settled_1 = settled_0;
            woke_0 = woke_1;
        }
        if(_S959)
        {
            float3 _S978 = float3(0.0f) ;
            thread float3 f_15 = _S978;
            thread float3 t_15 = _S978;
            i_11 = (&isl_15)->range_0.x + tid_5;
            for(;;)
            {
                if(i_11 < ((&isl_15)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                thread Island_0 _S979 = isl_15;
                thread Rigid_0 _S980 = rg_13;
                net_load_1(i_11, &_S979, &_S980, k_20, _S965, contact_island_0, &f_15, &t_15, &kernelContext_56);
                i_11 = i_11 + 256U;
            }
            group_sum3_0(tid_5, &f_15, &t_15, &kernelContext_56);
            thread Island_0 _S981 = isl_15;
            rigid_acceleration_1(&_S981, &rg_13, f_15, t_15);
        }
        if(settled_1)
        {
            if(_S960)
            {
                thread Island_0 _S982 = isl_15;
                integrate_rigid_1(&_S982, &rg_13, _S965);
            }
            if(_S962)
            {
                _S970 = ((&isl_15)->probes_0.y) > ((&isl_15)->probes_0.x);
            }
            else
            {
                _S970 = false;
            }
            if(_S970)
            {
                thread Island_0 _S983 = isl_15;
                thread Rigid_0 _S984 = rg_13;
                record_probes_0(&_S983, &_S984, k_20, &kernelContext_56);
            }
            done_1 = s_7 + 1U;
            uint _S974 = s_7 + 1U;
            settled_0 = settled_1;
            woke_1 = woke_0;
            s_7 = _S974;
            continue;
        }
        i_11 = (&isl_15)->range_0.z + tid_5;
        for(;;)
        {
            if(i_11 < ((&isl_15)->range_0.w))
            {
            }
            else
            {
                break;
            }
            bool _S985 = bond_update_0(i_11, _S965, _S966, abs_step_1, false, &kernelContext_56);
            if(_S985)
            {
                *(&kernelContext_56)->g_halt_0 = 1U;
            }
            i_11 = i_11 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_20 = (&isl_15)->range_0.x + tid_5;
        for(;;)
        {
            if(c_20 < ((&isl_15)->range_0.y))
            {
            }
            else
            {
                break;
            }
            thread Island_0 _S986 = isl_15;
            thread Rigid_0 _S987 = rg_13;
            chunk_update_1(c_20, &_S986, &_S987, _S965, _S967, k_20, contact_island_0, &work_3, &work_err_2, &kernelContext_56);
            c_20 = c_20 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        if(_S960)
        {
            thread Island_0 _S988 = isl_15;
            integrate_rigid_1(&_S988, &rg_13, _S965);
        }
        if(_S959)
        {
            float3 _S989 = (&isl_15)->wcom_0.xyz;
            float3 _S990 = float3(0.0f) ;
            thread float3 tu_1 = _S990;
            thread float3 pv_1 = _S990;
            uint c_21 = (&isl_15)->range_0.x + tid_5;
            for(;;)
            {
                if(c_21 < ((&isl_15)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_moments_0(c_21, &tu_1, &pv_1, &kernelContext_56);
                c_21 = c_21 + 256U;
            }
            group_sum3_0(tid_5, &tu_1, &pv_1, &kernelContext_56);
            float3 tr_4 = tu_1 / float3((&isl_15)->wcom_0.w) ;
            float3 dv_4 = pv_1 / float3((&isl_15)->wcom_0.w) ;
            thread float3 lu_1 = _S990;
            thread float3 lv_1 = _S990;
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
                drift_angular_0(c_22, _S989, tr_4, dv_4, &lu_1, &lv_1, &kernelContext_56);
                c_22 = c_22 + 256U;
            }
            group_sum3_0(tid_5, &lu_1, &lv_1, &kernelContext_56);
            float3 phi_4 = rows_mul_0((&isl_15)->winv0_0, (&isl_15)->winv1_0, (&isl_15)->winv2_0, lu_1);
            float3 dw_3 = rows_mul_0((&isl_15)->winv0_0, (&isl_15)->winv1_0, (&isl_15)->winv2_0, lv_1);
            uint c_23 = (&isl_15)->range_0.x + tid_5;
            for(;;)
            {
                if(c_23 < ((&isl_15)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_apply_0(c_23, _S989, tr_4, phi_4, dv_4, dw_3, &kernelContext_56);
                c_23 = c_23 + 256U;
            }
            if(!driven_0)
            {
                thread Island_0 _S991 = isl_15;
                drift_rigid_1(&_S991, &rg_13, tr_4, phi_4, dv_4, dw_3);
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        }
        if(_S962)
        {
            _S970 = ((&isl_15)->probes_0.y) > ((&isl_15)->probes_0.x);
        }
        else
        {
            _S970 = false;
        }
        if(_S970)
        {
            thread Island_0 _S992 = isl_15;
            thread Rigid_0 _S993 = rg_13;
            record_probes_0(&_S992, &_S993, k_20, &kernelContext_56);
        }
        uint _S994 = s_7 + 1U;
        if((*(&kernelContext_56)->g_halt_0) != 0U)
        {
            done_1 = _S994;
            break;
        }
        done_1 = _S994;
        uint _S974 = s_7 + 1U;
        settled_0 = settled_1;
        woke_1 = woke_0;
        s_7 = _S974;
    }
    thread float3 wsum_0 = float3(work_3, work_err_2, 0.0f);
    thread float3 unused_1 = float3(0.0f) ;
    group_sum3_0(tid_5, &wsum_0, &unused_1, &kernelContext_56);
    if(_S962)
    {
        thread Quat_0 _S995 = (&rg_13)->rot_0;
        float4 _S996 = quat_vec_0(&_S995);
        (&isl_15)->rotation_0 = _S996;
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
        if((*(&kernelContext_56)->g_halt_0) != 0U)
        {
            _S960 = contact_island_0;
        }
        else
        {
            _S960 = false;
        }
        if(_S960)
        {
            contact_split_at_0((&isl_15)->info_0.w + done_1, &kernelContext_56);
        }
        float _S997 = wsum_0.x;
        thread float _S998 = (&isl_15)->energy_0.x;
        thread float _S999 = (&isl_15)->energy_0.y;
        comp_add1_0(&_S998, &_S999, _S997);
        (&isl_15)->energy_0.x = _S998;
        (&isl_15)->energy_0.y = _S999 + wsum_0.y;
        (&isl_15)->info_0.w = (&isl_15)->info_0.w + done_1;
        if((*(&kernelContext_56)->g_halt_0) != 0U)
        {
            (&isl_15)->info_0.z = ((&isl_15)->info_0.z) | 1U;
        }
        uint _S1000 = seen_bits_0(&kernelContext_56);
        if((*(&kernelContext_56)->g_halt_0) != 0U)
        {
            cov_0 = 128U;
        }
        else
        {
            cov_0 = 0U;
        }
        uint _S1001 = _S1000 | cov_0;
        if(woke_0)
        {
            cov_0 = 2048U;
        }
        else
        {
            cov_0 = 0U;
        }
        uint cov_1 = _S1001 | cov_0;
        if(done_1 > 0U)
        {
            bool quiet_0 = (((&isl_15)->info_0.x) & 32U) != 0U;
            if(quiet_0)
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
                _S960 = !quiet_0;
            }
            else
            {
                _S960 = false;
            }
            if(_S960)
            {
                cov_0 = 512U;
            }
            else
            {
                cov_0 = 0U;
            }
            uint cov_3 = cov_2 | cov_0;
            if(((&kernelContext_56)->params_0->contact_mode_0) == 1U)
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
        Island_natural_0 device* _S1002 = (&kernelContext_56)->islands_0+_S934;
        _S1002->range_0 = packed_uint4(isl_15.range_0) ;
        _S1002->info_0 = packed_uint4(isl_15.info_0) ;
        _S1002->com_0 = packed_float4(isl_15.com_0) ;
        _S1002->inertia0_0 = packed_float4(isl_15.inertia0_0) ;
        _S1002->inertia1_0 = packed_float4(isl_15.inertia1_0) ;
        _S1002->inertia2_0 = packed_float4(isl_15.inertia2_0) ;
        _S1002->inv0_0 = packed_float4(isl_15.inv0_0) ;
        _S1002->inv1_0 = packed_float4(isl_15.inv1_0) ;
        _S1002->inv2_0 = packed_float4(isl_15.inv2_0) ;
        _S1002->wcom_0 = packed_float4(isl_15.wcom_0) ;
        _S1002->winv0_0 = packed_float4(isl_15.winv0_0) ;
        _S1002->winv1_0 = packed_float4(isl_15.winv1_0) ;
        _S1002->winv2_0 = packed_float4(isl_15.winv2_0) ;
        _S1002->rotation_0 = packed_float4(isl_15.rotation_0) ;
        _S1002->position_0 = packed_float4(isl_15.position_0) ;
        _S1002->position_err_0 = packed_float4(isl_15.position_err_0) ;
        _S1002->velocity_0 = packed_float4(isl_15.velocity_0) ;
        _S1002->velocity_err_0 = packed_float4(isl_15.velocity_err_0) ;
        _S1002->angular_velocity_0 = packed_float4(isl_15.angular_velocity_0) ;
        _S1002->done_0 = isl_15.done_0;
        _S1002->coverage_0 = isl_15.coverage_0;
        _S1002->wide_groups_0 = isl_15.wide_groups_0;
        _S1002->done_pad_0 = isl_15.done_pad_0;
        _S1002->probes_0 = packed_uint4(isl_15.probes_0) ;
        _S1002->energy_0 = packed_float4(isl_15.energy_0) ;
        _S1002->rotation_err_0 = packed_float4(isl_15.rotation_err_0) ;
        _S1002->momentum_0 = packed_float4(isl_15.momentum_0) ;
        _S1002->momentum_err_0 = packed_float4(isl_15.momentum_err_0) ;
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

WideGroup_0 wide_group_0(uint table_0, uint g_2, KernelContext_0 thread* kernelContext_57)
{
    thread WideGroup_0 w_11;
    uint _S1003 = table_0 + 4U * g_2;
    (&w_11)->island_3 = kernelContext_57->index_0[_S1003];
    (&w_11)->begin_1 = kernelContext_57->index_0[_S1003 + 1U];
    (&w_11)->end_0 = kernelContext_57->index_0[_S1003 + 2U];
    (&w_11)->first_0 = kernelContext_57->index_0[_S1003 + 3U];
    return w_11;
}

bool wide_runs_0(const Island_natural_0 thread* isl_16, KernelContext_0 thread* kernelContext_58)
{
    uint4 _S1004 = uint4(isl_16->info_0) ;
    bool _S1005;
    if(((_S1004.z) & 1U) != 0U)
    {
        _S1005 = true;
    }
    else
    {
        _S1005 = (_S1004.y) == 0U;
    }
    if(_S1005)
    {
        return false;
    }
    if(((_S1004.x) & 4U) == 0U)
    {
        _S1005 = true;
    }
    else
    {
        bool _S1006 = contact_stopped_0(isl_16, kernelContext_58);
        _S1005 = !_S1006;
    }
    return _S1005;
}

bool wide_enter_0(uint tid_6, const Island_natural_0 thread* isl_17, KernelContext_0 thread* kernelContext_59)
{
    seen_clear_0(tid_6, kernelContext_59);
    if(tid_6 == 0U)
    {
        bool _S1007 = wide_runs_0(isl_17, kernelContext_59);
        int _S1008;
        if(_S1007)
        {
            _S1008 = int(1);
        }
        else
        {
            _S1008 = int(0);
        }
        *kernelContext_59->g_wide_run_0 = uint(_S1008);
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    return (*kernelContext_59->g_wide_run_0) != 0U;
}

uint wide_step_0(const Island_natural_0 thread* isl_18, KernelContext_0 thread* kernelContext_60)
{
    return (uint4(isl_18->info_0) ).w - kernelContext_60->params_0->step_start_0;
}

uint wide_step_1(const Island_0 thread* isl_19, KernelContext_0 thread* kernelContext_61)
{
    return isl_19->info_0.w - kernelContext_61->params_0->step_start_0;
}

bool wide_enter_1(uint _S1009, uint _S1010, KernelContext_0 thread* kernelContext_62)
{
    thread Island_natural_0 _S1011 = *(kernelContext_62->islands_0+_S1010);
    seen_clear_0(_S1009, kernelContext_62);
    if(_S1009 == 0U)
    {
        bool _S1012 = wide_runs_0(&_S1011, kernelContext_62);
        int _S1013;
        if(_S1012)
        {
            _S1013 = int(1);
        }
        else
        {
            _S1013 = int(0);
        }
        *kernelContext_62->g_wide_run_0 = uint(_S1013);
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    return (*kernelContext_62->g_wide_run_0) != 0U;
}

[[kernel]] void wide_wake(uint3 group_3 [[threadgroup_position_in_grid]], uint3 thread_3 [[thread_position_in_threadgroup]], Params_0 constant* params_7 [[buffer(0)]], Island_natural_0 device* islands_7 [[buffer(9)]], uint device* index_7 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_7 [[buffer(3)]], packed_float4 device* state_9 [[buffer(6)]], packed_float4 device* scratch_7 [[buffer(8)]], packed_float4 device* contact_state_7 [[buffer(11)]], packed_float4 device* loads_7 [[buffer(5)]], Impactor_natural_0 device* impactors_7 [[buffer(10)]], BondStatic_natural_0 device* bonds_7 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_7 [[buffer(7)]], MaterialTable_0 constant* materials_7 [[buffer(1)]])
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
    (&kernelContext_63)->bond_dyn_0 = bond_dyn_7;
    (&kernelContext_63)->materials_0 = materials_7;
    threadgroup array<float4, int(32)> g_part_a_7;
    (&kernelContext_63)->g_part_a_0 = &g_part_a_7;
    threadgroup array<float4, int(32)> g_part_b_7;
    (&kernelContext_63)->g_part_b_0 = &g_part_b_7;
    threadgroup array<uint, int(5)> g_seen_7;
    (&kernelContext_63)->g_seen_0 = &g_seen_7;
    threadgroup uint g_run_7;
    (&kernelContext_63)->g_run_0 = &g_run_7;
    threadgroup uint g_halt_7;
    (&kernelContext_63)->g_halt_0 = &g_halt_7;
    threadgroup uint g_wide_run_7;
    (&kernelContext_63)->g_wide_run_0 = &g_wide_run_7;
    uint tid_7 = thread_3.x;
    uint _S1014 = group_3.x;
    WideGroup_0 _S1015 = wide_group_0(params_7->wide_chunk_table_0, _S1014, &kernelContext_63);
    if(_S1014 != (_S1015.first_0))
    {
        return;
    }
    thread Island_natural_0 _S1016 = *((&kernelContext_63)->islands_0+_S1015.island_3);
    uint4 _S1017 = uint4((&_S1016)->info_0) ;
    uint _S1018 = _S1017.x;
    bool _S1019;
    if((_S1018 & 16U) == 0U)
    {
        _S1019 = true;
    }
    else
    {
        bool _S1020 = wide_enter_1(tid_7, _S1015.island_3, &kernelContext_63);
        _S1019 = !_S1020;
    }
    if(_S1019)
    {
        return;
    }
    Quat_0 _S1021 = quat_of_0(float4((&_S1016)->rotation_0) );
    bool _S1022 = (_S1018 & 4U) != 0U;
    float3 _S1023 = float3(0.0f) ;
    thread float3 norm_1 = _S1023;
    thread float3 unused_2 = _S1023;
    uint4 _S1024 = uint4((&_S1016)->range_0) ;
    uint c_24 = _S1024.x + tid_7;
    for(;;)
    {
        if(c_24 < (_S1024.y))
        {
        }
        else
        {
            break;
        }
        uint _S1025 = wide_step_0(&_S1016, &kernelContext_63);
        float _S1026 = (&kernelContext_63)->params_0->dt_0;
        thread Quat_0 _S1027 = _S1021;
        float _S1028 = settled_chunk_load_0(c_24, &_S1027, _S1025, _S1026, _S1022, &kernelContext_63);
        norm_1.x = norm_1.x + _S1028;
        c_24 = c_24 + 256U;
    }
    group_sum3_0(tid_7, &norm_1, &unused_2, &kernelContext_63);
    if(tid_7 != 0U)
    {
        return;
    }
    uint _S1029 = seen_bits_0(&kernelContext_63);
    uint cov_5 = 1024U | _S1029;
    if(((&kernelContext_63)->params_0->solve_mode_0) == 1U)
    {
        float4 _S1030 = float4((&_S1016)->energy_0) ;
        _S1019 = (abs(norm_1.x - _S1030.z)) > (_S1030.w);
    }
    else
    {
        _S1019 = false;
    }
    uint cov_6;
    if(_S1019)
    {
        ((&kernelContext_63)->islands_0+_S1015.island_3)->info_0[int(0)] = _S1018 & 4294967279U;
        ((&kernelContext_63)->islands_0+_S1015.island_3)->info_0[int(2)] = (_S1017.z) | 4U;
        cov_6 = cov_5 | 2048U;
    }
    else
    {
        cov_6 = cov_5;
    }
    cov_mark_0(_S1015.island_3, (&_S1016)->coverage_0, cov_6, &kernelContext_63);
    return;
}

void wide_store_0(uint slot_2, uint p_14, float3 a_12, float3 b_29, KernelContext_0 thread* kernelContext_64)
{
    uint _S1031 = 8U * slot_2;
    *(kernelContext_64->scratch_0+(kernelContext_64->params_0->wide_base_0 + _S1031 + p_14)) = packed_float4(float4(a_12, 0.0f)) ;
    *(kernelContext_64->scratch_0+(kernelContext_64->params_0->wide_base_0 + _S1031 + p_14 + 1U)) = packed_float4(float4(b_29, 0.0f)) ;
    return;
}

[[kernel]] void wide_bonds(uint3 group_4 [[threadgroup_position_in_grid]], uint3 thread_4 [[thread_position_in_threadgroup]], Params_0 constant* params_8 [[buffer(0)]], Island_natural_0 device* islands_8 [[buffer(9)]], uint device* index_8 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_8 [[buffer(3)]], packed_float4 device* state_10 [[buffer(6)]], packed_float4 device* scratch_8 [[buffer(8)]], packed_float4 device* contact_state_8 [[buffer(11)]], packed_float4 device* loads_8 [[buffer(5)]], Impactor_natural_0 device* impactors_8 [[buffer(10)]], BondStatic_natural_0 device* bonds_8 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_8 [[buffer(7)]], MaterialTable_0 constant* materials_8 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_65;
    (&kernelContext_65)->params_0 = params_8;
    (&kernelContext_65)->islands_0 = islands_8;
    (&kernelContext_65)->index_0 = index_8;
    (&kernelContext_65)->chunks_0 = chunks_8;
    (&kernelContext_65)->state_0 = state_10;
    (&kernelContext_65)->scratch_0 = scratch_8;
    (&kernelContext_65)->contact_state_0 = contact_state_8;
    (&kernelContext_65)->loads_0 = loads_8;
    (&kernelContext_65)->impactors_0 = impactors_8;
    (&kernelContext_65)->bonds_0 = bonds_8;
    (&kernelContext_65)->bond_dyn_0 = bond_dyn_8;
    (&kernelContext_65)->materials_0 = materials_8;
    threadgroup array<float4, int(32)> g_part_a_8;
    (&kernelContext_65)->g_part_a_0 = &g_part_a_8;
    threadgroup array<float4, int(32)> g_part_b_8;
    (&kernelContext_65)->g_part_b_0 = &g_part_b_8;
    threadgroup array<uint, int(5)> g_seen_8;
    (&kernelContext_65)->g_seen_0 = &g_seen_8;
    threadgroup uint g_run_8;
    (&kernelContext_65)->g_run_0 = &g_run_8;
    threadgroup uint g_halt_8;
    (&kernelContext_65)->g_halt_0 = &g_halt_8;
    threadgroup uint g_wide_run_8;
    (&kernelContext_65)->g_wide_run_0 = &g_wide_run_8;
    uint tid_8 = thread_4.x;
    uint _S1032 = group_4.x;
    bool bond_group_0 = _S1032 < (params_8->wide_bond_groups_0);
    WideGroup_0 wg_0;
    if(bond_group_0)
    {
        WideGroup_0 _S1033 = wide_group_0((&kernelContext_65)->params_0->wide_bond_table_0, _S1032, &kernelContext_65);
        wg_0 = _S1033;
    }
    else
    {
        WideGroup_0 _S1034 = wide_group_0((&kernelContext_65)->params_0->wide_chunk_table_0, _S1032 - params_8->wide_bond_groups_0, &kernelContext_65);
        wg_0 = _S1034;
    }
    WideGroup_0 _S1035 = wg_0;
    thread Island_natural_0 _S1036 = *((&kernelContext_65)->islands_0+wg_0.island_3);
    bool _S1037 = wide_enter_1(tid_8, wg_0.island_3, &kernelContext_65);
    if(!_S1037)
    {
        return;
    }
    uint _S1038 = wide_step_0(&_S1036, &kernelContext_65);
    if(bond_group_0)
    {
        uint4 _S1039 = uint4((&_S1036)->info_0) ;
        if(((_S1039.x) & 16U) != 0U)
        {
            return;
        }
        uint i_12 = wg_0.begin_1 + tid_8;
        bool _S1040;
        if(i_12 < (wg_0.end_0))
        {
            bool _S1041 = bond_update_0(i_12, (&kernelContext_65)->params_0->dt_0, ((&kernelContext_65)->params_0->fracture_0) != 0U, _S1039.w + 1U, true, &kernelContext_65);
            _S1040 = _S1041;
        }
        else
        {
            _S1040 = false;
        }
        if(_S1040)
        {
            ((&kernelContext_65)->islands_0+_S1035.island_3)->info_0[int(2)] = (_S1039.z) | 2U;
        }
        return;
    }
    uint _S1042 = (uint4((&_S1036)->info_0) ).x;
    if((_S1042 & 1U) != 0U)
    {
        return;
    }
    float3 _S1043 = float3(0.0f) ;
    thread float3 f_16 = _S1043;
    thread float3 t_16 = _S1043;
    uint c_25 = wg_0.begin_1 + tid_8;
    if(c_25 < (wg_0.end_0))
    {
        Rigid_0 _S1044 = rigid_of_0(&_S1036);
        float _S1045 = (&kernelContext_65)->params_0->dt_0;
        bool _S1046 = (_S1042 & 4U) != 0U;
        thread Rigid_0 _S1047 = _S1044;
        net_load_0(c_25, &_S1036, &_S1047, _S1038, _S1045, _S1046, &f_16, &t_16, &kernelContext_65);
    }
    group_sum3_0(tid_8, &f_16, &t_16, &kernelContext_65);
    if(tid_8 == 0U)
    {
        wide_store_0(_S1032 - params_8->wide_bond_groups_0, 0U, f_16, t_16, &kernelContext_65);
    }
    return;
}

void wide_partials_0(uint tid_9, uint first_1, uint count_5, uint p_15, float3 thread* a_13, float3 thread* b_30, KernelContext_0 thread* kernelContext_66)
{
    float4 _S1048 = float4(0.0f) ;
    thread float4 x_10 = _S1048;
    thread float4 y_2 = _S1048;
    uint s_8 = tid_9;
    for(;;)
    {
        if(s_8 < count_5)
        {
        }
        else
        {
            break;
        }
        uint _S1049 = 8U * (first_1 + s_8);
        x_10 = x_10 + float4(*(kernelContext_66->scratch_0+(kernelContext_66->params_0->wide_base_0 + _S1049 + p_15))) ;
        y_2 = y_2 + float4(*(kernelContext_66->scratch_0+(kernelContext_66->params_0->wide_base_0 + _S1049 + p_15 + 1U))) ;
        s_8 = s_8 + 256U;
    }
    group_sum2_0(tid_9, &x_10, &y_2, kernelContext_66);
    *a_13 = x_10.xyz;
    *b_30 = y_2.xyz;
    return;
}

Rigid_0 wide_rigid_frame_0(uint tid_10, const Island_natural_0 thread* isl_20, const WideGroup_0 thread* wg_1, KernelContext_0 thread* kernelContext_67)
{
    Rigid_0 _S1050 = rigid_of_0(isl_20);
    thread Rigid_0 rg_14 = _S1050;
    if((((uint4(isl_20->info_0) ).x) & 1U) == 0U)
    {
        thread float3 f_17;
        thread float3 t_17;
        wide_partials_0(tid_10, wg_1->first_0, isl_20->wide_groups_0, 0U, &f_17, &t_17, kernelContext_67);
        rigid_acceleration_0(isl_20, &rg_14, f_17, t_17);
    }
    return rg_14;
}

[[kernel]] void wide_chunks(uint3 group_5 [[threadgroup_position_in_grid]], uint3 thread_5 [[thread_position_in_threadgroup]], Params_0 constant* params_9 [[buffer(0)]], Island_natural_0 device* islands_9 [[buffer(9)]], uint device* index_9 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_9 [[buffer(3)]], packed_float4 device* state_11 [[buffer(6)]], packed_float4 device* scratch_9 [[buffer(8)]], packed_float4 device* contact_state_9 [[buffer(11)]], packed_float4 device* loads_9 [[buffer(5)]], Impactor_natural_0 device* impactors_9 [[buffer(10)]], BondStatic_natural_0 device* bonds_9 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_9 [[buffer(7)]], MaterialTable_0 constant* materials_9 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_68;
    (&kernelContext_68)->params_0 = params_9;
    (&kernelContext_68)->islands_0 = islands_9;
    (&kernelContext_68)->index_0 = index_9;
    (&kernelContext_68)->chunks_0 = chunks_9;
    (&kernelContext_68)->state_0 = state_11;
    (&kernelContext_68)->scratch_0 = scratch_9;
    (&kernelContext_68)->contact_state_0 = contact_state_9;
    (&kernelContext_68)->loads_0 = loads_9;
    (&kernelContext_68)->impactors_0 = impactors_9;
    (&kernelContext_68)->bonds_0 = bonds_9;
    (&kernelContext_68)->bond_dyn_0 = bond_dyn_9;
    (&kernelContext_68)->materials_0 = materials_9;
    threadgroup array<float4, int(32)> g_part_a_9;
    (&kernelContext_68)->g_part_a_0 = &g_part_a_9;
    threadgroup array<float4, int(32)> g_part_b_9;
    (&kernelContext_68)->g_part_b_0 = &g_part_b_9;
    threadgroup array<uint, int(5)> g_seen_9;
    (&kernelContext_68)->g_seen_0 = &g_seen_9;
    threadgroup uint g_run_9;
    (&kernelContext_68)->g_run_0 = &g_run_9;
    threadgroup uint g_halt_9;
    (&kernelContext_68)->g_halt_0 = &g_halt_9;
    threadgroup uint g_wide_run_9;
    (&kernelContext_68)->g_wide_run_0 = &g_wide_run_9;
    uint tid_11 = thread_5.x;
    uint _S1051 = group_5.x;
    WideGroup_0 _S1052 = wide_group_0(params_9->wide_chunk_table_0, _S1051, &kernelContext_68);
    thread Island_natural_0 _S1053 = *((&kernelContext_68)->islands_0+_S1052.island_3);
    bool _S1054 = wide_enter_1(tid_11, _S1052.island_3, &kernelContext_68);
    if(!_S1054)
    {
        return;
    }
    uint _S1055 = (uint4((&_S1053)->info_0) ).x;
    bool anchored_0 = (_S1055 & 1U) != 0U;
    if((_S1055 & 16U) != 0U)
    {
        if(tid_11 == 0U)
        {
            *((&kernelContext_68)->scratch_0+((&kernelContext_68)->params_0->wide_base_0 + 8U * _S1051 + 6U)) = packed_float4(float4(0.0f) ) ;
        }
        return;
    }
    thread WideGroup_0 _S1056 = _S1052;
    Rigid_0 _S1057 = wide_rigid_frame_0(tid_11, &_S1053, &_S1056, &kernelContext_68);
    thread float work_4 = 0.0f;
    thread float work_err_3 = 0.0f;
    float3 _S1058 = float3(0.0f) ;
    thread float3 tu_2 = _S1058;
    thread float3 pv_2 = _S1058;
    uint c_26 = _S1052.begin_1 + tid_11;
    if(c_26 < (_S1052.end_0))
    {
        float _S1059 = (&kernelContext_68)->params_0->dt_0;
        bool _S1060 = ((&kernelContext_68)->params_0->rigid_motion_loads_0) != 0U;
        uint _S1061 = wide_step_0(&_S1053, &kernelContext_68);
        bool _S1062 = (_S1055 & 4U) != 0U;
        thread Rigid_0 _S1063 = _S1057;
        chunk_update_0(c_26, &_S1053, &_S1063, _S1059, _S1060, _S1061, _S1062, &work_4, &work_err_3, &kernelContext_68);
        if(!anchored_0)
        {
            drift_moments_0(c_26, &tu_2, &pv_2, &kernelContext_68);
        }
    }
    thread float3 wsum_1 = float3(work_4, work_err_3, 0.0f);
    thread float3 unused_3 = _S1058;
    group_sum3_0(tid_11, &wsum_1, &unused_3, &kernelContext_68);
    bool _S1064 = !anchored_0;
    if(_S1064)
    {
        group_sum3_0(tid_11, &tu_2, &pv_2, &kernelContext_68);
    }
    if(tid_11 == 0U)
    {
        uint _S1065 = 8U * _S1051;
        *((&kernelContext_68)->scratch_0+((&kernelContext_68)->params_0->wide_base_0 + _S1065 + 6U)) = packed_float4(float4(wsum_1, 0.0f)) ;
        if(_S1064)
        {
            wide_store_0(_S1051, 2U, tu_2, pv_2, &kernelContext_68);
        }
        *((&kernelContext_68)->scratch_0+((&kernelContext_68)->params_0->wide_base_0 + _S1065 + 7U)) = packed_float4(float4(float((*(&kernelContext_68)->g_seen_0)[0U]), float((*(&kernelContext_68)->g_seen_0)[1U]), float((*(&kernelContext_68)->g_seen_0)[2U]), 0.0f)) ;
    }
    return;
}

[[kernel]] void wide_drift(uint3 group_6 [[threadgroup_position_in_grid]], uint3 thread_6 [[thread_position_in_threadgroup]], Params_0 constant* params_10 [[buffer(0)]], Island_natural_0 device* islands_10 [[buffer(9)]], uint device* index_10 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_10 [[buffer(3)]], packed_float4 device* state_12 [[buffer(6)]], packed_float4 device* scratch_10 [[buffer(8)]], packed_float4 device* contact_state_10 [[buffer(11)]], packed_float4 device* loads_10 [[buffer(5)]], Impactor_natural_0 device* impactors_10 [[buffer(10)]], BondStatic_natural_0 device* bonds_10 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_10 [[buffer(7)]], MaterialTable_0 constant* materials_10 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_69;
    (&kernelContext_69)->params_0 = params_10;
    (&kernelContext_69)->islands_0 = islands_10;
    (&kernelContext_69)->index_0 = index_10;
    (&kernelContext_69)->chunks_0 = chunks_10;
    (&kernelContext_69)->state_0 = state_12;
    (&kernelContext_69)->scratch_0 = scratch_10;
    (&kernelContext_69)->contact_state_0 = contact_state_10;
    (&kernelContext_69)->loads_0 = loads_10;
    (&kernelContext_69)->impactors_0 = impactors_10;
    (&kernelContext_69)->bonds_0 = bonds_10;
    (&kernelContext_69)->bond_dyn_0 = bond_dyn_10;
    (&kernelContext_69)->materials_0 = materials_10;
    threadgroup array<float4, int(32)> g_part_a_10;
    (&kernelContext_69)->g_part_a_0 = &g_part_a_10;
    threadgroup array<float4, int(32)> g_part_b_10;
    (&kernelContext_69)->g_part_b_0 = &g_part_b_10;
    threadgroup array<uint, int(5)> g_seen_10;
    (&kernelContext_69)->g_seen_0 = &g_seen_10;
    threadgroup uint g_run_10;
    (&kernelContext_69)->g_run_0 = &g_run_10;
    threadgroup uint g_halt_10;
    (&kernelContext_69)->g_halt_0 = &g_halt_10;
    threadgroup uint g_wide_run_10;
    (&kernelContext_69)->g_wide_run_0 = &g_wide_run_10;
    uint tid_12 = thread_6.x;
    uint _S1066 = group_6.x;
    WideGroup_0 _S1067 = wide_group_0(params_10->wide_chunk_table_0, _S1066, &kernelContext_69);
    Island_natural_0 device* _S1068 = (&kernelContext_69)->islands_0+_S1067.island_3;
    Island_natural_0 isl_21 = *_S1068;
    bool _S1069;
    if((((uint4((*_S1068).info_0) ).x) & 17U) != 0U)
    {
        _S1069 = true;
    }
    else
    {
        bool _S1070 = wide_enter_1(tid_12, _S1067.island_3, &kernelContext_69);
        _S1069 = !_S1070;
    }
    if(_S1069)
    {
        return;
    }
    thread float3 tu_3;
    thread float3 pv_3;
    wide_partials_0(tid_12, _S1067.first_0, isl_21.wide_groups_0, 2U, &tu_3, &pv_3, &kernelContext_69);
    float4 _S1071 = float4(isl_21.wcom_0) ;
    float3 _S1072 = float3(_S1071.w) ;
    float3 tr_5 = tu_3 / _S1072;
    float3 dv_5 = pv_3 / _S1072;
    float3 _S1073 = float3(0.0f) ;
    thread float3 lu_2 = _S1073;
    thread float3 lv_2 = _S1073;
    uint c_27 = _S1067.begin_1 + tid_12;
    if(c_27 < (_S1067.end_0))
    {
        drift_angular_0(c_27, _S1071.xyz, tr_5, dv_5, &lu_2, &lv_2, &kernelContext_69);
    }
    group_sum3_0(tid_12, &lu_2, &lv_2, &kernelContext_69);
    if(tid_12 == 0U)
    {
        wide_store_0(_S1066, 4U, lu_2, lv_2, &kernelContext_69);
    }
    return;
}

[[kernel]] void wide_rigid(uint3 group_7 [[threadgroup_position_in_grid]], uint3 thread_7 [[thread_position_in_threadgroup]], Params_0 constant* params_11 [[buffer(0)]], Island_natural_0 device* islands_11 [[buffer(9)]], uint device* index_11 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_11 [[buffer(3)]], packed_float4 device* state_13 [[buffer(6)]], packed_float4 device* scratch_11 [[buffer(8)]], packed_float4 device* contact_state_11 [[buffer(11)]], packed_float4 device* loads_11 [[buffer(5)]], Impactor_natural_0 device* impactors_11 [[buffer(10)]], BondStatic_natural_0 device* bonds_11 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_11 [[buffer(7)]], MaterialTable_0 constant* materials_11 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_70;
    (&kernelContext_70)->params_0 = params_11;
    (&kernelContext_70)->islands_0 = islands_11;
    (&kernelContext_70)->index_0 = index_11;
    (&kernelContext_70)->chunks_0 = chunks_11;
    (&kernelContext_70)->state_0 = state_13;
    (&kernelContext_70)->scratch_0 = scratch_11;
    (&kernelContext_70)->contact_state_0 = contact_state_11;
    (&kernelContext_70)->loads_0 = loads_11;
    (&kernelContext_70)->impactors_0 = impactors_11;
    (&kernelContext_70)->bonds_0 = bonds_11;
    (&kernelContext_70)->bond_dyn_0 = bond_dyn_11;
    (&kernelContext_70)->materials_0 = materials_11;
    threadgroup array<float4, int(32)> g_part_a_11;
    (&kernelContext_70)->g_part_a_0 = &g_part_a_11;
    threadgroup array<float4, int(32)> g_part_b_11;
    (&kernelContext_70)->g_part_b_0 = &g_part_b_11;
    threadgroup array<uint, int(5)> g_seen_11;
    (&kernelContext_70)->g_seen_0 = &g_seen_11;
    threadgroup uint g_run_11;
    (&kernelContext_70)->g_run_0 = &g_run_11;
    threadgroup uint g_halt_11;
    (&kernelContext_70)->g_halt_0 = &g_halt_11;
    threadgroup uint g_wide_run_11;
    (&kernelContext_70)->g_wide_run_0 = &g_wide_run_11;
    uint tid_13 = thread_7.x;
    uint _S1074 = group_7.x;
    WideGroup_0 _S1075 = wide_group_0(params_11->wide_chunk_table_0, _S1074, &kernelContext_70);
    thread Island_natural_0 _S1076 = *((&kernelContext_70)->islands_0+_S1075.island_3);
    uint _S1077 = (uint4((&_S1076)->info_0) ).x;
    bool _S1078;
    if((_S1077 & 1U) != 0U)
    {
        _S1078 = true;
    }
    else
    {
        bool _S1079 = wide_enter_1(tid_13, _S1075.island_3, &kernelContext_70);
        _S1078 = !_S1079;
    }
    if(_S1078)
    {
        return;
    }
    if((_S1077 & 16U) != 0U)
    {
        if(_S1074 != (_S1075.first_0))
        {
            return;
        }
        thread WideGroup_0 _S1080 = _S1075;
        Rigid_0 _S1081 = wide_rigid_frame_0(tid_13, &_S1076, &_S1080, &kernelContext_70);
        thread Rigid_0 rs_0 = _S1081;
        if(tid_13 != 0U)
        {
            _S1078 = true;
        }
        else
        {
            _S1078 = (_S1077 & 2U) != 0U;
        }
        if(_S1078)
        {
            return;
        }
        integrate_rigid_0(&_S1076, &rs_0, (&kernelContext_70)->params_0->dt_0);
        thread Quat_0 _S1082 = (&rs_0)->rot_0;
        float4 _S1083 = quat_vec_0(&_S1082);
        ((&kernelContext_70)->islands_0+_S1075.island_3)->rotation_0 = packed_float4(_S1083) ;
        ((&kernelContext_70)->islands_0+_S1075.island_3)->rotation_err_0 = packed_float4((&rs_0)->rot_err_0) ;
        ((&kernelContext_70)->islands_0+_S1075.island_3)->position_0 = packed_float4(float4((&rs_0)->pos_1, 0.0f)) ;
        ((&kernelContext_70)->islands_0+_S1075.island_3)->position_err_0 = packed_float4(float4((&rs_0)->pos_err_1, 0.0f)) ;
        ((&kernelContext_70)->islands_0+_S1075.island_3)->velocity_0 = packed_float4(float4((&rs_0)->vel_1, 0.0f)) ;
        ((&kernelContext_70)->islands_0+_S1075.island_3)->velocity_err_0 = packed_float4(float4((&rs_0)->vel_err_1, 0.0f)) ;
        ((&kernelContext_70)->islands_0+_S1075.island_3)->angular_velocity_0 = packed_float4(float4((&rs_0)->w_4, 0.0f)) ;
        ((&kernelContext_70)->islands_0+_S1075.island_3)->momentum_0 = packed_float4(float4((&rs_0)->l_2, 0.0f)) ;
        ((&kernelContext_70)->islands_0+_S1075.island_3)->momentum_err_0 = packed_float4(float4((&rs_0)->l_err_1, 0.0f)) ;
        return;
    }
    thread float3 tu_4;
    thread float3 pv_4;
    wide_partials_0(tid_13, _S1075.first_0, (&_S1076)->wide_groups_0, 2U, &tu_4, &pv_4, &kernelContext_70);
    thread float3 lu_3;
    thread float3 lv_3;
    wide_partials_0(tid_13, _S1075.first_0, (&_S1076)->wide_groups_0, 4U, &lu_3, &lv_3, &kernelContext_70);
    float4 _S1084 = float4((&_S1076)->wcom_0) ;
    float3 _S1085 = float3(_S1084.w) ;
    float3 tr_6 = tu_4 / _S1085;
    float3 dv_6 = pv_4 / _S1085;
    float4 _S1086 = float4((&_S1076)->winv0_0) ;
    float4 _S1087 = float4((&_S1076)->winv1_0) ;
    float4 _S1088 = float4((&_S1076)->winv2_0) ;
    float3 phi_5 = rows_mul_0(_S1086, _S1087, _S1088, lu_3);
    float3 dw_4 = rows_mul_0(_S1086, _S1087, _S1088, lv_3);
    uint c_28 = _S1075.begin_1 + tid_13;
    if(c_28 < (_S1075.end_0))
    {
        drift_apply_0(c_28, _S1084.xyz, tr_6, phi_5, dv_6, dw_4, &kernelContext_70);
    }
    if(_S1074 != (_S1075.first_0))
    {
        return;
    }
    thread WideGroup_0 _S1089 = _S1075;
    Rigid_0 _S1090 = wide_rigid_frame_0(tid_13, &_S1076, &_S1089, &kernelContext_70);
    thread Rigid_0 rg_15 = _S1090;
    if(tid_13 != 0U)
    {
        return;
    }
    if(!((_S1077 & 2U) != 0U))
    {
        integrate_rigid_0(&_S1076, &rg_15, (&kernelContext_70)->params_0->dt_0);
        drift_rigid_0(&_S1076, &rg_15, tr_6, phi_5, dv_6, dw_4);
    }
    thread Quat_0 _S1091 = (&rg_15)->rot_0;
    float4 _S1092 = quat_vec_0(&_S1091);
    ((&kernelContext_70)->islands_0+_S1075.island_3)->rotation_0 = packed_float4(_S1092) ;
    ((&kernelContext_70)->islands_0+_S1075.island_3)->rotation_err_0 = packed_float4((&rg_15)->rot_err_0) ;
    ((&kernelContext_70)->islands_0+_S1075.island_3)->position_0 = packed_float4(float4((&rg_15)->pos_1, 0.0f)) ;
    ((&kernelContext_70)->islands_0+_S1075.island_3)->position_err_0 = packed_float4(float4((&rg_15)->pos_err_1, 0.0f)) ;
    ((&kernelContext_70)->islands_0+_S1075.island_3)->velocity_0 = packed_float4(float4((&rg_15)->vel_1, 0.0f)) ;
    ((&kernelContext_70)->islands_0+_S1075.island_3)->velocity_err_0 = packed_float4(float4((&rg_15)->vel_err_1, 0.0f)) ;
    ((&kernelContext_70)->islands_0+_S1075.island_3)->angular_velocity_0 = packed_float4(float4((&rg_15)->w_4, 0.0f)) ;
    ((&kernelContext_70)->islands_0+_S1075.island_3)->momentum_0 = packed_float4(float4((&rg_15)->l_2, 0.0f)) ;
    ((&kernelContext_70)->islands_0+_S1075.island_3)->momentum_err_0 = packed_float4(float4((&rg_15)->l_err_1, 0.0f)) ;
    return;
}

[[kernel]] void wide_end(uint3 group_8 [[threadgroup_position_in_grid]], uint3 thread_8 [[thread_position_in_threadgroup]], Params_0 constant* params_12 [[buffer(0)]], Island_natural_0 device* islands_12 [[buffer(9)]], uint device* index_12 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_12 [[buffer(3)]], packed_float4 device* state_14 [[buffer(6)]], packed_float4 device* scratch_12 [[buffer(8)]], packed_float4 device* contact_state_12 [[buffer(11)]], packed_float4 device* loads_12 [[buffer(5)]], Impactor_natural_0 device* impactors_12 [[buffer(10)]], BondStatic_natural_0 device* bonds_12 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_12 [[buffer(7)]], MaterialTable_0 constant* materials_12 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_71;
    (&kernelContext_71)->params_0 = params_12;
    (&kernelContext_71)->islands_0 = islands_12;
    (&kernelContext_71)->index_0 = index_12;
    (&kernelContext_71)->chunks_0 = chunks_12;
    (&kernelContext_71)->state_0 = state_14;
    (&kernelContext_71)->scratch_0 = scratch_12;
    (&kernelContext_71)->contact_state_0 = contact_state_12;
    (&kernelContext_71)->loads_0 = loads_12;
    (&kernelContext_71)->impactors_0 = impactors_12;
    (&kernelContext_71)->bonds_0 = bonds_12;
    (&kernelContext_71)->bond_dyn_0 = bond_dyn_12;
    (&kernelContext_71)->materials_0 = materials_12;
    threadgroup array<float4, int(32)> g_part_a_12;
    (&kernelContext_71)->g_part_a_0 = &g_part_a_12;
    threadgroup array<float4, int(32)> g_part_b_12;
    (&kernelContext_71)->g_part_b_0 = &g_part_b_12;
    threadgroup array<uint, int(5)> g_seen_12;
    (&kernelContext_71)->g_seen_0 = &g_seen_12;
    threadgroup uint g_run_12;
    (&kernelContext_71)->g_run_0 = &g_run_12;
    threadgroup uint g_halt_12;
    (&kernelContext_71)->g_halt_0 = &g_halt_12;
    threadgroup uint g_wide_run_12;
    (&kernelContext_71)->g_wide_run_0 = &g_wide_run_12;
    uint tid_14 = thread_8.x;
    uint _S1093 = group_8.x;
    WideGroup_0 _S1094 = wide_group_0(params_12->wide_chunk_table_0, _S1093, &kernelContext_71);
    if(_S1093 != (_S1094.first_0))
    {
        return;
    }
    Island_natural_0 device* _S1095 = (&kernelContext_71)->islands_0+_S1094.island_3;
    thread Island_natural_0 _S1096 = *_S1095;
    uint4 _S1097 = uint4((&_S1096)->info_0) ;
    float4 _S1098 = float4((&_S1096)->com_0) ;
    float4 _S1099 = float4((&_S1096)->inertia0_0) ;
    float4 _S1100 = float4((&_S1096)->inertia1_0) ;
    float4 _S1101 = float4((&_S1096)->inertia2_0) ;
    float4 _S1102 = float4((&_S1096)->inv0_0) ;
    float4 _S1103 = float4((&_S1096)->inv1_0) ;
    float4 _S1104 = float4((&_S1096)->inv2_0) ;
    float4 _S1105 = float4((&_S1096)->wcom_0) ;
    float4 _S1106 = float4((&_S1096)->winv0_0) ;
    float4 _S1107 = float4((&_S1096)->winv1_0) ;
    float4 _S1108 = float4((&_S1096)->winv2_0) ;
    float4 _S1109 = float4((&_S1096)->rotation_0) ;
    float4 _S1110 = float4((&_S1096)->position_0) ;
    float4 _S1111 = float4((&_S1096)->position_err_0) ;
    float4 _S1112 = float4((&_S1096)->velocity_0) ;
    float4 _S1113 = float4((&_S1096)->velocity_err_0) ;
    float4 _S1114 = float4((&_S1096)->angular_velocity_0) ;
    uint4 _S1115 = uint4((&_S1096)->probes_0) ;
    float4 _S1116 = float4((&_S1096)->energy_0) ;
    float4 _S1117 = float4((&_S1096)->rotation_err_0) ;
    float4 _S1118 = float4((&_S1096)->momentum_0) ;
    float4 _S1119 = float4((&_S1096)->momentum_err_0) ;
    thread Island_0 isl_22;
    (&isl_22)->range_0 = uint4((&_S1096)->range_0) ;
    (&isl_22)->info_0 = _S1097;
    (&isl_22)->com_0 = _S1098;
    (&isl_22)->inertia0_0 = _S1099;
    (&isl_22)->inertia1_0 = _S1100;
    (&isl_22)->inertia2_0 = _S1101;
    (&isl_22)->inv0_0 = _S1102;
    (&isl_22)->inv1_0 = _S1103;
    (&isl_22)->inv2_0 = _S1104;
    (&isl_22)->wcom_0 = _S1105;
    (&isl_22)->winv0_0 = _S1106;
    (&isl_22)->winv1_0 = _S1107;
    (&isl_22)->winv2_0 = _S1108;
    (&isl_22)->rotation_0 = _S1109;
    (&isl_22)->position_0 = _S1110;
    (&isl_22)->position_err_0 = _S1111;
    (&isl_22)->velocity_0 = _S1112;
    (&isl_22)->velocity_err_0 = _S1113;
    (&isl_22)->angular_velocity_0 = _S1114;
    (&isl_22)->done_0 = (&_S1096)->done_0;
    (&isl_22)->coverage_0 = (&_S1096)->coverage_0;
    (&isl_22)->wide_groups_0 = (&_S1096)->wide_groups_0;
    (&isl_22)->done_pad_0 = (&_S1096)->done_pad_0;
    (&isl_22)->probes_0 = _S1115;
    (&isl_22)->energy_0 = _S1116;
    (&isl_22)->rotation_err_0 = _S1117;
    (&isl_22)->momentum_0 = _S1118;
    (&isl_22)->momentum_err_0 = _S1119;
    _S1096 = *_S1095;
    bool _S1120 = wide_enter_0(tid_14, &_S1096, &kernelContext_71);
    if(!_S1120)
    {
        return;
    }
    thread float3 work_5;
    thread float3 flags_2;
    wide_partials_0(tid_14, _S1094.first_0, (&isl_22)->wide_groups_0, 6U, &work_5, &flags_2, &kernelContext_71);
    if(tid_14 != 0U)
    {
        return;
    }
    thread Island_0 _S1121 = isl_22;
    uint _S1122 = wide_step_1(&_S1121, &kernelContext_71);
    if(((&isl_22)->probes_0.y) > ((&isl_22)->probes_0.x))
    {
        thread Island_0 _S1123 = isl_22;
        Rigid_0 _S1124 = rigid_of_1(&_S1123);
        thread Island_0 _S1125 = isl_22;
        thread Rigid_0 _S1126 = _S1124;
        record_probes_0(&_S1125, &_S1126, _S1122, &kernelContext_71);
    }
    bool halt_0 = (((&isl_22)->info_0.z) & 2U) != 0U;
    bool _S1127;
    if(halt_0)
    {
        _S1127 = (((&isl_22)->info_0.x) & 4U) != 0U;
    }
    else
    {
        _S1127 = false;
    }
    if(_S1127)
    {
        contact_split_at_0((&isl_22)->info_0.w + 1U, &kernelContext_71);
    }
    float _S1128 = work_5.x;
    thread float _S1129 = (&isl_22)->energy_0.x;
    thread float _S1130 = (&isl_22)->energy_0.y;
    comp_add1_0(&_S1129, &_S1130, _S1128);
    (&isl_22)->energy_0.x = _S1129;
    (&isl_22)->energy_0.y = _S1130 + work_5.y;
    (&isl_22)->done_0 = (&isl_22)->done_0 + 1U;
    (&isl_22)->info_0.y = (&isl_22)->info_0.y - 1U;
    (&isl_22)->info_0.w = (&isl_22)->info_0.w + 1U;
    if(halt_0)
    {
        (&isl_22)->info_0.z = (((&isl_22)->info_0.z) & 4294967293U) | 1U;
    }
    uint _S1131;
    if(halt_0)
    {
        _S1131 = 128U;
    }
    else
    {
        _S1131 = 0U;
    }
    uint _S1132 = 256U | _S1131;
    if(((&isl_22)->probes_0.y) > ((&isl_22)->probes_0.x))
    {
        _S1131 = 262144U;
    }
    else
    {
        _S1131 = 0U;
    }
    uint _S1133 = _S1132 | _S1131;
    if((((&isl_22)->info_0.x) & 4U) != 0U)
    {
        _S1131 = 524288U;
    }
    else
    {
        _S1131 = 0U;
    }
    uint _S1134 = _S1133 | _S1131;
    if((flags_2.x) > 0.0f)
    {
        _S1131 = 32768U;
    }
    else
    {
        _S1131 = 0U;
    }
    uint _S1135 = _S1134 | _S1131;
    if((flags_2.y) > 0.0f)
    {
        _S1131 = 65536U;
    }
    else
    {
        _S1131 = 0U;
    }
    uint _S1136 = _S1135 | _S1131;
    if((flags_2.z) > 0.0f)
    {
        _S1131 = 131072U;
    }
    else
    {
        _S1131 = 0U;
    }
    (&isl_22)->coverage_0 = ((&isl_22)->coverage_0) | (_S1136 | _S1131);
    Island_natural_0 device* _S1137 = (&kernelContext_71)->islands_0+_S1094.island_3;
    _S1137->range_0 = packed_uint4(isl_22.range_0) ;
    _S1137->info_0 = packed_uint4(isl_22.info_0) ;
    _S1137->com_0 = packed_float4(isl_22.com_0) ;
    _S1137->inertia0_0 = packed_float4(isl_22.inertia0_0) ;
    _S1137->inertia1_0 = packed_float4(isl_22.inertia1_0) ;
    _S1137->inertia2_0 = packed_float4(isl_22.inertia2_0) ;
    _S1137->inv0_0 = packed_float4(isl_22.inv0_0) ;
    _S1137->inv1_0 = packed_float4(isl_22.inv1_0) ;
    _S1137->inv2_0 = packed_float4(isl_22.inv2_0) ;
    _S1137->wcom_0 = packed_float4(isl_22.wcom_0) ;
    _S1137->winv0_0 = packed_float4(isl_22.winv0_0) ;
    _S1137->winv1_0 = packed_float4(isl_22.winv1_0) ;
    _S1137->winv2_0 = packed_float4(isl_22.winv2_0) ;
    _S1137->rotation_0 = packed_float4(isl_22.rotation_0) ;
    _S1137->position_0 = packed_float4(isl_22.position_0) ;
    _S1137->position_err_0 = packed_float4(isl_22.position_err_0) ;
    _S1137->velocity_0 = packed_float4(isl_22.velocity_0) ;
    _S1137->velocity_err_0 = packed_float4(isl_22.velocity_err_0) ;
    _S1137->angular_velocity_0 = packed_float4(isl_22.angular_velocity_0) ;
    _S1137->done_0 = isl_22.done_0;
    _S1137->coverage_0 = isl_22.coverage_0;
    _S1137->wide_groups_0 = isl_22.wide_groups_0;
    _S1137->done_pad_0 = isl_22.done_pad_0;
    _S1137->probes_0 = packed_uint4(isl_22.probes_0) ;
    _S1137->energy_0 = packed_float4(isl_22.energy_0) ;
    _S1137->rotation_err_0 = packed_float4(isl_22.rotation_err_0) ;
    _S1137->momentum_0 = packed_float4(isl_22.momentum_0) ;
    _S1137->momentum_err_0 = packed_float4(isl_22.momentum_err_0) ;
    return;
}

uint sv_0(uint c_29, uint slot_3, KernelContext_0 thread* kernelContext_72)
{
    return kernelContext_72->params_0->statics_base_0 + 23U * c_29 + slot_3;
}

void project_load_slot_0(uint tid_15, const Island_natural_0 thread* isl_23, uint slot_4, KernelContext_0 thread* kernelContext_73)
{
    uint _S1138;
    float3 _S1139 = float3(0.0f) ;
    thread float3 net_f_0 = _S1139;
    thread float3 net_m_0 = _S1139;
    uint4 _S1140 = uint4(isl_23->range_0) ;
    uint _S1141 = _S1140.x + tid_15;
    uint c_30 = _S1141;
    for(;;)
    {
        uint _S1142 = _S1140.y;
        _S1138 = _S1142;
        if(c_30 < _S1142)
        {
        }
        else
        {
            break;
        }
        uint _S1143 = sv_0(c_30, slot_4, kernelContext_73);
        float3 fi_2 = (float4(*(kernelContext_73->scratch_0+_S1143)) ).xyz;
        net_f_0 = net_f_0 + fi_2;
        float3 _S1144 = cross((float4((kernelContext_73->chunks_0+c_30)->center_0) ).xyz - (float4(isl_23->com_0) ).xyz, fi_2);
        uint _S1145 = sv_0(c_30, slot_4 + 1U, kernelContext_73);
        net_m_0 = net_m_0 + (_S1144 + (float4(*(kernelContext_73->scratch_0+_S1145)) ).xyz);
        c_30 = c_30 + 256U;
    }
    group_sum3_0(tid_15, &net_f_0, &net_m_0, kernelContext_73);
    float4 _S1146 = float4(isl_23->com_0) ;
    float3 _S1147 = net_f_0 / float3(_S1146.w) ;
    float3 _S1148 = rows_mul_0(float4(isl_23->inv0_0) , float4(isl_23->inv1_0) , float4(isl_23->inv2_0) , net_m_0);
    c_30 = _S1141;
    for(;;)
    {
        if(c_30 < _S1138)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_natural_0 device* _S1149 = kernelContext_73->chunks_0+c_30;
        float4 _S1150 = float4(_S1149->center_0) ;
        float3 r_12 = _S1150.xyz - _S1146.xyz;
        uint _S1151 = sv_0(c_30, slot_4, kernelContext_73);
        *(kernelContext_73->scratch_0+_S1151) = packed_float4(float4((float4(*(kernelContext_73->scratch_0+_S1151)) ).xyz - (_S1147 + cross(_S1148, r_12)) * float3(_S1150.w) , 0.0f)) ;
        uint _S1152 = sv_0(c_30, slot_4 + 1U, kernelContext_73);
        *(kernelContext_73->scratch_0+_S1152) = packed_float4(float4((float4(*(kernelContext_73->scratch_0+_S1152)) ).xyz - rows_mul_0(float4(_S1149->inertia0_1) , float4(_S1149->inertia1_1) , float4(_S1149->inertia2_1) , _S1148), 0.0f)) ;
        c_30 = c_30 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    return;
}

float island_dot_0(uint tid_16, uint c0_0, uint c1_0, uint sa_2, uint sb_2, KernelContext_0 thread* kernelContext_74)
{
    float4 _S1153 = float4(0.0f) ;
    thread float4 acc_0 = _S1153;
    thread float4 unused_4 = _S1153;
    uint c_31 = c0_0 + tid_16;
    for(;;)
    {
        if(c_31 < c1_0)
        {
        }
        else
        {
            break;
        }
        uint _S1154 = sv_0(c_31, sa_2, kernelContext_74);
        float3 _S1155 = (float4(*(kernelContext_74->scratch_0+_S1154)) ).xyz;
        uint _S1156 = sv_0(c_31, sb_2, kernelContext_74);
        float _S1157 = dot(_S1155, (float4(*(kernelContext_74->scratch_0+_S1156)) ).xyz);
        uint _S1158 = sv_0(c_31, sa_2 + 1U, kernelContext_74);
        float3 _S1159 = (float4(*(kernelContext_74->scratch_0+_S1158)) ).xyz;
        uint _S1160 = sv_0(c_31, sb_2 + 1U, kernelContext_74);
        acc_0.x = acc_0.x + (_S1157 + dot(_S1159, (float4(*(kernelContext_74->scratch_0+_S1160)) ).xyz));
        c_31 = c_31 + 256U;
    }
    group_sum2_0(tid_16, &acc_0, &unused_4, kernelContext_74);
    return acc_0.x;
}

void static_kinematics_0(uint _S1161, float3 thread* _S1162, float3 thread* _S1163, KernelContext_0 thread* kernelContext_75)
{
    BondStatic_natural_0 device* _S1164 = kernelContext_75->bonds_0+_S1161;
    uint4 _S1165 = uint4(_S1164->law_0.ids_0) ;
    uint ca_1 = _S1165.y;
    uint cb_1 = _S1165.z;
    uint _S1166 = 4U * cb_1;
    uint _S1167 = 4U * ca_1;
    float3 _S1168 = (float4(*(kernelContext_75->state_0+_S1166)) ).xyz - (float4(*(kernelContext_75->state_0+_S1167)) ).xyz;
    uint _S1169 = sv_0(cb_1, 21U, kernelContext_75);
    float3 _S1170 = (float4(*(kernelContext_75->scratch_0+_S1169)) ).xyz;
    uint _S1171 = sv_0(ca_1, 21U, kernelContext_75);
    float3 du_0 = _S1168 + (_S1170 - (float4(*(kernelContext_75->scratch_0+_S1171)) ).xyz);
    uint _S1172 = _S1166 + 1U;
    uint _S1173 = _S1167 + 1U;
    float3 _S1174 = (float4(*(kernelContext_75->state_0+_S1172)) ).xyz - (float4(*(kernelContext_75->state_0+_S1173)) ).xyz;
    uint _S1175 = sv_0(cb_1, 22U, kernelContext_75);
    float3 _S1176 = (float4(*(kernelContext_75->scratch_0+_S1175)) ).xyz;
    uint _S1177 = sv_0(ca_1, 22U, kernelContext_75);
    float3 dth_0 = _S1174 + (_S1176 - (float4(*(kernelContext_75->scratch_0+_S1177)) ).xyz);
    float3 _S1178 = to_local_0(_S1161, du_0 + (cross((float4(*(kernelContext_75->state_0+_S1172)) ).xyz + (float4(*(kernelContext_75->scratch_0+_S1175)) ).xyz, (float4(_S1164->rb_0) ).xyz) - cross((float4(*(kernelContext_75->state_0+_S1173)) ).xyz + (float4(*(kernelContext_75->scratch_0+_S1177)) ).xyz, (float4(_S1164->ra_0) ).xyz)), kernelContext_75);
    *_S1162 = _S1178;
    float3 _S1179 = to_local_0(_S1161, dth_0, kernelContext_75);
    *_S1163 = _S1179;
    return;
}

JointResponse_0 static_response_0(uint i_13, KernelContext_0 thread* kernelContext_76)
{
    BondStatic_natural_0 device* _S1180 = kernelContext_76->bonds_0+i_13;
    thread float3 d_lin_4;
    thread float3 d_ang_3;
    static_kinematics_0(i_13, &d_lin_4, &d_ang_3, kernelContext_76);
    thread JointBond_natural_0 _S1181 = _S1180->law_0;
    _S1181 = _S1180->law_0;
    thread JointState_0 _S1182 = (kernelContext_76->bond_dyn_0+i_13)->js_0;
    JointResponse_0 _S1183 = joint_evaluate_0(&kernelContext_76->materials_0->m_0[(uint4((&_S1181)->ids_0) ).x], &_S1181, &_S1182, d_lin_4, d_ang_3, 0.0f, false);
    return _S1183;
}

void gather_loads_0(uint c_32, float3 thread* fi_3, float3 thread* mi_6, KernelContext_0 thread* kernelContext_77)
{
    float3 _S1184 = float3(0.0f) ;
    *fi_3 = _S1184;
    *mi_6 = _S1184;
    uint e_5 = kernelContext_77->index_0[c_32];
    for(;;)
    {
        if(e_5 < (kernelContext_77->index_0)[c_32 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_4 = kernelContext_77->index_0[e_5];
        uint bond_0 = entry_4 >> 1U;
        if((entry_4 & 1U) == 0U)
        {
            uint _S1185 = 3U * bond_0;
            *fi_3 = *fi_3 + (float4(*(kernelContext_77->scratch_0+_S1185)) ).xyz;
            *mi_6 = *mi_6 + (float4(*(kernelContext_77->scratch_0+(_S1185 + 1U))) ).xyz;
        }
        else
        {
            uint _S1186 = 3U * bond_0;
            *fi_3 = *fi_3 - (float4(*(kernelContext_77->scratch_0+_S1186)) ).xyz;
            *mi_6 = *mi_6 + (float4(*(kernelContext_77->scratch_0+(_S1186 + 2U))) ).xyz;
        }
        e_5 = e_5 + 1U;
    }
    return;
}

float bond_load_magnitude2_0(uint c_33, KernelContext_0 thread* kernelContext_78)
{
    uint e_6 = kernelContext_78->index_0[c_33];
    float m_7 = 0.0f;
    for(;;)
    {
        if(e_6 < (kernelContext_78->index_0)[c_33 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_5 = kernelContext_78->index_0[e_6];
        uint _S1187 = 3U * (entry_5 >> 1U);
        float3 f_18 = (float4(*(kernelContext_78->scratch_0+_S1187)) ).xyz;
        float3 t_18;
        if((entry_5 & 1U) == 0U)
        {
            t_18 = (float4(*(kernelContext_78->scratch_0+(_S1187 + 1U))) ).xyz;
        }
        else
        {
            t_18 = (float4(*(kernelContext_78->scratch_0+(_S1187 + 2U))) ).xyz;
        }
        float m_8 = m_7 + (dot(f_18, f_18) + dot(t_18, t_18));
        e_6 = e_6 + 1U;
        m_7 = m_8;
    }
    return m_7;
}

uint fixed_mask_0(uint c_34, KernelContext_0 thread* kernelContext_79)
{
    uint support_2 = (uint4((kernelContext_79->chunks_0+c_34)->info_1) ).x;
    uint _S1188;
    if(support_2 == 1U)
    {
        _S1188 = 63U;
    }
    else
    {
        if(support_2 == 2U)
        {
            _S1188 = 7U;
        }
        else
        {
            _S1188 = 0U;
        }
    }
    return _S1188;
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

uint statics_bond_slot_0(uint i_14, KernelContext_0 thread* kernelContext_80)
{
    return kernelContext_80->params_0->statics_base_0 + 23U * kernelContext_80->params_0->chunk_count_0 + 2U * i_14;
}

void store_inverse_0(uint c_35, const array<float, int(36)> thread* a_14, KernelContext_0 thread* kernelContext_81)
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
    uint i_15 = 0U;
    for(;;)
    {
        bool _S1189;
        if(i_15 < 6U)
        {
            _S1189 = spd_0;
        }
        else
        {
            _S1189 = false;
        }
        if(_S1189)
        {
        }
        else
        {
            break;
        }
        j_7 = 0U;
        for(;;)
        {
            if(j_7 <= i_15)
            {
            }
            else
            {
                break;
            }
            uint _S1190 = i_15 * 6U;
            uint _S1191 = _S1190 + j_7;
            k_21 = 0U;
            sum_4 = (*a_14)[_S1191];
            for(;;)
            {
                if(k_21 < j_7)
                {
                }
                else
                {
                    break;
                }
                float sum_5 = sum_4 - l_5[_S1190 + k_21] * l_5[j_7 * 6U + k_21];
                k_21 = k_21 + 1U;
                sum_4 = sum_5;
            }
            if(i_15 == j_7)
            {
                if(sum_4 <= 0.0f)
                {
                    spd_0 = false;
                    break;
                }
                l_5[_S1190 + i_15] = sqrt(sum_4);
            }
            else
            {
                l_5[_S1191] = sum_4 / l_5[j_7 * 6U + j_7];
            }
            j_7 = j_7 + 1U;
        }
        i_15 = i_15 + 1U;
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
            uint _S1192 = k_21 * 6U + k_21;
            float _S1193 = (*a_14)[_S1192];
            if(((*a_14)[_S1192]) > 0.0f)
            {
                sum_4 = 1.0f / _S1193;
            }
            else
            {
                sum_4 = 0.0f;
            }
            inv_0[_S1192] = sum_4;
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
            i_15 = 0U;
            for(;;)
            {
                if(i_15 < 6U)
                {
                }
                else
                {
                    break;
                }
                if(i_15 == j_7)
                {
                    sum_4 = 1.0f;
                }
                else
                {
                    sum_4 = 0.0f;
                }
                k_21 = 0U;
                float s_9 = sum_4;
                for(;;)
                {
                    if(k_21 < i_15)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_10 = s_9 - l_5[i_15 * 6U + k_21] * y_3[k_21];
                    k_21 = k_21 + 1U;
                    s_9 = s_10;
                }
                y_3[i_15] = s_9 / l_5[i_15 * 6U + i_15];
                i_15 = i_15 + 1U;
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
                uint i_16 = 5U - ii_2;
                k_21 = i_16 + 1U;
                sum_4 = y_3[i_16];
                for(;;)
                {
                    if(k_21 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_11 = sum_4 - l_5[k_21 * 6U + i_16] * x_11[k_21];
                    k_21 = k_21 + 1U;
                    sum_4 = s_11;
                }
                x_11[i_16] = sum_4 / l_5[i_16 * 6U + i_16];
                ii_2 = ii_2 + 1U;
            }
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
                inv_0[i_17 * 6U + j_7] = x_11[i_17];
                i_17 = i_17 + 1U;
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
        uint _S1194 = sv_0(c_35, 12U + j_7, kernelContext_81);
        uint _S1195 = 4U * j_7;
        *(kernelContext_81->scratch_0+_S1194) = packed_float4(float4(inv_0[_S1195], inv_0[_S1195 + 1U], inv_0[_S1195 + 2U], inv_0[_S1195 + 3U])) ;
        j_7 = j_7 + 1U;
    }
    return;
}

void assemble_block_0(uint c_36, KernelContext_0 thread* kernelContext_82)
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
    uint e_7 = kernelContext_82->index_0[c_36];
    for(;;)
    {
        if(e_7 < (kernelContext_82->index_0)[c_36 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_6 = kernelContext_82->index_0[e_7];
        uint i_18 = entry_6 >> 1U;
        bool _S1196 = (entry_6 & 1U) != 0U;
        BondStatic_natural_0 device* _S1197 = kernelContext_82->bonds_0+i_18;
        uint _S1198 = statics_bond_slot_0(i_18, kernelContext_82);
        float4 _S1199 = float4(*(kernelContext_82->scratch_0+_S1198)) ;
        float4 _S1200 = float4(*(kernelContext_82->scratch_0+(_S1198 + 1U))) ;
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
            uint _S1201 = p_16 % 3U;
            float3 t_19;
            if(_S1201 == 0U)
            {
                t_19 = (float4(_S1197->t1_0) ).xyz;
            }
            else
            {
                if(_S1201 == 1U)
                {
                    t_19 = (float4(_S1197->t2_0) ).xyz;
                }
                else
                {
                    t_19 = (float4(_S1197->normal_0) ).xyz;
                }
            }
            bool _S1202 = p_16 < 3U;
            float3 row_u_0;
            float3 row_t_0;
            if(_S1202)
            {
                if(_S1196)
                {
                    row_u_0 = t_19;
                }
                else
                {
                    row_u_0 = - t_19;
                }
                if(_S1196)
                {
                    row_t_0 = cross((float4(_S1197->rb_0) ).xyz, t_19);
                }
                else
                {
                    row_t_0 = - cross((float4(_S1197->ra_0) ).xyz, t_19);
                }
            }
            else
            {
                float3 _S1203 = float3(0.0f) ;
                if(_S1196)
                {
                    row_u_0 = t_19;
                }
                else
                {
                    row_u_0 = - t_19;
                }
                float3 _S1204 = row_u_0;
                row_u_0 = _S1203;
                row_t_0 = _S1204;
            }
            float kp_0;
            if(_S1202)
            {
                kp_0 = _S1199[p_16];
            }
            else
            {
                kp_0 = _S1200[p_16 - 3U];
            }
            if(kp_0 == 0.0f)
            {
                p_16 = p_16 + 1U;
                continue;
            }
            array<float, int(6)> _S1205 = { { row_u_0.x, row_u_0.y, row_u_0.z, row_t_0.x, row_t_0.y, row_t_0.z } };
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
                    a_15[r_13 * 6U + q_15] = a_15[r_13 * 6U + q_15] + kp_0 * _S1205[r_13] * _S1205[q_15];
                    q_15 = q_15 + 1U;
                }
                r_13 = r_13 + 1U;
            }
            p_16 = p_16 + 1U;
        }
        e_7 = e_7 + 1U;
    }
    uint _S1206 = fixed_mask_0(c_36, kernelContext_82);
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
        if((_S1206 & (1U << p_16)) != 0U)
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
    thread array<float, int(36)> _S1207 = a_15;
    store_inverse_0(c_36, &_S1207, kernelContext_82);
    return;
}

float block_get_0(uint c_37, uint i_19, uint j_8, KernelContext_0 thread* kernelContext_83)
{
    uint k_23 = i_19 * 6U + j_8;
    uint _S1208 = sv_0(c_37, 12U + k_23 / 4U, kernelContext_83);
    return (*(kernelContext_83->scratch_0+_S1208))[k_23 % 4U];
}

void precondition_0(uint c_38, KernelContext_0 thread* kernelContext_84)
{
    uint _S1209 = sv_0(c_38, 4U, kernelContext_84);
    float4 _S1210 = float4(*(kernelContext_84->scratch_0+_S1209)) ;
    uint _S1211 = sv_0(c_38, 5U, kernelContext_84);
    float4 _S1212 = float4(*(kernelContext_84->scratch_0+_S1211)) ;
    array<float, int(6)> _S1213 = { { _S1210.x, _S1210.y, _S1210.z, _S1212.x, _S1212.y, _S1212.z } };
    thread array<float, int(6)> z_1;
    uint i_20 = 0U;
    for(;;)
    {
        if(i_20 < 6U)
        {
        }
        else
        {
            break;
        }
        uint j_9 = 0U;
        float s_12 = 0.0f;
        for(;;)
        {
            if(j_9 < 6U)
            {
            }
            else
            {
                break;
            }
            float _S1214 = block_get_0(c_38, i_20, j_9, kernelContext_84);
            float s_13 = s_12 + _S1214 * _S1213[j_9];
            j_9 = j_9 + 1U;
            s_12 = s_13;
        }
        z_1[i_20] = s_12;
        i_20 = i_20 + 1U;
    }
    uint _S1215 = sv_0(c_38, 6U, kernelContext_84);
    *(kernelContext_84->scratch_0+_S1215) = packed_float4(float4(z_1[int(0)], z_1[int(1)], z_1[int(2)], 0.0f)) ;
    uint _S1216 = sv_0(c_38, 7U, kernelContext_84);
    *(kernelContext_84->scratch_0+_S1216) = packed_float4(float4(z_1[int(3)], z_1[int(4)], z_1[int(5)], 0.0f)) ;
    return;
}

void project_displacement_slot_0(uint tid_17, const Island_natural_0 thread* isl_24, uint slot_5, KernelContext_0 thread* kernelContext_85)
{
    uint _S1217;
    float3 _S1218 = float3(0.0f) ;
    thread float3 p_17 = _S1218;
    thread float3 l_6 = _S1218;
    uint4 _S1219 = uint4(isl_24->range_0) ;
    uint _S1220 = _S1219.x + tid_17;
    uint c_39 = _S1220;
    for(;;)
    {
        uint _S1221 = _S1219.y;
        _S1217 = _S1221;
        if(c_39 < _S1221)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_natural_0 device* _S1222 = kernelContext_85->chunks_0+c_39;
        uint _S1223 = sv_0(c_39, slot_5, kernelContext_85);
        float3 u_6 = (float4(*(kernelContext_85->scratch_0+_S1223)) ).xyz;
        uint _S1224 = sv_0(c_39, slot_5 + 1U, kernelContext_85);
        float3 th_7 = (float4(*(kernelContext_85->scratch_0+_S1224)) ).xyz;
        float4 _S1225 = float4(_S1222->center_0) ;
        float3 r_14 = _S1225.xyz - (float4(isl_24->com_0) ).xyz;
        float3 _S1226 = float3(_S1225.w) ;
        p_17 = p_17 + u_6 * _S1226;
        l_6 = l_6 + (cross(r_14, u_6) * _S1226 + rows_mul_0(float4(_S1222->inertia0_1) , float4(_S1222->inertia1_1) , float4(_S1222->inertia2_1) , th_7));
        c_39 = c_39 + 256U;
    }
    group_sum3_0(tid_17, &p_17, &l_6, kernelContext_85);
    float4 _S1227 = float4(isl_24->com_0) ;
    float3 _S1228 = p_17 / float3(_S1227.w) ;
    float3 _S1229 = rows_mul_0(float4(isl_24->inv0_0) , float4(isl_24->inv1_0) , float4(isl_24->inv2_0) , l_6);
    c_39 = _S1220;
    for(;;)
    {
        if(c_39 < _S1217)
        {
        }
        else
        {
            break;
        }
        float3 r_15 = (float4((kernelContext_85->chunks_0+c_39)->center_0) ).xyz - _S1227.xyz;
        uint _S1230 = sv_0(c_39, slot_5, kernelContext_85);
        *(kernelContext_85->scratch_0+_S1230) = packed_float4(float4((float4(*(kernelContext_85->scratch_0+_S1230)) ).xyz - _S1228 - cross(_S1229, r_15), 0.0f)) ;
        uint _S1231 = sv_0(c_39, slot_5 + 1U, kernelContext_85);
        *(kernelContext_85->scratch_0+_S1231) = packed_float4(float4((float4(*(kernelContext_85->scratch_0+_S1231)) ).xyz - _S1229, 0.0f)) ;
        c_39 = c_39 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    return;
}

uint statics_result_slot_0(uint island_4, KernelContext_0 thread* kernelContext_86)
{
    return kernelContext_86->params_0->statics_base_0 + 23U * kernelContext_86->params_0->chunk_count_0 + 2U * kernelContext_86->params_0->statics_bonds_0 + island_4;
}

void write_bond_loads_0(uint _S1232, uint _S1233, float3 _S1234, float3 _S1235, float _S1236, KernelContext_0 thread* kernelContext_87)
{
    BondStatic_natural_0 device* _S1237 = kernelContext_87->bonds_0+_S1233;
    float3 _S1238 = to_body_0(_S1233, _S1234, kernelContext_87);
    float3 _S1239 = to_body_0(_S1233, _S1235, kernelContext_87);
    uint _S1240 = 3U * _S1232;
    *(kernelContext_87->scratch_0+_S1240) = packed_float4(float4(_S1238, _S1236)) ;
    *(kernelContext_87->scratch_0+(_S1240 + 1U)) = packed_float4(float4(_S1239 + cross((float4(_S1237->ra_0) ).xyz, _S1238), 0.0f)) ;
    *(kernelContext_87->scratch_0+(_S1240 + 2U)) = packed_float4(float4(- _S1239 + cross((float4(_S1237->rb_0) ).xyz, - _S1238), 0.0f)) ;
    return;
}

void bond_kinematics_0(uint _S1241, float3 _S1242, float3 _S1243, float3 _S1244, float3 _S1245, float3 thread* _S1246, float3 thread* _S1247, KernelContext_0 thread* kernelContext_88)
{
    BondStatic_natural_0 device* _S1248 = kernelContext_88->bonds_0+_S1241;
    float3 _S1249 = to_local_0(_S1241, _S1244 + cross(_S1245, (float4(_S1248->rb_0) ).xyz) - (_S1242 + cross(_S1243, (float4(_S1248->ra_0) ).xyz)), kernelContext_88);
    *_S1246 = _S1249;
    float3 _S1250 = to_local_0(_S1241, _S1245 - _S1243, kernelContext_88);
    *_S1247 = _S1250;
    return;
}

[[kernel]] void island_statics(uint3 group_9 [[threadgroup_position_in_grid]], uint3 thread_9 [[thread_position_in_threadgroup]], Params_0 constant* params_13 [[buffer(0)]], Island_natural_0 device* islands_13 [[buffer(9)]], uint device* index_13 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_13 [[buffer(3)]], packed_float4 device* state_15 [[buffer(6)]], packed_float4 device* scratch_13 [[buffer(8)]], packed_float4 device* contact_state_13 [[buffer(11)]], packed_float4 device* loads_13 [[buffer(5)]], Impactor_natural_0 device* impactors_13 [[buffer(10)]], BondStatic_natural_0 device* bonds_13 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_13 [[buffer(7)]], MaterialTable_0 constant* materials_13 [[buffer(1)]])
{
    uint i_21;
    bool converged_0;
    uint c_40;
    thread KernelContext_0 kernelContext_89;
    (&kernelContext_89)->params_0 = params_13;
    (&kernelContext_89)->islands_0 = islands_13;
    (&kernelContext_89)->index_0 = index_13;
    (&kernelContext_89)->chunks_0 = chunks_13;
    (&kernelContext_89)->state_0 = state_15;
    (&kernelContext_89)->scratch_0 = scratch_13;
    (&kernelContext_89)->contact_state_0 = contact_state_13;
    (&kernelContext_89)->loads_0 = loads_13;
    (&kernelContext_89)->impactors_0 = impactors_13;
    (&kernelContext_89)->bonds_0 = bonds_13;
    (&kernelContext_89)->bond_dyn_0 = bond_dyn_13;
    (&kernelContext_89)->materials_0 = materials_13;
    threadgroup array<float4, int(32)> g_part_a_13;
    (&kernelContext_89)->g_part_a_0 = &g_part_a_13;
    threadgroup array<float4, int(32)> g_part_b_13;
    (&kernelContext_89)->g_part_b_0 = &g_part_b_13;
    threadgroup array<uint, int(5)> g_seen_13;
    (&kernelContext_89)->g_seen_0 = &g_seen_13;
    threadgroup uint g_run_13;
    (&kernelContext_89)->g_run_0 = &g_run_13;
    threadgroup uint g_halt_13;
    (&kernelContext_89)->g_halt_0 = &g_halt_13;
    threadgroup uint g_wide_run_13;
    (&kernelContext_89)->g_wide_run_0 = &g_wide_run_13;
    uint tid_18 = thread_9.x;
    uint _S1251 = group_9.x;
    thread Island_natural_0 _S1252 = *(islands_13+_S1251);
    uint4 _S1253 = uint4((&_S1252)->info_0) ;
    uint _S1254 = _S1253.z;
    if((_S1254 & 8U) == 0U)
    {
        return;
    }
    bool free_0 = ((_S1253.x) & 1U) == 0U;
    uint4 _S1255 = uint4((&_S1252)->range_0) ;
    uint c0_1 = _S1255.x;
    uint c1_1 = _S1255.y;
    uint b0_0 = _S1255.z;
    uint _S1256 = _S1255.w;
    uint _S1257 = c0_1 + tid_18;
    uint c_41 = _S1257;
    for(;;)
    {
        if(c_41 < c1_1)
        {
        }
        else
        {
            break;
        }
        uint _S1258 = sv_0(c_41, 21U, &kernelContext_89);
        packed_float4 _S1259 = packed_float4(float4(0.0f) ) ;
        *((&kernelContext_89)->scratch_0+_S1258) = _S1259;
        uint _S1260 = sv_0(c_41, 22U, &kernelContext_89);
        *((&kernelContext_89)->scratch_0+_S1260) = _S1259;
        c_41 = c_41 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    if(free_0)
    {
        project_load_slot_0(tid_18, &_S1252, 0U, &kernelContext_89);
    }
    float _S1261 = island_dot_0(tid_18, c0_1, c1_1, 0U, 0U, &kernelContext_89);
    float _S1262 = max(sqrt(_S1261), 1.00000000317107685e-30f);
    float _S1263 = (&kernelContext_89)->params_0->statics_tol_0;
    uint _S1264 = min((&kernelContext_89)->params_0->statics_cg_0, 20U * (c1_1 - c0_1) * 6U + 200U);
    float previous_2 = 1.00000001504746622e+30f;
    float residual_0 = 0.0f;
    uint newton_0 = 0U;
    uint cg_total_0 = 0U;
    for(;;)
    {
        if(newton_0 < ((&kernelContext_89)->params_0->statics_newton_0))
        {
        }
        else
        {
            converged_0 = false;
            break;
        }
        uint _S1265 = b0_0 + tid_18;
        i_21 = _S1265;
        for(;;)
        {
            if(i_21 < _S1256)
            {
            }
            else
            {
                break;
            }
            JointResponse_0 _S1266 = static_response_0(i_21, &kernelContext_89);
            write_bond_loads_0(i_21, i_21, _S1266.force_lin_1, _S1266.force_ang_1, 0.0f, &kernelContext_89);
            i_21 = i_21 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        float4 _S1267 = float4(0.0f) ;
        thread float4 magnitude_0 = _S1267;
        thread float4 unused_m_0 = _S1267;
        c_41 = _S1257;
        for(;;)
        {
            if(c_41 < c1_1)
            {
            }
            else
            {
                break;
            }
            thread float3 fi_4;
            thread float3 mi_7;
            gather_loads_0(c_41, &fi_4, &mi_7, &kernelContext_89);
            float _S1268 = bond_load_magnitude2_0(c_41, &kernelContext_89);
            magnitude_0.x = magnitude_0.x + _S1268;
            uint _S1269 = sv_0(c_41, 0U, &kernelContext_89);
            thread float4 r_lin_0 = float4((float4(*((&kernelContext_89)->scratch_0+_S1269)) ).xyz + fi_4, 0.0f);
            uint _S1270 = sv_0(c_41, 1U, &kernelContext_89);
            thread float4 r_ang_0 = float4((float4(*((&kernelContext_89)->scratch_0+_S1270)) ).xyz + mi_7, 0.0f);
            uint _S1271 = fixed_mask_0(c_41, &kernelContext_89);
            hold_0(_S1271, &r_lin_0, &r_ang_0, _S1267, _S1267);
            uint _S1272 = sv_0(c_41, 4U, &kernelContext_89);
            *((&kernelContext_89)->scratch_0+_S1272) = packed_float4(r_lin_0) ;
            uint _S1273 = sv_0(c_41, 5U, &kernelContext_89);
            *((&kernelContext_89)->scratch_0+_S1273) = packed_float4(r_ang_0) ;
            c_41 = c_41 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        group_sum2_0(tid_18, &magnitude_0, &unused_m_0, &kernelContext_89);
        if(free_0)
        {
            project_load_slot_0(tid_18, &_S1252, 4U, &kernelContext_89);
        }
        float _S1274 = island_dot_0(tid_18, c0_1, c1_1, 4U, 4U, &kernelContext_89);
        float residual_1 = sqrt(_S1274) / _S1262;
        float _S1275 = max(0.00100000004749745f, 3.83999986297567375e-06f * sqrt(magnitude_0.x) / _S1262);
        if(residual_1 <= _S1263)
        {
            converged_0 = true;
        }
        else
        {
            if(residual_1 <= _S1275)
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
        uint i_22 = _S1265;
        for(;;)
        {
            if(i_22 < _S1256)
            {
            }
            else
            {
                break;
            }
            BondStatic_natural_0 device* _S1276 = (&kernelContext_89)->bonds_0+i_22;
            thread float3 d_lin_5;
            thread float3 d_ang_4;
            static_kinematics_0(i_22, &d_lin_5, &d_ang_4, &kernelContext_89);
            thread JointBond_natural_0 _S1277 = _S1276->law_0;
            thread JointState_0 _S1278 = ((&kernelContext_89)->bond_dyn_0+i_22)->js_0;
            thread float3 f_lin_2;
            thread float3 f_ang_2;
            secant_factors_0(&_S1277, &_S1278, d_lin_5, &f_lin_2, &f_ang_2);
            float4 _S1279 = float4((&_S1277)->stiff0_0) ;
            uint _S1280 = statics_bond_slot_0(i_22, &kernelContext_89);
            float _S1281 = _S1279.y;
            *((&kernelContext_89)->scratch_0+_S1280) = packed_float4(float4(_S1281 * f_lin_2.x, _S1281 * f_lin_2.y, _S1279.x * f_lin_2.z, 0.0f)) ;
            *((&kernelContext_89)->scratch_0+(_S1280 + 1U)) = packed_float4(float4(_S1279.z * f_ang_2.x, _S1279.w * f_ang_2.y, (float4((&_S1277)->stiff1_0) ).x * f_ang_2.z, 0.0f)) ;
            i_22 = i_22 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_42 = _S1257;
        for(;;)
        {
            if(c_42 < c1_1)
            {
            }
            else
            {
                break;
            }
            assemble_block_0(c_42, &kernelContext_89);
            uint _S1282 = sv_0(c_42, 2U, &kernelContext_89);
            packed_float4 _S1283 = packed_float4(_S1267) ;
            *((&kernelContext_89)->scratch_0+_S1282) = _S1283;
            uint _S1284 = sv_0(c_42, 3U, &kernelContext_89);
            *((&kernelContext_89)->scratch_0+_S1284) = _S1283;
            c_42 = c_42 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_43 = _S1257;
        for(;;)
        {
            if(c_43 < c1_1)
            {
            }
            else
            {
                break;
            }
            precondition_0(c_43, &kernelContext_89);
            c_43 = c_43 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        if(free_0)
        {
            project_displacement_slot_0(tid_18, &_S1252, 6U, &kernelContext_89);
        }
        uint c_44 = _S1257;
        for(;;)
        {
            if(c_44 < c1_1)
            {
            }
            else
            {
                break;
            }
            uint _S1285 = sv_0(c_44, 8U, &kernelContext_89);
            packed_float4 device* _S1286 = (&kernelContext_89)->scratch_0+_S1285;
            uint _S1287 = sv_0(c_44, 6U, &kernelContext_89);
            *_S1286 = packed_float4(float4(*((&kernelContext_89)->scratch_0+_S1287)) ) ;
            uint _S1288 = sv_0(c_44, 9U, &kernelContext_89);
            packed_float4 device* _S1289 = (&kernelContext_89)->scratch_0+_S1288;
            uint _S1290 = sv_0(c_44, 7U, &kernelContext_89);
            *_S1289 = packed_float4(float4(*((&kernelContext_89)->scratch_0+_S1290)) ) ;
            c_44 = c_44 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        float _S1291 = island_dot_0(tid_18, c0_1, c1_1, 4U, 6U, &kernelContext_89);
        float _S1292 = island_dot_0(tid_18, c0_1, c1_1, 4U, 4U, &kernelContext_89);
        float _S1293 = sqrt(_S1292);
        float rz_0 = _S1291;
        uint k_24 = 0U;
        uint cg_total_1 = cg_total_0;
        for(;;)
        {
            bool _S1294;
            if(k_24 < _S1264)
            {
                _S1294 = _S1293 > 0.0f;
            }
            else
            {
                _S1294 = false;
            }
            if(_S1294)
            {
            }
            else
            {
                cg_total_0 = cg_total_1;
                break;
            }
            uint i_23 = _S1265;
            for(;;)
            {
                if(i_23 < _S1256)
                {
                }
                else
                {
                    break;
                }
                uint4 _S1295 = uint4(((&kernelContext_89)->bonds_0+i_23)->law_0.ids_0) ;
                uint ca_2 = _S1295.y;
                uint cb_2 = _S1295.z;
                uint _S1296 = sv_0(ca_2, 8U, &kernelContext_89);
                float3 _S1297 = (float4(*((&kernelContext_89)->scratch_0+_S1296)) ).xyz;
                uint _S1298 = sv_0(ca_2, 9U, &kernelContext_89);
                float3 _S1299 = (float4(*((&kernelContext_89)->scratch_0+_S1298)) ).xyz;
                uint _S1300 = sv_0(cb_2, 8U, &kernelContext_89);
                float3 _S1301 = (float4(*((&kernelContext_89)->scratch_0+_S1300)) ).xyz;
                uint _S1302 = sv_0(cb_2, 9U, &kernelContext_89);
                thread float3 d_lin_6;
                thread float3 d_ang_5;
                bond_kinematics_0(i_23, _S1297, _S1299, _S1301, (float4(*((&kernelContext_89)->scratch_0+_S1302)) ).xyz, &d_lin_6, &d_ang_5, &kernelContext_89);
                uint _S1303 = statics_bond_slot_0(i_23, &kernelContext_89);
                write_bond_loads_0(i_23, i_23, d_lin_6 * (float4(*((&kernelContext_89)->scratch_0+_S1303)) ).xyz, d_ang_5 * (float4(*((&kernelContext_89)->scratch_0+(_S1303 + 1U))) ).xyz, 0.0f, &kernelContext_89);
                i_23 = i_23 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            c_40 = _S1257;
            for(;;)
            {
                if(c_40 < c1_1)
                {
                }
                else
                {
                    break;
                }
                thread float3 fi_5;
                thread float3 mi_8;
                gather_loads_0(c_40, &fi_5, &mi_8, &kernelContext_89);
                thread float4 ap_lin_0 = float4(- fi_5, 0.0f);
                thread float4 ap_ang_0 = float4(- mi_8, 0.0f);
                uint _S1304 = fixed_mask_0(c_40, &kernelContext_89);
                uint _S1305 = sv_0(c_40, 8U, &kernelContext_89);
                float4 _S1306 = float4(*((&kernelContext_89)->scratch_0+_S1305)) ;
                uint _S1307 = sv_0(c_40, 9U, &kernelContext_89);
                hold_0(_S1304, &ap_lin_0, &ap_ang_0, _S1306, float4(*((&kernelContext_89)->scratch_0+_S1307)) );
                uint _S1308 = sv_0(c_40, 10U, &kernelContext_89);
                *((&kernelContext_89)->scratch_0+_S1308) = packed_float4(ap_lin_0) ;
                uint _S1309 = sv_0(c_40, 11U, &kernelContext_89);
                *((&kernelContext_89)->scratch_0+_S1309) = packed_float4(ap_ang_0) ;
                c_40 = c_40 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            float _S1310 = island_dot_0(tid_18, c0_1, c1_1, 8U, 10U, &kernelContext_89);
            uint _S1311 = cg_total_1 + 1U;
            if(_S1310 <= 0.0f)
            {
                cg_total_0 = _S1311;
                break;
            }
            float _S1312 = rz_0 / _S1310;
            uint c_45 = _S1257;
            for(;;)
            {
                if(c_45 < c1_1)
                {
                }
                else
                {
                    break;
                }
                uint _S1313 = sv_0(c_45, 2U, &kernelContext_89);
                packed_float4 device* _S1314 = (&kernelContext_89)->scratch_0+_S1313;
                float3 _S1315 = (float4(*((&kernelContext_89)->scratch_0+_S1313)) ).xyz;
                uint _S1316 = sv_0(c_45, 8U, &kernelContext_89);
                float3 _S1317 = float3(_S1312) ;
                *_S1314 = packed_float4(float4(_S1315 + _S1317 * (float4(*((&kernelContext_89)->scratch_0+_S1316)) ).xyz, 0.0f)) ;
                uint _S1318 = sv_0(c_45, 3U, &kernelContext_89);
                packed_float4 device* _S1319 = (&kernelContext_89)->scratch_0+_S1318;
                float3 _S1320 = (float4(*((&kernelContext_89)->scratch_0+_S1318)) ).xyz;
                uint _S1321 = sv_0(c_45, 9U, &kernelContext_89);
                *_S1319 = packed_float4(float4(_S1320 + _S1317 * (float4(*((&kernelContext_89)->scratch_0+_S1321)) ).xyz, 0.0f)) ;
                uint _S1322 = sv_0(c_45, 4U, &kernelContext_89);
                packed_float4 device* _S1323 = (&kernelContext_89)->scratch_0+_S1322;
                float3 _S1324 = (float4(*((&kernelContext_89)->scratch_0+_S1322)) ).xyz;
                uint _S1325 = sv_0(c_45, 10U, &kernelContext_89);
                *_S1323 = packed_float4(float4(_S1324 - _S1317 * (float4(*((&kernelContext_89)->scratch_0+_S1325)) ).xyz, 0.0f)) ;
                uint _S1326 = sv_0(c_45, 5U, &kernelContext_89);
                packed_float4 device* _S1327 = (&kernelContext_89)->scratch_0+_S1326;
                float3 _S1328 = (float4(*((&kernelContext_89)->scratch_0+_S1326)) ).xyz;
                uint _S1329 = sv_0(c_45, 11U, &kernelContext_89);
                *_S1327 = packed_float4(float4(_S1328 - _S1317 * (float4(*((&kernelContext_89)->scratch_0+_S1329)) ).xyz, 0.0f)) ;
                c_45 = c_45 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            float _S1330 = island_dot_0(tid_18, c0_1, c1_1, 4U, 4U, &kernelContext_89);
            if((sqrt(_S1330)) <= (0.00009999999747379f * _S1293))
            {
                cg_total_0 = _S1311;
                break;
            }
            uint c_46 = _S1257;
            for(;;)
            {
                if(c_46 < c1_1)
                {
                }
                else
                {
                    break;
                }
                precondition_0(c_46, &kernelContext_89);
                c_46 = c_46 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            if(free_0)
            {
                project_displacement_slot_0(tid_18, &_S1252, 6U, &kernelContext_89);
            }
            float _S1331 = island_dot_0(tid_18, c0_1, c1_1, 4U, 6U, &kernelContext_89);
            float _S1332 = _S1331 / rz_0;
            uint c_47 = _S1257;
            for(;;)
            {
                if(c_47 < c1_1)
                {
                }
                else
                {
                    break;
                }
                uint _S1333 = sv_0(c_47, 8U, &kernelContext_89);
                packed_float4 device* _S1334 = (&kernelContext_89)->scratch_0+_S1333;
                uint _S1335 = sv_0(c_47, 6U, &kernelContext_89);
                float3 _S1336 = float3(_S1332) ;
                *_S1334 = packed_float4(float4((float4(*((&kernelContext_89)->scratch_0+_S1335)) ).xyz + _S1336 * (float4(*((&kernelContext_89)->scratch_0+_S1333)) ).xyz, 0.0f)) ;
                uint _S1337 = sv_0(c_47, 9U, &kernelContext_89);
                packed_float4 device* _S1338 = (&kernelContext_89)->scratch_0+_S1337;
                uint _S1339 = sv_0(c_47, 7U, &kernelContext_89);
                *_S1338 = packed_float4(float4((float4(*((&kernelContext_89)->scratch_0+_S1339)) ).xyz + _S1336 * (float4(*((&kernelContext_89)->scratch_0+_S1337)) ).xyz, 0.0f)) ;
                c_47 = c_47 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            uint _S1340 = k_24 + 1U;
            rz_0 = _S1331;
            k_24 = _S1340;
            cg_total_1 = _S1311;
        }
        c_40 = _S1257;
        for(;;)
        {
            if(c_40 < c1_1)
            {
            }
            else
            {
                break;
            }
            uint _S1341 = 4U * c_40;
            thread float3 u_7 = (float4(*((&kernelContext_89)->state_0+_S1341)) ).xyz;
            uint _S1342 = sv_0(c_40, 21U, &kernelContext_89);
            thread float3 u_lo_0 = (float4(*((&kernelContext_89)->scratch_0+_S1342)) ).xyz;
            uint _S1343 = _S1341 + 1U;
            thread float3 th_8 = (float4(*((&kernelContext_89)->state_0+_S1343)) ).xyz;
            uint _S1344 = sv_0(c_40, 22U, &kernelContext_89);
            thread float3 th_lo_0 = (float4(*((&kernelContext_89)->scratch_0+_S1344)) ).xyz;
            uint _S1345 = sv_0(c_40, 2U, &kernelContext_89);
            comp_add_0(&u_7, &u_lo_0, (float4(*((&kernelContext_89)->scratch_0+_S1345)) ).xyz);
            uint _S1346 = sv_0(c_40, 3U, &kernelContext_89);
            comp_add_0(&th_8, &th_lo_0, (float4(*((&kernelContext_89)->scratch_0+_S1346)) ).xyz);
            *((&kernelContext_89)->state_0+_S1341) = packed_float4(float4(u_7, (float4(*((&kernelContext_89)->state_0+_S1341)) ).w)) ;
            *((&kernelContext_89)->state_0+_S1343) = packed_float4(float4(th_8, (float4(*((&kernelContext_89)->state_0+_S1343)) ).w)) ;
            *((&kernelContext_89)->scratch_0+_S1342) = packed_float4(float4(u_lo_0, 0.0f)) ;
            *((&kernelContext_89)->scratch_0+_S1344) = packed_float4(float4(th_lo_0, 0.0f)) ;
            c_40 = c_40 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint _S1347 = newton_0 + 1U;
        previous_2 = residual_1;
        residual_0 = residual_1;
        newton_0 = _S1347;
    }
    i_21 = b0_0 + tid_18;
    for(;;)
    {
        if(i_21 < _S1256)
        {
        }
        else
        {
            break;
        }
        JointResponse_0 _S1348 = static_response_0(i_21, &kernelContext_89);
        BondDyn_natural_0 device* _S1349 = (&kernelContext_89)->bond_dyn_0+i_21;
        float4 _S1350 = float4((*_S1349).force_lin_0) ;
        float4 _S1351 = float4((*_S1349).force_ang_0) ;
        float4 _S1352 = float4((*_S1349).sums_0) ;
        float4 _S1353 = float4((*_S1349).comps_0) ;
        uint4 _S1354 = uint4((*_S1349).events_0) ;
        thread BondDyn_0 bd_1;
        (&bd_1)->js_0 = (*_S1349).js_0;
        (&bd_1)->force_lin_0 = _S1350;
        (&bd_1)->force_ang_0 = _S1351;
        (&bd_1)->sums_0 = _S1352;
        (&bd_1)->comps_0 = _S1353;
        (&bd_1)->events_0 = _S1354;
        (&bd_1)->force_lin_0 = float4(_S1348.force_lin_1, _S1348.stored_5);
        (&bd_1)->force_ang_0 = float4(_S1348.force_ang_1, (&bd_1)->force_ang_0.w);
        BondDyn_natural_0 device* _S1355 = (&kernelContext_89)->bond_dyn_0+i_21;
        _S1355->js_0 = bd_1.js_0;
        _S1355->force_lin_0 = packed_float4(bd_1.force_lin_0) ;
        _S1355->force_ang_0 = packed_float4(bd_1.force_ang_0) ;
        _S1355->sums_0 = packed_float4(bd_1.sums_0) ;
        _S1355->comps_0 = packed_float4(bd_1.comps_0) ;
        _S1355->events_0 = packed_uint4(bd_1.events_0) ;
        write_bond_loads_0(i_21, i_21, _S1348.force_lin_1, _S1348.force_ang_1, max(_S1348.measures_0.tension_0, _S1348.measures_0.compression_0), &kernelContext_89);
        i_21 = i_21 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    c_41 = _S1257;
    for(;;)
    {
        if(c_41 < c1_1)
        {
        }
        else
        {
            break;
        }
        thread float3 fi_6;
        thread float3 mi_9;
        gather_loads_0(c_41, &fi_6, &mi_9, &kernelContext_89);
        uint _S1356 = fixed_mask_0(c_41, &kernelContext_89);
        float3 reaction_2;
        if(_S1356 != 0U)
        {
            uint _S1357 = sv_0(c_41, 0U, &kernelContext_89);
            reaction_2 = - ((float4(*((&kernelContext_89)->scratch_0+_S1357)) ).xyz + fi_6);
        }
        else
        {
            uint _S1358 = 4U * c_41;
            reaction_2 = float3((float4(*((&kernelContext_89)->state_0+(_S1358 + 1U))) ).w, (float4(*((&kernelContext_89)->state_0+(_S1358 + 2U))) ).w, (float4(*((&kernelContext_89)->state_0+(_S1358 + 3U))) ).w);
        }
        uint _S1359 = 4U * c_41;
        uint _S1360 = _S1359 + 1U;
        *((&kernelContext_89)->state_0+_S1360) = packed_float4(float4((float4(*((&kernelContext_89)->state_0+_S1360)) ).xyz, reaction_2.x)) ;
        *((&kernelContext_89)->state_0+(_S1359 + 2U)) = packed_float4(float4(0.0f, 0.0f, 0.0f, reaction_2.y)) ;
        *((&kernelContext_89)->state_0+(_S1359 + 3U)) = packed_float4(float4(0.0f, 0.0f, 0.0f, reaction_2.z)) ;
        c_41 = c_41 + 256U;
    }
    if(tid_18 == 0U)
    {
        uint _S1361 = statics_result_slot_0(_S1251, &kernelContext_89);
        packed_float4 device* _S1362 = (&kernelContext_89)->scratch_0+_S1361;
        float _S1363 = (as_type<float>((newton_0)));
        float _S1364 = (as_type<float>((cg_total_0)));
        if(converged_0)
        {
            previous_2 = 1.0f;
        }
        else
        {
            previous_2 = 0.0f;
        }
        *_S1362 = packed_float4(float4(residual_0, _S1363, _S1364, previous_2)) ;
        ((&kernelContext_89)->islands_0+_S1251)->info_0[int(2)] = _S1254 & 4294967287U;
    }
    return;
}

[[kernel]] void settled_fatigue(uint3 group_10 [[threadgroup_position_in_grid]], uint3 thread_10 [[thread_position_in_threadgroup]], Params_0 constant* params_14 [[buffer(0)]], Island_natural_0 device* islands_14 [[buffer(9)]], uint device* index_14 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_14 [[buffer(3)]], packed_float4 device* state_16 [[buffer(6)]], packed_float4 device* scratch_14 [[buffer(8)]], packed_float4 device* contact_state_14 [[buffer(11)]], packed_float4 device* loads_14 [[buffer(5)]], Impactor_natural_0 device* impactors_14 [[buffer(10)]], BondStatic_natural_0 device* bonds_14 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_14 [[buffer(7)]], MaterialTable_0 constant* materials_14 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_90;
    (&kernelContext_90)->params_0 = params_14;
    (&kernelContext_90)->islands_0 = islands_14;
    (&kernelContext_90)->index_0 = index_14;
    (&kernelContext_90)->chunks_0 = chunks_14;
    (&kernelContext_90)->state_0 = state_16;
    (&kernelContext_90)->scratch_0 = scratch_14;
    (&kernelContext_90)->contact_state_0 = contact_state_14;
    (&kernelContext_90)->loads_0 = loads_14;
    (&kernelContext_90)->impactors_0 = impactors_14;
    (&kernelContext_90)->bonds_0 = bonds_14;
    (&kernelContext_90)->bond_dyn_0 = bond_dyn_14;
    (&kernelContext_90)->materials_0 = materials_14;
    threadgroup array<float4, int(32)> g_part_a_14;
    (&kernelContext_90)->g_part_a_0 = &g_part_a_14;
    threadgroup array<float4, int(32)> g_part_b_14;
    (&kernelContext_90)->g_part_b_0 = &g_part_b_14;
    threadgroup array<uint, int(5)> g_seen_14;
    (&kernelContext_90)->g_seen_0 = &g_seen_14;
    threadgroup uint g_run_14;
    (&kernelContext_90)->g_run_0 = &g_run_14;
    threadgroup uint g_halt_14;
    (&kernelContext_90)->g_halt_0 = &g_halt_14;
    threadgroup uint g_wide_run_14;
    (&kernelContext_90)->g_wide_run_0 = &g_wide_run_14;
    uint tid_19 = thread_10.x;
    uint _S1365 = group_10.x;
    Island_natural_0 device* _S1366 = islands_14+_S1365;
    Island_natural_0 isl_25 = *_S1366;
    uint4 _S1367 = uint4((*_S1366).info_0) ;
    bool _S1368;
    if(((_S1367.x) & 16U) == 0U)
    {
        _S1368 = true;
    }
    else
    {
        uint4 _S1369 = uint4(isl_25.range_0) ;
        _S1368 = (_S1369.w) == (_S1369.z);
    }
    if(_S1368)
    {
        return;
    }
    seen_clear_0(tid_19, &kernelContext_90);
    if(tid_19 == 0U)
    {
        *(&kernelContext_90)->g_halt_0 = 0U;
        *(&kernelContext_90)->g_run_0 = 0U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    uint _S1370 = _S1367.w;
    uint4 _S1371 = uint4(isl_25.range_0) ;
    uint i_24 = _S1371.z + tid_19;
    for(;;)
    {
        if(i_24 < (_S1371.w))
        {
        }
        else
        {
            break;
        }
        BondStatic_natural_0 device* _S1372 = (&kernelContext_90)->bonds_0+i_24;
        BondDyn_natural_0 device* _S1373 = (&kernelContext_90)->bond_dyn_0+i_24;
        float4 _S1374 = float4((*_S1373).force_lin_0) ;
        float4 _S1375 = float4((*_S1373).force_ang_0) ;
        float4 _S1376 = float4((*_S1373).sums_0) ;
        float4 _S1377 = float4((*_S1373).comps_0) ;
        uint4 _S1378 = uint4((*_S1373).events_0) ;
        thread BondDyn_0 bd_2;
        (&bd_2)->js_0 = (*_S1373).js_0;
        (&bd_2)->force_lin_0 = _S1374;
        (&bd_2)->force_ang_0 = _S1375;
        (&bd_2)->sums_0 = _S1376;
        (&bd_2)->comps_0 = _S1377;
        (&bd_2)->events_0 = _S1378;
        thread JointBond_natural_0 _S1379 = _S1372->law_0;
        uint4 _S1380 = uint4((&_S1379)->ids_0) ;
        uint _S1381 = 4U * _S1380.y;
        uint _S1382 = 4U * _S1380.z;
        thread float3 d_lin_7;
        thread float3 d_ang_6;
        bond_kinematics_0(i_24, (float4(*((&kernelContext_90)->state_0+_S1381)) ).xyz, (float4(*((&kernelContext_90)->state_0+(_S1381 + 1U))) ).xyz, (float4(*((&kernelContext_90)->state_0+_S1382)) ).xyz, (float4(*((&kernelContext_90)->state_0+(_S1382 + 1U))) ).xyz, &d_lin_7, &d_ang_6, &kernelContext_90);
        JointState_0 previous_3 = (&bd_2)->js_0;
        float _S1383 = (&kernelContext_90)->params_0->dt_0;
        bool _S1384 = ((&kernelContext_90)->params_0->fracture_0) != 0U;
        _S1379 = _S1372->law_0;
        thread JointState_0 _S1385 = (&bd_2)->js_0;
        JointResponse_0 _S1386 = joint_evaluate_0(&(&kernelContext_90)->materials_0->m_0[_S1380.x], &_S1379, &_S1385, d_lin_7, d_ang_6, _S1383, _S1384);
        if((_S1386.state_6.damage_0) > (previous_3.damage_0 + 9.99999971718068537e-10f))
        {
            _S1368 = true;
        }
        else
        {
            _S1368 = (_S1386.state_6.crush_1) > (previous_3.crush_1 + 9.99999971718068537e-10f);
        }
        uint flags_3;
        if(_S1368)
        {
            flags_3 = 16U;
        }
        else
        {
            flags_3 = 0U;
        }
        thread float _S1387 = (&bd_2)->sums_0.x;
        thread float _S1388 = (&bd_2)->comps_0.x;
        comp_add1_0(&_S1387, &_S1388, _S1386.dissipated_2);
        (&bd_2)->comps_0.x = _S1388;
        (&bd_2)->sums_0.x = _S1387;
        thread float _S1389 = (&bd_2)->sums_0.y;
        thread float _S1390 = (&bd_2)->comps_0.y;
        comp_add1_0(&_S1389, &_S1390, _S1386.overshoot_0);
        (&bd_2)->comps_0.y = _S1390;
        (&bd_2)->sums_0.y = _S1389;
        (&bd_2)->force_lin_0 = float4(_S1386.force_lin_1, _S1386.stored_5);
        (&bd_2)->force_ang_0 = float4(_S1386.force_ang_1, max((&bd_2)->force_ang_0.w, _S1386.state_6.utilization_0));
        thread JointState_0 _S1391 = previous_3;
        bool _S1392 = is_damaged_0(&_S1391);
        bool _S1393;
        if(!_S1392)
        {
            thread JointState_0 _S1394 = _S1386.state_6;
            bool _S1395 = is_damaged_0(&_S1394);
            _S1393 = _S1395;
        }
        else
        {
            _S1393 = false;
        }
        bool _S1396;
        if(_S1393)
        {
            _S1396 = ((&bd_2)->events_0.x) == 0U;
        }
        else
        {
            _S1396 = false;
        }
        if(_S1396)
        {
            (&bd_2)->events_0.x = _S1370;
            (&bd_2)->events_0.w = _S1386.state_6.mode_0;
            (*(&kernelContext_90)->g_seen_0)[3U] = 1U;
        }
        bool _S1397;
        if(((&bd_2)->events_0.y) == 0U)
        {
            float _S1398 = fatigue_factor_0(&(&kernelContext_90)->materials_0->m_0[_S1380.x], previous_3.life_0);
            _S1397 = _S1398 > 0.99000000953674316f;
        }
        else
        {
            _S1397 = false;
        }
        bool _S1399;
        if(_S1397)
        {
            float _S1400 = fatigue_factor_0(&(&kernelContext_90)->materials_0->m_0[_S1380.x], _S1386.state_6.life_0);
            _S1399 = _S1400 <= 0.99000000953674316f;
        }
        else
        {
            _S1399 = false;
        }
        if(_S1399)
        {
            (&bd_2)->events_0.y = _S1370;
            (*(&kernelContext_90)->g_seen_0)[4U] = 1U;
        }
        uint flags_4;
        if(_S1386.disconnected_0)
        {
            (&bd_2)->events_0.z = _S1370;
            flags_4 = flags_3 | 32U;
        }
        else
        {
            flags_4 = flags_3;
        }
        (&bd_2)->js_0 = _S1386.state_6;
        BondDyn_natural_0 device* _S1401 = (&kernelContext_90)->bond_dyn_0+i_24;
        _S1401->js_0 = bd_2.js_0;
        _S1401->force_lin_0 = packed_float4(bd_2.force_lin_0) ;
        _S1401->force_ang_0 = packed_float4(bd_2.force_ang_0) ;
        _S1401->sums_0 = packed_float4(bd_2.sums_0) ;
        _S1401->comps_0 = packed_float4(bd_2.comps_0) ;
        _S1401->events_0 = packed_uint4(bd_2.events_0) ;
        write_bond_loads_0(i_24, i_24, _S1386.force_lin_1, _S1386.force_ang_1, max(_S1386.measures_0.tension_0, _S1386.measures_0.compression_0), &kernelContext_90);
        if((flags_4 & 16U) != 0U)
        {
            *(&kernelContext_90)->g_halt_0 = 1U;
        }
        if((flags_4 & 32U) != 0U)
        {
            *(&kernelContext_90)->g_run_0 = 1U;
        }
        i_24 = i_24 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    if(tid_19 != 0U)
    {
        return;
    }
    if(((*(&kernelContext_90)->g_halt_0) | (*(&kernelContext_90)->g_run_0)) != 0U)
    {
        uint _S1402 = _S1367.z;
        if((*(&kernelContext_90)->g_halt_0) != 0U)
        {
            i_24 = 16U;
        }
        else
        {
            i_24 = 0U;
        }
        uint _S1403 = _S1402 | i_24;
        if((*(&kernelContext_90)->g_run_0) != 0U)
        {
            i_24 = 32U;
        }
        else
        {
            i_24 = 0U;
        }
        ((&kernelContext_90)->islands_0+_S1365)->info_0[int(2)] = _S1403 | i_24;
    }
    uint _S1404 = (isl_25.coverage_0) | 16384U;
    uint _S1405 = seen_bits_0(&kernelContext_90);
    uint _S1406 = _S1404 | _S1405;
    if((*(&kernelContext_90)->g_run_0) != 0U)
    {
        i_24 = 128U;
    }
    else
    {
        i_24 = 0U;
    }
    ((&kernelContext_90)->islands_0+_S1365)->coverage_0 = _S1406 | i_24;
    return;
}

