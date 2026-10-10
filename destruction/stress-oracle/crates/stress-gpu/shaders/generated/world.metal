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
    array<float4, int(256)> threadgroup* g_red_a_0;
    array<float4, int(256)> threadgroup* g_red_b_0;
    uint threadgroup* g_run_0;
    uint threadgroup* g_halt_0;
    uint threadgroup* g_wide_run_0;
};

bool stopped_0(KernelContext_0 thread* kernelContext_0)
{
    uint4 _S1 = uint4((kernelContext_0->islands_0+kernelContext_0->params_0->halt_index_0)->info_0) ;
    bool _S2;
    if(((_S1.z) & 1U) != 0U)
    {
        _S2 = true;
    }
    else
    {
        _S2 = (_S1.y) != 0U;
    }
    return _S2;
}

struct Quat_0
{
    float w_0;
    float x_0;
    float y_0;
    float z_0;
};

Quat_0 quat_of_0(float4 q_0)
{
    thread Quat_0 r_0;
    (&r_0)->x_0 = q_0.x;
    (&r_0)->y_0 = q_0.y;
    (&r_0)->z_0 = q_0.z;
    (&r_0)->w_0 = q_0.w;
    return r_0;
}

float3 rotate_0(const Quat_0 thread* q_1, float3 v_0)
{
    float3 qv_0 = float3(q_1->x_0, q_1->y_0, q_1->z_0);
    float3 t_0 = cross(qv_0, v_0) * float3(2.0f) ;
    return v_0 + t_0 * float3(q_1->w_0)  + cross(qv_0, t_0);
}

float3 rotate_1(const Quat_0 thread* q_2, float3 v_1)
{
    float3 qv_1 = float3(q_2->x_0, q_2->y_0, q_2->z_0);
    float3 t_1 = cross(qv_1, v_1) * float3(2.0f) ;
    return v_1 + t_1 * float3(q_2->w_0)  + cross(qv_1, t_1);
}

struct WorldPoint_0
{
    float3 hi_0;
    float3 lo_0;
    float3 rel_0;
};

WorldPoint_0 chunk_world_0(uint c_0, KernelContext_0 thread* kernelContext_1)
{
    ChunkStatic_natural_0 device* _S3 = kernelContext_1->chunks_0+c_0;
    Island_natural_0 device* _S4 = kernelContext_1->islands_0+(uint4(_S3->info_1) ).y;
    Quat_0 q_3 = quat_of_0(float4(_S4->rotation_0) );
    thread WorldPoint_0 w_1;
    (&w_1)->hi_0 = (float4(_S4->position_0) ).xyz;
    (&w_1)->lo_0 = (float4(_S4->position_err_0) ).xyz;
    float3 _S5 = (float4(_S3->center_0) ).xyz + (float4(*(kernelContext_1->state_0+4U * c_0)) ).xyz;
    thread Quat_0 _S6 = q_3;
    float3 _S7 = rotate_0(&_S6, _S5);
    (&w_1)->rel_0 = _S7;
    return w_1;
}

float3 world_diff_0(const WorldPoint_0 thread* a_0, const WorldPoint_0 thread* b_0)
{
    return a_0->hi_0 - b_0->hi_0 + (a_0->lo_0 - b_0->lo_0) + (a_0->rel_0 - b_0->rel_0);
}

float3 safe_normalize_0(float3 v_2)
{
    float n_0 = length(v_2);
    float3 _S8;
    if(n_0 > 1.00000000317107685e-30f)
    {
        _S8 = v_2 / float3(n_0) ;
    }
    else
    {
        _S8 = float3(0.0f) ;
    }
    return _S8;
}

Quat_0 from_axis_angle_0(float3 axis_0, float angle_0)
{
    float3 a_1 = safe_normalize_0(axis_0);
    float _S9 = 0.5f * angle_0;
    float s_0 = sin(_S9);
    thread Quat_0 q_4;
    (&q_4)->w_0 = cos(_S9);
    (&q_4)->x_0 = a_1.x * s_0;
    (&q_4)->y_0 = a_1.y * s_0;
    (&q_4)->z_0 = a_1.z * s_0;
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

Box_0 chunk_box_0(uint c_1, float3 center_2, KernelContext_0 thread* kernelContext_2)
{
    ChunkStatic_natural_0 device* _S10 = kernelContext_2->chunks_0+c_1;
    Quat_0 q_5 = quat_of_0(float4((kernelContext_2->islands_0+(uint4(_S10->info_1) ).y)->rotation_0) );
    float3 th_0 = (float4(*(kernelContext_2->state_0+(4U * c_1 + 1U))) ).xyz;
    Quat_0 hidden_0 = from_axis_angle_0(th_0, length(th_0));
    thread Box_0 b_1;
    (&b_1)->center_1 = center_2;
    float4 _S11 = float4(_S10->crot0_0) ;
    float4 _S12 = float4(_S10->crot1_0) ;
    float4 _S13 = float4(_S10->crot2_0) ;
    float3 _S14 = float3(_S11.x, _S12.x, _S13.x);
    thread Quat_0 _S15 = hidden_0;
    float3 _S16 = rotate_0(&_S15, _S14);
    thread Quat_0 _S17 = q_5;
    float3 _S18 = rotate_0(&_S17, _S16);
    (&b_1)->axis0_0 = _S18;
    float3 _S19 = float3(_S11.y, _S12.y, _S13.y);
    thread Quat_0 _S20 = hidden_0;
    float3 _S21 = rotate_0(&_S20, _S19);
    thread Quat_0 _S22 = q_5;
    float3 _S23 = rotate_0(&_S22, _S21);
    (&b_1)->axis1_0 = _S23;
    float3 _S24 = float3(_S11.z, _S12.z, _S13.z);
    thread Quat_0 _S25 = hidden_0;
    float3 _S26 = rotate_0(&_S25, _S24);
    thread Quat_0 _S27 = q_5;
    float3 _S28 = rotate_0(&_S27, _S26);
    (&b_1)->axis2_0 = _S28;
    (&b_1)->half_2 = (float4(_S10->half_0) ).xyz;
    float4 _S29 = float4(_S10->cmat_0) ;
    (&b_1)->hull_at_0 = (as_type<uint>((_S29.z)));
    uint _S30 = (as_type<uint>((_S29.w)));
    (&b_1)->hull_v_0 = _S30 & 255U;
    (&b_1)->hull_f_0 = _S30 >> 8U;
    return b_1;
}

uint sample_count_0(const Box_0 thread* b_2)
{
    uint _S31 = b_2->hull_v_0;
    uint _S32;
    if((b_2->hull_v_0) == 0U)
    {
        _S32 = 14U;
    }
    else
    {
        _S32 = _S31 + b_2->hull_f_0;
    }
    return _S32;
}

bool may_overlap_0(const Box_0 thread* a_2, const Box_0 thread* b_3)
{
    float3 _S33 = b_3->center_1 - a_2->center_1;
    float3 _S34 = a_2->half_2;
    float3 _S35 = b_3->half_2;
    float _S36 = 0.00000999999974738f * (length(a_2->half_2) + length(b_3->half_2));
    float3 _S37 = a_2->axis0_0;
    float3 _S38 = a_2->axis1_0;
    float3 _S39 = a_2->axis2_0;
    float3 _S40 = b_3->axis0_0;
    float3 _S41 = b_3->axis1_0;
    float3 _S42 = b_3->axis2_0;
    array<float3, int(6)> _S43 = { { a_2->axis0_0, a_2->axis1_0, a_2->axis2_0, b_3->axis0_0, b_3->axis1_0, b_3->axis2_0 } };
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
            l_0 = _S43[i_0];
        }
        else
        {
            uint _S44 = i_0 - 6U;
            l_0 = cross(_S43[_S44 / 3U], _S43[3U + _S44 % 3U]);
        }
        float len_0 = length(l_0);
        if(len_0 <= 9.99999997475242708e-07f)
        {
            i_0 = i_0 + 1U;
            continue;
        }
        if((abs(dot(_S33, l_0))) > (_S34.x * abs(dot(_S37, l_0)) + _S34.y * abs(dot(_S38, l_0)) + _S34.z * abs(dot(_S39, l_0)) + (_S35.x * abs(dot(_S40, l_0)) + _S35.y * abs(dot(_S41, l_0)) + _S35.z * abs(dot(_S42, l_0))) + _S36 * len_0))
        {
            return false;
        }
        i_0 = i_0 + 1U;
    }
    return true;
}

void chunk_velocity_0(uint c_2, float3 thread* v_3, float3 thread* w_2, KernelContext_0 thread* kernelContext_3)
{
    ChunkStatic_natural_0 device* _S45 = kernelContext_3->chunks_0+c_2;
    Island_natural_0 device* _S46 = kernelContext_3->islands_0+(uint4(_S45->info_1) ).y;
    Quat_0 q_6 = quat_of_0(float4(_S46->rotation_0) );
    uint _S47 = 4U * c_2;
    float3 _S48 = (float4(_S45->center_0) ).xyz + (float4(*(kernelContext_3->state_0+_S47)) ).xyz - (float4(_S46->com_0) ).xyz;
    thread Quat_0 _S49 = q_6;
    float3 _S50 = rotate_0(&_S49, _S48);
    float3 _S51 = (float4(_S46->angular_velocity_0) ).xyz;
    float3 _S52 = (float4(_S46->velocity_0) ).xyz + (float4(_S46->velocity_err_0) ).xyz + cross(_S51, _S50);
    float3 _S53 = (float4(*(kernelContext_3->state_0+(_S47 + 2U))) ).xyz;
    thread Quat_0 _S54 = q_6;
    float3 _S55 = rotate_0(&_S54, _S53);
    *v_3 = _S52 + _S55;
    float3 _S56 = (float4(*(kernelContext_3->state_0+(_S47 + 3U))) ).xyz;
    thread Quat_0 _S57 = q_6;
    float3 _S58 = rotate_0(&_S57, _S56);
    *w_2 = _S51 + _S58;
    return;
}

float3 box_to_world_0(const Box_0 thread* b_4, float3 local_0)
{
    return b_4->axis0_0 * float3(local_0.x)  + b_4->axis1_0 * float3(local_0.y)  + b_4->axis2_0 * float3(local_0.z) ;
}

float3 box_axis_0(const Box_0 thread* b_5, uint k_0)
{
    float3 _S59;
    if(k_0 == 0U)
    {
        _S59 = b_5->axis0_0;
    }
    else
    {
        if(k_0 == 1U)
        {
            _S59 = b_5->axis1_0;
        }
        else
        {
            _S59 = b_5->axis2_0;
        }
    }
    return _S59;
}

float comp3_0(float3 v_4, uint k_1)
{
    float _S60;
    if(k_1 == 0U)
    {
        _S60 = v_4.x;
    }
    else
    {
        if(k_1 == 1U)
        {
            _S60 = v_4.y;
        }
        else
        {
            _S60 = v_4.z;
        }
    }
    return _S60;
}

float3 sample_point_0(const Box_0 thread* b_6, uint i_1, KernelContext_0 thread* kernelContext_4)
{
    uint _S61 = b_6->hull_v_0;
    if((b_6->hull_v_0) != 0U)
    {
        float3 local_1;
        if(i_1 < _S61)
        {
            local_1 = (float4(*(kernelContext_4->loads_0+(b_6->hull_at_0 + i_1))) ).xyz * float3(0.89999997615814209f) ;
        }
        else
        {
            local_1 = (float4(*(kernelContext_4->loads_0+(b_6->hull_at_0 + _S61 + b_6->hull_f_0 + (i_1 - _S61)))) ).xyz;
        }
        float3 _S62 = b_6->center_1;
        float3 _S63 = box_to_world_0(b_6, local_1);
        return _S62 + _S63;
    }
    float sign_0;
    if(i_1 < 8U)
    {
        float3 h_0 = b_6->half_2 * float3(0.89999997615814209f) ;
        if((i_1 & 1U) == 0U)
        {
            sign_0 = - h_0.x;
        }
        else
        {
            sign_0 = h_0.x;
        }
        float _S64;
        if((i_1 & 2U) == 0U)
        {
            _S64 = - h_0.y;
        }
        else
        {
            _S64 = h_0.y;
        }
        float _S65;
        if((i_1 & 4U) == 0U)
        {
            _S65 = - h_0.z;
        }
        else
        {
            _S65 = h_0.z;
        }
        return b_6->center_1 + b_6->axis0_0 * float3(sign_0)  + b_6->axis1_0 * float3(_S64)  + b_6->axis2_0 * float3(_S65) ;
    }
    uint _S66 = i_1 - 8U;
    uint axis_1 = _S66 / 2U;
    if((_S66 % 2U) == 0U)
    {
        sign_0 = -1.0f;
    }
    else
    {
        sign_0 = 1.0f;
    }
    float3 _S67 = b_6->center_1;
    float3 _S68 = box_axis_0(b_6, axis_1);
    return _S67 + _S68 * float3((sign_0 * comp3_0(b_6->half_2, axis_1))) ;
}

float3 sample_point_1(const Box_0 thread* b_7, uint i_2, KernelContext_0 thread* kernelContext_5)
{
    uint _S69 = b_7->hull_v_0;
    if((b_7->hull_v_0) != 0U)
    {
        float3 local_2;
        if(i_2 < _S69)
        {
            local_2 = (float4(*(kernelContext_5->loads_0+(b_7->hull_at_0 + i_2))) ).xyz * float3(0.89999997615814209f) ;
        }
        else
        {
            local_2 = (float4(*(kernelContext_5->loads_0+(b_7->hull_at_0 + _S69 + b_7->hull_f_0 + (i_2 - _S69)))) ).xyz;
        }
        float3 _S70 = b_7->center_1;
        float3 _S71 = box_to_world_0(b_7, local_2);
        return _S70 + _S71;
    }
    float sign_1;
    if(i_2 < 8U)
    {
        float3 h_1 = b_7->half_2 * float3(0.89999997615814209f) ;
        if((i_2 & 1U) == 0U)
        {
            sign_1 = - h_1.x;
        }
        else
        {
            sign_1 = h_1.x;
        }
        float _S72;
        if((i_2 & 2U) == 0U)
        {
            _S72 = - h_1.y;
        }
        else
        {
            _S72 = h_1.y;
        }
        float _S73;
        if((i_2 & 4U) == 0U)
        {
            _S73 = - h_1.z;
        }
        else
        {
            _S73 = h_1.z;
        }
        return b_7->center_1 + b_7->axis0_0 * float3(sign_1)  + b_7->axis1_0 * float3(_S72)  + b_7->axis2_0 * float3(_S73) ;
    }
    uint _S74 = i_2 - 8U;
    uint axis_2 = _S74 / 2U;
    if((_S74 % 2U) == 0U)
    {
        sign_1 = -1.0f;
    }
    else
    {
        sign_1 = 1.0f;
    }
    float3 _S75 = b_7->center_1;
    float3 _S76 = box_axis_0(b_7, axis_2);
    return _S75 + _S76 * float3((sign_1 * comp3_0(b_7->half_2, axis_2))) ;
}

float3 box_to_local_0(const Box_0 thread* b_8, float3 r_1)
{
    return float3(dot(r_1, b_8->axis0_0), dot(r_1, b_8->axis1_0), dot(r_1, b_8->axis2_0));
}

float hull_signed_distance_0(const Box_0 thread* b_9, float3 local_3, uint thread* face_0, KernelContext_0 thread* kernelContext_6)
{
    *face_0 = 0U;
    float best_0 = -1.00000001504746622e+30f;
    uint f_0 = 0U;
    for(;;)
    {
        if(f_0 < (b_9->hull_f_0))
        {
        }
        else
        {
            break;
        }
        float4 _S77 = float4(*(kernelContext_6->loads_0+(b_9->hull_at_0 + b_9->hull_v_0 + f_0))) ;
        float d_0 = dot(_S77.xyz, local_3) - _S77.w;
        if(d_0 > best_0)
        {
            *face_0 = f_0;
            best_0 = d_0;
        }
        f_0 = f_0 + 1U;
    }
    return best_0;
}

bool penetration_0(const Box_0 thread* b_10, float3 p_0, float thread* depth_0, float3 thread* normal_1, KernelContext_0 thread* kernelContext_7)
{
    *depth_0 = 0.0f;
    *normal_1 = float3(0.0f) ;
    float3 r_2 = p_0 - b_10->center_1;
    float3 _S78 = b_10->half_2;
    if((dot(r_2, r_2)) > (dot(b_10->half_2, b_10->half_2) * 1.00001001358032227f))
    {
        return false;
    }
    uint _S79 = b_10->hull_v_0;
    if((b_10->hull_v_0) != 0U)
    {
        float3 _S80 = box_to_local_0(b_10, r_2);
        thread uint face_1;
        float _S81 = hull_signed_distance_0(b_10, _S80, &face_1, kernelContext_7);
        if(!(_S81 < 0.0f))
        {
            return false;
        }
        *depth_0 = - _S81;
        float3 _S82 = box_to_world_0(b_10, (float4(*(kernelContext_7->loads_0+(b_10->hull_at_0 + _S79 + face_1))) ).xyz);
        *normal_1 = _S82;
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
        float3 _S83 = box_axis_0(b_10, k_2);
        float local_4 = dot(r_2, _S83);
        float d_1 = comp3_0(_S78, k_2) - abs(local_4);
        if(d_1 <= 0.0f)
        {
            return false;
        }
        if(d_1 < best_1)
        {
            float _S84;
            if(local_4 >= 0.0f)
            {
                _S84 = 1.0f;
            }
            else
            {
                _S84 = -1.0f;
            }
            best_1 = d_1;
            axis_3 = k_2;
            side_0 = _S84;
        }
        k_2 = k_2 + 1U;
    }
    *depth_0 = best_1;
    float3 _S85 = box_axis_0(b_10, axis_3);
    *normal_1 = _S85 * float3(side_0) ;
    return true;
}

bool penetration_1(const Box_0 thread* b_11, float3 p_1, float thread* depth_1, float3 thread* normal_2, KernelContext_0 thread* kernelContext_8)
{
    *depth_1 = 0.0f;
    *normal_2 = float3(0.0f) ;
    float3 r_3 = p_1 - b_11->center_1;
    float3 _S86 = b_11->half_2;
    if((dot(r_3, r_3)) > (dot(b_11->half_2, b_11->half_2) * 1.00001001358032227f))
    {
        return false;
    }
    uint _S87 = b_11->hull_v_0;
    if((b_11->hull_v_0) != 0U)
    {
        float3 _S88 = box_to_local_0(b_11, r_3);
        thread uint face_2;
        float _S89 = hull_signed_distance_0(b_11, _S88, &face_2, kernelContext_8);
        if(!(_S89 < 0.0f))
        {
            return false;
        }
        *depth_1 = - _S89;
        float3 _S90 = box_to_world_0(b_11, (float4(*(kernelContext_8->loads_0+(b_11->hull_at_0 + _S87 + face_2))) ).xyz);
        *normal_2 = _S90;
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
        float3 _S91 = box_axis_0(b_11, k_3);
        float local_5 = dot(r_3, _S91);
        float d_2 = comp3_0(_S86, k_3) - abs(local_5);
        if(d_2 <= 0.0f)
        {
            return false;
        }
        if(d_2 < best_2)
        {
            float _S92;
            if(local_5 >= 0.0f)
            {
                _S92 = 1.0f;
            }
            else
            {
                _S92 = -1.0f;
            }
            best_2 = d_2;
            axis_4 = k_3;
            side_1 = _S92;
        }
        k_3 = k_3 + 1U;
    }
    *depth_1 = best_2;
    float3 _S93 = box_axis_0(b_11, axis_4);
    *normal_2 = _S93 * float3(side_1) ;
    return true;
}

bool pair_point_0(const Box_0 thread* ba_0, const Box_0 thread* bb_0, uint na_0, uint e_0, float3 thread* p_2, float3 thread* n_1, float thread* d_3, KernelContext_0 thread* kernelContext_9)
{
    if(e_0 < na_0)
    {
        float3 _S94 = sample_point_1(ba_0, e_0, kernelContext_9);
        *p_2 = _S94;
        bool _S95 = penetration_1(bb_0, _S94, d_3, n_1, kernelContext_9);
        return _S95;
    }
    float3 _S96 = sample_point_1(bb_0, e_0 - na_0, kernelContext_9);
    *p_2 = _S96;
    bool _S97 = penetration_1(ba_0, _S96, d_3, n_1, kernelContext_9);
    if(!_S97)
    {
        return false;
    }
    *n_1 = - *n_1;
    return true;
}

bool is_nan_0(float x_1)
{
    return ((as_type<uint>((x_1))) & 2147483647U) > 2139095040U;
}

float2 half_thickness_and_area_0(const Box_0 thread* b_12, float3 d_4)
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
        float3 _S98 = box_axis_0(b_12, k_4);
        float c_3 = abs(dot(d_4, _S98));
        float h_3 = h_2 + c_3 * comp3_0(b_12->half_2, k_4);
        uint _S99 = k_4 + 1U;
        float area_1 = area_0 + c_3 * 4.0f * comp3_0(b_12->half_2, _S99 % 3U) * comp3_0(b_12->half_2, (k_4 + 2U) % 3U);
        k_4 = _S99;
        h_2 = h_3;
        area_0 = area_1;
    }
    return float2(h_2, area_0);
}

float contact_stiffness_0(float ea_0, const Box_0 thread* a_3, float eb_0, const Box_0 thread* b_13, float3 dir_0)
{
    float3 d_5 = safe_normalize_0(dir_0);
    float2 _S100 = half_thickness_and_area_0(a_3, d_5);
    float2 _S101 = half_thickness_and_area_0(b_13, d_5);
    return min(_S100.y, _S101.y) / (_S100.x / ea_0 + _S101.x / eb_0);
}

float3 penalty_force_0(float k_5, float m_red_0, float friction_0, float depth_2, float3 normal_3, float3 rel_velocity_0, float dt_1, uint points_0, float thread* stored_0, float thread* dissipated_1, KernelContext_0 thread* kernelContext_10)
{
    float c_max_0 = 1.0f / max(float(points_0), 10.0f) * m_red_0 / dt_1;
    float vn_0 = dot(rel_velocity_0, normal_3);
    float _S102 = k_5 * depth_2;
    float _S103 = min(2.0f * kernelContext_10->params_0->zeta_0 * sqrt(k_5 * m_red_0), c_max_0) * vn_0;
    float _S104 = _S102 - _S103;
    float _S105 = max(_S104, 0.0f);
    float3 vt_0 = rel_velocity_0 - normal_3 * float3(vn_0) ;
    float vt_mag_0 = length(vt_0);
    float _S106 = friction_0 * _S105;
    float _S107 = min(_S106, min(c_max_0, _S106 / 0.00100000004749745f) * vt_mag_0);
    float3 ft_0;
    if(vt_mag_0 > 0.0f)
    {
        ft_0 = - vt_0 * float3((_S107 / vt_mag_0)) ;
    }
    else
    {
        ft_0 = float3(0.0f) ;
    }
    *stored_0 = 0.5f * k_5 * depth_2 * depth_2;
    float damping_power_0;
    if(_S104 > 0.0f)
    {
        damping_power_0 = _S103 * vn_0;
    }
    else
    {
        damping_power_0 = _S102 * max(vn_0, 0.0f);
    }
    *dissipated_1 = (damping_power_0 + length(ft_0) * vt_mag_0) * dt_1;
    return normal_3 * float3(_S105)  + ft_0;
}

void comp_add1_0(float thread* sum_0, float thread* err_0, float x_2)
{
    float t_2 = *sum_0 + x_2;
    if((abs(*sum_0)) >= (abs(x_2)))
    {
        *err_0 = *err_0 + (*sum_0 - t_2 + x_2);
    }
    else
    {
        *err_0 = *err_0 + (x_2 - t_2 + *sum_0);
    }
    *sum_0 = t_2;
    return;
}

