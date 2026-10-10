#include "slang-cuda-prelude.h"

struct Params_0
{
    float4  gravity_0;
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

struct JointMaterial_0
{
    float4  strength_0;
    float4  energy_0;
    float4  dif_0;
    float4  misc_0;
    uint4  kind_flags_0;
};

struct MaterialTable_0
{
    FixedArray<JointMaterial_0, 64>  m_0;
};

struct JointBond_0
{
    float4  geom0_0;
    float4  geom1_0;
    float4  stiff0_0;
    float4  stiff1_0;
    float4  rebar0_0;
    float4  rebar1_0;
    uint4  ids_0;
};

struct BondStatic_0
{
    float4  t1_0;
    float4  t2_0;
    float4  normal_0;
    float4  ra_0;
    float4  rb_0;
    float4  centroid_0;
    float4  c_lin_0;
    float4  c_ang_0;
    JointBond_0 law_0;
};

struct ChunkStatic_0
{
    float4  center_0;
    float4  inertia0_0;
    float4  inertia1_0;
    float4  inertia2_0;
    float4  inv0_0;
    float4  inv1_0;
    float4  inv2_0;
    float4  scale_0;
    uint4  info_0;
    uint4  load_range_0;
    float4  half_0;
    float4  crot0_0;
    float4  crot1_0;
    float4  crot2_0;
    float4  cmat_0;
    float4  start_hi_0;
    float4  start_lo_0;
    uint4  cinfo_0;
};

struct JointState_0
{
    float damage_0;
    float crush_0;
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

struct BondDyn_0
{
    JointState_0 js_0;
    float4  force_lin_0;
    float4  force_ang_0;
    float4  sums_0;
    float4  comps_0;
    uint4  events_0;
};

struct Island_0
{
    uint4  range_0;
    uint4  info_1;
    float4  com_0;
    float4  inertia0_1;
    float4  inertia1_1;
    float4  inertia2_1;
    float4  inv0_1;
    float4  inv1_1;
    float4  inv2_1;
    float4  wcom_0;
    float4  winv0_0;
    float4  winv1_0;
    float4  winv2_0;
    float4  rotation_0;
    float4  position_0;
    float4  position_err_0;
    float4  velocity_0;
    float4  velocity_err_0;
    float4  angular_velocity_0;
    uint4  done_0;
    uint4  probes_0;
    float4  energy_1;
};

struct Impactor_0
{
    float4  position_1;
    float4  position_err_1;
    float4  velocity_1;
    float4  velocity_err_1;
    float4  angular_velocity_1;
    float4  rotation_1;
    float4  inertia0_2;
    float4  inertia1_2;
    float4  inertia2_2;
    float4  inv0_2;
    float4  inv1_2;
    float4  inv2_2;
    float4  shape_0;
    float4  half_1;
    float4  mat_0;
    float4  crush_1;
    float4  geom_0;
    float4  unused_0;
    float4  ledger_0;
    uint4  cand_0;
};

struct GlobalParams_0
{
    Params_0* params_0;
    MaterialTable_0* materials_0;
    StructuredBuffer<BondStatic_0> bonds_0;
    StructuredBuffer<ChunkStatic_0> chunks_0;
    StructuredBuffer<uint> index_0;
    StructuredBuffer<float4 > loads_0;
    RWStructuredBuffer<float4 > state_0;
    RWStructuredBuffer<BondDyn_0> bond_dyn_0;
    RWStructuredBuffer<float4 > scratch_0;
    RWStructuredBuffer<Island_0> islands_0;
    RWStructuredBuffer<Impactor_0> impactors_0;
    RWStructuredBuffer<float4 > contact_state_0;
};

extern "C" __constant__ GlobalParams_0 SLANG_globalParams;
#define globalParams_0 (&SLANG_globalParams)
static __device__ float3  max_0(float3  x_0, float3  y_0)
{
    float3  result_0;
    int i_0 = int(0);
    for(;;)
    {
        if(i_0 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_0, i_0) = (F32_max((_slang_vector_get_element(x_0, i_0)), (_slang_vector_get_element(y_0, i_0))));
        i_0 = i_0 + int(1);
    }
    return result_0;
}

static __device__ float clamp_0(float x_1, float minBound_0, float maxBound_0)
{
    return (F32_min(((F32_max((x_1), (minBound_0)))), (maxBound_0)));
}

static __device__ uint4  asuint_0(float4  x_2)
{
    uint4  result_1;
    int i_1 = int(0);
    for(;;)
    {
        if(i_1 < int(4))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_1, i_1) = (F32_asuint((_slang_vector_get_element(x_2, i_1))));
        i_1 = i_1 + int(1);
    }
    return result_1;
}

static __device__ float dot_0(float3  x_3, float3  y_1)
{
    return x_3.x * y_1.x + x_3.y * y_1.y + x_3.z * y_1.z;
}

static __device__ float3  abs_0(float3  x_4)
{
    float3  result_2;
    int i_2 = int(0);
    for(;;)
    {
        if(i_2 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_2, i_2) = (F32_abs((_slang_vector_get_element(x_4, i_2))));
        i_2 = i_2 + int(1);
    }
    return result_2;
}

static __device__ float3  min_0(float3  x_5, float3  y_2)
{
    float3  result_3;
    int i_3 = int(0);
    for(;;)
    {
        if(i_3 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_3, i_3) = (F32_min((_slang_vector_get_element(x_5, i_3)), (_slang_vector_get_element(y_2, i_3))));
        i_3 = i_3 + int(1);
    }
    return result_3;
}

static __device__ float3  clamp_1(float3  x_6, float3  minBound_1, float3  maxBound_1)
{
    return min_0(max_0(x_6, minBound_1), maxBound_1);
}

static __device__ bool any_0(bool3  x_7)
{
    bool result_4 = false;
    int i_4 = int(0);
    for(;;)
    {
        if(i_4 < int(3))
        {
        }
        else
        {
            break;
        }
        if(result_4)
        {
            result_4 = true;
        }
        else
        {
            result_4 = (bool((_slang_vector_get_element(x_7, i_4))));
        }
        i_4 = i_4 + int(1);
    }
    return result_4;
}

static __device__ float3  cross_0(float3  left_0, float3  right_0)
{
    float _S1 = left_0.y;
    float _S2 = right_0.z;
    float _S3 = left_0.z;
    float _S4 = right_0.y;
    float _S5 = right_0.x;
    float _S6 = left_0.x;
    return make_float3 (_S1 * _S2 - _S3 * _S4, _S3 * _S5 - _S6 * _S2, _S6 * _S4 - _S1 * _S5);
}

static __device__ float length_0(float3  x_8)
{
    return (F32_sqrt((dot_0(x_8, x_8))));
}

static __device__ bool stopped_0()
{
    uint _S7 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint4  _S8 = (&(globalParams_0->islands_0)[_S7])->info_1;
    bool _S9;
    if((((&(globalParams_0->islands_0)[_S7])->info_1.z) & 1U) != 0U)
    {
        _S9 = true;
    }
    else
    {
        _S9 = (_S8.y) != 0U;
    }
    return _S9;
}

struct Quat_0
{
    float w_0;
    float x_9;
    float y_3;
    float z_0;
};

static __device__ Quat_0 quat_of_0(float4  q_0)
{
    Quat_0 r_0;
    (&r_0)->x_9 = q_0.x;
    (&r_0)->y_3 = q_0.y;
    (&r_0)->z_0 = q_0.z;
    (&r_0)->w_0 = q_0.w;
    return r_0;
}

static __device__ float3  rotate_0(Quat_0 * q_1, float3  v_0)
{
    float3  qv_0 = make_float3 (q_1->x_9, q_1->y_3, q_1->z_0);
    float3  t_0 = cross_0(qv_0, v_0) * make_float3 (2.0f);
    return v_0 + t_0 * make_float3 (q_1->w_0) + cross_0(qv_0, t_0);
}

struct WorldPoint_0
{
    float3  hi_0;
    float3  lo_0;
    float3  rel_0;
};

static __device__ WorldPoint_0 chunk_world_0(uint c_0)
{
    ChunkStatic_0 * _S10 = (&(globalParams_0->chunks_0)[c_0]);
    uint4  _S11 = __ldg(&_S10->info_0);
    Island_0 * _S12 = (&(globalParams_0->islands_0)[_S11.y]);
    Quat_0 q_2 = quat_of_0(_S12->rotation_0);
    WorldPoint_0 w_1;
    float4  _S13 = _S12->position_0;
    (&w_1)->hi_0 = float3 {_S13.x, _S13.y, _S13.z};
    float4  _S14 = _S12->position_err_0;
    (&w_1)->lo_0 = float3 {_S14.x, _S14.y, _S14.z};
    float4  _S15 = __ldg(&_S10->center_0);
    float4  _S16 = *(&(globalParams_0->state_0)[4U * c_0]);
    float3  _S17 = float3 {_S15.x, _S15.y, _S15.z} + float3 {_S16.x, _S16.y, _S16.z};
    Quat_0 _S18 = q_2;
    float3  _S19 = rotate_0(&_S18, _S17);
    (&w_1)->rel_0 = _S19;
    return w_1;
}

static __device__ float3  world_diff_0(WorldPoint_0 * a_0, WorldPoint_0 * b_0)
{
    return a_0->hi_0 - b_0->hi_0 + (a_0->lo_0 - b_0->lo_0) + (a_0->rel_0 - b_0->rel_0);
}

static __device__ float3  safe_normalize_0(float3  v_1)
{
    float n_0 = length_0(v_1);
    float3  _S20;
    if(n_0 > 1.00000000317107685e-30f)
    {
        _S20 = v_1 / make_float3 (n_0);
    }
    else
    {
        _S20 = make_float3 (0.0f);
    }
    return _S20;
}

static __device__ Quat_0 from_axis_angle_0(float3  axis_0, float angle_0)
{
    float3  a_1 = safe_normalize_0(axis_0);
    float _S21 = 0.5f * angle_0;
    float s_0 = (F32_sin((_S21)));
    Quat_0 q_3;
    (&q_3)->w_0 = (F32_cos((_S21)));
    (&q_3)->x_9 = a_1.x * s_0;
    (&q_3)->y_3 = a_1.y * s_0;
    (&q_3)->z_0 = a_1.z * s_0;
    return q_3;
}

struct Box_0
{
    float3  center_1;
    float3  axis0_0;
    float3  axis1_0;
    float3  axis2_0;
    float3  half_2;
    uint hull_at_0;
    uint hull_v_0;
    uint hull_f_0;
};

static __device__ Box_0 chunk_box_0(uint c_1, float3  center_2)
{
    ChunkStatic_0 * _S22 = (&(globalParams_0->chunks_0)[c_1]);
    uint4  _S23 = __ldg(&_S22->info_0);
    Quat_0 q_4 = quat_of_0((&(globalParams_0->islands_0)[_S23.y])->rotation_0);
    float4  _S24 = *(&(globalParams_0->state_0)[4U * c_1 + 1U]);
    float3  th_0 = float3 {_S24.x, _S24.y, _S24.z};
    Quat_0 hidden_0 = from_axis_angle_0(th_0, length_0(th_0));
    Box_0 b_1;
    (&b_1)->center_1 = center_2;
    float4  _S25 = __ldg(&_S22->crot0_0);
    float _S26 = _S25.x;
    float4  _S27 = __ldg(&_S22->crot1_0);
    float _S28 = _S27.x;
    float4  _S29 = __ldg(&_S22->crot2_0);
    float3  _S30 = make_float3 (_S26, _S28, _S29.x);
    Quat_0 _S31 = hidden_0;
    float3  _S32 = rotate_0(&_S31, _S30);
    Quat_0 _S33 = q_4;
    float3  _S34 = rotate_0(&_S33, _S32);
    (&b_1)->axis0_0 = _S34;
    float3  _S35 = make_float3 (_S25.y, _S27.y, _S29.y);
    Quat_0 _S36 = hidden_0;
    float3  _S37 = rotate_0(&_S36, _S35);
    Quat_0 _S38 = q_4;
    float3  _S39 = rotate_0(&_S38, _S37);
    (&b_1)->axis1_0 = _S39;
    float3  _S40 = make_float3 (_S25.z, _S27.z, _S29.z);
    Quat_0 _S41 = hidden_0;
    float3  _S42 = rotate_0(&_S41, _S40);
    Quat_0 _S43 = q_4;
    float3  _S44 = rotate_0(&_S43, _S42);
    (&b_1)->axis2_0 = _S44;
    float4  _S45 = __ldg(&_S22->half_0);
    (&b_1)->half_2 = float3 {_S45.x, _S45.y, _S45.z};
    float4  _S46 = __ldg(&_S22->cmat_0);
    (&b_1)->hull_at_0 = (F32_asuint((_S46.z)));
    uint _S47 = (F32_asuint((_S46.w)));
    (&b_1)->hull_v_0 = _S47 & 255U;
    (&b_1)->hull_f_0 = _S47 >> int(8);
    return b_1;
}

static __device__ uint sample_count_0(Box_0 * b_2)
{
    uint _S48 = b_2->hull_v_0;
    uint _S49;
    if((b_2->hull_v_0) == 0U)
    {
        _S49 = 14U;
    }
    else
    {
        _S49 = _S48 + b_2->hull_f_0;
    }
    return _S49;
}

static __device__ bool may_overlap_0(Box_0 * a_2, Box_0 * b_3)
{
    float3  _S50 = b_3->center_1 - a_2->center_1;
    float3  _S51 = a_2->half_2;
    float3  _S52 = b_3->half_2;
    float _S53 = 0.00000999999974738f * (length_0(a_2->half_2) + length_0(b_3->half_2));
    float3  _S54 = a_2->axis0_0;
    float3  _S55 = a_2->axis1_0;
    float3  _S56 = a_2->axis2_0;
    float3  _S57 = b_3->axis0_0;
    float3  _S58 = b_3->axis1_0;
    float3  _S59 = b_3->axis2_0;
    FixedArray<float3 , 6>  _S60 = { {
        a_2->axis0_0, a_2->axis1_0, a_2->axis2_0, b_3->axis0_0, b_3->axis1_0, b_3->axis2_0
    } };
    uint i_5 = 0U;
    for(;;)
    {
        if(i_5 < 15U)
        {
        }
        else
        {
            break;
        }
        float3  l_0;
        if(i_5 < 6U)
        {
            l_0 = _S60[i_5];
        }
        else
        {
            uint _S61 = i_5 - 6U;
            l_0 = cross_0(_S60[_S61 / 3U], _S60[3U + _S61 % 3U]);
        }
        float len_0 = length_0(l_0);
        if(len_0 <= 9.99999997475242708e-07f)
        {
            i_5 = i_5 + 1U;
            continue;
        }
        if((F32_abs((dot_0(_S50, l_0)))) > (_S51.x * (F32_abs((dot_0(_S54, l_0)))) + _S51.y * (F32_abs((dot_0(_S55, l_0)))) + _S51.z * (F32_abs((dot_0(_S56, l_0)))) + (_S52.x * (F32_abs((dot_0(_S57, l_0)))) + _S52.y * (F32_abs((dot_0(_S58, l_0)))) + _S52.z * (F32_abs((dot_0(_S59, l_0))))) + _S53 * len_0))
        {
            return false;
        }
        i_5 = i_5 + 1U;
    }
    return true;
}

static __device__ void chunk_velocity_0(uint c_2, float3  * v_2, float3  * w_2)
{
    ChunkStatic_0 * _S62 = (&(globalParams_0->chunks_0)[c_2]);
    uint4  _S63 = __ldg(&_S62->info_0);
    Island_0 * _S64 = (&(globalParams_0->islands_0)[_S63.y]);
    Quat_0 q_5 = quat_of_0(_S64->rotation_0);
    float4  _S65 = __ldg(&_S62->center_0);
    uint _S66 = 4U * c_2;
    float4  _S67 = *(&(globalParams_0->state_0)[_S66]);
    float4  _S68 = _S64->com_0;
    float3  _S69 = float3 {_S65.x, _S65.y, _S65.z} + float3 {_S67.x, _S67.y, _S67.z} - float3 {_S68.x, _S68.y, _S68.z};
    Quat_0 _S70 = q_5;
    float3  _S71 = rotate_0(&_S70, _S69);
    float4  _S72 = _S64->velocity_0;
    float4  _S73 = _S64->velocity_err_0;
    float4  _S74 = _S64->angular_velocity_0;
    float3  _S75 = float3 {_S74.x, _S74.y, _S74.z};
    float3  _S76 = float3 {_S72.x, _S72.y, _S72.z} + float3 {_S73.x, _S73.y, _S73.z} + cross_0(_S75, _S71);
    float4  _S77 = *(&(globalParams_0->state_0)[_S66 + 2U]);
    float3  _S78 = float3 {_S77.x, _S77.y, _S77.z};
    Quat_0 _S79 = q_5;
    float3  _S80 = rotate_0(&_S79, _S78);
    *v_2 = _S76 + _S80;
    float4  _S81 = *(&(globalParams_0->state_0)[_S66 + 3U]);
    float3  _S82 = float3 {_S81.x, _S81.y, _S81.z};
    Quat_0 _S83 = q_5;
    float3  _S84 = rotate_0(&_S83, _S82);
    *w_2 = _S75 + _S84;
    return;
}

static __device__ float3  box_to_world_0(Box_0 * b_4, float3  local_0)
{
    return b_4->axis0_0 * make_float3 (local_0.x) + b_4->axis1_0 * make_float3 (local_0.y) + b_4->axis2_0 * make_float3 (local_0.z);
}

static __device__ float3  box_axis_0(Box_0 * b_5, uint k_0)
{
    float3  _S85;
    if(k_0 == 0U)
    {
        _S85 = b_5->axis0_0;
    }
    else
    {
        if(k_0 == 1U)
        {
            _S85 = b_5->axis1_0;
        }
        else
        {
            _S85 = b_5->axis2_0;
        }
    }
    return _S85;
}

static __device__ float comp3_0(float3  v_3, uint k_1)
{
    float _S86;
    if(k_1 == 0U)
    {
        _S86 = v_3.x;
    }
    else
    {
        if(k_1 == 1U)
        {
            _S86 = v_3.y;
        }
        else
        {
            _S86 = v_3.z;
        }
    }
    return _S86;
}

static __device__ float3  sample_point_0(Box_0 * b_6, uint i_6)
{
    uint _S87 = b_6->hull_v_0;
    if((b_6->hull_v_0) != 0U)
    {
        float3  local_1;
        if(i_6 < _S87)
        {
            float4  _S88 = __ldg((&(globalParams_0->loads_0)[b_6->hull_at_0 + i_6]));
            local_1 = float3 {_S88.x, _S88.y, _S88.z} * make_float3 (0.89999997615814209f);
        }
        else
        {
            float4  _S89 = __ldg((&(globalParams_0->loads_0)[b_6->hull_at_0 + _S87 + b_6->hull_f_0 + (i_6 - _S87)]));
            local_1 = float3 {_S89.x, _S89.y, _S89.z};
        }
        float3  _S90 = b_6->center_1;
        float3  _S91 = box_to_world_0(b_6, local_1);
        return _S90 + _S91;
    }
    float sign_0;
    if(i_6 < 8U)
    {
        float3  h_0 = b_6->half_2 * make_float3 (0.89999997615814209f);
        if((i_6 & 1U) == 0U)
        {
            sign_0 = - h_0.x;
        }
        else
        {
            sign_0 = h_0.x;
        }
        float _S92;
        if((i_6 & 2U) == 0U)
        {
            _S92 = - h_0.y;
        }
        else
        {
            _S92 = h_0.y;
        }
        float _S93;
        if((i_6 & 4U) == 0U)
        {
            _S93 = - h_0.z;
        }
        else
        {
            _S93 = h_0.z;
        }
        return b_6->center_1 + b_6->axis0_0 * make_float3 (sign_0) + b_6->axis1_0 * make_float3 (_S92) + b_6->axis2_0 * make_float3 (_S93);
    }
    uint _S94 = i_6 - 8U;
    uint axis_1 = _S94 / 2U;
    if((_S94 % 2U) == 0U)
    {
        sign_0 = -1.0f;
    }
    else
    {
        sign_0 = 1.0f;
    }
    float3  _S95 = b_6->center_1;
    float3  _S96 = box_axis_0(b_6, axis_1);
    return _S95 + _S96 * make_float3 (sign_0 * comp3_0(b_6->half_2, axis_1));
}

static __device__ float3  box_to_local_0(Box_0 * b_7, float3  r_1)
{
    return make_float3 (dot_0(r_1, b_7->axis0_0), dot_0(r_1, b_7->axis1_0), dot_0(r_1, b_7->axis2_0));
}

static __device__ float hull_signed_distance_0(Box_0 * b_8, float3  local_2, uint * face_0)
{
    *face_0 = 0U;
    float best_0 = -1.00000001504746622e+30f;
    uint f_0 = 0U;
    for(;;)
    {
        if(f_0 < (b_8->hull_f_0))
        {
        }
        else
        {
            break;
        }
        float4  _S97 = __ldg((&(globalParams_0->loads_0)[b_8->hull_at_0 + b_8->hull_v_0 + f_0]));
        float d_0 = dot_0(float3 {_S97.x, _S97.y, _S97.z}, local_2) - _S97.w;
        if(d_0 > best_0)
        {
            *face_0 = f_0;
            best_0 = d_0;
        }
        f_0 = f_0 + 1U;
    }
    return best_0;
}

static __device__ bool penetration_0(Box_0 * b_9, float3  p_0, float * depth_0, float3  * normal_1)
{
    *depth_0 = 0.0f;
    *normal_1 = make_float3 (0.0f);
    float3  r_2 = p_0 - b_9->center_1;
    float3  _S98 = b_9->half_2;
    if((dot_0(r_2, r_2)) > (dot_0(b_9->half_2, b_9->half_2) * 1.00001001358032227f))
    {
        return false;
    }
    uint _S99 = b_9->hull_v_0;
    if((b_9->hull_v_0) != 0U)
    {
        float3  _S100 = box_to_local_0(b_9, r_2);
        uint face_1;
        float _S101 = hull_signed_distance_0(b_9, _S100, &face_1);
        if(!(_S101 < 0.0f))
        {
            return false;
        }
        *depth_0 = - _S101;
        float4  _S102 = __ldg((&(globalParams_0->loads_0)[b_9->hull_at_0 + _S99 + face_1]));
        float3  _S103 = box_to_world_0(b_9, float3 {_S102.x, _S102.y, _S102.z});
        *normal_1 = _S103;
        return true;
    }
    float best_1 = 1.00000001504746622e+30f;
    uint axis_2 = 0U;
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
        float3  _S104 = box_axis_0(b_9, k_2);
        float local_3 = dot_0(r_2, _S104);
        float d_1 = comp3_0(_S98, k_2) - (F32_abs((local_3)));
        if(d_1 <= 0.0f)
        {
            return false;
        }
        if(d_1 < best_1)
        {
            float _S105;
            if(local_3 >= 0.0f)
            {
                _S105 = 1.0f;
            }
            else
            {
                _S105 = -1.0f;
            }
            best_1 = d_1;
            axis_2 = k_2;
            side_0 = _S105;
        }
        k_2 = k_2 + 1U;
    }
    *depth_0 = best_1;
    float3  _S106 = box_axis_0(b_9, axis_2);
    *normal_1 = _S106 * make_float3 (side_0);
    return true;
}

static __device__ bool pair_point_0(Box_0 * ba_0, Box_0 * bb_0, uint na_0, uint e_0, float3  * p_1, float3  * n_1, float * d_2)
{
    if(e_0 < na_0)
    {
        float3  _S107 = sample_point_0(ba_0, e_0);
        *p_1 = _S107;
        bool _S108 = penetration_0(bb_0, _S107, d_2, n_1);
        return _S108;
    }
    float3  _S109 = sample_point_0(bb_0, e_0 - na_0);
    *p_1 = _S109;
    bool _S110 = penetration_0(ba_0, _S109, d_2, n_1);
    if(!_S110)
    {
        return false;
    }
    *n_1 = - *n_1;
    return true;
}

static __device__ bool is_nan_0(float x_10)
{
    return ((F32_asuint((x_10))) & 2147483647U) > 2139095040U;
}

static __device__ float2  half_thickness_and_area_0(Box_0 * b_10, float3  d_3)
{
    uint k_3 = 0U;
    float h_1 = 0.0f;
    float area_0 = 0.0f;
    for(;;)
    {
        if(k_3 < 3U)
        {
        }
        else
        {
            break;
        }
        float3  _S111 = box_axis_0(b_10, k_3);
        float c_3 = (F32_abs((dot_0(d_3, _S111))));
        float h_2 = h_1 + c_3 * comp3_0(b_10->half_2, k_3);
        uint _S112 = k_3 + 1U;
        float area_1 = area_0 + c_3 * 4.0f * comp3_0(b_10->half_2, _S112 % 3U) * comp3_0(b_10->half_2, (k_3 + 2U) % 3U);
        k_3 = _S112;
        h_1 = h_2;
        area_0 = area_1;
    }
    return make_float2 (h_1, area_0);
}

static __device__ float contact_stiffness_0(float ea_0, Box_0 * a_3, float eb_0, Box_0 * b_11, float3  dir_0)
{
    float3  d_4 = safe_normalize_0(dir_0);
    float2  _S113 = half_thickness_and_area_0(a_3, d_4);
    float2  _S114 = half_thickness_and_area_0(b_11, d_4);
    return (F32_min((_S113.y), (_S114.y))) / (_S113.x / ea_0 + _S114.x / eb_0);
}

static __device__ float3  penalty_force_0(float k_4, float m_red_0, float friction_0, float depth_1, float3  normal_2, float3  rel_velocity_0, float dt_1, uint points_0, float * stored_0, float * dissipated_1)
{
    float c_max_0 = 1.0f / (F32_max((float(points_0)), (10.0f))) * m_red_0 / dt_1;
    float _S115 = __ldg(&globalParams_0->params_0->zeta_0);
    float vn_0 = dot_0(rel_velocity_0, normal_2);
    float _S116 = k_4 * depth_1;
    float _S117 = (F32_min((2.0f * _S115 * (F32_sqrt((k_4 * m_red_0)))), (c_max_0))) * vn_0;
    float _S118 = _S116 - _S117;
    float _S119 = (F32_max((_S118), (0.0f)));
    float3  vt_0 = rel_velocity_0 - normal_2 * make_float3 (vn_0);
    float vt_mag_0 = length_0(vt_0);
    float _S120 = friction_0 * _S119;
    float _S121 = (F32_min((_S120), ((F32_min((c_max_0), (_S120 / 0.00100000004749745f))) * vt_mag_0)));
    float3  ft_0;
    if(vt_mag_0 > 0.0f)
    {
        ft_0 = - vt_0 * make_float3 (_S121 / vt_mag_0);
    }
    else
    {
        ft_0 = make_float3 (0.0f);
    }
    *stored_0 = 0.5f * k_4 * depth_1 * depth_1;
    float damping_power_0;
    if(_S118 > 0.0f)
    {
        damping_power_0 = _S117 * vn_0;
    }
    else
    {
        damping_power_0 = _S116 * (F32_max((vn_0), (0.0f)));
    }
    *dissipated_1 = (damping_power_0 + length_0(ft_0) * vt_mag_0) * dt_1;
    return normal_2 * make_float3 (_S119) + ft_0;
}

static __device__ void comp_add1_0(float * sum_0, float * err_0, float x_11)
{
    float t_1 = *sum_0 + x_11;
    if((F32_abs((*sum_0))) >= (F32_abs((x_11))))
    {
        *err_0 = *err_0 + (*sum_0 - t_1 + x_11);
    }
    else
    {
        *err_0 = *err_0 + (x_11 - t_1 + *sum_0);
    }
    *sum_0 = t_1;
    return;
}

static __device__ void pair_contact_0(uint i_7)
{
    uint _S122 = __ldg(&globalParams_0->params_0->pair_index_0);
    uint at_0 = _S122 + 6U * i_7;
    uint _S123 = __ldg((&(globalParams_0->index_0)[at_0]));
    uint _S124 = __ldg((&(globalParams_0->index_0)[at_0 + 1U]));
    uint _S125 = __ldg((&(globalParams_0->index_0)[at_0 + 2U]));
    uint _S126 = __ldg((&(globalParams_0->index_0)[at_0 + 3U]));
    uint _S127 = __ldg((&(globalParams_0->index_0)[at_0 + 4U]));
    float _S128 = (U32_asfloat((_S127)));
    uint _S129 = __ldg((&(globalParams_0->index_0)[at_0 + 5U]));
    float _S130 = (U32_asfloat((_S129)));
    float _S131 = __ldg(&globalParams_0->params_0->dt_0);
    uint _S132 = __ldg(&globalParams_0->params_0->slot_base_0);
    uint out_0 = _S132 + 2U * _S125;
    WorldPoint_0 wa_0 = chunk_world_0(_S123);
    WorldPoint_0 _S133 = chunk_world_0(_S124);
    WorldPoint_0 _S134 = wa_0;
    float3  _S135 = world_diff_0(&_S133, &_S134);
    float _S136 = length_0(_S135);
    float4  _S137 = __ldg(&(&(globalParams_0->chunks_0)[_S123])->half_0);
    float _S138 = _S137.w;
    float4  _S139 = __ldg(&(&(globalParams_0->chunks_0)[_S124])->half_0);
    bool touching_0 = !(_S136 > (_S138 + _S139.w));
    uint _S140 = __ldg(&globalParams_0->params_0->ledger_base_0);
    float4  * _S141 = (&(globalParams_0->scratch_0)[_S140 + i_7]);
    float4  ledger_1 = *_S141;
    uint flags_0 = (F32_asuint(((*_S141).w)));
    float3  _S142 = make_float3 (0.0f);
    Box_0 ba_1 = chunk_box_0(_S123, _S142);
    Box_0 bb_1 = chunk_box_0(_S124, _S135);
    Box_0 _S143 = ba_1;
    uint _S144 = sample_count_0(&_S143);
    Box_0 _S145 = bb_1;
    uint _S146 = sample_count_0(&_S145);
    uint _S147 = _S144 + _S146;
    uint e_1;
    bool has_state_0;
    if(!touching_0)
    {
        if((flags_0 & 1U) != 0U)
        {
            e_1 = 0U;
            for(;;)
            {
                if(e_1 < _S147)
                {
                }
                else
                {
                    break;
                }
                *(&(globalParams_0->contact_state_0)[_S126 + e_1]) = make_float4 ((U32_asfloat((2143289344U))), 0.0f, 0.0f, 0.0f);
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
                *(&(globalParams_0->scratch_0)[out_0 + e_1]) = make_float4 (0.0f);
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
            *&((&ledger_1)->x) = 0.0f;
            *&((&ledger_1)->w) = (U32_asfloat((0U)));
            uint _S148 = __ldg(&globalParams_0->params_0->ledger_base_0);
            *(&(globalParams_0->scratch_0)[_S148 + i_7]) = ledger_1;
        }
        return;
    }
    Box_0 _S149 = ba_1;
    Box_0 _S150 = bb_1;
    bool _S151 = may_overlap_0(&_S149, &_S150);
    uint count_0;
    float3  fa_0;
    float3  ta_0;
    float3  fb_0;
    float3  tb_0;
    float stored_sum_0;
    if(_S151)
    {
        float3  va0_0;
        float3  wa0_0;
        chunk_velocity_0(_S123, &va0_0, &wa0_0);
        float3  vb0_0;
        float3  wb0_0;
        chunk_velocity_0(_S124, &vb0_0, &wb0_0);
        e_1 = 0U;
        count_0 = 0U;
        uint engaged_0 = 0U;
        for(;;)
        {
            if(e_1 < _S147)
            {
            }
            else
            {
                break;
            }
            Box_0 _S152 = ba_1;
            Box_0 _S153 = bb_1;
            float3  p_2;
            float3  n_2;
            float d_5;
            bool _S154 = pair_point_0(&_S152, &_S153, _S144, e_1, &p_2, &n_2, &d_5);
            if(!_S154)
            {
                uint _S155 = _S126 + e_1;
                if(!is_nan_0((*(&(globalParams_0->contact_state_0)[_S155])).x))
                {
                    *(&(globalParams_0->contact_state_0)[_S155]) = make_float4 ((U32_asfloat((2143289344U))), 0.0f, 0.0f, 0.0f);
                }
                e_1 = e_1 + 1U;
                continue;
            }
            uint _S156 = count_0 + 1U;
            uint _S157 = _S126 + e_1;
            float4  * _S158 = (&(globalParams_0->contact_state_0)[_S157]);
            float4  entry_0 = *_S158;
            if(is_nan_0((*_S158).x))
            {
                has_state_0 = true;
            }
            else
            {
                float4  _S159 = entry_0;
                has_state_0 = (dot_0(float3 {_S159.y, _S159.z, _S159.w}, n_2)) < 0.99000000953674316f;
            }
            if(has_state_0)
            {
                if(d_5 > (2.0f * (F32_abs((dot_0(va0_0 + cross_0(wa0_0, p_2) - (vb0_0 + cross_0(wb0_0, p_2 - bb_1.center_1)), n_2)))) * _S131 + 9.99999971718068537e-10f))
                {
                    stored_sum_0 = d_5;
                }
                else
                {
                    stored_sum_0 = 0.0f;
                }
                entry_0 = make_float4 (stored_sum_0, n_2.x, n_2.y, n_2.z);
            }
            *&((&entry_0)->x) = (F32_min((entry_0.x), (d_5)));
            *(&(globalParams_0->contact_state_0)[_S157]) = entry_0;
            uint engaged_1;
            if((d_5 - entry_0.x) > 0.0f)
            {
                engaged_1 = engaged_0 + 1U;
            }
            else
            {
                engaged_1 = engaged_0;
            }
            count_0 = _S156;
            engaged_0 = engaged_1;
            e_1 = e_1 + 1U;
        }
        if(count_0 > 0U)
        {
            float4  _S160 = __ldg(&(&(globalParams_0->chunks_0)[_S123])->cmat_0);
            float _S161 = _S160.x;
            float4  _S162 = __ldg(&(&(globalParams_0->chunks_0)[_S124])->cmat_0);
            float _S163 = _S162.x;
            float3  _S164 = bb_1.center_1 - ba_1.center_1;
            Box_0 _S165 = ba_1;
            Box_0 _S166 = bb_1;
            float _S167 = contact_stiffness_0(_S161, &_S165, _S163, &_S166, _S164);
            float _S168 = _S167 / (F32_max((float(engaged_0)), (10.0f)));
            e_1 = 0U;
            fa_0 = _S142;
            ta_0 = _S142;
            fb_0 = _S142;
            tb_0 = _S142;
            stored_sum_0 = 0.0f;
            for(;;)
            {
                if(e_1 < _S147)
                {
                }
                else
                {
                    break;
                }
                Box_0 _S169 = ba_1;
                Box_0 _S170 = bb_1;
                float3  p_3;
                float3  n_3;
                float d_6;
                bool _S171 = pair_point_0(&_S169, &_S170, _S144, e_1, &p_3, &n_3, &d_6);
                if(!_S171)
                {
                    e_1 = e_1 + 1U;
                    continue;
                }
                float eff_0 = d_6 - (*(&(globalParams_0->contact_state_0)[_S126 + e_1])).x;
                if(eff_0 <= 0.0f)
                {
                    e_1 = e_1 + 1U;
                    continue;
                }
                float stored_1;
                float diss_0;
                float3  f_1 = penalty_force_0(_S168, _S128, _S130, eff_0, n_3, va0_0 + cross_0(wa0_0, p_3) - (vb0_0 + cross_0(wb0_0, p_3 - bb_1.center_1)), _S131, engaged_0, &stored_1, &diss_0);
                float3  fa_1 = fa_0 + f_1;
                float3  ta_1 = ta_0 + cross_0(p_3, f_1);
                float3  _S172 = - f_1;
                float3  fb_1 = fb_0 + _S172;
                float3  tb_1 = tb_0 + cross_0(p_3 - bb_1.center_1, _S172);
                float stored_sum_1 = stored_sum_0 + stored_1;
                comp_add1_0(&((&ledger_1)->y), &((&ledger_1)->z), diss_0);
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
            fa_0 = _S142;
            ta_0 = _S142;
            fb_0 = _S142;
            tb_0 = _S142;
            stored_sum_0 = 0.0f;
        }
    }
    else
    {
        has_state_0 = false;
        fa_0 = _S142;
        ta_0 = _S142;
        fb_0 = _S142;
        tb_0 = _S142;
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
            if(e_1 < _S147)
            {
            }
            else
            {
                break;
            }
            *(&(globalParams_0->contact_state_0)[_S126 + e_1]) = make_float4 ((U32_asfloat((2143289344U))), 0.0f, 0.0f, 0.0f);
            e_1 = e_1 + 1U;
        }
    }
    if(any_0(fa_0 != make_float3 (0.0f)))
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any_0(ta_0 != make_float3 (0.0f));
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any_0(fb_0 != make_float3 (0.0f));
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any_0(tb_0 != make_float3 (0.0f));
    }
    bool _S173;
    if(loaded_0)
    {
        _S173 = true;
    }
    else
    {
        _S173 = (flags_0 & 2U) != 0U;
    }
    if(_S173)
    {
        *(&(globalParams_0->scratch_0)[out_0]) = make_float4 (fa_0.x, fa_0.y, fa_0.z, 0.0f);
        *(&(globalParams_0->scratch_0)[out_0 + 1U]) = make_float4 (ta_0.x, ta_0.y, ta_0.z, 0.0f);
        *(&(globalParams_0->scratch_0)[out_0 + 2U]) = make_float4 (fb_0.x, fb_0.y, fb_0.z, 0.0f);
        *(&(globalParams_0->scratch_0)[out_0 + 3U]) = make_float4 (tb_0.x, tb_0.y, tb_0.z, 0.0f);
    }
    *&((&ledger_1)->x) = stored_sum_0;
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
    *&((&ledger_1)->w) = (U32_asfloat((e_1 | count_0)));
    uint _S174 = __ldg(&globalParams_0->params_0->ledger_base_0);
    *(&(globalParams_0->scratch_0)[_S174 + i_7]) = ledger_1;
    return;
}

