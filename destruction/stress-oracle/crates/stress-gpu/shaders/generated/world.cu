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
    uint done_0;
    uint coverage_0;
    uint wide_groups_0;
    uint done_pad_0;
    uint4  probes_0;
    float4  energy_1;
    float4  rotation_err_0;
    float4  momentum_0;
    float4  momentum_err_0;
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
    float4  rotation_err_1;
    float4  ledger_0;
    uint4  cand_0;
    float4  momentum_1;
    float4  momentum_err_1;
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

__device__ static const FixedArray<float, 6>  SPRING_AT_0 = { {
    -0.4166666567325592f, -0.25f, -0.0833333358168602f, 0.0833333358168602f, 0.25f, 0.4166666567325592f
} };
static __device__ float clamp_0(float x_1, float minBound_0, float maxBound_0)
{
    return (F32_min(((F32_max((x_1), (minBound_0)))), (maxBound_0)));
}

static __device__ uint WaveGetActiveMask_0(uint _S1)
{
    return _S1;
}

static __device__ float4  WaveActiveSum_0(float4  expr_0, uint _S2)
{
    float4  _S3 = (_waveSumMultiple((make_uint4 (WaveGetActiveMask_0(_S2), 0U, 0U, 0U)).x, (expr_0)));
    return _S3;
}

__device__ __shared__ FixedArray<float4 , 32>  g_part_a_0;

__device__ __shared__ FixedArray<float4 , 32>  g_part_b_0;

static __device__ void group_sum2_0(uint tid_0, float4  * a_0, float4  * b_0, uint _S4)
{
    float4  _S5 = WaveActiveSum_0(*a_0, _S4);
    float4  _S6 = WaveActiveSum_0(*b_0, _S4);
    bool _S7 = (tid_0 % 32U) == 0U;
    uint _S8 = __ballot_sync(_S4, _S7);
    if(_S7)
    {
        (*&g_part_a_0)[tid_0 / 32U] = _S5;
        (*&g_part_b_0)[tid_0 / 32U] = _S6;
    }
    __syncthreads();
    uint w_0 = 1U;
    float4  sa_0 = (*&g_part_a_0)[int(0)];
    float4  sb_0 = (*&g_part_b_0)[int(0)];
    for(;;)
    {
        if(w_0 < 8U)
        {
        }
        else
        {
            break;
        }
        float4  sa_1 = sa_0 + (*&g_part_a_0)[w_0];
        float4  sb_1 = sb_0 + (*&g_part_b_0)[w_0];
        w_0 = w_0 + 1U;
        sa_0 = sa_1;
        sb_0 = sb_1;
    }
    __syncthreads();
    *a_0 = sa_0;
    *b_0 = sb_0;
    return;
}

static __device__ void group_sum3_0(uint tid_1, float3  * a_1, float3  * b_1, uint _S9)
{
    float4  x_2 = make_float4 ((*a_1).x, (*a_1).y, (*a_1).z, 0.0f);
    float4  y_1 = make_float4 ((*b_1).x, (*b_1).y, (*b_1).z, 0.0f);
    group_sum2_0(tid_1, &x_2, &y_1, _S9);
    float4  _S10 = x_2;
    *a_1 = float3 {_S10.x, _S10.y, _S10.z};
    float4  _S11 = y_1;
    *b_1 = float3 {_S11.x, _S11.y, _S11.z};
    return;
}

static __device__ uint4  asuint_0(float4  x_3)
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
        *_slang_vector_get_element_ptr(&result_1, i_1) = (F32_asuint((_slang_vector_get_element(x_3, i_1))));
        i_1 = i_1 + int(1);
    }
    return result_1;
}

static __device__ float4  abs_0(float4  x_4)
{
    float4  result_2;
    int i_2 = int(0);
    for(;;)
    {
        if(i_2 < int(4))
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

static __device__ float dot_0(float3  x_5, float3  y_2)
{
    return x_5.x * y_2.x + x_5.y * y_2.y + x_5.z * y_2.z;
}

static __device__ float3  abs_1(float3  x_6)
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
        *_slang_vector_get_element_ptr(&result_3, i_3) = (F32_abs((_slang_vector_get_element(x_6, i_3))));
        i_3 = i_3 + int(1);
    }
    return result_3;
}

static __device__ float3  min_0(float3  x_7, float3  y_3)
{
    float3  result_4;
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
        *_slang_vector_get_element_ptr(&result_4, i_4) = (F32_min((_slang_vector_get_element(x_7, i_4)), (_slang_vector_get_element(y_3, i_4))));
        i_4 = i_4 + int(1);
    }
    return result_4;
}

static __device__ float3  clamp_1(float3  x_8, float3  minBound_1, float3  maxBound_1)
{
    return min_0(max_0(x_8, minBound_1), maxBound_1);
}

static __device__ bool any_0(bool3  x_9)
{
    bool result_5 = false;
    int i_5 = int(0);
    for(;;)
    {
        if(i_5 < int(3))
        {
        }
        else
        {
            break;
        }
        if(result_5)
        {
            result_5 = true;
        }
        else
        {
            result_5 = (bool((_slang_vector_get_element(x_9, i_5))));
        }
        i_5 = i_5 + int(1);
    }
    return result_5;
}

static __device__ float3  cross_0(float3  left_0, float3  right_0)
{
    float _S12 = left_0.y;
    float _S13 = right_0.z;
    float _S14 = left_0.z;
    float _S15 = right_0.y;
    float _S16 = right_0.x;
    float _S17 = left_0.x;
    return make_float3 (_S12 * _S13 - _S14 * _S15, _S14 * _S16 - _S17 * _S13, _S17 * _S15 - _S12 * _S16);
}

static __device__ float length_0(float3  x_10)
{
    return (F32_sqrt((dot_0(x_10, x_10))));
}

static __device__ bool stopped_0()
{
    uint _S18 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint4  _S19 = (&(globalParams_0->islands_0)[_S18])->info_1;
    bool _S20;
    if((((&(globalParams_0->islands_0)[_S18])->info_1.z) & 1U) != 0U)
    {
        _S20 = true;
    }
    else
    {
        _S20 = (_S19.y) != 0U;
    }
    return _S20;
}

struct Quat_0
{
    float w_1;
    float x_11;
    float y_4;
    float z_0;
};

static __device__ Quat_0 quat_of_0(float4  q_0)
{
    Quat_0 r_0;
    (&r_0)->x_11 = q_0.x;
    (&r_0)->y_4 = q_0.y;
    (&r_0)->z_0 = q_0.z;
    (&r_0)->w_1 = q_0.w;
    return r_0;
}

static __device__ float3  rotate_0(Quat_0 * q_1, float3  v_0)
{
    float3  qv_0 = make_float3 (q_1->x_11, q_1->y_4, q_1->z_0);
    float3  t_0 = cross_0(qv_0, v_0) * make_float3 (2.0f);
    return v_0 + t_0 * make_float3 (q_1->w_1) + cross_0(qv_0, t_0);
}

struct WorldPoint_0
{
    float3  hi_0;
    float3  lo_0;
    float3  rel_0;
};

static __device__ WorldPoint_0 chunk_world_0(uint c_0)
{
    ChunkStatic_0 * _S21 = (&(globalParams_0->chunks_0)[c_0]);
    uint4  _S22 = __ldg(&_S21->info_0);
    Island_0 * _S23 = (&(globalParams_0->islands_0)[_S22.y]);
    Quat_0 q_2 = quat_of_0(_S23->rotation_0);
    WorldPoint_0 w_2;
    float4  _S24 = _S23->position_0;
    (&w_2)->hi_0 = float3 {_S24.x, _S24.y, _S24.z};
    float4  _S25 = _S23->position_err_0;
    (&w_2)->lo_0 = float3 {_S25.x, _S25.y, _S25.z};
    float4  _S26 = __ldg(&_S21->center_0);
    float4  _S27 = *(&(globalParams_0->state_0)[4U * c_0]);
    float3  _S28 = float3 {_S26.x, _S26.y, _S26.z} + float3 {_S27.x, _S27.y, _S27.z};
    Quat_0 _S29 = q_2;
    float3  _S30 = rotate_0(&_S29, _S28);
    (&w_2)->rel_0 = _S30;
    return w_2;
}

static __device__ float3  world_diff_0(WorldPoint_0 * a_2, WorldPoint_0 * b_2)
{
    return a_2->hi_0 - b_2->hi_0 + (a_2->lo_0 - b_2->lo_0) + (a_2->rel_0 - b_2->rel_0);
}

static __device__ float3  safe_normalize_0(float3  v_1)
{
    float n_0 = length_0(v_1);
    float3  _S31;
    if(n_0 > 1.00000000317107685e-30f)
    {
        _S31 = v_1 / make_float3 (n_0);
    }
    else
    {
        _S31 = make_float3 (0.0f);
    }
    return _S31;
}

static __device__ Quat_0 from_axis_angle_0(float3  axis_0, float angle_0)
{
    float3  a_3 = safe_normalize_0(axis_0);
    float _S32 = 0.5f * angle_0;
    float s_0 = (F32_sin((_S32)));
    Quat_0 q_3;
    (&q_3)->w_1 = (F32_cos((_S32)));
    (&q_3)->x_11 = a_3.x * s_0;
    (&q_3)->y_4 = a_3.y * s_0;
    (&q_3)->z_0 = a_3.z * s_0;
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
    ChunkStatic_0 * _S33 = (&(globalParams_0->chunks_0)[c_1]);
    uint4  _S34 = __ldg(&_S33->info_0);
    Quat_0 q_4 = quat_of_0((&(globalParams_0->islands_0)[_S34.y])->rotation_0);
    float4  _S35 = *(&(globalParams_0->state_0)[4U * c_1 + 1U]);
    float3  th_0 = float3 {_S35.x, _S35.y, _S35.z};
    Quat_0 hidden_0 = from_axis_angle_0(th_0, length_0(th_0));
    Box_0 b_3;
    (&b_3)->center_1 = center_2;
    float4  _S36 = __ldg(&_S33->crot0_0);
    float _S37 = _S36.x;
    float4  _S38 = __ldg(&_S33->crot1_0);
    float _S39 = _S38.x;
    float4  _S40 = __ldg(&_S33->crot2_0);
    float3  _S41 = make_float3 (_S37, _S39, _S40.x);
    Quat_0 _S42 = hidden_0;
    float3  _S43 = rotate_0(&_S42, _S41);
    Quat_0 _S44 = q_4;
    float3  _S45 = rotate_0(&_S44, _S43);
    (&b_3)->axis0_0 = _S45;
    float3  _S46 = make_float3 (_S36.y, _S38.y, _S40.y);
    Quat_0 _S47 = hidden_0;
    float3  _S48 = rotate_0(&_S47, _S46);
    Quat_0 _S49 = q_4;
    float3  _S50 = rotate_0(&_S49, _S48);
    (&b_3)->axis1_0 = _S50;
    float3  _S51 = make_float3 (_S36.z, _S38.z, _S40.z);
    Quat_0 _S52 = hidden_0;
    float3  _S53 = rotate_0(&_S52, _S51);
    Quat_0 _S54 = q_4;
    float3  _S55 = rotate_0(&_S54, _S53);
    (&b_3)->axis2_0 = _S55;
    float4  _S56 = __ldg(&_S33->half_0);
    (&b_3)->half_2 = float3 {_S56.x, _S56.y, _S56.z};
    float4  _S57 = __ldg(&_S33->cmat_0);
    (&b_3)->hull_at_0 = (F32_asuint((_S57.z)));
    uint _S58 = (F32_asuint((_S57.w)));
    (&b_3)->hull_v_0 = _S58 & 255U;
    (&b_3)->hull_f_0 = _S58 >> int(8);
    return b_3;
}

static __device__ uint sample_count_0(Box_0 * b_4)
{
    uint _S59 = b_4->hull_v_0;
    uint _S60;
    if((b_4->hull_v_0) == 0U)
    {
        _S60 = 14U;
    }
    else
    {
        _S60 = _S59 + b_4->hull_f_0;
    }
    return _S60;
}

static __device__ bool may_overlap_0(Box_0 * a_4, Box_0 * b_5)
{
    float3  _S61 = b_5->center_1 - a_4->center_1;
    float3  _S62 = a_4->half_2;
    float3  _S63 = b_5->half_2;
    float _S64 = 0.00000999999974738f * (length_0(a_4->half_2) + length_0(b_5->half_2));
    float3  _S65 = a_4->axis0_0;
    float3  _S66 = a_4->axis1_0;
    float3  _S67 = a_4->axis2_0;
    float3  _S68 = b_5->axis0_0;
    float3  _S69 = b_5->axis1_0;
    float3  _S70 = b_5->axis2_0;
    FixedArray<float3 , 6>  _S71 = { {
        a_4->axis0_0, a_4->axis1_0, a_4->axis2_0, b_5->axis0_0, b_5->axis1_0, b_5->axis2_0
    } };
    uint i_6 = 0U;
    for(;;)
    {
        if(i_6 < 15U)
        {
        }
        else
        {
            break;
        }
        float3  l_0;
        if(i_6 < 6U)
        {
            l_0 = _S71[i_6];
        }
        else
        {
            uint _S72 = i_6 - 6U;
            l_0 = cross_0(_S71[_S72 / 3U], _S71[3U + _S72 % 3U]);
        }
        float len_0 = length_0(l_0);
        if(len_0 <= 9.99999997475242708e-07f)
        {
            i_6 = i_6 + 1U;
            continue;
        }
        if((F32_abs((dot_0(_S61, l_0)))) > (_S62.x * (F32_abs((dot_0(_S65, l_0)))) + _S62.y * (F32_abs((dot_0(_S66, l_0)))) + _S62.z * (F32_abs((dot_0(_S67, l_0)))) + (_S63.x * (F32_abs((dot_0(_S68, l_0)))) + _S63.y * (F32_abs((dot_0(_S69, l_0)))) + _S63.z * (F32_abs((dot_0(_S70, l_0))))) + _S64 * len_0))
        {
            return false;
        }
        i_6 = i_6 + 1U;
    }
    return true;
}

static __device__ void chunk_velocity_0(uint c_2, float3  * v_2, float3  * w_3)
{
    ChunkStatic_0 * _S73 = (&(globalParams_0->chunks_0)[c_2]);
    uint4  _S74 = __ldg(&_S73->info_0);
    Island_0 * _S75 = (&(globalParams_0->islands_0)[_S74.y]);
    Quat_0 q_5 = quat_of_0(_S75->rotation_0);
    float4  _S76 = __ldg(&_S73->center_0);
    uint _S77 = 4U * c_2;
    float4  _S78 = *(&(globalParams_0->state_0)[_S77]);
    float4  _S79 = _S75->com_0;
    float3  _S80 = float3 {_S76.x, _S76.y, _S76.z} + float3 {_S78.x, _S78.y, _S78.z} - float3 {_S79.x, _S79.y, _S79.z};
    Quat_0 _S81 = q_5;
    float3  _S82 = rotate_0(&_S81, _S80);
    float4  _S83 = _S75->velocity_0;
    float4  _S84 = _S75->velocity_err_0;
    float4  _S85 = _S75->angular_velocity_0;
    float3  _S86 = float3 {_S85.x, _S85.y, _S85.z};
    float3  _S87 = float3 {_S83.x, _S83.y, _S83.z} + float3 {_S84.x, _S84.y, _S84.z} + cross_0(_S86, _S82);
    float4  _S88 = *(&(globalParams_0->state_0)[_S77 + 2U]);
    float3  _S89 = float3 {_S88.x, _S88.y, _S88.z};
    Quat_0 _S90 = q_5;
    float3  _S91 = rotate_0(&_S90, _S89);
    *v_2 = _S87 + _S91;
    float4  _S92 = *(&(globalParams_0->state_0)[_S77 + 3U]);
    float3  _S93 = float3 {_S92.x, _S92.y, _S92.z};
    Quat_0 _S94 = q_5;
    float3  _S95 = rotate_0(&_S94, _S93);
    *w_3 = _S86 + _S95;
    return;
}

static __device__ float3  box_to_world_0(Box_0 * b_6, float3  local_0)
{
    return b_6->axis0_0 * make_float3 (local_0.x) + b_6->axis1_0 * make_float3 (local_0.y) + b_6->axis2_0 * make_float3 (local_0.z);
}

static __device__ float3  box_axis_0(Box_0 * b_7, uint k_0)
{
    float3  _S96;
    if(k_0 == 0U)
    {
        _S96 = b_7->axis0_0;
    }
    else
    {
        if(k_0 == 1U)
        {
            _S96 = b_7->axis1_0;
        }
        else
        {
            _S96 = b_7->axis2_0;
        }
    }
    return _S96;
}

static __device__ float comp3_0(float3  v_3, uint k_1)
{
    float _S97;
    if(k_1 == 0U)
    {
        _S97 = v_3.x;
    }
    else
    {
        if(k_1 == 1U)
        {
            _S97 = v_3.y;
        }
        else
        {
            _S97 = v_3.z;
        }
    }
    return _S97;
}

static __device__ float3  sample_point_0(Box_0 * b_8, uint i_7)
{
    uint _S98 = b_8->hull_v_0;
    if((b_8->hull_v_0) != 0U)
    {
        float3  local_1;
        if(i_7 < _S98)
        {
            float4  _S99 = __ldg((&(globalParams_0->loads_0)[b_8->hull_at_0 + i_7]));
            local_1 = float3 {_S99.x, _S99.y, _S99.z} * make_float3 (0.89999997615814209f);
        }
        else
        {
            float4  _S100 = __ldg((&(globalParams_0->loads_0)[b_8->hull_at_0 + _S98 + b_8->hull_f_0 + (i_7 - _S98)]));
            local_1 = float3 {_S100.x, _S100.y, _S100.z};
        }
        float3  _S101 = b_8->center_1;
        float3  _S102 = box_to_world_0(b_8, local_1);
        return _S101 + _S102;
    }
    float sign_0;
    if(i_7 < 8U)
    {
        float3  h_0 = b_8->half_2 * make_float3 (0.89999997615814209f);
        if((i_7 & 1U) == 0U)
        {
            sign_0 = - h_0.x;
        }
        else
        {
            sign_0 = h_0.x;
        }
        float _S103;
        if((i_7 & 2U) == 0U)
        {
            _S103 = - h_0.y;
        }
        else
        {
            _S103 = h_0.y;
        }
        float _S104;
        if((i_7 & 4U) == 0U)
        {
            _S104 = - h_0.z;
        }
        else
        {
            _S104 = h_0.z;
        }
        return b_8->center_1 + b_8->axis0_0 * make_float3 (sign_0) + b_8->axis1_0 * make_float3 (_S103) + b_8->axis2_0 * make_float3 (_S104);
    }
    uint _S105 = i_7 - 8U;
    uint axis_1 = _S105 / 2U;
    if((_S105 % 2U) == 0U)
    {
        sign_0 = -1.0f;
    }
    else
    {
        sign_0 = 1.0f;
    }
    float3  _S106 = b_8->center_1;
    float3  _S107 = box_axis_0(b_8, axis_1);
    return _S106 + _S107 * make_float3 (sign_0 * comp3_0(b_8->half_2, axis_1));
}

static __device__ float3  box_to_local_0(Box_0 * b_9, float3  r_1)
{
    return make_float3 (dot_0(r_1, b_9->axis0_0), dot_0(r_1, b_9->axis1_0), dot_0(r_1, b_9->axis2_0));
}

static __device__ float hull_signed_distance_0(Box_0 * b_10, float3  local_2, uint * face_0)
{
    *face_0 = 0U;
    float best_0 = -1.00000001504746622e+30f;
    uint f_0 = 0U;
    for(;;)
    {
        if(f_0 < (b_10->hull_f_0))
        {
        }
        else
        {
            break;
        }
        float4  _S108 = __ldg((&(globalParams_0->loads_0)[b_10->hull_at_0 + b_10->hull_v_0 + f_0]));
        float d_0 = dot_0(float3 {_S108.x, _S108.y, _S108.z}, local_2) - _S108.w;
        if(d_0 > best_0)
        {
            *face_0 = f_0;
            best_0 = d_0;
        }
        f_0 = f_0 + 1U;
    }
    return best_0;
}

static __device__ bool penetration_0(Box_0 * b_11, float3  p_0, float * depth_0, float3  * normal_1)
{
    *depth_0 = 0.0f;
    *normal_1 = make_float3 (0.0f);
    float3  r_2 = p_0 - b_11->center_1;
    float3  _S109 = b_11->half_2;
    if((dot_0(r_2, r_2)) > (dot_0(b_11->half_2, b_11->half_2) * 1.00001001358032227f))
    {
        return false;
    }
    uint _S110 = b_11->hull_v_0;
    if((b_11->hull_v_0) != 0U)
    {
        float3  _S111 = box_to_local_0(b_11, r_2);
        uint face_1;
        float _S112 = hull_signed_distance_0(b_11, _S111, &face_1);
        if(!(_S112 < 0.0f))
        {
            return false;
        }
        *depth_0 = - _S112;
        float4  _S113 = __ldg((&(globalParams_0->loads_0)[b_11->hull_at_0 + _S110 + face_1]));
        float3  _S114 = box_to_world_0(b_11, float3 {_S113.x, _S113.y, _S113.z});
        *normal_1 = _S114;
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
        float3  _S115 = box_axis_0(b_11, k_2);
        float local_3 = dot_0(r_2, _S115);
        float d_1 = comp3_0(_S109, k_2) - (F32_abs((local_3)));
        if(d_1 <= 0.0f)
        {
            return false;
        }
        if(d_1 < best_1)
        {
            float _S116;
            if(local_3 >= 0.0f)
            {
                _S116 = 1.0f;
            }
            else
            {
                _S116 = -1.0f;
            }
            best_1 = d_1;
            axis_2 = k_2;
            side_0 = _S116;
        }
        k_2 = k_2 + 1U;
    }
    *depth_0 = best_1;
    float3  _S117 = box_axis_0(b_11, axis_2);
    *normal_1 = _S117 * make_float3 (side_0);
    return true;
}

static __device__ bool pair_point_0(Box_0 * ba_0, Box_0 * bb_0, uint na_0, uint e_0, float3  * p_1, float3  * n_1, float * d_2)
{
    if(e_0 < na_0)
    {
        float3  _S118 = sample_point_0(ba_0, e_0);
        *p_1 = _S118;
        bool _S119 = penetration_0(bb_0, _S118, d_2, n_1);
        return _S119;
    }
    float3  _S120 = sample_point_0(bb_0, e_0 - na_0);
    *p_1 = _S120;
    bool _S121 = penetration_0(ba_0, _S120, d_2, n_1);
    if(!_S121)
    {
        return false;
    }
    *n_1 = - *n_1;
    return true;
}

static __device__ bool is_nan_0(float x_12)
{
    return ((F32_asuint((x_12))) & 2147483647U) > 2139095040U;
}

static __device__ float2  half_thickness_and_area_0(Box_0 * b_12, float3  d_3)
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
        float3  _S122 = box_axis_0(b_12, k_3);
        float c_3 = (F32_abs((dot_0(d_3, _S122))));
        float h_2 = h_1 + c_3 * comp3_0(b_12->half_2, k_3);
        uint _S123 = k_3 + 1U;
        float area_1 = area_0 + c_3 * 4.0f * comp3_0(b_12->half_2, _S123 % 3U) * comp3_0(b_12->half_2, (k_3 + 2U) % 3U);
        k_3 = _S123;
        h_1 = h_2;
        area_0 = area_1;
    }
    return make_float2 (h_1, area_0);
}

static __device__ float contact_stiffness_0(float ea_0, Box_0 * a_5, float eb_0, Box_0 * b_13, float3  dir_0)
{
    float3  d_4 = safe_normalize_0(dir_0);
    float2  _S124 = half_thickness_and_area_0(a_5, d_4);
    float2  _S125 = half_thickness_and_area_0(b_13, d_4);
    return (F32_min((_S124.y), (_S125.y))) / (_S124.x / ea_0 + _S125.x / eb_0);
}

static __device__ float3  penalty_force_0(float k_4, float m_red_0, float friction_0, float depth_1, float3  normal_2, float3  rel_velocity_0, float dt_1, uint points_0, float * stored_0, float * dissipated_1)
{
    float c_max_0 = 1.0f / (F32_max((float(points_0)), (10.0f))) * m_red_0 / dt_1;
    float _S126 = __ldg(&globalParams_0->params_0->zeta_0);
    float vn_0 = dot_0(rel_velocity_0, normal_2);
    float _S127 = k_4 * depth_1;
    float _S128 = (F32_min((2.0f * _S126 * (F32_sqrt((k_4 * m_red_0)))), (c_max_0))) * vn_0;
    float _S129 = _S127 - _S128;
    float _S130 = (F32_max((_S129), (0.0f)));
    float3  vt_0 = rel_velocity_0 - normal_2 * make_float3 (vn_0);
    float vt_mag_0 = length_0(vt_0);
    float _S131 = friction_0 * _S130;
    float _S132 = (F32_min((_S131), ((F32_min((c_max_0), (_S131 / 0.00100000004749745f))) * vt_mag_0)));
    float3  ft_0;
    if(vt_mag_0 > 0.0f)
    {
        ft_0 = - vt_0 * make_float3 (_S132 / vt_mag_0);
    }
    else
    {
        ft_0 = make_float3 (0.0f);
    }
    *stored_0 = 0.5f * k_4 * depth_1 * depth_1;
    float damping_power_0;
    if(_S129 > 0.0f)
    {
        damping_power_0 = _S128 * vn_0;
    }
    else
    {
        damping_power_0 = _S127 * (F32_max((vn_0), (0.0f)));
    }
    *dissipated_1 = (damping_power_0 + length_0(ft_0) * vt_mag_0) * dt_1;
    return normal_2 * make_float3 (_S130) + ft_0;
}

static __device__ void comp_add1_0(float * sum_0, float * err_0, float x_13)
{
    float t_1 = *sum_0 + x_13;
    if((F32_abs((*sum_0))) >= (F32_abs((x_13))))
    {
        *err_0 = *err_0 + (*sum_0 - t_1 + x_13);
    }
    else
    {
        *err_0 = *err_0 + (x_13 - t_1 + *sum_0);
    }
    *sum_0 = t_1;
    return;
}

static __device__ void cov_or_0(uint island_0, uint bits_0)
{
    uint _S133 = atomicOr(&(&(globalParams_0->islands_0)[island_0])->coverage_0, bits_0);
    return;
}

static __device__ void cov_mark_0(uint island_1, uint seen_0, uint bits_1)
{
    if((bits_1 & (~seen_0)) != 0U)
    {
        cov_or_0(island_1, bits_1);
    }
    return;
}

static __device__ void sentinel_mark_0(uint bits_2)
{
    uint _S134 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint _S135 = __ldg(&globalParams_0->params_0->halt_index_0);
    cov_mark_0(_S134, (&(globalParams_0->islands_0)[_S135])->coverage_0, bits_2);
    return;
}