void pair_contact_0(uint i_3, KernelContext_0 thread* kernelContext_11)
{
    uint at_0 = kernelContext_11->params_0->pair_index_0 + 6U * i_3;
    uint ca_0 = kernelContext_11->index_0[at_0];
    uint cb_0 = kernelContext_11->index_0[at_0 + 1U];
    uint _S108 = kernelContext_11->index_0[at_0 + 3U];
    float _S109 = (as_type<float>((kernelContext_11->index_0[at_0 + 4U])));
    float _S110 = (as_type<float>((kernelContext_11->index_0[at_0 + 5U])));
    float _S111 = kernelContext_11->params_0->dt_0;
    uint out_0 = kernelContext_11->params_0->slot_base_0 + 2U * kernelContext_11->index_0[at_0 + 2U];
    WorldPoint_0 _S112 = chunk_world_0(ca_0, kernelContext_11);
    WorldPoint_0 _S113 = chunk_world_0(cb_0, kernelContext_11);
    thread WorldPoint_0 _S114 = _S113;
    thread WorldPoint_0 _S115 = _S112;
    float3 _S116 = world_diff_0(&_S114, &_S115);
    bool touching_0 = !((length(_S116)) > ((float4((kernelContext_11->chunks_0+ca_0)->half_0) ).w + (float4((kernelContext_11->chunks_0+cb_0)->half_0) ).w));
    float4 _S117 = float4(*(kernelContext_11->scratch_0+(kernelContext_11->params_0->ledger_base_0 + i_3))) ;
    thread float4 ledger_1 = _S117;
    uint flags_0 = (as_type<uint>((_S117.w)));
    float3 _S118 = float3(0.0f) ;
    Box_0 _S119 = chunk_box_0(ca_0, _S118, kernelContext_11);
    Box_0 _S120 = chunk_box_0(cb_0, _S116, kernelContext_11);
    thread Box_0 _S121 = _S119;
    uint _S122 = sample_count_0(&_S121);
    thread Box_0 _S123 = _S120;
    uint _S124 = sample_count_0(&_S123);
    uint _S125 = _S122 + _S124;
    uint e_1;
    bool has_state_0;
    if(!touching_0)
    {
        if((flags_0 & 1U) != 0U)
        {
            e_1 = 0U;
            for(;;)
            {
                if(e_1 < _S125)
                {
                }
                else
                {
                    break;
                }
                *(kernelContext_11->contact_state_0+(_S108 + e_1)) = packed_float4(float4((as_type<float>((2143289344U))), 0.0f, 0.0f, 0.0f)) ;
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
                *(kernelContext_11->scratch_0+(out_0 + e_1)) = packed_float4(float4(0.0f) ) ;
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
            *(kernelContext_11->scratch_0+(kernelContext_11->params_0->ledger_base_0 + i_3)) = packed_float4(ledger_1) ;
        }
        return;
    }
    thread Box_0 _S126 = _S119;
    thread Box_0 _S127 = _S120;
    bool _S128 = may_overlap_0(&_S126, &_S127);
    uint count_0;
    float3 fa_0;
    float3 ta_0;
    float3 fb_0;
    float3 tb_0;
    float stored_sum_0;
    if(_S128)
    {
        thread float3 va0_0;
        thread float3 wa0_0;
        chunk_velocity_0(ca_0, &va0_0, &wa0_0, kernelContext_11);
        thread float3 vb0_0;
        thread float3 wb0_0;
        chunk_velocity_0(cb_0, &vb0_0, &wb0_0, kernelContext_11);
        e_1 = 0U;
        count_0 = 0U;
        uint engaged_0 = 0U;
        for(;;)
        {
            if(e_1 < _S125)
            {
            }
            else
            {
                break;
            }
            thread Box_0 _S129 = _S119;
            thread Box_0 _S130 = _S120;
            thread float3 p_3;
            thread float3 n_2;
            thread float d_6;
            bool _S131 = pair_point_0(&_S129, &_S130, _S122, e_1, &p_3, &n_2, &d_6, kernelContext_11);
            if(!_S131)
            {
                uint _S132 = _S108 + e_1;
                if(!is_nan_0((float4(*(kernelContext_11->contact_state_0+_S132)) ).x))
                {
                    *(kernelContext_11->contact_state_0+_S132) = packed_float4(float4((as_type<float>((2143289344U))), 0.0f, 0.0f, 0.0f)) ;
                }
                e_1 = e_1 + 1U;
                continue;
            }
            uint _S133 = count_0 + 1U;
            uint _S134 = _S108 + e_1;
            float4 _S135 = float4(*(kernelContext_11->contact_state_0+_S134)) ;
            thread float4 entry_0 = _S135;
            if(is_nan_0(_S135.x))
            {
                has_state_0 = true;
            }
            else
            {
                has_state_0 = (dot(entry_0.yzw, n_2)) < 0.99000000953674316f;
            }
            if(has_state_0)
            {
                if(d_6 > (2.0f * abs(dot(va0_0 + cross(wa0_0, p_3) - (vb0_0 + cross(wb0_0, p_3 - _S120.center_1)), n_2)) * _S111 + 9.99999971718068537e-10f))
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
            *(kernelContext_11->contact_state_0+_S134) = packed_float4(entry_0) ;
            uint engaged_1;
            if((d_6 - entry_0.x) > 0.0f)
            {
                engaged_1 = engaged_0 + 1U;
            }
            else
            {
                engaged_1 = engaged_0;
            }
            count_0 = _S133;
            engaged_0 = engaged_1;
            e_1 = e_1 + 1U;
        }
        if(count_0 > 0U)
        {
            float _S136 = (float4((kernelContext_11->chunks_0+ca_0)->cmat_0) ).x;
            float _S137 = (float4((kernelContext_11->chunks_0+cb_0)->cmat_0) ).x;
            float3 _S138 = _S120.center_1 - _S119.center_1;
            thread Box_0 _S139 = _S119;
            thread Box_0 _S140 = _S120;
            float _S141 = contact_stiffness_0(_S136, &_S139, _S137, &_S140, _S138);
            float _S142 = _S141 / max(float(engaged_0), 10.0f);
            e_1 = 0U;
            fa_0 = _S118;
            ta_0 = _S118;
            fb_0 = _S118;
            tb_0 = _S118;
            stored_sum_0 = 0.0f;
            for(;;)
            {
                if(e_1 < _S125)
                {
                }
                else
                {
                    break;
                }
                thread Box_0 _S143 = _S119;
                thread Box_0 _S144 = _S120;
                thread float3 p_4;
                thread float3 n_3;
                thread float d_7;
                bool _S145 = pair_point_0(&_S143, &_S144, _S122, e_1, &p_4, &n_3, &d_7, kernelContext_11);
                if(!_S145)
                {
                    e_1 = e_1 + 1U;
                    continue;
                }
                float eff_0 = d_7 - (float4(*(kernelContext_11->contact_state_0+(_S108 + e_1))) ).x;
                if(eff_0 <= 0.0f)
                {
                    e_1 = e_1 + 1U;
                    continue;
                }
                thread float stored_1;
                thread float diss_0;
                float3 _S146 = penalty_force_0(_S142, _S109, _S110, eff_0, n_3, va0_0 + cross(wa0_0, p_4) - (vb0_0 + cross(wb0_0, p_4 - _S120.center_1)), _S111, engaged_0, &stored_1, &diss_0, kernelContext_11);
                float3 fa_1 = fa_0 + _S146;
                float3 ta_1 = ta_0 + cross(p_4, _S146);
                float3 _S147 = - _S146;
                float3 fb_1 = fb_0 + _S147;
                float3 tb_1 = tb_0 + cross(p_4 - _S120.center_1, _S147);
                float stored_sum_1 = stored_sum_0 + stored_1;
                thread float _S148 = ledger_1.y;
                thread float _S149 = ledger_1.z;
                comp_add1_0(&_S148, &_S149, diss_0);
                ledger_1.z = _S149;
                ledger_1.y = _S148;
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
            fa_0 = _S118;
            ta_0 = _S118;
            fb_0 = _S118;
            tb_0 = _S118;
            stored_sum_0 = 0.0f;
        }
    }
    else
    {
        has_state_0 = false;
        fa_0 = _S118;
        ta_0 = _S118;
        fb_0 = _S118;
        tb_0 = _S118;
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
            if(e_1 < _S125)
            {
            }
            else
            {
                break;
            }
            *(kernelContext_11->contact_state_0+(_S108 + e_1)) = packed_float4(float4((as_type<float>((2143289344U))), 0.0f, 0.0f, 0.0f)) ;
            e_1 = e_1 + 1U;
        }
    }
    float3 _S150 = float3(0.0f) ;
    if(any(fa_0 != _S150))
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any(ta_0 != _S150);
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any(fb_0 != _S150);
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any(tb_0 != _S150);
    }
    bool _S151;
    if(loaded_0)
    {
        _S151 = true;
    }
    else
    {
        _S151 = (flags_0 & 2U) != 0U;
    }
    if(_S151)
    {
        *(kernelContext_11->scratch_0+out_0) = packed_float4(float4(fa_0, 0.0f)) ;
        *(kernelContext_11->scratch_0+(out_0 + 1U)) = packed_float4(float4(ta_0, 0.0f)) ;
        *(kernelContext_11->scratch_0+(out_0 + 2U)) = packed_float4(float4(fb_0, 0.0f)) ;
        *(kernelContext_11->scratch_0+(out_0 + 3U)) = packed_float4(float4(tb_0, 0.0f)) ;
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
    *(kernelContext_11->scratch_0+(kernelContext_11->params_0->ledger_base_0 + i_3)) = packed_float4(ledger_1) ;
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
    thread Box_0 b_14;
    (&b_14)->center_1 = center_3;
    float3 _S152 = float3(1.0f, 0.0f, 0.0f);
    thread Quat_0 _S153 = q_7;
    float3 _S154 = rotate_0(&_S153, _S152);
    (&b_14)->axis0_0 = _S154;
    float3 _S155 = float3(0.0f, 1.0f, 0.0f);
    thread Quat_0 _S156 = q_7;
    float3 _S157 = rotate_0(&_S156, _S155);
    (&b_14)->axis1_0 = _S157;
    float3 _S158 = float3(0.0f, 0.0f, 1.0f);
    thread Quat_0 _S159 = q_7;
    float3 _S160 = rotate_0(&_S159, _S158);
    (&b_14)->axis2_0 = _S160;
    (&b_14)->half_2 = half_3;
    (&b_14)->hull_at_0 = 0U;
    (&b_14)->hull_v_0 = 0U;
    (&b_14)->hull_f_0 = 0U;
    return b_14;
}

uint impactor_slots_0(const Impactor_natural_0 thread* imp_1, const Box_0 thread* b_15)
{
    uint _S161;
    if(((float4(imp_1->shape_0) ).x) == 0.0f)
    {
        _S161 = 1U;
    }
    else
    {
        uint _S162 = sample_count_0(b_15);
        _S161 = _S162 + 14U;
    }
    return _S161;
}

uint impactor_slots_1(const Impactor_natural_0 thread* imp_2, const Box_0 thread* b_16)
{
    uint _S163;
    if(((float4(imp_2->shape_0) ).x) == 0.0f)
    {
        _S163 = 1U;
    }
    else
    {
        uint _S164 = sample_count_0(b_16);
        _S163 = _S164 + 14U;
    }
    return _S163;
}

bool sphere_contact_0(const Box_0 thread* b_17, float3 center_4, float radius_0, float3 thread* point_0, float3 thread* normal_4, float thread* depth_3, KernelContext_0 thread* kernelContext_12)
{
    float3 _S165 = float3(0.0f) ;
    *point_0 = _S165;
    *normal_4 = _S165;
    *depth_3 = 0.0f;
    float3 _S166 = b_17->center_1;
    float3 r_4 = center_4 - b_17->center_1;
    float3 _S167 = b_17->axis0_0;
    float3 _S168 = b_17->axis1_0;
    float3 _S169 = b_17->axis2_0;
    float3 local_6 = float3(dot(r_4, b_17->axis0_0), dot(r_4, b_17->axis1_0), dot(r_4, b_17->axis2_0));
    uint _S170 = b_17->hull_v_0;
    if((b_17->hull_v_0) != 0U)
    {
        thread uint face_3;
        float _S171 = hull_signed_distance_0(b_17, local_6, &face_3, kernelContext_12);
        if(_S171 >= radius_0)
        {
            return false;
        }
        float3 _S172 = box_to_world_0(b_17, (float4(*(kernelContext_12->loads_0+(b_17->hull_at_0 + _S170 + face_3))) ).xyz);
        *normal_4 = _S172;
        *point_0 = center_4 - _S172 * float3(max(_S171, 0.0f)) ;
        *depth_3 = radius_0 - _S171;
        return true;
    }
    float3 q_8 = clamp(local_6, - b_17->half_2, b_17->half_2);
    float3 d_8 = local_6 - q_8;
    float dist_0 = length(d_8);
    if(dist_0 > 9.999999960041972e-13f)
    {
        if(dist_0 >= radius_0)
        {
            return false;
        }
        float3 dn_0 = d_8 / float3(dist_0) ;
        *normal_4 = _S167 * float3(dn_0.x)  + _S168 * float3(dn_0.y)  + _S169 * float3(dn_0.z) ;
        *point_0 = _S166 + _S167 * float3(q_8.x)  + _S168 * float3(q_8.y)  + _S169 * float3(q_8.z) ;
        *depth_3 = radius_0 - dist_0;
        return true;
    }
    thread float inside_0;
    thread float3 n_4;
    bool _S173 = penetration_0(b_17, center_4, &inside_0, &n_4, kernelContext_12);
    if(!_S173)
    {
        return false;
    }
    *normal_4 = n_4;
    *point_0 = center_4 - n_4 * float3(min(radius_0, inside_0)) ;
    *depth_3 = radius_0 + inside_0;
    return true;
}

bool impactor_contact_0(const Impactor_natural_0 thread* imp_3, float crush_depth_0, const Box_0 thread* shrunk_0, const Box_0 thread* b_18, uint j_0, float3 thread* p_5, float3 thread* n_5, float thread* d_9, KernelContext_0 thread* kernelContext_13)
{
    float3 _S174 = float3(0.0f) ;
    *p_5 = _S174;
    *n_5 = _S174;
    *d_9 = 0.0f;
    float4 _S175 = float4(imp_3->shape_0) ;
    if((_S175.x) == 0.0f)
    {
        bool _S176 = sphere_contact_0(b_18, _S174, _S175.y - crush_depth_0, p_5, n_5, d_9, kernelContext_13);
        if(!_S176)
        {
            return false;
        }
        *n_5 = - *n_5;
        return true;
    }
    uint _S177 = sample_count_0(b_18);
    if(j_0 < _S177)
    {
        float3 _S178 = sample_point_0(b_18, j_0, kernelContext_13);
        *p_5 = _S178;
        bool _S179 = penetration_0(shrunk_0, _S178, d_9, n_5, kernelContext_13);
        return _S179;
    }
    float3 _S180 = sample_point_0(shrunk_0, j_0 - _S177, kernelContext_13);
    *p_5 = _S180;
    bool _S181 = penetration_0(b_18, _S180, d_9, n_5, kernelContext_13);
    if(!_S181)
    {
        return false;
    }
    *n_5 = - *n_5;
    return true;
}

bool impactor_contact_1(const Impactor_natural_0 thread* imp_4, float crush_depth_1, const Box_0 thread* shrunk_1, const Box_0 thread* b_19, uint j_1, float3 thread* p_6, float3 thread* n_6, float thread* d_10, KernelContext_0 thread* kernelContext_14)
{
    float3 _S182 = float3(0.0f) ;
    *p_6 = _S182;
    *n_6 = _S182;
    *d_10 = 0.0f;
    float4 _S183 = float4(imp_4->shape_0) ;
    if((_S183.x) == 0.0f)
    {
        bool _S184 = sphere_contact_0(b_19, _S182, _S183.y - crush_depth_1, p_6, n_6, d_10, kernelContext_14);
        if(!_S184)
        {
            return false;
        }
        *n_6 = - *n_6;
        return true;
    }
    uint _S185 = sample_count_0(b_19);
    if(j_1 < _S185)
    {
        float3 _S186 = sample_point_0(b_19, j_1, kernelContext_14);
        *p_6 = _S186;
        bool _S187 = penetration_0(shrunk_1, _S186, d_10, n_6, kernelContext_14);
        return _S187;
    }
    float3 _S188 = sample_point_0(shrunk_1, j_1 - _S185, kernelContext_14);
    *p_6 = _S188;
    bool _S189 = penetration_0(b_19, _S188, d_10, n_6, kernelContext_14);
    if(!_S189)
    {
        return false;
    }
    *n_6 = - *n_6;
    return true;
}

WorldPoint_0 impactor_point_0(uint _S190, KernelContext_0 thread* kernelContext_15)
{
    Impactor_natural_0 device* _S191 = kernelContext_15->impactors_0+_S190;
    thread WorldPoint_0 wi_0;
    (&wi_0)->hi_0 = (float4(_S191->position_1) ).xyz;
    (&wi_0)->lo_0 = (float4(_S191->position_err_1) ).xyz;
    (&wi_0)->rel_0 = float3(0.0f) ;
    return wi_0;
}

Box_0 impactor_box_1(uint _S192, float3 _S193, float3 _S194, KernelContext_0 thread* kernelContext_16)
{
    Quat_0 q_9 = quat_of_0(float4((kernelContext_16->impactors_0+_S192)->rotation_1) );
    thread Box_0 b_20;
    (&b_20)->center_1 = _S193;
    float3 _S195 = float3(1.0f, 0.0f, 0.0f);
    thread Quat_0 _S196 = q_9;
    float3 _S197 = rotate_0(&_S196, _S195);
    (&b_20)->axis0_0 = _S197;
    float3 _S198 = float3(0.0f, 1.0f, 0.0f);
    thread Quat_0 _S199 = q_9;
    float3 _S200 = rotate_0(&_S199, _S198);
    (&b_20)->axis1_0 = _S200;
    float3 _S201 = float3(0.0f, 0.0f, 1.0f);
    thread Quat_0 _S202 = q_9;
    float3 _S203 = rotate_0(&_S202, _S201);
    (&b_20)->axis2_0 = _S203;
    (&b_20)->half_2 = _S194;
    (&b_20)->hull_at_0 = 0U;
    (&b_20)->hull_v_0 = 0U;
    (&b_20)->hull_f_0 = 0U;
    return b_20;
}

Box_0 impactor_shrunk_0(uint _S204, float _S205, const Box_0 thread* _S206)
{
    thread Box_0 shrunk_2 = *_S206;
    (&shrunk_2)->half_2 = _S206->half_2 - min(float3(_S205) , _S206->half_2 * float3(0.5f) );
    return shrunk_2;
}

bool impactor_contact_2(uint _S207, float _S208, const Box_0 thread* _S209, const Box_0 thread* _S210, uint _S211, float3 thread* _S212, float3 thread* _S213, float thread* _S214, KernelContext_0 thread* kernelContext_17)
{
    Impactor_natural_0 _S215 = *(kernelContext_17->impactors_0+_S207);
    float3 _S216 = float3(0.0f) ;
    *_S212 = _S216;
    *_S213 = _S216;
    *_S214 = 0.0f;
    float4 _S217 = float4(_S215.shape_0) ;
    if((_S217.x) == 0.0f)
    {
        bool _S218 = sphere_contact_0(_S210, _S216, _S217.y - _S208, _S212, _S213, _S214, kernelContext_17);
        if(!_S218)
        {
            return false;
        }
        *_S213 = - *_S213;
        return true;
    }
    uint _S219 = sample_count_0(_S210);
    if(_S211 < _S219)
    {
        float3 _S220 = sample_point_0(_S210, _S211, kernelContext_17);
        *_S212 = _S220;
        bool _S221 = penetration_0(_S209, _S220, _S214, _S213, kernelContext_17);
        return _S221;
    }
    float3 _S222 = sample_point_0(_S209, _S211 - _S219, kernelContext_17);
    *_S212 = _S222;
    bool _S223 = penetration_0(_S210, _S222, _S214, _S213, kernelContext_17);
    if(!_S223)
    {
        return false;
    }
    *_S213 = - *_S213;
    return true;
}

uint impactor_contact_count_0(uint _S224, float _S225, const Box_0 thread* _S226, const Box_0 thread* _S227, KernelContext_0 thread* kernelContext_18)
{
    thread Impactor_natural_0 _S228 = *(kernelContext_18->impactors_0+_S224);
    uint j_2 = 0U;
    uint count_1 = 0U;
    for(;;)
    {
        uint _S229 = impactor_slots_1(&_S228, _S227);
        if(j_2 < _S229)
        {
        }
        else
        {
            break;
        }
        thread float3 p_7;
        thread float3 n_7;
        thread float d_11;
        bool _S230 = impactor_contact_2(_S224, _S225, _S226, _S227, j_2, &p_7, &n_7, &d_11, kernelContext_18);
        if(_S230)
        {
            count_1 = count_1 + 1U;
        }
        j_2 = j_2 + 1U;
    }
    return count_1;
}

void impactor_candidate_forces_0(uint k_6, KernelContext_0 thread* kernelContext_19)
{
    uint _S231 = 3U * k_6;
    uint at_1 = kernelContext_19->params_0->cand_index_0 + _S231;
    uint c_4 = kernelContext_19->index_0[at_1];
    uint slot_0 = kernelContext_19->index_0[at_1 + 1U];
    uint _S232 = kernelContext_19->index_0[at_1 + 2U];
    thread Impactor_natural_0 _S233 = *(kernelContext_19->impactors_0+_S232);
    float _S234 = kernelContext_19->params_0->dt_0;
    float3 _S235 = float3(0.0f) ;
    thread float4 data_0 = float4(*(kernelContext_19->scratch_0+(kernelContext_19->params_0->cand_base_0 + _S231))) ;
    float3 f_sum_0;
    float3 t_sum_0;
    float3 imp_f_0;
    float3 imp_t_0;
    if(((uint4((&_S233)->cand_0) ).z) == 0U)
    {
        WorldPoint_0 _S236 = chunk_world_0(c_4, kernelContext_19);
        WorldPoint_0 _S237 = impactor_point_0(_S232, kernelContext_19);
        thread WorldPoint_0 _S238 = _S236;
        thread WorldPoint_0 _S239 = _S237;
        float3 _S240 = world_diff_0(&_S238, &_S239);
        float4 _S241 = float4((&_S233)->half_1) ;
        if(!((length(_S240)) > (_S241.w + (float4((kernelContext_19->chunks_0+c_4)->half_0) ).w)))
        {
            Box_0 _S242 = impactor_box_1(_S232, _S235, _S241.xyz, kernelContext_19);
            Box_0 _S243 = chunk_box_0(c_4, _S240, kernelContext_19);
            float4 _S244 = float4((&_S233)->mat_0) ;
            float _S245 = _S244.x;
            float _S246 = (float4((kernelContext_19->chunks_0+c_4)->cmat_0) ).x;
            float3 _S247 = _S243.center_1 - _S242.center_1;
            thread Box_0 _S248 = _S242;
            thread Box_0 _S249 = _S243;
            float _S250 = contact_stiffness_0(_S245, &_S248, _S246, &_S249, _S247);
            float4 _S251 = float4((&_S233)->geom_0) ;
            float _S252 = _S251.y;
            thread Box_0 _S253 = _S242;
            Box_0 _S254 = impactor_shrunk_0(_S232, _S252, &_S253);
            thread Box_0 _S255 = _S254;
            thread Box_0 _S256 = _S243;
            uint _S257 = impactor_contact_count_0(_S232, _S252, &_S255, &_S256, kernelContext_19);
            bool _S258 = ((float4((&_S233)->shape_0) ).x) == 0.0f;
            float _S259;
            if(_S258)
            {
                _S259 = _S250;
            }
            else
            {
                _S259 = _S250 / max(float(_S257), 10.0f);
            }
            uint _S260;
            if(_S258)
            {
                _S260 = 1U;
            }
            else
            {
                _S260 = _S257;
            }
            float m_1 = (float4((kernelContext_19->chunks_0+c_4)->center_0) ).w;
            float _S261 = _S244.z;
            float _S262 = m_1 * _S261 / (m_1 + _S261);
            float _S263;
            if((kernelContext_19->params_0->pair_friction_0) >= 0.0f)
            {
                _S263 = kernelContext_19->params_0->pair_friction_0;
            }
            else
            {
                _S263 = min(_S244.y, (float4((kernelContext_19->chunks_0+c_4)->cmat_0) ).y);
            }
            float3 _S264 = (float4((&_S233)->velocity_1) ).xyz + (float4((&_S233)->velocity_err_1) ).xyz;
            thread float3 vc_0;
            thread float3 wc_0;
            chunk_velocity_0(c_4, &vc_0, &wc_0, kernelContext_19);
            uint j_3 = 0U;
            f_sum_0 = _S235;
            t_sum_0 = _S235;
            imp_f_0 = _S235;
            imp_t_0 = _S235;
            for(;;)
            {
                bool _S265;
                if(_S257 > 0U)
                {
                    thread Box_0 _S266 = _S243;
                    uint _S267 = impactor_slots_0(&_S233, &_S266);
                    _S265 = j_3 < _S267;
                }
                else
                {
                    _S265 = false;
                }
                if(_S265)
                {
                }
                else
                {
                    break;
                }
                thread Box_0 _S268 = _S254;
                thread Box_0 _S269 = _S243;
                thread float3 p_8;
                thread float3 nrm_0;
                thread float dep_0;
                bool _S270 = impactor_contact_0(&_S233, _S252, &_S268, &_S269, j_3, &p_8, &nrm_0, &dep_0, kernelContext_19);
                if(!_S270)
                {
                    j_3 = j_3 + 1U;
                    continue;
                }
                thread float stored_2;
                thread float diss_1;
                float3 _S271 = penalty_force_0(_S259, _S262, _S263, dep_0 * _S251.x, nrm_0, vc_0 + cross(wc_0, p_8 - _S243.center_1) - (_S264 + cross((float4((&_S233)->angular_velocity_1) ).xyz, p_8)), _S234, _S260, &stored_2, &diss_1, kernelContext_19);
                float3 f_sum_1 = f_sum_0 + _S271;
                float3 t_sum_1 = t_sum_0 + cross(p_8 - _S243.center_1, _S271);
                float3 imp_f_1 = imp_f_0 - _S271;
                float3 imp_t_1 = imp_t_0 - cross(p_8, _S271);
                thread float _S272 = data_0.z;
                thread float _S273 = data_0.w;
                comp_add1_0(&_S272, &_S273, diss_1);
                data_0.w = _S273;
                data_0.z = _S272;
                f_sum_0 = f_sum_1;
                t_sum_0 = t_sum_1;
                imp_f_0 = imp_f_1;
                imp_t_0 = imp_t_1;
                j_3 = j_3 + 1U;
            }
        }
        else
        {
            f_sum_0 = _S235;
            t_sum_0 = _S235;
            imp_f_0 = _S235;
            imp_t_0 = _S235;
        }
    }
    else
    {
        f_sum_0 = _S235;
        t_sum_0 = _S235;
        imp_f_0 = _S235;
        imp_t_0 = _S235;
    }
    uint _S274 = 2U * slot_0;
    *(kernelContext_19->scratch_0+(kernelContext_19->params_0->slot_base_0 + _S274)) = packed_float4(float4(f_sum_0, 0.0f)) ;
    *(kernelContext_19->scratch_0+(kernelContext_19->params_0->slot_base_0 + _S274 + 1U)) = packed_float4(float4(t_sum_0, 0.0f)) ;
    *(kernelContext_19->scratch_0+(kernelContext_19->params_0->cand_base_0 + _S231)) = packed_float4(data_0) ;
    *(kernelContext_19->scratch_0+(kernelContext_19->params_0->cand_base_0 + _S231 + 1U)) = packed_float4(float4(imp_f_0, 0.0f)) ;
    *(kernelContext_19->scratch_0+(kernelContext_19->params_0->cand_base_0 + _S231 + 2U)) = packed_float4(float4(imp_t_0, 0.0f)) ;
    return;
}

void travel_check_0(uint c_5, KernelContext_0 thread* kernelContext_20)
{
    ChunkStatic_natural_0 device* _S275 = kernelContext_20->chunks_0+c_5;
    if(((uint4(_S275->cinfo_0) ).z) == 0U)
    {
        return;
    }
    WorldPoint_0 _S276 = chunk_world_0(c_5, kernelContext_20);
    float4 _S277 = float4(_S275->start_hi_0) ;
    if((length(_S276.hi_0 - _S277.xyz + (_S276.lo_0 - (float4(_S275->start_lo_0) ).xyz) + _S276.rel_0)) > (_S277.w))
    {
        (kernelContext_20->islands_0+kernelContext_20->params_0->halt_index_0)->info_0[int(2)] = ((uint4((kernelContext_20->islands_0+kernelContext_20->params_0->halt_index_0)->info_0) ).z) | 1U;
    }
    return;
}

[[kernel]] void contact_forces(uint3 id_0 [[thread_position_in_grid]], Params_0 constant* params_1 [[buffer(0)]], Island_natural_0 device* islands_1 [[buffer(9)]], uint device* index_1 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_1 [[buffer(3)]], packed_float4 device* state_1 [[buffer(6)]], packed_float4 device* scratch_1 [[buffer(8)]], packed_float4 device* contact_state_1 [[buffer(11)]], packed_float4 device* loads_1 [[buffer(5)]], Impactor_natural_0 device* impactors_1 [[buffer(10)]], BondStatic_natural_0 device* bonds_1 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_1 [[buffer(7)]], MaterialTable_0 constant* materials_1 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_21;
    (&kernelContext_21)->params_0 = params_1;
    (&kernelContext_21)->islands_0 = islands_1;
    (&kernelContext_21)->index_0 = index_1;
    (&kernelContext_21)->chunks_0 = chunks_1;
    (&kernelContext_21)->state_0 = state_1;
    (&kernelContext_21)->scratch_0 = scratch_1;
    (&kernelContext_21)->contact_state_0 = contact_state_1;
    (&kernelContext_21)->loads_0 = loads_1;
    (&kernelContext_21)->impactors_0 = impactors_1;
    (&kernelContext_21)->bonds_0 = bonds_1;
    (&kernelContext_21)->bond_dyn_0 = bond_dyn_1;
    (&kernelContext_21)->materials_0 = materials_1;
    threadgroup array<float4, int(256)> g_red_a_1;
    (&kernelContext_21)->g_red_a_0 = &g_red_a_1;
    threadgroup array<float4, int(256)> g_red_b_1;
    (&kernelContext_21)->g_red_b_0 = &g_red_b_1;
    threadgroup uint g_run_1;
    (&kernelContext_21)->g_run_0 = &g_run_1;
    threadgroup uint g_halt_1;
    (&kernelContext_21)->g_halt_0 = &g_halt_1;
    threadgroup uint g_wide_run_1;
    (&kernelContext_21)->g_wide_run_0 = &g_wide_run_1;
    uint i_4 = id_0.x;
    bool _S278 = stopped_0(&kernelContext_21);
    if(_S278)
    {
        return;
    }
    if(i_4 < ((&kernelContext_21)->params_0->pair_count_0))
    {
        pair_contact_0(i_4, &kernelContext_21);
    }
    else
    {
        if(i_4 < ((&kernelContext_21)->params_0->pair_count_0 + (&kernelContext_21)->params_0->cand_count_0))
        {
            impactor_candidate_forces_0(i_4 - (&kernelContext_21)->params_0->pair_count_0, &kernelContext_21);
        }
        else
        {
            if(i_4 < ((&kernelContext_21)->params_0->pair_count_0 + (&kernelContext_21)->params_0->cand_count_0 + (&kernelContext_21)->params_0->chunk_count_0))
            {
                travel_check_0(i_4 - (&kernelContext_21)->params_0->pair_count_0 - (&kernelContext_21)->params_0->cand_count_0, &kernelContext_21);
            }
        }
    }
    return;
}

[[kernel]] void impactor_shares(uint3 id_1 [[thread_position_in_grid]], Params_0 constant* params_2 [[buffer(0)]], Island_natural_0 device* islands_2 [[buffer(9)]], uint device* index_2 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_2 [[buffer(3)]], packed_float4 device* state_2 [[buffer(6)]], packed_float4 device* scratch_2 [[buffer(8)]], packed_float4 device* contact_state_2 [[buffer(11)]], packed_float4 device* loads_2 [[buffer(5)]], Impactor_natural_0 device* impactors_2 [[buffer(10)]], BondStatic_natural_0 device* bonds_2 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_2 [[buffer(7)]], MaterialTable_0 constant* materials_2 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_22;
    (&kernelContext_22)->params_0 = params_2;
    (&kernelContext_22)->islands_0 = islands_2;
    (&kernelContext_22)->index_0 = index_2;
    (&kernelContext_22)->chunks_0 = chunks_2;
    (&kernelContext_22)->state_0 = state_2;
    (&kernelContext_22)->scratch_0 = scratch_2;
    (&kernelContext_22)->contact_state_0 = contact_state_2;
    (&kernelContext_22)->loads_0 = loads_2;
    (&kernelContext_22)->impactors_0 = impactors_2;
    (&kernelContext_22)->bonds_0 = bonds_2;
    (&kernelContext_22)->bond_dyn_0 = bond_dyn_2;
    (&kernelContext_22)->materials_0 = materials_2;
    threadgroup array<float4, int(256)> g_red_a_2;
    (&kernelContext_22)->g_red_a_0 = &g_red_a_2;
    threadgroup array<float4, int(256)> g_red_b_2;
    (&kernelContext_22)->g_red_b_0 = &g_red_b_2;
    threadgroup uint g_run_2;
    (&kernelContext_22)->g_run_0 = &g_run_2;
    threadgroup uint g_halt_2;
    (&kernelContext_22)->g_halt_0 = &g_halt_2;
    threadgroup uint g_wide_run_2;
    (&kernelContext_22)->g_wide_run_0 = &g_wide_run_2;
    uint k_7 = id_1.x;
    bool _S279;
    if(k_7 >= (params_2->cand_count_0))
    {
        _S279 = true;
    }
    else
    {
        bool _S280 = stopped_0(&kernelContext_22);
        _S279 = _S280;
    }
    if(_S279)
    {
        return;
    }
    uint _S281 = 3U * k_7;
    uint at_2 = (&kernelContext_22)->params_0->cand_index_0 + _S281;
    uint c_6 = (&kernelContext_22)->index_0[at_2];
    uint _S282 = (&kernelContext_22)->index_0[at_2 + 2U];
    thread Impactor_natural_0 _S283 = *((&kernelContext_22)->impactors_0+_S282);
    if(((uint4((&_S283)->cand_0) ).z) == 0U)
    {
        _S279 = ((float4((&_S283)->crush_0) ).x) > 0.0f;
    }
    else
    {
        _S279 = false;
    }
    float total_0;
    float ksum_0;
    if(_S279)
    {
        WorldPoint_0 _S284 = chunk_world_0(c_6, &kernelContext_22);
        WorldPoint_0 _S285 = impactor_point_0(_S282, &kernelContext_22);
        thread WorldPoint_0 _S286 = _S284;
        thread WorldPoint_0 _S287 = _S285;
        float3 _S288 = world_diff_0(&_S286, &_S287);
        float4 _S289 = float4((&_S283)->half_1) ;
        if(!((length(_S288)) > (_S289.w + (float4(((&kernelContext_22)->chunks_0+c_6)->half_0) ).w)))
        {
            Box_0 _S290 = impactor_box_1(_S282, float3(0.0f) , _S289.xyz, &kernelContext_22);
            Box_0 _S291 = chunk_box_0(c_6, _S288, &kernelContext_22);
            float _S292 = (float4((&_S283)->mat_0) ).x;
            float _S293 = (float4(((&kernelContext_22)->chunks_0+c_6)->cmat_0) ).x;
            float3 _S294 = _S291.center_1 - _S290.center_1;
            thread Box_0 _S295 = _S290;
            thread Box_0 _S296 = _S291;
            float _S297 = contact_stiffness_0(_S292, &_S295, _S293, &_S296, _S294);
            float _S298 = (float4((&_S283)->crush_0) ).w;
            thread Box_0 _S299 = _S290;
            Box_0 _S300 = impactor_shrunk_0(_S282, _S298, &_S299);
            thread Box_0 _S301 = _S300;
            thread Box_0 _S302 = _S291;
            uint _S303 = impactor_contact_count_0(_S282, _S298, &_S301, &_S302, &kernelContext_22);
            float _S304;
            if(((float4((&_S283)->shape_0) ).x) == 0.0f)
            {
                _S304 = _S297;
            }
            else
            {
                _S304 = _S297 / max(float(_S303), 10.0f);
            }
            uint j_4 = 0U;
            total_0 = 0.0f;
            ksum_0 = 0.0f;
            for(;;)
            {
                if(_S303 > 0U)
                {
                    thread Box_0 _S305 = _S291;
                    uint _S306 = impactor_slots_0(&_S283, &_S305);
                    _S279 = j_4 < _S306;
                }
                else
                {
                    _S279 = false;
                }
                if(_S279)
                {
                }
                else
                {
                    break;
                }
                thread Box_0 _S307 = _S300;
                thread Box_0 _S308 = _S291;
                thread float3 p_9;
                thread float3 nrm_1;
                thread float dep_1;
                bool _S309 = impactor_contact_1(&_S283, _S298, &_S307, &_S308, j_4, &p_9, &nrm_1, &dep_1, &kernelContext_22);
                if(!_S309)
                {
                    j_4 = j_4 + 1U;
                    continue;
                }
                float ksum_1 = ksum_0 + _S304;
                total_0 = total_0 + _S304 * dep_1;
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
    float4 _S310 = float4(*((&kernelContext_22)->scratch_0+((&kernelContext_22)->params_0->cand_base_0 + _S281))) ;
    *((&kernelContext_22)->scratch_0+((&kernelContext_22)->params_0->cand_base_0 + _S281)) = packed_float4(float4(total_0, ksum_0, _S310.z, _S310.w)) ;
    return;
}

void group_sum2_0(uint tid_0, float4 thread* a_4, float4 thread* b_21, KernelContext_0 thread* kernelContext_23)
{
    (*kernelContext_23->g_red_a_0)[tid_0] = *a_4;
    (*kernelContext_23->g_red_b_0)[tid_0] = *b_21;
    threadgroup_barrier(mem_flags::mem_threadgroup);
    uint s_1 = 128U;
    for(;;)
    {
        if(s_1 > 0U)
        {
        }
        else
        {
            break;
        }
        if(tid_0 < s_1)
        {
            uint _S311 = tid_0 + s_1;
            (*kernelContext_23->g_red_a_0)[tid_0] = (*kernelContext_23->g_red_a_0)[tid_0] + (*kernelContext_23->g_red_a_0)[_S311];
            (*kernelContext_23->g_red_b_0)[tid_0] = (*kernelContext_23->g_red_b_0)[tid_0] + (*kernelContext_23->g_red_b_0)[_S311];
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);
        s_1 = s_1 >> 1U;
    }
    *a_4 = (*kernelContext_23->g_red_a_0)[int(0)];
    *b_21 = (*kernelContext_23->g_red_b_0)[int(0)];
    threadgroup_barrier(mem_flags::mem_threadgroup);
    return;
}

[[kernel]] void impactor_crush(uint3 group_0 [[threadgroup_position_in_grid]], uint3 thread_0 [[thread_position_in_threadgroup]], Params_0 constant* params_3 [[buffer(0)]], Island_natural_0 device* islands_3 [[buffer(9)]], uint device* index_3 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_3 [[buffer(3)]], packed_float4 device* state_3 [[buffer(6)]], packed_float4 device* scratch_3 [[buffer(8)]], packed_float4 device* contact_state_3 [[buffer(11)]], packed_float4 device* loads_3 [[buffer(5)]], Impactor_natural_0 device* impactors_3 [[buffer(10)]], BondStatic_natural_0 device* bonds_3 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_3 [[buffer(7)]], MaterialTable_0 constant* materials_3 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_24;
    (&kernelContext_24)->params_0 = params_3;
    (&kernelContext_24)->islands_0 = islands_3;
    (&kernelContext_24)->index_0 = index_3;
    (&kernelContext_24)->chunks_0 = chunks_3;
    (&kernelContext_24)->state_0 = state_3;
    (&kernelContext_24)->scratch_0 = scratch_3;
    (&kernelContext_24)->contact_state_0 = contact_state_3;
    (&kernelContext_24)->loads_0 = loads_3;
    (&kernelContext_24)->impactors_0 = impactors_3;
    (&kernelContext_24)->bonds_0 = bonds_3;
    (&kernelContext_24)->bond_dyn_0 = bond_dyn_3;
    (&kernelContext_24)->materials_0 = materials_3;
    threadgroup array<float4, int(256)> g_red_a_3;
    (&kernelContext_24)->g_red_a_0 = &g_red_a_3;
    threadgroup array<float4, int(256)> g_red_b_3;
    (&kernelContext_24)->g_red_b_0 = &g_red_b_3;
    threadgroup uint g_run_3;
    (&kernelContext_24)->g_run_0 = &g_run_3;
    threadgroup uint g_halt_3;
    (&kernelContext_24)->g_halt_0 = &g_halt_3;
    threadgroup uint g_wide_run_3;
    (&kernelContext_24)->g_wide_run_0 = &g_wide_run_3;
    uint ii_0 = group_0.x;
    uint tid_1 = thread_0.x;
    bool _S312;
    if(ii_0 >= (params_3->impactor_count_0))
    {
        _S312 = true;
    }
    else
    {
        bool _S313 = stopped_0(&kernelContext_24);
        _S312 = _S313;
    }
    if(_S312)
    {
        return;
    }
    Impactor_natural_0 device* _S314 = (&kernelContext_24)->impactors_0+ii_0;
    float4 _S315 = float4((*_S314).position_err_1) ;
    float4 _S316 = float4((*_S314).velocity_1) ;
    float4 _S317 = float4((*_S314).velocity_err_1) ;
    float4 _S318 = float4((*_S314).angular_velocity_1) ;
    float4 _S319 = float4((*_S314).rotation_1) ;
    float4 _S320 = float4((*_S314).inertia0_2) ;
    float4 _S321 = float4((*_S314).inertia1_2) ;
    float4 _S322 = float4((*_S314).inertia2_2) ;
    float4 _S323 = float4((*_S314).inv0_2) ;
    float4 _S324 = float4((*_S314).inv1_2) ;
    float4 _S325 = float4((*_S314).inv2_2) ;
    float4 _S326 = float4((*_S314).shape_0) ;
    float4 _S327 = float4((*_S314).half_1) ;
    float4 _S328 = float4((*_S314).mat_0) ;
    float4 _S329 = float4((*_S314).crush_0) ;
    float4 _S330 = float4((*_S314).geom_0) ;
    float4 _S331 = float4((*_S314).unused_0) ;
    float4 _S332 = float4((*_S314).ledger_0) ;
    uint4 _S333 = uint4((*_S314).cand_0) ;
    thread Impactor_0 imp_5;
    (&imp_5)->position_1 = float4((*_S314).position_1) ;
    (&imp_5)->position_err_1 = _S315;
    (&imp_5)->velocity_1 = _S316;
    (&imp_5)->velocity_err_1 = _S317;
    (&imp_5)->angular_velocity_1 = _S318;
    (&imp_5)->rotation_1 = _S319;
    (&imp_5)->inertia0_2 = _S320;
    (&imp_5)->inertia1_2 = _S321;
    (&imp_5)->inertia2_2 = _S322;
    (&imp_5)->inv0_2 = _S323;
    (&imp_5)->inv1_2 = _S324;
    (&imp_5)->inv2_2 = _S325;
    (&imp_5)->shape_0 = _S326;
    (&imp_5)->half_1 = _S327;
    (&imp_5)->mat_0 = _S328;
    (&imp_5)->crush_0 = _S329;
    (&imp_5)->geom_0 = _S330;
    (&imp_5)->unused_0 = _S331;
    (&imp_5)->ledger_0 = _S332;
    (&imp_5)->cand_0 = _S333;
    float4 _S334 = float4(0.0f) ;
    thread float4 shares_0 = _S334;
    thread float4 unused_1 = _S334;
    uint k_8 = (&imp_5)->cand_0.x + tid_1;
    for(;;)
    {
        if(k_8 < ((&imp_5)->cand_0.y))
        {
        }
        else
        {
            break;
        }
        shares_0 = shares_0 + float4(*((&kernelContext_24)->scratch_0+((&kernelContext_24)->params_0->cand_base_0 + 3U * k_8))) ;
        k_8 = k_8 + 256U;
    }
    group_sum2_0(tid_1, &shares_0, &unused_1, &kernelContext_24);
    if(tid_1 != 0U)
    {
        _S312 = true;
    }
    else
    {
        _S312 = ((&imp_5)->cand_0.z) != 0U;
    }
    if(_S312)
    {
        return;
    }
    (&imp_5)->geom_0 = float4(1.0f, (&imp_5)->crush_0.w, 0.0f, 0.0f);
    float total_1 = shares_0.x;
    if(((&imp_5)->crush_0.x) > 0.0f)
    {
        _S312 = ((&imp_5)->crush_0.z) < ((&imp_5)->crush_0.y);
    }
    else
    {
        _S312 = false;
    }
    if(_S312)
    {
        _S312 = total_1 > ((&imp_5)->crush_0.x);
    }
    else
    {
        _S312 = false;
    }
    if(_S312)
    {
        float extra_0 = (total_1 - (&imp_5)->crush_0.x) / shares_0.y;
        (&imp_5)->crush_0.w = (&imp_5)->crush_0.w + extra_0;
        (&imp_5)->crush_0.z = (&imp_5)->crush_0.z + (&imp_5)->crush_0.x * extra_0;
        float _S335 = (&imp_5)->crush_0.x * extra_0;
        thread float _S336 = (&imp_5)->ledger_0.z;
        thread float _S337 = (&imp_5)->ledger_0.w;
        comp_add1_0(&_S336, &_S337, _S335);
        (&imp_5)->ledger_0.w = _S337;
        (&imp_5)->ledger_0.z = _S336;
        float _S338 = (&imp_5)->crush_0.x * extra_0;
        thread float _S339 = (&imp_5)->ledger_0.x;
        thread float _S340 = (&imp_5)->ledger_0.y;
        comp_add1_0(&_S339, &_S340, _S338);
        (&imp_5)->ledger_0.y = _S340;
        (&imp_5)->ledger_0.x = _S339;
        (&imp_5)->geom_0.x = (&imp_5)->crush_0.x / total_1;
    }
    Impactor_natural_0 device* _S341 = (&kernelContext_24)->impactors_0+ii_0;
    _S341->position_1 = packed_float4(imp_5.position_1) ;
    _S341->position_err_1 = packed_float4(imp_5.position_err_1) ;
    _S341->velocity_1 = packed_float4(imp_5.velocity_1) ;
    _S341->velocity_err_1 = packed_float4(imp_5.velocity_err_1) ;
    _S341->angular_velocity_1 = packed_float4(imp_5.angular_velocity_1) ;
    _S341->rotation_1 = packed_float4(imp_5.rotation_1) ;
    _S341->inertia0_2 = packed_float4(imp_5.inertia0_2) ;
    _S341->inertia1_2 = packed_float4(imp_5.inertia1_2) ;
    _S341->inertia2_2 = packed_float4(imp_5.inertia2_2) ;
    _S341->inv0_2 = packed_float4(imp_5.inv0_2) ;
    _S341->inv1_2 = packed_float4(imp_5.inv1_2) ;
    _S341->inv2_2 = packed_float4(imp_5.inv2_2) ;
    _S341->shape_0 = packed_float4(imp_5.shape_0) ;
    _S341->half_1 = packed_float4(imp_5.half_1) ;
    _S341->mat_0 = packed_float4(imp_5.mat_0) ;
    _S341->crush_0 = packed_float4(imp_5.crush_0) ;
    _S341->geom_0 = packed_float4(imp_5.geom_0) ;
    _S341->unused_0 = packed_float4(imp_5.unused_0) ;
    _S341->ledger_0 = packed_float4(imp_5.ledger_0) ;
    _S341->cand_0 = packed_uint4(imp_5.cand_0) ;
    return;
}

void comp_add_0(float3 thread* sum_1, float3 thread* err_1, float3 x_3)
{
    float3 t_3 = *sum_1 + x_3;
    float3 _S342 = abs(x_3);
    *err_1 = *err_1 + (select(x_3, *sum_1, (abs(*sum_1)) >= _S342) - t_3 + select(*sum_1, x_3, (abs(*sum_1)) >= _S342));
    *sum_1 = t_3;
    return;
}

float3 inverse_rotate_0(const Quat_0 thread* q_10, float3 v_5)
{
    thread Quat_0 c_7;
    (&c_7)->w_0 = q_10->w_0;
    (&c_7)->x_0 = - q_10->x_0;
    (&c_7)->y_0 = - q_10->y_0;
    (&c_7)->z_0 = - q_10->z_0;
    thread Quat_0 _S343 = c_7;
    float3 _S344 = rotate_0(&_S343, v_5);
    return _S344;
}

float3 inverse_rotate_1(const Quat_0 thread* q_11, float3 v_6)
{
    thread Quat_0 c_8;
    (&c_8)->w_0 = q_11->w_0;
    (&c_8)->x_0 = - q_11->x_0;
    (&c_8)->y_0 = - q_11->y_0;
    (&c_8)->z_0 = - q_11->z_0;
    thread Quat_0 _S345 = c_8;
    float3 _S346 = rotate_0(&_S345, v_6);
    return _S346;
}

float3 rows_mul_0(float4 r0_0, float4 r1_0, float4 r2_0, float3 v_7)
{
    return float3(dot(r0_0.xyz, v_7), dot(r1_0.xyz, v_7), dot(r2_0.xyz, v_7));
}

float3 world_mul_0(const Quat_0 thread* q_12, float4 r0_1, float4 r1_1, float4 r2_1, float3 v_8)
{
    float3 _S347 = inverse_rotate_1(q_12, v_8);
    float3 _S348 = rotate_1(q_12, rows_mul_0(r0_1, r1_1, r2_1, _S347));
    return _S348;
}

Quat_0 quat_mul_0(const Quat_0 thread* a_5, const Quat_0 thread* o_0)
{
    thread Quat_0 r_5;
    (&r_5)->w_0 = a_5->w_0 * o_0->w_0 - a_5->x_0 * o_0->x_0 - a_5->y_0 * o_0->y_0 - a_5->z_0 * o_0->z_0;
    (&r_5)->x_0 = a_5->w_0 * o_0->x_0 + a_5->x_0 * o_0->w_0 + a_5->y_0 * o_0->z_0 - a_5->z_0 * o_0->y_0;
    (&r_5)->y_0 = a_5->w_0 * o_0->y_0 - a_5->x_0 * o_0->z_0 + a_5->y_0 * o_0->w_0 + a_5->z_0 * o_0->x_0;
    (&r_5)->z_0 = a_5->w_0 * o_0->z_0 + a_5->x_0 * o_0->y_0 - a_5->y_0 * o_0->x_0 + a_5->z_0 * o_0->w_0;
    return r_5;
}

Quat_0 normalized_0(const Quat_0 thread* q_13)
{
    float n_8 = sqrt(q_13->w_0 * q_13->w_0 + q_13->x_0 * q_13->x_0 + q_13->y_0 * q_13->y_0 + q_13->z_0 * q_13->z_0);
    thread Quat_0 r_6;
    (&r_6)->w_0 = q_13->w_0 / n_8;
    (&r_6)->x_0 = q_13->x_0 / n_8;
    (&r_6)->y_0 = q_13->y_0 / n_8;
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
    thread Quat_0 _S349 = from_axis_angle_0(omega_0, angle_1);
    Quat_0 _S350 = quat_mul_0(&_S349, q_14);
    thread Quat_0 _S351 = _S350;
    Quat_0 _S352 = normalized_0(&_S351);
    return _S352;
}

float4 quat_vec_0(const Quat_0 thread* q_15)
{
    return float4(q_15->x_0, q_15->y_0, q_15->z_0, q_15->w_0);
}

[[kernel]] void impactor_integrate(uint3 group_1 [[threadgroup_position_in_grid]], uint3 thread_1 [[thread_position_in_threadgroup]], Params_0 constant* params_4 [[buffer(0)]], Island_natural_0 device* islands_4 [[buffer(9)]], uint device* index_4 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_4 [[buffer(3)]], packed_float4 device* state_4 [[buffer(6)]], packed_float4 device* scratch_4 [[buffer(8)]], packed_float4 device* contact_state_4 [[buffer(11)]], packed_float4 device* loads_4 [[buffer(5)]], Impactor_natural_0 device* impactors_4 [[buffer(10)]], BondStatic_natural_0 device* bonds_4 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_4 [[buffer(7)]], MaterialTable_0 constant* materials_4 [[buffer(1)]])
{
    float3 p_10;
    thread KernelContext_0 kernelContext_25;
    (&kernelContext_25)->params_0 = params_4;
    (&kernelContext_25)->islands_0 = islands_4;
    (&kernelContext_25)->index_0 = index_4;
    (&kernelContext_25)->chunks_0 = chunks_4;
    (&kernelContext_25)->state_0 = state_4;
    (&kernelContext_25)->scratch_0 = scratch_4;
    (&kernelContext_25)->contact_state_0 = contact_state_4;
    (&kernelContext_25)->loads_0 = loads_4;
    (&kernelContext_25)->impactors_0 = impactors_4;
    (&kernelContext_25)->bonds_0 = bonds_4;
    (&kernelContext_25)->bond_dyn_0 = bond_dyn_4;
    (&kernelContext_25)->materials_0 = materials_4;
    threadgroup array<float4, int(256)> g_red_a_4;
    (&kernelContext_25)->g_red_a_0 = &g_red_a_4;
    threadgroup array<float4, int(256)> g_red_b_4;
    (&kernelContext_25)->g_red_b_0 = &g_red_b_4;
    threadgroup uint g_run_4;
    (&kernelContext_25)->g_run_0 = &g_run_4;
    threadgroup uint g_halt_4;
    (&kernelContext_25)->g_halt_0 = &g_halt_4;
    threadgroup uint g_wide_run_4;
    (&kernelContext_25)->g_wide_run_0 = &g_wide_run_4;
    uint ii_1 = group_1.x;
    uint tid_2 = thread_1.x;
    if(ii_1 >= (params_4->impactor_count_0))
    {
        return;
    }
    Island_natural_0 device* _S353 = (&kernelContext_25)->islands_0+(&kernelContext_25)->params_0->halt_index_0;
    Impactor_natural_0 device* _S354 = (&kernelContext_25)->impactors_0+ii_1;
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
    float4 _S371 = float4((*_S354).unused_0) ;
    float4 _S372 = float4((*_S354).ledger_0) ;
    uint4 _S373 = uint4((*_S354).cand_0) ;
    thread Impactor_0 imp_6;
    (&imp_6)->position_1 = float4((*_S354).position_1) ;
    (&imp_6)->position_err_1 = _S355;
    (&imp_6)->velocity_1 = _S356;
    (&imp_6)->velocity_err_1 = _S357;
    (&imp_6)->angular_velocity_1 = _S358;
    (&imp_6)->rotation_1 = _S359;
    (&imp_6)->inertia0_2 = _S360;
    (&imp_6)->inertia1_2 = _S361;
    (&imp_6)->inertia2_2 = _S362;
    (&imp_6)->inv0_2 = _S363;
    (&imp_6)->inv1_2 = _S364;
    (&imp_6)->inv2_2 = _S365;
    (&imp_6)->shape_0 = _S366;
    (&imp_6)->half_1 = _S367;
    (&imp_6)->mat_0 = _S368;
    (&imp_6)->crush_0 = _S369;
    (&imp_6)->geom_0 = _S370;
    (&imp_6)->unused_0 = _S371;
    (&imp_6)->ledger_0 = _S372;
    (&imp_6)->cand_0 = _S373;
    bool _S374;
    if(((&imp_6)->cand_0.z) != 0U)
    {
        _S374 = true;
    }
    else
    {
        _S374 = (((uint4(_S353->info_0) ).z) & 1U) != 0U;
    }
    if(_S374)
    {
        _S374 = true;
    }
    else
    {
        uint _S375 = (uint4(_S353->info_0) ).y;
        if(_S375 != 0U)
        {
            _S374 = ((&imp_6)->cand_0.w) >= _S375;
        }
        else
        {
            _S374 = false;
        }
    }
    if(_S374)
    {
        return;
    }
    float4 _S376 = float4(0.0f) ;
    thread float4 rf_0 = _S376;
    thread float4 rt_0 = _S376;
    uint k_9 = (&imp_6)->cand_0.x + tid_2;
    for(;;)
    {
        if(k_9 < ((&imp_6)->cand_0.y))
        {
        }
        else
        {
            break;
        }
        uint _S377 = 3U * k_9;
        rf_0 = rf_0 + float4(*((&kernelContext_25)->scratch_0+((&kernelContext_25)->params_0->cand_base_0 + _S377 + 1U))) ;
        rt_0 = rt_0 + float4(*((&kernelContext_25)->scratch_0+((&kernelContext_25)->params_0->cand_base_0 + _S377 + 2U))) ;
        k_9 = k_9 + 256U;
    }
    group_sum2_0(tid_2, &rf_0, &rt_0, &kernelContext_25);
    if(tid_2 != 0U)
    {
        return;
    }
    float dt_3 = (&kernelContext_25)->params_0->dt_0;
    float3 _S378 = float3(0.0f) ;
    float3 load_f_0;
    float3 load_t_0;
    if(((&kernelContext_25)->params_0->has_ground_0) != 0U)
    {
        float3 _S379 = (&imp_6)->half_1.xyz;
        thread Impactor_0 _S380 = imp_6;
        Box_0 _S381 = impactor_box_0(&_S380, _S378, _S379);
        float3 _S382 = (&imp_6)->velocity_1.xyz + (&imp_6)->velocity_err_1.xyz;
        float _S383 = (&kernelContext_25)->params_0->ground_modulus_0;
        float _S384 = (&imp_6)->mat_0.x;
        float3 _S385 = float3(0.0f, 0.0f, 1.0f);
        thread Box_0 _S386 = _S381;
        thread Box_0 _S387 = _S381;
        float _S388 = contact_stiffness_0(_S383, &_S386, _S384, &_S387, _S385);
        float _S389 = (&imp_6)->position_1.z - (&kernelContext_25)->params_0->ground_hi_0 + ((&imp_6)->position_err_1.z - (&kernelContext_25)->params_0->ground_lo_0);
        uint total_points_0;
        if(((&imp_6)->shape_0.x) == 0.0f)
        {
            total_points_0 = 1U;
        }
        else
        {
            total_points_0 = 14U;
        }
        float _S390 = _S388 / float(min(total_points_0, 5U));
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
                thread Box_0 _S391 = _S381;
                float3 _S392 = sample_point_0(&_S391, s_2, &kernelContext_25);
                p_10 = _S392;
            }
            if((_S389 + p_10.z) < 0.0f)
            {
                below_0 = below_0 + 1U;
            }
            s_2 = s_2 + 1U;
        }
        s_2 = 0U;
        load_f_0 = _S378;
        load_t_0 = _S378;
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
                thread Box_0 _S393 = _S381;
                float3 _S394 = sample_point_0(&_S393, s_2, &kernelContext_25);
                p_10 = _S394;
            }
            float depth_4 = - (_S389 + p_10.z);
            if(depth_4 <= 0.0f)
            {
                s_2 = s_2 + 1U;
                continue;
            }
            thread float stored_3;
            thread float diss_2;
            float3 _S395 = penalty_force_0(_S390, (&imp_6)->mat_0.z, (&kernelContext_25)->params_0->ground_friction_0, depth_4, _S385, _S382 + cross((&imp_6)->angular_velocity_1.xyz, p_10), dt_3, below_0, &stored_3, &diss_2, &kernelContext_25);
            float3 load_f_1 = load_f_0 + _S395;
            float3 load_t_1 = load_t_0 + cross(p_10, _S395);
            thread float _S396 = (&imp_6)->ledger_0.x;
            thread float _S397 = (&imp_6)->ledger_0.y;
            comp_add1_0(&_S396, &_S397, diss_2);
            (&imp_6)->ledger_0.y = _S397;
            (&imp_6)->ledger_0.x = _S396;
            load_f_0 = load_f_1;
            load_t_0 = load_t_1;
            s_2 = s_2 + 1U;
        }
    }
    else
    {
        load_f_0 = _S378;
        load_t_0 = _S378;
    }
    float3 load_f_2 = rf_0.xyz + load_f_0;
    float3 load_t_2 = rt_0.xyz + load_t_0;
    float m_2 = (&imp_6)->mat_0.z;
    thread float3 vel_0 = (&imp_6)->velocity_1.xyz;
    thread float3 vel_err_0 = (&imp_6)->velocity_err_1.xyz;
    float3 _S398 = float3(dt_3) ;
    comp_add_0(&vel_0, &vel_err_0, (load_f_2 / float3(m_2)  + (&kernelContext_25)->params_0->gravity_0.xyz) * _S398);
    Quat_0 q_16 = quat_of_0((&imp_6)->rotation_1);
    float3 _S399 = (&imp_6)->angular_velocity_1.xyz;
    thread Quat_0 _S400 = q_16;
    float3 _S401 = world_mul_0(&_S400, (&imp_6)->inertia0_2, (&imp_6)->inertia1_2, (&imp_6)->inertia2_2, _S399);
    float3 l_1 = _S401 + load_t_2 * _S398;
    thread Quat_0 _S402 = q_16;
    float3 _S403 = world_mul_0(&_S402, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    thread float3 pos_0 = (&imp_6)->position_1.xyz;
    thread float3 pos_err_0 = (&imp_6)->position_err_1.xyz;
    comp_add_0(&pos_0, &pos_err_0, (vel_0 + vel_err_0) * _S398);
    thread Quat_0 _S404 = q_16;
    Quat_0 _S405 = integrate_rotation_0(&_S404, _S403, dt_3);
    thread Quat_0 _S406 = _S405;
    float3 _S407 = world_mul_0(&_S406, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    (&imp_6)->angular_velocity_1 = float4(_S407, 0.0f);
    thread Quat_0 _S408 = _S405;
    float4 _S409 = quat_vec_0(&_S408);
    (&imp_6)->rotation_1 = _S409;
    (&imp_6)->position_1 = float4(pos_0, 0.0f);
    (&imp_6)->position_err_1 = float4(pos_err_0, 0.0f);
    (&imp_6)->velocity_1 = float4(vel_0, 0.0f);
    (&imp_6)->velocity_err_1 = float4(vel_err_0, 0.0f);
    (&imp_6)->cand_0.w = (&imp_6)->cand_0.w + 1U;
    (&imp_6)->geom_0 = float4(1.0f, (&imp_6)->crush_0.w, 0.0f, 0.0f);
    Impactor_natural_0 device* _S410 = (&kernelContext_25)->impactors_0+ii_1;
    _S410->position_1 = packed_float4(imp_6.position_1) ;
    _S410->position_err_1 = packed_float4(imp_6.position_err_1) ;
    _S410->velocity_1 = packed_float4(imp_6.velocity_1) ;
    _S410->velocity_err_1 = packed_float4(imp_6.velocity_err_1) ;
    _S410->angular_velocity_1 = packed_float4(imp_6.angular_velocity_1) ;
    _S410->rotation_1 = packed_float4(imp_6.rotation_1) ;
    _S410->inertia0_2 = packed_float4(imp_6.inertia0_2) ;
    _S410->inertia1_2 = packed_float4(imp_6.inertia1_2) ;
    _S410->inertia2_2 = packed_float4(imp_6.inertia2_2) ;
    _S410->inv0_2 = packed_float4(imp_6.inv0_2) ;
    _S410->inv1_2 = packed_float4(imp_6.inv1_2) ;
    _S410->inv2_2 = packed_float4(imp_6.inv2_2) ;
    _S410->shape_0 = packed_float4(imp_6.shape_0) ;
    _S410->half_1 = packed_float4(imp_6.half_1) ;
    _S410->mat_0 = packed_float4(imp_6.mat_0) ;
    _S410->crush_0 = packed_float4(imp_6.crush_0) ;
    _S410->geom_0 = packed_float4(imp_6.geom_0) ;
    _S410->unused_0 = packed_float4(imp_6.unused_0) ;
    _S410->ledger_0 = packed_float4(imp_6.ledger_0) ;
    _S410->cand_0 = packed_uint4(imp_6.cand_0) ;
    uint k_10 = (&imp_6)->cand_0.w - 1U - (&kernelContext_25)->params_0->step_start_0;
    if(k_10 < ((&kernelContext_25)->params_0->record_stride_0))
    {
        uint at_3 = (&kernelContext_25)->params_0->record_base_0 + 2U * (ii_1 * (&kernelContext_25)->params_0->record_stride_0 + k_10);
        *((&kernelContext_25)->scratch_0+at_3) = packed_float4(float4(vel_0 + vel_err_0, 0.0f)) ;
        *((&kernelContext_25)->scratch_0+(at_3 + 1U)) = packed_float4(float4(pos_0 + pos_err_0, 0.0f)) ;
    }
    return;
}

void ground_contact_0(uint c_9, bool account_0, float3 thread* f_1, float3 thread* t_4, KernelContext_0 thread* kernelContext_26)
{
    ChunkStatic_natural_0 device* _S411 = kernelContext_26->chunks_0+c_9;
    WorldPoint_0 _S412 = chunk_world_0(c_9, kernelContext_26);
    float above_0 = _S412.hi_0.z - kernelContext_26->params_0->ground_hi_0 + (_S412.lo_0.z - kernelContext_26->params_0->ground_lo_0) + _S412.rel_0.z;
    if((above_0 - (float4(_S411->half_0) ).w) > 0.0f)
    {
        return;
    }
    Box_0 _S413 = chunk_box_0(c_9, float3(0.0f) , kernelContext_26);
    float _S414 = kernelContext_26->params_0->ground_modulus_0;
    float _S415 = (float4(_S411->cmat_0) ).x;
    float3 _S416 = float3(0.0f, 0.0f, 1.0f);
    thread Box_0 _S417 = _S413;
    thread Box_0 _S418 = _S413;
    float _S419 = contact_stiffness_0(_S414, &_S417, _S415, &_S418, _S416);
    thread Box_0 _S420 = _S413;
    uint _S421 = sample_count_0(&_S420);
    uint s_3 = 0U;
    uint n_9 = 0U;
    for(;;)
    {
        if(s_3 < _S421)
        {
        }
        else
        {
            break;
        }
        thread Box_0 _S422 = _S413;
        float3 _S423 = sample_point_0(&_S422, s_3, kernelContext_26);
        if((above_0 + _S423.z) < 0.0f)
        {
            n_9 = n_9 + 1U;
        }
        s_3 = s_3 + 1U;
    }
    if(n_9 == 0U)
    {
        return;
    }
    thread float3 vc_1;
    thread float3 wc_1;
    chunk_velocity_0(c_9, &vc_1, &wc_1, kernelContext_26);
    thread float4 ledger_2 = float4(*(kernelContext_26->scratch_0+(kernelContext_26->params_0->ledger_base_0 + kernelContext_26->params_0->pair_count_0 + c_9))) ;
    s_3 = 0U;
    for(;;)
    {
        if(s_3 < _S421)
        {
        }
        else
        {
            break;
        }
        thread Box_0 _S424 = _S413;
        float3 _S425 = sample_point_0(&_S424, s_3, kernelContext_26);
        float _S426 = above_0 + _S425.z;
        if(!(_S426 < 0.0f))
        {
            s_3 = s_3 + 1U;
            continue;
        }
        thread float stored_4;
        thread float diss_3;
        float3 _S427 = penalty_force_0(_S419 / float(max(n_9, 5U)), (float4(_S411->center_0) ).w, kernelContext_26->params_0->ground_friction_0, - _S426, _S416, vc_1 + cross(wc_1, _S425), kernelContext_26->params_0->dt_0, n_9, &stored_4, &diss_3, kernelContext_26);
        *f_1 = *f_1 + _S427;
        *t_4 = *t_4 + cross(_S425, _S427);
        thread float _S428 = ledger_2.y;
        thread float _S429 = ledger_2.z;
        comp_add1_0(&_S428, &_S429, diss_3);
        ledger_2.z = _S429;
        ledger_2.y = _S428;
        s_3 = s_3 + 1U;
    }
    if(account_0)
    {
        *(kernelContext_26->scratch_0+(kernelContext_26->params_0->ledger_base_0 + kernelContext_26->params_0->pair_count_0 + c_9)) = packed_float4(ledger_2) ;
    }
    return;
}

[[kernel]] void contact_sums(uint3 id_2 [[thread_position_in_grid]], Params_0 constant* params_5 [[buffer(0)]], Island_natural_0 device* islands_5 [[buffer(9)]], uint device* index_5 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_5 [[buffer(3)]], packed_float4 device* state_5 [[buffer(6)]], packed_float4 device* scratch_5 [[buffer(8)]], packed_float4 device* contact_state_5 [[buffer(11)]], packed_float4 device* loads_5 [[buffer(5)]], Impactor_natural_0 device* impactors_5 [[buffer(10)]], BondStatic_natural_0 device* bonds_5 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_5 [[buffer(7)]], MaterialTable_0 constant* materials_5 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_27;
    (&kernelContext_27)->params_0 = params_5;
    (&kernelContext_27)->islands_0 = islands_5;
    (&kernelContext_27)->index_0 = index_5;
    (&kernelContext_27)->chunks_0 = chunks_5;
    (&kernelContext_27)->state_0 = state_5;
    (&kernelContext_27)->scratch_0 = scratch_5;
    (&kernelContext_27)->contact_state_0 = contact_state_5;
    (&kernelContext_27)->loads_0 = loads_5;
    (&kernelContext_27)->impactors_0 = impactors_5;
    (&kernelContext_27)->bonds_0 = bonds_5;
    (&kernelContext_27)->bond_dyn_0 = bond_dyn_5;
    (&kernelContext_27)->materials_0 = materials_5;
    threadgroup array<float4, int(256)> g_red_a_5;
    (&kernelContext_27)->g_red_a_0 = &g_red_a_5;
    threadgroup array<float4, int(256)> g_red_b_5;
    (&kernelContext_27)->g_red_b_0 = &g_red_b_5;
    threadgroup uint g_run_5;
    (&kernelContext_27)->g_run_0 = &g_run_5;
    threadgroup uint g_halt_5;
    (&kernelContext_27)->g_halt_0 = &g_halt_5;
    threadgroup uint g_wide_run_5;
    (&kernelContext_27)->g_wide_run_0 = &g_wide_run_5;
    uint g_0 = id_2.x;
    bool _S430;
    if(g_0 >= (params_5->seg_count_0))
    {
        _S430 = true;
    }
    else
    {
        bool _S431 = stopped_0(&kernelContext_27);
        _S430 = _S431;
    }
    if(_S430)
    {
        return;
    }
    uint _S432 = 3U * g_0;
    uint _S433 = (&kernelContext_27)->index_0[(&kernelContext_27)->params_0->seg_index_0 + _S432];
    uint begin_0 = (&kernelContext_27)->index_0[(&kernelContext_27)->params_0->seg_index_0 + _S432 + 1U];
    uint _S434 = (&kernelContext_27)->index_0[(&kernelContext_27)->params_0->seg_index_0 + _S432 + 2U];
    float3 _S435 = float3(0.0f) ;
    thread float3 f_2 = _S435;
    thread float3 t_5 = _S435;
    uint e_2 = begin_0;
    for(;;)
    {
        if(e_2 < _S434)
        {
        }
        else
        {
            break;
        }
        uint entry_1 = (&kernelContext_27)->index_0[e_2];
        if(entry_1 == 2147483648U)
        {
            ground_contact_0(_S433, true, &f_2, &t_5, &kernelContext_27);
            e_2 = e_2 + 1U;
            continue;
        }
        uint _S436 = 2U * entry_1;
        f_2 = f_2 + (float4(*((&kernelContext_27)->scratch_0+((&kernelContext_27)->params_0->slot_base_0 + _S436))) ).xyz;
        t_5 = t_5 + (float4(*((&kernelContext_27)->scratch_0+((&kernelContext_27)->params_0->slot_base_0 + _S436 + 1U))) ).xyz;
        e_2 = e_2 + 1U;
    }
    uint _S437 = 2U * g_0;
    *((&kernelContext_27)->scratch_0+((&kernelContext_27)->params_0->seg_base_0 + _S437)) = packed_float4(float4(f_2, 0.0f)) ;
    *((&kernelContext_27)->scratch_0+((&kernelContext_27)->params_0->seg_base_0 + _S437 + 1U)) = packed_float4(float4(t_5, 0.0f)) ;
    return;
}

bool contact_stopped_0(const Island_natural_0 thread* isl_0, KernelContext_0 thread* kernelContext_28)
{
    uint4 _S438 = uint4((kernelContext_28->islands_0+kernelContext_28->params_0->halt_index_0)->info_0) ;
    bool _S439;
    if(((_S438.z) & 1U) != 0U)
    {
        _S439 = true;
    }
    else
    {
        uint _S440 = _S438.y;
        if(_S440 != 0U)
        {
            _S439 = _S440 <= ((uint4(isl_0->info_0) ).w);
        }
        else
        {
            _S439 = false;
        }
    }
    return _S439;
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

bool contact_stopped_1(const Island_0 thread* isl_1, KernelContext_0 thread* kernelContext_29)
{
    uint4 _S441 = uint4((kernelContext_29->islands_0+kernelContext_29->params_0->halt_index_0)->info_0) ;
    bool _S442;
    if(((_S441.z) & 1U) != 0U)
    {
        _S442 = true;
    }
    else
    {
        uint _S443 = _S441.y;
        if(_S443 != 0U)
        {
            _S442 = _S443 <= (isl_1->info_0.w);
        }
        else
        {
            _S442 = false;
        }
    }
    return _S442;
}

struct Rigid_0
{
    Quat_0 rot_0;
    float3 pos_1;
    float3 pos_err_1;
    float3 vel_1;
    float3 vel_err_1;
    float3 w_3;
    float3 a_6;
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
    (&rg_0)->w_3 = (float4(isl_2->angular_velocity_0) ).xyz;
    float3 _S444 = float3(0.0f) ;
    (&rg_0)->a_6 = _S444;
    (&rg_0)->alpha_0 = _S444;
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
    (&rg_1)->w_3 = isl_3->angular_velocity_0.xyz;
    float3 _S445 = float3(0.0f) ;
    (&rg_1)->a_6 = _S445;
    (&rg_1)->alpha_0 = _S445;
    return rg_1;
}

void write_probe_0(uint slot_1, uint k_11, float value_0, KernelContext_0 thread* kernelContext_30)
{
    uint at_4 = kernelContext_30->params_0->probe_base_0 * 4U + slot_1 * kernelContext_30->params_0->probe_stride_0 + k_11;
    thread float4 v_9 = float4(*(kernelContext_30->scratch_0+at_4 / 4U)) ;
    v_9[at_4 % 4U] = value_0;
    *(kernelContext_30->scratch_0+at_4 / 4U) = packed_float4(v_9) ;
    return;
}

void record_probes_0(const Island_0 thread* isl_4, const Rigid_0 thread* rg_2, uint k_12, KernelContext_0 thread* kernelContext_31)
{
    uint4 _S446 = isl_4->probes_0;
    uint at_5 = isl_4->probes_0.x;
    for(;;)
    {
        if(at_5 < (_S446.y))
        {
        }
        else
        {
            break;
        }
        uint4 info_2 = (as_type<uint4>((float4(*(kernelContext_31->loads_0+at_5)) )));
        float4 _S447 = float4(*(kernelContext_31->loads_0+(at_5 + 1U))) ;
        float4 _S448 = float4(*(kernelContext_31->loads_0+(at_5 + 2U))) ;
        float4 _S449 = float4(*(kernelContext_31->loads_0+(at_5 + 3U))) ;
        uint kind_0 = info_2.x;
        uint i_5 = info_2.y;
        float value_1;
        if(kind_0 == 0U)
        {
            float3 _S450 = rg_2->pos_1 - _S448.xyz + (rg_2->pos_err_1 - _S449.xyz);
            float3 _S451 = rotate_0(&rg_2->rot_0, (float4((kernelContext_31->chunks_0+i_5)->center_0) ).xyz + (float4(*(kernelContext_31->state_0+4U * i_5)) ).xyz);
            value_1 = dot(_S450 + _S451, _S447.xyz);
        }
        else
        {
            if(kind_0 == 1U)
            {
                uint _S452 = 4U * i_5;
                float3 _S453 = rotate_0(&rg_2->rot_0, (float4((kernelContext_31->chunks_0+i_5)->center_0) ).xyz + (float4(*(kernelContext_31->state_0+_S452)) ).xyz - isl_4->com_0.xyz);
                float3 _S454 = rg_2->vel_1 + rg_2->vel_err_1 + cross(rg_2->w_3, _S453);
                float3 _S455 = rotate_0(&rg_2->rot_0, (float4(*(kernelContext_31->state_0+(_S452 + 2U))) ).xyz);
                value_1 = dot(_S454 + _S455, _S447.xyz);
            }
            else
            {
                if(kind_0 == 2U)
                {
                    uint _S456 = 3U * i_5;
                    float3 f_3 = (float4(*(kernelContext_31->scratch_0+_S456)) ).xyz;
                    bool _S457 = (info_2.z) == 0U;
                    float3 mc_0;
                    if(_S457)
                    {
                        mc_0 = (float4(*(kernelContext_31->scratch_0+(_S456 + 1U))) ).xyz;
                    }
                    else
                    {
                        mc_0 = (float4(*(kernelContext_31->scratch_0+(_S456 + 2U))) ).xyz;
                    }
                    float3 fc_0;
                    if(_S457)
                    {
                        fc_0 = f_3;
                    }
                    else
                    {
                        fc_0 = - f_3;
                    }
                    value_1 = dot(fc_0, _S447.xyz) + dot(mc_0, _S448.xyz);
                }
                else
                {
                    uint _S458 = 4U * i_5;
                    float3 _S459 = rotate_0(&rg_2->rot_0, float3((float4(*(kernelContext_31->state_0+(_S458 + 1U))) ).w, (float4(*(kernelContext_31->state_0+(_S458 + 2U))) ).w, (float4(*(kernelContext_31->state_0+(_S458 + 3U))) ).w));
                    value_1 = dot(_S459, _S447.xyz);
                }
            }
        }
        write_probe_0(info_2.w, k_12, value_1, kernelContext_31);
        at_5 = at_5 + 4U;
    }
    return;
}

float time_since_0(float4 origin_0, uint k_13, float dt_4, KernelContext_0 thread* kernelContext_32)
{
    return kernelContext_32->params_0->t_hi_0 - origin_0.x + (kernelContext_32->params_0->t_lo_0 - origin_0.y) + float(k_13) * dt_4;
}

float table_eval_0(uint offset_0, uint count_2, float tau_0, KernelContext_0 thread* kernelContext_33)
{
    float4 _S460 = float4(*(kernelContext_33->loads_0+offset_0)) ;
    if(tau_0 <= (_S460.x))
    {
        return _S460.y;
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
        uint _S461 = offset_0 + i_6;
        float4 _S462 = float4(*(kernelContext_33->loads_0+_S461)) ;
        float _S463 = _S462.x;
        if(tau_0 <= _S463)
        {
            float4 _S464 = float4(*(kernelContext_33->loads_0+(_S461 - 1U))) ;
            float _S465 = _S464.x;
            float _S466 = _S464.y;
            return _S466 + (tau_0 - _S465) / max(_S463 - _S465, 1.00000000317107685e-30f) * (_S462.y - _S466);
        }
        i_6 = i_6 + 1U;
    }
    return (float4(*(kernelContext_33->loads_0+(offset_0 + count_2 - 1U))) ).y;
}

float eval_function_0(uint term_0, uint k_14, float dt_5, float shift_0, KernelContext_0 thread* kernelContext_34)
{
    uint _S467 = 5U * term_0;
    uint4 info_3 = (as_type<uint4>((float4(*(kernelContext_34->loads_0+_S467)) )));
    float4 _S468 = float4(*(kernelContext_34->loads_0+(_S467 + 3U))) ;
    float4 _S469 = float4(*(kernelContext_34->loads_0+(_S467 + 4U))) ;
    uint kind_1 = info_3.z;
    if(kind_1 == 0U)
    {
        return _S468.z;
    }
    float _S470 = time_since_0(_S468, k_14, dt_5, kernelContext_34);
    float tau_1 = _S470 + shift_0;
    float shape_1;
    if(kind_1 == 1U)
    {
        if(tau_1 <= 0.0f)
        {
            shape_1 = 0.0f;
        }
        else
        {
            float _S471 = _S469.x;
            if(tau_1 >= _S471)
            {
                shape_1 = _S469.y;
            }
            else
            {
                shape_1 = _S469.y * tau_1 / _S471;
            }
        }
        return shape_1;
    }
    bool _S472;
    if(kind_1 == 2U)
    {
        if(tau_1 < 0.0f)
        {
            _S472 = true;
        }
        else
        {
            _S472 = tau_1 > (_S469.x);
        }
        if(_S472)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S469.y * sin(3.14159274101257324f * tau_1 / _S469.x);
        }
        return shape_1;
    }
    if(kind_1 == 3U)
    {
        float sn_0 = tau_1 / _S469.y;
        if(sn_0 < 0.0f)
        {
            _S472 = true;
        }
        else
        {
            _S472 = sn_0 > 1.0f;
        }
        if(_S472)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S469.x * (1.0f - sn_0) * exp(- _S469.z * sn_0);
        }
        return shape_1;
    }
    if(kind_1 == 4U)
    {
        float _S473 = table_eval_0(info_3.w, (as_type<uint>((_S469.x))), tau_1, kernelContext_34);
        return _S473;
    }
    if(kind_1 == 5U)
    {
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float sn_1 = tau_1 / _S469.x;
        if(sn_1 < 0.0f)
        {
            _S472 = true;
        }
        else
        {
            _S472 = sn_1 > 1.0f;
        }
        if(_S472)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = (1.0f - sn_1) * exp(- _S469.y * sn_1);
        }
        float clearing_0 = _S468.w;
        float relax_0;
        if(clearing_0 > 0.0f)
        {
            relax_0 = max(1.0f - tau_1 / clearing_0, 0.0f);
        }
        else
        {
            relax_0 = 0.0f;
        }
        float _S474 = _S469.w;
        return (_S474 + (_S469.z - _S474) * relax_0) * shape_1;
    }
    if(kind_1 == 7U)
    {
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float _S475 = _S469.y;
        if(tau_1 < _S475)
        {
            return _S469.x;
        }
        float s_4 = tau_1 - _S475;
        float _S476 = _S469.w;
        if(s_4 > _S476)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S469.z * sin(3.14159274101257324f * s_4 / _S476);
        }
        return shape_1;
    }
    float _S477 = _S469.x;
    if(_S477 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp(1.0f - tau_1 / _S477, 0.0f, 1.0f);
}

void record_chunk_load_0(uint c_10, float3 f_4, float3 t_6, KernelContext_0 thread* kernelContext_35)
{
    if((kernelContext_35->params_0->solve_mode_0) == 0U)
    {
        return;
    }
    uint _S478 = 2U * c_10;
    *(kernelContext_35->scratch_0+(kernelContext_35->params_0->cload_base_0 + _S478)) = packed_float4(float4(f_4, 0.0f)) ;
    *(kernelContext_35->scratch_0+(kernelContext_35->params_0->cload_base_0 + _S478 + 1U)) = packed_float4(float4(t_6, 0.0f)) ;
    *(kernelContext_35->scratch_0+(kernelContext_35->params_0->cframe_base_0 + _S478)) = packed_float4(float4((float4(*(kernelContext_35->scratch_0+(kernelContext_35->params_0->cframe_base_0 + _S478))) ).xyz + f_4, 0.0f)) ;
    *(kernelContext_35->scratch_0+(kernelContext_35->params_0->cframe_base_0 + _S478 + 1U)) = packed_float4(float4((float4(*(kernelContext_35->scratch_0+(kernelContext_35->params_0->cframe_base_0 + _S478 + 1U))) ).xyz + t_6, 0.0f)) ;
    return;
}

void chunk_external_0(uint _S479, uint _S480, const Quat_0 thread* _S481, uint _S482, float _S483, bool _S484, float3 thread* _S485, float3 thread* _S486, KernelContext_0 thread* kernelContext_36)
{
    bool _S487;
    ChunkStatic_natural_0 device* _S488 = kernelContext_36->chunks_0+_S480;
    float3 _S489 = float3(0.0f) ;
    *_S485 = _S489;
    *_S486 = _S489;
    uint4 _S490 = uint4(_S488->load_range_0) ;
    uint term_1 = _S490.x;
    for(;;)
    {
        if(term_1 < (_S490.y))
        {
        }
        else
        {
            break;
        }
        uint _S491 = 5U * term_1;
        uint _S492 = (as_type<uint4>((float4(*(kernelContext_36->loads_0+_S491)) ))).y;
        if(_S492 == 2U)
        {
            term_1 = term_1 + 1U;
            continue;
        }
        float4 _S493 = float4(*(kernelContext_36->loads_0+(_S491 + 1U))) ;
        float4 _S494 = float4(*(kernelContext_36->loads_0+(_S491 + 2U))) ;
        float _S495 = eval_function_0(term_1, _S482, _S483, 0.0f, kernelContext_36);
        if(_S492 == 0U)
        {
            _S487 = true;
        }
        else
        {
            _S487 = _S492 == 3U;
        }
        float3 fw_0;
        if(_S487)
        {
            fw_0 = _S493.xyz * float3(_S495) ;
        }
        else
        {
            float3 _S496 = rotate_0(_S481, _S493.xyz);
            fw_0 = _S496 * float3((- _S495 * _S493.w)) ;
        }
        float3 lever_0;
        if(_S492 == 3U)
        {
            lever_0 = _S494.xyz - (float4(*(kernelContext_36->state_0+4U * _S479)) ).xyz;
        }
        else
        {
            lever_0 = _S494.xyz;
        }
        *_S485 = *_S485 + fw_0;
        float3 _S497 = rotate_0(_S481, lever_0);
        *_S486 = *_S486 + cross(_S497, fw_0);
        term_1 = term_1 + 1U;
    }
    if(_S484)
    {
        _S487 = ((uint4(_S488->cinfo_0) ).z) != 0U;
    }
    else
    {
        _S487 = false;
    }
    if(_S487)
    {
        uint4 _S498 = uint4(_S488->cinfo_0) ;
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
            *_S485 = *_S485 + (float4(*(kernelContext_36->scratch_0+(kernelContext_36->params_0->seg_base_0 + _S499))) ).xyz;
            *_S486 = *_S486 + (float4(*(kernelContext_36->scratch_0+(kernelContext_36->params_0->seg_base_0 + _S499 + 1U))) ).xyz;
            g_1 = g_1 + 1U;
        }
    }
    return;
}

