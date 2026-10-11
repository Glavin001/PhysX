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
    float4  start_vel_0;
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

static __device__ float4  abs_0(float4  x_1)
{
    float4  result_1;
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
        *_slang_vector_get_element_ptr(&result_1, i_1) = (F32_abs((_slang_vector_get_element(x_1, i_1))));
        i_1 = i_1 + int(1);
    }
    return result_1;
}

static __device__ float3  abs_1(float3  x_2)
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
        *_slang_vector_get_element_ptr(&result_2, i_2) = (F32_abs((_slang_vector_get_element(x_2, i_2))));
        i_2 = i_2 + int(1);
    }
    return result_2;
}

static __device__ float dot_0(float3  x_3, float3  y_1)
{
    return x_3.x * y_1.x + x_3.y * y_1.y + x_3.z * y_1.z;
}

__device__ static const FixedArray<float, 6>  SPRING_AT_0 = { {
    -0.4166666567325592f, -0.25f, -0.0833333358168602f, 0.0833333358168602f, 0.25f, 0.4166666567325592f
} };
static __device__ float clamp_0(float x_4, float minBound_0, float maxBound_0)
{
    return (F32_min(((F32_max((x_4), (minBound_0)))), (maxBound_0)));
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
    float4  x_5 = make_float4 ((*a_1).x, (*a_1).y, (*a_1).z, 0.0f);
    float4  y_2 = make_float4 ((*b_1).x, (*b_1).y, (*b_1).z, 0.0f);
    group_sum2_0(tid_1, &x_5, &y_2, _S9);
    float4  _S10 = x_5;
    *a_1 = float3 {_S10.x, _S10.y, _S10.z};
    float4  _S11 = y_2;
    *b_1 = float3 {_S11.x, _S11.y, _S11.z};
    return;
}

static __device__ uint4  asuint_0(float4  x_6)
{
    uint4  result_3;
    int i_3 = int(0);
    for(;;)
    {
        if(i_3 < int(4))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_3, i_3) = (F32_asuint((_slang_vector_get_element(x_6, i_3))));
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
    float3  moved_0 = _S433 + (wp_0.lo_0 - float3 {_S434.x, _S434.y, _S434.z}) + wp_0.rel_0;
    float _S435 = __ldg(&globalParams_0->params_0->t_hi_0);
    float4  _S436 = __ldg(&_S430->start_vel_0);
    float _S437 = _S435 - _S436.w;
    float _S438 = __ldg(&globalParams_0->params_0->t_lo_0);
    float _S439 = _S437 + (_S438 - _S434.w);
    uint4  _S440 = __ldg(&_S430->info_0);
    uint _S441 = _S440.y;
    uint _S442 = (&(globalParams_0->islands_0)[_S441])->info_1.w;
    uint _S443 = __ldg(&globalParams_0->params_0->step_start_0);
    float _S444 = float(_S442 - _S443);
    float _S445 = __ldg(&globalParams_0->params_0->dt_0);
    float since_0 = _S439 + _S444 * _S445;
    float3  _S446 = float3 {_S436.x, _S436.y, _S436.z} * make_float3 (since_0);
    uint _S447 = _S431.w;
    float3  _S448;
    if((_S447 & 2U) != 0U)
    {
        float4  _S449 = __ldg(&globalParams_0->params_0->gravity_0);
        _S448 = make_float3 (0.5f) * float3 {_S449.x, _S449.y, _S449.z} * make_float3 (since_0) * make_float3 (since_0);
    }
    else
    {
        _S448 = make_float3 (0.0f);
    }
    float travel_0 = length_0(moved_0 - (_S446 + _S448));
    float travel_1;
    if((_S447 & 1U) != 0U)
    {
        float4  _S450 = *(&(globalParams_0->state_0)[4U * c_4 + 1U]);
        float3  th_1 = float3 {_S450.x, _S450.y, _S450.z};
        Quat_0 _S451 = from_axis_angle_0(th_1, length_0(th_1));
        Quat_0 _S452 = quat_of_0((&(globalParams_0->islands_0)[_S441])->rotation_0);
        Quat_0 _S453 = _S451;
        Quat_0 _S454 = quat_mul_0(&_S452, &_S453);
        float4  _S455 = __ldg(&_S430->start_rot_0);
        Quat_0 _S456 = quat_of_0(make_float4 ((- float3 {_S455.x, _S455.y, _S455.z}).x, (- float3 {_S455.x, _S455.y, _S455.z}).y, (- float3 {_S455.x, _S455.y, _S455.z}).z, _S455.w));
        Quat_0 _S457 = _S454;
        Quat_0 _S458 = quat_mul_0(&_S456, &_S457);
        float _S459 = 2.0f * (F32_atan2((length_0(make_float3 (_S458.x_12, _S458.y_4, _S458.z_0))), ((F32_abs((_S458.w_1))))));
        float4  _S460 = __ldg(&_S430->half_0);
        travel_1 = travel_0 + _S459 * _S460.w;
    }
    else
    {
        travel_1 = travel_0;
    }
    if(travel_1 > (_S432.w))
    {
        uint _S461 = __ldg(&globalParams_0->params_0->halt_index_0);
        uint _S462 = __ldg(&globalParams_0->params_0->halt_index_0);
        *&((&(&(globalParams_0->islands_0)[_S461])->info_1)->z) = ((&(globalParams_0->islands_0)[_S462])->info_1.z) | 1U;
        sentinel_mark_0(1048576U);
    }
    return;
}

extern "C" __global__ void contact_forces()
{
    uint3  _S463 = blockIdx * blockDim + threadIdx;
    uint _S464 = __ballot_sync(4294967295U, true);
    uint i_9 = _S463.x;
    uint lanes_5 = pair_lane_count_0();
    uint _S465 = __ldg(&globalParams_0->params_0->pair_count_0);
    uint pair_threads_0 = _S465 * lanes_5;
    bool _S466 = i_9 < pair_threads_0;
    uint _S467 = __ballot_sync(_S464, _S466);
    if(_S466)
    {
        bool _S468 = pair_any_0(stopped_0(), lanes_5, _S467);
        bool _S469 = !_S468;
        uint _S470 = __ballot_sync(_S467, _S469);
        if(_S469)
        {
            uint _S471 = i_9 / lanes_5;
            uint _S472 = i_9 % lanes_5;
            pair_contact_0(_S471, _S472, lanes_5, _S470);
            uint _S473 = __ballot_sync(_S467, true);
        }
        return;
    }
    if(stopped_0())
    {
        return;
    }
    uint j_3 = i_9 - pair_threads_0;
    uint _S474 = __ldg(&globalParams_0->params_0->cand_count_0);
    if(j_3 < _S474)
    {
        impactor_candidate_forces_0(j_3);
    }
    else
    {
        uint _S475 = __ldg(&globalParams_0->params_0->cand_count_0);
        uint _S476 = __ldg(&globalParams_0->params_0->chunk_count_0);
        if(j_3 < (_S475 + _S476))
        {
            uint _S477 = __ldg(&globalParams_0->params_0->cand_count_0);
            travel_check_0(j_3 - _S477);
        }
    }
    return;
}

extern "C" __global__ void impactor_shares()
{
    uint k_6 = (blockIdx * blockDim + threadIdx).x;
    uint _S478 = __ldg(&globalParams_0->params_0->cand_count_0);
    bool _S479;
    if(k_6 >= _S478)
    {
        _S479 = true;
    }
    else
    {
        _S479 = stopped_0();
    }
    if(_S479)
    {
        return;
    }
    uint _S480 = __ldg(&globalParams_0->params_0->cand_index_0);
    uint _S481 = 3U * k_6;
    uint at_2 = _S480 + _S481;
    uint _S482 = __ldg((&(globalParams_0->index_0)[at_2]));
    uint _S483 = __ldg((&(globalParams_0->index_0)[at_2 + 2U]));
    Impactor_0 * _S484 = (&(globalParams_0->impactors_0)[_S483]);
    Impactor_0 imp_4 = *_S484;
    if(((*_S484).cand_0.z) == 0U)
    {
        _S479 = (imp_4.crush_1.x) > 0.0f;
    }
    else
    {
        _S479 = false;
    }
    float total_0;
    float ksum_0;
    if(_S479)
    {
        WorldPoint_0 _S485 = impactor_point_0(_S483);
        WorldPoint_0 _S486 = chunk_world_0(_S482);
        WorldPoint_0 _S487 = _S485;
        float3  _S488 = world_diff_0(&_S486, &_S487);
        float _S489 = length_0(_S488);
        float _S490 = imp_4.half_1.w;
        float4  _S491 = __ldg(&(&(globalParams_0->chunks_0)[_S482])->half_0);
        if(!(_S489 > (_S490 + _S491.w)))
        {
            float4  _S492 = imp_4.half_1;
            Box_0 _S493 = impactor_box_1(_S483, make_float3 (0.0f), float3 {_S492.x, _S492.y, _S492.z});
            Box_0 b_20 = chunk_box_0(_S482, _S488);
            float _S494 = imp_4.mat_0.x;
            float4  _S495 = __ldg(&(&(globalParams_0->chunks_0)[_S482])->cmat_0);
            float _S496 = _S495.x;
            float3  _S497 = b_20.center_1 - _S493.center_1;
            Box_0 _S498 = _S493;
            Box_0 _S499 = b_20;
            float _S500 = contact_stiffness_0(_S494, &_S498, _S496, &_S499, _S497);
            float _S501 = imp_4.crush_1.w;
            Box_0 _S502 = _S493;
            Box_0 _S503 = impactor_shrunk_0(_S483, _S501, &_S502);
            Box_0 _S504 = _S503;
            Box_0 _S505 = b_20;
            uint _S506 = impactor_contact_count_0(_S483, _S501, &_S504, &_S505);
            float _S507;
            if((imp_4.shape_0.x) == 0.0f)
            {
                _S507 = _S500;
            }
            else
            {
                _S507 = _S500 / (F32_max((float(_S506)), (10.0f)));
            }
            uint j_4 = 0U;
            total_0 = 0.0f;
            ksum_0 = 0.0f;
            for(;;)
            {
                if(_S506 > 0U)
                {
                    Impactor_0 _S508 = imp_4;
                    Box_0 _S509 = b_20;
                    uint _S510 = impactor_slots_0(&_S508, &_S509);
                    _S479 = j_4 < _S510;
                }
                else
                {
                    _S479 = false;
                }
                if(_S479)
                {
                }
                else
                {
                    break;
                }
                Impactor_0 _S511 = imp_4;
                Box_0 _S512 = _S503;
                Box_0 _S513 = b_20;
                float3  p_7;
                float3  nrm_1;
                float dep_1;
                bool _S514 = impactor_contact_0(&_S511, _S501, &_S512, &_S513, j_4, &p_7, &nrm_1, &dep_1);
                if(!_S514)
                {
                    j_4 = j_4 + 1U;
                    continue;
                }
                float ksum_1 = ksum_0 + _S507;
                total_0 = total_0 + _S507 * dep_1;
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
    uint _S515 = __ldg(&globalParams_0->params_0->cand_base_0);
    float4  data_1 = *(&(globalParams_0->scratch_0)[_S515 + _S481]);
    uint _S516 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S516 + _S481]) = make_float4 (total_0, ksum_0, data_1.z, data_1.w);
    return;
}

extern "C" __global__ void impactor_crush()
{
    uint _S517;
    uint _S518 = __ballot_sync(4294967295U, true);
    uint ii_0 = blockIdx.x;
    uint tid_2 = threadIdx.x;
    uint _S519 = __ldg(&globalParams_0->params_0->impactor_count_0);
    bool _S520 = ii_0 >= _S519;
    uint _S521 = __ballot_sync(_S518, _S520);
    bool _S522;
    uint k_7;
    if(_S520)
    {
        uint _S523 = __ballot_sync(_S518, true);
        _S522 = true;
        k_7 = _S523;
    }
    else
    {
        bool _S524 = stopped_0();
        uint _S525 = __ballot_sync(_S518, true);
        _S522 = _S524;
        k_7 = _S525;
    }
    uint _S526 = 0U;
    uint _S527 = __ballot_sync(k_7, _S522);
    if(_S522)
    {
        return;
    }
    else
    {
        uint _S528 = __ballot_sync(k_7, true);
        _S526 = _S528;
    }
    Impactor_0 imp_5 = *(&(globalParams_0->impactors_0)[ii_0]);
    float4  _S529 = make_float4 (0.0f);
    float4  shares_0 = _S529;
    float4  unused_0 = _S529;
    k_7 = (&imp_5)->cand_0.x + tid_2;
    uint _S530;
    _S530 = _S526;
    for(;;)
    {
        bool _S531 = k_7 < ((&imp_5)->cand_0.y);
        uint _S532 = __ballot_sync(_S530, _S531);
        if(_S531)
        {
            uint _S533 = __ballot_sync(_S530, true);
        }
        else
        {
            uint _S534 = __ballot_sync(_S530, false);
            uint _S535 = __ballot_sync(_S530, false);
            uint _S536 = __ballot_sync(_S526, true);
            _S517 = _S536;
            break;
        }
        uint _S537 = __ldg(&globalParams_0->params_0->cand_base_0);
        shares_0 = shares_0 + *(&(globalParams_0->scratch_0)[_S537 + 3U * k_7]);
        uint _S538 = __ballot_sync(_S530, true);
        k_7 = k_7 + 256U;
        _S530 = _S538;
    }
    group_sum2_0(tid_2, &shares_0, &unused_0, _S517);
    bool _S539 = tid_2 != 0U;
    uint _S540 = __ballot_sync(_S517, _S539);
    if(_S539)
    {
        _S522 = true;
    }
    else
    {
        _S522 = ((&imp_5)->cand_0.z) != 0U;
    }
    if(_S522)
    {
        return;
    }
    (&imp_5)->geom_0 = make_float4 (1.0f, (&imp_5)->crush_1.w, 0.0f, 0.0f);
    float total_1 = shares_0.x;
    if(((&imp_5)->crush_1.x) > 0.0f)
    {
        _S522 = ((&imp_5)->crush_1.z) < ((&imp_5)->crush_1.y);
    }
    else
    {
        _S522 = false;
    }
    if(_S522)
    {
        _S522 = total_1 > ((&imp_5)->crush_1.x);
    }
    else
    {
        _S522 = false;
    }
    if(_S522)
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

struct WideGroup_0
{
    uint island_2;
    uint begin_0;
    uint end_0;
    uint first_0;
};

static __device__ WideGroup_0 wide_group_0(uint table_0, uint g_0)
{
    WideGroup_0 w_4;
    uint _S541 = table_0 + 4U * g_0;
    uint _S542 = __ldg((&(globalParams_0->index_0)[_S541]));
    (&w_4)->island_2 = _S542;
    uint _S543 = __ldg((&(globalParams_0->index_0)[_S541 + 1U]));
    (&w_4)->begin_0 = _S543;
    uint _S544 = __ldg((&(globalParams_0->index_0)[_S541 + 2U]));
    (&w_4)->end_0 = _S544;
    uint _S545 = __ldg((&(globalParams_0->index_0)[_S541 + 3U]));
    (&w_4)->first_0 = _S545;
    return w_4;
}

__device__ __shared__ FixedArray<uint, 5>  g_seen_0;

static __device__ void seen_clear_0(uint tid_3)
{
    if(tid_3 < 5U)
    {
        (*&g_seen_0)[tid_3] = 0U;
    }
    return;
}

static __device__ bool contact_stopped_0(Island_0 * isl_0)
{
    uint _S546 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint4  _S547 = (&(globalParams_0->islands_0)[_S546])->info_1;
    bool _S548;
    if((((&(globalParams_0->islands_0)[_S546])->info_1.z) & 1U) != 0U)
    {
        _S548 = true;
    }
    else
    {
        uint _S549 = _S547.y;
        if(_S549 != 0U)
        {
            _S548 = _S549 <= (isl_0->info_1.w);
        }
        else
        {
            _S548 = false;
        }
    }
    return _S548;
}

static __device__ bool wide_runs_0(Island_0 * isl_1)
{
    uint4  _S550 = isl_1->info_1;
    bool _S551;
    if(((isl_1->info_1.z) & 1U) != 0U)
    {
        _S551 = true;
    }
    else
    {
        _S551 = (_S550.y) == 0U;
    }
    if(_S551)
    {
        return false;
    }
    if(((_S550.x) & 4U) == 0U)
    {
        _S551 = true;
    }
    else
    {
        bool _S552 = contact_stopped_0(isl_1);
        _S551 = !_S552;
    }
    return _S551;
}

__device__ __shared__ uint g_wide_run_0;

static __device__ bool wide_enter_0(uint tid_4, Island_0 * isl_2)
{
    seen_clear_0(tid_4);
    if(tid_4 == 0U)
    {
        bool _S553 = wide_runs_0(isl_2);
        int _S554;
        if(_S553)
        {
            _S554 = int(1);
        }
        else
        {
            _S554 = int(0);
        }
        *&g_wide_run_0 = uint(_S554);
    }
    __syncthreads();
    return (*&g_wide_run_0) != 0U;
}

static __device__ uint wide_step_0(Island_0 * isl_3)
{
    uint _S555 = isl_3->info_1.w;
    uint _S556 = __ldg(&globalParams_0->params_0->step_start_0);
    return _S555 - _S556;
}

static __device__ float time_since_0(float4  origin_0, uint k_8, float dt_2)
{
    float _S557 = __ldg(&globalParams_0->params_0->t_hi_0);
    float _S558 = _S557 - origin_0.x;
    float _S559 = __ldg(&globalParams_0->params_0->t_lo_0);
    return _S558 + (_S559 - origin_0.y) + float(k_8) * dt_2;
}

static __device__ float table_eval_0(uint offset_0, uint count_2, float tau_0)
{
    float4  _S560 = __ldg((&(globalParams_0->loads_0)[offset_0]));
    if(tau_0 <= (_S560.x))
    {
        return _S560.y;
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
        uint _S561 = offset_0 + i_10;
        float4  _S562 = __ldg((&(globalParams_0->loads_0)[_S561]));
        float _S563 = _S562.x;
        if(tau_0 <= _S563)
        {
            float4  _S564 = __ldg((&(globalParams_0->loads_0)[_S561 - 1U]));
            float _S565 = _S564.x;
            float _S566 = _S564.y;
            return _S566 + (tau_0 - _S565) / (F32_max((_S563 - _S565), (1.00000000317107685e-30f))) * (_S562.y - _S566);
        }
        i_10 = i_10 + 1U;
    }
    float4  _S567 = __ldg((&(globalParams_0->loads_0)[offset_0 + count_2 - 1U]));
    return _S567.y;
}

static __device__ float eval_function_0(uint term_0, uint k_9, float dt_3, float shift_0)
{
    uint _S568 = 5U * term_0;
    float4  _S569 = __ldg((&(globalParams_0->loads_0)[_S568]));
    uint4  info_2 = asuint_0(_S569);
    float4  _S570 = __ldg((&(globalParams_0->loads_0)[_S568 + 3U]));
    float4  _S571 = __ldg((&(globalParams_0->loads_0)[_S568 + 4U]));
    uint kind_0 = info_2.z;
    if(kind_0 == 0U)
    {
        return _S570.z;
    }
    float tau_1 = time_since_0(_S570, k_9, dt_3) + shift_0;
    float shape_1;
    if(kind_0 == 1U)
    {
        if(tau_1 <= 0.0f)
        {
            shape_1 = 0.0f;
        }
        else
        {
            float _S572 = _S571.x;
            if(tau_1 >= _S572)
            {
                shape_1 = _S571.y;
            }
            else
            {
                shape_1 = _S571.y * tau_1 / _S572;
            }
        }
        return shape_1;
    }
    bool _S573;
    if(kind_0 == 2U)
    {
        if(tau_1 < 0.0f)
        {
            _S573 = true;
        }
        else
        {
            _S573 = tau_1 > (_S571.x);
        }
        if(_S573)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S571.y * (F32_sin((3.14159274101257324f * tau_1 / _S571.x)));
        }
        return shape_1;
    }
    if(kind_0 == 3U)
    {
        float sn_0 = tau_1 / _S571.y;
        if(sn_0 < 0.0f)
        {
            _S573 = true;
        }
        else
        {
            _S573 = sn_0 > 1.0f;
        }
        if(_S573)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S571.x * (1.0f - sn_0) * (F32_exp((- _S571.z * sn_0)));
        }
        return shape_1;
    }
    if(kind_0 == 4U)
    {
        return table_eval_0(info_2.w, (F32_asuint((_S571.x))), tau_1);
    }
    if(kind_0 == 5U)
    {
        (*&g_seen_0)[1U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float sn_1 = tau_1 / _S571.x;
        if(sn_1 < 0.0f)
        {
            _S573 = true;
        }
        else
        {
            _S573 = sn_1 > 1.0f;
        }
        if(_S573)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = (1.0f - sn_1) * (F32_exp((- _S571.y * sn_1)));
        }
        float clearing_0 = _S570.w;
        float relax_0;
        if(clearing_0 > 0.0f)
        {
            relax_0 = (F32_max((1.0f - tau_1 / clearing_0), (0.0f)));
        }
        else
        {
            relax_0 = 0.0f;
        }
        float _S574 = _S571.w;
        return (_S574 + (_S571.z - _S574) * relax_0) * shape_1;
    }
    if(kind_0 == 7U)
    {
        (*&g_seen_0)[2U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float _S575 = _S571.y;
        if(tau_1 < _S575)
        {
            return _S571.x;
        }
        float s_1 = tau_1 - _S575;
        float _S576 = _S571.w;
        if(s_1 > _S576)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S571.z * (F32_sin((3.14159274101257324f * s_1 / _S576)));
        }
        return shape_1;
    }
    float _S577 = _S571.x;
    if(_S577 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp_0(1.0f - tau_1 / _S577, 0.0f, 1.0f);
}

static __device__ void record_chunk_load_0(uint c_5, float3  f_3, float3  t_2)
{
    uint _S578 = __ldg(&globalParams_0->params_0->solve_mode_0);
    if(_S578 == 0U)
    {
        return;
    }
    uint _S579 = __ldg(&globalParams_0->params_0->cload_base_0);
    uint _S580 = 2U * c_5;
    *(&(globalParams_0->scratch_0)[_S579 + _S580]) = make_float4 (f_3.x, f_3.y, f_3.z, 0.0f);
    uint _S581 = __ldg(&globalParams_0->params_0->cload_base_0);
    *(&(globalParams_0->scratch_0)[_S581 + _S580 + 1U]) = make_float4 (t_2.x, t_2.y, t_2.z, 0.0f);
    uint _S582 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  * _S583 = (&(globalParams_0->scratch_0)[_S582 + _S580]);
    uint _S584 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  _S585 = *(&(globalParams_0->scratch_0)[_S584 + _S580]);
    *_S583 = make_float4 ((float3 {_S585.x, _S585.y, _S585.z} + f_3).x, (float3 {_S585.x, _S585.y, _S585.z} + f_3).y, (float3 {_S585.x, _S585.y, _S585.z} + f_3).z, 0.0f);
    uint _S586 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  * _S587 = (&(globalParams_0->scratch_0)[_S586 + _S580 + 1U]);
    uint _S588 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  _S589 = *(&(globalParams_0->scratch_0)[_S588 + _S580 + 1U]);
    *_S587 = make_float4 ((float3 {_S589.x, _S589.y, _S589.z} + t_2).x, (float3 {_S589.x, _S589.y, _S589.z} + t_2).y, (float3 {_S589.x, _S589.y, _S589.z} + t_2).z, 0.0f);
    return;
}

static __device__ void chunk_loads_0(uint _S590, uint _S591, Quat_0 * _S592, uint _S593, float _S594, bool _S595, float _S596, float3  * _S597, float3  * _S598, float3  * _S599, float3  * _S600)
{
    bool _S601;
    ChunkStatic_0 * _S602 = (&(globalParams_0->chunks_0)[_S591]);
    float3  _S603 = make_float3 (0.0f);
    *_S597 = _S603;
    *_S598 = _S603;
    *_S599 = _S603;
    *_S600 = _S603;
    uint4  _S604 = __ldg(&_S602->load_range_0);
    uint term_1 = _S604.x;
    for(;;)
    {
        if(term_1 < (_S604.y))
        {
        }
        else
        {
            break;
        }
        (*&g_seen_0)[0U] = 1U;
        uint _S605 = 5U * term_1;
        float4  _S606 = __ldg((&(globalParams_0->loads_0)[_S605]));
        uint _S607 = asuint_0(_S606).y;
        bool replacement_0 = _S607 == 2U;
        float4  _S608 = __ldg((&(globalParams_0->loads_0)[_S605 + 1U]));
        float4  _S609 = __ldg((&(globalParams_0->loads_0)[_S605 + 2U]));
        float _S610;
        if(replacement_0)
        {
            _S610 = _S596;
        }
        else
        {
            _S610 = 0.0f;
        }
        float value_0 = eval_function_0(term_1, _S593, _S594, _S610);
        if(replacement_0)
        {
            *_S599 = *_S599 + float3 {_S608.x, _S608.y, _S608.z} * make_float3 (value_0);
            *_S600 = *_S600 + float3 {_S609.x, _S609.y, _S609.z} * make_float3 (value_0);
            term_1 = term_1 + 1U;
            continue;
        }
        if(_S607 == 0U)
        {
            _S601 = true;
        }
        else
        {
            _S601 = _S607 == 3U;
        }
        float3  fw_0;
        if(_S601)
        {
            fw_0 = float3 {_S608.x, _S608.y, _S608.z} * make_float3 (value_0);
        }
        else
        {
            float3  _S611 = rotate_0(_S592, float3 {_S608.x, _S608.y, _S608.z});
            fw_0 = _S611 * make_float3 (- value_0 * _S608.w);
        }
        float3  lever_0;
        if(_S607 == 3U)
        {
            float4  _S612 = *(&(globalParams_0->state_0)[4U * _S590]);
            lever_0 = float3 {_S609.x, _S609.y, _S609.z} - float3 {_S612.x, _S612.y, _S612.z};
        }
        else
        {
            lever_0 = float3 {_S609.x, _S609.y, _S609.z};
        }
        *_S597 = *_S597 + fw_0;
        float3  _S613 = rotate_0(_S592, lever_0);
        *_S598 = *_S598 + cross_0(_S613, fw_0);
        term_1 = term_1 + 1U;
    }
    if(_S595)
    {
        uint4  _S614 = __ldg(&_S602->cinfo_0);
        _S601 = (_S614.z) != 0U;
    }
    else
    {
        _S601 = false;
    }
    if(_S601)
    {
        uint4  _S615 = __ldg(&_S602->cinfo_0);
        uint g_1 = _S615.x;
        for(;;)
        {
            if(g_1 < (_S615.y))
            {
            }
            else
            {
                break;
            }
            uint _S616 = __ldg(&globalParams_0->params_0->seg_base_0);
            uint _S617 = 2U * g_1;
            float4  _S618 = *(&(globalParams_0->scratch_0)[_S616 + _S617]);
            *_S597 = *_S597 + float3 {_S618.x, _S618.y, _S618.z};
            uint _S619 = __ldg(&globalParams_0->params_0->seg_base_0);
            float4  _S620 = *(&(globalParams_0->scratch_0)[_S619 + _S617 + 1U]);
            *_S598 = *_S598 + float3 {_S620.x, _S620.y, _S620.z};
            g_1 = g_1 + 1U;
        }
    }
    return;
}

static __device__ void chunk_external_0(uint _S621, uint _S622, Quat_0 * _S623, uint _S624, float _S625, bool _S626, float3  * _S627, float3  * _S628)
{
    float3  rf_0;
    float3  rm_0;
    chunk_loads_0(_S621, _S622, _S623, _S624, _S625, _S626, 0.0f, _S627, _S628, &rf_0, &rm_0);
    return;
}

static __device__ float settled_chunk_load_0(uint c_6, Quat_0 * rot_0, uint k_10, float dt_4, bool contact_0)
{
    float3  f_4;
    float3  t_3;
    chunk_external_0(c_6, c_6, rot_0, k_10, dt_4, contact_0, &f_4, &t_3);
    record_chunk_load_0(c_6, f_4, t_3);
    return length_0(f_4);
}

static __device__ uint seen_bits_0()
{
    uint _S629;
    if(((*&g_seen_0)[0U]) != 0U)
    {
        _S629 = 32768U;
    }
    else
    {
        _S629 = 0U;
    }
    uint _S630;
    if(((*&g_seen_0)[1U]) != 0U)
    {
        _S630 = 65536U;
    }
    else
    {
        _S630 = 0U;
    }
    uint _S631 = _S629 | _S630;
    if(((*&g_seen_0)[2U]) != 0U)
    {
        _S629 = 131072U;
    }
    else
    {
        _S629 = 0U;
    }
    uint _S632 = _S631 | _S629;
    if(((*&g_seen_0)[3U]) != 0U)
    {
        _S629 = 32U;
    }
    else
    {
        _S629 = 0U;
    }
    uint _S633 = _S632 | _S629;
    if(((*&g_seen_0)[4U]) != 0U)
    {
        _S629 = 64U;
    }
    else
    {
        _S629 = 0U;
    }
    return _S633 | _S629;
}

static __device__ bool wide_enter_1(uint _S634, uint _S635)
{
    Island_0 _S636 = *(&(globalParams_0->islands_0)[_S635]);
    seen_clear_0(_S634);
    if(_S634 == 0U)
    {
        Island_0 _S637 = _S636;
        bool _S638 = wide_runs_0(&_S637);
        int _S639;
        if(_S638)
        {
            _S639 = int(1);
        }
        else
        {
            _S639 = int(0);
        }
        *&g_wide_run_0 = uint(_S639);
    }
    __syncthreads();
    return (*&g_wide_run_0) != 0U;
}

extern "C" __global__ void wide_wake()
{
    uint _S640 = 0U;
    uint _S641;
    uint _S642 = __ballot_sync(4294967295U, true);
    uint tid_5 = threadIdx.x;
    uint _S643 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S644 = blockIdx.x;
    WideGroup_0 wg_0 = wide_group_0(_S643, _S644);
    bool _S645 = _S644 != (wg_0.first_0);
    uint _S646 = __ballot_sync(_S642, _S645);
    if(_S645)
    {
        return;
    }
    else
    {
        uint _S647 = __ballot_sync(_S642, true);
        _S640 = _S647;
    }
    Island_0 * _S648 = (&(globalParams_0->islands_0)[wg_0.island_2]);
    Island_0 isl_4 = *_S648;
    uint _S649 = (*_S648).info_1.x;
    bool _S650 = (_S649 & 16U) == 0U;
    uint _S651 = __ballot_sync(_S640, _S650);
    bool _S652;
    uint c_7;
    if(_S650)
    {
        uint _S653 = __ballot_sync(_S640, true);
        _S652 = true;
        c_7 = _S653;
    }
    else
    {
        bool _S654 = wide_enter_1(tid_5, wg_0.island_2);
        bool _S655 = !_S654;
        uint _S656 = __ballot_sync(_S640, true);
        _S652 = _S655;
        c_7 = _S656;
    }
    uint _S657 = 0U;
    uint _S658 = __ballot_sync(c_7, _S652);
    if(_S652)
    {
        return;
    }
    else
    {
        uint _S659 = __ballot_sync(c_7, true);
        _S657 = _S659;
    }
    Quat_0 _S660 = quat_of_0(isl_4.rotation_0);
    bool _S661 = (_S649 & 4U) != 0U;
    float3  _S662 = make_float3 (0.0f);
    float3  norm_0 = _S662;
    float3  unused_1 = _S662;
    c_7 = isl_4.range_0.x + tid_5;
    uint cov_0;
    cov_0 = _S657;
    for(;;)
    {
        bool _S663 = c_7 < (isl_4.range_0.y);
        uint _S664 = __ballot_sync(cov_0, _S663);
        if(_S663)
        {
            uint _S665 = __ballot_sync(cov_0, true);
        }
        else
        {
            uint _S666 = __ballot_sync(cov_0, false);
            uint _S667 = __ballot_sync(cov_0, false);
            uint _S668 = __ballot_sync(_S657, true);
            _S641 = _S668;
            break;
        }
        Island_0 _S669 = isl_4;
        uint _S670 = wide_step_0(&_S669);
        float _S671 = __ldg(&globalParams_0->params_0->dt_0);
        Quat_0 _S672 = _S660;
        float _S673 = settled_chunk_load_0(c_7, &_S672, _S670, _S671, _S661);
        *&((&norm_0)->x) = *&((&norm_0)->x) + _S673;
        uint _S674 = __ballot_sync(cov_0, true);
        c_7 = c_7 + 256U;
        cov_0 = _S674;
    }
    group_sum3_0(tid_5, &norm_0, &unused_1, _S641);
    bool _S675 = tid_5 != 0U;
    uint _S676 = __ballot_sync(_S641, _S675);
    if(_S675)
    {
        return;
    }
    uint cov_1 = 1024U | (seen_bits_0());
    uint _S677 = __ldg(&globalParams_0->params_0->solve_mode_0);
    if(_S677 == 1U)
    {
        _S652 = (F32_abs((norm_0.x - isl_4.energy_1.z))) > (isl_4.energy_1.w);
    }
    else
    {
        _S652 = false;
    }
    if(_S652)
    {
        *&((&(&(globalParams_0->islands_0)[wg_0.island_2])->info_1)->x) = _S649 & 4294967279U;
        *&((&(&(globalParams_0->islands_0)[wg_0.island_2])->info_1)->z) = (isl_4.info_1.z) | 4U;
        cov_0 = cov_1 | 2048U;
    }
    else
    {
        cov_0 = cov_1;
    }
    cov_mark_0(wg_0.island_2, isl_4.coverage_0, cov_0);
    return;
}

static __device__ JointBond_0 slang_ldg_0(JointBond_0 * ptr_0)
{
    float4  _S678 = __ldg(&ptr_0->geom0_0);
    float4  _S679 = __ldg(&ptr_0->geom1_0);
    float4  _S680 = __ldg(&ptr_0->stiff0_0);
    float4  _S681 = __ldg(&ptr_0->stiff1_0);
    float4  _S682 = __ldg(&ptr_0->rebar0_0);
    float4  _S683 = __ldg(&ptr_0->rebar1_0);
    uint4  _S684 = __ldg(&ptr_0->ids_0);
    JointBond_0 _S685 = { _S678, _S679, _S680, _S681, _S682, _S683, _S684 };
    return _S685;
}

static __device__ bool is_damaged_0(JointState_0 * st_0)
{
    bool _S686;
    if((st_0->damage_0) > 0.0f)
    {
        _S686 = true;
    }
    else
    {
        _S686 = (st_0->crush_0) > 0.0f;
    }
    return _S686;
}

static __device__ bool connected_0(JointState_0 * st_1, bool has_rebar_0)
{
    bool _S687;
    if((st_1->damage_0) < 1.0f)
    {
        _S687 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S687 = (st_1->rebar_broken_0) == 0.0f;
        }
        else
        {
            _S687 = false;
        }
    }
    return _S687;
}