static __device__ void pair_contact_0(uint i_8)
{
    uint _S136 = __ldg(&globalParams_0->params_0->pair_index_0);
    uint at_0 = _S136 + 6U * i_8;
    uint _S137 = __ldg((&(globalParams_0->index_0)[at_0]));
    uint _S138 = __ldg((&(globalParams_0->index_0)[at_0 + 1U]));
    uint _S139 = __ldg((&(globalParams_0->index_0)[at_0 + 2U]));
    uint _S140 = __ldg((&(globalParams_0->index_0)[at_0 + 3U]));
    uint _S141 = __ldg((&(globalParams_0->index_0)[at_0 + 4U]));
    float _S142 = (U32_asfloat((_S141)));
    uint _S143 = __ldg((&(globalParams_0->index_0)[at_0 + 5U]));
    float _S144 = (U32_asfloat((_S143)));
    float _S145 = __ldg(&globalParams_0->params_0->dt_0);
    uint _S146 = __ldg(&globalParams_0->params_0->slot_base_0);
    uint out_0 = _S146 + 2U * _S139;
    WorldPoint_0 wa_0 = chunk_world_0(_S137);
    WorldPoint_0 _S147 = chunk_world_0(_S138);
    WorldPoint_0 _S148 = wa_0;
    float3  _S149 = world_diff_0(&_S147, &_S148);
    float _S150 = length_0(_S149);
    float4  _S151 = __ldg(&(&(globalParams_0->chunks_0)[_S137])->half_0);
    float _S152 = _S151.w;
    float4  _S153 = __ldg(&(&(globalParams_0->chunks_0)[_S138])->half_0);
    bool touching_0 = !(_S150 > (_S152 + _S153.w));
    uint _S154 = __ldg(&globalParams_0->params_0->ledger_base_0);
    float4  * _S155 = (&(globalParams_0->scratch_0)[_S154 + i_8]);
    float4  ledger_1 = *_S155;
    uint flags_0 = (F32_asuint(((*_S155).w)));
    float3  _S156 = make_float3 (0.0f);
    Box_0 ba_1 = chunk_box_0(_S137, _S156);
    Box_0 bb_1 = chunk_box_0(_S138, _S149);
    Box_0 _S157 = ba_1;
    uint _S158 = sample_count_0(&_S157);
    Box_0 _S159 = bb_1;
    uint _S160 = sample_count_0(&_S159);
    uint _S161 = _S158 + _S160;
    uint e_1;
    bool has_state_0;
    if(!touching_0)
    {
        if((flags_0 & 1U) != 0U)
        {
            e_1 = 0U;
            for(;;)
            {
                if(e_1 < _S161)
                {
                }
                else
                {
                    break;
                }
                *(&(globalParams_0->contact_state_0)[_S140 + e_1]) = make_float4 ((U32_asfloat((2143289344U))), 0.0f, 0.0f, 0.0f);
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
            uint _S162 = __ldg(&globalParams_0->params_0->ledger_base_0);
            *(&(globalParams_0->scratch_0)[_S162 + i_8]) = ledger_1;
        }
        return;
    }
    Box_0 _S163 = ba_1;
    Box_0 _S164 = bb_1;
    bool _S165 = may_overlap_0(&_S163, &_S164);
    uint count_0;
    float3  fa_0;
    float3  ta_0;
    float3  fb_0;
    float3  tb_0;
    float stored_sum_0;
    if(_S165)
    {
        float3  va0_0;
        float3  wa0_0;
        chunk_velocity_0(_S137, &va0_0, &wa0_0);
        float3  vb0_0;
        float3  wb0_0;
        chunk_velocity_0(_S138, &vb0_0, &wb0_0);
        e_1 = 0U;
        count_0 = 0U;
        uint engaged_0 = 0U;
        for(;;)
        {
            if(e_1 < _S161)
            {
            }
            else
            {
                break;
            }
            Box_0 _S166 = ba_1;
            Box_0 _S167 = bb_1;
            float3  p_2;
            float3  n_2;
            float d_5;
            bool _S168 = pair_point_0(&_S166, &_S167, _S158, e_1, &p_2, &n_2, &d_5);
            if(!_S168)
            {
                uint _S169 = _S140 + e_1;
                if(!is_nan_0((*(&(globalParams_0->contact_state_0)[_S169])).x))
                {
                    *(&(globalParams_0->contact_state_0)[_S169]) = make_float4 ((U32_asfloat((2143289344U))), 0.0f, 0.0f, 0.0f);
                }
                e_1 = e_1 + 1U;
                continue;
            }
            uint _S170 = count_0 + 1U;
            uint _S171 = _S140 + e_1;
            float4  * _S172 = (&(globalParams_0->contact_state_0)[_S171]);
            float4  entry_0 = *_S172;
            if(is_nan_0((*_S172).x))
            {
                has_state_0 = true;
            }
            else
            {
                float4  _S173 = entry_0;
                has_state_0 = (dot_0(float3 {_S173.y, _S173.z, _S173.w}, n_2)) < 0.99000000953674316f;
            }
            if(has_state_0)
            {
                if(d_5 > (2.0f * (F32_abs((dot_0(va0_0 + cross_0(wa0_0, p_2) - (vb0_0 + cross_0(wb0_0, p_2 - bb_1.center_1)), n_2)))) * _S145 + 9.99999971718068537e-10f))
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
            *(&(globalParams_0->contact_state_0)[_S171]) = entry_0;
            uint engaged_1;
            if((d_5 - entry_0.x) > 0.0f)
            {
                engaged_1 = engaged_0 + 1U;
            }
            else
            {
                engaged_1 = engaged_0;
            }
            count_0 = _S170;
            engaged_0 = engaged_1;
            e_1 = e_1 + 1U;
        }
        if(count_0 > 0U)
        {
            float4  _S174 = __ldg(&(&(globalParams_0->chunks_0)[_S137])->cmat_0);
            float _S175 = _S174.x;
            float4  _S176 = __ldg(&(&(globalParams_0->chunks_0)[_S138])->cmat_0);
            float _S177 = _S176.x;
            float3  _S178 = bb_1.center_1 - ba_1.center_1;
            Box_0 _S179 = ba_1;
            Box_0 _S180 = bb_1;
            float _S181 = contact_stiffness_0(_S175, &_S179, _S177, &_S180, _S178);
            float _S182 = _S181 / (F32_max((float(engaged_0)), (10.0f)));
            e_1 = 0U;
            fa_0 = _S156;
            ta_0 = _S156;
            fb_0 = _S156;
            tb_0 = _S156;
            stored_sum_0 = 0.0f;
            for(;;)
            {
                if(e_1 < _S161)
                {
                }
                else
                {
                    break;
                }
                Box_0 _S183 = ba_1;
                Box_0 _S184 = bb_1;
                float3  p_3;
                float3  n_3;
                float d_6;
                bool _S185 = pair_point_0(&_S183, &_S184, _S158, e_1, &p_3, &n_3, &d_6);
                if(!_S185)
                {
                    e_1 = e_1 + 1U;
                    continue;
                }
                float eff_0 = d_6 - (*(&(globalParams_0->contact_state_0)[_S140 + e_1])).x;
                if(eff_0 <= 0.0f)
                {
                    e_1 = e_1 + 1U;
                    continue;
                }
                float stored_1;
                float diss_0;
                float3  f_1 = penalty_force_0(_S182, _S142, _S144, eff_0, n_3, va0_0 + cross_0(wa0_0, p_3) - (vb0_0 + cross_0(wb0_0, p_3 - bb_1.center_1)), _S145, engaged_0, &stored_1, &diss_0);
                float3  fa_1 = fa_0 + f_1;
                float3  ta_1 = ta_0 + cross_0(p_3, f_1);
                float3  _S186 = - f_1;
                float3  fb_1 = fb_0 + _S186;
                float3  tb_1 = tb_0 + cross_0(p_3 - bb_1.center_1, _S186);
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
            fa_0 = _S156;
            ta_0 = _S156;
            fb_0 = _S156;
            tb_0 = _S156;
            stored_sum_0 = 0.0f;
        }
    }
    else
    {
        has_state_0 = false;
        fa_0 = _S156;
        ta_0 = _S156;
        fb_0 = _S156;
        tb_0 = _S156;
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
            if(e_1 < _S161)
            {
            }
            else
            {
                break;
            }
            *(&(globalParams_0->contact_state_0)[_S140 + e_1]) = make_float4 ((U32_asfloat((2143289344U))), 0.0f, 0.0f, 0.0f);
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
    bool _S187;
    if(loaded_0)
    {
        _S187 = true;
    }
    else
    {
        _S187 = (flags_0 & 2U) != 0U;
    }
    if(_S187)
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
    uint _S188 = __ldg(&globalParams_0->params_0->ledger_base_0);
    *(&(globalParams_0->scratch_0)[_S188 + i_8]) = ledger_1;
    if(loaded_0)
    {
        sentinel_mark_0(1U);
    }
    return;
}

static __device__ Box_0 impactor_box_0(Impactor_0 * imp_0, float3  center_3, float3  half_3)
{
    Quat_0 q_6 = quat_of_0(imp_0->rotation_1);
    Box_0 b_14;
    (&b_14)->center_1 = center_3;
    float3  _S189 = make_float3 (1.0f, 0.0f, 0.0f);
    Quat_0 _S190 = q_6;
    float3  _S191 = rotate_0(&_S190, _S189);
    (&b_14)->axis0_0 = _S191;
    float3  _S192 = make_float3 (0.0f, 1.0f, 0.0f);
    Quat_0 _S193 = q_6;
    float3  _S194 = rotate_0(&_S193, _S192);
    (&b_14)->axis1_0 = _S194;
    float3  _S195 = make_float3 (0.0f, 0.0f, 1.0f);
    Quat_0 _S196 = q_6;
    float3  _S197 = rotate_0(&_S196, _S195);
    (&b_14)->axis2_0 = _S197;
    (&b_14)->half_2 = half_3;
    (&b_14)->hull_at_0 = 0U;
    (&b_14)->hull_v_0 = 0U;
    (&b_14)->hull_f_0 = 0U;
    return b_14;
}

static __device__ uint impactor_slots_0(Impactor_0 * imp_1, Box_0 * b_15)
{
    uint _S198;
    if((imp_1->shape_0.x) == 0.0f)
    {
        _S198 = 1U;
    }
    else
    {
        uint _S199 = sample_count_0(b_15);
        _S198 = _S199 + 14U;
    }
    return _S198;
}

static __device__ bool sphere_contact_0(Box_0 * b_16, float3  center_4, float radius_0, float3  * point_0, float3  * normal_3, float * depth_2)
{
    float3  _S200 = make_float3 (0.0f);
    *point_0 = _S200;
    *normal_3 = _S200;
    *depth_2 = 0.0f;
    float3  _S201 = b_16->center_1;
    float3  r_3 = center_4 - b_16->center_1;
    float3  _S202 = b_16->axis0_0;
    float3  _S203 = b_16->axis1_0;
    float3  _S204 = b_16->axis2_0;
    float3  local_4 = make_float3 (dot_0(r_3, b_16->axis0_0), dot_0(r_3, b_16->axis1_0), dot_0(r_3, b_16->axis2_0));
    uint _S205 = b_16->hull_v_0;
    if((b_16->hull_v_0) != 0U)
    {
        uint face_2;
        float _S206 = hull_signed_distance_0(b_16, local_4, &face_2);
        if(_S206 >= radius_0)
        {
            return false;
        }
        float4  _S207 = __ldg((&(globalParams_0->loads_0)[b_16->hull_at_0 + _S205 + face_2]));
        float3  _S208 = box_to_world_0(b_16, float3 {_S207.x, _S207.y, _S207.z});
        *normal_3 = _S208;
        *point_0 = center_4 - _S208 * make_float3 ((F32_max((_S206), (0.0f))));
        *depth_2 = radius_0 - _S206;
        return true;
    }
    float3  q_7 = clamp_1(local_4, - b_16->half_2, b_16->half_2);
    float3  d_7 = local_4 - q_7;
    float dist_0 = length_0(d_7);
    if(dist_0 > 9.999999960041972e-13f)
    {
        if(dist_0 >= radius_0)
        {
            return false;
        }
        float3  dn_0 = d_7 / make_float3 (dist_0);
        *normal_3 = _S202 * make_float3 (dn_0.x) + _S203 * make_float3 (dn_0.y) + _S204 * make_float3 (dn_0.z);
        *point_0 = _S201 + _S202 * make_float3 (q_7.x) + _S203 * make_float3 (q_7.y) + _S204 * make_float3 (q_7.z);
        *depth_2 = radius_0 - dist_0;
        return true;
    }
    float inside_0;
    float3  n_4;
    bool _S209 = penetration_0(b_16, center_4, &inside_0, &n_4);
    if(!_S209)
    {
        return false;
    }
    *normal_3 = n_4;
    *point_0 = center_4 - n_4 * make_float3 ((F32_min((radius_0), (inside_0))));
    *depth_2 = radius_0 + inside_0;
    return true;
}

static __device__ bool impactor_contact_0(Impactor_0 * imp_2, float crush_depth_0, Box_0 * shrunk_0, Box_0 * b_17, uint j_0, float3  * p_4, float3  * n_5, float * d_8)
{
    float3  _S210 = make_float3 (0.0f);
    *p_4 = _S210;
    *n_5 = _S210;
    *d_8 = 0.0f;
    float4  _S211 = imp_2->shape_0;
    if((imp_2->shape_0.x) == 0.0f)
    {
        bool _S212 = sphere_contact_0(b_17, _S210, _S211.y - crush_depth_0, p_4, n_5, d_8);
        if(!_S212)
        {
            return false;
        }
        *n_5 = - *n_5;
        return true;
    }
    uint _S213 = sample_count_0(b_17);
    if(j_0 < _S213)
    {
        float3  _S214 = sample_point_0(b_17, j_0);
        *p_4 = _S214;
        bool _S215 = penetration_0(shrunk_0, _S214, d_8, n_5);
        return _S215;
    }
    float3  _S216 = sample_point_0(shrunk_0, j_0 - _S213);
    *p_4 = _S216;
    bool _S217 = penetration_0(b_17, _S216, d_8, n_5);
    if(!_S217)
    {
        return false;
    }
    *n_5 = - *n_5;
    return true;
}

static __device__ WorldPoint_0 impactor_point_0(uint _S218)
{
    Impactor_0 * _S219 = (&(globalParams_0->impactors_0)[_S218]);
    WorldPoint_0 wi_0;
    float4  _S220 = _S219->position_1;
    (&wi_0)->hi_0 = float3 {_S220.x, _S220.y, _S220.z};
    float4  _S221 = _S219->position_err_1;
    (&wi_0)->lo_0 = float3 {_S221.x, _S221.y, _S221.z};
    (&wi_0)->rel_0 = make_float3 (0.0f);
    return wi_0;
}

static __device__ Box_0 impactor_box_1(uint _S222, float3  _S223, float3  _S224)
{
    Quat_0 q_8 = quat_of_0((&(globalParams_0->impactors_0)[_S222])->rotation_1);
    Box_0 b_18;
    (&b_18)->center_1 = _S223;
    float3  _S225 = make_float3 (1.0f, 0.0f, 0.0f);
    Quat_0 _S226 = q_8;
    float3  _S227 = rotate_0(&_S226, _S225);
    (&b_18)->axis0_0 = _S227;
    float3  _S228 = make_float3 (0.0f, 1.0f, 0.0f);
    Quat_0 _S229 = q_8;
    float3  _S230 = rotate_0(&_S229, _S228);
    (&b_18)->axis1_0 = _S230;
    float3  _S231 = make_float3 (0.0f, 0.0f, 1.0f);
    Quat_0 _S232 = q_8;
    float3  _S233 = rotate_0(&_S232, _S231);
    (&b_18)->axis2_0 = _S233;
    (&b_18)->half_2 = _S224;
    (&b_18)->hull_at_0 = 0U;
    (&b_18)->hull_v_0 = 0U;
    (&b_18)->hull_f_0 = 0U;
    return b_18;
}

static __device__ Box_0 impactor_shrunk_0(uint _S234, float _S235, Box_0 * _S236)
{
    Box_0 shrunk_1 = *_S236;
    (&shrunk_1)->half_2 = _S236->half_2 - min_0(make_float3 (_S235), _S236->half_2 * make_float3 (0.5f));
    return shrunk_1;
}

static __device__ bool impactor_contact_1(uint _S237, float _S238, Box_0 * _S239, Box_0 * _S240, uint _S241, float3  * _S242, float3  * _S243, float * _S244)
{
    Impactor_0 _S245 = *(&(globalParams_0->impactors_0)[_S237]);
    float3  _S246 = make_float3 (0.0f);
    *_S242 = _S246;
    *_S243 = _S246;
    *_S244 = 0.0f;
    if((_S245.shape_0.x) == 0.0f)
    {
        bool _S247 = sphere_contact_0(_S240, _S246, _S245.shape_0.y - _S238, _S242, _S243, _S244);
        if(!_S247)
        {
            return false;
        }
        *_S243 = - *_S243;
        return true;
    }
    uint _S248 = sample_count_0(_S240);
    if(_S241 < _S248)
    {
        float3  _S249 = sample_point_0(_S240, _S241);
        *_S242 = _S249;
        bool _S250 = penetration_0(_S239, _S249, _S244, _S243);
        return _S250;
    }
    float3  _S251 = sample_point_0(_S239, _S241 - _S248);
    *_S242 = _S251;
    bool _S252 = penetration_0(_S240, _S251, _S244, _S243);
    if(!_S252)
    {
        return false;
    }
    *_S243 = - *_S243;
    return true;
}

static __device__ uint impactor_contact_count_0(uint _S253, float _S254, Box_0 * _S255, Box_0 * _S256)
{
    Impactor_0 _S257 = *(&(globalParams_0->impactors_0)[_S253]);
    uint j_1 = 0U;
    uint count_1 = 0U;
    for(;;)
    {
        Impactor_0 _S258 = _S257;
        uint _S259 = impactor_slots_0(&_S258, _S256);
        if(j_1 < _S259)
        {
        }
        else
        {
            break;
        }
        float3  p_5;
        float3  n_6;
        float d_9;
        bool _S260 = impactor_contact_1(_S253, _S254, _S255, _S256, j_1, &p_5, &n_6, &d_9);
        if(_S260)
        {
            count_1 = count_1 + 1U;
        }
        j_1 = j_1 + 1U;
    }
    return count_1;
}

static __device__ void impactor_candidate_forces_0(uint k_5)
{
    uint _S261 = __ldg(&globalParams_0->params_0->cand_index_0);
    uint _S262 = 3U * k_5;
    uint at_1 = _S261 + _S262;
    uint _S263 = __ldg((&(globalParams_0->index_0)[at_1]));
    uint _S264 = __ldg((&(globalParams_0->index_0)[at_1 + 1U]));
    uint _S265 = __ldg((&(globalParams_0->index_0)[at_1 + 2U]));
    Impactor_0 imp_3 = *(&(globalParams_0->impactors_0)[_S265]);
    float _S266 = __ldg(&globalParams_0->params_0->dt_0);
    float3  _S267 = make_float3 (0.0f);
    uint _S268 = __ldg(&globalParams_0->params_0->cand_base_0);
    float4  data_0 = *(&(globalParams_0->scratch_0)[_S268 + _S262]);
    bool hit_0;
    float3  f_sum_0;
    float3  t_sum_0;
    float3  imp_f_0;
    float3  imp_t_0;
    if((imp_3.cand_0.z) == 0U)
    {
        WorldPoint_0 _S269 = impactor_point_0(_S265);
        WorldPoint_0 _S270 = chunk_world_0(_S263);
        WorldPoint_0 _S271 = _S269;
        float3  _S272 = world_diff_0(&_S270, &_S271);
        float _S273 = length_0(_S272);
        float _S274 = imp_3.half_1.w;
        float4  _S275 = __ldg(&(&(globalParams_0->chunks_0)[_S263])->half_0);
        if(!(_S273 > (_S274 + _S275.w)))
        {
            float4  _S276 = imp_3.half_1;
            Box_0 _S277 = impactor_box_1(_S265, _S267, float3 {_S276.x, _S276.y, _S276.z});
            Box_0 b_19 = chunk_box_0(_S263, _S272);
            float _S278 = imp_3.mat_0.x;
            float4  _S279 = __ldg(&(&(globalParams_0->chunks_0)[_S263])->cmat_0);
            float _S280 = _S279.x;
            float3  _S281 = b_19.center_1 - _S277.center_1;
            Box_0 _S282 = _S277;
            Box_0 _S283 = b_19;
            float _S284 = contact_stiffness_0(_S278, &_S282, _S280, &_S283, _S281);
            float _S285 = imp_3.geom_0.y;
            Box_0 _S286 = _S277;
            Box_0 _S287 = impactor_shrunk_0(_S265, _S285, &_S286);
            Box_0 _S288 = _S287;
            Box_0 _S289 = b_19;
            uint _S290 = impactor_contact_count_0(_S265, _S285, &_S288, &_S289);
            bool _S291 = (imp_3.shape_0.x) == 0.0f;
            float _S292;
            if(_S291)
            {
                _S292 = _S284;
            }
            else
            {
                _S292 = _S284 / (F32_max((float(_S290)), (10.0f)));
            }
            uint _S293;
            if(_S291)
            {
                _S293 = 1U;
            }
            else
            {
                _S293 = _S290;
            }
            float4  _S294 = __ldg(&(&(globalParams_0->chunks_0)[_S263])->center_0);
            float m_1 = _S294.w;
            float _S295 = imp_3.mat_0.z;
            float _S296 = m_1 * _S295 / (m_1 + _S295);
            float _S297 = __ldg(&globalParams_0->params_0->pair_friction_0);
            float _S298;
            if(_S297 >= 0.0f)
            {
                float _S299 = __ldg(&globalParams_0->params_0->pair_friction_0);
                _S298 = _S299;
            }
            else
            {
                float _S300 = imp_3.mat_0.y;
                float4  _S301 = __ldg(&(&(globalParams_0->chunks_0)[_S263])->cmat_0);
                _S298 = (F32_min((_S300), (_S301.y)));
            }
            float4  _S302 = imp_3.velocity_1;
            float4  _S303 = imp_3.velocity_err_1;
            float3  _S304 = float3 {_S302.x, _S302.y, _S302.z} + float3 {_S303.x, _S303.y, _S303.z};
            float3  vc_0;
            float3  wc_0;
            chunk_velocity_0(_S263, &vc_0, &wc_0);
            hit_0 = false;
            uint j_2 = 0U;
            f_sum_0 = _S267;
            t_sum_0 = _S267;
            imp_f_0 = _S267;
            imp_t_0 = _S267;
            for(;;)
            {
                bool _S305;
                if(_S290 > 0U)
                {
                    Impactor_0 _S306 = imp_3;
                    Box_0 _S307 = b_19;
                    uint _S308 = impactor_slots_0(&_S306, &_S307);
                    _S305 = j_2 < _S308;
                }
                else
                {
                    _S305 = false;
                }
                if(_S305)
                {
                }
                else
                {
                    break;
                }
                Impactor_0 _S309 = imp_3;
                Box_0 _S310 = _S287;
                Box_0 _S311 = b_19;
                float3  p_6;
                float3  nrm_0;
                float dep_0;
                bool _S312 = impactor_contact_0(&_S309, _S285, &_S310, &_S311, j_2, &p_6, &nrm_0, &dep_0);
                if(!_S312)
                {
                    j_2 = j_2 + 1U;
                    continue;
                }
                float4  _S313 = imp_3.angular_velocity_1;
                float stored_2;
                float diss_1;
                float3  f_2 = penalty_force_0(_S292, _S296, _S298, dep_0 * imp_3.geom_0.x, nrm_0, vc_0 + cross_0(wc_0, p_6 - b_19.center_1) - (_S304 + cross_0(float3 {_S313.x, _S313.y, _S313.z}, p_6)), _S266, _S293, &stored_2, &diss_1);
                float3  f_sum_1 = f_sum_0 + f_2;
                float3  t_sum_1 = t_sum_0 + cross_0(p_6 - b_19.center_1, f_2);
                float3  imp_f_1 = imp_f_0 - f_2;
                float3  imp_t_1 = imp_t_0 - cross_0(p_6, f_2);
                comp_add1_0(&((&data_0)->z), &((&data_0)->w), diss_1);
                hit_0 = true;
                f_sum_0 = f_sum_1;
                t_sum_0 = t_sum_1;
                imp_f_0 = imp_f_1;
                imp_t_0 = imp_t_1;
                j_2 = j_2 + 1U;
            }
        }
        else
        {
            hit_0 = false;
            f_sum_0 = _S267;
            t_sum_0 = _S267;
            imp_f_0 = _S267;
            imp_t_0 = _S267;
        }
    }
    else
    {
        hit_0 = false;
        f_sum_0 = _S267;
        t_sum_0 = _S267;
        imp_f_0 = _S267;
        imp_t_0 = _S267;
    }
    uint _S314 = __ldg(&globalParams_0->params_0->slot_base_0);
    uint _S315 = 2U * _S264;
    *(&(globalParams_0->scratch_0)[_S314 + _S315]) = make_float4 (f_sum_0.x, f_sum_0.y, f_sum_0.z, 0.0f);
    uint _S316 = __ldg(&globalParams_0->params_0->slot_base_0);
    *(&(globalParams_0->scratch_0)[_S316 + _S315 + 1U]) = make_float4 (t_sum_0.x, t_sum_0.y, t_sum_0.z, 0.0f);
    uint _S317 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S317 + _S262]) = data_0;
    uint _S318 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S318 + _S262 + 1U]) = make_float4 (imp_f_0.x, imp_f_0.y, imp_f_0.z, 0.0f);
    uint _S319 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S319 + _S262 + 2U]) = make_float4 (imp_t_0.x, imp_t_0.y, imp_t_0.z, 0.0f);
    if(hit_0)
    {
        sentinel_mark_0(2U);
    }
    return;
}

static __device__ void travel_check_0(uint c_4)
{
    ChunkStatic_0 * _S320 = (&(globalParams_0->chunks_0)[c_4]);
    uint4  _S321 = __ldg(&_S320->cinfo_0);
    if((_S321.z) == 0U)
    {
        return;
    }
    WorldPoint_0 wp_0 = chunk_world_0(c_4);
    float4  _S322 = __ldg(&_S320->start_hi_0);
    float3  _S323 = wp_0.hi_0 - float3 {_S322.x, _S322.y, _S322.z};
    float4  _S324 = __ldg(&_S320->start_lo_0);
    if((length_0(_S323 + (wp_0.lo_0 - float3 {_S324.x, _S324.y, _S324.z}) + wp_0.rel_0)) > (_S322.w))
    {
        uint _S325 = __ldg(&globalParams_0->params_0->halt_index_0);
        uint _S326 = __ldg(&globalParams_0->params_0->halt_index_0);
        *&((&(&(globalParams_0->islands_0)[_S325])->info_1)->z) = ((&(globalParams_0->islands_0)[_S326])->info_1.z) | 1U;
        sentinel_mark_0(1048576U);
    }
    return;
}

extern "C" __global__ void contact_forces()
{
    uint i_9 = (blockIdx * blockDim + threadIdx).x;
    if(stopped_0())
    {
        return;
    }
    uint _S327 = __ldg(&globalParams_0->params_0->pair_count_0);
    if(i_9 < _S327)
    {
        pair_contact_0(i_9);
    }
    else
    {
        uint _S328 = __ldg(&globalParams_0->params_0->pair_count_0);
        uint _S329 = __ldg(&globalParams_0->params_0->cand_count_0);
        if(i_9 < (_S328 + _S329))
        {
            uint _S330 = __ldg(&globalParams_0->params_0->pair_count_0);
            impactor_candidate_forces_0(i_9 - _S330);
        }
        else
        {
            uint _S331 = __ldg(&globalParams_0->params_0->pair_count_0);
            uint _S332 = __ldg(&globalParams_0->params_0->cand_count_0);
            uint _S333 = _S331 + _S332;
            uint _S334 = __ldg(&globalParams_0->params_0->chunk_count_0);
            if(i_9 < (_S333 + _S334))
            {
                uint _S335 = __ldg(&globalParams_0->params_0->pair_count_0);
                uint _S336 = i_9 - _S335;
                uint _S337 = __ldg(&globalParams_0->params_0->cand_count_0);
                travel_check_0(_S336 - _S337);
            }
        }
    }
    return;
}