float settled_chunk_load_0(uint c_11, const Quat_0 thread* rot_1, uint k_15, float dt_6, bool contact_0, KernelContext_0 thread* kernelContext_37)
{
    thread float3 f_5;
    thread float3 t_7;
    chunk_external_0(c_11, c_11, rot_1, k_15, dt_6, contact_0, &f_5, &t_7, kernelContext_37);
    record_chunk_load_0(c_11, f_5, t_7, kernelContext_37);
    return length(f_5);
}

void group_sum3_0(uint tid_3, float3 thread* a_7, float3 thread* b_22, KernelContext_0 thread* kernelContext_38)
{
    thread float4 x_4 = float4(*a_7, 0.0f);
    thread float4 y_1 = float4(*b_22, 0.0f);
    group_sum2_0(tid_3, &x_4, &y_1, kernelContext_38);
    *a_7 = x_4.xyz;
    *b_22 = y_1.xyz;
    return;
}

void net_load_0(uint c_12, const Island_natural_0 thread* isl_5, const Rigid_0 thread* rg_3, uint k_16, float dt_7, bool contact_1, float3 thread* f_6, float3 thread* t_8, KernelContext_0 thread* kernelContext_39)
{
    ChunkStatic_natural_0 device* _S500 = kernelContext_39->chunks_0+c_12;
    thread float3 fl_0;
    thread float3 tl_0;
    chunk_external_0(c_12, c_12, &rg_3->rot_0, k_16, dt_7, contact_1, &fl_0, &tl_0, kernelContext_39);
    float4 _S501 = float4(_S500->center_0) ;
    float3 fc_1 = fl_0 + kernelContext_39->params_0->gravity_0.xyz * float3(_S501.w) ;
    float3 _S502 = _S501.xyz;
    float3 _S503 = (float4(isl_5->com_0) ).xyz;
    float3 _S504 = rotate_0(&rg_3->rot_0, _S502 + (float4(*(kernelContext_39->state_0+4U * c_12)) ).xyz - _S503);
    *f_6 = *f_6 + fc_1;
    *t_8 = *t_8 + (cross(_S504, fc_1) + tl_0);
    uint4 _S505 = uint4(_S500->load_range_0) ;
    uint term_2 = _S505.x;
    for(;;)
    {
        if(term_2 < (_S505.y))
        {
        }
        else
        {
            break;
        }
        uint _S506 = 5U * term_2;
        if(((as_type<uint4>((float4(*(kernelContext_39->loads_0+_S506)) ))).y) != 2U)
        {
            term_2 = term_2 + 1U;
            continue;
        }
        float _S507 = eval_function_0(term_2, k_16, dt_7, 0.0f, kernelContext_39);
        float3 _S508 = float3(_S507) ;
        float3 _S509 = rotate_0(&rg_3->rot_0, (float4(*(kernelContext_39->loads_0+(_S506 + 1U))) ).xyz * _S508);
        *f_6 = *f_6 + _S509;
        float3 _S510 = rotate_0(&rg_3->rot_0, _S502 - _S503);
        float3 _S511 = cross(_S510, _S509);
        float3 _S512 = rotate_0(&rg_3->rot_0, (float4(*(kernelContext_39->loads_0+(_S506 + 2U))) ).xyz * _S508);
        *t_8 = *t_8 + (_S511 + _S512);
        term_2 = term_2 + 1U;
    }
    return;
}