static __device__ Box_0 impactor_box_0(Impactor_0 * imp_0, float3  center_3, float3  half_3)
{
    Quat_0 q_6 = quat_of_0(imp_0->rotation_1);
    Box_0 b_12;
    (&b_12)->center_1 = center_3;
    float3  _S175 = make_float3 (1.0f, 0.0f, 0.0f);
    Quat_0 _S176 = q_6;
    float3  _S177 = rotate_0(&_S176, _S175);
    (&b_12)->axis0_0 = _S177;
    float3  _S178 = make_float3 (0.0f, 1.0f, 0.0f);
    Quat_0 _S179 = q_6;
    float3  _S180 = rotate_0(&_S179, _S178);
    (&b_12)->axis1_0 = _S180;
    float3  _S181 = make_float3 (0.0f, 0.0f, 1.0f);
    Quat_0 _S182 = q_6;
    float3  _S183 = rotate_0(&_S182, _S181);
    (&b_12)->axis2_0 = _S183;
    (&b_12)->half_2 = half_3;
    (&b_12)->hull_at_0 = 0U;
    (&b_12)->hull_v_0 = 0U;
    (&b_12)->hull_f_0 = 0U;
    return b_12;
}

static __device__ uint impactor_slots_0(Impactor_0 * imp_1, Box_0 * b_13)
{
    uint _S184;
    if((imp_1->shape_0.x) == 0.0f)
    {
        _S184 = 1U;
    }
    else
    {
        uint _S185 = sample_count_0(b_13);
        _S184 = _S185 + 14U;
    }
    return _S184;
}

static __device__ bool sphere_contact_0(Box_0 * b_14, float3  center_4, float radius_0, float3  * point_0, float3  * normal_3, float * depth_2)
{
    float3  _S186 = make_float3 (0.0f);
    *point_0 = _S186;
    *normal_3 = _S186;
    *depth_2 = 0.0f;
    float3  _S187 = b_14->center_1;
    float3  r_3 = center_4 - b_14->center_1;
    float3  _S188 = b_14->axis0_0;
    float3  _S189 = b_14->axis1_0;
    float3  _S190 = b_14->axis2_0;
    float3  local_4 = make_float3 (dot_0(r_3, b_14->axis0_0), dot_0(r_3, b_14->axis1_0), dot_0(r_3, b_14->axis2_0));
    uint _S191 = b_14->hull_v_0;
    if((b_14->hull_v_0) != 0U)
    {
        uint face_2;
        float _S192 = hull_signed_distance_0(b_14, local_4, &face_2);
        if(_S192 >= radius_0)
        {
            return false;
        }
        float4  _S193 = __ldg((&(globalParams_0->loads_0)[b_14->hull_at_0 + _S191 + face_2]));
        float3  _S194 = box_to_world_0(b_14, float3 {_S193.x, _S193.y, _S193.z});
        *normal_3 = _S194;
        *point_0 = center_4 - _S194 * make_float3 ((F32_max((_S192), (0.0f))));
        *depth_2 = radius_0 - _S192;
        return true;
    }
    float3  q_7 = clamp_1(local_4, - b_14->half_2, b_14->half_2);
    float3  d_7 = local_4 - q_7;
    float dist_0 = length_0(d_7);
    if(dist_0 > 9.999999960041972e-13f)
    {
        if(dist_0 >= radius_0)
        {
            return false;
        }
        float3  dn_0 = d_7 / make_float3 (dist_0);
        *normal_3 = _S188 * make_float3 (dn_0.x) + _S189 * make_float3 (dn_0.y) + _S190 * make_float3 (dn_0.z);
        *point_0 = _S187 + _S188 * make_float3 (q_7.x) + _S189 * make_float3 (q_7.y) + _S190 * make_float3 (q_7.z);
        *depth_2 = radius_0 - dist_0;
        return true;
    }
    float inside_0;
    float3  n_4;
    bool _S195 = penetration_0(b_14, center_4, &inside_0, &n_4);
    if(!_S195)
    {
        return false;
    }
    *normal_3 = n_4;
    *point_0 = center_4 - n_4 * make_float3 ((F32_min((radius_0), (inside_0))));
    *depth_2 = radius_0 + inside_0;
    return true;
}

static __device__ bool impactor_contact_0(Impactor_0 * imp_2, float crush_depth_0, Box_0 * shrunk_0, Box_0 * b_15, uint j_0, float3  * p_4, float3  * n_5, float * d_8)
{
    float3  _S196 = make_float3 (0.0f);
    *p_4 = _S196;
    *n_5 = _S196;
    *d_8 = 0.0f;
    float4  _S197 = imp_2->shape_0;
    if((imp_2->shape_0.x) == 0.0f)
    {
        bool _S198 = sphere_contact_0(b_15, _S196, _S197.y - crush_depth_0, p_4, n_5, d_8);
        if(!_S198)
        {
            return false;
        }
        *n_5 = - *n_5;
        return true;
    }
    uint _S199 = sample_count_0(b_15);
    if(j_0 < _S199)
    {
        float3  _S200 = sample_point_0(b_15, j_0);
        *p_4 = _S200;
        bool _S201 = penetration_0(shrunk_0, _S200, d_8, n_5);
        return _S201;
    }
    float3  _S202 = sample_point_0(shrunk_0, j_0 - _S199);
    *p_4 = _S202;
    bool _S203 = penetration_0(b_15, _S202, d_8, n_5);
    if(!_S203)
    {
        return false;
    }
    *n_5 = - *n_5;
    return true;
}

static __device__ WorldPoint_0 impactor_point_0(uint _S204)
{
    Impactor_0 * _S205 = (&(globalParams_0->impactors_0)[_S204]);
    WorldPoint_0 wi_0;
    float4  _S206 = _S205->position_1;
    (&wi_0)->hi_0 = float3 {_S206.x, _S206.y, _S206.z};
    float4  _S207 = _S205->position_err_1;
    (&wi_0)->lo_0 = float3 {_S207.x, _S207.y, _S207.z};
    (&wi_0)->rel_0 = make_float3 (0.0f);
    return wi_0;
}

static __device__ Box_0 impactor_box_1(uint _S208, float3  _S209, float3  _S210)
{
    Quat_0 q_8 = quat_of_0((&(globalParams_0->impactors_0)[_S208])->rotation_1);
    Box_0 b_16;
    (&b_16)->center_1 = _S209;
    float3  _S211 = make_float3 (1.0f, 0.0f, 0.0f);
    Quat_0 _S212 = q_8;
    float3  _S213 = rotate_0(&_S212, _S211);
    (&b_16)->axis0_0 = _S213;
    float3  _S214 = make_float3 (0.0f, 1.0f, 0.0f);
    Quat_0 _S215 = q_8;
    float3  _S216 = rotate_0(&_S215, _S214);
    (&b_16)->axis1_0 = _S216;
    float3  _S217 = make_float3 (0.0f, 0.0f, 1.0f);
    Quat_0 _S218 = q_8;
    float3  _S219 = rotate_0(&_S218, _S217);
    (&b_16)->axis2_0 = _S219;
    (&b_16)->half_2 = _S210;
    (&b_16)->hull_at_0 = 0U;
    (&b_16)->hull_v_0 = 0U;
    (&b_16)->hull_f_0 = 0U;
    return b_16;
}

static __device__ Box_0 impactor_shrunk_0(uint _S220, float _S221, Box_0 * _S222)
{
    Box_0 shrunk_1 = *_S222;
    (&shrunk_1)->half_2 = _S222->half_2 - min_0(make_float3 (_S221), _S222->half_2 * make_float3 (0.5f));
    return shrunk_1;
}

static __device__ bool impactor_contact_1(uint _S223, float _S224, Box_0 * _S225, Box_0 * _S226, uint _S227, float3  * _S228, float3  * _S229, float * _S230)
{
    Impactor_0 _S231 = *(&(globalParams_0->impactors_0)[_S223]);
    float3  _S232 = make_float3 (0.0f);
    *_S228 = _S232;
    *_S229 = _S232;
    *_S230 = 0.0f;
    if((_S231.shape_0.x) == 0.0f)
    {
        bool _S233 = sphere_contact_0(_S226, _S232, _S231.shape_0.y - _S224, _S228, _S229, _S230);
        if(!_S233)
        {
            return false;
        }
        *_S229 = - *_S229;
        return true;
    }
    uint _S234 = sample_count_0(_S226);
    if(_S227 < _S234)
    {
        float3  _S235 = sample_point_0(_S226, _S227);
        *_S228 = _S235;
        bool _S236 = penetration_0(_S225, _S235, _S230, _S229);
        return _S236;
    }
    float3  _S237 = sample_point_0(_S225, _S227 - _S234);
    *_S228 = _S237;
    bool _S238 = penetration_0(_S226, _S237, _S230, _S229);
    if(!_S238)
    {
        return false;
    }
    *_S229 = - *_S229;
    return true;
}

static __device__ uint impactor_contact_count_0(uint _S239, float _S240, Box_0 * _S241, Box_0 * _S242)
{
    Impactor_0 _S243 = *(&(globalParams_0->impactors_0)[_S239]);
    uint j_1 = 0U;
    uint count_1 = 0U;
    for(;;)
    {
        Impactor_0 _S244 = _S243;
        uint _S245 = impactor_slots_0(&_S244, _S242);
        if(j_1 < _S245)
        {
        }
        else
        {
            break;
        }
        float3  p_5;
        float3  n_6;
        float d_9;
        bool _S246 = impactor_contact_1(_S239, _S240, _S241, _S242, j_1, &p_5, &n_6, &d_9);
        if(_S246)
        {
            count_1 = count_1 + 1U;
        }
        j_1 = j_1 + 1U;
    }
    return count_1;
}

static __device__ void impactor_candidate_forces_0(uint k_5)
{
    uint _S247 = __ldg(&globalParams_0->params_0->cand_index_0);
    uint _S248 = 3U * k_5;
    uint at_1 = _S247 + _S248;
    uint _S249 = __ldg((&(globalParams_0->index_0)[at_1]));
    uint _S250 = __ldg((&(globalParams_0->index_0)[at_1 + 1U]));
    uint _S251 = __ldg((&(globalParams_0->index_0)[at_1 + 2U]));
    Impactor_0 imp_3 = *(&(globalParams_0->impactors_0)[_S251]);
    float _S252 = __ldg(&globalParams_0->params_0->dt_0);
    float3  _S253 = make_float3 (0.0f);
    uint _S254 = __ldg(&globalParams_0->params_0->cand_base_0);
    float4  data_0 = *(&(globalParams_0->scratch_0)[_S254 + _S248]);
    float3  f_sum_0;
    float3  t_sum_0;
    float3  imp_f_0;
    float3  imp_t_0;
    if((imp_3.cand_0.z) == 0U)
    {
        WorldPoint_0 _S255 = impactor_point_0(_S251);
        WorldPoint_0 _S256 = chunk_world_0(_S249);
        WorldPoint_0 _S257 = _S255;
        float3  _S258 = world_diff_0(&_S256, &_S257);
        float _S259 = length_0(_S258);
        float _S260 = imp_3.half_1.w;
        float4  _S261 = __ldg(&(&(globalParams_0->chunks_0)[_S249])->half_0);
        if(!(_S259 > (_S260 + _S261.w)))
        {
            float4  _S262 = imp_3.half_1;
            Box_0 _S263 = impactor_box_1(_S251, _S253, float3 {_S262.x, _S262.y, _S262.z});
            Box_0 b_17 = chunk_box_0(_S249, _S258);
            float _S264 = imp_3.mat_0.x;
            float4  _S265 = __ldg(&(&(globalParams_0->chunks_0)[_S249])->cmat_0);
            float _S266 = _S265.x;
            float3  _S267 = b_17.center_1 - _S263.center_1;
            Box_0 _S268 = _S263;
            Box_0 _S269 = b_17;
            float _S270 = contact_stiffness_0(_S264, &_S268, _S266, &_S269, _S267);
            float _S271 = imp_3.geom_0.y;
            Box_0 _S272 = _S263;
            Box_0 _S273 = impactor_shrunk_0(_S251, _S271, &_S272);
            Box_0 _S274 = _S273;
            Box_0 _S275 = b_17;
            uint _S276 = impactor_contact_count_0(_S251, _S271, &_S274, &_S275);
            bool _S277 = (imp_3.shape_0.x) == 0.0f;
            float _S278;
            if(_S277)
            {
                _S278 = _S270;
            }
            else
            {
                _S278 = _S270 / (F32_max((float(_S276)), (10.0f)));
            }
            uint _S279;
            if(_S277)
            {
                _S279 = 1U;
            }
            else
            {
                _S279 = _S276;
            }
            float4  _S280 = __ldg(&(&(globalParams_0->chunks_0)[_S249])->center_0);
            float m_1 = _S280.w;
            float _S281 = imp_3.mat_0.z;
            float _S282 = m_1 * _S281 / (m_1 + _S281);
            float _S283 = __ldg(&globalParams_0->params_0->pair_friction_0);
            float _S284;
            if(_S283 >= 0.0f)
            {
                float _S285 = __ldg(&globalParams_0->params_0->pair_friction_0);
                _S284 = _S285;
            }
            else
            {
                float _S286 = imp_3.mat_0.y;
                float4  _S287 = __ldg(&(&(globalParams_0->chunks_0)[_S249])->cmat_0);
                _S284 = (F32_min((_S286), (_S287.y)));
            }
            float4  _S288 = imp_3.velocity_1;
            float4  _S289 = imp_3.velocity_err_1;
            float3  _S290 = float3 {_S288.x, _S288.y, _S288.z} + float3 {_S289.x, _S289.y, _S289.z};
            float3  vc_0;
            float3  wc_0;
            chunk_velocity_0(_S249, &vc_0, &wc_0);
            uint j_2 = 0U;
            f_sum_0 = _S253;
            t_sum_0 = _S253;
            imp_f_0 = _S253;
            imp_t_0 = _S253;
            for(;;)
            {
                bool _S291;
                if(_S276 > 0U)
                {
                    Impactor_0 _S292 = imp_3;
                    Box_0 _S293 = b_17;
                    uint _S294 = impactor_slots_0(&_S292, &_S293);
                    _S291 = j_2 < _S294;
                }
                else
                {
                    _S291 = false;
                }
                if(_S291)
                {
                }
                else
                {
                    break;
                }
                Impactor_0 _S295 = imp_3;
                Box_0 _S296 = _S273;
                Box_0 _S297 = b_17;
                float3  p_6;
                float3  nrm_0;
                float dep_0;
                bool _S298 = impactor_contact_0(&_S295, _S271, &_S296, &_S297, j_2, &p_6, &nrm_0, &dep_0);
                if(!_S298)
                {
                    j_2 = j_2 + 1U;
                    continue;
                }
                float4  _S299 = imp_3.angular_velocity_1;
                float stored_2;
                float diss_1;
                float3  f_2 = penalty_force_0(_S278, _S282, _S284, dep_0 * imp_3.geom_0.x, nrm_0, vc_0 + cross_0(wc_0, p_6 - b_17.center_1) - (_S290 + cross_0(float3 {_S299.x, _S299.y, _S299.z}, p_6)), _S252, _S279, &stored_2, &diss_1);
                float3  f_sum_1 = f_sum_0 + f_2;
                float3  t_sum_1 = t_sum_0 + cross_0(p_6 - b_17.center_1, f_2);
                float3  imp_f_1 = imp_f_0 - f_2;
                float3  imp_t_1 = imp_t_0 - cross_0(p_6, f_2);
                comp_add1_0(&((&data_0)->z), &((&data_0)->w), diss_1);
                f_sum_0 = f_sum_1;
                t_sum_0 = t_sum_1;
                imp_f_0 = imp_f_1;
                imp_t_0 = imp_t_1;
                j_2 = j_2 + 1U;
            }
        }
        else
        {
            f_sum_0 = _S253;
            t_sum_0 = _S253;
            imp_f_0 = _S253;
            imp_t_0 = _S253;
        }
    }
    else
    {
        f_sum_0 = _S253;
        t_sum_0 = _S253;
        imp_f_0 = _S253;
        imp_t_0 = _S253;
    }
    uint _S300 = __ldg(&globalParams_0->params_0->slot_base_0);
    uint _S301 = 2U * _S250;
    *(&(globalParams_0->scratch_0)[_S300 + _S301]) = make_float4 (f_sum_0.x, f_sum_0.y, f_sum_0.z, 0.0f);
    uint _S302 = __ldg(&globalParams_0->params_0->slot_base_0);
    *(&(globalParams_0->scratch_0)[_S302 + _S301 + 1U]) = make_float4 (t_sum_0.x, t_sum_0.y, t_sum_0.z, 0.0f);
    uint _S303 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S303 + _S248]) = data_0;
    uint _S304 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S304 + _S248 + 1U]) = make_float4 (imp_f_0.x, imp_f_0.y, imp_f_0.z, 0.0f);
    uint _S305 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S305 + _S248 + 2U]) = make_float4 (imp_t_0.x, imp_t_0.y, imp_t_0.z, 0.0f);
    return;
}

static __device__ void travel_check_0(uint c_4)
{
    ChunkStatic_0 * _S306 = (&(globalParams_0->chunks_0)[c_4]);
    uint4  _S307 = __ldg(&_S306->cinfo_0);
    if((_S307.z) == 0U)
    {
        return;
    }
    WorldPoint_0 wp_0 = chunk_world_0(c_4);
    float4  _S308 = __ldg(&_S306->start_hi_0);
    float3  _S309 = wp_0.hi_0 - float3 {_S308.x, _S308.y, _S308.z};
    float4  _S310 = __ldg(&_S306->start_lo_0);
    if((length_0(_S309 + (wp_0.lo_0 - float3 {_S310.x, _S310.y, _S310.z}) + wp_0.rel_0)) > (_S308.w))
    {
        uint _S311 = __ldg(&globalParams_0->params_0->halt_index_0);
        uint _S312 = __ldg(&globalParams_0->params_0->halt_index_0);
        *&((&(&(globalParams_0->islands_0)[_S311])->info_1)->z) = ((&(globalParams_0->islands_0)[_S312])->info_1.z) | 1U;
    }
    return;
}

extern "C" __global__ void contact_forces()
{
    uint i_8 = (blockIdx * blockDim + threadIdx).x;
    if(stopped_0())
    {
        return;
    }
    uint _S313 = __ldg(&globalParams_0->params_0->pair_count_0);
    if(i_8 < _S313)
    {
        pair_contact_0(i_8);
    }
    else
    {
        uint _S314 = __ldg(&globalParams_0->params_0->pair_count_0);
        uint _S315 = __ldg(&globalParams_0->params_0->cand_count_0);
        if(i_8 < (_S314 + _S315))
        {
            uint _S316 = __ldg(&globalParams_0->params_0->pair_count_0);
            impactor_candidate_forces_0(i_8 - _S316);
        }
        else
        {
            uint _S317 = __ldg(&globalParams_0->params_0->pair_count_0);
            uint _S318 = __ldg(&globalParams_0->params_0->cand_count_0);
            uint _S319 = _S317 + _S318;
            uint _S320 = __ldg(&globalParams_0->params_0->chunk_count_0);
            if(i_8 < (_S319 + _S320))
            {
                uint _S321 = __ldg(&globalParams_0->params_0->pair_count_0);
                uint _S322 = i_8 - _S321;
                uint _S323 = __ldg(&globalParams_0->params_0->cand_count_0);
                travel_check_0(_S322 - _S323);
            }
        }
    }
    return;
}

extern "C" __global__ void impactor_shares()
{
    uint k_6 = (blockIdx * blockDim + threadIdx).x;
    uint _S324 = __ldg(&globalParams_0->params_0->cand_count_0);
    bool _S325;
    if(k_6 >= _S324)
    {
        _S325 = true;
    }
    else
    {
        _S325 = stopped_0();
    }
    if(_S325)
    {
        return;
    }
    uint _S326 = __ldg(&globalParams_0->params_0->cand_index_0);
    uint _S327 = 3U * k_6;
    uint at_2 = _S326 + _S327;
    uint _S328 = __ldg((&(globalParams_0->index_0)[at_2]));
    uint _S329 = __ldg((&(globalParams_0->index_0)[at_2 + 2U]));
    Impactor_0 * _S330 = (&(globalParams_0->impactors_0)[_S329]);
    Impactor_0 imp_4 = *_S330;
    if(((*_S330).cand_0.z) == 0U)
    {
        _S325 = (imp_4.crush_1.x) > 0.0f;
    }
    else
    {
        _S325 = false;
    }
    float total_0;
    float ksum_0;
    if(_S325)
    {
        WorldPoint_0 _S331 = impactor_point_0(_S329);
        WorldPoint_0 _S332 = chunk_world_0(_S328);
        WorldPoint_0 _S333 = _S331;
        float3  _S334 = world_diff_0(&_S332, &_S333);
        float _S335 = length_0(_S334);
        float _S336 = imp_4.half_1.w;
        float4  _S337 = __ldg(&(&(globalParams_0->chunks_0)[_S328])->half_0);
        if(!(_S335 > (_S336 + _S337.w)))
        {
            float4  _S338 = imp_4.half_1;
            Box_0 _S339 = impactor_box_1(_S329, make_float3 (0.0f), float3 {_S338.x, _S338.y, _S338.z});
            Box_0 b_18 = chunk_box_0(_S328, _S334);
            float _S340 = imp_4.mat_0.x;
            float4  _S341 = __ldg(&(&(globalParams_0->chunks_0)[_S328])->cmat_0);
            float _S342 = _S341.x;
            float3  _S343 = b_18.center_1 - _S339.center_1;
            Box_0 _S344 = _S339;
            Box_0 _S345 = b_18;
            float _S346 = contact_stiffness_0(_S340, &_S344, _S342, &_S345, _S343);
            float _S347 = imp_4.crush_1.w;
            Box_0 _S348 = _S339;
            Box_0 _S349 = impactor_shrunk_0(_S329, _S347, &_S348);
            Box_0 _S350 = _S349;
            Box_0 _S351 = b_18;
            uint _S352 = impactor_contact_count_0(_S329, _S347, &_S350, &_S351);
            float _S353;
            if((imp_4.shape_0.x) == 0.0f)
            {
                _S353 = _S346;
            }
            else
            {
                _S353 = _S346 / (F32_max((float(_S352)), (10.0f)));
            }
            uint j_3 = 0U;
            total_0 = 0.0f;
            ksum_0 = 0.0f;
            for(;;)
            {
                if(_S352 > 0U)
                {
                    Impactor_0 _S354 = imp_4;
                    Box_0 _S355 = b_18;
                    uint _S356 = impactor_slots_0(&_S354, &_S355);
                    _S325 = j_3 < _S356;
                }
                else
                {
                    _S325 = false;
                }
                if(_S325)
                {
                }
                else
                {
                    break;
                }
                Impactor_0 _S357 = imp_4;
                Box_0 _S358 = _S349;
                Box_0 _S359 = b_18;
                float3  p_7;
                float3  nrm_1;
                float dep_1;
                bool _S360 = impactor_contact_0(&_S357, _S347, &_S358, &_S359, j_3, &p_7, &nrm_1, &dep_1);
                if(!_S360)
                {
                    j_3 = j_3 + 1U;
                    continue;
                }
                float ksum_1 = ksum_0 + _S353;
                total_0 = total_0 + _S353 * dep_1;
                ksum_0 = ksum_1;
                j_3 = j_3 + 1U;
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
    uint _S361 = __ldg(&globalParams_0->params_0->cand_base_0);
    float4  data_1 = *(&(globalParams_0->scratch_0)[_S361 + _S327]);
    uint _S362 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S362 + _S327]) = make_float4 (total_0, ksum_0, data_1.z, data_1.w);
    return;
}

__device__ __shared__ FixedArray<float4 , 256>  g_red_a_0;

__device__ __shared__ FixedArray<float4 , 256>  g_red_b_0;

static __device__ void group_sum2_0(uint tid_0, float4  * a_4, float4  * b_19)
{
    (*&g_red_a_0)[tid_0] = *a_4;
    (*&g_red_b_0)[tid_0] = *b_19;
    __syncthreads();
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
            uint _S363 = tid_0 + s_1;
            (*&g_red_a_0)[tid_0] = (*&g_red_a_0)[tid_0] + (*&g_red_a_0)[_S363];
            (*&g_red_b_0)[tid_0] = (*&g_red_b_0)[tid_0] + (*&g_red_b_0)[_S363];
        }
        __syncthreads();
        s_1 = s_1 >> int(1);
    }
    *a_4 = (*&g_red_a_0)[int(0)];
    *b_19 = (*&g_red_b_0)[int(0)];
    __syncthreads();
    return;
}

extern "C" __global__ void impactor_crush()
{
    uint ii_0 = blockIdx.x;
    uint tid_1 = threadIdx.x;
    uint _S364 = __ldg(&globalParams_0->params_0->impactor_count_0);
    bool _S365;
    if(ii_0 >= _S364)
    {
        _S365 = true;
    }
    else
    {
        _S365 = stopped_0();
    }
    if(_S365)
    {
        return;
    }
    Impactor_0 imp_5 = *(&(globalParams_0->impactors_0)[ii_0]);
    float4  _S366 = make_float4 (0.0f);
    float4  shares_0 = _S366;
    float4  unused_1 = _S366;
    uint k_7 = (&imp_5)->cand_0.x + tid_1;
    for(;;)
    {
        if(k_7 < ((&imp_5)->cand_0.y))
        {
        }
        else
        {
            break;
        }
        uint _S367 = __ldg(&globalParams_0->params_0->cand_base_0);
        shares_0 = shares_0 + *(&(globalParams_0->scratch_0)[_S367 + 3U * k_7]);
        k_7 = k_7 + 256U;
    }
    group_sum2_0(tid_1, &shares_0, &unused_1);
    if(tid_1 != 0U)
    {
        _S365 = true;
    }
    else
    {
        _S365 = ((&imp_5)->cand_0.z) != 0U;
    }
    if(_S365)
    {
        return;
    }
    (&imp_5)->geom_0 = make_float4 (1.0f, (&imp_5)->crush_1.w, 0.0f, 0.0f);
    float total_1 = shares_0.x;
    if(((&imp_5)->crush_1.x) > 0.0f)
    {
        _S365 = ((&imp_5)->crush_1.z) < ((&imp_5)->crush_1.y);
    }
    else
    {
        _S365 = false;
    }
    if(_S365)
    {
        _S365 = total_1 > ((&imp_5)->crush_1.x);
    }
    else
    {
        _S365 = false;
    }
    if(_S365)
    {
        float extra_0 = (total_1 - (&imp_5)->crush_1.x) / shares_0.y;
        *&((&(&imp_5)->crush_1)->w) = *&((&(&imp_5)->crush_1)->w) + extra_0;
        *&((&(&imp_5)->crush_1)->z) = *&((&(&imp_5)->crush_1)->z) + (&imp_5)->crush_1.x * extra_0;
        comp_add1_0(&((&(&imp_5)->ledger_0)->z), &((&(&imp_5)->ledger_0)->w), (&imp_5)->crush_1.x * extra_0);
        comp_add1_0(&((&(&imp_5)->ledger_0)->x), &((&(&imp_5)->ledger_0)->y), (&imp_5)->crush_1.x * extra_0);
        *&((&(&imp_5)->geom_0)->x) = (&imp_5)->crush_1.x / total_1;
    }
    *(&(globalParams_0->impactors_0)[ii_0]) = imp_5;
    return;
}

static __device__ void comp_add_0(float3  * sum_1, float3  * err_1, float3  x_12)
{
    float3  t_2 = *sum_1 + x_12;
    float3  _S368 = abs_0(x_12);
    *err_1 = *err_1 + (_slang_select((abs_0(*sum_1)) >= _S368, *sum_1,x_12) - t_2 + _slang_select((abs_0(*sum_1)) >= _S368, x_12,*sum_1));
    *sum_1 = t_2;
    return;
}

static __device__ float3  inverse_rotate_0(Quat_0 * q_9, float3  v_4)
{
    Quat_0 c_5;
    (&c_5)->w_0 = q_9->w_0;
    (&c_5)->x_9 = - q_9->x_9;
    (&c_5)->y_3 = - q_9->y_3;
    (&c_5)->z_0 = - q_9->z_0;
    Quat_0 _S369 = c_5;
    float3  _S370 = rotate_0(&_S369, v_4);
    return _S370;
}

static __device__ float3  rows_mul_0(float4  r0_0, float4  r1_0, float4  r2_0, float3  v_5)
{
    return make_float3 (dot_0(float3 {r0_0.x, r0_0.y, r0_0.z}, v_5), dot_0(float3 {r1_0.x, r1_0.y, r1_0.z}, v_5), dot_0(float3 {r2_0.x, r2_0.y, r2_0.z}, v_5));
}

static __device__ float3  world_mul_0(Quat_0 * q_10, float4  r0_1, float4  r1_1, float4  r2_1, float3  v_6)
{
    float3  _S371 = inverse_rotate_0(q_10, v_6);
    float3  _S372 = rotate_0(q_10, rows_mul_0(r0_1, r1_1, r2_1, _S371));
    return _S372;
}