extern "C" __global__ void impactor_shares()
{
    uint k_6 = (blockIdx * blockDim + threadIdx).x;
    uint _S338 = __ldg(&globalParams_0->params_0->cand_count_0);
    bool _S339;
    if(k_6 >= _S338)
    {
        _S339 = true;
    }
    else
    {
        _S339 = stopped_0();
    }
    if(_S339)
    {
        return;
    }
    uint _S340 = __ldg(&globalParams_0->params_0->cand_index_0);
    uint _S341 = 3U * k_6;
    uint at_2 = _S340 + _S341;
    uint _S342 = __ldg((&(globalParams_0->index_0)[at_2]));
    uint _S343 = __ldg((&(globalParams_0->index_0)[at_2 + 2U]));
    Impactor_0 * _S344 = (&(globalParams_0->impactors_0)[_S343]);
    Impactor_0 imp_4 = *_S344;
    if(((*_S344).cand_0.z) == 0U)
    {
        _S339 = (imp_4.crush_1.x) > 0.0f;
    }
    else
    {
        _S339 = false;
    }
    float total_0;
    float ksum_0;
    if(_S339)
    {
        WorldPoint_0 _S345 = impactor_point_0(_S343);
        WorldPoint_0 _S346 = chunk_world_0(_S342);
        WorldPoint_0 _S347 = _S345;
        float3  _S348 = world_diff_0(&_S346, &_S347);
        float _S349 = length_0(_S348);
        float _S350 = imp_4.half_1.w;
        float4  _S351 = __ldg(&(&(globalParams_0->chunks_0)[_S342])->half_0);
        if(!(_S349 > (_S350 + _S351.w)))
        {
            float4  _S352 = imp_4.half_1;
            Box_0 _S353 = impactor_box_1(_S343, make_float3 (0.0f), float3 {_S352.x, _S352.y, _S352.z});
            Box_0 b_20 = chunk_box_0(_S342, _S348);
            float _S354 = imp_4.mat_0.x;
            float4  _S355 = __ldg(&(&(globalParams_0->chunks_0)[_S342])->cmat_0);
            float _S356 = _S355.x;
            float3  _S357 = b_20.center_1 - _S353.center_1;
            Box_0 _S358 = _S353;
            Box_0 _S359 = b_20;
            float _S360 = contact_stiffness_0(_S354, &_S358, _S356, &_S359, _S357);
            float _S361 = imp_4.crush_1.w;
            Box_0 _S362 = _S353;
            Box_0 _S363 = impactor_shrunk_0(_S343, _S361, &_S362);
            Box_0 _S364 = _S363;
            Box_0 _S365 = b_20;
            uint _S366 = impactor_contact_count_0(_S343, _S361, &_S364, &_S365);
            float _S367;
            if((imp_4.shape_0.x) == 0.0f)
            {
                _S367 = _S360;
            }
            else
            {
                _S367 = _S360 / (F32_max((float(_S366)), (10.0f)));
            }
            uint j_3 = 0U;
            total_0 = 0.0f;
            ksum_0 = 0.0f;
            for(;;)
            {
                if(_S366 > 0U)
                {
                    Impactor_0 _S368 = imp_4;
                    Box_0 _S369 = b_20;
                    uint _S370 = impactor_slots_0(&_S368, &_S369);
                    _S339 = j_3 < _S370;
                }
                else
                {
                    _S339 = false;
                }
                if(_S339)
                {
                }
                else
                {
                    break;
                }
                Impactor_0 _S371 = imp_4;
                Box_0 _S372 = _S363;
                Box_0 _S373 = b_20;
                float3  p_7;
                float3  nrm_1;
                float dep_1;
                bool _S374 = impactor_contact_0(&_S371, _S361, &_S372, &_S373, j_3, &p_7, &nrm_1, &dep_1);
                if(!_S374)
                {
                    j_3 = j_3 + 1U;
                    continue;
                }
                float ksum_1 = ksum_0 + _S367;
                total_0 = total_0 + _S367 * dep_1;
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
    uint _S375 = __ldg(&globalParams_0->params_0->cand_base_0);
    float4  data_1 = *(&(globalParams_0->scratch_0)[_S375 + _S341]);
    uint _S376 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S376 + _S341]) = make_float4 (total_0, ksum_0, data_1.z, data_1.w);
    return;
}

extern "C" __global__ void impactor_crush()
{
    uint _S377;
    uint _S378 = __ballot_sync(4294967295U, true);
    uint ii_0 = blockIdx.x;
    uint tid_2 = threadIdx.x;
    uint _S379 = __ldg(&globalParams_0->params_0->impactor_count_0);
    bool _S380 = ii_0 >= _S379;
    uint _S381 = __ballot_sync(_S378, _S380);
    bool _S382;
    uint k_7;
    if(_S380)
    {
        uint _S383 = __ballot_sync(_S378, true);
        _S382 = true;
        k_7 = _S383;
    }
    else
    {
        bool _S384 = stopped_0();
        uint _S385 = __ballot_sync(_S378, true);
        _S382 = _S384;
        k_7 = _S385;
    }
    uint _S386 = 0U;
    uint _S387 = __ballot_sync(k_7, _S382);
    if(_S382)
    {
        return;
    }
    else
    {
        uint _S388 = __ballot_sync(k_7, true);
        _S386 = _S388;
    }
    Impactor_0 imp_5 = *(&(globalParams_0->impactors_0)[ii_0]);
    float4  _S389 = make_float4 (0.0f);
    float4  shares_0 = _S389;
    float4  unused_0 = _S389;
    k_7 = (&imp_5)->cand_0.x + tid_2;
    uint _S390;
    _S390 = _S386;
    for(;;)
    {
        bool _S391 = k_7 < ((&imp_5)->cand_0.y);
        uint _S392 = __ballot_sync(_S390, _S391);
        if(_S391)
        {
            uint _S393 = __ballot_sync(_S390, true);
        }
        else
        {
            uint _S394 = __ballot_sync(_S390, false);
            uint _S395 = __ballot_sync(_S390, false);
            uint _S396 = __ballot_sync(_S386, true);
            _S377 = _S396;
            break;
        }
        uint _S397 = __ldg(&globalParams_0->params_0->cand_base_0);
        shares_0 = shares_0 + *(&(globalParams_0->scratch_0)[_S397 + 3U * k_7]);
        uint _S398 = __ballot_sync(_S390, true);
        k_7 = k_7 + 256U;
        _S390 = _S398;
    }
    group_sum2_0(tid_2, &shares_0, &unused_0, _S377);
    bool _S399 = tid_2 != 0U;
    uint _S400 = __ballot_sync(_S377, _S399);
    if(_S399)
    {
        _S382 = true;
    }
    else
    {
        _S382 = ((&imp_5)->cand_0.z) != 0U;
    }
    if(_S382)
    {
        return;
    }
    (&imp_5)->geom_0 = make_float4 (1.0f, (&imp_5)->crush_1.w, 0.0f, 0.0f);
    float total_1 = shares_0.x;
    if(((&imp_5)->crush_1.x) > 0.0f)
    {
        _S382 = ((&imp_5)->crush_1.z) < ((&imp_5)->crush_1.y);
    }
    else
    {
        _S382 = false;
    }
    if(_S382)
    {
        _S382 = total_1 > ((&imp_5)->crush_1.x);
    }
    else
    {
        _S382 = false;
    }
    if(_S382)
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

static __device__ void comp_add_0(float3  * sum_1, float3  * err_1, float3  x_14)
{
    float3  t_2 = *sum_1 + x_14;
    float3  _S401 = abs_1(x_14);
    *err_1 = *err_1 + (_slang_select((abs_1(*sum_1)) >= _S401, *sum_1,x_14) - t_2 + _slang_select((abs_1(*sum_1)) >= _S401, x_14,*sum_1));
    *sum_1 = t_2;
    return;
}

static __device__ float3  inverse_rotate_0(Quat_0 * q_9, float3  v_4)
{
    Quat_0 c_5;
    (&c_5)->w_1 = q_9->w_1;
    (&c_5)->x_11 = - q_9->x_11;
    (&c_5)->y_4 = - q_9->y_4;
    (&c_5)->z_0 = - q_9->z_0;
    Quat_0 _S402 = c_5;
    float3  _S403 = rotate_0(&_S402, v_4);
    return _S403;
}

static __device__ float3  rows_mul_0(float4  r0_0, float4  r1_0, float4  r2_0, float3  v_5)
{
    return make_float3 (dot_0(float3 {r0_0.x, r0_0.y, r0_0.z}, v_5), dot_0(float3 {r1_0.x, r1_0.y, r1_0.z}, v_5), dot_0(float3 {r2_0.x, r2_0.y, r2_0.z}, v_5));
}

static __device__ float3  world_mul_0(Quat_0 * q_10, float4  r0_1, float4  r1_1, float4  r2_1, float3  v_6)
{
    float3  _S404 = inverse_rotate_0(q_10, v_6);
    float3  _S405 = rotate_0(q_10, rows_mul_0(r0_1, r1_1, r2_1, _S404));
    return _S405;
}

static __device__ float4  turn_minus_one_0(float3  axis_3, float angle_1)
{
    float s_1 = (F32_sin((0.25f * angle_1)));
    return make_float4 ((axis_3 * make_float3 ((F32_sin((0.5f * angle_1))))).x, (axis_3 * make_float3 ((F32_sin((0.5f * angle_1))))).y, (axis_3 * make_float3 ((F32_sin((0.5f * angle_1))))).z, -2.0f * s_1 * s_1);
}

static __device__ Quat_0 quat_mul_0(Quat_0 * a_6, Quat_0 * o_0)
{
    Quat_0 r_4;
    (&r_4)->w_1 = a_6->w_1 * o_0->w_1 - a_6->x_11 * o_0->x_11 - a_6->y_4 * o_0->y_4 - a_6->z_0 * o_0->z_0;
    (&r_4)->x_11 = a_6->w_1 * o_0->x_11 + a_6->x_11 * o_0->w_1 + a_6->y_4 * o_0->z_0 - a_6->z_0 * o_0->y_4;
    (&r_4)->y_4 = a_6->w_1 * o_0->y_4 - a_6->x_11 * o_0->z_0 + a_6->y_4 * o_0->w_1 + a_6->z_0 * o_0->x_11;
    (&r_4)->z_0 = a_6->w_1 * o_0->z_0 + a_6->x_11 * o_0->y_4 - a_6->y_4 * o_0->x_11 + a_6->z_0 * o_0->w_1;
    return r_4;
}

static __device__ float4  quat_vec_0(Quat_0 * q_11)
{
    return make_float4 (q_11->x_11, q_11->y_4, q_11->z_0, q_11->w_1);
}

static __device__ void comp_add4_0(float4  * sum_2, float4  * err_2, float4  x_15)
{
    float4  t_3 = *sum_2 + x_15;
    float4  _S406 = abs_0(x_15);
    *err_2 = *err_2 + (_slang_select((abs_0(*sum_2)) >= _S406, *sum_2,x_15) - t_3 + _slang_select((abs_0(*sum_2)) >= _S406, x_15,*sum_2));
    *sum_2 = t_3;
    return;
}

static __device__ void quat_accumulate_0(Quat_0 * hi_1, float4  * lo_1, float4  x_16)
{
    Quat_0 _S407 = *hi_1;
    float4  _S408 = quat_vec_0(&_S407);
    float4  sum_3 = _S408;
    comp_add4_0(&sum_3, lo_1, x_16);
    float4  t_4 = sum_3 + *lo_1;
    *lo_1 = *lo_1 - (t_4 - sum_3);
    *hi_1 = quat_of_0(t_4);
    return;
}

static __device__ void turn_left_0(Quat_0 * hi_2, float4  * lo_2, float3  omega_0, float dt_2)
{
    float _S409 = length_0(omega_0);
    float angle_2 = _S409 * dt_2;
    if(angle_2 < 1.00000000317107685e-30f)
    {
        return;
    }
    float4  d_10 = turn_minus_one_0(omega_0 / make_float3 (_S409), angle_2);
    Quat_0 dq_0;
    (&dq_0)->x_11 = d_10.x;
    (&dq_0)->y_4 = d_10.y;
    (&dq_0)->z_0 = d_10.z;
    (&dq_0)->w_1 = d_10.w;
    Quat_0 _S410 = dq_0;
    Quat_0 _S411 = *hi_2;
    Quat_0 _S412 = quat_mul_0(&_S410, &_S411);
    Quat_0 _S413 = _S412;
    float4  _S414 = quat_vec_0(&_S413);
    quat_accumulate_0(hi_2, lo_2, _S414);
    return;
}

extern "C" __global__ void impactor_integrate()
{
    uint _S415 = 0U;
    uint _S416;
    float3  p_8;
    uint _S417 = __ballot_sync(4294967295U, true);
    uint ii_1 = blockIdx.x;
    uint tid_3 = threadIdx.x;
    uint _S418 = __ldg(&globalParams_0->params_0->impactor_count_0);
    bool _S419 = ii_1 >= _S418;
    uint _S420 = __ballot_sync(_S417, _S419);
    if(_S419)
    {
        return;
    }
    else
    {
        uint _S421 = __ballot_sync(_S417, true);
        _S415 = _S421;
    }
    uint _S422 = __ldg(&globalParams_0->params_0->halt_index_0);
    Island_0 * _S423 = (&(globalParams_0->islands_0)[_S422]);
    Impactor_0 imp_6 = *(&(globalParams_0->impactors_0)[ii_1]);
    bool _S424 = ((&imp_6)->cand_0.z) != 0U;
    uint _S425 = __ballot_sync(_S415, _S424);
    bool _S426;
    uint k_8;
    if(_S424)
    {
        uint _S427 = __ballot_sync(_S415, true);
        _S426 = true;
        k_8 = _S427;
    }
    else
    {
        bool _S428 = ((_S423->info_1.z) & 1U) != 0U;
        uint _S429 = __ballot_sync(_S415, true);
        _S426 = _S428;
        k_8 = _S429;
    }
    uint _S430 = __ballot_sync(k_8, _S426);
    if(_S426)
    {
        uint _S431 = __ballot_sync(k_8, true);
        _S426 = true;
        k_8 = _S431;
    }
    else
    {
        uint _S432 = k_8 & (~_S430);
        uint _S433 = _S423->info_1.y;
        bool _S434 = _S433 != 0U;
        uint _S435 = __ballot_sync(_S432, _S434);
        if(_S434)
        {
            bool _S436 = ((&imp_6)->cand_0.w) >= _S433;
            uint _S437 = __ballot_sync(_S432, true);
            _S426 = _S436;
        }
        else
        {
            uint _S438 = __ballot_sync(_S432, true);
            _S426 = false;
        }
        uint _S439 = __ballot_sync(k_8, true);
        k_8 = _S439;
    }
    uint _S440 = 0U;
    uint _S441 = __ballot_sync(k_8, _S426);
    if(_S426)
    {
        return;
    }
    else
    {
        uint _S442 = __ballot_sync(k_8, true);
        _S440 = _S442;
    }
    float4  _S443 = make_float4 (0.0f);
    float4  rf_0 = _S443;
    float4  rt_0 = _S443;
    k_8 = (&imp_6)->cand_0.x + tid_3;
    uint total_points_0;
    total_points_0 = _S440;
    for(;;)
    {
        bool _S444 = k_8 < ((&imp_6)->cand_0.y);
        uint _S445 = __ballot_sync(total_points_0, _S444);
        if(_S444)
        {
            uint _S446 = __ballot_sync(total_points_0, true);
        }
        else
        {
            uint _S447 = __ballot_sync(total_points_0, false);
            uint _S448 = __ballot_sync(total_points_0, false);
            uint _S449 = __ballot_sync(_S440, true);
            _S416 = _S449;
            break;
        }
        uint _S450 = __ldg(&globalParams_0->params_0->cand_base_0);
        uint _S451 = 3U * k_8;
        rf_0 = rf_0 + *(&(globalParams_0->scratch_0)[_S450 + _S451 + 1U]);
        uint _S452 = __ldg(&globalParams_0->params_0->cand_base_0);
        rt_0 = rt_0 + *(&(globalParams_0->scratch_0)[_S452 + _S451 + 2U]);
        uint _S453 = __ballot_sync(total_points_0, true);
        k_8 = k_8 + 256U;
        total_points_0 = _S453;
    }
    group_sum2_0(tid_3, &rf_0, &rt_0, _S416);
    bool _S454 = tid_3 != 0U;
    uint _S455 = __ballot_sync(_S416, _S454);
    if(_S454)
    {
        return;
    }
    float _S456 = __ldg(&globalParams_0->params_0->dt_0);
    float3  _S457 = make_float3 (0.0f);
    uint _S458 = __ldg(&globalParams_0->params_0->has_ground_0);
    float3  load_f_0;
    float3  load_t_0;
    if(_S458 != 0U)
    {
        float4  _S459 = (&imp_6)->half_1;
        float3  _S460 = float3 {_S459.x, _S459.y, _S459.z};
        Impactor_0 _S461 = imp_6;
        Box_0 _S462 = impactor_box_0(&_S461, _S457, _S460);
        float4  _S463 = (&imp_6)->velocity_1;
        float4  _S464 = (&imp_6)->velocity_err_1;
        float3  _S465 = float3 {_S463.x, _S463.y, _S463.z} + float3 {_S464.x, _S464.y, _S464.z};
        float _S466 = __ldg(&globalParams_0->params_0->ground_modulus_0);
        float _S467 = (&imp_6)->mat_0.x;
        float3  _S468 = make_float3 (0.0f, 0.0f, 1.0f);
        Box_0 _S469 = _S462;
        Box_0 _S470 = _S462;
        float _S471 = contact_stiffness_0(_S466, &_S469, _S467, &_S470, _S468);
        float _S472 = (&imp_6)->position_1.z;
        float _S473 = __ldg(&globalParams_0->params_0->ground_hi_0);
        float _S474 = _S472 - _S473;
        float _S475 = (&imp_6)->position_err_1.z;
        float _S476 = __ldg(&globalParams_0->params_0->ground_lo_0);
        float _S477 = _S474 + (_S475 - _S476);
        if(((&imp_6)->shape_0.x) == 0.0f)
        {
            total_points_0 = 1U;
        }
        else
        {
            total_points_0 = 14U;
        }
        float _S478 = _S471 / float((U32_min((total_points_0), (5U))));
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
                Box_0 _S479 = _S462;
                float3  _S480 = sample_point_0(&_S479, s_2);
                p_8 = _S480;
            }
            if((_S477 + p_8.z) < 0.0f)
            {
                below_0 = below_0 + 1U;
            }
            s_2 = s_2 + 1U;
        }
        if(below_0 > 0U)
        {
            sentinel_mark_0(8U);
        }
        s_2 = 0U;
        load_f_0 = _S457;
        load_t_0 = _S457;
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
                Box_0 _S481 = _S462;
                float3  _S482 = sample_point_0(&_S481, s_2);
                p_8 = _S482;
            }
            float depth_3 = - (_S477 + p_8.z);
            if(depth_3 <= 0.0f)
            {
                s_2 = s_2 + 1U;
                continue;
            }
            float4  _S483 = (&imp_6)->angular_velocity_1;
            float3  v_7 = _S465 + cross_0(float3 {_S483.x, _S483.y, _S483.z}, p_8);
            float _S484 = (&imp_6)->mat_0.z;
            float _S485 = __ldg(&globalParams_0->params_0->ground_friction_0);
            float stored_3;
            float diss_2;
            float3  f_3 = penalty_force_0(_S478, _S484, _S485, depth_3, _S468, v_7, _S456, below_0, &stored_3, &diss_2);
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
        load_f_0 = _S457;
        load_t_0 = _S457;
    }
    float4  _S486 = rf_0;
    float3  load_f_2 = float3 {_S486.x, _S486.y, _S486.z} + load_f_0;
    float4  _S487 = rt_0;
    float3  load_t_2 = float3 {_S487.x, _S487.y, _S487.z} + load_t_0;
    float m_2 = (&imp_6)->mat_0.z;
    float4  _S488 = (&imp_6)->velocity_1;
    float3  vel_0 = float3 {_S488.x, _S488.y, _S488.z};
    float4  _S489 = (&imp_6)->velocity_err_1;
    float3  vel_err_0 = float3 {_S489.x, _S489.y, _S489.z};
    float3  _S490 = load_f_2 / make_float3 (m_2);
    float4  _S491 = __ldg(&globalParams_0->params_0->gravity_0);
    comp_add_0(&vel_0, &vel_err_0, (_S490 + float3 {_S491.x, _S491.y, _S491.z}) * make_float3 (_S456));
    Quat_0 _S492 = quat_of_0((&imp_6)->rotation_1);
    Quat_0 q_12 = _S492;
    float4  q_err_0 = (&imp_6)->rotation_err_1;
    float4  _S493 = (&imp_6)->momentum_1;
    float3  l_hi_0 = float3 {_S493.x, _S493.y, _S493.z};
    float4  _S494 = (&imp_6)->momentum_err_1;
    float3  l_err_0 = float3 {_S494.x, _S494.y, _S494.z};
    comp_add_0(&l_hi_0, &l_err_0, load_t_2 * make_float3 (_S456));
    float3  l_1 = l_hi_0 + l_err_0;
    Quat_0 _S495 = _S492;
    float3  _S496 = world_mul_0(&_S495, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    float4  _S497 = (&imp_6)->position_1;
    float3  pos_0 = float3 {_S497.x, _S497.y, _S497.z};
    float4  _S498 = (&imp_6)->position_err_1;
    float3  pos_err_0 = float3 {_S498.x, _S498.y, _S498.z};
    comp_add_0(&pos_0, &pos_err_0, (vel_0 + vel_err_0) * make_float3 (_S456));
    turn_left_0(&q_12, &q_err_0, _S496, _S456);
    Quat_0 _S499 = q_12;
    float3  _S500 = world_mul_0(&_S499, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    (&imp_6)->angular_velocity_1 = make_float4 (_S500.x, _S500.y, _S500.z, 0.0f);
    Quat_0 _S501 = q_12;
    float4  _S502 = quat_vec_0(&_S501);
    (&imp_6)->rotation_1 = _S502;
    (&imp_6)->rotation_err_1 = q_err_0;
    (&imp_6)->momentum_1 = make_float4 (l_hi_0.x, l_hi_0.y, l_hi_0.z, 0.0f);
    (&imp_6)->momentum_err_1 = make_float4 (l_err_0.x, l_err_0.y, l_err_0.z, 0.0f);
    (&imp_6)->position_1 = make_float4 (pos_0.x, pos_0.y, pos_0.z, 0.0f);
    (&imp_6)->position_err_1 = make_float4 (pos_err_0.x, pos_err_0.y, pos_err_0.z, 0.0f);
    (&imp_6)->velocity_1 = make_float4 (vel_0.x, vel_0.y, vel_0.z, 0.0f);
    (&imp_6)->velocity_err_1 = make_float4 (vel_err_0.x, vel_err_0.y, vel_err_0.z, 0.0f);
    *&((&(&imp_6)->cand_0)->w) = *&((&(&imp_6)->cand_0)->w) + 1U;
    (&imp_6)->geom_0 = make_float4 (1.0f, (&imp_6)->crush_1.w, 0.0f, 0.0f);
    *(&(globalParams_0->impactors_0)[ii_1]) = imp_6;
    uint _S503 = (&imp_6)->cand_0.w - 1U;
    uint _S504 = __ldg(&globalParams_0->params_0->step_start_0);
    uint k_9 = _S503 - _S504;
    uint _S505 = __ldg(&globalParams_0->params_0->record_stride_0);
    if(k_9 < _S505)
    {
        uint _S506 = __ldg(&globalParams_0->params_0->record_base_0);
        uint _S507 = __ldg(&globalParams_0->params_0->record_stride_0);
        uint at_3 = _S506 + 2U * (ii_1 * _S507 + k_9);
        *(&(globalParams_0->scratch_0)[at_3]) = make_float4 ((vel_0 + vel_err_0).x, (vel_0 + vel_err_0).y, (vel_0 + vel_err_0).z, 0.0f);
        *(&(globalParams_0->scratch_0)[at_3 + 1U]) = make_float4 ((pos_0 + pos_err_0).x, (pos_0 + pos_err_0).y, (pos_0 + pos_err_0).z, 0.0f);
    }
    return;
}

static __device__ void ground_contact_0(uint c_6, bool account_0, float3  * f_4, float3  * t_5)
{
    ChunkStatic_0 * _S508 = (&(globalParams_0->chunks_0)[c_6]);
    WorldPoint_0 wp_1 = chunk_world_0(c_6);
    float _S509 = wp_1.hi_0.z;
    float _S510 = __ldg(&globalParams_0->params_0->ground_hi_0);
    float _S511 = _S509 - _S510;
    float _S512 = wp_1.lo_0.z;
    float _S513 = __ldg(&globalParams_0->params_0->ground_lo_0);
    float above_0 = _S511 + (_S512 - _S513) + wp_1.rel_0.z;
    float4  _S514 = __ldg(&_S508->half_0);
    if((above_0 - _S514.w) > 0.0f)
    {
        return;
    }
    Box_0 b_21 = chunk_box_0(c_6, make_float3 (0.0f));
    float _S515 = __ldg(&globalParams_0->params_0->ground_modulus_0);
    float4  _S516 = __ldg(&_S508->cmat_0);
    float _S517 = _S516.x;
    float3  _S518 = make_float3 (0.0f, 0.0f, 1.0f);
    Box_0 _S519 = b_21;
    Box_0 _S520 = b_21;
    float _S521 = contact_stiffness_0(_S515, &_S519, _S517, &_S520, _S518);
    Box_0 _S522 = b_21;
    uint _S523 = sample_count_0(&_S522);
    uint s_3 = 0U;
    uint n_7 = 0U;
    for(;;)
    {
        if(s_3 < _S523)
        {
        }
        else
        {
            break;
        }
        Box_0 _S524 = b_21;
        float3  _S525 = sample_point_0(&_S524, s_3);
        if((above_0 + _S525.z) < 0.0f)
        {
            n_7 = n_7 + 1U;
        }
        s_3 = s_3 + 1U;
    }
    if(n_7 == 0U)
    {
        return;
    }
    sentinel_mark_0(4U);
    float3  vc_1;
    float3  wc_1;
    chunk_velocity_0(c_6, &vc_1, &wc_1);
    uint _S526 = __ldg(&globalParams_0->params_0->ledger_base_0);
    uint _S527 = __ldg(&globalParams_0->params_0->pair_count_0);
    float4  ledger_2 = *(&(globalParams_0->scratch_0)[_S526 + _S527 + c_6]);
    s_3 = 0U;
    for(;;)
    {
        if(s_3 < _S523)
        {
        }
        else
        {
            break;
        }
        Box_0 _S528 = b_21;
        float3  _S529 = sample_point_0(&_S528, s_3);
        float _S530 = above_0 + _S529.z;
        if(!(_S530 < 0.0f))
        {
            s_3 = s_3 + 1U;
            continue;
        }
        float depth_4 = - _S530;
        float3  v_8 = vc_1 + cross_0(wc_1, _S529);
        float _S531 = _S521 / float((U32_max((n_7), (5U))));
        float4  _S532 = __ldg(&_S508->center_0);
        float _S533 = _S532.w;
        float _S534 = __ldg(&globalParams_0->params_0->ground_friction_0);
        float _S535 = __ldg(&globalParams_0->params_0->dt_0);
        float stored_4;
        float diss_3;
        float3  g_0 = penalty_force_0(_S531, _S533, _S534, depth_4, _S518, v_8, _S535, n_7, &stored_4, &diss_3);
        *f_4 = *f_4 + g_0;
        *t_5 = *t_5 + cross_0(_S529, g_0);
        comp_add1_0(&((&ledger_2)->y), &((&ledger_2)->z), diss_3);
        s_3 = s_3 + 1U;
    }
    if(account_0)
    {
        uint _S536 = __ldg(&globalParams_0->params_0->ledger_base_0);
        uint _S537 = __ldg(&globalParams_0->params_0->pair_count_0);
        *(&(globalParams_0->scratch_0)[_S536 + _S537 + c_6]) = ledger_2;
    }
    return;
}

extern "C" __global__ void contact_sums()
{
    uint g_1 = (blockIdx * blockDim + threadIdx).x;
    uint _S538 = __ldg(&globalParams_0->params_0->seg_count_0);
    bool _S539;
    if(g_1 >= _S538)
    {
        _S539 = true;
    }
    else
    {
        _S539 = stopped_0();
    }
    if(_S539)
    {
        return;
    }
    uint _S540 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S541 = 3U * g_1;
    uint _S542 = __ldg((&(globalParams_0->index_0)[_S540 + _S541]));
    uint _S543 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S544 = __ldg((&(globalParams_0->index_0)[_S543 + _S541 + 1U]));
    uint _S545 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S546 = __ldg((&(globalParams_0->index_0)[_S545 + _S541 + 2U]));
    float3  _S547 = make_float3 (0.0f);
    float3  f_5 = _S547;
    float3  t_6 = _S547;
    uint e_2 = _S544;
    for(;;)
    {
        if(e_2 < _S546)
        {
        }
        else
        {
            break;
        }
        uint _S548 = __ldg((&(globalParams_0->index_0)[e_2]));
        if(_S548 == 2147483648U)
        {
            ground_contact_0(_S542, true, &f_5, &t_6);
            e_2 = e_2 + 1U;
            continue;
        }
        uint _S549 = __ldg(&globalParams_0->params_0->slot_base_0);
        uint _S550 = 2U * _S548;
        float4  _S551 = *(&(globalParams_0->scratch_0)[_S549 + _S550]);
        f_5 = f_5 + float3 {_S551.x, _S551.y, _S551.z};
        uint _S552 = __ldg(&globalParams_0->params_0->slot_base_0);
        float4  _S553 = *(&(globalParams_0->scratch_0)[_S552 + _S550 + 1U]);
        t_6 = t_6 + float3 {_S553.x, _S553.y, _S553.z};
        e_2 = e_2 + 1U;
    }
    uint _S554 = __ldg(&globalParams_0->params_0->seg_base_0);
    uint _S555 = 2U * g_1;
    *(&(globalParams_0->scratch_0)[_S554 + _S555]) = make_float4 (f_5.x, f_5.y, f_5.z, 0.0f);
    uint _S556 = __ldg(&globalParams_0->params_0->seg_base_0);
    *(&(globalParams_0->scratch_0)[_S556 + _S555 + 1U]) = make_float4 (t_6.x, t_6.y, t_6.z, 0.0f);
    return;
}

__device__ __shared__ FixedArray<uint, 5>  g_seen_0;

static __device__ void seen_clear_0(uint tid_4)
{
    if(tid_4 < 5U)
    {
        (*&g_seen_0)[tid_4] = 0U;
    }
    return;
}

static __device__ bool contact_stopped_0(Island_0 * isl_0)
{
    uint _S557 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint4  _S558 = (&(globalParams_0->islands_0)[_S557])->info_1;
    bool _S559;
    if((((&(globalParams_0->islands_0)[_S557])->info_1.z) & 1U) != 0U)
    {
        _S559 = true;
    }
    else
    {
        uint _S560 = _S558.y;
        if(_S560 != 0U)
        {
            _S559 = _S560 <= (isl_0->info_1.w);
        }
        else
        {
            _S559 = false;
        }
    }
    return _S559;
}

__device__ __shared__ uint g_run_0;

__device__ __shared__ uint g_halt_0;

struct Rigid_0
{
    Quat_0 rot_0;
    float4  rot_err_0;
    float3  pos_1;
    float3  pos_err_1;
    float3  vel_1;
    float3  vel_err_1;
    float3  w_4;
    float3  l_2;
    float3  l_err_1;
    float3  torque_0;
    float3  a_7;
    float3  alpha_0;
};

static __device__ Rigid_0 rigid_of_0(Island_0 * isl_1)
{
    Rigid_0 rg_0;
    (&rg_0)->rot_0 = quat_of_0(isl_1->rotation_0);
    (&rg_0)->rot_err_0 = isl_1->rotation_err_0;
    float4  _S561 = isl_1->position_0;
    (&rg_0)->pos_1 = float3 {_S561.x, _S561.y, _S561.z};
    float4  _S562 = isl_1->position_err_0;
    (&rg_0)->pos_err_1 = float3 {_S562.x, _S562.y, _S562.z};
    float4  _S563 = isl_1->velocity_0;
    (&rg_0)->vel_1 = float3 {_S563.x, _S563.y, _S563.z};
    float4  _S564 = isl_1->velocity_err_0;
    (&rg_0)->vel_err_1 = float3 {_S564.x, _S564.y, _S564.z};
    float4  _S565 = isl_1->angular_velocity_0;
    (&rg_0)->w_4 = float3 {_S565.x, _S565.y, _S565.z};
    float4  _S566 = isl_1->momentum_0;
    (&rg_0)->l_2 = float3 {_S566.x, _S566.y, _S566.z};
    float4  _S567 = isl_1->momentum_err_0;
    (&rg_0)->l_err_1 = float3 {_S567.x, _S567.y, _S567.z};
    float3  _S568 = make_float3 (0.0f);
    (&rg_0)->torque_0 = _S568;
    (&rg_0)->a_7 = _S568;
    (&rg_0)->alpha_0 = _S568;
    return rg_0;
}

static __device__ void write_probe_0(uint slot_0, uint k_10, float value_0)
{
    uint _S569 = __ldg(&globalParams_0->params_0->probe_base_0);
    uint _S570 = _S569 * 4U;
    uint _S571 = __ldg(&globalParams_0->params_0->probe_stride_0);
    uint at_4 = _S570 + slot_0 * _S571 + k_10;
    float4  v_9 = *(&(globalParams_0->scratch_0)[at_4 / 4U]);
    *_slang_vector_get_element_ptr(&v_9, at_4 % 4U) = value_0;
    *(&(globalParams_0->scratch_0)[at_4 / 4U]) = v_9;
    return;
}

static __device__ void record_probes_0(Island_0 * isl_2, Rigid_0 * rg_1, uint k_11)
{
    uint4  _S572 = isl_2->probes_0;
    uint at_5 = isl_2->probes_0.x;
    for(;;)
    {
        if(at_5 < (_S572.y))
        {
        }
        else
        {
            break;
        }
        float4  _S573 = __ldg((&(globalParams_0->loads_0)[at_5]));
        uint4  info_2 = asuint_0(_S573);
        float4  _S574 = __ldg((&(globalParams_0->loads_0)[at_5 + 1U]));
        float4  _S575 = __ldg((&(globalParams_0->loads_0)[at_5 + 2U]));
        float4  _S576 = __ldg((&(globalParams_0->loads_0)[at_5 + 3U]));
        uint kind_0 = info_2.x;
        uint i_10 = info_2.y;
        float value_1;
        if(kind_0 == 0U)
        {
            float3  _S577 = rg_1->pos_1 - float3 {_S575.x, _S575.y, _S575.z} + (rg_1->pos_err_1 - float3 {_S576.x, _S576.y, _S576.z});
            float4  _S578 = __ldg(&(&(globalParams_0->chunks_0)[i_10])->center_0);
            float4  _S579 = *(&(globalParams_0->state_0)[4U * i_10]);
            float3  _S580 = rotate_0(&rg_1->rot_0, float3 {_S578.x, _S578.y, _S578.z} + float3 {_S579.x, _S579.y, _S579.z});
            value_1 = dot_0(_S577 + _S580, float3 {_S574.x, _S574.y, _S574.z});
        }
        else
        {
            if(kind_0 == 1U)
            {
                float4  _S581 = __ldg(&(&(globalParams_0->chunks_0)[i_10])->center_0);
                uint _S582 = 4U * i_10;
                float4  _S583 = *(&(globalParams_0->state_0)[_S582]);
                float4  _S584 = isl_2->com_0;
                float3  _S585 = rotate_0(&rg_1->rot_0, float3 {_S581.x, _S581.y, _S581.z} + float3 {_S583.x, _S583.y, _S583.z} - float3 {_S584.x, _S584.y, _S584.z});
                float3  _S586 = rg_1->vel_1 + rg_1->vel_err_1 + cross_0(rg_1->w_4, _S585);
                float4  _S587 = *(&(globalParams_0->state_0)[_S582 + 2U]);
                float3  _S588 = rotate_0(&rg_1->rot_0, float3 {_S587.x, _S587.y, _S587.z});
                value_1 = dot_0(_S586 + _S588, float3 {_S574.x, _S574.y, _S574.z});
            }
            else
            {
                if(kind_0 == 2U)
                {
                    uint _S589 = 3U * i_10;
                    float4  _S590 = *(&(globalParams_0->scratch_0)[_S589]);
                    float3  f_6 = float3 {_S590.x, _S590.y, _S590.z};
                    bool _S591 = (info_2.z) == 0U;
                    float3  mc_0;
                    if(_S591)
                    {
                        float4  _S592 = *(&(globalParams_0->scratch_0)[_S589 + 1U]);
                        mc_0 = float3 {_S592.x, _S592.y, _S592.z};
                    }
                    else
                    {
                        float4  _S593 = *(&(globalParams_0->scratch_0)[_S589 + 2U]);
                        mc_0 = float3 {_S593.x, _S593.y, _S593.z};
                    }
                    float3  fc_0;
                    if(_S591)
                    {
                        fc_0 = f_6;
                    }
                    else
                    {
                        fc_0 = - f_6;
                    }
                    value_1 = dot_0(fc_0, float3 {_S574.x, _S574.y, _S574.z}) + dot_0(mc_0, float3 {_S575.x, _S575.y, _S575.z});
                }
                else
                {
                    uint _S594 = 4U * i_10;
                    float3  _S595 = rotate_0(&rg_1->rot_0, make_float3 ((*(&(globalParams_0->state_0)[_S594 + 1U])).w, (*(&(globalParams_0->state_0)[_S594 + 2U])).w, (*(&(globalParams_0->state_0)[_S594 + 3U])).w));
                    value_1 = dot_0(_S595, float3 {_S574.x, _S574.y, _S574.z});
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
    float _S596 = __ldg(&globalParams_0->params_0->t_hi_0);
    float _S597 = _S596 - origin_0.x;
    float _S598 = __ldg(&globalParams_0->params_0->t_lo_0);
    return _S597 + (_S598 - origin_0.y) + float(k_12) * dt_3;
}

static __device__ float table_eval_0(uint offset_0, uint count_2, float tau_0)
{
    float4  _S599 = __ldg((&(globalParams_0->loads_0)[offset_0]));
    if(tau_0 <= (_S599.x))
    {
        return _S599.y;
    }
    uint i_11 = 1U;
    for(;;)
    {
        if(i_11 < count_2)
        {
        }
        else
        {
            break;
        }
        uint _S600 = offset_0 + i_11;
        float4  _S601 = __ldg((&(globalParams_0->loads_0)[_S600]));
        float _S602 = _S601.x;
        if(tau_0 <= _S602)
        {
            float4  _S603 = __ldg((&(globalParams_0->loads_0)[_S600 - 1U]));
            float _S604 = _S603.x;
            float _S605 = _S603.y;
            return _S605 + (tau_0 - _S604) / (F32_max((_S602 - _S604), (1.00000000317107685e-30f))) * (_S601.y - _S605);
        }
        i_11 = i_11 + 1U;
    }
    float4  _S606 = __ldg((&(globalParams_0->loads_0)[offset_0 + count_2 - 1U]));
    return _S606.y;
}

static __device__ float eval_function_0(uint term_0, uint k_13, float dt_4, float shift_0)
{
    uint _S607 = 5U * term_0;
    float4  _S608 = __ldg((&(globalParams_0->loads_0)[_S607]));
    uint4  info_3 = asuint_0(_S608);
    float4  _S609 = __ldg((&(globalParams_0->loads_0)[_S607 + 3U]));
    float4  _S610 = __ldg((&(globalParams_0->loads_0)[_S607 + 4U]));
    uint kind_1 = info_3.z;
    if(kind_1 == 0U)
    {
        return _S609.z;
    }
    float tau_1 = time_since_0(_S609, k_13, dt_4) + shift_0;
    float shape_1;
    if(kind_1 == 1U)
    {
        if(tau_1 <= 0.0f)
        {
            shape_1 = 0.0f;
        }
        else
        {
            float _S611 = _S610.x;
            if(tau_1 >= _S611)
            {
                shape_1 = _S610.y;
            }
            else
            {
                shape_1 = _S610.y * tau_1 / _S611;
            }
        }
        return shape_1;
    }
    bool _S612;
    if(kind_1 == 2U)
    {
        if(tau_1 < 0.0f)
        {
            _S612 = true;
        }
        else
        {
            _S612 = tau_1 > (_S610.x);
        }
        if(_S612)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S610.y * (F32_sin((3.14159274101257324f * tau_1 / _S610.x)));
        }
        return shape_1;
    }
    if(kind_1 == 3U)
    {
        float sn_0 = tau_1 / _S610.y;
        if(sn_0 < 0.0f)
        {
            _S612 = true;
        }
        else
        {
            _S612 = sn_0 > 1.0f;
        }
        if(_S612)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S610.x * (1.0f - sn_0) * (F32_exp((- _S610.z * sn_0)));
        }
        return shape_1;
    }
    if(kind_1 == 4U)
    {
        return table_eval_0(info_3.w, (F32_asuint((_S610.x))), tau_1);
    }
    if(kind_1 == 5U)
    {
        (*&g_seen_0)[1U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float sn_1 = tau_1 / _S610.x;
        if(sn_1 < 0.0f)
        {
            _S612 = true;
        }
        else
        {
            _S612 = sn_1 > 1.0f;
        }
        if(_S612)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = (1.0f - sn_1) * (F32_exp((- _S610.y * sn_1)));
        }
        float clearing_0 = _S609.w;
        float relax_0;
        if(clearing_0 > 0.0f)
        {
            relax_0 = (F32_max((1.0f - tau_1 / clearing_0), (0.0f)));
        }
        else
        {
            relax_0 = 0.0f;
        }
        float _S613 = _S610.w;
        return (_S613 + (_S610.z - _S613) * relax_0) * shape_1;
    }
    if(kind_1 == 7U)
    {
        (*&g_seen_0)[2U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float _S614 = _S610.y;
        if(tau_1 < _S614)
        {
            return _S610.x;
        }
        float s_4 = tau_1 - _S614;
        float _S615 = _S610.w;
        if(s_4 > _S615)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S610.z * (F32_sin((3.14159274101257324f * s_4 / _S615)));
        }
        return shape_1;
    }
    float _S616 = _S610.x;
    if(_S616 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp_0(1.0f - tau_1 / _S616, 0.0f, 1.0f);
}

static __device__ void record_chunk_load_0(uint c_7, float3  f_7, float3  t_7)
{
    uint _S617 = __ldg(&globalParams_0->params_0->solve_mode_0);
    if(_S617 == 0U)
    {
        return;
    }
    uint _S618 = __ldg(&globalParams_0->params_0->cload_base_0);
    uint _S619 = 2U * c_7;
    *(&(globalParams_0->scratch_0)[_S618 + _S619]) = make_float4 (f_7.x, f_7.y, f_7.z, 0.0f);
    uint _S620 = __ldg(&globalParams_0->params_0->cload_base_0);
    *(&(globalParams_0->scratch_0)[_S620 + _S619 + 1U]) = make_float4 (t_7.x, t_7.y, t_7.z, 0.0f);
    uint _S621 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  * _S622 = (&(globalParams_0->scratch_0)[_S621 + _S619]);
    uint _S623 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  _S624 = *(&(globalParams_0->scratch_0)[_S623 + _S619]);
    *_S622 = make_float4 ((float3 {_S624.x, _S624.y, _S624.z} + f_7).x, (float3 {_S624.x, _S624.y, _S624.z} + f_7).y, (float3 {_S624.x, _S624.y, _S624.z} + f_7).z, 0.0f);
    uint _S625 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  * _S626 = (&(globalParams_0->scratch_0)[_S625 + _S619 + 1U]);
    uint _S627 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  _S628 = *(&(globalParams_0->scratch_0)[_S627 + _S619 + 1U]);
    *_S626 = make_float4 ((float3 {_S628.x, _S628.y, _S628.z} + t_7).x, (float3 {_S628.x, _S628.y, _S628.z} + t_7).y, (float3 {_S628.x, _S628.y, _S628.z} + t_7).z, 0.0f);
    return;
}

static __device__ void chunk_loads_0(uint _S629, uint _S630, Quat_0 * _S631, uint _S632, float _S633, bool _S634, float _S635, float3  * _S636, float3  * _S637, float3  * _S638, float3  * _S639)
{
    bool _S640;
    ChunkStatic_0 * _S641 = (&(globalParams_0->chunks_0)[_S630]);
    float3  _S642 = make_float3 (0.0f);
    *_S636 = _S642;
    *_S637 = _S642;
    *_S638 = _S642;
    *_S639 = _S642;
    uint4  _S643 = __ldg(&_S641->load_range_0);
    uint term_1 = _S643.x;
    for(;;)
    {
        if(term_1 < (_S643.y))
        {
        }
        else
        {
            break;
        }
        (*&g_seen_0)[0U] = 1U;
        uint _S644 = 5U * term_1;
        float4  _S645 = __ldg((&(globalParams_0->loads_0)[_S644]));
        uint _S646 = asuint_0(_S645).y;
        bool replacement_0 = _S646 == 2U;
        float4  _S647 = __ldg((&(globalParams_0->loads_0)[_S644 + 1U]));
        float4  _S648 = __ldg((&(globalParams_0->loads_0)[_S644 + 2U]));
        float _S649;
        if(replacement_0)
        {
            _S649 = _S635;
        }
        else
        {
            _S649 = 0.0f;
        }
        float value_2 = eval_function_0(term_1, _S632, _S633, _S649);
        if(replacement_0)
        {
            *_S638 = *_S638 + float3 {_S647.x, _S647.y, _S647.z} * make_float3 (value_2);
            *_S639 = *_S639 + float3 {_S648.x, _S648.y, _S648.z} * make_float3 (value_2);
            term_1 = term_1 + 1U;
            continue;
        }
        if(_S646 == 0U)
        {
            _S640 = true;
        }
        else
        {
            _S640 = _S646 == 3U;
        }
        float3  fw_0;
        if(_S640)
        {
            fw_0 = float3 {_S647.x, _S647.y, _S647.z} * make_float3 (value_2);
        }
        else
        {
            float3  _S650 = rotate_0(_S631, float3 {_S647.x, _S647.y, _S647.z});
            fw_0 = _S650 * make_float3 (- value_2 * _S647.w);
        }
        float3  lever_0;
        if(_S646 == 3U)
        {
            float4  _S651 = *(&(globalParams_0->state_0)[4U * _S629]);
            lever_0 = float3 {_S648.x, _S648.y, _S648.z} - float3 {_S651.x, _S651.y, _S651.z};
        }
        else
        {
            lever_0 = float3 {_S648.x, _S648.y, _S648.z};
        }
        *_S636 = *_S636 + fw_0;
        float3  _S652 = rotate_0(_S631, lever_0);
        *_S637 = *_S637 + cross_0(_S652, fw_0);
        term_1 = term_1 + 1U;
    }
    if(_S634)
    {
        uint4  _S653 = __ldg(&_S641->cinfo_0);
        _S640 = (_S653.z) != 0U;
    }
    else
    {
        _S640 = false;
    }
    if(_S640)
    {
        uint4  _S654 = __ldg(&_S641->cinfo_0);
        uint g_2 = _S654.x;
        for(;;)
        {
            if(g_2 < (_S654.y))
            {
            }
            else
            {
                break;
            }
            uint _S655 = __ldg(&globalParams_0->params_0->seg_base_0);
            uint _S656 = 2U * g_2;
            float4  _S657 = *(&(globalParams_0->scratch_0)[_S655 + _S656]);
            *_S636 = *_S636 + float3 {_S657.x, _S657.y, _S657.z};
            uint _S658 = __ldg(&globalParams_0->params_0->seg_base_0);
            float4  _S659 = *(&(globalParams_0->scratch_0)[_S658 + _S656 + 1U]);
            *_S637 = *_S637 + float3 {_S659.x, _S659.y, _S659.z};
            g_2 = g_2 + 1U;
        }
    }
    return;
}

static __device__ void chunk_external_0(uint _S660, uint _S661, Quat_0 * _S662, uint _S663, float _S664, bool _S665, float3  * _S666, float3  * _S667)
{
    float3  rf_1;
    float3  rm_0;
    chunk_loads_0(_S660, _S661, _S662, _S663, _S664, _S665, 0.0f, _S666, _S667, &rf_1, &rm_0);
    return;
}

static __device__ float settled_chunk_load_0(uint c_8, Quat_0 * rot_1, uint k_14, float dt_5, bool contact_0)
{
    float3  f_8;
    float3  t_8;
    chunk_external_0(c_8, c_8, rot_1, k_14, dt_5, contact_0, &f_8, &t_8);
    record_chunk_load_0(c_8, f_8, t_8);
    return length_0(f_8);
}

static __device__ void net_load_0(uint c_9, Island_0 * isl_3, Rigid_0 * rg_2, uint k_15, float dt_6, bool contact_1, float3  * f_9, float3  * t_9)
{
    ChunkStatic_0 * _S668 = (&(globalParams_0->chunks_0)[c_9]);
    float3  fl_0;
    float3  tl_0;
    float3  rep_f_0;
    float3  rep_m_0;
    chunk_loads_0(c_9, c_9, &rg_2->rot_0, k_15, dt_6, contact_1, 0.0f, &fl_0, &tl_0, &rep_f_0, &rep_m_0);
    float3  _S669 = fl_0;
    float4  _S670 = __ldg(&globalParams_0->params_0->gravity_0);
    float3  _S671 = float3 {_S670.x, _S670.y, _S670.z};
    float4  _S672 = __ldg(&_S668->center_0);
    float3  fc_1 = _S669 + _S671 * make_float3 (_S672.w);
    float3  _S673 = float3 {_S672.x, _S672.y, _S672.z};
    float4  _S674 = *(&(globalParams_0->state_0)[4U * c_9]);
    float4  _S675 = isl_3->com_0;
    float3  _S676 = float3 {_S675.x, _S675.y, _S675.z};
    float3  _S677 = rotate_0(&rg_2->rot_0, _S673 + float3 {_S674.x, _S674.y, _S674.z} - _S676);
    *f_9 = *f_9 + fc_1;
    *t_9 = *t_9 + (cross_0(_S677, fc_1) + tl_0);
    uint4  _S678 = __ldg(&_S668->load_range_0);
    if((_S678.y) > (_S678.x))
    {
        float3  _S679 = rotate_0(&rg_2->rot_0, rep_f_0);
        *f_9 = *f_9 + _S679;
        float3  _S680 = rotate_0(&rg_2->rot_0, _S673 - _S676);
        float3  _S681 = cross_0(_S680, _S679);
        float3  _S682 = rotate_0(&rg_2->rot_0, rep_m_0);
        *t_9 = *t_9 + (_S681 + _S682);
    }
    return;
}

static __device__ void rigid_acceleration_0(Island_0 * isl_4, Rigid_0 * rg_3, float3  f_10, float3  t_10)
{
    Quat_0 _S683 = rg_3->rot_0;
    float3  _S684 = world_mul_0(&_S683, isl_4->inertia0_1, isl_4->inertia1_1, isl_4->inertia2_1, rg_3->w_4);
    rg_3->a_7 = f_10 / make_float3 (isl_4->com_0.w);
    float3  _S685 = t_10 - cross_0(rg_3->w_4, _S684);
    Quat_0 _S686 = rg_3->rot_0;
    float3  _S687 = world_mul_0(&_S686, isl_4->inv0_1, isl_4->inv1_1, isl_4->inv2_1, _S685);
    rg_3->alpha_0 = _S687;
    rg_3->torque_0 = t_10;
    return;
}

static __device__ float3  turn_difference_0(float3  omega_1, float dt_7, float3  v_10)
{
    float _S688 = length_0(omega_1);
    float angle_3 = _S688 * dt_7;
    if(angle_3 < 1.00000000317107685e-30f)
    {
        return make_float3 (0.0f);
    }
    float3  a_8 = omega_1 / make_float3 (_S688);
    float s_5 = (F32_sin((0.5f * angle_3)));
    float3  av_0 = cross_0(a_8, v_10);
    return av_0 * make_float3 ((F32_sin((angle_3)))) + cross_0(a_8, av_0) * make_float3 (2.0f * s_5 * s_5);
}

static __device__ void integrate_rigid_0(Island_0 * isl_5, Rigid_0 * rg_4, float dt_8)
{
    comp_add_0(&rg_4->l_2, &rg_4->l_err_1, rg_4->torque_0 * make_float3 (dt_8));
    float3  l_3 = rg_4->l_2 + rg_4->l_err_1;
    comp_add_0(&rg_4->vel_1, &rg_4->vel_err_1, rg_4->a_7 * make_float3 (dt_8));
    float3  vel_2 = rg_4->vel_1 + rg_4->vel_err_1;
    float4  _S689 = isl_5->inv0_1;
    float4  _S690 = isl_5->inv1_1;
    float4  _S691 = isl_5->inv2_1;
    Quat_0 _S692 = rg_4->rot_0;
    float3  _S693 = world_mul_0(&_S692, isl_5->inv0_1, isl_5->inv1_1, isl_5->inv2_1, l_3);
    float3  _S694 = vel_2 * make_float3 (dt_8);
    float4  _S695 = isl_5->com_0;
    float3  _S696 = float3 {_S695.x, _S695.y, _S695.z};
    Quat_0 _S697 = rg_4->rot_0;
    float3  _S698 = rotate_0(&_S697, _S696);
    comp_add_0(&rg_4->pos_1, &rg_4->pos_err_1, _S694 - turn_difference_0(_S693, dt_8, _S698));
    turn_left_0(&rg_4->rot_0, &rg_4->rot_err_0, _S693, dt_8);
    Quat_0 _S699 = rg_4->rot_0;
    float3  _S700 = world_mul_0(&_S699, _S689, _S690, _S691, l_3);
    rg_4->w_4 = _S700;
    return;
}

static __device__ JointBond_0 slang_ldg_0(JointBond_0 * ptr_0)
{
    float4  _S701 = __ldg(&ptr_0->geom0_0);
    float4  _S702 = __ldg(&ptr_0->geom1_0);
    float4  _S703 = __ldg(&ptr_0->stiff0_0);
    float4  _S704 = __ldg(&ptr_0->stiff1_0);
    float4  _S705 = __ldg(&ptr_0->rebar0_0);
    float4  _S706 = __ldg(&ptr_0->rebar1_0);
    uint4  _S707 = __ldg(&ptr_0->ids_0);
    JointBond_0 _S708 = { _S701, _S702, _S703, _S704, _S705, _S706, _S707 };
    return _S708;
}

static __device__ bool is_damaged_0(JointState_0 * st_0)
{
    bool _S709;
    if((st_0->damage_0) > 0.0f)
    {
        _S709 = true;
    }
    else
    {
        _S709 = (st_0->crush_0) > 0.0f;
    }
    return _S709;
}

static __device__ bool connected_0(JointState_0 * st_1, bool has_rebar_0)
{
    bool _S710;
    if((st_1->damage_0) < 1.0f)
    {
        _S710 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S710 = (st_1->rebar_broken_0) == 0.0f;
        }
        else
        {
            _S710 = false;
        }
    }
    return _S710;
}

static __device__ float fdiv_0(float a_9, float b_22)
{
    return a_9 / b_22;
}

static __device__ float fsqrt_0(float a_10)
{
    return (F32_sqrt((a_10)));
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
    float _S711 = q_lin_0.z;
    float axial_0 = fdiv_0(_S711, area_2);
    float bending_0 = fdiv_0((F32_abs((q_ang_0.x))), b_23->geom1_0.x) + fdiv_0((F32_abs((q_ang_0.y))), b_23->geom1_0.y);
    float _S712 = q_lin_0.x;
    float _S713 = q_lin_0.y;
    float shear_1 = fdiv_0(fsqrt_0(_S712 * _S712 + _S713 * _S713), area_2) + fdiv_0((F32_abs((q_ang_0.z))), b_23->geom0_0.w);
    Measures_0 m_3;
    (&m_3)->tension_0 = axial_0 + bending_0;
    (&m_3)->shear_0 = shear_1;
    float _S714 = - axial_0;
    (&m_3)->normal_compression_0 = (F32_max((_S714), (0.0f)));
    (&m_3)->compression_0 = _S714 + bending_0;
    (&m_3)->compressive_force_0 = (F32_max((- _S711), (0.0f)));
    return m_3;
}

static __device__ float expm1_accurate_0(float x_17)
{
    if((F32_abs((x_17))) < 0.00100000004749745f)
    {
        return x_17 * (1.0f + x_17 * (0.5f + x_17 * 0.1666666716337204f));
    }
    return (F32_exp((x_17))) - 1.0f;
}

static __device__ float fpow_0(float a_11, float b_24)
{
    return (F32_pow((a_11), (b_24)));
}

static __device__ float dif_factor_0(JointMaterial_0 * mat_1, float strain_rate_1)
{
    float r_5 = (F32_abs((strain_rate_1)));
    float4  _S715 = mat_1->dif_0;
    float ref_0 = mat_1->dif_0.x;
    if(r_5 <= ref_0)
    {
        return 1.0f;
    }
    float _S716 = _S715.z;
    float f_11;
    if(r_5 <= _S716)
    {
        f_11 = fpow_0(fdiv_0(r_5, ref_0), _S715.y);
    }
    else
    {
        f_11 = fpow_0(fdiv_0(_S716, ref_0), _S715.y) * fpow_0(fdiv_0(r_5, _S716), _S715.w);
    }
    return clamp_0(f_11, 1.0f, mat_1->misc_0.x);
}

static __device__ float fatigue_factor_0(JointMaterial_0 * mat_2, float life_1)
{
    if(((mat_2->kind_flags_0.y) & 64U) == 0U)
    {
        return 1.0f;
    }
    return fpow_0(clamp_0(life_1, 0.0f, 1.0f), fdiv_0(1.0f, mat_2->misc_0.y - 2.0f));
}

static __device__ float infinity_0()
{
    return (U32_asfloat((2139095040U)));
}

static __device__ float4  failure_indices_0(JointMaterial_0 * mat_3, JointBond_0 * b_25, Measures_0 * m_4, float multiplier_0)
{
    float fc_2 = mat_3->strength_0.y * multiplier_0;
    float _S717 = (F32_min((mat_3->strength_0.z * multiplier_0 + mat_3->strength_0.w * m_4->normal_compression_0), (mat_3->energy_0.x * multiplier_0)));
    float4  idx_0;
    *&((&idx_0)->x) = (F32_max((fdiv_0(m_4->tension_0, mat_3->strength_0.x * multiplier_0)), (0.0f)));
    float _S718;
    if(_S717 > 0.0f)
    {
        _S718 = fdiv_0(m_4->shear_0, _S717);
    }
    else
    {
        _S718 = infinity_0();
    }
    *&((&idx_0)->y) = _S718;
    *&((&idx_0)->z) = (F32_max((fdiv_0(m_4->compression_0, fc_2)), (0.0f)));
    float _S719 = b_25->stiff1_0.y;
    if(_S719 > 0.0f)
    {
        _S718 = fdiv_0(m_4->compressive_force_0, _S719);
    }
    else
    {
        _S718 = 0.0f;
    }
    *&((&idx_0)->w) = _S718;
    return idx_0;
}

static __device__ float sq_0(float x_18)
{
    return x_18 * x_18;
}

static __device__ float damage_law_0(uint kind_2, float kappa_1, float r_6)
{
    if(kappa_1 <= 1.0f)
    {
        return 0.0f;
    }
    if(kind_2 == 0U)
    {
        if(r_6 <= 1.0f)
        {
            return 1.0f;
        }
        return (F32_min((fdiv_0(r_6 * (kappa_1 - 1.0f), kappa_1 * (r_6 - 1.0f))), (1.0f)));
    }
    if(kappa_1 >= (0.5f * (r_6 + 1.0f)))
    {
        return 1.0f;
    }
    return 1.0f - fdiv_0(1.0f, kappa_1);
}

static __device__ __noinline__ float2  damage_increment_0(uint kind_3, float kappa_old_0, float lambda_0, float r_7, float d_old_0, float psi_0)
{
    float _S720 = (F32_max((damage_law_0(kind_3, lambda_0, r_7)), (d_old_0)));
    bool _S721;
    if(_S720 <= d_old_0)
    {
        _S721 = true;
    }
    else
    {
        _S721 = d_old_0 >= 1.0f;
    }
    if(_S721)
    {
        return make_float2 (d_old_0, 0.0f);
    }
    float u0_0 = fdiv_0(psi_0, lambda_0 * lambda_0);
    float _S722 = (F32_max((kappa_old_0), (1.0f)));
    if(kind_3 == 0U)
    {
        if(r_7 > 1.0f)
        {
            return make_float2 (_S720, fdiv_0(u0_0 * r_7, r_7 - 1.0f) * (F32_max(((F32_min((lambda_0), (r_7))) - (F32_min((_S722), (r_7)))), (0.0f))));
        }
        return make_float2 (_S720, (1.0f - d_old_0) * psi_0);
    }
    float ku_0 = 0.5f * (r_7 + 1.0f);
    float plateau_0 = u0_0 * (F32_max(((F32_min((lambda_0), (ku_0))) - (F32_min((_S722), (ku_0)))), (0.0f)));
    float snap_0;
    if(_S720 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return make_float2 (_S720, plateau_0 + snap_0);
}

static __device__ void compressed_region_0(float w0_0, float w1_0, float dz_0, float ax_0, float ay_0, FixedArray<float, 6>  * region_0)
{
    uint count_3;
    float h0_0 = 0.5f * w0_0;
    float h1_0 = 0.5f * w1_0;
    float _S723 = - h0_0;
    float _S724 = - h1_0;
    FixedArray<float2 , 4>  _S725 = { {
        float2 {
            _S723, _S724
        }, float2 {
            h0_0, _S724
        }, float2 {
            h0_0, h1_0
        }, float2 {
            _S723, h1_0
        }
    } };
    FixedArray<float2 , 8>  poly_0;
    uint i_12 = 0U;
    uint count_4 = 0U;
    for(;;)
    {
        if(i_12 < 4U)
        {
        }
        else
        {
            break;
        }
        uint _S726 = i_12;
        uint _S727 = i_12 + 1U;
        uint _S728 = _S727 % 4U;
        float _S729 = _S725[i_12].y;
        float _S730 = _S725[i_12].x;
        float fp_0 = dz_0 + ax_0 * _S729 - ay_0 * _S730;
        float _S731 = _S725[_S728].y;
        float _S732 = _S725[_S728].x;
        float fq_0 = dz_0 + ax_0 * _S731 - ay_0 * _S732;
        bool _S733 = fp_0 < 0.0f;
        if(_S733)
        {
            uint _S734 = count_4 + 1U;
            poly_0[count_4] = _S725[_S726];
            count_3 = _S734;
        }
        else
        {
            count_3 = count_4;
        }
        if(_S733 != (fq_0 < 0.0f))
        {
            float t_11 = fp_0 / (fp_0 - fq_0);
            uint _S735 = count_3 + 1U;
            poly_0[count_3] = make_float2 (_S730 + t_11 * (_S732 - _S730), _S729 + t_11 * (_S731 - _S729));
            count_4 = _S735;
        }
        else
        {
            count_4 = count_3;
        }
        i_12 = _S727;
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
    i_12 = 0U;
    float a_12 = 0.0f;
    float sx_0 = 0.0f;
    float sy_0 = 0.0f;
    float ixx_0 = 0.0f;
    float iyy_0 = 0.0f;
    float ixy_0 = 0.0f;
    for(;;)
    {
        if(i_12 < count_4)
        {
        }
        else
        {
            break;
        }
        float _S736 = o_1.x;
        float x0_0 = poly_0[i_12].x - _S736;
        float _S737 = o_1.y;
        float y0_0 = poly_0[i_12].y - _S737;
        uint _S738 = i_12 + 1U;
        uint _S739 = _S738 % count_4;
        float x1_0 = poly_0[_S739].x - _S736;
        float y1_0 = poly_0[_S739].y - _S737;
        float _S740 = x0_0 * y1_0;
        float _S741 = x1_0 * y0_0;
        float cr_0 = _S740 - _S741;
        float a_13 = a_12 + cr_0 / 2.0f;
        float sx_1 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        float sy_1 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        float ixx_1 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        float iyy_1 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        float ixy_1 = ixy_0 + (_S740 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S741) * cr_0 / 24.0f;
        i_12 = _S738;
        a_12 = a_13;
        sx_0 = sx_1;
        sy_0 = sy_1;
        ixx_0 = ixx_1;
        iyy_0 = iyy_1;
        ixy_0 = ixy_1;
    }
    if(a_12 <= 0.0f)
    {
        return;
    }
    float cx_0 = sx_0 / a_12;
    float cy_0 = sy_0 / a_12;
    (*region_0)[int(0)] = a_12;
    (*region_0)[int(1)] = o_1.x + cx_0;
    (*region_0)[int(2)] = o_1.y + cy_0;
    float _S742 = a_12 * cx_0;
    (*region_0)[int(3)] = ixx_0 - _S742 * cx_0;
    (*region_0)[int(4)] = iyy_0 - a_12 * cy_0 * cy_0;
    (*region_0)[int(5)] = ixy_0 - _S742 * cy_0;
    return;
}

static __device__ __noinline__ float4  no_tension_patch_0(float kn_0, float w0_1, float w1_1, float dz_1, float ax_1, float ay_1)
{
    FixedArray<float, 6>  r_8;
    compressed_region_0(w0_1, w1_1, dz_1, ax_1, ay_1, &r_8);
    float a_14 = r_8[int(0)];
    if((r_8[int(0)]) == 0.0f)
    {
        return make_float4 (0.0f);
    }
    float k_16 = kn_0 / (w0_1 * w1_1);
    float fc_3 = dz_1 + ax_1 * r_8[int(2)] - ay_1 * r_8[int(1)];
    float _S743 = a_14 * fc_3;
    float _S744 = - ay_1;
    return make_float4 (k_16 * a_14 * fc_3, k_16 * (_S743 * r_8[int(2)] + (_S744 * r_8[int(5)] + ax_1 * r_8[int(4)])), - k_16 * (_S743 * r_8[int(1)] + (_S744 * r_8[int(3)] + ax_1 * r_8[int(5)])), 0.5f * k_16 * (_S743 * fc_3 + ay_1 * ay_1 * r_8[int(3)] + ax_1 * ax_1 * r_8[int(4)] - 2.0f * ax_1 * ay_1 * r_8[int(5)]));
}

static __device__ float signum_0(float x_19)
{
    float _S745;
    if(((F32_asuint((x_19))) & 2147483648U) != 0U)
    {
        _S745 = -1.0f;
    }
    else
    {
        _S745 = 1.0f;
    }
    return _S745;
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

static __device__ __noinline__ Contact_0 contact_part_0(JointMaterial_0 * mat_4, JointBond_0 * b_26, float crush_2, float3  plastic_2, float3  d_lin_0, float3  d_ang_0)
{
    Contact_0 c_10;
    float3  _S746 = make_float3 (0.0f);
    (&c_10)->q_lin_1 = _S746;
    (&c_10)->q_ang_1 = _S746;
    (&c_10)->energy_2 = 0.0f;
    (&c_10)->diss_4 = 0.0f;
    (&c_10)->plastic_1 = plastic_2;
    uint _S747 = mat_4->kind_flags_0.y;
    if((_S747 & 2U) == 0U)
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
    if((_S747 & 4U) != 0U)
    {
        float4  p_9 = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        float _S748 = p_9.y;
        float _S749 = p_9.z;
        float _S750 = p_9.w;
        nc_sum_0 = p_9.x;
        m1_0 = _S748;
        m2_0 = _S749;
        energy_3 = _S750;
    }
    else
    {
        float ki_0 = kn_1 * (1.0f - crush_2) / 36.0f;
        float _S751 = d_ang_0.x;
        float _S752 = d_ang_0.y;
        float spread_0 = (F32_abs((_S751))) * 0.4166666567325592f * w1_2 + (F32_abs((_S752))) * 0.4166666567325592f * w0_2;
        float _S753 = d_lin_0.z;
        float slack_0 = 9.99999997475242708e-07f * ((F32_abs((_S753))) + spread_0);
        if((_S753 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S753 + spread_0) < (- slack_0))
            {
                float i1_0 = 2.91666650772094727f * w0_2 * w0_2;
                float i2_0 = 2.91666650772094727f * w1_2 * w1_2;
                float _S754 = ki_0 * _S751 * i2_0;
                float _S755 = ki_0 * _S752 * i1_0;
                float _S756 = 0.5f * ki_0 * (36.0f * _S753 * _S753 + _S751 * _S751 * i2_0 + _S752 * _S752 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S753;
                m1_0 = _S754;
                m2_0 = _S755;
                energy_3 = _S756;
            }
            else
            {
                uint i_13 = 0U;
                diss_5 = 0.0f;
                float m1_1 = 0.0f;
                float m2_1 = 0.0f;
                float energy_4 = 0.0f;
                for(;;)
                {
                    if(i_13 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float _S757 = SPRING_AT_0[i_13] * w0_2;
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
                        float s2_0 = SPRING_AT_0[j_4] * w1_2;
                        float di_0 = _S753 + _S751 * s2_0 - _S752 * _S757;
                        if(di_0 < 0.0f)
                        {
                            float f_13 = ki_0 * di_0;
                            float m1_2 = m1_0 + f_13 * s2_0;
                            float m2_2 = m2_0 - f_13 * _S757;
                            float energy_5 = energy_3 + 0.5f * ki_0 * di_0 * di_0;
                            nc_sum_0 = nc_sum_0 + f_13;
                            m1_0 = m1_2;
                            m2_0 = m2_2;
                            energy_3 = energy_5;
                        }
                        j_4 = j_4 + 1U;
                    }
                    i_13 = i_13 + 1U;
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
    float _S758 = ks_0 * (d_lin_0.x - plastic_2.x);
    float _S759 = ks_0 * (d_lin_0.y - plastic_2.y);
    float tn_0 = fsqrt_0(_S758 * _S758 + _S759 * _S759);
    bool _S760;
    if(tn_0 > slide_cap_0)
    {
        _S760 = tn_0 > 0.0f;
    }
    else
    {
        _S760 = false;
    }
    if(_S760)
    {
        float _S761 = fdiv_0(_S758, tn_0);
        float _S762 = fdiv_0(_S759, tn_0);
        float dslip_0 = fdiv_0(tn_0 - slide_cap_0, ks_0);
        *&((&p_10)->x) = *&((&p_10)->x) + _S761 * dslip_0;
        *&((&p_10)->y) = *&((&p_10)->y) + _S762 * dslip_0;
        *&((&(&c_10)->q_lin_1)->x) = _S761 * slide_cap_0;
        *&((&(&c_10)->q_lin_1)->y) = _S762 * slide_cap_0;
        diss_5 = slide_cap_0 * dslip_0;
    }
    else
    {
        *&((&(&c_10)->q_lin_1)->x) = _S758;
        *&((&(&c_10)->q_lin_1)->y) = _S759;
        diss_5 = 0.0f;
    }
    float2  tq_0 = return_map_0(kt_0, d_ang_0.z, p_10.z, slide_cap_0 * b_26->geom1_0.z);
    float _S763 = tq_0.x;
    float _S764 = tq_0.y;
    float diss_6 = diss_5 + (F32_abs((_S763))) * (F32_abs((_S764)));
    *&((&p_10)->z) = *&((&p_10)->z) + _S764;
    *&((&(&c_10)->q_ang_1)->z) = _S763;
    (&c_10)->energy_2 = energy_3 + 0.5f * (fdiv_0(sq_0((&c_10)->q_lin_1.x), ks_0) + fdiv_0(sq_0((&c_10)->q_lin_1.y), ks_0) + fdiv_0(sq_0(_S763), kt_0));
    (&c_10)->diss_4 = diss_6;
    (&c_10)->plastic_1 = p_10;
    return c_10;
}

static __device__ float3  contact_offsets_0(JointMaterial_0 * mat_5, JointBond_0 * b_27, float crush_3, float3  plastic_3, float3  d_lin_1, float3  d_ang_1)
{
    uint _S765 = mat_5->kind_flags_0.y;
    if((_S765 & 2U) == 0U)
    {
        return plastic_3;
    }
    float kn_2 = b_27->stiff0_0.x;
    float ks_1 = b_27->stiff0_0.y;
    float kt_1 = b_27->stiff1_0.x;
    float w0_3 = b_27->geom0_0.y;
    float w1_3 = b_27->geom0_0.z;
    float nc_sum_1;
    if((_S765 & 4U) != 0U)
    {
        float4  _S766 = no_tension_patch_0(kn_2 * (1.0f - crush_3), w0_3, w1_3, d_lin_1.z, d_ang_1.x, d_ang_1.y);
        nc_sum_1 = _S766.x;
    }
    else
    {
        float ki_1 = kn_2 * (1.0f - crush_3) / 36.0f;
        float _S767 = d_ang_1.x;
        float _S768 = d_ang_1.y;
        float spread_1 = (F32_abs((_S767))) * 0.4166666567325592f * w1_3 + (F32_abs((_S768))) * 0.4166666567325592f * w0_3;
        float _S769 = d_lin_1.z;
        float slack_1 = 9.99999997475242708e-07f * ((F32_abs((_S769))) + spread_1);
        if((_S769 - spread_1) > slack_1)
        {
            nc_sum_1 = 0.0f;
        }
        else
        {
            if((_S769 + spread_1) < (- slack_1))
            {
                nc_sum_1 = ki_1 * 36.0f * _S769;
            }
            else
            {
                uint i_14 = 0U;
                float nc_sum_2 = 0.0f;
                for(;;)
                {
                    if(i_14 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float _S770 = SPRING_AT_0[i_14] * w0_3;
                    uint j_5 = 0U;
                    nc_sum_1 = nc_sum_2;
                    for(;;)
                    {
                        if(j_5 < 6U)
                        {
                        }
                        else
                        {
                            break;
                        }
                        float di_1 = _S769 + _S767 * (SPRING_AT_0[j_5] * w1_3) - _S768 * _S770;
                        if(di_1 < 0.0f)
                        {
                            nc_sum_1 = nc_sum_1 + ki_1 * di_1;
                        }
                        j_5 = j_5 + 1U;
                    }
                    i_14 = i_14 + 1U;
                    nc_sum_2 = nc_sum_1;
                }
                nc_sum_1 = nc_sum_2;
            }
        }
    }
    float nc_1 = - nc_sum_1;
    float3  p_11 = plastic_3;
    float slide_cap_1 = mat_5->strength_0.w * nc_1;
    float _S771 = ks_1 * (d_lin_1.x - plastic_3.x);
    float _S772 = ks_1 * (d_lin_1.y - plastic_3.y);
    float tn_1 = fsqrt_0(_S771 * _S771 + _S772 * _S772);
    bool _S773;
    if(tn_1 > slide_cap_1)
    {
        _S773 = tn_1 > 0.0f;
    }
    else
    {
        _S773 = false;
    }
    if(_S773)
    {
        float _S774 = fdiv_0(_S772, tn_1);
        float dslip_1 = fdiv_0(tn_1 - slide_cap_1, ks_1);
        *&((&p_11)->x) = *&((&p_11)->x) + fdiv_0(_S771, tn_1) * dslip_1;
        *&((&p_11)->y) = *&((&p_11)->y) + _S774 * dslip_1;
    }
    *&((&p_11)->z) = *&((&p_11)->z) + return_map_0(kt_1, d_ang_1.z, p_11.z, slide_cap_1 * b_27->geom1_0.z).y;
    return p_11;
}

static __device__ float life_rate_0(JointMaterial_0 * mat_6, float s_6)
{
    if(s_6 <= 0.0f)
    {
        return 0.0f;
    }
    float _S775 = mat_6->misc_0.y;
    return fdiv_0((_S775 + 1.0f) * fpow_0(s_6, _S775), mat_6->misc_0.z);
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
    float fatigue_before_0;
    Measures_0 measures_0;
};

static __device__ JointResponse_0 joint_evaluate_0(JointMaterial_0 * mat_7, JointBond_0 * b_28, JointState_0 * state_2, float3  d_lin_2, float3  d_ang_2, float dt_9, bool fracture_1)
{
    float kn_3 = b_28->stiff0_0.x;
    float ks_2 = b_28->stiff0_0.y;
    float kb1_0 = b_28->stiff0_0.z;
    float kb2_0 = b_28->stiff0_0.w;
    float4  _S776 = b_28->stiff1_0;
    float kt_2 = b_28->stiff1_0.x;
    bool has_rebar_1 = (b_28->stiff1_0.w) != 0.0f;
    uint kind_4 = mat_7->kind_flags_0.x;
    uint flags_1 = mat_7->kind_flags_0.y;
    bool softening_0 = (flags_1 & 1U) != 0U;
    JointState_0 st_2 = *state_2;
    bool _S777 = connected_0(state_2, has_rebar_1);
    float3  qe_lin_0 = d_lin_2 * make_float3 (ks_2, ks_2, kn_3);
    float3  qe_ang_0 = d_ang_2 * make_float3 (kb1_0, kb2_0, kt_2);
    Measures_0 _S778 = stress_measures_0(b_28, qe_lin_0, qe_ang_0);
    float _S779 = (F32_max(((F32_max((_S778.tension_0), (_S778.shear_0)))), (_S778.compression_0)));
    bool _S780 = dt_9 > 0.0f;
    float dif_1;
    if(_S780)
    {
        float raw_0 = fdiv_0((F32_max((fdiv_0(_S779 - (&st_2)->governing_stress_0, dt_9)), (0.0f))), mat_7->misc_0.w);
        float tau_2 = _S776.z;
        if((flags_1 & 16U) != 0U)
        {
            dif_1 = - expm1_accurate_0(- fdiv_0(dt_9, tau_2));
        }
        else
        {
            dif_1 = (F32_min((fdiv_0(dt_9, tau_2)), (1.0f)));
        }
        (&st_2)->strain_rate_0 = (&st_2)->strain_rate_0 + (raw_0 - (&st_2)->strain_rate_0) * dif_1;
        (&st_2)->governing_stress_0 = _S779;
    }
    if((flags_1 & 32U) != 0U)
    {
        float _S781 = dif_factor_0(mat_7, (&st_2)->strain_rate_0);
        dif_1 = _S781;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = b_28->geom1_0.w;
    float _S782 = fatigue_factor_0(mat_7, (&st_2)->life_0);
    float multiplier_1 = weibull_0 * dif_1 * _S782;
    Measures_0 _S783 = _S778;
    float4  _S784 = failure_indices_0(mat_7, b_28, &_S783, multiplier_1);
    float _S785 = _S784.x;
    float _S786 = _S784.y;
    (&st_2)->utilization_0 = (F32_max(((F32_max((_S785), (_S786)))), ((F32_max((_S784.z), (_S784.w))))));
    float _S787 = d_lin_2.x;
    float _S788 = d_lin_2.y;
    float _S789 = ks_2 * (sq_0(_S787) + sq_0(_S788)) + kb1_0 * sq_0(d_ang_2.x) + kb2_0 * sq_0(d_ang_2.y) + kt_2 * sq_0(d_ang_2.z);
    float _S790 = d_lin_2.z;
    bool _S791 = _S790 > 0.0f;
    if(_S791)
    {
        dif_1 = kn_3 * sq_0(_S790);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S789 + dif_1);
    float psi_c_0;
    if(_S790 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_3 * sq_0(_S790);
    }
    else
    {
        psi_c_0 = 0.0f;
    }
    float3  plastic_4 = make_float3 ((&st_2)->plastic_x_0, (&st_2)->plastic_y_0, (&st_2)->plastic_t_0);
    float diss_contact_0;
    float psi_contact_0;
    float intact_normal_0;
    float dissipated_3;
    float overshoot_1;
    bool _S792;
    float3  qc_lin_0;
    if(fracture_1)
    {
        bool _S793 = _S785 >= _S786;
        if(_S793)
        {
            diss_contact_0 = _S785;
        }
        else
        {
            diss_contact_0 = _S786;
        }
        uint mode_ts_0;
        if(_S793)
        {
            mode_ts_0 = 1U;
        }
        else
        {
            mode_ts_0 = 2U;
        }
        if(diss_contact_0 > ((&st_2)->kappa_0))
        {
            _S792 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S792 = false;
        }
        if(_S792)
        {
            _S792 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S792 = false;
        }
        uint mode_c_0;
        if(_S792)
        {
            if(mode_ts_0 == 1U)
            {
                psi_contact_0 = mat_7->energy_0.y;
            }
            else
            {
                psi_contact_0 = mat_7->energy_0.z;
            }
            if(softening_0)
            {
                intact_normal_0 = fdiv_0(psi_contact_0 * b_28->geom0_0.x * diss_contact_0 * diss_contact_0, psi_ts_0);
            }
            else
            {
                intact_normal_0 = 0.0f;
            }
            (&st_2)->ductility_0 = intact_normal_0;
            if(softening_0)
            {
                mode_c_0 = kind_4;
            }
            else
            {
                mode_c_0 = 0U;
            }
            float2  inc_0 = damage_increment_0(mode_c_0, (&st_2)->kappa_0, diss_contact_0, intact_normal_0, (&st_2)->damage_0, psi_ts_0);
            float _S794 = inc_0.x;
            if(_S794 > ((&st_2)->damage_0))
            {
                Contact_0 _S795 = contact_part_0(mat_7, b_28, (&st_2)->crush_0, plastic_4, d_lin_2, d_ang_2);
                float _S796 = (F32_max((_S795.energy_2 - (1.0f - (&st_2)->crush_0) * psi_c_0), (0.0f)));
                float _S797 = (F32_max((inc_0.y - _S796 * (_S794 - (&st_2)->damage_0)), (0.0f)));
                float _S798 = (F32_max(((psi_ts_0 - _S796) * (_S794 - (&st_2)->damage_0) - _S797), (0.0f)));
                (&st_2)->damage_0 = _S794;
                (&st_2)->mode_0 = mode_ts_0;
                dissipated_3 = _S797;
                overshoot_1 = _S798;
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
        (&st_2)->kappa_0 = (F32_max(((&st_2)->kappa_0), (diss_contact_0)));
        float _S799 = state_2->damage_0;
        if((state_2->damage_0) > 0.0f)
        {
            Contact_0 _S800 = contact_part_0(mat_7, b_28, state_2->crush_0, make_float3 (state_2->plastic_x_0, state_2->plastic_y_0, state_2->plastic_t_0), d_lin_2, d_ang_2);
            qc_lin_0 = qe_ang_0 * make_float3 (1.0f - _S799) + _S800.q_ang_1 * make_float3 (_S799);
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S801 = stress_measures_0(b_28, make_float3 (0.0f, 0.0f, (F32_min((qe_lin_0.z), (0.0f)))), qc_lin_0);
        Measures_0 _S802 = _S801;
        float4  _S803 = failure_indices_0(mat_7, b_28, &_S802, multiplier_1);
        float _S804 = _S803.z;
        float _S805 = _S803.w;
        bool _S806 = _S804 >= _S805;
        if(_S806)
        {
            psi_contact_0 = _S804;
        }
        else
        {
            psi_contact_0 = _S805;
        }
        if(_S806)
        {
            mode_c_0 = 3U;
        }
        else
        {
            mode_c_0 = 4U;
        }
        if(psi_contact_0 > ((&st_2)->kappa_c_0))
        {
            _S792 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S792 = false;
        }
        if(_S792)
        {
            _S792 = psi_c_0 > 0.0f;
        }
        else
        {
            _S792 = false;
        }
        if(_S792)
        {
            if(softening_0)
            {
                intact_normal_0 = fdiv_0(mat_7->energy_0.w * b_28->geom0_0.x * psi_contact_0 * psi_contact_0, psi_c_0);
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
                    mode_ts_0 = kind_4;
                }
                law_1 = mode_ts_0;
            }
            float2  inc_1 = damage_increment_0(law_1, (&st_2)->kappa_c_0, psi_contact_0, intact_normal_0, (&st_2)->crush_0, psi_c_0);
            float _S807 = inc_1.x;
            if(_S807 > ((&st_2)->crush_0))
            {
                float _S808 = inc_1.y;
                float dissipated_4 = dissipated_3 + _S808;
                float overshoot_2 = overshoot_1 + (F32_max((psi_c_0 * (_S807 - (&st_2)->crush_0) - _S808), (0.0f)));
                (&st_2)->crush_0 = _S807;
                (&st_2)->mode_0 = mode_c_0;
                if(_S807 >= 1.0f)
                {
                    _S792 = ((&st_2)->damage_0) < 1.0f;
                }
                else
                {
                    _S792 = false;
                }
                if(_S792)
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
        (&st_2)->kappa_c_0 = (F32_max(((&st_2)->kappa_c_0), (psi_contact_0)));
    }
    else
    {
        dissipated_3 = 0.0f;
        overshoot_1 = 0.0f;
    }
    float dmg_0 = (&st_2)->damage_0;
    float3  _S809 = make_float3 (0.0f);
    float3  qc_ang_0;
    if(((&st_2)->damage_0) == 0.0f)
    {
        if((flags_1 & 8U) == 0U)
        {
            float3  _S810 = contact_offsets_0(mat_7, b_28, (&st_2)->crush_0, plastic_4, d_lin_2, d_ang_2);
            (&st_2)->plastic_x_0 = _S810.x;
            (&st_2)->plastic_y_0 = _S810.y;
            (&st_2)->plastic_t_0 = _S810.z;
        }
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S809;
        qc_ang_0 = _S809;
        psi_contact_0 = 0.0f;
    }
    else
    {
        Contact_0 _S811 = contact_part_0(mat_7, b_28, (&st_2)->crush_0, plastic_4, d_lin_2, d_ang_2);
        (&st_2)->plastic_x_0 = _S811.plastic_1.x;
        (&st_2)->plastic_y_0 = _S811.plastic_1.y;
        (&st_2)->plastic_t_0 = _S811.plastic_1.z;
        diss_contact_0 = _S811.diss_4;
        qc_lin_0 = _S811.q_lin_1;
        qc_ang_0 = _S811.q_ang_1;
        psi_contact_0 = _S811.energy_2;
    }
    float dissipated_6 = dissipated_3 + dmg_0 * diss_contact_0;
    if(_S791)
    {
        intact_normal_0 = kn_3 * _S790;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_2)->crush_0) * kn_3 * _S790;
    }
    float _S812 = 1.0f - dmg_0;
    float3  force_lin_2 = make_float3 (_S812 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S812 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S812 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3  force_ang_2 = qe_ang_0 * make_float3 (_S812) + qc_ang_0 * make_float3 (dmg_0);
    float stored_6 = _S812 * (psi_ts_0 + (1.0f - (&st_2)->crush_0) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S792 = ((&st_2)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S792 = false;
    }
    float stored_7;
    float3  force_lin_3;
    if(_S792)
    {
        float k_axial_0 = b_28->rebar0_0.x;
        float k_dowel_0 = b_28->rebar0_0.y;
        float yield_force_0 = b_28->rebar0_0.z;
        float dowel_capacity_0 = b_28->rebar0_0.w;
        float2  nr_0 = return_map_0(k_axial_0, _S790, (&st_2)->rebar_plastic_0, yield_force_0);
        float2  v1_0 = return_map_0(k_dowel_0, _S787, (&st_2)->rebar_slip0_0, dowel_capacity_0);
        float2  v2_0 = return_map_0(k_dowel_0, _S788, (&st_2)->rebar_slip1_0, dowel_capacity_0);
        float _S813 = nr_0.y;
        float _S814 = v1_0.y;
        float _S815 = v2_0.y;
        float work_0 = yield_force_0 * (F32_abs((_S813))) + dowel_capacity_0 * ((F32_abs((_S814))) + (F32_abs((_S815))));
        (&st_2)->rebar_plastic_0 = (&st_2)->rebar_plastic_0 + _S813;
        (&st_2)->rebar_slip0_0 = (&st_2)->rebar_slip0_0 + _S814;
        (&st_2)->rebar_slip1_0 = (&st_2)->rebar_slip1_0 + _S815;
        (&st_2)->rebar_work_0 = (&st_2)->rebar_work_0 + work_0;
        float dissipated_7 = dissipated_6 + work_0;
        float _S816 = nr_0.x;
        float _S817 = v1_0.x;
        float _S818 = v2_0.x;
        float elastic_0 = 0.5f * (fdiv_0(sq_0(_S816), k_axial_0) + fdiv_0(sq_0(_S817) + sq_0(_S818), k_dowel_0));
        if(fracture_1)
        {
            _S792 = ((&st_2)->rebar_work_0) >= (b_28->rebar1_0.x);
        }
        else
        {
            _S792 = false;
        }
        if(_S792)
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
            force_lin_3 = force_lin_2 + make_float3 (_S817, _S818, _S816);
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
        _S792 = _S780;
    }
    else
    {
        _S792 = false;
    }
    if(_S792)
    {
        _S792 = (flags_1 & 64U) != 0U;
    }
    else
    {
        _S792 = false;
    }
    if(_S792)
    {
        Measures_0 _S819 = stress_measures_0(b_28, force_lin_3, force_ang_2);
        Measures_0 _S820 = _S819;
        float4  _S821 = failure_indices_0(mat_7, b_28, &_S820, weibull_0);
        float _S822 = life_rate_0(mat_7, (F32_max(((F32_max((_S821.x), (_S821.y)))), (_S821.z))));
        (&st_2)->life_0 = (F32_max(((&st_2)->life_0 - _S822 * dt_9), (0.0f)));
    }
    (&st_2)->dissipated_0 = (&st_2)->dissipated_0 + dissipated_3;
    JointResponse_0 resp_0;
    (&resp_0)->force_lin_1 = force_lin_3;
    (&resp_0)->force_ang_1 = force_ang_2;
    (&resp_0)->state_1 = st_2;
    (&resp_0)->dissipated_2 = dissipated_3;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_5 = stored_7;
    if(_S777)
    {
        JointState_0 _S823 = st_2;
        bool _S824 = connected_0(&_S823, has_rebar_1);
        _S792 = !_S824;
    }
    else
    {
        _S792 = false;
    }
    (&resp_0)->disconnected_0 = _S792;
    (&resp_0)->fatigue_before_0 = _S782;
    (&resp_0)->measures_0 = _S778;
    return resp_0;
}

static __device__ void secant_factors_0(JointBond_0 * b_29, JointState_0 * st_3, float3  d_lin_3, float3  * f_lin_0, float3  * f_ang_0)
{
    float _S825 = st_3->damage_0;
    bool compressed_0 = (d_lin_3.z) < 0.0f;
    float contact_2;
    if(compressed_0)
    {
        contact_2 = _S825;
    }
    else
    {
        contact_2 = 0.0f;
    }
    float _S826 = 1.0f - _S825;
    float _S827 = (F32_max((_S826 + contact_2), (9.99999997475242708e-07f)));
    float normal_4;
    if(compressed_0)
    {
        normal_4 = (F32_max((1.0f - st_3->crush_0), (9.99999997475242708e-07f)));
    }
    else
    {
        normal_4 = (F32_max((_S826), (9.99999997475242708e-07f)));
    }
    *f_lin_0 = make_float3 (_S827, _S827, normal_4);
    *f_ang_0 = make_float3 (_S827);
    bool _S828;
    if((b_29->stiff1_0.w) != 0.0f)
    {
        _S828 = (st_3->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S828 = false;
    }
    if(_S828)
    {
        float4  _S829 = b_29->rebar0_0;
        float4  _S830 = b_29->stiff0_0;
        *&(f_lin_0->z) = *&(f_lin_0->z) + fdiv_0(b_29->rebar0_0.x, b_29->stiff0_0.x);
        float _S831 = fdiv_0(_S829.y, _S830.y);
        *&(f_lin_0->x) = *&(f_lin_0->x) + _S831;
        *&(f_lin_0->y) = *&(f_lin_0->y) + _S831;
    }
    return;
}

static __device__ float3  to_local_0(uint _S832, float3  _S833)
{
    BondStatic_0 * _S834 = (&(globalParams_0->bonds_0)[_S832]);
    float4  _S835 = __ldg(&_S834->t1_0);
    float _S836 = dot_0(_S833, float3 {_S835.x, _S835.y, _S835.z});
    float4  _S837 = __ldg(&_S834->t2_0);
    float _S838 = dot_0(_S833, float3 {_S837.x, _S837.y, _S837.z});
    float4  _S839 = __ldg(&_S834->normal_0);
    return make_float3 (_S836, _S838, dot_0(_S833, float3 {_S839.x, _S839.y, _S839.z}));
}

static __device__ float3  to_body_0(uint _S840, float3  _S841)
{
    BondStatic_0 * _S842 = (&(globalParams_0->bonds_0)[_S840]);
    float4  _S843 = __ldg(&_S842->t1_0);
    float3  _S844 = float3 {_S843.x, _S843.y, _S843.z} * make_float3 (_S841.x);
    float4  _S845 = __ldg(&_S842->t2_0);
    float3  _S846 = _S844 + float3 {_S845.x, _S845.y, _S845.z} * make_float3 (_S841.y);
    float4  _S847 = __ldg(&_S842->normal_0);
    return _S846 + float3 {_S847.x, _S847.y, _S847.z} * make_float3 (_S841.z);
}

static __device__ bool bond_update_0(uint i_15, float dt_10, bool fracture_2, uint abs_step_0, bool wide_0)
{
    BondStatic_0 * _S848 = (&(globalParams_0->bonds_0)[i_15]);
    JointBond_0 _S849 = slang_ldg_0(&_S848->law_0);
    uint ca_0 = _S849.ids_0.y;
    uint cb_0 = _S849.ids_0.z;
    float4  _S850 = __ldg(&_S848->ra_0);
    float3  ra_1 = float3 {_S850.x, _S850.y, _S850.z};
    float4  _S851 = __ldg(&_S848->rb_0);
    float3  rb_1 = float3 {_S851.x, _S851.y, _S851.z};
    uint _S852 = 4U * ca_0;
    float4  _S853 = *(&(globalParams_0->state_0)[_S852]);
    float4  _S854 = *(&(globalParams_0->state_0)[_S852 + 1U]);
    float3  ta_2 = float3 {_S854.x, _S854.y, _S854.z};
    float4  _S855 = *(&(globalParams_0->state_0)[_S852 + 2U]);
    float3  va_0 = float3 {_S855.x, _S855.y, _S855.z};
    float4  _S856 = *(&(globalParams_0->state_0)[_S852 + 3U]);
    float3  wa_1 = float3 {_S856.x, _S856.y, _S856.z};
    uint _S857 = 4U * cb_0;
    float4  _S858 = *(&(globalParams_0->state_0)[_S857]);
    float4  _S859 = *(&(globalParams_0->state_0)[_S857 + 1U]);
    float3  tb_2 = float3 {_S859.x, _S859.y, _S859.z};
    float4  _S860 = *(&(globalParams_0->state_0)[_S857 + 2U]);
    float3  vb_0 = float3 {_S860.x, _S860.y, _S860.z};
    float4  _S861 = *(&(globalParams_0->state_0)[_S857 + 3U]);
    float3  wb_0 = float3 {_S861.x, _S861.y, _S861.z};
    float3  _S862 = to_local_0(i_15, float3 {_S858.x, _S858.y, _S858.z} + cross_0(tb_2, rb_1) - (float3 {_S853.x, _S853.y, _S853.z} + cross_0(ta_2, ra_1)));
    float3  _S863 = to_local_0(i_15, tb_2 - ta_2);
    float3  _S864 = to_local_0(i_15, vb_0 + cross_0(wb_0, rb_1) - (va_0 + cross_0(wa_1, ra_1)));
    float3  _S865 = to_local_0(i_15, wb_0 - wa_1);
    JointBond_0 _S866 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_15])->law_0);
    JointState_0 previous_0 = (&(globalParams_0->bond_dyn_0)[i_15])->js_0;
    JointState_0 _S867 = (&(globalParams_0->bond_dyn_0)[i_15])->js_0;
    bool _S868 = is_damaged_0(&_S867);
    JointBond_0 _S869 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_15])->law_0);
    JointBond_0 _S870 = _S869;
    JointState_0 _S871 = (&(globalParams_0->bond_dyn_0)[i_15])->js_0;
    JointResponse_0 _S872 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S866.ids_0.x], &_S870, &_S871, _S862, _S863, dt_10, fracture_2);
    BondStatic_0 * _S873 = (&(globalParams_0->bonds_0)[i_15]);
    BondDyn_0 bd_0 = *(&(globalParams_0->bond_dyn_0)[i_15]);
    float4  _S874 = __ldg(&_S873->ra_0);
    float3  ra_2 = float3 {_S874.x, _S874.y, _S874.z};
    float4  _S875 = __ldg(&_S873->rb_0);
    float3  rb_2 = float3 {_S875.x, _S875.y, _S875.z};
    JointBond_0 _S876 = slang_ldg_0(&_S873->law_0);
    JointBond_0 _S877 = _S876;
    JointState_0 _S878 = _S872.state_1;
    float3  f_lin_1;
    float3  f_ang_1;
    secant_factors_0(&_S877, &_S878, _S862, &f_lin_1, &f_ang_1);
    float4  _S879 = __ldg(&_S873->c_lin_0);
    float3  qd_lin_0 = _S864 * float3 {_S879.x, _S879.y, _S879.z} * f_lin_1;
    float4  _S880 = __ldg(&_S873->c_ang_0);
    float3  qd_ang_0 = _S865 * float3 {_S880.x, _S880.y, _S880.z} * f_ang_1;
    float3  q_lin_2 = _S872.force_lin_1 + qd_lin_0;
    float3  q_ang_2 = _S872.force_ang_1 + qd_ang_0;
    float damped_0 = (dot_0(qd_lin_0, _S864) + dot_0(qd_ang_0, _S865)) * dt_10;
    float3  _S881 = to_body_0(i_15, q_lin_2);
    float3  _S882 = to_body_0(i_15, q_ang_2);
    uint _S883 = 3U * i_15;
    *(&(globalParams_0->scratch_0)[_S883]) = make_float4 (_S881.x, _S881.y, _S881.z, (F32_max((_S872.measures_0.tension_0), (_S872.measures_0.compression_0))));
    *(&(globalParams_0->scratch_0)[_S883 + 1U]) = make_float4 ((_S882 + cross_0(ra_2, _S881)).x, (_S882 + cross_0(ra_2, _S881)).y, (_S882 + cross_0(ra_2, _S881)).z, 0.0f);
    *(&(globalParams_0->scratch_0)[_S883 + 2U]) = make_float4 ((- _S882 + cross_0(rb_2, - _S881)).x, (- _S882 + cross_0(rb_2, - _S881)).y, (- _S882 + cross_0(rb_2, - _S881)).z, 0.0f);
    comp_add1_0(&((&(&bd_0)->sums_0)->x), &((&(&bd_0)->comps_0)->x), _S872.dissipated_2);
    comp_add1_0(&((&(&bd_0)->sums_0)->y), &((&(&bd_0)->comps_0)->y), _S872.overshoot_0);
    comp_add1_0(&((&(&bd_0)->sums_0)->z), &((&(&bd_0)->comps_0)->z), damped_0);
    (&bd_0)->force_lin_0 = make_float4 (q_lin_2.x, q_lin_2.y, q_lin_2.z, _S872.stored_5);
    (&bd_0)->force_ang_0 = make_float4 (q_ang_2.x, q_ang_2.y, q_ang_2.z, (F32_max(((&bd_0)->force_ang_0.w), (_S872.state_1.utilization_0))));
    bool _S884;
    if(!_S868)
    {
        JointState_0 _S885 = _S872.state_1;
        bool _S886 = is_damaged_0(&_S885);
        _S884 = _S886;
    }
    else
    {
        _S884 = false;
    }
    if(_S884)
    {
        _S884 = ((&bd_0)->events_0.x) == 0U;
    }
    else
    {
        _S884 = false;
    }
    if(_S884)
    {
        *&((&(&bd_0)->events_0)->x) = abs_step_0;
        *&((&(&bd_0)->events_0)->w) = _S872.state_1.mode_0;
        if(wide_0)
        {
            cov_or_0(_S876.ids_0.w, 32U);
        }
        else
        {
            (*&g_seen_0)[3U] = 1U;
        }
    }
    if(((&bd_0)->events_0.y) == 0U)
    {
        _S884 = (_S872.state_1.life_0) != (previous_0.life_0);
    }
    else
    {
        _S884 = false;
    }
    if(_S884)
    {
        _S884 = (_S872.fatigue_before_0) > 0.99000000953674316f;
    }
    else
    {
        _S884 = false;
    }
    if(_S884)
    {
        float _S887 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S866.ids_0.x], _S872.state_1.life_0);
        _S884 = _S887 <= 0.99000000953674316f;
    }
    else
    {
        _S884 = false;
    }
    if(_S884)
    {
        *&((&(&bd_0)->events_0)->y) = abs_step_0;
        if(wide_0)
        {
            cov_or_0(_S876.ids_0.w, 64U);
        }
        else
        {
            (*&g_seen_0)[4U] = 1U;
        }
    }
    if(_S872.disconnected_0)
    {
        *&((&(&bd_0)->events_0)->z) = abs_step_0;
    }
    (&bd_0)->js_0 = _S872.state_1;
    *(&(globalParams_0->bond_dyn_0)[i_15]) = bd_0;
    return _S872.disconnected_0;
}

static __device__ void chunk_update_0(uint c_11, Island_0 * isl_6, Rigid_0 * rg_5, float dt_11, bool rml_0, uint step_0, bool contact_3, float * work_1, float * work_err_0)
{
    ChunkStatic_0 * _S888 = (&(globalParams_0->chunks_0)[c_11]);
    float3  _S889 = make_float3 (0.0f);
    uint _S890 = __ldg((&(globalParams_0->index_0)[c_11]));
    float peak_0 = 0.0f;
    uint e_3 = _S890;
    float3  fi_0 = _S889;
    float3  mi_0 = _S889;
    for(;;)
    {
        uint _S891 = __ldg((&(globalParams_0->index_0)[c_11 + 1U]));
        if(e_3 < _S891)
        {
        }
        else
        {
            break;
        }
        uint _S892 = __ldg((&(globalParams_0->index_0)[e_3]));
        uint _S893 = 3U * (_S892 >> int(1));
        float4  fa_2 = *(&(globalParams_0->scratch_0)[_S893]);
        if((_S892 & 1U) == 0U)
        {
            float4  _S894 = *(&(globalParams_0->scratch_0)[_S893 + 1U]);
            float3  mi_1 = mi_0 + float3 {_S894.x, _S894.y, _S894.z};
            fi_0 = fi_0 + float3 {fa_2.x, fa_2.y, fa_2.z};
            mi_0 = mi_1;
        }
        else
        {
            float4  _S895 = *(&(globalParams_0->scratch_0)[_S893 + 2U]);
            float3  mi_2 = mi_0 + float3 {_S895.x, _S895.y, _S895.z};
            fi_0 = fi_0 + - float3 {fa_2.x, fa_2.y, fa_2.z};
            mi_0 = mi_2;
        }
        float _S896 = (F32_max((peak_0), (fa_2.w)));
        uint _S897 = e_3 + 1U;
        peak_0 = _S896;
        e_3 = _S897;
    }
    uint _S898 = 4U * c_11;
    float4  _S899 = *(&(globalParams_0->state_0)[_S898]);
    float3  u_0 = float3 {_S899.x, _S899.y, _S899.z};
    uint _S900 = _S898 + 1U;
    float4  _S901 = *(&(globalParams_0->state_0)[_S900]);
    float3  th_1 = float3 {_S901.x, _S901.y, _S901.z};
    uint _S902 = _S898 + 2U;
    float4  _S903 = *(&(globalParams_0->state_0)[_S902]);
    float3  v_11 = float3 {_S903.x, _S903.y, _S903.z};
    uint _S904 = _S898 + 3U;
    float4  _S905 = *(&(globalParams_0->state_0)[_S904]);
    float3  w_5 = float3 {_S905.x, _S905.y, _S905.z};
    float4  _S906 = __ldg(&_S888->center_0);
    float mass_0 = _S906.w;
    float3  _S907 = float3 {_S906.x, _S906.y, _S906.z};
    float4  _S908 = isl_6->com_0;
    float3  _S909 = float3 {_S908.x, _S908.y, _S908.z};
    float3  _S910 = rotate_0(&rg_5->rot_0, _S907 + u_0 - _S909);
    float3  f_load_0;
    float3  t_load_0;
    float3  rep_f_1;
    float3  rep_m_1;
    chunk_loads_0(c_11, c_11, &rg_5->rot_0, step_0, dt_11, contact_3, dt_11, &f_load_0, &t_load_0, &rep_f_1, &rep_m_1);
    record_chunk_load_0(c_11, f_load_0, t_load_0);
    float3  _S911 = f_load_0;
    float4  _S912 = __ldg(&globalParams_0->params_0->gravity_0);
    float3  f_world_0 = _S911 + float3 {_S912.x, _S912.y, _S912.z} * make_float3 (mass_0);
    float3  t_world_0 = t_load_0;
    float3  f_world_1;
    float3  t_world_1;
    if(rml_0)
    {
        float3  _S913 = rg_5->alpha_0;
        float3  _S914 = rg_5->w_4;
        float3  f_world_2 = f_world_0 - (rg_5->a_7 + cross_0(rg_5->alpha_0, _S910) + cross_0(rg_5->w_4, cross_0(rg_5->w_4, _S910))) * make_float3 (mass_0);
        float4  _S915 = __ldg(&_S888->inertia0_0);
        float4  _S916 = __ldg(&_S888->inertia1_0);
        float4  _S917 = __ldg(&_S888->inertia2_0);
        float3  _S918 = world_mul_0(&rg_5->rot_0, _S915, _S916, _S917, _S913);
        float3  _S919 = world_mul_0(&rg_5->rot_0, _S915, _S916, _S917, _S914);
        float3  t_world_2 = t_world_0 - (_S918 + cross_0(_S914, _S919));
        f_world_1 = f_world_2;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    float3  _S920 = inverse_rotate_0(&rg_5->rot_0, f_world_1);
    float3  _S921 = inverse_rotate_0(&rg_5->rot_0, t_world_1);
    float3  f_ext_0;
    float3  m_ext_0;
    if(rml_0)
    {
        float3  _S922 = inverse_rotate_0(&rg_5->rot_0, rg_5->w_4);
        float3  f_ext_1 = _S920 - cross_0(_S922, v_11) * make_float3 (2.0f * mass_0);
        float4  _S923 = __ldg(&_S888->inertia0_0);
        float4  _S924 = __ldg(&_S888->inertia1_0);
        float4  _S925 = __ldg(&_S888->inertia2_0);
        float3  i_w_0 = rows_mul_0(_S923, _S924, _S925, w_5);
        float3  m_ext_1 = _S921 - (cross_0(_S922, i_w_0) + cross_0(w_5, rows_mul_0(_S923, _S924, _S925, _S922)) + cross_0(w_5, i_w_0));
        f_ext_0 = f_ext_1;
        m_ext_0 = m_ext_1;
    }
    else
    {
        f_ext_0 = _S920;
        m_ext_0 = _S921;
    }
    float3  f_14 = f_ext_0 + rep_f_1 + fi_0;
    float3  m_5 = m_ext_0 + rep_m_1 + mi_0;
    uint4  _S926 = __ldg(&_S888->info_0);
    uint support_0 = _S926.x;
    float3  _S927 = make_float3 ((*(&(globalParams_0->state_0)[_S900])).w, (*(&(globalParams_0->state_0)[_S902])).w, (*(&(globalParams_0->state_0)[_S904])).w);
    float3  reaction_0;
    float3  u_1;
    float3  th_2;
    float3  v_12;
    float3  w_6;
    if(support_0 == 1U)
    {
        reaction_0 = - f_14;
        u_1 = u_0;
        th_2 = th_1;
        v_12 = _S889;
        w_6 = _S889;
    }
    else
    {
        float4  _S928 = __ldg(&_S888->inv0_0);
        float4  _S929 = __ldg(&_S888->inv1_0);
        float4  _S930 = __ldg(&_S888->inv2_0);
        float3  _S931 = rows_mul_0(_S928, _S929, _S930, m_5);
        float4  _S932 = __ldg(&_S888->scale_0);
        float3  w_7 = w_5 + _S931 * make_float3 (dt_11 * _S932.z);
        float3  th_3 = th_1 + w_7 * make_float3 (dt_11);
        if(support_0 == 2U)
        {
            reaction_0 = - f_14;
            u_1 = u_0;
            th_2 = _S889;
        }
        else
        {
            float3  v_13 = v_11 + f_14 * make_float3 (dt_11 * _S932.y);
            float3  u_2 = u_0 + v_13 * make_float3 (dt_11);
            reaction_0 = _S927;
            u_1 = u_2;
            th_2 = v_13;
        }
        float3  _S933 = th_2;
        th_2 = th_3;
        v_12 = _S933;
        w_6 = w_7;
    }
    *(&(globalParams_0->state_0)[_S898]) = make_float4 (u_1.x, u_1.y, u_1.z, peak_0);
    *(&(globalParams_0->state_0)[_S900]) = make_float4 (th_2.x, th_2.y, th_2.z, reaction_0.x);
    *(&(globalParams_0->state_0)[_S902]) = make_float4 (v_12.x, v_12.y, v_12.z, reaction_0.y);
    *(&(globalParams_0->state_0)[_S904]) = make_float4 (w_6.x, w_6.y, w_6.z, reaction_0.z);
    float3  _S934 = rotate_0(&rg_5->rot_0, _S907 + u_1 - _S909);
    float3  _S935 = rg_5->vel_1 + rg_5->vel_err_1 + cross_0(rg_5->w_4, _S934);
    float3  _S936 = rotate_0(&rg_5->rot_0, v_12);
    float3  v_world_0 = _S935 + _S936;
    float3  _S937 = rotate_0(&rg_5->rot_0, w_6);
    comp_add1_0(work_1, work_err_0, (dot_0(f_load_0, v_world_0) + dot_0(t_load_0, rg_5->w_4 + _S937)) * dt_11);
    return;
}

static __device__ void drift_moments_0(uint c_12, float3  * tu_0, float3  * pv_0)
{
    ChunkStatic_0 * _S938 = (&(globalParams_0->chunks_0)[c_12]);
    float4  _S939 = __ldg(&_S938->center_0);
    float _S940 = _S939.w;
    float4  _S941 = __ldg(&_S938->scale_0);
    float m_6 = _S940 * _S941.x;
    uint _S942 = 4U * c_12;
    float4  _S943 = *(&(globalParams_0->state_0)[_S942]);
    *tu_0 = *tu_0 + float3 {_S943.x, _S943.y, _S943.z} * make_float3 (m_6);
    float4  _S944 = *(&(globalParams_0->state_0)[_S942 + 2U]);
    *pv_0 = *pv_0 + float3 {_S944.x, _S944.y, _S944.z} * make_float3 (m_6);
    return;
}

static __device__ void drift_angular_0(uint c_13, float3  wcom_1, float3  tr_0, float3  dv_0, float3  * lu_0, float3  * lv_0)
{
    ChunkStatic_0 * _S945 = (&(globalParams_0->chunks_0)[c_13]);
    float4  _S946 = __ldg(&_S945->center_0);
    float3  r_9 = float3 {_S946.x, _S946.y, _S946.z} - wcom_1;
    float4  _S947 = __ldg(&_S945->scale_0);
    float kw_0 = _S947.x;
    uint _S948 = 4U * c_13;
    float4  _S949 = *(&(globalParams_0->state_0)[_S948]);
    float _S950 = _S946.w;
    float3  _S951 = cross_0(r_9, float3 {_S949.x, _S949.y, _S949.z} - tr_0) * make_float3 (_S950);
    float4  _S952 = __ldg(&_S945->inertia0_0);
    float4  _S953 = __ldg(&_S945->inertia1_0);
    float4  _S954 = __ldg(&_S945->inertia2_0);
    float4  _S955 = *(&(globalParams_0->state_0)[_S948 + 1U]);
    *lu_0 = *lu_0 + (_S951 + rows_mul_0(_S952, _S953, _S954, float3 {_S955.x, _S955.y, _S955.z})) * make_float3 (kw_0);
    float4  _S956 = *(&(globalParams_0->state_0)[_S948 + 2U]);
    float4  _S957 = *(&(globalParams_0->state_0)[_S948 + 3U]);
    *lv_0 = *lv_0 + (cross_0(r_9, float3 {_S956.x, _S956.y, _S956.z} - dv_0) * make_float3 (_S950) + rows_mul_0(_S952, _S953, _S954, float3 {_S957.x, _S957.y, _S957.z})) * make_float3 (kw_0);
    return;
}

static __device__ void drift_apply_0(uint c_14, float3  wcom_2, float3  tr_1, float3  phi_0, float3  dv_1, float3  dw_0)
{
    float4  _S958 = __ldg(&(&(globalParams_0->chunks_0)[c_14])->center_0);
    float3  r_10 = float3 {_S958.x, _S958.y, _S958.z} - wcom_2;
    uint _S959 = 4U * c_14;
    float4  _S960 = *(&(globalParams_0->state_0)[_S959]);
    *(&(globalParams_0->state_0)[_S959]) = make_float4 ((float3 {_S960.x, _S960.y, _S960.z} - (tr_1 + cross_0(phi_0, r_10))).x, (float3 {_S960.x, _S960.y, _S960.z} - (tr_1 + cross_0(phi_0, r_10))).y, (float3 {_S960.x, _S960.y, _S960.z} - (tr_1 + cross_0(phi_0, r_10))).z, (*(&(globalParams_0->state_0)[_S959])).w);
    uint _S961 = _S959 + 1U;
    float4  _S962 = *(&(globalParams_0->state_0)[_S961]);
    *(&(globalParams_0->state_0)[_S961]) = make_float4 ((float3 {_S962.x, _S962.y, _S962.z} - phi_0).x, (float3 {_S962.x, _S962.y, _S962.z} - phi_0).y, (float3 {_S962.x, _S962.y, _S962.z} - phi_0).z, (*(&(globalParams_0->state_0)[_S961])).w);
    uint _S963 = _S959 + 2U;
    float4  _S964 = *(&(globalParams_0->state_0)[_S963]);
    *(&(globalParams_0->state_0)[_S963]) = make_float4 ((float3 {_S964.x, _S964.y, _S964.z} - (dv_1 + cross_0(dw_0, r_10))).x, (float3 {_S964.x, _S964.y, _S964.z} - (dv_1 + cross_0(dw_0, r_10))).y, (float3 {_S964.x, _S964.y, _S964.z} - (dv_1 + cross_0(dw_0, r_10))).z, (*(&(globalParams_0->state_0)[_S963])).w);
    uint _S965 = _S959 + 3U;
    float4  _S966 = *(&(globalParams_0->state_0)[_S965]);
    *(&(globalParams_0->state_0)[_S965]) = make_float4 ((float3 {_S966.x, _S966.y, _S966.z} - dw_0).x, (float3 {_S966.x, _S966.y, _S966.z} - dw_0).y, (float3 {_S966.x, _S966.y, _S966.z} - dw_0).z, (*(&(globalParams_0->state_0)[_S965])).w);
    return;
}

static __device__ void turn_right_0(Quat_0 * hi_3, float4  * lo_3, float3  phi_1)
{
    float angle_4 = length_0(phi_1);
    if(angle_4 < 1.00000000317107685e-30f)
    {
        return;
    }
    float4  d_11 = turn_minus_one_0(phi_1 / make_float3 (angle_4), angle_4);
    Quat_0 dq_1;
    (&dq_1)->x_11 = d_11.x;
    (&dq_1)->y_4 = d_11.y;
    (&dq_1)->z_0 = d_11.z;
    (&dq_1)->w_1 = d_11.w;
    Quat_0 _S967 = *hi_3;
    Quat_0 _S968 = dq_1;
    Quat_0 _S969 = quat_mul_0(&_S967, &_S968);
    Quat_0 _S970 = _S969;
    float4  _S971 = quat_vec_0(&_S970);
    quat_accumulate_0(hi_3, lo_3, _S971);
    return;
}

static __device__ void drift_rigid_0(Island_0 * isl_7, Rigid_0 * rg_6, float3  tr_2, float3  phi_2, float3  dv_2, float3  dw_1)
{
    float4  _S972 = isl_7->wcom_0;
    float3  wcom_3 = float3 {_S972.x, _S972.y, _S972.z};
    Quat_0 rot_2 = rg_6->rot_0;
    float3  _S973 = tr_2 - cross_0(phi_2, wcom_3);
    Quat_0 _S974 = rg_6->rot_0;
    float3  _S975 = rotate_0(&_S974, _S973);
    comp_add_0(&rg_6->pos_1, &rg_6->pos_err_1, _S975);
    Quat_0 _S976 = rg_6->rot_0;
    float3  _S977 = inverse_rotate_0(&_S976, rg_6->w_4);
    float4  _S978 = isl_7->inertia0_1;
    float4  _S979 = isl_7->inertia1_1;
    float4  _S980 = isl_7->inertia2_1;
    float3  _S981 = cross_0(phi_2, rows_mul_0(isl_7->inertia0_1, isl_7->inertia1_1, isl_7->inertia2_1, _S977)) - rows_mul_0(isl_7->inertia0_1, isl_7->inertia1_1, isl_7->inertia2_1, cross_0(phi_2, _S977));
    Quat_0 _S982 = rg_6->rot_0;
    float3  _S983 = rotate_0(&_S982, _S981);
    turn_right_0(&rg_6->rot_0, &rg_6->rot_err_0, phi_2);
    float4  _S984 = isl_7->com_0;
    float3  _S985 = dv_2 + cross_0(dw_1, float3 {_S984.x, _S984.y, _S984.z} - wcom_3);
    Quat_0 _S986 = rot_2;
    float3  _S987 = rotate_0(&_S986, _S985);
    comp_add_0(&rg_6->vel_1, &rg_6->vel_err_1, _S987);
    Quat_0 _S988 = rot_2;
    float3  _S989 = rotate_0(&_S988, dw_1);
    rg_6->w_4 = rg_6->w_4 + _S989;
    Quat_0 _S990 = rg_6->rot_0;
    float3  _S991 = world_mul_0(&_S990, _S978, _S979, _S980, _S989);
    comp_add_0(&rg_6->l_2, &rg_6->l_err_1, _S983 + _S991);
    return;
}

static __device__ void contact_split_at_0(uint at_6)
{
    uint _S992 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint previous_1 = (&(globalParams_0->islands_0)[_S992])->info_1.y;
    uint _S993 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint _S994;
    if(previous_1 == 0U)
    {
        _S994 = at_6;
    }
    else
    {
        _S994 = (U32_min((previous_1), (at_6)));
    }
    *&((&(&(globalParams_0->islands_0)[_S993])->info_1)->y) = _S994;
    return;
}

static __device__ uint seen_bits_0()
{
    uint _S995;
    if(((*&g_seen_0)[0U]) != 0U)
    {
        _S995 = 32768U;
    }
    else
    {
        _S995 = 0U;
    }
    uint _S996;
    if(((*&g_seen_0)[1U]) != 0U)
    {
        _S996 = 65536U;
    }
    else
    {
        _S996 = 0U;
    }
    uint _S997 = _S995 | _S996;
    if(((*&g_seen_0)[2U]) != 0U)
    {
        _S995 = 131072U;
    }
    else
    {
        _S995 = 0U;
    }
    uint _S998 = _S997 | _S995;
    if(((*&g_seen_0)[3U]) != 0U)
    {
        _S995 = 32U;
    }
    else
    {
        _S995 = 0U;
    }
    uint _S999 = _S998 | _S995;
    if(((*&g_seen_0)[4U]) != 0U)
    {
        _S995 = 64U;
    }
    else
    {
        _S995 = 0U;
    }
    return _S999 | _S995;
}

extern "C" __global__ void island_frame()
{
    bool woke_0;
    uint _S1000;
    uint _S1001;
    uint _S1002;
    uint _S1003;
    uint _S1004;
    uint _S1005;
    uint _S1006;
    uint _S1007 = __ballot_sync(4294967295U, true);
    uint tid_5 = threadIdx.x;
    uint _S1008 = blockIdx.x;
    Island_0 isl_8 = *(&(globalParams_0->islands_0)[_S1008]);
    bool driven_0 = (((&isl_8)->info_1.x) & 2U) != 0U;
    bool _S1009 = !((((&isl_8)->info_1.x) & 1U) != 0U);
    uint _S1010 = __ballot_sync(_S1007, _S1009);
    bool _S1011;
    uint cov_0;
    if(_S1009)
    {
        bool _S1012 = !driven_0;
        uint _S1013 = __ballot_sync(_S1007, true);
        _S1011 = _S1012;
        cov_0 = _S1013;
    }
    else
    {
        uint _S1014 = __ballot_sync(_S1007, true);
        _S1011 = false;
        cov_0 = _S1014;
    }
    bool contact_island_0 = (((&isl_8)->info_1.x) & 4U) != 0U;
    bool _S1015 = (((&isl_8)->info_1.x) & 16U) != 0U;
    seen_clear_0(tid_5);
    bool _S1016 = tid_5 == 0U;
    uint _S1017 = __ballot_sync(cov_0, _S1016);
    bool settled_0;
    uint run_0;
    uint done_1;
    if(_S1016)
    {
        uint _S1018 = __ldg(&globalParams_0->params_0->contact_mode_0);
        bool _S1019 = contact_island_0 != (_S1018 == 1U);
        uint _S1020 = __ballot_sync(_S1017, _S1019);
        if(_S1019)
        {
            uint _S1021 = __ballot_sync(_S1017, true);
            settled_0 = true;
            run_0 = _S1021;
        }
        else
        {
            bool _S1022 = (((&isl_8)->info_1.x) & 8U) != 0U;
            uint _S1023 = __ballot_sync(_S1017, true);
            settled_0 = _S1022;
            run_0 = _S1023;
        }
        uint _S1024 = __ballot_sync(run_0, settled_0);
        if(settled_0)
        {
            uint _S1025 = __ballot_sync(run_0, true);
            run_0 = 0U;
            done_1 = _S1025;
        }
        else
        {
            uint _S1026 = __ballot_sync(run_0, true);
            run_0 = 1U;
            done_1 = _S1026;
        }
        uint _S1027 = __ballot_sync(done_1, contact_island_0);
        if(contact_island_0)
        {
            Island_0 _S1028 = isl_8;
            bool _S1029 = contact_stopped_0(&_S1028);
            uint _S1030 = __ballot_sync(done_1, true);
            settled_0 = _S1029;
            done_1 = _S1030;
        }
        else
        {
            uint _S1031 = __ballot_sync(done_1, true);
            settled_0 = false;
            done_1 = _S1031;
        }
        uint _S1032 = __ballot_sync(done_1, settled_0);
        if(settled_0)
        {
            uint _S1033 = __ballot_sync(done_1, true);
            run_0 = 0U;
        }
        else
        {
            uint _S1034 = __ballot_sync(done_1, true);
        }
        *&g_run_0 = run_0;
        *&g_halt_0 = 0U;
        uint _S1035 = __ballot_sync(cov_0, true);
        cov_0 = _S1035;
    }
    else
    {
        uint _S1036 = __ballot_sync(cov_0, true);
        cov_0 = _S1036;
    }
    __syncthreads();
    bool _S1037 = (((&isl_8)->info_1.z) & 1U) != 0U;
    uint _S1038 = __ballot_sync(cov_0, _S1037);
    if(_S1037)
    {
        uint _S1039 = __ballot_sync(cov_0, true);
        settled_0 = true;
        cov_0 = _S1039;
    }
    else
    {
        bool _S1040 = (*&g_run_0) == 0U;
        uint _S1041 = __ballot_sync(cov_0, true);
        settled_0 = _S1040;
        cov_0 = _S1041;
    }
    uint _S1042 = __ballot_sync(cov_0, settled_0);
    if(settled_0)
    {
        uint _S1043 = __ballot_sync(cov_0, true);
        cov_0 = 0U;
        run_0 = _S1043;
    }
    else
    {
        uint _S1044 = (&isl_8)->info_1.y;
        uint _S1045 = __ldg(&globalParams_0->params_0->max_steps_0);
        uint _S1046 = (U32_min((_S1044), (_S1045)));
        uint _S1047 = __ballot_sync(cov_0, true);
        cov_0 = _S1046;
        run_0 = _S1047;
    }
    float _S1048 = __ldg(&globalParams_0->params_0->dt_0);
    uint _S1049 = __ldg(&globalParams_0->params_0->fracture_0);
    bool _S1050 = _S1049 != 0U;
    uint _S1051 = __ldg(&globalParams_0->params_0->rigid_motion_loads_0);
    bool _S1052 = _S1051 != 0U;
    Island_0 _S1053 = isl_8;
    Rigid_0 _S1054 = rigid_of_0(&_S1053);
    Rigid_0 rg_7 = _S1054;
    float work_2 = 0.0f;
    float work_err_1 = 0.0f;
    settled_0 = _S1015;
    done_1 = 0U;
    bool woke_1 = false;
    uint s_7 = 0U;
    uint _S1055 = run_0;
    for(;;)
    {
        uint _S1056 = 0U;
        bool _S1057 = s_7 < cov_0;
        uint _S1058 = __ballot_sync(_S1055, _S1057);
        if(_S1057)
        {
            uint _S1059 = __ballot_sync(_S1055, true);
            _S1056 = _S1059;
        }
        else
        {
            uint _S1060 = __ballot_sync(_S1055, false);
            uint _S1061 = __ballot_sync(_S1055, false);
            uint _S1062 = __ballot_sync(run_0, true);
            woke_0 = woke_1;
            cov_0 = _S1062;
            break;
        }
        uint _S1063 = 0U;
        uint abs_step_1 = (&isl_8)->info_1.w + s_7 + 1U;
        uint _S1064 = abs_step_1 - 1U;
        uint _S1065 = __ldg(&globalParams_0->params_0->step_start_0);
        uint k_18 = _S1064 - _S1065;
        bool _S1066 = (((&isl_8)->info_1.x) & 32U) != 0U;
        uint _S1067 = __ballot_sync(_S1056, _S1066);
        bool _S1068;
        bool settled_1;
        uint c_15;
        if(_S1066)
        {
            uint _S1069 = __ballot_sync(_S1067, _S1016);
            if(_S1016)
            {
                bool _S1070 = ((&isl_8)->probes_0.y) > ((&isl_8)->probes_0.x);
                uint _S1071 = __ballot_sync(_S1067, true);
                _S1068 = _S1070;
                c_15 = _S1071;
            }
            else
            {
                uint _S1072 = __ballot_sync(_S1067, true);
                _S1068 = false;
                c_15 = _S1072;
            }
            uint _S1073 = __ballot_sync(c_15, _S1068);
            if(_S1068)
            {
                Island_0 _S1074 = isl_8;
                Rigid_0 _S1075 = rg_7;
                record_probes_0(&_S1074, &_S1075, k_18);
                uint _S1076 = __ballot_sync(c_15, true);
            }
            else
            {
                uint _S1077 = __ballot_sync(c_15, true);
            }
            uint _S1078 = s_7 + 1U;
            uint _S1079 = __ballot_sync(_S1056, false);
            uint _S1080 = __ballot_sync(_S1055, true);
            settled_1 = settled_0;
            done_1 = _S1078;
            woke_0 = woke_1;
            _S1055 = _S1080;
            uint _S1081 = s_7 + 1U;
            settled_0 = settled_1;
            woke_1 = woke_0;
            s_7 = _S1081;
            continue;
        }
        else
        {
            uint _S1082 = __ballot_sync(_S1056, true);
            _S1063 = _S1082;
        }
        uint _S1083 = __ballot_sync(_S1063, settled_0);
        uint c_16;
        uint i_16;
        if(settled_0)
        {
            float3  _S1084 = make_float3 (0.0f);
            float3  norm_0 = _S1084;
            float3  unused0_0 = _S1084;
            c_15 = (&isl_8)->range_0.x + tid_5;
            c_16 = _S1083;
            for(;;)
            {
                bool _S1085 = c_15 < ((&isl_8)->range_0.y);
                uint _S1086 = __ballot_sync(c_16, _S1085);
                if(_S1085)
                {
                    uint _S1087 = __ballot_sync(c_16, true);
                }
                else
                {
                    uint _S1088 = __ballot_sync(c_16, false);
                    uint _S1089 = __ballot_sync(c_16, false);
                    uint _S1090 = __ballot_sync(_S1083, true);
                    _S1000 = _S1090;
                    break;
                }
                Quat_0 _S1091 = (&rg_7)->rot_0;
                float _S1092 = settled_chunk_load_0(c_15, &_S1091, k_18, _S1048, contact_island_0);
                *&((&norm_0)->x) = *&((&norm_0)->x) + _S1092;
                uint _S1093 = __ballot_sync(c_16, true);
                c_15 = c_15 + 256U;
                c_16 = _S1093;
            }
            group_sum3_0(tid_5, &norm_0, &unused0_0, _S1000);
            uint _S1094 = __ldg(&globalParams_0->params_0->solve_mode_0);
            bool _S1095 = _S1094 == 1U;
            uint _S1096 = __ballot_sync(_S1000, _S1095);
            if(_S1095)
            {
                bool _S1097 = (F32_abs((norm_0.x - (&isl_8)->energy_1.z))) > ((&isl_8)->energy_1.w);
                uint _S1098 = __ballot_sync(_S1000, true);
                _S1068 = _S1097;
                i_16 = _S1098;
            }
            else
            {
                uint _S1099 = __ballot_sync(_S1000, true);
                _S1068 = false;
                i_16 = _S1099;
            }
            uint _S1100 = __ballot_sync(i_16, _S1068);
            if(_S1068)
            {
                uint _S1101 = __ballot_sync(i_16, true);
                settled_1 = false;
                woke_0 = true;
            }
            else
            {
                uint _S1102 = __ballot_sync(i_16, true);
                settled_1 = settled_0;
                woke_0 = woke_1;
            }
            uint _S1103 = __ballot_sync(_S1063, true);
            c_15 = _S1103;
        }
        else
        {
            uint _S1104 = __ballot_sync(_S1063, true);
            settled_1 = settled_0;
            woke_0 = woke_1;
            c_15 = _S1104;
        }
        uint _S1105 = __ballot_sync(c_15, _S1009);
        if(_S1009)
        {
            float3  _S1106 = make_float3 (0.0f);
            float3  f_15 = _S1106;
            float3  t_12 = _S1106;
            c_16 = (&isl_8)->range_0.x + tid_5;
            i_16 = _S1105;
            for(;;)
            {
                bool _S1107 = c_16 < ((&isl_8)->range_0.y);
                uint _S1108 = __ballot_sync(i_16, _S1107);
                if(_S1107)
                {
                    uint _S1109 = __ballot_sync(i_16, true);
                }
                else
                {
                    uint _S1110 = __ballot_sync(i_16, false);
                    uint _S1111 = __ballot_sync(i_16, false);
                    uint _S1112 = __ballot_sync(_S1105, true);
                    _S1001 = _S1112;
                    break;
                }
                Island_0 _S1113 = isl_8;
                Rigid_0 _S1114 = rg_7;
                net_load_0(c_16, &_S1113, &_S1114, k_18, _S1048, contact_island_0, &f_15, &t_12);
                uint _S1115 = __ballot_sync(i_16, true);
                c_16 = c_16 + 256U;
                i_16 = _S1115;
            }
            group_sum3_0(tid_5, &f_15, &t_12, _S1001);
            Island_0 _S1116 = isl_8;
            rigid_acceleration_0(&_S1116, &rg_7, f_15, t_12);
            uint _S1117 = __ballot_sync(c_15, true);
            c_16 = _S1117;
        }
        else
        {
            uint _S1118 = __ballot_sync(c_15, true);
            c_16 = _S1118;
        }
        uint _S1119 = 0U;
        uint _S1120 = __ballot_sync(c_16, settled_1);
        uint _S1121;
        if(settled_1)
        {
            uint _S1122 = __ballot_sync(_S1120, _S1011);
            if(_S1011)
            {
                Island_0 _S1123 = isl_8;
                integrate_rigid_0(&_S1123, &rg_7, _S1048);
                uint _S1124 = __ballot_sync(_S1120, true);
                i_16 = _S1124;
            }
            else
            {
                uint _S1125 = __ballot_sync(_S1120, true);
                i_16 = _S1125;
            }
            uint _S1126 = __ballot_sync(i_16, _S1016);
            if(_S1016)
            {
                bool _S1127 = ((&isl_8)->probes_0.y) > ((&isl_8)->probes_0.x);
                uint _S1128 = __ballot_sync(i_16, true);
                _S1068 = _S1127;
                _S1121 = _S1128;
            }
            else
            {
                uint _S1129 = __ballot_sync(i_16, true);
                _S1068 = false;
                _S1121 = _S1129;
            }
            uint _S1130 = __ballot_sync(_S1121, _S1068);
            if(_S1068)
            {
                Island_0 _S1131 = isl_8;
                Rigid_0 _S1132 = rg_7;
                record_probes_0(&_S1131, &_S1132, k_18);
                uint _S1133 = __ballot_sync(_S1121, true);
            }
            else
            {
                uint _S1134 = __ballot_sync(_S1121, true);
            }
            uint _S1135 = s_7 + 1U;
            uint _S1136 = __ballot_sync(c_16, false);
            uint _S1137 = __ballot_sync(_S1055, true);
            done_1 = _S1135;
            _S1055 = _S1137;
            uint _S1081 = s_7 + 1U;
            settled_0 = settled_1;
            woke_1 = woke_0;
            s_7 = _S1081;
            continue;
        }
        else
        {
            uint _S1138 = __ballot_sync(c_16, true);
            _S1119 = _S1138;
        }
        i_16 = (&isl_8)->range_0.z + tid_5;
        _S1121 = _S1119;
        for(;;)
        {
            uint _S1139 = 0U;
            bool _S1140 = i_16 < ((&isl_8)->range_0.w);
            uint _S1141 = __ballot_sync(_S1121, _S1140);
            if(_S1140)
            {
                uint _S1142 = __ballot_sync(_S1121, true);
                _S1139 = _S1142;
            }
            else
            {
                uint _S1143 = __ballot_sync(_S1121, false);
                uint _S1144 = __ballot_sync(_S1121, false);
                uint _S1145 = __ballot_sync(_S1119, true);
                _S1002 = _S1145;
                break;
            }
            bool _S1146 = bond_update_0(i_16, _S1048, _S1050, abs_step_1, false);
            uint _S1147 = __ballot_sync(_S1139, _S1146);
            if(_S1146)
            {
                *&g_halt_0 = 1U;
                uint _S1148 = __ballot_sync(_S1139, true);
            }
            else
            {
                uint _S1149 = __ballot_sync(_S1139, true);
            }
            uint _S1150 = __ballot_sync(_S1121, true);
            i_16 = i_16 + 256U;
            _S1121 = _S1150;
        }
        __syncthreads();
        uint c_17 = (&isl_8)->range_0.x + tid_5;
        uint _S1151 = _S1002;
        for(;;)
        {
            bool _S1152 = c_17 < ((&isl_8)->range_0.y);
            uint _S1153 = __ballot_sync(_S1151, _S1152);
            if(_S1152)
            {
                uint _S1154 = __ballot_sync(_S1151, true);
            }
            else
            {
                uint _S1155 = __ballot_sync(_S1151, false);
                uint _S1156 = __ballot_sync(_S1151, false);
                uint _S1157 = __ballot_sync(_S1002, true);
                _S1003 = _S1157;
                break;
            }
            Island_0 _S1158 = isl_8;
            Rigid_0 _S1159 = rg_7;
            chunk_update_0(c_17, &_S1158, &_S1159, _S1048, _S1052, k_18, contact_island_0, &work_2, &work_err_1);
            uint _S1160 = __ballot_sync(_S1151, true);
            c_17 = c_17 + 256U;
            _S1151 = _S1160;
        }
        __syncthreads();
        uint _S1161 = __ballot_sync(_S1003, _S1011);
        uint _S1162;
        if(_S1011)
        {
            Island_0 _S1163 = isl_8;
            integrate_rigid_0(&_S1163, &rg_7, _S1048);
            uint _S1164 = __ballot_sync(_S1003, true);
            _S1162 = _S1164;
        }
        else
        {
            uint _S1165 = __ballot_sync(_S1003, true);
            _S1162 = _S1165;
        }
        uint _S1166 = __ballot_sync(_S1162, _S1009);
        uint c_18;
        uint _S1167;
        uint c_19;
        if(_S1009)
        {
            float4  _S1168 = (&isl_8)->wcom_0;
            float3  _S1169 = float3 {_S1168.x, _S1168.y, _S1168.z};
            float3  _S1170 = make_float3 (0.0f);
            float3  tu_1 = _S1170;
            float3  pv_1 = _S1170;
            c_18 = (&isl_8)->range_0.x + tid_5;
            _S1167 = _S1166;
            for(;;)
            {
                bool _S1171 = c_18 < ((&isl_8)->range_0.y);
                uint _S1172 = __ballot_sync(_S1167, _S1171);
                if(_S1171)
                {
                    uint _S1173 = __ballot_sync(_S1167, true);
                }
                else
                {
                    uint _S1174 = __ballot_sync(_S1167, false);
                    uint _S1175 = __ballot_sync(_S1167, false);
                    uint _S1176 = __ballot_sync(_S1166, true);
                    _S1004 = _S1176;
                    break;
                }
                drift_moments_0(c_18, &tu_1, &pv_1);
                uint _S1177 = __ballot_sync(_S1167, true);
                c_18 = c_18 + 256U;
                _S1167 = _S1177;
            }
            group_sum3_0(tid_5, &tu_1, &pv_1, _S1004);
            float3  tr_3 = tu_1 / make_float3 ((&isl_8)->wcom_0.w);
            float3  dv_3 = pv_1 / make_float3 ((&isl_8)->wcom_0.w);
            float3  lu_1 = _S1170;
            float3  lv_1 = _S1170;
            c_19 = (&isl_8)->range_0.x + tid_5;
            uint _S1178 = _S1004;
            for(;;)
            {
                bool _S1179 = c_19 < ((&isl_8)->range_0.y);
                uint _S1180 = __ballot_sync(_S1178, _S1179);
                if(_S1179)
                {
                    uint _S1181 = __ballot_sync(_S1178, true);
                }
                else
                {
                    uint _S1182 = __ballot_sync(_S1178, false);
                    uint _S1183 = __ballot_sync(_S1178, false);
                    uint _S1184 = __ballot_sync(_S1004, true);
                    _S1005 = _S1184;
                    break;
                }
                drift_angular_0(c_19, _S1169, tr_3, dv_3, &lu_1, &lv_1);
                uint _S1185 = __ballot_sync(_S1178, true);
                c_19 = c_19 + 256U;
                _S1178 = _S1185;
            }
            group_sum3_0(tid_5, &lu_1, &lv_1, _S1005);
            float3  phi_3 = rows_mul_0((&isl_8)->winv0_0, (&isl_8)->winv1_0, (&isl_8)->winv2_0, lu_1);
            float3  dw_2 = rows_mul_0((&isl_8)->winv0_0, (&isl_8)->winv1_0, (&isl_8)->winv2_0, lv_1);
            uint c_20 = (&isl_8)->range_0.x + tid_5;
            uint _S1186 = _S1005;
            for(;;)
            {
                bool _S1187 = c_20 < ((&isl_8)->range_0.y);
                uint _S1188 = __ballot_sync(_S1186, _S1187);
                if(_S1187)
                {
                    uint _S1189 = __ballot_sync(_S1186, true);
                }
                else
                {
                    uint _S1190 = __ballot_sync(_S1186, false);
                    uint _S1191 = __ballot_sync(_S1186, false);
                    uint _S1192 = __ballot_sync(_S1005, true);
                    _S1006 = _S1192;
                    break;
                }
                drift_apply_0(c_20, _S1169, tr_3, phi_3, dv_3, dw_2);
                uint _S1193 = __ballot_sync(_S1186, true);
                c_20 = c_20 + 256U;
                _S1186 = _S1193;
            }
            bool _S1194 = !driven_0;
            uint _S1195 = __ballot_sync(_S1006, _S1194);
            if(_S1194)
            {
                Island_0 _S1196 = isl_8;
                drift_rigid_0(&_S1196, &rg_7, tr_3, phi_3, dv_3, dw_2);
                uint _S1197 = __ballot_sync(_S1006, true);
            }
            else
            {
                uint _S1198 = __ballot_sync(_S1006, true);
            }
            __syncthreads();
            uint _S1199 = __ballot_sync(_S1162, true);
            c_18 = _S1199;
        }
        else
        {
            uint _S1200 = __ballot_sync(_S1162, true);
            c_18 = _S1200;
        }
        uint _S1201 = __ballot_sync(c_18, _S1016);
        if(_S1016)
        {
            bool _S1202 = ((&isl_8)->probes_0.y) > ((&isl_8)->probes_0.x);
            uint _S1203 = __ballot_sync(c_18, true);
            _S1068 = _S1202;
            _S1167 = _S1203;
        }
        else
        {
            uint _S1204 = __ballot_sync(c_18, true);
            _S1068 = false;
            _S1167 = _S1204;
        }
        uint _S1205 = __ballot_sync(_S1167, _S1068);
        if(_S1068)
        {
            Island_0 _S1206 = isl_8;
            Rigid_0 _S1207 = rg_7;
            record_probes_0(&_S1206, &_S1207, k_18);
            uint _S1208 = __ballot_sync(_S1167, true);
            c_19 = _S1208;
        }
        else
        {
            uint _S1209 = __ballot_sync(_S1167, true);
            c_19 = _S1209;
        }
        uint _S1210 = s_7 + 1U;
        bool _S1211 = (*&g_halt_0) != 0U;
        uint _S1212 = __ballot_sync(c_19, _S1211);
        if(_S1211)
        {
            uint _S1213 = __ballot_sync(c_19, false);
            uint _S1214 = __ballot_sync(_S1055, false);
            uint _S1215 = __ballot_sync(run_0, true);
            done_1 = _S1210;
            cov_0 = _S1215;
            break;
        }
        else
        {
            uint _S1216 = __ballot_sync(c_19, true);
        }
        uint _S1217 = __ballot_sync(_S1055, true);
        done_1 = _S1210;
        _S1055 = _S1217;
        uint _S1081 = s_7 + 1U;
        settled_0 = settled_1;
        woke_1 = woke_0;
        s_7 = _S1081;
    }
    float3  wsum_0 = make_float3 (work_2, work_err_1, 0.0f);
    float3  unused_1 = make_float3 (0.0f);
    group_sum3_0(tid_5, &wsum_0, &unused_1, cov_0);
    uint _S1218 = __ballot_sync(cov_0, _S1016);
    if(_S1016)
    {
        Quat_0 _S1219 = (&rg_7)->rot_0;
        float4  _S1220 = quat_vec_0(&_S1219);
        (&isl_8)->rotation_0 = _S1220;
        (&isl_8)->rotation_err_0 = (&rg_7)->rot_err_0;
        (&isl_8)->position_0 = make_float4 ((&rg_7)->pos_1.x, (&rg_7)->pos_1.y, (&rg_7)->pos_1.z, 0.0f);
        (&isl_8)->position_err_0 = make_float4 ((&rg_7)->pos_err_1.x, (&rg_7)->pos_err_1.y, (&rg_7)->pos_err_1.z, 0.0f);
        (&isl_8)->velocity_0 = make_float4 ((&rg_7)->vel_1.x, (&rg_7)->vel_1.y, (&rg_7)->vel_1.z, 0.0f);
        (&isl_8)->velocity_err_0 = make_float4 ((&rg_7)->vel_err_1.x, (&rg_7)->vel_err_1.y, (&rg_7)->vel_err_1.z, 0.0f);
        (&isl_8)->angular_velocity_0 = make_float4 ((&rg_7)->w_4.x, (&rg_7)->w_4.y, (&rg_7)->w_4.z, 0.0f);
        (&isl_8)->momentum_0 = make_float4 ((&rg_7)->l_2.x, (&rg_7)->l_2.y, (&rg_7)->l_2.z, 0.0f);
        (&isl_8)->momentum_err_0 = make_float4 ((&rg_7)->l_err_1.x, (&rg_7)->l_err_1.y, (&rg_7)->l_err_1.z, 0.0f);
        (&isl_8)->done_0 = done_1;
        *&((&(&isl_8)->info_1)->y) = *&((&(&isl_8)->info_1)->y) - done_1;
        if((*&g_halt_0) != 0U)
        {
            _S1011 = contact_island_0;
        }
        else
        {
            _S1011 = false;
        }
        if(_S1011)
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
        uint _S1221 = seen_bits_0();
        if((*&g_halt_0) != 0U)
        {
            cov_0 = 128U;
        }
        else
        {
            cov_0 = 0U;
        }
        uint _S1222 = _S1221 | cov_0;
        if(woke_0)
        {
            cov_0 = 2048U;
        }
        else
        {
            cov_0 = 0U;
        }
        uint cov_1 = _S1222 | cov_0;
        if(done_1 > 0U)
        {
            bool quiet_0 = (((&isl_8)->info_1.x) & 32U) != 0U;
            if(quiet_0)
            {
                cov_0 = 4096U;
            }
            else
            {
                cov_0 = 0U;
            }
            uint cov_2 = cov_1 | cov_0;
            if((((&isl_8)->info_1.x) & 16U) != 0U)
            {
                _S1011 = !quiet_0;
            }
            else
            {
                _S1011 = false;
            }
            if(_S1011)
            {
                cov_0 = 512U;
            }
            else
            {
                cov_0 = 0U;
            }
            uint cov_3 = cov_2 | cov_0;
            uint _S1223 = __ldg(&globalParams_0->params_0->contact_mode_0);
            if(_S1223 == 1U)
            {
                cov_0 = 524288U;
            }
            else
            {
                cov_0 = 0U;
            }
            uint cov_4 = cov_3 | cov_0;
            if(((&isl_8)->probes_0.y) > ((&isl_8)->probes_0.x))
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
        (&isl_8)->coverage_0 = ((&isl_8)->coverage_0) | cov_0;
        if(woke_0)
        {
            *&((&(&isl_8)->info_1)->x) = (*&((&(&isl_8)->info_1)->x)) & 4294967279U;
            *&((&(&isl_8)->info_1)->z) = (*&((&(&isl_8)->info_1)->z)) | 4U;
        }
        *(&(globalParams_0->islands_0)[_S1008]) = isl_8;
    }
    return;
}

struct WideGroup_0
{
    uint island_2;
    uint begin_0;
    uint end_0;
    uint first_0;
};

static __device__ WideGroup_0 wide_group_0(uint table_0, uint g_3)
{
    WideGroup_0 w_8;
    uint _S1224 = table_0 + 4U * g_3;
    uint _S1225 = __ldg((&(globalParams_0->index_0)[_S1224]));
    (&w_8)->island_2 = _S1225;
    uint _S1226 = __ldg((&(globalParams_0->index_0)[_S1224 + 1U]));
    (&w_8)->begin_0 = _S1226;
    uint _S1227 = __ldg((&(globalParams_0->index_0)[_S1224 + 2U]));
    (&w_8)->end_0 = _S1227;
    uint _S1228 = __ldg((&(globalParams_0->index_0)[_S1224 + 3U]));
    (&w_8)->first_0 = _S1228;
    return w_8;
}

static __device__ bool wide_runs_0(Island_0 * isl_9)
{
    uint4  _S1229 = isl_9->info_1;
    bool _S1230;
    if(((isl_9->info_1.z) & 1U) != 0U)
    {
        _S1230 = true;
    }
    else
    {
        _S1230 = (_S1229.y) == 0U;
    }
    if(_S1230)
    {
        return false;
    }
    if(((_S1229.x) & 4U) == 0U)
    {
        _S1230 = true;
    }
    else
    {
        bool _S1231 = contact_stopped_0(isl_9);
        _S1230 = !_S1231;
    }
    return _S1230;
}

__device__ __shared__ uint g_wide_run_0;

static __device__ bool wide_enter_0(uint tid_6, Island_0 * isl_10)
{
    seen_clear_0(tid_6);
    if(tid_6 == 0U)
    {
        bool _S1232 = wide_runs_0(isl_10);
        int _S1233;
        if(_S1232)
        {
            _S1233 = int(1);
        }
        else
        {
            _S1233 = int(0);
        }
        *&g_wide_run_0 = uint(_S1233);
    }
    __syncthreads();
    return (*&g_wide_run_0) != 0U;
}

static __device__ uint wide_step_0(Island_0 * isl_11)
{
    uint _S1234 = isl_11->info_1.w;
    uint _S1235 = __ldg(&globalParams_0->params_0->step_start_0);
    return _S1234 - _S1235;
}

static __device__ bool wide_enter_1(uint _S1236, uint _S1237)
{
    Island_0 _S1238 = *(&(globalParams_0->islands_0)[_S1237]);
    seen_clear_0(_S1236);
    if(_S1236 == 0U)
    {
        Island_0 _S1239 = _S1238;
        bool _S1240 = wide_runs_0(&_S1239);
        int _S1241;
        if(_S1240)
        {
            _S1241 = int(1);
        }
        else
        {
            _S1241 = int(0);
        }
        *&g_wide_run_0 = uint(_S1241);
    }
    __syncthreads();
    return (*&g_wide_run_0) != 0U;
}

extern "C" __global__ void wide_wake()
{
    uint _S1242 = 0U;
    uint _S1243;
    uint _S1244 = __ballot_sync(4294967295U, true);
    uint tid_7 = threadIdx.x;
    uint _S1245 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1246 = blockIdx.x;
    WideGroup_0 wg_0 = wide_group_0(_S1245, _S1246);
    bool _S1247 = _S1246 != (wg_0.first_0);
    uint _S1248 = __ballot_sync(_S1244, _S1247);
    if(_S1247)
    {
        return;
    }
    else
    {
        uint _S1249 = __ballot_sync(_S1244, true);
        _S1242 = _S1249;
    }
    Island_0 * _S1250 = (&(globalParams_0->islands_0)[wg_0.island_2]);
    Island_0 isl_12 = *_S1250;
    uint _S1251 = (*_S1250).info_1.x;
    bool _S1252 = (_S1251 & 16U) == 0U;
    uint _S1253 = __ballot_sync(_S1242, _S1252);
    bool _S1254;
    uint c_21;
    if(_S1252)
    {
        uint _S1255 = __ballot_sync(_S1242, true);
        _S1254 = true;
        c_21 = _S1255;
    }
    else
    {
        bool _S1256 = wide_enter_1(tid_7, wg_0.island_2);
        bool _S1257 = !_S1256;
        uint _S1258 = __ballot_sync(_S1242, true);
        _S1254 = _S1257;
        c_21 = _S1258;
    }
    uint _S1259 = 0U;
    uint _S1260 = __ballot_sync(c_21, _S1254);
    if(_S1254)
    {
        return;
    }
    else
    {
        uint _S1261 = __ballot_sync(c_21, true);
        _S1259 = _S1261;
    }
    Quat_0 _S1262 = quat_of_0(isl_12.rotation_0);
    bool _S1263 = (_S1251 & 4U) != 0U;
    float3  _S1264 = make_float3 (0.0f);
    float3  norm_1 = _S1264;
    float3  unused_2 = _S1264;
    c_21 = isl_12.range_0.x + tid_7;
    uint cov_5;
    cov_5 = _S1259;
    for(;;)
    {
        bool _S1265 = c_21 < (isl_12.range_0.y);
        uint _S1266 = __ballot_sync(cov_5, _S1265);
        if(_S1265)
        {
            uint _S1267 = __ballot_sync(cov_5, true);
        }
        else
        {
            uint _S1268 = __ballot_sync(cov_5, false);
            uint _S1269 = __ballot_sync(cov_5, false);
            uint _S1270 = __ballot_sync(_S1259, true);
            _S1243 = _S1270;
            break;
        }
        Island_0 _S1271 = isl_12;
        uint _S1272 = wide_step_0(&_S1271);
        float _S1273 = __ldg(&globalParams_0->params_0->dt_0);
        Quat_0 _S1274 = _S1262;
        float _S1275 = settled_chunk_load_0(c_21, &_S1274, _S1272, _S1273, _S1263);
        *&((&norm_1)->x) = *&((&norm_1)->x) + _S1275;
        uint _S1276 = __ballot_sync(cov_5, true);
        c_21 = c_21 + 256U;
        cov_5 = _S1276;
    }
    group_sum3_0(tid_7, &norm_1, &unused_2, _S1243);
    bool _S1277 = tid_7 != 0U;
    uint _S1278 = __ballot_sync(_S1243, _S1277);
    if(_S1277)
    {
        return;
    }
    uint cov_6 = 1024U | (seen_bits_0());
    uint _S1279 = __ldg(&globalParams_0->params_0->solve_mode_0);
    if(_S1279 == 1U)
    {
        _S1254 = (F32_abs((norm_1.x - isl_12.energy_1.z))) > (isl_12.energy_1.w);
    }
    else
    {
        _S1254 = false;
    }
    if(_S1254)
    {
        *&((&(&(globalParams_0->islands_0)[wg_0.island_2])->info_1)->x) = _S1251 & 4294967279U;
        *&((&(&(globalParams_0->islands_0)[wg_0.island_2])->info_1)->z) = (isl_12.info_1.z) | 4U;
        cov_5 = cov_6 | 2048U;
    }
    else
    {
        cov_5 = cov_6;
    }
    cov_mark_0(wg_0.island_2, isl_12.coverage_0, cov_5);
    return;
}

static __device__ void wide_store_0(uint slot_1, uint p_12, float3  a_15, float3  b_30)
{
    uint _S1280 = __ldg(&globalParams_0->params_0->wide_base_0);
    uint _S1281 = 8U * slot_1;
    *(&(globalParams_0->scratch_0)[_S1280 + _S1281 + p_12]) = make_float4 (a_15.x, a_15.y, a_15.z, 0.0f);
    uint _S1282 = __ldg(&globalParams_0->params_0->wide_base_0);
    *(&(globalParams_0->scratch_0)[_S1282 + _S1281 + p_12 + 1U]) = make_float4 (b_30.x, b_30.y, b_30.z, 0.0f);
    return;
}

extern "C" __global__ void wide_bonds()
{
    uint _S1283 = __ballot_sync(4294967295U, true);
    uint tid_8 = threadIdx.x;
    uint _S1284 = blockIdx.x;
    uint _S1285 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
    bool bond_group_0 = _S1284 < _S1285;
    uint _S1286 = __ballot_sync(_S1283, bond_group_0);
    WideGroup_0 wg_1;
    uint _S1287;
    if(bond_group_0)
    {
        uint _S1288 = __ldg(&globalParams_0->params_0->wide_bond_table_0);
        WideGroup_0 _S1289 = wide_group_0(_S1288, _S1284);
        uint _S1290 = __ballot_sync(_S1283, true);
        wg_1 = _S1289;
        _S1287 = _S1290;
    }
    else
    {
        uint _S1291 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
        uint _S1292 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
        WideGroup_0 _S1293 = wide_group_0(_S1291, _S1284 - _S1292);
        uint _S1294 = __ballot_sync(_S1283, true);
        wg_1 = _S1293;
        _S1287 = _S1294;
    }
    uint _S1295 = 0U;
    WideGroup_0 _S1296 = wg_1;
    Island_0 isl_13 = *(&(globalParams_0->islands_0)[wg_1.island_2]);
    bool _S1297 = wide_enter_1(tid_8, wg_1.island_2);
    bool _S1298 = !_S1297;
    uint _S1299 = __ballot_sync(_S1287, _S1298);
    if(_S1298)
    {
        return;
    }
    else
    {
        uint _S1300 = __ballot_sync(_S1287, true);
        _S1295 = _S1300;
    }
    uint _S1301 = 0U;
    Island_0 _S1302 = isl_13;
    uint _S1303 = wide_step_0(&_S1302);
    uint _S1304 = __ballot_sync(_S1295, bond_group_0);
    if(bond_group_0)
    {
        if(((isl_13.info_1.x) & 16U) != 0U)
        {
            return;
        }
        uint i_17 = wg_1.begin_0 + tid_8;
        bool _S1305;
        if(i_17 < (wg_1.end_0))
        {
            float _S1306 = __ldg(&globalParams_0->params_0->dt_0);
            uint _S1307 = __ldg(&globalParams_0->params_0->fracture_0);
            bool _S1308 = bond_update_0(i_17, _S1306, _S1307 != 0U, isl_13.info_1.w + 1U, true);
            _S1305 = _S1308;
        }
        else
        {
            _S1305 = false;
        }
        if(_S1305)
        {
            *&((&(&(globalParams_0->islands_0)[_S1296.island_2])->info_1)->z) = (isl_13.info_1.z) | 2U;
        }
        return;
    }
    else
    {
        uint _S1309 = __ballot_sync(_S1295, true);
        _S1301 = _S1309;
    }
    uint _S1310 = 0U;
    uint _S1311 = isl_13.info_1.x;
    bool _S1312 = (_S1311 & 1U) != 0U;
    uint _S1313 = __ballot_sync(_S1301, _S1312);
    if(_S1312)
    {
        return;
    }
    else
    {
        uint _S1314 = __ballot_sync(_S1301, true);
        _S1310 = _S1314;
    }
    float3  _S1315 = make_float3 (0.0f);
    float3  f_16 = _S1315;
    float3  t_13 = _S1315;
    uint c_22 = wg_1.begin_0 + tid_8;
    bool _S1316 = c_22 < (wg_1.end_0);
    uint _S1317 = __ballot_sync(_S1310, _S1316);
    if(_S1316)
    {
        Island_0 _S1318 = isl_13;
        Rigid_0 _S1319 = rigid_of_0(&_S1318);
        float _S1320 = __ldg(&globalParams_0->params_0->dt_0);
        bool _S1321 = (_S1311 & 4U) != 0U;
        Island_0 _S1322 = isl_13;
        Rigid_0 _S1323 = _S1319;
        net_load_0(c_22, &_S1322, &_S1323, _S1303, _S1320, _S1321, &f_16, &t_13);
        uint _S1324 = __ballot_sync(_S1310, true);
        _S1287 = _S1324;
    }
    else
    {
        uint _S1325 = __ballot_sync(_S1310, true);
        _S1287 = _S1325;
    }
    group_sum3_0(tid_8, &f_16, &t_13, _S1287);
    bool _S1326 = tid_8 == 0U;
    uint _S1327 = __ballot_sync(_S1287, _S1326);
    if(_S1326)
    {
        uint _S1328 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
        wide_store_0(_S1284 - _S1328, 0U, f_16, t_13);
    }
    return;
}

static __device__ void wide_partials_0(uint tid_9, uint first_1, uint count_5, uint p_13, float3  * a_16, float3  * b_31, uint _S1329)
{
    uint _S1330;
    float4  _S1331 = make_float4 (0.0f);
    float4  x_20 = _S1331;
    float4  y_5 = _S1331;
    uint s_8 = tid_9;
    uint _S1332 = _S1329;
    for(;;)
    {
        bool _S1333 = s_8 < count_5;
        uint _S1334 = __ballot_sync(_S1332, _S1333);
        if(_S1333)
        {
            uint _S1335 = __ballot_sync(_S1332, true);
        }
        else
        {
            uint _S1336 = __ballot_sync(_S1332, false);
            uint _S1337 = __ballot_sync(_S1332, false);
            uint _S1338 = __ballot_sync(_S1329, true);
            _S1330 = _S1338;
            break;
        }
        uint _S1339 = __ldg(&globalParams_0->params_0->wide_base_0);
        uint _S1340 = 8U * (first_1 + s_8);
        x_20 = x_20 + *(&(globalParams_0->scratch_0)[_S1339 + _S1340 + p_13]);
        uint _S1341 = __ldg(&globalParams_0->params_0->wide_base_0);
        y_5 = y_5 + *(&(globalParams_0->scratch_0)[_S1341 + _S1340 + p_13 + 1U]);
        uint _S1342 = __ballot_sync(_S1332, true);
        s_8 = s_8 + 256U;
        _S1332 = _S1342;
    }
    group_sum2_0(tid_9, &x_20, &y_5, _S1330);
    float4  _S1343 = x_20;
    *a_16 = float3 {_S1343.x, _S1343.y, _S1343.z};
    float4  _S1344 = y_5;
    *b_31 = float3 {_S1344.x, _S1344.y, _S1344.z};
    return;
}

static __device__ Rigid_0 wide_rigid_frame_0(uint tid_10, Island_0 * isl_14, WideGroup_0 * wg_2, uint _S1345)
{
    Rigid_0 _S1346 = rigid_of_0(isl_14);
    Rigid_0 rg_8 = _S1346;
    bool _S1347 = ((isl_14->info_1.x) & 1U) == 0U;
    uint _S1348 = __ballot_sync(_S1345, _S1347);
    if(_S1347)
    {
        float3  f_17;
        float3  t_14;
        wide_partials_0(tid_10, wg_2->first_0, isl_14->wide_groups_0, 0U, &f_17, &t_14, _S1348);
        rigid_acceleration_0(isl_14, &rg_8, f_17, t_14);
        uint _S1349 = __ballot_sync(_S1345, true);
    }
    return rg_8;
}

extern "C" __global__ void wide_chunks()
{
    uint _S1350 = 0U;
    uint _S1351 = __ballot_sync(4294967295U, true);
    uint tid_11 = threadIdx.x;
    uint _S1352 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1353 = blockIdx.x;
    WideGroup_0 wg_3 = wide_group_0(_S1352, _S1353);
    Island_0 isl_15 = *(&(globalParams_0->islands_0)[wg_3.island_2]);
    bool _S1354 = wide_enter_1(tid_11, wg_3.island_2);
    bool _S1355 = !_S1354;
    uint _S1356 = __ballot_sync(_S1351, _S1355);
    if(_S1355)
    {
        return;
    }
    else
    {
        uint _S1357 = __ballot_sync(_S1351, true);
        _S1350 = _S1357;
    }
    uint _S1358 = 0U;
    uint _S1359 = isl_15.info_1.x;
    bool anchored_0 = (_S1359 & 1U) != 0U;
    bool _S1360 = (_S1359 & 16U) != 0U;
    uint _S1361 = __ballot_sync(_S1350, _S1360);
    if(_S1360)
    {
        if(tid_11 == 0U)
        {
            uint _S1362 = __ldg(&globalParams_0->params_0->wide_base_0);
            *(&(globalParams_0->scratch_0)[_S1362 + 8U * _S1353 + 6U]) = make_float4 (0.0f);
        }
        return;
    }
    else
    {
        uint _S1363 = __ballot_sync(_S1350, true);
        _S1358 = _S1363;
    }
    Island_0 _S1364 = isl_15;
    WideGroup_0 _S1365 = wg_3;
    Rigid_0 _S1366 = wide_rigid_frame_0(tid_11, &_S1364, &_S1365, _S1358);
    float work_3 = 0.0f;
    float work_err_2 = 0.0f;
    float3  _S1367 = make_float3 (0.0f);
    float3  tu_2 = _S1367;
    float3  pv_2 = _S1367;
    uint c_23 = wg_3.begin_0 + tid_11;
    bool _S1368 = c_23 < (wg_3.end_0);
    uint _S1369 = __ballot_sync(_S1358, _S1368);
    uint _S1370;
    if(_S1368)
    {
        float _S1371 = __ldg(&globalParams_0->params_0->dt_0);
        uint _S1372 = __ldg(&globalParams_0->params_0->rigid_motion_loads_0);
        bool _S1373 = _S1372 != 0U;
        Island_0 _S1374 = isl_15;
        uint _S1375 = wide_step_0(&_S1374);
        bool _S1376 = (_S1359 & 4U) != 0U;
        Island_0 _S1377 = isl_15;
        Rigid_0 _S1378 = _S1366;
        chunk_update_0(c_23, &_S1377, &_S1378, _S1371, _S1373, _S1375, _S1376, &work_3, &work_err_2);
        bool _S1379 = !anchored_0;
        uint _S1380 = __ballot_sync(_S1369, _S1379);
        if(_S1379)
        {
            drift_moments_0(c_23, &tu_2, &pv_2);
            uint _S1381 = __ballot_sync(_S1369, true);
        }
        else
        {
            uint _S1382 = __ballot_sync(_S1369, true);
        }
        uint _S1383 = __ballot_sync(_S1358, true);
        _S1370 = _S1383;
    }
    else
    {
        uint _S1384 = __ballot_sync(_S1358, true);
        _S1370 = _S1384;
    }
    float3  wsum_1 = make_float3 (work_3, work_err_2, 0.0f);
    float3  unused_3 = _S1367;
    group_sum3_0(tid_11, &wsum_1, &unused_3, _S1370);
    bool _S1385 = !anchored_0;
    uint _S1386 = __ballot_sync(_S1370, _S1385);
    if(_S1385)
    {
        group_sum3_0(tid_11, &tu_2, &pv_2, _S1386);
        uint _S1387 = __ballot_sync(_S1370, true);
    }
    if(tid_11 == 0U)
    {
        uint _S1388 = __ldg(&globalParams_0->params_0->wide_base_0);
        uint _S1389 = 8U * _S1353;
        *(&(globalParams_0->scratch_0)[_S1388 + _S1389 + 6U]) = make_float4 (wsum_1.x, wsum_1.y, wsum_1.z, 0.0f);
        if(_S1385)
        {
            wide_store_0(_S1353, 2U, tu_2, pv_2);
        }
        uint _S1390 = __ldg(&globalParams_0->params_0->wide_base_0);
        *(&(globalParams_0->scratch_0)[_S1390 + _S1389 + 7U]) = make_float4 (float((*&g_seen_0)[0U]), float((*&g_seen_0)[1U]), float((*&g_seen_0)[2U]), 0.0f);
    }
    return;
}

extern "C" __global__ void wide_drift()
{
    uint _S1391 = __ballot_sync(4294967295U, true);
    uint tid_12 = threadIdx.x;
    uint _S1392 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1393 = blockIdx.x;
    WideGroup_0 wg_4 = wide_group_0(_S1392, _S1393);
    Island_0 * _S1394 = (&(globalParams_0->islands_0)[wg_4.island_2]);
    Island_0 isl_16 = *_S1394;
    bool _S1395 = (((*_S1394).info_1.x) & 17U) != 0U;
    uint _S1396 = __ballot_sync(_S1391, _S1395);
    bool _S1397;
    uint _S1398;
    if(_S1395)
    {
        uint _S1399 = __ballot_sync(_S1391, true);
        _S1397 = true;
        _S1398 = _S1399;
    }
    else
    {
        bool _S1400 = wide_enter_1(tid_12, wg_4.island_2);
        bool _S1401 = !_S1400;
        uint _S1402 = __ballot_sync(_S1391, true);
        _S1397 = _S1401;
        _S1398 = _S1402;
    }
    uint _S1403 = 0U;
    uint _S1404 = __ballot_sync(_S1398, _S1397);
    if(_S1397)
    {
        return;
    }
    else
    {
        uint _S1405 = __ballot_sync(_S1398, true);
        _S1403 = _S1405;
    }
    float3  tu_3;
    float3  pv_3;
    wide_partials_0(tid_12, wg_4.first_0, isl_16.wide_groups_0, 2U, &tu_3, &pv_3, _S1403);
    float _S1406 = isl_16.wcom_0.w;
    float3  tr_4 = tu_3 / make_float3 (_S1406);
    float3  dv_4 = pv_3 / make_float3 (_S1406);
    float3  _S1407 = make_float3 (0.0f);
    float3  lu_2 = _S1407;
    float3  lv_2 = _S1407;
    uint c_24 = wg_4.begin_0 + tid_12;
    bool _S1408 = c_24 < (wg_4.end_0);
    uint _S1409 = __ballot_sync(_S1403, _S1408);
    if(_S1408)
    {
        float4  _S1410 = isl_16.wcom_0;
        drift_angular_0(c_24, float3 {_S1410.x, _S1410.y, _S1410.z}, tr_4, dv_4, &lu_2, &lv_2);
        uint _S1411 = __ballot_sync(_S1403, true);
        _S1398 = _S1411;
    }
    else
    {
        uint _S1412 = __ballot_sync(_S1403, true);
        _S1398 = _S1412;
    }
    group_sum3_0(tid_12, &lu_2, &lv_2, _S1398);
    bool _S1413 = tid_12 == 0U;
    uint _S1414 = __ballot_sync(_S1398, _S1413);
    if(_S1413)
    {
        wide_store_0(_S1393, 4U, lu_2, lv_2);
    }
    return;
}

extern "C" __global__ void wide_rigid()
{
    uint _S1415 = __ballot_sync(4294967295U, true);
    uint tid_13 = threadIdx.x;
    uint _S1416 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1417 = blockIdx.x;
    WideGroup_0 wg_5 = wide_group_0(_S1416, _S1417);
    Island_0 * _S1418 = (&(globalParams_0->islands_0)[wg_5.island_2]);
    Island_0 isl_17 = *_S1418;
    uint _S1419 = (*_S1418).info_1.x;
    bool _S1420 = (_S1419 & 1U) != 0U;
    uint _S1421 = __ballot_sync(_S1415, _S1420);
    bool _S1422;
    uint _S1423;
    if(_S1420)
    {
        uint _S1424 = __ballot_sync(_S1415, true);
        _S1422 = true;
        _S1423 = _S1424;
    }
    else
    {
        bool _S1425 = wide_enter_1(tid_13, wg_5.island_2);
        bool _S1426 = !_S1425;
        uint _S1427 = __ballot_sync(_S1415, true);
        _S1422 = _S1426;
        _S1423 = _S1427;
    }
    uint _S1428 = 0U;
    uint _S1429 = __ballot_sync(_S1423, _S1422);
    if(_S1422)
    {
        return;
    }
    else
    {
        uint _S1430 = __ballot_sync(_S1423, true);
        _S1428 = _S1430;
    }
    uint _S1431 = 0U;
    bool _S1432 = (_S1419 & 16U) != 0U;
    uint _S1433 = __ballot_sync(_S1428, _S1432);
    if(_S1432)
    {
        uint _S1434 = 0U;
        bool _S1435 = _S1417 != (wg_5.first_0);
        uint _S1436 = __ballot_sync(_S1433, _S1435);
        if(_S1435)
        {
            return;
        }
        else
        {
            uint _S1437 = __ballot_sync(_S1433, true);
            _S1434 = _S1437;
        }
        Island_0 _S1438 = isl_17;
        WideGroup_0 _S1439 = wg_5;
        Rigid_0 _S1440 = wide_rigid_frame_0(tid_13, &_S1438, &_S1439, _S1434);
        Rigid_0 rs_0 = _S1440;
        bool _S1441 = tid_13 != 0U;
        uint _S1442 = __ballot_sync(_S1434, _S1441);
        if(_S1441)
        {
            _S1422 = true;
        }
        else
        {
            _S1422 = (_S1419 & 2U) != 0U;
        }
        if(_S1422)
        {
            return;
        }
        float _S1443 = __ldg(&globalParams_0->params_0->dt_0);
        Island_0 _S1444 = isl_17;
        integrate_rigid_0(&_S1444, &rs_0, _S1443);
        Quat_0 _S1445 = (&rs_0)->rot_0;
        float4  _S1446 = quat_vec_0(&_S1445);
        (&(globalParams_0->islands_0)[wg_5.island_2])->rotation_0 = _S1446;
        (&(globalParams_0->islands_0)[wg_5.island_2])->rotation_err_0 = (&rs_0)->rot_err_0;
        (&(globalParams_0->islands_0)[wg_5.island_2])->position_0 = make_float4 ((&rs_0)->pos_1.x, (&rs_0)->pos_1.y, (&rs_0)->pos_1.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_5.island_2])->position_err_0 = make_float4 ((&rs_0)->pos_err_1.x, (&rs_0)->pos_err_1.y, (&rs_0)->pos_err_1.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_5.island_2])->velocity_0 = make_float4 ((&rs_0)->vel_1.x, (&rs_0)->vel_1.y, (&rs_0)->vel_1.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_5.island_2])->velocity_err_0 = make_float4 ((&rs_0)->vel_err_1.x, (&rs_0)->vel_err_1.y, (&rs_0)->vel_err_1.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_5.island_2])->angular_velocity_0 = make_float4 ((&rs_0)->w_4.x, (&rs_0)->w_4.y, (&rs_0)->w_4.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_5.island_2])->momentum_0 = make_float4 ((&rs_0)->l_2.x, (&rs_0)->l_2.y, (&rs_0)->l_2.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_5.island_2])->momentum_err_0 = make_float4 ((&rs_0)->l_err_1.x, (&rs_0)->l_err_1.y, (&rs_0)->l_err_1.z, 0.0f);
        return;
    }
    else
    {
        uint _S1447 = __ballot_sync(_S1428, true);
        _S1431 = _S1447;
    }
    float3  tu_4;
    float3  pv_4;
    wide_partials_0(tid_13, wg_5.first_0, isl_17.wide_groups_0, 2U, &tu_4, &pv_4, _S1431);
    float3  lu_3;
    float3  lv_3;
    wide_partials_0(tid_13, wg_5.first_0, isl_17.wide_groups_0, 4U, &lu_3, &lv_3, _S1431);
    float _S1448 = isl_17.wcom_0.w;
    float3  tr_5 = tu_4 / make_float3 (_S1448);
    float3  dv_5 = pv_4 / make_float3 (_S1448);
    float3  phi_4 = rows_mul_0(isl_17.winv0_0, isl_17.winv1_0, isl_17.winv2_0, lu_3);
    float3  dw_3 = rows_mul_0(isl_17.winv0_0, isl_17.winv1_0, isl_17.winv2_0, lv_3);
    uint c_25 = wg_5.begin_0 + tid_13;
    bool _S1449 = c_25 < (wg_5.end_0);
    uint _S1450 = __ballot_sync(_S1431, _S1449);
    if(_S1449)
    {
        float4  _S1451 = isl_17.wcom_0;
        drift_apply_0(c_25, float3 {_S1451.x, _S1451.y, _S1451.z}, tr_5, phi_4, dv_5, dw_3);
        uint _S1452 = __ballot_sync(_S1431, true);
        _S1423 = _S1452;
    }
    else
    {
        uint _S1453 = __ballot_sync(_S1431, true);
        _S1423 = _S1453;
    }
    uint _S1454 = 0U;
    bool _S1455 = _S1417 != (wg_5.first_0);
    uint _S1456 = __ballot_sync(_S1423, _S1455);
    if(_S1455)
    {
        return;
    }
    else
    {
        uint _S1457 = __ballot_sync(_S1423, true);
        _S1454 = _S1457;
    }
    Island_0 _S1458 = isl_17;
    WideGroup_0 _S1459 = wg_5;
    Rigid_0 _S1460 = wide_rigid_frame_0(tid_13, &_S1458, &_S1459, _S1454);
    Rigid_0 rg_9 = _S1460;
    bool _S1461 = tid_13 != 0U;
    uint _S1462 = __ballot_sync(_S1454, _S1461);
    if(_S1461)
    {
        return;
    }
    if(!((_S1419 & 2U) != 0U))
    {
        float _S1463 = __ldg(&globalParams_0->params_0->dt_0);
        Island_0 _S1464 = isl_17;
        integrate_rigid_0(&_S1464, &rg_9, _S1463);
        Island_0 _S1465 = isl_17;
        drift_rigid_0(&_S1465, &rg_9, tr_5, phi_4, dv_5, dw_3);
    }
    Quat_0 _S1466 = (&rg_9)->rot_0;
    float4  _S1467 = quat_vec_0(&_S1466);
    (&(globalParams_0->islands_0)[wg_5.island_2])->rotation_0 = _S1467;
    (&(globalParams_0->islands_0)[wg_5.island_2])->rotation_err_0 = (&rg_9)->rot_err_0;
    (&(globalParams_0->islands_0)[wg_5.island_2])->position_0 = make_float4 ((&rg_9)->pos_1.x, (&rg_9)->pos_1.y, (&rg_9)->pos_1.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_5.island_2])->position_err_0 = make_float4 ((&rg_9)->pos_err_1.x, (&rg_9)->pos_err_1.y, (&rg_9)->pos_err_1.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_5.island_2])->velocity_0 = make_float4 ((&rg_9)->vel_1.x, (&rg_9)->vel_1.y, (&rg_9)->vel_1.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_5.island_2])->velocity_err_0 = make_float4 ((&rg_9)->vel_err_1.x, (&rg_9)->vel_err_1.y, (&rg_9)->vel_err_1.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_5.island_2])->angular_velocity_0 = make_float4 ((&rg_9)->w_4.x, (&rg_9)->w_4.y, (&rg_9)->w_4.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_5.island_2])->momentum_0 = make_float4 ((&rg_9)->l_2.x, (&rg_9)->l_2.y, (&rg_9)->l_2.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_5.island_2])->momentum_err_0 = make_float4 ((&rg_9)->l_err_1.x, (&rg_9)->l_err_1.y, (&rg_9)->l_err_1.z, 0.0f);
    return;
}