void net_load_1(uint c_13, const Island_0 thread* isl_6, const Rigid_0 thread* rg_4, uint k_17, float dt_8, bool contact_2, float3 thread* f_7, float3 thread* t_9, KernelContext_0 thread* kernelContext_40)
{
    ChunkStatic_natural_0 device* _S513 = kernelContext_40->chunks_0+c_13;
    thread float3 fl_1;
    thread float3 tl_1;
    chunk_external_0(c_13, c_13, &rg_4->rot_0, k_17, dt_8, contact_2, &fl_1, &tl_1, kernelContext_40);
    float4 _S514 = float4(_S513->center_0) ;
    float3 fc_2 = fl_1 + kernelContext_40->params_0->gravity_0.xyz * float3(_S514.w) ;
    float3 _S515 = _S514.xyz;
    float3 _S516 = isl_6->com_0.xyz;
    float3 _S517 = rotate_0(&rg_4->rot_0, _S515 + (float4(*(kernelContext_40->state_0+4U * c_13)) ).xyz - _S516);
    *f_7 = *f_7 + fc_2;
    *t_9 = *t_9 + (cross(_S517, fc_2) + tl_1);
    uint4 _S518 = uint4(_S513->load_range_0) ;
    uint term_3 = _S518.x;
    for(;;)
    {
        if(term_3 < (_S518.y))
        {
        }
        else
        {
            break;
        }
        uint _S519 = 5U * term_3;
        if(((as_type<uint4>((float4(*(kernelContext_40->loads_0+_S519)) ))).y) != 2U)
        {
            term_3 = term_3 + 1U;
            continue;
        }
        float _S520 = eval_function_0(term_3, k_17, dt_8, 0.0f, kernelContext_40);
        float3 _S521 = float3(_S520) ;
        float3 _S522 = rotate_0(&rg_4->rot_0, (float4(*(kernelContext_40->loads_0+(_S519 + 1U))) ).xyz * _S521);
        *f_7 = *f_7 + _S522;
        float3 _S523 = rotate_0(&rg_4->rot_0, _S515 - _S516);
        float3 _S524 = cross(_S523, _S522);
        float3 _S525 = rotate_0(&rg_4->rot_0, (float4(*(kernelContext_40->loads_0+(_S519 + 2U))) ).xyz * _S521);
        *t_9 = *t_9 + (_S524 + _S525);
        term_3 = term_3 + 1U;
    }
    return;
}

void rigid_acceleration_0(const Island_natural_0 thread* isl_7, Rigid_0 thread* rg_5, float3 f_8, float3 t_10)
{
    float4 _S526 = float4(isl_7->inertia0_0) ;
    float4 _S527 = float4(isl_7->inertia1_0) ;
    float4 _S528 = float4(isl_7->inertia2_0) ;
    thread Quat_0 _S529 = rg_5->rot_0;
    float3 _S530 = world_mul_0(&_S529, _S526, _S527, _S528, rg_5->w_3);
    rg_5->a_6 = f_8 / float3((float4(isl_7->com_0) ).w) ;
    float4 _S531 = float4(isl_7->inv0_0) ;
    float4 _S532 = float4(isl_7->inv1_0) ;
    float4 _S533 = float4(isl_7->inv2_0) ;
    float3 _S534 = t_10 - cross(rg_5->w_3, _S530);
    thread Quat_0 _S535 = rg_5->rot_0;
    float3 _S536 = world_mul_0(&_S535, _S531, _S532, _S533, _S534);
    rg_5->alpha_0 = _S536;
    return;
}

void rigid_acceleration_1(const Island_0 thread* isl_8, Rigid_0 thread* rg_6, float3 f_9, float3 t_11)
{
    thread Quat_0 _S537 = rg_6->rot_0;
    float3 _S538 = world_mul_0(&_S537, isl_8->inertia0_0, isl_8->inertia1_0, isl_8->inertia2_0, rg_6->w_3);
    rg_6->a_6 = f_9 / float3(isl_8->com_0.w) ;
    float3 _S539 = t_11 - cross(rg_6->w_3, _S538);
    thread Quat_0 _S540 = rg_6->rot_0;
    float3 _S541 = world_mul_0(&_S540, isl_8->inv0_0, isl_8->inv1_0, isl_8->inv2_0, _S539);
    rg_6->alpha_0 = _S541;
    return;
}

void integrate_rigid_0(const Island_natural_0 thread* isl_9, Rigid_0 thread* rg_7, float dt_9)
{
    float4 _S542 = float4(isl_9->inertia0_0) ;
    float4 _S543 = float4(isl_9->inertia1_0) ;
    float4 _S544 = float4(isl_9->inertia2_0) ;
    thread Quat_0 _S545 = rg_7->rot_0;
    float3 _S546 = world_mul_0(&_S545, _S542, _S543, _S544, rg_7->w_3);
    thread Quat_0 _S547 = rg_7->rot_0;
    float3 _S548 = world_mul_0(&_S547, _S542, _S543, _S544, rg_7->alpha_0);
    float3 _S549 = float3(dt_9) ;
    float3 l_2 = _S546 + (_S548 + cross(rg_7->w_3, _S546)) * _S549;
    comp_add_0(&rg_7->vel_1, &rg_7->vel_err_1, rg_7->a_6 * _S549);
    float3 vel_2 = rg_7->vel_1 + rg_7->vel_err_1;
    float4 _S550 = float4(isl_9->inv0_0) ;
    float4 _S551 = float4(isl_9->inv1_0) ;
    float4 _S552 = float4(isl_9->inv2_0) ;
    thread Quat_0 _S553 = rg_7->rot_0;
    float3 _S554 = world_mul_0(&_S553, _S550, _S551, _S552, l_2);
    thread Quat_0 _S555 = rg_7->rot_0;
    Quat_0 _S556 = integrate_rotation_0(&_S555, _S554, dt_9);
    float3 _S557 = vel_2 * _S549;
    float3 _S558 = (float4(isl_9->com_0) ).xyz;
    thread Quat_0 _S559 = rg_7->rot_0;
    float3 _S560 = rotate_0(&_S559, _S558);
    thread Quat_0 _S561 = _S556;
    float3 _S562 = rotate_0(&_S561, _S558);
    comp_add_0(&rg_7->pos_1, &rg_7->pos_err_1, _S557 + (_S560 - _S562));
    rg_7->rot_0 = _S556;
    thread Quat_0 _S563 = _S556;
    float3 _S564 = world_mul_0(&_S563, _S550, _S551, _S552, l_2);
    rg_7->w_3 = _S564;
    return;
}

void integrate_rigid_1(const Island_0 thread* isl_10, Rigid_0 thread* rg_8, float dt_10)
{
    thread Quat_0 _S565 = rg_8->rot_0;
    float3 _S566 = world_mul_0(&_S565, isl_10->inertia0_0, isl_10->inertia1_0, isl_10->inertia2_0, rg_8->w_3);
    thread Quat_0 _S567 = rg_8->rot_0;
    float3 _S568 = world_mul_0(&_S567, isl_10->inertia0_0, isl_10->inertia1_0, isl_10->inertia2_0, rg_8->alpha_0);
    float3 _S569 = float3(dt_10) ;
    float3 l_3 = _S566 + (_S568 + cross(rg_8->w_3, _S566)) * _S569;
    comp_add_0(&rg_8->vel_1, &rg_8->vel_err_1, rg_8->a_6 * _S569);
    float3 vel_3 = rg_8->vel_1 + rg_8->vel_err_1;
    float4 _S570 = isl_10->inv0_0;
    float4 _S571 = isl_10->inv1_0;
    float4 _S572 = isl_10->inv2_0;
    thread Quat_0 _S573 = rg_8->rot_0;
    float3 _S574 = world_mul_0(&_S573, isl_10->inv0_0, isl_10->inv1_0, isl_10->inv2_0, l_3);
    thread Quat_0 _S575 = rg_8->rot_0;
    Quat_0 _S576 = integrate_rotation_0(&_S575, _S574, dt_10);
    float3 _S577 = vel_3 * _S569;
    float3 _S578 = isl_10->com_0.xyz;
    thread Quat_0 _S579 = rg_8->rot_0;
    float3 _S580 = rotate_0(&_S579, _S578);
    thread Quat_0 _S581 = _S576;
    float3 _S582 = rotate_0(&_S581, _S578);
    comp_add_0(&rg_8->pos_1, &rg_8->pos_err_1, _S577 + (_S580 - _S582));
    rg_8->rot_0 = _S576;
    thread Quat_0 _S583 = _S576;
    float3 _S584 = world_mul_0(&_S583, _S570, _S571, _S572, l_3);
    rg_8->w_3 = _S584;
    return;
}

bool connected_0(const JointState_0 thread* st_0, bool has_rebar_0)
{
    bool _S585;
    if((st_0->damage_0) < 1.0f)
    {
        _S585 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S585 = (st_0->rebar_broken_0) == 0.0f;
        }
        else
        {
            _S585 = false;
        }
    }
    return _S585;
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
    float4 _S586 = float4(b_23->geom0_0) ;
    float area_2 = _S586.x;
    float _S587 = q_lin_0.z;
    float axial_0 = (metal::fast::divide((_S587), (area_2)));
    float4 _S588 = float4(b_23->geom1_0) ;
    float _S589 = (metal::fast::divide((abs(q_ang_0.x)), (_S588.x)));
    float _S590 = (metal::fast::divide((abs(q_ang_0.y)), (_S588.y)));
    float bending_0 = _S589 + _S590;
    float _S591 = q_lin_0.x;
    float _S592 = q_lin_0.y;
    float _S593 = (metal::fast::sqrt((_S591 * _S591 + _S592 * _S592)));
    float _S594 = (metal::fast::divide((_S593), (area_2)));
    float _S595 = (metal::fast::divide((abs(q_ang_0.z)), (_S586.w)));
    float shear_1 = _S594 + _S595;
    thread Measures_0 m_3;
    (&m_3)->tension_0 = axial_0 + bending_0;
    (&m_3)->shear_0 = shear_1;
    float _S596 = - axial_0;
    (&m_3)->normal_compression_0 = max(_S596, 0.0f);
    (&m_3)->compression_0 = _S596 + bending_0;
    (&m_3)->compressive_force_0 = max(- _S587, 0.0f);
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
    float4 _S597 = mat_1->dif_0;
    float ref_0 = mat_1->dif_0.x;
    if(r_7 <= ref_0)
    {
        return 1.0f;
    }
    float _S598 = _S597.z;
    float f_10;
    if(r_7 <= _S598)
    {
        float _S599 = (metal::fast::divide((r_7), (ref_0)));
        float _S600 = (metal::fast::pow((_S599), (_S597.y)));
        f_10 = _S600;
    }
    else
    {
        float _S601 = (metal::fast::divide((_S598), (ref_0)));
        float _S602 = (metal::fast::pow((_S601), (_S597.y)));
        float _S603 = (metal::fast::divide((r_7), (_S598)));
        float _S604 = (metal::fast::pow((_S603), (_S597.w)));
        f_10 = _S602 * _S604;
    }
    return clamp(f_10, 1.0f, mat_1->misc_0.x);
}

float fatigue_factor_0(const JointMaterial_0 constant* mat_2, float fatigue_1)
{
    if(((mat_2->kind_flags_0.y) & 64U) == 0U)
    {
        return 1.0f;
    }
    float _S605 = 1.0f - clamp(fatigue_1, 0.0f, 1.0f);
    float _S606 = (metal::fast::divide((1.0f), (mat_2->misc_0.y - 2.0f)));
    float _S607 = (metal::fast::pow((_S605), (_S606)));
    return _S607;
}

float infinity_0()
{
    return (as_type<float>((2139095040U)));
}

float4 failure_indices_0(const JointMaterial_0 constant* mat_3, const JointBond_natural_0 thread* b_24, const Measures_0 thread* m_4, float multiplier_0)
{
    float fc_3 = mat_3->strength_0.y * multiplier_0;
    float _S608 = min(mat_3->strength_0.z * multiplier_0 + mat_3->strength_0.w * m_4->normal_compression_0, mat_3->energy_1.x * multiplier_0);
    thread float4 idx_0;
    float _S609 = (metal::fast::divide((m_4->tension_0), (mat_3->strength_0.x * multiplier_0)));
    idx_0.x = max(_S609, 0.0f);
    float _S610;
    if(_S608 > 0.0f)
    {
        float _S611 = (metal::fast::divide((m_4->shear_0), (_S608)));
        _S610 = _S611;
    }
    else
    {
        _S610 = infinity_0();
    }
    idx_0.y = _S610;
    float _S612 = (metal::fast::divide((m_4->compression_0), (fc_3)));
    idx_0.z = max(_S612, 0.0f);
    float _S613 = (float4(b_24->stiff1_0) ).y;
    if(_S613 > 0.0f)
    {
        float _S614 = (metal::fast::divide((m_4->compressive_force_0), (_S613)));
        _S610 = _S614;
    }
    else
    {
        _S610 = 0.0f;
    }
    idx_0.w = _S610;
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
        float _S615 = (metal::fast::divide((r_8 * (kappa_1 - 1.0f)), (kappa_1 * (r_8 - 1.0f))));
        return min(_S615, 1.0f);
    }
    if(kappa_1 >= (0.5f * (r_8 + 1.0f)))
    {
        return 1.0f;
    }
    float _S616 = (metal::fast::divide((1.0f), (kappa_1)));
    return 1.0f - _S616;
}

