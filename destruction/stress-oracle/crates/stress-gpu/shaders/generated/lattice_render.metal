#include <metal_stdlib>
#include <metal_math>
#include <metal_texture>
using namespace metal;
float3 ramp_0(float t_0)
{
    float3 c0_0 = float3(0.15000000596046448f, 0.25f, 0.85000002384185791f);
    float3 c1_0 = float3(0.10000000149011612f, 0.75f, 0.85000002384185791f);
    float3 c2_0 = float3(0.25f, 0.80000001192092896f, 0.30000001192092896f);
    float3 c3_0 = float3(0.94999998807907104f, 0.85000002384185791f, 0.20000000298023224f);
    float3 c4_0 = float3(0.89999997615814209f, 0.20000000298023224f, 0.15000000596046448f);
    float s_0 = saturate(t_0) * 4.0f;
    if(s_0 < 1.0f)
    {
        return mix(c0_0, c1_0, float3(s_0) );
    }
    if(s_0 < 2.0f)
    {
        return mix(c1_0, c2_0, float3((s_0 - 1.0f)) );
    }
    if(s_0 < 3.0f)
    {
        return mix(c2_0, c3_0, float3((s_0 - 2.0f)) );
    }
    return mix(c3_0, c4_0, float3((s_0 - 3.0f)) );
}

struct pixelOutput_0
{
    float4 output_0 [[color(0)]];
};

struct pixelInput_0
{
    float3 normal_0 [[user(_SLANG_ATTR)]];
    float3 color_0 [[user(_SLANG_ATTR_1)]];
};

struct Camera_0
{
    array<float4, int(4)> view_proj_0;
    float4 light_0;
    float half_size_0;
    float exaggerate_0;
    float strain_max_0;
    float pad_0;
};

struct KernelContext_0
{
    packed_float4 device* rest_0;
    packed_float4 device* displacement_0;
    Camera_0 constant* camera_0;
    float device* strain_0;
};

[[fragment]] pixelOutput_0 lattice_fs(pixelInput_0 _S1 [[stage_in]], float4 position_0 [[position]], packed_float4 device* rest_1 [[buffer(1)]], packed_float4 device* displacement_1 [[buffer(2)]], Camera_0 constant* camera_1 [[buffer(0)]], float device* strain_1 [[buffer(3)]])
{
    thread KernelContext_0 kernelContext_0;
    (&kernelContext_0)->rest_0 = rest_1;
    (&kernelContext_0)->displacement_0 = displacement_1;
    (&kernelContext_0)->camera_0 = camera_1;
    (&kernelContext_0)->strain_0 = strain_1;
    pixelOutput_0 _S2 = { float4(_S1.color_0 * float3((0.34999999403953552f + 0.64999997615814209f * max(dot(normalize(_S1.normal_0), normalize(camera_1->light_0.xyz)), 0.0f))) , 1.0f) };
    return _S2;
}

struct lattice_vs_Result_0
{
    float4 position_1 [[position]];
    float3 normal_1 [[user(_SLANG_ATTR)]];
    float3 color_1 [[user(_SLANG_ATTR_1)]];
};

struct VertexOut_0
{
    float4 position_2;
    float3 normal_2;
    float3 color_2;
};

[[vertex]] lattice_vs_Result_0 lattice_vs(uint vertex_0 [[vertex_id]], uint instance_0 [[instance_id]], uint base_instance_0 [[base_instance]], packed_float4 device* rest_2 [[buffer(1)]], packed_float4 device* displacement_2 [[buffer(2)]], Camera_0 constant* camera_2 [[buffer(0)]], float device* strain_2 [[buffer(3)]])
{
    thread KernelContext_0 kernelContext_1;
    (&kernelContext_1)->rest_0 = rest_2;
    (&kernelContext_1)->displacement_0 = displacement_2;
    (&kernelContext_1)->camera_0 = camera_2;
    (&kernelContext_1)->strain_0 = strain_2;
    uint _S3 = instance_0 - base_instance_0;
    uint face_0 = vertex_0 / 6U;
    uint corner_0 = vertex_0 % 6U;
    uint axis_0 = face_0 / 2U;
    float sign_0;
    if((face_0 % 2U) == 0U)
    {
        sign_0 = 1.0f;
    }
    else
    {
        sign_0 = -1.0f;
    }
    float2 _S4 = float2(-1.0f, -1.0f);
    float2 _S5 = float2(1.0f, 1.0f);
    array<float2, int(6)> quad_0 = { { _S4, float2(1.0f, -1.0f), _S5, _S4, _S5, float2(-1.0f, 1.0f) } };
    thread float2 st_0 = quad_0[corner_0];
    if(sign_0 < 0.0f)
    {
        st_0.x = - st_0.x;
    }
    float3 p_0;
    float3 n_0;
    if(axis_0 == 0U)
    {
        float3 _S6 = float3(sign_0, 0.0f, 0.0f);
        p_0 = float3(sign_0, st_0.x, st_0.y);
        n_0 = _S6;
    }
    else
    {
        if(axis_0 == 1U)
        {
            float3 _S7 = float3(0.0f, sign_0, 0.0f);
            p_0 = float3(st_0.y, sign_0, st_0.x);
            n_0 = _S7;
        }
        else
        {
            float3 _S8 = float3(0.0f, 0.0f, sign_0);
            p_0 = float3(st_0.x, st_0.y, sign_0);
            n_0 = _S8;
        }
    }
    float3 world_0 = (float4(*((&kernelContext_1)->rest_0+_S3)) ).xyz + (float4(*((&kernelContext_1)->displacement_0+_S3)) ).xyz * float3((&kernelContext_1)->camera_0->exaggerate_0)  + p_0 * float3((&kernelContext_1)->camera_0->half_size_0) ;
    thread VertexOut_0 o_0;
    (&o_0)->position_2 = (&kernelContext_1)->camera_0->view_proj_0[int(0)] * float4(world_0.x)  + (&kernelContext_1)->camera_0->view_proj_0[int(1)] * float4(world_0.y)  + (&kernelContext_1)->camera_0->view_proj_0[int(2)] * float4(world_0.z)  + (&kernelContext_1)->camera_0->view_proj_0[int(3)];
    (&o_0)->normal_2 = n_0;
    (&o_0)->color_2 = ramp_0((&kernelContext_1)->strain_0[_S3] / (&kernelContext_1)->camera_0->strain_max_0);
    VertexOut_0 _S9 = o_0;
    thread lattice_vs_Result_0 _S10;
    (&_S10)->position_1 = _S9.position_2;
    (&_S10)->normal_1 = _S9.normal_2;
    (&_S10)->color_1 = _S9.color_2;
    return _S10;
}