extern "C" __global__ void wide_end()
{
    uint _S1468 = 0U;
    uint _S1469 = __ballot_sync(4294967295U, true);
    uint tid_14 = threadIdx.x;
    uint _S1470 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1471 = blockIdx.x;
    WideGroup_0 wg_6 = wide_group_0(_S1470, _S1471);
    bool _S1472 = _S1471 != (wg_6.first_0);
    uint _S1473 = __ballot_sync(_S1469, _S1472);
    if(_S1472)
    {
        return;
    }
    else
    {
        uint _S1474 = __ballot_sync(_S1469, true);
        _S1468 = _S1474;
    }
    uint _S1475 = 0U;
    Island_0 * _S1476 = (&(globalParams_0->islands_0)[wg_6.island_2]);
    Island_0 isl_18 = *_S1476;
    Island_0 _S1477 = *_S1476;
    bool _S1478 = wide_enter_0(tid_14, &_S1477);
    bool _S1479 = !_S1478;
    uint _S1480 = __ballot_sync(_S1468, _S1479);
    if(_S1479)
    {
        return;
    }
    else
    {
        uint _S1481 = __ballot_sync(_S1468, true);
        _S1475 = _S1481;
    }
    float3  work_4;
    float3  flags_2;
    wide_partials_0(tid_14, wg_6.first_0, (&isl_18)->wide_groups_0, 6U, &work_4, &flags_2, _S1475);
    bool _S1482 = tid_14 != 0U;
    uint _S1483 = __ballot_sync(_S1475, _S1482);
    if(_S1482)
    {
        return;
    }
    Island_0 _S1484 = isl_18;
    uint _S1485 = wide_step_0(&_S1484);
    if(((&isl_18)->probes_0.y) > ((&isl_18)->probes_0.x))
    {
        Island_0 _S1486 = isl_18;
        Rigid_0 _S1487 = rigid_of_0(&_S1486);
        Island_0 _S1488 = isl_18;
        Rigid_0 _S1489 = _S1487;
        record_probes_0(&_S1488, &_S1489, _S1485);
    }
    bool halt_0 = (((&isl_18)->info_1.z) & 2U) != 0U;
    bool _S1490;
    if(halt_0)
    {
        _S1490 = (((&isl_18)->info_1.x) & 4U) != 0U;
    }
    else
    {
        _S1490 = false;
    }
    if(_S1490)
    {
        contact_split_at_0((&isl_18)->info_1.w + 1U);
    }
    comp_add1_0(&((&(&isl_18)->energy_1)->x), &((&(&isl_18)->energy_1)->y), work_4.x);
    *&((&(&isl_18)->energy_1)->y) = *&((&(&isl_18)->energy_1)->y) + work_4.y;
    (&isl_18)->done_0 = (&isl_18)->done_0 + 1U;
    *&((&(&isl_18)->info_1)->y) = *&((&(&isl_18)->info_1)->y) - 1U;
    *&((&(&isl_18)->info_1)->w) = *&((&(&isl_18)->info_1)->w) + 1U;
    if(halt_0)
    {
        *&((&(&isl_18)->info_1)->z) = (((&isl_18)->info_1.z) & 4294967293U) | 1U;
    }
    uint _S1491;
    if(halt_0)
    {
        _S1491 = 128U;
    }
    else
    {
        _S1491 = 0U;
    }
    uint _S1492 = 256U | _S1491;
    if(((&isl_18)->probes_0.y) > ((&isl_18)->probes_0.x))
    {
        _S1491 = 262144U;
    }
    else
    {
        _S1491 = 0U;
    }
    uint _S1493 = _S1492 | _S1491;
    if((((&isl_18)->info_1.x) & 4U) != 0U)
    {
        _S1491 = 524288U;
    }
    else
    {
        _S1491 = 0U;
    }
    uint _S1494 = _S1493 | _S1491;
    if((flags_2.x) > 0.0f)
    {
        _S1491 = 32768U;
    }
    else
    {
        _S1491 = 0U;
    }
    uint _S1495 = _S1494 | _S1491;
    if((flags_2.y) > 0.0f)
    {
        _S1491 = 65536U;
    }
    else
    {
        _S1491 = 0U;
    }
    uint _S1496 = _S1495 | _S1491;
    if((flags_2.z) > 0.0f)
    {
        _S1491 = 131072U;
    }
    else
    {
        _S1491 = 0U;
    }
    (&isl_18)->coverage_0 = ((&isl_18)->coverage_0) | (_S1496 | _S1491);
    *(&(globalParams_0->islands_0)[wg_6.island_2]) = isl_18;
    return;
}