static __device__ float fdiv_0(float a_7, float b_21)
{
    return a_7 / b_21;
}

static __device__ float fsqrt_0(float a_8)
{
    return (F32_sqrt((a_8)));
}

struct Measures_0
{
    float tension_0;
    float shear_0;
    float normal_compression_0;
    float compression_0;
    float compressive_force_0;
};

static __device__ Measures_0 stress_measures_0(JointBond_0 * b_22, float3  q_lin_0, float3  q_ang_0)
{
    float area_2 = b_22->geom0_0.x;
    float _S688 = q_lin_0.z;
    float axial_0 = fdiv_0(_S688, area_2);
    float bending_0 = fdiv_0((F32_abs((q_ang_0.x))), b_22->geom1_0.x) + fdiv_0((F32_abs((q_ang_0.y))), b_22->geom1_0.y);
    float _S689 = q_lin_0.x;
    float _S690 = q_lin_0.y;
    float shear_1 = fdiv_0(fsqrt_0(_S689 * _S689 + _S690 * _S690), area_2) + fdiv_0((F32_abs((q_ang_0.z))), b_22->geom0_0.w);
    Measures_0 m_2;
    (&m_2)->tension_0 = axial_0 + bending_0;
    (&m_2)->shear_0 = shear_1;
    float _S691 = - axial_0;
    (&m_2)->normal_compression_0 = (F32_max((_S691), (0.0f)));
    (&m_2)->compression_0 = _S691 + bending_0;
    (&m_2)->compressive_force_0 = (F32_max((- _S688), (0.0f)));
    return m_2;
}

static __device__ float expm1_accurate_0(float x_18)
{
    if((F32_abs((x_18))) < 0.00100000004749745f)
    {
        return x_18 * (1.0f + x_18 * (0.5f + x_18 * 0.1666666716337204f));
    }
    return (F32_exp((x_18))) - 1.0f;
}

static __device__ float fpow_0(float a_9, float b_23)
{
    return (F32_pow((a_9), (b_23)));
}

