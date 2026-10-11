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
    uint pc_steps_0;
    uint pc_base_0;
    uint pi_base_0;
    uint bond_count_0;
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

static __device__ void impactor_candidate_forces_0(uint k_5, uint lane_1, uint lanes_5, uint _S363)
{
    uint _S364;
    uint _S365;
    bool _S366;
    uint _S367;
    uint _S368 = __ldg(&globalParams_0->params_0->cand_index_0);
    uint _S369 = 3U * k_5;
    uint at_1 = _S368 + _S369;
    uint _S370 = __ldg((&(globalParams_0->index_0)[at_1]));
    uint _S371 = __ldg((&(globalParams_0->index_0)[at_1 + 1U]));
    uint _S372 = __ldg((&(globalParams_0->index_0)[at_1 + 2U]));
    Impactor_0 imp_3 = *(&(globalParams_0->impactors_0)[_S372]);
    float _S373 = __ldg(&globalParams_0->params_0->dt_0);
    float3  _S374 = make_float3 (0.0f);
    uint _S375 = __ldg(&globalParams_0->params_0->cand_base_0);
    float4  data_0 = *(&(globalParams_0->scratch_0)[_S375 + _S369]);
    bool _S376 = (imp_3.cand_0.z) == 0U;
    uint _S377 = __ballot_sync(_S363, _S376);
    bool hit_0;
    float3  f_sum_0;
    float3  t_sum_0;
    float3  imp_f_0;
    float3  imp_t_0;
    if(_S376)
    {
        WorldPoint_0 _S378 = impactor_point_0(_S372);
        WorldPoint_0 _S379 = chunk_world_0(_S370);
        WorldPoint_0 _S380 = _S378;
        float3  _S381 = world_diff_0(&_S379, &_S380);
        float _S382 = length_0(_S381);
        float _S383 = imp_3.half_1.w;
        float4  _S384 = __ldg(&(&(globalParams_0->chunks_0)[_S370])->half_0);
        bool _S385 = !(_S382 > (_S383 + _S384.w));
        uint _S386 = __ballot_sync(_S377, _S385);
        if(_S385)
        {
            float4  _S387 = imp_3.half_1;
            Box_0 _S388 = impactor_box_1(_S372, _S374, float3 {_S387.x, _S387.y, _S387.z});
            Box_0 b_19 = chunk_box_0(_S370, _S381);
            float _S389 = imp_3.mat_0.x;
            float4  _S390 = __ldg(&(&(globalParams_0->chunks_0)[_S370])->cmat_0);
            float _S391 = _S390.x;
            float3  _S392 = b_19.center_1 - _S388.center_1;
            Box_0 _S393 = _S388;
            Box_0 _S394 = b_19;
            float _S395 = contact_stiffness_0(_S389, &_S393, _S391, &_S394, _S392);
            float _S396 = imp_3.geom_0.y;
            Box_0 _S397 = _S388;
            Box_0 _S398 = impactor_shrunk_0(_S372, _S396, &_S397);
            uint j_1 = lane_1;
            uint n_6 = 0U;
            uint j_2 = _S386;
            for(;;)
            {
                uint _S399 = 0U;
                Impactor_0 _S400 = imp_3;
                Box_0 _S401 = b_19;
                uint _S402 = impactor_slots_0(&_S400, &_S401);
                _S364 = _S402;
                bool _S403 = j_1 < _S402;
                uint _S404 = __ballot_sync(j_2, _S403);
                if(_S403)
                {
                    uint _S405 = __ballot_sync(j_2, true);
                    _S399 = _S405;
                }
                else
                {
                    uint _S406 = __ballot_sync(j_2, false);
                    uint _S407 = __ballot_sync(j_2, false);
                    uint _S408 = __ballot_sync(_S386, true);
                    _S365 = _S408;
                    break;
                }
                Box_0 _S409 = _S398;
                Box_0 _S410 = b_19;
                float3  p_5;
                float3  nrm_0;
                float dep_0;
                bool _S411 = impactor_contact_1(_S372, _S396, &_S409, &_S410, j_1, &p_5, &nrm_0, &dep_0);
                uint _S412 = __ballot_sync(_S399, _S411);
                if(_S411)
                {
                    uint _S413 = n_6 + 1U;
                    uint _S414 = __ballot_sync(_S399, true);
                    n_6 = _S413;
                }
                else
                {
                    uint _S415 = __ballot_sync(_S399, true);
                }
                uint _S416 = __ballot_sync(j_2, true);
                j_1 = j_1 + lanes_5;
                j_2 = _S416;
            }
            uint _S417 = pair_count_sum_0(n_6, lanes_5, _S365);
            bool _S418 = (imp_3.shape_0.x) == 0.0f;
            uint _S419 = __ballot_sync(_S365, _S418);
            float _S420;
            if(_S418)
            {
                uint _S421 = __ballot_sync(_S365, true);
                _S420 = _S395;
                j_1 = _S421;
            }
            else
            {
                float _S422 = _S395 / (F32_max((float(_S417)), (10.0f)));
                uint _S423 = __ballot_sync(_S365, true);
                _S420 = _S422;
                j_1 = _S423;
            }
            uint _S424 = __ballot_sync(j_1, _S418);
            if(_S418)
            {
                uint _S425 = __ballot_sync(j_1, true);
                j_1 = 1U;
                n_6 = _S425;
            }
            else
            {
                uint _S426 = __ballot_sync(j_1, true);
                j_1 = _S417;
                n_6 = _S426;
            }
            float4  _S427 = __ldg(&(&(globalParams_0->chunks_0)[_S370])->center_0);
            float m_1 = _S427.w;
            float _S428 = imp_3.mat_0.z;
            float _S429 = m_1 * _S428 / (m_1 + _S428);
            float _S430 = __ldg(&globalParams_0->params_0->pair_friction_0);
            bool _S431 = _S430 >= 0.0f;
            uint _S432 = __ballot_sync(n_6, _S431);
            float _S433;
            if(_S431)
            {
                float _S434 = __ldg(&globalParams_0->params_0->pair_friction_0);
                uint _S435 = __ballot_sync(n_6, true);
                _S433 = _S434;
                n_6 = _S435;
            }
            else
            {
                float _S436 = imp_3.mat_0.y;
                float4  _S437 = __ldg(&(&(globalParams_0->chunks_0)[_S370])->cmat_0);
                float _S438 = (F32_min((_S436), (_S437.y)));
                uint _S439 = __ballot_sync(n_6, true);
                _S433 = _S438;
                n_6 = _S439;
            }
            float4  _S440 = imp_3.velocity_1;
            float4  _S441 = imp_3.velocity_err_1;
            float3  _S442 = float3 {_S440.x, _S440.y, _S440.z} + float3 {_S441.x, _S441.y, _S441.z};
            float3  vc_0;
            float3  wc_0;
            chunk_velocity_0(_S370, &vc_0, &wc_0);
            hit_0 = false;
            j_2 = lane_1;
            f_sum_0 = _S374;
            t_sum_0 = _S374;
            imp_f_0 = _S374;
            imp_t_0 = _S374;
            float diss_sum_2 = 0.0f;
            uint _S443 = n_6;
            for(;;)
            {
                bool _S444 = _S417 > 0U;
                _S366 = _S444;
                uint _S445 = __ballot_sync(_S443, _S444);
                uint _S446;
                bool _S447;
                if(_S444)
                {
                    bool _S448 = j_2 < _S364;
                    uint _S449 = __ballot_sync(_S443, true);
                    _S447 = _S448;
                    _S446 = _S449;
                }
                else
                {
                    uint _S450 = __ballot_sync(_S443, true);
                    _S447 = false;
                    _S446 = _S450;
                }
                uint _S451 = 0U;
                uint _S452 = __ballot_sync(_S446, _S447);
                if(_S447)
                {
                    uint _S453 = __ballot_sync(_S446, true);
                    _S451 = _S453;
                }
                else
                {
                    uint _S454 = __ballot_sync(_S446, false);
                    uint _S455 = __ballot_sync(_S443, false);
                    uint _S456 = __ballot_sync(n_6, true);
                    _S367 = _S456;
                    break;
                }
                Impactor_0 _S457 = imp_3;
                Box_0 _S458 = _S398;
                Box_0 _S459 = b_19;
                float3  p_6;
                float3  nrm_1;
                float dep_1;
                bool _S460 = impactor_contact_0(&_S457, _S396, &_S458, &_S459, j_2, &p_6, &nrm_1, &dep_1);
                bool _S461 = !_S460;
                uint _S462 = __ballot_sync(_S451, _S461);
                if(_S461)
                {
                    uint _S463 = __ballot_sync(_S451, false);
                    uint _S464 = __ballot_sync(_S443, true);
                    _S443 = _S464;
                    j_2 = j_2 + lanes_5;
                    continue;
                }
                else
                {
                    uint _S465 = __ballot_sync(_S451, true);
                }
                float4  _S466 = imp_3.angular_velocity_1;
                float stored_2;
                float diss_1;
                float3  f_2 = penalty_force_0(_S420, _S429, _S433, dep_1 * imp_3.geom_0.x, nrm_1, vc_0 + cross_0(wc_0, p_6 - b_19.center_1) - (_S442 + cross_0(float3 {_S466.x, _S466.y, _S466.z}, p_6)), _S373, j_1, &stored_2, &diss_1);
                float3  f_sum_1 = f_sum_0 + f_2;
                float3  t_sum_1 = t_sum_0 + cross_0(p_6 - b_19.center_1, f_2);
                float3  imp_f_1 = imp_f_0 - f_2;
                float3  imp_t_1 = imp_t_0 - cross_0(p_6, f_2);
                float diss_sum_3 = diss_sum_2 + diss_1;
                uint _S467 = __ballot_sync(_S443, true);
                hit_0 = true;
                f_sum_0 = f_sum_1;
                t_sum_0 = t_sum_1;
                imp_f_0 = imp_f_1;
                imp_t_0 = imp_t_1;
                diss_sum_2 = diss_sum_3;
                _S443 = _S467;
                j_2 = j_2 + lanes_5;
            }
            float3  _S468 = pair_sum3_0(f_sum_0, lanes_5, _S367);
            float3  _S469 = pair_sum3_0(t_sum_0, lanes_5, _S367);
            float3  _S470 = pair_sum3_0(imp_f_0, lanes_5, _S367);
            float3  _S471 = pair_sum3_0(imp_t_0, lanes_5, _S367);
            float _S472 = pair_sum_0(diss_sum_2, lanes_5, _S367);
            bool _S473 = pair_any_0(hit_0, lanes_5, _S367);
            uint _S474 = __ballot_sync(_S367, _S366);
            if(_S366)
            {
                comp_add1_0(&((&data_0)->z), &((&data_0)->w), _S472);
            }
            hit_0 = _S473;
            f_sum_0 = _S468;
            t_sum_0 = _S469;
            imp_f_0 = _S470;
            imp_t_0 = _S471;
        }
        else
        {
            hit_0 = false;
            f_sum_0 = _S374;
            t_sum_0 = _S374;
            imp_f_0 = _S374;
            imp_t_0 = _S374;
        }
    }
    else
    {
        hit_0 = false;
        f_sum_0 = _S374;
        t_sum_0 = _S374;
        imp_f_0 = _S374;
        imp_t_0 = _S374;
    }
    if(lane_1 != 0U)
    {
        return;
    }
    uint _S475 = __ldg(&globalParams_0->params_0->slot_base_0);
    uint _S476 = 2U * _S371;
    *(&(globalParams_0->scratch_0)[_S475 + _S476]) = make_float4 (f_sum_0.x, f_sum_0.y, f_sum_0.z, 0.0f);
    uint _S477 = __ldg(&globalParams_0->params_0->slot_base_0);
    *(&(globalParams_0->scratch_0)[_S477 + _S476 + 1U]) = make_float4 (t_sum_0.x, t_sum_0.y, t_sum_0.z, 0.0f);
    uint _S478 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S478 + _S369]) = data_0;
    uint _S479 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S479 + _S369 + 1U]) = make_float4 (imp_f_0.x, imp_f_0.y, imp_f_0.z, 0.0f);
    uint _S480 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S480 + _S369 + 2U]) = make_float4 (imp_t_0.x, imp_t_0.y, imp_t_0.z, 0.0f);
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
    ChunkStatic_0 * _S481 = (&(globalParams_0->chunks_0)[c_4]);
    uint4  _S482 = __ldg(&_S481->cinfo_0);
    if((_S482.z) == 0U)
    {
        return;
    }
    WorldPoint_0 wp_0 = chunk_world_0(c_4);
    float4  _S483 = __ldg(&_S481->start_hi_0);
    float3  _S484 = wp_0.hi_0 - float3 {_S483.x, _S483.y, _S483.z};
    float4  _S485 = __ldg(&_S481->start_lo_0);
    float3  moved_0 = _S484 + (wp_0.lo_0 - float3 {_S485.x, _S485.y, _S485.z}) + wp_0.rel_0;
    float _S486 = __ldg(&globalParams_0->params_0->t_hi_0);
    float4  _S487 = __ldg(&_S481->start_vel_0);
    float _S488 = _S486 - _S487.w;
    float _S489 = __ldg(&globalParams_0->params_0->t_lo_0);
    float _S490 = _S488 + (_S489 - _S485.w);
    uint4  _S491 = __ldg(&_S481->info_0);
    uint _S492 = _S491.y;
    uint _S493 = (&(globalParams_0->islands_0)[_S492])->info_1.w;
    uint _S494 = __ldg(&globalParams_0->params_0->step_start_0);
    float _S495 = float(_S493 - _S494);
    float _S496 = __ldg(&globalParams_0->params_0->dt_0);
    float since_0 = _S490 + _S495 * _S496;
    float3  _S497 = float3 {_S487.x, _S487.y, _S487.z} * make_float3 (since_0);
    uint _S498 = _S482.w;
    float3  _S499;
    if((_S498 & 2U) != 0U)
    {
        float4  _S500 = __ldg(&globalParams_0->params_0->gravity_0);
        _S499 = make_float3 (0.5f) * float3 {_S500.x, _S500.y, _S500.z} * make_float3 (since_0) * make_float3 (since_0);
    }
    else
    {
        _S499 = make_float3 (0.0f);
    }
    float travel_0 = length_0(moved_0 - (_S497 + _S499));
    float travel_1;
    if((_S498 & 1U) != 0U)
    {
        float4  _S501 = *(&(globalParams_0->state_0)[4U * c_4 + 1U]);
        float3  th_1 = float3 {_S501.x, _S501.y, _S501.z};
        Quat_0 _S502 = from_axis_angle_0(th_1, length_0(th_1));
        Quat_0 _S503 = quat_of_0((&(globalParams_0->islands_0)[_S492])->rotation_0);
        Quat_0 _S504 = _S502;
        Quat_0 _S505 = quat_mul_0(&_S503, &_S504);
        float4  _S506 = __ldg(&_S481->start_rot_0);
        Quat_0 _S507 = quat_of_0(make_float4 ((- float3 {_S506.x, _S506.y, _S506.z}).x, (- float3 {_S506.x, _S506.y, _S506.z}).y, (- float3 {_S506.x, _S506.y, _S506.z}).z, _S506.w));
        Quat_0 _S508 = _S505;
        Quat_0 _S509 = quat_mul_0(&_S507, &_S508);
        float _S510 = 2.0f * (F32_atan2((length_0(make_float3 (_S509.x_12, _S509.y_4, _S509.z_0))), ((F32_abs((_S509.w_1))))));
        float4  _S511 = __ldg(&_S481->half_0);
        travel_1 = travel_0 + _S510 * _S511.w;
    }
    else
    {
        travel_1 = travel_0;
    }
    if(travel_1 > (_S483.w))
    {
        uint _S512 = __ldg(&globalParams_0->params_0->halt_index_0);
        uint _S513 = __ldg(&globalParams_0->params_0->halt_index_0);
        *&((&(&(globalParams_0->islands_0)[_S512])->info_1)->z) = ((&(globalParams_0->islands_0)[_S513])->info_1.z) | 1U;
        sentinel_mark_0(1048576U);
    }
    return;
}

extern "C" __global__ void contact_forces()
{
    uint _S514 = 0U;
    uint3  _S515 = blockIdx * blockDim + threadIdx;
    uint _S516 = __ballot_sync(4294967295U, true);
    uint i_9 = _S515.x;
    uint lanes_6 = pair_lane_count_0();
    uint _S517 = __ldg(&globalParams_0->params_0->pair_count_0);
    uint pair_threads_0 = _S517 * lanes_6;
    bool _S518 = i_9 < pair_threads_0;
    uint _S519 = __ballot_sync(_S516, _S518);
    if(_S518)
    {
        bool _S520 = pair_any_0(stopped_0(), lanes_6, _S519);
        bool _S521 = !_S520;
        uint _S522 = __ballot_sync(_S519, _S521);
        if(_S521)
        {
            uint _S523 = i_9 / lanes_6;
            uint _S524 = i_9 % lanes_6;
            pair_contact_0(_S523, _S524, lanes_6, _S522);
            uint _S525 = __ballot_sync(_S519, true);
        }
        return;
    }
    else
    {
        uint _S526 = __ballot_sync(_S516, true);
        _S514 = _S526;
    }
    uint j_3 = i_9 - pair_threads_0;
    uint _S527 = __ldg(&globalParams_0->params_0->cand_count_0);
    uint cand_threads_0 = _S527 * lanes_6;
    bool _S528 = j_3 < cand_threads_0;
    uint _S529 = __ballot_sync(_S514, _S528);
    if(_S528)
    {
        bool _S530 = pair_any_0(stopped_0(), lanes_6, _S529);
        bool _S531 = !_S530;
        uint _S532 = __ballot_sync(_S529, _S531);
        if(_S531)
        {
            uint _S533 = j_3 / lanes_6;
            uint _S534 = j_3 % lanes_6;
            impactor_candidate_forces_0(_S533, _S534, lanes_6, _S532);
            uint _S535 = __ballot_sync(_S529, true);
        }
        return;
    }
    uint _S536 = j_3 - cand_threads_0;
    uint _S537 = __ldg(&globalParams_0->params_0->chunk_count_0);
    bool _S538;
    if(_S536 < _S537)
    {
        _S538 = !stopped_0();
    }
    else
    {
        _S538 = false;
    }
    if(_S538)
    {
        travel_check_0(_S536);
    }
    return;
}

static __device__ uint impactor_contact_count_0(uint _S539, float _S540, Box_0 * _S541, Box_0 * _S542)
{
    Impactor_0 _S543 = *(&(globalParams_0->impactors_0)[_S539]);
    uint j_4 = 0U;
    uint count_1 = 0U;
    for(;;)
    {
        Impactor_0 _S544 = _S543;
        uint _S545 = impactor_slots_0(&_S544, _S542);
        if(j_4 < _S545)
        {
        }
        else
        {
            break;
        }
        float3  p_7;
        float3  n_7;
        float d_9;
        bool _S546 = impactor_contact_1(_S539, _S540, _S541, _S542, j_4, &p_7, &n_7, &d_9);
        if(_S546)
        {
            count_1 = count_1 + 1U;
        }
        j_4 = j_4 + 1U;
    }
    return count_1;
}

extern "C" __global__ void impactor_shares()
{
    uint k_6 = (blockIdx * blockDim + threadIdx).x;
    uint _S547 = __ldg(&globalParams_0->params_0->cand_count_0);
    bool _S548;
    if(k_6 >= _S547)
    {
        _S548 = true;
    }
    else
    {
        _S548 = stopped_0();
    }
    if(_S548)
    {
        return;
    }
    uint _S549 = __ldg(&globalParams_0->params_0->cand_index_0);
    uint _S550 = 3U * k_6;
    uint at_2 = _S549 + _S550;
    uint _S551 = __ldg((&(globalParams_0->index_0)[at_2]));
    uint _S552 = __ldg((&(globalParams_0->index_0)[at_2 + 2U]));
    Impactor_0 * _S553 = (&(globalParams_0->impactors_0)[_S552]);
    Impactor_0 imp_4 = *_S553;
    if(((*_S553).cand_0.z) == 0U)
    {
        _S548 = (imp_4.crush_1.x) > 0.0f;
    }
    else
    {
        _S548 = false;
    }
    float total_0;
    float ksum_0;
    if(_S548)
    {
        WorldPoint_0 _S554 = impactor_point_0(_S552);
        WorldPoint_0 _S555 = chunk_world_0(_S551);
        WorldPoint_0 _S556 = _S554;
        float3  _S557 = world_diff_0(&_S555, &_S556);
        float _S558 = length_0(_S557);
        float _S559 = imp_4.half_1.w;
        float4  _S560 = __ldg(&(&(globalParams_0->chunks_0)[_S551])->half_0);
        if(!(_S558 > (_S559 + _S560.w)))
        {
            float4  _S561 = imp_4.half_1;
            Box_0 _S562 = impactor_box_1(_S552, make_float3 (0.0f), float3 {_S561.x, _S561.y, _S561.z});
            Box_0 b_20 = chunk_box_0(_S551, _S557);
            float _S563 = imp_4.mat_0.x;
            float4  _S564 = __ldg(&(&(globalParams_0->chunks_0)[_S551])->cmat_0);
            float _S565 = _S564.x;
            float3  _S566 = b_20.center_1 - _S562.center_1;
            Box_0 _S567 = _S562;
            Box_0 _S568 = b_20;
            float _S569 = contact_stiffness_0(_S563, &_S567, _S565, &_S568, _S566);
            float _S570 = imp_4.crush_1.w;
            Box_0 _S571 = _S562;
            Box_0 _S572 = impactor_shrunk_0(_S552, _S570, &_S571);
            Box_0 _S573 = _S572;
            Box_0 _S574 = b_20;
            uint _S575 = impactor_contact_count_0(_S552, _S570, &_S573, &_S574);
            float _S576;
            if((imp_4.shape_0.x) == 0.0f)
            {
                _S576 = _S569;
            }
            else
            {
                _S576 = _S569 / (F32_max((float(_S575)), (10.0f)));
            }
            uint j_5 = 0U;
            total_0 = 0.0f;
            ksum_0 = 0.0f;
            for(;;)
            {
                if(_S575 > 0U)
                {
                    Impactor_0 _S577 = imp_4;
                    Box_0 _S578 = b_20;
                    uint _S579 = impactor_slots_0(&_S577, &_S578);
                    _S548 = j_5 < _S579;
                }
                else
                {
                    _S548 = false;
                }
                if(_S548)
                {
                }
                else
                {
                    break;
                }
                Impactor_0 _S580 = imp_4;
                Box_0 _S581 = _S572;
                Box_0 _S582 = b_20;
                float3  p_8;
                float3  nrm_2;
                float dep_2;
                bool _S583 = impactor_contact_0(&_S580, _S570, &_S581, &_S582, j_5, &p_8, &nrm_2, &dep_2);
                if(!_S583)
                {
                    j_5 = j_5 + 1U;
                    continue;
                }
                float ksum_1 = ksum_0 + _S576;
                total_0 = total_0 + _S576 * dep_2;
                ksum_0 = ksum_1;
                j_5 = j_5 + 1U;
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
    uint _S584 = __ldg(&globalParams_0->params_0->cand_base_0);
    float4  data_1 = *(&(globalParams_0->scratch_0)[_S584 + _S550]);
    uint _S585 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S585 + _S550]) = make_float4 (total_0, ksum_0, data_1.z, data_1.w);
    return;
}

extern "C" __global__ void impactor_crush()
{
    uint _S586;
    uint _S587 = __ballot_sync(4294967295U, true);
    uint ii_0 = blockIdx.x;
    uint tid_2 = threadIdx.x;
    uint _S588 = __ldg(&globalParams_0->params_0->impactor_count_0);
    bool _S589 = ii_0 >= _S588;
    uint _S590 = __ballot_sync(_S587, _S589);
    bool _S591;
    uint k_7;
    if(_S589)
    {
        uint _S592 = __ballot_sync(_S587, true);
        _S591 = true;
        k_7 = _S592;
    }
    else
    {
        bool _S593 = stopped_0();
        uint _S594 = __ballot_sync(_S587, true);
        _S591 = _S593;
        k_7 = _S594;
    }
    uint _S595 = 0U;
    uint _S596 = __ballot_sync(k_7, _S591);
    if(_S591)
    {
        return;
    }
    else
    {
        uint _S597 = __ballot_sync(k_7, true);
        _S595 = _S597;
    }
    Impactor_0 imp_5 = *(&(globalParams_0->impactors_0)[ii_0]);
    float4  _S598 = make_float4 (0.0f);
    float4  shares_0 = _S598;
    float4  unused_0 = _S598;
    k_7 = (&imp_5)->cand_0.x + tid_2;
    uint _S599;
    _S599 = _S595;
    for(;;)
    {
        bool _S600 = k_7 < ((&imp_5)->cand_0.y);
        uint _S601 = __ballot_sync(_S599, _S600);
        if(_S600)
        {
            uint _S602 = __ballot_sync(_S599, true);
        }
        else
        {
            uint _S603 = __ballot_sync(_S599, false);
            uint _S604 = __ballot_sync(_S599, false);
            uint _S605 = __ballot_sync(_S595, true);
            _S586 = _S605;
            break;
        }
        uint _S606 = __ldg(&globalParams_0->params_0->cand_base_0);
        shares_0 = shares_0 + *(&(globalParams_0->scratch_0)[_S606 + 3U * k_7]);
        uint _S607 = __ballot_sync(_S599, true);
        k_7 = k_7 + 256U;
        _S599 = _S607;
    }
    group_sum2_0(tid_2, &shares_0, &unused_0, _S586);
    bool _S608 = tid_2 != 0U;
    uint _S609 = __ballot_sync(_S586, _S608);
    if(_S608)
    {
        _S591 = true;
    }
    else
    {
        _S591 = ((&imp_5)->cand_0.z) != 0U;
    }
    if(_S591)
    {
        return;
    }
    (&imp_5)->geom_0 = make_float4 (1.0f, (&imp_5)->crush_1.w, 0.0f, 0.0f);
    float total_1 = shares_0.x;
    if(((&imp_5)->crush_1.x) > 0.0f)
    {
        _S591 = ((&imp_5)->crush_1.z) < ((&imp_5)->crush_1.y);
    }
    else
    {
        _S591 = false;
    }
    if(_S591)
    {
        _S591 = total_1 > ((&imp_5)->crush_1.x);
    }
    else
    {
        _S591 = false;
    }
    if(_S591)
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
    uint _S610 = table_0 + 4U * g_0;
    uint _S611 = __ldg((&(globalParams_0->index_0)[_S610]));
    (&w_4)->island_2 = _S611;
    uint _S612 = __ldg((&(globalParams_0->index_0)[_S610 + 1U]));
    (&w_4)->begin_0 = _S612;
    uint _S613 = __ldg((&(globalParams_0->index_0)[_S610 + 2U]));
    (&w_4)->end_0 = _S613;
    uint _S614 = __ldg((&(globalParams_0->index_0)[_S610 + 3U]));
    (&w_4)->first_0 = _S614;
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
    uint _S615 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint4  _S616 = (&(globalParams_0->islands_0)[_S615])->info_1;
    bool _S617;
    if((((&(globalParams_0->islands_0)[_S615])->info_1.z) & 1U) != 0U)
    {
        _S617 = true;
    }
    else
    {
        uint _S618 = _S616.y;
        if(_S618 != 0U)
        {
            _S617 = _S618 <= (isl_0->info_1.w);
        }
        else
        {
            _S617 = false;
        }
    }
    return _S617;
}

static __device__ bool wide_runs_0(Island_0 * isl_1)
{
    uint4  _S619 = isl_1->info_1;
    bool _S620;
    if(((isl_1->info_1.z) & 1U) != 0U)
    {
        _S620 = true;
    }
    else
    {
        _S620 = (_S619.y) == 0U;
    }
    if(_S620)
    {
        return false;
    }
    if(((_S619.x) & 4U) == 0U)
    {
        _S620 = true;
    }
    else
    {
        bool _S621 = contact_stopped_0(isl_1);
        _S620 = !_S621;
    }
    return _S620;
}

__device__ __shared__ uint g_wide_run_0;

static __device__ bool wide_enter_0(uint tid_4, Island_0 * isl_2)
{
    seen_clear_0(tid_4);
    if(tid_4 == 0U)
    {
        bool _S622 = wide_runs_0(isl_2);
        int _S623;
        if(_S622)
        {
            _S623 = int(1);
        }
        else
        {
            _S623 = int(0);
        }
        *&g_wide_run_0 = uint(_S623);
    }
    __syncthreads();
    return (*&g_wide_run_0) != 0U;
}

static __device__ uint wide_step_0(Island_0 * isl_3)
{
    uint _S624 = isl_3->info_1.w;
    uint _S625 = __ldg(&globalParams_0->params_0->step_start_0);
    return _S624 - _S625;
}

static __device__ float time_since_0(float4  origin_0, uint k_8, float dt_2)
{
    float _S626 = __ldg(&globalParams_0->params_0->t_hi_0);
    float _S627 = _S626 - origin_0.x;
    float _S628 = __ldg(&globalParams_0->params_0->t_lo_0);
    return _S627 + (_S628 - origin_0.y) + float(k_8) * dt_2;
}

static __device__ float table_eval_0(uint offset_0, uint count_2, float tau_0)
{
    float4  _S629 = __ldg((&(globalParams_0->loads_0)[offset_0]));
    if(tau_0 <= (_S629.x))
    {
        return _S629.y;
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
        uint _S630 = offset_0 + i_10;
        float4  _S631 = __ldg((&(globalParams_0->loads_0)[_S630]));
        float _S632 = _S631.x;
        if(tau_0 <= _S632)
        {
            float4  _S633 = __ldg((&(globalParams_0->loads_0)[_S630 - 1U]));
            float _S634 = _S633.x;
            float _S635 = _S633.y;
            return _S635 + (tau_0 - _S634) / (F32_max((_S632 - _S634), (1.00000000317107685e-30f))) * (_S631.y - _S635);
        }
        i_10 = i_10 + 1U;
    }
    float4  _S636 = __ldg((&(globalParams_0->loads_0)[offset_0 + count_2 - 1U]));
    return _S636.y;
}

static __device__ float eval_function_0(uint term_0, uint k_9, float dt_3, float shift_0)
{
    uint _S637 = 5U * term_0;
    float4  _S638 = __ldg((&(globalParams_0->loads_0)[_S637]));
    uint4  info_2 = asuint_0(_S638);
    float4  _S639 = __ldg((&(globalParams_0->loads_0)[_S637 + 3U]));
    float4  _S640 = __ldg((&(globalParams_0->loads_0)[_S637 + 4U]));
    uint kind_0 = info_2.z;
    if(kind_0 == 0U)
    {
        return _S639.z;
    }
    float tau_1 = time_since_0(_S639, k_9, dt_3) + shift_0;
    float shape_1;
    if(kind_0 == 1U)
    {
        if(tau_1 <= 0.0f)
        {
            shape_1 = 0.0f;
        }
        else
        {
            float _S641 = _S640.x;
            if(tau_1 >= _S641)
            {
                shape_1 = _S640.y;
            }
            else
            {
                shape_1 = _S640.y * tau_1 / _S641;
            }
        }
        return shape_1;
    }
    bool _S642;
    if(kind_0 == 2U)
    {
        if(tau_1 < 0.0f)
        {
            _S642 = true;
        }
        else
        {
            _S642 = tau_1 > (_S640.x);
        }
        if(_S642)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S640.y * (F32_sin((3.14159274101257324f * tau_1 / _S640.x)));
        }
        return shape_1;
    }
    if(kind_0 == 3U)
    {
        float sn_0 = tau_1 / _S640.y;
        if(sn_0 < 0.0f)
        {
            _S642 = true;
        }
        else
        {
            _S642 = sn_0 > 1.0f;
        }
        if(_S642)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S640.x * (1.0f - sn_0) * (F32_exp((- _S640.z * sn_0)));
        }
        return shape_1;
    }
    if(kind_0 == 4U)
    {
        return table_eval_0(info_2.w, (F32_asuint((_S640.x))), tau_1);
    }
    if(kind_0 == 5U)
    {
        (*&g_seen_0)[1U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float sn_1 = tau_1 / _S640.x;
        if(sn_1 < 0.0f)
        {
            _S642 = true;
        }
        else
        {
            _S642 = sn_1 > 1.0f;
        }
        if(_S642)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = (1.0f - sn_1) * (F32_exp((- _S640.y * sn_1)));
        }
        float clearing_0 = _S639.w;
        float relax_0;
        if(clearing_0 > 0.0f)
        {
            relax_0 = (F32_max((1.0f - tau_1 / clearing_0), (0.0f)));
        }
        else
        {
            relax_0 = 0.0f;
        }
        float _S643 = _S640.w;
        return (_S643 + (_S640.z - _S643) * relax_0) * shape_1;
    }
    if(kind_0 == 7U)
    {
        (*&g_seen_0)[2U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float _S644 = _S640.y;
        if(tau_1 < _S644)
        {
            return _S640.x;
        }
        float s_1 = tau_1 - _S644;
        float _S645 = _S640.w;
        if(s_1 > _S645)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S640.z * (F32_sin((3.14159274101257324f * s_1 / _S645)));
        }
        return shape_1;
    }
    float _S646 = _S640.x;
    if(_S646 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp_0(1.0f - tau_1 / _S646, 0.0f, 1.0f);
}

static __device__ void record_chunk_load_0(uint c_5, float3  f_3, float3  t_2)
{
    uint _S647 = __ldg(&globalParams_0->params_0->solve_mode_0);
    if(_S647 == 0U)
    {
        return;
    }
    uint _S648 = __ldg(&globalParams_0->params_0->cload_base_0);
    uint _S649 = 2U * c_5;
    *(&(globalParams_0->scratch_0)[_S648 + _S649]) = make_float4 (f_3.x, f_3.y, f_3.z, 0.0f);
    uint _S650 = __ldg(&globalParams_0->params_0->cload_base_0);
    *(&(globalParams_0->scratch_0)[_S650 + _S649 + 1U]) = make_float4 (t_2.x, t_2.y, t_2.z, 0.0f);
    uint _S651 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  * _S652 = (&(globalParams_0->scratch_0)[_S651 + _S649]);
    uint _S653 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  _S654 = *(&(globalParams_0->scratch_0)[_S653 + _S649]);
    *_S652 = make_float4 ((float3 {_S654.x, _S654.y, _S654.z} + f_3).x, (float3 {_S654.x, _S654.y, _S654.z} + f_3).y, (float3 {_S654.x, _S654.y, _S654.z} + f_3).z, 0.0f);
    uint _S655 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  * _S656 = (&(globalParams_0->scratch_0)[_S655 + _S649 + 1U]);
    uint _S657 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  _S658 = *(&(globalParams_0->scratch_0)[_S657 + _S649 + 1U]);
    *_S656 = make_float4 ((float3 {_S658.x, _S658.y, _S658.z} + t_2).x, (float3 {_S658.x, _S658.y, _S658.z} + t_2).y, (float3 {_S658.x, _S658.y, _S658.z} + t_2).z, 0.0f);
    return;
}

static __device__ void chunk_loads_0(uint _S659, uint _S660, Quat_0 * _S661, uint _S662, float _S663, bool _S664, float _S665, float3  * _S666, float3  * _S667, float3  * _S668, float3  * _S669)
{
    bool _S670;
    ChunkStatic_0 * _S671 = (&(globalParams_0->chunks_0)[_S660]);
    float3  _S672 = make_float3 (0.0f);
    *_S666 = _S672;
    *_S667 = _S672;
    *_S668 = _S672;
    *_S669 = _S672;
    uint4  _S673 = __ldg(&_S671->load_range_0);
    uint term_1 = _S673.x;
    for(;;)
    {
        if(term_1 < (_S673.y))
        {
        }
        else
        {
            break;
        }
        (*&g_seen_0)[0U] = 1U;
        uint _S674 = 5U * term_1;
        float4  _S675 = __ldg((&(globalParams_0->loads_0)[_S674]));
        uint _S676 = asuint_0(_S675).y;
        bool replacement_0 = _S676 == 2U;
        float4  _S677 = __ldg((&(globalParams_0->loads_0)[_S674 + 1U]));
        float4  _S678 = __ldg((&(globalParams_0->loads_0)[_S674 + 2U]));
        float _S679;
        if(replacement_0)
        {
            _S679 = _S665;
        }
        else
        {
            _S679 = 0.0f;
        }
        float value_0 = eval_function_0(term_1, _S662, _S663, _S679);
        if(replacement_0)
        {
            *_S668 = *_S668 + float3 {_S677.x, _S677.y, _S677.z} * make_float3 (value_0);
            *_S669 = *_S669 + float3 {_S678.x, _S678.y, _S678.z} * make_float3 (value_0);
            term_1 = term_1 + 1U;
            continue;
        }
        if(_S676 == 0U)
        {
            _S670 = true;
        }
        else
        {
            _S670 = _S676 == 3U;
        }
        float3  fw_0;
        if(_S670)
        {
            fw_0 = float3 {_S677.x, _S677.y, _S677.z} * make_float3 (value_0);
        }
        else
        {
            float3  _S680 = rotate_0(_S661, float3 {_S677.x, _S677.y, _S677.z});
            fw_0 = _S680 * make_float3 (- value_0 * _S677.w);
        }
        float3  lever_0;
        if(_S676 == 3U)
        {
            float4  _S681 = *(&(globalParams_0->state_0)[4U * _S659]);
            lever_0 = float3 {_S678.x, _S678.y, _S678.z} - float3 {_S681.x, _S681.y, _S681.z};
        }
        else
        {
            lever_0 = float3 {_S678.x, _S678.y, _S678.z};
        }
        *_S666 = *_S666 + fw_0;
        float3  _S682 = rotate_0(_S661, lever_0);
        *_S667 = *_S667 + cross_0(_S682, fw_0);
        term_1 = term_1 + 1U;
    }
    if(_S664)
    {
        uint4  _S683 = __ldg(&_S671->cinfo_0);
        _S670 = (_S683.z) != 0U;
    }
    else
    {
        _S670 = false;
    }
    if(_S670)
    {
        uint4  _S684 = __ldg(&_S671->cinfo_0);
        uint g_1 = _S684.x;
        for(;;)
        {
            if(g_1 < (_S684.y))
            {
            }
            else
            {
                break;
            }
            uint _S685 = __ldg(&globalParams_0->params_0->seg_base_0);
            uint _S686 = 2U * g_1;
            float4  _S687 = *(&(globalParams_0->scratch_0)[_S685 + _S686]);
            *_S666 = *_S666 + float3 {_S687.x, _S687.y, _S687.z};
            uint _S688 = __ldg(&globalParams_0->params_0->seg_base_0);
            float4  _S689 = *(&(globalParams_0->scratch_0)[_S688 + _S686 + 1U]);
            *_S667 = *_S667 + float3 {_S689.x, _S689.y, _S689.z};
            g_1 = g_1 + 1U;
        }
    }
    return;
}

static __device__ void chunk_external_0(uint _S690, uint _S691, Quat_0 * _S692, uint _S693, float _S694, bool _S695, float3  * _S696, float3  * _S697)
{
    float3  rf_0;
    float3  rm_0;
    chunk_loads_0(_S690, _S691, _S692, _S693, _S694, _S695, 0.0f, _S696, _S697, &rf_0, &rm_0);
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
    uint _S698;
    if(((*&g_seen_0)[0U]) != 0U)
    {
        _S698 = 32768U;
    }
    else
    {
        _S698 = 0U;
    }
    uint _S699;
    if(((*&g_seen_0)[1U]) != 0U)
    {
        _S699 = 65536U;
    }
    else
    {
        _S699 = 0U;
    }
    uint _S700 = _S698 | _S699;
    if(((*&g_seen_0)[2U]) != 0U)
    {
        _S698 = 131072U;
    }
    else
    {
        _S698 = 0U;
    }
    uint _S701 = _S700 | _S698;
    if(((*&g_seen_0)[3U]) != 0U)
    {
        _S698 = 32U;
    }
    else
    {
        _S698 = 0U;
    }
    uint _S702 = _S701 | _S698;
    if(((*&g_seen_0)[4U]) != 0U)
    {
        _S698 = 64U;
    }
    else
    {
        _S698 = 0U;
    }
    return _S702 | _S698;
}

static __device__ bool wide_enter_1(uint _S703, uint _S704)
{
    Island_0 _S705 = *(&(globalParams_0->islands_0)[_S704]);
    seen_clear_0(_S703);
    if(_S703 == 0U)
    {
        Island_0 _S706 = _S705;
        bool _S707 = wide_runs_0(&_S706);
        int _S708;
        if(_S707)
        {
            _S708 = int(1);
        }
        else
        {
            _S708 = int(0);
        }
        *&g_wide_run_0 = uint(_S708);
    }
    __syncthreads();
    return (*&g_wide_run_0) != 0U;
}

extern "C" __global__ void wide_wake()
{
    uint _S709 = 0U;
    uint _S710;
    uint _S711 = __ballot_sync(4294967295U, true);
    uint tid_5 = threadIdx.x;
    uint _S712 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S713 = blockIdx.x;
    WideGroup_0 wg_0 = wide_group_0(_S712, _S713);
    bool _S714 = _S713 != (wg_0.first_0);
    uint _S715 = __ballot_sync(_S711, _S714);
    if(_S714)
    {
        return;
    }
    else
    {
        uint _S716 = __ballot_sync(_S711, true);
        _S709 = _S716;
    }
    Island_0 * _S717 = (&(globalParams_0->islands_0)[wg_0.island_2]);
    Island_0 isl_4 = *_S717;
    uint _S718 = (*_S717).info_1.x;
    bool _S719 = (_S718 & 16U) == 0U;
    uint _S720 = __ballot_sync(_S709, _S719);
    bool _S721;
    uint c_7;
    if(_S719)
    {
        uint _S722 = __ballot_sync(_S709, true);
        _S721 = true;
        c_7 = _S722;
    }
    else
    {
        bool _S723 = wide_enter_1(tid_5, wg_0.island_2);
        bool _S724 = !_S723;
        uint _S725 = __ballot_sync(_S709, true);
        _S721 = _S724;
        c_7 = _S725;
    }
    uint _S726 = 0U;
    uint _S727 = __ballot_sync(c_7, _S721);
    if(_S721)
    {
        return;
    }
    else
    {
        uint _S728 = __ballot_sync(c_7, true);
        _S726 = _S728;
    }
    Quat_0 _S729 = quat_of_0(isl_4.rotation_0);
    bool _S730 = (_S718 & 4U) != 0U;
    float3  _S731 = make_float3 (0.0f);
    float3  norm_0 = _S731;
    float3  unused_1 = _S731;
    c_7 = isl_4.range_0.x + tid_5;
    uint cov_0;
    cov_0 = _S726;
    for(;;)
    {
        bool _S732 = c_7 < (isl_4.range_0.y);
        uint _S733 = __ballot_sync(cov_0, _S732);
        if(_S732)
        {
            uint _S734 = __ballot_sync(cov_0, true);
        }
        else
        {
            uint _S735 = __ballot_sync(cov_0, false);
            uint _S736 = __ballot_sync(cov_0, false);
            uint _S737 = __ballot_sync(_S726, true);
            _S710 = _S737;
            break;
        }
        Island_0 _S738 = isl_4;
        uint _S739 = wide_step_0(&_S738);
        float _S740 = __ldg(&globalParams_0->params_0->dt_0);
        Quat_0 _S741 = _S729;
        float _S742 = settled_chunk_load_0(c_7, &_S741, _S739, _S740, _S730);
        *&((&norm_0)->x) = *&((&norm_0)->x) + _S742;
        uint _S743 = __ballot_sync(cov_0, true);
        c_7 = c_7 + 256U;
        cov_0 = _S743;
    }
    group_sum3_0(tid_5, &norm_0, &unused_1, _S710);
    bool _S744 = tid_5 != 0U;
    uint _S745 = __ballot_sync(_S710, _S744);
    if(_S744)
    {
        return;
    }
    uint cov_1 = 1024U | (seen_bits_0());
    uint _S746 = __ldg(&globalParams_0->params_0->solve_mode_0);
    if(_S746 == 1U)
    {
        _S721 = (F32_abs((norm_0.x - isl_4.energy_1.z))) > (isl_4.energy_1.w);
    }
    else
    {
        _S721 = false;
    }
    if(_S721)
    {
        *&((&(&(globalParams_0->islands_0)[wg_0.island_2])->info_1)->x) = _S718 & 4294967279U;
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
    float4  _S747 = __ldg(&ptr_0->geom0_0);
    float4  _S748 = __ldg(&ptr_0->geom1_0);
    float4  _S749 = __ldg(&ptr_0->stiff0_0);
    float4  _S750 = __ldg(&ptr_0->stiff1_0);
    float4  _S751 = __ldg(&ptr_0->rebar0_0);
    float4  _S752 = __ldg(&ptr_0->rebar1_0);
    uint4  _S753 = __ldg(&ptr_0->ids_0);
    JointBond_0 _S754 = { _S747, _S748, _S749, _S750, _S751, _S752, _S753 };
    return _S754;
}

static __device__ bool is_damaged_0(JointState_0 * st_0)
{
    bool _S755;
    if((st_0->damage_0) > 0.0f)
    {
        _S755 = true;
    }
    else
    {
        _S755 = (st_0->crush_0) > 0.0f;
    }
    return _S755;
}

static __device__ bool connected_0(JointState_0 * st_1, bool has_rebar_0)
{
    bool _S756;
    if((st_1->damage_0) < 1.0f)
    {
        _S756 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S756 = (st_1->rebar_broken_0) == 0.0f;
        }
        else
        {
            _S756 = false;
        }
    }
    return _S756;
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
    float _S757 = q_lin_0.z;
    float axial_0 = fdiv_0(_S757, area_2);
    float bending_0 = fdiv_0((F32_abs((q_ang_0.x))), b_22->geom1_0.x) + fdiv_0((F32_abs((q_ang_0.y))), b_22->geom1_0.y);
    float _S758 = q_lin_0.x;
    float _S759 = q_lin_0.y;
    float shear_1 = fdiv_0(fsqrt_0(_S758 * _S758 + _S759 * _S759), area_2) + fdiv_0((F32_abs((q_ang_0.z))), b_22->geom0_0.w);
    Measures_0 m_2;
    (&m_2)->tension_0 = axial_0 + bending_0;
    (&m_2)->shear_0 = shear_1;
    float _S760 = - axial_0;
    (&m_2)->normal_compression_0 = (F32_max((_S760), (0.0f)));
    (&m_2)->compression_0 = _S760 + bending_0;
    (&m_2)->compressive_force_0 = (F32_max((- _S757), (0.0f)));
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
    float4  _S761 = mat_1->dif_0;
    float ref_0 = mat_1->dif_0.x;
    if(r_5 <= ref_0)
    {
        return 1.0f;
    }
    float _S762 = _S761.z;
    float f_5;
    if(r_5 <= _S762)
    {
        f_5 = fpow_0(fdiv_0(r_5, ref_0), _S761.y);
    }
    else
    {
        f_5 = fpow_0(fdiv_0(_S762, ref_0), _S761.y) * fpow_0(fdiv_0(r_5, _S762), _S761.w);
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
    float _S763 = (F32_min((mat_3->strength_0.z * multiplier_0 + mat_3->strength_0.w * m_3->normal_compression_0), (mat_3->energy_0.x * multiplier_0)));
    float4  idx_0;
    *&((&idx_0)->x) = (F32_max((fdiv_0(m_3->tension_0, mat_3->strength_0.x * multiplier_0)), (0.0f)));
    float _S764;
    if(_S763 > 0.0f)
    {
        _S764 = fdiv_0(m_3->shear_0, _S763);
    }
    else
    {
        _S764 = infinity_0();
    }
    *&((&idx_0)->y) = _S764;
    *&((&idx_0)->z) = (F32_max((fdiv_0(m_3->compression_0, fc_0)), (0.0f)));
    float _S765 = b_24->stiff1_0.y;
    if(_S765 > 0.0f)
    {
        _S764 = fdiv_0(m_3->compressive_force_0, _S765);
    }
    else
    {
        _S764 = 0.0f;
    }
    *&((&idx_0)->w) = _S764;
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
    float _S766 = (F32_max((damage_law_0(kind_2, lambda_0, r_7)), (d_old_0)));
    bool _S767;
    if(_S766 <= d_old_0)
    {
        _S767 = true;
    }
    else
    {
        _S767 = d_old_0 >= 1.0f;
    }
    if(_S767)
    {
        return make_float2 (d_old_0, 0.0f);
    }
    float u0_0 = fdiv_0(psi_0, lambda_0 * lambda_0);
    float _S768 = (F32_max((kappa_old_0), (1.0f)));
    if(kind_2 == 0U)
    {
        if(r_7 > 1.0f)
        {
            return make_float2 (_S766, fdiv_0(u0_0 * r_7, r_7 - 1.0f) * (F32_max(((F32_min((lambda_0), (r_7))) - (F32_min((_S768), (r_7)))), (0.0f))));
        }
        return make_float2 (_S766, (1.0f - d_old_0) * psi_0);
    }
    float ku_0 = 0.5f * (r_7 + 1.0f);
    float plateau_0 = u0_0 * (F32_max(((F32_min((lambda_0), (ku_0))) - (F32_min((_S768), (ku_0)))), (0.0f)));
    float snap_0;
    if(_S766 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return make_float2 (_S766, plateau_0 + snap_0);
}

static __device__ void compressed_region_0(float w0_0, float w1_0, float dz_0, float ax_0, float ay_0, FixedArray<float, 6>  * region_0)
{
    uint count_3;
    float h0_0 = 0.5f * w0_0;
    float h1_0 = 0.5f * w1_0;
    float _S769 = - h0_0;
    float _S770 = - h1_0;
    FixedArray<float2 , 4>  _S771 = { {
        float2 {
            _S769, _S770
        }, float2 {
            h0_0, _S770
        }, float2 {
            h0_0, h1_0
        }, float2 {
            _S769, h1_0
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
        uint _S772 = i_11;
        uint _S773 = i_11 + 1U;
        uint _S774 = _S773 % 4U;
        float _S775 = _S771[i_11].y;
        float _S776 = _S771[i_11].x;
        float fp_0 = dz_0 + ax_0 * _S775 - ay_0 * _S776;
        float _S777 = _S771[_S774].y;
        float _S778 = _S771[_S774].x;
        float fq_0 = dz_0 + ax_0 * _S777 - ay_0 * _S778;
        bool _S779 = fp_0 < 0.0f;
        if(_S779)
        {
            uint _S780 = count_4 + 1U;
            poly_0[count_4] = _S771[_S772];
            count_3 = _S780;
        }
        else
        {
            count_3 = count_4;
        }
        if(_S779 != (fq_0 < 0.0f))
        {
            float t_4 = fp_0 / (fp_0 - fq_0);
            uint _S781 = count_3 + 1U;
            poly_0[count_3] = make_float2 (_S776 + t_4 * (_S778 - _S776), _S775 + t_4 * (_S777 - _S775));
            count_4 = _S781;
        }
        else
        {
            count_4 = count_3;
        }
        i_11 = _S773;
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
        float _S782 = o_1.x;
        float x0_0 = poly_0[i_11].x - _S782;
        float _S783 = o_1.y;
        float y0_0 = poly_0[i_11].y - _S783;
        uint _S784 = i_11 + 1U;
        uint _S785 = _S784 % count_4;
        float x1_0 = poly_0[_S785].x - _S782;
        float y1_0 = poly_0[_S785].y - _S783;
        float _S786 = x0_0 * y1_0;
        float _S787 = x1_0 * y0_0;
        float cr_0 = _S786 - _S787;
        float a_11 = a_10 + cr_0 / 2.0f;
        float sx_1 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        float sy_1 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        float ixx_1 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        float iyy_1 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        float ixy_1 = ixy_0 + (_S786 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S787) * cr_0 / 24.0f;
        i_11 = _S784;
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
    float _S788 = a_10 * cx_0;
    (*region_0)[int(3)] = ixx_0 - _S788 * cx_0;
    (*region_0)[int(4)] = iyy_0 - a_10 * cy_0 * cy_0;
    (*region_0)[int(5)] = ixy_0 - _S788 * cy_0;
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
    float _S789 = a_12 * fc_1;
    float _S790 = - ay_1;
    return make_float4 (k_11 * a_12 * fc_1, k_11 * (_S789 * r_8[int(2)] + (_S790 * r_8[int(5)] + ax_1 * r_8[int(4)])), - k_11 * (_S789 * r_8[int(1)] + (_S790 * r_8[int(3)] + ax_1 * r_8[int(5)])), 0.5f * k_11 * (_S789 * fc_1 + ay_1 * ay_1 * r_8[int(3)] + ax_1 * ax_1 * r_8[int(4)] - 2.0f * ax_1 * ay_1 * r_8[int(5)]));
}

static __device__ float signum_0(float x_20)
{
    float _S791;
    if(((F32_asuint((x_20))) & 2147483648U) != 0U)
    {
        _S791 = -1.0f;
    }
    else
    {
        _S791 = 1.0f;
    }
    return _S791;
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
    float3  _S792 = make_float3 (0.0f);
    (&c_8)->q_lin_1 = _S792;
    (&c_8)->q_ang_1 = _S792;
    (&c_8)->energy_2 = 0.0f;
    (&c_8)->diss_2 = 0.0f;
    (&c_8)->plastic_1 = plastic_2;
    uint _S793 = mat_4->kind_flags_0.y;
    if((_S793 & 2U) == 0U)
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
    if((_S793 & 4U) != 0U)
    {
        float4  p_9 = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        float _S794 = p_9.y;
        float _S795 = p_9.z;
        float _S796 = p_9.w;
        nc_sum_0 = p_9.x;
        m1_0 = _S794;
        m2_0 = _S795;
        energy_3 = _S796;
    }
    else
    {
        float ki_0 = kn_1 * (1.0f - crush_2) / 36.0f;
        float _S797 = d_ang_0.x;
        float _S798 = d_ang_0.y;
        float spread_0 = (F32_abs((_S797))) * 0.4166666567325592f * w1_2 + (F32_abs((_S798))) * 0.4166666567325592f * w0_2;
        float _S799 = d_lin_0.z;
        float slack_0 = 9.99999997475242708e-07f * ((F32_abs((_S799))) + spread_0);
        if((_S799 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S799 + spread_0) < (- slack_0))
            {
                float i1_0 = 2.91666650772094727f * w0_2 * w0_2;
                float i2_0 = 2.91666650772094727f * w1_2 * w1_2;
                float _S800 = ki_0 * _S797 * i2_0;
                float _S801 = ki_0 * _S798 * i1_0;
                float _S802 = 0.5f * ki_0 * (36.0f * _S799 * _S799 + _S797 * _S797 * i2_0 + _S798 * _S798 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S799;
                m1_0 = _S800;
                m2_0 = _S801;
                energy_3 = _S802;
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
                    float _S803 = SPRING_AT_0[i_12] * w0_2;
                    uint j_6 = 0U;
                    nc_sum_0 = diss_3;
                    m1_0 = m1_1;
                    m2_0 = m2_1;
                    energy_3 = energy_4;
                    for(;;)
                    {
                        if(j_6 < 6U)
                        {
                        }
                        else
                        {
                            break;
                        }
                        float s2_0 = SPRING_AT_0[j_6] * w1_2;
                        float di_0 = _S799 + _S797 * s2_0 - _S798 * _S803;
                        if(di_0 < 0.0f)
                        {
                            float f_7 = ki_0 * di_0;
                            float m1_2 = m1_0 + f_7 * s2_0;
                            float m2_2 = m2_0 - f_7 * _S803;
                            float energy_5 = energy_3 + 0.5f * ki_0 * di_0 * di_0;
                            nc_sum_0 = nc_sum_0 + f_7;
                            m1_0 = m1_2;
                            m2_0 = m2_2;
                            energy_3 = energy_5;
                        }
                        j_6 = j_6 + 1U;
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
    float3  p_10 = plastic_2;
    (&c_8)->q_lin_1 = make_float3 (0.0f, 0.0f, nc_sum_0);
    (&c_8)->q_ang_1 = make_float3 (m1_0, m2_0, 0.0f);
    float slide_cap_0 = mat_4->strength_0.w * nc_0;
    float _S804 = ks_0 * (d_lin_0.x - plastic_2.x);
    float _S805 = ks_0 * (d_lin_0.y - plastic_2.y);
    float tn_0 = fsqrt_0(_S804 * _S804 + _S805 * _S805);
    bool _S806;
    if(tn_0 > slide_cap_0)
    {
        _S806 = tn_0 > 0.0f;
    }
    else
    {
        _S806 = false;
    }
    if(_S806)
    {
        float _S807 = fdiv_0(_S804, tn_0);
        float _S808 = fdiv_0(_S805, tn_0);
        float dslip_0 = fdiv_0(tn_0 - slide_cap_0, ks_0);
        *&((&p_10)->x) = *&((&p_10)->x) + _S807 * dslip_0;
        *&((&p_10)->y) = *&((&p_10)->y) + _S808 * dslip_0;
        *&((&(&c_8)->q_lin_1)->x) = _S807 * slide_cap_0;
        *&((&(&c_8)->q_lin_1)->y) = _S808 * slide_cap_0;
        diss_3 = slide_cap_0 * dslip_0;
    }
    else
    {
        *&((&(&c_8)->q_lin_1)->x) = _S804;
        *&((&(&c_8)->q_lin_1)->y) = _S805;
        diss_3 = 0.0f;
    }
    float2  tq_0 = return_map_0(kt_0, d_ang_0.z, p_10.z, slide_cap_0 * b_25->geom1_0.z);
    float _S809 = tq_0.x;
    float _S810 = tq_0.y;
    float diss_4 = diss_3 + (F32_abs((_S809))) * (F32_abs((_S810)));
    *&((&p_10)->z) = *&((&p_10)->z) + _S810;
    *&((&(&c_8)->q_ang_1)->z) = _S809;
    (&c_8)->energy_2 = energy_3 + 0.5f * (fdiv_0(sq_0((&c_8)->q_lin_1.x), ks_0) + fdiv_0(sq_0((&c_8)->q_lin_1.y), ks_0) + fdiv_0(sq_0(_S809), kt_0));
    (&c_8)->diss_2 = diss_4;
    (&c_8)->plastic_1 = p_10;
    return c_8;
}

static __device__ float3  contact_offsets_0(JointMaterial_0 * mat_5, JointBond_0 * b_26, float crush_3, float3  plastic_3, float3  d_lin_1, float3  d_ang_1)
{
    uint _S811 = mat_5->kind_flags_0.y;
    if((_S811 & 2U) == 0U)
    {
        return plastic_3;
    }
    float kn_2 = b_26->stiff0_0.x;
    float ks_1 = b_26->stiff0_0.y;
    float kt_1 = b_26->stiff1_0.x;
    float w0_3 = b_26->geom0_0.y;
    float w1_3 = b_26->geom0_0.z;
    float nc_sum_1;
    if((_S811 & 4U) != 0U)
    {
        float4  _S812 = no_tension_patch_0(kn_2 * (1.0f - crush_3), w0_3, w1_3, d_lin_1.z, d_ang_1.x, d_ang_1.y);
        nc_sum_1 = _S812.x;
    }
    else
    {
        float ki_1 = kn_2 * (1.0f - crush_3) / 36.0f;
        float _S813 = d_ang_1.x;
        float _S814 = d_ang_1.y;
        float spread_1 = (F32_abs((_S813))) * 0.4166666567325592f * w1_3 + (F32_abs((_S814))) * 0.4166666567325592f * w0_3;
        float _S815 = d_lin_1.z;
        float slack_1 = 9.99999997475242708e-07f * ((F32_abs((_S815))) + spread_1);
        if((_S815 - spread_1) > slack_1)
        {
            nc_sum_1 = 0.0f;
        }
        else
        {
            if((_S815 + spread_1) < (- slack_1))
            {
                nc_sum_1 = ki_1 * 36.0f * _S815;
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
                    float _S816 = SPRING_AT_0[i_13] * w0_3;
                    uint j_7 = 0U;
                    nc_sum_1 = nc_sum_2;
                    for(;;)
                    {
                        if(j_7 < 6U)
                        {
                        }
                        else
                        {
                            break;
                        }
                        float di_1 = _S815 + _S813 * (SPRING_AT_0[j_7] * w1_3) - _S814 * _S816;
                        if(di_1 < 0.0f)
                        {
                            nc_sum_1 = nc_sum_1 + ki_1 * di_1;
                        }
                        j_7 = j_7 + 1U;
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
    float _S817 = ks_1 * (d_lin_1.x - plastic_3.x);
    float _S818 = ks_1 * (d_lin_1.y - plastic_3.y);
    float tn_1 = fsqrt_0(_S817 * _S817 + _S818 * _S818);
    bool _S819;
    if(tn_1 > slide_cap_1)
    {
        _S819 = tn_1 > 0.0f;
    }
    else
    {
        _S819 = false;
    }
    if(_S819)
    {
        float _S820 = fdiv_0(_S818, tn_1);
        float dslip_1 = fdiv_0(tn_1 - slide_cap_1, ks_1);
        *&((&p_11)->x) = *&((&p_11)->x) + fdiv_0(_S817, tn_1) * dslip_1;
        *&((&p_11)->y) = *&((&p_11)->y) + _S820 * dslip_1;
    }
    *&((&p_11)->z) = *&((&p_11)->z) + return_map_0(kt_1, d_ang_1.z, p_11.z, slide_cap_1 * b_26->geom1_0.z).y;
    return p_11;
}

static __device__ float life_rate_0(JointMaterial_0 * mat_6, float s_2)
{
    if(s_2 <= 0.0f)
    {
        return 0.0f;
    }
    float _S821 = mat_6->misc_0.y;
    return fdiv_0((_S821 + 1.0f) * fpow_0(s_2, _S821), mat_6->misc_0.z);
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
    float4  _S822 = b_27->stiff1_0;
    float kt_2 = b_27->stiff1_0.x;
    bool has_rebar_1 = (b_27->stiff1_0.w) != 0.0f;
    uint kind_3 = mat_7->kind_flags_0.x;
    uint flags_1 = mat_7->kind_flags_0.y;
    bool softening_0 = (flags_1 & 1U) != 0U;
    JointState_0 st_2 = *state_2;
    bool _S823 = connected_0(state_2, has_rebar_1);
    float3  qe_lin_0 = d_lin_2 * make_float3 (ks_2, ks_2, kn_3);
    float3  qe_ang_0 = d_ang_2 * make_float3 (kb1_0, kb2_0, kt_2);
    Measures_0 _S824 = stress_measures_0(b_27, qe_lin_0, qe_ang_0);
    float _S825 = (F32_max(((F32_max((_S824.tension_0), (_S824.shear_0)))), (_S824.compression_0)));
    bool _S826 = dt_5 > 0.0f;
    float dif_1;
    if(_S826)
    {
        float raw_0 = fdiv_0((F32_max((fdiv_0(_S825 - (&st_2)->governing_stress_0, dt_5)), (0.0f))), mat_7->misc_0.w);
        float tau_2 = _S822.z;
        if((flags_1 & 16U) != 0U)
        {
            dif_1 = - expm1_accurate_0(- fdiv_0(dt_5, tau_2));
        }
        else
        {
            dif_1 = (F32_min((fdiv_0(dt_5, tau_2)), (1.0f)));
        }
        (&st_2)->strain_rate_0 = (&st_2)->strain_rate_0 + (raw_0 - (&st_2)->strain_rate_0) * dif_1;
        (&st_2)->governing_stress_0 = _S825;
    }
    if((flags_1 & 32U) != 0U)
    {
        float _S827 = dif_factor_0(mat_7, (&st_2)->strain_rate_0);
        dif_1 = _S827;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = b_27->geom1_0.w;
    float _S828 = fatigue_factor_0(mat_7, (&st_2)->life_0);
    float multiplier_1 = weibull_0 * dif_1 * _S828;
    Measures_0 _S829 = _S824;
    float4  _S830 = failure_indices_0(mat_7, b_27, &_S829, multiplier_1);
    float _S831 = _S830.x;
    float _S832 = _S830.y;
    (&st_2)->utilization_0 = (F32_max(((F32_max((_S831), (_S832)))), ((F32_max((_S830.z), (_S830.w))))));
    float _S833 = d_lin_2.x;
    float _S834 = d_lin_2.y;
    float _S835 = ks_2 * (sq_0(_S833) + sq_0(_S834)) + kb1_0 * sq_0(d_ang_2.x) + kb2_0 * sq_0(d_ang_2.y) + kt_2 * sq_0(d_ang_2.z);
    float _S836 = d_lin_2.z;
    bool _S837 = _S836 > 0.0f;
    if(_S837)
    {
        dif_1 = kn_3 * sq_0(_S836);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S835 + dif_1);
    float psi_c_0;
    if(_S836 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_3 * sq_0(_S836);
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
    bool _S838;
    float3  qc_lin_0;
    if(fracture_1)
    {
        bool _S839 = _S831 >= _S832;
        if(_S839)
        {
            diss_contact_0 = _S831;
        }
        else
        {
            diss_contact_0 = _S832;
        }
        uint mode_ts_0;
        if(_S839)
        {
            mode_ts_0 = 1U;
        }
        else
        {
            mode_ts_0 = 2U;
        }
        if(diss_contact_0 > ((&st_2)->kappa_0))
        {
            _S838 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S838 = false;
        }
        if(_S838)
        {
            _S838 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S838 = false;
        }
        uint mode_c_0;
        if(_S838)
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
            float _S840 = inc_0.x;
            if(_S840 > ((&st_2)->damage_0))
            {
                Contact_0 _S841 = contact_part_0(mat_7, b_27, (&st_2)->crush_0, plastic_4, d_lin_2, d_ang_2);
                float _S842 = (F32_max((_S841.energy_2 - (1.0f - (&st_2)->crush_0) * psi_c_0), (0.0f)));
                float _S843 = (F32_max((inc_0.y - _S842 * (_S840 - (&st_2)->damage_0)), (0.0f)));
                float _S844 = (F32_max(((psi_ts_0 - _S842) * (_S840 - (&st_2)->damage_0) - _S843), (0.0f)));
                (&st_2)->damage_0 = _S840;
                (&st_2)->mode_0 = mode_ts_0;
                dissipated_3 = _S843;
                overshoot_1 = _S844;
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
        float _S845 = state_2->damage_0;
        if((state_2->damage_0) > 0.0f)
        {
            Contact_0 _S846 = contact_part_0(mat_7, b_27, state_2->crush_0, make_float3 (state_2->plastic_x_0, state_2->plastic_y_0, state_2->plastic_t_0), d_lin_2, d_ang_2);
            qc_lin_0 = qe_ang_0 * make_float3 (1.0f - _S845) + _S846.q_ang_1 * make_float3 (_S845);
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S847 = stress_measures_0(b_27, make_float3 (0.0f, 0.0f, (F32_min((qe_lin_0.z), (0.0f)))), qc_lin_0);
        Measures_0 _S848 = _S847;
        float4  _S849 = failure_indices_0(mat_7, b_27, &_S848, multiplier_1);
        float _S850 = _S849.z;
        float _S851 = _S849.w;
        bool _S852 = _S850 >= _S851;
        if(_S852)
        {
            psi_contact_0 = _S850;
        }
        else
        {
            psi_contact_0 = _S851;
        }
        if(_S852)
        {
            mode_c_0 = 3U;
        }
        else
        {
            mode_c_0 = 4U;
        }
        if(psi_contact_0 > ((&st_2)->kappa_c_0))
        {
            _S838 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S838 = false;
        }
        if(_S838)
        {
            _S838 = psi_c_0 > 0.0f;
        }
        else
        {
            _S838 = false;
        }
        if(_S838)
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
            float _S853 = inc_1.x;
            if(_S853 > ((&st_2)->crush_0))
            {
                float _S854 = inc_1.y;
                float dissipated_4 = dissipated_3 + _S854;
                float overshoot_2 = overshoot_1 + (F32_max((psi_c_0 * (_S853 - (&st_2)->crush_0) - _S854), (0.0f)));
                (&st_2)->crush_0 = _S853;
                (&st_2)->mode_0 = mode_c_0;
                if(_S853 >= 1.0f)
                {
                    _S838 = ((&st_2)->damage_0) < 1.0f;
                }
                else
                {
                    _S838 = false;
                }
                if(_S838)
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
    float3  _S855 = make_float3 (0.0f);
    float3  qc_ang_0;
    if(((&st_2)->damage_0) == 0.0f)
    {
        if((flags_1 & 8U) == 0U)
        {
            float3  _S856 = contact_offsets_0(mat_7, b_27, (&st_2)->crush_0, plastic_4, d_lin_2, d_ang_2);
            (&st_2)->plastic_x_0 = _S856.x;
            (&st_2)->plastic_y_0 = _S856.y;
            (&st_2)->plastic_t_0 = _S856.z;
        }
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S855;
        qc_ang_0 = _S855;
        psi_contact_0 = 0.0f;
    }
    else
    {
        Contact_0 _S857 = contact_part_0(mat_7, b_27, (&st_2)->crush_0, plastic_4, d_lin_2, d_ang_2);
        (&st_2)->plastic_x_0 = _S857.plastic_1.x;
        (&st_2)->plastic_y_0 = _S857.plastic_1.y;
        (&st_2)->plastic_t_0 = _S857.plastic_1.z;
        diss_contact_0 = _S857.diss_2;
        qc_lin_0 = _S857.q_lin_1;
        qc_ang_0 = _S857.q_ang_1;
        psi_contact_0 = _S857.energy_2;
    }
    float dissipated_6 = dissipated_3 + dmg_0 * diss_contact_0;
    if(_S837)
    {
        intact_normal_0 = kn_3 * _S836;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_2)->crush_0) * kn_3 * _S836;
    }
    float _S858 = 1.0f - dmg_0;
    float3  force_lin_2 = make_float3 (_S858 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S858 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S858 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3  force_ang_2 = qe_ang_0 * make_float3 (_S858) + qc_ang_0 * make_float3 (dmg_0);
    float stored_4 = _S858 * (psi_ts_0 + (1.0f - (&st_2)->crush_0) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S838 = ((&st_2)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S838 = false;
    }
    float stored_5;
    float3  force_lin_3;
    if(_S838)
    {
        float k_axial_0 = b_27->rebar0_0.x;
        float k_dowel_0 = b_27->rebar0_0.y;
        float yield_force_0 = b_27->rebar0_0.z;
        float dowel_capacity_0 = b_27->rebar0_0.w;
        float2  nr_0 = return_map_0(k_axial_0, _S836, (&st_2)->rebar_plastic_0, yield_force_0);
        float2  v1_0 = return_map_0(k_dowel_0, _S833, (&st_2)->rebar_slip0_0, dowel_capacity_0);
        float2  v2_0 = return_map_0(k_dowel_0, _S834, (&st_2)->rebar_slip1_0, dowel_capacity_0);
        float _S859 = nr_0.y;
        float _S860 = v1_0.y;
        float _S861 = v2_0.y;
        float work_0 = yield_force_0 * (F32_abs((_S859))) + dowel_capacity_0 * ((F32_abs((_S860))) + (F32_abs((_S861))));
        (&st_2)->rebar_plastic_0 = (&st_2)->rebar_plastic_0 + _S859;
        (&st_2)->rebar_slip0_0 = (&st_2)->rebar_slip0_0 + _S860;
        (&st_2)->rebar_slip1_0 = (&st_2)->rebar_slip1_0 + _S861;
        (&st_2)->rebar_work_0 = (&st_2)->rebar_work_0 + work_0;
        float dissipated_7 = dissipated_6 + work_0;
        float _S862 = nr_0.x;
        float _S863 = v1_0.x;
        float _S864 = v2_0.x;
        float elastic_0 = 0.5f * (fdiv_0(sq_0(_S862), k_axial_0) + fdiv_0(sq_0(_S863) + sq_0(_S864), k_dowel_0));
        if(fracture_1)
        {
            _S838 = ((&st_2)->rebar_work_0) >= (b_27->rebar1_0.x);
        }
        else
        {
            _S838 = false;
        }
        if(_S838)
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
            force_lin_3 = force_lin_2 + make_float3 (_S863, _S864, _S862);
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
        _S838 = _S826;
    }
    else
    {
        _S838 = false;
    }
    if(_S838)
    {
        _S838 = (flags_1 & 64U) != 0U;
    }
    else
    {
        _S838 = false;
    }
    if(_S838)
    {
        Measures_0 _S865 = stress_measures_0(b_27, force_lin_3, force_ang_2);
        Measures_0 _S866 = _S865;
        float4  _S867 = failure_indices_0(mat_7, b_27, &_S866, weibull_0);
        float _S868 = life_rate_0(mat_7, (F32_max(((F32_max((_S867.x), (_S867.y)))), (_S867.z))));
        (&st_2)->life_0 = (F32_max(((&st_2)->life_0 - _S868 * dt_5), (0.0f)));
    }
    (&st_2)->dissipated_0 = (&st_2)->dissipated_0 + dissipated_3;
    JointResponse_0 resp_0;
    (&resp_0)->force_lin_1 = force_lin_3;
    (&resp_0)->force_ang_1 = force_ang_2;
    (&resp_0)->state_1 = st_2;
    (&resp_0)->dissipated_2 = dissipated_3;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_3 = stored_5;
    if(_S823)
    {
        JointState_0 _S869 = st_2;
        bool _S870 = connected_0(&_S869, has_rebar_1);
        _S838 = !_S870;
    }
    else
    {
        _S838 = false;
    }
    (&resp_0)->disconnected_0 = _S838;
    (&resp_0)->fatigue_before_0 = _S828;
    (&resp_0)->measures_0 = _S824;
    return resp_0;
}

static __device__ void secant_factors_0(JointBond_0 * b_28, JointState_0 * st_3, float3  d_lin_3, float3  * f_lin_0, float3  * f_ang_0)
{
    float _S871 = st_3->damage_0;
    bool compressed_0 = (d_lin_3.z) < 0.0f;
    float contact_1;
    if(compressed_0)
    {
        contact_1 = _S871;
    }
    else
    {
        contact_1 = 0.0f;
    }
    float _S872 = 1.0f - _S871;
    float _S873 = (F32_max((_S872 + contact_1), (9.99999997475242708e-07f)));
    float normal_4;
    if(compressed_0)
    {
        normal_4 = (F32_max((1.0f - st_3->crush_0), (9.99999997475242708e-07f)));
    }
    else
    {
        normal_4 = (F32_max((_S872), (9.99999997475242708e-07f)));
    }
    *f_lin_0 = make_float3 (_S873, _S873, normal_4);
    *f_ang_0 = make_float3 (_S873);
    bool _S874;
    if((b_28->stiff1_0.w) != 0.0f)
    {
        _S874 = (st_3->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S874 = false;
    }
    if(_S874)
    {
        float4  _S875 = b_28->rebar0_0;
        float4  _S876 = b_28->stiff0_0;
        *&(f_lin_0->z) = *&(f_lin_0->z) + fdiv_0(b_28->rebar0_0.x, b_28->stiff0_0.x);
        float _S877 = fdiv_0(_S875.y, _S876.y);
        *&(f_lin_0->x) = *&(f_lin_0->x) + _S877;
        *&(f_lin_0->y) = *&(f_lin_0->y) + _S877;
    }
    return;
}

static __device__ float3  to_local_0(uint _S878, float3  _S879)
{
    BondStatic_0 * _S880 = (&(globalParams_0->bonds_0)[_S878]);
    float4  _S881 = __ldg(&_S880->t1_0);
    float _S882 = dot_0(_S879, float3 {_S881.x, _S881.y, _S881.z});
    float4  _S883 = __ldg(&_S880->t2_0);
    float _S884 = dot_0(_S879, float3 {_S883.x, _S883.y, _S883.z});
    float4  _S885 = __ldg(&_S880->normal_0);
    return make_float3 (_S882, _S884, dot_0(_S879, float3 {_S885.x, _S885.y, _S885.z}));
}

static __device__ float3  to_body_0(uint _S886, float3  _S887)
{
    BondStatic_0 * _S888 = (&(globalParams_0->bonds_0)[_S886]);
    float4  _S889 = __ldg(&_S888->t1_0);
    float3  _S890 = float3 {_S889.x, _S889.y, _S889.z} * make_float3 (_S887.x);
    float4  _S891 = __ldg(&_S888->t2_0);
    float3  _S892 = _S890 + float3 {_S891.x, _S891.y, _S891.z} * make_float3 (_S887.y);
    float4  _S893 = __ldg(&_S888->normal_0);
    return _S892 + float3 {_S893.x, _S893.y, _S893.z} * make_float3 (_S887.z);
}

static __device__ bool bond_update_0(uint i_14, float dt_6, bool fracture_2, uint abs_step_0, bool wide_0)
{
    BondStatic_0 * _S894 = (&(globalParams_0->bonds_0)[i_14]);
    JointBond_0 _S895 = slang_ldg_0(&_S894->law_0);
    uint ca_0 = _S895.ids_0.y;
    uint cb_0 = _S895.ids_0.z;
    float4  _S896 = __ldg(&_S894->ra_0);
    float3  ra_1 = float3 {_S896.x, _S896.y, _S896.z};
    float4  _S897 = __ldg(&_S894->rb_0);
    float3  rb_1 = float3 {_S897.x, _S897.y, _S897.z};
    uint _S898 = 4U * ca_0;
    float4  _S899 = *(&(globalParams_0->state_0)[_S898]);
    float4  _S900 = *(&(globalParams_0->state_0)[_S898 + 1U]);
    float3  ta_2 = float3 {_S900.x, _S900.y, _S900.z};
    float4  _S901 = *(&(globalParams_0->state_0)[_S898 + 2U]);
    float3  va_0 = float3 {_S901.x, _S901.y, _S901.z};
    float4  _S902 = *(&(globalParams_0->state_0)[_S898 + 3U]);
    float3  wa_1 = float3 {_S902.x, _S902.y, _S902.z};
    uint _S903 = 4U * cb_0;
    float4  _S904 = *(&(globalParams_0->state_0)[_S903]);
    float4  _S905 = *(&(globalParams_0->state_0)[_S903 + 1U]);
    float3  tb_2 = float3 {_S905.x, _S905.y, _S905.z};
    float4  _S906 = *(&(globalParams_0->state_0)[_S903 + 2U]);
    float3  vb_0 = float3 {_S906.x, _S906.y, _S906.z};
    float4  _S907 = *(&(globalParams_0->state_0)[_S903 + 3U]);
    float3  wb_0 = float3 {_S907.x, _S907.y, _S907.z};
    float3  _S908 = to_local_0(i_14, float3 {_S904.x, _S904.y, _S904.z} + cross_0(tb_2, rb_1) - (float3 {_S899.x, _S899.y, _S899.z} + cross_0(ta_2, ra_1)));
    float3  _S909 = to_local_0(i_14, tb_2 - ta_2);
    float3  _S910 = to_local_0(i_14, vb_0 + cross_0(wb_0, rb_1) - (va_0 + cross_0(wa_1, ra_1)));
    float3  _S911 = to_local_0(i_14, wb_0 - wa_1);
    JointBond_0 _S912 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_14])->law_0);
    JointState_0 previous_0 = (&(globalParams_0->bond_dyn_0)[i_14])->js_0;
    JointState_0 _S913 = (&(globalParams_0->bond_dyn_0)[i_14])->js_0;
    bool _S914 = is_damaged_0(&_S913);
    JointBond_0 _S915 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_14])->law_0);
    JointBond_0 _S916 = _S915;
    JointState_0 _S917 = (&(globalParams_0->bond_dyn_0)[i_14])->js_0;
    JointResponse_0 _S918 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S912.ids_0.x], &_S916, &_S917, _S908, _S909, dt_6, fracture_2);
    BondStatic_0 * _S919 = (&(globalParams_0->bonds_0)[i_14]);
    BondDyn_0 bd_0 = *(&(globalParams_0->bond_dyn_0)[i_14]);
    float4  _S920 = __ldg(&_S919->ra_0);
    float3  ra_2 = float3 {_S920.x, _S920.y, _S920.z};
    float4  _S921 = __ldg(&_S919->rb_0);
    float3  rb_2 = float3 {_S921.x, _S921.y, _S921.z};
    JointBond_0 _S922 = slang_ldg_0(&_S919->law_0);
    JointBond_0 _S923 = _S922;
    JointState_0 _S924 = _S918.state_1;
    float3  f_lin_1;
    float3  f_ang_1;
    secant_factors_0(&_S923, &_S924, _S908, &f_lin_1, &f_ang_1);
    float4  _S925 = __ldg(&_S919->c_lin_0);
    float3  qd_lin_0 = _S910 * float3 {_S925.x, _S925.y, _S925.z} * f_lin_1;
    float4  _S926 = __ldg(&_S919->c_ang_0);
    float3  qd_ang_0 = _S911 * float3 {_S926.x, _S926.y, _S926.z} * f_ang_1;
    float3  q_lin_2 = _S918.force_lin_1 + qd_lin_0;
    float3  q_ang_2 = _S918.force_ang_1 + qd_ang_0;
    float damped_0 = (dot_0(qd_lin_0, _S910) + dot_0(qd_ang_0, _S911)) * dt_6;
    float3  _S927 = to_body_0(i_14, q_lin_2);
    float3  _S928 = to_body_0(i_14, q_ang_2);
    uint _S929 = 3U * i_14;
    *(&(globalParams_0->scratch_0)[_S929]) = make_float4 (_S927.x, _S927.y, _S927.z, (F32_max((_S918.measures_0.tension_0), (_S918.measures_0.compression_0))));
    *(&(globalParams_0->scratch_0)[_S929 + 1U]) = make_float4 ((_S928 + cross_0(ra_2, _S927)).x, (_S928 + cross_0(ra_2, _S927)).y, (_S928 + cross_0(ra_2, _S927)).z, 0.0f);
    *(&(globalParams_0->scratch_0)[_S929 + 2U]) = make_float4 ((- _S928 + cross_0(rb_2, - _S927)).x, (- _S928 + cross_0(rb_2, - _S927)).y, (- _S928 + cross_0(rb_2, - _S927)).z, 0.0f);
    comp_add1_0(&((&(&bd_0)->sums_0)->x), &((&(&bd_0)->comps_0)->x), _S918.dissipated_2);
    comp_add1_0(&((&(&bd_0)->sums_0)->y), &((&(&bd_0)->comps_0)->y), _S918.overshoot_0);
    comp_add1_0(&((&(&bd_0)->sums_0)->z), &((&(&bd_0)->comps_0)->z), damped_0);
    (&bd_0)->force_lin_0 = make_float4 (q_lin_2.x, q_lin_2.y, q_lin_2.z, _S918.stored_3);
    (&bd_0)->force_ang_0 = make_float4 (q_ang_2.x, q_ang_2.y, q_ang_2.z, (F32_max(((&bd_0)->force_ang_0.w), (_S918.state_1.utilization_0))));
    bool _S930;
    if(!_S914)
    {
        JointState_0 _S931 = _S918.state_1;
        bool _S932 = is_damaged_0(&_S931);
        _S930 = _S932;
    }
    else
    {
        _S930 = false;
    }
    if(_S930)
    {
        _S930 = ((&bd_0)->events_0.x) == 0U;
    }
    else
    {
        _S930 = false;
    }
    if(_S930)
    {
        *&((&(&bd_0)->events_0)->x) = abs_step_0;
        *&((&(&bd_0)->events_0)->w) = _S918.state_1.mode_0;
        if(wide_0)
        {
            cov_or_0(_S922.ids_0.w, 32U);
        }
        else
        {
            (*&g_seen_0)[3U] = 1U;
        }
    }
    if(((&bd_0)->events_0.y) == 0U)
    {
        _S930 = (_S918.state_1.life_0) != (previous_0.life_0);
    }
    else
    {
        _S930 = false;
    }
    if(_S930)
    {
        _S930 = (_S918.fatigue_before_0) > 0.99000000953674316f;
    }
    else
    {
        _S930 = false;
    }
    if(_S930)
    {
        float _S933 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S912.ids_0.x], _S918.state_1.life_0);
        _S930 = _S933 <= 0.99000000953674316f;
    }
    else
    {
        _S930 = false;
    }
    if(_S930)
    {
        *&((&(&bd_0)->events_0)->y) = abs_step_0;
        if(wide_0)
        {
            cov_or_0(_S922.ids_0.w, 64U);
        }
        else
        {
            (*&g_seen_0)[4U] = 1U;
        }
    }
    if(_S918.disconnected_0)
    {
        *&((&(&bd_0)->events_0)->z) = abs_step_0;
    }
    (&bd_0)->js_0 = _S918.state_1;
    *(&(globalParams_0->bond_dyn_0)[i_14]) = bd_0;
    return _S918.disconnected_0;
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
    float4  _S934 = isl_5->position_0;
    (&rg_0)->pos_0 = float3 {_S934.x, _S934.y, _S934.z};
    float4  _S935 = isl_5->position_err_0;
    (&rg_0)->pos_err_0 = float3 {_S935.x, _S935.y, _S935.z};
    float4  _S936 = isl_5->velocity_0;
    (&rg_0)->vel_0 = float3 {_S936.x, _S936.y, _S936.z};
    float4  _S937 = isl_5->velocity_err_0;
    (&rg_0)->vel_err_0 = float3 {_S937.x, _S937.y, _S937.z};
    float4  _S938 = isl_5->angular_velocity_0;
    (&rg_0)->w_5 = float3 {_S938.x, _S938.y, _S938.z};
    float4  _S939 = isl_5->momentum_0;
    (&rg_0)->l_1 = float3 {_S939.x, _S939.y, _S939.z};
    float4  _S940 = isl_5->momentum_err_0;
    (&rg_0)->l_err_0 = float3 {_S940.x, _S940.y, _S940.z};
    float3  _S941 = make_float3 (0.0f);
    (&rg_0)->torque_0 = _S941;
    (&rg_0)->a_13 = _S941;
    (&rg_0)->alpha_0 = _S941;
    return rg_0;
}

static __device__ void net_load_0(uint c_9, Island_0 * isl_6, Rigid_0 * rg_1, uint k_13, float dt_7, bool contact_2, float3  * f_8, float3  * t_5)
{
    ChunkStatic_0 * _S942 = (&(globalParams_0->chunks_0)[c_9]);
    float3  fl_0;
    float3  tl_0;
    float3  rep_f_0;
    float3  rep_m_0;
    chunk_loads_0(c_9, c_9, &rg_1->rot_1, k_13, dt_7, contact_2, 0.0f, &fl_0, &tl_0, &rep_f_0, &rep_m_0);
    float3  _S943 = fl_0;
    float4  _S944 = __ldg(&globalParams_0->params_0->gravity_0);
    float3  _S945 = float3 {_S944.x, _S944.y, _S944.z};
    float4  _S946 = __ldg(&_S942->center_0);
    float3  fc_2 = _S943 + _S945 * make_float3 (_S946.w);
    float3  _S947 = float3 {_S946.x, _S946.y, _S946.z};
    float4  _S948 = *(&(globalParams_0->state_0)[4U * c_9]);
    float4  _S949 = isl_6->com_0;
    float3  _S950 = float3 {_S949.x, _S949.y, _S949.z};
    float3  _S951 = rotate_0(&rg_1->rot_1, _S947 + float3 {_S948.x, _S948.y, _S948.z} - _S950);
    *f_8 = *f_8 + fc_2;
    *t_5 = *t_5 + (cross_0(_S951, fc_2) + tl_0);
    uint4  _S952 = __ldg(&_S942->load_range_0);
    if((_S952.y) > (_S952.x))
    {
        float3  _S953 = rotate_0(&rg_1->rot_1, rep_f_0);
        *f_8 = *f_8 + _S953;
        float3  _S954 = rotate_0(&rg_1->rot_1, _S947 - _S950);
        float3  _S955 = cross_0(_S954, _S953);
        float3  _S956 = rotate_0(&rg_1->rot_1, rep_m_0);
        *t_5 = *t_5 + (_S955 + _S956);
    }
    return;
}

static __device__ void wide_store_0(uint slot_0, uint p_12, float3  a_14, float3  b_29)
{
    uint _S957 = __ldg(&globalParams_0->params_0->wide_base_0);
    uint _S958 = 8U * slot_0;
    *(&(globalParams_0->scratch_0)[_S957 + _S958 + p_12]) = make_float4 (a_14.x, a_14.y, a_14.z, 0.0f);
    uint _S959 = __ldg(&globalParams_0->params_0->wide_base_0);
    *(&(globalParams_0->scratch_0)[_S959 + _S958 + p_12 + 1U]) = make_float4 (b_29.x, b_29.y, b_29.z, 0.0f);
    return;
}

extern "C" __global__ void wide_bonds()
{
    uint _S960 = __ballot_sync(4294967295U, true);
    uint tid_6 = threadIdx.x;
    uint _S961 = blockIdx.x;
    uint _S962 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
    bool bond_group_0 = _S961 < _S962;
    uint _S963 = __ballot_sync(_S960, bond_group_0);
    WideGroup_0 wg_1;
    uint _S964;
    if(bond_group_0)
    {
        uint _S965 = __ldg(&globalParams_0->params_0->wide_bond_table_0);
        WideGroup_0 _S966 = wide_group_0(_S965, _S961);
        uint _S967 = __ballot_sync(_S960, true);
        wg_1 = _S966;
        _S964 = _S967;
    }
    else
    {
        uint _S968 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
        uint _S969 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
        WideGroup_0 _S970 = wide_group_0(_S968, _S961 - _S969);
        uint _S971 = __ballot_sync(_S960, true);
        wg_1 = _S970;
        _S964 = _S971;
    }
    uint _S972 = 0U;
    WideGroup_0 _S973 = wg_1;
    Island_0 isl_7 = *(&(globalParams_0->islands_0)[wg_1.island_2]);
    bool _S974 = wide_enter_1(tid_6, wg_1.island_2);
    bool _S975 = !_S974;
    uint _S976 = __ballot_sync(_S964, _S975);
    if(_S975)
    {
        return;
    }
    else
    {
        uint _S977 = __ballot_sync(_S964, true);
        _S972 = _S977;
    }
    uint _S978 = 0U;
    Island_0 _S979 = isl_7;
    uint _S980 = wide_step_0(&_S979);
    uint _S981 = __ballot_sync(_S972, bond_group_0);
    if(bond_group_0)
    {
        if(((isl_7.info_1.x) & 16U) != 0U)
        {
            return;
        }
        uint i_15 = wg_1.begin_0 + tid_6;
        bool _S982;
        if(i_15 < (wg_1.end_0))
        {
            float _S983 = __ldg(&globalParams_0->params_0->dt_0);
            uint _S984 = __ldg(&globalParams_0->params_0->fracture_0);
            bool _S985 = bond_update_0(i_15, _S983, _S984 != 0U, isl_7.info_1.w + 1U, true);
            _S982 = _S985;
        }
        else
        {
            _S982 = false;
        }
        if(_S982)
        {
            *&((&(&(globalParams_0->islands_0)[_S973.island_2])->info_1)->z) = (isl_7.info_1.z) | 2U;
        }
        return;
    }
    else
    {
        uint _S986 = __ballot_sync(_S972, true);
        _S978 = _S986;
    }
    uint _S987 = 0U;
    uint _S988 = isl_7.info_1.x;
    bool _S989 = (_S988 & 1U) != 0U;
    uint _S990 = __ballot_sync(_S978, _S989);
    if(_S989)
    {
        return;
    }
    else
    {
        uint _S991 = __ballot_sync(_S978, true);
        _S987 = _S991;
    }
    float3  _S992 = make_float3 (0.0f);
    float3  f_9 = _S992;
    float3  t_6 = _S992;
    uint c_10 = wg_1.begin_0 + tid_6;
    bool _S993 = c_10 < (wg_1.end_0);
    uint _S994 = __ballot_sync(_S987, _S993);
    if(_S993)
    {
        Island_0 _S995 = isl_7;
        Rigid_0 _S996 = rigid_of_0(&_S995);
        float _S997 = __ldg(&globalParams_0->params_0->dt_0);
        bool _S998 = (_S988 & 4U) != 0U;
        Island_0 _S999 = isl_7;
        Rigid_0 _S1000 = _S996;
        net_load_0(c_10, &_S999, &_S1000, _S980, _S997, _S998, &f_9, &t_6);
        uint _S1001 = __ballot_sync(_S987, true);
        _S964 = _S1001;
    }
    else
    {
        uint _S1002 = __ballot_sync(_S987, true);
        _S964 = _S1002;
    }
    group_sum3_0(tid_6, &f_9, &t_6, _S964);
    bool _S1003 = tid_6 == 0U;
    uint _S1004 = __ballot_sync(_S964, _S1003);
    if(_S1003)
    {
        uint _S1005 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
        wide_store_0(_S961 - _S1005, 0U, f_9, t_6);
    }
    return;
}

static __device__ void wide_partials_0(uint tid_7, uint first_1, uint count_5, uint p_13, float3  * a_15, float3  * b_30, uint _S1006)
{
    uint _S1007;
    float4  _S1008 = make_float4 (0.0f);
    float4  x_21 = _S1008;
    float4  y_5 = _S1008;
    uint s_3 = tid_7;
    uint _S1009 = _S1006;
    for(;;)
    {
        bool _S1010 = s_3 < count_5;
        uint _S1011 = __ballot_sync(_S1009, _S1010);
        if(_S1010)
        {
            uint _S1012 = __ballot_sync(_S1009, true);
        }
        else
        {
            uint _S1013 = __ballot_sync(_S1009, false);
            uint _S1014 = __ballot_sync(_S1009, false);
            uint _S1015 = __ballot_sync(_S1006, true);
            _S1007 = _S1015;
            break;
        }
        uint _S1016 = __ldg(&globalParams_0->params_0->wide_base_0);
        uint _S1017 = 8U * (first_1 + s_3);
        x_21 = x_21 + *(&(globalParams_0->scratch_0)[_S1016 + _S1017 + p_13]);
        uint _S1018 = __ldg(&globalParams_0->params_0->wide_base_0);
        y_5 = y_5 + *(&(globalParams_0->scratch_0)[_S1018 + _S1017 + p_13 + 1U]);
        uint _S1019 = __ballot_sync(_S1009, true);
        s_3 = s_3 + 256U;
        _S1009 = _S1019;
    }
    group_sum2_0(tid_7, &x_21, &y_5, _S1007);
    float4  _S1020 = x_21;
    *a_15 = float3 {_S1020.x, _S1020.y, _S1020.z};
    float4  _S1021 = y_5;
    *b_30 = float3 {_S1021.x, _S1021.y, _S1021.z};
    return;
}

static __device__ float3  rows_mul_0(float4  r0_0, float4  r1_0, float4  r2_0, float3  v_4)
{
    return make_float3 (dot_0(float3 {r0_0.x, r0_0.y, r0_0.z}, v_4), dot_0(float3 {r1_0.x, r1_0.y, r1_0.z}, v_4), dot_0(float3 {r2_0.x, r2_0.y, r2_0.z}, v_4));
}

static __device__ void drift_angular_0(uint c_11, float3  wcom_1, float3  tr_0, float3  dv_0, float3  * lu_0, float3  * lv_0)
{
    ChunkStatic_0 * _S1022 = (&(globalParams_0->chunks_0)[c_11]);
    float4  _S1023 = __ldg(&_S1022->center_0);
    float3  r_9 = float3 {_S1023.x, _S1023.y, _S1023.z} - wcom_1;
    float4  _S1024 = __ldg(&_S1022->scale_0);
    float kw_0 = _S1024.x;
    uint _S1025 = 4U * c_11;
    float4  _S1026 = *(&(globalParams_0->state_0)[_S1025]);
    float _S1027 = _S1023.w;
    float3  _S1028 = cross_0(r_9, float3 {_S1026.x, _S1026.y, _S1026.z} - tr_0) * make_float3 (_S1027);
    float4  _S1029 = __ldg(&_S1022->inertia0_0);
    float4  _S1030 = __ldg(&_S1022->inertia1_0);
    float4  _S1031 = __ldg(&_S1022->inertia2_0);
    float4  _S1032 = *(&(globalParams_0->state_0)[_S1025 + 1U]);
    *lu_0 = *lu_0 + (_S1028 + rows_mul_0(_S1029, _S1030, _S1031, float3 {_S1032.x, _S1032.y, _S1032.z})) * make_float3 (kw_0);
    float4  _S1033 = *(&(globalParams_0->state_0)[_S1025 + 2U]);
    float4  _S1034 = *(&(globalParams_0->state_0)[_S1025 + 3U]);
    *lv_0 = *lv_0 + (cross_0(r_9, float3 {_S1033.x, _S1033.y, _S1033.z} - dv_0) * make_float3 (_S1027) + rows_mul_0(_S1029, _S1030, _S1031, float3 {_S1034.x, _S1034.y, _S1034.z})) * make_float3 (kw_0);
    return;
}

extern "C" __global__ void wide_drift()
{
    uint _S1035 = __ballot_sync(4294967295U, true);
    uint tid_8 = threadIdx.x;
    uint _S1036 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1037 = blockIdx.x;
    WideGroup_0 wg_2 = wide_group_0(_S1036, _S1037);
    Island_0 * _S1038 = (&(globalParams_0->islands_0)[wg_2.island_2]);
    Island_0 isl_8 = *_S1038;
    bool _S1039 = (((*_S1038).info_1.x) & 17U) != 0U;
    uint _S1040 = __ballot_sync(_S1035, _S1039);
    bool _S1041;
    uint _S1042;
    if(_S1039)
    {
        uint _S1043 = __ballot_sync(_S1035, true);
        _S1041 = true;
        _S1042 = _S1043;
    }
    else
    {
        bool _S1044 = wide_enter_1(tid_8, wg_2.island_2);
        bool _S1045 = !_S1044;
        uint _S1046 = __ballot_sync(_S1035, true);
        _S1041 = _S1045;
        _S1042 = _S1046;
    }
    uint _S1047 = 0U;
    uint _S1048 = __ballot_sync(_S1042, _S1041);
    if(_S1041)
    {
        return;
    }
    else
    {
        uint _S1049 = __ballot_sync(_S1042, true);
        _S1047 = _S1049;
    }
    float3  tu_0;
    float3  pv_0;
    wide_partials_0(tid_8, wg_2.first_0, isl_8.wide_groups_0, 2U, &tu_0, &pv_0, _S1047);
    float _S1050 = isl_8.wcom_0.w;
    float3  tr_1 = tu_0 / make_float3 (_S1050);
    float3  dv_1 = pv_0 / make_float3 (_S1050);
    float3  _S1051 = make_float3 (0.0f);
    float3  lu_1 = _S1051;
    float3  lv_1 = _S1051;
    uint c_12 = wg_2.begin_0 + tid_8;
    bool _S1052 = c_12 < (wg_2.end_0);
    uint _S1053 = __ballot_sync(_S1047, _S1052);
    if(_S1052)
    {
        float4  _S1054 = isl_8.wcom_0;
        drift_angular_0(c_12, float3 {_S1054.x, _S1054.y, _S1054.z}, tr_1, dv_1, &lu_1, &lv_1);
        uint _S1055 = __ballot_sync(_S1047, true);
        _S1042 = _S1055;
    }
    else
    {
        uint _S1056 = __ballot_sync(_S1047, true);
        _S1042 = _S1056;
    }
    group_sum3_0(tid_8, &lu_1, &lv_1, _S1042);
    bool _S1057 = tid_8 == 0U;
    uint _S1058 = __ballot_sync(_S1042, _S1057);
    if(_S1057)
    {
        wide_store_0(_S1037, 4U, lu_1, lv_1);
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
    Quat_0 _S1059 = c_13;
    float3  _S1060 = rotate_0(&_S1059, v_5);
    return _S1060;
}

static __device__ float3  world_mul_0(Quat_0 * q_10, float4  r0_1, float4  r1_1, float4  r2_1, float3  v_6)
{
    float3  _S1061 = inverse_rotate_0(q_10, v_6);
    float3  _S1062 = rotate_0(q_10, rows_mul_0(r0_1, r1_1, r2_1, _S1061));
    return _S1062;
}

static __device__ void rigid_acceleration_0(Island_0 * isl_9, Rigid_0 * rg_2, float3  f_10, float3  t_7)
{
    Quat_0 _S1063 = rg_2->rot_1;
    float3  _S1064 = world_mul_0(&_S1063, isl_9->inertia0_1, isl_9->inertia1_1, isl_9->inertia2_1, rg_2->w_5);
    rg_2->a_13 = f_10 / make_float3 (isl_9->com_0.w);
    float3  _S1065 = t_7 - cross_0(rg_2->w_5, _S1064);
    Quat_0 _S1066 = rg_2->rot_1;
    float3  _S1067 = world_mul_0(&_S1066, isl_9->inv0_1, isl_9->inv1_1, isl_9->inv2_1, _S1065);
    rg_2->alpha_0 = _S1067;
    rg_2->torque_0 = t_7;
    return;
}

static __device__ Rigid_0 wide_rigid_frame_0(uint tid_9, Island_0 * isl_10, WideGroup_0 * wg_3, uint _S1068)
{
    Rigid_0 _S1069 = rigid_of_0(isl_10);
    Rigid_0 rg_3 = _S1069;
    bool _S1070 = ((isl_10->info_1.x) & 1U) == 0U;
    uint _S1071 = __ballot_sync(_S1068, _S1070);
    if(_S1070)
    {
        float3  f_11;
        float3  t_8;
        wide_partials_0(tid_9, wg_3->first_0, isl_10->wide_groups_0, 0U, &f_11, &t_8, _S1071);
        rigid_acceleration_0(isl_10, &rg_3, f_11, t_8);
        uint _S1072 = __ballot_sync(_S1068, true);
    }
    return rg_3;
}

static __device__ void comp_add_0(float3  * sum_1, float3  * err_1, float3  x_22)
{
    float3  t_9 = *sum_1 + x_22;
    float3  _S1073 = abs_1(x_22);
    *err_1 = *err_1 + (_slang_select((abs_1(*sum_1)) >= _S1073, *sum_1,x_22) - t_9 + _slang_select((abs_1(*sum_1)) >= _S1073, x_22,*sum_1));
    *sum_1 = t_9;
    return;
}

static __device__ float3  turn_difference_0(float3  omega_0, float dt_8, float3  v_7)
{
    float _S1074 = length_0(omega_0);
    float angle_1 = _S1074 * dt_8;
    if(angle_1 < 1.00000000317107685e-30f)
    {
        return make_float3 (0.0f);
    }
    float3  a_16 = omega_0 / make_float3 (_S1074);
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
    float4  _S1075 = abs_0(x_23);
    *err_2 = *err_2 + (_slang_select((abs_0(*sum_2)) >= _S1075, *sum_2,x_23) - t_10 + _slang_select((abs_0(*sum_2)) >= _S1075, x_23,*sum_2));
    *sum_2 = t_10;
    return;
}

static __device__ void quat_accumulate_0(Quat_0 * hi_1, float4  * lo_1, float4  x_24)
{
    Quat_0 _S1076 = *hi_1;
    float4  _S1077 = quat_vec_0(&_S1076);
    float4  sum_3 = _S1077;
    comp_add4_0(&sum_3, lo_1, x_24);
    float4  t_11 = sum_3 + *lo_1;
    *lo_1 = *lo_1 - (t_11 - sum_3);
    *hi_1 = quat_of_0(t_11);
    return;
}

static __device__ void turn_left_0(Quat_0 * hi_2, float4  * lo_2, float3  omega_1, float dt_9)
{
    float _S1078 = length_0(omega_1);
    float angle_3 = _S1078 * dt_9;
    if(angle_3 < 1.00000000317107685e-30f)
    {
        return;
    }
    float4  d_10 = turn_minus_one_0(omega_1 / make_float3 (_S1078), angle_3);
    Quat_0 dq_0;
    (&dq_0)->x_12 = d_10.x;
    (&dq_0)->y_4 = d_10.y;
    (&dq_0)->z_0 = d_10.z;
    (&dq_0)->w_1 = d_10.w;
    Quat_0 _S1079 = dq_0;
    Quat_0 _S1080 = *hi_2;
    Quat_0 _S1081 = quat_mul_0(&_S1079, &_S1080);
    Quat_0 _S1082 = _S1081;
    float4  _S1083 = quat_vec_0(&_S1082);
    quat_accumulate_0(hi_2, lo_2, _S1083);
    return;
}

static __device__ void integrate_rigid_0(Island_0 * isl_11, Rigid_0 * rg_4, float dt_10)
{
    comp_add_0(&rg_4->l_1, &rg_4->l_err_0, rg_4->torque_0 * make_float3 (dt_10));
    float3  l_2 = rg_4->l_1 + rg_4->l_err_0;
    comp_add_0(&rg_4->vel_0, &rg_4->vel_err_0, rg_4->a_13 * make_float3 (dt_10));
    float3  vel_1 = rg_4->vel_0 + rg_4->vel_err_0;
    float4  _S1084 = isl_11->inv0_1;
    float4  _S1085 = isl_11->inv1_1;
    float4  _S1086 = isl_11->inv2_1;
    Quat_0 _S1087 = rg_4->rot_1;
    float3  _S1088 = world_mul_0(&_S1087, isl_11->inv0_1, isl_11->inv1_1, isl_11->inv2_1, l_2);
    float3  _S1089 = vel_1 * make_float3 (dt_10);
    float4  _S1090 = isl_11->com_0;
    float3  _S1091 = float3 {_S1090.x, _S1090.y, _S1090.z};
    Quat_0 _S1092 = rg_4->rot_1;
    float3  _S1093 = rotate_0(&_S1092, _S1091);
    comp_add_0(&rg_4->pos_0, &rg_4->pos_err_0, _S1089 - turn_difference_0(_S1088, dt_10, _S1093));
    turn_left_0(&rg_4->rot_1, &rg_4->rot_err_0, _S1088, dt_10);
    Quat_0 _S1094 = rg_4->rot_1;
    float3  _S1095 = world_mul_0(&_S1094, _S1084, _S1085, _S1086, l_2);
    rg_4->w_5 = _S1095;
    return;
}

static __device__ void drift_apply_0(uint c_14, float3  wcom_2, float3  tr_2, float3  phi_0, float3  dv_2, float3  dw_0)
{
    float4  _S1096 = __ldg(&(&(globalParams_0->chunks_0)[c_14])->center_0);
    float3  r_10 = float3 {_S1096.x, _S1096.y, _S1096.z} - wcom_2;
    uint _S1097 = 4U * c_14;
    float4  _S1098 = *(&(globalParams_0->state_0)[_S1097]);
    *(&(globalParams_0->state_0)[_S1097]) = make_float4 ((float3 {_S1098.x, _S1098.y, _S1098.z} - (tr_2 + cross_0(phi_0, r_10))).x, (float3 {_S1098.x, _S1098.y, _S1098.z} - (tr_2 + cross_0(phi_0, r_10))).y, (float3 {_S1098.x, _S1098.y, _S1098.z} - (tr_2 + cross_0(phi_0, r_10))).z, (*(&(globalParams_0->state_0)[_S1097])).w);
    uint _S1099 = _S1097 + 1U;
    float4  _S1100 = *(&(globalParams_0->state_0)[_S1099]);
    *(&(globalParams_0->state_0)[_S1099]) = make_float4 ((float3 {_S1100.x, _S1100.y, _S1100.z} - phi_0).x, (float3 {_S1100.x, _S1100.y, _S1100.z} - phi_0).y, (float3 {_S1100.x, _S1100.y, _S1100.z} - phi_0).z, (*(&(globalParams_0->state_0)[_S1099])).w);
    uint _S1101 = _S1097 + 2U;
    float4  _S1102 = *(&(globalParams_0->state_0)[_S1101]);
    *(&(globalParams_0->state_0)[_S1101]) = make_float4 ((float3 {_S1102.x, _S1102.y, _S1102.z} - (dv_2 + cross_0(dw_0, r_10))).x, (float3 {_S1102.x, _S1102.y, _S1102.z} - (dv_2 + cross_0(dw_0, r_10))).y, (float3 {_S1102.x, _S1102.y, _S1102.z} - (dv_2 + cross_0(dw_0, r_10))).z, (*(&(globalParams_0->state_0)[_S1101])).w);
    uint _S1103 = _S1097 + 3U;
    float4  _S1104 = *(&(globalParams_0->state_0)[_S1103]);
    *(&(globalParams_0->state_0)[_S1103]) = make_float4 ((float3 {_S1104.x, _S1104.y, _S1104.z} - dw_0).x, (float3 {_S1104.x, _S1104.y, _S1104.z} - dw_0).y, (float3 {_S1104.x, _S1104.y, _S1104.z} - dw_0).z, (*(&(globalParams_0->state_0)[_S1103])).w);
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
    Quat_0 _S1105 = *hi_3;
    Quat_0 _S1106 = dq_1;
    Quat_0 _S1107 = quat_mul_0(&_S1105, &_S1106);
    Quat_0 _S1108 = _S1107;
    float4  _S1109 = quat_vec_0(&_S1108);
    quat_accumulate_0(hi_3, lo_3, _S1109);
    return;
}

static __device__ void drift_rigid_0(Island_0 * isl_12, Rigid_0 * rg_5, float3  tr_3, float3  phi_2, float3  dv_3, float3  dw_1)
{
    float4  _S1110 = isl_12->wcom_0;
    float3  wcom_3 = float3 {_S1110.x, _S1110.y, _S1110.z};
    Quat_0 rot_2 = rg_5->rot_1;
    float3  _S1111 = tr_3 - cross_0(phi_2, wcom_3);
    Quat_0 _S1112 = rg_5->rot_1;
    float3  _S1113 = rotate_0(&_S1112, _S1111);
    comp_add_0(&rg_5->pos_0, &rg_5->pos_err_0, _S1113);
    Quat_0 _S1114 = rg_5->rot_1;
    float3  _S1115 = inverse_rotate_0(&_S1114, rg_5->w_5);
    float4  _S1116 = isl_12->inertia0_1;
    float4  _S1117 = isl_12->inertia1_1;
    float4  _S1118 = isl_12->inertia2_1;
    float3  _S1119 = cross_0(phi_2, rows_mul_0(isl_12->inertia0_1, isl_12->inertia1_1, isl_12->inertia2_1, _S1115)) - rows_mul_0(isl_12->inertia0_1, isl_12->inertia1_1, isl_12->inertia2_1, cross_0(phi_2, _S1115));
    Quat_0 _S1120 = rg_5->rot_1;
    float3  _S1121 = rotate_0(&_S1120, _S1119);
    turn_right_0(&rg_5->rot_1, &rg_5->rot_err_0, phi_2);
    float4  _S1122 = isl_12->com_0;
    float3  _S1123 = dv_3 + cross_0(dw_1, float3 {_S1122.x, _S1122.y, _S1122.z} - wcom_3);
    Quat_0 _S1124 = rot_2;
    float3  _S1125 = rotate_0(&_S1124, _S1123);
    comp_add_0(&rg_5->vel_0, &rg_5->vel_err_0, _S1125);
    Quat_0 _S1126 = rot_2;
    float3  _S1127 = rotate_0(&_S1126, dw_1);
    rg_5->w_5 = rg_5->w_5 + _S1127;
    Quat_0 _S1128 = rg_5->rot_1;
    float3  _S1129 = world_mul_0(&_S1128, _S1116, _S1117, _S1118, _S1127);
    comp_add_0(&rg_5->l_1, &rg_5->l_err_0, _S1121 + _S1129);
    return;
}

extern "C" __global__ void wide_rigid()
{
    uint _S1130 = __ballot_sync(4294967295U, true);
    uint tid_10 = threadIdx.x;
    uint _S1131 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1132 = blockIdx.x;
    WideGroup_0 wg_4 = wide_group_0(_S1131, _S1132);
    Island_0 * _S1133 = (&(globalParams_0->islands_0)[wg_4.island_2]);
    Island_0 isl_13 = *_S1133;
    uint _S1134 = (*_S1133).info_1.x;
    bool _S1135 = (_S1134 & 1U) != 0U;
    uint _S1136 = __ballot_sync(_S1130, _S1135);
    bool _S1137;
    uint _S1138;
    if(_S1135)
    {
        uint _S1139 = __ballot_sync(_S1130, true);
        _S1137 = true;
        _S1138 = _S1139;
    }
    else
    {
        bool _S1140 = wide_enter_1(tid_10, wg_4.island_2);
        bool _S1141 = !_S1140;
        uint _S1142 = __ballot_sync(_S1130, true);
        _S1137 = _S1141;
        _S1138 = _S1142;
    }
    uint _S1143 = 0U;
    uint _S1144 = __ballot_sync(_S1138, _S1137);
    if(_S1137)
    {
        return;
    }
    else
    {
        uint _S1145 = __ballot_sync(_S1138, true);
        _S1143 = _S1145;
    }
    uint _S1146 = 0U;
    bool _S1147 = (_S1134 & 16U) != 0U;
    uint _S1148 = __ballot_sync(_S1143, _S1147);
    if(_S1147)
    {
        uint _S1149 = 0U;
        bool _S1150 = _S1132 != (wg_4.first_0);
        uint _S1151 = __ballot_sync(_S1148, _S1150);
        if(_S1150)
        {
            return;
        }
        else
        {
            uint _S1152 = __ballot_sync(_S1148, true);
            _S1149 = _S1152;
        }
        Island_0 _S1153 = isl_13;
        WideGroup_0 _S1154 = wg_4;
        Rigid_0 _S1155 = wide_rigid_frame_0(tid_10, &_S1153, &_S1154, _S1149);
        Rigid_0 rs_0 = _S1155;
        bool _S1156 = tid_10 != 0U;
        uint _S1157 = __ballot_sync(_S1149, _S1156);
        if(_S1156)
        {
            _S1137 = true;
        }
        else
        {
            _S1137 = (_S1134 & 2U) != 0U;
        }
        if(_S1137)
        {
            return;
        }
        float _S1158 = __ldg(&globalParams_0->params_0->dt_0);
        Island_0 _S1159 = isl_13;
        integrate_rigid_0(&_S1159, &rs_0, _S1158);
        Quat_0 _S1160 = (&rs_0)->rot_1;
        float4  _S1161 = quat_vec_0(&_S1160);
        (&(globalParams_0->islands_0)[wg_4.island_2])->rotation_0 = _S1161;
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
        uint _S1162 = __ballot_sync(_S1143, true);
        _S1146 = _S1162;
    }
    float3  tu_1;
    float3  pv_1;
    wide_partials_0(tid_10, wg_4.first_0, isl_13.wide_groups_0, 2U, &tu_1, &pv_1, _S1146);
    float3  lu_2;
    float3  lv_2;
    wide_partials_0(tid_10, wg_4.first_0, isl_13.wide_groups_0, 4U, &lu_2, &lv_2, _S1146);
    float _S1163 = isl_13.wcom_0.w;
    float3  tr_4 = tu_1 / make_float3 (_S1163);
    float3  dv_4 = pv_1 / make_float3 (_S1163);
    float3  phi_3 = rows_mul_0(isl_13.winv0_0, isl_13.winv1_0, isl_13.winv2_0, lu_2);
    float3  dw_2 = rows_mul_0(isl_13.winv0_0, isl_13.winv1_0, isl_13.winv2_0, lv_2);
    uint c_15 = wg_4.begin_0 + tid_10;
    bool _S1164 = c_15 < (wg_4.end_0);
    uint _S1165 = __ballot_sync(_S1146, _S1164);
    if(_S1164)
    {
        float4  _S1166 = isl_13.wcom_0;
        drift_apply_0(c_15, float3 {_S1166.x, _S1166.y, _S1166.z}, tr_4, phi_3, dv_4, dw_2);
        uint _S1167 = __ballot_sync(_S1146, true);
        _S1138 = _S1167;
    }
    else
    {
        uint _S1168 = __ballot_sync(_S1146, true);
        _S1138 = _S1168;
    }
    uint _S1169 = 0U;
    bool _S1170 = _S1132 != (wg_4.first_0);
    uint _S1171 = __ballot_sync(_S1138, _S1170);
    if(_S1170)
    {
        return;
    }
    else
    {
        uint _S1172 = __ballot_sync(_S1138, true);
        _S1169 = _S1172;
    }
    Island_0 _S1173 = isl_13;
    WideGroup_0 _S1174 = wg_4;
    Rigid_0 _S1175 = wide_rigid_frame_0(tid_10, &_S1173, &_S1174, _S1169);
    Rigid_0 rg_6 = _S1175;
    bool _S1176 = tid_10 != 0U;
    uint _S1177 = __ballot_sync(_S1169, _S1176);
    if(_S1176)
    {
        return;
    }
    if(!((_S1134 & 2U) != 0U))
    {
        float _S1178 = __ldg(&globalParams_0->params_0->dt_0);
        Island_0 _S1179 = isl_13;
        integrate_rigid_0(&_S1179, &rg_6, _S1178);
        Island_0 _S1180 = isl_13;
        drift_rigid_0(&_S1180, &rg_6, tr_4, phi_3, dv_4, dw_2);
    }
    Quat_0 _S1181 = (&rg_6)->rot_1;
    float4  _S1182 = quat_vec_0(&_S1181);
    (&(globalParams_0->islands_0)[wg_4.island_2])->rotation_0 = _S1182;
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

__device__ __shared__ FixedArray<uint, 4096>  g_label_0;

__device__ __shared__ uint g_changed_0;

static __device__ bool island_connected_0(uint tid_11, Island_0 * isl_14)
{
    uint _S1183 = isl_14->range_0.x;
    uint n_8 = isl_14->range_0.y - _S1183;
    if(n_8 > 4096U)
    {
        return false;
    }
    uint c_16 = tid_11;
    for(;;)
    {
        if(c_16 < n_8)
        {
        }
        else
        {
            break;
        }
        (*&g_label_0)[c_16] = c_16;
        c_16 = c_16 + 256U;
    }
    __syncthreads();
    bool converged_0 = false;
    uint pass_0 = 0U;
    for(;;)
    {
        if(pass_0 <= n_8)
        {
        }
        else
        {
            break;
        }
        if(tid_11 == 0U)
        {
            *&g_changed_0 = 0U;
        }
        __syncthreads();
        c_16 = tid_11;
        for(;;)
        {
            if(c_16 < n_8)
            {
            }
            else
            {
                break;
            }
            uint _S1184 = (*&g_label_0)[c_16];
            uint gc_0 = _S1183 + c_16;
            uint _S1185 = __ldg((&(globalParams_0->index_0)[gc_0]));
            uint l_3 = _S1184;
            uint e_2 = _S1185;
            for(;;)
            {
                uint _S1186 = __ldg((&(globalParams_0->index_0)[gc_0 + 1U]));
                if(e_2 < _S1186)
                {
                }
                else
                {
                    break;
                }
                uint _S1187 = __ldg((&(globalParams_0->index_0)[e_2]));
                uint bond_0 = _S1187 >> int(1);
                JointBond_0 _S1188 = slang_ldg_0(&(&(globalParams_0->bonds_0)[bond_0])->law_0);
                bool _S1189 = (_S1188.stiff1_0.w) != 0.0f;
                JointState_0 _S1190 = (&(globalParams_0->bond_dyn_0)[bond_0])->js_0;
                bool _S1191 = connected_0(&_S1190, _S1189);
                if(!_S1191)
                {
                    e_2 = e_2 + 1U;
                    continue;
                }
                uint other_0;
                if((_S1187 & 1U) == 0U)
                {
                    JointBond_0 _S1192 = slang_ldg_0(&(&(globalParams_0->bonds_0)[bond_0])->law_0);
                    other_0 = _S1192.ids_0.z;
                }
                else
                {
                    JointBond_0 _S1193 = slang_ldg_0(&(&(globalParams_0->bonds_0)[bond_0])->law_0);
                    other_0 = _S1193.ids_0.y;
                }
                l_3 = (U32_min((l_3), ((*&g_label_0)[other_0 - _S1183])));
                e_2 = e_2 + 1U;
            }
            uint _S1194 = (U32_min((l_3), ((*&g_label_0)[l_3])));
            if(_S1194 < (*&g_label_0)[c_16])
            {
                (*&g_label_0)[c_16] = _S1194;
                *&g_changed_0 = 1U;
            }
            c_16 = c_16 + 256U;
        }
        __syncthreads();
        bool converged_1 = (*&g_changed_0) == 0U;
        __syncthreads();
        if(converged_1)
        {
            converged_0 = converged_1;
            break;
        }
        uint _S1195 = pass_0 + 1U;
        converged_0 = converged_1;
        pass_0 = _S1195;
    }
    if(!converged_0)
    {
        return false;
    }
    if(tid_11 == 0U)
    {
        *&g_changed_0 = 0U;
    }
    __syncthreads();
    c_16 = tid_11;
    for(;;)
    {
        if(c_16 < n_8)
        {
        }
        else
        {
            break;
        }
        if(((*&g_label_0)[c_16]) != 0U)
        {
            *&g_changed_0 = 1U;
        }
        c_16 = c_16 + 256U;
    }
    __syncthreads();
    return (*&g_changed_0) == 0U;
}

static __device__ void write_probe_0(uint slot_1, uint k_14, float value_1)
{
    uint _S1196 = __ldg(&globalParams_0->params_0->probe_base_0);
    uint _S1197 = _S1196 * 4U;
    uint _S1198 = __ldg(&globalParams_0->params_0->probe_stride_0);
    uint at_3 = _S1197 + slot_1 * _S1198 + k_14;
    float4  v_8 = *(&(globalParams_0->scratch_0)[at_3 / 4U]);
    *_slang_vector_get_element_ptr(&v_8, at_3 % 4U) = value_1;
    *(&(globalParams_0->scratch_0)[at_3 / 4U]) = v_8;
    return;
}

static __device__ void record_probes_0(Island_0 * isl_15, Rigid_0 * rg_7, uint k_15)
{
    uint4  _S1199 = isl_15->probes_0;
    uint at_4 = isl_15->probes_0.x;
    for(;;)
    {
        if(at_4 < (_S1199.y))
        {
        }
        else
        {
            break;
        }
        float4  _S1200 = __ldg((&(globalParams_0->loads_0)[at_4]));
        uint4  info_3 = asuint_0(_S1200);
        float4  _S1201 = __ldg((&(globalParams_0->loads_0)[at_4 + 1U]));
        float4  _S1202 = __ldg((&(globalParams_0->loads_0)[at_4 + 2U]));
        float4  _S1203 = __ldg((&(globalParams_0->loads_0)[at_4 + 3U]));
        uint kind_4 = info_3.x;
        uint i_16 = info_3.y;
        float value_2;
        if(kind_4 == 0U)
        {
            float4  _S1204 = *(&(globalParams_0->state_0)[4U * i_16]);
            float3  small_0 = float3 {_S1204.x, _S1204.y, _S1204.z} + make_float3 (_S1201.w, _S1202.w, _S1203.w);
            float3  _S1205 = rg_7->pos_0 - float3 {_S1202.x, _S1202.y, _S1202.z};
            float4  _S1206 = __ldg(&(&(globalParams_0->chunks_0)[i_16])->center_0);
            float3  _S1207 = rotate_0(&rg_7->rot_1, float3 {_S1206.x, _S1206.y, _S1206.z});
            float3  _S1208 = _S1205 + _S1207;
            float3  _S1209 = rg_7->pos_err_0 - float3 {_S1203.x, _S1203.y, _S1203.z};
            float3  _S1210 = rotate_0(&rg_7->rot_1, small_0);
            value_2 = dot_0(_S1208 + (_S1209 + _S1210), float3 {_S1201.x, _S1201.y, _S1201.z});
        }
        else
        {
            if(kind_4 == 1U)
            {
                float4  _S1211 = __ldg(&(&(globalParams_0->chunks_0)[i_16])->center_0);
                uint _S1212 = 4U * i_16;
                float4  _S1213 = *(&(globalParams_0->state_0)[_S1212]);
                float4  _S1214 = isl_15->com_0;
                float3  _S1215 = rotate_0(&rg_7->rot_1, float3 {_S1211.x, _S1211.y, _S1211.z} + float3 {_S1213.x, _S1213.y, _S1213.z} - float3 {_S1214.x, _S1214.y, _S1214.z});
                float3  _S1216 = rg_7->vel_0 + rg_7->vel_err_0 + cross_0(rg_7->w_5, _S1215);
                float4  _S1217 = *(&(globalParams_0->state_0)[_S1212 + 2U]);
                float3  _S1218 = rotate_0(&rg_7->rot_1, float3 {_S1217.x, _S1217.y, _S1217.z});
                value_2 = dot_0(_S1216 + _S1218, float3 {_S1201.x, _S1201.y, _S1201.z});
            }
            else
            {
                if(kind_4 == 2U)
                {
                    uint _S1219 = 3U * i_16;
                    float4  _S1220 = *(&(globalParams_0->scratch_0)[_S1219]);
                    float3  f_12 = float3 {_S1220.x, _S1220.y, _S1220.z};
                    bool _S1221 = (info_3.z) == 0U;
                    float3  mc_0;
                    if(_S1221)
                    {
                        float4  _S1222 = *(&(globalParams_0->scratch_0)[_S1219 + 1U]);
                        mc_0 = float3 {_S1222.x, _S1222.y, _S1222.z};
                    }
                    else
                    {
                        float4  _S1223 = *(&(globalParams_0->scratch_0)[_S1219 + 2U]);
                        mc_0 = float3 {_S1223.x, _S1223.y, _S1223.z};
                    }
                    float3  fc_3;
                    if(_S1221)
                    {
                        fc_3 = f_12;
                    }
                    else
                    {
                        fc_3 = - f_12;
                    }
                    value_2 = dot_0(fc_3, float3 {_S1201.x, _S1201.y, _S1201.z}) + dot_0(mc_0, float3 {_S1202.x, _S1202.y, _S1202.z});
                }
                else
                {
                    uint _S1224 = 4U * i_16;
                    float3  _S1225 = rotate_0(&rg_7->rot_1, make_float3 ((*(&(globalParams_0->state_0)[_S1224 + 1U])).w, (*(&(globalParams_0->state_0)[_S1224 + 2U])).w, (*(&(globalParams_0->state_0)[_S1224 + 3U])).w));
                    value_2 = dot_0(_S1225, float3 {_S1201.x, _S1201.y, _S1201.z});
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
    uint _S1226 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint previous_1 = (&(globalParams_0->islands_0)[_S1226])->info_1.y;
    uint _S1227 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint _S1228;
    if(previous_1 == 0U)
    {
        _S1228 = at_5;
    }
    else
    {
        _S1228 = (U32_min((previous_1), (at_5)));
    }
    *&((&(&(globalParams_0->islands_0)[_S1227])->info_1)->y) = _S1228;
    return;
}

extern "C" __global__ void wide_end()
{
    uint _S1229 = 0U;
    uint _S1230 = __ballot_sync(4294967295U, true);
    uint tid_12 = threadIdx.x;
    uint _S1231 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1232 = blockIdx.x;
    WideGroup_0 wg_5 = wide_group_0(_S1231, _S1232);
    bool _S1233 = _S1232 != (wg_5.first_0);
    uint _S1234 = __ballot_sync(_S1230, _S1233);
    if(_S1233)
    {
        return;
    }
    else
    {
        uint _S1235 = __ballot_sync(_S1230, true);
        _S1229 = _S1235;
    }
    uint _S1236 = 0U;
    Island_0 * _S1237 = (&(globalParams_0->islands_0)[wg_5.island_2]);
    Island_0 isl_16 = *_S1237;
    Island_0 _S1238 = *_S1237;
    bool _S1239 = wide_enter_0(tid_12, &_S1238);
    bool _S1240 = !_S1239;
    uint _S1241 = __ballot_sync(_S1229, _S1240);
    if(_S1240)
    {
        return;
    }
    else
    {
        uint _S1242 = __ballot_sync(_S1229, true);
        _S1236 = _S1242;
    }
    float3  work_1;
    float3  flags_2;
    wide_partials_0(tid_12, wg_5.first_0, (&isl_16)->wide_groups_0, 6U, &work_1, &flags_2, _S1236);
    bool halt_0 = (((&isl_16)->info_1.z) & 2U) != 0U;
    uint _S1243 = __ballot_sync(_S1236, halt_0);
    bool whole_0;
    if(halt_0)
    {
        Island_0 _S1244 = isl_16;
        bool _S1245 = island_connected_0(tid_12, &_S1244);
        whole_0 = _S1245;
    }
    else
    {
        whole_0 = false;
    }
    if(tid_12 != 0U)
    {
        return;
    }
    bool halt_1;
    if(whole_0)
    {
        *&((&(&isl_16)->info_1)->z) = (*&((&(&isl_16)->info_1)->z)) & 4294967293U;
        (&isl_16)->coverage_0 = ((&isl_16)->coverage_0) | 128U;
        halt_1 = false;
    }
    else
    {
        halt_1 = halt_0;
    }
    Island_0 _S1246 = isl_16;
    uint _S1247 = wide_step_0(&_S1246);
    if(((&isl_16)->probes_0.y) > ((&isl_16)->probes_0.x))
    {
        Island_0 _S1248 = isl_16;
        Rigid_0 _S1249 = rigid_of_0(&_S1248);
        Island_0 _S1250 = isl_16;
        Rigid_0 _S1251 = _S1249;
        record_probes_0(&_S1250, &_S1251, _S1247);
    }
    if(halt_1)
    {
        whole_0 = (((&isl_16)->info_1.x) & 4U) != 0U;
    }
    else
    {
        whole_0 = false;
    }
    if(whole_0)
    {
        contact_split_at_0((&isl_16)->info_1.w + 1U);
    }
    comp_add1_0(&((&(&isl_16)->energy_1)->x), &((&(&isl_16)->energy_1)->y), work_1.x);
    *&((&(&isl_16)->energy_1)->y) = *&((&(&isl_16)->energy_1)->y) + work_1.y;
    (&isl_16)->done_0 = (&isl_16)->done_0 + 1U;
    *&((&(&isl_16)->info_1)->y) = *&((&(&isl_16)->info_1)->y) - 1U;
    *&((&(&isl_16)->info_1)->w) = *&((&(&isl_16)->info_1)->w) + 1U;
    if(halt_1)
    {
        *&((&(&isl_16)->info_1)->z) = (((&isl_16)->info_1.z) & 4294967293U) | 1U;
    }
    uint _S1252;
    if(halt_1)
    {
        _S1252 = 128U;
    }
    else
    {
        _S1252 = 0U;
    }
    uint _S1253 = 256U | _S1252;
    if(((&isl_16)->probes_0.y) > ((&isl_16)->probes_0.x))
    {
        _S1252 = 262144U;
    }
    else
    {
        _S1252 = 0U;
    }
    uint _S1254 = _S1253 | _S1252;
    if((((&isl_16)->info_1.x) & 4U) != 0U)
    {
        _S1252 = 524288U;
    }
    else
    {
        _S1252 = 0U;
    }
    uint _S1255 = _S1254 | _S1252;
    if((flags_2.x) > 0.0f)
    {
        _S1252 = 32768U;
    }
    else
    {
        _S1252 = 0U;
    }
    uint _S1256 = _S1255 | _S1252;
    if((flags_2.y) > 0.0f)
    {
        _S1252 = 65536U;
    }
    else
    {
        _S1252 = 0U;
    }
    uint _S1257 = _S1256 | _S1252;
    if((flags_2.z) > 0.0f)
    {
        _S1252 = 131072U;
    }
    else
    {
        _S1252 = 0U;
    }
    (&isl_16)->coverage_0 = ((&isl_16)->coverage_0) | (_S1257 | _S1252);
    *(&(globalParams_0->islands_0)[wg_5.island_2]) = isl_16;
    return;
}

static __device__ uint sv_0(uint c_17, uint slot_2)
{
    uint _S1258 = __ldg(&globalParams_0->params_0->statics_base_0);
    return _S1258 + 23U * c_17 + slot_2;
}

static __device__ void project_load_slot_0(uint tid_13, Island_0 * isl_17, uint slot_3, uint _S1259)
{
    uint _S1260;
    uint _S1261;
    float3  _S1262 = make_float3 (0.0f);
    float3  net_f_0 = _S1262;
    float3  net_m_0 = _S1262;
    uint4  _S1263 = isl_17->range_0;
    uint _S1264 = isl_17->range_0.x + tid_13;
    uint c_18 = _S1264;
    uint _S1265 = _S1259;
    for(;;)
    {
        uint _S1266 = _S1263.y;
        _S1260 = _S1266;
        bool _S1267 = c_18 < _S1266;
        uint _S1268 = __ballot_sync(_S1265, _S1267);
        if(_S1267)
        {
            uint _S1269 = __ballot_sync(_S1265, true);
        }
        else
        {
            uint _S1270 = __ballot_sync(_S1265, false);
            uint _S1271 = __ballot_sync(_S1265, false);
            uint _S1272 = __ballot_sync(_S1259, true);
            _S1261 = _S1272;
            break;
        }
        float4  _S1273 = *(&(globalParams_0->scratch_0)[sv_0(c_18, slot_3)]);
        float3  fi_0 = float3 {_S1273.x, _S1273.y, _S1273.z};
        net_f_0 = net_f_0 + fi_0;
        float4  _S1274 = __ldg(&(&(globalParams_0->chunks_0)[c_18])->center_0);
        float4  _S1275 = isl_17->com_0;
        float4  _S1276 = *(&(globalParams_0->scratch_0)[sv_0(c_18, slot_3 + 1U)]);
        net_m_0 = net_m_0 + (cross_0(float3 {_S1274.x, _S1274.y, _S1274.z} - float3 {_S1275.x, _S1275.y, _S1275.z}, fi_0) + float3 {_S1276.x, _S1276.y, _S1276.z});
        uint _S1277 = __ballot_sync(_S1265, true);
        c_18 = c_18 + 256U;
        _S1265 = _S1277;
    }
    group_sum3_0(tid_13, &net_f_0, &net_m_0, _S1261);
    float4  _S1278 = isl_17->com_0;
    float3  _S1279 = net_f_0 / make_float3 (isl_17->com_0.w);
    float3  _S1280 = rows_mul_0(isl_17->inv0_1, isl_17->inv1_1, isl_17->inv2_1, net_m_0);
    c_18 = _S1264;
    for(;;)
    {
        if(c_18 < _S1260)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_0 * _S1281 = (&(globalParams_0->chunks_0)[c_18]);
        float4  _S1282 = __ldg(&_S1281->center_0);
        uint _S1283 = sv_0(c_18, slot_3);
        float4  _S1284 = *(&(globalParams_0->scratch_0)[_S1283]);
        *(&(globalParams_0->scratch_0)[_S1283]) = make_float4 ((float3 {_S1284.x, _S1284.y, _S1284.z} - (_S1279 + cross_0(_S1280, float3 {_S1282.x, _S1282.y, _S1282.z} - float3 {_S1278.x, _S1278.y, _S1278.z})) * make_float3 (_S1282.w)).x, (float3 {_S1284.x, _S1284.y, _S1284.z} - (_S1279 + cross_0(_S1280, float3 {_S1282.x, _S1282.y, _S1282.z} - float3 {_S1278.x, _S1278.y, _S1278.z})) * make_float3 (_S1282.w)).y, (float3 {_S1284.x, _S1284.y, _S1284.z} - (_S1279 + cross_0(_S1280, float3 {_S1282.x, _S1282.y, _S1282.z} - float3 {_S1278.x, _S1278.y, _S1278.z})) * make_float3 (_S1282.w)).z, 0.0f);
        uint _S1285 = sv_0(c_18, slot_3 + 1U);
        float4  * _S1286 = (&(globalParams_0->scratch_0)[_S1285]);
        float4  _S1287 = *(&(globalParams_0->scratch_0)[_S1285]);
        float3  _S1288 = float3 {_S1287.x, _S1287.y, _S1287.z};
        float4  _S1289 = __ldg(&_S1281->inertia0_0);
        float4  _S1290 = __ldg(&_S1281->inertia1_0);
        float4  _S1291 = __ldg(&_S1281->inertia2_0);
        *_S1286 = make_float4 ((_S1288 - rows_mul_0(_S1289, _S1290, _S1291, _S1280)).x, (_S1288 - rows_mul_0(_S1289, _S1290, _S1291, _S1280)).y, (_S1288 - rows_mul_0(_S1289, _S1290, _S1291, _S1280)).z, 0.0f);
        c_18 = c_18 + 256U;
    }
    __syncthreads();
    return;
}

static __device__ float island_dot_0(uint tid_14, uint c0_0, uint c1_0, uint sa_2, uint sb_2, uint _S1292)
{
    uint _S1293;
    float4  _S1294 = make_float4 (0.0f);
    float4  acc_0 = _S1294;
    float4  unused_2 = _S1294;
    uint c_19 = c0_0 + tid_14;
    uint _S1295 = _S1292;
    for(;;)
    {
        bool _S1296 = c_19 < c1_0;
        uint _S1297 = __ballot_sync(_S1295, _S1296);
        if(_S1296)
        {
            uint _S1298 = __ballot_sync(_S1295, true);
        }
        else
        {
            uint _S1299 = __ballot_sync(_S1295, false);
            uint _S1300 = __ballot_sync(_S1295, false);
            uint _S1301 = __ballot_sync(_S1292, true);
            _S1293 = _S1301;
            break;
        }
        float4  _S1302 = *(&(globalParams_0->scratch_0)[sv_0(c_19, sa_2)]);
        float4  _S1303 = *(&(globalParams_0->scratch_0)[sv_0(c_19, sb_2)]);
        float4  _S1304 = *(&(globalParams_0->scratch_0)[sv_0(c_19, sa_2 + 1U)]);
        float4  _S1305 = *(&(globalParams_0->scratch_0)[sv_0(c_19, sb_2 + 1U)]);
        *&((&acc_0)->x) = *&((&acc_0)->x) + (dot_0(float3 {_S1302.x, _S1302.y, _S1302.z}, float3 {_S1303.x, _S1303.y, _S1303.z}) + dot_0(float3 {_S1304.x, _S1304.y, _S1304.z}, float3 {_S1305.x, _S1305.y, _S1305.z}));
        uint _S1306 = __ballot_sync(_S1295, true);
        c_19 = c_19 + 256U;
        _S1295 = _S1306;
    }
    group_sum2_0(tid_14, &acc_0, &unused_2, _S1293);
    return acc_0.x;
}

static __device__ void static_kinematics_0(uint _S1307, float3  * _S1308, float3  * _S1309)
{
    BondStatic_0 * _S1310 = (&(globalParams_0->bonds_0)[_S1307]);
    JointBond_0 _S1311 = slang_ldg_0(&_S1310->law_0);
    uint ca_1 = _S1311.ids_0.y;
    uint cb_1 = _S1311.ids_0.z;
    uint _S1312 = 4U * cb_1;
    float4  _S1313 = *(&(globalParams_0->state_0)[_S1312]);
    uint _S1314 = 4U * ca_1;
    float4  _S1315 = *(&(globalParams_0->state_0)[_S1314]);
    float4  _S1316 = *(&(globalParams_0->scratch_0)[sv_0(cb_1, 21U)]);
    float4  _S1317 = *(&(globalParams_0->scratch_0)[sv_0(ca_1, 21U)]);
    float3  du_0 = float3 {_S1313.x, _S1313.y, _S1313.z} - float3 {_S1315.x, _S1315.y, _S1315.z} + (float3 {_S1316.x, _S1316.y, _S1316.z} - float3 {_S1317.x, _S1317.y, _S1317.z});
    uint _S1318 = _S1312 + 1U;
    float4  _S1319 = *(&(globalParams_0->state_0)[_S1318]);
    uint _S1320 = _S1314 + 1U;
    float4  _S1321 = *(&(globalParams_0->state_0)[_S1320]);
    uint _S1322 = sv_0(cb_1, 22U);
    float4  _S1323 = *(&(globalParams_0->scratch_0)[_S1322]);
    uint _S1324 = sv_0(ca_1, 22U);
    float4  _S1325 = *(&(globalParams_0->scratch_0)[_S1324]);
    float3  dth_0 = float3 {_S1319.x, _S1319.y, _S1319.z} - float3 {_S1321.x, _S1321.y, _S1321.z} + (float3 {_S1323.x, _S1323.y, _S1323.z} - float3 {_S1325.x, _S1325.y, _S1325.z});
    float4  _S1326 = *(&(globalParams_0->state_0)[_S1320]);
    float4  _S1327 = *(&(globalParams_0->scratch_0)[_S1324]);
    float3  ta_3 = float3 {_S1326.x, _S1326.y, _S1326.z} + float3 {_S1327.x, _S1327.y, _S1327.z};
    float4  _S1328 = *(&(globalParams_0->state_0)[_S1318]);
    float4  _S1329 = *(&(globalParams_0->scratch_0)[_S1322]);
    float3  tb_3 = float3 {_S1328.x, _S1328.y, _S1328.z} + float3 {_S1329.x, _S1329.y, _S1329.z};
    float4  _S1330 = __ldg(&_S1310->rb_0);
    float3  _S1331 = cross_0(tb_3, float3 {_S1330.x, _S1330.y, _S1330.z});
    float4  _S1332 = __ldg(&_S1310->ra_0);
    float3  _S1333 = to_local_0(_S1307, du_0 + (_S1331 - cross_0(ta_3, float3 {_S1332.x, _S1332.y, _S1332.z})));
    *_S1308 = _S1333;
    float3  _S1334 = to_local_0(_S1307, dth_0);
    *_S1309 = _S1334;
    return;
}

static __device__ JointResponse_0 static_response_0(uint i_17)
{
    BondStatic_0 * _S1335 = (&(globalParams_0->bonds_0)[i_17]);
    float3  d_lin_4;
    float3  d_ang_3;
    static_kinematics_0(i_17, &d_lin_4, &d_ang_3);
    JointBond_0 _S1336 = slang_ldg_0(&_S1335->law_0);
    JointBond_0 _S1337 = _S1336;
    JointState_0 _S1338 = (&(globalParams_0->bond_dyn_0)[i_17])->js_0;
    JointResponse_0 _S1339 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S1336.ids_0.x], &_S1337, &_S1338, d_lin_4, d_ang_3, 0.0f, false);
    return _S1339;
}

static __device__ void gather_loads_0(uint c_20, float3  * fi_1, float3  * mi_0)
{
    float3  _S1340 = make_float3 (0.0f);
    *fi_1 = _S1340;
    *mi_0 = _S1340;
    uint _S1341 = __ldg((&(globalParams_0->index_0)[c_20]));
    uint e_3 = _S1341;
    for(;;)
    {
        uint _S1342 = __ldg((&(globalParams_0->index_0)[c_20 + 1U]));
        if(e_3 < _S1342)
        {
        }
        else
        {
            break;
        }
        uint _S1343 = __ldg((&(globalParams_0->index_0)[e_3]));
        uint bond_1 = _S1343 >> int(1);
        if((_S1343 & 1U) == 0U)
        {
            uint _S1344 = 3U * bond_1;
            float4  _S1345 = *(&(globalParams_0->scratch_0)[_S1344]);
            *fi_1 = *fi_1 + float3 {_S1345.x, _S1345.y, _S1345.z};
            float4  _S1346 = *(&(globalParams_0->scratch_0)[_S1344 + 1U]);
            *mi_0 = *mi_0 + float3 {_S1346.x, _S1346.y, _S1346.z};
        }
        else
        {
            uint _S1347 = 3U * bond_1;
            float4  _S1348 = *(&(globalParams_0->scratch_0)[_S1347]);
            *fi_1 = *fi_1 - float3 {_S1348.x, _S1348.y, _S1348.z};
            float4  _S1349 = *(&(globalParams_0->scratch_0)[_S1347 + 2U]);
            *mi_0 = *mi_0 + float3 {_S1349.x, _S1349.y, _S1349.z};
        }
        e_3 = e_3 + 1U;
    }
    return;
}

static __device__ float bond_load_magnitude2_0(uint c_21)
{
    uint _S1350 = __ldg((&(globalParams_0->index_0)[c_21]));
    uint e_4 = _S1350;
    float m_4 = 0.0f;
    for(;;)
    {
        uint _S1351 = __ldg((&(globalParams_0->index_0)[c_21 + 1U]));
        if(e_4 < _S1351)
        {
        }
        else
        {
            break;
        }
        uint _S1352 = __ldg((&(globalParams_0->index_0)[e_4]));
        uint _S1353 = 3U * (_S1352 >> int(1));
        float4  _S1354 = *(&(globalParams_0->scratch_0)[_S1353]);
        float3  f_13 = float3 {_S1354.x, _S1354.y, _S1354.z};
        float3  t_12;
        if((_S1352 & 1U) == 0U)
        {
            float4  _S1355 = *(&(globalParams_0->scratch_0)[_S1353 + 1U]);
            t_12 = float3 {_S1355.x, _S1355.y, _S1355.z};
        }
        else
        {
            float4  _S1356 = *(&(globalParams_0->scratch_0)[_S1353 + 2U]);
            t_12 = float3 {_S1356.x, _S1356.y, _S1356.z};
        }
        float m_5 = m_4 + (dot_0(f_13, f_13) + dot_0(t_12, t_12));
        e_4 = e_4 + 1U;
        m_4 = m_5;
    }
    return m_4;
}

static __device__ uint fixed_mask_0(uint c_22)
{
    uint4  _S1357 = __ldg(&(&(globalParams_0->chunks_0)[c_22])->info_0);
    uint support_0 = _S1357.x;
    uint _S1358;
    if(support_0 == 1U)
    {
        _S1358 = 63U;
    }
    else
    {
        if(support_0 == 2U)
        {
            _S1358 = 7U;
        }
        else
        {
            _S1358 = 0U;
        }
    }
    return _S1358;
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
    uint _S1359 = __ldg(&globalParams_0->params_0->statics_base_0);
    uint _S1360 = __ldg(&globalParams_0->params_0->chunk_count_0);
    return _S1359 + 23U * _S1360 + 2U * i_18;
}

static __device__ void store_inverse_0(uint c_23, FixedArray<float, 36>  * a_17)
{
    uint j_8;
    float sum_4;
    FixedArray<float, 36>  l_4;
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
        l_4[k_16] = 0.0f;
        k_16 = k_16 + 1U;
    }
    bool spd_0 = true;
    uint i_19 = 0U;
    for(;;)
    {
        bool _S1361;
        if(i_19 < 6U)
        {
            _S1361 = spd_0;
        }
        else
        {
            _S1361 = false;
        }
        if(_S1361)
        {
        }
        else
        {
            break;
        }
        j_8 = 0U;
        for(;;)
        {
            if(j_8 <= i_19)
            {
            }
            else
            {
                break;
            }
            uint _S1362 = i_19 * 6U;
            uint _S1363 = _S1362 + j_8;
            k_16 = 0U;
            sum_4 = (*a_17)[_S1363];
            for(;;)
            {
                if(k_16 < j_8)
                {
                }
                else
                {
                    break;
                }
                float sum_5 = sum_4 - l_4[_S1362 + k_16] * l_4[j_8 * 6U + k_16];
                k_16 = k_16 + 1U;
                sum_4 = sum_5;
            }
            if(i_19 == j_8)
            {
                if(sum_4 <= 0.0f)
                {
                    spd_0 = false;
                    break;
                }
                l_4[_S1362 + i_19] = (F32_sqrt((sum_4)));
            }
            else
            {
                l_4[_S1363] = sum_4 / l_4[j_8 * 6U + j_8];
            }
            j_8 = j_8 + 1U;
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
            uint _S1364 = k_16 * 6U + k_16;
            float _S1365 = (*a_17)[_S1364];
            if(((*a_17)[_S1364]) > 0.0f)
            {
                sum_4 = 1.0f / _S1365;
            }
            else
            {
                sum_4 = 0.0f;
            }
            inv_0[_S1364] = sum_4;
            k_16 = k_16 + 1U;
        }
    }
    else
    {
        j_8 = 0U;
        for(;;)
        {
            if(j_8 < 6U)
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
                if(i_19 == j_8)
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
                    float s_7 = s_6 - l_4[i_19 * 6U + k_16] * y_6[k_16];
                    k_16 = k_16 + 1U;
                    s_6 = s_7;
                }
                y_6[i_19] = s_6 / l_4[i_19 * 6U + i_19];
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
                    float s_8 = sum_4 - l_4[k_16 * 6U + i_20] * x_25[k_16];
                    k_16 = k_16 + 1U;
                    sum_4 = s_8;
                }
                x_25[i_20] = sum_4 / l_4[i_20 * 6U + i_20];
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
                inv_0[i_21 * 6U + j_8] = x_25[i_21];
                i_21 = i_21 + 1U;
            }
            j_8 = j_8 + 1U;
        }
    }
    j_8 = 0U;
    for(;;)
    {
        if(j_8 < 9U)
        {
        }
        else
        {
            break;
        }
        uint _S1366 = 4U * j_8;
        *(&(globalParams_0->scratch_0)[sv_0(c_23, 12U + j_8)]) = make_float4 (inv_0[_S1366], inv_0[_S1366 + 1U], inv_0[_S1366 + 2U], inv_0[_S1366 + 3U]);
        j_8 = j_8 + 1U;
    }
    return;
}

static __device__ void assemble_block_0(uint c_24)
{
    uint p_14;
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
    uint _S1367 = __ldg((&(globalParams_0->index_0)[c_24]));
    uint e_5 = _S1367;
    for(;;)
    {
        uint _S1368 = __ldg((&(globalParams_0->index_0)[c_24 + 1U]));
        if(e_5 < _S1368)
        {
        }
        else
        {
            break;
        }
        uint _S1369 = __ldg((&(globalParams_0->index_0)[e_5]));
        uint i_22 = _S1369 >> int(1);
        bool _S1370 = (_S1369 & 1U) != 0U;
        BondStatic_0 * _S1371 = (&(globalParams_0->bonds_0)[i_22]);
        uint _S1372 = statics_bond_slot_0(i_22);
        float4  _S1373 = *(&(globalParams_0->scratch_0)[_S1372]);
        float4  _S1374 = *(&(globalParams_0->scratch_0)[_S1372 + 1U]);
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
            uint _S1375 = p_14 % 3U;
            float3  t_13;
            if(_S1375 == 0U)
            {
                float4  _S1376 = __ldg(&_S1371->t1_0);
                t_13 = float3 {_S1376.x, _S1376.y, _S1376.z};
            }
            else
            {
                if(_S1375 == 1U)
                {
                    float4  _S1377 = __ldg(&_S1371->t2_0);
                    t_13 = float3 {_S1377.x, _S1377.y, _S1377.z};
                }
                else
                {
                    float4  _S1378 = __ldg(&_S1371->normal_0);
                    t_13 = float3 {_S1378.x, _S1378.y, _S1378.z};
                }
            }
            bool _S1379 = p_14 < 3U;
            float3  row_u_0;
            float3  row_t_0;
            if(_S1379)
            {
                if(_S1370)
                {
                    row_u_0 = t_13;
                }
                else
                {
                    row_u_0 = - t_13;
                }
                if(_S1370)
                {
                    float4  _S1380 = __ldg(&_S1371->rb_0);
                    row_t_0 = cross_0(float3 {_S1380.x, _S1380.y, _S1380.z}, t_13);
                }
                else
                {
                    float4  _S1381 = __ldg(&_S1371->ra_0);
                    row_t_0 = - cross_0(float3 {_S1381.x, _S1381.y, _S1381.z}, t_13);
                }
            }
            else
            {
                float3  _S1382 = make_float3 (0.0f);
                if(_S1370)
                {
                    row_u_0 = t_13;
                }
                else
                {
                    row_u_0 = - t_13;
                }
                float3  _S1383 = row_u_0;
                row_u_0 = _S1382;
                row_t_0 = _S1383;
            }
            float kp_0;
            if(_S1379)
            {
                kp_0 = _slang_vector_get_element(_S1373, p_14);
            }
            else
            {
                kp_0 = _slang_vector_get_element(_S1374, p_14 - 3U);
            }
            if(kp_0 == 0.0f)
            {
                p_14 = p_14 + 1U;
                continue;
            }
            FixedArray<float, 6>  _S1384 = { {
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
                    a_18[r_11 * 6U + q_12] = a_18[r_11 * 6U + q_12] + kp_0 * _S1384[r_11] * _S1384[q_12];
                    q_12 = q_12 + 1U;
                }
                r_11 = r_11 + 1U;
            }
            p_14 = p_14 + 1U;
        }
        e_5 = e_5 + 1U;
    }
    uint _S1385 = fixed_mask_0(c_24);
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
        if((_S1385 & (1U << p_14)) != 0U)
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
    FixedArray<float, 36>  _S1386 = a_18;
    store_inverse_0(c_24, &_S1386);
    return;
}

static __device__ float block_get_0(uint c_25, uint i_23, uint j_9)
{
    uint k_18 = i_23 * 6U + j_9;
    return *_slang_vector_get_element_ptr((&(globalParams_0->scratch_0)[sv_0(c_25, 12U + k_18 / 4U)]), k_18 % 4U);
}

static __device__ void precondition_0(uint c_26)
{
    float4  * _S1387 = (&(globalParams_0->scratch_0)[sv_0(c_26, 4U)]);
    float4  * _S1388 = (&(globalParams_0->scratch_0)[sv_0(c_26, 5U)]);
    FixedArray<float, 6>  _S1389 = { {
        (*_S1387).x, (*_S1387).y, (*_S1387).z, (*_S1388).x, (*_S1388).y, (*_S1388).z
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
        uint j_10 = 0U;
        float s_9 = 0.0f;
        for(;;)
        {
            if(j_10 < 6U)
            {
            }
            else
            {
                break;
            }
            float s_10 = s_9 + block_get_0(c_26, i_24, j_10) * _S1389[j_10];
            j_10 = j_10 + 1U;
            s_9 = s_10;
        }
        z_1[i_24] = s_9;
        i_24 = i_24 + 1U;
    }
    *(&(globalParams_0->scratch_0)[sv_0(c_26, 6U)]) = make_float4 (z_1[int(0)], z_1[int(1)], z_1[int(2)], 0.0f);
    *(&(globalParams_0->scratch_0)[sv_0(c_26, 7U)]) = make_float4 (z_1[int(3)], z_1[int(4)], z_1[int(5)], 0.0f);
    return;
}

static __device__ void project_displacement_slot_0(uint tid_15, Island_0 * isl_18, uint slot_4, uint _S1390)
{
    uint _S1391;
    uint _S1392;
    float3  _S1393 = make_float3 (0.0f);
    float3  p_15 = _S1393;
    float3  l_5 = _S1393;
    uint4  _S1394 = isl_18->range_0;
    uint _S1395 = isl_18->range_0.x + tid_15;
    uint c_27 = _S1395;
    uint _S1396 = _S1390;
    for(;;)
    {
        uint _S1397 = _S1394.y;
        _S1391 = _S1397;
        bool _S1398 = c_27 < _S1397;
        uint _S1399 = __ballot_sync(_S1396, _S1398);
        if(_S1398)
        {
            uint _S1400 = __ballot_sync(_S1396, true);
        }
        else
        {
            uint _S1401 = __ballot_sync(_S1396, false);
            uint _S1402 = __ballot_sync(_S1396, false);
            uint _S1403 = __ballot_sync(_S1390, true);
            _S1392 = _S1403;
            break;
        }
        ChunkStatic_0 * _S1404 = (&(globalParams_0->chunks_0)[c_27]);
        float4  _S1405 = *(&(globalParams_0->scratch_0)[sv_0(c_27, slot_4)]);
        float3  u_0 = float3 {_S1405.x, _S1405.y, _S1405.z};
        float4  _S1406 = *(&(globalParams_0->scratch_0)[sv_0(c_27, slot_4 + 1U)]);
        float3  th_2 = float3 {_S1406.x, _S1406.y, _S1406.z};
        float4  _S1407 = __ldg(&_S1404->center_0);
        float4  _S1408 = isl_18->com_0;
        float3  r_12 = float3 {_S1407.x, _S1407.y, _S1407.z} - float3 {_S1408.x, _S1408.y, _S1408.z};
        float _S1409 = _S1407.w;
        p_15 = p_15 + u_0 * make_float3 (_S1409);
        float3  _S1410 = cross_0(r_12, u_0) * make_float3 (_S1409);
        float4  _S1411 = __ldg(&_S1404->inertia0_0);
        float4  _S1412 = __ldg(&_S1404->inertia1_0);
        float4  _S1413 = __ldg(&_S1404->inertia2_0);
        l_5 = l_5 + (_S1410 + rows_mul_0(_S1411, _S1412, _S1413, th_2));
        uint _S1414 = __ballot_sync(_S1396, true);
        c_27 = c_27 + 256U;
        _S1396 = _S1414;
    }
    group_sum3_0(tid_15, &p_15, &l_5, _S1392);
    float4  _S1415 = isl_18->com_0;
    float3  _S1416 = p_15 / make_float3 (isl_18->com_0.w);
    float3  _S1417 = rows_mul_0(isl_18->inv0_1, isl_18->inv1_1, isl_18->inv2_1, l_5);
    c_27 = _S1395;
    for(;;)
    {
        if(c_27 < _S1391)
        {
        }
        else
        {
            break;
        }
        float4  _S1418 = __ldg(&(&(globalParams_0->chunks_0)[c_27])->center_0);
        uint _S1419 = sv_0(c_27, slot_4);
        float4  _S1420 = *(&(globalParams_0->scratch_0)[_S1419]);
        *(&(globalParams_0->scratch_0)[_S1419]) = make_float4 ((float3 {_S1420.x, _S1420.y, _S1420.z} - _S1416 - cross_0(_S1417, float3 {_S1418.x, _S1418.y, _S1418.z} - float3 {_S1415.x, _S1415.y, _S1415.z})).x, (float3 {_S1420.x, _S1420.y, _S1420.z} - _S1416 - cross_0(_S1417, float3 {_S1418.x, _S1418.y, _S1418.z} - float3 {_S1415.x, _S1415.y, _S1415.z})).y, (float3 {_S1420.x, _S1420.y, _S1420.z} - _S1416 - cross_0(_S1417, float3 {_S1418.x, _S1418.y, _S1418.z} - float3 {_S1415.x, _S1415.y, _S1415.z})).z, 0.0f);
        uint _S1421 = sv_0(c_27, slot_4 + 1U);
        float4  _S1422 = *(&(globalParams_0->scratch_0)[_S1421]);
        *(&(globalParams_0->scratch_0)[_S1421]) = make_float4 ((float3 {_S1422.x, _S1422.y, _S1422.z} - _S1417).x, (float3 {_S1422.x, _S1422.y, _S1422.z} - _S1417).y, (float3 {_S1422.x, _S1422.y, _S1422.z} - _S1417).z, 0.0f);
        c_27 = c_27 + 256U;
    }
    __syncthreads();
    return;
}

static __device__ uint statics_result_slot_0(uint island_3)
{
    uint _S1423 = __ldg(&globalParams_0->params_0->statics_base_0);
    uint _S1424 = __ldg(&globalParams_0->params_0->chunk_count_0);
    uint _S1425 = _S1423 + 23U * _S1424;
    uint _S1426 = __ldg(&globalParams_0->params_0->statics_bonds_0);
    return _S1425 + 2U * _S1426 + island_3;
}

static __device__ void write_bond_loads_0(uint _S1427, uint _S1428, float3  _S1429, float3  _S1430, float _S1431)
{
    BondStatic_0 * _S1432 = (&(globalParams_0->bonds_0)[_S1428]);
    float3  _S1433 = to_body_0(_S1428, _S1429);
    float3  _S1434 = to_body_0(_S1428, _S1430);
    uint _S1435 = 3U * _S1427;
    *(&(globalParams_0->scratch_0)[_S1435]) = make_float4 (_S1433.x, _S1433.y, _S1433.z, _S1431);
    float4  * _S1436 = (&(globalParams_0->scratch_0)[_S1435 + 1U]);
    float4  _S1437 = __ldg(&_S1432->ra_0);
    *_S1436 = make_float4 ((_S1434 + cross_0(float3 {_S1437.x, _S1437.y, _S1437.z}, _S1433)).x, (_S1434 + cross_0(float3 {_S1437.x, _S1437.y, _S1437.z}, _S1433)).y, (_S1434 + cross_0(float3 {_S1437.x, _S1437.y, _S1437.z}, _S1433)).z, 0.0f);
    float4  * _S1438 = (&(globalParams_0->scratch_0)[_S1435 + 2U]);
    float3  _S1439 = - _S1434;
    float4  _S1440 = __ldg(&_S1432->rb_0);
    *_S1438 = make_float4 ((_S1439 + cross_0(float3 {_S1440.x, _S1440.y, _S1440.z}, - _S1433)).x, (_S1439 + cross_0(float3 {_S1440.x, _S1440.y, _S1440.z}, - _S1433)).y, (_S1439 + cross_0(float3 {_S1440.x, _S1440.y, _S1440.z}, - _S1433)).z, 0.0f);
    return;
}

static __device__ void bond_kinematics_0(uint _S1441, float3  _S1442, float3  _S1443, float3  _S1444, float3  _S1445, float3  * _S1446, float3  * _S1447)
{
    BondStatic_0 * _S1448 = (&(globalParams_0->bonds_0)[_S1441]);
    float4  _S1449 = __ldg(&_S1448->rb_0);
    float3  _S1450 = _S1444 + cross_0(_S1445, float3 {_S1449.x, _S1449.y, _S1449.z});
    float4  _S1451 = __ldg(&_S1448->ra_0);
    float3  _S1452 = to_local_0(_S1441, _S1450 - (_S1442 + cross_0(_S1443, float3 {_S1451.x, _S1451.y, _S1451.z})));
    *_S1446 = _S1452;
    float3  _S1453 = to_local_0(_S1441, _S1445 - _S1443);
    *_S1447 = _S1453;
    return;
}

extern "C" __global__ void island_statics()
{
    uint _S1454 = 0U;
    uint _S1455;
    uint i_25;
    uint c_28;
    bool converged_2;
    uint _S1456;
    uint _S1457;
    uint _S1458;
    uint _S1459;
    uint _S1460;
    uint _S1461;
    uint i_26;
    uint _S1462;
    uint _S1463;
    uint _S1464;
    uint _S1465;
    uint _S1466;
    uint _S1467 = __ballot_sync(4294967295U, true);
    uint tid_16 = threadIdx.x;
    uint _S1468 = blockIdx.x;
    Island_0 * _S1469 = (&(globalParams_0->islands_0)[_S1468]);
    Island_0 isl_19 = *_S1469;
    uint _S1470 = (*_S1469).info_1.z;
    bool _S1471 = (_S1470 & 8U) == 0U;
    uint _S1472 = __ballot_sync(_S1467, _S1471);
    if(_S1471)
    {
        return;
    }
    else
    {
        uint _S1473 = __ballot_sync(_S1467, true);
        _S1454 = _S1473;
    }
    bool free_0 = ((isl_19.info_1.x) & 1U) == 0U;
    uint c0_1 = isl_19.range_0.x;
    uint c1_1 = isl_19.range_0.y;
    uint b0_0 = isl_19.range_0.z;
    uint _S1474 = isl_19.range_0.w;
    uint _S1475 = c0_1 + tid_16;
    uint c_29 = _S1475;
    uint newton_0;
    newton_0 = _S1454;
    for(;;)
    {
        bool _S1476 = c_29 < c1_1;
        uint _S1477 = __ballot_sync(newton_0, _S1476);
        if(_S1476)
        {
            uint _S1478 = __ballot_sync(newton_0, true);
        }
        else
        {
            uint _S1479 = __ballot_sync(newton_0, false);
            uint _S1480 = __ballot_sync(newton_0, false);
            uint _S1481 = __ballot_sync(_S1454, true);
            _S1455 = _S1481;
            break;
        }
        float4  _S1482 = make_float4 (0.0f);
        *(&(globalParams_0->scratch_0)[sv_0(c_29, 21U)]) = _S1482;
        *(&(globalParams_0->scratch_0)[sv_0(c_29, 22U)]) = _S1482;
        uint _S1483 = __ballot_sync(newton_0, true);
        c_29 = c_29 + 256U;
        newton_0 = _S1483;
    }
    __syncthreads();
    uint _S1484 = __ballot_sync(_S1455, free_0);
    if(free_0)
    {
        Island_0 _S1485 = isl_19;
        project_load_slot_0(tid_16, &_S1485, 0U, _S1484);
        uint _S1486 = __ballot_sync(_S1455, true);
        c_29 = _S1486;
    }
    else
    {
        uint _S1487 = __ballot_sync(_S1455, true);
        c_29 = _S1487;
    }
    float _S1488 = island_dot_0(tid_16, c0_1, c1_1, 0U, 0U, c_29);
    float _S1489 = (F32_max(((F32_sqrt((_S1488)))), (1.00000000317107685e-30f)));
    float _S1490 = __ldg(&globalParams_0->params_0->statics_tol_0);
    uint _S1491 = __ldg(&globalParams_0->params_0->statics_cg_0);
    uint _S1492 = (U32_min((_S1491), (20U * (c1_1 - c0_1) * 6U + 200U)));
    float previous_2 = 1.00000001504746622e+30f;
    float residual_0 = 0.0f;
    newton_0 = 0U;
    uint cg_total_0 = 0U;
    for(;;)
    {
        uint _S1493 = 0U;
        uint _S1494 = __ldg(&globalParams_0->params_0->statics_newton_0);
        bool _S1495 = newton_0 < _S1494;
        uint _S1496 = __ballot_sync(c_29, _S1495);
        if(_S1495)
        {
            uint _S1497 = __ballot_sync(c_29, true);
            _S1493 = _S1497;
        }
        else
        {
            converged_2 = false;
            break;
        }
        uint _S1498 = b0_0 + tid_16;
        i_25 = _S1498;
        uint _S1499;
        _S1499 = _S1493;
        for(;;)
        {
            bool _S1500 = i_25 < _S1474;
            uint _S1501 = __ballot_sync(_S1499, _S1500);
            if(_S1500)
            {
                uint _S1502 = __ballot_sync(_S1499, true);
            }
            else
            {
                uint _S1503 = __ballot_sync(_S1499, false);
                uint _S1504 = __ballot_sync(_S1499, false);
                uint _S1505 = __ballot_sync(_S1493, true);
                _S1456 = _S1505;
                break;
            }
            JointResponse_0 resp_1 = static_response_0(i_25);
            write_bond_loads_0(i_25, i_25, resp_1.force_lin_1, resp_1.force_ang_1, 0.0f);
            uint _S1506 = __ballot_sync(_S1499, true);
            i_25 = i_25 + 256U;
            _S1499 = _S1506;
        }
        __syncthreads();
        float4  _S1507 = make_float4 (0.0f);
        float4  magnitude_0 = _S1507;
        float4  unused_m_0 = _S1507;
        uint c_30 = _S1475;
        uint _S1508 = _S1456;
        for(;;)
        {
            bool _S1509 = c_30 < c1_1;
            uint _S1510 = __ballot_sync(_S1508, _S1509);
            if(_S1509)
            {
                uint _S1511 = __ballot_sync(_S1508, true);
            }
            else
            {
                uint _S1512 = __ballot_sync(_S1508, false);
                uint _S1513 = __ballot_sync(_S1508, false);
                uint _S1514 = __ballot_sync(_S1456, true);
                _S1457 = _S1514;
                break;
            }
            float3  fi_2;
            float3  mi_1;
            gather_loads_0(c_30, &fi_2, &mi_1);
            *&((&magnitude_0)->x) = *&((&magnitude_0)->x) + bond_load_magnitude2_0(c_30);
            float4  _S1515 = *(&(globalParams_0->scratch_0)[sv_0(c_30, 0U)]);
            float4  r_lin_0 = make_float4 ((float3 {_S1515.x, _S1515.y, _S1515.z} + fi_2).x, (float3 {_S1515.x, _S1515.y, _S1515.z} + fi_2).y, (float3 {_S1515.x, _S1515.y, _S1515.z} + fi_2).z, 0.0f);
            float4  _S1516 = *(&(globalParams_0->scratch_0)[sv_0(c_30, 1U)]);
            float4  r_ang_0 = make_float4 ((float3 {_S1516.x, _S1516.y, _S1516.z} + mi_1).x, (float3 {_S1516.x, _S1516.y, _S1516.z} + mi_1).y, (float3 {_S1516.x, _S1516.y, _S1516.z} + mi_1).z, 0.0f);
            hold_0(fixed_mask_0(c_30), &r_lin_0, &r_ang_0, _S1507, _S1507);
            *(&(globalParams_0->scratch_0)[sv_0(c_30, 4U)]) = r_lin_0;
            *(&(globalParams_0->scratch_0)[sv_0(c_30, 5U)]) = r_ang_0;
            uint _S1517 = __ballot_sync(_S1508, true);
            c_30 = c_30 + 256U;
            _S1508 = _S1517;
        }
        __syncthreads();
        group_sum2_0(tid_16, &magnitude_0, &unused_m_0, _S1457);
        uint _S1518 = __ballot_sync(_S1457, free_0);
        uint _S1519;
        if(free_0)
        {
            Island_0 _S1520 = isl_19;
            project_load_slot_0(tid_16, &_S1520, 4U, _S1518);
            uint _S1521 = __ballot_sync(_S1457, true);
            _S1519 = _S1521;
        }
        else
        {
            uint _S1522 = __ballot_sync(_S1457, true);
            _S1519 = _S1522;
        }
        float _S1523 = island_dot_0(tid_16, c0_1, c1_1, 4U, 4U, _S1519);
        float residual_1 = (F32_sqrt((_S1523))) / _S1489;
        float _S1524 = (F32_max((0.00100000004749745f), (3.83999986297567375e-06f * (F32_sqrt((magnitude_0.x))) / _S1489)));
        bool _S1525 = residual_1 <= _S1490;
        uint _S1526 = __ballot_sync(_S1519, _S1525);
        uint _S1527;
        if(_S1525)
        {
            uint _S1528 = __ballot_sync(_S1519, true);
            converged_2 = true;
            _S1527 = _S1528;
        }
        else
        {
            uint _S1529 = _S1519 & (~_S1526);
            bool _S1530 = residual_1 <= _S1524;
            uint _S1531 = __ballot_sync(_S1529, _S1530);
            if(_S1530)
            {
                bool _S1532 = residual_1 > (0.5f * previous_2);
                uint _S1533 = __ballot_sync(_S1529, true);
                converged_2 = _S1532;
            }
            else
            {
                uint _S1534 = __ballot_sync(_S1529, true);
                converged_2 = false;
            }
            uint _S1535 = __ballot_sync(_S1519, true);
            _S1527 = _S1535;
        }
        uint _S1536 = 0U;
        uint _S1537 = __ballot_sync(_S1527, converged_2);
        if(converged_2)
        {
            residual_0 = residual_1;
            converged_2 = true;
            break;
        }
        else
        {
            uint _S1538 = __ballot_sync(_S1527, true);
            _S1536 = _S1538;
        }
        uint i_27 = _S1498;
        uint _S1539;
        _S1539 = _S1536;
        for(;;)
        {
            bool _S1540 = i_27 < _S1474;
            uint _S1541 = __ballot_sync(_S1539, _S1540);
            if(_S1540)
            {
                uint _S1542 = __ballot_sync(_S1539, true);
            }
            else
            {
                uint _S1543 = __ballot_sync(_S1539, false);
                uint _S1544 = __ballot_sync(_S1539, false);
                uint _S1545 = __ballot_sync(_S1536, true);
                _S1458 = _S1545;
                break;
            }
            BondStatic_0 * _S1546 = (&(globalParams_0->bonds_0)[i_27]);
            float3  d_lin_5;
            float3  d_ang_4;
            static_kinematics_0(i_27, &d_lin_5, &d_ang_4);
            JointBond_0 _S1547 = slang_ldg_0(&_S1546->law_0);
            JointBond_0 _S1548 = _S1547;
            JointState_0 _S1549 = (&(globalParams_0->bond_dyn_0)[i_27])->js_0;
            float3  f_lin_2;
            float3  f_ang_2;
            secant_factors_0(&_S1548, &_S1549, d_lin_5, &f_lin_2, &f_ang_2);
            uint _S1550 = statics_bond_slot_0(i_27);
            float _S1551 = _S1547.stiff0_0.y;
            *(&(globalParams_0->scratch_0)[_S1550]) = make_float4 (_S1551 * f_lin_2.x, _S1551 * f_lin_2.y, _S1547.stiff0_0.x * f_lin_2.z, 0.0f);
            *(&(globalParams_0->scratch_0)[_S1550 + 1U]) = make_float4 (_S1547.stiff0_0.z * f_ang_2.x, _S1547.stiff0_0.w * f_ang_2.y, _S1547.stiff1_0.x * f_ang_2.z, 0.0f);
            uint _S1552 = __ballot_sync(_S1539, true);
            i_27 = i_27 + 256U;
            _S1539 = _S1552;
        }
        __syncthreads();
        uint c_31 = _S1475;
        uint _S1553 = _S1458;
        for(;;)
        {
            bool _S1554 = c_31 < c1_1;
            uint _S1555 = __ballot_sync(_S1553, _S1554);
            if(_S1554)
            {
                uint _S1556 = __ballot_sync(_S1553, true);
            }
            else
            {
                uint _S1557 = __ballot_sync(_S1553, false);
                uint _S1558 = __ballot_sync(_S1553, false);
                uint _S1559 = __ballot_sync(_S1458, true);
                _S1459 = _S1559;
                break;
            }
            assemble_block_0(c_31);
            *(&(globalParams_0->scratch_0)[sv_0(c_31, 2U)]) = _S1507;
            *(&(globalParams_0->scratch_0)[sv_0(c_31, 3U)]) = _S1507;
            uint _S1560 = __ballot_sync(_S1553, true);
            c_31 = c_31 + 256U;
            _S1553 = _S1560;
        }
        __syncthreads();
        uint c_32 = _S1475;
        uint _S1561 = _S1459;
        for(;;)
        {
            bool _S1562 = c_32 < c1_1;
            uint _S1563 = __ballot_sync(_S1561, _S1562);
            if(_S1562)
            {
                uint _S1564 = __ballot_sync(_S1561, true);
            }
            else
            {
                uint _S1565 = __ballot_sync(_S1561, false);
                uint _S1566 = __ballot_sync(_S1561, false);
                uint _S1567 = __ballot_sync(_S1459, true);
                _S1460 = _S1567;
                break;
            }
            precondition_0(c_32);
            uint _S1568 = __ballot_sync(_S1561, true);
            c_32 = c_32 + 256U;
            _S1561 = _S1568;
        }
        __syncthreads();
        uint _S1569 = __ballot_sync(_S1460, free_0);
        uint _S1570;
        if(free_0)
        {
            Island_0 _S1571 = isl_19;
            project_displacement_slot_0(tid_16, &_S1571, 6U, _S1569);
            uint _S1572 = __ballot_sync(_S1460, true);
            _S1570 = _S1572;
        }
        else
        {
            uint _S1573 = __ballot_sync(_S1460, true);
            _S1570 = _S1573;
        }
        uint c_33 = _S1475;
        uint _S1574 = _S1570;
        for(;;)
        {
            bool _S1575 = c_33 < c1_1;
            uint _S1576 = __ballot_sync(_S1574, _S1575);
            if(_S1575)
            {
                uint _S1577 = __ballot_sync(_S1574, true);
            }
            else
            {
                uint _S1578 = __ballot_sync(_S1574, false);
                uint _S1579 = __ballot_sync(_S1574, false);
                uint _S1580 = __ballot_sync(_S1570, true);
                _S1461 = _S1580;
                break;
            }
            *(&(globalParams_0->scratch_0)[sv_0(c_33, 8U)]) = *(&(globalParams_0->scratch_0)[sv_0(c_33, 6U)]);
            *(&(globalParams_0->scratch_0)[sv_0(c_33, 9U)]) = *(&(globalParams_0->scratch_0)[sv_0(c_33, 7U)]);
            uint _S1581 = __ballot_sync(_S1574, true);
            c_33 = c_33 + 256U;
            _S1574 = _S1581;
        }
        __syncthreads();
        float _S1582 = island_dot_0(tid_16, c0_1, c1_1, 4U, 6U, _S1461);
        float _S1583 = island_dot_0(tid_16, c0_1, c1_1, 4U, 4U, _S1461);
        float _S1584 = (F32_sqrt((_S1583)));
        float rz_0 = _S1582;
        uint k_19 = 0U;
        uint cg_total_1 = cg_total_0;
        uint _S1585 = _S1461;
        for(;;)
        {
            bool _S1586 = k_19 < _S1492;
            uint _S1587 = __ballot_sync(_S1585, _S1586);
            uint _S1588;
            bool _S1589;
            if(_S1586)
            {
                bool _S1590 = _S1584 > 0.0f;
                uint _S1591 = __ballot_sync(_S1585, true);
                _S1589 = _S1590;
                _S1588 = _S1591;
            }
            else
            {
                uint _S1592 = __ballot_sync(_S1585, true);
                _S1589 = false;
                _S1588 = _S1592;
            }
            uint _S1593 = 0U;
            uint _S1594 = __ballot_sync(_S1588, _S1589);
            if(_S1589)
            {
                uint _S1595 = __ballot_sync(_S1588, true);
                _S1593 = _S1595;
            }
            else
            {
                uint _S1596 = __ballot_sync(_S1588, false);
                uint _S1597 = __ballot_sync(_S1585, false);
                uint _S1598 = __ballot_sync(_S1461, true);
                cg_total_0 = cg_total_1;
                i_26 = _S1598;
                break;
            }
            i_26 = _S1498;
            _S1462 = _S1593;
            for(;;)
            {
                bool _S1599 = i_26 < _S1474;
                uint _S1600 = __ballot_sync(_S1462, _S1599);
                if(_S1599)
                {
                    uint _S1601 = __ballot_sync(_S1462, true);
                }
                else
                {
                    uint _S1602 = __ballot_sync(_S1462, false);
                    uint _S1603 = __ballot_sync(_S1462, false);
                    uint _S1604 = __ballot_sync(_S1593, true);
                    _S1463 = _S1604;
                    break;
                }
                JointBond_0 _S1605 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_26])->law_0);
                uint ca_2 = _S1605.ids_0.y;
                uint cb_2 = _S1605.ids_0.z;
                float4  _S1606 = *(&(globalParams_0->scratch_0)[sv_0(ca_2, 8U)]);
                float4  _S1607 = *(&(globalParams_0->scratch_0)[sv_0(ca_2, 9U)]);
                float4  _S1608 = *(&(globalParams_0->scratch_0)[sv_0(cb_2, 8U)]);
                float4  _S1609 = *(&(globalParams_0->scratch_0)[sv_0(cb_2, 9U)]);
                float3  d_lin_6;
                float3  d_ang_5;
                bond_kinematics_0(i_26, float3 {_S1606.x, _S1606.y, _S1606.z}, float3 {_S1607.x, _S1607.y, _S1607.z}, float3 {_S1608.x, _S1608.y, _S1608.z}, float3 {_S1609.x, _S1609.y, _S1609.z}, &d_lin_6, &d_ang_5);
                uint _S1610 = statics_bond_slot_0(i_26);
                float4  _S1611 = *(&(globalParams_0->scratch_0)[_S1610]);
                float4  _S1612 = *(&(globalParams_0->scratch_0)[_S1610 + 1U]);
                write_bond_loads_0(i_26, i_26, d_lin_6 * float3 {_S1611.x, _S1611.y, _S1611.z}, d_ang_5 * float3 {_S1612.x, _S1612.y, _S1612.z}, 0.0f);
                uint _S1613 = __ballot_sync(_S1462, true);
                i_26 = i_26 + 256U;
                _S1462 = _S1613;
            }
            __syncthreads();
            c_28 = _S1475;
            uint _S1614 = _S1463;
            for(;;)
            {
                bool _S1615 = c_28 < c1_1;
                uint _S1616 = __ballot_sync(_S1614, _S1615);
                if(_S1615)
                {
                    uint _S1617 = __ballot_sync(_S1614, true);
                }
                else
                {
                    uint _S1618 = __ballot_sync(_S1614, false);
                    uint _S1619 = __ballot_sync(_S1614, false);
                    uint _S1620 = __ballot_sync(_S1463, true);
                    _S1464 = _S1620;
                    break;
                }
                float3  fi_3;
                float3  mi_2;
                gather_loads_0(c_28, &fi_3, &mi_2);
                float4  ap_lin_0 = make_float4 ((- fi_3).x, (- fi_3).y, (- fi_3).z, 0.0f);
                float4  ap_ang_0 = make_float4 ((- mi_2).x, (- mi_2).y, (- mi_2).z, 0.0f);
                hold_0(fixed_mask_0(c_28), &ap_lin_0, &ap_ang_0, *(&(globalParams_0->scratch_0)[sv_0(c_28, 8U)]), *(&(globalParams_0->scratch_0)[sv_0(c_28, 9U)]));
                *(&(globalParams_0->scratch_0)[sv_0(c_28, 10U)]) = ap_lin_0;
                *(&(globalParams_0->scratch_0)[sv_0(c_28, 11U)]) = ap_ang_0;
                uint _S1621 = __ballot_sync(_S1614, true);
                c_28 = c_28 + 256U;
                _S1614 = _S1621;
            }
            uint _S1622 = 0U;
            __syncthreads();
            float _S1623 = island_dot_0(tid_16, c0_1, c1_1, 8U, 10U, _S1464);
            uint _S1624 = cg_total_1 + 1U;
            bool _S1625 = _S1623 <= 0.0f;
            uint _S1626 = __ballot_sync(_S1464, _S1625);
            if(_S1625)
            {
                uint _S1627 = __ballot_sync(_S1464, false);
                uint _S1628 = __ballot_sync(_S1585, false);
                uint _S1629 = __ballot_sync(_S1461, true);
                cg_total_0 = _S1624;
                i_26 = _S1629;
                break;
            }
            else
            {
                uint _S1630 = __ballot_sync(_S1464, true);
                _S1622 = _S1630;
            }
            float _S1631 = rz_0 / _S1623;
            uint c_34 = _S1475;
            uint _S1632;
            _S1632 = _S1622;
            for(;;)
            {
                bool _S1633 = c_34 < c1_1;
                uint _S1634 = __ballot_sync(_S1632, _S1633);
                if(_S1633)
                {
                    uint _S1635 = __ballot_sync(_S1632, true);
                }
                else
                {
                    uint _S1636 = __ballot_sync(_S1632, false);
                    uint _S1637 = __ballot_sync(_S1632, false);
                    uint _S1638 = __ballot_sync(_S1622, true);
                    _S1465 = _S1638;
                    break;
                }
                uint _S1639 = sv_0(c_34, 2U);
                float4  _S1640 = *(&(globalParams_0->scratch_0)[_S1639]);
                float4  _S1641 = *(&(globalParams_0->scratch_0)[sv_0(c_34, 8U)]);
                *(&(globalParams_0->scratch_0)[_S1639]) = make_float4 ((float3 {_S1640.x, _S1640.y, _S1640.z} + make_float3 (_S1631) * float3 {_S1641.x, _S1641.y, _S1641.z}).x, (float3 {_S1640.x, _S1640.y, _S1640.z} + make_float3 (_S1631) * float3 {_S1641.x, _S1641.y, _S1641.z}).y, (float3 {_S1640.x, _S1640.y, _S1640.z} + make_float3 (_S1631) * float3 {_S1641.x, _S1641.y, _S1641.z}).z, 0.0f);
                uint _S1642 = sv_0(c_34, 3U);
                float4  _S1643 = *(&(globalParams_0->scratch_0)[_S1642]);
                float4  _S1644 = *(&(globalParams_0->scratch_0)[sv_0(c_34, 9U)]);
                *(&(globalParams_0->scratch_0)[_S1642]) = make_float4 ((float3 {_S1643.x, _S1643.y, _S1643.z} + make_float3 (_S1631) * float3 {_S1644.x, _S1644.y, _S1644.z}).x, (float3 {_S1643.x, _S1643.y, _S1643.z} + make_float3 (_S1631) * float3 {_S1644.x, _S1644.y, _S1644.z}).y, (float3 {_S1643.x, _S1643.y, _S1643.z} + make_float3 (_S1631) * float3 {_S1644.x, _S1644.y, _S1644.z}).z, 0.0f);
                uint _S1645 = sv_0(c_34, 4U);
                float4  _S1646 = *(&(globalParams_0->scratch_0)[_S1645]);
                float4  _S1647 = *(&(globalParams_0->scratch_0)[sv_0(c_34, 10U)]);
                *(&(globalParams_0->scratch_0)[_S1645]) = make_float4 ((float3 {_S1646.x, _S1646.y, _S1646.z} - make_float3 (_S1631) * float3 {_S1647.x, _S1647.y, _S1647.z}).x, (float3 {_S1646.x, _S1646.y, _S1646.z} - make_float3 (_S1631) * float3 {_S1647.x, _S1647.y, _S1647.z}).y, (float3 {_S1646.x, _S1646.y, _S1646.z} - make_float3 (_S1631) * float3 {_S1647.x, _S1647.y, _S1647.z}).z, 0.0f);
                uint _S1648 = sv_0(c_34, 5U);
                float4  _S1649 = *(&(globalParams_0->scratch_0)[_S1648]);
                float4  _S1650 = *(&(globalParams_0->scratch_0)[sv_0(c_34, 11U)]);
                *(&(globalParams_0->scratch_0)[_S1648]) = make_float4 ((float3 {_S1649.x, _S1649.y, _S1649.z} - make_float3 (_S1631) * float3 {_S1650.x, _S1650.y, _S1650.z}).x, (float3 {_S1649.x, _S1649.y, _S1649.z} - make_float3 (_S1631) * float3 {_S1650.x, _S1650.y, _S1650.z}).y, (float3 {_S1649.x, _S1649.y, _S1649.z} - make_float3 (_S1631) * float3 {_S1650.x, _S1650.y, _S1650.z}).z, 0.0f);
                uint _S1651 = __ballot_sync(_S1632, true);
                c_34 = c_34 + 256U;
                _S1632 = _S1651;
            }
            uint _S1652 = 0U;
            __syncthreads();
            float _S1653 = island_dot_0(tid_16, c0_1, c1_1, 4U, 4U, _S1465);
            bool _S1654 = (F32_sqrt((_S1653))) <= (0.00009999999747379f * _S1584);
            uint _S1655 = __ballot_sync(_S1465, _S1654);
            if(_S1654)
            {
                uint _S1656 = __ballot_sync(_S1465, false);
                uint _S1657 = __ballot_sync(_S1585, false);
                uint _S1658 = __ballot_sync(_S1461, true);
                cg_total_0 = _S1624;
                i_26 = _S1658;
                break;
            }
            else
            {
                uint _S1659 = __ballot_sync(_S1465, true);
                _S1652 = _S1659;
            }
            uint c_35 = _S1475;
            uint _S1660;
            _S1660 = _S1652;
            for(;;)
            {
                bool _S1661 = c_35 < c1_1;
                uint _S1662 = __ballot_sync(_S1660, _S1661);
                if(_S1661)
                {
                    uint _S1663 = __ballot_sync(_S1660, true);
                }
                else
                {
                    uint _S1664 = __ballot_sync(_S1660, false);
                    uint _S1665 = __ballot_sync(_S1660, false);
                    uint _S1666 = __ballot_sync(_S1652, true);
                    _S1466 = _S1666;
                    break;
                }
                precondition_0(c_35);
                uint _S1667 = __ballot_sync(_S1660, true);
                c_35 = c_35 + 256U;
                _S1660 = _S1667;
            }
            __syncthreads();
            uint _S1668 = __ballot_sync(_S1466, free_0);
            uint _S1669;
            if(free_0)
            {
                Island_0 _S1670 = isl_19;
                project_displacement_slot_0(tid_16, &_S1670, 6U, _S1668);
                uint _S1671 = __ballot_sync(_S1466, true);
                _S1669 = _S1671;
            }
            else
            {
                uint _S1672 = __ballot_sync(_S1466, true);
                _S1669 = _S1672;
            }
            float _S1673 = island_dot_0(tid_16, c0_1, c1_1, 4U, 6U, _S1669);
            float _S1674 = _S1673 / rz_0;
            uint c_36 = _S1475;
            uint _S1675 = _S1669;
            for(;;)
            {
                bool _S1676 = c_36 < c1_1;
                uint _S1677 = __ballot_sync(_S1675, _S1676);
                if(_S1676)
                {
                    uint _S1678 = __ballot_sync(_S1675, true);
                }
                else
                {
                    uint _S1679 = __ballot_sync(_S1675, false);
                    uint _S1680 = __ballot_sync(_S1675, false);
                    uint _S1681 = __ballot_sync(_S1669, true);
                    break;
                }
                uint _S1682 = sv_0(c_36, 8U);
                float4  _S1683 = *(&(globalParams_0->scratch_0)[sv_0(c_36, 6U)]);
                float4  _S1684 = *(&(globalParams_0->scratch_0)[_S1682]);
                *(&(globalParams_0->scratch_0)[_S1682]) = make_float4 ((float3 {_S1683.x, _S1683.y, _S1683.z} + make_float3 (_S1674) * float3 {_S1684.x, _S1684.y, _S1684.z}).x, (float3 {_S1683.x, _S1683.y, _S1683.z} + make_float3 (_S1674) * float3 {_S1684.x, _S1684.y, _S1684.z}).y, (float3 {_S1683.x, _S1683.y, _S1683.z} + make_float3 (_S1674) * float3 {_S1684.x, _S1684.y, _S1684.z}).z, 0.0f);
                uint _S1685 = sv_0(c_36, 9U);
                float4  _S1686 = *(&(globalParams_0->scratch_0)[sv_0(c_36, 7U)]);
                float4  _S1687 = *(&(globalParams_0->scratch_0)[_S1685]);
                *(&(globalParams_0->scratch_0)[_S1685]) = make_float4 ((float3 {_S1686.x, _S1686.y, _S1686.z} + make_float3 (_S1674) * float3 {_S1687.x, _S1687.y, _S1687.z}).x, (float3 {_S1686.x, _S1686.y, _S1686.z} + make_float3 (_S1674) * float3 {_S1687.x, _S1687.y, _S1687.z}).y, (float3 {_S1686.x, _S1686.y, _S1686.z} + make_float3 (_S1674) * float3 {_S1687.x, _S1687.y, _S1687.z}).z, 0.0f);
                uint _S1688 = __ballot_sync(_S1675, true);
                c_36 = c_36 + 256U;
                _S1675 = _S1688;
            }
            __syncthreads();
            uint _S1689 = __ballot_sync(_S1585, true);
            uint _S1690 = k_19 + 1U;
            rz_0 = _S1673;
            k_19 = _S1690;
            cg_total_1 = _S1624;
            _S1585 = _S1689;
        }
        c_28 = _S1475;
        _S1462 = i_26;
        for(;;)
        {
            bool _S1691 = c_28 < c1_1;
            uint _S1692 = __ballot_sync(_S1462, _S1691);
            if(_S1691)
            {
                uint _S1693 = __ballot_sync(_S1462, true);
            }
            else
            {
                uint _S1694 = __ballot_sync(_S1462, false);
                uint _S1695 = __ballot_sync(_S1462, false);
                uint _S1696 = __ballot_sync(i_26, true);
                break;
            }
            uint _S1697 = 4U * c_28;
            float4  _S1698 = *(&(globalParams_0->state_0)[_S1697]);
            float3  u_1 = float3 {_S1698.x, _S1698.y, _S1698.z};
            uint _S1699 = sv_0(c_28, 21U);
            float4  _S1700 = *(&(globalParams_0->scratch_0)[_S1699]);
            float3  u_lo_0 = float3 {_S1700.x, _S1700.y, _S1700.z};
            uint _S1701 = _S1697 + 1U;
            float4  _S1702 = *(&(globalParams_0->state_0)[_S1701]);
            float3  th_3 = float3 {_S1702.x, _S1702.y, _S1702.z};
            uint _S1703 = sv_0(c_28, 22U);
            float4  _S1704 = *(&(globalParams_0->scratch_0)[_S1703]);
            float3  th_lo_0 = float3 {_S1704.x, _S1704.y, _S1704.z};
            float4  _S1705 = *(&(globalParams_0->scratch_0)[sv_0(c_28, 2U)]);
            comp_add_0(&u_1, &u_lo_0, float3 {_S1705.x, _S1705.y, _S1705.z});
            float4  _S1706 = *(&(globalParams_0->scratch_0)[sv_0(c_28, 3U)]);
            comp_add_0(&th_3, &th_lo_0, float3 {_S1706.x, _S1706.y, _S1706.z});
            *(&(globalParams_0->state_0)[_S1697]) = make_float4 (u_1.x, u_1.y, u_1.z, (*(&(globalParams_0->state_0)[_S1697])).w);
            *(&(globalParams_0->state_0)[_S1701]) = make_float4 (th_3.x, th_3.y, th_3.z, (*(&(globalParams_0->state_0)[_S1701])).w);
            *(&(globalParams_0->scratch_0)[_S1699]) = make_float4 (u_lo_0.x, u_lo_0.y, u_lo_0.z, 0.0f);
            *(&(globalParams_0->scratch_0)[_S1703]) = make_float4 (th_lo_0.x, th_lo_0.y, th_lo_0.z, 0.0f);
            uint _S1707 = __ballot_sync(_S1462, true);
            c_28 = c_28 + 256U;
            _S1462 = _S1707;
        }
        __syncthreads();
        uint _S1708 = newton_0 + 1U;
        uint _S1709 = __ballot_sync(c_29, true);
        previous_2 = residual_1;
        residual_0 = residual_1;
        newton_0 = _S1708;
        c_29 = _S1709;
    }
    i_25 = b0_0 + tid_16;
    for(;;)
    {
        if(i_25 < _S1474)
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
    c_28 = _S1475;
    for(;;)
    {
        if(c_28 < c1_1)
        {
        }
        else
        {
            break;
        }
        float3  fi_4;
        float3  mi_3;
        gather_loads_0(c_28, &fi_4, &mi_3);
        float3  reaction_0;
        if((fixed_mask_0(c_28)) != 0U)
        {
            float4  _S1710 = *(&(globalParams_0->scratch_0)[sv_0(c_28, 0U)]);
            reaction_0 = - (float3 {_S1710.x, _S1710.y, _S1710.z} + fi_4);
        }
        else
        {
            uint _S1711 = 4U * c_28;
            reaction_0 = make_float3 ((*(&(globalParams_0->state_0)[_S1711 + 1U])).w, (*(&(globalParams_0->state_0)[_S1711 + 2U])).w, (*(&(globalParams_0->state_0)[_S1711 + 3U])).w);
        }
        uint _S1712 = 4U * c_28;
        uint _S1713 = _S1712 + 1U;
        float4  _S1714 = *(&(globalParams_0->state_0)[_S1713]);
        *(&(globalParams_0->state_0)[_S1713]) = make_float4 (float3 {_S1714.x, _S1714.y, _S1714.z}.x, float3 {_S1714.x, _S1714.y, _S1714.z}.y, float3 {_S1714.x, _S1714.y, _S1714.z}.z, reaction_0.x);
        *(&(globalParams_0->state_0)[_S1712 + 2U]) = make_float4 (0.0f, 0.0f, 0.0f, reaction_0.y);
        *(&(globalParams_0->state_0)[_S1712 + 3U]) = make_float4 (0.0f, 0.0f, 0.0f, reaction_0.z);
        c_28 = c_28 + 256U;
    }
    if(tid_16 == 0U)
    {
        float4  * _S1715 = (&(globalParams_0->scratch_0)[statics_result_slot_0(_S1468)]);
        float _S1716 = (U32_asfloat((newton_0)));
        float _S1717 = (U32_asfloat((cg_total_0)));
        if(converged_2)
        {
            previous_2 = 1.0f;
        }
        else
        {
            previous_2 = 0.0f;
        }
        *_S1715 = make_float4 (residual_0, _S1716, _S1717, previous_2);
        *&((&(&(globalParams_0->islands_0)[_S1468])->info_1)->z) = _S1470 & 4294967287U;
    }
    return;
}

__device__ __shared__ uint g_halt_0;

__device__ __shared__ uint g_run_0;

extern "C" __global__ void settled_fatigue()
{
    uint tid_17 = threadIdx.x;
    uint _S1718 = blockIdx.x;
    Island_0 * _S1719 = (&(globalParams_0->islands_0)[_S1718]);
    Island_0 isl_20 = *_S1719;
    bool _S1720;
    if((((*_S1719).info_1.x) & 16U) == 0U)
    {
        _S1720 = true;
    }
    else
    {
        _S1720 = (isl_20.range_0.w) == (isl_20.range_0.z);
    }
    if(_S1720)
    {
        return;
    }
    seen_clear_0(tid_17);
    if(tid_17 == 0U)
    {
        *&g_halt_0 = 0U;
        *&g_run_0 = 0U;
    }
    __syncthreads();
    uint _S1721 = isl_20.info_1.w;
    uint i_28 = isl_20.range_0.z + tid_17;
    for(;;)
    {
        if(i_28 < (isl_20.range_0.w))
        {
        }
        else
        {
            break;
        }
        BondStatic_0 * _S1722 = (&(globalParams_0->bonds_0)[i_28]);
        BondDyn_0 bd_2 = *(&(globalParams_0->bond_dyn_0)[i_28]);
        JointBond_0 _S1723 = slang_ldg_0(&_S1722->law_0);
        uint _S1724 = 4U * _S1723.ids_0.y;
        float4  _S1725 = *(&(globalParams_0->state_0)[_S1724]);
        float4  _S1726 = *(&(globalParams_0->state_0)[_S1724 + 1U]);
        uint _S1727 = 4U * _S1723.ids_0.z;
        float4  _S1728 = *(&(globalParams_0->state_0)[_S1727]);
        float4  _S1729 = *(&(globalParams_0->state_0)[_S1727 + 1U]);
        float3  d_lin_7;
        float3  d_ang_6;
        bond_kinematics_0(i_28, float3 {_S1725.x, _S1725.y, _S1725.z}, float3 {_S1726.x, _S1726.y, _S1726.z}, float3 {_S1728.x, _S1728.y, _S1728.z}, float3 {_S1729.x, _S1729.y, _S1729.z}, &d_lin_7, &d_ang_6);
        JointState_0 previous_3 = (&bd_2)->js_0;
        float3  _S1730 = d_lin_7;
        float3  _S1731 = d_ang_6;
        float _S1732 = __ldg(&globalParams_0->params_0->dt_0);
        uint _S1733 = __ldg(&globalParams_0->params_0->fracture_0);
        bool _S1734 = _S1733 != 0U;
        JointBond_0 _S1735 = _S1723;
        JointState_0 _S1736 = previous_3;
        JointResponse_0 _S1737 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S1723.ids_0.x], &_S1735, &_S1736, _S1730, _S1731, _S1732, _S1734);
        if((_S1737.state_1.damage_0) > (previous_3.damage_0 + 9.99999971718068537e-10f))
        {
            _S1720 = true;
        }
        else
        {
            _S1720 = (_S1737.state_1.crush_0) > (previous_3.crush_0 + 9.99999971718068537e-10f);
        }
        uint flags_3;
        if(_S1720)
        {
            flags_3 = 16U;
        }
        else
        {
            flags_3 = 0U;
        }
        comp_add1_0(&((&(&bd_2)->sums_0)->x), &((&(&bd_2)->comps_0)->x), _S1737.dissipated_2);
        comp_add1_0(&((&(&bd_2)->sums_0)->y), &((&(&bd_2)->comps_0)->y), _S1737.overshoot_0);
        (&bd_2)->force_lin_0 = make_float4 (_S1737.force_lin_1.x, _S1737.force_lin_1.y, _S1737.force_lin_1.z, _S1737.stored_3);
        (&bd_2)->force_ang_0 = make_float4 (_S1737.force_ang_1.x, _S1737.force_ang_1.y, _S1737.force_ang_1.z, (F32_max(((&bd_2)->force_ang_0.w), (_S1737.state_1.utilization_0))));
        JointState_0 _S1738 = previous_3;
        bool _S1739 = is_damaged_0(&_S1738);
        bool _S1740;
        if(!_S1739)
        {
            JointState_0 _S1741 = _S1737.state_1;
            bool _S1742 = is_damaged_0(&_S1741);
            _S1740 = _S1742;
        }
        else
        {
            _S1740 = false;
        }
        bool _S1743;
        if(_S1740)
        {
            _S1743 = ((&bd_2)->events_0.x) == 0U;
        }
        else
        {
            _S1743 = false;
        }
        if(_S1743)
        {
            *&((&(&bd_2)->events_0)->x) = _S1721;
            *&((&(&bd_2)->events_0)->w) = _S1737.state_1.mode_0;
            (*&g_seen_0)[3U] = 1U;
        }
        bool _S1744;
        if(((&bd_2)->events_0.y) == 0U)
        {
            _S1744 = (_S1737.state_1.life_0) != (previous_3.life_0);
        }
        else
        {
            _S1744 = false;
        }
        bool _S1745;
        if(_S1744)
        {
            _S1745 = (_S1737.fatigue_before_0) > 0.99000000953674316f;
        }
        else
        {
            _S1745 = false;
        }
        bool _S1746;
        if(_S1745)
        {
            float _S1747 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S1723.ids_0.x], _S1737.state_1.life_0);
            _S1746 = _S1747 <= 0.99000000953674316f;
        }
        else
        {
            _S1746 = false;
        }
        if(_S1746)
        {
            *&((&(&bd_2)->events_0)->y) = _S1721;
            (*&g_seen_0)[4U] = 1U;
        }
        uint flags_4;
        if(_S1737.disconnected_0)
        {
            *&((&(&bd_2)->events_0)->z) = _S1721;
            flags_4 = flags_3 | 32U;
        }
        else
        {
            flags_4 = flags_3;
        }
        (&bd_2)->js_0 = _S1737.state_1;
        *(&(globalParams_0->bond_dyn_0)[i_28]) = bd_2;
        write_bond_loads_0(i_28, i_28, _S1737.force_lin_1, _S1737.force_ang_1, (F32_max((_S1737.measures_0.tension_0), (_S1737.measures_0.compression_0))));
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
    if(tid_17 != 0U)
    {
        return;
    }
    if(((*&g_halt_0) | (*&g_run_0)) != 0U)
    {
        uint _S1748 = isl_20.info_1.z;
        if((*&g_halt_0) != 0U)
        {
            i_28 = 16U;
        }
        else
        {
            i_28 = 0U;
        }
        uint _S1749 = _S1748 | i_28;
        if((*&g_run_0) != 0U)
        {
            i_28 = 32U;
        }
        else
        {
            i_28 = 0U;
        }
        *&((&(&(globalParams_0->islands_0)[_S1718])->info_1)->z) = _S1749 | i_28;
    }
    uint _S1750 = ((isl_20.coverage_0) | 16384U) | (seen_bits_0());
    if((*&g_run_0) != 0U)
    {
        i_28 = 128U;
    }
    else
    {
        i_28 = 0U;
    }
    (&(globalParams_0->islands_0)[_S1718])->coverage_0 = _S1750 | i_28;
    return;
}

static __device__ void impactor_integrate_at_0(uint ii_2, uint tid_18, uint _S1751)
{
    uint _S1752 = 0U;
    uint _S1753;
    float3  p_16;
    uint _S1754 = __ldg(&globalParams_0->params_0->impactor_count_0);
    bool _S1755 = ii_2 >= _S1754;
    uint _S1756 = __ballot_sync(_S1751, _S1755);
    if(_S1755)
    {
        return;
    }
    else
    {
        uint _S1757 = __ballot_sync(_S1751, true);
        _S1752 = _S1757;
    }
    uint _S1758 = __ldg(&globalParams_0->params_0->halt_index_0);
    Island_0 * _S1759 = (&(globalParams_0->islands_0)[_S1758]);
    Impactor_0 imp_6 = *(&(globalParams_0->impactors_0)[ii_2]);
    uint4  _S1760 = _S1759->info_1;
    bool _S1761 = ((_S1759->info_1.z) & 1U) != 0U;
    uint _S1762 = __ballot_sync(_S1752, _S1761);
    bool _S1763;
    uint k_20;
    if(_S1761)
    {
        uint _S1764 = __ballot_sync(_S1752, true);
        _S1763 = true;
        k_20 = _S1764;
    }
    else
    {
        uint _S1765 = _S1752 & (~_S1762);
        uint _S1766 = _S1760.y;
        bool _S1767 = _S1766 != 0U;
        uint _S1768 = __ballot_sync(_S1765, _S1767);
        if(_S1767)
        {
            bool _S1769 = ((&imp_6)->cand_0.w) >= _S1766;
            uint _S1770 = __ballot_sync(_S1765, true);
            _S1763 = _S1769;
        }
        else
        {
            uint _S1771 = __ballot_sync(_S1765, true);
            _S1763 = false;
        }
        uint _S1772 = __ballot_sync(_S1752, true);
        k_20 = _S1772;
    }
    uint _S1773 = 0U;
    uint _S1774 = __ballot_sync(k_20, _S1763);
    if(_S1763)
    {
        return;
    }
    else
    {
        uint _S1775 = __ballot_sync(k_20, true);
        _S1773 = _S1775;
    }
    uint _S1776 = 0U;
    bool _S1777 = ((&imp_6)->cand_0.z) != 0U;
    uint _S1778 = __ballot_sync(_S1773, _S1777);
    if(_S1777)
    {
        if(tid_18 == 0U)
        {
            *&((&(&(globalParams_0->impactors_0)[ii_2])->cand_0)->w) = (&imp_6)->cand_0.w + 1U;
        }
        return;
    }
    else
    {
        uint _S1779 = __ballot_sync(_S1773, true);
        _S1776 = _S1779;
    }
    float4  _S1780 = make_float4 (0.0f);
    float4  rf_1 = _S1780;
    float4  rt_0 = _S1780;
    k_20 = (&imp_6)->cand_0.x + tid_18;
    uint total_points_0;
    total_points_0 = _S1776;
    for(;;)
    {
        bool _S1781 = k_20 < ((&imp_6)->cand_0.y);
        uint _S1782 = __ballot_sync(total_points_0, _S1781);
        if(_S1781)
        {
            uint _S1783 = __ballot_sync(total_points_0, true);
        }
        else
        {
            uint _S1784 = __ballot_sync(total_points_0, false);
            uint _S1785 = __ballot_sync(total_points_0, false);
            uint _S1786 = __ballot_sync(_S1776, true);
            _S1753 = _S1786;
            break;
        }
        uint _S1787 = __ldg(&globalParams_0->params_0->cand_base_0);
        uint _S1788 = 3U * k_20;
        rf_1 = rf_1 + *(&(globalParams_0->scratch_0)[_S1787 + _S1788 + 1U]);
        uint _S1789 = __ldg(&globalParams_0->params_0->cand_base_0);
        rt_0 = rt_0 + *(&(globalParams_0->scratch_0)[_S1789 + _S1788 + 2U]);
        uint _S1790 = __ballot_sync(total_points_0, true);
        k_20 = k_20 + 256U;
        total_points_0 = _S1790;
    }
    group_sum2_0(tid_18, &rf_1, &rt_0, _S1753);
    bool _S1791 = tid_18 != 0U;
    uint _S1792 = __ballot_sync(_S1753, _S1791);
    if(_S1791)
    {
        return;
    }
    float _S1793 = __ldg(&globalParams_0->params_0->dt_0);
    float3  _S1794 = make_float3 (0.0f);
    uint _S1795 = __ldg(&globalParams_0->params_0->has_ground_0);
    float3  load_f_0;
    float3  load_t_0;
    if(_S1795 != 0U)
    {
        float4  _S1796 = (&imp_6)->half_1;
        float3  _S1797 = float3 {_S1796.x, _S1796.y, _S1796.z};
        Impactor_0 _S1798 = imp_6;
        Box_0 _S1799 = impactor_box_0(&_S1798, _S1794, _S1797);
        float4  _S1800 = (&imp_6)->velocity_1;
        float4  _S1801 = (&imp_6)->velocity_err_1;
        float3  _S1802 = float3 {_S1800.x, _S1800.y, _S1800.z} + float3 {_S1801.x, _S1801.y, _S1801.z};
        float _S1803 = __ldg(&globalParams_0->params_0->ground_modulus_0);
        float _S1804 = (&imp_6)->mat_0.x;
        float3  _S1805 = make_float3 (0.0f, 0.0f, 1.0f);
        Box_0 _S1806 = _S1799;
        Box_0 _S1807 = _S1799;
        float _S1808 = contact_stiffness_0(_S1803, &_S1806, _S1804, &_S1807, _S1805);
        float _S1809 = (&imp_6)->position_1.z;
        float _S1810 = __ldg(&globalParams_0->params_0->ground_hi_0);
        float _S1811 = _S1809 - _S1810;
        float _S1812 = (&imp_6)->position_err_1.z;
        float _S1813 = __ldg(&globalParams_0->params_0->ground_lo_0);
        float _S1814 = _S1811 + (_S1812 - _S1813);
        if(((&imp_6)->shape_0.x) == 0.0f)
        {
            total_points_0 = 1U;
        }
        else
        {
            total_points_0 = 14U;
        }
        float _S1815 = _S1808 / float((U32_min((total_points_0), (5U))));
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
                p_16 = make_float3 (0.0f, 0.0f, - (&imp_6)->shape_0.y);
            }
            else
            {
                Box_0 _S1816 = _S1799;
                float3  _S1817 = sample_point_0(&_S1816, s_11);
                p_16 = _S1817;
            }
            if((_S1814 + p_16.z) < 0.0f)
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
        load_f_0 = _S1794;
        load_t_0 = _S1794;
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
                p_16 = make_float3 (0.0f, 0.0f, - (&imp_6)->shape_0.y);
            }
            else
            {
                Box_0 _S1818 = _S1799;
                float3  _S1819 = sample_point_0(&_S1818, s_11);
                p_16 = _S1819;
            }
            float depth_3 = - (_S1814 + p_16.z);
            if(depth_3 <= 0.0f)
            {
                s_11 = s_11 + 1U;
                continue;
            }
            float4  _S1820 = (&imp_6)->angular_velocity_1;
            float3  v_9 = _S1802 + cross_0(float3 {_S1820.x, _S1820.y, _S1820.z}, p_16);
            float _S1821 = (&imp_6)->mat_0.z;
            float _S1822 = __ldg(&globalParams_0->params_0->ground_friction_0);
            float stored_7;
            float diss_5;
            float3  f_14 = penalty_force_0(_S1815, _S1821, _S1822, depth_3, _S1805, v_9, _S1793, below_0, &stored_7, &diss_5);
            float3  load_f_1 = load_f_0 + f_14;
            float3  load_t_1 = load_t_0 + cross_0(p_16, f_14);
            comp_add1_0(&((&(&imp_6)->ledger_0)->x), &((&(&imp_6)->ledger_0)->y), diss_5);
            load_f_0 = load_f_1;
            load_t_0 = load_t_1;
            s_11 = s_11 + 1U;
        }
    }
    else
    {
        load_f_0 = _S1794;
        load_t_0 = _S1794;
    }
    float4  _S1823 = rf_1;
    float3  load_f_2 = float3 {_S1823.x, _S1823.y, _S1823.z} + load_f_0;
    float4  _S1824 = rt_0;
    float3  load_t_2 = float3 {_S1824.x, _S1824.y, _S1824.z} + load_t_0;
    float m_6 = (&imp_6)->mat_0.z;
    float4  _S1825 = (&imp_6)->velocity_1;
    float3  vel_2 = float3 {_S1825.x, _S1825.y, _S1825.z};
    float4  _S1826 = (&imp_6)->velocity_err_1;
    float3  vel_err_1 = float3 {_S1826.x, _S1826.y, _S1826.z};
    float3  _S1827 = load_f_2 / make_float3 (m_6);
    float4  _S1828 = __ldg(&globalParams_0->params_0->gravity_0);
    comp_add_0(&vel_2, &vel_err_1, (_S1827 + float3 {_S1828.x, _S1828.y, _S1828.z}) * make_float3 (_S1793));
    Quat_0 _S1829 = quat_of_0((&imp_6)->rotation_1);
    Quat_0 q_13 = _S1829;
    float4  q_err_0 = (&imp_6)->rotation_err_1;
    float4  _S1830 = (&imp_6)->momentum_1;
    float3  l_hi_0 = float3 {_S1830.x, _S1830.y, _S1830.z};
    float4  _S1831 = (&imp_6)->momentum_err_1;
    float3  l_err_1 = float3 {_S1831.x, _S1831.y, _S1831.z};
    comp_add_0(&l_hi_0, &l_err_1, load_t_2 * make_float3 (_S1793));
    float3  l_6 = l_hi_0 + l_err_1;
    Quat_0 _S1832 = _S1829;
    float3  _S1833 = world_mul_0(&_S1832, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_6);
    float4  _S1834 = (&imp_6)->position_1;
    float3  pos_1 = float3 {_S1834.x, _S1834.y, _S1834.z};
    float4  _S1835 = (&imp_6)->position_err_1;
    float3  pos_err_1 = float3 {_S1835.x, _S1835.y, _S1835.z};
    comp_add_0(&pos_1, &pos_err_1, (vel_2 + vel_err_1) * make_float3 (_S1793));
    turn_left_0(&q_13, &q_err_0, _S1833, _S1793);
    Quat_0 _S1836 = q_13;
    float3  _S1837 = world_mul_0(&_S1836, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_6);
    (&imp_6)->angular_velocity_1 = make_float4 (_S1837.x, _S1837.y, _S1837.z, 0.0f);
    Quat_0 _S1838 = q_13;
    float4  _S1839 = quat_vec_0(&_S1838);
    (&imp_6)->rotation_1 = _S1839;
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
    uint _S1840 = (&imp_6)->cand_0.w - 1U;
    uint _S1841 = __ldg(&globalParams_0->params_0->step_start_0);
    uint k_21 = _S1840 - _S1841;
    uint _S1842 = __ldg(&globalParams_0->params_0->record_stride_0);
    if(k_21 < _S1842)
    {
        uint _S1843 = __ldg(&globalParams_0->params_0->record_base_0);
        uint _S1844 = __ldg(&globalParams_0->params_0->record_stride_0);
        uint at_6 = _S1843 + 2U * (ii_2 * _S1844 + k_21);
        *(&(globalParams_0->scratch_0)[at_6]) = make_float4 ((vel_2 + vel_err_1).x, (vel_2 + vel_err_1).y, (vel_2 + vel_err_1).z, 0.0f);
        *(&(globalParams_0->scratch_0)[at_6 + 1U]) = make_float4 ((pos_1 + pos_err_1).x, (pos_1 + pos_err_1).y, (pos_1 + pos_err_1).z, 0.0f);
    }
    return;
}

extern "C" __global__ void impactor_integrate()
{
    uint _S1845 = __ballot_sync(4294967295U, true);
    impactor_integrate_at_0(blockIdx.x, threadIdx.x, _S1845);
    return;
}

static __device__ void ground_contact_0(uint c_37, bool account_0, float3  * f_15, float3  * t_14)
{
    ChunkStatic_0 * _S1846 = (&(globalParams_0->chunks_0)[c_37]);
    WorldPoint_0 wp_1 = chunk_world_0(c_37);
    float _S1847 = wp_1.hi_0.z;
    float _S1848 = __ldg(&globalParams_0->params_0->ground_hi_0);
    float _S1849 = _S1847 - _S1848;
    float _S1850 = wp_1.lo_0.z;
    float _S1851 = __ldg(&globalParams_0->params_0->ground_lo_0);
    float above_0 = _S1849 + (_S1850 - _S1851) + wp_1.rel_0.z;
    float4  _S1852 = __ldg(&_S1846->half_0);
    if((above_0 - _S1852.w) > 0.0f)
    {
        return;
    }
    Box_0 b_31 = chunk_box_0(c_37, make_float3 (0.0f));
    float _S1853 = __ldg(&globalParams_0->params_0->ground_modulus_0);
    float4  _S1854 = __ldg(&_S1846->cmat_0);
    float _S1855 = _S1854.x;
    float3  _S1856 = make_float3 (0.0f, 0.0f, 1.0f);
    Box_0 _S1857 = b_31;
    Box_0 _S1858 = b_31;
    float _S1859 = contact_stiffness_0(_S1853, &_S1857, _S1855, &_S1858, _S1856);
    Box_0 _S1860 = b_31;
    uint _S1861 = sample_count_0(&_S1860);
    uint s_12 = 0U;
    uint n_9 = 0U;
    for(;;)
    {
        if(s_12 < _S1861)
        {
        }
        else
        {
            break;
        }
        Box_0 _S1862 = b_31;
        float3  _S1863 = sample_point_0(&_S1862, s_12);
        if((above_0 + _S1863.z) < 0.0f)
        {
            n_9 = n_9 + 1U;
        }
        s_12 = s_12 + 1U;
    }
    if(n_9 == 0U)
    {
        return;
    }
    sentinel_mark_0(4U);
    float3  vc_1;
    float3  wc_1;
    chunk_velocity_0(c_37, &vc_1, &wc_1);
    uint _S1864 = __ldg(&globalParams_0->params_0->ledger_base_0);
    uint _S1865 = __ldg(&globalParams_0->params_0->pair_count_0);
    float4  ledger_2 = *(&(globalParams_0->scratch_0)[_S1864 + _S1865 + c_37]);
    s_12 = 0U;
    for(;;)
    {
        if(s_12 < _S1861)
        {
        }
        else
        {
            break;
        }
        Box_0 _S1866 = b_31;
        float3  _S1867 = sample_point_0(&_S1866, s_12);
        float _S1868 = above_0 + _S1867.z;
        if(!(_S1868 < 0.0f))
        {
            s_12 = s_12 + 1U;
            continue;
        }
        float depth_4 = - _S1868;
        float3  v_10 = vc_1 + cross_0(wc_1, _S1867);
        float _S1869 = _S1859 / float((U32_max((n_9), (5U))));
        float4  _S1870 = __ldg(&_S1846->center_0);
        float _S1871 = _S1870.w;
        float _S1872 = __ldg(&globalParams_0->params_0->ground_friction_0);
        float _S1873 = __ldg(&globalParams_0->params_0->dt_0);
        float stored_8;
        float diss_6;
        float3  g_2 = penalty_force_0(_S1869, _S1871, _S1872, depth_4, _S1856, v_10, _S1873, n_9, &stored_8, &diss_6);
        *f_15 = *f_15 + g_2;
        *t_14 = *t_14 + cross_0(_S1867, g_2);
        comp_add1_0(&((&ledger_2)->y), &((&ledger_2)->z), diss_6);
        s_12 = s_12 + 1U;
    }
    if(account_0)
    {
        uint _S1874 = __ldg(&globalParams_0->params_0->ledger_base_0);
        uint _S1875 = __ldg(&globalParams_0->params_0->pair_count_0);
        *(&(globalParams_0->scratch_0)[_S1874 + _S1875 + c_37]) = ledger_2;
    }
    return;
}

static __device__ void contact_sum_at_0(uint g_3)
{
    uint _S1876 = __ldg(&globalParams_0->params_0->seg_count_0);
    bool _S1877;
    if(g_3 >= _S1876)
    {
        _S1877 = true;
    }
    else
    {
        _S1877 = stopped_0();
    }
    if(_S1877)
    {
        return;
    }
    uint _S1878 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S1879 = 3U * g_3;
    uint _S1880 = __ldg((&(globalParams_0->index_0)[_S1878 + _S1879]));
    uint _S1881 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S1882 = __ldg((&(globalParams_0->index_0)[_S1881 + _S1879 + 1U]));
    uint _S1883 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S1884 = __ldg((&(globalParams_0->index_0)[_S1883 + _S1879 + 2U]));
    float3  _S1885 = make_float3 (0.0f);
    float3  f_16 = _S1885;
    float3  t_15 = _S1885;
    uint e_6 = _S1882;
    for(;;)
    {
        if(e_6 < _S1884)
        {
        }
        else
        {
            break;
        }
        uint _S1886 = __ldg((&(globalParams_0->index_0)[e_6]));
        if(_S1886 == 2147483648U)
        {
            ground_contact_0(_S1880, true, &f_16, &t_15);
            e_6 = e_6 + 1U;
            continue;
        }
        uint _S1887 = __ldg(&globalParams_0->params_0->slot_base_0);
        uint _S1888 = 2U * _S1886;
        float4  _S1889 = *(&(globalParams_0->scratch_0)[_S1887 + _S1888]);
        f_16 = f_16 + float3 {_S1889.x, _S1889.y, _S1889.z};
        uint _S1890 = __ldg(&globalParams_0->params_0->slot_base_0);
        float4  _S1891 = *(&(globalParams_0->scratch_0)[_S1890 + _S1888 + 1U]);
        t_15 = t_15 + float3 {_S1891.x, _S1891.y, _S1891.z};
        e_6 = e_6 + 1U;
    }
    uint _S1892 = __ldg(&globalParams_0->params_0->seg_base_0);
    uint _S1893 = 2U * g_3;
    *(&(globalParams_0->scratch_0)[_S1892 + _S1893]) = make_float4 (f_16.x, f_16.y, f_16.z, 0.0f);
    uint _S1894 = __ldg(&globalParams_0->params_0->seg_base_0);
    *(&(globalParams_0->scratch_0)[_S1894 + _S1893 + 1U]) = make_float4 (t_15.x, t_15.y, t_15.z, 0.0f);
    return;
}

extern "C" __global__ void contact_sums()
{
    contact_sum_at_0((blockIdx * blockDim + threadIdx).x);
    return;
}

static __device__ void chunk_update_0(uint c_38, Island_0 * isl_21, Rigid_0 * rg_8, float dt_11, bool rml_0, uint step_0, bool contact_3, float * work_2, float * work_err_0)
{
    ChunkStatic_0 * _S1895 = (&(globalParams_0->chunks_0)[c_38]);
    float3  _S1896 = make_float3 (0.0f);
    uint _S1897 = __ldg((&(globalParams_0->index_0)[c_38]));
    float peak_0 = 0.0f;
    uint e_7 = _S1897;
    float3  fi_5 = _S1896;
    float3  mi_4 = _S1896;
    for(;;)
    {
        uint _S1898 = __ldg((&(globalParams_0->index_0)[c_38 + 1U]));
        if(e_7 < _S1898)
        {
        }
        else
        {
            break;
        }
        uint _S1899 = __ldg((&(globalParams_0->index_0)[e_7]));
        uint _S1900 = 3U * (_S1899 >> int(1));
        float4  fa_2 = *(&(globalParams_0->scratch_0)[_S1900]);
        if((_S1899 & 1U) == 0U)
        {
            float4  _S1901 = *(&(globalParams_0->scratch_0)[_S1900 + 1U]);
            float3  mi_5 = mi_4 + float3 {_S1901.x, _S1901.y, _S1901.z};
            fi_5 = fi_5 + float3 {fa_2.x, fa_2.y, fa_2.z};
            mi_4 = mi_5;
        }
        else
        {
            float4  _S1902 = *(&(globalParams_0->scratch_0)[_S1900 + 2U]);
            float3  mi_6 = mi_4 + float3 {_S1902.x, _S1902.y, _S1902.z};
            fi_5 = fi_5 + - float3 {fa_2.x, fa_2.y, fa_2.z};
            mi_4 = mi_6;
        }
        float _S1903 = (F32_max((peak_0), (fa_2.w)));
        uint _S1904 = e_7 + 1U;
        peak_0 = _S1903;
        e_7 = _S1904;
    }
    uint _S1905 = 4U * c_38;
    float4  _S1906 = *(&(globalParams_0->state_0)[_S1905]);
    float3  u_2 = float3 {_S1906.x, _S1906.y, _S1906.z};
    uint _S1907 = _S1905 + 1U;
    float4  _S1908 = *(&(globalParams_0->state_0)[_S1907]);
    float3  th_4 = float3 {_S1908.x, _S1908.y, _S1908.z};
    uint _S1909 = _S1905 + 2U;
    float4  _S1910 = *(&(globalParams_0->state_0)[_S1909]);
    float3  v_11 = float3 {_S1910.x, _S1910.y, _S1910.z};
    uint _S1911 = _S1905 + 3U;
    float4  _S1912 = *(&(globalParams_0->state_0)[_S1911]);
    float3  w_6 = float3 {_S1912.x, _S1912.y, _S1912.z};
    float4  _S1913 = __ldg(&_S1895->center_0);
    float mass_0 = _S1913.w;
    float3  _S1914 = float3 {_S1913.x, _S1913.y, _S1913.z};
    float4  _S1915 = isl_21->com_0;
    float3  _S1916 = float3 {_S1915.x, _S1915.y, _S1915.z};
    float3  _S1917 = rotate_0(&rg_8->rot_1, _S1914 + u_2 - _S1916);
    float3  f_load_0;
    float3  t_load_0;
    float3  rep_f_1;
    float3  rep_m_1;
    chunk_loads_0(c_38, c_38, &rg_8->rot_1, step_0, dt_11, contact_3, dt_11, &f_load_0, &t_load_0, &rep_f_1, &rep_m_1);
    record_chunk_load_0(c_38, f_load_0, t_load_0);
    float3  _S1918 = f_load_0;
    float4  _S1919 = __ldg(&globalParams_0->params_0->gravity_0);
    float3  f_world_0 = _S1918 + float3 {_S1919.x, _S1919.y, _S1919.z} * make_float3 (mass_0);
    float3  t_world_0 = t_load_0;
    float3  f_world_1;
    float3  t_world_1;
    if(rml_0)
    {
        float3  _S1920 = rg_8->alpha_0;
        float3  _S1921 = rg_8->w_5;
        float3  f_world_2 = f_world_0 - (rg_8->a_13 + cross_0(rg_8->alpha_0, _S1917) + cross_0(rg_8->w_5, cross_0(rg_8->w_5, _S1917))) * make_float3 (mass_0);
        float4  _S1922 = __ldg(&_S1895->inertia0_0);
        float4  _S1923 = __ldg(&_S1895->inertia1_0);
        float4  _S1924 = __ldg(&_S1895->inertia2_0);
        float3  _S1925 = world_mul_0(&rg_8->rot_1, _S1922, _S1923, _S1924, _S1920);
        float3  _S1926 = world_mul_0(&rg_8->rot_1, _S1922, _S1923, _S1924, _S1921);
        float3  t_world_2 = t_world_0 - (_S1925 + cross_0(_S1921, _S1926));
        f_world_1 = f_world_2;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    float3  _S1927 = inverse_rotate_0(&rg_8->rot_1, f_world_1);
    float3  _S1928 = inverse_rotate_0(&rg_8->rot_1, t_world_1);
    float3  f_ext_0;
    float3  m_ext_0;
    if(rml_0)
    {
        float3  _S1929 = inverse_rotate_0(&rg_8->rot_1, rg_8->w_5);
        float3  f_ext_1 = _S1927 - cross_0(_S1929, v_11) * make_float3 (2.0f * mass_0);
        float4  _S1930 = __ldg(&_S1895->inertia0_0);
        float4  _S1931 = __ldg(&_S1895->inertia1_0);
        float4  _S1932 = __ldg(&_S1895->inertia2_0);
        float3  i_w_0 = rows_mul_0(_S1930, _S1931, _S1932, w_6);
        float3  m_ext_1 = _S1928 - (cross_0(_S1929, i_w_0) + cross_0(w_6, rows_mul_0(_S1930, _S1931, _S1932, _S1929)) + cross_0(w_6, i_w_0));
        f_ext_0 = f_ext_1;
        m_ext_0 = m_ext_1;
    }
    else
    {
        f_ext_0 = _S1927;
        m_ext_0 = _S1928;
    }
    float3  f_17 = f_ext_0 + rep_f_1 + fi_5;
    float3  m_7 = m_ext_0 + rep_m_1 + mi_4;
    uint4  _S1933 = __ldg(&_S1895->info_0);
    uint support_1 = _S1933.x;
    float3  _S1934 = make_float3 ((*(&(globalParams_0->state_0)[_S1907])).w, (*(&(globalParams_0->state_0)[_S1909])).w, (*(&(globalParams_0->state_0)[_S1911])).w);
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
        v_12 = _S1896;
        w_7 = _S1896;
    }
    else
    {
        float4  _S1935 = __ldg(&_S1895->inv0_0);
        float4  _S1936 = __ldg(&_S1895->inv1_0);
        float4  _S1937 = __ldg(&_S1895->inv2_0);
        float3  _S1938 = rows_mul_0(_S1935, _S1936, _S1937, m_7);
        float4  _S1939 = __ldg(&_S1895->scale_0);
        float3  w_8 = w_6 + _S1938 * make_float3 (dt_11 * _S1939.z);
        float3  th_6 = th_4 + w_8 * make_float3 (dt_11);
        if(support_1 == 2U)
        {
            reaction_1 = - f_17;
            u_3 = u_2;
            th_5 = _S1896;
        }
        else
        {
            float3  v_13 = v_11 + f_17 * make_float3 (dt_11 * _S1939.y);
            float3  u_4 = u_2 + v_13 * make_float3 (dt_11);
            reaction_1 = _S1934;
            u_3 = u_4;
            th_5 = v_13;
        }
        float3  _S1940 = th_5;
        th_5 = th_6;
        v_12 = _S1940;
        w_7 = w_8;
    }
    *(&(globalParams_0->state_0)[_S1905]) = make_float4 (u_3.x, u_3.y, u_3.z, peak_0);
    *(&(globalParams_0->state_0)[_S1907]) = make_float4 (th_5.x, th_5.y, th_5.z, reaction_1.x);
    *(&(globalParams_0->state_0)[_S1909]) = make_float4 (v_12.x, v_12.y, v_12.z, reaction_1.y);
    *(&(globalParams_0->state_0)[_S1911]) = make_float4 (w_7.x, w_7.y, w_7.z, reaction_1.z);
    float3  _S1941 = rotate_0(&rg_8->rot_1, _S1914 + u_3 - _S1916);
    float3  _S1942 = rg_8->vel_0 + rg_8->vel_err_0 + cross_0(rg_8->w_5, _S1941);
    float3  _S1943 = rotate_0(&rg_8->rot_1, v_12);
    float3  v_world_0 = _S1942 + _S1943;
    float3  _S1944 = rotate_0(&rg_8->rot_1, w_7);
    comp_add1_0(work_2, work_err_0, (dot_0(f_load_0, v_world_0) + dot_0(t_load_0, rg_8->w_5 + _S1944)) * dt_11);
    return;
}

static __device__ void drift_moments_0(uint c_39, float3  * tu_2, float3  * pv_2)
{
    ChunkStatic_0 * _S1945 = (&(globalParams_0->chunks_0)[c_39]);
    float4  _S1946 = __ldg(&_S1945->center_0);
    float _S1947 = _S1946.w;
    float4  _S1948 = __ldg(&_S1945->scale_0);
    float m_8 = _S1947 * _S1948.x;
    uint _S1949 = 4U * c_39;
    float4  _S1950 = *(&(globalParams_0->state_0)[_S1949]);
    *tu_2 = *tu_2 + float3 {_S1950.x, _S1950.y, _S1950.z} * make_float3 (m_8);
    float4  _S1951 = *(&(globalParams_0->state_0)[_S1949 + 2U]);
    *pv_2 = *pv_2 + float3 {_S1951.x, _S1951.y, _S1951.z} * make_float3 (m_8);
    return;
}

static __device__ void island_frame_at_0(uint gi_0, uint tid_19, uint _S1952)
{
    bool woke_0;
    uint _S1953;
    uint _S1954;
    uint _S1955;
    uint _S1956;
    uint _S1957;
    uint _S1958;
    Island_0 isl_22 = *(&(globalParams_0->islands_0)[gi_0]);
    bool driven_0 = (((&isl_22)->info_1.x) & 2U) != 0U;
    bool _S1959 = !((((&isl_22)->info_1.x) & 1U) != 0U);
    uint _S1960 = __ballot_sync(_S1952, _S1959);
    bool _S1961;
    uint cov_2;
    if(_S1959)
    {
        bool _S1962 = !driven_0;
        uint _S1963 = __ballot_sync(_S1952, true);
        _S1961 = _S1962;
        cov_2 = _S1963;
    }
    else
    {
        uint _S1964 = __ballot_sync(_S1952, true);
        _S1961 = false;
        cov_2 = _S1964;
    }
    bool contact_island_0 = (((&isl_22)->info_1.x) & 4U) != 0U;
    bool _S1965 = (((&isl_22)->info_1.x) & 16U) != 0U;
    seen_clear_0(tid_19);
    bool _S1966 = tid_19 == 0U;
    uint _S1967 = __ballot_sync(cov_2, _S1966);
    bool settled_0;
    uint run_0;
    uint done_1;
    if(_S1966)
    {
        uint _S1968 = __ldg(&globalParams_0->params_0->contact_mode_0);
        bool _S1969 = contact_island_0 != (_S1968 == 1U);
        uint _S1970 = __ballot_sync(_S1967, _S1969);
        if(_S1969)
        {
            uint _S1971 = __ballot_sync(_S1967, true);
            settled_0 = true;
            run_0 = _S1971;
        }
        else
        {
            bool _S1972 = (((&isl_22)->info_1.x) & 8U) != 0U;
            uint _S1973 = __ballot_sync(_S1967, true);
            settled_0 = _S1972;
            run_0 = _S1973;
        }
        uint _S1974 = __ballot_sync(run_0, settled_0);
        if(settled_0)
        {
            uint _S1975 = __ballot_sync(run_0, true);
            run_0 = 0U;
            done_1 = _S1975;
        }
        else
        {
            uint _S1976 = __ballot_sync(run_0, true);
            run_0 = 1U;
            done_1 = _S1976;
        }
        uint _S1977 = __ballot_sync(done_1, contact_island_0);
        if(contact_island_0)
        {
            Island_0 _S1978 = isl_22;
            bool _S1979 = contact_stopped_0(&_S1978);
            uint _S1980 = __ballot_sync(done_1, true);
            settled_0 = _S1979;
            done_1 = _S1980;
        }
        else
        {
            uint _S1981 = __ballot_sync(done_1, true);
            settled_0 = false;
            done_1 = _S1981;
        }
        uint _S1982 = __ballot_sync(done_1, settled_0);
        if(settled_0)
        {
            uint _S1983 = __ballot_sync(done_1, true);
            run_0 = 0U;
        }
        else
        {
            uint _S1984 = __ballot_sync(done_1, true);
        }
        *&g_run_0 = run_0;
        *&g_halt_0 = 0U;
        uint _S1985 = __ballot_sync(cov_2, true);
        cov_2 = _S1985;
    }
    else
    {
        uint _S1986 = __ballot_sync(cov_2, true);
        cov_2 = _S1986;
    }
    __syncthreads();
    bool _S1987 = (((&isl_22)->info_1.z) & 1U) != 0U;
    uint _S1988 = __ballot_sync(cov_2, _S1987);
    if(_S1987)
    {
        uint _S1989 = __ballot_sync(cov_2, true);
        settled_0 = true;
        cov_2 = _S1989;
    }
    else
    {
        bool _S1990 = (*&g_run_0) == 0U;
        uint _S1991 = __ballot_sync(cov_2, true);
        settled_0 = _S1990;
        cov_2 = _S1991;
    }
    uint _S1992 = __ballot_sync(cov_2, settled_0);
    if(settled_0)
    {
        uint _S1993 = __ballot_sync(cov_2, true);
        cov_2 = 0U;
        run_0 = _S1993;
    }
    else
    {
        uint _S1994 = (&isl_22)->info_1.y;
        uint _S1995 = __ldg(&globalParams_0->params_0->max_steps_0);
        uint _S1996 = (U32_min((_S1994), (_S1995)));
        uint _S1997 = __ballot_sync(cov_2, true);
        cov_2 = _S1996;
        run_0 = _S1997;
    }
    float _S1998 = __ldg(&globalParams_0->params_0->dt_0);
    uint _S1999 = __ldg(&globalParams_0->params_0->fracture_0);
    bool _S2000 = _S1999 != 0U;
    uint _S2001 = __ldg(&globalParams_0->params_0->rigid_motion_loads_0);
    bool _S2002 = _S2001 != 0U;
    Island_0 _S2003 = isl_22;
    Rigid_0 _S2004 = rigid_of_0(&_S2003);
    Rigid_0 rg_9 = _S2004;
    float work_3 = 0.0f;
    float work_err_1 = 0.0f;
    settled_0 = _S1965;
    done_1 = 0U;
    bool woke_1 = false;
    uint _S2005 = run_0;
    for(;;)
    {
        uint _S2006 = 0U;
        bool _S2007 = done_1 < cov_2;
        uint _S2008 = __ballot_sync(_S2005, _S2007);
        if(_S2007)
        {
            uint _S2009 = __ballot_sync(_S2005, true);
            _S2006 = _S2009;
        }
        else
        {
            uint _S2010 = __ballot_sync(_S2005, false);
            uint _S2011 = __ballot_sync(_S2005, false);
            uint _S2012 = __ballot_sync(run_0, true);
            woke_0 = woke_1;
            cov_2 = _S2012;
            break;
        }
        uint abs_step_1 = (&isl_22)->info_1.w + done_1 + 1U;
        uint _S2013 = abs_step_1 - 1U;
        uint _S2014 = __ldg(&globalParams_0->params_0->step_start_0);
        uint k_22 = _S2013 - _S2014;
        bool quiet_0 = (((&isl_22)->info_1.x) & 32U) != 0U;
        uint _S2015 = __ballot_sync(_S2006, settled_0);
        bool _S2016;
        uint _S2017;
        if(settled_0)
        {
            bool _S2018 = !quiet_0;
            uint _S2019 = __ballot_sync(_S2006, true);
            _S2016 = _S2018;
            _S2017 = _S2019;
        }
        else
        {
            uint _S2020 = __ballot_sync(_S2006, true);
            _S2016 = false;
            _S2017 = _S2020;
        }
        uint _S2021 = __ballot_sync(_S2017, _S2016);
        bool _S2022;
        bool explicit_step_0;
        uint c_40;
        uint _S2023;
        uint c_41;
        if(_S2016)
        {
            float3  _S2024 = make_float3 (0.0f);
            float3  norm_1 = _S2024;
            float3  unused0_0 = _S2024;
            c_40 = (&isl_22)->range_0.x + tid_19;
            _S2023 = _S2021;
            for(;;)
            {
                bool _S2025 = c_40 < ((&isl_22)->range_0.y);
                uint _S2026 = __ballot_sync(_S2023, _S2025);
                if(_S2025)
                {
                    uint _S2027 = __ballot_sync(_S2023, true);
                }
                else
                {
                    uint _S2028 = __ballot_sync(_S2023, false);
                    uint _S2029 = __ballot_sync(_S2023, false);
                    uint _S2030 = __ballot_sync(_S2021, true);
                    _S1953 = _S2030;
                    break;
                }
                Quat_0 _S2031 = (&rg_9)->rot_1;
                float _S2032 = settled_chunk_load_0(c_40, &_S2031, k_22, _S1998, contact_island_0);
                *&((&norm_1)->x) = *&((&norm_1)->x) + _S2032;
                uint _S2033 = __ballot_sync(_S2023, true);
                c_40 = c_40 + 256U;
                _S2023 = _S2033;
            }
            group_sum3_0(tid_19, &norm_1, &unused0_0, _S1953);
            uint _S2034 = __ldg(&globalParams_0->params_0->solve_mode_0);
            bool _S2035 = _S2034 == 1U;
            uint _S2036 = __ballot_sync(_S1953, _S2035);
            if(_S2035)
            {
                bool _S2037 = (F32_abs((norm_1.x - (&isl_22)->energy_1.z))) > ((&isl_22)->energy_1.w);
                uint _S2038 = __ballot_sync(_S1953, true);
                _S2022 = _S2037;
                c_41 = _S2038;
            }
            else
            {
                uint _S2039 = __ballot_sync(_S1953, true);
                _S2022 = false;
                c_41 = _S2039;
            }
            uint _S2040 = __ballot_sync(c_41, _S2022);
            if(_S2022)
            {
                uint _S2041 = __ballot_sync(c_41, true);
                explicit_step_0 = false;
                woke_0 = true;
            }
            else
            {
                uint _S2042 = __ballot_sync(c_41, true);
                explicit_step_0 = settled_0;
                woke_0 = woke_1;
            }
            uint _S2043 = __ballot_sync(_S2017, true);
            settled_0 = explicit_step_0;
            c_40 = _S2043;
        }
        else
        {
            uint _S2044 = __ballot_sync(_S2017, true);
            woke_0 = woke_1;
            c_40 = _S2044;
        }
        uint _S2045 = __ballot_sync(c_40, _S1959);
        if(_S1959)
        {
            bool _S2046 = !quiet_0;
            uint _S2047 = __ballot_sync(c_40, true);
            _S2022 = _S2046;
            _S2023 = _S2047;
        }
        else
        {
            uint _S2048 = __ballot_sync(c_40, true);
            _S2022 = false;
            _S2023 = _S2048;
        }
        uint _S2049 = __ballot_sync(_S2023, _S2022);
        uint _S2050;
        if(_S2022)
        {
            float3  _S2051 = make_float3 (0.0f);
            float3  f_18 = _S2051;
            float3  t_16 = _S2051;
            c_41 = (&isl_22)->range_0.x + tid_19;
            _S2050 = _S2049;
            for(;;)
            {
                bool _S2052 = c_41 < ((&isl_22)->range_0.y);
                uint _S2053 = __ballot_sync(_S2050, _S2052);
                if(_S2052)
                {
                    uint _S2054 = __ballot_sync(_S2050, true);
                }
                else
                {
                    uint _S2055 = __ballot_sync(_S2050, false);
                    uint _S2056 = __ballot_sync(_S2050, false);
                    uint _S2057 = __ballot_sync(_S2049, true);
                    _S1954 = _S2057;
                    break;
                }
                Island_0 _S2058 = isl_22;
                Rigid_0 _S2059 = rg_9;
                net_load_0(c_41, &_S2058, &_S2059, k_22, _S1998, contact_island_0, &f_18, &t_16);
                uint _S2060 = __ballot_sync(_S2050, true);
                c_41 = c_41 + 256U;
                _S2050 = _S2060;
            }
            group_sum3_0(tid_19, &f_18, &t_16, _S1954);
            Island_0 _S2061 = isl_22;
            rigid_acceleration_0(&_S2061, &rg_9, f_18, t_16);
            uint _S2062 = __ballot_sync(_S2023, true);
            c_41 = _S2062;
        }
        else
        {
            uint _S2063 = __ballot_sync(_S2023, true);
            c_41 = _S2063;
        }
        bool _S2064 = !settled_0;
        uint _S2065 = __ballot_sync(c_41, _S2064);
        if(_S2064)
        {
            bool _S2066 = !quiet_0;
            uint _S2067 = __ballot_sync(c_41, true);
            explicit_step_0 = _S2066;
            _S2050 = _S2067;
        }
        else
        {
            uint _S2068 = __ballot_sync(c_41, true);
            explicit_step_0 = false;
            _S2050 = _S2068;
        }
        uint _S2069 = __ballot_sync(_S2050, explicit_step_0);
        uint i_29;
        uint _S2070;
        uint c_42;
        uint _S2071;
        if(explicit_step_0)
        {
            i_29 = (&isl_22)->range_0.z + tid_19;
            _S2070 = _S2069;
            for(;;)
            {
                uint _S2072 = 0U;
                bool _S2073 = i_29 < ((&isl_22)->range_0.w);
                uint _S2074 = __ballot_sync(_S2070, _S2073);
                if(_S2073)
                {
                    uint _S2075 = __ballot_sync(_S2070, true);
                    _S2072 = _S2075;
                }
                else
                {
                    uint _S2076 = __ballot_sync(_S2070, false);
                    uint _S2077 = __ballot_sync(_S2070, false);
                    uint _S2078 = __ballot_sync(_S2069, true);
                    _S1955 = _S2078;
                    break;
                }
                bool _S2079 = bond_update_0(i_29, _S1998, _S2000, abs_step_1, false);
                uint _S2080 = __ballot_sync(_S2072, _S2079);
                if(_S2079)
                {
                    *&g_halt_0 = 1U;
                    uint _S2081 = __ballot_sync(_S2072, true);
                }
                else
                {
                    uint _S2082 = __ballot_sync(_S2072, true);
                }
                uint _S2083 = __ballot_sync(_S2070, true);
                i_29 = i_29 + 256U;
                _S2070 = _S2083;
            }
            __syncthreads();
            c_42 = (&isl_22)->range_0.x + tid_19;
            _S2071 = _S1955;
            for(;;)
            {
                bool _S2084 = c_42 < ((&isl_22)->range_0.y);
                uint _S2085 = __ballot_sync(_S2071, _S2084);
                if(_S2084)
                {
                    uint _S2086 = __ballot_sync(_S2071, true);
                }
                else
                {
                    uint _S2087 = __ballot_sync(_S2071, false);
                    uint _S2088 = __ballot_sync(_S2071, false);
                    uint _S2089 = __ballot_sync(_S1955, true);
                    break;
                }
                Island_0 _S2090 = isl_22;
                Rigid_0 _S2091 = rg_9;
                chunk_update_0(c_42, &_S2090, &_S2091, _S1998, _S2002, k_22, contact_island_0, &work_3, &work_err_1);
                uint _S2092 = __ballot_sync(_S2071, true);
                c_42 = c_42 + 256U;
                _S2071 = _S2092;
            }
            __syncthreads();
            uint _S2093 = __ballot_sync(_S2050, true);
            i_29 = _S2093;
        }
        else
        {
            uint _S2094 = __ballot_sync(_S2050, true);
            i_29 = _S2094;
        }
        uint _S2095 = __ballot_sync(i_29, _S1961);
        bool _S2096;
        if(_S1961)
        {
            bool _S2097 = !quiet_0;
            uint _S2098 = __ballot_sync(i_29, true);
            _S2096 = _S2097;
            _S2070 = _S2098;
        }
        else
        {
            uint _S2099 = __ballot_sync(i_29, true);
            _S2096 = false;
            _S2070 = _S2099;
        }
        uint _S2100 = __ballot_sync(_S2070, _S2096);
        if(_S2096)
        {
            Island_0 _S2101 = isl_22;
            integrate_rigid_0(&_S2101, &rg_9, _S1998);
            uint _S2102 = __ballot_sync(_S2070, true);
            c_42 = _S2102;
        }
        else
        {
            uint _S2103 = __ballot_sync(_S2070, true);
            c_42 = _S2103;
        }
        uint _S2104 = __ballot_sync(c_42, _S1959);
        bool _S2105;
        if(_S1959)
        {
            uint _S2106 = __ballot_sync(c_42, true);
            _S2105 = explicit_step_0;
            _S2071 = _S2106;
        }
        else
        {
            uint _S2107 = __ballot_sync(c_42, true);
            _S2105 = false;
            _S2071 = _S2107;
        }
        uint _S2108 = __ballot_sync(_S2071, _S2105);
        uint c_43;
        uint _S2109;
        uint c_44;
        if(_S2105)
        {
            float4  _S2110 = (&isl_22)->wcom_0;
            float3  _S2111 = float3 {_S2110.x, _S2110.y, _S2110.z};
            float3  _S2112 = make_float3 (0.0f);
            float3  tu_3 = _S2112;
            float3  pv_3 = _S2112;
            c_43 = (&isl_22)->range_0.x + tid_19;
            _S2109 = _S2108;
            for(;;)
            {
                bool _S2113 = c_43 < ((&isl_22)->range_0.y);
                uint _S2114 = __ballot_sync(_S2109, _S2113);
                if(_S2113)
                {
                    uint _S2115 = __ballot_sync(_S2109, true);
                }
                else
                {
                    uint _S2116 = __ballot_sync(_S2109, false);
                    uint _S2117 = __ballot_sync(_S2109, false);
                    uint _S2118 = __ballot_sync(_S2108, true);
                    _S1956 = _S2118;
                    break;
                }
                drift_moments_0(c_43, &tu_3, &pv_3);
                uint _S2119 = __ballot_sync(_S2109, true);
                c_43 = c_43 + 256U;
                _S2109 = _S2119;
            }
            group_sum3_0(tid_19, &tu_3, &pv_3, _S1956);
            float3  tr_5 = tu_3 / make_float3 ((&isl_22)->wcom_0.w);
            float3  dv_5 = pv_3 / make_float3 ((&isl_22)->wcom_0.w);
            float3  lu_3 = _S2112;
            float3  lv_3 = _S2112;
            c_44 = (&isl_22)->range_0.x + tid_19;
            uint _S2120 = _S1956;
            for(;;)
            {
                bool _S2121 = c_44 < ((&isl_22)->range_0.y);
                uint _S2122 = __ballot_sync(_S2120, _S2121);
                if(_S2121)
                {
                    uint _S2123 = __ballot_sync(_S2120, true);
                }
                else
                {
                    uint _S2124 = __ballot_sync(_S2120, false);
                    uint _S2125 = __ballot_sync(_S2120, false);
                    uint _S2126 = __ballot_sync(_S1956, true);
                    _S1957 = _S2126;
                    break;
                }
                drift_angular_0(c_44, _S2111, tr_5, dv_5, &lu_3, &lv_3);
                uint _S2127 = __ballot_sync(_S2120, true);
                c_44 = c_44 + 256U;
                _S2120 = _S2127;
            }
            group_sum3_0(tid_19, &lu_3, &lv_3, _S1957);
            float3  phi_4 = rows_mul_0((&isl_22)->winv0_0, (&isl_22)->winv1_0, (&isl_22)->winv2_0, lu_3);
            float3  dw_3 = rows_mul_0((&isl_22)->winv0_0, (&isl_22)->winv1_0, (&isl_22)->winv2_0, lv_3);
            uint c_45 = (&isl_22)->range_0.x + tid_19;
            uint _S2128 = _S1957;
            for(;;)
            {
                bool _S2129 = c_45 < ((&isl_22)->range_0.y);
                uint _S2130 = __ballot_sync(_S2128, _S2129);
                if(_S2129)
                {
                    uint _S2131 = __ballot_sync(_S2128, true);
                }
                else
                {
                    uint _S2132 = __ballot_sync(_S2128, false);
                    uint _S2133 = __ballot_sync(_S2128, false);
                    uint _S2134 = __ballot_sync(_S1957, true);
                    _S1958 = _S2134;
                    break;
                }
                drift_apply_0(c_45, _S2111, tr_5, phi_4, dv_5, dw_3);
                uint _S2135 = __ballot_sync(_S2128, true);
                c_45 = c_45 + 256U;
                _S2128 = _S2135;
            }
            bool _S2136 = !driven_0;
            uint _S2137 = __ballot_sync(_S1958, _S2136);
            if(_S2136)
            {
                Island_0 _S2138 = isl_22;
                drift_rigid_0(&_S2138, &rg_9, tr_5, phi_4, dv_5, dw_3);
                uint _S2139 = __ballot_sync(_S1958, true);
            }
            else
            {
                uint _S2140 = __ballot_sync(_S1958, true);
            }
            __syncthreads();
            uint _S2141 = __ballot_sync(_S2071, true);
            c_43 = _S2141;
        }
        else
        {
            uint _S2142 = __ballot_sync(_S2071, true);
            c_43 = _S2142;
        }
        uint _S2143 = __ballot_sync(c_43, _S1966);
        bool _S2144;
        if(_S1966)
        {
            bool _S2145 = ((&isl_22)->probes_0.y) > ((&isl_22)->probes_0.x);
            uint _S2146 = __ballot_sync(c_43, true);
            _S2144 = _S2145;
            _S2109 = _S2146;
        }
        else
        {
            uint _S2147 = __ballot_sync(c_43, true);
            _S2144 = false;
            _S2109 = _S2147;
        }
        uint _S2148 = __ballot_sync(_S2109, _S2144);
        if(_S2144)
        {
            Island_0 _S2149 = isl_22;
            Rigid_0 _S2150 = rg_9;
            record_probes_0(&_S2149, &_S2150, k_22);
            uint _S2151 = __ballot_sync(_S2109, true);
            c_44 = _S2151;
        }
        else
        {
            uint _S2152 = __ballot_sync(_S2109, true);
            c_44 = _S2152;
        }
        uint _S2153 = done_1 + 1U;
        bool _S2154 = (*&g_halt_0) != 0U;
        uint _S2155 = __ballot_sync(c_44, _S2154);
        if(_S2154)
        {
            uint _S2156 = __ballot_sync(c_44, false);
            uint _S2157 = __ballot_sync(_S2005, false);
            uint _S2158 = __ballot_sync(run_0, true);
            done_1 = _S2153;
            cov_2 = _S2158;
            break;
        }
        else
        {
            uint _S2159 = __ballot_sync(c_44, true);
        }
        uint _S2160 = __ballot_sync(_S2005, true);
        done_1 = _S2153;
        woke_1 = woke_0;
        _S2005 = _S2160;
    }
    float3  wsum_0 = make_float3 (work_3, work_err_1, 0.0f);
    float3  unused_3 = make_float3 (0.0f);
    group_sum3_0(tid_19, &wsum_0, &unused_3, cov_2);
    uint _S2161 = __ballot_sync(cov_2, _S1966);
    if(_S1966)
    {
        Quat_0 _S2162 = (&rg_9)->rot_1;
        float4  _S2163 = quat_vec_0(&_S2162);
        (&isl_22)->rotation_0 = _S2163;
        (&isl_22)->rotation_err_0 = (&rg_9)->rot_err_0;
        (&isl_22)->position_0 = make_float4 ((&rg_9)->pos_0.x, (&rg_9)->pos_0.y, (&rg_9)->pos_0.z, 0.0f);
        (&isl_22)->position_err_0 = make_float4 ((&rg_9)->pos_err_0.x, (&rg_9)->pos_err_0.y, (&rg_9)->pos_err_0.z, 0.0f);
        (&isl_22)->velocity_0 = make_float4 ((&rg_9)->vel_0.x, (&rg_9)->vel_0.y, (&rg_9)->vel_0.z, 0.0f);
        (&isl_22)->velocity_err_0 = make_float4 ((&rg_9)->vel_err_0.x, (&rg_9)->vel_err_0.y, (&rg_9)->vel_err_0.z, 0.0f);
        (&isl_22)->angular_velocity_0 = make_float4 ((&rg_9)->w_5.x, (&rg_9)->w_5.y, (&rg_9)->w_5.z, 0.0f);
        (&isl_22)->momentum_0 = make_float4 ((&rg_9)->l_1.x, (&rg_9)->l_1.y, (&rg_9)->l_1.z, 0.0f);
        (&isl_22)->momentum_err_0 = make_float4 ((&rg_9)->l_err_0.x, (&rg_9)->l_err_0.y, (&rg_9)->l_err_0.z, 0.0f);
        (&isl_22)->done_0 = done_1;
        *&((&(&isl_22)->info_1)->y) = *&((&(&isl_22)->info_1)->y) - done_1;
        if((*&g_halt_0) != 0U)
        {
            _S1961 = contact_island_0;
        }
        else
        {
            _S1961 = false;
        }
        if(_S1961)
        {
            contact_split_at_0((&isl_22)->info_1.w + done_1);
        }
        comp_add1_0(&((&(&isl_22)->energy_1)->x), &((&(&isl_22)->energy_1)->y), wsum_0.x);
        *&((&(&isl_22)->energy_1)->y) = *&((&(&isl_22)->energy_1)->y) + wsum_0.y;
        *&((&(&isl_22)->info_1)->w) = *&((&(&isl_22)->info_1)->w) + done_1;
        if((*&g_halt_0) != 0U)
        {
            *&((&(&isl_22)->info_1)->z) = (*&((&(&isl_22)->info_1)->z)) | 1U;
        }
        uint _S2164 = seen_bits_0();
        if((*&g_halt_0) != 0U)
        {
            cov_2 = 128U;
        }
        else
        {
            cov_2 = 0U;
        }
        uint _S2165 = _S2164 | cov_2;
        if(woke_0)
        {
            cov_2 = 2048U;
        }
        else
        {
            cov_2 = 0U;
        }
        uint cov_3 = _S2165 | cov_2;
        if(done_1 > 0U)
        {
            bool quiet_1 = (((&isl_22)->info_1.x) & 32U) != 0U;
            if(quiet_1)
            {
                cov_2 = 4096U;
            }
            else
            {
                cov_2 = 0U;
            }
            uint cov_4 = cov_3 | cov_2;
            if((((&isl_22)->info_1.x) & 16U) != 0U)
            {
                _S1961 = !quiet_1;
            }
            else
            {
                _S1961 = false;
            }
            if(_S1961)
            {
                cov_2 = 512U;
            }
            else
            {
                cov_2 = 0U;
            }
            uint cov_5 = cov_4 | cov_2;
            uint _S2166 = __ldg(&globalParams_0->params_0->contact_mode_0);
            if(_S2166 == 1U)
            {
                cov_2 = 524288U;
            }
            else
            {
                cov_2 = 0U;
            }
            uint cov_6 = cov_5 | cov_2;
            if(((&isl_22)->probes_0.y) > ((&isl_22)->probes_0.x))
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
        (&isl_22)->coverage_0 = ((&isl_22)->coverage_0) | cov_2;
        if(woke_0)
        {
            *&((&(&isl_22)->info_1)->x) = (*&((&(&isl_22)->info_1)->x)) & 4294967279U;
            *&((&(&isl_22)->info_1)->z) = (*&((&(&isl_22)->info_1)->z)) | 4U;
        }
        *(&(globalParams_0->islands_0)[gi_0]) = isl_22;
    }
    return;
}

extern "C" __global__ void island_frame()
{
    uint _S2167 = __ballot_sync(4294967295U, true);
    island_frame_at_0(blockIdx.x, threadIdx.x, _S2167);
    return;
}

static __device__ void wide_chunks_at_0(uint gx_0, uint tid_20, uint _S2168)
{
    uint _S2169 = 0U;
    uint _S2170 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    WideGroup_0 wg_6 = wide_group_0(_S2170, gx_0);
    Island_0 isl_23 = *(&(globalParams_0->islands_0)[wg_6.island_2]);
    bool _S2171 = wide_enter_1(tid_20, wg_6.island_2);
    bool _S2172 = !_S2171;
    uint _S2173 = __ballot_sync(_S2168, _S2172);
    if(_S2172)
    {
        return;
    }
    else
    {
        uint _S2174 = __ballot_sync(_S2168, true);
        _S2169 = _S2174;
    }
    uint _S2175 = 0U;
    uint _S2176 = isl_23.info_1.x;
    bool anchored_0 = (_S2176 & 1U) != 0U;
    bool _S2177 = (_S2176 & 16U) != 0U;
    uint _S2178 = __ballot_sync(_S2169, _S2177);
    if(_S2177)
    {
        if(tid_20 == 0U)
        {
            uint _S2179 = __ldg(&globalParams_0->params_0->wide_base_0);
            *(&(globalParams_0->scratch_0)[_S2179 + 8U * gx_0 + 6U]) = make_float4 (0.0f);
        }
        return;
    }
    else
    {
        uint _S2180 = __ballot_sync(_S2169, true);
        _S2175 = _S2180;
    }
    Island_0 _S2181 = isl_23;
    WideGroup_0 _S2182 = wg_6;
    Rigid_0 _S2183 = wide_rigid_frame_0(tid_20, &_S2181, &_S2182, _S2175);
    float work_4 = 0.0f;
    float work_err_2 = 0.0f;
    float3  _S2184 = make_float3 (0.0f);
    float3  tu_4 = _S2184;
    float3  pv_4 = _S2184;
    uint c_46 = wg_6.begin_0 + tid_20;
    bool _S2185 = c_46 < (wg_6.end_0);
    uint _S2186 = __ballot_sync(_S2175, _S2185);
    uint _S2187;
    if(_S2185)
    {
        float _S2188 = __ldg(&globalParams_0->params_0->dt_0);
        uint _S2189 = __ldg(&globalParams_0->params_0->rigid_motion_loads_0);
        bool _S2190 = _S2189 != 0U;
        Island_0 _S2191 = isl_23;
        uint _S2192 = wide_step_0(&_S2191);
        bool _S2193 = (_S2176 & 4U) != 0U;
        Island_0 _S2194 = isl_23;
        Rigid_0 _S2195 = _S2183;
        chunk_update_0(c_46, &_S2194, &_S2195, _S2188, _S2190, _S2192, _S2193, &work_4, &work_err_2);
        bool _S2196 = !anchored_0;
        uint _S2197 = __ballot_sync(_S2186, _S2196);
        if(_S2196)
        {
            drift_moments_0(c_46, &tu_4, &pv_4);
            uint _S2198 = __ballot_sync(_S2186, true);
        }
        else
        {
            uint _S2199 = __ballot_sync(_S2186, true);
        }
        uint _S2200 = __ballot_sync(_S2175, true);
        _S2187 = _S2200;
    }
    else
    {
        uint _S2201 = __ballot_sync(_S2175, true);
        _S2187 = _S2201;
    }
    float3  wsum_1 = make_float3 (work_4, work_err_2, 0.0f);
    float3  unused_4 = _S2184;
    group_sum3_0(tid_20, &wsum_1, &unused_4, _S2187);
    bool _S2202 = !anchored_0;
    uint _S2203 = __ballot_sync(_S2187, _S2202);
    if(_S2202)
    {
        group_sum3_0(tid_20, &tu_4, &pv_4, _S2203);
        uint _S2204 = __ballot_sync(_S2187, true);
    }
    if(tid_20 == 0U)
    {
        uint _S2205 = __ldg(&globalParams_0->params_0->wide_base_0);
        uint _S2206 = 8U * gx_0;
        *(&(globalParams_0->scratch_0)[_S2205 + _S2206 + 6U]) = make_float4 (wsum_1.x, wsum_1.y, wsum_1.z, 0.0f);
        if(_S2202)
        {
            wide_store_0(gx_0, 2U, tu_4, pv_4);
        }
        uint _S2207 = __ldg(&globalParams_0->params_0->wide_base_0);
        *(&(globalParams_0->scratch_0)[_S2207 + _S2206 + 7U]) = make_float4 (float((*&g_seen_0)[0U]), float((*&g_seen_0)[1U]), float((*&g_seen_0)[2U]), 0.0f);
    }
    return;
}

extern "C" __global__ void wide_chunks()
{
    uint _S2208 = __ballot_sync(4294967295U, true);
    wide_chunks_at_0(blockIdx.x, threadIdx.x, _S2208);
    return;
}

extern "C" __global__ void sums_and_impactors()
{
    uint _S2209 = __ballot_sync(4294967295U, true);
    uint _S2210 = __ldg(&globalParams_0->params_0->seg_count_0);
    uint sums_groups_0 = (_S2210 + 255U) / 256U;
    uint _S2211 = blockIdx.x;
    bool _S2212 = _S2211 < sums_groups_0;
    uint _S2213 = __ballot_sync(_S2209, _S2212);
    if(_S2212)
    {
        contact_sum_at_0(_S2211 * 256U + threadIdx.x);
    }
    else
    {
        impactor_integrate_at_0(_S2211 - sums_groups_0, threadIdx.x, _S2209 & (~_S2213));
        uint _S2214 = __ballot_sync(_S2209, true);
    }
    return;
}

extern "C" __global__ void islands_and_wide_chunks()
{
    uint _S2215 = __ballot_sync(4294967295U, true);
    uint _S2216 = blockIdx.x;
    uint _S2217 = __ldg(&globalParams_0->params_0->halt_index_0);
    bool _S2218 = _S2216 < _S2217;
    uint _S2219 = __ballot_sync(_S2215, _S2218);
    if(_S2218)
    {
        island_frame_at_0(_S2216, threadIdx.x, _S2219);
        uint _S2220 = __ballot_sync(_S2215, true);
    }
    else
    {
        uint _S2221 = _S2215 & (~_S2219);
        uint _S2222 = __ldg(&globalParams_0->params_0->halt_index_0);
        wide_chunks_at_0(_S2216 - _S2222, threadIdx.x, _S2221);
        uint _S2223 = __ballot_sync(_S2215, true);
    }
    return;
}

__device__ __shared__ uint g_flag_0;

__device__ __shared__ FixedArray<uint, 1024>  g_mode_0;

static __device__ uint pc_k_0(Island_0 * isl_24)
{
    uint _S2224 = isl_24->info_1.w;
    uint _S2225 = __ldg(&globalParams_0->params_0->step_start_0);
    return _S2224 - _S2225;
}

static __device__ void pc_store_rigid_0(uint i_30, Rigid_0 * rg_10)
{
    uint _S2226 = __ldg(&globalParams_0->params_0->pi_base_0);
    uint at_7 = _S2226 + 16U * i_30;
    float4  * _S2227 = (&(globalParams_0->scratch_0)[at_7]);
    float4  _S2228 = quat_vec_0(&rg_10->rot_1);
    *_S2227 = _S2228;
    *(&(globalParams_0->scratch_0)[at_7 + 1U]) = rg_10->rot_err_0;
    *(&(globalParams_0->scratch_0)[at_7 + 2U]) = make_float4 (rg_10->pos_0.x, rg_10->pos_0.y, rg_10->pos_0.z, 0.0f);
    *(&(globalParams_0->scratch_0)[at_7 + 3U]) = make_float4 (rg_10->pos_err_0.x, rg_10->pos_err_0.y, rg_10->pos_err_0.z, 0.0f);
    *(&(globalParams_0->scratch_0)[at_7 + 4U]) = make_float4 (rg_10->vel_0.x, rg_10->vel_0.y, rg_10->vel_0.z, 0.0f);
    *(&(globalParams_0->scratch_0)[at_7 + 5U]) = make_float4 (rg_10->vel_err_0.x, rg_10->vel_err_0.y, rg_10->vel_err_0.z, 0.0f);
    *(&(globalParams_0->scratch_0)[at_7 + 6U]) = make_float4 (rg_10->w_5.x, rg_10->w_5.y, rg_10->w_5.z, 0.0f);
    *(&(globalParams_0->scratch_0)[at_7 + 7U]) = make_float4 (rg_10->l_1.x, rg_10->l_1.y, rg_10->l_1.z, 0.0f);
    *(&(globalParams_0->scratch_0)[at_7 + 8U]) = make_float4 (rg_10->l_err_0.x, rg_10->l_err_0.y, rg_10->l_err_0.z, 0.0f);
    *(&(globalParams_0->scratch_0)[at_7 + 9U]) = make_float4 (rg_10->torque_0.x, rg_10->torque_0.y, rg_10->torque_0.z, 0.0f);
    *(&(globalParams_0->scratch_0)[at_7 + 10U]) = make_float4 (rg_10->a_13.x, rg_10->a_13.y, rg_10->a_13.z, 0.0f);
    *(&(globalParams_0->scratch_0)[at_7 + 11U]) = make_float4 (rg_10->alpha_0.x, rg_10->alpha_0.y, rg_10->alpha_0.z, 0.0f);
    return;
}

static __device__ Rigid_0 pc_load_rigid_0(uint i_31)
{
    uint _S2229 = __ldg(&globalParams_0->params_0->pi_base_0);
    uint at_8 = _S2229 + 16U * i_31;
    Rigid_0 rg_11;
    (&rg_11)->rot_1 = quat_of_0(*(&(globalParams_0->scratch_0)[at_8]));
    (&rg_11)->rot_err_0 = *(&(globalParams_0->scratch_0)[at_8 + 1U]);
    float4  _S2230 = *(&(globalParams_0->scratch_0)[at_8 + 2U]);
    (&rg_11)->pos_0 = float3 {_S2230.x, _S2230.y, _S2230.z};
    float4  _S2231 = *(&(globalParams_0->scratch_0)[at_8 + 3U]);
    (&rg_11)->pos_err_0 = float3 {_S2231.x, _S2231.y, _S2231.z};
    float4  _S2232 = *(&(globalParams_0->scratch_0)[at_8 + 4U]);
    (&rg_11)->vel_0 = float3 {_S2232.x, _S2232.y, _S2232.z};
    float4  _S2233 = *(&(globalParams_0->scratch_0)[at_8 + 5U]);
    (&rg_11)->vel_err_0 = float3 {_S2233.x, _S2233.y, _S2233.z};
    float4  _S2234 = *(&(globalParams_0->scratch_0)[at_8 + 6U]);
    (&rg_11)->w_5 = float3 {_S2234.x, _S2234.y, _S2234.z};
    float4  _S2235 = *(&(globalParams_0->scratch_0)[at_8 + 7U]);
    (&rg_11)->l_1 = float3 {_S2235.x, _S2235.y, _S2235.z};
    float4  _S2236 = *(&(globalParams_0->scratch_0)[at_8 + 8U]);
    (&rg_11)->l_err_0 = float3 {_S2236.x, _S2236.y, _S2236.z};
    float4  _S2237 = *(&(globalParams_0->scratch_0)[at_8 + 9U]);
    (&rg_11)->torque_0 = float3 {_S2237.x, _S2237.y, _S2237.z};
    float4  _S2238 = *(&(globalParams_0->scratch_0)[at_8 + 10U]);
    (&rg_11)->a_13 = float3 {_S2238.x, _S2238.y, _S2238.z};
    float4  _S2239 = *(&(globalParams_0->scratch_0)[at_8 + 11U]);
    (&rg_11)->alpha_0 = float3 {_S2239.x, _S2239.y, _S2239.z};
    return rg_11;
}

static __device__ bool contact_stopped_1(uint _S2240)
{
    Island_0 * _S2241 = (&(globalParams_0->islands_0)[_S2240]);
    uint _S2242 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint4  _S2243 = (&(globalParams_0->islands_0)[_S2242])->info_1;
    bool _S2244;
    if((((&(globalParams_0->islands_0)[_S2242])->info_1.z) & 1U) != 0U)
    {
        _S2244 = true;
    }
    else
    {
        uint _S2245 = _S2243.y;
        if(_S2245 != 0U)
        {
            _S2244 = _S2245 <= (_S2241->info_1.w);
        }
        else
        {
            _S2244 = false;
        }
    }
    return _S2244;
}

static __device__ uint pc_k_1(uint _S2246)
{
    uint _S2247 = (&(globalParams_0->islands_0)[_S2246])->info_1.w;
    uint _S2248 = __ldg(&globalParams_0->params_0->step_start_0);
    return _S2247 - _S2248;
}

static __device__ void pc_sum_0(uint _S2249, float3  * _S2250, float3  * _S2251)
{
    uint4  _S2252 = (&(globalParams_0->islands_0)[_S2249])->range_0;
    uint c_47 = (&(globalParams_0->islands_0)[_S2249])->range_0.x;
    for(;;)
    {
        if(c_47 < (_S2252.y))
        {
        }
        else
        {
            break;
        }
        uint _S2253 = __ldg(&globalParams_0->params_0->pc_base_0);
        uint _S2254 = 2U * c_47;
        float4  _S2255 = *(&(globalParams_0->scratch_0)[_S2253 + _S2254]);
        *_S2250 = *_S2250 + float3 {_S2255.x, _S2255.y, _S2255.z};
        uint _S2256 = __ldg(&globalParams_0->params_0->pc_base_0);
        float4  _S2257 = *(&(globalParams_0->scratch_0)[_S2256 + _S2254 + 1U]);
        *_S2251 = *_S2251 + float3 {_S2257.x, _S2257.y, _S2257.z};
        c_47 = c_47 + 1U;
    }
    return;
}

static __device__ Rigid_0 rigid_of_1(uint _S2258)
{
    Island_0 * _S2259 = (&(globalParams_0->islands_0)[_S2258]);
    Rigid_0 rg_12;
    (&rg_12)->rot_1 = quat_of_0(_S2259->rotation_0);
    (&rg_12)->rot_err_0 = _S2259->rotation_err_0;
    float4  _S2260 = _S2259->position_0;
    (&rg_12)->pos_0 = float3 {_S2260.x, _S2260.y, _S2260.z};
    float4  _S2261 = _S2259->position_err_0;
    (&rg_12)->pos_err_0 = float3 {_S2261.x, _S2261.y, _S2261.z};
    float4  _S2262 = _S2259->velocity_0;
    (&rg_12)->vel_0 = float3 {_S2262.x, _S2262.y, _S2262.z};
    float4  _S2263 = _S2259->velocity_err_0;
    (&rg_12)->vel_err_0 = float3 {_S2263.x, _S2263.y, _S2263.z};
    float4  _S2264 = _S2259->angular_velocity_0;
    (&rg_12)->w_5 = float3 {_S2264.x, _S2264.y, _S2264.z};
    float4  _S2265 = _S2259->momentum_0;
    (&rg_12)->l_1 = float3 {_S2265.x, _S2265.y, _S2265.z};
    float4  _S2266 = _S2259->momentum_err_0;
    (&rg_12)->l_err_0 = float3 {_S2266.x, _S2266.y, _S2266.z};
    float3  _S2267 = make_float3 (0.0f);
    (&rg_12)->torque_0 = _S2267;
    (&rg_12)->a_13 = _S2267;
    (&rg_12)->alpha_0 = _S2267;
    return rg_12;
}

static __device__ void net_load_1(uint _S2268, uint _S2269, Rigid_0 * _S2270, uint _S2271, float _S2272, bool _S2273, float3  * _S2274, float3  * _S2275)
{
    Island_0 _S2276 = *(&(globalParams_0->islands_0)[_S2269]);
    ChunkStatic_0 * _S2277 = (&(globalParams_0->chunks_0)[_S2268]);
    float3  fl_1;
    float3  tl_1;
    float3  rep_f_2;
    float3  rep_m_2;
    chunk_loads_0(_S2268, _S2268, &_S2270->rot_1, _S2271, _S2272, _S2273, 0.0f, &fl_1, &tl_1, &rep_f_2, &rep_m_2);
    float3  _S2278 = fl_1;
    float4  _S2279 = __ldg(&globalParams_0->params_0->gravity_0);
    float3  _S2280 = float3 {_S2279.x, _S2279.y, _S2279.z};
    float4  _S2281 = __ldg(&_S2277->center_0);
    float3  fc_4 = _S2278 + _S2280 * make_float3 (_S2281.w);
    float3  _S2282 = float3 {_S2281.x, _S2281.y, _S2281.z};
    float4  _S2283 = *(&(globalParams_0->state_0)[4U * _S2268]);
    float4  _S2284 = _S2276.com_0;
    float3  _S2285 = float3 {_S2284.x, _S2284.y, _S2284.z};
    float3  _S2286 = rotate_0(&_S2270->rot_1, _S2282 + float3 {_S2283.x, _S2283.y, _S2283.z} - _S2285);
    *_S2274 = *_S2274 + fc_4;
    *_S2275 = *_S2275 + (cross_0(_S2286, fc_4) + tl_1);
    uint4  _S2287 = __ldg(&_S2277->load_range_0);
    if((_S2287.y) > (_S2287.x))
    {
        float3  _S2288 = rotate_0(&_S2270->rot_1, rep_f_2);
        *_S2274 = *_S2274 + _S2288;
        float3  _S2289 = rotate_0(&_S2270->rot_1, _S2282 - _S2285);
        float3  _S2290 = cross_0(_S2289, _S2288);
        float3  _S2291 = rotate_0(&_S2270->rot_1, rep_m_2);
        *_S2275 = *_S2275 + (_S2290 + _S2291);
    }
    return;
}

static __device__ void chunk_update_1(uint _S2292, uint _S2293, Rigid_0 * _S2294, float _S2295, bool _S2296, uint _S2297, bool _S2298, float * _S2299, float * _S2300)
{
    Island_0 * _S2301 = (&(globalParams_0->islands_0)[_S2293]);
    ChunkStatic_0 * _S2302 = (&(globalParams_0->chunks_0)[_S2292]);
    float3  _S2303 = make_float3 (0.0f);
    uint _S2304 = __ldg((&(globalParams_0->index_0)[_S2292]));
    float peak_1 = 0.0f;
    uint e_8 = _S2304;
    float3  fi_6 = _S2303;
    float3  mi_7 = _S2303;
    for(;;)
    {
        uint _S2305 = __ldg((&(globalParams_0->index_0)[_S2292 + 1U]));
        if(e_8 < _S2305)
        {
        }
        else
        {
            break;
        }
        uint _S2306 = __ldg((&(globalParams_0->index_0)[e_8]));
        uint _S2307 = 3U * (_S2306 >> int(1));
        float4  fa_3 = *(&(globalParams_0->scratch_0)[_S2307]);
        if((_S2306 & 1U) == 0U)
        {
            float4  _S2308 = *(&(globalParams_0->scratch_0)[_S2307 + 1U]);
            float3  mi_8 = mi_7 + float3 {_S2308.x, _S2308.y, _S2308.z};
            fi_6 = fi_6 + float3 {fa_3.x, fa_3.y, fa_3.z};
            mi_7 = mi_8;
        }
        else
        {
            float4  _S2309 = *(&(globalParams_0->scratch_0)[_S2307 + 2U]);
            float3  mi_9 = mi_7 + float3 {_S2309.x, _S2309.y, _S2309.z};
            fi_6 = fi_6 + - float3 {fa_3.x, fa_3.y, fa_3.z};
            mi_7 = mi_9;
        }
        float _S2310 = (F32_max((peak_1), (fa_3.w)));
        uint _S2311 = e_8 + 1U;
        peak_1 = _S2310;
        e_8 = _S2311;
    }
    uint _S2312 = 4U * _S2292;
    float4  _S2313 = *(&(globalParams_0->state_0)[_S2312]);
    float3  u_5 = float3 {_S2313.x, _S2313.y, _S2313.z};
    uint _S2314 = _S2312 + 1U;
    float4  _S2315 = *(&(globalParams_0->state_0)[_S2314]);
    float3  th_7 = float3 {_S2315.x, _S2315.y, _S2315.z};
    uint _S2316 = _S2312 + 2U;
    float4  _S2317 = *(&(globalParams_0->state_0)[_S2316]);
    float3  v_14 = float3 {_S2317.x, _S2317.y, _S2317.z};
    uint _S2318 = _S2312 + 3U;
    float4  _S2319 = *(&(globalParams_0->state_0)[_S2318]);
    float3  w_9 = float3 {_S2319.x, _S2319.y, _S2319.z};
    float4  _S2320 = __ldg(&_S2302->center_0);
    float mass_1 = _S2320.w;
    float3  _S2321 = float3 {_S2320.x, _S2320.y, _S2320.z};
    float4  _S2322 = _S2301->com_0;
    float3  _S2323 = float3 {_S2322.x, _S2322.y, _S2322.z};
    float3  _S2324 = rotate_0(&_S2294->rot_1, _S2321 + u_5 - _S2323);
    float3  f_load_1;
    float3  t_load_1;
    float3  rep_f_3;
    float3  rep_m_3;
    chunk_loads_0(_S2292, _S2292, &_S2294->rot_1, _S2297, _S2295, _S2298, _S2295, &f_load_1, &t_load_1, &rep_f_3, &rep_m_3);
    record_chunk_load_0(_S2292, f_load_1, t_load_1);
    float3  _S2325 = f_load_1;
    float4  _S2326 = __ldg(&globalParams_0->params_0->gravity_0);
    float3  f_world_3 = _S2325 + float3 {_S2326.x, _S2326.y, _S2326.z} * make_float3 (mass_1);
    float3  t_world_3 = t_load_1;
    float3  f_world_4;
    float3  t_world_4;
    if(_S2296)
    {
        float3  _S2327 = _S2294->alpha_0;
        float3  _S2328 = _S2294->w_5;
        float3  f_world_5 = f_world_3 - (_S2294->a_13 + cross_0(_S2294->alpha_0, _S2324) + cross_0(_S2294->w_5, cross_0(_S2294->w_5, _S2324))) * make_float3 (mass_1);
        float4  _S2329 = __ldg(&_S2302->inertia0_0);
        float4  _S2330 = __ldg(&_S2302->inertia1_0);
        float4  _S2331 = __ldg(&_S2302->inertia2_0);
        float3  _S2332 = world_mul_0(&_S2294->rot_1, _S2329, _S2330, _S2331, _S2327);
        float3  _S2333 = world_mul_0(&_S2294->rot_1, _S2329, _S2330, _S2331, _S2328);
        float3  t_world_5 = t_world_3 - (_S2332 + cross_0(_S2328, _S2333));
        f_world_4 = f_world_5;
        t_world_4 = t_world_5;
    }
    else
    {
        f_world_4 = f_world_3;
        t_world_4 = t_world_3;
    }
    float3  _S2334 = inverse_rotate_0(&_S2294->rot_1, f_world_4);
    float3  _S2335 = inverse_rotate_0(&_S2294->rot_1, t_world_4);
    float3  f_ext_2;
    float3  m_ext_2;
    if(_S2296)
    {
        float3  _S2336 = inverse_rotate_0(&_S2294->rot_1, _S2294->w_5);
        float3  f_ext_3 = _S2334 - cross_0(_S2336, v_14) * make_float3 (2.0f * mass_1);
        float4  _S2337 = __ldg(&_S2302->inertia0_0);
        float4  _S2338 = __ldg(&_S2302->inertia1_0);
        float4  _S2339 = __ldg(&_S2302->inertia2_0);
        float3  i_w_1 = rows_mul_0(_S2337, _S2338, _S2339, w_9);
        float3  m_ext_3 = _S2335 - (cross_0(_S2336, i_w_1) + cross_0(w_9, rows_mul_0(_S2337, _S2338, _S2339, _S2336)) + cross_0(w_9, i_w_1));
        f_ext_2 = f_ext_3;
        m_ext_2 = m_ext_3;
    }
    else
    {
        f_ext_2 = _S2334;
        m_ext_2 = _S2335;
    }
    float3  f_19 = f_ext_2 + rep_f_3 + fi_6;
    float3  m_9 = m_ext_2 + rep_m_3 + mi_7;
    uint4  _S2340 = __ldg(&_S2302->info_0);
    uint support_2 = _S2340.x;
    float3  _S2341 = make_float3 ((*(&(globalParams_0->state_0)[_S2314])).w, (*(&(globalParams_0->state_0)[_S2316])).w, (*(&(globalParams_0->state_0)[_S2318])).w);
    float3  reaction_2;
    float3  u_6;
    float3  th_8;
    float3  v_15;
    float3  w_10;
    if(support_2 == 1U)
    {
        reaction_2 = - f_19;
        u_6 = u_5;
        th_8 = th_7;
        v_15 = _S2303;
        w_10 = _S2303;
    }
    else
    {
        float4  _S2342 = __ldg(&_S2302->inv0_0);
        float4  _S2343 = __ldg(&_S2302->inv1_0);
        float4  _S2344 = __ldg(&_S2302->inv2_0);
        float3  _S2345 = rows_mul_0(_S2342, _S2343, _S2344, m_9);
        float4  _S2346 = __ldg(&_S2302->scale_0);
        float3  w_11 = w_9 + _S2345 * make_float3 (_S2295 * _S2346.z);
        float3  th_9 = th_7 + w_11 * make_float3 (_S2295);
        if(support_2 == 2U)
        {
            reaction_2 = - f_19;
            u_6 = u_5;
            th_8 = _S2303;
        }
        else
        {
            float3  v_16 = v_14 + f_19 * make_float3 (_S2295 * _S2346.y);
            float3  u_7 = u_5 + v_16 * make_float3 (_S2295);
            reaction_2 = _S2341;
            u_6 = u_7;
            th_8 = v_16;
        }
        float3  _S2347 = th_8;
        th_8 = th_9;
        v_15 = _S2347;
        w_10 = w_11;
    }
    *(&(globalParams_0->state_0)[_S2312]) = make_float4 (u_6.x, u_6.y, u_6.z, peak_1);
    *(&(globalParams_0->state_0)[_S2314]) = make_float4 (th_8.x, th_8.y, th_8.z, reaction_2.x);
    *(&(globalParams_0->state_0)[_S2316]) = make_float4 (v_15.x, v_15.y, v_15.z, reaction_2.y);
    *(&(globalParams_0->state_0)[_S2318]) = make_float4 (w_10.x, w_10.y, w_10.z, reaction_2.z);
    float3  _S2348 = rotate_0(&_S2294->rot_1, _S2321 + u_6 - _S2323);
    float3  _S2349 = _S2294->vel_0 + _S2294->vel_err_0 + cross_0(_S2294->w_5, _S2348);
    float3  _S2350 = rotate_0(&_S2294->rot_1, v_15);
    float3  v_world_1 = _S2349 + _S2350;
    float3  _S2351 = rotate_0(&_S2294->rot_1, w_10);
    comp_add1_0(_S2299, _S2300, (dot_0(f_load_1, v_world_1) + dot_0(t_load_1, _S2294->w_5 + _S2351)) * _S2295);
    return;
}

extern "C" __global__ void contact_frames()
{
    uint p_17;
    uint _S2352;
    uint q_14;
    uint _S2353;
    uint c_48;
    uint mode_1;
    uint g_4;
    uint _S2354;
    uint mode_2;
    uint _S2355;
    uint c_49;
    uint mode_3;
    bool contact_4;
    bool _S2356;
    uint _S2357;
    uint _S2358;
    uint _S2359;
    uint _S2360;
    uint _S2361;
    uint _S2362;
    uint _S2363;
    uint c_50;
    uint _S2364;
    uint _S2365;
    uint b_32;
    uint _S2366;
    uint _S2367;
    uint _S2368;
    uint c_51;
    uint _S2369;
    uint _S2370;
    uint _S2371;
    uint _S2372;
    uint _S2373;
    uint _S2374;
    uint _S2375;
    uint _S2376;
    uint _S2377;
    uint _S2378;
    uint _S2379;
    uint _S2380;
    uint _S2381;
    uint _S2382 = __ballot_sync(4294967295U, true);
    uint _S2383 = threadIdx.x;
    uint _S2384 = __ldg(&globalParams_0->params_0->halt_index_0);
    float _S2385 = __ldg(&globalParams_0->params_0->dt_0);
    uint _S2386 = __ldg(&globalParams_0->params_0->fracture_0);
    bool _S2387 = _S2386 != 0U;
    uint _S2388 = __ldg(&globalParams_0->params_0->rigid_motion_loads_0);
    bool _S2389 = _S2388 != 0U;
    uint _S2390 = __ldg(&globalParams_0->params_0->solve_mode_0);
    bool _S2391 = _S2390 == 1U;
    uint s_13 = 0U;
    uint _S2392 = _S2382;
    for(;;)
    {
        uint _S2393 = 0U;
        uint _S2394 = __ldg(&globalParams_0->params_0->pc_steps_0);
        bool _S2395 = s_13 < _S2394;
        uint _S2396 = __ballot_sync(_S2392, _S2395);
        if(_S2395)
        {
            uint _S2397 = __ballot_sync(_S2392, true);
            _S2393 = _S2397;
        }
        else
        {
            break;
        }
        seen_clear_0(_S2383);
        bool _S2398 = _S2383 == 0U;
        uint _S2399 = __ballot_sync(_S2393, _S2398);
        uint _S2400;
        if(_S2398)
        {
            *&g_flag_0 = 0U;
            uint _S2401 = __ballot_sync(_S2393, true);
            _S2400 = _S2401;
        }
        else
        {
            uint _S2402 = __ballot_sync(_S2393, true);
            _S2400 = _S2402;
        }
        __syncthreads();
        uint i_32 = _S2383;
        uint _S2403 = _S2400;
        for(;;)
        {
            uint _S2404 = 0U;
            bool _S2405 = i_32 < _S2384;
            uint _S2406 = __ballot_sync(_S2403, _S2405);
            if(_S2405)
            {
                uint _S2407 = __ballot_sync(_S2403, true);
                _S2404 = _S2407;
            }
            else
            {
                uint _S2408 = __ballot_sync(_S2403, false);
                uint _S2409 = __ballot_sync(_S2403, false);
                uint _S2410 = __ballot_sync(_S2400, true);
                _S2357 = _S2410;
                break;
            }
            uint4  _S2411 = (&(globalParams_0->islands_0)[i_32])->info_1;
            uint x_26 = (&(globalParams_0->islands_0)[i_32])->info_1.x;
            bool _S2412 = (x_26 & 4U) != 0U;
            uint _S2413 = __ballot_sync(_S2404, _S2412);
            if(_S2412)
            {
                bool _S2414 = (x_26 & 2U) == 0U;
                uint _S2415 = __ballot_sync(_S2404, true);
                contact_4 = _S2414;
                p_17 = _S2415;
            }
            else
            {
                uint _S2416 = __ballot_sync(_S2404, true);
                contact_4 = false;
                p_17 = _S2416;
            }
            uint _S2417 = __ballot_sync(p_17, contact_4);
            if(contact_4)
            {
                bool _S2418 = ((_S2411.z) & 1U) == 0U;
                uint _S2419 = __ballot_sync(p_17, true);
                _S2356 = _S2418;
                _S2352 = _S2419;
            }
            else
            {
                uint _S2420 = __ballot_sync(p_17, true);
                _S2356 = false;
                _S2352 = _S2420;
            }
            uint _S2421 = __ballot_sync(_S2352, _S2356);
            bool _S2422;
            if(_S2356)
            {
                bool _S2423 = (_S2411.y) > 0U;
                uint _S2424 = __ballot_sync(_S2352, true);
                _S2422 = _S2423;
                q_14 = _S2424;
            }
            else
            {
                uint _S2425 = __ballot_sync(_S2352, true);
                _S2422 = false;
                q_14 = _S2425;
            }
            uint _S2426 = __ballot_sync(q_14, _S2422);
            bool _S2427;
            if(_S2422)
            {
                bool _S2428 = contact_stopped_1(i_32);
                bool _S2429 = !_S2428;
                uint _S2430 = __ballot_sync(q_14, true);
                _S2427 = _S2429;
                _S2353 = _S2430;
            }
            else
            {
                uint _S2431 = __ballot_sync(q_14, true);
                _S2427 = false;
                _S2353 = _S2431;
            }
            uint _S2432 = __ballot_sync(_S2353, _S2427);
            if(_S2427)
            {
                bool quiet_2 = (x_26 & 32U) != 0U;
                bool settled_1 = (x_26 & 16U) != 0U;
                bool _S2433 = !((x_26 & 1U) != 0U);
                uint _S2434 = __ballot_sync(_S2432, _S2433);
                bool _S2435;
                if(_S2433)
                {
                    bool _S2436 = !quiet_2;
                    uint _S2437 = __ballot_sync(_S2432, true);
                    _S2435 = _S2436;
                    c_48 = _S2437;
                }
                else
                {
                    uint _S2438 = __ballot_sync(_S2432, true);
                    _S2435 = false;
                    c_48 = _S2438;
                }
                uint _S2439 = __ballot_sync(c_48, _S2435);
                if(_S2435)
                {
                    uint _S2440 = __ballot_sync(c_48, true);
                    mode_1 = 13U;
                    g_4 = _S2440;
                }
                else
                {
                    uint _S2441 = __ballot_sync(c_48, true);
                    mode_1 = 1U;
                    g_4 = _S2441;
                }
                bool _S2442 = !settled_1;
                uint _S2443 = __ballot_sync(g_4, _S2442);
                bool _S2444;
                if(_S2442)
                {
                    bool _S2445 = !quiet_2;
                    uint _S2446 = __ballot_sync(g_4, true);
                    _S2444 = _S2445;
                    _S2354 = _S2446;
                }
                else
                {
                    uint _S2447 = __ballot_sync(g_4, true);
                    _S2444 = false;
                    _S2354 = _S2447;
                }
                uint _S2448 = __ballot_sync(_S2354, _S2444);
                if(_S2444)
                {
                    uint mode_4 = mode_1 | 2U;
                    uint _S2449 = __ballot_sync(_S2354, true);
                    mode_2 = mode_4;
                    _S2355 = _S2449;
                }
                else
                {
                    uint _S2450 = __ballot_sync(_S2354, true);
                    mode_2 = mode_1;
                    _S2355 = _S2450;
                }
                uint _S2451 = __ballot_sync(_S2355, settled_1);
                bool _S2452;
                if(settled_1)
                {
                    bool _S2453 = !quiet_2;
                    uint _S2454 = __ballot_sync(_S2355, true);
                    _S2452 = _S2453;
                    c_49 = _S2454;
                }
                else
                {
                    uint _S2455 = __ballot_sync(_S2355, true);
                    _S2452 = false;
                    c_49 = _S2455;
                }
                uint _S2456 = __ballot_sync(c_49, _S2452);
                if(_S2452)
                {
                    uint mode_5 = mode_2 | 128U;
                    uint _S2457 = __ballot_sync(c_49, true);
                    mode_3 = mode_5;
                }
                else
                {
                    uint _S2458 = __ballot_sync(c_49, true);
                    mode_3 = mode_2;
                }
                *&g_flag_0 = 1U;
                uint _S2459 = __ballot_sync(_S2353, true);
                mode_1 = mode_3;
            }
            else
            {
                uint _S2460 = __ballot_sync(_S2353, true);
                mode_1 = 0U;
            }
            (*&g_mode_0)[i_32] = mode_1;
            uint _S2461 = __ballot_sync(_S2403, true);
            i_32 = i_32 + 256U;
            _S2403 = _S2461;
        }
        uint _S2462 = 0U;
        __syncthreads();
        bool _S2463 = (*&g_flag_0) == 0U;
        uint _S2464 = __ballot_sync(_S2357, _S2463);
        if(_S2463)
        {
            break;
        }
        else
        {
            uint _S2465 = __ballot_sync(_S2357, true);
            _S2462 = _S2465;
        }
        uint _S2466 = _S2383 % 32U;
        p_17 = _S2383 / 32U;
        _S2352 = _S2462;
        for(;;)
        {
            uint _S2467 = 0U;
            uint _S2468 = __ldg(&globalParams_0->params_0->pair_count_0);
            bool _S2469 = p_17 < _S2468;
            uint _S2470 = __ballot_sync(_S2352, _S2469);
            if(_S2469)
            {
                uint _S2471 = __ballot_sync(_S2352, true);
                _S2467 = _S2471;
            }
            else
            {
                uint _S2472 = __ballot_sync(_S2352, false);
                uint _S2473 = __ballot_sync(_S2352, false);
                uint _S2474 = __ballot_sync(_S2462, true);
                _S2358 = _S2474;
                break;
            }
            bool _S2475 = pair_any_0(stopped_0(), 32U, _S2467);
            bool _S2476 = !_S2475;
            uint _S2477 = __ballot_sync(_S2467, _S2476);
            if(_S2476)
            {
                pair_contact_0(p_17, _S2466, 32U, _S2477);
                uint _S2478 = __ballot_sync(_S2467, true);
            }
            else
            {
                uint _S2479 = __ballot_sync(_S2467, true);
            }
            uint _S2480 = __ballot_sync(_S2352, true);
            p_17 = p_17 + 8U;
            _S2352 = _S2480;
        }
        q_14 = _S2383 / 32U;
        _S2353 = _S2358;
        for(;;)
        {
            uint _S2481 = 0U;
            uint _S2482 = __ldg(&globalParams_0->params_0->cand_count_0);
            bool _S2483 = q_14 < _S2482;
            uint _S2484 = __ballot_sync(_S2353, _S2483);
            if(_S2483)
            {
                uint _S2485 = __ballot_sync(_S2353, true);
                _S2481 = _S2485;
            }
            else
            {
                uint _S2486 = __ballot_sync(_S2353, false);
                uint _S2487 = __ballot_sync(_S2353, false);
                uint _S2488 = __ballot_sync(_S2358, true);
                _S2359 = _S2488;
                break;
            }
            bool _S2489 = pair_any_0(stopped_0(), 32U, _S2481);
            bool _S2490 = !_S2489;
            uint _S2491 = __ballot_sync(_S2481, _S2490);
            if(_S2490)
            {
                impactor_candidate_forces_0(q_14, _S2466, 32U, _S2491);
                uint _S2492 = __ballot_sync(_S2481, true);
            }
            else
            {
                uint _S2493 = __ballot_sync(_S2481, true);
            }
            uint _S2494 = __ballot_sync(_S2353, true);
            q_14 = q_14 + 8U;
            _S2353 = _S2494;
        }
        c_48 = _S2383;
        mode_1 = _S2359;
        for(;;)
        {
            uint _S2495 = __ldg(&globalParams_0->params_0->chunk_count_0);
            bool _S2496 = c_48 < _S2495;
            uint _S2497 = __ballot_sync(mode_1, _S2496);
            if(_S2496)
            {
                uint _S2498 = __ballot_sync(mode_1, true);
            }
            else
            {
                uint _S2499 = __ballot_sync(mode_1, false);
                uint _S2500 = __ballot_sync(mode_1, false);
                uint _S2501 = __ballot_sync(_S2359, true);
                _S2360 = _S2501;
                break;
            }
            travel_check_0(c_48);
            uint _S2502 = __ballot_sync(mode_1, true);
            c_48 = c_48 + 256U;
            mode_1 = _S2502;
        }
        uint _S2503 = 0U;
        __syncthreads();
        uint _S2504 = __ldg(&globalParams_0->params_0->halt_index_0);
        bool _S2505 = (((&(globalParams_0->islands_0)[_S2504])->info_1.z) & 1U) != 0U;
        uint _S2506 = __ballot_sync(_S2360, _S2505);
        if(_S2505)
        {
            break;
        }
        else
        {
            uint _S2507 = __ballot_sync(_S2360, true);
            _S2503 = _S2507;
        }
        g_4 = _S2383;
        _S2354 = _S2503;
        for(;;)
        {
            uint _S2508 = __ldg(&globalParams_0->params_0->seg_count_0);
            bool _S2509 = g_4 < _S2508;
            uint _S2510 = __ballot_sync(_S2354, _S2509);
            if(_S2509)
            {
                uint _S2511 = __ballot_sync(_S2354, true);
            }
            else
            {
                uint _S2512 = __ballot_sync(_S2354, false);
                uint _S2513 = __ballot_sync(_S2354, false);
                uint _S2514 = __ballot_sync(_S2503, true);
                _S2361 = _S2514;
                break;
            }
            contact_sum_at_0(g_4);
            uint _S2515 = __ballot_sync(_S2354, true);
            g_4 = g_4 + 256U;
            _S2354 = _S2515;
        }
        mode_2 = 0U;
        _S2355 = _S2361;
        for(;;)
        {
            uint _S2516 = 0U;
            uint _S2517 = __ldg(&globalParams_0->params_0->impactor_count_0);
            bool _S2518 = mode_2 < _S2517;
            uint _S2519 = __ballot_sync(_S2355, _S2518);
            if(_S2518)
            {
                uint _S2520 = __ballot_sync(_S2355, true);
                _S2516 = _S2520;
            }
            else
            {
                uint _S2521 = __ballot_sync(_S2355, false);
                uint _S2522 = __ballot_sync(_S2355, false);
                uint _S2523 = __ballot_sync(_S2361, true);
                _S2362 = _S2523;
                break;
            }
            impactor_integrate_at_0(mode_2, _S2383, _S2516);
            __syncthreads();
            uint _S2524 = __ballot_sync(_S2355, true);
            mode_2 = mode_2 + 1U;
            _S2355 = _S2524;
        }
        __syncthreads();
        c_49 = _S2383;
        mode_3 = _S2362;
        for(;;)
        {
            uint _S2525 = 0U;
            uint _S2526 = __ldg(&globalParams_0->params_0->chunk_count_0);
            bool _S2527 = c_49 < _S2526;
            uint _S2528 = __ballot_sync(mode_3, _S2527);
            if(_S2527)
            {
                uint _S2529 = __ballot_sync(mode_3, true);
                _S2525 = _S2529;
            }
            else
            {
                uint _S2530 = __ballot_sync(mode_3, false);
                uint _S2531 = __ballot_sync(mode_3, false);
                uint _S2532 = __ballot_sync(_S2362, true);
                _S2363 = _S2532;
                break;
            }
            uint4  _S2533 = __ldg(&(&(globalParams_0->chunks_0)[c_49])->info_0);
            uint i_33 = _S2533.y;
            bool _S2534 = (((*&g_mode_0)[i_33]) & 128U) == 0U;
            uint _S2535 = __ballot_sync(_S2525, _S2534);
            if(_S2534)
            {
                uint _S2536 = __ballot_sync(_S2525, false);
                uint _S2537 = __ballot_sync(mode_3, true);
                mode_3 = _S2537;
                c_49 = c_49 + 256U;
                continue;
            }
            else
            {
                uint _S2538 = __ballot_sync(_S2525, true);
            }
            Quat_0 _S2539 = quat_of_0((&(globalParams_0->islands_0)[i_33])->rotation_0);
            uint _S2540 = pc_k_1(i_33);
            Quat_0 _S2541 = _S2539;
            float _S2542 = settled_chunk_load_0(c_49, &_S2541, _S2540, _S2385, true);
            uint _S2543 = __ldg(&globalParams_0->params_0->pc_base_0);
            uint _S2544 = 2U * c_49;
            *(&(globalParams_0->scratch_0)[_S2543 + _S2544]) = make_float4 (_S2542, 0.0f, 0.0f, 0.0f);
            uint _S2545 = __ldg(&globalParams_0->params_0->pc_base_0);
            *(&(globalParams_0->scratch_0)[_S2545 + _S2544 + 1U]) = make_float4 (0.0f);
            uint _S2546 = __ballot_sync(mode_3, true);
            mode_3 = _S2546;
            c_49 = c_49 + 256U;
        }
        __syncthreads();
        uint i_34 = _S2383;
        uint _S2547 = _S2363;
        for(;;)
        {
            uint _S2548 = 0U;
            bool _S2549 = i_34 < _S2384;
            uint _S2550 = __ballot_sync(_S2547, _S2549);
            if(_S2549)
            {
                uint _S2551 = __ballot_sync(_S2547, true);
                _S2548 = _S2551;
            }
            else
            {
                uint _S2552 = __ballot_sync(_S2547, false);
                uint _S2553 = __ballot_sync(_S2547, false);
                uint _S2554 = __ballot_sync(_S2363, true);
                _S2364 = _S2554;
                break;
            }
            uint _S2555 = 0U;
            uint mode_6 = (*&g_mode_0)[i_34];
            bool _S2556 = (((*&g_mode_0)[i_34]) & 128U) == 0U;
            uint _S2557 = __ballot_sync(_S2548, _S2556);
            if(_S2556)
            {
                uint _S2558 = __ballot_sync(_S2548, false);
                uint _S2559 = __ballot_sync(_S2547, true);
                _S2547 = _S2559;
                i_34 = i_34 + 256U;
                continue;
            }
            else
            {
                uint _S2560 = __ballot_sync(_S2548, true);
                _S2555 = _S2560;
            }
            Island_0 isl_25 = *(&(globalParams_0->islands_0)[i_34]);
            float3  _S2561 = make_float3 (0.0f);
            float3  norm_2 = _S2561;
            float3  unused_5 = _S2561;
            pc_sum_0(i_34, &norm_2, &unused_5);
            uint _S2562 = __ballot_sync(_S2555, _S2391);
            if(_S2391)
            {
                bool _S2563 = (F32_abs((norm_2.x - isl_25.energy_1.z))) > (isl_25.energy_1.w);
                uint _S2564 = __ballot_sync(_S2555, true);
                contact_4 = _S2563;
                c_50 = _S2564;
            }
            else
            {
                uint _S2565 = __ballot_sync(_S2555, true);
                contact_4 = false;
                c_50 = _S2565;
            }
            uint _S2566 = __ballot_sync(c_50, contact_4);
            if(contact_4)
            {
                (*&g_mode_0)[i_34] = (mode_6 | 2U) | 64U;
                uint _S2567 = __ballot_sync(c_50, true);
            }
            else
            {
                uint _S2568 = __ballot_sync(c_50, true);
            }
            uint _S2569 = __ballot_sync(_S2547, true);
            _S2547 = _S2569;
            i_34 = i_34 + 256U;
        }
        __syncthreads();
        c_50 = _S2383;
        uint _S2570 = _S2364;
        for(;;)
        {
            uint _S2571 = 0U;
            uint _S2572 = __ldg(&globalParams_0->params_0->chunk_count_0);
            bool _S2573 = c_50 < _S2572;
            uint _S2574 = __ballot_sync(_S2570, _S2573);
            if(_S2573)
            {
                uint _S2575 = __ballot_sync(_S2570, true);
                _S2571 = _S2575;
            }
            else
            {
                uint _S2576 = __ballot_sync(_S2570, false);
                uint _S2577 = __ballot_sync(_S2570, false);
                uint _S2578 = __ballot_sync(_S2364, true);
                _S2365 = _S2578;
                break;
            }
            uint4  _S2579 = __ldg(&(&(globalParams_0->chunks_0)[c_50])->info_0);
            uint i_35 = _S2579.y;
            bool _S2580 = (((*&g_mode_0)[i_35]) & 4U) == 0U;
            uint _S2581 = __ballot_sync(_S2571, _S2580);
            if(_S2580)
            {
                uint _S2582 = __ballot_sync(_S2571, false);
                uint _S2583 = __ballot_sync(_S2570, true);
                _S2570 = _S2583;
                c_50 = c_50 + 256U;
                continue;
            }
            else
            {
                uint _S2584 = __ballot_sync(_S2571, true);
            }
            float3  _S2585 = make_float3 (0.0f);
            float3  f_20 = _S2585;
            float3  t_17 = _S2585;
            Rigid_0 _S2586 = rigid_of_1(i_35);
            uint _S2587 = pc_k_1(i_35);
            Rigid_0 _S2588 = _S2586;
            net_load_1(c_50, i_35, &_S2588, _S2587, _S2385, true, &f_20, &t_17);
            uint _S2589 = __ldg(&globalParams_0->params_0->pc_base_0);
            uint _S2590 = 2U * c_50;
            *(&(globalParams_0->scratch_0)[_S2589 + _S2590]) = make_float4 (f_20.x, f_20.y, f_20.z, 0.0f);
            uint _S2591 = __ldg(&globalParams_0->params_0->pc_base_0);
            *(&(globalParams_0->scratch_0)[_S2591 + _S2590 + 1U]) = make_float4 (t_17.x, t_17.y, t_17.z, 0.0f);
            uint _S2592 = __ballot_sync(_S2570, true);
            _S2570 = _S2592;
            c_50 = c_50 + 256U;
        }
        __syncthreads();
        uint i_36 = _S2383;
        uint _S2593 = _S2365;
        for(;;)
        {
            uint _S2594 = 0U;
            bool _S2595 = i_36 < _S2384;
            uint _S2596 = __ballot_sync(_S2593, _S2595);
            if(_S2595)
            {
                uint _S2597 = __ballot_sync(_S2593, true);
                _S2594 = _S2597;
            }
            else
            {
                uint _S2598 = __ballot_sync(_S2593, false);
                uint _S2599 = __ballot_sync(_S2593, false);
                uint _S2600 = __ballot_sync(_S2365, true);
                _S2366 = _S2600;
                break;
            }
            uint _S2601 = 0U;
            uint mode_7 = (*&g_mode_0)[i_36];
            bool _S2602 = (((*&g_mode_0)[i_36]) & 1U) == 0U;
            uint _S2603 = __ballot_sync(_S2594, _S2602);
            if(_S2602)
            {
                uint _S2604 = __ballot_sync(_S2594, false);
                uint _S2605 = __ballot_sync(_S2593, true);
                _S2593 = _S2605;
                i_36 = i_36 + 256U;
                continue;
            }
            else
            {
                uint _S2606 = __ballot_sync(_S2594, true);
                _S2601 = _S2606;
            }
            Island_0 isl_26 = *(&(globalParams_0->islands_0)[i_36]);
            Rigid_0 rg_13 = rigid_of_1(i_36);
            bool _S2607 = (mode_7 & 4U) != 0U;
            uint _S2608 = __ballot_sync(_S2601, _S2607);
            if(_S2607)
            {
                float3  _S2609 = make_float3 (0.0f);
                float3  f_21 = _S2609;
                float3  t_18 = _S2609;
                pc_sum_0(i_36, &f_21, &t_18);
                Island_0 _S2610 = isl_26;
                rigid_acceleration_0(&_S2610, &rg_13, f_21, t_18);
                uint _S2611 = __ballot_sync(_S2601, true);
                b_32 = _S2611;
            }
            else
            {
                uint _S2612 = __ballot_sync(_S2601, true);
                b_32 = _S2612;
            }
            Rigid_0 _S2613 = rg_13;
            pc_store_rigid_0(i_36, &_S2613);
            bool _S2614 = (mode_7 & 6U) == 6U;
            uint _S2615 = __ballot_sync(b_32, _S2614);
            if(_S2614)
            {
                (*&g_mode_0)[i_36] = mode_7 | 16U;
                uint _S2616 = __ballot_sync(b_32, true);
            }
            else
            {
                uint _S2617 = __ballot_sync(b_32, true);
            }
            uint _S2618 = __ballot_sync(_S2593, true);
            _S2593 = _S2618;
            i_36 = i_36 + 256U;
        }
        __syncthreads();
        b_32 = _S2383;
        uint _S2619 = _S2366;
        for(;;)
        {
            uint _S2620 = 0U;
            uint _S2621 = __ldg(&globalParams_0->params_0->bond_count_0);
            bool _S2622 = b_32 < _S2621;
            uint _S2623 = __ballot_sync(_S2619, _S2622);
            if(_S2622)
            {
                uint _S2624 = __ballot_sync(_S2619, true);
                _S2620 = _S2624;
            }
            else
            {
                uint _S2625 = __ballot_sync(_S2619, false);
                uint _S2626 = __ballot_sync(_S2619, false);
                uint _S2627 = __ballot_sync(_S2366, true);
                _S2367 = _S2627;
                break;
            }
            uint _S2628 = 0U;
            JointBond_0 _S2629 = slang_ldg_0(&(&(globalParams_0->bonds_0)[b_32])->law_0);
            uint i_37 = _S2629.ids_0.w;
            uint mode_8 = (*&g_mode_0)[i_37];
            bool _S2630 = (((*&g_mode_0)[i_37]) & 2U) == 0U;
            uint _S2631 = __ballot_sync(_S2620, _S2630);
            if(_S2630)
            {
                uint _S2632 = __ballot_sync(_S2620, false);
                uint _S2633 = __ballot_sync(_S2619, true);
                _S2619 = _S2633;
                b_32 = b_32 + 256U;
                continue;
            }
            else
            {
                uint _S2634 = __ballot_sync(_S2620, true);
                _S2628 = _S2634;
            }
            bool _S2635 = bond_update_0(b_32, _S2385, _S2387, (&(globalParams_0->islands_0)[i_37])->info_1.w + 1U, (((&(globalParams_0->islands_0)[i_37])->info_1.x) & 8U) != 0U);
            uint _S2636 = __ballot_sync(_S2628, _S2635);
            if(_S2635)
            {
                (*&g_mode_0)[i_37] = mode_8 | 32U;
                uint _S2637 = __ballot_sync(_S2628, true);
            }
            else
            {
                uint _S2638 = __ballot_sync(_S2628, true);
            }
            uint _S2639 = __ballot_sync(_S2619, true);
            _S2619 = _S2639;
            b_32 = b_32 + 256U;
        }
        __syncthreads();
        uint c_52 = _S2383;
        uint _S2640 = _S2367;
        for(;;)
        {
            uint _S2641 = 0U;
            uint _S2642 = __ldg(&globalParams_0->params_0->chunk_count_0);
            bool _S2643 = c_52 < _S2642;
            uint _S2644 = __ballot_sync(_S2640, _S2643);
            if(_S2643)
            {
                uint _S2645 = __ballot_sync(_S2640, true);
                _S2641 = _S2645;
            }
            else
            {
                uint _S2646 = __ballot_sync(_S2640, false);
                uint _S2647 = __ballot_sync(_S2640, false);
                uint _S2648 = __ballot_sync(_S2367, true);
                _S2368 = _S2648;
                break;
            }
            uint4  _S2649 = __ldg(&(&(globalParams_0->chunks_0)[c_52])->info_0);
            uint i_38 = _S2649.y;
            bool _S2650 = (((*&g_mode_0)[i_38]) & 2U) == 0U;
            uint _S2651 = __ballot_sync(_S2641, _S2650);
            if(_S2650)
            {
                uint _S2652 = __ballot_sync(_S2641, false);
                uint _S2653 = __ballot_sync(_S2640, true);
                _S2640 = _S2653;
                c_52 = c_52 + 256U;
                continue;
            }
            else
            {
                uint _S2654 = __ballot_sync(_S2641, true);
            }
            float work_5 = 0.0f;
            float work_err_3 = 0.0f;
            Rigid_0 _S2655 = pc_load_rigid_0(i_38);
            uint _S2656 = pc_k_1(i_38);
            Rigid_0 _S2657 = _S2655;
            chunk_update_1(c_52, i_38, &_S2657, _S2385, _S2389, _S2656, true, &work_5, &work_err_3);
            uint _S2658 = __ldg(&globalParams_0->params_0->pc_base_0);
            uint _S2659 = 2U * c_52;
            *(&(globalParams_0->scratch_0)[_S2658 + _S2659]) = make_float4 (work_5, work_err_3, 0.0f, 0.0f);
            uint _S2660 = __ldg(&globalParams_0->params_0->pc_base_0);
            *(&(globalParams_0->scratch_0)[_S2660 + _S2659 + 1U]) = make_float4 (0.0f);
            uint _S2661 = __ballot_sync(_S2640, true);
            _S2640 = _S2661;
            c_52 = c_52 + 256U;
        }
        __syncthreads();
        uint i_39 = _S2383;
        uint _S2662 = _S2368;
        for(;;)
        {
            uint _S2663 = 0U;
            bool _S2664 = i_39 < _S2384;
            uint _S2665 = __ballot_sync(_S2662, _S2664);
            if(_S2664)
            {
                uint _S2666 = __ballot_sync(_S2662, true);
                _S2663 = _S2666;
            }
            else
            {
                uint _S2667 = __ballot_sync(_S2662, false);
                uint _S2668 = __ballot_sync(_S2662, false);
                uint _S2669 = __ballot_sync(_S2368, true);
                _S2370 = _S2669;
                break;
            }
            uint _S2670 = 0U;
            uint mode_9 = (*&g_mode_0)[i_39];
            bool _S2671 = (((*&g_mode_0)[i_39]) & 1U) == 0U;
            uint _S2672 = __ballot_sync(_S2663, _S2671);
            if(_S2671)
            {
                uint _S2673 = __ballot_sync(_S2663, false);
                uint _S2674 = __ballot_sync(_S2662, true);
                _S2662 = _S2674;
                i_39 = i_39 + 256U;
                continue;
            }
            else
            {
                uint _S2675 = __ballot_sync(_S2663, true);
                _S2670 = _S2675;
            }
            Island_0 isl_27 = *(&(globalParams_0->islands_0)[i_39]);
            Rigid_0 rg_14 = pc_load_rigid_0(i_39);
            bool _S2676 = (mode_9 & 2U) != 0U;
            uint _S2677 = __ballot_sync(_S2670, _S2676);
            if(_S2676)
            {
                float work_6 = 0.0f;
                float work_err_4 = 0.0f;
                c_51 = (&isl_27)->range_0.x;
                _S2369 = _S2677;
                for(;;)
                {
                    bool _S2678 = c_51 < ((&isl_27)->range_0.y);
                    uint _S2679 = __ballot_sync(_S2369, _S2678);
                    if(_S2678)
                    {
                        uint _S2680 = __ballot_sync(_S2369, true);
                    }
                    else
                    {
                        uint _S2681 = __ballot_sync(_S2369, false);
                        uint _S2682 = __ballot_sync(_S2369, false);
                        uint _S2683 = __ballot_sync(_S2677, true);
                        break;
                    }
                    uint _S2684 = __ldg(&globalParams_0->params_0->pc_base_0);
                    float4  * _S2685 = (&(globalParams_0->scratch_0)[_S2684 + 2U * c_51]);
                    comp_add1_0(&work_6, &work_err_4, (*_S2685).x);
                    work_err_4 = work_err_4 + (*_S2685).y;
                    uint _S2686 = __ballot_sync(_S2369, true);
                    c_51 = c_51 + 1U;
                    _S2369 = _S2686;
                }
                comp_add1_0(&((&(&isl_27)->energy_1)->x), &((&(&isl_27)->energy_1)->y), work_6);
                *&((&(&isl_27)->energy_1)->y) = *&((&(&isl_27)->energy_1)->y) + work_err_4;
                (&(globalParams_0->islands_0)[i_39])->energy_1 = (&isl_27)->energy_1;
                uint _S2687 = __ballot_sync(_S2670, true);
                c_51 = _S2687;
            }
            else
            {
                uint _S2688 = __ballot_sync(_S2670, true);
                c_51 = _S2688;
            }
            bool _S2689 = (mode_9 & 8U) != 0U;
            uint _S2690 = __ballot_sync(c_51, _S2689);
            if(_S2689)
            {
                Island_0 _S2691 = isl_27;
                integrate_rigid_0(&_S2691, &rg_14, _S2385);
                uint _S2692 = __ballot_sync(c_51, true);
            }
            else
            {
                uint _S2693 = __ballot_sync(c_51, true);
            }
            Rigid_0 _S2694 = rg_14;
            pc_store_rigid_0(i_39, &_S2694);
            uint _S2695 = __ballot_sync(_S2662, true);
            _S2662 = _S2695;
            i_39 = i_39 + 256U;
        }
        __syncthreads();
        c_51 = _S2383;
        _S2369 = _S2370;
        for(;;)
        {
            uint _S2696 = 0U;
            uint _S2697 = __ldg(&globalParams_0->params_0->chunk_count_0);
            bool _S2698 = c_51 < _S2697;
            uint _S2699 = __ballot_sync(_S2369, _S2698);
            if(_S2698)
            {
                uint _S2700 = __ballot_sync(_S2369, true);
                _S2696 = _S2700;
            }
            else
            {
                uint _S2701 = __ballot_sync(_S2369, false);
                uint _S2702 = __ballot_sync(_S2369, false);
                uint _S2703 = __ballot_sync(_S2370, true);
                _S2371 = _S2703;
                break;
            }
            uint4  _S2704 = __ldg(&(&(globalParams_0->chunks_0)[c_51])->info_0);
            bool _S2705 = (((*&g_mode_0)[_S2704.y]) & 16U) == 0U;
            uint _S2706 = __ballot_sync(_S2696, _S2705);
            if(_S2705)
            {
                uint _S2707 = __ballot_sync(_S2696, false);
                uint _S2708 = __ballot_sync(_S2369, true);
                _S2369 = _S2708;
                c_51 = c_51 + 256U;
                continue;
            }
            else
            {
                uint _S2709 = __ballot_sync(_S2696, true);
            }
            float3  _S2710 = make_float3 (0.0f);
            float3  tu_5 = _S2710;
            float3  pv_5 = _S2710;
            drift_moments_0(c_51, &tu_5, &pv_5);
            uint _S2711 = __ldg(&globalParams_0->params_0->pc_base_0);
            uint _S2712 = 2U * c_51;
            *(&(globalParams_0->scratch_0)[_S2711 + _S2712]) = make_float4 (tu_5.x, tu_5.y, tu_5.z, 0.0f);
            uint _S2713 = __ldg(&globalParams_0->params_0->pc_base_0);
            *(&(globalParams_0->scratch_0)[_S2713 + _S2712 + 1U]) = make_float4 (pv_5.x, pv_5.y, pv_5.z, 0.0f);
            uint _S2714 = __ballot_sync(_S2369, true);
            _S2369 = _S2714;
            c_51 = c_51 + 256U;
        }
        __syncthreads();
        uint i_40 = _S2383;
        uint _S2715 = _S2371;
        for(;;)
        {
            uint _S2716 = 0U;
            bool _S2717 = i_40 < _S2384;
            uint _S2718 = __ballot_sync(_S2715, _S2717);
            if(_S2717)
            {
                uint _S2719 = __ballot_sync(_S2715, true);
                _S2716 = _S2719;
            }
            else
            {
                uint _S2720 = __ballot_sync(_S2715, false);
                uint _S2721 = __ballot_sync(_S2715, false);
                uint _S2722 = __ballot_sync(_S2371, true);
                _S2372 = _S2722;
                break;
            }
            bool _S2723 = (((*&g_mode_0)[i_40]) & 16U) == 0U;
            uint _S2724 = __ballot_sync(_S2716, _S2723);
            if(_S2723)
            {
                uint _S2725 = __ballot_sync(_S2716, false);
                uint _S2726 = __ballot_sync(_S2715, true);
                _S2715 = _S2726;
                i_40 = i_40 + 256U;
                continue;
            }
            else
            {
                uint _S2727 = __ballot_sync(_S2716, true);
            }
            Island_0 isl_28 = *(&(globalParams_0->islands_0)[i_40]);
            float3  _S2728 = make_float3 (0.0f);
            float3  tu_6 = _S2728;
            float3  pv_6 = _S2728;
            pc_sum_0(i_40, &tu_6, &pv_6);
            uint _S2729 = __ldg(&globalParams_0->params_0->pi_base_0);
            uint _S2730 = 16U * i_40;
            float _S2731 = isl_28.wcom_0.w;
            *(&(globalParams_0->scratch_0)[_S2729 + _S2730 + 12U]) = make_float4 ((tu_6 / make_float3 (_S2731)).x, (tu_6 / make_float3 (_S2731)).y, (tu_6 / make_float3 (_S2731)).z, 0.0f);
            uint _S2732 = __ldg(&globalParams_0->params_0->pi_base_0);
            *(&(globalParams_0->scratch_0)[_S2732 + _S2730 + 13U]) = make_float4 ((pv_6 / make_float3 (_S2731)).x, (pv_6 / make_float3 (_S2731)).y, (pv_6 / make_float3 (_S2731)).z, 0.0f);
            uint _S2733 = __ballot_sync(_S2715, true);
            _S2715 = _S2733;
            i_40 = i_40 + 256U;
        }
        __syncthreads();
        uint c_53 = _S2383;
        uint _S2734 = _S2372;
        for(;;)
        {
            uint _S2735 = 0U;
            uint _S2736 = __ldg(&globalParams_0->params_0->chunk_count_0);
            bool _S2737 = c_53 < _S2736;
            uint _S2738 = __ballot_sync(_S2734, _S2737);
            if(_S2737)
            {
                uint _S2739 = __ballot_sync(_S2734, true);
                _S2735 = _S2739;
            }
            else
            {
                uint _S2740 = __ballot_sync(_S2734, false);
                uint _S2741 = __ballot_sync(_S2734, false);
                uint _S2742 = __ballot_sync(_S2372, true);
                _S2373 = _S2742;
                break;
            }
            uint4  _S2743 = __ldg(&(&(globalParams_0->chunks_0)[c_53])->info_0);
            uint i_41 = _S2743.y;
            bool _S2744 = (((*&g_mode_0)[i_41]) & 16U) == 0U;
            uint _S2745 = __ballot_sync(_S2735, _S2744);
            if(_S2744)
            {
                uint _S2746 = __ballot_sync(_S2735, false);
                uint _S2747 = __ballot_sync(_S2734, true);
                _S2734 = _S2747;
                c_53 = c_53 + 256U;
                continue;
            }
            else
            {
                uint _S2748 = __ballot_sync(_S2735, true);
            }
            float3  _S2749 = make_float3 (0.0f);
            float3  lu_4 = _S2749;
            float3  lv_4 = _S2749;
            float4  _S2750 = (&(globalParams_0->islands_0)[i_41])->wcom_0;
            float3  _S2751 = float3 {_S2750.x, _S2750.y, _S2750.z};
            uint _S2752 = __ldg(&globalParams_0->params_0->pi_base_0);
            uint _S2753 = 16U * i_41;
            float4  _S2754 = *(&(globalParams_0->scratch_0)[_S2752 + _S2753 + 12U]);
            float3  _S2755 = float3 {_S2754.x, _S2754.y, _S2754.z};
            uint _S2756 = __ldg(&globalParams_0->params_0->pi_base_0);
            float4  _S2757 = *(&(globalParams_0->scratch_0)[_S2756 + _S2753 + 13U]);
            drift_angular_0(c_53, _S2751, _S2755, float3 {_S2757.x, _S2757.y, _S2757.z}, &lu_4, &lv_4);
            uint _S2758 = __ldg(&globalParams_0->params_0->pc_base_0);
            uint _S2759 = 2U * c_53;
            *(&(globalParams_0->scratch_0)[_S2758 + _S2759]) = make_float4 (lu_4.x, lu_4.y, lu_4.z, 0.0f);
            uint _S2760 = __ldg(&globalParams_0->params_0->pc_base_0);
            *(&(globalParams_0->scratch_0)[_S2760 + _S2759 + 1U]) = make_float4 (lv_4.x, lv_4.y, lv_4.z, 0.0f);
            uint _S2761 = __ballot_sync(_S2734, true);
            _S2734 = _S2761;
            c_53 = c_53 + 256U;
        }
        __syncthreads();
        uint i_42 = _S2383;
        uint _S2762 = _S2373;
        for(;;)
        {
            uint _S2763 = 0U;
            bool _S2764 = i_42 < _S2384;
            uint _S2765 = __ballot_sync(_S2762, _S2764);
            if(_S2764)
            {
                uint _S2766 = __ballot_sync(_S2762, true);
                _S2763 = _S2766;
            }
            else
            {
                uint _S2767 = __ballot_sync(_S2762, false);
                uint _S2768 = __ballot_sync(_S2762, false);
                uint _S2769 = __ballot_sync(_S2373, true);
                _S2374 = _S2769;
                break;
            }
            bool _S2770 = (((*&g_mode_0)[i_42]) & 16U) == 0U;
            uint _S2771 = __ballot_sync(_S2763, _S2770);
            if(_S2770)
            {
                uint _S2772 = __ballot_sync(_S2763, false);
                uint _S2773 = __ballot_sync(_S2762, true);
                _S2762 = _S2773;
                i_42 = i_42 + 256U;
                continue;
            }
            else
            {
                uint _S2774 = __ballot_sync(_S2763, true);
            }
            Island_0 isl_29 = *(&(globalParams_0->islands_0)[i_42]);
            float3  _S2775 = make_float3 (0.0f);
            float3  lu_5 = _S2775;
            float3  lv_5 = _S2775;
            pc_sum_0(i_42, &lu_5, &lv_5);
            uint _S2776 = __ldg(&globalParams_0->params_0->pi_base_0);
            uint _S2777 = 16U * i_42;
            *(&(globalParams_0->scratch_0)[_S2776 + _S2777 + 14U]) = make_float4 (rows_mul_0(isl_29.winv0_0, isl_29.winv1_0, isl_29.winv2_0, lu_5).x, rows_mul_0(isl_29.winv0_0, isl_29.winv1_0, isl_29.winv2_0, lu_5).y, rows_mul_0(isl_29.winv0_0, isl_29.winv1_0, isl_29.winv2_0, lu_5).z, 0.0f);
            uint _S2778 = __ldg(&globalParams_0->params_0->pi_base_0);
            *(&(globalParams_0->scratch_0)[_S2778 + _S2777 + 15U]) = make_float4 (rows_mul_0(isl_29.winv0_0, isl_29.winv1_0, isl_29.winv2_0, lv_5).x, rows_mul_0(isl_29.winv0_0, isl_29.winv1_0, isl_29.winv2_0, lv_5).y, rows_mul_0(isl_29.winv0_0, isl_29.winv1_0, isl_29.winv2_0, lv_5).z, 0.0f);
            uint _S2779 = __ballot_sync(_S2762, true);
            _S2762 = _S2779;
            i_42 = i_42 + 256U;
        }
        __syncthreads();
        uint c_54 = _S2383;
        uint _S2780 = _S2374;
        for(;;)
        {
            uint _S2781 = 0U;
            uint _S2782 = __ldg(&globalParams_0->params_0->chunk_count_0);
            bool _S2783 = c_54 < _S2782;
            uint _S2784 = __ballot_sync(_S2780, _S2783);
            if(_S2783)
            {
                uint _S2785 = __ballot_sync(_S2780, true);
                _S2781 = _S2785;
            }
            else
            {
                uint _S2786 = __ballot_sync(_S2780, false);
                uint _S2787 = __ballot_sync(_S2780, false);
                uint _S2788 = __ballot_sync(_S2374, true);
                _S2375 = _S2788;
                break;
            }
            uint4  _S2789 = __ldg(&(&(globalParams_0->chunks_0)[c_54])->info_0);
            uint i_43 = _S2789.y;
            bool _S2790 = (((*&g_mode_0)[i_43]) & 16U) == 0U;
            uint _S2791 = __ballot_sync(_S2781, _S2790);
            if(_S2790)
            {
                uint _S2792 = __ballot_sync(_S2781, false);
                uint _S2793 = __ballot_sync(_S2780, true);
                _S2780 = _S2793;
                c_54 = c_54 + 256U;
                continue;
            }
            else
            {
                uint _S2794 = __ballot_sync(_S2781, true);
            }
            uint _S2795 = __ldg(&globalParams_0->params_0->pi_base_0);
            uint at_9 = _S2795 + 16U * i_43;
            float4  _S2796 = (&(globalParams_0->islands_0)[i_43])->wcom_0;
            float4  _S2797 = *(&(globalParams_0->scratch_0)[at_9 + 12U]);
            float4  _S2798 = *(&(globalParams_0->scratch_0)[at_9 + 14U]);
            float4  _S2799 = *(&(globalParams_0->scratch_0)[at_9 + 13U]);
            float4  _S2800 = *(&(globalParams_0->scratch_0)[at_9 + 15U]);
            drift_apply_0(c_54, float3 {_S2796.x, _S2796.y, _S2796.z}, float3 {_S2797.x, _S2797.y, _S2797.z}, float3 {_S2798.x, _S2798.y, _S2798.z}, float3 {_S2799.x, _S2799.y, _S2799.z}, float3 {_S2800.x, _S2800.y, _S2800.z});
            uint _S2801 = __ballot_sync(_S2780, true);
            _S2780 = _S2801;
            c_54 = c_54 + 256U;
        }
        __syncthreads();
        uint _S2802 = __ballot_sync(_S2375, _S2398);
        uint _S2803;
        if(_S2398)
        {
            *&g_flag_0 = 0U;
            uint _S2804 = __ballot_sync(_S2375, true);
            _S2803 = _S2804;
        }
        else
        {
            uint _S2805 = __ballot_sync(_S2375, true);
            _S2803 = _S2805;
        }
        __syncthreads();
        uint i_44 = _S2383;
        uint _S2806 = _S2803;
        for(;;)
        {
            uint _S2807 = 0U;
            bool _S2808 = i_44 < _S2384;
            uint _S2809 = __ballot_sync(_S2806, _S2808);
            if(_S2808)
            {
                uint _S2810 = __ballot_sync(_S2806, true);
                _S2807 = _S2810;
            }
            else
            {
                uint _S2811 = __ballot_sync(_S2806, false);
                uint _S2812 = __ballot_sync(_S2806, false);
                uint _S2813 = __ballot_sync(_S2803, true);
                _S2376 = _S2813;
                break;
            }
            bool _S2814 = (((*&g_mode_0)[i_44]) & 32U) != 0U;
            uint _S2815 = __ballot_sync(_S2807, _S2814);
            if(_S2814)
            {
                *&g_flag_0 = 1U;
                uint _S2816 = __ballot_sync(_S2807, true);
            }
            else
            {
                uint _S2817 = __ballot_sync(_S2807, true);
            }
            uint _S2818 = __ballot_sync(_S2806, true);
            i_44 = i_44 + 256U;
            _S2806 = _S2818;
        }
        __syncthreads();
        bool halts_0 = (*&g_flag_0) != 0U;
        uint _S2819 = __ballot_sync(_S2376, halts_0);
        uint c_55;
        uint _S2820;
        uint pass_1;
        uint _S2821;
        uint _S2822;
        uint i_45;
        uint _S2823;
        uint c_56;
        uint e_9;
        uint _S2824;
        uint other_1;
        if(halts_0)
        {
            c_55 = _S2383;
            _S2820 = _S2819;
            for(;;)
            {
                uint _S2825 = 0U;
                uint _S2826 = __ldg(&globalParams_0->params_0->chunk_count_0);
                bool _S2827 = c_55 < _S2826;
                uint _S2828 = __ballot_sync(_S2820, _S2827);
                if(_S2827)
                {
                    uint _S2829 = __ballot_sync(_S2820, true);
                    _S2825 = _S2829;
                }
                else
                {
                    uint _S2830 = __ballot_sync(_S2820, false);
                    uint _S2831 = __ballot_sync(_S2820, false);
                    uint _S2832 = __ballot_sync(_S2819, true);
                    _S2377 = _S2832;
                    break;
                }
                uint4  _S2833 = __ldg(&(&(globalParams_0->chunks_0)[c_55])->info_0);
                bool _S2834 = (((*&g_mode_0)[_S2833.y]) & 32U) != 0U;
                uint _S2835 = __ballot_sync(_S2825, _S2834);
                if(_S2834)
                {
                    uint _S2836 = __ldg(&globalParams_0->params_0->pc_base_0);
                    *(&(globalParams_0->scratch_0)[_S2836 + 2U * c_55]) = make_float4 ((U32_asfloat((c_55))), 0.0f, 0.0f, 0.0f);
                    uint _S2837 = __ballot_sync(_S2825, true);
                }
                else
                {
                    uint _S2838 = __ballot_sync(_S2825, true);
                }
                uint _S2839 = __ballot_sync(_S2820, true);
                c_55 = c_55 + 256U;
                _S2820 = _S2839;
            }
            __syncthreads();
            pass_1 = 0U;
            _S2821 = _S2377;
            for(;;)
            {
                uint _S2840 = 0U;
                uint _S2841 = __ldg(&globalParams_0->params_0->chunk_count_0);
                bool _S2842 = pass_1 <= _S2841;
                uint _S2843 = __ballot_sync(_S2821, _S2842);
                if(_S2842)
                {
                    uint _S2844 = __ballot_sync(_S2821, true);
                    _S2840 = _S2844;
                }
                else
                {
                    uint _S2845 = __ballot_sync(_S2821, false);
                    uint _S2846 = __ballot_sync(_S2821, false);
                    uint _S2847 = __ballot_sync(_S2377, true);
                    _S2822 = _S2847;
                    break;
                }
                uint _S2848 = __ballot_sync(_S2840, _S2398);
                if(_S2398)
                {
                    *&g_flag_0 = 0U;
                    uint _S2849 = __ballot_sync(_S2840, true);
                    _S2822 = _S2849;
                }
                else
                {
                    uint _S2850 = __ballot_sync(_S2840, true);
                    _S2822 = _S2850;
                }
                __syncthreads();
                i_45 = _S2383;
                _S2823 = _S2822;
                for(;;)
                {
                    uint _S2851 = 0U;
                    uint _S2852 = __ldg(&globalParams_0->params_0->chunk_count_0);
                    bool _S2853 = i_45 < _S2852;
                    uint _S2854 = __ballot_sync(_S2823, _S2853);
                    if(_S2853)
                    {
                        uint _S2855 = __ballot_sync(_S2823, true);
                        _S2851 = _S2855;
                    }
                    else
                    {
                        uint _S2856 = __ballot_sync(_S2823, false);
                        uint _S2857 = __ballot_sync(_S2823, false);
                        uint _S2858 = __ballot_sync(_S2822, true);
                        _S2379 = _S2858;
                        break;
                    }
                    uint _S2859 = 0U;
                    uint4  _S2860 = __ldg(&(&(globalParams_0->chunks_0)[i_45])->info_0);
                    bool _S2861 = (((*&g_mode_0)[_S2860.y]) & 32U) == 0U;
                    uint _S2862 = __ballot_sync(_S2851, _S2861);
                    if(_S2861)
                    {
                        uint _S2863 = __ballot_sync(_S2851, false);
                        uint _S2864 = __ballot_sync(_S2823, true);
                        _S2823 = _S2864;
                        i_45 = i_45 + 256U;
                        continue;
                    }
                    else
                    {
                        uint _S2865 = __ballot_sync(_S2851, true);
                        _S2859 = _S2865;
                    }
                    uint _S2866 = __ldg(&globalParams_0->params_0->pc_base_0);
                    uint _S2867 = 2U * i_45;
                    uint _S2868 = (F32_asuint(((*(&(globalParams_0->scratch_0)[_S2866 + _S2867])).x)));
                    uint _S2869 = __ldg((&(globalParams_0->index_0)[i_45]));
                    c_56 = _S2868;
                    e_9 = _S2869;
                    _S2824 = _S2859;
                    for(;;)
                    {
                        uint _S2870 = 0U;
                        uint _S2871 = __ldg((&(globalParams_0->index_0)[i_45 + 1U]));
                        bool _S2872 = e_9 < _S2871;
                        uint _S2873 = __ballot_sync(_S2824, _S2872);
                        if(_S2872)
                        {
                            uint _S2874 = __ballot_sync(_S2824, true);
                            _S2870 = _S2874;
                        }
                        else
                        {
                            uint _S2875 = __ballot_sync(_S2824, false);
                            uint _S2876 = __ballot_sync(_S2824, false);
                            uint _S2877 = __ballot_sync(_S2859, true);
                            _S2378 = _S2877;
                            break;
                        }
                        uint _S2878 = 0U;
                        uint _S2879 = __ldg((&(globalParams_0->index_0)[e_9]));
                        uint bond_2 = _S2879 >> int(1);
                        JointBond_0 _S2880 = slang_ldg_0(&(&(globalParams_0->bonds_0)[bond_2])->law_0);
                        bool _S2881 = (_S2880.stiff1_0.w) != 0.0f;
                        JointState_0 _S2882 = (&(globalParams_0->bond_dyn_0)[bond_2])->js_0;
                        bool _S2883 = connected_0(&_S2882, _S2881);
                        bool _S2884 = !_S2883;
                        uint _S2885 = __ballot_sync(_S2870, _S2884);
                        if(_S2884)
                        {
                            uint _S2886 = __ballot_sync(_S2870, false);
                            uint _S2887 = __ballot_sync(_S2824, true);
                            _S2824 = _S2887;
                            e_9 = e_9 + 1U;
                            continue;
                        }
                        else
                        {
                            uint _S2888 = __ballot_sync(_S2870, true);
                            _S2878 = _S2888;
                        }
                        bool _S2889 = (_S2879 & 1U) == 0U;
                        uint _S2890 = __ballot_sync(_S2878, _S2889);
                        if(_S2889)
                        {
                            JointBond_0 _S2891 = slang_ldg_0(&(&(globalParams_0->bonds_0)[bond_2])->law_0);
                            uint _S2892 = _S2891.ids_0.z;
                            uint _S2893 = __ballot_sync(_S2878, true);
                            other_1 = _S2892;
                        }
                        else
                        {
                            JointBond_0 _S2894 = slang_ldg_0(&(&(globalParams_0->bonds_0)[bond_2])->law_0);
                            uint _S2895 = _S2894.ids_0.y;
                            uint _S2896 = __ballot_sync(_S2878, true);
                            other_1 = _S2895;
                        }
                        uint _S2897 = __ldg(&globalParams_0->params_0->pc_base_0);
                        uint _S2898 = (U32_min((c_56), ((F32_asuint(((*(&(globalParams_0->scratch_0)[_S2897 + 2U * other_1])).x))))));
                        uint _S2899 = __ballot_sync(_S2824, true);
                        c_56 = _S2898;
                        _S2824 = _S2899;
                        e_9 = e_9 + 1U;
                    }
                    uint _S2900 = __ldg(&globalParams_0->params_0->pc_base_0);
                    uint _S2901 = (U32_min((c_56), ((F32_asuint(((*(&(globalParams_0->scratch_0)[_S2900 + 2U * c_56])).x))))));
                    uint _S2902 = __ldg(&globalParams_0->params_0->pc_base_0);
                    bool _S2903 = _S2901 < (F32_asuint(((*(&(globalParams_0->scratch_0)[_S2902 + _S2867])).x)));
                    uint _S2904 = __ballot_sync(_S2378, _S2903);
                    if(_S2903)
                    {
                        uint _S2905 = __ldg(&globalParams_0->params_0->pc_base_0);
                        *(&(globalParams_0->scratch_0)[_S2905 + _S2867]) = make_float4 ((U32_asfloat((_S2901))), 0.0f, 0.0f, 0.0f);
                        *&g_flag_0 = 1U;
                        uint _S2906 = __ballot_sync(_S2378, true);
                    }
                    else
                    {
                        uint _S2907 = __ballot_sync(_S2378, true);
                    }
                    uint _S2908 = __ballot_sync(_S2823, true);
                    _S2823 = _S2908;
                    i_45 = i_45 + 256U;
                }
                __syncthreads();
                bool changed_0 = (*&g_flag_0) != 0U;
                __syncthreads();
                bool _S2909 = !changed_0;
                uint _S2910 = __ballot_sync(_S2379, _S2909);
                if(_S2909)
                {
                    uint _S2911 = __ballot_sync(_S2379, false);
                    uint _S2912 = __ballot_sync(_S2821, false);
                    uint _S2913 = __ballot_sync(_S2377, true);
                    _S2822 = _S2913;
                    break;
                }
                else
                {
                    uint _S2914 = __ballot_sync(_S2379, true);
                }
                uint _S2915 = __ballot_sync(_S2821, true);
                pass_1 = pass_1 + 1U;
                _S2821 = _S2915;
            }
            i_45 = _S2383;
            _S2823 = _S2822;
            for(;;)
            {
                uint _S2916 = 0U;
                bool _S2917 = i_45 < _S2384;
                uint _S2918 = __ballot_sync(_S2823, _S2917);
                if(_S2917)
                {
                    uint _S2919 = __ballot_sync(_S2823, true);
                    _S2916 = _S2919;
                }
                else
                {
                    uint _S2920 = __ballot_sync(_S2823, false);
                    uint _S2921 = __ballot_sync(_S2823, false);
                    uint _S2922 = __ballot_sync(_S2822, true);
                    break;
                }
                uint _S2923 = 0U;
                bool _S2924 = (((*&g_mode_0)[i_45]) & 32U) == 0U;
                uint _S2925 = __ballot_sync(_S2916, _S2924);
                if(_S2924)
                {
                    uint _S2926 = __ballot_sync(_S2916, false);
                    uint _S2927 = __ballot_sync(_S2823, true);
                    _S2823 = _S2927;
                    i_45 = i_45 + 256U;
                    continue;
                }
                else
                {
                    uint _S2928 = __ballot_sync(_S2916, true);
                    _S2923 = _S2928;
                }
                uint4  _S2929 = (&(globalParams_0->islands_0)[i_45])->range_0;
                uint _S2930 = (&(globalParams_0->islands_0)[i_45])->range_0.x;
                contact_4 = true;
                c_56 = _S2930;
                e_9 = _S2923;
                for(;;)
                {
                    uint _S2931 = 0U;
                    bool _S2932 = c_56 < (_S2929.y);
                    uint _S2933 = __ballot_sync(e_9, _S2932);
                    if(_S2932)
                    {
                        uint _S2934 = __ballot_sync(e_9, true);
                        _S2931 = _S2934;
                    }
                    else
                    {
                        uint _S2935 = __ballot_sync(e_9, false);
                        uint _S2936 = __ballot_sync(e_9, false);
                        uint _S2937 = __ballot_sync(_S2923, true);
                        _S2380 = _S2937;
                        break;
                    }
                    uint _S2938 = __ballot_sync(_S2931, contact_4);
                    if(contact_4)
                    {
                        uint _S2939 = __ldg(&globalParams_0->params_0->pc_base_0);
                        bool _S2940 = (F32_asuint(((*(&(globalParams_0->scratch_0)[_S2939 + 2U * c_56])).x))) == _S2930;
                        uint _S2941 = __ballot_sync(_S2931, true);
                        contact_4 = _S2940;
                    }
                    else
                    {
                        uint _S2942 = __ballot_sync(_S2931, true);
                        contact_4 = false;
                    }
                    uint _S2943 = __ballot_sync(e_9, true);
                    c_56 = c_56 + 1U;
                    e_9 = _S2943;
                }
                bool _S2944 = !contact_4;
                uint _S2945 = __ballot_sync(_S2380, _S2944);
                if(_S2944)
                {
                    (*&g_mode_0)[i_45] = ((*&g_mode_0)[i_45]) | 256U;
                    uint _S2946 = __ballot_sync(_S2380, true);
                }
                else
                {
                    uint _S2947 = __ballot_sync(_S2380, true);
                }
                uint _S2948 = __ballot_sync(_S2823, true);
                _S2823 = _S2948;
                i_45 = i_45 + 256U;
            }
            __syncthreads();
            uint _S2949 = __ballot_sync(_S2376, true);
            c_55 = _S2949;
        }
        else
        {
            uint _S2950 = __ballot_sync(_S2376, true);
            c_55 = _S2950;
        }
        uint _S2951 = __ballot_sync(c_55, _S2398);
        if(_S2398)
        {
            *&g_flag_0 = 0U;
            uint _S2952 = __ballot_sync(c_55, true);
            _S2820 = _S2952;
        }
        else
        {
            uint _S2953 = __ballot_sync(c_55, true);
            _S2820 = _S2953;
        }
        __syncthreads();
        uint _S2954 = seen_bits_0();
        i_45 = _S2383;
        pass_1 = _S2820;
        for(;;)
        {
            uint _S2955 = 0U;
            bool _S2956 = i_45 < _S2384;
            uint _S2957 = __ballot_sync(pass_1, _S2956);
            if(_S2956)
            {
                uint _S2958 = __ballot_sync(pass_1, true);
                _S2955 = _S2958;
            }
            else
            {
                uint _S2959 = __ballot_sync(pass_1, false);
                uint _S2960 = __ballot_sync(pass_1, false);
                uint _S2961 = __ballot_sync(_S2820, true);
                _S2381 = _S2961;
                break;
            }
            uint _S2962 = 0U;
            uint mode_10 = (*&g_mode_0)[i_45];
            bool _S2963 = (((*&g_mode_0)[i_45]) & 1U) == 0U;
            uint _S2964 = __ballot_sync(_S2955, _S2963);
            if(_S2963)
            {
                uint _S2965 = __ballot_sync(_S2955, false);
                uint _S2966 = __ballot_sync(pass_1, true);
                pass_1 = _S2966;
                i_45 = i_45 + 256U;
                continue;
            }
            else
            {
                uint _S2967 = __ballot_sync(_S2955, true);
                _S2962 = _S2967;
            }
            Island_0 isl_30 = *(&(globalParams_0->islands_0)[i_45]);
            Rigid_0 rg_15 = pc_load_rigid_0(i_45);
            bool _S2968 = (mode_10 & 16U) != 0U;
            uint _S2969 = __ballot_sync(_S2962, _S2968);
            if(_S2968)
            {
                bool _S2970 = (((&isl_30)->info_1.x) & 2U) == 0U;
                uint _S2971 = __ballot_sync(_S2962, true);
                contact_4 = _S2970;
                _S2821 = _S2971;
            }
            else
            {
                uint _S2972 = __ballot_sync(_S2962, true);
                contact_4 = false;
                _S2821 = _S2972;
            }
            uint _S2973 = __ballot_sync(_S2821, contact_4);
            if(contact_4)
            {
                uint _S2974 = __ldg(&globalParams_0->params_0->pi_base_0);
                uint at_10 = _S2974 + 16U * i_45;
                float4  _S2975 = *(&(globalParams_0->scratch_0)[at_10 + 12U]);
                float3  _S2976 = float3 {_S2975.x, _S2975.y, _S2975.z};
                float4  _S2977 = *(&(globalParams_0->scratch_0)[at_10 + 14U]);
                float3  _S2978 = float3 {_S2977.x, _S2977.y, _S2977.z};
                float4  _S2979 = *(&(globalParams_0->scratch_0)[at_10 + 13U]);
                float3  _S2980 = float3 {_S2979.x, _S2979.y, _S2979.z};
                float4  _S2981 = *(&(globalParams_0->scratch_0)[at_10 + 15U]);
                float3  _S2982 = float3 {_S2981.x, _S2981.y, _S2981.z};
                Island_0 _S2983 = isl_30;
                drift_rigid_0(&_S2983, &rg_15, _S2976, _S2978, _S2980, _S2982);
                uint _S2984 = __ballot_sync(_S2821, true);
                _S2822 = _S2984;
            }
            else
            {
                uint _S2985 = __ballot_sync(_S2821, true);
                _S2822 = _S2985;
            }
            Quat_0 _S2986 = (&rg_15)->rot_1;
            float4  _S2987 = quat_vec_0(&_S2986);
            (&isl_30)->rotation_0 = _S2987;
            (&isl_30)->rotation_err_0 = (&rg_15)->rot_err_0;
            (&isl_30)->position_0 = make_float4 ((&rg_15)->pos_0.x, (&rg_15)->pos_0.y, (&rg_15)->pos_0.z, 0.0f);
            (&isl_30)->position_err_0 = make_float4 ((&rg_15)->pos_err_0.x, (&rg_15)->pos_err_0.y, (&rg_15)->pos_err_0.z, 0.0f);
            (&isl_30)->velocity_0 = make_float4 ((&rg_15)->vel_0.x, (&rg_15)->vel_0.y, (&rg_15)->vel_0.z, 0.0f);
            (&isl_30)->velocity_err_0 = make_float4 ((&rg_15)->vel_err_0.x, (&rg_15)->vel_err_0.y, (&rg_15)->vel_err_0.z, 0.0f);
            (&isl_30)->angular_velocity_0 = make_float4 ((&rg_15)->w_5.x, (&rg_15)->w_5.y, (&rg_15)->w_5.z, 0.0f);
            (&isl_30)->momentum_0 = make_float4 ((&rg_15)->l_1.x, (&rg_15)->l_1.y, (&rg_15)->l_1.z, 0.0f);
            (&isl_30)->momentum_err_0 = make_float4 ((&rg_15)->l_err_0.x, (&rg_15)->l_err_0.y, (&rg_15)->l_err_0.z, 0.0f);
            bool _S2988 = ((&isl_30)->probes_0.y) > ((&isl_30)->probes_0.x);
            uint _S2989 = __ballot_sync(_S2822, _S2988);
            if(_S2988)
            {
                Island_0 _S2990 = isl_30;
                uint _S2991 = pc_k_0(&_S2990);
                Island_0 _S2992 = isl_30;
                Rigid_0 _S2993 = rg_15;
                record_probes_0(&_S2992, &_S2993, _S2991);
                uint _S2994 = __ballot_sync(_S2822, true);
                _S2823 = _S2994;
            }
            else
            {
                uint _S2995 = __ballot_sync(_S2822, true);
                _S2823 = _S2995;
            }
            (&isl_30)->done_0 = (&isl_30)->done_0 + 1U;
            *&((&(&isl_30)->info_1)->y) = *&((&(&isl_30)->info_1)->y) - 1U;
            *&((&(&isl_30)->info_1)->w) = *&((&(&isl_30)->info_1)->w) + 1U;
            bool quiet_3 = (((&isl_30)->info_1.x) & 32U) != 0U;
            uint _S2996 = _S2954 | 524288U;
            bool _S2997 = (((&isl_30)->info_1.x) & 8U) != 0U;
            uint _S2998 = __ballot_sync(_S2823, _S2997);
            if(_S2997)
            {
                uint _S2999 = __ballot_sync(_S2823, true);
                c_56 = 256U;
                e_9 = _S2999;
            }
            else
            {
                uint _S3000 = __ballot_sync(_S2823, true);
                c_56 = 0U;
                e_9 = _S3000;
            }
            uint _S3001 = _S2996 | c_56;
            bool _S3002 = ((&isl_30)->probes_0.y) > ((&isl_30)->probes_0.x);
            uint _S3003 = __ballot_sync(e_9, _S3002);
            if(_S3002)
            {
                uint _S3004 = __ballot_sync(e_9, true);
                _S2824 = 262144U;
                other_1 = _S3004;
            }
            else
            {
                uint _S3005 = __ballot_sync(e_9, true);
                _S2824 = 0U;
                other_1 = _S3005;
            }
            uint _S3006 = _S3001 | _S2824;
            uint _S3007 = __ballot_sync(other_1, quiet_3);
            uint _S3008;
            uint _S3009;
            if(quiet_3)
            {
                uint _S3010 = __ballot_sync(other_1, true);
                _S3008 = 4096U;
                _S3009 = _S3010;
            }
            else
            {
                uint _S3011 = __ballot_sync(other_1, true);
                _S3008 = 0U;
                _S3009 = _S3011;
            }
            uint _S3012 = _S3006 | _S3008;
            bool _S3013 = (mode_10 & 128U) != 0U;
            uint _S3014 = __ballot_sync(_S3009, _S3013);
            uint _S3015;
            if(_S3013)
            {
                bool _S3016 = (mode_10 & 64U) == 0U;
                uint _S3017 = __ballot_sync(_S3009, true);
                _S2356 = _S3016;
                _S3015 = _S3017;
            }
            else
            {
                uint _S3018 = __ballot_sync(_S3009, true);
                _S2356 = false;
                _S3015 = _S3018;
            }
            uint _S3019 = __ballot_sync(_S3015, _S2356);
            uint _S3020;
            uint _S3021;
            if(_S2356)
            {
                uint _S3022 = __ballot_sync(_S3015, true);
                _S3020 = 512U;
                _S3021 = _S3022;
            }
            else
            {
                uint _S3023 = __ballot_sync(_S3015, true);
                _S3020 = 0U;
                _S3021 = _S3023;
            }
            uint _S3024 = _S3012 | _S3020;
            bool _S3025 = (mode_10 & 32U) != 0U;
            uint _S3026 = __ballot_sync(_S3021, _S3025);
            uint _S3027;
            uint _S3028;
            if(_S3025)
            {
                uint _S3029 = __ballot_sync(_S3021, true);
                _S3027 = 128U;
                _S3028 = _S3029;
            }
            else
            {
                uint _S3030 = __ballot_sync(_S3021, true);
                _S3027 = 0U;
                _S3028 = _S3030;
            }
            uint _S3031 = _S3024 | _S3027;
            bool _S3032 = (mode_10 & 64U) != 0U;
            uint _S3033 = __ballot_sync(_S3028, _S3032);
            uint _S3034;
            uint _S3035;
            if(_S3032)
            {
                uint _S3036 = __ballot_sync(_S3028, true);
                _S3034 = 2048U;
                _S3035 = _S3036;
            }
            else
            {
                uint _S3037 = __ballot_sync(_S3028, true);
                _S3034 = 0U;
                _S3035 = _S3037;
            }
            (&isl_30)->coverage_0 = ((&isl_30)->coverage_0) | (_S3031 | _S3034);
            uint _S3038 = __ballot_sync(_S3035, _S3032);
            uint _S3039;
            if(_S3032)
            {
                *&((&(&isl_30)->info_1)->x) = (*&((&(&isl_30)->info_1)->x)) & 4294967279U;
                *&((&(&isl_30)->info_1)->z) = (*&((&(&isl_30)->info_1)->z)) | 4U;
                uint _S3040 = __ballot_sync(_S3035, true);
                _S3039 = _S3040;
            }
            else
            {
                uint _S3041 = __ballot_sync(_S3035, true);
                _S3039 = _S3041;
            }
            bool _S3042 = (mode_10 & 256U) != 0U;
            uint _S3043 = __ballot_sync(_S3039, _S3042);
            if(_S3042)
            {
                contact_split_at_0((&isl_30)->info_1.w);
                *&((&(&isl_30)->info_1)->z) = (*&((&(&isl_30)->info_1)->z)) | 1U;
                *&g_flag_0 = 1U;
                uint _S3044 = __ballot_sync(_S3039, true);
            }
            else
            {
                uint _S3045 = __ballot_sync(_S3039, true);
            }
            *(&(globalParams_0->islands_0)[i_45]) = isl_30;
            uint _S3046 = __ballot_sync(pass_1, true);
            pass_1 = _S3046;
            i_45 = i_45 + 256U;
        }
        __syncthreads();
        bool _S3047 = (*&g_flag_0) != 0U;
        uint _S3048 = __ballot_sync(_S2381, _S3047);
        if(_S3047)
        {
            break;
        }
        else
        {
            uint _S3049 = __ballot_sync(_S2381, true);
        }
        uint _S3050 = __ballot_sync(_S2392, true);
        s_13 = s_13 + 1U;
        _S2392 = _S3050;
    }
    return;
}