static __device__ uint sv_0(uint c_26, uint slot_2)
{
    uint _S1497 = __ldg(&globalParams_0->params_0->statics_base_0);
    return _S1497 + 23U * c_26 + slot_2;
}

static __device__ void project_load_slot_0(uint tid_15, Island_0 * isl_19, uint slot_3, uint _S1498)
{
    uint _S1499;
    uint _S1500;
    float3  _S1501 = make_float3 (0.0f);
    float3  net_f_0 = _S1501;
    float3  net_m_0 = _S1501;
    uint4  _S1502 = isl_19->range_0;
    uint _S1503 = isl_19->range_0.x + tid_15;
    uint c_27 = _S1503;
    uint _S1504 = _S1498;
    for(;;)
    {
        uint _S1505 = _S1502.y;
        _S1499 = _S1505;
        bool _S1506 = c_27 < _S1505;
        uint _S1507 = __ballot_sync(_S1504, _S1506);
        if(_S1506)
        {
            uint _S1508 = __ballot_sync(_S1504, true);
        }
        else
        {
            uint _S1509 = __ballot_sync(_S1504, false);
            uint _S1510 = __ballot_sync(_S1504, false);
            uint _S1511 = __ballot_sync(_S1498, true);
            _S1500 = _S1511;
            break;
        }
        float4  _S1512 = *(&(globalParams_0->scratch_0)[sv_0(c_27, slot_3)]);
        float3  fi_1 = float3 {_S1512.x, _S1512.y, _S1512.z};
        net_f_0 = net_f_0 + fi_1;
        float4  _S1513 = __ldg(&(&(globalParams_0->chunks_0)[c_27])->center_0);
        float4  _S1514 = isl_19->com_0;
        float4  _S1515 = *(&(globalParams_0->scratch_0)[sv_0(c_27, slot_3 + 1U)]);
        net_m_0 = net_m_0 + (cross_0(float3 {_S1513.x, _S1513.y, _S1513.z} - float3 {_S1514.x, _S1514.y, _S1514.z}, fi_1) + float3 {_S1515.x, _S1515.y, _S1515.z});
        uint _S1516 = __ballot_sync(_S1504, true);
        c_27 = c_27 + 256U;
        _S1504 = _S1516;
    }
    group_sum3_0(tid_15, &net_f_0, &net_m_0, _S1500);
    float4  _S1517 = isl_19->com_0;
    float3  _S1518 = net_f_0 / make_float3 (isl_19->com_0.w);
    float3  _S1519 = rows_mul_0(isl_19->inv0_1, isl_19->inv1_1, isl_19->inv2_1, net_m_0);
    c_27 = _S1503;
    for(;;)
    {
        if(c_27 < _S1499)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_0 * _S1520 = (&(globalParams_0->chunks_0)[c_27]);
        float4  _S1521 = __ldg(&_S1520->center_0);
        uint _S1522 = sv_0(c_27, slot_3);
        float4  _S1523 = *(&(globalParams_0->scratch_0)[_S1522]);
        *(&(globalParams_0->scratch_0)[_S1522]) = make_float4 ((float3 {_S1523.x, _S1523.y, _S1523.z} - (_S1518 + cross_0(_S1519, float3 {_S1521.x, _S1521.y, _S1521.z} - float3 {_S1517.x, _S1517.y, _S1517.z})) * make_float3 (_S1521.w)).x, (float3 {_S1523.x, _S1523.y, _S1523.z} - (_S1518 + cross_0(_S1519, float3 {_S1521.x, _S1521.y, _S1521.z} - float3 {_S1517.x, _S1517.y, _S1517.z})) * make_float3 (_S1521.w)).y, (float3 {_S1523.x, _S1523.y, _S1523.z} - (_S1518 + cross_0(_S1519, float3 {_S1521.x, _S1521.y, _S1521.z} - float3 {_S1517.x, _S1517.y, _S1517.z})) * make_float3 (_S1521.w)).z, 0.0f);
        uint _S1524 = sv_0(c_27, slot_3 + 1U);
        float4  * _S1525 = (&(globalParams_0->scratch_0)[_S1524]);
        float4  _S1526 = *(&(globalParams_0->scratch_0)[_S1524]);
        float3  _S1527 = float3 {_S1526.x, _S1526.y, _S1526.z};
        float4  _S1528 = __ldg(&_S1520->inertia0_0);
        float4  _S1529 = __ldg(&_S1520->inertia1_0);
        float4  _S1530 = __ldg(&_S1520->inertia2_0);
        *_S1525 = make_float4 ((_S1527 - rows_mul_0(_S1528, _S1529, _S1530, _S1519)).x, (_S1527 - rows_mul_0(_S1528, _S1529, _S1530, _S1519)).y, (_S1527 - rows_mul_0(_S1528, _S1529, _S1530, _S1519)).z, 0.0f);
        c_27 = c_27 + 256U;
    }
    __syncthreads();
    return;
}