static __device__ float dif_factor_0(JointMaterial_0 * mat_1, float strain_rate_1)
{
    float r_5 = (F32_abs((strain_rate_1)));
    float4  _S692 = mat_1->dif_0;
    float ref_0 = mat_1->dif_0.x;
    if(r_5 <= ref_0)
    {
        return 1.0f;
    }
    float _S693 = _S692.z;
    float f_5;
    if(r_5 <= _S693)
    {
        f_5 = fpow_0(fdiv_0(r_5, ref_0), _S692.y);
    }
    else
    {
        f_5 = fpow_0(fdiv_0(_S693, ref_0), _S692.y) * fpow_0(fdiv_0(r_5, _S693), _S692.w);
    }
    return clamp_0(f_5, 1.0f, mat_1->misc_0.x);
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

static __device__ float4  failure_indices_0(JointMaterial_0 * mat_3, JointBond_0 * b_24, Measures_0 * m_3, float multiplier_0)
{
    float fc_0 = mat_3->strength_0.y * multiplier_0;
    float _S694 = (F32_min((mat_3->strength_0.z * multiplier_0 + mat_3->strength_0.w * m_3->normal_compression_0), (mat_3->energy_0.x * multiplier_0)));
    float4  idx_0;
    *&((&idx_0)->x) = (F32_max((fdiv_0(m_3->tension_0, mat_3->strength_0.x * multiplier_0)), (0.0f)));
    float _S695;
    if(_S694 > 0.0f)
    {
        _S695 = fdiv_0(m_3->shear_0, _S694);
    }
    else
    {
        _S695 = infinity_0();
    }
    *&((&idx_0)->y) = _S695;
    *&((&idx_0)->z) = (F32_max((fdiv_0(m_3->compression_0, fc_0)), (0.0f)));
    float _S696 = b_24->stiff1_0.y;
    if(_S696 > 0.0f)
    {
        _S695 = fdiv_0(m_3->compressive_force_0, _S696);
    }
    else
    {
        _S695 = 0.0f;
    }
    *&((&idx_0)->w) = _S695;
    return idx_0;
}

static __device__ float sq_0(float x_19)
{
    return x_19 * x_19;
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
    float _S697 = (F32_max((damage_law_0(kind_2, lambda_0, r_7)), (d_old_0)));
    bool _S698;
    if(_S697 <= d_old_0)
    {
        _S698 = true;
    }
    else
    {
        _S698 = d_old_0 >= 1.0f;
    }
    if(_S698)
    {
        return make_float2 (d_old_0, 0.0f);
    }
    float u0_0 = fdiv_0(psi_0, lambda_0 * lambda_0);
    float _S699 = (F32_max((kappa_old_0), (1.0f)));
    if(kind_2 == 0U)
    {
        if(r_7 > 1.0f)
        {
            return make_float2 (_S697, fdiv_0(u0_0 * r_7, r_7 - 1.0f) * (F32_max(((F32_min((lambda_0), (r_7))) - (F32_min((_S699), (r_7)))), (0.0f))));
        }
        return make_float2 (_S697, (1.0f - d_old_0) * psi_0);
    }
    float ku_0 = 0.5f * (r_7 + 1.0f);
    float plateau_0 = u0_0 * (F32_max(((F32_min((lambda_0), (ku_0))) - (F32_min((_S699), (ku_0)))), (0.0f)));
    float snap_0;
    if(_S697 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return make_float2 (_S697, plateau_0 + snap_0);
}

static __device__ void compressed_region_0(float w0_0, float w1_0, float dz_0, float ax_0, float ay_0, FixedArray<float, 6>  * region_0)
{
    uint count_3;
    float h0_0 = 0.5f * w0_0;
    float h1_0 = 0.5f * w1_0;
    float _S700 = - h0_0;
    float _S701 = - h1_0;
    FixedArray<float2 , 4>  _S702 = { {
        float2 {
            _S700, _S701
        }, float2 {
            h0_0, _S701
        }, float2 {
            h0_0, h1_0
        }, float2 {
            _S700, h1_0
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
        uint _S703 = i_11;
        uint _S704 = i_11 + 1U;
        uint _S705 = _S704 % 4U;
        float _S706 = _S702[i_11].y;
        float _S707 = _S702[i_11].x;
        float fp_0 = dz_0 + ax_0 * _S706 - ay_0 * _S707;
        float _S708 = _S702[_S705].y;
        float _S709 = _S702[_S705].x;
        float fq_0 = dz_0 + ax_0 * _S708 - ay_0 * _S709;
        bool _S710 = fp_0 < 0.0f;
        if(_S710)
        {
            uint _S711 = count_4 + 1U;
            poly_0[count_4] = _S702[_S703];
            count_3 = _S711;
        }
        else
        {
            count_3 = count_4;
        }
        if(_S710 != (fq_0 < 0.0f))
        {
            float t_4 = fp_0 / (fp_0 - fq_0);
            uint _S712 = count_3 + 1U;
            poly_0[count_3] = make_float2 (_S707 + t_4 * (_S709 - _S707), _S706 + t_4 * (_S708 - _S706));
            count_4 = _S712;
        }
        else
        {
            count_4 = count_3;
        }
        i_11 = _S704;
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
    float a_10 = 0.0f;
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
        float _S713 = o_1.x;
        float x0_0 = poly_0[i_11].x - _S713;
        float _S714 = o_1.y;
        float y0_0 = poly_0[i_11].y - _S714;
        uint _S715 = i_11 + 1U;
        uint _S716 = _S715 % count_4;
        float x1_0 = poly_0[_S716].x - _S713;
        float y1_0 = poly_0[_S716].y - _S714;
        float _S717 = x0_0 * y1_0;
        float _S718 = x1_0 * y0_0;
        float cr_0 = _S717 - _S718;
        float a_11 = a_10 + cr_0 / 2.0f;
        float sx_1 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        float sy_1 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        float ixx_1 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        float iyy_1 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        float ixy_1 = ixy_0 + (_S717 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S718) * cr_0 / 24.0f;
        i_11 = _S715;
        a_10 = a_11;
        sx_0 = sx_1;
        sy_0 = sy_1;
        ixx_0 = ixx_1;
        iyy_0 = iyy_1;
        ixy_0 = ixy_1;
    }
    if(a_10 <= 0.0f)
    {
        return;
    }
    float cx_0 = sx_0 / a_10;
    float cy_0 = sy_0 / a_10;
    (*region_0)[int(0)] = a_10;
    (*region_0)[int(1)] = o_1.x + cx_0;
    (*region_0)[int(2)] = o_1.y + cy_0;
    float _S719 = a_10 * cx_0;
    (*region_0)[int(3)] = ixx_0 - _S719 * cx_0;
    (*region_0)[int(4)] = iyy_0 - a_10 * cy_0 * cy_0;
    (*region_0)[int(5)] = ixy_0 - _S719 * cy_0;
    return;
}

static __device__ __noinline__ float4  no_tension_patch_0(float kn_0, float w0_1, float w1_1, float dz_1, float ax_1, float ay_1)
{
    FixedArray<float, 6>  r_8;
    compressed_region_0(w0_1, w1_1, dz_1, ax_1, ay_1, &r_8);
    float a_12 = r_8[int(0)];
    if((r_8[int(0)]) == 0.0f)
    {
        return make_float4 (0.0f);
    }
    float k_11 = kn_0 / (w0_1 * w1_1);
    float fc_1 = dz_1 + ax_1 * r_8[int(2)] - ay_1 * r_8[int(1)];
    float _S720 = a_12 * fc_1;
    float _S721 = - ay_1;
    return make_float4 (k_11 * a_12 * fc_1, k_11 * (_S720 * r_8[int(2)] + (_S721 * r_8[int(5)] + ax_1 * r_8[int(4)])), - k_11 * (_S720 * r_8[int(1)] + (_S721 * r_8[int(3)] + ax_1 * r_8[int(5)])), 0.5f * k_11 * (_S720 * fc_1 + ay_1 * ay_1 * r_8[int(3)] + ax_1 * ax_1 * r_8[int(4)] - 2.0f * ax_1 * ay_1 * r_8[int(5)]));
}

static __device__ float signum_0(float x_20)
{
    float _S722;
    if(((F32_asuint((x_20))) & 2147483648U) != 0U)
    {
        _S722 = -1.0f;
    }
    else
    {
        _S722 = 1.0f;
    }
    return _S722;
}

static __device__ float2  return_map_0(float k_12, float total_2, float plastic_0, float cap_0)
{
    float trial_0 = k_12 * (total_2 - plastic_0);
    if((F32_abs((trial_0))) <= cap_0)
    {
        return make_float2 (trial_0, 0.0f);
    }
    float f_6 = cap_0 * signum_0(trial_0);
    return make_float2 (f_6, fdiv_0(trial_0 - f_6, k_12));
}

struct Contact_0
{
    float3  q_lin_1;
    float3  q_ang_1;
    float energy_2;
    float diss_2;
    float3  plastic_1;
};

static __device__ __noinline__ Contact_0 contact_part_0(JointMaterial_0 * mat_4, JointBond_0 * b_25, float crush_2, float3  plastic_2, float3  d_lin_0, float3  d_ang_0)
{
    Contact_0 c_8;
    float3  _S723 = make_float3 (0.0f);
    (&c_8)->q_lin_1 = _S723;
    (&c_8)->q_ang_1 = _S723;
    (&c_8)->energy_2 = 0.0f;
    (&c_8)->diss_2 = 0.0f;
    (&c_8)->plastic_1 = plastic_2;
    uint _S724 = mat_4->kind_flags_0.y;
    if((_S724 & 2U) == 0U)
    {
        return c_8;
    }
    float kn_1 = b_25->stiff0_0.x;
    float ks_0 = b_25->stiff0_0.y;
    float kt_0 = b_25->stiff1_0.x;
    float w0_2 = b_25->geom0_0.y;
    float w1_2 = b_25->geom0_0.z;
    float diss_3;
    float nc_sum_0;
    float m1_0;
    float m2_0;
    float energy_3;
    if((_S724 & 4U) != 0U)
    {
        float4  p_8 = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        float _S725 = p_8.y;
        float _S726 = p_8.z;
        float _S727 = p_8.w;
        nc_sum_0 = p_8.x;
        m1_0 = _S725;
        m2_0 = _S726;
        energy_3 = _S727;
    }
    else
    {
        float ki_0 = kn_1 * (1.0f - crush_2) / 36.0f;
        float _S728 = d_ang_0.x;
        float _S729 = d_ang_0.y;
        float spread_0 = (F32_abs((_S728))) * 0.4166666567325592f * w1_2 + (F32_abs((_S729))) * 0.4166666567325592f * w0_2;
        float _S730 = d_lin_0.z;
        float slack_0 = 9.99999997475242708e-07f * ((F32_abs((_S730))) + spread_0);
        if((_S730 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S730 + spread_0) < (- slack_0))
            {
                float i1_0 = 2.91666650772094727f * w0_2 * w0_2;
                float i2_0 = 2.91666650772094727f * w1_2 * w1_2;
                float _S731 = ki_0 * _S728 * i2_0;
                float _S732 = ki_0 * _S729 * i1_0;
                float _S733 = 0.5f * ki_0 * (36.0f * _S730 * _S730 + _S728 * _S728 * i2_0 + _S729 * _S729 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S730;
                m1_0 = _S731;
                m2_0 = _S732;
                energy_3 = _S733;
            }
            else
            {
                uint i_12 = 0U;
                diss_3 = 0.0f;
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
                    float _S734 = SPRING_AT_0[i_12] * w0_2;
                    uint j_5 = 0U;
                    nc_sum_0 = diss_3;
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
                        float di_0 = _S730 + _S728 * s2_0 - _S729 * _S734;
                        if(di_0 < 0.0f)
                        {
                            float f_7 = ki_0 * di_0;
                            float m1_2 = m1_0 + f_7 * s2_0;
                            float m2_2 = m2_0 - f_7 * _S734;
                            float energy_5 = energy_3 + 0.5f * ki_0 * di_0 * di_0;
                            nc_sum_0 = nc_sum_0 + f_7;
                            m1_0 = m1_2;
                            m2_0 = m2_2;
                            energy_3 = energy_5;
                        }
                        j_5 = j_5 + 1U;
                    }
                    i_12 = i_12 + 1U;
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
    float3  p_9 = plastic_2;
    (&c_8)->q_lin_1 = make_float3 (0.0f, 0.0f, nc_sum_0);
    (&c_8)->q_ang_1 = make_float3 (m1_0, m2_0, 0.0f);
    float slide_cap_0 = mat_4->strength_0.w * nc_0;
    float _S735 = ks_0 * (d_lin_0.x - plastic_2.x);
    float _S736 = ks_0 * (d_lin_0.y - plastic_2.y);
    float tn_0 = fsqrt_0(_S735 * _S735 + _S736 * _S736);
    bool _S737;
    if(tn_0 > slide_cap_0)
    {
        _S737 = tn_0 > 0.0f;
    }
    else
    {
        _S737 = false;
    }
    if(_S737)
    {
        float _S738 = fdiv_0(_S735, tn_0);
        float _S739 = fdiv_0(_S736, tn_0);
        float dslip_0 = fdiv_0(tn_0 - slide_cap_0, ks_0);
        *&((&p_9)->x) = *&((&p_9)->x) + _S738 * dslip_0;
        *&((&p_9)->y) = *&((&p_9)->y) + _S739 * dslip_0;
        *&((&(&c_8)->q_lin_1)->x) = _S738 * slide_cap_0;
        *&((&(&c_8)->q_lin_1)->y) = _S739 * slide_cap_0;
        diss_3 = slide_cap_0 * dslip_0;
    }
    else
    {
        *&((&(&c_8)->q_lin_1)->x) = _S735;
        *&((&(&c_8)->q_lin_1)->y) = _S736;
        diss_3 = 0.0f;
    }
    float2  tq_0 = return_map_0(kt_0, d_ang_0.z, p_9.z, slide_cap_0 * b_25->geom1_0.z);
    float _S740 = tq_0.x;
    float _S741 = tq_0.y;
    float diss_4 = diss_3 + (F32_abs((_S740))) * (F32_abs((_S741)));
    *&((&p_9)->z) = *&((&p_9)->z) + _S741;
    *&((&(&c_8)->q_ang_1)->z) = _S740;
    (&c_8)->energy_2 = energy_3 + 0.5f * (fdiv_0(sq_0((&c_8)->q_lin_1.x), ks_0) + fdiv_0(sq_0((&c_8)->q_lin_1.y), ks_0) + fdiv_0(sq_0(_S740), kt_0));
    (&c_8)->diss_2 = diss_4;
    (&c_8)->plastic_1 = p_9;
    return c_8;
}

static __device__ float3  contact_offsets_0(JointMaterial_0 * mat_5, JointBond_0 * b_26, float crush_3, float3  plastic_3, float3  d_lin_1, float3  d_ang_1)
{
    uint _S742 = mat_5->kind_flags_0.y;
    if((_S742 & 2U) == 0U)
    {
        return plastic_3;
    }
    float kn_2 = b_26->stiff0_0.x;
    float ks_1 = b_26->stiff0_0.y;
    float kt_1 = b_26->stiff1_0.x;
    float w0_3 = b_26->geom0_0.y;
    float w1_3 = b_26->geom0_0.z;
    float nc_sum_1;
    if((_S742 & 4U) != 0U)
    {
        float4  _S743 = no_tension_patch_0(kn_2 * (1.0f - crush_3), w0_3, w1_3, d_lin_1.z, d_ang_1.x, d_ang_1.y);
        nc_sum_1 = _S743.x;
    }
    else
    {
        float ki_1 = kn_2 * (1.0f - crush_3) / 36.0f;
        float _S744 = d_ang_1.x;
        float _S745 = d_ang_1.y;
        float spread_1 = (F32_abs((_S744))) * 0.4166666567325592f * w1_3 + (F32_abs((_S745))) * 0.4166666567325592f * w0_3;
        float _S746 = d_lin_1.z;
        float slack_1 = 9.99999997475242708e-07f * ((F32_abs((_S746))) + spread_1);
        if((_S746 - spread_1) > slack_1)
        {
            nc_sum_1 = 0.0f;
        }
        else
        {
            if((_S746 + spread_1) < (- slack_1))
            {
                nc_sum_1 = ki_1 * 36.0f * _S746;
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
                    float _S747 = SPRING_AT_0[i_13] * w0_3;
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
                        float di_1 = _S746 + _S744 * (SPRING_AT_0[j_6] * w1_3) - _S745 * _S747;
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
    float3  p_10 = plastic_3;
    float slide_cap_1 = mat_5->strength_0.w * nc_1;
    float _S748 = ks_1 * (d_lin_1.x - plastic_3.x);
    float _S749 = ks_1 * (d_lin_1.y - plastic_3.y);
    float tn_1 = fsqrt_0(_S748 * _S748 + _S749 * _S749);
    bool _S750;
    if(tn_1 > slide_cap_1)
    {
        _S750 = tn_1 > 0.0f;
    }
    else
    {
        _S750 = false;
    }
    if(_S750)
    {
        float _S751 = fdiv_0(_S749, tn_1);
        float dslip_1 = fdiv_0(tn_1 - slide_cap_1, ks_1);
        *&((&p_10)->x) = *&((&p_10)->x) + fdiv_0(_S748, tn_1) * dslip_1;
        *&((&p_10)->y) = *&((&p_10)->y) + _S751 * dslip_1;
    }
    *&((&p_10)->z) = *&((&p_10)->z) + return_map_0(kt_1, d_ang_1.z, p_10.z, slide_cap_1 * b_26->geom1_0.z).y;
    return p_10;
}

static __device__ float life_rate_0(JointMaterial_0 * mat_6, float s_2)
{
    if(s_2 <= 0.0f)
    {
        return 0.0f;
    }
    float _S752 = mat_6->misc_0.y;
    return fdiv_0((_S752 + 1.0f) * fpow_0(s_2, _S752), mat_6->misc_0.z);
}

struct JointResponse_0
{
    float3  force_lin_1;
    float3  force_ang_1;
    JointState_0 state_1;
    float dissipated_2;
    float overshoot_0;
    float stored_3;
    bool disconnected_0;
    float fatigue_before_0;
    Measures_0 measures_0;
};

static __device__ JointResponse_0 joint_evaluate_0(JointMaterial_0 * mat_7, JointBond_0 * b_27, JointState_0 * state_2, float3  d_lin_2, float3  d_ang_2, float dt_5, bool fracture_1)
{
    float kn_3 = b_27->stiff0_0.x;
    float ks_2 = b_27->stiff0_0.y;
    float kb1_0 = b_27->stiff0_0.z;
    float kb2_0 = b_27->stiff0_0.w;
    float4  _S753 = b_27->stiff1_0;
    float kt_2 = b_27->stiff1_0.x;
    bool has_rebar_1 = (b_27->stiff1_0.w) != 0.0f;
    uint kind_3 = mat_7->kind_flags_0.x;
    uint flags_1 = mat_7->kind_flags_0.y;
    bool softening_0 = (flags_1 & 1U) != 0U;
    JointState_0 st_2 = *state_2;
    bool _S754 = connected_0(state_2, has_rebar_1);
    float3  qe_lin_0 = d_lin_2 * make_float3 (ks_2, ks_2, kn_3);
    float3  qe_ang_0 = d_ang_2 * make_float3 (kb1_0, kb2_0, kt_2);
    Measures_0 _S755 = stress_measures_0(b_27, qe_lin_0, qe_ang_0);
    float _S756 = (F32_max(((F32_max((_S755.tension_0), (_S755.shear_0)))), (_S755.compression_0)));
    bool _S757 = dt_5 > 0.0f;
    float dif_1;
    if(_S757)
    {
        float raw_0 = fdiv_0((F32_max((fdiv_0(_S756 - (&st_2)->governing_stress_0, dt_5)), (0.0f))), mat_7->misc_0.w);
        float tau_2 = _S753.z;
        if((flags_1 & 16U) != 0U)
        {
            dif_1 = - expm1_accurate_0(- fdiv_0(dt_5, tau_2));
        }
        else
        {
            dif_1 = (F32_min((fdiv_0(dt_5, tau_2)), (1.0f)));
        }
        (&st_2)->strain_rate_0 = (&st_2)->strain_rate_0 + (raw_0 - (&st_2)->strain_rate_0) * dif_1;
        (&st_2)->governing_stress_0 = _S756;
    }
    if((flags_1 & 32U) != 0U)
    {
        float _S758 = dif_factor_0(mat_7, (&st_2)->strain_rate_0);
        dif_1 = _S758;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = b_27->geom1_0.w;
    float _S759 = fatigue_factor_0(mat_7, (&st_2)->life_0);
    float multiplier_1 = weibull_0 * dif_1 * _S759;
    Measures_0 _S760 = _S755;
    float4  _S761 = failure_indices_0(mat_7, b_27, &_S760, multiplier_1);
    float _S762 = _S761.x;
    float _S763 = _S761.y;
    (&st_2)->utilization_0 = (F32_max(((F32_max((_S762), (_S763)))), ((F32_max((_S761.z), (_S761.w))))));
    float _S764 = d_lin_2.x;
    float _S765 = d_lin_2.y;
    float _S766 = ks_2 * (sq_0(_S764) + sq_0(_S765)) + kb1_0 * sq_0(d_ang_2.x) + kb2_0 * sq_0(d_ang_2.y) + kt_2 * sq_0(d_ang_2.z);
    float _S767 = d_lin_2.z;
    bool _S768 = _S767 > 0.0f;
    if(_S768)
    {
        dif_1 = kn_3 * sq_0(_S767);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S766 + dif_1);
    float psi_c_0;
    if(_S767 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_3 * sq_0(_S767);
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
    bool _S769;
    float3  qc_lin_0;
    if(fracture_1)
    {
        bool _S770 = _S762 >= _S763;
        if(_S770)
        {
            diss_contact_0 = _S762;
        }
        else
        {
            diss_contact_0 = _S763;
        }
        uint mode_ts_0;
        if(_S770)
        {
            mode_ts_0 = 1U;
        }
        else
        {
            mode_ts_0 = 2U;
        }
        if(diss_contact_0 > ((&st_2)->kappa_0))
        {
            _S769 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S769 = false;
        }
        if(_S769)
        {
            _S769 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S769 = false;
        }
        uint mode_c_0;
        if(_S769)
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
                intact_normal_0 = fdiv_0(psi_contact_0 * b_27->geom0_0.x * diss_contact_0 * diss_contact_0, psi_ts_0);
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
            float _S771 = inc_0.x;
            if(_S771 > ((&st_2)->damage_0))
            {
                Contact_0 _S772 = contact_part_0(mat_7, b_27, (&st_2)->crush_0, plastic_4, d_lin_2, d_ang_2);
                float _S773 = (F32_max((_S772.energy_2 - (1.0f - (&st_2)->crush_0) * psi_c_0), (0.0f)));
                float _S774 = (F32_max((inc_0.y - _S773 * (_S771 - (&st_2)->damage_0)), (0.0f)));
                float _S775 = (F32_max(((psi_ts_0 - _S773) * (_S771 - (&st_2)->damage_0) - _S774), (0.0f)));
                (&st_2)->damage_0 = _S771;
                (&st_2)->mode_0 = mode_ts_0;
                dissipated_3 = _S774;
                overshoot_1 = _S775;
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
        float _S776 = state_2->damage_0;
        if((state_2->damage_0) > 0.0f)
        {
            Contact_0 _S777 = contact_part_0(mat_7, b_27, state_2->crush_0, make_float3 (state_2->plastic_x_0, state_2->plastic_y_0, state_2->plastic_t_0), d_lin_2, d_ang_2);
            qc_lin_0 = qe_ang_0 * make_float3 (1.0f - _S776) + _S777.q_ang_1 * make_float3 (_S776);
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S778 = stress_measures_0(b_27, make_float3 (0.0f, 0.0f, (F32_min((qe_lin_0.z), (0.0f)))), qc_lin_0);
        Measures_0 _S779 = _S778;
        float4  _S780 = failure_indices_0(mat_7, b_27, &_S779, multiplier_1);
        float _S781 = _S780.z;
        float _S782 = _S780.w;
        bool _S783 = _S781 >= _S782;
        if(_S783)
        {
            psi_contact_0 = _S781;
        }
        else
        {
            psi_contact_0 = _S782;
        }
        if(_S783)
        {
            mode_c_0 = 3U;
        }
        else
        {
            mode_c_0 = 4U;
        }
        if(psi_contact_0 > ((&st_2)->kappa_c_0))
        {
            _S769 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S769 = false;
        }
        if(_S769)
        {
            _S769 = psi_c_0 > 0.0f;
        }
        else
        {
            _S769 = false;
        }
        if(_S769)
        {
            if(softening_0)
            {
                intact_normal_0 = fdiv_0(mat_7->energy_0.w * b_27->geom0_0.x * psi_contact_0 * psi_contact_0, psi_c_0);
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
            float _S784 = inc_1.x;
            if(_S784 > ((&st_2)->crush_0))
            {
                float _S785 = inc_1.y;
                float dissipated_4 = dissipated_3 + _S785;
                float overshoot_2 = overshoot_1 + (F32_max((psi_c_0 * (_S784 - (&st_2)->crush_0) - _S785), (0.0f)));
                (&st_2)->crush_0 = _S784;
                (&st_2)->mode_0 = mode_c_0;
                if(_S784 >= 1.0f)
                {
                    _S769 = ((&st_2)->damage_0) < 1.0f;
                }
                else
                {
                    _S769 = false;
                }
                if(_S769)
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
    float3  _S786 = make_float3 (0.0f);
    float3  qc_ang_0;
    if(((&st_2)->damage_0) == 0.0f)
    {
        if((flags_1 & 8U) == 0U)
        {
            float3  _S787 = contact_offsets_0(mat_7, b_27, (&st_2)->crush_0, plastic_4, d_lin_2, d_ang_2);
            (&st_2)->plastic_x_0 = _S787.x;
            (&st_2)->plastic_y_0 = _S787.y;
            (&st_2)->plastic_t_0 = _S787.z;
        }
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S786;
        qc_ang_0 = _S786;
        psi_contact_0 = 0.0f;
    }
    else
    {
        Contact_0 _S788 = contact_part_0(mat_7, b_27, (&st_2)->crush_0, plastic_4, d_lin_2, d_ang_2);
        (&st_2)->plastic_x_0 = _S788.plastic_1.x;
        (&st_2)->plastic_y_0 = _S788.plastic_1.y;
        (&st_2)->plastic_t_0 = _S788.plastic_1.z;
        diss_contact_0 = _S788.diss_2;
        qc_lin_0 = _S788.q_lin_1;
        qc_ang_0 = _S788.q_ang_1;
        psi_contact_0 = _S788.energy_2;
    }
    float dissipated_6 = dissipated_3 + dmg_0 * diss_contact_0;
    if(_S768)
    {
        intact_normal_0 = kn_3 * _S767;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_2)->crush_0) * kn_3 * _S767;
    }
    float _S789 = 1.0f - dmg_0;
    float3  force_lin_2 = make_float3 (_S789 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S789 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S789 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3  force_ang_2 = qe_ang_0 * make_float3 (_S789) + qc_ang_0 * make_float3 (dmg_0);
    float stored_4 = _S789 * (psi_ts_0 + (1.0f - (&st_2)->crush_0) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S769 = ((&st_2)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S769 = false;
    }
    float stored_5;
    float3  force_lin_3;
    if(_S769)
    {
        float k_axial_0 = b_27->rebar0_0.x;
        float k_dowel_0 = b_27->rebar0_0.y;
        float yield_force_0 = b_27->rebar0_0.z;
        float dowel_capacity_0 = b_27->rebar0_0.w;
        float2  nr_0 = return_map_0(k_axial_0, _S767, (&st_2)->rebar_plastic_0, yield_force_0);
        float2  v1_0 = return_map_0(k_dowel_0, _S764, (&st_2)->rebar_slip0_0, dowel_capacity_0);
        float2  v2_0 = return_map_0(k_dowel_0, _S765, (&st_2)->rebar_slip1_0, dowel_capacity_0);
        float _S790 = nr_0.y;
        float _S791 = v1_0.y;
        float _S792 = v2_0.y;
        float work_0 = yield_force_0 * (F32_abs((_S790))) + dowel_capacity_0 * ((F32_abs((_S791))) + (F32_abs((_S792))));
        (&st_2)->rebar_plastic_0 = (&st_2)->rebar_plastic_0 + _S790;
        (&st_2)->rebar_slip0_0 = (&st_2)->rebar_slip0_0 + _S791;
        (&st_2)->rebar_slip1_0 = (&st_2)->rebar_slip1_0 + _S792;
        (&st_2)->rebar_work_0 = (&st_2)->rebar_work_0 + work_0;
        float dissipated_7 = dissipated_6 + work_0;
        float _S793 = nr_0.x;
        float _S794 = v1_0.x;
        float _S795 = v2_0.x;
        float elastic_0 = 0.5f * (fdiv_0(sq_0(_S793), k_axial_0) + fdiv_0(sq_0(_S794) + sq_0(_S795), k_dowel_0));
        if(fracture_1)
        {
            _S769 = ((&st_2)->rebar_work_0) >= (b_27->rebar1_0.x);
        }
        else
        {
            _S769 = false;
        }
        if(_S769)
        {
            (&st_2)->rebar_broken_0 = 1.0f;
            float dissipated_8 = dissipated_7 + elastic_0;
            force_lin_3 = force_lin_2;
            dissipated_3 = dissipated_8;
            stored_5 = stored_4;
        }
        else
        {
            float stored_6 = stored_4 + elastic_0;
            force_lin_3 = force_lin_2 + make_float3 (_S794, _S795, _S793);
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
        _S769 = _S757;
    }
    else
    {
        _S769 = false;
    }
    if(_S769)
    {
        _S769 = (flags_1 & 64U) != 0U;
    }
    else
    {
        _S769 = false;
    }
    if(_S769)
    {
        Measures_0 _S796 = stress_measures_0(b_27, force_lin_3, force_ang_2);
        Measures_0 _S797 = _S796;
        float4  _S798 = failure_indices_0(mat_7, b_27, &_S797, weibull_0);
        float _S799 = life_rate_0(mat_7, (F32_max(((F32_max((_S798.x), (_S798.y)))), (_S798.z))));
        (&st_2)->life_0 = (F32_max(((&st_2)->life_0 - _S799 * dt_5), (0.0f)));
    }
    (&st_2)->dissipated_0 = (&st_2)->dissipated_0 + dissipated_3;
    JointResponse_0 resp_0;
    (&resp_0)->force_lin_1 = force_lin_3;
    (&resp_0)->force_ang_1 = force_ang_2;
    (&resp_0)->state_1 = st_2;
    (&resp_0)->dissipated_2 = dissipated_3;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_3 = stored_5;
    if(_S754)
    {
        JointState_0 _S800 = st_2;
        bool _S801 = connected_0(&_S800, has_rebar_1);
        _S769 = !_S801;
    }
    else
    {
        _S769 = false;
    }
    (&resp_0)->disconnected_0 = _S769;
    (&resp_0)->fatigue_before_0 = _S759;
    (&resp_0)->measures_0 = _S755;
    return resp_0;
}

static __device__ void secant_factors_0(JointBond_0 * b_28, JointState_0 * st_3, float3  d_lin_3, float3  * f_lin_0, float3  * f_ang_0)
{
    float _S802 = st_3->damage_0;
    bool compressed_0 = (d_lin_3.z) < 0.0f;
    float contact_1;
    if(compressed_0)
    {
        contact_1 = _S802;
    }
    else
    {
        contact_1 = 0.0f;
    }
    float _S803 = 1.0f - _S802;
    float _S804 = (F32_max((_S803 + contact_1), (9.99999997475242708e-07f)));
    float normal_4;
    if(compressed_0)
    {
        normal_4 = (F32_max((1.0f - st_3->crush_0), (9.99999997475242708e-07f)));
    }
    else
    {
        normal_4 = (F32_max((_S803), (9.99999997475242708e-07f)));
    }
    *f_lin_0 = make_float3 (_S804, _S804, normal_4);
    *f_ang_0 = make_float3 (_S804);
    bool _S805;
    if((b_28->stiff1_0.w) != 0.0f)
    {
        _S805 = (st_3->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S805 = false;
    }
    if(_S805)
    {
        float4  _S806 = b_28->rebar0_0;
        float4  _S807 = b_28->stiff0_0;
        *&(f_lin_0->z) = *&(f_lin_0->z) + fdiv_0(b_28->rebar0_0.x, b_28->stiff0_0.x);
        float _S808 = fdiv_0(_S806.y, _S807.y);
        *&(f_lin_0->x) = *&(f_lin_0->x) + _S808;
        *&(f_lin_0->y) = *&(f_lin_0->y) + _S808;
    }
    return;
}

static __device__ float3  to_local_0(uint _S809, float3  _S810)
{
    BondStatic_0 * _S811 = (&(globalParams_0->bonds_0)[_S809]);
    float4  _S812 = __ldg(&_S811->t1_0);
    float _S813 = dot_0(_S810, float3 {_S812.x, _S812.y, _S812.z});
    float4  _S814 = __ldg(&_S811->t2_0);
    float _S815 = dot_0(_S810, float3 {_S814.x, _S814.y, _S814.z});
    float4  _S816 = __ldg(&_S811->normal_0);
    return make_float3 (_S813, _S815, dot_0(_S810, float3 {_S816.x, _S816.y, _S816.z}));
}

static __device__ float3  to_body_0(uint _S817, float3  _S818)
{
    BondStatic_0 * _S819 = (&(globalParams_0->bonds_0)[_S817]);
    float4  _S820 = __ldg(&_S819->t1_0);
    float3  _S821 = float3 {_S820.x, _S820.y, _S820.z} * make_float3 (_S818.x);
    float4  _S822 = __ldg(&_S819->t2_0);
    float3  _S823 = _S821 + float3 {_S822.x, _S822.y, _S822.z} * make_float3 (_S818.y);
    float4  _S824 = __ldg(&_S819->normal_0);
    return _S823 + float3 {_S824.x, _S824.y, _S824.z} * make_float3 (_S818.z);
}

static __device__ bool bond_update_0(uint i_14, float dt_6, bool fracture_2, uint abs_step_0, bool wide_0)
{
    BondStatic_0 * _S825 = (&(globalParams_0->bonds_0)[i_14]);
    JointBond_0 _S826 = slang_ldg_0(&_S825->law_0);
    uint ca_0 = _S826.ids_0.y;
    uint cb_0 = _S826.ids_0.z;
    float4  _S827 = __ldg(&_S825->ra_0);
    float3  ra_1 = float3 {_S827.x, _S827.y, _S827.z};
    float4  _S828 = __ldg(&_S825->rb_0);
    float3  rb_1 = float3 {_S828.x, _S828.y, _S828.z};
    uint _S829 = 4U * ca_0;
    float4  _S830 = *(&(globalParams_0->state_0)[_S829]);
    float4  _S831 = *(&(globalParams_0->state_0)[_S829 + 1U]);
    float3  ta_2 = float3 {_S831.x, _S831.y, _S831.z};
    float4  _S832 = *(&(globalParams_0->state_0)[_S829 + 2U]);
    float3  va_0 = float3 {_S832.x, _S832.y, _S832.z};
    float4  _S833 = *(&(globalParams_0->state_0)[_S829 + 3U]);
    float3  wa_1 = float3 {_S833.x, _S833.y, _S833.z};
    uint _S834 = 4U * cb_0;
    float4  _S835 = *(&(globalParams_0->state_0)[_S834]);
    float4  _S836 = *(&(globalParams_0->state_0)[_S834 + 1U]);
    float3  tb_2 = float3 {_S836.x, _S836.y, _S836.z};
    float4  _S837 = *(&(globalParams_0->state_0)[_S834 + 2U]);
    float3  vb_0 = float3 {_S837.x, _S837.y, _S837.z};
    float4  _S838 = *(&(globalParams_0->state_0)[_S834 + 3U]);
    float3  wb_0 = float3 {_S838.x, _S838.y, _S838.z};
    float3  _S839 = to_local_0(i_14, float3 {_S835.x, _S835.y, _S835.z} + cross_0(tb_2, rb_1) - (float3 {_S830.x, _S830.y, _S830.z} + cross_0(ta_2, ra_1)));
    float3  _S840 = to_local_0(i_14, tb_2 - ta_2);
    float3  _S841 = to_local_0(i_14, vb_0 + cross_0(wb_0, rb_1) - (va_0 + cross_0(wa_1, ra_1)));
    float3  _S842 = to_local_0(i_14, wb_0 - wa_1);
    JointBond_0 _S843 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_14])->law_0);
    JointState_0 previous_0 = (&(globalParams_0->bond_dyn_0)[i_14])->js_0;
    JointState_0 _S844 = (&(globalParams_0->bond_dyn_0)[i_14])->js_0;
    bool _S845 = is_damaged_0(&_S844);
    JointBond_0 _S846 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_14])->law_0);
    JointBond_0 _S847 = _S846;
    JointState_0 _S848 = (&(globalParams_0->bond_dyn_0)[i_14])->js_0;
    JointResponse_0 _S849 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S843.ids_0.x], &_S847, &_S848, _S839, _S840, dt_6, fracture_2);
    BondStatic_0 * _S850 = (&(globalParams_0->bonds_0)[i_14]);
    BondDyn_0 bd_0 = *(&(globalParams_0->bond_dyn_0)[i_14]);
    float4  _S851 = __ldg(&_S850->ra_0);
    float3  ra_2 = float3 {_S851.x, _S851.y, _S851.z};
    float4  _S852 = __ldg(&_S850->rb_0);
    float3  rb_2 = float3 {_S852.x, _S852.y, _S852.z};
    JointBond_0 _S853 = slang_ldg_0(&_S850->law_0);
    JointBond_0 _S854 = _S853;
    JointState_0 _S855 = _S849.state_1;
    float3  f_lin_1;
    float3  f_ang_1;
    secant_factors_0(&_S854, &_S855, _S839, &f_lin_1, &f_ang_1);
    float4  _S856 = __ldg(&_S850->c_lin_0);
    float3  qd_lin_0 = _S841 * float3 {_S856.x, _S856.y, _S856.z} * f_lin_1;
    float4  _S857 = __ldg(&_S850->c_ang_0);
    float3  qd_ang_0 = _S842 * float3 {_S857.x, _S857.y, _S857.z} * f_ang_1;
    float3  q_lin_2 = _S849.force_lin_1 + qd_lin_0;
    float3  q_ang_2 = _S849.force_ang_1 + qd_ang_0;
    float damped_0 = (dot_0(qd_lin_0, _S841) + dot_0(qd_ang_0, _S842)) * dt_6;
    float3  _S858 = to_body_0(i_14, q_lin_2);
    float3  _S859 = to_body_0(i_14, q_ang_2);
    uint _S860 = 3U * i_14;
    *(&(globalParams_0->scratch_0)[_S860]) = make_float4 (_S858.x, _S858.y, _S858.z, (F32_max((_S849.measures_0.tension_0), (_S849.measures_0.compression_0))));
    *(&(globalParams_0->scratch_0)[_S860 + 1U]) = make_float4 ((_S859 + cross_0(ra_2, _S858)).x, (_S859 + cross_0(ra_2, _S858)).y, (_S859 + cross_0(ra_2, _S858)).z, 0.0f);
    *(&(globalParams_0->scratch_0)[_S860 + 2U]) = make_float4 ((- _S859 + cross_0(rb_2, - _S858)).x, (- _S859 + cross_0(rb_2, - _S858)).y, (- _S859 + cross_0(rb_2, - _S858)).z, 0.0f);
    comp_add1_0(&((&(&bd_0)->sums_0)->x), &((&(&bd_0)->comps_0)->x), _S849.dissipated_2);
    comp_add1_0(&((&(&bd_0)->sums_0)->y), &((&(&bd_0)->comps_0)->y), _S849.overshoot_0);
    comp_add1_0(&((&(&bd_0)->sums_0)->z), &((&(&bd_0)->comps_0)->z), damped_0);
    (&bd_0)->force_lin_0 = make_float4 (q_lin_2.x, q_lin_2.y, q_lin_2.z, _S849.stored_3);
    (&bd_0)->force_ang_0 = make_float4 (q_ang_2.x, q_ang_2.y, q_ang_2.z, (F32_max(((&bd_0)->force_ang_0.w), (_S849.state_1.utilization_0))));
    bool _S861;
    if(!_S845)
    {
        JointState_0 _S862 = _S849.state_1;
        bool _S863 = is_damaged_0(&_S862);
        _S861 = _S863;
    }
    else
    {
        _S861 = false;
    }
    if(_S861)
    {
        _S861 = ((&bd_0)->events_0.x) == 0U;
    }
    else
    {
        _S861 = false;
    }
    if(_S861)
    {
        *&((&(&bd_0)->events_0)->x) = abs_step_0;
        *&((&(&bd_0)->events_0)->w) = _S849.state_1.mode_0;
        if(wide_0)
        {
            cov_or_0(_S853.ids_0.w, 32U);
        }
        else
        {
            (*&g_seen_0)[3U] = 1U;
        }
    }
    if(((&bd_0)->events_0.y) == 0U)
    {
        _S861 = (_S849.state_1.life_0) != (previous_0.life_0);
    }
    else
    {
        _S861 = false;
    }
    if(_S861)
    {
        _S861 = (_S849.fatigue_before_0) > 0.99000000953674316f;
    }
    else
    {
        _S861 = false;
    }
    if(_S861)
    {
        float _S864 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S843.ids_0.x], _S849.state_1.life_0);
        _S861 = _S864 <= 0.99000000953674316f;
    }
    else
    {
        _S861 = false;
    }
    if(_S861)
    {
        *&((&(&bd_0)->events_0)->y) = abs_step_0;
        if(wide_0)
        {
            cov_or_0(_S853.ids_0.w, 64U);
        }
        else
        {
            (*&g_seen_0)[4U] = 1U;
        }
    }
    if(_S849.disconnected_0)
    {
        *&((&(&bd_0)->events_0)->z) = abs_step_0;
    }
    (&bd_0)->js_0 = _S849.state_1;
    *(&(globalParams_0->bond_dyn_0)[i_14]) = bd_0;
    return _S849.disconnected_0;
}

struct Rigid_0
{
    Quat_0 rot_1;
    float4  rot_err_0;
    float3  pos_0;
    float3  pos_err_0;
    float3  vel_0;
    float3  vel_err_0;
    float3  w_5;
    float3  l_1;
    float3  l_err_0;
    float3  torque_0;
    float3  a_13;
    float3  alpha_0;
};

static __device__ Rigid_0 rigid_of_0(Island_0 * isl_5)
{
    Rigid_0 rg_0;
    (&rg_0)->rot_1 = quat_of_0(isl_5->rotation_0);
    (&rg_0)->rot_err_0 = isl_5->rotation_err_0;
    float4  _S865 = isl_5->position_0;
    (&rg_0)->pos_0 = float3 {_S865.x, _S865.y, _S865.z};
    float4  _S866 = isl_5->position_err_0;
    (&rg_0)->pos_err_0 = float3 {_S866.x, _S866.y, _S866.z};
    float4  _S867 = isl_5->velocity_0;
    (&rg_0)->vel_0 = float3 {_S867.x, _S867.y, _S867.z};
    float4  _S868 = isl_5->velocity_err_0;
    (&rg_0)->vel_err_0 = float3 {_S868.x, _S868.y, _S868.z};
    float4  _S869 = isl_5->angular_velocity_0;
    (&rg_0)->w_5 = float3 {_S869.x, _S869.y, _S869.z};
    float4  _S870 = isl_5->momentum_0;
    (&rg_0)->l_1 = float3 {_S870.x, _S870.y, _S870.z};
    float4  _S871 = isl_5->momentum_err_0;
    (&rg_0)->l_err_0 = float3 {_S871.x, _S871.y, _S871.z};
    float3  _S872 = make_float3 (0.0f);
    (&rg_0)->torque_0 = _S872;
    (&rg_0)->a_13 = _S872;
    (&rg_0)->alpha_0 = _S872;
    return rg_0;
}

static __device__ void net_load_0(uint c_9, Island_0 * isl_6, Rigid_0 * rg_1, uint k_13, float dt_7, bool contact_2, float3  * f_8, float3  * t_5)
{
    ChunkStatic_0 * _S873 = (&(globalParams_0->chunks_0)[c_9]);
    float3  fl_0;
    float3  tl_0;
    float3  rep_f_0;
    float3  rep_m_0;
    chunk_loads_0(c_9, c_9, &rg_1->rot_1, k_13, dt_7, contact_2, 0.0f, &fl_0, &tl_0, &rep_f_0, &rep_m_0);
    float3  _S874 = fl_0;
    float4  _S875 = __ldg(&globalParams_0->params_0->gravity_0);
    float3  _S876 = float3 {_S875.x, _S875.y, _S875.z};
    float4  _S877 = __ldg(&_S873->center_0);
    float3  fc_2 = _S874 + _S876 * make_float3 (_S877.w);
    float3  _S878 = float3 {_S877.x, _S877.y, _S877.z};
    float4  _S879 = *(&(globalParams_0->state_0)[4U * c_9]);
    float4  _S880 = isl_6->com_0;
    float3  _S881 = float3 {_S880.x, _S880.y, _S880.z};
    float3  _S882 = rotate_0(&rg_1->rot_1, _S878 + float3 {_S879.x, _S879.y, _S879.z} - _S881);
    *f_8 = *f_8 + fc_2;
    *t_5 = *t_5 + (cross_0(_S882, fc_2) + tl_0);
    uint4  _S883 = __ldg(&_S873->load_range_0);
    if((_S883.y) > (_S883.x))
    {
        float3  _S884 = rotate_0(&rg_1->rot_1, rep_f_0);
        *f_8 = *f_8 + _S884;
        float3  _S885 = rotate_0(&rg_1->rot_1, _S878 - _S881);
        float3  _S886 = cross_0(_S885, _S884);
        float3  _S887 = rotate_0(&rg_1->rot_1, rep_m_0);
        *t_5 = *t_5 + (_S886 + _S887);
    }
    return;
}

static __device__ void wide_store_0(uint slot_0, uint p_11, float3  a_14, float3  b_29)
{
    uint _S888 = __ldg(&globalParams_0->params_0->wide_base_0);
    uint _S889 = 8U * slot_0;
    *(&(globalParams_0->scratch_0)[_S888 + _S889 + p_11]) = make_float4 (a_14.x, a_14.y, a_14.z, 0.0f);
    uint _S890 = __ldg(&globalParams_0->params_0->wide_base_0);
    *(&(globalParams_0->scratch_0)[_S890 + _S889 + p_11 + 1U]) = make_float4 (b_29.x, b_29.y, b_29.z, 0.0f);
    return;
}

extern "C" __global__ void wide_bonds()
{
    uint _S891 = __ballot_sync(4294967295U, true);
    uint tid_6 = threadIdx.x;
    uint _S892 = blockIdx.x;
    uint _S893 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
    bool bond_group_0 = _S892 < _S893;
    uint _S894 = __ballot_sync(_S891, bond_group_0);
    WideGroup_0 wg_1;
    uint _S895;
    if(bond_group_0)
    {
        uint _S896 = __ldg(&globalParams_0->params_0->wide_bond_table_0);
        WideGroup_0 _S897 = wide_group_0(_S896, _S892);
        uint _S898 = __ballot_sync(_S891, true);
        wg_1 = _S897;
        _S895 = _S898;
    }
    else
    {
        uint _S899 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
        uint _S900 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
        WideGroup_0 _S901 = wide_group_0(_S899, _S892 - _S900);
        uint _S902 = __ballot_sync(_S891, true);
        wg_1 = _S901;
        _S895 = _S902;
    }
    uint _S903 = 0U;
    WideGroup_0 _S904 = wg_1;
    Island_0 isl_7 = *(&(globalParams_0->islands_0)[wg_1.island_2]);
    bool _S905 = wide_enter_1(tid_6, wg_1.island_2);
    bool _S906 = !_S905;
    uint _S907 = __ballot_sync(_S895, _S906);
    if(_S906)
    {
        return;
    }
    else
    {
        uint _S908 = __ballot_sync(_S895, true);
        _S903 = _S908;
    }
    uint _S909 = 0U;
    Island_0 _S910 = isl_7;
    uint _S911 = wide_step_0(&_S910);
    uint _S912 = __ballot_sync(_S903, bond_group_0);
    if(bond_group_0)
    {
        if(((isl_7.info_1.x) & 16U) != 0U)
        {
            return;
        }
        uint i_15 = wg_1.begin_0 + tid_6;
        bool _S913;
        if(i_15 < (wg_1.end_0))
        {
            float _S914 = __ldg(&globalParams_0->params_0->dt_0);
            uint _S915 = __ldg(&globalParams_0->params_0->fracture_0);
            bool _S916 = bond_update_0(i_15, _S914, _S915 != 0U, isl_7.info_1.w + 1U, true);
            _S913 = _S916;
        }
        else
        {
            _S913 = false;
        }
        if(_S913)
        {
            *&((&(&(globalParams_0->islands_0)[_S904.island_2])->info_1)->z) = (isl_7.info_1.z) | 2U;
        }
        return;
    }
    else
    {
        uint _S917 = __ballot_sync(_S903, true);
        _S909 = _S917;
    }
    uint _S918 = 0U;
    uint _S919 = isl_7.info_1.x;
    bool _S920 = (_S919 & 1U) != 0U;
    uint _S921 = __ballot_sync(_S909, _S920);
    if(_S920)
    {
        return;
    }
    else
    {
        uint _S922 = __ballot_sync(_S909, true);
        _S918 = _S922;
    }
    float3  _S923 = make_float3 (0.0f);
    float3  f_9 = _S923;
    float3  t_6 = _S923;
    uint c_10 = wg_1.begin_0 + tid_6;
    bool _S924 = c_10 < (wg_1.end_0);
    uint _S925 = __ballot_sync(_S918, _S924);
    if(_S924)
    {
        Island_0 _S926 = isl_7;
        Rigid_0 _S927 = rigid_of_0(&_S926);
        float _S928 = __ldg(&globalParams_0->params_0->dt_0);
        bool _S929 = (_S919 & 4U) != 0U;
        Island_0 _S930 = isl_7;
        Rigid_0 _S931 = _S927;
        net_load_0(c_10, &_S930, &_S931, _S911, _S928, _S929, &f_9, &t_6);
        uint _S932 = __ballot_sync(_S918, true);
        _S895 = _S932;
    }
    else
    {
        uint _S933 = __ballot_sync(_S918, true);
        _S895 = _S933;
    }
    group_sum3_0(tid_6, &f_9, &t_6, _S895);
    bool _S934 = tid_6 == 0U;
    uint _S935 = __ballot_sync(_S895, _S934);
    if(_S934)
    {
        uint _S936 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
        wide_store_0(_S892 - _S936, 0U, f_9, t_6);
    }
    return;
}

static __device__ void wide_partials_0(uint tid_7, uint first_1, uint count_5, uint p_12, float3  * a_15, float3  * b_30, uint _S937)
{
    uint _S938;
    float4  _S939 = make_float4 (0.0f);
    float4  x_21 = _S939;
    float4  y_5 = _S939;
    uint s_3 = tid_7;
    uint _S940 = _S937;
    for(;;)
    {
        bool _S941 = s_3 < count_5;
        uint _S942 = __ballot_sync(_S940, _S941);
        if(_S941)
        {
            uint _S943 = __ballot_sync(_S940, true);
        }
        else
        {
            uint _S944 = __ballot_sync(_S940, false);
            uint _S945 = __ballot_sync(_S940, false);
            uint _S946 = __ballot_sync(_S937, true);
            _S938 = _S946;
            break;
        }
        uint _S947 = __ldg(&globalParams_0->params_0->wide_base_0);
        uint _S948 = 8U * (first_1 + s_3);
        x_21 = x_21 + *(&(globalParams_0->scratch_0)[_S947 + _S948 + p_12]);
        uint _S949 = __ldg(&globalParams_0->params_0->wide_base_0);
        y_5 = y_5 + *(&(globalParams_0->scratch_0)[_S949 + _S948 + p_12 + 1U]);
        uint _S950 = __ballot_sync(_S940, true);
        s_3 = s_3 + 256U;
        _S940 = _S950;
    }
    group_sum2_0(tid_7, &x_21, &y_5, _S938);
    float4  _S951 = x_21;
    *a_15 = float3 {_S951.x, _S951.y, _S951.z};
    float4  _S952 = y_5;
    *b_30 = float3 {_S952.x, _S952.y, _S952.z};
    return;
}

static __device__ float3  rows_mul_0(float4  r0_0, float4  r1_0, float4  r2_0, float3  v_4)
{
    return make_float3 (dot_0(float3 {r0_0.x, r0_0.y, r0_0.z}, v_4), dot_0(float3 {r1_0.x, r1_0.y, r1_0.z}, v_4), dot_0(float3 {r2_0.x, r2_0.y, r2_0.z}, v_4));
}

static __device__ void drift_angular_0(uint c_11, float3  wcom_1, float3  tr_0, float3  dv_0, float3  * lu_0, float3  * lv_0)
{
    ChunkStatic_0 * _S953 = (&(globalParams_0->chunks_0)[c_11]);
    float4  _S954 = __ldg(&_S953->center_0);
    float3  r_9 = float3 {_S954.x, _S954.y, _S954.z} - wcom_1;
    float4  _S955 = __ldg(&_S953->scale_0);
    float kw_0 = _S955.x;
    uint _S956 = 4U * c_11;
    float4  _S957 = *(&(globalParams_0->state_0)[_S956]);
    float _S958 = _S954.w;
    float3  _S959 = cross_0(r_9, float3 {_S957.x, _S957.y, _S957.z} - tr_0) * make_float3 (_S958);
    float4  _S960 = __ldg(&_S953->inertia0_0);
    float4  _S961 = __ldg(&_S953->inertia1_0);
    float4  _S962 = __ldg(&_S953->inertia2_0);
    float4  _S963 = *(&(globalParams_0->state_0)[_S956 + 1U]);
    *lu_0 = *lu_0 + (_S959 + rows_mul_0(_S960, _S961, _S962, float3 {_S963.x, _S963.y, _S963.z})) * make_float3 (kw_0);
    float4  _S964 = *(&(globalParams_0->state_0)[_S956 + 2U]);
    float4  _S965 = *(&(globalParams_0->state_0)[_S956 + 3U]);
    *lv_0 = *lv_0 + (cross_0(r_9, float3 {_S964.x, _S964.y, _S964.z} - dv_0) * make_float3 (_S958) + rows_mul_0(_S960, _S961, _S962, float3 {_S965.x, _S965.y, _S965.z})) * make_float3 (kw_0);
    return;
}

extern "C" __global__ void wide_drift()
{
    uint _S966 = __ballot_sync(4294967295U, true);
    uint tid_8 = threadIdx.x;
    uint _S967 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S968 = blockIdx.x;
    WideGroup_0 wg_2 = wide_group_0(_S967, _S968);
    Island_0 * _S969 = (&(globalParams_0->islands_0)[wg_2.island_2]);
    Island_0 isl_8 = *_S969;
    bool _S970 = (((*_S969).info_1.x) & 17U) != 0U;
    uint _S971 = __ballot_sync(_S966, _S970);
    bool _S972;
    uint _S973;
    if(_S970)
    {
        uint _S974 = __ballot_sync(_S966, true);
        _S972 = true;
        _S973 = _S974;
    }
    else
    {
        bool _S975 = wide_enter_1(tid_8, wg_2.island_2);
        bool _S976 = !_S975;
        uint _S977 = __ballot_sync(_S966, true);
        _S972 = _S976;
        _S973 = _S977;
    }
    uint _S978 = 0U;
    uint _S979 = __ballot_sync(_S973, _S972);
    if(_S972)
    {
        return;
    }
    else
    {
        uint _S980 = __ballot_sync(_S973, true);
        _S978 = _S980;
    }
    float3  tu_0;
    float3  pv_0;
    wide_partials_0(tid_8, wg_2.first_0, isl_8.wide_groups_0, 2U, &tu_0, &pv_0, _S978);
    float _S981 = isl_8.wcom_0.w;
    float3  tr_1 = tu_0 / make_float3 (_S981);
    float3  dv_1 = pv_0 / make_float3 (_S981);
    float3  _S982 = make_float3 (0.0f);
    float3  lu_1 = _S982;
    float3  lv_1 = _S982;
    uint c_12 = wg_2.begin_0 + tid_8;
    bool _S983 = c_12 < (wg_2.end_0);
    uint _S984 = __ballot_sync(_S978, _S983);
    if(_S983)
    {
        float4  _S985 = isl_8.wcom_0;
        drift_angular_0(c_12, float3 {_S985.x, _S985.y, _S985.z}, tr_1, dv_1, &lu_1, &lv_1);
        uint _S986 = __ballot_sync(_S978, true);
        _S973 = _S986;
    }
    else
    {
        uint _S987 = __ballot_sync(_S978, true);
        _S973 = _S987;
    }
    group_sum3_0(tid_8, &lu_1, &lv_1, _S973);
    bool _S988 = tid_8 == 0U;
    uint _S989 = __ballot_sync(_S973, _S988);
    if(_S988)
    {
        wide_store_0(_S968, 4U, lu_1, lv_1);
    }
    return;
}

static __device__ float3  inverse_rotate_0(Quat_0 * q_9, float3  v_5)
{
    Quat_0 c_13;
    (&c_13)->w_1 = q_9->w_1;
    (&c_13)->x_12 = - q_9->x_12;
    (&c_13)->y_4 = - q_9->y_4;
    (&c_13)->z_0 = - q_9->z_0;
    Quat_0 _S990 = c_13;
    float3  _S991 = rotate_0(&_S990, v_5);
    return _S991;
}

static __device__ float3  world_mul_0(Quat_0 * q_10, float4  r0_1, float4  r1_1, float4  r2_1, float3  v_6)
{
    float3  _S992 = inverse_rotate_0(q_10, v_6);
    float3  _S993 = rotate_0(q_10, rows_mul_0(r0_1, r1_1, r2_1, _S992));
    return _S993;
}

static __device__ void rigid_acceleration_0(Island_0 * isl_9, Rigid_0 * rg_2, float3  f_10, float3  t_7)
{
    Quat_0 _S994 = rg_2->rot_1;
    float3  _S995 = world_mul_0(&_S994, isl_9->inertia0_1, isl_9->inertia1_1, isl_9->inertia2_1, rg_2->w_5);
    rg_2->a_13 = f_10 / make_float3 (isl_9->com_0.w);
    float3  _S996 = t_7 - cross_0(rg_2->w_5, _S995);
    Quat_0 _S997 = rg_2->rot_1;
    float3  _S998 = world_mul_0(&_S997, isl_9->inv0_1, isl_9->inv1_1, isl_9->inv2_1, _S996);
    rg_2->alpha_0 = _S998;
    rg_2->torque_0 = t_7;
    return;
}

static __device__ Rigid_0 wide_rigid_frame_0(uint tid_9, Island_0 * isl_10, WideGroup_0 * wg_3, uint _S999)
{
    Rigid_0 _S1000 = rigid_of_0(isl_10);
    Rigid_0 rg_3 = _S1000;
    bool _S1001 = ((isl_10->info_1.x) & 1U) == 0U;
    uint _S1002 = __ballot_sync(_S999, _S1001);
    if(_S1001)
    {
        float3  f_11;
        float3  t_8;
        wide_partials_0(tid_9, wg_3->first_0, isl_10->wide_groups_0, 0U, &f_11, &t_8, _S1002);
        rigid_acceleration_0(isl_10, &rg_3, f_11, t_8);
        uint _S1003 = __ballot_sync(_S999, true);
    }
    return rg_3;
}

static __device__ void comp_add_0(float3  * sum_1, float3  * err_1, float3  x_22)
{
    float3  t_9 = *sum_1 + x_22;
    float3  _S1004 = abs_1(x_22);
    *err_1 = *err_1 + (_slang_select((abs_1(*sum_1)) >= _S1004, *sum_1,x_22) - t_9 + _slang_select((abs_1(*sum_1)) >= _S1004, x_22,*sum_1));
    *sum_1 = t_9;
    return;
}

static __device__ float3  turn_difference_0(float3  omega_0, float dt_8, float3  v_7)
{
    float _S1005 = length_0(omega_0);
    float angle_1 = _S1005 * dt_8;
    if(angle_1 < 1.00000000317107685e-30f)
    {
        return make_float3 (0.0f);
    }
    float3  a_16 = omega_0 / make_float3 (_S1005);
    float s_4 = (F32_sin((0.5f * angle_1)));
    float3  av_0 = cross_0(a_16, v_7);
    return av_0 * make_float3 ((F32_sin((angle_1)))) + cross_0(a_16, av_0) * make_float3 (2.0f * s_4 * s_4);
}

static __device__ float4  turn_minus_one_0(float3  axis_3, float angle_2)
{
    float s_5 = (F32_sin((0.25f * angle_2)));
    return make_float4 ((axis_3 * make_float3 ((F32_sin((0.5f * angle_2))))).x, (axis_3 * make_float3 ((F32_sin((0.5f * angle_2))))).y, (axis_3 * make_float3 ((F32_sin((0.5f * angle_2))))).z, -2.0f * s_5 * s_5);
}

static __device__ float4  quat_vec_0(Quat_0 * q_11)
{
    return make_float4 (q_11->x_12, q_11->y_4, q_11->z_0, q_11->w_1);
}

static __device__ void comp_add4_0(float4  * sum_2, float4  * err_2, float4  x_23)
{
    float4  t_10 = *sum_2 + x_23;
    float4  _S1006 = abs_0(x_23);
    *err_2 = *err_2 + (_slang_select((abs_0(*sum_2)) >= _S1006, *sum_2,x_23) - t_10 + _slang_select((abs_0(*sum_2)) >= _S1006, x_23,*sum_2));
    *sum_2 = t_10;
    return;
}

static __device__ void quat_accumulate_0(Quat_0 * hi_1, float4  * lo_1, float4  x_24)
{
    Quat_0 _S1007 = *hi_1;
    float4  _S1008 = quat_vec_0(&_S1007);
    float4  sum_3 = _S1008;
    comp_add4_0(&sum_3, lo_1, x_24);
    float4  t_11 = sum_3 + *lo_1;
    *lo_1 = *lo_1 - (t_11 - sum_3);
    *hi_1 = quat_of_0(t_11);
    return;
}

static __device__ void turn_left_0(Quat_0 * hi_2, float4  * lo_2, float3  omega_1, float dt_9)
{
    float _S1009 = length_0(omega_1);
    float angle_3 = _S1009 * dt_9;
    if(angle_3 < 1.00000000317107685e-30f)
    {
        return;
    }
    float4  d_10 = turn_minus_one_0(omega_1 / make_float3 (_S1009), angle_3);
    Quat_0 dq_0;
    (&dq_0)->x_12 = d_10.x;
    (&dq_0)->y_4 = d_10.y;
    (&dq_0)->z_0 = d_10.z;
    (&dq_0)->w_1 = d_10.w;
    Quat_0 _S1010 = dq_0;
    Quat_0 _S1011 = *hi_2;
    Quat_0 _S1012 = quat_mul_0(&_S1010, &_S1011);
    Quat_0 _S1013 = _S1012;
    float4  _S1014 = quat_vec_0(&_S1013);
    quat_accumulate_0(hi_2, lo_2, _S1014);
    return;
}

static __device__ void integrate_rigid_0(Island_0 * isl_11, Rigid_0 * rg_4, float dt_10)
{
    comp_add_0(&rg_4->l_1, &rg_4->l_err_0, rg_4->torque_0 * make_float3 (dt_10));
    float3  l_2 = rg_4->l_1 + rg_4->l_err_0;
    comp_add_0(&rg_4->vel_0, &rg_4->vel_err_0, rg_4->a_13 * make_float3 (dt_10));
    float3  vel_1 = rg_4->vel_0 + rg_4->vel_err_0;
    float4  _S1015 = isl_11->inv0_1;
    float4  _S1016 = isl_11->inv1_1;
    float4  _S1017 = isl_11->inv2_1;
    Quat_0 _S1018 = rg_4->rot_1;
    float3  _S1019 = world_mul_0(&_S1018, isl_11->inv0_1, isl_11->inv1_1, isl_11->inv2_1, l_2);
    float3  _S1020 = vel_1 * make_float3 (dt_10);
    float4  _S1021 = isl_11->com_0;
    float3  _S1022 = float3 {_S1021.x, _S1021.y, _S1021.z};
    Quat_0 _S1023 = rg_4->rot_1;
    float3  _S1024 = rotate_0(&_S1023, _S1022);
    comp_add_0(&rg_4->pos_0, &rg_4->pos_err_0, _S1020 - turn_difference_0(_S1019, dt_10, _S1024));
    turn_left_0(&rg_4->rot_1, &rg_4->rot_err_0, _S1019, dt_10);
    Quat_0 _S1025 = rg_4->rot_1;
    float3  _S1026 = world_mul_0(&_S1025, _S1015, _S1016, _S1017, l_2);
    rg_4->w_5 = _S1026;
    return;
}

static __device__ void drift_apply_0(uint c_14, float3  wcom_2, float3  tr_2, float3  phi_0, float3  dv_2, float3  dw_0)
{
    float4  _S1027 = __ldg(&(&(globalParams_0->chunks_0)[c_14])->center_0);
    float3  r_10 = float3 {_S1027.x, _S1027.y, _S1027.z} - wcom_2;
    uint _S1028 = 4U * c_14;
    float4  _S1029 = *(&(globalParams_0->state_0)[_S1028]);
    *(&(globalParams_0->state_0)[_S1028]) = make_float4 ((float3 {_S1029.x, _S1029.y, _S1029.z} - (tr_2 + cross_0(phi_0, r_10))).x, (float3 {_S1029.x, _S1029.y, _S1029.z} - (tr_2 + cross_0(phi_0, r_10))).y, (float3 {_S1029.x, _S1029.y, _S1029.z} - (tr_2 + cross_0(phi_0, r_10))).z, (*(&(globalParams_0->state_0)[_S1028])).w);
    uint _S1030 = _S1028 + 1U;
    float4  _S1031 = *(&(globalParams_0->state_0)[_S1030]);
    *(&(globalParams_0->state_0)[_S1030]) = make_float4 ((float3 {_S1031.x, _S1031.y, _S1031.z} - phi_0).x, (float3 {_S1031.x, _S1031.y, _S1031.z} - phi_0).y, (float3 {_S1031.x, _S1031.y, _S1031.z} - phi_0).z, (*(&(globalParams_0->state_0)[_S1030])).w);
    uint _S1032 = _S1028 + 2U;
    float4  _S1033 = *(&(globalParams_0->state_0)[_S1032]);
    *(&(globalParams_0->state_0)[_S1032]) = make_float4 ((float3 {_S1033.x, _S1033.y, _S1033.z} - (dv_2 + cross_0(dw_0, r_10))).x, (float3 {_S1033.x, _S1033.y, _S1033.z} - (dv_2 + cross_0(dw_0, r_10))).y, (float3 {_S1033.x, _S1033.y, _S1033.z} - (dv_2 + cross_0(dw_0, r_10))).z, (*(&(globalParams_0->state_0)[_S1032])).w);
    uint _S1034 = _S1028 + 3U;
    float4  _S1035 = *(&(globalParams_0->state_0)[_S1034]);
    *(&(globalParams_0->state_0)[_S1034]) = make_float4 ((float3 {_S1035.x, _S1035.y, _S1035.z} - dw_0).x, (float3 {_S1035.x, _S1035.y, _S1035.z} - dw_0).y, (float3 {_S1035.x, _S1035.y, _S1035.z} - dw_0).z, (*(&(globalParams_0->state_0)[_S1034])).w);
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
    Quat_0 _S1036 = *hi_3;
    Quat_0 _S1037 = dq_1;
    Quat_0 _S1038 = quat_mul_0(&_S1036, &_S1037);
    Quat_0 _S1039 = _S1038;
    float4  _S1040 = quat_vec_0(&_S1039);
    quat_accumulate_0(hi_3, lo_3, _S1040);
    return;
}

static __device__ void drift_rigid_0(Island_0 * isl_12, Rigid_0 * rg_5, float3  tr_3, float3  phi_2, float3  dv_3, float3  dw_1)
{
    float4  _S1041 = isl_12->wcom_0;
    float3  wcom_3 = float3 {_S1041.x, _S1041.y, _S1041.z};
    Quat_0 rot_2 = rg_5->rot_1;
    float3  _S1042 = tr_3 - cross_0(phi_2, wcom_3);
    Quat_0 _S1043 = rg_5->rot_1;
    float3  _S1044 = rotate_0(&_S1043, _S1042);
    comp_add_0(&rg_5->pos_0, &rg_5->pos_err_0, _S1044);
    Quat_0 _S1045 = rg_5->rot_1;
    float3  _S1046 = inverse_rotate_0(&_S1045, rg_5->w_5);
    float4  _S1047 = isl_12->inertia0_1;
    float4  _S1048 = isl_12->inertia1_1;
    float4  _S1049 = isl_12->inertia2_1;
    float3  _S1050 = cross_0(phi_2, rows_mul_0(isl_12->inertia0_1, isl_12->inertia1_1, isl_12->inertia2_1, _S1046)) - rows_mul_0(isl_12->inertia0_1, isl_12->inertia1_1, isl_12->inertia2_1, cross_0(phi_2, _S1046));
    Quat_0 _S1051 = rg_5->rot_1;
    float3  _S1052 = rotate_0(&_S1051, _S1050);
    turn_right_0(&rg_5->rot_1, &rg_5->rot_err_0, phi_2);
    float4  _S1053 = isl_12->com_0;
    float3  _S1054 = dv_3 + cross_0(dw_1, float3 {_S1053.x, _S1053.y, _S1053.z} - wcom_3);
    Quat_0 _S1055 = rot_2;
    float3  _S1056 = rotate_0(&_S1055, _S1054);
    comp_add_0(&rg_5->vel_0, &rg_5->vel_err_0, _S1056);
    Quat_0 _S1057 = rot_2;
    float3  _S1058 = rotate_0(&_S1057, dw_1);
    rg_5->w_5 = rg_5->w_5 + _S1058;
    Quat_0 _S1059 = rg_5->rot_1;
    float3  _S1060 = world_mul_0(&_S1059, _S1047, _S1048, _S1049, _S1058);
    comp_add_0(&rg_5->l_1, &rg_5->l_err_0, _S1052 + _S1060);
    return;
}

extern "C" __global__ void wide_rigid()
{
    uint _S1061 = __ballot_sync(4294967295U, true);
    uint tid_10 = threadIdx.x;
    uint _S1062 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1063 = blockIdx.x;
    WideGroup_0 wg_4 = wide_group_0(_S1062, _S1063);
    Island_0 * _S1064 = (&(globalParams_0->islands_0)[wg_4.island_2]);
    Island_0 isl_13 = *_S1064;
    uint _S1065 = (*_S1064).info_1.x;
    bool _S1066 = (_S1065 & 1U) != 0U;
    uint _S1067 = __ballot_sync(_S1061, _S1066);
    bool _S1068;
    uint _S1069;
    if(_S1066)
    {
        uint _S1070 = __ballot_sync(_S1061, true);
        _S1068 = true;
        _S1069 = _S1070;
    }
    else
    {
        bool _S1071 = wide_enter_1(tid_10, wg_4.island_2);
        bool _S1072 = !_S1071;
        uint _S1073 = __ballot_sync(_S1061, true);
        _S1068 = _S1072;
        _S1069 = _S1073;
    }
    uint _S1074 = 0U;
    uint _S1075 = __ballot_sync(_S1069, _S1068);
    if(_S1068)
    {
        return;
    }
    else
    {
        uint _S1076 = __ballot_sync(_S1069, true);
        _S1074 = _S1076;
    }
    uint _S1077 = 0U;
    bool _S1078 = (_S1065 & 16U) != 0U;
    uint _S1079 = __ballot_sync(_S1074, _S1078);
    if(_S1078)
    {
        uint _S1080 = 0U;
        bool _S1081 = _S1063 != (wg_4.first_0);
        uint _S1082 = __ballot_sync(_S1079, _S1081);
        if(_S1081)
        {
            return;
        }
        else
        {
            uint _S1083 = __ballot_sync(_S1079, true);
            _S1080 = _S1083;
        }
        Island_0 _S1084 = isl_13;
        WideGroup_0 _S1085 = wg_4;
        Rigid_0 _S1086 = wide_rigid_frame_0(tid_10, &_S1084, &_S1085, _S1080);
        Rigid_0 rs_0 = _S1086;
        bool _S1087 = tid_10 != 0U;
        uint _S1088 = __ballot_sync(_S1080, _S1087);
        if(_S1087)
        {
            _S1068 = true;
        }
        else
        {
            _S1068 = (_S1065 & 2U) != 0U;
        }
        if(_S1068)
        {
            return;
        }
        float _S1089 = __ldg(&globalParams_0->params_0->dt_0);
        Island_0 _S1090 = isl_13;
        integrate_rigid_0(&_S1090, &rs_0, _S1089);
        Quat_0 _S1091 = (&rs_0)->rot_1;
        float4  _S1092 = quat_vec_0(&_S1091);
        (&(globalParams_0->islands_0)[wg_4.island_2])->rotation_0 = _S1092;
        (&(globalParams_0->islands_0)[wg_4.island_2])->rotation_err_0 = (&rs_0)->rot_err_0;
        (&(globalParams_0->islands_0)[wg_4.island_2])->position_0 = make_float4 ((&rs_0)->pos_0.x, (&rs_0)->pos_0.y, (&rs_0)->pos_0.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_4.island_2])->position_err_0 = make_float4 ((&rs_0)->pos_err_0.x, (&rs_0)->pos_err_0.y, (&rs_0)->pos_err_0.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_4.island_2])->velocity_0 = make_float4 ((&rs_0)->vel_0.x, (&rs_0)->vel_0.y, (&rs_0)->vel_0.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_4.island_2])->velocity_err_0 = make_float4 ((&rs_0)->vel_err_0.x, (&rs_0)->vel_err_0.y, (&rs_0)->vel_err_0.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_4.island_2])->angular_velocity_0 = make_float4 ((&rs_0)->w_5.x, (&rs_0)->w_5.y, (&rs_0)->w_5.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_4.island_2])->momentum_0 = make_float4 ((&rs_0)->l_1.x, (&rs_0)->l_1.y, (&rs_0)->l_1.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_4.island_2])->momentum_err_0 = make_float4 ((&rs_0)->l_err_0.x, (&rs_0)->l_err_0.y, (&rs_0)->l_err_0.z, 0.0f);
        return;
    }
    else
    {
        uint _S1093 = __ballot_sync(_S1074, true);
        _S1077 = _S1093;
    }
    float3  tu_1;
    float3  pv_1;
    wide_partials_0(tid_10, wg_4.first_0, isl_13.wide_groups_0, 2U, &tu_1, &pv_1, _S1077);
    float3  lu_2;
    float3  lv_2;
    wide_partials_0(tid_10, wg_4.first_0, isl_13.wide_groups_0, 4U, &lu_2, &lv_2, _S1077);
    float _S1094 = isl_13.wcom_0.w;
    float3  tr_4 = tu_1 / make_float3 (_S1094);
    float3  dv_4 = pv_1 / make_float3 (_S1094);
    float3  phi_3 = rows_mul_0(isl_13.winv0_0, isl_13.winv1_0, isl_13.winv2_0, lu_2);
    float3  dw_2 = rows_mul_0(isl_13.winv0_0, isl_13.winv1_0, isl_13.winv2_0, lv_2);
    uint c_15 = wg_4.begin_0 + tid_10;
    bool _S1095 = c_15 < (wg_4.end_0);
    uint _S1096 = __ballot_sync(_S1077, _S1095);
    if(_S1095)
    {
        float4  _S1097 = isl_13.wcom_0;
        drift_apply_0(c_15, float3 {_S1097.x, _S1097.y, _S1097.z}, tr_4, phi_3, dv_4, dw_2);
        uint _S1098 = __ballot_sync(_S1077, true);
        _S1069 = _S1098;
    }
    else
    {
        uint _S1099 = __ballot_sync(_S1077, true);
        _S1069 = _S1099;
    }
    uint _S1100 = 0U;
    bool _S1101 = _S1063 != (wg_4.first_0);
    uint _S1102 = __ballot_sync(_S1069, _S1101);
    if(_S1101)
    {
        return;
    }
    else
    {
        uint _S1103 = __ballot_sync(_S1069, true);
        _S1100 = _S1103;
    }
    Island_0 _S1104 = isl_13;
    WideGroup_0 _S1105 = wg_4;
    Rigid_0 _S1106 = wide_rigid_frame_0(tid_10, &_S1104, &_S1105, _S1100);
    Rigid_0 rg_6 = _S1106;
    bool _S1107 = tid_10 != 0U;
    uint _S1108 = __ballot_sync(_S1100, _S1107);
    if(_S1107)
    {
        return;
    }
    if(!((_S1065 & 2U) != 0U))
    {
        float _S1109 = __ldg(&globalParams_0->params_0->dt_0);
        Island_0 _S1110 = isl_13;
        integrate_rigid_0(&_S1110, &rg_6, _S1109);
        Island_0 _S1111 = isl_13;
        drift_rigid_0(&_S1111, &rg_6, tr_4, phi_3, dv_4, dw_2);
    }
    Quat_0 _S1112 = (&rg_6)->rot_1;
    float4  _S1113 = quat_vec_0(&_S1112);
    (&(globalParams_0->islands_0)[wg_4.island_2])->rotation_0 = _S1113;
    (&(globalParams_0->islands_0)[wg_4.island_2])->rotation_err_0 = (&rg_6)->rot_err_0;
    (&(globalParams_0->islands_0)[wg_4.island_2])->position_0 = make_float4 ((&rg_6)->pos_0.x, (&rg_6)->pos_0.y, (&rg_6)->pos_0.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_4.island_2])->position_err_0 = make_float4 ((&rg_6)->pos_err_0.x, (&rg_6)->pos_err_0.y, (&rg_6)->pos_err_0.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_4.island_2])->velocity_0 = make_float4 ((&rg_6)->vel_0.x, (&rg_6)->vel_0.y, (&rg_6)->vel_0.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_4.island_2])->velocity_err_0 = make_float4 ((&rg_6)->vel_err_0.x, (&rg_6)->vel_err_0.y, (&rg_6)->vel_err_0.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_4.island_2])->angular_velocity_0 = make_float4 ((&rg_6)->w_5.x, (&rg_6)->w_5.y, (&rg_6)->w_5.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_4.island_2])->momentum_0 = make_float4 ((&rg_6)->l_1.x, (&rg_6)->l_1.y, (&rg_6)->l_1.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_4.island_2])->momentum_err_0 = make_float4 ((&rg_6)->l_err_0.x, (&rg_6)->l_err_0.y, (&rg_6)->l_err_0.z, 0.0f);
    return;
}

