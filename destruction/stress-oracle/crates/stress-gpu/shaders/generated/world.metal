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
    float4 unused_0;
    float4 ledger_0;
    uint4 cand_0;
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
    float4 _S332 = float4((*_S315).unused_0) ;
    float4 _S333 = float4((*_S315).ledger_0) ;
    uint4 _S334 = uint4((*_S315).cand_0) ;
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
    (&imp_5)->unused_0 = _S332;
    (&imp_5)->ledger_0 = _S333;
    (&imp_5)->cand_0 = _S334;
    float4 _S335 = float4(0.0f) ;
    thread float4 shares_0 = _S335;
    thread float4 unused_1 = _S335;
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
    group_sum2_0(tid_2, &shares_0, &unused_1, &kernelContext_25);
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
        float _S336 = (&imp_5)->crush_0.x * extra_0;
        thread float _S337 = (&imp_5)->ledger_0.z;
        thread float _S338 = (&imp_5)->ledger_0.w;
        comp_add1_0(&_S337, &_S338, _S336);
        (&imp_5)->ledger_0.w = _S338;
        (&imp_5)->ledger_0.z = _S337;
        float _S339 = (&imp_5)->crush_0.x * extra_0;
        thread float _S340 = (&imp_5)->ledger_0.x;
        thread float _S341 = (&imp_5)->ledger_0.y;
        comp_add1_0(&_S340, &_S341, _S339);
        (&imp_5)->ledger_0.y = _S341;
        (&imp_5)->ledger_0.x = _S340;
        (&imp_5)->geom_0.x = (&imp_5)->crush_0.x / total_1;
    }
    Impactor_natural_0 device* _S342 = (&kernelContext_25)->impactors_0+ii_0;
    _S342->position_1 = packed_float4(imp_5.position_1) ;
    _S342->position_err_1 = packed_float4(imp_5.position_err_1) ;
    _S342->velocity_1 = packed_float4(imp_5.velocity_1) ;
    _S342->velocity_err_1 = packed_float4(imp_5.velocity_err_1) ;
    _S342->angular_velocity_1 = packed_float4(imp_5.angular_velocity_1) ;
    _S342->rotation_1 = packed_float4(imp_5.rotation_1) ;
    _S342->inertia0_2 = packed_float4(imp_5.inertia0_2) ;
    _S342->inertia1_2 = packed_float4(imp_5.inertia1_2) ;
    _S342->inertia2_2 = packed_float4(imp_5.inertia2_2) ;
    _S342->inv0_2 = packed_float4(imp_5.inv0_2) ;
    _S342->inv1_2 = packed_float4(imp_5.inv1_2) ;
    _S342->inv2_2 = packed_float4(imp_5.inv2_2) ;
    _S342->shape_0 = packed_float4(imp_5.shape_0) ;
    _S342->half_1 = packed_float4(imp_5.half_1) ;
    _S342->mat_0 = packed_float4(imp_5.mat_0) ;
    _S342->crush_0 = packed_float4(imp_5.crush_0) ;
    _S342->geom_0 = packed_float4(imp_5.geom_0) ;
    _S342->unused_0 = packed_float4(imp_5.unused_0) ;
    _S342->ledger_0 = packed_float4(imp_5.ledger_0) ;
    _S342->cand_0 = packed_uint4(imp_5.cand_0) ;
    return;
}

void comp_add_0(float3 thread* sum_1, float3 thread* err_1, float3 x_4)
{
    float3 t_3 = *sum_1 + x_4;
    float3 _S343 = abs(x_4);
    *err_1 = *err_1 + (select(x_4, *sum_1, (abs(*sum_1)) >= _S343) - t_3 + select(*sum_1, x_4, (abs(*sum_1)) >= _S343));
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
    thread Quat_0 _S344 = c_7;
    float3 _S345 = rotate_0(&_S344, v_5);
    return _S345;
}

float3 inverse_rotate_1(const Quat_0 thread* q_11, float3 v_6)
{
    thread Quat_0 c_8;
    (&c_8)->w_1 = q_11->w_1;
    (&c_8)->x_1 = - q_11->x_1;
    (&c_8)->y_1 = - q_11->y_1;
    (&c_8)->z_0 = - q_11->z_0;
    thread Quat_0 _S346 = c_8;
    float3 _S347 = rotate_0(&_S346, v_6);
    return _S347;
}

float3 rows_mul_0(float4 r0_0, float4 r1_0, float4 r2_0, float3 v_7)
{
    return float3(dot(r0_0.xyz, v_7), dot(r1_0.xyz, v_7), dot(r2_0.xyz, v_7));
}