static __device__ float island_dot_0(uint tid_16, uint c0_0, uint c1_0, uint sa_2, uint sb_2, uint _S1531)
{
    uint _S1532;
    float4  _S1533 = make_float4 (0.0f);
    float4  acc_0 = _S1533;
    float4  unused_4 = _S1533;
    uint c_28 = c0_0 + tid_16;
    uint _S1534 = _S1531;
    for(;;)
    {
        bool _S1535 = c_28 < c1_0;
        uint _S1536 = __ballot_sync(_S1534, _S1535);
        if(_S1535)
        {
            uint _S1537 = __ballot_sync(_S1534, true);
        }
        else
        {
            uint _S1538 = __ballot_sync(_S1534, false);
            uint _S1539 = __ballot_sync(_S1534, false);
            uint _S1540 = __ballot_sync(_S1531, true);
            _S1532 = _S1540;
            break;
        }
        float4  _S1541 = *(&(globalParams_0->scratch_0)[sv_0(c_28, sa_2)]);
        float4  _S1542 = *(&(globalParams_0->scratch_0)[sv_0(c_28, sb_2)]);
        float4  _S1543 = *(&(globalParams_0->scratch_0)[sv_0(c_28, sa_2 + 1U)]);
        float4  _S1544 = *(&(globalParams_0->scratch_0)[sv_0(c_28, sb_2 + 1U)]);
        *&((&acc_0)->x) = *&((&acc_0)->x) + (dot_0(float3 {_S1541.x, _S1541.y, _S1541.z}, float3 {_S1542.x, _S1542.y, _S1542.z}) + dot_0(float3 {_S1543.x, _S1543.y, _S1543.z}, float3 {_S1544.x, _S1544.y, _S1544.z}));
        uint _S1545 = __ballot_sync(_S1534, true);
        c_28 = c_28 + 256U;
        _S1534 = _S1545;
    }
    group_sum2_0(tid_16, &acc_0, &unused_4, _S1532);
    return acc_0.x;
}