static __device__ void write_probe_0(uint slot_1, uint k_14, float value_1)
{
    uint _S1114 = __ldg(&globalParams_0->params_0->probe_base_0);
    uint _S1115 = _S1114 * 4U;
    uint _S1116 = __ldg(&globalParams_0->params_0->probe_stride_0);
    uint at_3 = _S1115 + slot_1 * _S1116 + k_14;
    float4  v_8 = *(&(globalParams_0->scratch_0)[at_3 / 4U]);
    *_slang_vector_get_element_ptr(&v_8, at_3 % 4U) = value_1;
    *(&(globalParams_0->scratch_0)[at_3 / 4U]) = v_8;
    return;
}

static __device__ void record_probes_0(Island_0 * isl_14, Rigid_0 * rg_7, uint k_15)
{
    uint4  _S1117 = isl_14->probes_0;
    uint at_4 = isl_14->probes_0.x;
    for(;;)
    {
        if(at_4 < (_S1117.y))
        {
        }
        else
        {
            break;
        }
        float4  _S1118 = __ldg((&(globalParams_0->loads_0)[at_4]));
        uint4  info_3 = asuint_0(_S1118);
        float4  _S1119 = __ldg((&(globalParams_0->loads_0)[at_4 + 1U]));
        float4  _S1120 = __ldg((&(globalParams_0->loads_0)[at_4 + 2U]));
        float4  _S1121 = __ldg((&(globalParams_0->loads_0)[at_4 + 3U]));
        uint kind_4 = info_3.x;
        uint i_16 = info_3.y;
        float value_2;
        if(kind_4 == 0U)
        {
            float4  _S1122 = *(&(globalParams_0->state_0)[4U * i_16]);
            float3  small_0 = float3 {_S1122.x, _S1122.y, _S1122.z} + make_float3 (_S1119.w, _S1120.w, _S1121.w);
            float3  _S1123 = rg_7->pos_0 - float3 {_S1120.x, _S1120.y, _S1120.z};
            float4  _S1124 = __ldg(&(&(globalParams_0->chunks_0)[i_16])->center_0);
            float3  _S1125 = rotate_0(&rg_7->rot_1, float3 {_S1124.x, _S1124.y, _S1124.z});
            float3  _S1126 = _S1123 + _S1125;
            float3  _S1127 = rg_7->pos_err_0 - float3 {_S1121.x, _S1121.y, _S1121.z};
            float3  _S1128 = rotate_0(&rg_7->rot_1, small_0);
            value_2 = dot_0(_S1126 + (_S1127 + _S1128), float3 {_S1119.x, _S1119.y, _S1119.z});
        }
        else
        {
            if(kind_4 == 1U)
            {
                float4  _S1129 = __ldg(&(&(globalParams_0->chunks_0)[i_16])->center_0);
                uint _S1130 = 4U * i_16;
                float4  _S1131 = *(&(globalParams_0->state_0)[_S1130]);
                float4  _S1132 = isl_14->com_0;
                float3  _S1133 = rotate_0(&rg_7->rot_1, float3 {_S1129.x, _S1129.y, _S1129.z} + float3 {_S1131.x, _S1131.y, _S1131.z} - float3 {_S1132.x, _S1132.y, _S1132.z});
                float3  _S1134 = rg_7->vel_0 + rg_7->vel_err_0 + cross_0(rg_7->w_5, _S1133);
                float4  _S1135 = *(&(globalParams_0->state_0)[_S1130 + 2U]);
                float3  _S1136 = rotate_0(&rg_7->rot_1, float3 {_S1135.x, _S1135.y, _S1135.z});
                value_2 = dot_0(_S1134 + _S1136, float3 {_S1119.x, _S1119.y, _S1119.z});
            }
            else
            {
                if(kind_4 == 2U)
                {
                    uint _S1137 = 3U * i_16;
                    float4  _S1138 = *(&(globalParams_0->scratch_0)[_S1137]);
                    float3  f_12 = float3 {_S1138.x, _S1138.y, _S1138.z};
                    bool _S1139 = (info_3.z) == 0U;
                    float3  mc_0;
                    if(_S1139)
                    {
                        float4  _S1140 = *(&(globalParams_0->scratch_0)[_S1137 + 1U]);
                        mc_0 = float3 {_S1140.x, _S1140.y, _S1140.z};
                    }
                    else
                    {
                        float4  _S1141 = *(&(globalParams_0->scratch_0)[_S1137 + 2U]);
                        mc_0 = float3 {_S1141.x, _S1141.y, _S1141.z};
                    }
                    float3  fc_3;
                    if(_S1139)
                    {
                        fc_3 = f_12;
                    }
                    else
                    {
                        fc_3 = - f_12;
                    }
                    value_2 = dot_0(fc_3, float3 {_S1119.x, _S1119.y, _S1119.z}) + dot_0(mc_0, float3 {_S1120.x, _S1120.y, _S1120.z});
                }
                else
                {
                    uint _S1142 = 4U * i_16;
                    float3  _S1143 = rotate_0(&rg_7->rot_1, make_float3 ((*(&(globalParams_0->state_0)[_S1142 + 1U])).w, (*(&(globalParams_0->state_0)[_S1142 + 2U])).w, (*(&(globalParams_0->state_0)[_S1142 + 3U])).w));
                    value_2 = dot_0(_S1143, float3 {_S1119.x, _S1119.y, _S1119.z});
                }
            }
        }
        write_probe_0(info_3.w, k_15, value_2);
        at_4 = at_4 + 4U;
    }
    return;
}

static __device__ void contact_split_at_0(uint at_5)
{
    uint _S1144 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint previous_1 = (&(globalParams_0->islands_0)[_S1144])->info_1.y;
    uint _S1145 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint _S1146;
    if(previous_1 == 0U)
    {
        _S1146 = at_5;
    }
    else
    {
        _S1146 = (U32_min((previous_1), (at_5)));
    }
    *&((&(&(globalParams_0->islands_0)[_S1145])->info_1)->y) = _S1146;
    return;
}

extern "C" __global__ void wide_end()
{
    uint _S1147 = 0U;
    uint _S1148 = __ballot_sync(4294967295U, true);
    uint tid_11 = threadIdx.x;
    uint _S1149 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1150 = blockIdx.x;
    WideGroup_0 wg_5 = wide_group_0(_S1149, _S1150);
    bool _S1151 = _S1150 != (wg_5.first_0);
    uint _S1152 = __ballot_sync(_S1148, _S1151);
    if(_S1151)
    {
        return;
    }
    else
    {
        uint _S1153 = __ballot_sync(_S1148, true);
        _S1147 = _S1153;
    }
    uint _S1154 = 0U;
    Island_0 * _S1155 = (&(globalParams_0->islands_0)[wg_5.island_2]);
    Island_0 isl_15 = *_S1155;
    Island_0 _S1156 = *_S1155;
    bool _S1157 = wide_enter_0(tid_11, &_S1156);
    bool _S1158 = !_S1157;
    uint _S1159 = __ballot_sync(_S1147, _S1158);
    if(_S1158)
    {
        return;
    }
    else
    {
        uint _S1160 = __ballot_sync(_S1147, true);
        _S1154 = _S1160;
    }
    float3  work_1;
    float3  flags_2;
    wide_partials_0(tid_11, wg_5.first_0, (&isl_15)->wide_groups_0, 6U, &work_1, &flags_2, _S1154);
    bool _S1161 = tid_11 != 0U;
    uint _S1162 = __ballot_sync(_S1154, _S1161);
    if(_S1161)
    {
        return;
    }
    Island_0 _S1163 = isl_15;
    uint _S1164 = wide_step_0(&_S1163);
    if(((&isl_15)->probes_0.y) > ((&isl_15)->probes_0.x))
    {
        Island_0 _S1165 = isl_15;
        Rigid_0 _S1166 = rigid_of_0(&_S1165);
        Island_0 _S1167 = isl_15;
        Rigid_0 _S1168 = _S1166;
        record_probes_0(&_S1167, &_S1168, _S1164);
    }
    bool halt_0 = (((&isl_15)->info_1.z) & 2U) != 0U;
    bool _S1169;
    if(halt_0)
    {
        _S1169 = (((&isl_15)->info_1.x) & 4U) != 0U;
    }
    else
    {
        _S1169 = false;
    }
    if(_S1169)
    {
        contact_split_at_0((&isl_15)->info_1.w + 1U);
    }
    comp_add1_0(&((&(&isl_15)->energy_1)->x), &((&(&isl_15)->energy_1)->y), work_1.x);
    *&((&(&isl_15)->energy_1)->y) = *&((&(&isl_15)->energy_1)->y) + work_1.y;
    (&isl_15)->done_0 = (&isl_15)->done_0 + 1U;
    *&((&(&isl_15)->info_1)->y) = *&((&(&isl_15)->info_1)->y) - 1U;
    *&((&(&isl_15)->info_1)->w) = *&((&(&isl_15)->info_1)->w) + 1U;
    if(halt_0)
    {
        *&((&(&isl_15)->info_1)->z) = (((&isl_15)->info_1.z) & 4294967293U) | 1U;
    }
    uint _S1170;
    if(halt_0)
    {
        _S1170 = 128U;
    }
    else
    {
        _S1170 = 0U;
    }
    uint _S1171 = 256U | _S1170;
    if(((&isl_15)->probes_0.y) > ((&isl_15)->probes_0.x))
    {
        _S1170 = 262144U;
    }
    else
    {
        _S1170 = 0U;
    }
    uint _S1172 = _S1171 | _S1170;
    if((((&isl_15)->info_1.x) & 4U) != 0U)
    {
        _S1170 = 524288U;
    }
    else
    {
        _S1170 = 0U;
    }
    uint _S1173 = _S1172 | _S1170;
    if((flags_2.x) > 0.0f)
    {
        _S1170 = 32768U;
    }
    else
    {
        _S1170 = 0U;
    }
    uint _S1174 = _S1173 | _S1170;
    if((flags_2.y) > 0.0f)
    {
        _S1170 = 65536U;
    }
    else
    {
        _S1170 = 0U;
    }
    uint _S1175 = _S1174 | _S1170;
    if((flags_2.z) > 0.0f)
    {
        _S1170 = 131072U;
    }
    else
    {
        _S1170 = 0U;
    }
    (&isl_15)->coverage_0 = ((&isl_15)->coverage_0) | (_S1175 | _S1170);
    *(&(globalParams_0->islands_0)[wg_5.island_2]) = isl_15;
    return;
}

static __device__ uint sv_0(uint c_16, uint slot_2)
{
    uint _S1176 = __ldg(&globalParams_0->params_0->statics_base_0);
    return _S1176 + 23U * c_16 + slot_2;
}

static __device__ void project_load_slot_0(uint tid_12, Island_0 * isl_16, uint slot_3, uint _S1177)
{
    uint _S1178;
    uint _S1179;
    float3  _S1180 = make_float3 (0.0f);
    float3  net_f_0 = _S1180;
    float3  net_m_0 = _S1180;
    uint4  _S1181 = isl_16->range_0;
    uint _S1182 = isl_16->range_0.x + tid_12;
    uint c_17 = _S1182;
    uint _S1183 = _S1177;
    for(;;)
    {
        uint _S1184 = _S1181.y;
        _S1178 = _S1184;
        bool _S1185 = c_17 < _S1184;
        uint _S1186 = __ballot_sync(_S1183, _S1185);
        if(_S1185)
        {
            uint _S1187 = __ballot_sync(_S1183, true);
        }
        else
        {
            uint _S1188 = __ballot_sync(_S1183, false);
            uint _S1189 = __ballot_sync(_S1183, false);
            uint _S1190 = __ballot_sync(_S1177, true);
            _S1179 = _S1190;
            break;
        }
        float4  _S1191 = *(&(globalParams_0->scratch_0)[sv_0(c_17, slot_3)]);
        float3  fi_0 = float3 {_S1191.x, _S1191.y, _S1191.z};
        net_f_0 = net_f_0 + fi_0;
        float4  _S1192 = __ldg(&(&(globalParams_0->chunks_0)[c_17])->center_0);
        float4  _S1193 = isl_16->com_0;
        float4  _S1194 = *(&(globalParams_0->scratch_0)[sv_0(c_17, slot_3 + 1U)]);
        net_m_0 = net_m_0 + (cross_0(float3 {_S1192.x, _S1192.y, _S1192.z} - float3 {_S1193.x, _S1193.y, _S1193.z}, fi_0) + float3 {_S1194.x, _S1194.y, _S1194.z});
        uint _S1195 = __ballot_sync(_S1183, true);
        c_17 = c_17 + 256U;
        _S1183 = _S1195;
    }
    group_sum3_0(tid_12, &net_f_0, &net_m_0, _S1179);
    float4  _S1196 = isl_16->com_0;
    float3  _S1197 = net_f_0 / make_float3 (isl_16->com_0.w);
    float3  _S1198 = rows_mul_0(isl_16->inv0_1, isl_16->inv1_1, isl_16->inv2_1, net_m_0);
    c_17 = _S1182;
    for(;;)
    {
        if(c_17 < _S1178)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_0 * _S1199 = (&(globalParams_0->chunks_0)[c_17]);
        float4  _S1200 = __ldg(&_S1199->center_0);
        uint _S1201 = sv_0(c_17, slot_3);
        float4  _S1202 = *(&(globalParams_0->scratch_0)[_S1201]);
        *(&(globalParams_0->scratch_0)[_S1201]) = make_float4 ((float3 {_S1202.x, _S1202.y, _S1202.z} - (_S1197 + cross_0(_S1198, float3 {_S1200.x, _S1200.y, _S1200.z} - float3 {_S1196.x, _S1196.y, _S1196.z})) * make_float3 (_S1200.w)).x, (float3 {_S1202.x, _S1202.y, _S1202.z} - (_S1197 + cross_0(_S1198, float3 {_S1200.x, _S1200.y, _S1200.z} - float3 {_S1196.x, _S1196.y, _S1196.z})) * make_float3 (_S1200.w)).y, (float3 {_S1202.x, _S1202.y, _S1202.z} - (_S1197 + cross_0(_S1198, float3 {_S1200.x, _S1200.y, _S1200.z} - float3 {_S1196.x, _S1196.y, _S1196.z})) * make_float3 (_S1200.w)).z, 0.0f);
        uint _S1203 = sv_0(c_17, slot_3 + 1U);
        float4  * _S1204 = (&(globalParams_0->scratch_0)[_S1203]);
        float4  _S1205 = *(&(globalParams_0->scratch_0)[_S1203]);
        float3  _S1206 = float3 {_S1205.x, _S1205.y, _S1205.z};
        float4  _S1207 = __ldg(&_S1199->inertia0_0);
        float4  _S1208 = __ldg(&_S1199->inertia1_0);
        float4  _S1209 = __ldg(&_S1199->inertia2_0);
        *_S1204 = make_float4 ((_S1206 - rows_mul_0(_S1207, _S1208, _S1209, _S1198)).x, (_S1206 - rows_mul_0(_S1207, _S1208, _S1209, _S1198)).y, (_S1206 - rows_mul_0(_S1207, _S1208, _S1209, _S1198)).z, 0.0f);
        c_17 = c_17 + 256U;
    }
    __syncthreads();
    return;
}

static __device__ float island_dot_0(uint tid_13, uint c0_0, uint c1_0, uint sa_2, uint sb_2, uint _S1210)
{
    uint _S1211;
    float4  _S1212 = make_float4 (0.0f);
    float4  acc_0 = _S1212;
    float4  unused_2 = _S1212;
    uint c_18 = c0_0 + tid_13;
    uint _S1213 = _S1210;
    for(;;)
    {
        bool _S1214 = c_18 < c1_0;
        uint _S1215 = __ballot_sync(_S1213, _S1214);
        if(_S1214)
        {
            uint _S1216 = __ballot_sync(_S1213, true);
        }
        else
        {
            uint _S1217 = __ballot_sync(_S1213, false);
            uint _S1218 = __ballot_sync(_S1213, false);
            uint _S1219 = __ballot_sync(_S1210, true);
            _S1211 = _S1219;
            break;
        }
        float4  _S1220 = *(&(globalParams_0->scratch_0)[sv_0(c_18, sa_2)]);
        float4  _S1221 = *(&(globalParams_0->scratch_0)[sv_0(c_18, sb_2)]);
        float4  _S1222 = *(&(globalParams_0->scratch_0)[sv_0(c_18, sa_2 + 1U)]);
        float4  _S1223 = *(&(globalParams_0->scratch_0)[sv_0(c_18, sb_2 + 1U)]);
        *&((&acc_0)->x) = *&((&acc_0)->x) + (dot_0(float3 {_S1220.x, _S1220.y, _S1220.z}, float3 {_S1221.x, _S1221.y, _S1221.z}) + dot_0(float3 {_S1222.x, _S1222.y, _S1222.z}, float3 {_S1223.x, _S1223.y, _S1223.z}));
        uint _S1224 = __ballot_sync(_S1213, true);
        c_18 = c_18 + 256U;
        _S1213 = _S1224;
    }
    group_sum2_0(tid_13, &acc_0, &unused_2, _S1211);
    return acc_0.x;
}

