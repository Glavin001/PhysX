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
    uint pair_lanes_0;
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

static __device__ float WaveActiveSum_1(float expr_1, uint _S12)
{
    float _S13 = (_waveSum((make_uint4 (WaveGetActiveMask_0(_S12), 0U, 0U, 0U)).x, (expr_1)));
    return _S13;
}

static __device__ float3  WaveActiveSum_2(float3  expr_2, uint _S14)
{
    float3  _S15 = (_waveSumMultiple((make_uint4 (WaveGetActiveMask_0(_S14), 0U, 0U, 0U)).x, (expr_2)));
    return _S15;
}

static __device__ uint WaveActiveSum_3(uint expr_3, uint _S16)
{
    uint _S17 = (_waveSum((make_uint4 (WaveGetActiveMask_0(_S16), 0U, 0U, 0U)).x, (expr_3)));
    return _S17;
}

static __device__ float3  cross_0(float3  left_0, float3  right_0)
{
    float _S18 = left_0.y;
    float _S19 = right_0.z;
    float _S20 = left_0.z;
    float _S21 = right_0.y;
    float _S22 = right_0.x;
    float _S23 = left_0.x;
    return make_float3 (_S18 * _S19 - _S20 * _S21, _S20 * _S22 - _S23 * _S19, _S23 * _S21 - _S18 * _S22);
}

static __device__ float length_0(float3  x_10)
{
    return (F32_sqrt((dot_0(x_10, x_10))));
}

static __device__ uint pair_lane_count_0()
{
    uint _S24 = __ldg(&globalParams_0->params_0->pair_lanes_0);
    return (U32_max((_S24), (1U)));
}

static __device__ bool stopped_0()
{
    uint _S25 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint4  _S26 = (&(globalParams_0->islands_0)[_S25])->info_1;
    bool _S27;
    if((((&(globalParams_0->islands_0)[_S25])->info_1.z) & 1U) != 0U)
    {
        _S27 = true;
    }
    else
    {
        _S27 = (_S26.y) != 0U;
    }
    return _S27;
}

static __device__ bool WaveActiveAnyTrue_0(bool condition_0, uint _S28)
{
    bool _S29 = ((__any_sync((WaveGetActiveMask_0(_S28)), (condition_0)) != 0));
    return _S29;
}

static __device__ bool pair_any_0(bool x_11, uint lanes_0, uint _S30)
{
    bool _S31 = lanes_0 > 1U;
    uint _S32 = __ballot_sync(_S30, _S31);
    bool _S33;
    if(_S31)
    {
        bool _S34 = WaveActiveAnyTrue_0(x_11, _S32);
        uint _S35 = __ballot_sync(_S30, true);
        _S33 = _S34;
    }
    else
    {
        _S33 = x_11;
    }
    return _S33;
}

struct Quat_0
{
    float w_1;
    float x_12;
    float y_4;
    float z_0;
};

static __device__ Quat_0 quat_of_0(float4  q_0)
{
    Quat_0 r_0;
    (&r_0)->x_12 = q_0.x;
    (&r_0)->y_4 = q_0.y;
    (&r_0)->z_0 = q_0.z;
    (&r_0)->w_1 = q_0.w;
    return r_0;
}

static __device__ float3  rotate_0(Quat_0 * q_1, float3  v_0)
{
    float3  qv_0 = make_float3 (q_1->x_12, q_1->y_4, q_1->z_0);
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
    ChunkStatic_0 * _S36 = (&(globalParams_0->chunks_0)[c_0]);
    uint4  _S37 = __ldg(&_S36->info_0);
    Island_0 * _S38 = (&(globalParams_0->islands_0)[_S37.y]);
    Quat_0 q_2 = quat_of_0(_S38->rotation_0);
    WorldPoint_0 w_2;
    float4  _S39 = _S38->position_0;
    (&w_2)->hi_0 = float3 {_S39.x, _S39.y, _S39.z};
    float4  _S40 = _S38->position_err_0;
    (&w_2)->lo_0 = float3 {_S40.x, _S40.y, _S40.z};
    float4  _S41 = __ldg(&_S36->center_0);
    float4  _S42 = *(&(globalParams_0->state_0)[4U * c_0]);
    float3  _S43 = float3 {_S41.x, _S41.y, _S41.z} + float3 {_S42.x, _S42.y, _S42.z};
    Quat_0 _S44 = q_2;
    float3  _S45 = rotate_0(&_S44, _S43);
    (&w_2)->rel_0 = _S45;
    return w_2;
}

static __device__ float3  world_diff_0(WorldPoint_0 * a_2, WorldPoint_0 * b_2)
{
    return a_2->hi_0 - b_2->hi_0 + (a_2->lo_0 - b_2->lo_0) + (a_2->rel_0 - b_2->rel_0);
}

static __device__ float3  safe_normalize_0(float3  v_1)
{
    float n_0 = length_0(v_1);
    float3  _S46;
    if(n_0 > 1.00000000317107685e-30f)
    {
        _S46 = v_1 / make_float3 (n_0);
    }
    else
    {
        _S46 = make_float3 (0.0f);
    }
    return _S46;
}

static __device__ Quat_0 from_axis_angle_0(float3  axis_0, float angle_0)
{
    float3  a_3 = safe_normalize_0(axis_0);
    float _S47 = 0.5f * angle_0;
    float s_0 = (F32_sin((_S47)));
    Quat_0 q_3;
    (&q_3)->w_1 = (F32_cos((_S47)));
    (&q_3)->x_12 = a_3.x * s_0;
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
    ChunkStatic_0 * _S48 = (&(globalParams_0->chunks_0)[c_1]);
    uint4  _S49 = __ldg(&_S48->info_0);
    Quat_0 q_4 = quat_of_0((&(globalParams_0->islands_0)[_S49.y])->rotation_0);
    float4  _S50 = *(&(globalParams_0->state_0)[4U * c_1 + 1U]);
    float3  th_0 = float3 {_S50.x, _S50.y, _S50.z};
    Quat_0 hidden_0 = from_axis_angle_0(th_0, length_0(th_0));
    Box_0 b_3;
    (&b_3)->center_1 = center_2;
    float4  _S51 = __ldg(&_S48->crot0_0);
    float _S52 = _S51.x;
    float4  _S53 = __ldg(&_S48->crot1_0);
    float _S54 = _S53.x;
    float4  _S55 = __ldg(&_S48->crot2_0);
    float3  _S56 = make_float3 (_S52, _S54, _S55.x);
    Quat_0 _S57 = hidden_0;
    float3  _S58 = rotate_0(&_S57, _S56);
    Quat_0 _S59 = q_4;
    float3  _S60 = rotate_0(&_S59, _S58);
    (&b_3)->axis0_0 = _S60;
    float3  _S61 = make_float3 (_S51.y, _S53.y, _S55.y);
    Quat_0 _S62 = hidden_0;
    float3  _S63 = rotate_0(&_S62, _S61);
    Quat_0 _S64 = q_4;
    float3  _S65 = rotate_0(&_S64, _S63);
    (&b_3)->axis1_0 = _S65;
    float3  _S66 = make_float3 (_S51.z, _S53.z, _S55.z);
    Quat_0 _S67 = hidden_0;
    float3  _S68 = rotate_0(&_S67, _S66);
    Quat_0 _S69 = q_4;
    float3  _S70 = rotate_0(&_S69, _S68);
    (&b_3)->axis2_0 = _S70;
    float4  _S71 = __ldg(&_S48->half_0);
    (&b_3)->half_2 = float3 {_S71.x, _S71.y, _S71.z};
    float4  _S72 = __ldg(&_S48->cmat_0);
    (&b_3)->hull_at_0 = (F32_asuint((_S72.z)));
    uint _S73 = (F32_asuint((_S72.w)));
    (&b_3)->hull_v_0 = _S73 & 255U;
    (&b_3)->hull_f_0 = _S73 >> int(8);
    return b_3;
}

static __device__ uint sample_count_0(Box_0 * b_4)
{
    uint _S74 = b_4->hull_v_0;
    uint _S75;
    if((b_4->hull_v_0) == 0U)
    {
        _S75 = 14U;
    }
    else
    {
        _S75 = _S74 + b_4->hull_f_0;
    }
    return _S75;
}

static __device__ bool may_overlap_0(Box_0 * a_4, Box_0 * b_5)
{
    float3  _S76 = b_5->center_1 - a_4->center_1;
    float3  _S77 = a_4->half_2;
    float3  _S78 = b_5->half_2;
    float _S79 = 0.00000999999974738f * (length_0(a_4->half_2) + length_0(b_5->half_2));
    float3  _S80 = a_4->axis0_0;
    float3  _S81 = a_4->axis1_0;
    float3  _S82 = a_4->axis2_0;
    float3  _S83 = b_5->axis0_0;
    float3  _S84 = b_5->axis1_0;
    float3  _S85 = b_5->axis2_0;
    FixedArray<float3 , 6>  _S86 = { {
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
            l_0 = _S86[i_6];
        }
        else
        {
            uint _S87 = i_6 - 6U;
            l_0 = cross_0(_S86[_S87 / 3U], _S86[3U + _S87 % 3U]);
        }
        float len_0 = length_0(l_0);
        if(len_0 <= 9.99999997475242708e-07f)
        {
            i_6 = i_6 + 1U;
            continue;
        }
        if((F32_abs((dot_0(_S76, l_0)))) > (_S77.x * (F32_abs((dot_0(_S80, l_0)))) + _S77.y * (F32_abs((dot_0(_S81, l_0)))) + _S77.z * (F32_abs((dot_0(_S82, l_0)))) + (_S78.x * (F32_abs((dot_0(_S83, l_0)))) + _S78.y * (F32_abs((dot_0(_S84, l_0)))) + _S78.z * (F32_abs((dot_0(_S85, l_0))))) + _S79 * len_0))
        {
            return false;
        }
        i_6 = i_6 + 1U;
    }
    return true;
}

static __device__ void chunk_velocity_0(uint c_2, float3  * v_2, float3  * w_3)
{
    ChunkStatic_0 * _S88 = (&(globalParams_0->chunks_0)[c_2]);
    uint4  _S89 = __ldg(&_S88->info_0);
    Island_0 * _S90 = (&(globalParams_0->islands_0)[_S89.y]);
    Quat_0 q_5 = quat_of_0(_S90->rotation_0);
    float4  _S91 = __ldg(&_S88->center_0);
    uint _S92 = 4U * c_2;
    float4  _S93 = *(&(globalParams_0->state_0)[_S92]);
    float4  _S94 = _S90->com_0;
    float3  _S95 = float3 {_S91.x, _S91.y, _S91.z} + float3 {_S93.x, _S93.y, _S93.z} - float3 {_S94.x, _S94.y, _S94.z};
    Quat_0 _S96 = q_5;
    float3  _S97 = rotate_0(&_S96, _S95);
    float4  _S98 = _S90->velocity_0;
    float4  _S99 = _S90->velocity_err_0;
    float4  _S100 = _S90->angular_velocity_0;
    float3  _S101 = float3 {_S100.x, _S100.y, _S100.z};
    float3  _S102 = float3 {_S98.x, _S98.y, _S98.z} + float3 {_S99.x, _S99.y, _S99.z} + cross_0(_S101, _S97);
    float4  _S103 = *(&(globalParams_0->state_0)[_S92 + 2U]);
    float3  _S104 = float3 {_S103.x, _S103.y, _S103.z};
    Quat_0 _S105 = q_5;
    float3  _S106 = rotate_0(&_S105, _S104);
    *v_2 = _S102 + _S106;
    float4  _S107 = *(&(globalParams_0->state_0)[_S92 + 3U]);
    float3  _S108 = float3 {_S107.x, _S107.y, _S107.z};
    Quat_0 _S109 = q_5;
    float3  _S110 = rotate_0(&_S109, _S108);
    *w_3 = _S101 + _S110;
    return;
}

static __device__ float3  box_to_world_0(Box_0 * b_6, float3  local_0)
{
    return b_6->axis0_0 * make_float3 (local_0.x) + b_6->axis1_0 * make_float3 (local_0.y) + b_6->axis2_0 * make_float3 (local_0.z);
}

static __device__ float3  box_axis_0(Box_0 * b_7, uint k_0)
{
    float3  _S111;
    if(k_0 == 0U)
    {
        _S111 = b_7->axis0_0;
    }
    else
    {
        if(k_0 == 1U)
        {
            _S111 = b_7->axis1_0;
        }
        else
        {
            _S111 = b_7->axis2_0;
        }
    }
    return _S111;
}

static __device__ float comp3_0(float3  v_3, uint k_1)
{
    float _S112;
    if(k_1 == 0U)
    {
        _S112 = v_3.x;
    }
    else
    {
        if(k_1 == 1U)
        {
            _S112 = v_3.y;
        }
        else
        {
            _S112 = v_3.z;
        }
    }
    return _S112;
}

static __device__ float3  sample_point_0(Box_0 * b_8, uint i_7)
{
    uint _S113 = b_8->hull_v_0;
    if((b_8->hull_v_0) != 0U)
    {
        float3  local_1;
        if(i_7 < _S113)
        {
            float4  _S114 = __ldg((&(globalParams_0->loads_0)[b_8->hull_at_0 + i_7]));
            local_1 = float3 {_S114.x, _S114.y, _S114.z} * make_float3 (0.89999997615814209f);
        }
        else
        {
            float4  _S115 = __ldg((&(globalParams_0->loads_0)[b_8->hull_at_0 + _S113 + b_8->hull_f_0 + (i_7 - _S113)]));
            local_1 = float3 {_S115.x, _S115.y, _S115.z};
        }
        float3  _S116 = b_8->center_1;
        float3  _S117 = box_to_world_0(b_8, local_1);
        return _S116 + _S117;
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
        float _S118;
        if((i_7 & 2U) == 0U)
        {
            _S118 = - h_0.y;
        }
        else
        {
            _S118 = h_0.y;
        }
        float _S119;
        if((i_7 & 4U) == 0U)
        {
            _S119 = - h_0.z;
        }
        else
        {
            _S119 = h_0.z;
        }
        return b_8->center_1 + b_8->axis0_0 * make_float3 (sign_0) + b_8->axis1_0 * make_float3 (_S118) + b_8->axis2_0 * make_float3 (_S119);
    }
    uint _S120 = i_7 - 8U;
    uint axis_1 = _S120 / 2U;
    if((_S120 % 2U) == 0U)
    {
        sign_0 = -1.0f;
    }
    else
    {
        sign_0 = 1.0f;
    }
    float3  _S121 = b_8->center_1;
    float3  _S122 = box_axis_0(b_8, axis_1);
    return _S121 + _S122 * make_float3 (sign_0 * comp3_0(b_8->half_2, axis_1));
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
        float4  _S123 = __ldg((&(globalParams_0->loads_0)[b_10->hull_at_0 + b_10->hull_v_0 + f_0]));
        float d_0 = dot_0(float3 {_S123.x, _S123.y, _S123.z}, local_2) - _S123.w;
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
    float3  _S124 = b_11->half_2;
    if((dot_0(r_2, r_2)) > (dot_0(b_11->half_2, b_11->half_2) * 1.00001001358032227f))
    {
        return false;
    }
    uint _S125 = b_11->hull_v_0;
    if((b_11->hull_v_0) != 0U)
    {
        float3  _S126 = box_to_local_0(b_11, r_2);
        uint face_1;
        float _S127 = hull_signed_distance_0(b_11, _S126, &face_1);
        if(!(_S127 < 0.0f))
        {
            return false;
        }
        *depth_0 = - _S127;
        float4  _S128 = __ldg((&(globalParams_0->loads_0)[b_11->hull_at_0 + _S125 + face_1]));
        float3  _S129 = box_to_world_0(b_11, float3 {_S128.x, _S128.y, _S128.z});
        *normal_1 = _S129;
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
        float3  _S130 = box_axis_0(b_11, k_2);
        float local_3 = dot_0(r_2, _S130);
        float d_1 = comp3_0(_S124, k_2) - (F32_abs((local_3)));
        if(d_1 <= 0.0f)
        {
            return false;
        }
        if(d_1 < best_1)
        {
            float _S131;
            if(local_3 >= 0.0f)
            {
                _S131 = 1.0f;
            }
            else
            {
                _S131 = -1.0f;
            }
            best_1 = d_1;
            axis_2 = k_2;
            side_0 = _S131;
        }
        k_2 = k_2 + 1U;
    }
    *depth_0 = best_1;
    float3  _S132 = box_axis_0(b_11, axis_2);
    *normal_1 = _S132 * make_float3 (side_0);
    return true;
}

static __device__ bool pair_point_0(Box_0 * ba_0, Box_0 * bb_0, uint na_0, uint e_0, float3  * p_1, float3  * n_1, float * d_2)
{
    if(e_0 < na_0)
    {
        float3  _S133 = sample_point_0(ba_0, e_0);
        *p_1 = _S133;
        bool _S134 = penetration_0(bb_0, _S133, d_2, n_1);
        return _S134;
    }
    float3  _S135 = sample_point_0(bb_0, e_0 - na_0);
    *p_1 = _S135;
    bool _S136 = penetration_0(ba_0, _S135, d_2, n_1);
    if(!_S136)
    {
        return false;
    }
    *n_1 = - *n_1;
    return true;
}

static __device__ bool is_nan_0(float x_13)
{
    return ((F32_asuint((x_13))) & 2147483647U) > 2139095040U;
}

static __device__ uint pair_count_sum_0(uint x_14, uint lanes_1, uint _S137)
{
    bool _S138 = lanes_1 > 1U;
    uint _S139 = __ballot_sync(_S137, _S138);
    uint _S140;
    if(_S138)
    {
        uint _S141 = WaveActiveSum_3(x_14, _S139);
        uint _S142 = __ballot_sync(_S137, true);
        _S140 = _S141;
    }
    else
    {
        _S140 = x_14;
    }
    return _S140;
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
        float3  _S143 = box_axis_0(b_12, k_3);
        float c_3 = (F32_abs((dot_0(d_3, _S143))));
        float h_2 = h_1 + c_3 * comp3_0(b_12->half_2, k_3);
        uint _S144 = k_3 + 1U;
        float area_1 = area_0 + c_3 * 4.0f * comp3_0(b_12->half_2, _S144 % 3U) * comp3_0(b_12->half_2, (k_3 + 2U) % 3U);
        k_3 = _S144;
        h_1 = h_2;
        area_0 = area_1;
    }
    return make_float2 (h_1, area_0);
}

static __device__ float contact_stiffness_0(float ea_0, Box_0 * a_5, float eb_0, Box_0 * b_13, float3  dir_0)
{
    float3  d_4 = safe_normalize_0(dir_0);
    float2  _S145 = half_thickness_and_area_0(a_5, d_4);
    float2  _S146 = half_thickness_and_area_0(b_13, d_4);
    return (F32_min((_S145.y), (_S146.y))) / (_S145.x / ea_0 + _S146.x / eb_0);
}

static __device__ float3  penalty_force_0(float k_4, float m_red_0, float friction_0, float depth_1, float3  normal_2, float3  rel_velocity_0, float dt_1, uint points_0, float * stored_0, float * dissipated_1)
{
    float c_max_0 = 1.0f / (F32_max((float(points_0)), (10.0f))) * m_red_0 / dt_1;
    float _S147 = __ldg(&globalParams_0->params_0->zeta_0);
    float vn_0 = dot_0(rel_velocity_0, normal_2);
    float _S148 = k_4 * depth_1;
    float _S149 = (F32_min((2.0f * _S147 * (F32_sqrt((k_4 * m_red_0)))), (c_max_0))) * vn_0;
    float _S150 = _S148 - _S149;
    float _S151 = (F32_max((_S150), (0.0f)));
    float3  vt_0 = rel_velocity_0 - normal_2 * make_float3 (vn_0);
    float vt_mag_0 = length_0(vt_0);
    float _S152 = friction_0 * _S151;
    float _S153 = (F32_min((_S152), ((F32_min((c_max_0), (_S152 / 0.00100000004749745f))) * vt_mag_0)));
    float3  ft_0;
    if(vt_mag_0 > 0.0f)
    {
        ft_0 = - vt_0 * make_float3 (_S153 / vt_mag_0);
    }
    else
    {
        ft_0 = make_float3 (0.0f);
    }
    *stored_0 = 0.5f * k_4 * depth_1 * depth_1;
    float damping_power_0;
    if(_S150 > 0.0f)
    {
        damping_power_0 = _S149 * vn_0;
    }
    else
    {
        damping_power_0 = _S148 * (F32_max((vn_0), (0.0f)));
    }
    *dissipated_1 = (damping_power_0 + length_0(ft_0) * vt_mag_0) * dt_1;
    return normal_2 * make_float3 (_S151) + ft_0;
}

static __device__ float3  pair_sum3_0(float3  x_15, uint lanes_2, uint _S154)
{
    bool _S155 = lanes_2 > 1U;
    uint _S156 = __ballot_sync(_S154, _S155);
    float3  _S157;
    if(_S155)
    {
        float3  _S158 = WaveActiveSum_2(x_15, _S156);
        uint _S159 = __ballot_sync(_S154, true);
        _S157 = _S158;
    }
    else
    {
        _S157 = x_15;
    }
    return _S157;
}

static __device__ float pair_sum_0(float x_16, uint lanes_3, uint _S160)
{
    bool _S161 = lanes_3 > 1U;
    uint _S162 = __ballot_sync(_S160, _S161);
    float _S163;
    if(_S161)
    {
        float _S164 = WaveActiveSum_1(x_16, _S162);
        uint _S165 = __ballot_sync(_S160, true);
        _S163 = _S164;
    }
    else
    {
        _S163 = x_16;
    }
    return _S163;
}

static __device__ void comp_add1_0(float * sum_0, float * err_0, float x_17)
{
    float t_1 = *sum_0 + x_17;
    if((F32_abs((*sum_0))) >= (F32_abs((x_17))))
    {
        *err_0 = *err_0 + (*sum_0 - t_1 + x_17);
    }
    else
    {
        *err_0 = *err_0 + (x_17 - t_1 + *sum_0);
    }
    *sum_0 = t_1;
    return;
}

static __device__ void cov_or_0(uint island_0, uint bits_0)
{
    uint _S166 = atomicOr(&(&(globalParams_0->islands_0)[island_0])->coverage_0, bits_0);
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
    uint _S167 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint _S168 = __ldg(&globalParams_0->params_0->halt_index_0);
    cov_mark_0(_S167, (&(globalParams_0->islands_0)[_S168])->coverage_0, bits_2);
    return;
}

static __device__ void pair_contact_0(uint i_8, uint lane_0, uint lanes_4, uint _S169)
{
    uint _S170 = 0U;
    uint _S171;
    uint _S172;
    uint _S173 = __ldg(&globalParams_0->params_0->pair_index_0);
    uint at_0 = _S173 + 6U * i_8;
    uint _S174 = __ldg((&(globalParams_0->index_0)[at_0]));
    uint _S175 = __ldg((&(globalParams_0->index_0)[at_0 + 1U]));
    uint _S176 = __ldg((&(globalParams_0->index_0)[at_0 + 2U]));
    uint _S177 = __ldg((&(globalParams_0->index_0)[at_0 + 3U]));
    uint _S178 = __ldg((&(globalParams_0->index_0)[at_0 + 4U]));
    float _S179 = (U32_asfloat((_S178)));
    uint _S180 = __ldg((&(globalParams_0->index_0)[at_0 + 5U]));
    float _S181 = (U32_asfloat((_S180)));
    float _S182 = __ldg(&globalParams_0->params_0->dt_0);
    uint _S183 = __ldg(&globalParams_0->params_0->slot_base_0);
    uint out_0 = _S183 + 2U * _S176;
    WorldPoint_0 wa_0 = chunk_world_0(_S174);
    WorldPoint_0 _S184 = chunk_world_0(_S175);
    WorldPoint_0 _S185 = wa_0;
    float3  _S186 = world_diff_0(&_S184, &_S185);
    float _S187 = length_0(_S186);
    float4  _S188 = __ldg(&(&(globalParams_0->chunks_0)[_S174])->half_0);
    float _S189 = _S188.w;
    float4  _S190 = __ldg(&(&(globalParams_0->chunks_0)[_S175])->half_0);
    bool touching_0 = !(_S187 > (_S189 + _S190.w));
    uint _S191 = __ldg(&globalParams_0->params_0->ledger_base_0);
    float4  * _S192 = (&(globalParams_0->scratch_0)[_S191 + i_8]);
    float4  ledger_1 = *_S192;
    uint flags_0 = (F32_asuint(((*_S192).w)));
    float3  _S193 = make_float3 (0.0f);
    Box_0 ba_1 = chunk_box_0(_S174, _S193);
    Box_0 bb_1 = chunk_box_0(_S175, _S186);
    Box_0 _S194 = ba_1;
    uint _S195 = sample_count_0(&_S194);
    Box_0 _S196 = bb_1;
    uint _S197 = sample_count_0(&_S196);
    uint _S198 = _S195 + _S197;
    bool _S199 = !touching_0;
    uint _S200 = __ballot_sync(_S169, _S199);
    uint e_1;
    bool has_state_0;
    if(_S199)
    {
        if((flags_0 & 1U) != 0U)
        {
            e_1 = lane_0;
            for(;;)
            {
                if(e_1 < _S198)
                {
                }
                else
                {
                    break;
                }
                *(&(globalParams_0->contact_state_0)[_S177 + e_1]) = make_float4 ((U32_asfloat((2143289344U))), 0.0f, 0.0f, 0.0f);
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
                uint _S201 = __ldg(&globalParams_0->params_0->ledger_base_0);
                *(&(globalParams_0->scratch_0)[_S201 + i_8]) = ledger_1;
            }
        }
        return;
    }
    else
    {
        uint _S202 = __ballot_sync(_S169, true);
        _S170 = _S202;
    }
    Box_0 _S203 = ba_1;
    Box_0 _S204 = bb_1;
    bool _S205 = may_overlap_0(&_S203, &_S204);
    uint _S206 = __ballot_sync(_S170, _S205);
    uint count_0;
    float3  fa_0;
    float3  ta_0;
    float3  fb_0;
    float3  tb_0;
    float stored_sum_0;
    float diss_sum_0;
    if(_S205)
    {
        float3  va0_0;
        float3  wa0_0;
        chunk_velocity_0(_S174, &va0_0, &wa0_0);
        float3  vb0_0;
        float3  wb0_0;
        chunk_velocity_0(_S175, &vb0_0, &wb0_0);
        e_1 = lane_0;
        count_0 = 0U;
        uint engaged_0 = 0U;
        uint _S207 = _S206;
        for(;;)
        {
            uint _S208 = 0U;
            bool _S209 = e_1 < _S198;
            uint _S210 = __ballot_sync(_S207, _S209);
            if(_S209)
            {
                uint _S211 = __ballot_sync(_S207, true);
                _S208 = _S211;
            }
            else
            {
                uint _S212 = __ballot_sync(_S207, false);
                uint _S213 = __ballot_sync(_S207, false);
                uint _S214 = __ballot_sync(_S206, true);
                _S171 = _S214;
                break;
            }
            uint _S215 = 0U;
            Box_0 _S216 = ba_1;
            Box_0 _S217 = bb_1;
            float3  p_2;
            float3  n_2;
            float d_5;
            bool _S218 = pair_point_0(&_S216, &_S217, _S195, e_1, &p_2, &n_2, &d_5);
            bool _S219 = !_S218;
            uint _S220 = __ballot_sync(_S208, _S219);
            if(_S219)
            {
                uint _S221 = _S177 + e_1;
                bool _S222 = !is_nan_0((*(&(globalParams_0->contact_state_0)[_S221])).x);
                uint _S223 = __ballot_sync(_S220, _S222);
                if(_S222)
                {
                    *(&(globalParams_0->contact_state_0)[_S221]) = make_float4 ((U32_asfloat((2143289344U))), 0.0f, 0.0f, 0.0f);
                    uint _S224 = __ballot_sync(_S220, true);
                }
                else
                {
                    uint _S225 = __ballot_sync(_S220, true);
                }
                uint _S226 = __ballot_sync(_S208, false);
                uint _S227 = __ballot_sync(_S207, true);
                _S207 = _S227;
                e_1 = e_1 + lanes_4;
                continue;
            }
            else
            {
                uint _S228 = __ballot_sync(_S208, true);
                _S215 = _S228;
            }
            uint _S229 = count_0 + 1U;
            uint _S230 = _S177 + e_1;
            float4  * _S231 = (&(globalParams_0->contact_state_0)[_S230]);
            float4  entry_0 = *_S231;
            bool _S232 = is_nan_0((*_S231).x);
            uint _S233 = __ballot_sync(_S215, _S232);
            uint _S234;
            if(_S232)
            {
                uint _S235 = __ballot_sync(_S215, true);
                has_state_0 = true;
                _S234 = _S235;
            }
            else
            {
                float4  _S236 = entry_0;
                bool _S237 = (dot_0(float3 {_S236.y, _S236.z, _S236.w}, n_2)) < 0.99000000953674316f;
                uint _S238 = __ballot_sync(_S215, true);
                has_state_0 = _S237;
                _S234 = _S238;
            }
            uint _S239 = __ballot_sync(_S234, has_state_0);
            uint _S240;
            if(has_state_0)
            {
                bool _S241 = d_5 > (2.0f * (F32_abs((dot_0(va0_0 + cross_0(wa0_0, p_2) - (vb0_0 + cross_0(wb0_0, p_2 - bb_1.center_1)), n_2)))) * _S182 + 9.99999971718068537e-10f);
                uint _S242 = __ballot_sync(_S239, _S241);
                if(_S241)
                {
                    float _S243 = d_5;
                    uint _S244 = __ballot_sync(_S239, true);
                    stored_sum_0 = _S243;
                }
                else
                {
                    uint _S245 = __ballot_sync(_S239, true);
                    stored_sum_0 = 0.0f;
                }
                entry_0 = make_float4 (stored_sum_0, n_2.x, n_2.y, n_2.z);
                uint _S246 = __ballot_sync(_S234, true);
                _S240 = _S246;
            }
            else
            {
                uint _S247 = __ballot_sync(_S234, true);
                _S240 = _S247;
            }
            *&((&entry_0)->x) = (F32_min((entry_0.x), (d_5)));
            *(&(globalParams_0->contact_state_0)[_S230]) = entry_0;
            bool _S248 = (d_5 - entry_0.x) > 0.0f;
            uint _S249 = __ballot_sync(_S240, _S248);
            uint engaged_1;
            if(_S248)
            {
                uint _S250 = engaged_0 + 1U;
                uint _S251 = __ballot_sync(_S240, true);
                engaged_1 = _S250;
            }
            else
            {
                uint _S252 = __ballot_sync(_S240, true);
                engaged_1 = engaged_0;
            }
            uint _S253 = __ballot_sync(_S207, true);
            count_0 = _S229;
            engaged_0 = engaged_1;
            _S207 = _S253;
            e_1 = e_1 + lanes_4;
        }
        uint _S254 = pair_count_sum_0(count_0, lanes_4, _S171);
        uint _S255 = pair_count_sum_0(engaged_0, lanes_4, _S171);
        bool _S256 = _S254 > 0U;
        uint _S257 = __ballot_sync(_S171, _S256);
        if(_S256)
        {
            float4  _S258 = __ldg(&(&(globalParams_0->chunks_0)[_S174])->cmat_0);
            float _S259 = _S258.x;
            float4  _S260 = __ldg(&(&(globalParams_0->chunks_0)[_S175])->cmat_0);
            float _S261 = _S260.x;
            float3  _S262 = bb_1.center_1 - ba_1.center_1;
            Box_0 _S263 = ba_1;
            Box_0 _S264 = bb_1;
            float _S265 = contact_stiffness_0(_S259, &_S263, _S261, &_S264, _S262);
            float _S266 = _S265 / (F32_max((float(_S255)), (10.0f)));
            e_1 = lane_0;
            fa_0 = _S193;
            ta_0 = _S193;
            fb_0 = _S193;
            tb_0 = _S193;
            stored_sum_0 = 0.0f;
            diss_sum_0 = 0.0f;
            count_0 = _S257;
            for(;;)
            {
                uint _S267 = 0U;
                bool _S268 = e_1 < _S198;
                uint _S269 = __ballot_sync(count_0, _S268);
                if(_S268)
                {
                    uint _S270 = __ballot_sync(count_0, true);
                    _S267 = _S270;
                }
                else
                {
                    uint _S271 = __ballot_sync(count_0, false);
                    uint _S272 = __ballot_sync(count_0, false);
                    uint _S273 = __ballot_sync(_S257, true);
                    _S172 = _S273;
                    break;
                }
                uint _S274 = 0U;
                Box_0 _S275 = ba_1;
                Box_0 _S276 = bb_1;
                float3  p_3;
                float3  n_3;
                float d_6;
                bool _S277 = pair_point_0(&_S275, &_S276, _S195, e_1, &p_3, &n_3, &d_6);
                bool _S278 = !_S277;
                uint _S279 = __ballot_sync(_S267, _S278);
                if(_S278)
                {
                    uint _S280 = __ballot_sync(_S267, false);
                    uint _S281 = __ballot_sync(count_0, true);
                    count_0 = _S281;
                    e_1 = e_1 + lanes_4;
                    continue;
                }
                else
                {
                    uint _S282 = __ballot_sync(_S267, true);
                    _S274 = _S282;
                }
                float eff_0 = d_6 - (*(&(globalParams_0->contact_state_0)[_S177 + e_1])).x;
                bool _S283 = eff_0 <= 0.0f;
                uint _S284 = __ballot_sync(_S274, _S283);
                if(_S283)
                {
                    uint _S285 = __ballot_sync(_S274, false);
                    uint _S286 = __ballot_sync(count_0, true);
                    count_0 = _S286;
                    e_1 = e_1 + lanes_4;
                    continue;
                }
                else
                {
                    uint _S287 = __ballot_sync(_S274, true);
                }
                float stored_1;
                float diss_0;
                float3  f_1 = penalty_force_0(_S266, _S179, _S181, eff_0, n_3, va0_0 + cross_0(wa0_0, p_3) - (vb0_0 + cross_0(wb0_0, p_3 - bb_1.center_1)), _S182, _S255, &stored_1, &diss_0);
                float3  fa_1 = fa_0 + f_1;
                float3  ta_1 = ta_0 + cross_0(p_3, f_1);
                float3  _S288 = - f_1;
                float3  fb_1 = fb_0 + _S288;
                float3  tb_1 = tb_0 + cross_0(p_3 - bb_1.center_1, _S288);
                float stored_sum_1 = stored_sum_0 + stored_1;
                float diss_sum_1 = diss_sum_0 + diss_0;
                uint _S289 = __ballot_sync(count_0, true);
                fa_0 = fa_1;
                ta_0 = ta_1;
                fb_0 = fb_1;
                tb_0 = tb_1;
                stored_sum_0 = stored_sum_1;
                diss_sum_0 = diss_sum_1;
                count_0 = _S289;
                e_1 = e_1 + lanes_4;
            }
            float3  _S290 = pair_sum3_0(fa_0, lanes_4, _S172);
            float3  _S291 = pair_sum3_0(ta_0, lanes_4, _S172);
            float3  _S292 = pair_sum3_0(fb_0, lanes_4, _S172);
            float3  _S293 = pair_sum3_0(tb_0, lanes_4, _S172);
            float _S294 = pair_sum_0(stored_sum_0, lanes_4, _S172);
            float _S295 = pair_sum_0(diss_sum_0, lanes_4, _S172);
            uint _S296 = __ballot_sync(_S171, true);
            has_state_0 = true;
            diss_sum_0 = _S295;
            fa_0 = _S290;
            ta_0 = _S291;
            fb_0 = _S292;
            tb_0 = _S293;
            stored_sum_0 = _S294;
        }
        else
        {
            has_state_0 = false;
            diss_sum_0 = 0.0f;
            fa_0 = _S193;
            ta_0 = _S193;
            fb_0 = _S193;
            tb_0 = _S193;
            stored_sum_0 = 0.0f;
        }
    }
    else
    {
        has_state_0 = false;
        diss_sum_0 = 0.0f;
        fa_0 = _S193;
        ta_0 = _S193;
        fb_0 = _S193;
        tb_0 = _S193;
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
            if(e_1 < _S198)
            {
            }
            else
            {
                break;
            }
            *(&(globalParams_0->contact_state_0)[_S177 + e_1]) = make_float4 ((U32_asfloat((2143289344U))), 0.0f, 0.0f, 0.0f);
            e_1 = e_1 + lanes_4;
        }
    }
    if(lane_0 != 0U)
    {
        return;
    }
    if(has_state_0)
    {
        comp_add1_0(&((&ledger_1)->y), &((&ledger_1)->z), diss_sum_0);
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
    bool _S297;
    if(loaded_0)
    {
        _S297 = true;
    }
    else
    {
        _S297 = (flags_0 & 2U) != 0U;
    }
    if(_S297)
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
    uint _S298 = __ldg(&globalParams_0->params_0->ledger_base_0);
    *(&(globalParams_0->scratch_0)[_S298 + i_8]) = ledger_1;
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
    float3  _S299 = make_float3 (1.0f, 0.0f, 0.0f);
    Quat_0 _S300 = q_6;
    float3  _S301 = rotate_0(&_S300, _S299);
    (&b_14)->axis0_0 = _S301;
    float3  _S302 = make_float3 (0.0f, 1.0f, 0.0f);
    Quat_0 _S303 = q_6;
    float3  _S304 = rotate_0(&_S303, _S302);
    (&b_14)->axis1_0 = _S304;
    float3  _S305 = make_float3 (0.0f, 0.0f, 1.0f);
    Quat_0 _S306 = q_6;
    float3  _S307 = rotate_0(&_S306, _S305);
    (&b_14)->axis2_0 = _S307;
    (&b_14)->half_2 = half_3;
    (&b_14)->hull_at_0 = 0U;
    (&b_14)->hull_v_0 = 0U;
    (&b_14)->hull_f_0 = 0U;
    return b_14;
}