static __device__ void static_kinematics_0(uint _S1546, float3  * _S1547, float3  * _S1548)
{
    BondStatic_0 * _S1549 = (&(globalParams_0->bonds_0)[_S1546]);
    JointBond_0 _S1550 = slang_ldg_0(&_S1549->law_0);
    uint ca_1 = _S1550.ids_0.y;
    uint cb_1 = _S1550.ids_0.z;
    uint _S1551 = 4U * cb_1;
    float4  _S1552 = *(&(globalParams_0->state_0)[_S1551]);
    uint _S1553 = 4U * ca_1;
    float4  _S1554 = *(&(globalParams_0->state_0)[_S1553]);
    float4  _S1555 = *(&(globalParams_0->scratch_0)[sv_0(cb_1, 21U)]);
    float4  _S1556 = *(&(globalParams_0->scratch_0)[sv_0(ca_1, 21U)]);
    float3  du_0 = float3 {_S1552.x, _S1552.y, _S1552.z} - float3 {_S1554.x, _S1554.y, _S1554.z} + (float3 {_S1555.x, _S1555.y, _S1555.z} - float3 {_S1556.x, _S1556.y, _S1556.z});
    uint _S1557 = _S1551 + 1U;
    float4  _S1558 = *(&(globalParams_0->state_0)[_S1557]);
    uint _S1559 = _S1553 + 1U;
    float4  _S1560 = *(&(globalParams_0->state_0)[_S1559]);
    uint _S1561 = sv_0(cb_1, 22U);
    float4  _S1562 = *(&(globalParams_0->scratch_0)[_S1561]);
    uint _S1563 = sv_0(ca_1, 22U);
    float4  _S1564 = *(&(globalParams_0->scratch_0)[_S1563]);
    float3  dth_0 = float3 {_S1558.x, _S1558.y, _S1558.z} - float3 {_S1560.x, _S1560.y, _S1560.z} + (float3 {_S1562.x, _S1562.y, _S1562.z} - float3 {_S1564.x, _S1564.y, _S1564.z});
    float4  _S1565 = *(&(globalParams_0->state_0)[_S1559]);
    float4  _S1566 = *(&(globalParams_0->scratch_0)[_S1563]);
    float3  ta_3 = float3 {_S1565.x, _S1565.y, _S1565.z} + float3 {_S1566.x, _S1566.y, _S1566.z};
    float4  _S1567 = *(&(globalParams_0->state_0)[_S1557]);
    float4  _S1568 = *(&(globalParams_0->scratch_0)[_S1561]);
    float3  tb_3 = float3 {_S1567.x, _S1567.y, _S1567.z} + float3 {_S1568.x, _S1568.y, _S1568.z};
    float4  _S1569 = __ldg(&_S1549->rb_0);
    float3  _S1570 = cross_0(tb_3, float3 {_S1569.x, _S1569.y, _S1569.z});
    float4  _S1571 = __ldg(&_S1549->ra_0);
    float3  _S1572 = to_local_0(_S1546, du_0 + (_S1570 - cross_0(ta_3, float3 {_S1571.x, _S1571.y, _S1571.z})));
    *_S1547 = _S1572;
    float3  _S1573 = to_local_0(_S1546, dth_0);
    *_S1548 = _S1573;
    return;
}

static __device__ JointResponse_0 static_response_0(uint i_18)
{
    BondStatic_0 * _S1574 = (&(globalParams_0->bonds_0)[i_18]);
    float3  d_lin_4;
    float3  d_ang_3;
    static_kinematics_0(i_18, &d_lin_4, &d_ang_3);
    JointBond_0 _S1575 = slang_ldg_0(&_S1574->law_0);
    JointBond_0 _S1576 = _S1575;
    JointState_0 _S1577 = (&(globalParams_0->bond_dyn_0)[i_18])->js_0;
    JointResponse_0 _S1578 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S1575.ids_0.x], &_S1576, &_S1577, d_lin_4, d_ang_3, 0.0f, false);
    return _S1578;
}

static __device__ void gather_loads_0(uint c_29, float3  * fi_2, float3  * mi_3)
{
    float3  _S1579 = make_float3 (0.0f);
    *fi_2 = _S1579;
    *mi_3 = _S1579;
    uint _S1580 = __ldg((&(globalParams_0->index_0)[c_29]));
    uint e_4 = _S1580;
    for(;;)
    {
        uint _S1581 = __ldg((&(globalParams_0->index_0)[c_29 + 1U]));
        if(e_4 < _S1581)
        {
        }
        else
        {
            break;
        }
        uint _S1582 = __ldg((&(globalParams_0->index_0)[e_4]));
        uint bond_0 = _S1582 >> int(1);
        if((_S1582 & 1U) == 0U)
        {
            uint _S1583 = 3U * bond_0;
            float4  _S1584 = *(&(globalParams_0->scratch_0)[_S1583]);
            *fi_2 = *fi_2 + float3 {_S1584.x, _S1584.y, _S1584.z};
            float4  _S1585 = *(&(globalParams_0->scratch_0)[_S1583 + 1U]);
            *mi_3 = *mi_3 + float3 {_S1585.x, _S1585.y, _S1585.z};
        }
        else
        {
            uint _S1586 = 3U * bond_0;
            float4  _S1587 = *(&(globalParams_0->scratch_0)[_S1586]);
            *fi_2 = *fi_2 - float3 {_S1587.x, _S1587.y, _S1587.z};
            float4  _S1588 = *(&(globalParams_0->scratch_0)[_S1586 + 2U]);
            *mi_3 = *mi_3 + float3 {_S1588.x, _S1588.y, _S1588.z};
        }
        e_4 = e_4 + 1U;
    }
    return;
}

static __device__ float bond_load_magnitude2_0(uint c_30)
{
    uint _S1589 = __ldg((&(globalParams_0->index_0)[c_30]));
    uint e_5 = _S1589;
    float m_7 = 0.0f;
    for(;;)
    {
        uint _S1590 = __ldg((&(globalParams_0->index_0)[c_30 + 1U]));
        if(e_5 < _S1590)
        {
        }
        else
        {
            break;
        }
        uint _S1591 = __ldg((&(globalParams_0->index_0)[e_5]));
        uint _S1592 = 3U * (_S1591 >> int(1));
        float4  _S1593 = *(&(globalParams_0->scratch_0)[_S1592]);
        float3  f_18 = float3 {_S1593.x, _S1593.y, _S1593.z};
        float3  t_15;
        if((_S1591 & 1U) == 0U)
        {
            float4  _S1594 = *(&(globalParams_0->scratch_0)[_S1592 + 1U]);
            t_15 = float3 {_S1594.x, _S1594.y, _S1594.z};
        }
        else
        {
            float4  _S1595 = *(&(globalParams_0->scratch_0)[_S1592 + 2U]);
            t_15 = float3 {_S1595.x, _S1595.y, _S1595.z};
        }
        float m_8 = m_7 + (dot_0(f_18, f_18) + dot_0(t_15, t_15));
        e_5 = e_5 + 1U;
        m_7 = m_8;
    }
    return m_7;
}

static __device__ uint fixed_mask_0(uint c_31)
{
    uint4  _S1596 = __ldg(&(&(globalParams_0->chunks_0)[c_31])->info_0);
    uint support_1 = _S1596.x;
    uint _S1597;
    if(support_1 == 1U)
    {
        _S1597 = 63U;
    }
    else
    {
        if(support_1 == 2U)
        {
            _S1597 = 7U;
        }
        else
        {
            _S1597 = 0U;
        }
    }
    return _S1597;
}

static __device__ void hold_0(uint mask_0, float4  * lin_0, float4  * ang_0, float4  keep_lin_0, float4  keep_ang_0)
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
            *_slang_vector_get_element_ptr(lin_0, d_12) = _slang_vector_get_element(keep_lin_0, d_12);
        }
        if((mask_0 & (1U << (d_12 + 3U))) != 0U)
        {
            *_slang_vector_get_element_ptr(ang_0, d_12) = _slang_vector_get_element(keep_ang_0, d_12);
        }
        d_12 = d_12 + 1U;
    }
    return;
}

static __device__ uint statics_bond_slot_0(uint i_19)
{
    uint _S1598 = __ldg(&globalParams_0->params_0->statics_base_0);
    uint _S1599 = __ldg(&globalParams_0->params_0->chunk_count_0);
    return _S1598 + 23U * _S1599 + 2U * i_19;
}

static __device__ void store_inverse_0(uint c_32, FixedArray<float, 36>  * a_17)
{
    uint j_6;
    float sum_4;
    FixedArray<float, 36>  l_4;
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
        l_4[k_19] = 0.0f;
        k_19 = k_19 + 1U;
    }
    bool spd_0 = true;
    uint i_20 = 0U;
    for(;;)
    {
        bool _S1600;
        if(i_20 < 6U)
        {
            _S1600 = spd_0;
        }
        else
        {
            _S1600 = false;
        }
        if(_S1600)
        {
        }
        else
        {
            break;
        }
        j_6 = 0U;
        for(;;)
        {
            if(j_6 <= i_20)
            {
            }
            else
            {
                break;
            }
            uint _S1601 = i_20 * 6U;
            uint _S1602 = _S1601 + j_6;
            k_19 = 0U;
            sum_4 = (*a_17)[_S1602];
            for(;;)
            {
                if(k_19 < j_6)
                {
                }
                else
                {
                    break;
                }
                float sum_5 = sum_4 - l_4[_S1601 + k_19] * l_4[j_6 * 6U + k_19];
                k_19 = k_19 + 1U;
                sum_4 = sum_5;
            }
            if(i_20 == j_6)
            {
                if(sum_4 <= 0.0f)
                {
                    spd_0 = false;
                    break;
                }
                l_4[_S1601 + i_20] = (F32_sqrt((sum_4)));
            }
            else
            {
                l_4[_S1602] = sum_4 / l_4[j_6 * 6U + j_6];
            }
            j_6 = j_6 + 1U;
        }
        i_20 = i_20 + 1U;
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
            uint _S1603 = k_19 * 6U + k_19;
            float _S1604 = (*a_17)[_S1603];
            if(((*a_17)[_S1603]) > 0.0f)
            {
                sum_4 = 1.0f / _S1604;
            }
            else
            {
                sum_4 = 0.0f;
            }
            inv_0[_S1603] = sum_4;
            k_19 = k_19 + 1U;
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
            FixedArray<float, 6>  y_6;
            y_6[int(0)] = 0.0f;
            y_6[int(1)] = 0.0f;
            y_6[int(2)] = 0.0f;
            y_6[int(3)] = 0.0f;
            y_6[int(4)] = 0.0f;
            y_6[int(5)] = 0.0f;
            i_20 = 0U;
            for(;;)
            {
                if(i_20 < 6U)
                {
                }
                else
                {
                    break;
                }
                if(i_20 == j_6)
                {
                    sum_4 = 1.0f;
                }
                else
                {
                    sum_4 = 0.0f;
                }
                k_19 = 0U;
                float s_9 = sum_4;
                for(;;)
                {
                    if(k_19 < i_20)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_10 = s_9 - l_4[i_20 * 6U + k_19] * y_6[k_19];
                    k_19 = k_19 + 1U;
                    s_9 = s_10;
                }
                y_6[i_20] = s_9 / l_4[i_20 * 6U + i_20];
                i_20 = i_20 + 1U;
            }
            FixedArray<float, 6>  x_21;
            x_21[int(0)] = 0.0f;
            x_21[int(1)] = 0.0f;
            x_21[int(2)] = 0.0f;
            x_21[int(3)] = 0.0f;
            x_21[int(4)] = 0.0f;
            x_21[int(5)] = 0.0f;
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
                uint i_21 = 5U - ii_2;
                k_19 = i_21 + 1U;
                sum_4 = y_6[i_21];
                for(;;)
                {
                    if(k_19 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_11 = sum_4 - l_4[k_19 * 6U + i_21] * x_21[k_19];
                    k_19 = k_19 + 1U;
                    sum_4 = s_11;
                }
                x_21[i_21] = sum_4 / l_4[i_21 * 6U + i_21];
                ii_2 = ii_2 + 1U;
            }
            uint i_22 = 0U;
            for(;;)
            {
                if(i_22 < 6U)
                {
                }
                else
                {
                    break;
                }
                inv_0[i_22 * 6U + j_6] = x_21[i_22];
                i_22 = i_22 + 1U;
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
        uint _S1605 = 4U * j_6;
        *(&(globalParams_0->scratch_0)[sv_0(c_32, 12U + j_6)]) = make_float4 (inv_0[_S1605], inv_0[_S1605 + 1U], inv_0[_S1605 + 2U], inv_0[_S1605 + 3U]);
        j_6 = j_6 + 1U;
    }
    return;
}

static __device__ void assemble_block_0(uint c_33)
{
    uint p_14;
    uint r_11;
    FixedArray<float, 36>  a_18;
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
        a_18[k_20] = 0.0f;
        k_20 = k_20 + 1U;
    }
    uint _S1606 = __ldg((&(globalParams_0->index_0)[c_33]));
    uint e_6 = _S1606;
    for(;;)
    {
        uint _S1607 = __ldg((&(globalParams_0->index_0)[c_33 + 1U]));
        if(e_6 < _S1607)
        {
        }
        else
        {
            break;
        }
        uint _S1608 = __ldg((&(globalParams_0->index_0)[e_6]));
        uint i_23 = _S1608 >> int(1);
        bool _S1609 = (_S1608 & 1U) != 0U;
        BondStatic_0 * _S1610 = (&(globalParams_0->bonds_0)[i_23]);
        uint _S1611 = statics_bond_slot_0(i_23);
        float4  _S1612 = *(&(globalParams_0->scratch_0)[_S1611]);
        float4  _S1613 = *(&(globalParams_0->scratch_0)[_S1611 + 1U]);
        p_14 = 0U;
        for(;;)
        {
            if(p_14 < 6U)
            {
            }
            else
            {
                break;
            }
            uint _S1614 = p_14 % 3U;
            float3  t_16;
            if(_S1614 == 0U)
            {
                float4  _S1615 = __ldg(&_S1610->t1_0);
                t_16 = float3 {_S1615.x, _S1615.y, _S1615.z};
            }
            else
            {
                if(_S1614 == 1U)
                {
                    float4  _S1616 = __ldg(&_S1610->t2_0);
                    t_16 = float3 {_S1616.x, _S1616.y, _S1616.z};
                }
                else
                {
                    float4  _S1617 = __ldg(&_S1610->normal_0);
                    t_16 = float3 {_S1617.x, _S1617.y, _S1617.z};
                }
            }
            bool _S1618 = p_14 < 3U;
            float3  row_u_0;
            float3  row_t_0;
            if(_S1618)
            {
                if(_S1609)
                {
                    row_u_0 = t_16;
                }
                else
                {
                    row_u_0 = - t_16;
                }
                if(_S1609)
                {
                    float4  _S1619 = __ldg(&_S1610->rb_0);
                    row_t_0 = cross_0(float3 {_S1619.x, _S1619.y, _S1619.z}, t_16);
                }
                else
                {
                    float4  _S1620 = __ldg(&_S1610->ra_0);
                    row_t_0 = - cross_0(float3 {_S1620.x, _S1620.y, _S1620.z}, t_16);
                }
            }
            else
            {
                float3  _S1621 = make_float3 (0.0f);
                if(_S1609)
                {
                    row_u_0 = t_16;
                }
                else
                {
                    row_u_0 = - t_16;
                }
                float3  _S1622 = row_u_0;
                row_u_0 = _S1621;
                row_t_0 = _S1622;
            }
            float kp_0;
            if(_S1618)
            {
                kp_0 = _slang_vector_get_element(_S1612, p_14);
            }
            else
            {
                kp_0 = _slang_vector_get_element(_S1613, p_14 - 3U);
            }
            if(kp_0 == 0.0f)
            {
                p_14 = p_14 + 1U;
                continue;
            }
            FixedArray<float, 6>  _S1623 = { {
                row_u_0.x, row_u_0.y, row_u_0.z, row_t_0.x, row_t_0.y, row_t_0.z
            } };
            r_11 = 0U;
            for(;;)
            {
                if(r_11 < 6U)
                {
                }
                else
                {
                    break;
                }
                uint q_13 = 0U;
                for(;;)
                {
                    if(q_13 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    a_18[r_11 * 6U + q_13] = a_18[r_11 * 6U + q_13] + kp_0 * _S1623[r_11] * _S1623[q_13];
                    q_13 = q_13 + 1U;
                }
                r_11 = r_11 + 1U;
            }
            p_14 = p_14 + 1U;
        }
        e_6 = e_6 + 1U;
    }
    uint _S1624 = fixed_mask_0(c_33);
    p_14 = 0U;
    for(;;)
    {
        if(p_14 < 6U)
        {
        }
        else
        {
            break;
        }
        if((_S1624 & (1U << p_14)) != 0U)
        {
            r_11 = 0U;
            for(;;)
            {
                if(r_11 < 6U)
                {
                }
                else
                {
                    break;
                }
                a_18[p_14 * 6U + r_11] = 0.0f;
                a_18[r_11 * 6U + p_14] = 0.0f;
                r_11 = r_11 + 1U;
            }
            a_18[p_14 * 6U + p_14] = 1.0f;
        }
        p_14 = p_14 + 1U;
    }
    p_14 = 0U;
    for(;;)
    {
        if(p_14 < 6U)
        {
        }
        else
        {
            break;
        }
        if((a_18[p_14 * 6U + p_14]) == 0.0f)
        {
            a_18[p_14 * 6U + p_14] = 1.0f;
        }
        p_14 = p_14 + 1U;
    }
    FixedArray<float, 36>  _S1625 = a_18;
    store_inverse_0(c_33, &_S1625);
    return;
}

static __device__ float block_get_0(uint c_34, uint i_24, uint j_7)
{
    uint k_21 = i_24 * 6U + j_7;
    return *_slang_vector_get_element_ptr((&(globalParams_0->scratch_0)[sv_0(c_34, 12U + k_21 / 4U)]), k_21 % 4U);
}

static __device__ void precondition_0(uint c_35)
{
    float4  * _S1626 = (&(globalParams_0->scratch_0)[sv_0(c_35, 4U)]);
    float4  * _S1627 = (&(globalParams_0->scratch_0)[sv_0(c_35, 5U)]);
    FixedArray<float, 6>  _S1628 = { {
        (*_S1626).x, (*_S1626).y, (*_S1626).z, (*_S1627).x, (*_S1627).y, (*_S1627).z
    } };
    FixedArray<float, 6>  z_1;
    uint i_25 = 0U;
    for(;;)
    {
        if(i_25 < 6U)
        {
        }
        else
        {
            break;
        }
        uint j_8 = 0U;
        float s_12 = 0.0f;
        for(;;)
        {
            if(j_8 < 6U)
            {
            }
            else
            {
                break;
            }
            float s_13 = s_12 + block_get_0(c_35, i_25, j_8) * _S1628[j_8];
            j_8 = j_8 + 1U;
            s_12 = s_13;
        }
        z_1[i_25] = s_12;
        i_25 = i_25 + 1U;
    }
    *(&(globalParams_0->scratch_0)[sv_0(c_35, 6U)]) = make_float4 (z_1[int(0)], z_1[int(1)], z_1[int(2)], 0.0f);
    *(&(globalParams_0->scratch_0)[sv_0(c_35, 7U)]) = make_float4 (z_1[int(3)], z_1[int(4)], z_1[int(5)], 0.0f);
    return;
}

static __device__ void project_displacement_slot_0(uint tid_17, Island_0 * isl_20, uint slot_4, uint _S1629)
{
    uint _S1630;
    uint _S1631;
    float3  _S1632 = make_float3 (0.0f);
    float3  p_15 = _S1632;
    float3  l_5 = _S1632;
    uint4  _S1633 = isl_20->range_0;
    uint _S1634 = isl_20->range_0.x + tid_17;
    uint c_36 = _S1634;
    uint _S1635 = _S1629;
    for(;;)
    {
        uint _S1636 = _S1633.y;
        _S1630 = _S1636;
        bool _S1637 = c_36 < _S1636;
        uint _S1638 = __ballot_sync(_S1635, _S1637);
        if(_S1637)
        {
            uint _S1639 = __ballot_sync(_S1635, true);
        }
        else
        {
            uint _S1640 = __ballot_sync(_S1635, false);
            uint _S1641 = __ballot_sync(_S1635, false);
            uint _S1642 = __ballot_sync(_S1629, true);
            _S1631 = _S1642;
            break;
        }
        ChunkStatic_0 * _S1643 = (&(globalParams_0->chunks_0)[c_36]);
        float4  _S1644 = *(&(globalParams_0->scratch_0)[sv_0(c_36, slot_4)]);
        float3  u_3 = float3 {_S1644.x, _S1644.y, _S1644.z};
        float4  _S1645 = *(&(globalParams_0->scratch_0)[sv_0(c_36, slot_4 + 1U)]);
        float3  th_4 = float3 {_S1645.x, _S1645.y, _S1645.z};
        float4  _S1646 = __ldg(&_S1643->center_0);
        float4  _S1647 = isl_20->com_0;
        float3  r_12 = float3 {_S1646.x, _S1646.y, _S1646.z} - float3 {_S1647.x, _S1647.y, _S1647.z};
        float _S1648 = _S1646.w;
        p_15 = p_15 + u_3 * make_float3 (_S1648);
        float3  _S1649 = cross_0(r_12, u_3) * make_float3 (_S1648);
        float4  _S1650 = __ldg(&_S1643->inertia0_0);
        float4  _S1651 = __ldg(&_S1643->inertia1_0);
        float4  _S1652 = __ldg(&_S1643->inertia2_0);
        l_5 = l_5 + (_S1649 + rows_mul_0(_S1650, _S1651, _S1652, th_4));
        uint _S1653 = __ballot_sync(_S1635, true);
        c_36 = c_36 + 256U;
        _S1635 = _S1653;
    }
    group_sum3_0(tid_17, &p_15, &l_5, _S1631);
    float4  _S1654 = isl_20->com_0;
    float3  _S1655 = p_15 / make_float3 (isl_20->com_0.w);
    float3  _S1656 = rows_mul_0(isl_20->inv0_1, isl_20->inv1_1, isl_20->inv2_1, l_5);
    c_36 = _S1634;
    for(;;)
    {
        if(c_36 < _S1630)
        {
        }
        else
        {
            break;
        }
        float4  _S1657 = __ldg(&(&(globalParams_0->chunks_0)[c_36])->center_0);
        uint _S1658 = sv_0(c_36, slot_4);
        float4  _S1659 = *(&(globalParams_0->scratch_0)[_S1658]);
        *(&(globalParams_0->scratch_0)[_S1658]) = make_float4 ((float3 {_S1659.x, _S1659.y, _S1659.z} - _S1655 - cross_0(_S1656, float3 {_S1657.x, _S1657.y, _S1657.z} - float3 {_S1654.x, _S1654.y, _S1654.z})).x, (float3 {_S1659.x, _S1659.y, _S1659.z} - _S1655 - cross_0(_S1656, float3 {_S1657.x, _S1657.y, _S1657.z} - float3 {_S1654.x, _S1654.y, _S1654.z})).y, (float3 {_S1659.x, _S1659.y, _S1659.z} - _S1655 - cross_0(_S1656, float3 {_S1657.x, _S1657.y, _S1657.z} - float3 {_S1654.x, _S1654.y, _S1654.z})).z, 0.0f);
        uint _S1660 = sv_0(c_36, slot_4 + 1U);
        float4  _S1661 = *(&(globalParams_0->scratch_0)[_S1660]);
        *(&(globalParams_0->scratch_0)[_S1660]) = make_float4 ((float3 {_S1661.x, _S1661.y, _S1661.z} - _S1656).x, (float3 {_S1661.x, _S1661.y, _S1661.z} - _S1656).y, (float3 {_S1661.x, _S1661.y, _S1661.z} - _S1656).z, 0.0f);
        c_36 = c_36 + 256U;
    }
    __syncthreads();
    return;
}

static __device__ uint statics_result_slot_0(uint island_3)
{
    uint _S1662 = __ldg(&globalParams_0->params_0->statics_base_0);
    uint _S1663 = __ldg(&globalParams_0->params_0->chunk_count_0);
    uint _S1664 = _S1662 + 23U * _S1663;
    uint _S1665 = __ldg(&globalParams_0->params_0->statics_bonds_0);
    return _S1664 + 2U * _S1665 + island_3;
}

static __device__ void write_bond_loads_0(uint _S1666, uint _S1667, float3  _S1668, float3  _S1669, float _S1670)
{
    BondStatic_0 * _S1671 = (&(globalParams_0->bonds_0)[_S1667]);
    float3  _S1672 = to_body_0(_S1667, _S1668);
    float3  _S1673 = to_body_0(_S1667, _S1669);
    uint _S1674 = 3U * _S1666;
    *(&(globalParams_0->scratch_0)[_S1674]) = make_float4 (_S1672.x, _S1672.y, _S1672.z, _S1670);
    float4  * _S1675 = (&(globalParams_0->scratch_0)[_S1674 + 1U]);
    float4  _S1676 = __ldg(&_S1671->ra_0);
    *_S1675 = make_float4 ((_S1673 + cross_0(float3 {_S1676.x, _S1676.y, _S1676.z}, _S1672)).x, (_S1673 + cross_0(float3 {_S1676.x, _S1676.y, _S1676.z}, _S1672)).y, (_S1673 + cross_0(float3 {_S1676.x, _S1676.y, _S1676.z}, _S1672)).z, 0.0f);
    float4  * _S1677 = (&(globalParams_0->scratch_0)[_S1674 + 2U]);
    float3  _S1678 = - _S1673;
    float4  _S1679 = __ldg(&_S1671->rb_0);
    *_S1677 = make_float4 ((_S1678 + cross_0(float3 {_S1679.x, _S1679.y, _S1679.z}, - _S1672)).x, (_S1678 + cross_0(float3 {_S1679.x, _S1679.y, _S1679.z}, - _S1672)).y, (_S1678 + cross_0(float3 {_S1679.x, _S1679.y, _S1679.z}, - _S1672)).z, 0.0f);
    return;
}

static __device__ void bond_kinematics_0(uint _S1680, float3  _S1681, float3  _S1682, float3  _S1683, float3  _S1684, float3  * _S1685, float3  * _S1686)
{
    BondStatic_0 * _S1687 = (&(globalParams_0->bonds_0)[_S1680]);
    float4  _S1688 = __ldg(&_S1687->rb_0);
    float3  _S1689 = _S1683 + cross_0(_S1684, float3 {_S1688.x, _S1688.y, _S1688.z});
    float4  _S1690 = __ldg(&_S1687->ra_0);
    float3  _S1691 = to_local_0(_S1680, _S1689 - (_S1681 + cross_0(_S1682, float3 {_S1690.x, _S1690.y, _S1690.z})));
    *_S1685 = _S1691;
    float3  _S1692 = to_local_0(_S1680, _S1684 - _S1682);
    *_S1686 = _S1692;
    return;
}