float3 world_mul_0(const Quat_0 thread* q_12, float4 r0_1, float4 r1_1, float4 r2_1, float3 v_8)
{
    float3 _S348 = inverse_rotate_1(q_12, v_8);
    float3 _S349 = rotate_1(q_12, rows_mul_0(r0_1, r1_1, r2_1, _S348));
    return _S349;
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

Quat_0 normalized_0(const Quat_0 thread* q_13)
{
    float n_8 = sqrt(q_13->w_1 * q_13->w_1 + q_13->x_1 * q_13->x_1 + q_13->y_1 * q_13->y_1 + q_13->z_0 * q_13->z_0);
    thread Quat_0 r_6;
    (&r_6)->w_1 = q_13->w_1 / n_8;
    (&r_6)->x_1 = q_13->x_1 / n_8;
    (&r_6)->y_1 = q_13->y_1 / n_8;
    (&r_6)->z_0 = q_13->z_0 / n_8;
    return r_6;
}

Quat_0 integrate_rotation_0(const Quat_0 thread* q_14, float3 omega_0, float dt_2)
{
    float angle_1 = length(omega_0) * dt_2;
    if(angle_1 < 1.00000000317107685e-30f)
    {
        return *q_14;
    }
    thread Quat_0 _S350 = from_axis_angle_0(omega_0, angle_1);
    Quat_0 _S351 = quat_mul_0(&_S350, q_14);
    thread Quat_0 _S352 = _S351;
    Quat_0 _S353 = normalized_0(&_S352);
    return _S353;
}

float4 quat_vec_0(const Quat_0 thread* q_15)
{
    return float4(q_15->x_1, q_15->y_1, q_15->z_0, q_15->w_1);
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
    Island_natural_0 device* _S354 = (&kernelContext_26)->islands_0+(&kernelContext_26)->params_0->halt_index_0;
    Impactor_natural_0 device* _S355 = (&kernelContext_26)->impactors_0+ii_1;
    float4 _S356 = float4((*_S355).position_err_1) ;
    float4 _S357 = float4((*_S355).velocity_1) ;
    float4 _S358 = float4((*_S355).velocity_err_1) ;
    float4 _S359 = float4((*_S355).angular_velocity_1) ;
    float4 _S360 = float4((*_S355).rotation_1) ;
    float4 _S361 = float4((*_S355).inertia0_2) ;
    float4 _S362 = float4((*_S355).inertia1_2) ;
    float4 _S363 = float4((*_S355).inertia2_2) ;
    float4 _S364 = float4((*_S355).inv0_2) ;
    float4 _S365 = float4((*_S355).inv1_2) ;
    float4 _S366 = float4((*_S355).inv2_2) ;
    float4 _S367 = float4((*_S355).shape_0) ;
    float4 _S368 = float4((*_S355).half_1) ;
    float4 _S369 = float4((*_S355).mat_0) ;
    float4 _S370 = float4((*_S355).crush_0) ;
    float4 _S371 = float4((*_S355).geom_0) ;
    float4 _S372 = float4((*_S355).unused_0) ;
    float4 _S373 = float4((*_S355).ledger_0) ;
    uint4 _S374 = uint4((*_S355).cand_0) ;
    thread Impactor_0 imp_6;
    (&imp_6)->position_1 = float4((*_S355).position_1) ;
    (&imp_6)->position_err_1 = _S356;
    (&imp_6)->velocity_1 = _S357;
    (&imp_6)->velocity_err_1 = _S358;
    (&imp_6)->angular_velocity_1 = _S359;
    (&imp_6)->rotation_1 = _S360;
    (&imp_6)->inertia0_2 = _S361;
    (&imp_6)->inertia1_2 = _S362;
    (&imp_6)->inertia2_2 = _S363;
    (&imp_6)->inv0_2 = _S364;
    (&imp_6)->inv1_2 = _S365;
    (&imp_6)->inv2_2 = _S366;
    (&imp_6)->shape_0 = _S367;
    (&imp_6)->half_1 = _S368;
    (&imp_6)->mat_0 = _S369;
    (&imp_6)->crush_0 = _S370;
    (&imp_6)->geom_0 = _S371;
    (&imp_6)->unused_0 = _S372;
    (&imp_6)->ledger_0 = _S373;
    (&imp_6)->cand_0 = _S374;
    bool _S375;
    if(((&imp_6)->cand_0.z) != 0U)
    {
        _S375 = true;
    }
    else
    {
        _S375 = (((uint4(_S354->info_0) ).z) & 1U) != 0U;
    }
    if(_S375)
    {
        _S375 = true;
    }
    else
    {
        uint _S376 = (uint4(_S354->info_0) ).y;
        if(_S376 != 0U)
        {
            _S375 = ((&imp_6)->cand_0.w) >= _S376;
        }
        else
        {
            _S375 = false;
        }
    }
    if(_S375)
    {
        return;
    }
    float4 _S377 = float4(0.0f) ;
    thread float4 rf_0 = _S377;
    thread float4 rt_0 = _S377;
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
        uint _S378 = 3U * k_9;
        rf_0 = rf_0 + float4(*((&kernelContext_26)->scratch_0+((&kernelContext_26)->params_0->cand_base_0 + _S378 + 1U))) ;
        rt_0 = rt_0 + float4(*((&kernelContext_26)->scratch_0+((&kernelContext_26)->params_0->cand_base_0 + _S378 + 2U))) ;
        k_9 = k_9 + 256U;
    }
    group_sum2_0(tid_3, &rf_0, &rt_0, &kernelContext_26);
    if(tid_3 != 0U)
    {
        return;
    }
    float dt_3 = (&kernelContext_26)->params_0->dt_0;
    float3 _S379 = float3(0.0f) ;
    float3 load_f_0;
    float3 load_t_0;
    if(((&kernelContext_26)->params_0->has_ground_0) != 0U)
    {
        float3 _S380 = (&imp_6)->half_1.xyz;
        thread Impactor_0 _S381 = imp_6;
        Box_0 _S382 = impactor_box_0(&_S381, _S379, _S380);
        float3 _S383 = (&imp_6)->velocity_1.xyz + (&imp_6)->velocity_err_1.xyz;
        float _S384 = (&kernelContext_26)->params_0->ground_modulus_0;
        float _S385 = (&imp_6)->mat_0.x;
        float3 _S386 = float3(0.0f, 0.0f, 1.0f);
        thread Box_0 _S387 = _S382;
        thread Box_0 _S388 = _S382;
        float _S389 = contact_stiffness_0(_S384, &_S387, _S385, &_S388, _S386);
        float _S390 = (&imp_6)->position_1.z - (&kernelContext_26)->params_0->ground_hi_0 + ((&imp_6)->position_err_1.z - (&kernelContext_26)->params_0->ground_lo_0);
        uint total_points_0;
        if(((&imp_6)->shape_0.x) == 0.0f)
        {
            total_points_0 = 1U;
        }
        else
        {
            total_points_0 = 14U;
        }
        float _S391 = _S389 / float(min(total_points_0, 5U));
        uint s_1 = 0U;
        uint below_0 = 0U;
        for(;;)
        {
            if(s_1 < total_points_0)
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
                thread Box_0 _S392 = _S382;
                float3 _S393 = sample_point_0(&_S392, s_1, &kernelContext_26);
                p_10 = _S393;
            }
            if((_S390 + p_10.z) < 0.0f)
            {
                below_0 = below_0 + 1U;
            }
            s_1 = s_1 + 1U;
        }
        s_1 = 0U;
        load_f_0 = _S379;
        load_t_0 = _S379;
        for(;;)
        {
            if(s_1 < total_points_0)
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
                thread Box_0 _S394 = _S382;
                float3 _S395 = sample_point_0(&_S394, s_1, &kernelContext_26);
                p_10 = _S395;
            }
            float depth_4 = - (_S390 + p_10.z);
            if(depth_4 <= 0.0f)
            {
                s_1 = s_1 + 1U;
                continue;
            }
            thread float stored_3;
            thread float diss_2;
            float3 _S396 = penalty_force_0(_S391, (&imp_6)->mat_0.z, (&kernelContext_26)->params_0->ground_friction_0, depth_4, _S386, _S383 + cross((&imp_6)->angular_velocity_1.xyz, p_10), dt_3, below_0, &stored_3, &diss_2, &kernelContext_26);
            float3 load_f_1 = load_f_0 + _S396;
            float3 load_t_1 = load_t_0 + cross(p_10, _S396);
            thread float _S397 = (&imp_6)->ledger_0.x;
            thread float _S398 = (&imp_6)->ledger_0.y;
            comp_add1_0(&_S397, &_S398, diss_2);
            (&imp_6)->ledger_0.y = _S398;
            (&imp_6)->ledger_0.x = _S397;
            load_f_0 = load_f_1;
            load_t_0 = load_t_1;
            s_1 = s_1 + 1U;
        }
    }
    else
    {
        load_f_0 = _S379;
        load_t_0 = _S379;
    }
    float3 load_f_2 = rf_0.xyz + load_f_0;
    float3 load_t_2 = rt_0.xyz + load_t_0;
    float m_2 = (&imp_6)->mat_0.z;
    thread float3 vel_0 = (&imp_6)->velocity_1.xyz;
    thread float3 vel_err_0 = (&imp_6)->velocity_err_1.xyz;
    float3 _S399 = float3(dt_3) ;
    comp_add_0(&vel_0, &vel_err_0, (load_f_2 / float3(m_2)  + (&kernelContext_26)->params_0->gravity_0.xyz) * _S399);
    Quat_0 q_16 = quat_of_0((&imp_6)->rotation_1);
    float3 _S400 = (&imp_6)->angular_velocity_1.xyz;
    thread Quat_0 _S401 = q_16;
    float3 _S402 = world_mul_0(&_S401, (&imp_6)->inertia0_2, (&imp_6)->inertia1_2, (&imp_6)->inertia2_2, _S400);
    float3 l_1 = _S402 + load_t_2 * _S399;
    thread Quat_0 _S403 = q_16;
    float3 _S404 = world_mul_0(&_S403, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    thread float3 pos_0 = (&imp_6)->position_1.xyz;
    thread float3 pos_err_0 = (&imp_6)->position_err_1.xyz;
    comp_add_0(&pos_0, &pos_err_0, (vel_0 + vel_err_0) * _S399);
    thread Quat_0 _S405 = q_16;
    Quat_0 _S406 = integrate_rotation_0(&_S405, _S404, dt_3);
    thread Quat_0 _S407 = _S406;
    float3 _S408 = world_mul_0(&_S407, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    (&imp_6)->angular_velocity_1 = float4(_S408, 0.0f);
    thread Quat_0 _S409 = _S406;
    float4 _S410 = quat_vec_0(&_S409);
    (&imp_6)->rotation_1 = _S410;
    (&imp_6)->position_1 = float4(pos_0, 0.0f);
    (&imp_6)->position_err_1 = float4(pos_err_0, 0.0f);
    (&imp_6)->velocity_1 = float4(vel_0, 0.0f);
    (&imp_6)->velocity_err_1 = float4(vel_err_0, 0.0f);
    (&imp_6)->cand_0.w = (&imp_6)->cand_0.w + 1U;
    (&imp_6)->geom_0 = float4(1.0f, (&imp_6)->crush_0.w, 0.0f, 0.0f);
    Impactor_natural_0 device* _S411 = (&kernelContext_26)->impactors_0+ii_1;
    _S411->position_1 = packed_float4(imp_6.position_1) ;
    _S411->position_err_1 = packed_float4(imp_6.position_err_1) ;
    _S411->velocity_1 = packed_float4(imp_6.velocity_1) ;
    _S411->velocity_err_1 = packed_float4(imp_6.velocity_err_1) ;
    _S411->angular_velocity_1 = packed_float4(imp_6.angular_velocity_1) ;
    _S411->rotation_1 = packed_float4(imp_6.rotation_1) ;
    _S411->inertia0_2 = packed_float4(imp_6.inertia0_2) ;
    _S411->inertia1_2 = packed_float4(imp_6.inertia1_2) ;
    _S411->inertia2_2 = packed_float4(imp_6.inertia2_2) ;
    _S411->inv0_2 = packed_float4(imp_6.inv0_2) ;
    _S411->inv1_2 = packed_float4(imp_6.inv1_2) ;
    _S411->inv2_2 = packed_float4(imp_6.inv2_2) ;
    _S411->shape_0 = packed_float4(imp_6.shape_0) ;
    _S411->half_1 = packed_float4(imp_6.half_1) ;
    _S411->mat_0 = packed_float4(imp_6.mat_0) ;
    _S411->crush_0 = packed_float4(imp_6.crush_0) ;
    _S411->geom_0 = packed_float4(imp_6.geom_0) ;
    _S411->unused_0 = packed_float4(imp_6.unused_0) ;
    _S411->ledger_0 = packed_float4(imp_6.ledger_0) ;
    _S411->cand_0 = packed_uint4(imp_6.cand_0) ;
    uint k_10 = (&imp_6)->cand_0.w - 1U - (&kernelContext_26)->params_0->step_start_0;
    if(k_10 < ((&kernelContext_26)->params_0->record_stride_0))
    {
        uint at_3 = (&kernelContext_26)->params_0->record_base_0 + 2U * (ii_1 * (&kernelContext_26)->params_0->record_stride_0 + k_10);
        *((&kernelContext_26)->scratch_0+at_3) = packed_float4(float4(vel_0 + vel_err_0, 0.0f)) ;
        *((&kernelContext_26)->scratch_0+(at_3 + 1U)) = packed_float4(float4(pos_0 + pos_err_0, 0.0f)) ;
    }
    return;
}

void ground_contact_0(uint c_9, bool account_0, float3 thread* f_1, float3 thread* t_4, KernelContext_0 thread* kernelContext_27)
{
    ChunkStatic_natural_0 device* _S412 = kernelContext_27->chunks_0+c_9;
    WorldPoint_0 _S413 = chunk_world_0(c_9, kernelContext_27);
    float above_0 = _S413.hi_0.z - kernelContext_27->params_0->ground_hi_0 + (_S413.lo_0.z - kernelContext_27->params_0->ground_lo_0) + _S413.rel_0.z;
    if((above_0 - (float4(_S412->half_0) ).w) > 0.0f)
    {
        return;
    }
    Box_0 _S414 = chunk_box_0(c_9, float3(0.0f) , kernelContext_27);
    float _S415 = kernelContext_27->params_0->ground_modulus_0;
    float _S416 = (float4(_S412->cmat_0) ).x;
    float3 _S417 = float3(0.0f, 0.0f, 1.0f);
    thread Box_0 _S418 = _S414;
    thread Box_0 _S419 = _S414;
    float _S420 = contact_stiffness_0(_S415, &_S418, _S416, &_S419, _S417);
    thread Box_0 _S421 = _S414;
    uint _S422 = sample_count_0(&_S421);
    uint s_2 = 0U;
    uint n_9 = 0U;
    for(;;)
    {
        if(s_2 < _S422)
        {
        }
        else
        {
            break;
        }
        thread Box_0 _S423 = _S414;
        float3 _S424 = sample_point_0(&_S423, s_2, kernelContext_27);
        if((above_0 + _S424.z) < 0.0f)
        {
            n_9 = n_9 + 1U;
        }
        s_2 = s_2 + 1U;
    }
    if(n_9 == 0U)
    {
        return;
    }
    thread float3 vc_1;
    thread float3 wc_1;
    chunk_velocity_0(c_9, &vc_1, &wc_1, kernelContext_27);
    thread float4 ledger_2 = float4(*(kernelContext_27->scratch_0+(kernelContext_27->params_0->ledger_base_0 + kernelContext_27->params_0->pair_count_0 + c_9))) ;
    s_2 = 0U;
    for(;;)
    {
        if(s_2 < _S422)
        {
        }
        else
        {
            break;
        }
        thread Box_0 _S425 = _S414;
        float3 _S426 = sample_point_0(&_S425, s_2, kernelContext_27);
        float _S427 = above_0 + _S426.z;
        if(!(_S427 < 0.0f))
        {
            s_2 = s_2 + 1U;
            continue;
        }
        thread float stored_4;
        thread float diss_3;
        float3 _S428 = penalty_force_0(_S420 / float(max(n_9, 5U)), (float4(_S412->center_0) ).w, kernelContext_27->params_0->ground_friction_0, - _S427, _S417, vc_1 + cross(wc_1, _S426), kernelContext_27->params_0->dt_0, n_9, &stored_4, &diss_3, kernelContext_27);
        *f_1 = *f_1 + _S428;
        *t_4 = *t_4 + cross(_S426, _S428);
        thread float _S429 = ledger_2.y;
        thread float _S430 = ledger_2.z;
        comp_add1_0(&_S429, &_S430, diss_3);
        ledger_2.z = _S430;
        ledger_2.y = _S429;
        s_2 = s_2 + 1U;
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
    bool _S431;
    if(g_0 >= (params_5->seg_count_0))
    {
        _S431 = true;
    }
    else
    {
        bool _S432 = stopped_0(&kernelContext_28);
        _S431 = _S432;
    }
    if(_S431)
    {
        return;
    }
    uint _S433 = 3U * g_0;
    uint _S434 = (&kernelContext_28)->index_0[(&kernelContext_28)->params_0->seg_index_0 + _S433];
    uint begin_0 = (&kernelContext_28)->index_0[(&kernelContext_28)->params_0->seg_index_0 + _S433 + 1U];
    uint _S435 = (&kernelContext_28)->index_0[(&kernelContext_28)->params_0->seg_index_0 + _S433 + 2U];
    float3 _S436 = float3(0.0f) ;
    thread float3 f_2 = _S436;
    thread float3 t_5 = _S436;
    uint e_2 = begin_0;
    for(;;)
    {
        if(e_2 < _S435)
        {
        }
        else
        {
            break;
        }
        uint entry_1 = (&kernelContext_28)->index_0[e_2];
        if(entry_1 == 2147483648U)
        {
            ground_contact_0(_S434, true, &f_2, &t_5, &kernelContext_28);
            e_2 = e_2 + 1U;
            continue;
        }
        uint _S437 = 2U * entry_1;
        f_2 = f_2 + (float4(*((&kernelContext_28)->scratch_0+((&kernelContext_28)->params_0->slot_base_0 + _S437))) ).xyz;
        t_5 = t_5 + (float4(*((&kernelContext_28)->scratch_0+((&kernelContext_28)->params_0->slot_base_0 + _S437 + 1U))) ).xyz;
        e_2 = e_2 + 1U;
    }
    uint _S438 = 2U * g_0;
    *((&kernelContext_28)->scratch_0+((&kernelContext_28)->params_0->seg_base_0 + _S438)) = packed_float4(float4(f_2, 0.0f)) ;
    *((&kernelContext_28)->scratch_0+((&kernelContext_28)->params_0->seg_base_0 + _S438 + 1U)) = packed_float4(float4(t_5, 0.0f)) ;
    return;
}

bool contact_stopped_0(const Island_natural_0 thread* isl_0, KernelContext_0 thread* kernelContext_29)
{
    uint4 _S439 = uint4((kernelContext_29->islands_0+kernelContext_29->params_0->halt_index_0)->info_0) ;
    bool _S440;
    if(((_S439.z) & 1U) != 0U)
    {
        _S440 = true;
    }
    else
    {
        uint _S441 = _S439.y;
        if(_S441 != 0U)
        {
            _S440 = _S441 <= ((uint4(isl_0->info_0) ).w);
        }
        else
        {
            _S440 = false;
        }
    }
    return _S440;
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

bool contact_stopped_1(const Island_0 thread* isl_1, KernelContext_0 thread* kernelContext_30)
{
    uint4 _S442 = uint4((kernelContext_30->islands_0+kernelContext_30->params_0->halt_index_0)->info_0) ;
    bool _S443;
    if(((_S442.z) & 1U) != 0U)
    {
        _S443 = true;
    }
    else
    {
        uint _S444 = _S442.y;
        if(_S444 != 0U)
        {
            _S443 = _S444 <= (isl_1->info_0.w);
        }
        else
        {
            _S443 = false;
        }
    }
    return _S443;
}

struct Rigid_0
{
    Quat_0 rot_0;
    float3 pos_1;
    float3 pos_err_1;
    float3 vel_1;
    float3 vel_err_1;
    float3 w_4;
    float3 a_7;
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
    (&rg_0)->w_4 = (float4(isl_2->angular_velocity_0) ).xyz;
    float3 _S445 = float3(0.0f) ;
    (&rg_0)->a_7 = _S445;
    (&rg_0)->alpha_0 = _S445;
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
    (&rg_1)->w_4 = isl_3->angular_velocity_0.xyz;
    float3 _S446 = float3(0.0f) ;
    (&rg_1)->a_7 = _S446;
    (&rg_1)->alpha_0 = _S446;
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
    uint4 _S447 = isl_4->probes_0;
    uint at_5 = isl_4->probes_0.x;
    for(;;)
    {
        if(at_5 < (_S447.y))
        {
        }
        else
        {
            break;
        }
        uint4 info_2 = (as_type<uint4>((float4(*(kernelContext_32->loads_0+at_5)) )));
        float4 _S448 = float4(*(kernelContext_32->loads_0+(at_5 + 1U))) ;
        float4 _S449 = float4(*(kernelContext_32->loads_0+(at_5 + 2U))) ;
        float4 _S450 = float4(*(kernelContext_32->loads_0+(at_5 + 3U))) ;
        uint kind_0 = info_2.x;
        uint i_5 = info_2.y;
        float value_1;
        if(kind_0 == 0U)
        {
            float3 _S451 = rg_2->pos_1 - _S449.xyz + (rg_2->pos_err_1 - _S450.xyz);
            float3 _S452 = rotate_0(&rg_2->rot_0, (float4((kernelContext_32->chunks_0+i_5)->center_0) ).xyz + (float4(*(kernelContext_32->state_0+4U * i_5)) ).xyz);
            value_1 = dot(_S451 + _S452, _S448.xyz);
        }
        else
        {
            if(kind_0 == 1U)
            {
                uint _S453 = 4U * i_5;
                float3 _S454 = rotate_0(&rg_2->rot_0, (float4((kernelContext_32->chunks_0+i_5)->center_0) ).xyz + (float4(*(kernelContext_32->state_0+_S453)) ).xyz - isl_4->com_0.xyz);
                float3 _S455 = rg_2->vel_1 + rg_2->vel_err_1 + cross(rg_2->w_4, _S454);
                float3 _S456 = rotate_0(&rg_2->rot_0, (float4(*(kernelContext_32->state_0+(_S453 + 2U))) ).xyz);
                value_1 = dot(_S455 + _S456, _S448.xyz);
            }
            else
            {
                if(kind_0 == 2U)
                {
                    uint _S457 = 3U * i_5;
                    float3 f_3 = (float4(*(kernelContext_32->scratch_0+_S457)) ).xyz;
                    bool _S458 = (info_2.z) == 0U;
                    float3 mc_0;
                    if(_S458)
                    {
                        mc_0 = (float4(*(kernelContext_32->scratch_0+(_S457 + 1U))) ).xyz;
                    }
                    else
                    {
                        mc_0 = (float4(*(kernelContext_32->scratch_0+(_S457 + 2U))) ).xyz;
                    }
                    float3 fc_0;
                    if(_S458)
                    {
                        fc_0 = f_3;
                    }
                    else
                    {
                        fc_0 = - f_3;
                    }
                    value_1 = dot(fc_0, _S448.xyz) + dot(mc_0, _S449.xyz);
                }
                else
                {
                    uint _S459 = 4U * i_5;
                    float3 _S460 = rotate_0(&rg_2->rot_0, float3((float4(*(kernelContext_32->state_0+(_S459 + 1U))) ).w, (float4(*(kernelContext_32->state_0+(_S459 + 2U))) ).w, (float4(*(kernelContext_32->state_0+(_S459 + 3U))) ).w));
                    value_1 = dot(_S460, _S448.xyz);
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
    float4 _S461 = float4(*(kernelContext_34->loads_0+offset_0)) ;
    if(tau_0 <= (_S461.x))
    {
        return _S461.y;
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
        uint _S462 = offset_0 + i_6;
        float4 _S463 = float4(*(kernelContext_34->loads_0+_S462)) ;
        float _S464 = _S463.x;
        if(tau_0 <= _S464)
        {
            float4 _S465 = float4(*(kernelContext_34->loads_0+(_S462 - 1U))) ;
            float _S466 = _S465.x;
            float _S467 = _S465.y;
            return _S467 + (tau_0 - _S466) / max(_S464 - _S466, 1.00000000317107685e-30f) * (_S463.y - _S467);
        }
        i_6 = i_6 + 1U;
    }
    return (float4(*(kernelContext_34->loads_0+(offset_0 + count_2 - 1U))) ).y;
}

float eval_function_0(uint term_0, uint k_14, float dt_5, float shift_0, KernelContext_0 thread* kernelContext_35)
{
    uint _S468 = 5U * term_0;
    uint4 info_3 = (as_type<uint4>((float4(*(kernelContext_35->loads_0+_S468)) )));
    float4 _S469 = float4(*(kernelContext_35->loads_0+(_S468 + 3U))) ;
    float4 _S470 = float4(*(kernelContext_35->loads_0+(_S468 + 4U))) ;
    uint kind_1 = info_3.z;
    if(kind_1 == 0U)
    {
        return _S469.z;
    }
    float _S471 = time_since_0(_S469, k_14, dt_5, kernelContext_35);
    float tau_1 = _S471 + shift_0;
    float shape_1;
    if(kind_1 == 1U)
    {
        if(tau_1 <= 0.0f)
        {
            shape_1 = 0.0f;
        }
        else
        {
            float _S472 = _S470.x;
            if(tau_1 >= _S472)
            {
                shape_1 = _S470.y;
            }
            else
            {
                shape_1 = _S470.y * tau_1 / _S472;
            }
        }
        return shape_1;
    }
    bool _S473;
    if(kind_1 == 2U)
    {
        if(tau_1 < 0.0f)
        {
            _S473 = true;
        }
        else
        {
            _S473 = tau_1 > (_S470.x);
        }
        if(_S473)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S470.y * sin(3.14159274101257324f * tau_1 / _S470.x);
        }
        return shape_1;
    }
    if(kind_1 == 3U)
    {
        float sn_0 = tau_1 / _S470.y;
        if(sn_0 < 0.0f)
        {
            _S473 = true;
        }
        else
        {
            _S473 = sn_0 > 1.0f;
        }
        if(_S473)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S470.x * (1.0f - sn_0) * exp(- _S470.z * sn_0);
        }
        return shape_1;
    }
    if(kind_1 == 4U)
    {
        float _S474 = table_eval_0(info_3.w, (as_type<uint>((_S470.x))), tau_1, kernelContext_35);
        return _S474;
    }
    if(kind_1 == 5U)
    {
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float sn_1 = tau_1 / _S470.x;
        if(sn_1 < 0.0f)
        {
            _S473 = true;
        }
        else
        {
            _S473 = sn_1 > 1.0f;
        }
        if(_S473)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = (1.0f - sn_1) * exp(- _S470.y * sn_1);
        }
        float clearing_0 = _S469.w;
        float relax_0;
        if(clearing_0 > 0.0f)
        {
            relax_0 = max(1.0f - tau_1 / clearing_0, 0.0f);
        }
        else
        {
            relax_0 = 0.0f;
        }
        float _S475 = _S470.w;
        return (_S475 + (_S470.z - _S475) * relax_0) * shape_1;
    }
    if(kind_1 == 7U)
    {
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float _S476 = _S470.y;
        if(tau_1 < _S476)
        {
            return _S470.x;
        }
        float s_3 = tau_1 - _S476;
        float _S477 = _S470.w;
        if(s_3 > _S477)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S470.z * sin(3.14159274101257324f * s_3 / _S477);
        }
        return shape_1;
    }
    float _S478 = _S470.x;
    if(_S478 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp(1.0f - tau_1 / _S478, 0.0f, 1.0f);
}

void record_chunk_load_0(uint c_10, float3 f_4, float3 t_6, KernelContext_0 thread* kernelContext_36)
{
    if((kernelContext_36->params_0->solve_mode_0) == 0U)
    {
        return;
    }
    uint _S479 = 2U * c_10;
    *(kernelContext_36->scratch_0+(kernelContext_36->params_0->cload_base_0 + _S479)) = packed_float4(float4(f_4, 0.0f)) ;
    *(kernelContext_36->scratch_0+(kernelContext_36->params_0->cload_base_0 + _S479 + 1U)) = packed_float4(float4(t_6, 0.0f)) ;
    *(kernelContext_36->scratch_0+(kernelContext_36->params_0->cframe_base_0 + _S479)) = packed_float4(float4((float4(*(kernelContext_36->scratch_0+(kernelContext_36->params_0->cframe_base_0 + _S479))) ).xyz + f_4, 0.0f)) ;
    *(kernelContext_36->scratch_0+(kernelContext_36->params_0->cframe_base_0 + _S479 + 1U)) = packed_float4(float4((float4(*(kernelContext_36->scratch_0+(kernelContext_36->params_0->cframe_base_0 + _S479 + 1U))) ).xyz + t_6, 0.0f)) ;
    return;
}

void chunk_external_0(uint _S480, uint _S481, const Quat_0 thread* _S482, uint _S483, float _S484, bool _S485, float3 thread* _S486, float3 thread* _S487, KernelContext_0 thread* kernelContext_37)
{
    bool _S488;
    ChunkStatic_natural_0 device* _S489 = kernelContext_37->chunks_0+_S481;
    float3 _S490 = float3(0.0f) ;
    *_S486 = _S490;
    *_S487 = _S490;
    uint4 _S491 = uint4(_S489->load_range_0) ;
    uint term_1 = _S491.x;
    for(;;)
    {
        if(term_1 < (_S491.y))
        {
        }
        else
        {
            break;
        }
        uint _S492 = 5U * term_1;
        uint _S493 = (as_type<uint4>((float4(*(kernelContext_37->loads_0+_S492)) ))).y;
        if(_S493 == 2U)
        {
            term_1 = term_1 + 1U;
            continue;
        }
        float4 _S494 = float4(*(kernelContext_37->loads_0+(_S492 + 1U))) ;
        float4 _S495 = float4(*(kernelContext_37->loads_0+(_S492 + 2U))) ;
        float _S496 = eval_function_0(term_1, _S483, _S484, 0.0f, kernelContext_37);
        if(_S493 == 0U)
        {
            _S488 = true;
        }
        else
        {
            _S488 = _S493 == 3U;
        }
        float3 fw_0;
        if(_S488)
        {
            fw_0 = _S494.xyz * float3(_S496) ;
        }
        else
        {
            float3 _S497 = rotate_0(_S482, _S494.xyz);
            fw_0 = _S497 * float3((- _S496 * _S494.w)) ;
        }
        float3 lever_0;
        if(_S493 == 3U)
        {
            lever_0 = _S495.xyz - (float4(*(kernelContext_37->state_0+4U * _S480)) ).xyz;
        }
        else
        {
            lever_0 = _S495.xyz;
        }
        *_S486 = *_S486 + fw_0;
        float3 _S498 = rotate_0(_S482, lever_0);
        *_S487 = *_S487 + cross(_S498, fw_0);
        term_1 = term_1 + 1U;
    }
    if(_S485)
    {
        _S488 = ((uint4(_S489->cinfo_0) ).z) != 0U;
    }
    else
    {
        _S488 = false;
    }
    if(_S488)
    {
        uint4 _S499 = uint4(_S489->cinfo_0) ;
        uint g_1 = _S499.x;
        for(;;)
        {
            if(g_1 < (_S499.y))
            {
            }
            else
            {
                break;
            }
            uint _S500 = 2U * g_1;
            *_S486 = *_S486 + (float4(*(kernelContext_37->scratch_0+(kernelContext_37->params_0->seg_base_0 + _S500))) ).xyz;
            *_S487 = *_S487 + (float4(*(kernelContext_37->scratch_0+(kernelContext_37->params_0->seg_base_0 + _S500 + 1U))) ).xyz;
            g_1 = g_1 + 1U;
        }
    }
    return;
}

float settled_chunk_load_0(uint c_11, const Quat_0 thread* rot_1, uint k_15, float dt_6, bool contact_0, KernelContext_0 thread* kernelContext_38)
{
    thread float3 f_5;
    thread float3 t_7;
    chunk_external_0(c_11, c_11, rot_1, k_15, dt_6, contact_0, &f_5, &t_7, kernelContext_38);
    record_chunk_load_0(c_11, f_5, t_7, kernelContext_38);
    return length(f_5);
}

void net_load_0(uint c_12, const Island_natural_0 thread* isl_5, const Rigid_0 thread* rg_3, uint k_16, float dt_7, bool contact_1, float3 thread* f_6, float3 thread* t_8, KernelContext_0 thread* kernelContext_39)
{
    ChunkStatic_natural_0 device* _S501 = kernelContext_39->chunks_0+c_12;
    thread float3 fl_0;
    thread float3 tl_0;
    chunk_external_0(c_12, c_12, &rg_3->rot_0, k_16, dt_7, contact_1, &fl_0, &tl_0, kernelContext_39);
    float4 _S502 = float4(_S501->center_0) ;
    float3 fc_1 = fl_0 + kernelContext_39->params_0->gravity_0.xyz * float3(_S502.w) ;
    float3 _S503 = _S502.xyz;
    float3 _S504 = (float4(isl_5->com_0) ).xyz;
    float3 _S505 = rotate_0(&rg_3->rot_0, _S503 + (float4(*(kernelContext_39->state_0+4U * c_12)) ).xyz - _S504);
    *f_6 = *f_6 + fc_1;
    *t_8 = *t_8 + (cross(_S505, fc_1) + tl_0);
    uint4 _S506 = uint4(_S501->load_range_0) ;
    uint term_2 = _S506.x;
    for(;;)
    {
        if(term_2 < (_S506.y))
        {
        }
        else
        {
            break;
        }
        uint _S507 = 5U * term_2;
        if(((as_type<uint4>((float4(*(kernelContext_39->loads_0+_S507)) ))).y) != 2U)
        {
            term_2 = term_2 + 1U;
            continue;
        }
        float _S508 = eval_function_0(term_2, k_16, dt_7, 0.0f, kernelContext_39);
        float3 _S509 = float3(_S508) ;
        float3 _S510 = rotate_0(&rg_3->rot_0, (float4(*(kernelContext_39->loads_0+(_S507 + 1U))) ).xyz * _S509);
        *f_6 = *f_6 + _S510;
        float3 _S511 = rotate_0(&rg_3->rot_0, _S503 - _S504);
        float3 _S512 = cross(_S511, _S510);
        float3 _S513 = rotate_0(&rg_3->rot_0, (float4(*(kernelContext_39->loads_0+(_S507 + 2U))) ).xyz * _S509);
        *t_8 = *t_8 + (_S512 + _S513);
        term_2 = term_2 + 1U;
    }
    return;
}

void net_load_1(uint c_13, const Island_0 thread* isl_6, const Rigid_0 thread* rg_4, uint k_17, float dt_8, bool contact_2, float3 thread* f_7, float3 thread* t_9, KernelContext_0 thread* kernelContext_40)
{
    ChunkStatic_natural_0 device* _S514 = kernelContext_40->chunks_0+c_13;
    thread float3 fl_1;
    thread float3 tl_1;
    chunk_external_0(c_13, c_13, &rg_4->rot_0, k_17, dt_8, contact_2, &fl_1, &tl_1, kernelContext_40);
    float4 _S515 = float4(_S514->center_0) ;
    float3 fc_2 = fl_1 + kernelContext_40->params_0->gravity_0.xyz * float3(_S515.w) ;
    float3 _S516 = _S515.xyz;
    float3 _S517 = isl_6->com_0.xyz;
    float3 _S518 = rotate_0(&rg_4->rot_0, _S516 + (float4(*(kernelContext_40->state_0+4U * c_13)) ).xyz - _S517);
    *f_7 = *f_7 + fc_2;
    *t_9 = *t_9 + (cross(_S518, fc_2) + tl_1);
    uint4 _S519 = uint4(_S514->load_range_0) ;
    uint term_3 = _S519.x;
    for(;;)
    {
        if(term_3 < (_S519.y))
        {
        }
        else
        {
            break;
        }
        uint _S520 = 5U * term_3;
        if(((as_type<uint4>((float4(*(kernelContext_40->loads_0+_S520)) ))).y) != 2U)
        {
            term_3 = term_3 + 1U;
            continue;
        }
        float _S521 = eval_function_0(term_3, k_17, dt_8, 0.0f, kernelContext_40);
        float3 _S522 = float3(_S521) ;
        float3 _S523 = rotate_0(&rg_4->rot_0, (float4(*(kernelContext_40->loads_0+(_S520 + 1U))) ).xyz * _S522);
        *f_7 = *f_7 + _S523;
        float3 _S524 = rotate_0(&rg_4->rot_0, _S516 - _S517);
        float3 _S525 = cross(_S524, _S523);
        float3 _S526 = rotate_0(&rg_4->rot_0, (float4(*(kernelContext_40->loads_0+(_S520 + 2U))) ).xyz * _S522);
        *t_9 = *t_9 + (_S525 + _S526);
        term_3 = term_3 + 1U;
    }
    return;
}

void rigid_acceleration_0(const Island_natural_0 thread* isl_7, Rigid_0 thread* rg_5, float3 f_8, float3 t_10)
{
    float4 _S527 = float4(isl_7->inertia0_0) ;
    float4 _S528 = float4(isl_7->inertia1_0) ;
    float4 _S529 = float4(isl_7->inertia2_0) ;
    thread Quat_0 _S530 = rg_5->rot_0;
    float3 _S531 = world_mul_0(&_S530, _S527, _S528, _S529, rg_5->w_4);
    rg_5->a_7 = f_8 / float3((float4(isl_7->com_0) ).w) ;
    float4 _S532 = float4(isl_7->inv0_0) ;
    float4 _S533 = float4(isl_7->inv1_0) ;
    float4 _S534 = float4(isl_7->inv2_0) ;
    float3 _S535 = t_10 - cross(rg_5->w_4, _S531);
    thread Quat_0 _S536 = rg_5->rot_0;
    float3 _S537 = world_mul_0(&_S536, _S532, _S533, _S534, _S535);
    rg_5->alpha_0 = _S537;
    return;
}

void rigid_acceleration_1(const Island_0 thread* isl_8, Rigid_0 thread* rg_6, float3 f_9, float3 t_11)
{
    thread Quat_0 _S538 = rg_6->rot_0;
    float3 _S539 = world_mul_0(&_S538, isl_8->inertia0_0, isl_8->inertia1_0, isl_8->inertia2_0, rg_6->w_4);
    rg_6->a_7 = f_9 / float3(isl_8->com_0.w) ;
    float3 _S540 = t_11 - cross(rg_6->w_4, _S539);
    thread Quat_0 _S541 = rg_6->rot_0;
    float3 _S542 = world_mul_0(&_S541, isl_8->inv0_0, isl_8->inv1_0, isl_8->inv2_0, _S540);
    rg_6->alpha_0 = _S542;
    return;
}

void integrate_rigid_0(const Island_natural_0 thread* isl_9, Rigid_0 thread* rg_7, float dt_9)
{
    float4 _S543 = float4(isl_9->inertia0_0) ;
    float4 _S544 = float4(isl_9->inertia1_0) ;
    float4 _S545 = float4(isl_9->inertia2_0) ;
    thread Quat_0 _S546 = rg_7->rot_0;
    float3 _S547 = world_mul_0(&_S546, _S543, _S544, _S545, rg_7->w_4);
    thread Quat_0 _S548 = rg_7->rot_0;
    float3 _S549 = world_mul_0(&_S548, _S543, _S544, _S545, rg_7->alpha_0);
    float3 _S550 = float3(dt_9) ;
    float3 l_2 = _S547 + (_S549 + cross(rg_7->w_4, _S547)) * _S550;
    comp_add_0(&rg_7->vel_1, &rg_7->vel_err_1, rg_7->a_7 * _S550);
    float3 vel_2 = rg_7->vel_1 + rg_7->vel_err_1;
    float4 _S551 = float4(isl_9->inv0_0) ;
    float4 _S552 = float4(isl_9->inv1_0) ;
    float4 _S553 = float4(isl_9->inv2_0) ;
    thread Quat_0 _S554 = rg_7->rot_0;
    float3 _S555 = world_mul_0(&_S554, _S551, _S552, _S553, l_2);
    thread Quat_0 _S556 = rg_7->rot_0;
    Quat_0 _S557 = integrate_rotation_0(&_S556, _S555, dt_9);
    float3 _S558 = vel_2 * _S550;
    float3 _S559 = (float4(isl_9->com_0) ).xyz;
    thread Quat_0 _S560 = rg_7->rot_0;
    float3 _S561 = rotate_0(&_S560, _S559);
    thread Quat_0 _S562 = _S557;
    float3 _S563 = rotate_0(&_S562, _S559);
    comp_add_0(&rg_7->pos_1, &rg_7->pos_err_1, _S558 + (_S561 - _S563));
    rg_7->rot_0 = _S557;
    thread Quat_0 _S564 = _S557;
    float3 _S565 = world_mul_0(&_S564, _S551, _S552, _S553, l_2);
    rg_7->w_4 = _S565;
    return;
}

void integrate_rigid_1(const Island_0 thread* isl_10, Rigid_0 thread* rg_8, float dt_10)
{
    thread Quat_0 _S566 = rg_8->rot_0;
    float3 _S567 = world_mul_0(&_S566, isl_10->inertia0_0, isl_10->inertia1_0, isl_10->inertia2_0, rg_8->w_4);
    thread Quat_0 _S568 = rg_8->rot_0;
    float3 _S569 = world_mul_0(&_S568, isl_10->inertia0_0, isl_10->inertia1_0, isl_10->inertia2_0, rg_8->alpha_0);
    float3 _S570 = float3(dt_10) ;
    float3 l_3 = _S567 + (_S569 + cross(rg_8->w_4, _S567)) * _S570;
    comp_add_0(&rg_8->vel_1, &rg_8->vel_err_1, rg_8->a_7 * _S570);
    float3 vel_3 = rg_8->vel_1 + rg_8->vel_err_1;
    float4 _S571 = isl_10->inv0_0;
    float4 _S572 = isl_10->inv1_0;
    float4 _S573 = isl_10->inv2_0;
    thread Quat_0 _S574 = rg_8->rot_0;
    float3 _S575 = world_mul_0(&_S574, isl_10->inv0_0, isl_10->inv1_0, isl_10->inv2_0, l_3);
    thread Quat_0 _S576 = rg_8->rot_0;
    Quat_0 _S577 = integrate_rotation_0(&_S576, _S575, dt_10);
    float3 _S578 = vel_3 * _S570;
    float3 _S579 = isl_10->com_0.xyz;
    thread Quat_0 _S580 = rg_8->rot_0;
    float3 _S581 = rotate_0(&_S580, _S579);
    thread Quat_0 _S582 = _S577;
    float3 _S583 = rotate_0(&_S582, _S579);
    comp_add_0(&rg_8->pos_1, &rg_8->pos_err_1, _S578 + (_S581 - _S583));
    rg_8->rot_0 = _S577;
    thread Quat_0 _S584 = _S577;
    float3 _S585 = world_mul_0(&_S584, _S571, _S572, _S573, l_3);
    rg_8->w_4 = _S585;
    return;
}

bool connected_0(const JointState_0 thread* st_0, bool has_rebar_0)
{
    bool _S586;
    if((st_0->damage_0) < 1.0f)
    {
        _S586 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S586 = (st_0->rebar_broken_0) == 0.0f;
        }
        else
        {
            _S586 = false;
        }
    }
    return _S586;
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
    float4 _S587 = float4(b_23->geom0_0) ;
    float area_2 = _S587.x;
    float _S588 = q_lin_0.z;
    float axial_0 = (metal::fast::divide((_S588), (area_2)));
    float4 _S589 = float4(b_23->geom1_0) ;
    float _S590 = (metal::fast::divide((abs(q_ang_0.x)), (_S589.x)));
    float _S591 = (metal::fast::divide((abs(q_ang_0.y)), (_S589.y)));
    float bending_0 = _S590 + _S591;
    float _S592 = q_lin_0.x;
    float _S593 = q_lin_0.y;
    float _S594 = (metal::fast::sqrt((_S592 * _S592 + _S593 * _S593)));
    float _S595 = (metal::fast::divide((_S594), (area_2)));
    float _S596 = (metal::fast::divide((abs(q_ang_0.z)), (_S587.w)));
    float shear_1 = _S595 + _S596;
    thread Measures_0 m_3;
    (&m_3)->tension_0 = axial_0 + bending_0;
    (&m_3)->shear_0 = shear_1;
    float _S597 = - axial_0;
    (&m_3)->normal_compression_0 = max(_S597, 0.0f);
    (&m_3)->compression_0 = _S597 + bending_0;
    (&m_3)->compressive_force_0 = max(- _S588, 0.0f);
    return m_3;
}

float expm1_accurate_0(float x_5)
{
    if((abs(x_5)) < 0.00100000004749745f)
    {
        return x_5 * (1.0f + x_5 * (0.5f + x_5 * 0.1666666716337204f));
    }
    return exp(x_5) - 1.0f;
}

float dif_factor_0(const JointMaterial_0 constant* mat_1, float strain_rate_1)
{
    float r_7 = abs(strain_rate_1);
    float4 _S598 = mat_1->dif_0;
    float ref_0 = mat_1->dif_0.x;
    if(r_7 <= ref_0)
    {
        return 1.0f;
    }
    float _S599 = _S598.z;
    float f_10;
    if(r_7 <= _S599)
    {
        float _S600 = (metal::fast::divide((r_7), (ref_0)));
        float _S601 = (metal::fast::pow((_S600), (_S598.y)));
        f_10 = _S601;
    }
    else
    {
        float _S602 = (metal::fast::divide((_S599), (ref_0)));
        float _S603 = (metal::fast::pow((_S602), (_S598.y)));
        float _S604 = (metal::fast::divide((r_7), (_S599)));
        float _S605 = (metal::fast::pow((_S604), (_S598.w)));
        f_10 = _S603 * _S605;
    }
    return clamp(f_10, 1.0f, mat_1->misc_0.x);
}

float fatigue_factor_0(const JointMaterial_0 constant* mat_2, float fatigue_1)
{
    if(((mat_2->kind_flags_0.y) & 64U) == 0U)
    {
        return 1.0f;
    }
    float _S606 = 1.0f - clamp(fatigue_1, 0.0f, 1.0f);
    float _S607 = (metal::fast::divide((1.0f), (mat_2->misc_0.y - 2.0f)));
    float _S608 = (metal::fast::pow((_S606), (_S607)));
    return _S608;
}

float infinity_0()
{
    return (as_type<float>((2139095040U)));
}

float4 failure_indices_0(const JointMaterial_0 constant* mat_3, const JointBond_natural_0 thread* b_24, const Measures_0 thread* m_4, float multiplier_0)
{
    float fc_3 = mat_3->strength_0.y * multiplier_0;
    float _S609 = min(mat_3->strength_0.z * multiplier_0 + mat_3->strength_0.w * m_4->normal_compression_0, mat_3->energy_1.x * multiplier_0);
    thread float4 idx_0;
    float _S610 = (metal::fast::divide((m_4->tension_0), (mat_3->strength_0.x * multiplier_0)));
    idx_0.x = max(_S610, 0.0f);
    float _S611;
    if(_S609 > 0.0f)
    {
        float _S612 = (metal::fast::divide((m_4->shear_0), (_S609)));
        _S611 = _S612;
    }
    else
    {
        _S611 = infinity_0();
    }
    idx_0.y = _S611;
    float _S613 = (metal::fast::divide((m_4->compression_0), (fc_3)));
    idx_0.z = max(_S613, 0.0f);
    float _S614 = (float4(b_24->stiff1_0) ).y;
    if(_S614 > 0.0f)
    {
        float _S615 = (metal::fast::divide((m_4->compressive_force_0), (_S614)));
        _S611 = _S615;
    }
    else
    {
        _S611 = 0.0f;
    }
    idx_0.w = _S611;
    return idx_0;
}

float sq_0(float x_6)
{
    return x_6 * x_6;
}

float damage_law_0(uint kind_2, float kappa_1, float r_8)
{
    if(kappa_1 <= 1.0f)
    {
        return 0.0f;
    }
    if(kind_2 == 0U)
    {
        if(r_8 <= 1.0f)
        {
            return 1.0f;
        }
        float _S616 = (metal::fast::divide((r_8 * (kappa_1 - 1.0f)), (kappa_1 * (r_8 - 1.0f))));
        return min(_S616, 1.0f);
    }
    if(kappa_1 >= (0.5f * (r_8 + 1.0f)))
    {
        return 1.0f;
    }
    float _S617 = (metal::fast::divide((1.0f), (kappa_1)));
    return 1.0f - _S617;
}

float2 damage_increment_0(uint kind_3, float kappa_old_0, float lambda_0, float r_9, float d_old_0, float psi_0)
{
    float _S618 = damage_law_0(kind_3, lambda_0, r_9);
    float _S619 = max(_S618, d_old_0);
    bool _S620;
    if(_S619 <= d_old_0)
    {
        _S620 = true;
    }
    else
    {
        _S620 = d_old_0 >= 1.0f;
    }
    if(_S620)
    {
        return float2(d_old_0, 0.0f);
    }
    float u0_0 = (metal::fast::divide((psi_0), (lambda_0 * lambda_0)));
    float _S621 = max(kappa_old_0, 1.0f);
    if(kind_3 == 0U)
    {
        if(r_9 > 1.0f)
        {
            float _S622 = (metal::fast::divide((u0_0 * r_9), (r_9 - 1.0f)));
            return float2(_S619, _S622 * max(min(lambda_0, r_9) - min(_S621, r_9), 0.0f));
        }
        return float2(_S619, (1.0f - d_old_0) * psi_0);
    }
    float ku_0 = 0.5f * (r_9 + 1.0f);
    float plateau_0 = u0_0 * max(min(lambda_0, ku_0) - min(_S621, ku_0), 0.0f);
    float snap_0;
    if(_S619 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return float2(_S619, plateau_0 + snap_0);
}

void compressed_region_0(float w0_0, float w1_0, float dz_0, float ax_0, float ay_0, array<float, int(6)> thread* region_0)
{
    uint count_3;
    float h0_0 = 0.5f * w0_0;
    float h1_0 = 0.5f * w1_0;
    float _S623 = - h0_0;
    float _S624 = - h1_0;
    array<float2, int(4)> _S625 = { { float2(_S623, _S624), float2(h0_0, _S624), float2(h0_0, h1_0), float2(_S623, h1_0) } };
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
        uint _S626 = i_7;
        uint _S627 = i_7 + 1U;
        uint _S628 = _S627 % 4U;
        float _S629 = _S625[i_7].y;
        float _S630 = _S625[i_7].x;
        float fp_0 = dz_0 + ax_0 * _S629 - ay_0 * _S630;
        float _S631 = _S625[_S628].y;
        float _S632 = _S625[_S628].x;
        float fq_0 = dz_0 + ax_0 * _S631 - ay_0 * _S632;
        bool _S633 = fp_0 < 0.0f;
        if(_S633)
        {
            uint _S634 = count_4 + 1U;
            poly_0[count_4] = _S625[_S626];
            count_3 = _S634;
        }
        else
        {
            count_3 = count_4;
        }
        if(_S633 != (fq_0 < 0.0f))
        {
            float t_12 = fp_0 / (fp_0 - fq_0);
            uint _S635 = count_3 + 1U;
            poly_0[count_3] = float2(_S630 + t_12 * (_S632 - _S630), _S629 + t_12 * (_S631 - _S629));
            count_4 = _S635;
        }
        else
        {
            count_4 = count_3;
        }
        i_7 = _S627;
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
    float a_8 = 0.0f;
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
        float _S636 = o_1.x;
        float x0_0 = poly_0[i_7].x - _S636;
        float _S637 = o_1.y;
        float y0_0 = poly_0[i_7].y - _S637;
        uint _S638 = i_7 + 1U;
        uint _S639 = _S638 % count_4;
        float x1_0 = poly_0[_S639].x - _S636;
        float y1_0 = poly_0[_S639].y - _S637;
        float _S640 = x0_0 * y1_0;
        float _S641 = x1_0 * y0_0;
        float cr_0 = _S640 - _S641;
        float a_9 = a_8 + cr_0 / 2.0f;
        float sx_1 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        float sy_1 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        float ixx_1 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        float iyy_1 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        float ixy_1 = ixy_0 + (_S640 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S641) * cr_0 / 24.0f;
        i_7 = _S638;
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
    float _S642 = a_8 * cx_0;
    (*region_0)[int(3)] = ixx_0 - _S642 * cx_0;
    (*region_0)[int(4)] = iyy_0 - a_8 * cy_0 * cy_0;
    (*region_0)[int(5)] = ixy_0 - _S642 * cy_0;
    return;
}

float4 no_tension_patch_0(float kn_0, float w0_1, float w1_1, float dz_1, float ax_1, float ay_1)
{
    thread array<float, int(6)> r_10;
    compressed_region_0(w0_1, w1_1, dz_1, ax_1, ay_1, &r_10);
    float a_10 = r_10[int(0)];
    if((r_10[int(0)]) == 0.0f)
    {
        return float4(0.0f) ;
    }
    float k_18 = kn_0 / (w0_1 * w1_1);
    float fc_4 = dz_1 + ax_1 * r_10[int(2)] - ay_1 * r_10[int(1)];
    float _S643 = a_10 * fc_4;
    float _S644 = - ay_1;
    return float4(k_18 * a_10 * fc_4, k_18 * (_S643 * r_10[int(2)] + (_S644 * r_10[int(5)] + ax_1 * r_10[int(4)])), - k_18 * (_S643 * r_10[int(1)] + (_S644 * r_10[int(3)] + ax_1 * r_10[int(5)])), 0.5f * k_18 * (_S643 * fc_4 + ay_1 * ay_1 * r_10[int(3)] + ax_1 * ax_1 * r_10[int(4)] - 2.0f * ax_1 * ay_1 * r_10[int(5)]));
}

float signum_0(float x_7)
{
    float _S645;
    if(((as_type<uint>((x_7))) & 2147483648U) != 0U)
    {
        _S645 = -1.0f;
    }
    else
    {
        _S645 = 1.0f;
    }
    return _S645;
}

float2 return_map_0(float k_19, float total_2, float plastic_0, float cap_0)
{
    float trial_0 = k_19 * (total_2 - plastic_0);
    if((abs(trial_0)) <= cap_0)
    {
        return float2(trial_0, 0.0f);
    }
    float f_11 = cap_0 * signum_0(trial_0);
    float _S646 = (metal::fast::divide((trial_0 - f_11), (k_19)));
    return float2(f_11, _S646);
}

struct Contact_0
{
    float3 q_lin_1;
    float3 q_ang_1;
    float energy_2;
    float diss_4;
    float3 plastic_1;
};

Contact_0 contact_part_0(const JointMaterial_0 constant* mat_4, const JointBond_natural_0 thread* b_25, float crush_2, float3 plastic_2, float3 d_lin_0, float3 d_ang_0)
{
    thread Contact_0 c_14;
    float3 _S647 = float3(0.0f) ;
    (&c_14)->q_lin_1 = _S647;
    (&c_14)->q_ang_1 = _S647;
    (&c_14)->energy_2 = 0.0f;
    (&c_14)->diss_4 = 0.0f;
    (&c_14)->plastic_1 = plastic_2;
    uint _S648 = mat_4->kind_flags_0.y;
    if((_S648 & 2U) == 0U)
    {
        return c_14;
    }
    float4 _S649 = float4(b_25->stiff0_0) ;
    float kn_1 = _S649.x;
    float ks_0 = _S649.y;
    float kt_0 = (float4(b_25->stiff1_0) ).x;
    float4 _S650 = float4(b_25->geom0_0) ;
    float w0_2 = _S650.y;
    float w1_2 = _S650.z;
    float diss_5;
    float nc_sum_0;
    float m1_0;
    float m2_0;
    float energy_3;
    if((_S648 & 4U) != 0U)
    {
        float4 p_11 = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        float _S651 = p_11.y;
        float _S652 = p_11.z;
        float _S653 = p_11.w;
        nc_sum_0 = p_11.x;
        m1_0 = _S651;
        m2_0 = _S652;
        energy_3 = _S653;
    }
    else
    {
        float ki_0 = kn_1 * (1.0f - crush_2) / 36.0f;
        float _S654 = d_ang_0.x;
        float _S655 = d_ang_0.y;
        float spread_0 = abs(_S654) * 0.4166666567325592f * w1_2 + abs(_S655) * 0.4166666567325592f * w0_2;
        float _S656 = d_lin_0.z;
        float slack_0 = 9.99999997475242708e-07f * (abs(_S656) + spread_0);
        if((_S656 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S656 + spread_0) < (- slack_0))
            {
                float i1_0 = 2.91666650772094727f * w0_2 * w0_2;
                float i2_0 = 2.91666650772094727f * w1_2 * w1_2;
                float _S657 = ki_0 * _S654 * i2_0;
                float _S658 = ki_0 * _S655 * i1_0;
                float _S659 = 0.5f * ki_0 * (36.0f * _S656 * _S656 + _S654 * _S654 * i2_0 + _S655 * _S655 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S656;
                m1_0 = _S657;
                m2_0 = _S658;
                energy_3 = _S659;
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
                    float _S660 = ((float(i_8) + 0.5f) / 6.0f - 0.5f) * w0_2;
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
                        float s2_0 = ((float(j_5) + 0.5f) / 6.0f - 0.5f) * w1_2;
                        float di_0 = _S656 + _S654 * s2_0 - _S655 * _S660;
                        if(di_0 < 0.0f)
                        {
                            float f_12 = ki_0 * di_0;
                            float m1_2 = m1_0 + f_12 * s2_0;
                            float m2_2 = m2_0 - f_12 * _S660;
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
    float _S661 = ks_0 * (d_lin_0.x - plastic_2.x);
    float _S662 = ks_0 * (d_lin_0.y - plastic_2.y);
    float tn_0 = (metal::fast::sqrt((_S661 * _S661 + _S662 * _S662)));
    bool _S663;
    if(tn_0 > slide_cap_0)
    {
        _S663 = tn_0 > 0.0f;
    }
    else
    {
        _S663 = false;
    }
    if(_S663)
    {
        float _S664 = (metal::fast::divide((_S661), (tn_0)));
        float _S665 = (metal::fast::divide((_S662), (tn_0)));
        float dslip_0 = (metal::fast::divide((tn_0 - slide_cap_0), (ks_0)));
        p_12.x = p_12.x + _S664 * dslip_0;
        p_12.y = p_12.y + _S665 * dslip_0;
        (&c_14)->q_lin_1.x = _S664 * slide_cap_0;
        (&c_14)->q_lin_1.y = _S665 * slide_cap_0;
        diss_5 = slide_cap_0 * dslip_0;
    }
    else
    {
        (&c_14)->q_lin_1.x = _S661;
        (&c_14)->q_lin_1.y = _S662;
        diss_5 = 0.0f;
    }
    float2 tq_0 = return_map_0(kt_0, d_ang_0.z, p_12.z, slide_cap_0 * (float4(b_25->geom1_0) ).z);
    float _S666 = tq_0.x;
    float _S667 = tq_0.y;
    float diss_6 = diss_5 + abs(_S666) * abs(_S667);
    p_12.z = p_12.z + _S667;
    (&c_14)->q_ang_1.z = _S666;
    float _S668 = (metal::fast::divide((sq_0((&c_14)->q_lin_1.x)), (ks_0)));
    float _S669 = (metal::fast::divide((sq_0((&c_14)->q_lin_1.y)), (ks_0)));
    float _S670 = _S668 + _S669;
    float _S671 = (metal::fast::divide((sq_0(_S666)), (kt_0)));
    (&c_14)->energy_2 = energy_3 + 0.5f * (_S670 + _S671);
    (&c_14)->diss_4 = diss_6;
    (&c_14)->plastic_1 = p_12;
    return c_14;
}

float3 contact_offsets_0(const JointMaterial_0 constant* mat_5, const JointBond_natural_0 thread* b_26, float crush_3, float3 plastic_3, float3 d_lin_1, float3 d_ang_1)
{
    uint _S672 = mat_5->kind_flags_0.y;
    if((_S672 & 2U) == 0U)
    {
        return plastic_3;
    }
    float4 _S673 = float4(b_26->stiff0_0) ;
    float kn_2 = _S673.x;
    float ks_1 = _S673.y;
    float kt_1 = (float4(b_26->stiff1_0) ).x;
    float4 _S674 = float4(b_26->geom0_0) ;
    float w0_3 = _S674.y;
    float w1_3 = _S674.z;
    float nc_sum_1;
    if((_S672 & 4U) != 0U)
    {
        float4 _S675 = no_tension_patch_0(kn_2 * (1.0f - crush_3), w0_3, w1_3, d_lin_1.z, d_ang_1.x, d_ang_1.y);
        nc_sum_1 = _S675.x;
    }
    else
    {
        float ki_1 = kn_2 * (1.0f - crush_3) / 36.0f;
        float _S676 = d_ang_1.x;
        float _S677 = d_ang_1.y;
        float spread_1 = abs(_S676) * 0.4166666567325592f * w1_3 + abs(_S677) * 0.4166666567325592f * w0_3;
        float _S678 = d_lin_1.z;
        float slack_1 = 9.99999997475242708e-07f * (abs(_S678) + spread_1);
        if((_S678 - spread_1) > slack_1)
        {
            nc_sum_1 = 0.0f;
        }
        else
        {
            if((_S678 + spread_1) < (- slack_1))
            {
                nc_sum_1 = ki_1 * 36.0f * _S678;
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
                    float _S679 = ((float(i_9) + 0.5f) / 6.0f - 0.5f) * w0_3;
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
                        float di_1 = _S678 + _S676 * (((float(j_6) + 0.5f) / 6.0f - 0.5f) * w1_3) - _S677 * _S679;
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
    float _S680 = ks_1 * (d_lin_1.x - plastic_3.x);
    float _S681 = ks_1 * (d_lin_1.y - plastic_3.y);
    float tn_1 = (metal::fast::sqrt((_S680 * _S680 + _S681 * _S681)));
    bool _S682;
    if(tn_1 > slide_cap_1)
    {
        _S682 = tn_1 > 0.0f;
    }
    else
    {
        _S682 = false;
    }
    if(_S682)
    {
        float _S683 = (metal::fast::divide((_S680), (tn_1)));
        float _S684 = (metal::fast::divide((_S681), (tn_1)));
        float dslip_1 = (metal::fast::divide((tn_1 - slide_cap_1), (ks_1)));
        p_13.x = p_13.x + _S683 * dslip_1;
        p_13.y = p_13.y + _S684 * dslip_1;
    }
    float2 tq_1 = return_map_0(kt_1, d_ang_1.z, p_13.z, slide_cap_1 * (float4(b_26->geom1_0) ).z);
    p_13.z = p_13.z + tq_1.y;
    return p_13;
}

float life_rate_0(const JointMaterial_0 constant* mat_6, float s_4)
{
    if(s_4 <= 0.0f)
    {
        return 0.0f;
    }
    float _S685 = mat_6->misc_0.y;
    float _S686 = _S685 + 1.0f;
    float _S687 = (metal::fast::pow((s_4), (_S685)));
    float _S688 = (metal::fast::divide((_S686 * _S687), (mat_6->misc_0.z)));
    return _S688;
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

JointResponse_0 joint_evaluate_0(const JointMaterial_0 constant* mat_7, const JointBond_natural_0 thread* b_27, const JointState_0 thread* state_7, float3 d_lin_2, float3 d_ang_2, float dt_11, bool fracture_1)
{
    float4 _S689 = float4(b_27->stiff0_0) ;
    float kn_3 = _S689.x;
    float ks_2 = _S689.y;
    float kb1_0 = _S689.z;
    float kb2_0 = _S689.w;
    float4 _S690 = float4(b_27->stiff1_0) ;
    float kt_2 = _S690.x;
    bool has_rebar_1 = (_S690.w) != 0.0f;
    uint kind_4 = mat_7->kind_flags_0.x;
    uint flags_1 = mat_7->kind_flags_0.y;
    bool softening_0 = (flags_1 & 1U) != 0U;
    thread JointState_0 st_1 = *state_7;
    bool _S691 = connected_0(state_7, has_rebar_1);
    float3 qe_lin_0 = d_lin_2 * float3(ks_2, ks_2, kn_3);
    float3 qe_ang_0 = d_ang_2 * float3(kb1_0, kb2_0, kt_2);
    Measures_0 _S692 = stress_measures_0(b_27, qe_lin_0, qe_ang_0);
    float _S693 = max(max(_S692.tension_0, _S692.shear_0), _S692.compression_0);
    bool _S694 = dt_11 > 0.0f;
    float dif_1;
    if(_S694)
    {
        float _S695 = (metal::fast::divide((_S693 - (&st_1)->governing_stress_0), (dt_11)));
        float raw_0 = (metal::fast::divide((max(_S695, 0.0f)), (mat_7->misc_0.w)));
        float tau_2 = _S690.z;
        if((flags_1 & 16U) != 0U)
        {
            float _S696 = (metal::fast::divide((dt_11), (tau_2)));
            dif_1 = - expm1_accurate_0(- _S696);
        }
        else
        {
            float _S697 = (metal::fast::divide((dt_11), (tau_2)));
            dif_1 = min(_S697, 1.0f);
        }
        (&st_1)->strain_rate_0 = (&st_1)->strain_rate_0 + (raw_0 - (&st_1)->strain_rate_0) * dif_1;
        (&st_1)->governing_stress_0 = _S693;
    }
    if((flags_1 & 32U) != 0U)
    {
        float _S698 = dif_factor_0(mat_7, (&st_1)->strain_rate_0);
        dif_1 = _S698;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = (float4(b_27->geom1_0) ).w;
    float _S699 = weibull_0 * dif_1;
    float _S700 = fatigue_factor_0(mat_7, (&st_1)->fatigue_0);
    float multiplier_1 = _S699 * _S700;
    thread Measures_0 _S701 = _S692;
    float4 _S702 = failure_indices_0(mat_7, b_27, &_S701, multiplier_1);
    float _S703 = _S702.x;
    float _S704 = _S702.y;
    (&st_1)->utilization_0 = max(max(_S703, _S704), max(_S702.z, _S702.w));
    float _S705 = d_lin_2.x;
    float _S706 = d_lin_2.y;
    float _S707 = ks_2 * (sq_0(_S705) + sq_0(_S706)) + kb1_0 * sq_0(d_ang_2.x) + kb2_0 * sq_0(d_ang_2.y) + kt_2 * sq_0(d_ang_2.z);
    float _S708 = d_lin_2.z;
    bool _S709 = _S708 > 0.0f;
    if(_S709)
    {
        dif_1 = kn_3 * sq_0(_S708);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S707 + dif_1);
    float psi_c_0;
    if(_S708 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_3 * sq_0(_S708);
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
    bool _S710;
    float3 qc_lin_0;
    if(fracture_1)
    {
        bool _S711 = _S703 >= _S704;
        if(_S711)
        {
            diss_contact_0 = _S703;
        }
        else
        {
            diss_contact_0 = _S704;
        }
        uint mode_ts_0;
        if(_S711)
        {
            mode_ts_0 = 1U;
        }
        else
        {
            mode_ts_0 = 2U;
        }
        if(diss_contact_0 > ((&st_1)->kappa_0))
        {
            _S710 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S710 = false;
        }
        if(_S710)
        {
            _S710 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S710 = false;
        }
        uint mode_c_0;
        if(_S710)
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
                float _S712 = (metal::fast::divide((psi_contact_0 * (float4(b_27->geom0_0) ).x * diss_contact_0 * diss_contact_0), (psi_ts_0)));
                intact_normal_0 = _S712;
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
            float _S713 = inc_0.x;
            if(_S713 > ((&st_1)->damage_0))
            {
                Contact_0 _S714 = contact_part_0(mat_7, b_27, (&st_1)->crush_1, plastic_4, d_lin_2, d_ang_2);
                float _S715 = max(_S714.energy_2 - (1.0f - (&st_1)->crush_1) * psi_c_0, 0.0f);
                float _S716 = max(inc_0.y - _S715 * (_S713 - (&st_1)->damage_0), 0.0f);
                float _S717 = max((psi_ts_0 - _S715) * (_S713 - (&st_1)->damage_0) - _S716, 0.0f);
                (&st_1)->damage_0 = _S713;
                (&st_1)->mode_0 = mode_ts_0;
                dissipated_3 = _S716;
                overshoot_1 = _S717;
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
        float _S718 = state_7->damage_0;
        if((state_7->damage_0) > 0.0f)
        {
            Contact_0 _S719 = contact_part_0(mat_7, b_27, state_7->crush_1, float3(state_7->plastic_x_0, state_7->plastic_y_0, state_7->plastic_t_0), d_lin_2, d_ang_2);
            qc_lin_0 = qe_ang_0 * float3((1.0f - _S718))  + _S719.q_ang_1 * float3(_S718) ;
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S720 = stress_measures_0(b_27, float3(0.0f, 0.0f, min(qe_lin_0.z, 0.0f)), qc_lin_0);
        thread Measures_0 _S721 = _S720;
        float4 _S722 = failure_indices_0(mat_7, b_27, &_S721, multiplier_1);
        float _S723 = _S722.z;
        float _S724 = _S722.w;
        bool _S725 = _S723 >= _S724;
        if(_S725)
        {
            psi_contact_0 = _S723;
        }
        else
        {
            psi_contact_0 = _S724;
        }
        if(_S725)
        {
            mode_c_0 = 3U;
        }
        else
        {
            mode_c_0 = 4U;
        }
        if(psi_contact_0 > ((&st_1)->kappa_c_0))
        {
            _S710 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S710 = false;
        }
        if(_S710)
        {
            _S710 = psi_c_0 > 0.0f;
        }
        else
        {
            _S710 = false;
        }
        if(_S710)
        {
            if(softening_0)
            {
                float _S726 = (metal::fast::divide((mat_7->energy_1.w * (float4(b_27->geom0_0) ).x * psi_contact_0 * psi_contact_0), (psi_c_0)));
                intact_normal_0 = _S726;
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
            float _S727 = inc_1.x;
            if(_S727 > ((&st_1)->crush_1))
            {
                float _S728 = inc_1.y;
                float dissipated_4 = dissipated_3 + _S728;
                float overshoot_2 = overshoot_1 + max(psi_c_0 * (_S727 - (&st_1)->crush_1) - _S728, 0.0f);
                (&st_1)->crush_1 = _S727;
                (&st_1)->mode_0 = mode_c_0;
                if(_S727 >= 1.0f)
                {
                    _S710 = ((&st_1)->damage_0) < 1.0f;
                }
                else
                {
                    _S710 = false;
                }
                if(_S710)
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
    float3 _S729 = float3(0.0f) ;
    float3 qc_ang_0;
    if(((&st_1)->damage_0) == 0.0f)
    {
        if((flags_1 & 8U) == 0U)
        {
            float3 _S730 = contact_offsets_0(mat_7, b_27, (&st_1)->crush_1, plastic_4, d_lin_2, d_ang_2);
            (&st_1)->plastic_x_0 = _S730.x;
            (&st_1)->plastic_y_0 = _S730.y;
            (&st_1)->plastic_t_0 = _S730.z;
        }
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S729;
        qc_ang_0 = _S729;
        psi_contact_0 = 0.0f;
    }
    else
    {
        Contact_0 _S731 = contact_part_0(mat_7, b_27, (&st_1)->crush_1, plastic_4, d_lin_2, d_ang_2);
        (&st_1)->plastic_x_0 = _S731.plastic_1.x;
        (&st_1)->plastic_y_0 = _S731.plastic_1.y;
        (&st_1)->plastic_t_0 = _S731.plastic_1.z;
        diss_contact_0 = _S731.diss_4;
        qc_lin_0 = _S731.q_lin_1;
        qc_ang_0 = _S731.q_ang_1;
        psi_contact_0 = _S731.energy_2;
    }
    float dissipated_6 = dissipated_3 + dmg_0 * diss_contact_0;
    if(_S709)
    {
        intact_normal_0 = kn_3 * _S708;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_1)->crush_1) * kn_3 * _S708;
    }
    float _S732 = 1.0f - dmg_0;
    float3 force_lin_2 = float3(_S732 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S732 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S732 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3 force_ang_2 = qe_ang_0 * float3(_S732)  + qc_ang_0 * float3(dmg_0) ;
    float stored_6 = _S732 * (psi_ts_0 + (1.0f - (&st_1)->crush_1) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S710 = ((&st_1)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S710 = false;
    }
    float stored_7;
    float3 force_lin_3;
    if(_S710)
    {
        float4 _S733 = float4(b_27->rebar0_0) ;
        float k_axial_0 = _S733.x;
        float k_dowel_0 = _S733.y;
        float yield_force_0 = _S733.z;
        float dowel_capacity_0 = _S733.w;
        float2 nr_0 = return_map_0(k_axial_0, _S708, (&st_1)->rebar_plastic_0, yield_force_0);
        float2 v1_0 = return_map_0(k_dowel_0, _S705, (&st_1)->rebar_slip0_0, dowel_capacity_0);
        float2 v2_0 = return_map_0(k_dowel_0, _S706, (&st_1)->rebar_slip1_0, dowel_capacity_0);
        float _S734 = nr_0.y;
        float _S735 = v1_0.y;
        float _S736 = v2_0.y;
        float work_0 = yield_force_0 * abs(_S734) + dowel_capacity_0 * (abs(_S735) + abs(_S736));
        (&st_1)->rebar_plastic_0 = (&st_1)->rebar_plastic_0 + _S734;
        (&st_1)->rebar_slip0_0 = (&st_1)->rebar_slip0_0 + _S735;
        (&st_1)->rebar_slip1_0 = (&st_1)->rebar_slip1_0 + _S736;
        (&st_1)->rebar_work_0 = (&st_1)->rebar_work_0 + work_0;
        float dissipated_7 = dissipated_6 + work_0;
        float _S737 = nr_0.x;
        float _S738 = (metal::fast::divide((sq_0(_S737)), (k_axial_0)));
        float _S739 = v1_0.x;
        float _S740 = v2_0.x;
        float _S741 = (metal::fast::divide((sq_0(_S739) + sq_0(_S740)), (k_dowel_0)));
        float elastic_0 = 0.5f * (_S738 + _S741);
        if(fracture_1)
        {
            _S710 = ((&st_1)->rebar_work_0) >= ((float4(b_27->rebar1_0) ).x);
        }
        else
        {
            _S710 = false;
        }
        if(_S710)
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
            force_lin_3 = force_lin_2 + float3(_S739, _S740, _S737);
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
        _S710 = _S694;
    }
    else
    {
        _S710 = false;
    }
    if(_S710)
    {
        _S710 = (flags_1 & 64U) != 0U;
    }
    else
    {
        _S710 = false;
    }
    if(_S710)
    {
        Measures_0 _S742 = stress_measures_0(b_27, force_lin_3, force_ang_2);
        thread Measures_0 _S743 = _S742;
        float4 _S744 = failure_indices_0(mat_7, b_27, &_S743, weibull_0);
        float _S745 = life_rate_0(mat_7, max(max(_S744.x, _S744.y), _S744.z));
        (&st_1)->fatigue_0 = min((&st_1)->fatigue_0 + _S745 * dt_11, 1.0f);
    }
    (&st_1)->dissipated_0 = (&st_1)->dissipated_0 + dissipated_3;
    thread JointResponse_0 resp_0;
    (&resp_0)->force_lin_1 = force_lin_3;
    (&resp_0)->force_ang_1 = force_ang_2;
    (&resp_0)->state_6 = st_1;
    (&resp_0)->dissipated_2 = dissipated_3;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_5 = stored_7;
    if(_S691)
    {
        thread JointState_0 _S746 = st_1;
        bool _S747 = connected_0(&_S746, has_rebar_1);
        _S710 = !_S747;
    }
    else
    {
        _S710 = false;
    }
    (&resp_0)->disconnected_0 = _S710;
    (&resp_0)->measures_0 = _S692;
    return resp_0;
}

void secant_factors_0(const JointBond_natural_0 thread* b_28, const JointState_0 thread* st_2, float3 d_lin_3, float3 thread* f_lin_0, float3 thread* f_ang_0)
{
    float _S748 = st_2->damage_0;
    bool compressed_0 = (d_lin_3.z) < 0.0f;
    float contact_3;
    if(compressed_0)
    {
        contact_3 = _S748;
    }
    else
    {
        contact_3 = 0.0f;
    }
    float _S749 = 1.0f - _S748;
    float _S750 = max(_S749 + contact_3, 9.99999997475242708e-07f);
    float normal_5;
    if(compressed_0)
    {
        normal_5 = max(1.0f - st_2->crush_1, 9.99999997475242708e-07f);
    }
    else
    {
        normal_5 = max(_S749, 9.99999997475242708e-07f);
    }
    *f_lin_0 = float3(_S750, _S750, normal_5);
    *f_ang_0 = float3(_S750) ;
    bool _S751;
    if(((float4(b_28->stiff1_0) ).w) != 0.0f)
    {
        _S751 = (st_2->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S751 = false;
    }
    if(_S751)
    {
        float4 _S752 = float4(b_28->rebar0_0) ;
        float4 _S753 = float4(b_28->stiff0_0) ;
        float _S754 = (metal::fast::divide((_S752.x), (_S753.x)));
        (*f_lin_0).z = (*f_lin_0).z + _S754;
        float _S755 = _S752.y;
        float _S756 = _S753.y;
        float _S757 = (metal::fast::divide((_S755), (_S756)));
        (*f_lin_0).x = (*f_lin_0).x + _S757;
        float _S758 = (metal::fast::divide((_S755), (_S756)));
        (*f_lin_0).y = (*f_lin_0).y + _S758;
    }
    return;
}

bool is_damaged_0(const JointState_0 thread* st_3)
{
    bool _S759;
    if((st_3->damage_0) > 0.0f)
    {
        _S759 = true;
    }
    else
    {
        _S759 = (st_3->crush_1) > 0.0f;
    }
    return _S759;
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

float3 to_local_0(uint _S760, float3 _S761, KernelContext_0 thread* kernelContext_41)
{
    BondStatic_natural_0 device* _S762 = kernelContext_41->bonds_0+_S760;
    return float3(dot(_S761, (float4(_S762->t1_0) ).xyz), dot(_S761, (float4(_S762->t2_0) ).xyz), dot(_S761, (float4(_S762->normal_0) ).xyz));
}

float3 to_body_0(uint _S763, float3 _S764, KernelContext_0 thread* kernelContext_42)
{
    BondStatic_natural_0 device* _S765 = kernelContext_42->bonds_0+_S763;
    return (float4(_S765->t1_0) ).xyz * float3(_S764.x)  + (float4(_S765->t2_0) ).xyz * float3(_S764.y)  + (float4(_S765->normal_0) ).xyz * float3(_S764.z) ;
}

bool bond_update_0(uint i_10, float dt_12, bool fracture_2, uint abs_step_0, KernelContext_0 thread* kernelContext_43)
{
    BondStatic_natural_0 device* _S766 = kernelContext_43->bonds_0+i_10;
    BondDyn_natural_0 device* _S767 = kernelContext_43->bond_dyn_0+i_10;
    float4 _S768 = float4((*_S767).force_lin_0) ;
    float4 _S769 = float4((*_S767).force_ang_0) ;
    float4 _S770 = float4((*_S767).sums_0) ;
    float4 _S771 = float4((*_S767).comps_0) ;
    uint4 _S772 = uint4((*_S767).events_0) ;
    thread BondDyn_0 bd_0;
    (&bd_0)->js_0 = (*_S767).js_0;
    (&bd_0)->force_lin_0 = _S768;
    (&bd_0)->force_ang_0 = _S769;
    (&bd_0)->sums_0 = _S770;
    (&bd_0)->comps_0 = _S771;
    (&bd_0)->events_0 = _S772;
    JointBond_natural_0 _S773 = _S766->law_0;
    thread JointBond_natural_0 _S774 = _S766->law_0;
    uint4 _S775 = uint4((&_S774)->ids_0) ;
    float3 ra_1 = (float4(_S766->ra_0) ).xyz;
    float3 rb_1 = (float4(_S766->rb_0) ).xyz;
    uint _S776 = 4U * _S775.y;
    float3 ta_2 = (float4(*(kernelContext_43->state_0+(_S776 + 1U))) ).xyz;
    float3 va_0 = (float4(*(kernelContext_43->state_0+(_S776 + 2U))) ).xyz;
    float3 wa_1 = (float4(*(kernelContext_43->state_0+(_S776 + 3U))) ).xyz;
    uint _S777 = 4U * _S775.z;
    float3 tb_2 = (float4(*(kernelContext_43->state_0+(_S777 + 1U))) ).xyz;
    float3 vb_0 = (float4(*(kernelContext_43->state_0+(_S777 + 2U))) ).xyz;
    float3 wb_1 = (float4(*(kernelContext_43->state_0+(_S777 + 3U))) ).xyz;
    float3 _S778 = to_local_0(i_10, (float4(*(kernelContext_43->state_0+_S777)) ).xyz + cross(tb_2, rb_1) - ((float4(*(kernelContext_43->state_0+_S776)) ).xyz + cross(ta_2, ra_1)), kernelContext_43);
    float3 _S779 = to_local_0(i_10, tb_2 - ta_2, kernelContext_43);
    float3 _S780 = to_local_0(i_10, vb_0 + cross(wb_1, rb_1) - (va_0 + cross(wa_1, ra_1)), kernelContext_43);
    float3 _S781 = to_local_0(i_10, wb_1 - wa_1, kernelContext_43);
    JointState_0 previous_0 = (&bd_0)->js_0;
    _S774 = _S773;
    thread JointState_0 _S782 = (&bd_0)->js_0;
    JointResponse_0 _S783 = joint_evaluate_0(&kernelContext_43->materials_0->m_0[_S775.x], &_S774, &_S782, _S778, _S779, dt_12, fracture_2);
    thread JointState_0 _S784 = _S783.state_6;
    thread float3 f_lin_1;
    thread float3 f_ang_1;
    secant_factors_0(&_S774, &_S784, _S778, &f_lin_1, &f_ang_1);
    float3 qd_lin_0 = _S780 * (float4(_S766->c_lin_0) ).xyz * f_lin_1;
    float3 qd_ang_0 = _S781 * (float4(_S766->c_ang_0) ).xyz * f_ang_1;
    float3 q_lin_2 = _S783.force_lin_1 + qd_lin_0;
    float3 q_ang_2 = _S783.force_ang_1 + qd_ang_0;
    float damped_0 = (dot(qd_lin_0, _S780) + dot(qd_ang_0, _S781)) * dt_12;
    float3 _S785 = to_body_0(i_10, q_lin_2, kernelContext_43);
    float3 _S786 = to_body_0(i_10, q_ang_2, kernelContext_43);
    uint _S787 = 3U * i_10;
    *(kernelContext_43->scratch_0+_S787) = packed_float4(float4(_S785, max(_S783.measures_0.tension_0, _S783.measures_0.compression_0))) ;
    *(kernelContext_43->scratch_0+(_S787 + 1U)) = packed_float4(float4(_S786 + cross(ra_1, _S785), 0.0f)) ;
    *(kernelContext_43->scratch_0+(_S787 + 2U)) = packed_float4(float4(- _S786 + cross(rb_1, - _S785), 0.0f)) ;
    thread float _S788 = (&bd_0)->sums_0.x;
    thread float _S789 = (&bd_0)->comps_0.x;
    comp_add1_0(&_S788, &_S789, _S783.dissipated_2);
    (&bd_0)->comps_0.x = _S789;
    (&bd_0)->sums_0.x = _S788;
    thread float _S790 = (&bd_0)->sums_0.y;
    thread float _S791 = (&bd_0)->comps_0.y;
    comp_add1_0(&_S790, &_S791, _S783.overshoot_0);
    (&bd_0)->comps_0.y = _S791;
    (&bd_0)->sums_0.y = _S790;
    thread float _S792 = (&bd_0)->sums_0.z;
    thread float _S793 = (&bd_0)->comps_0.z;
    comp_add1_0(&_S792, &_S793, damped_0);
    (&bd_0)->comps_0.z = _S793;
    (&bd_0)->sums_0.z = _S792;
    (&bd_0)->force_lin_0 = float4(q_lin_2, _S783.stored_5);
    (&bd_0)->force_ang_0 = float4(q_ang_2, max((&bd_0)->force_ang_0.w, _S783.state_6.utilization_0));
    thread JointState_0 _S794 = previous_0;
    bool _S795 = is_damaged_0(&_S794);
    bool _S796;
    if(!_S795)
    {
        thread JointState_0 _S797 = _S783.state_6;
        bool _S798 = is_damaged_0(&_S797);
        _S796 = _S798;
    }
    else
    {
        _S796 = false;
    }
    if(_S796)
    {
        _S796 = ((&bd_0)->events_0.x) == 0U;
    }
    else
    {
        _S796 = false;
    }
    if(_S796)
    {
        (&bd_0)->events_0.x = abs_step_0;
        (&bd_0)->events_0.w = _S783.state_6.mode_0;
    }
    if(((&bd_0)->events_0.y) == 0U)
    {
        float _S799 = fatigue_factor_0(&kernelContext_43->materials_0->m_0[_S775.x], previous_0.fatigue_0);
        _S796 = _S799 > 0.99000000953674316f;
    }
    else
    {
        _S796 = false;
    }
    if(_S796)
    {
        float _S800 = fatigue_factor_0(&kernelContext_43->materials_0->m_0[_S775.x], _S783.state_6.fatigue_0);
        _S796 = _S800 <= 0.99000000953674316f;
    }
    else
    {
        _S796 = false;
    }
    if(_S796)
    {
        (&bd_0)->events_0.y = abs_step_0;
    }
    if(_S783.disconnected_0)
    {
        (&bd_0)->events_0.z = abs_step_0;
    }
    (&bd_0)->js_0 = _S783.state_6;
    BondDyn_natural_0 device* _S801 = kernelContext_43->bond_dyn_0+i_10;
    _S801->js_0 = bd_0.js_0;
    _S801->force_lin_0 = packed_float4(bd_0.force_lin_0) ;
    _S801->force_ang_0 = packed_float4(bd_0.force_ang_0) ;
    _S801->sums_0 = packed_float4(bd_0.sums_0) ;
    _S801->comps_0 = packed_float4(bd_0.comps_0) ;
    _S801->events_0 = packed_uint4(bd_0.events_0) ;
    return _S783.disconnected_0;
}

void chunk_update_0(uint c_15, const Island_natural_0 thread* isl_11, const Rigid_0 thread* rg_9, float dt_13, bool rml_0, uint step_0, bool contact_4, float thread* work_1, float thread* work_err_0, KernelContext_0 thread* kernelContext_44)
{
    ChunkStatic_natural_0 device* _S802 = kernelContext_44->chunks_0+c_15;
    float3 _S803 = float3(0.0f) ;
    uint _S804 = kernelContext_44->index_0[c_15];
    float peak_0 = 0.0f;
    uint e_3 = _S804;
    float3 fi_0 = _S803;
    float3 mi_0 = _S803;
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
        uint _S805 = 3U * (entry_2 >> 1U);
        float4 _S806 = float4(*(kernelContext_44->scratch_0+_S805)) ;
        if((entry_2 & 1U) == 0U)
        {
            float3 mi_1 = mi_0 + (float4(*(kernelContext_44->scratch_0+(_S805 + 1U))) ).xyz;
            fi_0 = fi_0 + _S806.xyz;
            mi_0 = mi_1;
        }
        else
        {
            float3 mi_2 = mi_0 + (float4(*(kernelContext_44->scratch_0+(_S805 + 2U))) ).xyz;
            fi_0 = fi_0 + - _S806.xyz;
            mi_0 = mi_2;
        }
        float _S807 = max(peak_0, _S806.w);
        uint _S808 = e_3 + 1U;
        peak_0 = _S807;
        e_3 = _S808;
    }
    uint _S809 = 4U * c_15;
    float3 u_0 = (float4(*(kernelContext_44->state_0+_S809)) ).xyz;
    uint _S810 = _S809 + 1U;
    float3 th_1 = (float4(*(kernelContext_44->state_0+_S810)) ).xyz;
    uint _S811 = _S809 + 2U;
    float3 v_10 = (float4(*(kernelContext_44->state_0+_S811)) ).xyz;
    uint _S812 = _S809 + 3U;
    float3 w_5 = (float4(*(kernelContext_44->state_0+_S812)) ).xyz;
    float4 _S813 = float4(_S802->center_0) ;
    float mass_0 = _S813.w;
    float3 _S814 = _S813.xyz;
    float3 _S815 = (float4(isl_11->com_0) ).xyz;
    float3 _S816 = rotate_0(&rg_9->rot_0, _S814 + u_0 - _S815);
    thread float3 f_load_0;
    thread float3 t_load_0;
    chunk_external_0(c_15, c_15, &rg_9->rot_0, step_0, dt_13, contact_4, &f_load_0, &t_load_0, kernelContext_44);
    record_chunk_load_0(c_15, f_load_0, t_load_0, kernelContext_44);
    float3 _S817 = float3(mass_0) ;
    float3 f_world_0 = f_load_0 + kernelContext_44->params_0->gravity_0.xyz * _S817;
    float3 t_world_0 = t_load_0;
    float3 f_world_1;
    float3 t_world_1;
    if(rml_0)
    {
        float3 f_world_2 = f_world_0 - (rg_9->a_7 + cross(rg_9->alpha_0, _S816) + cross(rg_9->w_4, cross(rg_9->w_4, _S816))) * _S817;
        float4 _S818 = float4(_S802->inertia0_1) ;
        float4 _S819 = float4(_S802->inertia1_1) ;
        float4 _S820 = float4(_S802->inertia2_1) ;
        float3 _S821 = world_mul_0(&rg_9->rot_0, _S818, _S819, _S820, rg_9->alpha_0);
        float3 _S822 = world_mul_0(&rg_9->rot_0, _S818, _S819, _S820, rg_9->w_4);
        float3 t_world_2 = t_world_0 - (_S821 + cross(rg_9->w_4, _S822));
        f_world_1 = f_world_2;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    float3 _S823 = inverse_rotate_0(&rg_9->rot_0, f_world_1);
    float3 _S824 = inverse_rotate_0(&rg_9->rot_0, t_world_1);
    float3 f_ext_0;
    float3 m_ext_0;
    if(rml_0)
    {
        float3 _S825 = inverse_rotate_0(&rg_9->rot_0, rg_9->w_4);
        float4 _S826 = float4(_S802->inertia0_1) ;
        float4 _S827 = float4(_S802->inertia1_1) ;
        float4 _S828 = float4(_S802->inertia2_1) ;
        float3 i_w_0 = rows_mul_0(_S826, _S827, _S828, w_5);
        float3 m_ext_1 = _S824 - (cross(_S825, i_w_0) + cross(w_5, rows_mul_0(_S826, _S827, _S828, _S825)) + cross(w_5, i_w_0));
        f_ext_0 = _S823 - cross(_S825, v_10) * float3((2.0f * mass_0)) ;
        m_ext_0 = m_ext_1;
    }
    else
    {
        f_ext_0 = _S823;
        m_ext_0 = _S824;
    }
    uint4 _S829 = uint4(_S802->load_range_0) ;
    uint term_4 = _S829.x;
    for(;;)
    {
        if(term_4 < (_S829.y))
        {
        }
        else
        {
            break;
        }
        uint _S830 = 5U * term_4;
        if(((as_type<uint4>((float4(*(kernelContext_44->loads_0+_S830)) ))).y) != 2U)
        {
            term_4 = term_4 + 1U;
            continue;
        }
        float _S831 = eval_function_0(term_4, step_0, dt_13, dt_13, kernelContext_44);
        float3 _S832 = float3(_S831) ;
        float3 m_ext_2 = m_ext_0 + (float4(*(kernelContext_44->loads_0+(_S830 + 2U))) ).xyz * _S832;
        f_ext_0 = f_ext_0 + (float4(*(kernelContext_44->loads_0+(_S830 + 1U))) ).xyz * _S832;
        m_ext_0 = m_ext_2;
        term_4 = term_4 + 1U;
    }
    float3 f_13 = f_ext_0 + fi_0;
    float3 m_5 = m_ext_0 + mi_0;
    uint support_0 = (uint4(_S802->info_1) ).x;
    float3 _S833 = float3((float4(*(kernelContext_44->state_0+_S810)) ).w, (float4(*(kernelContext_44->state_0+_S811)) ).w, (float4(*(kernelContext_44->state_0+_S812)) ).w);
    float3 reaction_0;
    float3 u_1;
    float3 th_2;
    float3 v_11;
    float3 w_6;
    if(support_0 == 1U)
    {
        reaction_0 = - f_13;
        u_1 = u_0;
        th_2 = th_1;
        v_11 = _S803;
        w_6 = _S803;
    }
    else
    {
        float4 _S834 = float4(_S802->scale_0) ;
        float3 w_7 = w_5 + rows_mul_0(float4(_S802->inv0_1) , float4(_S802->inv1_1) , float4(_S802->inv2_1) , m_5) * float3((dt_13 * _S834.z)) ;
        float3 _S835 = float3(dt_13) ;
        float3 th_3 = th_1 + w_7 * _S835;
        if(support_0 == 2U)
        {
            reaction_0 = - f_13;
            u_1 = u_0;
            th_2 = _S803;
        }
        else
        {
            float3 v_12 = v_10 + f_13 * float3((dt_13 * _S834.y)) ;
            float3 u_2 = u_0 + v_12 * _S835;
            reaction_0 = _S833;
            u_1 = u_2;
            th_2 = v_12;
        }
        float3 _S836 = th_2;
        th_2 = th_3;
        v_11 = _S836;
        w_6 = w_7;
    }
    *(kernelContext_44->state_0+_S809) = packed_float4(float4(u_1, peak_0)) ;
    *(kernelContext_44->state_0+_S810) = packed_float4(float4(th_2, reaction_0.x)) ;
    *(kernelContext_44->state_0+_S811) = packed_float4(float4(v_11, reaction_0.y)) ;
    *(kernelContext_44->state_0+_S812) = packed_float4(float4(w_6, reaction_0.z)) ;
    float3 _S837 = rotate_0(&rg_9->rot_0, _S814 + u_1 - _S815);
    float3 _S838 = rg_9->vel_1 + rg_9->vel_err_1 + cross(rg_9->w_4, _S837);
    float3 _S839 = rotate_0(&rg_9->rot_0, v_11);
    float3 v_world_0 = _S838 + _S839;
    float3 _S840 = rotate_0(&rg_9->rot_0, w_6);
    comp_add1_0(work_1, work_err_0, (dot(f_load_0, v_world_0) + dot(t_load_0, rg_9->w_4 + _S840)) * dt_13);
    return;
}

void chunk_update_1(uint c_16, const Island_0 thread* isl_12, const Rigid_0 thread* rg_10, float dt_14, bool rml_1, uint step_1, bool contact_5, float thread* work_2, float thread* work_err_1, KernelContext_0 thread* kernelContext_45)
{
    ChunkStatic_natural_0 device* _S841 = kernelContext_45->chunks_0+c_16;
    float3 _S842 = float3(0.0f) ;
    uint _S843 = kernelContext_45->index_0[c_16];
    float peak_1 = 0.0f;
    uint e_4 = _S843;
    float3 fi_1 = _S842;
    float3 mi_3 = _S842;
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
        uint _S844 = 3U * (entry_3 >> 1U);
        float4 _S845 = float4(*(kernelContext_45->scratch_0+_S844)) ;
        if((entry_3 & 1U) == 0U)
        {
            float3 mi_4 = mi_3 + (float4(*(kernelContext_45->scratch_0+(_S844 + 1U))) ).xyz;
            fi_1 = fi_1 + _S845.xyz;
            mi_3 = mi_4;
        }
        else
        {
            float3 mi_5 = mi_3 + (float4(*(kernelContext_45->scratch_0+(_S844 + 2U))) ).xyz;
            fi_1 = fi_1 + - _S845.xyz;
            mi_3 = mi_5;
        }
        float _S846 = max(peak_1, _S845.w);
        uint _S847 = e_4 + 1U;
        peak_1 = _S846;
        e_4 = _S847;
    }
    uint _S848 = 4U * c_16;
    float3 u_3 = (float4(*(kernelContext_45->state_0+_S848)) ).xyz;
    uint _S849 = _S848 + 1U;
    float3 th_4 = (float4(*(kernelContext_45->state_0+_S849)) ).xyz;
    uint _S850 = _S848 + 2U;
    float3 v_13 = (float4(*(kernelContext_45->state_0+_S850)) ).xyz;
    uint _S851 = _S848 + 3U;
    float3 w_8 = (float4(*(kernelContext_45->state_0+_S851)) ).xyz;
    float4 _S852 = float4(_S841->center_0) ;
    float mass_1 = _S852.w;
    float3 _S853 = _S852.xyz;
    float3 _S854 = isl_12->com_0.xyz;
    float3 _S855 = rotate_0(&rg_10->rot_0, _S853 + u_3 - _S854);
    thread float3 f_load_1;
    thread float3 t_load_1;
    chunk_external_0(c_16, c_16, &rg_10->rot_0, step_1, dt_14, contact_5, &f_load_1, &t_load_1, kernelContext_45);
    record_chunk_load_0(c_16, f_load_1, t_load_1, kernelContext_45);
    float3 _S856 = float3(mass_1) ;
    float3 f_world_3 = f_load_1 + kernelContext_45->params_0->gravity_0.xyz * _S856;
    float3 t_world_3 = t_load_1;
    float3 f_world_4;
    float3 t_world_4;
    if(rml_1)
    {
        float3 f_world_5 = f_world_3 - (rg_10->a_7 + cross(rg_10->alpha_0, _S855) + cross(rg_10->w_4, cross(rg_10->w_4, _S855))) * _S856;
        float4 _S857 = float4(_S841->inertia0_1) ;
        float4 _S858 = float4(_S841->inertia1_1) ;
        float4 _S859 = float4(_S841->inertia2_1) ;
        float3 _S860 = world_mul_0(&rg_10->rot_0, _S857, _S858, _S859, rg_10->alpha_0);
        float3 _S861 = world_mul_0(&rg_10->rot_0, _S857, _S858, _S859, rg_10->w_4);
        float3 t_world_5 = t_world_3 - (_S860 + cross(rg_10->w_4, _S861));
        f_world_4 = f_world_5;
        t_world_4 = t_world_5;
    }
    else
    {
        f_world_4 = f_world_3;
        t_world_4 = t_world_3;
    }
    float3 _S862 = inverse_rotate_0(&rg_10->rot_0, f_world_4);
    float3 _S863 = inverse_rotate_0(&rg_10->rot_0, t_world_4);
    float3 f_ext_1;
    float3 m_ext_3;
    if(rml_1)
    {
        float3 _S864 = inverse_rotate_0(&rg_10->rot_0, rg_10->w_4);
        float4 _S865 = float4(_S841->inertia0_1) ;
        float4 _S866 = float4(_S841->inertia1_1) ;
        float4 _S867 = float4(_S841->inertia2_1) ;
        float3 i_w_1 = rows_mul_0(_S865, _S866, _S867, w_8);
        float3 m_ext_4 = _S863 - (cross(_S864, i_w_1) + cross(w_8, rows_mul_0(_S865, _S866, _S867, _S864)) + cross(w_8, i_w_1));
        f_ext_1 = _S862 - cross(_S864, v_13) * float3((2.0f * mass_1)) ;
        m_ext_3 = m_ext_4;
    }
    else
    {
        f_ext_1 = _S862;
        m_ext_3 = _S863;
    }
    uint4 _S868 = uint4(_S841->load_range_0) ;
    uint term_5 = _S868.x;
    for(;;)
    {
        if(term_5 < (_S868.y))
        {
        }
        else
        {
            break;
        }
        uint _S869 = 5U * term_5;
        if(((as_type<uint4>((float4(*(kernelContext_45->loads_0+_S869)) ))).y) != 2U)
        {
            term_5 = term_5 + 1U;
            continue;
        }
        float _S870 = eval_function_0(term_5, step_1, dt_14, dt_14, kernelContext_45);
        float3 _S871 = float3(_S870) ;
        float3 m_ext_5 = m_ext_3 + (float4(*(kernelContext_45->loads_0+(_S869 + 2U))) ).xyz * _S871;
        f_ext_1 = f_ext_1 + (float4(*(kernelContext_45->loads_0+(_S869 + 1U))) ).xyz * _S871;
        m_ext_3 = m_ext_5;
        term_5 = term_5 + 1U;
    }
    float3 f_14 = f_ext_1 + fi_1;
    float3 m_6 = m_ext_3 + mi_3;
    uint support_1 = (uint4(_S841->info_1) ).x;
    float3 _S872 = float3((float4(*(kernelContext_45->state_0+_S849)) ).w, (float4(*(kernelContext_45->state_0+_S850)) ).w, (float4(*(kernelContext_45->state_0+_S851)) ).w);
    float3 reaction_1;
    float3 u_4;
    float3 th_5;
    float3 v_14;
    float3 w_9;
    if(support_1 == 1U)
    {
        reaction_1 = - f_14;
        u_4 = u_3;
        th_5 = th_4;
        v_14 = _S842;
        w_9 = _S842;
    }
    else
    {
        float4 _S873 = float4(_S841->scale_0) ;
        float3 w_10 = w_8 + rows_mul_0(float4(_S841->inv0_1) , float4(_S841->inv1_1) , float4(_S841->inv2_1) , m_6) * float3((dt_14 * _S873.z)) ;
        float3 _S874 = float3(dt_14) ;
        float3 th_6 = th_4 + w_10 * _S874;
        if(support_1 == 2U)
        {
            reaction_1 = - f_14;
            u_4 = u_3;
            th_5 = _S842;
        }
        else
        {
            float3 v_15 = v_13 + f_14 * float3((dt_14 * _S873.y)) ;
            float3 u_5 = u_3 + v_15 * _S874;
            reaction_1 = _S872;
            u_4 = u_5;
            th_5 = v_15;
        }
        float3 _S875 = th_5;
        th_5 = th_6;
        v_14 = _S875;
        w_9 = w_10;
    }
    *(kernelContext_45->state_0+_S848) = packed_float4(float4(u_4, peak_1)) ;
    *(kernelContext_45->state_0+_S849) = packed_float4(float4(th_5, reaction_1.x)) ;
    *(kernelContext_45->state_0+_S850) = packed_float4(float4(v_14, reaction_1.y)) ;
    *(kernelContext_45->state_0+_S851) = packed_float4(float4(w_9, reaction_1.z)) ;
    float3 _S876 = rotate_0(&rg_10->rot_0, _S853 + u_4 - _S854);
    float3 _S877 = rg_10->vel_1 + rg_10->vel_err_1 + cross(rg_10->w_4, _S876);
    float3 _S878 = rotate_0(&rg_10->rot_0, v_14);
    float3 v_world_1 = _S877 + _S878;
    float3 _S879 = rotate_0(&rg_10->rot_0, w_9);
    comp_add1_0(work_2, work_err_1, (dot(f_load_1, v_world_1) + dot(t_load_1, rg_10->w_4 + _S879)) * dt_14);
    return;
}

void drift_moments_0(uint c_17, float3 thread* tu_0, float3 thread* pv_0, KernelContext_0 thread* kernelContext_46)
{
    ChunkStatic_natural_0 device* _S880 = kernelContext_46->chunks_0+c_17;
    uint _S881 = 4U * c_17;
    float3 _S882 = float3(((float4(_S880->center_0) ).w * (float4(_S880->scale_0) ).x)) ;
    *tu_0 = *tu_0 + (float4(*(kernelContext_46->state_0+_S881)) ).xyz * _S882;
    *pv_0 = *pv_0 + (float4(*(kernelContext_46->state_0+(_S881 + 2U))) ).xyz * _S882;
    return;
}

void drift_angular_0(uint c_18, float3 wcom_1, float3 tr_0, float3 dv_0, float3 thread* lu_0, float3 thread* lv_0, KernelContext_0 thread* kernelContext_47)
{
    ChunkStatic_natural_0 device* _S883 = kernelContext_47->chunks_0+c_18;
    float4 _S884 = float4(_S883->center_0) ;
    float3 r_11 = _S884.xyz - wcom_1;
    uint _S885 = 4U * c_18;
    float3 _S886 = float3(_S884.w) ;
    float4 _S887 = float4(_S883->inertia0_1) ;
    float4 _S888 = float4(_S883->inertia1_1) ;
    float4 _S889 = float4(_S883->inertia2_1) ;
    float3 _S890 = float3((float4(_S883->scale_0) ).x) ;
    *lu_0 = *lu_0 + (cross(r_11, (float4(*(kernelContext_47->state_0+_S885)) ).xyz - tr_0) * _S886 + rows_mul_0(_S887, _S888, _S889, (float4(*(kernelContext_47->state_0+(_S885 + 1U))) ).xyz)) * _S890;
    *lv_0 = *lv_0 + (cross(r_11, (float4(*(kernelContext_47->state_0+(_S885 + 2U))) ).xyz - dv_0) * _S886 + rows_mul_0(_S887, _S888, _S889, (float4(*(kernelContext_47->state_0+(_S885 + 3U))) ).xyz)) * _S890;
    return;
}

void drift_apply_0(uint c_19, float3 wcom_2, float3 tr_1, float3 phi_0, float3 dv_1, float3 dw_0, KernelContext_0 thread* kernelContext_48)
{
    float3 r_12 = (float4((kernelContext_48->chunks_0+c_19)->center_0) ).xyz - wcom_2;
    uint _S891 = 4U * c_19;
    *(kernelContext_48->state_0+_S891) = packed_float4(float4((float4(*(kernelContext_48->state_0+_S891)) ).xyz - (tr_1 + cross(phi_0, r_12)), (float4(*(kernelContext_48->state_0+_S891)) ).w)) ;
    uint _S892 = _S891 + 1U;
    *(kernelContext_48->state_0+_S892) = packed_float4(float4((float4(*(kernelContext_48->state_0+_S892)) ).xyz - phi_0, (float4(*(kernelContext_48->state_0+_S892)) ).w)) ;
    uint _S893 = _S891 + 2U;
    *(kernelContext_48->state_0+_S893) = packed_float4(float4((float4(*(kernelContext_48->state_0+_S893)) ).xyz - (dv_1 + cross(dw_0, r_12)), (float4(*(kernelContext_48->state_0+_S893)) ).w)) ;
    uint _S894 = _S891 + 3U;
    *(kernelContext_48->state_0+_S894) = packed_float4(float4((float4(*(kernelContext_48->state_0+_S894)) ).xyz - dw_0, (float4(*(kernelContext_48->state_0+_S894)) ).w)) ;
    return;
}

void drift_rigid_0(const Island_natural_0 thread* isl_13, Rigid_0 thread* rg_11, float3 tr_2, float3 phi_1, float3 dv_2, float3 dw_1)
{
    float3 wcom_3 = (float4(isl_13->wcom_0) ).xyz;
    Quat_0 rot_2 = rg_11->rot_0;
    float3 _S895 = tr_2 - cross(phi_1, wcom_3);
    thread Quat_0 _S896 = rg_11->rot_0;
    float3 _S897 = rotate_0(&_S896, _S895);
    comp_add_0(&rg_11->pos_1, &rg_11->pos_err_1, _S897);
    Quat_0 _S898 = from_axis_angle_0(phi_1, length(phi_1));
    thread Quat_0 _S899 = rg_11->rot_0;
    thread Quat_0 _S900 = _S898;
    Quat_0 _S901 = quat_mul_0(&_S899, &_S900);
    thread Quat_0 _S902 = _S901;
    Quat_0 _S903 = normalized_0(&_S902);
    rg_11->rot_0 = _S903;
    float3 _S904 = dv_2 + cross(dw_1, (float4(isl_13->com_0) ).xyz - wcom_3);
    thread Quat_0 _S905 = rot_2;
    float3 _S906 = rotate_0(&_S905, _S904);
    comp_add_0(&rg_11->vel_1, &rg_11->vel_err_1, _S906);
    thread Quat_0 _S907 = rot_2;
    float3 _S908 = rotate_0(&_S907, dw_1);
    rg_11->w_4 = rg_11->w_4 + _S908;
    return;
}

void drift_rigid_1(const Island_0 thread* isl_14, Rigid_0 thread* rg_12, float3 tr_3, float3 phi_2, float3 dv_3, float3 dw_2)
{
    float3 wcom_4 = isl_14->wcom_0.xyz;
    Quat_0 rot_3 = rg_12->rot_0;
    float3 _S909 = tr_3 - cross(phi_2, wcom_4);
    thread Quat_0 _S910 = rg_12->rot_0;
    float3 _S911 = rotate_0(&_S910, _S909);
    comp_add_0(&rg_12->pos_1, &rg_12->pos_err_1, _S911);
    Quat_0 _S912 = from_axis_angle_0(phi_2, length(phi_2));
    thread Quat_0 _S913 = rg_12->rot_0;
    thread Quat_0 _S914 = _S912;
    Quat_0 _S915 = quat_mul_0(&_S913, &_S914);
    thread Quat_0 _S916 = _S915;
    Quat_0 _S917 = normalized_0(&_S916);
    rg_12->rot_0 = _S917;
    float3 _S918 = dv_3 + cross(dw_2, isl_14->com_0.xyz - wcom_4);
    thread Quat_0 _S919 = rot_3;
    float3 _S920 = rotate_0(&_S919, _S918);
    comp_add_0(&rg_12->vel_1, &rg_12->vel_err_1, _S920);
    thread Quat_0 _S921 = rot_3;
    float3 _S922 = rotate_0(&_S921, dw_2);
    rg_12->w_4 = rg_12->w_4 + _S922;
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
    bool driven_0 = (((&isl_15)->info_0.x) & 2U) != 0U;
    bool _S947 = !((((&isl_15)->info_0.x) & 1U) != 0U);
    bool _S948;
    if(_S947)
    {
        _S948 = !driven_0;
    }
    else
    {
        _S948 = false;
    }
    bool contact_island_0 = (((&isl_15)->info_0.x) & 4U) != 0U;
    bool _S949 = (((&isl_15)->info_0.x) & 16U) != 0U;
    bool _S950 = tid_4 == 0U;
    bool settled_0;
    uint run_0;
    if(_S950)
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
            thread Island_0 _S951 = isl_15;
            bool _S952 = contact_stopped_1(&_S951, &kernelContext_50);
            settled_0 = _S952;
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
    float _S953 = (&kernelContext_50)->params_0->dt_0;
    bool _S954 = ((&kernelContext_50)->params_0->fracture_0) != 0U;
    bool _S955 = ((&kernelContext_50)->params_0->rigid_motion_loads_0) != 0U;
    thread Island_0 _S956 = isl_15;
    Rigid_0 _S957 = rigid_of_1(&_S956);
    thread Rigid_0 rg_13 = _S957;
    thread float work_3 = 0.0f;
    thread float work_err_2 = 0.0f;
    settled_0 = _S949;
    uint done_1 = 0U;
    bool woke_1 = false;
    uint s_5 = 0U;
    for(;;)
    {
        if(s_5 < run_0)
        {
        }
        else
        {
            woke_0 = woke_1;
            break;
        }
        uint abs_step_1 = (&isl_15)->info_0.w + s_5 + 1U;
        uint k_20 = abs_step_1 - 1U - (&kernelContext_50)->params_0->step_start_0;
        bool _S958;
        bool settled_1;
        if((((&isl_15)->info_0.x) & 32U) != 0U)
        {
            if(_S950)
            {
                _S958 = ((&isl_15)->probes_0.y) > ((&isl_15)->probes_0.x);
            }
            else
            {
                _S958 = false;
            }
            if(_S958)
            {
                thread Island_0 _S959 = isl_15;
                thread Rigid_0 _S960 = rg_13;
                record_probes_0(&_S959, &_S960, k_20, &kernelContext_50);
            }
            uint _S961 = s_5 + 1U;
            settled_1 = settled_0;
            done_1 = _S961;
            woke_0 = woke_1;
            uint _S962 = s_5 + 1U;
            settled_0 = settled_1;
            woke_1 = woke_0;
            s_5 = _S962;
            continue;
        }
        uint i_11;
        if(settled_0)
        {
            float3 _S963 = float3(0.0f) ;
            thread float3 norm_0 = _S963;
            thread float3 unused0_0 = _S963;
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
                thread Quat_0 _S964 = (&rg_13)->rot_0;
                float _S965 = settled_chunk_load_0(i_11, &_S964, k_20, _S953, contact_island_0, &kernelContext_50);
                norm_0.x = norm_0.x + _S965;
                i_11 = i_11 + 256U;
            }
            group_sum3_0(tid_4, &norm_0, &unused0_0, &kernelContext_50);
            if(((&kernelContext_50)->params_0->solve_mode_0) == 1U)
            {
                _S958 = (abs(norm_0.x - (&isl_15)->energy_0.z)) > ((&isl_15)->energy_0.w);
            }
            else
            {
                _S958 = false;
            }
            if(_S958)
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
        if(_S947)
        {
            float3 _S966 = float3(0.0f) ;
            thread float3 f_15 = _S966;
            thread float3 t_13 = _S966;
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
                thread Island_0 _S967 = isl_15;
                thread Rigid_0 _S968 = rg_13;
                net_load_1(i_11, &_S967, &_S968, k_20, _S953, contact_island_0, &f_15, &t_13, &kernelContext_50);
                i_11 = i_11 + 256U;
            }
            group_sum3_0(tid_4, &f_15, &t_13, &kernelContext_50);
            thread Island_0 _S969 = isl_15;
            rigid_acceleration_1(&_S969, &rg_13, f_15, t_13);
        }
        if(settled_1)
        {
            if(_S948)
            {
                thread Island_0 _S970 = isl_15;
                integrate_rigid_1(&_S970, &rg_13, _S953);
            }
            if(_S950)
            {
                _S958 = ((&isl_15)->probes_0.y) > ((&isl_15)->probes_0.x);
            }
            else
            {
                _S958 = false;
            }
            if(_S958)
            {
                thread Island_0 _S971 = isl_15;
                thread Rigid_0 _S972 = rg_13;
                record_probes_0(&_S971, &_S972, k_20, &kernelContext_50);
            }
            done_1 = s_5 + 1U;
            uint _S962 = s_5 + 1U;
            settled_0 = settled_1;
            woke_1 = woke_0;
            s_5 = _S962;
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
            bool _S973 = bond_update_0(i_11, _S953, _S954, abs_step_1, &kernelContext_50);
            if(_S973)
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
            thread Island_0 _S974 = isl_15;
            thread Rigid_0 _S975 = rg_13;
            chunk_update_1(c_20, &_S974, &_S975, _S953, _S955, k_20, contact_island_0, &work_3, &work_err_2, &kernelContext_50);
            c_20 = c_20 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        if(_S948)
        {
            thread Island_0 _S976 = isl_15;
            integrate_rigid_1(&_S976, &rg_13, _S953);
        }
        if(_S947)
        {
            float3 _S977 = (&isl_15)->wcom_0.xyz;
            float3 _S978 = float3(0.0f) ;
            thread float3 tu_1 = _S978;
            thread float3 pv_1 = _S978;
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
            thread float3 lu_1 = _S978;
            thread float3 lv_1 = _S978;
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
                drift_angular_0(c_22, _S977, tr_4, dv_4, &lu_1, &lv_1, &kernelContext_50);
                c_22 = c_22 + 256U;
            }
            group_sum3_0(tid_4, &lu_1, &lv_1, &kernelContext_50);
            float3 phi_3 = rows_mul_0((&isl_15)->winv0_0, (&isl_15)->winv1_0, (&isl_15)->winv2_0, lu_1);
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
                drift_apply_0(c_23, _S977, tr_4, phi_3, dv_4, dw_3, &kernelContext_50);
                c_23 = c_23 + 256U;
            }
            if(!driven_0)
            {
                thread Island_0 _S979 = isl_15;
                drift_rigid_1(&_S979, &rg_13, tr_4, phi_3, dv_4, dw_3);
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        }
        if(_S950)
        {
            _S958 = ((&isl_15)->probes_0.y) > ((&isl_15)->probes_0.x);
        }
        else
        {
            _S958 = false;
        }
        if(_S958)
        {
            thread Island_0 _S980 = isl_15;
            thread Rigid_0 _S981 = rg_13;
            record_probes_0(&_S980, &_S981, k_20, &kernelContext_50);
        }
        uint _S982 = s_5 + 1U;
        if((*(&kernelContext_50)->g_halt_0) != 0U)
        {
            done_1 = _S982;
            break;
        }
        done_1 = _S982;
        uint _S962 = s_5 + 1U;
        settled_0 = settled_1;
        woke_1 = woke_0;
        s_5 = _S962;
    }
    thread float3 wsum_0 = float3(work_3, work_err_2, 0.0f);
    thread float3 unused_2 = float3(0.0f) ;
    group_sum3_0(tid_4, &wsum_0, &unused_2, &kernelContext_50);
    if(_S950)
    {
        thread Quat_0 _S983 = (&rg_13)->rot_0;
        float4 _S984 = quat_vec_0(&_S983);
        (&isl_15)->rotation_0 = _S984;
        (&isl_15)->position_0 = float4((&rg_13)->pos_1, 0.0f);
        (&isl_15)->position_err_0 = float4((&rg_13)->pos_err_1, 0.0f);
        (&isl_15)->velocity_0 = float4((&rg_13)->vel_1, 0.0f);
        (&isl_15)->velocity_err_0 = float4((&rg_13)->vel_err_1, 0.0f);
        (&isl_15)->angular_velocity_0 = float4((&rg_13)->w_4, 0.0f);
        (&isl_15)->done_0.x = done_1;
        (&isl_15)->info_0.y = (&isl_15)->info_0.y - done_1;
        if((*(&kernelContext_50)->g_halt_0) != 0U)
        {
            _S948 = contact_island_0;
        }
        else
        {
            _S948 = false;
        }
        if(_S948)
        {
            contact_split_at_0((&isl_15)->info_0.w + done_1, &kernelContext_50);
        }
        float _S985 = wsum_0.x;
        thread float _S986 = (&isl_15)->energy_0.x;
        thread float _S987 = (&isl_15)->energy_0.y;
        comp_add1_0(&_S986, &_S987, _S985);
        (&isl_15)->energy_0.x = _S986;
        (&isl_15)->energy_0.y = _S987 + wsum_0.y;
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
        Island_natural_0 device* _S988 = (&kernelContext_50)->islands_0+_S924;
        _S988->range_0 = packed_uint4(isl_15.range_0) ;
        _S988->info_0 = packed_uint4(isl_15.info_0) ;
        _S988->com_0 = packed_float4(isl_15.com_0) ;
        _S988->inertia0_0 = packed_float4(isl_15.inertia0_0) ;
        _S988->inertia1_0 = packed_float4(isl_15.inertia1_0) ;
        _S988->inertia2_0 = packed_float4(isl_15.inertia2_0) ;
        _S988->inv0_0 = packed_float4(isl_15.inv0_0) ;
        _S988->inv1_0 = packed_float4(isl_15.inv1_0) ;
        _S988->inv2_0 = packed_float4(isl_15.inv2_0) ;
        _S988->wcom_0 = packed_float4(isl_15.wcom_0) ;
        _S988->winv0_0 = packed_float4(isl_15.winv0_0) ;
        _S988->winv1_0 = packed_float4(isl_15.winv1_0) ;
        _S988->winv2_0 = packed_float4(isl_15.winv2_0) ;
        _S988->rotation_0 = packed_float4(isl_15.rotation_0) ;
        _S988->position_0 = packed_float4(isl_15.position_0) ;
        _S988->position_err_0 = packed_float4(isl_15.position_err_0) ;
        _S988->velocity_0 = packed_float4(isl_15.velocity_0) ;
        _S988->velocity_err_0 = packed_float4(isl_15.velocity_err_0) ;
        _S988->angular_velocity_0 = packed_float4(isl_15.angular_velocity_0) ;
        _S988->done_0 = packed_uint4(isl_15.done_0) ;
        _S988->probes_0 = packed_uint4(isl_15.probes_0) ;
        _S988->energy_0 = packed_float4(isl_15.energy_0) ;
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
    uint _S989 = table_0 + 4U * g_2;
    (&w_11)->island_0 = kernelContext_51->index_0[_S989];
    (&w_11)->begin_1 = kernelContext_51->index_0[_S989 + 1U];
    (&w_11)->end_0 = kernelContext_51->index_0[_S989 + 2U];
    (&w_11)->first_0 = kernelContext_51->index_0[_S989 + 3U];
    return w_11;
}

bool wide_runs_0(const Island_natural_0 thread* isl_16, KernelContext_0 thread* kernelContext_52)
{
    uint4 _S990 = uint4(isl_16->info_0) ;
    bool _S991;
    if(((_S990.z) & 1U) != 0U)
    {
        _S991 = true;
    }
    else
    {
        _S991 = (_S990.y) == 0U;
    }
    if(_S991)
    {
        return false;
    }
    if(((_S990.x) & 4U) == 0U)
    {
        _S991 = true;
    }
    else
    {
        bool _S992 = contact_stopped_0(isl_16, kernelContext_52);
        _S991 = !_S992;
    }
    return _S991;
}

bool wide_enter_0(uint tid_5, const Island_natural_0 thread* isl_17, KernelContext_0 thread* kernelContext_53)
{
    if(tid_5 == 0U)
    {
        bool _S993 = wide_runs_0(isl_17, kernelContext_53);
        int _S994;
        if(_S993)
        {
            _S994 = int(1);
        }
        else
        {
            _S994 = int(0);
        }
        *kernelContext_53->g_wide_run_0 = uint(_S994);
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

bool contact_stopped_2(uint _S995, KernelContext_0 thread* kernelContext_56)
{
    Island_natural_0 device* _S996 = kernelContext_56->islands_0+_S995;
    uint4 _S997 = uint4((kernelContext_56->islands_0+kernelContext_56->params_0->halt_index_0)->info_0) ;
    bool _S998;
    if(((_S997.z) & 1U) != 0U)
    {
        _S998 = true;
    }
    else
    {
        uint _S999 = _S997.y;
        if(_S999 != 0U)
        {
            _S998 = _S999 <= ((uint4(_S996->info_0) ).w);
        }
        else
        {
            _S998 = false;
        }
    }
    return _S998;
}

bool wide_runs_1(uint _S1000, KernelContext_0 thread* kernelContext_57)
{
    uint4 _S1001 = uint4((kernelContext_57->islands_0+_S1000)->info_0) ;
    bool _S1002;
    if(((_S1001.z) & 1U) != 0U)
    {
        _S1002 = true;
    }
    else
    {
        _S1002 = (_S1001.y) == 0U;
    }
    if(_S1002)
    {
        return false;
    }
    if(((_S1001.x) & 4U) == 0U)
    {
        _S1002 = true;
    }
    else
    {
        bool _S1003 = contact_stopped_2(_S1000, kernelContext_57);
        _S1002 = !_S1003;
    }
    return _S1002;
}

bool wide_enter_1(uint _S1004, uint _S1005, KernelContext_0 thread* kernelContext_58)
{
    if(_S1004 == 0U)
    {
        bool _S1006 = wide_runs_1(_S1005, kernelContext_58);
        int _S1007;
        if(_S1006)
        {
            _S1007 = int(1);
        }
        else
        {
            _S1007 = int(0);
        }
        *kernelContext_58->g_wide_run_0 = uint(_S1007);
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
    uint _S1008 = group_3.x;
    WideGroup_0 _S1009 = wide_group_0(params_7->wide_chunk_table_0, _S1008, &kernelContext_59);
    if(_S1008 != (_S1009.first_0))
    {
        return;
    }
    thread Island_natural_0 _S1010 = *((&kernelContext_59)->islands_0+_S1009.island_0);
    uint4 _S1011 = uint4((&_S1010)->info_0) ;
    uint _S1012 = _S1011.x;
    bool _S1013;
    if((_S1012 & 16U) == 0U)
    {
        _S1013 = true;
    }
    else
    {
        bool _S1014 = wide_enter_1(tid_6, _S1009.island_0, &kernelContext_59);
        _S1013 = !_S1014;
    }
    if(_S1013)
    {
        return;
    }
    Quat_0 _S1015 = quat_of_0(float4((&_S1010)->rotation_0) );
    bool _S1016 = (_S1012 & 4U) != 0U;
    float3 _S1017 = float3(0.0f) ;
    thread float3 norm_1 = _S1017;
    thread float3 unused_3 = _S1017;
    uint4 _S1018 = uint4((&_S1010)->range_0) ;
    uint c_24 = _S1018.x + tid_6;
    for(;;)
    {
        if(c_24 < (_S1018.y))
        {
        }
        else
        {
            break;
        }
        uint _S1019 = wide_step_0(&_S1010, &kernelContext_59);
        float _S1020 = (&kernelContext_59)->params_0->dt_0;
        thread Quat_0 _S1021 = _S1015;
        float _S1022 = settled_chunk_load_0(c_24, &_S1021, _S1019, _S1020, _S1016, &kernelContext_59);
        norm_1.x = norm_1.x + _S1022;
        c_24 = c_24 + 256U;
    }
    group_sum3_0(tid_6, &norm_1, &unused_3, &kernelContext_59);
    if(tid_6 == 0U)
    {
        _S1013 = ((&kernelContext_59)->params_0->solve_mode_0) == 1U;
    }
    else
    {
        _S1013 = false;
    }
    if(_S1013)
    {
        float4 _S1023 = float4((&_S1010)->energy_0) ;
        _S1013 = (abs(norm_1.x - _S1023.z)) > (_S1023.w);
    }
    else
    {
        _S1013 = false;
    }
    if(_S1013)
    {
        ((&kernelContext_59)->islands_0+_S1009.island_0)->info_0[int(0)] = _S1012 & 4294967279U;
        ((&kernelContext_59)->islands_0+_S1009.island_0)->info_0[int(2)] = (_S1011.z) | 4U;
    }
    return;
}

void wide_store_0(uint slot_2, uint p_14, float3 a_11, float3 b_29, KernelContext_0 thread* kernelContext_60)
{
    uint _S1024 = 8U * slot_2;
    *(kernelContext_60->scratch_0+(kernelContext_60->params_0->wide_base_0 + _S1024 + p_14)) = packed_float4(float4(a_11, 0.0f)) ;
    *(kernelContext_60->scratch_0+(kernelContext_60->params_0->wide_base_0 + _S1024 + p_14 + 1U)) = packed_float4(float4(b_29, 0.0f)) ;
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
    uint _S1025 = group_4.x;
    bool bond_group_0 = _S1025 < (params_8->wide_bond_groups_0);
    WideGroup_0 wg_0;
    if(bond_group_0)
    {
        WideGroup_0 _S1026 = wide_group_0((&kernelContext_61)->params_0->wide_bond_table_0, _S1025, &kernelContext_61);
        wg_0 = _S1026;
    }
    else
    {
        WideGroup_0 _S1027 = wide_group_0((&kernelContext_61)->params_0->wide_chunk_table_0, _S1025 - params_8->wide_bond_groups_0, &kernelContext_61);
        wg_0 = _S1027;
    }
    WideGroup_0 _S1028 = wg_0;
    thread Island_natural_0 _S1029 = *((&kernelContext_61)->islands_0+wg_0.island_0);
    bool _S1030 = wide_enter_1(tid_7, wg_0.island_0, &kernelContext_61);
    if(!_S1030)
    {
        return;
    }
    uint _S1031 = wide_step_0(&_S1029, &kernelContext_61);
    if(bond_group_0)
    {
        uint4 _S1032 = uint4((&_S1029)->info_0) ;
        if(((_S1032.x) & 16U) != 0U)
        {
            return;
        }
        uint i_12 = wg_0.begin_1 + tid_7;
        bool _S1033;
        if(i_12 < (wg_0.end_0))
        {
            bool _S1034 = bond_update_0(i_12, (&kernelContext_61)->params_0->dt_0, ((&kernelContext_61)->params_0->fracture_0) != 0U, _S1032.w + 1U, &kernelContext_61);
            _S1033 = _S1034;
        }
        else
        {
            _S1033 = false;
        }
        if(_S1033)
        {
            ((&kernelContext_61)->islands_0+_S1028.island_0)->info_0[int(2)] = (_S1032.z) | 2U;
        }
        return;
    }
    uint _S1035 = (uint4((&_S1029)->info_0) ).x;
    if((_S1035 & 1U) != 0U)
    {
        return;
    }
    float3 _S1036 = float3(0.0f) ;
    thread float3 f_16 = _S1036;
    thread float3 t_14 = _S1036;
    uint c_25 = wg_0.begin_1 + tid_7;
    if(c_25 < (wg_0.end_0))
    {
        Rigid_0 _S1037 = rigid_of_0(&_S1029);
        float _S1038 = (&kernelContext_61)->params_0->dt_0;
        bool _S1039 = (_S1035 & 4U) != 0U;
        thread Rigid_0 _S1040 = _S1037;
        net_load_0(c_25, &_S1029, &_S1040, _S1031, _S1038, _S1039, &f_16, &t_14, &kernelContext_61);
    }
    group_sum3_0(tid_7, &f_16, &t_14, &kernelContext_61);
    if(tid_7 == 0U)
    {
        wide_store_0(_S1025 - params_8->wide_bond_groups_0, 0U, f_16, t_14, &kernelContext_61);
    }
    return;
}

void wide_partials_0(uint tid_8, uint first_1, uint count_5, uint p_15, float3 thread* a_12, float3 thread* b_30, KernelContext_0 thread* kernelContext_62)
{
    float4 _S1041 = float4(0.0f) ;
    thread float4 x_8 = _S1041;
    thread float4 y_2 = _S1041;
    uint s_6 = tid_8;
    for(;;)
    {
        if(s_6 < count_5)
        {
        }
        else
        {
            break;
        }
        uint _S1042 = 8U * (first_1 + s_6);
        x_8 = x_8 + float4(*(kernelContext_62->scratch_0+(kernelContext_62->params_0->wide_base_0 + _S1042 + p_15))) ;
        y_2 = y_2 + float4(*(kernelContext_62->scratch_0+(kernelContext_62->params_0->wide_base_0 + _S1042 + p_15 + 1U))) ;
        s_6 = s_6 + 256U;
    }
    group_sum2_0(tid_8, &x_8, &y_2, kernelContext_62);
    *a_12 = x_8.xyz;
    *b_30 = y_2.xyz;
    return;
}

Rigid_0 wide_rigid_frame_0(uint tid_9, const Island_natural_0 thread* isl_20, const WideGroup_0 thread* wg_1, KernelContext_0 thread* kernelContext_63)
{
    Rigid_0 _S1043 = rigid_of_0(isl_20);
    thread Rigid_0 rg_14 = _S1043;
    if((((uint4(isl_20->info_0) ).x) & 1U) == 0U)
    {
        thread float3 f_17;
        thread float3 t_15;
        wide_partials_0(tid_9, wg_1->first_0, (uint4(isl_20->done_0) ).z, 0U, &f_17, &t_15, kernelContext_63);
        rigid_acceleration_0(isl_20, &rg_14, f_17, t_15);
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
    uint _S1044 = group_5.x;
    WideGroup_0 _S1045 = wide_group_0(params_9->wide_chunk_table_0, _S1044, &kernelContext_64);
    thread Island_natural_0 _S1046 = *((&kernelContext_64)->islands_0+_S1045.island_0);
    bool _S1047 = wide_enter_1(tid_10, _S1045.island_0, &kernelContext_64);
    if(!_S1047)
    {
        return;
    }
    uint _S1048 = (uint4((&_S1046)->info_0) ).x;
    bool anchored_0 = (_S1048 & 1U) != 0U;
    if((_S1048 & 16U) != 0U)
    {
        if(tid_10 == 0U)
        {
            *((&kernelContext_64)->scratch_0+((&kernelContext_64)->params_0->wide_base_0 + 8U * _S1044 + 6U)) = packed_float4(float4(0.0f) ) ;
        }
        return;
    }
    thread WideGroup_0 _S1049 = _S1045;
    Rigid_0 _S1050 = wide_rigid_frame_0(tid_10, &_S1046, &_S1049, &kernelContext_64);
    thread float work_4 = 0.0f;
    thread float work_err_3 = 0.0f;
    float3 _S1051 = float3(0.0f) ;
    thread float3 tu_2 = _S1051;
    thread float3 pv_2 = _S1051;
    uint c_26 = _S1045.begin_1 + tid_10;
    if(c_26 < (_S1045.end_0))
    {
        float _S1052 = (&kernelContext_64)->params_0->dt_0;
        bool _S1053 = ((&kernelContext_64)->params_0->rigid_motion_loads_0) != 0U;
        uint _S1054 = wide_step_0(&_S1046, &kernelContext_64);
        bool _S1055 = (_S1048 & 4U) != 0U;
        thread Rigid_0 _S1056 = _S1050;
        chunk_update_0(c_26, &_S1046, &_S1056, _S1052, _S1053, _S1054, _S1055, &work_4, &work_err_3, &kernelContext_64);
        if(!anchored_0)
        {
            drift_moments_0(c_26, &tu_2, &pv_2, &kernelContext_64);
        }
    }
    thread float3 wsum_1 = float3(work_4, work_err_3, 0.0f);
    thread float3 unused_4 = _S1051;
    group_sum3_0(tid_10, &wsum_1, &unused_4, &kernelContext_64);
    bool _S1057 = !anchored_0;
    if(_S1057)
    {
        group_sum3_0(tid_10, &tu_2, &pv_2, &kernelContext_64);
    }
    if(tid_10 == 0U)
    {
        *((&kernelContext_64)->scratch_0+((&kernelContext_64)->params_0->wide_base_0 + 8U * _S1044 + 6U)) = packed_float4(float4(wsum_1, 0.0f)) ;
        if(_S1057)
        {
            wide_store_0(_S1044, 2U, tu_2, pv_2, &kernelContext_64);
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
    uint _S1058 = group_6.x;
    WideGroup_0 _S1059 = wide_group_0(params_10->wide_chunk_table_0, _S1058, &kernelContext_65);
    Island_natural_0 device* _S1060 = (&kernelContext_65)->islands_0+_S1059.island_0;
    Island_natural_0 isl_21 = *_S1060;
    bool _S1061;
    if((((uint4((*_S1060).info_0) ).x) & 17U) != 0U)
    {
        _S1061 = true;
    }
    else
    {
        bool _S1062 = wide_enter_1(tid_11, _S1059.island_0, &kernelContext_65);
        _S1061 = !_S1062;
    }
    if(_S1061)
    {
        return;
    }
    thread float3 tu_3;
    thread float3 pv_3;
    wide_partials_0(tid_11, _S1059.first_0, (uint4(isl_21.done_0) ).z, 2U, &tu_3, &pv_3, &kernelContext_65);
    float4 _S1063 = float4(isl_21.wcom_0) ;
    float3 _S1064 = float3(_S1063.w) ;
    float3 tr_5 = tu_3 / _S1064;
    float3 dv_5 = pv_3 / _S1064;
    float3 _S1065 = float3(0.0f) ;
    thread float3 lu_2 = _S1065;
    thread float3 lv_2 = _S1065;
    uint c_27 = _S1059.begin_1 + tid_11;
    if(c_27 < (_S1059.end_0))
    {
        drift_angular_0(c_27, _S1063.xyz, tr_5, dv_5, &lu_2, &lv_2, &kernelContext_65);
    }
    group_sum3_0(tid_11, &lu_2, &lv_2, &kernelContext_65);
    if(tid_11 == 0U)
    {
        wide_store_0(_S1058, 4U, lu_2, lv_2, &kernelContext_65);
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
    uint _S1066 = group_7.x;
    WideGroup_0 _S1067 = wide_group_0(params_11->wide_chunk_table_0, _S1066, &kernelContext_66);
    thread Island_natural_0 _S1068 = *((&kernelContext_66)->islands_0+_S1067.island_0);
    uint _S1069 = (uint4((&_S1068)->info_0) ).x;
    bool _S1070;
    if((_S1069 & 1U) != 0U)
    {
        _S1070 = true;
    }
    else
    {
        bool _S1071 = wide_enter_1(tid_12, _S1067.island_0, &kernelContext_66);
        _S1070 = !_S1071;
    }
    if(_S1070)
    {
        return;
    }
    if((_S1069 & 16U) != 0U)
    {
        if(_S1066 != (_S1067.first_0))
        {
            return;
        }
        thread WideGroup_0 _S1072 = _S1067;
        Rigid_0 _S1073 = wide_rigid_frame_0(tid_12, &_S1068, &_S1072, &kernelContext_66);
        thread Rigid_0 rs_0 = _S1073;
        if(tid_12 != 0U)
        {
            _S1070 = true;
        }
        else
        {
            _S1070 = (_S1069 & 2U) != 0U;
        }
        if(_S1070)
        {
            return;
        }
        integrate_rigid_0(&_S1068, &rs_0, (&kernelContext_66)->params_0->dt_0);
        thread Quat_0 _S1074 = (&rs_0)->rot_0;
        float4 _S1075 = quat_vec_0(&_S1074);
        ((&kernelContext_66)->islands_0+_S1067.island_0)->rotation_0 = packed_float4(_S1075) ;
        ((&kernelContext_66)->islands_0+_S1067.island_0)->position_0 = packed_float4(float4((&rs_0)->pos_1, 0.0f)) ;
        ((&kernelContext_66)->islands_0+_S1067.island_0)->position_err_0 = packed_float4(float4((&rs_0)->pos_err_1, 0.0f)) ;
        ((&kernelContext_66)->islands_0+_S1067.island_0)->velocity_0 = packed_float4(float4((&rs_0)->vel_1, 0.0f)) ;
        ((&kernelContext_66)->islands_0+_S1067.island_0)->velocity_err_0 = packed_float4(float4((&rs_0)->vel_err_1, 0.0f)) ;
        ((&kernelContext_66)->islands_0+_S1067.island_0)->angular_velocity_0 = packed_float4(float4((&rs_0)->w_4, 0.0f)) ;
        return;
    }
    uint _S1076 = (uint4((&_S1068)->done_0) ).z;
    thread float3 tu_4;
    thread float3 pv_4;
    wide_partials_0(tid_12, _S1067.first_0, _S1076, 2U, &tu_4, &pv_4, &kernelContext_66);
    thread float3 lu_3;
    thread float3 lv_3;
    wide_partials_0(tid_12, _S1067.first_0, _S1076, 4U, &lu_3, &lv_3, &kernelContext_66);
    float4 _S1077 = float4((&_S1068)->wcom_0) ;
    float3 _S1078 = float3(_S1077.w) ;
    float3 tr_6 = tu_4 / _S1078;
    float3 dv_6 = pv_4 / _S1078;
    float4 _S1079 = float4((&_S1068)->winv0_0) ;
    float4 _S1080 = float4((&_S1068)->winv1_0) ;
    float4 _S1081 = float4((&_S1068)->winv2_0) ;
    float3 phi_4 = rows_mul_0(_S1079, _S1080, _S1081, lu_3);
    float3 dw_4 = rows_mul_0(_S1079, _S1080, _S1081, lv_3);
    uint c_28 = _S1067.begin_1 + tid_12;
    if(c_28 < (_S1067.end_0))
    {
        drift_apply_0(c_28, _S1077.xyz, tr_6, phi_4, dv_6, dw_4, &kernelContext_66);
    }
    if(_S1066 != (_S1067.first_0))
    {
        return;
    }
    thread WideGroup_0 _S1082 = _S1067;
    Rigid_0 _S1083 = wide_rigid_frame_0(tid_12, &_S1068, &_S1082, &kernelContext_66);
    thread Rigid_0 rg_15 = _S1083;
    if(tid_12 != 0U)
    {
        return;
    }
    if(!((_S1069 & 2U) != 0U))
    {
        integrate_rigid_0(&_S1068, &rg_15, (&kernelContext_66)->params_0->dt_0);
        drift_rigid_0(&_S1068, &rg_15, tr_6, phi_4, dv_6, dw_4);
    }
    thread Quat_0 _S1084 = (&rg_15)->rot_0;
    float4 _S1085 = quat_vec_0(&_S1084);
    ((&kernelContext_66)->islands_0+_S1067.island_0)->rotation_0 = packed_float4(_S1085) ;
    ((&kernelContext_66)->islands_0+_S1067.island_0)->position_0 = packed_float4(float4((&rg_15)->pos_1, 0.0f)) ;
    ((&kernelContext_66)->islands_0+_S1067.island_0)->position_err_0 = packed_float4(float4((&rg_15)->pos_err_1, 0.0f)) ;
    ((&kernelContext_66)->islands_0+_S1067.island_0)->velocity_0 = packed_float4(float4((&rg_15)->vel_1, 0.0f)) ;
    ((&kernelContext_66)->islands_0+_S1067.island_0)->velocity_err_0 = packed_float4(float4((&rg_15)->vel_err_1, 0.0f)) ;
    ((&kernelContext_66)->islands_0+_S1067.island_0)->angular_velocity_0 = packed_float4(float4((&rg_15)->w_4, 0.0f)) ;
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
    uint _S1086 = group_8.x;
    WideGroup_0 _S1087 = wide_group_0(params_12->wide_chunk_table_0, _S1086, &kernelContext_67);
    if(_S1086 != (_S1087.first_0))
    {
        return;
    }
    Island_natural_0 device* _S1088 = (&kernelContext_67)->islands_0+_S1087.island_0;
    thread Island_natural_0 _S1089 = *_S1088;
    uint4 _S1090 = uint4((&_S1089)->info_0) ;
    float4 _S1091 = float4((&_S1089)->com_0) ;
    float4 _S1092 = float4((&_S1089)->inertia0_0) ;
    float4 _S1093 = float4((&_S1089)->inertia1_0) ;
    float4 _S1094 = float4((&_S1089)->inertia2_0) ;
    float4 _S1095 = float4((&_S1089)->inv0_0) ;
    float4 _S1096 = float4((&_S1089)->inv1_0) ;
    float4 _S1097 = float4((&_S1089)->inv2_0) ;
    float4 _S1098 = float4((&_S1089)->wcom_0) ;
    float4 _S1099 = float4((&_S1089)->winv0_0) ;
    float4 _S1100 = float4((&_S1089)->winv1_0) ;
    float4 _S1101 = float4((&_S1089)->winv2_0) ;
    float4 _S1102 = float4((&_S1089)->rotation_0) ;
    float4 _S1103 = float4((&_S1089)->position_0) ;
    float4 _S1104 = float4((&_S1089)->position_err_0) ;
    float4 _S1105 = float4((&_S1089)->velocity_0) ;
    float4 _S1106 = float4((&_S1089)->velocity_err_0) ;
    float4 _S1107 = float4((&_S1089)->angular_velocity_0) ;
    uint4 _S1108 = uint4((&_S1089)->done_0) ;
    uint4 _S1109 = uint4((&_S1089)->probes_0) ;
    float4 _S1110 = float4((&_S1089)->energy_0) ;
    thread Island_0 isl_22;
    (&isl_22)->range_0 = uint4((&_S1089)->range_0) ;
    (&isl_22)->info_0 = _S1090;
    (&isl_22)->com_0 = _S1091;
    (&isl_22)->inertia0_0 = _S1092;
    (&isl_22)->inertia1_0 = _S1093;
    (&isl_22)->inertia2_0 = _S1094;
    (&isl_22)->inv0_0 = _S1095;
    (&isl_22)->inv1_0 = _S1096;
    (&isl_22)->inv2_0 = _S1097;
    (&isl_22)->wcom_0 = _S1098;
    (&isl_22)->winv0_0 = _S1099;
    (&isl_22)->winv1_0 = _S1100;
    (&isl_22)->winv2_0 = _S1101;
    (&isl_22)->rotation_0 = _S1102;
    (&isl_22)->position_0 = _S1103;
    (&isl_22)->position_err_0 = _S1104;
    (&isl_22)->velocity_0 = _S1105;
    (&isl_22)->velocity_err_0 = _S1106;
    (&isl_22)->angular_velocity_0 = _S1107;
    (&isl_22)->done_0 = _S1108;
    (&isl_22)->probes_0 = _S1109;
    (&isl_22)->energy_0 = _S1110;
    _S1089 = *_S1088;
    bool _S1111 = wide_enter_0(tid_13, &_S1089, &kernelContext_67);
    if(!_S1111)
    {
        return;
    }
    thread float3 work_5;
    thread float3 unused_5;
    wide_partials_0(tid_13, _S1087.first_0, (&isl_22)->done_0.z, 6U, &work_5, &unused_5, &kernelContext_67);
    if(tid_13 != 0U)
    {
        return;
    }
    thread Island_0 _S1112 = isl_22;
    uint _S1113 = wide_step_1(&_S1112, &kernelContext_67);
    if(((&isl_22)->probes_0.y) > ((&isl_22)->probes_0.x))
    {
        thread Island_0 _S1114 = isl_22;
        Rigid_0 _S1115 = rigid_of_1(&_S1114);
        thread Island_0 _S1116 = isl_22;
        thread Rigid_0 _S1117 = _S1115;
        record_probes_0(&_S1116, &_S1117, _S1113, &kernelContext_67);
    }
    bool halt_0 = (((&isl_22)->info_0.z) & 2U) != 0U;
    bool _S1118;
    if(halt_0)
    {
        _S1118 = (((&isl_22)->info_0.x) & 4U) != 0U;
    }
    else
    {
        _S1118 = false;
    }
    if(_S1118)
    {
        contact_split_at_0((&isl_22)->info_0.w + 1U, &kernelContext_67);
    }
    float _S1119 = work_5.x;
    thread float _S1120 = (&isl_22)->energy_0.x;
    thread float _S1121 = (&isl_22)->energy_0.y;
    comp_add1_0(&_S1120, &_S1121, _S1119);
    (&isl_22)->energy_0.x = _S1120;
    (&isl_22)->energy_0.y = _S1121 + work_5.y;
    (&isl_22)->done_0.x = (&isl_22)->done_0.x + 1U;
    (&isl_22)->info_0.y = (&isl_22)->info_0.y - 1U;
    (&isl_22)->info_0.w = (&isl_22)->info_0.w + 1U;
    if(halt_0)
    {
        (&isl_22)->info_0.z = (((&isl_22)->info_0.z) & 4294967293U) | 1U;
    }
    Island_natural_0 device* _S1122 = (&kernelContext_67)->islands_0+_S1087.island_0;
    _S1122->range_0 = packed_uint4(isl_22.range_0) ;
    _S1122->info_0 = packed_uint4(isl_22.info_0) ;
    _S1122->com_0 = packed_float4(isl_22.com_0) ;
    _S1122->inertia0_0 = packed_float4(isl_22.inertia0_0) ;
    _S1122->inertia1_0 = packed_float4(isl_22.inertia1_0) ;
    _S1122->inertia2_0 = packed_float4(isl_22.inertia2_0) ;
    _S1122->inv0_0 = packed_float4(isl_22.inv0_0) ;
    _S1122->inv1_0 = packed_float4(isl_22.inv1_0) ;
    _S1122->inv2_0 = packed_float4(isl_22.inv2_0) ;
    _S1122->wcom_0 = packed_float4(isl_22.wcom_0) ;
    _S1122->winv0_0 = packed_float4(isl_22.winv0_0) ;
    _S1122->winv1_0 = packed_float4(isl_22.winv1_0) ;
    _S1122->winv2_0 = packed_float4(isl_22.winv2_0) ;
    _S1122->rotation_0 = packed_float4(isl_22.rotation_0) ;
    _S1122->position_0 = packed_float4(isl_22.position_0) ;
    _S1122->position_err_0 = packed_float4(isl_22.position_err_0) ;
    _S1122->velocity_0 = packed_float4(isl_22.velocity_0) ;
    _S1122->velocity_err_0 = packed_float4(isl_22.velocity_err_0) ;
    _S1122->angular_velocity_0 = packed_float4(isl_22.angular_velocity_0) ;
    _S1122->done_0 = packed_uint4(isl_22.done_0) ;
    _S1122->probes_0 = packed_uint4(isl_22.probes_0) ;
    _S1122->energy_0 = packed_float4(isl_22.energy_0) ;
    return;
}

uint sv_0(uint c_29, uint slot_3, KernelContext_0 thread* kernelContext_68)
{
    return kernelContext_68->params_0->statics_base_0 + 23U * c_29 + slot_3;
}

void project_load_slot_0(uint tid_14, const Island_natural_0 thread* isl_23, uint slot_4, KernelContext_0 thread* kernelContext_69)
{
    uint _S1123;
    float3 _S1124 = float3(0.0f) ;
    thread float3 net_f_0 = _S1124;
    thread float3 net_m_0 = _S1124;
    uint4 _S1125 = uint4(isl_23->range_0) ;
    uint _S1126 = _S1125.x + tid_14;
    uint c_30 = _S1126;
    for(;;)
    {
        uint _S1127 = _S1125.y;
        _S1123 = _S1127;
        if(c_30 < _S1127)
        {
        }
        else
        {
            break;
        }
        uint _S1128 = sv_0(c_30, slot_4, kernelContext_69);
        float3 fi_2 = (float4(*(kernelContext_69->scratch_0+_S1128)) ).xyz;
        net_f_0 = net_f_0 + fi_2;
        float3 _S1129 = cross((float4((kernelContext_69->chunks_0+c_30)->center_0) ).xyz - (float4(isl_23->com_0) ).xyz, fi_2);
        uint _S1130 = sv_0(c_30, slot_4 + 1U, kernelContext_69);
        net_m_0 = net_m_0 + (_S1129 + (float4(*(kernelContext_69->scratch_0+_S1130)) ).xyz);
        c_30 = c_30 + 256U;
    }
    group_sum3_0(tid_14, &net_f_0, &net_m_0, kernelContext_69);
    float4 _S1131 = float4(isl_23->com_0) ;
    float3 _S1132 = net_f_0 / float3(_S1131.w) ;
    float3 _S1133 = rows_mul_0(float4(isl_23->inv0_0) , float4(isl_23->inv1_0) , float4(isl_23->inv2_0) , net_m_0);
    c_30 = _S1126;
    for(;;)
    {
        if(c_30 < _S1123)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_natural_0 device* _S1134 = kernelContext_69->chunks_0+c_30;
        float4 _S1135 = float4(_S1134->center_0) ;
        float3 r_13 = _S1135.xyz - _S1131.xyz;
        uint _S1136 = sv_0(c_30, slot_4, kernelContext_69);
        *(kernelContext_69->scratch_0+_S1136) = packed_float4(float4((float4(*(kernelContext_69->scratch_0+_S1136)) ).xyz - (_S1132 + cross(_S1133, r_13)) * float3(_S1135.w) , 0.0f)) ;
        uint _S1137 = sv_0(c_30, slot_4 + 1U, kernelContext_69);
        *(kernelContext_69->scratch_0+_S1137) = packed_float4(float4((float4(*(kernelContext_69->scratch_0+_S1137)) ).xyz - rows_mul_0(float4(_S1134->inertia0_1) , float4(_S1134->inertia1_1) , float4(_S1134->inertia2_1) , _S1133), 0.0f)) ;
        c_30 = c_30 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    return;
}

float island_dot_0(uint tid_15, uint c0_0, uint c1_0, uint sa_2, uint sb_2, KernelContext_0 thread* kernelContext_70)
{
    float4 _S1138 = float4(0.0f) ;
    thread float4 acc_0 = _S1138;
    thread float4 unused_6 = _S1138;
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
        uint _S1139 = sv_0(c_31, sa_2, kernelContext_70);
        float3 _S1140 = (float4(*(kernelContext_70->scratch_0+_S1139)) ).xyz;
        uint _S1141 = sv_0(c_31, sb_2, kernelContext_70);
        float _S1142 = dot(_S1140, (float4(*(kernelContext_70->scratch_0+_S1141)) ).xyz);
        uint _S1143 = sv_0(c_31, sa_2 + 1U, kernelContext_70);
        float3 _S1144 = (float4(*(kernelContext_70->scratch_0+_S1143)) ).xyz;
        uint _S1145 = sv_0(c_31, sb_2 + 1U, kernelContext_70);
        acc_0.x = acc_0.x + (_S1142 + dot(_S1144, (float4(*(kernelContext_70->scratch_0+_S1145)) ).xyz));
        c_31 = c_31 + 256U;
    }
    group_sum2_0(tid_15, &acc_0, &unused_6, kernelContext_70);
    return acc_0.x;
}

void static_kinematics_0(uint _S1146, float3 thread* _S1147, float3 thread* _S1148, KernelContext_0 thread* kernelContext_71)
{
    BondStatic_natural_0 device* _S1149 = kernelContext_71->bonds_0+_S1146;
    uint4 _S1150 = uint4(_S1149->law_0.ids_0) ;
    uint ca_1 = _S1150.y;
    uint cb_1 = _S1150.z;
    uint _S1151 = 4U * cb_1;
    uint _S1152 = 4U * ca_1;
    float3 _S1153 = (float4(*(kernelContext_71->state_0+_S1151)) ).xyz - (float4(*(kernelContext_71->state_0+_S1152)) ).xyz;
    uint _S1154 = sv_0(cb_1, 21U, kernelContext_71);
    float3 _S1155 = (float4(*(kernelContext_71->scratch_0+_S1154)) ).xyz;
    uint _S1156 = sv_0(ca_1, 21U, kernelContext_71);
    float3 du_0 = _S1153 + (_S1155 - (float4(*(kernelContext_71->scratch_0+_S1156)) ).xyz);
    uint _S1157 = _S1151 + 1U;
    uint _S1158 = _S1152 + 1U;
    float3 _S1159 = (float4(*(kernelContext_71->state_0+_S1157)) ).xyz - (float4(*(kernelContext_71->state_0+_S1158)) ).xyz;
    uint _S1160 = sv_0(cb_1, 22U, kernelContext_71);
    float3 _S1161 = (float4(*(kernelContext_71->scratch_0+_S1160)) ).xyz;
    uint _S1162 = sv_0(ca_1, 22U, kernelContext_71);
    float3 dth_0 = _S1159 + (_S1161 - (float4(*(kernelContext_71->scratch_0+_S1162)) ).xyz);
    float3 _S1163 = to_local_0(_S1146, du_0 + (cross((float4(*(kernelContext_71->state_0+_S1157)) ).xyz + (float4(*(kernelContext_71->scratch_0+_S1160)) ).xyz, (float4(_S1149->rb_0) ).xyz) - cross((float4(*(kernelContext_71->state_0+_S1158)) ).xyz + (float4(*(kernelContext_71->scratch_0+_S1162)) ).xyz, (float4(_S1149->ra_0) ).xyz)), kernelContext_71);
    *_S1147 = _S1163;
    float3 _S1164 = to_local_0(_S1146, dth_0, kernelContext_71);
    *_S1148 = _S1164;
    return;
}

JointResponse_0 static_response_0(uint i_13, KernelContext_0 thread* kernelContext_72)
{
    BondStatic_natural_0 device* _S1165 = kernelContext_72->bonds_0+i_13;
    thread float3 d_lin_4;
    thread float3 d_ang_3;
    static_kinematics_0(i_13, &d_lin_4, &d_ang_3, kernelContext_72);
    thread JointBond_natural_0 _S1166 = _S1165->law_0;
    _S1166 = _S1165->law_0;
    thread JointState_0 _S1167 = (kernelContext_72->bond_dyn_0+i_13)->js_0;
    JointResponse_0 _S1168 = joint_evaluate_0(&kernelContext_72->materials_0->m_0[(uint4((&_S1166)->ids_0) ).x], &_S1166, &_S1167, d_lin_4, d_ang_3, 0.0f, false);
    return _S1168;
}

void gather_loads_0(uint c_32, float3 thread* fi_3, float3 thread* mi_6, KernelContext_0 thread* kernelContext_73)
{
    float3 _S1169 = float3(0.0f) ;
    *fi_3 = _S1169;
    *mi_6 = _S1169;
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
            uint _S1170 = 3U * bond_0;
            *fi_3 = *fi_3 + (float4(*(kernelContext_73->scratch_0+_S1170)) ).xyz;
            *mi_6 = *mi_6 + (float4(*(kernelContext_73->scratch_0+(_S1170 + 1U))) ).xyz;
        }
        else
        {
            uint _S1171 = 3U * bond_0;
            *fi_3 = *fi_3 - (float4(*(kernelContext_73->scratch_0+_S1171)) ).xyz;
            *mi_6 = *mi_6 + (float4(*(kernelContext_73->scratch_0+(_S1171 + 2U))) ).xyz;
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
        uint _S1172 = 3U * (entry_5 >> 1U);
        float3 f_18 = (float4(*(kernelContext_74->scratch_0+_S1172)) ).xyz;
        float3 t_16;
        if((entry_5 & 1U) == 0U)
        {
            t_16 = (float4(*(kernelContext_74->scratch_0+(_S1172 + 1U))) ).xyz;
        }
        else
        {
            t_16 = (float4(*(kernelContext_74->scratch_0+(_S1172 + 2U))) ).xyz;
        }
        float m_8 = m_7 + (dot(f_18, f_18) + dot(t_16, t_16));
        e_6 = e_6 + 1U;
        m_7 = m_8;
    }
    return m_7;
}

uint fixed_mask_0(uint c_34, KernelContext_0 thread* kernelContext_75)
{
    uint support_2 = (uint4((kernelContext_75->chunks_0+c_34)->info_1) ).x;
    uint _S1173;
    if(support_2 == 1U)
    {
        _S1173 = 63U;
    }
    else
    {
        if(support_2 == 2U)
        {
            _S1173 = 7U;
        }
        else
        {
            _S1173 = 0U;
        }
    }
    return _S1173;
}

void hold_0(uint mask_0, float4 thread* lin_0, float4 thread* ang_0, float4 keep_lin_0, float4 keep_ang_0)
{
    uint d_12 = 0U;
    for(;;)
    {
        if(d_12 < 3U)
        {
        }
        else
        {
            break;
        }
        if((mask_0 & (1U << d_12)) != 0U)
        {
            (*lin_0)[d_12] = keep_lin_0[d_12];
        }
        if((mask_0 & (1U << (d_12 + 3U))) != 0U)
        {
            (*ang_0)[d_12] = keep_ang_0[d_12];
        }
        d_12 = d_12 + 1U;
    }
    return;
}

uint statics_bond_slot_0(uint i_14, KernelContext_0 thread* kernelContext_76)
{
    return kernelContext_76->params_0->statics_base_0 + 23U * kernelContext_76->params_0->chunk_count_0 + 2U * i_14;
}

void store_inverse_0(uint c_35, const array<float, int(36)> thread* a_13, KernelContext_0 thread* kernelContext_77)
{
    uint j_7;
    float sum_2;
    thread array<float, int(36)> l_4;
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
        l_4[k_21] = 0.0f;
        k_21 = k_21 + 1U;
    }
    bool spd_0 = true;
    uint i_15 = 0U;
    for(;;)
    {
        bool _S1174;
        if(i_15 < 6U)
        {
            _S1174 = spd_0;
        }
        else
        {
            _S1174 = false;
        }
        if(_S1174)
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
            uint _S1175 = i_15 * 6U;
            uint _S1176 = _S1175 + j_7;
            k_21 = 0U;
            sum_2 = (*a_13)[_S1176];
            for(;;)
            {
                if(k_21 < j_7)
                {
                }
                else
                {
                    break;
                }
                float sum_3 = sum_2 - l_4[_S1175 + k_21] * l_4[j_7 * 6U + k_21];
                k_21 = k_21 + 1U;
                sum_2 = sum_3;
            }
            if(i_15 == j_7)
            {
                if(sum_2 <= 0.0f)
                {
                    spd_0 = false;
                    break;
                }
                l_4[_S1175 + i_15] = sqrt(sum_2);
            }
            else
            {
                l_4[_S1176] = sum_2 / l_4[j_7 * 6U + j_7];
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
            uint _S1177 = k_21 * 6U + k_21;
            float _S1178 = (*a_13)[_S1177];
            if(((*a_13)[_S1177]) > 0.0f)
            {
                sum_2 = 1.0f / _S1178;
            }
            else
            {
                sum_2 = 0.0f;
            }
            inv_0[_S1177] = sum_2;
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
                    sum_2 = 1.0f;
                }
                else
                {
                    sum_2 = 0.0f;
                }
                k_21 = 0U;
                float s_7 = sum_2;
                for(;;)
                {
                    if(k_21 < i_15)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_8 = s_7 - l_4[i_15 * 6U + k_21] * y_3[k_21];
                    k_21 = k_21 + 1U;
                    s_7 = s_8;
                }
                y_3[i_15] = s_7 / l_4[i_15 * 6U + i_15];
                i_15 = i_15 + 1U;
            }
            thread array<float, int(6)> x_9;
            x_9[int(0)] = 0.0f;
            x_9[int(1)] = 0.0f;
            x_9[int(2)] = 0.0f;
            x_9[int(3)] = 0.0f;
            x_9[int(4)] = 0.0f;
            x_9[int(5)] = 0.0f;
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
                sum_2 = y_3[i_16];
                for(;;)
                {
                    if(k_21 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_9 = sum_2 - l_4[k_21 * 6U + i_16] * x_9[k_21];
                    k_21 = k_21 + 1U;
                    sum_2 = s_9;
                }
                x_9[i_16] = sum_2 / l_4[i_16 * 6U + i_16];
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
                inv_0[i_17 * 6U + j_7] = x_9[i_17];
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
        uint _S1179 = sv_0(c_35, 12U + j_7, kernelContext_77);
        uint _S1180 = 4U * j_7;
        *(kernelContext_77->scratch_0+_S1179) = packed_float4(float4(inv_0[_S1180], inv_0[_S1180 + 1U], inv_0[_S1180 + 2U], inv_0[_S1180 + 3U])) ;
        j_7 = j_7 + 1U;
    }
    return;
}

void assemble_block_0(uint c_36, KernelContext_0 thread* kernelContext_78)
{
    uint p_16;
    uint r_14;
    thread array<float, int(36)> a_14;
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
        a_14[k_22] = 0.0f;
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
        bool _S1181 = (entry_6 & 1U) != 0U;
        BondStatic_natural_0 device* _S1182 = kernelContext_78->bonds_0+i_18;
        uint _S1183 = statics_bond_slot_0(i_18, kernelContext_78);
        float4 _S1184 = float4(*(kernelContext_78->scratch_0+_S1183)) ;
        float4 _S1185 = float4(*(kernelContext_78->scratch_0+(_S1183 + 1U))) ;
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
            uint _S1186 = p_16 % 3U;
            float3 t_17;
            if(_S1186 == 0U)
            {
                t_17 = (float4(_S1182->t1_0) ).xyz;
            }
            else
            {
                if(_S1186 == 1U)
                {
                    t_17 = (float4(_S1182->t2_0) ).xyz;
                }
                else
                {
                    t_17 = (float4(_S1182->normal_0) ).xyz;
                }
            }
            bool _S1187 = p_16 < 3U;
            float3 row_u_0;
            float3 row_t_0;
            if(_S1187)
            {
                if(_S1181)
                {
                    row_u_0 = t_17;
                }
                else
                {
                    row_u_0 = - t_17;
                }
                if(_S1181)
                {
                    row_t_0 = cross((float4(_S1182->rb_0) ).xyz, t_17);
                }
                else
                {
                    row_t_0 = - cross((float4(_S1182->ra_0) ).xyz, t_17);
                }
            }
            else
            {
                float3 _S1188 = float3(0.0f) ;
                if(_S1181)
                {
                    row_u_0 = t_17;
                }
                else
                {
                    row_u_0 = - t_17;
                }
                float3 _S1189 = row_u_0;
                row_u_0 = _S1188;
                row_t_0 = _S1189;
            }
            float kp_0;
            if(_S1187)
            {
                kp_0 = _S1184[p_16];
            }
            else
            {
                kp_0 = _S1185[p_16 - 3U];
            }
            if(kp_0 == 0.0f)
            {
                p_16 = p_16 + 1U;
                continue;
            }
            array<float, int(6)> _S1190 = { { row_u_0.x, row_u_0.y, row_u_0.z, row_t_0.x, row_t_0.y, row_t_0.z } };
            r_14 = 0U;
            for(;;)
            {
                if(r_14 < 6U)
                {
                }
                else
                {
                    break;
                }
                uint q_17 = 0U;
                for(;;)
                {
                    if(q_17 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    a_14[r_14 * 6U + q_17] = a_14[r_14 * 6U + q_17] + kp_0 * _S1190[r_14] * _S1190[q_17];
                    q_17 = q_17 + 1U;
                }
                r_14 = r_14 + 1U;
            }
            p_16 = p_16 + 1U;
        }
        e_7 = e_7 + 1U;
    }
    uint _S1191 = fixed_mask_0(c_36, kernelContext_78);
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
        if((_S1191 & (1U << p_16)) != 0U)
        {
            r_14 = 0U;
            for(;;)
            {
                if(r_14 < 6U)
                {
                }
                else
                {
                    break;
                }
                a_14[p_16 * 6U + r_14] = 0.0f;
                a_14[r_14 * 6U + p_16] = 0.0f;
                r_14 = r_14 + 1U;
            }
            a_14[p_16 * 6U + p_16] = 1.0f;
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
        if((a_14[p_16 * 6U + p_16]) == 0.0f)
        {
            a_14[p_16 * 6U + p_16] = 1.0f;
        }
        p_16 = p_16 + 1U;
    }
    thread array<float, int(36)> _S1192 = a_14;
    store_inverse_0(c_36, &_S1192, kernelContext_78);
    return;
}

float block_get_0(uint c_37, uint i_19, uint j_8, KernelContext_0 thread* kernelContext_79)
{
    uint k_23 = i_19 * 6U + j_8;
    uint _S1193 = sv_0(c_37, 12U + k_23 / 4U, kernelContext_79);
    return (*(kernelContext_79->scratch_0+_S1193))[k_23 % 4U];
}

void precondition_0(uint c_38, KernelContext_0 thread* kernelContext_80)
{
    uint _S1194 = sv_0(c_38, 4U, kernelContext_80);
    float4 _S1195 = float4(*(kernelContext_80->scratch_0+_S1194)) ;
    uint _S1196 = sv_0(c_38, 5U, kernelContext_80);
    float4 _S1197 = float4(*(kernelContext_80->scratch_0+_S1196)) ;
    array<float, int(6)> _S1198 = { { _S1195.x, _S1195.y, _S1195.z, _S1197.x, _S1197.y, _S1197.z } };
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
        float s_10 = 0.0f;
        for(;;)
        {
            if(j_9 < 6U)
            {
            }
            else
            {
                break;
            }
            float _S1199 = block_get_0(c_38, i_20, j_9, kernelContext_80);
            float s_11 = s_10 + _S1199 * _S1198[j_9];
            j_9 = j_9 + 1U;
            s_10 = s_11;
        }
        z_1[i_20] = s_10;
        i_20 = i_20 + 1U;
    }
    uint _S1200 = sv_0(c_38, 6U, kernelContext_80);
    *(kernelContext_80->scratch_0+_S1200) = packed_float4(float4(z_1[int(0)], z_1[int(1)], z_1[int(2)], 0.0f)) ;
    uint _S1201 = sv_0(c_38, 7U, kernelContext_80);
    *(kernelContext_80->scratch_0+_S1201) = packed_float4(float4(z_1[int(3)], z_1[int(4)], z_1[int(5)], 0.0f)) ;
    return;
}

void project_displacement_slot_0(uint tid_16, const Island_natural_0 thread* isl_24, uint slot_5, KernelContext_0 thread* kernelContext_81)
{
    uint _S1202;
    float3 _S1203 = float3(0.0f) ;
    thread float3 p_17 = _S1203;
    thread float3 l_5 = _S1203;
    uint4 _S1204 = uint4(isl_24->range_0) ;
    uint _S1205 = _S1204.x + tid_16;
    uint c_39 = _S1205;
    for(;;)
    {
        uint _S1206 = _S1204.y;
        _S1202 = _S1206;
        if(c_39 < _S1206)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_natural_0 device* _S1207 = kernelContext_81->chunks_0+c_39;
        uint _S1208 = sv_0(c_39, slot_5, kernelContext_81);
        float3 u_6 = (float4(*(kernelContext_81->scratch_0+_S1208)) ).xyz;
        uint _S1209 = sv_0(c_39, slot_5 + 1U, kernelContext_81);
        float3 th_7 = (float4(*(kernelContext_81->scratch_0+_S1209)) ).xyz;
        float4 _S1210 = float4(_S1207->center_0) ;
        float3 r_15 = _S1210.xyz - (float4(isl_24->com_0) ).xyz;
        float3 _S1211 = float3(_S1210.w) ;
        p_17 = p_17 + u_6 * _S1211;
        l_5 = l_5 + (cross(r_15, u_6) * _S1211 + rows_mul_0(float4(_S1207->inertia0_1) , float4(_S1207->inertia1_1) , float4(_S1207->inertia2_1) , th_7));
        c_39 = c_39 + 256U;
    }
    group_sum3_0(tid_16, &p_17, &l_5, kernelContext_81);
    float4 _S1212 = float4(isl_24->com_0) ;
    float3 _S1213 = p_17 / float3(_S1212.w) ;
    float3 _S1214 = rows_mul_0(float4(isl_24->inv0_0) , float4(isl_24->inv1_0) , float4(isl_24->inv2_0) , l_5);
    c_39 = _S1205;
    for(;;)
    {
        if(c_39 < _S1202)
        {
        }
        else
        {
            break;
        }
        float3 r_16 = (float4((kernelContext_81->chunks_0+c_39)->center_0) ).xyz - _S1212.xyz;
        uint _S1215 = sv_0(c_39, slot_5, kernelContext_81);
        *(kernelContext_81->scratch_0+_S1215) = packed_float4(float4((float4(*(kernelContext_81->scratch_0+_S1215)) ).xyz - _S1213 - cross(_S1214, r_16), 0.0f)) ;
        uint _S1216 = sv_0(c_39, slot_5 + 1U, kernelContext_81);
        *(kernelContext_81->scratch_0+_S1216) = packed_float4(float4((float4(*(kernelContext_81->scratch_0+_S1216)) ).xyz - _S1214, 0.0f)) ;
        c_39 = c_39 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    return;
}

uint statics_result_slot_0(uint island_1, KernelContext_0 thread* kernelContext_82)
{
    return kernelContext_82->params_0->statics_base_0 + 23U * kernelContext_82->params_0->chunk_count_0 + 2U * kernelContext_82->params_0->statics_bonds_0 + island_1;
}

void write_bond_loads_0(uint _S1217, uint _S1218, float3 _S1219, float3 _S1220, float _S1221, KernelContext_0 thread* kernelContext_83)
{
    BondStatic_natural_0 device* _S1222 = kernelContext_83->bonds_0+_S1218;
    float3 _S1223 = to_body_0(_S1218, _S1219, kernelContext_83);
    float3 _S1224 = to_body_0(_S1218, _S1220, kernelContext_83);
    uint _S1225 = 3U * _S1217;
    *(kernelContext_83->scratch_0+_S1225) = packed_float4(float4(_S1223, _S1221)) ;
    *(kernelContext_83->scratch_0+(_S1225 + 1U)) = packed_float4(float4(_S1224 + cross((float4(_S1222->ra_0) ).xyz, _S1223), 0.0f)) ;
    *(kernelContext_83->scratch_0+(_S1225 + 2U)) = packed_float4(float4(- _S1224 + cross((float4(_S1222->rb_0) ).xyz, - _S1223), 0.0f)) ;
    return;
}

void bond_kinematics_0(uint _S1226, float3 _S1227, float3 _S1228, float3 _S1229, float3 _S1230, float3 thread* _S1231, float3 thread* _S1232, KernelContext_0 thread* kernelContext_84)
{
    BondStatic_natural_0 device* _S1233 = kernelContext_84->bonds_0+_S1226;
    float3 _S1234 = to_local_0(_S1226, _S1229 + cross(_S1230, (float4(_S1233->rb_0) ).xyz) - (_S1227 + cross(_S1228, (float4(_S1233->ra_0) ).xyz)), kernelContext_84);
    *_S1231 = _S1234;
    float3 _S1235 = to_local_0(_S1226, _S1230 - _S1228, kernelContext_84);
    *_S1232 = _S1235;
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
    uint _S1236 = group_9.x;
    thread Island_natural_0 _S1237 = *(islands_13+_S1236);
    uint4 _S1238 = uint4((&_S1237)->info_0) ;
    uint _S1239 = _S1238.z;
    if((_S1239 & 8U) == 0U)
    {
        return;
    }
    bool free_0 = ((_S1238.x) & 1U) == 0U;
    uint4 _S1240 = uint4((&_S1237)->range_0) ;
    uint c0_1 = _S1240.x;
    uint c1_1 = _S1240.y;
    uint b0_0 = _S1240.z;
    uint _S1241 = _S1240.w;
    uint _S1242 = c0_1 + tid_17;
    uint c_41 = _S1242;
    for(;;)
    {
        if(c_41 < c1_1)
        {
        }
        else
        {
            break;
        }
        uint _S1243 = sv_0(c_41, 21U, &kernelContext_85);
        packed_float4 _S1244 = packed_float4(float4(0.0f) ) ;
        *((&kernelContext_85)->scratch_0+_S1243) = _S1244;
        uint _S1245 = sv_0(c_41, 22U, &kernelContext_85);
        *((&kernelContext_85)->scratch_0+_S1245) = _S1244;
        c_41 = c_41 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    if(free_0)
    {
        project_load_slot_0(tid_17, &_S1237, 0U, &kernelContext_85);
    }
    float _S1246 = island_dot_0(tid_17, c0_1, c1_1, 0U, 0U, &kernelContext_85);
    float _S1247 = max(sqrt(_S1246), 1.00000000317107685e-30f);
    float _S1248 = (&kernelContext_85)->params_0->statics_tol_0;
    uint _S1249 = min((&kernelContext_85)->params_0->statics_cg_0, 20U * (c1_1 - c0_1) * 6U + 200U);
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
        uint _S1250 = b0_0 + tid_17;
        i_21 = _S1250;
        for(;;)
        {
            if(i_21 < _S1241)
            {
            }
            else
            {
                break;
            }
            JointResponse_0 _S1251 = static_response_0(i_21, &kernelContext_85);
            write_bond_loads_0(i_21, i_21, _S1251.force_lin_1, _S1251.force_ang_1, 0.0f, &kernelContext_85);
            i_21 = i_21 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        float4 _S1252 = float4(0.0f) ;
        thread float4 magnitude_0 = _S1252;
        thread float4 unused_m_0 = _S1252;
        c_41 = _S1242;
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
            float _S1253 = bond_load_magnitude2_0(c_41, &kernelContext_85);
            magnitude_0.x = magnitude_0.x + _S1253;
            uint _S1254 = sv_0(c_41, 0U, &kernelContext_85);
            thread float4 r_lin_0 = float4((float4(*((&kernelContext_85)->scratch_0+_S1254)) ).xyz + fi_4, 0.0f);
            uint _S1255 = sv_0(c_41, 1U, &kernelContext_85);
            thread float4 r_ang_0 = float4((float4(*((&kernelContext_85)->scratch_0+_S1255)) ).xyz + mi_7, 0.0f);
            uint _S1256 = fixed_mask_0(c_41, &kernelContext_85);
            hold_0(_S1256, &r_lin_0, &r_ang_0, _S1252, _S1252);
            uint _S1257 = sv_0(c_41, 4U, &kernelContext_85);
            *((&kernelContext_85)->scratch_0+_S1257) = packed_float4(r_lin_0) ;
            uint _S1258 = sv_0(c_41, 5U, &kernelContext_85);
            *((&kernelContext_85)->scratch_0+_S1258) = packed_float4(r_ang_0) ;
            c_41 = c_41 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        group_sum2_0(tid_17, &magnitude_0, &unused_m_0, &kernelContext_85);
        if(free_0)
        {
            project_load_slot_0(tid_17, &_S1237, 4U, &kernelContext_85);
        }
        float _S1259 = island_dot_0(tid_17, c0_1, c1_1, 4U, 4U, &kernelContext_85);
        float residual_1 = sqrt(_S1259) / _S1247;
        float _S1260 = max(0.00100000004749745f, 3.83999986297567375e-06f * sqrt(magnitude_0.x) / _S1247);
        if(residual_1 <= _S1248)
        {
            converged_0 = true;
        }
        else
        {
            if(residual_1 <= _S1260)
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
        uint i_22 = _S1250;
        for(;;)
        {
            if(i_22 < _S1241)
            {
            }
            else
            {
                break;
            }
            BondStatic_natural_0 device* _S1261 = (&kernelContext_85)->bonds_0+i_22;
            thread float3 d_lin_5;
            thread float3 d_ang_4;
            static_kinematics_0(i_22, &d_lin_5, &d_ang_4, &kernelContext_85);
            thread JointBond_natural_0 _S1262 = _S1261->law_0;
            thread JointState_0 _S1263 = ((&kernelContext_85)->bond_dyn_0+i_22)->js_0;
            thread float3 f_lin_2;
            thread float3 f_ang_2;
            secant_factors_0(&_S1262, &_S1263, d_lin_5, &f_lin_2, &f_ang_2);
            float4 _S1264 = float4((&_S1262)->stiff0_0) ;
            uint _S1265 = statics_bond_slot_0(i_22, &kernelContext_85);
            float _S1266 = _S1264.y;
            *((&kernelContext_85)->scratch_0+_S1265) = packed_float4(float4(_S1266 * f_lin_2.x, _S1266 * f_lin_2.y, _S1264.x * f_lin_2.z, 0.0f)) ;
            *((&kernelContext_85)->scratch_0+(_S1265 + 1U)) = packed_float4(float4(_S1264.z * f_ang_2.x, _S1264.w * f_ang_2.y, (float4((&_S1262)->stiff1_0) ).x * f_ang_2.z, 0.0f)) ;
            i_22 = i_22 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_42 = _S1242;
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
            uint _S1267 = sv_0(c_42, 2U, &kernelContext_85);
            packed_float4 _S1268 = packed_float4(_S1252) ;
            *((&kernelContext_85)->scratch_0+_S1267) = _S1268;
            uint _S1269 = sv_0(c_42, 3U, &kernelContext_85);
            *((&kernelContext_85)->scratch_0+_S1269) = _S1268;
            c_42 = c_42 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_43 = _S1242;
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
            project_displacement_slot_0(tid_17, &_S1237, 6U, &kernelContext_85);
        }
        uint c_44 = _S1242;
        for(;;)
        {
            if(c_44 < c1_1)
            {
            }
            else
            {
                break;
            }
            uint _S1270 = sv_0(c_44, 8U, &kernelContext_85);
            packed_float4 device* _S1271 = (&kernelContext_85)->scratch_0+_S1270;
            uint _S1272 = sv_0(c_44, 6U, &kernelContext_85);
            *_S1271 = packed_float4(float4(*((&kernelContext_85)->scratch_0+_S1272)) ) ;
            uint _S1273 = sv_0(c_44, 9U, &kernelContext_85);
            packed_float4 device* _S1274 = (&kernelContext_85)->scratch_0+_S1273;
            uint _S1275 = sv_0(c_44, 7U, &kernelContext_85);
            *_S1274 = packed_float4(float4(*((&kernelContext_85)->scratch_0+_S1275)) ) ;
            c_44 = c_44 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        float _S1276 = island_dot_0(tid_17, c0_1, c1_1, 4U, 6U, &kernelContext_85);
        float _S1277 = island_dot_0(tid_17, c0_1, c1_1, 4U, 4U, &kernelContext_85);
        float _S1278 = sqrt(_S1277);
        float rz_0 = _S1276;
        uint k_24 = 0U;
        uint cg_total_1 = cg_total_0;
        for(;;)
        {
            bool _S1279;
            if(k_24 < _S1249)
            {
                _S1279 = _S1278 > 0.0f;
            }
            else
            {
                _S1279 = false;
            }
            if(_S1279)
            {
            }
            else
            {
                cg_total_0 = cg_total_1;
                break;
            }
            uint i_23 = _S1250;
            for(;;)
            {
                if(i_23 < _S1241)
                {
                }
                else
                {
                    break;
                }
                uint4 _S1280 = uint4(((&kernelContext_85)->bonds_0+i_23)->law_0.ids_0) ;
                uint ca_2 = _S1280.y;
                uint cb_2 = _S1280.z;
                uint _S1281 = sv_0(ca_2, 8U, &kernelContext_85);
                float3 _S1282 = (float4(*((&kernelContext_85)->scratch_0+_S1281)) ).xyz;
                uint _S1283 = sv_0(ca_2, 9U, &kernelContext_85);
                float3 _S1284 = (float4(*((&kernelContext_85)->scratch_0+_S1283)) ).xyz;
                uint _S1285 = sv_0(cb_2, 8U, &kernelContext_85);
                float3 _S1286 = (float4(*((&kernelContext_85)->scratch_0+_S1285)) ).xyz;
                uint _S1287 = sv_0(cb_2, 9U, &kernelContext_85);
                thread float3 d_lin_6;
                thread float3 d_ang_5;
                bond_kinematics_0(i_23, _S1282, _S1284, _S1286, (float4(*((&kernelContext_85)->scratch_0+_S1287)) ).xyz, &d_lin_6, &d_ang_5, &kernelContext_85);
                uint _S1288 = statics_bond_slot_0(i_23, &kernelContext_85);
                write_bond_loads_0(i_23, i_23, d_lin_6 * (float4(*((&kernelContext_85)->scratch_0+_S1288)) ).xyz, d_ang_5 * (float4(*((&kernelContext_85)->scratch_0+(_S1288 + 1U))) ).xyz, 0.0f, &kernelContext_85);
                i_23 = i_23 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            c_40 = _S1242;
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
                uint _S1289 = fixed_mask_0(c_40, &kernelContext_85);
                uint _S1290 = sv_0(c_40, 8U, &kernelContext_85);
                float4 _S1291 = float4(*((&kernelContext_85)->scratch_0+_S1290)) ;
                uint _S1292 = sv_0(c_40, 9U, &kernelContext_85);
                hold_0(_S1289, &ap_lin_0, &ap_ang_0, _S1291, float4(*((&kernelContext_85)->scratch_0+_S1292)) );
                uint _S1293 = sv_0(c_40, 10U, &kernelContext_85);
                *((&kernelContext_85)->scratch_0+_S1293) = packed_float4(ap_lin_0) ;
                uint _S1294 = sv_0(c_40, 11U, &kernelContext_85);
                *((&kernelContext_85)->scratch_0+_S1294) = packed_float4(ap_ang_0) ;
                c_40 = c_40 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            float _S1295 = island_dot_0(tid_17, c0_1, c1_1, 8U, 10U, &kernelContext_85);
            uint _S1296 = cg_total_1 + 1U;
            if(_S1295 <= 0.0f)
            {
                cg_total_0 = _S1296;
                break;
            }
            float _S1297 = rz_0 / _S1295;
            uint c_45 = _S1242;
            for(;;)
            {
                if(c_45 < c1_1)
                {
                }
                else
                {
                    break;
                }
                uint _S1298 = sv_0(c_45, 2U, &kernelContext_85);
                packed_float4 device* _S1299 = (&kernelContext_85)->scratch_0+_S1298;
                float3 _S1300 = (float4(*((&kernelContext_85)->scratch_0+_S1298)) ).xyz;
                uint _S1301 = sv_0(c_45, 8U, &kernelContext_85);
                float3 _S1302 = float3(_S1297) ;
                *_S1299 = packed_float4(float4(_S1300 + _S1302 * (float4(*((&kernelContext_85)->scratch_0+_S1301)) ).xyz, 0.0f)) ;
                uint _S1303 = sv_0(c_45, 3U, &kernelContext_85);
                packed_float4 device* _S1304 = (&kernelContext_85)->scratch_0+_S1303;
                float3 _S1305 = (float4(*((&kernelContext_85)->scratch_0+_S1303)) ).xyz;
                uint _S1306 = sv_0(c_45, 9U, &kernelContext_85);
                *_S1304 = packed_float4(float4(_S1305 + _S1302 * (float4(*((&kernelContext_85)->scratch_0+_S1306)) ).xyz, 0.0f)) ;
                uint _S1307 = sv_0(c_45, 4U, &kernelContext_85);
                packed_float4 device* _S1308 = (&kernelContext_85)->scratch_0+_S1307;
                float3 _S1309 = (float4(*((&kernelContext_85)->scratch_0+_S1307)) ).xyz;
                uint _S1310 = sv_0(c_45, 10U, &kernelContext_85);
                *_S1308 = packed_float4(float4(_S1309 - _S1302 * (float4(*((&kernelContext_85)->scratch_0+_S1310)) ).xyz, 0.0f)) ;
                uint _S1311 = sv_0(c_45, 5U, &kernelContext_85);
                packed_float4 device* _S1312 = (&kernelContext_85)->scratch_0+_S1311;
                float3 _S1313 = (float4(*((&kernelContext_85)->scratch_0+_S1311)) ).xyz;
                uint _S1314 = sv_0(c_45, 11U, &kernelContext_85);
                *_S1312 = packed_float4(float4(_S1313 - _S1302 * (float4(*((&kernelContext_85)->scratch_0+_S1314)) ).xyz, 0.0f)) ;
                c_45 = c_45 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            float _S1315 = island_dot_0(tid_17, c0_1, c1_1, 4U, 4U, &kernelContext_85);
            if((sqrt(_S1315)) <= (0.00009999999747379f * _S1278))
            {
                cg_total_0 = _S1296;
                break;
            }
            uint c_46 = _S1242;
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
                project_displacement_slot_0(tid_17, &_S1237, 6U, &kernelContext_85);
            }
            float _S1316 = island_dot_0(tid_17, c0_1, c1_1, 4U, 6U, &kernelContext_85);
            float _S1317 = _S1316 / rz_0;
            uint c_47 = _S1242;
            for(;;)
            {
                if(c_47 < c1_1)
                {
                }
                else
                {
                    break;
                }
                uint _S1318 = sv_0(c_47, 8U, &kernelContext_85);
                packed_float4 device* _S1319 = (&kernelContext_85)->scratch_0+_S1318;
                uint _S1320 = sv_0(c_47, 6U, &kernelContext_85);
                float3 _S1321 = float3(_S1317) ;
                *_S1319 = packed_float4(float4((float4(*((&kernelContext_85)->scratch_0+_S1320)) ).xyz + _S1321 * (float4(*((&kernelContext_85)->scratch_0+_S1318)) ).xyz, 0.0f)) ;
                uint _S1322 = sv_0(c_47, 9U, &kernelContext_85);
                packed_float4 device* _S1323 = (&kernelContext_85)->scratch_0+_S1322;
                uint _S1324 = sv_0(c_47, 7U, &kernelContext_85);
                *_S1323 = packed_float4(float4((float4(*((&kernelContext_85)->scratch_0+_S1324)) ).xyz + _S1321 * (float4(*((&kernelContext_85)->scratch_0+_S1322)) ).xyz, 0.0f)) ;
                c_47 = c_47 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            uint _S1325 = k_24 + 1U;
            rz_0 = _S1316;
            k_24 = _S1325;
            cg_total_1 = _S1296;
        }
        c_40 = _S1242;
        for(;;)
        {
            if(c_40 < c1_1)
            {
            }
            else
            {
                break;
            }
            uint _S1326 = 4U * c_40;
            thread float3 u_7 = (float4(*((&kernelContext_85)->state_0+_S1326)) ).xyz;
            uint _S1327 = sv_0(c_40, 21U, &kernelContext_85);
            thread float3 u_lo_0 = (float4(*((&kernelContext_85)->scratch_0+_S1327)) ).xyz;
            uint _S1328 = _S1326 + 1U;
            thread float3 th_8 = (float4(*((&kernelContext_85)->state_0+_S1328)) ).xyz;
            uint _S1329 = sv_0(c_40, 22U, &kernelContext_85);
            thread float3 th_lo_0 = (float4(*((&kernelContext_85)->scratch_0+_S1329)) ).xyz;
            uint _S1330 = sv_0(c_40, 2U, &kernelContext_85);
            comp_add_0(&u_7, &u_lo_0, (float4(*((&kernelContext_85)->scratch_0+_S1330)) ).xyz);
            uint _S1331 = sv_0(c_40, 3U, &kernelContext_85);
            comp_add_0(&th_8, &th_lo_0, (float4(*((&kernelContext_85)->scratch_0+_S1331)) ).xyz);
            *((&kernelContext_85)->state_0+_S1326) = packed_float4(float4(u_7, (float4(*((&kernelContext_85)->state_0+_S1326)) ).w)) ;
            *((&kernelContext_85)->state_0+_S1328) = packed_float4(float4(th_8, (float4(*((&kernelContext_85)->state_0+_S1328)) ).w)) ;
            *((&kernelContext_85)->scratch_0+_S1327) = packed_float4(float4(u_lo_0, 0.0f)) ;
            *((&kernelContext_85)->scratch_0+_S1329) = packed_float4(float4(th_lo_0, 0.0f)) ;
            c_40 = c_40 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint _S1332 = newton_0 + 1U;
        previous_2 = residual_1;
        residual_0 = residual_1;
        newton_0 = _S1332;
    }
    i_21 = b0_0 + tid_17;
    for(;;)
    {
        if(i_21 < _S1241)
        {
        }
        else
        {
            break;
        }
        JointResponse_0 _S1333 = static_response_0(i_21, &kernelContext_85);
        BondDyn_natural_0 device* _S1334 = (&kernelContext_85)->bond_dyn_0+i_21;
        float4 _S1335 = float4((*_S1334).force_lin_0) ;
        float4 _S1336 = float4((*_S1334).force_ang_0) ;
        float4 _S1337 = float4((*_S1334).sums_0) ;
        float4 _S1338 = float4((*_S1334).comps_0) ;
        uint4 _S1339 = uint4((*_S1334).events_0) ;
        thread BondDyn_0 bd_1;
        (&bd_1)->js_0 = (*_S1334).js_0;
        (&bd_1)->force_lin_0 = _S1335;
        (&bd_1)->force_ang_0 = _S1336;
        (&bd_1)->sums_0 = _S1337;
        (&bd_1)->comps_0 = _S1338;
        (&bd_1)->events_0 = _S1339;
        (&bd_1)->force_lin_0 = float4(_S1333.force_lin_1, _S1333.stored_5);
        (&bd_1)->force_ang_0 = float4(_S1333.force_ang_1, (&bd_1)->force_ang_0.w);
        BondDyn_natural_0 device* _S1340 = (&kernelContext_85)->bond_dyn_0+i_21;
        _S1340->js_0 = bd_1.js_0;
        _S1340->force_lin_0 = packed_float4(bd_1.force_lin_0) ;
        _S1340->force_ang_0 = packed_float4(bd_1.force_ang_0) ;
        _S1340->sums_0 = packed_float4(bd_1.sums_0) ;
        _S1340->comps_0 = packed_float4(bd_1.comps_0) ;
        _S1340->events_0 = packed_uint4(bd_1.events_0) ;
        write_bond_loads_0(i_21, i_21, _S1333.force_lin_1, _S1333.force_ang_1, max(_S1333.measures_0.tension_0, _S1333.measures_0.compression_0), &kernelContext_85);
        i_21 = i_21 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    c_41 = _S1242;
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
        uint _S1341 = fixed_mask_0(c_41, &kernelContext_85);
        float3 reaction_2;
        if(_S1341 != 0U)
        {
            uint _S1342 = sv_0(c_41, 0U, &kernelContext_85);
            reaction_2 = - ((float4(*((&kernelContext_85)->scratch_0+_S1342)) ).xyz + fi_6);
        }
        else
        {
            uint _S1343 = 4U * c_41;
            reaction_2 = float3((float4(*((&kernelContext_85)->state_0+(_S1343 + 1U))) ).w, (float4(*((&kernelContext_85)->state_0+(_S1343 + 2U))) ).w, (float4(*((&kernelContext_85)->state_0+(_S1343 + 3U))) ).w);
        }
        uint _S1344 = 4U * c_41;
        uint _S1345 = _S1344 + 1U;
        *((&kernelContext_85)->state_0+_S1345) = packed_float4(float4((float4(*((&kernelContext_85)->state_0+_S1345)) ).xyz, reaction_2.x)) ;
        *((&kernelContext_85)->state_0+(_S1344 + 2U)) = packed_float4(float4(0.0f, 0.0f, 0.0f, reaction_2.y)) ;
        *((&kernelContext_85)->state_0+(_S1344 + 3U)) = packed_float4(float4(0.0f, 0.0f, 0.0f, reaction_2.z)) ;
        c_41 = c_41 + 256U;
    }
    if(tid_17 == 0U)
    {
        uint _S1346 = statics_result_slot_0(_S1236, &kernelContext_85);
        packed_float4 device* _S1347 = (&kernelContext_85)->scratch_0+_S1346;
        float _S1348 = (as_type<float>((newton_0)));
        float _S1349 = (as_type<float>((cg_total_0)));
        if(converged_0)
        {
            previous_2 = 1.0f;
        }
        else
        {
            previous_2 = 0.0f;
        }
        *_S1347 = packed_float4(float4(residual_0, _S1348, _S1349, previous_2)) ;
        ((&kernelContext_85)->islands_0+_S1236)->info_0[int(2)] = _S1239 & 4294967287U;
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
    uint _S1350 = group_10.x;
    Island_natural_0 device* _S1351 = islands_14+_S1350;
    Island_natural_0 isl_25 = *_S1351;
    uint4 _S1352 = uint4((*_S1351).info_0) ;
    bool _S1353;
    if(((_S1352.x) & 16U) == 0U)
    {
        _S1353 = true;
    }
    else
    {
        uint4 _S1354 = uint4(isl_25.range_0) ;
        _S1353 = (_S1354.w) == (_S1354.z);
    }
    if(_S1353)
    {
        return;
    }
    bool _S1355 = tid_18 == 0U;
    if(_S1355)
    {
        *(&kernelContext_86)->g_halt_0 = 0U;
        *(&kernelContext_86)->g_run_0 = 0U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    uint _S1356 = _S1352.w;
    uint4 _S1357 = uint4(isl_25.range_0) ;
    uint i_24 = _S1357.z + tid_18;
    for(;;)
    {
        if(i_24 < (_S1357.w))
        {
        }
        else
        {
            break;
        }
        BondStatic_natural_0 device* _S1358 = (&kernelContext_86)->bonds_0+i_24;
        BondDyn_natural_0 device* _S1359 = (&kernelContext_86)->bond_dyn_0+i_24;
        float4 _S1360 = float4((*_S1359).force_lin_0) ;
        float4 _S1361 = float4((*_S1359).force_ang_0) ;
        float4 _S1362 = float4((*_S1359).sums_0) ;
        float4 _S1363 = float4((*_S1359).comps_0) ;
        uint4 _S1364 = uint4((*_S1359).events_0) ;
        thread BondDyn_0 bd_2;
        (&bd_2)->js_0 = (*_S1359).js_0;
        (&bd_2)->force_lin_0 = _S1360;
        (&bd_2)->force_ang_0 = _S1361;
        (&bd_2)->sums_0 = _S1362;
        (&bd_2)->comps_0 = _S1363;
        (&bd_2)->events_0 = _S1364;
        thread JointBond_natural_0 _S1365 = _S1358->law_0;
        uint4 _S1366 = uint4((&_S1365)->ids_0) ;
        uint _S1367 = 4U * _S1366.y;
        uint _S1368 = 4U * _S1366.z;
        thread float3 d_lin_7;
        thread float3 d_ang_6;
        bond_kinematics_0(i_24, (float4(*((&kernelContext_86)->state_0+_S1367)) ).xyz, (float4(*((&kernelContext_86)->state_0+(_S1367 + 1U))) ).xyz, (float4(*((&kernelContext_86)->state_0+_S1368)) ).xyz, (float4(*((&kernelContext_86)->state_0+(_S1368 + 1U))) ).xyz, &d_lin_7, &d_ang_6, &kernelContext_86);
        JointState_0 previous_3 = (&bd_2)->js_0;
        float _S1369 = (&kernelContext_86)->params_0->dt_0;
        bool _S1370 = ((&kernelContext_86)->params_0->fracture_0) != 0U;
        _S1365 = _S1358->law_0;
        thread JointState_0 _S1371 = (&bd_2)->js_0;
        JointResponse_0 _S1372 = joint_evaluate_0(&(&kernelContext_86)->materials_0->m_0[_S1366.x], &_S1365, &_S1371, d_lin_7, d_ang_6, _S1369, _S1370);
        if((_S1372.state_6.damage_0) > (previous_3.damage_0 + 9.99999971718068537e-10f))
        {
            _S1353 = true;
        }
        else
        {
            _S1353 = (_S1372.state_6.crush_1) > (previous_3.crush_1 + 9.99999971718068537e-10f);
        }
        uint flags_2;
        if(_S1353)
        {
            flags_2 = 16U;
        }
        else
        {
            flags_2 = 0U;
        }
        thread float _S1373 = (&bd_2)->sums_0.x;
        thread float _S1374 = (&bd_2)->comps_0.x;
        comp_add1_0(&_S1373, &_S1374, _S1372.dissipated_2);
        (&bd_2)->comps_0.x = _S1374;
        (&bd_2)->sums_0.x = _S1373;
        thread float _S1375 = (&bd_2)->sums_0.y;
        thread float _S1376 = (&bd_2)->comps_0.y;
        comp_add1_0(&_S1375, &_S1376, _S1372.overshoot_0);
        (&bd_2)->comps_0.y = _S1376;
        (&bd_2)->sums_0.y = _S1375;
        (&bd_2)->force_lin_0 = float4(_S1372.force_lin_1, _S1372.stored_5);
        (&bd_2)->force_ang_0 = float4(_S1372.force_ang_1, max((&bd_2)->force_ang_0.w, _S1372.state_6.utilization_0));
        thread JointState_0 _S1377 = previous_3;
        bool _S1378 = is_damaged_0(&_S1377);
        bool _S1379;
        if(!_S1378)
        {
            thread JointState_0 _S1380 = _S1372.state_6;
            bool _S1381 = is_damaged_0(&_S1380);
            _S1379 = _S1381;
        }
        else
        {
            _S1379 = false;
        }
        bool _S1382;
        if(_S1379)
        {
            _S1382 = ((&bd_2)->events_0.x) == 0U;
        }
        else
        {
            _S1382 = false;
        }
        if(_S1382)
        {
            (&bd_2)->events_0.x = _S1356;
            (&bd_2)->events_0.w = _S1372.state_6.mode_0;
        }
        bool _S1383;
        if(((&bd_2)->events_0.y) == 0U)
        {
            float _S1384 = fatigue_factor_0(&(&kernelContext_86)->materials_0->m_0[_S1366.x], previous_3.fatigue_0);
            _S1383 = _S1384 > 0.99000000953674316f;
        }
        else
        {
            _S1383 = false;
        }
        bool _S1385;
        if(_S1383)
        {
            float _S1386 = fatigue_factor_0(&(&kernelContext_86)->materials_0->m_0[_S1366.x], _S1372.state_6.fatigue_0);
            _S1385 = _S1386 <= 0.99000000953674316f;
        }
        else
        {
            _S1385 = false;
        }
        if(_S1385)
        {
            (&bd_2)->events_0.y = _S1356;
        }
        uint flags_3;
        if(_S1372.disconnected_0)
        {
            (&bd_2)->events_0.z = _S1356;
            flags_3 = flags_2 | 32U;
        }
        else
        {
            flags_3 = flags_2;
        }
        (&bd_2)->js_0 = _S1372.state_6;
        BondDyn_natural_0 device* _S1387 = (&kernelContext_86)->bond_dyn_0+i_24;
        _S1387->js_0 = bd_2.js_0;
        _S1387->force_lin_0 = packed_float4(bd_2.force_lin_0) ;
        _S1387->force_ang_0 = packed_float4(bd_2.force_ang_0) ;
        _S1387->sums_0 = packed_float4(bd_2.sums_0) ;
        _S1387->comps_0 = packed_float4(bd_2.comps_0) ;
        _S1387->events_0 = packed_uint4(bd_2.events_0) ;
        write_bond_loads_0(i_24, i_24, _S1372.force_lin_1, _S1372.force_ang_1, max(_S1372.measures_0.tension_0, _S1372.measures_0.compression_0), &kernelContext_86);
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
    if(_S1355)
    {
        _S1353 = ((*(&kernelContext_86)->g_halt_0) | (*(&kernelContext_86)->g_run_0)) != 0U;
    }
    else
    {
        _S1353 = false;
    }
    if(_S1353)
    {
        uint _S1388 = _S1352.z;
        if((*(&kernelContext_86)->g_halt_0) != 0U)
        {
            i_24 = 16U;
        }
        else
        {
            i_24 = 0U;
        }
        uint _S1389 = _S1388 | i_24;
        if((*(&kernelContext_86)->g_run_0) != 0U)
        {
            i_24 = 32U;
        }
        else
        {
            i_24 = 0U;
        }
        ((&kernelContext_86)->islands_0+_S1350)->info_0[int(2)] = _S1389 | i_24;
    }
    return;
}