static __device__ uint impactor_slots_0(Impactor_0 * imp_1, Box_0 * b_15)
{
    uint _S308;
    if((imp_1->shape_0.x) == 0.0f)
    {
        _S308 = 1U;
    }
    else
    {
        uint _S309 = sample_count_0(b_15);
        _S308 = _S309 + 14U;
    }
    return _S308;
}

static __device__ bool sphere_contact_0(Box_0 * b_16, float3  center_4, float radius_0, float3  * point_0, float3  * normal_3, float * depth_2)
{
    float3  _S310 = make_float3 (0.0f);
    *point_0 = _S310;
    *normal_3 = _S310;
    *depth_2 = 0.0f;
    float3  _S311 = b_16->center_1;
    float3  r_3 = center_4 - b_16->center_1;
    float3  _S312 = b_16->axis0_0;
    float3  _S313 = b_16->axis1_0;
    float3  _S314 = b_16->axis2_0;
    float3  local_4 = make_float3 (dot_0(r_3, b_16->axis0_0), dot_0(r_3, b_16->axis1_0), dot_0(r_3, b_16->axis2_0));
    uint _S315 = b_16->hull_v_0;
    if((b_16->hull_v_0) != 0U)
    {
        uint face_2;
        float _S316 = hull_signed_distance_0(b_16, local_4, &face_2);
        if(_S316 >= radius_0)
        {
            return false;
        }
        float4  _S317 = __ldg((&(globalParams_0->loads_0)[b_16->hull_at_0 + _S315 + face_2]));
        float3  _S318 = box_to_world_0(b_16, float3 {_S317.x, _S317.y, _S317.z});
        *normal_3 = _S318;
        *point_0 = center_4 - _S318 * make_float3 ((F32_max((_S316), (0.0f))));
        *depth_2 = radius_0 - _S316;
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
        *normal_3 = _S312 * make_float3 (dn_0.x) + _S313 * make_float3 (dn_0.y) + _S314 * make_float3 (dn_0.z);
        *point_0 = _S311 + _S312 * make_float3 (q_7.x) + _S313 * make_float3 (q_7.y) + _S314 * make_float3 (q_7.z);
        *depth_2 = radius_0 - dist_0;
        return true;
    }
    float inside_0;
    float3  n_4;
    bool _S319 = penetration_0(b_16, center_4, &inside_0, &n_4);
    if(!_S319)
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
    float3  _S320 = make_float3 (0.0f);
    *p_4 = _S320;
    *n_5 = _S320;
    *d_8 = 0.0f;
    float4  _S321 = imp_2->shape_0;
    if((imp_2->shape_0.x) == 0.0f)
    {
        bool _S322 = sphere_contact_0(b_17, _S320, _S321.y - crush_depth_0, p_4, n_5, d_8);
        if(!_S322)
        {
            return false;
        }
        *n_5 = - *n_5;
        return true;
    }
    uint _S323 = sample_count_0(b_17);
    if(j_0 < _S323)
    {
        float3  _S324 = sample_point_0(b_17, j_0);
        *p_4 = _S324;
        bool _S325 = penetration_0(shrunk_0, _S324, d_8, n_5);
        return _S325;
    }
    float3  _S326 = sample_point_0(shrunk_0, j_0 - _S323);
    *p_4 = _S326;
    bool _S327 = penetration_0(b_17, _S326, d_8, n_5);
    if(!_S327)
    {
        return false;
    }
    *n_5 = - *n_5;
    return true;
}

static __device__ WorldPoint_0 impactor_point_0(uint _S328)
{
    Impactor_0 * _S329 = (&(globalParams_0->impactors_0)[_S328]);
    WorldPoint_0 wi_0;
    float4  _S330 = _S329->position_1;
    (&wi_0)->hi_0 = float3 {_S330.x, _S330.y, _S330.z};
    float4  _S331 = _S329->position_err_1;
    (&wi_0)->lo_0 = float3 {_S331.x, _S331.y, _S331.z};
    (&wi_0)->rel_0 = make_float3 (0.0f);
    return wi_0;
}

static __device__ Box_0 impactor_box_1(uint _S332, float3  _S333, float3  _S334)
{
    Quat_0 q_8 = quat_of_0((&(globalParams_0->impactors_0)[_S332])->rotation_1);
    Box_0 b_18;
    (&b_18)->center_1 = _S333;
    float3  _S335 = make_float3 (1.0f, 0.0f, 0.0f);
    Quat_0 _S336 = q_8;
    float3  _S337 = rotate_0(&_S336, _S335);
    (&b_18)->axis0_0 = _S337;
    float3  _S338 = make_float3 (0.0f, 1.0f, 0.0f);
    Quat_0 _S339 = q_8;
    float3  _S340 = rotate_0(&_S339, _S338);
    (&b_18)->axis1_0 = _S340;
    float3  _S341 = make_float3 (0.0f, 0.0f, 1.0f);
    Quat_0 _S342 = q_8;
    float3  _S343 = rotate_0(&_S342, _S341);
    (&b_18)->axis2_0 = _S343;
    (&b_18)->half_2 = _S334;
    (&b_18)->hull_at_0 = 0U;
    (&b_18)->hull_v_0 = 0U;
    (&b_18)->hull_f_0 = 0U;
    return b_18;
}

static __device__ Box_0 impactor_shrunk_0(uint _S344, float _S345, Box_0 * _S346)
{
    Box_0 shrunk_1 = *_S346;
    (&shrunk_1)->half_2 = _S346->half_2 - min_0(make_float3 (_S345), _S346->half_2 * make_float3 (0.5f));
    return shrunk_1;
}

static __device__ bool impactor_contact_1(uint _S347, float _S348, Box_0 * _S349, Box_0 * _S350, uint _S351, float3  * _S352, float3  * _S353, float * _S354)
{
    Impactor_0 _S355 = *(&(globalParams_0->impactors_0)[_S347]);
    float3  _S356 = make_float3 (0.0f);
    *_S352 = _S356;
    *_S353 = _S356;
    *_S354 = 0.0f;
    if((_S355.shape_0.x) == 0.0f)
    {
        bool _S357 = sphere_contact_0(_S350, _S356, _S355.shape_0.y - _S348, _S352, _S353, _S354);
        if(!_S357)
        {
            return false;
        }
        *_S353 = - *_S353;
        return true;
    }
    uint _S358 = sample_count_0(_S350);
    if(_S351 < _S358)
    {
        float3  _S359 = sample_point_0(_S350, _S351);
        *_S352 = _S359;
        bool _S360 = penetration_0(_S349, _S359, _S354, _S353);
        return _S360;
    }
    float3  _S361 = sample_point_0(_S349, _S351 - _S358);
    *_S352 = _S361;
    bool _S362 = penetration_0(_S350, _S361, _S354, _S353);
    if(!_S362)
    {
        return false;
    }
    *_S353 = - *_S353;
    return true;
}

static __device__ uint impactor_contact_count_0(uint _S363, float _S364, Box_0 * _S365, Box_0 * _S366)
{
    Impactor_0 _S367 = *(&(globalParams_0->impactors_0)[_S363]);
    uint j_1 = 0U;
    uint count_1 = 0U;
    for(;;)
    {
        Impactor_0 _S368 = _S367;
        uint _S369 = impactor_slots_0(&_S368, _S366);
        if(j_1 < _S369)
        {
        }
        else
        {
            break;
        }
        float3  p_5;
        float3  n_6;
        float d_9;
        bool _S370 = impactor_contact_1(_S363, _S364, _S365, _S366, j_1, &p_5, &n_6, &d_9);
        if(_S370)
        {
            count_1 = count_1 + 1U;
        }
        j_1 = j_1 + 1U;
    }
    return count_1;
}

static __device__ void impactor_candidate_forces_0(uint k_5)
{
    uint _S371 = __ldg(&globalParams_0->params_0->cand_index_0);
    uint _S372 = 3U * k_5;
    uint at_1 = _S371 + _S372;
    uint _S373 = __ldg((&(globalParams_0->index_0)[at_1]));
    uint _S374 = __ldg((&(globalParams_0->index_0)[at_1 + 1U]));
    uint _S375 = __ldg((&(globalParams_0->index_0)[at_1 + 2U]));
    Impactor_0 imp_3 = *(&(globalParams_0->impactors_0)[_S375]);
    float _S376 = __ldg(&globalParams_0->params_0->dt_0);
    float3  _S377 = make_float3 (0.0f);
    uint _S378 = __ldg(&globalParams_0->params_0->cand_base_0);
    float4  data_0 = *(&(globalParams_0->scratch_0)[_S378 + _S372]);
    bool hit_0;
    float3  f_sum_0;
    float3  t_sum_0;
    float3  imp_f_0;
    float3  imp_t_0;
    if((imp_3.cand_0.z) == 0U)
    {
        WorldPoint_0 _S379 = impactor_point_0(_S375);
        WorldPoint_0 _S380 = chunk_world_0(_S373);
        WorldPoint_0 _S381 = _S379;
        float3  _S382 = world_diff_0(&_S380, &_S381);
        float _S383 = length_0(_S382);
        float _S384 = imp_3.half_1.w;
        float4  _S385 = __ldg(&(&(globalParams_0->chunks_0)[_S373])->half_0);
        if(!(_S383 > (_S384 + _S385.w)))
        {
            float4  _S386 = imp_3.half_1;
            Box_0 _S387 = impactor_box_1(_S375, _S377, float3 {_S386.x, _S386.y, _S386.z});
            Box_0 b_19 = chunk_box_0(_S373, _S382);
            float _S388 = imp_3.mat_0.x;
            float4  _S389 = __ldg(&(&(globalParams_0->chunks_0)[_S373])->cmat_0);
            float _S390 = _S389.x;
            float3  _S391 = b_19.center_1 - _S387.center_1;
            Box_0 _S392 = _S387;
            Box_0 _S393 = b_19;
            float _S394 = contact_stiffness_0(_S388, &_S392, _S390, &_S393, _S391);
            float _S395 = imp_3.geom_0.y;
            Box_0 _S396 = _S387;
            Box_0 _S397 = impactor_shrunk_0(_S375, _S395, &_S396);
            Box_0 _S398 = _S397;
            Box_0 _S399 = b_19;
            uint _S400 = impactor_contact_count_0(_S375, _S395, &_S398, &_S399);
            bool _S401 = (imp_3.shape_0.x) == 0.0f;
            float _S402;
            if(_S401)
            {
                _S402 = _S394;
            }
            else
            {
                _S402 = _S394 / (F32_max((float(_S400)), (10.0f)));
            }
            uint _S403;
            if(_S401)
            {
                _S403 = 1U;
            }
            else
            {
                _S403 = _S400;
            }
            float4  _S404 = __ldg(&(&(globalParams_0->chunks_0)[_S373])->center_0);
            float m_1 = _S404.w;
            float _S405 = imp_3.mat_0.z;
            float _S406 = m_1 * _S405 / (m_1 + _S405);
            float _S407 = __ldg(&globalParams_0->params_0->pair_friction_0);
            float _S408;
            if(_S407 >= 0.0f)
            {
                float _S409 = __ldg(&globalParams_0->params_0->pair_friction_0);
                _S408 = _S409;
            }
            else
            {
                float _S410 = imp_3.mat_0.y;
                float4  _S411 = __ldg(&(&(globalParams_0->chunks_0)[_S373])->cmat_0);
                _S408 = (F32_min((_S410), (_S411.y)));
            }
            float4  _S412 = imp_3.velocity_1;
            float4  _S413 = imp_3.velocity_err_1;
            float3  _S414 = float3 {_S412.x, _S412.y, _S412.z} + float3 {_S413.x, _S413.y, _S413.z};
            float3  vc_0;
            float3  wc_0;
            chunk_velocity_0(_S373, &vc_0, &wc_0);
            hit_0 = false;
            uint j_2 = 0U;
            f_sum_0 = _S377;
            t_sum_0 = _S377;
            imp_f_0 = _S377;
            imp_t_0 = _S377;
            for(;;)
            {
                bool _S415;
                if(_S400 > 0U)
                {
                    Impactor_0 _S416 = imp_3;
                    Box_0 _S417 = b_19;
                    uint _S418 = impactor_slots_0(&_S416, &_S417);
                    _S415 = j_2 < _S418;
                }
                else
                {
                    _S415 = false;
                }
                if(_S415)
                {
                }
                else
                {
                    break;
                }
                Impactor_0 _S419 = imp_3;
                Box_0 _S420 = _S397;
                Box_0 _S421 = b_19;
                float3  p_6;
                float3  nrm_0;
                float dep_0;
                bool _S422 = impactor_contact_0(&_S419, _S395, &_S420, &_S421, j_2, &p_6, &nrm_0, &dep_0);
                if(!_S422)
                {
                    j_2 = j_2 + 1U;
                    continue;
                }
                float4  _S423 = imp_3.angular_velocity_1;
                float stored_2;
                float diss_1;
                float3  f_2 = penalty_force_0(_S402, _S406, _S408, dep_0 * imp_3.geom_0.x, nrm_0, vc_0 + cross_0(wc_0, p_6 - b_19.center_1) - (_S414 + cross_0(float3 {_S423.x, _S423.y, _S423.z}, p_6)), _S376, _S403, &stored_2, &diss_1);
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
            f_sum_0 = _S377;
            t_sum_0 = _S377;
            imp_f_0 = _S377;
            imp_t_0 = _S377;
        }
    }
    else
    {
        hit_0 = false;
        f_sum_0 = _S377;
        t_sum_0 = _S377;
        imp_f_0 = _S377;
        imp_t_0 = _S377;
    }
    uint _S424 = __ldg(&globalParams_0->params_0->slot_base_0);
    uint _S425 = 2U * _S374;
    *(&(globalParams_0->scratch_0)[_S424 + _S425]) = make_float4 (f_sum_0.x, f_sum_0.y, f_sum_0.z, 0.0f);
    uint _S426 = __ldg(&globalParams_0->params_0->slot_base_0);
    *(&(globalParams_0->scratch_0)[_S426 + _S425 + 1U]) = make_float4 (t_sum_0.x, t_sum_0.y, t_sum_0.z, 0.0f);
    uint _S427 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S427 + _S372]) = data_0;
    uint _S428 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S428 + _S372 + 1U]) = make_float4 (imp_f_0.x, imp_f_0.y, imp_f_0.z, 0.0f);
    uint _S429 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S429 + _S372 + 2U]) = make_float4 (imp_t_0.x, imp_t_0.y, imp_t_0.z, 0.0f);
    if(hit_0)
    {
        sentinel_mark_0(2U);
    }
    return;
}

static __device__ Quat_0 quat_mul_0(Quat_0 * a_6, Quat_0 * o_0)
{
    Quat_0 r_4;
    (&r_4)->w_1 = a_6->w_1 * o_0->w_1 - a_6->x_12 * o_0->x_12 - a_6->y_4 * o_0->y_4 - a_6->z_0 * o_0->z_0;
    (&r_4)->x_12 = a_6->w_1 * o_0->x_12 + a_6->x_12 * o_0->w_1 + a_6->y_4 * o_0->z_0 - a_6->z_0 * o_0->y_4;
    (&r_4)->y_4 = a_6->w_1 * o_0->y_4 - a_6->x_12 * o_0->z_0 + a_6->y_4 * o_0->w_1 + a_6->z_0 * o_0->x_12;
    (&r_4)->z_0 = a_6->w_1 * o_0->z_0 + a_6->x_12 * o_0->y_4 - a_6->y_4 * o_0->x_12 + a_6->z_0 * o_0->w_1;
    return r_4;
}

static __device__ void travel_check_0(uint c_4)
{
    ChunkStatic_0 * _S430 = (&(globalParams_0->chunks_0)[c_4]);
    uint4  _S431 = __ldg(&_S430->cinfo_0);
    if((_S431.z) == 0U)
    {
        return;
    }
    WorldPoint_0 wp_0 = chunk_world_0(c_4);
    float4  _S432 = __ldg(&_S430->start_hi_0);
    float3  _S433 = wp_0.hi_0 - float3 {_S432.x, _S432.y, _S432.z};
    float4  _S434 = __ldg(&_S430->start_lo_0);
    float travel_0 = length_0(_S433 + (wp_0.lo_0 - float3 {_S434.x, _S434.y, _S434.z}) + wp_0.rel_0);
    float travel_1;
    if((_S431.w) != 0U)
    {
        float4  _S435 = *(&(globalParams_0->state_0)[4U * c_4 + 1U]);
        float3  th_1 = float3 {_S435.x, _S435.y, _S435.z};
        uint4  _S436 = __ldg(&_S430->info_0);
        Quat_0 _S437 = from_axis_angle_0(th_1, length_0(th_1));
        Quat_0 _S438 = quat_of_0((&(globalParams_0->islands_0)[_S436.y])->rotation_0);
        Quat_0 _S439 = _S437;
        Quat_0 _S440 = quat_mul_0(&_S438, &_S439);
        float4  _S441 = __ldg(&_S430->start_rot_0);
        Quat_0 _S442 = quat_of_0(make_float4 ((- float3 {_S441.x, _S441.y, _S441.z}).x, (- float3 {_S441.x, _S441.y, _S441.z}).y, (- float3 {_S441.x, _S441.y, _S441.z}).z, _S441.w));
        Quat_0 _S443 = _S440;
        Quat_0 _S444 = quat_mul_0(&_S442, &_S443);
        float _S445 = 2.0f * (F32_atan2((length_0(make_float3 (_S444.x_12, _S444.y_4, _S444.z_0))), ((F32_abs((_S444.w_1))))));
        float4  _S446 = __ldg(&_S430->half_0);
        travel_1 = travel_0 + _S445 * _S446.w;
    }
    else
    {
        travel_1 = travel_0;
    }
    if(travel_1 > (_S432.w))
    {
        uint _S447 = __ldg(&globalParams_0->params_0->halt_index_0);
        uint _S448 = __ldg(&globalParams_0->params_0->halt_index_0);
        *&((&(&(globalParams_0->islands_0)[_S447])->info_1)->z) = ((&(globalParams_0->islands_0)[_S448])->info_1.z) | 1U;
        sentinel_mark_0(1048576U);
    }
    return;
}

extern "C" __global__ void contact_forces()
{
    uint3  _S449 = blockIdx * blockDim + threadIdx;
    uint _S450 = __ballot_sync(4294967295U, true);
    uint i_9 = _S449.x;
    uint lanes_5 = pair_lane_count_0();
    uint _S451 = __ldg(&globalParams_0->params_0->pair_count_0);
    uint pair_threads_0 = _S451 * lanes_5;
    bool _S452 = i_9 < pair_threads_0;
    uint _S453 = __ballot_sync(_S450, _S452);
    if(_S452)
    {
        bool _S454 = pair_any_0(stopped_0(), lanes_5, _S453);
        bool _S455 = !_S454;
        uint _S456 = __ballot_sync(_S453, _S455);
        if(_S455)
        {
            uint _S457 = i_9 / lanes_5;
            uint _S458 = i_9 % lanes_5;
            pair_contact_0(_S457, _S458, lanes_5, _S456);
            uint _S459 = __ballot_sync(_S453, true);
        }
        return;
    }
    if(stopped_0())
    {
        return;
    }
    uint j_3 = i_9 - pair_threads_0;
    uint _S460 = __ldg(&globalParams_0->params_0->cand_count_0);
    if(j_3 < _S460)
    {
        impactor_candidate_forces_0(j_3);
    }
    else
    {
        uint _S461 = __ldg(&globalParams_0->params_0->cand_count_0);
        uint _S462 = __ldg(&globalParams_0->params_0->chunk_count_0);
        if(j_3 < (_S461 + _S462))
        {
            uint _S463 = __ldg(&globalParams_0->params_0->cand_count_0);
            travel_check_0(j_3 - _S463);
        }
    }
    return;
}