static __device__ Quat_0 quat_mul_0(Quat_0 * a_5, Quat_0 * o_0)
{
    Quat_0 r_4;
    (&r_4)->w_0 = a_5->w_0 * o_0->w_0 - a_5->x_9 * o_0->x_9 - a_5->y_3 * o_0->y_3 - a_5->z_0 * o_0->z_0;
    (&r_4)->x_9 = a_5->w_0 * o_0->x_9 + a_5->x_9 * o_0->w_0 + a_5->y_3 * o_0->z_0 - a_5->z_0 * o_0->y_3;
    (&r_4)->y_3 = a_5->w_0 * o_0->y_3 - a_5->x_9 * o_0->z_0 + a_5->y_3 * o_0->w_0 + a_5->z_0 * o_0->x_9;
    (&r_4)->z_0 = a_5->w_0 * o_0->z_0 + a_5->x_9 * o_0->y_3 - a_5->y_3 * o_0->x_9 + a_5->z_0 * o_0->w_0;
    return r_4;
}

static __device__ Quat_0 normalized_0(Quat_0 * q_11)
{
    float n_7 = (F32_sqrt((q_11->w_0 * q_11->w_0 + q_11->x_9 * q_11->x_9 + q_11->y_3 * q_11->y_3 + q_11->z_0 * q_11->z_0)));
    Quat_0 r_5;
    (&r_5)->w_0 = q_11->w_0 / n_7;
    (&r_5)->x_9 = q_11->x_9 / n_7;
    (&r_5)->y_3 = q_11->y_3 / n_7;
    (&r_5)->z_0 = q_11->z_0 / n_7;
    return r_5;
}

static __device__ Quat_0 integrate_rotation_0(Quat_0 * q_12, float3  omega_0, float dt_2)
{
    float angle_1 = length_0(omega_0) * dt_2;
    if(angle_1 < 1.00000000317107685e-30f)
    {
        return *q_12;
    }
    Quat_0 _S373 = from_axis_angle_0(omega_0, angle_1);
    Quat_0 _S374 = quat_mul_0(&_S373, q_12);
    Quat_0 _S375 = _S374;
    Quat_0 _S376 = normalized_0(&_S375);
    return _S376;
}

static __device__ float4  quat_vec_0(Quat_0 * q_13)
{
    return make_float4 (q_13->x_9, q_13->y_3, q_13->z_0, q_13->w_0);
}

extern "C" __global__ void impactor_integrate()
{
    float3  p_8;
    uint ii_1 = blockIdx.x;
    uint tid_2 = threadIdx.x;
    uint _S377 = __ldg(&globalParams_0->params_0->impactor_count_0);
    if(ii_1 >= _S377)
    {
        return;
    }
    uint _S378 = __ldg(&globalParams_0->params_0->halt_index_0);
    Island_0 * _S379 = (&(globalParams_0->islands_0)[_S378]);
    Impactor_0 imp_6 = *(&(globalParams_0->impactors_0)[ii_1]);
    bool _S380;
    if(((&imp_6)->cand_0.z) != 0U)
    {
        _S380 = true;
    }
    else
    {
        _S380 = ((_S379->info_1.z) & 1U) != 0U;
    }
    if(_S380)
    {
        _S380 = true;
    }
    else
    {
        uint _S381 = _S379->info_1.y;
        if(_S381 != 0U)
        {
            _S380 = ((&imp_6)->cand_0.w) >= _S381;
        }
        else
        {
            _S380 = false;
        }
    }
    if(_S380)
    {
        return;
    }
    float4  _S382 = make_float4 (0.0f);
    float4  rf_0 = _S382;
    float4  rt_0 = _S382;
    uint k_8 = (&imp_6)->cand_0.x + tid_2;
    for(;;)
    {
        if(k_8 < ((&imp_6)->cand_0.y))
        {
        }
        else
        {
            break;
        }
        uint _S383 = __ldg(&globalParams_0->params_0->cand_base_0);
        uint _S384 = 3U * k_8;
        rf_0 = rf_0 + *(&(globalParams_0->scratch_0)[_S383 + _S384 + 1U]);
        uint _S385 = __ldg(&globalParams_0->params_0->cand_base_0);
        rt_0 = rt_0 + *(&(globalParams_0->scratch_0)[_S385 + _S384 + 2U]);
        k_8 = k_8 + 256U;
    }
    group_sum2_0(tid_2, &rf_0, &rt_0);
    if(tid_2 != 0U)
    {
        return;
    }
    float _S386 = __ldg(&globalParams_0->params_0->dt_0);
    float3  _S387 = make_float3 (0.0f);
    uint _S388 = __ldg(&globalParams_0->params_0->has_ground_0);
    float3  load_f_0;
    float3  load_t_0;
    if(_S388 != 0U)
    {
        float4  _S389 = (&imp_6)->half_1;
        float3  _S390 = float3 {_S389.x, _S389.y, _S389.z};
        Impactor_0 _S391 = imp_6;
        Box_0 _S392 = impactor_box_0(&_S391, _S387, _S390);
        float4  _S393 = (&imp_6)->velocity_1;
        float4  _S394 = (&imp_6)->velocity_err_1;
        float3  _S395 = float3 {_S393.x, _S393.y, _S393.z} + float3 {_S394.x, _S394.y, _S394.z};
        float _S396 = __ldg(&globalParams_0->params_0->ground_modulus_0);
        float _S397 = (&imp_6)->mat_0.x;
        float3  _S398 = make_float3 (0.0f, 0.0f, 1.0f);
        Box_0 _S399 = _S392;
        Box_0 _S400 = _S392;
        float _S401 = contact_stiffness_0(_S396, &_S399, _S397, &_S400, _S398);
        float _S402 = (&imp_6)->position_1.z;
        float _S403 = __ldg(&globalParams_0->params_0->ground_hi_0);
        float _S404 = _S402 - _S403;
        float _S405 = (&imp_6)->position_err_1.z;
        float _S406 = __ldg(&globalParams_0->params_0->ground_lo_0);
        float _S407 = _S404 + (_S405 - _S406);
        uint total_points_0;
        if(((&imp_6)->shape_0.x) == 0.0f)
        {
            total_points_0 = 1U;
        }
        else
        {
            total_points_0 = 14U;
        }
        float _S408 = _S401 / float((U32_min((total_points_0), (5U))));
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
                p_8 = make_float3 (0.0f, 0.0f, - (&imp_6)->shape_0.y);
            }
            else
            {
                Box_0 _S409 = _S392;
                float3  _S410 = sample_point_0(&_S409, s_2);
                p_8 = _S410;
            }
            if((_S407 + p_8.z) < 0.0f)
            {
                below_0 = below_0 + 1U;
            }
            s_2 = s_2 + 1U;
        }
        s_2 = 0U;
        load_f_0 = _S387;
        load_t_0 = _S387;
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
                p_8 = make_float3 (0.0f, 0.0f, - (&imp_6)->shape_0.y);
            }
            else
            {
                Box_0 _S411 = _S392;
                float3  _S412 = sample_point_0(&_S411, s_2);
                p_8 = _S412;
            }
            float depth_3 = - (_S407 + p_8.z);
            if(depth_3 <= 0.0f)
            {
                s_2 = s_2 + 1U;
                continue;
            }
            float4  _S413 = (&imp_6)->angular_velocity_1;
            float3  v_7 = _S395 + cross_0(float3 {_S413.x, _S413.y, _S413.z}, p_8);
            float _S414 = (&imp_6)->mat_0.z;
            float _S415 = __ldg(&globalParams_0->params_0->ground_friction_0);
            float stored_3;
            float diss_2;
            float3  f_3 = penalty_force_0(_S408, _S414, _S415, depth_3, _S398, v_7, _S386, below_0, &stored_3, &diss_2);
            float3  load_f_1 = load_f_0 + f_3;
            float3  load_t_1 = load_t_0 + cross_0(p_8, f_3);
            comp_add1_0(&((&(&imp_6)->ledger_0)->x), &((&(&imp_6)->ledger_0)->y), diss_2);
            load_f_0 = load_f_1;
            load_t_0 = load_t_1;
            s_2 = s_2 + 1U;
        }
    }
    else
    {
        load_f_0 = _S387;
        load_t_0 = _S387;
    }
    float4  _S416 = rf_0;
    float3  load_f_2 = float3 {_S416.x, _S416.y, _S416.z} + load_f_0;
    float4  _S417 = rt_0;
    float3  load_t_2 = float3 {_S417.x, _S417.y, _S417.z} + load_t_0;
    float m_2 = (&imp_6)->mat_0.z;
    float4  _S418 = (&imp_6)->velocity_1;
    float3  vel_0 = float3 {_S418.x, _S418.y, _S418.z};
    float4  _S419 = (&imp_6)->velocity_err_1;
    float3  vel_err_0 = float3 {_S419.x, _S419.y, _S419.z};
    float3  _S420 = load_f_2 / make_float3 (m_2);
    float4  _S421 = __ldg(&globalParams_0->params_0->gravity_0);
    comp_add_0(&vel_0, &vel_err_0, (_S420 + float3 {_S421.x, _S421.y, _S421.z}) * make_float3 (_S386));
    Quat_0 q_14 = quat_of_0((&imp_6)->rotation_1);
    float4  _S422 = (&imp_6)->angular_velocity_1;
    float3  _S423 = float3 {_S422.x, _S422.y, _S422.z};
    Quat_0 _S424 = q_14;
    float3  _S425 = world_mul_0(&_S424, (&imp_6)->inertia0_2, (&imp_6)->inertia1_2, (&imp_6)->inertia2_2, _S423);
    float3  l_1 = _S425 + load_t_2 * make_float3 (_S386);
    Quat_0 _S426 = q_14;
    float3  _S427 = world_mul_0(&_S426, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    float4  _S428 = (&imp_6)->position_1;
    float3  pos_0 = float3 {_S428.x, _S428.y, _S428.z};
    float4  _S429 = (&imp_6)->position_err_1;
    float3  pos_err_0 = float3 {_S429.x, _S429.y, _S429.z};
    comp_add_0(&pos_0, &pos_err_0, (vel_0 + vel_err_0) * make_float3 (_S386));
    Quat_0 _S430 = q_14;
    Quat_0 _S431 = integrate_rotation_0(&_S430, _S427, _S386);
    Quat_0 _S432 = _S431;
    float3  _S433 = world_mul_0(&_S432, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    (&imp_6)->angular_velocity_1 = make_float4 (_S433.x, _S433.y, _S433.z, 0.0f);
    Quat_0 _S434 = _S431;
    float4  _S435 = quat_vec_0(&_S434);
    (&imp_6)->rotation_1 = _S435;
    (&imp_6)->position_1 = make_float4 (pos_0.x, pos_0.y, pos_0.z, 0.0f);
    (&imp_6)->position_err_1 = make_float4 (pos_err_0.x, pos_err_0.y, pos_err_0.z, 0.0f);
    (&imp_6)->velocity_1 = make_float4 (vel_0.x, vel_0.y, vel_0.z, 0.0f);
    (&imp_6)->velocity_err_1 = make_float4 (vel_err_0.x, vel_err_0.y, vel_err_0.z, 0.0f);
    *&((&(&imp_6)->cand_0)->w) = *&((&(&imp_6)->cand_0)->w) + 1U;
    (&imp_6)->geom_0 = make_float4 (1.0f, (&imp_6)->crush_1.w, 0.0f, 0.0f);
    *(&(globalParams_0->impactors_0)[ii_1]) = imp_6;
    uint _S436 = (&imp_6)->cand_0.w - 1U;
    uint _S437 = __ldg(&globalParams_0->params_0->step_start_0);
    uint k_9 = _S436 - _S437;
    uint _S438 = __ldg(&globalParams_0->params_0->record_stride_0);
    if(k_9 < _S438)
    {
        uint _S439 = __ldg(&globalParams_0->params_0->record_base_0);
        uint _S440 = __ldg(&globalParams_0->params_0->record_stride_0);
        uint at_3 = _S439 + 2U * (ii_1 * _S440 + k_9);
        *(&(globalParams_0->scratch_0)[at_3]) = make_float4 ((vel_0 + vel_err_0).x, (vel_0 + vel_err_0).y, (vel_0 + vel_err_0).z, 0.0f);
        *(&(globalParams_0->scratch_0)[at_3 + 1U]) = make_float4 ((pos_0 + pos_err_0).x, (pos_0 + pos_err_0).y, (pos_0 + pos_err_0).z, 0.0f);
    }
    return;
}

static __device__ void ground_contact_0(uint c_6, bool account_0, float3  * f_4, float3  * t_3)
{
    ChunkStatic_0 * _S441 = (&(globalParams_0->chunks_0)[c_6]);
    WorldPoint_0 wp_1 = chunk_world_0(c_6);
    float _S442 = wp_1.hi_0.z;
    float _S443 = __ldg(&globalParams_0->params_0->ground_hi_0);
    float _S444 = _S442 - _S443;
    float _S445 = wp_1.lo_0.z;
    float _S446 = __ldg(&globalParams_0->params_0->ground_lo_0);
    float above_0 = _S444 + (_S445 - _S446) + wp_1.rel_0.z;
    float4  _S447 = __ldg(&_S441->half_0);
    if((above_0 - _S447.w) > 0.0f)
    {
        return;
    }
    Box_0 b_20 = chunk_box_0(c_6, make_float3 (0.0f));
    float _S448 = __ldg(&globalParams_0->params_0->ground_modulus_0);
    float4  _S449 = __ldg(&_S441->cmat_0);
    float _S450 = _S449.x;
    float3  _S451 = make_float3 (0.0f, 0.0f, 1.0f);
    Box_0 _S452 = b_20;
    Box_0 _S453 = b_20;
    float _S454 = contact_stiffness_0(_S448, &_S452, _S450, &_S453, _S451);
    Box_0 _S455 = b_20;
    uint _S456 = sample_count_0(&_S455);
    uint s_3 = 0U;
    uint n_8 = 0U;
    for(;;)
    {
        if(s_3 < _S456)
        {
        }
        else
        {
            break;
        }
        Box_0 _S457 = b_20;
        float3  _S458 = sample_point_0(&_S457, s_3);
        if((above_0 + _S458.z) < 0.0f)
        {
            n_8 = n_8 + 1U;
        }
        s_3 = s_3 + 1U;
    }
    if(n_8 == 0U)
    {
        return;
    }
    float3  vc_1;
    float3  wc_1;
    chunk_velocity_0(c_6, &vc_1, &wc_1);
    uint _S459 = __ldg(&globalParams_0->params_0->ledger_base_0);
    uint _S460 = __ldg(&globalParams_0->params_0->pair_count_0);
    float4  ledger_2 = *(&(globalParams_0->scratch_0)[_S459 + _S460 + c_6]);
    s_3 = 0U;
    for(;;)
    {
        if(s_3 < _S456)
        {
        }
        else
        {
            break;
        }
        Box_0 _S461 = b_20;
        float3  _S462 = sample_point_0(&_S461, s_3);
        float _S463 = above_0 + _S462.z;
        if(!(_S463 < 0.0f))
        {
            s_3 = s_3 + 1U;
            continue;
        }
        float depth_4 = - _S463;
        float3  v_8 = vc_1 + cross_0(wc_1, _S462);
        float _S464 = _S454 / float((U32_max((n_8), (5U))));
        float4  _S465 = __ldg(&_S441->center_0);
        float _S466 = _S465.w;
        float _S467 = __ldg(&globalParams_0->params_0->ground_friction_0);
        float _S468 = __ldg(&globalParams_0->params_0->dt_0);
        float stored_4;
        float diss_3;
        float3  g_0 = penalty_force_0(_S464, _S466, _S467, depth_4, _S451, v_8, _S468, n_8, &stored_4, &diss_3);
        *f_4 = *f_4 + g_0;
        *t_3 = *t_3 + cross_0(_S462, g_0);
        comp_add1_0(&((&ledger_2)->y), &((&ledger_2)->z), diss_3);
        s_3 = s_3 + 1U;
    }
    if(account_0)
    {
        uint _S469 = __ldg(&globalParams_0->params_0->ledger_base_0);
        uint _S470 = __ldg(&globalParams_0->params_0->pair_count_0);
        *(&(globalParams_0->scratch_0)[_S469 + _S470 + c_6]) = ledger_2;
    }
    return;
}

extern "C" __global__ void contact_sums()
{
    uint g_1 = (blockIdx * blockDim + threadIdx).x;
    uint _S471 = __ldg(&globalParams_0->params_0->seg_count_0);
    bool _S472;
    if(g_1 >= _S471)
    {
        _S472 = true;
    }
    else
    {
        _S472 = stopped_0();
    }
    if(_S472)
    {
        return;
    }
    uint _S473 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S474 = 3U * g_1;
    uint _S475 = __ldg((&(globalParams_0->index_0)[_S473 + _S474]));
    uint _S476 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S477 = __ldg((&(globalParams_0->index_0)[_S476 + _S474 + 1U]));
    uint _S478 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S479 = __ldg((&(globalParams_0->index_0)[_S478 + _S474 + 2U]));
    float3  _S480 = make_float3 (0.0f);
    float3  f_5 = _S480;
    float3  t_4 = _S480;
    uint e_2 = _S477;
    for(;;)
    {
        if(e_2 < _S479)
        {
        }
        else
        {
            break;
        }
        uint _S481 = __ldg((&(globalParams_0->index_0)[e_2]));
        if(_S481 == 2147483648U)
        {
            ground_contact_0(_S475, true, &f_5, &t_4);
            e_2 = e_2 + 1U;
            continue;
        }
        uint _S482 = __ldg(&globalParams_0->params_0->slot_base_0);
        uint _S483 = 2U * _S481;
        float4  _S484 = *(&(globalParams_0->scratch_0)[_S482 + _S483]);
        f_5 = f_5 + float3 {_S484.x, _S484.y, _S484.z};
        uint _S485 = __ldg(&globalParams_0->params_0->slot_base_0);
        float4  _S486 = *(&(globalParams_0->scratch_0)[_S485 + _S483 + 1U]);
        t_4 = t_4 + float3 {_S486.x, _S486.y, _S486.z};
        e_2 = e_2 + 1U;
    }
    uint _S487 = __ldg(&globalParams_0->params_0->seg_base_0);
    uint _S488 = 2U * g_1;
    *(&(globalParams_0->scratch_0)[_S487 + _S488]) = make_float4 (f_5.x, f_5.y, f_5.z, 0.0f);
    uint _S489 = __ldg(&globalParams_0->params_0->seg_base_0);
    *(&(globalParams_0->scratch_0)[_S489 + _S488 + 1U]) = make_float4 (t_4.x, t_4.y, t_4.z, 0.0f);
    return;
}

static __device__ bool contact_stopped_0(Island_0 * isl_0)
{
    uint _S490 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint4  _S491 = (&(globalParams_0->islands_0)[_S490])->info_1;
    bool _S492;
    if((((&(globalParams_0->islands_0)[_S490])->info_1.z) & 1U) != 0U)
    {
        _S492 = true;
    }
    else
    {
        uint _S493 = _S491.y;
        if(_S493 != 0U)
        {
            _S492 = _S493 <= (isl_0->info_1.w);
        }
        else
        {
            _S492 = false;
        }
    }
    return _S492;
}

__device__ __shared__ uint g_run_0;

__device__ __shared__ uint g_halt_0;

struct Rigid_0
{
    Quat_0 rot_0;
    float3  pos_1;
    float3  pos_err_1;
    float3  vel_1;
    float3  vel_err_1;
    float3  w_3;
    float3  a_6;
    float3  alpha_0;
};

static __device__ Rigid_0 rigid_of_0(Island_0 * isl_1)
{
    Rigid_0 rg_0;
    (&rg_0)->rot_0 = quat_of_0(isl_1->rotation_0);
    float4  _S494 = isl_1->position_0;
    (&rg_0)->pos_1 = float3 {_S494.x, _S494.y, _S494.z};
    float4  _S495 = isl_1->position_err_0;
    (&rg_0)->pos_err_1 = float3 {_S495.x, _S495.y, _S495.z};
    float4  _S496 = isl_1->velocity_0;
    (&rg_0)->vel_1 = float3 {_S496.x, _S496.y, _S496.z};
    float4  _S497 = isl_1->velocity_err_0;
    (&rg_0)->vel_err_1 = float3 {_S497.x, _S497.y, _S497.z};
    float4  _S498 = isl_1->angular_velocity_0;
    (&rg_0)->w_3 = float3 {_S498.x, _S498.y, _S498.z};
    float3  _S499 = make_float3 (0.0f);
    (&rg_0)->a_6 = _S499;
    (&rg_0)->alpha_0 = _S499;
    return rg_0;
}

static __device__ void write_probe_0(uint slot_0, uint k_10, float value_0)
{
    uint _S500 = __ldg(&globalParams_0->params_0->probe_base_0);
    uint _S501 = _S500 * 4U;
    uint _S502 = __ldg(&globalParams_0->params_0->probe_stride_0);
    uint at_4 = _S501 + slot_0 * _S502 + k_10;
    float4  v_9 = *(&(globalParams_0->scratch_0)[at_4 / 4U]);
    *_slang_vector_get_element_ptr(&v_9, at_4 % 4U) = value_0;
    *(&(globalParams_0->scratch_0)[at_4 / 4U]) = v_9;
    return;
}

static __device__ void record_probes_0(Island_0 * isl_2, Rigid_0 * rg_1, uint k_11)
{
    uint4  _S503 = isl_2->probes_0;
    uint at_5 = isl_2->probes_0.x;
    for(;;)
    {
        if(at_5 < (_S503.y))
        {
        }
        else
        {
            break;
        }
        float4  _S504 = __ldg((&(globalParams_0->loads_0)[at_5]));
        uint4  info_2 = asuint_0(_S504);
        float4  _S505 = __ldg((&(globalParams_0->loads_0)[at_5 + 1U]));
        float4  _S506 = __ldg((&(globalParams_0->loads_0)[at_5 + 2U]));
        float4  _S507 = __ldg((&(globalParams_0->loads_0)[at_5 + 3U]));
        uint kind_0 = info_2.x;
        uint i_9 = info_2.y;
        float value_1;
        if(kind_0 == 0U)
        {
            float3  _S508 = rg_1->pos_1 - float3 {_S506.x, _S506.y, _S506.z} + (rg_1->pos_err_1 - float3 {_S507.x, _S507.y, _S507.z});
            float4  _S509 = __ldg(&(&(globalParams_0->chunks_0)[i_9])->center_0);
            float4  _S510 = *(&(globalParams_0->state_0)[4U * i_9]);
            float3  _S511 = rotate_0(&rg_1->rot_0, float3 {_S509.x, _S509.y, _S509.z} + float3 {_S510.x, _S510.y, _S510.z});
            value_1 = dot_0(_S508 + _S511, float3 {_S505.x, _S505.y, _S505.z});
        }
        else
        {
            if(kind_0 == 1U)
            {
                float4  _S512 = __ldg(&(&(globalParams_0->chunks_0)[i_9])->center_0);
                uint _S513 = 4U * i_9;
                float4  _S514 = *(&(globalParams_0->state_0)[_S513]);
                float4  _S515 = isl_2->com_0;
                float3  _S516 = rotate_0(&rg_1->rot_0, float3 {_S512.x, _S512.y, _S512.z} + float3 {_S514.x, _S514.y, _S514.z} - float3 {_S515.x, _S515.y, _S515.z});
                float3  _S517 = rg_1->vel_1 + rg_1->vel_err_1 + cross_0(rg_1->w_3, _S516);
                float4  _S518 = *(&(globalParams_0->state_0)[_S513 + 2U]);
                float3  _S519 = rotate_0(&rg_1->rot_0, float3 {_S518.x, _S518.y, _S518.z});
                value_1 = dot_0(_S517 + _S519, float3 {_S505.x, _S505.y, _S505.z});
            }
            else
            {
                if(kind_0 == 2U)
                {
                    uint _S520 = 3U * i_9;
                    float4  _S521 = *(&(globalParams_0->scratch_0)[_S520]);
                    float3  f_6 = float3 {_S521.x, _S521.y, _S521.z};
                    bool _S522 = (info_2.z) == 0U;
                    float3  mc_0;
                    if(_S522)
                    {
                        float4  _S523 = *(&(globalParams_0->scratch_0)[_S520 + 1U]);
                        mc_0 = float3 {_S523.x, _S523.y, _S523.z};
                    }
                    else
                    {
                        float4  _S524 = *(&(globalParams_0->scratch_0)[_S520 + 2U]);
                        mc_0 = float3 {_S524.x, _S524.y, _S524.z};
                    }
                    float3  fc_0;
                    if(_S522)
                    {
                        fc_0 = f_6;
                    }
                    else
                    {
                        fc_0 = - f_6;
                    }
                    value_1 = dot_0(fc_0, float3 {_S505.x, _S505.y, _S505.z}) + dot_0(mc_0, float3 {_S506.x, _S506.y, _S506.z});
                }
                else
                {
                    uint _S525 = 4U * i_9;
                    float3  _S526 = rotate_0(&rg_1->rot_0, make_float3 ((*(&(globalParams_0->state_0)[_S525 + 1U])).w, (*(&(globalParams_0->state_0)[_S525 + 2U])).w, (*(&(globalParams_0->state_0)[_S525 + 3U])).w));
                    value_1 = dot_0(_S526, float3 {_S505.x, _S505.y, _S505.z});
                }
            }
        }
        write_probe_0(info_2.w, k_11, value_1);
        at_5 = at_5 + 4U;
    }
    return;
}

static __device__ float time_since_0(float4  origin_0, uint k_12, float dt_3)
{
    float _S527 = __ldg(&globalParams_0->params_0->t_hi_0);
    float _S528 = _S527 - origin_0.x;
    float _S529 = __ldg(&globalParams_0->params_0->t_lo_0);
    return _S528 + (_S529 - origin_0.y) + float(k_12) * dt_3;
}

static __device__ float table_eval_0(uint offset_0, uint count_2, float tau_0)
{
    float4  _S530 = __ldg((&(globalParams_0->loads_0)[offset_0]));
    if(tau_0 <= (_S530.x))
    {
        return _S530.y;
    }
    uint i_10 = 1U;
    for(;;)
    {
        if(i_10 < count_2)
        {
        }
        else
        {
            break;
        }
        uint _S531 = offset_0 + i_10;
        float4  _S532 = __ldg((&(globalParams_0->loads_0)[_S531]));
        float _S533 = _S532.x;
        if(tau_0 <= _S533)
        {
            float4  _S534 = __ldg((&(globalParams_0->loads_0)[_S531 - 1U]));
            float _S535 = _S534.x;
            float _S536 = _S534.y;
            return _S536 + (tau_0 - _S535) / (F32_max((_S533 - _S535), (1.00000000317107685e-30f))) * (_S532.y - _S536);
        }
        i_10 = i_10 + 1U;
    }
    float4  _S537 = __ldg((&(globalParams_0->loads_0)[offset_0 + count_2 - 1U]));
    return _S537.y;
}

static __device__ float eval_function_0(uint term_0, uint k_13, float dt_4, float shift_0)
{
    uint _S538 = 5U * term_0;
    float4  _S539 = __ldg((&(globalParams_0->loads_0)[_S538]));
    uint4  info_3 = asuint_0(_S539);
    float4  _S540 = __ldg((&(globalParams_0->loads_0)[_S538 + 3U]));
    float4  _S541 = __ldg((&(globalParams_0->loads_0)[_S538 + 4U]));
    uint kind_1 = info_3.z;
    if(kind_1 == 0U)
    {
        return _S540.z;
    }
    float tau_1 = time_since_0(_S540, k_13, dt_4) + shift_0;
    float shape_1;
    if(kind_1 == 1U)
    {
        if(tau_1 <= 0.0f)
        {
            shape_1 = 0.0f;
        }
        else
        {
            float _S542 = _S541.x;
            if(tau_1 >= _S542)
            {
                shape_1 = _S541.y;
            }
            else
            {
                shape_1 = _S541.y * tau_1 / _S542;
            }
        }
        return shape_1;
    }
    bool _S543;
    if(kind_1 == 2U)
    {
        if(tau_1 < 0.0f)
        {
            _S543 = true;
        }
        else
        {
            _S543 = tau_1 > (_S541.x);
        }
        if(_S543)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S541.y * (F32_sin((3.14159274101257324f * tau_1 / _S541.x)));
        }
        return shape_1;
    }
    if(kind_1 == 3U)
    {
        float sn_0 = tau_1 / _S541.y;
        if(sn_0 < 0.0f)
        {
            _S543 = true;
        }
        else
        {
            _S543 = sn_0 > 1.0f;
        }
        if(_S543)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S541.x * (1.0f - sn_0) * (F32_exp((- _S541.z * sn_0)));
        }
        return shape_1;
    }
    if(kind_1 == 4U)
    {
        return table_eval_0(info_3.w, (F32_asuint((_S541.x))), tau_1);
    }
    if(kind_1 == 5U)
    {
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float sn_1 = tau_1 / _S541.x;
        if(sn_1 < 0.0f)
        {
            _S543 = true;
        }
        else
        {
            _S543 = sn_1 > 1.0f;
        }
        if(_S543)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = (1.0f - sn_1) * (F32_exp((- _S541.y * sn_1)));
        }
        float clearing_0 = _S540.w;
        float relax_0;
        if(clearing_0 > 0.0f)
        {
            relax_0 = (F32_max((1.0f - tau_1 / clearing_0), (0.0f)));
        }
        else
        {
            relax_0 = 0.0f;
        }
        float _S544 = _S541.w;
        return (_S544 + (_S541.z - _S544) * relax_0) * shape_1;
    }
    if(kind_1 == 7U)
    {
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float _S545 = _S541.y;
        if(tau_1 < _S545)
        {
            return _S541.x;
        }
        float s_4 = tau_1 - _S545;
        float _S546 = _S541.w;
        if(s_4 > _S546)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S541.z * (F32_sin((3.14159274101257324f * s_4 / _S546)));
        }
        return shape_1;
    }
    float _S547 = _S541.x;
    if(_S547 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp_0(1.0f - tau_1 / _S547, 0.0f, 1.0f);
}

static __device__ void record_chunk_load_0(uint c_7, float3  f_7, float3  t_5)
{
    uint _S548 = __ldg(&globalParams_0->params_0->solve_mode_0);
    if(_S548 == 0U)
    {
        return;
    }
    uint _S549 = __ldg(&globalParams_0->params_0->cload_base_0);
    uint _S550 = 2U * c_7;
    *(&(globalParams_0->scratch_0)[_S549 + _S550]) = make_float4 (f_7.x, f_7.y, f_7.z, 0.0f);
    uint _S551 = __ldg(&globalParams_0->params_0->cload_base_0);
    *(&(globalParams_0->scratch_0)[_S551 + _S550 + 1U]) = make_float4 (t_5.x, t_5.y, t_5.z, 0.0f);
    uint _S552 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  * _S553 = (&(globalParams_0->scratch_0)[_S552 + _S550]);
    uint _S554 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  _S555 = *(&(globalParams_0->scratch_0)[_S554 + _S550]);
    *_S553 = make_float4 ((float3 {_S555.x, _S555.y, _S555.z} + f_7).x, (float3 {_S555.x, _S555.y, _S555.z} + f_7).y, (float3 {_S555.x, _S555.y, _S555.z} + f_7).z, 0.0f);
    uint _S556 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  * _S557 = (&(globalParams_0->scratch_0)[_S556 + _S550 + 1U]);
    uint _S558 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  _S559 = *(&(globalParams_0->scratch_0)[_S558 + _S550 + 1U]);
    *_S557 = make_float4 ((float3 {_S559.x, _S559.y, _S559.z} + t_5).x, (float3 {_S559.x, _S559.y, _S559.z} + t_5).y, (float3 {_S559.x, _S559.y, _S559.z} + t_5).z, 0.0f);
    return;
}

static __device__ void chunk_external_0(uint _S560, uint _S561, Quat_0 * _S562, uint _S563, float _S564, bool _S565, float3  * _S566, float3  * _S567)
{
    bool _S568;
    ChunkStatic_0 * _S569 = (&(globalParams_0->chunks_0)[_S561]);
    float3  _S570 = make_float3 (0.0f);
    *_S566 = _S570;
    *_S567 = _S570;
    uint4  _S571 = __ldg(&_S569->load_range_0);
    uint term_1 = _S571.x;
    for(;;)
    {
        if(term_1 < (_S571.y))
        {
        }
        else
        {
            break;
        }
        uint _S572 = 5U * term_1;
        float4  _S573 = __ldg((&(globalParams_0->loads_0)[_S572]));
        uint _S574 = asuint_0(_S573).y;
        if(_S574 == 2U)
        {
            term_1 = term_1 + 1U;
            continue;
        }
        float4  _S575 = __ldg((&(globalParams_0->loads_0)[_S572 + 1U]));
        float4  _S576 = __ldg((&(globalParams_0->loads_0)[_S572 + 2U]));
        float value_2 = eval_function_0(term_1, _S563, _S564, 0.0f);
        if(_S574 == 0U)
        {
            _S568 = true;
        }
        else
        {
            _S568 = _S574 == 3U;
        }
        float3  fw_0;
        if(_S568)
        {
            fw_0 = float3 {_S575.x, _S575.y, _S575.z} * make_float3 (value_2);
        }
        else
        {
            float3  _S577 = rotate_0(_S562, float3 {_S575.x, _S575.y, _S575.z});
            fw_0 = _S577 * make_float3 (- value_2 * _S575.w);
        }
        float3  lever_0;
        if(_S574 == 3U)
        {
            float4  _S578 = *(&(globalParams_0->state_0)[4U * _S560]);
            lever_0 = float3 {_S576.x, _S576.y, _S576.z} - float3 {_S578.x, _S578.y, _S578.z};
        }
        else
        {
            lever_0 = float3 {_S576.x, _S576.y, _S576.z};
        }
        *_S566 = *_S566 + fw_0;
        float3  _S579 = rotate_0(_S562, lever_0);
        *_S567 = *_S567 + cross_0(_S579, fw_0);
        term_1 = term_1 + 1U;
    }
    if(_S565)
    {
        uint4  _S580 = __ldg(&_S569->cinfo_0);
        _S568 = (_S580.z) != 0U;
    }
    else
    {
        _S568 = false;
    }
    if(_S568)
    {
        uint4  _S581 = __ldg(&_S569->cinfo_0);
        uint g_2 = _S581.x;
        for(;;)
        {
            if(g_2 < (_S581.y))
            {
            }
            else
            {
                break;
            }
            uint _S582 = __ldg(&globalParams_0->params_0->seg_base_0);
            uint _S583 = 2U * g_2;
            float4  _S584 = *(&(globalParams_0->scratch_0)[_S582 + _S583]);
            *_S566 = *_S566 + float3 {_S584.x, _S584.y, _S584.z};
            uint _S585 = __ldg(&globalParams_0->params_0->seg_base_0);
            float4  _S586 = *(&(globalParams_0->scratch_0)[_S585 + _S583 + 1U]);
            *_S567 = *_S567 + float3 {_S586.x, _S586.y, _S586.z};
            g_2 = g_2 + 1U;
        }
    }
    return;
}