static __device__ void static_kinematics_0(uint _S1225, float3  * _S1226, float3  * _S1227)
{
    BondStatic_0 * _S1228 = (&(globalParams_0->bonds_0)[_S1225]);
    JointBond_0 _S1229 = slang_ldg_0(&_S1228->law_0);
    uint ca_1 = _S1229.ids_0.y;
    uint cb_1 = _S1229.ids_0.z;
    uint _S1230 = 4U * cb_1;
    float4  _S1231 = *(&(globalParams_0->state_0)[_S1230]);
    uint _S1232 = 4U * ca_1;
    float4  _S1233 = *(&(globalParams_0->state_0)[_S1232]);
    float4  _S1234 = *(&(globalParams_0->scratch_0)[sv_0(cb_1, 21U)]);
    float4  _S1235 = *(&(globalParams_0->scratch_0)[sv_0(ca_1, 21U)]);
    float3  du_0 = float3 {_S1231.x, _S1231.y, _S1231.z} - float3 {_S1233.x, _S1233.y, _S1233.z} + (float3 {_S1234.x, _S1234.y, _S1234.z} - float3 {_S1235.x, _S1235.y, _S1235.z});
    uint _S1236 = _S1230 + 1U;
    float4  _S1237 = *(&(globalParams_0->state_0)[_S1236]);
    uint _S1238 = _S1232 + 1U;
    float4  _S1239 = *(&(globalParams_0->state_0)[_S1238]);
    uint _S1240 = sv_0(cb_1, 22U);
    float4  _S1241 = *(&(globalParams_0->scratch_0)[_S1240]);
    uint _S1242 = sv_0(ca_1, 22U);
    float4  _S1243 = *(&(globalParams_0->scratch_0)[_S1242]);
    float3  dth_0 = float3 {_S1237.x, _S1237.y, _S1237.z} - float3 {_S1239.x, _S1239.y, _S1239.z} + (float3 {_S1241.x, _S1241.y, _S1241.z} - float3 {_S1243.x, _S1243.y, _S1243.z});
    float4  _S1244 = *(&(globalParams_0->state_0)[_S1238]);
    float4  _S1245 = *(&(globalParams_0->scratch_0)[_S1242]);
    float3  ta_3 = float3 {_S1244.x, _S1244.y, _S1244.z} + float3 {_S1245.x, _S1245.y, _S1245.z};
    float4  _S1246 = *(&(globalParams_0->state_0)[_S1236]);
    float4  _S1247 = *(&(globalParams_0->scratch_0)[_S1240]);
    float3  tb_3 = float3 {_S1246.x, _S1246.y, _S1246.z} + float3 {_S1247.x, _S1247.y, _S1247.z};
    float4  _S1248 = __ldg(&_S1228->rb_0);
    float3  _S1249 = cross_0(tb_3, float3 {_S1248.x, _S1248.y, _S1248.z});
    float4  _S1250 = __ldg(&_S1228->ra_0);
    float3  _S1251 = to_local_0(_S1225, du_0 + (_S1249 - cross_0(ta_3, float3 {_S1250.x, _S1250.y, _S1250.z})));
    *_S1226 = _S1251;
    float3  _S1252 = to_local_0(_S1225, dth_0);
    *_S1227 = _S1252;
    return;
}

static __device__ JointResponse_0 static_response_0(uint i_17)
{
    BondStatic_0 * _S1253 = (&(globalParams_0->bonds_0)[i_17]);
    float3  d_lin_4;
    float3  d_ang_3;
    static_kinematics_0(i_17, &d_lin_4, &d_ang_3);
    JointBond_0 _S1254 = slang_ldg_0(&_S1253->law_0);
    JointBond_0 _S1255 = _S1254;
    JointState_0 _S1256 = (&(globalParams_0->bond_dyn_0)[i_17])->js_0;
    JointResponse_0 _S1257 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S1254.ids_0.x], &_S1255, &_S1256, d_lin_4, d_ang_3, 0.0f, false);
    return _S1257;
}

static __device__ void gather_loads_0(uint c_19, float3  * fi_1, float3  * mi_0)
{
    float3  _S1258 = make_float3 (0.0f);
    *fi_1 = _S1258;
    *mi_0 = _S1258;
    uint _S1259 = __ldg((&(globalParams_0->index_0)[c_19]));
    uint e_2 = _S1259;
    for(;;)
    {
        uint _S1260 = __ldg((&(globalParams_0->index_0)[c_19 + 1U]));
        if(e_2 < _S1260)
        {
        }
        else
        {
            break;
        }
        uint _S1261 = __ldg((&(globalParams_0->index_0)[e_2]));
        uint bond_0 = _S1261 >> int(1);
        if((_S1261 & 1U) == 0U)
        {
            uint _S1262 = 3U * bond_0;
            float4  _S1263 = *(&(globalParams_0->scratch_0)[_S1262]);
            *fi_1 = *fi_1 + float3 {_S1263.x, _S1263.y, _S1263.z};
            float4  _S1264 = *(&(globalParams_0->scratch_0)[_S1262 + 1U]);
            *mi_0 = *mi_0 + float3 {_S1264.x, _S1264.y, _S1264.z};
        }
        else
        {
            uint _S1265 = 3U * bond_0;
            float4  _S1266 = *(&(globalParams_0->scratch_0)[_S1265]);
            *fi_1 = *fi_1 - float3 {_S1266.x, _S1266.y, _S1266.z};
            float4  _S1267 = *(&(globalParams_0->scratch_0)[_S1265 + 2U]);
            *mi_0 = *mi_0 + float3 {_S1267.x, _S1267.y, _S1267.z};
        }
        e_2 = e_2 + 1U;
    }
    return;
}

static __device__ float bond_load_magnitude2_0(uint c_20)
{
    uint _S1268 = __ldg((&(globalParams_0->index_0)[c_20]));
    uint e_3 = _S1268;
    float m_4 = 0.0f;
    for(;;)
    {
        uint _S1269 = __ldg((&(globalParams_0->index_0)[c_20 + 1U]));
        if(e_3 < _S1269)
        {
        }
        else
        {
            break;
        }
        uint _S1270 = __ldg((&(globalParams_0->index_0)[e_3]));
        uint _S1271 = 3U * (_S1270 >> int(1));
        float4  _S1272 = *(&(globalParams_0->scratch_0)[_S1271]);
        float3  f_13 = float3 {_S1272.x, _S1272.y, _S1272.z};
        float3  t_12;
        if((_S1270 & 1U) == 0U)
        {
            float4  _S1273 = *(&(globalParams_0->scratch_0)[_S1271 + 1U]);
            t_12 = float3 {_S1273.x, _S1273.y, _S1273.z};
        }
        else
        {
            float4  _S1274 = *(&(globalParams_0->scratch_0)[_S1271 + 2U]);
            t_12 = float3 {_S1274.x, _S1274.y, _S1274.z};
        }
        float m_5 = m_4 + (dot_0(f_13, f_13) + dot_0(t_12, t_12));
        e_3 = e_3 + 1U;
        m_4 = m_5;
    }
    return m_4;
}

