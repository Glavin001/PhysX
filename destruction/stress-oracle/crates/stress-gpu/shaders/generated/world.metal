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
    packed_uint4 done_0;
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

void pair_contact_0(uint i_3, KernelContext_0 thread* kernelContext_13)
{
    uint at_0 = kernelContext_13->params_0->pair_index_0 + 6U * i_3;
    uint ca_0 = kernelContext_13->index_0[at_0];
    uint cb_0 = kernelContext_13->index_0[at_0 + 1U];
    uint _S110 = kernelContext_13->index_0[at_0 + 3U];
    float _S111 = (as_type<float>((kernelContext_13->index_0[at_0 + 4U])));
    float _S112 = (as_type<float>((kernelContext_13->index_0[at_0 + 5U])));
    float _S113 = kernelContext_13->params_0->dt_0;
    uint out_0 = kernelContext_13->params_0->slot_base_0 + 2U * kernelContext_13->index_0[at_0 + 2U];
    WorldPoint_0 _S114 = chunk_world_0(ca_0, kernelContext_13);
    WorldPoint_0 _S115 = chunk_world_0(cb_0, kernelContext_13);
    thread WorldPoint_0 _S116 = _S115;
    thread WorldPoint_0 _S117 = _S114;
    float3 _S118 = world_diff_0(&_S116, &_S117);
    bool touching_0 = !((length(_S118)) > ((float4((kernelContext_13->chunks_0+ca_0)->half_0) ).w + (float4((kernelContext_13->chunks_0+cb_0)->half_0) ).w));
    float4 _S119 = float4(*(kernelContext_13->scratch_0+(kernelContext_13->params_0->ledger_base_0 + i_3))) ;
    thread float4 ledger_1 = _S119;
    uint flags_0 = (as_type<uint>((_S119.w)));
    float3 _S120 = float3(0.0f) ;
    Box_0 _S121 = chunk_box_0(ca_0, _S120, kernelContext_13);
    Box_0 _S122 = chunk_box_0(cb_0, _S118, kernelContext_13);
    thread Box_0 _S123 = _S121;
    uint _S124 = sample_count_0(&_S123);
    thread Box_0 _S125 = _S122;
    uint _S126 = sample_count_0(&_S125);
    uint _S127 = _S124 + _S126;
    uint e_1;
    bool has_state_0;
    if(!touching_0)
    {
        if((flags_0 & 1U) != 0U)
        {
            e_1 = 0U;
            for(;;)
            {
                if(e_1 < _S127)
                {
                }
                else
                {
                    break;
                }
                *(kernelContext_13->contact_state_0+(_S110 + e_1)) = packed_float4(float4((as_type<float>((2143289344U))), 0.0f, 0.0f, 0.0f)) ;
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
                *(kernelContext_13->scratch_0+(out_0 + e_1)) = packed_float4(float4(0.0f) ) ;
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
            *(kernelContext_13->scratch_0+(kernelContext_13->params_0->ledger_base_0 + i_3)) = packed_float4(ledger_1) ;
        }
        return;
    }
    thread Box_0 _S128 = _S121;
    thread Box_0 _S129 = _S122;
    bool _S130 = may_overlap_0(&_S128, &_S129);
    uint count_0;
    float3 fa_0;
    float3 ta_0;
    float3 fb_0;
    float3 tb_0;
    float stored_sum_0;
    if(_S130)
    {
        thread float3 va0_0;
        thread float3 wa0_0;
        chunk_velocity_0(ca_0, &va0_0, &wa0_0, kernelContext_13);
        thread float3 vb0_0;
        thread float3 wb0_0;
        chunk_velocity_0(cb_0, &vb0_0, &wb0_0, kernelContext_13);
        e_1 = 0U;
        count_0 = 0U;
        uint engaged_0 = 0U;
        for(;;)
        {
            if(e_1 < _S127)
            {
            }
            else
            {
                break;
            }
            thread Box_0 _S131 = _S121;
            thread Box_0 _S132 = _S122;
            thread float3 p_3;
            thread float3 n_2;
            thread float d_6;
            bool _S133 = pair_point_0(&_S131, &_S132, _S124, e_1, &p_3, &n_2, &d_6, kernelContext_13);
            if(!_S133)
            {
                uint _S134 = _S110 + e_1;
                if(!is_nan_0((float4(*(kernelContext_13->contact_state_0+_S134)) ).x))
                {
                    *(kernelContext_13->contact_state_0+_S134) = packed_float4(float4((as_type<float>((2143289344U))), 0.0f, 0.0f, 0.0f)) ;
                }
                e_1 = e_1 + 1U;
                continue;
            }
            uint _S135 = count_0 + 1U;
            uint _S136 = _S110 + e_1;
            float4 _S137 = float4(*(kernelContext_13->contact_state_0+_S136)) ;
            thread float4 entry_0 = _S137;
            if(is_nan_0(_S137.x))
            {
                has_state_0 = true;
            }
            else
            {
                has_state_0 = (dot(entry_0.yzw, n_2)) < 0.99000000953674316f;
            }
            if(has_state_0)
            {
                if(d_6 > (2.0f * abs(dot(va0_0 + cross(wa0_0, p_3) - (vb0_0 + cross(wb0_0, p_3 - _S122.center_1)), n_2)) * _S113 + 9.99999971718068537e-10f))
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
            *(kernelContext_13->contact_state_0+_S136) = packed_float4(entry_0) ;
            uint engaged_1;
            if((d_6 - entry_0.x) > 0.0f)
            {
                engaged_1 = engaged_0 + 1U;
            }
            else
            {
                engaged_1 = engaged_0;
            }
            count_0 = _S135;
            engaged_0 = engaged_1;
            e_1 = e_1 + 1U;
        }
        if(count_0 > 0U)
        {
            float _S138 = (float4((kernelContext_13->chunks_0+ca_0)->cmat_0) ).x;
            float _S139 = (float4((kernelContext_13->chunks_0+cb_0)->cmat_0) ).x;
            float3 _S140 = _S122.center_1 - _S121.center_1;
            thread Box_0 _S141 = _S121;
            thread Box_0 _S142 = _S122;
            float _S143 = contact_stiffness_0(_S138, &_S141, _S139, &_S142, _S140);
            float _S144 = _S143 / max(float(engaged_0), 10.0f);
            e_1 = 0U;
            fa_0 = _S120;
            ta_0 = _S120;
            fb_0 = _S120;
            tb_0 = _S120;
            stored_sum_0 = 0.0f;
            for(;;)
            {
                if(e_1 < _S127)
                {
                }
                else
                {
                    break;
                }
                thread Box_0 _S145 = _S121;
                thread Box_0 _S146 = _S122;
                thread float3 p_4;
                thread float3 n_3;
                thread float d_7;
                bool _S147 = pair_point_0(&_S145, &_S146, _S124, e_1, &p_4, &n_3, &d_7, kernelContext_13);
                if(!_S147)
                {
                    e_1 = e_1 + 1U;
                    continue;
                }
                float eff_0 = d_7 - (float4(*(kernelContext_13->contact_state_0+(_S110 + e_1))) ).x;
                if(eff_0 <= 0.0f)
                {
                    e_1 = e_1 + 1U;
                    continue;
                }
                thread float stored_1;
                thread float diss_0;
                float3 _S148 = penalty_force_0(_S144, _S111, _S112, eff_0, n_3, va0_0 + cross(wa0_0, p_4) - (vb0_0 + cross(wb0_0, p_4 - _S122.center_1)), _S113, engaged_0, &stored_1, &diss_0, kernelContext_13);
                float3 fa_1 = fa_0 + _S148;
                float3 ta_1 = ta_0 + cross(p_4, _S148);
                float3 _S149 = - _S148;
                float3 fb_1 = fb_0 + _S149;
                float3 tb_1 = tb_0 + cross(p_4 - _S122.center_1, _S149);
                float stored_sum_1 = stored_sum_0 + stored_1;
                thread float _S150 = ledger_1.y;
                thread float _S151 = ledger_1.z;
                comp_add1_0(&_S150, &_S151, diss_0);
                ledger_1.z = _S151;
                ledger_1.y = _S150;
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
            fa_0 = _S120;
            ta_0 = _S120;
            fb_0 = _S120;
            tb_0 = _S120;
            stored_sum_0 = 0.0f;
        }
    }
    else
    {
        has_state_0 = false;
        fa_0 = _S120;
        ta_0 = _S120;
        fb_0 = _S120;
        tb_0 = _S120;
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
            if(e_1 < _S127)
            {
            }
            else
            {
                break;
            }
            *(kernelContext_13->contact_state_0+(_S110 + e_1)) = packed_float4(float4((as_type<float>((2143289344U))), 0.0f, 0.0f, 0.0f)) ;
            e_1 = e_1 + 1U;
        }
    }
    float3 _S152 = float3(0.0f) ;
    if(any(fa_0 != _S152))
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any(ta_0 != _S152);
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any(fb_0 != _S152);
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any(tb_0 != _S152);
    }
    bool _S153;
    if(loaded_0)
    {
        _S153 = true;
    }
    else
    {
        _S153 = (flags_0 & 2U) != 0U;
    }
    if(_S153)
    {
        *(kernelContext_13->scratch_0+out_0) = packed_float4(float4(fa_0, 0.0f)) ;
        *(kernelContext_13->scratch_0+(out_0 + 1U)) = packed_float4(float4(ta_0, 0.0f)) ;
        *(kernelContext_13->scratch_0+(out_0 + 2U)) = packed_float4(float4(fb_0, 0.0f)) ;
        *(kernelContext_13->scratch_0+(out_0 + 3U)) = packed_float4(float4(tb_0, 0.0f)) ;
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
    *(kernelContext_13->scratch_0+(kernelContext_13->params_0->ledger_base_0 + i_3)) = packed_float4(ledger_1) ;
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
    float3 _S154 = float3(1.0f, 0.0f, 0.0f);
    thread Quat_0 _S155 = q_7;
    float3 _S156 = rotate_0(&_S155, _S154);
    (&b_16)->axis0_0 = _S156;
    float3 _S157 = float3(0.0f, 1.0f, 0.0f);
    thread Quat_0 _S158 = q_7;
    float3 _S159 = rotate_0(&_S158, _S157);
    (&b_16)->axis1_0 = _S159;
    float3 _S160 = float3(0.0f, 0.0f, 1.0f);
    thread Quat_0 _S161 = q_7;
    float3 _S162 = rotate_0(&_S161, _S160);
    (&b_16)->axis2_0 = _S162;
    (&b_16)->half_2 = half_3;
    (&b_16)->hull_at_0 = 0U;
    (&b_16)->hull_v_0 = 0U;
    (&b_16)->hull_f_0 = 0U;
    return b_16;
}

uint impactor_slots_0(const Impactor_natural_0 thread* imp_1, const Box_0 thread* b_17)
{
    uint _S163;
    if(((float4(imp_1->shape_0) ).x) == 0.0f)
    {
        _S163 = 1U;
    }
    else
    {
        uint _S164 = sample_count_0(b_17);
        _S163 = _S164 + 14U;
    }
    return _S163;
}

uint impactor_slots_1(const Impactor_natural_0 thread* imp_2, const Box_0 thread* b_18)
{
    uint _S165;
    if(((float4(imp_2->shape_0) ).x) == 0.0f)
    {
        _S165 = 1U;
    }
    else
    {
        uint _S166 = sample_count_0(b_18);
        _S165 = _S166 + 14U;
    }
    return _S165;
}

bool sphere_contact_0(const Box_0 thread* b_19, float3 center_4, float radius_0, float3 thread* point_0, float3 thread* normal_4, float thread* depth_3, KernelContext_0 thread* kernelContext_14)
{
    float3 _S167 = float3(0.0f) ;
    *point_0 = _S167;
    *normal_4 = _S167;
    *depth_3 = 0.0f;
    float3 _S168 = b_19->center_1;
    float3 r_4 = center_4 - b_19->center_1;
    float3 _S169 = b_19->axis0_0;
    float3 _S170 = b_19->axis1_0;
    float3 _S171 = b_19->axis2_0;
    float3 local_6 = float3(dot(r_4, b_19->axis0_0), dot(r_4, b_19->axis1_0), dot(r_4, b_19->axis2_0));
    uint _S172 = b_19->hull_v_0;
    if((b_19->hull_v_0) != 0U)
    {
        thread uint face_3;
        float _S173 = hull_signed_distance_0(b_19, local_6, &face_3, kernelContext_14);
        if(_S173 >= radius_0)
        {
            return false;
        }
        float3 _S174 = box_to_world_0(b_19, (float4(*(kernelContext_14->loads_0+(b_19->hull_at_0 + _S172 + face_3))) ).xyz);
        *normal_4 = _S174;
        *point_0 = center_4 - _S174 * float3(max(_S173, 0.0f)) ;
        *depth_3 = radius_0 - _S173;
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
        *normal_4 = _S169 * float3(dn_0.x)  + _S170 * float3(dn_0.y)  + _S171 * float3(dn_0.z) ;
        *point_0 = _S168 + _S169 * float3(q_8.x)  + _S170 * float3(q_8.y)  + _S171 * float3(q_8.z) ;
        *depth_3 = radius_0 - dist_0;
        return true;
    }
    thread float inside_0;
    thread float3 n_4;
    bool _S175 = penetration_0(b_19, center_4, &inside_0, &n_4, kernelContext_14);
    if(!_S175)
    {
        return false;
    }
    *normal_4 = n_4;
    *point_0 = center_4 - n_4 * float3(min(radius_0, inside_0)) ;
    *depth_3 = radius_0 + inside_0;
    return true;
}

bool impactor_contact_0(const Impactor_natural_0 thread* imp_3, float crush_depth_0, const Box_0 thread* shrunk_0, const Box_0 thread* b_20, uint j_0, float3 thread* p_5, float3 thread* n_5, float thread* d_9, KernelContext_0 thread* kernelContext_15)
{
    float3 _S176 = float3(0.0f) ;
    *p_5 = _S176;
    *n_5 = _S176;
    *d_9 = 0.0f;
    float4 _S177 = float4(imp_3->shape_0) ;
    if((_S177.x) == 0.0f)
    {
        bool _S178 = sphere_contact_0(b_20, _S176, _S177.y - crush_depth_0, p_5, n_5, d_9, kernelContext_15);
        if(!_S178)
        {
            return false;
        }
        *n_5 = - *n_5;
        return true;
    }
    uint _S179 = sample_count_0(b_20);
    if(j_0 < _S179)
    {
        float3 _S180 = sample_point_0(b_20, j_0, kernelContext_15);
        *p_5 = _S180;
        bool _S181 = penetration_0(shrunk_0, _S180, d_9, n_5, kernelContext_15);
        return _S181;
    }
    float3 _S182 = sample_point_0(shrunk_0, j_0 - _S179, kernelContext_15);
    *p_5 = _S182;
    bool _S183 = penetration_0(b_20, _S182, d_9, n_5, kernelContext_15);
    if(!_S183)
    {
        return false;
    }
    *n_5 = - *n_5;
    return true;
}

bool impactor_contact_1(const Impactor_natural_0 thread* imp_4, float crush_depth_1, const Box_0 thread* shrunk_1, const Box_0 thread* b_21, uint j_1, float3 thread* p_6, float3 thread* n_6, float thread* d_10, KernelContext_0 thread* kernelContext_16)
{
    float3 _S184 = float3(0.0f) ;
    *p_6 = _S184;
    *n_6 = _S184;
    *d_10 = 0.0f;
    float4 _S185 = float4(imp_4->shape_0) ;
    if((_S185.x) == 0.0f)
    {
        bool _S186 = sphere_contact_0(b_21, _S184, _S185.y - crush_depth_1, p_6, n_6, d_10, kernelContext_16);
        if(!_S186)
        {
            return false;
        }
        *n_6 = - *n_6;
        return true;
    }
    uint _S187 = sample_count_0(b_21);
    if(j_1 < _S187)
    {
        float3 _S188 = sample_point_0(b_21, j_1, kernelContext_16);
        *p_6 = _S188;
        bool _S189 = penetration_0(shrunk_1, _S188, d_10, n_6, kernelContext_16);
        return _S189;
    }
    float3 _S190 = sample_point_0(shrunk_1, j_1 - _S187, kernelContext_16);
    *p_6 = _S190;
    bool _S191 = penetration_0(b_21, _S190, d_10, n_6, kernelContext_16);
    if(!_S191)
    {
        return false;
    }
    *n_6 = - *n_6;
    return true;
}

WorldPoint_0 impactor_point_0(uint _S192, KernelContext_0 thread* kernelContext_17)
{
    Impactor_natural_0 device* _S193 = kernelContext_17->impactors_0+_S192;
    thread WorldPoint_0 wi_0;
    (&wi_0)->hi_0 = (float4(_S193->position_1) ).xyz;
    (&wi_0)->lo_0 = (float4(_S193->position_err_1) ).xyz;
    (&wi_0)->rel_0 = float3(0.0f) ;
    return wi_0;
}

Box_0 impactor_box_1(uint _S194, float3 _S195, float3 _S196, KernelContext_0 thread* kernelContext_18)
{
    Quat_0 q_9 = quat_of_0(float4((kernelContext_18->impactors_0+_S194)->rotation_1) );
    thread Box_0 b_22;
    (&b_22)->center_1 = _S195;
    float3 _S197 = float3(1.0f, 0.0f, 0.0f);
    thread Quat_0 _S198 = q_9;
    float3 _S199 = rotate_0(&_S198, _S197);
    (&b_22)->axis0_0 = _S199;
    float3 _S200 = float3(0.0f, 1.0f, 0.0f);
    thread Quat_0 _S201 = q_9;
    float3 _S202 = rotate_0(&_S201, _S200);
    (&b_22)->axis1_0 = _S202;
    float3 _S203 = float3(0.0f, 0.0f, 1.0f);
    thread Quat_0 _S204 = q_9;
    float3 _S205 = rotate_0(&_S204, _S203);
    (&b_22)->axis2_0 = _S205;
    (&b_22)->half_2 = _S196;
    (&b_22)->hull_at_0 = 0U;
    (&b_22)->hull_v_0 = 0U;
    (&b_22)->hull_f_0 = 0U;
    return b_22;
}

Box_0 impactor_shrunk_0(uint _S206, float _S207, const Box_0 thread* _S208)
{
    thread Box_0 shrunk_2 = *_S208;
    (&shrunk_2)->half_2 = _S208->half_2 - min(float3(_S207) , _S208->half_2 * float3(0.5f) );
    return shrunk_2;
}

bool impactor_contact_2(uint _S209, float _S210, const Box_0 thread* _S211, const Box_0 thread* _S212, uint _S213, float3 thread* _S214, float3 thread* _S215, float thread* _S216, KernelContext_0 thread* kernelContext_19)
{
    Impactor_natural_0 _S217 = *(kernelContext_19->impactors_0+_S209);
    float3 _S218 = float3(0.0f) ;
    *_S214 = _S218;
    *_S215 = _S218;
    *_S216 = 0.0f;
    float4 _S219 = float4(_S217.shape_0) ;
    if((_S219.x) == 0.0f)
    {
        bool _S220 = sphere_contact_0(_S212, _S218, _S219.y - _S210, _S214, _S215, _S216, kernelContext_19);
        if(!_S220)
        {
            return false;
        }
        *_S215 = - *_S215;
        return true;
    }
    uint _S221 = sample_count_0(_S212);
    if(_S213 < _S221)
    {
        float3 _S222 = sample_point_0(_S212, _S213, kernelContext_19);
        *_S214 = _S222;
        bool _S223 = penetration_0(_S211, _S222, _S216, _S215, kernelContext_19);
        return _S223;
    }
    float3 _S224 = sample_point_0(_S211, _S213 - _S221, kernelContext_19);
    *_S214 = _S224;
    bool _S225 = penetration_0(_S212, _S224, _S216, _S215, kernelContext_19);
    if(!_S225)
    {
        return false;
    }
    *_S215 = - *_S215;
    return true;
}

uint impactor_contact_count_0(uint _S226, float _S227, const Box_0 thread* _S228, const Box_0 thread* _S229, KernelContext_0 thread* kernelContext_20)
{
    thread Impactor_natural_0 _S230 = *(kernelContext_20->impactors_0+_S226);
    uint j_2 = 0U;
    uint count_1 = 0U;
    for(;;)
    {
        uint _S231 = impactor_slots_1(&_S230, _S229);
        if(j_2 < _S231)
        {
        }
        else
        {
            break;
        }
        thread float3 p_7;
        thread float3 n_7;
        thread float d_11;
        bool _S232 = impactor_contact_2(_S226, _S227, _S228, _S229, j_2, &p_7, &n_7, &d_11, kernelContext_20);
        if(_S232)
        {
            count_1 = count_1 + 1U;
        }
        j_2 = j_2 + 1U;
    }
    return count_1;
}

void impactor_candidate_forces_0(uint k_6, KernelContext_0 thread* kernelContext_21)
{
    uint _S233 = 3U * k_6;
    uint at_1 = kernelContext_21->params_0->cand_index_0 + _S233;
    uint c_4 = kernelContext_21->index_0[at_1];
    uint slot_0 = kernelContext_21->index_0[at_1 + 1U];
    uint _S234 = kernelContext_21->index_0[at_1 + 2U];
    thread Impactor_natural_0 _S235 = *(kernelContext_21->impactors_0+_S234);
    float _S236 = kernelContext_21->params_0->dt_0;
    float3 _S237 = float3(0.0f) ;
    thread float4 data_0 = float4(*(kernelContext_21->scratch_0+(kernelContext_21->params_0->cand_base_0 + _S233))) ;
    float3 f_sum_0;
    float3 t_sum_0;
    float3 imp_f_0;
    float3 imp_t_0;
    if(((uint4((&_S235)->cand_0) ).z) == 0U)
    {
        WorldPoint_0 _S238 = chunk_world_0(c_4, kernelContext_21);
        WorldPoint_0 _S239 = impactor_point_0(_S234, kernelContext_21);
        thread WorldPoint_0 _S240 = _S238;
        thread WorldPoint_0 _S241 = _S239;
        float3 _S242 = world_diff_0(&_S240, &_S241);
        float4 _S243 = float4((&_S235)->half_1) ;
        if(!((length(_S242)) > (_S243.w + (float4((kernelContext_21->chunks_0+c_4)->half_0) ).w)))
        {
            Box_0 _S244 = impactor_box_1(_S234, _S237, _S243.xyz, kernelContext_21);
            Box_0 _S245 = chunk_box_0(c_4, _S242, kernelContext_21);
            float4 _S246 = float4((&_S235)->mat_0) ;
            float _S247 = _S246.x;
            float _S248 = (float4((kernelContext_21->chunks_0+c_4)->cmat_0) ).x;
            float3 _S249 = _S245.center_1 - _S244.center_1;
            thread Box_0 _S250 = _S244;
            thread Box_0 _S251 = _S245;
            float _S252 = contact_stiffness_0(_S247, &_S250, _S248, &_S251, _S249);
            float4 _S253 = float4((&_S235)->geom_0) ;
            float _S254 = _S253.y;
            thread Box_0 _S255 = _S244;
            Box_0 _S256 = impactor_shrunk_0(_S234, _S254, &_S255);
            thread Box_0 _S257 = _S256;
            thread Box_0 _S258 = _S245;
            uint _S259 = impactor_contact_count_0(_S234, _S254, &_S257, &_S258, kernelContext_21);
            bool _S260 = ((float4((&_S235)->shape_0) ).x) == 0.0f;
            float _S261;
            if(_S260)
            {
                _S261 = _S252;
            }
            else
            {
                _S261 = _S252 / max(float(_S259), 10.0f);
            }
            uint _S262;
            if(_S260)
            {
                _S262 = 1U;
            }
            else
            {
                _S262 = _S259;
            }
            float m_1 = (float4((kernelContext_21->chunks_0+c_4)->center_0) ).w;
            float _S263 = _S246.z;
            float _S264 = m_1 * _S263 / (m_1 + _S263);
            float _S265;
            if((kernelContext_21->params_0->pair_friction_0) >= 0.0f)
            {
                _S265 = kernelContext_21->params_0->pair_friction_0;
            }
            else
            {
                _S265 = min(_S246.y, (float4((kernelContext_21->chunks_0+c_4)->cmat_0) ).y);
            }
            float3 _S266 = (float4((&_S235)->velocity_1) ).xyz + (float4((&_S235)->velocity_err_1) ).xyz;
            thread float3 vc_0;
            thread float3 wc_0;
            chunk_velocity_0(c_4, &vc_0, &wc_0, kernelContext_21);
            uint j_3 = 0U;
            f_sum_0 = _S237;
            t_sum_0 = _S237;
            imp_f_0 = _S237;
            imp_t_0 = _S237;
            for(;;)
            {
                bool _S267;
                if(_S259 > 0U)
                {
                    thread Box_0 _S268 = _S245;
                    uint _S269 = impactor_slots_0(&_S235, &_S268);
                    _S267 = j_3 < _S269;
                }
                else
                {
                    _S267 = false;
                }
                if(_S267)
                {
                }
                else
                {
                    break;
                }
                thread Box_0 _S270 = _S256;
                thread Box_0 _S271 = _S245;
                thread float3 p_8;
                thread float3 nrm_0;
                thread float dep_0;
                bool _S272 = impactor_contact_0(&_S235, _S254, &_S270, &_S271, j_3, &p_8, &nrm_0, &dep_0, kernelContext_21);
                if(!_S272)
                {
                    j_3 = j_3 + 1U;
                    continue;
                }
                thread float stored_2;
                thread float diss_1;
                float3 _S273 = penalty_force_0(_S261, _S264, _S265, dep_0 * _S253.x, nrm_0, vc_0 + cross(wc_0, p_8 - _S245.center_1) - (_S266 + cross((float4((&_S235)->angular_velocity_1) ).xyz, p_8)), _S236, _S262, &stored_2, &diss_1, kernelContext_21);
                float3 f_sum_1 = f_sum_0 + _S273;
                float3 t_sum_1 = t_sum_0 + cross(p_8 - _S245.center_1, _S273);
                float3 imp_f_1 = imp_f_0 - _S273;
                float3 imp_t_1 = imp_t_0 - cross(p_8, _S273);
                thread float _S274 = data_0.z;
                thread float _S275 = data_0.w;
                comp_add1_0(&_S274, &_S275, diss_1);
                data_0.w = _S275;
                data_0.z = _S274;
                f_sum_0 = f_sum_1;
                t_sum_0 = t_sum_1;
                imp_f_0 = imp_f_1;
                imp_t_0 = imp_t_1;
                j_3 = j_3 + 1U;
            }
        }
        else
        {
            f_sum_0 = _S237;
            t_sum_0 = _S237;
            imp_f_0 = _S237;
            imp_t_0 = _S237;
        }
    }
    else
    {
        f_sum_0 = _S237;
        t_sum_0 = _S237;
        imp_f_0 = _S237;
        imp_t_0 = _S237;
    }
    uint _S276 = 2U * slot_0;
    *(kernelContext_21->scratch_0+(kernelContext_21->params_0->slot_base_0 + _S276)) = packed_float4(float4(f_sum_0, 0.0f)) ;
    *(kernelContext_21->scratch_0+(kernelContext_21->params_0->slot_base_0 + _S276 + 1U)) = packed_float4(float4(t_sum_0, 0.0f)) ;
    *(kernelContext_21->scratch_0+(kernelContext_21->params_0->cand_base_0 + _S233)) = packed_float4(data_0) ;
    *(kernelContext_21->scratch_0+(kernelContext_21->params_0->cand_base_0 + _S233 + 1U)) = packed_float4(float4(imp_f_0, 0.0f)) ;
    *(kernelContext_21->scratch_0+(kernelContext_21->params_0->cand_base_0 + _S233 + 2U)) = packed_float4(float4(imp_t_0, 0.0f)) ;
    return;
}

void travel_check_0(uint c_5, KernelContext_0 thread* kernelContext_22)
{
    ChunkStatic_natural_0 device* _S277 = kernelContext_22->chunks_0+c_5;
    if(((uint4(_S277->cinfo_0) ).z) == 0U)
    {
        return;
    }
    WorldPoint_0 _S278 = chunk_world_0(c_5, kernelContext_22);
    float4 _S279 = float4(_S277->start_hi_0) ;
    if((length(_S278.hi_0 - _S279.xyz + (_S278.lo_0 - (float4(_S277->start_lo_0) ).xyz) + _S278.rel_0)) > (_S279.w))
    {
        (kernelContext_22->islands_0+kernelContext_22->params_0->halt_index_0)->info_0[int(2)] = ((uint4((kernelContext_22->islands_0+kernelContext_22->params_0->halt_index_0)->info_0) ).z) | 1U;
    }
    return;
}

[[kernel]] void contact_forces(uint3 id_0 [[thread_position_in_grid]], Params_0 constant* params_1 [[buffer(0)]], Island_natural_0 device* islands_1 [[buffer(9)]], uint device* index_1 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_1 [[buffer(3)]], packed_float4 device* state_1 [[buffer(6)]], packed_float4 device* scratch_1 [[buffer(8)]], packed_float4 device* contact_state_1 [[buffer(11)]], packed_float4 device* loads_1 [[buffer(5)]], Impactor_natural_0 device* impactors_1 [[buffer(10)]], BondStatic_natural_0 device* bonds_1 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_1 [[buffer(7)]], MaterialTable_0 constant* materials_1 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_23;
    (&kernelContext_23)->params_0 = params_1;
    (&kernelContext_23)->islands_0 = islands_1;
    (&kernelContext_23)->index_0 = index_1;
    (&kernelContext_23)->chunks_0 = chunks_1;
    (&kernelContext_23)->state_0 = state_1;
    (&kernelContext_23)->scratch_0 = scratch_1;
    (&kernelContext_23)->contact_state_0 = contact_state_1;
    (&kernelContext_23)->loads_0 = loads_1;
    (&kernelContext_23)->impactors_0 = impactors_1;
    (&kernelContext_23)->bonds_0 = bonds_1;
    (&kernelContext_23)->bond_dyn_0 = bond_dyn_1;
    (&kernelContext_23)->materials_0 = materials_1;
    threadgroup array<float4, int(32)> g_part_a_1;
    (&kernelContext_23)->g_part_a_0 = &g_part_a_1;
    threadgroup array<float4, int(32)> g_part_b_1;
    (&kernelContext_23)->g_part_b_0 = &g_part_b_1;
    threadgroup uint g_run_1;
    (&kernelContext_23)->g_run_0 = &g_run_1;
    threadgroup uint g_halt_1;
    (&kernelContext_23)->g_halt_0 = &g_halt_1;
    threadgroup uint g_wide_run_1;
    (&kernelContext_23)->g_wide_run_0 = &g_wide_run_1;
    uint i_4 = id_0.x;
    bool _S280 = stopped_0(&kernelContext_23);
    if(_S280)
    {
        return;
    }
    if(i_4 < ((&kernelContext_23)->params_0->pair_count_0))
    {
        pair_contact_0(i_4, &kernelContext_23);
    }
    else
    {
        if(i_4 < ((&kernelContext_23)->params_0->pair_count_0 + (&kernelContext_23)->params_0->cand_count_0))
        {
            impactor_candidate_forces_0(i_4 - (&kernelContext_23)->params_0->pair_count_0, &kernelContext_23);
        }
        else
        {
            if(i_4 < ((&kernelContext_23)->params_0->pair_count_0 + (&kernelContext_23)->params_0->cand_count_0 + (&kernelContext_23)->params_0->chunk_count_0))
            {
                travel_check_0(i_4 - (&kernelContext_23)->params_0->pair_count_0 - (&kernelContext_23)->params_0->cand_count_0, &kernelContext_23);
            }
        }
    }
    return;
}

[[kernel]] void impactor_shares(uint3 id_1 [[thread_position_in_grid]], Params_0 constant* params_2 [[buffer(0)]], Island_natural_0 device* islands_2 [[buffer(9)]], uint device* index_2 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_2 [[buffer(3)]], packed_float4 device* state_2 [[buffer(6)]], packed_float4 device* scratch_2 [[buffer(8)]], packed_float4 device* contact_state_2 [[buffer(11)]], packed_float4 device* loads_2 [[buffer(5)]], Impactor_natural_0 device* impactors_2 [[buffer(10)]], BondStatic_natural_0 device* bonds_2 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_2 [[buffer(7)]], MaterialTable_0 constant* materials_2 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_24;
    (&kernelContext_24)->params_0 = params_2;
    (&kernelContext_24)->islands_0 = islands_2;
    (&kernelContext_24)->index_0 = index_2;
    (&kernelContext_24)->chunks_0 = chunks_2;
    (&kernelContext_24)->state_0 = state_2;
    (&kernelContext_24)->scratch_0 = scratch_2;
    (&kernelContext_24)->contact_state_0 = contact_state_2;
    (&kernelContext_24)->loads_0 = loads_2;
    (&kernelContext_24)->impactors_0 = impactors_2;
    (&kernelContext_24)->bonds_0 = bonds_2;
    (&kernelContext_24)->bond_dyn_0 = bond_dyn_2;
    (&kernelContext_24)->materials_0 = materials_2;
    threadgroup array<float4, int(32)> g_part_a_2;
    (&kernelContext_24)->g_part_a_0 = &g_part_a_2;
    threadgroup array<float4, int(32)> g_part_b_2;
    (&kernelContext_24)->g_part_b_0 = &g_part_b_2;
    threadgroup uint g_run_2;
    (&kernelContext_24)->g_run_0 = &g_run_2;
    threadgroup uint g_halt_2;
    (&kernelContext_24)->g_halt_0 = &g_halt_2;
    threadgroup uint g_wide_run_2;
    (&kernelContext_24)->g_wide_run_0 = &g_wide_run_2;
    uint k_7 = id_1.x;
    bool _S281;
    if(k_7 >= (params_2->cand_count_0))
    {
        _S281 = true;
    }
    else
    {
        bool _S282 = stopped_0(&kernelContext_24);
        _S281 = _S282;
    }
    if(_S281)
    {
        return;
    }
    uint _S283 = 3U * k_7;
    uint at_2 = (&kernelContext_24)->params_0->cand_index_0 + _S283;
    uint c_6 = (&kernelContext_24)->index_0[at_2];
    uint _S284 = (&kernelContext_24)->index_0[at_2 + 2U];
    thread Impactor_natural_0 _S285 = *((&kernelContext_24)->impactors_0+_S284);
    if(((uint4((&_S285)->cand_0) ).z) == 0U)
    {
        _S281 = ((float4((&_S285)->crush_0) ).x) > 0.0f;
    }
    else
    {
        _S281 = false;
    }
    float total_0;
    float ksum_0;
    if(_S281)
    {
        WorldPoint_0 _S286 = chunk_world_0(c_6, &kernelContext_24);
        WorldPoint_0 _S287 = impactor_point_0(_S284, &kernelContext_24);
        thread WorldPoint_0 _S288 = _S286;
        thread WorldPoint_0 _S289 = _S287;
        float3 _S290 = world_diff_0(&_S288, &_S289);
        float4 _S291 = float4((&_S285)->half_1) ;
        if(!((length(_S290)) > (_S291.w + (float4(((&kernelContext_24)->chunks_0+c_6)->half_0) ).w)))
        {
            Box_0 _S292 = impactor_box_1(_S284, float3(0.0f) , _S291.xyz, &kernelContext_24);
            Box_0 _S293 = chunk_box_0(c_6, _S290, &kernelContext_24);
            float _S294 = (float4((&_S285)->mat_0) ).x;
            float _S295 = (float4(((&kernelContext_24)->chunks_0+c_6)->cmat_0) ).x;
            float3 _S296 = _S293.center_1 - _S292.center_1;
            thread Box_0 _S297 = _S292;
            thread Box_0 _S298 = _S293;
            float _S299 = contact_stiffness_0(_S294, &_S297, _S295, &_S298, _S296);
            float _S300 = (float4((&_S285)->crush_0) ).w;
            thread Box_0 _S301 = _S292;
            Box_0 _S302 = impactor_shrunk_0(_S284, _S300, &_S301);
            thread Box_0 _S303 = _S302;
            thread Box_0 _S304 = _S293;
            uint _S305 = impactor_contact_count_0(_S284, _S300, &_S303, &_S304, &kernelContext_24);
            float _S306;
            if(((float4((&_S285)->shape_0) ).x) == 0.0f)
            {
                _S306 = _S299;
            }
            else
            {
                _S306 = _S299 / max(float(_S305), 10.0f);
            }
            uint j_4 = 0U;
            total_0 = 0.0f;
            ksum_0 = 0.0f;
            for(;;)
            {
                if(_S305 > 0U)
                {
                    thread Box_0 _S307 = _S293;
                    uint _S308 = impactor_slots_0(&_S285, &_S307);
                    _S281 = j_4 < _S308;
                }
                else
                {
                    _S281 = false;
                }
                if(_S281)
                {
                }
                else
                {
                    break;
                }
                thread Box_0 _S309 = _S302;
                thread Box_0 _S310 = _S293;
                thread float3 p_9;
                thread float3 nrm_1;
                thread float dep_1;
                bool _S311 = impactor_contact_1(&_S285, _S300, &_S309, &_S310, j_4, &p_9, &nrm_1, &dep_1, &kernelContext_24);
                if(!_S311)
                {
                    j_4 = j_4 + 1U;
                    continue;
                }
                float ksum_1 = ksum_0 + _S306;
                total_0 = total_0 + _S306 * dep_1;
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
    float4 _S312 = float4(*((&kernelContext_24)->scratch_0+((&kernelContext_24)->params_0->cand_base_0 + _S283))) ;
    *((&kernelContext_24)->scratch_0+((&kernelContext_24)->params_0->cand_base_0 + _S283)) = packed_float4(float4(total_0, ksum_0, _S312.z, _S312.w)) ;
    return;
}

[[kernel]] void impactor_crush(uint3 group_0 [[threadgroup_position_in_grid]], uint3 thread_0 [[thread_position_in_threadgroup]], Params_0 constant* params_3 [[buffer(0)]], Island_natural_0 device* islands_3 [[buffer(9)]], uint device* index_3 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_3 [[buffer(3)]], packed_float4 device* state_3 [[buffer(6)]], packed_float4 device* scratch_3 [[buffer(8)]], packed_float4 device* contact_state_3 [[buffer(11)]], packed_float4 device* loads_3 [[buffer(5)]], Impactor_natural_0 device* impactors_3 [[buffer(10)]], BondStatic_natural_0 device* bonds_3 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_3 [[buffer(7)]], MaterialTable_0 constant* materials_3 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_25;
    (&kernelContext_25)->params_0 = params_3;
    (&kernelContext_25)->islands_0 = islands_3;
    (&kernelContext_25)->index_0 = index_3;
    (&kernelContext_25)->chunks_0 = chunks_3;
    (&kernelContext_25)->state_0 = state_3;
    (&kernelContext_25)->scratch_0 = scratch_3;
    (&kernelContext_25)->contact_state_0 = contact_state_3;
    (&kernelContext_25)->loads_0 = loads_3;
    (&kernelContext_25)->impactors_0 = impactors_3;
    (&kernelContext_25)->bonds_0 = bonds_3;
    (&kernelContext_25)->bond_dyn_0 = bond_dyn_3;
    (&kernelContext_25)->materials_0 = materials_3;
    threadgroup array<float4, int(32)> g_part_a_3;
    (&kernelContext_25)->g_part_a_0 = &g_part_a_3;
    threadgroup array<float4, int(32)> g_part_b_3;
    (&kernelContext_25)->g_part_b_0 = &g_part_b_3;
    threadgroup uint g_run_3;
    (&kernelContext_25)->g_run_0 = &g_run_3;
    threadgroup uint g_halt_3;
    (&kernelContext_25)->g_halt_0 = &g_halt_3;
    threadgroup uint g_wide_run_3;
    (&kernelContext_25)->g_wide_run_0 = &g_wide_run_3;
    uint ii_0 = group_0.x;
    uint tid_2 = thread_0.x;
    bool _S313;
    if(ii_0 >= (params_3->impactor_count_0))
    {
        _S313 = true;
    }
    else
    {
        bool _S314 = stopped_0(&kernelContext_25);
        _S313 = _S314;
    }
    if(_S313)
    {
        return;
    }
    Impactor_natural_0 device* _S315 = (&kernelContext_25)->impactors_0+ii_0;
    float4 _S316 = float4((*_S315).position_err_1) ;
    float4 _S317 = float4((*_S315).velocity_1) ;
    float4 _S318 = float4((*_S315).velocity_err_1) ;
    float4 _S319 = float4((*_S315).angular_velocity_1) ;
    float4 _S320 = float4((*_S315).rotation_1) ;
    float4 _S321 = float4((*_S315).inertia0_2) ;
    float4 _S322 = float4((*_S315).inertia1_2) ;
    float4 _S323 = float4((*_S315).inertia2_2) ;
    float4 _S324 = float4((*_S315).inv0_2) ;
    float4 _S325 = float4((*_S315).inv1_2) ;
    float4 _S326 = float4((*_S315).inv2_2) ;
    float4 _S327 = float4((*_S315).shape_0) ;
    float4 _S328 = float4((*_S315).half_1) ;
    float4 _S329 = float4((*_S315).mat_0) ;
    float4 _S330 = float4((*_S315).crush_0) ;
    float4 _S331 = float4((*_S315).geom_0) ;
    float4 _S332 = float4((*_S315).rotation_err_1) ;
    float4 _S333 = float4((*_S315).ledger_0) ;
    uint4 _S334 = uint4((*_S315).cand_0) ;
    float4 _S335 = float4((*_S315).momentum_1) ;
    float4 _S336 = float4((*_S315).momentum_err_1) ;
    thread Impactor_0 imp_5;
    (&imp_5)->position_1 = float4((*_S315).position_1) ;
    (&imp_5)->position_err_1 = _S316;
    (&imp_5)->velocity_1 = _S317;
    (&imp_5)->velocity_err_1 = _S318;
    (&imp_5)->angular_velocity_1 = _S319;
    (&imp_5)->rotation_1 = _S320;
    (&imp_5)->inertia0_2 = _S321;
    (&imp_5)->inertia1_2 = _S322;
    (&imp_5)->inertia2_2 = _S323;
    (&imp_5)->inv0_2 = _S324;
    (&imp_5)->inv1_2 = _S325;
    (&imp_5)->inv2_2 = _S326;
    (&imp_5)->shape_0 = _S327;
    (&imp_5)->half_1 = _S328;
    (&imp_5)->mat_0 = _S329;
    (&imp_5)->crush_0 = _S330;
    (&imp_5)->geom_0 = _S331;
    (&imp_5)->rotation_err_1 = _S332;
    (&imp_5)->ledger_0 = _S333;
    (&imp_5)->cand_0 = _S334;
    (&imp_5)->momentum_1 = _S335;
    (&imp_5)->momentum_err_1 = _S336;
    float4 _S337 = float4(0.0f) ;
    thread float4 shares_0 = _S337;
    thread float4 unused_0 = _S337;
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
        shares_0 = shares_0 + float4(*((&kernelContext_25)->scratch_0+((&kernelContext_25)->params_0->cand_base_0 + 3U * k_8))) ;
        k_8 = k_8 + 256U;
    }
    group_sum2_0(tid_2, &shares_0, &unused_0, &kernelContext_25);
    if(tid_2 != 0U)
    {
        _S313 = true;
    }
    else
    {
        _S313 = ((&imp_5)->cand_0.z) != 0U;
    }
    if(_S313)
    {
        return;
    }
    (&imp_5)->geom_0 = float4(1.0f, (&imp_5)->crush_0.w, 0.0f, 0.0f);
    float total_1 = shares_0.x;
    if(((&imp_5)->crush_0.x) > 0.0f)
    {
        _S313 = ((&imp_5)->crush_0.z) < ((&imp_5)->crush_0.y);
    }
    else
    {
        _S313 = false;
    }
    if(_S313)
    {
        _S313 = total_1 > ((&imp_5)->crush_0.x);
    }
    else
    {
        _S313 = false;
    }
    if(_S313)
    {
        float extra_0 = (total_1 - (&imp_5)->crush_0.x) / shares_0.y;
        (&imp_5)->crush_0.w = (&imp_5)->crush_0.w + extra_0;
        (&imp_5)->crush_0.z = (&imp_5)->crush_0.z + (&imp_5)->crush_0.x * extra_0;
        float _S338 = (&imp_5)->crush_0.x * extra_0;
        thread float _S339 = (&imp_5)->ledger_0.z;
        thread float _S340 = (&imp_5)->ledger_0.w;
        comp_add1_0(&_S339, &_S340, _S338);
        (&imp_5)->ledger_0.w = _S340;
        (&imp_5)->ledger_0.z = _S339;
        float _S341 = (&imp_5)->crush_0.x * extra_0;
        thread float _S342 = (&imp_5)->ledger_0.x;
        thread float _S343 = (&imp_5)->ledger_0.y;
        comp_add1_0(&_S342, &_S343, _S341);
        (&imp_5)->ledger_0.y = _S343;
        (&imp_5)->ledger_0.x = _S342;
        (&imp_5)->geom_0.x = (&imp_5)->crush_0.x / total_1;
    }
    Impactor_natural_0 device* _S344 = (&kernelContext_25)->impactors_0+ii_0;
    _S344->position_1 = packed_float4(imp_5.position_1) ;
    _S344->position_err_1 = packed_float4(imp_5.position_err_1) ;
    _S344->velocity_1 = packed_float4(imp_5.velocity_1) ;
    _S344->velocity_err_1 = packed_float4(imp_5.velocity_err_1) ;
    _S344->angular_velocity_1 = packed_float4(imp_5.angular_velocity_1) ;
    _S344->rotation_1 = packed_float4(imp_5.rotation_1) ;
    _S344->inertia0_2 = packed_float4(imp_5.inertia0_2) ;
    _S344->inertia1_2 = packed_float4(imp_5.inertia1_2) ;
    _S344->inertia2_2 = packed_float4(imp_5.inertia2_2) ;
    _S344->inv0_2 = packed_float4(imp_5.inv0_2) ;
    _S344->inv1_2 = packed_float4(imp_5.inv1_2) ;
    _S344->inv2_2 = packed_float4(imp_5.inv2_2) ;
    _S344->shape_0 = packed_float4(imp_5.shape_0) ;
    _S344->half_1 = packed_float4(imp_5.half_1) ;
    _S344->mat_0 = packed_float4(imp_5.mat_0) ;
    _S344->crush_0 = packed_float4(imp_5.crush_0) ;
    _S344->geom_0 = packed_float4(imp_5.geom_0) ;
    _S344->rotation_err_1 = packed_float4(imp_5.rotation_err_1) ;
    _S344->ledger_0 = packed_float4(imp_5.ledger_0) ;
    _S344->cand_0 = packed_uint4(imp_5.cand_0) ;
    _S344->momentum_1 = packed_float4(imp_5.momentum_1) ;
    _S344->momentum_err_1 = packed_float4(imp_5.momentum_err_1) ;
    return;
}

void comp_add_0(float3 thread* sum_1, float3 thread* err_1, float3 x_4)
{
    float3 t_3 = *sum_1 + x_4;
    float3 _S345 = abs(x_4);
    *err_1 = *err_1 + (select(x_4, *sum_1, (abs(*sum_1)) >= _S345) - t_3 + select(*sum_1, x_4, (abs(*sum_1)) >= _S345));
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
    thread Quat_0 _S346 = c_7;
    float3 _S347 = rotate_0(&_S346, v_5);
    return _S347;
}

float3 inverse_rotate_1(const Quat_0 thread* q_11, float3 v_6)
{
    thread Quat_0 c_8;
    (&c_8)->w_1 = q_11->w_1;
    (&c_8)->x_1 = - q_11->x_1;
    (&c_8)->y_1 = - q_11->y_1;
    (&c_8)->z_0 = - q_11->z_0;
    thread Quat_0 _S348 = c_8;
    float3 _S349 = rotate_0(&_S348, v_6);
    return _S349;
}

float3 rows_mul_0(float4 r0_0, float4 r1_0, float4 r2_0, float3 v_7)
{
    return float3(dot(r0_0.xyz, v_7), dot(r1_0.xyz, v_7), dot(r2_0.xyz, v_7));
}

float3 world_mul_0(const Quat_0 thread* q_12, float4 r0_1, float4 r1_1, float4 r2_1, float3 v_8)
{
    float3 _S350 = inverse_rotate_1(q_12, v_8);
    float3 _S351 = rotate_1(q_12, rows_mul_0(r0_1, r1_1, r2_1, _S350));
    return _S351;
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
    float4 _S352 = abs(x_5);
    *err_2 = *err_2 + (select(x_5, *sum_2, (abs(*sum_2)) >= _S352) - t_4 + select(*sum_2, x_5, (abs(*sum_2)) >= _S352));
    *sum_2 = t_4;
    return;
}

void quat_accumulate_0(Quat_0 thread* hi_1, float4 thread* lo_1, float4 x_6)
{
    thread Quat_0 _S353 = *hi_1;
    float4 _S354 = quat_vec_0(&_S353);
    thread float4 sum_3 = _S354;
    comp_add4_0(&sum_3, lo_1, x_6);
    float4 t_5 = sum_3 + *lo_1;
    *lo_1 = *lo_1 - (t_5 - sum_3);
    *hi_1 = quat_of_0(t_5);
    return;
}

void turn_left_0(Quat_0 thread* hi_2, float4 thread* lo_2, float3 omega_0, float dt_2)
{
    float _S355 = length(omega_0);
    float angle_2 = _S355 * dt_2;
    if(angle_2 < 1.00000000317107685e-30f)
    {
        return;
    }
    float4 d_12 = turn_minus_one_0(omega_0 / float3(_S355) , angle_2);
    thread Quat_0 dq_0;
    (&dq_0)->x_1 = d_12.x;
    (&dq_0)->y_1 = d_12.y;
    (&dq_0)->z_0 = d_12.z;
    (&dq_0)->w_1 = d_12.w;
    thread Quat_0 _S356 = dq_0;
    thread Quat_0 _S357 = *hi_2;
    Quat_0 _S358 = quat_mul_0(&_S356, &_S357);
    thread Quat_0 _S359 = _S358;
    float4 _S360 = quat_vec_0(&_S359);
    quat_accumulate_0(hi_2, lo_2, _S360);
    return;
}

[[kernel]] void impactor_integrate(uint3 group_1 [[threadgroup_position_in_grid]], uint3 thread_1 [[thread_position_in_threadgroup]], Params_0 constant* params_4 [[buffer(0)]], Island_natural_0 device* islands_4 [[buffer(9)]], uint device* index_4 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_4 [[buffer(3)]], packed_float4 device* state_4 [[buffer(6)]], packed_float4 device* scratch_4 [[buffer(8)]], packed_float4 device* contact_state_4 [[buffer(11)]], packed_float4 device* loads_4 [[buffer(5)]], Impactor_natural_0 device* impactors_4 [[buffer(10)]], BondStatic_natural_0 device* bonds_4 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_4 [[buffer(7)]], MaterialTable_0 constant* materials_4 [[buffer(1)]])
{
    float3 p_10;
    thread KernelContext_0 kernelContext_26;
    (&kernelContext_26)->params_0 = params_4;
    (&kernelContext_26)->islands_0 = islands_4;
    (&kernelContext_26)->index_0 = index_4;
    (&kernelContext_26)->chunks_0 = chunks_4;
    (&kernelContext_26)->state_0 = state_4;
    (&kernelContext_26)->scratch_0 = scratch_4;
    (&kernelContext_26)->contact_state_0 = contact_state_4;
    (&kernelContext_26)->loads_0 = loads_4;
    (&kernelContext_26)->impactors_0 = impactors_4;
    (&kernelContext_26)->bonds_0 = bonds_4;
    (&kernelContext_26)->bond_dyn_0 = bond_dyn_4;
    (&kernelContext_26)->materials_0 = materials_4;
    threadgroup array<float4, int(32)> g_part_a_4;
    (&kernelContext_26)->g_part_a_0 = &g_part_a_4;
    threadgroup array<float4, int(32)> g_part_b_4;
    (&kernelContext_26)->g_part_b_0 = &g_part_b_4;
    threadgroup uint g_run_4;
    (&kernelContext_26)->g_run_0 = &g_run_4;
    threadgroup uint g_halt_4;
    (&kernelContext_26)->g_halt_0 = &g_halt_4;
    threadgroup uint g_wide_run_4;
    (&kernelContext_26)->g_wide_run_0 = &g_wide_run_4;
    uint ii_1 = group_1.x;
    uint tid_3 = thread_1.x;
    if(ii_1 >= (params_4->impactor_count_0))
    {
        return;
    }
    Island_natural_0 device* _S361 = (&kernelContext_26)->islands_0+(&kernelContext_26)->params_0->halt_index_0;
    Impactor_natural_0 device* _S362 = (&kernelContext_26)->impactors_0+ii_1;
    float4 _S363 = float4((*_S362).position_err_1) ;
    float4 _S364 = float4((*_S362).velocity_1) ;
    float4 _S365 = float4((*_S362).velocity_err_1) ;
    float4 _S366 = float4((*_S362).angular_velocity_1) ;
    float4 _S367 = float4((*_S362).rotation_1) ;
    float4 _S368 = float4((*_S362).inertia0_2) ;
    float4 _S369 = float4((*_S362).inertia1_2) ;
    float4 _S370 = float4((*_S362).inertia2_2) ;
    float4 _S371 = float4((*_S362).inv0_2) ;
    float4 _S372 = float4((*_S362).inv1_2) ;
    float4 _S373 = float4((*_S362).inv2_2) ;
    float4 _S374 = float4((*_S362).shape_0) ;
    float4 _S375 = float4((*_S362).half_1) ;
    float4 _S376 = float4((*_S362).mat_0) ;
    float4 _S377 = float4((*_S362).crush_0) ;
    float4 _S378 = float4((*_S362).geom_0) ;
    float4 _S379 = float4((*_S362).rotation_err_1) ;
    float4 _S380 = float4((*_S362).ledger_0) ;
    uint4 _S381 = uint4((*_S362).cand_0) ;
    float4 _S382 = float4((*_S362).momentum_1) ;
    float4 _S383 = float4((*_S362).momentum_err_1) ;
    thread Impactor_0 imp_6;
    (&imp_6)->position_1 = float4((*_S362).position_1) ;
    (&imp_6)->position_err_1 = _S363;
    (&imp_6)->velocity_1 = _S364;
    (&imp_6)->velocity_err_1 = _S365;
    (&imp_6)->angular_velocity_1 = _S366;
    (&imp_6)->rotation_1 = _S367;
    (&imp_6)->inertia0_2 = _S368;
    (&imp_6)->inertia1_2 = _S369;
    (&imp_6)->inertia2_2 = _S370;
    (&imp_6)->inv0_2 = _S371;
    (&imp_6)->inv1_2 = _S372;
    (&imp_6)->inv2_2 = _S373;
    (&imp_6)->shape_0 = _S374;
    (&imp_6)->half_1 = _S375;
    (&imp_6)->mat_0 = _S376;
    (&imp_6)->crush_0 = _S377;
    (&imp_6)->geom_0 = _S378;
    (&imp_6)->rotation_err_1 = _S379;
    (&imp_6)->ledger_0 = _S380;
    (&imp_6)->cand_0 = _S381;
    (&imp_6)->momentum_1 = _S382;
    (&imp_6)->momentum_err_1 = _S383;
    bool _S384;
    if(((&imp_6)->cand_0.z) != 0U)
    {
        _S384 = true;
    }
    else
    {
        _S384 = (((uint4(_S361->info_0) ).z) & 1U) != 0U;
    }
    if(_S384)
    {
        _S384 = true;
    }
    else
    {
        uint _S385 = (uint4(_S361->info_0) ).y;
        if(_S385 != 0U)
        {
            _S384 = ((&imp_6)->cand_0.w) >= _S385;
        }
        else
        {
            _S384 = false;
        }
    }
    if(_S384)
    {
        return;
    }
    float4 _S386 = float4(0.0f) ;
    thread float4 rf_0 = _S386;
    thread float4 rt_0 = _S386;
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
        uint _S387 = 3U * k_9;
        rf_0 = rf_0 + float4(*((&kernelContext_26)->scratch_0+((&kernelContext_26)->params_0->cand_base_0 + _S387 + 1U))) ;
        rt_0 = rt_0 + float4(*((&kernelContext_26)->scratch_0+((&kernelContext_26)->params_0->cand_base_0 + _S387 + 2U))) ;
        k_9 = k_9 + 256U;
    }
    group_sum2_0(tid_3, &rf_0, &rt_0, &kernelContext_26);
    if(tid_3 != 0U)
    {
        return;
    }
    float dt_3 = (&kernelContext_26)->params_0->dt_0;
    float3 _S388 = float3(0.0f) ;
    float3 load_f_0;
    float3 load_t_0;
    if(((&kernelContext_26)->params_0->has_ground_0) != 0U)
    {
        float3 _S389 = (&imp_6)->half_1.xyz;
        thread Impactor_0 _S390 = imp_6;
        Box_0 _S391 = impactor_box_0(&_S390, _S388, _S389);
        float3 _S392 = (&imp_6)->velocity_1.xyz + (&imp_6)->velocity_err_1.xyz;
        float _S393 = (&kernelContext_26)->params_0->ground_modulus_0;
        float _S394 = (&imp_6)->mat_0.x;
        float3 _S395 = float3(0.0f, 0.0f, 1.0f);
        thread Box_0 _S396 = _S391;
        thread Box_0 _S397 = _S391;
        float _S398 = contact_stiffness_0(_S393, &_S396, _S394, &_S397, _S395);
        float _S399 = (&imp_6)->position_1.z - (&kernelContext_26)->params_0->ground_hi_0 + ((&imp_6)->position_err_1.z - (&kernelContext_26)->params_0->ground_lo_0);
        uint total_points_0;
        if(((&imp_6)->shape_0.x) == 0.0f)
        {
            total_points_0 = 1U;
        }
        else
        {
            total_points_0 = 14U;
        }
        float _S400 = _S398 / float(min(total_points_0, 5U));
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
                thread Box_0 _S401 = _S391;
                float3 _S402 = sample_point_0(&_S401, s_2, &kernelContext_26);
                p_10 = _S402;
            }
            if((_S399 + p_10.z) < 0.0f)
            {
                below_0 = below_0 + 1U;
            }
            s_2 = s_2 + 1U;
        }
        s_2 = 0U;
        load_f_0 = _S388;
        load_t_0 = _S388;
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
                thread Box_0 _S403 = _S391;
                float3 _S404 = sample_point_0(&_S403, s_2, &kernelContext_26);
                p_10 = _S404;
            }
            float depth_4 = - (_S399 + p_10.z);
            if(depth_4 <= 0.0f)
            {
                s_2 = s_2 + 1U;
                continue;
            }
            thread float stored_3;
            thread float diss_2;
            float3 _S405 = penalty_force_0(_S400, (&imp_6)->mat_0.z, (&kernelContext_26)->params_0->ground_friction_0, depth_4, _S395, _S392 + cross((&imp_6)->angular_velocity_1.xyz, p_10), dt_3, below_0, &stored_3, &diss_2, &kernelContext_26);
            float3 load_f_1 = load_f_0 + _S405;
            float3 load_t_1 = load_t_0 + cross(p_10, _S405);
            thread float _S406 = (&imp_6)->ledger_0.x;
            thread float _S407 = (&imp_6)->ledger_0.y;
            comp_add1_0(&_S406, &_S407, diss_2);
            (&imp_6)->ledger_0.y = _S407;
            (&imp_6)->ledger_0.x = _S406;
            load_f_0 = load_f_1;
            load_t_0 = load_t_1;
            s_2 = s_2 + 1U;
        }
    }
    else
    {
        load_f_0 = _S388;
        load_t_0 = _S388;
    }
    float3 load_f_2 = rf_0.xyz + load_f_0;
    float3 load_t_2 = rt_0.xyz + load_t_0;
    float m_2 = (&imp_6)->mat_0.z;
    thread float3 vel_0 = (&imp_6)->velocity_1.xyz;
    thread float3 vel_err_0 = (&imp_6)->velocity_err_1.xyz;
    float3 _S408 = float3(dt_3) ;
    comp_add_0(&vel_0, &vel_err_0, (load_f_2 / float3(m_2)  + (&kernelContext_26)->params_0->gravity_0.xyz) * _S408);
    Quat_0 _S409 = quat_of_0((&imp_6)->rotation_1);
    thread Quat_0 q_14 = _S409;
    thread float4 q_err_0 = (&imp_6)->rotation_err_1;
    thread float3 l_hi_0 = (&imp_6)->momentum_1.xyz;
    thread float3 l_err_0 = (&imp_6)->momentum_err_1.xyz;
    comp_add_0(&l_hi_0, &l_err_0, load_t_2 * _S408);
    float3 l_1 = l_hi_0 + l_err_0;
    thread Quat_0 _S410 = _S409;
    float3 _S411 = world_mul_0(&_S410, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    thread float3 pos_0 = (&imp_6)->position_1.xyz;
    thread float3 pos_err_0 = (&imp_6)->position_err_1.xyz;
    comp_add_0(&pos_0, &pos_err_0, (vel_0 + vel_err_0) * _S408);
    turn_left_0(&q_14, &q_err_0, _S411, dt_3);
    thread Quat_0 _S412 = q_14;
    float3 _S413 = world_mul_0(&_S412, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    (&imp_6)->angular_velocity_1 = float4(_S413, 0.0f);
    thread Quat_0 _S414 = q_14;
    float4 _S415 = quat_vec_0(&_S414);
    (&imp_6)->rotation_1 = _S415;
    (&imp_6)->rotation_err_1 = q_err_0;
    (&imp_6)->momentum_1 = float4(l_hi_0, 0.0f);
    (&imp_6)->momentum_err_1 = float4(l_err_0, 0.0f);
    (&imp_6)->position_1 = float4(pos_0, 0.0f);
    (&imp_6)->position_err_1 = float4(pos_err_0, 0.0f);
    (&imp_6)->velocity_1 = float4(vel_0, 0.0f);
    (&imp_6)->velocity_err_1 = float4(vel_err_0, 0.0f);
    (&imp_6)->cand_0.w = (&imp_6)->cand_0.w + 1U;
    (&imp_6)->geom_0 = float4(1.0f, (&imp_6)->crush_0.w, 0.0f, 0.0f);
    Impactor_natural_0 device* _S416 = (&kernelContext_26)->impactors_0+ii_1;
    _S416->position_1 = packed_float4(imp_6.position_1) ;
    _S416->position_err_1 = packed_float4(imp_6.position_err_1) ;
    _S416->velocity_1 = packed_float4(imp_6.velocity_1) ;
    _S416->velocity_err_1 = packed_float4(imp_6.velocity_err_1) ;
    _S416->angular_velocity_1 = packed_float4(imp_6.angular_velocity_1) ;
    _S416->rotation_1 = packed_float4(imp_6.rotation_1) ;
    _S416->inertia0_2 = packed_float4(imp_6.inertia0_2) ;
    _S416->inertia1_2 = packed_float4(imp_6.inertia1_2) ;
    _S416->inertia2_2 = packed_float4(imp_6.inertia2_2) ;
    _S416->inv0_2 = packed_float4(imp_6.inv0_2) ;
    _S416->inv1_2 = packed_float4(imp_6.inv1_2) ;
    _S416->inv2_2 = packed_float4(imp_6.inv2_2) ;
    _S416->shape_0 = packed_float4(imp_6.shape_0) ;
    _S416->half_1 = packed_float4(imp_6.half_1) ;
    _S416->mat_0 = packed_float4(imp_6.mat_0) ;
    _S416->crush_0 = packed_float4(imp_6.crush_0) ;
    _S416->geom_0 = packed_float4(imp_6.geom_0) ;
    _S416->rotation_err_1 = packed_float4(imp_6.rotation_err_1) ;
    _S416->ledger_0 = packed_float4(imp_6.ledger_0) ;
    _S416->cand_0 = packed_uint4(imp_6.cand_0) ;
    _S416->momentum_1 = packed_float4(imp_6.momentum_1) ;
    _S416->momentum_err_1 = packed_float4(imp_6.momentum_err_1) ;
    uint k_10 = (&imp_6)->cand_0.w - 1U - (&kernelContext_26)->params_0->step_start_0;
    if(k_10 < ((&kernelContext_26)->params_0->record_stride_0))
    {
        uint at_3 = (&kernelContext_26)->params_0->record_base_0 + 2U * (ii_1 * (&kernelContext_26)->params_0->record_stride_0 + k_10);
        *((&kernelContext_26)->scratch_0+at_3) = packed_float4(float4(vel_0 + vel_err_0, 0.0f)) ;
        *((&kernelContext_26)->scratch_0+(at_3 + 1U)) = packed_float4(float4(pos_0 + pos_err_0, 0.0f)) ;
    }
    return;
}

void ground_contact_0(uint c_9, bool account_0, float3 thread* f_1, float3 thread* t_6, KernelContext_0 thread* kernelContext_27)
{
    ChunkStatic_natural_0 device* _S417 = kernelContext_27->chunks_0+c_9;
    WorldPoint_0 _S418 = chunk_world_0(c_9, kernelContext_27);
    float above_0 = _S418.hi_0.z - kernelContext_27->params_0->ground_hi_0 + (_S418.lo_0.z - kernelContext_27->params_0->ground_lo_0) + _S418.rel_0.z;
    if((above_0 - (float4(_S417->half_0) ).w) > 0.0f)
    {
        return;
    }
    Box_0 _S419 = chunk_box_0(c_9, float3(0.0f) , kernelContext_27);
    float _S420 = kernelContext_27->params_0->ground_modulus_0;
    float _S421 = (float4(_S417->cmat_0) ).x;
    float3 _S422 = float3(0.0f, 0.0f, 1.0f);
    thread Box_0 _S423 = _S419;
    thread Box_0 _S424 = _S419;
    float _S425 = contact_stiffness_0(_S420, &_S423, _S421, &_S424, _S422);
    thread Box_0 _S426 = _S419;
    uint _S427 = sample_count_0(&_S426);
    uint s_3 = 0U;
    uint n_8 = 0U;
    for(;;)
    {
        if(s_3 < _S427)
        {
        }
        else
        {
            break;
        }
        thread Box_0 _S428 = _S419;
        float3 _S429 = sample_point_0(&_S428, s_3, kernelContext_27);
        if((above_0 + _S429.z) < 0.0f)
        {
            n_8 = n_8 + 1U;
        }
        s_3 = s_3 + 1U;
    }
    if(n_8 == 0U)
    {
        return;
    }
    thread float3 vc_1;
    thread float3 wc_1;
    chunk_velocity_0(c_9, &vc_1, &wc_1, kernelContext_27);
    thread float4 ledger_2 = float4(*(kernelContext_27->scratch_0+(kernelContext_27->params_0->ledger_base_0 + kernelContext_27->params_0->pair_count_0 + c_9))) ;
    s_3 = 0U;
    for(;;)
    {
        if(s_3 < _S427)
        {
        }
        else
        {
            break;
        }
        thread Box_0 _S430 = _S419;
        float3 _S431 = sample_point_0(&_S430, s_3, kernelContext_27);
        float _S432 = above_0 + _S431.z;
        if(!(_S432 < 0.0f))
        {
            s_3 = s_3 + 1U;
            continue;
        }
        thread float stored_4;
        thread float diss_3;
        float3 _S433 = penalty_force_0(_S425 / float(max(n_8, 5U)), (float4(_S417->center_0) ).w, kernelContext_27->params_0->ground_friction_0, - _S432, _S422, vc_1 + cross(wc_1, _S431), kernelContext_27->params_0->dt_0, n_8, &stored_4, &diss_3, kernelContext_27);
        *f_1 = *f_1 + _S433;
        *t_6 = *t_6 + cross(_S431, _S433);
        thread float _S434 = ledger_2.y;
        thread float _S435 = ledger_2.z;
        comp_add1_0(&_S434, &_S435, diss_3);
        ledger_2.z = _S435;
        ledger_2.y = _S434;
        s_3 = s_3 + 1U;
    }
    if(account_0)
    {
        *(kernelContext_27->scratch_0+(kernelContext_27->params_0->ledger_base_0 + kernelContext_27->params_0->pair_count_0 + c_9)) = packed_float4(ledger_2) ;
    }
    return;
}

[[kernel]] void contact_sums(uint3 id_2 [[thread_position_in_grid]], Params_0 constant* params_5 [[buffer(0)]], Island_natural_0 device* islands_5 [[buffer(9)]], uint device* index_5 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_5 [[buffer(3)]], packed_float4 device* state_5 [[buffer(6)]], packed_float4 device* scratch_5 [[buffer(8)]], packed_float4 device* contact_state_5 [[buffer(11)]], packed_float4 device* loads_5 [[buffer(5)]], Impactor_natural_0 device* impactors_5 [[buffer(10)]], BondStatic_natural_0 device* bonds_5 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_5 [[buffer(7)]], MaterialTable_0 constant* materials_5 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_28;
    (&kernelContext_28)->params_0 = params_5;
    (&kernelContext_28)->islands_0 = islands_5;
    (&kernelContext_28)->index_0 = index_5;
    (&kernelContext_28)->chunks_0 = chunks_5;
    (&kernelContext_28)->state_0 = state_5;
    (&kernelContext_28)->scratch_0 = scratch_5;
    (&kernelContext_28)->contact_state_0 = contact_state_5;
    (&kernelContext_28)->loads_0 = loads_5;
    (&kernelContext_28)->impactors_0 = impactors_5;
    (&kernelContext_28)->bonds_0 = bonds_5;
    (&kernelContext_28)->bond_dyn_0 = bond_dyn_5;
    (&kernelContext_28)->materials_0 = materials_5;
    threadgroup array<float4, int(32)> g_part_a_5;
    (&kernelContext_28)->g_part_a_0 = &g_part_a_5;
    threadgroup array<float4, int(32)> g_part_b_5;
    (&kernelContext_28)->g_part_b_0 = &g_part_b_5;
    threadgroup uint g_run_5;
    (&kernelContext_28)->g_run_0 = &g_run_5;
    threadgroup uint g_halt_5;
    (&kernelContext_28)->g_halt_0 = &g_halt_5;
    threadgroup uint g_wide_run_5;
    (&kernelContext_28)->g_wide_run_0 = &g_wide_run_5;
    uint g_0 = id_2.x;
    bool _S436;
    if(g_0 >= (params_5->seg_count_0))
    {
        _S436 = true;
    }
    else
    {
        bool _S437 = stopped_0(&kernelContext_28);
        _S436 = _S437;
    }
    if(_S436)
    {
        return;
    }
    uint _S438 = 3U * g_0;
    uint _S439 = (&kernelContext_28)->index_0[(&kernelContext_28)->params_0->seg_index_0 + _S438];
    uint begin_0 = (&kernelContext_28)->index_0[(&kernelContext_28)->params_0->seg_index_0 + _S438 + 1U];
    uint _S440 = (&kernelContext_28)->index_0[(&kernelContext_28)->params_0->seg_index_0 + _S438 + 2U];
    float3 _S441 = float3(0.0f) ;
    thread float3 f_2 = _S441;
    thread float3 t_7 = _S441;
    uint e_2 = begin_0;
    for(;;)
    {
        if(e_2 < _S440)
        {
        }
        else
        {
            break;
        }
        uint entry_1 = (&kernelContext_28)->index_0[e_2];
        if(entry_1 == 2147483648U)
        {
            ground_contact_0(_S439, true, &f_2, &t_7, &kernelContext_28);
            e_2 = e_2 + 1U;
            continue;
        }
        uint _S442 = 2U * entry_1;
        f_2 = f_2 + (float4(*((&kernelContext_28)->scratch_0+((&kernelContext_28)->params_0->slot_base_0 + _S442))) ).xyz;
        t_7 = t_7 + (float4(*((&kernelContext_28)->scratch_0+((&kernelContext_28)->params_0->slot_base_0 + _S442 + 1U))) ).xyz;
        e_2 = e_2 + 1U;
    }
    uint _S443 = 2U * g_0;
    *((&kernelContext_28)->scratch_0+((&kernelContext_28)->params_0->seg_base_0 + _S443)) = packed_float4(float4(f_2, 0.0f)) ;
    *((&kernelContext_28)->scratch_0+((&kernelContext_28)->params_0->seg_base_0 + _S443 + 1U)) = packed_float4(float4(t_7, 0.0f)) ;
    return;
}

bool contact_stopped_0(const Island_natural_0 thread* isl_0, KernelContext_0 thread* kernelContext_29)
{
    uint4 _S444 = uint4((kernelContext_29->islands_0+kernelContext_29->params_0->halt_index_0)->info_0) ;
    bool _S445;
    if(((_S444.z) & 1U) != 0U)
    {
        _S445 = true;
    }
    else
    {
        uint _S446 = _S444.y;
        if(_S446 != 0U)
        {
            _S445 = _S446 <= ((uint4(isl_0->info_0) ).w);
        }
        else
        {
            _S445 = false;
        }
    }
    return _S445;
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
    float4 rotation_err_0;
    float4 momentum_0;
    float4 momentum_err_0;
};

bool contact_stopped_1(const Island_0 thread* isl_1, KernelContext_0 thread* kernelContext_30)
{
    uint4 _S447 = uint4((kernelContext_30->islands_0+kernelContext_30->params_0->halt_index_0)->info_0) ;
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
            _S448 = _S449 <= (isl_1->info_0.w);
        }
        else
        {
            _S448 = false;
        }
    }
    return _S448;
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
    float3 _S450 = float3(0.0f) ;
    (&rg_0)->torque_0 = _S450;
    (&rg_0)->a_7 = _S450;
    (&rg_0)->alpha_0 = _S450;
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
    float3 _S451 = float3(0.0f) ;
    (&rg_1)->torque_0 = _S451;
    (&rg_1)->a_7 = _S451;
    (&rg_1)->alpha_0 = _S451;
    return rg_1;
}