extern "C" __global__ void island_statics()
{
    uint _S1693 = 0U;
    uint _S1694;
    uint i_26;
    uint c_37;
    bool converged_0;
    uint _S1695;
    uint _S1696;
    uint _S1697;
    uint _S1698;
    uint _S1699;
    uint _S1700;
    uint i_27;
    uint _S1701;
    uint _S1702;
    uint _S1703;
    uint _S1704;
    uint _S1705;
    uint _S1706 = __ballot_sync(4294967295U, true);
    uint tid_18 = threadIdx.x;
    uint _S1707 = blockIdx.x;
    Island_0 * _S1708 = (&(globalParams_0->islands_0)[_S1707]);
    Island_0 isl_21 = *_S1708;
    uint _S1709 = (*_S1708).info_1.z;
    bool _S1710 = (_S1709 & 8U) == 0U;
    uint _S1711 = __ballot_sync(_S1706, _S1710);
    if(_S1710)
    {
        return;
    }
    else
    {
        uint _S1712 = __ballot_sync(_S1706, true);
        _S1693 = _S1712;
    }
    bool free_0 = ((isl_21.info_1.x) & 1U) == 0U;
    uint c0_1 = isl_21.range_0.x;
    uint c1_1 = isl_21.range_0.y;
    uint b0_0 = isl_21.range_0.z;
    uint _S1713 = isl_21.range_0.w;
    uint _S1714 = c0_1 + tid_18;
    uint c_38 = _S1714;
    uint newton_0;
    newton_0 = _S1693;
    for(;;)
    {
        bool _S1715 = c_38 < c1_1;
        uint _S1716 = __ballot_sync(newton_0, _S1715);
        if(_S1715)
        {
            uint _S1717 = __ballot_sync(newton_0, true);
        }
        else
        {
            uint _S1718 = __ballot_sync(newton_0, false);
            uint _S1719 = __ballot_sync(newton_0, false);
            uint _S1720 = __ballot_sync(_S1693, true);
            _S1694 = _S1720;
            break;
        }
        float4  _S1721 = make_float4 (0.0f);
        *(&(globalParams_0->scratch_0)[sv_0(c_38, 21U)]) = _S1721;
        *(&(globalParams_0->scratch_0)[sv_0(c_38, 22U)]) = _S1721;
        uint _S1722 = __ballot_sync(newton_0, true);
        c_38 = c_38 + 256U;
        newton_0 = _S1722;
    }
    __syncthreads();
    uint _S1723 = __ballot_sync(_S1694, free_0);
    if(free_0)
    {
        Island_0 _S1724 = isl_21;
        project_load_slot_0(tid_18, &_S1724, 0U, _S1723);
        uint _S1725 = __ballot_sync(_S1694, true);
        c_38 = _S1725;
    }
    else
    {
        uint _S1726 = __ballot_sync(_S1694, true);
        c_38 = _S1726;
    }
    float _S1727 = island_dot_0(tid_18, c0_1, c1_1, 0U, 0U, c_38);
    float _S1728 = (F32_max(((F32_sqrt((_S1727)))), (1.00000000317107685e-30f)));
    float _S1729 = __ldg(&globalParams_0->params_0->statics_tol_0);
    uint _S1730 = __ldg(&globalParams_0->params_0->statics_cg_0);
    uint _S1731 = (U32_min((_S1730), (20U * (c1_1 - c0_1) * 6U + 200U)));
    float previous_2 = 1.00000001504746622e+30f;
    float residual_0 = 0.0f;
    newton_0 = 0U;
    uint cg_total_0 = 0U;
    for(;;)
    {
        uint _S1732 = 0U;
        uint _S1733 = __ldg(&globalParams_0->params_0->statics_newton_0);
        bool _S1734 = newton_0 < _S1733;
        uint _S1735 = __ballot_sync(c_38, _S1734);
        if(_S1734)
        {
            uint _S1736 = __ballot_sync(c_38, true);
            _S1732 = _S1736;
        }
        else
        {
            converged_0 = false;
            break;
        }
        uint _S1737 = b0_0 + tid_18;
        i_26 = _S1737;
        uint _S1738;
        _S1738 = _S1732;
        for(;;)
        {
            bool _S1739 = i_26 < _S1713;
            uint _S1740 = __ballot_sync(_S1738, _S1739);
            if(_S1739)
            {
                uint _S1741 = __ballot_sync(_S1738, true);
            }
            else
            {
                uint _S1742 = __ballot_sync(_S1738, false);
                uint _S1743 = __ballot_sync(_S1738, false);
                uint _S1744 = __ballot_sync(_S1732, true);
                _S1695 = _S1744;
                break;
            }
            JointResponse_0 resp_1 = static_response_0(i_26);
            write_bond_loads_0(i_26, i_26, resp_1.force_lin_1, resp_1.force_ang_1, 0.0f);
            uint _S1745 = __ballot_sync(_S1738, true);
            i_26 = i_26 + 256U;
            _S1738 = _S1745;
        }
        __syncthreads();
        float4  _S1746 = make_float4 (0.0f);
        float4  magnitude_0 = _S1746;
        float4  unused_m_0 = _S1746;
        uint c_39 = _S1714;
        uint _S1747 = _S1695;
        for(;;)
        {
            bool _S1748 = c_39 < c1_1;
            uint _S1749 = __ballot_sync(_S1747, _S1748);
            if(_S1748)
            {
                uint _S1750 = __ballot_sync(_S1747, true);
            }
            else
            {
                uint _S1751 = __ballot_sync(_S1747, false);
                uint _S1752 = __ballot_sync(_S1747, false);
                uint _S1753 = __ballot_sync(_S1695, true);
                _S1696 = _S1753;
                break;
            }
            float3  fi_3;
            float3  mi_4;
            gather_loads_0(c_39, &fi_3, &mi_4);
            *&((&magnitude_0)->x) = *&((&magnitude_0)->x) + bond_load_magnitude2_0(c_39);
            float4  _S1754 = *(&(globalParams_0->scratch_0)[sv_0(c_39, 0U)]);
            float4  r_lin_0 = make_float4 ((float3 {_S1754.x, _S1754.y, _S1754.z} + fi_3).x, (float3 {_S1754.x, _S1754.y, _S1754.z} + fi_3).y, (float3 {_S1754.x, _S1754.y, _S1754.z} + fi_3).z, 0.0f);
            float4  _S1755 = *(&(globalParams_0->scratch_0)[sv_0(c_39, 1U)]);
            float4  r_ang_0 = make_float4 ((float3 {_S1755.x, _S1755.y, _S1755.z} + mi_4).x, (float3 {_S1755.x, _S1755.y, _S1755.z} + mi_4).y, (float3 {_S1755.x, _S1755.y, _S1755.z} + mi_4).z, 0.0f);
            hold_0(fixed_mask_0(c_39), &r_lin_0, &r_ang_0, _S1746, _S1746);
            *(&(globalParams_0->scratch_0)[sv_0(c_39, 4U)]) = r_lin_0;
            *(&(globalParams_0->scratch_0)[sv_0(c_39, 5U)]) = r_ang_0;
            uint _S1756 = __ballot_sync(_S1747, true);
            c_39 = c_39 + 256U;
            _S1747 = _S1756;
        }
        __syncthreads();
        group_sum2_0(tid_18, &magnitude_0, &unused_m_0, _S1696);
        uint _S1757 = __ballot_sync(_S1696, free_0);
        uint _S1758;
        if(free_0)
        {
            Island_0 _S1759 = isl_21;
            project_load_slot_0(tid_18, &_S1759, 4U, _S1757);
            uint _S1760 = __ballot_sync(_S1696, true);
            _S1758 = _S1760;
        }
        else
        {
            uint _S1761 = __ballot_sync(_S1696, true);
            _S1758 = _S1761;
        }
        float _S1762 = island_dot_0(tid_18, c0_1, c1_1, 4U, 4U, _S1758);
        float residual_1 = (F32_sqrt((_S1762))) / _S1728;
        float _S1763 = (F32_max((0.00100000004749745f), (3.83999986297567375e-06f * (F32_sqrt((magnitude_0.x))) / _S1728)));
        bool _S1764 = residual_1 <= _S1729;
        uint _S1765 = __ballot_sync(_S1758, _S1764);
        uint _S1766;
        if(_S1764)
        {
            uint _S1767 = __ballot_sync(_S1758, true);
            converged_0 = true;
            _S1766 = _S1767;
        }
        else
        {
            uint _S1768 = _S1758 & (~_S1765);
            bool _S1769 = residual_1 <= _S1763;
            uint _S1770 = __ballot_sync(_S1768, _S1769);
            if(_S1769)
            {
                bool _S1771 = residual_1 > (0.5f * previous_2);
                uint _S1772 = __ballot_sync(_S1768, true);
                converged_0 = _S1771;
            }
            else
            {
                uint _S1773 = __ballot_sync(_S1768, true);
                converged_0 = false;
            }
            uint _S1774 = __ballot_sync(_S1758, true);
            _S1766 = _S1774;
        }
        uint _S1775 = 0U;
        uint _S1776 = __ballot_sync(_S1766, converged_0);
        if(converged_0)
        {
            residual_0 = residual_1;
            converged_0 = true;
            break;
        }
        else
        {
            uint _S1777 = __ballot_sync(_S1766, true);
            _S1775 = _S1777;
        }
        uint i_28 = _S1737;
        uint _S1778;
        _S1778 = _S1775;
        for(;;)
        {
            bool _S1779 = i_28 < _S1713;
            uint _S1780 = __ballot_sync(_S1778, _S1779);
            if(_S1779)
            {
                uint _S1781 = __ballot_sync(_S1778, true);
            }
            else
            {
                uint _S1782 = __ballot_sync(_S1778, false);
                uint _S1783 = __ballot_sync(_S1778, false);
                uint _S1784 = __ballot_sync(_S1775, true);
                _S1697 = _S1784;
                break;
            }
            BondStatic_0 * _S1785 = (&(globalParams_0->bonds_0)[i_28]);
            float3  d_lin_5;
            float3  d_ang_4;
            static_kinematics_0(i_28, &d_lin_5, &d_ang_4);
            JointBond_0 _S1786 = slang_ldg_0(&_S1785->law_0);
            JointBond_0 _S1787 = _S1786;
            JointState_0 _S1788 = (&(globalParams_0->bond_dyn_0)[i_28])->js_0;
            float3  f_lin_2;
            float3  f_ang_2;
            secant_factors_0(&_S1787, &_S1788, d_lin_5, &f_lin_2, &f_ang_2);
            uint _S1789 = statics_bond_slot_0(i_28);
            float _S1790 = _S1786.stiff0_0.y;
            *(&(globalParams_0->scratch_0)[_S1789]) = make_float4 (_S1790 * f_lin_2.x, _S1790 * f_lin_2.y, _S1786.stiff0_0.x * f_lin_2.z, 0.0f);
            *(&(globalParams_0->scratch_0)[_S1789 + 1U]) = make_float4 (_S1786.stiff0_0.z * f_ang_2.x, _S1786.stiff0_0.w * f_ang_2.y, _S1786.stiff1_0.x * f_ang_2.z, 0.0f);
            uint _S1791 = __ballot_sync(_S1778, true);
            i_28 = i_28 + 256U;
            _S1778 = _S1791;
        }
        __syncthreads();
        uint c_40 = _S1714;
        uint _S1792 = _S1697;
        for(;;)
        {
            bool _S1793 = c_40 < c1_1;
            uint _S1794 = __ballot_sync(_S1792, _S1793);
            if(_S1793)
            {
                uint _S1795 = __ballot_sync(_S1792, true);
            }
            else
            {
                uint _S1796 = __ballot_sync(_S1792, false);
                uint _S1797 = __ballot_sync(_S1792, false);
                uint _S1798 = __ballot_sync(_S1697, true);
                _S1698 = _S1798;
                break;
            }
            assemble_block_0(c_40);
            *(&(globalParams_0->scratch_0)[sv_0(c_40, 2U)]) = _S1746;
            *(&(globalParams_0->scratch_0)[sv_0(c_40, 3U)]) = _S1746;
            uint _S1799 = __ballot_sync(_S1792, true);
            c_40 = c_40 + 256U;
            _S1792 = _S1799;
        }
        __syncthreads();
        uint c_41 = _S1714;
        uint _S1800 = _S1698;
        for(;;)
        {
            bool _S1801 = c_41 < c1_1;
            uint _S1802 = __ballot_sync(_S1800, _S1801);
            if(_S1801)
            {
                uint _S1803 = __ballot_sync(_S1800, true);
            }
            else
            {
                uint _S1804 = __ballot_sync(_S1800, false);
                uint _S1805 = __ballot_sync(_S1800, false);
                uint _S1806 = __ballot_sync(_S1698, true);
                _S1699 = _S1806;
                break;
            }
            precondition_0(c_41);
            uint _S1807 = __ballot_sync(_S1800, true);
            c_41 = c_41 + 256U;
            _S1800 = _S1807;
        }
        __syncthreads();
        uint _S1808 = __ballot_sync(_S1699, free_0);
        uint _S1809;
        if(free_0)
        {
            Island_0 _S1810 = isl_21;
            project_displacement_slot_0(tid_18, &_S1810, 6U, _S1808);
            uint _S1811 = __ballot_sync(_S1699, true);
            _S1809 = _S1811;
        }
        else
        {
            uint _S1812 = __ballot_sync(_S1699, true);
            _S1809 = _S1812;
        }
        uint c_42 = _S1714;
        uint _S1813 = _S1809;
        for(;;)
        {
            bool _S1814 = c_42 < c1_1;
            uint _S1815 = __ballot_sync(_S1813, _S1814);
            if(_S1814)
            {
                uint _S1816 = __ballot_sync(_S1813, true);
            }
            else
            {
                uint _S1817 = __ballot_sync(_S1813, false);
                uint _S1818 = __ballot_sync(_S1813, false);
                uint _S1819 = __ballot_sync(_S1809, true);
                _S1700 = _S1819;
                break;
            }
            *(&(globalParams_0->scratch_0)[sv_0(c_42, 8U)]) = *(&(globalParams_0->scratch_0)[sv_0(c_42, 6U)]);
            *(&(globalParams_0->scratch_0)[sv_0(c_42, 9U)]) = *(&(globalParams_0->scratch_0)[sv_0(c_42, 7U)]);
            uint _S1820 = __ballot_sync(_S1813, true);
            c_42 = c_42 + 256U;
            _S1813 = _S1820;
        }
        __syncthreads();
        float _S1821 = island_dot_0(tid_18, c0_1, c1_1, 4U, 6U, _S1700);
        float _S1822 = island_dot_0(tid_18, c0_1, c1_1, 4U, 4U, _S1700);
        float _S1823 = (F32_sqrt((_S1822)));
        float rz_0 = _S1821;
        uint k_22 = 0U;
        uint cg_total_1 = cg_total_0;
        uint _S1824 = _S1700;
        for(;;)
        {
            bool _S1825 = k_22 < _S1731;
            uint _S1826 = __ballot_sync(_S1824, _S1825);
            uint _S1827;
            bool _S1828;
            if(_S1825)
            {
                bool _S1829 = _S1823 > 0.0f;
                uint _S1830 = __ballot_sync(_S1824, true);
                _S1828 = _S1829;
                _S1827 = _S1830;
            }
            else
            {
                uint _S1831 = __ballot_sync(_S1824, true);
                _S1828 = false;
                _S1827 = _S1831;
            }
            uint _S1832 = 0U;
            uint _S1833 = __ballot_sync(_S1827, _S1828);
            if(_S1828)
            {
                uint _S1834 = __ballot_sync(_S1827, true);
                _S1832 = _S1834;
            }
            else
            {
                uint _S1835 = __ballot_sync(_S1827, false);
                uint _S1836 = __ballot_sync(_S1824, false);
                uint _S1837 = __ballot_sync(_S1700, true);
                cg_total_0 = cg_total_1;
                i_27 = _S1837;
                break;
            }
            i_27 = _S1737;
            _S1701 = _S1832;
            for(;;)
            {
                bool _S1838 = i_27 < _S1713;
                uint _S1839 = __ballot_sync(_S1701, _S1838);
                if(_S1838)
                {
                    uint _S1840 = __ballot_sync(_S1701, true);
                }
                else
                {
                    uint _S1841 = __ballot_sync(_S1701, false);
                    uint _S1842 = __ballot_sync(_S1701, false);
                    uint _S1843 = __ballot_sync(_S1832, true);
                    _S1702 = _S1843;
                    break;
                }
                JointBond_0 _S1844 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_27])->law_0);
                uint ca_2 = _S1844.ids_0.y;
                uint cb_2 = _S1844.ids_0.z;
                float4  _S1845 = *(&(globalParams_0->scratch_0)[sv_0(ca_2, 8U)]);
                float4  _S1846 = *(&(globalParams_0->scratch_0)[sv_0(ca_2, 9U)]);
                float4  _S1847 = *(&(globalParams_0->scratch_0)[sv_0(cb_2, 8U)]);
                float4  _S1848 = *(&(globalParams_0->scratch_0)[sv_0(cb_2, 9U)]);
                float3  d_lin_6;
                float3  d_ang_5;
                bond_kinematics_0(i_27, float3 {_S1845.x, _S1845.y, _S1845.z}, float3 {_S1846.x, _S1846.y, _S1846.z}, float3 {_S1847.x, _S1847.y, _S1847.z}, float3 {_S1848.x, _S1848.y, _S1848.z}, &d_lin_6, &d_ang_5);
                uint _S1849 = statics_bond_slot_0(i_27);
                float4  _S1850 = *(&(globalParams_0->scratch_0)[_S1849]);
                float4  _S1851 = *(&(globalParams_0->scratch_0)[_S1849 + 1U]);
                write_bond_loads_0(i_27, i_27, d_lin_6 * float3 {_S1850.x, _S1850.y, _S1850.z}, d_ang_5 * float3 {_S1851.x, _S1851.y, _S1851.z}, 0.0f);
                uint _S1852 = __ballot_sync(_S1701, true);
                i_27 = i_27 + 256U;
                _S1701 = _S1852;
            }
            __syncthreads();
            c_37 = _S1714;
            uint _S1853 = _S1702;
            for(;;)
            {
                bool _S1854 = c_37 < c1_1;
                uint _S1855 = __ballot_sync(_S1853, _S1854);
                if(_S1854)
                {
                    uint _S1856 = __ballot_sync(_S1853, true);
                }
                else
                {
                    uint _S1857 = __ballot_sync(_S1853, false);
                    uint _S1858 = __ballot_sync(_S1853, false);
                    uint _S1859 = __ballot_sync(_S1702, true);
                    _S1703 = _S1859;
                    break;
                }
                float3  fi_4;
                float3  mi_5;
                gather_loads_0(c_37, &fi_4, &mi_5);
                float4  ap_lin_0 = make_float4 ((- fi_4).x, (- fi_4).y, (- fi_4).z, 0.0f);
                float4  ap_ang_0 = make_float4 ((- mi_5).x, (- mi_5).y, (- mi_5).z, 0.0f);
                hold_0(fixed_mask_0(c_37), &ap_lin_0, &ap_ang_0, *(&(globalParams_0->scratch_0)[sv_0(c_37, 8U)]), *(&(globalParams_0->scratch_0)[sv_0(c_37, 9U)]));
                *(&(globalParams_0->scratch_0)[sv_0(c_37, 10U)]) = ap_lin_0;
                *(&(globalParams_0->scratch_0)[sv_0(c_37, 11U)]) = ap_ang_0;
                uint _S1860 = __ballot_sync(_S1853, true);
                c_37 = c_37 + 256U;
                _S1853 = _S1860;
            }
            uint _S1861 = 0U;
            __syncthreads();
            float _S1862 = island_dot_0(tid_18, c0_1, c1_1, 8U, 10U, _S1703);
            uint _S1863 = cg_total_1 + 1U;
            bool _S1864 = _S1862 <= 0.0f;
            uint _S1865 = __ballot_sync(_S1703, _S1864);
            if(_S1864)
            {
                uint _S1866 = __ballot_sync(_S1703, false);
                uint _S1867 = __ballot_sync(_S1824, false);
                uint _S1868 = __ballot_sync(_S1700, true);
                cg_total_0 = _S1863;
                i_27 = _S1868;
                break;
            }
            else
            {
                uint _S1869 = __ballot_sync(_S1703, true);
                _S1861 = _S1869;
            }
            float _S1870 = rz_0 / _S1862;
            uint c_43 = _S1714;
            uint _S1871;
            _S1871 = _S1861;
            for(;;)
            {
                bool _S1872 = c_43 < c1_1;
                uint _S1873 = __ballot_sync(_S1871, _S1872);
                if(_S1872)
                {
                    uint _S1874 = __ballot_sync(_S1871, true);
                }
                else
                {
                    uint _S1875 = __ballot_sync(_S1871, false);
                    uint _S1876 = __ballot_sync(_S1871, false);
                    uint _S1877 = __ballot_sync(_S1861, true);
                    _S1704 = _S1877;
                    break;
                }
                uint _S1878 = sv_0(c_43, 2U);
                float4  _S1879 = *(&(globalParams_0->scratch_0)[_S1878]);
                float4  _S1880 = *(&(globalParams_0->scratch_0)[sv_0(c_43, 8U)]);
                *(&(globalParams_0->scratch_0)[_S1878]) = make_float4 ((float3 {_S1879.x, _S1879.y, _S1879.z} + make_float3 (_S1870) * float3 {_S1880.x, _S1880.y, _S1880.z}).x, (float3 {_S1879.x, _S1879.y, _S1879.z} + make_float3 (_S1870) * float3 {_S1880.x, _S1880.y, _S1880.z}).y, (float3 {_S1879.x, _S1879.y, _S1879.z} + make_float3 (_S1870) * float3 {_S1880.x, _S1880.y, _S1880.z}).z, 0.0f);
                uint _S1881 = sv_0(c_43, 3U);
                float4  _S1882 = *(&(globalParams_0->scratch_0)[_S1881]);
                float4  _S1883 = *(&(globalParams_0->scratch_0)[sv_0(c_43, 9U)]);
                *(&(globalParams_0->scratch_0)[_S1881]) = make_float4 ((float3 {_S1882.x, _S1882.y, _S1882.z} + make_float3 (_S1870) * float3 {_S1883.x, _S1883.y, _S1883.z}).x, (float3 {_S1882.x, _S1882.y, _S1882.z} + make_float3 (_S1870) * float3 {_S1883.x, _S1883.y, _S1883.z}).y, (float3 {_S1882.x, _S1882.y, _S1882.z} + make_float3 (_S1870) * float3 {_S1883.x, _S1883.y, _S1883.z}).z, 0.0f);
                uint _S1884 = sv_0(c_43, 4U);
                float4  _S1885 = *(&(globalParams_0->scratch_0)[_S1884]);
                float4  _S1886 = *(&(globalParams_0->scratch_0)[sv_0(c_43, 10U)]);
                *(&(globalParams_0->scratch_0)[_S1884]) = make_float4 ((float3 {_S1885.x, _S1885.y, _S1885.z} - make_float3 (_S1870) * float3 {_S1886.x, _S1886.y, _S1886.z}).x, (float3 {_S1885.x, _S1885.y, _S1885.z} - make_float3 (_S1870) * float3 {_S1886.x, _S1886.y, _S1886.z}).y, (float3 {_S1885.x, _S1885.y, _S1885.z} - make_float3 (_S1870) * float3 {_S1886.x, _S1886.y, _S1886.z}).z, 0.0f);
                uint _S1887 = sv_0(c_43, 5U);
                float4  _S1888 = *(&(globalParams_0->scratch_0)[_S1887]);
                float4  _S1889 = *(&(globalParams_0->scratch_0)[sv_0(c_43, 11U)]);
                *(&(globalParams_0->scratch_0)[_S1887]) = make_float4 ((float3 {_S1888.x, _S1888.y, _S1888.z} - make_float3 (_S1870) * float3 {_S1889.x, _S1889.y, _S1889.z}).x, (float3 {_S1888.x, _S1888.y, _S1888.z} - make_float3 (_S1870) * float3 {_S1889.x, _S1889.y, _S1889.z}).y, (float3 {_S1888.x, _S1888.y, _S1888.z} - make_float3 (_S1870) * float3 {_S1889.x, _S1889.y, _S1889.z}).z, 0.0f);
                uint _S1890 = __ballot_sync(_S1871, true);
                c_43 = c_43 + 256U;
                _S1871 = _S1890;
            }
            uint _S1891 = 0U;
            __syncthreads();
            float _S1892 = island_dot_0(tid_18, c0_1, c1_1, 4U, 4U, _S1704);
            bool _S1893 = (F32_sqrt((_S1892))) <= (0.00009999999747379f * _S1823);
            uint _S1894 = __ballot_sync(_S1704, _S1893);
            if(_S1893)
            {
                uint _S1895 = __ballot_sync(_S1704, false);
                uint _S1896 = __ballot_sync(_S1824, false);
                uint _S1897 = __ballot_sync(_S1700, true);
                cg_total_0 = _S1863;
                i_27 = _S1897;
                break;
            }
            else
            {
                uint _S1898 = __ballot_sync(_S1704, true);
                _S1891 = _S1898;
            }
            uint c_44 = _S1714;
            uint _S1899;
            _S1899 = _S1891;
            for(;;)
            {
                bool _S1900 = c_44 < c1_1;
                uint _S1901 = __ballot_sync(_S1899, _S1900);
                if(_S1900)
                {
                    uint _S1902 = __ballot_sync(_S1899, true);
                }
                else
                {
                    uint _S1903 = __ballot_sync(_S1899, false);
                    uint _S1904 = __ballot_sync(_S1899, false);
                    uint _S1905 = __ballot_sync(_S1891, true);
                    _S1705 = _S1905;
                    break;
                }
                precondition_0(c_44);
                uint _S1906 = __ballot_sync(_S1899, true);
                c_44 = c_44 + 256U;
                _S1899 = _S1906;
            }
            __syncthreads();
            uint _S1907 = __ballot_sync(_S1705, free_0);
            uint _S1908;
            if(free_0)
            {
                Island_0 _S1909 = isl_21;
                project_displacement_slot_0(tid_18, &_S1909, 6U, _S1907);
                uint _S1910 = __ballot_sync(_S1705, true);
                _S1908 = _S1910;
            }
            else
            {
                uint _S1911 = __ballot_sync(_S1705, true);
                _S1908 = _S1911;
            }
            float _S1912 = island_dot_0(tid_18, c0_1, c1_1, 4U, 6U, _S1908);
            float _S1913 = _S1912 / rz_0;
            uint c_45 = _S1714;
            uint _S1914 = _S1908;
            for(;;)
            {
                bool _S1915 = c_45 < c1_1;
                uint _S1916 = __ballot_sync(_S1914, _S1915);
                if(_S1915)
                {
                    uint _S1917 = __ballot_sync(_S1914, true);
                }
                else
                {
                    uint _S1918 = __ballot_sync(_S1914, false);
                    uint _S1919 = __ballot_sync(_S1914, false);
                    uint _S1920 = __ballot_sync(_S1908, true);
                    break;
                }
                uint _S1921 = sv_0(c_45, 8U);
                float4  _S1922 = *(&(globalParams_0->scratch_0)[sv_0(c_45, 6U)]);
                float4  _S1923 = *(&(globalParams_0->scratch_0)[_S1921]);
                *(&(globalParams_0->scratch_0)[_S1921]) = make_float4 ((float3 {_S1922.x, _S1922.y, _S1922.z} + make_float3 (_S1913) * float3 {_S1923.x, _S1923.y, _S1923.z}).x, (float3 {_S1922.x, _S1922.y, _S1922.z} + make_float3 (_S1913) * float3 {_S1923.x, _S1923.y, _S1923.z}).y, (float3 {_S1922.x, _S1922.y, _S1922.z} + make_float3 (_S1913) * float3 {_S1923.x, _S1923.y, _S1923.z}).z, 0.0f);
                uint _S1924 = sv_0(c_45, 9U);
                float4  _S1925 = *(&(globalParams_0->scratch_0)[sv_0(c_45, 7U)]);
                float4  _S1926 = *(&(globalParams_0->scratch_0)[_S1924]);
                *(&(globalParams_0->scratch_0)[_S1924]) = make_float4 ((float3 {_S1925.x, _S1925.y, _S1925.z} + make_float3 (_S1913) * float3 {_S1926.x, _S1926.y, _S1926.z}).x, (float3 {_S1925.x, _S1925.y, _S1925.z} + make_float3 (_S1913) * float3 {_S1926.x, _S1926.y, _S1926.z}).y, (float3 {_S1925.x, _S1925.y, _S1925.z} + make_float3 (_S1913) * float3 {_S1926.x, _S1926.y, _S1926.z}).z, 0.0f);
                uint _S1927 = __ballot_sync(_S1914, true);
                c_45 = c_45 + 256U;
                _S1914 = _S1927;
            }
            __syncthreads();
            uint _S1928 = __ballot_sync(_S1824, true);
            uint _S1929 = k_22 + 1U;
            rz_0 = _S1912;
            k_22 = _S1929;
            cg_total_1 = _S1863;
            _S1824 = _S1928;
        }
        c_37 = _S1714;
        _S1701 = i_27;
        for(;;)
        {
            bool _S1930 = c_37 < c1_1;
            uint _S1931 = __ballot_sync(_S1701, _S1930);
            if(_S1930)
            {
                uint _S1932 = __ballot_sync(_S1701, true);
            }
            else
            {
                uint _S1933 = __ballot_sync(_S1701, false);
                uint _S1934 = __ballot_sync(_S1701, false);
                uint _S1935 = __ballot_sync(i_27, true);
                break;
            }
            uint _S1936 = 4U * c_37;
            float4  _S1937 = *(&(globalParams_0->state_0)[_S1936]);
            float3  u_4 = float3 {_S1937.x, _S1937.y, _S1937.z};
            uint _S1938 = sv_0(c_37, 21U);
            float4  _S1939 = *(&(globalParams_0->scratch_0)[_S1938]);
            float3  u_lo_0 = float3 {_S1939.x, _S1939.y, _S1939.z};
            uint _S1940 = _S1936 + 1U;
            float4  _S1941 = *(&(globalParams_0->state_0)[_S1940]);
            float3  th_5 = float3 {_S1941.x, _S1941.y, _S1941.z};
            uint _S1942 = sv_0(c_37, 22U);
            float4  _S1943 = *(&(globalParams_0->scratch_0)[_S1942]);
            float3  th_lo_0 = float3 {_S1943.x, _S1943.y, _S1943.z};
            float4  _S1944 = *(&(globalParams_0->scratch_0)[sv_0(c_37, 2U)]);
            comp_add_0(&u_4, &u_lo_0, float3 {_S1944.x, _S1944.y, _S1944.z});
            float4  _S1945 = *(&(globalParams_0->scratch_0)[sv_0(c_37, 3U)]);
            comp_add_0(&th_5, &th_lo_0, float3 {_S1945.x, _S1945.y, _S1945.z});
            *(&(globalParams_0->state_0)[_S1936]) = make_float4 (u_4.x, u_4.y, u_4.z, (*(&(globalParams_0->state_0)[_S1936])).w);
            *(&(globalParams_0->state_0)[_S1940]) = make_float4 (th_5.x, th_5.y, th_5.z, (*(&(globalParams_0->state_0)[_S1940])).w);
            *(&(globalParams_0->scratch_0)[_S1938]) = make_float4 (u_lo_0.x, u_lo_0.y, u_lo_0.z, 0.0f);
            *(&(globalParams_0->scratch_0)[_S1942]) = make_float4 (th_lo_0.x, th_lo_0.y, th_lo_0.z, 0.0f);
            uint _S1946 = __ballot_sync(_S1701, true);
            c_37 = c_37 + 256U;
            _S1701 = _S1946;
        }
        __syncthreads();
        uint _S1947 = newton_0 + 1U;
        uint _S1948 = __ballot_sync(c_38, true);
        previous_2 = residual_1;
        residual_0 = residual_1;
        newton_0 = _S1947;
        c_38 = _S1948;
    }
    i_26 = b0_0 + tid_18;
    for(;;)
    {
        if(i_26 < _S1713)
        {
        }
        else
        {
            break;
        }
        JointResponse_0 resp_2 = static_response_0(i_26);
        BondDyn_0 bd_1 = *(&(globalParams_0->bond_dyn_0)[i_26]);
        (&bd_1)->force_lin_0 = make_float4 (resp_2.force_lin_1.x, resp_2.force_lin_1.y, resp_2.force_lin_1.z, resp_2.stored_5);
        (&bd_1)->force_ang_0 = make_float4 (resp_2.force_ang_1.x, resp_2.force_ang_1.y, resp_2.force_ang_1.z, (&bd_1)->force_ang_0.w);
        *(&(globalParams_0->bond_dyn_0)[i_26]) = bd_1;
        write_bond_loads_0(i_26, i_26, resp_2.force_lin_1, resp_2.force_ang_1, (F32_max((resp_2.measures_0.tension_0), (resp_2.measures_0.compression_0))));
        i_26 = i_26 + 256U;
    }
    __syncthreads();
    c_37 = _S1714;
    for(;;)
    {
        if(c_37 < c1_1)
        {
        }
        else
        {
            break;
        }
        float3  fi_5;
        float3  mi_6;
        gather_loads_0(c_37, &fi_5, &mi_6);
        float3  reaction_1;
        if((fixed_mask_0(c_37)) != 0U)
        {
            float4  _S1949 = *(&(globalParams_0->scratch_0)[sv_0(c_37, 0U)]);
            reaction_1 = - (float3 {_S1949.x, _S1949.y, _S1949.z} + fi_5);
        }
        else
        {
            uint _S1950 = 4U * c_37;
            reaction_1 = make_float3 ((*(&(globalParams_0->state_0)[_S1950 + 1U])).w, (*(&(globalParams_0->state_0)[_S1950 + 2U])).w, (*(&(globalParams_0->state_0)[_S1950 + 3U])).w);
        }
        uint _S1951 = 4U * c_37;
        uint _S1952 = _S1951 + 1U;
        float4  _S1953 = *(&(globalParams_0->state_0)[_S1952]);
        *(&(globalParams_0->state_0)[_S1952]) = make_float4 (float3 {_S1953.x, _S1953.y, _S1953.z}.x, float3 {_S1953.x, _S1953.y, _S1953.z}.y, float3 {_S1953.x, _S1953.y, _S1953.z}.z, reaction_1.x);
        *(&(globalParams_0->state_0)[_S1951 + 2U]) = make_float4 (0.0f, 0.0f, 0.0f, reaction_1.y);
        *(&(globalParams_0->state_0)[_S1951 + 3U]) = make_float4 (0.0f, 0.0f, 0.0f, reaction_1.z);
        c_37 = c_37 + 256U;
    }
    if(tid_18 == 0U)
    {
        float4  * _S1954 = (&(globalParams_0->scratch_0)[statics_result_slot_0(_S1707)]);
        float _S1955 = (U32_asfloat((newton_0)));
        float _S1956 = (U32_asfloat((cg_total_0)));
        if(converged_0)
        {
            previous_2 = 1.0f;
        }
        else
        {
            previous_2 = 0.0f;
        }
        *_S1954 = make_float4 (residual_0, _S1955, _S1956, previous_2);
        *&((&(&(globalParams_0->islands_0)[_S1707])->info_1)->z) = _S1709 & 4294967287U;
    }
    return;
}

extern "C" __global__ void settled_fatigue()
{
    uint tid_19 = threadIdx.x;
    uint _S1957 = blockIdx.x;
    Island_0 * _S1958 = (&(globalParams_0->islands_0)[_S1957]);
    Island_0 isl_22 = *_S1958;
    bool _S1959;
    if((((*_S1958).info_1.x) & 16U) == 0U)
    {
        _S1959 = true;
    }
    else
    {
        _S1959 = (isl_22.range_0.w) == (isl_22.range_0.z);
    }
    if(_S1959)
    {
        return;
    }
    seen_clear_0(tid_19);
    if(tid_19 == 0U)
    {
        *&g_halt_0 = 0U;
        *&g_run_0 = 0U;
    }
    __syncthreads();
    uint _S1960 = isl_22.info_1.w;
    uint i_29 = isl_22.range_0.z + tid_19;
    for(;;)
    {
        if(i_29 < (isl_22.range_0.w))
        {
        }
        else
        {
            break;
        }
        BondStatic_0 * _S1961 = (&(globalParams_0->bonds_0)[i_29]);
        BondDyn_0 bd_2 = *(&(globalParams_0->bond_dyn_0)[i_29]);
        JointBond_0 _S1962 = slang_ldg_0(&_S1961->law_0);
        uint _S1963 = 4U * _S1962.ids_0.y;
        float4  _S1964 = *(&(globalParams_0->state_0)[_S1963]);
        float4  _S1965 = *(&(globalParams_0->state_0)[_S1963 + 1U]);
        uint _S1966 = 4U * _S1962.ids_0.z;
        float4  _S1967 = *(&(globalParams_0->state_0)[_S1966]);
        float4  _S1968 = *(&(globalParams_0->state_0)[_S1966 + 1U]);
        float3  d_lin_7;
        float3  d_ang_6;
        bond_kinematics_0(i_29, float3 {_S1964.x, _S1964.y, _S1964.z}, float3 {_S1965.x, _S1965.y, _S1965.z}, float3 {_S1967.x, _S1967.y, _S1967.z}, float3 {_S1968.x, _S1968.y, _S1968.z}, &d_lin_7, &d_ang_6);
        JointState_0 previous_3 = (&bd_2)->js_0;
        float3  _S1969 = d_lin_7;
        float3  _S1970 = d_ang_6;
        float _S1971 = __ldg(&globalParams_0->params_0->dt_0);
        uint _S1972 = __ldg(&globalParams_0->params_0->fracture_0);
        bool _S1973 = _S1972 != 0U;
        JointBond_0 _S1974 = _S1962;
        JointState_0 _S1975 = previous_3;
        JointResponse_0 _S1976 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S1962.ids_0.x], &_S1974, &_S1975, _S1969, _S1970, _S1971, _S1973);
        if((_S1976.state_1.damage_0) > (previous_3.damage_0 + 9.99999971718068537e-10f))
        {
            _S1959 = true;
        }
        else
        {
            _S1959 = (_S1976.state_1.crush_0) > (previous_3.crush_0 + 9.99999971718068537e-10f);
        }
        uint flags_3;
        if(_S1959)
        {
            flags_3 = 16U;
        }
        else
        {
            flags_3 = 0U;
        }
        comp_add1_0(&((&(&bd_2)->sums_0)->x), &((&(&bd_2)->comps_0)->x), _S1976.dissipated_2);
        comp_add1_0(&((&(&bd_2)->sums_0)->y), &((&(&bd_2)->comps_0)->y), _S1976.overshoot_0);
        (&bd_2)->force_lin_0 = make_float4 (_S1976.force_lin_1.x, _S1976.force_lin_1.y, _S1976.force_lin_1.z, _S1976.stored_5);
        (&bd_2)->force_ang_0 = make_float4 (_S1976.force_ang_1.x, _S1976.force_ang_1.y, _S1976.force_ang_1.z, (F32_max(((&bd_2)->force_ang_0.w), (_S1976.state_1.utilization_0))));
        JointState_0 _S1977 = previous_3;
        bool _S1978 = is_damaged_0(&_S1977);
        bool _S1979;
        if(!_S1978)
        {
            JointState_0 _S1980 = _S1976.state_1;
            bool _S1981 = is_damaged_0(&_S1980);
            _S1979 = _S1981;
        }
        else
        {
            _S1979 = false;
        }
        bool _S1982;
        if(_S1979)
        {
            _S1982 = ((&bd_2)->events_0.x) == 0U;
        }
        else
        {
            _S1982 = false;
        }
        if(_S1982)
        {
            *&((&(&bd_2)->events_0)->x) = _S1960;
            *&((&(&bd_2)->events_0)->w) = _S1976.state_1.mode_0;
            (*&g_seen_0)[3U] = 1U;
        }
        bool _S1983;
        if(((&bd_2)->events_0.y) == 0U)
        {
            _S1983 = (_S1976.state_1.life_0) != (previous_3.life_0);
        }
        else
        {
            _S1983 = false;
        }
        bool _S1984;
        if(_S1983)
        {
            _S1984 = (_S1976.fatigue_before_0) > 0.99000000953674316f;
        }
        else
        {
            _S1984 = false;
        }
        bool _S1985;
        if(_S1984)
        {
            float _S1986 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S1962.ids_0.x], _S1976.state_1.life_0);
            _S1985 = _S1986 <= 0.99000000953674316f;
        }
        else
        {
            _S1985 = false;
        }
        if(_S1985)
        {
            *&((&(&bd_2)->events_0)->y) = _S1960;
            (*&g_seen_0)[4U] = 1U;
        }
        uint flags_4;
        if(_S1976.disconnected_0)
        {
            *&((&(&bd_2)->events_0)->z) = _S1960;
            flags_4 = flags_3 | 32U;
        }
        else
        {
            flags_4 = flags_3;
        }
        (&bd_2)->js_0 = _S1976.state_1;
        *(&(globalParams_0->bond_dyn_0)[i_29]) = bd_2;
        write_bond_loads_0(i_29, i_29, _S1976.force_lin_1, _S1976.force_ang_1, (F32_max((_S1976.measures_0.tension_0), (_S1976.measures_0.compression_0))));
        if((flags_4 & 16U) != 0U)
        {
            *&g_halt_0 = 1U;
        }
        if((flags_4 & 32U) != 0U)
        {
            *&g_run_0 = 1U;
        }
        i_29 = i_29 + 256U;
    }
    __syncthreads();
    if(tid_19 != 0U)
    {
        return;
    }
    if(((*&g_halt_0) | (*&g_run_0)) != 0U)
    {
        uint _S1987 = isl_22.info_1.z;
        if((*&g_halt_0) != 0U)
        {
            i_29 = 16U;
        }
        else
        {
            i_29 = 0U;
        }
        uint _S1988 = _S1987 | i_29;
        if((*&g_run_0) != 0U)
        {
            i_29 = 32U;
        }
        else
        {
            i_29 = 0U;
        }
        *&((&(&(globalParams_0->islands_0)[_S1957])->info_1)->z) = _S1988 | i_29;
    }
    uint _S1989 = ((isl_22.coverage_0) | 16384U) | (seen_bits_0());
    if((*&g_run_0) != 0U)
    {
        i_29 = 128U;
    }
    else
    {
        i_29 = 0U;
    }
    (&(globalParams_0->islands_0)[_S1957])->coverage_0 = _S1989 | i_29;
    return;
}

