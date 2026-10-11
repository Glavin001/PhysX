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
    float4  start_rot_0;
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

static __device__ Quat_0 quat_mul_0(Quat_0 * a_6, Quat_0 * o_0)
{
    Quat_0 r_4;
    (&r_4)->w_1 = a_6->w_1 * o_0->w_1 - a_6->x_11 * o_0->x_11 - a_6->y_4 * o_0->y_4 - a_6->z_0 * o_0->z_0;
    (&r_4)->x_11 = a_6->w_1 * o_0->x_11 + a_6->x_11 * o_0->w_1 + a_6->y_4 * o_0->z_0 - a_6->z_0 * o_0->y_4;
    (&r_4)->y_4 = a_6->w_1 * o_0->y_4 - a_6->x_11 * o_0->z_0 + a_6->y_4 * o_0->w_1 + a_6->z_0 * o_0->x_11;
    (&r_4)->z_0 = a_6->w_1 * o_0->z_0 + a_6->x_11 * o_0->y_4 - a_6->y_4 * o_0->x_11 + a_6->z_0 * o_0->w_1;
    return r_4;
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
    float travel_0 = length_0(_S323 + (wp_0.lo_0 - float3 {_S324.x, _S324.y, _S324.z}) + wp_0.rel_0);
    float travel_1;
    if((_S321.w) != 0U)
    {
        float4  _S325 = *(&(globalParams_0->state_0)[4U * c_4 + 1U]);
        float3  th_1 = float3 {_S325.x, _S325.y, _S325.z};
        uint4  _S326 = __ldg(&_S320->info_0);
        Quat_0 _S327 = from_axis_angle_0(th_1, length_0(th_1));
        Quat_0 _S328 = quat_of_0((&(globalParams_0->islands_0)[_S326.y])->rotation_0);
        Quat_0 _S329 = _S327;
        Quat_0 _S330 = quat_mul_0(&_S328, &_S329);
        float4  _S331 = __ldg(&_S320->start_rot_0);
        Quat_0 _S332 = quat_of_0(make_float4 ((- float3 {_S331.x, _S331.y, _S331.z}).x, (- float3 {_S331.x, _S331.y, _S331.z}).y, (- float3 {_S331.x, _S331.y, _S331.z}).z, _S331.w));
        Quat_0 _S333 = _S330;
        Quat_0 _S334 = quat_mul_0(&_S332, &_S333);
        float _S335 = 2.0f * (F32_atan2((length_0(make_float3 (_S334.x_11, _S334.y_4, _S334.z_0))), ((F32_abs((_S334.w_1))))));
        float4  _S336 = __ldg(&_S320->half_0);
        travel_1 = travel_0 + _S335 * _S336.w;
    }
    else
    {
        travel_1 = travel_0;
    }
    if(travel_1 > (_S322.w))
    {
        uint _S337 = __ldg(&globalParams_0->params_0->halt_index_0);
        uint _S338 = __ldg(&globalParams_0->params_0->halt_index_0);
        *&((&(&(globalParams_0->islands_0)[_S337])->info_1)->z) = ((&(globalParams_0->islands_0)[_S338])->info_1.z) | 1U;
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
    uint _S339 = __ldg(&globalParams_0->params_0->pair_count_0);
    if(i_9 < _S339)
    {
        pair_contact_0(i_9);
    }
    else
    {
        uint _S340 = __ldg(&globalParams_0->params_0->pair_count_0);
        uint _S341 = __ldg(&globalParams_0->params_0->cand_count_0);
        if(i_9 < (_S340 + _S341))
        {
            uint _S342 = __ldg(&globalParams_0->params_0->pair_count_0);
            impactor_candidate_forces_0(i_9 - _S342);
        }
        else
        {
            uint _S343 = __ldg(&globalParams_0->params_0->pair_count_0);
            uint _S344 = __ldg(&globalParams_0->params_0->cand_count_0);
            uint _S345 = _S343 + _S344;
            uint _S346 = __ldg(&globalParams_0->params_0->chunk_count_0);
            if(i_9 < (_S345 + _S346))
            {
                uint _S347 = __ldg(&globalParams_0->params_0->pair_count_0);
                uint _S348 = i_9 - _S347;
                uint _S349 = __ldg(&globalParams_0->params_0->cand_count_0);
                travel_check_0(_S348 - _S349);
            }
        }
    }
    return;
}

extern "C" __global__ void impactor_shares()
{
    uint k_6 = (blockIdx * blockDim + threadIdx).x;
    uint _S350 = __ldg(&globalParams_0->params_0->cand_count_0);
    bool _S351;
    if(k_6 >= _S350)
    {
        _S351 = true;
    }
    else
    {
        _S351 = stopped_0();
    }
    if(_S351)
    {
        return;
    }
    uint _S352 = __ldg(&globalParams_0->params_0->cand_index_0);
    uint _S353 = 3U * k_6;
    uint at_2 = _S352 + _S353;
    uint _S354 = __ldg((&(globalParams_0->index_0)[at_2]));
    uint _S355 = __ldg((&(globalParams_0->index_0)[at_2 + 2U]));
    Impactor_0 * _S356 = (&(globalParams_0->impactors_0)[_S355]);
    Impactor_0 imp_4 = *_S356;
    if(((*_S356).cand_0.z) == 0U)
    {
        _S351 = (imp_4.crush_1.x) > 0.0f;
    }
    else
    {
        _S351 = false;
    }
    float total_0;
    float ksum_0;
    if(_S351)
    {
        WorldPoint_0 _S357 = impactor_point_0(_S355);
        WorldPoint_0 _S358 = chunk_world_0(_S354);
        WorldPoint_0 _S359 = _S357;
        float3  _S360 = world_diff_0(&_S358, &_S359);
        float _S361 = length_0(_S360);
        float _S362 = imp_4.half_1.w;
        float4  _S363 = __ldg(&(&(globalParams_0->chunks_0)[_S354])->half_0);
        if(!(_S361 > (_S362 + _S363.w)))
        {
            float4  _S364 = imp_4.half_1;
            Box_0 _S365 = impactor_box_1(_S355, make_float3 (0.0f), float3 {_S364.x, _S364.y, _S364.z});
            Box_0 b_20 = chunk_box_0(_S354, _S360);
            float _S366 = imp_4.mat_0.x;
            float4  _S367 = __ldg(&(&(globalParams_0->chunks_0)[_S354])->cmat_0);
            float _S368 = _S367.x;
            float3  _S369 = b_20.center_1 - _S365.center_1;
            Box_0 _S370 = _S365;
            Box_0 _S371 = b_20;
            float _S372 = contact_stiffness_0(_S366, &_S370, _S368, &_S371, _S369);
            float _S373 = imp_4.crush_1.w;
            Box_0 _S374 = _S365;
            Box_0 _S375 = impactor_shrunk_0(_S355, _S373, &_S374);
            Box_0 _S376 = _S375;
            Box_0 _S377 = b_20;
            uint _S378 = impactor_contact_count_0(_S355, _S373, &_S376, &_S377);
            float _S379;
            if((imp_4.shape_0.x) == 0.0f)
            {
                _S379 = _S372;
            }
            else
            {
                _S379 = _S372 / (F32_max((float(_S378)), (10.0f)));
            }
            uint j_3 = 0U;
            total_0 = 0.0f;
            ksum_0 = 0.0f;
            for(;;)
            {
                if(_S378 > 0U)
                {
                    Impactor_0 _S380 = imp_4;
                    Box_0 _S381 = b_20;
                    uint _S382 = impactor_slots_0(&_S380, &_S381);
                    _S351 = j_3 < _S382;
                }
                else
                {
                    _S351 = false;
                }
                if(_S351)
                {
                }
                else
                {
                    break;
                }
                Impactor_0 _S383 = imp_4;
                Box_0 _S384 = _S375;
                Box_0 _S385 = b_20;
                float3  p_7;
                float3  nrm_1;
                float dep_1;
                bool _S386 = impactor_contact_0(&_S383, _S373, &_S384, &_S385, j_3, &p_7, &nrm_1, &dep_1);
                if(!_S386)
                {
                    j_3 = j_3 + 1U;
                    continue;
                }
                float ksum_1 = ksum_0 + _S379;
                total_0 = total_0 + _S379 * dep_1;
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
    uint _S387 = __ldg(&globalParams_0->params_0->cand_base_0);
    float4  data_1 = *(&(globalParams_0->scratch_0)[_S387 + _S353]);
    uint _S388 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S388 + _S353]) = make_float4 (total_0, ksum_0, data_1.z, data_1.w);
    return;
}

extern "C" __global__ void impactor_crush()
{
    uint _S389;
    uint _S390 = __ballot_sync(4294967295U, true);
    uint ii_0 = blockIdx.x;
    uint tid_2 = threadIdx.x;
    uint _S391 = __ldg(&globalParams_0->params_0->impactor_count_0);
    bool _S392 = ii_0 >= _S391;
    uint _S393 = __ballot_sync(_S390, _S392);
    bool _S394;
    uint k_7;
    if(_S392)
    {
        uint _S395 = __ballot_sync(_S390, true);
        _S394 = true;
        k_7 = _S395;
    }
    else
    {
        bool _S396 = stopped_0();
        uint _S397 = __ballot_sync(_S390, true);
        _S394 = _S396;
        k_7 = _S397;
    }
    uint _S398 = 0U;
    uint _S399 = __ballot_sync(k_7, _S394);
    if(_S394)
    {
        return;
    }
    else
    {
        uint _S400 = __ballot_sync(k_7, true);
        _S398 = _S400;
    }
    Impactor_0 imp_5 = *(&(globalParams_0->impactors_0)[ii_0]);
    float4  _S401 = make_float4 (0.0f);
    float4  shares_0 = _S401;
    float4  unused_0 = _S401;
    k_7 = (&imp_5)->cand_0.x + tid_2;
    uint _S402;
    _S402 = _S398;
    for(;;)
    {
        bool _S403 = k_7 < ((&imp_5)->cand_0.y);
        uint _S404 = __ballot_sync(_S402, _S403);
        if(_S403)
        {
            uint _S405 = __ballot_sync(_S402, true);
        }
        else
        {
            uint _S406 = __ballot_sync(_S402, false);
            uint _S407 = __ballot_sync(_S402, false);
            uint _S408 = __ballot_sync(_S398, true);
            _S389 = _S408;
            break;
        }
        uint _S409 = __ldg(&globalParams_0->params_0->cand_base_0);
        shares_0 = shares_0 + *(&(globalParams_0->scratch_0)[_S409 + 3U * k_7]);
        uint _S410 = __ballot_sync(_S402, true);
        k_7 = k_7 + 256U;
        _S402 = _S410;
    }
    group_sum2_0(tid_2, &shares_0, &unused_0, _S389);
    bool _S411 = tid_2 != 0U;
    uint _S412 = __ballot_sync(_S389, _S411);
    if(_S411)
    {
        _S394 = true;
    }
    else
    {
        _S394 = ((&imp_5)->cand_0.z) != 0U;
    }
    if(_S394)
    {
        return;
    }
    (&imp_5)->geom_0 = make_float4 (1.0f, (&imp_5)->crush_1.w, 0.0f, 0.0f);
    float total_1 = shares_0.x;
    if(((&imp_5)->crush_1.x) > 0.0f)
    {
        _S394 = ((&imp_5)->crush_1.z) < ((&imp_5)->crush_1.y);
    }
    else
    {
        _S394 = false;
    }
    if(_S394)
    {
        _S394 = total_1 > ((&imp_5)->crush_1.x);
    }
    else
    {
        _S394 = false;
    }
    if(_S394)
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
    float3  _S413 = abs_1(x_14);
    *err_1 = *err_1 + (_slang_select((abs_1(*sum_1)) >= _S413, *sum_1,x_14) - t_2 + _slang_select((abs_1(*sum_1)) >= _S413, x_14,*sum_1));
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
    Quat_0 _S414 = c_5;
    float3  _S415 = rotate_0(&_S414, v_4);
    return _S415;
}

static __device__ float3  rows_mul_0(float4  r0_0, float4  r1_0, float4  r2_0, float3  v_5)
{
    return make_float3 (dot_0(float3 {r0_0.x, r0_0.y, r0_0.z}, v_5), dot_0(float3 {r1_0.x, r1_0.y, r1_0.z}, v_5), dot_0(float3 {r2_0.x, r2_0.y, r2_0.z}, v_5));
}

static __device__ float3  world_mul_0(Quat_0 * q_10, float4  r0_1, float4  r1_1, float4  r2_1, float3  v_6)
{
    float3  _S416 = inverse_rotate_0(q_10, v_6);
    float3  _S417 = rotate_0(q_10, rows_mul_0(r0_1, r1_1, r2_1, _S416));
    return _S417;
}

static __device__ float4  turn_minus_one_0(float3  axis_3, float angle_1)
{
    float s_1 = (F32_sin((0.25f * angle_1)));
    return make_float4 ((axis_3 * make_float3 ((F32_sin((0.5f * angle_1))))).x, (axis_3 * make_float3 ((F32_sin((0.5f * angle_1))))).y, (axis_3 * make_float3 ((F32_sin((0.5f * angle_1))))).z, -2.0f * s_1 * s_1);
}

static __device__ float4  quat_vec_0(Quat_0 * q_11)
{
    return make_float4 (q_11->x_11, q_11->y_4, q_11->z_0, q_11->w_1);
}

static __device__ void comp_add4_0(float4  * sum_2, float4  * err_2, float4  x_15)
{
    float4  t_3 = *sum_2 + x_15;
    float4  _S418 = abs_0(x_15);
    *err_2 = *err_2 + (_slang_select((abs_0(*sum_2)) >= _S418, *sum_2,x_15) - t_3 + _slang_select((abs_0(*sum_2)) >= _S418, x_15,*sum_2));
    *sum_2 = t_3;
    return;
}

static __device__ void quat_accumulate_0(Quat_0 * hi_1, float4  * lo_1, float4  x_16)
{
    Quat_0 _S419 = *hi_1;
    float4  _S420 = quat_vec_0(&_S419);
    float4  sum_3 = _S420;
    comp_add4_0(&sum_3, lo_1, x_16);
    float4  t_4 = sum_3 + *lo_1;
    *lo_1 = *lo_1 - (t_4 - sum_3);
    *hi_1 = quat_of_0(t_4);
    return;
}

static __device__ void turn_left_0(Quat_0 * hi_2, float4  * lo_2, float3  omega_0, float dt_2)
{
    float _S421 = length_0(omega_0);
    float angle_2 = _S421 * dt_2;
    if(angle_2 < 1.00000000317107685e-30f)
    {
        return;
    }
    float4  d_10 = turn_minus_one_0(omega_0 / make_float3 (_S421), angle_2);
    Quat_0 dq_0;
    (&dq_0)->x_11 = d_10.x;
    (&dq_0)->y_4 = d_10.y;
    (&dq_0)->z_0 = d_10.z;
    (&dq_0)->w_1 = d_10.w;
    Quat_0 _S422 = dq_0;
    Quat_0 _S423 = *hi_2;
    Quat_0 _S424 = quat_mul_0(&_S422, &_S423);
    Quat_0 _S425 = _S424;
    float4  _S426 = quat_vec_0(&_S425);
    quat_accumulate_0(hi_2, lo_2, _S426);
    return;
}

extern "C" __global__ void impactor_integrate()
{
    uint _S427 = 0U;
    uint _S428;
    float3  p_8;
    uint _S429 = __ballot_sync(4294967295U, true);
    uint ii_1 = blockIdx.x;
    uint tid_3 = threadIdx.x;
    uint _S430 = __ldg(&globalParams_0->params_0->impactor_count_0);
    bool _S431 = ii_1 >= _S430;
    uint _S432 = __ballot_sync(_S429, _S431);
    if(_S431)
    {
        return;
    }
    else
    {
        uint _S433 = __ballot_sync(_S429, true);
        _S427 = _S433;
    }
    uint _S434 = __ldg(&globalParams_0->params_0->halt_index_0);
    Island_0 * _S435 = (&(globalParams_0->islands_0)[_S434]);
    Impactor_0 imp_6 = *(&(globalParams_0->impactors_0)[ii_1]);
    uint4  _S436 = _S435->info_1;
    bool _S437 = ((_S435->info_1.z) & 1U) != 0U;
    uint _S438 = __ballot_sync(_S427, _S437);
    bool _S439;
    uint k_8;
    if(_S437)
    {
        uint _S440 = __ballot_sync(_S427, true);
        _S439 = true;
        k_8 = _S440;
    }
    else
    {
        uint _S441 = _S427 & (~_S438);
        uint _S442 = _S436.y;
        bool _S443 = _S442 != 0U;
        uint _S444 = __ballot_sync(_S441, _S443);
        if(_S443)
        {
            bool _S445 = ((&imp_6)->cand_0.w) >= _S442;
            uint _S446 = __ballot_sync(_S441, true);
            _S439 = _S445;
        }
        else
        {
            uint _S447 = __ballot_sync(_S441, true);
            _S439 = false;
        }
        uint _S448 = __ballot_sync(_S427, true);
        k_8 = _S448;
    }
    uint _S449 = 0U;
    uint _S450 = __ballot_sync(k_8, _S439);
    if(_S439)
    {
        return;
    }
    else
    {
        uint _S451 = __ballot_sync(k_8, true);
        _S449 = _S451;
    }
    uint _S452 = 0U;
    bool _S453 = ((&imp_6)->cand_0.z) != 0U;
    uint _S454 = __ballot_sync(_S449, _S453);
    if(_S453)
    {
        if(tid_3 == 0U)
        {
            *&((&(&(globalParams_0->impactors_0)[ii_1])->cand_0)->w) = (&imp_6)->cand_0.w + 1U;
        }
        return;
    }
    else
    {
        uint _S455 = __ballot_sync(_S449, true);
        _S452 = _S455;
    }
    float4  _S456 = make_float4 (0.0f);
    float4  rf_0 = _S456;
    float4  rt_0 = _S456;
    k_8 = (&imp_6)->cand_0.x + tid_3;
    uint total_points_0;
    total_points_0 = _S452;
    for(;;)
    {
        bool _S457 = k_8 < ((&imp_6)->cand_0.y);
        uint _S458 = __ballot_sync(total_points_0, _S457);
        if(_S457)
        {
            uint _S459 = __ballot_sync(total_points_0, true);
        }
        else
        {
            uint _S460 = __ballot_sync(total_points_0, false);
            uint _S461 = __ballot_sync(total_points_0, false);
            uint _S462 = __ballot_sync(_S452, true);
            _S428 = _S462;
            break;
        }
        uint _S463 = __ldg(&globalParams_0->params_0->cand_base_0);
        uint _S464 = 3U * k_8;
        rf_0 = rf_0 + *(&(globalParams_0->scratch_0)[_S463 + _S464 + 1U]);
        uint _S465 = __ldg(&globalParams_0->params_0->cand_base_0);
        rt_0 = rt_0 + *(&(globalParams_0->scratch_0)[_S465 + _S464 + 2U]);
        uint _S466 = __ballot_sync(total_points_0, true);
        k_8 = k_8 + 256U;
        total_points_0 = _S466;
    }
    group_sum2_0(tid_3, &rf_0, &rt_0, _S428);
    bool _S467 = tid_3 != 0U;
    uint _S468 = __ballot_sync(_S428, _S467);
    if(_S467)
    {
        return;
    }
    float _S469 = __ldg(&globalParams_0->params_0->dt_0);
    float3  _S470 = make_float3 (0.0f);
    uint _S471 = __ldg(&globalParams_0->params_0->has_ground_0);
    float3  load_f_0;
    float3  load_t_0;
    if(_S471 != 0U)
    {
        float4  _S472 = (&imp_6)->half_1;
        float3  _S473 = float3 {_S472.x, _S472.y, _S472.z};
        Impactor_0 _S474 = imp_6;
        Box_0 _S475 = impactor_box_0(&_S474, _S470, _S473);
        float4  _S476 = (&imp_6)->velocity_1;
        float4  _S477 = (&imp_6)->velocity_err_1;
        float3  _S478 = float3 {_S476.x, _S476.y, _S476.z} + float3 {_S477.x, _S477.y, _S477.z};
        float _S479 = __ldg(&globalParams_0->params_0->ground_modulus_0);
        float _S480 = (&imp_6)->mat_0.x;
        float3  _S481 = make_float3 (0.0f, 0.0f, 1.0f);
        Box_0 _S482 = _S475;
        Box_0 _S483 = _S475;
        float _S484 = contact_stiffness_0(_S479, &_S482, _S480, &_S483, _S481);
        float _S485 = (&imp_6)->position_1.z;
        float _S486 = __ldg(&globalParams_0->params_0->ground_hi_0);
        float _S487 = _S485 - _S486;
        float _S488 = (&imp_6)->position_err_1.z;
        float _S489 = __ldg(&globalParams_0->params_0->ground_lo_0);
        float _S490 = _S487 + (_S488 - _S489);
        if(((&imp_6)->shape_0.x) == 0.0f)
        {
            total_points_0 = 1U;
        }
        else
        {
            total_points_0 = 14U;
        }
        float _S491 = _S484 / float((U32_min((total_points_0), (5U))));
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
                Box_0 _S492 = _S475;
                float3  _S493 = sample_point_0(&_S492, s_2);
                p_8 = _S493;
            }
            if((_S490 + p_8.z) < 0.0f)
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
        load_f_0 = _S470;
        load_t_0 = _S470;
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
                Box_0 _S494 = _S475;
                float3  _S495 = sample_point_0(&_S494, s_2);
                p_8 = _S495;
            }
            float depth_3 = - (_S490 + p_8.z);
            if(depth_3 <= 0.0f)
            {
                s_2 = s_2 + 1U;
                continue;
            }
            float4  _S496 = (&imp_6)->angular_velocity_1;
            float3  v_7 = _S478 + cross_0(float3 {_S496.x, _S496.y, _S496.z}, p_8);
            float _S497 = (&imp_6)->mat_0.z;
            float _S498 = __ldg(&globalParams_0->params_0->ground_friction_0);
            float stored_3;
            float diss_2;
            float3  f_3 = penalty_force_0(_S491, _S497, _S498, depth_3, _S481, v_7, _S469, below_0, &stored_3, &diss_2);
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
        load_f_0 = _S470;
        load_t_0 = _S470;
    }
    float4  _S499 = rf_0;
    float3  load_f_2 = float3 {_S499.x, _S499.y, _S499.z} + load_f_0;
    float4  _S500 = rt_0;
    float3  load_t_2 = float3 {_S500.x, _S500.y, _S500.z} + load_t_0;
    float m_2 = (&imp_6)->mat_0.z;
    float4  _S501 = (&imp_6)->velocity_1;
    float3  vel_0 = float3 {_S501.x, _S501.y, _S501.z};
    float4  _S502 = (&imp_6)->velocity_err_1;
    float3  vel_err_0 = float3 {_S502.x, _S502.y, _S502.z};
    float3  _S503 = load_f_2 / make_float3 (m_2);
    float4  _S504 = __ldg(&globalParams_0->params_0->gravity_0);
    comp_add_0(&vel_0, &vel_err_0, (_S503 + float3 {_S504.x, _S504.y, _S504.z}) * make_float3 (_S469));
    Quat_0 _S505 = quat_of_0((&imp_6)->rotation_1);
    Quat_0 q_12 = _S505;
    float4  q_err_0 = (&imp_6)->rotation_err_1;
    float4  _S506 = (&imp_6)->momentum_1;
    float3  l_hi_0 = float3 {_S506.x, _S506.y, _S506.z};
    float4  _S507 = (&imp_6)->momentum_err_1;
    float3  l_err_0 = float3 {_S507.x, _S507.y, _S507.z};
    comp_add_0(&l_hi_0, &l_err_0, load_t_2 * make_float3 (_S469));
    float3  l_1 = l_hi_0 + l_err_0;
    Quat_0 _S508 = _S505;
    float3  _S509 = world_mul_0(&_S508, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    float4  _S510 = (&imp_6)->position_1;
    float3  pos_0 = float3 {_S510.x, _S510.y, _S510.z};
    float4  _S511 = (&imp_6)->position_err_1;
    float3  pos_err_0 = float3 {_S511.x, _S511.y, _S511.z};
    comp_add_0(&pos_0, &pos_err_0, (vel_0 + vel_err_0) * make_float3 (_S469));
    turn_left_0(&q_12, &q_err_0, _S509, _S469);
    Quat_0 _S512 = q_12;
    float3  _S513 = world_mul_0(&_S512, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    (&imp_6)->angular_velocity_1 = make_float4 (_S513.x, _S513.y, _S513.z, 0.0f);
    Quat_0 _S514 = q_12;
    float4  _S515 = quat_vec_0(&_S514);
    (&imp_6)->rotation_1 = _S515;
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
    uint _S516 = (&imp_6)->cand_0.w - 1U;
    uint _S517 = __ldg(&globalParams_0->params_0->step_start_0);
    uint k_9 = _S516 - _S517;
    uint _S518 = __ldg(&globalParams_0->params_0->record_stride_0);
    if(k_9 < _S518)
    {
        uint _S519 = __ldg(&globalParams_0->params_0->record_base_0);
        uint _S520 = __ldg(&globalParams_0->params_0->record_stride_0);
        uint at_3 = _S519 + 2U * (ii_1 * _S520 + k_9);
        *(&(globalParams_0->scratch_0)[at_3]) = make_float4 ((vel_0 + vel_err_0).x, (vel_0 + vel_err_0).y, (vel_0 + vel_err_0).z, 0.0f);
        *(&(globalParams_0->scratch_0)[at_3 + 1U]) = make_float4 ((pos_0 + pos_err_0).x, (pos_0 + pos_err_0).y, (pos_0 + pos_err_0).z, 0.0f);
    }
    return;
}

static __device__ void ground_contact_0(uint c_6, bool account_0, float3  * f_4, float3  * t_5)
{
    ChunkStatic_0 * _S521 = (&(globalParams_0->chunks_0)[c_6]);
    WorldPoint_0 wp_1 = chunk_world_0(c_6);
    float _S522 = wp_1.hi_0.z;
    float _S523 = __ldg(&globalParams_0->params_0->ground_hi_0);
    float _S524 = _S522 - _S523;
    float _S525 = wp_1.lo_0.z;
    float _S526 = __ldg(&globalParams_0->params_0->ground_lo_0);
    float above_0 = _S524 + (_S525 - _S526) + wp_1.rel_0.z;
    float4  _S527 = __ldg(&_S521->half_0);
    if((above_0 - _S527.w) > 0.0f)
    {
        return;
    }
    Box_0 b_21 = chunk_box_0(c_6, make_float3 (0.0f));
    float _S528 = __ldg(&globalParams_0->params_0->ground_modulus_0);
    float4  _S529 = __ldg(&_S521->cmat_0);
    float _S530 = _S529.x;
    float3  _S531 = make_float3 (0.0f, 0.0f, 1.0f);
    Box_0 _S532 = b_21;
    Box_0 _S533 = b_21;
    float _S534 = contact_stiffness_0(_S528, &_S532, _S530, &_S533, _S531);
    Box_0 _S535 = b_21;
    uint _S536 = sample_count_0(&_S535);
    uint s_3 = 0U;
    uint n_7 = 0U;
    for(;;)
    {
        if(s_3 < _S536)
        {
        }
        else
        {
            break;
        }
        Box_0 _S537 = b_21;
        float3  _S538 = sample_point_0(&_S537, s_3);
        if((above_0 + _S538.z) < 0.0f)
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
    uint _S539 = __ldg(&globalParams_0->params_0->ledger_base_0);
    uint _S540 = __ldg(&globalParams_0->params_0->pair_count_0);
    float4  ledger_2 = *(&(globalParams_0->scratch_0)[_S539 + _S540 + c_6]);
    s_3 = 0U;
    for(;;)
    {
        if(s_3 < _S536)
        {
        }
        else
        {
            break;
        }
        Box_0 _S541 = b_21;
        float3  _S542 = sample_point_0(&_S541, s_3);
        float _S543 = above_0 + _S542.z;
        if(!(_S543 < 0.0f))
        {
            s_3 = s_3 + 1U;
            continue;
        }
        float depth_4 = - _S543;
        float3  v_8 = vc_1 + cross_0(wc_1, _S542);
        float _S544 = _S534 / float((U32_max((n_7), (5U))));
        float4  _S545 = __ldg(&_S521->center_0);
        float _S546 = _S545.w;
        float _S547 = __ldg(&globalParams_0->params_0->ground_friction_0);
        float _S548 = __ldg(&globalParams_0->params_0->dt_0);
        float stored_4;
        float diss_3;
        float3  g_0 = penalty_force_0(_S544, _S546, _S547, depth_4, _S531, v_8, _S548, n_7, &stored_4, &diss_3);
        *f_4 = *f_4 + g_0;
        *t_5 = *t_5 + cross_0(_S542, g_0);
        comp_add1_0(&((&ledger_2)->y), &((&ledger_2)->z), diss_3);
        s_3 = s_3 + 1U;
    }
    if(account_0)
    {
        uint _S549 = __ldg(&globalParams_0->params_0->ledger_base_0);
        uint _S550 = __ldg(&globalParams_0->params_0->pair_count_0);
        *(&(globalParams_0->scratch_0)[_S549 + _S550 + c_6]) = ledger_2;
    }
    return;
}

extern "C" __global__ void contact_sums()
{
    uint g_1 = (blockIdx * blockDim + threadIdx).x;
    uint _S551 = __ldg(&globalParams_0->params_0->seg_count_0);
    bool _S552;
    if(g_1 >= _S551)
    {
        _S552 = true;
    }
    else
    {
        _S552 = stopped_0();
    }
    if(_S552)
    {
        return;
    }
    uint _S553 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S554 = 3U * g_1;
    uint _S555 = __ldg((&(globalParams_0->index_0)[_S553 + _S554]));
    uint _S556 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S557 = __ldg((&(globalParams_0->index_0)[_S556 + _S554 + 1U]));
    uint _S558 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S559 = __ldg((&(globalParams_0->index_0)[_S558 + _S554 + 2U]));
    float3  _S560 = make_float3 (0.0f);
    float3  f_5 = _S560;
    float3  t_6 = _S560;
    uint e_2 = _S557;
    for(;;)
    {
        if(e_2 < _S559)
        {
        }
        else
        {
            break;
        }
        uint _S561 = __ldg((&(globalParams_0->index_0)[e_2]));
        if(_S561 == 2147483648U)
        {
            ground_contact_0(_S555, true, &f_5, &t_6);
            e_2 = e_2 + 1U;
            continue;
        }
        uint _S562 = __ldg(&globalParams_0->params_0->slot_base_0);
        uint _S563 = 2U * _S561;
        float4  _S564 = *(&(globalParams_0->scratch_0)[_S562 + _S563]);
        f_5 = f_5 + float3 {_S564.x, _S564.y, _S564.z};
        uint _S565 = __ldg(&globalParams_0->params_0->slot_base_0);
        float4  _S566 = *(&(globalParams_0->scratch_0)[_S565 + _S563 + 1U]);
        t_6 = t_6 + float3 {_S566.x, _S566.y, _S566.z};
        e_2 = e_2 + 1U;
    }
    uint _S567 = __ldg(&globalParams_0->params_0->seg_base_0);
    uint _S568 = 2U * g_1;
    *(&(globalParams_0->scratch_0)[_S567 + _S568]) = make_float4 (f_5.x, f_5.y, f_5.z, 0.0f);
    uint _S569 = __ldg(&globalParams_0->params_0->seg_base_0);
    *(&(globalParams_0->scratch_0)[_S569 + _S568 + 1U]) = make_float4 (t_6.x, t_6.y, t_6.z, 0.0f);
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
    uint _S570 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint4  _S571 = (&(globalParams_0->islands_0)[_S570])->info_1;
    bool _S572;
    if((((&(globalParams_0->islands_0)[_S570])->info_1.z) & 1U) != 0U)
    {
        _S572 = true;
    }
    else
    {
        uint _S573 = _S571.y;
        if(_S573 != 0U)
        {
            _S572 = _S573 <= (isl_0->info_1.w);
        }
        else
        {
            _S572 = false;
        }
    }
    return _S572;
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
    float4  _S574 = isl_1->position_0;
    (&rg_0)->pos_1 = float3 {_S574.x, _S574.y, _S574.z};
    float4  _S575 = isl_1->position_err_0;
    (&rg_0)->pos_err_1 = float3 {_S575.x, _S575.y, _S575.z};
    float4  _S576 = isl_1->velocity_0;
    (&rg_0)->vel_1 = float3 {_S576.x, _S576.y, _S576.z};
    float4  _S577 = isl_1->velocity_err_0;
    (&rg_0)->vel_err_1 = float3 {_S577.x, _S577.y, _S577.z};
    float4  _S578 = isl_1->angular_velocity_0;
    (&rg_0)->w_4 = float3 {_S578.x, _S578.y, _S578.z};
    float4  _S579 = isl_1->momentum_0;
    (&rg_0)->l_2 = float3 {_S579.x, _S579.y, _S579.z};
    float4  _S580 = isl_1->momentum_err_0;
    (&rg_0)->l_err_1 = float3 {_S580.x, _S580.y, _S580.z};
    float3  _S581 = make_float3 (0.0f);
    (&rg_0)->torque_0 = _S581;
    (&rg_0)->a_7 = _S581;
    (&rg_0)->alpha_0 = _S581;
    return rg_0;
}

static __device__ float time_since_0(float4  origin_0, uint k_10, float dt_3)
{
    float _S582 = __ldg(&globalParams_0->params_0->t_hi_0);
    float _S583 = _S582 - origin_0.x;
    float _S584 = __ldg(&globalParams_0->params_0->t_lo_0);
    return _S583 + (_S584 - origin_0.y) + float(k_10) * dt_3;
}

static __device__ float table_eval_0(uint offset_0, uint count_2, float tau_0)
{
    float4  _S585 = __ldg((&(globalParams_0->loads_0)[offset_0]));
    if(tau_0 <= (_S585.x))
    {
        return _S585.y;
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
        uint _S586 = offset_0 + i_10;
        float4  _S587 = __ldg((&(globalParams_0->loads_0)[_S586]));
        float _S588 = _S587.x;
        if(tau_0 <= _S588)
        {
            float4  _S589 = __ldg((&(globalParams_0->loads_0)[_S586 - 1U]));
            float _S590 = _S589.x;
            float _S591 = _S589.y;
            return _S591 + (tau_0 - _S590) / (F32_max((_S588 - _S590), (1.00000000317107685e-30f))) * (_S587.y - _S591);
        }
        i_10 = i_10 + 1U;
    }
    float4  _S592 = __ldg((&(globalParams_0->loads_0)[offset_0 + count_2 - 1U]));
    return _S592.y;
}

static __device__ float eval_function_0(uint term_0, uint k_11, float dt_4, float shift_0)
{
    uint _S593 = 5U * term_0;
    float4  _S594 = __ldg((&(globalParams_0->loads_0)[_S593]));
    uint4  info_2 = asuint_0(_S594);
    float4  _S595 = __ldg((&(globalParams_0->loads_0)[_S593 + 3U]));
    float4  _S596 = __ldg((&(globalParams_0->loads_0)[_S593 + 4U]));
    uint kind_0 = info_2.z;
    if(kind_0 == 0U)
    {
        return _S595.z;
    }
    float tau_1 = time_since_0(_S595, k_11, dt_4) + shift_0;
    float shape_1;
    if(kind_0 == 1U)
    {
        if(tau_1 <= 0.0f)
        {
            shape_1 = 0.0f;
        }
        else
        {
            float _S597 = _S596.x;
            if(tau_1 >= _S597)
            {
                shape_1 = _S596.y;
            }
            else
            {
                shape_1 = _S596.y * tau_1 / _S597;
            }
        }
        return shape_1;
    }
    bool _S598;
    if(kind_0 == 2U)
    {
        if(tau_1 < 0.0f)
        {
            _S598 = true;
        }
        else
        {
            _S598 = tau_1 > (_S596.x);
        }
        if(_S598)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S596.y * (F32_sin((3.14159274101257324f * tau_1 / _S596.x)));
        }
        return shape_1;
    }
    if(kind_0 == 3U)
    {
        float sn_0 = tau_1 / _S596.y;
        if(sn_0 < 0.0f)
        {
            _S598 = true;
        }
        else
        {
            _S598 = sn_0 > 1.0f;
        }
        if(_S598)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S596.x * (1.0f - sn_0) * (F32_exp((- _S596.z * sn_0)));
        }
        return shape_1;
    }
    if(kind_0 == 4U)
    {
        return table_eval_0(info_2.w, (F32_asuint((_S596.x))), tau_1);
    }
    if(kind_0 == 5U)
    {
        (*&g_seen_0)[1U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float sn_1 = tau_1 / _S596.x;
        if(sn_1 < 0.0f)
        {
            _S598 = true;
        }
        else
        {
            _S598 = sn_1 > 1.0f;
        }
        if(_S598)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = (1.0f - sn_1) * (F32_exp((- _S596.y * sn_1)));
        }
        float clearing_0 = _S595.w;
        float relax_0;
        if(clearing_0 > 0.0f)
        {
            relax_0 = (F32_max((1.0f - tau_1 / clearing_0), (0.0f)));
        }
        else
        {
            relax_0 = 0.0f;
        }
        float _S599 = _S596.w;
        return (_S599 + (_S596.z - _S599) * relax_0) * shape_1;
    }
    if(kind_0 == 7U)
    {
        (*&g_seen_0)[2U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float _S600 = _S596.y;
        if(tau_1 < _S600)
        {
            return _S596.x;
        }
        float s_4 = tau_1 - _S600;
        float _S601 = _S596.w;
        if(s_4 > _S601)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S596.z * (F32_sin((3.14159274101257324f * s_4 / _S601)));
        }
        return shape_1;
    }
    float _S602 = _S596.x;
    if(_S602 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp_0(1.0f - tau_1 / _S602, 0.0f, 1.0f);
}

static __device__ void record_chunk_load_0(uint c_7, float3  f_6, float3  t_7)
{
    uint _S603 = __ldg(&globalParams_0->params_0->solve_mode_0);
    if(_S603 == 0U)
    {
        return;
    }
    uint _S604 = __ldg(&globalParams_0->params_0->cload_base_0);
    uint _S605 = 2U * c_7;
    *(&(globalParams_0->scratch_0)[_S604 + _S605]) = make_float4 (f_6.x, f_6.y, f_6.z, 0.0f);
    uint _S606 = __ldg(&globalParams_0->params_0->cload_base_0);
    *(&(globalParams_0->scratch_0)[_S606 + _S605 + 1U]) = make_float4 (t_7.x, t_7.y, t_7.z, 0.0f);
    uint _S607 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  * _S608 = (&(globalParams_0->scratch_0)[_S607 + _S605]);
    uint _S609 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  _S610 = *(&(globalParams_0->scratch_0)[_S609 + _S605]);
    *_S608 = make_float4 ((float3 {_S610.x, _S610.y, _S610.z} + f_6).x, (float3 {_S610.x, _S610.y, _S610.z} + f_6).y, (float3 {_S610.x, _S610.y, _S610.z} + f_6).z, 0.0f);
    uint _S611 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  * _S612 = (&(globalParams_0->scratch_0)[_S611 + _S605 + 1U]);
    uint _S613 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  _S614 = *(&(globalParams_0->scratch_0)[_S613 + _S605 + 1U]);
    *_S612 = make_float4 ((float3 {_S614.x, _S614.y, _S614.z} + t_7).x, (float3 {_S614.x, _S614.y, _S614.z} + t_7).y, (float3 {_S614.x, _S614.y, _S614.z} + t_7).z, 0.0f);
    return;
}

static __device__ void chunk_loads_0(uint _S615, uint _S616, Quat_0 * _S617, uint _S618, float _S619, bool _S620, float _S621, float3  * _S622, float3  * _S623, float3  * _S624, float3  * _S625)
{
    bool _S626;
    ChunkStatic_0 * _S627 = (&(globalParams_0->chunks_0)[_S616]);
    float3  _S628 = make_float3 (0.0f);
    *_S622 = _S628;
    *_S623 = _S628;
    *_S624 = _S628;
    *_S625 = _S628;
    uint4  _S629 = __ldg(&_S627->load_range_0);
    uint term_1 = _S629.x;
    for(;;)
    {
        if(term_1 < (_S629.y))
        {
        }
        else
        {
            break;
        }
        (*&g_seen_0)[0U] = 1U;
        uint _S630 = 5U * term_1;
        float4  _S631 = __ldg((&(globalParams_0->loads_0)[_S630]));
        uint _S632 = asuint_0(_S631).y;
        bool replacement_0 = _S632 == 2U;
        float4  _S633 = __ldg((&(globalParams_0->loads_0)[_S630 + 1U]));
        float4  _S634 = __ldg((&(globalParams_0->loads_0)[_S630 + 2U]));
        float _S635;
        if(replacement_0)
        {
            _S635 = _S621;
        }
        else
        {
            _S635 = 0.0f;
        }
        float value_0 = eval_function_0(term_1, _S618, _S619, _S635);
        if(replacement_0)
        {
            *_S624 = *_S624 + float3 {_S633.x, _S633.y, _S633.z} * make_float3 (value_0);
            *_S625 = *_S625 + float3 {_S634.x, _S634.y, _S634.z} * make_float3 (value_0);
            term_1 = term_1 + 1U;
            continue;
        }
        if(_S632 == 0U)
        {
            _S626 = true;
        }
        else
        {
            _S626 = _S632 == 3U;
        }
        float3  fw_0;
        if(_S626)
        {
            fw_0 = float3 {_S633.x, _S633.y, _S633.z} * make_float3 (value_0);
        }
        else
        {
            float3  _S636 = rotate_0(_S617, float3 {_S633.x, _S633.y, _S633.z});
            fw_0 = _S636 * make_float3 (- value_0 * _S633.w);
        }
        float3  lever_0;
        if(_S632 == 3U)
        {
            float4  _S637 = *(&(globalParams_0->state_0)[4U * _S615]);
            lever_0 = float3 {_S634.x, _S634.y, _S634.z} - float3 {_S637.x, _S637.y, _S637.z};
        }
        else
        {
            lever_0 = float3 {_S634.x, _S634.y, _S634.z};
        }
        *_S622 = *_S622 + fw_0;
        float3  _S638 = rotate_0(_S617, lever_0);
        *_S623 = *_S623 + cross_0(_S638, fw_0);
        term_1 = term_1 + 1U;
    }
    if(_S620)
    {
        uint4  _S639 = __ldg(&_S627->cinfo_0);
        _S626 = (_S639.z) != 0U;
    }
    else
    {
        _S626 = false;
    }
    if(_S626)
    {
        uint4  _S640 = __ldg(&_S627->cinfo_0);
        uint g_2 = _S640.x;
        for(;;)
        {
            if(g_2 < (_S640.y))
            {
            }
            else
            {
                break;
            }
            uint _S641 = __ldg(&globalParams_0->params_0->seg_base_0);
            uint _S642 = 2U * g_2;
            float4  _S643 = *(&(globalParams_0->scratch_0)[_S641 + _S642]);
            *_S622 = *_S622 + float3 {_S643.x, _S643.y, _S643.z};
            uint _S644 = __ldg(&globalParams_0->params_0->seg_base_0);
            float4  _S645 = *(&(globalParams_0->scratch_0)[_S644 + _S642 + 1U]);
            *_S623 = *_S623 + float3 {_S645.x, _S645.y, _S645.z};
            g_2 = g_2 + 1U;
        }
    }
    return;
}

static __device__ void chunk_external_0(uint _S646, uint _S647, Quat_0 * _S648, uint _S649, float _S650, bool _S651, float3  * _S652, float3  * _S653)
{
    float3  rf_1;
    float3  rm_0;
    chunk_loads_0(_S646, _S647, _S648, _S649, _S650, _S651, 0.0f, _S652, _S653, &rf_1, &rm_0);
    return;
}

static __device__ float settled_chunk_load_0(uint c_8, Quat_0 * rot_1, uint k_12, float dt_5, bool contact_0)
{
    float3  f_7;
    float3  t_8;
    chunk_external_0(c_8, c_8, rot_1, k_12, dt_5, contact_0, &f_7, &t_8);
    record_chunk_load_0(c_8, f_7, t_8);
    return length_0(f_7);
}

static __device__ void net_load_0(uint c_9, Island_0 * isl_2, Rigid_0 * rg_1, uint k_13, float dt_6, bool contact_1, float3  * f_8, float3  * t_9)
{
    ChunkStatic_0 * _S654 = (&(globalParams_0->chunks_0)[c_9]);
    float3  fl_0;
    float3  tl_0;
    float3  rep_f_0;
    float3  rep_m_0;
    chunk_loads_0(c_9, c_9, &rg_1->rot_0, k_13, dt_6, contact_1, 0.0f, &fl_0, &tl_0, &rep_f_0, &rep_m_0);
    float3  _S655 = fl_0;
    float4  _S656 = __ldg(&globalParams_0->params_0->gravity_0);
    float3  _S657 = float3 {_S656.x, _S656.y, _S656.z};
    float4  _S658 = __ldg(&_S654->center_0);
    float3  fc_0 = _S655 + _S657 * make_float3 (_S658.w);
    float3  _S659 = float3 {_S658.x, _S658.y, _S658.z};
    float4  _S660 = *(&(globalParams_0->state_0)[4U * c_9]);
    float4  _S661 = isl_2->com_0;
    float3  _S662 = float3 {_S661.x, _S661.y, _S661.z};
    float3  _S663 = rotate_0(&rg_1->rot_0, _S659 + float3 {_S660.x, _S660.y, _S660.z} - _S662);
    *f_8 = *f_8 + fc_0;
    *t_9 = *t_9 + (cross_0(_S663, fc_0) + tl_0);
    uint4  _S664 = __ldg(&_S654->load_range_0);
    if((_S664.y) > (_S664.x))
    {
        float3  _S665 = rotate_0(&rg_1->rot_0, rep_f_0);
        *f_8 = *f_8 + _S665;
        float3  _S666 = rotate_0(&rg_1->rot_0, _S659 - _S662);
        float3  _S667 = cross_0(_S666, _S665);
        float3  _S668 = rotate_0(&rg_1->rot_0, rep_m_0);
        *t_9 = *t_9 + (_S667 + _S668);
    }
    return;
}

static __device__ void rigid_acceleration_0(Island_0 * isl_3, Rigid_0 * rg_2, float3  f_9, float3  t_10)
{
    Quat_0 _S669 = rg_2->rot_0;
    float3  _S670 = world_mul_0(&_S669, isl_3->inertia0_1, isl_3->inertia1_1, isl_3->inertia2_1, rg_2->w_4);
    rg_2->a_7 = f_9 / make_float3 (isl_3->com_0.w);
    float3  _S671 = t_10 - cross_0(rg_2->w_4, _S670);
    Quat_0 _S672 = rg_2->rot_0;
    float3  _S673 = world_mul_0(&_S672, isl_3->inv0_1, isl_3->inv1_1, isl_3->inv2_1, _S671);
    rg_2->alpha_0 = _S673;
    rg_2->torque_0 = t_10;
    return;
}

static __device__ JointBond_0 slang_ldg_0(JointBond_0 * ptr_0)
{
    float4  _S674 = __ldg(&ptr_0->geom0_0);
    float4  _S675 = __ldg(&ptr_0->geom1_0);
    float4  _S676 = __ldg(&ptr_0->stiff0_0);
    float4  _S677 = __ldg(&ptr_0->stiff1_0);
    float4  _S678 = __ldg(&ptr_0->rebar0_0);
    float4  _S679 = __ldg(&ptr_0->rebar1_0);
    uint4  _S680 = __ldg(&ptr_0->ids_0);
    JointBond_0 _S681 = { _S674, _S675, _S676, _S677, _S678, _S679, _S680 };
    return _S681;
}

static __device__ bool is_damaged_0(JointState_0 * st_0)
{
    bool _S682;
    if((st_0->damage_0) > 0.0f)
    {
        _S682 = true;
    }
    else
    {
        _S682 = (st_0->crush_0) > 0.0f;
    }
    return _S682;
}

static __device__ bool connected_0(JointState_0 * st_1, bool has_rebar_0)
{
    bool _S683;
    if((st_1->damage_0) < 1.0f)
    {
        _S683 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S683 = (st_1->rebar_broken_0) == 0.0f;
        }
        else
        {
            _S683 = false;
        }
    }
    return _S683;
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
    float _S684 = q_lin_0.z;
    float axial_0 = fdiv_0(_S684, area_2);
    float bending_0 = fdiv_0((F32_abs((q_ang_0.x))), b_23->geom1_0.x) + fdiv_0((F32_abs((q_ang_0.y))), b_23->geom1_0.y);
    float _S685 = q_lin_0.x;
    float _S686 = q_lin_0.y;
    float shear_1 = fdiv_0(fsqrt_0(_S685 * _S685 + _S686 * _S686), area_2) + fdiv_0((F32_abs((q_ang_0.z))), b_23->geom0_0.w);
    Measures_0 m_3;
    (&m_3)->tension_0 = axial_0 + bending_0;
    (&m_3)->shear_0 = shear_1;
    float _S687 = - axial_0;
    (&m_3)->normal_compression_0 = (F32_max((_S687), (0.0f)));
    (&m_3)->compression_0 = _S687 + bending_0;
    (&m_3)->compressive_force_0 = (F32_max((- _S684), (0.0f)));
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

static __device__ float fpow_0(float a_10, float b_24)
{
    return (F32_pow((a_10), (b_24)));
}

static __device__ float dif_factor_0(JointMaterial_0 * mat_1, float strain_rate_1)
{
    float r_5 = (F32_abs((strain_rate_1)));
    float4  _S688 = mat_1->dif_0;
    float ref_0 = mat_1->dif_0.x;
    if(r_5 <= ref_0)
    {
        return 1.0f;
    }
    float _S689 = _S688.z;
    float f_10;
    if(r_5 <= _S689)
    {
        f_10 = fpow_0(fdiv_0(r_5, ref_0), _S688.y);
    }
    else
    {
        f_10 = fpow_0(fdiv_0(_S689, ref_0), _S688.y) * fpow_0(fdiv_0(r_5, _S689), _S688.w);
    }
    return clamp_0(f_10, 1.0f, mat_1->misc_0.x);
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
    float fc_1 = mat_3->strength_0.y * multiplier_0;
    float _S690 = (F32_min((mat_3->strength_0.z * multiplier_0 + mat_3->strength_0.w * m_4->normal_compression_0), (mat_3->energy_0.x * multiplier_0)));
    float4  idx_0;
    *&((&idx_0)->x) = (F32_max((fdiv_0(m_4->tension_0, mat_3->strength_0.x * multiplier_0)), (0.0f)));
    float _S691;
    if(_S690 > 0.0f)
    {
        _S691 = fdiv_0(m_4->shear_0, _S690);
    }
    else
    {
        _S691 = infinity_0();
    }
    *&((&idx_0)->y) = _S691;
    *&((&idx_0)->z) = (F32_max((fdiv_0(m_4->compression_0, fc_1)), (0.0f)));
    float _S692 = b_25->stiff1_0.y;
    if(_S692 > 0.0f)
    {
        _S691 = fdiv_0(m_4->compressive_force_0, _S692);
    }
    else
    {
        _S691 = 0.0f;
    }
    *&((&idx_0)->w) = _S691;
    return idx_0;
}

static __device__ float sq_0(float x_18)
{
    return x_18 * x_18;
}

static __device__ float damage_law_0(uint kind_1, float kappa_1, float r_6)
{
    if(kappa_1 <= 1.0f)
    {
        return 0.0f;
    }
    if(kind_1 == 0U)
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

static __device__ __noinline__ float2  damage_increment_0(uint kind_2, float kappa_old_0, float lambda_0, float r_7, float d_old_0, float psi_0)
{
    float _S693 = (F32_max((damage_law_0(kind_2, lambda_0, r_7)), (d_old_0)));
    bool _S694;
    if(_S693 <= d_old_0)
    {
        _S694 = true;
    }
    else
    {
        _S694 = d_old_0 >= 1.0f;
    }
    if(_S694)
    {
        return make_float2 (d_old_0, 0.0f);
    }
    float u0_0 = fdiv_0(psi_0, lambda_0 * lambda_0);
    float _S695 = (F32_max((kappa_old_0), (1.0f)));
    if(kind_2 == 0U)
    {
        if(r_7 > 1.0f)
        {
            return make_float2 (_S693, fdiv_0(u0_0 * r_7, r_7 - 1.0f) * (F32_max(((F32_min((lambda_0), (r_7))) - (F32_min((_S695), (r_7)))), (0.0f))));
        }
        return make_float2 (_S693, (1.0f - d_old_0) * psi_0);
    }
    float ku_0 = 0.5f * (r_7 + 1.0f);
    float plateau_0 = u0_0 * (F32_max(((F32_min((lambda_0), (ku_0))) - (F32_min((_S695), (ku_0)))), (0.0f)));
    float snap_0;
    if(_S693 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return make_float2 (_S693, plateau_0 + snap_0);
}

static __device__ void compressed_region_0(float w0_0, float w1_0, float dz_0, float ax_0, float ay_0, FixedArray<float, 6>  * region_0)
{
    uint count_3;
    float h0_0 = 0.5f * w0_0;
    float h1_0 = 0.5f * w1_0;
    float _S696 = - h0_0;
    float _S697 = - h1_0;
    FixedArray<float2 , 4>  _S698 = { {
        float2 {
            _S696, _S697
        }, float2 {
            h0_0, _S697
        }, float2 {
            h0_0, h1_0
        }, float2 {
            _S696, h1_0
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
        uint _S699 = i_11;
        uint _S700 = i_11 + 1U;
        uint _S701 = _S700 % 4U;
        float _S702 = _S698[i_11].y;
        float _S703 = _S698[i_11].x;
        float fp_0 = dz_0 + ax_0 * _S702 - ay_0 * _S703;
        float _S704 = _S698[_S701].y;
        float _S705 = _S698[_S701].x;
        float fq_0 = dz_0 + ax_0 * _S704 - ay_0 * _S705;
        bool _S706 = fp_0 < 0.0f;
        if(_S706)
        {
            uint _S707 = count_4 + 1U;
            poly_0[count_4] = _S698[_S699];
            count_3 = _S707;
        }
        else
        {
            count_3 = count_4;
        }
        if(_S706 != (fq_0 < 0.0f))
        {
            float t_11 = fp_0 / (fp_0 - fq_0);
            uint _S708 = count_3 + 1U;
            poly_0[count_3] = make_float2 (_S703 + t_11 * (_S705 - _S703), _S702 + t_11 * (_S704 - _S702));
            count_4 = _S708;
        }
        else
        {
            count_4 = count_3;
        }
        i_11 = _S700;
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
        float _S709 = o_1.x;
        float x0_0 = poly_0[i_11].x - _S709;
        float _S710 = o_1.y;
        float y0_0 = poly_0[i_11].y - _S710;
        uint _S711 = i_11 + 1U;
        uint _S712 = _S711 % count_4;
        float x1_0 = poly_0[_S712].x - _S709;
        float y1_0 = poly_0[_S712].y - _S710;
        float _S713 = x0_0 * y1_0;
        float _S714 = x1_0 * y0_0;
        float cr_0 = _S713 - _S714;
        float a_12 = a_11 + cr_0 / 2.0f;
        float sx_1 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        float sy_1 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        float ixx_1 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        float iyy_1 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        float ixy_1 = ixy_0 + (_S713 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S714) * cr_0 / 24.0f;
        i_11 = _S711;
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
    float _S715 = a_11 * cx_0;
    (*region_0)[int(3)] = ixx_0 - _S715 * cx_0;
    (*region_0)[int(4)] = iyy_0 - a_11 * cy_0 * cy_0;
    (*region_0)[int(5)] = ixy_0 - _S715 * cy_0;
    return;
}

static __device__ __noinline__ float4  no_tension_patch_0(float kn_0, float w0_1, float w1_1, float dz_1, float ax_1, float ay_1)
{
    FixedArray<float, 6>  r_8;
    compressed_region_0(w0_1, w1_1, dz_1, ax_1, ay_1, &r_8);
    float a_13 = r_8[int(0)];
    if((r_8[int(0)]) == 0.0f)
    {
        return make_float4 (0.0f);
    }
    float k_14 = kn_0 / (w0_1 * w1_1);
    float fc_2 = dz_1 + ax_1 * r_8[int(2)] - ay_1 * r_8[int(1)];
    float _S716 = a_13 * fc_2;
    float _S717 = - ay_1;
    return make_float4 (k_14 * a_13 * fc_2, k_14 * (_S716 * r_8[int(2)] + (_S717 * r_8[int(5)] + ax_1 * r_8[int(4)])), - k_14 * (_S716 * r_8[int(1)] + (_S717 * r_8[int(3)] + ax_1 * r_8[int(5)])), 0.5f * k_14 * (_S716 * fc_2 + ay_1 * ay_1 * r_8[int(3)] + ax_1 * ax_1 * r_8[int(4)] - 2.0f * ax_1 * ay_1 * r_8[int(5)]));
}

static __device__ float signum_0(float x_19)
{
    float _S718;
    if(((F32_asuint((x_19))) & 2147483648U) != 0U)
    {
        _S718 = -1.0f;
    }
    else
    {
        _S718 = 1.0f;
    }
    return _S718;
}

static __device__ float2  return_map_0(float k_15, float total_2, float plastic_0, float cap_0)
{
    float trial_0 = k_15 * (total_2 - plastic_0);
    if((F32_abs((trial_0))) <= cap_0)
    {
        return make_float2 (trial_0, 0.0f);
    }
    float f_11 = cap_0 * signum_0(trial_0);
    return make_float2 (f_11, fdiv_0(trial_0 - f_11, k_15));
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
    float3  _S719 = make_float3 (0.0f);
    (&c_10)->q_lin_1 = _S719;
    (&c_10)->q_ang_1 = _S719;
    (&c_10)->energy_2 = 0.0f;
    (&c_10)->diss_4 = 0.0f;
    (&c_10)->plastic_1 = plastic_2;
    uint _S720 = mat_4->kind_flags_0.y;
    if((_S720 & 2U) == 0U)
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
    if((_S720 & 4U) != 0U)
    {
        float4  p_9 = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        float _S721 = p_9.y;
        float _S722 = p_9.z;
        float _S723 = p_9.w;
        nc_sum_0 = p_9.x;
        m1_0 = _S721;
        m2_0 = _S722;
        energy_3 = _S723;
    }
    else
    {
        float ki_0 = kn_1 * (1.0f - crush_2) / 36.0f;
        float _S724 = d_ang_0.x;
        float _S725 = d_ang_0.y;
        float spread_0 = (F32_abs((_S724))) * 0.4166666567325592f * w1_2 + (F32_abs((_S725))) * 0.4166666567325592f * w0_2;
        float _S726 = d_lin_0.z;
        float slack_0 = 9.99999997475242708e-07f * ((F32_abs((_S726))) + spread_0);
        if((_S726 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S726 + spread_0) < (- slack_0))
            {
                float i1_0 = 2.91666650772094727f * w0_2 * w0_2;
                float i2_0 = 2.91666650772094727f * w1_2 * w1_2;
                float _S727 = ki_0 * _S724 * i2_0;
                float _S728 = ki_0 * _S725 * i1_0;
                float _S729 = 0.5f * ki_0 * (36.0f * _S726 * _S726 + _S724 * _S724 * i2_0 + _S725 * _S725 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S726;
                m1_0 = _S727;
                m2_0 = _S728;
                energy_3 = _S729;
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
                    float _S730 = SPRING_AT_0[i_12] * w0_2;
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
                        float di_0 = _S726 + _S724 * s2_0 - _S725 * _S730;
                        if(di_0 < 0.0f)
                        {
                            float f_12 = ki_0 * di_0;
                            float m1_2 = m1_0 + f_12 * s2_0;
                            float m2_2 = m2_0 - f_12 * _S730;
                            float energy_5 = energy_3 + 0.5f * ki_0 * di_0 * di_0;
                            nc_sum_0 = nc_sum_0 + f_12;
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
    float _S731 = ks_0 * (d_lin_0.x - plastic_2.x);
    float _S732 = ks_0 * (d_lin_0.y - plastic_2.y);
    float tn_0 = fsqrt_0(_S731 * _S731 + _S732 * _S732);
    bool _S733;
    if(tn_0 > slide_cap_0)
    {
        _S733 = tn_0 > 0.0f;
    }
    else
    {
        _S733 = false;
    }
    if(_S733)
    {
        float _S734 = fdiv_0(_S731, tn_0);
        float _S735 = fdiv_0(_S732, tn_0);
        float dslip_0 = fdiv_0(tn_0 - slide_cap_0, ks_0);
        *&((&p_10)->x) = *&((&p_10)->x) + _S734 * dslip_0;
        *&((&p_10)->y) = *&((&p_10)->y) + _S735 * dslip_0;
        *&((&(&c_10)->q_lin_1)->x) = _S734 * slide_cap_0;
        *&((&(&c_10)->q_lin_1)->y) = _S735 * slide_cap_0;
        diss_5 = slide_cap_0 * dslip_0;
    }
    else
    {
        *&((&(&c_10)->q_lin_1)->x) = _S731;
        *&((&(&c_10)->q_lin_1)->y) = _S732;
        diss_5 = 0.0f;
    }
    float2  tq_0 = return_map_0(kt_0, d_ang_0.z, p_10.z, slide_cap_0 * b_26->geom1_0.z);
    float _S736 = tq_0.x;
    float _S737 = tq_0.y;
    float diss_6 = diss_5 + (F32_abs((_S736))) * (F32_abs((_S737)));
    *&((&p_10)->z) = *&((&p_10)->z) + _S737;
    *&((&(&c_10)->q_ang_1)->z) = _S736;
    (&c_10)->energy_2 = energy_3 + 0.5f * (fdiv_0(sq_0((&c_10)->q_lin_1.x), ks_0) + fdiv_0(sq_0((&c_10)->q_lin_1.y), ks_0) + fdiv_0(sq_0(_S736), kt_0));
    (&c_10)->diss_4 = diss_6;
    (&c_10)->plastic_1 = p_10;
    return c_10;
}

static __device__ float3  contact_offsets_0(JointMaterial_0 * mat_5, JointBond_0 * b_27, float crush_3, float3  plastic_3, float3  d_lin_1, float3  d_ang_1)
{
    uint _S738 = mat_5->kind_flags_0.y;
    if((_S738 & 2U) == 0U)
    {
        return plastic_3;
    }
    float kn_2 = b_27->stiff0_0.x;
    float ks_1 = b_27->stiff0_0.y;
    float kt_1 = b_27->stiff1_0.x;
    float w0_3 = b_27->geom0_0.y;
    float w1_3 = b_27->geom0_0.z;
    float nc_sum_1;
    if((_S738 & 4U) != 0U)
    {
        float4  _S739 = no_tension_patch_0(kn_2 * (1.0f - crush_3), w0_3, w1_3, d_lin_1.z, d_ang_1.x, d_ang_1.y);
        nc_sum_1 = _S739.x;
    }
    else
    {
        float ki_1 = kn_2 * (1.0f - crush_3) / 36.0f;
        float _S740 = d_ang_1.x;
        float _S741 = d_ang_1.y;
        float spread_1 = (F32_abs((_S740))) * 0.4166666567325592f * w1_3 + (F32_abs((_S741))) * 0.4166666567325592f * w0_3;
        float _S742 = d_lin_1.z;
        float slack_1 = 9.99999997475242708e-07f * ((F32_abs((_S742))) + spread_1);
        if((_S742 - spread_1) > slack_1)
        {
            nc_sum_1 = 0.0f;
        }
        else
        {
            if((_S742 + spread_1) < (- slack_1))
            {
                nc_sum_1 = ki_1 * 36.0f * _S742;
            }
            else
            {
                uint i_13 = 0U;
                float nc_sum_2 = 0.0f;
                for(;;)
                {
                    if(i_13 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float _S743 = SPRING_AT_0[i_13] * w0_3;
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
                        float di_1 = _S742 + _S740 * (SPRING_AT_0[j_5] * w1_3) - _S741 * _S743;
                        if(di_1 < 0.0f)
                        {
                            nc_sum_1 = nc_sum_1 + ki_1 * di_1;
                        }
                        j_5 = j_5 + 1U;
                    }
                    i_13 = i_13 + 1U;
                    nc_sum_2 = nc_sum_1;
                }
                nc_sum_1 = nc_sum_2;
            }
        }
    }
    float nc_1 = - nc_sum_1;
    float3  p_11 = plastic_3;
    float slide_cap_1 = mat_5->strength_0.w * nc_1;
    float _S744 = ks_1 * (d_lin_1.x - plastic_3.x);
    float _S745 = ks_1 * (d_lin_1.y - plastic_3.y);
    float tn_1 = fsqrt_0(_S744 * _S744 + _S745 * _S745);
    bool _S746;
    if(tn_1 > slide_cap_1)
    {
        _S746 = tn_1 > 0.0f;
    }
    else
    {
        _S746 = false;
    }
    if(_S746)
    {
        float _S747 = fdiv_0(_S745, tn_1);
        float dslip_1 = fdiv_0(tn_1 - slide_cap_1, ks_1);
        *&((&p_11)->x) = *&((&p_11)->x) + fdiv_0(_S744, tn_1) * dslip_1;
        *&((&p_11)->y) = *&((&p_11)->y) + _S747 * dslip_1;
    }
    *&((&p_11)->z) = *&((&p_11)->z) + return_map_0(kt_1, d_ang_1.z, p_11.z, slide_cap_1 * b_27->geom1_0.z).y;
    return p_11;
}

static __device__ float life_rate_0(JointMaterial_0 * mat_6, float s_5)
{
    if(s_5 <= 0.0f)
    {
        return 0.0f;
    }
    float _S748 = mat_6->misc_0.y;
    return fdiv_0((_S748 + 1.0f) * fpow_0(s_5, _S748), mat_6->misc_0.z);
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

static __device__ JointResponse_0 joint_evaluate_0(JointMaterial_0 * mat_7, JointBond_0 * b_28, JointState_0 * state_2, float3  d_lin_2, float3  d_ang_2, float dt_7, bool fracture_1)
{
    float kn_3 = b_28->stiff0_0.x;
    float ks_2 = b_28->stiff0_0.y;
    float kb1_0 = b_28->stiff0_0.z;
    float kb2_0 = b_28->stiff0_0.w;
    float4  _S749 = b_28->stiff1_0;
    float kt_2 = b_28->stiff1_0.x;
    bool has_rebar_1 = (b_28->stiff1_0.w) != 0.0f;
    uint kind_3 = mat_7->kind_flags_0.x;
    uint flags_1 = mat_7->kind_flags_0.y;
    bool softening_0 = (flags_1 & 1U) != 0U;
    JointState_0 st_2 = *state_2;
    bool _S750 = connected_0(state_2, has_rebar_1);
    float3  qe_lin_0 = d_lin_2 * make_float3 (ks_2, ks_2, kn_3);
    float3  qe_ang_0 = d_ang_2 * make_float3 (kb1_0, kb2_0, kt_2);
    Measures_0 _S751 = stress_measures_0(b_28, qe_lin_0, qe_ang_0);
    float _S752 = (F32_max(((F32_max((_S751.tension_0), (_S751.shear_0)))), (_S751.compression_0)));
    bool _S753 = dt_7 > 0.0f;
    float dif_1;
    if(_S753)
    {
        float raw_0 = fdiv_0((F32_max((fdiv_0(_S752 - (&st_2)->governing_stress_0, dt_7)), (0.0f))), mat_7->misc_0.w);
        float tau_2 = _S749.z;
        if((flags_1 & 16U) != 0U)
        {
            dif_1 = - expm1_accurate_0(- fdiv_0(dt_7, tau_2));
        }
        else
        {
            dif_1 = (F32_min((fdiv_0(dt_7, tau_2)), (1.0f)));
        }
        (&st_2)->strain_rate_0 = (&st_2)->strain_rate_0 + (raw_0 - (&st_2)->strain_rate_0) * dif_1;
        (&st_2)->governing_stress_0 = _S752;
    }
    if((flags_1 & 32U) != 0U)
    {
        float _S754 = dif_factor_0(mat_7, (&st_2)->strain_rate_0);
        dif_1 = _S754;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = b_28->geom1_0.w;
    float _S755 = fatigue_factor_0(mat_7, (&st_2)->life_0);
    float multiplier_1 = weibull_0 * dif_1 * _S755;
    Measures_0 _S756 = _S751;
    float4  _S757 = failure_indices_0(mat_7, b_28, &_S756, multiplier_1);
    float _S758 = _S757.x;
    float _S759 = _S757.y;
    (&st_2)->utilization_0 = (F32_max(((F32_max((_S758), (_S759)))), ((F32_max((_S757.z), (_S757.w))))));
    float _S760 = d_lin_2.x;
    float _S761 = d_lin_2.y;
    float _S762 = ks_2 * (sq_0(_S760) + sq_0(_S761)) + kb1_0 * sq_0(d_ang_2.x) + kb2_0 * sq_0(d_ang_2.y) + kt_2 * sq_0(d_ang_2.z);
    float _S763 = d_lin_2.z;
    bool _S764 = _S763 > 0.0f;
    if(_S764)
    {
        dif_1 = kn_3 * sq_0(_S763);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S762 + dif_1);
    float psi_c_0;
    if(_S763 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_3 * sq_0(_S763);
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
    bool _S765;
    float3  qc_lin_0;
    if(fracture_1)
    {
        bool _S766 = _S758 >= _S759;
        if(_S766)
        {
            diss_contact_0 = _S758;
        }
        else
        {
            diss_contact_0 = _S759;
        }
        uint mode_ts_0;
        if(_S766)
        {
            mode_ts_0 = 1U;
        }
        else
        {
            mode_ts_0 = 2U;
        }
        if(diss_contact_0 > ((&st_2)->kappa_0))
        {
            _S765 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S765 = false;
        }
        if(_S765)
        {
            _S765 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S765 = false;
        }
        uint mode_c_0;
        if(_S765)
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
                mode_c_0 = kind_3;
            }
            else
            {
                mode_c_0 = 0U;
            }
            float2  inc_0 = damage_increment_0(mode_c_0, (&st_2)->kappa_0, diss_contact_0, intact_normal_0, (&st_2)->damage_0, psi_ts_0);
            float _S767 = inc_0.x;
            if(_S767 > ((&st_2)->damage_0))
            {
                Contact_0 _S768 = contact_part_0(mat_7, b_28, (&st_2)->crush_0, plastic_4, d_lin_2, d_ang_2);
                float _S769 = (F32_max((_S768.energy_2 - (1.0f - (&st_2)->crush_0) * psi_c_0), (0.0f)));
                float _S770 = (F32_max((inc_0.y - _S769 * (_S767 - (&st_2)->damage_0)), (0.0f)));
                float _S771 = (F32_max(((psi_ts_0 - _S769) * (_S767 - (&st_2)->damage_0) - _S770), (0.0f)));
                (&st_2)->damage_0 = _S767;
                (&st_2)->mode_0 = mode_ts_0;
                dissipated_3 = _S770;
                overshoot_1 = _S771;
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
        float _S772 = state_2->damage_0;
        if((state_2->damage_0) > 0.0f)
        {
            Contact_0 _S773 = contact_part_0(mat_7, b_28, state_2->crush_0, make_float3 (state_2->plastic_x_0, state_2->plastic_y_0, state_2->plastic_t_0), d_lin_2, d_ang_2);
            qc_lin_0 = qe_ang_0 * make_float3 (1.0f - _S772) + _S773.q_ang_1 * make_float3 (_S772);
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S774 = stress_measures_0(b_28, make_float3 (0.0f, 0.0f, (F32_min((qe_lin_0.z), (0.0f)))), qc_lin_0);
        Measures_0 _S775 = _S774;
        float4  _S776 = failure_indices_0(mat_7, b_28, &_S775, multiplier_1);
        float _S777 = _S776.z;
        float _S778 = _S776.w;
        bool _S779 = _S777 >= _S778;
        if(_S779)
        {
            psi_contact_0 = _S777;
        }
        else
        {
            psi_contact_0 = _S778;
        }
        if(_S779)
        {
            mode_c_0 = 3U;
        }
        else
        {
            mode_c_0 = 4U;
        }
        if(psi_contact_0 > ((&st_2)->kappa_c_0))
        {
            _S765 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S765 = false;
        }
        if(_S765)
        {
            _S765 = psi_c_0 > 0.0f;
        }
        else
        {
            _S765 = false;
        }
        if(_S765)
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
                    mode_ts_0 = kind_3;
                }
                law_1 = mode_ts_0;
            }
            float2  inc_1 = damage_increment_0(law_1, (&st_2)->kappa_c_0, psi_contact_0, intact_normal_0, (&st_2)->crush_0, psi_c_0);
            float _S780 = inc_1.x;
            if(_S780 > ((&st_2)->crush_0))
            {
                float _S781 = inc_1.y;
                float dissipated_4 = dissipated_3 + _S781;
                float overshoot_2 = overshoot_1 + (F32_max((psi_c_0 * (_S780 - (&st_2)->crush_0) - _S781), (0.0f)));
                (&st_2)->crush_0 = _S780;
                (&st_2)->mode_0 = mode_c_0;
                if(_S780 >= 1.0f)
                {
                    _S765 = ((&st_2)->damage_0) < 1.0f;
                }
                else
                {
                    _S765 = false;
                }
                if(_S765)
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
    float3  _S782 = make_float3 (0.0f);
    float3  qc_ang_0;
    if(((&st_2)->damage_0) == 0.0f)
    {
        if((flags_1 & 8U) == 0U)
        {
            float3  _S783 = contact_offsets_0(mat_7, b_28, (&st_2)->crush_0, plastic_4, d_lin_2, d_ang_2);
            (&st_2)->plastic_x_0 = _S783.x;
            (&st_2)->plastic_y_0 = _S783.y;
            (&st_2)->plastic_t_0 = _S783.z;
        }
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S782;
        qc_ang_0 = _S782;
        psi_contact_0 = 0.0f;
    }
    else
    {
        Contact_0 _S784 = contact_part_0(mat_7, b_28, (&st_2)->crush_0, plastic_4, d_lin_2, d_ang_2);
        (&st_2)->plastic_x_0 = _S784.plastic_1.x;
        (&st_2)->plastic_y_0 = _S784.plastic_1.y;
        (&st_2)->plastic_t_0 = _S784.plastic_1.z;
        diss_contact_0 = _S784.diss_4;
        qc_lin_0 = _S784.q_lin_1;
        qc_ang_0 = _S784.q_ang_1;
        psi_contact_0 = _S784.energy_2;
    }
    float dissipated_6 = dissipated_3 + dmg_0 * diss_contact_0;
    if(_S764)
    {
        intact_normal_0 = kn_3 * _S763;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_2)->crush_0) * kn_3 * _S763;
    }
    float _S785 = 1.0f - dmg_0;
    float3  force_lin_2 = make_float3 (_S785 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S785 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S785 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3  force_ang_2 = qe_ang_0 * make_float3 (_S785) + qc_ang_0 * make_float3 (dmg_0);
    float stored_6 = _S785 * (psi_ts_0 + (1.0f - (&st_2)->crush_0) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S765 = ((&st_2)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S765 = false;
    }
    float stored_7;
    float3  force_lin_3;
    if(_S765)
    {
        float k_axial_0 = b_28->rebar0_0.x;
        float k_dowel_0 = b_28->rebar0_0.y;
        float yield_force_0 = b_28->rebar0_0.z;
        float dowel_capacity_0 = b_28->rebar0_0.w;
        float2  nr_0 = return_map_0(k_axial_0, _S763, (&st_2)->rebar_plastic_0, yield_force_0);
        float2  v1_0 = return_map_0(k_dowel_0, _S760, (&st_2)->rebar_slip0_0, dowel_capacity_0);
        float2  v2_0 = return_map_0(k_dowel_0, _S761, (&st_2)->rebar_slip1_0, dowel_capacity_0);
        float _S786 = nr_0.y;
        float _S787 = v1_0.y;
        float _S788 = v2_0.y;
        float work_0 = yield_force_0 * (F32_abs((_S786))) + dowel_capacity_0 * ((F32_abs((_S787))) + (F32_abs((_S788))));
        (&st_2)->rebar_plastic_0 = (&st_2)->rebar_plastic_0 + _S786;
        (&st_2)->rebar_slip0_0 = (&st_2)->rebar_slip0_0 + _S787;
        (&st_2)->rebar_slip1_0 = (&st_2)->rebar_slip1_0 + _S788;
        (&st_2)->rebar_work_0 = (&st_2)->rebar_work_0 + work_0;
        float dissipated_7 = dissipated_6 + work_0;
        float _S789 = nr_0.x;
        float _S790 = v1_0.x;
        float _S791 = v2_0.x;
        float elastic_0 = 0.5f * (fdiv_0(sq_0(_S789), k_axial_0) + fdiv_0(sq_0(_S790) + sq_0(_S791), k_dowel_0));
        if(fracture_1)
        {
            _S765 = ((&st_2)->rebar_work_0) >= (b_28->rebar1_0.x);
        }
        else
        {
            _S765 = false;
        }
        if(_S765)
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
            force_lin_3 = force_lin_2 + make_float3 (_S790, _S791, _S789);
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
        _S765 = _S753;
    }
    else
    {
        _S765 = false;
    }
    if(_S765)
    {
        _S765 = (flags_1 & 64U) != 0U;
    }
    else
    {
        _S765 = false;
    }
    if(_S765)
    {
        Measures_0 _S792 = stress_measures_0(b_28, force_lin_3, force_ang_2);
        Measures_0 _S793 = _S792;
        float4  _S794 = failure_indices_0(mat_7, b_28, &_S793, weibull_0);
        float _S795 = life_rate_0(mat_7, (F32_max(((F32_max((_S794.x), (_S794.y)))), (_S794.z))));
        (&st_2)->life_0 = (F32_max(((&st_2)->life_0 - _S795 * dt_7), (0.0f)));
    }
    (&st_2)->dissipated_0 = (&st_2)->dissipated_0 + dissipated_3;
    JointResponse_0 resp_0;
    (&resp_0)->force_lin_1 = force_lin_3;
    (&resp_0)->force_ang_1 = force_ang_2;
    (&resp_0)->state_1 = st_2;
    (&resp_0)->dissipated_2 = dissipated_3;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_5 = stored_7;
    if(_S750)
    {
        JointState_0 _S796 = st_2;
        bool _S797 = connected_0(&_S796, has_rebar_1);
        _S765 = !_S797;
    }
    else
    {
        _S765 = false;
    }
    (&resp_0)->disconnected_0 = _S765;
    (&resp_0)->fatigue_before_0 = _S755;
    (&resp_0)->measures_0 = _S751;
    return resp_0;
}

static __device__ void secant_factors_0(JointBond_0 * b_29, JointState_0 * st_3, float3  d_lin_3, float3  * f_lin_0, float3  * f_ang_0)
{
    float _S798 = st_3->damage_0;
    bool compressed_0 = (d_lin_3.z) < 0.0f;
    float contact_2;
    if(compressed_0)
    {
        contact_2 = _S798;
    }
    else
    {
        contact_2 = 0.0f;
    }
    float _S799 = 1.0f - _S798;
    float _S800 = (F32_max((_S799 + contact_2), (9.99999997475242708e-07f)));
    float normal_4;
    if(compressed_0)
    {
        normal_4 = (F32_max((1.0f - st_3->crush_0), (9.99999997475242708e-07f)));
    }
    else
    {
        normal_4 = (F32_max((_S799), (9.99999997475242708e-07f)));
    }
    *f_lin_0 = make_float3 (_S800, _S800, normal_4);
    *f_ang_0 = make_float3 (_S800);
    bool _S801;
    if((b_29->stiff1_0.w) != 0.0f)
    {
        _S801 = (st_3->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S801 = false;
    }
    if(_S801)
    {
        float4  _S802 = b_29->rebar0_0;
        float4  _S803 = b_29->stiff0_0;
        *&(f_lin_0->z) = *&(f_lin_0->z) + fdiv_0(b_29->rebar0_0.x, b_29->stiff0_0.x);
        float _S804 = fdiv_0(_S802.y, _S803.y);
        *&(f_lin_0->x) = *&(f_lin_0->x) + _S804;
        *&(f_lin_0->y) = *&(f_lin_0->y) + _S804;
    }
    return;
}

static __device__ float3  to_local_0(uint _S805, float3  _S806)
{
    BondStatic_0 * _S807 = (&(globalParams_0->bonds_0)[_S805]);
    float4  _S808 = __ldg(&_S807->t1_0);
    float _S809 = dot_0(_S806, float3 {_S808.x, _S808.y, _S808.z});
    float4  _S810 = __ldg(&_S807->t2_0);
    float _S811 = dot_0(_S806, float3 {_S810.x, _S810.y, _S810.z});
    float4  _S812 = __ldg(&_S807->normal_0);
    return make_float3 (_S809, _S811, dot_0(_S806, float3 {_S812.x, _S812.y, _S812.z}));
}

static __device__ float3  to_body_0(uint _S813, float3  _S814)
{
    BondStatic_0 * _S815 = (&(globalParams_0->bonds_0)[_S813]);
    float4  _S816 = __ldg(&_S815->t1_0);
    float3  _S817 = float3 {_S816.x, _S816.y, _S816.z} * make_float3 (_S814.x);
    float4  _S818 = __ldg(&_S815->t2_0);
    float3  _S819 = _S817 + float3 {_S818.x, _S818.y, _S818.z} * make_float3 (_S814.y);
    float4  _S820 = __ldg(&_S815->normal_0);
    return _S819 + float3 {_S820.x, _S820.y, _S820.z} * make_float3 (_S814.z);
}

static __device__ bool bond_update_0(uint i_14, float dt_8, bool fracture_2, uint abs_step_0, bool wide_0)
{
    BondStatic_0 * _S821 = (&(globalParams_0->bonds_0)[i_14]);
    JointBond_0 _S822 = slang_ldg_0(&_S821->law_0);
    uint ca_0 = _S822.ids_0.y;
    uint cb_0 = _S822.ids_0.z;
    float4  _S823 = __ldg(&_S821->ra_0);
    float3  ra_1 = float3 {_S823.x, _S823.y, _S823.z};
    float4  _S824 = __ldg(&_S821->rb_0);
    float3  rb_1 = float3 {_S824.x, _S824.y, _S824.z};
    uint _S825 = 4U * ca_0;
    float4  _S826 = *(&(globalParams_0->state_0)[_S825]);
    float4  _S827 = *(&(globalParams_0->state_0)[_S825 + 1U]);
    float3  ta_2 = float3 {_S827.x, _S827.y, _S827.z};
    float4  _S828 = *(&(globalParams_0->state_0)[_S825 + 2U]);
    float3  va_0 = float3 {_S828.x, _S828.y, _S828.z};
    float4  _S829 = *(&(globalParams_0->state_0)[_S825 + 3U]);
    float3  wa_1 = float3 {_S829.x, _S829.y, _S829.z};
    uint _S830 = 4U * cb_0;
    float4  _S831 = *(&(globalParams_0->state_0)[_S830]);
    float4  _S832 = *(&(globalParams_0->state_0)[_S830 + 1U]);
    float3  tb_2 = float3 {_S832.x, _S832.y, _S832.z};
    float4  _S833 = *(&(globalParams_0->state_0)[_S830 + 2U]);
    float3  vb_0 = float3 {_S833.x, _S833.y, _S833.z};
    float4  _S834 = *(&(globalParams_0->state_0)[_S830 + 3U]);
    float3  wb_0 = float3 {_S834.x, _S834.y, _S834.z};
    float3  _S835 = to_local_0(i_14, float3 {_S831.x, _S831.y, _S831.z} + cross_0(tb_2, rb_1) - (float3 {_S826.x, _S826.y, _S826.z} + cross_0(ta_2, ra_1)));
    float3  _S836 = to_local_0(i_14, tb_2 - ta_2);
    float3  _S837 = to_local_0(i_14, vb_0 + cross_0(wb_0, rb_1) - (va_0 + cross_0(wa_1, ra_1)));
    float3  _S838 = to_local_0(i_14, wb_0 - wa_1);
    JointBond_0 _S839 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_14])->law_0);
    JointState_0 previous_0 = (&(globalParams_0->bond_dyn_0)[i_14])->js_0;
    JointState_0 _S840 = (&(globalParams_0->bond_dyn_0)[i_14])->js_0;
    bool _S841 = is_damaged_0(&_S840);
    JointBond_0 _S842 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_14])->law_0);
    JointBond_0 _S843 = _S842;
    JointState_0 _S844 = (&(globalParams_0->bond_dyn_0)[i_14])->js_0;
    JointResponse_0 _S845 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S839.ids_0.x], &_S843, &_S844, _S835, _S836, dt_8, fracture_2);
    BondStatic_0 * _S846 = (&(globalParams_0->bonds_0)[i_14]);
    BondDyn_0 bd_0 = *(&(globalParams_0->bond_dyn_0)[i_14]);
    float4  _S847 = __ldg(&_S846->ra_0);
    float3  ra_2 = float3 {_S847.x, _S847.y, _S847.z};
    float4  _S848 = __ldg(&_S846->rb_0);
    float3  rb_2 = float3 {_S848.x, _S848.y, _S848.z};
    JointBond_0 _S849 = slang_ldg_0(&_S846->law_0);
    JointBond_0 _S850 = _S849;
    JointState_0 _S851 = _S845.state_1;
    float3  f_lin_1;
    float3  f_ang_1;
    secant_factors_0(&_S850, &_S851, _S835, &f_lin_1, &f_ang_1);
    float4  _S852 = __ldg(&_S846->c_lin_0);
    float3  qd_lin_0 = _S837 * float3 {_S852.x, _S852.y, _S852.z} * f_lin_1;
    float4  _S853 = __ldg(&_S846->c_ang_0);
    float3  qd_ang_0 = _S838 * float3 {_S853.x, _S853.y, _S853.z} * f_ang_1;
    float3  q_lin_2 = _S845.force_lin_1 + qd_lin_0;
    float3  q_ang_2 = _S845.force_ang_1 + qd_ang_0;
    float damped_0 = (dot_0(qd_lin_0, _S837) + dot_0(qd_ang_0, _S838)) * dt_8;
    float3  _S854 = to_body_0(i_14, q_lin_2);
    float3  _S855 = to_body_0(i_14, q_ang_2);
    uint _S856 = 3U * i_14;
    *(&(globalParams_0->scratch_0)[_S856]) = make_float4 (_S854.x, _S854.y, _S854.z, (F32_max((_S845.measures_0.tension_0), (_S845.measures_0.compression_0))));
    *(&(globalParams_0->scratch_0)[_S856 + 1U]) = make_float4 ((_S855 + cross_0(ra_2, _S854)).x, (_S855 + cross_0(ra_2, _S854)).y, (_S855 + cross_0(ra_2, _S854)).z, 0.0f);
    *(&(globalParams_0->scratch_0)[_S856 + 2U]) = make_float4 ((- _S855 + cross_0(rb_2, - _S854)).x, (- _S855 + cross_0(rb_2, - _S854)).y, (- _S855 + cross_0(rb_2, - _S854)).z, 0.0f);
    comp_add1_0(&((&(&bd_0)->sums_0)->x), &((&(&bd_0)->comps_0)->x), _S845.dissipated_2);
    comp_add1_0(&((&(&bd_0)->sums_0)->y), &((&(&bd_0)->comps_0)->y), _S845.overshoot_0);
    comp_add1_0(&((&(&bd_0)->sums_0)->z), &((&(&bd_0)->comps_0)->z), damped_0);
    (&bd_0)->force_lin_0 = make_float4 (q_lin_2.x, q_lin_2.y, q_lin_2.z, _S845.stored_5);
    (&bd_0)->force_ang_0 = make_float4 (q_ang_2.x, q_ang_2.y, q_ang_2.z, (F32_max(((&bd_0)->force_ang_0.w), (_S845.state_1.utilization_0))));
    bool _S857;
    if(!_S841)
    {
        JointState_0 _S858 = _S845.state_1;
        bool _S859 = is_damaged_0(&_S858);
        _S857 = _S859;
    }
    else
    {
        _S857 = false;
    }
    if(_S857)
    {
        _S857 = ((&bd_0)->events_0.x) == 0U;
    }
    else
    {
        _S857 = false;
    }
    if(_S857)
    {
        *&((&(&bd_0)->events_0)->x) = abs_step_0;
        *&((&(&bd_0)->events_0)->w) = _S845.state_1.mode_0;
        if(wide_0)
        {
            cov_or_0(_S849.ids_0.w, 32U);
        }
        else
        {
            (*&g_seen_0)[3U] = 1U;
        }
    }
    if(((&bd_0)->events_0.y) == 0U)
    {
        _S857 = (_S845.state_1.life_0) != (previous_0.life_0);
    }
    else
    {
        _S857 = false;
    }
    if(_S857)
    {
        _S857 = (_S845.fatigue_before_0) > 0.99000000953674316f;
    }
    else
    {
        _S857 = false;
    }
    if(_S857)
    {
        float _S860 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S839.ids_0.x], _S845.state_1.life_0);
        _S857 = _S860 <= 0.99000000953674316f;
    }
    else
    {
        _S857 = false;
    }
    if(_S857)
    {
        *&((&(&bd_0)->events_0)->y) = abs_step_0;
        if(wide_0)
        {
            cov_or_0(_S849.ids_0.w, 64U);
        }
        else
        {
            (*&g_seen_0)[4U] = 1U;
        }
    }
    if(_S845.disconnected_0)
    {
        *&((&(&bd_0)->events_0)->z) = abs_step_0;
    }
    (&bd_0)->js_0 = _S845.state_1;
    *(&(globalParams_0->bond_dyn_0)[i_14]) = bd_0;
    return _S845.disconnected_0;
}

static __device__ void chunk_update_0(uint c_11, Island_0 * isl_4, Rigid_0 * rg_3, float dt_9, bool rml_0, uint step_0, bool contact_3, float * work_1, float * work_err_0)
{
    ChunkStatic_0 * _S861 = (&(globalParams_0->chunks_0)[c_11]);
    float3  _S862 = make_float3 (0.0f);
    uint _S863 = __ldg((&(globalParams_0->index_0)[c_11]));
    float peak_0 = 0.0f;
    uint e_3 = _S863;
    float3  fi_0 = _S862;
    float3  mi_0 = _S862;
    for(;;)
    {
        uint _S864 = __ldg((&(globalParams_0->index_0)[c_11 + 1U]));
        if(e_3 < _S864)
        {
        }
        else
        {
            break;
        }
        uint _S865 = __ldg((&(globalParams_0->index_0)[e_3]));
        uint _S866 = 3U * (_S865 >> int(1));
        float4  fa_2 = *(&(globalParams_0->scratch_0)[_S866]);
        if((_S865 & 1U) == 0U)
        {
            float4  _S867 = *(&(globalParams_0->scratch_0)[_S866 + 1U]);
            float3  mi_1 = mi_0 + float3 {_S867.x, _S867.y, _S867.z};
            fi_0 = fi_0 + float3 {fa_2.x, fa_2.y, fa_2.z};
            mi_0 = mi_1;
        }
        else
        {
            float4  _S868 = *(&(globalParams_0->scratch_0)[_S866 + 2U]);
            float3  mi_2 = mi_0 + float3 {_S868.x, _S868.y, _S868.z};
            fi_0 = fi_0 + - float3 {fa_2.x, fa_2.y, fa_2.z};
            mi_0 = mi_2;
        }
        float _S869 = (F32_max((peak_0), (fa_2.w)));
        uint _S870 = e_3 + 1U;
        peak_0 = _S869;
        e_3 = _S870;
    }
    uint _S871 = 4U * c_11;
    float4  _S872 = *(&(globalParams_0->state_0)[_S871]);
    float3  u_0 = float3 {_S872.x, _S872.y, _S872.z};
    uint _S873 = _S871 + 1U;
    float4  _S874 = *(&(globalParams_0->state_0)[_S873]);
    float3  th_2 = float3 {_S874.x, _S874.y, _S874.z};
    uint _S875 = _S871 + 2U;
    float4  _S876 = *(&(globalParams_0->state_0)[_S875]);
    float3  v_9 = float3 {_S876.x, _S876.y, _S876.z};
    uint _S877 = _S871 + 3U;
    float4  _S878 = *(&(globalParams_0->state_0)[_S877]);
    float3  w_5 = float3 {_S878.x, _S878.y, _S878.z};
    float4  _S879 = __ldg(&_S861->center_0);
    float mass_0 = _S879.w;
    float3  _S880 = float3 {_S879.x, _S879.y, _S879.z};
    float4  _S881 = isl_4->com_0;
    float3  _S882 = float3 {_S881.x, _S881.y, _S881.z};
    float3  _S883 = rotate_0(&rg_3->rot_0, _S880 + u_0 - _S882);
    float3  f_load_0;
    float3  t_load_0;
    float3  rep_f_1;
    float3  rep_m_1;
    chunk_loads_0(c_11, c_11, &rg_3->rot_0, step_0, dt_9, contact_3, dt_9, &f_load_0, &t_load_0, &rep_f_1, &rep_m_1);
    record_chunk_load_0(c_11, f_load_0, t_load_0);
    float3  _S884 = f_load_0;
    float4  _S885 = __ldg(&globalParams_0->params_0->gravity_0);
    float3  f_world_0 = _S884 + float3 {_S885.x, _S885.y, _S885.z} * make_float3 (mass_0);
    float3  t_world_0 = t_load_0;
    float3  f_world_1;
    float3  t_world_1;
    if(rml_0)
    {
        float3  _S886 = rg_3->alpha_0;
        float3  _S887 = rg_3->w_4;
        float3  f_world_2 = f_world_0 - (rg_3->a_7 + cross_0(rg_3->alpha_0, _S883) + cross_0(rg_3->w_4, cross_0(rg_3->w_4, _S883))) * make_float3 (mass_0);
        float4  _S888 = __ldg(&_S861->inertia0_0);
        float4  _S889 = __ldg(&_S861->inertia1_0);
        float4  _S890 = __ldg(&_S861->inertia2_0);
        float3  _S891 = world_mul_0(&rg_3->rot_0, _S888, _S889, _S890, _S886);
        float3  _S892 = world_mul_0(&rg_3->rot_0, _S888, _S889, _S890, _S887);
        float3  t_world_2 = t_world_0 - (_S891 + cross_0(_S887, _S892));
        f_world_1 = f_world_2;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    float3  _S893 = inverse_rotate_0(&rg_3->rot_0, f_world_1);
    float3  _S894 = inverse_rotate_0(&rg_3->rot_0, t_world_1);
    float3  f_ext_0;
    float3  m_ext_0;
    if(rml_0)
    {
        float3  _S895 = inverse_rotate_0(&rg_3->rot_0, rg_3->w_4);
        float3  f_ext_1 = _S893 - cross_0(_S895, v_9) * make_float3 (2.0f * mass_0);
        float4  _S896 = __ldg(&_S861->inertia0_0);
        float4  _S897 = __ldg(&_S861->inertia1_0);
        float4  _S898 = __ldg(&_S861->inertia2_0);
        float3  i_w_0 = rows_mul_0(_S896, _S897, _S898, w_5);
        float3  m_ext_1 = _S894 - (cross_0(_S895, i_w_0) + cross_0(w_5, rows_mul_0(_S896, _S897, _S898, _S895)) + cross_0(w_5, i_w_0));
        f_ext_0 = f_ext_1;
        m_ext_0 = m_ext_1;
    }
    else
    {
        f_ext_0 = _S893;
        m_ext_0 = _S894;
    }
    float3  f_13 = f_ext_0 + rep_f_1 + fi_0;
    float3  m_5 = m_ext_0 + rep_m_1 + mi_0;
    uint4  _S899 = __ldg(&_S861->info_0);
    uint support_0 = _S899.x;
    float3  _S900 = make_float3 ((*(&(globalParams_0->state_0)[_S873])).w, (*(&(globalParams_0->state_0)[_S875])).w, (*(&(globalParams_0->state_0)[_S877])).w);
    float3  reaction_0;
    float3  u_1;
    float3  th_3;
    float3  v_10;
    float3  w_6;
    if(support_0 == 1U)
    {
        reaction_0 = - f_13;
        u_1 = u_0;
        th_3 = th_2;
        v_10 = _S862;
        w_6 = _S862;
    }
    else
    {
        float4  _S901 = __ldg(&_S861->inv0_0);
        float4  _S902 = __ldg(&_S861->inv1_0);
        float4  _S903 = __ldg(&_S861->inv2_0);
        float3  _S904 = rows_mul_0(_S901, _S902, _S903, m_5);
        float4  _S905 = __ldg(&_S861->scale_0);
        float3  w_7 = w_5 + _S904 * make_float3 (dt_9 * _S905.z);
        float3  th_4 = th_2 + w_7 * make_float3 (dt_9);
        if(support_0 == 2U)
        {
            reaction_0 = - f_13;
            u_1 = u_0;
            th_3 = _S862;
        }
        else
        {
            float3  v_11 = v_9 + f_13 * make_float3 (dt_9 * _S905.y);
            float3  u_2 = u_0 + v_11 * make_float3 (dt_9);
            reaction_0 = _S900;
            u_1 = u_2;
            th_3 = v_11;
        }
        float3  _S906 = th_3;
        th_3 = th_4;
        v_10 = _S906;
        w_6 = w_7;
    }
    *(&(globalParams_0->state_0)[_S871]) = make_float4 (u_1.x, u_1.y, u_1.z, peak_0);
    *(&(globalParams_0->state_0)[_S873]) = make_float4 (th_3.x, th_3.y, th_3.z, reaction_0.x);
    *(&(globalParams_0->state_0)[_S875]) = make_float4 (v_10.x, v_10.y, v_10.z, reaction_0.y);
    *(&(globalParams_0->state_0)[_S877]) = make_float4 (w_6.x, w_6.y, w_6.z, reaction_0.z);
    float3  _S907 = rotate_0(&rg_3->rot_0, _S880 + u_1 - _S882);
    float3  _S908 = rg_3->vel_1 + rg_3->vel_err_1 + cross_0(rg_3->w_4, _S907);
    float3  _S909 = rotate_0(&rg_3->rot_0, v_10);
    float3  v_world_0 = _S908 + _S909;
    float3  _S910 = rotate_0(&rg_3->rot_0, w_6);
    comp_add1_0(work_1, work_err_0, (dot_0(f_load_0, v_world_0) + dot_0(t_load_0, rg_3->w_4 + _S910)) * dt_9);
    return;
}

static __device__ float3  turn_difference_0(float3  omega_1, float dt_10, float3  v_12)
{
    float _S911 = length_0(omega_1);
    float angle_3 = _S911 * dt_10;
    if(angle_3 < 1.00000000317107685e-30f)
    {
        return make_float3 (0.0f);
    }
    float3  a_14 = omega_1 / make_float3 (_S911);
    float s_6 = (F32_sin((0.5f * angle_3)));
    float3  av_0 = cross_0(a_14, v_12);
    return av_0 * make_float3 ((F32_sin((angle_3)))) + cross_0(a_14, av_0) * make_float3 (2.0f * s_6 * s_6);
}

static __device__ void integrate_rigid_0(Island_0 * isl_5, Rigid_0 * rg_4, float dt_11)
{
    comp_add_0(&rg_4->l_2, &rg_4->l_err_1, rg_4->torque_0 * make_float3 (dt_11));
    float3  l_3 = rg_4->l_2 + rg_4->l_err_1;
    comp_add_0(&rg_4->vel_1, &rg_4->vel_err_1, rg_4->a_7 * make_float3 (dt_11));
    float3  vel_2 = rg_4->vel_1 + rg_4->vel_err_1;
    float4  _S912 = isl_5->inv0_1;
    float4  _S913 = isl_5->inv1_1;
    float4  _S914 = isl_5->inv2_1;
    Quat_0 _S915 = rg_4->rot_0;
    float3  _S916 = world_mul_0(&_S915, isl_5->inv0_1, isl_5->inv1_1, isl_5->inv2_1, l_3);
    float3  _S917 = vel_2 * make_float3 (dt_11);
    float4  _S918 = isl_5->com_0;
    float3  _S919 = float3 {_S918.x, _S918.y, _S918.z};
    Quat_0 _S920 = rg_4->rot_0;
    float3  _S921 = rotate_0(&_S920, _S919);
    comp_add_0(&rg_4->pos_1, &rg_4->pos_err_1, _S917 - turn_difference_0(_S916, dt_11, _S921));
    turn_left_0(&rg_4->rot_0, &rg_4->rot_err_0, _S916, dt_11);
    Quat_0 _S922 = rg_4->rot_0;
    float3  _S923 = world_mul_0(&_S922, _S912, _S913, _S914, l_3);
    rg_4->w_4 = _S923;
    return;
}

static __device__ void drift_moments_0(uint c_12, float3  * tu_0, float3  * pv_0)
{
    ChunkStatic_0 * _S924 = (&(globalParams_0->chunks_0)[c_12]);
    float4  _S925 = __ldg(&_S924->center_0);
    float _S926 = _S925.w;
    float4  _S927 = __ldg(&_S924->scale_0);
    float m_6 = _S926 * _S927.x;
    uint _S928 = 4U * c_12;
    float4  _S929 = *(&(globalParams_0->state_0)[_S928]);
    *tu_0 = *tu_0 + float3 {_S929.x, _S929.y, _S929.z} * make_float3 (m_6);
    float4  _S930 = *(&(globalParams_0->state_0)[_S928 + 2U]);
    *pv_0 = *pv_0 + float3 {_S930.x, _S930.y, _S930.z} * make_float3 (m_6);
    return;
}

static __device__ void drift_angular_0(uint c_13, float3  wcom_1, float3  tr_0, float3  dv_0, float3  * lu_0, float3  * lv_0)
{
    ChunkStatic_0 * _S931 = (&(globalParams_0->chunks_0)[c_13]);
    float4  _S932 = __ldg(&_S931->center_0);
    float3  r_9 = float3 {_S932.x, _S932.y, _S932.z} - wcom_1;
    float4  _S933 = __ldg(&_S931->scale_0);
    float kw_0 = _S933.x;
    uint _S934 = 4U * c_13;
    float4  _S935 = *(&(globalParams_0->state_0)[_S934]);
    float _S936 = _S932.w;
    float3  _S937 = cross_0(r_9, float3 {_S935.x, _S935.y, _S935.z} - tr_0) * make_float3 (_S936);
    float4  _S938 = __ldg(&_S931->inertia0_0);
    float4  _S939 = __ldg(&_S931->inertia1_0);
    float4  _S940 = __ldg(&_S931->inertia2_0);
    float4  _S941 = *(&(globalParams_0->state_0)[_S934 + 1U]);
    *lu_0 = *lu_0 + (_S937 + rows_mul_0(_S938, _S939, _S940, float3 {_S941.x, _S941.y, _S941.z})) * make_float3 (kw_0);
    float4  _S942 = *(&(globalParams_0->state_0)[_S934 + 2U]);
    float4  _S943 = *(&(globalParams_0->state_0)[_S934 + 3U]);
    *lv_0 = *lv_0 + (cross_0(r_9, float3 {_S942.x, _S942.y, _S942.z} - dv_0) * make_float3 (_S936) + rows_mul_0(_S938, _S939, _S940, float3 {_S943.x, _S943.y, _S943.z})) * make_float3 (kw_0);
    return;
}

static __device__ void drift_apply_0(uint c_14, float3  wcom_2, float3  tr_1, float3  phi_0, float3  dv_1, float3  dw_0)
{
    float4  _S944 = __ldg(&(&(globalParams_0->chunks_0)[c_14])->center_0);
    float3  r_10 = float3 {_S944.x, _S944.y, _S944.z} - wcom_2;
    uint _S945 = 4U * c_14;
    float4  _S946 = *(&(globalParams_0->state_0)[_S945]);
    *(&(globalParams_0->state_0)[_S945]) = make_float4 ((float3 {_S946.x, _S946.y, _S946.z} - (tr_1 + cross_0(phi_0, r_10))).x, (float3 {_S946.x, _S946.y, _S946.z} - (tr_1 + cross_0(phi_0, r_10))).y, (float3 {_S946.x, _S946.y, _S946.z} - (tr_1 + cross_0(phi_0, r_10))).z, (*(&(globalParams_0->state_0)[_S945])).w);
    uint _S947 = _S945 + 1U;
    float4  _S948 = *(&(globalParams_0->state_0)[_S947]);
    *(&(globalParams_0->state_0)[_S947]) = make_float4 ((float3 {_S948.x, _S948.y, _S948.z} - phi_0).x, (float3 {_S948.x, _S948.y, _S948.z} - phi_0).y, (float3 {_S948.x, _S948.y, _S948.z} - phi_0).z, (*(&(globalParams_0->state_0)[_S947])).w);
    uint _S949 = _S945 + 2U;
    float4  _S950 = *(&(globalParams_0->state_0)[_S949]);
    *(&(globalParams_0->state_0)[_S949]) = make_float4 ((float3 {_S950.x, _S950.y, _S950.z} - (dv_1 + cross_0(dw_0, r_10))).x, (float3 {_S950.x, _S950.y, _S950.z} - (dv_1 + cross_0(dw_0, r_10))).y, (float3 {_S950.x, _S950.y, _S950.z} - (dv_1 + cross_0(dw_0, r_10))).z, (*(&(globalParams_0->state_0)[_S949])).w);
    uint _S951 = _S945 + 3U;
    float4  _S952 = *(&(globalParams_0->state_0)[_S951]);
    *(&(globalParams_0->state_0)[_S951]) = make_float4 ((float3 {_S952.x, _S952.y, _S952.z} - dw_0).x, (float3 {_S952.x, _S952.y, _S952.z} - dw_0).y, (float3 {_S952.x, _S952.y, _S952.z} - dw_0).z, (*(&(globalParams_0->state_0)[_S951])).w);
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
    Quat_0 _S953 = *hi_3;
    Quat_0 _S954 = dq_1;
    Quat_0 _S955 = quat_mul_0(&_S953, &_S954);
    Quat_0 _S956 = _S955;
    float4  _S957 = quat_vec_0(&_S956);
    quat_accumulate_0(hi_3, lo_3, _S957);
    return;
}

static __device__ void drift_rigid_0(Island_0 * isl_6, Rigid_0 * rg_5, float3  tr_2, float3  phi_2, float3  dv_2, float3  dw_1)
{
    float4  _S958 = isl_6->wcom_0;
    float3  wcom_3 = float3 {_S958.x, _S958.y, _S958.z};
    Quat_0 rot_2 = rg_5->rot_0;
    float3  _S959 = tr_2 - cross_0(phi_2, wcom_3);
    Quat_0 _S960 = rg_5->rot_0;
    float3  _S961 = rotate_0(&_S960, _S959);
    comp_add_0(&rg_5->pos_1, &rg_5->pos_err_1, _S961);
    Quat_0 _S962 = rg_5->rot_0;
    float3  _S963 = inverse_rotate_0(&_S962, rg_5->w_4);
    float4  _S964 = isl_6->inertia0_1;
    float4  _S965 = isl_6->inertia1_1;
    float4  _S966 = isl_6->inertia2_1;
    float3  _S967 = cross_0(phi_2, rows_mul_0(isl_6->inertia0_1, isl_6->inertia1_1, isl_6->inertia2_1, _S963)) - rows_mul_0(isl_6->inertia0_1, isl_6->inertia1_1, isl_6->inertia2_1, cross_0(phi_2, _S963));
    Quat_0 _S968 = rg_5->rot_0;
    float3  _S969 = rotate_0(&_S968, _S967);
    turn_right_0(&rg_5->rot_0, &rg_5->rot_err_0, phi_2);
    float4  _S970 = isl_6->com_0;
    float3  _S971 = dv_2 + cross_0(dw_1, float3 {_S970.x, _S970.y, _S970.z} - wcom_3);
    Quat_0 _S972 = rot_2;
    float3  _S973 = rotate_0(&_S972, _S971);
    comp_add_0(&rg_5->vel_1, &rg_5->vel_err_1, _S973);
    Quat_0 _S974 = rot_2;
    float3  _S975 = rotate_0(&_S974, dw_1);
    rg_5->w_4 = rg_5->w_4 + _S975;
    Quat_0 _S976 = rg_5->rot_0;
    float3  _S977 = world_mul_0(&_S976, _S964, _S965, _S966, _S975);
    comp_add_0(&rg_5->l_2, &rg_5->l_err_1, _S969 + _S977);
    return;
}

static __device__ void write_probe_0(uint slot_0, uint k_16, float value_1)
{
    uint _S978 = __ldg(&globalParams_0->params_0->probe_base_0);
    uint _S979 = _S978 * 4U;
    uint _S980 = __ldg(&globalParams_0->params_0->probe_stride_0);
    uint at_4 = _S979 + slot_0 * _S980 + k_16;
    float4  v_13 = *(&(globalParams_0->scratch_0)[at_4 / 4U]);
    *_slang_vector_get_element_ptr(&v_13, at_4 % 4U) = value_1;
    *(&(globalParams_0->scratch_0)[at_4 / 4U]) = v_13;
    return;
}

static __device__ void record_probes_0(Island_0 * isl_7, Rigid_0 * rg_6, uint k_17)
{
    uint4  _S981 = isl_7->probes_0;
    uint at_5 = isl_7->probes_0.x;
    for(;;)
    {
        if(at_5 < (_S981.y))
        {
        }
        else
        {
            break;
        }
        float4  _S982 = __ldg((&(globalParams_0->loads_0)[at_5]));
        uint4  info_3 = asuint_0(_S982);
        float4  _S983 = __ldg((&(globalParams_0->loads_0)[at_5 + 1U]));
        float4  _S984 = __ldg((&(globalParams_0->loads_0)[at_5 + 2U]));
        float4  _S985 = __ldg((&(globalParams_0->loads_0)[at_5 + 3U]));
        uint kind_4 = info_3.x;
        uint i_15 = info_3.y;
        float value_2;
        if(kind_4 == 0U)
        {
            float4  _S986 = *(&(globalParams_0->state_0)[4U * i_15]);
            float3  small_0 = float3 {_S986.x, _S986.y, _S986.z} + make_float3 (_S983.w, _S984.w, _S985.w);
            float3  _S987 = rg_6->pos_1 - float3 {_S984.x, _S984.y, _S984.z};
            float4  _S988 = __ldg(&(&(globalParams_0->chunks_0)[i_15])->center_0);
            float3  _S989 = rotate_0(&rg_6->rot_0, float3 {_S988.x, _S988.y, _S988.z});
            float3  _S990 = _S987 + _S989;
            float3  _S991 = rg_6->pos_err_1 - float3 {_S985.x, _S985.y, _S985.z};
            float3  _S992 = rotate_0(&rg_6->rot_0, small_0);
            value_2 = dot_0(_S990 + (_S991 + _S992), float3 {_S983.x, _S983.y, _S983.z});
        }
        else
        {
            if(kind_4 == 1U)
            {
                float4  _S993 = __ldg(&(&(globalParams_0->chunks_0)[i_15])->center_0);
                uint _S994 = 4U * i_15;
                float4  _S995 = *(&(globalParams_0->state_0)[_S994]);
                float4  _S996 = isl_7->com_0;
                float3  _S997 = rotate_0(&rg_6->rot_0, float3 {_S993.x, _S993.y, _S993.z} + float3 {_S995.x, _S995.y, _S995.z} - float3 {_S996.x, _S996.y, _S996.z});
                float3  _S998 = rg_6->vel_1 + rg_6->vel_err_1 + cross_0(rg_6->w_4, _S997);
                float4  _S999 = *(&(globalParams_0->state_0)[_S994 + 2U]);
                float3  _S1000 = rotate_0(&rg_6->rot_0, float3 {_S999.x, _S999.y, _S999.z});
                value_2 = dot_0(_S998 + _S1000, float3 {_S983.x, _S983.y, _S983.z});
            }
            else
            {
                if(kind_4 == 2U)
                {
                    uint _S1001 = 3U * i_15;
                    float4  _S1002 = *(&(globalParams_0->scratch_0)[_S1001]);
                    float3  f_14 = float3 {_S1002.x, _S1002.y, _S1002.z};
                    bool _S1003 = (info_3.z) == 0U;
                    float3  mc_0;
                    if(_S1003)
                    {
                        float4  _S1004 = *(&(globalParams_0->scratch_0)[_S1001 + 1U]);
                        mc_0 = float3 {_S1004.x, _S1004.y, _S1004.z};
                    }
                    else
                    {
                        float4  _S1005 = *(&(globalParams_0->scratch_0)[_S1001 + 2U]);
                        mc_0 = float3 {_S1005.x, _S1005.y, _S1005.z};
                    }
                    float3  fc_3;
                    if(_S1003)
                    {
                        fc_3 = f_14;
                    }
                    else
                    {
                        fc_3 = - f_14;
                    }
                    value_2 = dot_0(fc_3, float3 {_S983.x, _S983.y, _S983.z}) + dot_0(mc_0, float3 {_S984.x, _S984.y, _S984.z});
                }
                else
                {
                    uint _S1006 = 4U * i_15;
                    float3  _S1007 = rotate_0(&rg_6->rot_0, make_float3 ((*(&(globalParams_0->state_0)[_S1006 + 1U])).w, (*(&(globalParams_0->state_0)[_S1006 + 2U])).w, (*(&(globalParams_0->state_0)[_S1006 + 3U])).w));
                    value_2 = dot_0(_S1007, float3 {_S983.x, _S983.y, _S983.z});
                }
            }
        }
        write_probe_0(info_3.w, k_17, value_2);
        at_5 = at_5 + 4U;
    }
    return;
}

static __device__ void contact_split_at_0(uint at_6)
{
    uint _S1008 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint previous_1 = (&(globalParams_0->islands_0)[_S1008])->info_1.y;
    uint _S1009 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint _S1010;
    if(previous_1 == 0U)
    {
        _S1010 = at_6;
    }
    else
    {
        _S1010 = (U32_min((previous_1), (at_6)));
    }
    *&((&(&(globalParams_0->islands_0)[_S1009])->info_1)->y) = _S1010;
    return;
}

static __device__ uint seen_bits_0()
{
    uint _S1011;
    if(((*&g_seen_0)[0U]) != 0U)
    {
        _S1011 = 32768U;
    }
    else
    {
        _S1011 = 0U;
    }
    uint _S1012;
    if(((*&g_seen_0)[1U]) != 0U)
    {
        _S1012 = 65536U;
    }
    else
    {
        _S1012 = 0U;
    }
    uint _S1013 = _S1011 | _S1012;
    if(((*&g_seen_0)[2U]) != 0U)
    {
        _S1011 = 131072U;
    }
    else
    {
        _S1011 = 0U;
    }
    uint _S1014 = _S1013 | _S1011;
    if(((*&g_seen_0)[3U]) != 0U)
    {
        _S1011 = 32U;
    }
    else
    {
        _S1011 = 0U;
    }
    uint _S1015 = _S1014 | _S1011;
    if(((*&g_seen_0)[4U]) != 0U)
    {
        _S1011 = 64U;
    }
    else
    {
        _S1011 = 0U;
    }
    return _S1015 | _S1011;
}

extern "C" __global__ void island_frame()
{
    bool woke_0;
    uint _S1016;
    uint _S1017;
    uint _S1018;
    uint _S1019;
    uint _S1020;
    uint _S1021;
    uint _S1022 = __ballot_sync(4294967295U, true);
    uint tid_5 = threadIdx.x;
    uint _S1023 = blockIdx.x;
    Island_0 isl_8 = *(&(globalParams_0->islands_0)[_S1023]);
    bool driven_0 = (((&isl_8)->info_1.x) & 2U) != 0U;
    bool _S1024 = !((((&isl_8)->info_1.x) & 1U) != 0U);
    uint _S1025 = __ballot_sync(_S1022, _S1024);
    bool _S1026;
    uint cov_0;
    if(_S1024)
    {
        bool _S1027 = !driven_0;
        uint _S1028 = __ballot_sync(_S1022, true);
        _S1026 = _S1027;
        cov_0 = _S1028;
    }
    else
    {
        uint _S1029 = __ballot_sync(_S1022, true);
        _S1026 = false;
        cov_0 = _S1029;
    }
    bool contact_island_0 = (((&isl_8)->info_1.x) & 4U) != 0U;
    bool _S1030 = (((&isl_8)->info_1.x) & 16U) != 0U;
    seen_clear_0(tid_5);
    bool _S1031 = tid_5 == 0U;
    uint _S1032 = __ballot_sync(cov_0, _S1031);
    bool settled_0;
    uint run_0;
    uint done_1;
    if(_S1031)
    {
        uint _S1033 = __ldg(&globalParams_0->params_0->contact_mode_0);
        bool _S1034 = contact_island_0 != (_S1033 == 1U);
        uint _S1035 = __ballot_sync(_S1032, _S1034);
        if(_S1034)
        {
            uint _S1036 = __ballot_sync(_S1032, true);
            settled_0 = true;
            run_0 = _S1036;
        }
        else
        {
            bool _S1037 = (((&isl_8)->info_1.x) & 8U) != 0U;
            uint _S1038 = __ballot_sync(_S1032, true);
            settled_0 = _S1037;
            run_0 = _S1038;
        }
        uint _S1039 = __ballot_sync(run_0, settled_0);
        if(settled_0)
        {
            uint _S1040 = __ballot_sync(run_0, true);
            run_0 = 0U;
            done_1 = _S1040;
        }
        else
        {
            uint _S1041 = __ballot_sync(run_0, true);
            run_0 = 1U;
            done_1 = _S1041;
        }
        uint _S1042 = __ballot_sync(done_1, contact_island_0);
        if(contact_island_0)
        {
            Island_0 _S1043 = isl_8;
            bool _S1044 = contact_stopped_0(&_S1043);
            uint _S1045 = __ballot_sync(done_1, true);
            settled_0 = _S1044;
            done_1 = _S1045;
        }
        else
        {
            uint _S1046 = __ballot_sync(done_1, true);
            settled_0 = false;
            done_1 = _S1046;
        }
        uint _S1047 = __ballot_sync(done_1, settled_0);
        if(settled_0)
        {
            uint _S1048 = __ballot_sync(done_1, true);
            run_0 = 0U;
        }
        else
        {
            uint _S1049 = __ballot_sync(done_1, true);
        }
        *&g_run_0 = run_0;
        *&g_halt_0 = 0U;
        uint _S1050 = __ballot_sync(cov_0, true);
        cov_0 = _S1050;
    }
    else
    {
        uint _S1051 = __ballot_sync(cov_0, true);
        cov_0 = _S1051;
    }
    __syncthreads();
    bool _S1052 = (((&isl_8)->info_1.z) & 1U) != 0U;
    uint _S1053 = __ballot_sync(cov_0, _S1052);
    if(_S1052)
    {
        uint _S1054 = __ballot_sync(cov_0, true);
        settled_0 = true;
        cov_0 = _S1054;
    }
    else
    {
        bool _S1055 = (*&g_run_0) == 0U;
        uint _S1056 = __ballot_sync(cov_0, true);
        settled_0 = _S1055;
        cov_0 = _S1056;
    }
    uint _S1057 = __ballot_sync(cov_0, settled_0);
    if(settled_0)
    {
        uint _S1058 = __ballot_sync(cov_0, true);
        cov_0 = 0U;
        run_0 = _S1058;
    }
    else
    {
        uint _S1059 = (&isl_8)->info_1.y;
        uint _S1060 = __ldg(&globalParams_0->params_0->max_steps_0);
        uint _S1061 = (U32_min((_S1059), (_S1060)));
        uint _S1062 = __ballot_sync(cov_0, true);
        cov_0 = _S1061;
        run_0 = _S1062;
    }
    float _S1063 = __ldg(&globalParams_0->params_0->dt_0);
    uint _S1064 = __ldg(&globalParams_0->params_0->fracture_0);
    bool _S1065 = _S1064 != 0U;
    uint _S1066 = __ldg(&globalParams_0->params_0->rigid_motion_loads_0);
    bool _S1067 = _S1066 != 0U;
    Island_0 _S1068 = isl_8;
    Rigid_0 _S1069 = rigid_of_0(&_S1068);
    Rigid_0 rg_7 = _S1069;
    float work_2 = 0.0f;
    float work_err_1 = 0.0f;
    settled_0 = _S1030;
    done_1 = 0U;
    bool woke_1 = false;
    uint _S1070 = run_0;
    for(;;)
    {
        uint _S1071 = 0U;
        bool _S1072 = done_1 < cov_0;
        uint _S1073 = __ballot_sync(_S1070, _S1072);
        if(_S1072)
        {
            uint _S1074 = __ballot_sync(_S1070, true);
            _S1071 = _S1074;
        }
        else
        {
            uint _S1075 = __ballot_sync(_S1070, false);
            uint _S1076 = __ballot_sync(_S1070, false);
            uint _S1077 = __ballot_sync(run_0, true);
            woke_0 = woke_1;
            cov_0 = _S1077;
            break;
        }
        uint abs_step_1 = (&isl_8)->info_1.w + done_1 + 1U;
        uint _S1078 = abs_step_1 - 1U;
        uint _S1079 = __ldg(&globalParams_0->params_0->step_start_0);
        uint k_18 = _S1078 - _S1079;
        bool quiet_0 = (((&isl_8)->info_1.x) & 32U) != 0U;
        uint _S1080 = __ballot_sync(_S1071, settled_0);
        bool _S1081;
        uint _S1082;
        if(settled_0)
        {
            bool _S1083 = !quiet_0;
            uint _S1084 = __ballot_sync(_S1071, true);
            _S1081 = _S1083;
            _S1082 = _S1084;
        }
        else
        {
            uint _S1085 = __ballot_sync(_S1071, true);
            _S1081 = false;
            _S1082 = _S1085;
        }
        uint _S1086 = __ballot_sync(_S1082, _S1081);
        bool _S1087;
        bool explicit_step_0;
        uint c_15;
        uint _S1088;
        uint c_16;
        if(_S1081)
        {
            float3  _S1089 = make_float3 (0.0f);
            float3  norm_0 = _S1089;
            float3  unused0_0 = _S1089;
            c_15 = (&isl_8)->range_0.x + tid_5;
            _S1088 = _S1086;
            for(;;)
            {
                bool _S1090 = c_15 < ((&isl_8)->range_0.y);
                uint _S1091 = __ballot_sync(_S1088, _S1090);
                if(_S1090)
                {
                    uint _S1092 = __ballot_sync(_S1088, true);
                }
                else
                {
                    uint _S1093 = __ballot_sync(_S1088, false);
                    uint _S1094 = __ballot_sync(_S1088, false);
                    uint _S1095 = __ballot_sync(_S1086, true);
                    _S1016 = _S1095;
                    break;
                }
                Quat_0 _S1096 = (&rg_7)->rot_0;
                float _S1097 = settled_chunk_load_0(c_15, &_S1096, k_18, _S1063, contact_island_0);
                *&((&norm_0)->x) = *&((&norm_0)->x) + _S1097;
                uint _S1098 = __ballot_sync(_S1088, true);
                c_15 = c_15 + 256U;
                _S1088 = _S1098;
            }
            group_sum3_0(tid_5, &norm_0, &unused0_0, _S1016);
            uint _S1099 = __ldg(&globalParams_0->params_0->solve_mode_0);
            bool _S1100 = _S1099 == 1U;
            uint _S1101 = __ballot_sync(_S1016, _S1100);
            if(_S1100)
            {
                bool _S1102 = (F32_abs((norm_0.x - (&isl_8)->energy_1.z))) > ((&isl_8)->energy_1.w);
                uint _S1103 = __ballot_sync(_S1016, true);
                _S1087 = _S1102;
                c_16 = _S1103;
            }
            else
            {
                uint _S1104 = __ballot_sync(_S1016, true);
                _S1087 = false;
                c_16 = _S1104;
            }
            uint _S1105 = __ballot_sync(c_16, _S1087);
            if(_S1087)
            {
                uint _S1106 = __ballot_sync(c_16, true);
                explicit_step_0 = false;
                woke_0 = true;
            }
            else
            {
                uint _S1107 = __ballot_sync(c_16, true);
                explicit_step_0 = settled_0;
                woke_0 = woke_1;
            }
            uint _S1108 = __ballot_sync(_S1082, true);
            settled_0 = explicit_step_0;
            c_15 = _S1108;
        }
        else
        {
            uint _S1109 = __ballot_sync(_S1082, true);
            woke_0 = woke_1;
            c_15 = _S1109;
        }
        uint _S1110 = __ballot_sync(c_15, _S1024);
        if(_S1024)
        {
            bool _S1111 = !quiet_0;
            uint _S1112 = __ballot_sync(c_15, true);
            _S1087 = _S1111;
            _S1088 = _S1112;
        }
        else
        {
            uint _S1113 = __ballot_sync(c_15, true);
            _S1087 = false;
            _S1088 = _S1113;
        }
        uint _S1114 = __ballot_sync(_S1088, _S1087);
        uint _S1115;
        if(_S1087)
        {
            float3  _S1116 = make_float3 (0.0f);
            float3  f_15 = _S1116;
            float3  t_12 = _S1116;
            c_16 = (&isl_8)->range_0.x + tid_5;
            _S1115 = _S1114;
            for(;;)
            {
                bool _S1117 = c_16 < ((&isl_8)->range_0.y);
                uint _S1118 = __ballot_sync(_S1115, _S1117);
                if(_S1117)
                {
                    uint _S1119 = __ballot_sync(_S1115, true);
                }
                else
                {
                    uint _S1120 = __ballot_sync(_S1115, false);
                    uint _S1121 = __ballot_sync(_S1115, false);
                    uint _S1122 = __ballot_sync(_S1114, true);
                    _S1017 = _S1122;
                    break;
                }
                Island_0 _S1123 = isl_8;
                Rigid_0 _S1124 = rg_7;
                net_load_0(c_16, &_S1123, &_S1124, k_18, _S1063, contact_island_0, &f_15, &t_12);
                uint _S1125 = __ballot_sync(_S1115, true);
                c_16 = c_16 + 256U;
                _S1115 = _S1125;
            }
            group_sum3_0(tid_5, &f_15, &t_12, _S1017);
            Island_0 _S1126 = isl_8;
            rigid_acceleration_0(&_S1126, &rg_7, f_15, t_12);
            uint _S1127 = __ballot_sync(_S1088, true);
            c_16 = _S1127;
        }
        else
        {
            uint _S1128 = __ballot_sync(_S1088, true);
            c_16 = _S1128;
        }
        bool _S1129 = !settled_0;
        uint _S1130 = __ballot_sync(c_16, _S1129);
        if(_S1129)
        {
            bool _S1131 = !quiet_0;
            uint _S1132 = __ballot_sync(c_16, true);
            explicit_step_0 = _S1131;
            _S1115 = _S1132;
        }
        else
        {
            uint _S1133 = __ballot_sync(c_16, true);
            explicit_step_0 = false;
            _S1115 = _S1133;
        }
        uint _S1134 = __ballot_sync(_S1115, explicit_step_0);
        uint i_16;
        uint _S1135;
        uint c_17;
        uint _S1136;
        if(explicit_step_0)
        {
            i_16 = (&isl_8)->range_0.z + tid_5;
            _S1135 = _S1134;
            for(;;)
            {
                uint _S1137 = 0U;
                bool _S1138 = i_16 < ((&isl_8)->range_0.w);
                uint _S1139 = __ballot_sync(_S1135, _S1138);
                if(_S1138)
                {
                    uint _S1140 = __ballot_sync(_S1135, true);
                    _S1137 = _S1140;
                }
                else
                {
                    uint _S1141 = __ballot_sync(_S1135, false);
                    uint _S1142 = __ballot_sync(_S1135, false);
                    uint _S1143 = __ballot_sync(_S1134, true);
                    _S1018 = _S1143;
                    break;
                }
                bool _S1144 = bond_update_0(i_16, _S1063, _S1065, abs_step_1, false);
                uint _S1145 = __ballot_sync(_S1137, _S1144);
                if(_S1144)
                {
                    *&g_halt_0 = 1U;
                    uint _S1146 = __ballot_sync(_S1137, true);
                }
                else
                {
                    uint _S1147 = __ballot_sync(_S1137, true);
                }
                uint _S1148 = __ballot_sync(_S1135, true);
                i_16 = i_16 + 256U;
                _S1135 = _S1148;
            }
            __syncthreads();
            c_17 = (&isl_8)->range_0.x + tid_5;
            _S1136 = _S1018;
            for(;;)
            {
                bool _S1149 = c_17 < ((&isl_8)->range_0.y);
                uint _S1150 = __ballot_sync(_S1136, _S1149);
                if(_S1149)
                {
                    uint _S1151 = __ballot_sync(_S1136, true);
                }
                else
                {
                    uint _S1152 = __ballot_sync(_S1136, false);
                    uint _S1153 = __ballot_sync(_S1136, false);
                    uint _S1154 = __ballot_sync(_S1018, true);
                    break;
                }
                Island_0 _S1155 = isl_8;
                Rigid_0 _S1156 = rg_7;
                chunk_update_0(c_17, &_S1155, &_S1156, _S1063, _S1067, k_18, contact_island_0, &work_2, &work_err_1);
                uint _S1157 = __ballot_sync(_S1136, true);
                c_17 = c_17 + 256U;
                _S1136 = _S1157;
            }
            __syncthreads();
            uint _S1158 = __ballot_sync(_S1115, true);
            i_16 = _S1158;
        }
        else
        {
            uint _S1159 = __ballot_sync(_S1115, true);
            i_16 = _S1159;
        }
        uint _S1160 = __ballot_sync(i_16, _S1026);
        bool _S1161;
        if(_S1026)
        {
            bool _S1162 = !quiet_0;
            uint _S1163 = __ballot_sync(i_16, true);
            _S1161 = _S1162;
            _S1135 = _S1163;
        }
        else
        {
            uint _S1164 = __ballot_sync(i_16, true);
            _S1161 = false;
            _S1135 = _S1164;
        }
        uint _S1165 = __ballot_sync(_S1135, _S1161);
        if(_S1161)
        {
            Island_0 _S1166 = isl_8;
            integrate_rigid_0(&_S1166, &rg_7, _S1063);
            uint _S1167 = __ballot_sync(_S1135, true);
            c_17 = _S1167;
        }
        else
        {
            uint _S1168 = __ballot_sync(_S1135, true);
            c_17 = _S1168;
        }
        uint _S1169 = __ballot_sync(c_17, _S1024);
        bool _S1170;
        if(_S1024)
        {
            uint _S1171 = __ballot_sync(c_17, true);
            _S1170 = explicit_step_0;
            _S1136 = _S1171;
        }
        else
        {
            uint _S1172 = __ballot_sync(c_17, true);
            _S1170 = false;
            _S1136 = _S1172;
        }
        uint _S1173 = __ballot_sync(_S1136, _S1170);
        uint c_18;
        uint _S1174;
        uint c_19;
        if(_S1170)
        {
            float4  _S1175 = (&isl_8)->wcom_0;
            float3  _S1176 = float3 {_S1175.x, _S1175.y, _S1175.z};
            float3  _S1177 = make_float3 (0.0f);
            float3  tu_1 = _S1177;
            float3  pv_1 = _S1177;
            c_18 = (&isl_8)->range_0.x + tid_5;
            _S1174 = _S1173;
            for(;;)
            {
                bool _S1178 = c_18 < ((&isl_8)->range_0.y);
                uint _S1179 = __ballot_sync(_S1174, _S1178);
                if(_S1178)
                {
                    uint _S1180 = __ballot_sync(_S1174, true);
                }
                else
                {
                    uint _S1181 = __ballot_sync(_S1174, false);
                    uint _S1182 = __ballot_sync(_S1174, false);
                    uint _S1183 = __ballot_sync(_S1173, true);
                    _S1019 = _S1183;
                    break;
                }
                drift_moments_0(c_18, &tu_1, &pv_1);
                uint _S1184 = __ballot_sync(_S1174, true);
                c_18 = c_18 + 256U;
                _S1174 = _S1184;
            }
            group_sum3_0(tid_5, &tu_1, &pv_1, _S1019);
            float3  tr_3 = tu_1 / make_float3 ((&isl_8)->wcom_0.w);
            float3  dv_3 = pv_1 / make_float3 ((&isl_8)->wcom_0.w);
            float3  lu_1 = _S1177;
            float3  lv_1 = _S1177;
            c_19 = (&isl_8)->range_0.x + tid_5;
            uint _S1185 = _S1019;
            for(;;)
            {
                bool _S1186 = c_19 < ((&isl_8)->range_0.y);
                uint _S1187 = __ballot_sync(_S1185, _S1186);
                if(_S1186)
                {
                    uint _S1188 = __ballot_sync(_S1185, true);
                }
                else
                {
                    uint _S1189 = __ballot_sync(_S1185, false);
                    uint _S1190 = __ballot_sync(_S1185, false);
                    uint _S1191 = __ballot_sync(_S1019, true);
                    _S1020 = _S1191;
                    break;
                }
                drift_angular_0(c_19, _S1176, tr_3, dv_3, &lu_1, &lv_1);
                uint _S1192 = __ballot_sync(_S1185, true);
                c_19 = c_19 + 256U;
                _S1185 = _S1192;
            }
            group_sum3_0(tid_5, &lu_1, &lv_1, _S1020);
            float3  phi_3 = rows_mul_0((&isl_8)->winv0_0, (&isl_8)->winv1_0, (&isl_8)->winv2_0, lu_1);
            float3  dw_2 = rows_mul_0((&isl_8)->winv0_0, (&isl_8)->winv1_0, (&isl_8)->winv2_0, lv_1);
            uint c_20 = (&isl_8)->range_0.x + tid_5;
            uint _S1193 = _S1020;
            for(;;)
            {
                bool _S1194 = c_20 < ((&isl_8)->range_0.y);
                uint _S1195 = __ballot_sync(_S1193, _S1194);
                if(_S1194)
                {
                    uint _S1196 = __ballot_sync(_S1193, true);
                }
                else
                {
                    uint _S1197 = __ballot_sync(_S1193, false);
                    uint _S1198 = __ballot_sync(_S1193, false);
                    uint _S1199 = __ballot_sync(_S1020, true);
                    _S1021 = _S1199;
                    break;
                }
                drift_apply_0(c_20, _S1176, tr_3, phi_3, dv_3, dw_2);
                uint _S1200 = __ballot_sync(_S1193, true);
                c_20 = c_20 + 256U;
                _S1193 = _S1200;
            }
            bool _S1201 = !driven_0;
            uint _S1202 = __ballot_sync(_S1021, _S1201);
            if(_S1201)
            {
                Island_0 _S1203 = isl_8;
                drift_rigid_0(&_S1203, &rg_7, tr_3, phi_3, dv_3, dw_2);
                uint _S1204 = __ballot_sync(_S1021, true);
            }
            else
            {
                uint _S1205 = __ballot_sync(_S1021, true);
            }
            __syncthreads();
            uint _S1206 = __ballot_sync(_S1136, true);
            c_18 = _S1206;
        }
        else
        {
            uint _S1207 = __ballot_sync(_S1136, true);
            c_18 = _S1207;
        }
        uint _S1208 = __ballot_sync(c_18, _S1031);
        bool _S1209;
        if(_S1031)
        {
            bool _S1210 = ((&isl_8)->probes_0.y) > ((&isl_8)->probes_0.x);
            uint _S1211 = __ballot_sync(c_18, true);
            _S1209 = _S1210;
            _S1174 = _S1211;
        }
        else
        {
            uint _S1212 = __ballot_sync(c_18, true);
            _S1209 = false;
            _S1174 = _S1212;
        }
        uint _S1213 = __ballot_sync(_S1174, _S1209);
        if(_S1209)
        {
            Island_0 _S1214 = isl_8;
            Rigid_0 _S1215 = rg_7;
            record_probes_0(&_S1214, &_S1215, k_18);
            uint _S1216 = __ballot_sync(_S1174, true);
            c_19 = _S1216;
        }
        else
        {
            uint _S1217 = __ballot_sync(_S1174, true);
            c_19 = _S1217;
        }
        uint _S1218 = done_1 + 1U;
        bool _S1219 = (*&g_halt_0) != 0U;
        uint _S1220 = __ballot_sync(c_19, _S1219);
        if(_S1219)
        {
            uint _S1221 = __ballot_sync(c_19, false);
            uint _S1222 = __ballot_sync(_S1070, false);
            uint _S1223 = __ballot_sync(run_0, true);
            done_1 = _S1218;
            cov_0 = _S1223;
            break;
        }
        else
        {
            uint _S1224 = __ballot_sync(c_19, true);
        }
        uint _S1225 = __ballot_sync(_S1070, true);
        done_1 = _S1218;
        woke_1 = woke_0;
        _S1070 = _S1225;
    }
    float3  wsum_0 = make_float3 (work_2, work_err_1, 0.0f);
    float3  unused_1 = make_float3 (0.0f);
    group_sum3_0(tid_5, &wsum_0, &unused_1, cov_0);
    uint _S1226 = __ballot_sync(cov_0, _S1031);
    if(_S1031)
    {
        Quat_0 _S1227 = (&rg_7)->rot_0;
        float4  _S1228 = quat_vec_0(&_S1227);
        (&isl_8)->rotation_0 = _S1228;
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
            _S1026 = contact_island_0;
        }
        else
        {
            _S1026 = false;
        }
        if(_S1026)
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
        uint _S1229 = seen_bits_0();
        if((*&g_halt_0) != 0U)
        {
            cov_0 = 128U;
        }
        else
        {
            cov_0 = 0U;
        }
        uint _S1230 = _S1229 | cov_0;
        if(woke_0)
        {
            cov_0 = 2048U;
        }
        else
        {
            cov_0 = 0U;
        }
        uint cov_1 = _S1230 | cov_0;
        if(done_1 > 0U)
        {
            bool quiet_1 = (((&isl_8)->info_1.x) & 32U) != 0U;
            if(quiet_1)
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
                _S1026 = !quiet_1;
            }
            else
            {
                _S1026 = false;
            }
            if(_S1026)
            {
                cov_0 = 512U;
            }
            else
            {
                cov_0 = 0U;
            }
            uint cov_3 = cov_2 | cov_0;
            uint _S1231 = __ldg(&globalParams_0->params_0->contact_mode_0);
            if(_S1231 == 1U)
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
        *(&(globalParams_0->islands_0)[_S1023]) = isl_8;
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
    uint _S1232 = table_0 + 4U * g_3;
    uint _S1233 = __ldg((&(globalParams_0->index_0)[_S1232]));
    (&w_8)->island_2 = _S1233;
    uint _S1234 = __ldg((&(globalParams_0->index_0)[_S1232 + 1U]));
    (&w_8)->begin_0 = _S1234;
    uint _S1235 = __ldg((&(globalParams_0->index_0)[_S1232 + 2U]));
    (&w_8)->end_0 = _S1235;
    uint _S1236 = __ldg((&(globalParams_0->index_0)[_S1232 + 3U]));
    (&w_8)->first_0 = _S1236;
    return w_8;
}

static __device__ bool wide_runs_0(Island_0 * isl_9)
{
    uint4  _S1237 = isl_9->info_1;
    bool _S1238;
    if(((isl_9->info_1.z) & 1U) != 0U)
    {
        _S1238 = true;
    }
    else
    {
        _S1238 = (_S1237.y) == 0U;
    }
    if(_S1238)
    {
        return false;
    }
    if(((_S1237.x) & 4U) == 0U)
    {
        _S1238 = true;
    }
    else
    {
        bool _S1239 = contact_stopped_0(isl_9);
        _S1238 = !_S1239;
    }
    return _S1238;
}

__device__ __shared__ uint g_wide_run_0;

static __device__ bool wide_enter_0(uint tid_6, Island_0 * isl_10)
{
    seen_clear_0(tid_6);
    if(tid_6 == 0U)
    {
        bool _S1240 = wide_runs_0(isl_10);
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

static __device__ uint wide_step_0(Island_0 * isl_11)
{
    uint _S1242 = isl_11->info_1.w;
    uint _S1243 = __ldg(&globalParams_0->params_0->step_start_0);
    return _S1242 - _S1243;
}

static __device__ bool wide_enter_1(uint _S1244, uint _S1245)
{
    Island_0 _S1246 = *(&(globalParams_0->islands_0)[_S1245]);
    seen_clear_0(_S1244);
    if(_S1244 == 0U)
    {
        Island_0 _S1247 = _S1246;
        bool _S1248 = wide_runs_0(&_S1247);
        int _S1249;
        if(_S1248)
        {
            _S1249 = int(1);
        }
        else
        {
            _S1249 = int(0);
        }
        *&g_wide_run_0 = uint(_S1249);
    }
    __syncthreads();
    return (*&g_wide_run_0) != 0U;
}

extern "C" __global__ void wide_wake()
{
    uint _S1250 = 0U;
    uint _S1251;
    uint _S1252 = __ballot_sync(4294967295U, true);
    uint tid_7 = threadIdx.x;
    uint _S1253 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1254 = blockIdx.x;
    WideGroup_0 wg_0 = wide_group_0(_S1253, _S1254);
    bool _S1255 = _S1254 != (wg_0.first_0);
    uint _S1256 = __ballot_sync(_S1252, _S1255);
    if(_S1255)
    {
        return;
    }
    else
    {
        uint _S1257 = __ballot_sync(_S1252, true);
        _S1250 = _S1257;
    }
    Island_0 * _S1258 = (&(globalParams_0->islands_0)[wg_0.island_2]);
    Island_0 isl_12 = *_S1258;
    uint _S1259 = (*_S1258).info_1.x;
    bool _S1260 = (_S1259 & 16U) == 0U;
    uint _S1261 = __ballot_sync(_S1250, _S1260);
    bool _S1262;
    uint c_21;
    if(_S1260)
    {
        uint _S1263 = __ballot_sync(_S1250, true);
        _S1262 = true;
        c_21 = _S1263;
    }
    else
    {
        bool _S1264 = wide_enter_1(tid_7, wg_0.island_2);
        bool _S1265 = !_S1264;
        uint _S1266 = __ballot_sync(_S1250, true);
        _S1262 = _S1265;
        c_21 = _S1266;
    }
    uint _S1267 = 0U;
    uint _S1268 = __ballot_sync(c_21, _S1262);
    if(_S1262)
    {
        return;
    }
    else
    {
        uint _S1269 = __ballot_sync(c_21, true);
        _S1267 = _S1269;
    }
    Quat_0 _S1270 = quat_of_0(isl_12.rotation_0);
    bool _S1271 = (_S1259 & 4U) != 0U;
    float3  _S1272 = make_float3 (0.0f);
    float3  norm_1 = _S1272;
    float3  unused_2 = _S1272;
    c_21 = isl_12.range_0.x + tid_7;
    uint cov_5;
    cov_5 = _S1267;
    for(;;)
    {
        bool _S1273 = c_21 < (isl_12.range_0.y);
        uint _S1274 = __ballot_sync(cov_5, _S1273);
        if(_S1273)
        {
            uint _S1275 = __ballot_sync(cov_5, true);
        }
        else
        {
            uint _S1276 = __ballot_sync(cov_5, false);
            uint _S1277 = __ballot_sync(cov_5, false);
            uint _S1278 = __ballot_sync(_S1267, true);
            _S1251 = _S1278;
            break;
        }
        Island_0 _S1279 = isl_12;
        uint _S1280 = wide_step_0(&_S1279);
        float _S1281 = __ldg(&globalParams_0->params_0->dt_0);
        Quat_0 _S1282 = _S1270;
        float _S1283 = settled_chunk_load_0(c_21, &_S1282, _S1280, _S1281, _S1271);
        *&((&norm_1)->x) = *&((&norm_1)->x) + _S1283;
        uint _S1284 = __ballot_sync(cov_5, true);
        c_21 = c_21 + 256U;
        cov_5 = _S1284;
    }
    group_sum3_0(tid_7, &norm_1, &unused_2, _S1251);
    bool _S1285 = tid_7 != 0U;
    uint _S1286 = __ballot_sync(_S1251, _S1285);
    if(_S1285)
    {
        return;
    }
    uint cov_6 = 1024U | (seen_bits_0());
    uint _S1287 = __ldg(&globalParams_0->params_0->solve_mode_0);
    if(_S1287 == 1U)
    {
        _S1262 = (F32_abs((norm_1.x - isl_12.energy_1.z))) > (isl_12.energy_1.w);
    }
    else
    {
        _S1262 = false;
    }
    if(_S1262)
    {
        *&((&(&(globalParams_0->islands_0)[wg_0.island_2])->info_1)->x) = _S1259 & 4294967279U;
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
    uint _S1288 = __ldg(&globalParams_0->params_0->wide_base_0);
    uint _S1289 = 8U * slot_1;
    *(&(globalParams_0->scratch_0)[_S1288 + _S1289 + p_12]) = make_float4 (a_15.x, a_15.y, a_15.z, 0.0f);
    uint _S1290 = __ldg(&globalParams_0->params_0->wide_base_0);
    *(&(globalParams_0->scratch_0)[_S1290 + _S1289 + p_12 + 1U]) = make_float4 (b_30.x, b_30.y, b_30.z, 0.0f);
    return;
}

extern "C" __global__ void wide_bonds()
{
    uint _S1291 = __ballot_sync(4294967295U, true);
    uint tid_8 = threadIdx.x;
    uint _S1292 = blockIdx.x;
    uint _S1293 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
    bool bond_group_0 = _S1292 < _S1293;
    uint _S1294 = __ballot_sync(_S1291, bond_group_0);
    WideGroup_0 wg_1;
    uint _S1295;
    if(bond_group_0)
    {
        uint _S1296 = __ldg(&globalParams_0->params_0->wide_bond_table_0);
        WideGroup_0 _S1297 = wide_group_0(_S1296, _S1292);
        uint _S1298 = __ballot_sync(_S1291, true);
        wg_1 = _S1297;
        _S1295 = _S1298;
    }
    else
    {
        uint _S1299 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
        uint _S1300 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
        WideGroup_0 _S1301 = wide_group_0(_S1299, _S1292 - _S1300);
        uint _S1302 = __ballot_sync(_S1291, true);
        wg_1 = _S1301;
        _S1295 = _S1302;
    }
    uint _S1303 = 0U;
    WideGroup_0 _S1304 = wg_1;
    Island_0 isl_13 = *(&(globalParams_0->islands_0)[wg_1.island_2]);
    bool _S1305 = wide_enter_1(tid_8, wg_1.island_2);
    bool _S1306 = !_S1305;
    uint _S1307 = __ballot_sync(_S1295, _S1306);
    if(_S1306)
    {
        return;
    }
    else
    {
        uint _S1308 = __ballot_sync(_S1295, true);
        _S1303 = _S1308;
    }
    uint _S1309 = 0U;
    Island_0 _S1310 = isl_13;
    uint _S1311 = wide_step_0(&_S1310);
    uint _S1312 = __ballot_sync(_S1303, bond_group_0);
    if(bond_group_0)
    {
        if(((isl_13.info_1.x) & 16U) != 0U)
        {
            return;
        }
        uint i_17 = wg_1.begin_0 + tid_8;
        bool _S1313;
        if(i_17 < (wg_1.end_0))
        {
            float _S1314 = __ldg(&globalParams_0->params_0->dt_0);
            uint _S1315 = __ldg(&globalParams_0->params_0->fracture_0);
            bool _S1316 = bond_update_0(i_17, _S1314, _S1315 != 0U, isl_13.info_1.w + 1U, true);
            _S1313 = _S1316;
        }
        else
        {
            _S1313 = false;
        }
        if(_S1313)
        {
            *&((&(&(globalParams_0->islands_0)[_S1304.island_2])->info_1)->z) = (isl_13.info_1.z) | 2U;
        }
        return;
    }
    else
    {
        uint _S1317 = __ballot_sync(_S1303, true);
        _S1309 = _S1317;
    }
    uint _S1318 = 0U;
    uint _S1319 = isl_13.info_1.x;
    bool _S1320 = (_S1319 & 1U) != 0U;
    uint _S1321 = __ballot_sync(_S1309, _S1320);
    if(_S1320)
    {
        return;
    }
    else
    {
        uint _S1322 = __ballot_sync(_S1309, true);
        _S1318 = _S1322;
    }
    float3  _S1323 = make_float3 (0.0f);
    float3  f_16 = _S1323;
    float3  t_13 = _S1323;
    uint c_22 = wg_1.begin_0 + tid_8;
    bool _S1324 = c_22 < (wg_1.end_0);
    uint _S1325 = __ballot_sync(_S1318, _S1324);
    if(_S1324)
    {
        Island_0 _S1326 = isl_13;
        Rigid_0 _S1327 = rigid_of_0(&_S1326);
        float _S1328 = __ldg(&globalParams_0->params_0->dt_0);
        bool _S1329 = (_S1319 & 4U) != 0U;
        Island_0 _S1330 = isl_13;
        Rigid_0 _S1331 = _S1327;
        net_load_0(c_22, &_S1330, &_S1331, _S1311, _S1328, _S1329, &f_16, &t_13);
        uint _S1332 = __ballot_sync(_S1318, true);
        _S1295 = _S1332;
    }
    else
    {
        uint _S1333 = __ballot_sync(_S1318, true);
        _S1295 = _S1333;
    }
    group_sum3_0(tid_8, &f_16, &t_13, _S1295);
    bool _S1334 = tid_8 == 0U;
    uint _S1335 = __ballot_sync(_S1295, _S1334);
    if(_S1334)
    {
        uint _S1336 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
        wide_store_0(_S1292 - _S1336, 0U, f_16, t_13);
    }
    return;
}

static __device__ void wide_partials_0(uint tid_9, uint first_1, uint count_5, uint p_13, float3  * a_16, float3  * b_31, uint _S1337)
{
    uint _S1338;
    float4  _S1339 = make_float4 (0.0f);
    float4  x_20 = _S1339;
    float4  y_5 = _S1339;
    uint s_7 = tid_9;
    uint _S1340 = _S1337;
    for(;;)
    {
        bool _S1341 = s_7 < count_5;
        uint _S1342 = __ballot_sync(_S1340, _S1341);
        if(_S1341)
        {
            uint _S1343 = __ballot_sync(_S1340, true);
        }
        else
        {
            uint _S1344 = __ballot_sync(_S1340, false);
            uint _S1345 = __ballot_sync(_S1340, false);
            uint _S1346 = __ballot_sync(_S1337, true);
            _S1338 = _S1346;
            break;
        }
        uint _S1347 = __ldg(&globalParams_0->params_0->wide_base_0);
        uint _S1348 = 8U * (first_1 + s_7);
        x_20 = x_20 + *(&(globalParams_0->scratch_0)[_S1347 + _S1348 + p_13]);
        uint _S1349 = __ldg(&globalParams_0->params_0->wide_base_0);
        y_5 = y_5 + *(&(globalParams_0->scratch_0)[_S1349 + _S1348 + p_13 + 1U]);
        uint _S1350 = __ballot_sync(_S1340, true);
        s_7 = s_7 + 256U;
        _S1340 = _S1350;
    }
    group_sum2_0(tid_9, &x_20, &y_5, _S1338);
    float4  _S1351 = x_20;
    *a_16 = float3 {_S1351.x, _S1351.y, _S1351.z};
    float4  _S1352 = y_5;
    *b_31 = float3 {_S1352.x, _S1352.y, _S1352.z};
    return;
}

static __device__ Rigid_0 wide_rigid_frame_0(uint tid_10, Island_0 * isl_14, WideGroup_0 * wg_2, uint _S1353)
{
    Rigid_0 _S1354 = rigid_of_0(isl_14);
    Rigid_0 rg_8 = _S1354;
    bool _S1355 = ((isl_14->info_1.x) & 1U) == 0U;
    uint _S1356 = __ballot_sync(_S1353, _S1355);
    if(_S1355)
    {
        float3  f_17;
        float3  t_14;
        wide_partials_0(tid_10, wg_2->first_0, isl_14->wide_groups_0, 0U, &f_17, &t_14, _S1356);
        rigid_acceleration_0(isl_14, &rg_8, f_17, t_14);
        uint _S1357 = __ballot_sync(_S1353, true);
    }
    return rg_8;
}

extern "C" __global__ void wide_chunks()
{
    uint _S1358 = 0U;
    uint _S1359 = __ballot_sync(4294967295U, true);
    uint tid_11 = threadIdx.x;
    uint _S1360 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1361 = blockIdx.x;
    WideGroup_0 wg_3 = wide_group_0(_S1360, _S1361);
    Island_0 isl_15 = *(&(globalParams_0->islands_0)[wg_3.island_2]);
    bool _S1362 = wide_enter_1(tid_11, wg_3.island_2);
    bool _S1363 = !_S1362;
    uint _S1364 = __ballot_sync(_S1359, _S1363);
    if(_S1363)
    {
        return;
    }
    else
    {
        uint _S1365 = __ballot_sync(_S1359, true);
        _S1358 = _S1365;
    }
    uint _S1366 = 0U;
    uint _S1367 = isl_15.info_1.x;
    bool anchored_0 = (_S1367 & 1U) != 0U;
    bool _S1368 = (_S1367 & 16U) != 0U;
    uint _S1369 = __ballot_sync(_S1358, _S1368);
    if(_S1368)
    {
        if(tid_11 == 0U)
        {
            uint _S1370 = __ldg(&globalParams_0->params_0->wide_base_0);
            *(&(globalParams_0->scratch_0)[_S1370 + 8U * _S1361 + 6U]) = make_float4 (0.0f);
        }
        return;
    }
    else
    {
        uint _S1371 = __ballot_sync(_S1358, true);
        _S1366 = _S1371;
    }
    Island_0 _S1372 = isl_15;
    WideGroup_0 _S1373 = wg_3;
    Rigid_0 _S1374 = wide_rigid_frame_0(tid_11, &_S1372, &_S1373, _S1366);
    float work_3 = 0.0f;
    float work_err_2 = 0.0f;
    float3  _S1375 = make_float3 (0.0f);
    float3  tu_2 = _S1375;
    float3  pv_2 = _S1375;
    uint c_23 = wg_3.begin_0 + tid_11;
    bool _S1376 = c_23 < (wg_3.end_0);
    uint _S1377 = __ballot_sync(_S1366, _S1376);
    uint _S1378;
    if(_S1376)
    {
        float _S1379 = __ldg(&globalParams_0->params_0->dt_0);
        uint _S1380 = __ldg(&globalParams_0->params_0->rigid_motion_loads_0);
        bool _S1381 = _S1380 != 0U;
        Island_0 _S1382 = isl_15;
        uint _S1383 = wide_step_0(&_S1382);
        bool _S1384 = (_S1367 & 4U) != 0U;
        Island_0 _S1385 = isl_15;
        Rigid_0 _S1386 = _S1374;
        chunk_update_0(c_23, &_S1385, &_S1386, _S1379, _S1381, _S1383, _S1384, &work_3, &work_err_2);
        bool _S1387 = !anchored_0;
        uint _S1388 = __ballot_sync(_S1377, _S1387);
        if(_S1387)
        {
            drift_moments_0(c_23, &tu_2, &pv_2);
            uint _S1389 = __ballot_sync(_S1377, true);
        }
        else
        {
            uint _S1390 = __ballot_sync(_S1377, true);
        }
        uint _S1391 = __ballot_sync(_S1366, true);
        _S1378 = _S1391;
    }
    else
    {
        uint _S1392 = __ballot_sync(_S1366, true);
        _S1378 = _S1392;
    }
    float3  wsum_1 = make_float3 (work_3, work_err_2, 0.0f);
    float3  unused_3 = _S1375;
    group_sum3_0(tid_11, &wsum_1, &unused_3, _S1378);
    bool _S1393 = !anchored_0;
    uint _S1394 = __ballot_sync(_S1378, _S1393);
    if(_S1393)
    {
        group_sum3_0(tid_11, &tu_2, &pv_2, _S1394);
        uint _S1395 = __ballot_sync(_S1378, true);
    }
    if(tid_11 == 0U)
    {
        uint _S1396 = __ldg(&globalParams_0->params_0->wide_base_0);
        uint _S1397 = 8U * _S1361;
        *(&(globalParams_0->scratch_0)[_S1396 + _S1397 + 6U]) = make_float4 (wsum_1.x, wsum_1.y, wsum_1.z, 0.0f);
        if(_S1393)
        {
            wide_store_0(_S1361, 2U, tu_2, pv_2);
        }
        uint _S1398 = __ldg(&globalParams_0->params_0->wide_base_0);
        *(&(globalParams_0->scratch_0)[_S1398 + _S1397 + 7U]) = make_float4 (float((*&g_seen_0)[0U]), float((*&g_seen_0)[1U]), float((*&g_seen_0)[2U]), 0.0f);
    }
    return;
}

extern "C" __global__ void wide_drift()
{
    uint _S1399 = __ballot_sync(4294967295U, true);
    uint tid_12 = threadIdx.x;
    uint _S1400 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1401 = blockIdx.x;
    WideGroup_0 wg_4 = wide_group_0(_S1400, _S1401);
    Island_0 * _S1402 = (&(globalParams_0->islands_0)[wg_4.island_2]);
    Island_0 isl_16 = *_S1402;
    bool _S1403 = (((*_S1402).info_1.x) & 17U) != 0U;
    uint _S1404 = __ballot_sync(_S1399, _S1403);
    bool _S1405;
    uint _S1406;
    if(_S1403)
    {
        uint _S1407 = __ballot_sync(_S1399, true);
        _S1405 = true;
        _S1406 = _S1407;
    }
    else
    {
        bool _S1408 = wide_enter_1(tid_12, wg_4.island_2);
        bool _S1409 = !_S1408;
        uint _S1410 = __ballot_sync(_S1399, true);
        _S1405 = _S1409;
        _S1406 = _S1410;
    }
    uint _S1411 = 0U;
    uint _S1412 = __ballot_sync(_S1406, _S1405);
    if(_S1405)
    {
        return;
    }
    else
    {
        uint _S1413 = __ballot_sync(_S1406, true);
        _S1411 = _S1413;
    }
    float3  tu_3;
    float3  pv_3;
    wide_partials_0(tid_12, wg_4.first_0, isl_16.wide_groups_0, 2U, &tu_3, &pv_3, _S1411);
    float _S1414 = isl_16.wcom_0.w;
    float3  tr_4 = tu_3 / make_float3 (_S1414);
    float3  dv_4 = pv_3 / make_float3 (_S1414);
    float3  _S1415 = make_float3 (0.0f);
    float3  lu_2 = _S1415;
    float3  lv_2 = _S1415;
    uint c_24 = wg_4.begin_0 + tid_12;
    bool _S1416 = c_24 < (wg_4.end_0);
    uint _S1417 = __ballot_sync(_S1411, _S1416);
    if(_S1416)
    {
        float4  _S1418 = isl_16.wcom_0;
        drift_angular_0(c_24, float3 {_S1418.x, _S1418.y, _S1418.z}, tr_4, dv_4, &lu_2, &lv_2);
        uint _S1419 = __ballot_sync(_S1411, true);
        _S1406 = _S1419;
    }
    else
    {
        uint _S1420 = __ballot_sync(_S1411, true);
        _S1406 = _S1420;
    }
    group_sum3_0(tid_12, &lu_2, &lv_2, _S1406);
    bool _S1421 = tid_12 == 0U;
    uint _S1422 = __ballot_sync(_S1406, _S1421);
    if(_S1421)
    {
        wide_store_0(_S1401, 4U, lu_2, lv_2);
    }
    return;
}

extern "C" __global__ void wide_rigid()
{
    uint _S1423 = __ballot_sync(4294967295U, true);
    uint tid_13 = threadIdx.x;
    uint _S1424 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1425 = blockIdx.x;
    WideGroup_0 wg_5 = wide_group_0(_S1424, _S1425);
    Island_0 * _S1426 = (&(globalParams_0->islands_0)[wg_5.island_2]);
    Island_0 isl_17 = *_S1426;
    uint _S1427 = (*_S1426).info_1.x;
    bool _S1428 = (_S1427 & 1U) != 0U;
    uint _S1429 = __ballot_sync(_S1423, _S1428);
    bool _S1430;
    uint _S1431;
    if(_S1428)
    {
        uint _S1432 = __ballot_sync(_S1423, true);
        _S1430 = true;
        _S1431 = _S1432;
    }
    else
    {
        bool _S1433 = wide_enter_1(tid_13, wg_5.island_2);
        bool _S1434 = !_S1433;
        uint _S1435 = __ballot_sync(_S1423, true);
        _S1430 = _S1434;
        _S1431 = _S1435;
    }
    uint _S1436 = 0U;
    uint _S1437 = __ballot_sync(_S1431, _S1430);
    if(_S1430)
    {
        return;
    }
    else
    {
        uint _S1438 = __ballot_sync(_S1431, true);
        _S1436 = _S1438;
    }
    uint _S1439 = 0U;
    bool _S1440 = (_S1427 & 16U) != 0U;
    uint _S1441 = __ballot_sync(_S1436, _S1440);
    if(_S1440)
    {
        uint _S1442 = 0U;
        bool _S1443 = _S1425 != (wg_5.first_0);
        uint _S1444 = __ballot_sync(_S1441, _S1443);
        if(_S1443)
        {
            return;
        }
        else
        {
            uint _S1445 = __ballot_sync(_S1441, true);
            _S1442 = _S1445;
        }
        Island_0 _S1446 = isl_17;
        WideGroup_0 _S1447 = wg_5;
        Rigid_0 _S1448 = wide_rigid_frame_0(tid_13, &_S1446, &_S1447, _S1442);
        Rigid_0 rs_0 = _S1448;
        bool _S1449 = tid_13 != 0U;
        uint _S1450 = __ballot_sync(_S1442, _S1449);
        if(_S1449)
        {
            _S1430 = true;
        }
        else
        {
            _S1430 = (_S1427 & 2U) != 0U;
        }
        if(_S1430)
        {
            return;
        }
        float _S1451 = __ldg(&globalParams_0->params_0->dt_0);
        Island_0 _S1452 = isl_17;
        integrate_rigid_0(&_S1452, &rs_0, _S1451);
        Quat_0 _S1453 = (&rs_0)->rot_0;
        float4  _S1454 = quat_vec_0(&_S1453);
        (&(globalParams_0->islands_0)[wg_5.island_2])->rotation_0 = _S1454;
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
        uint _S1455 = __ballot_sync(_S1436, true);
        _S1439 = _S1455;
    }
    float3  tu_4;
    float3  pv_4;
    wide_partials_0(tid_13, wg_5.first_0, isl_17.wide_groups_0, 2U, &tu_4, &pv_4, _S1439);
    float3  lu_3;
    float3  lv_3;
    wide_partials_0(tid_13, wg_5.first_0, isl_17.wide_groups_0, 4U, &lu_3, &lv_3, _S1439);
    float _S1456 = isl_17.wcom_0.w;
    float3  tr_5 = tu_4 / make_float3 (_S1456);
    float3  dv_5 = pv_4 / make_float3 (_S1456);
    float3  phi_4 = rows_mul_0(isl_17.winv0_0, isl_17.winv1_0, isl_17.winv2_0, lu_3);
    float3  dw_3 = rows_mul_0(isl_17.winv0_0, isl_17.winv1_0, isl_17.winv2_0, lv_3);
    uint c_25 = wg_5.begin_0 + tid_13;
    bool _S1457 = c_25 < (wg_5.end_0);
    uint _S1458 = __ballot_sync(_S1439, _S1457);
    if(_S1457)
    {
        float4  _S1459 = isl_17.wcom_0;
        drift_apply_0(c_25, float3 {_S1459.x, _S1459.y, _S1459.z}, tr_5, phi_4, dv_5, dw_3);
        uint _S1460 = __ballot_sync(_S1439, true);
        _S1431 = _S1460;
    }
    else
    {
        uint _S1461 = __ballot_sync(_S1439, true);
        _S1431 = _S1461;
    }
    uint _S1462 = 0U;
    bool _S1463 = _S1425 != (wg_5.first_0);
    uint _S1464 = __ballot_sync(_S1431, _S1463);
    if(_S1463)
    {
        return;
    }
    else
    {
        uint _S1465 = __ballot_sync(_S1431, true);
        _S1462 = _S1465;
    }
    Island_0 _S1466 = isl_17;
    WideGroup_0 _S1467 = wg_5;
    Rigid_0 _S1468 = wide_rigid_frame_0(tid_13, &_S1466, &_S1467, _S1462);
    Rigid_0 rg_9 = _S1468;
    bool _S1469 = tid_13 != 0U;
    uint _S1470 = __ballot_sync(_S1462, _S1469);
    if(_S1469)
    {
        return;
    }
    if(!((_S1427 & 2U) != 0U))
    {
        float _S1471 = __ldg(&globalParams_0->params_0->dt_0);
        Island_0 _S1472 = isl_17;
        integrate_rigid_0(&_S1472, &rg_9, _S1471);
        Island_0 _S1473 = isl_17;
        drift_rigid_0(&_S1473, &rg_9, tr_5, phi_4, dv_5, dw_3);
    }
    Quat_0 _S1474 = (&rg_9)->rot_0;
    float4  _S1475 = quat_vec_0(&_S1474);
    (&(globalParams_0->islands_0)[wg_5.island_2])->rotation_0 = _S1475;
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
    uint _S1476 = 0U;
    uint _S1477 = __ballot_sync(4294967295U, true);
    uint tid_14 = threadIdx.x;
    uint _S1478 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1479 = blockIdx.x;
    WideGroup_0 wg_6 = wide_group_0(_S1478, _S1479);
    bool _S1480 = _S1479 != (wg_6.first_0);
    uint _S1481 = __ballot_sync(_S1477, _S1480);
    if(_S1480)
    {
        return;
    }
    else
    {
        uint _S1482 = __ballot_sync(_S1477, true);
        _S1476 = _S1482;
    }
    uint _S1483 = 0U;
    Island_0 * _S1484 = (&(globalParams_0->islands_0)[wg_6.island_2]);
    Island_0 isl_18 = *_S1484;
    Island_0 _S1485 = *_S1484;
    bool _S1486 = wide_enter_0(tid_14, &_S1485);
    bool _S1487 = !_S1486;
    uint _S1488 = __ballot_sync(_S1476, _S1487);
    if(_S1487)
    {
        return;
    }
    else
    {
        uint _S1489 = __ballot_sync(_S1476, true);
        _S1483 = _S1489;
    }
    float3  work_4;
    float3  flags_2;
    wide_partials_0(tid_14, wg_6.first_0, (&isl_18)->wide_groups_0, 6U, &work_4, &flags_2, _S1483);
    bool _S1490 = tid_14 != 0U;
    uint _S1491 = __ballot_sync(_S1483, _S1490);
    if(_S1490)
    {
        return;
    }
    Island_0 _S1492 = isl_18;
    uint _S1493 = wide_step_0(&_S1492);
    if(((&isl_18)->probes_0.y) > ((&isl_18)->probes_0.x))
    {
        Island_0 _S1494 = isl_18;
        Rigid_0 _S1495 = rigid_of_0(&_S1494);
        Island_0 _S1496 = isl_18;
        Rigid_0 _S1497 = _S1495;
        record_probes_0(&_S1496, &_S1497, _S1493);
    }
    bool halt_0 = (((&isl_18)->info_1.z) & 2U) != 0U;
    bool _S1498;
    if(halt_0)
    {
        _S1498 = (((&isl_18)->info_1.x) & 4U) != 0U;
    }
    else
    {
        _S1498 = false;
    }
    if(_S1498)
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
    uint _S1499;
    if(halt_0)
    {
        _S1499 = 128U;
    }
    else
    {
        _S1499 = 0U;
    }
    uint _S1500 = 256U | _S1499;
    if(((&isl_18)->probes_0.y) > ((&isl_18)->probes_0.x))
    {
        _S1499 = 262144U;
    }
    else
    {
        _S1499 = 0U;
    }
    uint _S1501 = _S1500 | _S1499;
    if((((&isl_18)->info_1.x) & 4U) != 0U)
    {
        _S1499 = 524288U;
    }
    else
    {
        _S1499 = 0U;
    }
    uint _S1502 = _S1501 | _S1499;
    if((flags_2.x) > 0.0f)
    {
        _S1499 = 32768U;
    }
    else
    {
        _S1499 = 0U;
    }
    uint _S1503 = _S1502 | _S1499;
    if((flags_2.y) > 0.0f)
    {
        _S1499 = 65536U;
    }
    else
    {
        _S1499 = 0U;
    }
    uint _S1504 = _S1503 | _S1499;
    if((flags_2.z) > 0.0f)
    {
        _S1499 = 131072U;
    }
    else
    {
        _S1499 = 0U;
    }
    (&isl_18)->coverage_0 = ((&isl_18)->coverage_0) | (_S1504 | _S1499);
    *(&(globalParams_0->islands_0)[wg_6.island_2]) = isl_18;
    return;
}

static __device__ uint sv_0(uint c_26, uint slot_2)
{
    uint _S1505 = __ldg(&globalParams_0->params_0->statics_base_0);
    return _S1505 + 23U * c_26 + slot_2;
}

static __device__ void project_load_slot_0(uint tid_15, Island_0 * isl_19, uint slot_3, uint _S1506)
{
    uint _S1507;
    uint _S1508;
    float3  _S1509 = make_float3 (0.0f);
    float3  net_f_0 = _S1509;
    float3  net_m_0 = _S1509;
    uint4  _S1510 = isl_19->range_0;
    uint _S1511 = isl_19->range_0.x + tid_15;
    uint c_27 = _S1511;
    uint _S1512 = _S1506;
    for(;;)
    {
        uint _S1513 = _S1510.y;
        _S1507 = _S1513;
        bool _S1514 = c_27 < _S1513;
        uint _S1515 = __ballot_sync(_S1512, _S1514);
        if(_S1514)
        {
            uint _S1516 = __ballot_sync(_S1512, true);
        }
        else
        {
            uint _S1517 = __ballot_sync(_S1512, false);
            uint _S1518 = __ballot_sync(_S1512, false);
            uint _S1519 = __ballot_sync(_S1506, true);
            _S1508 = _S1519;
            break;
        }
        float4  _S1520 = *(&(globalParams_0->scratch_0)[sv_0(c_27, slot_3)]);
        float3  fi_1 = float3 {_S1520.x, _S1520.y, _S1520.z};
        net_f_0 = net_f_0 + fi_1;
        float4  _S1521 = __ldg(&(&(globalParams_0->chunks_0)[c_27])->center_0);
        float4  _S1522 = isl_19->com_0;
        float4  _S1523 = *(&(globalParams_0->scratch_0)[sv_0(c_27, slot_3 + 1U)]);
        net_m_0 = net_m_0 + (cross_0(float3 {_S1521.x, _S1521.y, _S1521.z} - float3 {_S1522.x, _S1522.y, _S1522.z}, fi_1) + float3 {_S1523.x, _S1523.y, _S1523.z});
        uint _S1524 = __ballot_sync(_S1512, true);
        c_27 = c_27 + 256U;
        _S1512 = _S1524;
    }
    group_sum3_0(tid_15, &net_f_0, &net_m_0, _S1508);
    float4  _S1525 = isl_19->com_0;
    float3  _S1526 = net_f_0 / make_float3 (isl_19->com_0.w);
    float3  _S1527 = rows_mul_0(isl_19->inv0_1, isl_19->inv1_1, isl_19->inv2_1, net_m_0);
    c_27 = _S1511;
    for(;;)
    {
        if(c_27 < _S1507)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_0 * _S1528 = (&(globalParams_0->chunks_0)[c_27]);
        float4  _S1529 = __ldg(&_S1528->center_0);
        uint _S1530 = sv_0(c_27, slot_3);
        float4  _S1531 = *(&(globalParams_0->scratch_0)[_S1530]);
        *(&(globalParams_0->scratch_0)[_S1530]) = make_float4 ((float3 {_S1531.x, _S1531.y, _S1531.z} - (_S1526 + cross_0(_S1527, float3 {_S1529.x, _S1529.y, _S1529.z} - float3 {_S1525.x, _S1525.y, _S1525.z})) * make_float3 (_S1529.w)).x, (float3 {_S1531.x, _S1531.y, _S1531.z} - (_S1526 + cross_0(_S1527, float3 {_S1529.x, _S1529.y, _S1529.z} - float3 {_S1525.x, _S1525.y, _S1525.z})) * make_float3 (_S1529.w)).y, (float3 {_S1531.x, _S1531.y, _S1531.z} - (_S1526 + cross_0(_S1527, float3 {_S1529.x, _S1529.y, _S1529.z} - float3 {_S1525.x, _S1525.y, _S1525.z})) * make_float3 (_S1529.w)).z, 0.0f);
        uint _S1532 = sv_0(c_27, slot_3 + 1U);
        float4  * _S1533 = (&(globalParams_0->scratch_0)[_S1532]);
        float4  _S1534 = *(&(globalParams_0->scratch_0)[_S1532]);
        float3  _S1535 = float3 {_S1534.x, _S1534.y, _S1534.z};
        float4  _S1536 = __ldg(&_S1528->inertia0_0);
        float4  _S1537 = __ldg(&_S1528->inertia1_0);
        float4  _S1538 = __ldg(&_S1528->inertia2_0);
        *_S1533 = make_float4 ((_S1535 - rows_mul_0(_S1536, _S1537, _S1538, _S1527)).x, (_S1535 - rows_mul_0(_S1536, _S1537, _S1538, _S1527)).y, (_S1535 - rows_mul_0(_S1536, _S1537, _S1538, _S1527)).z, 0.0f);
        c_27 = c_27 + 256U;
    }
    __syncthreads();
    return;
}

static __device__ float island_dot_0(uint tid_16, uint c0_0, uint c1_0, uint sa_2, uint sb_2, uint _S1539)
{
    uint _S1540;
    float4  _S1541 = make_float4 (0.0f);
    float4  acc_0 = _S1541;
    float4  unused_4 = _S1541;
    uint c_28 = c0_0 + tid_16;
    uint _S1542 = _S1539;
    for(;;)
    {
        bool _S1543 = c_28 < c1_0;
        uint _S1544 = __ballot_sync(_S1542, _S1543);
        if(_S1543)
        {
            uint _S1545 = __ballot_sync(_S1542, true);
        }
        else
        {
            uint _S1546 = __ballot_sync(_S1542, false);
            uint _S1547 = __ballot_sync(_S1542, false);
            uint _S1548 = __ballot_sync(_S1539, true);
            _S1540 = _S1548;
            break;
        }
        float4  _S1549 = *(&(globalParams_0->scratch_0)[sv_0(c_28, sa_2)]);
        float4  _S1550 = *(&(globalParams_0->scratch_0)[sv_0(c_28, sb_2)]);
        float4  _S1551 = *(&(globalParams_0->scratch_0)[sv_0(c_28, sa_2 + 1U)]);
        float4  _S1552 = *(&(globalParams_0->scratch_0)[sv_0(c_28, sb_2 + 1U)]);
        *&((&acc_0)->x) = *&((&acc_0)->x) + (dot_0(float3 {_S1549.x, _S1549.y, _S1549.z}, float3 {_S1550.x, _S1550.y, _S1550.z}) + dot_0(float3 {_S1551.x, _S1551.y, _S1551.z}, float3 {_S1552.x, _S1552.y, _S1552.z}));
        uint _S1553 = __ballot_sync(_S1542, true);
        c_28 = c_28 + 256U;
        _S1542 = _S1553;
    }
    group_sum2_0(tid_16, &acc_0, &unused_4, _S1540);
    return acc_0.x;
}

static __device__ void static_kinematics_0(uint _S1554, float3  * _S1555, float3  * _S1556)
{
    BondStatic_0 * _S1557 = (&(globalParams_0->bonds_0)[_S1554]);
    JointBond_0 _S1558 = slang_ldg_0(&_S1557->law_0);
    uint ca_1 = _S1558.ids_0.y;
    uint cb_1 = _S1558.ids_0.z;
    uint _S1559 = 4U * cb_1;
    float4  _S1560 = *(&(globalParams_0->state_0)[_S1559]);
    uint _S1561 = 4U * ca_1;
    float4  _S1562 = *(&(globalParams_0->state_0)[_S1561]);
    float4  _S1563 = *(&(globalParams_0->scratch_0)[sv_0(cb_1, 21U)]);
    float4  _S1564 = *(&(globalParams_0->scratch_0)[sv_0(ca_1, 21U)]);
    float3  du_0 = float3 {_S1560.x, _S1560.y, _S1560.z} - float3 {_S1562.x, _S1562.y, _S1562.z} + (float3 {_S1563.x, _S1563.y, _S1563.z} - float3 {_S1564.x, _S1564.y, _S1564.z});
    uint _S1565 = _S1559 + 1U;
    float4  _S1566 = *(&(globalParams_0->state_0)[_S1565]);
    uint _S1567 = _S1561 + 1U;
    float4  _S1568 = *(&(globalParams_0->state_0)[_S1567]);
    uint _S1569 = sv_0(cb_1, 22U);
    float4  _S1570 = *(&(globalParams_0->scratch_0)[_S1569]);
    uint _S1571 = sv_0(ca_1, 22U);
    float4  _S1572 = *(&(globalParams_0->scratch_0)[_S1571]);
    float3  dth_0 = float3 {_S1566.x, _S1566.y, _S1566.z} - float3 {_S1568.x, _S1568.y, _S1568.z} + (float3 {_S1570.x, _S1570.y, _S1570.z} - float3 {_S1572.x, _S1572.y, _S1572.z});
    float4  _S1573 = *(&(globalParams_0->state_0)[_S1567]);
    float4  _S1574 = *(&(globalParams_0->scratch_0)[_S1571]);
    float3  ta_3 = float3 {_S1573.x, _S1573.y, _S1573.z} + float3 {_S1574.x, _S1574.y, _S1574.z};
    float4  _S1575 = *(&(globalParams_0->state_0)[_S1565]);
    float4  _S1576 = *(&(globalParams_0->scratch_0)[_S1569]);
    float3  tb_3 = float3 {_S1575.x, _S1575.y, _S1575.z} + float3 {_S1576.x, _S1576.y, _S1576.z};
    float4  _S1577 = __ldg(&_S1557->rb_0);
    float3  _S1578 = cross_0(tb_3, float3 {_S1577.x, _S1577.y, _S1577.z});
    float4  _S1579 = __ldg(&_S1557->ra_0);
    float3  _S1580 = to_local_0(_S1554, du_0 + (_S1578 - cross_0(ta_3, float3 {_S1579.x, _S1579.y, _S1579.z})));
    *_S1555 = _S1580;
    float3  _S1581 = to_local_0(_S1554, dth_0);
    *_S1556 = _S1581;
    return;
}

static __device__ JointResponse_0 static_response_0(uint i_18)
{
    BondStatic_0 * _S1582 = (&(globalParams_0->bonds_0)[i_18]);
    float3  d_lin_4;
    float3  d_ang_3;
    static_kinematics_0(i_18, &d_lin_4, &d_ang_3);
    JointBond_0 _S1583 = slang_ldg_0(&_S1582->law_0);
    JointBond_0 _S1584 = _S1583;
    JointState_0 _S1585 = (&(globalParams_0->bond_dyn_0)[i_18])->js_0;
    JointResponse_0 _S1586 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S1583.ids_0.x], &_S1584, &_S1585, d_lin_4, d_ang_3, 0.0f, false);
    return _S1586;
}

static __device__ void gather_loads_0(uint c_29, float3  * fi_2, float3  * mi_3)
{
    float3  _S1587 = make_float3 (0.0f);
    *fi_2 = _S1587;
    *mi_3 = _S1587;
    uint _S1588 = __ldg((&(globalParams_0->index_0)[c_29]));
    uint e_4 = _S1588;
    for(;;)
    {
        uint _S1589 = __ldg((&(globalParams_0->index_0)[c_29 + 1U]));
        if(e_4 < _S1589)
        {
        }
        else
        {
            break;
        }
        uint _S1590 = __ldg((&(globalParams_0->index_0)[e_4]));
        uint bond_0 = _S1590 >> int(1);
        if((_S1590 & 1U) == 0U)
        {
            uint _S1591 = 3U * bond_0;
            float4  _S1592 = *(&(globalParams_0->scratch_0)[_S1591]);
            *fi_2 = *fi_2 + float3 {_S1592.x, _S1592.y, _S1592.z};
            float4  _S1593 = *(&(globalParams_0->scratch_0)[_S1591 + 1U]);
            *mi_3 = *mi_3 + float3 {_S1593.x, _S1593.y, _S1593.z};
        }
        else
        {
            uint _S1594 = 3U * bond_0;
            float4  _S1595 = *(&(globalParams_0->scratch_0)[_S1594]);
            *fi_2 = *fi_2 - float3 {_S1595.x, _S1595.y, _S1595.z};
            float4  _S1596 = *(&(globalParams_0->scratch_0)[_S1594 + 2U]);
            *mi_3 = *mi_3 + float3 {_S1596.x, _S1596.y, _S1596.z};
        }
        e_4 = e_4 + 1U;
    }
    return;
}

static __device__ float bond_load_magnitude2_0(uint c_30)
{
    uint _S1597 = __ldg((&(globalParams_0->index_0)[c_30]));
    uint e_5 = _S1597;
    float m_7 = 0.0f;
    for(;;)
    {
        uint _S1598 = __ldg((&(globalParams_0->index_0)[c_30 + 1U]));
        if(e_5 < _S1598)
        {
        }
        else
        {
            break;
        }
        uint _S1599 = __ldg((&(globalParams_0->index_0)[e_5]));
        uint _S1600 = 3U * (_S1599 >> int(1));
        float4  _S1601 = *(&(globalParams_0->scratch_0)[_S1600]);
        float3  f_18 = float3 {_S1601.x, _S1601.y, _S1601.z};
        float3  t_15;
        if((_S1599 & 1U) == 0U)
        {
            float4  _S1602 = *(&(globalParams_0->scratch_0)[_S1600 + 1U]);
            t_15 = float3 {_S1602.x, _S1602.y, _S1602.z};
        }
        else
        {
            float4  _S1603 = *(&(globalParams_0->scratch_0)[_S1600 + 2U]);
            t_15 = float3 {_S1603.x, _S1603.y, _S1603.z};
        }
        float m_8 = m_7 + (dot_0(f_18, f_18) + dot_0(t_15, t_15));
        e_5 = e_5 + 1U;
        m_7 = m_8;
    }
    return m_7;
}

static __device__ uint fixed_mask_0(uint c_31)
{
    uint4  _S1604 = __ldg(&(&(globalParams_0->chunks_0)[c_31])->info_0);
    uint support_1 = _S1604.x;
    uint _S1605;
    if(support_1 == 1U)
    {
        _S1605 = 63U;
    }
    else
    {
        if(support_1 == 2U)
        {
            _S1605 = 7U;
        }
        else
        {
            _S1605 = 0U;
        }
    }
    return _S1605;
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
    uint _S1606 = __ldg(&globalParams_0->params_0->statics_base_0);
    uint _S1607 = __ldg(&globalParams_0->params_0->chunk_count_0);
    return _S1606 + 23U * _S1607 + 2U * i_19;
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
        bool _S1608;
        if(i_20 < 6U)
        {
            _S1608 = spd_0;
        }
        else
        {
            _S1608 = false;
        }
        if(_S1608)
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
            uint _S1609 = i_20 * 6U;
            uint _S1610 = _S1609 + j_6;
            k_19 = 0U;
            sum_4 = (*a_17)[_S1610];
            for(;;)
            {
                if(k_19 < j_6)
                {
                }
                else
                {
                    break;
                }
                float sum_5 = sum_4 - l_4[_S1609 + k_19] * l_4[j_6 * 6U + k_19];
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
                l_4[_S1609 + i_20] = (F32_sqrt((sum_4)));
            }
            else
            {
                l_4[_S1610] = sum_4 / l_4[j_6 * 6U + j_6];
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
            uint _S1611 = k_19 * 6U + k_19;
            float _S1612 = (*a_17)[_S1611];
            if(((*a_17)[_S1611]) > 0.0f)
            {
                sum_4 = 1.0f / _S1612;
            }
            else
            {
                sum_4 = 0.0f;
            }
            inv_0[_S1611] = sum_4;
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
                float s_8 = sum_4;
                for(;;)
                {
                    if(k_19 < i_20)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_9 = s_8 - l_4[i_20 * 6U + k_19] * y_6[k_19];
                    k_19 = k_19 + 1U;
                    s_8 = s_9;
                }
                y_6[i_20] = s_8 / l_4[i_20 * 6U + i_20];
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
                    float s_10 = sum_4 - l_4[k_19 * 6U + i_21] * x_21[k_19];
                    k_19 = k_19 + 1U;
                    sum_4 = s_10;
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
        uint _S1613 = 4U * j_6;
        *(&(globalParams_0->scratch_0)[sv_0(c_32, 12U + j_6)]) = make_float4 (inv_0[_S1613], inv_0[_S1613 + 1U], inv_0[_S1613 + 2U], inv_0[_S1613 + 3U]);
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
    uint _S1614 = __ldg((&(globalParams_0->index_0)[c_33]));
    uint e_6 = _S1614;
    for(;;)
    {
        uint _S1615 = __ldg((&(globalParams_0->index_0)[c_33 + 1U]));
        if(e_6 < _S1615)
        {
        }
        else
        {
            break;
        }
        uint _S1616 = __ldg((&(globalParams_0->index_0)[e_6]));
        uint i_23 = _S1616 >> int(1);
        bool _S1617 = (_S1616 & 1U) != 0U;
        BondStatic_0 * _S1618 = (&(globalParams_0->bonds_0)[i_23]);
        uint _S1619 = statics_bond_slot_0(i_23);
        float4  _S1620 = *(&(globalParams_0->scratch_0)[_S1619]);
        float4  _S1621 = *(&(globalParams_0->scratch_0)[_S1619 + 1U]);
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
            uint _S1622 = p_14 % 3U;
            float3  t_16;
            if(_S1622 == 0U)
            {
                float4  _S1623 = __ldg(&_S1618->t1_0);
                t_16 = float3 {_S1623.x, _S1623.y, _S1623.z};
            }
            else
            {
                if(_S1622 == 1U)
                {
                    float4  _S1624 = __ldg(&_S1618->t2_0);
                    t_16 = float3 {_S1624.x, _S1624.y, _S1624.z};
                }
                else
                {
                    float4  _S1625 = __ldg(&_S1618->normal_0);
                    t_16 = float3 {_S1625.x, _S1625.y, _S1625.z};
                }
            }
            bool _S1626 = p_14 < 3U;
            float3  row_u_0;
            float3  row_t_0;
            if(_S1626)
            {
                if(_S1617)
                {
                    row_u_0 = t_16;
                }
                else
                {
                    row_u_0 = - t_16;
                }
                if(_S1617)
                {
                    float4  _S1627 = __ldg(&_S1618->rb_0);
                    row_t_0 = cross_0(float3 {_S1627.x, _S1627.y, _S1627.z}, t_16);
                }
                else
                {
                    float4  _S1628 = __ldg(&_S1618->ra_0);
                    row_t_0 = - cross_0(float3 {_S1628.x, _S1628.y, _S1628.z}, t_16);
                }
            }
            else
            {
                float3  _S1629 = make_float3 (0.0f);
                if(_S1617)
                {
                    row_u_0 = t_16;
                }
                else
                {
                    row_u_0 = - t_16;
                }
                float3  _S1630 = row_u_0;
                row_u_0 = _S1629;
                row_t_0 = _S1630;
            }
            float kp_0;
            if(_S1626)
            {
                kp_0 = _slang_vector_get_element(_S1620, p_14);
            }
            else
            {
                kp_0 = _slang_vector_get_element(_S1621, p_14 - 3U);
            }
            if(kp_0 == 0.0f)
            {
                p_14 = p_14 + 1U;
                continue;
            }
            FixedArray<float, 6>  _S1631 = { {
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
                    a_18[r_11 * 6U + q_13] = a_18[r_11 * 6U + q_13] + kp_0 * _S1631[r_11] * _S1631[q_13];
                    q_13 = q_13 + 1U;
                }
                r_11 = r_11 + 1U;
            }
            p_14 = p_14 + 1U;
        }
        e_6 = e_6 + 1U;
    }
    uint _S1632 = fixed_mask_0(c_33);
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
        if((_S1632 & (1U << p_14)) != 0U)
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
    FixedArray<float, 36>  _S1633 = a_18;
    store_inverse_0(c_33, &_S1633);
    return;
}

static __device__ float block_get_0(uint c_34, uint i_24, uint j_7)
{
    uint k_21 = i_24 * 6U + j_7;
    return *_slang_vector_get_element_ptr((&(globalParams_0->scratch_0)[sv_0(c_34, 12U + k_21 / 4U)]), k_21 % 4U);
}

static __device__ void precondition_0(uint c_35)
{
    float4  * _S1634 = (&(globalParams_0->scratch_0)[sv_0(c_35, 4U)]);
    float4  * _S1635 = (&(globalParams_0->scratch_0)[sv_0(c_35, 5U)]);
    FixedArray<float, 6>  _S1636 = { {
        (*_S1634).x, (*_S1634).y, (*_S1634).z, (*_S1635).x, (*_S1635).y, (*_S1635).z
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
            float s_12 = s_11 + block_get_0(c_35, i_25, j_8) * _S1636[j_8];
            j_8 = j_8 + 1U;
            s_11 = s_12;
        }
        z_1[i_25] = s_11;
        i_25 = i_25 + 1U;
    }
    *(&(globalParams_0->scratch_0)[sv_0(c_35, 6U)]) = make_float4 (z_1[int(0)], z_1[int(1)], z_1[int(2)], 0.0f);
    *(&(globalParams_0->scratch_0)[sv_0(c_35, 7U)]) = make_float4 (z_1[int(3)], z_1[int(4)], z_1[int(5)], 0.0f);
    return;
}

static __device__ void project_displacement_slot_0(uint tid_17, Island_0 * isl_20, uint slot_4, uint _S1637)
{
    uint _S1638;
    uint _S1639;
    float3  _S1640 = make_float3 (0.0f);
    float3  p_15 = _S1640;
    float3  l_5 = _S1640;
    uint4  _S1641 = isl_20->range_0;
    uint _S1642 = isl_20->range_0.x + tid_17;
    uint c_36 = _S1642;
    uint _S1643 = _S1637;
    for(;;)
    {
        uint _S1644 = _S1641.y;
        _S1638 = _S1644;
        bool _S1645 = c_36 < _S1644;
        uint _S1646 = __ballot_sync(_S1643, _S1645);
        if(_S1645)
        {
            uint _S1647 = __ballot_sync(_S1643, true);
        }
        else
        {
            uint _S1648 = __ballot_sync(_S1643, false);
            uint _S1649 = __ballot_sync(_S1643, false);
            uint _S1650 = __ballot_sync(_S1637, true);
            _S1639 = _S1650;
            break;
        }
        ChunkStatic_0 * _S1651 = (&(globalParams_0->chunks_0)[c_36]);
        float4  _S1652 = *(&(globalParams_0->scratch_0)[sv_0(c_36, slot_4)]);
        float3  u_3 = float3 {_S1652.x, _S1652.y, _S1652.z};
        float4  _S1653 = *(&(globalParams_0->scratch_0)[sv_0(c_36, slot_4 + 1U)]);
        float3  th_5 = float3 {_S1653.x, _S1653.y, _S1653.z};
        float4  _S1654 = __ldg(&_S1651->center_0);
        float4  _S1655 = isl_20->com_0;
        float3  r_12 = float3 {_S1654.x, _S1654.y, _S1654.z} - float3 {_S1655.x, _S1655.y, _S1655.z};
        float _S1656 = _S1654.w;
        p_15 = p_15 + u_3 * make_float3 (_S1656);
        float3  _S1657 = cross_0(r_12, u_3) * make_float3 (_S1656);
        float4  _S1658 = __ldg(&_S1651->inertia0_0);
        float4  _S1659 = __ldg(&_S1651->inertia1_0);
        float4  _S1660 = __ldg(&_S1651->inertia2_0);
        l_5 = l_5 + (_S1657 + rows_mul_0(_S1658, _S1659, _S1660, th_5));
        uint _S1661 = __ballot_sync(_S1643, true);
        c_36 = c_36 + 256U;
        _S1643 = _S1661;
    }
    group_sum3_0(tid_17, &p_15, &l_5, _S1639);
    float4  _S1662 = isl_20->com_0;
    float3  _S1663 = p_15 / make_float3 (isl_20->com_0.w);
    float3  _S1664 = rows_mul_0(isl_20->inv0_1, isl_20->inv1_1, isl_20->inv2_1, l_5);
    c_36 = _S1642;
    for(;;)
    {
        if(c_36 < _S1638)
        {
        }
        else
        {
            break;
        }
        float4  _S1665 = __ldg(&(&(globalParams_0->chunks_0)[c_36])->center_0);
        uint _S1666 = sv_0(c_36, slot_4);
        float4  _S1667 = *(&(globalParams_0->scratch_0)[_S1666]);
        *(&(globalParams_0->scratch_0)[_S1666]) = make_float4 ((float3 {_S1667.x, _S1667.y, _S1667.z} - _S1663 - cross_0(_S1664, float3 {_S1665.x, _S1665.y, _S1665.z} - float3 {_S1662.x, _S1662.y, _S1662.z})).x, (float3 {_S1667.x, _S1667.y, _S1667.z} - _S1663 - cross_0(_S1664, float3 {_S1665.x, _S1665.y, _S1665.z} - float3 {_S1662.x, _S1662.y, _S1662.z})).y, (float3 {_S1667.x, _S1667.y, _S1667.z} - _S1663 - cross_0(_S1664, float3 {_S1665.x, _S1665.y, _S1665.z} - float3 {_S1662.x, _S1662.y, _S1662.z})).z, 0.0f);
        uint _S1668 = sv_0(c_36, slot_4 + 1U);
        float4  _S1669 = *(&(globalParams_0->scratch_0)[_S1668]);
        *(&(globalParams_0->scratch_0)[_S1668]) = make_float4 ((float3 {_S1669.x, _S1669.y, _S1669.z} - _S1664).x, (float3 {_S1669.x, _S1669.y, _S1669.z} - _S1664).y, (float3 {_S1669.x, _S1669.y, _S1669.z} - _S1664).z, 0.0f);
        c_36 = c_36 + 256U;
    }
    __syncthreads();
    return;
}

static __device__ uint statics_result_slot_0(uint island_3)
{
    uint _S1670 = __ldg(&globalParams_0->params_0->statics_base_0);
    uint _S1671 = __ldg(&globalParams_0->params_0->chunk_count_0);
    uint _S1672 = _S1670 + 23U * _S1671;
    uint _S1673 = __ldg(&globalParams_0->params_0->statics_bonds_0);
    return _S1672 + 2U * _S1673 + island_3;
}

static __device__ void write_bond_loads_0(uint _S1674, uint _S1675, float3  _S1676, float3  _S1677, float _S1678)
{
    BondStatic_0 * _S1679 = (&(globalParams_0->bonds_0)[_S1675]);
    float3  _S1680 = to_body_0(_S1675, _S1676);
    float3  _S1681 = to_body_0(_S1675, _S1677);
    uint _S1682 = 3U * _S1674;
    *(&(globalParams_0->scratch_0)[_S1682]) = make_float4 (_S1680.x, _S1680.y, _S1680.z, _S1678);
    float4  * _S1683 = (&(globalParams_0->scratch_0)[_S1682 + 1U]);
    float4  _S1684 = __ldg(&_S1679->ra_0);
    *_S1683 = make_float4 ((_S1681 + cross_0(float3 {_S1684.x, _S1684.y, _S1684.z}, _S1680)).x, (_S1681 + cross_0(float3 {_S1684.x, _S1684.y, _S1684.z}, _S1680)).y, (_S1681 + cross_0(float3 {_S1684.x, _S1684.y, _S1684.z}, _S1680)).z, 0.0f);
    float4  * _S1685 = (&(globalParams_0->scratch_0)[_S1682 + 2U]);
    float3  _S1686 = - _S1681;
    float4  _S1687 = __ldg(&_S1679->rb_0);
    *_S1685 = make_float4 ((_S1686 + cross_0(float3 {_S1687.x, _S1687.y, _S1687.z}, - _S1680)).x, (_S1686 + cross_0(float3 {_S1687.x, _S1687.y, _S1687.z}, - _S1680)).y, (_S1686 + cross_0(float3 {_S1687.x, _S1687.y, _S1687.z}, - _S1680)).z, 0.0f);
    return;
}

static __device__ void bond_kinematics_0(uint _S1688, float3  _S1689, float3  _S1690, float3  _S1691, float3  _S1692, float3  * _S1693, float3  * _S1694)
{
    BondStatic_0 * _S1695 = (&(globalParams_0->bonds_0)[_S1688]);
    float4  _S1696 = __ldg(&_S1695->rb_0);
    float3  _S1697 = _S1691 + cross_0(_S1692, float3 {_S1696.x, _S1696.y, _S1696.z});
    float4  _S1698 = __ldg(&_S1695->ra_0);
    float3  _S1699 = to_local_0(_S1688, _S1697 - (_S1689 + cross_0(_S1690, float3 {_S1698.x, _S1698.y, _S1698.z})));
    *_S1693 = _S1699;
    float3  _S1700 = to_local_0(_S1688, _S1692 - _S1690);
    *_S1694 = _S1700;
    return;
}

extern "C" __global__ void island_statics()
{
    uint _S1701 = 0U;
    uint _S1702;
    uint i_26;
    uint c_37;
    bool converged_0;
    uint _S1703;
    uint _S1704;
    uint _S1705;
    uint _S1706;
    uint _S1707;
    uint _S1708;
    uint i_27;
    uint _S1709;
    uint _S1710;
    uint _S1711;
    uint _S1712;
    uint _S1713;
    uint _S1714 = __ballot_sync(4294967295U, true);
    uint tid_18 = threadIdx.x;
    uint _S1715 = blockIdx.x;
    Island_0 * _S1716 = (&(globalParams_0->islands_0)[_S1715]);
    Island_0 isl_21 = *_S1716;
    uint _S1717 = (*_S1716).info_1.z;
    bool _S1718 = (_S1717 & 8U) == 0U;
    uint _S1719 = __ballot_sync(_S1714, _S1718);
    if(_S1718)
    {
        return;
    }
    else
    {
        uint _S1720 = __ballot_sync(_S1714, true);
        _S1701 = _S1720;
    }
    bool free_0 = ((isl_21.info_1.x) & 1U) == 0U;
    uint c0_1 = isl_21.range_0.x;
    uint c1_1 = isl_21.range_0.y;
    uint b0_0 = isl_21.range_0.z;
    uint _S1721 = isl_21.range_0.w;
    uint _S1722 = c0_1 + tid_18;
    uint c_38 = _S1722;
    uint newton_0;
    newton_0 = _S1701;
    for(;;)
    {
        bool _S1723 = c_38 < c1_1;
        uint _S1724 = __ballot_sync(newton_0, _S1723);
        if(_S1723)
        {
            uint _S1725 = __ballot_sync(newton_0, true);
        }
        else
        {
            uint _S1726 = __ballot_sync(newton_0, false);
            uint _S1727 = __ballot_sync(newton_0, false);
            uint _S1728 = __ballot_sync(_S1701, true);
            _S1702 = _S1728;
            break;
        }
        float4  _S1729 = make_float4 (0.0f);
        *(&(globalParams_0->scratch_0)[sv_0(c_38, 21U)]) = _S1729;
        *(&(globalParams_0->scratch_0)[sv_0(c_38, 22U)]) = _S1729;
        uint _S1730 = __ballot_sync(newton_0, true);
        c_38 = c_38 + 256U;
        newton_0 = _S1730;
    }
    __syncthreads();
    uint _S1731 = __ballot_sync(_S1702, free_0);
    if(free_0)
    {
        Island_0 _S1732 = isl_21;
        project_load_slot_0(tid_18, &_S1732, 0U, _S1731);
        uint _S1733 = __ballot_sync(_S1702, true);
        c_38 = _S1733;
    }
    else
    {
        uint _S1734 = __ballot_sync(_S1702, true);
        c_38 = _S1734;
    }
    float _S1735 = island_dot_0(tid_18, c0_1, c1_1, 0U, 0U, c_38);
    float _S1736 = (F32_max(((F32_sqrt((_S1735)))), (1.00000000317107685e-30f)));
    float _S1737 = __ldg(&globalParams_0->params_0->statics_tol_0);
    uint _S1738 = __ldg(&globalParams_0->params_0->statics_cg_0);
    uint _S1739 = (U32_min((_S1738), (20U * (c1_1 - c0_1) * 6U + 200U)));
    float previous_2 = 1.00000001504746622e+30f;
    float residual_0 = 0.0f;
    newton_0 = 0U;
    uint cg_total_0 = 0U;
    for(;;)
    {
        uint _S1740 = 0U;
        uint _S1741 = __ldg(&globalParams_0->params_0->statics_newton_0);
        bool _S1742 = newton_0 < _S1741;
        uint _S1743 = __ballot_sync(c_38, _S1742);
        if(_S1742)
        {
            uint _S1744 = __ballot_sync(c_38, true);
            _S1740 = _S1744;
        }
        else
        {
            converged_0 = false;
            break;
        }
        uint _S1745 = b0_0 + tid_18;
        i_26 = _S1745;
        uint _S1746;
        _S1746 = _S1740;
        for(;;)
        {
            bool _S1747 = i_26 < _S1721;
            uint _S1748 = __ballot_sync(_S1746, _S1747);
            if(_S1747)
            {
                uint _S1749 = __ballot_sync(_S1746, true);
            }
            else
            {
                uint _S1750 = __ballot_sync(_S1746, false);
                uint _S1751 = __ballot_sync(_S1746, false);
                uint _S1752 = __ballot_sync(_S1740, true);
                _S1703 = _S1752;
                break;
            }
            JointResponse_0 resp_1 = static_response_0(i_26);
            write_bond_loads_0(i_26, i_26, resp_1.force_lin_1, resp_1.force_ang_1, 0.0f);
            uint _S1753 = __ballot_sync(_S1746, true);
            i_26 = i_26 + 256U;
            _S1746 = _S1753;
        }
        __syncthreads();
        float4  _S1754 = make_float4 (0.0f);
        float4  magnitude_0 = _S1754;
        float4  unused_m_0 = _S1754;
        uint c_39 = _S1722;
        uint _S1755 = _S1703;
        for(;;)
        {
            bool _S1756 = c_39 < c1_1;
            uint _S1757 = __ballot_sync(_S1755, _S1756);
            if(_S1756)
            {
                uint _S1758 = __ballot_sync(_S1755, true);
            }
            else
            {
                uint _S1759 = __ballot_sync(_S1755, false);
                uint _S1760 = __ballot_sync(_S1755, false);
                uint _S1761 = __ballot_sync(_S1703, true);
                _S1704 = _S1761;
                break;
            }
            float3  fi_3;
            float3  mi_4;
            gather_loads_0(c_39, &fi_3, &mi_4);
            *&((&magnitude_0)->x) = *&((&magnitude_0)->x) + bond_load_magnitude2_0(c_39);
            float4  _S1762 = *(&(globalParams_0->scratch_0)[sv_0(c_39, 0U)]);
            float4  r_lin_0 = make_float4 ((float3 {_S1762.x, _S1762.y, _S1762.z} + fi_3).x, (float3 {_S1762.x, _S1762.y, _S1762.z} + fi_3).y, (float3 {_S1762.x, _S1762.y, _S1762.z} + fi_3).z, 0.0f);
            float4  _S1763 = *(&(globalParams_0->scratch_0)[sv_0(c_39, 1U)]);
            float4  r_ang_0 = make_float4 ((float3 {_S1763.x, _S1763.y, _S1763.z} + mi_4).x, (float3 {_S1763.x, _S1763.y, _S1763.z} + mi_4).y, (float3 {_S1763.x, _S1763.y, _S1763.z} + mi_4).z, 0.0f);
            hold_0(fixed_mask_0(c_39), &r_lin_0, &r_ang_0, _S1754, _S1754);
            *(&(globalParams_0->scratch_0)[sv_0(c_39, 4U)]) = r_lin_0;
            *(&(globalParams_0->scratch_0)[sv_0(c_39, 5U)]) = r_ang_0;
            uint _S1764 = __ballot_sync(_S1755, true);
            c_39 = c_39 + 256U;
            _S1755 = _S1764;
        }
        __syncthreads();
        group_sum2_0(tid_18, &magnitude_0, &unused_m_0, _S1704);
        uint _S1765 = __ballot_sync(_S1704, free_0);
        uint _S1766;
        if(free_0)
        {
            Island_0 _S1767 = isl_21;
            project_load_slot_0(tid_18, &_S1767, 4U, _S1765);
            uint _S1768 = __ballot_sync(_S1704, true);
            _S1766 = _S1768;
        }
        else
        {
            uint _S1769 = __ballot_sync(_S1704, true);
            _S1766 = _S1769;
        }
        float _S1770 = island_dot_0(tid_18, c0_1, c1_1, 4U, 4U, _S1766);
        float residual_1 = (F32_sqrt((_S1770))) / _S1736;
        float _S1771 = (F32_max((0.00100000004749745f), (3.83999986297567375e-06f * (F32_sqrt((magnitude_0.x))) / _S1736)));
        bool _S1772 = residual_1 <= _S1737;
        uint _S1773 = __ballot_sync(_S1766, _S1772);
        uint _S1774;
        if(_S1772)
        {
            uint _S1775 = __ballot_sync(_S1766, true);
            converged_0 = true;
            _S1774 = _S1775;
        }
        else
        {
            uint _S1776 = _S1766 & (~_S1773);
            bool _S1777 = residual_1 <= _S1771;
            uint _S1778 = __ballot_sync(_S1776, _S1777);
            if(_S1777)
            {
                bool _S1779 = residual_1 > (0.5f * previous_2);
                uint _S1780 = __ballot_sync(_S1776, true);
                converged_0 = _S1779;
            }
            else
            {
                uint _S1781 = __ballot_sync(_S1776, true);
                converged_0 = false;
            }
            uint _S1782 = __ballot_sync(_S1766, true);
            _S1774 = _S1782;
        }
        uint _S1783 = 0U;
        uint _S1784 = __ballot_sync(_S1774, converged_0);
        if(converged_0)
        {
            residual_0 = residual_1;
            converged_0 = true;
            break;
        }
        else
        {
            uint _S1785 = __ballot_sync(_S1774, true);
            _S1783 = _S1785;
        }
        uint i_28 = _S1745;
        uint _S1786;
        _S1786 = _S1783;
        for(;;)
        {
            bool _S1787 = i_28 < _S1721;
            uint _S1788 = __ballot_sync(_S1786, _S1787);
            if(_S1787)
            {
                uint _S1789 = __ballot_sync(_S1786, true);
            }
            else
            {
                uint _S1790 = __ballot_sync(_S1786, false);
                uint _S1791 = __ballot_sync(_S1786, false);
                uint _S1792 = __ballot_sync(_S1783, true);
                _S1705 = _S1792;
                break;
            }
            BondStatic_0 * _S1793 = (&(globalParams_0->bonds_0)[i_28]);
            float3  d_lin_5;
            float3  d_ang_4;
            static_kinematics_0(i_28, &d_lin_5, &d_ang_4);
            JointBond_0 _S1794 = slang_ldg_0(&_S1793->law_0);
            JointBond_0 _S1795 = _S1794;
            JointState_0 _S1796 = (&(globalParams_0->bond_dyn_0)[i_28])->js_0;
            float3  f_lin_2;
            float3  f_ang_2;
            secant_factors_0(&_S1795, &_S1796, d_lin_5, &f_lin_2, &f_ang_2);
            uint _S1797 = statics_bond_slot_0(i_28);
            float _S1798 = _S1794.stiff0_0.y;
            *(&(globalParams_0->scratch_0)[_S1797]) = make_float4 (_S1798 * f_lin_2.x, _S1798 * f_lin_2.y, _S1794.stiff0_0.x * f_lin_2.z, 0.0f);
            *(&(globalParams_0->scratch_0)[_S1797 + 1U]) = make_float4 (_S1794.stiff0_0.z * f_ang_2.x, _S1794.stiff0_0.w * f_ang_2.y, _S1794.stiff1_0.x * f_ang_2.z, 0.0f);
            uint _S1799 = __ballot_sync(_S1786, true);
            i_28 = i_28 + 256U;
            _S1786 = _S1799;
        }
        __syncthreads();
        uint c_40 = _S1722;
        uint _S1800 = _S1705;
        for(;;)
        {
            bool _S1801 = c_40 < c1_1;
            uint _S1802 = __ballot_sync(_S1800, _S1801);
            if(_S1801)
            {
                uint _S1803 = __ballot_sync(_S1800, true);
            }
            else
            {
                uint _S1804 = __ballot_sync(_S1800, false);
                uint _S1805 = __ballot_sync(_S1800, false);
                uint _S1806 = __ballot_sync(_S1705, true);
                _S1706 = _S1806;
                break;
            }
            assemble_block_0(c_40);
            *(&(globalParams_0->scratch_0)[sv_0(c_40, 2U)]) = _S1754;
            *(&(globalParams_0->scratch_0)[sv_0(c_40, 3U)]) = _S1754;
            uint _S1807 = __ballot_sync(_S1800, true);
            c_40 = c_40 + 256U;
            _S1800 = _S1807;
        }
        __syncthreads();
        uint c_41 = _S1722;
        uint _S1808 = _S1706;
        for(;;)
        {
            bool _S1809 = c_41 < c1_1;
            uint _S1810 = __ballot_sync(_S1808, _S1809);
            if(_S1809)
            {
                uint _S1811 = __ballot_sync(_S1808, true);
            }
            else
            {
                uint _S1812 = __ballot_sync(_S1808, false);
                uint _S1813 = __ballot_sync(_S1808, false);
                uint _S1814 = __ballot_sync(_S1706, true);
                _S1707 = _S1814;
                break;
            }
            precondition_0(c_41);
            uint _S1815 = __ballot_sync(_S1808, true);
            c_41 = c_41 + 256U;
            _S1808 = _S1815;
        }
        __syncthreads();
        uint _S1816 = __ballot_sync(_S1707, free_0);
        uint _S1817;
        if(free_0)
        {
            Island_0 _S1818 = isl_21;
            project_displacement_slot_0(tid_18, &_S1818, 6U, _S1816);
            uint _S1819 = __ballot_sync(_S1707, true);
            _S1817 = _S1819;
        }
        else
        {
            uint _S1820 = __ballot_sync(_S1707, true);
            _S1817 = _S1820;
        }
        uint c_42 = _S1722;
        uint _S1821 = _S1817;
        for(;;)
        {
            bool _S1822 = c_42 < c1_1;
            uint _S1823 = __ballot_sync(_S1821, _S1822);
            if(_S1822)
            {
                uint _S1824 = __ballot_sync(_S1821, true);
            }
            else
            {
                uint _S1825 = __ballot_sync(_S1821, false);
                uint _S1826 = __ballot_sync(_S1821, false);
                uint _S1827 = __ballot_sync(_S1817, true);
                _S1708 = _S1827;
                break;
            }
            *(&(globalParams_0->scratch_0)[sv_0(c_42, 8U)]) = *(&(globalParams_0->scratch_0)[sv_0(c_42, 6U)]);
            *(&(globalParams_0->scratch_0)[sv_0(c_42, 9U)]) = *(&(globalParams_0->scratch_0)[sv_0(c_42, 7U)]);
            uint _S1828 = __ballot_sync(_S1821, true);
            c_42 = c_42 + 256U;
            _S1821 = _S1828;
        }
        __syncthreads();
        float _S1829 = island_dot_0(tid_18, c0_1, c1_1, 4U, 6U, _S1708);
        float _S1830 = island_dot_0(tid_18, c0_1, c1_1, 4U, 4U, _S1708);
        float _S1831 = (F32_sqrt((_S1830)));
        float rz_0 = _S1829;
        uint k_22 = 0U;
        uint cg_total_1 = cg_total_0;
        uint _S1832 = _S1708;
        for(;;)
        {
            bool _S1833 = k_22 < _S1739;
            uint _S1834 = __ballot_sync(_S1832, _S1833);
            uint _S1835;
            bool _S1836;
            if(_S1833)
            {
                bool _S1837 = _S1831 > 0.0f;
                uint _S1838 = __ballot_sync(_S1832, true);
                _S1836 = _S1837;
                _S1835 = _S1838;
            }
            else
            {
                uint _S1839 = __ballot_sync(_S1832, true);
                _S1836 = false;
                _S1835 = _S1839;
            }
            uint _S1840 = 0U;
            uint _S1841 = __ballot_sync(_S1835, _S1836);
            if(_S1836)
            {
                uint _S1842 = __ballot_sync(_S1835, true);
                _S1840 = _S1842;
            }
            else
            {
                uint _S1843 = __ballot_sync(_S1835, false);
                uint _S1844 = __ballot_sync(_S1832, false);
                uint _S1845 = __ballot_sync(_S1708, true);
                cg_total_0 = cg_total_1;
                i_27 = _S1845;
                break;
            }
            i_27 = _S1745;
            _S1709 = _S1840;
            for(;;)
            {
                bool _S1846 = i_27 < _S1721;
                uint _S1847 = __ballot_sync(_S1709, _S1846);
                if(_S1846)
                {
                    uint _S1848 = __ballot_sync(_S1709, true);
                }
                else
                {
                    uint _S1849 = __ballot_sync(_S1709, false);
                    uint _S1850 = __ballot_sync(_S1709, false);
                    uint _S1851 = __ballot_sync(_S1840, true);
                    _S1710 = _S1851;
                    break;
                }
                JointBond_0 _S1852 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_27])->law_0);
                uint ca_2 = _S1852.ids_0.y;
                uint cb_2 = _S1852.ids_0.z;
                float4  _S1853 = *(&(globalParams_0->scratch_0)[sv_0(ca_2, 8U)]);
                float4  _S1854 = *(&(globalParams_0->scratch_0)[sv_0(ca_2, 9U)]);
                float4  _S1855 = *(&(globalParams_0->scratch_0)[sv_0(cb_2, 8U)]);
                float4  _S1856 = *(&(globalParams_0->scratch_0)[sv_0(cb_2, 9U)]);
                float3  d_lin_6;
                float3  d_ang_5;
                bond_kinematics_0(i_27, float3 {_S1853.x, _S1853.y, _S1853.z}, float3 {_S1854.x, _S1854.y, _S1854.z}, float3 {_S1855.x, _S1855.y, _S1855.z}, float3 {_S1856.x, _S1856.y, _S1856.z}, &d_lin_6, &d_ang_5);
                uint _S1857 = statics_bond_slot_0(i_27);
                float4  _S1858 = *(&(globalParams_0->scratch_0)[_S1857]);
                float4  _S1859 = *(&(globalParams_0->scratch_0)[_S1857 + 1U]);
                write_bond_loads_0(i_27, i_27, d_lin_6 * float3 {_S1858.x, _S1858.y, _S1858.z}, d_ang_5 * float3 {_S1859.x, _S1859.y, _S1859.z}, 0.0f);
                uint _S1860 = __ballot_sync(_S1709, true);
                i_27 = i_27 + 256U;
                _S1709 = _S1860;
            }
            __syncthreads();
            c_37 = _S1722;
            uint _S1861 = _S1710;
            for(;;)
            {
                bool _S1862 = c_37 < c1_1;
                uint _S1863 = __ballot_sync(_S1861, _S1862);
                if(_S1862)
                {
                    uint _S1864 = __ballot_sync(_S1861, true);
                }
                else
                {
                    uint _S1865 = __ballot_sync(_S1861, false);
                    uint _S1866 = __ballot_sync(_S1861, false);
                    uint _S1867 = __ballot_sync(_S1710, true);
                    _S1711 = _S1867;
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
                uint _S1868 = __ballot_sync(_S1861, true);
                c_37 = c_37 + 256U;
                _S1861 = _S1868;
            }
            uint _S1869 = 0U;
            __syncthreads();
            float _S1870 = island_dot_0(tid_18, c0_1, c1_1, 8U, 10U, _S1711);
            uint _S1871 = cg_total_1 + 1U;
            bool _S1872 = _S1870 <= 0.0f;
            uint _S1873 = __ballot_sync(_S1711, _S1872);
            if(_S1872)
            {
                uint _S1874 = __ballot_sync(_S1711, false);
                uint _S1875 = __ballot_sync(_S1832, false);
                uint _S1876 = __ballot_sync(_S1708, true);
                cg_total_0 = _S1871;
                i_27 = _S1876;
                break;
            }
            else
            {
                uint _S1877 = __ballot_sync(_S1711, true);
                _S1869 = _S1877;
            }
            float _S1878 = rz_0 / _S1870;
            uint c_43 = _S1722;
            uint _S1879;
            _S1879 = _S1869;
            for(;;)
            {
                bool _S1880 = c_43 < c1_1;
                uint _S1881 = __ballot_sync(_S1879, _S1880);
                if(_S1880)
                {
                    uint _S1882 = __ballot_sync(_S1879, true);
                }
                else
                {
                    uint _S1883 = __ballot_sync(_S1879, false);
                    uint _S1884 = __ballot_sync(_S1879, false);
                    uint _S1885 = __ballot_sync(_S1869, true);
                    _S1712 = _S1885;
                    break;
                }
                uint _S1886 = sv_0(c_43, 2U);
                float4  _S1887 = *(&(globalParams_0->scratch_0)[_S1886]);
                float4  _S1888 = *(&(globalParams_0->scratch_0)[sv_0(c_43, 8U)]);
                *(&(globalParams_0->scratch_0)[_S1886]) = make_float4 ((float3 {_S1887.x, _S1887.y, _S1887.z} + make_float3 (_S1878) * float3 {_S1888.x, _S1888.y, _S1888.z}).x, (float3 {_S1887.x, _S1887.y, _S1887.z} + make_float3 (_S1878) * float3 {_S1888.x, _S1888.y, _S1888.z}).y, (float3 {_S1887.x, _S1887.y, _S1887.z} + make_float3 (_S1878) * float3 {_S1888.x, _S1888.y, _S1888.z}).z, 0.0f);
                uint _S1889 = sv_0(c_43, 3U);
                float4  _S1890 = *(&(globalParams_0->scratch_0)[_S1889]);
                float4  _S1891 = *(&(globalParams_0->scratch_0)[sv_0(c_43, 9U)]);
                *(&(globalParams_0->scratch_0)[_S1889]) = make_float4 ((float3 {_S1890.x, _S1890.y, _S1890.z} + make_float3 (_S1878) * float3 {_S1891.x, _S1891.y, _S1891.z}).x, (float3 {_S1890.x, _S1890.y, _S1890.z} + make_float3 (_S1878) * float3 {_S1891.x, _S1891.y, _S1891.z}).y, (float3 {_S1890.x, _S1890.y, _S1890.z} + make_float3 (_S1878) * float3 {_S1891.x, _S1891.y, _S1891.z}).z, 0.0f);
                uint _S1892 = sv_0(c_43, 4U);
                float4  _S1893 = *(&(globalParams_0->scratch_0)[_S1892]);
                float4  _S1894 = *(&(globalParams_0->scratch_0)[sv_0(c_43, 10U)]);
                *(&(globalParams_0->scratch_0)[_S1892]) = make_float4 ((float3 {_S1893.x, _S1893.y, _S1893.z} - make_float3 (_S1878) * float3 {_S1894.x, _S1894.y, _S1894.z}).x, (float3 {_S1893.x, _S1893.y, _S1893.z} - make_float3 (_S1878) * float3 {_S1894.x, _S1894.y, _S1894.z}).y, (float3 {_S1893.x, _S1893.y, _S1893.z} - make_float3 (_S1878) * float3 {_S1894.x, _S1894.y, _S1894.z}).z, 0.0f);
                uint _S1895 = sv_0(c_43, 5U);
                float4  _S1896 = *(&(globalParams_0->scratch_0)[_S1895]);
                float4  _S1897 = *(&(globalParams_0->scratch_0)[sv_0(c_43, 11U)]);
                *(&(globalParams_0->scratch_0)[_S1895]) = make_float4 ((float3 {_S1896.x, _S1896.y, _S1896.z} - make_float3 (_S1878) * float3 {_S1897.x, _S1897.y, _S1897.z}).x, (float3 {_S1896.x, _S1896.y, _S1896.z} - make_float3 (_S1878) * float3 {_S1897.x, _S1897.y, _S1897.z}).y, (float3 {_S1896.x, _S1896.y, _S1896.z} - make_float3 (_S1878) * float3 {_S1897.x, _S1897.y, _S1897.z}).z, 0.0f);
                uint _S1898 = __ballot_sync(_S1879, true);
                c_43 = c_43 + 256U;
                _S1879 = _S1898;
            }
            uint _S1899 = 0U;
            __syncthreads();
            float _S1900 = island_dot_0(tid_18, c0_1, c1_1, 4U, 4U, _S1712);
            bool _S1901 = (F32_sqrt((_S1900))) <= (0.00009999999747379f * _S1831);
            uint _S1902 = __ballot_sync(_S1712, _S1901);
            if(_S1901)
            {
                uint _S1903 = __ballot_sync(_S1712, false);
                uint _S1904 = __ballot_sync(_S1832, false);
                uint _S1905 = __ballot_sync(_S1708, true);
                cg_total_0 = _S1871;
                i_27 = _S1905;
                break;
            }
            else
            {
                uint _S1906 = __ballot_sync(_S1712, true);
                _S1899 = _S1906;
            }
            uint c_44 = _S1722;
            uint _S1907;
            _S1907 = _S1899;
            for(;;)
            {
                bool _S1908 = c_44 < c1_1;
                uint _S1909 = __ballot_sync(_S1907, _S1908);
                if(_S1908)
                {
                    uint _S1910 = __ballot_sync(_S1907, true);
                }
                else
                {
                    uint _S1911 = __ballot_sync(_S1907, false);
                    uint _S1912 = __ballot_sync(_S1907, false);
                    uint _S1913 = __ballot_sync(_S1899, true);
                    _S1713 = _S1913;
                    break;
                }
                precondition_0(c_44);
                uint _S1914 = __ballot_sync(_S1907, true);
                c_44 = c_44 + 256U;
                _S1907 = _S1914;
            }
            __syncthreads();
            uint _S1915 = __ballot_sync(_S1713, free_0);
            uint _S1916;
            if(free_0)
            {
                Island_0 _S1917 = isl_21;
                project_displacement_slot_0(tid_18, &_S1917, 6U, _S1915);
                uint _S1918 = __ballot_sync(_S1713, true);
                _S1916 = _S1918;
            }
            else
            {
                uint _S1919 = __ballot_sync(_S1713, true);
                _S1916 = _S1919;
            }
            float _S1920 = island_dot_0(tid_18, c0_1, c1_1, 4U, 6U, _S1916);
            float _S1921 = _S1920 / rz_0;
            uint c_45 = _S1722;
            uint _S1922 = _S1916;
            for(;;)
            {
                bool _S1923 = c_45 < c1_1;
                uint _S1924 = __ballot_sync(_S1922, _S1923);
                if(_S1923)
                {
                    uint _S1925 = __ballot_sync(_S1922, true);
                }
                else
                {
                    uint _S1926 = __ballot_sync(_S1922, false);
                    uint _S1927 = __ballot_sync(_S1922, false);
                    uint _S1928 = __ballot_sync(_S1916, true);
                    break;
                }
                uint _S1929 = sv_0(c_45, 8U);
                float4  _S1930 = *(&(globalParams_0->scratch_0)[sv_0(c_45, 6U)]);
                float4  _S1931 = *(&(globalParams_0->scratch_0)[_S1929]);
                *(&(globalParams_0->scratch_0)[_S1929]) = make_float4 ((float3 {_S1930.x, _S1930.y, _S1930.z} + make_float3 (_S1921) * float3 {_S1931.x, _S1931.y, _S1931.z}).x, (float3 {_S1930.x, _S1930.y, _S1930.z} + make_float3 (_S1921) * float3 {_S1931.x, _S1931.y, _S1931.z}).y, (float3 {_S1930.x, _S1930.y, _S1930.z} + make_float3 (_S1921) * float3 {_S1931.x, _S1931.y, _S1931.z}).z, 0.0f);
                uint _S1932 = sv_0(c_45, 9U);
                float4  _S1933 = *(&(globalParams_0->scratch_0)[sv_0(c_45, 7U)]);
                float4  _S1934 = *(&(globalParams_0->scratch_0)[_S1932]);
                *(&(globalParams_0->scratch_0)[_S1932]) = make_float4 ((float3 {_S1933.x, _S1933.y, _S1933.z} + make_float3 (_S1921) * float3 {_S1934.x, _S1934.y, _S1934.z}).x, (float3 {_S1933.x, _S1933.y, _S1933.z} + make_float3 (_S1921) * float3 {_S1934.x, _S1934.y, _S1934.z}).y, (float3 {_S1933.x, _S1933.y, _S1933.z} + make_float3 (_S1921) * float3 {_S1934.x, _S1934.y, _S1934.z}).z, 0.0f);
                uint _S1935 = __ballot_sync(_S1922, true);
                c_45 = c_45 + 256U;
                _S1922 = _S1935;
            }
            __syncthreads();
            uint _S1936 = __ballot_sync(_S1832, true);
            uint _S1937 = k_22 + 1U;
            rz_0 = _S1920;
            k_22 = _S1937;
            cg_total_1 = _S1871;
            _S1832 = _S1936;
        }
        c_37 = _S1722;
        _S1709 = i_27;
        for(;;)
        {
            bool _S1938 = c_37 < c1_1;
            uint _S1939 = __ballot_sync(_S1709, _S1938);
            if(_S1938)
            {
                uint _S1940 = __ballot_sync(_S1709, true);
            }
            else
            {
                uint _S1941 = __ballot_sync(_S1709, false);
                uint _S1942 = __ballot_sync(_S1709, false);
                uint _S1943 = __ballot_sync(i_27, true);
                break;
            }
            uint _S1944 = 4U * c_37;
            float4  _S1945 = *(&(globalParams_0->state_0)[_S1944]);
            float3  u_4 = float3 {_S1945.x, _S1945.y, _S1945.z};
            uint _S1946 = sv_0(c_37, 21U);
            float4  _S1947 = *(&(globalParams_0->scratch_0)[_S1946]);
            float3  u_lo_0 = float3 {_S1947.x, _S1947.y, _S1947.z};
            uint _S1948 = _S1944 + 1U;
            float4  _S1949 = *(&(globalParams_0->state_0)[_S1948]);
            float3  th_6 = float3 {_S1949.x, _S1949.y, _S1949.z};
            uint _S1950 = sv_0(c_37, 22U);
            float4  _S1951 = *(&(globalParams_0->scratch_0)[_S1950]);
            float3  th_lo_0 = float3 {_S1951.x, _S1951.y, _S1951.z};
            float4  _S1952 = *(&(globalParams_0->scratch_0)[sv_0(c_37, 2U)]);
            comp_add_0(&u_4, &u_lo_0, float3 {_S1952.x, _S1952.y, _S1952.z});
            float4  _S1953 = *(&(globalParams_0->scratch_0)[sv_0(c_37, 3U)]);
            comp_add_0(&th_6, &th_lo_0, float3 {_S1953.x, _S1953.y, _S1953.z});
            *(&(globalParams_0->state_0)[_S1944]) = make_float4 (u_4.x, u_4.y, u_4.z, (*(&(globalParams_0->state_0)[_S1944])).w);
            *(&(globalParams_0->state_0)[_S1948]) = make_float4 (th_6.x, th_6.y, th_6.z, (*(&(globalParams_0->state_0)[_S1948])).w);
            *(&(globalParams_0->scratch_0)[_S1946]) = make_float4 (u_lo_0.x, u_lo_0.y, u_lo_0.z, 0.0f);
            *(&(globalParams_0->scratch_0)[_S1950]) = make_float4 (th_lo_0.x, th_lo_0.y, th_lo_0.z, 0.0f);
            uint _S1954 = __ballot_sync(_S1709, true);
            c_37 = c_37 + 256U;
            _S1709 = _S1954;
        }
        __syncthreads();
        uint _S1955 = newton_0 + 1U;
        uint _S1956 = __ballot_sync(c_38, true);
        previous_2 = residual_1;
        residual_0 = residual_1;
        newton_0 = _S1955;
        c_38 = _S1956;
    }
    i_26 = b0_0 + tid_18;
    for(;;)
    {
        if(i_26 < _S1721)
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
    c_37 = _S1722;
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
            float4  _S1957 = *(&(globalParams_0->scratch_0)[sv_0(c_37, 0U)]);
            reaction_1 = - (float3 {_S1957.x, _S1957.y, _S1957.z} + fi_5);
        }
        else
        {
            uint _S1958 = 4U * c_37;
            reaction_1 = make_float3 ((*(&(globalParams_0->state_0)[_S1958 + 1U])).w, (*(&(globalParams_0->state_0)[_S1958 + 2U])).w, (*(&(globalParams_0->state_0)[_S1958 + 3U])).w);
        }
        uint _S1959 = 4U * c_37;
        uint _S1960 = _S1959 + 1U;
        float4  _S1961 = *(&(globalParams_0->state_0)[_S1960]);
        *(&(globalParams_0->state_0)[_S1960]) = make_float4 (float3 {_S1961.x, _S1961.y, _S1961.z}.x, float3 {_S1961.x, _S1961.y, _S1961.z}.y, float3 {_S1961.x, _S1961.y, _S1961.z}.z, reaction_1.x);
        *(&(globalParams_0->state_0)[_S1959 + 2U]) = make_float4 (0.0f, 0.0f, 0.0f, reaction_1.y);
        *(&(globalParams_0->state_0)[_S1959 + 3U]) = make_float4 (0.0f, 0.0f, 0.0f, reaction_1.z);
        c_37 = c_37 + 256U;
    }
    if(tid_18 == 0U)
    {
        float4  * _S1962 = (&(globalParams_0->scratch_0)[statics_result_slot_0(_S1715)]);
        float _S1963 = (U32_asfloat((newton_0)));
        float _S1964 = (U32_asfloat((cg_total_0)));
        if(converged_0)
        {
            previous_2 = 1.0f;
        }
        else
        {
            previous_2 = 0.0f;
        }
        *_S1962 = make_float4 (residual_0, _S1963, _S1964, previous_2);
        *&((&(&(globalParams_0->islands_0)[_S1715])->info_1)->z) = _S1717 & 4294967287U;
    }
    return;
}

extern "C" __global__ void settled_fatigue()
{
    uint tid_19 = threadIdx.x;
    uint _S1965 = blockIdx.x;
    Island_0 * _S1966 = (&(globalParams_0->islands_0)[_S1965]);
    Island_0 isl_22 = *_S1966;
    bool _S1967;
    if((((*_S1966).info_1.x) & 16U) == 0U)
    {
        _S1967 = true;
    }
    else
    {
        _S1967 = (isl_22.range_0.w) == (isl_22.range_0.z);
    }
    if(_S1967)
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
    uint _S1968 = isl_22.info_1.w;
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
        BondStatic_0 * _S1969 = (&(globalParams_0->bonds_0)[i_29]);
        BondDyn_0 bd_2 = *(&(globalParams_0->bond_dyn_0)[i_29]);
        JointBond_0 _S1970 = slang_ldg_0(&_S1969->law_0);
        uint _S1971 = 4U * _S1970.ids_0.y;
        float4  _S1972 = *(&(globalParams_0->state_0)[_S1971]);
        float4  _S1973 = *(&(globalParams_0->state_0)[_S1971 + 1U]);
        uint _S1974 = 4U * _S1970.ids_0.z;
        float4  _S1975 = *(&(globalParams_0->state_0)[_S1974]);
        float4  _S1976 = *(&(globalParams_0->state_0)[_S1974 + 1U]);
        float3  d_lin_7;
        float3  d_ang_6;
        bond_kinematics_0(i_29, float3 {_S1972.x, _S1972.y, _S1972.z}, float3 {_S1973.x, _S1973.y, _S1973.z}, float3 {_S1975.x, _S1975.y, _S1975.z}, float3 {_S1976.x, _S1976.y, _S1976.z}, &d_lin_7, &d_ang_6);
        JointState_0 previous_3 = (&bd_2)->js_0;
        float3  _S1977 = d_lin_7;
        float3  _S1978 = d_ang_6;
        float _S1979 = __ldg(&globalParams_0->params_0->dt_0);
        uint _S1980 = __ldg(&globalParams_0->params_0->fracture_0);
        bool _S1981 = _S1980 != 0U;
        JointBond_0 _S1982 = _S1970;
        JointState_0 _S1983 = previous_3;
        JointResponse_0 _S1984 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S1970.ids_0.x], &_S1982, &_S1983, _S1977, _S1978, _S1979, _S1981);
        if((_S1984.state_1.damage_0) > (previous_3.damage_0 + 9.99999971718068537e-10f))
        {
            _S1967 = true;
        }
        else
        {
            _S1967 = (_S1984.state_1.crush_0) > (previous_3.crush_0 + 9.99999971718068537e-10f);
        }
        uint flags_3;
        if(_S1967)
        {
            flags_3 = 16U;
        }
        else
        {
            flags_3 = 0U;
        }
        comp_add1_0(&((&(&bd_2)->sums_0)->x), &((&(&bd_2)->comps_0)->x), _S1984.dissipated_2);
        comp_add1_0(&((&(&bd_2)->sums_0)->y), &((&(&bd_2)->comps_0)->y), _S1984.overshoot_0);
        (&bd_2)->force_lin_0 = make_float4 (_S1984.force_lin_1.x, _S1984.force_lin_1.y, _S1984.force_lin_1.z, _S1984.stored_5);
        (&bd_2)->force_ang_0 = make_float4 (_S1984.force_ang_1.x, _S1984.force_ang_1.y, _S1984.force_ang_1.z, (F32_max(((&bd_2)->force_ang_0.w), (_S1984.state_1.utilization_0))));
        JointState_0 _S1985 = previous_3;
        bool _S1986 = is_damaged_0(&_S1985);
        bool _S1987;
        if(!_S1986)
        {
            JointState_0 _S1988 = _S1984.state_1;
            bool _S1989 = is_damaged_0(&_S1988);
            _S1987 = _S1989;
        }
        else
        {
            _S1987 = false;
        }
        bool _S1990;
        if(_S1987)
        {
            _S1990 = ((&bd_2)->events_0.x) == 0U;
        }
        else
        {
            _S1990 = false;
        }
        if(_S1990)
        {
            *&((&(&bd_2)->events_0)->x) = _S1968;
            *&((&(&bd_2)->events_0)->w) = _S1984.state_1.mode_0;
            (*&g_seen_0)[3U] = 1U;
        }
        bool _S1991;
        if(((&bd_2)->events_0.y) == 0U)
        {
            _S1991 = (_S1984.state_1.life_0) != (previous_3.life_0);
        }
        else
        {
            _S1991 = false;
        }
        bool _S1992;
        if(_S1991)
        {
            _S1992 = (_S1984.fatigue_before_0) > 0.99000000953674316f;
        }
        else
        {
            _S1992 = false;
        }
        bool _S1993;
        if(_S1992)
        {
            float _S1994 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S1970.ids_0.x], _S1984.state_1.life_0);
            _S1993 = _S1994 <= 0.99000000953674316f;
        }
        else
        {
            _S1993 = false;
        }
        if(_S1993)
        {
            *&((&(&bd_2)->events_0)->y) = _S1968;
            (*&g_seen_0)[4U] = 1U;
        }
        uint flags_4;
        if(_S1984.disconnected_0)
        {
            *&((&(&bd_2)->events_0)->z) = _S1968;
            flags_4 = flags_3 | 32U;
        }
        else
        {
            flags_4 = flags_3;
        }
        (&bd_2)->js_0 = _S1984.state_1;
        *(&(globalParams_0->bond_dyn_0)[i_29]) = bd_2;
        write_bond_loads_0(i_29, i_29, _S1984.force_lin_1, _S1984.force_ang_1, (F32_max((_S1984.measures_0.tension_0), (_S1984.measures_0.compression_0))));
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
        uint _S1995 = isl_22.info_1.z;
        if((*&g_halt_0) != 0U)
        {
            i_29 = 16U;
        }
        else
        {
            i_29 = 0U;
        }
        uint _S1996 = _S1995 | i_29;
        if((*&g_run_0) != 0U)
        {
            i_29 = 32U;
        }
        else
        {
            i_29 = 0U;
        }
        *&((&(&(globalParams_0->islands_0)[_S1965])->info_1)->z) = _S1996 | i_29;
    }
    uint _S1997 = ((isl_22.coverage_0) | 16384U) | (seen_bits_0());
    if((*&g_run_0) != 0U)
    {
        i_29 = 128U;
    }
    else
    {
        i_29 = 0U;
    }
    (&(globalParams_0->islands_0)[_S1965])->coverage_0 = _S1997 | i_29;
    return;
}