void write_probe_0(uint slot_1, uint k_11, float value_0, KernelContext_0 thread* kernelContext_31)
{
    uint at_4 = kernelContext_31->params_0->probe_base_0 * 4U + slot_1 * kernelContext_31->params_0->probe_stride_0 + k_11;
    thread float4 v_9 = float4(*(kernelContext_31->scratch_0+at_4 / 4U)) ;
    v_9[at_4 % 4U] = value_0;
    *(kernelContext_31->scratch_0+at_4 / 4U) = packed_float4(v_9) ;
    return;
}

void record_probes_0(const Island_0 thread* isl_4, const Rigid_0 thread* rg_2, uint k_12, KernelContext_0 thread* kernelContext_32)
{
    uint4 _S452 = isl_4->probes_0;
    uint at_5 = isl_4->probes_0.x;
    for(;;)
    {
        if(at_5 < (_S452.y))
        {
        }
        else
        {
            break;
        }
        uint4 info_2 = (as_type<uint4>((float4(*(kernelContext_32->loads_0+at_5)) )));
        float4 _S453 = float4(*(kernelContext_32->loads_0+(at_5 + 1U))) ;
        float4 _S454 = float4(*(kernelContext_32->loads_0+(at_5 + 2U))) ;
        float4 _S455 = float4(*(kernelContext_32->loads_0+(at_5 + 3U))) ;
        uint kind_0 = info_2.x;
        uint i_5 = info_2.y;
        float value_1;
        if(kind_0 == 0U)
        {
            float3 _S456 = rg_2->pos_1 - _S454.xyz + (rg_2->pos_err_1 - _S455.xyz);
            float3 _S457 = rotate_0(&rg_2->rot_0, (float4((kernelContext_32->chunks_0+i_5)->center_0) ).xyz + (float4(*(kernelContext_32->state_0+4U * i_5)) ).xyz);
            value_1 = dot(_S456 + _S457, _S453.xyz);
        }
        else
        {
            if(kind_0 == 1U)
            {
                uint _S458 = 4U * i_5;
                float3 _S459 = rotate_0(&rg_2->rot_0, (float4((kernelContext_32->chunks_0+i_5)->center_0) ).xyz + (float4(*(kernelContext_32->state_0+_S458)) ).xyz - isl_4->com_0.xyz);
                float3 _S460 = rg_2->vel_1 + rg_2->vel_err_1 + cross(rg_2->w_4, _S459);
                float3 _S461 = rotate_0(&rg_2->rot_0, (float4(*(kernelContext_32->state_0+(_S458 + 2U))) ).xyz);
                value_1 = dot(_S460 + _S461, _S453.xyz);
            }
            else
            {
                if(kind_0 == 2U)
                {
                    uint _S462 = 3U * i_5;
                    float3 f_3 = (float4(*(kernelContext_32->scratch_0+_S462)) ).xyz;
                    bool _S463 = (info_2.z) == 0U;
                    float3 mc_0;
                    if(_S463)
                    {
                        mc_0 = (float4(*(kernelContext_32->scratch_0+(_S462 + 1U))) ).xyz;
                    }
                    else
                    {
                        mc_0 = (float4(*(kernelContext_32->scratch_0+(_S462 + 2U))) ).xyz;
                    }
                    float3 fc_0;
                    if(_S463)
                    {
                        fc_0 = f_3;
                    }
                    else
                    {
                        fc_0 = - f_3;
                    }
                    value_1 = dot(fc_0, _S453.xyz) + dot(mc_0, _S454.xyz);
                }
                else
                {
                    uint _S464 = 4U * i_5;
                    float3 _S465 = rotate_0(&rg_2->rot_0, float3((float4(*(kernelContext_32->state_0+(_S464 + 1U))) ).w, (float4(*(kernelContext_32->state_0+(_S464 + 2U))) ).w, (float4(*(kernelContext_32->state_0+(_S464 + 3U))) ).w));
                    value_1 = dot(_S465, _S453.xyz);
                }
            }
        }
        write_probe_0(info_2.w, k_12, value_1, kernelContext_32);
        at_5 = at_5 + 4U;
    }
    return;
}