float2 damage_increment_0(uint kind_3, float kappa_old_0, float lambda_0, float r_9, float d_old_0, float psi_0)
{
    float _S617 = damage_law_0(kind_3, lambda_0, r_9);
    float _S618 = max(_S617, d_old_0);
    bool _S619;
    if(_S618 <= d_old_0)
    {
        _S619 = true;
    }
    else
    {
        _S619 = d_old_0 >= 1.0f;
    }
    if(_S619)
    {
        return float2(d_old_0, 0.0f);
    }
    float u0_0 = (metal::fast::divide((psi_0), (lambda_0 * lambda_0)));
    float _S620 = max(kappa_old_0, 1.0f);
    if(kind_3 == 0U)
    {
        if(r_9 > 1.0f)
        {
            float _S621 = (metal::fast::divide((u0_0 * r_9), (r_9 - 1.0f)));
            return float2(_S618, _S621 * max(min(lambda_0, r_9) - min(_S620, r_9), 0.0f));
        }
        return float2(_S618, (1.0f - d_old_0) * psi_0);
    }
    float ku_0 = 0.5f * (r_9 + 1.0f);
    float plateau_0 = u0_0 * max(min(lambda_0, ku_0) - min(_S620, ku_0), 0.0f);
    float snap_0;
    if(_S618 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return float2(_S618, plateau_0 + snap_0);
}

void compressed_region_0(float w0_0, float w1_0, float dz_0, float ax_0, float ay_0, array<float, int(6)> thread* region_0)
{
    uint count_3;
    float h0_0 = 0.5f * w0_0;
    float h1_0 = 0.5f * w1_0;
    float _S622 = - h0_0;
    float _S623 = - h1_0;
    array<float2, int(4)> _S624 = { { float2(_S622, _S623), float2(h0_0, _S623), float2(h0_0, h1_0), float2(_S622, h1_0) } };
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
        uint _S625 = i_7;
        uint _S626 = i_7 + 1U;
        uint _S627 = _S626 % 4U;
        float _S628 = _S624[i_7].y;
        float _S629 = _S624[i_7].x;
        float fp_0 = dz_0 + ax_0 * _S628 - ay_0 * _S629;
        float _S630 = _S624[_S627].y;
        float _S631 = _S624[_S627].x;
        float fq_0 = dz_0 + ax_0 * _S630 - ay_0 * _S631;
        bool _S632 = fp_0 < 0.0f;
        if(_S632)
        {
            uint _S633 = count_4 + 1U;
            poly_0[count_4] = _S624[_S625];
            count_3 = _S633;
        }
        else
        {
            count_3 = count_4;
        }
        if(_S632 != (fq_0 < 0.0f))
        {
            float t_12 = fp_0 / (fp_0 - fq_0);
            uint _S634 = count_3 + 1U;
            poly_0[count_3] = float2(_S629 + t_12 * (_S631 - _S629), _S628 + t_12 * (_S630 - _S628));
            count_4 = _S634;
        }
        else
        {
            count_4 = count_3;
        }
        i_7 = _S626;
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
        float _S635 = o_1.x;
        float x0_0 = poly_0[i_7].x - _S635;
        float _S636 = o_1.y;
        float y0_0 = poly_0[i_7].y - _S636;
        uint _S637 = i_7 + 1U;
        uint _S638 = _S637 % count_4;
        float x1_0 = poly_0[_S638].x - _S635;
        float y1_0 = poly_0[_S638].y - _S636;
        float _S639 = x0_0 * y1_0;
        float _S640 = x1_0 * y0_0;
        float cr_0 = _S639 - _S640;
        float a_9 = a_8 + cr_0 / 2.0f;
        float sx_1 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        float sy_1 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        float ixx_1 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        float iyy_1 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        float ixy_1 = ixy_0 + (_S639 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S640) * cr_0 / 24.0f;
        i_7 = _S637;
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
    float _S641 = a_8 * cx_0;
    (*region_0)[int(3)] = ixx_0 - _S641 * cx_0;
    (*region_0)[int(4)] = iyy_0 - a_8 * cy_0 * cy_0;
    (*region_0)[int(5)] = ixy_0 - _S641 * cy_0;
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
    float _S642 = a_10 * fc_4;
    float _S643 = - ay_1;
    return float4(k_18 * a_10 * fc_4, k_18 * (_S642 * r_10[int(2)] + (_S643 * r_10[int(5)] + ax_1 * r_10[int(4)])), - k_18 * (_S642 * r_10[int(1)] + (_S643 * r_10[int(3)] + ax_1 * r_10[int(5)])), 0.5f * k_18 * (_S642 * fc_4 + ay_1 * ay_1 * r_10[int(3)] + ax_1 * ax_1 * r_10[int(4)] - 2.0f * ax_1 * ay_1 * r_10[int(5)]));
}

float signum_0(float x_7)
{
    float _S644;
    if(((as_type<uint>((x_7))) & 2147483648U) != 0U)
    {
        _S644 = -1.0f;
    }
    else
    {
        _S644 = 1.0f;
    }
    return _S644;
}

float2 return_map_0(float k_19, float total_2, float plastic_0, float cap_0)
{
    float trial_0 = k_19 * (total_2 - plastic_0);
    if((abs(trial_0)) <= cap_0)
    {
        return float2(trial_0, 0.0f);
    }
    float f_11 = cap_0 * signum_0(trial_0);
    float _S645 = (metal::fast::divide((trial_0 - f_11), (k_19)));
    return float2(f_11, _S645);
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
    float3 _S646 = float3(0.0f) ;
    (&c_14)->q_lin_1 = _S646;
    (&c_14)->q_ang_1 = _S646;
    (&c_14)->energy_2 = 0.0f;
    (&c_14)->diss_4 = 0.0f;
    (&c_14)->plastic_1 = plastic_2;
    uint _S647 = mat_4->kind_flags_0.y;
    if((_S647 & 2U) == 0U)
    {
        return c_14;
    }
    float4 _S648 = float4(b_25->stiff0_0) ;
    float kn_1 = _S648.x;
    float ks_0 = _S648.y;
    float kt_0 = (float4(b_25->stiff1_0) ).x;
    float4 _S649 = float4(b_25->geom0_0) ;
    float w0_2 = _S649.y;
    float w1_2 = _S649.z;
    float diss_5;
    float nc_sum_0;
    float m1_0;
    float m2_0;
    float energy_3;
    if((_S647 & 4U) != 0U)
    {
        float4 p_11 = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        float _S650 = p_11.y;
        float _S651 = p_11.z;
        float _S652 = p_11.w;
        nc_sum_0 = p_11.x;
        m1_0 = _S650;
        m2_0 = _S651;
        energy_3 = _S652;
    }
    else
    {
        float ki_0 = kn_1 * (1.0f - crush_2) / 36.0f;
        float _S653 = d_ang_0.x;
        float _S654 = d_ang_0.y;
        float spread_0 = abs(_S653) * 0.4166666567325592f * w1_2 + abs(_S654) * 0.4166666567325592f * w0_2;
        float _S655 = d_lin_0.z;
        float slack_0 = 9.99999997475242708e-07f * (abs(_S655) + spread_0);
        if((_S655 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S655 + spread_0) < (- slack_0))
            {
                float i1_0 = 2.91666650772094727f * w0_2 * w0_2;
                float i2_0 = 2.91666650772094727f * w1_2 * w1_2;
                float _S656 = ki_0 * _S653 * i2_0;
                float _S657 = ki_0 * _S654 * i1_0;
                float _S658 = 0.5f * ki_0 * (36.0f * _S655 * _S655 + _S653 * _S653 * i2_0 + _S654 * _S654 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S655;
                m1_0 = _S656;
                m2_0 = _S657;
                energy_3 = _S658;
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
                    float _S659 = ((float(i_8) + 0.5f) / 6.0f - 0.5f) * w0_2;
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
                        float di_0 = _S655 + _S653 * s2_0 - _S654 * _S659;
                        if(di_0 < 0.0f)
                        {
                            float f_12 = ki_0 * di_0;
                            float m1_2 = m1_0 + f_12 * s2_0;
                            float m2_2 = m2_0 - f_12 * _S659;
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
    float _S660 = ks_0 * (d_lin_0.x - plastic_2.x);
    float _S661 = ks_0 * (d_lin_0.y - plastic_2.y);
    float tn_0 = (metal::fast::sqrt((_S660 * _S660 + _S661 * _S661)));
    bool _S662;
    if(tn_0 > slide_cap_0)
    {
        _S662 = tn_0 > 0.0f;
    }
    else
    {
        _S662 = false;
    }
    if(_S662)
    {
        float _S663 = (metal::fast::divide((_S660), (tn_0)));
        float _S664 = (metal::fast::divide((_S661), (tn_0)));
        float dslip_0 = (metal::fast::divide((tn_0 - slide_cap_0), (ks_0)));
        p_12.x = p_12.x + _S663 * dslip_0;
        p_12.y = p_12.y + _S664 * dslip_0;
        (&c_14)->q_lin_1.x = _S663 * slide_cap_0;
        (&c_14)->q_lin_1.y = _S664 * slide_cap_0;
        diss_5 = slide_cap_0 * dslip_0;
    }
    else
    {
        (&c_14)->q_lin_1.x = _S660;
        (&c_14)->q_lin_1.y = _S661;
        diss_5 = 0.0f;
    }
    float2 tq_0 = return_map_0(kt_0, d_ang_0.z, p_12.z, slide_cap_0 * (float4(b_25->geom1_0) ).z);
    float _S665 = tq_0.x;
    float _S666 = tq_0.y;
    float diss_6 = diss_5 + abs(_S665) * abs(_S666);
    p_12.z = p_12.z + _S666;
    (&c_14)->q_ang_1.z = _S665;
    float _S667 = (metal::fast::divide((sq_0((&c_14)->q_lin_1.x)), (ks_0)));
    float _S668 = (metal::fast::divide((sq_0((&c_14)->q_lin_1.y)), (ks_0)));
    float _S669 = _S667 + _S668;
    float _S670 = (metal::fast::divide((sq_0(_S665)), (kt_0)));
    (&c_14)->energy_2 = energy_3 + 0.5f * (_S669 + _S670);
    (&c_14)->diss_4 = diss_6;
    (&c_14)->plastic_1 = p_12;
    return c_14;
}

float life_rate_0(const JointMaterial_0 constant* mat_5, float s_5)
{
    if(s_5 <= 0.0f)
    {
        return 0.0f;
    }
    float _S671 = mat_5->misc_0.y;
    float _S672 = _S671 + 1.0f;
    float _S673 = (metal::fast::pow((s_5), (_S671)));
    float _S674 = (metal::fast::divide((_S672 * _S673), (mat_5->misc_0.z)));
    return _S674;
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

JointResponse_0 joint_evaluate_0(const JointMaterial_0 constant* mat_6, const JointBond_natural_0 thread* b_26, const JointState_0 thread* state_7, float3 d_lin_1, float3 d_ang_1, float dt_11, bool fracture_1)
{
    float4 _S675 = float4(b_26->stiff0_0) ;
    float kn_2 = _S675.x;
    float ks_1 = _S675.y;
    float kb1_0 = _S675.z;
    float kb2_0 = _S675.w;
    float4 _S676 = float4(b_26->stiff1_0) ;
    float kt_1 = _S676.x;
    bool has_rebar_1 = (_S676.w) != 0.0f;
    uint kind_4 = mat_6->kind_flags_0.x;
    uint flags_1 = mat_6->kind_flags_0.y;
    bool softening_0 = (flags_1 & 1U) != 0U;
    thread JointState_0 st_1 = *state_7;
    bool _S677 = connected_0(state_7, has_rebar_1);
    float3 qe_lin_0 = d_lin_1 * float3(ks_1, ks_1, kn_2);
    float3 qe_ang_0 = d_ang_1 * float3(kb1_0, kb2_0, kt_1);
    Measures_0 _S678 = stress_measures_0(b_26, qe_lin_0, qe_ang_0);
    float _S679 = max(max(_S678.tension_0, _S678.shear_0), _S678.compression_0);
    bool _S680 = dt_11 > 0.0f;
    float dif_1;
    if(_S680)
    {
        float _S681 = (metal::fast::divide((_S679 - (&st_1)->governing_stress_0), (dt_11)));
        float raw_0 = (metal::fast::divide((max(_S681, 0.0f)), (mat_6->misc_0.w)));
        float tau_2 = _S676.z;
        if((flags_1 & 16U) != 0U)
        {
            float _S682 = (metal::fast::divide((dt_11), (tau_2)));
            dif_1 = - expm1_accurate_0(- _S682);
        }
        else
        {
            float _S683 = (metal::fast::divide((dt_11), (tau_2)));
            dif_1 = min(_S683, 1.0f);
        }
        (&st_1)->strain_rate_0 = (&st_1)->strain_rate_0 + (raw_0 - (&st_1)->strain_rate_0) * dif_1;
        (&st_1)->governing_stress_0 = _S679;
    }
    if((flags_1 & 32U) != 0U)
    {
        float _S684 = dif_factor_0(mat_6, (&st_1)->strain_rate_0);
        dif_1 = _S684;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = (float4(b_26->geom1_0) ).w;
    float _S685 = weibull_0 * dif_1;
    float _S686 = fatigue_factor_0(mat_6, (&st_1)->fatigue_0);
    float multiplier_1 = _S685 * _S686;
    thread Measures_0 _S687 = _S678;
    float4 _S688 = failure_indices_0(mat_6, b_26, &_S687, multiplier_1);
    float _S689 = _S688.x;
    float _S690 = _S688.y;
    (&st_1)->utilization_0 = max(max(_S689, _S690), max(_S688.z, _S688.w));
    float _S691 = d_lin_1.x;
    float _S692 = d_lin_1.y;
    float _S693 = ks_1 * (sq_0(_S691) + sq_0(_S692)) + kb1_0 * sq_0(d_ang_1.x) + kb2_0 * sq_0(d_ang_1.y) + kt_1 * sq_0(d_ang_1.z);
    float _S694 = d_lin_1.z;
    bool _S695 = _S694 > 0.0f;
    if(_S695)
    {
        dif_1 = kn_2 * sq_0(_S694);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S693 + dif_1);
    float psi_c_0;
    if(_S694 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_2 * sq_0(_S694);
    }
    else
    {
        psi_c_0 = 0.0f;
    }
    float3 plastic_3 = float3((&st_1)->plastic_x_0, (&st_1)->plastic_y_0, (&st_1)->plastic_t_0);
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
        if(diss_contact_0 > ((&st_1)->kappa_0))
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
                psi_contact_0 = mat_6->energy_1.y;
            }
            else
            {
                psi_contact_0 = mat_6->energy_1.z;
            }
            if(softening_0)
            {
                float _S698 = (metal::fast::divide((psi_contact_0 * (float4(b_26->geom0_0) ).x * diss_contact_0 * diss_contact_0), (psi_ts_0)));
                intact_normal_0 = _S698;
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
            float _S699 = inc_0.x;
            if(_S699 > ((&st_1)->damage_0))
            {
                Contact_0 _S700 = contact_part_0(mat_6, b_26, (&st_1)->crush_1, plastic_3, d_lin_1, d_ang_1);
                float _S701 = max(_S700.energy_2 - (1.0f - (&st_1)->crush_1) * psi_c_0, 0.0f);
                float _S702 = max(inc_0.y - _S701 * (_S699 - (&st_1)->damage_0), 0.0f);
                float _S703 = max((psi_ts_0 - _S701) * (_S699 - (&st_1)->damage_0) - _S702, 0.0f);
                (&st_1)->damage_0 = _S699;
                (&st_1)->mode_0 = mode_ts_0;
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
        (&st_1)->kappa_0 = max((&st_1)->kappa_0, diss_contact_0);
        float _S704 = state_7->damage_0;
        if((state_7->damage_0) > 0.0f)
        {
            Contact_0 _S705 = contact_part_0(mat_6, b_26, state_7->crush_1, float3(state_7->plastic_x_0, state_7->plastic_y_0, state_7->plastic_t_0), d_lin_1, d_ang_1);
            qc_lin_0 = qe_ang_0 * float3((1.0f - _S704))  + _S705.q_ang_1 * float3(_S704) ;
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S706 = stress_measures_0(b_26, float3(0.0f, 0.0f, min(qe_lin_0.z, 0.0f)), qc_lin_0);
        thread Measures_0 _S707 = _S706;
        float4 _S708 = failure_indices_0(mat_6, b_26, &_S707, multiplier_1);
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
        if(psi_contact_0 > ((&st_1)->kappa_c_0))
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
                float _S712 = (metal::fast::divide((mat_6->energy_1.w * (float4(b_26->geom0_0) ).x * psi_contact_0 * psi_contact_0), (psi_c_0)));
                intact_normal_0 = _S712;
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
            float _S713 = inc_1.x;
            if(_S713 > ((&st_1)->crush_1))
            {
                float _S714 = inc_1.y;
                float dissipated_4 = dissipated_3 + _S714;
                float overshoot_2 = overshoot_1 + max(psi_c_0 * (_S713 - (&st_1)->crush_1) - _S714, 0.0f);
                (&st_1)->crush_1 = _S713;
                (&st_1)->mode_0 = mode_c_0;
                if(_S713 >= 1.0f)
                {
                    _S696 = ((&st_1)->damage_0) < 1.0f;
                }
                else
                {
                    _S696 = false;
                }
                if(_S696)
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
    float3 _S715 = float3(0.0f) ;
    if(((&st_1)->damage_0) == 0.0f)
    {
        _S696 = (flags_1 & 8U) != 0U;
    }
    else
    {
        _S696 = false;
    }
    float3 qc_ang_0;
    if(!_S696)
    {
        Contact_0 _S716 = contact_part_0(mat_6, b_26, (&st_1)->crush_1, plastic_3, d_lin_1, d_ang_1);
        (&st_1)->plastic_x_0 = _S716.plastic_1.x;
        (&st_1)->plastic_y_0 = _S716.plastic_1.y;
        (&st_1)->plastic_t_0 = _S716.plastic_1.z;
        diss_contact_0 = _S716.diss_4;
        qc_lin_0 = _S716.q_lin_1;
        qc_ang_0 = _S716.q_ang_1;
        psi_contact_0 = _S716.energy_2;
    }
    else
    {
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S715;
        qc_ang_0 = _S715;
        psi_contact_0 = 0.0f;
    }
    float dissipated_6 = dissipated_3 + dmg_0 * diss_contact_0;
    if(_S695)
    {
        intact_normal_0 = kn_2 * _S694;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_1)->crush_1) * kn_2 * _S694;
    }
    float _S717 = 1.0f - dmg_0;
    float3 force_lin_2 = float3(_S717 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S717 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S717 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3 force_ang_2 = qe_ang_0 * float3(_S717)  + qc_ang_0 * float3(dmg_0) ;
    float stored_6 = _S717 * (psi_ts_0 + (1.0f - (&st_1)->crush_1) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S696 = ((&st_1)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S696 = false;
    }
    float stored_7;
    float3 force_lin_3;
    if(_S696)
    {
        float4 _S718 = float4(b_26->rebar0_0) ;
        float k_axial_0 = _S718.x;
        float k_dowel_0 = _S718.y;
        float yield_force_0 = _S718.z;
        float dowel_capacity_0 = _S718.w;
        float2 nr_0 = return_map_0(k_axial_0, _S694, (&st_1)->rebar_plastic_0, yield_force_0);
        float2 v1_0 = return_map_0(k_dowel_0, _S691, (&st_1)->rebar_slip0_0, dowel_capacity_0);
        float2 v2_0 = return_map_0(k_dowel_0, _S692, (&st_1)->rebar_slip1_0, dowel_capacity_0);
        float _S719 = nr_0.y;
        float _S720 = v1_0.y;
        float _S721 = v2_0.y;
        float work_0 = yield_force_0 * abs(_S719) + dowel_capacity_0 * (abs(_S720) + abs(_S721));
        (&st_1)->rebar_plastic_0 = (&st_1)->rebar_plastic_0 + _S719;
        (&st_1)->rebar_slip0_0 = (&st_1)->rebar_slip0_0 + _S720;
        (&st_1)->rebar_slip1_0 = (&st_1)->rebar_slip1_0 + _S721;
        (&st_1)->rebar_work_0 = (&st_1)->rebar_work_0 + work_0;
        float dissipated_7 = dissipated_6 + work_0;
        float _S722 = nr_0.x;
        float _S723 = (metal::fast::divide((sq_0(_S722)), (k_axial_0)));
        float _S724 = v1_0.x;
        float _S725 = v2_0.x;
        float _S726 = (metal::fast::divide((sq_0(_S724) + sq_0(_S725)), (k_dowel_0)));
        float elastic_0 = 0.5f * (_S723 + _S726);
        if(fracture_1)
        {
            _S696 = ((&st_1)->rebar_work_0) >= ((float4(b_26->rebar1_0) ).x);
        }
        else
        {
            _S696 = false;
        }
        if(_S696)
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
            force_lin_3 = force_lin_2 + float3(_S724, _S725, _S722);
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
        _S696 = _S680;
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
        Measures_0 _S727 = stress_measures_0(b_26, force_lin_3, force_ang_2);
        thread Measures_0 _S728 = _S727;
        float4 _S729 = failure_indices_0(mat_6, b_26, &_S728, weibull_0);
        float _S730 = life_rate_0(mat_6, max(max(_S729.x, _S729.y), _S729.z));
        (&st_1)->fatigue_0 = min((&st_1)->fatigue_0 + _S730 * dt_11, 1.0f);
    }
    (&st_1)->dissipated_0 = (&st_1)->dissipated_0 + dissipated_3;
    thread JointResponse_0 resp_0;
    (&resp_0)->force_lin_1 = force_lin_3;
    (&resp_0)->force_ang_1 = force_ang_2;
    (&resp_0)->state_6 = st_1;
    (&resp_0)->dissipated_2 = dissipated_3;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_5 = stored_7;
    if(_S677)
    {
        thread JointState_0 _S731 = st_1;
        bool _S732 = connected_0(&_S731, has_rebar_1);
        _S696 = !_S732;
    }
    else
    {
        _S696 = false;
    }
    (&resp_0)->disconnected_0 = _S696;
    (&resp_0)->measures_0 = _S678;
    return resp_0;
}

void secant_factors_0(const JointBond_natural_0 thread* b_27, const JointState_0 thread* st_2, float3 d_lin_2, float3 thread* f_lin_0, float3 thread* f_ang_0)
{
    float _S733 = st_2->damage_0;
    bool compressed_0 = (d_lin_2.z) < 0.0f;
    float contact_3;
    if(compressed_0)
    {
        contact_3 = _S733;
    }
    else
    {
        contact_3 = 0.0f;
    }
    float _S734 = 1.0f - _S733;
    float _S735 = max(_S734 + contact_3, 9.99999997475242708e-07f);
    float normal_5;
    if(compressed_0)
    {
        normal_5 = max(1.0f - st_2->crush_1, 9.99999997475242708e-07f);
    }
    else
    {
        normal_5 = max(_S734, 9.99999997475242708e-07f);
    }
    *f_lin_0 = float3(_S735, _S735, normal_5);
    *f_ang_0 = float3(_S735) ;
    bool _S736;
    if(((float4(b_27->stiff1_0) ).w) != 0.0f)
    {
        _S736 = (st_2->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S736 = false;
    }
    if(_S736)
    {
        float4 _S737 = float4(b_27->rebar0_0) ;
        float4 _S738 = float4(b_27->stiff0_0) ;
        float _S739 = (metal::fast::divide((_S737.x), (_S738.x)));
        (*f_lin_0).z = (*f_lin_0).z + _S739;
        float _S740 = _S737.y;
        float _S741 = _S738.y;
        float _S742 = (metal::fast::divide((_S740), (_S741)));
        (*f_lin_0).x = (*f_lin_0).x + _S742;
        float _S743 = (metal::fast::divide((_S740), (_S741)));
        (*f_lin_0).y = (*f_lin_0).y + _S743;
    }
    return;
}

bool is_damaged_0(const JointState_0 thread* st_3)
{
    bool _S744;
    if((st_3->damage_0) > 0.0f)
    {
        _S744 = true;
    }
    else
    {
        _S744 = (st_3->crush_1) > 0.0f;
    }
    return _S744;
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

float3 to_local_0(uint _S745, float3 _S746, KernelContext_0 thread* kernelContext_41)
{
    BondStatic_natural_0 device* _S747 = kernelContext_41->bonds_0+_S745;
    return float3(dot(_S746, (float4(_S747->t1_0) ).xyz), dot(_S746, (float4(_S747->t2_0) ).xyz), dot(_S746, (float4(_S747->normal_0) ).xyz));
}

float3 to_body_0(uint _S748, float3 _S749, KernelContext_0 thread* kernelContext_42)
{
    BondStatic_natural_0 device* _S750 = kernelContext_42->bonds_0+_S748;
    return (float4(_S750->t1_0) ).xyz * float3(_S749.x)  + (float4(_S750->t2_0) ).xyz * float3(_S749.y)  + (float4(_S750->normal_0) ).xyz * float3(_S749.z) ;
}

bool bond_update_0(uint i_9, float dt_12, bool fracture_2, uint abs_step_0, KernelContext_0 thread* kernelContext_43)
{
    BondStatic_natural_0 device* _S751 = kernelContext_43->bonds_0+i_9;
    BondDyn_natural_0 device* _S752 = kernelContext_43->bond_dyn_0+i_9;
    float4 _S753 = float4((*_S752).force_lin_0) ;
    float4 _S754 = float4((*_S752).force_ang_0) ;
    float4 _S755 = float4((*_S752).sums_0) ;
    float4 _S756 = float4((*_S752).comps_0) ;
    uint4 _S757 = uint4((*_S752).events_0) ;
    thread BondDyn_0 bd_0;
    (&bd_0)->js_0 = (*_S752).js_0;
    (&bd_0)->force_lin_0 = _S753;
    (&bd_0)->force_ang_0 = _S754;
    (&bd_0)->sums_0 = _S755;
    (&bd_0)->comps_0 = _S756;
    (&bd_0)->events_0 = _S757;
    JointBond_natural_0 _S758 = _S751->law_0;
    thread JointBond_natural_0 _S759 = _S751->law_0;
    uint4 _S760 = uint4((&_S759)->ids_0) ;
    float3 ra_1 = (float4(_S751->ra_0) ).xyz;
    float3 rb_1 = (float4(_S751->rb_0) ).xyz;
    uint _S761 = 4U * _S760.y;
    float3 ta_2 = (float4(*(kernelContext_43->state_0+(_S761 + 1U))) ).xyz;
    float3 va_0 = (float4(*(kernelContext_43->state_0+(_S761 + 2U))) ).xyz;
    float3 wa_0 = (float4(*(kernelContext_43->state_0+(_S761 + 3U))) ).xyz;
    uint _S762 = 4U * _S760.z;
    float3 tb_2 = (float4(*(kernelContext_43->state_0+(_S762 + 1U))) ).xyz;
    float3 vb_0 = (float4(*(kernelContext_43->state_0+(_S762 + 2U))) ).xyz;
    float3 wb_0 = (float4(*(kernelContext_43->state_0+(_S762 + 3U))) ).xyz;
    float3 _S763 = to_local_0(i_9, (float4(*(kernelContext_43->state_0+_S762)) ).xyz + cross(tb_2, rb_1) - ((float4(*(kernelContext_43->state_0+_S761)) ).xyz + cross(ta_2, ra_1)), kernelContext_43);
    float3 _S764 = to_local_0(i_9, tb_2 - ta_2, kernelContext_43);
    float3 _S765 = to_local_0(i_9, vb_0 + cross(wb_0, rb_1) - (va_0 + cross(wa_0, ra_1)), kernelContext_43);
    float3 _S766 = to_local_0(i_9, wb_0 - wa_0, kernelContext_43);
    JointState_0 previous_0 = (&bd_0)->js_0;
    _S759 = _S758;
    thread JointState_0 _S767 = (&bd_0)->js_0;
    JointResponse_0 _S768 = joint_evaluate_0(&kernelContext_43->materials_0->m_0[_S760.x], &_S759, &_S767, _S763, _S764, dt_12, fracture_2);
    thread JointState_0 _S769 = _S768.state_6;
    thread float3 f_lin_1;
    thread float3 f_ang_1;
    secant_factors_0(&_S759, &_S769, _S763, &f_lin_1, &f_ang_1);
    float3 qd_lin_0 = _S765 * (float4(_S751->c_lin_0) ).xyz * f_lin_1;
    float3 qd_ang_0 = _S766 * (float4(_S751->c_ang_0) ).xyz * f_ang_1;
    float3 q_lin_2 = _S768.force_lin_1 + qd_lin_0;
    float3 q_ang_2 = _S768.force_ang_1 + qd_ang_0;
    float damped_0 = (dot(qd_lin_0, _S765) + dot(qd_ang_0, _S766)) * dt_12;
    float3 _S770 = to_body_0(i_9, q_lin_2, kernelContext_43);
    float3 _S771 = to_body_0(i_9, q_ang_2, kernelContext_43);
    uint _S772 = 3U * i_9;
    *(kernelContext_43->scratch_0+_S772) = packed_float4(float4(_S770, max(_S768.measures_0.tension_0, _S768.measures_0.compression_0))) ;
    *(kernelContext_43->scratch_0+(_S772 + 1U)) = packed_float4(float4(_S771 + cross(ra_1, _S770), 0.0f)) ;
    *(kernelContext_43->scratch_0+(_S772 + 2U)) = packed_float4(float4(- _S771 + cross(rb_1, - _S770), 0.0f)) ;
    thread float _S773 = (&bd_0)->sums_0.x;
    thread float _S774 = (&bd_0)->comps_0.x;
    comp_add1_0(&_S773, &_S774, _S768.dissipated_2);
    (&bd_0)->comps_0.x = _S774;
    (&bd_0)->sums_0.x = _S773;
    thread float _S775 = (&bd_0)->sums_0.y;
    thread float _S776 = (&bd_0)->comps_0.y;
    comp_add1_0(&_S775, &_S776, _S768.overshoot_0);
    (&bd_0)->comps_0.y = _S776;
    (&bd_0)->sums_0.y = _S775;
    thread float _S777 = (&bd_0)->sums_0.z;
    thread float _S778 = (&bd_0)->comps_0.z;
    comp_add1_0(&_S777, &_S778, damped_0);
    (&bd_0)->comps_0.z = _S778;
    (&bd_0)->sums_0.z = _S777;
    (&bd_0)->force_lin_0 = float4(q_lin_2, _S768.stored_5);
    (&bd_0)->force_ang_0 = float4(q_ang_2, max((&bd_0)->force_ang_0.w, _S768.state_6.utilization_0));
    thread JointState_0 _S779 = previous_0;
    bool _S780 = is_damaged_0(&_S779);
    bool _S781;
    if(!_S780)
    {
        thread JointState_0 _S782 = _S768.state_6;
        bool _S783 = is_damaged_0(&_S782);
        _S781 = _S783;
    }
    else
    {
        _S781 = false;
    }
    if(_S781)
    {
        _S781 = ((&bd_0)->events_0.x) == 0U;
    }
    else
    {
        _S781 = false;
    }
    if(_S781)
    {
        (&bd_0)->events_0.x = abs_step_0;
        (&bd_0)->events_0.w = _S768.state_6.mode_0;
    }
    if(((&bd_0)->events_0.y) == 0U)
    {
        float _S784 = fatigue_factor_0(&kernelContext_43->materials_0->m_0[_S760.x], previous_0.fatigue_0);
        _S781 = _S784 > 0.99000000953674316f;
    }
    else
    {
        _S781 = false;
    }
    if(_S781)
    {
        float _S785 = fatigue_factor_0(&kernelContext_43->materials_0->m_0[_S760.x], _S768.state_6.fatigue_0);
        _S781 = _S785 <= 0.99000000953674316f;
    }
    else
    {
        _S781 = false;
    }
    if(_S781)
    {
        (&bd_0)->events_0.y = abs_step_0;
    }
    if(_S768.disconnected_0)
    {
        (&bd_0)->events_0.z = abs_step_0;
    }
    (&bd_0)->js_0 = _S768.state_6;
    BondDyn_natural_0 device* _S786 = kernelContext_43->bond_dyn_0+i_9;
    _S786->js_0 = bd_0.js_0;
    _S786->force_lin_0 = packed_float4(bd_0.force_lin_0) ;
    _S786->force_ang_0 = packed_float4(bd_0.force_ang_0) ;
    _S786->sums_0 = packed_float4(bd_0.sums_0) ;
    _S786->comps_0 = packed_float4(bd_0.comps_0) ;
    _S786->events_0 = packed_uint4(bd_0.events_0) ;
    return _S768.disconnected_0;
}

void chunk_update_0(uint c_15, const Island_natural_0 thread* isl_11, const Rigid_0 thread* rg_9, float dt_13, bool rml_0, uint step_0, bool contact_4, float thread* work_1, float thread* work_err_0, KernelContext_0 thread* kernelContext_44)
{
    ChunkStatic_natural_0 device* _S787 = kernelContext_44->chunks_0+c_15;
    float3 _S788 = float3(0.0f) ;
    uint _S789 = kernelContext_44->index_0[c_15];
    float peak_0 = 0.0f;
    uint e_3 = _S789;
    float3 fi_0 = _S788;
    float3 mi_0 = _S788;
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
        uint _S790 = 3U * (entry_2 >> 1U);
        float4 _S791 = float4(*(kernelContext_44->scratch_0+_S790)) ;
        if((entry_2 & 1U) == 0U)
        {
            float3 mi_1 = mi_0 + (float4(*(kernelContext_44->scratch_0+(_S790 + 1U))) ).xyz;
            fi_0 = fi_0 + _S791.xyz;
            mi_0 = mi_1;
        }
        else
        {
            float3 mi_2 = mi_0 + (float4(*(kernelContext_44->scratch_0+(_S790 + 2U))) ).xyz;
            fi_0 = fi_0 + - _S791.xyz;
            mi_0 = mi_2;
        }
        float _S792 = max(peak_0, _S791.w);
        uint _S793 = e_3 + 1U;
        peak_0 = _S792;
        e_3 = _S793;
    }
    uint _S794 = 4U * c_15;
    float3 u_0 = (float4(*(kernelContext_44->state_0+_S794)) ).xyz;
    uint _S795 = _S794 + 1U;
    float3 th_1 = (float4(*(kernelContext_44->state_0+_S795)) ).xyz;
    uint _S796 = _S794 + 2U;
    float3 v_10 = (float4(*(kernelContext_44->state_0+_S796)) ).xyz;
    uint _S797 = _S794 + 3U;
    float3 w_4 = (float4(*(kernelContext_44->state_0+_S797)) ).xyz;
    float4 _S798 = float4(_S787->center_0) ;
    float mass_0 = _S798.w;
    float3 _S799 = _S798.xyz;
    float3 _S800 = (float4(isl_11->com_0) ).xyz;
    float3 _S801 = rotate_0(&rg_9->rot_0, _S799 + u_0 - _S800);
    thread float3 f_load_0;
    thread float3 t_load_0;
    chunk_external_0(c_15, c_15, &rg_9->rot_0, step_0, dt_13, contact_4, &f_load_0, &t_load_0, kernelContext_44);
    record_chunk_load_0(c_15, f_load_0, t_load_0, kernelContext_44);
    float3 _S802 = float3(mass_0) ;
    float3 f_world_0 = f_load_0 + kernelContext_44->params_0->gravity_0.xyz * _S802;
    float3 t_world_0 = t_load_0;
    float3 f_world_1;
    float3 t_world_1;
    if(rml_0)
    {
        float3 f_world_2 = f_world_0 - (rg_9->a_6 + cross(rg_9->alpha_0, _S801) + cross(rg_9->w_3, cross(rg_9->w_3, _S801))) * _S802;
        float4 _S803 = float4(_S787->inertia0_1) ;
        float4 _S804 = float4(_S787->inertia1_1) ;
        float4 _S805 = float4(_S787->inertia2_1) ;
        float3 _S806 = world_mul_0(&rg_9->rot_0, _S803, _S804, _S805, rg_9->alpha_0);
        float3 _S807 = world_mul_0(&rg_9->rot_0, _S803, _S804, _S805, rg_9->w_3);
        float3 t_world_2 = t_world_0 - (_S806 + cross(rg_9->w_3, _S807));
        f_world_1 = f_world_2;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    float3 _S808 = inverse_rotate_0(&rg_9->rot_0, f_world_1);
    float3 _S809 = inverse_rotate_0(&rg_9->rot_0, t_world_1);
    float3 f_ext_0;
    float3 m_ext_0;
    if(rml_0)
    {
        float3 _S810 = inverse_rotate_0(&rg_9->rot_0, rg_9->w_3);
        float4 _S811 = float4(_S787->inertia0_1) ;
        float4 _S812 = float4(_S787->inertia1_1) ;
        float4 _S813 = float4(_S787->inertia2_1) ;
        float3 i_w_0 = rows_mul_0(_S811, _S812, _S813, w_4);
        float3 m_ext_1 = _S809 - (cross(_S810, i_w_0) + cross(w_4, rows_mul_0(_S811, _S812, _S813, _S810)) + cross(w_4, i_w_0));
        f_ext_0 = _S808 - cross(_S810, v_10) * float3((2.0f * mass_0)) ;
        m_ext_0 = m_ext_1;
    }
    else
    {
        f_ext_0 = _S808;
        m_ext_0 = _S809;
    }
    uint4 _S814 = uint4(_S787->load_range_0) ;
    uint term_4 = _S814.x;
    for(;;)
    {
        if(term_4 < (_S814.y))
        {
        }
        else
        {
            break;
        }
        uint _S815 = 5U * term_4;
        if(((as_type<uint4>((float4(*(kernelContext_44->loads_0+_S815)) ))).y) != 2U)
        {
            term_4 = term_4 + 1U;
            continue;
        }
        float _S816 = eval_function_0(term_4, step_0, dt_13, dt_13, kernelContext_44);
        float3 _S817 = float3(_S816) ;
        float3 m_ext_2 = m_ext_0 + (float4(*(kernelContext_44->loads_0+(_S815 + 2U))) ).xyz * _S817;
        f_ext_0 = f_ext_0 + (float4(*(kernelContext_44->loads_0+(_S815 + 1U))) ).xyz * _S817;
        m_ext_0 = m_ext_2;
        term_4 = term_4 + 1U;
    }
    float3 f_13 = f_ext_0 + fi_0;
    float3 m_5 = m_ext_0 + mi_0;
    uint support_0 = (uint4(_S787->info_1) ).x;
    float3 _S818 = float3((float4(*(kernelContext_44->state_0+_S795)) ).w, (float4(*(kernelContext_44->state_0+_S796)) ).w, (float4(*(kernelContext_44->state_0+_S797)) ).w);
    float3 reaction_0;
    float3 u_1;
    float3 th_2;
    float3 v_11;
    float3 w_5;
    if(support_0 == 1U)
    {
        reaction_0 = - f_13;
        u_1 = u_0;
        th_2 = th_1;
        v_11 = _S788;
        w_5 = _S788;
    }
    else
    {
        float4 _S819 = float4(_S787->scale_0) ;
        float3 w_6 = w_4 + rows_mul_0(float4(_S787->inv0_1) , float4(_S787->inv1_1) , float4(_S787->inv2_1) , m_5) * float3((dt_13 * _S819.z)) ;
        float3 _S820 = float3(dt_13) ;
        float3 th_3 = th_1 + w_6 * _S820;
        if(support_0 == 2U)
        {
            reaction_0 = - f_13;
            u_1 = u_0;
            th_2 = _S788;
        }
        else
        {
            float3 v_12 = v_10 + f_13 * float3((dt_13 * _S819.y)) ;
            float3 u_2 = u_0 + v_12 * _S820;
            reaction_0 = _S818;
            u_1 = u_2;
            th_2 = v_12;
        }
        float3 _S821 = th_2;
        th_2 = th_3;
        v_11 = _S821;
        w_5 = w_6;
    }
    *(kernelContext_44->state_0+_S794) = packed_float4(float4(u_1, peak_0)) ;
    *(kernelContext_44->state_0+_S795) = packed_float4(float4(th_2, reaction_0.x)) ;
    *(kernelContext_44->state_0+_S796) = packed_float4(float4(v_11, reaction_0.y)) ;
    *(kernelContext_44->state_0+_S797) = packed_float4(float4(w_5, reaction_0.z)) ;
    float3 _S822 = rotate_0(&rg_9->rot_0, _S799 + u_1 - _S800);
    float3 _S823 = rg_9->vel_1 + rg_9->vel_err_1 + cross(rg_9->w_3, _S822);
    float3 _S824 = rotate_0(&rg_9->rot_0, v_11);
    float3 v_world_0 = _S823 + _S824;
    float3 _S825 = rotate_0(&rg_9->rot_0, w_5);
    comp_add1_0(work_1, work_err_0, (dot(f_load_0, v_world_0) + dot(t_load_0, rg_9->w_3 + _S825)) * dt_13);
    return;
}

void chunk_update_1(uint c_16, const Island_0 thread* isl_12, const Rigid_0 thread* rg_10, float dt_14, bool rml_1, uint step_1, bool contact_5, float thread* work_2, float thread* work_err_1, KernelContext_0 thread* kernelContext_45)
{
    ChunkStatic_natural_0 device* _S826 = kernelContext_45->chunks_0+c_16;
    float3 _S827 = float3(0.0f) ;
    uint _S828 = kernelContext_45->index_0[c_16];
    float peak_1 = 0.0f;
    uint e_4 = _S828;
    float3 fi_1 = _S827;
    float3 mi_3 = _S827;
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
        uint _S829 = 3U * (entry_3 >> 1U);
        float4 _S830 = float4(*(kernelContext_45->scratch_0+_S829)) ;
        if((entry_3 & 1U) == 0U)
        {
            float3 mi_4 = mi_3 + (float4(*(kernelContext_45->scratch_0+(_S829 + 1U))) ).xyz;
            fi_1 = fi_1 + _S830.xyz;
            mi_3 = mi_4;
        }
        else
        {
            float3 mi_5 = mi_3 + (float4(*(kernelContext_45->scratch_0+(_S829 + 2U))) ).xyz;
            fi_1 = fi_1 + - _S830.xyz;
            mi_3 = mi_5;
        }
        float _S831 = max(peak_1, _S830.w);
        uint _S832 = e_4 + 1U;
        peak_1 = _S831;
        e_4 = _S832;
    }
    uint _S833 = 4U * c_16;
    float3 u_3 = (float4(*(kernelContext_45->state_0+_S833)) ).xyz;
    uint _S834 = _S833 + 1U;
    float3 th_4 = (float4(*(kernelContext_45->state_0+_S834)) ).xyz;
    uint _S835 = _S833 + 2U;
    float3 v_13 = (float4(*(kernelContext_45->state_0+_S835)) ).xyz;
    uint _S836 = _S833 + 3U;
    float3 w_7 = (float4(*(kernelContext_45->state_0+_S836)) ).xyz;
    float4 _S837 = float4(_S826->center_0) ;
    float mass_1 = _S837.w;
    float3 _S838 = _S837.xyz;
    float3 _S839 = isl_12->com_0.xyz;
    float3 _S840 = rotate_0(&rg_10->rot_0, _S838 + u_3 - _S839);
    thread float3 f_load_1;
    thread float3 t_load_1;
    chunk_external_0(c_16, c_16, &rg_10->rot_0, step_1, dt_14, contact_5, &f_load_1, &t_load_1, kernelContext_45);
    record_chunk_load_0(c_16, f_load_1, t_load_1, kernelContext_45);
    float3 _S841 = float3(mass_1) ;
    float3 f_world_3 = f_load_1 + kernelContext_45->params_0->gravity_0.xyz * _S841;
    float3 t_world_3 = t_load_1;
    float3 f_world_4;
    float3 t_world_4;
    if(rml_1)
    {
        float3 f_world_5 = f_world_3 - (rg_10->a_6 + cross(rg_10->alpha_0, _S840) + cross(rg_10->w_3, cross(rg_10->w_3, _S840))) * _S841;
        float4 _S842 = float4(_S826->inertia0_1) ;
        float4 _S843 = float4(_S826->inertia1_1) ;
        float4 _S844 = float4(_S826->inertia2_1) ;
        float3 _S845 = world_mul_0(&rg_10->rot_0, _S842, _S843, _S844, rg_10->alpha_0);
        float3 _S846 = world_mul_0(&rg_10->rot_0, _S842, _S843, _S844, rg_10->w_3);
        float3 t_world_5 = t_world_3 - (_S845 + cross(rg_10->w_3, _S846));
        f_world_4 = f_world_5;
        t_world_4 = t_world_5;
    }
    else
    {
        f_world_4 = f_world_3;
        t_world_4 = t_world_3;
    }
    float3 _S847 = inverse_rotate_0(&rg_10->rot_0, f_world_4);
    float3 _S848 = inverse_rotate_0(&rg_10->rot_0, t_world_4);
    float3 f_ext_1;
    float3 m_ext_3;
    if(rml_1)
    {
        float3 _S849 = inverse_rotate_0(&rg_10->rot_0, rg_10->w_3);
        float4 _S850 = float4(_S826->inertia0_1) ;
        float4 _S851 = float4(_S826->inertia1_1) ;
        float4 _S852 = float4(_S826->inertia2_1) ;
        float3 i_w_1 = rows_mul_0(_S850, _S851, _S852, w_7);
        float3 m_ext_4 = _S848 - (cross(_S849, i_w_1) + cross(w_7, rows_mul_0(_S850, _S851, _S852, _S849)) + cross(w_7, i_w_1));
        f_ext_1 = _S847 - cross(_S849, v_13) * float3((2.0f * mass_1)) ;
        m_ext_3 = m_ext_4;
    }
    else
    {
        f_ext_1 = _S847;
        m_ext_3 = _S848;
    }
    uint4 _S853 = uint4(_S826->load_range_0) ;
    uint term_5 = _S853.x;
    for(;;)
    {
        if(term_5 < (_S853.y))
        {
        }
        else
        {
            break;
        }
        uint _S854 = 5U * term_5;
        if(((as_type<uint4>((float4(*(kernelContext_45->loads_0+_S854)) ))).y) != 2U)
        {
            term_5 = term_5 + 1U;
            continue;
        }
        float _S855 = eval_function_0(term_5, step_1, dt_14, dt_14, kernelContext_45);
        float3 _S856 = float3(_S855) ;
        float3 m_ext_5 = m_ext_3 + (float4(*(kernelContext_45->loads_0+(_S854 + 2U))) ).xyz * _S856;
        f_ext_1 = f_ext_1 + (float4(*(kernelContext_45->loads_0+(_S854 + 1U))) ).xyz * _S856;
        m_ext_3 = m_ext_5;
        term_5 = term_5 + 1U;
    }
    float3 f_14 = f_ext_1 + fi_1;
    float3 m_6 = m_ext_3 + mi_3;
    uint support_1 = (uint4(_S826->info_1) ).x;
    float3 _S857 = float3((float4(*(kernelContext_45->state_0+_S834)) ).w, (float4(*(kernelContext_45->state_0+_S835)) ).w, (float4(*(kernelContext_45->state_0+_S836)) ).w);
    float3 reaction_1;
    float3 u_4;
    float3 th_5;
    float3 v_14;
    float3 w_8;
    if(support_1 == 1U)
    {
        reaction_1 = - f_14;
        u_4 = u_3;
        th_5 = th_4;
        v_14 = _S827;
        w_8 = _S827;
    }
    else
    {
        float4 _S858 = float4(_S826->scale_0) ;
        float3 w_9 = w_7 + rows_mul_0(float4(_S826->inv0_1) , float4(_S826->inv1_1) , float4(_S826->inv2_1) , m_6) * float3((dt_14 * _S858.z)) ;
        float3 _S859 = float3(dt_14) ;
        float3 th_6 = th_4 + w_9 * _S859;
        if(support_1 == 2U)
        {
            reaction_1 = - f_14;
            u_4 = u_3;
            th_5 = _S827;
        }
        else
        {
            float3 v_15 = v_13 + f_14 * float3((dt_14 * _S858.y)) ;
            float3 u_5 = u_3 + v_15 * _S859;
            reaction_1 = _S857;
            u_4 = u_5;
            th_5 = v_15;
        }
        float3 _S860 = th_5;
        th_5 = th_6;
        v_14 = _S860;
        w_8 = w_9;
    }
    *(kernelContext_45->state_0+_S833) = packed_float4(float4(u_4, peak_1)) ;
    *(kernelContext_45->state_0+_S834) = packed_float4(float4(th_5, reaction_1.x)) ;
    *(kernelContext_45->state_0+_S835) = packed_float4(float4(v_14, reaction_1.y)) ;
    *(kernelContext_45->state_0+_S836) = packed_float4(float4(w_8, reaction_1.z)) ;
    float3 _S861 = rotate_0(&rg_10->rot_0, _S838 + u_4 - _S839);
    float3 _S862 = rg_10->vel_1 + rg_10->vel_err_1 + cross(rg_10->w_3, _S861);
    float3 _S863 = rotate_0(&rg_10->rot_0, v_14);
    float3 v_world_1 = _S862 + _S863;
    float3 _S864 = rotate_0(&rg_10->rot_0, w_8);
    comp_add1_0(work_2, work_err_1, (dot(f_load_1, v_world_1) + dot(t_load_1, rg_10->w_3 + _S864)) * dt_14);
    return;
}

void drift_moments_0(uint c_17, float3 thread* tu_0, float3 thread* pv_0, KernelContext_0 thread* kernelContext_46)
{
    ChunkStatic_natural_0 device* _S865 = kernelContext_46->chunks_0+c_17;
    uint _S866 = 4U * c_17;
    float3 _S867 = float3(((float4(_S865->center_0) ).w * (float4(_S865->scale_0) ).x)) ;
    *tu_0 = *tu_0 + (float4(*(kernelContext_46->state_0+_S866)) ).xyz * _S867;
    *pv_0 = *pv_0 + (float4(*(kernelContext_46->state_0+(_S866 + 2U))) ).xyz * _S867;
    return;
}

void drift_angular_0(uint c_18, float3 wcom_1, float3 tr_0, float3 dv_0, float3 thread* lu_0, float3 thread* lv_0, KernelContext_0 thread* kernelContext_47)
{
    ChunkStatic_natural_0 device* _S868 = kernelContext_47->chunks_0+c_18;
    float4 _S869 = float4(_S868->center_0) ;
    float3 r_11 = _S869.xyz - wcom_1;
    uint _S870 = 4U * c_18;
    float3 _S871 = float3(_S869.w) ;
    float4 _S872 = float4(_S868->inertia0_1) ;
    float4 _S873 = float4(_S868->inertia1_1) ;
    float4 _S874 = float4(_S868->inertia2_1) ;
    float3 _S875 = float3((float4(_S868->scale_0) ).x) ;
    *lu_0 = *lu_0 + (cross(r_11, (float4(*(kernelContext_47->state_0+_S870)) ).xyz - tr_0) * _S871 + rows_mul_0(_S872, _S873, _S874, (float4(*(kernelContext_47->state_0+(_S870 + 1U))) ).xyz)) * _S875;
    *lv_0 = *lv_0 + (cross(r_11, (float4(*(kernelContext_47->state_0+(_S870 + 2U))) ).xyz - dv_0) * _S871 + rows_mul_0(_S872, _S873, _S874, (float4(*(kernelContext_47->state_0+(_S870 + 3U))) ).xyz)) * _S875;
    return;
}

void drift_apply_0(uint c_19, float3 wcom_2, float3 tr_1, float3 phi_0, float3 dv_1, float3 dw_0, KernelContext_0 thread* kernelContext_48)
{
    float3 r_12 = (float4((kernelContext_48->chunks_0+c_19)->center_0) ).xyz - wcom_2;
    uint _S876 = 4U * c_19;
    *(kernelContext_48->state_0+_S876) = packed_float4(float4((float4(*(kernelContext_48->state_0+_S876)) ).xyz - (tr_1 + cross(phi_0, r_12)), (float4(*(kernelContext_48->state_0+_S876)) ).w)) ;
    uint _S877 = _S876 + 1U;
    *(kernelContext_48->state_0+_S877) = packed_float4(float4((float4(*(kernelContext_48->state_0+_S877)) ).xyz - phi_0, (float4(*(kernelContext_48->state_0+_S877)) ).w)) ;
    uint _S878 = _S876 + 2U;
    *(kernelContext_48->state_0+_S878) = packed_float4(float4((float4(*(kernelContext_48->state_0+_S878)) ).xyz - (dv_1 + cross(dw_0, r_12)), (float4(*(kernelContext_48->state_0+_S878)) ).w)) ;
    uint _S879 = _S876 + 3U;
    *(kernelContext_48->state_0+_S879) = packed_float4(float4((float4(*(kernelContext_48->state_0+_S879)) ).xyz - dw_0, (float4(*(kernelContext_48->state_0+_S879)) ).w)) ;
    return;
}

void drift_rigid_0(const Island_natural_0 thread* isl_13, Rigid_0 thread* rg_11, float3 tr_2, float3 phi_1, float3 dv_2, float3 dw_1)
{
    float3 wcom_3 = (float4(isl_13->wcom_0) ).xyz;
    Quat_0 rot_2 = rg_11->rot_0;
    float3 _S880 = tr_2 - cross(phi_1, wcom_3);
    thread Quat_0 _S881 = rg_11->rot_0;
    float3 _S882 = rotate_0(&_S881, _S880);
    comp_add_0(&rg_11->pos_1, &rg_11->pos_err_1, _S882);
    Quat_0 _S883 = from_axis_angle_0(phi_1, length(phi_1));
    thread Quat_0 _S884 = rg_11->rot_0;
    thread Quat_0 _S885 = _S883;
    Quat_0 _S886 = quat_mul_0(&_S884, &_S885);
    thread Quat_0 _S887 = _S886;
    Quat_0 _S888 = normalized_0(&_S887);
    rg_11->rot_0 = _S888;
    float3 _S889 = dv_2 + cross(dw_1, (float4(isl_13->com_0) ).xyz - wcom_3);
    thread Quat_0 _S890 = rot_2;
    float3 _S891 = rotate_0(&_S890, _S889);
    comp_add_0(&rg_11->vel_1, &rg_11->vel_err_1, _S891);
    thread Quat_0 _S892 = rot_2;
    float3 _S893 = rotate_0(&_S892, dw_1);
    rg_11->w_3 = rg_11->w_3 + _S893;
    return;
}

void drift_rigid_1(const Island_0 thread* isl_14, Rigid_0 thread* rg_12, float3 tr_3, float3 phi_2, float3 dv_3, float3 dw_2)
{
    float3 wcom_4 = isl_14->wcom_0.xyz;
    Quat_0 rot_3 = rg_12->rot_0;
    float3 _S894 = tr_3 - cross(phi_2, wcom_4);
    thread Quat_0 _S895 = rg_12->rot_0;
    float3 _S896 = rotate_0(&_S895, _S894);
    comp_add_0(&rg_12->pos_1, &rg_12->pos_err_1, _S896);
    Quat_0 _S897 = from_axis_angle_0(phi_2, length(phi_2));
    thread Quat_0 _S898 = rg_12->rot_0;
    thread Quat_0 _S899 = _S897;
    Quat_0 _S900 = quat_mul_0(&_S898, &_S899);
    thread Quat_0 _S901 = _S900;
    Quat_0 _S902 = normalized_0(&_S901);
    rg_12->rot_0 = _S902;
    float3 _S903 = dv_3 + cross(dw_2, isl_14->com_0.xyz - wcom_4);
    thread Quat_0 _S904 = rot_3;
    float3 _S905 = rotate_0(&_S904, _S903);
    comp_add_0(&rg_12->vel_1, &rg_12->vel_err_1, _S905);
    thread Quat_0 _S906 = rot_3;
    float3 _S907 = rotate_0(&_S906, dw_2);
    rg_12->w_3 = rg_12->w_3 + _S907;
    return;
}

void contact_split_at_0(uint at_6, KernelContext_0 thread* kernelContext_49)
{
    uint previous_1 = (uint4((kernelContext_49->islands_0+kernelContext_49->params_0->halt_index_0)->info_0) ).y;
    uint _S908;
    if(previous_1 == 0U)
    {
        _S908 = at_6;
    }
    else
    {
        _S908 = min(previous_1, at_6);
    }
    (kernelContext_49->islands_0+kernelContext_49->params_0->halt_index_0)->info_0[int(1)] = _S908;
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
    threadgroup array<float4, int(256)> g_red_a_6;
    (&kernelContext_50)->g_red_a_0 = &g_red_a_6;
    threadgroup array<float4, int(256)> g_red_b_6;
    (&kernelContext_50)->g_red_b_0 = &g_red_b_6;
    threadgroup uint g_run_6;
    (&kernelContext_50)->g_run_0 = &g_run_6;
    threadgroup uint g_halt_6;
    (&kernelContext_50)->g_halt_0 = &g_halt_6;
    threadgroup uint g_wide_run_6;
    (&kernelContext_50)->g_wide_run_0 = &g_wide_run_6;
    uint tid_4 = thread_2.x;
    uint _S909 = group_2.x;
    Island_natural_0 device* _S910 = islands_6+_S909;
    uint4 _S911 = uint4((*_S910).info_0) ;
    float4 _S912 = float4((*_S910).com_0) ;
    float4 _S913 = float4((*_S910).inertia0_0) ;
    float4 _S914 = float4((*_S910).inertia1_0) ;
    float4 _S915 = float4((*_S910).inertia2_0) ;
    float4 _S916 = float4((*_S910).inv0_0) ;
    float4 _S917 = float4((*_S910).inv1_0) ;
    float4 _S918 = float4((*_S910).inv2_0) ;
    float4 _S919 = float4((*_S910).wcom_0) ;
    float4 _S920 = float4((*_S910).winv0_0) ;
    float4 _S921 = float4((*_S910).winv1_0) ;
    float4 _S922 = float4((*_S910).winv2_0) ;
    float4 _S923 = float4((*_S910).rotation_0) ;
    float4 _S924 = float4((*_S910).position_0) ;
    float4 _S925 = float4((*_S910).position_err_0) ;
    float4 _S926 = float4((*_S910).velocity_0) ;
    float4 _S927 = float4((*_S910).velocity_err_0) ;
    float4 _S928 = float4((*_S910).angular_velocity_0) ;
    uint4 _S929 = uint4((*_S910).done_0) ;
    uint4 _S930 = uint4((*_S910).probes_0) ;
    float4 _S931 = float4((*_S910).energy_0) ;
    thread Island_0 isl_15;
    (&isl_15)->range_0 = uint4((*_S910).range_0) ;
    (&isl_15)->info_0 = _S911;
    (&isl_15)->com_0 = _S912;
    (&isl_15)->inertia0_0 = _S913;
    (&isl_15)->inertia1_0 = _S914;
    (&isl_15)->inertia2_0 = _S915;
    (&isl_15)->inv0_0 = _S916;
    (&isl_15)->inv1_0 = _S917;
    (&isl_15)->inv2_0 = _S918;
    (&isl_15)->wcom_0 = _S919;
    (&isl_15)->winv0_0 = _S920;
    (&isl_15)->winv1_0 = _S921;
    (&isl_15)->winv2_0 = _S922;
    (&isl_15)->rotation_0 = _S923;
    (&isl_15)->position_0 = _S924;
    (&isl_15)->position_err_0 = _S925;
    (&isl_15)->velocity_0 = _S926;
    (&isl_15)->velocity_err_0 = _S927;
    (&isl_15)->angular_velocity_0 = _S928;
    (&isl_15)->done_0 = _S929;
    (&isl_15)->probes_0 = _S930;
    (&isl_15)->energy_0 = _S931;
    bool driven_0 = (((&isl_15)->info_0.x) & 2U) != 0U;
    bool _S932 = !((((&isl_15)->info_0.x) & 1U) != 0U);
    bool _S933;
    if(_S932)
    {
        _S933 = !driven_0;
    }
    else
    {
        _S933 = false;
    }
    bool contact_island_0 = (((&isl_15)->info_0.x) & 4U) != 0U;
    bool _S934 = (((&isl_15)->info_0.x) & 16U) != 0U;
    bool _S935 = tid_4 == 0U;
    bool settled_0;
    uint run_0;
    if(_S935)
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
            thread Island_0 _S936 = isl_15;
            bool _S937 = contact_stopped_1(&_S936, &kernelContext_50);
            settled_0 = _S937;
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
    float _S938 = (&kernelContext_50)->params_0->dt_0;
    bool _S939 = ((&kernelContext_50)->params_0->fracture_0) != 0U;
    bool _S940 = ((&kernelContext_50)->params_0->rigid_motion_loads_0) != 0U;
    thread Island_0 _S941 = isl_15;
    Rigid_0 _S942 = rigid_of_1(&_S941);
    thread Rigid_0 rg_13 = _S942;
    thread float work_3 = 0.0f;
    thread float work_err_2 = 0.0f;
    settled_0 = _S934;
    uint done_1 = 0U;
    bool woke_1 = false;
    uint s_6 = 0U;
    for(;;)
    {
        if(s_6 < run_0)
        {
        }
        else
        {
            woke_0 = woke_1;
            break;
        }
        uint abs_step_1 = (&isl_15)->info_0.w + s_6 + 1U;
        uint k_20 = abs_step_1 - 1U - (&kernelContext_50)->params_0->step_start_0;
        bool _S943;
        bool settled_1;
        if((((&isl_15)->info_0.x) & 32U) != 0U)
        {
            if(_S935)
            {
                _S943 = ((&isl_15)->probes_0.y) > ((&isl_15)->probes_0.x);
            }
            else
            {
                _S943 = false;
            }
            if(_S943)
            {
                thread Island_0 _S944 = isl_15;
                thread Rigid_0 _S945 = rg_13;
                record_probes_0(&_S944, &_S945, k_20, &kernelContext_50);
            }
            uint _S946 = s_6 + 1U;
            settled_1 = settled_0;
            done_1 = _S946;
            woke_0 = woke_1;
            uint _S947 = s_6 + 1U;
            settled_0 = settled_1;
            woke_1 = woke_0;
            s_6 = _S947;
            continue;
        }
        uint i_10;
        if(settled_0)
        {
            float3 _S948 = float3(0.0f) ;
            thread float3 norm_0 = _S948;
            thread float3 unused0_0 = _S948;
            i_10 = (&isl_15)->range_0.x + tid_4;
            for(;;)
            {
                if(i_10 < ((&isl_15)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                thread Quat_0 _S949 = (&rg_13)->rot_0;
                float _S950 = settled_chunk_load_0(i_10, &_S949, k_20, _S938, contact_island_0, &kernelContext_50);
                norm_0.x = norm_0.x + _S950;
                i_10 = i_10 + 256U;
            }
            group_sum3_0(tid_4, &norm_0, &unused0_0, &kernelContext_50);
            if(((&kernelContext_50)->params_0->solve_mode_0) == 1U)
            {
                _S943 = (abs(norm_0.x - (&isl_15)->energy_0.z)) > ((&isl_15)->energy_0.w);
            }
            else
            {
                _S943 = false;
            }
            if(_S943)
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
        if(_S932)
        {
            float3 _S951 = float3(0.0f) ;
            thread float3 f_15 = _S951;
            thread float3 t_13 = _S951;
            i_10 = (&isl_15)->range_0.x + tid_4;
            for(;;)
            {
                if(i_10 < ((&isl_15)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                thread Island_0 _S952 = isl_15;
                thread Rigid_0 _S953 = rg_13;
                net_load_1(i_10, &_S952, &_S953, k_20, _S938, contact_island_0, &f_15, &t_13, &kernelContext_50);
                i_10 = i_10 + 256U;
            }
            group_sum3_0(tid_4, &f_15, &t_13, &kernelContext_50);
            thread Island_0 _S954 = isl_15;
            rigid_acceleration_1(&_S954, &rg_13, f_15, t_13);
        }
        if(settled_1)
        {
            if(_S933)
            {
                thread Island_0 _S955 = isl_15;
                integrate_rigid_1(&_S955, &rg_13, _S938);
            }
            if(_S935)
            {
                _S943 = ((&isl_15)->probes_0.y) > ((&isl_15)->probes_0.x);
            }
            else
            {
                _S943 = false;
            }
            if(_S943)
            {
                thread Island_0 _S956 = isl_15;
                thread Rigid_0 _S957 = rg_13;
                record_probes_0(&_S956, &_S957, k_20, &kernelContext_50);
            }
            done_1 = s_6 + 1U;
            uint _S947 = s_6 + 1U;
            settled_0 = settled_1;
            woke_1 = woke_0;
            s_6 = _S947;
            continue;
        }
        i_10 = (&isl_15)->range_0.z + tid_4;
        for(;;)
        {
            if(i_10 < ((&isl_15)->range_0.w))
            {
            }
            else
            {
                break;
            }
            bool _S958 = bond_update_0(i_10, _S938, _S939, abs_step_1, &kernelContext_50);
            if(_S958)
            {
                *(&kernelContext_50)->g_halt_0 = 1U;
            }
            i_10 = i_10 + 256U;
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
            thread Island_0 _S959 = isl_15;
            thread Rigid_0 _S960 = rg_13;
            chunk_update_1(c_20, &_S959, &_S960, _S938, _S940, k_20, contact_island_0, &work_3, &work_err_2, &kernelContext_50);
            c_20 = c_20 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        if(_S933)
        {
            thread Island_0 _S961 = isl_15;
            integrate_rigid_1(&_S961, &rg_13, _S938);
        }
        if(_S932)
        {
            float3 _S962 = (&isl_15)->wcom_0.xyz;
            float3 _S963 = float3(0.0f) ;
            thread float3 tu_1 = _S963;
            thread float3 pv_1 = _S963;
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
            thread float3 lu_1 = _S963;
            thread float3 lv_1 = _S963;
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
                drift_angular_0(c_22, _S962, tr_4, dv_4, &lu_1, &lv_1, &kernelContext_50);
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
                drift_apply_0(c_23, _S962, tr_4, phi_3, dv_4, dw_3, &kernelContext_50);
                c_23 = c_23 + 256U;
            }
            if(!driven_0)
            {
                thread Island_0 _S964 = isl_15;
                drift_rigid_1(&_S964, &rg_13, tr_4, phi_3, dv_4, dw_3);
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        }
        if(_S935)
        {
            _S943 = ((&isl_15)->probes_0.y) > ((&isl_15)->probes_0.x);
        }
        else
        {
            _S943 = false;
        }
        if(_S943)
        {
            thread Island_0 _S965 = isl_15;
            thread Rigid_0 _S966 = rg_13;
            record_probes_0(&_S965, &_S966, k_20, &kernelContext_50);
        }
        uint _S967 = s_6 + 1U;
        if((*(&kernelContext_50)->g_halt_0) != 0U)
        {
            done_1 = _S967;
            break;
        }
        done_1 = _S967;
        uint _S947 = s_6 + 1U;
        settled_0 = settled_1;
        woke_1 = woke_0;
        s_6 = _S947;
    }
    thread float3 wsum_0 = float3(work_3, work_err_2, 0.0f);
    thread float3 unused_2 = float3(0.0f) ;
    group_sum3_0(tid_4, &wsum_0, &unused_2, &kernelContext_50);
    if(_S935)
    {
        thread Quat_0 _S968 = (&rg_13)->rot_0;
        float4 _S969 = quat_vec_0(&_S968);
        (&isl_15)->rotation_0 = _S969;
        (&isl_15)->position_0 = float4((&rg_13)->pos_1, 0.0f);
        (&isl_15)->position_err_0 = float4((&rg_13)->pos_err_1, 0.0f);
        (&isl_15)->velocity_0 = float4((&rg_13)->vel_1, 0.0f);
        (&isl_15)->velocity_err_0 = float4((&rg_13)->vel_err_1, 0.0f);
        (&isl_15)->angular_velocity_0 = float4((&rg_13)->w_3, 0.0f);
        (&isl_15)->done_0.x = done_1;
        (&isl_15)->info_0.y = (&isl_15)->info_0.y - done_1;
        if((*(&kernelContext_50)->g_halt_0) != 0U)
        {
            _S933 = contact_island_0;
        }
        else
        {
            _S933 = false;
        }
        if(_S933)
        {
            contact_split_at_0((&isl_15)->info_0.w + done_1, &kernelContext_50);
        }
        float _S970 = wsum_0.x;
        thread float _S971 = (&isl_15)->energy_0.x;
        thread float _S972 = (&isl_15)->energy_0.y;
        comp_add1_0(&_S971, &_S972, _S970);
        (&isl_15)->energy_0.x = _S971;
        (&isl_15)->energy_0.y = _S972 + wsum_0.y;
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
        Island_natural_0 device* _S973 = (&kernelContext_50)->islands_0+_S909;
        _S973->range_0 = packed_uint4(isl_15.range_0) ;
        _S973->info_0 = packed_uint4(isl_15.info_0) ;
        _S973->com_0 = packed_float4(isl_15.com_0) ;
        _S973->inertia0_0 = packed_float4(isl_15.inertia0_0) ;
        _S973->inertia1_0 = packed_float4(isl_15.inertia1_0) ;
        _S973->inertia2_0 = packed_float4(isl_15.inertia2_0) ;
        _S973->inv0_0 = packed_float4(isl_15.inv0_0) ;
        _S973->inv1_0 = packed_float4(isl_15.inv1_0) ;
        _S973->inv2_0 = packed_float4(isl_15.inv2_0) ;
        _S973->wcom_0 = packed_float4(isl_15.wcom_0) ;
        _S973->winv0_0 = packed_float4(isl_15.winv0_0) ;
        _S973->winv1_0 = packed_float4(isl_15.winv1_0) ;
        _S973->winv2_0 = packed_float4(isl_15.winv2_0) ;
        _S973->rotation_0 = packed_float4(isl_15.rotation_0) ;
        _S973->position_0 = packed_float4(isl_15.position_0) ;
        _S973->position_err_0 = packed_float4(isl_15.position_err_0) ;
        _S973->velocity_0 = packed_float4(isl_15.velocity_0) ;
        _S973->velocity_err_0 = packed_float4(isl_15.velocity_err_0) ;
        _S973->angular_velocity_0 = packed_float4(isl_15.angular_velocity_0) ;
        _S973->done_0 = packed_uint4(isl_15.done_0) ;
        _S973->probes_0 = packed_uint4(isl_15.probes_0) ;
        _S973->energy_0 = packed_float4(isl_15.energy_0) ;
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
    thread WideGroup_0 w_10;
    uint _S974 = table_0 + 4U * g_2;
    (&w_10)->island_0 = kernelContext_51->index_0[_S974];
    (&w_10)->begin_1 = kernelContext_51->index_0[_S974 + 1U];
    (&w_10)->end_0 = kernelContext_51->index_0[_S974 + 2U];
    (&w_10)->first_0 = kernelContext_51->index_0[_S974 + 3U];
    return w_10;
}

bool wide_runs_0(const Island_natural_0 thread* isl_16, KernelContext_0 thread* kernelContext_52)
{
    uint4 _S975 = uint4(isl_16->info_0) ;
    bool _S976;
    if(((_S975.z) & 1U) != 0U)
    {
        _S976 = true;
    }
    else
    {
        _S976 = (_S975.y) == 0U;
    }
    if(_S976)
    {
        return false;
    }
    if(((_S975.x) & 4U) == 0U)
    {
        _S976 = true;
    }
    else
    {
        bool _S977 = contact_stopped_0(isl_16, kernelContext_52);
        _S976 = !_S977;
    }
    return _S976;
}

bool wide_enter_0(uint tid_5, const Island_natural_0 thread* isl_17, KernelContext_0 thread* kernelContext_53)
{
    if(tid_5 == 0U)
    {
        bool _S978 = wide_runs_0(isl_17, kernelContext_53);
        int _S979;
        if(_S978)
        {
            _S979 = int(1);
        }
        else
        {
            _S979 = int(0);
        }
        *kernelContext_53->g_wide_run_0 = uint(_S979);
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

bool contact_stopped_2(uint _S980, KernelContext_0 thread* kernelContext_56)
{
    Island_natural_0 device* _S981 = kernelContext_56->islands_0+_S980;
    uint4 _S982 = uint4((kernelContext_56->islands_0+kernelContext_56->params_0->halt_index_0)->info_0) ;
    bool _S983;
    if(((_S982.z) & 1U) != 0U)
    {
        _S983 = true;
    }
    else
    {
        uint _S984 = _S982.y;
        if(_S984 != 0U)
        {
            _S983 = _S984 <= ((uint4(_S981->info_0) ).w);
        }
        else
        {
            _S983 = false;
        }
    }
    return _S983;
}

bool wide_runs_1(uint _S985, KernelContext_0 thread* kernelContext_57)
{
    uint4 _S986 = uint4((kernelContext_57->islands_0+_S985)->info_0) ;
    bool _S987;
    if(((_S986.z) & 1U) != 0U)
    {
        _S987 = true;
    }
    else
    {
        _S987 = (_S986.y) == 0U;
    }
    if(_S987)
    {
        return false;
    }
    if(((_S986.x) & 4U) == 0U)
    {
        _S987 = true;
    }
    else
    {
        bool _S988 = contact_stopped_2(_S985, kernelContext_57);
        _S987 = !_S988;
    }
    return _S987;
}

bool wide_enter_1(uint _S989, uint _S990, KernelContext_0 thread* kernelContext_58)
{
    if(_S989 == 0U)
    {
        bool _S991 = wide_runs_1(_S990, kernelContext_58);
        int _S992;
        if(_S991)
        {
            _S992 = int(1);
        }
        else
        {
            _S992 = int(0);
        }
        *kernelContext_58->g_wide_run_0 = uint(_S992);
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
    threadgroup array<float4, int(256)> g_red_a_7;
    (&kernelContext_59)->g_red_a_0 = &g_red_a_7;
    threadgroup array<float4, int(256)> g_red_b_7;
    (&kernelContext_59)->g_red_b_0 = &g_red_b_7;
    threadgroup uint g_run_7;
    (&kernelContext_59)->g_run_0 = &g_run_7;
    threadgroup uint g_halt_7;
    (&kernelContext_59)->g_halt_0 = &g_halt_7;
    threadgroup uint g_wide_run_7;
    (&kernelContext_59)->g_wide_run_0 = &g_wide_run_7;
    uint tid_6 = thread_3.x;
    uint _S993 = group_3.x;
    WideGroup_0 _S994 = wide_group_0(params_7->wide_chunk_table_0, _S993, &kernelContext_59);
    if(_S993 != (_S994.first_0))
    {
        return;
    }
    thread Island_natural_0 _S995 = *((&kernelContext_59)->islands_0+_S994.island_0);
    uint4 _S996 = uint4((&_S995)->info_0) ;
    uint _S997 = _S996.x;
    bool _S998;
    if((_S997 & 16U) == 0U)
    {
        _S998 = true;
    }
    else
    {
        bool _S999 = wide_enter_1(tid_6, _S994.island_0, &kernelContext_59);
        _S998 = !_S999;
    }
    if(_S998)
    {
        return;
    }
    Quat_0 _S1000 = quat_of_0(float4((&_S995)->rotation_0) );
    bool _S1001 = (_S997 & 4U) != 0U;
    float3 _S1002 = float3(0.0f) ;
    thread float3 norm_1 = _S1002;
    thread float3 unused_3 = _S1002;
    uint4 _S1003 = uint4((&_S995)->range_0) ;
    uint c_24 = _S1003.x + tid_6;
    for(;;)
    {
        if(c_24 < (_S1003.y))
        {
        }
        else
        {
            break;
        }
        uint _S1004 = wide_step_0(&_S995, &kernelContext_59);
        float _S1005 = (&kernelContext_59)->params_0->dt_0;
        thread Quat_0 _S1006 = _S1000;
        float _S1007 = settled_chunk_load_0(c_24, &_S1006, _S1004, _S1005, _S1001, &kernelContext_59);
        norm_1.x = norm_1.x + _S1007;
        c_24 = c_24 + 256U;
    }
    group_sum3_0(tid_6, &norm_1, &unused_3, &kernelContext_59);
    if(tid_6 == 0U)
    {
        _S998 = ((&kernelContext_59)->params_0->solve_mode_0) == 1U;
    }
    else
    {
        _S998 = false;
    }
    if(_S998)
    {
        float4 _S1008 = float4((&_S995)->energy_0) ;
        _S998 = (abs(norm_1.x - _S1008.z)) > (_S1008.w);
    }
    else
    {
        _S998 = false;
    }
    if(_S998)
    {
        ((&kernelContext_59)->islands_0+_S994.island_0)->info_0[int(0)] = _S997 & 4294967279U;
        ((&kernelContext_59)->islands_0+_S994.island_0)->info_0[int(2)] = (_S996.z) | 4U;
    }
    return;
}

void wide_store_0(uint slot_2, uint p_13, float3 a_11, float3 b_28, KernelContext_0 thread* kernelContext_60)
{
    uint _S1009 = 8U * slot_2;
    *(kernelContext_60->scratch_0+(kernelContext_60->params_0->wide_base_0 + _S1009 + p_13)) = packed_float4(float4(a_11, 0.0f)) ;
    *(kernelContext_60->scratch_0+(kernelContext_60->params_0->wide_base_0 + _S1009 + p_13 + 1U)) = packed_float4(float4(b_28, 0.0f)) ;
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
    threadgroup array<float4, int(256)> g_red_a_8;
    (&kernelContext_61)->g_red_a_0 = &g_red_a_8;
    threadgroup array<float4, int(256)> g_red_b_8;
    (&kernelContext_61)->g_red_b_0 = &g_red_b_8;
    threadgroup uint g_run_8;
    (&kernelContext_61)->g_run_0 = &g_run_8;
    threadgroup uint g_halt_8;
    (&kernelContext_61)->g_halt_0 = &g_halt_8;
    threadgroup uint g_wide_run_8;
    (&kernelContext_61)->g_wide_run_0 = &g_wide_run_8;
    uint tid_7 = thread_4.x;
    uint _S1010 = group_4.x;
    bool bond_group_0 = _S1010 < (params_8->wide_bond_groups_0);
    WideGroup_0 wg_0;
    if(bond_group_0)
    {
        WideGroup_0 _S1011 = wide_group_0((&kernelContext_61)->params_0->wide_bond_table_0, _S1010, &kernelContext_61);
        wg_0 = _S1011;
    }
    else
    {
        WideGroup_0 _S1012 = wide_group_0((&kernelContext_61)->params_0->wide_chunk_table_0, _S1010 - params_8->wide_bond_groups_0, &kernelContext_61);
        wg_0 = _S1012;
    }
    WideGroup_0 _S1013 = wg_0;
    thread Island_natural_0 _S1014 = *((&kernelContext_61)->islands_0+wg_0.island_0);
    bool _S1015 = wide_enter_1(tid_7, wg_0.island_0, &kernelContext_61);
    if(!_S1015)
    {
        return;
    }
    uint _S1016 = wide_step_0(&_S1014, &kernelContext_61);
    if(bond_group_0)
    {
        uint4 _S1017 = uint4((&_S1014)->info_0) ;
        if(((_S1017.x) & 16U) != 0U)
        {
            return;
        }
        uint i_11 = wg_0.begin_1 + tid_7;
        bool _S1018;
        if(i_11 < (wg_0.end_0))
        {
            bool _S1019 = bond_update_0(i_11, (&kernelContext_61)->params_0->dt_0, ((&kernelContext_61)->params_0->fracture_0) != 0U, _S1017.w + 1U, &kernelContext_61);
            _S1018 = _S1019;
        }
        else
        {
            _S1018 = false;
        }
        if(_S1018)
        {
            ((&kernelContext_61)->islands_0+_S1013.island_0)->info_0[int(2)] = (_S1017.z) | 2U;
        }
        return;
    }
    uint _S1020 = (uint4((&_S1014)->info_0) ).x;
    if((_S1020 & 1U) != 0U)
    {
        return;
    }
    float3 _S1021 = float3(0.0f) ;
    thread float3 f_16 = _S1021;
    thread float3 t_14 = _S1021;
    uint c_25 = wg_0.begin_1 + tid_7;
    if(c_25 < (wg_0.end_0))
    {
        Rigid_0 _S1022 = rigid_of_0(&_S1014);
        float _S1023 = (&kernelContext_61)->params_0->dt_0;
        bool _S1024 = (_S1020 & 4U) != 0U;
        thread Rigid_0 _S1025 = _S1022;
        net_load_0(c_25, &_S1014, &_S1025, _S1016, _S1023, _S1024, &f_16, &t_14, &kernelContext_61);
    }
    group_sum3_0(tid_7, &f_16, &t_14, &kernelContext_61);
    if(tid_7 == 0U)
    {
        wide_store_0(_S1010 - params_8->wide_bond_groups_0, 0U, f_16, t_14, &kernelContext_61);
    }
    return;
}

void wide_partials_0(uint tid_8, uint first_1, uint count_5, uint p_14, float3 thread* a_12, float3 thread* b_29, KernelContext_0 thread* kernelContext_62)
{
    float4 _S1026 = float4(0.0f) ;
    thread float4 x_8 = _S1026;
    thread float4 y_2 = _S1026;
    uint s_7 = tid_8;
    for(;;)
    {
        if(s_7 < count_5)
        {
        }
        else
        {
            break;
        }
        uint _S1027 = 8U * (first_1 + s_7);
        x_8 = x_8 + float4(*(kernelContext_62->scratch_0+(kernelContext_62->params_0->wide_base_0 + _S1027 + p_14))) ;
        y_2 = y_2 + float4(*(kernelContext_62->scratch_0+(kernelContext_62->params_0->wide_base_0 + _S1027 + p_14 + 1U))) ;
        s_7 = s_7 + 256U;
    }
    group_sum2_0(tid_8, &x_8, &y_2, kernelContext_62);
    *a_12 = x_8.xyz;
    *b_29 = y_2.xyz;
    return;
}

Rigid_0 wide_rigid_frame_0(uint tid_9, const Island_natural_0 thread* isl_20, const WideGroup_0 thread* wg_1, KernelContext_0 thread* kernelContext_63)
{
    Rigid_0 _S1028 = rigid_of_0(isl_20);
    thread Rigid_0 rg_14 = _S1028;
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
    threadgroup array<float4, int(256)> g_red_a_9;
    (&kernelContext_64)->g_red_a_0 = &g_red_a_9;
    threadgroup array<float4, int(256)> g_red_b_9;
    (&kernelContext_64)->g_red_b_0 = &g_red_b_9;
    threadgroup uint g_run_9;
    (&kernelContext_64)->g_run_0 = &g_run_9;
    threadgroup uint g_halt_9;
    (&kernelContext_64)->g_halt_0 = &g_halt_9;
    threadgroup uint g_wide_run_9;
    (&kernelContext_64)->g_wide_run_0 = &g_wide_run_9;
    uint tid_10 = thread_5.x;
    uint _S1029 = group_5.x;
    WideGroup_0 _S1030 = wide_group_0(params_9->wide_chunk_table_0, _S1029, &kernelContext_64);
    thread Island_natural_0 _S1031 = *((&kernelContext_64)->islands_0+_S1030.island_0);
    bool _S1032 = wide_enter_1(tid_10, _S1030.island_0, &kernelContext_64);
    if(!_S1032)
    {
        return;
    }
    uint _S1033 = (uint4((&_S1031)->info_0) ).x;
    bool anchored_0 = (_S1033 & 1U) != 0U;
    if((_S1033 & 16U) != 0U)
    {
        if(tid_10 == 0U)
        {
            *((&kernelContext_64)->scratch_0+((&kernelContext_64)->params_0->wide_base_0 + 8U * _S1029 + 6U)) = packed_float4(float4(0.0f) ) ;
        }
        return;
    }
    thread WideGroup_0 _S1034 = _S1030;
    Rigid_0 _S1035 = wide_rigid_frame_0(tid_10, &_S1031, &_S1034, &kernelContext_64);
    thread float work_4 = 0.0f;
    thread float work_err_3 = 0.0f;
    float3 _S1036 = float3(0.0f) ;
    thread float3 tu_2 = _S1036;
    thread float3 pv_2 = _S1036;
    uint c_26 = _S1030.begin_1 + tid_10;
    if(c_26 < (_S1030.end_0))
    {
        float _S1037 = (&kernelContext_64)->params_0->dt_0;
        bool _S1038 = ((&kernelContext_64)->params_0->rigid_motion_loads_0) != 0U;
        uint _S1039 = wide_step_0(&_S1031, &kernelContext_64);
        bool _S1040 = (_S1033 & 4U) != 0U;
        thread Rigid_0 _S1041 = _S1035;
        chunk_update_0(c_26, &_S1031, &_S1041, _S1037, _S1038, _S1039, _S1040, &work_4, &work_err_3, &kernelContext_64);
        if(!anchored_0)
        {
            drift_moments_0(c_26, &tu_2, &pv_2, &kernelContext_64);
        }
    }
    thread float3 wsum_1 = float3(work_4, work_err_3, 0.0f);
    thread float3 unused_4 = _S1036;
    group_sum3_0(tid_10, &wsum_1, &unused_4, &kernelContext_64);
    bool _S1042 = !anchored_0;
    if(_S1042)
    {
        group_sum3_0(tid_10, &tu_2, &pv_2, &kernelContext_64);
    }
    if(tid_10 == 0U)
    {
        *((&kernelContext_64)->scratch_0+((&kernelContext_64)->params_0->wide_base_0 + 8U * _S1029 + 6U)) = packed_float4(float4(wsum_1, 0.0f)) ;
        if(_S1042)
        {
            wide_store_0(_S1029, 2U, tu_2, pv_2, &kernelContext_64);
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
    threadgroup array<float4, int(256)> g_red_a_10;
    (&kernelContext_65)->g_red_a_0 = &g_red_a_10;
    threadgroup array<float4, int(256)> g_red_b_10;
    (&kernelContext_65)->g_red_b_0 = &g_red_b_10;
    threadgroup uint g_run_10;
    (&kernelContext_65)->g_run_0 = &g_run_10;
    threadgroup uint g_halt_10;
    (&kernelContext_65)->g_halt_0 = &g_halt_10;
    threadgroup uint g_wide_run_10;
    (&kernelContext_65)->g_wide_run_0 = &g_wide_run_10;
    uint tid_11 = thread_6.x;
    uint _S1043 = group_6.x;
    WideGroup_0 _S1044 = wide_group_0(params_10->wide_chunk_table_0, _S1043, &kernelContext_65);
    Island_natural_0 device* _S1045 = (&kernelContext_65)->islands_0+_S1044.island_0;
    Island_natural_0 isl_21 = *_S1045;
    bool _S1046;
    if((((uint4((*_S1045).info_0) ).x) & 17U) != 0U)
    {
        _S1046 = true;
    }
    else
    {
        bool _S1047 = wide_enter_1(tid_11, _S1044.island_0, &kernelContext_65);
        _S1046 = !_S1047;
    }
    if(_S1046)
    {
        return;
    }
    thread float3 tu_3;
    thread float3 pv_3;
    wide_partials_0(tid_11, _S1044.first_0, (uint4(isl_21.done_0) ).z, 2U, &tu_3, &pv_3, &kernelContext_65);
    float4 _S1048 = float4(isl_21.wcom_0) ;
    float3 _S1049 = float3(_S1048.w) ;
    float3 tr_5 = tu_3 / _S1049;
    float3 dv_5 = pv_3 / _S1049;
    float3 _S1050 = float3(0.0f) ;
    thread float3 lu_2 = _S1050;
    thread float3 lv_2 = _S1050;
    uint c_27 = _S1044.begin_1 + tid_11;
    if(c_27 < (_S1044.end_0))
    {
        drift_angular_0(c_27, _S1048.xyz, tr_5, dv_5, &lu_2, &lv_2, &kernelContext_65);
    }
    group_sum3_0(tid_11, &lu_2, &lv_2, &kernelContext_65);
    if(tid_11 == 0U)
    {
        wide_store_0(_S1043, 4U, lu_2, lv_2, &kernelContext_65);
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
    threadgroup array<float4, int(256)> g_red_a_11;
    (&kernelContext_66)->g_red_a_0 = &g_red_a_11;
    threadgroup array<float4, int(256)> g_red_b_11;
    (&kernelContext_66)->g_red_b_0 = &g_red_b_11;
    threadgroup uint g_run_11;
    (&kernelContext_66)->g_run_0 = &g_run_11;
    threadgroup uint g_halt_11;
    (&kernelContext_66)->g_halt_0 = &g_halt_11;
    threadgroup uint g_wide_run_11;
    (&kernelContext_66)->g_wide_run_0 = &g_wide_run_11;
    uint tid_12 = thread_7.x;
    uint _S1051 = group_7.x;
    WideGroup_0 _S1052 = wide_group_0(params_11->wide_chunk_table_0, _S1051, &kernelContext_66);
    thread Island_natural_0 _S1053 = *((&kernelContext_66)->islands_0+_S1052.island_0);
    uint _S1054 = (uint4((&_S1053)->info_0) ).x;
    bool _S1055;
    if((_S1054 & 1U) != 0U)
    {
        _S1055 = true;
    }
    else
    {
        bool _S1056 = wide_enter_1(tid_12, _S1052.island_0, &kernelContext_66);
        _S1055 = !_S1056;
    }
    if(_S1055)
    {
        return;
    }
    if((_S1054 & 16U) != 0U)
    {
        if(_S1051 != (_S1052.first_0))
        {
            return;
        }
        thread WideGroup_0 _S1057 = _S1052;
        Rigid_0 _S1058 = wide_rigid_frame_0(tid_12, &_S1053, &_S1057, &kernelContext_66);
        thread Rigid_0 rs_0 = _S1058;
        if(tid_12 != 0U)
        {
            _S1055 = true;
        }
        else
        {
            _S1055 = (_S1054 & 2U) != 0U;
        }
        if(_S1055)
        {
            return;
        }
        integrate_rigid_0(&_S1053, &rs_0, (&kernelContext_66)->params_0->dt_0);
        thread Quat_0 _S1059 = (&rs_0)->rot_0;
        float4 _S1060 = quat_vec_0(&_S1059);
        ((&kernelContext_66)->islands_0+_S1052.island_0)->rotation_0 = packed_float4(_S1060) ;
        ((&kernelContext_66)->islands_0+_S1052.island_0)->position_0 = packed_float4(float4((&rs_0)->pos_1, 0.0f)) ;
        ((&kernelContext_66)->islands_0+_S1052.island_0)->position_err_0 = packed_float4(float4((&rs_0)->pos_err_1, 0.0f)) ;
        ((&kernelContext_66)->islands_0+_S1052.island_0)->velocity_0 = packed_float4(float4((&rs_0)->vel_1, 0.0f)) ;
        ((&kernelContext_66)->islands_0+_S1052.island_0)->velocity_err_0 = packed_float4(float4((&rs_0)->vel_err_1, 0.0f)) ;
        ((&kernelContext_66)->islands_0+_S1052.island_0)->angular_velocity_0 = packed_float4(float4((&rs_0)->w_3, 0.0f)) ;
        return;
    }
    uint _S1061 = (uint4((&_S1053)->done_0) ).z;
    thread float3 tu_4;
    thread float3 pv_4;
    wide_partials_0(tid_12, _S1052.first_0, _S1061, 2U, &tu_4, &pv_4, &kernelContext_66);
    thread float3 lu_3;
    thread float3 lv_3;
    wide_partials_0(tid_12, _S1052.first_0, _S1061, 4U, &lu_3, &lv_3, &kernelContext_66);
    float4 _S1062 = float4((&_S1053)->wcom_0) ;
    float3 _S1063 = float3(_S1062.w) ;
    float3 tr_6 = tu_4 / _S1063;
    float3 dv_6 = pv_4 / _S1063;
    float4 _S1064 = float4((&_S1053)->winv0_0) ;
    float4 _S1065 = float4((&_S1053)->winv1_0) ;
    float4 _S1066 = float4((&_S1053)->winv2_0) ;
    float3 phi_4 = rows_mul_0(_S1064, _S1065, _S1066, lu_3);
    float3 dw_4 = rows_mul_0(_S1064, _S1065, _S1066, lv_3);
    uint c_28 = _S1052.begin_1 + tid_12;
    if(c_28 < (_S1052.end_0))
    {
        drift_apply_0(c_28, _S1062.xyz, tr_6, phi_4, dv_6, dw_4, &kernelContext_66);
    }
    if(_S1051 != (_S1052.first_0))
    {
        return;
    }
    thread WideGroup_0 _S1067 = _S1052;
    Rigid_0 _S1068 = wide_rigid_frame_0(tid_12, &_S1053, &_S1067, &kernelContext_66);
    thread Rigid_0 rg_15 = _S1068;
    if(tid_12 != 0U)
    {
        return;
    }
    if(!((_S1054 & 2U) != 0U))
    {
        integrate_rigid_0(&_S1053, &rg_15, (&kernelContext_66)->params_0->dt_0);
        drift_rigid_0(&_S1053, &rg_15, tr_6, phi_4, dv_6, dw_4);
    }
    thread Quat_0 _S1069 = (&rg_15)->rot_0;
    float4 _S1070 = quat_vec_0(&_S1069);
    ((&kernelContext_66)->islands_0+_S1052.island_0)->rotation_0 = packed_float4(_S1070) ;
    ((&kernelContext_66)->islands_0+_S1052.island_0)->position_0 = packed_float4(float4((&rg_15)->pos_1, 0.0f)) ;
    ((&kernelContext_66)->islands_0+_S1052.island_0)->position_err_0 = packed_float4(float4((&rg_15)->pos_err_1, 0.0f)) ;
    ((&kernelContext_66)->islands_0+_S1052.island_0)->velocity_0 = packed_float4(float4((&rg_15)->vel_1, 0.0f)) ;
    ((&kernelContext_66)->islands_0+_S1052.island_0)->velocity_err_0 = packed_float4(float4((&rg_15)->vel_err_1, 0.0f)) ;
    ((&kernelContext_66)->islands_0+_S1052.island_0)->angular_velocity_0 = packed_float4(float4((&rg_15)->w_3, 0.0f)) ;
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
    threadgroup array<float4, int(256)> g_red_a_12;
    (&kernelContext_67)->g_red_a_0 = &g_red_a_12;
    threadgroup array<float4, int(256)> g_red_b_12;
    (&kernelContext_67)->g_red_b_0 = &g_red_b_12;
    threadgroup uint g_run_12;
    (&kernelContext_67)->g_run_0 = &g_run_12;
    threadgroup uint g_halt_12;
    (&kernelContext_67)->g_halt_0 = &g_halt_12;
    threadgroup uint g_wide_run_12;
    (&kernelContext_67)->g_wide_run_0 = &g_wide_run_12;
    uint tid_13 = thread_8.x;
    uint _S1071 = group_8.x;
    WideGroup_0 _S1072 = wide_group_0(params_12->wide_chunk_table_0, _S1071, &kernelContext_67);
    if(_S1071 != (_S1072.first_0))
    {
        return;
    }
    Island_natural_0 device* _S1073 = (&kernelContext_67)->islands_0+_S1072.island_0;
    thread Island_natural_0 _S1074 = *_S1073;
    uint4 _S1075 = uint4((&_S1074)->info_0) ;
    float4 _S1076 = float4((&_S1074)->com_0) ;
    float4 _S1077 = float4((&_S1074)->inertia0_0) ;
    float4 _S1078 = float4((&_S1074)->inertia1_0) ;
    float4 _S1079 = float4((&_S1074)->inertia2_0) ;
    float4 _S1080 = float4((&_S1074)->inv0_0) ;
    float4 _S1081 = float4((&_S1074)->inv1_0) ;
    float4 _S1082 = float4((&_S1074)->inv2_0) ;
    float4 _S1083 = float4((&_S1074)->wcom_0) ;
    float4 _S1084 = float4((&_S1074)->winv0_0) ;
    float4 _S1085 = float4((&_S1074)->winv1_0) ;
    float4 _S1086 = float4((&_S1074)->winv2_0) ;
    float4 _S1087 = float4((&_S1074)->rotation_0) ;
    float4 _S1088 = float4((&_S1074)->position_0) ;
    float4 _S1089 = float4((&_S1074)->position_err_0) ;
    float4 _S1090 = float4((&_S1074)->velocity_0) ;
    float4 _S1091 = float4((&_S1074)->velocity_err_0) ;
    float4 _S1092 = float4((&_S1074)->angular_velocity_0) ;
    uint4 _S1093 = uint4((&_S1074)->done_0) ;
    uint4 _S1094 = uint4((&_S1074)->probes_0) ;
    float4 _S1095 = float4((&_S1074)->energy_0) ;
    thread Island_0 isl_22;
    (&isl_22)->range_0 = uint4((&_S1074)->range_0) ;
    (&isl_22)->info_0 = _S1075;
    (&isl_22)->com_0 = _S1076;
    (&isl_22)->inertia0_0 = _S1077;
    (&isl_22)->inertia1_0 = _S1078;
    (&isl_22)->inertia2_0 = _S1079;
    (&isl_22)->inv0_0 = _S1080;
    (&isl_22)->inv1_0 = _S1081;
    (&isl_22)->inv2_0 = _S1082;
    (&isl_22)->wcom_0 = _S1083;
    (&isl_22)->winv0_0 = _S1084;
    (&isl_22)->winv1_0 = _S1085;
    (&isl_22)->winv2_0 = _S1086;
    (&isl_22)->rotation_0 = _S1087;
    (&isl_22)->position_0 = _S1088;
    (&isl_22)->position_err_0 = _S1089;
    (&isl_22)->velocity_0 = _S1090;
    (&isl_22)->velocity_err_0 = _S1091;
    (&isl_22)->angular_velocity_0 = _S1092;
    (&isl_22)->done_0 = _S1093;
    (&isl_22)->probes_0 = _S1094;
    (&isl_22)->energy_0 = _S1095;
    _S1074 = *_S1073;
    bool _S1096 = wide_enter_0(tid_13, &_S1074, &kernelContext_67);
    if(!_S1096)
    {
        return;
    }
    thread float3 work_5;
    thread float3 unused_5;
    wide_partials_0(tid_13, _S1072.first_0, (&isl_22)->done_0.z, 6U, &work_5, &unused_5, &kernelContext_67);
    if(tid_13 != 0U)
    {
        return;
    }
    thread Island_0 _S1097 = isl_22;
    uint _S1098 = wide_step_1(&_S1097, &kernelContext_67);
    if(((&isl_22)->probes_0.y) > ((&isl_22)->probes_0.x))
    {
        thread Island_0 _S1099 = isl_22;
        Rigid_0 _S1100 = rigid_of_1(&_S1099);
        thread Island_0 _S1101 = isl_22;
        thread Rigid_0 _S1102 = _S1100;
        record_probes_0(&_S1101, &_S1102, _S1098, &kernelContext_67);
    }
    bool halt_0 = (((&isl_22)->info_0.z) & 2U) != 0U;
    bool _S1103;
    if(halt_0)
    {
        _S1103 = (((&isl_22)->info_0.x) & 4U) != 0U;
    }
    else
    {
        _S1103 = false;
    }
    if(_S1103)
    {
        contact_split_at_0((&isl_22)->info_0.w + 1U, &kernelContext_67);
    }
    float _S1104 = work_5.x;
    thread float _S1105 = (&isl_22)->energy_0.x;
    thread float _S1106 = (&isl_22)->energy_0.y;
    comp_add1_0(&_S1105, &_S1106, _S1104);
    (&isl_22)->energy_0.x = _S1105;
    (&isl_22)->energy_0.y = _S1106 + work_5.y;
    (&isl_22)->done_0.x = (&isl_22)->done_0.x + 1U;
    (&isl_22)->info_0.y = (&isl_22)->info_0.y - 1U;
    (&isl_22)->info_0.w = (&isl_22)->info_0.w + 1U;
    if(halt_0)
    {
        (&isl_22)->info_0.z = (((&isl_22)->info_0.z) & 4294967293U) | 1U;
    }
    Island_natural_0 device* _S1107 = (&kernelContext_67)->islands_0+_S1072.island_0;
    _S1107->range_0 = packed_uint4(isl_22.range_0) ;
    _S1107->info_0 = packed_uint4(isl_22.info_0) ;
    _S1107->com_0 = packed_float4(isl_22.com_0) ;
    _S1107->inertia0_0 = packed_float4(isl_22.inertia0_0) ;
    _S1107->inertia1_0 = packed_float4(isl_22.inertia1_0) ;
    _S1107->inertia2_0 = packed_float4(isl_22.inertia2_0) ;
    _S1107->inv0_0 = packed_float4(isl_22.inv0_0) ;
    _S1107->inv1_0 = packed_float4(isl_22.inv1_0) ;
    _S1107->inv2_0 = packed_float4(isl_22.inv2_0) ;
    _S1107->wcom_0 = packed_float4(isl_22.wcom_0) ;
    _S1107->winv0_0 = packed_float4(isl_22.winv0_0) ;
    _S1107->winv1_0 = packed_float4(isl_22.winv1_0) ;
    _S1107->winv2_0 = packed_float4(isl_22.winv2_0) ;
    _S1107->rotation_0 = packed_float4(isl_22.rotation_0) ;
    _S1107->position_0 = packed_float4(isl_22.position_0) ;
    _S1107->position_err_0 = packed_float4(isl_22.position_err_0) ;
    _S1107->velocity_0 = packed_float4(isl_22.velocity_0) ;
    _S1107->velocity_err_0 = packed_float4(isl_22.velocity_err_0) ;
    _S1107->angular_velocity_0 = packed_float4(isl_22.angular_velocity_0) ;
    _S1107->done_0 = packed_uint4(isl_22.done_0) ;
    _S1107->probes_0 = packed_uint4(isl_22.probes_0) ;
    _S1107->energy_0 = packed_float4(isl_22.energy_0) ;
    return;
}

uint sv_0(uint c_29, uint slot_3, KernelContext_0 thread* kernelContext_68)
{
    return kernelContext_68->params_0->statics_base_0 + 23U * c_29 + slot_3;
}

void project_load_slot_0(uint tid_14, const Island_natural_0 thread* isl_23, uint slot_4, KernelContext_0 thread* kernelContext_69)
{
    uint _S1108;
    float3 _S1109 = float3(0.0f) ;
    thread float3 net_f_0 = _S1109;
    thread float3 net_m_0 = _S1109;
    uint4 _S1110 = uint4(isl_23->range_0) ;
    uint _S1111 = _S1110.x + tid_14;
    uint c_30 = _S1111;
    for(;;)
    {
        uint _S1112 = _S1110.y;
        _S1108 = _S1112;
        if(c_30 < _S1112)
        {
        }
        else
        {
            break;
        }
        uint _S1113 = sv_0(c_30, slot_4, kernelContext_69);
        float3 fi_2 = (float4(*(kernelContext_69->scratch_0+_S1113)) ).xyz;
        net_f_0 = net_f_0 + fi_2;
        float3 _S1114 = cross((float4((kernelContext_69->chunks_0+c_30)->center_0) ).xyz - (float4(isl_23->com_0) ).xyz, fi_2);
        uint _S1115 = sv_0(c_30, slot_4 + 1U, kernelContext_69);
        net_m_0 = net_m_0 + (_S1114 + (float4(*(kernelContext_69->scratch_0+_S1115)) ).xyz);
        c_30 = c_30 + 256U;
    }
    group_sum3_0(tid_14, &net_f_0, &net_m_0, kernelContext_69);
    float4 _S1116 = float4(isl_23->com_0) ;
    float3 _S1117 = net_f_0 / float3(_S1116.w) ;
    float3 _S1118 = rows_mul_0(float4(isl_23->inv0_0) , float4(isl_23->inv1_0) , float4(isl_23->inv2_0) , net_m_0);
    c_30 = _S1111;
    for(;;)
    {
        if(c_30 < _S1108)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_natural_0 device* _S1119 = kernelContext_69->chunks_0+c_30;
        float4 _S1120 = float4(_S1119->center_0) ;
        float3 r_13 = _S1120.xyz - _S1116.xyz;
        uint _S1121 = sv_0(c_30, slot_4, kernelContext_69);
        *(kernelContext_69->scratch_0+_S1121) = packed_float4(float4((float4(*(kernelContext_69->scratch_0+_S1121)) ).xyz - (_S1117 + cross(_S1118, r_13)) * float3(_S1120.w) , 0.0f)) ;
        uint _S1122 = sv_0(c_30, slot_4 + 1U, kernelContext_69);
        *(kernelContext_69->scratch_0+_S1122) = packed_float4(float4((float4(*(kernelContext_69->scratch_0+_S1122)) ).xyz - rows_mul_0(float4(_S1119->inertia0_1) , float4(_S1119->inertia1_1) , float4(_S1119->inertia2_1) , _S1118), 0.0f)) ;
        c_30 = c_30 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    return;
}

float island_dot_0(uint tid_15, uint c0_0, uint c1_0, uint sa_0, uint sb_0, KernelContext_0 thread* kernelContext_70)
{
    float4 _S1123 = float4(0.0f) ;
    thread float4 acc_0 = _S1123;
    thread float4 unused_6 = _S1123;
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
        uint _S1124 = sv_0(c_31, sa_0, kernelContext_70);
        float3 _S1125 = (float4(*(kernelContext_70->scratch_0+_S1124)) ).xyz;
        uint _S1126 = sv_0(c_31, sb_0, kernelContext_70);
        float _S1127 = dot(_S1125, (float4(*(kernelContext_70->scratch_0+_S1126)) ).xyz);
        uint _S1128 = sv_0(c_31, sa_0 + 1U, kernelContext_70);
        float3 _S1129 = (float4(*(kernelContext_70->scratch_0+_S1128)) ).xyz;
        uint _S1130 = sv_0(c_31, sb_0 + 1U, kernelContext_70);
        acc_0.x = acc_0.x + (_S1127 + dot(_S1129, (float4(*(kernelContext_70->scratch_0+_S1130)) ).xyz));
        c_31 = c_31 + 256U;
    }
    group_sum2_0(tid_15, &acc_0, &unused_6, kernelContext_70);
    return acc_0.x;
}

void static_kinematics_0(uint _S1131, float3 thread* _S1132, float3 thread* _S1133, KernelContext_0 thread* kernelContext_71)
{
    BondStatic_natural_0 device* _S1134 = kernelContext_71->bonds_0+_S1131;
    uint4 _S1135 = uint4(_S1134->law_0.ids_0) ;
    uint ca_1 = _S1135.y;
    uint cb_1 = _S1135.z;
    uint _S1136 = 4U * cb_1;
    uint _S1137 = 4U * ca_1;
    float3 _S1138 = (float4(*(kernelContext_71->state_0+_S1136)) ).xyz - (float4(*(kernelContext_71->state_0+_S1137)) ).xyz;
    uint _S1139 = sv_0(cb_1, 21U, kernelContext_71);
    float3 _S1140 = (float4(*(kernelContext_71->scratch_0+_S1139)) ).xyz;
    uint _S1141 = sv_0(ca_1, 21U, kernelContext_71);
    float3 du_0 = _S1138 + (_S1140 - (float4(*(kernelContext_71->scratch_0+_S1141)) ).xyz);
    uint _S1142 = _S1136 + 1U;
    uint _S1143 = _S1137 + 1U;
    float3 _S1144 = (float4(*(kernelContext_71->state_0+_S1142)) ).xyz - (float4(*(kernelContext_71->state_0+_S1143)) ).xyz;
    uint _S1145 = sv_0(cb_1, 22U, kernelContext_71);
    float3 _S1146 = (float4(*(kernelContext_71->scratch_0+_S1145)) ).xyz;
    uint _S1147 = sv_0(ca_1, 22U, kernelContext_71);
    float3 dth_0 = _S1144 + (_S1146 - (float4(*(kernelContext_71->scratch_0+_S1147)) ).xyz);
    float3 _S1148 = to_local_0(_S1131, du_0 + (cross((float4(*(kernelContext_71->state_0+_S1142)) ).xyz + (float4(*(kernelContext_71->scratch_0+_S1145)) ).xyz, (float4(_S1134->rb_0) ).xyz) - cross((float4(*(kernelContext_71->state_0+_S1143)) ).xyz + (float4(*(kernelContext_71->scratch_0+_S1147)) ).xyz, (float4(_S1134->ra_0) ).xyz)), kernelContext_71);
    *_S1132 = _S1148;
    float3 _S1149 = to_local_0(_S1131, dth_0, kernelContext_71);
    *_S1133 = _S1149;
    return;
}

JointResponse_0 static_response_0(uint i_12, KernelContext_0 thread* kernelContext_72)
{
    BondStatic_natural_0 device* _S1150 = kernelContext_72->bonds_0+i_12;
    thread float3 d_lin_3;
    thread float3 d_ang_2;
    static_kinematics_0(i_12, &d_lin_3, &d_ang_2, kernelContext_72);
    thread JointBond_natural_0 _S1151 = _S1150->law_0;
    _S1151 = _S1150->law_0;
    thread JointState_0 _S1152 = (kernelContext_72->bond_dyn_0+i_12)->js_0;
    JointResponse_0 _S1153 = joint_evaluate_0(&kernelContext_72->materials_0->m_0[(uint4((&_S1151)->ids_0) ).x], &_S1151, &_S1152, d_lin_3, d_ang_2, 0.0f, false);
    return _S1153;
}

void gather_loads_0(uint c_32, float3 thread* fi_3, float3 thread* mi_6, KernelContext_0 thread* kernelContext_73)
{
    float3 _S1154 = float3(0.0f) ;
    *fi_3 = _S1154;
    *mi_6 = _S1154;
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
            uint _S1155 = 3U * bond_0;
            *fi_3 = *fi_3 + (float4(*(kernelContext_73->scratch_0+_S1155)) ).xyz;
            *mi_6 = *mi_6 + (float4(*(kernelContext_73->scratch_0+(_S1155 + 1U))) ).xyz;
        }
        else
        {
            uint _S1156 = 3U * bond_0;
            *fi_3 = *fi_3 - (float4(*(kernelContext_73->scratch_0+_S1156)) ).xyz;
            *mi_6 = *mi_6 + (float4(*(kernelContext_73->scratch_0+(_S1156 + 2U))) ).xyz;
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
        uint _S1157 = 3U * (entry_5 >> 1U);
        float3 f_18 = (float4(*(kernelContext_74->scratch_0+_S1157)) ).xyz;
        float3 t_16;
        if((entry_5 & 1U) == 0U)
        {
            t_16 = (float4(*(kernelContext_74->scratch_0+(_S1157 + 1U))) ).xyz;
        }
        else
        {
            t_16 = (float4(*(kernelContext_74->scratch_0+(_S1157 + 2U))) ).xyz;
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
    uint _S1158;
    if(support_2 == 1U)
    {
        _S1158 = 63U;
    }
    else
    {
        if(support_2 == 2U)
        {
            _S1158 = 7U;
        }
        else
        {
            _S1158 = 0U;
        }
    }
    return _S1158;
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

uint statics_bond_slot_0(uint i_13, KernelContext_0 thread* kernelContext_76)
{
    return kernelContext_76->params_0->statics_base_0 + 23U * kernelContext_76->params_0->chunk_count_0 + 2U * i_13;
}

void store_inverse_0(uint c_35, const array<float, int(36)> thread* a_13, KernelContext_0 thread* kernelContext_77)
{
    uint j_6;
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
    uint i_14 = 0U;
    for(;;)
    {
        bool _S1159;
        if(i_14 < 6U)
        {
            _S1159 = spd_0;
        }
        else
        {
            _S1159 = false;
        }
        if(_S1159)
        {
        }
        else
        {
            break;
        }
        j_6 = 0U;
        for(;;)
        {
            if(j_6 <= i_14)
            {
            }
            else
            {
                break;
            }
            uint _S1160 = i_14 * 6U;
            uint _S1161 = _S1160 + j_6;
            k_21 = 0U;
            sum_2 = (*a_13)[_S1161];
            for(;;)
            {
                if(k_21 < j_6)
                {
                }
                else
                {
                    break;
                }
                float sum_3 = sum_2 - l_4[_S1160 + k_21] * l_4[j_6 * 6U + k_21];
                k_21 = k_21 + 1U;
                sum_2 = sum_3;
            }
            if(i_14 == j_6)
            {
                if(sum_2 <= 0.0f)
                {
                    spd_0 = false;
                    break;
                }
                l_4[_S1160 + i_14] = sqrt(sum_2);
            }
            else
            {
                l_4[_S1161] = sum_2 / l_4[j_6 * 6U + j_6];
            }
            j_6 = j_6 + 1U;
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
            uint _S1162 = k_21 * 6U + k_21;
            float _S1163 = (*a_13)[_S1162];
            if(((*a_13)[_S1162]) > 0.0f)
            {
                sum_2 = 1.0f / _S1163;
            }
            else
            {
                sum_2 = 0.0f;
            }
            inv_0[_S1162] = sum_2;
            k_21 = k_21 + 1U;
        }
    }
    else
    {
        j_6 = 0U;
        for(;;)
        {
            if(j_6 < 6U)
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
                if(i_14 == j_6)
                {
                    sum_2 = 1.0f;
                }
                else
                {
                    sum_2 = 0.0f;
                }
                k_21 = 0U;
                float s_8 = sum_2;
                for(;;)
                {
                    if(k_21 < i_14)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_9 = s_8 - l_4[i_14 * 6U + k_21] * y_3[k_21];
                    k_21 = k_21 + 1U;
                    s_8 = s_9;
                }
                y_3[i_14] = s_8 / l_4[i_14 * 6U + i_14];
                i_14 = i_14 + 1U;
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
                uint i_15 = 5U - ii_2;
                k_21 = i_15 + 1U;
                sum_2 = y_3[i_15];
                for(;;)
                {
                    if(k_21 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_10 = sum_2 - l_4[k_21 * 6U + i_15] * x_9[k_21];
                    k_21 = k_21 + 1U;
                    sum_2 = s_10;
                }
                x_9[i_15] = sum_2 / l_4[i_15 * 6U + i_15];
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
                inv_0[i_16 * 6U + j_6] = x_9[i_16];
                i_16 = i_16 + 1U;
            }
            j_6 = j_6 + 1U;
        }
    }
    j_6 = 0U;
    for(;;)
    {
        if(j_6 < 9U)
        {
        }
        else
        {
            break;
        }
        uint _S1164 = sv_0(c_35, 12U + j_6, kernelContext_77);
        uint _S1165 = 4U * j_6;
        *(kernelContext_77->scratch_0+_S1164) = packed_float4(float4(inv_0[_S1165], inv_0[_S1165 + 1U], inv_0[_S1165 + 2U], inv_0[_S1165 + 3U])) ;
        j_6 = j_6 + 1U;
    }
    return;
}

void assemble_block_0(uint c_36, KernelContext_0 thread* kernelContext_78)
{
    uint p_15;
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
        uint i_17 = entry_6 >> 1U;
        bool _S1166 = (entry_6 & 1U) != 0U;
        BondStatic_natural_0 device* _S1167 = kernelContext_78->bonds_0+i_17;
        uint _S1168 = statics_bond_slot_0(i_17, kernelContext_78);
        float4 _S1169 = float4(*(kernelContext_78->scratch_0+_S1168)) ;
        float4 _S1170 = float4(*(kernelContext_78->scratch_0+(_S1168 + 1U))) ;
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
            uint _S1171 = p_15 % 3U;
            float3 t_17;
            if(_S1171 == 0U)
            {
                t_17 = (float4(_S1167->t1_0) ).xyz;
            }
            else
            {
                if(_S1171 == 1U)
                {
                    t_17 = (float4(_S1167->t2_0) ).xyz;
                }
                else
                {
                    t_17 = (float4(_S1167->normal_0) ).xyz;
                }
            }
            bool _S1172 = p_15 < 3U;
            float3 row_u_0;
            float3 row_t_0;
            if(_S1172)
            {
                if(_S1166)
                {
                    row_u_0 = t_17;
                }
                else
                {
                    row_u_0 = - t_17;
                }
                if(_S1166)
                {
                    row_t_0 = cross((float4(_S1167->rb_0) ).xyz, t_17);
                }
                else
                {
                    row_t_0 = - cross((float4(_S1167->ra_0) ).xyz, t_17);
                }
            }
            else
            {
                float3 _S1173 = float3(0.0f) ;
                if(_S1166)
                {
                    row_u_0 = t_17;
                }
                else
                {
                    row_u_0 = - t_17;
                }
                float3 _S1174 = row_u_0;
                row_u_0 = _S1173;
                row_t_0 = _S1174;
            }
            float kp_0;
            if(_S1172)
            {
                kp_0 = _S1169[p_15];
            }
            else
            {
                kp_0 = _S1170[p_15 - 3U];
            }
            if(kp_0 == 0.0f)
            {
                p_15 = p_15 + 1U;
                continue;
            }
            array<float, int(6)> _S1175 = { { row_u_0.x, row_u_0.y, row_u_0.z, row_t_0.x, row_t_0.y, row_t_0.z } };
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
                    a_14[r_14 * 6U + q_17] = a_14[r_14 * 6U + q_17] + kp_0 * _S1175[r_14] * _S1175[q_17];
                    q_17 = q_17 + 1U;
                }
                r_14 = r_14 + 1U;
            }
            p_15 = p_15 + 1U;
        }
        e_7 = e_7 + 1U;
    }
    uint _S1176 = fixed_mask_0(c_36, kernelContext_78);
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
        if((_S1176 & (1U << p_15)) != 0U)
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
                a_14[p_15 * 6U + r_14] = 0.0f;
                a_14[r_14 * 6U + p_15] = 0.0f;
                r_14 = r_14 + 1U;
            }
            a_14[p_15 * 6U + p_15] = 1.0f;
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
        if((a_14[p_15 * 6U + p_15]) == 0.0f)
        {
            a_14[p_15 * 6U + p_15] = 1.0f;
        }
        p_15 = p_15 + 1U;
    }
    thread array<float, int(36)> _S1177 = a_14;
    store_inverse_0(c_36, &_S1177, kernelContext_78);
    return;
}

float block_get_0(uint c_37, uint i_18, uint j_7, KernelContext_0 thread* kernelContext_79)
{
    uint k_23 = i_18 * 6U + j_7;
    uint _S1178 = sv_0(c_37, 12U + k_23 / 4U, kernelContext_79);
    return (*(kernelContext_79->scratch_0+_S1178))[k_23 % 4U];
}

void precondition_0(uint c_38, KernelContext_0 thread* kernelContext_80)
{
    uint _S1179 = sv_0(c_38, 4U, kernelContext_80);
    float4 _S1180 = float4(*(kernelContext_80->scratch_0+_S1179)) ;
    uint _S1181 = sv_0(c_38, 5U, kernelContext_80);
    float4 _S1182 = float4(*(kernelContext_80->scratch_0+_S1181)) ;
    array<float, int(6)> _S1183 = { { _S1180.x, _S1180.y, _S1180.z, _S1182.x, _S1182.y, _S1182.z } };
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
        uint j_8 = 0U;
        float s_11 = 0.0f;
        for(;;)
        {
            if(j_8 < 6U)
            {
            }
            else
            {
                break;
            }
            float _S1184 = block_get_0(c_38, i_19, j_8, kernelContext_80);
            float s_12 = s_11 + _S1184 * _S1183[j_8];
            j_8 = j_8 + 1U;
            s_11 = s_12;
        }
        z_1[i_19] = s_11;
        i_19 = i_19 + 1U;
    }
    uint _S1185 = sv_0(c_38, 6U, kernelContext_80);
    *(kernelContext_80->scratch_0+_S1185) = packed_float4(float4(z_1[int(0)], z_1[int(1)], z_1[int(2)], 0.0f)) ;
    uint _S1186 = sv_0(c_38, 7U, kernelContext_80);
    *(kernelContext_80->scratch_0+_S1186) = packed_float4(float4(z_1[int(3)], z_1[int(4)], z_1[int(5)], 0.0f)) ;
    return;
}

void project_displacement_slot_0(uint tid_16, const Island_natural_0 thread* isl_24, uint slot_5, KernelContext_0 thread* kernelContext_81)
{
    uint _S1187;
    float3 _S1188 = float3(0.0f) ;
    thread float3 p_16 = _S1188;
    thread float3 l_5 = _S1188;
    uint4 _S1189 = uint4(isl_24->range_0) ;
    uint _S1190 = _S1189.x + tid_16;
    uint c_39 = _S1190;
    for(;;)
    {
        uint _S1191 = _S1189.y;
        _S1187 = _S1191;
        if(c_39 < _S1191)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_natural_0 device* _S1192 = kernelContext_81->chunks_0+c_39;
        uint _S1193 = sv_0(c_39, slot_5, kernelContext_81);
        float3 u_6 = (float4(*(kernelContext_81->scratch_0+_S1193)) ).xyz;
        uint _S1194 = sv_0(c_39, slot_5 + 1U, kernelContext_81);
        float3 th_7 = (float4(*(kernelContext_81->scratch_0+_S1194)) ).xyz;
        float4 _S1195 = float4(_S1192->center_0) ;
        float3 r_15 = _S1195.xyz - (float4(isl_24->com_0) ).xyz;
        float3 _S1196 = float3(_S1195.w) ;
        p_16 = p_16 + u_6 * _S1196;
        l_5 = l_5 + (cross(r_15, u_6) * _S1196 + rows_mul_0(float4(_S1192->inertia0_1) , float4(_S1192->inertia1_1) , float4(_S1192->inertia2_1) , th_7));
        c_39 = c_39 + 256U;
    }
    group_sum3_0(tid_16, &p_16, &l_5, kernelContext_81);
    float4 _S1197 = float4(isl_24->com_0) ;
    float3 _S1198 = p_16 / float3(_S1197.w) ;
    float3 _S1199 = rows_mul_0(float4(isl_24->inv0_0) , float4(isl_24->inv1_0) , float4(isl_24->inv2_0) , l_5);
    c_39 = _S1190;
    for(;;)
    {
        if(c_39 < _S1187)
        {
        }
        else
        {
            break;
        }
        float3 r_16 = (float4((kernelContext_81->chunks_0+c_39)->center_0) ).xyz - _S1197.xyz;
        uint _S1200 = sv_0(c_39, slot_5, kernelContext_81);
        *(kernelContext_81->scratch_0+_S1200) = packed_float4(float4((float4(*(kernelContext_81->scratch_0+_S1200)) ).xyz - _S1198 - cross(_S1199, r_16), 0.0f)) ;
        uint _S1201 = sv_0(c_39, slot_5 + 1U, kernelContext_81);
        *(kernelContext_81->scratch_0+_S1201) = packed_float4(float4((float4(*(kernelContext_81->scratch_0+_S1201)) ).xyz - _S1199, 0.0f)) ;
        c_39 = c_39 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    return;
}

uint statics_result_slot_0(uint island_1, KernelContext_0 thread* kernelContext_82)
{
    return kernelContext_82->params_0->statics_base_0 + 23U * kernelContext_82->params_0->chunk_count_0 + 2U * kernelContext_82->params_0->statics_bonds_0 + island_1;
}

void write_bond_loads_0(uint _S1202, uint _S1203, float3 _S1204, float3 _S1205, float _S1206, KernelContext_0 thread* kernelContext_83)
{
    BondStatic_natural_0 device* _S1207 = kernelContext_83->bonds_0+_S1203;
    float3 _S1208 = to_body_0(_S1203, _S1204, kernelContext_83);
    float3 _S1209 = to_body_0(_S1203, _S1205, kernelContext_83);
    uint _S1210 = 3U * _S1202;
    *(kernelContext_83->scratch_0+_S1210) = packed_float4(float4(_S1208, _S1206)) ;
    *(kernelContext_83->scratch_0+(_S1210 + 1U)) = packed_float4(float4(_S1209 + cross((float4(_S1207->ra_0) ).xyz, _S1208), 0.0f)) ;
    *(kernelContext_83->scratch_0+(_S1210 + 2U)) = packed_float4(float4(- _S1209 + cross((float4(_S1207->rb_0) ).xyz, - _S1208), 0.0f)) ;
    return;
}

void bond_kinematics_0(uint _S1211, float3 _S1212, float3 _S1213, float3 _S1214, float3 _S1215, float3 thread* _S1216, float3 thread* _S1217, KernelContext_0 thread* kernelContext_84)
{
    BondStatic_natural_0 device* _S1218 = kernelContext_84->bonds_0+_S1211;
    float3 _S1219 = to_local_0(_S1211, _S1214 + cross(_S1215, (float4(_S1218->rb_0) ).xyz) - (_S1212 + cross(_S1213, (float4(_S1218->ra_0) ).xyz)), kernelContext_84);
    *_S1216 = _S1219;
    float3 _S1220 = to_local_0(_S1211, _S1215 - _S1213, kernelContext_84);
    *_S1217 = _S1220;
    return;
}

[[kernel]] void island_statics(uint3 group_9 [[threadgroup_position_in_grid]], uint3 thread_9 [[thread_position_in_threadgroup]], Params_0 constant* params_13 [[buffer(0)]], Island_natural_0 device* islands_13 [[buffer(9)]], uint device* index_13 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_13 [[buffer(3)]], packed_float4 device* state_15 [[buffer(6)]], packed_float4 device* scratch_13 [[buffer(8)]], packed_float4 device* contact_state_13 [[buffer(11)]], packed_float4 device* loads_13 [[buffer(5)]], Impactor_natural_0 device* impactors_13 [[buffer(10)]], BondStatic_natural_0 device* bonds_13 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_13 [[buffer(7)]], MaterialTable_0 constant* materials_13 [[buffer(1)]])
{
    uint i_20;
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
    threadgroup array<float4, int(256)> g_red_a_13;
    (&kernelContext_85)->g_red_a_0 = &g_red_a_13;
    threadgroup array<float4, int(256)> g_red_b_13;
    (&kernelContext_85)->g_red_b_0 = &g_red_b_13;
    threadgroup uint g_run_13;
    (&kernelContext_85)->g_run_0 = &g_run_13;
    threadgroup uint g_halt_13;
    (&kernelContext_85)->g_halt_0 = &g_halt_13;
    threadgroup uint g_wide_run_13;
    (&kernelContext_85)->g_wide_run_0 = &g_wide_run_13;
    uint tid_17 = thread_9.x;
    uint _S1221 = group_9.x;
    thread Island_natural_0 _S1222 = *(islands_13+_S1221);
    uint4 _S1223 = uint4((&_S1222)->info_0) ;
    uint _S1224 = _S1223.z;
    if((_S1224 & 8U) == 0U)
    {
        return;
    }
    bool free_0 = ((_S1223.x) & 1U) == 0U;
    uint4 _S1225 = uint4((&_S1222)->range_0) ;
    uint c0_1 = _S1225.x;
    uint c1_1 = _S1225.y;
    uint b0_0 = _S1225.z;
    uint _S1226 = _S1225.w;
    uint _S1227 = c0_1 + tid_17;
    uint c_41 = _S1227;
    for(;;)
    {
        if(c_41 < c1_1)
        {
        }
        else
        {
            break;
        }
        uint _S1228 = sv_0(c_41, 21U, &kernelContext_85);
        packed_float4 _S1229 = packed_float4(float4(0.0f) ) ;
        *((&kernelContext_85)->scratch_0+_S1228) = _S1229;
        uint _S1230 = sv_0(c_41, 22U, &kernelContext_85);
        *((&kernelContext_85)->scratch_0+_S1230) = _S1229;
        c_41 = c_41 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    if(free_0)
    {
        project_load_slot_0(tid_17, &_S1222, 0U, &kernelContext_85);
    }
    float _S1231 = island_dot_0(tid_17, c0_1, c1_1, 0U, 0U, &kernelContext_85);
    float _S1232 = max(sqrt(_S1231), 1.00000000317107685e-30f);
    float _S1233 = (&kernelContext_85)->params_0->statics_tol_0;
    uint _S1234 = min((&kernelContext_85)->params_0->statics_cg_0, 20U * (c1_1 - c0_1) * 6U + 200U);
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
        uint _S1235 = b0_0 + tid_17;
        i_20 = _S1235;
        for(;;)
        {
            if(i_20 < _S1226)
            {
            }
            else
            {
                break;
            }
            JointResponse_0 _S1236 = static_response_0(i_20, &kernelContext_85);
            write_bond_loads_0(i_20, i_20, _S1236.force_lin_1, _S1236.force_ang_1, 0.0f, &kernelContext_85);
            i_20 = i_20 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        float4 _S1237 = float4(0.0f) ;
        thread float4 magnitude_0 = _S1237;
        thread float4 unused_m_0 = _S1237;
        c_41 = _S1227;
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
            float _S1238 = bond_load_magnitude2_0(c_41, &kernelContext_85);
            magnitude_0.x = magnitude_0.x + _S1238;
            uint _S1239 = sv_0(c_41, 0U, &kernelContext_85);
            thread float4 r_lin_0 = float4((float4(*((&kernelContext_85)->scratch_0+_S1239)) ).xyz + fi_4, 0.0f);
            uint _S1240 = sv_0(c_41, 1U, &kernelContext_85);
            thread float4 r_ang_0 = float4((float4(*((&kernelContext_85)->scratch_0+_S1240)) ).xyz + mi_7, 0.0f);
            uint _S1241 = fixed_mask_0(c_41, &kernelContext_85);
            hold_0(_S1241, &r_lin_0, &r_ang_0, _S1237, _S1237);
            uint _S1242 = sv_0(c_41, 4U, &kernelContext_85);
            *((&kernelContext_85)->scratch_0+_S1242) = packed_float4(r_lin_0) ;
            uint _S1243 = sv_0(c_41, 5U, &kernelContext_85);
            *((&kernelContext_85)->scratch_0+_S1243) = packed_float4(r_ang_0) ;
            c_41 = c_41 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        group_sum2_0(tid_17, &magnitude_0, &unused_m_0, &kernelContext_85);
        if(free_0)
        {
            project_load_slot_0(tid_17, &_S1222, 4U, &kernelContext_85);
        }
        float _S1244 = island_dot_0(tid_17, c0_1, c1_1, 4U, 4U, &kernelContext_85);
        float residual_1 = sqrt(_S1244) / _S1232;
        float _S1245 = max(0.00100000004749745f, 3.83999986297567375e-06f * sqrt(magnitude_0.x) / _S1232);
        if(residual_1 <= _S1233)
        {
            converged_0 = true;
        }
        else
        {
            if(residual_1 <= _S1245)
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
        uint i_21 = _S1235;
        for(;;)
        {
            if(i_21 < _S1226)
            {
            }
            else
            {
                break;
            }
            BondStatic_natural_0 device* _S1246 = (&kernelContext_85)->bonds_0+i_21;
            thread float3 d_lin_4;
            thread float3 d_ang_3;
            static_kinematics_0(i_21, &d_lin_4, &d_ang_3, &kernelContext_85);
            thread JointBond_natural_0 _S1247 = _S1246->law_0;
            thread JointState_0 _S1248 = ((&kernelContext_85)->bond_dyn_0+i_21)->js_0;
            thread float3 f_lin_2;
            thread float3 f_ang_2;
            secant_factors_0(&_S1247, &_S1248, d_lin_4, &f_lin_2, &f_ang_2);
            float4 _S1249 = float4((&_S1247)->stiff0_0) ;
            uint _S1250 = statics_bond_slot_0(i_21, &kernelContext_85);
            float _S1251 = _S1249.y;
            *((&kernelContext_85)->scratch_0+_S1250) = packed_float4(float4(_S1251 * f_lin_2.x, _S1251 * f_lin_2.y, _S1249.x * f_lin_2.z, 0.0f)) ;
            *((&kernelContext_85)->scratch_0+(_S1250 + 1U)) = packed_float4(float4(_S1249.z * f_ang_2.x, _S1249.w * f_ang_2.y, (float4((&_S1247)->stiff1_0) ).x * f_ang_2.z, 0.0f)) ;
            i_21 = i_21 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_42 = _S1227;
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
            uint _S1252 = sv_0(c_42, 2U, &kernelContext_85);
            packed_float4 _S1253 = packed_float4(_S1237) ;
            *((&kernelContext_85)->scratch_0+_S1252) = _S1253;
            uint _S1254 = sv_0(c_42, 3U, &kernelContext_85);
            *((&kernelContext_85)->scratch_0+_S1254) = _S1253;
            c_42 = c_42 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_43 = _S1227;
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
            project_displacement_slot_0(tid_17, &_S1222, 6U, &kernelContext_85);
        }
        uint c_44 = _S1227;
        for(;;)
        {
            if(c_44 < c1_1)
            {
            }
            else
            {
                break;
            }
            uint _S1255 = sv_0(c_44, 8U, &kernelContext_85);
            packed_float4 device* _S1256 = (&kernelContext_85)->scratch_0+_S1255;
            uint _S1257 = sv_0(c_44, 6U, &kernelContext_85);
            *_S1256 = packed_float4(float4(*((&kernelContext_85)->scratch_0+_S1257)) ) ;
            uint _S1258 = sv_0(c_44, 9U, &kernelContext_85);
            packed_float4 device* _S1259 = (&kernelContext_85)->scratch_0+_S1258;
            uint _S1260 = sv_0(c_44, 7U, &kernelContext_85);
            *_S1259 = packed_float4(float4(*((&kernelContext_85)->scratch_0+_S1260)) ) ;
            c_44 = c_44 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        float _S1261 = island_dot_0(tid_17, c0_1, c1_1, 4U, 6U, &kernelContext_85);
        float _S1262 = island_dot_0(tid_17, c0_1, c1_1, 4U, 4U, &kernelContext_85);
        float _S1263 = sqrt(_S1262);
        float rz_0 = _S1261;
        uint k_24 = 0U;
        uint cg_total_1 = cg_total_0;
        for(;;)
        {
            bool _S1264;
            if(k_24 < _S1234)
            {
                _S1264 = _S1263 > 0.0f;
            }
            else
            {
                _S1264 = false;
            }
            if(_S1264)
            {
            }
            else
            {
                cg_total_0 = cg_total_1;
                break;
            }
            uint i_22 = _S1235;
            for(;;)
            {
                if(i_22 < _S1226)
                {
                }
                else
                {
                    break;
                }
                uint4 _S1265 = uint4(((&kernelContext_85)->bonds_0+i_22)->law_0.ids_0) ;
                uint ca_2 = _S1265.y;
                uint cb_2 = _S1265.z;
                uint _S1266 = sv_0(ca_2, 8U, &kernelContext_85);
                float3 _S1267 = (float4(*((&kernelContext_85)->scratch_0+_S1266)) ).xyz;
                uint _S1268 = sv_0(ca_2, 9U, &kernelContext_85);
                float3 _S1269 = (float4(*((&kernelContext_85)->scratch_0+_S1268)) ).xyz;
                uint _S1270 = sv_0(cb_2, 8U, &kernelContext_85);
                float3 _S1271 = (float4(*((&kernelContext_85)->scratch_0+_S1270)) ).xyz;
                uint _S1272 = sv_0(cb_2, 9U, &kernelContext_85);
                thread float3 d_lin_5;
                thread float3 d_ang_4;
                bond_kinematics_0(i_22, _S1267, _S1269, _S1271, (float4(*((&kernelContext_85)->scratch_0+_S1272)) ).xyz, &d_lin_5, &d_ang_4, &kernelContext_85);
                uint _S1273 = statics_bond_slot_0(i_22, &kernelContext_85);
                write_bond_loads_0(i_22, i_22, d_lin_5 * (float4(*((&kernelContext_85)->scratch_0+_S1273)) ).xyz, d_ang_4 * (float4(*((&kernelContext_85)->scratch_0+(_S1273 + 1U))) ).xyz, 0.0f, &kernelContext_85);
                i_22 = i_22 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            c_40 = _S1227;
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
                uint _S1274 = fixed_mask_0(c_40, &kernelContext_85);
                uint _S1275 = sv_0(c_40, 8U, &kernelContext_85);
                float4 _S1276 = float4(*((&kernelContext_85)->scratch_0+_S1275)) ;
                uint _S1277 = sv_0(c_40, 9U, &kernelContext_85);
                hold_0(_S1274, &ap_lin_0, &ap_ang_0, _S1276, float4(*((&kernelContext_85)->scratch_0+_S1277)) );
                uint _S1278 = sv_0(c_40, 10U, &kernelContext_85);
                *((&kernelContext_85)->scratch_0+_S1278) = packed_float4(ap_lin_0) ;
                uint _S1279 = sv_0(c_40, 11U, &kernelContext_85);
                *((&kernelContext_85)->scratch_0+_S1279) = packed_float4(ap_ang_0) ;
                c_40 = c_40 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            float _S1280 = island_dot_0(tid_17, c0_1, c1_1, 8U, 10U, &kernelContext_85);
            uint _S1281 = cg_total_1 + 1U;
            if(_S1280 <= 0.0f)
            {
                cg_total_0 = _S1281;
                break;
            }
            float _S1282 = rz_0 / _S1280;
            uint c_45 = _S1227;
            for(;;)
            {
                if(c_45 < c1_1)
                {
                }
                else
                {
                    break;
                }
                uint _S1283 = sv_0(c_45, 2U, &kernelContext_85);
                packed_float4 device* _S1284 = (&kernelContext_85)->scratch_0+_S1283;
                float3 _S1285 = (float4(*((&kernelContext_85)->scratch_0+_S1283)) ).xyz;
                uint _S1286 = sv_0(c_45, 8U, &kernelContext_85);
                float3 _S1287 = float3(_S1282) ;
                *_S1284 = packed_float4(float4(_S1285 + _S1287 * (float4(*((&kernelContext_85)->scratch_0+_S1286)) ).xyz, 0.0f)) ;
                uint _S1288 = sv_0(c_45, 3U, &kernelContext_85);
                packed_float4 device* _S1289 = (&kernelContext_85)->scratch_0+_S1288;
                float3 _S1290 = (float4(*((&kernelContext_85)->scratch_0+_S1288)) ).xyz;
                uint _S1291 = sv_0(c_45, 9U, &kernelContext_85);
                *_S1289 = packed_float4(float4(_S1290 + _S1287 * (float4(*((&kernelContext_85)->scratch_0+_S1291)) ).xyz, 0.0f)) ;
                uint _S1292 = sv_0(c_45, 4U, &kernelContext_85);
                packed_float4 device* _S1293 = (&kernelContext_85)->scratch_0+_S1292;
                float3 _S1294 = (float4(*((&kernelContext_85)->scratch_0+_S1292)) ).xyz;
                uint _S1295 = sv_0(c_45, 10U, &kernelContext_85);
                *_S1293 = packed_float4(float4(_S1294 - _S1287 * (float4(*((&kernelContext_85)->scratch_0+_S1295)) ).xyz, 0.0f)) ;
                uint _S1296 = sv_0(c_45, 5U, &kernelContext_85);
                packed_float4 device* _S1297 = (&kernelContext_85)->scratch_0+_S1296;
                float3 _S1298 = (float4(*((&kernelContext_85)->scratch_0+_S1296)) ).xyz;
                uint _S1299 = sv_0(c_45, 11U, &kernelContext_85);
                *_S1297 = packed_float4(float4(_S1298 - _S1287 * (float4(*((&kernelContext_85)->scratch_0+_S1299)) ).xyz, 0.0f)) ;
                c_45 = c_45 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            float _S1300 = island_dot_0(tid_17, c0_1, c1_1, 4U, 4U, &kernelContext_85);
            if((sqrt(_S1300)) <= (0.00009999999747379f * _S1263))
            {
                cg_total_0 = _S1281;
                break;
            }
            uint c_46 = _S1227;
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
                project_displacement_slot_0(tid_17, &_S1222, 6U, &kernelContext_85);
            }
            float _S1301 = island_dot_0(tid_17, c0_1, c1_1, 4U, 6U, &kernelContext_85);
            float _S1302 = _S1301 / rz_0;
            uint c_47 = _S1227;
            for(;;)
            {
                if(c_47 < c1_1)
                {
                }
                else
                {
                    break;
                }
                uint _S1303 = sv_0(c_47, 8U, &kernelContext_85);
                packed_float4 device* _S1304 = (&kernelContext_85)->scratch_0+_S1303;
                uint _S1305 = sv_0(c_47, 6U, &kernelContext_85);
                float3 _S1306 = float3(_S1302) ;
                *_S1304 = packed_float4(float4((float4(*((&kernelContext_85)->scratch_0+_S1305)) ).xyz + _S1306 * (float4(*((&kernelContext_85)->scratch_0+_S1303)) ).xyz, 0.0f)) ;
                uint _S1307 = sv_0(c_47, 9U, &kernelContext_85);
                packed_float4 device* _S1308 = (&kernelContext_85)->scratch_0+_S1307;
                uint _S1309 = sv_0(c_47, 7U, &kernelContext_85);
                *_S1308 = packed_float4(float4((float4(*((&kernelContext_85)->scratch_0+_S1309)) ).xyz + _S1306 * (float4(*((&kernelContext_85)->scratch_0+_S1307)) ).xyz, 0.0f)) ;
                c_47 = c_47 + 256U;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
            uint _S1310 = k_24 + 1U;
            rz_0 = _S1301;
            k_24 = _S1310;
            cg_total_1 = _S1281;
        }
        c_40 = _S1227;
        for(;;)
        {
            if(c_40 < c1_1)
            {
            }
            else
            {
                break;
            }
            uint _S1311 = 4U * c_40;
            thread float3 u_7 = (float4(*((&kernelContext_85)->state_0+_S1311)) ).xyz;
            uint _S1312 = sv_0(c_40, 21U, &kernelContext_85);
            thread float3 u_lo_0 = (float4(*((&kernelContext_85)->scratch_0+_S1312)) ).xyz;
            uint _S1313 = _S1311 + 1U;
            thread float3 th_8 = (float4(*((&kernelContext_85)->state_0+_S1313)) ).xyz;
            uint _S1314 = sv_0(c_40, 22U, &kernelContext_85);
            thread float3 th_lo_0 = (float4(*((&kernelContext_85)->scratch_0+_S1314)) ).xyz;
            uint _S1315 = sv_0(c_40, 2U, &kernelContext_85);
            comp_add_0(&u_7, &u_lo_0, (float4(*((&kernelContext_85)->scratch_0+_S1315)) ).xyz);
            uint _S1316 = sv_0(c_40, 3U, &kernelContext_85);
            comp_add_0(&th_8, &th_lo_0, (float4(*((&kernelContext_85)->scratch_0+_S1316)) ).xyz);
            *((&kernelContext_85)->state_0+_S1311) = packed_float4(float4(u_7, (float4(*((&kernelContext_85)->state_0+_S1311)) ).w)) ;
            *((&kernelContext_85)->state_0+_S1313) = packed_float4(float4(th_8, (float4(*((&kernelContext_85)->state_0+_S1313)) ).w)) ;
            *((&kernelContext_85)->scratch_0+_S1312) = packed_float4(float4(u_lo_0, 0.0f)) ;
            *((&kernelContext_85)->scratch_0+_S1314) = packed_float4(float4(th_lo_0, 0.0f)) ;
            c_40 = c_40 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint _S1317 = newton_0 + 1U;
        previous_2 = residual_1;
        residual_0 = residual_1;
        newton_0 = _S1317;
    }
    i_20 = b0_0 + tid_17;
    for(;;)
    {
        if(i_20 < _S1226)
        {
        }
        else
        {
            break;
        }
        JointResponse_0 _S1318 = static_response_0(i_20, &kernelContext_85);
        BondDyn_natural_0 device* _S1319 = (&kernelContext_85)->bond_dyn_0+i_20;
        float4 _S1320 = float4((*_S1319).force_lin_0) ;
        float4 _S1321 = float4((*_S1319).force_ang_0) ;
        float4 _S1322 = float4((*_S1319).sums_0) ;
        float4 _S1323 = float4((*_S1319).comps_0) ;
        uint4 _S1324 = uint4((*_S1319).events_0) ;
        thread BondDyn_0 bd_1;
        (&bd_1)->js_0 = (*_S1319).js_0;
        (&bd_1)->force_lin_0 = _S1320;
        (&bd_1)->force_ang_0 = _S1321;
        (&bd_1)->sums_0 = _S1322;
        (&bd_1)->comps_0 = _S1323;
        (&bd_1)->events_0 = _S1324;
        (&bd_1)->force_lin_0 = float4(_S1318.force_lin_1, _S1318.stored_5);
        (&bd_1)->force_ang_0 = float4(_S1318.force_ang_1, (&bd_1)->force_ang_0.w);
        BondDyn_natural_0 device* _S1325 = (&kernelContext_85)->bond_dyn_0+i_20;
        _S1325->js_0 = bd_1.js_0;
        _S1325->force_lin_0 = packed_float4(bd_1.force_lin_0) ;
        _S1325->force_ang_0 = packed_float4(bd_1.force_ang_0) ;
        _S1325->sums_0 = packed_float4(bd_1.sums_0) ;
        _S1325->comps_0 = packed_float4(bd_1.comps_0) ;
        _S1325->events_0 = packed_uint4(bd_1.events_0) ;
        write_bond_loads_0(i_20, i_20, _S1318.force_lin_1, _S1318.force_ang_1, max(_S1318.measures_0.tension_0, _S1318.measures_0.compression_0), &kernelContext_85);
        i_20 = i_20 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
    c_41 = _S1227;
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
        uint _S1326 = fixed_mask_0(c_41, &kernelContext_85);
        float3 reaction_2;
        if(_S1326 != 0U)
        {
            uint _S1327 = sv_0(c_41, 0U, &kernelContext_85);
            reaction_2 = - ((float4(*((&kernelContext_85)->scratch_0+_S1327)) ).xyz + fi_6);
        }
        else
        {
            uint _S1328 = 4U * c_41;
            reaction_2 = float3((float4(*((&kernelContext_85)->state_0+(_S1328 + 1U))) ).w, (float4(*((&kernelContext_85)->state_0+(_S1328 + 2U))) ).w, (float4(*((&kernelContext_85)->state_0+(_S1328 + 3U))) ).w);
        }
        uint _S1329 = 4U * c_41;
        uint _S1330 = _S1329 + 1U;
        *((&kernelContext_85)->state_0+_S1330) = packed_float4(float4((float4(*((&kernelContext_85)->state_0+_S1330)) ).xyz, reaction_2.x)) ;
        *((&kernelContext_85)->state_0+(_S1329 + 2U)) = packed_float4(float4(0.0f, 0.0f, 0.0f, reaction_2.y)) ;
        *((&kernelContext_85)->state_0+(_S1329 + 3U)) = packed_float4(float4(0.0f, 0.0f, 0.0f, reaction_2.z)) ;
        c_41 = c_41 + 256U;
    }
    if(tid_17 == 0U)
    {
        uint _S1331 = statics_result_slot_0(_S1221, &kernelContext_85);
        packed_float4 device* _S1332 = (&kernelContext_85)->scratch_0+_S1331;
        float _S1333 = (as_type<float>((newton_0)));
        float _S1334 = (as_type<float>((cg_total_0)));
        if(converged_0)
        {
            previous_2 = 1.0f;
        }
        else
        {
            previous_2 = 0.0f;
        }
        *_S1332 = packed_float4(float4(residual_0, _S1333, _S1334, previous_2)) ;
        ((&kernelContext_85)->islands_0+_S1221)->info_0[int(2)] = _S1224 & 4294967287U;
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
    threadgroup array<float4, int(256)> g_red_a_14;
    (&kernelContext_86)->g_red_a_0 = &g_red_a_14;
    threadgroup array<float4, int(256)> g_red_b_14;
    (&kernelContext_86)->g_red_b_0 = &g_red_b_14;
    threadgroup uint g_run_14;
    (&kernelContext_86)->g_run_0 = &g_run_14;
    threadgroup uint g_halt_14;
    (&kernelContext_86)->g_halt_0 = &g_halt_14;
    threadgroup uint g_wide_run_14;
    (&kernelContext_86)->g_wide_run_0 = &g_wide_run_14;
    uint tid_18 = thread_10.x;
    uint _S1335 = group_10.x;
    Island_natural_0 device* _S1336 = islands_14+_S1335;
    Island_natural_0 isl_25 = *_S1336;
    uint4 _S1337 = uint4((*_S1336).info_0) ;
    bool _S1338;
    if(((_S1337.x) & 16U) == 0U)
    {
        _S1338 = true;
    }
    else
    {
        uint4 _S1339 = uint4(isl_25.range_0) ;
        _S1338 = (_S1339.w) == (_S1339.z);
    }
    if(_S1338)
    {
        return;
    }
    bool _S1340 = tid_18 == 0U;
    if(_S1340)
    {
        *(&kernelContext_86)->g_halt_0 = 0U;
        *(&kernelContext_86)->g_run_0 = 0U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    uint _S1341 = _S1337.w;
    uint4 _S1342 = uint4(isl_25.range_0) ;
    uint i_23 = _S1342.z + tid_18;
    for(;;)
    {
        if(i_23 < (_S1342.w))
        {
        }
        else
        {
            break;
        }
        BondStatic_natural_0 device* _S1343 = (&kernelContext_86)->bonds_0+i_23;
        BondDyn_natural_0 device* _S1344 = (&kernelContext_86)->bond_dyn_0+i_23;
        float4 _S1345 = float4((*_S1344).force_lin_0) ;
        float4 _S1346 = float4((*_S1344).force_ang_0) ;
        float4 _S1347 = float4((*_S1344).sums_0) ;
        float4 _S1348 = float4((*_S1344).comps_0) ;
        uint4 _S1349 = uint4((*_S1344).events_0) ;
        thread BondDyn_0 bd_2;
        (&bd_2)->js_0 = (*_S1344).js_0;
        (&bd_2)->force_lin_0 = _S1345;
        (&bd_2)->force_ang_0 = _S1346;
        (&bd_2)->sums_0 = _S1347;
        (&bd_2)->comps_0 = _S1348;
        (&bd_2)->events_0 = _S1349;
        thread JointBond_natural_0 _S1350 = _S1343->law_0;
        uint4 _S1351 = uint4((&_S1350)->ids_0) ;
        uint _S1352 = 4U * _S1351.y;
        uint _S1353 = 4U * _S1351.z;
        thread float3 d_lin_6;
        thread float3 d_ang_5;
        bond_kinematics_0(i_23, (float4(*((&kernelContext_86)->state_0+_S1352)) ).xyz, (float4(*((&kernelContext_86)->state_0+(_S1352 + 1U))) ).xyz, (float4(*((&kernelContext_86)->state_0+_S1353)) ).xyz, (float4(*((&kernelContext_86)->state_0+(_S1353 + 1U))) ).xyz, &d_lin_6, &d_ang_5, &kernelContext_86);
        JointState_0 previous_3 = (&bd_2)->js_0;
        float _S1354 = (&kernelContext_86)->params_0->dt_0;
        bool _S1355 = ((&kernelContext_86)->params_0->fracture_0) != 0U;
        _S1350 = _S1343->law_0;
        thread JointState_0 _S1356 = (&bd_2)->js_0;
        JointResponse_0 _S1357 = joint_evaluate_0(&(&kernelContext_86)->materials_0->m_0[_S1351.x], &_S1350, &_S1356, d_lin_6, d_ang_5, _S1354, _S1355);
        if((_S1357.state_6.damage_0) > (previous_3.damage_0 + 9.99999971718068537e-10f))
        {
            _S1338 = true;
        }
        else
        {
            _S1338 = (_S1357.state_6.crush_1) > (previous_3.crush_1 + 9.99999971718068537e-10f);
        }
        uint flags_2;
        if(_S1338)
        {
            flags_2 = 16U;
        }
        else
        {
            flags_2 = 0U;
        }
        thread float _S1358 = (&bd_2)->sums_0.x;
        thread float _S1359 = (&bd_2)->comps_0.x;
        comp_add1_0(&_S1358, &_S1359, _S1357.dissipated_2);
        (&bd_2)->comps_0.x = _S1359;
        (&bd_2)->sums_0.x = _S1358;
        thread float _S1360 = (&bd_2)->sums_0.y;
        thread float _S1361 = (&bd_2)->comps_0.y;
        comp_add1_0(&_S1360, &_S1361, _S1357.overshoot_0);
        (&bd_2)->comps_0.y = _S1361;
        (&bd_2)->sums_0.y = _S1360;
        (&bd_2)->force_lin_0 = float4(_S1357.force_lin_1, _S1357.stored_5);
        (&bd_2)->force_ang_0 = float4(_S1357.force_ang_1, max((&bd_2)->force_ang_0.w, _S1357.state_6.utilization_0));
        thread JointState_0 _S1362 = previous_3;
        bool _S1363 = is_damaged_0(&_S1362);
        bool _S1364;
        if(!_S1363)
        {
            thread JointState_0 _S1365 = _S1357.state_6;
            bool _S1366 = is_damaged_0(&_S1365);
            _S1364 = _S1366;
        }
        else
        {
            _S1364 = false;
        }
        bool _S1367;
        if(_S1364)
        {
            _S1367 = ((&bd_2)->events_0.x) == 0U;
        }
        else
        {
            _S1367 = false;
        }
        if(_S1367)
        {
            (&bd_2)->events_0.x = _S1341;
            (&bd_2)->events_0.w = _S1357.state_6.mode_0;
        }
        bool _S1368;
        if(((&bd_2)->events_0.y) == 0U)
        {
            float _S1369 = fatigue_factor_0(&(&kernelContext_86)->materials_0->m_0[_S1351.x], previous_3.fatigue_0);
            _S1368 = _S1369 > 0.99000000953674316f;
        }
        else
        {
            _S1368 = false;
        }
        bool _S1370;
        if(_S1368)
        {
            float _S1371 = fatigue_factor_0(&(&kernelContext_86)->materials_0->m_0[_S1351.x], _S1357.state_6.fatigue_0);
            _S1370 = _S1371 <= 0.99000000953674316f;
        }
        else
        {
            _S1370 = false;
        }
        if(_S1370)
        {
            (&bd_2)->events_0.y = _S1341;
        }
        uint flags_3;
        if(_S1357.disconnected_0)
        {
            (&bd_2)->events_0.z = _S1341;
            flags_3 = flags_2 | 32U;
        }
        else
        {
            flags_3 = flags_2;
        }
        (&bd_2)->js_0 = _S1357.state_6;
        BondDyn_natural_0 device* _S1372 = (&kernelContext_86)->bond_dyn_0+i_23;
        _S1372->js_0 = bd_2.js_0;
        _S1372->force_lin_0 = packed_float4(bd_2.force_lin_0) ;
        _S1372->force_ang_0 = packed_float4(bd_2.force_ang_0) ;
        _S1372->sums_0 = packed_float4(bd_2.sums_0) ;
        _S1372->comps_0 = packed_float4(bd_2.comps_0) ;
        _S1372->events_0 = packed_uint4(bd_2.events_0) ;
        write_bond_loads_0(i_23, i_23, _S1357.force_lin_1, _S1357.force_ang_1, max(_S1357.measures_0.tension_0, _S1357.measures_0.compression_0), &kernelContext_86);
        if((flags_3 & 16U) != 0U)
        {
            *(&kernelContext_86)->g_halt_0 = 1U;
        }
        if((flags_3 & 32U) != 0U)
        {
            *(&kernelContext_86)->g_run_0 = 1U;
        }
        i_23 = i_23 + 256U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    if(_S1340)
    {
        _S1338 = ((*(&kernelContext_86)->g_halt_0) | (*(&kernelContext_86)->g_run_0)) != 0U;
    }
    else
    {
        _S1338 = false;
    }
    if(_S1338)
    {
        uint _S1373 = _S1337.z;
        if((*(&kernelContext_86)->g_halt_0) != 0U)
        {
            i_23 = 16U;
        }
        else
        {
            i_23 = 0U;
        }
        uint _S1374 = _S1373 | i_23;
        if((*(&kernelContext_86)->g_run_0) != 0U)
        {
            i_23 = 32U;
        }
        else
        {
            i_23 = 0U;
        }
        ((&kernelContext_86)->islands_0+_S1335)->info_0[int(2)] = _S1374 | i_23;
    }
    return;
}