static __device__ float settled_chunk_load_0(uint c_8, Quat_0 * rot_1, uint k_14, float dt_5, bool contact_0)
{
    float3  f_8;
    float3  t_6;
    chunk_external_0(c_8, c_8, rot_1, k_14, dt_5, contact_0, &f_8, &t_6);
    record_chunk_load_0(c_8, f_8, t_6);
    return length_0(f_8);
}

static __device__ void group_sum3_0(uint tid_3, float3  * a_7, float3  * b_21)
{
    float4  x_13 = make_float4 ((*a_7).x, (*a_7).y, (*a_7).z, 0.0f);
    float4  y_4 = make_float4 ((*b_21).x, (*b_21).y, (*b_21).z, 0.0f);
    group_sum2_0(tid_3, &x_13, &y_4);
    float4  _S587 = x_13;
    *a_7 = float3 {_S587.x, _S587.y, _S587.z};
    float4  _S588 = y_4;
    *b_21 = float3 {_S588.x, _S588.y, _S588.z};
    return;
}

static __device__ void net_load_0(uint c_9, Island_0 * isl_3, Rigid_0 * rg_2, uint k_15, float dt_6, bool contact_1, float3  * f_9, float3  * t_7)
{
    ChunkStatic_0 * _S589 = (&(globalParams_0->chunks_0)[c_9]);
    float3  fl_0;
    float3  tl_0;
    chunk_external_0(c_9, c_9, &rg_2->rot_0, k_15, dt_6, contact_1, &fl_0, &tl_0);
    float3  _S590 = fl_0;
    float4  _S591 = __ldg(&globalParams_0->params_0->gravity_0);
    float3  _S592 = float3 {_S591.x, _S591.y, _S591.z};
    float4  _S593 = __ldg(&_S589->center_0);
    float3  fc_1 = _S590 + _S592 * make_float3 (_S593.w);
    float3  _S594 = float3 {_S593.x, _S593.y, _S593.z};
    float4  _S595 = *(&(globalParams_0->state_0)[4U * c_9]);
    float4  _S596 = isl_3->com_0;
    float3  _S597 = float3 {_S596.x, _S596.y, _S596.z};
    float3  _S598 = rotate_0(&rg_2->rot_0, _S594 + float3 {_S595.x, _S595.y, _S595.z} - _S597);
    *f_9 = *f_9 + fc_1;
    *t_7 = *t_7 + (cross_0(_S598, fc_1) + tl_0);
    uint4  _S599 = __ldg(&_S589->load_range_0);
    uint term_2 = _S599.x;
    for(;;)
    {
        if(term_2 < (_S599.y))
        {
        }
        else
        {
            break;
        }
        uint _S600 = 5U * term_2;
        float4  _S601 = __ldg((&(globalParams_0->loads_0)[_S600]));
        if((asuint_0(_S601).y) != 2U)
        {
            term_2 = term_2 + 1U;
            continue;
        }
        float kf_0 = eval_function_0(term_2, k_15, dt_6, 0.0f);
        float4  _S602 = __ldg((&(globalParams_0->loads_0)[_S600 + 1U]));
        float3  _S603 = rotate_0(&rg_2->rot_0, float3 {_S602.x, _S602.y, _S602.z} * make_float3 (kf_0));
        *f_9 = *f_9 + _S603;
        float3  _S604 = rotate_0(&rg_2->rot_0, _S594 - _S597);
        float3  _S605 = cross_0(_S604, _S603);
        float4  _S606 = __ldg((&(globalParams_0->loads_0)[_S600 + 2U]));
        float3  _S607 = rotate_0(&rg_2->rot_0, float3 {_S606.x, _S606.y, _S606.z} * make_float3 (kf_0));
        *t_7 = *t_7 + (_S605 + _S607);
        term_2 = term_2 + 1U;
    }
    return;
}

static __device__ void rigid_acceleration_0(Island_0 * isl_4, Rigid_0 * rg_3, float3  f_10, float3  t_8)
{
    Quat_0 _S608 = rg_3->rot_0;
    float3  _S609 = world_mul_0(&_S608, isl_4->inertia0_1, isl_4->inertia1_1, isl_4->inertia2_1, rg_3->w_3);
    rg_3->a_6 = f_10 / make_float3 (isl_4->com_0.w);
    float3  _S610 = t_8 - cross_0(rg_3->w_3, _S609);
    Quat_0 _S611 = rg_3->rot_0;
    float3  _S612 = world_mul_0(&_S611, isl_4->inv0_1, isl_4->inv1_1, isl_4->inv2_1, _S610);
    rg_3->alpha_0 = _S612;
    return;
}

static __device__ void integrate_rigid_0(Island_0 * isl_5, Rigid_0 * rg_4, float dt_7)
{
    Quat_0 _S613 = rg_4->rot_0;
    float3  _S614 = world_mul_0(&_S613, isl_5->inertia0_1, isl_5->inertia1_1, isl_5->inertia2_1, rg_4->w_3);
    Quat_0 _S615 = rg_4->rot_0;
    float3  _S616 = world_mul_0(&_S615, isl_5->inertia0_1, isl_5->inertia1_1, isl_5->inertia2_1, rg_4->alpha_0);
    float3  l_2 = _S614 + (_S616 + cross_0(rg_4->w_3, _S614)) * make_float3 (dt_7);
    comp_add_0(&rg_4->vel_1, &rg_4->vel_err_1, rg_4->a_6 * make_float3 (dt_7));
    float3  vel_2 = rg_4->vel_1 + rg_4->vel_err_1;
    float4  _S617 = isl_5->inv0_1;
    float4  _S618 = isl_5->inv1_1;
    float4  _S619 = isl_5->inv2_1;
    Quat_0 _S620 = rg_4->rot_0;
    float3  _S621 = world_mul_0(&_S620, isl_5->inv0_1, isl_5->inv1_1, isl_5->inv2_1, l_2);
    Quat_0 _S622 = rg_4->rot_0;
    Quat_0 _S623 = integrate_rotation_0(&_S622, _S621, dt_7);
    float3  _S624 = vel_2 * make_float3 (dt_7);
    float4  _S625 = isl_5->com_0;
    float3  _S626 = float3 {_S625.x, _S625.y, _S625.z};
    Quat_0 _S627 = rg_4->rot_0;
    float3  _S628 = rotate_0(&_S627, _S626);
    Quat_0 _S629 = _S623;
    float3  _S630 = rotate_0(&_S629, _S626);
    comp_add_0(&rg_4->pos_1, &rg_4->pos_err_1, _S624 + (_S628 - _S630));
    rg_4->rot_0 = _S623;
    Quat_0 _S631 = _S623;
    float3  _S632 = world_mul_0(&_S631, _S617, _S618, _S619, l_2);
    rg_4->w_3 = _S632;
    return;
}

static __device__ JointBond_0 slang_ldg_0(JointBond_0 * ptr_0)
{
    float4  _S633 = __ldg(&ptr_0->geom0_0);
    float4  _S634 = __ldg(&ptr_0->geom1_0);
    float4  _S635 = __ldg(&ptr_0->stiff0_0);
    float4  _S636 = __ldg(&ptr_0->stiff1_0);
    float4  _S637 = __ldg(&ptr_0->rebar0_0);
    float4  _S638 = __ldg(&ptr_0->rebar1_0);
    uint4  _S639 = __ldg(&ptr_0->ids_0);
    JointBond_0 _S640 = { _S633, _S634, _S635, _S636, _S637, _S638, _S639 };
    return _S640;
}

static __device__ bool connected_0(JointState_0 * st_0, bool has_rebar_0)
{
    bool _S641;
    if((st_0->damage_0) < 1.0f)
    {
        _S641 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S641 = (st_0->rebar_broken_0) == 0.0f;
        }
        else
        {
            _S641 = false;
        }
    }
    return _S641;
}

static __device__ float fdiv_0(float a_8, float b_22)
{
    return a_8 / b_22;
}

static __device__ float fsqrt_0(float a_9)
{
    return (F32_sqrt((a_9)));
}

struct Measures_0
{
    float tension_0;
    float shear_0;
    float normal_compression_0;
    float compression_0;
    float compressive_force_0;
};

static __device__ Measures_0 stress_measures_0(JointBond_0 * b_23, float3  q_lin_0, float3  q_ang_0)
{
    float area_2 = b_23->geom0_0.x;
    float _S642 = q_lin_0.z;
    float axial_0 = fdiv_0(_S642, area_2);
    float bending_0 = fdiv_0((F32_abs((q_ang_0.x))), b_23->geom1_0.x) + fdiv_0((F32_abs((q_ang_0.y))), b_23->geom1_0.y);
    float _S643 = q_lin_0.x;
    float _S644 = q_lin_0.y;
    float shear_1 = fdiv_0(fsqrt_0(_S643 * _S643 + _S644 * _S644), area_2) + fdiv_0((F32_abs((q_ang_0.z))), b_23->geom0_0.w);
    Measures_0 m_3;
    (&m_3)->tension_0 = axial_0 + bending_0;
    (&m_3)->shear_0 = shear_1;
    float _S645 = - axial_0;
    (&m_3)->normal_compression_0 = (F32_max((_S645), (0.0f)));
    (&m_3)->compression_0 = _S645 + bending_0;
    (&m_3)->compressive_force_0 = (F32_max((- _S642), (0.0f)));
    return m_3;
}

static __device__ float expm1_accurate_0(float x_14)
{
    if((F32_abs((x_14))) < 0.00100000004749745f)
    {
        return x_14 * (1.0f + x_14 * (0.5f + x_14 * 0.1666666716337204f));
    }
    return (F32_exp((x_14))) - 1.0f;
}

static __device__ float fpow_0(float a_10, float b_24)
{
    return (F32_pow((a_10), (b_24)));
}

static __device__ float dif_factor_0(JointMaterial_0 * mat_1, float strain_rate_1)
{
    float r_6 = (F32_abs((strain_rate_1)));
    float4  _S646 = mat_1->dif_0;
    float ref_0 = mat_1->dif_0.x;
    if(r_6 <= ref_0)
    {
        return 1.0f;
    }
    float _S647 = _S646.z;
    float f_11;
    if(r_6 <= _S647)
    {
        f_11 = fpow_0(fdiv_0(r_6, ref_0), _S646.y);
    }
    else
    {
        f_11 = fpow_0(fdiv_0(_S647, ref_0), _S646.y) * fpow_0(fdiv_0(r_6, _S647), _S646.w);
    }
    return clamp_0(f_11, 1.0f, mat_1->misc_0.x);
}

static __device__ float fatigue_factor_0(JointMaterial_0 * mat_2, float fatigue_1)
{
    if(((mat_2->kind_flags_0.y) & 64U) == 0U)
    {
        return 1.0f;
    }
    return fpow_0(1.0f - clamp_0(fatigue_1, 0.0f, 1.0f), fdiv_0(1.0f, mat_2->misc_0.y - 2.0f));
}

static __device__ float infinity_0()
{
    return (U32_asfloat((2139095040U)));
}

static __device__ float4  failure_indices_0(JointMaterial_0 * mat_3, JointBond_0 * b_25, Measures_0 * m_4, float multiplier_0)
{
    float fc_2 = mat_3->strength_0.y * multiplier_0;
    float _S648 = (F32_min((mat_3->strength_0.z * multiplier_0 + mat_3->strength_0.w * m_4->normal_compression_0), (mat_3->energy_0.x * multiplier_0)));
    float4  idx_0;
    *&((&idx_0)->x) = (F32_max((fdiv_0(m_4->tension_0, mat_3->strength_0.x * multiplier_0)), (0.0f)));
    float _S649;
    if(_S648 > 0.0f)
    {
        _S649 = fdiv_0(m_4->shear_0, _S648);
    }
    else
    {
        _S649 = infinity_0();
    }
    *&((&idx_0)->y) = _S649;
    *&((&idx_0)->z) = (F32_max((fdiv_0(m_4->compression_0, fc_2)), (0.0f)));
    float _S650 = b_25->stiff1_0.y;
    if(_S650 > 0.0f)
    {
        _S649 = fdiv_0(m_4->compressive_force_0, _S650);
    }
    else
    {
        _S649 = 0.0f;
    }
    *&((&idx_0)->w) = _S649;
    return idx_0;
}

static __device__ float sq_0(float x_15)
{
    return x_15 * x_15;
}

static __device__ float damage_law_0(uint kind_2, float kappa_1, float r_7)
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
        return (F32_min((fdiv_0(r_7 * (kappa_1 - 1.0f), kappa_1 * (r_7 - 1.0f))), (1.0f)));
    }
    if(kappa_1 >= (0.5f * (r_7 + 1.0f)))
    {
        return 1.0f;
    }
    return 1.0f - fdiv_0(1.0f, kappa_1);
}