float time_since_0(float4 origin_0, uint k_13, float dt_4, KernelContext_0 thread* kernelContext_33)
{
    return kernelContext_33->params_0->t_hi_0 - origin_0.x + (kernelContext_33->params_0->t_lo_0 - origin_0.y) + float(k_13) * dt_4;
}

float table_eval_0(uint offset_0, uint count_2, float tau_0, KernelContext_0 thread* kernelContext_34)
{
    float4 _S466 = float4(*(kernelContext_34->loads_0+offset_0)) ;
    if(tau_0 <= (_S466.x))
    {
        return _S466.y;
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
        uint _S467 = offset_0 + i_6;
        float4 _S468 = float4(*(kernelContext_34->loads_0+_S467)) ;
        float _S469 = _S468.x;
        if(tau_0 <= _S469)
        {
            float4 _S470 = float4(*(kernelContext_34->loads_0+(_S467 - 1U))) ;
            float _S471 = _S470.x;
            float _S472 = _S470.y;
            return _S472 + (tau_0 - _S471) / max(_S469 - _S471, 1.00000000317107685e-30f) * (_S468.y - _S472);
        }
        i_6 = i_6 + 1U;
    }
    return (float4(*(kernelContext_34->loads_0+(offset_0 + count_2 - 1U))) ).y;
}

float eval_function_0(uint term_0, uint k_14, float dt_5, float shift_0, KernelContext_0 thread* kernelContext_35)
{
    uint _S473 = 5U * term_0;
    uint4 info_3 = (as_type<uint4>((float4(*(kernelContext_35->loads_0+_S473)) )));
    float4 _S474 = float4(*(kernelContext_35->loads_0+(_S473 + 3U))) ;
    float4 _S475 = float4(*(kernelContext_35->loads_0+(_S473 + 4U))) ;
    uint kind_1 = info_3.z;
    if(kind_1 == 0U)
    {
        return _S474.z;
    }
    float _S476 = time_since_0(_S474, k_14, dt_5, kernelContext_35);
    float tau_1 = _S476 + shift_0;
    float shape_1;
    if(kind_1 == 1U)
    {
        if(tau_1 <= 0.0f)
        {
            shape_1 = 0.0f;
        }
        else
        {
            float _S477 = _S475.x;
            if(tau_1 >= _S477)
            {
                shape_1 = _S475.y;
            }
            else
            {
                shape_1 = _S475.y * tau_1 / _S477;
            }
        }
        return shape_1;
    }
    bool _S478;
    if(kind_1 == 2U)
    {
        if(tau_1 < 0.0f)
        {
            _S478 = true;
        }
        else
        {
            _S478 = tau_1 > (_S475.x);
        }
        if(_S478)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S475.y * sin(3.14159274101257324f * tau_1 / _S475.x);
        }
        return shape_1;
    }
    if(kind_1 == 3U)
    {
        float sn_0 = tau_1 / _S475.y;
        if(sn_0 < 0.0f)
        {
            _S478 = true;
        }
        else
        {
            _S478 = sn_0 > 1.0f;
        }
        if(_S478)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S475.x * (1.0f - sn_0) * exp(- _S475.z * sn_0);
        }
        return shape_1;
    }
    if(kind_1 == 4U)
    {
        float _S479 = table_eval_0(info_3.w, (as_type<uint>((_S475.x))), tau_1, kernelContext_35);
        return _S479;
    }
    if(kind_1 == 5U)
    {
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float sn_1 = tau_1 / _S475.x;
        if(sn_1 < 0.0f)
        {
            _S478 = true;
        }
        else
        {
            _S478 = sn_1 > 1.0f;
        }
        if(_S478)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = (1.0f - sn_1) * exp(- _S475.y * sn_1);
        }
        float clearing_0 = _S474.w;
        float relax_0;
        if(clearing_0 > 0.0f)
        {
            relax_0 = max(1.0f - tau_1 / clearing_0, 0.0f);
        }
        else
        {
            relax_0 = 0.0f;
        }
        float _S480 = _S475.w;
        return (_S480 + (_S475.z - _S480) * relax_0) * shape_1;
    }
    if(kind_1 == 7U)
    {
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float _S481 = _S475.y;
        if(tau_1 < _S481)
        {
            return _S475.x;
        }
        float s_4 = tau_1 - _S481;
        float _S482 = _S475.w;
        if(s_4 > _S482)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S475.z * sin(3.14159274101257324f * s_4 / _S482);
        }
        return shape_1;
    }
    float _S483 = _S475.x;
    if(_S483 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp(1.0f - tau_1 / _S483, 0.0f, 1.0f);
}

void record_chunk_load_0(uint c_10, float3 f_4, float3 t_8, KernelContext_0 thread* kernelContext_36)
{
    if((kernelContext_36->params_0->solve_mode_0) == 0U)
    {
        return;
    }
    uint _S484 = 2U * c_10;
    *(kernelContext_36->scratch_0+(kernelContext_36->params_0->cload_base_0 + _S484)) = packed_float4(float4(f_4, 0.0f)) ;
    *(kernelContext_36->scratch_0+(kernelContext_36->params_0->cload_base_0 + _S484 + 1U)) = packed_float4(float4(t_8, 0.0f)) ;
    *(kernelContext_36->scratch_0+(kernelContext_36->params_0->cframe_base_0 + _S484)) = packed_float4(float4((float4(*(kernelContext_36->scratch_0+(kernelContext_36->params_0->cframe_base_0 + _S484))) ).xyz + f_4, 0.0f)) ;
    *(kernelContext_36->scratch_0+(kernelContext_36->params_0->cframe_base_0 + _S484 + 1U)) = packed_float4(float4((float4(*(kernelContext_36->scratch_0+(kernelContext_36->params_0->cframe_base_0 + _S484 + 1U))) ).xyz + t_8, 0.0f)) ;
    return;
}

void chunk_external_0(uint _S485, uint _S486, const Quat_0 thread* _S487, uint _S488, float _S489, bool _S490, float3 thread* _S491, float3 thread* _S492, KernelContext_0 thread* kernelContext_37)
{
    bool _S493;
    ChunkStatic_natural_0 device* _S494 = kernelContext_37->chunks_0+_S486;
    float3 _S495 = float3(0.0f) ;
    *_S491 = _S495;
    *_S492 = _S495;
    uint4 _S496 = uint4(_S494->load_range_0) ;
    uint term_1 = _S496.x;
    for(;;)
    {
        if(term_1 < (_S496.y))
        {
        }
        else
        {
            break;
        }
        uint _S497 = 5U * term_1;
        uint _S498 = (as_type<uint4>((float4(*(kernelContext_37->loads_0+_S497)) ))).y;
        if(_S498 == 2U)
        {
            term_1 = term_1 + 1U;
            continue;
        }
        float4 _S499 = float4(*(kernelContext_37->loads_0+(_S497 + 1U))) ;
        float4 _S500 = float4(*(kernelContext_37->loads_0+(_S497 + 2U))) ;
        float _S501 = eval_function_0(term_1, _S488, _S489, 0.0f, kernelContext_37);
        if(_S498 == 0U)
        {
            _S493 = true;
        }
        else
        {
            _S493 = _S498 == 3U;
        }
        float3 fw_0;
        if(_S493)
        {
            fw_0 = _S499.xyz * float3(_S501) ;
        }
        else
        {
            float3 _S502 = rotate_0(_S487, _S499.xyz);
            fw_0 = _S502 * float3((- _S501 * _S499.w)) ;
        }
        float3 lever_0;
        if(_S498 == 3U)
        {
            lever_0 = _S500.xyz - (float4(*(kernelContext_37->state_0+4U * _S485)) ).xyz;
        }
        else
        {
            lever_0 = _S500.xyz;
        }
        *_S491 = *_S491 + fw_0;
        float3 _S503 = rotate_0(_S487, lever_0);
        *_S492 = *_S492 + cross(_S503, fw_0);
        term_1 = term_1 + 1U;
    }
    if(_S490)
    {
        _S493 = ((uint4(_S494->cinfo_0) ).z) != 0U;
    }
    else
    {
        _S493 = false;
    }
    if(_S493)
    {
        uint4 _S504 = uint4(_S494->cinfo_0) ;
        uint g_1 = _S504.x;
        for(;;)
        {
            if(g_1 < (_S504.y))
            {
            }
            else
            {
                break;
            }
            uint _S505 = 2U * g_1;
            *_S491 = *_S491 + (float4(*(kernelContext_37->scratch_0+(kernelContext_37->params_0->seg_base_0 + _S505))) ).xyz;
            *_S492 = *_S492 + (float4(*(kernelContext_37->scratch_0+(kernelContext_37->params_0->seg_base_0 + _S505 + 1U))) ).xyz;
            g_1 = g_1 + 1U;
        }
    }
    return;
}

float settled_chunk_load_0(uint c_11, const Quat_0 thread* rot_1, uint k_15, float dt_6, bool contact_0, KernelContext_0 thread* kernelContext_38)
{
    thread float3 f_5;
    thread float3 t_9;
    chunk_external_0(c_11, c_11, rot_1, k_15, dt_6, contact_0, &f_5, &t_9, kernelContext_38);
    record_chunk_load_0(c_11, f_5, t_9, kernelContext_38);
    return length(f_5);
}

void net_load_0(uint c_12, const Island_natural_0 thread* isl_5, const Rigid_0 thread* rg_3, uint k_16, float dt_7, bool contact_1, float3 thread* f_6, float3 thread* t_10, KernelContext_0 thread* kernelContext_39)
{
    ChunkStatic_natural_0 device* _S506 = kernelContext_39->chunks_0+c_12;
    thread float3 fl_0;
    thread float3 tl_0;
    chunk_external_0(c_12, c_12, &rg_3->rot_0, k_16, dt_7, contact_1, &fl_0, &tl_0, kernelContext_39);
    float4 _S507 = float4(_S506->center_0) ;
    float3 fc_1 = fl_0 + kernelContext_39->params_0->gravity_0.xyz * float3(_S507.w) ;
    float3 _S508 = _S507.xyz;
    float3 _S509 = (float4(isl_5->com_0) ).xyz;
    float3 _S510 = rotate_0(&rg_3->rot_0, _S508 + (float4(*(kernelContext_39->state_0+4U * c_12)) ).xyz - _S509);
    *f_6 = *f_6 + fc_1;
    *t_10 = *t_10 + (cross(_S510, fc_1) + tl_0);
    uint4 _S511 = uint4(_S506->load_range_0) ;
    uint term_2 = _S511.x;
    for(;;)
    {
        if(term_2 < (_S511.y))
        {
        }
        else
        {
            break;
        }
        uint _S512 = 5U * term_2;
        if(((as_type<uint4>((float4(*(kernelContext_39->loads_0+_S512)) ))).y) != 2U)
        {
            term_2 = term_2 + 1U;
            continue;
        }
        float _S513 = eval_function_0(term_2, k_16, dt_7, 0.0f, kernelContext_39);
        float3 _S514 = float3(_S513) ;
        float3 _S515 = rotate_0(&rg_3->rot_0, (float4(*(kernelContext_39->loads_0+(_S512 + 1U))) ).xyz * _S514);
        *f_6 = *f_6 + _S515;
        float3 _S516 = rotate_0(&rg_3->rot_0, _S508 - _S509);
        float3 _S517 = cross(_S516, _S515);
        float3 _S518 = rotate_0(&rg_3->rot_0, (float4(*(kernelContext_39->loads_0+(_S512 + 2U))) ).xyz * _S514);
        *t_10 = *t_10 + (_S517 + _S518);
        term_2 = term_2 + 1U;
    }
    return;
}

void net_load_1(uint c_13, const Island_0 thread* isl_6, const Rigid_0 thread* rg_4, uint k_17, float dt_8, bool contact_2, float3 thread* f_7, float3 thread* t_11, KernelContext_0 thread* kernelContext_40)
{
    ChunkStatic_natural_0 device* _S519 = kernelContext_40->chunks_0+c_13;
    thread float3 fl_1;
    thread float3 tl_1;
    chunk_external_0(c_13, c_13, &rg_4->rot_0, k_17, dt_8, contact_2, &fl_1, &tl_1, kernelContext_40);
    float4 _S520 = float4(_S519->center_0) ;
    float3 fc_2 = fl_1 + kernelContext_40->params_0->gravity_0.xyz * float3(_S520.w) ;
    float3 _S521 = _S520.xyz;
    float3 _S522 = isl_6->com_0.xyz;
    float3 _S523 = rotate_0(&rg_4->rot_0, _S521 + (float4(*(kernelContext_40->state_0+4U * c_13)) ).xyz - _S522);
    *f_7 = *f_7 + fc_2;
    *t_11 = *t_11 + (cross(_S523, fc_2) + tl_1);
    uint4 _S524 = uint4(_S519->load_range_0) ;
    uint term_3 = _S524.x;
    for(;;)
    {
        if(term_3 < (_S524.y))
        {
        }
        else
        {
            break;
        }
        uint _S525 = 5U * term_3;
        if(((as_type<uint4>((float4(*(kernelContext_40->loads_0+_S525)) ))).y) != 2U)
        {
            term_3 = term_3 + 1U;
            continue;
        }
        float _S526 = eval_function_0(term_3, k_17, dt_8, 0.0f, kernelContext_40);
        float3 _S527 = float3(_S526) ;
        float3 _S528 = rotate_0(&rg_4->rot_0, (float4(*(kernelContext_40->loads_0+(_S525 + 1U))) ).xyz * _S527);
        *f_7 = *f_7 + _S528;
        float3 _S529 = rotate_0(&rg_4->rot_0, _S521 - _S522);
        float3 _S530 = cross(_S529, _S528);
        float3 _S531 = rotate_0(&rg_4->rot_0, (float4(*(kernelContext_40->loads_0+(_S525 + 2U))) ).xyz * _S527);
        *t_11 = *t_11 + (_S530 + _S531);
        term_3 = term_3 + 1U;
    }
    return;
}

void rigid_acceleration_0(const Island_natural_0 thread* isl_7, Rigid_0 thread* rg_5, float3 f_8, float3 t_12)
{
    float4 _S532 = float4(isl_7->inertia0_0) ;
    float4 _S533 = float4(isl_7->inertia1_0) ;
    float4 _S534 = float4(isl_7->inertia2_0) ;
    thread Quat_0 _S535 = rg_5->rot_0;
    float3 _S536 = world_mul_0(&_S535, _S532, _S533, _S534, rg_5->w_4);
    rg_5->a_7 = f_8 / float3((float4(isl_7->com_0) ).w) ;
    float4 _S537 = float4(isl_7->inv0_0) ;
    float4 _S538 = float4(isl_7->inv1_0) ;
    float4 _S539 = float4(isl_7->inv2_0) ;
    float3 _S540 = t_12 - cross(rg_5->w_4, _S536);
    thread Quat_0 _S541 = rg_5->rot_0;
    float3 _S542 = world_mul_0(&_S541, _S537, _S538, _S539, _S540);
    rg_5->alpha_0 = _S542;
    rg_5->torque_0 = t_12;
    return;
}

void rigid_acceleration_1(const Island_0 thread* isl_8, Rigid_0 thread* rg_6, float3 f_9, float3 t_13)
{
    thread Quat_0 _S543 = rg_6->rot_0;
    float3 _S544 = world_mul_0(&_S543, isl_8->inertia0_0, isl_8->inertia1_0, isl_8->inertia2_0, rg_6->w_4);
    rg_6->a_7 = f_9 / float3(isl_8->com_0.w) ;
    float3 _S545 = t_13 - cross(rg_6->w_4, _S544);
    thread Quat_0 _S546 = rg_6->rot_0;
    float3 _S547 = world_mul_0(&_S546, isl_8->inv0_0, isl_8->inv1_0, isl_8->inv2_0, _S545);
    rg_6->alpha_0 = _S547;
    rg_6->torque_0 = t_13;
    return;
}

float3 turn_difference_0(float3 omega_1, float dt_9, float3 v_10)
{
    float _S548 = length(omega_1);
    float angle_3 = _S548 * dt_9;
    if(angle_3 < 1.00000000317107685e-30f)
    {
        return float3(0.0f) ;
    }
    float3 a_8 = omega_1 / float3(_S548) ;
    float s_5 = sin(0.5f * angle_3);
    float3 av_0 = cross(a_8, v_10);
    return av_0 * float3(sin(angle_3))  + cross(a_8, av_0) * float3((2.0f * s_5 * s_5)) ;
}

void integrate_rigid_0(const Island_natural_0 thread* isl_9, Rigid_0 thread* rg_7, float dt_10)
{
    float3 _S549 = float3(dt_10) ;
    comp_add_0(&rg_7->l_2, &rg_7->l_err_1, rg_7->torque_0 * _S549);
    float3 l_3 = rg_7->l_2 + rg_7->l_err_1;
    comp_add_0(&rg_7->vel_1, &rg_7->vel_err_1, rg_7->a_7 * _S549);
    float3 vel_2 = rg_7->vel_1 + rg_7->vel_err_1;
    float4 _S550 = float4(isl_9->inv0_0) ;
    float4 _S551 = float4(isl_9->inv1_0) ;
    float4 _S552 = float4(isl_9->inv2_0) ;
    thread Quat_0 _S553 = rg_7->rot_0;
    float3 _S554 = world_mul_0(&_S553, _S550, _S551, _S552, l_3);
    float3 _S555 = vel_2 * _S549;
    float3 _S556 = (float4(isl_9->com_0) ).xyz;
    thread Quat_0 _S557 = rg_7->rot_0;
    float3 _S558 = rotate_0(&_S557, _S556);
    comp_add_0(&rg_7->pos_1, &rg_7->pos_err_1, _S555 - turn_difference_0(_S554, dt_10, _S558));
    turn_left_0(&rg_7->rot_0, &rg_7->rot_err_0, _S554, dt_10);
    thread Quat_0 _S559 = rg_7->rot_0;
    float3 _S560 = world_mul_0(&_S559, _S550, _S551, _S552, l_3);
    rg_7->w_4 = _S560;
    return;
}

void integrate_rigid_1(const Island_0 thread* isl_10, Rigid_0 thread* rg_8, float dt_11)
{
    float3 _S561 = float3(dt_11) ;
    comp_add_0(&rg_8->l_2, &rg_8->l_err_1, rg_8->torque_0 * _S561);
    float3 l_4 = rg_8->l_2 + rg_8->l_err_1;
    comp_add_0(&rg_8->vel_1, &rg_8->vel_err_1, rg_8->a_7 * _S561);
    float3 vel_3 = rg_8->vel_1 + rg_8->vel_err_1;
    float4 _S562 = isl_10->inv0_0;
    float4 _S563 = isl_10->inv1_0;
    float4 _S564 = isl_10->inv2_0;
    thread Quat_0 _S565 = rg_8->rot_0;
    float3 _S566 = world_mul_0(&_S565, isl_10->inv0_0, isl_10->inv1_0, isl_10->inv2_0, l_4);
    float3 _S567 = vel_3 * _S561;
    float3 _S568 = isl_10->com_0.xyz;
    thread Quat_0 _S569 = rg_8->rot_0;
    float3 _S570 = rotate_0(&_S569, _S568);
    comp_add_0(&rg_8->pos_1, &rg_8->pos_err_1, _S567 - turn_difference_0(_S566, dt_11, _S570));
    turn_left_0(&rg_8->rot_0, &rg_8->rot_err_0, _S566, dt_11);
    thread Quat_0 _S571 = rg_8->rot_0;
    float3 _S572 = world_mul_0(&_S571, _S562, _S563, _S564, l_4);
    rg_8->w_4 = _S572;
    return;
}