static __device__ uint fixed_mask_0(uint c_21)
{
    uint4  _S1275 = __ldg(&(&(globalParams_0->chunks_0)[c_21])->info_0);
    uint support_0 = _S1275.x;
    uint _S1276;
    if(support_0 == 1U)
    {
        _S1276 = 63U;
    }
    else
    {
        if(support_0 == 2U)
        {
            _S1276 = 7U;
        }
        else
        {
            _S1276 = 0U;
        }
    }
    return _S1276;
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

static __device__ uint statics_bond_slot_0(uint i_18)
{
    uint _S1277 = __ldg(&globalParams_0->params_0->statics_base_0);
    uint _S1278 = __ldg(&globalParams_0->params_0->chunk_count_0);
    return _S1277 + 23U * _S1278 + 2U * i_18;
}

static __device__ void store_inverse_0(uint c_22, FixedArray<float, 36>  * a_17)
{
    uint j_7;
    float sum_4;
    FixedArray<float, 36>  l_3;
    uint k_16 = 0U;
    for(;;)
    {
        if(k_16 < 36U)
        {
        }
        else
        {
            break;
        }
        l_3[k_16] = 0.0f;
        k_16 = k_16 + 1U;
    }
    bool spd_0 = true;
    uint i_19 = 0U;
    for(;;)
    {
        bool _S1279;
        if(i_19 < 6U)
        {
            _S1279 = spd_0;
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
            break;
        }
        j_7 = 0U;
        for(;;)
        {
            if(j_7 <= i_19)
            {
            }
            else
            {
                break;
            }
            uint _S1280 = i_19 * 6U;
            uint _S1281 = _S1280 + j_7;
            k_16 = 0U;
            sum_4 = (*a_17)[_S1281];
            for(;;)
            {
                if(k_16 < j_7)
                {
                }
                else
                {
                    break;
                }
                float sum_5 = sum_4 - l_3[_S1280 + k_16] * l_3[j_7 * 6U + k_16];
                k_16 = k_16 + 1U;
                sum_4 = sum_5;
            }
            if(i_19 == j_7)
            {
                if(sum_4 <= 0.0f)
                {
                    spd_0 = false;
                    break;
                }
                l_3[_S1280 + i_19] = (F32_sqrt((sum_4)));
            }
            else
            {
                l_3[_S1281] = sum_4 / l_3[j_7 * 6U + j_7];
            }
            j_7 = j_7 + 1U;
        }
        i_19 = i_19 + 1U;
    }
    FixedArray<float, 36>  inv_0;
    if(!spd_0)
    {
        k_16 = 0U;
        for(;;)
        {
            if(k_16 < 36U)
            {
            }
            else
            {
                break;
            }
            inv_0[k_16] = 0.0f;
            k_16 = k_16 + 1U;
        }
        k_16 = 0U;
        for(;;)
        {
            if(k_16 < 6U)
            {
            }
            else
            {
                break;
            }
            uint _S1282 = k_16 * 6U + k_16;
            float _S1283 = (*a_17)[_S1282];
            if(((*a_17)[_S1282]) > 0.0f)
            {
                sum_4 = 1.0f / _S1283;
            }
            else
            {
                sum_4 = 0.0f;
            }
            inv_0[_S1282] = sum_4;
            k_16 = k_16 + 1U;
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
            i_19 = 0U;
            for(;;)
            {
                if(i_19 < 6U)
                {
                }
                else
                {
                    break;
                }
                if(i_19 == j_7)
                {
                    sum_4 = 1.0f;
                }
                else
                {
                    sum_4 = 0.0f;
                }
                k_16 = 0U;
                float s_6 = sum_4;
                for(;;)
                {
                    if(k_16 < i_19)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_7 = s_6 - l_3[i_19 * 6U + k_16] * y_6[k_16];
                    k_16 = k_16 + 1U;
                    s_6 = s_7;
                }
                y_6[i_19] = s_6 / l_3[i_19 * 6U + i_19];
                i_19 = i_19 + 1U;
            }
            FixedArray<float, 6>  x_25;
            x_25[int(0)] = 0.0f;
            x_25[int(1)] = 0.0f;
            x_25[int(2)] = 0.0f;
            x_25[int(3)] = 0.0f;
            x_25[int(4)] = 0.0f;
            x_25[int(5)] = 0.0f;
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
                uint i_20 = 5U - ii_1;
                k_16 = i_20 + 1U;
                sum_4 = y_6[i_20];
                for(;;)
                {
                    if(k_16 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_8 = sum_4 - l_3[k_16 * 6U + i_20] * x_25[k_16];
                    k_16 = k_16 + 1U;
                    sum_4 = s_8;
                }
                x_25[i_20] = sum_4 / l_3[i_20 * 6U + i_20];
                ii_1 = ii_1 + 1U;
            }
            uint i_21 = 0U;
            for(;;)
            {
                if(i_21 < 6U)
                {
                }
                else
                {
                    break;
                }
                inv_0[i_21 * 6U + j_7] = x_25[i_21];
                i_21 = i_21 + 1U;
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
        uint _S1284 = 4U * j_7;
        *(&(globalParams_0->scratch_0)[sv_0(c_22, 12U + j_7)]) = make_float4 (inv_0[_S1284], inv_0[_S1284 + 1U], inv_0[_S1284 + 2U], inv_0[_S1284 + 3U]);
        j_7 = j_7 + 1U;
    }
    return;
}

static __device__ void assemble_block_0(uint c_23)
{
    uint p_13;
    uint r_11;
    FixedArray<float, 36>  a_18;
    uint k_17 = 0U;
    for(;;)
    {
        if(k_17 < 36U)
        {
        }
        else
        {
            break;
        }
        a_18[k_17] = 0.0f;
        k_17 = k_17 + 1U;
    }
    uint _S1285 = __ldg((&(globalParams_0->index_0)[c_23]));
    uint e_4 = _S1285;
    for(;;)
    {
        uint _S1286 = __ldg((&(globalParams_0->index_0)[c_23 + 1U]));
        if(e_4 < _S1286)
        {
        }
        else
        {
            break;
        }
        uint _S1287 = __ldg((&(globalParams_0->index_0)[e_4]));
        uint i_22 = _S1287 >> int(1);
        bool _S1288 = (_S1287 & 1U) != 0U;
        BondStatic_0 * _S1289 = (&(globalParams_0->bonds_0)[i_22]);
        uint _S1290 = statics_bond_slot_0(i_22);
        float4  _S1291 = *(&(globalParams_0->scratch_0)[_S1290]);
        float4  _S1292 = *(&(globalParams_0->scratch_0)[_S1290 + 1U]);
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
            uint _S1293 = p_13 % 3U;
            float3  t_13;
            if(_S1293 == 0U)
            {
                float4  _S1294 = __ldg(&_S1289->t1_0);
                t_13 = float3 {_S1294.x, _S1294.y, _S1294.z};
            }
            else
            {
                if(_S1293 == 1U)
                {
                    float4  _S1295 = __ldg(&_S1289->t2_0);
                    t_13 = float3 {_S1295.x, _S1295.y, _S1295.z};
                }
                else
                {
                    float4  _S1296 = __ldg(&_S1289->normal_0);
                    t_13 = float3 {_S1296.x, _S1296.y, _S1296.z};
                }
            }
            bool _S1297 = p_13 < 3U;
            float3  row_u_0;
            float3  row_t_0;
            if(_S1297)
            {
                if(_S1288)
                {
                    row_u_0 = t_13;
                }
                else
                {
                    row_u_0 = - t_13;
                }
                if(_S1288)
                {
                    float4  _S1298 = __ldg(&_S1289->rb_0);
                    row_t_0 = cross_0(float3 {_S1298.x, _S1298.y, _S1298.z}, t_13);
                }
                else
                {
                    float4  _S1299 = __ldg(&_S1289->ra_0);
                    row_t_0 = - cross_0(float3 {_S1299.x, _S1299.y, _S1299.z}, t_13);
                }
            }
            else
            {
                float3  _S1300 = make_float3 (0.0f);
                if(_S1288)
                {
                    row_u_0 = t_13;
                }
                else
                {
                    row_u_0 = - t_13;
                }
                float3  _S1301 = row_u_0;
                row_u_0 = _S1300;
                row_t_0 = _S1301;
            }
            float kp_0;
            if(_S1297)
            {
                kp_0 = _slang_vector_get_element(_S1291, p_13);
            }
            else
            {
                kp_0 = _slang_vector_get_element(_S1292, p_13 - 3U);
            }
            if(kp_0 == 0.0f)
            {
                p_13 = p_13 + 1U;
                continue;
            }
            FixedArray<float, 6>  _S1302 = { {
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
                uint q_12 = 0U;
                for(;;)
                {
                    if(q_12 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    a_18[r_11 * 6U + q_12] = a_18[r_11 * 6U + q_12] + kp_0 * _S1302[r_11] * _S1302[q_12];
                    q_12 = q_12 + 1U;
                }
                r_11 = r_11 + 1U;
            }
            p_13 = p_13 + 1U;
        }
        e_4 = e_4 + 1U;
    }
    uint _S1303 = fixed_mask_0(c_23);
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
        if((_S1303 & (1U << p_13)) != 0U)
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
                a_18[p_13 * 6U + r_11] = 0.0f;
                a_18[r_11 * 6U + p_13] = 0.0f;
                r_11 = r_11 + 1U;
            }
            a_18[p_13 * 6U + p_13] = 1.0f;
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
        if((a_18[p_13 * 6U + p_13]) == 0.0f)
        {
            a_18[p_13 * 6U + p_13] = 1.0f;
        }
        p_13 = p_13 + 1U;
    }
    FixedArray<float, 36>  _S1304 = a_18;
    store_inverse_0(c_23, &_S1304);
    return;
}

static __device__ float block_get_0(uint c_24, uint i_23, uint j_8)
{
    uint k_18 = i_23 * 6U + j_8;
    return *_slang_vector_get_element_ptr((&(globalParams_0->scratch_0)[sv_0(c_24, 12U + k_18 / 4U)]), k_18 % 4U);
}

static __device__ void precondition_0(uint c_25)
{
    float4  * _S1305 = (&(globalParams_0->scratch_0)[sv_0(c_25, 4U)]);
    float4  * _S1306 = (&(globalParams_0->scratch_0)[sv_0(c_25, 5U)]);
    FixedArray<float, 6>  _S1307 = { {
        (*_S1305).x, (*_S1305).y, (*_S1305).z, (*_S1306).x, (*_S1306).y, (*_S1306).z
    } };
    FixedArray<float, 6>  z_1;
    uint i_24 = 0U;
    for(;;)
    {
        if(i_24 < 6U)
        {
        }
        else
        {
            break;
        }
        uint j_9 = 0U;
        float s_9 = 0.0f;
        for(;;)
        {
            if(j_9 < 6U)
            {
            }
            else
            {
                break;
            }
            float s_10 = s_9 + block_get_0(c_25, i_24, j_9) * _S1307[j_9];
            j_9 = j_9 + 1U;
            s_9 = s_10;
        }
        z_1[i_24] = s_9;
        i_24 = i_24 + 1U;
    }
    *(&(globalParams_0->scratch_0)[sv_0(c_25, 6U)]) = make_float4 (z_1[int(0)], z_1[int(1)], z_1[int(2)], 0.0f);
    *(&(globalParams_0->scratch_0)[sv_0(c_25, 7U)]) = make_float4 (z_1[int(3)], z_1[int(4)], z_1[int(5)], 0.0f);
    return;
}

static __device__ void project_displacement_slot_0(uint tid_14, Island_0 * isl_17, uint slot_4, uint _S1308)
{
    uint _S1309;
    uint _S1310;
    float3  _S1311 = make_float3 (0.0f);
    float3  p_14 = _S1311;
    float3  l_4 = _S1311;
    uint4  _S1312 = isl_17->range_0;
    uint _S1313 = isl_17->range_0.x + tid_14;
    uint c_26 = _S1313;
    uint _S1314 = _S1308;
    for(;;)
    {
        uint _S1315 = _S1312.y;
        _S1309 = _S1315;
        bool _S1316 = c_26 < _S1315;
        uint _S1317 = __ballot_sync(_S1314, _S1316);
        if(_S1316)
        {
            uint _S1318 = __ballot_sync(_S1314, true);
        }
        else
        {
            uint _S1319 = __ballot_sync(_S1314, false);
            uint _S1320 = __ballot_sync(_S1314, false);
            uint _S1321 = __ballot_sync(_S1308, true);
            _S1310 = _S1321;
            break;
        }
        ChunkStatic_0 * _S1322 = (&(globalParams_0->chunks_0)[c_26]);
        float4  _S1323 = *(&(globalParams_0->scratch_0)[sv_0(c_26, slot_4)]);
        float3  u_0 = float3 {_S1323.x, _S1323.y, _S1323.z};
        float4  _S1324 = *(&(globalParams_0->scratch_0)[sv_0(c_26, slot_4 + 1U)]);
        float3  th_2 = float3 {_S1324.x, _S1324.y, _S1324.z};
        float4  _S1325 = __ldg(&_S1322->center_0);
        float4  _S1326 = isl_17->com_0;
        float3  r_12 = float3 {_S1325.x, _S1325.y, _S1325.z} - float3 {_S1326.x, _S1326.y, _S1326.z};
        float _S1327 = _S1325.w;
        p_14 = p_14 + u_0 * make_float3 (_S1327);
        float3  _S1328 = cross_0(r_12, u_0) * make_float3 (_S1327);
        float4  _S1329 = __ldg(&_S1322->inertia0_0);
        float4  _S1330 = __ldg(&_S1322->inertia1_0);
        float4  _S1331 = __ldg(&_S1322->inertia2_0);
        l_4 = l_4 + (_S1328 + rows_mul_0(_S1329, _S1330, _S1331, th_2));
        uint _S1332 = __ballot_sync(_S1314, true);
        c_26 = c_26 + 256U;
        _S1314 = _S1332;
    }
    group_sum3_0(tid_14, &p_14, &l_4, _S1310);
    float4  _S1333 = isl_17->com_0;
    float3  _S1334 = p_14 / make_float3 (isl_17->com_0.w);
    float3  _S1335 = rows_mul_0(isl_17->inv0_1, isl_17->inv1_1, isl_17->inv2_1, l_4);
    c_26 = _S1313;
    for(;;)
    {
        if(c_26 < _S1309)
        {
        }
        else
        {
            break;
        }
        float4  _S1336 = __ldg(&(&(globalParams_0->chunks_0)[c_26])->center_0);
        uint _S1337 = sv_0(c_26, slot_4);
        float4  _S1338 = *(&(globalParams_0->scratch_0)[_S1337]);
        *(&(globalParams_0->scratch_0)[_S1337]) = make_float4 ((float3 {_S1338.x, _S1338.y, _S1338.z} - _S1334 - cross_0(_S1335, float3 {_S1336.x, _S1336.y, _S1336.z} - float3 {_S1333.x, _S1333.y, _S1333.z})).x, (float3 {_S1338.x, _S1338.y, _S1338.z} - _S1334 - cross_0(_S1335, float3 {_S1336.x, _S1336.y, _S1336.z} - float3 {_S1333.x, _S1333.y, _S1333.z})).y, (float3 {_S1338.x, _S1338.y, _S1338.z} - _S1334 - cross_0(_S1335, float3 {_S1336.x, _S1336.y, _S1336.z} - float3 {_S1333.x, _S1333.y, _S1333.z})).z, 0.0f);
        uint _S1339 = sv_0(c_26, slot_4 + 1U);
        float4  _S1340 = *(&(globalParams_0->scratch_0)[_S1339]);
        *(&(globalParams_0->scratch_0)[_S1339]) = make_float4 ((float3 {_S1340.x, _S1340.y, _S1340.z} - _S1335).x, (float3 {_S1340.x, _S1340.y, _S1340.z} - _S1335).y, (float3 {_S1340.x, _S1340.y, _S1340.z} - _S1335).z, 0.0f);
        c_26 = c_26 + 256U;
    }
    __syncthreads();
    return;
}

static __device__ uint statics_result_slot_0(uint island_3)
{
    uint _S1341 = __ldg(&globalParams_0->params_0->statics_base_0);
    uint _S1342 = __ldg(&globalParams_0->params_0->chunk_count_0);
    uint _S1343 = _S1341 + 23U * _S1342;
    uint _S1344 = __ldg(&globalParams_0->params_0->statics_bonds_0);
    return _S1343 + 2U * _S1344 + island_3;
}

static __device__ void write_bond_loads_0(uint _S1345, uint _S1346, float3  _S1347, float3  _S1348, float _S1349)
{
    BondStatic_0 * _S1350 = (&(globalParams_0->bonds_0)[_S1346]);
    float3  _S1351 = to_body_0(_S1346, _S1347);
    float3  _S1352 = to_body_0(_S1346, _S1348);
    uint _S1353 = 3U * _S1345;
    *(&(globalParams_0->scratch_0)[_S1353]) = make_float4 (_S1351.x, _S1351.y, _S1351.z, _S1349);
    float4  * _S1354 = (&(globalParams_0->scratch_0)[_S1353 + 1U]);
    float4  _S1355 = __ldg(&_S1350->ra_0);
    *_S1354 = make_float4 ((_S1352 + cross_0(float3 {_S1355.x, _S1355.y, _S1355.z}, _S1351)).x, (_S1352 + cross_0(float3 {_S1355.x, _S1355.y, _S1355.z}, _S1351)).y, (_S1352 + cross_0(float3 {_S1355.x, _S1355.y, _S1355.z}, _S1351)).z, 0.0f);
    float4  * _S1356 = (&(globalParams_0->scratch_0)[_S1353 + 2U]);
    float3  _S1357 = - _S1352;
    float4  _S1358 = __ldg(&_S1350->rb_0);
    *_S1356 = make_float4 ((_S1357 + cross_0(float3 {_S1358.x, _S1358.y, _S1358.z}, - _S1351)).x, (_S1357 + cross_0(float3 {_S1358.x, _S1358.y, _S1358.z}, - _S1351)).y, (_S1357 + cross_0(float3 {_S1358.x, _S1358.y, _S1358.z}, - _S1351)).z, 0.0f);
    return;
}

static __device__ void bond_kinematics_0(uint _S1359, float3  _S1360, float3  _S1361, float3  _S1362, float3  _S1363, float3  * _S1364, float3  * _S1365)
{
    BondStatic_0 * _S1366 = (&(globalParams_0->bonds_0)[_S1359]);
    float4  _S1367 = __ldg(&_S1366->rb_0);
    float3  _S1368 = _S1362 + cross_0(_S1363, float3 {_S1367.x, _S1367.y, _S1367.z});
    float4  _S1369 = __ldg(&_S1366->ra_0);
    float3  _S1370 = to_local_0(_S1359, _S1368 - (_S1360 + cross_0(_S1361, float3 {_S1369.x, _S1369.y, _S1369.z})));
    *_S1364 = _S1370;
    float3  _S1371 = to_local_0(_S1359, _S1363 - _S1361);
    *_S1365 = _S1371;
    return;
}

extern "C" __global__ void island_statics()
{
    uint _S1372 = 0U;
    uint _S1373;
    uint i_25;
    uint c_27;
    bool converged_0;
    uint _S1374;
    uint _S1375;
    uint _S1376;
    uint _S1377;
    uint _S1378;
    uint _S1379;
    uint i_26;
    uint _S1380;
    uint _S1381;
    uint _S1382;
    uint _S1383;
    uint _S1384;
    uint _S1385 = __ballot_sync(4294967295U, true);
    uint tid_15 = threadIdx.x;
    uint _S1386 = blockIdx.x;
    Island_0 * _S1387 = (&(globalParams_0->islands_0)[_S1386]);
    Island_0 isl_18 = *_S1387;
    uint _S1388 = (*_S1387).info_1.z;
    bool _S1389 = (_S1388 & 8U) == 0U;
    uint _S1390 = __ballot_sync(_S1385, _S1389);
    if(_S1389)
    {
        return;
    }
    else
    {
        uint _S1391 = __ballot_sync(_S1385, true);
        _S1372 = _S1391;
    }
    bool free_0 = ((isl_18.info_1.x) & 1U) == 0U;
    uint c0_1 = isl_18.range_0.x;
    uint c1_1 = isl_18.range_0.y;
    uint b0_0 = isl_18.range_0.z;
    uint _S1392 = isl_18.range_0.w;
    uint _S1393 = c0_1 + tid_15;
    uint c_28 = _S1393;
    uint newton_0;
    newton_0 = _S1372;
    for(;;)
    {
        bool _S1394 = c_28 < c1_1;
        uint _S1395 = __ballot_sync(newton_0, _S1394);
        if(_S1394)
        {
            uint _S1396 = __ballot_sync(newton_0, true);
        }
        else
        {
            uint _S1397 = __ballot_sync(newton_0, false);
            uint _S1398 = __ballot_sync(newton_0, false);
            uint _S1399 = __ballot_sync(_S1372, true);
            _S1373 = _S1399;
            break;
        }
        float4  _S1400 = make_float4 (0.0f);
        *(&(globalParams_0->scratch_0)[sv_0(c_28, 21U)]) = _S1400;
        *(&(globalParams_0->scratch_0)[sv_0(c_28, 22U)]) = _S1400;
        uint _S1401 = __ballot_sync(newton_0, true);
        c_28 = c_28 + 256U;
        newton_0 = _S1401;
    }
    __syncthreads();
    uint _S1402 = __ballot_sync(_S1373, free_0);
    if(free_0)
    {
        Island_0 _S1403 = isl_18;
        project_load_slot_0(tid_15, &_S1403, 0U, _S1402);
        uint _S1404 = __ballot_sync(_S1373, true);
        c_28 = _S1404;
    }
    else
    {
        uint _S1405 = __ballot_sync(_S1373, true);
        c_28 = _S1405;
    }
    float _S1406 = island_dot_0(tid_15, c0_1, c1_1, 0U, 0U, c_28);
    float _S1407 = (F32_max(((F32_sqrt((_S1406)))), (1.00000000317107685e-30f)));
    float _S1408 = __ldg(&globalParams_0->params_0->statics_tol_0);
    uint _S1409 = __ldg(&globalParams_0->params_0->statics_cg_0);
    uint _S1410 = (U32_min((_S1409), (20U * (c1_1 - c0_1) * 6U + 200U)));
    float previous_2 = 1.00000001504746622e+30f;
    float residual_0 = 0.0f;
    newton_0 = 0U;
    uint cg_total_0 = 0U;
    for(;;)
    {
        uint _S1411 = 0U;
        uint _S1412 = __ldg(&globalParams_0->params_0->statics_newton_0);
        bool _S1413 = newton_0 < _S1412;
        uint _S1414 = __ballot_sync(c_28, _S1413);
        if(_S1413)
        {
            uint _S1415 = __ballot_sync(c_28, true);
            _S1411 = _S1415;
        }
        else
        {
            converged_0 = false;
            break;
        }
        uint _S1416 = b0_0 + tid_15;
        i_25 = _S1416;
        uint _S1417;
        _S1417 = _S1411;
        for(;;)
        {
            bool _S1418 = i_25 < _S1392;
            uint _S1419 = __ballot_sync(_S1417, _S1418);
            if(_S1418)
            {
                uint _S1420 = __ballot_sync(_S1417, true);
            }
            else
            {
                uint _S1421 = __ballot_sync(_S1417, false);
                uint _S1422 = __ballot_sync(_S1417, false);
                uint _S1423 = __ballot_sync(_S1411, true);
                _S1374 = _S1423;
                break;
            }
            JointResponse_0 resp_1 = static_response_0(i_25);
            write_bond_loads_0(i_25, i_25, resp_1.force_lin_1, resp_1.force_ang_1, 0.0f);
            uint _S1424 = __ballot_sync(_S1417, true);
            i_25 = i_25 + 256U;
            _S1417 = _S1424;
        }
        __syncthreads();
        float4  _S1425 = make_float4 (0.0f);
        float4  magnitude_0 = _S1425;
        float4  unused_m_0 = _S1425;
        uint c_29 = _S1393;
        uint _S1426 = _S1374;
        for(;;)
        {
            bool _S1427 = c_29 < c1_1;
            uint _S1428 = __ballot_sync(_S1426, _S1427);
            if(_S1427)
            {
                uint _S1429 = __ballot_sync(_S1426, true);
            }
            else
            {
                uint _S1430 = __ballot_sync(_S1426, false);
                uint _S1431 = __ballot_sync(_S1426, false);
                uint _S1432 = __ballot_sync(_S1374, true);
                _S1375 = _S1432;
                break;
            }
            float3  fi_2;
            float3  mi_1;
            gather_loads_0(c_29, &fi_2, &mi_1);
            *&((&magnitude_0)->x) = *&((&magnitude_0)->x) + bond_load_magnitude2_0(c_29);
            float4  _S1433 = *(&(globalParams_0->scratch_0)[sv_0(c_29, 0U)]);
            float4  r_lin_0 = make_float4 ((float3 {_S1433.x, _S1433.y, _S1433.z} + fi_2).x, (float3 {_S1433.x, _S1433.y, _S1433.z} + fi_2).y, (float3 {_S1433.x, _S1433.y, _S1433.z} + fi_2).z, 0.0f);
            float4  _S1434 = *(&(globalParams_0->scratch_0)[sv_0(c_29, 1U)]);
            float4  r_ang_0 = make_float4 ((float3 {_S1434.x, _S1434.y, _S1434.z} + mi_1).x, (float3 {_S1434.x, _S1434.y, _S1434.z} + mi_1).y, (float3 {_S1434.x, _S1434.y, _S1434.z} + mi_1).z, 0.0f);
            hold_0(fixed_mask_0(c_29), &r_lin_0, &r_ang_0, _S1425, _S1425);
            *(&(globalParams_0->scratch_0)[sv_0(c_29, 4U)]) = r_lin_0;
            *(&(globalParams_0->scratch_0)[sv_0(c_29, 5U)]) = r_ang_0;
            uint _S1435 = __ballot_sync(_S1426, true);
            c_29 = c_29 + 256U;
            _S1426 = _S1435;
        }
        __syncthreads();
        group_sum2_0(tid_15, &magnitude_0, &unused_m_0, _S1375);
        uint _S1436 = __ballot_sync(_S1375, free_0);
        uint _S1437;
        if(free_0)
        {
            Island_0 _S1438 = isl_18;
            project_load_slot_0(tid_15, &_S1438, 4U, _S1436);
            uint _S1439 = __ballot_sync(_S1375, true);
            _S1437 = _S1439;
        }
        else
        {
            uint _S1440 = __ballot_sync(_S1375, true);
            _S1437 = _S1440;
        }
        float _S1441 = island_dot_0(tid_15, c0_1, c1_1, 4U, 4U, _S1437);
        float residual_1 = (F32_sqrt((_S1441))) / _S1407;
        float _S1442 = (F32_max((0.00100000004749745f), (3.83999986297567375e-06f * (F32_sqrt((magnitude_0.x))) / _S1407)));
        bool _S1443 = residual_1 <= _S1408;
        uint _S1444 = __ballot_sync(_S1437, _S1443);
        uint _S1445;
        if(_S1443)
        {
            uint _S1446 = __ballot_sync(_S1437, true);
            converged_0 = true;
            _S1445 = _S1446;
        }
        else
        {
            uint _S1447 = _S1437 & (~_S1444);
            bool _S1448 = residual_1 <= _S1442;
            uint _S1449 = __ballot_sync(_S1447, _S1448);
            if(_S1448)
            {
                bool _S1450 = residual_1 > (0.5f * previous_2);
                uint _S1451 = __ballot_sync(_S1447, true);
                converged_0 = _S1450;
            }
            else
            {
                uint _S1452 = __ballot_sync(_S1447, true);
                converged_0 = false;
            }
            uint _S1453 = __ballot_sync(_S1437, true);
            _S1445 = _S1453;
        }
        uint _S1454 = 0U;
        uint _S1455 = __ballot_sync(_S1445, converged_0);
        if(converged_0)
        {
            residual_0 = residual_1;
            converged_0 = true;
            break;
        }
        else
        {
            uint _S1456 = __ballot_sync(_S1445, true);
            _S1454 = _S1456;
        }
        uint i_27 = _S1416;
        uint _S1457;
        _S1457 = _S1454;
        for(;;)
        {
            bool _S1458 = i_27 < _S1392;
            uint _S1459 = __ballot_sync(_S1457, _S1458);
            if(_S1458)
            {
                uint _S1460 = __ballot_sync(_S1457, true);
            }
            else
            {
                uint _S1461 = __ballot_sync(_S1457, false);
                uint _S1462 = __ballot_sync(_S1457, false);
                uint _S1463 = __ballot_sync(_S1454, true);
                _S1376 = _S1463;
                break;
            }
            BondStatic_0 * _S1464 = (&(globalParams_0->bonds_0)[i_27]);
            float3  d_lin_5;
            float3  d_ang_4;
            static_kinematics_0(i_27, &d_lin_5, &d_ang_4);
            JointBond_0 _S1465 = slang_ldg_0(&_S1464->law_0);
            JointBond_0 _S1466 = _S1465;
            JointState_0 _S1467 = (&(globalParams_0->bond_dyn_0)[i_27])->js_0;
            float3  f_lin_2;
            float3  f_ang_2;
            secant_factors_0(&_S1466, &_S1467, d_lin_5, &f_lin_2, &f_ang_2);
            uint _S1468 = statics_bond_slot_0(i_27);
            float _S1469 = _S1465.stiff0_0.y;
            *(&(globalParams_0->scratch_0)[_S1468]) = make_float4 (_S1469 * f_lin_2.x, _S1469 * f_lin_2.y, _S1465.stiff0_0.x * f_lin_2.z, 0.0f);
            *(&(globalParams_0->scratch_0)[_S1468 + 1U]) = make_float4 (_S1465.stiff0_0.z * f_ang_2.x, _S1465.stiff0_0.w * f_ang_2.y, _S1465.stiff1_0.x * f_ang_2.z, 0.0f);
            uint _S1470 = __ballot_sync(_S1457, true);
            i_27 = i_27 + 256U;
            _S1457 = _S1470;
        }
        __syncthreads();
        uint c_30 = _S1393;
        uint _S1471 = _S1376;
        for(;;)
        {
            bool _S1472 = c_30 < c1_1;
            uint _S1473 = __ballot_sync(_S1471, _S1472);
            if(_S1472)
            {
                uint _S1474 = __ballot_sync(_S1471, true);
            }
            else
            {
                uint _S1475 = __ballot_sync(_S1471, false);
                uint _S1476 = __ballot_sync(_S1471, false);
                uint _S1477 = __ballot_sync(_S1376, true);
                _S1377 = _S1477;
                break;
            }
            assemble_block_0(c_30);
            *(&(globalParams_0->scratch_0)[sv_0(c_30, 2U)]) = _S1425;
            *(&(globalParams_0->scratch_0)[sv_0(c_30, 3U)]) = _S1425;
            uint _S1478 = __ballot_sync(_S1471, true);
            c_30 = c_30 + 256U;
            _S1471 = _S1478;
        }
        __syncthreads();
        uint c_31 = _S1393;
        uint _S1479 = _S1377;
        for(;;)
        {
            bool _S1480 = c_31 < c1_1;
            uint _S1481 = __ballot_sync(_S1479, _S1480);
            if(_S1480)
            {
                uint _S1482 = __ballot_sync(_S1479, true);
            }
            else
            {
                uint _S1483 = __ballot_sync(_S1479, false);
                uint _S1484 = __ballot_sync(_S1479, false);
                uint _S1485 = __ballot_sync(_S1377, true);
                _S1378 = _S1485;
                break;
            }
            precondition_0(c_31);
            uint _S1486 = __ballot_sync(_S1479, true);
            c_31 = c_31 + 256U;
            _S1479 = _S1486;
        }
        __syncthreads();
        uint _S1487 = __ballot_sync(_S1378, free_0);
        uint _S1488;
        if(free_0)
        {
            Island_0 _S1489 = isl_18;
            project_displacement_slot_0(tid_15, &_S1489, 6U, _S1487);
            uint _S1490 = __ballot_sync(_S1378, true);
            _S1488 = _S1490;
        }
        else
        {
            uint _S1491 = __ballot_sync(_S1378, true);
            _S1488 = _S1491;
        }
        uint c_32 = _S1393;
        uint _S1492 = _S1488;
        for(;;)
        {
            bool _S1493 = c_32 < c1_1;
            uint _S1494 = __ballot_sync(_S1492, _S1493);
            if(_S1493)
            {
                uint _S1495 = __ballot_sync(_S1492, true);
            }
            else
            {
                uint _S1496 = __ballot_sync(_S1492, false);
                uint _S1497 = __ballot_sync(_S1492, false);
                uint _S1498 = __ballot_sync(_S1488, true);
                _S1379 = _S1498;
                break;
            }
            *(&(globalParams_0->scratch_0)[sv_0(c_32, 8U)]) = *(&(globalParams_0->scratch_0)[sv_0(c_32, 6U)]);
            *(&(globalParams_0->scratch_0)[sv_0(c_32, 9U)]) = *(&(globalParams_0->scratch_0)[sv_0(c_32, 7U)]);
            uint _S1499 = __ballot_sync(_S1492, true);
            c_32 = c_32 + 256U;
            _S1492 = _S1499;
        }
        __syncthreads();
        float _S1500 = island_dot_0(tid_15, c0_1, c1_1, 4U, 6U, _S1379);
        float _S1501 = island_dot_0(tid_15, c0_1, c1_1, 4U, 4U, _S1379);
        float _S1502 = (F32_sqrt((_S1501)));
        float rz_0 = _S1500;
        uint k_19 = 0U;
        uint cg_total_1 = cg_total_0;
        uint _S1503 = _S1379;
        for(;;)
        {
            bool _S1504 = k_19 < _S1410;
            uint _S1505 = __ballot_sync(_S1503, _S1504);
            uint _S1506;
            bool _S1507;
            if(_S1504)
            {
                bool _S1508 = _S1502 > 0.0f;
                uint _S1509 = __ballot_sync(_S1503, true);
                _S1507 = _S1508;
                _S1506 = _S1509;
            }
            else
            {
                uint _S1510 = __ballot_sync(_S1503, true);
                _S1507 = false;
                _S1506 = _S1510;
            }
            uint _S1511 = 0U;
            uint _S1512 = __ballot_sync(_S1506, _S1507);
            if(_S1507)
            {
                uint _S1513 = __ballot_sync(_S1506, true);
                _S1511 = _S1513;
            }
            else
            {
                uint _S1514 = __ballot_sync(_S1506, false);
                uint _S1515 = __ballot_sync(_S1503, false);
                uint _S1516 = __ballot_sync(_S1379, true);
                cg_total_0 = cg_total_1;
                i_26 = _S1516;
                break;
            }
            i_26 = _S1416;
            _S1380 = _S1511;
            for(;;)
            {
                bool _S1517 = i_26 < _S1392;
                uint _S1518 = __ballot_sync(_S1380, _S1517);
                if(_S1517)
                {
                    uint _S1519 = __ballot_sync(_S1380, true);
                }
                else
                {
                    uint _S1520 = __ballot_sync(_S1380, false);
                    uint _S1521 = __ballot_sync(_S1380, false);
                    uint _S1522 = __ballot_sync(_S1511, true);
                    _S1381 = _S1522;
                    break;
                }
                JointBond_0 _S1523 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_26])->law_0);
                uint ca_2 = _S1523.ids_0.y;
                uint cb_2 = _S1523.ids_0.z;
                float4  _S1524 = *(&(globalParams_0->scratch_0)[sv_0(ca_2, 8U)]);
                float4  _S1525 = *(&(globalParams_0->scratch_0)[sv_0(ca_2, 9U)]);
                float4  _S1526 = *(&(globalParams_0->scratch_0)[sv_0(cb_2, 8U)]);
                float4  _S1527 = *(&(globalParams_0->scratch_0)[sv_0(cb_2, 9U)]);
                float3  d_lin_6;
                float3  d_ang_5;
                bond_kinematics_0(i_26, float3 {_S1524.x, _S1524.y, _S1524.z}, float3 {_S1525.x, _S1525.y, _S1525.z}, float3 {_S1526.x, _S1526.y, _S1526.z}, float3 {_S1527.x, _S1527.y, _S1527.z}, &d_lin_6, &d_ang_5);
                uint _S1528 = statics_bond_slot_0(i_26);
                float4  _S1529 = *(&(globalParams_0->scratch_0)[_S1528]);
                float4  _S1530 = *(&(globalParams_0->scratch_0)[_S1528 + 1U]);
                write_bond_loads_0(i_26, i_26, d_lin_6 * float3 {_S1529.x, _S1529.y, _S1529.z}, d_ang_5 * float3 {_S1530.x, _S1530.y, _S1530.z}, 0.0f);
                uint _S1531 = __ballot_sync(_S1380, true);
                i_26 = i_26 + 256U;
                _S1380 = _S1531;
            }
            __syncthreads();
            c_27 = _S1393;
            uint _S1532 = _S1381;
            for(;;)
            {
                bool _S1533 = c_27 < c1_1;
                uint _S1534 = __ballot_sync(_S1532, _S1533);
                if(_S1533)
                {
                    uint _S1535 = __ballot_sync(_S1532, true);
                }
                else
                {
                    uint _S1536 = __ballot_sync(_S1532, false);
                    uint _S1537 = __ballot_sync(_S1532, false);
                    uint _S1538 = __ballot_sync(_S1381, true);
                    _S1382 = _S1538;
                    break;
                }
                float3  fi_3;
                float3  mi_2;
                gather_loads_0(c_27, &fi_3, &mi_2);
                float4  ap_lin_0 = make_float4 ((- fi_3).x, (- fi_3).y, (- fi_3).z, 0.0f);
                float4  ap_ang_0 = make_float4 ((- mi_2).x, (- mi_2).y, (- mi_2).z, 0.0f);
                hold_0(fixed_mask_0(c_27), &ap_lin_0, &ap_ang_0, *(&(globalParams_0->scratch_0)[sv_0(c_27, 8U)]), *(&(globalParams_0->scratch_0)[sv_0(c_27, 9U)]));
                *(&(globalParams_0->scratch_0)[sv_0(c_27, 10U)]) = ap_lin_0;
                *(&(globalParams_0->scratch_0)[sv_0(c_27, 11U)]) = ap_ang_0;
                uint _S1539 = __ballot_sync(_S1532, true);
                c_27 = c_27 + 256U;
                _S1532 = _S1539;
            }
            uint _S1540 = 0U;
            __syncthreads();
            float _S1541 = island_dot_0(tid_15, c0_1, c1_1, 8U, 10U, _S1382);
            uint _S1542 = cg_total_1 + 1U;
            bool _S1543 = _S1541 <= 0.0f;
            uint _S1544 = __ballot_sync(_S1382, _S1543);
            if(_S1543)
            {
                uint _S1545 = __ballot_sync(_S1382, false);
                uint _S1546 = __ballot_sync(_S1503, false);
                uint _S1547 = __ballot_sync(_S1379, true);
                cg_total_0 = _S1542;
                i_26 = _S1547;
                break;
            }
            else
            {
                uint _S1548 = __ballot_sync(_S1382, true);
                _S1540 = _S1548;
            }
            float _S1549 = rz_0 / _S1541;
            uint c_33 = _S1393;
            uint _S1550;
            _S1550 = _S1540;
            for(;;)
            {
                bool _S1551 = c_33 < c1_1;
                uint _S1552 = __ballot_sync(_S1550, _S1551);
                if(_S1551)
                {
                    uint _S1553 = __ballot_sync(_S1550, true);
                }
                else
                {
                    uint _S1554 = __ballot_sync(_S1550, false);
                    uint _S1555 = __ballot_sync(_S1550, false);
                    uint _S1556 = __ballot_sync(_S1540, true);
                    _S1383 = _S1556;
                    break;
                }
                uint _S1557 = sv_0(c_33, 2U);
                float4  _S1558 = *(&(globalParams_0->scratch_0)[_S1557]);
                float4  _S1559 = *(&(globalParams_0->scratch_0)[sv_0(c_33, 8U)]);
                *(&(globalParams_0->scratch_0)[_S1557]) = make_float4 ((float3 {_S1558.x, _S1558.y, _S1558.z} + make_float3 (_S1549) * float3 {_S1559.x, _S1559.y, _S1559.z}).x, (float3 {_S1558.x, _S1558.y, _S1558.z} + make_float3 (_S1549) * float3 {_S1559.x, _S1559.y, _S1559.z}).y, (float3 {_S1558.x, _S1558.y, _S1558.z} + make_float3 (_S1549) * float3 {_S1559.x, _S1559.y, _S1559.z}).z, 0.0f);
                uint _S1560 = sv_0(c_33, 3U);
                float4  _S1561 = *(&(globalParams_0->scratch_0)[_S1560]);
                float4  _S1562 = *(&(globalParams_0->scratch_0)[sv_0(c_33, 9U)]);
                *(&(globalParams_0->scratch_0)[_S1560]) = make_float4 ((float3 {_S1561.x, _S1561.y, _S1561.z} + make_float3 (_S1549) * float3 {_S1562.x, _S1562.y, _S1562.z}).x, (float3 {_S1561.x, _S1561.y, _S1561.z} + make_float3 (_S1549) * float3 {_S1562.x, _S1562.y, _S1562.z}).y, (float3 {_S1561.x, _S1561.y, _S1561.z} + make_float3 (_S1549) * float3 {_S1562.x, _S1562.y, _S1562.z}).z, 0.0f);
                uint _S1563 = sv_0(c_33, 4U);
                float4  _S1564 = *(&(globalParams_0->scratch_0)[_S1563]);
                float4  _S1565 = *(&(globalParams_0->scratch_0)[sv_0(c_33, 10U)]);
                *(&(globalParams_0->scratch_0)[_S1563]) = make_float4 ((float3 {_S1564.x, _S1564.y, _S1564.z} - make_float3 (_S1549) * float3 {_S1565.x, _S1565.y, _S1565.z}).x, (float3 {_S1564.x, _S1564.y, _S1564.z} - make_float3 (_S1549) * float3 {_S1565.x, _S1565.y, _S1565.z}).y, (float3 {_S1564.x, _S1564.y, _S1564.z} - make_float3 (_S1549) * float3 {_S1565.x, _S1565.y, _S1565.z}).z, 0.0f);
                uint _S1566 = sv_0(c_33, 5U);
                float4  _S1567 = *(&(globalParams_0->scratch_0)[_S1566]);
                float4  _S1568 = *(&(globalParams_0->scratch_0)[sv_0(c_33, 11U)]);
                *(&(globalParams_0->scratch_0)[_S1566]) = make_float4 ((float3 {_S1567.x, _S1567.y, _S1567.z} - make_float3 (_S1549) * float3 {_S1568.x, _S1568.y, _S1568.z}).x, (float3 {_S1567.x, _S1567.y, _S1567.z} - make_float3 (_S1549) * float3 {_S1568.x, _S1568.y, _S1568.z}).y, (float3 {_S1567.x, _S1567.y, _S1567.z} - make_float3 (_S1549) * float3 {_S1568.x, _S1568.y, _S1568.z}).z, 0.0f);
                uint _S1569 = __ballot_sync(_S1550, true);
                c_33 = c_33 + 256U;
                _S1550 = _S1569;
            }
            uint _S1570 = 0U;
            __syncthreads();
            float _S1571 = island_dot_0(tid_15, c0_1, c1_1, 4U, 4U, _S1383);
            bool _S1572 = (F32_sqrt((_S1571))) <= (0.00009999999747379f * _S1502);
            uint _S1573 = __ballot_sync(_S1383, _S1572);
            if(_S1572)
            {
                uint _S1574 = __ballot_sync(_S1383, false);
                uint _S1575 = __ballot_sync(_S1503, false);
                uint _S1576 = __ballot_sync(_S1379, true);
                cg_total_0 = _S1542;
                i_26 = _S1576;
                break;
            }
            else
            {
                uint _S1577 = __ballot_sync(_S1383, true);
                _S1570 = _S1577;
            }
            uint c_34 = _S1393;
            uint _S1578;
            _S1578 = _S1570;
            for(;;)
            {
                bool _S1579 = c_34 < c1_1;
                uint _S1580 = __ballot_sync(_S1578, _S1579);
                if(_S1579)
                {
                    uint _S1581 = __ballot_sync(_S1578, true);
                }
                else
                {
                    uint _S1582 = __ballot_sync(_S1578, false);
                    uint _S1583 = __ballot_sync(_S1578, false);
                    uint _S1584 = __ballot_sync(_S1570, true);
                    _S1384 = _S1584;
                    break;
                }
                precondition_0(c_34);
                uint _S1585 = __ballot_sync(_S1578, true);
                c_34 = c_34 + 256U;
                _S1578 = _S1585;
            }
            __syncthreads();
            uint _S1586 = __ballot_sync(_S1384, free_0);
            uint _S1587;
            if(free_0)
            {
                Island_0 _S1588 = isl_18;
                project_displacement_slot_0(tid_15, &_S1588, 6U, _S1586);
                uint _S1589 = __ballot_sync(_S1384, true);
                _S1587 = _S1589;
            }
            else
            {
                uint _S1590 = __ballot_sync(_S1384, true);
                _S1587 = _S1590;
            }
            float _S1591 = island_dot_0(tid_15, c0_1, c1_1, 4U, 6U, _S1587);
            float _S1592 = _S1591 / rz_0;
            uint c_35 = _S1393;
            uint _S1593 = _S1587;
            for(;;)
            {
                bool _S1594 = c_35 < c1_1;
                uint _S1595 = __ballot_sync(_S1593, _S1594);
                if(_S1594)
                {
                    uint _S1596 = __ballot_sync(_S1593, true);
                }
                else
                {
                    uint _S1597 = __ballot_sync(_S1593, false);
                    uint _S1598 = __ballot_sync(_S1593, false);
                    uint _S1599 = __ballot_sync(_S1587, true);
                    break;
                }
                uint _S1600 = sv_0(c_35, 8U);
                float4  _S1601 = *(&(globalParams_0->scratch_0)[sv_0(c_35, 6U)]);
                float4  _S1602 = *(&(globalParams_0->scratch_0)[_S1600]);
                *(&(globalParams_0->scratch_0)[_S1600]) = make_float4 ((float3 {_S1601.x, _S1601.y, _S1601.z} + make_float3 (_S1592) * float3 {_S1602.x, _S1602.y, _S1602.z}).x, (float3 {_S1601.x, _S1601.y, _S1601.z} + make_float3 (_S1592) * float3 {_S1602.x, _S1602.y, _S1602.z}).y, (float3 {_S1601.x, _S1601.y, _S1601.z} + make_float3 (_S1592) * float3 {_S1602.x, _S1602.y, _S1602.z}).z, 0.0f);
                uint _S1603 = sv_0(c_35, 9U);
                float4  _S1604 = *(&(globalParams_0->scratch_0)[sv_0(c_35, 7U)]);
                float4  _S1605 = *(&(globalParams_0->scratch_0)[_S1603]);
                *(&(globalParams_0->scratch_0)[_S1603]) = make_float4 ((float3 {_S1604.x, _S1604.y, _S1604.z} + make_float3 (_S1592) * float3 {_S1605.x, _S1605.y, _S1605.z}).x, (float3 {_S1604.x, _S1604.y, _S1604.z} + make_float3 (_S1592) * float3 {_S1605.x, _S1605.y, _S1605.z}).y, (float3 {_S1604.x, _S1604.y, _S1604.z} + make_float3 (_S1592) * float3 {_S1605.x, _S1605.y, _S1605.z}).z, 0.0f);
                uint _S1606 = __ballot_sync(_S1593, true);
                c_35 = c_35 + 256U;
                _S1593 = _S1606;
            }
            __syncthreads();
            uint _S1607 = __ballot_sync(_S1503, true);
            uint _S1608 = k_19 + 1U;
            rz_0 = _S1591;
            k_19 = _S1608;
            cg_total_1 = _S1542;
            _S1503 = _S1607;
        }
        c_27 = _S1393;
        _S1380 = i_26;
        for(;;)
        {
            bool _S1609 = c_27 < c1_1;
            uint _S1610 = __ballot_sync(_S1380, _S1609);
            if(_S1609)
            {
                uint _S1611 = __ballot_sync(_S1380, true);
            }
            else
            {
                uint _S1612 = __ballot_sync(_S1380, false);
                uint _S1613 = __ballot_sync(_S1380, false);
                uint _S1614 = __ballot_sync(i_26, true);
                break;
            }
            uint _S1615 = 4U * c_27;
            float4  _S1616 = *(&(globalParams_0->state_0)[_S1615]);
            float3  u_1 = float3 {_S1616.x, _S1616.y, _S1616.z};
            uint _S1617 = sv_0(c_27, 21U);
            float4  _S1618 = *(&(globalParams_0->scratch_0)[_S1617]);
            float3  u_lo_0 = float3 {_S1618.x, _S1618.y, _S1618.z};
            uint _S1619 = _S1615 + 1U;
            float4  _S1620 = *(&(globalParams_0->state_0)[_S1619]);
            float3  th_3 = float3 {_S1620.x, _S1620.y, _S1620.z};
            uint _S1621 = sv_0(c_27, 22U);
            float4  _S1622 = *(&(globalParams_0->scratch_0)[_S1621]);
            float3  th_lo_0 = float3 {_S1622.x, _S1622.y, _S1622.z};
            float4  _S1623 = *(&(globalParams_0->scratch_0)[sv_0(c_27, 2U)]);
            comp_add_0(&u_1, &u_lo_0, float3 {_S1623.x, _S1623.y, _S1623.z});
            float4  _S1624 = *(&(globalParams_0->scratch_0)[sv_0(c_27, 3U)]);
            comp_add_0(&th_3, &th_lo_0, float3 {_S1624.x, _S1624.y, _S1624.z});
            *(&(globalParams_0->state_0)[_S1615]) = make_float4 (u_1.x, u_1.y, u_1.z, (*(&(globalParams_0->state_0)[_S1615])).w);
            *(&(globalParams_0->state_0)[_S1619]) = make_float4 (th_3.x, th_3.y, th_3.z, (*(&(globalParams_0->state_0)[_S1619])).w);
            *(&(globalParams_0->scratch_0)[_S1617]) = make_float4 (u_lo_0.x, u_lo_0.y, u_lo_0.z, 0.0f);
            *(&(globalParams_0->scratch_0)[_S1621]) = make_float4 (th_lo_0.x, th_lo_0.y, th_lo_0.z, 0.0f);
            uint _S1625 = __ballot_sync(_S1380, true);
            c_27 = c_27 + 256U;
            _S1380 = _S1625;
        }
        __syncthreads();
        uint _S1626 = newton_0 + 1U;
        uint _S1627 = __ballot_sync(c_28, true);
        previous_2 = residual_1;
        residual_0 = residual_1;
        newton_0 = _S1626;
        c_28 = _S1627;
    }
    i_25 = b0_0 + tid_15;
    for(;;)
    {
        if(i_25 < _S1392)
        {
        }
        else
        {
            break;
        }
        JointResponse_0 resp_2 = static_response_0(i_25);
        BondDyn_0 bd_1 = *(&(globalParams_0->bond_dyn_0)[i_25]);
        (&bd_1)->force_lin_0 = make_float4 (resp_2.force_lin_1.x, resp_2.force_lin_1.y, resp_2.force_lin_1.z, resp_2.stored_3);
        (&bd_1)->force_ang_0 = make_float4 (resp_2.force_ang_1.x, resp_2.force_ang_1.y, resp_2.force_ang_1.z, (&bd_1)->force_ang_0.w);
        *(&(globalParams_0->bond_dyn_0)[i_25]) = bd_1;
        write_bond_loads_0(i_25, i_25, resp_2.force_lin_1, resp_2.force_ang_1, (F32_max((resp_2.measures_0.tension_0), (resp_2.measures_0.compression_0))));
        i_25 = i_25 + 256U;
    }
    __syncthreads();
    c_27 = _S1393;
    for(;;)
    {
        if(c_27 < c1_1)
        {
        }
        else
        {
            break;
        }
        float3  fi_4;
        float3  mi_3;
        gather_loads_0(c_27, &fi_4, &mi_3);
        float3  reaction_0;
        if((fixed_mask_0(c_27)) != 0U)
        {
            float4  _S1628 = *(&(globalParams_0->scratch_0)[sv_0(c_27, 0U)]);
            reaction_0 = - (float3 {_S1628.x, _S1628.y, _S1628.z} + fi_4);
        }
        else
        {
            uint _S1629 = 4U * c_27;
            reaction_0 = make_float3 ((*(&(globalParams_0->state_0)[_S1629 + 1U])).w, (*(&(globalParams_0->state_0)[_S1629 + 2U])).w, (*(&(globalParams_0->state_0)[_S1629 + 3U])).w);
        }
        uint _S1630 = 4U * c_27;
        uint _S1631 = _S1630 + 1U;
        float4  _S1632 = *(&(globalParams_0->state_0)[_S1631]);
        *(&(globalParams_0->state_0)[_S1631]) = make_float4 (float3 {_S1632.x, _S1632.y, _S1632.z}.x, float3 {_S1632.x, _S1632.y, _S1632.z}.y, float3 {_S1632.x, _S1632.y, _S1632.z}.z, reaction_0.x);
        *(&(globalParams_0->state_0)[_S1630 + 2U]) = make_float4 (0.0f, 0.0f, 0.0f, reaction_0.y);
        *(&(globalParams_0->state_0)[_S1630 + 3U]) = make_float4 (0.0f, 0.0f, 0.0f, reaction_0.z);
        c_27 = c_27 + 256U;
    }
    if(tid_15 == 0U)
    {
        float4  * _S1633 = (&(globalParams_0->scratch_0)[statics_result_slot_0(_S1386)]);
        float _S1634 = (U32_asfloat((newton_0)));
        float _S1635 = (U32_asfloat((cg_total_0)));
        if(converged_0)
        {
            previous_2 = 1.0f;
        }
        else
        {
            previous_2 = 0.0f;
        }
        *_S1633 = make_float4 (residual_0, _S1634, _S1635, previous_2);
        *&((&(&(globalParams_0->islands_0)[_S1386])->info_1)->z) = _S1388 & 4294967287U;
    }
    return;
}

__device__ __shared__ uint g_halt_0;

__device__ __shared__ uint g_run_0;

extern "C" __global__ void settled_fatigue()
{
    uint tid_16 = threadIdx.x;
    uint _S1636 = blockIdx.x;
    Island_0 * _S1637 = (&(globalParams_0->islands_0)[_S1636]);
    Island_0 isl_19 = *_S1637;
    bool _S1638;
    if((((*_S1637).info_1.x) & 16U) == 0U)
    {
        _S1638 = true;
    }
    else
    {
        _S1638 = (isl_19.range_0.w) == (isl_19.range_0.z);
    }
    if(_S1638)
    {
        return;
    }
    seen_clear_0(tid_16);
    if(tid_16 == 0U)
    {
        *&g_halt_0 = 0U;
        *&g_run_0 = 0U;
    }
    __syncthreads();
    uint _S1639 = isl_19.info_1.w;
    uint i_28 = isl_19.range_0.z + tid_16;
    for(;;)
    {
        if(i_28 < (isl_19.range_0.w))
        {
        }
        else
        {
            break;
        }
        BondStatic_0 * _S1640 = (&(globalParams_0->bonds_0)[i_28]);
        BondDyn_0 bd_2 = *(&(globalParams_0->bond_dyn_0)[i_28]);
        JointBond_0 _S1641 = slang_ldg_0(&_S1640->law_0);
        uint _S1642 = 4U * _S1641.ids_0.y;
        float4  _S1643 = *(&(globalParams_0->state_0)[_S1642]);
        float4  _S1644 = *(&(globalParams_0->state_0)[_S1642 + 1U]);
        uint _S1645 = 4U * _S1641.ids_0.z;
        float4  _S1646 = *(&(globalParams_0->state_0)[_S1645]);
        float4  _S1647 = *(&(globalParams_0->state_0)[_S1645 + 1U]);
        float3  d_lin_7;
        float3  d_ang_6;
        bond_kinematics_0(i_28, float3 {_S1643.x, _S1643.y, _S1643.z}, float3 {_S1644.x, _S1644.y, _S1644.z}, float3 {_S1646.x, _S1646.y, _S1646.z}, float3 {_S1647.x, _S1647.y, _S1647.z}, &d_lin_7, &d_ang_6);
        JointState_0 previous_3 = (&bd_2)->js_0;
        float3  _S1648 = d_lin_7;
        float3  _S1649 = d_ang_6;
        float _S1650 = __ldg(&globalParams_0->params_0->dt_0);
        uint _S1651 = __ldg(&globalParams_0->params_0->fracture_0);
        bool _S1652 = _S1651 != 0U;
        JointBond_0 _S1653 = _S1641;
        JointState_0 _S1654 = previous_3;
        JointResponse_0 _S1655 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S1641.ids_0.x], &_S1653, &_S1654, _S1648, _S1649, _S1650, _S1652);
        if((_S1655.state_1.damage_0) > (previous_3.damage_0 + 9.99999971718068537e-10f))
        {
            _S1638 = true;
        }
        else
        {
            _S1638 = (_S1655.state_1.crush_0) > (previous_3.crush_0 + 9.99999971718068537e-10f);
        }
        uint flags_3;
        if(_S1638)
        {
            flags_3 = 16U;
        }
        else
        {
            flags_3 = 0U;
        }
        comp_add1_0(&((&(&bd_2)->sums_0)->x), &((&(&bd_2)->comps_0)->x), _S1655.dissipated_2);
        comp_add1_0(&((&(&bd_2)->sums_0)->y), &((&(&bd_2)->comps_0)->y), _S1655.overshoot_0);
        (&bd_2)->force_lin_0 = make_float4 (_S1655.force_lin_1.x, _S1655.force_lin_1.y, _S1655.force_lin_1.z, _S1655.stored_3);
        (&bd_2)->force_ang_0 = make_float4 (_S1655.force_ang_1.x, _S1655.force_ang_1.y, _S1655.force_ang_1.z, (F32_max(((&bd_2)->force_ang_0.w), (_S1655.state_1.utilization_0))));
        JointState_0 _S1656 = previous_3;
        bool _S1657 = is_damaged_0(&_S1656);
        bool _S1658;
        if(!_S1657)
        {
            JointState_0 _S1659 = _S1655.state_1;
            bool _S1660 = is_damaged_0(&_S1659);
            _S1658 = _S1660;
        }
        else
        {
            _S1658 = false;
        }
        bool _S1661;
        if(_S1658)
        {
            _S1661 = ((&bd_2)->events_0.x) == 0U;
        }
        else
        {
            _S1661 = false;
        }
        if(_S1661)
        {
            *&((&(&bd_2)->events_0)->x) = _S1639;
            *&((&(&bd_2)->events_0)->w) = _S1655.state_1.mode_0;
            (*&g_seen_0)[3U] = 1U;
        }
        bool _S1662;
        if(((&bd_2)->events_0.y) == 0U)
        {
            _S1662 = (_S1655.state_1.life_0) != (previous_3.life_0);
        }
        else
        {
            _S1662 = false;
        }
        bool _S1663;
        if(_S1662)
        {
            _S1663 = (_S1655.fatigue_before_0) > 0.99000000953674316f;
        }
        else
        {
            _S1663 = false;
        }
        bool _S1664;
        if(_S1663)
        {
            float _S1665 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S1641.ids_0.x], _S1655.state_1.life_0);
            _S1664 = _S1665 <= 0.99000000953674316f;
        }
        else
        {
            _S1664 = false;
        }
        if(_S1664)
        {
            *&((&(&bd_2)->events_0)->y) = _S1639;
            (*&g_seen_0)[4U] = 1U;
        }
        uint flags_4;
        if(_S1655.disconnected_0)
        {
            *&((&(&bd_2)->events_0)->z) = _S1639;
            flags_4 = flags_3 | 32U;
        }
        else
        {
            flags_4 = flags_3;
        }
        (&bd_2)->js_0 = _S1655.state_1;
        *(&(globalParams_0->bond_dyn_0)[i_28]) = bd_2;
        write_bond_loads_0(i_28, i_28, _S1655.force_lin_1, _S1655.force_ang_1, (F32_max((_S1655.measures_0.tension_0), (_S1655.measures_0.compression_0))));
        if((flags_4 & 16U) != 0U)
        {
            *&g_halt_0 = 1U;
        }
        if((flags_4 & 32U) != 0U)
        {
            *&g_run_0 = 1U;
        }
        i_28 = i_28 + 256U;
    }
    __syncthreads();
    if(tid_16 != 0U)
    {
        return;
    }
    if(((*&g_halt_0) | (*&g_run_0)) != 0U)
    {
        uint _S1666 = isl_19.info_1.z;
        if((*&g_halt_0) != 0U)
        {
            i_28 = 16U;
        }
        else
        {
            i_28 = 0U;
        }
        uint _S1667 = _S1666 | i_28;
        if((*&g_run_0) != 0U)
        {
            i_28 = 32U;
        }
        else
        {
            i_28 = 0U;
        }
        *&((&(&(globalParams_0->islands_0)[_S1636])->info_1)->z) = _S1667 | i_28;
    }
    uint _S1668 = ((isl_19.coverage_0) | 16384U) | (seen_bits_0());
    if((*&g_run_0) != 0U)
    {
        i_28 = 128U;
    }
    else
    {
        i_28 = 0U;
    }
    (&(globalParams_0->islands_0)[_S1636])->coverage_0 = _S1668 | i_28;
    return;
}