static __device__ float2  damage_increment_0(uint kind_3, float kappa_old_0, float lambda_0, float r_8, float d_old_0, float psi_0)
{
    float _S651 = (F32_max((damage_law_0(kind_3, lambda_0, r_8)), (d_old_0)));
    bool _S652;
    if(_S651 <= d_old_0)
    {
        _S652 = true;
    }
    else
    {
        _S652 = d_old_0 >= 1.0f;
    }
    if(_S652)
    {
        return make_float2 (d_old_0, 0.0f);
    }
    float u0_0 = fdiv_0(psi_0, lambda_0 * lambda_0);
    float _S653 = (F32_max((kappa_old_0), (1.0f)));
    if(kind_3 == 0U)
    {
        if(r_8 > 1.0f)
        {
            return make_float2 (_S651, fdiv_0(u0_0 * r_8, r_8 - 1.0f) * (F32_max(((F32_min((lambda_0), (r_8))) - (F32_min((_S653), (r_8)))), (0.0f))));
        }
        return make_float2 (_S651, (1.0f - d_old_0) * psi_0);
    }
    float ku_0 = 0.5f * (r_8 + 1.0f);
    float plateau_0 = u0_0 * (F32_max(((F32_min((lambda_0), (ku_0))) - (F32_min((_S653), (ku_0)))), (0.0f)));
    float snap_0;
    if(_S651 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return make_float2 (_S651, plateau_0 + snap_0);
}

static __device__ void compressed_region_0(float w0_0, float w1_0, float dz_0, float ax_0, float ay_0, FixedArray<float, 6>  * region_0)
{
    uint count_3;
    float h0_0 = 0.5f * w0_0;
    float h1_0 = 0.5f * w1_0;
    float _S654 = - h0_0;
    float _S655 = - h1_0;
    FixedArray<float2 , 4>  _S656 = { {
        float2 {
            _S654, _S655
        }, float2 {
            h0_0, _S655
        }, float2 {
            h0_0, h1_0
        }, float2 {
            _S654, h1_0
        }
    } };
    FixedArray<float2 , 8>  poly_0;
    uint i_11 = 0U;
    uint count_4 = 0U;
    for(;;)
    {
        if(i_11 < 4U)
        {
        }
        else
        {
            break;
        }
        uint _S657 = i_11;
        uint _S658 = i_11 + 1U;
        uint _S659 = _S658 % 4U;
        float _S660 = _S656[i_11].y;
        float _S661 = _S656[i_11].x;
        float fp_0 = dz_0 + ax_0 * _S660 - ay_0 * _S661;
        float _S662 = _S656[_S659].y;
        float _S663 = _S656[_S659].x;
        float fq_0 = dz_0 + ax_0 * _S662 - ay_0 * _S663;
        bool _S664 = fp_0 < 0.0f;
        if(_S664)
        {
            uint _S665 = count_4 + 1U;
            poly_0[count_4] = _S656[_S657];
            count_3 = _S665;
        }
        else
        {
            count_3 = count_4;
        }
        if(_S664 != (fq_0 < 0.0f))
        {
            float t_9 = fp_0 / (fp_0 - fq_0);
            uint _S666 = count_3 + 1U;
            poly_0[count_3] = make_float2 (_S661 + t_9 * (_S663 - _S661), _S660 + t_9 * (_S662 - _S660));
            count_4 = _S666;
        }
        else
        {
            count_4 = count_3;
        }
        i_11 = _S658;
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
    float2  o_1 = poly_0[int(0)];
    i_11 = 0U;
    float a_11 = 0.0f;
    float sx_0 = 0.0f;
    float sy_0 = 0.0f;
    float ixx_0 = 0.0f;
    float iyy_0 = 0.0f;
    float ixy_0 = 0.0f;
    for(;;)
    {
        if(i_11 < count_4)
        {
        }
        else
        {
            break;
        }
        float _S667 = o_1.x;
        float x0_0 = poly_0[i_11].x - _S667;
        float _S668 = o_1.y;
        float y0_0 = poly_0[i_11].y - _S668;
        uint _S669 = i_11 + 1U;
        uint _S670 = _S669 % count_4;
        float x1_0 = poly_0[_S670].x - _S667;
        float y1_0 = poly_0[_S670].y - _S668;
        float _S671 = x0_0 * y1_0;
        float _S672 = x1_0 * y0_0;
        float cr_0 = _S671 - _S672;
        float a_12 = a_11 + cr_0 / 2.0f;
        float sx_1 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        float sy_1 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        float ixx_1 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        float iyy_1 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        float ixy_1 = ixy_0 + (_S671 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S672) * cr_0 / 24.0f;
        i_11 = _S669;
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
    float _S673 = a_11 * cx_0;
    (*region_0)[int(3)] = ixx_0 - _S673 * cx_0;
    (*region_0)[int(4)] = iyy_0 - a_11 * cy_0 * cy_0;
    (*region_0)[int(5)] = ixy_0 - _S673 * cy_0;
    return;
}

static __device__ float4  no_tension_patch_0(float kn_0, float w0_1, float w1_1, float dz_1, float ax_1, float ay_1)
{
    FixedArray<float, 6>  r_9;
    compressed_region_0(w0_1, w1_1, dz_1, ax_1, ay_1, &r_9);
    float a_13 = r_9[int(0)];
    if((r_9[int(0)]) == 0.0f)
    {
        return make_float4 (0.0f);
    }
    float k_16 = kn_0 / (w0_1 * w1_1);
    float fc_3 = dz_1 + ax_1 * r_9[int(2)] - ay_1 * r_9[int(1)];
    float _S674 = a_13 * fc_3;
    float _S675 = - ay_1;
    return make_float4 (k_16 * a_13 * fc_3, k_16 * (_S674 * r_9[int(2)] + (_S675 * r_9[int(5)] + ax_1 * r_9[int(4)])), - k_16 * (_S674 * r_9[int(1)] + (_S675 * r_9[int(3)] + ax_1 * r_9[int(5)])), 0.5f * k_16 * (_S674 * fc_3 + ay_1 * ay_1 * r_9[int(3)] + ax_1 * ax_1 * r_9[int(4)] - 2.0f * ax_1 * ay_1 * r_9[int(5)]));
}

static __device__ float signum_0(float x_16)
{
    float _S676;
    if(((F32_asuint((x_16))) & 2147483648U) != 0U)
    {
        _S676 = -1.0f;
    }
    else
    {
        _S676 = 1.0f;
    }
    return _S676;
}

static __device__ float2  return_map_0(float k_17, float total_2, float plastic_0, float cap_0)
{
    float trial_0 = k_17 * (total_2 - plastic_0);
    if((F32_abs((trial_0))) <= cap_0)
    {
        return make_float2 (trial_0, 0.0f);
    }
    float f_12 = cap_0 * signum_0(trial_0);
    return make_float2 (f_12, fdiv_0(trial_0 - f_12, k_17));
}

struct Contact_0
{
    float3  q_lin_1;
    float3  q_ang_1;
    float energy_2;
    float diss_4;
    float3  plastic_1;
};

static __device__ Contact_0 contact_part_0(JointMaterial_0 * mat_4, JointBond_0 * b_26, float crush_2, float3  plastic_2, float3  d_lin_0, float3  d_ang_0)
{
    Contact_0 c_10;
    float3  _S677 = make_float3 (0.0f);
    (&c_10)->q_lin_1 = _S677;
    (&c_10)->q_ang_1 = _S677;
    (&c_10)->energy_2 = 0.0f;
    (&c_10)->diss_4 = 0.0f;
    (&c_10)->plastic_1 = plastic_2;
    uint _S678 = mat_4->kind_flags_0.y;
    if((_S678 & 2U) == 0U)
    {
        return c_10;
    }
    float kn_1 = b_26->stiff0_0.x;
    float ks_0 = b_26->stiff0_0.y;
    float kt_0 = b_26->stiff1_0.x;
    float w0_2 = b_26->geom0_0.y;
    float w1_2 = b_26->geom0_0.z;
    float diss_5;
    float nc_sum_0;
    float m1_0;
    float m2_0;
    float energy_3;
    if((_S678 & 4U) != 0U)
    {
        float4  p_9 = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        float _S679 = p_9.y;
        float _S680 = p_9.z;
        float _S681 = p_9.w;
        nc_sum_0 = p_9.x;
        m1_0 = _S679;
        m2_0 = _S680;
        energy_3 = _S681;
    }
    else
    {
        float ki_0 = kn_1 * (1.0f - crush_2) / 36.0f;
        float _S682 = d_ang_0.x;
        float _S683 = d_ang_0.y;
        float spread_0 = (F32_abs((_S682))) * 0.4166666567325592f * w1_2 + (F32_abs((_S683))) * 0.4166666567325592f * w0_2;
        float _S684 = d_lin_0.z;
        float slack_0 = 9.99999997475242708e-07f * ((F32_abs((_S684))) + spread_0);
        if((_S684 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S684 + spread_0) < (- slack_0))
            {
                float i1_0 = 2.91666650772094727f * w0_2 * w0_2;
                float i2_0 = 2.91666650772094727f * w1_2 * w1_2;
                float _S685 = ki_0 * _S682 * i2_0;
                float _S686 = ki_0 * _S683 * i1_0;
                float _S687 = 0.5f * ki_0 * (36.0f * _S684 * _S684 + _S682 * _S682 * i2_0 + _S683 * _S683 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S684;
                m1_0 = _S685;
                m2_0 = _S686;
                energy_3 = _S687;
            }
            else
            {
                uint i_12 = 0U;
                diss_5 = 0.0f;
                float m1_1 = 0.0f;
                float m2_1 = 0.0f;
                float energy_4 = 0.0f;
                for(;;)
                {
                    if(i_12 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float _S688 = ((float(i_12) + 0.5f) / 6.0f - 0.5f) * w0_2;
                    uint j_4 = 0U;
                    nc_sum_0 = diss_5;
                    m1_0 = m1_1;
                    m2_0 = m2_1;
                    energy_3 = energy_4;
                    for(;;)
                    {
                        if(j_4 < 6U)
                        {
                        }
                        else
                        {
                            break;
                        }
                        float s2_0 = ((float(j_4) + 0.5f) / 6.0f - 0.5f) * w1_2;
                        float di_0 = _S684 + _S682 * s2_0 - _S683 * _S688;
                        if(di_0 < 0.0f)
                        {
                            float f_13 = ki_0 * di_0;
                            float m1_2 = m1_0 + f_13 * s2_0;
                            float m2_2 = m2_0 - f_13 * _S688;
                            float energy_5 = energy_3 + 0.5f * ki_0 * di_0 * di_0;
                            nc_sum_0 = nc_sum_0 + f_13;
                            m1_0 = m1_2;
                            m2_0 = m2_2;
                            energy_3 = energy_5;
                        }
                        j_4 = j_4 + 1U;
                    }
                    i_12 = i_12 + 1U;
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
    float3  p_10 = plastic_2;
    (&c_10)->q_lin_1 = make_float3 (0.0f, 0.0f, nc_sum_0);
    (&c_10)->q_ang_1 = make_float3 (m1_0, m2_0, 0.0f);
    float slide_cap_0 = mat_4->strength_0.w * nc_0;
    float _S689 = ks_0 * (d_lin_0.x - plastic_2.x);
    float _S690 = ks_0 * (d_lin_0.y - plastic_2.y);
    float tn_0 = fsqrt_0(_S689 * _S689 + _S690 * _S690);
    bool _S691;
    if(tn_0 > slide_cap_0)
    {
        _S691 = tn_0 > 0.0f;
    }
    else
    {
        _S691 = false;
    }
    if(_S691)
    {
        float _S692 = fdiv_0(_S689, tn_0);
        float _S693 = fdiv_0(_S690, tn_0);
        float dslip_0 = fdiv_0(tn_0 - slide_cap_0, ks_0);
        *&((&p_10)->x) = *&((&p_10)->x) + _S692 * dslip_0;
        *&((&p_10)->y) = *&((&p_10)->y) + _S693 * dslip_0;
        *&((&(&c_10)->q_lin_1)->x) = _S692 * slide_cap_0;
        *&((&(&c_10)->q_lin_1)->y) = _S693 * slide_cap_0;
        diss_5 = slide_cap_0 * dslip_0;
    }
    else
    {
        *&((&(&c_10)->q_lin_1)->x) = _S689;
        *&((&(&c_10)->q_lin_1)->y) = _S690;
        diss_5 = 0.0f;
    }
    float2  tq_0 = return_map_0(kt_0, d_ang_0.z, p_10.z, slide_cap_0 * b_26->geom1_0.z);
    float _S694 = tq_0.x;
    float _S695 = tq_0.y;
    float diss_6 = diss_5 + (F32_abs((_S694))) * (F32_abs((_S695)));
    *&((&p_10)->z) = *&((&p_10)->z) + _S695;
    *&((&(&c_10)->q_ang_1)->z) = _S694;
    (&c_10)->energy_2 = energy_3 + 0.5f * (fdiv_0(sq_0((&c_10)->q_lin_1.x), ks_0) + fdiv_0(sq_0((&c_10)->q_lin_1.y), ks_0) + fdiv_0(sq_0(_S694), kt_0));
    (&c_10)->diss_4 = diss_6;
    (&c_10)->plastic_1 = p_10;
    return c_10;
}

static __device__ float life_rate_0(JointMaterial_0 * mat_5, float s_5)
{
    if(s_5 <= 0.0f)
    {
        return 0.0f;
    }
    float _S696 = mat_5->misc_0.y;
    return fdiv_0((_S696 + 1.0f) * fpow_0(s_5, _S696), mat_5->misc_0.z);
}

struct JointResponse_0
{
    float3  force_lin_1;
    float3  force_ang_1;
    JointState_0 state_1;
    float dissipated_2;
    float overshoot_0;
    float stored_5;
    bool disconnected_0;
    Measures_0 measures_0;
};

static __device__ JointResponse_0 joint_evaluate_0(JointMaterial_0 * mat_6, JointBond_0 * b_27, JointState_0 * state_2, float3  d_lin_1, float3  d_ang_1, float dt_8, bool fracture_1)
{
    float kn_2 = b_27->stiff0_0.x;
    float ks_1 = b_27->stiff0_0.y;
    float kb1_0 = b_27->stiff0_0.z;
    float kb2_0 = b_27->stiff0_0.w;
    float4  _S697 = b_27->stiff1_0;
    float kt_1 = b_27->stiff1_0.x;
    bool has_rebar_1 = (b_27->stiff1_0.w) != 0.0f;
    uint kind_4 = mat_6->kind_flags_0.x;
    uint flags_1 = mat_6->kind_flags_0.y;
    bool softening_0 = (flags_1 & 1U) != 0U;
    JointState_0 st_1 = *state_2;
    bool _S698 = connected_0(state_2, has_rebar_1);
    float3  qe_lin_0 = d_lin_1 * make_float3 (ks_1, ks_1, kn_2);
    float3  qe_ang_0 = d_ang_1 * make_float3 (kb1_0, kb2_0, kt_1);
    Measures_0 _S699 = stress_measures_0(b_27, qe_lin_0, qe_ang_0);
    float _S700 = (F32_max(((F32_max((_S699.tension_0), (_S699.shear_0)))), (_S699.compression_0)));
    bool _S701 = dt_8 > 0.0f;
    float dif_1;
    if(_S701)
    {
        float raw_0 = fdiv_0((F32_max((fdiv_0(_S700 - (&st_1)->governing_stress_0, dt_8)), (0.0f))), mat_6->misc_0.w);
        float tau_2 = _S697.z;
        if((flags_1 & 16U) != 0U)
        {
            dif_1 = - expm1_accurate_0(- fdiv_0(dt_8, tau_2));
        }
        else
        {
            dif_1 = (F32_min((fdiv_0(dt_8, tau_2)), (1.0f)));
        }
        (&st_1)->strain_rate_0 = (&st_1)->strain_rate_0 + (raw_0 - (&st_1)->strain_rate_0) * dif_1;
        (&st_1)->governing_stress_0 = _S700;
    }
    if((flags_1 & 32U) != 0U)
    {
        float _S702 = dif_factor_0(mat_6, (&st_1)->strain_rate_0);
        dif_1 = _S702;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = b_27->geom1_0.w;
    float _S703 = weibull_0 * dif_1;
    float _S704 = fatigue_factor_0(mat_6, (&st_1)->fatigue_0);
    float multiplier_1 = _S703 * _S704;
    Measures_0 _S705 = _S699;
    float4  _S706 = failure_indices_0(mat_6, b_27, &_S705, multiplier_1);
    float _S707 = _S706.x;
    float _S708 = _S706.y;
    (&st_1)->utilization_0 = (F32_max(((F32_max((_S707), (_S708)))), ((F32_max((_S706.z), (_S706.w))))));
    float _S709 = d_lin_1.x;
    float _S710 = d_lin_1.y;
    float _S711 = ks_1 * (sq_0(_S709) + sq_0(_S710)) + kb1_0 * sq_0(d_ang_1.x) + kb2_0 * sq_0(d_ang_1.y) + kt_1 * sq_0(d_ang_1.z);
    float _S712 = d_lin_1.z;
    bool _S713 = _S712 > 0.0f;
    if(_S713)
    {
        dif_1 = kn_2 * sq_0(_S712);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S711 + dif_1);
    float psi_c_0;
    if(_S712 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_2 * sq_0(_S712);
    }
    else
    {
        psi_c_0 = 0.0f;
    }
    float3  plastic_3 = make_float3 ((&st_1)->plastic_x_0, (&st_1)->plastic_y_0, (&st_1)->plastic_t_0);
    float diss_contact_0;
    float psi_contact_0;
    float intact_normal_0;
    float dissipated_3;
    float overshoot_1;
    bool _S714;
    float3  qc_lin_0;
    if(fracture_1)
    {
        bool _S715 = _S707 >= _S708;
        if(_S715)
        {
            diss_contact_0 = _S707;
        }
        else
        {
            diss_contact_0 = _S708;
        }
        uint mode_ts_0;
        if(_S715)
        {
            mode_ts_0 = 1U;
        }
        else
        {
            mode_ts_0 = 2U;
        }
        if(diss_contact_0 > ((&st_1)->kappa_0))
        {
            _S714 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S714 = false;
        }
        if(_S714)
        {
            _S714 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S714 = false;
        }
        uint mode_c_0;
        if(_S714)
        {
            if(mode_ts_0 == 1U)
            {
                psi_contact_0 = mat_6->energy_0.y;
            }
            else
            {
                psi_contact_0 = mat_6->energy_0.z;
            }
            if(softening_0)
            {
                intact_normal_0 = fdiv_0(psi_contact_0 * b_27->geom0_0.x * diss_contact_0 * diss_contact_0, psi_ts_0);
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
            float2  inc_0 = damage_increment_0(mode_c_0, (&st_1)->kappa_0, diss_contact_0, intact_normal_0, (&st_1)->damage_0, psi_ts_0);
            float _S716 = inc_0.x;
            if(_S716 > ((&st_1)->damage_0))
            {
                Contact_0 _S717 = contact_part_0(mat_6, b_27, (&st_1)->crush_0, plastic_3, d_lin_1, d_ang_1);
                float _S718 = (F32_max((_S717.energy_2 - (1.0f - (&st_1)->crush_0) * psi_c_0), (0.0f)));
                float _S719 = (F32_max((inc_0.y - _S718 * (_S716 - (&st_1)->damage_0)), (0.0f)));
                float _S720 = (F32_max(((psi_ts_0 - _S718) * (_S716 - (&st_1)->damage_0) - _S719), (0.0f)));
                (&st_1)->damage_0 = _S716;
                (&st_1)->mode_0 = mode_ts_0;
                dissipated_3 = _S719;
                overshoot_1 = _S720;
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
        (&st_1)->kappa_0 = (F32_max(((&st_1)->kappa_0), (diss_contact_0)));
        float _S721 = state_2->damage_0;
        if((state_2->damage_0) > 0.0f)
        {
            Contact_0 _S722 = contact_part_0(mat_6, b_27, state_2->crush_0, make_float3 (state_2->plastic_x_0, state_2->plastic_y_0, state_2->plastic_t_0), d_lin_1, d_ang_1);
            qc_lin_0 = qe_ang_0 * make_float3 (1.0f - _S721) + _S722.q_ang_1 * make_float3 (_S721);
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S723 = stress_measures_0(b_27, make_float3 (0.0f, 0.0f, (F32_min((qe_lin_0.z), (0.0f)))), qc_lin_0);
        Measures_0 _S724 = _S723;
        float4  _S725 = failure_indices_0(mat_6, b_27, &_S724, multiplier_1);
        float _S726 = _S725.z;
        float _S727 = _S725.w;
        bool _S728 = _S726 >= _S727;
        if(_S728)
        {
            psi_contact_0 = _S726;
        }
        else
        {
            psi_contact_0 = _S727;
        }
        if(_S728)
        {
            mode_c_0 = 3U;
        }
        else
        {
            mode_c_0 = 4U;
        }
        if(psi_contact_0 > ((&st_1)->kappa_c_0))
        {
            _S714 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S714 = false;
        }
        if(_S714)
        {
            _S714 = psi_c_0 > 0.0f;
        }
        else
        {
            _S714 = false;
        }
        if(_S714)
        {
            if(softening_0)
            {
                intact_normal_0 = fdiv_0(mat_6->energy_0.w * b_27->geom0_0.x * psi_contact_0 * psi_contact_0, psi_c_0);
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
            float2  inc_1 = damage_increment_0(law_1, (&st_1)->kappa_c_0, psi_contact_0, intact_normal_0, (&st_1)->crush_0, psi_c_0);
            float _S729 = inc_1.x;
            if(_S729 > ((&st_1)->crush_0))
            {
                float _S730 = inc_1.y;
                float dissipated_4 = dissipated_3 + _S730;
                float overshoot_2 = overshoot_1 + (F32_max((psi_c_0 * (_S729 - (&st_1)->crush_0) - _S730), (0.0f)));
                (&st_1)->crush_0 = _S729;
                (&st_1)->mode_0 = mode_c_0;
                if(_S729 >= 1.0f)
                {
                    _S714 = ((&st_1)->damage_0) < 1.0f;
                }
                else
                {
                    _S714 = false;
                }
                if(_S714)
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
        (&st_1)->kappa_c_0 = (F32_max(((&st_1)->kappa_c_0), (psi_contact_0)));
    }
    else
    {
        dissipated_3 = 0.0f;
        overshoot_1 = 0.0f;
    }
    float dmg_0 = (&st_1)->damage_0;
    float3  _S731 = make_float3 (0.0f);
    if(((&st_1)->damage_0) == 0.0f)
    {
        _S714 = (flags_1 & 8U) != 0U;
    }
    else
    {
        _S714 = false;
    }
    float3  qc_ang_0;
    if(!_S714)
    {
        Contact_0 _S732 = contact_part_0(mat_6, b_27, (&st_1)->crush_0, plastic_3, d_lin_1, d_ang_1);
        (&st_1)->plastic_x_0 = _S732.plastic_1.x;
        (&st_1)->plastic_y_0 = _S732.plastic_1.y;
        (&st_1)->plastic_t_0 = _S732.plastic_1.z;
        diss_contact_0 = _S732.diss_4;
        qc_lin_0 = _S732.q_lin_1;
        qc_ang_0 = _S732.q_ang_1;
        psi_contact_0 = _S732.energy_2;
    }
    else
    {
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S731;
        qc_ang_0 = _S731;
        psi_contact_0 = 0.0f;
    }
    float dissipated_6 = dissipated_3 + dmg_0 * diss_contact_0;
    if(_S713)
    {
        intact_normal_0 = kn_2 * _S712;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_1)->crush_0) * kn_2 * _S712;
    }
    float _S733 = 1.0f - dmg_0;
    float3  force_lin_2 = make_float3 (_S733 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S733 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S733 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3  force_ang_2 = qe_ang_0 * make_float3 (_S733) + qc_ang_0 * make_float3 (dmg_0);
    float stored_6 = _S733 * (psi_ts_0 + (1.0f - (&st_1)->crush_0) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S714 = ((&st_1)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S714 = false;
    }
    float stored_7;
    float3  force_lin_3;
    if(_S714)
    {
        float k_axial_0 = b_27->rebar0_0.x;
        float k_dowel_0 = b_27->rebar0_0.y;
        float yield_force_0 = b_27->rebar0_0.z;
        float dowel_capacity_0 = b_27->rebar0_0.w;
        float2  nr_0 = return_map_0(k_axial_0, _S712, (&st_1)->rebar_plastic_0, yield_force_0);
        float2  v1_0 = return_map_0(k_dowel_0, _S709, (&st_1)->rebar_slip0_0, dowel_capacity_0);
        float2  v2_0 = return_map_0(k_dowel_0, _S710, (&st_1)->rebar_slip1_0, dowel_capacity_0);
        float _S734 = nr_0.y;
        float _S735 = v1_0.y;
        float _S736 = v2_0.y;
        float work_0 = yield_force_0 * (F32_abs((_S734))) + dowel_capacity_0 * ((F32_abs((_S735))) + (F32_abs((_S736))));
        (&st_1)->rebar_plastic_0 = (&st_1)->rebar_plastic_0 + _S734;
        (&st_1)->rebar_slip0_0 = (&st_1)->rebar_slip0_0 + _S735;
        (&st_1)->rebar_slip1_0 = (&st_1)->rebar_slip1_0 + _S736;
        (&st_1)->rebar_work_0 = (&st_1)->rebar_work_0 + work_0;
        float dissipated_7 = dissipated_6 + work_0;
        float _S737 = nr_0.x;
        float _S738 = v1_0.x;
        float _S739 = v2_0.x;
        float elastic_0 = 0.5f * (fdiv_0(sq_0(_S737), k_axial_0) + fdiv_0(sq_0(_S738) + sq_0(_S739), k_dowel_0));
        if(fracture_1)
        {
            _S714 = ((&st_1)->rebar_work_0) >= (b_27->rebar1_0.x);
        }
        else
        {
            _S714 = false;
        }
        if(_S714)
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
            force_lin_3 = force_lin_2 + make_float3 (_S738, _S739, _S737);
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
        _S714 = _S701;
    }
    else
    {
        _S714 = false;
    }
    if(_S714)
    {
        _S714 = (flags_1 & 64U) != 0U;
    }
    else
    {
        _S714 = false;
    }
    if(_S714)
    {
        Measures_0 _S740 = stress_measures_0(b_27, force_lin_3, force_ang_2);
        Measures_0 _S741 = _S740;
        float4  _S742 = failure_indices_0(mat_6, b_27, &_S741, weibull_0);
        float _S743 = life_rate_0(mat_6, (F32_max(((F32_max((_S742.x), (_S742.y)))), (_S742.z))));
        (&st_1)->fatigue_0 = (F32_min(((&st_1)->fatigue_0 + _S743 * dt_8), (1.0f)));
    }
    (&st_1)->dissipated_0 = (&st_1)->dissipated_0 + dissipated_3;
    JointResponse_0 resp_0;
    (&resp_0)->force_lin_1 = force_lin_3;
    (&resp_0)->force_ang_1 = force_ang_2;
    (&resp_0)->state_1 = st_1;
    (&resp_0)->dissipated_2 = dissipated_3;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_5 = stored_7;
    if(_S698)
    {
        JointState_0 _S744 = st_1;
        bool _S745 = connected_0(&_S744, has_rebar_1);
        _S714 = !_S745;
    }
    else
    {
        _S714 = false;
    }
    (&resp_0)->disconnected_0 = _S714;
    (&resp_0)->measures_0 = _S699;
    return resp_0;
}

static __device__ void secant_factors_0(JointBond_0 * b_28, JointState_0 * st_2, float3  d_lin_2, float3  * f_lin_0, float3  * f_ang_0)
{
    float _S746 = st_2->damage_0;
    bool compressed_0 = (d_lin_2.z) < 0.0f;
    float contact_2;
    if(compressed_0)
    {
        contact_2 = _S746;
    }
    else
    {
        contact_2 = 0.0f;
    }
    float _S747 = 1.0f - _S746;
    float _S748 = (F32_max((_S747 + contact_2), (9.99999997475242708e-07f)));
    float normal_4;
    if(compressed_0)
    {
        normal_4 = (F32_max((1.0f - st_2->crush_0), (9.99999997475242708e-07f)));
    }
    else
    {
        normal_4 = (F32_max((_S747), (9.99999997475242708e-07f)));
    }
    *f_lin_0 = make_float3 (_S748, _S748, normal_4);
    *f_ang_0 = make_float3 (_S748);
    bool _S749;
    if((b_28->stiff1_0.w) != 0.0f)
    {
        _S749 = (st_2->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S749 = false;
    }
    if(_S749)
    {
        float4  _S750 = b_28->rebar0_0;
        float4  _S751 = b_28->stiff0_0;
        *&(f_lin_0->z) = *&(f_lin_0->z) + fdiv_0(b_28->rebar0_0.x, b_28->stiff0_0.x);
        float _S752 = fdiv_0(_S750.y, _S751.y);
        *&(f_lin_0->x) = *&(f_lin_0->x) + _S752;
        *&(f_lin_0->y) = *&(f_lin_0->y) + _S752;
    }
    return;
}

static __device__ bool is_damaged_0(JointState_0 * st_3)
{
    bool _S753;
    if((st_3->damage_0) > 0.0f)
    {
        _S753 = true;
    }
    else
    {
        _S753 = (st_3->crush_0) > 0.0f;
    }
    return _S753;
}

static __device__ float3  to_local_0(uint _S754, float3  _S755)
{
    BondStatic_0 * _S756 = (&(globalParams_0->bonds_0)[_S754]);
    float4  _S757 = __ldg(&_S756->t1_0);
    float _S758 = dot_0(_S755, float3 {_S757.x, _S757.y, _S757.z});
    float4  _S759 = __ldg(&_S756->t2_0);
    float _S760 = dot_0(_S755, float3 {_S759.x, _S759.y, _S759.z});
    float4  _S761 = __ldg(&_S756->normal_0);
    return make_float3 (_S758, _S760, dot_0(_S755, float3 {_S761.x, _S761.y, _S761.z}));
}

static __device__ float3  to_body_0(uint _S762, float3  _S763)
{
    BondStatic_0 * _S764 = (&(globalParams_0->bonds_0)[_S762]);
    float4  _S765 = __ldg(&_S764->t1_0);
    float3  _S766 = float3 {_S765.x, _S765.y, _S765.z} * make_float3 (_S763.x);
    float4  _S767 = __ldg(&_S764->t2_0);
    float3  _S768 = _S766 + float3 {_S767.x, _S767.y, _S767.z} * make_float3 (_S763.y);
    float4  _S769 = __ldg(&_S764->normal_0);
    return _S768 + float3 {_S769.x, _S769.y, _S769.z} * make_float3 (_S763.z);
}

static __device__ bool bond_update_0(uint i_13, float dt_9, bool fracture_2, uint abs_step_0)
{
    BondStatic_0 * _S770 = (&(globalParams_0->bonds_0)[i_13]);
    BondDyn_0 bd_0 = *(&(globalParams_0->bond_dyn_0)[i_13]);
    JointBond_0 _S771 = slang_ldg_0(&_S770->law_0);
    uint ca_0 = _S771.ids_0.y;
    uint cb_0 = _S771.ids_0.z;
    float4  _S772 = __ldg(&_S770->ra_0);
    float3  ra_1 = float3 {_S772.x, _S772.y, _S772.z};
    float4  _S773 = __ldg(&_S770->rb_0);
    float3  rb_1 = float3 {_S773.x, _S773.y, _S773.z};
    uint _S774 = 4U * ca_0;
    float4  _S775 = *(&(globalParams_0->state_0)[_S774]);
    float4  _S776 = *(&(globalParams_0->state_0)[_S774 + 1U]);
    float3  ta_2 = float3 {_S776.x, _S776.y, _S776.z};
    float4  _S777 = *(&(globalParams_0->state_0)[_S774 + 2U]);
    float3  va_0 = float3 {_S777.x, _S777.y, _S777.z};
    float4  _S778 = *(&(globalParams_0->state_0)[_S774 + 3U]);
    float3  wa_1 = float3 {_S778.x, _S778.y, _S778.z};
    uint _S779 = 4U * cb_0;
    float4  _S780 = *(&(globalParams_0->state_0)[_S779]);
    float4  _S781 = *(&(globalParams_0->state_0)[_S779 + 1U]);
    float3  tb_2 = float3 {_S781.x, _S781.y, _S781.z};
    float4  _S782 = *(&(globalParams_0->state_0)[_S779 + 2U]);
    float3  vb_0 = float3 {_S782.x, _S782.y, _S782.z};
    float4  _S783 = *(&(globalParams_0->state_0)[_S779 + 3U]);
    float3  wb_0 = float3 {_S783.x, _S783.y, _S783.z};
    float3  _S784 = to_local_0(i_13, float3 {_S780.x, _S780.y, _S780.z} + cross_0(tb_2, rb_1) - (float3 {_S775.x, _S775.y, _S775.z} + cross_0(ta_2, ra_1)));
    float3  _S785 = to_local_0(i_13, tb_2 - ta_2);
    float3  _S786 = to_local_0(i_13, vb_0 + cross_0(wb_0, rb_1) - (va_0 + cross_0(wa_1, ra_1)));
    float3  _S787 = to_local_0(i_13, wb_0 - wa_1);
    JointState_0 previous_0 = (&bd_0)->js_0;
    JointBond_0 _S788 = _S771;
    JointState_0 _S789 = (&bd_0)->js_0;
    JointResponse_0 _S790 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S771.ids_0.x], &_S788, &_S789, _S784, _S785, dt_9, fracture_2);
    JointBond_0 _S791 = _S771;
    JointState_0 _S792 = _S790.state_1;
    float3  f_lin_1;
    float3  f_ang_1;
    secant_factors_0(&_S791, &_S792, _S784, &f_lin_1, &f_ang_1);
    float4  _S793 = __ldg(&_S770->c_lin_0);
    float3  qd_lin_0 = _S786 * float3 {_S793.x, _S793.y, _S793.z} * f_lin_1;
    float4  _S794 = __ldg(&_S770->c_ang_0);
    float3  qd_ang_0 = _S787 * float3 {_S794.x, _S794.y, _S794.z} * f_ang_1;
    float3  q_lin_2 = _S790.force_lin_1 + qd_lin_0;
    float3  q_ang_2 = _S790.force_ang_1 + qd_ang_0;
    float damped_0 = (dot_0(qd_lin_0, _S786) + dot_0(qd_ang_0, _S787)) * dt_9;
    float3  _S795 = to_body_0(i_13, q_lin_2);
    float3  _S796 = to_body_0(i_13, q_ang_2);
    uint _S797 = 3U * i_13;
    *(&(globalParams_0->scratch_0)[_S797]) = make_float4 (_S795.x, _S795.y, _S795.z, (F32_max((_S790.measures_0.tension_0), (_S790.measures_0.compression_0))));
    *(&(globalParams_0->scratch_0)[_S797 + 1U]) = make_float4 ((_S796 + cross_0(ra_1, _S795)).x, (_S796 + cross_0(ra_1, _S795)).y, (_S796 + cross_0(ra_1, _S795)).z, 0.0f);
    *(&(globalParams_0->scratch_0)[_S797 + 2U]) = make_float4 ((- _S796 + cross_0(rb_1, - _S795)).x, (- _S796 + cross_0(rb_1, - _S795)).y, (- _S796 + cross_0(rb_1, - _S795)).z, 0.0f);
    comp_add1_0(&((&(&bd_0)->sums_0)->x), &((&(&bd_0)->comps_0)->x), _S790.dissipated_2);
    comp_add1_0(&((&(&bd_0)->sums_0)->y), &((&(&bd_0)->comps_0)->y), _S790.overshoot_0);
    comp_add1_0(&((&(&bd_0)->sums_0)->z), &((&(&bd_0)->comps_0)->z), damped_0);
    (&bd_0)->force_lin_0 = make_float4 (q_lin_2.x, q_lin_2.y, q_lin_2.z, _S790.stored_5);
    (&bd_0)->force_ang_0 = make_float4 (q_ang_2.x, q_ang_2.y, q_ang_2.z, (F32_max(((&bd_0)->force_ang_0.w), (_S790.state_1.utilization_0))));
    JointState_0 _S798 = previous_0;
    bool _S799 = is_damaged_0(&_S798);
    bool _S800;
    if(!_S799)
    {
        JointState_0 _S801 = _S790.state_1;
        bool _S802 = is_damaged_0(&_S801);
        _S800 = _S802;
    }
    else
    {
        _S800 = false;
    }
    if(_S800)
    {
        _S800 = ((&bd_0)->events_0.x) == 0U;
    }
    else
    {
        _S800 = false;
    }
    if(_S800)
    {
        *&((&(&bd_0)->events_0)->x) = abs_step_0;
        *&((&(&bd_0)->events_0)->w) = _S790.state_1.mode_0;
    }
    if(((&bd_0)->events_0.y) == 0U)
    {
        float _S803 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S771.ids_0.x], previous_0.fatigue_0);
        _S800 = _S803 > 0.99000000953674316f;
    }
    else
    {
        _S800 = false;
    }
    if(_S800)
    {
        float _S804 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S771.ids_0.x], _S790.state_1.fatigue_0);
        _S800 = _S804 <= 0.99000000953674316f;
    }
    else
    {
        _S800 = false;
    }
    if(_S800)
    {
        *&((&(&bd_0)->events_0)->y) = abs_step_0;
    }
    if(_S790.disconnected_0)
    {
        *&((&(&bd_0)->events_0)->z) = abs_step_0;
    }
    (&bd_0)->js_0 = _S790.state_1;
    *(&(globalParams_0->bond_dyn_0)[i_13]) = bd_0;
    return _S790.disconnected_0;
}

static __device__ void chunk_update_0(uint c_11, Island_0 * isl_6, Rigid_0 * rg_5, float dt_10, bool rml_0, uint step_0, bool contact_3, float * work_1, float * work_err_0)
{
    ChunkStatic_0 * _S805 = (&(globalParams_0->chunks_0)[c_11]);
    float3  _S806 = make_float3 (0.0f);
    uint _S807 = __ldg((&(globalParams_0->index_0)[c_11]));
    float peak_0 = 0.0f;
    uint e_3 = _S807;
    float3  fi_0 = _S806;
    float3  mi_0 = _S806;
    for(;;)
    {
        uint _S808 = __ldg((&(globalParams_0->index_0)[c_11 + 1U]));
        if(e_3 < _S808)
        {
        }
        else
        {
            break;
        }
        uint _S809 = __ldg((&(globalParams_0->index_0)[e_3]));
        uint _S810 = 3U * (_S809 >> int(1));
        float4  fa_2 = *(&(globalParams_0->scratch_0)[_S810]);
        if((_S809 & 1U) == 0U)
        {
            float4  _S811 = *(&(globalParams_0->scratch_0)[_S810 + 1U]);
            float3  mi_1 = mi_0 + float3 {_S811.x, _S811.y, _S811.z};
            fi_0 = fi_0 + float3 {fa_2.x, fa_2.y, fa_2.z};
            mi_0 = mi_1;
        }
        else
        {
            float4  _S812 = *(&(globalParams_0->scratch_0)[_S810 + 2U]);
            float3  mi_2 = mi_0 + float3 {_S812.x, _S812.y, _S812.z};
            fi_0 = fi_0 + - float3 {fa_2.x, fa_2.y, fa_2.z};
            mi_0 = mi_2;
        }
        float _S813 = (F32_max((peak_0), (fa_2.w)));
        uint _S814 = e_3 + 1U;
        peak_0 = _S813;
        e_3 = _S814;
    }
    uint _S815 = 4U * c_11;
    float4  _S816 = *(&(globalParams_0->state_0)[_S815]);
    float3  u_0 = float3 {_S816.x, _S816.y, _S816.z};
    uint _S817 = _S815 + 1U;
    float4  _S818 = *(&(globalParams_0->state_0)[_S817]);
    float3  th_1 = float3 {_S818.x, _S818.y, _S818.z};
    uint _S819 = _S815 + 2U;
    float4  _S820 = *(&(globalParams_0->state_0)[_S819]);
    float3  v_10 = float3 {_S820.x, _S820.y, _S820.z};
    uint _S821 = _S815 + 3U;
    float4  _S822 = *(&(globalParams_0->state_0)[_S821]);
    float3  w_4 = float3 {_S822.x, _S822.y, _S822.z};
    float4  _S823 = __ldg(&_S805->center_0);
    float mass_0 = _S823.w;
    float3  _S824 = float3 {_S823.x, _S823.y, _S823.z};
    float4  _S825 = isl_6->com_0;
    float3  _S826 = float3 {_S825.x, _S825.y, _S825.z};
    float3  _S827 = rotate_0(&rg_5->rot_0, _S824 + u_0 - _S826);
    float3  f_load_0;
    float3  t_load_0;
    chunk_external_0(c_11, c_11, &rg_5->rot_0, step_0, dt_10, contact_3, &f_load_0, &t_load_0);
    record_chunk_load_0(c_11, f_load_0, t_load_0);
    float3  _S828 = f_load_0;
    float4  _S829 = __ldg(&globalParams_0->params_0->gravity_0);
    float3  f_world_0 = _S828 + float3 {_S829.x, _S829.y, _S829.z} * make_float3 (mass_0);
    float3  t_world_0 = t_load_0;
    float3  f_world_1;
    float3  t_world_1;
    if(rml_0)
    {
        float3  _S830 = rg_5->alpha_0;
        float3  _S831 = rg_5->w_3;
        float3  f_world_2 = f_world_0 - (rg_5->a_6 + cross_0(rg_5->alpha_0, _S827) + cross_0(rg_5->w_3, cross_0(rg_5->w_3, _S827))) * make_float3 (mass_0);
        float4  _S832 = __ldg(&_S805->inertia0_0);
        float4  _S833 = __ldg(&_S805->inertia1_0);
        float4  _S834 = __ldg(&_S805->inertia2_0);
        float3  _S835 = world_mul_0(&rg_5->rot_0, _S832, _S833, _S834, _S830);
        float3  _S836 = world_mul_0(&rg_5->rot_0, _S832, _S833, _S834, _S831);
        float3  t_world_2 = t_world_0 - (_S835 + cross_0(_S831, _S836));
        f_world_1 = f_world_2;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    float3  _S837 = inverse_rotate_0(&rg_5->rot_0, f_world_1);
    float3  _S838 = inverse_rotate_0(&rg_5->rot_0, t_world_1);
    float3  f_ext_0;
    float3  m_ext_0;
    if(rml_0)
    {
        float3  _S839 = inverse_rotate_0(&rg_5->rot_0, rg_5->w_3);
        float3  f_ext_1 = _S837 - cross_0(_S839, v_10) * make_float3 (2.0f * mass_0);
        float4  _S840 = __ldg(&_S805->inertia0_0);
        float4  _S841 = __ldg(&_S805->inertia1_0);
        float4  _S842 = __ldg(&_S805->inertia2_0);
        float3  i_w_0 = rows_mul_0(_S840, _S841, _S842, w_4);
        float3  m_ext_1 = _S838 - (cross_0(_S839, i_w_0) + cross_0(w_4, rows_mul_0(_S840, _S841, _S842, _S839)) + cross_0(w_4, i_w_0));
        f_ext_0 = f_ext_1;
        m_ext_0 = m_ext_1;
    }
    else
    {
        f_ext_0 = _S837;
        m_ext_0 = _S838;
    }
    uint4  _S843 = __ldg(&_S805->load_range_0);
    uint term_3 = _S843.x;
    for(;;)
    {
        if(term_3 < (_S843.y))
        {
        }
        else
        {
            break;
        }
        uint _S844 = 5U * term_3;
        float4  _S845 = __ldg((&(globalParams_0->loads_0)[_S844]));
        if((asuint_0(_S845).y) != 2U)
        {
            term_3 = term_3 + 1U;
            continue;
        }
        float kf_1 = eval_function_0(term_3, step_0, dt_10, dt_10);
        float4  _S846 = __ldg((&(globalParams_0->loads_0)[_S844 + 1U]));
        float3  f_ext_2 = f_ext_0 + float3 {_S846.x, _S846.y, _S846.z} * make_float3 (kf_1);
        float4  _S847 = __ldg((&(globalParams_0->loads_0)[_S844 + 2U]));
        float3  m_ext_2 = m_ext_0 + float3 {_S847.x, _S847.y, _S847.z} * make_float3 (kf_1);
        f_ext_0 = f_ext_2;
        m_ext_0 = m_ext_2;
        term_3 = term_3 + 1U;
    }
    float3  f_14 = f_ext_0 + fi_0;
    float3  m_5 = m_ext_0 + mi_0;
    uint4  _S848 = __ldg(&_S805->info_0);
    uint support_0 = _S848.x;
    float3  _S849 = make_float3 ((*(&(globalParams_0->state_0)[_S817])).w, (*(&(globalParams_0->state_0)[_S819])).w, (*(&(globalParams_0->state_0)[_S821])).w);
    float3  reaction_0;
    float3  u_1;
    float3  th_2;
    float3  v_11;
    float3  w_5;
    if(support_0 == 1U)
    {
        reaction_0 = - f_14;
        u_1 = u_0;
        th_2 = th_1;
        v_11 = _S806;
        w_5 = _S806;
    }
    else
    {
        float4  _S850 = __ldg(&_S805->inv0_0);
        float4  _S851 = __ldg(&_S805->inv1_0);
        float4  _S852 = __ldg(&_S805->inv2_0);
        float3  _S853 = rows_mul_0(_S850, _S851, _S852, m_5);
        float4  _S854 = __ldg(&_S805->scale_0);
        float3  w_6 = w_4 + _S853 * make_float3 (dt_10 * _S854.z);
        float3  th_3 = th_1 + w_6 * make_float3 (dt_10);
        if(support_0 == 2U)
        {
            reaction_0 = - f_14;
            u_1 = u_0;
            th_2 = _S806;
        }
        else
        {
            float3  v_12 = v_10 + f_14 * make_float3 (dt_10 * _S854.y);
            float3  u_2 = u_0 + v_12 * make_float3 (dt_10);
            reaction_0 = _S849;
            u_1 = u_2;
            th_2 = v_12;
        }
        float3  _S855 = th_2;
        th_2 = th_3;
        v_11 = _S855;
        w_5 = w_6;
    }
    *(&(globalParams_0->state_0)[_S815]) = make_float4 (u_1.x, u_1.y, u_1.z, peak_0);
    *(&(globalParams_0->state_0)[_S817]) = make_float4 (th_2.x, th_2.y, th_2.z, reaction_0.x);
    *(&(globalParams_0->state_0)[_S819]) = make_float4 (v_11.x, v_11.y, v_11.z, reaction_0.y);
    *(&(globalParams_0->state_0)[_S821]) = make_float4 (w_5.x, w_5.y, w_5.z, reaction_0.z);
    float3  _S856 = rotate_0(&rg_5->rot_0, _S824 + u_1 - _S826);
    float3  _S857 = rg_5->vel_1 + rg_5->vel_err_1 + cross_0(rg_5->w_3, _S856);
    float3  _S858 = rotate_0(&rg_5->rot_0, v_11);
    float3  v_world_0 = _S857 + _S858;
    float3  _S859 = rotate_0(&rg_5->rot_0, w_5);
    comp_add1_0(work_1, work_err_0, (dot_0(f_load_0, v_world_0) + dot_0(t_load_0, rg_5->w_3 + _S859)) * dt_10);
    return;
}

static __device__ void drift_moments_0(uint c_12, float3  * tu_0, float3  * pv_0)
{
    ChunkStatic_0 * _S860 = (&(globalParams_0->chunks_0)[c_12]);
    float4  _S861 = __ldg(&_S860->center_0);
    float _S862 = _S861.w;
    float4  _S863 = __ldg(&_S860->scale_0);
    float m_6 = _S862 * _S863.x;
    uint _S864 = 4U * c_12;
    float4  _S865 = *(&(globalParams_0->state_0)[_S864]);
    *tu_0 = *tu_0 + float3 {_S865.x, _S865.y, _S865.z} * make_float3 (m_6);
    float4  _S866 = *(&(globalParams_0->state_0)[_S864 + 2U]);
    *pv_0 = *pv_0 + float3 {_S866.x, _S866.y, _S866.z} * make_float3 (m_6);
    return;
}

static __device__ void drift_angular_0(uint c_13, float3  wcom_1, float3  tr_0, float3  dv_0, float3  * lu_0, float3  * lv_0)
{
    ChunkStatic_0 * _S867 = (&(globalParams_0->chunks_0)[c_13]);
    float4  _S868 = __ldg(&_S867->center_0);
    float3  r_10 = float3 {_S868.x, _S868.y, _S868.z} - wcom_1;
    float4  _S869 = __ldg(&_S867->scale_0);
    float kw_0 = _S869.x;
    uint _S870 = 4U * c_13;
    float4  _S871 = *(&(globalParams_0->state_0)[_S870]);
    float _S872 = _S868.w;
    float3  _S873 = cross_0(r_10, float3 {_S871.x, _S871.y, _S871.z} - tr_0) * make_float3 (_S872);
    float4  _S874 = __ldg(&_S867->inertia0_0);
    float4  _S875 = __ldg(&_S867->inertia1_0);
    float4  _S876 = __ldg(&_S867->inertia2_0);
    float4  _S877 = *(&(globalParams_0->state_0)[_S870 + 1U]);
    *lu_0 = *lu_0 + (_S873 + rows_mul_0(_S874, _S875, _S876, float3 {_S877.x, _S877.y, _S877.z})) * make_float3 (kw_0);
    float4  _S878 = *(&(globalParams_0->state_0)[_S870 + 2U]);
    float4  _S879 = *(&(globalParams_0->state_0)[_S870 + 3U]);
    *lv_0 = *lv_0 + (cross_0(r_10, float3 {_S878.x, _S878.y, _S878.z} - dv_0) * make_float3 (_S872) + rows_mul_0(_S874, _S875, _S876, float3 {_S879.x, _S879.y, _S879.z})) * make_float3 (kw_0);
    return;
}

static __device__ void drift_apply_0(uint c_14, float3  wcom_2, float3  tr_1, float3  phi_0, float3  dv_1, float3  dw_0)
{
    float4  _S880 = __ldg(&(&(globalParams_0->chunks_0)[c_14])->center_0);
    float3  r_11 = float3 {_S880.x, _S880.y, _S880.z} - wcom_2;
    uint _S881 = 4U * c_14;
    float4  _S882 = *(&(globalParams_0->state_0)[_S881]);
    *(&(globalParams_0->state_0)[_S881]) = make_float4 ((float3 {_S882.x, _S882.y, _S882.z} - (tr_1 + cross_0(phi_0, r_11))).x, (float3 {_S882.x, _S882.y, _S882.z} - (tr_1 + cross_0(phi_0, r_11))).y, (float3 {_S882.x, _S882.y, _S882.z} - (tr_1 + cross_0(phi_0, r_11))).z, (*(&(globalParams_0->state_0)[_S881])).w);
    uint _S883 = _S881 + 1U;
    float4  _S884 = *(&(globalParams_0->state_0)[_S883]);
    *(&(globalParams_0->state_0)[_S883]) = make_float4 ((float3 {_S884.x, _S884.y, _S884.z} - phi_0).x, (float3 {_S884.x, _S884.y, _S884.z} - phi_0).y, (float3 {_S884.x, _S884.y, _S884.z} - phi_0).z, (*(&(globalParams_0->state_0)[_S883])).w);
    uint _S885 = _S881 + 2U;
    float4  _S886 = *(&(globalParams_0->state_0)[_S885]);
    *(&(globalParams_0->state_0)[_S885]) = make_float4 ((float3 {_S886.x, _S886.y, _S886.z} - (dv_1 + cross_0(dw_0, r_11))).x, (float3 {_S886.x, _S886.y, _S886.z} - (dv_1 + cross_0(dw_0, r_11))).y, (float3 {_S886.x, _S886.y, _S886.z} - (dv_1 + cross_0(dw_0, r_11))).z, (*(&(globalParams_0->state_0)[_S885])).w);
    uint _S887 = _S881 + 3U;
    float4  _S888 = *(&(globalParams_0->state_0)[_S887]);
    *(&(globalParams_0->state_0)[_S887]) = make_float4 ((float3 {_S888.x, _S888.y, _S888.z} - dw_0).x, (float3 {_S888.x, _S888.y, _S888.z} - dw_0).y, (float3 {_S888.x, _S888.y, _S888.z} - dw_0).z, (*(&(globalParams_0->state_0)[_S887])).w);
    return;
}

static __device__ void drift_rigid_0(Island_0 * isl_7, Rigid_0 * rg_6, float3  tr_2, float3  phi_1, float3  dv_2, float3  dw_1)
{
    float4  _S889 = isl_7->wcom_0;
    float3  wcom_3 = float3 {_S889.x, _S889.y, _S889.z};
    Quat_0 rot_2 = rg_6->rot_0;
    float3  _S890 = tr_2 - cross_0(phi_1, wcom_3);
    Quat_0 _S891 = rg_6->rot_0;
    float3  _S892 = rotate_0(&_S891, _S890);
    comp_add_0(&rg_6->pos_1, &rg_6->pos_err_1, _S892);
    Quat_0 _S893 = from_axis_angle_0(phi_1, length_0(phi_1));
    Quat_0 _S894 = rg_6->rot_0;
    Quat_0 _S895 = _S893;
    Quat_0 _S896 = quat_mul_0(&_S894, &_S895);
    Quat_0 _S897 = _S896;
    Quat_0 _S898 = normalized_0(&_S897);
    rg_6->rot_0 = _S898;
    float4  _S899 = isl_7->com_0;
    float3  _S900 = dv_2 + cross_0(dw_1, float3 {_S899.x, _S899.y, _S899.z} - wcom_3);
    Quat_0 _S901 = rot_2;
    float3  _S902 = rotate_0(&_S901, _S900);
    comp_add_0(&rg_6->vel_1, &rg_6->vel_err_1, _S902);
    Quat_0 _S903 = rot_2;
    float3  _S904 = rotate_0(&_S903, dw_1);
    rg_6->w_3 = rg_6->w_3 + _S904;
    return;
}

static __device__ void contact_split_at_0(uint at_6)
{
    uint _S905 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint previous_1 = (&(globalParams_0->islands_0)[_S905])->info_1.y;
    uint _S906 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint _S907;
    if(previous_1 == 0U)
    {
        _S907 = at_6;
    }
    else
    {
        _S907 = (U32_min((previous_1), (at_6)));
    }
    *&((&(&(globalParams_0->islands_0)[_S906])->info_1)->y) = _S907;
    return;
}

extern "C" __global__ void island_frame()
{
    bool woke_0;
    uint tid_4 = threadIdx.x;
    uint _S908 = blockIdx.x;
    Island_0 isl_8 = *(&(globalParams_0->islands_0)[_S908]);
    bool driven_0 = (((&isl_8)->info_1.x) & 2U) != 0U;
    bool _S909 = !((((&isl_8)->info_1.x) & 1U) != 0U);
    bool _S910;
    if(_S909)
    {
        _S910 = !driven_0;
    }
    else
    {
        _S910 = false;
    }
    bool contact_island_0 = (((&isl_8)->info_1.x) & 4U) != 0U;
    bool _S911 = (((&isl_8)->info_1.x) & 16U) != 0U;
    bool _S912 = tid_4 == 0U;
    bool settled_0;
    uint run_0;
    if(_S912)
    {
        uint _S913 = __ldg(&globalParams_0->params_0->contact_mode_0);
        if(contact_island_0 != (_S913 == 1U))
        {
            settled_0 = true;
        }
        else
        {
            settled_0 = (((&isl_8)->info_1.x) & 8U) != 0U;
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
            Island_0 _S914 = isl_8;
            bool _S915 = contact_stopped_0(&_S914);
            settled_0 = _S915;
        }
        else
        {
            settled_0 = false;
        }
        if(settled_0)
        {
            run_0 = 0U;
        }
        *&g_run_0 = run_0;
        *&g_halt_0 = 0U;
    }
    __syncthreads();
    if((((&isl_8)->info_1.z) & 1U) != 0U)
    {
        settled_0 = true;
    }
    else
    {
        settled_0 = (*&g_run_0) == 0U;
    }
    if(settled_0)
    {
        run_0 = 0U;
    }
    else
    {
        uint _S916 = (&isl_8)->info_1.y;
        uint _S917 = __ldg(&globalParams_0->params_0->max_steps_0);
        run_0 = (U32_min((_S916), (_S917)));
    }
    float _S918 = __ldg(&globalParams_0->params_0->dt_0);
    uint _S919 = __ldg(&globalParams_0->params_0->fracture_0);
    bool _S920 = _S919 != 0U;
    uint _S921 = __ldg(&globalParams_0->params_0->rigid_motion_loads_0);
    bool _S922 = _S921 != 0U;
    Island_0 _S923 = isl_8;
    Rigid_0 _S924 = rigid_of_0(&_S923);
    Rigid_0 rg_7 = _S924;
    float work_2 = 0.0f;
    float work_err_1 = 0.0f;
    settled_0 = _S911;
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
        uint abs_step_1 = (&isl_8)->info_1.w + s_6 + 1U;
        uint _S925 = abs_step_1 - 1U;
        uint _S926 = __ldg(&globalParams_0->params_0->step_start_0);
        uint k_18 = _S925 - _S926;
        bool _S927;
        bool settled_1;
        if((((&isl_8)->info_1.x) & 32U) != 0U)
        {
            if(_S912)
            {
                _S927 = ((&isl_8)->probes_0.y) > ((&isl_8)->probes_0.x);
            }
            else
            {
                _S927 = false;
            }
            if(_S927)
            {
                Island_0 _S928 = isl_8;
                Rigid_0 _S929 = rg_7;
                record_probes_0(&_S928, &_S929, k_18);
            }
            uint _S930 = s_6 + 1U;
            settled_1 = settled_0;
            done_1 = _S930;
            woke_0 = woke_1;
            uint _S931 = s_6 + 1U;
            settled_0 = settled_1;
            woke_1 = woke_0;
            s_6 = _S931;
            continue;
        }
        uint i_14;
        if(settled_0)
        {
            float3  _S932 = make_float3 (0.0f);
            float3  norm_0 = _S932;
            float3  unused0_0 = _S932;
            i_14 = (&isl_8)->range_0.x + tid_4;
            for(;;)
            {
                if(i_14 < ((&isl_8)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                Quat_0 _S933 = (&rg_7)->rot_0;
                float _S934 = settled_chunk_load_0(i_14, &_S933, k_18, _S918, contact_island_0);
                *&((&norm_0)->x) = *&((&norm_0)->x) + _S934;
                i_14 = i_14 + 256U;
            }
            group_sum3_0(tid_4, &norm_0, &unused0_0);
            uint _S935 = __ldg(&globalParams_0->params_0->solve_mode_0);
            if(_S935 == 1U)
            {
                _S927 = (F32_abs((norm_0.x - (&isl_8)->energy_1.z))) > ((&isl_8)->energy_1.w);
            }
            else
            {
                _S927 = false;
            }
            if(_S927)
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
        if(_S909)
        {
            float3  _S936 = make_float3 (0.0f);
            float3  f_15 = _S936;
            float3  t_10 = _S936;
            i_14 = (&isl_8)->range_0.x + tid_4;
            for(;;)
            {
                if(i_14 < ((&isl_8)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                Island_0 _S937 = isl_8;
                Rigid_0 _S938 = rg_7;
                net_load_0(i_14, &_S937, &_S938, k_18, _S918, contact_island_0, &f_15, &t_10);
                i_14 = i_14 + 256U;
            }
            group_sum3_0(tid_4, &f_15, &t_10);
            Island_0 _S939 = isl_8;
            rigid_acceleration_0(&_S939, &rg_7, f_15, t_10);
        }
        if(settled_1)
        {
            if(_S910)
            {
                Island_0 _S940 = isl_8;
                integrate_rigid_0(&_S940, &rg_7, _S918);
            }
            if(_S912)
            {
                _S927 = ((&isl_8)->probes_0.y) > ((&isl_8)->probes_0.x);
            }
            else
            {
                _S927 = false;
            }
            if(_S927)
            {
                Island_0 _S941 = isl_8;
                Rigid_0 _S942 = rg_7;
                record_probes_0(&_S941, &_S942, k_18);
            }
            done_1 = s_6 + 1U;
            uint _S931 = s_6 + 1U;
            settled_0 = settled_1;
            woke_1 = woke_0;
            s_6 = _S931;
            continue;
        }
        i_14 = (&isl_8)->range_0.z + tid_4;
        for(;;)
        {
            if(i_14 < ((&isl_8)->range_0.w))
            {
            }
            else
            {
                break;
            }
            bool _S943 = bond_update_0(i_14, _S918, _S920, abs_step_1);
            if(_S943)
            {
                *&g_halt_0 = 1U;
            }
            i_14 = i_14 + 256U;
        }
        __syncthreads();
        uint c_15 = (&isl_8)->range_0.x + tid_4;
        for(;;)
        {
            if(c_15 < ((&isl_8)->range_0.y))
            {
            }
            else
            {
                break;
            }
            Island_0 _S944 = isl_8;
            Rigid_0 _S945 = rg_7;
            chunk_update_0(c_15, &_S944, &_S945, _S918, _S922, k_18, contact_island_0, &work_2, &work_err_1);
            c_15 = c_15 + 256U;
        }
        __syncthreads();
        if(_S910)
        {
            Island_0 _S946 = isl_8;
            integrate_rigid_0(&_S946, &rg_7, _S918);
        }
        if(_S909)
        {
            float4  _S947 = (&isl_8)->wcom_0;
            float3  _S948 = float3 {_S947.x, _S947.y, _S947.z};
            float3  _S949 = make_float3 (0.0f);
            float3  tu_1 = _S949;
            float3  pv_1 = _S949;
            uint c_16 = (&isl_8)->range_0.x + tid_4;
            for(;;)
            {
                if(c_16 < ((&isl_8)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_moments_0(c_16, &tu_1, &pv_1);
                c_16 = c_16 + 256U;
            }
            group_sum3_0(tid_4, &tu_1, &pv_1);
            float3  tr_3 = tu_1 / make_float3 ((&isl_8)->wcom_0.w);
            float3  dv_3 = pv_1 / make_float3 ((&isl_8)->wcom_0.w);
            float3  lu_1 = _S949;
            float3  lv_1 = _S949;
            uint c_17 = (&isl_8)->range_0.x + tid_4;
            for(;;)
            {
                if(c_17 < ((&isl_8)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_angular_0(c_17, _S948, tr_3, dv_3, &lu_1, &lv_1);
                c_17 = c_17 + 256U;
            }
            group_sum3_0(tid_4, &lu_1, &lv_1);
            float3  phi_2 = rows_mul_0((&isl_8)->winv0_0, (&isl_8)->winv1_0, (&isl_8)->winv2_0, lu_1);
            float3  dw_2 = rows_mul_0((&isl_8)->winv0_0, (&isl_8)->winv1_0, (&isl_8)->winv2_0, lv_1);
            uint c_18 = (&isl_8)->range_0.x + tid_4;
            for(;;)
            {
                if(c_18 < ((&isl_8)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_apply_0(c_18, _S948, tr_3, phi_2, dv_3, dw_2);
                c_18 = c_18 + 256U;
            }
            if(!driven_0)
            {
                Island_0 _S950 = isl_8;
                drift_rigid_0(&_S950, &rg_7, tr_3, phi_2, dv_3, dw_2);
            }
            __syncthreads();
        }
        if(_S912)
        {
            _S927 = ((&isl_8)->probes_0.y) > ((&isl_8)->probes_0.x);
        }
        else
        {
            _S927 = false;
        }
        if(_S927)
        {
            Island_0 _S951 = isl_8;
            Rigid_0 _S952 = rg_7;
            record_probes_0(&_S951, &_S952, k_18);
        }
        uint _S953 = s_6 + 1U;
        if((*&g_halt_0) != 0U)
        {
            done_1 = _S953;
            break;
        }
        done_1 = _S953;
        uint _S931 = s_6 + 1U;
        settled_0 = settled_1;
        woke_1 = woke_0;
        s_6 = _S931;
    }
    float3  wsum_0 = make_float3 (work_2, work_err_1, 0.0f);
    float3  unused_2 = make_float3 (0.0f);
    group_sum3_0(tid_4, &wsum_0, &unused_2);
    if(_S912)
    {
        Quat_0 _S954 = (&rg_7)->rot_0;
        float4  _S955 = quat_vec_0(&_S954);
        (&isl_8)->rotation_0 = _S955;
        (&isl_8)->position_0 = make_float4 ((&rg_7)->pos_1.x, (&rg_7)->pos_1.y, (&rg_7)->pos_1.z, 0.0f);
        (&isl_8)->position_err_0 = make_float4 ((&rg_7)->pos_err_1.x, (&rg_7)->pos_err_1.y, (&rg_7)->pos_err_1.z, 0.0f);
        (&isl_8)->velocity_0 = make_float4 ((&rg_7)->vel_1.x, (&rg_7)->vel_1.y, (&rg_7)->vel_1.z, 0.0f);
        (&isl_8)->velocity_err_0 = make_float4 ((&rg_7)->vel_err_1.x, (&rg_7)->vel_err_1.y, (&rg_7)->vel_err_1.z, 0.0f);
        (&isl_8)->angular_velocity_0 = make_float4 ((&rg_7)->w_3.x, (&rg_7)->w_3.y, (&rg_7)->w_3.z, 0.0f);
        *&((&(&isl_8)->done_0)->x) = done_1;
        *&((&(&isl_8)->info_1)->y) = *&((&(&isl_8)->info_1)->y) - done_1;
        if((*&g_halt_0) != 0U)
        {
            _S910 = contact_island_0;
        }
        else
        {
            _S910 = false;
        }
        if(_S910)
        {
            contact_split_at_0((&isl_8)->info_1.w + done_1);
        }
        comp_add1_0(&((&(&isl_8)->energy_1)->x), &((&(&isl_8)->energy_1)->y), wsum_0.x);
        *&((&(&isl_8)->energy_1)->y) = *&((&(&isl_8)->energy_1)->y) + wsum_0.y;
        *&((&(&isl_8)->info_1)->w) = *&((&(&isl_8)->info_1)->w) + done_1;
        if((*&g_halt_0) != 0U)
        {
            *&((&(&isl_8)->info_1)->z) = (*&((&(&isl_8)->info_1)->z)) | 1U;
        }
        if(woke_0)
        {
            *&((&(&isl_8)->info_1)->x) = (*&((&(&isl_8)->info_1)->x)) & 4294967279U;
            *&((&(&isl_8)->info_1)->z) = (*&((&(&isl_8)->info_1)->z)) | 4U;
        }
        *(&(globalParams_0->islands_0)[_S908]) = isl_8;
    }
    return;
}

struct WideGroup_0
{
    uint island_0;
    uint begin_0;
    uint end_0;
    uint first_0;
};

static __device__ WideGroup_0 wide_group_0(uint table_0, uint g_3)
{
    WideGroup_0 w_7;
    uint _S956 = table_0 + 4U * g_3;
    uint _S957 = __ldg((&(globalParams_0->index_0)[_S956]));
    (&w_7)->island_0 = _S957;
    uint _S958 = __ldg((&(globalParams_0->index_0)[_S956 + 1U]));
    (&w_7)->begin_0 = _S958;
    uint _S959 = __ldg((&(globalParams_0->index_0)[_S956 + 2U]));
    (&w_7)->end_0 = _S959;
    uint _S960 = __ldg((&(globalParams_0->index_0)[_S956 + 3U]));
    (&w_7)->first_0 = _S960;
    return w_7;
}

static __device__ bool wide_runs_0(Island_0 * isl_9)
{
    uint4  _S961 = isl_9->info_1;
    bool _S962;
    if(((isl_9->info_1.z) & 1U) != 0U)
    {
        _S962 = true;
    }
    else
    {
        _S962 = (_S961.y) == 0U;
    }
    if(_S962)
    {
        return false;
    }
    if(((_S961.x) & 4U) == 0U)
    {
        _S962 = true;
    }
    else
    {
        bool _S963 = contact_stopped_0(isl_9);
        _S962 = !_S963;
    }
    return _S962;
}

__device__ __shared__ uint g_wide_run_0;

static __device__ bool wide_enter_0(uint tid_5, Island_0 * isl_10)
{
    if(tid_5 == 0U)
    {
        bool _S964 = wide_runs_0(isl_10);
        int _S965;
        if(_S964)
        {
            _S965 = int(1);
        }
        else
        {
            _S965 = int(0);
        }
        *&g_wide_run_0 = uint(_S965);
    }
    __syncthreads();
    return (*&g_wide_run_0) != 0U;
}

static __device__ uint wide_step_0(Island_0 * isl_11)
{
    uint _S966 = isl_11->info_1.w;
    uint _S967 = __ldg(&globalParams_0->params_0->step_start_0);
    return _S966 - _S967;
}

static __device__ bool contact_stopped_1(uint _S968)
{
    Island_0 * _S969 = (&(globalParams_0->islands_0)[_S968]);
    uint _S970 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint4  _S971 = (&(globalParams_0->islands_0)[_S970])->info_1;
    bool _S972;
    if((((&(globalParams_0->islands_0)[_S970])->info_1.z) & 1U) != 0U)
    {
        _S972 = true;
    }
    else
    {
        uint _S973 = _S971.y;
        if(_S973 != 0U)
        {
            _S972 = _S973 <= (_S969->info_1.w);
        }
        else
        {
            _S972 = false;
        }
    }
    return _S972;
}

static __device__ bool wide_runs_1(uint _S974)
{
    uint4  _S975 = (&(globalParams_0->islands_0)[_S974])->info_1;
    bool _S976;
    if((((&(globalParams_0->islands_0)[_S974])->info_1.z) & 1U) != 0U)
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
        bool _S977 = contact_stopped_1(_S974);
        _S976 = !_S977;
    }
    return _S976;
}

static __device__ bool wide_enter_1(uint _S978, uint _S979)
{
    if(_S978 == 0U)
    {
        bool _S980 = wide_runs_1(_S979);
        int _S981;
        if(_S980)
        {
            _S981 = int(1);
        }
        else
        {
            _S981 = int(0);
        }
        *&g_wide_run_0 = uint(_S981);
    }
    __syncthreads();
    return (*&g_wide_run_0) != 0U;
}

extern "C" __global__ void wide_wake()
{
    uint tid_6 = threadIdx.x;
    uint _S982 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S983 = blockIdx.x;
    WideGroup_0 wg_0 = wide_group_0(_S982, _S983);
    if(_S983 != (wg_0.first_0))
    {
        return;
    }
    Island_0 * _S984 = (&(globalParams_0->islands_0)[wg_0.island_0]);
    Island_0 isl_12 = *_S984;
    uint _S985 = (*_S984).info_1.x;
    bool _S986;
    if((_S985 & 16U) == 0U)
    {
        _S986 = true;
    }
    else
    {
        bool _S987 = wide_enter_1(tid_6, wg_0.island_0);
        _S986 = !_S987;
    }
    if(_S986)
    {
        return;
    }
    Quat_0 _S988 = quat_of_0(isl_12.rotation_0);
    bool _S989 = (_S985 & 4U) != 0U;
    float3  _S990 = make_float3 (0.0f);
    float3  norm_1 = _S990;
    float3  unused_3 = _S990;
    uint c_19 = isl_12.range_0.x + tid_6;
    for(;;)
    {
        if(c_19 < (isl_12.range_0.y))
        {
        }
        else
        {
            break;
        }
        Island_0 _S991 = isl_12;
        uint _S992 = wide_step_0(&_S991);
        float _S993 = __ldg(&globalParams_0->params_0->dt_0);
        Quat_0 _S994 = _S988;
        float _S995 = settled_chunk_load_0(c_19, &_S994, _S992, _S993, _S989);
        *&((&norm_1)->x) = *&((&norm_1)->x) + _S995;
        c_19 = c_19 + 256U;
    }
    group_sum3_0(tid_6, &norm_1, &unused_3);
    if(tid_6 == 0U)
    {
        uint _S996 = __ldg(&globalParams_0->params_0->solve_mode_0);
        _S986 = _S996 == 1U;
    }
    else
    {
        _S986 = false;
    }
    if(_S986)
    {
        _S986 = (F32_abs((norm_1.x - isl_12.energy_1.z))) > (isl_12.energy_1.w);
    }
    else
    {
        _S986 = false;
    }
    if(_S986)
    {
        *&((&(&(globalParams_0->islands_0)[wg_0.island_0])->info_1)->x) = _S985 & 4294967279U;
        *&((&(&(globalParams_0->islands_0)[wg_0.island_0])->info_1)->z) = (isl_12.info_1.z) | 4U;
    }
    return;
}

static __device__ void wide_store_0(uint slot_1, uint p_11, float3  a_14, float3  b_29)
{
    uint _S997 = __ldg(&globalParams_0->params_0->wide_base_0);
    uint _S998 = 8U * slot_1;
    *(&(globalParams_0->scratch_0)[_S997 + _S998 + p_11]) = make_float4 (a_14.x, a_14.y, a_14.z, 0.0f);
    uint _S999 = __ldg(&globalParams_0->params_0->wide_base_0);
    *(&(globalParams_0->scratch_0)[_S999 + _S998 + p_11 + 1U]) = make_float4 (b_29.x, b_29.y, b_29.z, 0.0f);
    return;
}

extern "C" __global__ void wide_bonds()
{
    uint tid_7 = threadIdx.x;
    uint _S1000 = blockIdx.x;
    uint _S1001 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
    bool bond_group_0 = _S1000 < _S1001;
    WideGroup_0 wg_1;
    if(bond_group_0)
    {
        uint _S1002 = __ldg(&globalParams_0->params_0->wide_bond_table_0);
        wg_1 = wide_group_0(_S1002, _S1000);
    }
    else
    {
        uint _S1003 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
        uint _S1004 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
        wg_1 = wide_group_0(_S1003, _S1000 - _S1004);
    }
    WideGroup_0 _S1005 = wg_1;
    Island_0 isl_13 = *(&(globalParams_0->islands_0)[wg_1.island_0]);
    bool _S1006 = wide_enter_1(tid_7, wg_1.island_0);
    if(!_S1006)
    {
        return;
    }
    Island_0 _S1007 = isl_13;
    uint _S1008 = wide_step_0(&_S1007);
    if(bond_group_0)
    {
        if(((isl_13.info_1.x) & 16U) != 0U)
        {
            return;
        }
        uint i_15 = wg_1.begin_0 + tid_7;
        bool _S1009;
        if(i_15 < (wg_1.end_0))
        {
            float _S1010 = __ldg(&globalParams_0->params_0->dt_0);
            uint _S1011 = __ldg(&globalParams_0->params_0->fracture_0);
            bool _S1012 = bond_update_0(i_15, _S1010, _S1011 != 0U, isl_13.info_1.w + 1U);
            _S1009 = _S1012;
        }
        else
        {
            _S1009 = false;
        }
        if(_S1009)
        {
            *&((&(&(globalParams_0->islands_0)[_S1005.island_0])->info_1)->z) = (isl_13.info_1.z) | 2U;
        }
        return;
    }
    uint _S1013 = isl_13.info_1.x;
    if((_S1013 & 1U) != 0U)
    {
        return;
    }
    float3  _S1014 = make_float3 (0.0f);
    float3  f_16 = _S1014;
    float3  t_11 = _S1014;
    uint c_20 = wg_1.begin_0 + tid_7;
    if(c_20 < (wg_1.end_0))
    {
        Island_0 _S1015 = isl_13;
        Rigid_0 _S1016 = rigid_of_0(&_S1015);
        float _S1017 = __ldg(&globalParams_0->params_0->dt_0);
        bool _S1018 = (_S1013 & 4U) != 0U;
        Island_0 _S1019 = isl_13;
        Rigid_0 _S1020 = _S1016;
        net_load_0(c_20, &_S1019, &_S1020, _S1008, _S1017, _S1018, &f_16, &t_11);
    }
    group_sum3_0(tid_7, &f_16, &t_11);
    if(tid_7 == 0U)
    {
        uint _S1021 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
        wide_store_0(_S1000 - _S1021, 0U, f_16, t_11);
    }
    return;
}

static __device__ void wide_partials_0(uint tid_8, uint first_1, uint count_5, uint p_12, float3  * a_15, float3  * b_30)
{
    float4  _S1022 = make_float4 (0.0f);
    float4  x_17 = _S1022;
    float4  y_5 = _S1022;
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
        uint _S1023 = __ldg(&globalParams_0->params_0->wide_base_0);
        uint _S1024 = 8U * (first_1 + s_7);
        x_17 = x_17 + *(&(globalParams_0->scratch_0)[_S1023 + _S1024 + p_12]);
        uint _S1025 = __ldg(&globalParams_0->params_0->wide_base_0);
        y_5 = y_5 + *(&(globalParams_0->scratch_0)[_S1025 + _S1024 + p_12 + 1U]);
        s_7 = s_7 + 256U;
    }
    group_sum2_0(tid_8, &x_17, &y_5);
    float4  _S1026 = x_17;
    *a_15 = float3 {_S1026.x, _S1026.y, _S1026.z};
    float4  _S1027 = y_5;
    *b_30 = float3 {_S1027.x, _S1027.y, _S1027.z};
    return;
}

static __device__ Rigid_0 wide_rigid_frame_0(uint tid_9, Island_0 * isl_14, WideGroup_0 * wg_2)
{
    Rigid_0 _S1028 = rigid_of_0(isl_14);
    Rigid_0 rg_8 = _S1028;
    if(((isl_14->info_1.x) & 1U) == 0U)
    {
        float3  f_17;
        float3  t_12;
        wide_partials_0(tid_9, wg_2->first_0, isl_14->done_0.z, 0U, &f_17, &t_12);
        rigid_acceleration_0(isl_14, &rg_8, f_17, t_12);
    }
    return rg_8;
}

extern "C" __global__ void wide_chunks()
{
    uint tid_10 = threadIdx.x;
    uint _S1029 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1030 = blockIdx.x;
    WideGroup_0 wg_3 = wide_group_0(_S1029, _S1030);
    Island_0 isl_15 = *(&(globalParams_0->islands_0)[wg_3.island_0]);
    bool _S1031 = wide_enter_1(tid_10, wg_3.island_0);
    if(!_S1031)
    {
        return;
    }
    uint _S1032 = isl_15.info_1.x;
    bool anchored_0 = (_S1032 & 1U) != 0U;
    if((_S1032 & 16U) != 0U)
    {
        if(tid_10 == 0U)
        {
            uint _S1033 = __ldg(&globalParams_0->params_0->wide_base_0);
            *(&(globalParams_0->scratch_0)[_S1033 + 8U * _S1030 + 6U]) = make_float4 (0.0f);
        }
        return;
    }
    Island_0 _S1034 = isl_15;
    WideGroup_0 _S1035 = wg_3;
    Rigid_0 _S1036 = wide_rigid_frame_0(tid_10, &_S1034, &_S1035);
    float work_3 = 0.0f;
    float work_err_2 = 0.0f;
    float3  _S1037 = make_float3 (0.0f);
    float3  tu_2 = _S1037;
    float3  pv_2 = _S1037;
    uint c_21 = wg_3.begin_0 + tid_10;
    if(c_21 < (wg_3.end_0))
    {
        float _S1038 = __ldg(&globalParams_0->params_0->dt_0);
        uint _S1039 = __ldg(&globalParams_0->params_0->rigid_motion_loads_0);
        bool _S1040 = _S1039 != 0U;
        Island_0 _S1041 = isl_15;
        uint _S1042 = wide_step_0(&_S1041);
        bool _S1043 = (_S1032 & 4U) != 0U;
        Island_0 _S1044 = isl_15;
        Rigid_0 _S1045 = _S1036;
        chunk_update_0(c_21, &_S1044, &_S1045, _S1038, _S1040, _S1042, _S1043, &work_3, &work_err_2);
        if(!anchored_0)
        {
            drift_moments_0(c_21, &tu_2, &pv_2);
        }
    }
    float3  wsum_1 = make_float3 (work_3, work_err_2, 0.0f);
    float3  unused_4 = _S1037;
    group_sum3_0(tid_10, &wsum_1, &unused_4);
    bool _S1046 = !anchored_0;
    if(_S1046)
    {
        group_sum3_0(tid_10, &tu_2, &pv_2);
    }
    if(tid_10 == 0U)
    {
        uint _S1047 = __ldg(&globalParams_0->params_0->wide_base_0);
        *(&(globalParams_0->scratch_0)[_S1047 + 8U * _S1030 + 6U]) = make_float4 (wsum_1.x, wsum_1.y, wsum_1.z, 0.0f);
        if(_S1046)
        {
            wide_store_0(_S1030, 2U, tu_2, pv_2);
        }
    }
    return;
}

extern "C" __global__ void wide_drift()
{
    uint tid_11 = threadIdx.x;
    uint _S1048 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1049 = blockIdx.x;
    WideGroup_0 wg_4 = wide_group_0(_S1048, _S1049);
    Island_0 * _S1050 = (&(globalParams_0->islands_0)[wg_4.island_0]);
    Island_0 isl_16 = *_S1050;
    bool _S1051;
    if((((*_S1050).info_1.x) & 17U) != 0U)
    {
        _S1051 = true;
    }
    else
    {
        bool _S1052 = wide_enter_1(tid_11, wg_4.island_0);
        _S1051 = !_S1052;
    }
    if(_S1051)
    {
        return;
    }
    float3  tu_3;
    float3  pv_3;
    wide_partials_0(tid_11, wg_4.first_0, isl_16.done_0.z, 2U, &tu_3, &pv_3);
    float _S1053 = isl_16.wcom_0.w;
    float3  tr_4 = tu_3 / make_float3 (_S1053);
    float3  dv_4 = pv_3 / make_float3 (_S1053);
    float3  _S1054 = make_float3 (0.0f);
    float3  lu_2 = _S1054;
    float3  lv_2 = _S1054;
    uint c_22 = wg_4.begin_0 + tid_11;
    if(c_22 < (wg_4.end_0))
    {
        float4  _S1055 = isl_16.wcom_0;
        drift_angular_0(c_22, float3 {_S1055.x, _S1055.y, _S1055.z}, tr_4, dv_4, &lu_2, &lv_2);
    }
    group_sum3_0(tid_11, &lu_2, &lv_2);
    if(tid_11 == 0U)
    {
        wide_store_0(_S1049, 4U, lu_2, lv_2);
    }
    return;
}

extern "C" __global__ void wide_rigid()
{
    uint tid_12 = threadIdx.x;
    uint _S1056 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1057 = blockIdx.x;
    WideGroup_0 wg_5 = wide_group_0(_S1056, _S1057);
    Island_0 * _S1058 = (&(globalParams_0->islands_0)[wg_5.island_0]);
    Island_0 isl_17 = *_S1058;
    uint _S1059 = (*_S1058).info_1.x;
    bool _S1060;
    if((_S1059 & 1U) != 0U)
    {
        _S1060 = true;
    }
    else
    {
        bool _S1061 = wide_enter_1(tid_12, wg_5.island_0);
        _S1060 = !_S1061;
    }
    if(_S1060)
    {
        return;
    }
    if((_S1059 & 16U) != 0U)
    {
        if(_S1057 != (wg_5.first_0))
        {
            return;
        }
        Island_0 _S1062 = isl_17;
        WideGroup_0 _S1063 = wg_5;
        Rigid_0 _S1064 = wide_rigid_frame_0(tid_12, &_S1062, &_S1063);
        Rigid_0 rs_0 = _S1064;
        if(tid_12 != 0U)
        {
            _S1060 = true;
        }
        else
        {
            _S1060 = (_S1059 & 2U) != 0U;
        }
        if(_S1060)
        {
            return;
        }
        float _S1065 = __ldg(&globalParams_0->params_0->dt_0);
        Island_0 _S1066 = isl_17;
        integrate_rigid_0(&_S1066, &rs_0, _S1065);
        Quat_0 _S1067 = (&rs_0)->rot_0;
        float4  _S1068 = quat_vec_0(&_S1067);
        (&(globalParams_0->islands_0)[wg_5.island_0])->rotation_0 = _S1068;
        (&(globalParams_0->islands_0)[wg_5.island_0])->position_0 = make_float4 ((&rs_0)->pos_1.x, (&rs_0)->pos_1.y, (&rs_0)->pos_1.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_5.island_0])->position_err_0 = make_float4 ((&rs_0)->pos_err_1.x, (&rs_0)->pos_err_1.y, (&rs_0)->pos_err_1.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_5.island_0])->velocity_0 = make_float4 ((&rs_0)->vel_1.x, (&rs_0)->vel_1.y, (&rs_0)->vel_1.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_5.island_0])->velocity_err_0 = make_float4 ((&rs_0)->vel_err_1.x, (&rs_0)->vel_err_1.y, (&rs_0)->vel_err_1.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_5.island_0])->angular_velocity_0 = make_float4 ((&rs_0)->w_3.x, (&rs_0)->w_3.y, (&rs_0)->w_3.z, 0.0f);
        return;
    }
    uint _S1069 = isl_17.done_0.z;
    float3  tu_4;
    float3  pv_4;
    wide_partials_0(tid_12, wg_5.first_0, _S1069, 2U, &tu_4, &pv_4);
    float3  lu_3;
    float3  lv_3;
    wide_partials_0(tid_12, wg_5.first_0, _S1069, 4U, &lu_3, &lv_3);
    float _S1070 = isl_17.wcom_0.w;
    float3  tr_5 = tu_4 / make_float3 (_S1070);
    float3  dv_5 = pv_4 / make_float3 (_S1070);
    float3  phi_3 = rows_mul_0(isl_17.winv0_0, isl_17.winv1_0, isl_17.winv2_0, lu_3);
    float3  dw_3 = rows_mul_0(isl_17.winv0_0, isl_17.winv1_0, isl_17.winv2_0, lv_3);
    uint c_23 = wg_5.begin_0 + tid_12;
    if(c_23 < (wg_5.end_0))
    {
        float4  _S1071 = isl_17.wcom_0;
        drift_apply_0(c_23, float3 {_S1071.x, _S1071.y, _S1071.z}, tr_5, phi_3, dv_5, dw_3);
    }
    if(_S1057 != (wg_5.first_0))
    {
        return;
    }
    Island_0 _S1072 = isl_17;
    WideGroup_0 _S1073 = wg_5;
    Rigid_0 _S1074 = wide_rigid_frame_0(tid_12, &_S1072, &_S1073);
    Rigid_0 rg_9 = _S1074;
    if(tid_12 != 0U)
    {
        return;
    }
    if(!((_S1059 & 2U) != 0U))
    {
        float _S1075 = __ldg(&globalParams_0->params_0->dt_0);
        Island_0 _S1076 = isl_17;
        integrate_rigid_0(&_S1076, &rg_9, _S1075);
        Island_0 _S1077 = isl_17;
        drift_rigid_0(&_S1077, &rg_9, tr_5, phi_3, dv_5, dw_3);
    }
    Quat_0 _S1078 = (&rg_9)->rot_0;
    float4  _S1079 = quat_vec_0(&_S1078);
    (&(globalParams_0->islands_0)[wg_5.island_0])->rotation_0 = _S1079;
    (&(globalParams_0->islands_0)[wg_5.island_0])->position_0 = make_float4 ((&rg_9)->pos_1.x, (&rg_9)->pos_1.y, (&rg_9)->pos_1.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_5.island_0])->position_err_0 = make_float4 ((&rg_9)->pos_err_1.x, (&rg_9)->pos_err_1.y, (&rg_9)->pos_err_1.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_5.island_0])->velocity_0 = make_float4 ((&rg_9)->vel_1.x, (&rg_9)->vel_1.y, (&rg_9)->vel_1.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_5.island_0])->velocity_err_0 = make_float4 ((&rg_9)->vel_err_1.x, (&rg_9)->vel_err_1.y, (&rg_9)->vel_err_1.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_5.island_0])->angular_velocity_0 = make_float4 ((&rg_9)->w_3.x, (&rg_9)->w_3.y, (&rg_9)->w_3.z, 0.0f);
    return;
}

extern "C" __global__ void wide_end()
{
    uint tid_13 = threadIdx.x;
    uint _S1080 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1081 = blockIdx.x;
    WideGroup_0 wg_6 = wide_group_0(_S1080, _S1081);
    if(_S1081 != (wg_6.first_0))
    {
        return;
    }
    Island_0 * _S1082 = (&(globalParams_0->islands_0)[wg_6.island_0]);
    Island_0 isl_18 = *_S1082;
    Island_0 _S1083 = *_S1082;
    bool _S1084 = wide_enter_0(tid_13, &_S1083);
    if(!_S1084)
    {
        return;
    }
    float3  work_4;
    float3  unused_5;
    wide_partials_0(tid_13, wg_6.first_0, (&isl_18)->done_0.z, 6U, &work_4, &unused_5);
    if(tid_13 != 0U)
    {
        return;
    }
    Island_0 _S1085 = isl_18;
    uint _S1086 = wide_step_0(&_S1085);
    if(((&isl_18)->probes_0.y) > ((&isl_18)->probes_0.x))
    {
        Island_0 _S1087 = isl_18;
        Rigid_0 _S1088 = rigid_of_0(&_S1087);
        Island_0 _S1089 = isl_18;
        Rigid_0 _S1090 = _S1088;
        record_probes_0(&_S1089, &_S1090, _S1086);
    }
    bool halt_0 = (((&isl_18)->info_1.z) & 2U) != 0U;
    bool _S1091;
    if(halt_0)
    {
        _S1091 = (((&isl_18)->info_1.x) & 4U) != 0U;
    }
    else
    {
        _S1091 = false;
    }
    if(_S1091)
    {
        contact_split_at_0((&isl_18)->info_1.w + 1U);
    }
    comp_add1_0(&((&(&isl_18)->energy_1)->x), &((&(&isl_18)->energy_1)->y), work_4.x);
    *&((&(&isl_18)->energy_1)->y) = *&((&(&isl_18)->energy_1)->y) + work_4.y;
    *&((&(&isl_18)->done_0)->x) = *&((&(&isl_18)->done_0)->x) + 1U;
    *&((&(&isl_18)->info_1)->y) = *&((&(&isl_18)->info_1)->y) - 1U;
    *&((&(&isl_18)->info_1)->w) = *&((&(&isl_18)->info_1)->w) + 1U;
    if(halt_0)
    {
        *&((&(&isl_18)->info_1)->z) = (((&isl_18)->info_1.z) & 4294967293U) | 1U;
    }
    *(&(globalParams_0->islands_0)[wg_6.island_0]) = isl_18;
    return;
}

static __device__ uint sv_0(uint c_24, uint slot_2)
{
    uint _S1092 = __ldg(&globalParams_0->params_0->statics_base_0);
    return _S1092 + 23U * c_24 + slot_2;
}

static __device__ void project_load_slot_0(uint tid_14, Island_0 * isl_19, uint slot_3)
{
    uint _S1093;
    float3  _S1094 = make_float3 (0.0f);
    float3  net_f_0 = _S1094;
    float3  net_m_0 = _S1094;
    uint4  _S1095 = isl_19->range_0;
    uint _S1096 = isl_19->range_0.x + tid_14;
    uint c_25 = _S1096;
    for(;;)
    {
        uint _S1097 = _S1095.y;
        _S1093 = _S1097;
        if(c_25 < _S1097)
        {
        }
        else
        {
            break;
        }
        float4  _S1098 = *(&(globalParams_0->scratch_0)[sv_0(c_25, slot_3)]);
        float3  fi_1 = float3 {_S1098.x, _S1098.y, _S1098.z};
        net_f_0 = net_f_0 + fi_1;
        float4  _S1099 = __ldg(&(&(globalParams_0->chunks_0)[c_25])->center_0);
        float4  _S1100 = isl_19->com_0;
        float4  _S1101 = *(&(globalParams_0->scratch_0)[sv_0(c_25, slot_3 + 1U)]);
        net_m_0 = net_m_0 + (cross_0(float3 {_S1099.x, _S1099.y, _S1099.z} - float3 {_S1100.x, _S1100.y, _S1100.z}, fi_1) + float3 {_S1101.x, _S1101.y, _S1101.z});
        c_25 = c_25 + 256U;
    }
    group_sum3_0(tid_14, &net_f_0, &net_m_0);
    float4  _S1102 = isl_19->com_0;
    float3  _S1103 = net_f_0 / make_float3 (isl_19->com_0.w);
    float3  _S1104 = rows_mul_0(isl_19->inv0_1, isl_19->inv1_1, isl_19->inv2_1, net_m_0);
    c_25 = _S1096;
    for(;;)
    {
        if(c_25 < _S1093)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_0 * _S1105 = (&(globalParams_0->chunks_0)[c_25]);
        float4  _S1106 = __ldg(&_S1105->center_0);
        uint _S1107 = sv_0(c_25, slot_3);
        float4  _S1108 = *(&(globalParams_0->scratch_0)[_S1107]);
        *(&(globalParams_0->scratch_0)[_S1107]) = make_float4 ((float3 {_S1108.x, _S1108.y, _S1108.z} - (_S1103 + cross_0(_S1104, float3 {_S1106.x, _S1106.y, _S1106.z} - float3 {_S1102.x, _S1102.y, _S1102.z})) * make_float3 (_S1106.w)).x, (float3 {_S1108.x, _S1108.y, _S1108.z} - (_S1103 + cross_0(_S1104, float3 {_S1106.x, _S1106.y, _S1106.z} - float3 {_S1102.x, _S1102.y, _S1102.z})) * make_float3 (_S1106.w)).y, (float3 {_S1108.x, _S1108.y, _S1108.z} - (_S1103 + cross_0(_S1104, float3 {_S1106.x, _S1106.y, _S1106.z} - float3 {_S1102.x, _S1102.y, _S1102.z})) * make_float3 (_S1106.w)).z, 0.0f);
        uint _S1109 = sv_0(c_25, slot_3 + 1U);
        float4  * _S1110 = (&(globalParams_0->scratch_0)[_S1109]);
        float4  _S1111 = *(&(globalParams_0->scratch_0)[_S1109]);
        float3  _S1112 = float3 {_S1111.x, _S1111.y, _S1111.z};
        float4  _S1113 = __ldg(&_S1105->inertia0_0);
        float4  _S1114 = __ldg(&_S1105->inertia1_0);
        float4  _S1115 = __ldg(&_S1105->inertia2_0);
        *_S1110 = make_float4 ((_S1112 - rows_mul_0(_S1113, _S1114, _S1115, _S1104)).x, (_S1112 - rows_mul_0(_S1113, _S1114, _S1115, _S1104)).y, (_S1112 - rows_mul_0(_S1113, _S1114, _S1115, _S1104)).z, 0.0f);
        c_25 = c_25 + 256U;
    }
    __syncthreads();
    return;
}

static __device__ float island_dot_0(uint tid_15, uint c0_0, uint c1_0, uint sa_0, uint sb_0)
{
    float4  _S1116 = make_float4 (0.0f);
    float4  acc_0 = _S1116;
    float4  unused_6 = _S1116;
    uint c_26 = c0_0 + tid_15;
    for(;;)
    {
        if(c_26 < c1_0)
        {
        }
        else
        {
            break;
        }
        float4  _S1117 = *(&(globalParams_0->scratch_0)[sv_0(c_26, sa_0)]);
        float4  _S1118 = *(&(globalParams_0->scratch_0)[sv_0(c_26, sb_0)]);
        float4  _S1119 = *(&(globalParams_0->scratch_0)[sv_0(c_26, sa_0 + 1U)]);
        float4  _S1120 = *(&(globalParams_0->scratch_0)[sv_0(c_26, sb_0 + 1U)]);
        *&((&acc_0)->x) = *&((&acc_0)->x) + (dot_0(float3 {_S1117.x, _S1117.y, _S1117.z}, float3 {_S1118.x, _S1118.y, _S1118.z}) + dot_0(float3 {_S1119.x, _S1119.y, _S1119.z}, float3 {_S1120.x, _S1120.y, _S1120.z}));
        c_26 = c_26 + 256U;
    }
    group_sum2_0(tid_15, &acc_0, &unused_6);
    return acc_0.x;
}

static __device__ void static_kinematics_0(uint _S1121, float3  * _S1122, float3  * _S1123)
{
    BondStatic_0 * _S1124 = (&(globalParams_0->bonds_0)[_S1121]);
    JointBond_0 _S1125 = slang_ldg_0(&_S1124->law_0);
    uint ca_1 = _S1125.ids_0.y;
    uint cb_1 = _S1125.ids_0.z;
    uint _S1126 = 4U * cb_1;
    float4  _S1127 = *(&(globalParams_0->state_0)[_S1126]);
    uint _S1128 = 4U * ca_1;
    float4  _S1129 = *(&(globalParams_0->state_0)[_S1128]);
    float4  _S1130 = *(&(globalParams_0->scratch_0)[sv_0(cb_1, 21U)]);
    float4  _S1131 = *(&(globalParams_0->scratch_0)[sv_0(ca_1, 21U)]);
    float3  du_0 = float3 {_S1127.x, _S1127.y, _S1127.z} - float3 {_S1129.x, _S1129.y, _S1129.z} + (float3 {_S1130.x, _S1130.y, _S1130.z} - float3 {_S1131.x, _S1131.y, _S1131.z});
    uint _S1132 = _S1126 + 1U;
    float4  _S1133 = *(&(globalParams_0->state_0)[_S1132]);
    uint _S1134 = _S1128 + 1U;
    float4  _S1135 = *(&(globalParams_0->state_0)[_S1134]);
    uint _S1136 = sv_0(cb_1, 22U);
    float4  _S1137 = *(&(globalParams_0->scratch_0)[_S1136]);
    uint _S1138 = sv_0(ca_1, 22U);
    float4  _S1139 = *(&(globalParams_0->scratch_0)[_S1138]);
    float3  dth_0 = float3 {_S1133.x, _S1133.y, _S1133.z} - float3 {_S1135.x, _S1135.y, _S1135.z} + (float3 {_S1137.x, _S1137.y, _S1137.z} - float3 {_S1139.x, _S1139.y, _S1139.z});
    float4  _S1140 = *(&(globalParams_0->state_0)[_S1134]);
    float4  _S1141 = *(&(globalParams_0->scratch_0)[_S1138]);
    float3  ta_3 = float3 {_S1140.x, _S1140.y, _S1140.z} + float3 {_S1141.x, _S1141.y, _S1141.z};
    float4  _S1142 = *(&(globalParams_0->state_0)[_S1132]);
    float4  _S1143 = *(&(globalParams_0->scratch_0)[_S1136]);
    float3  tb_3 = float3 {_S1142.x, _S1142.y, _S1142.z} + float3 {_S1143.x, _S1143.y, _S1143.z};
    float4  _S1144 = __ldg(&_S1124->rb_0);
    float3  _S1145 = cross_0(tb_3, float3 {_S1144.x, _S1144.y, _S1144.z});
    float4  _S1146 = __ldg(&_S1124->ra_0);
    float3  _S1147 = to_local_0(_S1121, du_0 + (_S1145 - cross_0(ta_3, float3 {_S1146.x, _S1146.y, _S1146.z})));
    *_S1122 = _S1147;
    float3  _S1148 = to_local_0(_S1121, dth_0);
    *_S1123 = _S1148;
    return;
}

static __device__ JointResponse_0 static_response_0(uint i_16)
{
    BondStatic_0 * _S1149 = (&(globalParams_0->bonds_0)[i_16]);
    float3  d_lin_3;
    float3  d_ang_2;
    static_kinematics_0(i_16, &d_lin_3, &d_ang_2);
    JointBond_0 _S1150 = slang_ldg_0(&_S1149->law_0);
    JointBond_0 _S1151 = _S1150;
    JointState_0 _S1152 = (&(globalParams_0->bond_dyn_0)[i_16])->js_0;
    JointResponse_0 _S1153 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S1150.ids_0.x], &_S1151, &_S1152, d_lin_3, d_ang_2, 0.0f, false);
    return _S1153;
}

static __device__ void gather_loads_0(uint c_27, float3  * fi_2, float3  * mi_3)
{
    float3  _S1154 = make_float3 (0.0f);
    *fi_2 = _S1154;
    *mi_3 = _S1154;
    uint _S1155 = __ldg((&(globalParams_0->index_0)[c_27]));
    uint e_4 = _S1155;
    for(;;)
    {
        uint _S1156 = __ldg((&(globalParams_0->index_0)[c_27 + 1U]));
        if(e_4 < _S1156)
        {
        }
        else
        {
            break;
        }
        uint _S1157 = __ldg((&(globalParams_0->index_0)[e_4]));
        uint bond_0 = _S1157 >> int(1);
        if((_S1157 & 1U) == 0U)
        {
            uint _S1158 = 3U * bond_0;
            float4  _S1159 = *(&(globalParams_0->scratch_0)[_S1158]);
            *fi_2 = *fi_2 + float3 {_S1159.x, _S1159.y, _S1159.z};
            float4  _S1160 = *(&(globalParams_0->scratch_0)[_S1158 + 1U]);
            *mi_3 = *mi_3 + float3 {_S1160.x, _S1160.y, _S1160.z};
        }
        else
        {
            uint _S1161 = 3U * bond_0;
            float4  _S1162 = *(&(globalParams_0->scratch_0)[_S1161]);
            *fi_2 = *fi_2 - float3 {_S1162.x, _S1162.y, _S1162.z};
            float4  _S1163 = *(&(globalParams_0->scratch_0)[_S1161 + 2U]);
            *mi_3 = *mi_3 + float3 {_S1163.x, _S1163.y, _S1163.z};
        }
        e_4 = e_4 + 1U;
    }
    return;
}

static __device__ float bond_load_magnitude2_0(uint c_28)
{
    uint _S1164 = __ldg((&(globalParams_0->index_0)[c_28]));
    uint e_5 = _S1164;
    float m_7 = 0.0f;
    for(;;)
    {
        uint _S1165 = __ldg((&(globalParams_0->index_0)[c_28 + 1U]));
        if(e_5 < _S1165)
        {
        }
        else
        {
            break;
        }
        uint _S1166 = __ldg((&(globalParams_0->index_0)[e_5]));
        uint _S1167 = 3U * (_S1166 >> int(1));
        float4  _S1168 = *(&(globalParams_0->scratch_0)[_S1167]);
        float3  f_18 = float3 {_S1168.x, _S1168.y, _S1168.z};
        float3  t_13;
        if((_S1166 & 1U) == 0U)
        {
            float4  _S1169 = *(&(globalParams_0->scratch_0)[_S1167 + 1U]);
            t_13 = float3 {_S1169.x, _S1169.y, _S1169.z};
        }
        else
        {
            float4  _S1170 = *(&(globalParams_0->scratch_0)[_S1167 + 2U]);
            t_13 = float3 {_S1170.x, _S1170.y, _S1170.z};
        }
        float m_8 = m_7 + (dot_0(f_18, f_18) + dot_0(t_13, t_13));
        e_5 = e_5 + 1U;
        m_7 = m_8;
    }
    return m_7;
}

static __device__ uint fixed_mask_0(uint c_29)
{
    uint4  _S1171 = __ldg(&(&(globalParams_0->chunks_0)[c_29])->info_0);
    uint support_1 = _S1171.x;
    uint _S1172;
    if(support_1 == 1U)
    {
        _S1172 = 63U;
    }
    else
    {
        if(support_1 == 2U)
        {
            _S1172 = 7U;
        }
        else
        {
            _S1172 = 0U;
        }
    }
    return _S1172;
}

static __device__ void hold_0(uint mask_0, float4  * lin_0, float4  * ang_0, float4  keep_lin_0, float4  keep_ang_0)
{
    uint d_10 = 0U;
    for(;;)
    {
        if(d_10 < 3U)
        {
        }
        else
        {
            break;
        }
        if((mask_0 & (1U << d_10)) != 0U)
        {
            *_slang_vector_get_element_ptr(lin_0, d_10) = _slang_vector_get_element(keep_lin_0, d_10);
        }
        if((mask_0 & (1U << (d_10 + 3U))) != 0U)
        {
            *_slang_vector_get_element_ptr(ang_0, d_10) = _slang_vector_get_element(keep_ang_0, d_10);
        }
        d_10 = d_10 + 1U;
    }
    return;
}

static __device__ uint statics_bond_slot_0(uint i_17)
{
    uint _S1173 = __ldg(&globalParams_0->params_0->statics_base_0);
    uint _S1174 = __ldg(&globalParams_0->params_0->chunk_count_0);
    return _S1173 + 23U * _S1174 + 2U * i_17;
}

static __device__ void store_inverse_0(uint c_30, FixedArray<float, 36>  * a_16)
{
    uint j_5;
    float sum_2;
    FixedArray<float, 36>  l_3;
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
        l_3[k_19] = 0.0f;
        k_19 = k_19 + 1U;
    }
    bool spd_0 = true;
    uint i_18 = 0U;
    for(;;)
    {
        bool _S1175;
        if(i_18 < 6U)
        {
            _S1175 = spd_0;
        }
        else
        {
            _S1175 = false;
        }
        if(_S1175)
        {
        }
        else
        {
            break;
        }
        j_5 = 0U;
        for(;;)
        {
            if(j_5 <= i_18)
            {
            }
            else
            {
                break;
            }
            uint _S1176 = i_18 * 6U;
            uint _S1177 = _S1176 + j_5;
            k_19 = 0U;
            sum_2 = (*a_16)[_S1177];
            for(;;)
            {
                if(k_19 < j_5)
                {
                }
                else
                {
                    break;
                }
                float sum_3 = sum_2 - l_3[_S1176 + k_19] * l_3[j_5 * 6U + k_19];
                k_19 = k_19 + 1U;
                sum_2 = sum_3;
            }
            if(i_18 == j_5)
            {
                if(sum_2 <= 0.0f)
                {
                    spd_0 = false;
                    break;
                }
                l_3[_S1176 + i_18] = (F32_sqrt((sum_2)));
            }
            else
            {
                l_3[_S1177] = sum_2 / l_3[j_5 * 6U + j_5];
            }
            j_5 = j_5 + 1U;
        }
        i_18 = i_18 + 1U;
    }
    FixedArray<float, 36>  inv_0;
    if(!spd_0)
    {
        k_19 = 0U;
        for(;;)
        {
            if(k_19 < 36U)
            {
            }
            else
            {
                break;
            }
            inv_0[k_19] = 0.0f;
            k_19 = k_19 + 1U;
        }
        k_19 = 0U;
        for(;;)
        {
            if(k_19 < 6U)
            {
            }
            else
            {
                break;
            }
            uint _S1178 = k_19 * 6U + k_19;
            float _S1179 = (*a_16)[_S1178];
            if(((*a_16)[_S1178]) > 0.0f)
            {
                sum_2 = 1.0f / _S1179;
            }
            else
            {
                sum_2 = 0.0f;
            }
            inv_0[_S1178] = sum_2;
            k_19 = k_19 + 1U;
        }
    }
    else
    {
        j_5 = 0U;
        for(;;)
        {
            if(j_5 < 6U)
            {
            }
            else
            {
                break;
            }
            FixedArray<float, 6>  y_6;
            y_6[int(0)] = 0.0f;
            y_6[int(1)] = 0.0f;
            y_6[int(2)] = 0.0f;
            y_6[int(3)] = 0.0f;
            y_6[int(4)] = 0.0f;
            y_6[int(5)] = 0.0f;
            i_18 = 0U;
            for(;;)
            {
                if(i_18 < 6U)
                {
                }
                else
                {
                    break;
                }
                if(i_18 == j_5)
                {
                    sum_2 = 1.0f;
                }
                else
                {
                    sum_2 = 0.0f;
                }
                k_19 = 0U;
                float s_8 = sum_2;
                for(;;)
                {
                    if(k_19 < i_18)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_9 = s_8 - l_3[i_18 * 6U + k_19] * y_6[k_19];
                    k_19 = k_19 + 1U;
                    s_8 = s_9;
                }
                y_6[i_18] = s_8 / l_3[i_18 * 6U + i_18];
                i_18 = i_18 + 1U;
            }
            FixedArray<float, 6>  x_18;
            x_18[int(0)] = 0.0f;
            x_18[int(1)] = 0.0f;
            x_18[int(2)] = 0.0f;
            x_18[int(3)] = 0.0f;
            x_18[int(4)] = 0.0f;
            x_18[int(5)] = 0.0f;
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
                uint i_19 = 5U - ii_2;
                k_19 = i_19 + 1U;
                sum_2 = y_6[i_19];
                for(;;)
                {
                    if(k_19 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_10 = sum_2 - l_3[k_19 * 6U + i_19] * x_18[k_19];
                    k_19 = k_19 + 1U;
                    sum_2 = s_10;
                }
                x_18[i_19] = sum_2 / l_3[i_19 * 6U + i_19];
                ii_2 = ii_2 + 1U;
            }
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
                inv_0[i_20 * 6U + j_5] = x_18[i_20];
                i_20 = i_20 + 1U;
            }
            j_5 = j_5 + 1U;
        }
    }
    j_5 = 0U;
    for(;;)
    {
        if(j_5 < 9U)
        {
        }
        else
        {
            break;
        }
        uint _S1180 = 4U * j_5;
        *(&(globalParams_0->scratch_0)[sv_0(c_30, 12U + j_5)]) = make_float4 (inv_0[_S1180], inv_0[_S1180 + 1U], inv_0[_S1180 + 2U], inv_0[_S1180 + 3U]);
        j_5 = j_5 + 1U;
    }
    return;
}

static __device__ void assemble_block_0(uint c_31)
{
    uint p_13;
    uint r_12;
    FixedArray<float, 36>  a_17;
    uint k_20 = 0U;
    for(;;)
    {
        if(k_20 < 36U)
        {
        }
        else
        {
            break;
        }
        a_17[k_20] = 0.0f;
        k_20 = k_20 + 1U;
    }
    uint _S1181 = __ldg((&(globalParams_0->index_0)[c_31]));
    uint e_6 = _S1181;
    for(;;)
    {
        uint _S1182 = __ldg((&(globalParams_0->index_0)[c_31 + 1U]));
        if(e_6 < _S1182)
        {
        }
        else
        {
            break;
        }
        uint _S1183 = __ldg((&(globalParams_0->index_0)[e_6]));
        uint i_21 = _S1183 >> int(1);
        bool _S1184 = (_S1183 & 1U) != 0U;
        BondStatic_0 * _S1185 = (&(globalParams_0->bonds_0)[i_21]);
        uint _S1186 = statics_bond_slot_0(i_21);
        float4  _S1187 = *(&(globalParams_0->scratch_0)[_S1186]);
        float4  _S1188 = *(&(globalParams_0->scratch_0)[_S1186 + 1U]);
        p_13 = 0U;
        for(;;)
        {
            if(p_13 < 6U)
            {
            }
            else
            {
                break;
            }
            uint _S1189 = p_13 % 3U;
            float3  t_14;
            if(_S1189 == 0U)
            {
                float4  _S1190 = __ldg(&_S1185->t1_0);
                t_14 = float3 {_S1190.x, _S1190.y, _S1190.z};
            }
            else
            {
                if(_S1189 == 1U)
                {
                    float4  _S1191 = __ldg(&_S1185->t2_0);
                    t_14 = float3 {_S1191.x, _S1191.y, _S1191.z};
                }
                else
                {
                    float4  _S1192 = __ldg(&_S1185->normal_0);
                    t_14 = float3 {_S1192.x, _S1192.y, _S1192.z};
                }
            }
            bool _S1193 = p_13 < 3U;
            float3  row_u_0;
            float3  row_t_0;
            if(_S1193)
            {
                if(_S1184)
                {
                    row_u_0 = t_14;
                }
                else
                {
                    row_u_0 = - t_14;
                }
                if(_S1184)
                {
                    float4  _S1194 = __ldg(&_S1185->rb_0);
                    row_t_0 = cross_0(float3 {_S1194.x, _S1194.y, _S1194.z}, t_14);
                }
                else
                {
                    float4  _S1195 = __ldg(&_S1185->ra_0);
                    row_t_0 = - cross_0(float3 {_S1195.x, _S1195.y, _S1195.z}, t_14);
                }
            }
            else
            {
                float3  _S1196 = make_float3 (0.0f);
                if(_S1184)
                {
                    row_u_0 = t_14;
                }
                else
                {
                    row_u_0 = - t_14;
                }
                float3  _S1197 = row_u_0;
                row_u_0 = _S1196;
                row_t_0 = _S1197;
            }
            float kp_0;
            if(_S1193)
            {
                kp_0 = _slang_vector_get_element(_S1187, p_13);
            }
            else
            {
                kp_0 = _slang_vector_get_element(_S1188, p_13 - 3U);
            }
            if(kp_0 == 0.0f)
            {
                p_13 = p_13 + 1U;
                continue;
            }
            FixedArray<float, 6>  _S1198 = { {
                row_u_0.x, row_u_0.y, row_u_0.z, row_t_0.x, row_t_0.y, row_t_0.z
            } };
            r_12 = 0U;
            for(;;)
            {
                if(r_12 < 6U)
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
                    a_17[r_12 * 6U + q_15] = a_17[r_12 * 6U + q_15] + kp_0 * _S1198[r_12] * _S1198[q_15];
                    q_15 = q_15 + 1U;
                }
                r_12 = r_12 + 1U;
            }
            p_13 = p_13 + 1U;
        }
        e_6 = e_6 + 1U;
    }
    uint _S1199 = fixed_mask_0(c_31);
    p_13 = 0U;
    for(;;)
    {
        if(p_13 < 6U)
        {
        }
        else
        {
            break;
        }
        if((_S1199 & (1U << p_13)) != 0U)
        {
            r_12 = 0U;
            for(;;)
            {
                if(r_12 < 6U)
                {
                }
                else
                {
                    break;
                }
                a_17[p_13 * 6U + r_12] = 0.0f;
                a_17[r_12 * 6U + p_13] = 0.0f;
                r_12 = r_12 + 1U;
            }
            a_17[p_13 * 6U + p_13] = 1.0f;
        }
        p_13 = p_13 + 1U;
    }
    p_13 = 0U;
    for(;;)
    {
        if(p_13 < 6U)
        {
        }
        else
        {
            break;
        }
        if((a_17[p_13 * 6U + p_13]) == 0.0f)
        {
            a_17[p_13 * 6U + p_13] = 1.0f;
        }
        p_13 = p_13 + 1U;
    }
    FixedArray<float, 36>  _S1200 = a_17;
    store_inverse_0(c_31, &_S1200);
    return;
}

static __device__ float block_get_0(uint c_32, uint i_22, uint j_6)
{
    uint k_21 = i_22 * 6U + j_6;
    return *_slang_vector_get_element_ptr((&(globalParams_0->scratch_0)[sv_0(c_32, 12U + k_21 / 4U)]), k_21 % 4U);
}

static __device__ void precondition_0(uint c_33)
{
    float4  * _S1201 = (&(globalParams_0->scratch_0)[sv_0(c_33, 4U)]);
    float4  * _S1202 = (&(globalParams_0->scratch_0)[sv_0(c_33, 5U)]);
    FixedArray<float, 6>  _S1203 = { {
        (*_S1201).x, (*_S1201).y, (*_S1201).z, (*_S1202).x, (*_S1202).y, (*_S1202).z
    } };
    FixedArray<float, 6>  z_1;
    uint i_23 = 0U;
    for(;;)
    {
        if(i_23 < 6U)
        {
        }
        else
        {
            break;
        }
        uint j_7 = 0U;
        float s_11 = 0.0f;
        for(;;)
        {
            if(j_7 < 6U)
            {
            }
            else
            {
                break;
            }
            float s_12 = s_11 + block_get_0(c_33, i_23, j_7) * _S1203[j_7];
            j_7 = j_7 + 1U;
            s_11 = s_12;
        }
        z_1[i_23] = s_11;
        i_23 = i_23 + 1U;
    }
    *(&(globalParams_0->scratch_0)[sv_0(c_33, 6U)]) = make_float4 (z_1[int(0)], z_1[int(1)], z_1[int(2)], 0.0f);
    *(&(globalParams_0->scratch_0)[sv_0(c_33, 7U)]) = make_float4 (z_1[int(3)], z_1[int(4)], z_1[int(5)], 0.0f);
    return;
}

static __device__ void project_displacement_slot_0(uint tid_16, Island_0 * isl_20, uint slot_4)
{
    uint _S1204;
    float3  _S1205 = make_float3 (0.0f);
    float3  p_14 = _S1205;
    float3  l_4 = _S1205;
    uint4  _S1206 = isl_20->range_0;
    uint _S1207 = isl_20->range_0.x + tid_16;
    uint c_34 = _S1207;
    for(;;)
    {
        uint _S1208 = _S1206.y;
        _S1204 = _S1208;
        if(c_34 < _S1208)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_0 * _S1209 = (&(globalParams_0->chunks_0)[c_34]);
        float4  _S1210 = *(&(globalParams_0->scratch_0)[sv_0(c_34, slot_4)]);
        float3  u_3 = float3 {_S1210.x, _S1210.y, _S1210.z};
        float4  _S1211 = *(&(globalParams_0->scratch_0)[sv_0(c_34, slot_4 + 1U)]);
        float3  th_4 = float3 {_S1211.x, _S1211.y, _S1211.z};
        float4  _S1212 = __ldg(&_S1209->center_0);
        float4  _S1213 = isl_20->com_0;
        float3  r_13 = float3 {_S1212.x, _S1212.y, _S1212.z} - float3 {_S1213.x, _S1213.y, _S1213.z};
        float _S1214 = _S1212.w;
        p_14 = p_14 + u_3 * make_float3 (_S1214);
        float3  _S1215 = cross_0(r_13, u_3) * make_float3 (_S1214);
        float4  _S1216 = __ldg(&_S1209->inertia0_0);
        float4  _S1217 = __ldg(&_S1209->inertia1_0);
        float4  _S1218 = __ldg(&_S1209->inertia2_0);
        l_4 = l_4 + (_S1215 + rows_mul_0(_S1216, _S1217, _S1218, th_4));
        c_34 = c_34 + 256U;
    }
    group_sum3_0(tid_16, &p_14, &l_4);
    float4  _S1219 = isl_20->com_0;
    float3  _S1220 = p_14 / make_float3 (isl_20->com_0.w);
    float3  _S1221 = rows_mul_0(isl_20->inv0_1, isl_20->inv1_1, isl_20->inv2_1, l_4);
    c_34 = _S1207;
    for(;;)
    {
        if(c_34 < _S1204)
        {
        }
        else
        {
            break;
        }
        float4  _S1222 = __ldg(&(&(globalParams_0->chunks_0)[c_34])->center_0);
        uint _S1223 = sv_0(c_34, slot_4);
        float4  _S1224 = *(&(globalParams_0->scratch_0)[_S1223]);
        *(&(globalParams_0->scratch_0)[_S1223]) = make_float4 ((float3 {_S1224.x, _S1224.y, _S1224.z} - _S1220 - cross_0(_S1221, float3 {_S1222.x, _S1222.y, _S1222.z} - float3 {_S1219.x, _S1219.y, _S1219.z})).x, (float3 {_S1224.x, _S1224.y, _S1224.z} - _S1220 - cross_0(_S1221, float3 {_S1222.x, _S1222.y, _S1222.z} - float3 {_S1219.x, _S1219.y, _S1219.z})).y, (float3 {_S1224.x, _S1224.y, _S1224.z} - _S1220 - cross_0(_S1221, float3 {_S1222.x, _S1222.y, _S1222.z} - float3 {_S1219.x, _S1219.y, _S1219.z})).z, 0.0f);
        uint _S1225 = sv_0(c_34, slot_4 + 1U);
        float4  _S1226 = *(&(globalParams_0->scratch_0)[_S1225]);
        *(&(globalParams_0->scratch_0)[_S1225]) = make_float4 ((float3 {_S1226.x, _S1226.y, _S1226.z} - _S1221).x, (float3 {_S1226.x, _S1226.y, _S1226.z} - _S1221).y, (float3 {_S1226.x, _S1226.y, _S1226.z} - _S1221).z, 0.0f);
        c_34 = c_34 + 256U;
    }
    __syncthreads();
    return;
}

static __device__ uint statics_result_slot_0(uint island_1)
{
    uint _S1227 = __ldg(&globalParams_0->params_0->statics_base_0);
    uint _S1228 = __ldg(&globalParams_0->params_0->chunk_count_0);
    uint _S1229 = _S1227 + 23U * _S1228;
    uint _S1230 = __ldg(&globalParams_0->params_0->statics_bonds_0);
    return _S1229 + 2U * _S1230 + island_1;
}

static __device__ void write_bond_loads_0(uint _S1231, uint _S1232, float3  _S1233, float3  _S1234, float _S1235)
{
    BondStatic_0 * _S1236 = (&(globalParams_0->bonds_0)[_S1232]);
    float3  _S1237 = to_body_0(_S1232, _S1233);
    float3  _S1238 = to_body_0(_S1232, _S1234);
    uint _S1239 = 3U * _S1231;
    *(&(globalParams_0->scratch_0)[_S1239]) = make_float4 (_S1237.x, _S1237.y, _S1237.z, _S1235);
    float4  * _S1240 = (&(globalParams_0->scratch_0)[_S1239 + 1U]);
    float4  _S1241 = __ldg(&_S1236->ra_0);
    *_S1240 = make_float4 ((_S1238 + cross_0(float3 {_S1241.x, _S1241.y, _S1241.z}, _S1237)).x, (_S1238 + cross_0(float3 {_S1241.x, _S1241.y, _S1241.z}, _S1237)).y, (_S1238 + cross_0(float3 {_S1241.x, _S1241.y, _S1241.z}, _S1237)).z, 0.0f);
    float4  * _S1242 = (&(globalParams_0->scratch_0)[_S1239 + 2U]);
    float3  _S1243 = - _S1238;
    float4  _S1244 = __ldg(&_S1236->rb_0);
    *_S1242 = make_float4 ((_S1243 + cross_0(float3 {_S1244.x, _S1244.y, _S1244.z}, - _S1237)).x, (_S1243 + cross_0(float3 {_S1244.x, _S1244.y, _S1244.z}, - _S1237)).y, (_S1243 + cross_0(float3 {_S1244.x, _S1244.y, _S1244.z}, - _S1237)).z, 0.0f);
    return;
}

static __device__ void bond_kinematics_0(uint _S1245, float3  _S1246, float3  _S1247, float3  _S1248, float3  _S1249, float3  * _S1250, float3  * _S1251)
{
    BondStatic_0 * _S1252 = (&(globalParams_0->bonds_0)[_S1245]);
    float4  _S1253 = __ldg(&_S1252->rb_0);
    float3  _S1254 = _S1248 + cross_0(_S1249, float3 {_S1253.x, _S1253.y, _S1253.z});
    float4  _S1255 = __ldg(&_S1252->ra_0);
    float3  _S1256 = to_local_0(_S1245, _S1254 - (_S1246 + cross_0(_S1247, float3 {_S1255.x, _S1255.y, _S1255.z})));
    *_S1250 = _S1256;
    float3  _S1257 = to_local_0(_S1245, _S1249 - _S1247);
    *_S1251 = _S1257;
    return;
}

extern "C" __global__ void island_statics()
{
    uint i_24;
    bool converged_0;
    uint c_35;
    uint tid_17 = threadIdx.x;
    uint _S1258 = blockIdx.x;
    Island_0 * _S1259 = (&(globalParams_0->islands_0)[_S1258]);
    Island_0 isl_21 = *_S1259;
    uint _S1260 = (*_S1259).info_1.z;
    if((_S1260 & 8U) == 0U)
    {
        return;
    }
    bool free_0 = ((isl_21.info_1.x) & 1U) == 0U;
    uint c0_1 = isl_21.range_0.x;
    uint c1_1 = isl_21.range_0.y;
    uint b0_0 = isl_21.range_0.z;
    uint _S1261 = isl_21.range_0.w;
    uint _S1262 = c0_1 + tid_17;
    uint c_36 = _S1262;
    for(;;)
    {
        if(c_36 < c1_1)
        {
        }
        else
        {
            break;
        }
        float4  _S1263 = make_float4 (0.0f);
        *(&(globalParams_0->scratch_0)[sv_0(c_36, 21U)]) = _S1263;
        *(&(globalParams_0->scratch_0)[sv_0(c_36, 22U)]) = _S1263;
        c_36 = c_36 + 256U;
    }
    __syncthreads();
    if(free_0)
    {
        Island_0 _S1264 = isl_21;
        project_load_slot_0(tid_17, &_S1264, 0U);
    }
    float _S1265 = island_dot_0(tid_17, c0_1, c1_1, 0U, 0U);
    float _S1266 = (F32_max(((F32_sqrt((_S1265)))), (1.00000000317107685e-30f)));
    float _S1267 = __ldg(&globalParams_0->params_0->statics_tol_0);
    uint _S1268 = __ldg(&globalParams_0->params_0->statics_cg_0);
    uint _S1269 = (U32_min((_S1268), (20U * (c1_1 - c0_1) * 6U + 200U)));
    float previous_2 = 1.00000001504746622e+30f;
    float residual_0 = 0.0f;
    uint newton_0 = 0U;
    uint cg_total_0 = 0U;
    for(;;)
    {
        uint _S1270 = __ldg(&globalParams_0->params_0->statics_newton_0);
        if(newton_0 < _S1270)
        {
        }
        else
        {
            converged_0 = false;
            break;
        }
        uint _S1271 = b0_0 + tid_17;
        i_24 = _S1271;
        for(;;)
        {
            if(i_24 < _S1261)
            {
            }
            else
            {
                break;
            }
            JointResponse_0 resp_1 = static_response_0(i_24);
            write_bond_loads_0(i_24, i_24, resp_1.force_lin_1, resp_1.force_ang_1, 0.0f);
            i_24 = i_24 + 256U;
        }
        __syncthreads();
        float4  _S1272 = make_float4 (0.0f);
        float4  magnitude_0 = _S1272;
        float4  unused_m_0 = _S1272;
        c_36 = _S1262;
        for(;;)
        {
            if(c_36 < c1_1)
            {
            }
            else
            {
                break;
            }
            float3  fi_3;
            float3  mi_4;
            gather_loads_0(c_36, &fi_3, &mi_4);
            *&((&magnitude_0)->x) = *&((&magnitude_0)->x) + bond_load_magnitude2_0(c_36);
            float4  _S1273 = *(&(globalParams_0->scratch_0)[sv_0(c_36, 0U)]);
            float4  r_lin_0 = make_float4 ((float3 {_S1273.x, _S1273.y, _S1273.z} + fi_3).x, (float3 {_S1273.x, _S1273.y, _S1273.z} + fi_3).y, (float3 {_S1273.x, _S1273.y, _S1273.z} + fi_3).z, 0.0f);
            float4  _S1274 = *(&(globalParams_0->scratch_0)[sv_0(c_36, 1U)]);
            float4  r_ang_0 = make_float4 ((float3 {_S1274.x, _S1274.y, _S1274.z} + mi_4).x, (float3 {_S1274.x, _S1274.y, _S1274.z} + mi_4).y, (float3 {_S1274.x, _S1274.y, _S1274.z} + mi_4).z, 0.0f);
            hold_0(fixed_mask_0(c_36), &r_lin_0, &r_ang_0, _S1272, _S1272);
            *(&(globalParams_0->scratch_0)[sv_0(c_36, 4U)]) = r_lin_0;
            *(&(globalParams_0->scratch_0)[sv_0(c_36, 5U)]) = r_ang_0;
            c_36 = c_36 + 256U;
        }
        __syncthreads();
        group_sum2_0(tid_17, &magnitude_0, &unused_m_0);
        if(free_0)
        {
            Island_0 _S1275 = isl_21;
            project_load_slot_0(tid_17, &_S1275, 4U);
        }
        float _S1276 = island_dot_0(tid_17, c0_1, c1_1, 4U, 4U);
        float residual_1 = (F32_sqrt((_S1276))) / _S1266;
        float _S1277 = (F32_max((0.00100000004749745f), (3.83999986297567375e-06f * (F32_sqrt((magnitude_0.x))) / _S1266)));
        if(residual_1 <= _S1267)
        {
            converged_0 = true;
        }
        else
        {
            if(residual_1 <= _S1277)
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
        uint i_25 = _S1271;
        for(;;)
        {
            if(i_25 < _S1261)
            {
            }
            else
            {
                break;
            }
            BondStatic_0 * _S1278 = (&(globalParams_0->bonds_0)[i_25]);
            float3  d_lin_4;
            float3  d_ang_3;
            static_kinematics_0(i_25, &d_lin_4, &d_ang_3);
            JointBond_0 _S1279 = slang_ldg_0(&_S1278->law_0);
            JointBond_0 _S1280 = _S1279;
            JointState_0 _S1281 = (&(globalParams_0->bond_dyn_0)[i_25])->js_0;
            float3  f_lin_2;
            float3  f_ang_2;
            secant_factors_0(&_S1280, &_S1281, d_lin_4, &f_lin_2, &f_ang_2);
            uint _S1282 = statics_bond_slot_0(i_25);
            float _S1283 = _S1279.stiff0_0.y;
            *(&(globalParams_0->scratch_0)[_S1282]) = make_float4 (_S1283 * f_lin_2.x, _S1283 * f_lin_2.y, _S1279.stiff0_0.x * f_lin_2.z, 0.0f);
            *(&(globalParams_0->scratch_0)[_S1282 + 1U]) = make_float4 (_S1279.stiff0_0.z * f_ang_2.x, _S1279.stiff0_0.w * f_ang_2.y, _S1279.stiff1_0.x * f_ang_2.z, 0.0f);
            i_25 = i_25 + 256U;
        }
        __syncthreads();
        uint c_37 = _S1262;
        for(;;)
        {
            if(c_37 < c1_1)
            {
            }
            else
            {
                break;
            }
            assemble_block_0(c_37);
            *(&(globalParams_0->scratch_0)[sv_0(c_37, 2U)]) = _S1272;
            *(&(globalParams_0->scratch_0)[sv_0(c_37, 3U)]) = _S1272;
            c_37 = c_37 + 256U;
        }
        __syncthreads();
        uint c_38 = _S1262;
        for(;;)
        {
            if(c_38 < c1_1)
            {
            }
            else
            {
                break;
            }
            precondition_0(c_38);
            c_38 = c_38 + 256U;
        }
        __syncthreads();
        if(free_0)
        {
            Island_0 _S1284 = isl_21;
            project_displacement_slot_0(tid_17, &_S1284, 6U);
        }
        uint c_39 = _S1262;
        for(;;)
        {
            if(c_39 < c1_1)
            {
            }
            else
            {
                break;
            }
            *(&(globalParams_0->scratch_0)[sv_0(c_39, 8U)]) = *(&(globalParams_0->scratch_0)[sv_0(c_39, 6U)]);
            *(&(globalParams_0->scratch_0)[sv_0(c_39, 9U)]) = *(&(globalParams_0->scratch_0)[sv_0(c_39, 7U)]);
            c_39 = c_39 + 256U;
        }
        __syncthreads();
        float _S1285 = island_dot_0(tid_17, c0_1, c1_1, 4U, 6U);
        float _S1286 = island_dot_0(tid_17, c0_1, c1_1, 4U, 4U);
        float _S1287 = (F32_sqrt((_S1286)));
        float rz_0 = _S1285;
        uint k_22 = 0U;
        uint cg_total_1 = cg_total_0;
        for(;;)
        {
            bool _S1288;
            if(k_22 < _S1269)
            {
                _S1288 = _S1287 > 0.0f;
            }
            else
            {
                _S1288 = false;
            }
            if(_S1288)
            {
            }
            else
            {
                cg_total_0 = cg_total_1;
                break;
            }
            uint i_26 = _S1271;
            for(;;)
            {
                if(i_26 < _S1261)
                {
                }
                else
                {
                    break;
                }
                JointBond_0 _S1289 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_26])->law_0);
                uint ca_2 = _S1289.ids_0.y;
                uint cb_2 = _S1289.ids_0.z;
                float4  _S1290 = *(&(globalParams_0->scratch_0)[sv_0(ca_2, 8U)]);
                float4  _S1291 = *(&(globalParams_0->scratch_0)[sv_0(ca_2, 9U)]);
                float4  _S1292 = *(&(globalParams_0->scratch_0)[sv_0(cb_2, 8U)]);
                float4  _S1293 = *(&(globalParams_0->scratch_0)[sv_0(cb_2, 9U)]);
                float3  d_lin_5;
                float3  d_ang_4;
                bond_kinematics_0(i_26, float3 {_S1290.x, _S1290.y, _S1290.z}, float3 {_S1291.x, _S1291.y, _S1291.z}, float3 {_S1292.x, _S1292.y, _S1292.z}, float3 {_S1293.x, _S1293.y, _S1293.z}, &d_lin_5, &d_ang_4);
                uint _S1294 = statics_bond_slot_0(i_26);
                float4  _S1295 = *(&(globalParams_0->scratch_0)[_S1294]);
                float4  _S1296 = *(&(globalParams_0->scratch_0)[_S1294 + 1U]);
                write_bond_loads_0(i_26, i_26, d_lin_5 * float3 {_S1295.x, _S1295.y, _S1295.z}, d_ang_4 * float3 {_S1296.x, _S1296.y, _S1296.z}, 0.0f);
                i_26 = i_26 + 256U;
            }
            __syncthreads();
            c_35 = _S1262;
            for(;;)
            {
                if(c_35 < c1_1)
                {
                }
                else
                {
                    break;
                }
                float3  fi_4;
                float3  mi_5;
                gather_loads_0(c_35, &fi_4, &mi_5);
                float4  ap_lin_0 = make_float4 ((- fi_4).x, (- fi_4).y, (- fi_4).z, 0.0f);
                float4  ap_ang_0 = make_float4 ((- mi_5).x, (- mi_5).y, (- mi_5).z, 0.0f);
                hold_0(fixed_mask_0(c_35), &ap_lin_0, &ap_ang_0, *(&(globalParams_0->scratch_0)[sv_0(c_35, 8U)]), *(&(globalParams_0->scratch_0)[sv_0(c_35, 9U)]));
                *(&(globalParams_0->scratch_0)[sv_0(c_35, 10U)]) = ap_lin_0;
                *(&(globalParams_0->scratch_0)[sv_0(c_35, 11U)]) = ap_ang_0;
                c_35 = c_35 + 256U;
            }
            __syncthreads();
            float pap_0 = island_dot_0(tid_17, c0_1, c1_1, 8U, 10U);
            uint _S1297 = cg_total_1 + 1U;
            if(pap_0 <= 0.0f)
            {
                cg_total_0 = _S1297;
                break;
            }
            float _S1298 = rz_0 / pap_0;
            uint c_40 = _S1262;
            for(;;)
            {
                if(c_40 < c1_1)
                {
                }
                else
                {
                    break;
                }
                uint _S1299 = sv_0(c_40, 2U);
                float4  _S1300 = *(&(globalParams_0->scratch_0)[_S1299]);
                float4  _S1301 = *(&(globalParams_0->scratch_0)[sv_0(c_40, 8U)]);
                *(&(globalParams_0->scratch_0)[_S1299]) = make_float4 ((float3 {_S1300.x, _S1300.y, _S1300.z} + make_float3 (_S1298) * float3 {_S1301.x, _S1301.y, _S1301.z}).x, (float3 {_S1300.x, _S1300.y, _S1300.z} + make_float3 (_S1298) * float3 {_S1301.x, _S1301.y, _S1301.z}).y, (float3 {_S1300.x, _S1300.y, _S1300.z} + make_float3 (_S1298) * float3 {_S1301.x, _S1301.y, _S1301.z}).z, 0.0f);
                uint _S1302 = sv_0(c_40, 3U);
                float4  _S1303 = *(&(globalParams_0->scratch_0)[_S1302]);
                float4  _S1304 = *(&(globalParams_0->scratch_0)[sv_0(c_40, 9U)]);
                *(&(globalParams_0->scratch_0)[_S1302]) = make_float4 ((float3 {_S1303.x, _S1303.y, _S1303.z} + make_float3 (_S1298) * float3 {_S1304.x, _S1304.y, _S1304.z}).x, (float3 {_S1303.x, _S1303.y, _S1303.z} + make_float3 (_S1298) * float3 {_S1304.x, _S1304.y, _S1304.z}).y, (float3 {_S1303.x, _S1303.y, _S1303.z} + make_float3 (_S1298) * float3 {_S1304.x, _S1304.y, _S1304.z}).z, 0.0f);
                uint _S1305 = sv_0(c_40, 4U);
                float4  _S1306 = *(&(globalParams_0->scratch_0)[_S1305]);
                float4  _S1307 = *(&(globalParams_0->scratch_0)[sv_0(c_40, 10U)]);
                *(&(globalParams_0->scratch_0)[_S1305]) = make_float4 ((float3 {_S1306.x, _S1306.y, _S1306.z} - make_float3 (_S1298) * float3 {_S1307.x, _S1307.y, _S1307.z}).x, (float3 {_S1306.x, _S1306.y, _S1306.z} - make_float3 (_S1298) * float3 {_S1307.x, _S1307.y, _S1307.z}).y, (float3 {_S1306.x, _S1306.y, _S1306.z} - make_float3 (_S1298) * float3 {_S1307.x, _S1307.y, _S1307.z}).z, 0.0f);
                uint _S1308 = sv_0(c_40, 5U);
                float4  _S1309 = *(&(globalParams_0->scratch_0)[_S1308]);
                float4  _S1310 = *(&(globalParams_0->scratch_0)[sv_0(c_40, 11U)]);
                *(&(globalParams_0->scratch_0)[_S1308]) = make_float4 ((float3 {_S1309.x, _S1309.y, _S1309.z} - make_float3 (_S1298) * float3 {_S1310.x, _S1310.y, _S1310.z}).x, (float3 {_S1309.x, _S1309.y, _S1309.z} - make_float3 (_S1298) * float3 {_S1310.x, _S1310.y, _S1310.z}).y, (float3 {_S1309.x, _S1309.y, _S1309.z} - make_float3 (_S1298) * float3 {_S1310.x, _S1310.y, _S1310.z}).z, 0.0f);
                c_40 = c_40 + 256U;
            }
            __syncthreads();
            float _S1311 = island_dot_0(tid_17, c0_1, c1_1, 4U, 4U);
            if((F32_sqrt((_S1311))) <= (0.00009999999747379f * _S1287))
            {
                cg_total_0 = _S1297;
                break;
            }
            uint c_41 = _S1262;
            for(;;)
            {
                if(c_41 < c1_1)
                {
                }
                else
                {
                    break;
                }
                precondition_0(c_41);
                c_41 = c_41 + 256U;
            }
            __syncthreads();
            if(free_0)
            {
                Island_0 _S1312 = isl_21;
                project_displacement_slot_0(tid_17, &_S1312, 6U);
            }
            float rz_new_0 = island_dot_0(tid_17, c0_1, c1_1, 4U, 6U);
            float _S1313 = rz_new_0 / rz_0;
            uint c_42 = _S1262;
            for(;;)
            {
                if(c_42 < c1_1)
                {
                }
                else
                {
                    break;
                }
                uint _S1314 = sv_0(c_42, 8U);
                float4  _S1315 = *(&(globalParams_0->scratch_0)[sv_0(c_42, 6U)]);
                float4  _S1316 = *(&(globalParams_0->scratch_0)[_S1314]);
                *(&(globalParams_0->scratch_0)[_S1314]) = make_float4 ((float3 {_S1315.x, _S1315.y, _S1315.z} + make_float3 (_S1313) * float3 {_S1316.x, _S1316.y, _S1316.z}).x, (float3 {_S1315.x, _S1315.y, _S1315.z} + make_float3 (_S1313) * float3 {_S1316.x, _S1316.y, _S1316.z}).y, (float3 {_S1315.x, _S1315.y, _S1315.z} + make_float3 (_S1313) * float3 {_S1316.x, _S1316.y, _S1316.z}).z, 0.0f);
                uint _S1317 = sv_0(c_42, 9U);
                float4  _S1318 = *(&(globalParams_0->scratch_0)[sv_0(c_42, 7U)]);
                float4  _S1319 = *(&(globalParams_0->scratch_0)[_S1317]);
                *(&(globalParams_0->scratch_0)[_S1317]) = make_float4 ((float3 {_S1318.x, _S1318.y, _S1318.z} + make_float3 (_S1313) * float3 {_S1319.x, _S1319.y, _S1319.z}).x, (float3 {_S1318.x, _S1318.y, _S1318.z} + make_float3 (_S1313) * float3 {_S1319.x, _S1319.y, _S1319.z}).y, (float3 {_S1318.x, _S1318.y, _S1318.z} + make_float3 (_S1313) * float3 {_S1319.x, _S1319.y, _S1319.z}).z, 0.0f);
                c_42 = c_42 + 256U;
            }
            __syncthreads();
            uint _S1320 = k_22 + 1U;
            rz_0 = rz_new_0;
            k_22 = _S1320;
            cg_total_1 = _S1297;
        }
        c_35 = _S1262;
        for(;;)
        {
            if(c_35 < c1_1)
            {
            }
            else
            {
                break;
            }
            uint _S1321 = 4U * c_35;
            float4  _S1322 = *(&(globalParams_0->state_0)[_S1321]);
            float3  u_4 = float3 {_S1322.x, _S1322.y, _S1322.z};
            uint _S1323 = sv_0(c_35, 21U);
            float4  _S1324 = *(&(globalParams_0->scratch_0)[_S1323]);
            float3  u_lo_0 = float3 {_S1324.x, _S1324.y, _S1324.z};
            uint _S1325 = _S1321 + 1U;
            float4  _S1326 = *(&(globalParams_0->state_0)[_S1325]);
            float3  th_5 = float3 {_S1326.x, _S1326.y, _S1326.z};
            uint _S1327 = sv_0(c_35, 22U);
            float4  _S1328 = *(&(globalParams_0->scratch_0)[_S1327]);
            float3  th_lo_0 = float3 {_S1328.x, _S1328.y, _S1328.z};
            float4  _S1329 = *(&(globalParams_0->scratch_0)[sv_0(c_35, 2U)]);
            comp_add_0(&u_4, &u_lo_0, float3 {_S1329.x, _S1329.y, _S1329.z});
            float4  _S1330 = *(&(globalParams_0->scratch_0)[sv_0(c_35, 3U)]);
            comp_add_0(&th_5, &th_lo_0, float3 {_S1330.x, _S1330.y, _S1330.z});
            *(&(globalParams_0->state_0)[_S1321]) = make_float4 (u_4.x, u_4.y, u_4.z, (*(&(globalParams_0->state_0)[_S1321])).w);
            *(&(globalParams_0->state_0)[_S1325]) = make_float4 (th_5.x, th_5.y, th_5.z, (*(&(globalParams_0->state_0)[_S1325])).w);
            *(&(globalParams_0->scratch_0)[_S1323]) = make_float4 (u_lo_0.x, u_lo_0.y, u_lo_0.z, 0.0f);
            *(&(globalParams_0->scratch_0)[_S1327]) = make_float4 (th_lo_0.x, th_lo_0.y, th_lo_0.z, 0.0f);
            c_35 = c_35 + 256U;
        }
        __syncthreads();
        uint _S1331 = newton_0 + 1U;
        previous_2 = residual_1;
        residual_0 = residual_1;
        newton_0 = _S1331;
    }
    i_24 = b0_0 + tid_17;
    for(;;)
    {
        if(i_24 < _S1261)
        {
        }
        else
        {
            break;
        }
        JointResponse_0 resp_2 = static_response_0(i_24);
        BondDyn_0 bd_1 = *(&(globalParams_0->bond_dyn_0)[i_24]);
        (&bd_1)->force_lin_0 = make_float4 (resp_2.force_lin_1.x, resp_2.force_lin_1.y, resp_2.force_lin_1.z, resp_2.stored_5);
        (&bd_1)->force_ang_0 = make_float4 (resp_2.force_ang_1.x, resp_2.force_ang_1.y, resp_2.force_ang_1.z, (&bd_1)->force_ang_0.w);
        *(&(globalParams_0->bond_dyn_0)[i_24]) = bd_1;
        write_bond_loads_0(i_24, i_24, resp_2.force_lin_1, resp_2.force_ang_1, (F32_max((resp_2.measures_0.tension_0), (resp_2.measures_0.compression_0))));
        i_24 = i_24 + 256U;
    }
    __syncthreads();
    c_36 = _S1262;
    for(;;)
    {
        if(c_36 < c1_1)
        {
        }
        else
        {
            break;
        }
        float3  fi_5;
        float3  mi_6;
        gather_loads_0(c_36, &fi_5, &mi_6);
        float3  reaction_1;
        if((fixed_mask_0(c_36)) != 0U)
        {
            float4  _S1332 = *(&(globalParams_0->scratch_0)[sv_0(c_36, 0U)]);
            reaction_1 = - (float3 {_S1332.x, _S1332.y, _S1332.z} + fi_5);
        }
        else
        {
            uint _S1333 = 4U * c_36;
            reaction_1 = make_float3 ((*(&(globalParams_0->state_0)[_S1333 + 1U])).w, (*(&(globalParams_0->state_0)[_S1333 + 2U])).w, (*(&(globalParams_0->state_0)[_S1333 + 3U])).w);
        }
        uint _S1334 = 4U * c_36;
        uint _S1335 = _S1334 + 1U;
        float4  _S1336 = *(&(globalParams_0->state_0)[_S1335]);
        *(&(globalParams_0->state_0)[_S1335]) = make_float4 (float3 {_S1336.x, _S1336.y, _S1336.z}.x, float3 {_S1336.x, _S1336.y, _S1336.z}.y, float3 {_S1336.x, _S1336.y, _S1336.z}.z, reaction_1.x);
        *(&(globalParams_0->state_0)[_S1334 + 2U]) = make_float4 (0.0f, 0.0f, 0.0f, reaction_1.y);
        *(&(globalParams_0->state_0)[_S1334 + 3U]) = make_float4 (0.0f, 0.0f, 0.0f, reaction_1.z);
        c_36 = c_36 + 256U;
    }
    if(tid_17 == 0U)
    {
        float4  * _S1337 = (&(globalParams_0->scratch_0)[statics_result_slot_0(_S1258)]);
        float _S1338 = (U32_asfloat((newton_0)));
        float _S1339 = (U32_asfloat((cg_total_0)));
        if(converged_0)
        {
            previous_2 = 1.0f;
        }
        else
        {
            previous_2 = 0.0f;
        }
        *_S1337 = make_float4 (residual_0, _S1338, _S1339, previous_2);
        *&((&(&(globalParams_0->islands_0)[_S1258])->info_1)->z) = _S1260 & 4294967287U;
    }
    return;
}

extern "C" __global__ void settled_fatigue()
{
    uint tid_18 = threadIdx.x;
    uint _S1340 = blockIdx.x;
    Island_0 * _S1341 = (&(globalParams_0->islands_0)[_S1340]);
    Island_0 isl_22 = *_S1341;
    bool _S1342;
    if((((*_S1341).info_1.x) & 16U) == 0U)
    {
        _S1342 = true;
    }
    else
    {
        _S1342 = (isl_22.range_0.w) == (isl_22.range_0.z);
    }
    if(_S1342)
    {
        return;
    }
    bool _S1343 = tid_18 == 0U;
    if(_S1343)
    {
        *&g_halt_0 = 0U;
        *&g_run_0 = 0U;
    }
    __syncthreads();
    uint _S1344 = isl_22.info_1.w;
    uint i_27 = isl_22.range_0.z + tid_18;
    for(;;)
    {
        if(i_27 < (isl_22.range_0.w))
        {
        }
        else
        {
            break;
        }
        BondStatic_0 * _S1345 = (&(globalParams_0->bonds_0)[i_27]);
        BondDyn_0 bd_2 = *(&(globalParams_0->bond_dyn_0)[i_27]);
        JointBond_0 _S1346 = slang_ldg_0(&_S1345->law_0);
        uint _S1347 = 4U * _S1346.ids_0.y;
        float4  _S1348 = *(&(globalParams_0->state_0)[_S1347]);
        float4  _S1349 = *(&(globalParams_0->state_0)[_S1347 + 1U]);
        uint _S1350 = 4U * _S1346.ids_0.z;
        float4  _S1351 = *(&(globalParams_0->state_0)[_S1350]);
        float4  _S1352 = *(&(globalParams_0->state_0)[_S1350 + 1U]);
        float3  d_lin_6;
        float3  d_ang_5;
        bond_kinematics_0(i_27, float3 {_S1348.x, _S1348.y, _S1348.z}, float3 {_S1349.x, _S1349.y, _S1349.z}, float3 {_S1351.x, _S1351.y, _S1351.z}, float3 {_S1352.x, _S1352.y, _S1352.z}, &d_lin_6, &d_ang_5);
        JointState_0 previous_3 = (&bd_2)->js_0;
        float3  _S1353 = d_lin_6;
        float3  _S1354 = d_ang_5;
        float _S1355 = __ldg(&globalParams_0->params_0->dt_0);
        uint _S1356 = __ldg(&globalParams_0->params_0->fracture_0);
        bool _S1357 = _S1356 != 0U;
        JointBond_0 _S1358 = _S1346;
        JointState_0 _S1359 = previous_3;
        JointResponse_0 _S1360 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S1346.ids_0.x], &_S1358, &_S1359, _S1353, _S1354, _S1355, _S1357);
        if((_S1360.state_1.damage_0) > (previous_3.damage_0 + 9.99999971718068537e-10f))
        {
            _S1342 = true;
        }
        else
        {
            _S1342 = (_S1360.state_1.crush_0) > (previous_3.crush_0 + 9.99999971718068537e-10f);
        }
        uint flags_2;
        if(_S1342)
        {
            flags_2 = 16U;
        }
        else
        {
            flags_2 = 0U;
        }
        comp_add1_0(&((&(&bd_2)->sums_0)->x), &((&(&bd_2)->comps_0)->x), _S1360.dissipated_2);
        comp_add1_0(&((&(&bd_2)->sums_0)->y), &((&(&bd_2)->comps_0)->y), _S1360.overshoot_0);
        (&bd_2)->force_lin_0 = make_float4 (_S1360.force_lin_1.x, _S1360.force_lin_1.y, _S1360.force_lin_1.z, _S1360.stored_5);
        (&bd_2)->force_ang_0 = make_float4 (_S1360.force_ang_1.x, _S1360.force_ang_1.y, _S1360.force_ang_1.z, (F32_max(((&bd_2)->force_ang_0.w), (_S1360.state_1.utilization_0))));
        JointState_0 _S1361 = previous_3;
        bool _S1362 = is_damaged_0(&_S1361);
        bool _S1363;
        if(!_S1362)
        {
            JointState_0 _S1364 = _S1360.state_1;
            bool _S1365 = is_damaged_0(&_S1364);
            _S1363 = _S1365;
        }
        else
        {
            _S1363 = false;
        }
        bool _S1366;
        if(_S1363)
        {
            _S1366 = ((&bd_2)->events_0.x) == 0U;
        }
        else
        {
            _S1366 = false;
        }
        if(_S1366)
        {
            *&((&(&bd_2)->events_0)->x) = _S1344;
            *&((&(&bd_2)->events_0)->w) = _S1360.state_1.mode_0;
        }
        bool _S1367;
        if(((&bd_2)->events_0.y) == 0U)
        {
            float _S1368 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S1346.ids_0.x], previous_3.fatigue_0);
            _S1367 = _S1368 > 0.99000000953674316f;
        }
        else
        {
            _S1367 = false;
        }
        bool _S1369;
        if(_S1367)
        {
            float _S1370 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S1346.ids_0.x], _S1360.state_1.fatigue_0);
            _S1369 = _S1370 <= 0.99000000953674316f;
        }
        else
        {
            _S1369 = false;
        }
        if(_S1369)
        {
            *&((&(&bd_2)->events_0)->y) = _S1344;
        }
        uint flags_3;
        if(_S1360.disconnected_0)
        {
            *&((&(&bd_2)->events_0)->z) = _S1344;
            flags_3 = flags_2 | 32U;
        }
        else
        {
            flags_3 = flags_2;
        }
        (&bd_2)->js_0 = _S1360.state_1;
        *(&(globalParams_0->bond_dyn_0)[i_27]) = bd_2;
        write_bond_loads_0(i_27, i_27, _S1360.force_lin_1, _S1360.force_ang_1, (F32_max((_S1360.measures_0.tension_0), (_S1360.measures_0.compression_0))));
        if((flags_3 & 16U) != 0U)
        {
            *&g_halt_0 = 1U;
        }
        if((flags_3 & 32U) != 0U)
        {
            *&g_run_0 = 1U;
        }
        i_27 = i_27 + 256U;
    }
    __syncthreads();
    if(_S1343)
    {
        _S1342 = ((*&g_halt_0) | (*&g_run_0)) != 0U;
    }
    else
    {
        _S1342 = false;
    }
    if(_S1342)
    {
        uint _S1371 = isl_22.info_1.z;
        if((*&g_halt_0) != 0U)
        {
            i_27 = 16U;
        }
        else
        {
            i_27 = 0U;
        }
        uint _S1372 = _S1371 | i_27;
        if((*&g_run_0) != 0U)
        {
            i_27 = 32U;
        }
        else
        {
            i_27 = 0U;
        }
        *&((&(&(globalParams_0->islands_0)[_S1340])->info_1)->z) = _S1372 | i_27;
    }
    return;
}