bool connected_0(const JointState_0 thread* st_0, bool has_rebar_0)
{
    bool _S573;
    if((st_0->damage_0) < 1.0f)
    {
        _S573 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S573 = (st_0->rebar_broken_0) == 0.0f;
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
    float4 _S585 = mat_1->dif_0;
    float ref_0 = mat_1->dif_0.x;
    if(r_6 <= ref_0)
    {
        return 1.0f;
    }
    float _S586 = _S585.z;
    float f_10;
    if(r_6 <= _S586)
    {
        float _S587 = (metal::fast::divide((r_6), (ref_0)));
        float _S588 = (metal::fast::pow((_S587), (_S585.y)));
        f_10 = _S588;
    }
    else
    {
        float _S589 = (metal::fast::divide((_S586), (ref_0)));
        float _S590 = (metal::fast::pow((_S589), (_S585.y)));
        float _S591 = (metal::fast::divide((r_6), (_S586)));
        float _S592 = (metal::fast::pow((_S591), (_S585.w)));
        f_10 = _S590 * _S592;
    }
    return clamp(f_10, 1.0f, mat_1->misc_0.x);
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
    float fc_3 = mat_3->strength_0.y * multiplier_0;
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
    float _S600 = (metal::fast::divide((m_4->compression_0), (fc_3)));
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
float2 damage_increment_0(uint kind_3, float kappa_old_0, float lambda_0, float r_8, float d_old_0, float psi_0)
{
    float _S605 = damage_law_0(kind_3, lambda_0, r_8);
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
    if(kind_3 == 0U)
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
    uint count_3;
    float h0_0 = 0.5f * w0_0;
    float h1_0 = 0.5f * w1_0;
    float _S610 = - h0_0;
    float _S611 = - h1_0;
    array<float2, int(4)> _S612 = { { float2(_S610, _S611), float2(h0_0, _S611), float2(h0_0, h1_0), float2(_S610, h1_0) } };
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
        uint _S613 = i_7;
        uint _S614 = i_7 + 1U;
        uint _S615 = _S614 % 4U;
        float _S616 = _S612[i_7].y;
        float _S617 = _S612[i_7].x;
        float fp_0 = dz_0 + ax_0 * _S616 - ay_0 * _S617;
        float _S618 = _S612[_S615].y;
        float _S619 = _S612[_S615].x;
        float fq_0 = dz_0 + ax_0 * _S618 - ay_0 * _S619;
        bool _S620 = fp_0 < 0.0f;
        if(_S620)
        {
            uint _S621 = count_4 + 1U;
            poly_0[count_4] = _S612[_S613];
            count_3 = _S621;
        }
        else
        {
            count_3 = count_4;
        }
        if(_S620 != (fq_0 < 0.0f))
        {
            float t_14 = fp_0 / (fp_0 - fq_0);
            uint _S622 = count_3 + 1U;
            poly_0[count_3] = float2(_S617 + t_14 * (_S619 - _S617), _S616 + t_14 * (_S618 - _S616));
            count_4 = _S622;
        }
        else
        {
            count_4 = count_3;
        }
        i_7 = _S614;
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
        float _S623 = o_1.x;
        float x0_0 = poly_0[i_7].x - _S623;
        float _S624 = o_1.y;
        float y0_0 = poly_0[i_7].y - _S624;
        uint _S625 = i_7 + 1U;
        uint _S626 = _S625 % count_4;
        float x1_0 = poly_0[_S626].x - _S623;
        float y1_0 = poly_0[_S626].y - _S624;
        float _S627 = x0_0 * y1_0;
        float _S628 = x1_0 * y0_0;
        float cr_0 = _S627 - _S628;
        float a_10 = a_9 + cr_0 / 2.0f;
        float sx_1 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        float sy_1 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        float ixx_1 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        float iyy_1 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        float ixy_1 = ixy_0 + (_S627 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S628) * cr_0 / 24.0f;
        i_7 = _S625;
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
    float _S629 = a_9 * cx_0;
    (*region_0)[int(3)] = ixx_0 - _S629 * cx_0;
    (*region_0)[int(4)] = iyy_0 - a_9 * cy_0 * cy_0;
    (*region_0)[int(5)] = ixy_0 - _S629 * cy_0;
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
    float _S630 = a_11 * fc_4;
    float _S631 = - ay_1;
    return float4(k_18 * a_11 * fc_4, k_18 * (_S630 * r_9[int(2)] + (_S631 * r_9[int(5)] + ax_1 * r_9[int(4)])), - k_18 * (_S630 * r_9[int(1)] + (_S631 * r_9[int(3)] + ax_1 * r_9[int(5)])), 0.5f * k_18 * (_S630 * fc_4 + ay_1 * ay_1 * r_9[int(3)] + ax_1 * ax_1 * r_9[int(4)] - 2.0f * ax_1 * ay_1 * r_9[int(5)]));
}

float signum_0(float x_9)
{
    float _S632;
    if(((as_type<uint>((x_9))) & 2147483648U) != 0U)
    {
        _S632 = -1.0f;
    }
    else
    {
        _S632 = 1.0f;
    }
    return _S632;
}

float2 return_map_0(float k_19, float total_2, float plastic_0, float cap_0)
{
    float trial_0 = k_19 * (total_2 - plastic_0);
    if((abs(trial_0)) <= cap_0)
    {
        return float2(trial_0, 0.0f);
    }
    float f_11 = cap_0 * signum_0(trial_0);
    float _S633 = (metal::fast::divide((trial_0 - f_11), (k_19)));
    return float2(f_11, _S633);
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
                    float _S647 = SPRING_AT_0[i_8] * w0_2;
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
                        float di_0 = _S643 + _S641 * s2_0 - _S642 * _S647;
                        if(di_0 < 0.0f)
                        {
                            float f_12 = ki_0 * di_0;
                            float m1_2 = m1_0 + f_12 * s2_0;
                            float m2_2 = m2_0 - f_12 * _S647;
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
                    float _S666 = SPRING_AT_0[i_9] * w0_3;
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
                        float di_1 = _S665 + _S663 * (SPRING_AT_0[j_6] * w1_3) - _S664 * _S666;
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

float life_rate_0(const JointMaterial_0 constant* mat_6, float s_6)
{
    if(s_6 <= 0.0f)
    {
        return 0.0f;
    }
    float _S672 = mat_6->misc_0.y;
    float _S673 = _S672 + 1.0f;
    float _S674 = (metal::fast::pow((s_6), (_S672)));
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
    Measures_0 measures_0;
};

JointResponse_0 joint_evaluate_0(const JointMaterial_0 constant* mat_7, const JointBond_natural_0 thread* b_27, const JointState_0 thread* state_7, float3 d_lin_2, float3 d_ang_2, float dt_12, bool fracture_1)
{
    float4 _S676 = float4(b_27->stiff0_0) ;
    float kn_3 = _S676.x;
    float ks_2 = _S676.y;
    float kb1_0 = _S676.z;
    float kb2_0 = _S676.w;
    float4 _S677 = float4(b_27->stiff1_0) ;
    float kt_2 = _S677.x;
    bool has_rebar_1 = (_S677.w) != 0.0f;
    uint kind_4 = mat_7->kind_flags_0.x;
    uint flags_1 = mat_7->kind_flags_0.y;
    bool softening_0 = (flags_1 & 1U) != 0U;
    thread JointState_0 st_1 = *state_7;
    bool _S678 = connected_0(state_7, has_rebar_1);
    float3 qe_lin_0 = d_lin_2 * float3(ks_2, ks_2, kn_3);
    float3 qe_ang_0 = d_ang_2 * float3(kb1_0, kb2_0, kt_2);
    Measures_0 _S679 = stress_measures_0(b_27, qe_lin_0, qe_ang_0);
    float _S680 = max(max(_S679.tension_0, _S679.shear_0), _S679.compression_0);
    bool _S681 = dt_12 > 0.0f;
    float dif_1;
    if(_S681)
    {
        float _S682 = (metal::fast::divide((_S680 - (&st_1)->governing_stress_0), (dt_12)));
        float raw_0 = (metal::fast::divide((max(_S682, 0.0f)), (mat_7->misc_0.w)));
        float tau_2 = _S677.z;
        if((flags_1 & 16U) != 0U)
        {
            float _S683 = (metal::fast::divide((dt_12), (tau_2)));
            dif_1 = - expm1_accurate_0(- _S683);
        }
        else
        {
            float _S684 = (metal::fast::divide((dt_12), (tau_2)));
            dif_1 = min(_S684, 1.0f);
        }
        (&st_1)->strain_rate_0 = (&st_1)->strain_rate_0 + (raw_0 - (&st_1)->strain_rate_0) * dif_1;
        (&st_1)->governing_stress_0 = _S680;
    }
    if((flags_1 & 32U) != 0U)
    {
        float _S685 = dif_factor_0(mat_7, (&st_1)->strain_rate_0);
        dif_1 = _S685;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = (float4(b_27->geom1_0) ).w;
    float _S686 = weibull_0 * dif_1;
    float _S687 = fatigue_factor_0(mat_7, (&st_1)->life_0);
    float multiplier_1 = _S686 * _S687;
    thread Measures_0 _S688 = _S679;
    float4 _S689 = failure_indices_0(mat_7, b_27, &_S688, multiplier_1);
    float _S690 = _S689.x;
    float _S691 = _S689.y;
    (&st_1)->utilization_0 = max(max(_S690, _S691), max(_S689.z, _S689.w));
    float _S692 = d_lin_2.x;
    float _S693 = d_lin_2.y;
    float _S694 = ks_2 * (sq_0(_S692) + sq_0(_S693)) + kb1_0 * sq_0(d_ang_2.x) + kb2_0 * sq_0(d_ang_2.y) + kt_2 * sq_0(d_ang_2.z);
    float _S695 = d_lin_2.z;
    bool _S696 = _S695 > 0.0f;
    if(_S696)
    {
        dif_1 = kn_3 * sq_0(_S695);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S694 + dif_1);
    float psi_c_0;
    if(_S695 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_3 * sq_0(_S695);
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
    bool _S697;
    float3 qc_lin_0;
    if(fracture_1)
    {
        bool _S698 = _S690 >= _S691;
        if(_S698)
        {
            diss_contact_0 = _S690;
        }
        else
        {
            diss_contact_0 = _S691;
        }
        uint mode_ts_0;
        if(_S698)
        {
            mode_ts_0 = 1U;
        }
        else
        {
            mode_ts_0 = 2U;
        }
        if(diss_contact_0 > ((&st_1)->kappa_0))
        {
            _S697 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S697 = false;
        }
        if(_S697)
        {
            _S697 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S697 = false;
        }
        uint mode_c_0;
        if(_S697)
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
                float _S699 = (metal::fast::divide((psi_contact_0 * (float4(b_27->geom0_0) ).x * diss_contact_0 * diss_contact_0), (psi_ts_0)));
                intact_normal_0 = _S699;
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
            float _S700 = inc_0.x;
            if(_S700 > ((&st_1)->damage_0))
            {
                Contact_0 _S701 = contact_part_0(mat_7, b_27, (&st_1)->crush_1, plastic_4, d_lin_2, d_ang_2);
                float _S702 = max(_S701.energy_2 - (1.0f - (&st_1)->crush_1) * psi_c_0, 0.0f);
                float _S703 = max(inc_0.y - _S702 * (_S700 - (&st_1)->damage_0), 0.0f);
                float _S704 = max((psi_ts_0 - _S702) * (_S700 - (&st_1)->damage_0) - _S703, 0.0f);
                (&st_1)->damage_0 = _S700;
                (&st_1)->mode_0 = mode_ts_0;
                dissipated_3 = _S703;
                overshoot_1 = _S704;
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
        float _S705 = state_7->damage_0;
        if((state_7->damage_0) > 0.0f)
        {
            Contact_0 _S706 = contact_part_0(mat_7, b_27, state_7->crush_1, float3(state_7->plastic_x_0, state_7->plastic_y_0, state_7->plastic_t_0), d_lin_2, d_ang_2);
            qc_lin_0 = qe_ang_0 * float3((1.0f - _S705))  + _S706.q_ang_1 * float3(_S705) ;
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S707 = stress_measures_0(b_27, float3(0.0f, 0.0f, min(qe_lin_0.z, 0.0f)), qc_lin_0);
        thread Measures_0 _S708 = _S707;
        float4 _S709 = failure_indices_0(mat_7, b_27, &_S708, multiplier_1);
        float _S710 = _S709.z;
        float _S711 = _S709.w;
        bool _S712 = _S710 >= _S711;
        if(_S712)
        {
            psi_contact_0 = _S710;
        }
        else
        {
            psi_contact_0 = _S711;
        }
        if(_S712)
        {
            mode_c_0 = 3U;
        }
        else
        {
            mode_c_0 = 4U;
        }
        if(psi_contact_0 > ((&st_1)->kappa_c_0))
        {
            _S697 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S697 = false;
        }
        if(_S697)
        {
            _S697 = psi_c_0 > 0.0f;
        }
        else
        {
            _S697 = false;
        }
        if(_S697)
        {
            if(softening_0)
            {
                float _S713 = (metal::fast::divide((mat_7->energy_1.w * (float4(b_27->geom0_0) ).x * psi_contact_0 * psi_contact_0), (psi_c_0)));
                intact_normal_0 = _S713;
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
            float _S714 = inc_1.x;
            if(_S714 > ((&st_1)->crush_1))
            {
                float _S715 = inc_1.y;
                float dissipated_4 = dissipated_3 + _S715;
                float overshoot_2 = overshoot_1 + max(psi_c_0 * (_S714 - (&st_1)->crush_1) - _S715, 0.0f);
                (&st_1)->crush_1 = _S714;
                (&st_1)->mode_0 = mode_c_0;
                if(_S714 >= 1.0f)
                {
                    _S697 = ((&st_1)->damage_0) < 1.0f;
                }
                else
                {
                    _S697 = false;
                }
                if(_S697)
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
    float3 _S716 = float3(0.0f) ;
    float3 qc_ang_0;
    if(((&st_1)->damage_0) == 0.0f)
    {
        if((flags_1 & 8U) == 0U)
        {
            float3 _S717 = contact_offsets_0(mat_7, b_27, (&st_1)->crush_1, plastic_4, d_lin_2, d_ang_2);
            (&st_1)->plastic_x_0 = _S717.x;
            (&st_1)->plastic_y_0 = _S717.y;
            (&st_1)->plastic_t_0 = _S717.z;
        }
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S716;
        qc_ang_0 = _S716;
        psi_contact_0 = 0.0f;
    }
    else
    {
        Contact_0 _S718 = contact_part_0(mat_7, b_27, (&st_1)->crush_1, plastic_4, d_lin_2, d_ang_2);
        (&st_1)->plastic_x_0 = _S718.plastic_1.x;
        (&st_1)->plastic_y_0 = _S718.plastic_1.y;
        (&st_1)->plastic_t_0 = _S718.plastic_1.z;
        diss_contact_0 = _S718.diss_4;
        qc_lin_0 = _S718.q_lin_1;
        qc_ang_0 = _S718.q_ang_1;
        psi_contact_0 = _S718.energy_2;
    }
    float dissipated_6 = dissipated_3 + dmg_0 * diss_contact_0;
    if(_S696)
    {
        intact_normal_0 = kn_3 * _S695;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_1)->crush_1) * kn_3 * _S695;
    }
    float _S719 = 1.0f - dmg_0;
    float3 force_lin_2 = float3(_S719 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S719 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S719 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3 force_ang_2 = qe_ang_0 * float3(_S719)  + qc_ang_0 * float3(dmg_0) ;
    float stored_6 = _S719 * (psi_ts_0 + (1.0f - (&st_1)->crush_1) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S697 = ((&st_1)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S697 = false;
    }
    float stored_7;
    float3 force_lin_3;
    if(_S697)
    {
        float4 _S720 = float4(b_27->rebar0_0) ;
        float k_axial_0 = _S720.x;
        float k_dowel_0 = _S720.y;
        float yield_force_0 = _S720.z;
        float dowel_capacity_0 = _S720.w;
        float2 nr_0 = return_map_0(k_axial_0, _S695, (&st_1)->rebar_plastic_0, yield_force_0);
        float2 v1_0 = return_map_0(k_dowel_0, _S692, (&st_1)->rebar_slip0_0, dowel_capacity_0);
        float2 v2_0 = return_map_0(k_dowel_0, _S693, (&st_1)->rebar_slip1_0, dowel_capacity_0);
        float _S721 = nr_0.y;
        float _S722 = v1_0.y;
        float _S723 = v2_0.y;
        float work_0 = yield_force_0 * abs(_S721) + dowel_capacity_0 * (abs(_S722) + abs(_S723));
        (&st_1)->rebar_plastic_0 = (&st_1)->rebar_plastic_0 + _S721;
        (&st_1)->rebar_slip0_0 = (&st_1)->rebar_slip0_0 + _S722;
        (&st_1)->rebar_slip1_0 = (&st_1)->rebar_slip1_0 + _S723;
        (&st_1)->rebar_work_0 = (&st_1)->rebar_work_0 + work_0;
        float dissipated_7 = dissipated_6 + work_0;
        float _S724 = nr_0.x;
        float _S725 = (metal::fast::divide((sq_0(_S724)), (k_axial_0)));
        float _S726 = v1_0.x;
        float _S727 = v2_0.x;
        float _S728 = (metal::fast::divide((sq_0(_S726) + sq_0(_S727)), (k_dowel_0)));
        float elastic_0 = 0.5f * (_S725 + _S728);
        if(fracture_1)
        {
            _S697 = ((&st_1)->rebar_work_0) >= ((float4(b_27->rebar1_0) ).x);
        }
        else
        {
            _S697 = false;
        }
        if(_S697)
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
            force_lin_3 = force_lin_2 + float3(_S726, _S727, _S724);
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
        _S697 = _S681;
    }
    else
    {
        _S697 = false;
    }
    if(_S697)
    {
        _S697 = (flags_1 & 64U) != 0U;
    }
    else
    {
        _S697 = false;
    }
    if(_S697)
    {
        Measures_0 _S729 = stress_measures_0(b_27, force_lin_3, force_ang_2);
        thread Measures_0 _S730 = _S729;
        float4 _S731 = failure_indices_0(mat_7, b_27, &_S730, weibull_0);
        float _S732 = life_rate_0(mat_7, max(max(_S731.x, _S731.y), _S731.z));
        (&st_1)->life_0 = max((&st_1)->life_0 - _S732 * dt_12, 0.0f);
    }
    (&st_1)->dissipated_0 = (&st_1)->dissipated_0 + dissipated_3;
    thread JointResponse_0 resp_0;
    (&resp_0)->force_lin_1 = force_lin_3;
    (&resp_0)->force_ang_1 = force_ang_2;
    (&resp_0)->state_6 = st_1;
    (&resp_0)->dissipated_2 = dissipated_3;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_5 = stored_7;
    if(_S678)
    {
        thread JointState_0 _S733 = st_1;
        bool _S734 = connected_0(&_S733, has_rebar_1);
        _S697 = !_S734;
    }
    else
    {
        _S697 = false;
    }
    (&resp_0)->disconnected_0 = _S697;
    (&resp_0)->measures_0 = _S679;
    return resp_0;
}

void secant_factors_0(const JointBond_natural_0 thread* b_28, const JointState_0 thread* st_2, float3 d_lin_3, float3 thread* f_lin_0, float3 thread* f_ang_0)
{
    float _S735 = st_2->damage_0;
    bool compressed_0 = (d_lin_3.z) < 0.0f;
    float contact_3;
    if(compressed_0)
    {
        contact_3 = _S735;
    }
    else
    {
        contact_3 = 0.0f;
    }
    float _S736 = 1.0f - _S735;
    float _S737 = max(_S736 + contact_3, 9.99999997475242708e-07f);
    float normal_5;
    if(compressed_0)
    {
        normal_5 = max(1.0f - st_2->crush_1, 9.99999997475242708e-07f);
    }
    else
    {
        normal_5 = max(_S736, 9.99999997475242708e-07f);
    }
    *f_lin_0 = float3(_S737, _S737, normal_5);
    *f_ang_0 = float3(_S737) ;
    bool _S738;
    if(((float4(b_28->stiff1_0) ).w) != 0.0f)
    {
        _S738 = (st_2->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S738 = false;
    }
    if(_S738)
    {
        float4 _S739 = float4(b_28->rebar0_0) ;
        float4 _S740 = float4(b_28->stiff0_0) ;
        float _S741 = (metal::fast::divide((_S739.x), (_S740.x)));
        (*f_lin_0).z = (*f_lin_0).z + _S741;
        float _S742 = _S739.y;
        float _S743 = _S740.y;
        float _S744 = (metal::fast::divide((_S742), (_S743)));
        (*f_lin_0).x = (*f_lin_0).x + _S744;
        float _S745 = (metal::fast::divide((_S742), (_S743)));
        (*f_lin_0).y = (*f_lin_0).y + _S745;
    }
    return;
}

bool is_damaged_0(const JointState_0 thread* st_3)
{
    bool _S746;
    if((st_3->damage_0) > 0.0f)
    {
        _S746 = true;
    }
    else
    {
        _S746 = (st_3->crush_1) > 0.0f;
    }
    return _S746;
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

float3 to_local_0(uint _S747, float3 _S748, KernelContext_0 thread* kernelContext_41)
{
    BondStatic_natural_0 device* _S749 = kernelContext_41->bonds_0+_S747;
    return float3(dot(_S748, (float4(_S749->t1_0) ).xyz), dot(_S748, (float4(_S749->t2_0) ).xyz), dot(_S748, (float4(_S749->normal_0) ).xyz));
}

float3 to_body_0(uint _S750, float3 _S751, KernelContext_0 thread* kernelContext_42)
{
    BondStatic_natural_0 device* _S752 = kernelContext_42->bonds_0+_S750;
    return (float4(_S752->t1_0) ).xyz * float3(_S751.x)  + (float4(_S752->t2_0) ).xyz * float3(_S751.y)  + (float4(_S752->normal_0) ).xyz * float3(_S751.z) ;
}

bool bond_update_0(uint i_10, float dt_13, bool fracture_2, uint abs_step_0, KernelContext_0 thread* kernelContext_43)
{
    BondStatic_natural_0 device* _S753 = kernelContext_43->bonds_0+i_10;
    BondDyn_natural_0 device* _S754 = kernelContext_43->bond_dyn_0+i_10;
    float4 _S755 = float4((*_S754).force_lin_0) ;
    float4 _S756 = float4((*_S754).force_ang_0) ;
    float4 _S757 = float4((*_S754).sums_0) ;
    float4 _S758 = float4((*_S754).comps_0) ;
    uint4 _S759 = uint4((*_S754).events_0) ;
    thread BondDyn_0 bd_0;
    (&bd_0)->js_0 = (*_S754).js_0;
    (&bd_0)->force_lin_0 = _S755;
    (&bd_0)->force_ang_0 = _S756;
    (&bd_0)->sums_0 = _S757;
    (&bd_0)->comps_0 = _S758;
    (&bd_0)->events_0 = _S759;
    JointBond_natural_0 _S760 = _S753->law_0;
    thread JointBond_natural_0 _S761 = _S753->law_0;
    uint4 _S762 = uint4((&_S761)->ids_0) ;
    float3 ra_1 = (float4(_S753->ra_0) ).xyz;
    float3 rb_1 = (float4(_S753->rb_0) ).xyz;
    uint _S763 = 4U * _S762.y;
    float3 ta_2 = (float4(*(kernelContext_43->state_0+(_S763 + 1U))) ).xyz;
    float3 va_0 = (float4(*(kernelContext_43->state_0+(_S763 + 2U))) ).xyz;
    float3 wa_1 = (float4(*(kernelContext_43->state_0+(_S763 + 3U))) ).xyz;
    uint _S764 = 4U * _S762.z;
    float3 tb_2 = (float4(*(kernelContext_43->state_0+(_S764 + 1U))) ).xyz;
    float3 vb_0 = (float4(*(kernelContext_43->state_0+(_S764 + 2U))) ).xyz;
    float3 wb_1 = (float4(*(kernelContext_43->state_0+(_S764 + 3U))) ).xyz;
    float3 _S765 = to_local_0(i_10, (float4(*(kernelContext_43->state_0+_S764)) ).xyz + cross(tb_2, rb_1) - ((float4(*(kernelContext_43->state_0+_S763)) ).xyz + cross(ta_2, ra_1)), kernelContext_43);
    float3 _S766 = to_local_0(i_10, tb_2 - ta_2, kernelContext_43);
    float3 _S767 = to_local_0(i_10, vb_0 + cross(wb_1, rb_1) - (va_0 + cross(wa_1, ra_1)), kernelContext_43);
    float3 _S768 = to_local_0(i_10, wb_1 - wa_1, kernelContext_43);
    JointState_0 previous_0 = (&bd_0)->js_0;
    _S761 = _S760;
    thread JointState_0 _S769 = (&bd_0)->js_0;
    JointResponse_0 _S770 = joint_evaluate_0(&kernelContext_43->materials_0->m_0[_S762.x], &_S761, &_S769, _S765, _S766, dt_13, fracture_2);
    thread JointState_0 _S771 = _S770.state_6;
    thread float3 f_lin_1;
    thread float3 f_ang_1;
    secant_factors_0(&_S761, &_S771, _S765, &f_lin_1, &f_ang_1);
    float3 qd_lin_0 = _S767 * (float4(_S753->c_lin_0) ).xyz * f_lin_1;
    float3 qd_ang_0 = _S768 * (float4(_S753->c_ang_0) ).xyz * f_ang_1;
    float3 q_lin_2 = _S770.force_lin_1 + qd_lin_0;
    float3 q_ang_2 = _S770.force_ang_1 + qd_ang_0;
    float damped_0 = (dot(qd_lin_0, _S767) + dot(qd_ang_0, _S768)) * dt_13;
    float3 _S772 = to_body_0(i_10, q_lin_2, kernelContext_43);
    float3 _S773 = to_body_0(i_10, q_ang_2, kernelContext_43);
    uint _S774 = 3U * i_10;
    *(kernelContext_43->scratch_0+_S774) = packed_float4(float4(_S772, max(_S770.measures_0.tension_0, _S770.measures_0.compression_0))) ;
    *(kernelContext_43->scratch_0+(_S774 + 1U)) = packed_float4(float4(_S773 + cross(ra_1, _S772), 0.0f)) ;
    *(kernelContext_43->scratch_0+(_S774 + 2U)) = packed_float4(float4(- _S773 + cross(rb_1, - _S772), 0.0f)) ;
    thread float _S775 = (&bd_0)->sums_0.x;
    thread float _S776 = (&bd_0)->comps_0.x;
    comp_add1_0(&_S775, &_S776, _S770.dissipated_2);
    (&bd_0)->comps_0.x = _S776;
    (&bd_0)->sums_0.x = _S775;
    thread float _S777 = (&bd_0)->sums_0.y;
    thread float _S778 = (&bd_0)->comps_0.y;
    comp_add1_0(&_S777, &_S778, _S770.overshoot_0);
    (&bd_0)->comps_0.y = _S778;
    (&bd_0)->sums_0.y = _S777;
    thread float _S779 = (&bd_0)->sums_0.z;
    thread float _S780 = (&bd_0)->comps_0.z;
    comp_add1_0(&_S779, &_S780, damped_0);
    (&bd_0)->comps_0.z = _S780;
    (&bd_0)->sums_0.z = _S779;
    (&bd_0)->force_lin_0 = float4(q_lin_2, _S770.stored_5);
    (&bd_0)->force_ang_0 = float4(q_ang_2, max((&bd_0)->force_ang_0.w, _S770.state_6.utilization_0));
    thread JointState_0 _S781 = previous_0;
    bool _S782 = is_damaged_0(&_S781);
    bool _S783;
    if(!_S782)
    {
        thread JointState_0 _S784 = _S770.state_6;
        bool _S785 = is_damaged_0(&_S784);
        _S783 = _S785;
    }
    else
    {
        _S783 = false;
    }
    if(_S783)
    {
        _S783 = ((&bd_0)->events_0.x) == 0U;
    }
    else
    {
        _S783 = false;
    }
    if(_S783)
    {
        (&bd_0)->events_0.x = abs_step_0;
        (&bd_0)->events_0.w = _S770.state_6.mode_0;
    }
    if(((&bd_0)->events_0.y) == 0U)
    {
        float _S786 = fatigue_factor_0(&kernelContext_43->materials_0->m_0[_S762.x], previous_0.life_0);
        _S783 = _S786 > 0.99000000953674316f;
    }
    else
    {
        _S783 = false;
    }
    if(_S783)
    {
        float _S787 = fatigue_factor_0(&kernelContext_43->materials_0->m_0[_S762.x], _S770.state_6.life_0);
        _S783 = _S787 <= 0.99000000953674316f;
    }
    else
    {
        _S783 = false;
    }
    if(_S783)
    {
        (&bd_0)->events_0.y = abs_step_0;
    }
    if(_S770.disconnected_0)
    {
        (&bd_0)->events_0.z = abs_step_0;
    }
    (&bd_0)->js_0 = _S770.state_6;
    BondDyn_natural_0 device* _S788 = kernelContext_43->bond_dyn_0+i_10;
    _S788->js_0 = bd_0.js_0;
    _S788->force_lin_0 = packed_float4(bd_0.force_lin_0) ;
    _S788->force_ang_0 = packed_float4(bd_0.force_ang_0) ;
    _S788->sums_0 = packed_float4(bd_0.sums_0) ;
    _S788->comps_0 = packed_float4(bd_0.comps_0) ;
    _S788->events_0 = packed_uint4(bd_0.events_0) ;
    return _S770.disconnected_0;
}

void chunk_update_0(uint c_15, const Island_natural_0 thread* isl_11, const Rigid_0 thread* rg_9, float dt_14, bool rml_0, uint step_0, bool contact_4, float thread* work_1, float thread* work_err_0, KernelContext_0 thread* kernelContext_44)
{
    ChunkStatic_natural_0 device* _S789 = kernelContext_44->chunks_0+c_15;
    float3 _S790 = float3(0.0f) ;
    uint _S791 = kernelContext_44->index_0[c_15];
    float peak_0 = 0.0f;
    uint e_3 = _S791;
    float3 fi_0 = _S790;
    float3 mi_0 = _S790;
    for(;;)
    {
        if(e_3 < (kernelContext_44->index_0)[c_15 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_2 = kernelContext_44->index_0[e_3];
        uint _S792 = 3U * (entry_2 >> 1U);
        float4 _S793 = float4(*(kernelContext_44->scratch_0+_S792)) ;
        if((entry_2 & 1U) == 0U)
        {
            float3 mi_1 = mi_0 + (float4(*(kernelContext_44->scratch_0+(_S792 + 1U))) ).xyz;
            fi_0 = fi_0 + _S793.xyz;
            mi_0 = mi_1;
        }
        else
        {
            float3 mi_2 = mi_0 + (float4(*(kernelContext_44->scratch_0+(_S792 + 2U))) ).xyz;
            fi_0 = fi_0 + - _S793.xyz;
            mi_0 = mi_2;
        }
        float _S794 = max(peak_0, _S793.w);
        uint _S795 = e_3 + 1U;
        peak_0 = _S794;
        e_3 = _S795;
    }
    uint _S796 = 4U * c_15;
    float3 u_0 = (float4(*(kernelContext_44->state_0+_S796)) ).xyz;
    uint _S797 = _S796 + 1U;
    float3 th_1 = (float4(*(kernelContext_44->state_0+_S797)) ).xyz;
    uint _S798 = _S796 + 2U;
    float3 v_11 = (float4(*(kernelContext_44->state_0+_S798)) ).xyz;
    uint _S799 = _S796 + 3U;
    float3 w_5 = (float4(*(kernelContext_44->state_0+_S799)) ).xyz;
    float4 _S800 = float4(_S789->center_0) ;
    float mass_0 = _S800.w;
    float3 _S801 = _S800.xyz;
    float3 _S802 = (float4(isl_11->com_0) ).xyz;
    float3 _S803 = rotate_0(&rg_9->rot_0, _S801 + u_0 - _S802);
    thread float3 f_load_0;
    thread float3 t_load_0;
    chunk_external_0(c_15, c_15, &rg_9->rot_0, step_0, dt_14, contact_4, &f_load_0, &t_load_0, kernelContext_44);
    record_chunk_load_0(c_15, f_load_0, t_load_0, kernelContext_44);
    float3 _S804 = float3(mass_0) ;
    float3 f_world_0 = f_load_0 + kernelContext_44->params_0->gravity_0.xyz * _S804;
    float3 t_world_0 = t_load_0;
    float3 f_world_1;
    float3 t_world_1;
    if(rml_0)
    {
        float3 f_world_2 = f_world_0 - (rg_9->a_7 + cross(rg_9->alpha_0, _S803) + cross(rg_9->w_4, cross(rg_9->w_4, _S803))) * _S804;
        float4 _S805 = float4(_S789->inertia0_1) ;
        float4 _S806 = float4(_S789->inertia1_1) ;
        float4 _S807 = float4(_S789->inertia2_1) ;
        float3 _S808 = world_mul_0(&rg_9->rot_0, _S805, _S806, _S807, rg_9->alpha_0);
        float3 _S809 = world_mul_0(&rg_9->rot_0, _S805, _S806, _S807, rg_9->w_4);
        float3 t_world_2 = t_world_0 - (_S808 + cross(rg_9->w_4, _S809));
        f_world_1 = f_world_2;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    float3 _S810 = inverse_rotate_0(&rg_9->rot_0, f_world_1);
    float3 _S811 = inverse_rotate_0(&rg_9->rot_0, t_world_1);
    float3 f_ext_0;
    float3 m_ext_0;
    if(rml_0)
    {
        float3 _S812 = inverse_rotate_0(&rg_9->rot_0, rg_9->w_4);
        float4 _S813 = float4(_S789->inertia0_1) ;
        float4 _S814 = float4(_S789->inertia1_1) ;
        float4 _S815 = float4(_S789->inertia2_1) ;
        float3 i_w_0 = rows_mul_0(_S813, _S814, _S815, w_5);
        float3 m_ext_1 = _S811 - (cross(_S812, i_w_0) + cross(w_5, rows_mul_0(_S813, _S814, _S815, _S812)) + cross(w_5, i_w_0));
        f_ext_0 = _S810 - cross(_S812, v_11) * float3((2.0f * mass_0)) ;
        m_ext_0 = m_ext_1;
    }
    else
    {
        f_ext_0 = _S810;
        m_ext_0 = _S811;
    }
    uint4 _S816 = uint4(_S789->load_range_0) ;
    uint term_4 = _S816.x;
    for(;;)
    {
        if(term_4 < (_S816.y))
        {
        }
        else
        {
            break;
        }
        uint _S817 = 5U * term_4;
        if(((as_type<uint4>((float4(*(kernelContext_44->loads_0+_S817)) ))).y) != 2U)
        {
            term_4 = term_4 + 1U;
            continue;
        }
        float _S818 = eval_function_0(term_4, step_0, dt_14, dt_14, kernelContext_44);
        float3 _S819 = float3(_S818) ;
        float3 m_ext_2 = m_ext_0 + (float4(*(kernelContext_44->loads_0+(_S817 + 2U))) ).xyz * _S819;
        f_ext_0 = f_ext_0 + (float4(*(kernelContext_44->loads_0+(_S817 + 1U))) ).xyz * _S819;
        m_ext_0 = m_ext_2;
        term_4 = term_4 + 1U;
    }
    float3 f_13 = f_ext_0 + fi_0;
    float3 m_5 = m_ext_0 + mi_0;
    uint support_0 = (uint4(_S789->info_1) ).x;
    float3 _S820 = float3((float4(*(kernelContext_44->state_0+_S797)) ).w, (float4(*(kernelContext_44->state_0+_S798)) ).w, (float4(*(kernelContext_44->state_0+_S799)) ).w);
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
        v_12 = _S790;
        w_6 = _S790;
    }
    else
    {
        float4 _S821 = float4(_S789->scale_0) ;
        float3 w_7 = w_5 + rows_mul_0(float4(_S789->inv0_1) , float4(_S789->inv1_1) , float4(_S789->inv2_1) , m_5) * float3((dt_14 * _S821.z)) ;
        float3 _S822 = float3(dt_14) ;
        float3 th_3 = th_1 + w_7 * _S822;
        if(support_0 == 2U)
        {
            reaction_0 = - f_13;
            u_1 = u_0;
            th_2 = _S790;
        }
        else
        {
            float3 v_13 = v_11 + f_13 * float3((dt_14 * _S821.y)) ;
            float3 u_2 = u_0 + v_13 * _S822;
            reaction_0 = _S820;
            u_1 = u_2;
            th_2 = v_13;
        }
        float3 _S823 = th_2;
        th_2 = th_3;
        v_12 = _S823;
        w_6 = w_7;
    }
    *(kernelContext_44->state_0+_S796) = packed_float4(float4(u_1, peak_0)) ;
    *(kernelContext_44->state_0+_S797) = packed_float4(float4(th_2, reaction_0.x)) ;
    *(kernelContext_44->state_0+_S798) = packed_float4(float4(v_12, reaction_0.y)) ;
    *(kernelContext_44->state_0+_S799) = packed_float4(float4(w_6, reaction_0.z)) ;
    float3 _S824 = rotate_0(&rg_9->rot_0, _S801 + u_1 - _S802);
    float3 _S825 = rg_9->vel_1 + rg_9->vel_err_1 + cross(rg_9->w_4, _S824);
    float3 _S826 = rotate_0(&rg_9->rot_0, v_12);
    float3 v_world_0 = _S825 + _S826;
    float3 _S827 = rotate_0(&rg_9->rot_0, w_6);
    comp_add1_0(work_1, work_err_0, (dot(f_load_0, v_world_0) + dot(t_load_0, rg_9->w_4 + _S827)) * dt_14);
    return;
}

void chunk_update_1(uint c_16, const Island_0 thread* isl_12, const Rigid_0 thread* rg_10, float dt_15, bool rml_1, uint step_1, bool contact_5, float thread* work_2, float thread* work_err_1, KernelContext_0 thread* kernelContext_45)
{
    ChunkStatic_natural_0 device* _S828 = kernelContext_45->chunks_0+c_16;
    float3 _S829 = float3(0.0f) ;
    uint _S830 = kernelContext_45->index_0[c_16];
    float peak_1 = 0.0f;
    uint e_4 = _S830;
    float3 fi_1 = _S829;
    float3 mi_3 = _S829;
    for(;;)
    {
        if(e_4 < (kernelContext_45->index_0)[c_16 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_3 = kernelContext_45->index_0[e_4];
        uint _S831 = 3U * (entry_3 >> 1U);
        float4 _S832 = float4(*(kernelContext_45->scratch_0+_S831)) ;
        if((entry_3 & 1U) == 0U)
        {
            float3 mi_4 = mi_3 + (float4(*(kernelContext_45->scratch_0+(_S831 + 1U))) ).xyz;
            fi_1 = fi_1 + _S832.xyz;
            mi_3 = mi_4;
        }
        else
        {
            float3 mi_5 = mi_3 + (float4(*(kernelContext_45->scratch_0+(_S831 + 2U))) ).xyz;
            fi_1 = fi_1 + - _S832.xyz;
            mi_3 = mi_5;
        }
        float _S833 = max(peak_1, _S832.w);
        uint _S834 = e_4 + 1U;
        peak_1 = _S833;
        e_4 = _S834;
    }
    uint _S835 = 4U * c_16;
    float3 u_3 = (float4(*(kernelContext_45->state_0+_S835)) ).xyz;
    uint _S836 = _S835 + 1U;
    float3 th_4 = (float4(*(kernelContext_45->state_0+_S836)) ).xyz;
    uint _S837 = _S835 + 2U;
    float3 v_14 = (float4(*(kernelContext_45->state_0+_S837)) ).xyz;
    uint _S838 = _S835 + 3U;
    float3 w_8 = (float4(*(kernelContext_45->state_0+_S838)) ).xyz;
    float4 _S839 = float4(_S828->center_0) ;
    float mass_1 = _S839.w;
    float3 _S840 = _S839.xyz;
    float3 _S841 = isl_12->com_0.xyz;
    float3 _S842 = rotate_0(&rg_10->rot_0, _S840 + u_3 - _S841);
    thread float3 f_load_1;
    thread float3 t_load_1;
    chunk_external_0(c_16, c_16, &rg_10->rot_0, step_1, dt_15, contact_5, &f_load_1, &t_load_1, kernelContext_45);
    record_chunk_load_0(c_16, f_load_1, t_load_1, kernelContext_45);
    float3 _S843 = float3(mass_1) ;
    float3 f_world_3 = f_load_1 + kernelContext_45->params_0->gravity_0.xyz * _S843;
    float3 t_world_3 = t_load_1;
    float3 f_world_4;
    float3 t_world_4;
    if(rml_1)
    {
        float3 f_world_5 = f_world_3 - (rg_10->a_7 + cross(rg_10->alpha_0, _S842) + cross(rg_10->w_4, cross(rg_10->w_4, _S842))) * _S843;
        float4 _S844 = float4(_S828->inertia0_1) ;
        float4 _S845 = float4(_S828->inertia1_1) ;
        float4 _S846 = float4(_S828->inertia2_1) ;
        float3 _S847 = world_mul_0(&rg_10->rot_0, _S844, _S845, _S846, rg_10->alpha_0);
        float3 _S848 = world_mul_0(&rg_10->rot_0, _S844, _S845, _S846, rg_10->w_4);
        float3 t_world_5 = t_world_3 - (_S847 + cross(rg_10->w_4, _S848));
        f_world_4 = f_world_5;
        t_world_4 = t_world_5;
    }
    else
    {
        f_world_4 = f_world_3;
        t_world_4 = t_world_3;
    }
    float3 _S849 = inverse_rotate_0(&rg_10->rot_0, f_world_4);
    float3 _S850 = inverse_rotate_0(&rg_10->rot_0, t_world_4);
    float3 f_ext_1;
    float3 m_ext_3;
    if(rml_1)
    {
        float3 _S851 = inverse_rotate_0(&rg_10->rot_0, rg_10->w_4);
        float4 _S852 = float4(_S828->inertia0_1) ;
        float4 _S853 = float4(_S828->inertia1_1) ;
        float4 _S854 = float4(_S828->inertia2_1) ;
        float3 i_w_1 = rows_mul_0(_S852, _S853, _S854, w_8);
        float3 m_ext_4 = _S850 - (cross(_S851, i_w_1) + cross(w_8, rows_mul_0(_S852, _S853, _S854, _S851)) + cross(w_8, i_w_1));
        f_ext_1 = _S849 - cross(_S851, v_14) * float3((2.0f * mass_1)) ;
        m_ext_3 = m_ext_4;
    }
    else
    {
        f_ext_1 = _S849;
        m_ext_3 = _S850;
    }
    uint4 _S855 = uint4(_S828->load_range_0) ;
    uint term_5 = _S855.x;
    for(;;)
    {
        if(term_5 < (_S855.y))
        {
        }
        else
        {
            break;
        }
        uint _S856 = 5U * term_5;
        if(((as_type<uint4>((float4(*(kernelContext_45->loads_0+_S856)) ))).y) != 2U)
        {
            term_5 = term_5 + 1U;
            continue;
        }
        float _S857 = eval_function_0(term_5, step_1, dt_15, dt_15, kernelContext_45);
        float3 _S858 = float3(_S857) ;
        float3 m_ext_5 = m_ext_3 + (float4(*(kernelContext_45->loads_0+(_S856 + 2U))) ).xyz * _S858;
        f_ext_1 = f_ext_1 + (float4(*(kernelContext_45->loads_0+(_S856 + 1U))) ).xyz * _S858;
        m_ext_3 = m_ext_5;
        term_5 = term_5 + 1U;
    }
    float3 f_14 = f_ext_1 + fi_1;
    float3 m_6 = m_ext_3 + mi_3;
    uint support_1 = (uint4(_S828->info_1) ).x;
    float3 _S859 = float3((float4(*(kernelContext_45->state_0+_S836)) ).w, (float4(*(kernelContext_45->state_0+_S837)) ).w, (float4(*(kernelContext_45->state_0+_S838)) ).w);
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
        v_15 = _S829;
        w_9 = _S829;
    }
    else
    {
        float4 _S860 = float4(_S828->scale_0) ;
        float3 w_10 = w_8 + rows_mul_0(float4(_S828->inv0_1) , float4(_S828->inv1_1) , float4(_S828->inv2_1) , m_6) * float3((dt_15 * _S860.z)) ;
        float3 _S861 = float3(dt_15) ;
        float3 th_6 = th_4 + w_10 * _S861;
        if(support_1 == 2U)
        {
            reaction_1 = - f_14;
            u_4 = u_3;
            th_5 = _S829;
        }
        else
        {
            float3 v_16 = v_14 + f_14 * float3((dt_15 * _S860.y)) ;
            float3 u_5 = u_3 + v_16 * _S861;
            reaction_1 = _S859;
            u_4 = u_5;
            th_5 = v_16;
        }
        float3 _S862 = th_5;
        th_5 = th_6;
        v_15 = _S862;
        w_9 = w_10;
    }
    *(kernelContext_45->state_0+_S835) = packed_float4(float4(u_4, peak_1)) ;
    *(kernelContext_45->state_0+_S836) = packed_float4(float4(th_5, reaction_1.x)) ;
    *(kernelContext_45->state_0+_S837) = packed_float4(float4(v_15, reaction_1.y)) ;
    *(kernelContext_45->state_0+_S838) = packed_float4(float4(w_9, reaction_1.z)) ;
    float3 _S863 = rotate_0(&rg_10->rot_0, _S840 + u_4 - _S841);
    float3 _S864 = rg_10->vel_1 + rg_10->vel_err_1 + cross(rg_10->w_4, _S863);
    float3 _S865 = rotate_0(&rg_10->rot_0, v_15);
    float3 v_world_1 = _S864 + _S865;
    float3 _S866 = rotate_0(&rg_10->rot_0, w_9);
    comp_add1_0(work_2, work_err_1, (dot(f_load_1, v_world_1) + dot(t_load_1, rg_10->w_4 + _S866)) * dt_15);
    return;
}

void drift_moments_0(uint c_17, float3 thread* tu_0, float3 thread* pv_0, KernelContext_0 thread* kernelContext_46)
{
    ChunkStatic_natural_0 device* _S867 = kernelContext_46->chunks_0+c_17;
    uint _S868 = 4U * c_17;
    float3 _S869 = float3(((float4(_S867->center_0) ).w * (float4(_S867->scale_0) ).x)) ;
    *tu_0 = *tu_0 + (float4(*(kernelContext_46->state_0+_S868)) ).xyz * _S869;
    *pv_0 = *pv_0 + (float4(*(kernelContext_46->state_0+(_S868 + 2U))) ).xyz * _S869;
    return;
}

void drift_angular_0(uint c_18, float3 wcom_1, float3 tr_0, float3 dv_0, float3 thread* lu_0, float3 thread* lv_0, KernelContext_0 thread* kernelContext_47)
{
    ChunkStatic_natural_0 device* _S870 = kernelContext_47->chunks_0+c_18;
    float4 _S871 = float4(_S870->center_0) ;
    float3 r_10 = _S871.xyz - wcom_1;
    uint _S872 = 4U * c_18;
    float3 _S873 = float3(_S871.w) ;
    float4 _S874 = float4(_S870->inertia0_1) ;
    float4 _S875 = float4(_S870->inertia1_1) ;
    float4 _S876 = float4(_S870->inertia2_1) ;
    float3 _S877 = float3((float4(_S870->scale_0) ).x) ;
    *lu_0 = *lu_0 + (cross(r_10, (float4(*(kernelContext_47->state_0+_S872)) ).xyz - tr_0) * _S873 + rows_mul_0(_S874, _S875, _S876, (float4(*(kernelContext_47->state_0+(_S872 + 1U))) ).xyz)) * _S877;
    *lv_0 = *lv_0 + (cross(r_10, (float4(*(kernelContext_47->state_0+(_S872 + 2U))) ).xyz - dv_0) * _S873 + rows_mul_0(_S874, _S875, _S876, (float4(*(kernelContext_47->state_0+(_S872 + 3U))) ).xyz)) * _S877;
    return;
}

void drift_apply_0(uint c_19, float3 wcom_2, float3 tr_1, float3 phi_0, float3 dv_1, float3 dw_0, KernelContext_0 thread* kernelContext_48)
{
    float3 r_11 = (float4((kernelContext_48->chunks_0+c_19)->center_0) ).xyz - wcom_2;
    uint _S878 = 4U * c_19;
    *(kernelContext_48->state_0+_S878) = packed_float4(float4((float4(*(kernelContext_48->state_0+_S878)) ).xyz - (tr_1 + cross(phi_0, r_11)), (float4(*(kernelContext_48->state_0+_S878)) ).w)) ;
    uint _S879 = _S878 + 1U;
    *(kernelContext_48->state_0+_S879) = packed_float4(float4((float4(*(kernelContext_48->state_0+_S879)) ).xyz - phi_0, (float4(*(kernelContext_48->state_0+_S879)) ).w)) ;
    uint _S880 = _S878 + 2U;
    *(kernelContext_48->state_0+_S880) = packed_float4(float4((float4(*(kernelContext_48->state_0+_S880)) ).xyz - (dv_1 + cross(dw_0, r_11)), (float4(*(kernelContext_48->state_0+_S880)) ).w)) ;
    uint _S881 = _S878 + 3U;
    *(kernelContext_48->state_0+_S881) = packed_float4(float4((float4(*(kernelContext_48->state_0+_S881)) ).xyz - dw_0, (float4(*(kernelContext_48->state_0+_S881)) ).w)) ;
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
    thread Quat_0 _S882 = *hi_3;
    thread Quat_0 _S883 = dq_1;
    Quat_0 _S884 = quat_mul_0(&_S882, &_S883);
    thread Quat_0 _S885 = _S884;
    float4 _S886 = quat_vec_0(&_S885);
    quat_accumulate_0(hi_3, lo_3, _S886);
    return;
}

void drift_rigid_0(const Island_natural_0 thread* isl_13, Rigid_0 thread* rg_11, float3 tr_2, float3 phi_2, float3 dv_2, float3 dw_1)
{
    float3 wcom_3 = (float4(isl_13->wcom_0) ).xyz;
    Quat_0 rot_2 = rg_11->rot_0;
    float3 _S887 = tr_2 - cross(phi_2, wcom_3);
    thread Quat_0 _S888 = rg_11->rot_0;
    float3 _S889 = rotate_0(&_S888, _S887);
    comp_add_0(&rg_11->pos_1, &rg_11->pos_err_1, _S889);
    thread Quat_0 _S890 = rg_11->rot_0;
    float3 _S891 = inverse_rotate_0(&_S890, rg_11->w_4);
    float4 _S892 = float4(isl_13->inertia0_0) ;
    float4 _S893 = float4(isl_13->inertia1_0) ;
    float4 _S894 = float4(isl_13->inertia2_0) ;
    float3 _S895 = cross(phi_2, rows_mul_0(_S892, _S893, _S894, _S891)) - rows_mul_0(_S892, _S893, _S894, cross(phi_2, _S891));
    thread Quat_0 _S896 = rg_11->rot_0;
    float3 _S897 = rotate_0(&_S896, _S895);
    turn_right_0(&rg_11->rot_0, &rg_11->rot_err_0, phi_2);
    float3 _S898 = dv_2 + cross(dw_1, (float4(isl_13->com_0) ).xyz - wcom_3);
    thread Quat_0 _S899 = rot_2;
    float3 _S900 = rotate_0(&_S899, _S898);
    comp_add_0(&rg_11->vel_1, &rg_11->vel_err_1, _S900);
    thread Quat_0 _S901 = rot_2;
    float3 _S902 = rotate_0(&_S901, dw_1);
    rg_11->w_4 = rg_11->w_4 + _S902;
    thread Quat_0 _S903 = rg_11->rot_0;
    float3 _S904 = world_mul_0(&_S903, _S892, _S893, _S894, _S902);
    comp_add_0(&rg_11->l_2, &rg_11->l_err_1, _S897 + _S904);
    return;
}

void drift_rigid_1(const Island_0 thread* isl_14, Rigid_0 thread* rg_12, float3 tr_3, float3 phi_3, float3 dv_3, float3 dw_2)
{
    float3 wcom_4 = isl_14->wcom_0.xyz;
    Quat_0 rot_3 = rg_12->rot_0;
    float3 _S905 = tr_3 - cross(phi_3, wcom_4);
    thread Quat_0 _S906 = rg_12->rot_0;
    float3 _S907 = rotate_0(&_S906, _S905);
    comp_add_0(&rg_12->pos_1, &rg_12->pos_err_1, _S907);
    thread Quat_0 _S908 = rg_12->rot_0;
    float3 _S909 = inverse_rotate_0(&_S908, rg_12->w_4);
    float4 _S910 = isl_14->inertia0_0;
    float4 _S911 = isl_14->inertia1_0;
    float4 _S912 = isl_14->inertia2_0;
    float3 _S913 = cross(phi_3, rows_mul_0(isl_14->inertia0_0, isl_14->inertia1_0, isl_14->inertia2_0, _S909)) - rows_mul_0(isl_14->inertia0_0, isl_14->inertia1_0, isl_14->inertia2_0, cross(phi_3, _S909));
    thread Quat_0 _S914 = rg_12->rot_0;
    float3 _S915 = rotate_0(&_S914, _S913);
    turn_right_0(&rg_12->rot_0, &rg_12->rot_err_0, phi_3);
    float3 _S916 = dv_3 + cross(dw_2, isl_14->com_0.xyz - wcom_4);
    thread Quat_0 _S917 = rot_3;
    float3 _S918 = rotate_0(&_S917, _S916);
    comp_add_0(&rg_12->vel_1, &rg_12->vel_err_1, _S918);
    thread Quat_0 _S919 = rot_3;
    float3 _S920 = rotate_0(&_S919, dw_2);
    rg_12->w_4 = rg_12->w_4 + _S920;
    thread Quat_0 _S921 = rg_12->rot_0;
    float3 _S922 = world_mul_0(&_S921, _S910, _S911, _S912, _S920);
    comp_add_0(&rg_12->l_2, &rg_12->l_err_1, _S915 + _S922);
    return;
}

void contact_split_at_0(uint at_6, KernelContext_0 thread* kernelContext_49)
{
    uint previous_1 = (uint4((kernelContext_49->islands_0+kernelContext_49->params_0->halt_index_0)->info_0) ).y;
    uint _S923;
    if(previous_1 == 0U)
    {
        _S923 = at_6;
    }
    else
    {
        _S923 = min(previous_1, at_6);
    }
    (kernelContext_49->islands_0+kernelContext_49->params_0->halt_index_0)->info_0[int(1)] = _S923;
    return;
}

[[kernel]] void island_frame(uint3 group_2 [[threadgroup_position_in_grid]], uint3 thread_2 [[thread_position_in_threadgroup]], Params_0 constant* params_6 [[buffer(0)]], Island_natural_0 device* islands_6 [[buffer(9)]], uint device* index_6 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_6 [[buffer(3)]], packed_float4 device* state_8 [[buffer(6)]], packed_float4 device* scratch_6 [[buffer(8)]], packed_float4 device* contact_state_6 [[buffer(11)]], packed_float4 device* loads_6 [[buffer(5)]], Impactor_natural_0 device* impactors_6 [[buffer(10)]], BondStatic_natural_0 device* bonds_6 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_6 [[buffer(7)]], MaterialTable_0 constant* materials_6 [[buffer(1)]])
{
    bool woke_0;
    thread KernelContext_0 kernelContext_50;
    (&kernelContext_50)->params_0 = params_6;
    (&kernelContext_50)->islands_0 = islands_6;
    (&kernelContext_50)->index_0 = index_6;
    (&kernelContext_50)->chunks_0 = chunks_6;
    (&kernelContext_50)->state_0 = state_8;
    (&kernelContext_50)->scratch_0 = scratch_6;
    (&kernelContext_50)->contact_state_0 = contact_state_6;
    (&kernelContext_50)->loads_0 = loads_6;
    (&kernelContext_50)->impactors_0 = impactors_6;
    (&kernelContext_50)->bonds_0 = bonds_6;
    (&kernelContext_50)->bond_dyn_0 = bond_dyn_6;
    (&kernelContext_50)->materials_0 = materials_6;
    threadgroup array<float4, int(32)> g_part_a_6;
    (&kernelContext_50)->g_part_a_0 = &g_part_a_6;
    threadgroup array<float4, int(32)> g_part_b_6;
    (&kernelContext_50)->g_part_b_0 = &g_part_b_6;
    threadgroup uint g_run_6;
    (&kernelContext_50)->g_run_0 = &g_run_6;
    threadgroup uint g_halt_6;
    (&kernelContext_50)->g_halt_0 = &g_halt_6;
    threadgroup uint g_wide_run_6;
    (&kernelContext_50)->g_wide_run_0 = &g_wide_run_6;
    uint tid_4 = thread_2.x;
    uint _S924 = group_2.x;
    Island_natural_0 device* _S925 = islands_6+_S924;
    uint4 _S926 = uint4((*_S925).info_0) ;
    float4 _S927 = float4((*_S925).com_0) ;
    float4 _S928 = float4((*_S925).inertia0_0) ;
    float4 _S929 = float4((*_S925).inertia1_0) ;
    float4 _S930 = float4((*_S925).inertia2_0) ;
    float4 _S931 = float4((*_S925).inv0_0) ;
    float4 _S932 = float4((*_S925).inv1_0) ;
    float4 _S933 = float4((*_S925).inv2_0) ;
    float4 _S934 = float4((*_S925).wcom_0) ;
    float4 _S935 = float4((*_S925).winv0_0) ;
    float4 _S936 = float4((*_S925).winv1_0) ;
    float4 _S937 = float4((*_S925).winv2_0) ;
    float4 _S938 = float4((*_S925).rotation_0) ;
    float4 _S939 = float4((*_S925).position_0) ;
    float4 _S940 = float4((*_S925).position_err_0) ;
    float4 _S941 = float4((*_S925).velocity_0) ;
    float4 _S942 = float4((*_S925).velocity_err_0) ;
    float4 _S943 = float4((*_S925).angular_velocity_0) ;
    uint4 _S944 = uint4((*_S925).done_0) ;
    uint4 _S945 = uint4((*_S925).probes_0) ;
    float4 _S946 = float4((*_S925).energy_0) ;
    float4 _S947 = float4((*_S925).rotation_err_0) ;
    float4 _S948 = float4((*_S925).momentum_0) ;
    float4 _S949 = float4((*_S925).momentum_err_0) ;
    thread Island_0 isl_15;
    (&isl_15)->range_0 = uint4((*_S925).range_0) ;
    (&isl_15)->info_0 = _S926;
    (&isl_15)->com_0 = _S927;
    (&isl_15)->inertia0_0 = _S928;
    (&isl_15)->inertia1_0 = _S929;
    (&isl_15)->inertia2_0 = _S930;
    (&isl_15)->inv0_0 = _S931;
    (&isl_15)->inv1_0 = _S932;
    (&isl_15)->inv2_0 = _S933;
    (&isl_15)->wcom_0 = _S934;
    (&isl_15)->winv0_0 = _S935;
    (&isl_15)->winv1_0 = _S936;
    (&isl_15)->winv2_0 = _S937;
    (&isl_15)->rotation_0 = _S938;
    (&isl_15)->position_0 = _S939;
    (&isl_15)->position_err_0 = _S940;
    (&isl_15)->velocity_0 = _S941;
    (&isl_15)->velocity_err_0 = _S942;
    (&isl_15)->angular_velocity_0 = _S943;
    (&isl_15)->done_0 = _S944;
    (&isl_15)->probes_0 = _S945;
    (&isl_15)->energy_0 = _S946;
    (&isl_15)->rotation_err_0 = _S947;
    (&isl_15)->momentum_0 = _S948;
    (&isl_15)->momentum_err_0 = _S949;
    bool driven_0 = (((&isl_15)->info_0.x) & 2U) != 0U;
    bool _S950 = !((((&isl_15)->info_0.x) & 1U) != 0U);
    bool _S951;
    if(_S950)
    {
        _S951 = !driven_0;
    }
    else
    {
        _S951 = false;
    }
    bool contact_island_0 = (((&isl_15)->info_0.x) & 4U) != 0U;
    bool _S952 = (((&isl_15)->info_0.x) & 16U) != 0U;
    bool _S953 = tid_4 == 0U;
    bool settled_0;
    uint run_0;
    if(_S953)
    {
        if(contact_island_0 != (((&kernelContext_50)->params_0->contact_mode_0) == 1U))
        {
            settled_0 = true;
        }
        else
        {
            settled_0 = (((&isl_15)->info_0.x) & 8U) != 0U;
        }
        if(settled_0)
        {
            run_0 = 0U;
        }
        else
        {
            run_0 = 1U;
        }
        if(contact_island_0)
        {
            thread Island_0 _S954 = isl_15;
            bool _S955 = contact_stopped_1(&_S954, &kernelContext_50);
            settled_0 = _S955;
        }
        else
        {
            settled_0 = false;
        }
        if(settled_0)
        {
            run_0 = 0U;
        }
        *(&kernelContext_50)->g_run_0 = run_0;
        *(&kernelContext_50)->g_halt_0 = 0U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    if((((&isl_15)->info_0.z) & 1U) != 0U)
    {
        settled_0 = true;
    }
    else
    {
        settled_0 = (*(&kernelContext_50)->g_run_0) == 0U;
    }
    if(settled_0)
    {
        run_0 = 0U;
    }
    else
    {
        run_0 = min((&isl_15)->info_0.y, (&kernelContext_50)->params_0->max_steps_0);
    }
    float _S956 = (&kernelContext_50)->params_0->dt_0;
    bool _S957 = ((&kernelContext_50)->params_0->fracture_0) != 0U;
    bool _S958 = ((&kernelContext_50)->params_0->rigid_motion_loads_0) != 0U;
    thread Island_0 _S959 = isl_15;
    Rigid_0 _S960 = rigid_of_1(&_S959);
    thread Rigid_0 rg_13 = _S960;
    thread float work_3 = 0.0f;
    thread float work_err_2 = 0.0f;
    settled_0 = _S952;
    uint done_1 = 0U;
    bool woke_1 = false;
    uint s_7 = 0U;
    for(;;)
    {
        if(s_7 < run_0)
        {
        }
        else
        {
            woke_0 = woke_1;
            break;
        }
        uint abs_step_1 = (&isl_15)->info_0.w + s_7 + 1U;
        uint k_20 = abs_step_1 - 1U - (&kernelContext_50)->params_0->step_start_0;
        bool _S961;
        bool settled_1;
        if((((&isl_15)->info_0.x) & 32U) != 0U)
        {
            if(_S953)
            {
                _S961 = ((&isl_15)->probes_0.y) > ((&isl_15)->probes_0.x);
            }
            else
            {
                _S961 = false;
            }
            if(_S961)
            {
                thread Island_0 _S962 = isl_15;
                thread Rigid_0 _S963 = rg_13;
                record_probes_0(&_S962, &_S963, k_20, &kernelContext_50);
            }
            uint _S964 = s_7 + 1U;
            settled_1 = settled_0;
            done_1 = _S964;
            woke_0 = woke_1;
            uint _S965 = s_7 + 1U;
            settled_0 = settled_1;
            woke_1 = woke_0;
            s_7 = _S965;
            continue;
        }
        uint i_11;
        if(settled_0)
        {
            float3 _S966 = float3(0.0f) ;
            thread float3 norm_0 = _S966;
            thread float3 unused0_0 = _S966;
            i_11 = (&isl_15)->range_0.x + tid_4;
            for(;;)
            {
                if(i_11 < ((&isl_15)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                thread Quat_0 _S967 = (&rg_13)->rot_0;
                float _S968 = settled_chunk_load_0(i_11, &_S967, k_20, _S956, contact_island_0, &kernelContext_50);
                norm_0.x = norm_0.x + _S968;
                i_11 = i_11 + 256U;
            }
            group_sum3_0(tid_4, &norm_0, &unused0_0, &kernelContext_50);
            if(((&kernelContext_50)->params_0->solve_mode_0) == 1U)
            {
                _S961 = (abs(norm_0.x - (&isl_15)->energy_0.z)) > ((&isl_15)->energy_0.w);
            }
            else
            {
                _S961 = false;
            }
            if(_S961)
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
        if(_S950)
        {
            float3 _S969 = float3(0.0f) ;
            thread float3 f_15 = _S969;
            thread float3 t_15 = _S969;
            i_11 = (&isl_15)->range_0.x + tid_4;
            for(;;)
            {
                if(i_11 < ((&isl_15)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                thread Island_0 _S970 = isl_15;
                thread Rigid_0 _S971 = rg_13;
                net_load_1(i_11, &_S970, &_S971, k_20, _S956, contact_island_0, &f_15, &t_15, &kernelContext_50);
                i_11 = i_11 + 256U;
            }
            group_sum3_0(tid_4, &f_15, &t_15, &kernelContext_50);
            thread Island_0 _S972 = isl_15;
            rigid_acceleration_1(&_S972, &rg_13, f_15, t_15);
        }
        if(settled_1)
        {
            if(_S951)
            {
                thread Island_0 _S973 = isl_15;
                integrate_rigid_1(&_S973, &rg_13, _S956);
            }
            if(_S953)
            {
                _S961 = ((&isl_15)->probes_0.y) > ((&isl_15)->probes_0.x);
            }
            else
            {
                _S961 = false;
            }
            if(_S961)
            {
                thread Island_0 _S974 = isl_15;
                thread Rigid_0 _S975 = rg_13;
                record_probes_0(&_S974, &_S975, k_20, &kernelContext_50);
            }
            done_1 = s_7 + 1U;
            uint _S965 = s_7 + 1U;
            settled_0 = settled_1;
            woke_1 = woke_0;
            s_7 = _S965;
            continue;
        }
        i_11 = (&isl_15)->range_0.z + tid_4;
        for(;;)
        {
            if(i_11 < ((&isl_15)->range_0.w))
            {
            }
            else
            {
                break;
            }
            bool _S976 = bond_update_0(i_11, _S956, _S957, abs_step_1, &kernelContext_50);
            if(_S976)
            {
                *(&kernelContext_50)->g_halt_0 = 1U;
            }
            i_11 = i_11 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
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
            thread Island_0 _S977 = isl_15;
            thread Rigid_0 _S978 = rg_13;
            chunk_update_1(c_20, &_S977, &_S978, _S956, _S958, k_20, contact_island_0, &work_3, &work_err_2, &kernelContext_50);
            c_20 = c_20 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        if(_S951)
        {
            thread Island_0 _S979 = isl_15;
            integrate_rigid_1(&_S979, &rg_13, _S956);
        }
        if(_S950)
        {
            float3 _S980 = (&isl_15)->wcom_0.xyz;
            float3 _S981 = float3(0.0f) ;
            thread float3 tu_1 = _S981;
            thread float3 pv_1 = _S981;
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
                drift_moments_0(c_21, &tu_1, &pv_1, &kernelContext_50);
                c_21 = c_21 + 256U;
            }
            group_sum3_0(tid_4, &tu_1, &pv_1, &kernelContext_50);
            float3 tr_4 = tu_1 / float3((&isl_15)->wcom_0.w) ;
            float3 dv_4 = pv_1 / float3((&isl_15)->wcom_0.w) ;
            thread float3 lu_1 = _S981;
            thread float3 lv_1 = _S981;
            uint c_22 = (&isl_15)->range_0.x + tid_4;
            for(;;)
            {
                if(c_22 < ((&isl_15)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_angular_0(c_22, _S980, tr_4, dv_4, &lu_1, &lv_1, &kernelContext_50);
                c_22 = c_22 + 256U;
            }
            group_sum3_0(tid_4, &lu_1, &lv_1, &kernelContext_50);
            float3 phi_4 = rows_mul_0((&isl_15)->winv0_0, (&isl_15)->winv1_0, (&isl_15)->winv2_0, lu_1);
            float3 dw_3 = rows_mul_0((&isl_15)->winv0_0, (&isl_15)->winv1_0, (&isl_15)->winv2_0, lv_1);
            uint c_23 = (&isl_15)->range_0.x + tid_4;
            for(;;)
            {
                if(c_23 < ((&isl_15)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_apply_0(c_23, _S980, tr_4, phi_4, dv_4, dw_3, &kernelContext_50);
                c_23 = c_23 + 256U;
            }
            if(!driven_0)
            {
                thread Island_0 _S982 = isl_15;
                drift_rigid_1(&_S982, &rg_13, tr_4, phi_4, dv_4, dw_3);
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        }
        if(_S953)
        {
            _S961 = ((&isl_15)->probes_0.y) > ((&isl_15)->probes_0.x);
        }
        else
        {
            _S961 = false;
        }
        if(_S961)
        {
            thread Island_0 _S983 = isl_15;
            thread Rigid_0 _S984 = rg_13;
            record_probes_0(&_S983, &_S984, k_20, &kernelContext_50);
        }
        uint _S985 = s_7 + 1U;
        if((*(&kernelContext_50)->g_halt_0) != 0U)
        {
            done_1 = _S985;
            break;
        }
        done_1 = _S985;
        uint _S965 = s_7 + 1U;
        settled_0 = settled_1;
        woke_1 = woke_0;
        s_7 = _S965;
    }
    thread float3 wsum_0 = float3(work_3, work_err_2, 0.0f);
    thread float3 unused_1 = float3(0.0f) ;
    group_sum3_0(tid_4, &wsum_0, &unused_1, &kernelContext_50);
    if(_S953)
    {
        thread Quat_0 _S986 = (&rg_13)->rot_0;
        float4 _S987 = quat_vec_0(&_S986);
        (&isl_15)->rotation_0 = _S987;
        (&isl_15)->rotation_err_0 = (&rg_13)->rot_err_0;
        (&isl_15)->position_0 = float4((&rg_13)->pos_1, 0.0f);
        (&isl_15)->position_err_0 = float4((&rg_13)->pos_err_1, 0.0f);
        (&isl_15)->velocity_0 = float4((&rg_13)->vel_1, 0.0f);
        (&isl_15)->velocity_err_0 = float4((&rg_13)->vel_err_1, 0.0f);
        (&isl_15)->angular_velocity_0 = float4((&rg_13)->w_4, 0.0f);
        (&isl_15)->momentum_0 = float4((&rg_13)->l_2, 0.0f);
        (&isl_15)->momentum_err_0 = float4((&rg_13)->l_err_1, 0.0f);
        (&isl_15)->done_0.x = done_1;
        (&isl_15)->info_0.y = (&isl_15)->info_0.y - done_1;
        if((*(&kernelContext_50)->g_halt_0) != 0U)
        {
            _S951 = contact_island_0;
        }
        else
        {
            _S951 = false;
        }
        if(_S951)
        {
            contact_split_at_0((&isl_15)->info_0.w + done_1, &kernelContext_50);
        }
        float _S988 = wsum_0.x;
        thread float _S989 = (&isl_15)->energy_0.x;
        thread float _S990 = (&isl_15)->energy_0.y;
        comp_add1_0(&_S989, &_S990, _S988);
        (&isl_15)->energy_0.x = _S989;
        (&isl_15)->energy_0.y = _S990 + wsum_0.y;
        (&isl_15)->info_0.w = (&isl_15)->info_0.w + done_1;
        if((*(&kernelContext_50)->g_halt_0) != 0U)
        {
            (&isl_15)->info_0.z = ((&isl_15)->info_0.z) | 1U;
        }
        if(woke_0)
        {
            (&isl_15)->info_0.x = ((&isl_15)->info_0.x) & 4294967279U;
            (&isl_15)->info_0.z = ((&isl_15)->info_0.z) | 4U;
        }
        Island_natural_0 device* _S991 = (&kernelContext_50)->islands_0+_S924;
        _S991->range_0 = packed_uint4(isl_15.range_0) ;
        _S991->info_0 = packed_uint4(isl_15.info_0) ;
        _S991->com_0 = packed_float4(isl_15.com_0) ;
        _S991->inertia0_0 = packed_float4(isl_15.inertia0_0) ;
        _S991->inertia1_0 = packed_float4(isl_15.inertia1_0) ;
        _S991->inertia2_0 = packed_float4(isl_15.inertia2_0) ;
        _S991->inv0_0 = packed_float4(isl_15.inv0_0) ;
        _S991->inv1_0 = packed_float4(isl_15.inv1_0) ;
        _S991->inv2_0 = packed_float4(isl_15.inv2_0) ;
        _S991->wcom_0 = packed_float4(isl_15.wcom_0) ;
        _S991->winv0_0 = packed_float4(isl_15.winv0_0) ;
        _S991->winv1_0 = packed_float4(isl_15.winv1_0) ;
        _S991->winv2_0 = packed_float4(isl_15.winv2_0) ;
        _S991->rotation_0 = packed_float4(isl_15.rotation_0) ;
        _S991->position_0 = packed_float4(isl_15.position_0) ;
        _S991->position_err_0 = packed_float4(isl_15.position_err_0) ;
        _S991->velocity_0 = packed_float4(isl_15.velocity_0) ;
        _S991->velocity_err_0 = packed_float4(isl_15.velocity_err_0) ;
        _S991->angular_velocity_0 = packed_float4(isl_15.angular_velocity_0) ;
        _S991->done_0 = packed_uint4(isl_15.done_0) ;
        _S991->probes_0 = packed_uint4(isl_15.probes_0) ;
        _S991->energy_0 = packed_float4(isl_15.energy_0) ;
        _S991->rotation_err_0 = packed_float4(isl_15.rotation_err_0) ;
        _S991->momentum_0 = packed_float4(isl_15.momentum_0) ;
        _S991->momentum_err_0 = packed_float4(isl_15.momentum_err_0) ;
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

WideGroup_0 wide_group_0(uint table_0, uint g_2, KernelContext_0 thread* kernelContext_51)
{
    thread WideGroup_0 w_11;
    uint _S992 = table_0 + 4U * g_2;
    (&w_11)->island_0 = kernelContext_51->index_0[_S992];
    (&w_11)->begin_1 = kernelContext_51->index_0[_S992 + 1U];
    (&w_11)->end_0 = kernelContext_51->index_0[_S992 + 2U];
    (&w_11)->first_0 = kernelContext_51->index_0[_S992 + 3U];
    return w_11;
}

bool wide_runs_0(const Island_natural_0 thread* isl_16, KernelContext_0 thread* kernelContext_52)
{
    uint4 _S993 = uint4(isl_16->info_0) ;
    bool _S994;
    if(((_S993.z) & 1U) != 0U)
    {
        _S994 = true;
    }
    else
    {
        _S994 = (_S993.y) == 0U;
    }
    if(_S994)
    {
        return false;
    }
    if(((_S993.x) & 4U) == 0U)
    {
        _S994 = true;
    }
    else
    {
        bool _S995 = contact_stopped_0(isl_16, kernelContext_52);
        _S994 = !_S995;
    }
    return _S994;
}

bool wide_enter_0(uint tid_5, const Island_natural_0 thread* isl_17, KernelContext_0 thread* kernelContext_53)
{
    if(tid_5 == 0U)
    {
        bool _S996 = wide_runs_0(isl_17, kernelContext_53);
        int _S997;
        if(_S996)
        {
            _S997 = int(1);
        }
        else
        {
            _S997 = int(0);
        }
        *kernelContext_53->g_wide_run_0 = uint(_S997);
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    return (*kernelContext_53->g_wide_run_0) != 0U;
}

uint wide_step_0(const Island_natural_0 thread* isl_18, KernelContext_0 thread* kernelContext_54)
{
    return (uint4(isl_18->info_0) ).w - kernelContext_54->params_0->step_start_0;
}

uint wide_step_1(const Island_0 thread* isl_19, KernelContext_0 thread* kernelContext_55)
{
    return isl_19->info_0.w - kernelContext_55->params_0->step_start_0;
}

bool contact_stopped_2(uint _S998, KernelContext_0 thread* kernelContext_56)
{
    Island_natural_0 device* _S999 = kernelContext_56->islands_0+_S998;
    uint4 _S1000 = uint4((kernelContext_56->islands_0+kernelContext_56->params_0->halt_index_0)->info_0) ;
    bool _S1001;
    if(((_S1000.z) & 1U) != 0U)
    {
        _S1001 = true;
    }
    else
    {
        uint _S1002 = _S1000.y;
        if(_S1002 != 0U)
        {
            _S1001 = _S1002 <= ((uint4(_S999->info_0) ).w);
        }
        else
        {
            _S1001 = false;
        }
    }
    return _S1001;
}

bool wide_runs_1(uint _S1003, KernelContext_0 thread* kernelContext_57)
{
    uint4 _S1004 = uint4((kernelContext_57->islands_0+_S1003)->info_0) ;
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
        bool _S1006 = contact_stopped_2(_S1003, kernelContext_57);
        _S1005 = !_S1006;
    }
    return _S1005;
}

bool wide_enter_1(uint _S1007, uint _S1008, KernelContext_0 thread* kernelContext_58)
{
    if(_S1007 == 0U)
    {
        bool _S1009 = wide_runs_1(_S1008, kernelContext_58);
        int _S1010;
        if(_S1009)
        {
            _S1010 = int(1);
        }
        else
        {
            _S1010 = int(0);
        }
        *kernelContext_58->g_wide_run_0 = uint(_S1010);
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    return (*kernelContext_58->g_wide_run_0) != 0U;
}

[[kernel]] void wide_wake(uint3 group_3 [[threadgroup_position_in_grid]], uint3 thread_3 [[thread_position_in_threadgroup]], Params_0 constant* params_7 [[buffer(0)]], Island_natural_0 device* islands_7 [[buffer(9)]], uint device* index_7 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_7 [[buffer(3)]], packed_float4 device* state_9 [[buffer(6)]], packed_float4 device* scratch_7 [[buffer(8)]], packed_float4 device* contact_state_7 [[buffer(11)]], packed_float4 device* loads_7 [[buffer(5)]], Impactor_natural_0 device* impactors_7 [[buffer(10)]], BondStatic_natural_0 device* bonds_7 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_7 [[buffer(7)]], MaterialTable_0 constant* materials_7 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_59;
    (&kernelContext_59)->params_0 = params_7;
    (&kernelContext_59)->islands_0 = islands_7;
    (&kernelContext_59)->index_0 = index_7;
    (&kernelContext_59)->chunks_0 = chunks_7;
    (&kernelContext_59)->state_0 = state_9;
    (&kernelContext_59)->scratch_0 = scratch_7;
    (&kernelContext_59)->contact_state_0 = contact_state_7;
    (&kernelContext_59)->loads_0 = loads_7;
    (&kernelContext_59)->impactors_0 = impactors_7;
    (&kernelContext_59)->bonds_0 = bonds_7;
    (&kernelContext_59)->bond_dyn_0 = bond_dyn_7;
    (&kernelContext_59)->materials_0 = materials_7;
    threadgroup array<float4, int(32)> g_part_a_7;
    (&kernelContext_59)->g_part_a_0 = &g_part_a_7;
    threadgroup array<float4, int(32)> g_part_b_7;
    (&kernelContext_59)->g_part_b_0 = &g_part_b_7;
    threadgroup uint g_run_7;
    (&kernelContext_59)->g_run_0 = &g_run_7;
    threadgroup uint g_halt_7;
    (&kernelContext_59)->g_halt_0 = &g_halt_7;
    threadgroup uint g_wide_run_7;
    (&kernelContext_59)->g_wide_run_0 = &g_wide_run_7;
    uint tid_6 = thread_3.x;
    uint _S1011 = group_3.x;
    WideGroup_0 _S1012 = wide_group_0(params_7->wide_chunk_table_0, _S1011, &kernelContext_59);
    if(_S1011 != (_S1012.first_0))
    {
        return;
    }
    thread Island_natural_0 _S1013 = *((&kernelContext_59)->islands_0+_S1012.island_0);
    uint4 _S1014 = uint4((&_S1013)->info_0) ;
    uint _S1015 = _S1014.x;
    bool _S1016;
    if((_S1015 & 16U) == 0U)
    {
        _S1016 = true;
    }
    else
    {
        bool _S1017 = wide_enter_1(tid_6, _S1012.island_0, &kernelContext_59);
        _S1016 = !_S1017;
    }
    if(_S1016)
    {
        return;
    }
    Quat_0 _S1018 = quat_of_0(float4((&_S1013)->rotation_0) );
    bool _S1019 = (_S1015 & 4U) != 0U;
    float3 _S1020 = float3(0.0f) ;
    thread float3 norm_1 = _S1020;
    thread float3 unused_2 = _S1020;
    uint4 _S1021 = uint4((&_S1013)->range_0) ;
    uint c_24 = _S1021.x + tid_6;
    for(;;)
    {
        if(c_24 < (_S1021.y))
        {
        }
        else
        {
            break;
        }
        uint _S1022 = wide_step_0(&_S1013, &kernelContext_59);
        float _S1023 = (&kernelContext_59)->params_0->dt_0;
        thread Quat_0 _S1024 = _S1018;
        float _S1025 = settled_chunk_load_0(c_24, &_S1024, _S1022, _S1023, _S1019, &kernelContext_59);
        norm_1.x = norm_1.x + _S1025;
        c_24 = c_24 + 256U;
    }
    group_sum3_0(tid_6, &norm_1, &unused_2, &kernelContext_59);
    if(tid_6 == 0U)
    {
        _S1016 = ((&kernelContext_59)->params_0->solve_mode_0) == 1U;
    }
    else
    {
        _S1016 = false;
    }
    if(_S1016)
    {
        float4 _S1026 = float4((&_S1013)->energy_0) ;
        _S1016 = (abs(norm_1.x - _S1026.z)) > (_S1026.w);
    }
    else
    {
        _S1016 = false;
    }
    if(_S1016)
    {
        ((&kernelContext_59)->islands_0+_S1012.island_0)->info_0[int(0)] = _S1015 & 4294967279U;
        ((&kernelContext_59)->islands_0+_S1012.island_0)->info_0[int(2)] = (_S1014.z) | 4U;
    }
    return;
}

void wide_store_0(uint slot_2, uint p_14, float3 a_12, float3 b_29, KernelContext_0 thread* kernelContext_60)
{
    uint _S1027 = 8U * slot_2;
    *(kernelContext_60->scratch_0+(kernelContext_60->params_0->wide_base_0 + _S1027 + p_14)) = packed_float4(float4(a_12, 0.0f)) ;
    *(kernelContext_60->scratch_0+(kernelContext_60->params_0->wide_base_0 + _S1027 + p_14 + 1U)) = packed_float4(float4(b_29, 0.0f)) ;
    return;
}

[[kernel]] void wide_bonds(uint3 group_4 [[threadgroup_position_in_grid]], uint3 thread_4 [[thread_position_in_threadgroup]], Params_0 constant* params_8 [[buffer(0)]], Island_natural_0 device* islands_8 [[buffer(9)]], uint device* index_8 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_8 [[buffer(3)]], packed_float4 device* state_10 [[buffer(6)]], packed_float4 device* scratch_8 [[buffer(8)]], packed_float4 device* contact_state_8 [[buffer(11)]], packed_float4 device* loads_8 [[buffer(5)]], Impactor_natural_0 device* impactors_8 [[buffer(10)]], BondStatic_natural_0 device* bonds_8 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_8 [[buffer(7)]], MaterialTable_0 constant* materials_8 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_61;
    (&kernelContext_61)->params_0 = params_8;
    (&kernelContext_61)->islands_0 = islands_8;
    (&kernelContext_61)->index_0 = index_8;
    (&kernelContext_61)->chunks_0 = chunks_8;
    (&kernelContext_61)->state_0 = state_10;
    (&kernelContext_61)->scratch_0 = scratch_8;
    (&kernelContext_61)->contact_state_0 = contact_state_8;
    (&kernelContext_61)->loads_0 = loads_8;
    (&kernelContext_61)->impactors_0 = impactors_8;
    (&kernelContext_61)->bonds_0 = bonds_8;
    (&kernelContext_61)->bond_dyn_0 = bond_dyn_8;
    (&kernelContext_61)->materials_0 = materials_8;
    threadgroup array<float4, int(32)> g_part_a_8;
    (&kernelContext_61)->g_part_a_0 = &g_part_a_8;
    threadgroup array<float4, int(32)> g_part_b_8;
    (&kernelContext_61)->g_part_b_0 = &g_part_b_8;
    threadgroup uint g_run_8;
    (&kernelContext_61)->g_run_0 = &g_run_8;
    threadgroup uint g_halt_8;
    (&kernelContext_61)->g_halt_0 = &g_halt_8;
    threadgroup uint g_wide_run_8;
    (&kernelContext_61)->g_wide_run_0 = &g_wide_run_8;
    uint tid_7 = thread_4.x;
    uint _S1028 = group_4.x;
    bool bond_group_0 = _S1028 < (params_8->wide_bond_groups_0);
    WideGroup_0 wg_0;
    if(bond_group_0)
    {
        WideGroup_0 _S1029 = wide_group_0((&kernelContext_61)->params_0->wide_bond_table_0, _S1028, &kernelContext_61);
        wg_0 = _S1029;
    }
    else
    {
        WideGroup_0 _S1030 = wide_group_0((&kernelContext_61)->params_0->wide_chunk_table_0, _S1028 - params_8->wide_bond_groups_0, &kernelContext_61);
        wg_0 = _S1030;
    }
    WideGroup_0 _S1031 = wg_0;
    thread Island_natural_0 _S1032 = *((&kernelContext_61)->islands_0+wg_0.island_0);
    bool _S1033 = wide_enter_1(tid_7, wg_0.island_0, &kernelContext_61);
    if(!_S1033)
    {
        return;
    }
    uint _S1034 = wide_step_0(&_S1032, &kernelContext_61);
    if(bond_group_0)
    {
        uint4 _S1035 = uint4((&_S1032)->info_0) ;
        if(((_S1035.x) & 16U) != 0U)
        {
            return;
        }
        uint i_12 = wg_0.begin_1 + tid_7;
        bool _S1036;
        if(i_12 < (wg_0.end_0))
        {
            bool _S1037 = bond_update_0(i_12, (&kernelContext_61)->params_0->dt_0, ((&kernelContext_61)->params_0->fracture_0) != 0U, _S1035.w + 1U, &kernelContext_61);
            _S1036 = _S1037;
        }
        else
        {
            _S1036 = false;
        }
        if(_S1036)
        {
            ((&kernelContext_61)->islands_0+_S1031.island_0)->info_0[int(2)] = (_S1035.z) | 2U;
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
    uint c_25 = wg_0.begin_1 + tid_7;
    if(c_25 < (wg_0.end_0))
    {
        Rigid_0 _S1040 = rigid_of_0(&_S1032);
        float _S1041 = (&kernelContext_61)->params_0->dt_0;
        bool _S1042 = (_S1038 & 4U) != 0U;
        thread Rigid_0 _S1043 = _S1040;
        net_load_0(c_25, &_S1032, &_S1043, _S1034, _S1041, _S1042, &f_16, &t_16, &kernelContext_61);
    }
    group_sum3_0(tid_7, &f_16, &t_16, &kernelContext_61);
    if(tid_7 == 0U)
    {
        wide_store_0(_S1028 - params_8->wide_bond_groups_0, 0U, f_16, t_16, &kernelContext_61);
    }
    return;
}

void wide_partials_0(uint tid_8, uint first_1, uint count_5, uint p_15, float3 thread* a_13, float3 thread* b_30, KernelContext_0 thread* kernelContext_62)
{
    float4 _S1044 = float4(0.0f) ;
    thread float4 x_10 = _S1044;
    thread float4 y_2 = _S1044;
    uint s_8 = tid_8;
    for(;;)
    {
        if(s_8 < count_5)
        {
        }
        else
        {
            break;
        }
        uint _S1045 = 8U * (first_1 + s_8);
        x_10 = x_10 + float4(*(kernelContext_62->scratch_0+(kernelContext_62->params_0->wide_base_0 + _S1045 + p_15))) ;
        y_2 = y_2 + float4(*(kernelContext_62->scratch_0+(kernelContext_62->params_0->wide_base_0 + _S1045 + p_15 + 1U))) ;
        s_8 = s_8 + 256U;
    }
    group_sum2_0(tid_8, &x_10, &y_2, kernelContext_62);
    *a_13 = x_10.xyz;
    *b_30 = y_2.xyz;
    return;
}

Rigid_0 wide_rigid_frame_0(uint tid_9, const Island_natural_0 thread* isl_20, const WideGroup_0 thread* wg_1, KernelContext_0 thread* kernelContext_63)
{
    Rigid_0 _S1046 = rigid_of_0(isl_20);
    thread Rigid_0 rg_14 = _S1046;
    if((((uint4(isl_20->info_0) ).x) & 1U) == 0U)
    {
        thread float3 f_17;
        thread float3 t_17;
        wide_partials_0(tid_9, wg_1->first_0, (uint4(isl_20->done_0) ).z, 0U, &f_17, &t_17, kernelContext_63);
        rigid_acceleration_0(isl_20, &rg_14, f_17, t_17);
    }
    return rg_14;
}

[[kernel]] void wide_chunks(uint3 group_5 [[threadgroup_position_in_grid]], uint3 thread_5 [[thread_position_in_threadgroup]], Params_0 constant* params_9 [[buffer(0)]], Island_natural_0 device* islands_9 [[buffer(9)]], uint device* index_9 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_9 [[buffer(3)]], packed_float4 device* state_11 [[buffer(6)]], packed_float4 device* scratch_9 [[buffer(8)]], packed_float4 device* contact_state_9 [[buffer(11)]], packed_float4 device* loads_9 [[buffer(5)]], Impactor_natural_0 device* impactors_9 [[buffer(10)]], BondStatic_natural_0 device* bonds_9 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_9 [[buffer(7)]], MaterialTable_0 constant* materials_9 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_64;
    (&kernelContext_64)->params_0 = params_9;
    (&kernelContext_64)->islands_0 = islands_9;
    (&kernelContext_64)->index_0 = index_9;
    (&kernelContext_64)->chunks_0 = chunks_9;
    (&kernelContext_64)->state_0 = state_11;
    (&kernelContext_64)->scratch_0 = scratch_9;
    (&kernelContext_64)->contact_state_0 = contact_state_9;
    (&kernelContext_64)->loads_0 = loads_9;
    (&kernelContext_64)->impactors_0 = impactors_9;
    (&kernelContext_64)->bonds_0 = bonds_9;
    (&kernelContext_64)->bond_dyn_0 = bond_dyn_9;
    (&kernelContext_64)->materials_0 = materials_9;
    threadgroup array<float4, int(32)> g_part_a_9;
    (&kernelContext_64)->g_part_a_0 = &g_part_a_9;
    threadgroup array<float4, int(32)> g_part_b_9;
    (&kernelContext_64)->g_part_b_0 = &g_part_b_9;
    threadgroup uint g_run_9;
    (&kernelContext_64)->g_run_0 = &g_run_9;
    threadgroup uint g_halt_9;
    (&kernelContext_64)->g_halt_0 = &g_halt_9;
    threadgroup uint g_wide_run_9;
    (&kernelContext_64)->g_wide_run_0 = &g_wide_run_9;
    uint tid_10 = thread_5.x;
    uint _S1047 = group_5.x;
    WideGroup_0 _S1048 = wide_group_0(params_9->wide_chunk_table_0, _S1047, &kernelContext_64);
    thread Island_natural_0 _S1049 = *((&kernelContext_64)->islands_0+_S1048.island_0);
    bool _S1050 = wide_enter_1(tid_10, _S1048.island_0, &kernelContext_64);
    if(!_S1050)
    {
        return;
    }
    uint _S1051 = (uint4((&_S1049)->info_0) ).x;
    bool anchored_0 = (_S1051 & 1U) != 0U;
    if((_S1051 & 16U) != 0U)
    {
        if(tid_10 == 0U)
        {
            *((&kernelContext_64)->scratch_0+((&kernelContext_64)->params_0->wide_base_0 + 8U * _S1047 + 6U)) = packed_float4(float4(0.0f) ) ;
        }
        return;
    }
    thread WideGroup_0 _S1052 = _S1048;
    Rigid_0 _S1053 = wide_rigid_frame_0(tid_10, &_S1049, &_S1052, &kernelContext_64);
    thread float work_4 = 0.0f;
    thread float work_err_3 = 0.0f;
    float3 _S1054 = float3(0.0f) ;
    thread float3 tu_2 = _S1054;
    thread float3 pv_2 = _S1054;
    uint c_26 = _S1048.begin_1 + tid_10;
    if(c_26 < (_S1048.end_0))
    {
        float _S1055 = (&kernelContext_64)->params_0->dt_0;
        bool _S1056 = ((&kernelContext_64)->params_0->rigid_motion_loads_0) != 0U;
        uint _S1057 = wide_step_0(&_S1049, &kernelContext_64);
        bool _S1058 = (_S1051 & 4U) != 0U;
        thread Rigid_0 _S1059 = _S1053;
        chunk_update_0(c_26, &_S1049, &_S1059, _S1055, _S1056, _S1057, _S1058, &work_4, &work_err_3, &kernelContext_64);
        if(!anchored_0)
        {
            drift_moments_0(c_26, &tu_2, &pv_2, &kernelContext_64);
        }
    }
    thread float3 wsum_1 = float3(work_4, work_err_3, 0.0f);
    thread float3 unused_3 = _S1054;
    group_sum3_0(tid_10, &wsum_1, &unused_3, &kernelContext_64);
    bool _S1060 = !anchored_0;
    if(_S1060)
    {
        group_sum3_0(tid_10, &tu_2, &pv_2, &kernelContext_64);
    }
    if(tid_10 == 0U)
    {
        *((&kernelContext_64)->scratch_0+((&kernelContext_64)->params_0->wide_base_0 + 8U * _S1047 + 6U)) = packed_float4(float4(wsum_1, 0.0f)) ;
        if(_S1060)
        {
            wide_store_0(_S1047, 2U, tu_2, pv_2, &kernelContext_64);
        }
    }
    return;
}

[[kernel]] void wide_drift(uint3 group_6 [[threadgroup_position_in_grid]], uint3 thread_6 [[thread_position_in_threadgroup]], Params_0 constant* params_10 [[buffer(0)]], Island_natural_0 device* islands_10 [[buffer(9)]], uint device* index_10 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_10 [[buffer(3)]], packed_float4 device* state_12 [[buffer(6)]], packed_float4 device* scratch_10 [[buffer(8)]], packed_float4 device* contact_state_10 [[buffer(11)]], packed_float4 device* loads_10 [[buffer(5)]], Impactor_natural_0 device* impactors_10 [[buffer(10)]], BondStatic_natural_0 device* bonds_10 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_10 [[buffer(7)]], MaterialTable_0 constant* materials_10 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_65;
    (&kernelContext_65)->params_0 = params_10;
    (&kernelContext_65)->islands_0 = islands_10;
    (&kernelContext_65)->index_0 = index_10;
    (&kernelContext_65)->chunks_0 = chunks_10;
    (&kernelContext_65)->state_0 = state_12;
    (&kernelContext_65)->scratch_0 = scratch_10;
    (&kernelContext_65)->contact_state_0 = contact_state_10;
    (&kernelContext_65)->loads_0 = loads_10;
    (&kernelContext_65)->impactors_0 = impactors_10;
    (&kernelContext_65)->bonds_0 = bonds_10;
    (&kernelContext_65)->bond_dyn_0 = bond_dyn_10;
    (&kernelContext_65)->materials_0 = materials_10;
    threadgroup array<float4, int(32)> g_part_a_10;
    (&kernelContext_65)->g_part_a_0 = &g_part_a_10;
    threadgroup array<float4, int(32)> g_part_b_10;
    (&kernelContext_65)->g_part_b_0 = &g_part_b_10;
    threadgroup uint g_run_10;
    (&kernelContext_65)->g_run_0 = &g_run_10;
    threadgroup uint g_halt_10;
    (&kernelContext_65)->g_halt_0 = &g_halt_10;
    threadgroup uint g_wide_run_10;
    (&kernelContext_65)->g_wide_run_0 = &g_wide_run_10;
    uint tid_11 = thread_6.x;
    uint _S1061 = group_6.x;
    WideGroup_0 _S1062 = wide_group_0(params_10->wide_chunk_table_0, _S1061, &kernelContext_65);
    Island_natural_0 device* _S1063 = (&kernelContext_65)->islands_0+_S1062.island_0;
    Island_natural_0 isl_21 = *_S1063;
    bool _S1064;
    if((((uint4((*_S1063).info_0) ).x) & 17U) != 0U)
    {
        _S1064 = true;
    }
    else
    {
        bool _S1065 = wide_enter_1(tid_11, _S1062.island_0, &kernelContext_65);
        _S1064 = !_S1065;
    }
    if(_S1064)
    {
        return;
    }
    thread float3 tu_3;
    thread float3 pv_3;
    wide_partials_0(tid_11, _S1062.first_0, (uint4(isl_21.done_0) ).z, 2U, &tu_3, &pv_3, &kernelContext_65);
    float4 _S1066 = float4(isl_21.wcom_0) ;
    float3 _S1067 = float3(_S1066.w) ;
    float3 tr_5 = tu_3 / _S1067;
    float3 dv_5 = pv_3 / _S1067;
    float3 _S1068 = float3(0.0f) ;
    thread float3 lu_2 = _S1068;
    thread float3 lv_2 = _S1068;
    uint c_27 = _S1062.begin_1 + tid_11;
    if(c_27 < (_S1062.end_0))
    {
        drift_angular_0(c_27, _S1066.xyz, tr_5, dv_5, &lu_2, &lv_2, &kernelContext_65);
    }
    group_sum3_0(tid_11, &lu_2, &lv_2, &kernelContext_65);
    if(tid_11 == 0U)
    {
        wide_store_0(_S1061, 4U, lu_2, lv_2, &kernelContext_65);
    }
    return;
}

[[kernel]] void wide_rigid(uint3 group_7 [[threadgroup_position_in_grid]], uint3 thread_7 [[thread_position_in_threadgroup]], Params_0 constant* params_11 [[buffer(0)]], Island_natural_0 device* islands_11 [[buffer(9)]], uint device* index_11 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_11 [[buffer(3)]], packed_float4 device* state_13 [[buffer(6)]], packed_float4 device* scratch_11 [[buffer(8)]], packed_float4 device* contact_state_11 [[buffer(11)]], packed_float4 device* loads_11 [[buffer(5)]], Impactor_natural_0 device* impactors_11 [[buffer(10)]], BondStatic_natural_0 device* bonds_11 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_11 [[buffer(7)]], MaterialTable_0 constant* materials_11 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_66;
    (&kernelContext_66)->params_0 = params_11;
    (&kernelContext_66)->islands_0 = islands_11;
    (&kernelContext_66)->index_0 = index_11;
    (&kernelContext_66)->chunks_0 = chunks_11;
    (&kernelContext_66)->state_0 = state_13;
    (&kernelContext_66)->scratch_0 = scratch_11;
    (&kernelContext_66)->contact_state_0 = contact_state_11;
    (&kernelContext_66)->loads_0 = loads_11;
    (&kernelContext_66)->impactors_0 = impactors_11;
    (&kernelContext_66)->bonds_0 = bonds_11;
    (&kernelContext_66)->bond_dyn_0 = bond_dyn_11;
    (&kernelContext_66)->materials_0 = materials_11;
    threadgroup array<float4, int(32)> g_part_a_11;
    (&kernelContext_66)->g_part_a_0 = &g_part_a_11;
    threadgroup array<float4, int(32)> g_part_b_11;
    (&kernelContext_66)->g_part_b_0 = &g_part_b_11;
    threadgroup uint g_run_11;
    (&kernelContext_66)->g_run_0 = &g_run_11;
    threadgroup uint g_halt_11;
    (&kernelContext_66)->g_halt_0 = &g_halt_11;
    threadgroup uint g_wide_run_11;
    (&kernelContext_66)->g_wide_run_0 = &g_wide_run_11;
    uint tid_12 = thread_7.x;
    uint _S1069 = group_7.x;
    WideGroup_0 _S1070 = wide_group_0(params_11->wide_chunk_table_0, _S1069, &kernelContext_66);
    thread Island_natural_0 _S1071 = *((&kernelContext_66)->islands_0+_S1070.island_0);
    uint _S1072 = (uint4((&_S1071)->info_0) ).x;
    bool _S1073;
    if((_S1072 & 1U) != 0U)
    {
        _S1073 = true;
    }
    else
    {
        bool _S1074 = wide_enter_1(tid_12, _S1070.island_0, &kernelContext_66);
        _S1073 = !_S1074;
    }
    if(_S1073)
    {
        return;
    }
    if((_S1072 & 16U) != 0U)
    {
        if(_S1069 != (_S1070.first_0))
        {
            return;
        }
        thread WideGroup_0 _S1075 = _S1070;
        Rigid_0 _S1076 = wide_rigid_frame_0(tid_12, &_S1071, &_S1075, &kernelContext_66);
        thread Rigid_0 rs_0 = _S1076;
        if(tid_12 != 0U)
        {
            _S1073 = true;
        }
        else
        {
            _S1073 = (_S1072 & 2U) != 0U;
        }
        if(_S1073)
        {
            return;
        }
        integrate_rigid_0(&_S1071, &rs_0, (&kernelContext_66)->params_0->dt_0);
        thread Quat_0 _S1077 = (&rs_0)->rot_0;
        float4 _S1078 = quat_vec_0(&_S1077);
        ((&kernelContext_66)->islands_0+_S1070.island_0)->rotation_0 = packed_float4(_S1078) ;
        ((&kernelContext_66)->islands_0+_S1070.island_0)->rotation_err_0 = packed_float4((&rs_0)->rot_err_0) ;
        ((&kernelContext_66)->islands_0+_S1070.island_0)->position_0 = packed_float4(float4((&rs_0)->pos_1, 0.0f)) ;
        ((&kernelContext_66)->islands_0+_S1070.island_0)->position_err_0 = packed_float4(float4((&rs_0)->pos_err_1, 0.0f)) ;
        ((&kernelContext_66)->islands_0+_S1070.island_0)->velocity_0 = packed_float4(float4((&rs_0)->vel_1, 0.0f)) ;
        ((&kernelContext_66)->islands_0+_S1070.island_0)->velocity_err_0 = packed_float4(float4((&rs_0)->vel_err_1, 0.0f)) ;
        ((&kernelContext_66)->islands_0+_S1070.island_0)->angular_velocity_0 = packed_float4(float4((&rs_0)->w_4, 0.0f)) ;
        ((&kernelContext_66)->islands_0+_S1070.island_0)->momentum_0 = packed_float4(float4((&rs_0)->l_2, 0.0f)) ;
        ((&kernelContext_66)->islands_0+_S1070.island_0)->momentum_err_0 = packed_float4(float4((&rs_0)->l_err_1, 0.0f)) ;
        return;
    }
    uint _S1079 = (uint4((&_S1071)->done_0) ).z;
    thread float3 tu_4;
    thread float3 pv_4;
    wide_partials_0(tid_12, _S1070.first_0, _S1079, 2U, &tu_4, &pv_4, &kernelContext_66);
    thread float3 lu_3;
    thread float3 lv_3;
    wide_partials_0(tid_12, _S1070.first_0, _S1079, 4U, &lu_3, &lv_3, &kernelContext_66);
    float4 _S1080 = float4((&_S1071)->wcom_0) ;
    float3 _S1081 = float3(_S1080.w) ;
    float3 tr_6 = tu_4 / _S1081;
    float3 dv_6 = pv_4 / _S1081;
    float4 _S1082 = float4((&_S1071)->winv0_0) ;
    float4 _S1083 = float4((&_S1071)->winv1_0) ;
    float4 _S1084 = float4((&_S1071)->winv2_0) ;
    float3 phi_5 = rows_mul_0(_S1082, _S1083, _S1084, lu_3);
    float3 dw_4 = rows_mul_0(_S1082, _S1083, _S1084, lv_3);
    uint c_28 = _S1070.begin_1 + tid_12;
    if(c_28 < (_S1070.end_0))
    {
        drift_apply_0(c_28, _S1080.xyz, tr_6, phi_5, dv_6, dw_4, &kernelContext_66);
    }
    if(_S1069 != (_S1070.first_0))
    {
        return;
    }
    thread WideGroup_0 _S1085 = _S1070;
    Rigid_0 _S1086 = wide_rigid_frame_0(tid_12, &_S1071, &_S1085, &kernelContext_66);
    thread Rigid_0 rg_15 = _S1086;
    if(tid_12 != 0U)
    {
        return;
    }
    if(!((_S1072 & 2U) != 0U))
    {
        integrate_rigid_0(&_S1071, &rg_15, (&kernelContext_66)->params_0->dt_0);
        drift_rigid_0(&_S1071, &rg_15, tr_6, phi_5, dv_6, dw_4);
    }
    thread Quat_0 _S1087 = (&rg_15)->rot_0;
    float4 _S1088 = quat_vec_0(&_S1087);
    ((&kernelContext_66)->islands_0+_S1070.island_0)->rotation_0 = packed_float4(_S1088) ;
    ((&kernelContext_66)->islands_0+_S1070.island_0)->rotation_err_0 = packed_float4((&rg_15)->rot_err_0) ;
    ((&kernelContext_66)->islands_0+_S1070.island_0)->position_0 = packed_float4(float4((&rg_15)->pos_1, 0.0f)) ;
    ((&kernelContext_66)->islands_0+_S1070.island_0)->position_err_0 = packed_float4(float4((&rg_15)->pos_err_1, 0.0f)) ;
    ((&kernelContext_66)->islands_0+_S1070.island_0)->velocity_0 = packed_float4(float4((&rg_15)->vel_1, 0.0f)) ;
    ((&kernelContext_66)->islands_0+_S1070.island_0)->velocity_err_0 = packed_float4(float4((&rg_15)->vel_err_1, 0.0f)) ;
    ((&kernelContext_66)->islands_0+_S1070.island_0)->angular_velocity_0 = packed_float4(float4((&rg_15)->w_4, 0.0f)) ;
    ((&kernelContext_66)->islands_0+_S1070.island_0)->momentum_0 = packed_float4(float4((&rg_15)->l_2, 0.0f)) ;
    ((&kernelContext_66)->islands_0+_S1070.island_0)->momentum_err_0 = packed_float4(float4((&rg_15)->l_err_1, 0.0f)) ;
    return;
}

[[kernel]] void wide_end(uint3 group_8 [[threadgroup_position_in_grid]], uint3 thread_8 [[thread_position_in_threadgroup]], Params_0 constant* params_12 [[buffer(0)]], Island_natural_0 device* islands_12 [[buffer(9)]], uint device* index_12 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_12 [[buffer(3)]], packed_float4 device* state_14 [[buffer(6)]], packed_float4 device* scratch_12 [[buffer(8)]], packed_float4 device* contact_state_12 [[buffer(11)]], packed_float4 device* loads_12 [[buffer(5)]], Impactor_natural_0 device* impactors_12 [[buffer(10)]], BondStatic_natural_0 device* bonds_12 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_12 [[buffer(7)]], MaterialTable_0 constant* materials_12 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_67;
    (&kernelContext_67)->params_0 = params_12;
    (&kernelContext_67)->islands_0 = islands_12;
    (&kernelContext_67)->index_0 = index_12;
    (&kernelContext_67)->chunks_0 = chunks_12;
    (&kernelContext_67)->state_0 = state_14;
    (&kernelContext_67)->scratch_0 = scratch_12;
    (&kernelContext_67)->contact_state_0 = contact_state_12;
    (&kernelContext_67)->loads_0 = loads_12;
    (&kernelContext_67)->impactors_0 = impactors_12;
    (&kernelContext_67)->bonds_0 = bonds_12;
    (&kernelContext_67)->bond_dyn_0 = bond_dyn_12;
    (&kernelContext_67)->materials_0 = materials_12;
    threadgroup array<float4, int(32)> g_part_a_12;
    (&kernelContext_67)->g_part_a_0 = &g_part_a_12;
    threadgroup array<float4, int(32)> g_part_b_12;
    (&kernelContext_67)->g_part_b_0 = &g_part_b_12;
    threadgroup uint g_run_12;
    (&kernelContext_67)->g_run_0 = &g_run_12;
    threadgroup uint g_halt_12;
    (&kernelContext_67)->g_halt_0 = &g_halt_12;
    threadgroup uint g_wide_run_12;
    (&kernelContext_67)->g_wide_run_0 = &g_wide_run_12;
    uint tid_13 = thread_8.x;
    uint _S1089 = group_8.x;
    WideGroup_0 _S1090 = wide_group_0(params_12->wide_chunk_table_0, _S1089, &kernelContext_67);
    if(_S1089 != (_S1090.first_0))
    {
        return;
    }
    Island_natural_0 device* _S1091 = (&kernelContext_67)->islands_0+_S1090.island_0;
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
    uint4 _S1111 = uint4((&_S1092)->done_0) ;
    uint4 _S1112 = uint4((&_S1092)->probes_0) ;
    float4 _S1113 = float4((&_S1092)->energy_0) ;
    float4 _S1114 = float4((&_S1092)->rotation_err_0) ;
    float4 _S1115 = float4((&_S1092)->momentum_0) ;
    float4 _S1116 = float4((&_S1092)->momentum_err_0) ;
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
    (&isl_22)->done_0 = _S1111;
    (&isl_22)->probes_0 = _S1112;
    (&isl_22)->energy_0 = _S1113;
    (&isl_22)->rotation_err_0 = _S1114;
    (&isl_22)->momentum_0 = _S1115;
    (&isl_22)->momentum_err_0 = _S1116;
    _S1092 = *_S1091;
    bool _S1117 = wide_enter_0(tid_13, &_S1092, &kernelContext_67);
    if(!_S1117)
    {
        return;
    }
    thread float3 work_5;
    thread float3 unused_4;
    wide_partials_0(tid_13, _S1090.first_0, (&isl_22)->done_0.z, 6U, &work_5, &unused_4, &kernelContext_67);
    if(tid_13 != 0U)
    {
        return;
    }
    thread Island_0 _S1118 = isl_22;
    uint _S1119 = wide_step_1(&_S1118, &kernelContext_67);
    if(((&isl_22)->probes_0.y) > ((&isl_22)->probes_0.x))
    {
        thread Island_0 _S1120 = isl_22;
        Rigid_0 _S1121 = rigid_of_1(&_S1120);
        thread Island_0 _S1122 = isl_22;
        thread Rigid_0 _S1123 = _S1121;
        record_probes_0(&_S1122, &_S1123, _S1119, &kernelContext_67);
    }
    bool halt_0 = (((&isl_22)->info_0.z) & 2U) != 0U;
    bool _S1124;
    if(halt_0)
    {
        _S1124 = (((&isl_22)->info_0.x) & 4U) != 0U;
    }
    else
    {
        _S1124 = false;
    }
    if(_S1124)
    {
        contact_split_at_0((&isl_22)->info_0.w + 1U, &kernelContext_67);
    }
    float _S1125 = work_5.x;
    thread float _S1126 = (&isl_22)->energy_0.x;
    thread float _S1127 = (&isl_22)->energy_0.y;
    comp_add1_0(&_S1126, &_S1127, _S1125);
    (&isl_22)->energy_0.x = _S1126;
    (&isl_22)->energy_0.y = _S1127 + work_5.y;
    (&isl_22)->done_0.x = (&isl_22)->done_0.x + 1U;
    (&isl_22)->info_0.y = (&isl_22)->info_0.y - 1U;
    (&isl_22)->info_0.w = (&isl_22)->info_0.w + 1U;
    if(halt_0)
    {
        (&isl_22)->info_0.z = (((&isl_22)->info_0.z) & 4294967293U) | 1U;
    }
    Island_natural_0 device* _S1128 = (&kernelContext_67)->islands_0+_S1090.island_0;
    _S1128->range_0 = packed_uint4(isl_22.range_0) ;
    _S1128->info_0 = packed_uint4(isl_22.info_0) ;
    _S1128->com_0 = packed_float4(isl_22.com_0) ;
    _S1128->inertia0_0 = packed_float4(isl_22.inertia0_0) ;
    _S1128->inertia1_0 = packed_float4(isl_22.inertia1_0) ;
    _S1128->inertia2_0 = packed_float4(isl_22.inertia2_0) ;
    _S1128->inv0_0 = packed_float4(isl_22.inv0_0) ;
    _S1128->inv1_0 = packed_float4(isl_22.inv1_0) ;
    _S1128->inv2_0 = packed_float4(isl_22.inv2_0) ;
    _S1128->wcom_0 = packed_float4(isl_22.wcom_0) ;
    _S1128->winv0_0 = packed_float4(isl_22.winv0_0) ;
    _S1128->winv1_0 = packed_float4(isl_22.winv1_0) ;
    _S1128->winv2_0 = packed_float4(isl_22.winv2_0) ;
    _S1128->rotation_0 = packed_float4(isl_22.rotation_0) ;
    _S1128->position_0 = packed_float4(isl_22.position_0) ;
    _S1128->position_err_0 = packed_float4(isl_22.position_err_0) ;
    _S1128->velocity_0 = packed_float4(isl_22.velocity_0) ;
    _S1128->velocity_err_0 = packed_float4(isl_22.velocity_err_0) ;
    _S1128->angular_velocity_0 = packed_float4(isl_22.angular_velocity_0) ;
    _S1128->done_0 = packed_uint4(isl_22.done_0) ;
    _S1128->probes_0 = packed_uint4(isl_22.probes_0) ;
    _S1128->energy_0 = packed_float4(isl_22.energy_0) ;
    _S1128->rotation_err_0 = packed_float4(isl_22.rotation_err_0) ;
    _S1128->momentum_0 = packed_float4(isl_22.momentum_0) ;
    _S1128->momentum_err_0 = packed_float4(isl_22.momentum_err_0) ;
    return;
}

uint sv_0(uint c_29, uint slot_3, KernelContext_0 thread* kernelContext_68)
{
    return kernelContext_68->params_0->statics_base_0 + 23U * c_29 + slot_3;
}

void project_load_slot_0(uint tid_14, const Island_natural_0 thread* isl_23, uint slot_4, KernelContext_0 thread* kernelContext_69)
{
    uint _S1129;
    float3 _S1130 = float3(0.0f) ;
    thread float3 net_f_0 = _S1130;
    thread float3 net_m_0 = _S1130;
    uint4 _S1131 = uint4(isl_23->range_0) ;
    uint _S1132 = _S1131.x + tid_14;
    uint c_30 = _S1132;
    for(;;)
    {
        uint _S1133 = _S1131.y;
        _S1129 = _S1133;
        if(c_30 < _S1133)
        {
        }
        else
        {
            break;
        }
        uint _S1134 = sv_0(c_30, slot_4, kernelContext_69);
        float3 fi_2 = (float4(*(kernelContext_69->scratch_0+_S1134)) ).xyz;
        net_f_0 = net_f_0 + fi_2;
        float3 _S1135 = cross((float4((kernelContext_69->chunks_0+c_30)->center_0) ).xyz - (float4(isl_23->com_0) ).xyz, fi_2);
        uint _S1136 = sv_0(c_30, slot_4 + 1U, kernelContext_69);
        net_m_0 = net_m_0 + (_S1135 + (float4(*(kernelContext_69->scratch_0+_S1136)) ).xyz);
        c_30 = c_30 + 256U;
    }
    group_sum3_0(tid_14, &net_f_0, &net_m_0, kernelContext_69);
    float4 _S1137 = float4(isl_23->com_0) ;
    float3 _S1138 = net_f_0 / float3(_S1137.w) ;
    float3 _S1139 = rows_mul_0(float4(isl_23->inv0_0) , float4(isl_23->inv1_0) , float4(isl_23->inv2_0) , net_m_0);
    c_30 = _S1132;
    for(;;)
    {
        if(c_30 < _S1129)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_natural_0 device* _S1140 = kernelContext_69->chunks_0+c_30;
        float4 _S1141 = float4(_S1140->center_0) ;
        float3 r_12 = _S1141.xyz - _S1137.xyz;
        uint _S1142 = sv_0(c_30, slot_4, kernelContext_69);
        *(kernelContext_69->scratch_0+_S1142) = packed_float4(float4((float4(*(kernelContext_69->scratch_0+_S1142)) ).xyz - (_S1138 + cross(_S1139, r_12)) * float3(_S1141.w) , 0.0f)) ;
        uint _S1143 = sv_0(c_30, slot_4 + 1U, kernelContext_69);
        *(kernelContext_69->scratch_0+_S1143) = packed_float4(float4((float4(*(kernelContext_69->scratch_0+_S1143)) ).xyz - rows_mul_0(float4(_S1140->inertia0_1) , float4(_S1140->inertia1_1) , float4(_S1140->inertia2_1) , _S1139), 0.0f)) ;
        c_30 = c_30 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    return;
}

float island_dot_0(uint tid_15, uint c0_0, uint c1_0, uint sa_2, uint sb_2, KernelContext_0 thread* kernelContext_70)
{
    float4 _S1144 = float4(0.0f) ;
    thread float4 acc_0 = _S1144;
    thread float4 unused_5 = _S1144;
    uint c_31 = c0_0 + tid_15;
    for(;;)
    {
        if(c_31 < c1_0)
        {
        }
        else
        {
            break;
        }
        uint _S1145 = sv_0(c_31, sa_2, kernelContext_70);
        float3 _S1146 = (float4(*(kernelContext_70->scratch_0+_S1145)) ).xyz;
        uint _S1147 = sv_0(c_31, sb_2, kernelContext_70);
        float _S1148 = dot(_S1146, (float4(*(kernelContext_70->scratch_0+_S1147)) ).xyz);
        uint _S1149 = sv_0(c_31, sa_2 + 1U, kernelContext_70);
        float3 _S1150 = (float4(*(kernelContext_70->scratch_0+_S1149)) ).xyz;
        uint _S1151 = sv_0(c_31, sb_2 + 1U, kernelContext_70);
        acc_0.x = acc_0.x + (_S1148 + dot(_S1150, (float4(*(kernelContext_70->scratch_0+_S1151)) ).xyz));
        c_31 = c_31 + 256U;
    }
    group_sum2_0(tid_15, &acc_0, &unused_5, kernelContext_70);
    return acc_0.x;
}

void static_kinematics_0(uint _S1152, float3 thread* _S1153, float3 thread* _S1154, KernelContext_0 thread* kernelContext_71)
{
    BondStatic_natural_0 device* _S1155 = kernelContext_71->bonds_0+_S1152;
    uint4 _S1156 = uint4(_S1155->law_0.ids_0) ;
    uint ca_1 = _S1156.y;
    uint cb_1 = _S1156.z;
    uint _S1157 = 4U * cb_1;
    uint _S1158 = 4U * ca_1;
    float3 _S1159 = (float4(*(kernelContext_71->state_0+_S1157)) ).xyz - (float4(*(kernelContext_71->state_0+_S1158)) ).xyz;
    uint _S1160 = sv_0(cb_1, 21U, kernelContext_71);
    float3 _S1161 = (float4(*(kernelContext_71->scratch_0+_S1160)) ).xyz;
    uint _S1162 = sv_0(ca_1, 21U, kernelContext_71);
    float3 du_0 = _S1159 + (_S1161 - (float4(*(kernelContext_71->scratch_0+_S1162)) ).xyz);
    uint _S1163 = _S1157 + 1U;
    uint _S1164 = _S1158 + 1U;
    float3 _S1165 = (float4(*(kernelContext_71->state_0+_S1163)) ).xyz - (float4(*(kernelContext_71->state_0+_S1164)) ).xyz;
    uint _S1166 = sv_0(cb_1, 22U, kernelContext_71);
    float3 _S1167 = (float4(*(kernelContext_71->scratch_0+_S1166)) ).xyz;
    uint _S1168 = sv_0(ca_1, 22U, kernelContext_71);
    float3 dth_0 = _S1165 + (_S1167 - (float4(*(kernelContext_71->scratch_0+_S1168)) ).xyz);
    float3 _S1169 = to_local_0(_S1152, du_0 + (cross((float4(*(kernelContext_71->state_0+_S1163)) ).xyz + (float4(*(kernelContext_71->scratch_0+_S1166)) ).xyz, (float4(_S1155->rb_0) ).xyz) - cross((float4(*(kernelContext_71->state_0+_S1164)) ).xyz + (float4(*(kernelContext_71->scratch_0+_S1168)) ).xyz, (float4(_S1155->ra_0) ).xyz)), kernelContext_71);
    *_S1153 = _S1169;
    float3 _S1170 = to_local_0(_S1152, dth_0, kernelContext_71);
    *_S1154 = _S1170;
    return;
}

JointResponse_0 static_response_0(uint i_13, KernelContext_0 thread* kernelContext_72)
{
    BondStatic_natural_0 device* _S1171 = kernelContext_72->bonds_0+i_13;
    thread float3 d_lin_4;
    thread float3 d_ang_3;
    static_kinematics_0(i_13, &d_lin_4, &d_ang_3, kernelContext_72);
    thread JointBond_natural_0 _S1172 = _S1171->law_0;
    _S1172 = _S1171->law_0;
    thread JointState_0 _S1173 = (kernelContext_72->bond_dyn_0+i_13)->js_0;
    JointResponse_0 _S1174 = joint_evaluate_0(&kernelContext_72->materials_0->m_0[(uint4((&_S1172)->ids_0) ).x], &_S1172, &_S1173, d_lin_4, d_ang_3, 0.0f, false);
    return _S1174;
}

void gather_loads_0(uint c_32, float3 thread* fi_3, float3 thread* mi_6, KernelContext_0 thread* kernelContext_73)
{
    float3 _S1175 = float3(0.0f) ;
    *fi_3 = _S1175;
    *mi_6 = _S1175;
    uint e_5 = kernelContext_73->index_0[c_32];
    for(;;)
    {
        if(e_5 < (kernelContext_73->index_0)[c_32 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_4 = kernelContext_73->index_0[e_5];
        uint bond_0 = entry_4 >> 1U;
        if((entry_4 & 1U) == 0U)
        {
            uint _S1176 = 3U * bond_0;
            *fi_3 = *fi_3 + (float4(*(kernelContext_73->scratch_0+_S1176)) ).xyz;
            *mi_6 = *mi_6 + (float4(*(kernelContext_73->scratch_0+(_S1176 + 1U))) ).xyz;
        }
        else
        {
            uint _S1177 = 3U * bond_0;
            *fi_3 = *fi_3 - (float4(*(kernelContext_73->scratch_0+_S1177)) ).xyz;
            *mi_6 = *mi_6 + (float4(*(kernelContext_73->scratch_0+(_S1177 + 2U))) ).xyz;
        }
        e_5 = e_5 + 1U;
    }
    return;
}

float bond_load_magnitude2_0(uint c_33, KernelContext_0 thread* kernelContext_74)
{
    uint e_6 = kernelContext_74->index_0[c_33];
    float m_7 = 0.0f;
    for(;;)
    {
        if(e_6 < (kernelContext_74->index_0)[c_33 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_5 = kernelContext_74->index_0[e_6];
        uint _S1178 = 3U * (entry_5 >> 1U);
        float3 f_18 = (float4(*(kernelContext_74->scratch_0+_S1178)) ).xyz;
        float3 t_18;
        if((entry_5 & 1U) == 0U)
        {
            t_18 = (float4(*(kernelContext_74->scratch_0+(_S1178 + 1U))) ).xyz;
        }
        else
        {
            t_18 = (float4(*(kernelContext_74->scratch_0+(_S1178 + 2U))) ).xyz;
        }
        float m_8 = m_7 + (dot(f_18, f_18) + dot(t_18, t_18));
        e_6 = e_6 + 1U;
        m_7 = m_8;
    }
    return m_7;
}

uint fixed_mask_0(uint c_34, KernelContext_0 thread* kernelContext_75)
{
    uint support_2 = (uint4((kernelContext_75->chunks_0+c_34)->info_1) ).x;
    uint _S1179;
    if(support_2 == 1U)
    {
        _S1179 = 63U;
    }
    else
    {
        if(support_2 == 2U)
        {
            _S1179 = 7U;
        }
        else
        {
            _S1179 = 0U;
        }
    }
    return _S1179;
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

uint statics_bond_slot_0(uint i_14, KernelContext_0 thread* kernelContext_76)
{
    return kernelContext_76->params_0->statics_base_0 + 23U * kernelContext_76->params_0->chunk_count_0 + 2U * i_14;
}

void store_inverse_0(uint c_35, const array<float, int(36)> thread* a_14, KernelContext_0 thread* kernelContext_77)
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
        bool _S1180;
        if(i_15 < 6U)
        {
            _S1180 = spd_0;
        }
        else
        {
            _S1180 = false;
        }
        if(_S1180)
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
            uint _S1181 = i_15 * 6U;
            uint _S1182 = _S1181 + j_7;
            k_21 = 0U;
            sum_4 = (*a_14)[_S1182];
            for(;;)
            {
                if(k_21 < j_7)
                {
                }
                else
                {
                    break;
                }
                float sum_5 = sum_4 - l_5[_S1181 + k_21] * l_5[j_7 * 6U + k_21];
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
                l_5[_S1181 + i_15] = sqrt(sum_4);
            }
            else
            {
                l_5[_S1182] = sum_4 / l_5[j_7 * 6U + j_7];
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
            uint _S1183 = k_21 * 6U + k_21;
            float _S1184 = (*a_14)[_S1183];
            if(((*a_14)[_S1183]) > 0.0f)
            {
                sum_4 = 1.0f / _S1184;
            }
            else
            {
                sum_4 = 0.0f;
            }
            inv_0[_S1183] = sum_4;
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
        uint _S1185 = sv_0(c_35, 12U + j_7, kernelContext_77);
        uint _S1186 = 4U * j_7;
        *(kernelContext_77->scratch_0+_S1185) = packed_float4(float4(inv_0[_S1186], inv_0[_S1186 + 1U], inv_0[_S1186 + 2U], inv_0[_S1186 + 3U])) ;
        j_7 = j_7 + 1U;
    }
    return;
}

void assemble_block_0(uint c_36, KernelContext_0 thread* kernelContext_78)
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
    uint e_7 = kernelContext_78->index_0[c_36];
    for(;;)
    {
        if(e_7 < (kernelContext_78->index_0)[c_36 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_6 = kernelContext_78->index_0[e_7];
        uint i_18 = entry_6 >> 1U;
        bool _S1187 = (entry_6 & 1U) != 0U;
        BondStatic_natural_0 device* _S1188 = kernelContext_78->bonds_0+i_18;
        uint _S1189 = statics_bond_slot_0(i_18, kernelContext_78);
        float4 _S1190 = float4(*(kernelContext_78->scratch_0+_S1189)) ;
        float4 _S1191 = float4(*(kernelContext_78->scratch_0+(_S1189 + 1U))) ;
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
            uint _S1192 = p_16 % 3U;
            float3 t_19;
            if(_S1192 == 0U)
            {
                t_19 = (float4(_S1188->t1_0) ).xyz;
            }
            else
            {
                if(_S1192 == 1U)
                {
                    t_19 = (float4(_S1188->t2_0) ).xyz;
                }
                else
                {
                    t_19 = (float4(_S1188->normal_0) ).xyz;
                }
            }
            bool _S1193 = p_16 < 3U;
            float3 row_u_0;
            float3 row_t_0;
            if(_S1193)
            {
                if(_S1187)
                {
                    row_u_0 = t_19;
                }
                else
                {
                    row_u_0 = - t_19;
                }
                if(_S1187)
                {
                    row_t_0 = cross((float4(_S1188->rb_0) ).xyz, t_19);
                }
                else
                {
                    row_t_0 = - cross((float4(_S1188->ra_0) ).xyz, t_19);
                }
            }
            else
            {
                float3 _S1194 = float3(0.0f) ;
                if(_S1187)
                {
                    row_u_0 = t_19;
                }
                else
                {
                    row_u_0 = - t_19;
                }
                float3 _S1195 = row_u_0;
                row_u_0 = _S1194;
                row_t_0 = _S1195;
            }
            float kp_0;
            if(_S1193)
            {
                kp_0 = _S1190[p_16];
            }
            else
            {
                kp_0 = _S1191[p_16 - 3U];
            }
            if(kp_0 == 0.0f)
            {
                p_16 = p_16 + 1U;
                continue;
            }
            array<float, int(6)> _S1196 = { { row_u_0.x, row_u_0.y, row_u_0.z, row_t_0.x, row_t_0.y, row_t_0.z } };
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
                    a_15[r_13 * 6U + q_15] = a_15[r_13 * 6U + q_15] + kp_0 * _S1196[r_13] * _S1196[q_15];
                    q_15 = q_15 + 1U;
                }
                r_13 = r_13 + 1U;
            }
            p_16 = p_16 + 1U;
        }
        e_7 = e_7 + 1U;
    }
    uint _S1197 = fixed_mask_0(c_36, kernelContext_78);
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
        if((_S1197 & (1U << p_16)) != 0U)
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
    thread array<float, int(36)> _S1198 = a_15;
    store_inverse_0(c_36, &_S1198, kernelContext_78);
    return;
}

float block_get_0(uint c_37, uint i_19, uint j_8, KernelContext_0 thread* kernelContext_79)
{
    uint k_23 = i_19 * 6U + j_8;
    uint _S1199 = sv_0(c_37, 12U + k_23 / 4U, kernelContext_79);
    return (*(kernelContext_79->scratch_0+_S1199))[k_23 % 4U];
}

void precondition_0(uint c_38, KernelContext_0 thread* kernelContext_80)
{
    uint _S1200 = sv_0(c_38, 4U, kernelContext_80);
    float4 _S1201 = float4(*(kernelContext_80->scratch_0+_S1200)) ;
    uint _S1202 = sv_0(c_38, 5U, kernelContext_80);
    float4 _S1203 = float4(*(kernelContext_80->scratch_0+_S1202)) ;
    array<float, int(6)> _S1204 = { { _S1201.x, _S1201.y, _S1201.z, _S1203.x, _S1203.y, _S1203.z } };
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
            float _S1205 = block_get_0(c_38, i_20, j_9, kernelContext_80);
            float s_13 = s_12 + _S1205 * _S1204[j_9];
            j_9 = j_9 + 1U;
            s_12 = s_13;
        }
        z_1[i_20] = s_12;
        i_20 = i_20 + 1U;
    }
    uint _S1206 = sv_0(c_38, 6U, kernelContext_80);
    *(kernelContext_80->scratch_0+_S1206) = packed_float4(float4(z_1[int(0)], z_1[int(1)], z_1[int(2)], 0.0f)) ;
    uint _S1207 = sv_0(c_38, 7U, kernelContext_80);
    *(kernelContext_80->scratch_0+_S1207) = packed_float4(float4(z_1[int(3)], z_1[int(4)], z_1[int(5)], 0.0f)) ;
    return;
}

void project_displacement_slot_0(uint tid_16, const Island_natural_0 thread* isl_24, uint slot_5, KernelContext_0 thread* kernelContext_81)
{
    uint _S1208;
    float3 _S1209 = float3(0.0f) ;
    thread float3 p_17 = _S1209;
    thread float3 l_6 = _S1209;
    uint4 _S1210 = uint4(isl_24->range_0) ;
    uint _S1211 = _S1210.x + tid_16;
    uint c_39 = _S1211;
    for(;;)
    {
        uint _S1212 = _S1210.y;
        _S1208 = _S1212;
        if(c_39 < _S1212)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_natural_0 device* _S1213 = kernelContext_81->chunks_0+c_39;
        uint _S1214 = sv_0(c_39, slot_5, kernelContext_81);
        float3 u_6 = (float4(*(kernelContext_81->scratch_0+_S1214)) ).xyz;
        uint _S1215 = sv_0(c_39, slot_5 + 1U, kernelContext_81);
        float3 th_7 = (float4(*(kernelContext_81->scratch_0+_S1215)) ).xyz;
        float4 _S1216 = float4(_S1213->center_0) ;
        float3 r_14 = _S1216.xyz - (float4(isl_24->com_0) ).xyz;
        float3 _S1217 = float3(_S1216.w) ;
        p_17 = p_17 + u_6 * _S1217;
        l_6 = l_6 + (cross(r_14, u_6) * _S1217 + rows_mul_0(float4(_S1213->inertia0_1) , float4(_S1213->inertia1_1) , float4(_S1213->inertia2_1) , th_7));
        c_39 = c_39 + 256U;
    }
    group_sum3_0(tid_16, &p_17, &l_6, kernelContext_81);
    float4 _S1218 = float4(isl_24->com_0) ;
    float3 _S1219 = p_17 / float3(_S1218.w) ;
    float3 _S1220 = rows_mul_0(float4(isl_24->inv0_0) , float4(isl_24->inv1_0) , float4(isl_24->inv2_0) , l_6);
    c_39 = _S1211;
    for(;;)
    {
        if(c_39 < _S1208)
        {
        }
        else
        {
            break;
        }
        float3 r_15 = (float4((kernelContext_81->chunks_0+c_39)->center_0) ).xyz - _S1218.xyz;
        uint _S1221 = sv_0(c_39, slot_5, kernelContext_81);
        *(kernelContext_81->scratch_0+_S1221) = packed_float4(float4((float4(*(kernelContext_81->scratch_0+_S1221)) ).xyz - _S1219 - cross(_S1220, r_15), 0.0f)) ;
        uint _S1222 = sv_0(c_39, slot_5 + 1U, kernelContext_81);
        *(kernelContext_81->scratch_0+_S1222) = packed_float4(float4((float4(*(kernelContext_81->scratch_0+_S1222)) ).xyz - _S1220, 0.0f)) ;
        c_39 = c_39 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    return;
}

uint statics_result_slot_0(uint island_1, KernelContext_0 thread* kernelContext_82)
{
    return kernelContext_82->params_0->statics_base_0 + 23U * kernelContext_82->params_0->chunk_count_0 + 2U * kernelContext_82->params_0->statics_bonds_0 + island_1;
}

void write_bond_loads_0(uint _S1223, uint _S1224, float3 _S1225, float3 _S1226, float _S1227, KernelContext_0 thread* kernelContext_83)
{
    BondStatic_natural_0 device* _S1228 = kernelContext_83->bonds_0+_S1224;
    float3 _S1229 = to_body_0(_S1224, _S1225, kernelContext_83);
    float3 _S1230 = to_body_0(_S1224, _S1226, kernelContext_83);
    uint _S1231 = 3U * _S1223;
    *(kernelContext_83->scratch_0+_S1231) = packed_float4(float4(_S1229, _S1227)) ;
    *(kernelContext_83->scratch_0+(_S1231 + 1U)) = packed_float4(float4(_S1230 + cross((float4(_S1228->ra_0) ).xyz, _S1229), 0.0f)) ;
    *(kernelContext_83->scratch_0+(_S1231 + 2U)) = packed_float4(float4(- _S1230 + cross((float4(_S1228->rb_0) ).xyz, - _S1229), 0.0f)) ;
    return;
}

void bond_kinematics_0(uint _S1232, float3 _S1233, float3 _S1234, float3 _S1235, float3 _S1236, float3 thread* _S1237, float3 thread* _S1238, KernelContext_0 thread* kernelContext_84)
{
    BondStatic_natural_0 device* _S1239 = kernelContext_84->bonds_0+_S1232;
    float3 _S1240 = to_local_0(_S1232, _S1235 + cross(_S1236, (float4(_S1239->rb_0) ).xyz) - (_S1233 + cross(_S1234, (float4(_S1239->ra_0) ).xyz)), kernelContext_84);
    *_S1237 = _S1240;
    float3 _S1241 = to_local_0(_S1232, _S1236 - _S1234, kernelContext_84);
    *_S1238 = _S1241;
    return;
}

[[kernel]] void island_statics(uint3 group_9 [[threadgroup_position_in_grid]], uint3 thread_9 [[thread_position_in_threadgroup]], Params_0 constant* params_13 [[buffer(0)]], Island_natural_0 device* islands_13 [[buffer(9)]], uint device* index_13 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_13 [[buffer(3)]], packed_float4 device* state_15 [[buffer(6)]], packed_float4 device* scratch_13 [[buffer(8)]], packed_float4 device* contact_state_13 [[buffer(11)]], packed_float4 device* loads_13 [[buffer(5)]], Impactor_natural_0 device* impactors_13 [[buffer(10)]], BondStatic_natural_0 device* bonds_13 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_13 [[buffer(7)]], MaterialTable_0 constant* materials_13 [[buffer(1)]])
{
    uint i_21;
    bool converged_0;
    uint c_40;
    thread KernelContext_0 kernelContext_85;
    (&kernelContext_85)->params_0 = params_13;
    (&kernelContext_85)->islands_0 = islands_13;
    (&kernelContext_85)->index_0 = index_13;
    (&kernelContext_85)->chunks_0 = chunks_13;
    (&kernelContext_85)->state_0 = state_15;
    (&kernelContext_85)->scratch_0 = scratch_13;
    (&kernelContext_85)->contact_state_0 = contact_state_13;
    (&kernelContext_85)->loads_0 = loads_13;
    (&kernelContext_85)->impactors_0 = impactors_13;
    (&kernelContext_85)->bonds_0 = bonds_13;
    (&kernelContext_85)->bond_dyn_0 = bond_dyn_13;
    (&kernelContext_85)->materials_0 = materials_13;
    threadgroup array<float4, int(32)> g_part_a_13;
    (&kernelContext_85)->g_part_a_0 = &g_part_a_13;
    threadgroup array<float4, int(32)> g_part_b_13;
    (&kernelContext_85)->g_part_b_0 = &g_part_b_13;
    threadgroup uint g_run_13;
    (&kernelContext_85)->g_run_0 = &g_run_13;
    threadgroup uint g_halt_13;
    (&kernelContext_85)->g_halt_0 = &g_halt_13;
    threadgroup uint g_wide_run_13;
    (&kernelContext_85)->g_wide_run_0 = &g_wide_run_13;
    uint tid_17 = thread_9.x;
    uint _S1242 = group_9.x;
    thread Island_natural_0 _S1243 = *(islands_13+_S1242);
    uint4 _S1244 = uint4((&_S1243)->info_0) ;
    uint _S1245 = _S1244.z;
    if((_S1245 & 8U) == 0U)
    {
        return;
    }
    bool free_0 = ((_S1244.x) & 1U) == 0U;
    uint4 _S1246 = uint4((&_S1243)->range_0) ;
    uint c0_1 = _S1246.x;
    uint c1_1 = _S1246.y;
    uint b0_0 = _S1246.z;
    uint _S1247 = _S1246.w;
    uint _S1248 = c0_1 + tid_17;
    uint c_41 = _S1248;
    for(;;)
    {
        if(c_41 < c1_1)
        {
        }
        else
        {
            break;
        }
        uint _S1249 = sv_0(c_41, 21U, &kernelContext_85);
        packed_float4 _S1250 = packed_float4(float4(0.0f) ) ;
        *((&kernelContext_85)->scratch_0+_S1249) = _S1250;
        uint _S1251 = sv_0(c_41, 22U, &kernelContext_85);
        *((&kernelContext_85)->scratch_0+_S1251) = _S1250;
        c_41 = c_41 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    if(free_0)
    {
        project_load_slot_0(tid_17, &_S1243, 0U, &kernelContext_85);
    }
    float _S1252 = island_dot_0(tid_17, c0_1, c1_1, 0U, 0U, &kernelContext_85);
    float _S1253 = max(sqrt(_S1252), 1.00000000317107685e-30f);
    float _S1254 = (&kernelContext_85)->params_0->statics_tol_0;
    uint _S1255 = min((&kernelContext_85)->params_0->statics_cg_0, 20U * (c1_1 - c0_1) * 6U + 200U);
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
        uint _S1256 = b0_0 + tid_17;
        i_21 = _S1256;
        for(;;)
        {
            if(i_21 < _S1247)
            {
            }
            else
            {
                break;
            }
            JointResponse_0 _S1257 = static_response_0(i_21, &kernelContext_85);
            write_bond_loads_0(i_21, i_21, _S1257.force_lin_1, _S1257.force_ang_1, 0.0f, &kernelContext_85);
            i_21 = i_21 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        float4 _S1258 = float4(0.0f) ;
        thread float4 magnitude_0 = _S1258;
        thread float4 unused_m_0 = _S1258;
        c_41 = _S1248;
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
            gather_loads_0(c_41, &fi_4, &mi_7, &kernelContext_85);
            float _S1259 = bond_load_magnitude2_0(c_41, &kernelContext_85);
            magnitude_0.x = magnitude_0.x + _S1259;
            uint _S1260 = sv_0(c_41, 0U, &kernelContext_85);
            thread float4 r_lin_0 = float4((float4(*((&kernelContext_85)->scratch_0+_S1260)) ).xyz + fi_4, 0.0f);
            uint _S1261 = sv_0(c_41, 1U, &kernelContext_85);
            thread float4 r_ang_0 = float4((float4(*((&kernelContext_85)->scratch_0+_S1261)) ).xyz + mi_7, 0.0f);
            uint _S1262 = fixed_mask_0(c_41, &kernelContext_85);
            hold_0(_S1262, &r_lin_0, &r_ang_0, _S1258, _S1258);
            uint _S1263 = sv_0(c_41, 4U, &kernelContext_85);
            *((&kernelContext_85)->scratch_0+_S1263) = packed_float4(r_lin_0) ;
            uint _S1264 = sv_0(c_41, 5U, &kernelContext_85);
            *((&kernelContext_85)->scratch_0+_S1264) = packed_float4(r_ang_0) ;
            c_41 = c_41 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        group_sum2_0(tid_17, &magnitude_0, &unused_m_0, &kernelContext_85);
        if(free_0)
        {
            project_load_slot_0(tid_17, &_S1243, 4U, &kernelContext_85);
        }
        float _S1265 = island_dot_0(tid_17, c0_1, c1_1, 4U, 4U, &kernelContext_85);
        float residual_1 = sqrt(_S1265) / _S1253;
        float _S1266 = max(0.00100000004749745f, 3.83999986297567375e-06f * sqrt(magnitude_0.x) / _S1253);
        if(residual_1 <= _S1254)
        {
            converged_0 = true;
        }
        else
        {
            if(residual_1 <= _S1266)
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
        uint i_22 = _S1256;
        for(;;)
        {
            if(i_22 < _S1247)
            {
            }
            else
            {
                break;
            }
            BondStatic_natural_0 device* _S1267 = (&kernelContext_85)->bonds_0+i_22;
            thread float3 d_lin_5;
            thread float3 d_ang_4;
            static_kinematics_0(i_22, &d_lin_5, &d_ang_4, &kernelContext_85);
            thread JointBond_natural_0 _S1268 = _S1267->law_0;
            thread JointState_0 _S1269 = ((&kernelContext_85)->bond_dyn_0+i_22)->js_0;
            thread float3 f_lin_2;
            thread float3 f_ang_2;
            secant_factors_0(&_S1268, &_S1269, d_lin_5, &f_lin_2, &f_ang_2);
            float4 _S1270 = float4((&_S1268)->stiff0_0) ;
            uint _S1271 = statics_bond_slot_0(i_22, &kernelContext_85);
            float _S1272 = _S1270.y;
            *((&kernelContext_85)->scratch_0+_S1271) = packed_float4(float4(_S1272 * f_lin_2.x, _S1272 * f_lin_2.y, _S1270.x * f_lin_2.z, 0.0f)) ;
            *((&kernelContext_85)->scratch_0+(_S1271 + 1U)) = packed_float4(float4(_S1270.z * f_ang_2.x, _S1270.w * f_ang_2.y, (float4((&_S1268)->stiff1_0) ).x * f_ang_2.z, 0.0f)) ;
            i_22 = i_22 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_42 = _S1248;
        for(;;)
        {
            if(c_42 < c1_1)
            {
            }
            else
            {
                break;
            }
            assemble_block_0(c_42, &kernelContext_85);
            uint _S1273 = sv_0(c_42, 2U, &kernelContext_85);
            packed_float4 _S1274 = packed_float4(_S1258) ;
            *((&kernelContext_85)->scratch_0+_S1273) = _S1274;
            uint _S1275 = sv_0(c_42, 3U, &kernelContext_85);
            *((&kernelContext_85)->scratch_0+_S1275) = _S1274;
            c_42 = c_42 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_43 = _S1248;
        for(;;)
        {
            if(c_43 < c1_1)
            {
            }
            else
            {
                break;
            }
            precondition_0(c_43, &kernelContext_85);
            c_43 = c_43 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        if(free_0)
        {
            project_displacement_slot_0(tid_17, &_S1243, 6U, &kernelContext_85);
        }
        uint c_44 = _S1248;
        for(;;)
        {
            if(c_44 < c1_1)
            {
            }
            else
            {
                break;
            }
            uint _S1276 = sv_0(c_44, 8U, &kernelContext_85);
            packed_float4 device* _S1277 = (&kernelContext_85)->scratch_0+_S1276;
            uint _S1278 = sv_0(c_44, 6U, &kernelContext_85);
            *_S1277 = packed_float4(float4(*((&kernelContext_85)->scratch_0+_S1278)) ) ;
            uint _S1279 = sv_0(c_44, 9U, &kernelContext_85);
            packed_float4 device* _S1280 = (&kernelContext_85)->scratch_0+_S1279;
            uint _S1281 = sv_0(c_44, 7U, &kernelContext_85);
            *_S1280 = packed_float4(float4(*((&kernelContext_85)->scratch_0+_S1281)) ) ;
            c_44 = c_44 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        float _S1282 = island_dot_0(tid_17, c0_1, c1_1, 4U, 6U, &kernelContext_85);
        float _S1283 = island_dot_0(tid_17, c0_1, c1_1, 4U, 4U, &kernelContext_85);
        float _S1284 = sqrt(_S1283);
        float rz_0 = _S1282;
        uint k_24 = 0U;
        uint cg_total_1 = cg_total_0;
        for(;;)
        {
            bool _S1285;
            if(k_24 < _S1255)
            {
                _S1285 = _S1284 > 0.0f;
            }
            else
            {
                _S1285 = false;
            }
            if(_S1285)
            {
            }
            else
            {
                cg_total_0 = cg_total_1;
                break;
            }
            uint i_23 = _S1256;
            for(;;)
            {
                if(i_23 < _S1247)
                {
                }
                else
                {
                    break;
                }
                uint4 _S1286 = uint4(((&kernelContext_85)->bonds_0+i_23)->law_0.ids_0) ;
                uint ca_2 = _S1286.y;
                uint cb_2 = _S1286.z;
                uint _S1287 = sv_0(ca_2, 8U, &kernelContext_85);
                float3 _S1288 = (float4(*((&kernelContext_85)->scratch_0+_S1287)) ).xyz;
                uint _S1289 = sv_0(ca_2, 9U, &kernelContext_85);
                float3 _S1290 = (float4(*((&kernelContext_85)->scratch_0+_S1289)) ).xyz;
                uint _S1291 = sv_0(cb_2, 8U, &kernelContext_85);
                float3 _S1292 = (float4(*((&kernelContext_85)->scratch_0+_S1291)) ).xyz;
                uint _S1293 = sv_0(cb_2, 9U, &kernelContext_85);
                thread float3 d_lin_6;
                thread float3 d_ang_5;
                bond_kinematics_0(i_23, _S1288, _S1290, _S1292, (float4(*((&kernelContext_85)->scratch_0+_S1293)) ).xyz, &d_lin_6, &d_ang_5, &kernelContext_85);
                uint _S1294 = statics_bond_slot_0(i_23, &kernelContext_85);
                write_bond_loads_0(i_23, i_23, d_lin_6 * (float4(*((&kernelContext_85)->scratch_0+_S1294)) ).xyz, d_ang_5 * (float4(*((&kernelContext_85)->scratch_0+(_S1294 + 1U))) ).xyz, 0.0f, &kernelContext_85);
                i_23 = i_23 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            c_40 = _S1248;
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
                gather_loads_0(c_40, &fi_5, &mi_8, &kernelContext_85);
                thread float4 ap_lin_0 = float4(- fi_5, 0.0f);
                thread float4 ap_ang_0 = float4(- mi_8, 0.0f);
                uint _S1295 = fixed_mask_0(c_40, &kernelContext_85);
                uint _S1296 = sv_0(c_40, 8U, &kernelContext_85);
                float4 _S1297 = float4(*((&kernelContext_85)->scratch_0+_S1296)) ;
                uint _S1298 = sv_0(c_40, 9U, &kernelContext_85);
                hold_0(_S1295, &ap_lin_0, &ap_ang_0, _S1297, float4(*((&kernelContext_85)->scratch_0+_S1298)) );
                uint _S1299 = sv_0(c_40, 10U, &kernelContext_85);
                *((&kernelContext_85)->scratch_0+_S1299) = packed_float4(ap_lin_0) ;
                uint _S1300 = sv_0(c_40, 11U, &kernelContext_85);
                *((&kernelContext_85)->scratch_0+_S1300) = packed_float4(ap_ang_0) ;
                c_40 = c_40 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            float _S1301 = island_dot_0(tid_17, c0_1, c1_1, 8U, 10U, &kernelContext_85);
            uint _S1302 = cg_total_1 + 1U;
            if(_S1301 <= 0.0f)
            {
                cg_total_0 = _S1302;
                break;
            }
            float _S1303 = rz_0 / _S1301;
            uint c_45 = _S1248;
            for(;;)
            {
                if(c_45 < c1_1)
                {
                }
                else
                {
                    break;
                }
                uint _S1304 = sv_0(c_45, 2U, &kernelContext_85);
                packed_float4 device* _S1305 = (&kernelContext_85)->scratch_0+_S1304;
                float3 _S1306 = (float4(*((&kernelContext_85)->scratch_0+_S1304)) ).xyz;
                uint _S1307 = sv_0(c_45, 8U, &kernelContext_85);
                float3 _S1308 = float3(_S1303) ;
                *_S1305 = packed_float4(float4(_S1306 + _S1308 * (float4(*((&kernelContext_85)->scratch_0+_S1307)) ).xyz, 0.0f)) ;
                uint _S1309 = sv_0(c_45, 3U, &kernelContext_85);
                packed_float4 device* _S1310 = (&kernelContext_85)->scratch_0+_S1309;
                float3 _S1311 = (float4(*((&kernelContext_85)->scratch_0+_S1309)) ).xyz;
                uint _S1312 = sv_0(c_45, 9U, &kernelContext_85);
                *_S1310 = packed_float4(float4(_S1311 + _S1308 * (float4(*((&kernelContext_85)->scratch_0+_S1312)) ).xyz, 0.0f)) ;
                uint _S1313 = sv_0(c_45, 4U, &kernelContext_85);
                packed_float4 device* _S1314 = (&kernelContext_85)->scratch_0+_S1313;
                float3 _S1315 = (float4(*((&kernelContext_85)->scratch_0+_S1313)) ).xyz;
                uint _S1316 = sv_0(c_45, 10U, &kernelContext_85);
                *_S1314 = packed_float4(float4(_S1315 - _S1308 * (float4(*((&kernelContext_85)->scratch_0+_S1316)) ).xyz, 0.0f)) ;
                uint _S1317 = sv_0(c_45, 5U, &kernelContext_85);
                packed_float4 device* _S1318 = (&kernelContext_85)->scratch_0+_S1317;
                float3 _S1319 = (float4(*((&kernelContext_85)->scratch_0+_S1317)) ).xyz;
                uint _S1320 = sv_0(c_45, 11U, &kernelContext_85);
                *_S1318 = packed_float4(float4(_S1319 - _S1308 * (float4(*((&kernelContext_85)->scratch_0+_S1320)) ).xyz, 0.0f)) ;
                c_45 = c_45 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            float _S1321 = island_dot_0(tid_17, c0_1, c1_1, 4U, 4U, &kernelContext_85);
            if((sqrt(_S1321)) <= (0.00009999999747379f * _S1284))
            {
                cg_total_0 = _S1302;
                break;
            }
            uint c_46 = _S1248;
            for(;;)
            {
                if(c_46 < c1_1)
                {
                }
                else
                {
                    break;
                }
                precondition_0(c_46, &kernelContext_85);
                c_46 = c_46 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            if(free_0)
            {
                project_displacement_slot_0(tid_17, &_S1243, 6U, &kernelContext_85);
            }
            float _S1322 = island_dot_0(tid_17, c0_1, c1_1, 4U, 6U, &kernelContext_85);
            float _S1323 = _S1322 / rz_0;
            uint c_47 = _S1248;
            for(;;)
            {
                if(c_47 < c1_1)
                {
                }
                else
                {
                    break;
                }
                uint _S1324 = sv_0(c_47, 8U, &kernelContext_85);
                packed_float4 device* _S1325 = (&kernelContext_85)->scratch_0+_S1324;
                uint _S1326 = sv_0(c_47, 6U, &kernelContext_85);
                float3 _S1327 = float3(_S1323) ;
                *_S1325 = packed_float4(float4((float4(*((&kernelContext_85)->scratch_0+_S1326)) ).xyz + _S1327 * (float4(*((&kernelContext_85)->scratch_0+_S1324)) ).xyz, 0.0f)) ;
                uint _S1328 = sv_0(c_47, 9U, &kernelContext_85);
                packed_float4 device* _S1329 = (&kernelContext_85)->scratch_0+_S1328;
                uint _S1330 = sv_0(c_47, 7U, &kernelContext_85);
                *_S1329 = packed_float4(float4((float4(*((&kernelContext_85)->scratch_0+_S1330)) ).xyz + _S1327 * (float4(*((&kernelContext_85)->scratch_0+_S1328)) ).xyz, 0.0f)) ;
                c_47 = c_47 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            uint _S1331 = k_24 + 1U;
            rz_0 = _S1322;
            k_24 = _S1331;
            cg_total_1 = _S1302;
        }
        c_40 = _S1248;
        for(;;)
        {
            if(c_40 < c1_1)
            {
            }
            else
            {
                break;
            }
            uint _S1332 = 4U * c_40;
            thread float3 u_7 = (float4(*((&kernelContext_85)->state_0+_S1332)) ).xyz;
            uint _S1333 = sv_0(c_40, 21U, &kernelContext_85);
            thread float3 u_lo_0 = (float4(*((&kernelContext_85)->scratch_0+_S1333)) ).xyz;
            uint _S1334 = _S1332 + 1U;
            thread float3 th_8 = (float4(*((&kernelContext_85)->state_0+_S1334)) ).xyz;
            uint _S1335 = sv_0(c_40, 22U, &kernelContext_85);
            thread float3 th_lo_0 = (float4(*((&kernelContext_85)->scratch_0+_S1335)) ).xyz;
            uint _S1336 = sv_0(c_40, 2U, &kernelContext_85);
            comp_add_0(&u_7, &u_lo_0, (float4(*((&kernelContext_85)->scratch_0+_S1336)) ).xyz);
            uint _S1337 = sv_0(c_40, 3U, &kernelContext_85);
            comp_add_0(&th_8, &th_lo_0, (float4(*((&kernelContext_85)->scratch_0+_S1337)) ).xyz);
            *((&kernelContext_85)->state_0+_S1332) = packed_float4(float4(u_7, (float4(*((&kernelContext_85)->state_0+_S1332)) ).w)) ;
            *((&kernelContext_85)->state_0+_S1334) = packed_float4(float4(th_8, (float4(*((&kernelContext_85)->state_0+_S1334)) ).w)) ;
            *((&kernelContext_85)->scratch_0+_S1333) = packed_float4(float4(u_lo_0, 0.0f)) ;
            *((&kernelContext_85)->scratch_0+_S1335) = packed_float4(float4(th_lo_0, 0.0f)) ;
            c_40 = c_40 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint _S1338 = newton_0 + 1U;
        previous_2 = residual_1;
        residual_0 = residual_1;
        newton_0 = _S1338;
    }
    i_21 = b0_0 + tid_17;
    for(;;)
    {
        if(i_21 < _S1247)
        {
        }
        else
        {
            break;
        }
        JointResponse_0 _S1339 = static_response_0(i_21, &kernelContext_85);
        BondDyn_natural_0 device* _S1340 = (&kernelContext_85)->bond_dyn_0+i_21;
        float4 _S1341 = float4((*_S1340).force_lin_0) ;
        float4 _S1342 = float4((*_S1340).force_ang_0) ;
        float4 _S1343 = float4((*_S1340).sums_0) ;
        float4 _S1344 = float4((*_S1340).comps_0) ;
        uint4 _S1345 = uint4((*_S1340).events_0) ;
        thread BondDyn_0 bd_1;
        (&bd_1)->js_0 = (*_S1340).js_0;
        (&bd_1)->force_lin_0 = _S1341;
        (&bd_1)->force_ang_0 = _S1342;
        (&bd_1)->sums_0 = _S1343;
        (&bd_1)->comps_0 = _S1344;
        (&bd_1)->events_0 = _S1345;
        (&bd_1)->force_lin_0 = float4(_S1339.force_lin_1, _S1339.stored_5);
        (&bd_1)->force_ang_0 = float4(_S1339.force_ang_1, (&bd_1)->force_ang_0.w);
        BondDyn_natural_0 device* _S1346 = (&kernelContext_85)->bond_dyn_0+i_21;
        _S1346->js_0 = bd_1.js_0;
        _S1346->force_lin_0 = packed_float4(bd_1.force_lin_0) ;
        _S1346->force_ang_0 = packed_float4(bd_1.force_ang_0) ;
        _S1346->sums_0 = packed_float4(bd_1.sums_0) ;
        _S1346->comps_0 = packed_float4(bd_1.comps_0) ;
        _S1346->events_0 = packed_uint4(bd_1.events_0) ;
        write_bond_loads_0(i_21, i_21, _S1339.force_lin_1, _S1339.force_ang_1, max(_S1339.measures_0.tension_0, _S1339.measures_0.compression_0), &kernelContext_85);
        i_21 = i_21 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    c_41 = _S1248;
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
        gather_loads_0(c_41, &fi_6, &mi_9, &kernelContext_85);
        uint _S1347 = fixed_mask_0(c_41, &kernelContext_85);
        float3 reaction_2;
        if(_S1347 != 0U)
        {
            uint _S1348 = sv_0(c_41, 0U, &kernelContext_85);
            reaction_2 = - ((float4(*((&kernelContext_85)->scratch_0+_S1348)) ).xyz + fi_6);
        }
        else
        {
            uint _S1349 = 4U * c_41;
            reaction_2 = float3((float4(*((&kernelContext_85)->state_0+(_S1349 + 1U))) ).w, (float4(*((&kernelContext_85)->state_0+(_S1349 + 2U))) ).w, (float4(*((&kernelContext_85)->state_0+(_S1349 + 3U))) ).w);
        }
        uint _S1350 = 4U * c_41;
        uint _S1351 = _S1350 + 1U;
        *((&kernelContext_85)->state_0+_S1351) = packed_float4(float4((float4(*((&kernelContext_85)->state_0+_S1351)) ).xyz, reaction_2.x)) ;
        *((&kernelContext_85)->state_0+(_S1350 + 2U)) = packed_float4(float4(0.0f, 0.0f, 0.0f, reaction_2.y)) ;
        *((&kernelContext_85)->state_0+(_S1350 + 3U)) = packed_float4(float4(0.0f, 0.0f, 0.0f, reaction_2.z)) ;
        c_41 = c_41 + 256U;
    }
    if(tid_17 == 0U)
    {
        uint _S1352 = statics_result_slot_0(_S1242, &kernelContext_85);
        packed_float4 device* _S1353 = (&kernelContext_85)->scratch_0+_S1352;
        float _S1354 = (as_type<float>((newton_0)));
        float _S1355 = (as_type<float>((cg_total_0)));
        if(converged_0)
        {
            previous_2 = 1.0f;
        }
        else
        {
            previous_2 = 0.0f;
        }
        *_S1353 = packed_float4(float4(residual_0, _S1354, _S1355, previous_2)) ;
        ((&kernelContext_85)->islands_0+_S1242)->info_0[int(2)] = _S1245 & 4294967287U;
    }
    return;
}

[[kernel]] void settled_fatigue(uint3 group_10 [[threadgroup_position_in_grid]], uint3 thread_10 [[thread_position_in_threadgroup]], Params_0 constant* params_14 [[buffer(0)]], Island_natural_0 device* islands_14 [[buffer(9)]], uint device* index_14 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_14 [[buffer(3)]], packed_float4 device* state_16 [[buffer(6)]], packed_float4 device* scratch_14 [[buffer(8)]], packed_float4 device* contact_state_14 [[buffer(11)]], packed_float4 device* loads_14 [[buffer(5)]], Impactor_natural_0 device* impactors_14 [[buffer(10)]], BondStatic_natural_0 device* bonds_14 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_14 [[buffer(7)]], MaterialTable_0 constant* materials_14 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_86;
    (&kernelContext_86)->params_0 = params_14;
    (&kernelContext_86)->islands_0 = islands_14;
    (&kernelContext_86)->index_0 = index_14;
    (&kernelContext_86)->chunks_0 = chunks_14;
    (&kernelContext_86)->state_0 = state_16;
    (&kernelContext_86)->scratch_0 = scratch_14;
    (&kernelContext_86)->contact_state_0 = contact_state_14;
    (&kernelContext_86)->loads_0 = loads_14;
    (&kernelContext_86)->impactors_0 = impactors_14;
    (&kernelContext_86)->bonds_0 = bonds_14;
    (&kernelContext_86)->bond_dyn_0 = bond_dyn_14;
    (&kernelContext_86)->materials_0 = materials_14;
    threadgroup array<float4, int(32)> g_part_a_14;
    (&kernelContext_86)->g_part_a_0 = &g_part_a_14;
    threadgroup array<float4, int(32)> g_part_b_14;
    (&kernelContext_86)->g_part_b_0 = &g_part_b_14;
    threadgroup uint g_run_14;
    (&kernelContext_86)->g_run_0 = &g_run_14;
    threadgroup uint g_halt_14;
    (&kernelContext_86)->g_halt_0 = &g_halt_14;
    threadgroup uint g_wide_run_14;
    (&kernelContext_86)->g_wide_run_0 = &g_wide_run_14;
    uint tid_18 = thread_10.x;
    uint _S1356 = group_10.x;
    Island_natural_0 device* _S1357 = islands_14+_S1356;
    Island_natural_0 isl_25 = *_S1357;
    uint4 _S1358 = uint4((*_S1357).info_0) ;
    bool _S1359;
    if(((_S1358.x) & 16U) == 0U)
    {
        _S1359 = true;
    }
    else
    {
        uint4 _S1360 = uint4(isl_25.range_0) ;
        _S1359 = (_S1360.w) == (_S1360.z);
    }
    if(_S1359)
    {
        return;
    }
    bool _S1361 = tid_18 == 0U;
    if(_S1361)
    {
        *(&kernelContext_86)->g_halt_0 = 0U;
        *(&kernelContext_86)->g_run_0 = 0U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    uint _S1362 = _S1358.w;
    uint4 _S1363 = uint4(isl_25.range_0) ;
    uint i_24 = _S1363.z + tid_18;
    for(;;)
    {
        if(i_24 < (_S1363.w))
        {
        }
        else
        {
            break;
        }
        BondStatic_natural_0 device* _S1364 = (&kernelContext_86)->bonds_0+i_24;
        BondDyn_natural_0 device* _S1365 = (&kernelContext_86)->bond_dyn_0+i_24;
        float4 _S1366 = float4((*_S1365).force_lin_0) ;
        float4 _S1367 = float4((*_S1365).force_ang_0) ;
        float4 _S1368 = float4((*_S1365).sums_0) ;
        float4 _S1369 = float4((*_S1365).comps_0) ;
        uint4 _S1370 = uint4((*_S1365).events_0) ;
        thread BondDyn_0 bd_2;
        (&bd_2)->js_0 = (*_S1365).js_0;
        (&bd_2)->force_lin_0 = _S1366;
        (&bd_2)->force_ang_0 = _S1367;
        (&bd_2)->sums_0 = _S1368;
        (&bd_2)->comps_0 = _S1369;
        (&bd_2)->events_0 = _S1370;
        thread JointBond_natural_0 _S1371 = _S1364->law_0;
        uint4 _S1372 = uint4((&_S1371)->ids_0) ;
        uint _S1373 = 4U * _S1372.y;
        uint _S1374 = 4U * _S1372.z;
        thread float3 d_lin_7;
        thread float3 d_ang_6;
        bond_kinematics_0(i_24, (float4(*((&kernelContext_86)->state_0+_S1373)) ).xyz, (float4(*((&kernelContext_86)->state_0+(_S1373 + 1U))) ).xyz, (float4(*((&kernelContext_86)->state_0+_S1374)) ).xyz, (float4(*((&kernelContext_86)->state_0+(_S1374 + 1U))) ).xyz, &d_lin_7, &d_ang_6, &kernelContext_86);
        JointState_0 previous_3 = (&bd_2)->js_0;
        float _S1375 = (&kernelContext_86)->params_0->dt_0;
        bool _S1376 = ((&kernelContext_86)->params_0->fracture_0) != 0U;
        _S1371 = _S1364->law_0;
        thread JointState_0 _S1377 = (&bd_2)->js_0;
        JointResponse_0 _S1378 = joint_evaluate_0(&(&kernelContext_86)->materials_0->m_0[_S1372.x], &_S1371, &_S1377, d_lin_7, d_ang_6, _S1375, _S1376);
        if((_S1378.state_6.damage_0) > (previous_3.damage_0 + 9.99999971718068537e-10f))
        {
            _S1359 = true;
        }
        else
        {
            _S1359 = (_S1378.state_6.crush_1) > (previous_3.crush_1 + 9.99999971718068537e-10f);
        }
        uint flags_2;
        if(_S1359)
        {
            flags_2 = 16U;
        }
        else
        {
            flags_2 = 0U;
        }
        thread float _S1379 = (&bd_2)->sums_0.x;
        thread float _S1380 = (&bd_2)->comps_0.x;
        comp_add1_0(&_S1379, &_S1380, _S1378.dissipated_2);
        (&bd_2)->comps_0.x = _S1380;
        (&bd_2)->sums_0.x = _S1379;
        thread float _S1381 = (&bd_2)->sums_0.y;
        thread float _S1382 = (&bd_2)->comps_0.y;
        comp_add1_0(&_S1381, &_S1382, _S1378.overshoot_0);
        (&bd_2)->comps_0.y = _S1382;
        (&bd_2)->sums_0.y = _S1381;
        (&bd_2)->force_lin_0 = float4(_S1378.force_lin_1, _S1378.stored_5);
        (&bd_2)->force_ang_0 = float4(_S1378.force_ang_1, max((&bd_2)->force_ang_0.w, _S1378.state_6.utilization_0));
        thread JointState_0 _S1383 = previous_3;
        bool _S1384 = is_damaged_0(&_S1383);
        bool _S1385;
        if(!_S1384)
        {
            thread JointState_0 _S1386 = _S1378.state_6;
            bool _S1387 = is_damaged_0(&_S1386);
            _S1385 = _S1387;
        }
        else
        {
            _S1385 = false;
        }
        bool _S1388;
        if(_S1385)
        {
            _S1388 = ((&bd_2)->events_0.x) == 0U;
        }
        else
        {
            _S1388 = false;
        }
        if(_S1388)
        {
            (&bd_2)->events_0.x = _S1362;
            (&bd_2)->events_0.w = _S1378.state_6.mode_0;
        }
        bool _S1389;
        if(((&bd_2)->events_0.y) == 0U)
        {
            float _S1390 = fatigue_factor_0(&(&kernelContext_86)->materials_0->m_0[_S1372.x], previous_3.life_0);
            _S1389 = _S1390 > 0.99000000953674316f;
        }
        else
        {
            _S1389 = false;
        }
        bool _S1391;
        if(_S1389)
        {
            float _S1392 = fatigue_factor_0(&(&kernelContext_86)->materials_0->m_0[_S1372.x], _S1378.state_6.life_0);
            _S1391 = _S1392 <= 0.99000000953674316f;
        }
        else
        {
            _S1391 = false;
        }
        if(_S1391)
        {
            (&bd_2)->events_0.y = _S1362;
        }
        uint flags_3;
        if(_S1378.disconnected_0)
        {
            (&bd_2)->events_0.z = _S1362;
            flags_3 = flags_2 | 32U;
        }
        else
        {
            flags_3 = flags_2;
        }
        (&bd_2)->js_0 = _S1378.state_6;
        BondDyn_natural_0 device* _S1393 = (&kernelContext_86)->bond_dyn_0+i_24;
        _S1393->js_0 = bd_2.js_0;
        _S1393->force_lin_0 = packed_float4(bd_2.force_lin_0) ;
        _S1393->force_ang_0 = packed_float4(bd_2.force_ang_0) ;
        _S1393->sums_0 = packed_float4(bd_2.sums_0) ;
        _S1393->comps_0 = packed_float4(bd_2.comps_0) ;
        _S1393->events_0 = packed_uint4(bd_2.events_0) ;
        write_bond_loads_0(i_24, i_24, _S1378.force_lin_1, _S1378.force_ang_1, max(_S1378.measures_0.tension_0, _S1378.measures_0.compression_0), &kernelContext_86);
        if((flags_3 & 16U) != 0U)
        {
            *(&kernelContext_86)->g_halt_0 = 1U;
        }
        if((flags_3 & 32U) != 0U)
        {
            *(&kernelContext_86)->g_run_0 = 1U;
        }
        i_24 = i_24 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    if(_S1361)
    {
        _S1359 = ((*(&kernelContext_86)->g_halt_0) | (*(&kernelContext_86)->g_run_0)) != 0U;
    }
    else
    {
        _S1359 = false;
    }
    if(_S1359)
    {
        uint _S1394 = _S1358.z;
        if((*(&kernelContext_86)->g_halt_0) != 0U)
        {
            i_24 = 16U;
        }
        else
        {
            i_24 = 0U;
        }
        uint _S1395 = _S1394 | i_24;
        if((*(&kernelContext_86)->g_run_0) != 0U)
        {
            i_24 = 32U;
        }
        else
        {
            i_24 = 0U;
        }
        ((&kernelContext_86)->islands_0+_S1356)->info_0[int(2)] = _S1395 | i_24;
    }
    return;
}