static __device__ void impactor_integrate_at_0(uint ii_2, uint tid_17, uint _S1669)
{
    uint _S1670 = 0U;
    uint _S1671;
    float3  p_15;
    uint _S1672 = __ldg(&globalParams_0->params_0->impactor_count_0);
    bool _S1673 = ii_2 >= _S1672;
    uint _S1674 = __ballot_sync(_S1669, _S1673);
    if(_S1673)
    {
        return;
    }
    else
    {
        uint _S1675 = __ballot_sync(_S1669, true);
        _S1670 = _S1675;
    }
    uint _S1676 = __ldg(&globalParams_0->params_0->halt_index_0);
    Island_0 * _S1677 = (&(globalParams_0->islands_0)[_S1676]);
    Impactor_0 imp_6 = *(&(globalParams_0->impactors_0)[ii_2]);
    uint4  _S1678 = _S1677->info_1;
    bool _S1679 = ((_S1677->info_1.z) & 1U) != 0U;
    uint _S1680 = __ballot_sync(_S1670, _S1679);
    bool _S1681;
    uint k_20;
    if(_S1679)
    {
        uint _S1682 = __ballot_sync(_S1670, true);
        _S1681 = true;
        k_20 = _S1682;
    }
    else
    {
        uint _S1683 = _S1670 & (~_S1680);
        uint _S1684 = _S1678.y;
        bool _S1685 = _S1684 != 0U;
        uint _S1686 = __ballot_sync(_S1683, _S1685);
        if(_S1685)
        {
            bool _S1687 = ((&imp_6)->cand_0.w) >= _S1684;
            uint _S1688 = __ballot_sync(_S1683, true);
            _S1681 = _S1687;
        }
        else
        {
            uint _S1689 = __ballot_sync(_S1683, true);
            _S1681 = false;
        }
        uint _S1690 = __ballot_sync(_S1670, true);
        k_20 = _S1690;
    }
    uint _S1691 = 0U;
    uint _S1692 = __ballot_sync(k_20, _S1681);
    if(_S1681)
    {
        return;
    }
    else
    {
        uint _S1693 = __ballot_sync(k_20, true);
        _S1691 = _S1693;
    }
    uint _S1694 = 0U;
    bool _S1695 = ((&imp_6)->cand_0.z) != 0U;
    uint _S1696 = __ballot_sync(_S1691, _S1695);
    if(_S1695)
    {
        if(tid_17 == 0U)
        {
            *&((&(&(globalParams_0->impactors_0)[ii_2])->cand_0)->w) = (&imp_6)->cand_0.w + 1U;
        }
        return;
    }
    else
    {
        uint _S1697 = __ballot_sync(_S1691, true);
        _S1694 = _S1697;
    }
    float4  _S1698 = make_float4 (0.0f);
    float4  rf_1 = _S1698;
    float4  rt_0 = _S1698;
    k_20 = (&imp_6)->cand_0.x + tid_17;
    uint total_points_0;
    total_points_0 = _S1694;
    for(;;)
    {
        bool _S1699 = k_20 < ((&imp_6)->cand_0.y);
        uint _S1700 = __ballot_sync(total_points_0, _S1699);
        if(_S1699)
        {
            uint _S1701 = __ballot_sync(total_points_0, true);
        }
        else
        {
            uint _S1702 = __ballot_sync(total_points_0, false);
            uint _S1703 = __ballot_sync(total_points_0, false);
            uint _S1704 = __ballot_sync(_S1694, true);
            _S1671 = _S1704;
            break;
        }
        uint _S1705 = __ldg(&globalParams_0->params_0->cand_base_0);
        uint _S1706 = 3U * k_20;
        rf_1 = rf_1 + *(&(globalParams_0->scratch_0)[_S1705 + _S1706 + 1U]);
        uint _S1707 = __ldg(&globalParams_0->params_0->cand_base_0);
        rt_0 = rt_0 + *(&(globalParams_0->scratch_0)[_S1707 + _S1706 + 2U]);
        uint _S1708 = __ballot_sync(total_points_0, true);
        k_20 = k_20 + 256U;
        total_points_0 = _S1708;
    }
    group_sum2_0(tid_17, &rf_1, &rt_0, _S1671);
    bool _S1709 = tid_17 != 0U;
    uint _S1710 = __ballot_sync(_S1671, _S1709);
    if(_S1709)
    {
        return;
    }
    float _S1711 = __ldg(&globalParams_0->params_0->dt_0);
    float3  _S1712 = make_float3 (0.0f);
    uint _S1713 = __ldg(&globalParams_0->params_0->has_ground_0);
    float3  load_f_0;
    float3  load_t_0;
    if(_S1713 != 0U)
    {
        float4  _S1714 = (&imp_6)->half_1;
        float3  _S1715 = float3 {_S1714.x, _S1714.y, _S1714.z};
        Impactor_0 _S1716 = imp_6;
        Box_0 _S1717 = impactor_box_0(&_S1716, _S1712, _S1715);
        float4  _S1718 = (&imp_6)->velocity_1;
        float4  _S1719 = (&imp_6)->velocity_err_1;
        float3  _S1720 = float3 {_S1718.x, _S1718.y, _S1718.z} + float3 {_S1719.x, _S1719.y, _S1719.z};
        float _S1721 = __ldg(&globalParams_0->params_0->ground_modulus_0);
        float _S1722 = (&imp_6)->mat_0.x;
        float3  _S1723 = make_float3 (0.0f, 0.0f, 1.0f);
        Box_0 _S1724 = _S1717;
        Box_0 _S1725 = _S1717;
        float _S1726 = contact_stiffness_0(_S1721, &_S1724, _S1722, &_S1725, _S1723);
        float _S1727 = (&imp_6)->position_1.z;
        float _S1728 = __ldg(&globalParams_0->params_0->ground_hi_0);
        float _S1729 = _S1727 - _S1728;
        float _S1730 = (&imp_6)->position_err_1.z;
        float _S1731 = __ldg(&globalParams_0->params_0->ground_lo_0);
        float _S1732 = _S1729 + (_S1730 - _S1731);
        if(((&imp_6)->shape_0.x) == 0.0f)
        {
            total_points_0 = 1U;
        }
        else
        {
            total_points_0 = 14U;
        }
        float _S1733 = _S1726 / float((U32_min((total_points_0), (5U))));
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
                p_15 = make_float3 (0.0f, 0.0f, - (&imp_6)->shape_0.y);
            }
            else
            {
                Box_0 _S1734 = _S1717;
                float3  _S1735 = sample_point_0(&_S1734, s_11);
                p_15 = _S1735;
            }
            if((_S1732 + p_15.z) < 0.0f)
            {
                below_0 = below_0 + 1U;
            }
            s_11 = s_11 + 1U;
        }
        if(below_0 > 0U)
        {
            sentinel_mark_0(8U);
        }
        s_11 = 0U;
        load_f_0 = _S1712;
        load_t_0 = _S1712;
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
                p_15 = make_float3 (0.0f, 0.0f, - (&imp_6)->shape_0.y);
            }
            else
            {
                Box_0 _S1736 = _S1717;
                float3  _S1737 = sample_point_0(&_S1736, s_11);
                p_15 = _S1737;
            }
            float depth_3 = - (_S1732 + p_15.z);
            if(depth_3 <= 0.0f)
            {
                s_11 = s_11 + 1U;
                continue;
            }
            float4  _S1738 = (&imp_6)->angular_velocity_1;
            float3  v_9 = _S1720 + cross_0(float3 {_S1738.x, _S1738.y, _S1738.z}, p_15);
            float _S1739 = (&imp_6)->mat_0.z;
            float _S1740 = __ldg(&globalParams_0->params_0->ground_friction_0);
            float stored_7;
            float diss_5;
            float3  f_14 = penalty_force_0(_S1733, _S1739, _S1740, depth_3, _S1723, v_9, _S1711, below_0, &stored_7, &diss_5);
            float3  load_f_1 = load_f_0 + f_14;
            float3  load_t_1 = load_t_0 + cross_0(p_15, f_14);
            comp_add1_0(&((&(&imp_6)->ledger_0)->x), &((&(&imp_6)->ledger_0)->y), diss_5);
            load_f_0 = load_f_1;
            load_t_0 = load_t_1;
            s_11 = s_11 + 1U;
        }
    }
    else
    {
        load_f_0 = _S1712;
        load_t_0 = _S1712;
    }
    float4  _S1741 = rf_1;
    float3  load_f_2 = float3 {_S1741.x, _S1741.y, _S1741.z} + load_f_0;
    float4  _S1742 = rt_0;
    float3  load_t_2 = float3 {_S1742.x, _S1742.y, _S1742.z} + load_t_0;
    float m_6 = (&imp_6)->mat_0.z;
    float4  _S1743 = (&imp_6)->velocity_1;
    float3  vel_2 = float3 {_S1743.x, _S1743.y, _S1743.z};
    float4  _S1744 = (&imp_6)->velocity_err_1;
    float3  vel_err_1 = float3 {_S1744.x, _S1744.y, _S1744.z};
    float3  _S1745 = load_f_2 / make_float3 (m_6);
    float4  _S1746 = __ldg(&globalParams_0->params_0->gravity_0);
    comp_add_0(&vel_2, &vel_err_1, (_S1745 + float3 {_S1746.x, _S1746.y, _S1746.z}) * make_float3 (_S1711));
    Quat_0 _S1747 = quat_of_0((&imp_6)->rotation_1);
    Quat_0 q_13 = _S1747;
    float4  q_err_0 = (&imp_6)->rotation_err_1;
    float4  _S1748 = (&imp_6)->momentum_1;
    float3  l_hi_0 = float3 {_S1748.x, _S1748.y, _S1748.z};
    float4  _S1749 = (&imp_6)->momentum_err_1;
    float3  l_err_1 = float3 {_S1749.x, _S1749.y, _S1749.z};
    comp_add_0(&l_hi_0, &l_err_1, load_t_2 * make_float3 (_S1711));
    float3  l_5 = l_hi_0 + l_err_1;
    Quat_0 _S1750 = _S1747;
    float3  _S1751 = world_mul_0(&_S1750, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_5);
    float4  _S1752 = (&imp_6)->position_1;
    float3  pos_1 = float3 {_S1752.x, _S1752.y, _S1752.z};
    float4  _S1753 = (&imp_6)->position_err_1;
    float3  pos_err_1 = float3 {_S1753.x, _S1753.y, _S1753.z};
    comp_add_0(&pos_1, &pos_err_1, (vel_2 + vel_err_1) * make_float3 (_S1711));
    turn_left_0(&q_13, &q_err_0, _S1751, _S1711);
    Quat_0 _S1754 = q_13;
    float3  _S1755 = world_mul_0(&_S1754, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_5);
    (&imp_6)->angular_velocity_1 = make_float4 (_S1755.x, _S1755.y, _S1755.z, 0.0f);
    Quat_0 _S1756 = q_13;
    float4  _S1757 = quat_vec_0(&_S1756);
    (&imp_6)->rotation_1 = _S1757;
    (&imp_6)->rotation_err_1 = q_err_0;
    (&imp_6)->momentum_1 = make_float4 (l_hi_0.x, l_hi_0.y, l_hi_0.z, 0.0f);
    (&imp_6)->momentum_err_1 = make_float4 (l_err_1.x, l_err_1.y, l_err_1.z, 0.0f);
    (&imp_6)->position_1 = make_float4 (pos_1.x, pos_1.y, pos_1.z, 0.0f);
    (&imp_6)->position_err_1 = make_float4 (pos_err_1.x, pos_err_1.y, pos_err_1.z, 0.0f);
    (&imp_6)->velocity_1 = make_float4 (vel_2.x, vel_2.y, vel_2.z, 0.0f);
    (&imp_6)->velocity_err_1 = make_float4 (vel_err_1.x, vel_err_1.y, vel_err_1.z, 0.0f);
    *&((&(&imp_6)->cand_0)->w) = *&((&(&imp_6)->cand_0)->w) + 1U;
    (&imp_6)->geom_0 = make_float4 (1.0f, (&imp_6)->crush_1.w, 0.0f, 0.0f);
    *(&(globalParams_0->impactors_0)[ii_2]) = imp_6;
    uint _S1758 = (&imp_6)->cand_0.w - 1U;
    uint _S1759 = __ldg(&globalParams_0->params_0->step_start_0);
    uint k_21 = _S1758 - _S1759;
    uint _S1760 = __ldg(&globalParams_0->params_0->record_stride_0);
    if(k_21 < _S1760)
    {
        uint _S1761 = __ldg(&globalParams_0->params_0->record_base_0);
        uint _S1762 = __ldg(&globalParams_0->params_0->record_stride_0);
        uint at_6 = _S1761 + 2U * (ii_2 * _S1762 + k_21);
        *(&(globalParams_0->scratch_0)[at_6]) = make_float4 ((vel_2 + vel_err_1).x, (vel_2 + vel_err_1).y, (vel_2 + vel_err_1).z, 0.0f);
        *(&(globalParams_0->scratch_0)[at_6 + 1U]) = make_float4 ((pos_1 + pos_err_1).x, (pos_1 + pos_err_1).y, (pos_1 + pos_err_1).z, 0.0f);
    }
    return;
}

extern "C" __global__ void impactor_integrate()
{
    uint _S1763 = __ballot_sync(4294967295U, true);
    impactor_integrate_at_0(blockIdx.x, threadIdx.x, _S1763);
    return;
}

static __device__ void ground_contact_0(uint c_36, bool account_0, float3  * f_15, float3  * t_14)
{
    ChunkStatic_0 * _S1764 = (&(globalParams_0->chunks_0)[c_36]);
    WorldPoint_0 wp_1 = chunk_world_0(c_36);
    float _S1765 = wp_1.hi_0.z;
    float _S1766 = __ldg(&globalParams_0->params_0->ground_hi_0);
    float _S1767 = _S1765 - _S1766;
    float _S1768 = wp_1.lo_0.z;
    float _S1769 = __ldg(&globalParams_0->params_0->ground_lo_0);
    float above_0 = _S1767 + (_S1768 - _S1769) + wp_1.rel_0.z;
    float4  _S1770 = __ldg(&_S1764->half_0);
    if((above_0 - _S1770.w) > 0.0f)
    {
        return;
    }
    Box_0 b_31 = chunk_box_0(c_36, make_float3 (0.0f));
    float _S1771 = __ldg(&globalParams_0->params_0->ground_modulus_0);
    float4  _S1772 = __ldg(&_S1764->cmat_0);
    float _S1773 = _S1772.x;
    float3  _S1774 = make_float3 (0.0f, 0.0f, 1.0f);
    Box_0 _S1775 = b_31;
    Box_0 _S1776 = b_31;
    float _S1777 = contact_stiffness_0(_S1771, &_S1775, _S1773, &_S1776, _S1774);
    Box_0 _S1778 = b_31;
    uint _S1779 = sample_count_0(&_S1778);
    uint s_12 = 0U;
    uint n_7 = 0U;
    for(;;)
    {
        if(s_12 < _S1779)
        {
        }
        else
        {
            break;
        }
        Box_0 _S1780 = b_31;
        float3  _S1781 = sample_point_0(&_S1780, s_12);
        if((above_0 + _S1781.z) < 0.0f)
        {
            n_7 = n_7 + 1U;
        }
        s_12 = s_12 + 1U;
    }
    if(n_7 == 0U)
    {
        return;
    }
    sentinel_mark_0(4U);
    float3  vc_1;
    float3  wc_1;
    chunk_velocity_0(c_36, &vc_1, &wc_1);
    uint _S1782 = __ldg(&globalParams_0->params_0->ledger_base_0);
    uint _S1783 = __ldg(&globalParams_0->params_0->pair_count_0);
    float4  ledger_2 = *(&(globalParams_0->scratch_0)[_S1782 + _S1783 + c_36]);
    s_12 = 0U;
    for(;;)
    {
        if(s_12 < _S1779)
        {
        }
        else
        {
            break;
        }
        Box_0 _S1784 = b_31;
        float3  _S1785 = sample_point_0(&_S1784, s_12);
        float _S1786 = above_0 + _S1785.z;
        if(!(_S1786 < 0.0f))
        {
            s_12 = s_12 + 1U;
            continue;
        }
        float depth_4 = - _S1786;
        float3  v_10 = vc_1 + cross_0(wc_1, _S1785);
        float _S1787 = _S1777 / float((U32_max((n_7), (5U))));
        float4  _S1788 = __ldg(&_S1764->center_0);
        float _S1789 = _S1788.w;
        float _S1790 = __ldg(&globalParams_0->params_0->ground_friction_0);
        float _S1791 = __ldg(&globalParams_0->params_0->dt_0);
        float stored_8;
        float diss_6;
        float3  g_2 = penalty_force_0(_S1787, _S1789, _S1790, depth_4, _S1774, v_10, _S1791, n_7, &stored_8, &diss_6);
        *f_15 = *f_15 + g_2;
        *t_14 = *t_14 + cross_0(_S1785, g_2);
        comp_add1_0(&((&ledger_2)->y), &((&ledger_2)->z), diss_6);
        s_12 = s_12 + 1U;
    }
    if(account_0)
    {
        uint _S1792 = __ldg(&globalParams_0->params_0->ledger_base_0);
        uint _S1793 = __ldg(&globalParams_0->params_0->pair_count_0);
        *(&(globalParams_0->scratch_0)[_S1792 + _S1793 + c_36]) = ledger_2;
    }
    return;
}

static __device__ void contact_sum_at_0(uint g_3)
{
    uint _S1794 = __ldg(&globalParams_0->params_0->seg_count_0);
    bool _S1795;
    if(g_3 >= _S1794)
    {
        _S1795 = true;
    }
    else
    {
        _S1795 = stopped_0();
    }
    if(_S1795)
    {
        return;
    }
    uint _S1796 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S1797 = 3U * g_3;
    uint _S1798 = __ldg((&(globalParams_0->index_0)[_S1796 + _S1797]));
    uint _S1799 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S1800 = __ldg((&(globalParams_0->index_0)[_S1799 + _S1797 + 1U]));
    uint _S1801 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S1802 = __ldg((&(globalParams_0->index_0)[_S1801 + _S1797 + 2U]));
    float3  _S1803 = make_float3 (0.0f);
    float3  f_16 = _S1803;
    float3  t_15 = _S1803;
    uint e_5 = _S1800;
    for(;;)
    {
        if(e_5 < _S1802)
        {
        }
        else
        {
            break;
        }
        uint _S1804 = __ldg((&(globalParams_0->index_0)[e_5]));
        if(_S1804 == 2147483648U)
        {
            ground_contact_0(_S1798, true, &f_16, &t_15);
            e_5 = e_5 + 1U;
            continue;
        }
        uint _S1805 = __ldg(&globalParams_0->params_0->slot_base_0);
        uint _S1806 = 2U * _S1804;
        float4  _S1807 = *(&(globalParams_0->scratch_0)[_S1805 + _S1806]);
        f_16 = f_16 + float3 {_S1807.x, _S1807.y, _S1807.z};
        uint _S1808 = __ldg(&globalParams_0->params_0->slot_base_0);
        float4  _S1809 = *(&(globalParams_0->scratch_0)[_S1808 + _S1806 + 1U]);
        t_15 = t_15 + float3 {_S1809.x, _S1809.y, _S1809.z};
        e_5 = e_5 + 1U;
    }
    uint _S1810 = __ldg(&globalParams_0->params_0->seg_base_0);
    uint _S1811 = 2U * g_3;
    *(&(globalParams_0->scratch_0)[_S1810 + _S1811]) = make_float4 (f_16.x, f_16.y, f_16.z, 0.0f);
    uint _S1812 = __ldg(&globalParams_0->params_0->seg_base_0);
    *(&(globalParams_0->scratch_0)[_S1812 + _S1811 + 1U]) = make_float4 (t_15.x, t_15.y, t_15.z, 0.0f);
    return;
}

extern "C" __global__ void contact_sums()
{
    contact_sum_at_0((blockIdx * blockDim + threadIdx).x);
    return;
}