extern "C" __global__ void impactor_shares()
{
    uint k_6 = (blockIdx * blockDim + threadIdx).x;
    uint _S464 = __ldg(&globalParams_0->params_0->cand_count_0);
    bool _S465;
    if(k_6 >= _S464)
    {
        _S465 = true;
    }
    else
    {
        _S465 = stopped_0();
    }
    if(_S465)
    {
        return;
    }
    uint _S466 = __ldg(&globalParams_0->params_0->cand_index_0);
    uint _S467 = 3U * k_6;
    uint at_2 = _S466 + _S467;
    uint _S468 = __ldg((&(globalParams_0->index_0)[at_2]));
    uint _S469 = __ldg((&(globalParams_0->index_0)[at_2 + 2U]));
    Impactor_0 * _S470 = (&(globalParams_0->impactors_0)[_S469]);
    Impactor_0 imp_4 = *_S470;
    if(((*_S470).cand_0.z) == 0U)
    {
        _S465 = (imp_4.crush_1.x) > 0.0f;
    }
    else
    {
        _S465 = false;
    }
    float total_0;
    float ksum_0;
    if(_S465)
    {
        WorldPoint_0 _S471 = impactor_point_0(_S469);
        WorldPoint_0 _S472 = chunk_world_0(_S468);
        WorldPoint_0 _S473 = _S471;
        float3  _S474 = world_diff_0(&_S472, &_S473);
        float _S475 = length_0(_S474);
        float _S476 = imp_4.half_1.w;
        float4  _S477 = __ldg(&(&(globalParams_0->chunks_0)[_S468])->half_0);
        if(!(_S475 > (_S476 + _S477.w)))
        {
            float4  _S478 = imp_4.half_1;
            Box_0 _S479 = impactor_box_1(_S469, make_float3 (0.0f), float3 {_S478.x, _S478.y, _S478.z});
            Box_0 b_20 = chunk_box_0(_S468, _S474);
            float _S480 = imp_4.mat_0.x;
            float4  _S481 = __ldg(&(&(globalParams_0->chunks_0)[_S468])->cmat_0);
            float _S482 = _S481.x;
            float3  _S483 = b_20.center_1 - _S479.center_1;
            Box_0 _S484 = _S479;
            Box_0 _S485 = b_20;
            float _S486 = contact_stiffness_0(_S480, &_S484, _S482, &_S485, _S483);
            float _S487 = imp_4.crush_1.w;
            Box_0 _S488 = _S479;
            Box_0 _S489 = impactor_shrunk_0(_S469, _S487, &_S488);
            Box_0 _S490 = _S489;
            Box_0 _S491 = b_20;
            uint _S492 = impactor_contact_count_0(_S469, _S487, &_S490, &_S491);
            float _S493;
            if((imp_4.shape_0.x) == 0.0f)
            {
                _S493 = _S486;
            }
            else
            {
                _S493 = _S486 / (F32_max((float(_S492)), (10.0f)));
            }
            uint j_4 = 0U;
            total_0 = 0.0f;
            ksum_0 = 0.0f;
            for(;;)
            {
                if(_S492 > 0U)
                {
                    Impactor_0 _S494 = imp_4;
                    Box_0 _S495 = b_20;
                    uint _S496 = impactor_slots_0(&_S494, &_S495);
                    _S465 = j_4 < _S496;
                }
                else
                {
                    _S465 = false;
                }
                if(_S465)
                {
                }
                else
                {
                    break;
                }
                Impactor_0 _S497 = imp_4;
                Box_0 _S498 = _S489;
                Box_0 _S499 = b_20;
                float3  p_7;
                float3  nrm_1;
                float dep_1;
                bool _S500 = impactor_contact_0(&_S497, _S487, &_S498, &_S499, j_4, &p_7, &nrm_1, &dep_1);
                if(!_S500)
                {
                    j_4 = j_4 + 1U;
                    continue;
                }
                float ksum_1 = ksum_0 + _S493;
                total_0 = total_0 + _S493 * dep_1;
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
    uint _S501 = __ldg(&globalParams_0->params_0->cand_base_0);
    float4  data_1 = *(&(globalParams_0->scratch_0)[_S501 + _S467]);
    uint _S502 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S502 + _S467]) = make_float4 (total_0, ksum_0, data_1.z, data_1.w);
    return;
}

extern "C" __global__ void impactor_crush()
{
    uint _S503;
    uint _S504 = __ballot_sync(4294967295U, true);
    uint ii_0 = blockIdx.x;
    uint tid_2 = threadIdx.x;
    uint _S505 = __ldg(&globalParams_0->params_0->impactor_count_0);
    bool _S506 = ii_0 >= _S505;
    uint _S507 = __ballot_sync(_S504, _S506);
    bool _S508;
    uint k_7;
    if(_S506)
    {
        uint _S509 = __ballot_sync(_S504, true);
        _S508 = true;
        k_7 = _S509;
    }
    else
    {
        bool _S510 = stopped_0();
        uint _S511 = __ballot_sync(_S504, true);
        _S508 = _S510;
        k_7 = _S511;
    }
    uint _S512 = 0U;
    uint _S513 = __ballot_sync(k_7, _S508);
    if(_S508)
    {
        return;
    }
    else
    {
        uint _S514 = __ballot_sync(k_7, true);
        _S512 = _S514;
    }
    Impactor_0 imp_5 = *(&(globalParams_0->impactors_0)[ii_0]);
    float4  _S515 = make_float4 (0.0f);
    float4  shares_0 = _S515;
    float4  unused_0 = _S515;
    k_7 = (&imp_5)->cand_0.x + tid_2;
    uint _S516;
    _S516 = _S512;
    for(;;)
    {
        bool _S517 = k_7 < ((&imp_5)->cand_0.y);
        uint _S518 = __ballot_sync(_S516, _S517);
        if(_S517)
        {
            uint _S519 = __ballot_sync(_S516, true);
        }
        else
        {
            uint _S520 = __ballot_sync(_S516, false);
            uint _S521 = __ballot_sync(_S516, false);
            uint _S522 = __ballot_sync(_S512, true);
            _S503 = _S522;
            break;
        }
        uint _S523 = __ldg(&globalParams_0->params_0->cand_base_0);
        shares_0 = shares_0 + *(&(globalParams_0->scratch_0)[_S523 + 3U * k_7]);
        uint _S524 = __ballot_sync(_S516, true);
        k_7 = k_7 + 256U;
        _S516 = _S524;
    }
    group_sum2_0(tid_2, &shares_0, &unused_0, _S503);
    bool _S525 = tid_2 != 0U;
    uint _S526 = __ballot_sync(_S503, _S525);
    if(_S525)
    {
        _S508 = true;
    }
    else
    {
        _S508 = ((&imp_5)->cand_0.z) != 0U;
    }
    if(_S508)
    {
        return;
    }
    (&imp_5)->geom_0 = make_float4 (1.0f, (&imp_5)->crush_1.w, 0.0f, 0.0f);
    float total_1 = shares_0.x;
    if(((&imp_5)->crush_1.x) > 0.0f)
    {
        _S508 = ((&imp_5)->crush_1.z) < ((&imp_5)->crush_1.y);
    }
    else
    {
        _S508 = false;
    }
    if(_S508)
    {
        _S508 = total_1 > ((&imp_5)->crush_1.x);
    }
    else
    {
        _S508 = false;
    }
    if(_S508)
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

static __device__ void comp_add_0(float3  * sum_1, float3  * err_1, float3  x_18)
{
    float3  t_2 = *sum_1 + x_18;
    float3  _S527 = abs_1(x_18);
    *err_1 = *err_1 + (_slang_select((abs_1(*sum_1)) >= _S527, *sum_1,x_18) - t_2 + _slang_select((abs_1(*sum_1)) >= _S527, x_18,*sum_1));
    *sum_1 = t_2;
    return;
}

static __device__ float3  inverse_rotate_0(Quat_0 * q_9, float3  v_4)
{
    Quat_0 c_5;
    (&c_5)->w_1 = q_9->w_1;
    (&c_5)->x_12 = - q_9->x_12;
    (&c_5)->y_4 = - q_9->y_4;
    (&c_5)->z_0 = - q_9->z_0;
    Quat_0 _S528 = c_5;
    float3  _S529 = rotate_0(&_S528, v_4);
    return _S529;
}

static __device__ float3  rows_mul_0(float4  r0_0, float4  r1_0, float4  r2_0, float3  v_5)
{
    return make_float3 (dot_0(float3 {r0_0.x, r0_0.y, r0_0.z}, v_5), dot_0(float3 {r1_0.x, r1_0.y, r1_0.z}, v_5), dot_0(float3 {r2_0.x, r2_0.y, r2_0.z}, v_5));
}

static __device__ float3  world_mul_0(Quat_0 * q_10, float4  r0_1, float4  r1_1, float4  r2_1, float3  v_6)
{
    float3  _S530 = inverse_rotate_0(q_10, v_6);
    float3  _S531 = rotate_0(q_10, rows_mul_0(r0_1, r1_1, r2_1, _S530));
    return _S531;
}

static __device__ float4  turn_minus_one_0(float3  axis_3, float angle_1)
{
    float s_1 = (F32_sin((0.25f * angle_1)));
    return make_float4 ((axis_3 * make_float3 ((F32_sin((0.5f * angle_1))))).x, (axis_3 * make_float3 ((F32_sin((0.5f * angle_1))))).y, (axis_3 * make_float3 ((F32_sin((0.5f * angle_1))))).z, -2.0f * s_1 * s_1);
}

static __device__ float4  quat_vec_0(Quat_0 * q_11)
{
    return make_float4 (q_11->x_12, q_11->y_4, q_11->z_0, q_11->w_1);
}

static __device__ void comp_add4_0(float4  * sum_2, float4  * err_2, float4  x_19)
{
    float4  t_3 = *sum_2 + x_19;
    float4  _S532 = abs_0(x_19);
    *err_2 = *err_2 + (_slang_select((abs_0(*sum_2)) >= _S532, *sum_2,x_19) - t_3 + _slang_select((abs_0(*sum_2)) >= _S532, x_19,*sum_2));
    *sum_2 = t_3;
    return;
}

static __device__ void quat_accumulate_0(Quat_0 * hi_1, float4  * lo_1, float4  x_20)
{
    Quat_0 _S533 = *hi_1;
    float4  _S534 = quat_vec_0(&_S533);
    float4  sum_3 = _S534;
    comp_add4_0(&sum_3, lo_1, x_20);
    float4  t_4 = sum_3 + *lo_1;
    *lo_1 = *lo_1 - (t_4 - sum_3);
    *hi_1 = quat_of_0(t_4);
    return;
}

static __device__ void turn_left_0(Quat_0 * hi_2, float4  * lo_2, float3  omega_0, float dt_2)
{
    float _S535 = length_0(omega_0);
    float angle_2 = _S535 * dt_2;
    if(angle_2 < 1.00000000317107685e-30f)
    {
        return;
    }
    float4  d_10 = turn_minus_one_0(omega_0 / make_float3 (_S535), angle_2);
    Quat_0 dq_0;
    (&dq_0)->x_12 = d_10.x;
    (&dq_0)->y_4 = d_10.y;
    (&dq_0)->z_0 = d_10.z;
    (&dq_0)->w_1 = d_10.w;
    Quat_0 _S536 = dq_0;
    Quat_0 _S537 = *hi_2;
    Quat_0 _S538 = quat_mul_0(&_S536, &_S537);
    Quat_0 _S539 = _S538;
    float4  _S540 = quat_vec_0(&_S539);
    quat_accumulate_0(hi_2, lo_2, _S540);
    return;
}

extern "C" __global__ void impactor_integrate()
{
    uint _S541 = 0U;
    uint _S542;
    float3  p_8;
    uint _S543 = __ballot_sync(4294967295U, true);
    uint ii_1 = blockIdx.x;
    uint tid_3 = threadIdx.x;
    uint _S544 = __ldg(&globalParams_0->params_0->impactor_count_0);
    bool _S545 = ii_1 >= _S544;
    uint _S546 = __ballot_sync(_S543, _S545);
    if(_S545)
    {
        return;
    }
    else
    {
        uint _S547 = __ballot_sync(_S543, true);
        _S541 = _S547;
    }
    uint _S548 = __ldg(&globalParams_0->params_0->halt_index_0);
    Island_0 * _S549 = (&(globalParams_0->islands_0)[_S548]);
    Impactor_0 imp_6 = *(&(globalParams_0->impactors_0)[ii_1]);
    uint4  _S550 = _S549->info_1;
    bool _S551 = ((_S549->info_1.z) & 1U) != 0U;
    uint _S552 = __ballot_sync(_S541, _S551);
    bool _S553;
    uint k_8;
    if(_S551)
    {
        uint _S554 = __ballot_sync(_S541, true);
        _S553 = true;
        k_8 = _S554;
    }
    else
    {
        uint _S555 = _S541 & (~_S552);
        uint _S556 = _S550.y;
        bool _S557 = _S556 != 0U;
        uint _S558 = __ballot_sync(_S555, _S557);
        if(_S557)
        {
            bool _S559 = ((&imp_6)->cand_0.w) >= _S556;
            uint _S560 = __ballot_sync(_S555, true);
            _S553 = _S559;
        }
        else
        {
            uint _S561 = __ballot_sync(_S555, true);
            _S553 = false;
        }
        uint _S562 = __ballot_sync(_S541, true);
        k_8 = _S562;
    }
    uint _S563 = 0U;
    uint _S564 = __ballot_sync(k_8, _S553);
    if(_S553)
    {
        return;
    }
    else
    {
        uint _S565 = __ballot_sync(k_8, true);
        _S563 = _S565;
    }
    uint _S566 = 0U;
    bool _S567 = ((&imp_6)->cand_0.z) != 0U;
    uint _S568 = __ballot_sync(_S563, _S567);
    if(_S567)
    {
        if(tid_3 == 0U)
        {
            *&((&(&(globalParams_0->impactors_0)[ii_1])->cand_0)->w) = (&imp_6)->cand_0.w + 1U;
        }
        return;
    }
    else
    {
        uint _S569 = __ballot_sync(_S563, true);
        _S566 = _S569;
    }
    float4  _S570 = make_float4 (0.0f);
    float4  rf_0 = _S570;
    float4  rt_0 = _S570;
    k_8 = (&imp_6)->cand_0.x + tid_3;
    uint total_points_0;
    total_points_0 = _S566;
    for(;;)
    {
        bool _S571 = k_8 < ((&imp_6)->cand_0.y);
        uint _S572 = __ballot_sync(total_points_0, _S571);
        if(_S571)
        {
            uint _S573 = __ballot_sync(total_points_0, true);
        }
        else
        {
            uint _S574 = __ballot_sync(total_points_0, false);
            uint _S575 = __ballot_sync(total_points_0, false);
            uint _S576 = __ballot_sync(_S566, true);
            _S542 = _S576;
            break;
        }
        uint _S577 = __ldg(&globalParams_0->params_0->cand_base_0);
        uint _S578 = 3U * k_8;
        rf_0 = rf_0 + *(&(globalParams_0->scratch_0)[_S577 + _S578 + 1U]);
        uint _S579 = __ldg(&globalParams_0->params_0->cand_base_0);
        rt_0 = rt_0 + *(&(globalParams_0->scratch_0)[_S579 + _S578 + 2U]);
        uint _S580 = __ballot_sync(total_points_0, true);
        k_8 = k_8 + 256U;
        total_points_0 = _S580;
    }
    group_sum2_0(tid_3, &rf_0, &rt_0, _S542);
    bool _S581 = tid_3 != 0U;
    uint _S582 = __ballot_sync(_S542, _S581);
    if(_S581)
    {
        return;
    }
    float _S583 = __ldg(&globalParams_0->params_0->dt_0);
    float3  _S584 = make_float3 (0.0f);
    uint _S585 = __ldg(&globalParams_0->params_0->has_ground_0);
    float3  load_f_0;
    float3  load_t_0;
    if(_S585 != 0U)
    {
        float4  _S586 = (&imp_6)->half_1;
        float3  _S587 = float3 {_S586.x, _S586.y, _S586.z};
        Impactor_0 _S588 = imp_6;
        Box_0 _S589 = impactor_box_0(&_S588, _S584, _S587);
        float4  _S590 = (&imp_6)->velocity_1;
        float4  _S591 = (&imp_6)->velocity_err_1;
        float3  _S592 = float3 {_S590.x, _S590.y, _S590.z} + float3 {_S591.x, _S591.y, _S591.z};
        float _S593 = __ldg(&globalParams_0->params_0->ground_modulus_0);
        float _S594 = (&imp_6)->mat_0.x;
        float3  _S595 = make_float3 (0.0f, 0.0f, 1.0f);
        Box_0 _S596 = _S589;
        Box_0 _S597 = _S589;
        float _S598 = contact_stiffness_0(_S593, &_S596, _S594, &_S597, _S595);
        float _S599 = (&imp_6)->position_1.z;
        float _S600 = __ldg(&globalParams_0->params_0->ground_hi_0);
        float _S601 = _S599 - _S600;
        float _S602 = (&imp_6)->position_err_1.z;
        float _S603 = __ldg(&globalParams_0->params_0->ground_lo_0);
        float _S604 = _S601 + (_S602 - _S603);
        if(((&imp_6)->shape_0.x) == 0.0f)
        {
            total_points_0 = 1U;
        }
        else
        {
            total_points_0 = 14U;
        }
        float _S605 = _S598 / float((U32_min((total_points_0), (5U))));
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
                Box_0 _S606 = _S589;
                float3  _S607 = sample_point_0(&_S606, s_2);
                p_8 = _S607;
            }
            if((_S604 + p_8.z) < 0.0f)
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
        load_f_0 = _S584;
        load_t_0 = _S584;
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
                Box_0 _S608 = _S589;
                float3  _S609 = sample_point_0(&_S608, s_2);
                p_8 = _S609;
            }
            float depth_3 = - (_S604 + p_8.z);
            if(depth_3 <= 0.0f)
            {
                s_2 = s_2 + 1U;
                continue;
            }
            float4  _S610 = (&imp_6)->angular_velocity_1;
            float3  v_7 = _S592 + cross_0(float3 {_S610.x, _S610.y, _S610.z}, p_8);
            float _S611 = (&imp_6)->mat_0.z;
            float _S612 = __ldg(&globalParams_0->params_0->ground_friction_0);
            float stored_3;
            float diss_2;
            float3  f_3 = penalty_force_0(_S605, _S611, _S612, depth_3, _S595, v_7, _S583, below_0, &stored_3, &diss_2);
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
        load_f_0 = _S584;
        load_t_0 = _S584;
    }
    float4  _S613 = rf_0;
    float3  load_f_2 = float3 {_S613.x, _S613.y, _S613.z} + load_f_0;
    float4  _S614 = rt_0;
    float3  load_t_2 = float3 {_S614.x, _S614.y, _S614.z} + load_t_0;
    float m_2 = (&imp_6)->mat_0.z;
    float4  _S615 = (&imp_6)->velocity_1;
    float3  vel_0 = float3 {_S615.x, _S615.y, _S615.z};
    float4  _S616 = (&imp_6)->velocity_err_1;
    float3  vel_err_0 = float3 {_S616.x, _S616.y, _S616.z};
    float3  _S617 = load_f_2 / make_float3 (m_2);
    float4  _S618 = __ldg(&globalParams_0->params_0->gravity_0);
    comp_add_0(&vel_0, &vel_err_0, (_S617 + float3 {_S618.x, _S618.y, _S618.z}) * make_float3 (_S583));
    Quat_0 _S619 = quat_of_0((&imp_6)->rotation_1);
    Quat_0 q_12 = _S619;
    float4  q_err_0 = (&imp_6)->rotation_err_1;
    float4  _S620 = (&imp_6)->momentum_1;
    float3  l_hi_0 = float3 {_S620.x, _S620.y, _S620.z};
    float4  _S621 = (&imp_6)->momentum_err_1;
    float3  l_err_0 = float3 {_S621.x, _S621.y, _S621.z};
    comp_add_0(&l_hi_0, &l_err_0, load_t_2 * make_float3 (_S583));
    float3  l_1 = l_hi_0 + l_err_0;
    Quat_0 _S622 = _S619;
    float3  _S623 = world_mul_0(&_S622, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    float4  _S624 = (&imp_6)->position_1;
    float3  pos_0 = float3 {_S624.x, _S624.y, _S624.z};
    float4  _S625 = (&imp_6)->position_err_1;
    float3  pos_err_0 = float3 {_S625.x, _S625.y, _S625.z};
    comp_add_0(&pos_0, &pos_err_0, (vel_0 + vel_err_0) * make_float3 (_S583));
    turn_left_0(&q_12, &q_err_0, _S623, _S583);
    Quat_0 _S626 = q_12;
    float3  _S627 = world_mul_0(&_S626, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    (&imp_6)->angular_velocity_1 = make_float4 (_S627.x, _S627.y, _S627.z, 0.0f);
    Quat_0 _S628 = q_12;
    float4  _S629 = quat_vec_0(&_S628);
    (&imp_6)->rotation_1 = _S629;
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
    uint _S630 = (&imp_6)->cand_0.w - 1U;
    uint _S631 = __ldg(&globalParams_0->params_0->step_start_0);
    uint k_9 = _S630 - _S631;
    uint _S632 = __ldg(&globalParams_0->params_0->record_stride_0);
    if(k_9 < _S632)
    {
        uint _S633 = __ldg(&globalParams_0->params_0->record_base_0);
        uint _S634 = __ldg(&globalParams_0->params_0->record_stride_0);
        uint at_3 = _S633 + 2U * (ii_1 * _S634 + k_9);
        *(&(globalParams_0->scratch_0)[at_3]) = make_float4 ((vel_0 + vel_err_0).x, (vel_0 + vel_err_0).y, (vel_0 + vel_err_0).z, 0.0f);
        *(&(globalParams_0->scratch_0)[at_3 + 1U]) = make_float4 ((pos_0 + pos_err_0).x, (pos_0 + pos_err_0).y, (pos_0 + pos_err_0).z, 0.0f);
    }
    return;
}

static __device__ void ground_contact_0(uint c_6, bool account_0, float3  * f_4, float3  * t_5)
{
    ChunkStatic_0 * _S635 = (&(globalParams_0->chunks_0)[c_6]);
    WorldPoint_0 wp_1 = chunk_world_0(c_6);
    float _S636 = wp_1.hi_0.z;
    float _S637 = __ldg(&globalParams_0->params_0->ground_hi_0);
    float _S638 = _S636 - _S637;
    float _S639 = wp_1.lo_0.z;
    float _S640 = __ldg(&globalParams_0->params_0->ground_lo_0);
    float above_0 = _S638 + (_S639 - _S640) + wp_1.rel_0.z;
    float4  _S641 = __ldg(&_S635->half_0);
    if((above_0 - _S641.w) > 0.0f)
    {
        return;
    }
    Box_0 b_21 = chunk_box_0(c_6, make_float3 (0.0f));
    float _S642 = __ldg(&globalParams_0->params_0->ground_modulus_0);
    float4  _S643 = __ldg(&_S635->cmat_0);
    float _S644 = _S643.x;
    float3  _S645 = make_float3 (0.0f, 0.0f, 1.0f);
    Box_0 _S646 = b_21;
    Box_0 _S647 = b_21;
    float _S648 = contact_stiffness_0(_S642, &_S646, _S644, &_S647, _S645);
    Box_0 _S649 = b_21;
    uint _S650 = sample_count_0(&_S649);
    uint s_3 = 0U;
    uint n_7 = 0U;
    for(;;)
    {
        if(s_3 < _S650)
        {
        }
        else
        {
            break;
        }
        Box_0 _S651 = b_21;
        float3  _S652 = sample_point_0(&_S651, s_3);
        if((above_0 + _S652.z) < 0.0f)
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
    uint _S653 = __ldg(&globalParams_0->params_0->ledger_base_0);
    uint _S654 = __ldg(&globalParams_0->params_0->pair_count_0);
    float4  ledger_2 = *(&(globalParams_0->scratch_0)[_S653 + _S654 + c_6]);
    s_3 = 0U;
    for(;;)
    {
        if(s_3 < _S650)
        {
        }
        else
        {
            break;
        }
        Box_0 _S655 = b_21;
        float3  _S656 = sample_point_0(&_S655, s_3);
        float _S657 = above_0 + _S656.z;
        if(!(_S657 < 0.0f))
        {
            s_3 = s_3 + 1U;
            continue;
        }
        float depth_4 = - _S657;
        float3  v_8 = vc_1 + cross_0(wc_1, _S656);
        float _S658 = _S648 / float((U32_max((n_7), (5U))));
        float4  _S659 = __ldg(&_S635->center_0);
        float _S660 = _S659.w;
        float _S661 = __ldg(&globalParams_0->params_0->ground_friction_0);
        float _S662 = __ldg(&globalParams_0->params_0->dt_0);
        float stored_4;
        float diss_3;
        float3  g_0 = penalty_force_0(_S658, _S660, _S661, depth_4, _S645, v_8, _S662, n_7, &stored_4, &diss_3);
        *f_4 = *f_4 + g_0;
        *t_5 = *t_5 + cross_0(_S656, g_0);
        comp_add1_0(&((&ledger_2)->y), &((&ledger_2)->z), diss_3);
        s_3 = s_3 + 1U;
    }
    if(account_0)
    {
        uint _S663 = __ldg(&globalParams_0->params_0->ledger_base_0);
        uint _S664 = __ldg(&globalParams_0->params_0->pair_count_0);
        *(&(globalParams_0->scratch_0)[_S663 + _S664 + c_6]) = ledger_2;
    }
    return;
}

extern "C" __global__ void contact_sums()
{
    uint g_1 = (blockIdx * blockDim + threadIdx).x;
    uint _S665 = __ldg(&globalParams_0->params_0->seg_count_0);
    bool _S666;
    if(g_1 >= _S665)
    {
        _S666 = true;
    }
    else
    {
        _S666 = stopped_0();
    }
    if(_S666)
    {
        return;
    }
    uint _S667 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S668 = 3U * g_1;
    uint _S669 = __ldg((&(globalParams_0->index_0)[_S667 + _S668]));
    uint _S670 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S671 = __ldg((&(globalParams_0->index_0)[_S670 + _S668 + 1U]));
    uint _S672 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S673 = __ldg((&(globalParams_0->index_0)[_S672 + _S668 + 2U]));
    float3  _S674 = make_float3 (0.0f);
    float3  f_5 = _S674;
    float3  t_6 = _S674;
    uint e_2 = _S671;
    for(;;)
    {
        if(e_2 < _S673)
        {
        }
        else
        {
            break;
        }
        uint _S675 = __ldg((&(globalParams_0->index_0)[e_2]));
        if(_S675 == 2147483648U)
        {
            ground_contact_0(_S669, true, &f_5, &t_6);
            e_2 = e_2 + 1U;
            continue;
        }
        uint _S676 = __ldg(&globalParams_0->params_0->slot_base_0);
        uint _S677 = 2U * _S675;
        float4  _S678 = *(&(globalParams_0->scratch_0)[_S676 + _S677]);
        f_5 = f_5 + float3 {_S678.x, _S678.y, _S678.z};
        uint _S679 = __ldg(&globalParams_0->params_0->slot_base_0);
        float4  _S680 = *(&(globalParams_0->scratch_0)[_S679 + _S677 + 1U]);
        t_6 = t_6 + float3 {_S680.x, _S680.y, _S680.z};
        e_2 = e_2 + 1U;
    }
    uint _S681 = __ldg(&globalParams_0->params_0->seg_base_0);
    uint _S682 = 2U * g_1;
    *(&(globalParams_0->scratch_0)[_S681 + _S682]) = make_float4 (f_5.x, f_5.y, f_5.z, 0.0f);
    uint _S683 = __ldg(&globalParams_0->params_0->seg_base_0);
    *(&(globalParams_0->scratch_0)[_S683 + _S682 + 1U]) = make_float4 (t_6.x, t_6.y, t_6.z, 0.0f);
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
    uint _S684 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint4  _S685 = (&(globalParams_0->islands_0)[_S684])->info_1;
    bool _S686;
    if((((&(globalParams_0->islands_0)[_S684])->info_1.z) & 1U) != 0U)
    {
        _S686 = true;
    }
    else
    {
        uint _S687 = _S685.y;
        if(_S687 != 0U)
        {
            _S686 = _S687 <= (isl_0->info_1.w);
        }
        else
        {
            _S686 = false;
        }
    }
    return _S686;
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
    float4  _S688 = isl_1->position_0;
    (&rg_0)->pos_1 = float3 {_S688.x, _S688.y, _S688.z};
    float4  _S689 = isl_1->position_err_0;
    (&rg_0)->pos_err_1 = float3 {_S689.x, _S689.y, _S689.z};
    float4  _S690 = isl_1->velocity_0;
    (&rg_0)->vel_1 = float3 {_S690.x, _S690.y, _S690.z};
    float4  _S691 = isl_1->velocity_err_0;
    (&rg_0)->vel_err_1 = float3 {_S691.x, _S691.y, _S691.z};
    float4  _S692 = isl_1->angular_velocity_0;
    (&rg_0)->w_4 = float3 {_S692.x, _S692.y, _S692.z};
    float4  _S693 = isl_1->momentum_0;
    (&rg_0)->l_2 = float3 {_S693.x, _S693.y, _S693.z};
    float4  _S694 = isl_1->momentum_err_0;
    (&rg_0)->l_err_1 = float3 {_S694.x, _S694.y, _S694.z};
    float3  _S695 = make_float3 (0.0f);
    (&rg_0)->torque_0 = _S695;
    (&rg_0)->a_7 = _S695;
    (&rg_0)->alpha_0 = _S695;
    return rg_0;
}

static __device__ float time_since_0(float4  origin_0, uint k_10, float dt_3)
{
    float _S696 = __ldg(&globalParams_0->params_0->t_hi_0);
    float _S697 = _S696 - origin_0.x;
    float _S698 = __ldg(&globalParams_0->params_0->t_lo_0);
    return _S697 + (_S698 - origin_0.y) + float(k_10) * dt_3;
}

static __device__ float table_eval_0(uint offset_0, uint count_2, float tau_0)
{
    float4  _S699 = __ldg((&(globalParams_0->loads_0)[offset_0]));
    if(tau_0 <= (_S699.x))
    {
        return _S699.y;
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
        uint _S700 = offset_0 + i_10;
        float4  _S701 = __ldg((&(globalParams_0->loads_0)[_S700]));
        float _S702 = _S701.x;
        if(tau_0 <= _S702)
        {
            float4  _S703 = __ldg((&(globalParams_0->loads_0)[_S700 - 1U]));
            float _S704 = _S703.x;
            float _S705 = _S703.y;
            return _S705 + (tau_0 - _S704) / (F32_max((_S702 - _S704), (1.00000000317107685e-30f))) * (_S701.y - _S705);
        }
        i_10 = i_10 + 1U;
    }
    float4  _S706 = __ldg((&(globalParams_0->loads_0)[offset_0 + count_2 - 1U]));
    return _S706.y;
}

static __device__ float eval_function_0(uint term_0, uint k_11, float dt_4, float shift_0)
{
    uint _S707 = 5U * term_0;
    float4  _S708 = __ldg((&(globalParams_0->loads_0)[_S707]));
    uint4  info_2 = asuint_0(_S708);
    float4  _S709 = __ldg((&(globalParams_0->loads_0)[_S707 + 3U]));
    float4  _S710 = __ldg((&(globalParams_0->loads_0)[_S707 + 4U]));
    uint kind_0 = info_2.z;
    if(kind_0 == 0U)
    {
        return _S709.z;
    }
    float tau_1 = time_since_0(_S709, k_11, dt_4) + shift_0;
    float shape_1;
    if(kind_0 == 1U)
    {
        if(tau_1 <= 0.0f)
        {
            shape_1 = 0.0f;
        }
        else
        {
            float _S711 = _S710.x;
            if(tau_1 >= _S711)
            {
                shape_1 = _S710.y;
            }
            else
            {
                shape_1 = _S710.y * tau_1 / _S711;
            }
        }
        return shape_1;
    }
    bool _S712;
    if(kind_0 == 2U)
    {
        if(tau_1 < 0.0f)
        {
            _S712 = true;
        }
        else
        {
            _S712 = tau_1 > (_S710.x);
        }
        if(_S712)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S710.y * (F32_sin((3.14159274101257324f * tau_1 / _S710.x)));
        }
        return shape_1;
    }
    if(kind_0 == 3U)
    {
        float sn_0 = tau_1 / _S710.y;
        if(sn_0 < 0.0f)
        {
            _S712 = true;
        }
        else
        {
            _S712 = sn_0 > 1.0f;
        }
        if(_S712)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S710.x * (1.0f - sn_0) * (F32_exp((- _S710.z * sn_0)));
        }
        return shape_1;
    }
    if(kind_0 == 4U)
    {
        return table_eval_0(info_2.w, (F32_asuint((_S710.x))), tau_1);
    }
    if(kind_0 == 5U)
    {
        (*&g_seen_0)[1U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float sn_1 = tau_1 / _S710.x;
        if(sn_1 < 0.0f)
        {
            _S712 = true;
        }
        else
        {
            _S712 = sn_1 > 1.0f;
        }
        if(_S712)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = (1.0f - sn_1) * (F32_exp((- _S710.y * sn_1)));
        }
        float clearing_0 = _S709.w;
        float relax_0;
        if(clearing_0 > 0.0f)
        {
            relax_0 = (F32_max((1.0f - tau_1 / clearing_0), (0.0f)));
        }
        else
        {
            relax_0 = 0.0f;
        }
        float _S713 = _S710.w;
        return (_S713 + (_S710.z - _S713) * relax_0) * shape_1;
    }
    if(kind_0 == 7U)
    {
        (*&g_seen_0)[2U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float _S714 = _S710.y;
        if(tau_1 < _S714)
        {
            return _S710.x;
        }
        float s_4 = tau_1 - _S714;
        float _S715 = _S710.w;
        if(s_4 > _S715)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S710.z * (F32_sin((3.14159274101257324f * s_4 / _S715)));
        }
        return shape_1;
    }
    float _S716 = _S710.x;
    if(_S716 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp_0(1.0f - tau_1 / _S716, 0.0f, 1.0f);
}

static __device__ void record_chunk_load_0(uint c_7, float3  f_6, float3  t_7)
{
    uint _S717 = __ldg(&globalParams_0->params_0->solve_mode_0);
    if(_S717 == 0U)
    {
        return;
    }
    uint _S718 = __ldg(&globalParams_0->params_0->cload_base_0);
    uint _S719 = 2U * c_7;
    *(&(globalParams_0->scratch_0)[_S718 + _S719]) = make_float4 (f_6.x, f_6.y, f_6.z, 0.0f);
    uint _S720 = __ldg(&globalParams_0->params_0->cload_base_0);
    *(&(globalParams_0->scratch_0)[_S720 + _S719 + 1U]) = make_float4 (t_7.x, t_7.y, t_7.z, 0.0f);
    uint _S721 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  * _S722 = (&(globalParams_0->scratch_0)[_S721 + _S719]);
    uint _S723 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  _S724 = *(&(globalParams_0->scratch_0)[_S723 + _S719]);
    *_S722 = make_float4 ((float3 {_S724.x, _S724.y, _S724.z} + f_6).x, (float3 {_S724.x, _S724.y, _S724.z} + f_6).y, (float3 {_S724.x, _S724.y, _S724.z} + f_6).z, 0.0f);
    uint _S725 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  * _S726 = (&(globalParams_0->scratch_0)[_S725 + _S719 + 1U]);
    uint _S727 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  _S728 = *(&(globalParams_0->scratch_0)[_S727 + _S719 + 1U]);
    *_S726 = make_float4 ((float3 {_S728.x, _S728.y, _S728.z} + t_7).x, (float3 {_S728.x, _S728.y, _S728.z} + t_7).y, (float3 {_S728.x, _S728.y, _S728.z} + t_7).z, 0.0f);
    return;
}

static __device__ void chunk_loads_0(uint _S729, uint _S730, Quat_0 * _S731, uint _S732, float _S733, bool _S734, float _S735, float3  * _S736, float3  * _S737, float3  * _S738, float3  * _S739)
{
    bool _S740;
    ChunkStatic_0 * _S741 = (&(globalParams_0->chunks_0)[_S730]);
    float3  _S742 = make_float3 (0.0f);
    *_S736 = _S742;
    *_S737 = _S742;
    *_S738 = _S742;
    *_S739 = _S742;
    uint4  _S743 = __ldg(&_S741->load_range_0);
    uint term_1 = _S743.x;
    for(;;)
    {
        if(term_1 < (_S743.y))
        {
        }
        else
        {
            break;
        }
        (*&g_seen_0)[0U] = 1U;
        uint _S744 = 5U * term_1;
        float4  _S745 = __ldg((&(globalParams_0->loads_0)[_S744]));
        uint _S746 = asuint_0(_S745).y;
        bool replacement_0 = _S746 == 2U;
        float4  _S747 = __ldg((&(globalParams_0->loads_0)[_S744 + 1U]));
        float4  _S748 = __ldg((&(globalParams_0->loads_0)[_S744 + 2U]));
        float _S749;
        if(replacement_0)
        {
            _S749 = _S735;
        }
        else
        {
            _S749 = 0.0f;
        }
        float value_0 = eval_function_0(term_1, _S732, _S733, _S749);
        if(replacement_0)
        {
            *_S738 = *_S738 + float3 {_S747.x, _S747.y, _S747.z} * make_float3 (value_0);
            *_S739 = *_S739 + float3 {_S748.x, _S748.y, _S748.z} * make_float3 (value_0);
            term_1 = term_1 + 1U;
            continue;
        }
        if(_S746 == 0U)
        {
            _S740 = true;
        }
        else
        {
            _S740 = _S746 == 3U;
        }
        float3  fw_0;
        if(_S740)
        {
            fw_0 = float3 {_S747.x, _S747.y, _S747.z} * make_float3 (value_0);
        }
        else
        {
            float3  _S750 = rotate_0(_S731, float3 {_S747.x, _S747.y, _S747.z});
            fw_0 = _S750 * make_float3 (- value_0 * _S747.w);
        }
        float3  lever_0;
        if(_S746 == 3U)
        {
            float4  _S751 = *(&(globalParams_0->state_0)[4U * _S729]);
            lever_0 = float3 {_S748.x, _S748.y, _S748.z} - float3 {_S751.x, _S751.y, _S751.z};
        }
        else
        {
            lever_0 = float3 {_S748.x, _S748.y, _S748.z};
        }
        *_S736 = *_S736 + fw_0;
        float3  _S752 = rotate_0(_S731, lever_0);
        *_S737 = *_S737 + cross_0(_S752, fw_0);
        term_1 = term_1 + 1U;
    }
    if(_S734)
    {
        uint4  _S753 = __ldg(&_S741->cinfo_0);
        _S740 = (_S753.z) != 0U;
    }
    else
    {
        _S740 = false;
    }
    if(_S740)
    {
        uint4  _S754 = __ldg(&_S741->cinfo_0);
        uint g_2 = _S754.x;
        for(;;)
        {
            if(g_2 < (_S754.y))
            {
            }
            else
            {
                break;
            }
            uint _S755 = __ldg(&globalParams_0->params_0->seg_base_0);
            uint _S756 = 2U * g_2;
            float4  _S757 = *(&(globalParams_0->scratch_0)[_S755 + _S756]);
            *_S736 = *_S736 + float3 {_S757.x, _S757.y, _S757.z};
            uint _S758 = __ldg(&globalParams_0->params_0->seg_base_0);
            float4  _S759 = *(&(globalParams_0->scratch_0)[_S758 + _S756 + 1U]);
            *_S737 = *_S737 + float3 {_S759.x, _S759.y, _S759.z};
            g_2 = g_2 + 1U;
        }
    }
    return;
}

static __device__ void chunk_external_0(uint _S760, uint _S761, Quat_0 * _S762, uint _S763, float _S764, bool _S765, float3  * _S766, float3  * _S767)
{
    float3  rf_1;
    float3  rm_0;
    chunk_loads_0(_S760, _S761, _S762, _S763, _S764, _S765, 0.0f, _S766, _S767, &rf_1, &rm_0);
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
    ChunkStatic_0 * _S768 = (&(globalParams_0->chunks_0)[c_9]);
    float3  fl_0;
    float3  tl_0;
    float3  rep_f_0;
    float3  rep_m_0;
    chunk_loads_0(c_9, c_9, &rg_1->rot_0, k_13, dt_6, contact_1, 0.0f, &fl_0, &tl_0, &rep_f_0, &rep_m_0);
    float3  _S769 = fl_0;
    float4  _S770 = __ldg(&globalParams_0->params_0->gravity_0);
    float3  _S771 = float3 {_S770.x, _S770.y, _S770.z};
    float4  _S772 = __ldg(&_S768->center_0);
    float3  fc_0 = _S769 + _S771 * make_float3 (_S772.w);
    float3  _S773 = float3 {_S772.x, _S772.y, _S772.z};
    float4  _S774 = *(&(globalParams_0->state_0)[4U * c_9]);
    float4  _S775 = isl_2->com_0;
    float3  _S776 = float3 {_S775.x, _S775.y, _S775.z};
    float3  _S777 = rotate_0(&rg_1->rot_0, _S773 + float3 {_S774.x, _S774.y, _S774.z} - _S776);
    *f_8 = *f_8 + fc_0;
    *t_9 = *t_9 + (cross_0(_S777, fc_0) + tl_0);
    uint4  _S778 = __ldg(&_S768->load_range_0);
    if((_S778.y) > (_S778.x))
    {
        float3  _S779 = rotate_0(&rg_1->rot_0, rep_f_0);
        *f_8 = *f_8 + _S779;
        float3  _S780 = rotate_0(&rg_1->rot_0, _S773 - _S776);
        float3  _S781 = cross_0(_S780, _S779);
        float3  _S782 = rotate_0(&rg_1->rot_0, rep_m_0);
        *t_9 = *t_9 + (_S781 + _S782);
    }
    return;
}

static __device__ void rigid_acceleration_0(Island_0 * isl_3, Rigid_0 * rg_2, float3  f_9, float3  t_10)
{
    Quat_0 _S783 = rg_2->rot_0;
    float3  _S784 = world_mul_0(&_S783, isl_3->inertia0_1, isl_3->inertia1_1, isl_3->inertia2_1, rg_2->w_4);
    rg_2->a_7 = f_9 / make_float3 (isl_3->com_0.w);
    float3  _S785 = t_10 - cross_0(rg_2->w_4, _S784);
    Quat_0 _S786 = rg_2->rot_0;
    float3  _S787 = world_mul_0(&_S786, isl_3->inv0_1, isl_3->inv1_1, isl_3->inv2_1, _S785);
    rg_2->alpha_0 = _S787;
    rg_2->torque_0 = t_10;
    return;
}

static __device__ JointBond_0 slang_ldg_0(JointBond_0 * ptr_0)
{
    float4  _S788 = __ldg(&ptr_0->geom0_0);
    float4  _S789 = __ldg(&ptr_0->geom1_0);
    float4  _S790 = __ldg(&ptr_0->stiff0_0);
    float4  _S791 = __ldg(&ptr_0->stiff1_0);
    float4  _S792 = __ldg(&ptr_0->rebar0_0);
    float4  _S793 = __ldg(&ptr_0->rebar1_0);
    uint4  _S794 = __ldg(&ptr_0->ids_0);
    JointBond_0 _S795 = { _S788, _S789, _S790, _S791, _S792, _S793, _S794 };
    return _S795;
}

static __device__ bool is_damaged_0(JointState_0 * st_0)
{
    bool _S796;
    if((st_0->damage_0) > 0.0f)
    {
        _S796 = true;
    }
    else
    {
        _S796 = (st_0->crush_0) > 0.0f;
    }
    return _S796;
}

static __device__ bool connected_0(JointState_0 * st_1, bool has_rebar_0)
{
    bool _S797;
    if((st_1->damage_0) < 1.0f)
    {
        _S797 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S797 = (st_1->rebar_broken_0) == 0.0f;
        }
        else
        {
            _S797 = false;
        }
    }
    return _S797;
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
    float _S798 = q_lin_0.z;
    float axial_0 = fdiv_0(_S798, area_2);
    float bending_0 = fdiv_0((F32_abs((q_ang_0.x))), b_23->geom1_0.x) + fdiv_0((F32_abs((q_ang_0.y))), b_23->geom1_0.y);
    float _S799 = q_lin_0.x;
    float _S800 = q_lin_0.y;
    float shear_1 = fdiv_0(fsqrt_0(_S799 * _S799 + _S800 * _S800), area_2) + fdiv_0((F32_abs((q_ang_0.z))), b_23->geom0_0.w);
    Measures_0 m_3;
    (&m_3)->tension_0 = axial_0 + bending_0;
    (&m_3)->shear_0 = shear_1;
    float _S801 = - axial_0;
    (&m_3)->normal_compression_0 = (F32_max((_S801), (0.0f)));
    (&m_3)->compression_0 = _S801 + bending_0;
    (&m_3)->compressive_force_0 = (F32_max((- _S798), (0.0f)));
    return m_3;
}

static __device__ float expm1_accurate_0(float x_21)
{
    if((F32_abs((x_21))) < 0.00100000004749745f)
    {
        return x_21 * (1.0f + x_21 * (0.5f + x_21 * 0.1666666716337204f));
    }
    return (F32_exp((x_21))) - 1.0f;
}

static __device__ float fpow_0(float a_10, float b_24)
{
    return (F32_pow((a_10), (b_24)));
}

static __device__ float dif_factor_0(JointMaterial_0 * mat_1, float strain_rate_1)
{
    float r_5 = (F32_abs((strain_rate_1)));
    float4  _S802 = mat_1->dif_0;
    float ref_0 = mat_1->dif_0.x;
    if(r_5 <= ref_0)
    {
        return 1.0f;
    }
    float _S803 = _S802.z;
    float f_10;
    if(r_5 <= _S803)
    {
        f_10 = fpow_0(fdiv_0(r_5, ref_0), _S802.y);
    }
    else
    {
        f_10 = fpow_0(fdiv_0(_S803, ref_0), _S802.y) * fpow_0(fdiv_0(r_5, _S803), _S802.w);
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
    float _S804 = (F32_min((mat_3->strength_0.z * multiplier_0 + mat_3->strength_0.w * m_4->normal_compression_0), (mat_3->energy_0.x * multiplier_0)));
    float4  idx_0;
    *&((&idx_0)->x) = (F32_max((fdiv_0(m_4->tension_0, mat_3->strength_0.x * multiplier_0)), (0.0f)));
    float _S805;
    if(_S804 > 0.0f)
    {
        _S805 = fdiv_0(m_4->shear_0, _S804);
    }
    else
    {
        _S805 = infinity_0();
    }
    *&((&idx_0)->y) = _S805;
    *&((&idx_0)->z) = (F32_max((fdiv_0(m_4->compression_0, fc_1)), (0.0f)));
    float _S806 = b_25->stiff1_0.y;
    if(_S806 > 0.0f)
    {
        _S805 = fdiv_0(m_4->compressive_force_0, _S806);
    }
    else
    {
        _S805 = 0.0f;
    }
    *&((&idx_0)->w) = _S805;
    return idx_0;
}

static __device__ float sq_0(float x_22)
{
    return x_22 * x_22;
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
    float _S807 = (F32_max((damage_law_0(kind_2, lambda_0, r_7)), (d_old_0)));
    bool _S808;
    if(_S807 <= d_old_0)
    {
        _S808 = true;
    }
    else
    {
        _S808 = d_old_0 >= 1.0f;
    }
    if(_S808)
    {
        return make_float2 (d_old_0, 0.0f);
    }
    float u0_0 = fdiv_0(psi_0, lambda_0 * lambda_0);
    float _S809 = (F32_max((kappa_old_0), (1.0f)));
    if(kind_2 == 0U)
    {
        if(r_7 > 1.0f)
        {
            return make_float2 (_S807, fdiv_0(u0_0 * r_7, r_7 - 1.0f) * (F32_max(((F32_min((lambda_0), (r_7))) - (F32_min((_S809), (r_7)))), (0.0f))));
        }
        return make_float2 (_S807, (1.0f - d_old_0) * psi_0);
    }
    float ku_0 = 0.5f * (r_7 + 1.0f);
    float plateau_0 = u0_0 * (F32_max(((F32_min((lambda_0), (ku_0))) - (F32_min((_S809), (ku_0)))), (0.0f)));
    float snap_0;
    if(_S807 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return make_float2 (_S807, plateau_0 + snap_0);
}

static __device__ void compressed_region_0(float w0_0, float w1_0, float dz_0, float ax_0, float ay_0, FixedArray<float, 6>  * region_0)
{
    uint count_3;
    float h0_0 = 0.5f * w0_0;
    float h1_0 = 0.5f * w1_0;
    float _S810 = - h0_0;
    float _S811 = - h1_0;
    FixedArray<float2 , 4>  _S812 = { {
        float2 {
            _S810, _S811
        }, float2 {
            h0_0, _S811
        }, float2 {
            h0_0, h1_0
        }, float2 {
            _S810, h1_0
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
        uint _S813 = i_11;
        uint _S814 = i_11 + 1U;
        uint _S815 = _S814 % 4U;
        float _S816 = _S812[i_11].y;
        float _S817 = _S812[i_11].x;
        float fp_0 = dz_0 + ax_0 * _S816 - ay_0 * _S817;
        float _S818 = _S812[_S815].y;
        float _S819 = _S812[_S815].x;
        float fq_0 = dz_0 + ax_0 * _S818 - ay_0 * _S819;
        bool _S820 = fp_0 < 0.0f;
        if(_S820)
        {
            uint _S821 = count_4 + 1U;
            poly_0[count_4] = _S812[_S813];
            count_3 = _S821;
        }
        else
        {
            count_3 = count_4;
        }
        if(_S820 != (fq_0 < 0.0f))
        {
            float t_11 = fp_0 / (fp_0 - fq_0);
            uint _S822 = count_3 + 1U;
            poly_0[count_3] = make_float2 (_S817 + t_11 * (_S819 - _S817), _S816 + t_11 * (_S818 - _S816));
            count_4 = _S822;
        }
        else
        {
            count_4 = count_3;
        }
        i_11 = _S814;
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
        float _S823 = o_1.x;
        float x0_0 = poly_0[i_11].x - _S823;
        float _S824 = o_1.y;
        float y0_0 = poly_0[i_11].y - _S824;
        uint _S825 = i_11 + 1U;
        uint _S826 = _S825 % count_4;
        float x1_0 = poly_0[_S826].x - _S823;
        float y1_0 = poly_0[_S826].y - _S824;
        float _S827 = x0_0 * y1_0;
        float _S828 = x1_0 * y0_0;
        float cr_0 = _S827 - _S828;
        float a_12 = a_11 + cr_0 / 2.0f;
        float sx_1 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        float sy_1 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        float ixx_1 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        float iyy_1 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        float ixy_1 = ixy_0 + (_S827 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S828) * cr_0 / 24.0f;
        i_11 = _S825;
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
    float _S829 = a_11 * cx_0;
    (*region_0)[int(3)] = ixx_0 - _S829 * cx_0;
    (*region_0)[int(4)] = iyy_0 - a_11 * cy_0 * cy_0;
    (*region_0)[int(5)] = ixy_0 - _S829 * cy_0;
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
    float _S830 = a_13 * fc_2;
    float _S831 = - ay_1;
    return make_float4 (k_14 * a_13 * fc_2, k_14 * (_S830 * r_8[int(2)] + (_S831 * r_8[int(5)] + ax_1 * r_8[int(4)])), - k_14 * (_S830 * r_8[int(1)] + (_S831 * r_8[int(3)] + ax_1 * r_8[int(5)])), 0.5f * k_14 * (_S830 * fc_2 + ay_1 * ay_1 * r_8[int(3)] + ax_1 * ax_1 * r_8[int(4)] - 2.0f * ax_1 * ay_1 * r_8[int(5)]));
}

static __device__ float signum_0(float x_23)
{
    float _S832;
    if(((F32_asuint((x_23))) & 2147483648U) != 0U)
    {
        _S832 = -1.0f;
    }
    else
    {
        _S832 = 1.0f;
    }
    return _S832;
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
    float3  _S833 = make_float3 (0.0f);
    (&c_10)->q_lin_1 = _S833;
    (&c_10)->q_ang_1 = _S833;
    (&c_10)->energy_2 = 0.0f;
    (&c_10)->diss_4 = 0.0f;
    (&c_10)->plastic_1 = plastic_2;
    uint _S834 = mat_4->kind_flags_0.y;
    if((_S834 & 2U) == 0U)
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
    if((_S834 & 4U) != 0U)
    {
        float4  p_9 = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        float _S835 = p_9.y;
        float _S836 = p_9.z;
        float _S837 = p_9.w;
        nc_sum_0 = p_9.x;
        m1_0 = _S835;
        m2_0 = _S836;
        energy_3 = _S837;
    }
    else
    {
        float ki_0 = kn_1 * (1.0f - crush_2) / 36.0f;
        float _S838 = d_ang_0.x;
        float _S839 = d_ang_0.y;
        float spread_0 = (F32_abs((_S838))) * 0.4166666567325592f * w1_2 + (F32_abs((_S839))) * 0.4166666567325592f * w0_2;
        float _S840 = d_lin_0.z;
        float slack_0 = 9.99999997475242708e-07f * ((F32_abs((_S840))) + spread_0);
        if((_S840 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S840 + spread_0) < (- slack_0))
            {
                float i1_0 = 2.91666650772094727f * w0_2 * w0_2;
                float i2_0 = 2.91666650772094727f * w1_2 * w1_2;
                float _S841 = ki_0 * _S838 * i2_0;
                float _S842 = ki_0 * _S839 * i1_0;
                float _S843 = 0.5f * ki_0 * (36.0f * _S840 * _S840 + _S838 * _S838 * i2_0 + _S839 * _S839 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S840;
                m1_0 = _S841;
                m2_0 = _S842;
                energy_3 = _S843;
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
                    float _S844 = SPRING_AT_0[i_12] * w0_2;
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
                        float di_0 = _S840 + _S838 * s2_0 - _S839 * _S844;
                        if(di_0 < 0.0f)
                        {
                            float f_12 = ki_0 * di_0;
                            float m1_2 = m1_0 + f_12 * s2_0;
                            float m2_2 = m2_0 - f_12 * _S844;
                            float energy_5 = energy_3 + 0.5f * ki_0 * di_0 * di_0;
                            nc_sum_0 = nc_sum_0 + f_12;
                            m1_0 = m1_2;
                            m2_0 = m2_2;
                            energy_3 = energy_5;
                        }
                        j_5 = j_5 + 1U;
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
    float _S845 = ks_0 * (d_lin_0.x - plastic_2.x);
    float _S846 = ks_0 * (d_lin_0.y - plastic_2.y);
    float tn_0 = fsqrt_0(_S845 * _S845 + _S846 * _S846);
    bool _S847;
    if(tn_0 > slide_cap_0)
    {
        _S847 = tn_0 > 0.0f;
    }
    else
    {
        _S847 = false;
    }
    if(_S847)
    {
        float _S848 = fdiv_0(_S845, tn_0);
        float _S849 = fdiv_0(_S846, tn_0);
        float dslip_0 = fdiv_0(tn_0 - slide_cap_0, ks_0);
        *&((&p_10)->x) = *&((&p_10)->x) + _S848 * dslip_0;
        *&((&p_10)->y) = *&((&p_10)->y) + _S849 * dslip_0;
        *&((&(&c_10)->q_lin_1)->x) = _S848 * slide_cap_0;
        *&((&(&c_10)->q_lin_1)->y) = _S849 * slide_cap_0;
        diss_5 = slide_cap_0 * dslip_0;
    }
    else
    {
        *&((&(&c_10)->q_lin_1)->x) = _S845;
        *&((&(&c_10)->q_lin_1)->y) = _S846;
        diss_5 = 0.0f;
    }
    float2  tq_0 = return_map_0(kt_0, d_ang_0.z, p_10.z, slide_cap_0 * b_26->geom1_0.z);
    float _S850 = tq_0.x;
    float _S851 = tq_0.y;
    float diss_6 = diss_5 + (F32_abs((_S850))) * (F32_abs((_S851)));
    *&((&p_10)->z) = *&((&p_10)->z) + _S851;
    *&((&(&c_10)->q_ang_1)->z) = _S850;
    (&c_10)->energy_2 = energy_3 + 0.5f * (fdiv_0(sq_0((&c_10)->q_lin_1.x), ks_0) + fdiv_0(sq_0((&c_10)->q_lin_1.y), ks_0) + fdiv_0(sq_0(_S850), kt_0));
    (&c_10)->diss_4 = diss_6;
    (&c_10)->plastic_1 = p_10;
    return c_10;
}

static __device__ float3  contact_offsets_0(JointMaterial_0 * mat_5, JointBond_0 * b_27, float crush_3, float3  plastic_3, float3  d_lin_1, float3  d_ang_1)
{
    uint _S852 = mat_5->kind_flags_0.y;
    if((_S852 & 2U) == 0U)
    {
        return plastic_3;
    }
    float kn_2 = b_27->stiff0_0.x;
    float ks_1 = b_27->stiff0_0.y;
    float kt_1 = b_27->stiff1_0.x;
    float w0_3 = b_27->geom0_0.y;
    float w1_3 = b_27->geom0_0.z;
    float nc_sum_1;
    if((_S852 & 4U) != 0U)
    {
        float4  _S853 = no_tension_patch_0(kn_2 * (1.0f - crush_3), w0_3, w1_3, d_lin_1.z, d_ang_1.x, d_ang_1.y);
        nc_sum_1 = _S853.x;
    }
    else
    {
        float ki_1 = kn_2 * (1.0f - crush_3) / 36.0f;
        float _S854 = d_ang_1.x;
        float _S855 = d_ang_1.y;
        float spread_1 = (F32_abs((_S854))) * 0.4166666567325592f * w1_3 + (F32_abs((_S855))) * 0.4166666567325592f * w0_3;
        float _S856 = d_lin_1.z;
        float slack_1 = 9.99999997475242708e-07f * ((F32_abs((_S856))) + spread_1);
        if((_S856 - spread_1) > slack_1)
        {
            nc_sum_1 = 0.0f;
        }
        else
        {
            if((_S856 + spread_1) < (- slack_1))
            {
                nc_sum_1 = ki_1 * 36.0f * _S856;
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
                    float _S857 = SPRING_AT_0[i_13] * w0_3;
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
                        float di_1 = _S856 + _S854 * (SPRING_AT_0[j_6] * w1_3) - _S855 * _S857;
                        if(di_1 < 0.0f)
                        {
                            nc_sum_1 = nc_sum_1 + ki_1 * di_1;
                        }
                        j_6 = j_6 + 1U;
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
    float _S858 = ks_1 * (d_lin_1.x - plastic_3.x);
    float _S859 = ks_1 * (d_lin_1.y - plastic_3.y);
    float tn_1 = fsqrt_0(_S858 * _S858 + _S859 * _S859);
    bool _S860;
    if(tn_1 > slide_cap_1)
    {
        _S860 = tn_1 > 0.0f;
    }
    else
    {
        _S860 = false;
    }
    if(_S860)
    {
        float _S861 = fdiv_0(_S859, tn_1);
        float dslip_1 = fdiv_0(tn_1 - slide_cap_1, ks_1);
        *&((&p_11)->x) = *&((&p_11)->x) + fdiv_0(_S858, tn_1) * dslip_1;
        *&((&p_11)->y) = *&((&p_11)->y) + _S861 * dslip_1;
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
    float _S862 = mat_6->misc_0.y;
    return fdiv_0((_S862 + 1.0f) * fpow_0(s_5, _S862), mat_6->misc_0.z);
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
    float4  _S863 = b_28->stiff1_0;
    float kt_2 = b_28->stiff1_0.x;
    bool has_rebar_1 = (b_28->stiff1_0.w) != 0.0f;
    uint kind_3 = mat_7->kind_flags_0.x;
    uint flags_1 = mat_7->kind_flags_0.y;
    bool softening_0 = (flags_1 & 1U) != 0U;
    JointState_0 st_2 = *state_2;
    bool _S864 = connected_0(state_2, has_rebar_1);
    float3  qe_lin_0 = d_lin_2 * make_float3 (ks_2, ks_2, kn_3);
    float3  qe_ang_0 = d_ang_2 * make_float3 (kb1_0, kb2_0, kt_2);
    Measures_0 _S865 = stress_measures_0(b_28, qe_lin_0, qe_ang_0);
    float _S866 = (F32_max(((F32_max((_S865.tension_0), (_S865.shear_0)))), (_S865.compression_0)));
    bool _S867 = dt_7 > 0.0f;
    float dif_1;
    if(_S867)
    {
        float raw_0 = fdiv_0((F32_max((fdiv_0(_S866 - (&st_2)->governing_stress_0, dt_7)), (0.0f))), mat_7->misc_0.w);
        float tau_2 = _S863.z;
        if((flags_1 & 16U) != 0U)
        {
            dif_1 = - expm1_accurate_0(- fdiv_0(dt_7, tau_2));
        }
        else
        {
            dif_1 = (F32_min((fdiv_0(dt_7, tau_2)), (1.0f)));
        }
        (&st_2)->strain_rate_0 = (&st_2)->strain_rate_0 + (raw_0 - (&st_2)->strain_rate_0) * dif_1;
        (&st_2)->governing_stress_0 = _S866;
    }
    if((flags_1 & 32U) != 0U)
    {
        float _S868 = dif_factor_0(mat_7, (&st_2)->strain_rate_0);
        dif_1 = _S868;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = b_28->geom1_0.w;
    float _S869 = fatigue_factor_0(mat_7, (&st_2)->life_0);
    float multiplier_1 = weibull_0 * dif_1 * _S869;
    Measures_0 _S870 = _S865;
    float4  _S871 = failure_indices_0(mat_7, b_28, &_S870, multiplier_1);
    float _S872 = _S871.x;
    float _S873 = _S871.y;
    (&st_2)->utilization_0 = (F32_max(((F32_max((_S872), (_S873)))), ((F32_max((_S871.z), (_S871.w))))));
    float _S874 = d_lin_2.x;
    float _S875 = d_lin_2.y;
    float _S876 = ks_2 * (sq_0(_S874) + sq_0(_S875)) + kb1_0 * sq_0(d_ang_2.x) + kb2_0 * sq_0(d_ang_2.y) + kt_2 * sq_0(d_ang_2.z);
    float _S877 = d_lin_2.z;
    bool _S878 = _S877 > 0.0f;
    if(_S878)
    {
        dif_1 = kn_3 * sq_0(_S877);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S876 + dif_1);
    float psi_c_0;
    if(_S877 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_3 * sq_0(_S877);
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
    bool _S879;
    float3  qc_lin_0;
    if(fracture_1)
    {
        bool _S880 = _S872 >= _S873;
        if(_S880)
        {
            diss_contact_0 = _S872;
        }
        else
        {
            diss_contact_0 = _S873;
        }
        uint mode_ts_0;
        if(_S880)
        {
            mode_ts_0 = 1U;
        }
        else
        {
            mode_ts_0 = 2U;
        }
        if(diss_contact_0 > ((&st_2)->kappa_0))
        {
            _S879 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S879 = false;
        }
        if(_S879)
        {
            _S879 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S879 = false;
        }
        uint mode_c_0;
        if(_S879)
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
            float _S881 = inc_0.x;
            if(_S881 > ((&st_2)->damage_0))
            {
                Contact_0 _S882 = contact_part_0(mat_7, b_28, (&st_2)->crush_0, plastic_4, d_lin_2, d_ang_2);
                float _S883 = (F32_max((_S882.energy_2 - (1.0f - (&st_2)->crush_0) * psi_c_0), (0.0f)));
                float _S884 = (F32_max((inc_0.y - _S883 * (_S881 - (&st_2)->damage_0)), (0.0f)));
                float _S885 = (F32_max(((psi_ts_0 - _S883) * (_S881 - (&st_2)->damage_0) - _S884), (0.0f)));
                (&st_2)->damage_0 = _S881;
                (&st_2)->mode_0 = mode_ts_0;
                dissipated_3 = _S884;
                overshoot_1 = _S885;
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
        float _S886 = state_2->damage_0;
        if((state_2->damage_0) > 0.0f)
        {
            Contact_0 _S887 = contact_part_0(mat_7, b_28, state_2->crush_0, make_float3 (state_2->plastic_x_0, state_2->plastic_y_0, state_2->plastic_t_0), d_lin_2, d_ang_2);
            qc_lin_0 = qe_ang_0 * make_float3 (1.0f - _S886) + _S887.q_ang_1 * make_float3 (_S886);
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S888 = stress_measures_0(b_28, make_float3 (0.0f, 0.0f, (F32_min((qe_lin_0.z), (0.0f)))), qc_lin_0);
        Measures_0 _S889 = _S888;
        float4  _S890 = failure_indices_0(mat_7, b_28, &_S889, multiplier_1);
        float _S891 = _S890.z;
        float _S892 = _S890.w;
        bool _S893 = _S891 >= _S892;
        if(_S893)
        {
            psi_contact_0 = _S891;
        }
        else
        {
            psi_contact_0 = _S892;
        }
        if(_S893)
        {
            mode_c_0 = 3U;
        }
        else
        {
            mode_c_0 = 4U;
        }
        if(psi_contact_0 > ((&st_2)->kappa_c_0))
        {
            _S879 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S879 = false;
        }
        if(_S879)
        {
            _S879 = psi_c_0 > 0.0f;
        }
        else
        {
            _S879 = false;
        }
        if(_S879)
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
            float _S894 = inc_1.x;
            if(_S894 > ((&st_2)->crush_0))
            {
                float _S895 = inc_1.y;
                float dissipated_4 = dissipated_3 + _S895;
                float overshoot_2 = overshoot_1 + (F32_max((psi_c_0 * (_S894 - (&st_2)->crush_0) - _S895), (0.0f)));
                (&st_2)->crush_0 = _S894;
                (&st_2)->mode_0 = mode_c_0;
                if(_S894 >= 1.0f)
                {
                    _S879 = ((&st_2)->damage_0) < 1.0f;
                }
                else
                {
                    _S879 = false;
                }
                if(_S879)
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
    float3  _S896 = make_float3 (0.0f);
    float3  qc_ang_0;
    if(((&st_2)->damage_0) == 0.0f)
    {
        if((flags_1 & 8U) == 0U)
        {
            float3  _S897 = contact_offsets_0(mat_7, b_28, (&st_2)->crush_0, plastic_4, d_lin_2, d_ang_2);
            (&st_2)->plastic_x_0 = _S897.x;
            (&st_2)->plastic_y_0 = _S897.y;
            (&st_2)->plastic_t_0 = _S897.z;
        }
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S896;
        qc_ang_0 = _S896;
        psi_contact_0 = 0.0f;
    }
    else
    {
        Contact_0 _S898 = contact_part_0(mat_7, b_28, (&st_2)->crush_0, plastic_4, d_lin_2, d_ang_2);
        (&st_2)->plastic_x_0 = _S898.plastic_1.x;
        (&st_2)->plastic_y_0 = _S898.plastic_1.y;
        (&st_2)->plastic_t_0 = _S898.plastic_1.z;
        diss_contact_0 = _S898.diss_4;
        qc_lin_0 = _S898.q_lin_1;
        qc_ang_0 = _S898.q_ang_1;
        psi_contact_0 = _S898.energy_2;
    }
    float dissipated_6 = dissipated_3 + dmg_0 * diss_contact_0;
    if(_S878)
    {
        intact_normal_0 = kn_3 * _S877;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_2)->crush_0) * kn_3 * _S877;
    }
    float _S899 = 1.0f - dmg_0;
    float3  force_lin_2 = make_float3 (_S899 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S899 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S899 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3  force_ang_2 = qe_ang_0 * make_float3 (_S899) + qc_ang_0 * make_float3 (dmg_0);
    float stored_6 = _S899 * (psi_ts_0 + (1.0f - (&st_2)->crush_0) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S879 = ((&st_2)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S879 = false;
    }
    float stored_7;
    float3  force_lin_3;
    if(_S879)
    {
        float k_axial_0 = b_28->rebar0_0.x;
        float k_dowel_0 = b_28->rebar0_0.y;
        float yield_force_0 = b_28->rebar0_0.z;
        float dowel_capacity_0 = b_28->rebar0_0.w;
        float2  nr_0 = return_map_0(k_axial_0, _S877, (&st_2)->rebar_plastic_0, yield_force_0);
        float2  v1_0 = return_map_0(k_dowel_0, _S874, (&st_2)->rebar_slip0_0, dowel_capacity_0);
        float2  v2_0 = return_map_0(k_dowel_0, _S875, (&st_2)->rebar_slip1_0, dowel_capacity_0);
        float _S900 = nr_0.y;
        float _S901 = v1_0.y;
        float _S902 = v2_0.y;
        float work_0 = yield_force_0 * (F32_abs((_S900))) + dowel_capacity_0 * ((F32_abs((_S901))) + (F32_abs((_S902))));
        (&st_2)->rebar_plastic_0 = (&st_2)->rebar_plastic_0 + _S900;
        (&st_2)->rebar_slip0_0 = (&st_2)->rebar_slip0_0 + _S901;
        (&st_2)->rebar_slip1_0 = (&st_2)->rebar_slip1_0 + _S902;
        (&st_2)->rebar_work_0 = (&st_2)->rebar_work_0 + work_0;
        float dissipated_7 = dissipated_6 + work_0;
        float _S903 = nr_0.x;
        float _S904 = v1_0.x;
        float _S905 = v2_0.x;
        float elastic_0 = 0.5f * (fdiv_0(sq_0(_S903), k_axial_0) + fdiv_0(sq_0(_S904) + sq_0(_S905), k_dowel_0));
        if(fracture_1)
        {
            _S879 = ((&st_2)->rebar_work_0) >= (b_28->rebar1_0.x);
        }
        else
        {
            _S879 = false;
        }
        if(_S879)
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
            force_lin_3 = force_lin_2 + make_float3 (_S904, _S905, _S903);
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
        _S879 = _S867;
    }
    else
    {
        _S879 = false;
    }
    if(_S879)
    {
        _S879 = (flags_1 & 64U) != 0U;
    }
    else
    {
        _S879 = false;
    }
    if(_S879)
    {
        Measures_0 _S906 = stress_measures_0(b_28, force_lin_3, force_ang_2);
        Measures_0 _S907 = _S906;
        float4  _S908 = failure_indices_0(mat_7, b_28, &_S907, weibull_0);
        float _S909 = life_rate_0(mat_7, (F32_max(((F32_max((_S908.x), (_S908.y)))), (_S908.z))));
        (&st_2)->life_0 = (F32_max(((&st_2)->life_0 - _S909 * dt_7), (0.0f)));
    }
    (&st_2)->dissipated_0 = (&st_2)->dissipated_0 + dissipated_3;
    JointResponse_0 resp_0;
    (&resp_0)->force_lin_1 = force_lin_3;
    (&resp_0)->force_ang_1 = force_ang_2;
    (&resp_0)->state_1 = st_2;
    (&resp_0)->dissipated_2 = dissipated_3;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_5 = stored_7;
    if(_S864)
    {
        JointState_0 _S910 = st_2;
        bool _S911 = connected_0(&_S910, has_rebar_1);
        _S879 = !_S911;
    }
    else
    {
        _S879 = false;
    }
    (&resp_0)->disconnected_0 = _S879;
    (&resp_0)->fatigue_before_0 = _S869;
    (&resp_0)->measures_0 = _S865;
    return resp_0;
}

static __device__ void secant_factors_0(JointBond_0 * b_29, JointState_0 * st_3, float3  d_lin_3, float3  * f_lin_0, float3  * f_ang_0)
{
    float _S912 = st_3->damage_0;
    bool compressed_0 = (d_lin_3.z) < 0.0f;
    float contact_2;
    if(compressed_0)
    {
        contact_2 = _S912;
    }
    else
    {
        contact_2 = 0.0f;
    }
    float _S913 = 1.0f - _S912;
    float _S914 = (F32_max((_S913 + contact_2), (9.99999997475242708e-07f)));
    float normal_4;
    if(compressed_0)
    {
        normal_4 = (F32_max((1.0f - st_3->crush_0), (9.99999997475242708e-07f)));
    }
    else
    {
        normal_4 = (F32_max((_S913), (9.99999997475242708e-07f)));
    }
    *f_lin_0 = make_float3 (_S914, _S914, normal_4);
    *f_ang_0 = make_float3 (_S914);
    bool _S915;
    if((b_29->stiff1_0.w) != 0.0f)
    {
        _S915 = (st_3->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S915 = false;
    }
    if(_S915)
    {
        float4  _S916 = b_29->rebar0_0;
        float4  _S917 = b_29->stiff0_0;
        *&(f_lin_0->z) = *&(f_lin_0->z) + fdiv_0(b_29->rebar0_0.x, b_29->stiff0_0.x);
        float _S918 = fdiv_0(_S916.y, _S917.y);
        *&(f_lin_0->x) = *&(f_lin_0->x) + _S918;
        *&(f_lin_0->y) = *&(f_lin_0->y) + _S918;
    }
    return;
}

static __device__ float3  to_local_0(uint _S919, float3  _S920)
{
    BondStatic_0 * _S921 = (&(globalParams_0->bonds_0)[_S919]);
    float4  _S922 = __ldg(&_S921->t1_0);
    float _S923 = dot_0(_S920, float3 {_S922.x, _S922.y, _S922.z});
    float4  _S924 = __ldg(&_S921->t2_0);
    float _S925 = dot_0(_S920, float3 {_S924.x, _S924.y, _S924.z});
    float4  _S926 = __ldg(&_S921->normal_0);
    return make_float3 (_S923, _S925, dot_0(_S920, float3 {_S926.x, _S926.y, _S926.z}));
}

static __device__ float3  to_body_0(uint _S927, float3  _S928)
{
    BondStatic_0 * _S929 = (&(globalParams_0->bonds_0)[_S927]);
    float4  _S930 = __ldg(&_S929->t1_0);
    float3  _S931 = float3 {_S930.x, _S930.y, _S930.z} * make_float3 (_S928.x);
    float4  _S932 = __ldg(&_S929->t2_0);
    float3  _S933 = _S931 + float3 {_S932.x, _S932.y, _S932.z} * make_float3 (_S928.y);
    float4  _S934 = __ldg(&_S929->normal_0);
    return _S933 + float3 {_S934.x, _S934.y, _S934.z} * make_float3 (_S928.z);
}

static __device__ bool bond_update_0(uint i_14, float dt_8, bool fracture_2, uint abs_step_0, bool wide_0)
{
    BondStatic_0 * _S935 = (&(globalParams_0->bonds_0)[i_14]);
    JointBond_0 _S936 = slang_ldg_0(&_S935->law_0);
    uint ca_0 = _S936.ids_0.y;
    uint cb_0 = _S936.ids_0.z;
    float4  _S937 = __ldg(&_S935->ra_0);
    float3  ra_1 = float3 {_S937.x, _S937.y, _S937.z};
    float4  _S938 = __ldg(&_S935->rb_0);
    float3  rb_1 = float3 {_S938.x, _S938.y, _S938.z};
    uint _S939 = 4U * ca_0;
    float4  _S940 = *(&(globalParams_0->state_0)[_S939]);
    float4  _S941 = *(&(globalParams_0->state_0)[_S939 + 1U]);
    float3  ta_2 = float3 {_S941.x, _S941.y, _S941.z};
    float4  _S942 = *(&(globalParams_0->state_0)[_S939 + 2U]);
    float3  va_0 = float3 {_S942.x, _S942.y, _S942.z};
    float4  _S943 = *(&(globalParams_0->state_0)[_S939 + 3U]);
    float3  wa_1 = float3 {_S943.x, _S943.y, _S943.z};
    uint _S944 = 4U * cb_0;
    float4  _S945 = *(&(globalParams_0->state_0)[_S944]);
    float4  _S946 = *(&(globalParams_0->state_0)[_S944 + 1U]);
    float3  tb_2 = float3 {_S946.x, _S946.y, _S946.z};
    float4  _S947 = *(&(globalParams_0->state_0)[_S944 + 2U]);
    float3  vb_0 = float3 {_S947.x, _S947.y, _S947.z};
    float4  _S948 = *(&(globalParams_0->state_0)[_S944 + 3U]);
    float3  wb_0 = float3 {_S948.x, _S948.y, _S948.z};
    float3  _S949 = to_local_0(i_14, float3 {_S945.x, _S945.y, _S945.z} + cross_0(tb_2, rb_1) - (float3 {_S940.x, _S940.y, _S940.z} + cross_0(ta_2, ra_1)));
    float3  _S950 = to_local_0(i_14, tb_2 - ta_2);
    float3  _S951 = to_local_0(i_14, vb_0 + cross_0(wb_0, rb_1) - (va_0 + cross_0(wa_1, ra_1)));
    float3  _S952 = to_local_0(i_14, wb_0 - wa_1);
    JointBond_0 _S953 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_14])->law_0);
    JointState_0 previous_0 = (&(globalParams_0->bond_dyn_0)[i_14])->js_0;
    JointState_0 _S954 = (&(globalParams_0->bond_dyn_0)[i_14])->js_0;
    bool _S955 = is_damaged_0(&_S954);
    JointBond_0 _S956 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_14])->law_0);
    JointBond_0 _S957 = _S956;
    JointState_0 _S958 = (&(globalParams_0->bond_dyn_0)[i_14])->js_0;
    JointResponse_0 _S959 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S953.ids_0.x], &_S957, &_S958, _S949, _S950, dt_8, fracture_2);
    BondStatic_0 * _S960 = (&(globalParams_0->bonds_0)[i_14]);
    BondDyn_0 bd_0 = *(&(globalParams_0->bond_dyn_0)[i_14]);
    float4  _S961 = __ldg(&_S960->ra_0);
    float3  ra_2 = float3 {_S961.x, _S961.y, _S961.z};
    float4  _S962 = __ldg(&_S960->rb_0);
    float3  rb_2 = float3 {_S962.x, _S962.y, _S962.z};
    JointBond_0 _S963 = slang_ldg_0(&_S960->law_0);
    JointBond_0 _S964 = _S963;
    JointState_0 _S965 = _S959.state_1;
    float3  f_lin_1;
    float3  f_ang_1;
    secant_factors_0(&_S964, &_S965, _S949, &f_lin_1, &f_ang_1);
    float4  _S966 = __ldg(&_S960->c_lin_0);
    float3  qd_lin_0 = _S951 * float3 {_S966.x, _S966.y, _S966.z} * f_lin_1;
    float4  _S967 = __ldg(&_S960->c_ang_0);
    float3  qd_ang_0 = _S952 * float3 {_S967.x, _S967.y, _S967.z} * f_ang_1;
    float3  q_lin_2 = _S959.force_lin_1 + qd_lin_0;
    float3  q_ang_2 = _S959.force_ang_1 + qd_ang_0;
    float damped_0 = (dot_0(qd_lin_0, _S951) + dot_0(qd_ang_0, _S952)) * dt_8;
    float3  _S968 = to_body_0(i_14, q_lin_2);
    float3  _S969 = to_body_0(i_14, q_ang_2);
    uint _S970 = 3U * i_14;
    *(&(globalParams_0->scratch_0)[_S970]) = make_float4 (_S968.x, _S968.y, _S968.z, (F32_max((_S959.measures_0.tension_0), (_S959.measures_0.compression_0))));
    *(&(globalParams_0->scratch_0)[_S970 + 1U]) = make_float4 ((_S969 + cross_0(ra_2, _S968)).x, (_S969 + cross_0(ra_2, _S968)).y, (_S969 + cross_0(ra_2, _S968)).z, 0.0f);
    *(&(globalParams_0->scratch_0)[_S970 + 2U]) = make_float4 ((- _S969 + cross_0(rb_2, - _S968)).x, (- _S969 + cross_0(rb_2, - _S968)).y, (- _S969 + cross_0(rb_2, - _S968)).z, 0.0f);
    comp_add1_0(&((&(&bd_0)->sums_0)->x), &((&(&bd_0)->comps_0)->x), _S959.dissipated_2);
    comp_add1_0(&((&(&bd_0)->sums_0)->y), &((&(&bd_0)->comps_0)->y), _S959.overshoot_0);
    comp_add1_0(&((&(&bd_0)->sums_0)->z), &((&(&bd_0)->comps_0)->z), damped_0);
    (&bd_0)->force_lin_0 = make_float4 (q_lin_2.x, q_lin_2.y, q_lin_2.z, _S959.stored_5);
    (&bd_0)->force_ang_0 = make_float4 (q_ang_2.x, q_ang_2.y, q_ang_2.z, (F32_max(((&bd_0)->force_ang_0.w), (_S959.state_1.utilization_0))));
    bool _S971;
    if(!_S955)
    {
        JointState_0 _S972 = _S959.state_1;
        bool _S973 = is_damaged_0(&_S972);
        _S971 = _S973;
    }
    else
    {
        _S971 = false;
    }
    if(_S971)
    {
        _S971 = ((&bd_0)->events_0.x) == 0U;
    }
    else
    {
        _S971 = false;
    }
    if(_S971)
    {
        *&((&(&bd_0)->events_0)->x) = abs_step_0;
        *&((&(&bd_0)->events_0)->w) = _S959.state_1.mode_0;
        if(wide_0)
        {
            cov_or_0(_S963.ids_0.w, 32U);
        }
        else
        {
            (*&g_seen_0)[3U] = 1U;
        }
    }
    if(((&bd_0)->events_0.y) == 0U)
    {
        _S971 = (_S959.state_1.life_0) != (previous_0.life_0);
    }
    else
    {
        _S971 = false;
    }
    if(_S971)
    {
        _S971 = (_S959.fatigue_before_0) > 0.99000000953674316f;
    }
    else
    {
        _S971 = false;
    }
    if(_S971)
    {
        float _S974 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S953.ids_0.x], _S959.state_1.life_0);
        _S971 = _S974 <= 0.99000000953674316f;
    }
    else
    {
        _S971 = false;
    }
    if(_S971)
    {
        *&((&(&bd_0)->events_0)->y) = abs_step_0;
        if(wide_0)
        {
            cov_or_0(_S963.ids_0.w, 64U);
        }
        else
        {
            (*&g_seen_0)[4U] = 1U;
        }
    }
    if(_S959.disconnected_0)
    {
        *&((&(&bd_0)->events_0)->z) = abs_step_0;
    }
    (&bd_0)->js_0 = _S959.state_1;
    *(&(globalParams_0->bond_dyn_0)[i_14]) = bd_0;
    return _S959.disconnected_0;
}

static __device__ void chunk_update_0(uint c_11, Island_0 * isl_4, Rigid_0 * rg_3, float dt_9, bool rml_0, uint step_0, bool contact_3, float * work_1, float * work_err_0)
{
    ChunkStatic_0 * _S975 = (&(globalParams_0->chunks_0)[c_11]);
    float3  _S976 = make_float3 (0.0f);
    uint _S977 = __ldg((&(globalParams_0->index_0)[c_11]));
    float peak_0 = 0.0f;
    uint e_3 = _S977;
    float3  fi_0 = _S976;
    float3  mi_0 = _S976;
    for(;;)
    {
        uint _S978 = __ldg((&(globalParams_0->index_0)[c_11 + 1U]));
        if(e_3 < _S978)
        {
        }
        else
        {
            break;
        }
        uint _S979 = __ldg((&(globalParams_0->index_0)[e_3]));
        uint _S980 = 3U * (_S979 >> int(1));
        float4  fa_2 = *(&(globalParams_0->scratch_0)[_S980]);
        if((_S979 & 1U) == 0U)
        {
            float4  _S981 = *(&(globalParams_0->scratch_0)[_S980 + 1U]);
            float3  mi_1 = mi_0 + float3 {_S981.x, _S981.y, _S981.z};
            fi_0 = fi_0 + float3 {fa_2.x, fa_2.y, fa_2.z};
            mi_0 = mi_1;
        }
        else
        {
            float4  _S982 = *(&(globalParams_0->scratch_0)[_S980 + 2U]);
            float3  mi_2 = mi_0 + float3 {_S982.x, _S982.y, _S982.z};
            fi_0 = fi_0 + - float3 {fa_2.x, fa_2.y, fa_2.z};
            mi_0 = mi_2;
        }
        float _S983 = (F32_max((peak_0), (fa_2.w)));
        uint _S984 = e_3 + 1U;
        peak_0 = _S983;
        e_3 = _S984;
    }
    uint _S985 = 4U * c_11;
    float4  _S986 = *(&(globalParams_0->state_0)[_S985]);
    float3  u_0 = float3 {_S986.x, _S986.y, _S986.z};
    uint _S987 = _S985 + 1U;
    float4  _S988 = *(&(globalParams_0->state_0)[_S987]);
    float3  th_2 = float3 {_S988.x, _S988.y, _S988.z};
    uint _S989 = _S985 + 2U;
    float4  _S990 = *(&(globalParams_0->state_0)[_S989]);
    float3  v_9 = float3 {_S990.x, _S990.y, _S990.z};
    uint _S991 = _S985 + 3U;
    float4  _S992 = *(&(globalParams_0->state_0)[_S991]);
    float3  w_5 = float3 {_S992.x, _S992.y, _S992.z};
    float4  _S993 = __ldg(&_S975->center_0);
    float mass_0 = _S993.w;
    float3  _S994 = float3 {_S993.x, _S993.y, _S993.z};
    float4  _S995 = isl_4->com_0;
    float3  _S996 = float3 {_S995.x, _S995.y, _S995.z};
    float3  _S997 = rotate_0(&rg_3->rot_0, _S994 + u_0 - _S996);
    float3  f_load_0;
    float3  t_load_0;
    float3  rep_f_1;
    float3  rep_m_1;
    chunk_loads_0(c_11, c_11, &rg_3->rot_0, step_0, dt_9, contact_3, dt_9, &f_load_0, &t_load_0, &rep_f_1, &rep_m_1);
    record_chunk_load_0(c_11, f_load_0, t_load_0);
    float3  _S998 = f_load_0;
    float4  _S999 = __ldg(&globalParams_0->params_0->gravity_0);
    float3  f_world_0 = _S998 + float3 {_S999.x, _S999.y, _S999.z} * make_float3 (mass_0);
    float3  t_world_0 = t_load_0;
    float3  f_world_1;
    float3  t_world_1;
    if(rml_0)
    {
        float3  _S1000 = rg_3->alpha_0;
        float3  _S1001 = rg_3->w_4;
        float3  f_world_2 = f_world_0 - (rg_3->a_7 + cross_0(rg_3->alpha_0, _S997) + cross_0(rg_3->w_4, cross_0(rg_3->w_4, _S997))) * make_float3 (mass_0);
        float4  _S1002 = __ldg(&_S975->inertia0_0);
        float4  _S1003 = __ldg(&_S975->inertia1_0);
        float4  _S1004 = __ldg(&_S975->inertia2_0);
        float3  _S1005 = world_mul_0(&rg_3->rot_0, _S1002, _S1003, _S1004, _S1000);
        float3  _S1006 = world_mul_0(&rg_3->rot_0, _S1002, _S1003, _S1004, _S1001);
        float3  t_world_2 = t_world_0 - (_S1005 + cross_0(_S1001, _S1006));
        f_world_1 = f_world_2;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    float3  _S1007 = inverse_rotate_0(&rg_3->rot_0, f_world_1);
    float3  _S1008 = inverse_rotate_0(&rg_3->rot_0, t_world_1);
    float3  f_ext_0;
    float3  m_ext_0;
    if(rml_0)
    {
        float3  _S1009 = inverse_rotate_0(&rg_3->rot_0, rg_3->w_4);
        float3  f_ext_1 = _S1007 - cross_0(_S1009, v_9) * make_float3 (2.0f * mass_0);
        float4  _S1010 = __ldg(&_S975->inertia0_0);
        float4  _S1011 = __ldg(&_S975->inertia1_0);
        float4  _S1012 = __ldg(&_S975->inertia2_0);
        float3  i_w_0 = rows_mul_0(_S1010, _S1011, _S1012, w_5);
        float3  m_ext_1 = _S1008 - (cross_0(_S1009, i_w_0) + cross_0(w_5, rows_mul_0(_S1010, _S1011, _S1012, _S1009)) + cross_0(w_5, i_w_0));
        f_ext_0 = f_ext_1;
        m_ext_0 = m_ext_1;
    }
    else
    {
        f_ext_0 = _S1007;
        m_ext_0 = _S1008;
    }
    float3  f_13 = f_ext_0 + rep_f_1 + fi_0;
    float3  m_5 = m_ext_0 + rep_m_1 + mi_0;
    uint4  _S1013 = __ldg(&_S975->info_0);
    uint support_0 = _S1013.x;
    float3  _S1014 = make_float3 ((*(&(globalParams_0->state_0)[_S987])).w, (*(&(globalParams_0->state_0)[_S989])).w, (*(&(globalParams_0->state_0)[_S991])).w);
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
        v_10 = _S976;
        w_6 = _S976;
    }
    else
    {
        float4  _S1015 = __ldg(&_S975->inv0_0);
        float4  _S1016 = __ldg(&_S975->inv1_0);
        float4  _S1017 = __ldg(&_S975->inv2_0);
        float3  _S1018 = rows_mul_0(_S1015, _S1016, _S1017, m_5);
        float4  _S1019 = __ldg(&_S975->scale_0);
        float3  w_7 = w_5 + _S1018 * make_float3 (dt_9 * _S1019.z);
        float3  th_4 = th_2 + w_7 * make_float3 (dt_9);
        if(support_0 == 2U)
        {
            reaction_0 = - f_13;
            u_1 = u_0;
            th_3 = _S976;
        }
        else
        {
            float3  v_11 = v_9 + f_13 * make_float3 (dt_9 * _S1019.y);
            float3  u_2 = u_0 + v_11 * make_float3 (dt_9);
            reaction_0 = _S1014;
            u_1 = u_2;
            th_3 = v_11;
        }
        float3  _S1020 = th_3;
        th_3 = th_4;
        v_10 = _S1020;
        w_6 = w_7;
    }
    *(&(globalParams_0->state_0)[_S985]) = make_float4 (u_1.x, u_1.y, u_1.z, peak_0);
    *(&(globalParams_0->state_0)[_S987]) = make_float4 (th_3.x, th_3.y, th_3.z, reaction_0.x);
    *(&(globalParams_0->state_0)[_S989]) = make_float4 (v_10.x, v_10.y, v_10.z, reaction_0.y);
    *(&(globalParams_0->state_0)[_S991]) = make_float4 (w_6.x, w_6.y, w_6.z, reaction_0.z);
    float3  _S1021 = rotate_0(&rg_3->rot_0, _S994 + u_1 - _S996);
    float3  _S1022 = rg_3->vel_1 + rg_3->vel_err_1 + cross_0(rg_3->w_4, _S1021);
    float3  _S1023 = rotate_0(&rg_3->rot_0, v_10);
    float3  v_world_0 = _S1022 + _S1023;
    float3  _S1024 = rotate_0(&rg_3->rot_0, w_6);
    comp_add1_0(work_1, work_err_0, (dot_0(f_load_0, v_world_0) + dot_0(t_load_0, rg_3->w_4 + _S1024)) * dt_9);
    return;
}

static __device__ float3  turn_difference_0(float3  omega_1, float dt_10, float3  v_12)
{
    float _S1025 = length_0(omega_1);
    float angle_3 = _S1025 * dt_10;
    if(angle_3 < 1.00000000317107685e-30f)
    {
        return make_float3 (0.0f);
    }
    float3  a_14 = omega_1 / make_float3 (_S1025);
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
    float4  _S1026 = isl_5->inv0_1;
    float4  _S1027 = isl_5->inv1_1;
    float4  _S1028 = isl_5->inv2_1;
    Quat_0 _S1029 = rg_4->rot_0;
    float3  _S1030 = world_mul_0(&_S1029, isl_5->inv0_1, isl_5->inv1_1, isl_5->inv2_1, l_3);
    float3  _S1031 = vel_2 * make_float3 (dt_11);
    float4  _S1032 = isl_5->com_0;
    float3  _S1033 = float3 {_S1032.x, _S1032.y, _S1032.z};
    Quat_0 _S1034 = rg_4->rot_0;
    float3  _S1035 = rotate_0(&_S1034, _S1033);
    comp_add_0(&rg_4->pos_1, &rg_4->pos_err_1, _S1031 - turn_difference_0(_S1030, dt_11, _S1035));
    turn_left_0(&rg_4->rot_0, &rg_4->rot_err_0, _S1030, dt_11);
    Quat_0 _S1036 = rg_4->rot_0;
    float3  _S1037 = world_mul_0(&_S1036, _S1026, _S1027, _S1028, l_3);
    rg_4->w_4 = _S1037;
    return;
}

static __device__ void drift_moments_0(uint c_12, float3  * tu_0, float3  * pv_0)
{
    ChunkStatic_0 * _S1038 = (&(globalParams_0->chunks_0)[c_12]);
    float4  _S1039 = __ldg(&_S1038->center_0);
    float _S1040 = _S1039.w;
    float4  _S1041 = __ldg(&_S1038->scale_0);
    float m_6 = _S1040 * _S1041.x;
    uint _S1042 = 4U * c_12;
    float4  _S1043 = *(&(globalParams_0->state_0)[_S1042]);
    *tu_0 = *tu_0 + float3 {_S1043.x, _S1043.y, _S1043.z} * make_float3 (m_6);
    float4  _S1044 = *(&(globalParams_0->state_0)[_S1042 + 2U]);
    *pv_0 = *pv_0 + float3 {_S1044.x, _S1044.y, _S1044.z} * make_float3 (m_6);
    return;
}

static __device__ void drift_angular_0(uint c_13, float3  wcom_1, float3  tr_0, float3  dv_0, float3  * lu_0, float3  * lv_0)
{
    ChunkStatic_0 * _S1045 = (&(globalParams_0->chunks_0)[c_13]);
    float4  _S1046 = __ldg(&_S1045->center_0);
    float3  r_9 = float3 {_S1046.x, _S1046.y, _S1046.z} - wcom_1;
    float4  _S1047 = __ldg(&_S1045->scale_0);
    float kw_0 = _S1047.x;
    uint _S1048 = 4U * c_13;
    float4  _S1049 = *(&(globalParams_0->state_0)[_S1048]);
    float _S1050 = _S1046.w;
    float3  _S1051 = cross_0(r_9, float3 {_S1049.x, _S1049.y, _S1049.z} - tr_0) * make_float3 (_S1050);
    float4  _S1052 = __ldg(&_S1045->inertia0_0);
    float4  _S1053 = __ldg(&_S1045->inertia1_0);
    float4  _S1054 = __ldg(&_S1045->inertia2_0);
    float4  _S1055 = *(&(globalParams_0->state_0)[_S1048 + 1U]);
    *lu_0 = *lu_0 + (_S1051 + rows_mul_0(_S1052, _S1053, _S1054, float3 {_S1055.x, _S1055.y, _S1055.z})) * make_float3 (kw_0);
    float4  _S1056 = *(&(globalParams_0->state_0)[_S1048 + 2U]);
    float4  _S1057 = *(&(globalParams_0->state_0)[_S1048 + 3U]);
    *lv_0 = *lv_0 + (cross_0(r_9, float3 {_S1056.x, _S1056.y, _S1056.z} - dv_0) * make_float3 (_S1050) + rows_mul_0(_S1052, _S1053, _S1054, float3 {_S1057.x, _S1057.y, _S1057.z})) * make_float3 (kw_0);
    return;
}

static __device__ void drift_apply_0(uint c_14, float3  wcom_2, float3  tr_1, float3  phi_0, float3  dv_1, float3  dw_0)
{
    float4  _S1058 = __ldg(&(&(globalParams_0->chunks_0)[c_14])->center_0);
    float3  r_10 = float3 {_S1058.x, _S1058.y, _S1058.z} - wcom_2;
    uint _S1059 = 4U * c_14;
    float4  _S1060 = *(&(globalParams_0->state_0)[_S1059]);
    *(&(globalParams_0->state_0)[_S1059]) = make_float4 ((float3 {_S1060.x, _S1060.y, _S1060.z} - (tr_1 + cross_0(phi_0, r_10))).x, (float3 {_S1060.x, _S1060.y, _S1060.z} - (tr_1 + cross_0(phi_0, r_10))).y, (float3 {_S1060.x, _S1060.y, _S1060.z} - (tr_1 + cross_0(phi_0, r_10))).z, (*(&(globalParams_0->state_0)[_S1059])).w);
    uint _S1061 = _S1059 + 1U;
    float4  _S1062 = *(&(globalParams_0->state_0)[_S1061]);
    *(&(globalParams_0->state_0)[_S1061]) = make_float4 ((float3 {_S1062.x, _S1062.y, _S1062.z} - phi_0).x, (float3 {_S1062.x, _S1062.y, _S1062.z} - phi_0).y, (float3 {_S1062.x, _S1062.y, _S1062.z} - phi_0).z, (*(&(globalParams_0->state_0)[_S1061])).w);
    uint _S1063 = _S1059 + 2U;
    float4  _S1064 = *(&(globalParams_0->state_0)[_S1063]);
    *(&(globalParams_0->state_0)[_S1063]) = make_float4 ((float3 {_S1064.x, _S1064.y, _S1064.z} - (dv_1 + cross_0(dw_0, r_10))).x, (float3 {_S1064.x, _S1064.y, _S1064.z} - (dv_1 + cross_0(dw_0, r_10))).y, (float3 {_S1064.x, _S1064.y, _S1064.z} - (dv_1 + cross_0(dw_0, r_10))).z, (*(&(globalParams_0->state_0)[_S1063])).w);
    uint _S1065 = _S1059 + 3U;
    float4  _S1066 = *(&(globalParams_0->state_0)[_S1065]);
    *(&(globalParams_0->state_0)[_S1065]) = make_float4 ((float3 {_S1066.x, _S1066.y, _S1066.z} - dw_0).x, (float3 {_S1066.x, _S1066.y, _S1066.z} - dw_0).y, (float3 {_S1066.x, _S1066.y, _S1066.z} - dw_0).z, (*(&(globalParams_0->state_0)[_S1065])).w);
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
    (&dq_1)->x_12 = d_11.x;
    (&dq_1)->y_4 = d_11.y;
    (&dq_1)->z_0 = d_11.z;
    (&dq_1)->w_1 = d_11.w;
    Quat_0 _S1067 = *hi_3;
    Quat_0 _S1068 = dq_1;
    Quat_0 _S1069 = quat_mul_0(&_S1067, &_S1068);
    Quat_0 _S1070 = _S1069;
    float4  _S1071 = quat_vec_0(&_S1070);
    quat_accumulate_0(hi_3, lo_3, _S1071);
    return;
}

static __device__ void drift_rigid_0(Island_0 * isl_6, Rigid_0 * rg_5, float3  tr_2, float3  phi_2, float3  dv_2, float3  dw_1)
{
    float4  _S1072 = isl_6->wcom_0;
    float3  wcom_3 = float3 {_S1072.x, _S1072.y, _S1072.z};
    Quat_0 rot_2 = rg_5->rot_0;
    float3  _S1073 = tr_2 - cross_0(phi_2, wcom_3);
    Quat_0 _S1074 = rg_5->rot_0;
    float3  _S1075 = rotate_0(&_S1074, _S1073);
    comp_add_0(&rg_5->pos_1, &rg_5->pos_err_1, _S1075);
    Quat_0 _S1076 = rg_5->rot_0;
    float3  _S1077 = inverse_rotate_0(&_S1076, rg_5->w_4);
    float4  _S1078 = isl_6->inertia0_1;
    float4  _S1079 = isl_6->inertia1_1;
    float4  _S1080 = isl_6->inertia2_1;
    float3  _S1081 = cross_0(phi_2, rows_mul_0(isl_6->inertia0_1, isl_6->inertia1_1, isl_6->inertia2_1, _S1077)) - rows_mul_0(isl_6->inertia0_1, isl_6->inertia1_1, isl_6->inertia2_1, cross_0(phi_2, _S1077));
    Quat_0 _S1082 = rg_5->rot_0;
    float3  _S1083 = rotate_0(&_S1082, _S1081);
    turn_right_0(&rg_5->rot_0, &rg_5->rot_err_0, phi_2);
    float4  _S1084 = isl_6->com_0;
    float3  _S1085 = dv_2 + cross_0(dw_1, float3 {_S1084.x, _S1084.y, _S1084.z} - wcom_3);
    Quat_0 _S1086 = rot_2;
    float3  _S1087 = rotate_0(&_S1086, _S1085);
    comp_add_0(&rg_5->vel_1, &rg_5->vel_err_1, _S1087);
    Quat_0 _S1088 = rot_2;
    float3  _S1089 = rotate_0(&_S1088, dw_1);
    rg_5->w_4 = rg_5->w_4 + _S1089;
    Quat_0 _S1090 = rg_5->rot_0;
    float3  _S1091 = world_mul_0(&_S1090, _S1078, _S1079, _S1080, _S1089);
    comp_add_0(&rg_5->l_2, &rg_5->l_err_1, _S1083 + _S1091);
    return;
}

static __device__ void write_probe_0(uint slot_0, uint k_16, float value_1)
{
    uint _S1092 = __ldg(&globalParams_0->params_0->probe_base_0);
    uint _S1093 = _S1092 * 4U;
    uint _S1094 = __ldg(&globalParams_0->params_0->probe_stride_0);
    uint at_4 = _S1093 + slot_0 * _S1094 + k_16;
    float4  v_13 = *(&(globalParams_0->scratch_0)[at_4 / 4U]);
    *_slang_vector_get_element_ptr(&v_13, at_4 % 4U) = value_1;
    *(&(globalParams_0->scratch_0)[at_4 / 4U]) = v_13;
    return;
}

static __device__ void record_probes_0(Island_0 * isl_7, Rigid_0 * rg_6, uint k_17)
{
    uint4  _S1095 = isl_7->probes_0;
    uint at_5 = isl_7->probes_0.x;
    for(;;)
    {
        if(at_5 < (_S1095.y))
        {
        }
        else
        {
            break;
        }
        float4  _S1096 = __ldg((&(globalParams_0->loads_0)[at_5]));
        uint4  info_3 = asuint_0(_S1096);
        float4  _S1097 = __ldg((&(globalParams_0->loads_0)[at_5 + 1U]));
        float4  _S1098 = __ldg((&(globalParams_0->loads_0)[at_5 + 2U]));
        float4  _S1099 = __ldg((&(globalParams_0->loads_0)[at_5 + 3U]));
        uint kind_4 = info_3.x;
        uint i_15 = info_3.y;
        float value_2;
        if(kind_4 == 0U)
        {
            float4  _S1100 = *(&(globalParams_0->state_0)[4U * i_15]);
            float3  small_0 = float3 {_S1100.x, _S1100.y, _S1100.z} + make_float3 (_S1097.w, _S1098.w, _S1099.w);
            float3  _S1101 = rg_6->pos_1 - float3 {_S1098.x, _S1098.y, _S1098.z};
            float4  _S1102 = __ldg(&(&(globalParams_0->chunks_0)[i_15])->center_0);
            float3  _S1103 = rotate_0(&rg_6->rot_0, float3 {_S1102.x, _S1102.y, _S1102.z});
            float3  _S1104 = _S1101 + _S1103;
            float3  _S1105 = rg_6->pos_err_1 - float3 {_S1099.x, _S1099.y, _S1099.z};
            float3  _S1106 = rotate_0(&rg_6->rot_0, small_0);
            value_2 = dot_0(_S1104 + (_S1105 + _S1106), float3 {_S1097.x, _S1097.y, _S1097.z});
        }
        else
        {
            if(kind_4 == 1U)
            {
                float4  _S1107 = __ldg(&(&(globalParams_0->chunks_0)[i_15])->center_0);
                uint _S1108 = 4U * i_15;
                float4  _S1109 = *(&(globalParams_0->state_0)[_S1108]);
                float4  _S1110 = isl_7->com_0;
                float3  _S1111 = rotate_0(&rg_6->rot_0, float3 {_S1107.x, _S1107.y, _S1107.z} + float3 {_S1109.x, _S1109.y, _S1109.z} - float3 {_S1110.x, _S1110.y, _S1110.z});
                float3  _S1112 = rg_6->vel_1 + rg_6->vel_err_1 + cross_0(rg_6->w_4, _S1111);
                float4  _S1113 = *(&(globalParams_0->state_0)[_S1108 + 2U]);
                float3  _S1114 = rotate_0(&rg_6->rot_0, float3 {_S1113.x, _S1113.y, _S1113.z});
                value_2 = dot_0(_S1112 + _S1114, float3 {_S1097.x, _S1097.y, _S1097.z});
            }
            else
            {
                if(kind_4 == 2U)
                {
                    uint _S1115 = 3U * i_15;
                    float4  _S1116 = *(&(globalParams_0->scratch_0)[_S1115]);
                    float3  f_14 = float3 {_S1116.x, _S1116.y, _S1116.z};
                    bool _S1117 = (info_3.z) == 0U;
                    float3  mc_0;
                    if(_S1117)
                    {
                        float4  _S1118 = *(&(globalParams_0->scratch_0)[_S1115 + 1U]);
                        mc_0 = float3 {_S1118.x, _S1118.y, _S1118.z};
                    }
                    else
                    {
                        float4  _S1119 = *(&(globalParams_0->scratch_0)[_S1115 + 2U]);
                        mc_0 = float3 {_S1119.x, _S1119.y, _S1119.z};
                    }
                    float3  fc_3;
                    if(_S1117)
                    {
                        fc_3 = f_14;
                    }
                    else
                    {
                        fc_3 = - f_14;
                    }
                    value_2 = dot_0(fc_3, float3 {_S1097.x, _S1097.y, _S1097.z}) + dot_0(mc_0, float3 {_S1098.x, _S1098.y, _S1098.z});
                }
                else
                {
                    uint _S1120 = 4U * i_15;
                    float3  _S1121 = rotate_0(&rg_6->rot_0, make_float3 ((*(&(globalParams_0->state_0)[_S1120 + 1U])).w, (*(&(globalParams_0->state_0)[_S1120 + 2U])).w, (*(&(globalParams_0->state_0)[_S1120 + 3U])).w));
                    value_2 = dot_0(_S1121, float3 {_S1097.x, _S1097.y, _S1097.z});
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
    uint _S1122 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint previous_1 = (&(globalParams_0->islands_0)[_S1122])->info_1.y;
    uint _S1123 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint _S1124;
    if(previous_1 == 0U)
    {
        _S1124 = at_6;
    }
    else
    {
        _S1124 = (U32_min((previous_1), (at_6)));
    }
    *&((&(&(globalParams_0->islands_0)[_S1123])->info_1)->y) = _S1124;
    return;
}

static __device__ uint seen_bits_0()
{
    uint _S1125;
    if(((*&g_seen_0)[0U]) != 0U)
    {
        _S1125 = 32768U;
    }
    else
    {
        _S1125 = 0U;
    }
    uint _S1126;
    if(((*&g_seen_0)[1U]) != 0U)
    {
        _S1126 = 65536U;
    }
    else
    {
        _S1126 = 0U;
    }
    uint _S1127 = _S1125 | _S1126;
    if(((*&g_seen_0)[2U]) != 0U)
    {
        _S1125 = 131072U;
    }
    else
    {
        _S1125 = 0U;
    }
    uint _S1128 = _S1127 | _S1125;
    if(((*&g_seen_0)[3U]) != 0U)
    {
        _S1125 = 32U;
    }
    else
    {
        _S1125 = 0U;
    }
    uint _S1129 = _S1128 | _S1125;
    if(((*&g_seen_0)[4U]) != 0U)
    {
        _S1125 = 64U;
    }
    else
    {
        _S1125 = 0U;
    }
    return _S1129 | _S1125;
}

extern "C" __global__ void island_frame()
{
    bool woke_0;
    uint _S1130;
    uint _S1131;
    uint _S1132;
    uint _S1133;
    uint _S1134;
    uint _S1135;
    uint _S1136 = __ballot_sync(4294967295U, true);
    uint tid_5 = threadIdx.x;
    uint _S1137 = blockIdx.x;
    Island_0 isl_8 = *(&(globalParams_0->islands_0)[_S1137]);
    bool driven_0 = (((&isl_8)->info_1.x) & 2U) != 0U;
    bool _S1138 = !((((&isl_8)->info_1.x) & 1U) != 0U);
    uint _S1139 = __ballot_sync(_S1136, _S1138);
    bool _S1140;
    uint cov_0;
    if(_S1138)
    {
        bool _S1141 = !driven_0;
        uint _S1142 = __ballot_sync(_S1136, true);
        _S1140 = _S1141;
        cov_0 = _S1142;
    }
    else
    {
        uint _S1143 = __ballot_sync(_S1136, true);
        _S1140 = false;
        cov_0 = _S1143;
    }
    bool contact_island_0 = (((&isl_8)->info_1.x) & 4U) != 0U;
    bool _S1144 = (((&isl_8)->info_1.x) & 16U) != 0U;
    seen_clear_0(tid_5);
    bool _S1145 = tid_5 == 0U;
    uint _S1146 = __ballot_sync(cov_0, _S1145);
    bool settled_0;
    uint run_0;
    uint done_1;
    if(_S1145)
    {
        uint _S1147 = __ldg(&globalParams_0->params_0->contact_mode_0);
        bool _S1148 = contact_island_0 != (_S1147 == 1U);
        uint _S1149 = __ballot_sync(_S1146, _S1148);
        if(_S1148)
        {
            uint _S1150 = __ballot_sync(_S1146, true);
            settled_0 = true;
            run_0 = _S1150;
        }
        else
        {
            bool _S1151 = (((&isl_8)->info_1.x) & 8U) != 0U;
            uint _S1152 = __ballot_sync(_S1146, true);
            settled_0 = _S1151;
            run_0 = _S1152;
        }
        uint _S1153 = __ballot_sync(run_0, settled_0);
        if(settled_0)
        {
            uint _S1154 = __ballot_sync(run_0, true);
            run_0 = 0U;
            done_1 = _S1154;
        }
        else
        {
            uint _S1155 = __ballot_sync(run_0, true);
            run_0 = 1U;
            done_1 = _S1155;
        }
        uint _S1156 = __ballot_sync(done_1, contact_island_0);
        if(contact_island_0)
        {
            Island_0 _S1157 = isl_8;
            bool _S1158 = contact_stopped_0(&_S1157);
            uint _S1159 = __ballot_sync(done_1, true);
            settled_0 = _S1158;
            done_1 = _S1159;
        }
        else
        {
            uint _S1160 = __ballot_sync(done_1, true);
            settled_0 = false;
            done_1 = _S1160;
        }
        uint _S1161 = __ballot_sync(done_1, settled_0);
        if(settled_0)
        {
            uint _S1162 = __ballot_sync(done_1, true);
            run_0 = 0U;
        }
        else
        {
            uint _S1163 = __ballot_sync(done_1, true);
        }
        *&g_run_0 = run_0;
        *&g_halt_0 = 0U;
        uint _S1164 = __ballot_sync(cov_0, true);
        cov_0 = _S1164;
    }
    else
    {
        uint _S1165 = __ballot_sync(cov_0, true);
        cov_0 = _S1165;
    }
    __syncthreads();
    bool _S1166 = (((&isl_8)->info_1.z) & 1U) != 0U;
    uint _S1167 = __ballot_sync(cov_0, _S1166);
    if(_S1166)
    {
        uint _S1168 = __ballot_sync(cov_0, true);
        settled_0 = true;
        cov_0 = _S1168;
    }
    else
    {
        bool _S1169 = (*&g_run_0) == 0U;
        uint _S1170 = __ballot_sync(cov_0, true);
        settled_0 = _S1169;
        cov_0 = _S1170;
    }
    uint _S1171 = __ballot_sync(cov_0, settled_0);
    if(settled_0)
    {
        uint _S1172 = __ballot_sync(cov_0, true);
        cov_0 = 0U;
        run_0 = _S1172;
    }
    else
    {
        uint _S1173 = (&isl_8)->info_1.y;
        uint _S1174 = __ldg(&globalParams_0->params_0->max_steps_0);
        uint _S1175 = (U32_min((_S1173), (_S1174)));
        uint _S1176 = __ballot_sync(cov_0, true);
        cov_0 = _S1175;
        run_0 = _S1176;
    }
    float _S1177 = __ldg(&globalParams_0->params_0->dt_0);
    uint _S1178 = __ldg(&globalParams_0->params_0->fracture_0);
    bool _S1179 = _S1178 != 0U;
    uint _S1180 = __ldg(&globalParams_0->params_0->rigid_motion_loads_0);
    bool _S1181 = _S1180 != 0U;
    Island_0 _S1182 = isl_8;
    Rigid_0 _S1183 = rigid_of_0(&_S1182);
    Rigid_0 rg_7 = _S1183;
    float work_2 = 0.0f;
    float work_err_1 = 0.0f;
    settled_0 = _S1144;
    done_1 = 0U;
    bool woke_1 = false;
    uint _S1184 = run_0;
    for(;;)
    {
        uint _S1185 = 0U;
        bool _S1186 = done_1 < cov_0;
        uint _S1187 = __ballot_sync(_S1184, _S1186);
        if(_S1186)
        {
            uint _S1188 = __ballot_sync(_S1184, true);
            _S1185 = _S1188;
        }
        else
        {
            uint _S1189 = __ballot_sync(_S1184, false);
            uint _S1190 = __ballot_sync(_S1184, false);
            uint _S1191 = __ballot_sync(run_0, true);
            woke_0 = woke_1;
            cov_0 = _S1191;
            break;
        }
        uint abs_step_1 = (&isl_8)->info_1.w + done_1 + 1U;
        uint _S1192 = abs_step_1 - 1U;
        uint _S1193 = __ldg(&globalParams_0->params_0->step_start_0);
        uint k_18 = _S1192 - _S1193;
        bool quiet_0 = (((&isl_8)->info_1.x) & 32U) != 0U;
        uint _S1194 = __ballot_sync(_S1185, settled_0);
        bool _S1195;
        uint _S1196;
        if(settled_0)
        {
            bool _S1197 = !quiet_0;
            uint _S1198 = __ballot_sync(_S1185, true);
            _S1195 = _S1197;
            _S1196 = _S1198;
        }
        else
        {
            uint _S1199 = __ballot_sync(_S1185, true);
            _S1195 = false;
            _S1196 = _S1199;
        }
        uint _S1200 = __ballot_sync(_S1196, _S1195);
        bool _S1201;
        bool explicit_step_0;
        uint c_15;
        uint _S1202;
        uint c_16;
        if(_S1195)
        {
            float3  _S1203 = make_float3 (0.0f);
            float3  norm_0 = _S1203;
            float3  unused0_0 = _S1203;
            c_15 = (&isl_8)->range_0.x + tid_5;
            _S1202 = _S1200;
            for(;;)
            {
                bool _S1204 = c_15 < ((&isl_8)->range_0.y);
                uint _S1205 = __ballot_sync(_S1202, _S1204);
                if(_S1204)
                {
                    uint _S1206 = __ballot_sync(_S1202, true);
                }
                else
                {
                    uint _S1207 = __ballot_sync(_S1202, false);
                    uint _S1208 = __ballot_sync(_S1202, false);
                    uint _S1209 = __ballot_sync(_S1200, true);
                    _S1130 = _S1209;
                    break;
                }
                Quat_0 _S1210 = (&rg_7)->rot_0;
                float _S1211 = settled_chunk_load_0(c_15, &_S1210, k_18, _S1177, contact_island_0);
                *&((&norm_0)->x) = *&((&norm_0)->x) + _S1211;
                uint _S1212 = __ballot_sync(_S1202, true);
                c_15 = c_15 + 256U;
                _S1202 = _S1212;
            }
            group_sum3_0(tid_5, &norm_0, &unused0_0, _S1130);
            uint _S1213 = __ldg(&globalParams_0->params_0->solve_mode_0);
            bool _S1214 = _S1213 == 1U;
            uint _S1215 = __ballot_sync(_S1130, _S1214);
            if(_S1214)
            {
                bool _S1216 = (F32_abs((norm_0.x - (&isl_8)->energy_1.z))) > ((&isl_8)->energy_1.w);
                uint _S1217 = __ballot_sync(_S1130, true);
                _S1201 = _S1216;
                c_16 = _S1217;
            }
            else
            {
                uint _S1218 = __ballot_sync(_S1130, true);
                _S1201 = false;
                c_16 = _S1218;
            }
            uint _S1219 = __ballot_sync(c_16, _S1201);
            if(_S1201)
            {
                uint _S1220 = __ballot_sync(c_16, true);
                explicit_step_0 = false;
                woke_0 = true;
            }
            else
            {
                uint _S1221 = __ballot_sync(c_16, true);
                explicit_step_0 = settled_0;
                woke_0 = woke_1;
            }
            uint _S1222 = __ballot_sync(_S1196, true);
            settled_0 = explicit_step_0;
            c_15 = _S1222;
        }
        else
        {
            uint _S1223 = __ballot_sync(_S1196, true);
            woke_0 = woke_1;
            c_15 = _S1223;
        }
        uint _S1224 = __ballot_sync(c_15, _S1138);
        if(_S1138)
        {
            bool _S1225 = !quiet_0;
            uint _S1226 = __ballot_sync(c_15, true);
            _S1201 = _S1225;
            _S1202 = _S1226;
        }
        else
        {
            uint _S1227 = __ballot_sync(c_15, true);
            _S1201 = false;
            _S1202 = _S1227;
        }
        uint _S1228 = __ballot_sync(_S1202, _S1201);
        uint _S1229;
        if(_S1201)
        {
            float3  _S1230 = make_float3 (0.0f);
            float3  f_15 = _S1230;
            float3  t_12 = _S1230;
            c_16 = (&isl_8)->range_0.x + tid_5;
            _S1229 = _S1228;
            for(;;)
            {
                bool _S1231 = c_16 < ((&isl_8)->range_0.y);
                uint _S1232 = __ballot_sync(_S1229, _S1231);
                if(_S1231)
                {
                    uint _S1233 = __ballot_sync(_S1229, true);
                }
                else
                {
                    uint _S1234 = __ballot_sync(_S1229, false);
                    uint _S1235 = __ballot_sync(_S1229, false);
                    uint _S1236 = __ballot_sync(_S1228, true);
                    _S1131 = _S1236;
                    break;
                }
                Island_0 _S1237 = isl_8;
                Rigid_0 _S1238 = rg_7;
                net_load_0(c_16, &_S1237, &_S1238, k_18, _S1177, contact_island_0, &f_15, &t_12);
                uint _S1239 = __ballot_sync(_S1229, true);
                c_16 = c_16 + 256U;
                _S1229 = _S1239;
            }
            group_sum3_0(tid_5, &f_15, &t_12, _S1131);
            Island_0 _S1240 = isl_8;
            rigid_acceleration_0(&_S1240, &rg_7, f_15, t_12);
            uint _S1241 = __ballot_sync(_S1202, true);
            c_16 = _S1241;
        }
        else
        {
            uint _S1242 = __ballot_sync(_S1202, true);
            c_16 = _S1242;
        }
        bool _S1243 = !settled_0;
        uint _S1244 = __ballot_sync(c_16, _S1243);
        if(_S1243)
        {
            bool _S1245 = !quiet_0;
            uint _S1246 = __ballot_sync(c_16, true);
            explicit_step_0 = _S1245;
            _S1229 = _S1246;
        }
        else
        {
            uint _S1247 = __ballot_sync(c_16, true);
            explicit_step_0 = false;
            _S1229 = _S1247;
        }
        uint _S1248 = __ballot_sync(_S1229, explicit_step_0);
        uint i_16;
        uint _S1249;
        uint c_17;
        uint _S1250;
        if(explicit_step_0)
        {
            i_16 = (&isl_8)->range_0.z + tid_5;
            _S1249 = _S1248;
            for(;;)
            {
                uint _S1251 = 0U;
                bool _S1252 = i_16 < ((&isl_8)->range_0.w);
                uint _S1253 = __ballot_sync(_S1249, _S1252);
                if(_S1252)
                {
                    uint _S1254 = __ballot_sync(_S1249, true);
                    _S1251 = _S1254;
                }
                else
                {
                    uint _S1255 = __ballot_sync(_S1249, false);
                    uint _S1256 = __ballot_sync(_S1249, false);
                    uint _S1257 = __ballot_sync(_S1248, true);
                    _S1132 = _S1257;
                    break;
                }
                bool _S1258 = bond_update_0(i_16, _S1177, _S1179, abs_step_1, false);
                uint _S1259 = __ballot_sync(_S1251, _S1258);
                if(_S1258)
                {
                    *&g_halt_0 = 1U;
                    uint _S1260 = __ballot_sync(_S1251, true);
                }
                else
                {
                    uint _S1261 = __ballot_sync(_S1251, true);
                }
                uint _S1262 = __ballot_sync(_S1249, true);
                i_16 = i_16 + 256U;
                _S1249 = _S1262;
            }
            __syncthreads();
            c_17 = (&isl_8)->range_0.x + tid_5;
            _S1250 = _S1132;
            for(;;)
            {
                bool _S1263 = c_17 < ((&isl_8)->range_0.y);
                uint _S1264 = __ballot_sync(_S1250, _S1263);
                if(_S1263)
                {
                    uint _S1265 = __ballot_sync(_S1250, true);
                }
                else
                {
                    uint _S1266 = __ballot_sync(_S1250, false);
                    uint _S1267 = __ballot_sync(_S1250, false);
                    uint _S1268 = __ballot_sync(_S1132, true);
                    break;
                }
                Island_0 _S1269 = isl_8;
                Rigid_0 _S1270 = rg_7;
                chunk_update_0(c_17, &_S1269, &_S1270, _S1177, _S1181, k_18, contact_island_0, &work_2, &work_err_1);
                uint _S1271 = __ballot_sync(_S1250, true);
                c_17 = c_17 + 256U;
                _S1250 = _S1271;
            }
            __syncthreads();
            uint _S1272 = __ballot_sync(_S1229, true);
            i_16 = _S1272;
        }
        else
        {
            uint _S1273 = __ballot_sync(_S1229, true);
            i_16 = _S1273;
        }
        uint _S1274 = __ballot_sync(i_16, _S1140);
        bool _S1275;
        if(_S1140)
        {
            bool _S1276 = !quiet_0;
            uint _S1277 = __ballot_sync(i_16, true);
            _S1275 = _S1276;
            _S1249 = _S1277;
        }
        else
        {
            uint _S1278 = __ballot_sync(i_16, true);
            _S1275 = false;
            _S1249 = _S1278;
        }
        uint _S1279 = __ballot_sync(_S1249, _S1275);
        if(_S1275)
        {
            Island_0 _S1280 = isl_8;
            integrate_rigid_0(&_S1280, &rg_7, _S1177);
            uint _S1281 = __ballot_sync(_S1249, true);
            c_17 = _S1281;
        }
        else
        {
            uint _S1282 = __ballot_sync(_S1249, true);
            c_17 = _S1282;
        }
        uint _S1283 = __ballot_sync(c_17, _S1138);
        bool _S1284;
        if(_S1138)
        {
            uint _S1285 = __ballot_sync(c_17, true);
            _S1284 = explicit_step_0;
            _S1250 = _S1285;
        }
        else
        {
            uint _S1286 = __ballot_sync(c_17, true);
            _S1284 = false;
            _S1250 = _S1286;
        }
        uint _S1287 = __ballot_sync(_S1250, _S1284);
        uint c_18;
        uint _S1288;
        uint c_19;
        if(_S1284)
        {
            float4  _S1289 = (&isl_8)->wcom_0;
            float3  _S1290 = float3 {_S1289.x, _S1289.y, _S1289.z};
            float3  _S1291 = make_float3 (0.0f);
            float3  tu_1 = _S1291;
            float3  pv_1 = _S1291;
            c_18 = (&isl_8)->range_0.x + tid_5;
            _S1288 = _S1287;
            for(;;)
            {
                bool _S1292 = c_18 < ((&isl_8)->range_0.y);
                uint _S1293 = __ballot_sync(_S1288, _S1292);
                if(_S1292)
                {
                    uint _S1294 = __ballot_sync(_S1288, true);
                }
                else
                {
                    uint _S1295 = __ballot_sync(_S1288, false);
                    uint _S1296 = __ballot_sync(_S1288, false);
                    uint _S1297 = __ballot_sync(_S1287, true);
                    _S1133 = _S1297;
                    break;
                }
                drift_moments_0(c_18, &tu_1, &pv_1);
                uint _S1298 = __ballot_sync(_S1288, true);
                c_18 = c_18 + 256U;
                _S1288 = _S1298;
            }
            group_sum3_0(tid_5, &tu_1, &pv_1, _S1133);
            float3  tr_3 = tu_1 / make_float3 ((&isl_8)->wcom_0.w);
            float3  dv_3 = pv_1 / make_float3 ((&isl_8)->wcom_0.w);
            float3  lu_1 = _S1291;
            float3  lv_1 = _S1291;
            c_19 = (&isl_8)->range_0.x + tid_5;
            uint _S1299 = _S1133;
            for(;;)
            {
                bool _S1300 = c_19 < ((&isl_8)->range_0.y);
                uint _S1301 = __ballot_sync(_S1299, _S1300);
                if(_S1300)
                {
                    uint _S1302 = __ballot_sync(_S1299, true);
                }
                else
                {
                    uint _S1303 = __ballot_sync(_S1299, false);
                    uint _S1304 = __ballot_sync(_S1299, false);
                    uint _S1305 = __ballot_sync(_S1133, true);
                    _S1134 = _S1305;
                    break;
                }
                drift_angular_0(c_19, _S1290, tr_3, dv_3, &lu_1, &lv_1);
                uint _S1306 = __ballot_sync(_S1299, true);
                c_19 = c_19 + 256U;
                _S1299 = _S1306;
            }
            group_sum3_0(tid_5, &lu_1, &lv_1, _S1134);
            float3  phi_3 = rows_mul_0((&isl_8)->winv0_0, (&isl_8)->winv1_0, (&isl_8)->winv2_0, lu_1);
            float3  dw_2 = rows_mul_0((&isl_8)->winv0_0, (&isl_8)->winv1_0, (&isl_8)->winv2_0, lv_1);
            uint c_20 = (&isl_8)->range_0.x + tid_5;
            uint _S1307 = _S1134;
            for(;;)
            {
                bool _S1308 = c_20 < ((&isl_8)->range_0.y);
                uint _S1309 = __ballot_sync(_S1307, _S1308);
                if(_S1308)
                {
                    uint _S1310 = __ballot_sync(_S1307, true);
                }
                else
                {
                    uint _S1311 = __ballot_sync(_S1307, false);
                    uint _S1312 = __ballot_sync(_S1307, false);
                    uint _S1313 = __ballot_sync(_S1134, true);
                    _S1135 = _S1313;
                    break;
                }
                drift_apply_0(c_20, _S1290, tr_3, phi_3, dv_3, dw_2);
                uint _S1314 = __ballot_sync(_S1307, true);
                c_20 = c_20 + 256U;
                _S1307 = _S1314;
            }
            bool _S1315 = !driven_0;
            uint _S1316 = __ballot_sync(_S1135, _S1315);
            if(_S1315)
            {
                Island_0 _S1317 = isl_8;
                drift_rigid_0(&_S1317, &rg_7, tr_3, phi_3, dv_3, dw_2);
                uint _S1318 = __ballot_sync(_S1135, true);
            }
            else
            {
                uint _S1319 = __ballot_sync(_S1135, true);
            }
            __syncthreads();
            uint _S1320 = __ballot_sync(_S1250, true);
            c_18 = _S1320;
        }
        else
        {
            uint _S1321 = __ballot_sync(_S1250, true);
            c_18 = _S1321;
        }
        uint _S1322 = __ballot_sync(c_18, _S1145);
        bool _S1323;
        if(_S1145)
        {
            bool _S1324 = ((&isl_8)->probes_0.y) > ((&isl_8)->probes_0.x);
            uint _S1325 = __ballot_sync(c_18, true);
            _S1323 = _S1324;
            _S1288 = _S1325;
        }
        else
        {
            uint _S1326 = __ballot_sync(c_18, true);
            _S1323 = false;
            _S1288 = _S1326;
        }
        uint _S1327 = __ballot_sync(_S1288, _S1323);
        if(_S1323)
        {
            Island_0 _S1328 = isl_8;
            Rigid_0 _S1329 = rg_7;
            record_probes_0(&_S1328, &_S1329, k_18);
            uint _S1330 = __ballot_sync(_S1288, true);
            c_19 = _S1330;
        }
        else
        {
            uint _S1331 = __ballot_sync(_S1288, true);
            c_19 = _S1331;
        }
        uint _S1332 = done_1 + 1U;
        bool _S1333 = (*&g_halt_0) != 0U;
        uint _S1334 = __ballot_sync(c_19, _S1333);
        if(_S1333)
        {
            uint _S1335 = __ballot_sync(c_19, false);
            uint _S1336 = __ballot_sync(_S1184, false);
            uint _S1337 = __ballot_sync(run_0, true);
            done_1 = _S1332;
            cov_0 = _S1337;
            break;
        }
        else
        {
            uint _S1338 = __ballot_sync(c_19, true);
        }
        uint _S1339 = __ballot_sync(_S1184, true);
        done_1 = _S1332;
        woke_1 = woke_0;
        _S1184 = _S1339;
    }
    float3  wsum_0 = make_float3 (work_2, work_err_1, 0.0f);
    float3  unused_1 = make_float3 (0.0f);
    group_sum3_0(tid_5, &wsum_0, &unused_1, cov_0);
    uint _S1340 = __ballot_sync(cov_0, _S1145);
    if(_S1145)
    {
        Quat_0 _S1341 = (&rg_7)->rot_0;
        float4  _S1342 = quat_vec_0(&_S1341);
        (&isl_8)->rotation_0 = _S1342;
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
            _S1140 = contact_island_0;
        }
        else
        {
            _S1140 = false;
        }
        if(_S1140)
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
        uint _S1343 = seen_bits_0();
        if((*&g_halt_0) != 0U)
        {
            cov_0 = 128U;
        }
        else
        {
            cov_0 = 0U;
        }
        uint _S1344 = _S1343 | cov_0;
        if(woke_0)
        {
            cov_0 = 2048U;
        }
        else
        {
            cov_0 = 0U;
        }
        uint cov_1 = _S1344 | cov_0;
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
                _S1140 = !quiet_1;
            }
            else
            {
                _S1140 = false;
            }
            if(_S1140)
            {
                cov_0 = 512U;
            }
            else
            {
                cov_0 = 0U;
            }
            uint cov_3 = cov_2 | cov_0;
            uint _S1345 = __ldg(&globalParams_0->params_0->contact_mode_0);
            if(_S1345 == 1U)
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
        *(&(globalParams_0->islands_0)[_S1137]) = isl_8;
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
    uint _S1346 = table_0 + 4U * g_3;
    uint _S1347 = __ldg((&(globalParams_0->index_0)[_S1346]));
    (&w_8)->island_2 = _S1347;
    uint _S1348 = __ldg((&(globalParams_0->index_0)[_S1346 + 1U]));
    (&w_8)->begin_0 = _S1348;
    uint _S1349 = __ldg((&(globalParams_0->index_0)[_S1346 + 2U]));
    (&w_8)->end_0 = _S1349;
    uint _S1350 = __ldg((&(globalParams_0->index_0)[_S1346 + 3U]));
    (&w_8)->first_0 = _S1350;
    return w_8;
}

static __device__ bool wide_runs_0(Island_0 * isl_9)
{
    uint4  _S1351 = isl_9->info_1;
    bool _S1352;
    if(((isl_9->info_1.z) & 1U) != 0U)
    {
        _S1352 = true;
    }
    else
    {
        _S1352 = (_S1351.y) == 0U;
    }
    if(_S1352)
    {
        return false;
    }
    if(((_S1351.x) & 4U) == 0U)
    {
        _S1352 = true;
    }
    else
    {
        bool _S1353 = contact_stopped_0(isl_9);
        _S1352 = !_S1353;
    }
    return _S1352;
}

__device__ __shared__ uint g_wide_run_0;

static __device__ bool wide_enter_0(uint tid_6, Island_0 * isl_10)
{
    seen_clear_0(tid_6);
    if(tid_6 == 0U)
    {
        bool _S1354 = wide_runs_0(isl_10);
        int _S1355;
        if(_S1354)
        {
            _S1355 = int(1);
        }
        else
        {
            _S1355 = int(0);
        }
        *&g_wide_run_0 = uint(_S1355);
    }
    __syncthreads();
    return (*&g_wide_run_0) != 0U;
}

static __device__ uint wide_step_0(Island_0 * isl_11)
{
    uint _S1356 = isl_11->info_1.w;
    uint _S1357 = __ldg(&globalParams_0->params_0->step_start_0);
    return _S1356 - _S1357;
}

static __device__ bool wide_enter_1(uint _S1358, uint _S1359)
{
    Island_0 _S1360 = *(&(globalParams_0->islands_0)[_S1359]);
    seen_clear_0(_S1358);
    if(_S1358 == 0U)
    {
        Island_0 _S1361 = _S1360;
        bool _S1362 = wide_runs_0(&_S1361);
        int _S1363;
        if(_S1362)
        {
            _S1363 = int(1);
        }
        else
        {
            _S1363 = int(0);
        }
        *&g_wide_run_0 = uint(_S1363);
    }
    __syncthreads();
    return (*&g_wide_run_0) != 0U;
}

extern "C" __global__ void wide_wake()
{
    uint _S1364 = 0U;
    uint _S1365;
    uint _S1366 = __ballot_sync(4294967295U, true);
    uint tid_7 = threadIdx.x;
    uint _S1367 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1368 = blockIdx.x;
    WideGroup_0 wg_0 = wide_group_0(_S1367, _S1368);
    bool _S1369 = _S1368 != (wg_0.first_0);
    uint _S1370 = __ballot_sync(_S1366, _S1369);
    if(_S1369)
    {
        return;
    }
    else
    {
        uint _S1371 = __ballot_sync(_S1366, true);
        _S1364 = _S1371;
    }
    Island_0 * _S1372 = (&(globalParams_0->islands_0)[wg_0.island_2]);
    Island_0 isl_12 = *_S1372;
    uint _S1373 = (*_S1372).info_1.x;
    bool _S1374 = (_S1373 & 16U) == 0U;
    uint _S1375 = __ballot_sync(_S1364, _S1374);
    bool _S1376;
    uint c_21;
    if(_S1374)
    {
        uint _S1377 = __ballot_sync(_S1364, true);
        _S1376 = true;
        c_21 = _S1377;
    }
    else
    {
        bool _S1378 = wide_enter_1(tid_7, wg_0.island_2);
        bool _S1379 = !_S1378;
        uint _S1380 = __ballot_sync(_S1364, true);
        _S1376 = _S1379;
        c_21 = _S1380;
    }
    uint _S1381 = 0U;
    uint _S1382 = __ballot_sync(c_21, _S1376);
    if(_S1376)
    {
        return;
    }
    else
    {
        uint _S1383 = __ballot_sync(c_21, true);
        _S1381 = _S1383;
    }
    Quat_0 _S1384 = quat_of_0(isl_12.rotation_0);
    bool _S1385 = (_S1373 & 4U) != 0U;
    float3  _S1386 = make_float3 (0.0f);
    float3  norm_1 = _S1386;
    float3  unused_2 = _S1386;
    c_21 = isl_12.range_0.x + tid_7;
    uint cov_5;
    cov_5 = _S1381;
    for(;;)
    {
        bool _S1387 = c_21 < (isl_12.range_0.y);
        uint _S1388 = __ballot_sync(cov_5, _S1387);
        if(_S1387)
        {
            uint _S1389 = __ballot_sync(cov_5, true);
        }
        else
        {
            uint _S1390 = __ballot_sync(cov_5, false);
            uint _S1391 = __ballot_sync(cov_5, false);
            uint _S1392 = __ballot_sync(_S1381, true);
            _S1365 = _S1392;
            break;
        }
        Island_0 _S1393 = isl_12;
        uint _S1394 = wide_step_0(&_S1393);
        float _S1395 = __ldg(&globalParams_0->params_0->dt_0);
        Quat_0 _S1396 = _S1384;
        float _S1397 = settled_chunk_load_0(c_21, &_S1396, _S1394, _S1395, _S1385);
        *&((&norm_1)->x) = *&((&norm_1)->x) + _S1397;
        uint _S1398 = __ballot_sync(cov_5, true);
        c_21 = c_21 + 256U;
        cov_5 = _S1398;
    }
    group_sum3_0(tid_7, &norm_1, &unused_2, _S1365);
    bool _S1399 = tid_7 != 0U;
    uint _S1400 = __ballot_sync(_S1365, _S1399);
    if(_S1399)
    {
        return;
    }
    uint cov_6 = 1024U | (seen_bits_0());
    uint _S1401 = __ldg(&globalParams_0->params_0->solve_mode_0);
    if(_S1401 == 1U)
    {
        _S1376 = (F32_abs((norm_1.x - isl_12.energy_1.z))) > (isl_12.energy_1.w);
    }
    else
    {
        _S1376 = false;
    }
    if(_S1376)
    {
        *&((&(&(globalParams_0->islands_0)[wg_0.island_2])->info_1)->x) = _S1373 & 4294967279U;
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
    uint _S1402 = __ldg(&globalParams_0->params_0->wide_base_0);
    uint _S1403 = 8U * slot_1;
    *(&(globalParams_0->scratch_0)[_S1402 + _S1403 + p_12]) = make_float4 (a_15.x, a_15.y, a_15.z, 0.0f);
    uint _S1404 = __ldg(&globalParams_0->params_0->wide_base_0);
    *(&(globalParams_0->scratch_0)[_S1404 + _S1403 + p_12 + 1U]) = make_float4 (b_30.x, b_30.y, b_30.z, 0.0f);
    return;
}

extern "C" __global__ void wide_bonds()
{
    uint _S1405 = __ballot_sync(4294967295U, true);
    uint tid_8 = threadIdx.x;
    uint _S1406 = blockIdx.x;
    uint _S1407 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
    bool bond_group_0 = _S1406 < _S1407;
    uint _S1408 = __ballot_sync(_S1405, bond_group_0);
    WideGroup_0 wg_1;
    uint _S1409;
    if(bond_group_0)
    {
        uint _S1410 = __ldg(&globalParams_0->params_0->wide_bond_table_0);
        WideGroup_0 _S1411 = wide_group_0(_S1410, _S1406);
        uint _S1412 = __ballot_sync(_S1405, true);
        wg_1 = _S1411;
        _S1409 = _S1412;
    }
    else
    {
        uint _S1413 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
        uint _S1414 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
        WideGroup_0 _S1415 = wide_group_0(_S1413, _S1406 - _S1414);
        uint _S1416 = __ballot_sync(_S1405, true);
        wg_1 = _S1415;
        _S1409 = _S1416;
    }
    uint _S1417 = 0U;
    WideGroup_0 _S1418 = wg_1;
    Island_0 isl_13 = *(&(globalParams_0->islands_0)[wg_1.island_2]);
    bool _S1419 = wide_enter_1(tid_8, wg_1.island_2);
    bool _S1420 = !_S1419;
    uint _S1421 = __ballot_sync(_S1409, _S1420);
    if(_S1420)
    {
        return;
    }
    else
    {
        uint _S1422 = __ballot_sync(_S1409, true);
        _S1417 = _S1422;
    }
    uint _S1423 = 0U;
    Island_0 _S1424 = isl_13;
    uint _S1425 = wide_step_0(&_S1424);
    uint _S1426 = __ballot_sync(_S1417, bond_group_0);
    if(bond_group_0)
    {
        if(((isl_13.info_1.x) & 16U) != 0U)
        {
            return;
        }
        uint i_17 = wg_1.begin_0 + tid_8;
        bool _S1427;
        if(i_17 < (wg_1.end_0))
        {
            float _S1428 = __ldg(&globalParams_0->params_0->dt_0);
            uint _S1429 = __ldg(&globalParams_0->params_0->fracture_0);
            bool _S1430 = bond_update_0(i_17, _S1428, _S1429 != 0U, isl_13.info_1.w + 1U, true);
            _S1427 = _S1430;
        }
        else
        {
            _S1427 = false;
        }
        if(_S1427)
        {
            *&((&(&(globalParams_0->islands_0)[_S1418.island_2])->info_1)->z) = (isl_13.info_1.z) | 2U;
        }
        return;
    }
    else
    {
        uint _S1431 = __ballot_sync(_S1417, true);
        _S1423 = _S1431;
    }
    uint _S1432 = 0U;
    uint _S1433 = isl_13.info_1.x;
    bool _S1434 = (_S1433 & 1U) != 0U;
    uint _S1435 = __ballot_sync(_S1423, _S1434);
    if(_S1434)
    {
        return;
    }
    else
    {
        uint _S1436 = __ballot_sync(_S1423, true);
        _S1432 = _S1436;
    }
    float3  _S1437 = make_float3 (0.0f);
    float3  f_16 = _S1437;
    float3  t_13 = _S1437;
    uint c_22 = wg_1.begin_0 + tid_8;
    bool _S1438 = c_22 < (wg_1.end_0);
    uint _S1439 = __ballot_sync(_S1432, _S1438);
    if(_S1438)
    {
        Island_0 _S1440 = isl_13;
        Rigid_0 _S1441 = rigid_of_0(&_S1440);
        float _S1442 = __ldg(&globalParams_0->params_0->dt_0);
        bool _S1443 = (_S1433 & 4U) != 0U;
        Island_0 _S1444 = isl_13;
        Rigid_0 _S1445 = _S1441;
        net_load_0(c_22, &_S1444, &_S1445, _S1425, _S1442, _S1443, &f_16, &t_13);
        uint _S1446 = __ballot_sync(_S1432, true);
        _S1409 = _S1446;
    }
    else
    {
        uint _S1447 = __ballot_sync(_S1432, true);
        _S1409 = _S1447;
    }
    group_sum3_0(tid_8, &f_16, &t_13, _S1409);
    bool _S1448 = tid_8 == 0U;
    uint _S1449 = __ballot_sync(_S1409, _S1448);
    if(_S1448)
    {
        uint _S1450 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
        wide_store_0(_S1406 - _S1450, 0U, f_16, t_13);
    }
    return;
}

static __device__ void wide_partials_0(uint tid_9, uint first_1, uint count_5, uint p_13, float3  * a_16, float3  * b_31, uint _S1451)
{
    uint _S1452;
    float4  _S1453 = make_float4 (0.0f);
    float4  x_24 = _S1453;
    float4  y_5 = _S1453;
    uint s_7 = tid_9;
    uint _S1454 = _S1451;
    for(;;)
    {
        bool _S1455 = s_7 < count_5;
        uint _S1456 = __ballot_sync(_S1454, _S1455);
        if(_S1455)
        {
            uint _S1457 = __ballot_sync(_S1454, true);
        }
        else
        {
            uint _S1458 = __ballot_sync(_S1454, false);
            uint _S1459 = __ballot_sync(_S1454, false);
            uint _S1460 = __ballot_sync(_S1451, true);
            _S1452 = _S1460;
            break;
        }
        uint _S1461 = __ldg(&globalParams_0->params_0->wide_base_0);
        uint _S1462 = 8U * (first_1 + s_7);
        x_24 = x_24 + *(&(globalParams_0->scratch_0)[_S1461 + _S1462 + p_13]);
        uint _S1463 = __ldg(&globalParams_0->params_0->wide_base_0);
        y_5 = y_5 + *(&(globalParams_0->scratch_0)[_S1463 + _S1462 + p_13 + 1U]);
        uint _S1464 = __ballot_sync(_S1454, true);
        s_7 = s_7 + 256U;
        _S1454 = _S1464;
    }
    group_sum2_0(tid_9, &x_24, &y_5, _S1452);
    float4  _S1465 = x_24;
    *a_16 = float3 {_S1465.x, _S1465.y, _S1465.z};
    float4  _S1466 = y_5;
    *b_31 = float3 {_S1466.x, _S1466.y, _S1466.z};
    return;
}

static __device__ Rigid_0 wide_rigid_frame_0(uint tid_10, Island_0 * isl_14, WideGroup_0 * wg_2, uint _S1467)
{
    Rigid_0 _S1468 = rigid_of_0(isl_14);
    Rigid_0 rg_8 = _S1468;
    bool _S1469 = ((isl_14->info_1.x) & 1U) == 0U;
    uint _S1470 = __ballot_sync(_S1467, _S1469);
    if(_S1469)
    {
        float3  f_17;
        float3  t_14;
        wide_partials_0(tid_10, wg_2->first_0, isl_14->wide_groups_0, 0U, &f_17, &t_14, _S1470);
        rigid_acceleration_0(isl_14, &rg_8, f_17, t_14);
        uint _S1471 = __ballot_sync(_S1467, true);
    }
    return rg_8;
}

extern "C" __global__ void wide_chunks()
{
    uint _S1472 = 0U;
    uint _S1473 = __ballot_sync(4294967295U, true);
    uint tid_11 = threadIdx.x;
    uint _S1474 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1475 = blockIdx.x;
    WideGroup_0 wg_3 = wide_group_0(_S1474, _S1475);
    Island_0 isl_15 = *(&(globalParams_0->islands_0)[wg_3.island_2]);
    bool _S1476 = wide_enter_1(tid_11, wg_3.island_2);
    bool _S1477 = !_S1476;
    uint _S1478 = __ballot_sync(_S1473, _S1477);
    if(_S1477)
    {
        return;
    }
    else
    {
        uint _S1479 = __ballot_sync(_S1473, true);
        _S1472 = _S1479;
    }
    uint _S1480 = 0U;
    uint _S1481 = isl_15.info_1.x;
    bool anchored_0 = (_S1481 & 1U) != 0U;
    bool _S1482 = (_S1481 & 16U) != 0U;
    uint _S1483 = __ballot_sync(_S1472, _S1482);
    if(_S1482)
    {
        if(tid_11 == 0U)
        {
            uint _S1484 = __ldg(&globalParams_0->params_0->wide_base_0);
            *(&(globalParams_0->scratch_0)[_S1484 + 8U * _S1475 + 6U]) = make_float4 (0.0f);
        }
        return;
    }
    else
    {
        uint _S1485 = __ballot_sync(_S1472, true);
        _S1480 = _S1485;
    }
    Island_0 _S1486 = isl_15;
    WideGroup_0 _S1487 = wg_3;
    Rigid_0 _S1488 = wide_rigid_frame_0(tid_11, &_S1486, &_S1487, _S1480);
    float work_3 = 0.0f;
    float work_err_2 = 0.0f;
    float3  _S1489 = make_float3 (0.0f);
    float3  tu_2 = _S1489;
    float3  pv_2 = _S1489;
    uint c_23 = wg_3.begin_0 + tid_11;
    bool _S1490 = c_23 < (wg_3.end_0);
    uint _S1491 = __ballot_sync(_S1480, _S1490);
    uint _S1492;
    if(_S1490)
    {
        float _S1493 = __ldg(&globalParams_0->params_0->dt_0);
        uint _S1494 = __ldg(&globalParams_0->params_0->rigid_motion_loads_0);
        bool _S1495 = _S1494 != 0U;
        Island_0 _S1496 = isl_15;
        uint _S1497 = wide_step_0(&_S1496);
        bool _S1498 = (_S1481 & 4U) != 0U;
        Island_0 _S1499 = isl_15;
        Rigid_0 _S1500 = _S1488;
        chunk_update_0(c_23, &_S1499, &_S1500, _S1493, _S1495, _S1497, _S1498, &work_3, &work_err_2);
        bool _S1501 = !anchored_0;
        uint _S1502 = __ballot_sync(_S1491, _S1501);
        if(_S1501)
        {
            drift_moments_0(c_23, &tu_2, &pv_2);
            uint _S1503 = __ballot_sync(_S1491, true);
        }
        else
        {
            uint _S1504 = __ballot_sync(_S1491, true);
        }
        uint _S1505 = __ballot_sync(_S1480, true);
        _S1492 = _S1505;
    }
    else
    {
        uint _S1506 = __ballot_sync(_S1480, true);
        _S1492 = _S1506;
    }
    float3  wsum_1 = make_float3 (work_3, work_err_2, 0.0f);
    float3  unused_3 = _S1489;
    group_sum3_0(tid_11, &wsum_1, &unused_3, _S1492);
    bool _S1507 = !anchored_0;
    uint _S1508 = __ballot_sync(_S1492, _S1507);
    if(_S1507)
    {
        group_sum3_0(tid_11, &tu_2, &pv_2, _S1508);
        uint _S1509 = __ballot_sync(_S1492, true);
    }
    if(tid_11 == 0U)
    {
        uint _S1510 = __ldg(&globalParams_0->params_0->wide_base_0);
        uint _S1511 = 8U * _S1475;
        *(&(globalParams_0->scratch_0)[_S1510 + _S1511 + 6U]) = make_float4 (wsum_1.x, wsum_1.y, wsum_1.z, 0.0f);
        if(_S1507)
        {
            wide_store_0(_S1475, 2U, tu_2, pv_2);
        }
        uint _S1512 = __ldg(&globalParams_0->params_0->wide_base_0);
        *(&(globalParams_0->scratch_0)[_S1512 + _S1511 + 7U]) = make_float4 (float((*&g_seen_0)[0U]), float((*&g_seen_0)[1U]), float((*&g_seen_0)[2U]), 0.0f);
    }
    return;
}

extern "C" __global__ void wide_drift()
{
    uint _S1513 = __ballot_sync(4294967295U, true);
    uint tid_12 = threadIdx.x;
    uint _S1514 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1515 = blockIdx.x;
    WideGroup_0 wg_4 = wide_group_0(_S1514, _S1515);
    Island_0 * _S1516 = (&(globalParams_0->islands_0)[wg_4.island_2]);
    Island_0 isl_16 = *_S1516;
    bool _S1517 = (((*_S1516).info_1.x) & 17U) != 0U;
    uint _S1518 = __ballot_sync(_S1513, _S1517);
    bool _S1519;
    uint _S1520;
    if(_S1517)
    {
        uint _S1521 = __ballot_sync(_S1513, true);
        _S1519 = true;
        _S1520 = _S1521;
    }
    else
    {
        bool _S1522 = wide_enter_1(tid_12, wg_4.island_2);
        bool _S1523 = !_S1522;
        uint _S1524 = __ballot_sync(_S1513, true);
        _S1519 = _S1523;
        _S1520 = _S1524;
    }
    uint _S1525 = 0U;
    uint _S1526 = __ballot_sync(_S1520, _S1519);
    if(_S1519)
    {
        return;
    }
    else
    {
        uint _S1527 = __ballot_sync(_S1520, true);
        _S1525 = _S1527;
    }
    float3  tu_3;
    float3  pv_3;
    wide_partials_0(tid_12, wg_4.first_0, isl_16.wide_groups_0, 2U, &tu_3, &pv_3, _S1525);
    float _S1528 = isl_16.wcom_0.w;
    float3  tr_4 = tu_3 / make_float3 (_S1528);
    float3  dv_4 = pv_3 / make_float3 (_S1528);
    float3  _S1529 = make_float3 (0.0f);
    float3  lu_2 = _S1529;
    float3  lv_2 = _S1529;
    uint c_24 = wg_4.begin_0 + tid_12;
    bool _S1530 = c_24 < (wg_4.end_0);
    uint _S1531 = __ballot_sync(_S1525, _S1530);
    if(_S1530)
    {
        float4  _S1532 = isl_16.wcom_0;
        drift_angular_0(c_24, float3 {_S1532.x, _S1532.y, _S1532.z}, tr_4, dv_4, &lu_2, &lv_2);
        uint _S1533 = __ballot_sync(_S1525, true);
        _S1520 = _S1533;
    }
    else
    {
        uint _S1534 = __ballot_sync(_S1525, true);
        _S1520 = _S1534;
    }
    group_sum3_0(tid_12, &lu_2, &lv_2, _S1520);
    bool _S1535 = tid_12 == 0U;
    uint _S1536 = __ballot_sync(_S1520, _S1535);
    if(_S1535)
    {
        wide_store_0(_S1515, 4U, lu_2, lv_2);
    }
    return;
}

extern "C" __global__ void wide_rigid()
{
    uint _S1537 = __ballot_sync(4294967295U, true);
    uint tid_13 = threadIdx.x;
    uint _S1538 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1539 = blockIdx.x;
    WideGroup_0 wg_5 = wide_group_0(_S1538, _S1539);
    Island_0 * _S1540 = (&(globalParams_0->islands_0)[wg_5.island_2]);
    Island_0 isl_17 = *_S1540;
    uint _S1541 = (*_S1540).info_1.x;
    bool _S1542 = (_S1541 & 1U) != 0U;
    uint _S1543 = __ballot_sync(_S1537, _S1542);
    bool _S1544;
    uint _S1545;
    if(_S1542)
    {
        uint _S1546 = __ballot_sync(_S1537, true);
        _S1544 = true;
        _S1545 = _S1546;
    }
    else
    {
        bool _S1547 = wide_enter_1(tid_13, wg_5.island_2);
        bool _S1548 = !_S1547;
        uint _S1549 = __ballot_sync(_S1537, true);
        _S1544 = _S1548;
        _S1545 = _S1549;
    }
    uint _S1550 = 0U;
    uint _S1551 = __ballot_sync(_S1545, _S1544);
    if(_S1544)
    {
        return;
    }
    else
    {
        uint _S1552 = __ballot_sync(_S1545, true);
        _S1550 = _S1552;
    }
    uint _S1553 = 0U;
    bool _S1554 = (_S1541 & 16U) != 0U;
    uint _S1555 = __ballot_sync(_S1550, _S1554);
    if(_S1554)
    {
        uint _S1556 = 0U;
        bool _S1557 = _S1539 != (wg_5.first_0);
        uint _S1558 = __ballot_sync(_S1555, _S1557);
        if(_S1557)
        {
            return;
        }
        else
        {
            uint _S1559 = __ballot_sync(_S1555, true);
            _S1556 = _S1559;
        }
        Island_0 _S1560 = isl_17;
        WideGroup_0 _S1561 = wg_5;
        Rigid_0 _S1562 = wide_rigid_frame_0(tid_13, &_S1560, &_S1561, _S1556);
        Rigid_0 rs_0 = _S1562;
        bool _S1563 = tid_13 != 0U;
        uint _S1564 = __ballot_sync(_S1556, _S1563);
        if(_S1563)
        {
            _S1544 = true;
        }
        else
        {
            _S1544 = (_S1541 & 2U) != 0U;
        }
        if(_S1544)
        {
            return;
        }
        float _S1565 = __ldg(&globalParams_0->params_0->dt_0);
        Island_0 _S1566 = isl_17;
        integrate_rigid_0(&_S1566, &rs_0, _S1565);
        Quat_0 _S1567 = (&rs_0)->rot_0;
        float4  _S1568 = quat_vec_0(&_S1567);
        (&(globalParams_0->islands_0)[wg_5.island_2])->rotation_0 = _S1568;
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
        uint _S1569 = __ballot_sync(_S1550, true);
        _S1553 = _S1569;
    }
    float3  tu_4;
    float3  pv_4;
    wide_partials_0(tid_13, wg_5.first_0, isl_17.wide_groups_0, 2U, &tu_4, &pv_4, _S1553);
    float3  lu_3;
    float3  lv_3;
    wide_partials_0(tid_13, wg_5.first_0, isl_17.wide_groups_0, 4U, &lu_3, &lv_3, _S1553);
    float _S1570 = isl_17.wcom_0.w;
    float3  tr_5 = tu_4 / make_float3 (_S1570);
    float3  dv_5 = pv_4 / make_float3 (_S1570);
    float3  phi_4 = rows_mul_0(isl_17.winv0_0, isl_17.winv1_0, isl_17.winv2_0, lu_3);
    float3  dw_3 = rows_mul_0(isl_17.winv0_0, isl_17.winv1_0, isl_17.winv2_0, lv_3);
    uint c_25 = wg_5.begin_0 + tid_13;
    bool _S1571 = c_25 < (wg_5.end_0);
    uint _S1572 = __ballot_sync(_S1553, _S1571);
    if(_S1571)
    {
        float4  _S1573 = isl_17.wcom_0;
        drift_apply_0(c_25, float3 {_S1573.x, _S1573.y, _S1573.z}, tr_5, phi_4, dv_5, dw_3);
        uint _S1574 = __ballot_sync(_S1553, true);
        _S1545 = _S1574;
    }
    else
    {
        uint _S1575 = __ballot_sync(_S1553, true);
        _S1545 = _S1575;
    }
    uint _S1576 = 0U;
    bool _S1577 = _S1539 != (wg_5.first_0);
    uint _S1578 = __ballot_sync(_S1545, _S1577);
    if(_S1577)
    {
        return;
    }
    else
    {
        uint _S1579 = __ballot_sync(_S1545, true);
        _S1576 = _S1579;
    }
    Island_0 _S1580 = isl_17;
    WideGroup_0 _S1581 = wg_5;
    Rigid_0 _S1582 = wide_rigid_frame_0(tid_13, &_S1580, &_S1581, _S1576);
    Rigid_0 rg_9 = _S1582;
    bool _S1583 = tid_13 != 0U;
    uint _S1584 = __ballot_sync(_S1576, _S1583);
    if(_S1583)
    {
        return;
    }
    if(!((_S1541 & 2U) != 0U))
    {
        float _S1585 = __ldg(&globalParams_0->params_0->dt_0);
        Island_0 _S1586 = isl_17;
        integrate_rigid_0(&_S1586, &rg_9, _S1585);
        Island_0 _S1587 = isl_17;
        drift_rigid_0(&_S1587, &rg_9, tr_5, phi_4, dv_5, dw_3);
    }
    Quat_0 _S1588 = (&rg_9)->rot_0;
    float4  _S1589 = quat_vec_0(&_S1588);
    (&(globalParams_0->islands_0)[wg_5.island_2])->rotation_0 = _S1589;
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
    uint _S1590 = 0U;
    uint _S1591 = __ballot_sync(4294967295U, true);
    uint tid_14 = threadIdx.x;
    uint _S1592 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1593 = blockIdx.x;
    WideGroup_0 wg_6 = wide_group_0(_S1592, _S1593);
    bool _S1594 = _S1593 != (wg_6.first_0);
    uint _S1595 = __ballot_sync(_S1591, _S1594);
    if(_S1594)
    {
        return;
    }
    else
    {
        uint _S1596 = __ballot_sync(_S1591, true);
        _S1590 = _S1596;
    }
    uint _S1597 = 0U;
    Island_0 * _S1598 = (&(globalParams_0->islands_0)[wg_6.island_2]);
    Island_0 isl_18 = *_S1598;
    Island_0 _S1599 = *_S1598;
    bool _S1600 = wide_enter_0(tid_14, &_S1599);
    bool _S1601 = !_S1600;
    uint _S1602 = __ballot_sync(_S1590, _S1601);
    if(_S1601)
    {
        return;
    }
    else
    {
        uint _S1603 = __ballot_sync(_S1590, true);
        _S1597 = _S1603;
    }
    float3  work_4;
    float3  flags_2;
    wide_partials_0(tid_14, wg_6.first_0, (&isl_18)->wide_groups_0, 6U, &work_4, &flags_2, _S1597);
    bool _S1604 = tid_14 != 0U;
    uint _S1605 = __ballot_sync(_S1597, _S1604);
    if(_S1604)
    {
        return;
    }
    Island_0 _S1606 = isl_18;
    uint _S1607 = wide_step_0(&_S1606);
    if(((&isl_18)->probes_0.y) > ((&isl_18)->probes_0.x))
    {
        Island_0 _S1608 = isl_18;
        Rigid_0 _S1609 = rigid_of_0(&_S1608);
        Island_0 _S1610 = isl_18;
        Rigid_0 _S1611 = _S1609;
        record_probes_0(&_S1610, &_S1611, _S1607);
    }
    bool halt_0 = (((&isl_18)->info_1.z) & 2U) != 0U;
    bool _S1612;
    if(halt_0)
    {
        _S1612 = (((&isl_18)->info_1.x) & 4U) != 0U;
    }
    else
    {
        _S1612 = false;
    }
    if(_S1612)
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
    uint _S1613;
    if(halt_0)
    {
        _S1613 = 128U;
    }
    else
    {
        _S1613 = 0U;
    }
    uint _S1614 = 256U | _S1613;
    if(((&isl_18)->probes_0.y) > ((&isl_18)->probes_0.x))
    {
        _S1613 = 262144U;
    }
    else
    {
        _S1613 = 0U;
    }
    uint _S1615 = _S1614 | _S1613;
    if((((&isl_18)->info_1.x) & 4U) != 0U)
    {
        _S1613 = 524288U;
    }
    else
    {
        _S1613 = 0U;
    }
    uint _S1616 = _S1615 | _S1613;
    if((flags_2.x) > 0.0f)
    {
        _S1613 = 32768U;
    }
    else
    {
        _S1613 = 0U;
    }
    uint _S1617 = _S1616 | _S1613;
    if((flags_2.y) > 0.0f)
    {
        _S1613 = 65536U;
    }
    else
    {
        _S1613 = 0U;
    }
    uint _S1618 = _S1617 | _S1613;
    if((flags_2.z) > 0.0f)
    {
        _S1613 = 131072U;
    }
    else
    {
        _S1613 = 0U;
    }
    (&isl_18)->coverage_0 = ((&isl_18)->coverage_0) | (_S1618 | _S1613);
    *(&(globalParams_0->islands_0)[wg_6.island_2]) = isl_18;
    return;
}

static __device__ uint sv_0(uint c_26, uint slot_2)
{
    uint _S1619 = __ldg(&globalParams_0->params_0->statics_base_0);
    return _S1619 + 23U * c_26 + slot_2;
}

static __device__ void project_load_slot_0(uint tid_15, Island_0 * isl_19, uint slot_3, uint _S1620)
{
    uint _S1621;
    uint _S1622;
    float3  _S1623 = make_float3 (0.0f);
    float3  net_f_0 = _S1623;
    float3  net_m_0 = _S1623;
    uint4  _S1624 = isl_19->range_0;
    uint _S1625 = isl_19->range_0.x + tid_15;
    uint c_27 = _S1625;
    uint _S1626 = _S1620;
    for(;;)
    {
        uint _S1627 = _S1624.y;
        _S1621 = _S1627;
        bool _S1628 = c_27 < _S1627;
        uint _S1629 = __ballot_sync(_S1626, _S1628);
        if(_S1628)
        {
            uint _S1630 = __ballot_sync(_S1626, true);
        }
        else
        {
            uint _S1631 = __ballot_sync(_S1626, false);
            uint _S1632 = __ballot_sync(_S1626, false);
            uint _S1633 = __ballot_sync(_S1620, true);
            _S1622 = _S1633;
            break;
        }
        float4  _S1634 = *(&(globalParams_0->scratch_0)[sv_0(c_27, slot_3)]);
        float3  fi_1 = float3 {_S1634.x, _S1634.y, _S1634.z};
        net_f_0 = net_f_0 + fi_1;
        float4  _S1635 = __ldg(&(&(globalParams_0->chunks_0)[c_27])->center_0);
        float4  _S1636 = isl_19->com_0;
        float4  _S1637 = *(&(globalParams_0->scratch_0)[sv_0(c_27, slot_3 + 1U)]);
        net_m_0 = net_m_0 + (cross_0(float3 {_S1635.x, _S1635.y, _S1635.z} - float3 {_S1636.x, _S1636.y, _S1636.z}, fi_1) + float3 {_S1637.x, _S1637.y, _S1637.z});
        uint _S1638 = __ballot_sync(_S1626, true);
        c_27 = c_27 + 256U;
        _S1626 = _S1638;
    }
    group_sum3_0(tid_15, &net_f_0, &net_m_0, _S1622);
    float4  _S1639 = isl_19->com_0;
    float3  _S1640 = net_f_0 / make_float3 (isl_19->com_0.w);
    float3  _S1641 = rows_mul_0(isl_19->inv0_1, isl_19->inv1_1, isl_19->inv2_1, net_m_0);
    c_27 = _S1625;
    for(;;)
    {
        if(c_27 < _S1621)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_0 * _S1642 = (&(globalParams_0->chunks_0)[c_27]);
        float4  _S1643 = __ldg(&_S1642->center_0);
        uint _S1644 = sv_0(c_27, slot_3);
        float4  _S1645 = *(&(globalParams_0->scratch_0)[_S1644]);
        *(&(globalParams_0->scratch_0)[_S1644]) = make_float4 ((float3 {_S1645.x, _S1645.y, _S1645.z} - (_S1640 + cross_0(_S1641, float3 {_S1643.x, _S1643.y, _S1643.z} - float3 {_S1639.x, _S1639.y, _S1639.z})) * make_float3 (_S1643.w)).x, (float3 {_S1645.x, _S1645.y, _S1645.z} - (_S1640 + cross_0(_S1641, float3 {_S1643.x, _S1643.y, _S1643.z} - float3 {_S1639.x, _S1639.y, _S1639.z})) * make_float3 (_S1643.w)).y, (float3 {_S1645.x, _S1645.y, _S1645.z} - (_S1640 + cross_0(_S1641, float3 {_S1643.x, _S1643.y, _S1643.z} - float3 {_S1639.x, _S1639.y, _S1639.z})) * make_float3 (_S1643.w)).z, 0.0f);
        uint _S1646 = sv_0(c_27, slot_3 + 1U);
        float4  * _S1647 = (&(globalParams_0->scratch_0)[_S1646]);
        float4  _S1648 = *(&(globalParams_0->scratch_0)[_S1646]);
        float3  _S1649 = float3 {_S1648.x, _S1648.y, _S1648.z};
        float4  _S1650 = __ldg(&_S1642->inertia0_0);
        float4  _S1651 = __ldg(&_S1642->inertia1_0);
        float4  _S1652 = __ldg(&_S1642->inertia2_0);
        *_S1647 = make_float4 ((_S1649 - rows_mul_0(_S1650, _S1651, _S1652, _S1641)).x, (_S1649 - rows_mul_0(_S1650, _S1651, _S1652, _S1641)).y, (_S1649 - rows_mul_0(_S1650, _S1651, _S1652, _S1641)).z, 0.0f);
        c_27 = c_27 + 256U;
    }
    __syncthreads();
    return;
}

static __device__ float island_dot_0(uint tid_16, uint c0_0, uint c1_0, uint sa_2, uint sb_2, uint _S1653)
{
    uint _S1654;
    float4  _S1655 = make_float4 (0.0f);
    float4  acc_0 = _S1655;
    float4  unused_4 = _S1655;
    uint c_28 = c0_0 + tid_16;
    uint _S1656 = _S1653;
    for(;;)
    {
        bool _S1657 = c_28 < c1_0;
        uint _S1658 = __ballot_sync(_S1656, _S1657);
        if(_S1657)
        {
            uint _S1659 = __ballot_sync(_S1656, true);
        }
        else
        {
            uint _S1660 = __ballot_sync(_S1656, false);
            uint _S1661 = __ballot_sync(_S1656, false);
            uint _S1662 = __ballot_sync(_S1653, true);
            _S1654 = _S1662;
            break;
        }
        float4  _S1663 = *(&(globalParams_0->scratch_0)[sv_0(c_28, sa_2)]);
        float4  _S1664 = *(&(globalParams_0->scratch_0)[sv_0(c_28, sb_2)]);
        float4  _S1665 = *(&(globalParams_0->scratch_0)[sv_0(c_28, sa_2 + 1U)]);
        float4  _S1666 = *(&(globalParams_0->scratch_0)[sv_0(c_28, sb_2 + 1U)]);
        *&((&acc_0)->x) = *&((&acc_0)->x) + (dot_0(float3 {_S1663.x, _S1663.y, _S1663.z}, float3 {_S1664.x, _S1664.y, _S1664.z}) + dot_0(float3 {_S1665.x, _S1665.y, _S1665.z}, float3 {_S1666.x, _S1666.y, _S1666.z}));
        uint _S1667 = __ballot_sync(_S1656, true);
        c_28 = c_28 + 256U;
        _S1656 = _S1667;
    }
    group_sum2_0(tid_16, &acc_0, &unused_4, _S1654);
    return acc_0.x;
}

static __device__ void static_kinematics_0(uint _S1668, float3  * _S1669, float3  * _S1670)
{
    BondStatic_0 * _S1671 = (&(globalParams_0->bonds_0)[_S1668]);
    JointBond_0 _S1672 = slang_ldg_0(&_S1671->law_0);
    uint ca_1 = _S1672.ids_0.y;
    uint cb_1 = _S1672.ids_0.z;
    uint _S1673 = 4U * cb_1;
    float4  _S1674 = *(&(globalParams_0->state_0)[_S1673]);
    uint _S1675 = 4U * ca_1;
    float4  _S1676 = *(&(globalParams_0->state_0)[_S1675]);
    float4  _S1677 = *(&(globalParams_0->scratch_0)[sv_0(cb_1, 21U)]);
    float4  _S1678 = *(&(globalParams_0->scratch_0)[sv_0(ca_1, 21U)]);
    float3  du_0 = float3 {_S1674.x, _S1674.y, _S1674.z} - float3 {_S1676.x, _S1676.y, _S1676.z} + (float3 {_S1677.x, _S1677.y, _S1677.z} - float3 {_S1678.x, _S1678.y, _S1678.z});
    uint _S1679 = _S1673 + 1U;
    float4  _S1680 = *(&(globalParams_0->state_0)[_S1679]);
    uint _S1681 = _S1675 + 1U;
    float4  _S1682 = *(&(globalParams_0->state_0)[_S1681]);
    uint _S1683 = sv_0(cb_1, 22U);
    float4  _S1684 = *(&(globalParams_0->scratch_0)[_S1683]);
    uint _S1685 = sv_0(ca_1, 22U);
    float4  _S1686 = *(&(globalParams_0->scratch_0)[_S1685]);
    float3  dth_0 = float3 {_S1680.x, _S1680.y, _S1680.z} - float3 {_S1682.x, _S1682.y, _S1682.z} + (float3 {_S1684.x, _S1684.y, _S1684.z} - float3 {_S1686.x, _S1686.y, _S1686.z});
    float4  _S1687 = *(&(globalParams_0->state_0)[_S1681]);
    float4  _S1688 = *(&(globalParams_0->scratch_0)[_S1685]);
    float3  ta_3 = float3 {_S1687.x, _S1687.y, _S1687.z} + float3 {_S1688.x, _S1688.y, _S1688.z};
    float4  _S1689 = *(&(globalParams_0->state_0)[_S1679]);
    float4  _S1690 = *(&(globalParams_0->scratch_0)[_S1683]);
    float3  tb_3 = float3 {_S1689.x, _S1689.y, _S1689.z} + float3 {_S1690.x, _S1690.y, _S1690.z};
    float4  _S1691 = __ldg(&_S1671->rb_0);
    float3  _S1692 = cross_0(tb_3, float3 {_S1691.x, _S1691.y, _S1691.z});
    float4  _S1693 = __ldg(&_S1671->ra_0);
    float3  _S1694 = to_local_0(_S1668, du_0 + (_S1692 - cross_0(ta_3, float3 {_S1693.x, _S1693.y, _S1693.z})));
    *_S1669 = _S1694;
    float3  _S1695 = to_local_0(_S1668, dth_0);
    *_S1670 = _S1695;
    return;
}

static __device__ JointResponse_0 static_response_0(uint i_18)
{
    BondStatic_0 * _S1696 = (&(globalParams_0->bonds_0)[i_18]);
    float3  d_lin_4;
    float3  d_ang_3;
    static_kinematics_0(i_18, &d_lin_4, &d_ang_3);
    JointBond_0 _S1697 = slang_ldg_0(&_S1696->law_0);
    JointBond_0 _S1698 = _S1697;
    JointState_0 _S1699 = (&(globalParams_0->bond_dyn_0)[i_18])->js_0;
    JointResponse_0 _S1700 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S1697.ids_0.x], &_S1698, &_S1699, d_lin_4, d_ang_3, 0.0f, false);
    return _S1700;
}

static __device__ void gather_loads_0(uint c_29, float3  * fi_2, float3  * mi_3)
{
    float3  _S1701 = make_float3 (0.0f);
    *fi_2 = _S1701;
    *mi_3 = _S1701;
    uint _S1702 = __ldg((&(globalParams_0->index_0)[c_29]));
    uint e_4 = _S1702;
    for(;;)
    {
        uint _S1703 = __ldg((&(globalParams_0->index_0)[c_29 + 1U]));
        if(e_4 < _S1703)
        {
        }
        else
        {
            break;
        }
        uint _S1704 = __ldg((&(globalParams_0->index_0)[e_4]));
        uint bond_0 = _S1704 >> int(1);
        if((_S1704 & 1U) == 0U)
        {
            uint _S1705 = 3U * bond_0;
            float4  _S1706 = *(&(globalParams_0->scratch_0)[_S1705]);
            *fi_2 = *fi_2 + float3 {_S1706.x, _S1706.y, _S1706.z};
            float4  _S1707 = *(&(globalParams_0->scratch_0)[_S1705 + 1U]);
            *mi_3 = *mi_3 + float3 {_S1707.x, _S1707.y, _S1707.z};
        }
        else
        {
            uint _S1708 = 3U * bond_0;
            float4  _S1709 = *(&(globalParams_0->scratch_0)[_S1708]);
            *fi_2 = *fi_2 - float3 {_S1709.x, _S1709.y, _S1709.z};
            float4  _S1710 = *(&(globalParams_0->scratch_0)[_S1708 + 2U]);
            *mi_3 = *mi_3 + float3 {_S1710.x, _S1710.y, _S1710.z};
        }
        e_4 = e_4 + 1U;
    }
    return;
}

static __device__ float bond_load_magnitude2_0(uint c_30)
{
    uint _S1711 = __ldg((&(globalParams_0->index_0)[c_30]));
    uint e_5 = _S1711;
    float m_7 = 0.0f;
    for(;;)
    {
        uint _S1712 = __ldg((&(globalParams_0->index_0)[c_30 + 1U]));
        if(e_5 < _S1712)
        {
        }
        else
        {
            break;
        }
        uint _S1713 = __ldg((&(globalParams_0->index_0)[e_5]));
        uint _S1714 = 3U * (_S1713 >> int(1));
        float4  _S1715 = *(&(globalParams_0->scratch_0)[_S1714]);
        float3  f_18 = float3 {_S1715.x, _S1715.y, _S1715.z};
        float3  t_15;
        if((_S1713 & 1U) == 0U)
        {
            float4  _S1716 = *(&(globalParams_0->scratch_0)[_S1714 + 1U]);
            t_15 = float3 {_S1716.x, _S1716.y, _S1716.z};
        }
        else
        {
            float4  _S1717 = *(&(globalParams_0->scratch_0)[_S1714 + 2U]);
            t_15 = float3 {_S1717.x, _S1717.y, _S1717.z};
        }
        float m_8 = m_7 + (dot_0(f_18, f_18) + dot_0(t_15, t_15));
        e_5 = e_5 + 1U;
        m_7 = m_8;
    }
    return m_7;
}

static __device__ uint fixed_mask_0(uint c_31)
{
    uint4  _S1718 = __ldg(&(&(globalParams_0->chunks_0)[c_31])->info_0);
    uint support_1 = _S1718.x;
    uint _S1719;
    if(support_1 == 1U)
    {
        _S1719 = 63U;
    }
    else
    {
        if(support_1 == 2U)
        {
            _S1719 = 7U;
        }
        else
        {
            _S1719 = 0U;
        }
    }
    return _S1719;
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
    uint _S1720 = __ldg(&globalParams_0->params_0->statics_base_0);
    uint _S1721 = __ldg(&globalParams_0->params_0->chunk_count_0);
    return _S1720 + 23U * _S1721 + 2U * i_19;
}

static __device__ void store_inverse_0(uint c_32, FixedArray<float, 36>  * a_17)
{
    uint j_7;
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
        bool _S1722;
        if(i_20 < 6U)
        {
            _S1722 = spd_0;
        }
        else
        {
            _S1722 = false;
        }
        if(_S1722)
        {
        }
        else
        {
            break;
        }
        j_7 = 0U;
        for(;;)
        {
            if(j_7 <= i_20)
            {
            }
            else
            {
                break;
            }
            uint _S1723 = i_20 * 6U;
            uint _S1724 = _S1723 + j_7;
            k_19 = 0U;
            sum_4 = (*a_17)[_S1724];
            for(;;)
            {
                if(k_19 < j_7)
                {
                }
                else
                {
                    break;
                }
                float sum_5 = sum_4 - l_4[_S1723 + k_19] * l_4[j_7 * 6U + k_19];
                k_19 = k_19 + 1U;
                sum_4 = sum_5;
            }
            if(i_20 == j_7)
            {
                if(sum_4 <= 0.0f)
                {
                    spd_0 = false;
                    break;
                }
                l_4[_S1723 + i_20] = (F32_sqrt((sum_4)));
            }
            else
            {
                l_4[_S1724] = sum_4 / l_4[j_7 * 6U + j_7];
            }
            j_7 = j_7 + 1U;
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
            uint _S1725 = k_19 * 6U + k_19;
            float _S1726 = (*a_17)[_S1725];
            if(((*a_17)[_S1725]) > 0.0f)
            {
                sum_4 = 1.0f / _S1726;
            }
            else
            {
                sum_4 = 0.0f;
            }
            inv_0[_S1725] = sum_4;
            k_19 = k_19 + 1U;
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
                if(i_20 == j_7)
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
            FixedArray<float, 6>  x_25;
            x_25[int(0)] = 0.0f;
            x_25[int(1)] = 0.0f;
            x_25[int(2)] = 0.0f;
            x_25[int(3)] = 0.0f;
            x_25[int(4)] = 0.0f;
            x_25[int(5)] = 0.0f;
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
                    float s_10 = sum_4 - l_4[k_19 * 6U + i_21] * x_25[k_19];
                    k_19 = k_19 + 1U;
                    sum_4 = s_10;
                }
                x_25[i_21] = sum_4 / l_4[i_21 * 6U + i_21];
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
                inv_0[i_22 * 6U + j_7] = x_25[i_22];
                i_22 = i_22 + 1U;
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
        uint _S1727 = 4U * j_7;
        *(&(globalParams_0->scratch_0)[sv_0(c_32, 12U + j_7)]) = make_float4 (inv_0[_S1727], inv_0[_S1727 + 1U], inv_0[_S1727 + 2U], inv_0[_S1727 + 3U]);
        j_7 = j_7 + 1U;
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
    uint _S1728 = __ldg((&(globalParams_0->index_0)[c_33]));
    uint e_6 = _S1728;
    for(;;)
    {
        uint _S1729 = __ldg((&(globalParams_0->index_0)[c_33 + 1U]));
        if(e_6 < _S1729)
        {
        }
        else
        {
            break;
        }
        uint _S1730 = __ldg((&(globalParams_0->index_0)[e_6]));
        uint i_23 = _S1730 >> int(1);
        bool _S1731 = (_S1730 & 1U) != 0U;
        BondStatic_0 * _S1732 = (&(globalParams_0->bonds_0)[i_23]);
        uint _S1733 = statics_bond_slot_0(i_23);
        float4  _S1734 = *(&(globalParams_0->scratch_0)[_S1733]);
        float4  _S1735 = *(&(globalParams_0->scratch_0)[_S1733 + 1U]);
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
            uint _S1736 = p_14 % 3U;
            float3  t_16;
            if(_S1736 == 0U)
            {
                float4  _S1737 = __ldg(&_S1732->t1_0);
                t_16 = float3 {_S1737.x, _S1737.y, _S1737.z};
            }
            else
            {
                if(_S1736 == 1U)
                {
                    float4  _S1738 = __ldg(&_S1732->t2_0);
                    t_16 = float3 {_S1738.x, _S1738.y, _S1738.z};
                }
                else
                {
                    float4  _S1739 = __ldg(&_S1732->normal_0);
                    t_16 = float3 {_S1739.x, _S1739.y, _S1739.z};
                }
            }
            bool _S1740 = p_14 < 3U;
            float3  row_u_0;
            float3  row_t_0;
            if(_S1740)
            {
                if(_S1731)
                {
                    row_u_0 = t_16;
                }
                else
                {
                    row_u_0 = - t_16;
                }
                if(_S1731)
                {
                    float4  _S1741 = __ldg(&_S1732->rb_0);
                    row_t_0 = cross_0(float3 {_S1741.x, _S1741.y, _S1741.z}, t_16);
                }
                else
                {
                    float4  _S1742 = __ldg(&_S1732->ra_0);
                    row_t_0 = - cross_0(float3 {_S1742.x, _S1742.y, _S1742.z}, t_16);
                }
            }
            else
            {
                float3  _S1743 = make_float3 (0.0f);
                if(_S1731)
                {
                    row_u_0 = t_16;
                }
                else
                {
                    row_u_0 = - t_16;
                }
                float3  _S1744 = row_u_0;
                row_u_0 = _S1743;
                row_t_0 = _S1744;
            }
            float kp_0;
            if(_S1740)
            {
                kp_0 = _slang_vector_get_element(_S1734, p_14);
            }
            else
            {
                kp_0 = _slang_vector_get_element(_S1735, p_14 - 3U);
            }
            if(kp_0 == 0.0f)
            {
                p_14 = p_14 + 1U;
                continue;
            }
            FixedArray<float, 6>  _S1745 = { {
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
                    a_18[r_11 * 6U + q_13] = a_18[r_11 * 6U + q_13] + kp_0 * _S1745[r_11] * _S1745[q_13];
                    q_13 = q_13 + 1U;
                }
                r_11 = r_11 + 1U;
            }
            p_14 = p_14 + 1U;
        }
        e_6 = e_6 + 1U;
    }
    uint _S1746 = fixed_mask_0(c_33);
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
        if((_S1746 & (1U << p_14)) != 0U)
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
    FixedArray<float, 36>  _S1747 = a_18;
    store_inverse_0(c_33, &_S1747);
    return;
}

static __device__ float block_get_0(uint c_34, uint i_24, uint j_8)
{
    uint k_21 = i_24 * 6U + j_8;
    return *_slang_vector_get_element_ptr((&(globalParams_0->scratch_0)[sv_0(c_34, 12U + k_21 / 4U)]), k_21 % 4U);
}

static __device__ void precondition_0(uint c_35)
{
    float4  * _S1748 = (&(globalParams_0->scratch_0)[sv_0(c_35, 4U)]);
    float4  * _S1749 = (&(globalParams_0->scratch_0)[sv_0(c_35, 5U)]);
    FixedArray<float, 6>  _S1750 = { {
        (*_S1748).x, (*_S1748).y, (*_S1748).z, (*_S1749).x, (*_S1749).y, (*_S1749).z
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
            float s_12 = s_11 + block_get_0(c_35, i_25, j_9) * _S1750[j_9];
            j_9 = j_9 + 1U;
            s_11 = s_12;
        }
        z_1[i_25] = s_11;
        i_25 = i_25 + 1U;
    }
    *(&(globalParams_0->scratch_0)[sv_0(c_35, 6U)]) = make_float4 (z_1[int(0)], z_1[int(1)], z_1[int(2)], 0.0f);
    *(&(globalParams_0->scratch_0)[sv_0(c_35, 7U)]) = make_float4 (z_1[int(3)], z_1[int(4)], z_1[int(5)], 0.0f);
    return;
}

static __device__ void project_displacement_slot_0(uint tid_17, Island_0 * isl_20, uint slot_4, uint _S1751)
{
    uint _S1752;
    uint _S1753;
    float3  _S1754 = make_float3 (0.0f);
    float3  p_15 = _S1754;
    float3  l_5 = _S1754;
    uint4  _S1755 = isl_20->range_0;
    uint _S1756 = isl_20->range_0.x + tid_17;
    uint c_36 = _S1756;
    uint _S1757 = _S1751;
    for(;;)
    {
        uint _S1758 = _S1755.y;
        _S1752 = _S1758;
        bool _S1759 = c_36 < _S1758;
        uint _S1760 = __ballot_sync(_S1757, _S1759);
        if(_S1759)
        {
            uint _S1761 = __ballot_sync(_S1757, true);
        }
        else
        {
            uint _S1762 = __ballot_sync(_S1757, false);
            uint _S1763 = __ballot_sync(_S1757, false);
            uint _S1764 = __ballot_sync(_S1751, true);
            _S1753 = _S1764;
            break;
        }
        ChunkStatic_0 * _S1765 = (&(globalParams_0->chunks_0)[c_36]);
        float4  _S1766 = *(&(globalParams_0->scratch_0)[sv_0(c_36, slot_4)]);
        float3  u_3 = float3 {_S1766.x, _S1766.y, _S1766.z};
        float4  _S1767 = *(&(globalParams_0->scratch_0)[sv_0(c_36, slot_4 + 1U)]);
        float3  th_5 = float3 {_S1767.x, _S1767.y, _S1767.z};
        float4  _S1768 = __ldg(&_S1765->center_0);
        float4  _S1769 = isl_20->com_0;
        float3  r_12 = float3 {_S1768.x, _S1768.y, _S1768.z} - float3 {_S1769.x, _S1769.y, _S1769.z};
        float _S1770 = _S1768.w;
        p_15 = p_15 + u_3 * make_float3 (_S1770);
        float3  _S1771 = cross_0(r_12, u_3) * make_float3 (_S1770);
        float4  _S1772 = __ldg(&_S1765->inertia0_0);
        float4  _S1773 = __ldg(&_S1765->inertia1_0);
        float4  _S1774 = __ldg(&_S1765->inertia2_0);
        l_5 = l_5 + (_S1771 + rows_mul_0(_S1772, _S1773, _S1774, th_5));
        uint _S1775 = __ballot_sync(_S1757, true);
        c_36 = c_36 + 256U;
        _S1757 = _S1775;
    }
    group_sum3_0(tid_17, &p_15, &l_5, _S1753);
    float4  _S1776 = isl_20->com_0;
    float3  _S1777 = p_15 / make_float3 (isl_20->com_0.w);
    float3  _S1778 = rows_mul_0(isl_20->inv0_1, isl_20->inv1_1, isl_20->inv2_1, l_5);
    c_36 = _S1756;
    for(;;)
    {
        if(c_36 < _S1752)
        {
        }
        else
        {
            break;
        }
        float4  _S1779 = __ldg(&(&(globalParams_0->chunks_0)[c_36])->center_0);
        uint _S1780 = sv_0(c_36, slot_4);
        float4  _S1781 = *(&(globalParams_0->scratch_0)[_S1780]);
        *(&(globalParams_0->scratch_0)[_S1780]) = make_float4 ((float3 {_S1781.x, _S1781.y, _S1781.z} - _S1777 - cross_0(_S1778, float3 {_S1779.x, _S1779.y, _S1779.z} - float3 {_S1776.x, _S1776.y, _S1776.z})).x, (float3 {_S1781.x, _S1781.y, _S1781.z} - _S1777 - cross_0(_S1778, float3 {_S1779.x, _S1779.y, _S1779.z} - float3 {_S1776.x, _S1776.y, _S1776.z})).y, (float3 {_S1781.x, _S1781.y, _S1781.z} - _S1777 - cross_0(_S1778, float3 {_S1779.x, _S1779.y, _S1779.z} - float3 {_S1776.x, _S1776.y, _S1776.z})).z, 0.0f);
        uint _S1782 = sv_0(c_36, slot_4 + 1U);
        float4  _S1783 = *(&(globalParams_0->scratch_0)[_S1782]);
        *(&(globalParams_0->scratch_0)[_S1782]) = make_float4 ((float3 {_S1783.x, _S1783.y, _S1783.z} - _S1778).x, (float3 {_S1783.x, _S1783.y, _S1783.z} - _S1778).y, (float3 {_S1783.x, _S1783.y, _S1783.z} - _S1778).z, 0.0f);
        c_36 = c_36 + 256U;
    }
    __syncthreads();
    return;
}

static __device__ uint statics_result_slot_0(uint island_3)
{
    uint _S1784 = __ldg(&globalParams_0->params_0->statics_base_0);
    uint _S1785 = __ldg(&globalParams_0->params_0->chunk_count_0);
    uint _S1786 = _S1784 + 23U * _S1785;
    uint _S1787 = __ldg(&globalParams_0->params_0->statics_bonds_0);
    return _S1786 + 2U * _S1787 + island_3;
}

static __device__ void write_bond_loads_0(uint _S1788, uint _S1789, float3  _S1790, float3  _S1791, float _S1792)
{
    BondStatic_0 * _S1793 = (&(globalParams_0->bonds_0)[_S1789]);
    float3  _S1794 = to_body_0(_S1789, _S1790);
    float3  _S1795 = to_body_0(_S1789, _S1791);
    uint _S1796 = 3U * _S1788;
    *(&(globalParams_0->scratch_0)[_S1796]) = make_float4 (_S1794.x, _S1794.y, _S1794.z, _S1792);
    float4  * _S1797 = (&(globalParams_0->scratch_0)[_S1796 + 1U]);
    float4  _S1798 = __ldg(&_S1793->ra_0);
    *_S1797 = make_float4 ((_S1795 + cross_0(float3 {_S1798.x, _S1798.y, _S1798.z}, _S1794)).x, (_S1795 + cross_0(float3 {_S1798.x, _S1798.y, _S1798.z}, _S1794)).y, (_S1795 + cross_0(float3 {_S1798.x, _S1798.y, _S1798.z}, _S1794)).z, 0.0f);
    float4  * _S1799 = (&(globalParams_0->scratch_0)[_S1796 + 2U]);
    float3  _S1800 = - _S1795;
    float4  _S1801 = __ldg(&_S1793->rb_0);
    *_S1799 = make_float4 ((_S1800 + cross_0(float3 {_S1801.x, _S1801.y, _S1801.z}, - _S1794)).x, (_S1800 + cross_0(float3 {_S1801.x, _S1801.y, _S1801.z}, - _S1794)).y, (_S1800 + cross_0(float3 {_S1801.x, _S1801.y, _S1801.z}, - _S1794)).z, 0.0f);
    return;
}

static __device__ void bond_kinematics_0(uint _S1802, float3  _S1803, float3  _S1804, float3  _S1805, float3  _S1806, float3  * _S1807, float3  * _S1808)
{
    BondStatic_0 * _S1809 = (&(globalParams_0->bonds_0)[_S1802]);
    float4  _S1810 = __ldg(&_S1809->rb_0);
    float3  _S1811 = _S1805 + cross_0(_S1806, float3 {_S1810.x, _S1810.y, _S1810.z});
    float4  _S1812 = __ldg(&_S1809->ra_0);
    float3  _S1813 = to_local_0(_S1802, _S1811 - (_S1803 + cross_0(_S1804, float3 {_S1812.x, _S1812.y, _S1812.z})));
    *_S1807 = _S1813;
    float3  _S1814 = to_local_0(_S1802, _S1806 - _S1804);
    *_S1808 = _S1814;
    return;
}

extern "C" __global__ void island_statics()
{
    uint _S1815 = 0U;
    uint _S1816;
    uint i_26;
    uint c_37;
    bool converged_0;
    uint _S1817;
    uint _S1818;
    uint _S1819;
    uint _S1820;
    uint _S1821;
    uint _S1822;
    uint i_27;
    uint _S1823;
    uint _S1824;
    uint _S1825;
    uint _S1826;
    uint _S1827;
    uint _S1828 = __ballot_sync(4294967295U, true);
    uint tid_18 = threadIdx.x;
    uint _S1829 = blockIdx.x;
    Island_0 * _S1830 = (&(globalParams_0->islands_0)[_S1829]);
    Island_0 isl_21 = *_S1830;
    uint _S1831 = (*_S1830).info_1.z;
    bool _S1832 = (_S1831 & 8U) == 0U;
    uint _S1833 = __ballot_sync(_S1828, _S1832);
    if(_S1832)
    {
        return;
    }
    else
    {
        uint _S1834 = __ballot_sync(_S1828, true);
        _S1815 = _S1834;
    }
    bool free_0 = ((isl_21.info_1.x) & 1U) == 0U;
    uint c0_1 = isl_21.range_0.x;
    uint c1_1 = isl_21.range_0.y;
    uint b0_0 = isl_21.range_0.z;
    uint _S1835 = isl_21.range_0.w;
    uint _S1836 = c0_1 + tid_18;
    uint c_38 = _S1836;
    uint newton_0;
    newton_0 = _S1815;
    for(;;)
    {
        bool _S1837 = c_38 < c1_1;
        uint _S1838 = __ballot_sync(newton_0, _S1837);
        if(_S1837)
        {
            uint _S1839 = __ballot_sync(newton_0, true);
        }
        else
        {
            uint _S1840 = __ballot_sync(newton_0, false);
            uint _S1841 = __ballot_sync(newton_0, false);
            uint _S1842 = __ballot_sync(_S1815, true);
            _S1816 = _S1842;
            break;
        }
        float4  _S1843 = make_float4 (0.0f);
        *(&(globalParams_0->scratch_0)[sv_0(c_38, 21U)]) = _S1843;
        *(&(globalParams_0->scratch_0)[sv_0(c_38, 22U)]) = _S1843;
        uint _S1844 = __ballot_sync(newton_0, true);
        c_38 = c_38 + 256U;
        newton_0 = _S1844;
    }
    __syncthreads();
    uint _S1845 = __ballot_sync(_S1816, free_0);
    if(free_0)
    {
        Island_0 _S1846 = isl_21;
        project_load_slot_0(tid_18, &_S1846, 0U, _S1845);
        uint _S1847 = __ballot_sync(_S1816, true);
        c_38 = _S1847;
    }
    else
    {
        uint _S1848 = __ballot_sync(_S1816, true);
        c_38 = _S1848;
    }
    float _S1849 = island_dot_0(tid_18, c0_1, c1_1, 0U, 0U, c_38);
    float _S1850 = (F32_max(((F32_sqrt((_S1849)))), (1.00000000317107685e-30f)));
    float _S1851 = __ldg(&globalParams_0->params_0->statics_tol_0);
    uint _S1852 = __ldg(&globalParams_0->params_0->statics_cg_0);
    uint _S1853 = (U32_min((_S1852), (20U * (c1_1 - c0_1) * 6U + 200U)));
    float previous_2 = 1.00000001504746622e+30f;
    float residual_0 = 0.0f;
    newton_0 = 0U;
    uint cg_total_0 = 0U;
    for(;;)
    {
        uint _S1854 = 0U;
        uint _S1855 = __ldg(&globalParams_0->params_0->statics_newton_0);
        bool _S1856 = newton_0 < _S1855;
        uint _S1857 = __ballot_sync(c_38, _S1856);
        if(_S1856)
        {
            uint _S1858 = __ballot_sync(c_38, true);
            _S1854 = _S1858;
        }
        else
        {
            converged_0 = false;
            break;
        }
        uint _S1859 = b0_0 + tid_18;
        i_26 = _S1859;
        uint _S1860;
        _S1860 = _S1854;
        for(;;)
        {
            bool _S1861 = i_26 < _S1835;
            uint _S1862 = __ballot_sync(_S1860, _S1861);
            if(_S1861)
            {
                uint _S1863 = __ballot_sync(_S1860, true);
            }
            else
            {
                uint _S1864 = __ballot_sync(_S1860, false);
                uint _S1865 = __ballot_sync(_S1860, false);
                uint _S1866 = __ballot_sync(_S1854, true);
                _S1817 = _S1866;
                break;
            }
            JointResponse_0 resp_1 = static_response_0(i_26);
            write_bond_loads_0(i_26, i_26, resp_1.force_lin_1, resp_1.force_ang_1, 0.0f);
            uint _S1867 = __ballot_sync(_S1860, true);
            i_26 = i_26 + 256U;
            _S1860 = _S1867;
        }
        __syncthreads();
        float4  _S1868 = make_float4 (0.0f);
        float4  magnitude_0 = _S1868;
        float4  unused_m_0 = _S1868;
        uint c_39 = _S1836;
        uint _S1869 = _S1817;
        for(;;)
        {
            bool _S1870 = c_39 < c1_1;
            uint _S1871 = __ballot_sync(_S1869, _S1870);
            if(_S1870)
            {
                uint _S1872 = __ballot_sync(_S1869, true);
            }
            else
            {
                uint _S1873 = __ballot_sync(_S1869, false);
                uint _S1874 = __ballot_sync(_S1869, false);
                uint _S1875 = __ballot_sync(_S1817, true);
                _S1818 = _S1875;
                break;
            }
            float3  fi_3;
            float3  mi_4;
            gather_loads_0(c_39, &fi_3, &mi_4);
            *&((&magnitude_0)->x) = *&((&magnitude_0)->x) + bond_load_magnitude2_0(c_39);
            float4  _S1876 = *(&(globalParams_0->scratch_0)[sv_0(c_39, 0U)]);
            float4  r_lin_0 = make_float4 ((float3 {_S1876.x, _S1876.y, _S1876.z} + fi_3).x, (float3 {_S1876.x, _S1876.y, _S1876.z} + fi_3).y, (float3 {_S1876.x, _S1876.y, _S1876.z} + fi_3).z, 0.0f);
            float4  _S1877 = *(&(globalParams_0->scratch_0)[sv_0(c_39, 1U)]);
            float4  r_ang_0 = make_float4 ((float3 {_S1877.x, _S1877.y, _S1877.z} + mi_4).x, (float3 {_S1877.x, _S1877.y, _S1877.z} + mi_4).y, (float3 {_S1877.x, _S1877.y, _S1877.z} + mi_4).z, 0.0f);
            hold_0(fixed_mask_0(c_39), &r_lin_0, &r_ang_0, _S1868, _S1868);
            *(&(globalParams_0->scratch_0)[sv_0(c_39, 4U)]) = r_lin_0;
            *(&(globalParams_0->scratch_0)[sv_0(c_39, 5U)]) = r_ang_0;
            uint _S1878 = __ballot_sync(_S1869, true);
            c_39 = c_39 + 256U;
            _S1869 = _S1878;
        }
        __syncthreads();
        group_sum2_0(tid_18, &magnitude_0, &unused_m_0, _S1818);
        uint _S1879 = __ballot_sync(_S1818, free_0);
        uint _S1880;
        if(free_0)
        {
            Island_0 _S1881 = isl_21;
            project_load_slot_0(tid_18, &_S1881, 4U, _S1879);
            uint _S1882 = __ballot_sync(_S1818, true);
            _S1880 = _S1882;
        }
        else
        {
            uint _S1883 = __ballot_sync(_S1818, true);
            _S1880 = _S1883;
        }
        float _S1884 = island_dot_0(tid_18, c0_1, c1_1, 4U, 4U, _S1880);
        float residual_1 = (F32_sqrt((_S1884))) / _S1850;
        float _S1885 = (F32_max((0.00100000004749745f), (3.83999986297567375e-06f * (F32_sqrt((magnitude_0.x))) / _S1850)));
        bool _S1886 = residual_1 <= _S1851;
        uint _S1887 = __ballot_sync(_S1880, _S1886);
        uint _S1888;
        if(_S1886)
        {
            uint _S1889 = __ballot_sync(_S1880, true);
            converged_0 = true;
            _S1888 = _S1889;
        }
        else
        {
            uint _S1890 = _S1880 & (~_S1887);
            bool _S1891 = residual_1 <= _S1885;
            uint _S1892 = __ballot_sync(_S1890, _S1891);
            if(_S1891)
            {
                bool _S1893 = residual_1 > (0.5f * previous_2);
                uint _S1894 = __ballot_sync(_S1890, true);
                converged_0 = _S1893;
            }
            else
            {
                uint _S1895 = __ballot_sync(_S1890, true);
                converged_0 = false;
            }
            uint _S1896 = __ballot_sync(_S1880, true);
            _S1888 = _S1896;
        }
        uint _S1897 = 0U;
        uint _S1898 = __ballot_sync(_S1888, converged_0);
        if(converged_0)
        {
            residual_0 = residual_1;
            converged_0 = true;
            break;
        }
        else
        {
            uint _S1899 = __ballot_sync(_S1888, true);
            _S1897 = _S1899;
        }
        uint i_28 = _S1859;
        uint _S1900;
        _S1900 = _S1897;
        for(;;)
        {
            bool _S1901 = i_28 < _S1835;
            uint _S1902 = __ballot_sync(_S1900, _S1901);
            if(_S1901)
            {
                uint _S1903 = __ballot_sync(_S1900, true);
            }
            else
            {
                uint _S1904 = __ballot_sync(_S1900, false);
                uint _S1905 = __ballot_sync(_S1900, false);
                uint _S1906 = __ballot_sync(_S1897, true);
                _S1819 = _S1906;
                break;
            }
            BondStatic_0 * _S1907 = (&(globalParams_0->bonds_0)[i_28]);
            float3  d_lin_5;
            float3  d_ang_4;
            static_kinematics_0(i_28, &d_lin_5, &d_ang_4);
            JointBond_0 _S1908 = slang_ldg_0(&_S1907->law_0);
            JointBond_0 _S1909 = _S1908;
            JointState_0 _S1910 = (&(globalParams_0->bond_dyn_0)[i_28])->js_0;
            float3  f_lin_2;
            float3  f_ang_2;
            secant_factors_0(&_S1909, &_S1910, d_lin_5, &f_lin_2, &f_ang_2);
            uint _S1911 = statics_bond_slot_0(i_28);
            float _S1912 = _S1908.stiff0_0.y;
            *(&(globalParams_0->scratch_0)[_S1911]) = make_float4 (_S1912 * f_lin_2.x, _S1912 * f_lin_2.y, _S1908.stiff0_0.x * f_lin_2.z, 0.0f);
            *(&(globalParams_0->scratch_0)[_S1911 + 1U]) = make_float4 (_S1908.stiff0_0.z * f_ang_2.x, _S1908.stiff0_0.w * f_ang_2.y, _S1908.stiff1_0.x * f_ang_2.z, 0.0f);
            uint _S1913 = __ballot_sync(_S1900, true);
            i_28 = i_28 + 256U;
            _S1900 = _S1913;
        }
        __syncthreads();
        uint c_40 = _S1836;
        uint _S1914 = _S1819;
        for(;;)
        {
            bool _S1915 = c_40 < c1_1;
            uint _S1916 = __ballot_sync(_S1914, _S1915);
            if(_S1915)
            {
                uint _S1917 = __ballot_sync(_S1914, true);
            }
            else
            {
                uint _S1918 = __ballot_sync(_S1914, false);
                uint _S1919 = __ballot_sync(_S1914, false);
                uint _S1920 = __ballot_sync(_S1819, true);
                _S1820 = _S1920;
                break;
            }
            assemble_block_0(c_40);
            *(&(globalParams_0->scratch_0)[sv_0(c_40, 2U)]) = _S1868;
            *(&(globalParams_0->scratch_0)[sv_0(c_40, 3U)]) = _S1868;
            uint _S1921 = __ballot_sync(_S1914, true);
            c_40 = c_40 + 256U;
            _S1914 = _S1921;
        }
        __syncthreads();
        uint c_41 = _S1836;
        uint _S1922 = _S1820;
        for(;;)
        {
            bool _S1923 = c_41 < c1_1;
            uint _S1924 = __ballot_sync(_S1922, _S1923);
            if(_S1923)
            {
                uint _S1925 = __ballot_sync(_S1922, true);
            }
            else
            {
                uint _S1926 = __ballot_sync(_S1922, false);
                uint _S1927 = __ballot_sync(_S1922, false);
                uint _S1928 = __ballot_sync(_S1820, true);
                _S1821 = _S1928;
                break;
            }
            precondition_0(c_41);
            uint _S1929 = __ballot_sync(_S1922, true);
            c_41 = c_41 + 256U;
            _S1922 = _S1929;
        }
        __syncthreads();
        uint _S1930 = __ballot_sync(_S1821, free_0);
        uint _S1931;
        if(free_0)
        {
            Island_0 _S1932 = isl_21;
            project_displacement_slot_0(tid_18, &_S1932, 6U, _S1930);
            uint _S1933 = __ballot_sync(_S1821, true);
            _S1931 = _S1933;
        }
        else
        {
            uint _S1934 = __ballot_sync(_S1821, true);
            _S1931 = _S1934;
        }
        uint c_42 = _S1836;
        uint _S1935 = _S1931;
        for(;;)
        {
            bool _S1936 = c_42 < c1_1;
            uint _S1937 = __ballot_sync(_S1935, _S1936);
            if(_S1936)
            {
                uint _S1938 = __ballot_sync(_S1935, true);
            }
            else
            {
                uint _S1939 = __ballot_sync(_S1935, false);
                uint _S1940 = __ballot_sync(_S1935, false);
                uint _S1941 = __ballot_sync(_S1931, true);
                _S1822 = _S1941;
                break;
            }
            *(&(globalParams_0->scratch_0)[sv_0(c_42, 8U)]) = *(&(globalParams_0->scratch_0)[sv_0(c_42, 6U)]);
            *(&(globalParams_0->scratch_0)[sv_0(c_42, 9U)]) = *(&(globalParams_0->scratch_0)[sv_0(c_42, 7U)]);
            uint _S1942 = __ballot_sync(_S1935, true);
            c_42 = c_42 + 256U;
            _S1935 = _S1942;
        }
        __syncthreads();
        float _S1943 = island_dot_0(tid_18, c0_1, c1_1, 4U, 6U, _S1822);
        float _S1944 = island_dot_0(tid_18, c0_1, c1_1, 4U, 4U, _S1822);
        float _S1945 = (F32_sqrt((_S1944)));
        float rz_0 = _S1943;
        uint k_22 = 0U;
        uint cg_total_1 = cg_total_0;
        uint _S1946 = _S1822;
        for(;;)
        {
            bool _S1947 = k_22 < _S1853;
            uint _S1948 = __ballot_sync(_S1946, _S1947);
            uint _S1949;
            bool _S1950;
            if(_S1947)
            {
                bool _S1951 = _S1945 > 0.0f;
                uint _S1952 = __ballot_sync(_S1946, true);
                _S1950 = _S1951;
                _S1949 = _S1952;
            }
            else
            {
                uint _S1953 = __ballot_sync(_S1946, true);
                _S1950 = false;
                _S1949 = _S1953;
            }
            uint _S1954 = 0U;
            uint _S1955 = __ballot_sync(_S1949, _S1950);
            if(_S1950)
            {
                uint _S1956 = __ballot_sync(_S1949, true);
                _S1954 = _S1956;
            }
            else
            {
                uint _S1957 = __ballot_sync(_S1949, false);
                uint _S1958 = __ballot_sync(_S1946, false);
                uint _S1959 = __ballot_sync(_S1822, true);
                cg_total_0 = cg_total_1;
                i_27 = _S1959;
                break;
            }
            i_27 = _S1859;
            _S1823 = _S1954;
            for(;;)
            {
                bool _S1960 = i_27 < _S1835;
                uint _S1961 = __ballot_sync(_S1823, _S1960);
                if(_S1960)
                {
                    uint _S1962 = __ballot_sync(_S1823, true);
                }
                else
                {
                    uint _S1963 = __ballot_sync(_S1823, false);
                    uint _S1964 = __ballot_sync(_S1823, false);
                    uint _S1965 = __ballot_sync(_S1954, true);
                    _S1824 = _S1965;
                    break;
                }
                JointBond_0 _S1966 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_27])->law_0);
                uint ca_2 = _S1966.ids_0.y;
                uint cb_2 = _S1966.ids_0.z;
                float4  _S1967 = *(&(globalParams_0->scratch_0)[sv_0(ca_2, 8U)]);
                float4  _S1968 = *(&(globalParams_0->scratch_0)[sv_0(ca_2, 9U)]);
                float4  _S1969 = *(&(globalParams_0->scratch_0)[sv_0(cb_2, 8U)]);
                float4  _S1970 = *(&(globalParams_0->scratch_0)[sv_0(cb_2, 9U)]);
                float3  d_lin_6;
                float3  d_ang_5;
                bond_kinematics_0(i_27, float3 {_S1967.x, _S1967.y, _S1967.z}, float3 {_S1968.x, _S1968.y, _S1968.z}, float3 {_S1969.x, _S1969.y, _S1969.z}, float3 {_S1970.x, _S1970.y, _S1970.z}, &d_lin_6, &d_ang_5);
                uint _S1971 = statics_bond_slot_0(i_27);
                float4  _S1972 = *(&(globalParams_0->scratch_0)[_S1971]);
                float4  _S1973 = *(&(globalParams_0->scratch_0)[_S1971 + 1U]);
                write_bond_loads_0(i_27, i_27, d_lin_6 * float3 {_S1972.x, _S1972.y, _S1972.z}, d_ang_5 * float3 {_S1973.x, _S1973.y, _S1973.z}, 0.0f);
                uint _S1974 = __ballot_sync(_S1823, true);
                i_27 = i_27 + 256U;
                _S1823 = _S1974;
            }
            __syncthreads();
            c_37 = _S1836;
            uint _S1975 = _S1824;
            for(;;)
            {
                bool _S1976 = c_37 < c1_1;
                uint _S1977 = __ballot_sync(_S1975, _S1976);
                if(_S1976)
                {
                    uint _S1978 = __ballot_sync(_S1975, true);
                }
                else
                {
                    uint _S1979 = __ballot_sync(_S1975, false);
                    uint _S1980 = __ballot_sync(_S1975, false);
                    uint _S1981 = __ballot_sync(_S1824, true);
                    _S1825 = _S1981;
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
                uint _S1982 = __ballot_sync(_S1975, true);
                c_37 = c_37 + 256U;
                _S1975 = _S1982;
            }
            uint _S1983 = 0U;
            __syncthreads();
            float _S1984 = island_dot_0(tid_18, c0_1, c1_1, 8U, 10U, _S1825);
            uint _S1985 = cg_total_1 + 1U;
            bool _S1986 = _S1984 <= 0.0f;
            uint _S1987 = __ballot_sync(_S1825, _S1986);
            if(_S1986)
            {
                uint _S1988 = __ballot_sync(_S1825, false);
                uint _S1989 = __ballot_sync(_S1946, false);
                uint _S1990 = __ballot_sync(_S1822, true);
                cg_total_0 = _S1985;
                i_27 = _S1990;
                break;
            }
            else
            {
                uint _S1991 = __ballot_sync(_S1825, true);
                _S1983 = _S1991;
            }
            float _S1992 = rz_0 / _S1984;
            uint c_43 = _S1836;
            uint _S1993;
            _S1993 = _S1983;
            for(;;)
            {
                bool _S1994 = c_43 < c1_1;
                uint _S1995 = __ballot_sync(_S1993, _S1994);
                if(_S1994)
                {
                    uint _S1996 = __ballot_sync(_S1993, true);
                }
                else
                {
                    uint _S1997 = __ballot_sync(_S1993, false);
                    uint _S1998 = __ballot_sync(_S1993, false);
                    uint _S1999 = __ballot_sync(_S1983, true);
                    _S1826 = _S1999;
                    break;
                }
                uint _S2000 = sv_0(c_43, 2U);
                float4  _S2001 = *(&(globalParams_0->scratch_0)[_S2000]);
                float4  _S2002 = *(&(globalParams_0->scratch_0)[sv_0(c_43, 8U)]);
                *(&(globalParams_0->scratch_0)[_S2000]) = make_float4 ((float3 {_S2001.x, _S2001.y, _S2001.z} + make_float3 (_S1992) * float3 {_S2002.x, _S2002.y, _S2002.z}).x, (float3 {_S2001.x, _S2001.y, _S2001.z} + make_float3 (_S1992) * float3 {_S2002.x, _S2002.y, _S2002.z}).y, (float3 {_S2001.x, _S2001.y, _S2001.z} + make_float3 (_S1992) * float3 {_S2002.x, _S2002.y, _S2002.z}).z, 0.0f);
                uint _S2003 = sv_0(c_43, 3U);
                float4  _S2004 = *(&(globalParams_0->scratch_0)[_S2003]);
                float4  _S2005 = *(&(globalParams_0->scratch_0)[sv_0(c_43, 9U)]);
                *(&(globalParams_0->scratch_0)[_S2003]) = make_float4 ((float3 {_S2004.x, _S2004.y, _S2004.z} + make_float3 (_S1992) * float3 {_S2005.x, _S2005.y, _S2005.z}).x, (float3 {_S2004.x, _S2004.y, _S2004.z} + make_float3 (_S1992) * float3 {_S2005.x, _S2005.y, _S2005.z}).y, (float3 {_S2004.x, _S2004.y, _S2004.z} + make_float3 (_S1992) * float3 {_S2005.x, _S2005.y, _S2005.z}).z, 0.0f);
                uint _S2006 = sv_0(c_43, 4U);
                float4  _S2007 = *(&(globalParams_0->scratch_0)[_S2006]);
                float4  _S2008 = *(&(globalParams_0->scratch_0)[sv_0(c_43, 10U)]);
                *(&(globalParams_0->scratch_0)[_S2006]) = make_float4 ((float3 {_S2007.x, _S2007.y, _S2007.z} - make_float3 (_S1992) * float3 {_S2008.x, _S2008.y, _S2008.z}).x, (float3 {_S2007.x, _S2007.y, _S2007.z} - make_float3 (_S1992) * float3 {_S2008.x, _S2008.y, _S2008.z}).y, (float3 {_S2007.x, _S2007.y, _S2007.z} - make_float3 (_S1992) * float3 {_S2008.x, _S2008.y, _S2008.z}).z, 0.0f);
                uint _S2009 = sv_0(c_43, 5U);
                float4  _S2010 = *(&(globalParams_0->scratch_0)[_S2009]);
                float4  _S2011 = *(&(globalParams_0->scratch_0)[sv_0(c_43, 11U)]);
                *(&(globalParams_0->scratch_0)[_S2009]) = make_float4 ((float3 {_S2010.x, _S2010.y, _S2010.z} - make_float3 (_S1992) * float3 {_S2011.x, _S2011.y, _S2011.z}).x, (float3 {_S2010.x, _S2010.y, _S2010.z} - make_float3 (_S1992) * float3 {_S2011.x, _S2011.y, _S2011.z}).y, (float3 {_S2010.x, _S2010.y, _S2010.z} - make_float3 (_S1992) * float3 {_S2011.x, _S2011.y, _S2011.z}).z, 0.0f);
                uint _S2012 = __ballot_sync(_S1993, true);
                c_43 = c_43 + 256U;
                _S1993 = _S2012;
            }
            uint _S2013 = 0U;
            __syncthreads();
            float _S2014 = island_dot_0(tid_18, c0_1, c1_1, 4U, 4U, _S1826);
            bool _S2015 = (F32_sqrt((_S2014))) <= (0.00009999999747379f * _S1945);
            uint _S2016 = __ballot_sync(_S1826, _S2015);
            if(_S2015)
            {
                uint _S2017 = __ballot_sync(_S1826, false);
                uint _S2018 = __ballot_sync(_S1946, false);
                uint _S2019 = __ballot_sync(_S1822, true);
                cg_total_0 = _S1985;
                i_27 = _S2019;
                break;
            }
            else
            {
                uint _S2020 = __ballot_sync(_S1826, true);
                _S2013 = _S2020;
            }
            uint c_44 = _S1836;
            uint _S2021;
            _S2021 = _S2013;
            for(;;)
            {
                bool _S2022 = c_44 < c1_1;
                uint _S2023 = __ballot_sync(_S2021, _S2022);
                if(_S2022)
                {
                    uint _S2024 = __ballot_sync(_S2021, true);
                }
                else
                {
                    uint _S2025 = __ballot_sync(_S2021, false);
                    uint _S2026 = __ballot_sync(_S2021, false);
                    uint _S2027 = __ballot_sync(_S2013, true);
                    _S1827 = _S2027;
                    break;
                }
                precondition_0(c_44);
                uint _S2028 = __ballot_sync(_S2021, true);
                c_44 = c_44 + 256U;
                _S2021 = _S2028;
            }
            __syncthreads();
            uint _S2029 = __ballot_sync(_S1827, free_0);
            uint _S2030;
            if(free_0)
            {
                Island_0 _S2031 = isl_21;
                project_displacement_slot_0(tid_18, &_S2031, 6U, _S2029);
                uint _S2032 = __ballot_sync(_S1827, true);
                _S2030 = _S2032;
            }
            else
            {
                uint _S2033 = __ballot_sync(_S1827, true);
                _S2030 = _S2033;
            }
            float _S2034 = island_dot_0(tid_18, c0_1, c1_1, 4U, 6U, _S2030);
            float _S2035 = _S2034 / rz_0;
            uint c_45 = _S1836;
            uint _S2036 = _S2030;
            for(;;)
            {
                bool _S2037 = c_45 < c1_1;
                uint _S2038 = __ballot_sync(_S2036, _S2037);
                if(_S2037)
                {
                    uint _S2039 = __ballot_sync(_S2036, true);
                }
                else
                {
                    uint _S2040 = __ballot_sync(_S2036, false);
                    uint _S2041 = __ballot_sync(_S2036, false);
                    uint _S2042 = __ballot_sync(_S2030, true);
                    break;
                }
                uint _S2043 = sv_0(c_45, 8U);
                float4  _S2044 = *(&(globalParams_0->scratch_0)[sv_0(c_45, 6U)]);
                float4  _S2045 = *(&(globalParams_0->scratch_0)[_S2043]);
                *(&(globalParams_0->scratch_0)[_S2043]) = make_float4 ((float3 {_S2044.x, _S2044.y, _S2044.z} + make_float3 (_S2035) * float3 {_S2045.x, _S2045.y, _S2045.z}).x, (float3 {_S2044.x, _S2044.y, _S2044.z} + make_float3 (_S2035) * float3 {_S2045.x, _S2045.y, _S2045.z}).y, (float3 {_S2044.x, _S2044.y, _S2044.z} + make_float3 (_S2035) * float3 {_S2045.x, _S2045.y, _S2045.z}).z, 0.0f);
                uint _S2046 = sv_0(c_45, 9U);
                float4  _S2047 = *(&(globalParams_0->scratch_0)[sv_0(c_45, 7U)]);
                float4  _S2048 = *(&(globalParams_0->scratch_0)[_S2046]);
                *(&(globalParams_0->scratch_0)[_S2046]) = make_float4 ((float3 {_S2047.x, _S2047.y, _S2047.z} + make_float3 (_S2035) * float3 {_S2048.x, _S2048.y, _S2048.z}).x, (float3 {_S2047.x, _S2047.y, _S2047.z} + make_float3 (_S2035) * float3 {_S2048.x, _S2048.y, _S2048.z}).y, (float3 {_S2047.x, _S2047.y, _S2047.z} + make_float3 (_S2035) * float3 {_S2048.x, _S2048.y, _S2048.z}).z, 0.0f);
                uint _S2049 = __ballot_sync(_S2036, true);
                c_45 = c_45 + 256U;
                _S2036 = _S2049;
            }
            __syncthreads();
            uint _S2050 = __ballot_sync(_S1946, true);
            uint _S2051 = k_22 + 1U;
            rz_0 = _S2034;
            k_22 = _S2051;
            cg_total_1 = _S1985;
            _S1946 = _S2050;
        }
        c_37 = _S1836;
        _S1823 = i_27;
        for(;;)
        {
            bool _S2052 = c_37 < c1_1;
            uint _S2053 = __ballot_sync(_S1823, _S2052);
            if(_S2052)
            {
                uint _S2054 = __ballot_sync(_S1823, true);
            }
            else
            {
                uint _S2055 = __ballot_sync(_S1823, false);
                uint _S2056 = __ballot_sync(_S1823, false);
                uint _S2057 = __ballot_sync(i_27, true);
                break;
            }
            uint _S2058 = 4U * c_37;
            float4  _S2059 = *(&(globalParams_0->state_0)[_S2058]);
            float3  u_4 = float3 {_S2059.x, _S2059.y, _S2059.z};
            uint _S2060 = sv_0(c_37, 21U);
            float4  _S2061 = *(&(globalParams_0->scratch_0)[_S2060]);
            float3  u_lo_0 = float3 {_S2061.x, _S2061.y, _S2061.z};
            uint _S2062 = _S2058 + 1U;
            float4  _S2063 = *(&(globalParams_0->state_0)[_S2062]);
            float3  th_6 = float3 {_S2063.x, _S2063.y, _S2063.z};
            uint _S2064 = sv_0(c_37, 22U);
            float4  _S2065 = *(&(globalParams_0->scratch_0)[_S2064]);
            float3  th_lo_0 = float3 {_S2065.x, _S2065.y, _S2065.z};
            float4  _S2066 = *(&(globalParams_0->scratch_0)[sv_0(c_37, 2U)]);
            comp_add_0(&u_4, &u_lo_0, float3 {_S2066.x, _S2066.y, _S2066.z});
            float4  _S2067 = *(&(globalParams_0->scratch_0)[sv_0(c_37, 3U)]);
            comp_add_0(&th_6, &th_lo_0, float3 {_S2067.x, _S2067.y, _S2067.z});
            *(&(globalParams_0->state_0)[_S2058]) = make_float4 (u_4.x, u_4.y, u_4.z, (*(&(globalParams_0->state_0)[_S2058])).w);
            *(&(globalParams_0->state_0)[_S2062]) = make_float4 (th_6.x, th_6.y, th_6.z, (*(&(globalParams_0->state_0)[_S2062])).w);
            *(&(globalParams_0->scratch_0)[_S2060]) = make_float4 (u_lo_0.x, u_lo_0.y, u_lo_0.z, 0.0f);
            *(&(globalParams_0->scratch_0)[_S2064]) = make_float4 (th_lo_0.x, th_lo_0.y, th_lo_0.z, 0.0f);
            uint _S2068 = __ballot_sync(_S1823, true);
            c_37 = c_37 + 256U;
            _S1823 = _S2068;
        }
        __syncthreads();
        uint _S2069 = newton_0 + 1U;
        uint _S2070 = __ballot_sync(c_38, true);
        previous_2 = residual_1;
        residual_0 = residual_1;
        newton_0 = _S2069;
        c_38 = _S2070;
    }
    i_26 = b0_0 + tid_18;
    for(;;)
    {
        if(i_26 < _S1835)
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
    c_37 = _S1836;
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
            float4  _S2071 = *(&(globalParams_0->scratch_0)[sv_0(c_37, 0U)]);
            reaction_1 = - (float3 {_S2071.x, _S2071.y, _S2071.z} + fi_5);
        }
        else
        {
            uint _S2072 = 4U * c_37;
            reaction_1 = make_float3 ((*(&(globalParams_0->state_0)[_S2072 + 1U])).w, (*(&(globalParams_0->state_0)[_S2072 + 2U])).w, (*(&(globalParams_0->state_0)[_S2072 + 3U])).w);
        }
        uint _S2073 = 4U * c_37;
        uint _S2074 = _S2073 + 1U;
        float4  _S2075 = *(&(globalParams_0->state_0)[_S2074]);
        *(&(globalParams_0->state_0)[_S2074]) = make_float4 (float3 {_S2075.x, _S2075.y, _S2075.z}.x, float3 {_S2075.x, _S2075.y, _S2075.z}.y, float3 {_S2075.x, _S2075.y, _S2075.z}.z, reaction_1.x);
        *(&(globalParams_0->state_0)[_S2073 + 2U]) = make_float4 (0.0f, 0.0f, 0.0f, reaction_1.y);
        *(&(globalParams_0->state_0)[_S2073 + 3U]) = make_float4 (0.0f, 0.0f, 0.0f, reaction_1.z);
        c_37 = c_37 + 256U;
    }
    if(tid_18 == 0U)
    {
        float4  * _S2076 = (&(globalParams_0->scratch_0)[statics_result_slot_0(_S1829)]);
        float _S2077 = (U32_asfloat((newton_0)));
        float _S2078 = (U32_asfloat((cg_total_0)));
        if(converged_0)
        {
            previous_2 = 1.0f;
        }
        else
        {
            previous_2 = 0.0f;
        }
        *_S2076 = make_float4 (residual_0, _S2077, _S2078, previous_2);
        *&((&(&(globalParams_0->islands_0)[_S1829])->info_1)->z) = _S1831 & 4294967287U;
    }
    return;
}

extern "C" __global__ void settled_fatigue()
{
    uint tid_19 = threadIdx.x;
    uint _S2079 = blockIdx.x;
    Island_0 * _S2080 = (&(globalParams_0->islands_0)[_S2079]);
    Island_0 isl_22 = *_S2080;
    bool _S2081;
    if((((*_S2080).info_1.x) & 16U) == 0U)
    {
        _S2081 = true;
    }
    else
    {
        _S2081 = (isl_22.range_0.w) == (isl_22.range_0.z);
    }
    if(_S2081)
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
    uint _S2082 = isl_22.info_1.w;
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
        BondStatic_0 * _S2083 = (&(globalParams_0->bonds_0)[i_29]);
        BondDyn_0 bd_2 = *(&(globalParams_0->bond_dyn_0)[i_29]);
        JointBond_0 _S2084 = slang_ldg_0(&_S2083->law_0);
        uint _S2085 = 4U * _S2084.ids_0.y;
        float4  _S2086 = *(&(globalParams_0->state_0)[_S2085]);
        float4  _S2087 = *(&(globalParams_0->state_0)[_S2085 + 1U]);
        uint _S2088 = 4U * _S2084.ids_0.z;
        float4  _S2089 = *(&(globalParams_0->state_0)[_S2088]);
        float4  _S2090 = *(&(globalParams_0->state_0)[_S2088 + 1U]);
        float3  d_lin_7;
        float3  d_ang_6;
        bond_kinematics_0(i_29, float3 {_S2086.x, _S2086.y, _S2086.z}, float3 {_S2087.x, _S2087.y, _S2087.z}, float3 {_S2089.x, _S2089.y, _S2089.z}, float3 {_S2090.x, _S2090.y, _S2090.z}, &d_lin_7, &d_ang_6);
        JointState_0 previous_3 = (&bd_2)->js_0;
        float3  _S2091 = d_lin_7;
        float3  _S2092 = d_ang_6;
        float _S2093 = __ldg(&globalParams_0->params_0->dt_0);
        uint _S2094 = __ldg(&globalParams_0->params_0->fracture_0);
        bool _S2095 = _S2094 != 0U;
        JointBond_0 _S2096 = _S2084;
        JointState_0 _S2097 = previous_3;
        JointResponse_0 _S2098 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S2084.ids_0.x], &_S2096, &_S2097, _S2091, _S2092, _S2093, _S2095);
        if((_S2098.state_1.damage_0) > (previous_3.damage_0 + 9.99999971718068537e-10f))
        {
            _S2081 = true;
        }
        else
        {
            _S2081 = (_S2098.state_1.crush_0) > (previous_3.crush_0 + 9.99999971718068537e-10f);
        }
        uint flags_3;
        if(_S2081)
        {
            flags_3 = 16U;
        }
        else
        {
            flags_3 = 0U;
        }
        comp_add1_0(&((&(&bd_2)->sums_0)->x), &((&(&bd_2)->comps_0)->x), _S2098.dissipated_2);
        comp_add1_0(&((&(&bd_2)->sums_0)->y), &((&(&bd_2)->comps_0)->y), _S2098.overshoot_0);
        (&bd_2)->force_lin_0 = make_float4 (_S2098.force_lin_1.x, _S2098.force_lin_1.y, _S2098.force_lin_1.z, _S2098.stored_5);
        (&bd_2)->force_ang_0 = make_float4 (_S2098.force_ang_1.x, _S2098.force_ang_1.y, _S2098.force_ang_1.z, (F32_max(((&bd_2)->force_ang_0.w), (_S2098.state_1.utilization_0))));
        JointState_0 _S2099 = previous_3;
        bool _S2100 = is_damaged_0(&_S2099);
        bool _S2101;
        if(!_S2100)
        {
            JointState_0 _S2102 = _S2098.state_1;
            bool _S2103 = is_damaged_0(&_S2102);
            _S2101 = _S2103;
        }
        else
        {
            _S2101 = false;
        }
        bool _S2104;
        if(_S2101)
        {
            _S2104 = ((&bd_2)->events_0.x) == 0U;
        }
        else
        {
            _S2104 = false;
        }
        if(_S2104)
        {
            *&((&(&bd_2)->events_0)->x) = _S2082;
            *&((&(&bd_2)->events_0)->w) = _S2098.state_1.mode_0;
            (*&g_seen_0)[3U] = 1U;
        }
        bool _S2105;
        if(((&bd_2)->events_0.y) == 0U)
        {
            _S2105 = (_S2098.state_1.life_0) != (previous_3.life_0);
        }
        else
        {
            _S2105 = false;
        }
        bool _S2106;
        if(_S2105)
        {
            _S2106 = (_S2098.fatigue_before_0) > 0.99000000953674316f;
        }
        else
        {
            _S2106 = false;
        }
        bool _S2107;
        if(_S2106)
        {
            float _S2108 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S2084.ids_0.x], _S2098.state_1.life_0);
            _S2107 = _S2108 <= 0.99000000953674316f;
        }
        else
        {
            _S2107 = false;
        }
        if(_S2107)
        {
            *&((&(&bd_2)->events_0)->y) = _S2082;
            (*&g_seen_0)[4U] = 1U;
        }
        uint flags_4;
        if(_S2098.disconnected_0)
        {
            *&((&(&bd_2)->events_0)->z) = _S2082;
            flags_4 = flags_3 | 32U;
        }
        else
        {
            flags_4 = flags_3;
        }
        (&bd_2)->js_0 = _S2098.state_1;
        *(&(globalParams_0->bond_dyn_0)[i_29]) = bd_2;
        write_bond_loads_0(i_29, i_29, _S2098.force_lin_1, _S2098.force_ang_1, (F32_max((_S2098.measures_0.tension_0), (_S2098.measures_0.compression_0))));
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
        uint _S2109 = isl_22.info_1.z;
        if((*&g_halt_0) != 0U)
        {
            i_29 = 16U;
        }
        else
        {
            i_29 = 0U;
        }
        uint _S2110 = _S2109 | i_29;
        if((*&g_run_0) != 0U)
        {
            i_29 = 32U;
        }
        else
        {
            i_29 = 0U;
        }
        *&((&(&(globalParams_0->islands_0)[_S2079])->info_1)->z) = _S2110 | i_29;
    }
    uint _S2111 = ((isl_22.coverage_0) | 16384U) | (seen_bits_0());
    if((*&g_run_0) != 0U)
    {
        i_29 = 128U;
    }
    else
    {
        i_29 = 0U;
    }
    (&(globalParams_0->islands_0)[_S2079])->coverage_0 = _S2111 | i_29;
    return;
}