static __device__ void chunk_update_0(uint c_37, Island_0 * isl_20, Rigid_0 * rg_8, float dt_11, bool rml_0, uint step_0, bool contact_3, float * work_2, float * work_err_0)
{
    ChunkStatic_0 * _S1813 = (&(globalParams_0->chunks_0)[c_37]);
    float3  _S1814 = make_float3 (0.0f);
    uint _S1815 = __ldg((&(globalParams_0->index_0)[c_37]));
    float peak_0 = 0.0f;
    uint e_6 = _S1815;
    float3  fi_5 = _S1814;
    float3  mi_4 = _S1814;
    for(;;)
    {
        uint _S1816 = __ldg((&(globalParams_0->index_0)[c_37 + 1U]));
        if(e_6 < _S1816)
        {
        }
        else
        {
            break;
        }
        uint _S1817 = __ldg((&(globalParams_0->index_0)[e_6]));
        uint _S1818 = 3U * (_S1817 >> int(1));
        float4  fa_2 = *(&(globalParams_0->scratch_0)[_S1818]);
        if((_S1817 & 1U) == 0U)
        {
            float4  _S1819 = *(&(globalParams_0->scratch_0)[_S1818 + 1U]);
            float3  mi_5 = mi_4 + float3 {_S1819.x, _S1819.y, _S1819.z};
            fi_5 = fi_5 + float3 {fa_2.x, fa_2.y, fa_2.z};
            mi_4 = mi_5;
        }
        else
        {
            float4  _S1820 = *(&(globalParams_0->scratch_0)[_S1818 + 2U]);
            float3  mi_6 = mi_4 + float3 {_S1820.x, _S1820.y, _S1820.z};
            fi_5 = fi_5 + - float3 {fa_2.x, fa_2.y, fa_2.z};
            mi_4 = mi_6;
        }
        float _S1821 = (F32_max((peak_0), (fa_2.w)));
        uint _S1822 = e_6 + 1U;
        peak_0 = _S1821;
        e_6 = _S1822;
    }
    uint _S1823 = 4U * c_37;
    float4  _S1824 = *(&(globalParams_0->state_0)[_S1823]);
    float3  u_2 = float3 {_S1824.x, _S1824.y, _S1824.z};
    uint _S1825 = _S1823 + 1U;
    float4  _S1826 = *(&(globalParams_0->state_0)[_S1825]);
    float3  th_4 = float3 {_S1826.x, _S1826.y, _S1826.z};
    uint _S1827 = _S1823 + 2U;
    float4  _S1828 = *(&(globalParams_0->state_0)[_S1827]);
    float3  v_11 = float3 {_S1828.x, _S1828.y, _S1828.z};
    uint _S1829 = _S1823 + 3U;
    float4  _S1830 = *(&(globalParams_0->state_0)[_S1829]);
    float3  w_6 = float3 {_S1830.x, _S1830.y, _S1830.z};
    float4  _S1831 = __ldg(&_S1813->center_0);
    float mass_0 = _S1831.w;
    float3  _S1832 = float3 {_S1831.x, _S1831.y, _S1831.z};
    float4  _S1833 = isl_20->com_0;
    float3  _S1834 = float3 {_S1833.x, _S1833.y, _S1833.z};
    float3  _S1835 = rotate_0(&rg_8->rot_1, _S1832 + u_2 - _S1834);
    float3  f_load_0;
    float3  t_load_0;
    float3  rep_f_1;
    float3  rep_m_1;
    chunk_loads_0(c_37, c_37, &rg_8->rot_1, step_0, dt_11, contact_3, dt_11, &f_load_0, &t_load_0, &rep_f_1, &rep_m_1);
    record_chunk_load_0(c_37, f_load_0, t_load_0);
    float3  _S1836 = f_load_0;
    float4  _S1837 = __ldg(&globalParams_0->params_0->gravity_0);
    float3  f_world_0 = _S1836 + float3 {_S1837.x, _S1837.y, _S1837.z} * make_float3 (mass_0);
    float3  t_world_0 = t_load_0;
    float3  f_world_1;
    float3  t_world_1;
    if(rml_0)
    {
        float3  _S1838 = rg_8->alpha_0;
        float3  _S1839 = rg_8->w_5;
        float3  f_world_2 = f_world_0 - (rg_8->a_13 + cross_0(rg_8->alpha_0, _S1835) + cross_0(rg_8->w_5, cross_0(rg_8->w_5, _S1835))) * make_float3 (mass_0);
        float4  _S1840 = __ldg(&_S1813->inertia0_0);
        float4  _S1841 = __ldg(&_S1813->inertia1_0);
        float4  _S1842 = __ldg(&_S1813->inertia2_0);
        float3  _S1843 = world_mul_0(&rg_8->rot_1, _S1840, _S1841, _S1842, _S1838);
        float3  _S1844 = world_mul_0(&rg_8->rot_1, _S1840, _S1841, _S1842, _S1839);
        float3  t_world_2 = t_world_0 - (_S1843 + cross_0(_S1839, _S1844));
        f_world_1 = f_world_2;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    float3  _S1845 = inverse_rotate_0(&rg_8->rot_1, f_world_1);
    float3  _S1846 = inverse_rotate_0(&rg_8->rot_1, t_world_1);
    float3  f_ext_0;
    float3  m_ext_0;
    if(rml_0)
    {
        float3  _S1847 = inverse_rotate_0(&rg_8->rot_1, rg_8->w_5);
        float3  f_ext_1 = _S1845 - cross_0(_S1847, v_11) * make_float3 (2.0f * mass_0);
        float4  _S1848 = __ldg(&_S1813->inertia0_0);
        float4  _S1849 = __ldg(&_S1813->inertia1_0);
        float4  _S1850 = __ldg(&_S1813->inertia2_0);
        float3  i_w_0 = rows_mul_0(_S1848, _S1849, _S1850, w_6);
        float3  m_ext_1 = _S1846 - (cross_0(_S1847, i_w_0) + cross_0(w_6, rows_mul_0(_S1848, _S1849, _S1850, _S1847)) + cross_0(w_6, i_w_0));
        f_ext_0 = f_ext_1;
        m_ext_0 = m_ext_1;
    }
    else
    {
        f_ext_0 = _S1845;
        m_ext_0 = _S1846;
    }
    float3  f_17 = f_ext_0 + rep_f_1 + fi_5;
    float3  m_7 = m_ext_0 + rep_m_1 + mi_4;
    uint4  _S1851 = __ldg(&_S1813->info_0);
    uint support_1 = _S1851.x;
    float3  _S1852 = make_float3 ((*(&(globalParams_0->state_0)[_S1825])).w, (*(&(globalParams_0->state_0)[_S1827])).w, (*(&(globalParams_0->state_0)[_S1829])).w);
    float3  reaction_1;
    float3  u_3;
    float3  th_5;
    float3  v_12;
    float3  w_7;
    if(support_1 == 1U)
    {
        reaction_1 = - f_17;
        u_3 = u_2;
        th_5 = th_4;
        v_12 = _S1814;
        w_7 = _S1814;
    }
    else
    {
        float4  _S1853 = __ldg(&_S1813->inv0_0);
        float4  _S1854 = __ldg(&_S1813->inv1_0);
        float4  _S1855 = __ldg(&_S1813->inv2_0);
        float3  _S1856 = rows_mul_0(_S1853, _S1854, _S1855, m_7);
        float4  _S1857 = __ldg(&_S1813->scale_0);
        float3  w_8 = w_6 + _S1856 * make_float3 (dt_11 * _S1857.z);
        float3  th_6 = th_4 + w_8 * make_float3 (dt_11);
        if(support_1 == 2U)
        {
            reaction_1 = - f_17;
            u_3 = u_2;
            th_5 = _S1814;
        }
        else
        {
            float3  v_13 = v_11 + f_17 * make_float3 (dt_11 * _S1857.y);
            float3  u_4 = u_2 + v_13 * make_float3 (dt_11);
            reaction_1 = _S1852;
            u_3 = u_4;
            th_5 = v_13;
        }
        float3  _S1858 = th_5;
        th_5 = th_6;
        v_12 = _S1858;
        w_7 = w_8;
    }
    *(&(globalParams_0->state_0)[_S1823]) = make_float4 (u_3.x, u_3.y, u_3.z, peak_0);
    *(&(globalParams_0->state_0)[_S1825]) = make_float4 (th_5.x, th_5.y, th_5.z, reaction_1.x);
    *(&(globalParams_0->state_0)[_S1827]) = make_float4 (v_12.x, v_12.y, v_12.z, reaction_1.y);
    *(&(globalParams_0->state_0)[_S1829]) = make_float4 (w_7.x, w_7.y, w_7.z, reaction_1.z);
    float3  _S1859 = rotate_0(&rg_8->rot_1, _S1832 + u_3 - _S1834);
    float3  _S1860 = rg_8->vel_0 + rg_8->vel_err_0 + cross_0(rg_8->w_5, _S1859);
    float3  _S1861 = rotate_0(&rg_8->rot_1, v_12);
    float3  v_world_0 = _S1860 + _S1861;
    float3  _S1862 = rotate_0(&rg_8->rot_1, w_7);
    comp_add1_0(work_2, work_err_0, (dot_0(f_load_0, v_world_0) + dot_0(t_load_0, rg_8->w_5 + _S1862)) * dt_11);
    return;
}

static __device__ void drift_moments_0(uint c_38, float3  * tu_2, float3  * pv_2)
{
    ChunkStatic_0 * _S1863 = (&(globalParams_0->chunks_0)[c_38]);
    float4  _S1864 = __ldg(&_S1863->center_0);
    float _S1865 = _S1864.w;
    float4  _S1866 = __ldg(&_S1863->scale_0);
    float m_8 = _S1865 * _S1866.x;
    uint _S1867 = 4U * c_38;
    float4  _S1868 = *(&(globalParams_0->state_0)[_S1867]);
    *tu_2 = *tu_2 + float3 {_S1868.x, _S1868.y, _S1868.z} * make_float3 (m_8);
    float4  _S1869 = *(&(globalParams_0->state_0)[_S1867 + 2U]);
    *pv_2 = *pv_2 + float3 {_S1869.x, _S1869.y, _S1869.z} * make_float3 (m_8);
    return;
}

static __device__ void island_frame_at_0(uint gi_0, uint tid_18, uint _S1870)
{
    bool woke_0;
    uint _S1871;
    uint _S1872;
    uint _S1873;
    uint _S1874;
    uint _S1875;
    uint _S1876;
    Island_0 isl_21 = *(&(globalParams_0->islands_0)[gi_0]);
    bool driven_0 = (((&isl_21)->info_1.x) & 2U) != 0U;
    bool _S1877 = !((((&isl_21)->info_1.x) & 1U) != 0U);
    uint _S1878 = __ballot_sync(_S1870, _S1877);
    bool _S1879;
    uint cov_2;
    if(_S1877)
    {
        bool _S1880 = !driven_0;
        uint _S1881 = __ballot_sync(_S1870, true);
        _S1879 = _S1880;
        cov_2 = _S1881;
    }
    else
    {
        uint _S1882 = __ballot_sync(_S1870, true);
        _S1879 = false;
        cov_2 = _S1882;
    }
    bool contact_island_0 = (((&isl_21)->info_1.x) & 4U) != 0U;
    bool _S1883 = (((&isl_21)->info_1.x) & 16U) != 0U;
    seen_clear_0(tid_18);
    bool _S1884 = tid_18 == 0U;
    uint _S1885 = __ballot_sync(cov_2, _S1884);
    bool settled_0;
    uint run_0;
    uint done_1;
    if(_S1884)
    {
        uint _S1886 = __ldg(&globalParams_0->params_0->contact_mode_0);
        bool _S1887 = contact_island_0 != (_S1886 == 1U);
        uint _S1888 = __ballot_sync(_S1885, _S1887);
        if(_S1887)
        {
            uint _S1889 = __ballot_sync(_S1885, true);
            settled_0 = true;
            run_0 = _S1889;
        }
        else
        {
            bool _S1890 = (((&isl_21)->info_1.x) & 8U) != 0U;
            uint _S1891 = __ballot_sync(_S1885, true);
            settled_0 = _S1890;
            run_0 = _S1891;
        }
        uint _S1892 = __ballot_sync(run_0, settled_0);
        if(settled_0)
        {
            uint _S1893 = __ballot_sync(run_0, true);
            run_0 = 0U;
            done_1 = _S1893;
        }
        else
        {
            uint _S1894 = __ballot_sync(run_0, true);
            run_0 = 1U;
            done_1 = _S1894;
        }
        uint _S1895 = __ballot_sync(done_1, contact_island_0);
        if(contact_island_0)
        {
            Island_0 _S1896 = isl_21;
            bool _S1897 = contact_stopped_0(&_S1896);
            uint _S1898 = __ballot_sync(done_1, true);
            settled_0 = _S1897;
            done_1 = _S1898;
        }
        else
        {
            uint _S1899 = __ballot_sync(done_1, true);
            settled_0 = false;
            done_1 = _S1899;
        }
        uint _S1900 = __ballot_sync(done_1, settled_0);
        if(settled_0)
        {
            uint _S1901 = __ballot_sync(done_1, true);
            run_0 = 0U;
        }
        else
        {
            uint _S1902 = __ballot_sync(done_1, true);
        }
        *&g_run_0 = run_0;
        *&g_halt_0 = 0U;
        uint _S1903 = __ballot_sync(cov_2, true);
        cov_2 = _S1903;
    }
    else
    {
        uint _S1904 = __ballot_sync(cov_2, true);
        cov_2 = _S1904;
    }
    __syncthreads();
    bool _S1905 = (((&isl_21)->info_1.z) & 1U) != 0U;
    uint _S1906 = __ballot_sync(cov_2, _S1905);
    if(_S1905)
    {
        uint _S1907 = __ballot_sync(cov_2, true);
        settled_0 = true;
        cov_2 = _S1907;
    }
    else
    {
        bool _S1908 = (*&g_run_0) == 0U;
        uint _S1909 = __ballot_sync(cov_2, true);
        settled_0 = _S1908;
        cov_2 = _S1909;
    }
    uint _S1910 = __ballot_sync(cov_2, settled_0);
    if(settled_0)
    {
        uint _S1911 = __ballot_sync(cov_2, true);
        cov_2 = 0U;
        run_0 = _S1911;
    }
    else
    {
        uint _S1912 = (&isl_21)->info_1.y;
        uint _S1913 = __ldg(&globalParams_0->params_0->max_steps_0);
        uint _S1914 = (U32_min((_S1912), (_S1913)));
        uint _S1915 = __ballot_sync(cov_2, true);
        cov_2 = _S1914;
        run_0 = _S1915;
    }
    float _S1916 = __ldg(&globalParams_0->params_0->dt_0);
    uint _S1917 = __ldg(&globalParams_0->params_0->fracture_0);
    bool _S1918 = _S1917 != 0U;
    uint _S1919 = __ldg(&globalParams_0->params_0->rigid_motion_loads_0);
    bool _S1920 = _S1919 != 0U;
    Island_0 _S1921 = isl_21;
    Rigid_0 _S1922 = rigid_of_0(&_S1921);
    Rigid_0 rg_9 = _S1922;
    float work_3 = 0.0f;
    float work_err_1 = 0.0f;
    settled_0 = _S1883;
    done_1 = 0U;
    bool woke_1 = false;
    uint _S1923 = run_0;
    for(;;)
    {
        uint _S1924 = 0U;
        bool _S1925 = done_1 < cov_2;
        uint _S1926 = __ballot_sync(_S1923, _S1925);
        if(_S1925)
        {
            uint _S1927 = __ballot_sync(_S1923, true);
            _S1924 = _S1927;
        }
        else
        {
            uint _S1928 = __ballot_sync(_S1923, false);
            uint _S1929 = __ballot_sync(_S1923, false);
            uint _S1930 = __ballot_sync(run_0, true);
            woke_0 = woke_1;
            cov_2 = _S1930;
            break;
        }
        uint abs_step_1 = (&isl_21)->info_1.w + done_1 + 1U;
        uint _S1931 = abs_step_1 - 1U;
        uint _S1932 = __ldg(&globalParams_0->params_0->step_start_0);
        uint k_22 = _S1931 - _S1932;
        bool quiet_0 = (((&isl_21)->info_1.x) & 32U) != 0U;
        uint _S1933 = __ballot_sync(_S1924, settled_0);
        bool _S1934;
        uint _S1935;
        if(settled_0)
        {
            bool _S1936 = !quiet_0;
            uint _S1937 = __ballot_sync(_S1924, true);
            _S1934 = _S1936;
            _S1935 = _S1937;
        }
        else
        {
            uint _S1938 = __ballot_sync(_S1924, true);
            _S1934 = false;
            _S1935 = _S1938;
        }
        uint _S1939 = __ballot_sync(_S1935, _S1934);
        bool _S1940;
        bool explicit_step_0;
        uint c_39;
        uint _S1941;
        uint c_40;
        if(_S1934)
        {
            float3  _S1942 = make_float3 (0.0f);
            float3  norm_1 = _S1942;
            float3  unused0_0 = _S1942;
            c_39 = (&isl_21)->range_0.x + tid_18;
            _S1941 = _S1939;
            for(;;)
            {
                bool _S1943 = c_39 < ((&isl_21)->range_0.y);
                uint _S1944 = __ballot_sync(_S1941, _S1943);
                if(_S1943)
                {
                    uint _S1945 = __ballot_sync(_S1941, true);
                }
                else
                {
                    uint _S1946 = __ballot_sync(_S1941, false);
                    uint _S1947 = __ballot_sync(_S1941, false);
                    uint _S1948 = __ballot_sync(_S1939, true);
                    _S1871 = _S1948;
                    break;
                }
                Quat_0 _S1949 = (&rg_9)->rot_1;
                float _S1950 = settled_chunk_load_0(c_39, &_S1949, k_22, _S1916, contact_island_0);
                *&((&norm_1)->x) = *&((&norm_1)->x) + _S1950;
                uint _S1951 = __ballot_sync(_S1941, true);
                c_39 = c_39 + 256U;
                _S1941 = _S1951;
            }
            group_sum3_0(tid_18, &norm_1, &unused0_0, _S1871);
            uint _S1952 = __ldg(&globalParams_0->params_0->solve_mode_0);
            bool _S1953 = _S1952 == 1U;
            uint _S1954 = __ballot_sync(_S1871, _S1953);
            if(_S1953)
            {
                bool _S1955 = (F32_abs((norm_1.x - (&isl_21)->energy_1.z))) > ((&isl_21)->energy_1.w);
                uint _S1956 = __ballot_sync(_S1871, true);
                _S1940 = _S1955;
                c_40 = _S1956;
            }
            else
            {
                uint _S1957 = __ballot_sync(_S1871, true);
                _S1940 = false;
                c_40 = _S1957;
            }
            uint _S1958 = __ballot_sync(c_40, _S1940);
            if(_S1940)
            {
                uint _S1959 = __ballot_sync(c_40, true);
                explicit_step_0 = false;
                woke_0 = true;
            }
            else
            {
                uint _S1960 = __ballot_sync(c_40, true);
                explicit_step_0 = settled_0;
                woke_0 = woke_1;
            }
            uint _S1961 = __ballot_sync(_S1935, true);
            settled_0 = explicit_step_0;
            c_39 = _S1961;
        }
        else
        {
            uint _S1962 = __ballot_sync(_S1935, true);
            woke_0 = woke_1;
            c_39 = _S1962;
        }
        uint _S1963 = __ballot_sync(c_39, _S1877);
        if(_S1877)
        {
            bool _S1964 = !quiet_0;
            uint _S1965 = __ballot_sync(c_39, true);
            _S1940 = _S1964;
            _S1941 = _S1965;
        }
        else
        {
            uint _S1966 = __ballot_sync(c_39, true);
            _S1940 = false;
            _S1941 = _S1966;
        }
        uint _S1967 = __ballot_sync(_S1941, _S1940);
        uint _S1968;
        if(_S1940)
        {
            float3  _S1969 = make_float3 (0.0f);
            float3  f_18 = _S1969;
            float3  t_16 = _S1969;
            c_40 = (&isl_21)->range_0.x + tid_18;
            _S1968 = _S1967;
            for(;;)
            {
                bool _S1970 = c_40 < ((&isl_21)->range_0.y);
                uint _S1971 = __ballot_sync(_S1968, _S1970);
                if(_S1970)
                {
                    uint _S1972 = __ballot_sync(_S1968, true);
                }
                else
                {
                    uint _S1973 = __ballot_sync(_S1968, false);
                    uint _S1974 = __ballot_sync(_S1968, false);
                    uint _S1975 = __ballot_sync(_S1967, true);
                    _S1872 = _S1975;
                    break;
                }
                Island_0 _S1976 = isl_21;
                Rigid_0 _S1977 = rg_9;
                net_load_0(c_40, &_S1976, &_S1977, k_22, _S1916, contact_island_0, &f_18, &t_16);
                uint _S1978 = __ballot_sync(_S1968, true);
                c_40 = c_40 + 256U;
                _S1968 = _S1978;
            }
            group_sum3_0(tid_18, &f_18, &t_16, _S1872);
            Island_0 _S1979 = isl_21;
            rigid_acceleration_0(&_S1979, &rg_9, f_18, t_16);
            uint _S1980 = __ballot_sync(_S1941, true);
            c_40 = _S1980;
        }
        else
        {
            uint _S1981 = __ballot_sync(_S1941, true);
            c_40 = _S1981;
        }
        bool _S1982 = !settled_0;
        uint _S1983 = __ballot_sync(c_40, _S1982);
        if(_S1982)
        {
            bool _S1984 = !quiet_0;
            uint _S1985 = __ballot_sync(c_40, true);
            explicit_step_0 = _S1984;
            _S1968 = _S1985;
        }
        else
        {
            uint _S1986 = __ballot_sync(c_40, true);
            explicit_step_0 = false;
            _S1968 = _S1986;
        }
        uint _S1987 = __ballot_sync(_S1968, explicit_step_0);
        uint i_29;
        uint _S1988;
        uint c_41;
        uint _S1989;
        if(explicit_step_0)
        {
            i_29 = (&isl_21)->range_0.z + tid_18;
            _S1988 = _S1987;
            for(;;)
            {
                uint _S1990 = 0U;
                bool _S1991 = i_29 < ((&isl_21)->range_0.w);
                uint _S1992 = __ballot_sync(_S1988, _S1991);
                if(_S1991)
                {
                    uint _S1993 = __ballot_sync(_S1988, true);
                    _S1990 = _S1993;
                }
                else
                {
                    uint _S1994 = __ballot_sync(_S1988, false);
                    uint _S1995 = __ballot_sync(_S1988, false);
                    uint _S1996 = __ballot_sync(_S1987, true);
                    _S1873 = _S1996;
                    break;
                }
                bool _S1997 = bond_update_0(i_29, _S1916, _S1918, abs_step_1, false);
                uint _S1998 = __ballot_sync(_S1990, _S1997);
                if(_S1997)
                {
                    *&g_halt_0 = 1U;
                    uint _S1999 = __ballot_sync(_S1990, true);
                }
                else
                {
                    uint _S2000 = __ballot_sync(_S1990, true);
                }
                uint _S2001 = __ballot_sync(_S1988, true);
                i_29 = i_29 + 256U;
                _S1988 = _S2001;
            }
            __syncthreads();
            c_41 = (&isl_21)->range_0.x + tid_18;
            _S1989 = _S1873;
            for(;;)
            {
                bool _S2002 = c_41 < ((&isl_21)->range_0.y);
                uint _S2003 = __ballot_sync(_S1989, _S2002);
                if(_S2002)
                {
                    uint _S2004 = __ballot_sync(_S1989, true);
                }
                else
                {
                    uint _S2005 = __ballot_sync(_S1989, false);
                    uint _S2006 = __ballot_sync(_S1989, false);
                    uint _S2007 = __ballot_sync(_S1873, true);
                    break;
                }
                Island_0 _S2008 = isl_21;
                Rigid_0 _S2009 = rg_9;
                chunk_update_0(c_41, &_S2008, &_S2009, _S1916, _S1920, k_22, contact_island_0, &work_3, &work_err_1);
                uint _S2010 = __ballot_sync(_S1989, true);
                c_41 = c_41 + 256U;
                _S1989 = _S2010;
            }
            __syncthreads();
            uint _S2011 = __ballot_sync(_S1968, true);
            i_29 = _S2011;
        }
        else
        {
            uint _S2012 = __ballot_sync(_S1968, true);
            i_29 = _S2012;
        }
        uint _S2013 = __ballot_sync(i_29, _S1879);
        bool _S2014;
        if(_S1879)
        {
            bool _S2015 = !quiet_0;
            uint _S2016 = __ballot_sync(i_29, true);
            _S2014 = _S2015;
            _S1988 = _S2016;
        }
        else
        {
            uint _S2017 = __ballot_sync(i_29, true);
            _S2014 = false;
            _S1988 = _S2017;
        }
        uint _S2018 = __ballot_sync(_S1988, _S2014);
        if(_S2014)
        {
            Island_0 _S2019 = isl_21;
            integrate_rigid_0(&_S2019, &rg_9, _S1916);
            uint _S2020 = __ballot_sync(_S1988, true);
            c_41 = _S2020;
        }
        else
        {
            uint _S2021 = __ballot_sync(_S1988, true);
            c_41 = _S2021;
        }
        uint _S2022 = __ballot_sync(c_41, _S1877);
        bool _S2023;
        if(_S1877)
        {
            uint _S2024 = __ballot_sync(c_41, true);
            _S2023 = explicit_step_0;
            _S1989 = _S2024;
        }
        else
        {
            uint _S2025 = __ballot_sync(c_41, true);
            _S2023 = false;
            _S1989 = _S2025;
        }
        uint _S2026 = __ballot_sync(_S1989, _S2023);
        uint c_42;
        uint _S2027;
        uint c_43;
        if(_S2023)
        {
            float4  _S2028 = (&isl_21)->wcom_0;
            float3  _S2029 = float3 {_S2028.x, _S2028.y, _S2028.z};
            float3  _S2030 = make_float3 (0.0f);
            float3  tu_3 = _S2030;
            float3  pv_3 = _S2030;
            c_42 = (&isl_21)->range_0.x + tid_18;
            _S2027 = _S2026;
            for(;;)
            {
                bool _S2031 = c_42 < ((&isl_21)->range_0.y);
                uint _S2032 = __ballot_sync(_S2027, _S2031);
                if(_S2031)
                {
                    uint _S2033 = __ballot_sync(_S2027, true);
                }
                else
                {
                    uint _S2034 = __ballot_sync(_S2027, false);
                    uint _S2035 = __ballot_sync(_S2027, false);
                    uint _S2036 = __ballot_sync(_S2026, true);
                    _S1874 = _S2036;
                    break;
                }
                drift_moments_0(c_42, &tu_3, &pv_3);
                uint _S2037 = __ballot_sync(_S2027, true);
                c_42 = c_42 + 256U;
                _S2027 = _S2037;
            }
            group_sum3_0(tid_18, &tu_3, &pv_3, _S1874);
            float3  tr_5 = tu_3 / make_float3 ((&isl_21)->wcom_0.w);
            float3  dv_5 = pv_3 / make_float3 ((&isl_21)->wcom_0.w);
            float3  lu_3 = _S2030;
            float3  lv_3 = _S2030;
            c_43 = (&isl_21)->range_0.x + tid_18;
            uint _S2038 = _S1874;
            for(;;)
            {
                bool _S2039 = c_43 < ((&isl_21)->range_0.y);
                uint _S2040 = __ballot_sync(_S2038, _S2039);
                if(_S2039)
                {
                    uint _S2041 = __ballot_sync(_S2038, true);
                }
                else
                {
                    uint _S2042 = __ballot_sync(_S2038, false);
                    uint _S2043 = __ballot_sync(_S2038, false);
                    uint _S2044 = __ballot_sync(_S1874, true);
                    _S1875 = _S2044;
                    break;
                }
                drift_angular_0(c_43, _S2029, tr_5, dv_5, &lu_3, &lv_3);
                uint _S2045 = __ballot_sync(_S2038, true);
                c_43 = c_43 + 256U;
                _S2038 = _S2045;
            }
            group_sum3_0(tid_18, &lu_3, &lv_3, _S1875);
            float3  phi_4 = rows_mul_0((&isl_21)->winv0_0, (&isl_21)->winv1_0, (&isl_21)->winv2_0, lu_3);
            float3  dw_3 = rows_mul_0((&isl_21)->winv0_0, (&isl_21)->winv1_0, (&isl_21)->winv2_0, lv_3);
            uint c_44 = (&isl_21)->range_0.x + tid_18;
            uint _S2046 = _S1875;
            for(;;)
            {
                bool _S2047 = c_44 < ((&isl_21)->range_0.y);
                uint _S2048 = __ballot_sync(_S2046, _S2047);
                if(_S2047)
                {
                    uint _S2049 = __ballot_sync(_S2046, true);
                }
                else
                {
                    uint _S2050 = __ballot_sync(_S2046, false);
                    uint _S2051 = __ballot_sync(_S2046, false);
                    uint _S2052 = __ballot_sync(_S1875, true);
                    _S1876 = _S2052;
                    break;
                }
                drift_apply_0(c_44, _S2029, tr_5, phi_4, dv_5, dw_3);
                uint _S2053 = __ballot_sync(_S2046, true);
                c_44 = c_44 + 256U;
                _S2046 = _S2053;
            }
            bool _S2054 = !driven_0;
            uint _S2055 = __ballot_sync(_S1876, _S2054);
            if(_S2054)
            {
                Island_0 _S2056 = isl_21;
                drift_rigid_0(&_S2056, &rg_9, tr_5, phi_4, dv_5, dw_3);
                uint _S2057 = __ballot_sync(_S1876, true);
            }
            else
            {
                uint _S2058 = __ballot_sync(_S1876, true);
            }
            __syncthreads();
            uint _S2059 = __ballot_sync(_S1989, true);
            c_42 = _S2059;
        }
        else
        {
            uint _S2060 = __ballot_sync(_S1989, true);
            c_42 = _S2060;
        }
        uint _S2061 = __ballot_sync(c_42, _S1884);
        bool _S2062;
        if(_S1884)
        {
            bool _S2063 = ((&isl_21)->probes_0.y) > ((&isl_21)->probes_0.x);
            uint _S2064 = __ballot_sync(c_42, true);
            _S2062 = _S2063;
            _S2027 = _S2064;
        }
        else
        {
            uint _S2065 = __ballot_sync(c_42, true);
            _S2062 = false;
            _S2027 = _S2065;
        }
        uint _S2066 = __ballot_sync(_S2027, _S2062);
        if(_S2062)
        {
            Island_0 _S2067 = isl_21;
            Rigid_0 _S2068 = rg_9;
            record_probes_0(&_S2067, &_S2068, k_22);
            uint _S2069 = __ballot_sync(_S2027, true);
            c_43 = _S2069;
        }
        else
        {
            uint _S2070 = __ballot_sync(_S2027, true);
            c_43 = _S2070;
        }
        uint _S2071 = done_1 + 1U;
        bool _S2072 = (*&g_halt_0) != 0U;
        uint _S2073 = __ballot_sync(c_43, _S2072);
        if(_S2072)
        {
            uint _S2074 = __ballot_sync(c_43, false);
            uint _S2075 = __ballot_sync(_S1923, false);
            uint _S2076 = __ballot_sync(run_0, true);
            done_1 = _S2071;
            cov_2 = _S2076;
            break;
        }
        else
        {
            uint _S2077 = __ballot_sync(c_43, true);
        }
        uint _S2078 = __ballot_sync(_S1923, true);
        done_1 = _S2071;
        woke_1 = woke_0;
        _S1923 = _S2078;
    }
    float3  wsum_0 = make_float3 (work_3, work_err_1, 0.0f);
    float3  unused_3 = make_float3 (0.0f);
    group_sum3_0(tid_18, &wsum_0, &unused_3, cov_2);
    uint _S2079 = __ballot_sync(cov_2, _S1884);
    if(_S1884)
    {
        Quat_0 _S2080 = (&rg_9)->rot_1;
        float4  _S2081 = quat_vec_0(&_S2080);
        (&isl_21)->rotation_0 = _S2081;
        (&isl_21)->rotation_err_0 = (&rg_9)->rot_err_0;
        (&isl_21)->position_0 = make_float4 ((&rg_9)->pos_0.x, (&rg_9)->pos_0.y, (&rg_9)->pos_0.z, 0.0f);
        (&isl_21)->position_err_0 = make_float4 ((&rg_9)->pos_err_0.x, (&rg_9)->pos_err_0.y, (&rg_9)->pos_err_0.z, 0.0f);
        (&isl_21)->velocity_0 = make_float4 ((&rg_9)->vel_0.x, (&rg_9)->vel_0.y, (&rg_9)->vel_0.z, 0.0f);
        (&isl_21)->velocity_err_0 = make_float4 ((&rg_9)->vel_err_0.x, (&rg_9)->vel_err_0.y, (&rg_9)->vel_err_0.z, 0.0f);
        (&isl_21)->angular_velocity_0 = make_float4 ((&rg_9)->w_5.x, (&rg_9)->w_5.y, (&rg_9)->w_5.z, 0.0f);
        (&isl_21)->momentum_0 = make_float4 ((&rg_9)->l_1.x, (&rg_9)->l_1.y, (&rg_9)->l_1.z, 0.0f);
        (&isl_21)->momentum_err_0 = make_float4 ((&rg_9)->l_err_0.x, (&rg_9)->l_err_0.y, (&rg_9)->l_err_0.z, 0.0f);
        (&isl_21)->done_0 = done_1;
        *&((&(&isl_21)->info_1)->y) = *&((&(&isl_21)->info_1)->y) - done_1;
        if((*&g_halt_0) != 0U)
        {
            _S1879 = contact_island_0;
        }
        else
        {
            _S1879 = false;
        }
        if(_S1879)
        {
            contact_split_at_0((&isl_21)->info_1.w + done_1);
        }
        comp_add1_0(&((&(&isl_21)->energy_1)->x), &((&(&isl_21)->energy_1)->y), wsum_0.x);
        *&((&(&isl_21)->energy_1)->y) = *&((&(&isl_21)->energy_1)->y) + wsum_0.y;
        *&((&(&isl_21)->info_1)->w) = *&((&(&isl_21)->info_1)->w) + done_1;
        if((*&g_halt_0) != 0U)
        {
            *&((&(&isl_21)->info_1)->z) = (*&((&(&isl_21)->info_1)->z)) | 1U;
        }
        uint _S2082 = seen_bits_0();
        if((*&g_halt_0) != 0U)
        {
            cov_2 = 128U;
        }
        else
        {
            cov_2 = 0U;
        }
        uint _S2083 = _S2082 | cov_2;
        if(woke_0)
        {
            cov_2 = 2048U;
        }
        else
        {
            cov_2 = 0U;
        }
        uint cov_3 = _S2083 | cov_2;
        if(done_1 > 0U)
        {
            bool quiet_1 = (((&isl_21)->info_1.x) & 32U) != 0U;
            if(quiet_1)
            {
                cov_2 = 4096U;
            }
            else
            {
                cov_2 = 0U;
            }
            uint cov_4 = cov_3 | cov_2;
            if((((&isl_21)->info_1.x) & 16U) != 0U)
            {
                _S1879 = !quiet_1;
            }
            else
            {
                _S1879 = false;
            }
            if(_S1879)
            {
                cov_2 = 512U;
            }
            else
            {
                cov_2 = 0U;
            }
            uint cov_5 = cov_4 | cov_2;
            uint _S2084 = __ldg(&globalParams_0->params_0->contact_mode_0);
            if(_S2084 == 1U)
            {
                cov_2 = 524288U;
            }
            else
            {
                cov_2 = 0U;
            }
            uint cov_6 = cov_5 | cov_2;
            if(((&isl_21)->probes_0.y) > ((&isl_21)->probes_0.x))
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
        (&isl_21)->coverage_0 = ((&isl_21)->coverage_0) | cov_2;
        if(woke_0)
        {
            *&((&(&isl_21)->info_1)->x) = (*&((&(&isl_21)->info_1)->x)) & 4294967279U;
            *&((&(&isl_21)->info_1)->z) = (*&((&(&isl_21)->info_1)->z)) | 4U;
        }
        *(&(globalParams_0->islands_0)[gi_0]) = isl_21;
    }
    return;
}

extern "C" __global__ void island_frame()
{
    uint _S2085 = __ballot_sync(4294967295U, true);
    island_frame_at_0(blockIdx.x, threadIdx.x, _S2085);
    return;
}

static __device__ void wide_chunks_at_0(uint gx_0, uint tid_19, uint _S2086)
{
    uint _S2087 = 0U;
    uint _S2088 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    WideGroup_0 wg_6 = wide_group_0(_S2088, gx_0);
    Island_0 isl_22 = *(&(globalParams_0->islands_0)[wg_6.island_2]);
    bool _S2089 = wide_enter_1(tid_19, wg_6.island_2);
    bool _S2090 = !_S2089;
    uint _S2091 = __ballot_sync(_S2086, _S2090);
    if(_S2090)
    {
        return;
    }
    else
    {
        uint _S2092 = __ballot_sync(_S2086, true);
        _S2087 = _S2092;
    }
    uint _S2093 = 0U;
    uint _S2094 = isl_22.info_1.x;
    bool anchored_0 = (_S2094 & 1U) != 0U;
    bool _S2095 = (_S2094 & 16U) != 0U;
    uint _S2096 = __ballot_sync(_S2087, _S2095);
    if(_S2095)
    {
        if(tid_19 == 0U)
        {
            uint _S2097 = __ldg(&globalParams_0->params_0->wide_base_0);
            *(&(globalParams_0->scratch_0)[_S2097 + 8U * gx_0 + 6U]) = make_float4 (0.0f);
        }
        return;
    }
    else
    {
        uint _S2098 = __ballot_sync(_S2087, true);
        _S2093 = _S2098;
    }
    Island_0 _S2099 = isl_22;
    WideGroup_0 _S2100 = wg_6;
    Rigid_0 _S2101 = wide_rigid_frame_0(tid_19, &_S2099, &_S2100, _S2093);
    float work_4 = 0.0f;
    float work_err_2 = 0.0f;
    float3  _S2102 = make_float3 (0.0f);
    float3  tu_4 = _S2102;
    float3  pv_4 = _S2102;
    uint c_45 = wg_6.begin_0 + tid_19;
    bool _S2103 = c_45 < (wg_6.end_0);
    uint _S2104 = __ballot_sync(_S2093, _S2103);
    uint _S2105;
    if(_S2103)
    {
        float _S2106 = __ldg(&globalParams_0->params_0->dt_0);
        uint _S2107 = __ldg(&globalParams_0->params_0->rigid_motion_loads_0);
        bool _S2108 = _S2107 != 0U;
        Island_0 _S2109 = isl_22;
        uint _S2110 = wide_step_0(&_S2109);
        bool _S2111 = (_S2094 & 4U) != 0U;
        Island_0 _S2112 = isl_22;
        Rigid_0 _S2113 = _S2101;
        chunk_update_0(c_45, &_S2112, &_S2113, _S2106, _S2108, _S2110, _S2111, &work_4, &work_err_2);
        bool _S2114 = !anchored_0;
        uint _S2115 = __ballot_sync(_S2104, _S2114);
        if(_S2114)
        {
            drift_moments_0(c_45, &tu_4, &pv_4);
            uint _S2116 = __ballot_sync(_S2104, true);
        }
        else
        {
            uint _S2117 = __ballot_sync(_S2104, true);
        }
        uint _S2118 = __ballot_sync(_S2093, true);
        _S2105 = _S2118;
    }
    else
    {
        uint _S2119 = __ballot_sync(_S2093, true);
        _S2105 = _S2119;
    }
    float3  wsum_1 = make_float3 (work_4, work_err_2, 0.0f);
    float3  unused_4 = _S2102;
    group_sum3_0(tid_19, &wsum_1, &unused_4, _S2105);
    bool _S2120 = !anchored_0;
    uint _S2121 = __ballot_sync(_S2105, _S2120);
    if(_S2120)
    {
        group_sum3_0(tid_19, &tu_4, &pv_4, _S2121);
        uint _S2122 = __ballot_sync(_S2105, true);
    }
    if(tid_19 == 0U)
    {
        uint _S2123 = __ldg(&globalParams_0->params_0->wide_base_0);
        uint _S2124 = 8U * gx_0;
        *(&(globalParams_0->scratch_0)[_S2123 + _S2124 + 6U]) = make_float4 (wsum_1.x, wsum_1.y, wsum_1.z, 0.0f);
        if(_S2120)
        {
            wide_store_0(gx_0, 2U, tu_4, pv_4);
        }
        uint _S2125 = __ldg(&globalParams_0->params_0->wide_base_0);
        *(&(globalParams_0->scratch_0)[_S2125 + _S2124 + 7U]) = make_float4 (float((*&g_seen_0)[0U]), float((*&g_seen_0)[1U]), float((*&g_seen_0)[2U]), 0.0f);
    }
    return;
}

extern "C" __global__ void wide_chunks()
{
    uint _S2126 = __ballot_sync(4294967295U, true);
    wide_chunks_at_0(blockIdx.x, threadIdx.x, _S2126);
    return;
}

extern "C" __global__ void sums_and_impactors()
{
    uint _S2127 = __ballot_sync(4294967295U, true);
    uint _S2128 = __ldg(&globalParams_0->params_0->seg_count_0);
    uint sums_groups_0 = (_S2128 + 255U) / 256U;
    uint _S2129 = blockIdx.x;
    bool _S2130 = _S2129 < sums_groups_0;
    uint _S2131 = __ballot_sync(_S2127, _S2130);
    if(_S2130)
    {
        contact_sum_at_0(_S2129 * 256U + threadIdx.x);
    }
    else
    {
        impactor_integrate_at_0(_S2129 - sums_groups_0, threadIdx.x, _S2127 & (~_S2131));
        uint _S2132 = __ballot_sync(_S2127, true);
    }
    return;
}

extern "C" __global__ void islands_and_wide_chunks()
{
    uint _S2133 = __ballot_sync(4294967295U, true);
    uint _S2134 = blockIdx.x;
    uint _S2135 = __ldg(&globalParams_0->params_0->halt_index_0);
    bool _S2136 = _S2134 < _S2135;
    uint _S2137 = __ballot_sync(_S2133, _S2136);
    if(_S2136)
    {
        island_frame_at_0(_S2134, threadIdx.x, _S2137);
        uint _S2138 = __ballot_sync(_S2133, true);
    }
    else
    {
        uint _S2139 = _S2133 & (~_S2137);
        uint _S2140 = __ldg(&globalParams_0->params_0->halt_index_0);
        wide_chunks_at_0(_S2134 - _S2140, threadIdx.x, _S2139);
        uint _S2141 = __ballot_sync(_S2133, true);
    }
    return;
}

